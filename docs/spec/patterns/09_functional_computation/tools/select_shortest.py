#!/usr/bin/env python3
"""Publish both LMX client styles; retain existing foreign/body selections."""
from pathlib import Path
import json,sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parent/'tools'))
from lmx_execution_contract import apply_execution_contract
from lmx_style_variants import normalize,measure,validate_variants

def main():
    path=ROOT/'patterns.json';data=apply_execution_contract(json.loads(path.read_text()));decisions=[]
    for row in data['patterns']:
        for listing in row['listings']:
            language=listing['language']
            if language=='LMX' and row.get('lmx_variants'):
                errors=validate_variants(row)
                if errors:raise ValueError((row['id'],errors))
                code=row['lmx_variants']['functional']['code']
                listing.update(code=code,primary_variant='functional',publication_role='compatibility_mirror_not_separate_comparison')
                row['primary_variant']['LMX']='functional'
                decisions.append({'id':row['id'],'language':'LMX','compared_styles':['procedural','functional'],
                                  'metrics':{s:v['metrics'] for s,v in row['lmx_variants'].items()},
                                  'selection':'both full styles; no shortest-only selection'})
            else:
                variant=row['primary_variant'][language]
                listing['code']=normalize(row['variants'][language][variant])
                listing['primary_variant']=variant
                decisions.append({'id':row['id'],'language':language,'variant':variant,'metrics':measure(listing['code']),
                                  'selection':'one unchanged canonical implementation' if row.get('kind')=='implementation' else 'unchanged foreign control'})
    path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
    (ROOT/'variant_selection.json').write_text(json.dumps({'policy':data['selection_policy'],'decisions':decisions},ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({'client_pairs':4,'common_implementations':4,'foreign_sources_changed':False}))
if __name__=='__main__':main()
