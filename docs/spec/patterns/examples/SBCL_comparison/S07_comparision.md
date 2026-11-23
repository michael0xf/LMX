# S07. STABLE-SORT: ключ и устойчивость

Полное сравнение на указанном домене.

## Общий договор

Стабильно отсортировать пары [целый ключ, строковая метка] по ключу. Сохранить порядок равных ключей и значения входа; пары не изменять.

## Входы и ожидаемые наблюдения

```json
[
  {
    "args": [
      [
        [
          2,
          "a"
        ],
        [
          1,
          "b"
        ],
        [
          2,
          "c"
        ],
        [
          1,
          "d"
        ]
      ]
    ],
    "expected": [
      [
        1,
        "b"
      ],
      [
        1,
        "d"
      ],
      [
        2,
        "a"
      ],
      [
        2,
        "c"
      ]
    ]
  },
  {
    "args": [
      []
    ],
    "expected": []
  },
  {
    "args": [
      [
        [
          3,
          "x"
        ]
      ]
    ],
    "expected": [
      [
        3,
        "x"
      ]
    ]
  }
]
```

## Размер полных вариантов

| Источник | Без пробельных | Все символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX — процедурный | 242 | 490 | 19 |
| LMX — функциональный | 166 | 270 | 14 |
| Common Lisp / SBCL | 64 | 75 | 2 |

Оба стиля LMX сравниваются независимо по одному договору. Все объявления, вспомогательные определения и Throws входят в размер. Реализация общих библиотечных операций учитывается отдельно один раз.

## LMX — процедурный

```lmx
Example:
    @: items
    return: @
    run:
        @[]: result []
        sys\resize(result; length(items))
        int: i 0
        while: i < length(items)
            @: current items[i]
            int: j i
            while: j > 0
                @: previous result[j - 1]
                if: \previous[0] <= \current[0]
                    break
                result[j] := previous
                j -= 1
            result[j] := current
            i += 1
        return: result
```

[Полный исходник](source/lmx/procedural/S07.lm3). 242 непробельных символов; 19 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Order:
    @: first
    @: second
    return: int
    compare:
        int: a \first[0]
        int: b \second[0]
        return: (a > b) - (a < b)

Example:
    @: items
    return: @
    run:
        throws: copy(sort	hrows)
        return: (sort items Order\compare)
```

[Полный исходник](source/lmx/S07.lm3). 166 непробельных символов; 14 непустых строк. Все объявления и Throws включены.

## Common Lisp / SBCL

[Полный исходник](source/common-lisp/S07.lisp).

```common-lisp
(defun example (items)
  (stable-sort (copy-list items) #'< :key #'first))
```

## Соответствие стилей договору

Обе записи сохраняют полный договор; процедурная раскрывает прикладной обход, функциональная использует общие операции/Expression без копии ядрового алгоритма.

STABLE-SORT разрешено менять переданный список. Поэтому внешняя структура предварительно копируется; поля пар разделяются и не изменяются.

Каждая пара — структура [key,label] на границе сравнения; [0] выбирает запись ключа. sort сохраняет профиль внешней последовательности, вход и идентичность записей; comparator возвращает -1/0/1. Два сравнения дают int 0/1; их разность — тот же трёхзначный порядок.

## Общие операции и реализации

- `sort`: [тело ядра](../../LMX_Fn_Receivers/src/corePerlExamples.lmx); отдельное сравнение [SI03](library_comparisons/SI03_comparision.md).

Common Lisp-клиент использует указанные native/standard средства и не импортирует сравнительные реализации.

## Проверка

SBCL: [фактический отчёт](validation/common_lisp.json). Оба LMX-варианта: **NOT_RUN**; проверки текста не доказывают исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/f_sort_.htm>
