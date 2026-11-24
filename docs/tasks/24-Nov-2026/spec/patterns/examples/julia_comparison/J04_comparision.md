# J04. Отбор по числовой маске

## Общий наблюдаемый договор

Сохранить элементы, чья маска ненулевая; порядок прежний. Длины xs и mask должны совпадать, mask состоит из целых.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.



## Вход и ожидаемое наблюдение

```json
{
  "arguments": {
    "xs": [
      10,
      20,
      30,
      40
    ],
    "mask": [
      1,
      0,
      -2,
      0
    ]
  },
  "result": [
    10,
    30
  ]
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 360 | 530 | 16 |
| LMX функциональный | 86 | 131 | 7 |
| Julia | 97 | 117 | 4 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    @: xs
    int[]: mask
    return: @
    run:
        throws: copy(FxSeqInfo\get\throws) copy(FxSeqAllocate\make\throws) copy(FxSeqRead\read\throws) copy(FxSeqPush\append\throws) FxShape
        if: length(xs) != length(mask)
            throw: FxShape()
        @: info FxSeqInfo\get(xs)
        @: out FxSeqAllocate\make(info\arrayType; 0)
        int: i 0
        while: i < length(xs)
            if: mask[i] != 0
                FxSeqPush\append(out; FxSeqRead\read(xs; i))
            i += 1
        return: out
```

[Полный исходник](source/lmx/procedural/J04.lm3). 360 непробельных символов; 16 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    @: xs
    int[]: mask
    return: @
    run:
        throws: copy(compress\throws)
        return: compress(xs; mask)
```

[Полный исходник](source/lmx/J04.lm3). 86 непробельных символов; 7 непустых строк. Все объявления и Throws включены.

## Julia

[Полный исходник](source/julia/J04.jl).

```julia
function example(xs, mask)
    length(xs) == length(mask) || throw(DimensionMismatch("mask"))
    xs[mask .!= 0]
end
```

## Общие библиотечные реализации

- `compress`: [полная пара реализации](library_comparisons/JI02_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

LMX и Julia: **NOT_RUN** в этой сборке. Проверяются обе LMX-формы как текст и общий независимый oracle; это не языковое исполнение.

## Первичные источники

- <https://docs.julialang.org/en/v1/base/arrays/>
- <https://docs.julialang.org/en/v1/manual/arrays/>
