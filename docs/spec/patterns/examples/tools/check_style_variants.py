#!/usr/bin/env python3
"""Validate both full styles of the24 root scenarios without executing LMX."""
from pathlib import Path
import argparse,hashlib,json,re,sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parent/'tools'))
from lmx_style_variants import validate_variants,normalize,measure,type_declaration_issues

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--baseline',type=Path);args=parser.parse_args()
    index=json.loads((ROOT/'haskell/comparison_index.json').read_text());checks=[];errors=[]
    def check(condition,label):
        checks.append(label)
        if not condition:errors.append(label)
    check(len(index['entries'])==24,'all24 original scenario identities present')
    check(hashlib.sha256((ROOT/'haskell/Analogies.hs').read_bytes()).hexdigest()==index['source_module_sha256'],'unchanged Haskell module fingerprint')
    sources=set()
    for entry in index['entries']:
        ident=entry['id'];issues=validate_variants(entry,ROOT)
        check(not issues,ident+': shared full-style/source/type gates'+(' '+repr(issues) if issues else ''))
        sources.update(v['source_file'] for v in entry['lmx_variants'].values())
        md=(ROOT/entry['lmx_style_comparison']).read_text()
        blocks=[normalize(m[1]) for m in re.finditer(r'^```lmx\n(.*?)^```\s*$',md,re.M|re.S)]
        expected=[entry['lmx_variants']['functional']['code']] if entry['style_relation']=='same_minimal_form' else [entry['lmx_variants'][s]['code'] for s in ['procedural','functional']]
        check(blocks==expected,ident+': every distinct LMX body published exactly once')
        for style,variant in entry['lmx_variants'].items():
            label='процедурный' if style=='procedural' else 'функциональный';m=variant['metrics']
            check(f"| LMX — {label} | {m['characters']} | {m['nonblank_lines']} |" in md.replace('**',''),ident+'/'+style+': full metric row')
        if entry.get('foreign_code'):
            code=entry['foreign_code'];foreign=[normalize(m[1]) for m in re.finditer(r'^```haskell\n(.*?)^```\s*$',md,re.M|re.S)]
            check(foreign==[normalize(code)],ident+': unchanged Haskell listing published once')
            check(hashlib.sha256(code.encode()).hexdigest()==entry['foreign_listing_sha256'],ident+': original foreign listing hash')
        if args.baseline:
            prior=json.loads((args.baseline/'patterns/examples/haskell/comparison_index.json').read_text())
            old=next(e for e in prior['entries'] if e['id']==ident)
            check(entry.get('foreign_code')==old.get('foreign_code') and entry['status']==old['status'],ident+': exact uploaded foreign control and comparability status')
        check('без сложного' not in md.lower() and 'without_complex_throws' not in md,ident+': no reduced-error counting')
    for code in ['Model@: p','int@: left','Model[]: arr','int[]: values',
                 'Model[]: arr [Model Model]','Model[]: [Model Model]',
                 'int[]: values [1 2 3]','int[]: [1 2 3]',
                 'FxMaybe@: input','int[]: items','@: current makeValue()','@: same Slots']:
        check(not type_declaration_issues(code),'current declaration accepted: '+code)
    for code in ['@int: left','[]int: items','@: int left','@: left int']:
        check(bool(type_declaration_issues(code)),'superseded declaration rejected: '+code)
    report={'status':'PASS' if not errors else 'FAIL','checks':len(checks),'errors':errors,'scenarios':24,'compared_style_records':48,'unique_lmx_sources':len(sources),'same_minimal_form':sum(e['style_relation']=='same_minimal_form' for e in index['entries']),'runtime_execution':'NOT_RUN','scope':'Source/JSON/Markdown, full metric, foreign preservation and declaration-format checks only. No parser or runtime execution.'}
    (ROOT/'validation/style_variants.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps(report,ensure_ascii=False));return bool(errors)
if __name__=='__main__':raise SystemExit(main())
