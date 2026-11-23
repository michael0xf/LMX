# V05. Command/read integration check and fault modes

## Общий договор

No current Haskell definition implements all command/read observations, event counts and fault modes of the current integration fixture.

Оба цикла set/observe должны выполняться безусловно, в том числе после неуспешного первого. Замена на короткое замыкание пропустила бы off. Общие mark/cycle и обязательные эффекты сохраняются.

Обоим стилям соответствует одна минимальная форма, необходимая для проверяемого низкоуровневого договора. Её исходник и листинг приведены один раз, значения в обоих столбцах равны. Два разных алгоритма не заявляются.

## LMX — общая минимальная форма обоих стилей

```lmx
Indicator:
    int: command
    int: fault 0
    int: commanded 0
    int: sensed 0
    int: writes 0
    int: reads 0
    int: trace 0
    return: int
    mark:
        node\trace := node\trace * 10 + command
        return: 1
    set:
        node\commanded := command
        node\writes += 1
        mark()
        if: node\fault = 0
            node\sensed := command
        if: node\fault = 1
            node\sensed := 0
        if: node\fault = 2
            node\sensed := 1
        return: 1
    observe:
        node\reads += 1
        mark(2)
        return: node\sensed

Commissioning:
    @: candidate
    int: command
    return: int
    cycle:
        int: ack candidate\set(command := command)
        int: seen candidate\observe()
        return: ack = 1 && seen = command
    check:
        int: on cycle(command := 1)
        int: off cycle(command := 0)
        return: on && off
```

[Полный исходник](../../lmx/V05.lm3)

## Haskell

Сопоставимого существующего листинга для этого договора нет. Новая иностранная реализация не сочиняется; статус остаётся lmx_only.

## Размер полного текста

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | **547** | 39 |
| LMX — функциональный | **547** | 39 |

Обе LMX-записи учитываются целиком, включая объявления, общие локальные helpers и Throws. Ошибки не исключаются из подсчёта. Общая реализация ядра не размножается ради стилей. Существующий статус иностранной пары/аналогии сохранён.

Runtime LMX: NOT_RUN. Это публикация исходников, договоров и полных размеров, не новый parser/runtime receipt.
