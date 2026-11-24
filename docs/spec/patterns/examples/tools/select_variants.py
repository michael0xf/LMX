#!/usr/bin/env python3
"""Publish both full LMX styles for all24 root scenarios; never select one away."""
from pathlib import Path
import csv,json,os,re,sys
ROOT=Path(__file__).resolve().parents[2];EX=ROOT/'examples'
sys.path.insert(0,str(ROOT/'tools'))
from lmx_style_variants import normalize,measure,get_variants,write_sources,validate_variants
from lmx_execution_contract import apply_execution_contract, ensure_startup_note, startup_note
from guide_supplement import compose_guide


def save(path,value):path.write_text(json.dumps(value,ensure_ascii=False,indent=2)+'\n')
def fence(language,code):return '```'+language+'\n'+normalize(code)+'```'
def table(entry):
    values=[('LMX — процедурный',entry['lmx_variants']['procedural']['metrics']),('LMX — функциональный',entry['lmx_variants']['functional']['metrics'])]
    if entry.get('foreign_code'):values.append(('Haskell'+(' — аналогия' if entry['status']!='complete_pair' else ''),measure(entry['foreign_code'])))
    eligible=values if entry['status']=='complete_pair' else values[:2]
    minimum=min(m['characters'] for _,m in eligible)
    lines=['| Запись | Непробельные символы | Непустые строки |','| --- | ---: | ---: |']
    for label,m in values:
        marked=(label,m) in eligible and m['characters']==minimum
        chars=f"**{m['characters']}**" if marked else str(m['characters'])
        lines.append(f"| {label} | {chars} | {m['nonblank_lines']} |")
    return '\n'.join(lines)


def sections(entry, directory):
    lines=['## Общий договор',entry['contract_notes'],entry['style_note']]
    if entry['style_relation']=='same_minimal_form':
        lines += ['Обоим стилям соответствует одна минимальная форма, необходимая для проверяемого низкоуровневого договора. Её исходник и листинг приведены один раз, значения в обоих столбцах равны. Два разных алгоритма не заявляются.']
    displayed=[('shared',entry['lmx_variants']['functional'])] if entry['style_relation']=='same_minimal_form' else get_variants(entry)
    for style,variant in displayed:
        label='общая минимальная форма обоих стилей' if style=='shared' else 'процедурный' if style=='procedural' else 'функциональный'
        rel=os.path.relpath(EX/variant['source_file'],directory)
        lines += ['## LMX — '+label,fence('lmx',variant['code']),f'[Полный исходник]({rel})']
    if entry.get('foreign_code'):
        lines += ['## Haskell'+(' — связанная аналогия' if entry['status']=='related_analogy' else ''),fence('haskell',entry['foreign_code'])]
    else:lines += ['## Haskell','Сопоставимого существующего листинга для этого договора нет. Новая иностранная реализация не сочиняется; статус остаётся lmx_only.']
    lines += ['## Размер полного текста',table(entry),'Обе LMX-записи учитываются целиком, включая объявления, общие локальные helpers и Throws. Ошибки не исключаются из подсчёта. Общая реализация ядра не размножается ради стилей. Существующий статус иностранной пары/аналогии сохранён.',
              'Runtime LMX: NOT_RUN. Это публикация исходников, договоров и полных размеров, не новый parser/runtime receipt.']
    return lines


def guide_document(entries, expected):
    """Keep the measured sections and all permanent semantic chapters together."""
    guide=['# Примеры LMX и аналоги Haskell: две полные стилевые записи',
        startup_note('../LMX_semantics.en.md#source-entry-profiles'),
        'Все24 исходных сценария сохранены. Для каждого опубликованы процедурная и функциональная LMX-записи одного observablecontract. Ни одна не исключается из сравнения только потому, что другая короче. Все объявления и Throws входят в полный размер.',
        'Функциональная запись находится по прежнему пути lmx/ID.lm3; отличающийся процедурный вариант — в lmx/procedural/ID.lm3. Одинаковые минимальные формы используют один исходник и один Markdown-листинг. Они используют одно ядро. Если проверяемые copy/raw/place/Message-семантики требуют одной минимальной формы, это прямо объясняется и не выдаётся за два разных алгоритма.',
        'Haskell-код и статус complete_pair/related_analogy/lmx_only не изменяются. Частичная аналогия не превращается в полную пару. Зелёный минимум в PDF/XLSX выбирается по полному тексту сопоставимых записей.']
    for entry in entries:
        guide += [f'<a id="{entry["id"].lower()}"></a>\n### {entry["id"]}. {entry["title"]}']+sections(entry,ROOT)
    return compose_guide('\n\n'.join(guide)+'\n',EX,
                         ROOT/'LMX_examples_and_analogies.ru.md',expected['additional_fixtures'])


