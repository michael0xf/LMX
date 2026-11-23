#!/usr/bin/env python3
"""Validate the complete merge packet using disposable baseline copies only.

Python 3.9+ and Git are required. This tool has no user-target/apply argument.
The baseline and delivered spec are read-only inputs. Only temporary copies
and the requested receipt (outside either input tree) can be written.

Example, from the delivered packet root:
    python3 fable_merge/validate_packet.py --baseline /path/to/uploaded/spec
"""
from __future__ import annotations

import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile
import time

sys.dont_write_bytecode = True

EXCLUSIONS = ["any .DS_Store file", "any __pycache__ path component",
              "any .pyc suffix", "any .git path component"]
PACKET_FILES = ["merge.py", "test_merge.py", "build_fable_patch.py",
                "changes.json", "base-files.tar.gz", "source.patch",
                "generated.patch", "validate_packet.py"]


def sha(data):
    return None if data is None else hashlib.sha256(data).hexdigest()


def inventory(root):
    # Deliberately identical inclusion rule to build_fable_patch.inventory.
    return {p.relative_to(root).as_posix(): p.read_bytes()
            for p in root.rglob("*")
            if p.is_file() and p.name != ".DS_Store"
            and "__pycache__" not in p.parts and p.suffix != ".pyc"
            and ".git" not in p.parts}


def describe(tree):
    digest = hashlib.sha256()
    for name, value in sorted(tree.items()):
        encoded = name.encode("utf-8")
        digest.update(len(encoded).to_bytes(8, "big"))
        digest.update(encoded)
        digest.update(len(value).to_bytes(8, "big"))
        digest.update(value)
    return {"files": len(tree), "bytes": sum(map(len, tree.values())),
            "tree_sha256": digest.hexdigest(),
            "tree_digest_encoding": "sorted UTF-8 path length/path/content length/content; uint64 big-endian lengths"}


def differences(actual, expected):
    missing = sorted(expected.keys() - actual.keys())
    extra = sorted(actual.keys() - expected.keys())
    changed = [name for name in sorted(actual.keys() & expected.keys())
               if actual[name] != expected[name]]
    return {"missing": missing, "extra": extra,
            "different_bytes": [{"path": name, "actual_sha256": sha(actual[name]),
                                 "expected_sha256": sha(expected[name]),
                                 "actual_bytes": len(actual[name]),
                                 "expected_bytes": len(expected[name])}
                                for name in changed]}


def copy_inventory(tree, target):
    target.mkdir()
    for name, value in tree.items():
        path = target / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(value)


class ValidationFailure(Exception):
    pass


class Validator:
    def __init__(self, report):
        self.report = report

    def check(self, identifier, condition, **details):
        self.report["checks"].append({"id": identifier,
                                      "status": "PASS" if condition else "FAIL",
                                      **details})
        if not condition:
            raise ValidationFailure(identifier)

    def equal(self, identifier, actual, expected):
        # Equality here compares every byte, rather than only comparing hashes.
        self.check(identifier, actual == expected,
                   actual=describe(actual), expected=describe(expected),
                   differences=differences(actual, expected))

    def command(self, identifier, arguments, cwd):
        started = time.monotonic()
        env = dict(os.environ, PYTHONDONTWRITEBYTECODE="1")
        result = subprocess.run([str(x) for x in arguments], cwd=cwd, env=env,
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                text=True, encoding="utf-8", errors="replace",
                                check=False, timeout=300)
        entry = {"id": identifier, "argv": [str(x) for x in arguments],
                 "cwd": str(cwd), "returncode": result.returncode,
                 "elapsed_seconds": round(time.monotonic() - started, 6),
                 "stdout": result.stdout, "stderr": result.stderr}
        self.report["commands"].append(entry)
        self.check(identifier, result.returncode == 0,
                   returncode=result.returncode)
        return result


