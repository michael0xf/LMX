# J17. Дополнение существующего массива

## Общий наблюдаемый договор

Добавить values в конец target и вернуть тот же target. Сравниваемый домен: отдельные совместимые векторы без перекрытия; наблюдаются содержимое и идентичность target.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.

LMX дополнительно умеет безопасно подготовить перекрывающиеся источники; это свойство проверяется отдельно на реализациях, а не приписывается Base.append!.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": {
    "target": [
      1,
      2
    ],
    "values": [
      3,
      4
    ]
  },
  "result": {
    "returned": [
      1,
      2,
      3,
      4
    ],
    "target": [
      1,
      2,
      3,
      4
    ],
    "same_target": true
  }
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 578 | 823 | 23 |
| LMX функциональный | 102 | 147 | 7 |
| Julia | 45 | 50 | 1 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    @: target
    @: values
    return: @
    run:
        throws: copy(FxSeqInfo\get\throws) copy(FxSeqSize\sum\throws) copy(FxSeqAdmit\admit\throws) copy(FxSeqRead\read\throws) copy(FxKernel\arrayWrite\throws) copy(sys\resize\throws)
        @: info FxSeqInfo\get(target)
        FxSeqInfo\get(values)
        int: oldSize length(target)
        int: added length(values)
        int: newSize FxSeqSize\sum(oldSize; added; info\maxLength)
        @[]: ready []
        sys\resize(ready; added)
        int: i 0
        while: i < added
            ready[i] := FxSeqAdmit\admit(target; FxSeqRead\read(values; i))
            i += 1
        sys\resize(target; newSize)
        i := 0
        while: i < added
            FxKernel\arrayWrite(target; oldSize + i; ready[i])
            i += 1
        return: target
```

[Полный исходник](source/lmx/procedural/J17.lm3). 578 непробельных символов; 23 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    @: target
    @: values
    return: @
    run:
        throws: copy(FxSeqAppend\append\throws)
        return: append(target; values)
```

[Полный исходник](source/lmx/J17.lm3). 102 непробельных символов; 7 непустых строк. Все объявления и Throws включены.

## Julia

[Полный исходник](source/julia/J17.jl).

```julia
example(target, values) = append!(target, values)
```

## Общие библиотечные реализации

- `append`: [полная пара реализации](library_comparisons/JI03_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

LMX и Julia: **NOT_RUN** в этой сборке. Проверяются обе LMX-формы как текст и общий независимый oracle; это не языковое исполнение.

## Первичные источники

- <https://docs.julialang.org/en/v1/base/collections/>
