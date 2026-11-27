# Присваивание := и транслирование срезу .:

17 положительных и 6 отрицательных примеров. Обычный :=
присваивает поэлементно с полным снимком RHS и проверкой всех назначений до
записи. Скалярное место @ принимает одно ссылочное значение по своему типу.
Срезовое .: отдельно допускает транслирование RHS: оси выравниваются справа,
каждая длина равна целевой либо 1. Обычный = сравнивает и ничего не записывает.

Depth задаёт глубину обхода: 0 означает максимум, положительное N — N внешних
осей. Пропуск depth сохраняется до выбора профиля. Модификатор — .(depth).
Structure []@ не исключается из Arrays, а допуск проверяет фактические типы.

Минимальный fuse создаёт свежий Scalar/Map результат; dest := fuse(expr)
использует последующее обычное присваивание. Не обещаются streaming store,
частичная запись при отказе внутри fuse или поддержка contraction в fuse.

Нормы: [TENSOR_EXPRESSIONS](../../TENSOR_EXPRESSIONS.md),
[depth](../../OPERATOR_DEPTH.ru.md), [fuse](../../FUSION.ru.md).
Production parser/translator/LMX runtime: **NOT_RUN**.

## Содержание

| Источник | Что проверяет | Статус |
| --- | --- | --- |
| [001_scalar_place.lm3](001_scalar_place.lm3) | Скалярное := меняет одно существующее место | Ожидаемый результат; NOT_RUN |
| [002_reference_rebinding.lm3](002_reference_rebinding.lm3) | Присваивание := перепривязывает переменную-ссылку | Ожидаемый результат; NOT_RUN |
| [003_element_assignment_identity.lm3](003_element_assignment_identity.lm3) | Поэлементное := сохраняет массив назначения и его алиасы | Ожидаемый результат; NOT_RUN |
| [004_place_rotation.lm3](004_place_rotation.lm3) | Перестановка трёх настоящих переменных | Ожидаемый результат; NOT_RUN |
| [005_scalar_fill.lm3](005_scalar_fill.lm3) | Транслирование singleton RHS на срез | Ожидаемый результат; NOT_RUN |
| [006_compound_updates.lm3](006_compound_updates.lm3) | Обычное += обновляет скаляр и элементы массива | Ожидаемый результат; NOT_RUN |
| [007_overlap_shift.lm3](007_overlap_shift.lm3) | Сдвиг вправо с перекрывающимися участками | Ожидаемый результат; NOT_RUN |
| [008_reverse_places.lm3](008_reverse_places.lm3) | Обратный порядок целевых мест и полный снимок источника | Ожидаемый результат; NOT_RUN |
| [009_returned_array.lm3](009_returned_array.lm3) | Элементы возвращённого Array получает потребитель := | Ожидаемый результат; NOT_RUN |
| [010_sibling_groups.lm3](010_sibling_groups.lm3) | Три соседние группы остаются тремя структурными значениями | Ожидаемый результат; NOT_RUN |
| [011_conditional_rhs.lm3](011_conditional_rhs.lm3) | Условная RHS выбирает массив либо скалярное заполнение | Ожидаемый результат; NOT_RUN |
| [012_fused_assignment.lm3](012_fused_assignment.lm3) | Свежий результат fuse и обычное присваивание в исходный массив | Ожидаемый результат; NOT_RUN |
| [013_comparison_is_not_assignment.lm3](013_comparison_is_not_assignment.lm3) | = сравнивает, := меняет значения | Ожидаемый результат; NOT_RUN |
| [017_nested_places.lm3](017_nested_places.lm3) | Запись двух ссылочных элементов и отдельная перепривязка скалярного @ | Ожидаемый результат; NOT_RUN |
| [018_dynamic_depth.lm3](018_dynamic_depth.lm3) | Выражение глубины extra - 1 и скалярный множитель | Ожидаемый результат; NOT_RUN |
| [021_flat_row_places.lm3](021_flat_row_places.lm3) | Строки flat матрицы как регионы PLACE, затем скалярное изменение | Ожидаемый результат; NOT_RUN |
| [022_flat_fused_places.lm3](022_flat_fused_places.lm3) | Свежий fuse-результат для плоской матрицы и запись через := | Ожидаемый результат; NOT_RUN |
| [negative/014_shape_mismatch.lm3](negative/014_shape_mismatch.lm3) | Отказ: число элементов не совпадает; singleton Array не скаляр | Ожидаемый отказ; NOT_RUN |
| [negative/015_admission_before_writes.lm3](negative/015_admission_before_writes.lm3) | Отказ допуска второго элемента до любых записей | Ожидаемый отказ; NOT_RUN |
| [negative/016_fuse_contraction.lm3](negative/016_fuse_contraction.lm3) | Отказ: fuse не превращает свёртку в поэлементное умножение | Ожидаемый отказ; NOT_RUN |
| [negative/019_frame_mismatch.lm3](negative/019_frame_mismatch.lm3) | При depth=1 внешние frames имеют разные размеры | Ожидаемый отказ; NOT_RUN |
| [negative/020_excess_depth.lm3](negative/020_excess_depth.lm3) | Глубина обхода 2 превышает rank=1 входного Array | Ожидаемый отказ; NOT_RUN |
| [negative/023_broadcast_mismatch.lm3](negative/023_broadcast_mismatch.lm3) | Несовместимый broadcast RHS среза | Ожидаемый отказ; NOT_RUN |

