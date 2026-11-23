# R01. Merge an existing record and add a field

## Общий договор

The Haskell record update preserves width and changes height/depth, but Size declares depth before the update. LMX merge adds a previously absent field and preserves its source structures. The fixed-shape Haskell update cannot be labelled a complete dynamic record-extension pair.

Процедурный вариант использует прямой merge полей, функциональный — канонический derive. Оба добавляют отсутствовавшее поле depth и сохраняют исходные структуры.

## LMX — процедурный

```lmx
RecordModel:
    int: width 2
    int: height 3

RecordPatch:
    int: height 5
    int: depth 7

MergeProbe:
    return: int
    run:
        @: result (merge(RecordModel; RecordPatch))
        return: result\width * 100 + result\height * 10 + result\depth
```

[Полный исходник](../../lmx/procedural/R01.lm3)

## LMX — функциональный

```lmx
RecordModel:
    int: width 2
    int: height 3

RecordPatch:
    int: height 5
    int: depth 7

MergeProbe:
    return: int
    run:
        @: result derive(RecordModel; RecordPatch)
        return: result\width * 100 + result\height * 10 + result\depth
```

[Полный исходник](../../lmx/R01.lm3)

## Haskell

Сопоставимого существующего листинга для этого договора нет. Новая иностранная реализация не сочиняется; статус остаётся lmx_only.

## Размер полного текста

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 184 | 11 |
| LMX — функциональный | **183** | 11 |

Обе LMX-записи учитываются целиком, включая объявления, общие локальные helpers и Throws. Ошибки не исключаются из подсчёта. Общая реализация ядра не размножается ради стилей. Существующий статус иностранной пары/аналогии сохранён.

Runtime LMX: NOT_RUN. Это публикация исходников, договоров и полных размеров, не новый parser/runtime receipt.
