#!/usr/bin/env python3
"""Check the integrated documentation and source listings without running LMX.

Optionally compare foreign-language source files with the supplied input archive.
This checker is not the LMX parser or an execution conformance test.
"""
from __future__ import annotations

import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import tarfile


OLD_NAMES = (
    "bindResult", "flatMap", "signatureTypes", "intercalate", "repeatText",
    "compareText", "formatInt", "parseInt", "charRange", "anyChar",
    "textStart", "textEnd", "matchedText", "captureText", "captureTexts",
)
OLD_WORD = re.compile(r"(?<![A-Za-z0-9_])(" + "|".join(OLD_NAMES) + r")(?![A-Za-z0-9_])")
OLD_PATTERN = re.compile(r"\bRxSequence\\+sequence\b|(?m:^\s+@:\s+sequence\s+\S)|\bsequence\s*\(")
OLD_BOTH = re.compile(r"(?m:^\s*both\s*:)|\\both\b|\bboth\s*\(")
TASK_REFERENCE = re.compile(r"(?:TZ_[A-Za-z0-9_]+\.md|next_core_tasks_v\d+\.md|(?<![A-Za-z0-9_])(?:\.\./)*tasks/)")
FENCE = re.compile(r"^ {0,3}(`{3,}|~{3,})(.*)$")
FOREIGN = {".go", ".java", ".cs", ".jl", ".pl", ".erl", ".lisp", ".rs", ".ts", ".hs", ".scala", ".pm"}


def code_blocks(text):
    opened = None
    lines = []
    for number, line in enumerate(text.splitlines(), 1):
        match = FENCE.match(line)
        if opened is None:
            if match and not (match[1][0] == "`" and "`" in match[2]):
                opened = (match[1][0], len(match[1]), match[2].strip().split(" ")[0].lower(), number)
                lines = []
        elif match and match[1][0] == opened[0] and len(match[1]) >= opened[1] and not match[2].strip():
            yield opened[2], opened[3], "\n".join(lines)
            opened = None
        else:
            lines.append(line)
    if opened:
        raise ValueError(f"unclosed fence at line {opened[3]}")


def json_listings(value, location="$", language=None):
    if isinstance(value, dict):
        own_language = value.get("language", value.get("lang", language))
        for key, child in value.items():
            child_location = location + "." + str(key)
            if isinstance(child, str):
                if key in {"code", "source", "listing"} and str(own_language).lower() in {"lmx", "lm3"}:
                    yield child_location, child
                elif str(key).lower() in {"lmx", "lm3"} and "\n" in child:
                    yield child_location, child
            elif isinstance(child, (dict, list)):
                nested_language = "LMX" if str(key).lower() in {"lmx", "lm3", "lmx_variants"} else own_language
                yield from json_listings(child, child_location, nested_language)
    elif isinstance(value, list):
        for i, child in enumerate(value):
            yield from json_listings(child, f"{location}[{i}]", language)


def without_comments(code):
    # Retain generated-source strings and exact names; ignore whole-line comments.
    return "\n".join(line for line in code.splitlines() if not line.lstrip().startswith("#"))


