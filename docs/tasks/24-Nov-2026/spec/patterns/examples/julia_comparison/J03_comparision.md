# J03. Разворот без изменения входа

## Общий наблюдаемый договор

Вернуть элементы в обратном порядке в новом внешнем массиве; исходный массив сохраняется.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.



## Вход и ожидаемое наблюдение

```json
{
  "arguments": {
    "xs": [
      1,
      2,
      3,
      4
    ]
  },
  "result": [
    4,
    3,
    2,
    1
  ]
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 300 | 433 | 13 |
| LMX функциональный | 69 | 107 | 6 |
| Julia | 23 | 26 | 1 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    @: xs
    return: @
    run:
        throws: copy(FxSeqInfo\get\throws) copy(FxSeqAllocate\make\throws) copy(FxSeqRead\read\throws) copy(FxSeqStore\write\throws)
        @: info FxSeqInfo\get(xs)
        int: n length(xs)
        @: out FxSeqAllocate\make(info\arrayType; n)
        int: i 0
        while: i < n
            FxSeqStore\write(out; i; FxSeqRead\read(xs; n - i - 1))
            i += 1
        return: out
```

[Полный исходник](source/lmx/procedural/J03.lm3). 300 непробельных символов; 13 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    @: xs
    return: @
    run:
        throws: copy(reverse\throws)
        return: reverse(xs)
```

[Полный исходник](source/lmx/J03.lm3). 69 непробельных символов; 6 непустых строк. Все объявления и Throws включены.

## Julia

[Полный исходник](source/julia/J03.jl).

```julia
example(xs) = reverse(xs)
```

## Общие библиотечные реализации

- `reverse`: [полная пара реализации](library_comparisons/JI02_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

LMX и Julia: **NOT_RUN** в этой сборке. Проверяются обе LMX-формы как текст и общий независимый oracle; это не языковое исполнение.

## Первичные источники

- <https://docs.julialang.org/en/v1/base/arrays/>
- <https://docs.julialang.org/en/v1/base/collections/>
