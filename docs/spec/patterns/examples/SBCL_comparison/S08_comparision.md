# S08. REMOVE-DUPLICATES: сохранить первые

Полная пара в указанном ниже договоре.

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

## Размер основного варианта

| Источник | Полный, без пробельных | Без сложного Throws | Все символы | Непустые строки |
| --- | ---: | ---: | ---: | ---: |
| LMX | 175 | 151 | 253 | 12 |
| Common Lisp / SBCL | 63 | — | 74 | 2 |

Учитывается полный основной листинг. Тестовый стенд и отдельные реализации ядра в него не входят; их файлы и размеры приведены отдельно.

## LMX

[Исходник](source/lmx/S08.lm3).

```lmx
Equal:
    int: first
    int: second
    return: int
    same:
        return: first = second

Example:
    int[]: items
    return: @
    run:
        throws: copy(FxThrows\mutation) FxCallFailure FxPredicate
        return: unique(items; Equal\same)
```

## Common Lisp / SBCL

[Исходник](source/common-lisp/S08.lisp).

```common-lisp
(defun example (items)
  (remove-duplicates items :from-end t :test #'=))
```

## Почему эти варианты сопоставимы

Исходный полный вариант; нормы и конечные эффекты проверены.

Без :FROM-END T стандартный REMOVE-DUPLICATES сохранял бы последние вхождения, что отличалось бы от LMX unique.

Средства Common Lisp/SBCL: `CL:REMOVE-DUPLICATES`.

## Реализации используемых функций

- `unique`: [SI03](library_comparisons/SI03_comparision.md)

Common Lisp-клиент не загружает сравнительные reference-реализации.

## Проверка

SBCL: [фактический отчёт](validation/common_lisp.json). LMX: **NOT_RUN**; структурная проверка текста не доказывает исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/f_rm_dup.htm>