## Границы проверки

Ожидания приведены для новой нормативной семантики. Синхронизация исходников,
Markdown и doc_examples не означает выполнение production parser/runtime.
Неподходящие rank/frame/axisRules и неподдержанный fuse — диагностика
транслятора при известных данных или интерпретатора при достижении.
Ошибки выбранных скалярных методов сохраняют обычные throws.

## Полные положительные примеры

### Скалярное := меняет одно существующее место

[Полный исходник](001_scalar_place.lm3); вызов `ScalarPlace\run()`.

Ожидание: `{"value": 42}`.

Права́я часть читает прежнее значение total=36; запись не создаёт новую переменную и возвращает присвоенное значение. Пример возвращает окончательную сумму.

```lmx
ScalarPlace:
    return: int
    run:
        throws: copy(`:=`\throws) copy(`*`\throws) copy(`+`\throws)
        int: price 12
        int: quantity 3
        int: total price * quantity
        total := total + 6
        return: total
```

### Присваивание := перепривязывает переменную-ссылку

[Полный исходник](002_reference_rebinding.lm3); вызов `ReferenceRebinding\run()`.

Ожидание: `{"value": [1, 1, 70, 70]}`.

selected начинает указывать на other. Ссылка original по-прежнему ведёт на source; копирования содержимого двух массивов здесь нет. Четыре наблюдения показывают обе сохранённые идентичности.

```lmx
ReferenceRebinding:
    return: @
    run:
        throws: copy(`:=`\throws) ReceiverIndex
        []int: source [1 2 3]
        []int: other [7 8 9]
        @: selected source
        @: original selected
        selected := other
        selected[0] := 70
        return: (original[0] source[0] other[0] selected[0])
```

### Поэлементное := сохраняет массив назначения и его алиасы

[Полный исходник](003_element_assignment_identity.lm3); вызов `ElementAssignmentIdentity\run()`.

Ожидание: `{"value": [7, 80, 7, 80, 8]}`.

Обычный := копирует значения элементов в существующий Array; прежний alias видит изменения, отдельный other сохраняет свои данные.

```lmx
ElementAssignmentIdentity:
    return: @
    run:
        throws: copy(`:=`\throws) ReceiverIndex
        []int: values [1 2 3]
        []int: other [7 8 9]
        @: alias values
        values := other
        alias[1] := 80
        return: (values[0] values[1] alias[0] alias[1] other[1])
```

### Перестановка трёх настоящих переменных

[Полный исходник](004_place_rotation.lm3); вызов `PlaceRotation\run()`.

Ожидание: `{"value": [2, 3, 1]}`.

Левая группа содержит настоящие PLACE, не копии их значений. Вся RHS удерживается до первой записи, поэтому исходное a=1 не теряется.

```lmx
PlaceRotation:
    return: @
    run:
        throws: copy(`:=`\throws)
        int: a 1
        int: b 2
        int: c 3
        (a b c) := (b c a)
        return: (a b c)
```

### Транслирование singleton RHS на срез

[Полный исходник](005_scalar_fill.lm3); вызов `ScalarFill\run()`.

Ожидание: `{"value": [7, 8, 7]}`.

Срезовое .: транслирует Array длины 1 на длину назначения. Это разрешение принадлежит .:, а обычный := такого broadcasting Array не выполняет.

```lmx
ScalarFill:
    return: @
    run:
        throws: copy(`.:`\throws) copy(slice\throws) copy(`:=`\throws) ReceiverIndex
        []int: values [3 4 5]
        values[:] .: [7]
        values[1] := 8
        return: values
```

