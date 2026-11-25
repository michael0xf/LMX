# J19. Итоги каналов после вычитания фона

## Общий наблюдаемый договор

Строки матрицы — последовательные измерения, столбцы — каналы. Вычесть общий целочисленный baseline из каждого показания и вернуть сумму каждого канала в исходном порядке столбцов. Вход не меняется; допустимы прямоугольные матрицы положительной ширины и отдельно 0x0. Арифметика без переполнения.

Обе полные реализации выполняют один новый прикладной сценарий: процедурная задаёт алгоритм явно, функциональная использует общие операции ядра. Изменённые тексты требуют нового P0-прогона.

Сценарий расширен по замечанию автора: показана обработка данных и полезный итог, а не только вызов одной функции. Обе полные реализации выполняют один новый прикладной сценарий: процедурная задаёт алгоритм явно, функциональная использует общие операции ядра. Изменённые тексты требуют нового P0-прогона.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": {
    "rows": [
      [
        2,
        4,
        6
      ],
      [
        3,
        5,
        7
      ]
    ],
    "baseline": 1
  },
  "result": [
    3,
    7,
    11
  ]
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 523 | 903 | 30 |
| LMX функциональный | 263 | 353 | 13 |
| Julia | 105 | 127 | 4 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    @: rows
    int: baseline
    return: @
    run:
        throws: copy(FxSeqRead\read\throws) copy(FxSeqInfo\get\throws) copy(sys\resize\throws) copy(record\throws) FxShape
        @[]: out []
        if: length(rows) = 0
            return: out
        @: first FxSeqRead\read(rows; 0)
        int: width length(first)
        int: i 0
        while: i < length(rows)
            @: row FxSeqRead\read(rows; i)
            FxSeqInfo\get(row)
            if: length(row) != width
                throw: FxShape()
            i += 1
        sys\resize(out; width)
        int: j 0
        while: j < width
            int: total 0
            i := 0
            while: i < length(rows)
                @: row FxSeqRead\read(rows; i)
                total += \FxSeqRead\read(row; j) - baseline
                i += 1
            out[j] := (total record)
            j += 1
        return: out
```

[Полный исходник](source/lmx/procedural/J19.lm3). 523 непробельных символов; 30 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
ChannelTotal:
    @: column
    return: int
    value:
        throws: copy(sum\throws)
        return: \sum(column) - baseline * length(column)

Example:
    @: rows
    int: baseline
    return: @
    run:
        throws: copy(transpose\throws) copy(map\throws) copy(ChannelTotal\value\throws)
        return: map(transpose(rows); ChannelTotal\value)
```

[Полный исходник](source/lmx/J19.lm3). 263 непробельных символов; 13 непустых строк. Все объявления и Throws включены.

## Julia

[Полный исходник](source/julia/J19.jl).

```julia
function example(matrix, baseline)
    calibrated = matrix .- baseline
    [sum(column) for column in eachcol(calibrated)]
end
```

## Общие библиотечные реализации

- `transpose`: [полная пара реализации](library_comparisons/JI02_comparision.md)
- `map`: [полная пара реализации](library_comparisons/JI01_comparision.md)
- `sum`: [полная пара реализации](../../LMX_Fn_Receivers/src/coreStandardNumeric.lmx)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Изменённые LMX-исходники: parser/P0 **NOT_RUN**; прежний receipt не переносится на новый хэш. LMX и Julia runtime: **NOT_RUN** в этой сборке. Проверяются обе LMX-формы как текст и общий независимый oracle; это не языковое исполнение. Численные размеры пересчитаны по текущим полным исходникам.

## Первичные источники

- <https://docs.julialang.org/en/v1/base/arrays/>
