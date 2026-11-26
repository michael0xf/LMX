# Массивные операции, условие, срезы и fuse

Редакция 2026-11-26. [LMX-опись](array_expression_forms.lmx) и
[JSON-проекция](array_expression_forms.json) перечисляют договоры дополнения.
Это описания публикации, а не повторный runtime-диспетчер.
Исходный каталог 215 имён / 227 вариантов сохранён как исходная опись.
Новые профили не маскируются под уже проверенные экспорты компилятора.

Для каждого имени обе формы используют один обработчик. RAW-выражение
fuse/условия и PLACE назначения нельзя пропускать через eager VALUE-адаптер.
Унарная/бинарная форма точечных знаков выбирается обычным договором арности.
Обычный `*` использует целый матричный/векторный профиль. `.*` имеет
глубину 1 по логическим измерениям; скалярные координаты rank-2 массива
получаются через `.(2)*`. Промежуточные структуры строк не создаются.
`.=` сравнивает, `.:` присваивает элементам. `:=` присваивает целому месту
на глубине 0; `.(выражение):` задаёт глубину явно. Поэтому перестановка
элементов записывается `(a b c) .: (b c a)`.

[Общий depth](../../spec/OPERATOR_DEPTH.ru.md) — второй вход между left и right.
Форма без точки передаёт 0, одна точка — 1, `.(выражение)` — явно вычисленную
глубину. Внутри круглых скобок работает общий парсер. `.(` всегда начинает модификатор, не десятичную точку. Базовое имя
ресивера остаётся без точек; используется именованный depth. Таблица
ниже показывает профили и примеры поверхностной записи, не новые
вызываемые имена. Неопределимая/недопустимая глубина, несовместимая
структура и непригодный fuse — диагностика транслятора/интерпретатора,
без новых пользовательских исключений.

