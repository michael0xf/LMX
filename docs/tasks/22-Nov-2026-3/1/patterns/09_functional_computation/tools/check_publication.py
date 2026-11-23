#!/usr/bin/env python3
"""Group09 consistency checker; does not execute LMX, Haskell or Scala."""
from pathlib import Path
import json,re,hashlib,csv,io
ROOT=Path(__file__).resolve().parents[1]
MARK='# BEGIN ALTERNATIVE LMX (excluded from character counts)'
END='# END ALTERNATIVE LMX'
EXT={'LMX':('lmx','lm3','lmx'),'Haskell':('haskell','hs','haskell'),'Scala':('scala','scala','scala')}
def canon(s):return s.strip()+'\n'
def metric(s):return sum(not c.isspace() for c in s),sum(bool(l.strip()) for l in s.splitlines())
def historical_code(other):
 prefix=other.get('context_prefix','')
 return (canon(prefix)+'\n' if prefix else '')+canon(other['code'])
def main():
 data=json.loads((ROOT/'patterns.json').read_text());errors=[];checks=[]
 def check(cond,why):
  checks.append(why)
  if not cond:errors.append(why)
 for p in data['patterns']:
  stem=f"{p['id']:03d}_{p['slug']}";md=(ROOT/(stem+'_comparision.md')).read_text();fences=re.findall(r'^```([^\n]*)\n(.*?)^```\s*$',md,re.M|re.S)
  displayed=[v for v in p.get('inline_current_lmx_variants',[]) if v!=p['primary_variant']['LMX']]
  check(len(fences)==6+len(displayed),f'{p["id"]}: primary, displayed current, and historical fence count')
  if p.get('failure_note'):
   note=p['failure_note'];path=note['path'].partition('#')[0]
   check((ROOT/path).is_file(),f'{p["id"]}: failure-boundary companion exists')
   check(']('+note['path']+')' in md,f'{p["id"]}: failure-boundary explanation linked')
  for i,l in enumerate(p['listings']):
   lang=l['language'];folder,ext,tag=EXT[lang];code=canon(l['code']);source=(ROOT/'examples'/folder/(stem+'.'+ext)).read_text()
   if lang=='LMX':
    primary,sep,old=source.partition('\n'+MARK+'\n');check(bool(sep),f'{p["id"]}: archival sentinel exists')
    check(canon(primary)==code,f'{p["id"]}: primary source equals JSON')
    lines=old.splitlines();check(lines[-1]==END,f'{p["id"]}: archive closed')
    decoded='\n'.join(x[2:] for x in lines[:-1])+'\n';other=p['alternative']['LMX']
    check(decoded==historical_code(other),f'{p["id"]}: exact complete saved LMX source')
    if other.get('context_prefix'):
     prefix=canon(other['context_prefix'])+'\n'
     check(decoded.startswith(prefix) and decoded[len(prefix):]==other['code'],f'{p["id"]}: byte-exact historical client follows its declared context')
   else:check(source==code,f'{p["id"]}/{lang}: source equals JSON')
   check(i<len(fences) and fences[i]==(tag,code),f'{p["id"]}/{lang}: primary fence equals source')
   eligible=p['eligible_variants'][lang];check(p['primary_variant'][lang] in eligible,f'{p["id"]}/{lang}: eligible selected algorithm');check(metric(code)[0]==min(metric(canon(p['variants'][lang][v]))[0] for v in eligible),f'{p["id"]}/{lang}: shortest eligible full source')
   chars,ln=metric(code);check(f'| {lang} | {chars} | {ln} |' in md,f'{p["id"]}/{lang}: exact published metrics')
  current=[('lmx',canon(p['variants']['LMX'][v])) for v in displayed]
  check(fences[3:3+len(displayed)]==current,f'{p["id"]}: displayed current alternatives equal JSON')
  for variant in displayed:
   chars,ln=metric(canon(p['variants']['LMX'][variant]))
   check(f'**{chars} непробельных символов / {ln} непустых строк**' in md,f'{p["id"]}/{variant}: displayed alternative size')
  expected=[('lmx',historical_code(p['alternative']['LMX']))]+[(EXT[k][2],historical_code(p['alternative'][k])) for k in ['Haskell','Scala']]
  check(fences[3+len(displayed):]==expected,f'{p["id"]}: all historical fences equal JSON')
  for lang,other in p['alternative'].items():
   if other.get('context_prefix'):
    chars,ln=metric(historical_code(other))
    check(f'Полный размер сохранённого варианта: **{chars} непробельных символов / {ln} непустых строк**' in md,f'{p["id"]}/{lang}: complete saved listing metrics')
 by={p['id']:p for p in data['patterns']}
 trampoline=by[83]['variants']['LMX']['core']
 check(trampoline.count('    throws:\n')==1,'083: finite exit list declared once')
 check(trampoline.count('throws: copy(Steps\\throws)')==3,'083: all three uses qualify the shared source')
 check('return: \\trampoline(Steps\\even_step(n))' in trampoline,'083: result dereference remains explicit')
 shared=by[83]['variants']['LMX']['shared_body']
 check(shared.count('    Throws:\n')==1 and shared.count('throws: copy(Throws)')==4,'083: shared-body primary declares exits once with four uses')
 check('@: next odd_step' in shared and '@: next even_step' in shared and shared.count('return: more(')==1,'083: common body retains both mutual transitions')
 check('Tthrows' not in shared and 'return: \\trampoline(even_step(n))' in shared,'083: corrected source and explicit result dereference')
 old83=by[83]['alternative']['LMX']
 check(old83['code']==by[83]['procedural_lmx'] and hashlib.sha256(old83['code'].encode()).hexdigest()==old83['preserved_code_sha256'],'083: historical client bytes retained')
 check(old83['context_prefix']==by[92]['alternative']['LMX']['code'],'083: historical Bounce and runner context included in full')
 trace=by[84]['variants']['LMX']['shared_trace']
 check(trace.startswith('Around:\n    @: acquire\n    @: release\n    @: action\n'),'084: factored primary includes its entire Around helper')
 check('        close:\n            int: x 3\n            eval()\n' in trace and 'eval(int: x 3)' not in trace,'084: release declares its dynamic local before calling eval')
 check('catch: ResourceFailure ()' in trace and 'int: value 42' in trace and 'finally:\n            release(resource := resource)' in trace,'084: failure, resource and cleanup remain explicit')
 around=by[84]['variants']['LMX']['core']
 check('catch: FxCallFailure (@: outcome)' in around,'084: declared generic-call envelope is caught')
 check(not re.search(r'^\s+FxCallFailure\s*$',around,re.M),'084: handled envelope is not advertised outward')
 local=by[84]['variants']['LMX']['local_callbacks']
 check('local_callbacks' in by[84]['eligible_variants']['LMX'],'084: complete local callback helper is eligible')
 check('Around:\n    @: acquire\n    @: release\n    @: action\n' in local,'084: local callback helper is fully declared in its counted listing')
 check('Around\\use(Acquire\\open; Release\\close; Action\\use)' in local,'084: callback-supplied execute-around mechanism is retained')
 check('catch: ResourceFailure ()' in local,'084: current local variant catches its original declared failure')
 saved=by[84]['alternative']['LMX'];raw=saved['code'];context=saved['context_prefix']
 check(raw==by[84]['procedural_lmx'],'084: original historical client matches the retained procedural snapshot')
 check(hashlib.sha256(raw.encode()).hexdigest()==saved['preserved_code_sha256'],'084: original historical client retains its recorded hash')
 check(saved['context_prefix_source_id']==98 and context==by[98]['alternative']['LMX']['code'],'084: restored context is the exact historical Around from 098')
 check(historical_code(saved).count('Around:\n')==1,'084: complete saved listing defines Around exactly once')
 decisions=json.loads((ROOT/'variant_selection.json').read_text())['decisions']
 decision=next(d for d in decisions if d['id']==84 and d['language']=='LMX')
 check(decision['historical_characters']==metric(historical_code(saved))[0] and decision['historical_client_characters']==metric(raw)[0] and decision['historical_context_characters']==metric(context)[0] and decision['historical_nonblank_lines']==metric(historical_code(saved))[1],'084: saved comparison metrics include the complete context')
 auxiliary=ROOT/'examples/lmx/083_trampoline_failure_boundary.lm3'
 note=ROOT/'FAILURE_BOUNDARIES.md'
 check(auxiliary.is_file() and note.is_file(),'083: concrete partial failure boundary is published')
 if auxiliary.is_file() and note.is_file():
  check('```lmx\n'+canon(auxiliary.read_text())+'```' in note.read_text(),'083: companion fence equals its auxiliary source')
 report={'date':'2026-11-22','ok':not errors,'scope':'Static publication and exact historical preservation only; no language runtime execution','checks':len(checks),'errors':errors,'pattern_ids':[p['id'] for p in data['patterns']],'preserved_lmx':8,'preserved_control_listings':16,'lmx_runtime_executed':False,'haskell_runtime_executed':False,'scala_runtime_executed':False}
 (ROOT/'validation_2026-11-22.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n');print(json.dumps(report,ensure_ascii=False));return bool(errors)
if __name__=='__main__':raise SystemExit(main())