### Обычное += обновляет скаляр и элементы массива

[Полный исходник](006_compound_updates.lm3); вызов `CompoundUpdates\run()`.

Ожидание: `{"value": [13, 15, 17]}`.

Обычный += использует общие поэлементное сложение и присваивание, разрешая назначение один раз.

```lmx
CompoundUpdates:
    return: @
    run:
        throws: copy(`+=`\throws)
        int: offset 10
        offset += 2
        []int: values [1 3 5]
        values += offset
        return: values
```

### Сдвиг вправо с перекрывающимися участками

[Полный исходник](007_overlap_shift.lm3); вызов `OverlapShift\run()`.

Ожидание: `{"value": [0, 0, 1, 2, 3]}`.

Левый срез задаёт места записи, правый — источник. Общий снимок всех RHS до stores сохраняет значения перекрывающихся областей.

```lmx
OverlapShift:
    return: @
    run:
        throws: copy(slice\throws) copy(`.:`\throws)
        []int: values [0 1 2 3 4]
        values[1:] .: values[:-1]
        return: values
```

### Обратный порядок целевых мест и полный снимок источника

[Полный исходник](008_reverse_places.lm3); вызов `ReversePlaces\run()`.

Ожидание: `{"value": [4, 3, 2, 1]}`.

Срез .: сохраняет снимок исходного массива перед записью по обратным адресам; shape назначения не меняется.

```lmx
ReversePlaces:
    return: @
    run:
        throws: copy(slice\throws) copy(`.:`\throws)
        []int: values [1 2 3 4]
        values[::-1] .: values
        return: values
```

### Элементы возвращённого Array получает потребитель :=

[Полный исходник](009_returned_array.lm3); вызов `ReturnedArray\run()`.

Ожидание: `{"value": [20, 30, 10]}`.

Функция возвращает одно Array-значение; непосредственные элементы читает договор :=, не группировщик.

```lmx
ValuesProducer:
    return: @
    make:
        []int: values [20 30 10]
        return: values

ReturnedArray:
    return: @
    run:
        throws: copy(`:=`\throws)
        int: a 1
        int: b 2
        int: c 3
        (a b c) := ValuesProducer\make()
        return: (a b c)
```

### Три соседние группы остаются тремя структурными значениями

[Полный исходник](010_sibling_groups.lm3); вызов `SiblingGroups\run()`.

Ожидание: `{"value": [1, 2, 3, 4, 5, 6], "assigned_values": [[1, 2], [3, 4], [5, 6]]}`.

Три целевых поля типа @ принимают три Structure-значения; sibling группы не превращаются в шесть полей.

```lmx
SiblingGroups:
    return: @
    run:
        throws: copy(`:=`\throws) ReceiverIndex
        @: first
        @: second
        @: third
        (first second third) := (1 2) (3 4) (5 6)
        return: (first[0] first[1] second[0] second[1] third[0] third[1])
```

### Условная RHS выбирает массив либо скалярное заполнение

[Полный исходник](011_conditional_rhs.lm3); вызов `ConditionalAssignment\run(chooseFill)`.

Входы: `[{"chooseFill": 0}, {"chooseFill": 1}]`.

Ожидание: `{"inputs": [0, 1], "values": [[7, 8, 9], [5, 5, 5]]}`.

Условие скалярное. Результат выбранной ветви поступает целиком: Array даёт непосредственные элементы, скаляр — заполнение. Неактивная ветвь не вычисляется.

```lmx
ConditionalAssignment:
    int: chooseFill
    return: @
    run:
        throws: copy(`?:`\throws) copy(`:=`\throws)
        []int: values [1 2 3]
        []int: replacement [7 8 9]
        values := (chooseFill ? 5 : replacement)
        return: values
```

### Свежий результат fuse и обычное присваивание в исходный массив

[Полный исходник](012_fused_assignment.lm3); вызов `FusedAssignment\run(values; scale; bias)`.

Входы: `[{"values": [1, 2, 3], "scale": 2, "bias": 1}]`.

Ожидание: `{"value": [3, 5, 7], "target_identity": "preserved", "fuse_final_arrays": 1, "fuse_internal_intermediate_arrays": 0}`.

Минимальный fuse создаёт один свежий финальный Array без внутренних промежуточных Arrays. Обычный := затем получает снимок и проверяет назначение; streaming store и частично записанный префикс здесь не обещаются.

