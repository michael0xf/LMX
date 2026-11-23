# S06. POSITION-IF: первый подходящий индекс

Полное сравнение на указанном домене.

## Общий договор

Вернуть индекс первого отрицательного целого, начиная с нуля, либо -1 при отсутствии. Вход не меняется.

## Входы и ожидаемые наблюдения

```json
[
  {
    "args": [
      [
        2,
        0,
        -4,
        -1
      ]
    ],
    "expected": 2
  },
  {
    "args": [
      [
        -1,
        2
      ]
    ],
    "expected": 0
  },
  {
    "args": [
      [
        0,
        2
      ]
    ],
    "expected": -1
  },
  {
    "args": [
      []
    ],
    "expected": -1
  }
]
```

## Размер полных вариантов

| Источник | Без пробельных | Все символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX — процедурный | 94 | 194 | 10 |
| LMX — функциональный | 187 | 296 | 14 |
| Common Lisp / SBCL | 53 | 63 | 2 |

Оба стиля LMX сравниваются независимо по одному договору. Все объявления, вспомогательные определения и Throws входят в размер. Реализация общих библиотечных операций учитывается отдельно один раз.

## LMX — процедурный

```lmx
Example:
    int[]: items
    return: int
    run:
        int: i 0
        while: i < length(items)
            if: items[i] < 0
                return: i
            i += 1
        return: -1
```

[Полный исходник](source/lmx/procedural/S06.lm3). 94 непробельных символов; 10 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Negative:
    int: value
    return: int
    accepts:
        return: value < 0

Example:
    int[]: items
    return: int
    run:
        throws: copy(index	hrows)
        @: found (index items Negative\accepts)
        if: found\present = 0
            return: -1
        return: \found\value
```

[Полный исходник](source/lmx/S06.lm3). 187 непробельных символов; 14 непустых строк. Все объявления и Throws включены.

## Common Lisp / SBCL

[Полный исходник](source/common-lisp/S06.lisp).

```common-lisp
(defun example (items)
  (or (position-if #'minusp items) -1))
```

## Соответствие стилей договору

Обе записи сохраняют полный договор; процедурная раскрывает прикладной обход, функциональная использует общие операции/Expression без копии ядрового алгоритма.

В Common Lisp 0 истинен; OR корректно сохраняет найденный нулевой индекс. Отсутствие NIL переводится в -1. Основной прямой проход возвращает тот же индекс или -1. В отдельной альтернативе index возвращает Maybe записи int; present проверяется до извлечения значения.

## Общие операции и реализации

- `index`: [тело ядра](../../LMX_Fn_Receivers/src/sequences.lmx); отдельное сравнение [SI02](library_comparisons/SI02_comparision.md).

Common Lisp-клиент использует указанные native/standard средства и не импортирует сравнительные реализации.

## Проверка

SBCL: [фактический отчёт](validation/common_lisp.json). Оба LMX-варианта: **NOT_RUN**; проверки текста не доказывают исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/f_pos_p.htm>
