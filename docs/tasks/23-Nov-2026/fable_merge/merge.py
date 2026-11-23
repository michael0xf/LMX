#!/usr/bin/env python3
"""Review/apply this packet against a spec directory, preserving concurrent edits.

No changes are made without --apply.  For changed text, --merge uses Git's normal
three-way merge.  A conflict anywhere prevents the entire apply operation.
Python 3.9+; Git is needed only for --merge and conflict previews.
"""
from __future__ import annotations

import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import shutil
import subprocess
import sys
import tarfile
import tempfile


def digest(value):
    return None if value is None else hashlib.sha256(value).hexdigest()


def path_at(root, relative):
    p = PurePosixPath(relative)
    if p.is_absolute() or not p.parts or any(x in ("..", ".") for x in p.parts):
        raise ValueError("Unsafe relative path: " + relative)
    result = root.joinpath(*p.parts)
    # Do not follow a link into a different project, even when its bytes match.
    if any(x.is_symlink() for x in [result, *result.parents] if x != root.parent):
        raise ValueError("Symlink in target path: " + str(result))
    if not result.resolve().is_relative_to(root.resolve()):
        raise ValueError("Path escapes target: " + relative)
    return result


def read_optional(path):
    if not path.exists():
        return None
    if not path.is_file():
        raise ValueError("Expected a file: " + str(path))
    return path.read_bytes()


def is_text(data):
    if data is None or b"\0" in data:
        return False
    try:
        data.decode("utf-8")
        return True
    except UnicodeDecodeError:
        return False


