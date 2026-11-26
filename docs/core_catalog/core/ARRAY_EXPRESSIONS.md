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

Размерные TYPE-постфиксы используют тот же плоский Array и depth:
`int[][3]: var [1 2 3 4 5 6]` определяет форму `[2,3]`, а `Struct[2][5]`
задаёт оба размера. Общий P0 полностью разбирает выражение размера;
TYPE получает каждое вхождение один раз. Полное нормализованное LEFT —
единственный источник тождества типа: `int[][]` равно `int[](2)`,
`int[2][3]` и `int[3][2]` различны, `int[]` длины 2/3 имеют один TypeRef.

У всех типов, включая примитивы, TypeRef — прямой адрес канонической
неизменяемой системной Structure, не integer-код/счётчик. Инициализатор и
резерв не уточняют его. `int[][]: [1 2 3; 4 5 6]` проверяет строки,
уплощает значения и сохраняет два неизвестных размера. Он может дать те же
данные, что int[][3], но имеет другой TYPE. Несколько неизвестных осей не
угадываются; нехватка сведений диагностируется при размерной операции,
которой они нужны. Плоское хранение и обычные линейные операции допустимы.

Основной Lmx — parent/length/storage. При capacity=length второго дескриптора
нет, включая пустой/nD Array; только capacity>length хранится дополнительной
компактной записью одной capacity. Reserve/resize сохраняют TypeRef и явные
ограничения. Формы экземпляра вне TYPE, скрытого shape или отдельного вида
«массив массивов» нет. [Общий договор](../../spec/ARRAY_STORAGE.ru.md#array-profiles).

`sys\typeof(obj)` уже возвращает каноническое TYPE-описание.
`sys\descriptor(sys\typeof(obj))` возвращает **ту же** системную Structure:
более конкретный договор канонического TYPE имеет приоритет. Обычная Structure
с похожими полями не выбирает эту ветвь. Для обычного объекта сохраняются три
адреса основных полей; вместимость экземпляра сообщает `sys\capacity(obj)`.
Никакого integer-поиска, копии описания или выделения на экземпляр не нужно.
[TYPE descriptor](../../spec/ARRAY_STORAGE.ru.md#type-descriptor).
Без инициализатора остаётся uninit. [Размерные формы](../../spec/ARRAY_STORAGE.ru.md#sized-postfix)
и [TypeRef ABI](../../TYPE_REFERENCES_CHANGE.md) — **DOC_SPEC_ADDITION_ONLY**;
production acceptance **NOT_RUN**. Существующие исходники/учебный C-runtime
со старым int-prefix требуют указанной миграции, а прежние receipts её не проверяют.

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