```lmx
FusedAssignment:
    []: values
    @: scale
    @: bias
    return: @
    run:
        throws: copy(fuse\throws) copy(`*`\throws) copy(`+`\throws) copy(`:=`\throws)
        values := fuse(values * scale + bias)
        return: values
```

### = сравнивает, := меняет значения

[Полный исходник](013_comparison_is_not_assignment.lm3); вызов `ComparisonAndAssignment\run()`.

Ожидание: `{"value": [[1, 0, 1], [1, 1, 1]]}`.

Первое сравнение создаёт [1 0 1], не изменяя left. После присваивания новый результат сравнения — [1 1 1]. Два массива сравнения возвращаются двумя целыми значениями и не превращаются в скалярное условие.

```lmx
ComparisonAndAssignment:
    return: @
    run:
        throws: copy(`=`\throws) copy(`:=`\throws)
        []int: left [1 2 3]
        []int: right [1 8 3]
        @: before left = right
        left := right
        @: after left = right
        return: (before; after)
```

### Запись двух ссылочных элементов и отдельная перепривязка скалярного @

[Полный исходник](017_nested_places.lm3); вызов `NestedPlaces\run()`.

Ожидание: `{"value": [[[3, 4], [1, 2]], [3, 4], [1, 2]]}`.

Обычный := меняет два поля внешней Structure. first/second сохраняют ссылки на прежние внутренние Structure; присваивание скалярному полю @ selected меняет только его ссылочное значение. Отдельного примитива массива массивов нет.

```lmx
NestedPlaces:
    return: @
    run:
        throws: copy(`:=`\throws) ReceiverIndex
        []@: values [(1 2) (3 4)]
        @: first values[0]
        @: second values[1]
        values := (second first)
        @: selected first
        selected := second
        return: (values; selected; first)
```

### Выражение глубины extra - 1 и скалярный множитель

[Полный исходник](018_dynamic_depth.lm3); вызов `DynamicDepth\run(extra)`.

Входы: `[{"extra": 1}]`.

Ожидание: `{"value": [[10, 20], [30, 40]], "obtained_depth": 0}`.

extra=1 даёт depth=0 через общее выражение extra-1. depth=0 запускает максимальный Map и обрабатывает скалярные ячейки плоского Array формы 2×2 и сохраняет его форму.

```lmx
DynamicDepth:
    int: extra
    return: @
    run:
        throws: copy(`*`\throws) copy(`-`\throws)
        [2][2]int: rows [1 2; 3 4]
        return: rows .(extra - 1)* 10
```

### Строки flat матрицы как регионы PLACE, затем скалярное изменение

[Полный исходник](021_flat_row_places.lm3); вызов `FlatRowPlaces\run()`.

Ожидание: `{"shape": [2, 2], "flat_values": [13, 14, 11, 12], "returned_references_same_identity": true}`.

Явный прямоугольный RHS меняет порядок строк, затем обычный += добавляет 10 к координатам. Shape 2×2 определена TYPE, values и alias сохраняют один объект.

```lmx
FlatRowPlaces:
    return: @
    run:
        throws: copy(`:=`\throws) copy(`+=`\throws) copy(slice\throws) ReceiverIndex
        [2][2]int: values [1 2; 3 4]
        @: alias values
        [2][2]int: swapped [values[2] values[3]; values[0] values[1]]
        values := swapped
        values += 10
        return: (values; alias)
```

### Свежий fuse-результат для плоской матрицы и запись через :=

[Полный исходник](022_flat_fused_places.lm3); вызов `FlatFusedPlaces\run()`.

Ожидание: `{"shape": [2, 2], "flat_values": [3, 5, 7, 9], "returned_references_same_identity": true, "fuse_final_arrays": 1, "fuse_internal_intermediate_arrays": 0}`.

Обе записи прямоугольного initializer создают плоский Array. Scalar/Map fuse имеет свежий результат; обычный := сохраняет identity назначения и проверяет RHS до записей.

```lmx
FlatFusedPlaces:
    return: @
    run:
        throws: copy(`:=`\throws) copy(fuse\throws) copy(`*`\throws) copy(`+`\throws)
        [2][2]int: values [[1 2] [3 4]]
        @: alias values
        values := fuse(values * 2 + 1)
        return: (values; alias)
```

## Отдельные отрицательные fixtures

### Отказ: число элементов не совпадает; singleton Array не скаляр

[Полный исходник](negative/014_shape_mismatch.lm3); вызов `ShapeMismatch\run(values; useSingleton)`.

