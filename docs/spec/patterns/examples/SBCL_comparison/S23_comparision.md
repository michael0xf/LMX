# S23. Мемоизация через HASH-TABLE

Полное сравнение на указанном домене.

## Общий договор

Внутри одного вызова example кешировать квадрат целого по EQL-ключу. Вернуть [список квадратов в порядке запросов, число фактических вычислений]. Повтор нуля должен попадать в кеш. Кеш свежий для каждого example, не разделяется между потоками.

## Входы и ожидаемые наблюдения

```json
[
  {
    "args": [
      [
        2,
        0,
        2,
        0,
        3
      ]
    ],
    "expected": [
      [
        4,
        0,
        4,
        0,
        9
      ],
      3
    ]
  },
  {
    "args": [
      []
    ],
    "expected": [
      [],
      0
    ]
  },
  {
    "args": [
      [
        -2,
        2,
        -2
      ]
    ],
    "expected": [
      [
        4,
        4,
        4
      ],
      2
    ]
  }
]
```

## Размер полных вариантов

| Источник | Без пробельных | Все символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX — процедурный | 368 | 657 | 28 |
| LMX — функциональный | 230 | 346 | 16 |
| Common Lisp / SBCL | 231 | 353 | 8 |

Оба стиля LMX сравниваются независимо по одному договору. Все объявления, вспомогательные определения и Throws входят в размер. Реализация общих библиотечных операций учитывается отдельно один раз.

## LMX — процедурный

```lmx
Memo:
    int: value
    return: int
    get:
        int: i 0
        while: i < length(cache)
            @: row cache[i]
            if: \row[0] = value
                return: \row[1]
            i += 1
        int: square value * value
        calls += 1
        sys\resize(cache; i + 1)
        cache[i] := (value; square)
        return: square

Example:
    int[]: items
    return: @
    run:
        @[]: cache []
        int: calls 0
        int[]: result []
        sys\resize(result; length(items))
        int: i 0
        while: i < length(items)
            result[i] := Memo\get(items[i])
            i += 1
        return: (result; calls)
```

[Полный исходник](source/lmx/procedural/S23.lm3). 368 непробельных символов; 28 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
State:
    int: calls 0

Square:
    int: value
    return: int
    run:
        State\calls += 1
        return: value * value

Example:
    int[]: items
    return: @
    run:
        throws: copy(memoize\throws) copy(map\throws)
        State\calls := 0
        @: result (map items (memoize Square\run))
        return: (result; State\calls)
```

[Полный исходник](source/lmx/S23.lm3). 230 непробельных символов; 16 непустых строк. Все объявления и Throws включены.

## Common Lisp / SBCL

[Полный исходник](source/common-lisp/S23.lisp).

```common-lisp
(defun example (items)
  (let ((cache (make-hash-table :test #'eql)) (calls 0))
    (flet ((square (x)
             (multiple-value-bind (value present) (gethash x cache)
               (if present value
                   (progn (incf calls)
                          (setf (gethash x cache) (* x x)))))))
      (list (mapcar #'square items) calls))))
```

## Соответствие стилей договору

Обе записи сохраняют полный договор; процедурная раскрывает прикладной обход, функциональная использует общие операции/Expression без копии ядрового алгоритма.

В стандартном Common Lisp нет функции MEMOIZE: показана полная прикладная реализация через штатный HASH-TABLE. Основной LMX-вариант должен тоже содержать кеш; отдельный вариант с LMX memoize учитывается отдельно.

Основной вариант содержит прикладной кеш, как CL-пример с HASH-TABLE. Каждая строка кеша — обычная структура (key; value), уже @[]; один массив cache заменяет две параллельные таблицы и два resize. Линейный поиск не имитирует хеш-таблицу. cache/calls живут в текущем Example и доступны Memo по динамическому связыванию. Нулевое значение не означает промах. Вариант с готовым memoize вынесен отдельно из-за иного уровня абстракции.

## Общие операции и реализации

- `memoize`: [тело ядра](../../LMX_Fn_Receivers/src/generic_combinators.lmx); отдельное сравнение [SI06](library_comparisons/SI06_comparision.md).

- `map`: [тело ядра](../../LMX_Fn_Receivers/src/collections.lmx); отдельное сравнение [SI01](library_comparisons/SI01_comparision.md).

Common Lisp-клиент использует указанные native/standard средства и не импортирует сравнительные реализации.

## Проверка

SBCL: [статус и датированный отчёт](validation/common_lisp.json). Оба LMX-варианта: **NOT_RUN**; проверки текста не доказывают исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/f_gethas.htm>
