# J08. Все промежуточные суммы с начальным значением

## Общий договор

Вернуть seed, затем результат каждого последовательного прибавления. Длина результата length(xs)+1; на пустом входе [seed].

accumulate не возвращает init отдельным первым элементом; его добавление явно входит в Julia-код.

Вход:

```json
{
  "xs": [
    1,
    2,
    3
  ],
  "seed": 10
}
```

Ожидаемое наблюдение:

```json
[
  10,
  11,
  13,
  16
]
```

## LMX

```lmx
Add:
    int: left
    int: right
    return: int
    add:
        return: left + right

Example:
    int[]: xs
    int: seed
    return: @
    run:
        throws: FxCallFailure FxKernelFailure FxRecordArity FxTypeToken ReceiverIndex SequenceSize
        return: scanl(xs; (seed record); Add\add)
```

## Julia

```julia
example(xs, seed) = [seed; accumulate(+, xs; init=seed)]
```

## Размер полного клиента

| Язык | Без пробельных символов | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: |
| LMX | 209 | 13 | 298 |
| Julia | 50 | 1 | 57 |

## Реализации использованного ядра

- `scanl`: [полная пара реализации](library_comparisons/JI01_comparision.md)
- `record`: [полная пара реализации](library_comparisons/JI01_comparision.md)

Julia-клиент использует реальные Base/пакет; реализации из library_comparisons он не импортирует. [Общие зависимости и границы](library_comparisons/README.md) учитываются отдельно. Код проверен как текст и по договорам; исполнение LMX/Julia здесь не заявлено.

## Первичные источники

- [https://docs.julialang.org/en/v1/base/arrays/](https://docs.julialang.org/en/v1/base/arrays/)
