#!/usr/bin/env python3
"""Apply this verified LMX delta; default is a read-only preflight."""
from __future__ import annotations
import argparse
import hashlib
import json
import os
import shutil
import tempfile
from datetime import datetime, timezone
from pathlib import Path, PurePosixPath

def digest(path):
    if not path.exists():
        return None
    if not path.is_file() or path.is_symlink():
        raise ValueError(f"Expected a regular file: {path}")
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()

def safe_path(base, relative):
    parts = PurePosixPath(relative)
    if parts.is_absolute() or not parts.parts or any(p in (".", "..") for p in parts.parts):
        raise ValueError(f"Unsafe relative path: {relative}")
    result = base.joinpath(*parts.parts)
    if not result.resolve().is_relative_to(base):
        raise ValueError(f"Path escapes target: {relative}")
    current = result
    while current != base:
        if current.is_symlink():
            raise ValueError(f"Symlink is outside the update contract: {current}")
        current = current.parent
    return result

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--target", required=True, type=Path, help="Existing LMX project directory")
    parser.add_argument("--apply", action="store_true", help="Apply after full preflight; keep backups")
    args = parser.parse_args()
    package = Path(__file__).resolve().parent
    target = args.target.resolve(strict=True)
    if not target.is_dir():
        raise ValueError("Target must be an existing project directory")
    manifest = json.loads((package / "LMX_CHANGESET_2026-11-28.json").read_text(encoding="utf-8"))
    if manifest["format"] != "lmx.source-delta.v1":
        raise ValueError("Unexpected manifest format")
    payload = (package / "LMX").resolve(strict=True)
    actions = []
    conflicts = []
    seen = set()
    for row in manifest["changes"]:
        relative = row["path"]
        if relative in seen:
            raise ValueError(f"Duplicate change: {relative}")
        seen.add(relative)
        destination = safe_path(target, relative)
        old, new = row["before_sha256"], row["after_sha256"]
        if new is not None:
            source = safe_path(payload, relative)
            if digest(source) != new:
                raise ValueError(f"Payload checksum mismatch: {relative}")
        current = digest(destination)
        if current == new:
            continue
        if current != old:
            conflicts.append(relative)
        else:
            actions.append((row, destination))
    if conflicts:
        raise ValueError("Locally changed files; nothing written:\n" + "\n".join(conflicts))
    print(json.dumps({"preflight": "PASS", "pending_changes": len(actions),
                      "already_applied": len(manifest["changes"]) - len(actions),
                      "apply": args.apply}, ensure_ascii=False))
    if not args.apply or not actions:
        return
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    backup = Path(tempfile.mkdtemp(prefix=f"LMX-before-{stamp}-", dir=target.parent))
    # Finish all backups before the first target mutation.
    for row, destination in actions:
        if row["before_sha256"] is not None:
            saved = backup / row["path"]
            saved.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(destination, saved)
            if digest(saved) != row["before_sha256"]:
                raise ValueError(f"Source changed during backup: {row['path']}")
    for row, destination in actions:
        if digest(destination) != row["before_sha256"]:
            raise ValueError(f"Concurrent change detected; backups at {backup}: {row['path']}")
        if row["after_sha256"] is None:
            destination.unlink()
        else:
            source = safe_path(payload, row["path"])
            destination.parent.mkdir(parents=True, exist_ok=True)
            fd, temporary = tempfile.mkstemp(prefix=".lmx-update-", dir=destination.parent)
            os.close(fd)
            temporary = Path(temporary)
            try:
                shutil.copy2(source, temporary)
                if digest(temporary) != row["after_sha256"]:
                    raise ValueError(f"Staged checksum mismatch: {row['path']}")
                os.replace(temporary, destination)
            finally:
                temporary.unlink(missing_ok=True)
    for row, destination in actions:
        if row["after_sha256"] is None:
            parent = destination.parent
            while parent != target:
                try:
                    parent.rmdir()
                except OSError:
                    break
                parent = parent.parent
    for row in manifest["changes"]:
        if digest(safe_path(target, row["path"])) != row["after_sha256"]:
            raise ValueError(f"Post-update mismatch; backups at {backup}: {row['path']}")
    print(json.dumps({"status": "APPLIED", "backup": str(backup),
                      "changed": len(actions)}, ensure_ascii=False))

if __name__ == "__main__":
    main()
