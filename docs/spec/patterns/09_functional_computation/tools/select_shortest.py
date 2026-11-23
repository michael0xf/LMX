#!/usr/bin/env python3
"""Choose within the same usage/implementation boundary; no history inflation."""
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[1]
import sys
sys.path.insert(0,str(ROOT.parent/'tools'))
from throws_metrics import measure_throws
def canon(s): return s.strip()+'\n'
def count(s): return sum(not c.isspace() for c in s)
def main():
 path=ROOT/'patterns.json'; data=json.loads(path.read_text()); decisions=[]
 for p in data['patterns']:
  for listing in p['listings']:
   lang=listing['language']; variants={k:canon(v) for k,v in p['variants'][lang].items()}; p['variants'][lang]=variants
   eligible=p['eligible_variants'][lang]; assert eligible and all(k in variants for k in eligible)
   minimum=min(count(variants[k]) for k in eligible)
   choices=[k for k in eligible if count(variants[k])==minimum]
   chosen=p['primary_variant'][lang] if p['primary_variant'][lang] in choices else choices[0]
   p['primary_variant'][lang]=chosen;listing['primary_variant']=chosen;listing['code']=variants[chosen]
   listing.update(p.get('variant_notes',{}).get(lang,{}).get(chosen,{}))
   decisions.append({'id':p['id'],'language':lang,'primary_variant':chosen,'eligible_variants':eligible,'primary_characters':minimum,'retained_approaches':list(variants),'fairness_note':p['fairness_notes'][lang]})
 for row in decisions:
  if row['language']=='LMX':
   pattern=next(p for p in data['patterns'] if p['id']==row['id'])
   row['without_complex_throws_characters']={name:measure_throws(code,ROOT.parent)['without_complex_throws_characters'] for name,code in pattern['variants']['LMX'].items()}
 path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
 (ROOT/'variant_selection.json').write_text(json.dumps({'policy':data['selection_policy'],'decisions':decisions},ensure_ascii=False,indent=2)+'\n')
 print(json.dumps({'choices':len(decisions),'policy':'real facilities for usage; complete scoped implementations separately'}))
if __name__=='__main__':main()
