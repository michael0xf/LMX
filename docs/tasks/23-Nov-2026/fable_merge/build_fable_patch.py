#!/usr/bin/env python3
"""Build a reviewable patch packet from an immutable baseline and new spec tree."""
import argparse
from collections import Counter
import hashlib
import io
import json
from pathlib import Path
import shutil
import subprocess
import tarfile
import tempfile


def sha(data):
    return None if data is None else hashlib.sha256(data).hexdigest()


def inventory(root):
    return {p.relative_to(root).as_posix(): p.read_bytes() for p in root.rglob('*')
            if p.is_file() and p.name != '.DS_Store' and '__pycache__' not in p.parts
            and p.suffix != '.pyc' and '.git' not in p.parts}


def category(name):
    path = Path(name)
    if path.suffix in {'.pdf', '.xlsx', '.csv'} or 'validation' in path.parts:
        return 'generated'
    if path.name in {'LMX_Receivers.lmx', 'catalog.json', 'CATALOG.md',
                     'value_symbols.json', 'MANIFEST.json', 'MANIFEST.sha256',
                     'ARCHIVE_MANIFEST.json', 'STATIC_REPORT.json', 'effect_contracts.json',
                     'STATISTICS.json', 'statistics.json', 'SOURCE_INVENTORY.json'}:
        return 'generated'
    return 'source'


def build(baseline, updated, output, archive):
    old, new = inventory(baseline), inventory(updated)
    output.mkdir(parents=True, exist_ok=True)
    changes = []
    with tarfile.open(output/'base-files.tar.gz','w:gz') as package:
        for name in sorted(old.keys() | new.keys()):
            before, after = old.get(name), new.get(name)
            if before == after:
                continue
            changes.append({'path':name, 'action': 'add' if before is None else 'delete' if after is None else 'modify',
                            'category': category(name), 'before':sha(before), 'after':sha(after),
                            'before_bytes':len(before) if before is not None else 0,
                            'after_bytes':len(after) if after is not None else 0})
            if before is not None:
                member=tarfile.TarInfo(name)
                member.size=len(before);member.mode=0o644;member.mtime=0
                package.addfile(member,io.BytesIO(before))
    report={'format':1,'baseline_archive':archive.name,'baseline_sha256':sha(archive.read_bytes()),
            'baseline_root':'spec','new_root':'spec',
            'description':'Source and generated outputs are separate; paths are relative to docs/spec.',
            'baseline_files':len(old),'updated_files':len(new),
            'counts':dict(Counter(x['action'] for x in changes)),
            'category_counts':dict(Counter(x['category'] for x in changes)), 'changes':changes}
    (output/'changes.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    with tempfile.TemporaryDirectory(prefix='fable-git-patch-') as directory:
        work=Path(directory)
        def git(*args):
            return subprocess.run(['git','-c','core.autocrlf=false','-c','core.quotePath=false',*args],cwd=work,
                                  check=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE).stdout
        git('init','-q')
        for name,data in old.items():
            dest=work/name;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(data)
        git('add','-A')
        git('-c','user.name=LMX patch builder','-c','user.email=patch@localhost',
            'commit','-q','-m','Exact uploaded spec baseline')
        for name in old:
            if name not in new:(work/name).unlink()
        for name,data in new.items():
            dest=work/name;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(data)
        git('add','-A')
        for kind in ('source','generated'):
            names=[x['path'] for x in changes if x['category']==kind]
            patch=git('diff','--cached','--binary','--full-index','--',*names) if names else b''
            (output/(kind+'.patch')).write_bytes(patch)
        report['base_git_commit']=git('rev-parse','HEAD').decode().strip()
    (output/'changes.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({k:v for k,v in report.items() if k!='changes'},ensure_ascii=False,indent=2))


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    for key in ('baseline','updated','output','archive'):p.add_argument(key,type=Path)
    a=p.parse_args();build(a.baseline.resolve(),a.updated.resolve(),a.output.resolve(),a.archive.resolve())
