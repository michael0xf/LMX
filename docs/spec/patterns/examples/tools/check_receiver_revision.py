#!/usr/bin/env python3
"""Check both complete styles, guide mirrors, failure boundaries and actual foreign dependencies."""
from pathlib import Path
import hashlib,json,re,sys
ROOT=Path(__file__).resolve().parents[2];EX=ROOT/'examples'
sys.path.insert(0,str(ROOT/'tools'))
from lmx_style_variants import normalize,measure,validate_variants
from guide_supplement import STRUCTURAL_ANCHORS
from select_variants import guide_document


def main():
    errors=[];checks=[];rows=[]
    def check(ok,label):
        checks.append(label)
        if not ok:errors.append(label)
    registry=json.loads((EX/'variants.json').read_text())
    variants={record['id']:record for record in registry['records']}
    counts=json.loads((EX/'validation/functional_receiver_counts.json').read_text())
    count_rows={row['id']:row for row in counts['rows']}
    guide=(ROOT/'LMX_examples_and_analogies.ru.md').read_text()
    expected=json.loads((EX/'expected_results.json').read_text())
    cases={record['id']:record for record in expected['source_examples']}
    supplement=EX/'GUIDE_SUPPLEMENTARY.md'
    check(supplement.is_file(),'permanent supplementary guide source is present')
    required_anchors=STRUCTURAL_ANCHORS | {row['id'].lower() for row in expected['additional_fixtures']}
    for anchor in sorted(required_anchors):
        check(guide.count('<a id="'+anchor+'"></a>')==1,
              anchor+': supplementary semantic chapter survives guide regeneration')
    anchors=re.findall(r'<a\s+(?:id|name)="([^"]+)"',guide)
    check(len(anchors)==len(set(anchors)),'every guide anchor has one destination')
    index=json.loads((EX/'haskell_comparision/comparison_index.json').read_text())
    if supplement.is_file():
        try:
            check(guide==guide_document(index['entries'],expected),
                  'complete guide is reproducible from both style listings and permanent supplementary chapters')
        except ValueError as error:
            check(False,'complete guide composition: '+str(error))
    check(len(variants)==len(count_rows)==len(cases)==24 and set(variants)==set(count_rows)==set(cases),'all24 contracts occur once in registry, counts and acceptance metadata')
    check(counts.get('source_count')==24 and counts.get('style_listing_count')==48,'both complete styles are counted for each contract')
    check(expected.get('receiver_revision',{}).get('compared_styles')==['procedural','functional'],'acceptance metadata compares both full styles')
    for ident,record in variants.items():
        check(not validate_variants(record,EX),ident+': complete style/source contracts')
        marker='<a id="'+ident.lower()+'"></a>'
        check(guide.count(marker)==1,ident+': one guide section')
        section=guide.split(marker,1)[1].split('<a id="',1)[0] if marker in guide else ''
        blocks=[normalize(match[1]) for match in re.finditer(r'^```lmx\n(.*?)^```\s*$',section,re.M|re.S)]
        bodies=[]
        for style in ('procedural','functional'):
            variant=record['lmx_variants'][style];code=normalize(variant['code'])
            if code not in bodies:bodies.append(code)
            check(count_rows.get(ident,{}).get(style)==measure(code),ident+'/'+style+': exact complete-source metrics')
            check(not re.search(r'(?m)^\s*fn:',code),ident+'/'+style+': no superseded fn declaration')
            check('import: fun' not in code,ident+'/'+style+': canonical core requires no custom import')
        check(blocks==bodies,ident+': each distinct full LMX body occurs once in guide')
        declared={item['id']:item for item in record['variants']}
        check(set(declared)=={'procedural','functional'},ident+': exact style identities')
        for style,variant in record['lmx_variants'].items():
            item=declared.get(style,{})
            check(item.get('code')==variant['code'] and item.get('metrics')==variant['metrics'],ident+'/'+style+': legacy registry mirror is exact')
            check(not item.get('load_before'),ident+'/'+style+': no hidden user helper source')
            check(cases[ident].get('style_cases',{}).get(style)==cases[ident].get('cases',[]),ident+'/'+style+': original acceptance cases retained')
        check(record.get('selected')==cases[ident].get('selected_variant')=='functional',ident+': legacy selection denotes only the functional compatibility mirror')
        check(record.get('lmx_legacy_role')=='compatibility_mirror_not_separate_comparison',ident+': no third compared LMX listing')
        check(bool(record.get('fairness_note')) and bool(record.get('style_note')),ident+': contract and style relation are explained')
        rows.append({'id':ident,'style_relation':record['style_relation'],
                     'procedural':measure(record['lmx_variants']['procedural']['code']),
                     'functional':measure(record['lmx_variants']['functional']['code'])})
    hs=(EX/'haskell_comparision/Analogies.hs').read_text()
    for module in ['IntApply','Partial','IntPipe','Lazy','EvaluationModes','StepIterator','CharacterRange','CurryInt']:
        check(not re.search(r'^import\s+(?:qualified\s+)?'+module+r'\b',hs,re.M),'foreign client imports no comparison helper '+module)
    check('import Control.Monad.Loops (whileJust_)' in hs,'H09 uses real monad-loops')
    check('import Data.Ix (inRange)' in hs,'V02 uses real Data.Ix')
    check('libraries' not in (EX/'haskell_comparision/lmx-examples.cabal').read_text(),'comparison modules do not leak into the client component')
    check(len(cases['V02']['cases'])==11,'all11 V02 input expectations retained')
    h09=(EX/'haskell_comparision/source/lmx/H09.lm3').read_text()
    check('Cycles:' in h09 and 'Cycles\\iterate:' in h09,'H09 contains its complete local helper')
    check('catch: Stop ()' in h09 and 'FxCallFailure' not in h09,'H09 retains ordinary source Stop handling')
    check(not cases['H09'].get('core_functions'),'H09 does not require an error-envelope adapter')
    core=(ROOT/'LMX_Fn_Receivers/src/coreComparisonExamples.lmx').read_text()
    check('PRIORITY sys\\priority("<=")' in core,'between retains explicit comparison priority')
    check('FxKernel\\attemptAccepted' in core,'declaration/body integration remains explicit')
    check('AE01' in (ROOT/'LMX_Fn_Receivers/CORE_EXAMPLE_HELPERS.md').read_text(),'AE01 integration contract is documented')
    report={'format':'examples-receiver-revision-v6','date':'2026-11-23','status':'PASS' if not errors else 'FAIL',
            'scope':'Both complete sources and metrics, complete guide including permanent supplementary chapters, registry mirrors, original failure boundaries, actual foreign dependencies and acceptance metadata; no parser/runtime execution.',
            'runtime':{'lmx_executed':False,'haskell_executed':False},'source_count':len(rows),'style_listing_count':2*len(rows),
            'guide_anchors':len(anchors),'supplementary_fixtures':len(expected['additional_fixtures']),
            'supplementary_source_sha256':hashlib.sha256(supplement.read_bytes()).hexdigest() if supplement.is_file() else None,
            'checks':len(checks),'rows':rows,'error_count':len(errors),'errors':errors}
    (EX/'validation/receiver_revision.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({'status':report['status'],'checks':len(checks),'source_contracts':len(rows),'style_metrics':2*len(rows),'errors':errors},ensure_ascii=False))
    return bool(errors)


if __name__=='__main__':raise SystemExit(main())
