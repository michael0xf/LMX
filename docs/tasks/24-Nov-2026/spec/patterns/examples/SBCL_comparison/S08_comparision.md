# S08. REMOVE-DUPLICATES: сохранить первые

Полное сравнение на указанном домене.

## Общий договор

Убрать повторные целые, сохранив первое вхождение каждого значения и исходный порядок первых вхождений. Вход не меняется; идентичность результирующего контейнера не входит в контракт.

## Входы и ожидаемые наблюдения

```json
[
  {
    "args": [
      [
        3,
        1,
        3,
        2,
        1
      ]
    ],
    "expected": [
      3,
      1,
      2
    ]
  },
  {
    "args": [
      []
    ],
    "expected": []
  },
  {
    "args": [
      [
        0,
        0
      ]
    ],
    "expected": [
      0
    ]
  },
  {
    "args": [
      [
        -1,
        2,
        -1
      ]
    ],
    "expected": [
      -1,
      2
    ]
  }
]
```

## Размер полных вариантов

| Источник | Без пробельных | Все символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX — процедурный | 202 | 388 | 15 |
| LMX — функциональный | 77 | 116 | 6 |
| Common Lisp / SBCL | 63 | 74 | 2 |

Оба стиля LMX сравниваются независимо по одному договору. Все объявления, вспомогательные определения и Throws входят в размер. Реализация общих библиотечных операций учитывается отдельно один раз.

## LMX — процедурный

```lmx
Example:
    int[]: items
    return: @
    run:
        int[]: result []
        int: i 0
        while: i < length(items)
            int: j 0
            while: j < length(result) && result[j] != items[i]
                j += 1
            if: j = length(result)
                sys\resize(result; j + 1)
                result[j] := items[i]
            i += 1
        return: result
```

[Полный исходник](source/lmx/procedural/S08.lm3). 202 непробельных символов; 15 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    int[]: items
    return: @
    run:
        throws: copy(unique\throws)
        return: (unique items)
```

[Полный исходник](source/lmx/S08.lm3). 77 непробельных символов; 6 непустых строк. Все объявления и Throws включены.

## Common Lisp / SBCL

[Полный исходник](source/common-lisp/S08.lisp).

```common-lisp
(defun example (items)
  (remove-duplicates items :from-end t :test #'=))
```

## Соответствие стилей договору

Обе записи сохраняют полный договор; процедурная раскрывает прикладной обход, функциональная использует общие операции/Expression без копии ядрового алгоритма.

(unique items) использует общий Expression и единственное стандартное определение unique с обычным равенством; локальный Equal удалён. Целочисленный домен сохраняет сопоставимость с REMOVE-DUPLICATES :FROM-END T, который оставляет первые вхождения. В общем LMX API same необязателен; профиль исходного массива и тип первого представителя сохраняются.

## Общие операции и реализации

- `unique`: [тело ядра](../../LMX_Fn_Receivers/src/corePerlExamples.lmx); отдельное сравнение [SI03](library_comparisons/SI03_comparision.md).

Common Lisp-клиент использует указанные native/standard средства и не импортирует сравнительные реализации.

## Проверка

SBCL: [фактический отчёт](validation/common_lisp.json). Оба LMX-варианта: **NOT_RUN**; проверки текста не доказывают исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/f_rm_dup.htm>
