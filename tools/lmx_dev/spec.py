"""Exact Markdown sections from the working tree; no generated normative prose."""
from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path
from threading import RLock


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def slug(title: str) -> str:
    title = re.sub(r"<[^>]*>", "", title).lower().strip()
    return re.sub(r"[^\w\- ]", "", title).replace(" ", "-")


def sections(path: Path, relative: str, authority: str, data: bytes | None = None) -> list[dict]:
    lines = (data if data is not None else path.read_bytes()).decode("utf-8-sig").splitlines(keepends=True)
    boundaries, fence, pending, levels, slugs = [], None, None, [], {}
    for i, line in enumerate(lines):
        marker = re.match(r"^\s{0,3}(`{3,}|~{3,})", line)
        if marker:
            mark = marker[1]
            if fence is None:
                fence = mark
            elif mark[0] == fence[0] and len(mark) >= len(fence):
                fence = None
            continue
        if fence:
            continue
        anchor = re.fullmatch(r'\s*<a (?:id|name)="([^"]+)">\s*</a>\s*', line)
        heading = re.match(r"^(#{1,6})\s+(.+?)\s*#*\s*$", line)
        if anchor:
            pending = len(boundaries)
            boundaries.append([i, anchor[1], anchor[1], levels[-1][1] if levels else authority])
        elif heading:
            level, title = len(heading[1]), heading[2]
            while levels and levels[-1][0] >= level:
                levels.pop()
            role = levels[-1][1] if levels else authority
            if re.search(r"\bhistorical\b|истори[яч]", title, re.I):
                role = "historical"
            elif re.search(r"open questions?|открытые вопросы", title, re.I):
                role = "open_question"
            levels.append((level, role))
            if pending is not None:
                boundaries[pending][2:] = [title, role]
            else:
                base = slug(title)
                suffix = slugs.get(base, 0)
                slugs[base] = suffix + 1
                boundaries.append([i, base + (f"-{suffix}" if suffix else ""), title, role])
            pending = None
        elif line.strip():
            pending = None
    result = []
    for n, (start, anchor, title, role) in enumerate(boundaries):
        end = boundaries[n + 1][0] if n + 1 < len(boundaries) else len(lines)
        body = "".join(lines[start:end])
        result.append({"ruleId": f"{relative}#{anchor}", "title": title,
                       "authority": role, "source": {"file": relative, "anchor": anchor,
                       "lineStart": start + 1, "lineEnd": end}, "text": body,
                       "sectionHash": digest(body.encode()), "related": []})
    return result


class SpecIndex:
    def __init__(self, root: Path, catalogue: Path):
        self.root, self.catalogue = root.resolve(), catalogue
        self.revision, self.entries, self.aliases = "", {}, {}
        self.lock = RLock()

    def refresh(self) -> None:
        raw = self.catalogue.read_bytes()
        config = json.loads(raw)
        files = [(self.root / name, role) for name, role in config["documents"].items()]
        # Hash content, not mtimes or HEAD: an uncommitted correction changes the index.
        content = [(p, role, p.read_bytes()) for p, role in files]
        revision = digest(raw + b"".join(str(p.relative_to(self.root)).encode() + b"\0" + data
                                       for p, _, data in content))
        if revision == self.revision:
            return
        entries = {}
        for path, role, data in content:
            for entry in sections(path, path.relative_to(self.root).as_posix(), role, data):
                key = entry["ruleId"]
                if key in entries:
                    raise ValueError(f"Duplicate section anchor: {key}")
                entries[key] = entry
        aliases = {}
        for rule in config["rules"]:
            target = rule["source"]
            if target not in entries:
                raise ValueError(f"Missing source anchor for {rule['id']}: {target}")
            entry = dict(entries[target], ruleId=rule["id"], related=rule.get("related", []))
            entries[target] = entry
            entries[rule["id"]] = entry
            for alias in [rule["id"], *rule.get("aliases", [])]:
                aliases.setdefault(alias.casefold(), []).append(entry)
        for entry in entries.values():
            for related in entry["related"]:
                if related not in entries:
                    raise ValueError(f"Missing related rule: {related}")
        self.entries, self.aliases, self.revision = entries, aliases, revision

    @staticmethod
    def summary(entry: dict) -> dict:
        return {k: entry[k] for k in ("ruleId", "title", "authority", "source", "sectionHash")}

    def search(self, topic: str, max_chars: int = 2600, include_history: bool = False) -> dict:
        with self.lock:
            return self._search(topic, max_chars, include_history)

    def _search(self, topic: str, max_chars: int, include_history: bool) -> dict:
        if not topic.strip() or len(topic) > 300 or not 500 <= max_chars <= 80000:
            return {"status": "invalidRequest", "message": "topic: 1..300 characters; max_chars: 500..80000"}
        try:
            self.refresh()
        except (OSError, ValueError) as error:
            return {"status": "indexError", "message": str(error)}
        query = topic.strip().casefold()
        visible = lambda e: include_history or e["authority"] not in ("historical", "open_question")
        hits = [self.entries[topic]] if topic in self.entries else self.aliases.get(query, [])
        hits = [e for e in hits if visible(e)]
        if not hits:
            ranked = []
            for entry in {e["ruleId"]: e for e in self.entries.values()}.values():
                if not visible(entry):
                    continue
                # Exact notation first. No tokenization of int@:, ::, or backticks.
                title, body = entry["title"].casefold(), entry["text"].casefold()
                score = 100 if query == title else 50 if query in title else 10 if query in body else 0
                if not score and len(query.split()) > 1 and all(term in body for term in query.split()):
                    score = 3
                if score:
                    ranked.append((score, entry))
            ranked.sort(key=lambda x: (-x[0], x[1]["ruleId"]))
            if ranked:
                hits = [e for score, e in ranked if score == ranked[0][0]]
        common = {"specRevision": self.revision, "revisionScope": "catalogue and indexed working-tree Markdown"}
        if not hits:
            return dict(common, status="notFound", topic=topic)
        hits = list({e["ruleId"]: e for e in hits}.values())
        if len(hits) > 1:
            return dict(common, status="ambiguous", candidates=[self.summary(e) for e in hits[:6]],
                        candidateCount=len(hits))
        entry = hits[0]
        if len(entry["text"]) > max_chars:
            return dict(common, **self.summary(entry), status="sectionTooLarge", characters=len(entry["text"]),
                        message="Repeat with this ruleId and a larger max_chars to read the complete section.",
                        truncated=False)
        return dict(common, **entry, status="found", truncated=False)
