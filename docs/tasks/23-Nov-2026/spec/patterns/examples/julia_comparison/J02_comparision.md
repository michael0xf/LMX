# J02. Копия среза

## Общий договор

Создать новый внешний массив для нулевого полуинтервала [lo, hi). Требуется 0 <= lo <= hi <= length(xs). Ссылочные элементы сохраняют свои цели.

Перевод индексов оплачивается в Julia-клиенте. Это копия внешнего массива, а не view и не глубокая копия графа.

Вход:

```json
{
  "xs": [
    10,
    20,
    30,
    40,
    50
  ],
  "lo": 1,
  "hi": 4
}
```

Ожидаемое наблюдение:

```json
[
  20,
  30,
  40
]
```

## LMX

```lmx
Example:
    @: xs
    int: lo
    int: hi
    return: @
    run:
        throws: copy(FxThrows\sequence)
        return: slice(xs; lo; hi)
```

## Julia

```julia
function example(xs, lo, hi)
    0 <= lo <= hi <= length(xs) || throw(BoundsError(xs, lo:hi))
    xs[lo + 1:hi]
end
```

## Размер полного клиента

| Язык | Без пробельных символов | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: |
| LMX | 88 | 8 | 140 |
| Julia | 90 | 4 | 116 |

## Реализации использованного ядра

- `slice`: [полная пара реализации](library_comparisons/JI02_comparision.md)

Julia-клиент использует реальные Base/пакет; реализации из library_comparisons он не импортирует. [Общие зависимости и границы](library_comparisons/README.md) учитываются отдельно. Код проверен как текст и по договорам; исполнение LMX/Julia здесь не заявлено.

## Первичные источники

- [https://docs.julialang.org/en/v1/base/arrays/](https://docs.julialang.org/en/v1/base/arrays/)
