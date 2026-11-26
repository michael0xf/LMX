# Выражения Array: плоские оси, inline-значения и fuse

Общие нормы: [Array expressions](../../ARRAY_EXPRESSIONS.ru.md),
[хранение и размерности](../../ARRAY_STORAGE.ru.md),
[depth](../../OPERATOR_DEPTH.ru.md), [fuse](../../FUSION.ru.md).

`int[][]:` задаёт ранг 2 одного плоского хранилища. `[1 2; 3 4]` и
`[[1 2] [3 4]]` — равноправные формы его прямоугольного инициализатора.
На depth=0 обычный `*` выбирает матричное произведение; на depth=1 пары
логических строк дают vector dot; на depth=2 базовый метод получает скаляры.
Обход осей использует дескриптор и смещения, не создавая объектов строк.
Одномерные потребители последовательностей остаются доступными на том же
flat storage без reshape или нового дескриптора rank=1.

Самостоятельное `[items]` в VALUE строит свободно типизированный `@[]`.
`[arr2]` содержит ровно одно целое значение, тот же arr2; singleton flatten
и singleton broadcast не вводятся. Structure в поле — обычное значение,
не отдельная сущность массива массивов. Типизированный многомерный
инициализатор имеет собственный принимающий договор и не меняет это правило.

Ни один `Main` не вводится: вызывается указанная обычная процедура.
Production P0/translator/runtime: **NOT_RUN**. Host-модель проверяет
семантические результаты отдельно; source/README/doc_examples sync проверяет
совпадение текстов, а не исполнение LMX. Списки throws копируются из базовых
канонических методов. Неподходящие shape/depth/fuse диагностируются
транслятором или интерпретатором, не вводя catchable exception.

[LMX-алгоритмы](../../patterns/LMX_Fn_Receivers/src/array_expression_ops.lmx),
[host reference](../../tools/array_expression_reference.py),
[его результат](../../tools/array_expression_reference_results.json).

## Исходники и ожидания

### Матричное произведение и выбранные scalar cells

[Полный исходник](matrix_and_elementwise.lm3).

MatrixExpression получает a shape(2,3)=[1,2,3,4,5,6], b shape(3,2)=[7,8,9,10,11,12], e shape(2,2)=[1,2,3,4]. ElementwiseExpression, напротив, получает три согласованных матрицы ранга 2; SameCoordinates в приведённом ожидании — два вектора. Все аргументы имеют свои полные реальные описания.

- `MatrixExpression\run(a; b; e)`: {"shape": [2, 2], "flat": [59, 66, 142, 158]}.
- `ElementwiseExpression\run(a; b; e)`: "при shape(2,2), a=[1,2,3,4], b=[5,6,7,8], e=[1,1,1,1]: flat [6,13,22,33], один проход".
- `SameCoordinates\run([1 2 3]; [1 8 3])`: [1, 0, 1].

```lmx
# Integration examples. The caller's full Array description supplies shape:
# a: [2,3] = [1 2 3 4 5 6]
# b: [3,2] = [7 8 9 10 11 12]
# e: [2,2] = [1 2 3 4]
# MatrixExpression gives [59 66 142 158] with shape [2,2].
# ElementwiseExpression instead requires all three full shapes to be equal
# and rank two: depth two reaches scalar cells in the retained flat axes.
# Production parser/runtime: NOT_RUN.

MatrixExpression:
    @: a
    @: b
    @: e
    return: @
    run:
        throws: copy(`*`\throws) copy(`+`\throws)
        return: a * b + e

ElementwiseExpression:
    @: a
    @: b
    @: e
    return: @
    run:
        throws: copy(fuse\throws) copy(`*`\throws) copy(`+`\throws)
        return: fuse(a .(2)* b .(2)+ e)

SameCoordinates:
    @: left
    @: right
    return: @
    run:
        throws: copy(`=`\throws)
        return: left .= right
```

### Один проход с реальным назначением и ленивой ветвью

[Полный исходник](fused_update.lm3).

values одномерен; scale=2, bias=1 доступны обычным динамическим связыванием. FusedUpdate сохраняет identity values. В ConditionalFusion получается только выбранная ветвь. Поздний обычный отказ fused-записи может оставить записанный префикс.

- `FusedUpdate\run([1 2 3])`: [3, 5, 7].
- `ConditionalFusion\run([1 2 3]; 1)`: [2, 4, 6].
- `ConditionalFusion\run([1 2 3]; 0)`: [2, 3, 4].