def foreign_source(path):
    return path.suffix in FOREIGN or (path.suffix == ".py" and any(
        segment in path.as_posix() for segment in ("/examples/python/", "/source/python/")
    ))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--baseline-archive", type=Path)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    root = args.root.resolve()
    errors = []
    counts = Counter()

    def issue(kind, path, details):
        errors.append({"check": kind, "path": str(path), "details": details})

    def inspect_lmx(code, path, location):
        counts["lmx_listings"] += 1
        code = without_comments(code)
        matches = sorted(set(OLD_WORD.findall(code)))
        if OLD_PATTERN.search(code):
            matches.append("Pattern sequence")
        if OLD_BOTH.search(code):
            matches.append("predicate both")
        if matches:
            issue("retired_callable_names", path, {"location": location, "names": matches})

    for path in sorted(root.rglob("*")):
        if not path.is_file() or "__pycache__" in path.parts:
            continue
        relative = path.relative_to(root).as_posix()
        if path.suffix not in {".md", ".json", ".lmx", ".lm3"}:
            continue
        text = path.read_text(encoding="utf-8")
        counts[path.suffix[1:] + "_files"] += 1
        if path.suffix in {".md", ".json", ".lmx", ".lm3"}:
            links = sorted(set(TASK_REFERENCE.findall(text)))
            if links:
                issue("external_assignment_reference", relative, links)
        if path.suffix == ".md":
            try:
                for language, line, code in code_blocks(text):
                    if language in {"lmx", "lm3", "lingvamyxa"}:
                        inspect_lmx(code, relative, "line " + str(line))
            except ValueError as error:
                issue("markdown_fence", relative, str(error))
        elif path.suffix in {".lmx", ".lm3"}:
            inspect_lmx(text, relative, "file")
        elif path.suffix == ".json":
            try:
                value = json.loads(text)
            except ValueError as error:
                issue("json_syntax", relative, str(error))
            else:
                for location, code in json_listings(value):
                    inspect_lmx(code, relative, location)

    library = root / "patterns/LMX_Fn_Receivers"
    sources = list((library / "src").rglob("*.lmx"))
    full_source = "\n".join(path.read_text() for path in sources)
    for name in ("FxValueSame", "FxSequenceDifference", "FxEqualFields", "FxUnique"):
        amount = len(re.findall(r"(?m)^" + name + r":\s*$", full_source))
        if amount != 1:
            issue("single_shared_definition", "patterns/LMX_Fn_Receivers/src", {"name": name, "count": amount})
    equal = re.search(r"(?ms)^FxEqualFields:\n(.*?)(?=^[A-Za-z][A-Za-z0-9_]*:|\Z)", full_source)
    if not equal or "FxSequenceDifference\\find" not in equal[1] or re.search(r"(?m)^\s+while:", equal[1]):
        issue("shared_equality_walk", "patterns/LMX_Fn_Receivers/src", "equalFields must delegate to the one range-comparison walk")

    foreign_checked = 0
    foreign_reviewed = 0
    baseline = None
    revision_path = root / 'patterns/validation/source_revision_20261124.json'
    revision = json.loads(revision_path.read_text()) if revision_path.is_file() else {}
    reviewed_foreign = {'patterns/'+row['path']:row for row in revision.get('foreign_changes',[])}
    if args.baseline_archive:
        baseline = {"file": args.baseline_archive.name, "sha256": hashlib.sha256(args.baseline_archive.read_bytes()).hexdigest()}
        with tarfile.open(args.baseline_archive) as archive:
            for member in archive.getmembers():
                if not member.isfile() or not member.name.startswith("spec/"):
                    continue
                relative = Path(member.name).relative_to("spec")
                if not foreign_source(relative):
                    continue
                foreign_checked += 1
                current = root / relative
                before = archive.extractfile(member).read()
                if not current.is_file() or current.read_bytes() != before:
                    review = reviewed_foreign.get(relative.as_posix(), {})
                    if (current.is_file() and relative.as_posix() in {
                        'patterns/09_functional_computation/examples/haskell/085_currying.hs',
                        'patterns/09_functional_computation/examples/scala/085_currying.scala'}
                        and hashlib.sha256(before).hexdigest() == review.get('before_sha256')
                        and hashlib.sha256(current.read_bytes()).hexdigest() == review.get('after_sha256')):
                        foreign_reviewed += 1
                    else:
                        issue("foreign_source_changed", relative, "Change is not covered by the exact reviewed source hashes")

    counts["foreign_sources_compared"] = foreign_checked
    counts["foreign_sources_reviewed_shortening"] = foreign_reviewed
    report = {
        "scope": "documentation, source names, shared definitions and preserved or explicitly reviewed comparison-language sources",
        "baseline": baseline,
        "checks": dict(counts),
        "errors": errors,
        "status": "PASS" if not errors else "FAIL",
        "lmx_parser_execution": "NOT_RUN",
        "lmx_runtime_execution": "NOT_RUN",
    }
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps({"status": report["status"], "checks": report["checks"], "error_count": len(errors)}, ensure_ascii=False))
    return bool(errors)


if __name__ == "__main__":
    raise SystemExit(main())
