# J11. Уникальные позиции вокруг событий

## Общий наблюдаемый договор

Каждая позиция события порождает x-1,x,x+1. Соединить эти окрестности в порядке событий, удалить отрицательные позиции, затем оставить первые вхождения. Нельзя сортировать результат или рекурсивно раскрывать данные. Целочисленная арифметика без переполнения.

Обе полные реализации выполняют один новый прикладной сценарий: процедурная задаёт алгоритм явно, функциональная использует общие операции ядра. Изменённые тексты требуют нового P0-прогона.

Сценарий расширен по замечанию автора: показана обработка данных и полезный итог, а не только вызов одной функции. Обе полные реализации выполняют один новый прикладной сценарий: процедурная задаёт алгоритм явно, функциональная использует общие операции ядра. Изменённые тексты требуют нового P0-прогона.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": {
    "xs": [
      0,
      2,
      2
    ]
  },
  "result": [
    0,
    1,
    2,
    3
  ]
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 297 | 622 | 21 |
| LMX функциональный | 277 | 385 | 16 |
| Julia | <span style="color:#176233"><u>110</u></span> | 131 | 4 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    []int: xs
    return: @
    run:
        throws: copy(FxSeqPush\append\throws) copy(record\throws)
        []@: out []
        int: i 0
        while: i < length(xs)
            int: offset -1
            while: offset <= 1
                int: value xs[i] + offset
                if: value >= 0
                    int: j 0
                    while: j < length(out) && \out[j] != value
                        j += 1
                    if: j = length(out)
                        FxSeqPush\append(out; (value record))
                ---
                offset += 1
            i += 1
        return: out
```

[Полный исходник](source/lmx/procedural/J11.lm3). 297 непробельных символов; 21 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Neighborhood:
    int: x
    return: @
    expand:
        return: (x - 1; x; x + 1)

Nonnegative:
    int: value
    return: int
    accepts:
        return: value >= 0

Example:
    []int: xs
    return: @
    run:
        throws: copy(FxListBind\bind\throws) copy(filter\throws) copy(unique\throws)
        return: unique(filter(bind(xs; Neighborhood\expand); Nonnegative\accepts))
```

[Полный исходник](source/lmx/J11.lm3). 277 непробельных символов; 16 непустых строк. Все объявления и Throws включены.

## Julia

[Полный исходник](source/julia/J11.jl).

```julia
function example(xs)
    candidates = collect(Iterators.flatmap(x -> (x-1, x, x+1), xs))
    unique(filter(>=(0), candidates))
end
```

## Общие библиотечные реализации

- `bind`: [полная пара реализации](library_comparisons/JI01_comparision.md)
- `filter`: [полная пара реализации](library_comparisons/JI01_comparision.md)
- `unique`: [полная пара реализации](library_comparisons/JI04_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Изменённые LMX-исходники: parser/P0 **NOT_RUN**; прежний receipt не переносится на новый хэш. LMX и Julia runtime: **NOT_RUN** в этой сборке. Проверяются обе LMX-формы как текст и общий независимый oracle; это не языковое исполнение. Численные размеры пересчитаны по текущим полным исходникам.

## Первичные источники

- <https://docs.julialang.org/en/v1/base/iterators/>
