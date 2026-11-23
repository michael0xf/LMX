# J01. Полуоткрытый диапазон с направлением

## Общий наблюдаемый договор

Конечная последовательность машинных целых start + k*step до исключённой границы stop. step не равен нулю; направление может быть любым. Размер результата должен помещаться в массив.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.

Julia-диапазон включает достижимую правую границу; takewhile явно удаляет её. Код не вычисляет stop - 1, который мог бы переполниться.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": {
    "start": 1,
    "stop": 8,
    "step": 2
  },
  "result": [
    1,
    3,
    5,
    7
  ]
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 375 | 606 | 20 |
| LMX функциональный | 110 | 162 | 8 |
| Julia | 109 | 162 | 3 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    int: start
    int: stop
    int: step
    return: @
    run:
        throws: copy(FxSeqInfo\get\throws) copy(sys\resize\throws) SequenceStep SequenceSize
        if: step = 0
            throw: SequenceStep()
        int[]: out []
        @: info FxSeqInfo\get(out)
        bigint: value start
        while: (step > 0 && value < stop) || (step < 0 && value > stop)
            if: length(out) = info\maxLength
                throw: SequenceSize()
            int: at length(out)
            sys\resize(out; at + 1)
            out[at] := value
            value += step
        return: out
```

[Полный исходник](source/lmx/procedural/J01.lm3). 375 непробельных символов; 20 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    int: start
    int: stop
    int: step
    return: @
    run:
        throws: copy(FxSeqRange\range\throws)
        return: range(start; stop; step)
```

[Полный исходник](source/lmx/J01.lm3). 110 непробельных символов; 8 непустых строк. Все объявления и Throws включены.

## Julia

[Полный исходник](source/julia/J01.jl).

```julia
example(start::Int, stop::Int, step::Int) =
    collect(Iterators.takewhile(x -> step > 0 ? x < stop : x > stop,
                               start:step:stop))
```

## Общие библиотечные реализации

- `range`: [полная пара реализации](library_comparisons/JI02_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

LMX и Julia: **NOT_RUN** в этой сборке. Проверяются обе LMX-формы как текст и общий независимый oracle; это не языковое исполнение.

## Первичные источники

- <https://docs.julialang.org/en/v1/base/collections/>
- <https://docs.julialang.org/en/v1/base/iterators/>
