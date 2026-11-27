#!/usr/bin/env python3
"""Build full-source comparison tables with both LMX client styles.

The publication model is shared by Markdown, PDF and XLSX renderers. It never
chooses one LMX style by size and never removes any part of a Throws contract.
"""
from __future__ import annotations

import argparse
import csv
import hashlib
import json
from pathlib import Path
import re

from lmx_style_variants import STYLES, measure, validate_variants

ROOT = Path(__file__).resolve().parents[1]
EXAMPLES = ROOT / 'examples'
DATE = '2026-11-27'
LANGUAGES = ['LMX', 'Python', 'Java', 'C++', 'C#', 'TypeScript', 'Go', 'Rust']
STATUS = {'complete_pair':'Полная пара', 'related_analogy':'Аналогия', 'lmx_only':'Только LMX'}
METHOD = (
    'Считаются все непробельные Unicode-символы полного показанного листинга, '
    'включая объявления, локальные вспомогательные методы, комментарии и Throws. '
    'Списки ошибок копируются из вызываемых методов там, где это сохраняет контракт; '
    'текст copy и всех дополнительных отказов входит в размер. '
    'Зелёным подчёркивается минимальное число в сопоставимой строке; при равенстве — все победители.'
)
STYLE_METHOD = (
    'Для функциональных клиентских сценариев опубликованы оба варианта LMX: '
    'процедурный с явным алгоритмом и функциональный с общими операциями и композицией. '
    'Они сохраняют один наблюдаемый договор. Выбор единственного варианта по краткости не производится. '
    'Общие реализации библиотеки учитываются отдельно и не размножаются по стилям.'
)
RUNTIME = ('LMX parser/runtime: NOT_RUN для изменённых листингов. '
           'Проверки исходников и публикации не являются исполнением языка. '
           'Размер кода не измеряет скорость или расход памяти.')


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def edition_label(edition):
    year, month, day = edition.split('-')[:3]
    months = ('января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
              'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря')
    return f'{int(day)} {months[int(month)-1]} {year}'


def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')


def table(title, headers, rows, compare=(), eligible=None, totals=(), widths=None, note=''):
    count = len(rows)
    if eligible is None:
        eligible = [True] * count
    result = {'title':title, 'headers':headers, 'rows':rows, 'comparison_columns':list(compare),
              'eligible_rows':list(eligible), 'note':note,
              'widths':widths or [1.0]*len(headers)}
    if totals:
        picked = [i for i, ok in enumerate(eligible) if ok]
        total = ['Итого'] + [None]*(len(headers)-1)
        for c in totals:
            total[c] = sum(rows[i][c] for i in picked if isinstance(rows[i][c], (int,float)))
        result['total'] = {'values':total, 'columns':list(totals), 'included_rows':picked,
                           'compare':bool(picked)}
    return result


def sheet(name, title, tables, notes=None):
    return {'name':name, 'title':title, 'tables':tables,
            'notes':notes if notes is not None else [METHOD, RUNTIME]}


def document(stem, title, sheets):
    return {'stem':stem, 'title':title, 'edition':DATE, 'sheets':sheets}


def variant_metrics(record, directory, errors):
    errors.extend(f"{record.get('id')}: {message}" for message in validate_variants(record, directory))
    return {style:measure(record['lmx_variants'][style]['code']) for style in STYLES}


def case_table(rows, language, title='Прикладные сценарии'):
    cells=[]; eligible=[]
    for case in rows:
        cells.append([case['id'],case['title'],case['lmx_variants']['procedural']['characters'],
                      case['lmx_variants']['functional']['characters'],
                      case['foreign']['characters'] if case['foreign'] else None,
                      STATUS[case['comparison_status']]])
        eligible.append(case['comparison_status']=='complete_pair')
    return table(title,['ID','Сценарий','LMX\nпроцедурный','LMX\nфункциональный',language,'Граница'],
                 cells,[2,3,4],eligible,[2,3,4],[.55,3.8,1.05,1.05,1.05,1.15],
                 'Итоги включают только полные пары. Аналогии и отсутствие контрольного листинга не считаются нулём.')


