# S15. MULTIPLE-VALUE-BIND: план упаковки

Полное сравнение на указанном домене.

## Общий договор

Для целых n >= 0 и capacity > 0 составить план упаковки: вернуть [fullBoxes, remainder, boxesNeeded, unusedPlaces]. fullBoxes и remainder получены целочисленным делением n на capacity; boxesNeeded добавляет одну коробку при ненулевом остатке, unusedPlaces — свободные места в последней неполной коробке, либо 0 при точном делении. При n=0 все четыре результата равны 0. Числа и промежуточные значения помещаются в LMX int.

## Входы и ожидаемые наблюдения

```json
[
  {
    "args": [
      17,
      5
    ],
    "expected": [
      3,
      2,
      4,
      3
    ]
  },
  {
    "args": [
      0,
      7
    ],
    "expected": [
      0,
      0,
      0,
      0
    ]
  },
  {
    "args": [
      12,
      3
    ],
    "expected": [
      4,
      0,
      4,
      0
    ]
  },
  {
    "args": [
      2,
      5
    ],
    "expected": [
      0,
      2,
      1,
      3
    ]
  },
  {
    "args": [
      1,
      1
    ],
    "expected": [
      1,
      0,
      1,
      0
    ]
  }
]
```

## Размер полных вариантов

| Источник | Без пробельных | Все символы | Непустые строки |
| --- | ---: | ---: | ---: |
| LMX — процедурный | 199 | 330 | 13 |
| LMX — функциональный | 163 | 236 | 8 |
| Common Lisp / SBCL | 166 | 209 | 4 |

Оба стиля LMX сравниваются независимо по одному договору. Все объявления, вспомогательные определения и Throws входят в размер. Реализация общих библиотечных операций учитывается отдельно один раз.

## LMX — процедурный

```lmx
Example:
    int: n
    int: capacity
    return: @
    run:
        int: remainder n % capacity
        int: full (n - remainder) / capacity
        int: boxes full
        int: unused 0
        if: remainder != 0
            boxes += 1
            unused := capacity - remainder
        return: (full; remainder; boxes; unused)
```

[Полный исходник](source/lmx/procedural/S15.lm3). 199 непробельных символов; 13 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Example:
    int: n
    int: capacity
    return: @
    run:
        int: remainder n % capacity
        int: full (n - remainder) / capacity
        return: (full; remainder; full + (remainder != 0); (capacity - remainder) % capacity)
```

[Полный исходник](source/lmx/S15.lm3). 163 непробельных символов; 8 непустых строк. Все объявления и Throws включены.

## Common Lisp / SBCL

[Полный исходник](source/common-lisp/S15.lisp).

```common-lisp
(defun example (n capacity)
  (multiple-value-bind (full remainder) (floor n capacity)
    (list full remainder (+ full (if (zerop remainder) 0 1))
          (if (zerop remainder) 0 (- capacity remainder)))))
```

## Соответствие стилей договору

Процедурная форма явно добавляет неполную коробку ветвлением. Функциональная выражает дополнительную коробку и свободные места скалярными выражениями. Обе формы теперь различаются и решают завершённую прикладную задачу.

Lisp связывает два значения FLOOR через MULTIPLE-VALUE-BIND и использует оба при планировании. LMX получает те же составляющие обычными scalar-операциями и возвращает одну структуру результатов; это не объявляется нативным протоколом независимых multiple values. Формула unused не требует произведения boxesNeeded*capacity.

## Общие операции и реализации

Общий договор выражен базовыми средствами языка и приведёнными прикладными определениями.

Common Lisp-клиент использует указанные native/standard средства и не импортирует сравнительные реализации.

## Проверка

Для обновлённого кода **SBCL: NOT_RUN; LMX parser/runtime: NOT_RUN**. Статистика пересчитана по полным исходникам; это не выполнение программ. [Статус и прежний receipt](validation/common_lisp.json).

## Первичные источники

- <https://www.lispworks.com/documentation/HyperSpec/Body/f_floorc.htm>
- <https://www.lispworks.com/documentation/HyperSpec/Body/m_multip.htm>
