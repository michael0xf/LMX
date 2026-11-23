# S23. Мемоизация через HASH-TABLE

Полная пара в указанном ниже договоре.

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

## Размер основного варианта

| Источник | Полный, без пробельных | Без сложного Throws | Все символы | Непустые строки |
| --- | ---: | ---: | ---: | ---: |
| LMX | 368 | 368 | 657 | 28 |
| Common Lisp / SBCL | 231 | — | 353 | 8 |

Учитывается полный основной листинг. Тестовый стенд и отдельные реализации ядра в него не входят; их файлы и размеры приведены отдельно.

## LMX

[Исходник](source/lmx/S23.lm3).

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

## Common Lisp / SBCL

[Исходник](source/common-lisp/S23.lisp).

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

## Почему эти варианты сопоставимы

Исходный полный вариант; нормы и конечные эффекты проверены.

В стандартном Common Lisp нет функции MEMOIZE: показана полная прикладная реализация через штатный HASH-TABLE. Основной LMX-вариант должен тоже содержать кеш; отдельный вариант с LMX memoize учитывается отдельно.

Основной вариант содержит прикладной кеш, как CL-пример с HASH-TABLE. Каждая строка кеша — обычная структура (key; value), уже @[]; один массив cache заменяет две параллельные таблицы и два resize. Линейный поиск не имитирует хеш-таблицу. cache/calls живут в текущем Example и доступны Memo по динамическому связыванию. Нулевое значение не означает промах. Вариант с готовым memoize вынесен отдельно из-за иного уровня абстракции.

Средства Common Lisp/SBCL: `CL:MAKE-HASH-TABLE`, `CL:GETHASH`, `CL:MAPCAR`.

## Реализации используемых функций

Основной листинг использует базовые средства языка и полностью приведённые прикладные определения.

Common Lisp-клиент не загружает сравнительные reference-реализации.

## Другой подход: LMX с готовым ядром memoize: другой уровень абстракции

В стандартном Common Lisp нет MEMOIZE: CL-клиент содержит прикладную реализацию. Этот более высокий уровень отдельно связан с SI06 и не уменьшает основной сравнительный размер.

[Исходник](alternatives/lmx/S23_core_memoize.lm3). В основной коэффициент не входит.

```lmx
State:
    int: calls 0

Square:
    int: value
    return: int
    run:
        State\calls += 1
        return: value * value

Keys:
    @: first
    @: second
    return: int
    same:
        return: \first[0] = \second[0]

Example:
    int[]: items
    return: @
    run:
        throws: copy(FxThrows\sequencefixture)
        State\calls := 0
        @: cached memoize(Square\run; Keys\same)
        @: result map(items; cached)
        return: (result; State\calls)
```

`memoize`: [SI06](library_comparisons/SI06_comparision.md).

`map`: [SI01](library_comparisons/SI01_comparision.md).

## Проверка

SBCL: [фактический отчёт](validation/common_lisp.json). LMX: **NOT_RUN**; структурная проверка текста не доказывает исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/f_gethas.htm>
