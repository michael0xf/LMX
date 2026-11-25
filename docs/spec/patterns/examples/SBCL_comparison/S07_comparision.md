# S07. STABLE-SORT: приоритетная очередь с квотой

Полное сравнение на указанном домене.

## Общий договор

Для конечного списка пар [целый priority, строковая label] и целого limit >= 0 выбрать не более limit задач с наименьшим priority. Равные приоритеты обслуживаются в исходном порядке. Вернуть [selectedRows, deferredCount]. Вход и поля пар не меняются; выбранные пары сохраняют идентичность, копируется лишь внешняя последовательность. Пустой список и нулевая квота допустимы.

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
      ],
      3
    ],
    "expected": [
      [
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
        ]
      ],
      1
    ]
  },
  {
    "args": [
      [],
      2
    ],
    "expected": [
      [],
      0
    ]
  },
  {
    "args": [
      [
        [
          3,
          "x"
        ]
      ],
      0
    ],
    "expected": [
      [],
      1
    ]
  },
  {
    "args": [
      [
        [
          3,
          "x"
        ]
      ],
      9
    ],
    "expected": [
      [
        [
          3,
          "x"
        ]
      ],
      0
    ]
  },
  {
    "args": [
      [
        [
          1,
          "a"
        ],
        [
          1,
          "b"
        ],
        [
          1,
          "c"
        ]
      ],
      2
    ],
    "expected": [
      [
        [
          1,
          "a"
        ],
        [
          1,
          "b"
        ]
      ],
      1
    ]
  }
]
```

## Размер полных вариантов

| Источник | Без пробельных | Все символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX — процедурный | 376 | 691 | 25 |
| LMX — функциональный | 256 | 382 | 16 |
| Common Lisp / SBCL | 183 | 225 | 4 |

Оба стиля LMX сравниваются независимо по одному договору. Все объявления, вспомогательные определения и Throws входят в размер. Реализация общих библиотечных операций учитывается отдельно один раз.

## LMX — процедурный

```lmx
Example:
    @: items
    int: limit
    return: @
    run:
        throws: copy(sys\resize\throws)
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
        int: count length(result)
        if: limit < count
            count := limit
        sys\resize(result; count)
        return: (result; length(items) - count)
```

[Полный исходник](source/lmx/procedural/S07.lm3). 376 непробельных символов; 25 непустых строк. Все объявления и Throws включены.

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
    int: limit
    return: @
    run:
        throws: copy(sort\throws) copy(take\throws)
        @: selected (take (sort items Order\compare) limit)
        return: (selected; length(items) - length(selected))
```

[Полный исходник](source/lmx/S07.lm3). 256 непробельных символов; 16 непустых строк. Все объявления и Throws включены.

## Common Lisp / SBCL

[Полный исходник](source/common-lisp/S07.lisp).

```common-lisp
(defun example (items limit)
  (let* ((ordered (stable-sort (copy-list items) #'< :key #'first))
         (selected (subseq ordered 0 (min limit (length ordered)))))
    (list selected (- (length items) (length selected)))))
```

## Соответствие стилей договору

Процедурный вариант раскрывает стабильную сортировку вставками и ограничение длины; функциональный соединяет стабильный sort и take. Оба сохраняют ссылки на исходные пары.

STABLE-SORT может менять переданный список, поэтому Lisp сортирует copy-list. LMX sort сохраняет вход и идентичность записей; take задаёт квоту без изменения порядка равных ключей. Метки позволяют видеть, какие именно задачи отложены.

## Общие операции и реализации

- `sort`: [тело ядра](../../LMX_Fn_Receivers/src/corePerlExamples.lmx); отдельное сравнение [SI03](library_comparisons/SI03_comparision.md).

- `take`: [тело ядра](../../LMX_Fn_Receivers/src/coreStandardFunctional.lmx).

Common Lisp-клиент использует указанные native/standard средства и не импортирует сравнительные реализации.

## Проверка

Для обновлённого кода **SBCL: NOT_RUN; LMX parser/runtime: NOT_RUN**. Статистика пересчитана по полным исходникам; это не выполнение программ. [Статус и прежний receipt](validation/common_lisp.json).

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/f_sort_.htm>
- <https://www.lispworks.com/documentation/HyperSpec/Body/f_subseq.htm>