def implementation_table(rows, all_suites=False):
    cells=[]
    for row in rows:
        cells.append([(row['foreign_language']+' / ' if all_suites else '')+row['id'],row['title'],
                      row['lmx']['characters'],row['foreign']['characters']])
    return table('Общие реализации библиотеки', ['Набор / ID' if all_suites else 'ID','Операции','LMX — реализация','Контроль'],
                 cells,[2,3],widths=[1.25,4.5,1.15,1.15],
                 note='Полные указанные тела сравниваются отдельно от клиентов. Пересекающиеся зависимости нельзя складывать повторно.')


def build():
    errors=[]; docs=[]; groups=[]; all_cases=[]
    for path in sorted(ROOT.glob('[0-9][0-9]_*/patterns.json')):
        data=read(path); directory=path.parent
        records=sorted(data['patterns'],key=lambda p:(p.get('paired_with',p['id']),p.get('kind')=='implementation',p['id']))
        clients=[]; implementations=[]; ordinary=[]; layer_records=[]
        foreign=data['languages']
        if data.get('language_pairing') == 'per_record' or data.get('language_pairs_scope'):
            paired_rows=[]; layer_records=[]
            for record in records:
                pair=record['languages']
                if len(pair)!=2:
                    raise ValueError(f"{directory.name}/{record['id']}: exactly two control languages required")
                metrics={listing['language']:measure(listing['code']) for listing in record['listings']}
                styles=variant_metrics(record,directory,errors)
                paired_rows.append([f"{record['id']:03d}", record['name'],
                                    styles['procedural']['characters'], styles['functional']['characters'],
                                    pair[0], metrics[pair[0]]['characters'], pair[1], metrics[pair[1]]['characters']])
                layer_records.append({'id':record['id'],'role':'Сценарий','metrics':metrics,
                                      'lmx_variants':styles,'languages':pair})
                all_cases.append({'suite':directory.name,'id':f"{record['id']:03d}",'title':record['name'],
                                  'lmx_variants':styles,'foreign':{lang:metrics[lang] for lang in pair},
                                  'comparison_status':'complete_pair'})
            tabs=[table('Два стиля LMX и пара языков для каждого сценария',
                        ['ID','Сценарий','LMX\nпроцедурный','LMX\nфункциональный','Язык 1','Символы','Язык 2','Символы'],
                        paired_rows,[2,3,5,7],widths=[.5,3.6,1.1,1.1,1,1,1,1])]
            notes=[data.get('rationale_ru',''),data.get('overview_ru',''),STYLE_METHOD,METHOD,RUNTIME]
            stem=f'{directory.name}/LMX_Comparison_{directory.name}'
            docs.append(document(stem,data['group_title_ru'],[sheet('Сравнение',data['group_title_ru'],tabs,notes)]))
            groups.append({'directory':directory.name,'title':data['group_title_ru'],'languages':foreign,
                           'language_pairing':'per_record','records':layer_records})
            continue
        for record in records:
            metrics={listing['language']:measure(listing['code']) for listing in record['listings']}
            kind='implementation' if record.get('kind')=='implementation' else 'client'
            role=('Реализация' if kind=='implementation' else
                  'Общий клиент' if record.get('comparison_level')=='shared_implementation_client' else
                  'Клиент' if record.get('implementation_ids') else 'Сценарий')
            layer_records.append({'id':record['id'],'role':role,'metrics':metrics})
            if record.get('lmx_variants'):
                styles=variant_metrics(record,directory,errors)
                clients.append([f"{record['id']:03d}",record['name'],styles['procedural']['characters'],
                                styles['functional']['characters'],*[metrics[l]['characters'] for l in foreign]])
                all_cases.append({'suite':'functional','id':f"{record['id']:03d}",'title':record['name'],
                                  'lmx_variants':styles,'foreign':{l:metrics[l] for l in foreign},
                                  'comparison_status':'complete_pair'})
                layer_records[-1]['lmx_variants']=styles
            elif directory.name=='09_functional_computation' and kind=='client':
                errors.append(f"{directory.name}/{record['id']}: missing both LMX styles")
            elif directory.name=='09_functional_computation':
                implementations.append([f"{record['id']:03d}",record['name'],metrics['LMX']['characters'],
                                        *[metrics[l]['characters'] for l in foreign]])
            else:
                ordinary.append([f"{record['id']:03d}",record['name'],metrics['LMX']['characters'],
                                 *[metrics[l]['characters'] for l in foreign],role])
        tables=[]
        if ordinary:
            tables.append(table('Сравнения',['ID','Сценарий','LMX',*foreign,'Слой'],ordinary,[2,3,4],
                                widths=[.5,3.6,1,1,1,1.2]))
        if clients:
            tables.append(table('Два стиля LMX: один договор',['ID','Сценарий','LMX\nпроцедурный','LMX\nфункциональный',*foreign],
                                clients,[2,3,4,5],totals=[2,3,4,5],widths=[.5,3.5,1.1,1.1,1,1]))
        if implementations:
            tables.append(table('Общие реализации библиотеки',['ID','Компонент','LMX — реализация',*foreign],
                                implementations,[2,3,4],widths=[.5,3.7,1.2,1,1]))
        notes=[data.get('rationale_ru',''), data.get('overview_ru','')]
        if clients: notes.append(STYLE_METHOD)
        notes.extend([METHOD,RUNTIME])
        stem=f'{directory.name}/LMX_Comparison_{directory.name}'
        docs.append(document(stem,data['group_title_ru'],[sheet('Сравнение',data['group_title_ru'],tables,notes)]))
        groups.append({'directory':directory.name,'title':data['group_title_ru'],'languages':foreign,'records':layer_records})

    gof_stats=read(ROOT/'validation/gof_statistics_20261122.json')
    gof_rows=gof_stats['records']
    for stem, name, first,last in [('LMX_Comparison_2026-11-20','Сравнение',1,9),
                                  ('LMX_Comparison_10-18','Шаблоны 10–18',10,18),
                                  ('LMX_Comparison_19-23','Шаблоны 19–23',19,23)]:
        chosen=[row for row in gof_rows if first<=row['id']<=last]
        values=[[str(row['id']).zfill(2),row.get('title',row.get('name',row.get('file',''))),
                 *[row['metrics'][lang]['characters'] for lang in LANGUAGES]] for row in chosen]
        tab=table(f'Паттерны {first}–{last}',['ID','Сценарий',*LANGUAGES],values,list(range(2,10)),
                  totals=list(range(2,10)),widths=[.4,3,1,1,1,1,1,1.2,1,1])
        docs.append(document(stem,f'LMX: паттерны {first}–{last}',[sheet(name,f'LMX: паттерны {first}–{last}',[tab])]))

    suite_cases={}; suite_labels={'haskell':'Haskell','julia':'Julia','perl':'Perl','sbcl':'Common Lisp (SBCL)'}
    haskell=read(EXAMPLES/'haskell_comparision/comparison_index.json')
    for entry in haskell['entries']:
        styles=variant_metrics(entry,EXAMPLES,errors)
        case={'suite':'haskell','id':entry['id'],'title':entry['title'],
              'lmx_variants':styles,'foreign':measure(entry.get('foreign_measurement_code',entry['foreign_code'])) if entry.get('foreign_code','').strip() else None,
              'comparison_status':entry['status'],'style_relation':entry.get('style_relation'),
              'style_note':entry.get('style_note','')}
        suite_cases.setdefault('haskell',[]).append(case)
    for suite,dirname in [('julia','julia_comparison'),('perl','perl_comparison'),('sbcl','SBCL_comparison')]:
        source=read(EXAMPLES/dirname/'examples.json')
        suite_cases[suite]=[]
        for entry in source['examples']:
            styles=variant_metrics(entry,EXAMPLES/dirname,errors)
            case={'suite':suite,'id':entry['id'],'title':entry['title'],'lmx_variants':styles,
                  'foreign':measure(entry['foreign']) if entry.get('foreign','').strip() else None,
                  'comparison_status':entry.get('comparison_status','complete_pair'),
                  'style_relation':entry.get('style_relation'),'style_note':entry.get('style_note','')}
            suite_cases[suite].append(case)
    for cases in suite_cases.values(): all_cases.extend(cases)
    implementations=read(EXAMPLES/'STATISTICS.json')['implementations']
    summaries=[]
    for suite,cases in suite_cases.items():
        paired=[c for c in cases if c['comparison_status']=='complete_pair']
        summaries.append({'suite':suite,'language':suite_labels[suite],'cases':len(cases),'paired':len(paired),
                          'procedural':sum(c['lmx_variants']['procedural']['characters'] for c in paired),
                          'functional':sum(c['lmx_variants']['functional']['characters'] for c in paired),
                          'foreign':sum(c['foreign']['characters'] for c in paired)})
    overview=table('Итоги полных пар',['Набор','Сценарии','Полные пары','LMX\nпроцедурный','LMX\nфункциональный','Контроль'],
                   [[r['language'],r['cases'],r['paired'],r['procedural'],r['functional'],r['foreign']] for r in summaries],
                   [3,4,5],widths=[2.1,.9,1,1.3,1.3,1.3],
                   note='Разные наборы не образуют общий рейтинг языков. Для каждой полной пары показаны оба стиля LMX.')
    example_sheets=[sheet('Обзор','LMX: все примеры',[overview],[STYLE_METHOD,METHOD,RUNTIME])]
    for suite,cases in suite_cases.items():
        example_sheets.append(sheet({'haskell':'Haskell','julia':'Julia','perl':'Perl','sbcl':'SBCL'}[suite],
                                    'LMX / '+suite_labels[suite],[case_table(cases,suite_labels[suite])],[STYLE_METHOD,METHOD,RUNTIME]))
    example_sheets.append(sheet('Реализации','Общие реализации',[implementation_table(implementations,True)]))
    # Preserve the sheet order of the supplied workbook, including its SBCL tab.
    existing_order=['Обзор','Haskell','Julia','Perl','Реализации','SBCL']
    example_sheets.sort(key=lambda view:existing_order.index(view['name']))
    docs.append(document('examples/STATISTICS','LMX: все примеры',example_sheets))
    for suite,dirname,label in [('haskell','haskell_comparision','Haskell'),('julia','julia_comparison','Julia'),('perl','perl_comparison','Perl'),('sbcl','SBCL_comparison','SBCL')]:
        cases=suite_cases[suite]
        shname='Сравнения' if suite=='sbcl' else 'Примеры'
        docs.append(document(f'examples/{dirname}/LMX_Comparison_{label}', 'LMX / '+suite_labels[suite],
                             [sheet(shname,'LMX / '+suite_labels[suite],[case_table(cases,suite_labels[suite])],[STYLE_METHOD,METHOD,RUNTIME]),
                              sheet('Реализации','Общие реализации',[implementation_table([r for r in implementations if r['suite']==suite])])]))

    summary_rows=[]; functional_clients=[]; functional_implementations=[]
    for group in groups:
        if group.get('language_pairing')=='per_record':
            pairs=list(dict.fromkeys(tuple(entry['languages']) for entry in group['records']))
            for first,second in pairs:
                subset=[e for e in group['records'] if e['languages']==[first,second]]
                summary_rows.append([group['title'],'Сценарии',len(subset),None,
                                     sum(e['lmx_variants']['procedural']['characters'] for e in subset),
                                     sum(e['lmx_variants']['functional']['characters'] for e in subset),
                                     first,sum(e['metrics'][first]['characters'] for e in subset),
                                     second,sum(e['metrics'][second]['characters'] for e in subset)])
            continue
        if group['directory']=='09_functional_computation':
            for entry in group['records']:
                if entry.get('lmx_variants'):
                    functional_clients.append([str(entry['id']),entry['lmx_variants']['procedural']['characters'],
                                               entry['lmx_variants']['functional']['characters'],
                                               *[entry['metrics'][l]['characters'] for l in group['languages']]])
                else:
                    functional_implementations.append([str(entry['id']),entry['metrics']['LMX']['characters'],
                                                       *[entry['metrics'][l]['characters'] for l in group['languages']]])
            continue
        for role in dict.fromkeys(e['role'] for e in group['records']):
            subset=[e for e in group['records'] if e['role']==role]
            first,second=group['languages']
            summary_rows.append([group['title'],role,len(subset),sum(e['metrics']['LMX']['characters'] for e in subset),None,None,
                                 first,sum(e['metrics'][first]['characters'] for e in subset),
                                 second,sum(e['metrics'][second]['characters'] for e in subset)])
    group_tables=[table('Группы сравнений',['Группа','Слой','Число','LMX','LMX\nпроцедурный','LMX\nфункциональный','Контроль 1','Символы','Контроль 2','Символы'],
                        summary_rows,[3,4,5,7,9],widths=[3.2,1.3,.7,.8,1.1,1.1,1,.8,1,.8]),
                  table('Функциональные клиенты',['ID','LMX процедурный','LMX функциональный','Haskell','Scala'],
                        functional_clients,[1,2,3,4],totals=[1,2,3,4],widths=[.5,2,2,1.5,1.5]),
                  table('Функциональные реализации',['ID','LMX — реализация','Haskell','Scala'],
                        functional_implementations,[1,2,3],widths=[.5,2.5,2,2])]
    gof_totals=[sum(row['metrics'][lang]['characters'] for row in gof_rows) for lang in LANGUAGES]
    gof_table=table('23 сравнения GoF',['Подборка',*LANGUAGES],[['23 сценария',*gof_totals]],list(range(1,9)),widths=[2]+[1]*8)
    style_rows=[[case['id'],case['lmx_variants']['procedural']['characters'],case['lmx_variants']['functional']['characters'],
                 'Одна минимальная форма' if case.get('style_relation')=='same_minimal_form' else 'Два алгоритмических подхода',
                 case.get('style_note','')] for case in suite_cases['haskell']]
    style_table=table('Договор стилевой пары',['ID','LMX процедурный','LMX функциональный','Отношение','Пояснение'],
                      style_rows,[1,2],widths=[.5,1.1,1.1,2.5,4])
    docs.append(document('STATISTICS_2026-11-22','LMX: сводная статистика',
                         [sheet('Группы','Группы сравнений',group_tables,[STYLE_METHOD,METHOD,RUNTIME]),
                          sheet('Примеры','Исходные 24 сценария',[case_table(suite_cases['haskell'],'Haskell')],[STYLE_METHOD,METHOD,RUNTIME]),
                          sheet('GoF','Исходная подборка GoF',[gof_table]),
                          sheet('Варианты','Два стиля LMX',[style_table],[STYLE_METHOD,METHOD,RUNTIME])]))
    return {'edition':DATE,'metric':'Full nonwhitespace Unicode source; all declarations and Throws included',
            'style_policy':STYLE_METHOD,'winner_policy':'Green underline on every equal minimum among comparable full listings',
            'lmx_style_clients':len(all_cases),'lmx_style_listings':2*len(all_cases),
            'groups':groups,'suite_summaries':summaries,'cases':all_cases,
            'documents':docs,'mirrors':[{'source':'examples/STATISTICS','target':'examples/LMX_Examples_Statistics_2026-11-23'}],
            'errors':errors,'lmx_parser_execution':'NOT_RUN','lmx_runtime_execution':'NOT_RUN'}


