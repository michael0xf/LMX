#!/usr/bin/env python3
"""Check both full styles and canonical shared bodies; no language execution."""
from pathlib import Path
import json,re,sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parent/'tools'))
from lmx_style_variants import normalize,measure,validate_variants
from canonical_operations import definitions
LANG={'LMX':('lmx','lm3','lmx'),'Haskell':('haskell','hs','haskell'),'Scala':('scala','scala','scala')}

def main():
    data=json.loads((ROOT/'patterns.json').read_text());by={r['id']:r for r in data['patterns']};checks=[];errors=[]
    def check(condition,label):
        checks.append(label)
        if not condition:errors.append(label)
    for row in data['patterns']:
        ident=row['id'];stem=f"{ident:03d}_{row['slug']}";md=(ROOT/(stem+'_comparision.md')).read_text()
        fences=[(m[1],normalize(m[2])) for m in re.finditer(r'^```([^\n]*)\n(.*?)^```\s*$',md,re.M|re.S)]
        variant_count=2 if row.get('lmx_variants') else 1
        check(len(fences)==variant_count+2,f'{ident}: both client styles or one shared body, plus two unchanged controls')
        if row.get('lmx_variants'):
            for error in validate_variants(row,ROOT):check(False,f'{ident}: {error}')
            for position,style in enumerate(['procedural','functional']):
                variant=row['lmx_variants'][style]
                check(fences[position]==('lmx',normalize(variant['code'])),f'{ident}/{style}: exact source/JSON/MD')
                label='процедурный' if style=='procedural' else 'функциональный';m=variant['metrics']
                line=f"| LMX — {label} | {m['characters']} | {m['nonblank_lines']} |"
                check(line in re.sub(r'<[^>]+>','',md).replace('**',''),f'{ident}/{style}: complete source counts')
            check(next(x['code'] for x in row['listings'] if x['language']=='LMX')==row['lmx_variants']['functional']['code'],f'{ident}: legacy listing is only the functional mirror')
        else:
            code=next(x['code'] for x in row['listings'] if x['language']=='LMX')
            check(fences[0]==('lmx',normalize(code)),f'{ident}: one implementation source/MD')
        for offset,listing in enumerate(x for x in row['listings'] if x['language']!='LMX'):
            language=listing['language'];folder,extension,tag=LANG[language];code=normalize(listing['code'])
            check((ROOT/'examples'/folder/(stem+'.'+extension)).read_text()==code,f'{ident}/{language}: exact unchanged source mirror')
            check(fences[variant_count+offset]==(tag,code),f'{ident}/{language}: exact source/MD')
            if row.get('kind')!='implementation':check(not re.search(r'^import (MaybeValue|Bounce|Around|Partial)[ .(]',code,re.M),f'{ident}/{language}: actual language/library client')
        check('Без сложного Throws' not in md and 'without_complex_throws' not in md,f'{ident}: full-source counting only')
    for ident in [91,92,98,99]:check(not by[ident].get('lmx_variants'),f'{ident}: common implementation is not duplicated by style')
    defs=definitions(ROOT.parent/'LMX_Fn_Receivers')
    ledger=json.loads((ROOT/'implementation_dependencies.json').read_text())
    for component in ledger['components']:
        ident=component['id']
        if ident not in [91,92,98,99]:continue
        canonical='\n'.join(defs[n]['code'] for n in component['primary_definitions'])
        actual=next(x['code'] for x in by[ident]['listings'] if x['language']=='LMX')
        check(normalize(canonical)==normalize(actual),f'{ident}: exact current canonical implementation')
    functional=by[84]['lmx_variants']['functional']['code'];procedural=by[84]['lmx_variants']['procedural']['code']
    check('\\bracket(' in functional and 'Around:' not in functional,'084 functional: use shared bracket')
    check(procedural.count('Around:\n')==1 and 'catch: ResourceFailure ()' in procedural,'084 procedural: complete Around and original failure handler')
    check('catch: FxCallFailure (@: error)' in functional and 'sys\\assert' not in functional,'084 functional: closed callback-failure set without handwritten text comparison')
    for style in ['procedural','functional']:
        code=by[84]['lmx_variants'][style]['code']
        check(code.count('Trace\\events := events * 10 + x')==1,'084/'+style+': one shared trace update')
    check('while: n > 0' in by[83]['lmx_variants']['procedural']['code'],'083 procedural: actual iterative parity state')
    check(by[83]['lmx_variants']['functional']['code'].count('return: more(')==1,'083 functional: one shared step body')
    check(' bind half bind half' in by[82]['lmx_variants']['functional']['code'],'082 functional: compact bind chain')
    check('if: result\\present = 0' in by[82]['lmx_variants']['procedural']['code'],'082 procedural: explicit absence branch')
    check('curry(Addition\\apply)' in by[85]['lmx_variants']['functional']['code'],'085 functional: common curry')
    check('CapturePrototype:' in by[85]['lmx_variants']['procedural']['code'],'085 procedural: complete direct capture environment')
    cases=json.loads((ROOT/'acceptance_cases.json').read_text())['cases']
    check(all(c['status']=='NOT_RUN' for c in cases),'acceptance specifications do not claim LMX execution')
    report={'ok':not errors,'checks':len(checks),'errors':errors,'scope':'Dual-style source/JSON/MD integrity and exact common body checks, not parsing or execution.','client_style_pairs':4,'common_implementations':4,'compared_listings':28,'acceptance_cases_prepared':len(cases),'runtime_execution':'NOT_RUN'}
    (ROOT/'validation_2026-11-26.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    (ROOT/'VALIDATION_2026-11-26.md').write_text(
        '# Проверка функциональных сравнений — 26 ноября 2026\n\n'
        +f"Статус: **{'PASS' if not errors else 'FAIL'}**, {len(checks)} проверок. "
        +'Проверены четыре пары полных LMX-стилей, четыре общие реализации, '
        +'равенство исходников/JSON/Markdown и полные метрики. Контрольные Haskell/Scala-листинги сохранены.\n\n'
        +'[Машинный отчёт](validation_2026-11-26.json). Это проверка публикации: '
        +'production P0, транслятор и runtime LMX не запускались. Acceptance cases остаются NOT_RUN.\n'
        + ('\nОшибки:\n\n'+'\n'.join('- '+x for x in errors)+'\n' if errors else ''))
    print(json.dumps(report,ensure_ascii=False));return bool(errors)
if __name__=='__main__':raise SystemExit(main())
