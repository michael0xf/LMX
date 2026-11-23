# S05. SOME и EVERY: короткое замыкание

Полная пара в указанном ниже договоре.

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

## Размер основного варианта

| Источник | Полный, без пробельных | Без сложного Throws | Все символы | Непустые строки |
| --- | ---: | ---: | ---: | ---: |
| LMX | 218 | 218 | 364 | 16 |
| Common Lisp / SBCL | 211 | — | 271 | 5 |

Учитывается полный основной листинг. Тестовый стенд и отдельные реализации ядра в него не входят; их файлы и размеры приведены отдельно.

## LMX

[Исходник](source/lmx/S05.lm3).

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

## Common Lisp / SBCL

[Исходник](source/common-lisp/S05.lisp).

```common-lisp
(defun example (items)
  (let ((some-calls 0) (every-calls 0))
    (let ((any (some (lambda (x) (incf some-calls) (plusp x)) items))
          (all (every (lambda (x) (incf every-calls) (plusp x)) items)))
      (list (if any 1 0) some-calls (if all 1 0) every-calls))))
```

## Почему эти варианты сопоставимы

Один Query описывает оба коротких прохода. copy выдаёт поля каждого результата в общий результат; промежуточные a/b не нужны. Количество вычислений предиката и независимость проходов сохранены.

SOME вообще возвращает первое истинное значение предиката; здесь результат намеренно нормализован в 0/1 для общего контракта.

Один Query описывает оба коротких прохода. copy выдаёт поля каждого результата в общий результат; промежуточные a/b не нужны. Количество вычислений предиката и независимость проходов сохранены.

Средства Common Lisp/SBCL: `CL:SOME`, `CL:EVERY`.

## Реализации используемых функций

Основной листинг использует базовые средства языка и полностью приведённые прикладные определения.

Common Lisp-клиент не загружает сравнительные reference-реализации.

## Другой подход: LMX с общими ресиверами ядра

Исходный полный вариант; нормы и конечные эффекты проверены. Полные текущие размеры приведены в статистике.

[Исходник](alternatives/lmx/S05_core.lm3). В основной коэффициент не входит.

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
        throws: copy(FxThrows\predicate)
        Probe\calls := 0
        int: a any(items; Probe\Test\run)
        int: ac Probe\calls
        Probe\calls := 0
        int: b all(items; Probe\Test\run)
        return: (a; ac; b; Probe\calls)
```

`any`: [SI02](library_comparisons/SI02_comparision.md).

`all`: [SI02](library_comparisons/SI02_comparision.md).

## Проверка

SBCL: [фактический отчёт](validation/common_lisp.json). LMX: **NOT_RUN**; структурная проверка текста не доказывает исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/f_everyc.htm>
