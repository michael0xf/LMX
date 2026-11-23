# S12. Ключевые аргументы и значение по умолчанию

Полная пара в указанном ниже договоре.

## Общий договор

Функция area имеет width=1 и height=1 по умолчанию. Вернуть [area с явно переданными width,height в обратном порядке; area только с width]. Нулевые размеры не равны отсутствию аргумента.

## Входы и ожидаемые наблюдения

```json
[
  {
    "args": [
      4,
      3
    ],
    "expected": [
      12,
      4
    ]
  },
  {
    "args": [
      0,
      3
    ],
    "expected": [
      0,
      0
    ]
  },
  {
    "args": [
      2,
      0
    ],
    "expected": [
      0,
      2
    ]
  }
]
```

## Размер основного варианта

| Источник | Полный, без пробельных | Без сложного Throws | Все символы | Непустые строки |
| --- | ---: | ---: | ---: | ---: |
| LMX | 170 | 170 | 251 | 12 |
| Common Lisp / SBCL | 128 | — | 164 | 5 |

Учитывается полный основной листинг. Тестовый стенд и отдельные реализации ядра в него не входят; их файлы и размеры приведены отдельно.

## LMX

[Исходник](source/lmx/S12.lm3).

```lmx
Area:
    int: width 1
    int: height 1
    return: int
    area:
        return: width * height

Example:
    int: width
    int: height
    return: @
    run:
        return: (Area\area(height := height; width := width); Area\area(width := width))
```

## Common Lisp / SBCL

[Исходник](source/common-lisp/S12.lisp).

```common-lisp
(defun area (&key (width 1) (height 1))
  (* width height))

(defun example (width height)
  (list (area :height height :width width)
        (area :width width)))
```

## Почему эти варианты сопоставимы

Исходный полный вариант; нормы и конечные эффекты проверены.

После именования height не на текущей позиции второй аргумент также именован. Собственное значение height=1 не заменяется одноимённым полем caller; явно переданный 0 не является пропуском.

Средства Common Lisp/SBCL: `CL:&KEY`.

## Реализации используемых функций

Основной листинг использует базовые средства языка и полностью приведённые прикладные определения.

Common Lisp-клиент не загружает сравнительные reference-реализации.

## Проверка

SBCL: [фактический отчёт](validation/common_lisp.json). LMX: **NOT_RUN**; структурная проверка текста не доказывает исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/03_da.htm>
