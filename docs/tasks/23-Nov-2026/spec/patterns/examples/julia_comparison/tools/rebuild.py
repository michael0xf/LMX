#!/usr/bin/env python3
"""Пересобрать источники/MD/метрики Julia suite; LMX и Julia не исполняются."""
import sys
sys.dont_write_bytecode = True
from pathlib import Path
import csv, hashlib, json, re, shutil
R = Path(__file__).resolve().parents[1]
LIB = R.parents[1] / 'LMX_Fn_Receivers'
EDITION = '2026-11-23'
COMPONENTS = [
 ('JI01','Упорядоченные обходы, предикаты и свёртки','JI01_ordered.jl',
  ['map','filter','foldl','scanl','zip','zipWith','flatMap','any','all','index','count','record'],
  ['FxMap','FxFilter','FxFold','FxScan','FxPair','FxZip','FxZipWith','FxListBind','FxSeqFlatMap','FxSeqAny','FxSeqAll','FxSeqIndex','FxSeqCount','FxRecordOperands','FxMaybe','FxSome','FxNone'],
  'Конечные последовательности, произвольные типы полезных значений, упорядоченные callbacks в одной Message. map/flatMap/scan/zip возвращают записи значений; filter сохраняет исходный профиль. Предикаты возвращают int LMX, Bool/Int Julia. Ошибка callback распространяется; callback не изменяет входную последовательность. Частичный результат не выдаётся. index различает отсутствие и индекс 0. record сохраняет принятое значение, а не копирует граф.',
  ['https://docs.julialang.org/en/v1/base/collections/','https://docs.julialang.org/en/v1/base/iterators/','https://docs.julialang.org/en/v1/base/arrays/'],[]),
 ('JI02','Границы, маски и устройство массивов','JI02_arrays.jl',
  ['range','slice','reverse','compress','concat','transpose'],
  ['FxSeqRange','FxSeqSlice','FxSeqReverse','FxSeqCompress','FxSeqConcat','FxTranspose'],
  'Полные конечные одномерные массивы и прямоугольные массивы строк. Диапазоны и срезы полуоткрыты и используют нулевые позиции. Предусмотрены пустые входы, отрицательный шаг, отказ на нулевом шаге, проверка размеров и несовместимой формы. Копируются внешние позиции, ссылочные цели сохраняются. concat не делает рекурсивного flatten. Julia reference принимает обычные one-based AbstractVector, а не все возможные AbstractArray/OffsetArray.',
  ['https://docs.julialang.org/en/v1/base/arrays/','https://docs.julialang.org/en/v1/base/collections/'],[]),
 ('JI03','Изменение диапазона с сохранением target','JI03_mutation.jl',
  ['append','splice','replaceRange'],['FxSeqReplaceRange','FxSeqSplice','FxSeqAppend'],
  'Один общий алгоритм replaceRange, splice возвращает удалённые элементы, append возвращает исходный target. Обе reference-реализации полностью подготавливают вставку до первой записи, в том числе при перекрытии. Обычное принятие типа и исчерпание ресурсов остаются правилами respective runtime; обещания общей транзакции нет. Сравнение клиентов J17/J18 ограничено совместимыми неперекрывающимися входами, поскольку Base.splice! предупреждает о разделяемой памяти.',
  ['https://docs.julialang.org/en/v1/base/collections/'],['JI02']),
 ('JI04','Сортировка, уникальность и группировка','JI04_order_group.jl',
  ['sort','unique','groupBy'],['FxSort','FxUnique','FxGroup','FxGroupBy'],
  'Общие типы элементов и ключей. Устойчивая bottom-up merge sort с целочисленным трёхсторонним comparator; unique оставляет первое появление по явному равенству; groupBy вызывает keyOf один раз на элемент и сохраняет порядок внутри групп. Пустые входы и неверные ответы comparator/predicate обработаны. Источник и ключи callbacks не меняют. Generic unique/groupBy используют поиск без hash; их асимптотика не приравнивается к оптимизированным Base.unique/SplitApplyCombine.group.',
  ['https://docs.julialang.org/en/v1/base/sort/','https://docs.julialang.org/en/v1/base/collections/','https://github.com/JuliaData/SplitApplyCombine.jl#grouping'],['JI01'])
]
def canonical(code): return code.strip() + '\n'
def metrics(code):
    return {'characters_with_whitespace':len(code),'characters_without_whitespace':sum(not c.isspace() for c in code),'nonblank_lines':sum(bool(x.strip()) for x in code.splitlines()),'utf8_bytes':len(code.encode('utf-8'))}
