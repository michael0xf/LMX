# S11. APPLY: сумма аргументов из списка

Полная пара в указанном ниже договоре.

## Общий договор

Просуммировать конечный список целых; пустой список даёт 0. Размер входа ниже CALL-ARGUMENTS-LIMIT установленной реализации; сумма помещается в LMX int.

## Входы и ожидаемые наблюдения

```json
[
  {
    "args": [
      [
        1,
        2,
        3
      ]
    ],
    "expected": 6
  },
  {
    "args": [
      []
    ],
    "expected": 0
  },
  {
    "args": [
      [
        -2,
        0,
        5
      ]
    ],
    "expected": 3
  }
]
```

## Размер основного варианта

| Источник | Полный, без пробельных | Без сложного Throws | Все символы | Непустые строки |
| --- | ---: | ---: | ---: | ---: |
| LMX | 55 | 55 | 85 | 5 |
| Common Lisp / SBCL | 36 | — | 44 | 2 |

Учитывается полный основной листинг. Тестовый стенд и отдельные реализации ядра в него не входят; их файлы и размеры приведены отдельно.

## LMX

[Исходник](source/lmx/S11.lm3).

```lmx
Example:
    int[]: items
    return: int
    run:
        return: (+ 0 copy(items))
```

## Common Lisp / SBCL

[Исходник](source/common-lisp/S11.lisp).

```common-lisp
(defun example (items)
  (apply #'+ items))
```

## Почему эти варианты сопоставимы

Одна variadic application штатного + с явным copy-потоком; нейтральный 0 сохраняет пустой вход. Встроенный числовой операнд уже принимает Expression, адаптер не нужен.

copy(items) явно выдаёт поля в потребитель Expression; это не неявное раскрытие Array. Непустые и пустые плотные массивы требуют отдельной LMX runtime-приёмки, NOT_RUN.

Средства Common Lisp/SBCL: `CL:APPLY`, `CL:+`.

## Реализации используемых функций

Основной листинг использует базовые средства языка и полностью приведённые прикладные определения.

Common Lisp-клиент не загружает сравнительные reference-реализации.

## Другой подход: LMX с общими ресиверами ядра

Исходный полный вариант; нормы и конечные эффекты проверены. Полные текущие размеры приведены в статистике.

[Исходник](alternatives/lmx/S11_core.lm3). В основной коэффициент не входит.

```lmx
Add:
    int: total
    int: value
    return: int
    run:
        return: total + value

Example:
    int[]: items
    return: int
    run:
        throws: copy(FxThrows\recordcall) ReceiverIndex
        return: \foldl(items; (0 record); Add\run)
```

`foldl`: [SI01](library_comparisons/SI01_comparision.md).

`record`: [SI02](library_comparisons/SI02_comparision.md).

## Проверка

SBCL: [фактический отчёт](validation/common_lisp.json). LMX: **NOT_RUN**; структурная проверка текста не доказывает исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/f_apply.htm>
