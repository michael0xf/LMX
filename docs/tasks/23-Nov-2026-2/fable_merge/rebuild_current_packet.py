#!/usr/bin/env python3
"""Prepare the exact original base; build/validate a direct packet only with --build.

Original uploads and --updated are read-only. A build uses disposable copies,
verifies the two application routes, then replaces --output while preserving
its former contents in --work. No existing user project receives --apply.
"""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import importlib.util
import json
from pathlib import Path, PurePosixPath
import shutil
import subprocess
import sys
import tarfile
import tempfile
import uuid

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
TOOLS = ('build_fable_patch.py', 'merge.py', 'test_merge.py', 'validate_packet.py')


def digest(value):
    return hashlib.sha256(value).hexdigest()


def load_module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def original_files(archive):
    files, seen = {}, set()
    with tarfile.open(archive, 'r:gz') as package:
        for member in package:
            path = PurePosixPath(member.name)
            if path.is_absolute() or not path.parts or path.parts[0] != 'spec' or '..' in path.parts:
                raise ValueError('Unsafe original archive path: ' + member.name)
            if member.isdir():
                continue
            if not member.isfile() or len(path.parts) < 2 or member.name in seen:
                raise ValueError('Unexpected or duplicate archive member: ' + member.name)
            seen.add(member.name)
            relative = PurePosixPath(*path.parts[1:])
            if relative.name == '.DS_Store' or '__pycache__' in relative.parts or relative.suffix == '.pyc' or '.git' in relative.parts:
                continue
            files[relative.as_posix()] = package.extractfile(member).read()
    return files


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--archive', type=Path, required=True, help='The original uploaded spec.tar.gz, not the 23-Nov delivery')
    parser.add_argument('--work', type=Path, required=True, help='Scratch directory for verified baseline, staging and retained previous packet')
    parser.add_argument('--tools', type=Path, default=HERE, help='Directory containing the four original merge/build tools')
    parser.add_argument('--updated', type=Path, help='Read-only final spec tree; required for --build')
    parser.add_argument('--output', type=Path, help='Final fable_merge directory; required for --build')
    parser.add_argument('--build', action='store_true', help='Build and validate after the final source/artifact freeze; default prepares only the base')
    args = parser.parse_args()
    for name in ('archive', 'work', 'tools', 'updated', 'output'):
        value = getattr(args, name)
        if value is not None:
            setattr(args, name, value.resolve())
    if args.build and (args.updated is None or args.output is None):
        parser.error('--build requires --updated and --output')
    if args.updated and (args.work.is_relative_to(args.updated) or args.updated.is_relative_to(args.work)):
        parser.error('Scratch work and read-only updated spec must be separate trees')
    if args.output and args.updated and (args.output.is_relative_to(args.updated) or args.updated.is_relative_to(args.output)):
        parser.error('Output packet and updated spec must be separate trees')
    if args.output and (args.output == args.work or args.work.is_relative_to(args.output)):
        parser.error('Output packet cannot contain its scratch work directory')
    provenance = json.loads((HERE / 'BASELINE_PROVENANCE.json').read_text())
    expected = provenance['original_archive']
    actual_archive = args.archive.read_bytes()
    if len(actual_archive) != expected['bytes'] or digest(actual_archive) != expected['sha256']:
        raise ValueError('Original archive identity does not match verified provenance')
    for name in TOOLS:
        expected_hash = provenance['historical_packet_checks']['hashes'][name]
        if digest((args.tools / name).read_bytes()) != expected_hash:
            raise ValueError('Reviewed merge tool differs: ' + name)
    builder = load_module('packet_builder', args.tools / 'build_fable_patch.py')
    validator = load_module('packet_validator', args.tools / 'validate_packet.py')
    base = original_files(args.archive)
    if validator.describe(base) != provenance['baseline_tree']:
        raise ValueError('Original archive inventory differs from verified baseline')
    args.work.mkdir(parents=True, exist_ok=True)
    baseline = args.work / 'original-spec'
    if baseline.exists():
        if builder.inventory(baseline) != base:
            raise ValueError('Existing extracted baseline differs; use a new --work directory')
    else:
        validator.copy_inventory(base, baseline)
    receipt = {'status': 'BASE_PREPARED', 'baseline': str(baseline),
               'baseline_tree': validator.describe(base), 'archive_sha256': expected['sha256'],
               'current_packet_build': 'NOT_RUN'}
    (args.work / 'PREPARATION.json').write_text(json.dumps(receipt, indent=2) + '\n')
    if not args.build:
        print(json.dumps(receipt, indent=2))
        return
    if not args.updated.is_dir():
        raise ValueError('Updated spec does not exist')
    if args.output.exists() and (not args.output.is_dir() or args.output.is_symlink()):
        raise ValueError('Output must be a real packet directory or a new path')
    for path in args.updated.rglob('*'):
        if path.is_symlink():
            raise ValueError('Symlink in updated tree: ' + str(path))
    current = builder.inventory(args.updated)
    with tempfile.TemporaryDirectory(prefix='validated-current-', dir=args.work) as temporary:
        stage = Path(temporary)
        delivered = stage / 'spec'
        packet = stage / 'fable_merge'
        validator.copy_inventory(current, delivered)
        packet.mkdir()
        for name in TOOLS:
            shutil.copy2(args.tools / name, packet / name)
        for name in ('BASELINE_PROVENANCE.json', 'rebuild_current_packet.py'):
            shutil.copy2(HERE / name, packet / name)
        readme = HERE / 'README.current.md'
        shutil.copy2(readme if readme.exists() else HERE / 'README.md', packet / 'README.md')
        builder.build(baseline, delivered, packet, args.archive)
        build_provenance = {'status': 'BUILT_DIRECT_FROM_ORIGINAL',
            'original_archive': expected, 'baseline': validator.describe(base),
            'updated': validator.describe(current), 'previous_packet_applied_first': False,
            'basis': 'BASELINE_PROVENANCE.json',
            'scope': 'Exact file delivery; no claim of LMX runtime execution',
            'tools_sha256': {name: digest((packet / name).read_bytes()) for name in TOOLS}}
        (packet / 'BUILD_PROVENANCE.json').write_text(json.dumps(build_provenance, indent=2) + '\n')
        subprocess.run([sys.executable, '-B', str(packet / 'validate_packet.py'),
                        '--baseline', str(baseline), '--packet', str(packet),
                        '--expected', str(delivered)], check=True)
        validated = json.loads((packet / 'VALIDATION.json').read_text())
        if validated['status'] != 'PASS':
            raise ValueError('Staged packet validation failed')
        if builder.inventory(args.updated) != current or builder.inventory(baseline) != base:
            raise ValueError('Read-only input changed while building; do not publish this staged packet')
        if digest(args.archive.read_bytes()) != expected['sha256']:
            raise ValueError('Original archive changed while building')
        backup = None
        if args.output.exists():
            stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')
            backup = args.work / ('previous-packet-' + stamp + '-' + uuid.uuid4().hex[:8])
            shutil.move(str(args.output), str(backup))
        try:
            args.output.parent.mkdir(parents=True, exist_ok=True)
            shutil.move(str(packet), str(args.output))
        except BaseException:
            if backup is not None and not args.output.exists():
                shutil.move(str(backup), str(args.output))
            raise
    receipt.update(status='PASS', current_packet_build='PASS', output=str(args.output),
                   previous_packet_backup=str(backup) if backup else None,
                   updated_tree=validator.describe(current),
                   validation_checks=validated['check_counts'])
    (args.work / 'BUILD.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print(json.dumps(receipt, indent=2))


if __name__ == '__main__':
    main()