def sha(code): return hashlib.sha256(code.encode()).hexdigest()
def write_json(path, value): path.write_text(json.dumps(value,ensure_ascii=False,indent=2)+'\n')
def production():
    found={}
    for path in sorted((LIB/'src').rglob('*.lmx')):
        code=path.read_text()
        for part in code.split('\n\n'):
            match=re.search(r'^((?:Fx|Rx)[A-Za-z0-9_]+):[^\n]*\n',part,re.M)
            if match:
                name=match[1]
                if name in found: raise ValueError('Повтор определения: '+name)
                found[name]={'code':canonical(part[match.start():]),'source':path.relative_to(LIB).as_posix()}
    return found

def refs(code):
    code='\n'.join(line for line in code.splitlines() if not line.lstrip().startswith('#'))
    return set(re.findall(r'\b((?:Fx|Rx)[A-Za-z0-9_]+)(?=\\|@)',code)) | set(re.findall(r'copy\(((?:Fx|Rx)[A-Za-z0-9_]+)\)',code))
def closure(names, available):
    result=set(); external=set(); stack=list(names)
    while stack:
        name=stack.pop()
        if name in result: continue
        if name not in available:
            external.add(name); continue
        result.add(name)
        if name != 'FxThrows': stack.extend(refs(available[name]['code'])-result)
    return result,external

