# S11. APPLY: обороты и итоговый баланс

Полное сравнение на указанном домене.

## Общий договор

Даны начальный целый баланс opening и конечные списки неотрицательных целых charges и credits. Вернуть [chargeTotal, creditTotal, closing], где closing = opening + chargeTotal - creditTotal. Пустой список имеет сумму 0, входы не меняются. Все суммы и промежуточные значения помещаются в LMX int.

## Входы и ожидаемые наблюдения

```json
[
  {
    "args": [
      100,
      [
        20,
        5
      ],
      [
        10,
        7
      ]
    ],
    "expected": [
      25,
      17,
      108
    ]
  },
  {
    "args": [
      0,
      [],
      []
    ],
    "expected": [
      0,
      0,
      0
    ]
  },
  {
    "args": [
      -5,
      [],
      [
        2
      ]
    ],
    "expected": [
      0,
      2,
      -7
    ]
  },
  {
    "args": [
      0,
      [
        2,
        2
      ],
      [
        1
      ]
    ],
    "expected": [
      4,
      1,
      3
    ]
  }
]
```

## Размер полных вариантов

| Источник | Без пробельных | Все символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX — процедурный | 268 | 429 | 19 |
| LMX — функциональный | 164 | 236 | 9 |
| Common Lisp / SBCL | 146 | 182 | 4 |

Оба стиля LMX сравниваются независимо по одному договору. Все объявления, вспомогательные определения и Throws входят в размер. Реализация общих библиотечных операций учитывается отдельно один раз.

## LMX — процедурный

```lmx
Total:
    []int: items
    return: int
    sum:
        int: result 0
        int: i 0
        while: i < length(items)
            result += items[i]
            i += 1
        return: result

Example:
    int: opening
    []int: charges
    []int: credits
    return: @
    run:
        int: charged Total\sum(charges)
        int: credited Total\sum(credits)
        return: (charged; credited; opening + charged - credited)
```

[Полный исходник](source/lmx/procedural/S11.lm3). 268 непробельных символов; 19 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    int: opening
    []int: charges
    []int: credits
    return: @
    run:
        int: charged (+ 0 copy(charges))
        int: credited (+ 0 copy(credits))
        return: (charged; credited; opening + charged - credited)
```

[Полный исходник](source/lmx/S11.lm3). 164 непробельных символов; 9 непустых строк. Все объявления и Throws включены.

## Common Lisp / SBCL

[Полный исходник](source/common-lisp/S11.lisp).

```common-lisp
(defun example (opening charges credits)
  (let ((charged (apply #'+ charges))
        (credited (apply #'+ credits)))
    (list charged credited (- (+ opening charged) credited))))
```

## Соответствие стилей договору

Процедурный стиль использует один локальный цикл суммирования повторно. Функциональный записывает обе вариадические суммы через общий Expression, затем строит финансовую сводку без повторного вычисления сумм.

Две независимые последовательности превращаются в аргументы обычного +; готовые числовые итоги затем используются в балансе. Процедурный helper Total\sum определён один раз для обоих входов. Copy открывает значения явно и не вводит неявное рекурсивное раскрытие произвольных записей.

## Общие операции и реализации

Общий договор выражен базовыми средствами языка и приведёнными прикладными определениями.

Common Lisp-клиент использует указанные native/standard средства и не импортирует сравнительные реализации.

## Проверка

Для обновлённого кода **SBCL: NOT_RUN; LMX parser/runtime: NOT_RUN**. Статистика пересчитана по полным исходникам; это не выполнение программ. [Статус и прежний receipt](validation/common_lisp.json).

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/f_apply.htm>
