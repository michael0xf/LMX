# J20. Устойчивая сортировка записей

## Общий договор

Отсортировать записи по key, сохраняя порядок равных ключей, все остальные поля и исходный массив. Результат — новый внешний массив.

Компаратор вычитает два результата сравнения int 0/1, а не сами ключи: переполнения разности ключей нет. id наблюдает устойчивость; все поля сохраняются. Используется общий FxSort.

Вход:

```json
{
  "items": [
    {
      "key": 2,
      "id": "a"
    },
    {
      "key": 1,
      "id": "b"
    },
    {
      "key": 2,
      "id": "c"
    },
    {
      "key": 1,
      "id": "d"
    }
  ]
}
```

Ожидаемое наблюдение:

```json
[
  {
    "key": 1,
    "id": "b"
  },
  {
    "key": 1,
    "id": "d"
  },
  {
    "key": 2,
    "id": "a"
  },
  {
    "key": 2,
    "id": "c"
  }
]
```

## LMX

```lmx
Order:
    @: first
    @: second
    return: int
    compare:
        return: (first\key > second\key) - (first\key < second\key)

Example:
    @: items
    return: @
    run:
        throws: FxCallFailure FxKernelFailure FxTypeToken ReceiverIndex SequenceElement SequenceSize
        return: sort(items; Order\compare)
```

## Julia

```julia
example(items) = sort(items; by=item -> item.key)
```

## Размер полного клиента

| Язык | Без пробельных символов | Без сложного Throws | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: | ---: |
| LMX | 236 | 170 | 12 | 321 |
| Julia | 44 | 44 | 1 | 50 |

Дополнительная колонка оставляет заголовок и первый аргумент Throws; copy(Throws) сохраняется целиком. Полный исходник и его основной счёт не изменяются.

## Реализации использованного ядра

- `sort`: [полная пара реализации](library_comparisons/JI04_comparision.md)

Julia-клиент использует реальные Base/пакет; реализации из library_comparisons он не импортирует. [Общие зависимости и границы](library_comparisons/README.md) учитываются отдельно. Код проверен как текст и по договорам; исполнение LMX/Julia здесь не заявлено.

## Первичные источники

- [https://docs.julialang.org/en/v1/base/sort/](https://docs.julialang.org/en/v1/base/sort/)
