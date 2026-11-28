#!/usr/bin/env python3
"""Limited artifact consistency checks. NOT a LMX parser or runtime."""
from __future__ import annotations

import hashlib
import json
import re
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import unquote

BASE = Path(__file__).resolve().parents[1]
PLATFORMS = ("windows", "linux_ubuntu", "macos", "android_ndk",
             "mir", "wasm_linear", "riscv", "c99_other")
GATES = {
    "py.install": "install", "py.open": "open", "py.close": "close",
    "py.import": "importModule", "py.getattr": "getAttribute",
    "py.setattr": "setAttribute", "py.call": "call",
    "py.getitem": "getItem", "py.setitem": "setItem",
    "py.retain": "retain", "py.release": "release",
    "py.toValue": "toValue", "py.fromValue": "fromValue",
    "py.buffer": "buffer", "py.releaseBuffer": "releaseBuffer",
}
errors: list[str] = []


def require(condition: bool, message: str) -> None:
    if not condition:
        errors.append(message)


def mask_literals_and_comments(text: str, path: str) -> str:
    """Keep only non-literal code; enough for our limited delimiter checks."""
    output: list[str] = []
    quote = None
    escaped = False
    comment = False
    for char in text:
        if char == "\n":
            comment = False
        if comment:
            output.append(" ")
        elif quote:
            output.append("\n" if char == "\n" else " ")
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == quote:
                quote = None
        elif char == "#":
            comment = True
            output.append(" ")
        elif char in "\"'`":
            quote = char
            output.append(" ")
        else:
            output.append(char)
    require(quote is None, f"{path}: unfinished literal")
    return "".join(output)


sources = sorted((*BASE.glob("src/*.lmx"), *BASE.glob("examples/*.lmx")))
require(len(sources) == 16, f"expected 16 LMX files, got {len(sources)}")
top_names: set[str] = set()
masked: dict[Path, str] = {}
input_hashes = {}
for file in sources:
    relative = str(file.relative_to(BASE))
    content = file.read_text()
    input_hashes[relative] = hashlib.sha256(file.read_bytes()).hexdigest()
    require("\t" not in content, f"{relative}: tab indentation")
    lines = content.splitlines()
    for index, line in enumerate(lines):
        if not line.strip():
            following = next((later for later in lines[index + 1:]
                              if later.strip() and not later.lstrip().startswith("#")), "")
            require(not following.startswith(" "),
                    f"{relative}:{index + 1}: blank resets block before nested continuation")
    code = mask_literals_and_comments(content, relative)
    masked[file] = code
    stack: list[str] = []
    for char in code:
        if char in "([{":
            stack.append(char)
        elif char in ")]}":
            require(bool(stack) and stack[-1] == {")": "(", "]": "[", "}": "{"}[char],
                    f"{relative}: unmatched {char}")
            if stack:
                stack.pop()
    require(not stack, f"{relative}: unfinished delimiter stack {stack}")
    top_names.update(re.findall(r"^(Python[A-Za-z0-9_]*)\s*(?::|::)", code, re.M))
    require(not re.search(r"\bsynchronized\s*:", code),
            f"{relative}: LMX synchronized is outside this design")

# Bare outcome names are declarations of finite throws; never treated as CODE.
declared_outcomes = {"PythonBridgeFailure"}
for file, code in masked.items():
    references = set(re.findall(r"\bPython[A-Za-z0-9_]+\b", code))
    unknown = references - top_names - declared_outcomes
    require(not unknown, f"{file.name}: unknown Python-prefixed names {sorted(unknown)}")

bindings = (BASE / "src/gate_bindings.lmx").read_text()
found = re.findall(r'spelling "(py\.[A-Za-z]+)"; @: code PythonGate\\([A-Za-z]+)\\run',
                   bindings)
require(len(found) == 15 and dict(found) == GATES, "finite gate binding mismatch")
gate_source = (BASE / "src/gates.lmx").read_text()
for spelling, implementation in GATES.items():
    require(re.search(r"^    " + implementation + r":\n(?:(?:[ ]{8}.*|#)\n)*?        run:",
                      gate_source, re.M) is not None,
            f"{spelling}: ordinary LMX CODE body missing")
for file, code in masked.items():
    actual = set(re.findall(r"\bpy\.[A-Za-z]+", code))
    require(actual <= set(GATES), f"{file.name}: undefined py gate {sorted(actual-set(GATES))}")

markdown = [BASE / "README.md", BASE / "SOURCES.md"]
markdown += sorted(BASE.glob("python/*.md"))
markdown += sorted(BASE.glob("examples/*.md"))
markdown += [BASE / "validation/README.md"]
for platform in PLATFORMS:
    for name in ("README.md", "PYTHON.md"):
        file = BASE / "platforms" / platform / name
        require(file.exists(), f"missing separate platform page {platform}/{name}")
        markdown.append(file)
link_count = 0
for file in markdown:
    if not file.exists():
        continue
    text = file.read_text()
    for target in re.findall(r"\[[^\]]*\]\(([^)]+)\)", text):
        if re.match(r"^[a-zA-Z][a-zA-Z0-9+.-]*:", target) or target.startswith("#"):
            continue
        target = unquote(target.split("#", 1)[0].split("?", 1)[0])
        if target:
            link_count += 1
            require((file.parent / target).exists(),
                    f"{file.relative_to(BASE)}: missing link {target}")

report = {
    "generated_utc": datetime.now(timezone.utc).isoformat(),
    "scope": "artifact text consistency only; not production LMX parsing",
    "status": "STATIC_CHECKS_PASS" if not errors else "STATIC_CHECKS_FAIL",
    "lmx_files": len(sources),
    "platform_directories": len(PLATFORMS),
    "separate_platform_pages": len(PLATFORMS) * 2,
    "finite_gate_bindings": len(found),
    "local_links_checked": link_count,
    "input_sha256": input_hashes,
    "errors": errors,
    "not_run": ["production LMX P0 parse", "LMX type/effect validation",
                "LMX runtime/native/interpreter execution", "target platform builds",
                "distribution installs", "Python native provider integration",
                "external worker integration"],
    "require_implementation": ["production py.* binding", "PythonNativePort",
                               "PythonInstallerPort", "wire transport/bootstrap"],
}
(BASE / "validation/static_report.json").write_text(
    json.dumps(report, ensure_ascii=False, indent=2) + "\n")
print(json.dumps({key: report[key] for key in ("status", "lmx_files",
      "platform_directories", "finite_gate_bindings", "local_links_checked", "errors")},
      ensure_ascii=False, indent=2))
raise SystemExit(bool(errors))
