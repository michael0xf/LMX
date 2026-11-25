# S22. UNWIND-PROTECT: полный жизненный цикл

Полное сравнение на указанном домене.

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

## Размер полных вариантов

| Источник | Без пробельных | Все символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX — процедурный | 489 | 761 | 31 |
| LMX — функциональный | 699 | 1044 | 42 |
| Common Lisp / SBCL | 532 | 881 | 19 |

Оба стиля LMX сравниваются независимо по одному договору. Все объявления, вспомогательные определения и Throws входят в размер. Реализация общих библиотечных операций учитывается отдельно один раз.

## LMX — процедурный

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

[Полный исходник](source/lmx/procedural/S22.lm3). 489 непробельных символов; 31 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Resource:
    int: value 42
    int: width 8

Event:
    int: phase
    int: failed
    int: events 0
    int: failure 0
    run:
        throws: ResourceFailure
        node\events := node\events * 10 + phase
        if: failed
            node\failure := phase
            throw: ResourceFailure(phase)

Acquire:
    return: @
    open:
        throws: copy(Event\run\throws)
        Event\run(1; mode = 2)
        return: Resource

Action:
    @: resource
    return: int
    use:
        throws: copy(Event\run\throws)
        Event\run(2; mode = 1 || mode = 4)
        return: resource\value + resource\width

Release:
    @: resource
    close:
        throws: copy(Event\run\throws)
        Event\run(3; mode = 3 || mode = 4)

Example:
    int: mode
    return: @
    run:
        throws: copy(bracket\throws)
        Event\events := 0
        int: result \(bracket Acquire\open Release\close Action\use)
        return: (result; Event\events)
        catch: FxCallFailure (@: outcome)
            return: (-Event\failure; Event\events)
```

[Полный исходник](source/lmx/S22.lm3). 699 непробельных символов; 42 непустых строк. Все объявления и Throws включены.

## Common Lisp / SBCL

[Полный исходник](source/common-lisp/S22.lisp).

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

## Соответствие стилей договору

Обе записи сохраняют полный договор; процедурная раскрывает прикладной обход, функциональная использует общие операции/Expression без копии ядрового алгоритма.

Acquire находится до установления cleanup: неуспешное получение ресурса не вызывает release. Поля value и width оба сохранены. Условие release замещает ранее начатый выход по ошибке action.

Как в CL unwind-protect, acquire/action/release выполнены внутри одного полного Work\use; один общий Event меняет trace и порождает конкретный ResourceFailure. mode приходит динамически из Example. Сохранены два поля ресурса, точный порядок, отсутствие release после сбоя acquire и приоритет ошибки release. Ни generic catch, ни посимвольные проверки имени ошибки не добавлены.

## Общие операции и реализации

- `bracket`: [тело ядра](../../LMX_Fn_Receivers/src/generic_wrappers.lmx).

Common Lisp-клиент использует указанные native/standard средства и не импортирует сравнительные реализации.

## Проверка

SBCL: [статус и датированный отчёт](validation/common_lisp.json). Оба LMX-варианта: **NOT_RUN**; проверки текста не доказывают исполнение.

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/s_unwind.htm>
- <https://www.lispworks.com/documentation/HyperSpec/Body/m_hand_1.htm>
