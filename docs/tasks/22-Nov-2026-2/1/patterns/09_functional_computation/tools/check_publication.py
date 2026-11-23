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
def main():
 data=json.loads((ROOT/'patterns.json').read_text());errors=[];checks=[]
 def check(cond,why):
  checks.append(why)
  if not cond:errors.append(why)
 for p in data['patterns']:
  stem=f"{p['id']:03d}_{p['slug']}";md=(ROOT/(stem+'_comparision.md')).read_text();fences=re.findall(r'^```([^\n]*)\n(.*?)^```\s*$',md,re.M|re.S)
  check(len(fences)==6,f'{p["id"]}: three primary and three historical fences')
  for i,l in enumerate(p['listings']):
   lang=l['language'];folder,ext,tag=EXT[lang];code=canon(l['code']);source=(ROOT/'examples'/folder/(stem+'.'+ext)).read_text()
   if lang=='LMX':
    primary,sep,old=source.partition('\n'+MARK+'\n');check(bool(sep),f'{p["id"]}: archival sentinel exists')
    check(canon(primary)==code,f'{p["id"]}: primary source equals JSON')
    lines=old.splitlines();check(lines[-1]==END,f'{p["id"]}: archive closed')
    decoded='\n'.join(x[2:] for x in lines[:-1])+'\n';check(decoded==canon(p['alternative']['LMX']['code']),f'{p["id"]}: exact preserved old LMX source')
   else:check(source==code,f'{p["id"]}/{lang}: source equals JSON')
   check(i<len(fences) and fences[i]==(tag,code),f'{p["id"]}/{lang}: primary fence equals source')
   eligible=p['eligible_variants'][lang];check(p['primary_variant'][lang] in eligible,f'{p["id"]}/{lang}: eligible selected algorithm');check(metric(code)[0]==min(metric(canon(p['variants'][lang][v]))[0] for v in eligible),f'{p["id"]}/{lang}: shortest eligible full source')
   chars,ln=metric(code);check(f'| {lang} | {chars} | {ln} |' in md,f'{p["id"]}/{lang}: exact published metrics')
  expected=[('lmx',canon(p['alternative']['LMX']['code']))]+[(EXT[k][2],canon(p['alternative'][k]['code'])) for k in ['Haskell','Scala']]
  check(fences[3:]==expected,f'{p["id"]}: all historical fences equal JSON')
 report={'date':'2026-11-22','ok':not errors,'scope':'Static publication and exact historical preservation only; no language runtime execution','checks':len(checks),'errors':errors,'pattern_ids':[p['id'] for p in data['patterns']],'preserved_lmx':8,'preserved_control_listings':16,'lmx_runtime_executed':False,'haskell_runtime_executed':False,'scala_runtime_executed':False}
 (ROOT/'validation_2026-11-22.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n');print(json.dumps(report,ensure_ascii=False));return bool(errors)
if __name__=='__main__':raise SystemExit(main())
