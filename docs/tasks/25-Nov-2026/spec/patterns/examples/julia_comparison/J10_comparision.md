# J10. Пороговый отбор калиброванных оценок

## Общий наблюдаемый договор

Для двух целочисленных векторов одинаковой длины вычислить score=2*x+y*y, затем сохранить оценки не ниже limit. Порядок прежний, оба входа не меняются; переполнение исключено. Несовпадение длин — ошибка формы до выдачи результата.

Обе полные реализации выполняют один новый прикладной сценарий: процедурная задаёт алгоритм явно, функциональная использует общие операции ядра. Изменённые тексты требуют нового P0-прогона.

Сценарий расширен по замечанию автора: показана обработка данных и полезный итог, а не только вызов одной функции. Обе полные реализации выполняют один новый прикладной сценарий: процедурная задаёт алгоритм явно, функциональная использует общие операции ядра. Изменённые тексты требуют нового P0-прогона.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": {
    "left": [
      1,
      2,
      3
    ],
    "right": [
      4,
      5,
      6
    ],
    "limit": 20
  },
  "result": [
    29,
    42
  ]
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 304 | 487 | 17 |
| LMX функциональный | 203 | 300 | 11 |
| Julia | 149 | 183 | 5 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    int[]: left
    int[]: right
    int: limit
    return: @
    run:
        throws: copy(FxSeqPush\append\throws) copy(record\throws) SequenceSize
        if: length(left) != length(right)
            throw: SequenceSize()
        int[]: out []
        int: i 0
        while: i < length(left)
            int: score 2 * left[i] + right[i] * right[i]
            if: score >= limit
                FxSeqPush\append(out; (score record))
            i += 1
        return: out
```

[Полный исходник](source/lmx/procedural/J10.lm3). 304 непробельных символов; 17 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    int[]: left
    int[]: right
    int: limit
    return: @
    run:
        throws: copy(compress\throws) SequenceSize
        if: length(left) != length(right)
            throw: SequenceSize()
        @: scores 2 * left + right * right
        return: compress(scores; scores >= limit)
```

[Полный исходник](source/lmx/J10.lm3). 203 непробельных символов; 11 непустых строк. Все объявления и Throws включены.

## Julia

[Полный исходник](source/julia/J10.jl).

```julia
function example(left, right, limit)
    length(left) == length(right) || throw(DimensionMismatch("scores"))
    scores = 2 .* left .+ right .* right
    scores[scores .>= limit]
end
```

## Общие библиотечные реализации

- `compress`: [полная пара реализации](library_comparisons/JI02_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Изменённые LMX-исходники: parser/P0 **NOT_RUN**; прежний receipt не переносится на новый хэш. LMX и Julia runtime: **NOT_RUN** в этой сборке. Проверяются обе LMX-формы как текст и общий независимый oracle; это не языковое исполнение. Численные размеры пересчитаны по текущим полным исходникам.

## Первичные источники

- <https://docs.julialang.org/en/v1/manual/arrays/>
- <https://docs.julialang.org/en/v1/base/arrays/>
