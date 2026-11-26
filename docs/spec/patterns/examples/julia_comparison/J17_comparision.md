# J17. Добавление пачки в ограниченный журнал

## Общий наблюдаемый договор

Добавить values в конец изменяемого target, затем при превышении неотрицательной capacity удалить самые старые элементы. Вернуть тот же target с последними capacity значениями. Источник values не пересекается с target; сохранение идентичности target входит в договор. capacity=0 очищает журнал.

Обе полные реализации выполняют один новый прикладной сценарий: процедурная задаёт алгоритм явно, функциональная использует общие операции ядра. Изменённые тексты требуют нового P0-прогона.

Сценарий расширен по замечанию автора: показана обработка данных и полезный итог, а не только вызов одной функции. Обе полные реализации выполняют один новый прикладной сценарий: процедурная задаёт алгоритм явно, функциональная использует общие операции ядра. Изменённые тексты требуют нового P0-прогона.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": {
    "target": [
      1,
      2,
      3
    ],
    "values": [
      4,
      5
    ],
    "capacity": 3
  },
  "result": {
    "returned": [
      3,
      4,
      5
    ],
    "target": [
      3,
      4,
      5
    ],
    "same_target": true
  }
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 740 | 1102 | 31 |
| LMX функциональный | 191 | 293 | 12 |
| Julia | <span style="color:#176233"><u>128</u></span> | 163 | 6 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    @: target
    @: values
    int: capacity
    return: @
    run:
        throws: copy(FxSeqInfo\get\throws) copy(FxSeqSize\sum\throws) copy(FxSeqAdmit\admit\throws) copy(FxSeqRead\read\throws) copy(FxKernel\arrayWrite\throws) copy(sys\resize\throws)
        @: info FxSeqInfo\get(target)
        FxSeqInfo\get(values)
        int: oldSize length(target)
        int: added length(values)
        int: newSize FxSeqSize\sum(oldSize; added; info\maxLength)
        []@: ready []
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
        int: drop length(target) - capacity
        if: drop > 0
            i := 0
            while: i < capacity
                FxKernel\arrayWrite(target; i; FxSeqRead\read(target; drop + i))
                i += 1
            sys\resize(target; capacity)
        return: target
```

[Полный исходник](source/lmx/procedural/J17.lm3). 740 непробельных символов; 31 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    @: target
    @: values
    int: capacity
    return: @
    run:
        throws: copy(append\throws) copy(splice\throws)
        append(target; values)
        int: drop length(target) - capacity
        if: drop > 0
            splice(target; 0; drop; ())
        return: target
```

[Полный исходник](source/lmx/J17.lm3). 191 непробельных символов; 12 непустых строк. Все объявления и Throws включены.

## Julia

[Полный исходник](source/julia/J17.jl).

```julia
function example(target, values, capacity)
    append!(target, values)
    drop = length(target) - capacity
    drop > 0 && splice!(target, 1:drop)
    target
end
```

## Общие библиотечные реализации

- `append`: [полная пара реализации](library_comparisons/JI03_comparision.md)
- `splice`: [полная пара реализации](library_comparisons/JI03_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Изменённые LMX-исходники: parser/P0 **NOT_RUN**; прежний receipt не переносится на новый хэш. LMX и Julia runtime: **NOT_RUN** в этой сборке. Проверяются обе LMX-формы как текст и общий независимый oracle; это не языковое исполнение. Численные размеры пересчитаны по текущим полным исходникам.

## Первичные источники

- <https://docs.julialang.org/en/v1/base/collections/>
