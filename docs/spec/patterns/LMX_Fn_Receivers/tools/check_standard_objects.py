#!/usr/bin/env python3
"""Source/metadata checks only; never execute or typecheck LMX."""
from pathlib import Path
import csv
import hashlib
import json
import re

ROOT=Path(__file__).resolve().parents[1]

def main():
    source=(ROOT/'src/coreStandardObjects.lmx').read_text()
    metadata=json.loads((ROOT/'CORE_STANDARD_OBJECT_ADDITIONS.json').read_text())
    cases=json.loads((ROOT/'tests/standard_objects_cases.json').read_text())
    definitions={m[1]:m[0].strip()+'\n' for m in re.finditer(r'(?m)^(Fx\w+):\n(?:(?!\n\s*\n)[\s\S])*',source)}
    checks=[]
    def check(ok,label):checks.append({'check':label,'status':'PASS' if ok else 'FAIL'})
    check(len(metadata['entries'])==16,'16 public entries')
    check(len({e['name'] for e in metadata['entries']})==16,'unique public names')
    entries=metadata['entries']+metadata['support_definitions']
    for entry in entries:
        code=definitions.get(entry['definition'],'')
        check(bool(code) and hashlib.sha256(code.encode()).hexdigest()==entry['sha256'] and sum(not c.isspace() for c in code)==entry['characters'],'definition inventory and exact metadata '+entry['definition'])
    check(not metadata['new_kernel_primitives'],'no new kernel primitives')
    check(not cases['runtime_executed'] and len(cases['cases'])==50 and all(c['status']=='NOT_RUN' for c in cases['cases']),'50 prepared cases with honest runtime status')
    check(source.count('while:')==1 and source.count('copy(FxFieldArguments)')==3,'one field scan and copied common inputs')
    check(source.index('candidate != nil')<source.index('FxSameText\\same(candidate; label)'),'nil observed before string payload comparison')
    check('FxMaybe@: result \\record' not in source and 'FxResult@: result \\record' not in source,'no unconditional container dereference')
    fold=definitions['FxFoldResult']
    check(fold.index('input\\reason')>fold.index('else:') and fold.count('FxApply\\apply')==1 and fold.index('input\\value')>fold.index('if: input\\ok'),'foldResult reads only the chosen payload and invokes one shared call')
    all_source='\n'.join(p.read_text() for p in (ROOT/'src').rglob('*.lmx'))
    known=set(re.findall(r'(?m)^(?:independent:\s*)?((?:Fx|Rx)\w+)\s*:',all_source))|{'FxKernel'}
    dependencies=set(re.findall(r'\b((?:Fx|Rx)\w+)(?=\\|@)',source))
    check(dependencies<=known,'all named implementation dependencies exist')
    for name in ['CORE_STANDARD_OBJECTS.md','CORE_STANDARD_OBJECTS_TZ.md']:
        for link in re.findall(r'\[[^\]]*\]\(([^\s)]+)\)',(ROOT/name).read_text()):
            if re.match(r'https?://',link):continue
            target=link.split('#',1)[0]
            check((ROOT/target).is_file() if target else True,'local link '+name+' '+link)
    with (ROOT/'STANDARD_OBJECT_COVERAGE.csv').open(encoding='utf-8-sig',newline='') as stream:
        coverage=list(csv.DictReader(stream))
    result={'status':'PASS' if all(c['status']=='PASS' for c in checks) else 'FAIL','scope':'Source hashes, metadata, dependency identities, branch placement and document links only; not LMX parsing or runtime verification.','checks_count':len(checks),'checks':checks,'public_operations':len(metadata['entries']),'definitions':len(definitions),'coverage_rows':len(coverage),'prepared_acceptance_cases':len(cases['cases']),'source_sha256':hashlib.sha256(source.encode()).hexdigest(),'lmx_runtime_executed':False}
    (ROOT/'tests/standard_objects_source_review.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k!='checks'}))
    if result['status']!='PASS':raise SystemExit(1)

if __name__=='__main__':main()
