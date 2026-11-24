#!/usr/bin/env python3
"""Publish two complete LMX client styles and single canonical implementations."""
from pathlib import Path
import csv,json,sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parent/'tools'))
from lmx_execution_contract import apply_execution_contract, ensure_startup_note
from lmx_style_variants import normalize,measure,get_variants,write_sources,markdown_variants,validate_variants
LANG={'LMX':('lmx','lm3','lmx'),'Haskell':('haskell','hs','haskell'),'Scala':('scala','scala','scala')}

def stem(row):return f"{row['id']:03d}_{row['slug']}"
def link(row):return f"[{row['id']:03d}. {row['name']}]({stem(row)}_comparision.md)"
def count(code):m=measure(code);return m['characters'],m['nonblank_lines']
def samples(row):
    if row.get('lmx_variants'):
        values=[('LMX — процедурный',v['code']) for s,v in get_variants(row) if s=='procedural']
        values += [('LMX — функциональный',v['code']) for s,v in get_variants(row) if s=='functional']
    else:values=[('LMX — общая реализация',next(x['code'] for x in row['listings'] if x['language']=='LMX'))]
    return values+[(x['language'],x['code']) for x in row['listings'] if x['language']!='LMX']

def render(row,by):
    implementation=row.get('kind')=='implementation'
    lines=[f"# {row['id']:03d}. {row['name']}",row['summary_ru'],'## Общий сценарий',row['scenario_ru'],'**Ожидается:** '+row['expected_ru']]
    if row.get('implementation_ids'):lines += ['Общие реализации: '+', '.join(link(by[n]) for n in row['implementation_ids'])+'. Они учитываются отдельно; иностранные клиенты не импортируют эти сравнительные модули.']
    if row.get('usage_ids'):lines += ['Клиенты: '+', '.join(link(by[n]) for n in row['usage_ids'])+'. Одно тело ядра обслуживает обе формы записи.']
    if row.get('lmx_variants'):
        lines += ['## Граница двух стилей',row['style_note'],markdown_variants(row)]
    else:
        code=next(x['code'] for x in row['listings'] if x['language']=='LMX')
        lines += ['## LMX — единая общая реализация','```lmx\n'+normalize(code)+'```',f'[Исходник](examples/lmx/{stem(row)}.lm3)',row.get('lmx_notes_ru','')]
    for listing in row['listings']:
        language=listing['language']
        if language=='LMX':continue
        folder,extension,tag=LANG[language]
        lines += ['## '+language,'```'+tag+'\n'+normalize(listing['code'])+'```',listing.get('notes_ru',''),f'[Исходник](examples/{folder}/{stem(row)}.{extension})']
    compared=samples(row);minimum=min(measure(code)['characters'] for _,code in compared)
    table=['| Запись | Непробельные символы | Непустые строки |','| --- | ---: | ---: |']
    for label,code in compared:
        chars,lines_count=count(code);value=f'**{chars}**' if chars==minimum else str(chars)
        table += [f'| {label} | {value} | {lines_count} |']
    lines += ['## Подсчёт полного текста','\n'.join(table),
              'Обе LMX-записи сравниваются самостоятельно. Полный текст включает все объявления, локальные helpers и Throws; заголовки и списки ошибок не вычитаются. Общие тела ядра учитываются один раз в отдельных сравнениях. Минимум сопоставимой строки подчёркивается в PDF и XLSX зелёным; при равенстве отмечаются все победители.',
              'Явные Throws и copy списка вызываемого метода сохраняют точный видимый договор отказов. У процедурной записи нет скрытых обходов через map/filter/fold/unique/pipe/bind или поэлементную Array-арифметику.',
              '## Семантические границы',row['limits_ru'],row.get('failure_note','') if isinstance(row.get('failure_note'),str) else '',
              '[Ошибки и Message/post](FAILURE_BOUNDARIES.md). [Общие зависимости](IMPLEMENTATION_DEPENDENCIES.md).',
              '## English explanation',row['summary_en'],'**Scenario.** '+row['scenario_en'],'**Expected.** '+row['expected_en'],'**Limits.** '+row['limits_en'],
              'Both complete LMX client styles are counted in full. Foreign controls retain the same scenario; 085 removes unused and single-use locals consistently across languages. Implementation comparisons retain one canonical body. Revised LMX source has not been executed.',
              '## Источники','\n'.join('- ['+s['title']+']('+s['url']+')' for s in row.get('sources',[])),
              '## Проверка','[Проверка публикации](VALIDATION_2026-11-23.md) проверяет обе записи и зеркала. [Acceptance cases](acceptance_cases.json) — спецификация ожидаемых наблюдений, а не LMX execution receipt.']
    return '\n\n'.join(x for x in lines if x)+'\n'

