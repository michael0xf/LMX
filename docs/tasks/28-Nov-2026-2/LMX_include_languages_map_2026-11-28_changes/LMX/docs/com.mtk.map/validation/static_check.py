#!/usr/bin/env python3
"""Limited draft consistency checks; never a substitute for the LMX parser."""
from __future__ import annotations
import hashlib
import json
import re
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import unquote

BASE = Path(__file__).resolve().parents[1]
errors: list[str] = []
sources = sorted(p for folder in ("src", "p0", "examples")
                 for p in (BASE / folder).glob("*.lmx"))

def check(ok: bool, problem: str) -> None:
    if not ok:
        errors.append(problem)

def mask(text: str, name: str) -> str:
    result: list[str] = []
    quote = None
    escape = False
    comment = False
    for c in text:
        if comment:
            if c == "\n":
                comment = False
            result.append("\n" if c == "\n" else " ")
        elif quote:
            result.append("\n" if c == "\n" else " ")
            if escape:
                escape = False
            elif c == "\\":
                escape = True
            elif c == quote:
                quote = None
        elif c == "#":
            comment = True
            result.append(" ")
        elif c in "\"'`":
            quote = c
            result.append(" ")
        else:
            result.append(c)
    check(quote is None, f"{name}: unfinished literal in limited lexical check")
    return "".join(result)

def terminal(s: str) -> bool:
    return bool(re.match(r"^(?:return|throw|break|continue)(?:\s|:|$)", s))

definitions: dict[str, tuple[str, set[str]]] = {}
masked = {}
hashes = {}
for path in sources:
    name = path.relative_to(BASE).as_posix()
    text = path.read_text()
    hashes[name] = hashlib.sha256(path.read_bytes()).hexdigest()
    code = mask(text, name)
    masked[path] = code
    check("\t" not in text, f"{name}: tab indentation")
    lines = text.splitlines()
    previous = None
    previous_text = ""
    for number, line in enumerate(lines, 1):
        stripped = line.strip()
        if not stripped:
            next_code = next((s for s in lines[number:]
                              if s.strip() and not s.lstrip().startswith("#")), "")
            check(not next_code.startswith(" "),
                  f"{name}:{number}: blank line closes a continuing nested block")
            previous = None
            continue
        if stripped.startswith("#"):
            continue
        indent = len(line) - len(line.lstrip())
        check(indent % 4 == 0, f"{name}:{number}: non-four-space indentation")
        if previous is not None and previous > indent + 4:
            check(stripped.startswith(("---", "end:"))
                  or terminal(stripped) or terminal(previous_text),
                  f"{name}:{number}: multi-level dedent needs an explicit cutter")
        previous, previous_text = indent, stripped
    stack = []
    for c in code:
        if c in "([{":
            stack.append(c)
        elif c in ")]}":
            check(bool(stack) and stack[-1] == {")": "(", "]": "[", "}": "{"}[c],
                  f"{name}: unmatched delimiter {c}")
            if stack:
                stack.pop()
    check(not stack, f"{name}: unfinished delimiters {stack}")
    check(not re.search(r"\bsynchronized\s*[:(]", code),
          f"{name}: L3 draft uses synchronized")
    current = None
    for line in code.splitlines():
        root = re.match(r"^((?:Map|P0Mix)\w*)\s*:(?::|$)", line)
        if root:
            current = root.group(1)
            check(current not in definitions, f"{name}: duplicate root {current}")
            definitions[current] = (name, set())
        elif line and not line.startswith(" "):
            current = None
        elif current:
            child = re.match(r"^    (?:[^\s:]+:\s+)?([A-Za-z_]\w*)(?::|\s|$)", line)
            if child:
                definitions[current][1].add(child.group(1))
    # Qualified immutable sentinel is a value binding rather than a Structure.
    if re.search(r"^const:\s+@:\s+MapNil\b", code, re.M):
        check("MapNil" not in definitions, f"{name}: duplicate MapNil")
        definitions["MapNil"] = (name, set())

allowed_outcomes = {"MapFailure", "P0MixFailure", "P0MixPortFailure"}
for path, code in masked.items():
    name = path.relative_to(BASE).as_posix()
    unknown = set(re.findall(r"\b(?:Map|P0Mix)[A-Za-z0-9_]*\b", code)) - set(definitions) - allowed_outcomes
    check(not unknown, f"{name}: undefined project names {sorted(unknown)}")
    for owner, field in set(re.findall(r"\b((?:Map|P0Mix)\w*)\\([A-Za-z_]\w*)", code)):
        if owner in definitions:
            check(field in definitions[owner][1],
                  f"{name}: unresolved first path step {owner}\\{field}")

links = 0
for path in sorted(BASE.rglob("*.md")):
    if "java_original" in path.parts:
        continue
    for link in re.findall(r"\[[^\]]*\]\(([^)]+)\)", path.read_text()):
        if re.match(r"^[a-zA-Z][a-zA-Z0-9+.-]*:", link) or link.startswith("#"):
            continue
        relative = unquote(link.split("#", 1)[0].split("?", 1)[0])
        if relative:
            links += 1
            check((path.parent / relative).exists(),
                  f"{path.relative_to(BASE)}: missing local link {relative}")

manifest_path = BASE / "validation/java_original_manifest.json"
retained_count = 0
if manifest_path.exists():
    manifest = json.loads(manifest_path.read_text())
    expected = {row["path"] for row in manifest["files"]}
    actual = {p.relative_to(BASE / "java_original").as_posix()
              for p in (BASE / "java_original").rglob("*") if p.is_file()}
    check(expected == actual, "retained Java tree differs from original inventory")
    for row in manifest["files"]:
        path = BASE / "java_original" / row["path"]
        check(path.exists() and hashlib.sha256(path.read_bytes()).hexdigest() == row["sha256"],
              f"retained Java changed: {row['path']}")
        retained_count += 1
else:
    errors.append("missing original Java preservation manifest")

report = {
    "generated_utc": datetime.now(timezone.utc).isoformat(),
    "status": "STATIC_CHECKS_PASS" if not errors else "STATIC_CHECKS_FAIL",
    "scope": "text, references, first path steps, limited delimiters/indentation, links and original-byte preservation",
    "lmx_files": len(sources), "project_definitions": len(definitions),
    "local_links_checked": links, "original_files_verified": retained_count,
    "input_sha256": hashes, "errors": errors,
    "not_run": ["production LMX parsing", "LMX TYPE/effect admission",
                "LMX interpretation/native execution", "native incremental P0 integration"],
}
(BASE / "validation/static_report.json").write_text(
    json.dumps(report, ensure_ascii=False, indent=2) + "\n")
print(json.dumps({k: report[k] for k in ("status", "lmx_files",
                 "project_definitions", "local_links_checked",
                 "original_files_verified", "errors")}, ensure_ascii=False, indent=2))
raise SystemExit(bool(errors))
