# 108. Fixed Timestep Game Loop

Накопитель времени отделяет фиксированные шаги симуляции от границ кадров.

В варианте Game Loop с фиксированным шагом накопленное время расходуется отдельными update, а остаток переносится в следующий кадр. Это механизм из [главы Nystrom](https://github.com/munificent/game-programming-patterns/blob/master/book/game-loop.markdown). Здесь он отделён от часов и воспроизводится на конечном потоке дельт.

## Пара языков

C++ представляет обновление симуляции в движке, JavaScript — обновление между браузерными кадрами. Для воспроизводимого сравнения оба получают готовые временные дельты; платформенный цикл событий и часы остаются за границей примера.

## Единый контракт

Вход: положительный целый `step` и произвольный конечный массив целых `deltas`; единица времени у них одна. Аргументы находятся в общем диапазоне `int32`. `step <= 0` даёт `InvalidStep`. Дельты проверяются слева направо: отрицательная даёт `InvalidElapsed`, а сумма выше `2147483647` — `TimeOverflow`. Весь вход проверяется до первого update; при нескольких ошибках действует указанный порядок.

Начальное состояние: `ticks = position = velocity = lag = 0`. Для кадра к `lag` прибавляется его дельта. Пока остаётся хотя бы `step`, выполняется **отдельный** update: `velocity = (velocity + 1) % 7`, `position = (position + velocity) % 97`, `ticks += 1`, `lag -= step`. Это простая конечная симуляция, а не подстановка заранее вычисленного числа тиков.

После каждого входного кадра возвращается независимый снимок `(ticks, position, velocity, lag)`. Нулевая дельта также даёт снимок. Пустой вход даёт пустой массив. Повторный вызов начинает новое состояние. В LMX служебное поле `step` тоже сохраняется в снимке; наблюдаемая проекция сравнения состоит из четырёх перечисленных полей, и одинаковое `step` доступно всем реализациям как вход.

После каждого кадра `0 <= lag < step` и `ticks * step + lag = сумма пройденных deltas`. Изменение разбиения общего времени на кадры сохраняет финальное состояние симуляции, но закономерно меняет число промежуточных снимков. Ограничение суммы сохраняет точность общих целых и счётчиков; оно не ограничивает пример несколькими заранее известными значениями.

**Контрольное наблюдение.** `step=10`, `deltas=[6,4,25,0,5]` → `(0,0,0,6)`, `(1,1,1,0)`, `(3,6,3,5)`, `(3,6,3,5)`, `(4,10,4,0)`. Один кадр может вызвать ноль, один или несколько update. Ранние снимки не меняются при обработке поздних кадров.

## LMX: общий механизм

Этот файл включается в каждый выбранный вариант ровно один раз. Полный вариант — общая часть и один из двух клиентов ниже; его граница не ограничивается клиентским вызовом.

```lmx
SimulationState:
    int: step
    int: lag 0
    int: ticks 0
    int: position 0
    int: velocity 0

SimulationMake:
    int: step
    int[]: deltas
    return: @
    make:
        throws: InvalidStep InvalidElapsed TimeOverflow
        if: step <= 0
            throw: InvalidStep()
        int: total 0
        int: i 0
        while: i < length(deltas)
            int: elapsed deltas[i]
            if: elapsed < 0
                throw: InvalidElapsed()
            if: elapsed > 2147483647 - total
                throw: TimeOverflow()
            total += elapsed
            i += 1
        @: state (copy(SimulationState))
        state\step := step
        return: state

Tick:
    SimulationState@: state
    return: @
    update:
        state\velocity := (state\velocity + 1) % 7
        state\position := (state\position + state\velocity) % 97
        state\ticks += 1
        state\lag -= state\step
        return: state
```

[Общий исходник](examples/lmx/shared/108_fixed_timestep.lm3).

## LMX — процедурный

```lmx
Frames:
    int: step
    int[]: deltas
    return: @
    run:
        throws: copy(SimulationMake\make\throws) copy(sys\resize\throws)
        @: state SimulationMake\make(step; deltas)
        @[]: output []
        sys\resize(output; length(deltas))
        int: frame 0
        while: frame < length(deltas)
            state\lag += deltas[frame]
            while: state\lag >= step
                Tick\update(state)
            output[frame] := (copy(state))
            frame += 1
        return: output
```

[Процедурный клиент](examples/lmx/procedural/108_fixed_timestep.lm3) + [общая часть](examples/lmx/shared/108_fixed_timestep.lm3).

## LMX — функциональный

```lmx
TickFold:
    SimulationState@: state
    int: index
    return: @
    advance:
        return: Tick\update(state)

Frame:
    SimulationState@: state
    int: elapsed
    return: @
    advance:
        throws: copy(foldl\throws) copy(range\throws)
        @: next (copy(state))
        next\lag += elapsed
        foldl(range(0; next\lag / next\step); next; TickFold\advance)
        return: FxStdPair\make(next; next)

Frames:
    int: step
    int[]: deltas
    return: @
    run:
        throws: copy(SimulationMake\make\throws) copy(mapAccumL\throws)
        @: initial SimulationMake\make(step; deltas)
        @: result mapAccumL(deltas; initial; Frame\advance)
        return: result\second
```

[Функциональный клиент](examples/lmx/108_fixed_timestep.lm3) + [общая часть](examples/lmx/shared/108_fixed_timestep.lm3).

## Разбор LMX

Общая часть задаёт проверку входа и один настоящий `Tick\update`. Процедурный код явно ведёт два цикла и сохраняет копию состояния после кадра. Функциональная форма использует существующие `mapAccumL`, `foldl` и `range`: накопитель переносится между кадрами, а каждый индекс диапазона вызывает тот же `Tick\update` ровно один раз.

`Frame\advance` сначала копирует числовое состояние; поэтому вывод предыдущего кадра не меняется. Его результат `FxStdPair\make(next; next)` — существующая пара `(новый аккумулятор, результат кадра)`, которую ожидает `mapAccumL`; это не новая встроенная функция. Следующий callback снова работает с копией. При положительных целых `next\lag / next\step` задаёт число целых update; результат и порядок переходов сохраняются.

Операционный вызов после запуска корня: `Frames\run(10; [6 4 25 0 5])`. Отдельный `Main` не вводится. Функциональная форма не сокращает шаги до закрытой формулы: формула используется только независимым тестовым оракулом.

## C++

```cpp
#include <cstdint>
#include <stdexcept>
#include <vector>

struct FrameState {
    std::int32_t ticks = 0, position = 0, velocity = 0, lag = 0;
};

std::vector<FrameState> frames(std::int32_t step, const std::vector<std::int32_t>& deltas) {
    if (step <= 0) throw std::invalid_argument("InvalidStep");
    std::int32_t total = 0;
    for (auto elapsed : deltas) {
        if (elapsed < 0) throw std::invalid_argument("InvalidElapsed");
        if (elapsed > 2147483647 - total) throw std::overflow_error("TimeOverflow");
        total += elapsed;
    }
    FrameState state;
    std::vector<FrameState> output;
    for (auto elapsed : deltas) {
        state.lag += elapsed;
        while (state.lag >= step) {
            state.velocity = (state.velocity + 1) % 7;
            state.position = (state.position + state.velocity) % 97;
            ++state.ticks;
            state.lag -= step;
        }
        output.push_back(state);
    }
    return output;
}
```

[Полный исходник](examples/cpp/108_fixed_timestep.cpp).

## JavaScript

```javascript
export function frames(step, deltas) {
    if (step <= 0) throw new RangeError("InvalidStep");
    let total = 0;
    for (const elapsed of deltas) {
        if (elapsed < 0) throw new RangeError("InvalidElapsed");
        if (elapsed > 2147483647 - total) throw new RangeError("TimeOverflow");
        total += elapsed;
    }
    const state = {ticks: 0, position: 0, velocity: 0, lag: 0};
    return deltas.map(elapsed => {
        state.lag += elapsed;
        while (state.lag >= step) {
            state.velocity = (state.velocity + 1) % 7;
            state.position = (state.position + state.velocity) % 97;
            ++state.ticks;
            state.lag -= step;
        }
        return {...state};
    });
}
```

[Полный исходник](examples/javascript/108_fixed_timestep.mjs).

## Сопоставление

Сравнивается аккумулятор фиксированного шага, реальный переход состояния и выдача снимка на каждый кадр. В C++ это явный цикл; JavaScript использует map для кадров и цикл для update; LMX даёт оба стиля. Ни один вариант не заменяет нужные эффекты вычислением общего числа шагов. Проверка по независимой формуле ловит ошибки скорости, позиции, остатка и числа update.

## Граница и ограничения

Это конечный детерминированный фрагмент game loop. Он не получает wall-clock время, не регистрирует requestAnimationFrame, не гарантирует realtime, не реализует sleep, FPS cap, интерполяцию, ввод или рендеринг. Здесь нет ограничения catch-up и потери накопленного времени; добавление такого ограничения потребовало бы другого контракта. При огромном допустимом числе шагов выполнение может быть долгим.

Вызовы, парсинг тестовых входов, assertions и сериализация результатов находятся в тестовых адаптерах. Они одинаково вынесены за границу сравниваемого механизма. Расходы памяти и системные ошибки выделения ресурсов не сравниваются по переносимому коду ошибки.

## Статистика



## Проверка

[Общие fixtures и ожидаемые результаты](tests/fixture_expectations.json), [исполняемый прогон](tests/validate.py), [отчёт](tests/validation_results.json). Контрольные реализации выполняются на указанных в отчёте версиях инструментов. Для новых LMX-листингов **parser: NOT_RUN; runtime: NOT_RUN**: парсер и runtime LMX в рабочем архиве не предоставлены. Совпадение исходников, Markdown и JSON проверяется отдельно и не объявляется синтаксической проверкой.

## English explanation

A finite delta stream feeds a fixed-step accumulator. Each whole step performs a real state transition; each input frame produces an independent snapshot. Preflight rejects invalid time data before updates. Conservation of elapsed time and a closed-form simulation oracle are tested. The example does not implement clock scheduling, rendering, frame pacing, interpolation, or a real-time guarantee.



## Источники

- [Robert Nystrom — Game Loop, original author repository](https://github.com/munificent/game-programming-patterns/blob/master/book/game-loop.markdown) — Накопитель lag, фиксированные update и перенос остатка.
- [ECMAScript — Array.prototype.map](https://tc39.es/ecma262/multipage/indexed-collections.html#sec-array.prototype.map) — Один результат на каждый обработанный элемент массива.

Норма LMX: [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [правила сравнения](../COMPARISON_RULES.md). Используемые общие операции: [collections.lmx](../LMX_Fn_Receivers/src/collections.lmx), [coreStandardFunctional.lmx](../LMX_Fn_Receivers/src/coreStandardFunctional.lmx), [coreStandardNumeric.lmx](../LMX_Fn_Receivers/src/coreStandardNumeric.lmx), [публикация имён](../LMX_Fn_Receivers/src/public.lmx).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 912 | 53 |
| LMX — функциональный | 1090 | 61 |
| C++ | 713 | 28 |
| JavaScript | <span style="color:#176233"><u>501</u></span> | 20 |

Для каждой LMX-формы считаются все её source_files, включая общие определения ровно один раз. Все объявления и Throws входят в размер. Зелёным подчёркнут минимум полного сопоставимого листинга; равные минимумы выделены вместе.
