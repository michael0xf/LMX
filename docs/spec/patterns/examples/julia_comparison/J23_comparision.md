# J23. Обратный порядок операций из сохранённых пачек

## Общий наблюдаемый договор

Пачки записаны в порядке выполнения. Составить порядок отмены: сначала последние операции последней пачки, затем предыдущие. Соединение выполняется только на одном уровне; вложенное значение остаётся одним элементом. Входы и ссылочные цели сохраняются, пустые пачки допустимы.

Обе полные реализации выполняют один новый прикладной сценарий: процедурная задаёт алгоритм явно, функциональная использует общие операции ядра. Изменённые тексты требуют нового P0-прогона.

Сценарий расширен по замечанию автора: показана обработка данных и полезный итог, а не только вызов одной функции. Обе полные реализации выполняют один новый прикладной сценарий: процедурная задаёт алгоритм явно, функциональная использует общие операции ядра. Изменённые тексты требуют нового P0-прогона.

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
    5,
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
| LMX процедурный | 730 | 1228 | 38 |
| LMX функциональный | 102 | 141 | 6 |
| Julia | <span style="color:#176233"><u>82</u></span> | 97 | 4 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    @: parts
    return: @
    run:
        throws: copy(FxSeqInfo\get\throws) copy(FxSeqAllocate\make\throws) copy(FxSeqRead\read\throws) copy(FxSeqStore\write\throws) copy(sys\resize\throws) SequenceSize
        FxSeqInfo\get(parts)
        int: kind []@
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
            kind := []@
        @: out FxSeqAllocate\make(kind; 0)
        @: info FxSeqInfo\get(out)
        if: count > info\maxLength
            throw: SequenceSize()
        int: size count
        sys\resize(out; size)
        int: at 0
        i := length(parts) - 1
        while: i >= 0
            @: part FxSeqRead\read(parts; i)
            int: j length(part) - 1
            while: j >= 0
                FxSeqStore\write(out; at; FxSeqRead\read(part; j))
                at += 1
                j -= 1
            i -= 1
        return: out
```

[Полный исходник](source/lmx/procedural/J23.lm3). 730 непробельных символов; 38 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    @: parts
    return: @
    run:
        throws: copy(concat\throws) copy(reverse\throws)
        return: reverse(concat(parts))
```

[Полный исходник](source/lmx/J23.lm3). 102 непробельных символов; 6 непустых строк. Все объявления и Throws включены.

## Julia

[Полный исходник](source/julia/J23.jl).

```julia
function example(parts)
    history = collect(Iterators.flatten(parts))
    reverse(history)
end
```

## Общие библиотечные реализации

- `concat`: [полная пара реализации](library_comparisons/JI02_comparision.md)
- `reverse`: [полная пара реализации](library_comparisons/JI02_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Изменённые LMX-исходники: parser/P0 **NOT_RUN**; прежний receipt не переносится на новый хэш. LMX и Julia runtime: **NOT_RUN** в этой сборке. Проверяются обе LMX-формы как текст и общий независимый oracle; это не языковое исполнение. Численные размеры пересчитаны по текущим полным исходникам.

## Первичные источники

- <https://docs.julialang.org/en/v1/base/iterators/>
