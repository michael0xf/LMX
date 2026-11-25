# S02. REMOVE-IF-NOT: допуск заявок и сводка отказов

Полное сравнение на указанном домене.

## Общий договор

Для конечного списка целых items и целого limit >= 0 оставить заявки 0 < value <= limit в исходном порядке; вернуть [accepted, total, rejectedCount]. total — сумма принятых заявок, rejectedCount включает все неподходящие позиции, в том числе повторяющиеся. Входы не меняются. Пустой список даёт [[], 0, 0]. Все значения и суммы помещаются в LMX int.

## Входы и ожидаемые наблюдения

```json
[
  {
    "args": [
      [
        -2,
        0,
        3,
        1,
        8,
        3
      ],
      3
    ],
    "expected": [
      [
        3,
        1,
        3
      ],
      7,
      3
    ]
  },
  {
    "args": [
      [],
      5
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
        1,
        2
      ],
      0
    ],
    "expected": [
      [],
      0,
      2
    ]
  },
  {
    "args": [
      [
        4,
        4
      ],
      4
    ],
    "expected": [
      [
        4,
        4
      ],
      8,
      0
    ]
  }
]
```

## Размер полных вариантов

| Источник | Без пробельных | Все символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX — процедурный | 318 | 549 | 20 |
| LMX — функциональный | 248 | 346 | 13 |
| Common Lisp / SBCL | 165 | 207 | 4 |

Оба стиля LMX сравниваются независимо по одному договору. Все объявления, вспомогательные определения и Throws входят в размер. Реализация общих библиотечных операций учитывается отдельно один раз.

## LMX — процедурный

```lmx
Example:
    int[]: items
    int: limit
    return: @
    run:
        throws: copy(sys\resize\throws)
        int[]: accepted []
        sys\resize(accepted; length(items))
        int: used 0
        int: total 0
        int: i 0
        while: i < length(items)
            int: value items[i]
            if: value > 0 && value <= limit
                accepted[used] := value
                used += 1
                total += value
            i += 1
        sys\resize(accepted; used)
        return: (accepted; total; length(items) - used)
```

[Полный исходник](source/lmx/procedural/S02.lm3). 318 непробельных символов; 20 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Eligible:
    int: value
    return: int
    accepts:
        return: value > 0 && value <= limit

Example:
    int[]: items
    int: limit
    return: @
    run:
        throws: copy(filter\throws) copy(sum\throws)
        @: accepted (filter items Eligible\accepts)
        return: (accepted; \(sum accepted); length(items) - length(accepted))
```

[Полный исходник](source/lmx/S02.lm3). 248 непробельных символов; 13 непустых строк. Все объявления и Throws включены.

## Common Lisp / SBCL

[Полный исходник](source/common-lisp/S02.lisp).

```common-lisp
(defun example (items limit)
  (let ((accepted (remove-if-not (lambda (x) (<= 1 x limit)) items)))
    (list accepted (reduce #'+ accepted :initial-value 0)
          (- (length items) (length accepted)))))
```

## Соответствие стилей договору

Процедурный проход явно отбирает, сохраняет и суммирует. Функциональный объединяет filter и sum, сохраняя порядок и повторные подходящие заявки.

Свободный limit в Eligible\accepts получает значение из активного вызова Example\run по динамическому связыванию LMX. Не добавляются отдельный объект-контекст или дублирующий helper. Результат сообщает и принятые заявки, и сумму, и число отказов.

## Общие операции и реализации

- `filter`: [тело ядра](../../LMX_Fn_Receivers/src/collections.lmx); отдельное сравнение [SI01](library_comparisons/SI01_comparision.md).

- `sum`: [тело ядра](../../LMX_Fn_Receivers/src/coreStandardNumeric.lmx).

Common Lisp-клиент использует указанные native/standard средства и не импортирует сравнительные реализации.

## Проверка

Для обновлённого кода **SBCL: NOT_RUN; LMX parser/runtime: NOT_RUN**. Статистика пересчитана по полным исходникам; это не выполнение программ. [Статус и прежний receipt](validation/common_lisp.json).

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/f_rm_rm.htm>
- <https://www.lispworks.com/documentation/HyperSpec/Body/f_reduce.htm>
