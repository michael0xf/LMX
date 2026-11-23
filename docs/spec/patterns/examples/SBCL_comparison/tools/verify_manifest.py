#!/usr/bin/env python3
"""Verify package hashes; optionally compare the external spec without writing."""
from pathlib import Path
import argparse
import hashlib
import json

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--spec-root', type=Path)
    args = parser.parse_args()
    errors = []
    lines = (ROOT / 'MANIFEST.sha256').read_text().splitlines()
    for line in lines:
        wanted, name = line.split('  ', 1)
        file = ROOT / name
        if not file.is_file() or hashlib.sha256(file.read_bytes()).hexdigest() != wanted:
            errors.append(name)
    if args.spec_root:
        for item in json.loads((ROOT / 'BASE_REFERENCES.json').read_text())['files']:
            file = args.spec_root / item['path_relative_to_spec']
            if not file.is_file() or hashlib.sha256(file.read_bytes()).hexdigest() != item['sha256']:
                errors.append('spec/' + item['path_relative_to_spec'])
    print(json.dumps({'status': 'PASS' if not errors else 'FAIL', 'package_files': len(lines), 'mismatches': errors}, ensure_ascii=False))
    return int(bool(errors))


if __name__ == '__main__':
    raise SystemExit(main())
