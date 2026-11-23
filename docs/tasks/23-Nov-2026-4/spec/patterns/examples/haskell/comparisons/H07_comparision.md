# H07. Prepared value versus raw source occurrence

## Общий договор

The complete numeric/call-count series is present, but its raw side explicitly repeats an IO action. It does not accept an arbitrary raw source occurrence or evaluate the retained source graph via sys\eval. The guide expressly keeps the lazy example separate from raw-occurrence semantics.

Это проверка prepared/raw ролей и повторного вычисления исходного occurrence. Замена сохраняемого узла на lambda или заранее вычисленное значение изменила бы договор, поэтому минимальная запись общая.

Обоим стилям соответствует одна минимальная форма, необходимая для проверяемого низкоуровневого договора. Её исходник и листинг приведены один раз, значения в обоих столбцах равны. Два разных алгоритма не заявляются.

## LMX — общая минимальная форма обоих стилей

```lmx
PreparedOps:
    copy: sys\OPERANDS_TEMPLATE
    return: int
    twice:
        return: \left + \left

RawOps:
    merge: sys\OPERANDS_TEMPLATE (const: int: PASS_ARGS_AS_IS 1)
    return: int
    twice:
        return: sys\eval(left) + sys\eval(left)

Meter:
    int: calls 0
    return: int
    next:
        node\calls += 1
        return: node\calls

Evaluation:
    return: int
    prepared:
        return: (Meter\next() PreparedOps\twice 0)
    raw:
        return: (Meter\next() RawOps\twice 0)
```

[Полный исходник](../../lmx/H07.lm3)

## Haskell

Сопоставимого существующего листинга для этого договора нет. Новая иностранная реализация не сочиняется; статус остаётся lmx_only.

## Размер полного текста

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | **354** | 22 |
| LMX — функциональный | **354** | 22 |

Обе LMX-записи учитываются целиком, включая объявления, общие локальные helpers и Throws. Ошибки не исключаются из подсчёта. Общая реализация ядра не размножается ради стилей. Существующий статус иностранной пары/аналогии сохранён.

Runtime LMX: NOT_RUN. Это публикация исходников, договоров и полных размеров, не новый parser/runtime receipt.
