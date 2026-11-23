# R04. Computed initializer, local write and repeated activation

## Общий договор

The module has no counterpart for these computed local initializer and explicit graph/local-write cases. H07 IO actions are not reassigned as coverage for this different contract.

Инициализатор с побочным эффектом и различие локальной/графовой записи являются предметом проверки. Их порядок, число вызовов и два отдельных entry сохраняются одинаково.

Обоим стилям соответствует одна минимальная форма, необходимая для проверяемого низкоуровневого договора. Её исходник и листинг приведены один раз, значения в обоих столбцах равны. Два разных алгоритма не заявляются.

## LMX — общая минимальная форма обоих стилей

```lmx
ReadSource:
    int: calls 0
    return: int
    next:
        node\calls += 1
        return: 40 + node\calls

ComputedInput:
    int: value ReadSource\next()
    return: int
    changeLocal:
        int: seen value
        value := 99
        return: seen

LocalProbe:
    return: int
    run:
        ReadSource\calls := 0
        int: first ComputedInput\changeLocal()
        int: second ComputedInput\changeLocal()
        return: first * 100 + second
    explicitInitialization:
        ReadSource\calls := 0
        int: i
        i := ReadSource\next()
        i += 3
        return: i
```

[Полный исходник](../../lmx/R04.lm3)

## Haskell

Сопоставимого существующего листинга для этого договора нет. Новая иностранная реализация не сочиняется; статус остаётся lmx_only.

## Размер полного текста

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | **383** | 26 |
| LMX — функциональный | **383** | 26 |

Обе LMX-записи учитываются целиком, включая объявления, общие локальные helpers и Throws. Ошибки не исключаются из подсчёта. Общая реализация ядра не размножается ради стилей. Существующий статус иностранной пары/аналогии сохранён.

Runtime LMX: NOT_RUN. Это публикация исходников, договоров и полных размеров, не новый parser/runtime receipt.
