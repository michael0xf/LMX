# Expression: пересмотр всех 24 LMX-клиентов

Во всех случаях действует один общий шаблон операнда. `(myOp 1 2 3 4 5)` и `(1 myOp 2 3 4 5)` — два положения одного метода; типа или отдельного режима «префиксный» нет. Сохранён главный критерий: кратчайший полный основной листинг на одинаковом уровне задачи.

Обычный callable не становится операндом от перестановки скобки. `asOperand` действительно строит его DATA с left/right и готовыми свойствами; стоимость настройки видна ниже. Если один прямой вызов уже короче полного адаптера, он остаётся основным.

## Полный пример одной настройки

[Исходник](source/lmx/Expression_examples.lm3). Ожидаемый результат: `[15,15]`; исполнение LMX — **NOT_RUN**.

```lmx
Numbers:
    int: a
    int: b
    int: c
    int: d
    int: e
    return: int
    add:
        return: (+ a b c d e)

Example:
    return: @
    run:
        throws: copy(FxThrows\selection)
        @: myOp asOperand(Numbers\add; sys\priority("+"))
        return: ((myOp 1 2 3 4 5); (1 myOp 2 3 4 5))
```

| Что учитывается | Полный размер без пробельных | Без сложного Throws |
| --- | ---: | ---: |
| Полный E01, настройка включена | 191 | 191 |
| Единственное тело фабрики asOperand | 1228 | 1228 |
| Уникальное замыкание asOperand, включая фабрику (19 определений) | 7599 | 6621 |

Замыкание не прибавляется ко всем примерам повторно. В него входят уже существующие общие типовые/вызовные функции и общий left/right collector; нативный FxKernel остаётся внешней границей, его реализация не оценена нулём. E01 не подставлен в коэффициент 23 полных сравнительных пар.

## Решение по каждой строке

| ID | Решение | Почему |
| --- | --- | --- |
| [S01](S01_comparision.md) | Existing Array arithmetic | items * 3 already is ordinary Expression; changing only operand placement adds punctuation without removing logic. |
| [S02](S02_comparision.md) | Ready compress callable | Vector comparison forms the mask; a local asOperand used once would lengthen the full listing. |
| [S03](S03_comparision.md) | Ordered left subtraction | Keep the short full left fold. Variadic + does not prove a variadic subtraction contract; summing first could change intermediate overflow. |
| [S04](S04_comparision.md) | Shortest truncating pair loop | Equal-length Array multiplication alone loses the shorter-input stop rule; the complete zipWith alternative remains separate. |
| [S05](S05_comparision.md) | One shared short-circuit traversal | Any/all traces share Query; no repeated predicate body. Converting a call spelling does not remove the trace requirement. |
| [S06](S06_comparision.md) | Shortest first-match loop | A result sentinel is part of this narrow task; the Maybe/index core alternative includes its full conversion. |
| [S07](S07_comparision.md) | Ready sort callable | Comparator arithmetic is Expression; configuring an operand for this one sort call would add setup. |
| [S08](S08_comparision.md) | Ready unique callable | One equality body; full first-occurrence semantics. Local operand configuration would be longer. |
| [S09](S09_comparision.md) | Ready replaceRange callable | The required independent outer result uses explicit copy; mutation/length contract remains complete. |
| [S10](S10_comparision.md) | One partial factory | partial is the common general capture factory; a syntax adapter adds cost. The copied-owner alternative remains a different implementation. |
| [S11](S11_comparision.md) | Explicit variadic Expression | (+ 0 copy(items)) consumes the explicit field stream and retains the empty-input neutral value; the loop is eliminated. |
| [S12](S12_comparision.md) | Named actuals and defaults | Ordinary named calls are needed to demonstrate named order and omission. asOperand transports ready positional values, not fictitious named entries. |
| [S13](S13_comparision.md) | Native dynamic binding | The free value crosses a forwarding function that does not declare or use it; no context object or forwarding parameter. |
| [S14](S14_comparision.md) | Local recursive callable | Native conditional/arithmetic Expression already applies. An operand adapter would not remove recursion or local ownership. |
| [S15](S15_comparision.md) | Structured multiple result | Native division/remainder expressions and one ordinary result Structure; no new values runtime. |
| [S16](S16_comparision.md) | Explicit shape paths | Ordinary field/index arithmetic is shortest; no invented recursive operand argument expansion. |
| [S17](S17_comparision.md) | Mask plus explicit variadic Expression | One compress selects odd values before squaring; (+ 0 copy(odd * odd)) removes the accumulator loop without evaluating excluded squares. |
| [S18](S18_comparision.md) | Native structural object methods | Keep full object creation, copied method ownership and both calls. A prefix-shaped arithmetic-only driver would omit the object task. |
| [S19](S19_comparision.md) | Native stateful accessor task | Preserve the actual copied owner, unchanged height and updated width. Operand placement cannot substitute for these observations. |
| [S20](S20_comparision.md) | One computed binding | Producer runs once, the saved value is reused; arbitrary macroexpansion is not claimed. |
| [S21](S21_comparision.md) | Exact declared failure | Catch only InputFailure with ordinary typed flow; eager asOperand does not manufacture a control-flow operator. |
| [S22](S22_comparision.md) | One Event body and finally | Acquire/action/release differ only in data; exact ResourceFailure carries phase, with release overriding action failure as required. |
| [S23](S23_comparision.md) | Explicit cache at the same comparison level | One cache implementation, fresh per call. Ready memoize remains separately costed and is not compared as an ANSI builtin. |
| [S24](S24_comparision.md) | Existing Message protocol | No spawn/await/parser mode invented. Full host fixture remains pending; notation changes do not erase its cost. |

S11 использует именно явный поток `copy(items)`, а не неявное раскрытие готового Array. S17 сначала отбирает значения, поэтому не вычисляет потенциально лишние квадраты чётных элементов. У короткого замыкания, объектов, исключений и Message сохраняются все наблюдаемые части договора.

Основания: [Expression](../../../LMX_semantics.en.md#assignment-inside-expression), [структурный operand](../../../LMX_semantics.en.md#operand-receiver), [prepared values](../../../LMX_semantics.en.md#prepared-operands), [явный stream](../../../LMX_semantics.en.md#stream-or-group). [Точная машинная запись и hashes](validation/expression_review.json); [ТЗ и runtime-приёмка](TZ_Standard_Lisp_and_Expression.md).
