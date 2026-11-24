# J19. Транспонирование прямоугольной матрицы

## Общий наблюдаемый договор

Вернуть транспонированные значения без сопряжения и без изменения входа. Общий домен: непустые прямоугольные матрицы с положительной шириной и отдельно матрица 0x0.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.

Julia получает родную Matrix; LMX — массив строк. Конвертация тестовых данных не включена в алгоритмы. LMX без отдельной метаинформации не различает все формы 0xn, поэтому такие формы не объявлены равнозначными.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": {
    "rows": [
      [
        1,
        2,
        3
      ],
      [
        4,
        5,
        6
      ]
    ]
  },
  "result": [
    [
      1,
      4
    ],
    [
      2,
      5
    ],
    [
      3,
      6
    ]
  ]
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 583 | 973 | 31 |
| LMX функциональный | 77 | 115 | 6 |
| Julia | 35 | 38 | 1 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    @: rows
    return: @
    run:
        throws: copy(FxSeqInfo\get\throws) copy(FxSeqAllocate\make\throws) copy(FxSeqRead\read\throws) copy(sys\resize\throws) FxShape
        FxSeqInfo\get(rows)
        @[]: out []
        if: length(rows) = 0
            return: out
        @: first FxSeqRead\read(rows; 0)
        FxSeqInfo\get(first)
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
            @: column FxSeqAllocate\make(@[]; length(rows))
            i := 0
            while: i < length(rows)
                @: row FxSeqRead\read(rows; i)
                column[i] := FxSeqRead\read(row; j)
                i += 1
            out[j] := column
            j += 1
        return: out
```

[Полный исходник](source/lmx/procedural/J19.lm3). 583 непробельных символов; 31 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    @: rows
    return: @
    run:
        throws: copy(transpose\throws)
        return: transpose(rows)
```

[Полный исходник](source/lmx/J19.lm3). 77 непробельных символов; 6 непустых строк. Все объявления и Throws включены.

## Julia

[Полный исходник](source/julia/J19.jl).

```julia
example(matrix) = permutedims(matrix)
```

## Общие библиотечные реализации

- `transpose`: [полная пара реализации](library_comparisons/JI02_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

LMX и Julia: **NOT_RUN** в этой сборке. Проверяются обе LMX-формы как текст и общий независимый oracle; это не языковое исполнение.

## Первичные источники

- <https://docs.julialang.org/en/v1/base/arrays/>
