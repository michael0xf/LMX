# J03. Разворот без изменения входа

## Общий договор

Вернуть элементы в обратном порядке в новом внешнем массиве; исходный массив сохраняется.



Вход:

```json
{
  "xs": [
    1,
    2,
    3,
    4
  ]
}
```

Ожидаемое наблюдение:

```json
[
  4,
  3,
  2,
  1
]
```

## LMX

```lmx
Example:
    @: xs
    return: @
    run:
        throws: copy(FxThrows\sequence)
        return: reverse(xs)
```

## Julia

```julia
example(xs) = reverse(xs)
```

## Размер полного клиента

| Язык | Без пробельных символов | Без сложного Throws | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: | ---: |
| LMX | 72 | 72 | 6 | 110 |
| Julia | 23 | 23 | 1 | 26 |

Дополнительная колонка оставляет заголовок и первый аргумент Throws; copy(Throws) сохраняется целиком. Полный исходник и его основной счёт не изменяются.

## Реализации использованного ядра

- `reverse`: [полная пара реализации](library_comparisons/JI02_comparision.md)

Julia-клиент использует реальные Base/пакет; реализации из library_comparisons он не импортирует. [Общие зависимости и границы](library_comparisons/README.md) учитываются отдельно. Код проверен как текст и по договорам; исполнение LMX/Julia здесь не заявлено.

## Первичные источники

- [https://docs.julialang.org/en/v1/base/arrays/](https://docs.julialang.org/en/v1/base/arrays/)
- [https://docs.julialang.org/en/v1/base/collections/](https://docs.julialang.org/en/v1/base/collections/)
