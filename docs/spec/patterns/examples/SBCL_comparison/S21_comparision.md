# S21. Условие и HANDLER-CASE

Полное сравнение на указанном домене.

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

## Размер полных вариантов

| Источник | Без пробельных | Все символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX — процедурный | 187 | 307 | 15 |
| LMX — функциональный | 352 | 521 | 24 |
| Common Lisp / SBCL | 178 | 214 | 7 |

Оба стиля LMX сравниваются независимо по одному договору. Все объявления, вспомогательные определения и Throws входят в размер. Реализация общих библиотечных операций учитывается отдельно один раз.

## LMX — процедурный

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

[Полный исходник](source/lmx/procedural/S21.lm3). 187 непробельных символов; 15 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Checked:
    int: value
    return: int
    checked:
        throws: InputFailure
        if: value < 0
            throw: InputFailure()
        return: value * 2

ResultValue:
    int: value
    return: int
    use:
        return: value

FailureValue:
    @: reason
    return: int
    use:
        return: 99

Example:
    int: value
    return: int
    run:
        throws: copy(attempt\throws) copy(foldResult\throws)
        return: \(foldResult (attempt Checked\checked (value)) FailureValue\use ResultValue\use)
```

[Полный исходник](source/lmx/S21.lm3). 352 непробельных символов; 24 непустых строк. Все объявления и Throws включены.

## Common Lisp / SBCL

[Полный исходник](source/common-lisp/S21.lisp).

```common-lisp
(define-condition input-failure (error) ())

(defun checked (value)
  (when (minusp value) (error 'input-failure))
  (* value 2))

(defun example (value)
  (handler-case (checked value)
    (input-failure () 99)))
```

## Соответствие стилей договору

Обе записи сохраняют полный договор; процедурная раскрывает прикладной обход, функциональная использует общие операции/Expression без копии ядрового алгоритма.

Перехватывается один явно объявленный типизированный выход. Нет catch-all и нет притязания на возобновляемые condition/restart Common Lisp.

## Общие операции и реализации

- `attempt`: [тело ядра](../../LMX_Fn_Receivers/src/coreStandardObjects.lmx).

- `foldResult`: [тело ядра](../../LMX_Fn_Receivers/src/coreStandardObjects.lmx).

Common Lisp-клиент использует указанные native/standard средства и не импортирует сравнительные реализации.

## Проверка

SBCL: [статус и датированный отчёт](validation/common_lisp.json). Оба LMX-варианта: **NOT_RUN**; проверки текста не доказывают исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/m_defi_5.htm>
- <https://www.lispworks.com/documentation/HyperSpec/Body/m_hand_1.htm>
