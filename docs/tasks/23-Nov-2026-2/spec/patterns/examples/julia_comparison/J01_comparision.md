# J01. Полуоткрытый диапазон с направлением

## Общий договор

Конечная последовательность машинных целых start + k*step до исключённой границы stop. step не равен нулю; направление может быть любым. Размер результата должен помещаться в массив.

Julia-диапазон включает достижимую правую границу; takewhile явно удаляет её. Код не вычисляет stop - 1, который мог бы переполниться.

Вход:

```json
{
  "start": 1,
  "stop": 8,
  "step": 2
}
```

Ожидаемое наблюдение:

```json
[
  1,
  3,
  5,
  7
]
```

## LMX

```lmx
Example:
    int: start
    int: stop
    int: step
    return: @
    run:
        throws: FxKernelFailure FxTypeToken SequenceSize SequenceStep
        return: range(start; stop; step)
```

## Julia

```julia
example(start::Int, stop::Int, step::Int) =
    collect(Iterators.takewhile(x -> step > 0 ? x < stop : x > stop,
                               start:step:stop))
```

## Размер полного клиента

| Язык | Без пробельных символов | Без сложного Throws | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: | ---: |
| LMX | 131 | 96 | 8 | 186 |
| Julia | 109 | 109 | 3 | 162 |

Дополнительная колонка оставляет заголовок и первый аргумент Throws; copy(Throws) сохраняется целиком. Полный исходник и его основной счёт не изменяются.

## Реализации использованного ядра

- `range`: [полная пара реализации](library_comparisons/JI02_comparision.md)

Julia-клиент использует реальные Base/пакет; реализации из library_comparisons он не импортирует. [Общие зависимости и границы](library_comparisons/README.md) учитываются отдельно. Код проверен как текст и по договорам; исполнение LMX/Julia здесь не заявлено.

## Первичные источники

- [https://docs.julialang.org/en/v1/base/collections/](https://docs.julialang.org/en/v1/base/collections/)
- [https://docs.julialang.org/en/v1/base/iterators/](https://docs.julialang.org/en/v1/base/iterators/)
