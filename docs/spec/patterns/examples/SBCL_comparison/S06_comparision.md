# S06. POSITION-IF: первый подходящий индекс

Полная пара в указанном ниже договоре.

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

## Размер основного варианта

| Источник | Полный, без пробельных | Без сложного Throws | Все символы | Непустые строки |
| --- | ---: | ---: | ---: | ---: |
| LMX | 94 | 94 | 194 | 10 |
| Common Lisp / SBCL | 53 | — | 63 | 2 |

Учитывается полный основной листинг. Тестовый стенд и отдельные реализации ядра в него не входят; их файлы и размеры приведены отдельно.

## LMX

[Исходник](source/lmx/S06.lm3).

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

## Common Lisp / SBCL

[Исходник](source/common-lisp/S06.lisp).

```common-lisp
(defun example (items)
  (or (position-if #'minusp items) -1))
```

## Почему эти варианты сопоставимы

Возвращает индекс либо -1 напрямую; корректно сохраняет найденный нулевой индекс и пустой вход.

В Common Lisp 0 истинен; OR корректно сохраняет найденный нулевой индекс. Отсутствие NIL переводится в -1. Основной прямой проход возвращает тот же индекс или -1. В отдельной альтернативе index возвращает Maybe записи int; present проверяется до извлечения значения.

Средства Common Lisp/SBCL: `CL:POSITION-IF`.

## Реализации используемых функций

Основной листинг использует базовые средства языка и полностью приведённые прикладные определения.

Common Lisp-клиент не загружает сравнительные reference-реализации.

## Другой подход: LMX с общими ресиверами ядра

Исходный полный вариант; нормы и конечные эффекты проверены. Полные текущие размеры приведены в статистике.

[Исходник](alternatives/lmx/S06_core.lm3). В основной коэффициент не входит.

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
        throws: copy(FxThrows\predicate) FxRecordArity
        @: found index(items; Negative\accepts)
        if: found\present = 0
            return: -1
        return: \found\value
```

`index`: [SI02](library_comparisons/SI02_comparision.md).

## Проверка

SBCL: [фактический отчёт](validation/common_lisp.json). LMX: **NOT_RUN**; структурная проверка текста не доказывает исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/f_pos_p.htm>
