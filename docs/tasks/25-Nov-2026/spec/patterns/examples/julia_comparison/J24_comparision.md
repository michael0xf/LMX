# J24. Пары покупок в пределах бюджета

## Общий наблюдаемый договор

Из двух списков цен построить пары (x,y), для которых x+y не превышает budget. Сначала меняется правый список, затем левый; равные цены и повторные пары не удаляются. Пустой любой вход даёт пустой результат, источники сохраняются; арифметика без переполнения.

Обе полные реализации выполняют один новый прикладной сценарий: процедурная задаёт алгоритм явно, функциональная использует общие операции ядра. Изменённые тексты требуют нового P0-прогона.

Сценарий расширен по замечанию автора: показана обработка данных и полезный итог, а не только вызов одной функции. Обе полные реализации выполняют один новый прикладной сценарий: процедурная задаёт алгоритм явно, функциональная использует общие операции ядра. Изменённые тексты требуют нового P0-прогона.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": {
    "left": [
      2,
      5
    ],
    "right": [
      3,
      6
    ],
    "budget": 8
  },
  "result": [
    [
      2,
      3
    ],
    [
      2,
      6
    ],
    [
      5,
      3
    ]
  ]
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 261 | 457 | 17 |
| LMX функциональный | 307 | 511 | 21 |
| Julia | 78 | 103 | 3 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    int[]: left
    int[]: right
    int: budget
    return: @
    run:
        throws: copy(FxSeqPush\append\throws) copy(record\throws)
        @[]: out []
        int: i 0
        while: i < length(left)
            int: j 0
            while: j < length(right)
                if: left[i] + right[j] <= budget
                    FxSeqPush\append(out; ((left[i]; right[j]) record))
                j += 1
            i += 1
        return: out
```

[Полный исходник](source/lmx/procedural/J24.lm3). 261 непробельных символов; 17 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    int[]: left
    int[]: right
    int: budget
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
            throws: copy(map\throws) copy(compress\throws)
            return: map(compress(right; x + right <= budget); Pair\make)
    ---
    run:
        throws: copy(FxListBind\bind\throws) copy(Example\Row\expand\throws)
        return: bind(left; Row\expand)
```

[Полный исходник](source/lmx/J24.lm3). 307 непробельных символов; 21 непустых строк. Все объявления и Throws включены.

## Julia

[Полный исходник](source/julia/J24.jl).

```julia
function example(left, right, budget)
    [(x, y) for x in left for y in right if x + y <= budget]
end
```

## Общие библиотечные реализации

- `map`: [полная пара реализации](library_comparisons/JI01_comparision.md)
- `bind`: [полная пара реализации](library_comparisons/JI01_comparision.md)
- `compress`: [полная пара реализации](library_comparisons/JI02_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Изменённые LMX-исходники: parser/P0 **NOT_RUN**; прежний receipt не переносится на новый хэш. LMX и Julia runtime: **NOT_RUN** в этой сборке. Проверяются обе LMX-формы как текст и общий независимый oracle; это не языковое исполнение. Численные размеры пересчитаны по текущим полным исходникам.

## Первичные источники

- <https://docs.julialang.org/en/v1/manual/arrays/>
- <https://docs.julialang.org/en/v1/base/iterators/>
