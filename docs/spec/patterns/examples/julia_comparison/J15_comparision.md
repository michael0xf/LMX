# J15. Первый найденный индекс без sentinel

## Общий договор

Вернуть первый нулевой индекс x > limit либо отсутствие результата. Настоящий индекс 0 не смешивается с отсутствием.

LMX Maybe.present/value сопоставляется с Julia nothing/Int. Вычитание единицы применяется только к найденному индексу.

Вход:

```json
{
  "xs": [
    2,
    8,
    9
  ],
  "limit": 5
}
```

Ожидаемое наблюдение:

```json
{
  "present": true,
  "value": 1
}
```

## LMX

```lmx
Above:
    int: value
    return: int
    accepts:
        return: value > limit

Example:
    int[]: xs
    int: limit
    return: @
    run:
        throws: FxCallFailure FxKernelFailure FxPredicate FxRecordArity FxTypeToken ReceiverIndex
        return: index(xs; Above\accepts)
```

## Julia

```julia
function example(xs, limit)
    found = findfirst(x -> x > limit, xs)
    isnothing(found) ? nothing : found - 1
end
```

## Размер полного клиента

| Язык | Без пробельных символов | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: |
| LMX | 201 | 12 | 282 |
| Julia | 90 | 4 | 117 |

## Реализации использованного ядра

- `index`: [полная пара реализации](library_comparisons/JI01_comparision.md)

Julia-клиент использует реальные Base/пакет; реализации из library_comparisons он не импортирует. [Общие зависимости и границы](library_comparisons/README.md) учитываются отдельно. Код проверен как текст и по договорам; исполнение LMX/Julia здесь не заявлено.

## Первичные источники

- [https://docs.julialang.org/en/v1/base/arrays/](https://docs.julialang.org/en/v1/base/arrays/)
