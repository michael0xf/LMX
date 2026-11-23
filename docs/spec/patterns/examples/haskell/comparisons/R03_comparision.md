# R03. Imported parent identity versus copied parent identity

## Общий договор

No current Haskell implementation tests import-retained owner identity and copy-recouped parent identity.

Обязательны import исходного владельца, copy графа и запись в владельца копии. Эти наблюдаемые операции одинаковы; искусственная функциональная обвязка не вводится.

Обоим стилям соответствует одна минимальная форма, необходимая для проверяемого низкоуровневого договора. Её исходник и листинг приведены один раз, значения в обоих столбцах равны. Два разных алгоритма не заявляются.

## LMX — общая минимальная форма обоих стилей

```lmx
Provider:
    int: value 7
    return: int
    read:
        return: value

ImportProbe:
    return: int
    run:
        import: Provider
        int: value 99
        int: original read()
        @: copied (copy(Provider))
        @: copiedOwner parent(copied\read)
        copiedOwner\value := 12
        return: original * 100 + copied\read()
```

[Полный исходник](../../lmx/R03.lm3)

## Haskell

Сопоставимого существующего листинга для этого договора нет. Новая иностранная реализация не сочиняется; статус остаётся lmx_only.

## Размер полного текста

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | **226** | 15 |
| LMX — функциональный | **226** | 15 |

Обе LMX-записи учитываются целиком, включая объявления, общие локальные helpers и Throws. Ошибки не исключаются из подсчёта. Общая реализация ядра не размножается ради стилей. Существующий статус иностранной пары/аналогии сохранён.

Runtime LMX: NOT_RUN. Это публикация исходников, договоров и полных размеров, не новый parser/runtime receipt.
