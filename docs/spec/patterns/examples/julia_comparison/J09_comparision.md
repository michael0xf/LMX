# J09. Парное прохождение до короткого входа

## Общий наблюдаемый договор

Материализовать пары соответствующих элементов. Результат заканчивается вместе с более коротким входом; входы не меняются.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.

Наблюдение нормализует FxPair{first,second} и Julia Tuple к паре значений. Ленивый zip в Julia явно материализован.

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
      "a",
      "b"
    ]
  },
  "result": [
    [
      1,
      "a"
    ],
    [
      2,
      "b"
    ]
  ]
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 343 | 521 | 17 |
| LMX функциональный | 78 | 123 | 7 |
| Julia | 44 | 49 | 1 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    @: left
    @: right
    return: @
    run:
        throws: copy(FxSeqInfo\get\throws) copy(FxSeqRead\read\throws) copy(FxSeqPush\append\throws)
        FxSeqInfo\get(left)
        FxSeqInfo\get(right)
        @[]: out []
        int: i 0
        while: i < length(left) && i < length(right)
            @: pair (copy(FxPair))
            pair\first := FxSeqRead\read(left; i)
            pair\second := FxSeqRead\read(right; i)
            FxSeqPush\append(out; pair)
            i += 1
        return: out
```

[Полный исходник](source/lmx/procedural/J09.lm3). 343 непробельных символов; 17 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    @: left
    @: right
    return: @
    run:
        throws: copy(zip\throws)
        return: zip(left; right)
```

[Полный исходник](source/lmx/J09.lm3). 78 непробельных символов; 7 непустых строк. Все объявления и Throws включены.

## Julia

[Полный исходник](source/julia/J09.jl).

```julia
example(left, right) = collect(zip(left, right))
```

## Общие библиотечные реализации

- `zip`: [полная пара реализации](library_comparisons/JI01_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

LMX и Julia: **NOT_RUN** в этой сборке. Проверяются обе LMX-формы как текст и общий независимый oracle; это не языковое исполнение.

## Первичные источники

- <https://docs.julialang.org/en/v1/base/iterators/>
