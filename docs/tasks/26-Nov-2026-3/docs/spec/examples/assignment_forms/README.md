# Присваивание: `:=`, `.:` и сравнение `.=`

Фикстуры предыдущей редакции: 17 положительных и 6 отрицательных.
Для TypeRef ABI случаи 021, 022 и negative/023 требуют `int[2][2]` вместо `int[][]`:
границы строк не сохраняют оси; готовый вход с заданным TYPE сохраняет его при допуске.
Production P0, translator и LMX runtime — **NOT_RUN**; нового `Main` нет.

`:=` меняет одно существующее место. Если это переменная-ссылка, меняется её
цель, а прежние алиасы продолжают ссылаться на прежний объект. `.:` меняет
элементы выбранного назначения и сохраняет идентичность его Array; в группе
слева находятся реальные переменные или другие допустимые PLACE. `.=` только
сравнивает соответствующие элементы и возвращает Array предикатов.

Для обычного `.:` вся RHS и допуск всех целей готовы до первой записи. Один
возвращённый Array читает сам поэлементный потребитель; несколько соседних
структурных значений остаются несколькими элементами. Скалярное заполнение
не делает Array из одного элемента скаляром. Явное `target .: fuse(expression)`
выбирает отдельный потоковый договор: поздний обычный скалярный отказ сохраняет
записанный префикс.

[Общая глубина](../../OPERATOR_DEPTH.ru.md) передаёт методу числовой `depth`:
`op` имеет depth=0, `.op` — 1, `.(EXPR)op` получает явную глубину через обычное
Expression один раз при востребовании. В ресиверной записи используется
базовое имя и `depth := n`. Присваивание отображается как `:=`, `.:`,
`.(EXPR):`; явное `.(0):` — обычная целая перепривязка настоящего binding PLACE.
Глубина потребляет сохранённые логические оси плоского Array: у ранга 2 depth=1
выбирает регионы строк, depth=2 — скалярные ячейки. Строка не получает отдельного
pointer-slot или объекта графа. Недостающая ось не маскируется распространением
скаляра, достигнутого внутри Array. Обычные Structure в полях сохраняют свою
идентичность; отдельной сущности «массив массивов» нет.

