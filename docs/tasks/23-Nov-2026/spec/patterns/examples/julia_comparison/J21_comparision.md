# J21. Первые уникальные значения

## Общий договор

Оставить первое появление каждого целого, сохранив порядок. Вход не меняется.

Для данного целочисленного домена равенство LMX и isequal Julia совпадают. Обобщённая LMX-функция принимает явный предикат и не предполагает наличие hash.

Вход:

```json
{
  "xs": [
    3,
    1,
    3,
    2,
    1,
    4
  ]
}
```

Ожидаемое наблюдение:

```json
[
  3,
  1,
  2,
  4
]
```

## LMX

```lmx
Equal:
    int: left
    int: right
    return: int
    same:
        return: left = right

Example:
    int[]: xs
    return: @
    run:
        throws: FxCallFailure FxKernelFailure FxPredicate FxTypeToken ReceiverIndex SequenceElement SequenceSize
        return: unique(xs; Equal\same)
```

## Julia

```julia
example(xs) = unique(xs)
```

## Размер полного клиента

| Язык | Без пробельных символов | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: |
| LMX | 208 | 12 | 290 |
| Julia | 22 | 1 | 25 |

## Реализации использованного ядра

- `unique`: [полная пара реализации](library_comparisons/JI04_comparision.md)

Julia-клиент использует реальные Base/пакет; реализации из library_comparisons он не импортирует. [Общие зависимости и границы](library_comparisons/README.md) учитываются отдельно. Код проверен как текст и по договорам; исполнение LMX/Julia здесь не заявлено.

## Первичные источники

- [https://docs.julialang.org/en/v1/base/collections/](https://docs.julialang.org/en/v1/base/collections/)
