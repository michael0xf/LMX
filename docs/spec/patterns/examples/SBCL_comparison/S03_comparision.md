# S03. REDUCE: левая свёртка

Полная пара в указанном ниже договоре.

## Общий договор

Вычесть слева направо все элементы из начального значения 20; пустой список возвращает 20.

## Входы и ожидаемые наблюдения

```json
[
  {
    "args": [
      [
        2,
        3,
        4
      ]
    ],
    "expected": 11
  },
  {
    "args": [
      []
    ],
    "expected": 20
  },
  {
    "args": [
      [
        -2,
        0,
        5
      ]
    ],
    "expected": 17
  }
]
```

## Размер основного варианта

| Источник | Полный, без пробельных | Без сложного Throws | Все символы | Непустые строки |
| --- | ---: | ---: | ---: | ---: |
| LMX | 102 | 102 | 194 | 10 |
| Common Lisp / SBCL | 53 | — | 63 | 2 |

Учитывается полный основной листинг. Тестовый стенд и отдельные реализации ядра в него не входят; их файлы и размеры приведены отдельно.

## LMX

[Исходник](source/lmx/S03.lm3).

```lmx
Example:
    int[]: items
    return: int
    run:
        int: total 20
        int: i 0
        while: i < length(items)
            total -= items[i]
            i += 1
        return: total
```

## Common Lisp / SBCL

[Исходник](source/common-lisp/S03.lisp).

```common-lisp
(defun example (items)
  (reduce #'- items :initial-value 20))
```

## Почему эти варианты сопоставимы

Строгое вычитание слева с seed20; общий алгоритм foldl не нужен для этого фиксированного шага.

 Основной вариант выбран по меньшему полному размеру: Строгое вычитание слева с seed20; общий алгоритм foldl не нужен для этого фиксированного шага.

Средства Common Lisp/SBCL: `CL:REDUCE`.

## Реализации используемых функций

Основной листинг использует базовые средства языка и полностью приведённые прикладные определения.

Common Lisp-клиент не загружает сравнительные reference-реализации.

## Другой подход: LMX с общими ресиверами ядра

Исходный полный вариант; нормы и конечные эффекты проверены. Полные текущие размеры приведены в статистике.

[Исходник](alternatives/lmx/S03_core.lm3). В основной коэффициент не входит.

```lmx
Subtract:
    int: total
    int: value
    return: int
    run:
        return: total - value

Example:
    int[]: items
    return: int
    run:
        throws: copy(FxThrows\recordcall) ReceiverIndex
        return: \foldl(items; (20 record); Subtract\run)
```

`foldl`: [SI01](library_comparisons/SI01_comparision.md).

`record`: [SI02](library_comparisons/SI02_comparision.md).

## Проверка

SBCL: [фактический отчёт](validation/common_lisp.json). LMX: **NOT_RUN**; структурная проверка текста не доказывает исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/f_reduce.htm>