def main():
    data=json.loads((R/'examples.json').read_text())
    available=production(); implementations=[]; mapping={}; all_defs=set(); primary_defs=set(); ledger=[]
    for ident,title,filename,names,owners,contract,sources,dependencies in COMPONENTS:
        missing=set(owners)-set(available)
        if missing: raise ValueError(f'{ident}: {missing}')
        lmx='\n'.join(available[x]['code'] for x in owners)
        foreign=canonical((R/'library_comparisons'/filename).read_text())
        source=f'library_comparisons/{ident}.lmx'
        (R/source).write_text(lmx)
        needed,external=closure(owners,available)
        all_defs|=needed; primary_defs.update(owners)
        rec={'id':ident,'title':title,'core_functions':names,'lmx':lmx,'foreign':foreign,'contract':contract,'sources':sources,
             'source_files':{'lmx':source,'foreign':'library_comparisons/'+filename},
             'implementation_dependencies':dependencies,'production_definitions':[{'name':x,'source':'../../LMX_Fn_Receivers/'+available[x]['source'],'sha256':sha(available[x]['code'])} for x in owners],
             'shared_lmx_definitions':sorted(needed-set(owners)),'external_boundaries':sorted(external),'complete_with_declared_dependencies':True,'runtime_execution':'NOT_RUN'}
        implementations.append(rec)
        ledger.append({'id':ident,'primary_definitions':owners,'all_definitions':sorted(needed),'external_boundaries':sorted(external),
                       'primary':metrics(lmx),'shared':metrics('\n'.join(available[x]['code'] for x in sorted(needed-set(owners))))})
        for name in names: mapping[name]=f'library_comparisons/{ident}_comparision.md'
    data['implementations']=implementations
    data['core_additions']=[]
    data['shared_existing_additions']=['sort','unique']
    shared=all_defs-primary_defs
    shared_code='\n'.join(available[x]['code'] for x in sorted(shared))
    (R/'library_comparisons/shared_dependencies.lmx').write_text(shared_code)
    dep_report={'edition':EDITION,'component_dependencies':ledger,'definitions':[{'name':x,'source':'../../LMX_Fn_Receivers/'+available[x]['source'],'sha256':sha(available[x]['code']),**metrics(available[x]['code'])} for x in sorted(all_defs)],'unique_definitions':len(all_defs),'unique_lmx_total':metrics('\n'.join(available[x]['code'] for x in sorted(all_defs))),'shared_not_in_primary':metrics(shared_code),'runtime_implementation_measured':False,'note_ru':'Тела алгоритмов и общие тела сохранены полностью; FxKernel и sys являются существующими интеграционными границами, не выдуманной реализацией нулевого размера.'}
    write_json(R/'validation/implementation_dependencies.json',dep_report)
    rows=[]; checks=[]
    expected_ids=[f'J{i:02}' for i in range(1,25)]
    assert [e['id'] for e in data['examples']]==expected_ids
    for e in data['examples']:
        # These contracts are shared with the production module, not narrowed.
        if e['id']=='J20':
            e['lmx']=e['lmx'].replace('throws: copy(FxThrows\\traversal)','throws: FxCallFailure FxKernelFailure FxTypeToken ReceiverIndex SequenceElement SequenceSize')
            e['notes_ru']='Устойчивость наблюдается по id, поэтому поле id присутствует и во входе, и в ожидаемом результате. Используется общий FxSort из corePerlExamples; нового Julia-специфичного ресивера нет.'
        if e['id']=='J21':
            e['lmx']=e['lmx'].replace('throws: copy(FxThrows\\traversal)','throws: FxCallFailure FxKernelFailure FxPredicate FxTypeToken ReceiverIndex SequenceElement SequenceSize')
        e['implementation_links']={name:mapping[name] for name in e['core_functions']}
        e['lmx']=canonical(e['lmx']); e['foreign']=canonical(e['foreign'])
        for language,key in [('LMX','lmx'),('Julia','foreign')]:
            path=R/e['source_files'][key]; path.write_text(e[key]);
            rows.append({'id':e['id'],'role':'client','language':language,'title':e['title'],**metrics(e[key])})
            checks.append({'id':e['id'],'language':language,'source':e['source_files'][key],'sha256':sha(e[key]),'status':'PASS','check':'source_json_equal'})
        assert not re.search(r'Julia(?:Ordered|Array|Mutation|OrderGroup)Reference|include\(|library_comparisons',e['foreign'])
        table='| Язык | Без пробельных символов | Непустые строки | Все Unicode-символы |\n| --- | ---: | ---: | ---: |'
        for row in rows[-2:]: table+=f"\n| {row['language']} | {row['characters_without_whitespace']} | {row['nonblank_lines']} | {row['characters_with_whitespace']} |"
        links='\n'.join(f'- `{name}`: [полная пара реализации]({link})' for name,link in e['implementation_links'].items())
        sources='\n'.join(f'- [{url}]({url})' for url in e['sources'])
        md=f"# {e['id']}. {e['title']}\n\n## Общий договор\n\n{e['contract']}\n\n{e['notes_ru']}\n\nВход:\n\n```json\n{json.dumps(e['inputs'],ensure_ascii=False,indent=2)}\n```\n\nОжидаемое наблюдение:\n\n```json\n{json.dumps(e['expected'],ensure_ascii=False,indent=2)}\n```\n\n## LMX\n\n```lmx\n{e['lmx']}```\n\n## Julia\n\n```julia\n{e['foreign']}```\n\n## Размер полного клиента\n\n{table}\n\n## Реализации использованного ядра\n\n{links}\n\nJulia-клиент использует реальные Base/пакет; реализации из library_comparisons он не импортирует. [Общие зависимости и границы](library_comparisons/README.md) учитываются отдельно. Код проверен как текст и по договорам; исполнение LMX/Julia здесь не заявлено.\n\n## Первичные источники\n\n{sources}\n"
        (R/(e['id']+'_comparision.md')).write_text(md)
    for item in implementations:
        for language,key in [('LMX','lmx'),('Julia','foreign')]:
            rows.append({'id':item['id'],'role':'implementation','language':language,'title':item['title'],**metrics(item[key])})
        links='\n'.join(f"- `{x['name']}` — [{x['source']}]({('../'+x['source'])})" for x in item['production_definitions'])
        deps='; '.join(item['implementation_dependencies']) or 'нет дополнительных Julia comparison-модулей'
        source_links='\n'.join(f'- [{url}]({url})' for url in item['sources'])
        lm=metrics(item['lmx']); jm=metrics(item['foreign'])
        md=f"# {item['id']}. {item['title']}\n\n## Область реализации\n\n{item['contract']}\n\nЭто полная реализация объявленных операций в указанном профиле, а не весь Julia Base. Foreign comparison-модуль не импортируется клиентами. Зависимости Julia: {deps}; тела находятся рядом. LMX-тела извлечены из текущего ядра; [общие определения](shared_dependencies.lmx) и [машинный реестр](../validation/implementation_dependencies.json) составляют их явное дополнение.\n\nПубличные операции: {', '.join('`'+n+'`' for n in item['core_functions'])}.\n\n## LMX: действующие тела\n\n```lmx\n{item['lmx']}```\n\n## Julia: самостоятельная семантическая реализация\n\n```julia\n{item['foreign']}```\n\n## Размеры компонентов\n\n| Язык | Без пробельных | Непустые строки | Все символы |\n| --- | ---: | ---: | ---: |\n| LMX | {lm['characters_without_whitespace']} | {lm['nonblank_lines']} | {lm['characters_with_whitespace']} |\n| Julia | {jm['characters_without_whitespace']} | {jm['nonblank_lines']} | {jm['characters_with_whitespace']} |\n\nРазмер общих зависимостей приводится отдельно: складывать его для каждой строки повторно нельзя. Подготовлены empty/error/alias/callback cases в validation; runtime execution NOT_RUN.\n\n## Исходники LMX\n\n{links}\n\n## Первичные источники семантики Julia\n\n{source_links}\n"
        (R/'library_comparisons'/(item['id']+'_comparision.md')).write_text(md)
    write_json(R/'examples.json',data)
    totals={}
    for role in ('client','implementation'):
        totals[role]={}
        for lang in ('LMX','Julia'):
            selected=[r for r in rows if r['role']==role and r['language']==lang]
            totals[role][lang]={k:sum(r[k] for r in selected) for k in ('characters_with_whitespace','characters_without_whitespace','nonblank_lines','utf8_bytes')}
    write_json(R/'statistics.json',{'suite':'julia','edition':EDITION,'metrics':'Unicode code points; comments and final newline included; whitespace determined by Python str.isspace. No minification.','totals':totals,'shared_lmx':dep_report['shared_not_in_primary'],'rows':rows})
    with (R/'statistics.csv').open('w',newline='') as f:
        w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
    write_json(R/'validation/source_checks.json',{'status':'PASS','checks':checks,'core_coverage':mapping,'foreign_custom_helpers_imported':False,'primary_listings':len(checks),'runtime':{'julia':{'status':'NOT_RUN','executable':shutil.which('julia')},'lmx':{'status':'NOT_RUN','reason':'No integrated executable kernel available in archive.'}}})
    semantic=[]
    for e in data['examples']:
        semantic.append({'id':e['id']+'-main','example':e['id'],'inputs':e['inputs'],'expected':e['expected'],'status':'NOT_RUN'})
        for number,case in enumerate(e['semantic_cases'],1): semantic.append({'id':e['id']+f'-edge{number}','example':e['id'],**case,'status':'NOT_RUN'})
    write_json(R/'validation/semantic_cases.json',{'kind':'acceptance_specification_not_execution','cases':semantic})
    from write_julia_tests import main as write_tests
    write_tests()
    print(json.dumps({'examples':len(data['examples']),'implementations':len(implementations),'semantic_cases':len(semantic),'totals':totals,'unique_lmx_definitions':len(all_defs)},ensure_ascii=False))
if __name__=='__main__': main()
