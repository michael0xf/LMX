# J20. Ограниченная очередь по приоритету

## Общий наблюдаемый договор

Стабильно отсортировать задания по key и вернуть не более capacity первых записей. capacity неотрицательна; равные приоритеты сохраняют порядок поступления. Все поля записей и исходный массив сохраняются, результат — новый внешний массив.

Обе полные реализации выполняют один новый прикладной сценарий: процедурная задаёт алгоритм явно, функциональная использует общие операции ядра. Изменённые тексты требуют нового P0-прогона.

Сценарий расширен по замечанию автора: показана обработка данных и полезный итог, а не только вызов одной функции. Обе полные реализации выполняют один новый прикладной сценарий: процедурная задаёт алгоритм явно, функциональная использует общие операции ядра. Изменённые тексты требуют нового P0-прогона.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": {
    "items": [
      {
        "key": 2,
        "id": "a"
      },
      {
        "key": 1,
        "id": "b"
      },
      {
        "key": 2,
        "id": "c"
      },
      {
        "key": 1,
        "id": "d"
      }
    ],
    "capacity": 3
  },
  "result": [
    {
      "key": 1,
      "id": "b"
    },
    {
      "key": 1,
      "id": "d"
    },
    {
      "key": 2,
      "id": "a"
    }
  ]
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 569 | 907 | 25 |
| LMX функциональный | 291 | 429 | 17 |
| Julia | <span style="color:#176233"><u>111</u></span> | 131 | 4 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    @: items
    int: capacity
    return: @
    run:
        throws: copy(FxSeqInfo\get\throws) copy(FxSeqAllocate\make\throws) copy(FxSeqRead\read\throws) copy(FxSeqStore\write\throws) copy(sys\resize\throws)
        @: info FxSeqInfo\get(items)
        @: out FxSeqAllocate\make(info\arrayType; length(items))
        int: i 0
        while: i < length(items)
            @: held FxSeqRead\read(items; i)
            @: value \held
            int: j i
            while: j > 0
                @: previous FxSeqRead\read(out; j - 1)
                @: item \previous
                if: (item\key > value\key) - (item\key < value\key) <= 0
                    break
                FxSeqStore\write(out; j; previous)
                j -= 1
            FxSeqStore\write(out; j; held)
            i += 1
        if: capacity < length(out)
            sys\resize(out; capacity)
        return: out
```

[Полный исходник](source/lmx/procedural/J20.lm3). 569 непробельных символов; 25 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Order:
    @: first
    @: second
    return: int
    compare:
        return: (first\key > second\key) - (first\key < second\key)

Example:
    @: items
    int: capacity
    return: @
    run:
        throws: copy(sort\throws) copy(slice\throws)
        @: ordered sort(items; Order\compare)
        int: count length(ordered)
        if: capacity < count
            count := capacity
        return: slice(ordered; 0; count)
```

[Полный исходник](source/lmx/J20.lm3). 291 непробельных символов; 17 непустых строк. Все объявления и Throws включены.

## Julia

[Полный исходник](source/julia/J20.jl).

```julia
function example(items, capacity)
    ordered = sort(items; by=item -> item.key)
    ordered[1:min(capacity, length(ordered))]
end
```

## Общие библиотечные реализации

- `sort`: [полная пара реализации](library_comparisons/JI04_comparision.md)
- `slice`: [полная пара реализации](library_comparisons/JI02_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

Изменённые LMX-исходники: parser/P0 **NOT_RUN**; прежний receipt не переносится на новый хэш. LMX и Julia runtime: **NOT_RUN** в этой сборке. Проверяются обе LMX-формы как текст и общий независимый oracle; это не языковое исполнение. Численные размеры пересчитаны по текущим полным исходникам.

## Первичные источники

- <https://docs.julialang.org/en/v1/base/sort/>
