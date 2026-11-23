#!/usr/bin/env python3
"""Пересобрать источники/MD/метрики Julia suite; LMX и Julia не исполняются."""
import sys
sys.dont_write_bytecode = True
from pathlib import Path
import csv, hashlib, json, re, shutil
R = Path(__file__).resolve().parents[1]
LIB = R.parents[1] / 'LMX_Fn_Receivers'
CORE = LIB
PATTERNS = R.parents[1]
sys.path.insert(0, str(PATTERNS / 'tools'))
from lmx_style_variants import get_variants, validate_variants
from lmx_execution_contract import apply_execution_contract, acceptance_document
from lmx_style_suite_reports import prepare as prepare_style, rows_for, client_markdown, count_table, write_overview, write_csv, block
from canonical_operations import definitions, public_roots as catalog_roots, selected_operations
EDITION = '2026-11-23'
COMPONENTS = [
 ('JI01','Упорядоченные обходы, предикаты и свёртки','JI01_ordered.jl',
  ['map','filter','foldl','scanl','zip','zipWith','bind','any','all','index','count','record'],
  ['FxMap','FxFilter','FxFold','FxScan','FxPair','FxZip','FxZipWith','FxListBind','FxSeqBind','FxSeqAny','FxSeqAll','FxSeqIndex','FxSeqCount','FxRecordOperands','FxMaybe','FxSome','FxNone'],
  'Конечные последовательности, произвольные типы полезных значений, упорядоченные callbacks в одной Message. map/bind/scan/zip возвращают записи значений; filter сохраняет исходный профиль. Предикаты возвращают int LMX, Bool/Int Julia. Ошибка callback распространяется; callback не изменяет входную последовательность. Частичный результат не выдаётся. index различает отсутствие и индекс 0. record сохраняет принятое значение, а не копирует граф.',
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
  'Общие типы элементов и ключей. Устойчивая bottom-up merge sort с целочисленным трёхсторонним comparator; unique оставляет первое появление по общему равенству по умолчанию или явному same; groupBy вызывает keyOf один раз на элемент и сохраняет порядок внутри групп. Пустые входы и неверные ответы comparator/predicate обработаны. Источник и ключи callbacks не меняют. Generic unique/groupBy используют поиск без hash; их асимптотика не приравнивается к оптимизированным Base.unique/SplitApplyCombine.group.',
  ['https://docs.julialang.org/en/v1/base/sort/','https://docs.julialang.org/en/v1/base/collections/','https://github.com/JuliaData/SplitApplyCombine.jl#grouping'],['JI01'])
]
def canonical(code): return code.strip() + '\n'
def metrics(code):
    return {'characters_with_whitespace':len(code),'characters_without_whitespace':sum(not c.isspace() for c in code),'nonblank_lines':sum(bool(x.strip()) for x in code.splitlines()),'utf8_bytes':len(code.encode('utf-8'))}
def sha(code): return hashlib.sha256(code.encode()).hexdigest()
def write_json(path, value): path.write_text(json.dumps(value,ensure_ascii=False,indent=2)+'\n')

def production():
    return definitions(CORE)

def refs(code, available=None):
    # Follow actual qualified roots, model heads, copy/merge DATA streams and
    # ready Structure values. Plain failure labels in throws banks are not calls.
    clean = '\n'.join(line.split('#', 1)[0] for line in code.splitlines())
    found = set(re.findall(r'\b((?:Fx|Rx)\w+)(?=\\|@)', clean))
    found.update(re.findall(r'\b(?:copy|merge|import)\s*(?:\(|:)\s*((?:Fx|Rx)\w+)', clean))
    if available is not None:
        throws_indent = None
        for line in clean.splitlines():
            if not line.strip():
                continue
            indent = len(line) - len(line.lstrip())
            if throws_indent is not None and indent <= throws_indent:
                throws_indent = None
            if line.lstrip().startswith('throws:'):
                throws_indent = indent
                continue
            if throws_indent is not None or line.lstrip().startswith('throw:'):
                continue
            found.update(set(re.findall(r'\b(?:Fx|Rx)\w+\b', line)) & set(available))
    return found

