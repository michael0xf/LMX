#!/usr/bin/env python3
"""Audit local Markdown links and GFM/manual anchors against the uploaded archive.

Uses only the Python standard library. Reads documentation but never edits it.
Fenced/indented code, inline-code spans and HTML comments are excluded from links.
The baseline is read directly from the current uploaded ZIP/tar; no member is extracted.
"""
from __future__ import annotations

import argparse
from bisect import bisect_right
from collections import Counter
from datetime import datetime, timezone
import hashlib
import html
import json
from pathlib import Path, PurePosixPath
import posixpath
import re
import tarfile
import zipfile
import unicodedata
from urllib.parse import unquote, urlsplit

TICK = chr(96)
FENCE = re.compile(r"^ {0,3}(" + TICK + r"{3,}|~{3,})(.*)$")
REFDEF = re.compile(r"^ {0,3}\[([^\]\n]+)\]:[ \t]*(.*)$")
HTML_ID = re.compile(
    r"<(?:a|[A-Za-z][A-Za-z0-9:-]*)\b[^>]*?\b(?:id|name)\s*=\s*"
    r"(?:\"([^\"]+)\"|'([^']+)'|([^\s>]+))", re.I)
HTML_LINK = re.compile(
    r"<(?:a|img)\b[^>]*?\b(?:href|src)\s*=\s*"
    r"(?:\"([^\"]*)\"|'([^']*)'|([^\s>]+))", re.I)


def blank(text: str) -> str:
    return "".join("\n" if ch == "\n" else " " for ch in text)


def escaped(text: str, at: int) -> bool:
    n = 0
    at -= 1
    while at >= 0 and text[at] == "\\":
        n += 1
        at -= 1
    return bool(n % 2)


def mask_blocks(text: str) -> str:
    out, fence = [], None
    for line in text.splitlines(keepends=True):
        hit = FENCE.match(line)
        if fence:
            if hit and hit[1][0] == fence[0] and len(hit[1]) >= fence[1] and not hit[2].strip():
                fence = None
            out.append(blank(line))
        elif hit and not (hit[1][0] == TICK and TICK in hit[2]):
            fence = (hit[1][0], len(hit[1]))
            out.append(blank(line))
        else:
            out.append(line)
    return re.sub(r"<!--[\s\S]*?-->", lambda m: blank(m[0]), "".join(out))


def mask_inline_code(text: str) -> str:
    chars = list(text)
    i = 0
    while i < len(text):
        if text[i] != TICK or escaped(text, i):
            i += 1
            continue
        j = i
        while j < len(text) and text[j] == TICK:
            j += 1
        delimiter = text[i:j]
        k = j
        while True:
            k = text.find(delimiter, k)
            if k < 0:
                break
            if (k == 0 or text[k - 1] != TICK) and (
                k + len(delimiter) == len(text) or text[k + len(delimiter)] != TICK
            ):
                end = k + len(delimiter)
                chars[i:end] = blank(text[i:end])
                i = end
                break
            k += len(delimiter)
        else:
            continue
        if k < 0:
            i = j
    return "".join(chars)


def normalized_label(label: str) -> str:
    return re.sub(r"\s+", " ", label.strip()).casefold()


def unescape_md(value: str) -> str:
    return html.unescape(re.sub(r"\\([!\"#$%&'()*+,\-./:;<=>?@\[\]\\^_" + TICK + r"{|}~])", r"\1", value))


def destination(text: str, start: int) -> tuple[str, int] | None:
    i = start
    while i < len(text) and text[i].isspace():
        i += 1
    if i == len(text):
        return None
    if text[i] == "<":
        j = i + 1
        while j < len(text) and text[j] not in "\n\r":
            if text[j] == ">" and not escaped(text, j):
                return unescape_md(text[i + 1:j]), j + 1
            j += 1
        return None
    begin, depth = i, 0
    while i < len(text):
        ch = text[i]
        if not escaped(text, i):
            if ch.isspace() and depth == 0:
                break
            if ch == "(":
                depth += 1
            elif ch == ")":
                if depth == 0:
                    break
                depth -= 1
        i += 1
    if depth:
        return None
    return unescape_md(text[begin:i]), i


def closing_bracket(text: str, start: int) -> int | None:
    depth = 0
    for i in range(start, len(text)):
        if escaped(text, i):
            continue
        if text[i] == "[":
            depth += 1
        elif text[i] == "]":
            depth -= 1
            if depth == 0:
                return i
    return None


