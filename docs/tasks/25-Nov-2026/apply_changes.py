#!/usr/bin/env python3
"""Apply this changes-only package after checking all old and new hashes."""
from __future__ import annotations
import argparse
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import tempfile

PACKAGE = Path(__file__).resolve().parent
MANIFEST = 'CHANGES_2026-11-24.json'

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest() if path.is_file() else None

def safe_path(root, name):
    relative = PurePosixPath(name)
    if relative.is_absolute() or not relative.parts or any(p in ('..', '.') for p in relative.parts):
        raise ValueError('Unsafe path in manifest: '+name)
    path = root.joinpath(*relative.parts)
    for candidate in (path, *path.parents):
        if candidate==root: break
        if candidate.is_symlink(): raise ValueError('Symlink in target path: '+str(candidate))
    if path.exists() and not path.is_file():
        raise ValueError('Expected a regular file: '+str(path))
    return path

def prepare(target, manifest):
    actions=[]; errors=[]
    journal=safe_path(target,MANIFEST)
    if journal.exists() and digest(journal)!=digest(PACKAGE/MANIFEST):
        raise ValueError('A different delivery journal already exists: '+str(journal))
    for row in manifest['files']:
        try:
            destination=safe_path(target,row['path'])
            actual=digest(destination)
            wanted=row.get('after_sha256')
            old=row.get('before_sha256')
            if row['change']=='deleted':
                if actual is None: continue
                if actual!=old: raise ValueError('Local edits conflict with deletion: '+row['path'])
                actions.append(('delete',destination,None))
            else:
                source=safe_path(PACKAGE,row['path'])
                if digest(source)!=wanted: raise ValueError('Package hash mismatch: '+row['path'])
                if actual==wanted: continue
                if actual!=old: raise ValueError('Local edits conflict with replacement: '+row['path'])
                actions.append(('write',destination,source))
        except ValueError as exc:
            errors.append(str(exc))
    if errors: raise ValueError('\n'.join(errors))
    return actions

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--target',required=True,type=Path,help='Project directory containing spec/ and doc_examples/')
    parser.add_argument('--apply',action='store_true',help='Write only after every preflight check passes; default is check-only')
    args=parser.parse_args()
    if not args.target.is_dir(): parser.error('--target must be an existing directory')
    target=args.target.resolve()
    if target==PACKAGE: parser.error('Extract the changes package separately from the target')
    manifest=json.loads((PACKAGE/MANIFEST).read_text(encoding='utf-8'))
    try: actions=prepare(target,manifest)
    except ValueError as exc:
        print(json.dumps({'status':'CONFLICT','errors':str(exc).splitlines()},ensure_ascii=False,indent=2))
        return 1
    if args.apply:
        # Checks finish before the first change. Atomic per-file replacement
        # prevents partial file contents; the operation is not a filesystem transaction.
        for operation,destination,source in actions:
            if operation=='delete':
                destination.unlink()
            else:
                destination.parent.mkdir(parents=True,exist_ok=True)
                descriptor,name=tempfile.mkstemp(prefix='.lmx-change-',dir=destination.parent)
                try:
                    with os.fdopen(descriptor,'wb') as stream: stream.write(source.read_bytes())
                    os.chmod(name, source.stat().st_mode & 0o777)
                    os.replace(name,destination)
                finally:
                    if os.path.exists(name): os.unlink(name)
        # Preserve the exact delivery journal for provenance, outside its own hash list.
        (target/MANIFEST).write_bytes((PACKAGE/MANIFEST).read_bytes())
    print(json.dumps({'status':'APPLIED' if args.apply else 'READY',
                      'writes':sum(action[0]=='write' for action in actions),
                      'deletions':sum(action[0]=='delete' for action in actions),
                      'unchanged_or_already_applied':len(manifest['files'])-len(actions)},ensure_ascii=False))
    return 0

if __name__=='__main__': raise SystemExit(main())
