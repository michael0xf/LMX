# J13. Хотя бы одно превышение

## Общий договор

Вернуть логическую истину, если существует x > limit. Пустой вход даёт ложь; просмотр заканчивается после первого успеха.

limit разрешается в живом DATA вызывающего Example; исходник не копирует его в отдельную замкнутую структуру.

Вход:

```json
{
  "xs": [
    1,
    9,
    3
  ],
  "limit": 5
}
```

Ожидаемое наблюдение:

```json
true
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
    return: int
    run:
        throws: copy(FxThrows\predicate)
        return: any(xs; Above\accepts)
```

## Julia

```julia
example(xs, limit) = any(x -> x > limit, xs)
```

## Размер полного клиента

| Язык | Без пробельных символов | Без сложного Throws | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: | ---: |
| LMX | 149 | 149 | 12 | 225 |
| Julia | 36 | 36 | 1 | 45 |

Дополнительная колонка оставляет заголовок и первый аргумент Throws; copy(Throws) сохраняется целиком. Полный исходник и его основной счёт не изменяются.

## Реализации использованного ядра

- `any`: [полная пара реализации](library_comparisons/JI01_comparision.md)

Julia-клиент использует реальные Base/пакет; реализации из library_comparisons он не импортирует. [Общие зависимости и границы](library_comparisons/README.md) учитываются отдельно. Код проверен как текст и по договорам; исполнение LMX/Julia здесь не заявлено.

## Первичные источники

- [https://docs.julialang.org/en/v1/base/collections/](https://docs.julialang.org/en/v1/base/collections/)