def inline_link_end(text: str, start: int) -> int | None:
    parsed = destination(text, start)
    if parsed is None:
        return None
    _, i = parsed
    while i < len(text) and text[i].isspace():
        i += 1
    if i < len(text) and text[i] == ")":
        return i + 1
    if i >= len(text) or text[i] not in "\"'(":
        return None
    close = ")" if text[i] == "(" else text[i]
    i += 1
    while i < len(text):
        if text[i] == close and not escaped(text, i):
            i += 1
            while i < len(text) and text[i].isspace():
                i += 1
            return i + 1 if i < len(text) and text[i] == ")" else None
        i += 1
    return None


def parse_links(source: str) -> list[dict]:
    clean = mask_inline_code(mask_blocks(source))
    # Four-space code is excluded. Ordinary list prose is not indented this way
    # in the current corpus; nested fenced blocks are already removed above.
    clean = re.sub(r"(?m)^(?: {4}|\t)[^\n]*", lambda m: blank(m[0]), clean)
    definitions, definition_spans = {}, []
    offset = 0
    for line in clean.splitlines(keepends=True):
        hit = REFDEF.match(line)
        if hit:
            parsed = destination(hit[2], 0)
            if parsed:
                definitions.setdefault(normalized_label(hit[1]), parsed[0])
                definition_spans.append((offset, offset + len(line)))
        offset += len(line)
    chars = list(clean)
    for start, end in definition_spans:
        chars[start:end] = blank(clean[start:end])
    clean = "".join(chars)
    starts = [0] + [m.end() for m in re.finditer("\n", clean)]
    links = []

    def record(at: int, target: str, form: str):
        links.append({"line": bisect_right(starts, at), "target": target, "form": form})

    i = 0
    while i < len(clean):
        if clean[i] != "[" or escaped(clean, i):
            i += 1
            continue
        end_label = closing_bracket(clean, i)
        if end_label is None:
            i += 1
            continue
        label = clean[i + 1:end_label]
        after = end_label + 1
        if after < len(clean) and clean[after] == "(":
            parsed = destination(clean, after + 1)
            end = inline_link_end(clean, after + 1)
            if parsed and end is not None:
                record(i, parsed[0], "inline")
                i = end
                continue
        if after < len(clean) and clean[after] == "[":
            ref_end = closing_bracket(clean, after)
            if ref_end is not None:
                ref = clean[after + 1:ref_end] or label
                target = definitions.get(normalized_label(ref))
                if target is not None:
                    record(i, target, "reference")
                    i = ref_end + 1
                    continue
        target = definitions.get(normalized_label(label))
        if target is not None:
            record(i, target, "shortcut_reference")
        i = end_label + 1
    for hit in HTML_LINK.finditer(clean):
        record(hit.start(), html.unescape(next(v for v in hit.groups() if v is not None)), "html")
    return sorted(links, key=lambda item: item["line"])


def heading_text(value: str) -> str:
    code_values = []

    def preserve_code(hit):
        code_values.append(hit[2].replace("\n", " ").strip())
        return f"PLACEHOLDERCODE{len(code_values) - 1}END"

    value = re.sub("(" + TICK + r"+)(.+?)\1", preserve_code, value)
    value = re.sub(r"!?\[([^\]]*)\]\([^)]*\)", r"\1", value)
    value = re.sub(r"!?\[([^\]]*)\](?:\[[^\]]*\])?", r"\1", value)
    value = re.sub(r"<[^>]*>", "", value)
    value = re.sub(r"(?<!\w)(__?)(\S(?:.*?\S)?)\1(?!\w)", r"\2", value)
    value = unescape_md(value)
    for i, code in enumerate(code_values):
        value = value.replace(f"PLACEHOLDERCODE{i}END", code)
    return value


def slug(value: str) -> str:
    value = heading_text(value).lower()
    return "".join(
        ch for ch in value
        if ch in "-_" or (not unicodedata.category(ch).startswith(("P", "S", "C")))
    ).replace(" ", "-")


