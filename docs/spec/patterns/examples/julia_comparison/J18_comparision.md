# J18. Splice с возвратом удалённых элементов

## Общий наблюдаемый договор

Заменить нулевой полуинтервал [lo,hi) target на values; вернуть удалённый внешний массив. values совместимы и не перекрываются с target; наблюдаются также итоговый target и сохранение его идентичности.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.

Возврат удалённых элементов обязателен. replaceRange возвращает изменённый target и потому не подставлен вместо splice. Предупреждение Julia о перекрытии аргументов вынесено в общий домен, а не скрыто.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": {
    "target": [
      1,
      2,
      3,
      4
    ],
    "lo": 1,
    "hi": 3,
    "values": [
      9,
      8,
      7
    ]
  },
  "result": {
    "removed": [
      2,
      3
    ],
    "target": [
      1,
      9,
      8,
      7,
      4
    ]
  }
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 1006 | 1496 | 38 |
| LMX функциональный | <span style="color:#176233"><u>108</u></span> | 167 | 9 |
| Julia | 128 | 157 | 4 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    @: target
    int: lo
    int: hi
    @: values
    return: @
    run:
        throws: copy(FxSeqInfo\get\throws) copy(FxSeqAllocate\make\throws) copy(FxSeqRead\read\throws) copy(FxSeqStore\write\throws) copy(FxSeqBounds\count\throws) copy(FxSeqSize\sum\throws) copy(FxKernel\arrayWrite\throws) copy(sys\resize\throws)
        int: removedCount FxSeqBounds\count(target; lo; hi)
        @: info FxSeqInfo\get(target)
        FxSeqInfo\get(values)
        int: oldSize length(target)
        int: newSize FxSeqSize\sum(oldSize - removedCount; length(values); info\maxLength)
        @: removed FxSeqAllocate\make(info\arrayType; removedCount)
        @: staged FxSeqAllocate\make(info\arrayType; newSize)
        int: i 0
        while: i < removedCount
            FxSeqStore\write(removed; i; FxSeqRead\read(target; lo + i))
            i += 1
        i := 0
        while: i < newSize
            @: value
            if: i < lo
                value := FxSeqRead\read(target; i)
            else:
                if: i - lo < length(values)
                    value := FxSeqRead\read(values; i - lo)
                else:
                    value := FxSeqRead\read(target; hi + (i - lo - length(values)))
            ---
            FxSeqStore\write(staged; i; value)
            i += 1
        sys\resize(target; newSize)
        i := 0
        while: i < newSize
            FxKernel\arrayWrite(target; i; FxSeqRead\read(staged; i))
            i += 1
        return: removed
```

[Полный исходник](source/lmx/procedural/J18.lm3). 1006 непробельных символов; 38 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    @: target
    int: lo
    int: hi
    @: values
    return: @
    run:
        throws: copy(splice\throws)
        return: splice(target; lo; hi; values)
```

[Полный исходник](source/lmx/J18.lm3). 108 непробельных символов; 9 непустых строк. Все объявления и Throws включены.

## Julia

[Полный исходник](source/julia/J18.jl).

```julia
function example(target, lo, hi, values)
    0 <= lo <= hi <= length(target) || throw(BoundsError(target, lo:hi))
    splice!(target, lo + 1:hi, values)
end
```

## Общие библиотечные реализации

- `splice`: [полная пара реализации](library_comparisons/JI03_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

LMX и Julia runtime: **NOT_RUN** в этой сборке. Проверяются обе LMX-формы как текст и общий независимый oracle; это не языковое исполнение. Численные размеры пересчитаны по текущим полным исходникам.

## Первичные источники

- <https://docs.julialang.org/en/v1/base/collections/>
