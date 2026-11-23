# S10. Замыкание add5

Полное сравнение на указанном домене.

## Общий договор

Фабрика make-adder захватывает любое целое first и возвращает унарную функцию. Пример создаёт add5 и применяет её к value; захват живёт после возврата фабрики.

## Входы и ожидаемые наблюдения

```json
[
  {
    "args": [
      3
    ],
    "expected": 8
  },
  {
    "args": [
      0
    ],
    "expected": 5
  },
  {
    "args": [
      -5
    ],
    "expected": 0
  },
  {
    "args": [
      12
    ],
    "expected": 17
  }
]
```

## Размер полных вариантов

| Источник | Без пробельных | Все символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX — процедурный | 260 | 431 | 21 |
| LMX — функциональный | 165 | 254 | 13 |
| Common Lisp / SBCL | 119 | 146 | 5 |

Оба стиля LMX сравниваются независимо по одному договору. Все объявления, вспомогательные определения и Throws входят в размер. Реализация общих библиотечных операций учитывается отдельно один раз.

## LMX — процедурный

```lmx
MakeAdder:
    int: first
    return: @
    Add:
        int: second
        return: int
        add:
            @: owner parent(node)
            return: owner\first + second
    ---
    make:
        @: owner (copy(node))
        owner := parent(owner\Add)
        owner\first := first
        return: owner\Add\add

Example:
    int: value
    return: int
    run:
        @: add5 MakeAdder\make(5)
        return: add5(value)
```

[Полный исходник](source/lmx/procedural/S10.lm3). 260 непробельных символов; 21 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Addition:
    int: first
    int: second
    return: int
    add:
        return: first + second

Example:
    int: value
    return: int
    run:
        throws: copy(partial	hrows)
        @: add5 (partial Addition\add (5))
        return: add5(value)
```

[Полный исходник](source/lmx/S10.lm3). 165 непробельных символов; 13 непустых строк. Все объявления и Throws включены.

## Common Lisp / SBCL

[Полный исходник](source/common-lisp/S10.lisp).

```common-lisp
(defun make-adder (first)
  (lambda (second) (+ first second)))

(defun example (value)
  (let ((add5 (make-adder 5)))
    (funcall add5 value)))
```

## Соответствие стилей договору

Обе записи сохраняют полный договор; процедурная раскрывает прикладной обход, функциональная использует общие операции/Expression без копии ядрового алгоритма.

Использован короткий шаблон H03 из 22-Nov: partial уже является общей фабрикой захвата, поэтому вторая MakeAdder-обёртка удалена. Фабрика для любого first — partial(Addition\add; (first)); исходник partial и полный граф его зависимостей приведены в SI05. Независимые захваты и срок жизни остаются частью приёмки.

## Общие операции и реализации

- `partial`: [тело ядра](../../LMX_Fn_Receivers/src/generic_functions.lmx); отдельное сравнение [SI05](library_comparisons/SI05_comparision.md).

Common Lisp-клиент использует указанные native/standard средства и не импортирует сравнительные реализации.

## Проверка

SBCL: [фактический отчёт](validation/common_lisp.json). Оба LMX-варианта: **NOT_RUN**; проверки текста не доказывают исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/s_fn.htm>
