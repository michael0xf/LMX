#!/usr/bin/env python3
"""Refresh only this directory's implementation extracts, docs and provenance."""
import sys
sys.dont_write_bytecode = True
from pathlib import Path
import hashlib
import json
import os
import re

ROOT = Path(__file__).resolve().parents[1]
SPEC = ROOT.parents[2]
LIB = SPEC / 'patterns/LMX_Fn_Receivers'
sys.path.insert(0, str(SPEC / 'patterns/tools'))
from canonical_operations import definitions
from lmx_execution_contract import ensure_startup_note
CLHS = 'https://www.lispworks.com/documentation/HyperSpec/Body/'
COMPONENTS = [
    dict(id='SI01', title='Обходы, фильтрация и свёртка',
         core_functions=['map','filter','compress','foldl','zipWith'],
         owners=['FxMap','FxFilter','FxSeqCompress','FxFold','FxZipWith'],
         contract='Конечные последовательности с произвольными элементами. map и zipWith выдают последовательность результатов, filter сохраняет профиль элементов и порядок, compress выбирает по целочисленной маске ровно той же длины и проверяет всю маску до построения результата, foldl начинает с явного seed. zipWith заканчивает на меньшей длине. Порядок callbacks слева направо; ошибка прерывает обход; частичный результат не возвращается. Пустые входы и ссылочные результаты поддержаны.',
         boundary='Чтение позиции, выделение последовательности и обычный вызов функции — общий нижний уровень. В CL здесь нет вызова map, mapcar, remove-if-not или reduce; показаны сами алгоритмы. В LMX общий вызов включает существующие FxApply/FxKernel и нормальное принятие результата.',
         limitations='Общий профиль исключает изменение входа из callback. CL reference принимает конечные proper lists и векторы; последовательность результатов map/zipWith — общий вектор. filter сохраняет list/vector и actual array element type; родство native типов двух VM не утверждается. Предикат reference намеренно принимает integer truth, чтобы не потерять отличие LMX int от произвольного Lisp truth.',
         sources=[CLHS+'f_mapc_.htm',CLHS+'f_rm_rm.htm',CLHS+'f_reduce.htm'],
         dependency_role='selected_clients'),
    dict(id='SI02', title='Короткие предикаты, первый индекс и запись значения',
         core_functions=['any','all','index','record'],
         owners=['FxSeqAny','FxSeqAll','FxSeqIndex','FxRecordOperands','FxMaybe','FxSome','FxNone'],
         contract='any/all прекращают обход сразу после определяющего ответа; на пустом входе получают 0/1. index возвращает первый подходящий нулевой индекс либо отсутствие; индекс 0 никогда не означает отсутствие. LMX выражает это Maybe, CL reference — двумя values. record сохраняет принятое значение и его идентичность без копирования полезного объекта.',
         boundary='В CL reference циклы реализованы напрямую, some/every/position-if не вызываются. Родной CL объект уже является динамическим значением; record-value имеет смысл identity. Это не заявление о совпадении физических {type value} LMX и машинных tagged values SBCL.',
         limitations='Полный семантический договор относится к одному предикату над одной конечной последовательностью; опции start/end/key/from-end из всего CL API здесь не заявлены. Predicate-admission принимает integer. Физическое Maybe и multiple values отличаются, поэтому сравнивается признак присутствия и само значение.',
         sources=[CLHS+'f_everyc.htm',CLHS+'f_pos_p.htm',CLHS+'f_values.htm'],
         dependency_role='selected_clients'),
    dict(id='SI03', title='Устойчивая сортировка и первые уникальные элементы',
         core_functions=['sort','unique'], owners=['FxSort','FxUnique'],
         contract='Новая внешняя последовательность, неизменный источник, прежняя идентичность ссылочных элементов. Устойчивая bottom-up merge sort использует трёхсторонний целый comparator. unique оставляет первое вхождение по общему равенству по умолчанию или явному same. Пустой и одиночный вход не вызывают comparator. Вход и ключи не меняются из callbacks.',
         boundary='CL reference не вызывает sort/stable-sort/remove-duplicates. Обе реализации показывают алгоритмы; общая инфраструктура профиля последовательности перечислена отдельно.',
         limitations='Generic unique линейно ищет в уже принятой части и имеет O(n²), sort имеет O(n log n). Это не замер скорости SBCL и не описание внутреннего алгоритма его стандартной библиотеки. CL native remove-duplicates может разделять внешнюю последовательность с входом, а reference здесь всегда строит результат по договору LMX; клиент S08 не наблюдает идентичность внешнего контейнера.',
         sources=[CLHS+'f_sort_.htm',CLHS+'f_rm_dup.htm'],
         dependency_role='selected_clients'),
    dict(id='SI04', title='Замена диапазона и сохранение target',
         core_functions=['replaceRange'], owners=['FxSeqReplaceRange'],
         contract='Полный replaceRange: полуоткрытый [begin,end), вставка, удаление, рост, уменьшение, пустые диапазоны и совпадение values с target. Вставка сначала подготавливается и проверяется, затем сдвигается хвост. Возвращается прежний target, а не удалённые элементы. Ссылочные цели сохраняются.',
         boundary='LMX использует общий изменяемый массив. CL reference использует adjustable vector с fill pointer и собственной памятью. Это ближайший физический профиль сохраняющего идентичность расширяемого массива; клиент S09 с обычным replace ограничен одинаковыми длинами, поэтому его договор уже, чем библиотечная реализация.',
         limitations='Reference не выдаётся за реализацию CL:replace: стандартный replace не изменяет длину. Здесь отдельно реализован именно LMX replaceRange. Допускаются перекрывающиеся источники; target должен владеть backing storage, displaced target отвергается. Ошибка типов подготовки не меняет target; исчерпание памяти не даёт общего обещания транзакции. CL actual array element type не равен полной системе admission LMX.',
         sources=[CLHS+'f_replac.htm',CLHS+'f_adjust.htm',CLHS+'f_mk_ar.htm'],
         dependency_role='selected_clients'),
    dict(id='SI05', title='Частичное применение произвольной конечной функции',
         core_functions=['partial'], owners=['FxPartial'],
         contract='Функция произвольной конечной позиционной арности N, префикс длины 0..N и остаток N−K. Значения префикса сохраняются в новом внешнем контейнере с прежними ссылочными целями. Полный префикс даёт thunk, тело до вызова не исполняется; ошибка тела проходит наружу. CL reference сохраняет все multiple values.',
         boundary='Обычный apply/funcall и lexical closure — примитивы языка CL. В reference arity передаётся как явная метаинформация, потому что ANSI CL не требует восстанавливать декларацию любого function object. LMX получает реальные требования из существующего signature-моста, и его полная реализация вместе с общими адаптерами сохраняется здесь.',
         limitations='Доказанный общий профиль — уже вычисленные позиционные аргументы. LMX partial также сохраняет свои defaults, DATA, динамическое связывание, admission и точную сигнатуру; CL reference не притворяется полной эмуляцией этих механизмов. Поэтому отношение размеров этих компонентов не является доказательством краткости всей системы вызова.',
         sources=[CLHS+'f_apply.htm',CLHS+'s_fn.htm'],
         dependency_role='selected_clients'),
    dict(id='SI06', title='Мемоизация с явным равенством полного ключа',
         core_functions=['memoize'], owners=['FxMemoEntry','FxMemoState','FxMemoEngine','FxMemo'],
         contract='Любое конечное число принятых позиционных аргументов, включая ноль; равенство получает весь ключ. Сохраняется внешний снимок аргументов, ссылочные цели не копируются. Кешируются только успешные результаты; nil, отсутствие значений и ссылочный результат сохраняются различимо. Результат ошибки и ошибка сравнения не превращаются в успешную запись.',
         boundary='Это две общие реализации linear-cache memoize с пользовательским равенством, а не подмена ими клиентского hash-table. CL reference сохраняет native multiple values. LMX использует один типизированный результат/void и стандартный frame snapshot; исходные тела его адаптера включены в зависимости.',
         limitations='Ключи должны оставаться стабильны для заданного равенства. Рекурсивный повтор ещё вычисляемого ключа не имеет special in-flight suppression. Кеш локален одному Message/последовательному владельцу; конкурентное разделение mutable cache не заявлено. S23 показывает явный процедурный кеш и функциональный вызов memoize. Общие реализации ниже учитываются один раз. Дополнительное LMX-равенство по умолчанию использует общий equality-контракт; эта пара проверяет профиль с явно переданным сравнением полного ключа.',
         sources=[CLHS+'f_gethas.htm',CLHS+'f_apply.htm',CLHS+'s_fn.htm'],
         dependency_role='functional_clients'),
]

