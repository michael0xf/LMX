# S04. MAPCAR по двум спискам: строки счёта и непарные позиции

Полное сравнение на указанном домене.

## Общий договор

Даны конечные списки неотрицательных целых quantities и prices. Сформировать суммы строк для попарных элементов до конца более короткого списка. Вернуть [lineTotals, total, extraQuantities, extraPrices], где последние поля — числа непарных элементов соответствующего входа. Входы и порядок сохраняются; все произведения и суммы помещаются в LMX int.

## Входы и ожидаемые наблюдения

```json
[
  {
    "args": [
      [
        2,
        3,
        4
      ],
      [
        10,
        5
      ]
    ],
    "expected": [
      [
        20,
        15
      ],
      35,
      1,
      0
    ]
  },
  {
    "args": [
      [
        2
      ],
      [
        10,
        5,
        7
      ]
    ],
    "expected": [
      [
        20
      ],
      20,
      0,
      2
    ]
  },
  {
    "args": [
      [],
      [
        4
      ]
    ],
    "expected": [
      [],
      0,
      0,
      1
    ]
  },
  {
    "args": [
      [],
      []
    ],
    "expected": [
      [],
      0,
      0,
      0
    ]
  },
  {
    "args": [
      [
        0,
        2
      ],
      [
        9,
        6
      ]
    ],
    "expected": [
      [
        0,
        12
      ],
      12,
      0,
      0
    ]
  }
]
```

## Размер полных вариантов

| Источник | Без пробельных | Все символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX — процедурный | 347 | 553 | 19 |
| LMX — функциональный | 224 | 302 | 9 |
| Common Lisp / SBCL | 188 | 241 | 5 |

Оба стиля LMX сравниваются независимо по одному договору. Все объявления, вспомогательные определения и Throws входят в размер. Реализация общих библиотечных операций учитывается отдельно один раз.

## LMX — процедурный

```lmx
Example:
    []int: quantities
    []int: prices
    return: @
    run:
        throws: copy(sys\resize\throws)
        int: count length(quantities)
        if: length(prices) < count
            count := length(prices)
        []int: totals []
        sys\resize(totals; count)
        int: total 0
        int: i 0
        while: i < count
            int: value quantities[i] * prices[i]
            totals[i] := value
            total += value
            i += 1
        return: (totals; total; length(quantities) - count; length(prices) - count)
```

[Полный исходник](source/lmx/procedural/S04.lm3). 347 непробельных символов; 19 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    []int: quantities
    []int: prices
    return: @
    run:
        throws: copy(zipWith\throws) copy(sum\throws)
        @: totals (zipWith quantities prices `*`)
        int: count length(totals)
        return: (totals; \(sum totals); length(quantities) - count; length(prices) - count)
```

[Полный исходник](source/lmx/S04.lm3). 224 непробельных символов; 9 непустых строк. Все объявления и Throws включены.

## Common Lisp / SBCL

[Полный исходник](source/common-lisp/S04.lisp).

```common-lisp
(defun example (quantities prices)
  (let* ((totals (mapcar #'* quantities prices))
         (count (length totals)))
    (list totals (reduce #'+ totals :initial-value 0)
          (- (length quantities) count) (- (length prices) count))))
```

## Соответствие стилей договору

Оба стиля возвращают строки счёта и сверку длины входов; процедурный вычисляет общий итог в том же цикле, функциональный применяет zipWith и sum.

Короткий список больше не приводит к незаметной потере хвоста: результат явно содержит число непарных позиций. zipWith сохраняет тот же контракт остановки, что многосписочный MAPCAR. Обобщённый sum читает записи из возвращённой последовательности.

## Общие операции и реализации

- `zipWith`: [тело ядра](../../LMX_Fn_Receivers/src/collections.lmx); отдельное сравнение [SI01](library_comparisons/SI01_comparision.md).

- `sum`: [тело ядра](../../LMX_Fn_Receivers/src/coreStandardNumeric.lmx).

Common Lisp-клиент использует указанные native/standard средства и не импортирует сравнительные реализации.

## Проверка

Для обновлённого кода **SBCL: NOT_RUN; LMX parser/runtime: NOT_RUN**. Статистика пересчитана по полным исходникам; это не выполнение программ. [Статус и прежний receipt](validation/common_lisp.json).

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/f_mapc_.htm>
- <https://www.lispworks.com/documentation/HyperSpec/Body/f_reduce.htm>
