# J11. Плоское разворачивание результатов

## Общий договор

Для каждого целого x получить пару [x, x*x] и объединить пары по порядку. Происходит ровно одно разворачивание внешнего результата callback.

Julia требует 1.9 или новее для Iterators.flatmap. LMX возвращает обычную структуру как Array<@>; отдельный контейнер items не создаётся.

Вход:

```json
{
  "xs": [
    2,
    -3
  ]
}
```

Ожидаемое наблюдение:

```json
[
  2,
  4,
  -3,
  9
]
```

## LMX

```lmx
Expand:
    int: x
    return: @
    expand:
        return: (x; x * x)

Example:
    int[]: xs
    return: @
    run:
        throws: copy(FxThrows\traversal)
        return: flatMap(xs; Expand\expand)
```

## Julia

```julia
example(xs) = collect(Iterators.flatmap(x -> (x, x * x), xs))
```

## Размер полного клиента

| Язык | Без пробельных символов | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: |
| LMX | 132 | 11 | 203 |
| Julia | 53 | 1 | 62 |

## Реализации использованного ядра

- `flatMap`: [полная пара реализации](library_comparisons/JI01_comparision.md)

Julia-клиент использует реальные Base/пакет; реализации из library_comparisons он не импортирует. [Общие зависимости и границы](library_comparisons/README.md) учитываются отдельно. Код проверен как текст и по договорам; исполнение LMX/Julia здесь не заявлено.

## Первичные источники

- [https://docs.julialang.org/en/v1/base/iterators/](https://docs.julialang.org/en/v1/base/iterators/)
