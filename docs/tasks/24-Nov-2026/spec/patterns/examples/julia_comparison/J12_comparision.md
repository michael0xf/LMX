# J12. Группировка по чётности

## Общий наблюдаемый договор

Разбить целые на группы odd=true/false, сохранить порядок элементов внутри каждой группы. Отсутствующие группы не создаются. Порядок обхода самих групп не сравнивается.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.

Клиент импортирует настоящий пакет SplitApplyCombine. LMX возвращает список {key,items}, Julia — Dictionary; сравниваются ключи и полные группы, без искусственного преобразования одного клиента в устройство другого.

## Вход и ожидаемое наблюдение

```json
{
  "arguments": {
    "xs": [
      3,
      2,
      5,
      4,
      3
    ]
  },
  "result": {
    "true": [
      3,
      5,
      3
    ],
    "false": [
      2,
      4
    ]
  }
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 348 | 616 | 20 |
| LMX функциональный | 131 | 204 | 11 |
| Julia | 55 | 62 | 2 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    int[]: xs
    return: @
    run:
        throws: copy(FxSeqPush\append\throws) copy(record\throws)
        @[]: out []
        int: i 0
        while: i < length(xs)
            int: key xs[i] % 2 != 0
            int: j 0
            while: j < length(out) && \out[j]\key != key
                j += 1
            if: j = length(out)
                @: group (copy(FxGroup))
                group\key := (key record)
                group\items := (copy(()))
                FxSeqPush\append(out; group)
            FxSeqPush\append(out[j]\items; (xs[i] record))
            i += 1
        return: out
```

[Полный исходник](source/lmx/procedural/J12.lm3). 348 непробельных символов; 20 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Parity:
    int: value
    return: int
    key:
        return: value % 2 != 0


Example:
    int[]: xs
    return: @
    run:
        throws: copy(groupBy\throws)
        return: groupBy(xs; Parity\key)
```

[Полный исходник](source/lmx/J12.lm3). 131 непробельных символов; 11 непустых строк. Все объявления и Throws включены.

## Julia

[Полный исходник](source/julia/J12.jl).

```julia
using SplitApplyCombine: group
example(xs) = group(isodd, xs)
```

## Общие библиотечные реализации

- `groupBy`: [полная пара реализации](library_comparisons/JI04_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

LMX и Julia: **NOT_RUN** в этой сборке. Проверяются обе LMX-формы как текст и общий независимый oracle; это не языковое исполнение.

## Первичные источники

- <https://github.com/JuliaData/SplitApplyCombine.jl#grouping>
