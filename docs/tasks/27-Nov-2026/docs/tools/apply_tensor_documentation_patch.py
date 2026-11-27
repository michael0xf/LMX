#!/usr/bin/env python3
"""Apply the 27-Nov documentation delta after checking every affected file.

Unpack the patch, then run this file with --target pointing at the directory
containing the destination docs/. --check validates without writing anything.
Unlisted destination files are preserved. Already applied files are accepted.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import shutil

MANIFEST = 'docs/TENSOR_PATCH_MANIFEST_2026-11-27.json'


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def local_path(root: Path, name: str) -> Path:
    relative = PurePosixPath(name)
    if relative.is_absolute() or not relative.parts or '..' in relative.parts:
        raise ValueError(f'Invalid relative path: {name}')
    result = root.joinpath(*relative.parts)
    if not result.resolve().is_relative_to(root.resolve()):
        raise ValueError(f'Path leaves the selected directory: {name}')
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--target', required=True, type=Path)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    source_root = Path(__file__).resolve().parents[2]
    target_root = args.target.resolve()
    manifest_path = source_root / MANIFEST
    manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
    if manifest.get('schema') != 'lmx-documentation-delta-v1':
        raise ValueError('Unsupported manifest schema')
    if not (target_root / 'docs').is_dir():
        raise ValueError('Target must contain the existing docs directory')

    errors, copies, removals = [], [], []
    already_applied = 0
    for item in manifest['files']:
        name = item['path']
        source, target = local_path(source_root, name), local_path(target_root, name)
        if not source.is_file() or digest(source) != item['after_sha256']:
            errors.append(f'Patch payload differs from its manifest: {name}')
            continue
        if target.exists() and not target.is_file():
            errors.append(f'Destination is not a file: {name}')
            continue
        current = digest(target) if target.is_file() else None
        if current == item['after_sha256']:
            already_applied += 1
        elif current == item['before_sha256']:
            copies.append((source, target))
        else:
            errors.append(f'Destination differs from the baseline and the patch: {name}')

    for item in manifest['deleted']:
        target = local_path(target_root, item['path'])
        if not target.exists():
            continue
        if not target.is_file() or digest(target) != item['before_sha256']:
            errors.append(f'Obsolete file has local changes: {item["path"]}')
        else:
            removals.append(target)

    target_manifest = local_path(target_root, MANIFEST)
    if target_manifest.exists() and (
        not target_manifest.is_file() or digest(target_manifest) != digest(manifest_path)
    ):
        errors.append('Destination already has a different patch manifest')
    if errors:
        print(json.dumps({'status': 'CONFLICT', 'errors': errors}, ensure_ascii=False, indent=2))
        return 1
    if not args.check:
        for source, target in copies:
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source, target)
        for target in removals:
            target.unlink()
        if not target_manifest.exists():
            target_manifest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(manifest_path, target_manifest)
    print(json.dumps({
        'status': 'CHECKED' if args.check else 'APPLIED',
        'files_to_copy' if args.check else 'copied_files': len(copies),
        'files_to_remove' if args.check else 'removed_files': len(removals),
        'already_applied_files': already_applied,
        'baseline_archive': manifest['baseline']['file'],
    }, ensure_ascii=False))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
