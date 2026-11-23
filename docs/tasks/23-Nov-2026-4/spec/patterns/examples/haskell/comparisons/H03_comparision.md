# H03. Independent bound prefixes and residual callable admission

## Общий договор

Complete captured-prefix fixture: add5 and add100 are independent, their results are 6,101,6, and the original addition remains unchanged. Haskell values are immutable and native partial application exposes only the remaining argument. The LMX-specific explicit saved actual is rejected by its residual signature; Haskell has no such named formal and rejects that spelling statically. This admission-language difference is recorded separately and does not subtract the matching successful fixture.

Процедурный вариант целиком показывает отдельные копии окружения и прямой вызов. Функциональный использует общий partial; сохранённый вход не становится доступным именованным аргументом остаточной функции.

## LMX — процедурный

```lmx
CapturePrototype:
    int: saved 0
    @: binary 0
    inputs:
        int: second
        return: int
        apply:
            return: node\binary(node\saved; second)

Curry:
    @: binary
    int: first
    return: @
    capture:
        @: instance (copy(CapturePrototype))
        @: owner parent(instance\inputs)
        owner\saved := first
        owner\binary := binary
        return: instance\inputs\apply

Addition:
    int: first
    int: second
    return: int
    add:
        return: first + second

ClosureProbe:
    return: int
    run:
        @: add5 Curry\capture(Addition\add; 5)
        @: add100 Curry\capture(Addition\add; 100)
        int: saved 1000
        return: add5(1) * 1000000 + add100(1) * 1000 + add5(1)
```

[Полный исходник](../../lmx/procedural/H03.lm3)

## LMX — функциональный

```lmx
Addition:
    int: first
    int: second
    return: int
    add:
        return: first + second

ClosureProbe:
    return: int
    run:
        throws: copy(FxPartial\partial\throws)
        @: add5 partial(Addition\add; (5))
        @: add100 partial(Addition\add; (100))
        int: saved 1000
        return: add5(1) * 1000000 + add100(1) * 1000 + add5(1)
```

[Полный исходник](../../lmx/H03.lm3)

## Haskell

```haskell
makeAdder :: Int -> Int -> Int
makeAdder n = (+) n

closureExample :: (Int, Int, Int)
closureExample =
  let add5 = makeAdder 5
      add100 = makeAdder 100
  in (add5 1, add100 1, add5 1)
```

## Размер полного текста

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 495 | 31 |
| LMX — функциональный | 249 | 14 |
| Haskell | **143** | 7 |

Обе LMX-записи учитываются целиком, включая объявления, общие локальные helpers и Throws. Ошибки не исключаются из подсчёта. Общая реализация ядра не размножается ради стилей. Существующий статус иностранной пары/аналогии сохранён.

Runtime LMX: NOT_RUN. Это публикация исходников, договоров и полных размеров, не новый parser/runtime receipt.
