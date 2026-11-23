# J07. Левая свёртка с неассоциативным шагом

## Общий договор

Последовательно вычитать элементы из seed: ((seed - x0) - x1) ... . Пустой вход возвращает seed. Арифметика без переполнения.

Используется foldl, а не reduce: порядок связывания входит в контракт.

Вход:

```json
{
  "xs": [
    1,
    2,
    3
  ],
  "seed": 100
}
```

Ожидаемое наблюдение:

```json
94
```

## LMX

```lmx
Subtract:
    int: left
    int: right
    return: int
    subtract:
        return: left - right

Example:
    int[]: xs
    int: seed
    return: int
    run:
        throws: FxCallFailure FxKernelFailure FxRecordArity FxTypeToken ReceiverIndex
        return: \foldl(xs; (seed record); Subtract\subtract)
```

## Julia

```julia
example(xs, seed) = foldl(-, xs; init=seed)
```

## Размер полного клиента

| Язык | Без пробельных символов | Без сложного Throws | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: | ---: |
| LMX | 220 | 168 | 13 | 308 |
| Julia | 38 | 38 | 1 | 44 |

Дополнительная колонка оставляет заголовок и первый аргумент Throws; copy(Throws) сохраняется целиком. Полный исходник и его основной счёт не изменяются.

## Реализации использованного ядра

- `foldl`: [полная пара реализации](library_comparisons/JI01_comparision.md)
- `record`: [полная пара реализации](library_comparisons/JI01_comparision.md)

Julia-клиент использует реальные Base/пакет; реализации из library_comparisons он не импортирует. [Общие зависимости и границы](library_comparisons/README.md) учитываются отдельно. Код проверен как текст и по договорам; исполнение LMX/Julia здесь не заявлено.

## Первичные источники

- [https://docs.julialang.org/en/v1/base/collections/](https://docs.julialang.org/en/v1/base/collections/)
