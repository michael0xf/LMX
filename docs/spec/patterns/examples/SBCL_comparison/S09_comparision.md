# S09. REPLACE: ограниченный диапазон

Полное сравнение на указанном домене.

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

## Размер полных вариантов

| Источник | Без пробельных | Все символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX — процедурный | 227 | 405 | 17 |
| LMX — функциональный | 168 | 239 | 10 |
| Common Lisp / SBCL | 96 | 112 | 2 |

Оба стиля LMX сравниваются независимо по одному договору. Все объявления, вспомогательные определения и Throws входят в размер. Реализация общих библиотечных операций учитывается отдельно один раз.

## LMX — процедурный

```lmx
Example:
    int[]: items
    int: start
    int: end
    int[]: replacement
    return: @
    run:
        int[]: result []
        sys\resize(result; length(items))
        int: i 0
        while: i < length(items)
            if: i >= start && i < end
                result[i] := replacement[i - start]
            else:
                result[i] := items[i]
            i += 1
        return: result
```

[Полный исходник](source/lmx/procedural/S09.lm3). 227 непробельных символов; 17 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    int[]: items
    int: start
    int: end
    int[]: replacement
    return: @
    run:
        throws: copy(replaceRange	hrows)
        int[]: result [copy(items)]
        return: replaceRange(result; start; end; replacement)
```

[Полный исходник](source/lmx/S09.lm3). 168 непробельных символов; 10 непустых строк. Все объявления и Throws включены.

## Common Lisp / SBCL

[Полный исходник](source/common-lisp/S09.lisp).

```common-lisp
(defun example (items start end replacement)
  (replace (copy-list items) replacement :start1 start :end1 end))
```

## Соответствие стилей договору

Обе записи сохраняют полный договор; процедурная раскрывает прикладной обход, функциональная использует общие операции/Expression без копии ядрового алгоритма.

CL REPLACE не меняет длину последовательности. Общий контракт здесь ограничен равной длиной удаляемого и вставляемого диапазонов; это не утверждение тождества всему LMX replaceRange.

Используется только общая область с равной длиной замены. Полный replaceRange умеет менять размер; CL REPLACE этого не обещает. Копирование здесь необходимо для неизменности исходного массива.

## Общие операции и реализации

- `replaceRange`: [тело ядра](../../LMX_Fn_Receivers/src/sequences_mutation.lmx); отдельное сравнение [SI04](library_comparisons/SI04_comparision.md).

Common Lisp-клиент использует указанные native/standard средства и не импортирует сравнительные реализации.

## Проверка

SBCL: [фактический отчёт](validation/common_lisp.json). Оба LMX-варианта: **NOT_RUN**; проверки текста не доказывают исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/f_replac.htm>
