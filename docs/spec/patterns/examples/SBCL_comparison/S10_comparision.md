# S10. Замыкание add5

Полная пара в указанном ниже договоре.

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

## Размер основного варианта

| Источник | Полный, без пробельных | Без сложного Throws | Все символы | Непустые строки |
| --- | ---: | ---: | ---: | ---: |
| LMX | 170 | 170 | 257 | 13 |
| Common Lisp / SBCL | 119 | — | 146 | 5 |

Учитывается полный основной листинг. Тестовый стенд и отдельные реализации ядра в него не входят; их файлы и размеры приведены отдельно.

## LMX

[Исходник](source/lmx/S10.lm3).

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
        throws: copy(FxThrows\capture)
        @: add5 partial(Addition\add; (5))
        return: add5(value)
```

## Common Lisp / SBCL

[Исходник](source/common-lisp/S10.lisp).

```common-lisp
(defun make-adder (first)
  (lambda (second) (+ first second)))

(defun example (value)
  (let ((add5 (make-adder 5)))
    (funcall add5 value)))
```

## Почему эти варианты сопоставимы

Использован короткий шаблон H03 из 22-Nov: partial уже является общей фабрикой захвата, поэтому вторая MakeAdder-обёртка удалена. Фабрика для любого first — partial(Addition\add; (first)); исходник partial и полный граф его зависимостей приведены в SI05. Независимые захваты и срок жизни остаются частью приёмки.

Использован короткий шаблон H03 из 22-Nov: partial уже является общей фабрикой захвата, поэтому вторая MakeAdder-обёртка удалена. Фабрика для любого first — partial(Addition\add; (first)); исходник partial и полный граф его зависимостей приведены в SI05. Независимые захваты и срок жизни остаются частью приёмки.

Средства Common Lisp/SBCL: `CL:FUNCTION`, `CL:FUNCALL`.

## Реализации используемых функций

- `partial`: [SI05](library_comparisons/SI05_comparision.md)

Common Lisp-клиент не загружает сравнительные reference-реализации.

## Другой подход: Прямой / процедурный LMX

Обычная копия DATA/кода и явная запись захвата в фактического владельца; чтение owner\first не перехватывается динамическим одноимённым caller. Фабрика принимает произвольный first. Полные текущие размеры приведены в статистике.

[Исходник](alternatives/lmx/S10_copied_owner_closure.lm3). В основной коэффициент не входит.

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

## Проверка

SBCL: [фактический отчёт](validation/common_lisp.json). LMX: **NOT_RUN**; структурная проверка текста не доказывает исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/s_fn.htm>
