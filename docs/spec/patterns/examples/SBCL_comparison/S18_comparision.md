# S18. CLOS: общий вызов для разных объектов

Полное сравнение на указанном домене.

## Общий договор

Создать прямоугольник width,height и квадрат side; вызвать общий area у каждого и вернуть [width*height,side*side]. Поля и методы не подменяются вычислением в драйвере. Эта пара не реализует всю систему CLOS, множественную диспетчеризацию или method combination.

## Входы и ожидаемые наблюдения

```json
[
  {
    "args": [
      4,
      3,
      5
    ],
    "expected": [
      12,
      25
    ]
  },
  {
    "args": [
      0,
      3,
      0
    ],
    "expected": [
      0,
      0
    ]
  },
  {
    "args": [
      2,
      7,
      3
    ],
    "expected": [
      14,
      9
    ]
  }
]
```

## Размер полных вариантов

| Источник | Без пробельных | Все символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX — процедурный | 371 | 560 | 25 |
| LMX — функциональный | 371 | 560 | 25 |
| Common Lisp / SBCL | 389 | 489 | 13 |

Оба стиля LMX сравниваются независимо по одному договору. Все объявления, вспомогательные определения и Throws входят в размер. Реализация общих библиотечных операций учитывается отдельно один раз.

## LMX — общая минимальная форма обоих стилей

Объекты с полями и реальными methods создаются и вызываются полностью. Функциональная свёртка по двум заранее известным объектам добавила бы обход, не сокращая object/dispatch договор; обе формы оставлены минимальными.

```lmx
Rectangle:
    int: width 0
    int: height 0
    return: int
    area:
        return: width * height

Square:
    int: side 0
    return: int
    area:
        return: side * side

Example:
    int: width
    int: height
    int: side
    return: @
    run:
        @: rectangle (copy(Rectangle))
        rectangle := parent(rectangle\area)
        @: square (copy(Square))
        square := parent(square\area)
        rectangle\width := width
        rectangle\height := height
        square\side := side
        return: (rectangle\area(); square\area())
```

[Общий исходник](source/lmx/S18.lm3). Обе формы используют этот текст. 371 непробельных символов; 25 непустых строк. Все объявления и Throws включены.

## Common Lisp / SBCL

[Полный исходник](source/common-lisp/S18.lisp).

```common-lisp
(defclass rectangle ()
  ((width :initarg :width :reader width)
   (height :initarg :height :reader height)))

(defclass square ()
  ((side :initarg :side :reader side)))

(defmethod area ((shape rectangle))
  (* (width shape) (height shape)))

(defmethod area ((shape square))
  (* (side shape) (side shape)))

(defun example (width height side)
  (mapcar #'area
          (list (make-instance 'rectangle :width width :height height)
                (make-instance 'square :side side))))
```

## Соответствие стилей договору

Объекты с полями и реальными methods создаются и вызываются полностью. Функциональная свёртка по двум заранее известным объектам добавила бы обход, не сокращая object/dispatch договор; обе формы оставлены минимальными.

LMX может прикрепить area к владельцу объекта и использовать собственный вызов; принудительная имитация таблицы методов CLOS не нужна.

Метод area находится у фактического владельца каждого объекта; LMX не подделывает классы/таблицы CLOS. parent после собирающей группы copy выбирает реальный DATA владельца скопированного кода. Все поля и оба метода присутствуют в листинге.

## Общие операции и реализации

Общий договор выражен базовыми средствами языка и приведёнными прикладными определениями.

Common Lisp-клиент использует указанные native/standard средства и не импортирует сравнительные реализации.

## Проверка

SBCL: [статус и датированный отчёт](validation/common_lisp.json). Оба LMX-варианта: **NOT_RUN**; проверки текста не доказывают исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/m_defcla.htm>
- <https://www.lispworks.com/documentation/HyperSpec/Body/m_defmet.htm>
