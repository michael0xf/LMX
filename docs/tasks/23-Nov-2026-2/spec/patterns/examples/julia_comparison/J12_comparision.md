# J12. Группировка по чётности

## Общий договор

Разбить целые на группы odd=true/false, сохранить порядок элементов внутри каждой группы. Отсутствующие группы не создаются. Порядок обхода самих групп не сравнивается.

Клиент импортирует настоящий пакет SplitApplyCombine. LMX возвращает список {key,items}, Julia — Dictionary; сравниваются ключи и полные группы, без искусственного преобразования одного клиента в устройство другого.

Вход:

```json
{
  "xs": [
    3,
    2,
    5,
    4,
    3
  ]
}
```

Ожидаемое наблюдение:

```json
{
  "true": [
    3,
    5,
    3
  ],
  "false": [
    2,
    4
  ]
}
```

## LMX

```lmx
Parity:
    int: value
    return: int
    key:
        return: value % 2 != 0

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
        throws: FxCallFailure FxKernelFailure FxTypeToken ReceiverIndex SequenceElement SequenceSize
        return: groupBy(xs; Parity\key; Equal\same)
```

## Julia

```julia
using SplitApplyCombine: group
example(xs) = group(isodd, xs)
```

## Размер полного клиента

| Язык | Без пробельных символов | Без сложного Throws | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: | ---: |
| LMX | 256 | 190 | 17 | 371 |
| Julia | 55 | 55 | 2 | 62 |

Дополнительная колонка оставляет заголовок и первый аргумент Throws; copy(Throws) сохраняется целиком. Полный исходник и его основной счёт не изменяются.

## Реализации использованного ядра

- `groupBy`: [полная пара реализации](library_comparisons/JI04_comparision.md)

Julia-клиент использует реальные Base/пакет; реализации из library_comparisons он не импортирует. [Общие зависимости и границы](library_comparisons/README.md) учитываются отдельно. Код проверен как текст и по договорам; исполнение LMX/Julia здесь не заявлено.

## Первичные источники

- [https://github.com/JuliaData/SplitApplyCombine.jl#grouping](https://github.com/JuliaData/SplitApplyCombine.jl#grouping)
