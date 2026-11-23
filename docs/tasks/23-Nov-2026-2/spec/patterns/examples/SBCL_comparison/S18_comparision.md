# S18. CLOS: общий вызов для разных объектов

Полная пара в указанном ниже договоре.

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

## Размер основного варианта

| Источник | Полный, без пробельных | Без сложного Throws | Все символы | Непустые строки |
| --- | ---: | ---: | ---: | ---: |
| LMX | 371 | 371 | 560 | 25 |
| Common Lisp / SBCL | 389 | — | 489 | 13 |

Учитывается полный основной листинг. Тестовый стенд и отдельные реализации ядра в него не входят; их файлы и размеры приведены отдельно.

## LMX

[Исходник](source/lmx/S18.lm3).

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

## Common Lisp / SBCL

[Исходник](source/common-lisp/S18.lisp).

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

## Почему эти варианты сопоставимы

Исходный полный вариант; нормы и конечные эффекты проверены.

LMX может прикрепить area к владельцу объекта и использовать собственный вызов; принудительная имитация таблицы методов CLOS не нужна.

Метод area находится у фактического владельца каждого объекта; LMX не подделывает классы/таблицы CLOS. parent после собирающей группы copy выбирает реальный DATA владельца скопированного кода. Все поля и оба метода присутствуют в листинге.

Средства Common Lisp/SBCL: `CL:DEFCLASS`, `CL:DEFMETHOD`, `CL:MAKE-INSTANCE`, `CL:MAPCAR`.

## Реализации используемых функций

Основной листинг использует базовые средства языка и полностью приведённые прикладные определения.

Common Lisp-клиент не загружает сравнительные reference-реализации.

## Проверка

SBCL: [фактический отчёт](validation/common_lisp.json). LMX: **NOT_RUN**; структурная проверка текста не доказывает исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/m_defcla.htm>
- <https://www.lispworks.com/documentation/HyperSpec/Body/m_defmet.htm>
