# S22. UNWIND-PROTECT: полный жизненный цикл

Полная пара в указанном ниже договоре.

## Общий договор

Ресурс содержит value=42 и width=8. Acquire/action/release добавляют 1/2/3 к десятичному trace. Mode 0: успех [50,123]; 1: сбой action [-2,123]; 2: сбой acquire [-1,1] без release; 3: сбой release [-3,123]; 4: action и release ошибаются, побеждает release [-3,123]. Вызовы и cleanup выполняются ровно по одному разу.

## Входы и ожидаемые наблюдения

```json
[
  {
    "args": [
      0
    ],
    "expected": [
      50,
      123
    ]
  },
  {
    "args": [
      1
    ],
    "expected": [
      -2,
      123
    ]
  },
  {
    "args": [
      2
    ],
    "expected": [
      -1,
      1
    ]
  },
  {
    "args": [
      3
    ],
    "expected": [
      -3,
      123
    ]
  },
  {
    "args": [
      4
    ],
    "expected": [
      -3,
      123
    ]
  }
]
```

## Размер основного варианта

| Источник | Полный, без пробельных | Без сложного Throws | Все символы | Непустые строки |
| --- | ---: | ---: | ---: | ---: |
| LMX | 489 | 489 | 761 | 31 |
| Common Lisp / SBCL | 532 | — | 881 | 19 |

Учитывается полный основной листинг. Тестовый стенд и отдельные реализации ядра в него не входят; их файлы и размеры приведены отдельно.

## LMX

[Исходник](source/lmx/S22.lm3).

```lmx
Resource:
    int: value 42
    int: width 8

Event:
    int: phase
    int: failed
    int: events 0
    run:
        throws: ResourceFailure
        node\events := node\events * 10 + phase
        if: failed
            throw: ResourceFailure(phase)

Work:
    return: int
    use:
        throws: ResourceFailure
        Event\run(1; mode = 2)
        @: resource Resource
        finally:
            Event\run(3; mode = 3 || mode = 4)
        Event\run(2; mode = 1 || mode = 4)
        return: resource\value + resource\width

Example:
    int: mode
    return: @
    run:
        Event\events := 0
        int: result Work\use()
        return: (result; Event\events)
        catch: ResourceFailure (int: phase)
            return: (-phase; Event\events)
```

## Common Lisp / SBCL

[Исходник](source/common-lisp/S22.lisp).

```common-lisp
(define-condition resource-failure (error)
  ((phase :initarg :phase :reader failure-phase)))

(defstruct resource (value 42) (width 8))

(defun example (mode)
  (let ((trace 0))
    (flet ((event (phase fail)
             (setf trace (+ (* trace 10) phase))
             (when fail (error 'resource-failure :phase phase))))
      (let ((result
              (handler-case
                  (let ((resource (progn (event 1 (= mode 2))
                                         (make-resource))))
                    (unwind-protect
                         (progn (event 2 (member mode '(1 4)))
                                (+ (resource-value resource)
                                   (resource-width resource)))
                      (event 3 (member mode '(3 4)))))
                (resource-failure (failure) (- (failure-phase failure))))))
        (list result trace)))))
```

## Почему эти варианты сопоставимы

Как в CL unwind-protect, acquire/action/release выполнены внутри одного полного Work\use; один общий Event меняет trace и порождает конкретный ResourceFailure. mode приходит динамически из Example. Сохранены два поля ресурса, точный порядок, отсутствие release после сбоя acquire и приоритет ошибки release. Ни generic catch, ни посимвольные проверки имени ошибки не добавлены.

Acquire находится до установления cleanup: неуспешное получение ресурса не вызывает release. Поля value и width оба сохранены. Условие release замещает ранее начатый выход по ошибке action.

Как в CL unwind-protect, acquire/action/release выполнены внутри одного полного Work\use; один общий Event меняет trace и порождает конкретный ResourceFailure. mode приходит динамически из Example. Сохранены два поля ресурса, точный порядок, отсутствие release после сбоя acquire и приоритет ошибки release. Ни generic catch, ни посимвольные проверки имени ошибки не добавлены.

Средства Common Lisp/SBCL: `CL:UNWIND-PROTECT`, `CL:HANDLER-CASE`, `CL:DEFSTRUCT`.

## Реализации используемых функций

Основной листинг использует базовые средства языка и полностью приведённые прикладные определения.

Common Lisp-клиент не загружает сравнительные reference-реализации.

## Проверка

SBCL: [фактический отчёт](validation/common_lisp.json). LMX: **NOT_RUN**; структурная проверка текста не доказывает исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/s_unwind.htm>
- <https://www.lispworks.com/documentation/HyperSpec/Body/m_hand_1.htm>
