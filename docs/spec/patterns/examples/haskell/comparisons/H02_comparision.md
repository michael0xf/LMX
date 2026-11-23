# H02. Named signature positions versus candidate names

## Общий договор

No current Haskell definition checks differently named positional signatures, explicit candidate names and the resulting 2772 observation.

Процедурный вариант сохраняет результаты двух вызовов явно; функциональный объединяет их арифметическим выражением. Позиционное принятие сигнатуры и именованные аргументы проверяются одинаково.

## LMX — процедурный

```lmx
PairOperation :: (int: a; int: b; return: int)

Candidate:
    int: b
    int: a
    return: int
    encode:
        return: b * 10 + a

SignatureProbe:
    return: int
    run:
        PairOperation@: selected Candidate\encode
        int: first selected(a := 2; b := 7)
        int: second Candidate\encode(a := 2; b := 7)
        return: first * 100 + second
```

[Полный исходник](../../lmx/procedural/H02.lm3)

## LMX — функциональный

```lmx
PairOperation :: (int: a; int: b; return: int)

Candidate:
    int: b
    int: a
    return: int
    encode:
        return: b * 10 + a

SignatureProbe:
    return: int
    run:
        PairOperation@: selected Candidate\encode
        return: selected(a := 2; b := 7) * 100 + Candidate\encode(a := 2; b := 7)
```

[Полный исходник](../../lmx/H02.lm3)

## Haskell

Сопоставимого существующего листинга для этого договора нет. Новая иностранная реализация не сочиняется; статус остаётся lmx_only.

## Размер полного текста

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 245 | 14 |
| LMX — функциональный | **215** | 12 |

Обе LMX-записи учитываются целиком, включая объявления, общие локальные helpers и Throws. Ошибки не исключаются из подсчёта. Общая реализация ядра не размножается ради стилей. Существующий статус иностранной пары/аналогии сохранён.

Runtime LMX: NOT_RUN. Это публикация исходников, договоров и полных размеров, не новый parser/runtime receipt.