def merge_text(local, base, updated):
    with tempfile.TemporaryDirectory(prefix="fable-three-way-") as td:
        paths = [Path(td) / name for name in ("local", "base", "updated")]
        for path, content in zip(paths, (local, base, updated)):
            path.write_bytes(content)
        result = subprocess.run(
            ["git", "merge-file", "--diff3", "-p", "-L", "YOUR_WORK", "-L",
             "UPLOADED_BASE", "-L", "THIS_EDITION", *map(str, paths)],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
        if result.returncode < 0 or result.returncode > 127:
            raise RuntimeError(result.stderr.decode(errors="replace"))
        return result.returncode == 0, result.stdout


def plan(packet, target, allow_merge=False, review=None, include_generated=False):
    metadata = json.loads((packet / "changes.json").read_text(encoding="utf-8"))
    if metadata.get("format") != 1:
        raise ValueError("Unsupported changes.json format")
    new_root = packet.parent / "spec"
    previous = {}
    with tarfile.open(packet / "base-files.tar.gz", "r:gz") as archive:
        for member in archive.getmembers():
            if not member.isfile():
                raise ValueError("Unexpected baseline archive member: " + member.name)
            path_at(Path("/baseline"), member.name)
            previous[member.name] = archive.extractfile(member).read()
    rows, changes = [], []
    for entry in metadata["changes"]:
        relative = entry["path"]
        if entry["category"] == "generated" and not include_generated:
            rows.append({"path": relative, "state": "generatedSkipped"})
            continue
        dest = path_at(target, relative)
        current = read_optional(dest)
        before = previous.get(relative)
        after = read_optional(path_at(new_root, relative)) if entry["after"] else None
        if digest(before) != entry["before"] or digest(after) != entry["after"]:
            raise ValueError("Packet checksum mismatch: " + relative)
        current_hash = digest(current)
        row = {"path": relative, "state": "", "current": current_hash}
        if current_hash == entry["after"]:
            row["state"] = "alreadyApplied"
        elif current_hash == entry["before"]:
            row["state"] = "ready"
            changes.append((dest, current, after))
        elif all(is_text(x) for x in (current, before, after)):
            if allow_merge or review:
                clean, merged = merge_text(current, before, after)
                if clean and allow_merge:
                    row["state"] = "merged"
                    changes.append((dest, current, merged))
                else:
                    row["state"] = "mergeAvailable" if clean else "conflict"
                if review is not None:
                    output = path_at(review, relative + ".merge")
                    output.parent.mkdir(parents=True, exist_ok=True)
                    output.write_bytes(merged)
            else:
                row["state"] = "localChanges"
        else:
            row["state"] = "conflict"
        rows.append(row)
    return metadata, rows, changes


def apply_all(target, changes, backup):
    # Recheck the complete plan before any mutation; detect edits since planning.
    for dest, before, _ in changes:
        if read_optional(dest) != before:
            raise RuntimeError("Target changed during review: " + str(dest))
    backup.mkdir(parents=True, exist_ok=False)
    record = []
    for dest, before, after in changes:
        relative = dest.relative_to(target).as_posix()
        if before is not None:
            save = path_at(backup, relative)
            save.parent.mkdir(parents=True, exist_ok=True)
            save.write_bytes(before)
        record.append({"path": relative, "before": digest(before), "after": digest(after)})
    (backup / "RESTORE.json").write_text(json.dumps(record, indent=2) + "\n")
    applied = []
    try:
        for dest, before, after in changes:
            if read_optional(dest) != before:
                raise RuntimeError("Target changed during apply: " + str(dest))
            if after is None:
                dest.unlink()
            else:
                dest.parent.mkdir(parents=True, exist_ok=True)
                fd, temp_name = tempfile.mkstemp(prefix="fable-", dir=dest.parent)
                try:
                    with os.fdopen(fd, "wb") as output:
                        output.write(after)
                    if dest.exists():
                        shutil.copymode(dest, temp_name)
                    os.replace(temp_name, dest)
                finally:
                    if os.path.exists(temp_name):
                        os.unlink(temp_name)
            applied.append((dest, before, after))
    except BaseException:
        for dest, before, after in reversed(applied):
            # Never roll back over an external edit made after our own write.
            if read_optional(dest) != after:
                continue
            if before is None:
                dest.unlink()
            else:
                dest.write_bytes(before)
        raise


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("target", type=Path, help="Existing docs/spec directory")
    parser.add_argument("--check", action="store_true", help="Explicit read-only check (default)")
    parser.add_argument("--apply", action="store_true", help="Apply only after all paths pass")
    parser.add_argument("--merge", action="store_true", help="Accept clean Git three-way text merges")
    parser.add_argument("--include-generated", action="store_true", help="Also update PDFs, workbooks and generated mirrors")
    parser.add_argument("--review", type=Path, help="Write .merge previews outside the target")
    parser.add_argument("--report", type=Path, help="Save machine-readable review report")
    parser.add_argument("--backup", type=Path, help="New directory for pre-apply backups")
    args = parser.parse_args()
    if args.check and args.apply:
        parser.error("Choose --check or --apply")
    target = args.target.resolve()
    packet = Path(__file__).resolve().parent
    if not target.is_dir():
        parser.error("Target directory does not exist")
    if target == (packet.parent / "spec").resolve():
        parser.error("Choose your existing working tree, not the delivered spec directory")
    review = args.review.resolve() if args.review else None
    if review and (review.is_relative_to(target) or target.is_relative_to(review)):
        parser.error("Review output must be separate from the target")
    _, rows, changes = plan(packet, target, args.merge, review, args.include_generated)
    blockers = [r for r in rows if r["state"] in {"conflict", "localChanges", "mergeAvailable"}]
    result = {"target": str(target), "apply_requested": args.apply,
              "counts": dict(Counter(r["state"] for r in rows)),
              "applied": False, "files": rows}
    if args.apply and not blockers and changes:
        backup = args.backup.resolve() if args.backup else target.parent / (
            "fable-backup-" + datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ"))
        if backup.is_relative_to(target) or target.is_relative_to(backup):
            parser.error("Backup directory must be separate from the target")
        apply_all(target, changes, backup)
        result.update(applied=True, backup=str(backup))
    if args.report:
        args.report.write_text(json.dumps(result, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(json.dumps({k:v for k,v in result.items() if k != "files"}, indent=2))
    for row in blockers:
        print(row["state"] + ": " + row["path"])
    return 2 if blockers else 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, RuntimeError, OSError, tarfile.TarError) as error:
        print("No unreviewed overwrite: " + str(error), file=sys.stderr)
        sys.exit(3)
