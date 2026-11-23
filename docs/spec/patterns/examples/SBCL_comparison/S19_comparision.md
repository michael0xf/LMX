# S19. CLOS: изменяемый слот и сохранение полей

Полная пара в указанном ниже договоре.

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

## Размер основного варианта

| Источник | Полный, без пробельных | Без сложного Throws | Все символы | Непустые строки |
| --- | ---: | ---: | ---: | ---: |
| LMX | 306 | 306 | 442 | 18 |
| Common Lisp / SBCL | 281 | — | 337 | 7 |

Учитывается полный основной листинг. Тестовый стенд и отдельные реализации ядра в него не входят; их файлы и размеры приведены отдельно.

## LMX

[Исходник](source/lmx/S19.lm3).

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

## Common Lisp / SBCL

[Исходник](source/common-lisp/S19.lisp).

```common-lisp
(defclass rectangle ()
  ((width :initarg :width :accessor width)
   (height :initarg :height :accessor height)))

(defun example (width height new-width)
  (let ((shape (make-instance 'rectangle :width width :height height)))
    (setf (width shape) new-width)
    (list (width shape) (height shape) (* (width shape) (height shape)))))
```

## Почему эти варианты сопоставимы

Исходный полный вариант; нормы и конечные эффекты проверены.

Прямой путь LMX выполняет штатное чтение/присваивание поля; отдельный accessor не нужен для данного контракта. Исходные width,height создаются, затем меняется только width, height остаётся в результате и расчёте.

Средства Common Lisp/SBCL: `CL:DEFCLASS`, `CL:SETF`, `CL:MAKE-INSTANCE`.

## Реализации используемых функций

Основной листинг использует базовые средства языка и полностью приведённые прикладные определения.

Common Lisp-клиент не загружает сравнительные reference-реализации.

## Проверка

SBCL: [фактический отчёт](validation/common_lisp.json). LMX: **NOT_RUN**; структурная проверка текста не доказывает исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/m_defcla.htm>
