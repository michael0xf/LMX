# S04. MAPCAR по двум спискам

Полная пара в указанном ниже договоре.

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

## Размер основного варианта

| Источник | Полный, без пробельных | Без сложного Throws | Все символы | Непустые строки |
| --- | ---: | ---: | ---: | ---: |
| LMX | 174 | 174 | 294 | 12 |
| Common Lisp / SBCL | 45 | — | 55 | 2 |

Учитывается полный основной листинг. Тестовый стенд и отдельные реализации ядра в него не входят; их файлы и размеры приведены отдельно.

## LMX

[Исходник](source/lmx/S04.lm3).

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

## Common Lisp / SBCL

[Исходник](source/common-lisp/S04.lisp).

```common-lisp
(defun example (left right)
  (mapcar #'* left right))
```

## Почему эти варианты сопоставимы

Явный парный проход обрывается на коротком входе; в отличие от first*second допускает разные длины.

 Основной вариант выбран по меньшему полному размеру: Явный парный проход обрывается на коротком входе; в отличие от first*second допускает разные длины.

Средства Common Lisp/SBCL: `CL:MAPCAR`.

## Реализации используемых функций

Основной листинг использует базовые средства языка и полностью приведённые прикладные определения.

Common Lisp-клиент не загружает сравнительные reference-реализации.

## Другой подход: LMX с общими ресиверами ядра

Исходный полный вариант; нормы и конечные эффекты проверены. Полные текущие размеры приведены в статистике.

[Исходник](alternatives/lmx/S04_core.lm3). В основной коэффициент не входит.

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
        throws: copy(FxThrows\traversal)
        return: zipWith(first; second; Multiply\run)
```

`zipWith`: [SI01](library_comparisons/SI01_comparision.md).

## Проверка

SBCL: [фактический отчёт](validation/common_lisp.json). LMX: **NOT_RUN**; структурная проверка текста не доказывает исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/f_mapc_.htm>
