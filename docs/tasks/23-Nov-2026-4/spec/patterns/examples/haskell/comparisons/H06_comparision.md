# H06. Order of two composed computations

## Общий договор

Complete for the selected primary LMX listing: next(twice(4)) is 9 and twice(next(4)) is 10. The existing Haskell composition expression preserves both orders. The separate effectful stage-order fixture and the LMX pipe variant are additional material, not silently substituted into this ratio.

Процедурный вариант явно хранит промежуточные стадии; функциональный использует краткие вложенные вызовы. Обе последовательности наблюдаются: next(twice(4))=9 и twice(next(4))=10.

## LMX — процедурный

```lmx
Functions:
    int: x
    return: int
    twice:
        return: x * 2
    next:
        return: x + 1

CompositionProbe:
    return: int
    run:
        int: first Functions\twice(4)
        first := Functions\next(first)
        int: second Functions\next(4)
        second := Functions\twice(second)
        return: first * 100 + second
```

[Полный исходник](../../lmx/procedural/H06.lm3)

## LMX — функциональный

```lmx
Functions:
    int: x
    return: int
    twice:
        return: x * 2
    next:
        return: x + 1

CompositionProbe:
    return: int
    run:
        return: Functions\next(Functions\twice(4)) * 100 + Functions\twice(Functions\next(4))
```

[Полный исходник](../../lmx/H06.lm3)

## Haskell

```haskell
compositionFactoryExample :: (Int, Int)
compositionFactoryExample = (((+1) . (*2)) 4, ((*2) . (+1)) 4)
```

## Размер полного текста

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 223 | 15 |
| LMX — функциональный | 167 | 11 |
| Haskell | **89** | 2 |

Обе LMX-записи учитываются целиком, включая объявления, общие локальные helpers и Throws. Ошибки не исключаются из подсчёта. Общая реализация ядра не размножается ради стилей. Существующий статус иностранной пары/аналогии сохранён.

Runtime LMX: NOT_RUN. Это публикация исходников, договоров и полных размеров, не новый parser/runtime receipt.
