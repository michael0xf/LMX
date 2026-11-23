#!/usr/bin/env python3
"""Publish the 24-case Expression review and charge one shared adapter once."""
import sys
sys.dont_write_bytecode=True
from pathlib import Path
import json
from rebuild import metrics
from rebuild_implementations import production, closure

ROOT=Path(__file__).resolve().parents[1]
DECISIONS=[
('S01','Existing Array arithmetic','items * 3 already is ordinary Expression; changing only operand placement adds punctuation without removing logic.'),
('S02','Ready compress callable','Vector comparison forms the mask; a local asOperand used once would lengthen the full listing.'),
('S03','Ordered left subtraction','Keep the short full left fold. Variadic + does not prove a variadic subtraction contract; summing first could change intermediate overflow.'),
('S04','Shortest truncating pair loop','Equal-length Array multiplication alone loses the shorter-input stop rule; the complete zipWith alternative remains separate.'),
('S05','One shared short-circuit traversal','Any/all traces share Query; no repeated predicate body. Converting a call spelling does not remove the trace requirement.'),
('S06','Shortest first-match loop','A result sentinel is part of this narrow task; the Maybe/index core alternative includes its full conversion.'),
('S07','Ready sort callable','Comparator arithmetic is Expression; configuring an operand for this one sort call would add setup.'),
('S08','Ready unique callable','One equality body; full first-occurrence semantics. Local operand configuration would be longer.'),
('S09','Ready replaceRange callable','The required independent outer result uses explicit copy; mutation/length contract remains complete.'),
('S10','One partial factory','partial is the common general capture factory; a syntax adapter adds cost. The copied-owner alternative remains a different implementation.'),
('S11','Explicit variadic Expression','(+ 0 copy(items)) consumes the explicit field stream and retains the empty-input neutral value; the loop is eliminated.'),
('S12','Named actuals and defaults','Ordinary named calls are needed to demonstrate named order and omission. asOperand transports ready positional values, not fictitious named entries.'),
('S13','Native dynamic binding','The free value crosses a forwarding function that does not declare or use it; no context object or forwarding parameter.'),
('S14','Local recursive callable','Native conditional/arithmetic Expression already applies. An operand adapter would not remove recursion or local ownership.'),
('S15','Structured multiple result','Native division/remainder expressions and one ordinary result Structure; no new values runtime.'),
('S16','Explicit shape paths','Ordinary field/index arithmetic is shortest; no invented recursive operand argument expansion.'),
('S17','Mask plus explicit variadic Expression','One compress selects odd values before squaring; (+ 0 copy(odd * odd)) removes the accumulator loop without evaluating excluded squares.'),
('S18','Native structural object methods','Keep full object creation, copied method ownership and both calls. A prefix-shaped arithmetic-only driver would omit the object task.'),
('S19','Native stateful accessor task','Preserve the actual copied owner, unchanged height and updated width. Operand placement cannot substitute for these observations.'),
('S20','One computed binding','Producer runs once, the saved value is reused; arbitrary macroexpansion is not claimed.'),
('S21','Exact declared failure','Catch only InputFailure with ordinary typed flow; eager asOperand does not manufacture a control-flow operator.'),
('S22','One Event body and finally','Acquire/action/release differ only in data; exact ResourceFailure carries phase, with release overriding action failure as required.'),
('S23','Explicit cache at the same comparison level','One cache implementation, fresh per call. Ready memoize remains separately costed and is not compared as an ANSI builtin.'),
('S24','Existing Message protocol','No spawn/await/parser mode invented. Full host fixture remains pending; notation changes do not erase its cost.')]


