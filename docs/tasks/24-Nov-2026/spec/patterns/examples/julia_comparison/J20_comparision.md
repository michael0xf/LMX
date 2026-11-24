# J20. Устойчивая сортировка записей

## Общий наблюдаемый договор

Отсортировать записи по key, сохраняя порядок равных ключей, все остальные поля и исходный массив. Результат — новый внешний массив.

Обе формы сохраняют один наблюдаемый договор; процедурная запись показывает управление и изменение данных, функциональная использует общие операции ядра.

Компаратор вычитает два результата сравнения int 0/1, а не сами ключи: переполнения разности ключей нет. id наблюдает устойчивость; все поля сохраняются. Используется общий FxSort. Общий домен ключей — согласованный полный порядок для сравниваемых >/< и иностранного порядка; специальные NaN/частичные порядки не приписываются этому компаратору. Тип записей и набор их полей не ограничиваются int.

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
    ]
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
    },
    {
      "key": 2,
      "id": "c"
    }
  ]
}
```

## Размер полных клиентов

| Полный исходник | Непробельные символы | Все Unicode-символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX процедурный | 487 | 792 | 22 |
| LMX функциональный | 174 | 254 | 12 |
| Julia | 44 | 50 | 1 |

Обе LMX-формы опубликованы и считаются независимо. Все определения, обработчики и ссылки на throws входят в полный размер. Выбор единственного LMX-варианта по длине не выполняется.

## LMX — процедурный

```lmx
Example:
    @: items
    return: @
    run:
        throws: copy(FxSeqInfo\get\throws) copy(FxSeqAllocate\make\throws) copy(FxSeqRead\read\throws) copy(FxSeqStore\write\throws)
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
        return: out
```

[Полный исходник](source/lmx/procedural/J20.lm3). 487 непробельных символов; 22 непустых строк. Все объявления и Throws включены.

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
    return: @
    run:
        throws: copy(sort\throws)
        return: sort(items; Order\compare)
```

[Полный исходник](source/lmx/J20.lm3). 174 непробельных символов; 12 непустых строк. Все объявления и Throws включены.

## Julia

[Полный исходник](source/julia/J20.jl).

```julia
example(items) = sort(items; by=item -> item.key)
```

## Общие библиотечные реализации

- `sort`: [полная пара реализации](library_comparisons/JI04_comparision.md)

Тела библиотечного ядра сохранены в одном общем источнике и не размножаются для двух стилей. Иностранный клиент использует свои настоящие средства; соседние comparison-реализации он не импортирует.

## Проверка

LMX и Julia: **NOT_RUN** в этой сборке. Проверяются обе LMX-формы как текст и общий независимый oracle; это не языковое исполнение.

## Первичные источники

- <https://docs.julialang.org/en/v1/base/sort/>
