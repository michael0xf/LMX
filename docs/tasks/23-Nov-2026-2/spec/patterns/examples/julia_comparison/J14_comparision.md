# J14. Все значения положительны

## Общий договор

Истина, если каждый элемент больше нуля. Пустой вход даёт истину; просмотр заканчивается после первого отказа.



Вход:

```json
{
  "xs": [
    1,
    2,
    3
  ]
}
```

Ожидаемое наблюдение:

```json
true
```

## LMX

```lmx
Positive:
    int: value
    return: int
    accepts:
        return: value > 0

Example:
    int[]: xs
    return: int
    run:
        throws: copy(FxThrows\predicate)
        return: all(xs; Positive\accepts)
```

## Julia

```julia
example(xs) = all(x -> x > 0, xs)
```

## Размер полного клиента

| Язык | Без пробельных символов | Без сложного Throws | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: | ---: |
| LMX | 142 | 142 | 11 | 212 |
| Julia | 26 | 26 | 1 | 34 |

Дополнительная колонка оставляет заголовок и первый аргумент Throws; copy(Throws) сохраняется целиком. Полный исходник и его основной счёт не изменяются.

## Реализации использованного ядра

- `all`: [полная пара реализации](library_comparisons/JI01_comparision.md)

Julia-клиент использует реальные Base/пакет; реализации из library_comparisons он не импортирует. [Общие зависимости и границы](library_comparisons/README.md) учитываются отдельно. Код проверен как текст и по договорам; исполнение LMX/Julia здесь не заявлено.

## Первичные источники

- [https://docs.julialang.org/en/v1/base/collections/](https://docs.julialang.org/en/v1/base/collections/)
