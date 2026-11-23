# J24. Декартово произведение через вложенные comprehensions

## Общий договор

Для каждого x из left, затем каждого y из right вернуть пару (x,y). Порядок: правый вход меняется быстрее. Результат материализован, пустой любой вход даёт пустой результат.

Вложенные Row/Pair используют живое DATA текущего вызова, а не искусственный статический closure-класс. В Julia два последовательных for дают нужный порядок; форма с запятой создаёт матрицу другого устройства.

Вход:

```json
{
  "left": [
    1,
    2
  ],
  "right": [
    10,
    20
  ]
}
```

Ожидаемое наблюдение:

```json
[
  [
    1,
    10
  ],
  [
    1,
    20
  ],
  [
    2,
    10
  ],
  [
    2,
    20
  ]
]
```

## LMX

```lmx
Example:
    int[]: left
    int[]: right
    return: @
    Row:
        int: x
        return: @
        Pair:
            int: y
            return: @
            make:
                return: (x; y)
        ---
        expand:
            throws: copy(FxThrows\traversal)
            return: map(right; Pair\make)
    ---
    run:
        throws: copy(FxThrows\traversal)
        return: flatMap(left; Row\expand)
```

## Julia

```julia
example(left, right) = [(x, y) for x in left for y in right]
```

## Размер полного клиента

| Язык | Без пробельных символов | Непустые строки | Все Unicode-символы |
| --- | ---: | ---: | ---: |
| LMX | 226 | 20 | 417 |
| Julia | 48 | 1 | 61 |

## Реализации использованного ядра

- `map`: [полная пара реализации](library_comparisons/JI01_comparision.md)
- `flatMap`: [полная пара реализации](library_comparisons/JI01_comparision.md)

Julia-клиент использует реальные Base/пакет; реализации из library_comparisons он не импортирует. [Общие зависимости и границы](library_comparisons/README.md) учитываются отдельно. Код проверен как текст и по договорам; исполнение LMX/Julia здесь не заявлено.

## Первичные источники

- [https://docs.julialang.org/en/v1/manual/arrays/](https://docs.julialang.org/en/v1/manual/arrays/)
- [https://docs.julialang.org/en/v1/base/iterators/](https://docs.julialang.org/en/v1/base/iterators/)
