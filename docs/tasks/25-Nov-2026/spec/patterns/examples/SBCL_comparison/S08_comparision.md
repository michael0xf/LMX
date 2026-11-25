# S08. REMOVE-DUPLICATES: подготовка очереди новых работ

Полное сравнение на указанном домене.

## Общий договор

Даны конечные списки целых идентификаторов items и completed. Сохранить только первое появление каждого идентификатора items, затем удалить идентификаторы, встречающиеся в completed. Вернуть [pending, duplicateCount, completedCount]. duplicateCount считает отброшенные повторные позиции items; completedCount считает удалённые уникальные идентификаторы, а не их повторы в completed. Порядок первых появлений и входы сохраняются.

## Входы и ожидаемые наблюдения

```json
[
  {
    "args": [
      [
        3,
        1,
        3,
        2,
        1,
        4
      ],
      [
        2,
        2,
        9
      ]
    ],
    "expected": [
      [
        3,
        1,
        4
      ],
      2,
      1
    ]
  },
  {
    "args": [
      [],
      [
        1
      ]
    ],
    "expected": [
      [],
      0,
      0
    ]
  },
  {
    "args": [
      [
        5,
        5,
        5
      ],
      [
        5
      ]
    ],
    "expected": [
      [],
      2,
      1
    ]
  },
  {
    "args": [
      [
        3,
        2,
        3,
        1
      ],
      []
    ],
    "expected": [
      [
        3,
        2,
        1
      ],
      1,
      0
    ]
  }
]
```

## Размер полных вариантов

| Источник | Без пробельных | Все символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX — процедурный | 503 | 920 | 30 |
| LMX — функциональный | 236 | 312 | 9 |
| Common Lisp / SBCL | 234 | 293 | 5 |

Оба стиля LMX сравниваются независимо по одному договору. Все объявления, вспомогательные определения и Throws входят в размер. Реализация общих библиотечных операций учитывается отдельно один раз.

## LMX — процедурный

```lmx
Example:
    int[]: items
    int[]: completed
    return: @
    run:
        throws: copy(sys\resize\throws)
        int[]: seen []
        int[]: pending []
        sys\resize(seen; length(items))
        sys\resize(pending; length(items))
        int: distinct 0
        int: used 0
        int: i 0
        while: i < length(items)
            int: value items[i]
            int: j 0
            while: j < distinct && seen[j] != value
                j += 1
            if: j = distinct
                seen[distinct] := value
                distinct += 1
                j := 0
                while: j < length(completed) && completed[j] != value
                    j += 1
                if: j = length(completed)
                    pending[used] := value
                    used += 1
            i += 1
        sys\resize(pending; used)
        return: (pending; length(items) - distinct; distinct - used)
```

[Полный исходник](source/lmx/procedural/S08.lm3). 503 непробельных символов; 30 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    int[]: items
    int[]: completed
    return: @
    run:
        throws: copy(unique\throws) copy(difference\throws)
        @: distinct (unique items)
        @: pending (difference distinct completed)
        return: (pending; length(items) - length(distinct); length(distinct) - length(pending))
```

[Полный исходник](source/lmx/S08.lm3). 236 непробельных символов; 9 непустых строк. Все объявления и Throws включены.

## Common Lisp / SBCL

[Полный исходник](source/common-lisp/S08.lisp).

```common-lisp
(defun example (items completed)
  (let* ((distinct (remove-duplicates items :from-end t :test #'=))
         (pending (remove-if (lambda (x) (member x completed :test #'=)) distinct)))
    (list pending (- (length items) (length distinct))
          (- (length distinct) (length pending)))))
```

## Соответствие стилей договору

Процедурный код явно ведёт seen и проверяет completed. Функциональный использует обобщённые unique и difference, а не вводит новый int-only уникализатор.

LMX difference уже сохраняет порядок первых появлений; unique перед ним нужен здесь ещё и для отдельного счётчика дублей. Common Lisp set-difference не используется как замена, потому что выбранный договор требует определённый порядок pending. REMOVE-DUPLICATES получает :from-end t, чтобы сохранить первые появления.

## Общие операции и реализации

- `unique`: [тело ядра](../../LMX_Fn_Receivers/src/corePerlExamples.lmx); отдельное сравнение [SI03](library_comparisons/SI03_comparision.md).

- `difference`: [тело ядра](../../LMX_Fn_Receivers/src/coreStandardFunctional.lmx).

Common Lisp-клиент использует указанные native/standard средства и не импортирует сравнительные реализации.

## Проверка

Для обновлённого кода **SBCL: NOT_RUN; LMX parser/runtime: NOT_RUN**. Статистика пересчитана по полным исходникам; это не выполнение программ. [Статус и прежний receipt](validation/common_lisp.json).

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/f_rm_dup.htm>
- <https://www.lispworks.com/documentation/HyperSpec/Body/f_rm_rm.htm>
- <https://www.lispworks.com/documentation/HyperSpec/Body/f_mem_m.htm>