def validate(args, report):
    packet, baseline, expected = args.packet, args.baseline, args.expected
    check = Validator(report)
    before_base, before_new = inventory(baseline), inventory(expected)
    before_packet = {name: (packet / name).read_bytes() for name in PACKET_FILES}
    report["inputs"] = {
        "baseline": {"path": str(baseline), **describe(before_base)},
        "expected": {"path": str(expected), **describe(before_new)},
        "packet": {"path": str(packet),
                   "files": {name: {"bytes": len(value), "sha256": sha(value)}
                             for name, value in before_packet.items()}},
    }
    try:
        metadata = json.loads(before_packet["changes.json"])
        report["packet_metadata"] = {key: value for key, value in metadata.items()
                                     if key != "changes"}
        entries = metadata["changes"]
        paths = [entry["path"] for entry in entries]
        actual_changes = {name for name in before_base.keys() | before_new.keys()
                          if before_base.get(name) != before_new.get(name)}
        check.check("manifest_exact_changed_paths",
                    metadata.get("format") == 1 and len(paths) == len(set(paths))
                    and set(paths) == actual_changes,
                    listed=len(paths), actual=len(actual_changes),
                    missing=sorted(actual_changes - set(paths)),
                    unexpected=sorted(set(paths) - actual_changes))
        invalid = []
        for entry in entries:
            name = entry["path"]
            old, new = before_base.get(name), before_new.get(name)
            action = "add" if old is None else "delete" if new is None else "modify"
            if (entry["before"] != sha(old) or entry["after"] != sha(new)
                    or entry["action"] != action
                    or entry["before_bytes"] != (len(old) if old is not None else 0)
                    or entry["after_bytes"] != (len(new) if new is not None else 0)
                    or entry["category"] not in {"source", "generated"}):
                invalid.append(name)
        check.check("manifest_file_hashes_sizes_actions", not invalid,
                    invalid_paths=invalid)
        check.check("manifest_totals",
                    metadata["baseline_files"] == len(before_base)
                    and metadata["updated_files"] == len(before_new)
                    and metadata["counts"] == dict(Counter(x["action"] for x in entries))
                    and metadata["category_counts"] == dict(Counter(x["category"] for x in entries)),
                    baseline_files=len(before_base), updated_files=len(before_new),
                    actions=dict(Counter(x["action"] for x in entries)),
                    categories=dict(Counter(x["category"] for x in entries)))
        archived = {}
        with tarfile.open(packet / "base-files.tar.gz", "r:gz") as archive:
            for member in archive.getmembers():
                if not member.isfile() or member.name in archived:
                    raise ValidationFailure("Unexpected or duplicate baseline archive member: " + member.name)
                archived[member.name] = archive.extractfile(member).read()
        required_old = {name: before_base[name] for name in actual_changes
                        if name in before_base}
        check.equal("base_archive_exact_changed_originals", archived, required_old)

        result = check.command("isolated_merge_unit_tests",
                               [sys.executable, "-B", packet / "test_merge.py"], packet)
        count = re.search(r"Ran (\d+) tests? in", result.stdout + result.stderr)
        check.check("eight_unit_tests_executed", bool(count) and int(count[1]) == 8,
                    tests=int(count[1]) if count else None)
        report["unit_tests_executed"] = int(count[1]) if count else 0

        with tempfile.TemporaryDirectory(prefix="lmx-packet-validation-") as temporary:
            temp = Path(temporary)
            report["temporary_directory"] = {"path_during_run": str(temp),
                                               "removed_on_exit": True}
            merge_target, git_target = temp / "merge-copy", temp / "git-copy"
            copy_inventory(before_base, merge_target)
            check.equal("merge_copy_matches_baseline", inventory(merge_target), before_base)
            merge_args = [sys.executable, "-B", packet / "merge.py", merge_target]
            check.command("merge_check_include_generated",
                          merge_args + ["--check", "--include-generated", "--report", temp / "merge-check.json"], temp)
            reviewed = json.loads((temp / "merge-check.json").read_text(encoding="utf-8"))
            check.check("all_changes_ready", reviewed["counts"] == {"ready": len(entries)}
                        and reviewed["applied"] is False,
                        counts=reviewed["counts"], applied=reviewed["applied"])
            check.equal("merge_check_is_read_only", inventory(merge_target), before_base)
            check.command("merge_apply_include_generated",
                          merge_args + ["--apply", "--include-generated", "--backup", temp / "merge-backup",
                                        "--report", temp / "merge-apply.json"], temp)
            applied = json.loads((temp / "merge-apply.json").read_text(encoding="utf-8"))
            check.check("merge_applied_all_changes", applied["applied"] is bool(entries)
                        and applied["counts"] == {"ready": len(entries)},
                        counts=applied["counts"], applied=applied["applied"])
            check.equal("merge_result_exact_bytes", inventory(merge_target), before_new)
            first_stats = {p.relative_to(merge_target).as_posix():
                           (p.stat().st_mtime_ns, p.stat().st_size)
                           for p in merge_target.rglob("*") if p.is_file()}
            check.command("merge_reapply_include_generated",
                          merge_args + ["--apply", "--include-generated", "--backup", temp / "unused-repeat-backup",
                                        "--report", temp / "merge-repeat.json"], temp)
            repeated = json.loads((temp / "merge-repeat.json").read_text(encoding="utf-8"))
            check.check("merge_reapply_reports_no_mutation",
                        repeated["counts"] == {"alreadyApplied": len(entries)}
                        and repeated["applied"] is False
                        and not (temp / "unused-repeat-backup").exists(),
                        counts=repeated["counts"], applied=repeated["applied"])
            check.equal("merge_reapply_exact_bytes", inventory(merge_target), before_new)
            repeated_stats = {p.relative_to(merge_target).as_posix():
                              (p.stat().st_mtime_ns, p.stat().st_size)
                              for p in merge_target.rglob("*") if p.is_file()}
            check.check("merge_reapply_preserves_file_mtimes", first_stats == repeated_stats)

            copy_inventory(before_base, git_target)
            check.equal("git_copy_matches_baseline", inventory(git_target), before_base)
            check.command("git_initialize_disposable_copy", ["git", "init", "-q"], git_target)
            git = ["git", "-c", "core.autocrlf=false", "-c", "core.quotePath=false", "apply"]
            patches = [packet / "source.patch", packet / "generated.patch"]
            check.command("git_check_source_and_generated", git + ["--check", *patches], git_target)
            check.equal("git_check_is_read_only", inventory(git_target), before_base)
            check.command("git_apply_source_and_generated", git + patches, git_target)
            check.equal("git_result_exact_bytes", inventory(git_target), before_new)
            check.equal("both_application_routes_agree", inventory(git_target), inventory(merge_target))
    finally:
        # These checks also run after a failed command; neither input is a target.
        for identifier, root, original in (
                ("original_baseline_unchanged", baseline, before_base),
                ("delivered_spec_unchanged", expected, before_new)):
            current = inventory(root)
            report["checks"].append({"id": identifier,
                                      "status": "PASS" if current == original else "FAIL",
                                      "actual": describe(current),
                                      "expected": describe(original),
                                      "differences": differences(current, original)})
        after_packet = {name: (packet / name).read_bytes() for name in PACKET_FILES}
        report["checks"].append({"id": "validated_packet_files_unchanged",
                                  "status": "PASS" if after_packet == before_packet else "FAIL",
                                  "differences": differences(after_packet, before_packet)})


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--baseline", type=Path, required=True,
                        help="Read-only extracted original spec directory")
    parser.add_argument("--packet", type=Path, default=Path(__file__).resolve().parent,
                        help="Delivered fable_merge directory (default: this script's directory)")
    parser.add_argument("--expected", type=Path,
                        help="Read-only delivered spec directory (default: ../spec beside packet)")
    parser.add_argument("--report", type=Path,
                        help="Receipt outside both input trees (default: packet/VALIDATION.json)")
    args = parser.parse_args()
    args.packet = args.packet.resolve()
    args.baseline = args.baseline.resolve()
    args.expected = (args.expected or args.packet.parent / "spec").resolve()
    args.report = (args.report or args.packet / "VALIDATION.json").resolve()
    for root in (args.baseline, args.expected):
        if not root.is_dir():
            parser.error("Input directory does not exist: " + str(root))
        if args.report.is_relative_to(root):
            parser.error("Receipt must be outside the read-only input trees")
    if args.baseline == args.expected:
        parser.error("Baseline and expected edition must be different directories")
    if shutil.which("git") is None:
        parser.error("Git is required for the two-patch application and merge unit tests")
    report = {"format": 1, "status": "RUNNING",
              "started_utc": datetime.now(timezone.utc).isoformat(),
              "scope": "Merge/diff infrastructure and exact file reproduction; no LMX or foreign-language semantic runtime tests",
              "safety": "Only disposable copies receive --apply or git apply; input trees are compared before/after",
              "inventory_exclusions": EXCLUSIONS,
              "environment": {"python": platform.python_version(),
                              "platform": platform.platform(),
                              "git": subprocess.run(["git", "--version"], check=True,
                                                    capture_output=True, text=True).stdout.strip()},
              "checks": [], "commands": []}
    try:
        validate(args, report)
    except Exception as error:
        report["error"] = {"type": type(error).__name__, "message": str(error)}
    report["completed_utc"] = datetime.now(timezone.utc).isoformat()
    report["check_counts"] = dict(Counter(x["status"] for x in report["checks"]))
    report["status"] = "PASS" if "error" not in report and not report["check_counts"].get("FAIL", 0) else "FAIL"
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"status": report["status"], "check_counts": report["check_counts"],
                      "report": str(args.report), "error": report.get("error")},
                     ensure_ascii=False, indent=2))
    return 0 if report["status"] == "PASS" else 1


if __name__ == "__main__":
    sys.exit(main())
