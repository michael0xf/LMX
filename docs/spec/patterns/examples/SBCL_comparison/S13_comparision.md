# S13. Динамическая переменная SPECIAL

Полная пара в указанном ниже договоре.

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

## Размер основного варианта

| Источник | Полный, без пробельных | Без сложного Throws | Все символы | Непустые строки |
| --- | ---: | ---: | ---: | ---: |
| LMX | 198 | 198 | 311 | 17 |
| Common Lisp / SBCL | 153 | — | 188 | 6 |

Учитывается полный основной листинг. Тестовый стенд и отдельные реализации ядра в него не входят; их файлы и размеры приведены отдельно.

## LMX

[Исходник](source/lmx/S13.lm3).

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

## Common Lisp / SBCL

[Исходник](source/common-lisp/S13.lisp).

```common-lisp
(defparameter *scale* 2)

(defun read-scaled (value)
  (* value *scale*))

(defun example (value factor)
  (list (let ((*scale* factor)) (read-scaled value))
        (read-scaled value)))
```

## Почему эти варианты сопоставимы

Reading\Eval читает свободные value и scale. Bound связывает scale, но не объявляет и не потребляет value: value проходит по цепочке Example → Bound → Reading\Eval согласно CORE §3.3. После возврата Bound отдельный вызов использует лексическое scale=2. Добавочной передачи контекста нет.

Reading\Eval читает свободные value и scale. Bound связывает scale, но не объявляет и не потребляет value: value проходит по цепочке Example → Bound → Reading\Eval согласно CORE §3.3. После возврата Bound отдельный вызов использует лексическое scale=2. Добавочной передачи контекста нет.

Средства Common Lisp/SBCL: `CL:DEFPARAMETER`, `CL:LET`, `CL:SPECIAL`.

## Реализации используемых функций

Основной листинг использует базовые средства языка и полностью приведённые прикладные определения.

Common Lisp-клиент не загружает сравнительные reference-реализации.

## Проверка

SBCL: [фактический отчёт](validation/common_lisp.json). LMX: **NOT_RUN**; структурная проверка текста не доказывает исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/d_specia.htm>
- <https://www.lispworks.com/documentation/HyperSpec/Body/03_abaab.htm>
