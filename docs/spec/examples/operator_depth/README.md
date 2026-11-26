# Глубина операции: короткие полные примеры

Нормативные исходники редакции 26 ноября. [Общий договор](../../OPERATOR_DEPTH.ru.md)
и [грамматика](../../LMX_grammar.ru.md#conditional-slice-grammar) задают
`op` → 0, `.op` → 1, `.(expression)op` → полученный int.
Повторные точки не означают большую глубину; содержимое круглой области после точки
разбирает общий Expression.

Каждый файл загружается обычным запуском корня; для наблюдения затем явно
запрашивается `Example\run`. Имя Example не является точкой старта языка.
Два примера вложенного сложения показывают альтернативные исходники одного
договора: операндный и ресиверный; это не две реализации сложения.

| Файл | Наблюдение после Example\run | Что проверять |
| --- | --- | --- |
| 001_nested_values | `[[11,12],[13,14]]` | Глубина 2, сохранение вложенных границ, скалярный аргумент |
| 002_assignment_levels | `[9,3,1]` | `.:` при 1, `.(0):` при 0, снимок перед перестановкой |
| 003_custom_dynamic_depth | `[10,10,10,1]` | Обычное выражение 1+9, once, prefix без left, явный ABI прямого вызова |
| 004_receiver_depth | `[[11,12],[13,14]]` | Базовое точное имя `+`, обычный named actual depth |
| 005_lazy_depth | `[0,1,42,0]` | Ветви &&, ||, ?: не исполняют свой depth |

`DepthProbe` намеренно возвращает полученный depth и не выполняет подъём
арифметики. Он подтверждает пользовательский ABI: число находится во втором
входе, а right сохраняет аргументы. У префиксного применения первый right
не переносится в отсутствующий left. Структурная форма использует именованные
left/depth/right, поэтому второй пользовательский actual не попадает в depth
по случайному позиционному сдвигу. Вложенные Array обрабатывает общая
реализация базового `+` на выбранной глубине.

Негативные записи и ожидаемая стадия диагностики находятся в [cases.json](cases.json).
Нецелый/отрицательный/многозначный depth и несовместимая структура —
диагностика транслятора, когда это известно статически, либо интерпретатора
при достижении. Это не новые LMX throw-исходы. Неизвестное точное имя `.+`
проходит обычный lookup; оно не переписывается в базовый + с глубиной 1.

**Production P0, трансляция и LMX runtime: NOT_RUN.** Host-проверки
[transport](../../validation/operand_depth_reference_report.json),
[группировщика](../../validation/expression_planner_host_checks_20261126.json)
и [подъёма Arrays](../../tools/array_expression_reference.py) не являются
прогоном этих исходников. [Дополнительный doc_examples](doc_examples/README.md)
сохраняет оба места каждого текста: самостоятельный файл и Markdown ниже.


## Границы без пробелов

В обычном исходном потоке `.(` всегда начинает модификатор оператора либо
функции до чтения точки как части числа. Авторская запись `1 .(3)+ 2 .(2)+ 3`
имеет те же границы в `1.(3)+2.(2)+3`; `1.(2)+3` начинается с числа 1.
`1.5` остаётся десятичным числом. Строки, комментарии и точные идентификаторы
защищены обычным P0. Это нормативные примеры границ, не parser receipts
и не обещание успешного допуска скаляров на выбранной глубине.

<!-- generated-source-blocks:start -->

## Полные листинги

### 001_nested_values.lm3

Две оси вложенности; скаляр 10 используется по договору подъёма без flatten.

```lmx
Example:
    return: @
    run:
        throws: copy(`+`\throws)
        []int: first [1 2]
        []int: second [3 4]
        []@: rows [first second]
        return: rows .(2)+ 10
```

### 002_assignment_levels.lm3

Глубина 1 снимает значения правой перестановки до записи; явная глубина 0 затем меняет только a.

```lmx
Example:
    return: @
    run:
        throws: copy(`:=`\throws)
        int: a 1
        int: b 2
        int: c 3
        (a b c) .: (b c a)
        a .(0): 9
        return: (a b c)
```

### 003_custom_dynamic_depth.lm3

Один пользовательский операнд: infix, отсутствующий left у prefix и прямой вызов с именованными left/depth/right. Вызов вычисления глубины происходит один раз.

```lmx
DepthProbe:
    @: left
    int: depth 0
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

Та же операция + с обычным именованным входом depth; точное имя не содержит декорации.

```lmx
Example:
    return: @
    run:
        throws: copy(`+`\throws)
        []int: first [1 2]
        []int: second [3 4]
        []@: rows [first second]
        return: `+`(rows; 10; depth := 2)
```

### 005_lazy_depth.lm3

Три невостребованные области не вызывают выражение глубины ни разу.

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
