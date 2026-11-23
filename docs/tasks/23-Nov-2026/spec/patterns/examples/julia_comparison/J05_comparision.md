# J05. Квадраты через comprehension

## Общий договор

Вычислить квадрат каждого целого слева направо. Значения выбраны без переполнения, исходный массив сохраняется.

В Julia выбран естественный comprehension. LMX использует общий map; упаковка результатов в @-записи не подменяется плотным int[] в подсчёте.

Вход:

```json
{
  "xs": [
    -3,
    0,
    4
  ]
}
```

Ожидаемое наблюдение:

```json
[
  9,
  0,
  16
]
```

## LMX

```lmx
Square:
    int: value
    return: int
    square:
        return: value * value

Example:
    int[]: xs
    return: @
    run:
        throws: copy(FxThrows\traversal)
        return: map(xs; Square\square)
```

## Julia

```julia
example(xs) = [x * x for x in xs]
```

## Размер полного клиента

| Язык | Без пробельных символов | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: |
| LMX | 138 | 11 | 208 |
| Julia | 25 | 1 | 34 |

## Реализации использованного ядра

- `map`: [полная пара реализации](library_comparisons/JI01_comparision.md)

Julia-клиент использует реальные Base/пакет; реализации из library_comparisons он не импортирует. [Общие зависимости и границы](library_comparisons/README.md) учитываются отдельно. Код проверен как текст и по договорам; исполнение LMX/Julia здесь не заявлено.

## Первичные источники

- [https://docs.julialang.org/en/v1/manual/arrays/](https://docs.julialang.org/en/v1/manual/arrays/)
