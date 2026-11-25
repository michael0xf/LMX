# J02. Копия среза

## Общий наблюдаемый договор

Создать новый внешний массив для нулевого полуинтервала [lo, hi). Требуется 0 <= lo <= hi <= length(xs). Ссылочные элементы сохраняют свои цели.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.

Перевод индексов оплачивается в Julia-клиенте. Это копия внешнего массива, а не view и не глубокая копия графа.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": {
    "xs": [
      10,
      20,
      30,
      40,
      50
    ],
    "lo": 1,
    "hi": 4
  },
  "result": [
    20,
    30,
    40
  ]
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 370 | 516 | 15 |
| LMX функциональный | 83 | 135 | 8 |
| Julia | 90 | 116 | 4 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    @: xs
    int: lo
    int: hi
    return: @
    run:
        throws: copy(FxSeqBounds\count\throws) copy(FxSeqInfo\get\throws) copy(FxSeqAllocate\make\throws) copy(FxSeqRead\read\throws) copy(FxSeqStore\write\throws)
        int: count FxSeqBounds\count(xs; lo; hi)
        @: info FxSeqInfo\get(xs)
        @: out FxSeqAllocate\make(info\arrayType; count)
        int: i 0
        while: i < count
            FxSeqStore\write(out; i; FxSeqRead\read(xs; lo + i))
            i += 1
        return: out
```

[Полный исходник](source/lmx/procedural/J02.lm3). 370 непробельных символов; 15 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    @: xs
    int: lo
    int: hi
    return: @
    run:
        throws: copy(slice\throws)
        return: slice(xs; lo; hi)
```

[Полный исходник](source/lmx/J02.lm3). 83 непробельных символов; 8 непустых строк. Все объявления и Throws включены.

## Julia

[Полный исходник](source/julia/J02.jl).

```julia
function example(xs, lo, hi)
    0 <= lo <= hi <= length(xs) || throw(BoundsError(xs, lo:hi))
    xs[lo + 1:hi]
end
```

## Общие библиотечные реализации

- `slice`: [полная пара реализации](library_comparisons/JI02_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

LMX и Julia runtime: **NOT_RUN** в этой сборке. Проверяются обе LMX-формы как текст и общий независимый oracle; это не языковое исполнение. Численные размеры пересчитаны по текущим полным исходникам.

## Первичные источники

- <https://docs.julialang.org/en/v1/base/arrays/>
