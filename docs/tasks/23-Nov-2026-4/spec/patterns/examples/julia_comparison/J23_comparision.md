# J23. Объединение частей на один уровень

## Общий наблюдаемый договор

Последовательно объединить конечные части. Пустые части допустимы. В клиентском сценарии части содержат целые; вложенные элементы не раскрываются рекурсивно.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.

Материализация результата входит в Julia-код. При пустом внешнем входе сравниваются пустые значения, а не несуществующий выведенный тип элемента.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": {
    "parts": [
      [
        1,
        2
      ],
      [],
      [
        3
      ],
      [
        4,
        5
      ]
    ]
  },
  "result": [
    1,
    2,
    3,
    4,
    5
  ]
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 724 | 1218 | 38 |
| LMX функциональный | 85 | 123 | 6 |
| Julia | 48 | 51 | 1 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    @: parts
    return: @
    run:
        throws: copy(FxSeqInfo\get\throws) copy(FxSeqAllocate\make\throws) copy(FxSeqRead\read\throws) copy(FxSeqStore\write\throws) copy(sys\resize\throws) SequenceSize
        FxSeqInfo\get(parts)
        int: kind @[]
        int: uniform 1
        bigint: count 0
        int: i 0
        while: i < length(parts)
            @: part FxSeqRead\read(parts; i)
            @: info FxSeqInfo\get(part)
            if: i = 0
                kind := info\arrayType
            if: info\dense = 0 || info\arrayType != kind
                uniform := 0
            count += length(part)
            i += 1
        if: uniform = 0
            kind := @[]
        @: out FxSeqAllocate\make(kind; 0)
        @: info FxSeqInfo\get(out)
        if: count > info\maxLength
            throw: SequenceSize()
        int: size count
        sys\resize(out; size)
        int: at 0
        i := 0
        while: i < length(parts)
            @: part FxSeqRead\read(parts; i)
            int: j 0
            while: j < length(part)
                FxSeqStore\write(out; at; FxSeqRead\read(part; j))
                at += 1
                j += 1
            i += 1
        return: out
```

[Полный исходник](source/lmx/procedural/J23.lm3). 724 непробельных символов; 38 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    @: parts
    return: @
    run:
        throws: copy(FxSeqConcat\concat\throws)
        return: concat(parts)
```

[Полный исходник](source/lmx/J23.lm3). 85 непробельных символов; 6 непустых строк. Все объявления и Throws включены.

## Julia

[Полный исходник](source/julia/J23.jl).

```julia
example(parts) = collect(Iterators.flatten(parts))
```

## Общие библиотечные реализации

- `concat`: [полная пара реализации](library_comparisons/JI02_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

LMX и Julia: **NOT_RUN** в этой сборке. Проверяются обе LMX-формы как текст и общий независимый oracle; это не языковое исполнение.

## Первичные источники

- <https://docs.julialang.org/en/v1/base/iterators/>
