# S05. SOME и EVERY: короткое замыкание

Полное сравнение на указанном домене.

## Общий договор

Двумя независимыми проходами проверить наличие положительного элемента и положительность всех элементов. Вернуть [any, число вызовов any, all, число вызовов all]; логические значения нормализованы в 0/1. Порядок вызовов слева направо.

## Входы и ожидаемые наблюдения

```json
[
  {
    "args": [
      [
        -1,
        2,
        3
      ]
    ],
    "expected": [
      1,
      2,
      0,
      1
    ]
  },
  {
    "args": [
      []
    ],
    "expected": [
      0,
      0,
      1,
      0
    ]
  },
  {
    "args": [
      [
        1,
        2
      ]
    ],
    "expected": [
      1,
      1,
      1,
      2
    ]
  },
  {
    "args": [
      [
        -1,
        0
      ]
    ],
    "expected": [
      0,
      2,
      0,
      1
    ]
  }
]
```

## Размер полных вариантов

| Источник | Без пробельных | Все символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX — процедурный | 218 | 364 | 16 |
| LMX — функциональный | 272 | 447 | 19 |
| Common Lisp / SBCL | 211 | 271 | 5 |

Оба стиля LMX сравниваются независимо по одному договору. Все объявления, вспомогательные определения и Throws входят в размер. Реализация общих библиотечных операций учитывается отдельно один раз.

## LMX — процедурный

```lmx
Query:
    int[]: items
    int: wanted
    return: @
    run:
        int: i 0
        while: i < length(items)
            if: (items[i] > 0) = wanted
                return: (wanted; i + 1)
            i += 1
        return: (1 - wanted; i)

Example:
    int[]: items
    return: @
    run:
        return: (copy(Query\run(items; 1)) copy(Query\run(items; 0)))
```

[Полный исходник](source/lmx/procedural/S05.lm3). 218 непробельных символов; 16 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Probe:
    int: calls 0
    Test:
        int: value
        return: int
        run:
            Probe\calls += 1
            return: value > 0

Example:
    int[]: items
    return: @
    run:
        throws: copy(any\throws) copy(all\throws)
        Probe\calls := 0
        int: a (any items Probe\Test\run)
        int: ac Probe\calls
        Probe\calls := 0
        int: b (all items Probe\Test\run)
        return: (a; ac; b; Probe\calls)
```

[Полный исходник](source/lmx/S05.lm3). 272 непробельных символов; 19 непустых строк. Все объявления и Throws включены.

## Common Lisp / SBCL

[Полный исходник](source/common-lisp/S05.lisp).

```common-lisp
(defun example (items)
  (let ((some-calls 0) (every-calls 0))
    (let ((any (some (lambda (x) (incf some-calls) (plusp x)) items))
          (all (every (lambda (x) (incf every-calls) (plusp x)) items)))
      (list (if any 1 0) some-calls (if all 1 0) every-calls))))
```

## Соответствие стилей договору

Обе записи сохраняют полный договор; процедурная раскрывает прикладной обход, функциональная использует общие операции/Expression без копии ядрового алгоритма.

SOME вообще возвращает первое истинное значение предиката; здесь результат намеренно нормализован в 0/1 для общего контракта.

Один Query описывает оба коротких прохода. copy выдаёт поля каждого результата в общий результат; промежуточные a/b не нужны. Количество вычислений предиката и независимость проходов сохранены.

## Общие операции и реализации

- `any`: [тело ядра](../../LMX_Fn_Receivers/src/sequences.lmx); отдельное сравнение [SI02](library_comparisons/SI02_comparision.md).

- `all`: [тело ядра](../../LMX_Fn_Receivers/src/sequences.lmx); отдельное сравнение [SI02](library_comparisons/SI02_comparision.md).

Common Lisp-клиент использует указанные native/standard средства и не импортирует сравнительные реализации.

## Проверка

SBCL: [статус и датированный отчёт](validation/common_lisp.json). Оба LMX-варианта: **NOT_RUN**; проверки текста не доказывают исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/f_everyc.htm>
