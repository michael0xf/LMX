# J04. Отбор по числовой маске

## Общий договор

Сохранить элементы, чья маска ненулевая; порядок прежний. Длины xs и mask должны совпадать, mask состоит из целых.



Вход:

```json
{
  "xs": [
    10,
    20,
    30,
    40
  ],
  "mask": [
    1,
    0,
    -2,
    0
  ]
}
```

Ожидаемое наблюдение:

```json
[
  10,
  30
]
```

## LMX

```lmx
Example:
    @: xs
    int[]: mask
    return: @
    run:
        throws: FxKernelFailure FxShape FxTypeToken ReceiverIndex SequenceElement SequenceSize
        return: compress(xs; mask)
```

## Julia

```julia
function example(xs, mask)
    length(xs) == length(mask) || throw(DimensionMismatch("mask"))
    xs[mask .!= 0]
end
```

## Размер полного клиента

| Язык | Без пробельных символов | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: |
| LMX | 138 | 7 | 188 |
| Julia | 97 | 4 | 117 |

## Реализации использованного ядра

- `compress`: [полная пара реализации](library_comparisons/JI02_comparision.md)

Julia-клиент использует реальные Base/пакет; реализации из library_comparisons он не импортирует. [Общие зависимости и границы](library_comparisons/README.md) учитываются отдельно. Код проверен как текст и по договорам; исполнение LMX/Julia здесь не заявлено.

## Первичные источники

- [https://docs.julialang.org/en/v1/base/arrays/](https://docs.julialang.org/en/v1/base/arrays/)
- [https://docs.julialang.org/en/v1/manual/arrays/](https://docs.julialang.org/en/v1/manual/arrays/)