```lmx
# scale and bias are ordinary dynamically bound scalar values. Their actual
# numeric types and contexts are preserved, not fixed here to machine int.
# values is an actual rank-one Array; its real backing is the destination.
# With values=[1 2 3], scale=2, bias=1 the result is [3 5 7].
# Production parser/runtime: NOT_RUN.

FusedUpdate:
    []: values
    return: @
    run:
        throws: copy(fuse\throws) copy(`:=`\throws) copy(`*`\throws) copy(`+`\throws)
        values .: fuse(values .* scale .+ bias)
        return: values

ConditionalFusion:
    []: values
    int: enabled
    return: @
    run:
        throws: copy(fuse\throws) copy(`*`\throws) copy(`+`\throws)
        return: fuse(enabled ? values .* scale : values .+ bias)
```

### Снимок значений перед перестановкой реальных переменных

[Полный исходник](place_rotation.lm3).

Левая группа содержит настоящие PLACE. Все правые значения готовы до первой записи.

- `Rotation\run()`: [2, 3, 1].

```lmx
# The RHS values are captured before the first write to a real left place.
# The returned Structure has values 2,3,1. The same algorithm accepts other
# admitted value types; int only makes this small fixture easy to read.
# Production parser/runtime: NOT_RUN.

Rotation:
    return: @
    run:
        throws: copy(`:=`\throws)
        int: a 1
        int: b 2
        int: c 3
        (a b c) .: (b c a)
        return: (a b c)
```

### Один flat rank2 на глубинах 0, 1 и 2

[Полный исходник](flat_depth.lm3).

Две формы typed initializer создают прямоугольные flat Array. Результат первого * — матрица, второго — вектор row-dot, третьего — координатное умножение. Полный scalar fuse у матриц требует depth=2. Числа int лишь делают эту демонстрацию проверяемой вручную; общие алгоритмы тип не сужают.

- `FlatDepth\run()`: [{"shape": [2, 2], "flat": [19, 22, 43, 50]}, {"shape": [2], "flat": [17, 53]}, {"shape": [2, 2], "flat": [5, 12, 21, 32]}].
- `FlatDepthFusion\run()`: {"shape": [2, 2], "flat": [6, 13, 22, 33], "output_passes": 1, "result_arrays": 1}.

```lmx
FlatDepth:
    return: @
    run:
        throws: copy(`*`\throws)
        int[][]: a [1 2; 3 4]
        int[][]: b [[5 6] [7 8]]
        return: (a * b; a .* b; a .(2)* b)

FlatDepthFusion:
    return: @
    run:
        throws: copy(fuse\throws) copy(`*`\throws) copy(`+`\throws)
        int[][]: a [1 2; 3 4]
        int[][]: b [[5 6] [7 8]]
        return: fuse(a .(2)* b .(2)+ 1)
```

### Inline Array в обычной цепочке; один whole child

[Полный исходник](inline_array_chains.lm3).

InlineChain сохраняет группировку ((a+b)+literal)+d: scalar a+b получается один раз. WholeChildChain имеет внешнюю длину 1; [arr2] содержит сам arr2 и не раскрывается. Удаление ненаблюдаемого промежуточного хранения требует доказанной эквивалентности identity, порядка эффектов и ошибок; переассоциация/FMA не разрешены автоматически.

- `InlineChain\run()`: [17, 27].
- `WholeChildChain\run()`: [[111, 222]].

```lmx
InlineChain:
    return: @
    run:
        throws: copy(`+`\throws)
        int: a 1
        int: b 2
        int: d 4
        return: a + b + [10 20] + d

WholeChildChain:
    return: @
    run:
        throws: copy(`+`\throws)
        @: arr0 [[1 2]]
        @: arr1 [[10 20]]
        @: arr2 [100 200]
        return: arr0 .+ arr1 .+ [arr2]
```

### Отдельный отказ: whole child не означает singleton broadcast

[Полный исходник](negative/inline_singleton_mismatch.lm3).

Первое .+ допустимо, внешняя длина его результата равна 2. Единственный arr2 справа содержится во внешнем Array длины 1; это несовпадение выбранной оси. Группировщик не удаляет оболочку явного конструктора.

- `InlineSingletonMismatch\run()`: {"diagnostic": "translator if known, otherwise interpreter when reached", "catchable_lmx_exception": false}.

```lmx
InlineSingletonMismatch:
    return: @
    run:
        throws: copy(`+`\throws)
        @: arr0 [[1 2] [3 4]]
        @: arr1 [[10 20] [30 40]]
        @: arr2 [100 200]
        return: arr0 .+ arr1 .+ [arr2]
```