def main():
    data=json.loads((ROOT/'examples.json').read_text())
    current={e['id']:e for e in data['examples']}
    code=(ROOT/'source/lmx/Expression_examples.lm3').read_text()
    available=production();needed,external=closure(['FxAsOperand'],available)
    owner=available['FxAsOperand']
    dependency_code='\n'.join(available[n]['code'] for n in sorted(needed))
    report={
        'lmx_runtime':'NOT_RUN',
        'principle':'One ordinary OPERANDS_TEMPLATE, both operand positions, shortest complete primary source; no automatic callable rewrite.',
        'cases':[dict(id=sid,decision=decision,reason=reason,source=current[sid]['source_files']['lmx'],metrics=current[sid]['counts']['lmx']) for sid,decision,reason in DECISIONS],
        'example':{'source':'source/lmx/Expression_examples.lm3','metrics':metrics(code),'expected':[15,15]},
        'asOperand':{'source':'../../LMX_Fn_Receivers/src/coreStandardLisp.lmx','primary':metrics(owner['code']),
                     'unique_dependency_count':len(needed),'unique_dependency_metrics':metrics(dependency_code),
                     'dependencies':[{'name':n,**{k:v for k,v in available[n].items() if k!='code'}} for n in sorted(needed)],
                     'existing_external_boundaries':sorted(external)},
        'accounting':'Factory/body and dependencies counted once; exact source/native provider costs are not hidden in a per-client zero. E01 is a notation illustration outside the 24 paired-task ratios.'}
    (ROOT/'validation/expression_review.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    m=report['example']['metrics'];am=report['asOperand']['primary'];dm=report['asOperand']['unique_dependency_metrics']
    lines=['# Expression: пересмотр всех 24 LMX-клиентов','',
           'Во всех случаях действует один общий шаблон операнда. `(myOp 1 2 3 4 5)` и '+
           '`(1 myOp 2 3 4 5)` — два положения одного метода; типа или отдельного режима «префиксный» нет. '+
           'Сохранён главный критерий: кратчайший полный основной листинг на одинаковом уровне задачи.','',
           'Обычный callable не становится операндом от перестановки скобки. `asOperand` действительно строит '+
           'его DATA с left/right и готовыми свойствами; стоимость настройки видна ниже. '+
           'Если один прямой вызов уже короче полного адаптера, он остаётся основным.','',
           '## Полный пример одной настройки','',
           '[Исходник](source/lmx/Expression_examples.lm3). Ожидаемый результат: `[15,15]`; исполнение LMX — **NOT_RUN**.','',
           '```lmx',code.rstrip(),'```','',
           '| Что учитывается | Полный размер без пробельных | Без сложного Throws |',
           '| --- | ---: | ---: |',
           f"| Полный E01, настройка включена | {m['characters_nonwhitespace']} | {m['without_complex_throws_characters']} |",
           f"| Единственное тело фабрики asOperand | {am['characters_nonwhitespace']} | {am['without_complex_throws_characters']} |",
           f"| Уникальное замыкание asOperand, включая фабрику ({len(needed)} определений) | {dm['characters_nonwhitespace']} | {dm['without_complex_throws_characters']} |",'',
           'Замыкание не прибавляется ко всем примерам повторно. В него входят уже существующие общие '+
           'типовые/вызовные функции и общий left/right collector; нативный FxKernel остаётся внешней границей, '+
           'его реализация не оценена нулём. E01 не подставлен в коэффициент 23 полных сравнительных пар.','',
           '## Решение по каждой строке','',
           '| ID | Решение | Почему |','| --- | --- | --- |']
    for sid,decision,reason in DECISIONS:
        lines.append(f'| [{sid}]({sid}_comparision.md) | {decision} | {reason} |')
    lines += ['',
        'S11 использует именно явный поток `copy(items)`, а не неявное раскрытие готового Array. '+
        'S17 сначала отбирает значения, поэтому не вычисляет потенциально лишние квадраты чётных элементов. '+
        'У короткого замыкания, объектов, исключений и Message сохраняются все наблюдаемые части договора.','',
        'Основания: [Expression](../../../LMX_semantics.en.md#assignment-inside-expression), '+
        '[структурный operand](../../../LMX_semantics.en.md#operand-receiver), '+
        '[prepared values](../../../LMX_semantics.en.md#prepared-operands), '+
        '[явный stream](../../../LMX_semantics.en.md#stream-or-group). '+
        '[Точная машинная запись и hashes](validation/expression_review.json); '+
        '[ТЗ и runtime-приёмка](TZ_Standard_Lisp_and_Expression.md).']
    (ROOT/'EXPRESSION_REVIEW.md').write_text('\n'.join(lines)+'\n')
    print(json.dumps({'reviewed':len(DECISIONS),'E01':m,'adapter_closure_definitions':len(needed)},ensure_ascii=False))


if __name__=='__main__':main()
