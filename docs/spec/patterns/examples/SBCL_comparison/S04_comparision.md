# S04. MAPCAR по двум спискам

Полное сравнение на указанном домене.

## Общий договор

Попарно умножить элементы двух списков; остановиться на конце более короткого. Порядок сохраняется, входы не меняются.

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
        5,
        6
      ]
    ],
    "expected": [
      10,
      18
    ]
  },
  {
    "args": [
      [],
      [
        1
      ]
    ],
    "expected": []
  },
  {
    "args": [
      [
        1
      ],
      []
    ],
    "expected": []
  },
  {
    "args": [
      [
        -2,
        0
      ],
      [
        3,
        7
      ]
    ],
    "expected": [
      -6,
      0
    ]
  }
]
```

## Размер полных вариантов

| Источник | Без пробельных | Все символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX — процедурный | 174 | 294 | 12 |
| LMX — функциональный | 168 | 253 | 13 |
| Common Lisp / SBCL | 45 | 55 | 2 |

Оба стиля LMX сравниваются независимо по одному договору. Все объявления, вспомогательные определения и Throws входят в размер. Реализация общих библиотечных операций учитывается отдельно один раз.

## LMX — процедурный

```lmx
Example:
    int[]: first
    int[]: second
    return: int[]
    run:
        int[]: result []
        int: i 0
        while: i < length(first) && i < length(second)
            sys\resize(result; i + 1)
            result[i] := first[i] * second[i]
            i += 1
        return: result
```

[Полный исходник](source/lmx/procedural/S04.lm3). 174 непробельных символов; 12 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Multiply:
    int: first
    int: second
    return: int
    run:
        return: first * second

Example:
    int[]: first
    int[]: second
    return: @
    run:
        throws: copy(zipWith	hrows)
        return: (zipWith first second Multiply\run)
```

[Полный исходник](source/lmx/S04.lm3). 168 непробельных символов; 13 непустых строк. Все объявления и Throws включены.

## Common Lisp / SBCL

[Полный исходник](source/common-lisp/S04.lisp).

```common-lisp
(defun example (left right)
  (mapcar #'* left right))
```

## Соответствие стилей договору

Обе записи сохраняют полный договор; процедурная раскрывает прикладной обход, функциональная использует общие операции/Expression без копии ядрового алгоритма.

 Основной вариант выбран по меньшему полному размеру: Явный парный проход обрывается на коротком входе; в отличие от first*second допускает разные длины.

## Общие операции и реализации

- `zipWith`: [тело ядра](../../LMX_Fn_Receivers/src/collections.lmx); отдельное сравнение [SI01](library_comparisons/SI01_comparision.md).

Common Lisp-клиент использует указанные native/standard средства и не импортирует сравнительные реализации.

## Проверка

SBCL: [фактический отчёт](validation/common_lisp.json). Оба LMX-варианта: **NOT_RUN**; проверки текста не доказывают исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/f_mapc_.htm>
