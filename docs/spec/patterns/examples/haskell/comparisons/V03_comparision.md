# V03. Inject a read dependency and check interaction counts

## Общий договор

The Good/Biased/ReadsTwice fixtures and read counts are represented. However, the Haskell checker takes a closed SampleVariant rather than the arbitrary candidate callable accepted by the LMX checker, and passes its read dependency explicitly. Treating it as a complete generic injection/checker implementation would overstate the existing source.

Процедурный вариант ветвится по результату; функциональный соединяет проверки выражением. Сам candidate вызывается ровно один раз, счётчик чтений сохраняется.

## LMX — процедурный

```lmx
Measurement:
    int: gain
    @: read
    return: int
    sample:
        return: read() * gain
    biased:
        return: sample() + 1
    readsTwice:
        int: discarded read()
        return: sample()

SamplingCheck:
    @: candidate
    int: calls 0
    return: int
    fixedRead:
        node\calls += 1
        return: 7
    check:
        node\calls := 0
        @: read fixedRead
        int: result candidate(gain := 4)
        if: result != 28
            return: 0
        return: node\calls = 1
```

[Полный исходник](../../lmx/procedural/V03.lm3)

## LMX — функциональный

```lmx
Measurement:
    int: gain
    @: read
    return: int
    sample:
        return: read() * gain
    biased:
        return: sample() + 1
    readsTwice:
        int: discarded read()
        return: sample()

SamplingCheck:
    @: candidate
    int: calls 0
    return: int
    fixedRead:
        node\calls += 1
        return: 7
    check:
        node\calls := 0
        @: read fixedRead
        int: result candidate(gain := 4)
        return: result = 28 && node\calls = 1
```

[Полный исходник](../../lmx/V03.lm3)

## Haskell

Сопоставимого существующего листинга для этого договора нет. Новая иностранная реализация не сочиняется; статус остаётся lmx_only.

## Размер полного текста

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 308 | 25 |
| LMX — функциональный | **298** | 23 |

Обе LMX-записи учитываются целиком, включая объявления, общие локальные helpers и Throws. Ошибки не исключаются из подсчёта. Общая реализация ядра не размножается ради стилей. Существующий статус иностранной пары/аналогии сохранён.

Runtime LMX: NOT_RUN. Это публикация исходников, договоров и полных размеров, не новый parser/runtime receipt.
