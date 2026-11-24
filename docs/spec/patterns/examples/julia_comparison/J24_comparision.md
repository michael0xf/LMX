# J24. Декартово произведение через вложенные comprehensions

## Общий наблюдаемый договор

Для каждого x из left, затем каждого y из right вернуть пару (x,y). Порядок: правый вход меняется быстрее. Результат материализован, пустой любой вход даёт пустой результат.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.

Вложенные Row/Pair используют живое DATA текущего вызова, а не искусственный статический closure-класс. В Julia два последовательных for дают нужный порядок; форма с запятой создаёт матрицу другого устройства.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": {
    "left": [
      1,
      2
    ],
    "right": [
      10,
      20
    ]
  },
  "result": [
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
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 224 | 388 | 15 |
| LMX функциональный | 250 | 442 | 20 |
| Julia | 48 | 61 | 1 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    int[]: left
    int[]: right
    return: @
    run:
        throws: copy(FxSeqPush\append\throws) copy(record\throws)
        @[]: out []
        int: i 0
        while: i < length(left)
            int: j 0
            while: j < length(right)
                FxSeqPush\append(out; ((left[i]; right[j]) record))
                j += 1
            i += 1
        return: out
```

[Полный исходник](source/lmx/procedural/J24.lm3). 224 непробельных символов; 15 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

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
            throws: copy(map\throws)
            return: map(right; Pair\make)
    ---
    run:
        throws: copy(FxListBind\bind\throws) copy(Example\Row\expand\throws)
        return: bind(left; Row\expand)
```

[Полный исходник](source/lmx/J24.lm3). 250 непробельных символов; 20 непустых строк. Все объявления и Throws включены.

## Julia

[Полный исходник](source/julia/J24.jl).

```julia
example(left, right) = [(x, y) for x in left for y in right]
```

## Общие библиотечные реализации

- `map`: [полная пара реализации](library_comparisons/JI01_comparision.md)
- `bind`: [полная пара реализации](library_comparisons/JI01_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

LMX и Julia: **NOT_RUN** в этой сборке. Проверяются обе LMX-формы как текст и общий независимый oracle; это не языковое исполнение.

## Первичные источники

- <https://docs.julialang.org/en/v1/manual/arrays/>
- <https://docs.julialang.org/en/v1/base/iterators/>