def md_table(tab):
    headers=[h.replace('\n',' ') for h in tab['headers']]
    out=['| '+' | '.join(headers)+' |','| '+' | '.join('---' for _ in headers)+' |']
    rows=list(zip(tab['rows'],tab['eligible_rows']))
    if tab.get('total'): rows.append((tab['total']['values'],tab['total']['compare']))
    for row,eligible in rows:
        numbers=[row[i] for i in tab['comparison_columns'] if isinstance(row[i],(int,float))]
        minimum=min(numbers) if eligible and numbers else None
        cells=[]
        for i,value in enumerate(row):
            cell='—' if value is None else str(value).replace('|','\\|').replace('\n',' ')
            if minimum is not None and i in tab['comparison_columns'] and value==minimum:
                cell=f'<span style="color:#176233"><u>{cell}</u></span>'
            cells.append(cell)
        out.append('| '+' | '.join(cells)+' |')
    return '\n'.join(out)


def publish_text(model, selected_stems=None):
    for doc in model['documents']:
        if selected_stems is not None and doc['stem'] not in selected_stems:
            continue
        # Suite-specific narrative/source comparisons belong to their own builders.
        # Only publication summary tables are emitted here.
        target=ROOT/(doc['stem']+'.md')
        lines=['# '+doc['title'],f"Редакция {edition_label(doc['edition'])} года. Полные размеры листингов."]
        for view in doc['sheets']:
            lines.extend(['## '+view['title']])
            for tab in view['tables']:
                lines.extend(['### '+tab['title'],md_table(tab)])
                if tab['note']: lines.append(tab['note'])
            lines.extend(note for note in view['notes'] if note)
        lines.append('Одинаковые числовые данные используются в Markdown, PDF и XLSX. '
                     'Машинный источник — PUBLICATION_DATA.json в корне каталога patterns; '
                     'генератор — tools/build_publication_data.py.')
        target.write_text('\n\n'.join(lines)+'\n',encoding='utf-8')
        # Per-suite/group CSV schemas are maintained with their source generators.
        # The two cross-suite summaries contain explicit section headers.
        if doc['stem'] not in {'STATISTICS_2026-11-22', 'examples/STATISTICS'}:
            continue
        csv_path=ROOT/(doc['stem']+'.csv')
        with csv_path.open('w',encoding='utf-8-sig',newline='') as stream:
            writer=csv.writer(stream)
            for view in doc['sheets']:
                for tab in view['tables']:
                    writer.writerow([view['title']+' — '+tab['title']])
                    writer.writerow([h.replace('\n',' ') for h in tab['headers']])
                    writer.writerows(tab['rows'])
                    if tab.get('total'): writer.writerow(tab['total']['values'])
                    writer.writerow([])


