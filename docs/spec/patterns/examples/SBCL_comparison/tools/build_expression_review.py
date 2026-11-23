#!/usr/bin/env python3
"""Record both full LMX styles for every client; never select a style by size."""
import sys
sys.dont_write_bytecode=True
from pathlib import Path
import json
from rebuild import metrics, STYLES
from rebuild_implementations import production, closure
ROOT=Path(__file__).resolve().parents[1]

def main():
    data=json.loads((ROOT/'examples.json').read_text())
    code=(ROOT/'source/lmx/Expression_examples.lm3').read_text()
    available=production();needed,external=closure(['FxAsOperand'],available)
    dependency_code='\n'.join(available[n]['code'] for n in sorted(needed))
    cases=[]
    for e in data['examples']:
        cases.append({'id':e['id'],'variants':{style:{'source':e['lmx_variants'][style]['source_file'],
            'metrics':e['lmx_variants'][style]['metrics'],'core_functions':e['lmx_variants'][style].get('core_functions',[])} for style in STYLES},
            'style_relation':e['style_relation'],'reason':e['style_note'],'runtime_execution':'NOT_RUN'})
    report={'lmx_runtime':'NOT_RUN','principle':'Both procedural and functional styles remain complete primary comparisons. One OPERANDS_TEMPLATE supports either operand position. No per-client adapter or size-based style selection is required.',
        'cases':cases,'example':{'source':'source/lmx/Expression_examples.lm3','metrics':metrics(code),'expected':[15,15]},
        'asOperand':{'source':'../../LMX_Fn_Receivers/src/coreStandardLisp.lmx','primary':metrics(available['FxAsOperand']['code']),
            'unique_dependency_count':len(needed),'unique_dependency_metrics':metrics(dependency_code),
            'dependencies':[{'name':n,**{k:v for k,v in available[n].items() if k!='code'}} for n in sorted(needed)],'existing_external_boundaries':sorted(external)},
        'accounting':'Core implementation and common adapters are counted once in their own boundary. Every client includes its entire source and full Throws; no supplementary Throws metric.'}
    (ROOT/'validation/expression_review.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    lines=['# Expression и два полных LMX-стиля','',
        'Для всех 24 договоров опубликованы процедурный и функциональный исходники. Оба входят в сравнение; меньший размер не удаляет другой стиль. Общие операции ядра имеют канонические обычную и операндную формы. Настройка нового пользовательского операнда показана отдельно ниже, без её повторения в каждом клиенте.','',
        'Единственный общий OPERANDS_TEMPLATE допускает `(myOp 1 2 3 4 5)` и `(1 myOp 2 3 4 5)`. Отдельного типа «префиксный» и дополнительного Lisp-парсера нет. Functional-варианты используют Expression, общие обходы, адаптацию и контейнерные операции с сохранением short-circuit, порядка эффектов и реальных значений.','',
        '| ID | Процедурный | Функциональный | Соответствие договору |','| --- | ---: | ---: | --- |']
    for row in cases:
        a=row['variants']['procedural'];b=row['variants']['functional']
        lines.append(f"| [{row['id']}]({row['id']}_comparision.md) | [{a['metrics']['characters']}]({a['source']}) | [{b['metrics']['characters']}]({b['source']}) | {row['reason']} |")
    m=report['example']['metrics'];am=report['asOperand']['primary'];dm=report['asOperand']['unique_dependency_metrics']
    lines += ['', '## Полный пример явной настройки пользовательского операнда','',
        '[Исходник](source/lmx/Expression_examples.lm3). Ожидание `[15,15]`; LMX **NOT_RUN**. Эта иллюстрация находится вне итоговых 23 сопоставимых договоров.','',
        '```lmx',code.rstrip(),'```','',
        '| Что учитывается | Полный размер без пробельных |','| --- | ---: |',
        f"| Иллюстрация, настройка включена | {m['characters_nonwhitespace']} |",
        f"| Единственное тело asOperand | {am['characters_nonwhitespace']} |",
        f"| Уникальное замыкание ({len(needed)} определений) | {dm['characters_nonwhitespace']} |",'',
        'В стандартной публикации обе формы подготавливает общий actor/translator контекст. Граница этой явной фабрики не превращается в обязательную клиентскую обвязку. Одно ядровое тело не размножается по стилям и строкам.','',
        'Скалярные и Array-выражения не открывают готовые значения рекурсивно: где нужен поток полей, он указан явным `copy`. S03 использует настоящий левый foldl; предварительная сумма не меняет порядок промежуточных вычислений. S04 сохраняет остановку по меньшей длине. S05 сохраняет два независимых счётчика короткого замыкания. S22 сохраняет все пять путей finally/ошибок. S24 остаётся протокольной аналогией с тем же owning Message/FIFO-профилем.','',
        'Основания: [общие формы](../../../OPERATION_FORMS.md), [Expression](../../../LMX_semantics.en.md#assignment-inside-expression), [prepared values](../../../LMX_semantics.en.md#prepared-operands), [явный stream](../../../LMX_semantics.en.md#stream-or-group), [публикация](../../LMX_Fn_Receivers/PUBLICATION_CONTRACT.md).']
    (ROOT/'EXPRESSION_REVIEW.md').write_text('\n'.join(lines)+'\n')
    print(json.dumps({'reviewed':len(cases),'style_variants':2*len(cases),'physical_style_sources':len({v['source'] for c in cases for v in c['variants'].values()}),'adapter_closure_definitions':len(needed)}))

if __name__=='__main__':main()