def anchor_inventory(source: str) -> dict[str, list[str]]:
    clean = mask_blocks(source)
    anchor_source = mask_inline_code(clean)
    manual = {
        html.unescape(next(v for v in hit.groups() if v is not None))
        for hit in HTML_ID.finditer(anchor_source)
    }
    seen = set()
    lines = clean.splitlines()
    headings = []
    for i, line in enumerate(lines):
        hit = re.match(r"^ {0,3}#{1,6}(?:[ \t]+(.*?)|[ \t]*)$", line)
        if hit:
            headings.append(re.sub(r"[ \t]+#+[ \t]*$", "", hit[1] or "").strip())
        elif i and re.match(r"^ {0,3}(?:=+|-+)[ \t]*$", line):
            previous = lines[i - 1]
            if previous.strip() and not previous.startswith(("    ", "\t")) and not re.match(
                r"^ {0,3}(?:[-*+]|\d+[.)])\s", previous
            ):
                headings.append(previous.strip())
    for heading in headings:
        base = slug(heading)
        candidate, n = base, 0
        while candidate in seen:
            n += 1
            candidate = f"{base}-{n}"
        seen.add(candidate)
    return {"manual_ids": sorted(manual), "gfm_heading_ids": sorted(seen)}


def parse_anchors(source: str) -> set[str]:
    inventory = anchor_inventory(source)
    return set(inventory["manual_ids"]) | set(inventory["gfm_heading_ids"])


def corpus_from_directory(root: Path) -> tuple[set[str], dict[str, str]]:
    files, docs = set(), {}
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        name = path.relative_to(root).as_posix()
        files.add(name)
        if path.suffix.lower() == ".md":
            docs[name] = path.read_text(encoding="utf-8")
    return files, docs


def corpus_from_tar(path: Path) -> tuple[set[str], dict[str, str]]:
    files, docs = set(), {}
    with tarfile.open(path, "r:*") as archive:
        for member in archive.getmembers():
            if not member.isfile():
                continue
            parts = PurePosixPath(member.name).parts
            if parts and parts[0] == ".":
                parts = parts[1:]
            if parts and parts[0] == "docs":
                parts = parts[1:]
            name = str(PurePosixPath(*parts))
            files.add(name)
            if name.lower().endswith(".md"):
                stream = archive.extractfile(member)
                if stream is not None:
                    docs[name] = stream.read().decode("utf-8")
    return files, docs


def corpus_from_zip(path: Path) -> tuple[set[str], dict[str, str]]:
    files, docs = set(), {}
    with zipfile.ZipFile(path) as archive:
        for item in archive.infolist():
            if item.is_dir():
                continue
            name = item.filename.removeprefix("./")
            files.add(name)
            if name.lower().endswith(".md"):
                docs[name] = archive.read(item).decode("utf-8-sig")
    return files, docs


def resolve_all(files: set[str], docs: dict[str, str]) -> tuple[list[dict], int]:
    anchors = {name: parse_anchors(text) for name, text in docs.items()}
    rows, web = [], 0
    for name in sorted(docs):
        for link in parse_links(docs[name]):
            target = link["target"]
            parsed = urlsplit(target)
            if parsed.scheme or parsed.netloc:
                web += 1
                continue
            path = unquote(parsed.path)
            fragment = unquote(parsed.fragment)
            resolved = posixpath.normpath(posixpath.join(posixpath.dirname(name), path)) if path else name
            row = dict(source=name, **link, resolved_path=resolved, anchor=fragment)
            if path.startswith("/") or resolved == ".." or resolved.startswith("../"):
                row["status"] = "repository_external"
            elif resolved not in files:
                row["status"] = "missing_file"
            elif fragment and resolved.lower().endswith(".md") and fragment not in anchors.get(resolved, set()):
                row["status"] = "missing_anchor"
            else:
                row["status"] = "resolved"
            rows.append(row)
    return rows, web


