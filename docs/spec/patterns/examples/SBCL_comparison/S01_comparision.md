# S01. MAPCAR: калибровка измерений и итог

Полное сравнение на указанном домене.

## Общий договор

Для конечного списка целых items и целых gain, offset получить calibrated[i] = items[i] * gain + offset; вернуть [calibrated, total], где total — сумма откалиброванных значений. Сохранить порядок и входы. Пустой список даёт [[], 0]. Все произведения, суммы и промежуточные значения помещаются в выбранный LMX int.

## Входы и ожидаемые наблюдения

```json
[
  {
    "args": [
      [
        -2,
        0,
        3
      ],
      3,
      2
    ],
    "expected": [
      [
        -4,
        2,
        11
      ],
      9
    ]
  },
  {
    "args": [
      [],
      3,
      2
    ],
    "expected": [
      [],
      0
    ]
  },
  {
    "args": [
      [
        7
      ],
      -2,
      1
    ],
    "expected": [
      [
        -13
      ],
      -13
    ]
  },
  {
    "args": [
      [
        1,
        1,
        2
      ],
      0,
      5
    ],
    "expected": [
      [
        5,
        5,
        5
      ],
      15
    ]
  }
]
```

## Размер полных вариантов

| Источник | Без пробельных | Все символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX — процедурный | 260 | 430 | 17 |
| LMX — функциональный | 122 | 180 | 8 |
| Common Lisp / SBCL | 143 | 172 | 3 |

Оба стиля LMX сравниваются независимо по одному договору. Все объявления, вспомогательные определения и Throws входят в размер. Реализация общих библиотечных операций учитывается отдельно один раз.

## LMX — процедурный

```lmx
Example:
    []int: items
    int: gain
    int: offset
    return: @
    run:
        throws: copy(sys\resize\throws)
        []int: calibrated []
        sys\resize(calibrated; length(items))
        int: total 0
        int: i 0
        while: i < length(items)
            int: value items[i] * gain + offset
            calibrated[i] := value
            total += value
            i += 1
        return: (calibrated; total)
```

[Полный исходник](source/lmx/procedural/S01.lm3). 260 непробельных символов; 17 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    []int: items
    int: gain
    int: offset
    return: @
    run:
        []int: calibrated items * gain + offset
        return: (calibrated; (+ 0 copy(calibrated)))
```

[Полный исходник](source/lmx/S01.lm3). 122 непробельных символов; 8 непустых строк. Все объявления и Throws включены.

## Common Lisp / SBCL

[Полный исходник](source/common-lisp/S01.lisp).

```common-lisp
(defun example (items gain offset)
  (let ((calibrated (mapcar (lambda (x) (+ (* x gain) offset)) items)))
    (list calibrated (reduce #'+ calibrated :initial-value 0))))
```

## Соответствие стилей договору

Процедурная форма выполняет один цикл и одновременно накапливает итог. Функциональная строит откалиброванный массив элементным Expression и затем вычисляет сумму общего потока.

Калибровка имеет два настраиваемых параметра; откалиброванный ряд используется и как результат, и для итогового накопления. Элементная арифметика Array/scalar сохраняется, а copy явно открывает готовые значения для суммирующего Expression.

## Общие операции и реализации

Общий договор выражен базовыми средствами языка и приведёнными прикладными определениями.

Common Lisp-клиент использует указанные native/standard средства и не импортирует сравнительные реализации.

## Проверка

Для обновлённого кода **SBCL: NOT_RUN; LMX parser/runtime: NOT_RUN**. Статистика пересчитана по полным исходникам; это не выполнение программ. [Статус и прежний receipt](validation/common_lisp.json).

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/f_mapc_.htm>
- <https://www.lispworks.com/documentation/HyperSpec/Body/f_reduce.htm>
