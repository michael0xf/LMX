# S13. Динамическая переменная SPECIAL

Полное сравнение на указанном домене.

## Общий договор

read-scaled читает текущий scale без отдельного аргумента scale. Внутри динамического связывания factor вернуть value*factor; затем value*2, подтверждая восстановление внешнего связывания. Сравниваются этот путь чтения и восстановление, не все правила окружений.

## Входы и ожидаемые наблюдения

```json
[
  {
    "args": [
      3,
      5
    ],
    "expected": [
      15,
      6
    ]
  },
  {
    "args": [
      0,
      9
    ],
    "expected": [
      0,
      0
    ]
  },
  {
    "args": [
      -2,
      4
    ],
    "expected": [
      -8,
      -4
    ]
  }
]
```

## Размер полных вариантов

| Источник | Без пробельных | Все символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX — процедурный | 198 | 311 | 17 |
| LMX — функциональный | 198 | 311 | 17 |
| Common Lisp / SBCL | 153 | 188 | 6 |

Оба стиля LMX сравниваются независимо по одному договору. Все объявления, вспомогательные определения и Throws входят в размер. Реализация общих библиотечных операций учитывается отдельно один раз.

## LMX — общая минимальная форма обоих стилей

Оба стиля используют те же реальные свободные имена и forwarding-call для наблюдения динамического связывания и восстановления внешнего scale. Отдельный context object или передача scale аргументом изменили бы этот договор.

```lmx
Reading:
    int: scale 2
    Eval:
        return: int
        read:
            return: value * scale

Bound:
    int: scale
    return: int
    read:
        return: Reading\Eval\read()

Example:
    int: value
    int: factor
    return: @
    run:
        return: (Bound\read(factor); Reading\Eval\read())
```

[Общий исходник](source/lmx/S13.lm3). Обе формы используют этот текст. 198 непробельных символов; 17 непустых строк. Все объявления и Throws включены.

## Common Lisp / SBCL

[Полный исходник](source/common-lisp/S13.lisp).

```common-lisp
(defparameter *scale* 2)

(defun read-scaled (value)
  (* value *scale*))

(defun example (value factor)
  (list (let ((*scale* factor)) (read-scaled value))
        (read-scaled value)))
```

## Соответствие стилей договору

Оба стиля используют те же реальные свободные имена и forwarding-call для наблюдения динамического связывания и восстановления внешнего scale. Отдельный context object или передача scale аргументом изменили бы этот договор.

Reading\Eval читает свободные value и scale. Bound связывает scale, но не объявляет и не потребляет value: value проходит по цепочке Example → Bound → Reading\Eval согласно CORE §3.3. После возврата Bound отдельный вызов использует лексическое scale=2. Добавочной передачи контекста нет.

## Общие операции и реализации

Общий договор выражен базовыми средствами языка и приведёнными прикладными определениями.

Common Lisp-клиент использует указанные native/standard средства и не импортирует сравнительные реализации.

## Проверка

SBCL: [статус и датированный отчёт](validation/common_lisp.json). Оба LMX-варианта: **NOT_RUN**; проверки текста не доказывают исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/d_specia.htm>
- <https://www.lispworks.com/documentation/HyperSpec/Body/03_abaab.htm>
