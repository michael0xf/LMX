# Обычные, матричные и fused выражения

Обычная арифметика работает поэлементно; [*] выбирает матричное произведение.
Модификатор .(depth) задаёт глубину обхода; 0 означает максимальную. := выполняет обычное поэлементное
присваивание со снимком RHS. Минимальный fuse строит свежий Scalar/Map результат.
[Полная норма](../../TENSOR_EXPRESSIONS.md), [срезы](../../TERNARY_AND_SLICES.ru.md).
Production parser, translator и LMX runtime: **NOT_RUN**.

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
# and rank two; ordinary operators select scalar cells at maximum depth (explicit depth zero).
# Production parser/runtime: NOT_RUN.

MatrixExpression:
    @: a
    @: b
    @: e
    return: @
    run:
        throws: copy(`[*]`\throws) copy(`+`\throws)
        return: a [*] b + e

ElementwiseExpression:
    @: a
    @: b
    @: e
    return: @
    run:
        throws: copy(fuse\throws) copy(`*`\throws) copy(`+`\throws)
        return: fuse(a * b + e)

SameCoordinates:
    @: left
    @: right
    return: @
    run:
        throws: copy(`=`\throws)
        return: left = right
```

### Свежий Scalar/Map результат, последующее присваивание и ленивая ветвь

[Полный исходник](fused_update.lm3).

Для всех трёх вызовов динамический контекст задаёт scale=2 и bias=1. fuse создаёт свежий результат без промежуточных Arrays внутри Scalar/Map плана; затем обычный := проверяет весь RHS до записи. При отказе построения результата назначение не меняется. ConditionalFusion получает только выбранную ветвь.

- `FusedUpdate\run([1 2 3])`: [3, 5, 7].
- `ConditionalFusion\run([1 2 3]; 1)`: [2, 4, 6].
- `ConditionalFusion\run([1 2 3]; 0)`: [2, 3, 4].

```lmx
# scale and bias are ordinary dynamically bound scalar values. Their actual
# numeric types and contexts are preserved, not fixed here to machine int.
# fuse creates a fresh result; ordinary := then snapshots/admit/writes values.
# With values=[1 2 3], scale=2, bias=1 the result is [3 5 7].
# Production parser/runtime: NOT_RUN.

FusedUpdate:
    []: values
    return: @
    run:
        throws: copy(fuse\throws) copy(`:=`\throws) copy(`*`\throws) copy(`+`\throws)
        values := fuse(values * scale + bias)
        return: values

ConditionalFusion:
    []: values
    int: enabled
    return: @
    run:
        throws: copy(fuse\throws) copy(`*`\throws) copy(`+`\throws)
        return: fuse(enabled ? values * scale : values + bias)
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
        (a b c) := (b c a)
        return: (a b c)
```

### Целая матрица, обход строк depth=1 и максимальный поэлементный обход

[Полный исходник](flat_depth.lm3).

Array формы 2×2 задан левым TYPE. [*] даёт матричное произведение, .(1)[*] — по одному скалярному произведению строк, обычный * — координатное умножение. Минимальный fuse поддерживает последнее с последующим Map.

- `FlatDepth\run()`: [{"shape": [2, 2], "flat": [19, 22, 43, 50]}, {"shape": [2], "flat": [17, 53]}, {"shape": [2, 2], "flat": [5, 12, 21, 32]}].
- `FlatDepthFusion\run()`: {"shape": [2, 2], "flat": [6, 13, 22, 33], "output_passes": 1, "result_arrays": 1}.

```lmx
FlatDepth:
    return: @
    run:
        throws: copy(`[*]`\throws) copy(`*`\throws)
        [2][2]int: a [1 2; 3 4]
        [2][2]int: b [[5 6] [7 8]]
        return: (a [*] b; a .(1)[*] b; a * b)

FlatDepthFusion:
    return: @
    run:
        throws: copy(fuse\throws) copy(`*`\throws) copy(`+`\throws)
        [2][2]int: a [1 2; 3 4]
        [2][2]int: b [[5 6] [7 8]]
        return: fuse(a * b + 1)
