# S09. REPLACE: ограниченный диапазон

Полная пара в указанном ниже договоре.

## Общий договор

Заменить диапазон [start,end) в копии списка. 0 <= start <= end <= длина; длина replacement равна end-start. Размер результата неизменен; оба входных списка не меняются. Выход за эту область не сравнивается.

## Входы и ожидаемые наблюдения

```json
[
  {
    "args": [
      [
        1,
        2,
        3,
        4
      ],
      1,
      3,
      [
        8,
        9
      ]
    ],
    "expected": [
      1,
      8,
      9,
      4
    ]
  },
  {
    "args": [
      [
        1,
        2
      ],
      1,
      1,
      []
    ],
    "expected": [
      1,
      2
    ]
  },
  {
    "args": [
      [],
      0,
      0,
      []
    ],
    "expected": []
  },
  {
    "args": [
      [
        1,
        2
      ],
      0,
      2,
      [
        7,
        8
      ]
    ],
    "expected": [
      7,
      8
    ]
  }
]
```

## Размер основного варианта

| Источник | Полный, без пробельных | Без сложного Throws | Все символы | Непустые строки |
| --- | ---: | ---: | ---: | ---: |
| LMX | 168 | 168 | 238 | 10 |
| Common Lisp / SBCL | 96 | — | 112 | 2 |

Учитывается полный основной листинг. Тестовый стенд и отдельные реализации ядра в него не входят; их файлы и размеры приведены отдельно.

## LMX

[Исходник](source/lmx/S09.lm3).

```lmx
Example:
    int[]: items
    int: start
    int: end
    int[]: replacement
    return: @
    run:
        throws: copy(FxThrows\mutation)
        int[]: result [copy(items)]
        return: replaceRange(result; start; end; replacement)
```

## Common Lisp / SBCL

[Исходник](source/common-lisp/S09.lisp).

```common-lisp
(defun example (items start end replacement)
  (replace (copy-list items) replacement :start1 start :end1 end))
```

## Почему эти варианты сопоставимы

Исходный полный вариант; нормы и конечные эффекты проверены.

CL REPLACE не меняет длину последовательности. Общий контракт здесь ограничен равной длиной удаляемого и вставляемого диапазонов; это не утверждение тождества всему LMX replaceRange.

Используется только общая область с равной длиной замены. Полный replaceRange умеет менять размер; CL REPLACE этого не обещает. Копирование здесь необходимо для неизменности исходного массива.

Средства Common Lisp/SBCL: `CL:REPLACE`, `CL:COPY-LIST`.

## Реализации используемых функций

- `replaceRange`: [SI04](library_comparisons/SI04_comparision.md)

Common Lisp-клиент не загружает сравнительные reference-реализации.

## Проверка

SBCL: [фактический отчёт](validation/common_lisp.json). LMX: **NOT_RUN**; структурная проверка текста не доказывает исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/f_replac.htm>