[LMX-тела](../../spec/patterns/LMX_Fn_Receivers/src/array_expression_ops.lmx)
содержат реальные общие циклы, включая внутреннюю свёртку матричного
произведения. [Подключение](../../spec/FUSION.ru.md#implementation)
сохраняет существующий граф и namespace; подготовка формы/RAW/PLACE и
провайдеры скалярных операций остаются явно указанными точками интеграции.
Production parser, translator и runtime: **NOT_RUN**.

| Базовое имя | Пример формы | Семейство | Роли | Единое тело/алгоритм | Состояние исходника |
| --- | --- | --- | --- | --- | --- |
| `+` | `+` | ordinary-array-profile | VALUE | `FxArrayElementwise\apply` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `-` | `-` | ordinary-array-profile | VALUE | `FxArrayElementwise\apply` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `*` | `*` | ordinary-array-profile | VALUE | `FxArrayProduct\multiply / FxArrayElementwise\apply` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `/` | `/` | ordinary-array-profile | VALUE | `FxArrayElementwise\apply` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `%` | `%` | ordinary-array-profile | VALUE | `FxArrayElementwise\apply` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `**` | `**` | ordinary-array-profile | VALUE | `selected-algebraic-power-profile (no new default body)` | SELECTED_PROFILE_CONTRACT_ONLY |
| `&` | `&` | ordinary-array-profile | VALUE | `FxArrayElementwise\apply` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `\|` | `\|` | ordinary-array-profile | VALUE | `FxArrayElementwise\apply` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `^` | `^` | ordinary-array-profile | VALUE | `FxArrayElementwise\apply` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `~` | `~` | ordinary-array-profile | VALUE | `FxArrayElementwise\apply` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `<<` | `<<` | ordinary-array-profile | VALUE | `FxArrayElementwise\apply` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `>>` | `>>` | ordinary-array-profile | VALUE | `FxArrayElementwise\apply` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `+` | `.+` | component-value | VALUE | `FxArrayDepth\apply + selected base operation` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `-` | `.-` | component-value | VALUE | `FxArrayDepth\apply + selected base operation` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `*` | `.*` | component-value | VALUE | `FxArrayDepth\apply + selected base operation` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `/` | `./` | component-value | VALUE | `FxArrayDepth\apply + selected base operation` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `%` | `.%` | component-value | VALUE | `FxArrayDepth\apply + selected base operation` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `**` | `.**` | component-value | VALUE | `FxArrayDepth\apply + selected base operation` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `&` | `.&` | component-value | VALUE | `FxArrayDepth\apply + selected base operation` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `\|` | `.\|` | component-value | VALUE | `FxArrayDepth\apply + selected base operation` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `^` | `.^` | component-value | VALUE | `FxArrayDepth\apply + selected base operation` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `~` | `.~` | component-value | VALUE | `FxArrayDepth\apply + selected base operation` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `<<` | `.<<` | component-value | VALUE | `FxArrayDepth\apply + selected base operation` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `>>` | `.>>` | component-value | VALUE | `FxArrayDepth\apply + selected base operation` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `=` | `.=` | component-value | VALUE | `FxArrayDepth\apply + selected base operation` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `!=` | `.!=` | component-value | VALUE | `FxArrayDepth\apply + selected base operation` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `<` | `.<` | component-value | VALUE | `FxArrayDepth\apply + selected base operation` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `<=` | `.<=` | component-value | VALUE | `FxArrayDepth\apply + selected base operation` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `>` | `.>` | component-value | VALUE | `FxArrayDepth\apply + selected base operation` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `>=` | `.>=` | component-value | VALUE | `FxArrayDepth\apply + selected base operation` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `+=` | `.+=` | component-update | PLACE, VALUE | `shared-update preparation -> FxArrayDepth\apply -> FxArrayDepthAssignPrepared\assign` | COMPOSED_LMX_BODIES_WITH_PREPARATION_BOUNDARY |
| `-=` | `.-=` | component-update | PLACE, VALUE | `shared-update preparation -> FxArrayDepth\apply -> FxArrayDepthAssignPrepared\assign` | COMPOSED_LMX_BODIES_WITH_PREPARATION_BOUNDARY |
| `*=` | `.*=` | component-update | PLACE, VALUE | `shared-update preparation -> FxArrayDepth\apply -> FxArrayDepthAssignPrepared\assign` | COMPOSED_LMX_BODIES_WITH_PREPARATION_BOUNDARY |
| `/=` | `./=` | component-update | PLACE, VALUE | `shared-update preparation -> FxArrayDepth\apply -> FxArrayDepthAssignPrepared\assign` | COMPOSED_LMX_BODIES_WITH_PREPARATION_BOUNDARY |
| `%=` | `.%=` | component-update | PLACE, VALUE | `shared-update preparation -> FxArrayDepth\apply -> FxArrayDepthAssignPrepared\assign` | COMPOSED_LMX_BODIES_WITH_PREPARATION_BOUNDARY |
| `**=` | `.**=` | component-update | PLACE, VALUE | `shared-update preparation -> FxArrayDepth\apply -> FxArrayDepthAssignPrepared\assign` | COMPOSED_LMX_BODIES_WITH_PREPARATION_BOUNDARY |
| `&=` | `.&=` | component-update | PLACE, VALUE | `shared-update preparation -> FxArrayDepth\apply -> FxArrayDepthAssignPrepared\assign` | COMPOSED_LMX_BODIES_WITH_PREPARATION_BOUNDARY |
| `\|=` | `.\|=` | component-update | PLACE, VALUE | `shared-update preparation -> FxArrayDepth\apply -> FxArrayDepthAssignPrepared\assign` | COMPOSED_LMX_BODIES_WITH_PREPARATION_BOUNDARY |
| `^=` | `.^=` | component-update | PLACE, VALUE | `shared-update preparation -> FxArrayDepth\apply -> FxArrayDepthAssignPrepared\assign` | COMPOSED_LMX_BODIES_WITH_PREPARATION_BOUNDARY |
| `<<=` | `.<<=` | component-update | PLACE, VALUE | `shared-update preparation -> FxArrayDepth\apply -> FxArrayDepthAssignPrepared\assign` | COMPOSED_LMX_BODIES_WITH_PREPARATION_BOUNDARY |
| `>>=` | `.>>=` | component-update | PLACE, VALUE | `shared-update preparation -> FxArrayDepth\apply -> FxArrayDepthAssignPrepared\assign` | COMPOSED_LMX_BODIES_WITH_PREPARATION_BOUNDARY |
| `++var` | `.++var` | attached-component-update | PLACE | `old-value capture + FxArrayDepth\apply(selected unit/update) + FxArrayDepthAssignPrepared\assign + old/new result` | COMPOSED_LMX_BODIES_WITH_PREPARATION_BOUNDARY |
| `var++` | `var.++` | attached-component-update | PLACE | `old-value capture + FxArrayDepth\apply(selected unit/update) + FxArrayDepthAssignPrepared\assign + old/new result` | COMPOSED_LMX_BODIES_WITH_PREPARATION_BOUNDARY |
| `--var` | `.--var` | attached-component-update | PLACE | `old-value capture + FxArrayDepth\apply(selected unit/update) + FxArrayDepthAssignPrepared\assign + old/new result` | COMPOSED_LMX_BODIES_WITH_PREPARATION_BOUNDARY |
| `var--` | `var.--` | attached-component-update | PLACE | `old-value capture + FxArrayDepth\apply(selected unit/update) + FxArrayDepthAssignPrepared\assign + old/new result` | COMPOSED_LMX_BODIES_WITH_PREPARATION_BOUNDARY |
| `:=` | `.:` | component-assignment | PLACE, VALUE | `FxArrayDepthAssignPrepared\assign -> shared FxArrayAssignPrepared\assign` | LMX_LOOP_BODY_WITH_PREPARATION_BOUNDARY |
| `fuse` | `fuse` | one-loop-expression | RAW | `FxFusePrepared\run` | LMX_LOOP_BODY_RAW_PREPARATION_REQUIRED |
| `?:` | `?:` | lazy-conditional | VALUE, RAW, RAW | `shared-expression-conditional` | HOST_REFERENCE_AND_DOCUMENTED_ALGORITHM |
| `slice` | `slice` | signed-strided-slice-overload | VALUE, VALUE | `shared-slice-normalize-and-selection` | HOST_REFERENCE_AND_DOCUMENTED_ALGORITHM |