```

### Inline Array в числовой цепочке и typed initializer в матричной цепочке

[Полный исходник](inline_array_chains.lm3).

InlineChain сохраняет скалярный a+b и порядок цепочки. InlineMatrixChain складывает три плоские матрицы формы 1×2 посредством whole [+]; последний actual создаётся inline TYPE-конструктором. Вложенный Array не передаётся скалярному + в надежде на повторный автоматический Map. Нет автоматической переассоциации или FMA.

- `InlineChain\run()`: [17, 27].
- `InlineMatrixChain\run()`: {"shape": [1, 2], "flat": [111, 222]}.

```lmx
InlineChain:
    return: @
    run:
        throws: copy(`+`\throws)
        int: a 1
        int: b 2
        int: d 4
        return: a + b + [10 20] + d

InlineMatrixChain:
    return: @
    run:
        throws: copy(`[+]`\throws)
        [1][2]int: arr0 [1 2]
        [1][2]int: arr1 [10 20]
        return: arr0 [+] arr1 [+] ([1][2]int: [100 200])
```

### Отдельный отказ: whole child не означает singleton broadcast

[Полный исходник](negative/inline_singleton_mismatch.lm3).

Первое сложение двух числовых векторов даёт [11 22]. Затем внешний Array длины 2 не согласуется с [arr2] длины 1: ordinary + требует равные frames. [arr2] остаётся контейнером из одной ссылки на целый arr2, не становится скаляром и не включает broadcasting.

- `InlineSingletonMismatch\run()`: {"diagnostic": "translator if known, otherwise interpreter when reached", "catchable_lmx_exception": false}.

```lmx
InlineSingletonMismatch:
    return: @
    run:
        throws: copy(`+`\throws)
        @: arr0 [1 2]
        @: arr1 [10 20]
        @: arr2 [100 200]
        return: arr0 + arr1 + [arr2]
```

### Целая степень, отрицательный показатель и пустая матрица

[Полный исходник](integer_matrix_power.lm3).

Публичный [**] использует один FxMatrixPower\power в ../../patterns/LMX_Fn_Receivers/src/array_expression_ops.lmx после общего square/type/exponent admission. Нулевая степень создаёт identity без проверки обратимости; первая возвращает fresh VALUE. Отрицательная степень выполняет одно решение A X = I и тот же binary order; signed q/2 и q%2!=0 не вычисляют -MIN_INT. Нет лишнего I*A или последнего неиспользуемого квадрата. MinimumIntegerMatrixPower получает минимальный int от target harness; число бит не зафиксировано. Эти ожидания не являются отчётом о запуске LMX.

- `MatrixPowerValues\run()`: [{"shape": [2, 2], "flat": [1, 0, 0, 1], "fresh_value": true}, {"shape": [2, 2], "flat": [2, 1, 0, 3], "fresh_value": true}, {"shape": [2, 2], "flat": [4, 5, 0, 9], "fresh_value": true}, {"shape": [2, 2], "flat": [8, 19, 0, 27], "fresh_value": true}, {"shape": [2, 2], "flat": [32, 211, 0, 243], "fresh_value": true}].
- `NegativeMatrixPowers\run()`: [{"shape": [2, 2], "flat": [0.5, 0, 0, 0.25]}, {"shape": [2, 2], "flat": [0.125, 0, 0, 0.015625]}].
- `MinimumIntegerMatrixPower\run(exponent)`: {"input": "exponent is target machine int minimum", "shape": [2, 2], "flat": [1, 0, 0, 1], "negates_exponent": false}.
- `EmptyMatrixPower\run()`: [{"shape": [0, 0], "flat": [], "fresh_value": true}, {"shape": [0, 0], "flat": [], "fresh_value": true}, {"shape": [0, 0], "flat": [], "fresh_value": true}].

```lmx
# Whole integer powers use one shared binary order and preserve the input.
# The production LMX parser, translator and runtime have not executed this file.
# MatrixPowerValues returns I, A, A^2, A^3 and A^5, each as a fresh VALUE.
MatrixPowerValues:
    return: @
    run:
        throws: copy(`[**]`\throws)
        [2][2]int: a [2 1; 0 3]
        return: (a [**] 0; a [**] 1; a [**] 2; a [**] 3; a [**] 5)