Примеры используют готовые числовые данные для понятных результатов;
операции Array и fused-метод не ограничены `int`. Списки `throws` копируются
из вызываемых базовых канонических методов; точечные имена в кавычках
не декодируются в операцию с глубиной. RAW/PLACE-адаптеры новых форм ещё должны
быть подключены в production согласно [границе реализации](../../FUSION.ru.md#implementation);
эти файлы не объявляют поддельных заглушек вместо ядра.

Нормы: [Array и присваивание](../../ARRAY_EXPRESSIONS.ru.md#assignment),
[срезы](../../TERNARY_AND_SLICES.ru.md), [fuse](../../FUSION.ru.md),
[групповое присваивание](../../LMX_semantics.ru.md#group-assign).
[doc_examples](doc_examples/README.md) содержит дополнительные стабильные ID,
два места каждого текста и SHA-256 в [отчёте](../../validation/assignment_forms_examples_20261126.json).

## Содержание

| Источник | Что проверяет | Статус |
| --- | --- | --- |
| [001_scalar_place.lm3](001_scalar_place.lm3) | Скалярное := меняет одно существующее место | Ожидаемый результат; NOT_RUN |
| [002_reference_rebinding.lm3](002_reference_rebinding.lm3) | Присваивание := перепривязывает переменную-ссылку | Ожидаемый результат; NOT_RUN |
| [003_element_assignment_identity.lm3](003_element_assignment_identity.lm3) | Поэлементное .: сохраняет массив назначения и его алиасы | Ожидаемый результат; NOT_RUN |
| [004_place_rotation.lm3](004_place_rotation.lm3) | Перестановка трёх настоящих переменных | Ожидаемый результат; NOT_RUN |
| [005_scalar_fill.lm3](005_scalar_fill.lm3) | Один скаляр заполняет массив; := затем меняет один элемент | Ожидаемый результат; NOT_RUN |
| [006_compound_updates.lm3](006_compound_updates.lm3) | Обычное += для скаляра и .+= для элементов | Ожидаемый результат; NOT_RUN |
| [007_overlap_shift.lm3](007_overlap_shift.lm3) | Сдвиг вправо с перекрывающимися участками | Ожидаемый результат; NOT_RUN |
| [008_reverse_places.lm3](008_reverse_places.lm3) | Обратный порядок целевых мест и полный снимок источника | Ожидаемый результат; NOT_RUN |
| [009_returned_array.lm3](009_returned_array.lm3) | Один возвращённый Array читает сам потребитель .: | Ожидаемый результат; NOT_RUN |
| [010_sibling_groups.lm3](010_sibling_groups.lm3) | Три соседние группы остаются тремя структурными значениями | Ожидаемый результат; NOT_RUN |
| [011_conditional_rhs.lm3](011_conditional_rhs.lm3) | Условная RHS выбирает массив либо скалярное заполнение | Ожидаемый результат; NOT_RUN |
| [012_fused_assignment.lm3](012_fused_assignment.lm3) | Явное fused-присваивание в тот же массив | Ожидаемый результат; NOT_RUN |
| [013_comparison_is_not_assignment.lm3](013_comparison_is_not_assignment.lm3) | .= сравнивает, .: меняет значения | Ожидаемый результат; NOT_RUN |
| [017_nested_places.lm3](017_nested_places.lm3) | Глубина 2 меняет дочерние места; явная глубина 0 перепривязывает ссылку | Ожидаемый результат; NOT_RUN |
| [018_dynamic_depth.lm3](018_dynamic_depth.lm3) | Обычное выражение глубины и исходный скалярный broadcast | Ожидаемый результат; NOT_RUN |
| [021_flat_row_places.lm3](021_flat_row_places.lm3) | Строки flat матрицы как регионы PLACE, затем скалярное изменение | Ожидаемый результат; NOT_RUN |
| [022_flat_fused_places.lm3](022_flat_fused_places.lm3) | Fused-запись по двум логическим осям плоской матрицы | Ожидаемый результат; NOT_RUN |
| [negative/014_shape_mismatch.lm3](negative/014_shape_mismatch.lm3) | Отказ: число элементов не совпадает; singleton Array не скаляр | Ожидаемый отказ; NOT_RUN |
| [negative/015_admission_before_writes.lm3](negative/015_admission_before_writes.lm3) | Отказ допуска второго элемента до любых записей | Ожидаемый отказ; NOT_RUN |
| [negative/016_fuse_contraction.lm3](negative/016_fuse_contraction.lm3) | Отказ: fuse не превращает свёртку в поэлементное умножение | Ожидаемый отказ; NOT_RUN |
| [negative/019_depth_mismatch.lm3](negative/019_depth_mismatch.lm3) | Диагностика: один из исходных Array не имеет требуемого уровня | Ожидаемый отказ; NOT_RUN |
| [negative/020_excess_depth.lm3](negative/020_excess_depth.lm3) | Диагностика: у одномерного scalar Array нет второй логической оси | Ожидаемый отказ; NOT_RUN |
| [negative/023_scalar_to_row.lm3](negative/023_scalar_to_row.lm3) | Отказ допуска скаляра целому региону строки | Ожидаемый отказ; NOT_RUN |

## Границы проверки

Ниже сохранены прежние ожидания; изменения TypeRef для случаев с осями оговорены выше.
Исполняемая [семантическая модель](../../tools/array_expression_reference.py)
и её [проверки](../../tools/array_expression_reference_results.json) отдельно
проверяют snapshots, alias, admission, shape и fusion. Синхронизация текстов
проверяет лишь совпадение исходников, блоков Markdown и копий doc_examples.

Отрицательные случаи вынесены в `negative/`; они не входят в успешный запуск
положительных примеров. Неподходящие глубина/форма и непригодное выражение fuse
диагностируются транслятором, если уже известны, иначе интерпретатором при
достижении. Это не catchable LMX exceptions и не дополнительные строки throws.
Обычный допуск целевого типа и ошибки самих числовых/обратных методов сохраняют
свой существующий договор. Откат уже выполненных эффектов RHS не обещается.

Поздний арифметический отказ в fused-записи проверен host-моделью с явно
выбранным бросающим scalar provider. Этот раздел не придумывает для всех
числовых типов единое имя или поведение деления на ноль. Production-проверки
RAW/PLACE, времени жизни, объявления `throws` и точных ошибок остаются NOT_RUN.

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
        int[]: source [1 2 3]
        int[]: other [7 8 9]
        @: selected source
        @: original selected
        selected := other
        selected[0] := 70
        return: (original[0] source[0] other[0] selected[0])
```

### Поэлементное .: сохраняет массив назначения и его алиасы

[Полный исходник](003_element_assignment_identity.lm3); вызов `ElementAssignmentIdentity\run()`.

Ожидание: `{"value": [7, 80, 7, 80, 8]}`.

values получает элементы other, но остаётся тем же массивом. Запись через прежний alias видна через values, а отдельный other сохраняет свой элемент 8.

```lmx
ElementAssignmentIdentity:
    return: @
    run:
        throws: copy(`:=`\throws) copy(`:=`\throws) ReceiverIndex
        int[]: values [1 2 3]
        int[]: other [7 8 9]
        @: alias values
        values .: other
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
        (a b c) .: (b c a)
        return: (a b c)
```

### Один скаляр заполняет массив; := затем меняет один элемент

[Полный исходник](005_scalar_fill.lm3); вызов `ScalarFill\run()`.

Ожидание: `{"value": [7, 8, 7]}`.

Скаляр 7 получается один раз как RHS и распространяется на выбранные места. Это не расширение массива из одного элемента: соответствующий отрицательный случай приведён отдельно.

```lmx
ScalarFill:
    return: @
    run:
        throws: copy(`:=`\throws) copy(`:=`\throws) ReceiverIndex
        int[]: values [3 4 5]
        values .: 7
        values[1] := 8
        return: values
```

### Обычное += для скаляра и .+= для элементов

[Полный исходник](006_compound_updates.lm3); вызов `CompoundUpdates\run()`.

Ожидание: `{"value": [13, 15, 17]}`.

offset становится 12. Затем один и тот же скаляр прибавляется к каждому элементу; .+= использует общие поэлементное сложение и присваивание, а место назначения разрешает один раз.

```lmx
CompoundUpdates:
    return: @
    run:
        throws: copy(`+=`\throws) copy(`+=`\throws)
        int: offset 10
        offset += 2
        int[]: values [1 3 5]
        values .+= offset
        return: values
```

### Сдвиг вправо с перекрывающимися участками

[Полный исходник](007_overlap_shift.lm3); вызов `OverlapShift\run()`.

Ожидание: `{"value": [0, 0, 1, 2, 3]}`.

Левый срез — реальные целевые ячейки. Правый срез в VALUE даёт свежую выборку; обычное .: дополнительно соблюдает полный снимок RHS до записей. Размер values остаётся 5.

```lmx
OverlapShift:
    return: @
    run:
        throws: copy(slice\throws) copy(`:=`\throws)
        int[]: values [0 1 2 3 4]
        values[1:] .: values[:-1]
        return: values
```

### Обратный порядок целевых мест и полный снимок источника

[Полный исходник](008_reverse_places.lm3); вызов `ReversePlaces\run()`.

Ожидание: `{"value": [4, 3, 2, 1]}`.

Здесь справа сам исходный массив, а слева выбранные места в обратном порядке. Результат требует удержания всех четырёх исходных значений; последовательная запись без снимка была бы неверна.

```lmx
ReversePlaces:
    return: @
    run:
        throws: copy(slice\throws) copy(`:=`\throws)
        int[]: values [1 2 3 4]
        values[::-1] .: values
        return: values
```

### Один возвращённый Array читает сам потребитель .:

[Полный исходник](009_returned_array.lm3); вызов `ReturnedArray\run()`.

Ожидание: `{"value": [20, 30, 10]}`.

make возвращает одно значение Array. Группировщик не выпускает его элементы в поток; непосредственные элементы единственного RHS Array читает сам .:. Дополнительные copy и скобки не требуются.

```lmx
ValuesProducer:
    return: @
    make:
        int[]: values [20 30 10]
        return: values

ReturnedArray:
    return: @
    run:
        throws: copy(`:=`\throws)
        int: a 1
        int: b 2
        int: c 3
        (a b c) .: ValuesProducer\make()
        return: (a b c)
```

### Три соседние группы остаются тремя структурными значениями

[Полный исходник](010_sibling_groups.lm3); вызов `SiblingGroups\run()`.

Ожидание: `{"value": [1, 2, 3, 4, 5, 6], "assigned_values": [[1, 2], [3, 4], [5, 6]]}`.

Назначений три, RHS содержит три двухэлементные Structure. Они не превращаются в шесть аргументов .:. В конце шесть явных индексных чтений показывают содержимое трёх полученных значений.

```lmx
SiblingGroups:
    return: @
    run:
        throws: copy(`:=`\throws) ReceiverIndex
        @: first
        @: second
        @: third
        (first second third) .: (1 2) (3 4) (5 6)
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
        int[]: values [1 2 3]
        int[]: replacement [7 8 9]
        values .: (chooseFill ? 5 : replacement)
        return: values
```

### Явное fused-присваивание в тот же массив

[Полный исходник](012_fused_assignment.lm3); вызов `FusedAssignment\run(values; scale; bias)`.

Входы: `[{"values": [1, 2, 3], "scale": 2, "bias": 1}]`.

Ожидание: `{"value": [3, 5, 7], "target_identity": "preserved", "output_traversals": 1, "intermediate_result_arrays": 0}`.

values — одномерный Array допустимого полного числового T; scale/bias и операции совместимы с T. Совпадение координат разрешает запись на месте. Это явное исключение из полного снимка обычного `.:`: если скалярная операция или admission позже откажет, уже записанный префикс сохраняется. Числовые ошибки сохраняют обычный договор; непригодная форма fuse диагностируется отдельно и не является новым исключением.

```lmx
FusedAssignment:
    []: values
    @: scale
    @: bias
    return: @
    run:
        throws: copy(fuse\throws) copy(`*`\throws) copy(`+`\throws) copy(`:=`\throws)
        values .: fuse(values .* scale .+ bias)
        return: values
```

### .= сравнивает, .: меняет значения

[Полный исходник](013_comparison_is_not_assignment.lm3); вызов `ComparisonAndAssignment\run()`.

Ожидание: `{"value": [[1, 0, 1], [1, 1, 1]]}`.

Первое сравнение создаёт [1 0 1], не изменяя left. После присваивания новый результат сравнения — [1 1 1]. Два массива сравнения возвращаются двумя целыми значениями и не превращаются в скалярное условие.

```lmx
ComparisonAndAssignment:
    return: @
    run:
        throws: copy(`=`\throws) copy(`:=`\throws)
        int[]: left [1 2 3]
        int[]: right [1 8 3]
        @: before left .= right
        left .: right
        @: after left .= right
        return: (before; after)
```

### Глубина 2 меняет дочерние места; явная глубина 0 перепривязывает ссылку

[Полный исходник](017_nested_places.lm3); вызов `NestedPlaces\run()`.

Ожидание: `{"value": [[[3, 4], [1, 2]], [1, 2], [3, 4]]}`.

Справа удерживаются все четыре исходных числа до любых записей. first/second сохраняют ссылки на прежние обычные Structure, чьи поля обменялись. Затем .(0): меняет только ссылку selected. Внешний @[] содержит две Structure как целые обычные значения; специальный вид массива массивов не вводится. Для плоских размерных данных применяются сохранённые логические оси, показанные отдельно.

```lmx
NestedPlaces:
    return: @
    run:
        throws: copy(`:=`\throws) ReceiverIndex
        @[]: values [(1 2) (3 4)]
        @: first values[0]
        @: second values[1]
        values .(2): (second first)
        @: selected first
        selected .(0): second
        return: (values; selected; first)
```

### Обычное выражение глубины и исходный скалярный broadcast

[Полный исходник](018_dynamic_depth.lm3); вызов `DynamicDepth\run(extra)`.

Входы: `[{"extra": 1}]`.

Ожидание: `{"value": [[10, 20], [30, 40]], "obtained_depth": 2}`.

При extra=1 обычное выражение 1+extra даёт depth=2 один раз. Исходный scalar 10 распространяется при выборе осей обычных Structure в полях. Ресиверная форма: `` `*`(rows; 10; depth := 1 + extra) ``; точечное имя в кавычках не создаётся. Ранг плоского Array задаётся его собственным описанием, а не угадывается по этим полям.

```lmx
DynamicDepth:
    int: extra
    return: @
    run:
        throws: copy(`*`\throws) copy(`+`\throws)
        @[]: rows [(1 2) (3 4)]
        return: rows .(1 + extra)* 10
```

### Строки flat матрицы как регионы PLACE, затем скалярное изменение

[Полный исходник](021_flat_row_places.lm3); вызов `FlatRowPlaces\run()`.

Ожидание: `{"shape": [2, 2], "flat_values": [13, 14, 11, 12], "returned_references_same_identity": true}`.

Обе RHS строки выбираются до записи, после чего .: меняет целые реальные регионы строк. В storage не появляются ссылки на row objects. .(2)+= затем выбирает скалярные клетки. values и alias остаются тем же одним плоским Array. Каждая VALUE-выборка строки — обычный результат slice, а не постоянный writable view.

```lmx
FlatRowPlaces:
    return: @
    run:
        throws: copy(`:=`\throws) copy(`+=`\throws) copy(slice\throws) ReceiverIndex
        int[][]: values [1 2; 3 4]
        @: alias values
        values .: [values[1][:] values[0][:]]
        values .(2)+= 10
        return: (values; alias)
```

### Fused-запись по двум логическим осям плоской матрицы

[Полный исходник](022_flat_fused_places.lm3); вызов `FlatFusedPlaces\run()`.

Ожидание: `{"shape": [2, 2], "flat_values": [3, 5, 7, 9], "returned_references_same_identity": true, "output_traversals": 1, "intermediate_result_arrays": 0}`.

Обе формы typed initializer эквивалентны: [[1 2] [3 4]] и [1 2; 3 4] создают одно плоское хранилище. depth=2 выбран у арифметики и назначения. Адреса строк получаются через описание без их выделения; явный fuse сохраняет потоковый договор поздних обычных ошибок.

```lmx
FlatFusedPlaces:
    return: @
    run:
        throws: copy(`:=`\throws) copy(fuse\throws) copy(`*`\throws) copy(`+`\throws)
        int[][]: values [[1 2] [3 4]]
        @: alias values
        values .(2): fuse(values .(2)* 2 .(2)+ 1)
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
        int[]: one [9]
        int[]: two [7 8]
        values .: (useSingleton ? one : two)
        return: values
```

### Отказ допуска второго элемента до любых записей

[Полный исходник](negative/015_admission_before_writes.lm3); вызов `AdmissionBeforeWrites\run(values)`.

Входы: `[{"values": [1, 2, 3], "actual_array_requirement": "int[]"}]`.

Ожидание: `{"failure": "ordinary int target admission", "target_after_failure": [1, 2, 3]}`.

Проверяемый профиль: values — int[] длины 3, строка "bad" не допускается его типом и явного конвертера нет. Число элементов верно, но второй элемент не проходит admission. Даже первый элемент назначения остаётся 1.

```lmx
AdmissionBeforeWrites:
    []: values
    return: @
    run:
        throws: copy(`:=`\throws)
        values .: (10 "bad" 30)
        return: values
```

### Отказ: fuse не превращает свёртку в поэлементное умножение

[Полный исходник](negative/016_fuse_contraction.lm3); вызов `FuseContraction\run(values; factors)`.

Входы: `[{"values": [1, 2], "factors": [3, 4]}]`.

Ожидание: `{"diagnostic": "ineligible contraction in fuse; translator/interpreter", "catchable_lmx_exception": false, "target_after_diagnostic": [1, 2]}`.

Два линейных массива в обычном * выбирают скалярное произведение. Это непригодная к данному одному поэлементному проходу свёртка, а не запрос .*; отказ не запускает запасной eager-путь и не пишет в values.

```lmx
FuseContraction:
    []: values
    []: factors
    return: @
    run:
        throws: copy(fuse\throws) copy(`*`\throws) copy(`:=`\throws)
        values .: fuse(values * factors)
        return: values
```

### Диагностика: один из исходных Array не имеет требуемого уровня

[Полный исходник](negative/019_depth_mismatch.lm3); вызов `DepthMismatch\run()`.

Ожидание: `{"diagnostic": "incompatible required logical levels", "catchable_lmx_exception": false}`.

После первого потребления flat ранга 1 даёт скаляры, а ещё требуется ось. Это не исходный scalar-аргумент и не разрешённый broadcast. При .(1)* глубина уже исчерпана и базовый * мог бы выбрать масштабирование whole Structure/scalar; здесь запрошены два уровня.

```lmx
DepthMismatch:
    return: @
    run:
        throws: copy(`*`\throws)
        @[]: nested [(1 2) (3 4)]
        int[]: flat [10 20]
        return: nested .(2)* flat
```

### Диагностика: у одномерного scalar Array нет второй логической оси

[Полный исходник](negative/020_excess_depth.lm3); вызов `ExcessDepth\run()`.

Ожидание: `{"diagnostic": "requested depth exceeds available logical axes", "catchable_lmx_exception": false}`.

values объявлен int[] и имеет ранг 1 со скалярными элементами. depth=2 запрашивает отсутствующую ось; исходный scalar 1 её не создаёт. У настоящего int[][] с сохранённым рангом 2 depth=2, напротив, допустим и выбирает клетки.

```lmx
ExcessDepth:
    return: @
    run:
        throws: copy(`+`\throws)
        int[]: values [1 2 3]
        return: values .(2)+ 1
```

### Отказ допуска скаляра целому региону строки

[Полный исходник](negative/023_scalar_to_row.lm3); вызов `ScalarToRow\run()`.

Ожидание: `{"failure": "ordinary whole-region admission; scalar is not a compatible row block", "target_shape": [2, 2], "target_flat_after_failure": [1, 2, 3, 4]}`.

У values ранг 2, поэтому .: выбирает целые строки. В плоском хранилище нет отдельных reference-slots строк, которые можно перепривязать к 9; выбранный договор целого региона требует совместимый блок. Все admission выполняются до stores. Допустимое скалярное заполнение этой матрицы — values .(2): 9. Ошибка обычного admission не переименовывается в новый языковой exception.

```lmx
ScalarToRow:
    return: @
    run:
        throws: copy(`:=`\throws)
        int[][]: values [1 2; 3 4]
        values .: 9
        return: values
```
