# S06. POSITION-IF: полезный префикс до первой ошибки

Полное сравнение на указанном домене.

## Общий договор

Из конечного списка целых items выделить непрерывный префикс до первого отрицательного значения. Вернуть [acceptedPrefix, total, badIndex], где badIndex — нулевой индекс первого отрицательного либо -1 при его отсутствии. Ноль допустим. Хвост после первой ошибки не включается даже при положительных значениях. Вход не меняется; суммы помещаются в LMX int.

## Входы и ожидаемые наблюдения

```json
[
  {
    "args": [
      [
        2,
        0,
        3,
        -1,
        9
      ]
    ],
    "expected": [
      [
        2,
        0,
        3
      ],
      5,
      3
    ]
  },
  {
    "args": [
      [
        -2,
        4
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
        1,
        2,
        0
      ]
    ],
    "expected": [
      [
        1,
        2,
        0
      ],
      3,
      -1
    ]
  },
  {
    "args": [
      []
    ],
    "expected": [
      [],
      0,
      -1
    ]
  }
]
```

## Размер полных вариантов

| Источник | Без пробельных | Все символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX — процедурный | 297 | 510 | 19 |
| LMX — функциональный | 313 | 477 | 18 |
| Common Lisp / SBCL | 161 | 202 | 4 |

Оба стиля LMX сравниваются независимо по одному договору. Все объявления, вспомогательные определения и Throws входят в размер. Реализация общих библиотечных операций учитывается отдельно один раз.

## LMX — процедурный

```lmx
Example:
    []int: items
    return: @
    run:
        throws: copy(sys\resize\throws)
        []int: accepted []
        sys\resize(accepted; length(items))
        int: total 0
        int: used 0
        int: bad -1
        while: used < length(items)
            if: items[used] < 0
                bad := used
                break
            accepted[used] := items[used]
            total += items[used]
            used += 1
        sys\resize(accepted; used)
        return: (accepted; total; bad)
```

[Полный исходник](source/lmx/procedural/S06.lm3). 297 непробельных символов; 19 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Negative:
    int: value
    return: int
    accepts:
        return: value < 0

Example:
    []int: items
    return: @
    run:
        throws: copy(index\throws) copy(take\throws) copy(sum\throws)
        @: found (index items Negative\accepts)
        int: bad -1
        int: count length(items)
        if: found\present != 0
            bad := \found\value
            count := bad
        @: accepted (take items count)
        return: (accepted; \(sum accepted); bad)
```

[Полный исходник](source/lmx/S06.lm3). 313 непробельных символов; 18 непустых строк. Все объявления и Throws включены.

## Common Lisp / SBCL

[Полный исходник](source/common-lisp/S06.lisp).

```common-lisp
(defun example (items)
  (let* ((bad (position-if #'minusp items))
         (accepted (subseq items 0 (or bad (length items)))))
    (list accepted (reduce #'+ accepted :initial-value 0) (or bad -1))))
```

## Соответствие стилей договору

Процедурная форма останавливает один цикл; функциональная находит границу через index, выделяет take и суммирует выбранную часть.

LMX сохраняет различие отсутствующего результата index и найденной позиции 0. Lisp NIL нормализуется только для диагностического badIndex. Порядок остановки и возвращаемый префикс делают поиск частью обработки входного потока.

## Общие операции и реализации

- `index`: [тело ядра](../../LMX_Fn_Receivers/src/sequences.lmx); отдельное сравнение [SI02](library_comparisons/SI02_comparision.md).

- `take`: [тело ядра](../../LMX_Fn_Receivers/src/coreStandardFunctional.lmx).

- `sum`: [тело ядра](../../LMX_Fn_Receivers/src/coreStandardNumeric.lmx).

Common Lisp-клиент использует указанные native/standard средства и не импортирует сравнительные реализации.

## Проверка

Для обновлённого кода **SBCL: NOT_RUN; LMX parser/runtime: NOT_RUN**. Статистика пересчитана по полным исходникам; это не выполнение программ. [Статус и прежний receipt](validation/common_lisp.json).

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/f_pos_p.htm>
- <https://www.lispworks.com/documentation/HyperSpec/Body/f_subseq.htm>
- <https://www.lispworks.com/documentation/HyperSpec/Body/f_reduce.htm>
