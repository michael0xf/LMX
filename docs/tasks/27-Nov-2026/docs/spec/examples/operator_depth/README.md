# Глубина поэлементного обхода и вход depth

Обычные поэлементные операции обрабатывают элементы на максимальной глубине.
Явный depth=0 тоже означает максимальную глубину; положительное N задаёт
число пройденных внешних логических осей. Это не ранг получаемой ячейки:
у массива rank=K после N осей остаётся ячейка rank=K-N.
Общий обход вызывает выбранное базовое тело на этой ячейке, без повторного
автоматического Map. Скалярное тело не обязано принимать оставшийся Array.

rank остаётся числом осей массива. Сокращения .op и повторные точки удалены.
Общий шаблон — left/depth/right. Отсутствие управляющего actual сохраняется
до выбора профиля и не захватывает одноимённую переменную вызывающего.
[Полный договор](../../OPERATOR_DEPTH.ru.md).
Production parser/translator/LMX runtime: **NOT_RUN**.

<!-- generated-source-blocks:start -->

## Полные листинги

### 001_nested_values.lm3

Плоский Array формы 2×2; depth=0 выбирает скалярные ячейки, сохраняет форму и допускает исходный скаляр 10.

```lmx
Example:
    return: @
    run:
        throws: copy(`+`\throws)
        [2][2]int: rows [1 2; 3 4]
        return: rows + 10
```

### 002_assignment_levels.lm3

Обычный := сохраняет RHS перестановки до записи; последующее присваивание скалярному a меняет одно место.

```lmx
Example:
    return: @
    run:
        throws: copy(`:=`\throws)
        int: a 1
        int: b 2
        int: c 3
        (a b c) := (b c a)
        a := 9
        return: (a b c)
```

### 003_custom_dynamic_depth.lm3

Один операнд получает left/depth/right; явное выражение depth вычисляется один раз, prefix сохраняет отсутствие left.

```lmx
DepthProbe:
    @: left
    int: depth
    []@: right
    const:
        int: PASS_ARGS_AS_IS 0
        int: PRIORITY sys\priority("+")
    return: int
    apply:
        return: depth

DepthSource:
    int: calls 0
    return: int
    get:
        DepthSource\calls += 1
        return: 1 + 9

Example:
    return: @
    run:
        DepthSource\calls := 0
        int: infix 5 .(DepthSource\get())DepthProbe\apply 6
        int: prefix (.(1 + 9)DepthProbe\apply 5 6)
        []@: arguments [6]
        int: receiver DepthProbe\apply(left := 5; depth := 10; right := arguments)
        return: (infix prefix receiver DepthSource\calls)
```

### 004_receiver_depth.lm3

Ресивер + получает именованный depth=0; точное имя не содержит декораций.

```lmx
Example:
    return: @
    run:
        throws: copy(`+`\throws)
        [2][2]int: rows [1 2; 3 4]
        return: `+`(rows; 10; depth := 0)
```

### 005_lazy_depth.lm3

Невостребованные ветви не получают выражение depth и не вызывают эффектов.

```lmx
DepthSource:
    int: calls 0
    return: int
    get:
        DepthSource\calls += 1
        return: 1

Example:
    return: @
    run:
        throws: copy(`+`\throws)
        DepthSource\calls := 0
        int: conjunction 0 && (5 .(DepthSource\get())+ 6)
        int: disjunction 1 || (5 .(DepthSource\get())+ 6)
        int: chosen 1 ? 42 : (5 .(DepthSource\get())+ 6)
        return: (conjunction disjunction chosen DepthSource\calls)
```

<!-- generated-source-blocks:end -->
