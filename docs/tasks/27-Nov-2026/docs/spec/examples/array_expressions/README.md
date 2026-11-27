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