def main():
    data=apply_execution_contract(json.loads((ROOT/'patterns.json').read_text()));items=data['patterns'];by={r['id']:r for r in items};csvrows=[]
    for row in items:
        if row.get('lmx_variants'):
            write_sources(row,ROOT)
            errors=validate_variants(row,ROOT)
            if errors:raise ValueError((row['id'],errors))
        for listing in row['listings']:
            language=listing['language'];folder,extension,_=LANG[language]
            if language=='LMX' and row.get('lmx_variants'):continue
            (ROOT/'examples'/folder/(stem(row)+'.'+extension)).write_text(normalize(listing['code']))
        (ROOT/(stem(row)+'_comparision.md')).write_text(render(row,by))
        result={'id':row['id'],'pattern':row['name'],'kind':row.get('kind','pattern'),'source':stem(row)+'_comparision.md'}
        for style,variant in get_variants(row):
            result['LMX_'+style+'_characters']=variant['metrics']['characters'];result['LMX_'+style+'_nonblank_lines']=variant['metrics']['nonblank_lines']
        for listing in row['listings']:
            lang=listing['language']
            if lang=='LMX' and row.get('lmx_variants'):continue
            prefix='LMX_implementation' if lang=='LMX' else lang
            result[prefix+'_characters'],result[prefix+'_nonblank_lines']=count(listing['code'])
        csvrows.append(result)
    fields=['id','pattern','kind','source']+[label+'_'+metric for metric in ['characters','nonblank_lines'] for label in ['LMX_procedural','LMX_functional','LMX_implementation','Haskell','Scala']]
    with (ROOT/'LMX_Comparison_09_functional_computation.csv').open('w',encoding='utf-8-sig',newline='') as stream:
        writer=csv.DictWriter(stream,fieldnames=fields);writer.writeheader();writer.writerows(csvrows)
    table=['# Функциональные вычисления: два LMX-стиля','Числа — полный текст без пробельных символов. Все объявления и Throws включены. Общие реализации имеют одну LMX-колонку; они не дублируются ради стиля.','| ID | Задача | LMX процедурный | LMX функциональный | LMX общая реализация | Haskell | Scala |','| --- | --- | ---: | ---: | ---: | ---: | ---: |']
    for row,result in zip(items,csvrows):
        values=[result.get(name+'_characters') for name in ['LMX_procedural','LMX_functional','LMX_implementation','Haskell','Scala']]
        minimum=min(v for v in values if v is not None)
        cells=['—' if v is None else f'**{v}**' if v==minimum else str(v) for v in values]
        table += [f"| {row['id']:03d} | {link(row)} | "+' | '.join(cells)+' |']
    table += ['','[Общие зависимости](IMPLEMENTATION_DEPENDENCIES.md) · [Договор публикации](variant_selection.json) · [Ошибки](FAILURE_BOUNDARIES.md). Runtime LMX: NOT_RUN.']
    (ROOT/'LMX_Comparison_09_functional_computation.md').write_text('\n\n'.join(table[:2])+'\n\n'+'\n'.join(table[2:])+'\n')
    for language,title in [('ru','LMX: Функциональные вычисления'),('en','LMX: Functional computation')]:
        lines=['# '+title,data['rationale_'+language],data['overview_'+language],'## Каталог / Catalog']
        for row in items:lines += ['### '+link(row),row['summary_'+language],row['scenario_'+language],row['expected_'+language]]
        lines += ['## Методика / Method',data['selection_policy'],'[Comparison](LMX_Comparison_09_functional_computation.md) · [Excel](LMX_Comparison_09_functional_computation.xlsx) · [PDF](LMX_Comparison_09_functional_computation.pdf) · [CSV](LMX_Comparison_09_functional_computation.csv)','Runtime LMX: NOT_RUN.']
        (ROOT/f'LMX_Design_Patterns.{language}.md').write_text('\n\n'.join(lines)+'\n')
    (ROOT/'README.md').write_text('# Функциональные вычисления\n\n'+data['overview_ru']+'\n\n[Каталог](LMX_Design_Patterns.ru.md) · [Сравнение](LMX_Comparison_09_functional_computation.md) · [Зависимости](IMPLEMENTATION_DEPENDENCIES.md) · [Ошибки](FAILURE_BOUNDARIES.md)\n\nКлиенты082–085 имеют процедурную и функциональную форму с одним observablecontract. Функциональная запись находится по прежнему пути; procedural — в examples/lmx/procedural. Обе включены в таблицы и считаются полностью. В091/092/098/099 находится одно точное общее тело ядра, без стилевых копий.\n\nHaskell использует Maybe, free, Control.Exception.bracket и обычное применение; Scala — Option, TailCalls, Using.resource и Function2.curried. В 085 удалены неиспользуемая переменная и одноразовое промежуточное имя во всех функциональных клиентах; договор и результат сохранены.\n\nВоспроизведение: sync_receiver_bodies.py → select_shortest.py (теперь сохраняет обе стилевые записи) → regenerate_publication.py → curry_appendix.py → check_publication.py. LMX runtime: NOT_RUN.\n')
    readme=ROOT/'README.md'
    full_metric_note=('Считается полный текст каждой формы: все определения, вспомогательные методы, комментарии внутри листинга, обработчики, имена ошибок и полные ссылки `throws: copy(target\\throws)`. '
                      'Списки берутся из фактически выбранных методов или явно заданного конечного объединения договоров. Статистического удаления аргументов Throws нет. '
                      'В PDF/XLSX зелёным шрифтом и подчёркиванием числа выделяются **все** равные минимумы полного счёта сопоставимой строки; неполные аналогии победителя не получают.')
    readme.write_text(ensure_startup_note(readme.read_text().rstrip()+'\n\n'+full_metric_note+'\n','../../LMX_semantics.en.md#source-entry-profiles'))
    print(json.dumps({'client_pairs':4,'common_implementations':4,'compared_listings':28,'metrics':'full-source only'}))
if __name__=='__main__':main()
