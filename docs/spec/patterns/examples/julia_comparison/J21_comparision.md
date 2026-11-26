# J21. Первые уникальные значения из пачек

## Общий наблюдаемый договор

Последовательно объединить конечные пачки на один уровень, затем оставить первое появление каждого значения во всём потоке. Пустые пачки допустимы, входы сохраняются. Реализация LMX принимает общие профили последовательностей; проверяемый общий домен этой пары — скалярные целые без расхождения политик равенства.

Обе полные реализации выполняют один новый прикладной сценарий: процедурная задаёт алгоритм явно, функциональная использует общие операции ядра. Изменённые тексты требуют нового P0-прогона.

Сценарий расширен по замечанию автора: показана обработка данных и полезный итог, а не только вызов одной функции. Обе полные реализации выполняют один новый прикладной сценарий: процедурная задаёт алгоритм явно, функциональная использует общие операции ядра. Изменённые тексты требуют нового P0-прогона.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": {
    "batches": [
      [
        3,
        1,
        3
      ],
      [],
      [
        2,
        1
      ],
      [
        4,
        2
      ]
    ]
  },
  "result": [
    3,
    1,
    2,
    4
  ]
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 870 | 1491 | 44 |
| LMX функциональный | 104 | 143 | 6 |
| Julia | <span style="color:#176233"><u>83</u></span> | 98 | 4 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    @: batches
    return: @
    run:
        throws: copy(FxSeqInfo\get\throws) copy(FxSeqAllocate\make\throws) copy(FxSeqRead\read\throws) copy(FxSeqStore\write\throws) copy(sys\resize\throws) copy(FxValueSame\test\throws) SequenceSize
        FxSeqInfo\get(batches)
        int: kind []@
        int: uniform 1
        bigint: count 0
        int: i 0
        while: i < length(batches)
            @: part FxSeqRead\read(batches; i)
            @: info FxSeqInfo\get(part)
            if: i = 0
                kind := info\arrayType
            if: info\dense = 0 || info\arrayType != kind
                uniform := 0
            count += length(part)
            i += 1
        if: uniform = 0
            kind := []@
        @: out FxSeqAllocate\make(kind; 0)
        @: info FxSeqInfo\get(out)
        if: count > info\maxLength
            throw: SequenceSize()
        int: size count
        sys\resize(out; size)
        int: at 0
        i := 0
        while: i < length(batches)
            @: part FxSeqRead\read(batches; i)
            int: j 0
            while: j < length(part)
                @: item FxSeqRead\read(part; j)
                int: k 0
                while: k < at && FxValueSame\test(FxSeqRead\read(out; k); item; 0) = 0
                    k += 1
                if: k = at
                    FxSeqStore\write(out; at; item)
                    at += 1
                j += 1
            i += 1
        sys\resize(out; at)
        return: out
```

[Полный исходник](source/lmx/procedural/J21.lm3). 870 непробельных символов; 44 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    @: batches
    return: @
    run:
        throws: copy(concat\throws) copy(unique\throws)
        return: unique(concat(batches))
```

[Полный исходник](source/lmx/J21.lm3). 104 непробельных символов; 6 непустых строк. Все объявления и Throws включены.

## Julia

[Полный исходник](source/julia/J21.jl).

```julia
function example(batches)
    joined = collect(Iterators.flatten(batches))
    unique(joined)
end
```

## Общие библиотечные реализации

- `concat`: [полная пара реализации](library_comparisons/JI02_comparision.md)
- `unique`: [полная пара реализации](library_comparisons/JI04_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Изменённые LMX-исходники: parser/P0 **NOT_RUN**; прежний receipt не переносится на новый хэш. LMX и Julia runtime: **NOT_RUN** в этой сборке. Проверяются обе LMX-формы как текст и общий независимый oracle; это не языковое исполнение. Численные размеры пересчитаны по текущим полным исходникам.

## Первичные источники

- <https://docs.julialang.org/en/v1/base/collections/>
