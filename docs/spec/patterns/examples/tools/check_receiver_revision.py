#!/usr/bin/env python3
"""Check complete scenario sources, real client dependencies and deduplicated variants."""
from pathlib import Path
import hashlib,json,re,sys
ROOT=Path(__file__).resolve().parents[2];EX=ROOT/'examples'
sys.path.insert(0,str(ROOT/'tools'))
from throws_metrics import measure_throws
BEGIN='# BEGIN ALTERNATIVE LMX (excluded from character counts)';END='# END ALTERNATIVE LMX'
def canonical(s):return s.strip()+'\n'
def metric(s):
 s=canonical(s);return {'characters':sum(not c.isspace() for c in s),'nonblank_lines':sum(bool(x.strip()) for x in s.splitlines()),'utf8_bytes':len(s.encode()),'sha256':hashlib.sha256(s.encode()).hexdigest(),'without_complex_throws_characters':measure_throws(s,ROOT)['without_complex_throws_characters']}
def main():
 errors=[]
 def check(ok,msg):
  if not ok:errors.append(msg)
 registry=json.loads((EX/'variants.json').read_text());variants={r['id']:r for r in registry['records']};counts=json.loads((EX/'validation/functional_receiver_counts.json').read_text());guide=(ROOT/'LMX_examples_and_analogies.ru.md').read_text();expect=json.loads((EX/'expected_results.json').read_text());cases={r['id']:r for r in expect['source_examples']};checked=[]
 for row in counts['rows']:
  ident=row['id'];text=(EX/row['file']).read_text();primary=canonical(text.split(BEGIN)[0]);check(metric(primary)==row['after'],ident+': primary metrics differ')
  m=re.search(r'<!-- example: '+re.escape(ident)+r' -->\s*```lmx\n(.*?)\n```',guide,re.S);check(m is not None,ident+': guide source missing')
  if m:check(canonical(m[1])==primary,ident+': guide source differs')
  if ident in variants:
   r=variants[ident];vs={v['id']:v for v in r['variants']};chosen=vs[r['selected']];alt=vs.get(r.get('alternative'));eligible=[v for v in r['variants'] if v['correct_for_scenario'] and v['id'] in r['eligible_variants']];best=min(eligible,key=lambda v:(metric(v['code'])['characters'],v['id']!='original'))
   check(best['id']==chosen['id'],ident+': primary not shortest eligible');check(primary==canonical(chosen['code']),ident+': selected source differs');check(bool(r['fairness_note']),ident+': missing boundary')
   if alt:
    check(text.count(BEGIN)==1 and text.count(END)==1,ident+': missing unique alternative region')
    lines=text.split(BEGIN+'\n',1)[1].split(END,1)[0].splitlines();check(all(l.startswith('# ') for l in lines),ident+': uncommented alternative')
    check(canonical('\n'.join(l[2:] for l in lines[1:]))==canonical(alt['code']),ident+': alternative changed')
    m=re.search(r'<!-- alternative-example: '+ident+r' -->\s*```lmx\n(.*?)\n```',guide,re.S);check(bool(m),ident+': guide alternative missing')
    if m:check(canonical(m[1])==canonical(alt['code']),ident+': guide alternative differs')
   else:
    check(BEGIN not in text and END not in text,ident+': obsolete duplicate region');check(bool(r.get('inline_variant_note_ru')),ident+': compacted variant lacks explanation')
   for v in r['variants']:
    check(not re.search(r'(?m)^\s*fn:',v['code']),ident+': obsolete declaration');check('import: fun' not in v['code'],ident+': core import required');check(not v.get('load_before'),ident+': custom helper dependency')
   check(cases[ident].get('selected_variant')==chosen['id'],ident+': expected variant mismatch')
  checked.append({'id':ident,'primary':metric(primary),'has_alternative':BEGIN in text})
 hs=(EX/'haskell/Analogies.hs').read_text();forbidden=['IntApply','Partial','IntPipe','Lazy','EvaluationModes','StepIterator','CharacterRange','CurryInt']
 for module in forbidden:check(not re.search(r'^import\s+(?:qualified\s+)?'+module+r'\b',hs,re.M),'foreign client imports custom '+module)
 check('import Control.Monad.Loops (whileJust_)' in hs,'H09 does not use real monad-loops');check('import Data.Ix (inRange)' in hs,'V02 does not use real Data.Ix');check('libraries' not in (EX/'haskell/lmx-examples.cabal').read_text(),'custom modules leaked into client component')
 for ident in ['H04','R01','V03']:check(len(variants[ident]['variants'])==1,ident+': minor duplicate retained')
 check(len(checked)==24,'original 24 scenarios changed count');check(len(cases['V02']['cases'])==11,'V02 input coverage lost')
 h09=(EX/'lmx/H09.lm3').read_text();check('Cycles:' in h09 and 'Cycles\\iterate:' in h09,'H09 lost the complete local helper');check('catch: Stop ()' in h09 and 'FxCallFailure' not in h09,'H09 must retain ordinary source Stop handling');check(not cases['H09'].get('core_functions'),'H09 incorrectly requires an adapter core')
 core=(ROOT/'LMX_Fn_Receivers/src/coreComparisonExamples.lmx').read_text();check('PRIORITY sys\\priority("<=")' in core,'between has no comparison priority');check('FxKernel\\attemptAccepted' in core,'declaration/body integration lost');check('AE01' in (ROOT/'LMX_Fn_Receivers/CORE_EXAMPLE_HELPERS.md').read_text(),'AE01 undocumented')
 report={'format':'examples-receiver-revision-v4','date':'2026-11-23','status':'PASS' if not errors else 'FAIL','scope':'Sources, guide identities, ordinary versus envelope failure boundaries, actual foreign dependencies, meaningful variants and exact metrics; not parser/runtime execution','runtime':{'lmx_executed':False,'haskell_executed':False},'source_count':len(checked),'checks':checked,'error_count':len(errors),'errors':errors}
 (EX/'validation/receiver_revision.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n');print(json.dumps({'status':report['status'],'checked':len(checked),'errors':errors},ensure_ascii=False));return bool(errors)
if __name__=='__main__':raise SystemExit(main())