def canonical(code):
    return code.replace('\r\n','\n').strip()+'\n'

def sha(code):
    return hashlib.sha256(code.encode('utf-8')).hexdigest()

def metrics(code):
    return dict(characters_with_whitespace=len(code),
                characters_without_whitespace=sum(not c.isspace() for c in code),
                nonblank_lines=sum(bool(x.strip()) for x in code.splitlines()),
                utf8_bytes=len(code.encode('utf-8')))

def write_json(path, data):
    path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')

def production():
    found=definitions(LIB)
    for item in found.values():
        path=LIB/item.pop('source')
        item.update(source_spec_relative=path.relative_to(SPEC).as_posix(),file_sha256=hashlib.sha256(path.read_bytes()).hexdigest(),sha256=sha(item['code']))
    return found

def refs(code):
    source='\n'.join(x for x in code.splitlines() if not x.lstrip().startswith('#'))
    return (set(re.findall(r'\b((?:Fx|Rx)[A-Za-z0-9_]+)(?=\\|@)',source)) |
            set(re.findall(r'copy\(((?:Fx|Rx)[A-Za-z0-9_]+)\)',source)) |
            set(re.findall(r'\bcopy\s*:\s*((?:Fx|Rx)[A-Za-z0-9_]+)\b',source)))

def closure(owners,available):
    result=set(); external=set(); stack=list(owners)
    while stack:
        name=stack.pop()
        if name in result: continue
        if name not in available:
            external.add(name); continue
        result.add(name)
        if name!='FxThrows':
            stack.extend(refs(available[name]['code'])-result)
    return result,external

