# 106. Double Buffer

Синхронное обновление клеточного поля: текущее поколение читается целиком до публикации следующего.

У Nystrom Double Buffer отделяет читаемое текущее состояние от подготавливаемого следующего; обмен выполняется после завершения записи. Здесь этот механизм показан на одномерном двоичном автомате с замкнутым краем. [Описание автора](https://gameprogrammingpatterns.com/double-buffer.html).

## Пара языков

C++ показывает явное владение двумя массивами и обмен их буферов; Go — те же роли через срезы и множественное присваивание. Оба языка подходят для реализации состояния симуляции без скрытого графического API.

## Единый контракт

Вход `cells` — произвольный конечный массив нулей и единиц; `steps` — число поколений. Все размеры и целые аргументы рассматриваются в общем точном диапазоне `int32`; это область сравнения, а не определение ширины `int` в LMX.

Для каждой клетки следующего поколения берётся сумма **двух соседей из предыдущего поколения** по модулю 2. На кольце длины 1 или 2 левый и правый соседи могут совпасть; это два слагаемых, а не множество уникальных соседей. Пустой массив остаётся пустым. Нулевое число шагов возвращает независимую копию входа.

`steps < 0` даёт `InvalidSteps`; затем проверяются все клетки, и любое значение вне `{0,1}` даёт `InvalidCell`, даже при `steps = 0`. Ошибочный шаг имеет приоритет над ошибочной клеткой. Вход не меняется ни при успехе, ни при ошибке. Каждый вызов создаёт своё состояние.

В обоих LMX-вариантах и обоих контрольных языках есть два массива состояния. Во время поколения читается только `current`, пишется только `next`, затем меняются их роли. Функциональный обход может создавать дополнительные массивы индексов `range`; он не обещает ту же суммарную аллокацию, что процедурный цикл. После возврата финальный массив принадлежит результату.

**Контрольное наблюдение.** `[1,0,0,0,0]`, один шаг → `[0,1,0,0,1]`; три шага → `[0,1,1,1,1]`. Для `[1]` один шаг даёт `[0]`. Ошибочные данные не затрагивают исходный массив.

## LMX: общий механизм

Этот файл включается в каждый выбранный вариант ровно один раз. Полный вариант — общая часть и один из двух клиентов ниже; его граница не ограничивается клиентским вызовом.

```lmx
Buffers:
    @: current
    @: next

BufferMake:
    int[]: cells
    int: steps
    return: @
    make:
        throws: InvalidSteps InvalidCell copy(sys\resize\throws)
        if: steps < 0
            throw: InvalidSteps()
        int: i 0
        while: i < length(cells)
            if: cells[i] != 0 && cells[i] != 1
                throw: InvalidCell()
            i += 1
        int[]: current [copy(cells)]
        int[]: next []
        sys\resize(next; length(cells))
        @: state (copy(Buffers))
        state\current := current
        state\next := next
        return: state

Ring:
    Buffers@: state
    int: index
    return: int
    value:
        @: source state\current
        int: left index - 1
        int: right index + 1
        if: left < 0
            left := length(source) - 1
        if: right = length(source)
            right := 0
        return: (source[left] + source[right]) % 2

Publish:
    Buffers@: state
    return: @
    swap:
        (state\current state\next) := state\next state\current
        return: state
```

[Общий исходник](examples/lmx/shared/106_double_buffer.lm3).

## LMX — процедурный

```lmx
Evolve:
    int[]: cells
    int: steps
    return: @
    run:
        throws: copy(BufferMake\make\throws)
        @: state BufferMake\make(cells; steps)
        int: tick 0
        while: tick < steps
            int: i 0
            while: i < length(cells)
                state\next[i] := Ring\value(state; i)
                i += 1
            Publish\swap(state)
            tick += 1
        return: state\current
```

[Процедурный клиент](examples/lmx/procedural/106_double_buffer.lm3) + [общая часть](examples/lmx/shared/106_double_buffer.lm3).

## LMX — функциональный

```lmx
Fill:
    Buffers@: state
    int: index
    return: @
    cell:
        state\next[index] := Ring\value(state; index)
        return: state

Generation:
    Buffers@: state
    int: tick
    return: @
    advance:
        throws: copy(foldl\throws) copy(range\throws)
        foldl(range(0; length(state\current)); state; Fill\cell)
        return: Publish\swap(state)

Evolve:
    int[]: cells
    int: steps
    return: @
    run:
        throws: copy(BufferMake\make\throws) copy(foldl\throws) copy(range\throws)
        @: initial BufferMake\make(cells; steps)
        @: state foldl(range(0; steps); initial; Generation\advance)
        return: state\current
```

[Функциональный клиент](examples/lmx/106_double_buffer.lm3) + [общая часть](examples/lmx/shared/106_double_buffer.lm3).

## Разбор LMX

Общий файл содержит создание двух массивов, правило клетки и обмен ролями. Процедурный вариант явно проходит поколения и индексы. Функциональный вариант выражает оба обхода через уже существующий `foldl`: внутренний аккумулятор — состояние с двумя буферами, внешний — последовательность поколений. `Fill\cell` меняет только целевой буфер; массив индексов, который обходит `foldl`, не меняется.

Здесь «функциональный» обозначает композицию обходов, а не чистоту без эффектов: наблюдаемый контракт паттерна включает публикацию и переиспользование буферов. Замена механизма на новый неизменяемый массив при каждом поколении дала бы другую политику памяти. Эта подмена в сравнение не включена.

Операционный вызов после запуска корня: `Evolve\run([1 0 0 0 0]; 1)`. Обмен `(state\current state\next) := state\next state\current` использует обычное связывание левой группы; новая специальная обработка скобок не вводится.

## C++

```cpp
#include <cstddef>
#include <stdexcept>
#include <vector>

std::vector<int> evolve(const std::vector<int>& cells, int steps) {
    if (steps < 0) throw std::invalid_argument("InvalidSteps");
    for (int cell : cells)
        if (cell != 0 && cell != 1) throw std::invalid_argument("InvalidCell");
    auto current = cells;
    std::vector<int> next(cells.size());
    for (int tick = 0; tick < steps; ++tick) {
        for (std::size_t i = 0; i < cells.size(); ++i) {
            auto left = i == 0 ? cells.size() - 1 : i - 1;
            auto right = i + 1 == cells.size() ? 0 : i + 1;
            next[i] = (current[left] + current[right]) % 2;
        }
        current.swap(next);
    }
    return current;
}
```

[Полный исходник](examples/cpp/106_double_buffer.cpp).

## Go

```go
package main

import "errors"

func evolve(cells []int, steps int) ([]int, error) {
	if steps < 0 {
		return nil, errors.New("InvalidSteps")
	}
	for _, cell := range cells {
		if cell != 0 && cell != 1 {
			return nil, errors.New("InvalidCell")
		}
	}
	current, next := make([]int, len(cells)), make([]int, len(cells))
	copy(current, cells)
	for tick := 0; tick < steps; tick++ {
		for i := range cells {
			left, right := i-1, i+1
			if left < 0 {
				left = len(cells) - 1
			}
			if right == len(cells) {
				right = 0
			}
			next[i] = (current[left] + current[right]) % 2
		}
		current, next = next, current
	}
	return current, nil
}
```

[Полный исходник](examples/go/106_double_buffer.go).

## Сопоставление

Здесь сравнивается реализация самого механизма, а не вызов выдуманного оператора evolve из ядра. C++ `vector::swap`, Go множественное присваивание и LMX групповое присваивание меняют роли двух готовых массивов. Go `copy` и LMX `[copy(cells)]` явно создают независимое исходное состояние. Последовательность обновлений одной клетки не влияет на соседей до следующего поколения.

## Граница и ограничения

Один последовательный владелец состояния. Обмен буферов не объявляется межпоточно атомарным. Нет дисплея, VSync, синхронизации GPU, блокировок, проверки аппаратной производительности или обещания отсутствия разрывов картинки. Код иллюстрирует публикацию поколения, а не графический драйвер.

Вызовы, парсинг тестовых входов, assertions и сериализация результатов находятся в тестовых адаптерах. Они одинаково вынесены за границу сравниваемого механизма. Расходы памяти и системные ошибки выделения ресурсов не сравниваются по переносимому коду ошибки.

## Статистика



## Проверка

[Общие fixtures и ожидаемые результаты](tests/fixture_expectations.json), [исполняемый прогон](tests/validate.py), [отчёт](tests/validation_results.json). Контрольные реализации выполняются на указанных в отчёте версиях инструментов. Для новых LMX-листингов **parser: NOT_RUN; runtime: NOT_RUN**: парсер и runtime LMX в рабочем архиве не предоставлены. Совпадение исходников, Markdown и JSON проверяется отдельно и не объявляется синтаксической проверкой.

## English explanation

A binary ring evolves synchronously from two neighbours of the previous generation. Every call owns two buffers and leaves its input unchanged. Validate negative steps before cell values. Empty and one-/two-cell rings are covered. Ordered folds preserve the mutable two-buffer lifecycle; they are not advertised as allocation-free or pure.



## Источники

- [Robert Nystrom — Double Buffer](https://gameprogrammingpatterns.com/double-buffer.html) — Текущее и следующее состояния, завершение записи перед обменом.
- [Go specification — appending to and copying slices](https://go.dev/ref/spec#Appending_to_and_copying_slices) — Копирование элементов среза вместо алиаса того же backing array.

Норма LMX: [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [правила сравнения](../COMPARISON_RULES.md). Используемые общие операции: [collections.lmx](../LMX_Fn_Receivers/src/collections.lmx), [coreStandardFunctional.lmx](../LMX_Fn_Receivers/src/coreStandardFunctional.lmx), [coreStandardNumeric.lmx](../LMX_Fn_Receivers/src/coreStandardNumeric.lmx), [публикация имён](../LMX_Fn_Receivers/src/public.lmx).

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 904 | 58 |
| LMX — функциональный | 1147 | 66 |
| C++ | 516 | 19 |
| Go | <span style="color:#176233"><u>478</u></span> | 28 |

Для каждой LMX-формы считаются все её source_files, включая общие определения ровно один раз. Все объявления и Throws входят в размер. Зелёным подчёркнут минимум полного сопоставимого листинга; равные минимумы выделены вместе.
