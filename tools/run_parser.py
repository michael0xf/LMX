"""Run imported P0 goldens against a supplied printTree executable; never regenerate goldens."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess

ROOT=Path(__file__).resolve().parents[1]

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--parser',type=Path,required=True)
    ap.add_argument('--profile',choices=['historical','previous-l1','current'],default='historical')
    ap.add_argument('--output',type=Path,default=ROOT/'build/parser')
    args=ap.parse_args()
    exe=args.parser.resolve(strict=True)
    records=json.loads((ROOT/'provenance/parser-tests.json').read_text(encoding='utf-8'))['files']
    def lookup(stage,path):
        matches=[r for r in records if any(o['stage']==stage and o['path']==path for o in r['origins'])]
        if len(matches)!=1:raise ValueError(f'Expected one source for {stage}:{path}, found {len(matches)}')
        return ROOT/matches[0]['path']
    env=os.environ.copy()
    for key in ('LM_TRANS_REGISTRY','LM_TRANS_REGISTRY_VIEW','LM_P0_REGISTRY','LM_P0_COMPARE_REGISTRY'):
        env.pop(key,None)
    args.output.mkdir(parents=True,exist_ok=True)
    report={'profile':args.profile,'parser':str(exe),'parser_sha256':hashlib.sha256(exe.read_bytes()).hexdigest(),'cases':[]}
    if args.profile=='current':
        inputs=json.loads((ROOT/'tests/parser/current/expectations.json').read_text(encoding='utf-8'))
    else:
        inputs=[]
        manifest=lookup('03-l1','tests/l1/legacy_p0_manifest.txt').read_text(encoding='utf-8-sig')
        for line in manifest.splitlines():
            if not line.strip() or line.startswith('#'):continue
            path,exitcode,*tail=line.split(maxsplit=2)
            note=tail[0] if tail else ''
            path=path.replace('\\','/')
            key=path.replace('/','_')
            base='tests/l1/goldens/printTree.lm0/'+key
            expected_exit=int(exitcode)
            golden_exit=int(lookup('03-l1',base+'.exit').read_text(encoding='utf-8-sig').strip())
            if golden_exit!=expected_exit:raise ValueError(f'Imported golden/manifest disagree: {path}')
            expectation={'path':str(lookup('03-l1',path).relative_to(ROOT)),'exit':expected_exit,'name':path}
            override=re.search(r'root_exit=(\d+)',note)
            if args.profile=='previous-l1' and override:
                expectation['exit']=int(override.group(1))
                diag=re.search(r'root_diag=(\d+@\d+:\d+)',note)
                expectation['diagnostic']=diag.group(1) if diag else '32@'
            elif expected_exit==0:
                expectation['stdout_file']=str(lookup('03-l1',base+'.stdout').relative_to(ROOT))
            else:
                expectation['diagnostic']=lookup('03-l1',base+'.p0').read_text(encoding='utf-8-sig').strip()
            inputs.append(expectation)
    for i,expect in enumerate(inputs):
        source=ROOT/expect['path']
        case={'name':expect.get('name',expect['path']),'expected_exit':expect['exit']}
        try:
            run=subprocess.run([str(exe),str(source)],cwd=ROOT,env=env,capture_output=True,timeout=15)
            case['exit']=run.returncode
            (args.output/f'{i:04d}.stdout').write_bytes(run.stdout)
            (args.output/f'{i:04d}.stderr').write_bytes(run.stderr)
            ok=run.returncode==expect['exit']
            if 'stdout_file' in expect:
                ok=ok and run.stdout==(ROOT/expect['stdout_file']).read_bytes()
            if 'diagnostic' in expect:
                match=re.search(rb'P0 parse error (\d+) at (\d+):(\d+)',run.stderr)
                diagnostic=(match[1]+b'@'+match[2]+b':'+match[3]).decode() if match else ''
                case['diagnostic']=diagnostic
                ok=ok and (diagnostic==expect['diagnostic'] or (expect['diagnostic']=='32@' and diagnostic.startswith('32@')))
            for text in expect.get('stdout_contains',[]):
                ok=ok and text.encode('utf-8') in run.stdout
            if 'stdout_exact' in expect:
                actual=run.stdout.decode('utf-8').replace('\r\n','\n')
                ok=ok and actual==expect['stdout_exact']
            case['passed']=bool(ok)
        except subprocess.TimeoutExpired:
            case.update(passed=False,error='timeout')
        report['cases'].append(case)
    report['passed']=sum(c['passed'] for c in report['cases'])
    report['failed']=len(report['cases'])-report['passed']
    (args.output/'report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(f'{args.profile}: {report["passed"]} passed, {report["failed"]} failed')
    for case in report['cases']:
        if not case['passed']:print('FAIL',case['name'],case.get('exit'),case.get('diagnostic',''))
    raise SystemExit(1 if report['failed'] else 0)

if __name__=='__main__':main()
