#!/usr/bin/env python3
"""Execute only local Common Lisp implementation-reference tests."""
import sys
sys.dont_write_bytecode = True
from pathlib import Path
import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess

ROOT=Path(__file__).resolve().parents[1]
def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--sbcl', default=os.environ.get('SBCL_BIN') or os.environ.get('SBCL') or 'sbcl')
    parser.add_argument('--sbcl-home', default=os.environ.get('SBCL_HOME'))
    args=parser.parse_args()
    executable=shutil.which(args.sbcl)
    environment=dict(os.environ)
    if args.sbcl_home: environment['SBCL_HOME']=args.sbcl_home
    files=sorted((ROOT/'source/implementations/common-lisp').glob('*.lisp'))+[ROOT/'tools/test_implementations.lisp']
    provenance=[{'file':p.relative_to(ROOT).as_posix(),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in files]
    if not executable:
        result={'status':'NOT_RUN','reason':'SBCL executable not found; set SBCL_BIN or install SBCL.',
                'files':provenance,'LMX':'NOT_RUN'}
    else:
        version=subprocess.run([executable,'--version'],capture_output=True,text=True,check=True,env=environment).stdout.strip()
        run=subprocess.run([executable,'--script',str(ROOT/'tools/test_implementations.lisp')],
                           cwd=ROOT,capture_output=True,text=True,timeout=60,env=environment)
        (ROOT/'validation/implementation_test.log').write_text(run.stdout+run.stderr)
        ids=re.findall(r'^PASS (SI\d+\.\d+)$',run.stdout,re.M)
        declared=re.search(r'^CHECKS (\d+)$',run.stdout,re.M)
        ok=run.returncode==0 and declared is not None and int(declared[1])==len(ids) and len(set(ids))==len(ids)
        by_group={k:sum(x.startswith(k+'.') for x in ids) for k in sorted({x.split('.')[0] for x in ids})}
        result={'status':'PASS' if ok else 'FAIL','runtime':version,'command':'sbcl --script tools/test_implementations.lisp',
                'checks':len(ids),'groups':by_group,'test_ids':ids,'returncode':run.returncode,
                'files':provenance,'LMX':'NOT_RUN','note':'Only Common Lisp reference code executed; no claim of LMX runtime validation.'}
    (ROOT/'validation/implementation_execution.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({k:result.get(k) for k in ('status','runtime','checks','groups')},ensure_ascii=False))
    if result['status']=='FAIL': raise SystemExit(1)
if __name__=='__main__': main()