def closure(names, available):
    result, external, stack = set(), set(), list(names)
    while stack:
        name = stack.pop()
        if name in result:
            continue
        if name not in available:
            external.add(name)
            continue
        result.add(name)
        if name != 'FxThrows':
            stack.extend(refs(available[name]['code'], available) - result)
    return result, external

def public_roots(available, families=None):
    return catalog_roots(CORE, available, families)

def main():
    data=apply_execution_contract(json.loads((R/'examples.json').read_text()))
    available=production(); aliases=public_roots(available); implementations=[]; mapping={}; all_defs=set(); primary_defs=set(); ledger=[]
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
    for case in data['examples']:
        for _, variant in get_variants(case):
            needed, _ = closure(refs(variant['code'], available), available)
            all_defs.update(needed)
    shared=all_defs-primary_defs
    shared_code='\n'.join(available[x]['code'] for x in sorted(shared))
    (R/'library_comparisons/shared_dependencies.lmx').write_text(shared_code)
    dep_report={'edition':EDITION,'component_dependencies':ledger,'definitions':[{'name':x,'source':'../../LMX_Fn_Receivers/'+available[x]['source'],'sha256':sha(available[x]['code']),**metrics(available[x]['code'])} for x in sorted(all_defs)],'unique_definitions':len(all_defs),'unique_lmx_total':metrics('\n'.join(available[x]['code'] for x in sorted(all_defs))),'shared_not_in_primary':metrics(shared_code),'runtime_implementation_measured':False,'note_ru':'Тела алгоритмов и общие тела сохранены полностью; FxKernel и sys являются существующими интеграционными границами, не выдуманной реализацией нулевого размера.'}
    write_json(R/'validation/implementation_dependencies.json',dep_report)

    rows=[]; checks=[]; comparison_rows=[]
    expected_ids=[f'J{i:02}' for i in range(1,25)]
    assert [e['id'] for e in data['examples']]==expected_ids
    for e in data['examples']:
        prepare_style(e,R)
        aliases=public_roots(available,e.get('core_families'))
        operations=selected_operations(CORE,e.get('core_families'))
        e['implementation_targets']={name:operations[name]['api'] for name in e['core_functions']}
        e['implementation_links']={}
        for name in e['core_functions']:
            if name in mapping:e['implementation_links'][name]=mapping[name]
            elif name in aliases and aliases[name] in available:
                e['implementation_links'][name]='../../LMX_Fn_Receivers/'+available[aliases[name]]['source']
            else:raise ValueError(e['id']+': unresolved core '+name)
        for language,key in [('LMX','lmx'),('Julia','foreign')]:
            path=R/e['source_files'][key]
            path.write_text(e[key])
            rows.append({'id':e['id'],'role':'client','language':language,'title':e['title'],**metrics(e[key])})
        for style,variant in get_variants(e):
            checks.append({'id':e['id'],'language':'LMX','style':style,'source':variant['source_file'],'sha256':variant['metrics']['sha256'],'status':'PASS','check':'source_json_equal','runtime_execution':'NOT_RUN'})
        comparison_rows.extend(rows_for(e,'Julia'))
        assert not re.search(r'Julia(?:Ordered|Array|Mutation|OrderGroup)Reference|include\(|library_comparisons',e['foreign'])
        links='\n'.join(f'- `{name}`: [полная пара реализации]({link})' for name,link in e['implementation_links'].items())
        (R/(e['id']+'_comparision.md')).write_text(client_markdown(e,'Julia',links,'notes_ru',
            'LMX и Julia: **NOT_RUN** в этой сборке. Проверяются обе LMX-формы как текст и общий независимый oracle; это не языковое исполнение.'))
    for item in implementations:
        for language,key in [('LMX','lmx'),('Julia','foreign')]:
            rows.append({'id':item['id'],'role':'implementation','language':language,'title':item['title'],**metrics(item[key])})
        links='\n'.join(f"- `{x['name']}` — [{x['source']}]({('../'+x['source'])})" for x in item['production_definitions'])
        deps='; '.join(item['implementation_dependencies']) or 'нет дополнительных Julia comparison-модулей'
        sources='\n'.join(f'- <{url}>' for url in item['sources'])
        md=(f"# {item['id']}. {item['title']}\n\n## Область реализации\n\n{item['contract']}\n\n"
            f"Единое LMX-тело используется обеими клиентскими формами. Julia comparison-модуль клиенты не импортируют. Зависимости Julia: {deps}.\n\n"
            "[Общие определения](shared_dependencies.lmx) и [машинный реестр](../validation/implementation_dependencies.json) дополняют эти тела.\n\n"
            "## LMX: действующие тела\n\n"+block('lmx',item['lmx'])+
            "\n## Julia: самостоятельная реализация\n\n"+block('julia',item['foreign'])+
            "\n## Полный размер компонентов\n\n"+count_table([('LMX',item['lmx']),('Julia',item['foreign'])])+
            "\nОбщие зависимости считаются один раз; отдельные style-копии библиотечных тел не создаются. Runtime execution: NOT_RUN.\n\n"
            "## Исходники LMX\n\n"+links+"\n\n## Первичные источники\n\n"+sources+"\n")
        (R/'library_comparisons'/(item['id']+'_comparision.md')).write_text(md)
    write_json(R/'examples.json',data)
    totals={}
    for role in ('client','implementation'):
        totals[role]={}
        for lang in ('LMX','Julia'):
            selected=[r for r in rows if r['role']==role and r['language']==lang]
            totals[role][lang]={k:sum(r[k] for r in selected) for k in ('characters_with_whitespace','characters_without_whitespace','nonblank_lines','utf8_bytes')}
    style_totals=write_overview(R,data,'Julia',
        '[Единые библиотечные реализации](library_comparisons/README.md) JI01–JI04 и [общие зависимости](validation/implementation_dependencies.json) учитываются отдельно.')
    write_json(R/'statistics.json',{'suite':'julia','edition':EDITION,'metrics':'Full-source Unicode code points; whitespace by str.isspace; comments and Throws retained.','legacy_lmx_role':'functional compatibility mirror only','totals':totals,'style_totals':style_totals,'shared_lmx':dep_report['shared_not_in_primary'],'rows':rows,'comparison_rows':comparison_rows})
    write_csv(R,data,'Julia')
    write_json(R/'validation/source_checks.json',{'status':'PASS','checks':checks,'core_coverage':mapping,'foreign_custom_helpers_imported':False,'runtime':{'julia':{'status':'NOT_RUN','executable':shutil.which('julia')},'lmx':{'status':'NOT_RUN'}}})
    semantic=[]
    for e in data['examples']:
        semantic.append({'id':e['id']+'-main','example':e['id'],'contract_id':e['id'],'styles':['procedural','functional'],'inputs':e['inputs'],'expected':e['expected'],'status':'NOT_RUN'})
        for number,case in enumerate(e['semantic_cases'],1):
            semantic.append({'id':e['id']+f'-edge{number}','example':e['id'],'contract_id':e['id'],'styles':['procedural','functional'],**case,'status':'NOT_RUN'})
    write_json(R/'validation/semantic_cases.json',acceptance_document({'kind':'acceptance_specification_not_execution','cases':semantic}))
    (R/'validation/throws_metrics.json').unlink(missing_ok=True)
    revision_path=R/'validation/julia_revision_20261123.json'
    if revision_path.exists():
        revision=json.loads(revision_path.read_text())
        revision.update({'status':'PAIRED_CLIENTS_READY','core_operations_used':sorted({name for item in data['examples'] for name in item['core_functions']}),'statistics':totals,'style_totals':style_totals,'notes_ru':'Обе полные LMX-формы опубликованы отдельно; старое lmx является functional-зеркалом. Исключений из полного счёта Throws нет.','final_frozen_core_refresh':True})
        write_json(revision_path,revision)
    from write_julia_tests import main as write_tests
    write_tests()
    print(json.dumps({'examples':len(data['examples']),'lmx_client_variants':len(comparison_rows)-len(data['examples']),'implementations':len(implementations),'semantic_cases':len(semantic),'style_totals':style_totals},ensure_ascii=False))
if __name__=='__main__': main()