def main():
    available=production()
    primary=set(); all_owners=set(); items=[]; ledger=[]; coverage={}
    report_path=ROOT/'validation/implementation_execution.json'
    execution=json.loads(report_path.read_text()) if report_path.exists() else {'status':'NOT_RUN'}
    for component in COMPONENTS:
        item={k:v for k,v in component.items() if k!='owners'}
        owners=component['owners']
        needed,external=closure(owners,available)
        all_owners.update(needed);primary.update(owners)
        lmx='\n'.join(available[x]['code'] for x in owners)
        lmx_file=f'source/implementations/lmx/{item["id"]}.lmx'
        foreign_file=f'source/implementations/common-lisp/{item["id"]}.lisp'
        foreign=canonical((ROOT/foreign_file).read_text())
        (ROOT/lmx_file).write_text(lmx)
        item.update(lmx=lmx,foreign=foreign,source_files={'lmx':lmx_file,'foreign':foreign_file},
                    production_definitions=[{'name':x,**{k:v for k,v in available[x].items() if k!='code'}} for x in owners],
                    shared_lmx_definitions=sorted(needed-set(owners)),external_boundaries=sorted(external),
                    common_lisp_dependencies=['source/implementations/common-lisp/runtime.lisp'],
                    complete_with_declared_dependencies=True,
                    runtime_execution={'LMX':'NOT_RUN','SBCL':execution['status']},
                    metrics={'LMX':metrics(lmx),'Common Lisp':metrics(foreign)})
        items.append(item)
        ledger.append({'id':item['id'],'primary_definitions':owners,'all_definitions':sorted(needed),
                       'external_boundaries':sorted(external),'primary':metrics(lmx),
                       'shared':metrics('\n'.join(available[x]['code'] for x in sorted(needed-set(owners))))})
        for name in item['core_functions']:
            coverage[name]=f'library_comparisons/{item["id"]}_comparision.md'
    shared=all_owners-primary
    shared_code='\n'.join(available[x]['code'] for x in sorted(shared))
    (ROOT/'source/implementations/lmx/shared_dependencies.lmx').write_text(shared_code)
    cl_runtime=(ROOT/'source/implementations/common-lisp/runtime.lisp').read_text()
    dependencies=dict(component_dependencies=ledger,
                      definitions=[{'name':x,**{k:v for k,v in available[x].items() if k!='code'},
                                    **metrics(available[x]['code'])} for x in sorted(all_owners)],
                      unique_definitions=len(all_owners),
                      unique_lmx_total=metrics('\n'.join(available[x]['code'] for x in sorted(all_owners))),
                      shared_not_in_primary=metrics(shared_code),common_lisp_runtime=metrics(cl_runtime),
                      external_boundaries=sorted(set().union(*(set(x['external_boundaries']) for x in items))),
                      missing_native_provider_implemented=False,
                      note_ru='Замыкание содержит текущие LMX тела. FxKernel и sys остаются существующими границами движка: их native реализация не оценена в ноль и не объявлена написанной. Одно общее тело учитывается один раз. Это размер исходников, не скорость и не размер машинного бинарника.')
    write_json(ROOT/'validation/implementation_dependencies.json',dependencies)
    totals={language:{key:sum(x['metrics'][language][key] for x in items)
                      for key in metrics('')} for language in ('LMX','Common Lisp')}
    write_json(ROOT/'implementation_data.json',dict(suite='SBCL',edition='2026-11-27',
               implementations=items,coverage=coverage,totals=totals,
               shared_dependencies={'lmx':'source/implementations/lmx/shared_dependencies.lmx',
                                    'foreign':'source/implementations/common-lisp/runtime.lisp'},
               dependency_report='validation/implementation_dependencies.json',
               execution_report='validation/implementation_execution.json'))
    for item in items:
        lm=item['metrics']['LMX'];cl=item['metrics']['Common Lisp']
        links=[]
        for d in item['production_definitions']:
            rel=os.path.relpath(SPEC/d['source_spec_relative'],ROOT/'library_comparisons')
            links.append(f'- `{d["name"]}` — [{d["source_spec_relative"]}]({rel}), SHA-256 `{d["sha256"]}`.')
        sources='\n'.join(f'- [{url}]({url})' for url in item['sources'])
        text=f'''# {item['id']}. {item['title']}

## Общий договор

{item['contract']}

{item['boundary']}

{item['limitations']}

Эта самостоятельная reference-реализация не является исходником SBCL и не импортируется ни одним клиентским примером. Сравниваются показанные алгоритмы в указанном профиле; весь ANSI Common Lisp API не заявлен.

## LMX: действующие тела ядра

```lmx
{item['lmx']}```

## Common Lisp: отдельная реализация того же профиля

```lisp
{item['foreign']}```

## Размер исходников

| Язык | Без пробельных | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: |
| LMX | {lm['characters_without_whitespace']} | {lm['nonblank_lines']} | {lm['characters_with_whitespace']} |
| Common Lisp | {cl['characters_without_whitespace']} | {cl['nonblank_lines']} | {cl['characters_with_whitespace']} |

Это размеры первичных тел, а не замер производительности. [Общие LMX определения](../source/implementations/lmx/shared_dependencies.lmx), [Common Lisp runtime](../source/implementations/common-lisp/runtime.lisp) и [реестр замыкания](../validation/implementation_dependencies.json) учитываются отдельно. Повторно прибавлять общие определения к каждой строке нельзя. Сигнатуры и admission LMX шире общего профиля SI05/SI06; их стоимость оставлена видимой.

## Проверка

Исполнение reference на SBCL: **{item['runtime_execution']['SBCL']}**. [Протокол](../validation/implementation_execution.json) содержит тесты и hashes проверенных файлов. LMX: **NOT_RUN**, текущий интегрированный исполняемый движок в этом пакете отсутствует. Совпадение текста с ядром и замыкание зависимостей проверяются отдельно; это не заменяет исполнение.

## Происхождение LMX

{chr(10).join(links)}

## Первичные источники Common Lisp

{sources}
'''
        (ROOT/'library_comparisons'/f'{item["id"]}_comparision.md').write_text(text)
    readme=f'''# Сравнения реализаций ядра: Common Lisp/SBCL и LMX

Шесть пар ниже раскрывают библиотечные тела отдельно от клиентов. Клиенты используют реальные средства Common Lisp/SBCL; они не загружают этот reference-код. Никакие внешние файлы `spec` не меняются.

| Пара | Операции | Роль |
| --- | --- | --- |
'''
    for item in items:
        role='основные клиенты' if item['dependency_role']=='selected_clients' else 'сохранённый вариант S23 с ядром'
        readme+=f'| [{item["id"]}]({item["id"]}_comparision.md) | '+', '.join('`'+x+'`' for x in item['core_functions'])+f' | {role} |\n'
    readme+=f'''
## Что именно посчитано

Первичные LMX тела: **{totals['LMX']['characters_without_whitespace']}** непробельных символов. Common Lisp reference: **{totals['Common Lisp']['characters_without_whitespace']}**. Единое замыкание LMX содержит **{len(all_owners)}** определений, **{dependencies['unique_lmx_total']['characters_without_whitespace']}** непробельных символов; из них общие определения, не включённые в шесть первичных пар, занимают **{dependencies['shared_not_in_primary']['characters_without_whitespace']}**. Общая CL инфраструктура занимает **{dependencies['common_lisp_runtime']['characters_without_whitespace']}**. Машинные данные находятся в [implementation_data.json](../implementation_data.json) и [implementation_dependencies.json](../validation/implementation_dependencies.json).

Алгоритмы сохранены полностью. Общее чтение/запись массива, создание значений, VM-вызов, выделение памяти, родные lexical closures и согласованные мосты LMX — нижний уровень обеих архитектур. Код provider для `FxKernel` в этих числах не появляется и не объявляется реализованным. Размер общего нижнего уровня нельзя считать нулевым только потому, что он находится в другом слое.

SI04 имеет полный договор LMX replaceRange, который шире CL replace; клиент сравнивает их только там, где операция совпадает. SI05/SI06 сохраняют настоящие LMX адаптеры, хотя portable Common Lisp reference ограничен обычными принятыми позиционными значениями. В S23 наличие стандартного hash-table не выдаётся за наличие стандартного memoize: процедурный клиент и вариант с ядром показаны отдельно.

Все операции здесь синхронны в одном владельце. Кеш SI06 локален владельцу и не разделяется между Thread. Асинхронный клиент S24 использует Message/post и реальный SBCL mailbox; эти алгоритмы не создают дополнительного планировщика.

Общие входные условия: конечная proper sequence и действительный callback нужной арности. Ошибки, которые callback поднимает во время нормального вызова, входят в договор; порядок обнаружения некорректного объекта вместо callback и исчерпания памяти в разных VM не приравнивается. CL дополнительные проверки не означают, что LMX заранее исполняет или принудительно читает неиспользованный callback пустой коллекции.

## Воспроизводимость

```sh
python3 tools/run_implementation_tests.py
python3 tools/rebuild_implementations.py
```

Команды выполняются из корня SBCL_comparison. Для нестандартной установки задайте `SBCL_BIN` и, если нужно, `SBCL_HOME`. Первый скрипт исполняет только Common Lisp reference. Второй перечитывает текущий `spec/patterns/LMX_Fn_Receivers/src`, извлекает точные тела и пишет только внутрь SBCL_comparison. При изменении ядра hashes закономерно изменятся; чужие файлы этот скрипт не переписывает.

[Runtime support CL](../source/implementations/common-lisp/runtime.lisp) загружается перед SI01–SI06. Тесты: [test_implementations.lisp](../tools/test_implementations.lisp). [LMX зависимости](../source/implementations/lmx/shared_dependencies.lmx) являются частью сравнительного пакета, но не заменяют штатную установку ядра и его provider. Новых публичных операций эти шесть пар не требуют.
'''
    (ROOT/'library_comparisons/README.md').write_text(ensure_startup_note(
        readme,'../../../../LMX_semantics.en.md#source-entry-profiles'))
    mirror_checks=[]
    for item in items:
        markdown=(ROOT/'library_comparisons'/f'{item["id"]}_comparision.md').read_text()
        for key in ('lmx','foreign'):
            source=(ROOT/item['source_files'][key]).read_text()
            assert source==item[key] and item[key] in markdown
            mirror_checks.append({'id':item['id'],'language':key,'file':item['source_files'][key],
                                  'sha256':sha(source),'status':'PASS','check':'source_json_markdown_equal'})
    write_json(ROOT/'validation/implementation_source_checks.json',
               {'status':'PASS','checks':mirror_checks,'external_boundaries':dependencies['external_boundaries'],
                'source_only_lmx':True,'core_additions':[]})
    print(json.dumps({'implementations':len(items),'owners':len(all_owners),'totals':totals,
                      'shared':dependencies['shared_not_in_primary'],'foreign_shared':dependencies['common_lisp_runtime'],
                      'external':dependencies['external_boundaries']},ensure_ascii=False))

if __name__=='__main__':
    main()
