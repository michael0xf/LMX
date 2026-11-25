# S09. REPLACE: изменение остатков и отчёт о правке

Полное сравнение на указанном домене.

## Общий договор

Даны конечный список целых items, 0 <= start <= end <= length(items) и replacement длиной ровно end-start. На независимой копии заменить полуинтервал [start,end). Вернуть [updated, changedCount, deltaTotal], где changedCount считает позиции с фактически новым значением, а deltaTotal — сумма updated[i]-items[i]. Входы не меняются; пустой диапазон допустим. Все значения, разности и суммы помещаются в LMX int.

## Входы и ожидаемые наблюдения

```json
[
  {
    "args": [
      [
        4,
        5,
        6,
        7
      ],
      1,
      3,
      [
        5,
        9
      ]
    ],
    "expected": [
      [
        4,
        5,
        9,
        7
      ],
      1,
      3
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
      [
        1,
        2
      ],
      0,
      0
    ]
  },
  {
    "args": [
      [],
      0,
      0,
      []
    ],
    "expected": [
      [],
      0,
      0
    ]
  },
  {
    "args": [
      [
        5,
        8
      ],
      0,
      2,
      [
        1,
        2
      ]
    ],
    "expected": [
      [
        1,
        2
      ],
      2,
      -10
    ]
  }
]
```

## Размер полных вариантов

| Источник | Без пробельных | Все символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX — процедурный | 347 | 591 | 22 |
| LMX — функциональный | 237 | 325 | 11 |
| Common Lisp / SBCL | 207 | 255 | 4 |

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
        throws: copy(sys\resize\throws)
        int[]: result []
        sys\resize(result; length(items))
        int: changed 0
        int: delta 0
        int: i 0
        while: i < length(items)
            int: value items[i]
            if: i >= start && i < end
                value := replacement[i - start]
            result[i] := value
            changed += (value != items[i])
            delta += value - items[i]
            i += 1
        return: (result; changed; delta)
```

[Полный исходник](source/lmx/procedural/S09.lm3). 347 непробельных символов; 22 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    int[]: items
    int: start
    int: end
    int[]: replacement
    return: @
    run:
        throws: copy(replaceRange\throws) copy(sum\throws)
        int[]: result [copy(items)]
        replaceRange(result; start; end; replacement)
        return: (result; \(sum (result != items)); \(sum (result - items)))
```

[Полный исходник](source/lmx/S09.lm3). 237 непробельных символов; 11 непустых строк. Все объявления и Throws включены.

## Common Lisp / SBCL

[Полный исходник](source/common-lisp/S09.lisp).

```common-lisp
(defun example (items start end replacement)
  (let ((updated (replace (copy-list items) replacement :start1 start :end1 end)))
    (list updated (count nil (mapcar #'= updated items))
          (reduce #'+ (mapcar #'- updated items) :initial-value 0))))
```

## Соответствие стилей договору

Процедурный цикл одновременно создаёт копию и отчёт. Функциональный вариант применяет replaceRange к независимой копии и строит сводку элементными выражениями и sum.

Одинаковая длина replacement и диапазона сохраняет прежнюю согласованную границу REPLACE/replaceRange. Изменения считаются по значениям: запись прежнего значения не увеличивает changedCount. Сравнение и вычитание равнодлинных dense Array в LMX элементные; сумма получает их результаты явно.

## Общие операции и реализации

- `replaceRange`: [тело ядра](../../LMX_Fn_Receivers/src/sequences_mutation.lmx); отдельное сравнение [SI04](library_comparisons/SI04_comparision.md).

- `sum`: [тело ядра](../../LMX_Fn_Receivers/src/coreStandardNumeric.lmx).

Common Lisp-клиент использует указанные native/standard средства и не импортирует сравнительные реализации.

## Проверка

Для обновлённого кода **SBCL: NOT_RUN; LMX parser/runtime: NOT_RUN**. Статистика пересчитана по полным исходникам; это не выполнение программ. [Статус и прежний receipt](validation/common_lisp.json).

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/f_replac.htm>
- <https://www.lispworks.com/documentation/HyperSpec/Body/f_mapc_.htm>
- <https://www.lispworks.com/documentation/HyperSpec/Body/f_countc.htm>
- <https://www.lispworks.com/documentation/HyperSpec/Body/f_reduce.htm>
