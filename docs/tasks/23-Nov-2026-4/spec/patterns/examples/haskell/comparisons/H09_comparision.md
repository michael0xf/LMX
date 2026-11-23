# H09. Finite iterator with a live declaration and body

## Общий договор

All observed iterator results agree: total 12, four next calls and three body calls. However, the only existing Haskell listing interleaves extra next/body counters with the algorithm, while the LMX source delegates those observations to its external fixture. A size ratio would charge harness instrumentation only to Haskell. No rewritten or shortened Haskell implementation has been invented; this is related_analogy because the current source counting boundaries cannot be matched exactly.

Принятая декларация и тело работают в живом контексте. Stop источника поглощается, Stop тела распространяется под исходным именем. Существующий общий адаптер имеет иной failure-envelope API, поэтому корректная минимальная форма здесь общая.

Обоим стилям соответствует одна минимальная форма, необходимая для проверяемого низкоуровневого договора. Её исходник и листинг приведены один раз, значения в обоих столбцах равны. Два разных алгоритма не заявляются.

## LMX — общая минимальная форма обоих стилей

```lmx
Cycles:
    @: iteration
    @: body
    iterate:
        while: 1
            iteration()
            catch: Stop ()
                break
            body()

Numbers:
    int: position 0
    return: int
    next:
        throws: Stop
        if: node\position >= 3
            throw: Stop()
        node\position += 1
        return: node\position
    demo:
        node\position := 0
        int: total 0
        Cycles\iterate: int: item Numbers\next()
            item *= 2
            total += item
        return: total
```

[Полный исходник](../../lmx/H09.lm3)

## Haskell

Сопоставимого существующего листинга для этого договора нет. Новая иностранная реализация не сочиняется; статус остаётся lmx_only.

## Размер полного текста

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | **285** | 25 |
| LMX — функциональный | **285** | 25 |

Обе LMX-записи учитываются целиком, включая объявления, общие локальные helpers и Throws. Ошибки не исключаются из подсчёта. Общая реализация ядра не размножается ради стилей. Существующий статус иностранной пары/аналогии сохранён.

Runtime LMX: NOT_RUN. Это публикация исходников, договоров и полных размеров, не новый parser/runtime receipt.
