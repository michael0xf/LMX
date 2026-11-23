# S21. Условие и HANDLER-CASE

Полная пара в указанном ниже договоре.

## Общий договор

Функция checked удваивает неотрицательное целое, а для отрицательного сигналит конкретное условие input-failure. Example перехватывает только это условие и возвращает 99. Возобновляемые restart-сценарии не включены.

## Входы и ожидаемые наблюдения

```json
[
  {
    "args": [
      4
    ],
    "expected": 8
  },
  {
    "args": [
      0
    ],
    "expected": 0
  },
  {
    "args": [
      -1
    ],
    "expected": 99
  }
]
```

## Размер основного варианта

| Источник | Полный, без пробельных | Без сложного Throws | Все символы | Непустые строки |
| --- | ---: | ---: | ---: | ---: |
| LMX | 187 | 187 | 307 | 15 |
| Common Lisp / SBCL | 178 | — | 214 | 7 |

Учитывается полный основной листинг. Тестовый стенд и отдельные реализации ядра в него не входят; их файлы и размеры приведены отдельно.

## LMX

[Исходник](source/lmx/S21.lm3).

```lmx
Checked:
    int: value
    return: int
    checked:
        throws: InputFailure
        if: value < 0
            throw: InputFailure()
        return: value * 2

Example:
    int: value
    return: int
    run:
        return: Checked\checked(value)
        catch: InputFailure ()
            return: 99
```

## Common Lisp / SBCL

[Исходник](source/common-lisp/S21.lisp).

```common-lisp
(define-condition input-failure (error) ())

(defun checked (value)
  (when (minusp value) (error 'input-failure))
  (* value 2))

(defun example (value)
  (handler-case (checked value)
    (input-failure () 99)))
```

## Почему эти варианты сопоставимы

Исходный полный вариант; нормы и конечные эффекты проверены.

Перехватывается один явно объявленный типизированный выход. Нет catch-all и нет притязания на возобновляемые condition/restart Common Lisp.

Средства Common Lisp/SBCL: `CL:DEFINE-CONDITION`, `CL:HANDLER-CASE`, `CL:ERROR`.

## Реализации используемых функций

Основной листинг использует базовые средства языка и полностью приведённые прикладные определения.

Common Lisp-клиент не загружает сравнительные reference-реализации.

## Проверка

SBCL: [фактический отчёт](validation/common_lisp.json). LMX: **NOT_RUN**; структурная проверка текста не доказывает исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/m_defi_5.htm>
- <https://www.lispworks.com/documentation/HyperSpec/Body/m_hand_1.htm>
