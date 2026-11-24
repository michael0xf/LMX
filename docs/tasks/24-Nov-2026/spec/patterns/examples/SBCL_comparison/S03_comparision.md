# S03. REDUCE: левая свёртка

Полное сравнение на указанном домене.

## Общий договор

Вычесть слева направо все элементы из начального значения 20; пустой список возвращает 20.

## Входы и ожидаемые наблюдения

```json
[
  {
    "args": [
      [
        2,
        3,
        4
      ]
    ],
    "expected": 11
  },
  {
    "args": [
      []
    ],
    "expected": 20
  },
  {
    "args": [
      [
        -2,
        0,
        5
      ]
    ],
    "expected": 17
  }
]
```

## Размер полных вариантов

| Источник | Без пробельных | Все символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX — процедурный | 102 | 194 | 10 |
| LMX — функциональный | 110 | 153 | 6 |
| Common Lisp / SBCL | 53 | 63 | 2 |

Оба стиля LMX сравниваются независимо по одному договору. Все объявления, вспомогательные определения и Throws входят в размер. Реализация общих библиотечных операций учитывается отдельно один раз.

## LMX — процедурный

```lmx
Example:
    int[]: items
    return: int
    run:
        int: total 20
        int: i 0
        while: i < length(items)
            total -= items[i]
            i += 1
        return: total
```

[Полный исходник](source/lmx/procedural/S03.lm3). 102 непробельных символов; 10 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    int[]: items
    return: int
    run:
        throws: copy(foldl\throws) copy(record\throws)
        return: \(foldl items (20 record) `-`)
```

[Полный исходник](source/lmx/S03.lm3). 110 непробельных символов; 6 непустых строк. Все объявления и Throws включены.

## Common Lisp / SBCL

[Полный исходник](source/common-lisp/S03.lisp).

```common-lisp
(defun example (items)
  (reduce #'- items :initial-value 20))
```

## Соответствие стилей договору

Обе записи сохраняют полный договор; процедурная раскрывает прикладной обход, функциональная использует общие операции/Expression без копии ядрового алгоритма.

Функциональная форма передаёт готовый стандартный ресивер `-` в foldl; локальный Subtract не нужен. Строгое вычитание слева с seed20 и пустой вход сохраняют исходный договор. Процедурная форма раскрывает тот же обход.

## Общие операции и реализации

- `foldl`: [тело ядра](../../LMX_Fn_Receivers/src/collections.lmx); отдельное сравнение [SI01](library_comparisons/SI01_comparision.md).

- `record`: [тело ядра](../../LMX_Fn_Receivers/src/generic_functions.lmx); отдельное сравнение [SI02](library_comparisons/SI02_comparision.md).

Common Lisp-клиент использует указанные native/standard средства и не импортирует сравнительные реализации.

## Проверка

SBCL: [фактический отчёт](validation/common_lisp.json). Оба LMX-варианта: **NOT_RUN**; проверки текста не доказывают исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/f_reduce.htm>
