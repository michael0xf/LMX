# J09. Парное прохождение до короткого входа

## Общий договор

Материализовать пары соответствующих элементов. Результат заканчивается вместе с более коротким входом; входы не меняются.

Наблюдение нормализует FxPair{first,second} и Julia Tuple к паре значений. Ленивый zip в Julia явно материализован.

Вход:

```json
{
  "left": [
    1,
    2,
    3
  ],
  "right": [
    "a",
    "b"
  ]
}
```

Ожидаемое наблюдение:

```json
[
  [
    1,
    "a"
  ],
  [
    2,
    "b"
  ]
]
```

## LMX

```lmx
Example:
    @: left
    @: right
    return: @
    run:
        throws: copy(FxThrows\sequence)
        return: zip(left; right)
```

## Julia

```julia
example(left, right) = collect(zip(left, right))
```

## Размер полного клиента

| Язык | Без пробельных символов | Без сложного Throws | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: | ---: |
| LMX | 85 | 85 | 7 | 130 |
| Julia | 44 | 44 | 1 | 49 |

Дополнительная колонка оставляет заголовок и первый аргумент Throws; copy(Throws) сохраняется целиком. Полный исходник и его основной счёт не изменяются.

## Реализации использованного ядра

- `zip`: [полная пара реализации](library_comparisons/JI01_comparision.md)

Julia-клиент использует реальные Base/пакет; реализации из library_comparisons он не импортирует. [Общие зависимости и границы](library_comparisons/README.md) учитываются отдельно. Код проверен как текст и по договорам; исполнение LMX/Julia здесь не заявлено.

## Первичные источники

- [https://docs.julialang.org/en/v1/base/iterators/](https://docs.julialang.org/en/v1/base/iterators/)
