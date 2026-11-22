#!/usr/bin/env python3
"""Select shortest fair algorithms of the single current core; history is not a competing library."""
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[1]
def canon(s):return s.strip()+'\n'
def count(s):return sum(not c.isspace() for c in s)
def main():
 path=ROOT/'patterns.json';data=json.loads(path.read_text());decisions=[]
 for p in data['patterns']:
  for listing in p['listings']:
   lang=listing['language'];variants={k:canon(v) for k,v in p['variants'][lang].items()};p['variants'][lang]=variants
   eligible=p['eligible_variants'][lang];assert eligible and all(k in variants for k in eligible)
   current=p['primary_variant'][lang];minimum=min(count(variants[k]) for k in eligible);choices=[k for k in eligible if count(variants[k])==minimum]
   chosen=current if current in choices else choices[0];p['primary_variant'][lang]=chosen;listing['primary_variant']=chosen;listing['code']=variants[chosen]
   listing.update(p.get('variant_notes',{}).get(lang,{}).get(chosen,{}))
   decisions.append({'id':p['id'],'language':lang,'primary_variant':chosen,'eligible_variants':eligible,'primary_characters':minimum,'historical_characters':count(p['alternative'][lang]['code']),'historical_is_eligible':False,'fairness_note':p['fairness_notes'][lang]})
 path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
 (ROOT/'variant_selection.json').write_text(json.dumps({'policy':data['selection_policy'],'decisions':decisions},ensure_ascii=False,indent=2)+'\n')
 print(json.dumps({'choices':len(decisions),'current_core':True,'historical_sources_excluded':len(decisions)}))
if __name__=='__main__':main()
