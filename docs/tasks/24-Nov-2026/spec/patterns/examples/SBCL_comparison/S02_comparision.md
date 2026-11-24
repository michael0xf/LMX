# S02. REMOVE-IF-NOT: устойчивый отбор

Полное сравнение на указанном домене.

## Общий договор

Оставить положительные целые в исходном порядке; ноль не проходит. Вход не меняется; независимость хранения результата от входа не требуется.

## Входы и ожидаемые наблюдения

```json
[
  {
    "args": [
      [
        -2,
        0,
        3,
        1
      ]
    ],
    "expected": [
      3,
      1
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
        -1,
        0
      ]
    ],
    "expected": []
  },
  {
    "args": [
      [
        4,
        4
      ]
    ],
    "expected": [
      4,
      4
    ]
  }
]
```

## Размер полных вариантов

| Источник | Без пробельных | Все символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX — процедурный | 165 | 327 | 14 |
| LMX — функциональный | 90 | 132 | 6 |
| Common Lisp / SBCL | 48 | 56 | 2 |

Оба стиля LMX сравниваются независимо по одному договору. Все объявления, вспомогательные определения и Throws входят в размер. Реализация общих библиотечных операций учитывается отдельно один раз.

## LMX — процедурный

```lmx
Example:
    int[]: items
    return: @
    run:
        int[]: result []
        int: used 0
        int: i 0
        while: i < length(items)
            if: items[i] > 0
                sys\resize(result; used + 1)
                result[used] := items[i]
                used += 1
            i += 1
        return: result
```

[Полный исходник](source/lmx/procedural/S02.lm3). 165 непробельных символов; 14 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    int[]: items
    return: @
    run:
        throws: copy(compress\throws)
        return: (compress items (items > 0))
```

[Полный исходник](source/lmx/S02.lm3). 90 непробельных символов; 6 непустых строк. Все объявления и Throws включены.

## Common Lisp / SBCL

[Полный исходник](source/common-lisp/S02.lisp).

```common-lisp
(defun example (items)
  (remove-if-not #'plusp items))
```

## Соответствие стилей договору

Обе записи сохраняют полный договор; процедурная раскрывает прикладной обход, функциональная использует общие операции/Expression без копии ядрового алгоритма.

REMOVE-IF-NOT может разделять неизменённые части списка. Контракт сравнивает значения и отсутствие записи во вход.

 Основной вариант выбран по меньшему полному размеру: Сравнение создаёт int-маску, compress устойчиво отбирает элементы; нет callback с внешними эффектами.

## Общие операции и реализации

- `compress`: [тело ядра](../../LMX_Fn_Receivers/src/sequences.lmx); отдельное сравнение [SI01](library_comparisons/SI01_comparision.md).

Common Lisp-клиент использует указанные native/standard средства и не импортирует сравнительные реализации.

## Дополнительный способ: LMX с общими ресиверами ядра

Исходный полный вариант; нормы и конечные эффекты проверены. Полные текущие размеры приведены в статистике.

[Исходник](alternatives/lmx/S02_core.lm3); вне двух основных сравнений.

```lmx
Positive:
    int: value
    return: int
    accepts:
        return: value > 0

Example:
    int[]: items
    return: @
    run:
        throws: copy(FxThrows\traversal)
        return: filter(items; Positive\accepts)
```

## Проверка

SBCL: [фактический отчёт](validation/common_lisp.json). Оба LMX-варианта: **NOT_RUN**; проверки текста не доказывают исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/f_rm_rm.htm>