def self_test():
    tick3 = TICK * 3
    source = (
        "# Example\n<a id='manual'></a>\n[yes](other.md#there)\n"
        + TICK + "[no](bad.md)" + TICK + "\n"
        + tick3 + "text\n[no](bad2.md)\n" + tick3 + "\n"
        + "[ref]: sub/test.md#ok\n[use][ref]\n[manual](#manual)\n"
        + "[paren](a(b).md \"title\")\n<!-- [no](bad3.md) -->\n"
    )
    assert [x["target"] for x in parse_links(source)] == [
        "other.md#there", "sub/test.md#ok", "#manual", "a(b).md"]
    assert {"example", "manual"} <= parse_anchors(source)
    assert parse_anchors("# Same\n# Same\n# Same-1\n") == {"same", "same-1", "same-1-1"}
    assert slug("Проверка " + TICK + "a_b" + TICK + " и **RHS**") == "проверка-a_b-и-rhs"
    assert not parse_links("    [not-a-link](missing.md)\n")
    assert not parse_links(TICK * 2 + "code " + TICK + " [x](bad)" + TICK * 2)
    return 6


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument("--baseline", type=Path)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--pending", action="append", default=[])
    parser.add_argument("--check-new", action="store_true", help="Exit 1 for new unresolved local links.")
    args = parser.parse_args()
    tests = self_test()
    root = args.root.resolve()
    baseline = args.baseline
    if baseline is None:
        baseline = next(
            (parent / "upload/docs.tar.gz" for parent in root.parents
             if (parent / "upload/docs.tar.gz").is_file()), None)
    if baseline is None or not baseline.is_file():
        parser.error("Use --baseline to identify the current uploaded archive.")
    output = args.output or root / "patterns/validation/doc_links_20261122.json"
    pending = {
        "patterns/STATISTICS_2026-11-22.xlsx",
        "patterns/STATISTICS_2026-11-22.pdf",
        "patterns/COMPARISON_RULES.md",
        *args.pending,
    }
    current_files, current_docs = corpus_from_directory(root)
    baseline_files, baseline_docs = (corpus_from_zip(baseline) if zipfile.is_zipfile(baseline) else corpus_from_tar(baseline))
    current_rows, current_web = resolve_all(current_files, current_docs)
    old_rows, old_web = resolve_all(baseline_files, baseline_docs)
    old_broken = {
        (r["source"], r["resolved_path"], r["anchor"], r["status"])
        for r in old_rows if r["status"] != "resolved"
    }
    old_external_targets = {
        r["resolved_path"] for r in old_rows if r["status"] == "repository_external"}
    old_broken_targets = {
        (r["resolved_path"], r["anchor"], r["status"])
        for r in old_rows if r["status"] in {"missing_file", "missing_anchor"}
    }
    counts = Counter()
    issues = []
    for row in current_rows:
        status = row["status"]
        if status == "resolved":
            counts["resolved"] += 1
            continue
        if status == "repository_external":
            category = (
                "baseline_repository_external" if row["resolved_path"] in old_external_targets
                else "repository_external_new_reference")
        elif row["resolved_path"] in pending and status == "missing_file":
            category = "pending_deliverable"
        elif (row["source"], row["resolved_path"], row["anchor"], status) in old_broken:
            category = "baseline_" + status
        else:
            category = "new_" + status
        row["category"] = category
        row["target_already_broken_in_baseline"] = (
            row["resolved_path"], row["anchor"], status) in old_broken_targets
        counts[category] += 1
        issues.append(row)
    new_broken = [r for r in issues if r["category"] in {"new_missing_file", "new_missing_anchor"}]
    report = {
        "generated_utc": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "scope": "All Markdown documents under docs; referenced local files of any type, manual HTML IDs/names and GFM-style heading anchors. Does not query external websites or validate PDF/XLSX embedded links.",
        "method": "Standard-library scanner excludes fenced/indented code, inline-code spans and HTML comments; resolves inline, defined reference/shortcut and HTML href/src links. Heading slugs remove markup/punctuation and apply duplicate suffixes.",
        "reproduce": "python3 patterns/tools/audit_doc_links.py --baseline /path/to/upload/docs.tar.gz --check-new",
        "baseline": {
            "archive": str(baseline.resolve()),
            "archive_sha256": hashlib.sha256(baseline.read_bytes()).hexdigest(),
            "file_count": len(baseline_files),
            "markdown_files": len(baseline_docs),
            "local_link_occurrences": len(old_rows),
            "external_urls_skipped": old_web,
            "unresolved_by_kind": dict(Counter(r["status"] for r in old_rows if r["status"] != "resolved")),
        },
        "current": {
            "root": str(root),
            "file_count": len(current_files),
            "markdown_files": len(current_docs),
            "local_link_occurrences": len(current_rows),
            "external_urls_skipped": current_web,
        },
        "pending_paths": sorted(pending),
        "anchor_index": {
            name: {
                "source_sha256": hashlib.sha256(text.encode("utf-8")).hexdigest(),
                **anchor_inventory(text),
            }
            for name, text in sorted(current_docs.items())
        },
        "summary": dict(counts),
        "new_broken_count": len(new_broken),
        "new_broken": new_broken,
        "issues": issues,
        "scanner_self_checks": tests,
        "runtime_language_execution": False,
    }
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({
        "markdown_files": len(current_docs), "local_links": len(current_rows),
        "summary": dict(counts), "new_broken_count": len(new_broken),
        "report": str(output),
    }, ensure_ascii=False))
    return int(args.check_new and bool(new_broken))


if __name__ == "__main__":
    raise SystemExit(main())

