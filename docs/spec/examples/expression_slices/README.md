# Условные выражения и срезы: полные примеры

Эти исходники входят в редакцию 26 ноября 2026. Они описывают новую грамматику и семантику, а не объявляются прошедшими прежний парсер. **Production P0 / translator / LMX runtime: NOT_RUN.** Исполнимый независимый [контрактный эталон](../../tools/ternary_slices_reference.py) и [его проверки](../../validation/ternary_slices_reference_test.py) имеют отдельный результат; он не повышает статус этих `.lm3` файлов до runtime PASS.

| Исходник / вход | Ожидаемый результат |
| --- | --- |
| [001_author_slices.lm3](001_author_slices.lm3) | `([0 2 4 6]; [6 5 4 3 2 1 0]; [4 5 6]; [0 1 2 3 4]; [5 4 3 2])` |
| [002_slice_omission.lm3](002_slice_omission.lm3) | `([6 5 4 3 2 1 0]; []; [6 4 2 0])` |
| [003_lazy_conditional.lm3](003_lazy_conditional.lm3) | 42; `Unselected\fail` не вызывается |
| [004_conditional_receiver.lm3](004_conditional_receiver.lm3) | 42; та же ленивость у `` `?:` `` |
| [005_overlap_reverse.lm3](005_overlap_reverse.lm3) | `[6 5 4 3 2 1 0]`; RHS получен до store |
| [006_group_rotation.lm3](006_group_rotation.lm3) | `(2 3 1)`; Structure — Array свободного типа |
| [007_pointer_neighbor.lm3](007_pointer_neighbor.lm3) | 10; смещение указателя внутри массива |
| [008_nested_conditional.lm3](008_nested_conditional.lm3), `(first; second)` | `(1;0)` → 10; `(0;1)` → 20; `(0;0)` → 30 |
| [009_conditional_bound.lm3](009_conditional_bound.lm3), `flag` | 1 → `[1 3 5]`; 0 → `[2 4]` |
| [010_slice_zero_step.lm3](010_slice_zero_step.lm3) | `SequenceStep`; исходный массив не изменён |

Табличные квадратные группы обозначают ожидаемые значения Array, не новую нетипизированную форму инициализатора в LMX. В источниках массивы объявляются `[]int: nums [...]`. Тернарные ветви остаются RAW до выбора; потенциальные исходы всё равно входят в `throws` метода. Список исходов копируется из выбранного общего семейства, не перечисляется повторно вручную.

Отрицательный скалярный индекс `nums[-1]` не включён в положительные исходники: это недопустимый Array-доступ, проверяемый также при интерпретации L2. Нативное L2 не обязано добавлять bounds-check и от этого не придаёт такому доступу смысл последнего элемента. Пример 007 показывает требуемую указательную операцию вместо отрицательного Array-индекса.

[Нормативное описание](../../TERNARY_AND_SLICES.ru.md), [English contract](../../TERNARY_AND_SLICES.en.md), [общая грамматика](../../LMX_grammar.ru.md#conditional-slice-grammar).

<!-- generated-source-blocks:start -->

## Полные листинги

Блоки ниже синхронизированы с отдельными `.lm3`. [Каталог в формате doc_examples](doc_examples/README.md) сохраняет два места каждого текста и отдельный статус NOT_RUN.

### 001_author_slices.lm3

```lmx
AuthorSlices:
    return: @
    run:
        throws: copy(slice\throws)
        []int: nums [0 1 2 3 4 5 6]
        return: (nums[::2]; nums[::-1]; nums[-3:]; nums[:-2]; nums[5:1:-1])
```

### 002_slice_omission.lm3

```lmx
SliceOmission:
    return: @
    run:
        throws: copy(slice\throws)
        []int: nums [0 1 2 3 4 5 6]
        return: (nums[::-1]; nums[:-1:-1]; nums[100:-100:-2])
```

### 003_lazy_conditional.lm3

```lmx
Unselected:
    return: int
    fail:
        throws: NotChosen
        throw: NotChosen()

LazyConditional:
    return: int
    run:
        throws: copy(Unselected\fail\throws)
        return: 1 ? 42 : Unselected\fail()
```

### 004_conditional_receiver.lm3

```lmx
Unselected:
    return: int
    fail:
        throws: NotChosen
        throw: NotChosen()

ConditionalReceiver:
    return: int
    run:
        throws: copy(Unselected\fail\throws)
        return: `?:`(0; Unselected\fail(); 42)
```

### 005_overlap_reverse.lm3

```lmx
OverlapReverse:
    return: @
    run:
        throws: copy(slice\throws) copy(`:=`\throws)
        []int: nums [0 1 2 3 4 5 6]
        nums[::-1] .: nums
        return: nums
```

### 006_group_rotation.lm3

```lmx
GroupRotation:
    return: @
    run:
        throws: copy(`:=`\throws)
        int: a 1
        int: b 2
        int: c 3
        (a b c) .: (b c a)
        return: (a b c)
```

### 007_pointer_neighbor.lm3

```lmx
PointerNeighbor:
    return: int
    run:
        []int: values [10 20 30]
        L2:
            @int: p @values[1]
            return: \(p - 1)
```

### 008_nested_conditional.lm3

```lmx
NestedConditional:
    int: first
    int: second
    return: int
    run:
        return: first ? 10 : second ? 20 : 30
```

### 009_conditional_bound.lm3

```lmx
ConditionalBound:
    int: flag
    return: @
    run:
        throws: copy(slice\throws)
        []int: nums [0 1 2 3 4 5 6]
        return: nums[flag ? 1 : 2:6:2]
```

### 010_slice_zero_step.lm3

```lmx
ZeroSliceStep:
    return: @
    run:
        throws: copy(slice\throws)
        []int: nums [0 1 2]
        return: nums[::0]
```

<!-- generated-source-blocks:end -->
