# J16. Количество выполнений предиката

## Общий договор

Посчитать чётные элементы; ноль и отрицательные чётные учитываются. Исходный массив сохраняется.



Вход:

```json
{
  "xs": [
    -2,
    -1,
    0,
    3,
    4
  ]
}
```

Ожидаемое наблюдение:

```json
3
```

## LMX

```lmx
Even:
    int: value
    return: int
    accepts:
        return: value % 2 = 0

Example:
    int[]: xs
    return: int
    run:
        throws: copy(FxThrows\predicate)
        return: count(xs; Even\accepts)
```

## Julia

```julia
example(xs) = count(iseven, xs)
```

## Размер полного клиента

| Язык | Без пробельных символов | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: |
| LMX | 138 | 11 | 210 |
| Julia | 28 | 1 | 32 |

## Реализации использованного ядра

- `count`: [полная пара реализации](library_comparisons/JI01_comparision.md)

Julia-клиент использует реальные Base/пакет; реализации из library_comparisons он не импортирует. [Общие зависимости и границы](library_comparisons/README.md) учитываются отдельно. Код проверен как текст и по договорам; исполнение LMX/Julia здесь не заявлено.

## Первичные источники

- [https://docs.julialang.org/en/v1/base/collections/](https://docs.julialang.org/en/v1/base/collections/)