Входы: `[{"values": [1, 2, 3], "useSingleton": 0}, {"values": [1, 2, 3], "useSingleton": 1}]`.

Ожидание: `{"diagnostic": "translator if known, otherwise interpreter when reached", "catchable_lmx_exception": false, "target_after_diagnostic": [1, 2, 3]}`.

При входной длине 3 не подходят ни два элемента, ни Array из одного элемента. Во втором случае нельзя применять правило скалярного заполнения. Диагностика возникает до первой записи.

```lmx
ShapeMismatch:
    []: values
    int: useSingleton
    return: @
    run:
        throws: copy(`?:`\throws) copy(`:=`\throws)
        []int: one [9]
        []int: two [7 8]
        values := (useSingleton ? one : two)
        return: values
```

### Отказ допуска второго элемента до любых записей

[Полный исходник](negative/015_admission_before_writes.lm3); вызов `AdmissionBeforeWrites\run(values)`.

Входы: `[{"values": [1, 2, 3], "actual_array_requirement": "[]int"}]`.

Ожидание: `{"failure": "ordinary int target admission", "target_after_failure": [1, 2, 3]}`.

Проверяемый профиль: values — []int длины 3, строка "bad" не допускается его типом и явного конвертера нет. Число элементов верно, но второй элемент не проходит admission. Даже первый элемент назначения остаётся 1.

```lmx
AdmissionBeforeWrites:
    []: values
    return: @
    run:
        throws: copy(`:=`\throws)
        values := (10 "bad" 30)
        return: values
```

### Отказ: fuse не превращает свёртку в поэлементное умножение

[Полный исходник](negative/016_fuse_contraction.lm3); вызов `FuseContraction\run(values; factors)`.

Входы: `[{"values": [1, 2], "factors": [3, 4]}]`.

Ожидание: `{"diagnostic": "ineligible contraction in fuse; translator/interpreter", "catchable_lmx_exception": false, "target_after_diagnostic": [1, 2]}`.

[*] выбирает скалярное произведение векторов. Минимальный Scalar/Map fuse не поддерживает contraction и диагностирует план без запасного eager-пути.

```lmx
FuseContraction:
    []: values
    []: factors
    return: @
    run:
        throws: copy(fuse\throws) copy(`[*]`\throws) copy(`:=`\throws)
        values := fuse(values [*] factors)
        return: values
```

### При depth=1 внешние frames имеют разные размеры

[Полный исходник](negative/019_frame_mismatch.lm3); вызов `FrameMismatch\run()`.

Ожидание: `{"diagnostic": "incompatible frames (2) vs (3)", "catchable_lmx_exception": false}`.

При depth=1 строки обоих Arrays имеют длину 2 и подходят базовому векторному [*], но frames равны (2) и (3). Несовместимые frames не транслируются неявно; ошибка возникает до вызова [*].

```lmx
FrameMismatch:
    return: @
    run:
        throws: copy(`[*]`\throws)
        [2][2]int: a [1 2; 3 4]
        [3][2]int: b [10 20; 30 40; 50 60]
        return: a .(1)[*] b
```

### Глубина обхода 2 превышает rank=1 входного Array

[Полный исходник](negative/020_excess_depth.lm3); вызов `ExcessDepth\run()`.

Ожидание: `{"diagnostic": "depth exceeds the actual Array rank", "catchable_lmx_exception": false}`.

У values одна логическая ось. Стандартный Map не обрезает положительный depth=2 до rank=1: применение диагностируется до базового сложения. Максимальный обход здесь задаётся depth=0 или depth=1. Пользовательский метод без Map сохраняет собственный договор числа.

```lmx
ExcessDepth:
    return: @
    run:
        throws: copy(`+`\throws)
        []int: values [1 2 3]
        return: values .(2)+ 1
```

### Несовместимый broadcast RHS среза

[Полный исходник](negative/023_broadcast_mismatch.lm3); вызов `BroadcastMismatch\run()`.

Ожидание: `{"diagnostic": "slice broadcast shape mismatch", "catchable_lmx_exception": false, "target_shape": [2, 2], "target_flat_after_failure": [1, 2, 3, 4]}`.

Срез имеет четыре места, RHS — три элемента. В .: размер RHS должен совпадать с размером оси либо быть 1; 3 в 4 не транслируется.

```lmx
BroadcastMismatch:
    return: @
    run:
        throws: copy(slice\throws) copy(`.:`\throws)
        [2][2]int: values [1 2; 3 4]
        values[:] .: [7 8 9]
        return: values
```
