# Массивные, индексные и матричные профили

Редакция 2026-11-28. [LMX-опись](array_expression_forms.lmx) и
[JSON-проекция](array_expression_forms.json) описывают канонические операции и
профили.

Все структурные применения квадратных скобок идут через общий P0 и
[единый подпарсер](../../spec/BRACKET_SUBPARSER.ru.md). Для индексов, срезов,
вхождения поля, TYPE, VALUE, DATA, голов объявлений и матричных операций
явный [ресивер `` `[]` ``](../../spec/BRACKET_SUBPARSER.ru.md#square-receiver)
использует ключ `60 5B 5D 60`. Каждая пара записей разделяет подготовку и
выбранное тело своего договора.

Обычные арифметика, сравнения и обновления работают поэлементно. `*` и `[*]`
различаются выбором Map и whole матричного профиля. Явные `[op rules]` выбирают
индексный kernel с независимо объявленным reducer. Бинарный `*` может иметь
default суммирования; для `+`, `&`, `^` reducer не угадывается. `[+ 1:]` — сумма,
`[* 1:]` — произведение, `[+ 0:1]` — след. Пустые axisRules дают внешнее
произведение и не совпадают с отсутствующим списком в `[*]`.

**left, depth, right** сохраняют отсутствие actual. `.(depth)` задаёт глубину обхода внешних осей; 0 означает максимум. `.op` не является
сокращением. Структурные вызовы используют базовое имя с формалом depth.
Конфигурация профиля — обычная LMX-структура; методы — обычные ссылки.

`:=` присваивает поэлементно со снимком RHS и проверками до записи.
`target[:] .: values` присваивает срезу с выравниванием справа и транслированием
осей размера 1. Оба используют одно тело snapshot/admission/write с разными
подготовленными картами RHS.

Минимальный `fuse` принимает Scalar/Map со свежим результатом. Неподдержанный
план с редукцией, contraction или streaming store диагностируется. RAW/PLACE/
TYPE/DATA не проходят через eager VALUE. Structure `[]@` не исключается из
Arrays: применимость определяется типами ячеек и конкретным kernel.

[Полная норма и каталог](../../spec/TENSOR_EXPRESSIONS.md),
[depth](../../spec/OPERATOR_DEPTH.ru.md), [подпарсер](../../spec/BRACKET_SUBPARSER.ru.md),
[общие LMX-тела](../../spec/patterns/LMX_Fn_Receivers/src/array_expression_ops.lmx).
[Матричные backend и альтернативы](../matrix/README.ru.md) задают допуск
конкретных C entry, численного профиля, layout, ошибок и владения.
`[**]` с целым показателем использует одно общее `FxMatrixPower\power`;
другие matrix functions этим не реализуются.
Production parser/translator/runtime: **NOT_RUN**.

| Имя | Expression | Профиль | Роли | Общее тело/граница |
| --- | --- | --- | --- | --- |
| `+` | `+` | scalar-map | VALUE | `FxArrayElementwise\apply / FxArrayDepth\apply` |
| `-` | `-` | scalar-map | VALUE | `FxArrayElementwise\apply / FxArrayDepth\apply` |
| `*` | `*` | scalar-map | VALUE | `FxArrayElementwise\apply / FxArrayDepth\apply` |
| `/` | `/` | scalar-map | VALUE | `FxArrayElementwise\apply / FxArrayDepth\apply` |
| `%` | `%` | scalar-map | VALUE | `FxArrayElementwise\apply / FxArrayDepth\apply` |
| `**` | `**` | scalar-map | VALUE | `FxArrayElementwise\apply / FxArrayDepth\apply` |
| `&` | `&` | scalar-map | VALUE | `FxArrayElementwise\apply / FxArrayDepth\apply` |
| `\|` | `\|` | scalar-map | VALUE | `FxArrayElementwise\apply / FxArrayDepth\apply` |
| `^` | `^` | scalar-map | VALUE | `FxArrayElementwise\apply / FxArrayDepth\apply` |
| `~` | `~` | scalar-map | VALUE | `FxArrayElementwise\apply / FxArrayDepth\apply` |
| `!` | `!` | scalar-map | VALUE | `FxArrayElementwise\apply / FxArrayDepth\apply` |
| `<<` | `<<` | scalar-map | VALUE | `FxArrayElementwise\apply / FxArrayDepth\apply` |
| `>>` | `>>` | scalar-map | VALUE | `FxArrayElementwise\apply / FxArrayDepth\apply` |
| `=` | `=` | scalar-map | VALUE | `FxArrayElementwise\apply / FxArrayDepth\apply` |
| `!=` | `!=` | scalar-map | VALUE | `FxArrayElementwise\apply / FxArrayDepth\apply` |
| `<` | `<` | scalar-map | VALUE | `FxArrayElementwise\apply / FxArrayDepth\apply` |
| `<=` | `<=` | scalar-map | VALUE | `FxArrayElementwise\apply / FxArrayDepth\apply` |
| `>` | `>` | scalar-map | VALUE | `FxArrayElementwise\apply / FxArrayDepth\apply` |
| `>=` | `>=` | scalar-map | VALUE | `FxArrayElementwise\apply / FxArrayDepth\apply` |
| `+=` | `+=` | pointwise-update | PLACE, VALUE | `snapshot + base profile + FxArrayAssignPrepared\assign + selected old/new result` |
| `-=` | `-=` | pointwise-update | PLACE, VALUE | `snapshot + base profile + FxArrayAssignPrepared\assign + selected old/new result` |
| `*=` | `*=` | pointwise-update | PLACE, VALUE | `snapshot + base profile + FxArrayAssignPrepared\assign + selected old/new result` |
| `/=` | `/=` | pointwise-update | PLACE, VALUE | `snapshot + base profile + FxArrayAssignPrepared\assign + selected old/new result` |
| `%=` | `%=` | pointwise-update | PLACE, VALUE | `snapshot + base profile + FxArrayAssignPrepared\assign + selected old/new result` |
| `**=` | `**=` | pointwise-update | PLACE, VALUE | `snapshot + base profile + FxArrayAssignPrepared\assign + selected old/new result` |
| `&=` | `&=` | pointwise-update | PLACE, VALUE | `snapshot + base profile + FxArrayAssignPrepared\assign + selected old/new result` |
| `\|=` | `\|=` | pointwise-update | PLACE, VALUE | `snapshot + base profile + FxArrayAssignPrepared\assign + selected old/new result` |
| `^=` | `^=` | pointwise-update | PLACE, VALUE | `snapshot + base profile + FxArrayAssignPrepared\assign + selected old/new result` |
| `<<=` | `<<=` | pointwise-update | PLACE, VALUE | `snapshot + base profile + FxArrayAssignPrepared\assign + selected old/new result` |
| `>>=` | `>>=` | pointwise-update | PLACE, VALUE | `snapshot + base profile + FxArrayAssignPrepared\assign + selected old/new result` |
| `++var` | `++var` | pointwise-update | PLACE, VALUE | `snapshot + base profile + FxArrayAssignPrepared\assign + selected old/new result` |
| `var++` | `var++` | pointwise-update | PLACE, VALUE | `snapshot + base profile + FxArrayAssignPrepared\assign + selected old/new result` |
| `--var` | `--var` | pointwise-update | PLACE, VALUE | `snapshot + base profile + FxArrayAssignPrepared\assign + selected old/new result` |
| `var--` | `var--` | pointwise-update | PLACE, VALUE | `snapshot + base profile + FxArrayAssignPrepared\assign + selected old/new result` |
| `:=` | `:=` | pointwise-assignment | PLACE, VALUE | `FxArrayAssignPrepared\assign` |
| `.:` | `.:` | slice-broadcast-assignment | PLACE, VALUE | `broadcast RHS map -> FxArrayAssignPrepared\assign` |
| `+` | `[+]` | whole-linear-algebra | VALUE | `selected declared whole profile` |
| `-` | `[-]` | whole-linear-algebra | VALUE | `selected declared whole profile` |
| `*` | `[*]` | whole-linear-algebra | VALUE | `FxArrayProduct\multiply -> FxArrayIndexed\apply` |
| `/` | `[/]` | whole-linear-algebra | VALUE | `selected declared whole profile` |
| `\` | `[\]` | whole-linear-algebra | VALUE | `selected declared whole profile` |
| `**` | `[**]` | whole-linear-algebra | VALUE | `FxMatrixPower\power (integer exponent)` |
| `=` | `[=]` | whole-linear-algebra | VALUE | `selected declared whole profile` |
| `!=` | `[!=]` | whole-linear-algebra | VALUE | `selected declared whole profile` |
| `op` | `[op axisRules; options -> outputOrder]` | explicit-indexed-profile | VALUE | `FxArrayIndexed\apply + FxArrayIndexedCell\at` |
| `+` | `[+ 1:]` | unary-sum | VALUE | `ordinary selected index/geometry profile` |
| `*` | `[* 1:]` | unary-product | VALUE | `ordinary selected index/geometry profile` |
| `+` | `[+ 0:1]` | trace-sum | VALUE | `ordinary selected index/geometry profile` |
| `*` | `[* 0=1]` | diagonal-view | VALUE | `ordinary selected index/geometry profile` |
| `*` | `[* -> 1,0]` | permutation-view | VALUE | `ordinary selected index/geometry profile` |
| `fuse` | `fuse` | minimum-scalar-map-fresh-result | RAW | `FxFusePrepared\run` |
| `?:` | `?:` | lazy-conditional | VALUE, RAW, RAW | `existing conditional demand` |
| `slice` | `slice` | signed-strided-slice | VALUE, VALUE | `shared slice normalization` |
