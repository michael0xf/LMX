# R09. Uninitialized payload and local versus graph write

## Общий договор

The module contains no counterpart for uninitialized zero-payload primitive/reference records or the distinct local and graph write paths.

Неинициализированные поля и отдельные пути локальной/графовой записи нельзя заменить значениями-константами. Минимальная форма одинакова.

Обоим стилям соответствует одна минимальная форма, необходимая для проверяемого низкоуровневого договора. Её исходник и листинг приведены один раз, значения в обоих столбцах равны. Два разных алгоритма не заявляются.

## LMX — общая минимальная форма обоих стилей

```lmx
UninitializedGraph:
    int: number
    @: reference
    return: int
    localWrite:
        number := 5
        return: number
    graphWrite:
        UninitializedGraph\number := 5
        return: UninitializedGraph\number

ReadyValues:
    int: number 0
    @: reference 0
```

[Полный исходник](../../lmx/R09.lm3)

## Haskell

Сопоставимого существующего листинга для этого договора нет. Новая иностранная реализация не сочиняется; статус остаётся lmx_only.

## Размер полного текста

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | **189** | 13 |
| LMX — функциональный | **189** | 13 |

Обе LMX-записи учитываются целиком, включая объявления, общие локальные helpers и Throws. Ошибки не исключаются из подсчёта. Общая реализация ядра не размножается ради стилей. Существующий статус иностранной пары/аналогии сохранён.

Runtime LMX: NOT_RUN. Это публикация исходников, договоров и полных размеров, не новый parser/runtime receipt.