def main():
    index_path=EX/'haskell/comparison_index.json';index=apply_execution_contract(json.loads(index_path.read_text()));entries=index['entries']
    expected_path=EX/'expected_results.json';expected=apply_execution_contract(json.loads(expected_path.read_text()));cases={x['id']:x for x in expected['source_examples']}
    prior=json.loads((EX/'variants.json').read_text());old={r['id']:r for r in prior['records']}
    records=[];rows=[]
    comparison_dir=EX/'haskell/comparisons';comparison_dir.mkdir(exist_ok=True)
    for entry in entries:
        ident=entry['id'];write_sources(entry,EX);errors=validate_variants(entry,EX)
        if errors:raise ValueError((ident,errors))
        entry['lmx_source']=entry['lmx_variants']['functional']['source_file'];entry['lmx_source_sha256']=entry['lmx_variants']['functional']['metrics']['sha256']
        entry['lmx_style_comparison']='haskell/comparisons/'+ident+'_comparision.md'
        (comparison_dir/(ident+'_comparision.md')).write_text('\n\n'.join(['# '+ident+'. '+entry['title']]+sections(entry,comparison_dir))+'\n')
        c=cases[ident];c['lmx_sources']={s:v['source_file'] for s,v in get_variants(entry)};c['compared_styles']=['procedural','functional'];c['selected_variant']='functional';c['lmx_legacy_role']=entry['lmx_legacy_role']
        c['source_regions']={'functional':'whole functional file','procedural':'whole procedural file'}
        c['style_cases']={s:c.get('cases',[]) for s in ['procedural','functional']}
        c['fairness_note']='Both complete LMX styles preserve the observable contract. All declarations and Throws count; the same existing foreign control/status is used for each.'
        for key in ['alternative_variant','alternative_cases','alternative_load_before','procedural_source_region']:c.pop(key,None)
        base=old.get(ident,{})
        record={k:base[k] for k in ['original_source_sha256_at_import','expected_ru','implementation_comparison','retained_explanation_ru'] if k in base}
        record.update(id=ident,title_ru=entry['title'],selected='functional',alternative=None,
                      eligible_variants=['procedural','functional'],fairness_note=c['fairness_note'],
                      variants=[{'id':s,'label_ru':'Процедурный LMX' if s=='procedural' else 'Функциональный LMX',
                                 'code':v['code'],'metrics':v['metrics'],'correct_for_scenario':True,
                                 'cases':c.get('cases',[]),'load_before':c.get('load_before',[]),'notes_ru':entry['style_note']} for s,v in get_variants(entry)])
        for key in ['lmx_variants','lmx_comparison_variants','lmx_legacy_role','style_relation','style_note']:record[key]=entry[key]
        records.append(record)
        rows.append({'id':ident,'status':entry['status'],'style_relation':entry['style_relation'],
                     'procedural':entry['lmx_variants']['procedural']['metrics'],
                     'functional':entry['lmx_variants']['functional']['metrics'],
                     'foreign':measure(entry['foreign_code']) if entry.get('foreign_code') else None,
                     'foreign_ratio_eligible':entry['status']=='complete_pair'})
    expected['receiver_revision']={
        'date':'2026-11-23','variant_ids':[entry['id'] for entry in entries],
        'rule':'Compare both complete procedural and functional LMX forms for every observable contract. Reuse common implementations and templates; retain all declarations, local helpers and Throws in each full metric. Identical minimal forms share one physical source and one displayed body.',
        'metric_boundary':'Whole source file for each of the two compared styles; no excluded error declarations.',
        'compared_styles':['procedural','functional'],
        'compatibility_mirror':'functional; not an additional compared listing',
        'scenario_cases_preserved':True,'runtime_executed':False}
    save(index_path,index);save(expected_path,expected)
    save(EX/'variants.json',apply_execution_contract({'format':'lmx-dual-style-variants-v1','rule':'Compare both complete styles; no shortest-only selection; foreign controls unchanged.','records':records}))
    target=ROOT/'LMX_examples_and_analogies.ru.md'
    target.write_text(guide_document(entries,expected))
    manifest={'format':'lmx-dual-style-counts-v1','scope':'Both complete style sources including every declaration and Throws; no normalized error column.','source_count':len(rows),'style_listing_count':2*len(rows),'unique_source_count':len({v['source_file'] for e in entries for v in e['lmx_variants'].values()}),'rows':rows,'runtime_executed':False}
    save(EX/'validation/functional_receiver_counts.json',manifest)
    save(EX/'validation/primary_listings.json',{'format':'lmx-style-listings-v1','status':'source_text_not_runtime_receipt','legacy_role':'functional compatibility mirror, not an extra comparison','selected':{e['id']:'functional' for e in entries},'listings':{e['id']:e['lmx_variants']['functional']['code'] for e in entries},'style_listings':{e['id']:{s:v['code'] for s,v in get_variants(e)} for e in entries}})
    tablelines=['# Две стилевые формы исходных24 сценариев','',
        'Каждый сценарий имеет два полных исходника одного договора. Совпадение минимальной формы отмечено явно. Иностранные исходники и статусы сопоставимости сохранены.', '',
        '| ID | Процедурный LMX | Функциональный LMX | Haskell | Статус | Соотношение форм |',
        '| --- | ---: | ---: | ---: | --- | --- |']
    for row in rows:
        tablelines += [f"| [{row['id']}](haskell/comparisons/{row['id']}_comparision.md) | {row['procedural']['characters']} | {row['functional']['characters']} | {row['foreign']['characters'] if row['foreign'] else '—'} | {row['status']} | {row['style_relation']} |"]
    tablelines += ['','Все объявления и Throws входят в цену. Выбор одной основной LMX-записи по краткости больше не применяется. Прежний canonicalpath — только физический путь функционального исходника, а не дополнительная третья запись.','', 'Runtime LMX: NOT_RUN.']
    (EX/'OPTIMIZATION_REVIEW.md').write_text('\n'.join(tablelines)+'\n')
    for name in ['README.md','README.ru.md','haskell/README.md']:
        path=EX/name
        if not path.exists():continue
        text=path.read_text()
        text=text.replace('При равном договоре выбирается кратчайшая полноценная запись; размещение функции в ядре не даёт её клиенту приоритета.','Обе стилевые записи одного договора сравниваются полностью; одна не исключается ради краткости.')
        text=text.replace('Самый короткий полный вариант','Обе полные стилевые записи')
        heading='## Процедурная и функциональная формы'
        rel='../OPTIMIZATION_REVIEW.md' if name.startswith('haskell/') else 'OPTIMIZATION_REVIEW.md'
        # Preserve authored scope/methodology in an existing section. Refreshing
        # metrics does not authorize replacing the all-suite scope with 24 roots.
        if heading not in text:
            text+='\n'+heading+'\n\nВсе24 исходных сценария опубликованы в двух полных LMX-записях с одним договором. [Таблица и ссылки]('+rel+'). Оба текста, включая все Throws, входят в сравнение. Минимальные формы copy/raw/place/Message могут совпадать; для каждого такого случая дано объяснение. Иностранные исходники и статус аналогий не изменяются.\n'
        text=ensure_startup_note(text,os.path.relpath(ROOT.parent/'LMX_semantics.en.md',path.parent)+'#source-entry-profiles')
        path.write_text(text)
    print(json.dumps({'root_scenarios':len(entries),'compared_style_records':2*len(entries),'unique_lmx_sources':len({v['source_file'] for e in entries for v in e['lmx_variants'].values()}),'same_minimal_form':sum(e['style_relation']=='same_minimal_form' for e in entries),'foreign_sources_changed':False}))
if __name__=='__main__':
    if sys.argv[1:]==['--guide-only']:
        entries=json.loads((EX/'haskell/comparison_index.json').read_text())['entries']
        expected=json.loads((EX/'expected_results.json').read_text())
        (ROOT/'LMX_examples_and_analogies.ru.md').write_text(guide_document(entries,expected))
        print(json.dumps({'compared_scenarios':len(entries),
                          'supplementary_fixtures':len(expected['additional_fixtures']),
                          'changed_comparison_sources':False}))
    elif sys.argv[1:]:
        raise SystemExit('usage: select_variants.py [--guide-only]')
    else:
        main()
