# S03. REDUCE: последовательное распределение бюджета

Полное сравнение на указанном домене.

## Общий договор

Даны initial >= 0 и конечный список неотрицательных целых costs. Заявки рассматриваются строго слева направо: если стоимость не больше остатка, она оплачивается и уменьшает остаток; иначе отклоняется без изменения остатка. Вернуть [remaining, acceptedCount, rejectedCount]. Нулевая заявка принимается, вход не меняется. Пустой список возвращает [initial, 0, 0]. Числа и счётчики помещаются в LMX int.

## Входы и ожидаемые наблюдения

```json
[
  {
    "args": [
      20,
      [
        2,
        30,
        3,
        15,
        0
      ]
    ],
    "expected": [
      0,
      4,
      1
    ]
  },
  {
    "args": [
      20,
      []
    ],
    "expected": [
      20,
      0,
      0
    ]
  },
  {
    "args": [
      0,
      [
        0,
        1,
        0
      ]
    ],
    "expected": [
      0,
      2,
      1
    ]
  },
  {
    "args": [
      5,
      [
        4,
        2,
        1
      ]
    ],
    "expected": [
      0,
      2,
      1
    ]
  },
  {
    "args": [
      5,
      [
        2,
        4,
        1
      ]
    ],
    "expected": [
      2,
      2,
      1
    ]
  }
]
```

## Размер полных вариантов

| Источник | Без пробельных | Все символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX — процедурный | 223 | 416 | 17 |
| LMX — функциональный | 314 | 467 | 18 |
| Common Lisp / SBCL | 239 | 348 | 7 |

Оба стиля LMX сравниваются независимо по одному договору. Все объявления, вспомогательные определения и Throws входят в размер. Реализация общих библиотечных операций учитывается отдельно один раз.

## LMX — процедурный

```lmx
Example:
    int: initial
    int[]: costs
    return: @
    run:
        int: remaining initial
        int: accepted 0
        int: rejected 0
        int: i 0
        while: i < length(costs)
            if: costs[i] <= remaining
                remaining -= costs[i]
                accepted += 1
            else:
                rejected += 1
            i += 1
        return: (remaining; accepted; rejected)
```

[Полный исходник](source/lmx/procedural/S03.lm3). 223 непробельных символов; 17 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Payment:
    @: state
    int: cost
    return: @
    accept:
        int: remaining \state[0]
        int: accepted \state[1]
        int: rejected \state[2]
        if: cost <= remaining
            return: (remaining - cost; accepted + 1; rejected)
        return: (remaining; accepted; rejected + 1)

Example:
    int: initial
    int[]: costs
    return: @
    run:
        throws: copy(foldl\throws)
        return: (foldl costs (initial; 0; 0) Payment\accept)
```

[Полный исходник](source/lmx/S03.lm3). 314 непробельных символов; 18 непустых строк. Все объявления и Throws включены.

## Common Lisp / SBCL

[Полный исходник](source/common-lisp/S03.lisp).

```common-lisp
(defun example (initial costs)
  (reduce (lambda (state cost)
            (destructuring-bind (remaining accepted rejected) state
              (if (<= cost remaining)
                  (list (- remaining cost) (1+ accepted) rejected)
                  (list remaining accepted (1+ rejected)))))
          costs :initial-value (list initial 0 0)))
```

## Соответствие стилей договору

Процедурный вариант изменяет три локальных значения; функциональный foldl передаёт структуру состояния между шагами и возвращает новую структуру на каждом шаге.

Состояние свёртки — настоящая структура из остатка и двух счётчиков. Порядок заявок влияет на оплату; предварительная сумма не заменяет алгоритм. После отклонённой заявки обработка продолжается. Seed содержит три элемента и передаётся как одна структура.

## Общие операции и реализации

- `foldl`: [тело ядра](../../LMX_Fn_Receivers/src/collections.lmx); отдельное сравнение [SI01](library_comparisons/SI01_comparision.md).

Common Lisp-клиент использует указанные native/standard средства и не импортирует сравнительные реализации.

## Проверка

Для обновлённого кода **SBCL: NOT_RUN; LMX parser/runtime: NOT_RUN**. Статистика пересчитана по полным исходникам; это не выполнение программ. [Статус и прежний receipt](validation/common_lisp.json).

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/f_reduce.htm>
- <https://www.lispworks.com/documentation/HyperSpec/Body/m_destru.htm>