def retain_document_editions(model, previous):
    """Keep publication dates when every published field is unchanged."""
    previous_docs = {doc['stem']: doc for doc in previous.get('documents', [])}
    def payload(doc):
        return {key: value for key, value in doc.items() if key != 'edition'}
    changed_stems = set()
    for doc in model['documents']:
        old = previous_docs.get(doc['stem'])
        if old is not None and payload(doc) == payload(old):
            doc['edition'] = old.get('edition', previous.get('edition', DATE))
        else:
            changed_stems.add(doc['stem'])
    return changed_stems


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--text',action='store_true',help='Also write the publication Markdown/CSV summaries')
    parser.add_argument('--changed-only',action='store_true',help='Write text summaries only when their published payload changes')
    args=parser.parse_args()
    model=build()
    if model['errors']:
        print(json.dumps({'status':'FAIL','errors':model['errors']},ensure_ascii=False,indent=2))
        return 1
    expected_suite_clients=24+sum(read(EXAMPLES/name/'examples.json').get('expected_client_count',24)
                                 for name in ('julia_comparison','perl_comparison','SBCL_comparison'))
    expected_clients=expected_suite_clients+sum(bool(record.get('lmx_variants'))
                            for path in ROOT.glob('[0-9][0-9]_*/patterns.json')
                            for record in read(path)['patterns'])
    if model['lmx_style_clients']!=expected_clients:
        raise ValueError('Publication lost one or more declared style pairs')
    previous_path=ROOT/'PUBLICATION_DATA.json'
    previous=read(previous_path) if previous_path.is_file() else {'documents':[]}
    changed_stems=retain_document_editions(model,previous)
    write(ROOT/'PUBLICATION_DATA.json',model)
    if args.text: publish_text(model,changed_stems if args.changed_only else None)
    print(json.dumps({'status':'PASS','documents':len(model['documents']),'mirrors':len(model['mirrors']),
                      'client_scenarios':model['lmx_style_clients'],'lmx_style_listings':model['lmx_style_listings'],
                      'changed_documents':len(changed_stems)},ensure_ascii=False))
    return 0


if __name__=='__main__':
    raise SystemExit(main())
