# S02. REMOVE-IF-NOT: устойчивый отбор

Полная пара в указанном ниже договоре.

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

## Размер основного варианта

| Источник | Полный, без пробельных | Без сложного Throws | Все символы | Непустые строки |
| --- | ---: | ---: | ---: | ---: |
| LMX | 98 | 91 | 140 | 6 |
| Common Lisp / SBCL | 48 | — | 56 | 2 |

Учитывается полный основной листинг. Тестовый стенд и отдельные реализации ядра в него не входят; их файлы и размеры приведены отдельно.

## LMX

[Исходник](source/lmx/S02.lm3).

```lmx
Example:
    int[]: items
    return: @
    run:
        throws: copy(FxThrows\mutation) FxShape
        return: compress(items; items > 0)
```

## Common Lisp / SBCL

[Исходник](source/common-lisp/S02.lisp).

```common-lisp
(defun example (items)
  (remove-if-not #'plusp items))
```

## Почему эти варианты сопоставимы

Сравнение создаёт int-маску, compress устойчиво отбирает элементы; нет callback с внешними эффектами.

REMOVE-IF-NOT может разделять неизменённые части списка. Контракт сравнивает значения и отсутствие записи во вход.

 Основной вариант выбран по меньшему полному размеру: Сравнение создаёт int-маску, compress устойчиво отбирает элементы; нет callback с внешними эффектами.

Средства Common Lisp/SBCL: `CL:REMOVE-IF-NOT`.

## Реализации используемых функций

- `compress`: [SI01](library_comparisons/SI01_comparision.md)

Common Lisp-клиент не загружает сравнительные reference-реализации.

## Другой подход: LMX с общими ресиверами ядра

Исходный полный вариант; нормы и конечные эффекты проверены. Полные текущие размеры приведены в статистике.

[Исходник](alternatives/lmx/S02_core.lm3). В основной коэффициент не входит.

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

`filter`: [SI01](library_comparisons/SI01_comparision.md).

## Проверка

SBCL: [фактический отчёт](validation/common_lisp.json). LMX: **NOT_RUN**; структурная проверка текста не доказывает исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/f_rm_rm.htm>
