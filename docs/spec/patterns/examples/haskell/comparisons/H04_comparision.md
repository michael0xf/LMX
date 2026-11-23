# H04. Overrideable copied default

## Общий договор

Complete four-probe fixture: absent default gives 6; explicit 25 gives 26; explicit zero gives 1; the repeated absent default is still 6. Haskell uses explicit Maybe Int; LMX uses copied DATA defaults and named override. These different representations preserve all four observed values and do not mutate the saved default. The listing includes the exact fixture expression from main after the helper; it is a declaration-plus-expression fragment of the unchanged complete module, not a new independently compiled module.

Процедурный вариант сохраняет четыре наблюдения по шагам; функциональный непосредственно компонует их. Оба проверяют отсутствующий аргумент, явные25/0 и повторное значение по умолчанию.

## LMX — процедурный

```lmx
Addition:
    int: x
    int: y
    return: int
    add:
        return: x + y

DefaultProbe:
    return: int
    run:
        int: y 100
        @: fiveContext (merge(Addition; (int: y 5)))
        @: add5 fiveContext\add
        int: first add5(1)
        int: second add5(1; y := 25)
        int: third add5(1; y := 0)
        int: fourth add5(1)
        return: first * 1000000 + second * 10000 + third * 100 + fourth
```

[Полный исходник](../../lmx/procedural/H04.lm3)

## LMX — функциональный

```lmx
Addition:
    int: x
    int: y
    return: int
    add:
        return: x + y

DefaultProbe:
    return: int
    run:
        int: y 100
        @: fiveContext (merge(Addition; (int: y 5)))
        @: add5 fiveContext\add
        return: add5(1) * 1000000 + add5(1; y := 25) * 10000 + add5(1; y := 0) * 100 + add5(1)
```

[Полный исходник](../../lmx/H04.lm3)

## Haskell

```haskell
addWithDefault :: Int -> Maybe Int -> Int
addWithDefault x supplied = x + maybe 5 id supplied

    (map (addWithDefault 1) [Nothing, Just 25, Just 0, Nothing])
```

## Размер полного текста

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 265 | 17 |
| LMX — функциональный | 205 | 13 |
| Haskell | **128** | 3 |

Обе LMX-записи учитываются целиком, включая объявления, общие локальные helpers и Throws. Ошибки не исключаются из подсчёта. Общая реализация ядра не размножается ради стилей. Существующий статус иностранной пары/аналогии сохранён.

Runtime LMX: NOT_RUN. Это публикация исходников, договоров и полных размеров, не новый parser/runtime receipt.
