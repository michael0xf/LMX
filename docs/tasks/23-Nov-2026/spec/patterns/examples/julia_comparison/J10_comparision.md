# J10. Слитное поэлементное выражение

## Общий договор

Для двух целочисленных векторов одинаковой длины вернуть 2*x + y*y по позициям. Арифметика без переполнения, callbacks не имеют эффектов.

Общий домен — равные длины. За его пределами zipWith обрезает до короткого входа, а broadcast имеет собственное расширение размерностей; эти возможности не названы тождественными.

Вход:

```json
{
  "left": [
    1,
    2,
    3
  ],
  "right": [
    4,
    5,
    6
  ]
}
```

Ожидаемое наблюдение:

```json
[
  18,
  29,
  42
]
```

## LMX

```lmx
Combine:
    int: x
    int: y
    return: int
    combine:
        return: 2 * x + y * y

Example:
    int[]: left
    int[]: right
    return: @
    run:
        throws: copy(FxThrows\traversal)
        return: zipWith(left; right; Combine\combine)
```

## Julia

```julia
example(left, right) = 2 .* left .+ right .* right
```

## Размер полного клиента

| Язык | Без пробельных символов | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: |
| LMX | 164 | 13 | 251 |
| Julia | 41 | 1 | 51 |

## Реализации использованного ядра

- `zipWith`: [полная пара реализации](library_comparisons/JI01_comparision.md)

Julia-клиент использует реальные Base/пакет; реализации из library_comparisons он не импортирует. [Общие зависимости и границы](library_comparisons/README.md) учитываются отдельно. Код проверен как текст и по договорам; исполнение LMX/Julia здесь не заявлено.

## Первичные источники

- [https://docs.julialang.org/en/v1/manual/arrays/](https://docs.julialang.org/en/v1/manual/arrays/)
- [https://docs.julialang.org/en/v1/base/arrays/](https://docs.julialang.org/en/v1/base/arrays/)
