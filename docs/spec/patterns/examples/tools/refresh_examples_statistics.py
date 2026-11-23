#!/usr/bin/env python3
"""Recount all current example suites; never treat a partial analogy as a pair."""
from pathlib import Path
from collections import Counter
import csv
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[1]
PATTERNS = ROOT.parent
EDITION = '2026-11-23'

def normalize(code):
    return code.replace('\r\n','\n').replace('\r','\n').strip()+'\n'

def metric(code):
    code = normalize(code)
    return {'characters':sum(not c.isspace() for c in code),
            'characters_with_whitespace':len(code),
            'nonblank_lines':sum(bool(x.strip()) for x in code.splitlines()),
            'utf8_bytes':len(code.encode()),
            'sha256':hashlib.sha256(code.encode()).hexdigest()}

def write_json(path, value):
    path.parent.mkdir(parents=True,exist_ok=True)
    path.write_text(json.dumps(value,ensure_ascii=False,indent=2)+'\n')

def primary(path):
    return normalize(path.read_text().split('# BEGIN ALTERNATIVE LMX (excluded from character counts)')[0])

def main():
    expected = json.loads((ROOT/'expected_results.json').read_text())
    index = json.loads((ROOT/'haskell/comparison_index.json').read_text())
    hs = {x['id']:x for x in index['entries']}
    examples=[]
    implementations=[]
    for item in expected['source_examples']:
        ident=item['id']; details=hs[ident]
        code=primary(ROOT/item['file'])
        foreign=details.get('foreign_code','')
        status=details['status']
        assert status in ('complete_pair','related_analogy','lmx_only'), details
        if status=='complete_pair':assert foreign.strip(),ident
        examples.append({'suite':'haskell','id':ident,'title':details.get('title',ident),
            'foreign_language':'Haskell','comparison_status':status,
            'lmx_source':item['file'],'foreign_source':'haskell/Analogies.hs',
            'lmx':metric(code),'foreign':metric(foreign) if foreign.strip() else None,
            'ratio':metric(foreign)['characters']/metric(code)['characters'] if status=='complete_pair' else None,
            'contract':details.get('contract_notes',''),
            'source_symbols':details.get('source_symbols',[]),
            'runtime':{'LMX':'NOT_RUN','Haskell':'NOT_RUN'}})
    assert len(examples)==24 and len({x['id'] for x in examples})==24
    for suite in ('julia','perl'):
        directory=ROOT/(suite+'_comparison')
        data=json.loads((directory/'examples.json').read_text())
        assert len(data['examples'])>=24, suite
        assert len({x['id'] for x in data['examples']})==len(data['examples']),suite
        for item in data['examples']:
            lm=metric(item['lmx']);fm=metric(item['foreign'])
            examples.append({'suite':suite,'id':item['id'],'title':item['title'],
                'foreign_language':data['foreign_language'],'comparison_status':'complete_pair',
                'lmx_source':f'{suite}_comparison/source/lmx/{item["id"]}.lm3',
                'foreign_source':f'{suite}_comparison/source/{suite}/{item["id"]}.'+('jl' if suite=='julia' else 'pl'),
                'lmx':lm,'foreign':fm,'ratio':fm['characters']/lm['characters'],
                'category':item.get('category',''),'contract':item['contract'],
                'core_functions':item.get('core_functions',[]),
                'foreign_dependencies':item.get('foreign_dependencies',[]),
                'sources':item.get('sources',[]),
                'alternatives':[{k:v for k,v in a.items() if k!='code'}|{'metrics':metric(a['code'])} for a in item.get('alternatives',[])],
                'runtime':{'LMX':'NOT_RUN',data['foreign_language']:'see suite validation'}})
        for item in data.get('implementations',[]):
            implementations.append({'suite':suite,'id':item['id'],'title':item['title'],
                'foreign_language':data['foreign_language'],'core_functions':item.get('core_functions',[]),
                'lmx':metric(item['lmx']),'foreign':metric(item['foreign']),
                'contract':item['contract'],'sources':item.get('sources',[]),
                'source_files':item.get('source_files',[]),'comparison_scope':'implementation_only',
                'dependencies':item.get('implementation_dependencies',item.get('dependencies',[])),
                'production_definitions':item.get('production_definitions',[]),
                'shared_lmx_definitions':item.get('shared_lmx_definitions',[]),
                'external_boundaries':item.get('external_boundaries',[]),
                'imported_by_clients':False})
    previous=json.loads((ROOT/'validation/receiver_library_counts.json').read_text())
    for item in previous['comparisons']:
        implementations.append({'suite':'haskell','id':Path(item['file']).stem.split('_')[0].upper(),
            'title':', '.join(item['public_names']),'foreign_language':'Haskell',
            'core_functions':item['public_names'],'lmx':item['lmx'],'lmx_entry':item['lmx_entry'],
            'foreign':item['haskell'],'source_files':item['source_files'],
            'comparison_file':item['file'],'comparison_scope':'implementation_only',
            'contract':'Complete entry and reachable LMX definitions; complete standalone Haskell module. Shared roots overlap across rows.',
            'imported_by_clients':False})
    # R01 has a native-language record implementation, so its full comparison is a
    # separate source boundary rather than another imported helper module.
    r01=ROOT/'library_comparisons/r01_derive_comparision.md'
    blocks=re.findall(r'```(lmx|haskell)\n(.*?)```',r01.read_text(),re.S)
    if {x[0] for x in blocks}>={'lmx','haskell'}:
        bodies={lang:'\n'.join(code for label,code in blocks if label==lang) for lang in ('lmx','haskell')}
        implementations.append({'suite':'haskell','id':'R01','title':'derive / record composition',
            'foreign_language':'Haskell','core_functions':['derive'],
            'lmx':metric(bodies['lmx']),'foreign':metric(bodies['haskell']),
            'comparison_file':'library_comparisons/r01_derive_comparision.md',
            'comparison_scope':'implementation_only','imported_by_clients':False,
            'contract':'Exact explicitly delimited comparison bodies, including the stated host representation boundary.'})
    summaries=[]
    for suite in ('haskell','julia','perl'):
        rows=[x for x in examples if x['suite']==suite]
        pairs=[x for x in rows if x['comparison_status']=='complete_pair']
        lm=sum(x['lmx']['characters'] for x in pairs)
        fm=sum(x['foreign']['characters'] for x in pairs)
        summaries.append({'suite':suite,'foreign_language':rows[0]['foreign_language'],
            'examples':len(rows),'complete_pairs':len(pairs),
            'related_analogies':sum(x['comparison_status']=='related_analogy' for x in rows),
            'lmx_only':sum(x['comparison_status']=='lmx_only' for x in rows),
            'all_lmx_characters':sum(x['lmx']['characters'] for x in rows),
            'paired_lmx_characters':lm,'paired_foreign_characters':fm,
            'paired_ratio':fm/lm if lm else None,
            'implementation_comparisons':sum(x['suite']==suite for x in implementations)})
    inventory=[]
    for path in sorted(ROOT.rglob('*')):
        if not path.is_file() or path.suffix not in ('.lm3','.lmx','.hs','.jl','.pl','.pm'):continue
        if '__pycache__' in path.parts:continue
        rel=path.relative_to(ROOT).as_posix()
        layer='implementation' if ('libraries/' in rel or 'library_comparisons/' in rel or '/implementation/' in rel) else 'source_or_fixture'
        inventory.append({'file':rel,'layer':layer,'metrics':metric(path.read_text())})
    result={'edition':EDITION,'metric':'nonwhitespace Unicode codepoints, nonblank lines, LF normalized; comments included within the declared source boundary',
        'ratio':'foreign / LMX; computed only for complete pairs; ratios from different suites are not a language ranking',
        'counts':{'lmx_examples':len(examples),'complete_pairs':sum(x['complete_pairs'] for x in summaries),
                  'implementation_comparisons':len(implementations),'source_files':len(inventory)},
        'summaries':summaries,'examples':examples,'implementations':implementations,
        'haskell_module':{'file':'haskell/Analogies.hs','metric':metric((ROOT/'haskell/Analogies.hs').read_text()),
            'scope':'whole source with assertions and shared declarations; not added to per-case totals'},
        'runtime_note':'Source and publication metrics only. LMX runtime is absent. Foreign execution receipts, where available, are stored in suite validation.'}
    write_json(ROOT/'STATISTICS.json',result)
    write_json(ROOT/'SOURCE_INVENTORY.json',{'edition':EDITION,'files':inventory,'sum_is_not_application_size':True})
    with (ROOT/'STATISTICS.csv').open('w',newline='') as out:
        writer=csv.writer(out);writer.writerow(['suite','id','title','status','LMX_characters','foreign_language','foreign_characters','foreign_per_LMX','LMX_nonblank_lines','foreign_nonblank_lines'])
        for x in examples:writer.writerow([x['suite'],x['id'],x['title'],x['comparison_status'],x['lmx']['characters'],x['foreign_language'],x['foreign']['characters'] if x['foreign'] else '',x['ratio'] if x['ratio'] is not None else '',x['lmx']['nonblank_lines'],x['foreign']['nonblank_lines'] if x['foreign'] else ''])
    with (ROOT/'IMPLEMENTATIONS.csv').open('w',newline='') as out:
        writer=csv.writer(out);writer.writerow(['suite','id','title','LMX_characters','foreign_language','foreign_characters','scope'])
        for x in implementations:writer.writerow([x['suite'],x['id'],x['title'],x['lmx']['characters'],x['foreign_language'],x['foreign']['characters'],x['comparison_scope']])
    lines=['# Статистика всей директории examples','',f'Редакция **{EDITION}**. Подсчёт строится из текущих исходников, а не прежних PDF или таблиц.','',
        '## Сопоставимые наборы','',
        '| Набор | Сценариев LMX | Полных пар | Поясняющих аналогий | Только LMX | LMX в полных парах | Контроль в полных парах | Контроль / LMX |',
        '| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |']
    for x in summaries:
        ratio=f'{x["paired_ratio"]:.3f}' if x['paired_ratio'] is not None else '—'
        lines.append(f'| {x["foreign_language"]} | {x["examples"]} | {x["complete_pairs"]} | {x["related_analogies"]} | {x["lmx_only"]} | {x["paired_lmx_characters"]} | {x["paired_foreign_characters"]} | {ratio} |')
    lines.extend(['','Директория содержит '+str(len(examples))+' сценария LMX. Существующие 24 исходника сохранены. '
        'Два новых набора подобраны под характерные задачи Julia и Perl. Их разные составы не дают '
        'основания строить общий рейтинг языков. Неполная аналогия не считается нулевым размером '
        'другого языка и не участвует в отношениях.','',
        '## Основные листинги','',
        '| Набор / ID | Сценарий | Статус | LMX: символы / строки | Контроль: символы / строки | Контроль / LMX |',
        '| --- | --- | --- | ---: | ---: | ---: |'])
    statuses={'complete_pair':'Полная пара','related_analogy':'Поясняющая аналогия','lmx_only':'Только LMX'}
    for x in examples:
        fm=f'{x["foreign"]["characters"]} / {x["foreign"]["nonblank_lines"]}' if x['foreign'] else '—'
        ratio=f'{x["ratio"]:.3f}' if x['ratio'] is not None else '—'
        title=x['title'].replace('|',r'\|')
        lines.append(f'| [{x["suite"]} / {x["id"]}]({x["lmx_source"]}) | {title} | {statuses[x["comparison_status"]]} | {x["lmx"]["characters"]} / {x["lmx"]["nonblank_lines"]} | {fm} | {ratio} |')
    lines.extend(['','## Сравнения реализаций','',
        'Эти размеры не прибавляются к каждому клиенту. Общие зависимости LMX могут встречаться '
        'в нескольких замыканиях; складывать строки этой таблицы как размер одного приложения нельзя. '
        'Клиенты контрольных языков не импортируют сравнительные модули.','',
        '| Набор / ID | Операции | LMX: символы / строки | Контроль: символы / строки |','| --- | --- | ---: | ---: |'])
    for x in implementations:lines.append(f'| {x["suite"]} / {x["id"]} | {x["title"].replace("|", " / ")} | {x["lmx"]["characters"]} / {x["lmx"]["nonblank_lines"]} | {x["foreign"]["characters"]} / {x["foreign"]["nonblank_lines"]} |')
    lines.extend(['','## Метод и воспроизведение','',
        'Основная метрика — непробельные Unicode-символы, включая комментарии внутри явно выбранного '
        'листинга; вторая — непустые строки. Переводы строк нормализуются в LF, внешние пустые строки '
        'удаляются, добавляется один завершающий LF. JSON дополнительно хранит символы с пробелами, '
        'UTF-8-байты и SHA-256. Тестовый harness не маскируется под часть предметной реализации.', '',
        'Отношение равно размеру контрольного листинга, делённому на размер LMX; отношение сумм '
        'считается по одним и тем же полным парам. Это метрика кода, не скорости, памяти или качества языка.', '',
        'Библиотечные операции LMX входят непосредственно в ядро; отдельные реализации сравниваются '
        'по явно указанному общему договору. Полные альтернативы сохраняются только при другом '
        'подходе. Код, убирающий обязательные эффекты, поля или проверки, не выбирается ради краткости.', '',
        'Исходные наборы: [Haskell coverage](haskell/comparison_index.json), '
        '[Julia](julia_comparison/examples.json), [Perl](perl_comparison/examples.json). '
        'Артефакты: [JSON](STATISTICS.json), [CSV](STATISTICS.csv), [XLSX](STATISTICS.xlsx), '
        '[PDF](STATISTICS.pdf), [реестр всех исходников](SOURCE_INVENTORY.json).', '',
        'Команды из корня spec: `python3 patterns/examples/tools/refresh_examples_statistics.py`, '
        'затем генераторы `refresh_examples_pdfs.py` и `refresh_examples_workbooks.mjs` из той же директории. '
        'Для XLSX требуется `@oai/artifact-tool`; путь к примерам задаётся LMX_EXAMPLES_ROOT.', '',
        result['runtime_note'],''])
    (ROOT/'STATISTICS.md').write_text('\n'.join(lines))
    print(json.dumps(result['counts']))

if __name__=='__main__':main()
