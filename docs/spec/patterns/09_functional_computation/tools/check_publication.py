#!/usr/bin/env python3
"""Check source/publication integrity and real-library boundaries; not a compiler."""
from pathlib import Path
import json,re,csv
ROOT=Path(__file__).resolve().parents[1]
LANG={'LMX':('lmx','lm3','lmx'),'Haskell':('haskell','hs','haskell'),'Scala':('scala','scala','scala')}
def canon(s):return s.strip()+'\n'
def metric(s):return sum(not x.isspace() for x in s),sum(bool(x.strip()) for x in s.splitlines())
def main():
 data=json.loads((ROOT/'patterns.json').read_text());errors=[];checks=[];by={x['id']:x for x in data['patterns']}
 def check(ok,label):
  checks.append(label)
  if not ok:errors.append(label)
 for p in data['patterns']:
  stem=f"{p['id']:03d}_{p['slug']}";md=(ROOT/(stem+'_comparision.md')).read_text()
  fences=re.findall(r'^```([^\n]*)\n(.*?)^```\s*$',md,re.M|re.S)
  nalt=sum(len(v)-1 for v in p['variants'].values())
  check(len(fences)==3+nalt,f'{p["id"]}: only primary plus genuinely different alternatives')
  for n,l in enumerate(p['listings']):
   lang=l['language'];folder,ext,tag=LANG[lang];code=canon(l['code']);source=ROOT/'examples'/folder/(stem+'.'+ext)
   check(source.read_text()==code,f'{p["id"]}/{lang}: complete primary source equals JSON')
   check(fences[n]==(tag,code),f'{p["id"]}/{lang}: primary fence equals source')
   eligible=p['eligible_variants'][lang]
   check(p['primary_variant'][lang] in eligible,f'{p["id"]}/{lang}: selected eligible approach')
   check(metric(code)[0]==min(metric(canon(p['variants'][lang][x]))[0] for x in eligible),f'{p["id"]}/{lang}: shortest within declared boundary')
   a,b=metric(code);check(f'| {lang} | {a} | {b} |' in md,f'{p["id"]}/{lang}: exact published counts')
   if p.get('kind')!='implementation' and lang!='LMX':
    check(not re.search(r'^import (MaybeValue|Bounce|Around|Partial)[ .(]',code,re.M),f'{p["id"]}/{lang}: no custom comparison import')
   for v,other in p['variants'][lang].items():
    altfile=ROOT/'examples'/folder/'variants'/(stem+'_'+v+'.'+ext)
    if v==p['primary_variant'][lang]:check(not altfile.exists(),f'{p["id"]}/{lang}: no duplicate primary variant file')
    else:
     check(altfile.is_file() and altfile.read_text()==canon(other),f'{p["id"]}/{lang}/{v}: retained full alternate source')
     check((tag,canon(other)) in fences,f'{p["id"]}/{lang}/{v}: alternate published once')
  check(not p.get('alternative'),f'{p["id"]}: obsolete full historical copies removed')
 check('import Control.Exception (IOException, bracket, try)' in by[84]['variants']['Haskell']['standard'],'084: actual Haskell bracket import')
 check('Using.resource(acquire())' in by[84]['variants']['Scala']['standard'],'084: actual Scala Using.resource call')
 check('Around:' not in by[84]['variants']['LMX']['core'],'084: core client does not duplicate helper')
 local=by[84]['variants']['LMX']['local_callbacks']
 check(local.count('Around:\n')==1 and 'catch: ResourceFailure ()' in local,'084: procedural alternative has complete helper and handler')
 for token in ['int: value 42','int: mode','Trace\\events','return: -Trace\\events']:
  check(token in by[84]['variants']['LMX']['core'],'084: retained scenario '+token)
 shared=by[83]['variants']['LMX']['shared_body']
 check(shared.count('return: more(')==1 and '@: next odd_step' in shared and '@: next even_step' in shared,'083: shared body retains both transitions')
 for lang in ['Haskell','Scala']:
  check('saved' in by[85]['variants'][lang]['standard'],'085/'+lang+': retained saved binding')
 hs=by[98]['variants']['Haskell']['implementation'];sc=by[98]['variants']['Scala']['implementation']
 check('mask $ \\restore' in hs and 'restore (action resource)' in hs,'098: Haskell asynchronous setup protection and restored action')
 check('addSuppressed' in sc and 'severity(second) > severity(first)' in sc,'098: Scala dual-failure retention and priority')
 src=(ROOT.parent/'LMX_Fn_Receivers/src/generic_wrappers.lmx').read_text().split('FxAround:\n',1)[1].split('\n\n',1)[0]
 check(src.index('sys\\resize(resourceArgs; 1)')<src.index('finally:')<src.index('FxTry\\attempt(acquire; empty)'),'098: cleanup vector and guarded finally precede acquire')
 check(src.index('finally:')<src.index('FxAppend\\append') and 'if: acquired\\ok != 0' in src,'098: successful-outcome guard protects argument construction')
 check('Args (types :: [Type])' in by[99]['variants']['Haskell']['implementation'],'099: heterogeneous unbounded Haskell inputs')
 check('Tuple.Concat[Prefix, Rest]' in by[99]['variants']['Scala']['implementation'],'099: heterogeneous arbitrary Scala prefix')
 cases=json.loads((ROOT/'acceptance_cases.json').read_text())['cases']
 check(all(x['status']=='NOT_RUN' for x in cases),'acceptance cases do not claim execution')
 report={'date':'2026-11-23','ok':not errors,'scope':'source/publication and declared boundary checks; no language execution','checks':len(checks),'errors':errors,'pattern_ids':list(by),'retained_alternate_listings':sum(sum(len(v)-1 for v in p['variants'].values()) for p in by.values()),'acceptance_cases_prepared':len(cases),'lmx_runtime_executed':False,'haskell_runtime_executed':False,'scala_runtime_executed':False}
 (ROOT/'validation_2026-11-23.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
 print(json.dumps(report,ensure_ascii=False));return bool(errors)
if __name__=='__main__':raise SystemExit(main())
