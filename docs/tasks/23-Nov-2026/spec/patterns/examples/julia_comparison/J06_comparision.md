# J06. Стабильный отбор нечётных

## Общий договор

Сохранить все нечётные целые в исходном порядке, включая отрицательные.



Вход:

```json
{
  "xs": [
    -3,
    -2,
    0,
    1,
    4,
    5
  ]
}
```

Ожидаемое наблюдение:

```json
[
  -3,
  1,
  5
]
```

## LMX

```lmx
Odd:
    int: value
    return: int
    accepts:
        return: value % 2 != 0

Example:
    int[]: xs
    return: @
    run:
        throws: copy(FxThrows\traversal)
        return: filter(xs; Odd\accepts)
```

## Julia

```julia
example(xs) = filter(isodd, xs)
```

## Размер полного клиента

| Язык | Без пробельных символов | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: |
| LMX | 136 | 11 | 208 |
| Julia | 28 | 1 | 32 |

## Реализации использованного ядра

- `filter`: [полная пара реализации](library_comparisons/JI01_comparision.md)

Julia-клиент использует реальные Base/пакет; реализации из library_comparisons он не импортирует. [Общие зависимости и границы](library_comparisons/README.md) учитываются отдельно. Код проверен как текст и по договорам; исполнение LMX/Julia здесь не заявлено.

## Первичные источники

- [https://docs.julialang.org/en/v1/base/collections/](https://docs.julialang.org/en/v1/base/collections/)
