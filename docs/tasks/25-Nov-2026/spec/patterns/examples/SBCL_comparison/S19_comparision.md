# S19. CLOS: изменяемый слот и сохранение полей

Полное сравнение на указанном домене.

## Общий договор

Создать прямоугольник width,height, изменить только width на new-width через accessor и вернуть [width,height,area]. Высота сохраняется и участвует в результате.

## Входы и ожидаемые наблюдения

```json
[
  {
    "args": [
      4,
      3,
      7
    ],
    "expected": [
      7,
      3,
      21
    ]
  },
  {
    "args": [
      5,
      0,
      2
    ],
    "expected": [
      2,
      0,
      0
    ]
  },
  {
    "args": [
      1,
      8,
      0
    ],
    "expected": [
      0,
      8,
      0
    ]
  }
]
```

## Размер полных вариантов

| Источник | Без пробельных | Все символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX — процедурный | 306 | 442 | 18 |
| LMX — функциональный | 306 | 442 | 18 |
| Common Lisp / SBCL | 281 | 337 | 7 |

Оба стиля LMX сравниваются независимо по одному договору. Все объявления, вспомогательные определения и Throws входят в размер. Реализация общих библиотечных операций учитывается отдельно один раз.

## LMX — общая минимальная форма обоих стилей

Обновление настоящего width в скопированном владельце и чтение height/area входят в договор. Последовательность этих stateful операций уже минимальна, поэтому обе формы совпадают.

```lmx
Rectangle:
    int: width 0
    int: height 0
    return: int
    area:
        return: width * height

Example:
    int: width
    int: height
    int: newWidth
    return: @
    run:
        @: rectangle (copy(Rectangle))
        rectangle := parent(rectangle\area)
        rectangle\width := width
        rectangle\height := height
        rectangle\width := newWidth
        return: (rectangle\width; rectangle\height; rectangle\area())
```

[Общий исходник](source/lmx/S19.lm3). Обе формы используют этот текст. 306 непробельных символов; 18 непустых строк. Все объявления и Throws включены.

## Common Lisp / SBCL

[Полный исходник](source/common-lisp/S19.lisp).

```common-lisp
(defclass rectangle ()
  ((width :initarg :width :accessor width)
   (height :initarg :height :accessor height)))

(defun example (width height new-width)
  (let ((shape (make-instance 'rectangle :width width :height height)))
    (setf (width shape) new-width)
    (list (width shape) (height shape) (* (width shape) (height shape)))))
```

## Соответствие стилей договору

Обновление настоящего width в скопированном владельце и чтение height/area входят в договор. Последовательность этих stateful операций уже минимальна, поэтому обе формы совпадают.

Прямой путь LMX выполняет штатное чтение/присваивание поля; отдельный accessor не нужен для данного контракта. Исходные width,height создаются, затем меняется только width, height остаётся в результате и расчёте.

## Общие операции и реализации

Общий договор выражен базовыми средствами языка и приведёнными прикладными определениями.

Common Lisp-клиент использует указанные native/standard средства и не импортирует сравнительные реализации.

## Проверка

SBCL: [статус и датированный отчёт](validation/common_lisp.json). Оба LMX-варианта: **NOT_RUN**; проверки текста не доказывают исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/m_defcla.htm>