# A negative exponent uses one solve against identity before binary powers.
# The admitted machine-double profile returns exact binary fractions here.
NegativeMatrixPowers:
    return: @
    run:
        throws: copy(`[**]`\throws)
        [2][2]double: a [2 0; 0 4]
        return: (a [**] (-1); a [**] (-3))

# The harness supplies the target int minimum; no hard-coded width or negation.
# Identity stays identity for every admitted exponent, including MIN_INT.
MinimumIntegerMatrixPower:
    int: exponent
    return: @
    run:
        throws: copy(`[**]`\throws)
        [2][2]double: a [1 0; 0 1]
        return: a [**] exponent

# Complete empty shape is supplied by TYPE, not inferred from absent elements.
EmptyMatrixPower:
    return: @
    run:
        throws: copy(`[**]`\throws)
        [0][0]double: a []
        return: (a [**] 0; a [**] 1; a [**] (-1))
```

### Общие bridge-модели: reverse view, complex и sparse

[Полный исходник](matrix_bridge_models.lm3).

Обычные Structures из ../../../core_catalog/types/common_models.lmx описывают данные; сами конструкторы не выполняют native admission или pack. Tensor.strides имеет signed i64 element units. ComplexBuffer planar удаляет ведущую ось компонентов длины2; SparseMatrix CSR имеет zero-based indices и explicit nnz. Адаптер проверяет source-view bounds, actual type, owner, native widths, aliasing и duplicate policy. Нет hidden handles/TypeRef или нового парсера. Production runtime NOT_RUN.

- `ReverseMatrixView\make()`: {"model": "BridgeData\\Tensor", "shape": [2, 3], "strides": [3, -1], "offset": 2, "logical_flat": [3, 2, 1, 6, 5, 4], "reachable_range": [0, 5], "native_admission": "REQUIRE_IMPLEMENTATION"}.
- `PlanarComplexVector\make()`: {"model": "BridgeData\\ComplexBuffer", "layout": "planar", "profile": "double", "component_shape": [2, 3], "logical_shape": [3], "real": [1, 2, 3], "imaginary": [10, 20, 30]}.
- `SparseMatrixData\make()`: {"model": "BridgeData\\SparseMatrix", "format": "csr", "shape": [2, 3], "nnz": 3, "values": [10, 20, 30], "indices": [0, 2, 1], "pointers": [0, 2, 3], "dense_allocation": false}.

```lmx
# Ordinary DATA construction examples using core_catalog/types/common_models.lmx.
# These methods construct descriptions; they do not claim native admission,
# numerical conversion, backend calls or a production runtime test.
# The Array references retain actual storage; no C pointers or handles appear.
ReverseMatrixView:
    return: @
    make:
        [6]double: values [1 2 3 4 5 6]
        private: @: view (copy(BridgeData\Tensor))
        view\array := values
        view\shape := ([]size_t: [2 3])
        view\strides := ([]i64: [3 (-1)])
        view\offset := 2
        view\layout := "strided"
        return: view

# Components are two contiguous planes: real=[1,2,3], imaginary=[10,20,30].
# The logical complex shape is (3); the component Tensor has shape (2,3).
PlanarComplexVector:
    return: @
    make:
        [2][3]double: values [1 2 3; 10 20 30]
        private: @: view (copy(BridgeData\Tensor))
        view\array := values
        view\shape := ([]size_t: [2 3])
        view\strides := ([]i64: [3 1])
        view\offset := 0
        view\layout := "row-major"
        private: @: result (copy(BridgeData\ComplexBuffer))
        result\components := view
        result\layout := "planar"
        result\profile := "double"
        return: result

# CSR represents rows [10,0,20] and [0,30,0]; no dense array is allocated.
# Indices are zero-based, nnz=3, outer pointers=[0,2,3].
SparseMatrixData:
    return: @
    make:
        [3]double: values [10 20 30]
        private: @: entries (copy(BridgeData\Buffer))
        entries\array := values
        entries\offset := 0
        entries\count := 3
        entries\writable := 0
        private: @: result (copy(BridgeData\SparseMatrix))
        result\format := "csr"
        result\shape := ([2]size_t: [2 3])
        result\values := entries
        result\indices := ([]size_t: [0 2 1])
        result\pointers := ([]size_t: [0 2 3])
        return: result
```
