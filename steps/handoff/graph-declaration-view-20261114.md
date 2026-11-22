# Чтение объявлений Graph и каталог primitive.description

2026-11-14, Codex, исследование для M11.5е. База383 `58bc7f3a`, во время WIP384.
Это результаты чтения исходников и кандидат реализации, не новая норма, не утверждённая
архитектура и не закрытый этап. Сборки и проверки поведения в рамках исследования не выполнялись.
Номера строк ниже относятся к прочитанному дереву; текущий writer может их сдвинуть.

## Задача и граница нормы

В [семантике, роли data/code](../../docs/spec/LMX_semantics.ru.md#data-code-roles) формалы
объявляются ресиверами: `int: arg default`, `@: arg Model`. Запись `arg: Model`
объявляла бы Structure и в формалах запрещена. Это отдельная задача от исправления
прямых актуалов ресивера: именованное фактическое задаёт только `:=`, но поля одного
целого descriptor DATA остаются обычными данными. Проверку последних нельзя подменять
запретом всех двоеточий внутри descriptor.

Синтаксис допустимого объявления шире текущего машинного lowering. Общий reader должен
различать имя, требование, квалификацию, глубину ссылок и Array, сохраняя физический граф.
Проверка декларации не должна вычислять initializer или готовить namespace binding.
Узкий список пяти C-скаляров не является полной проверкой формалов языка.

## Что уже имеется

Все пути в таблице начинаются с `selfbuild/src/l2src/`.

| Источник | Текущее содержимое и ограничение |
| --- | --- |
| [primitive.lm2](../../selfbuild/src/l2src/primitive.lm2), строки2–39 | Единственный текущий source-каталог `primitive.description`; колонки `class`, `cell`, `semantic`, числовые признаки, `width`, `range`, `spelling`, `convert`. Имена классов и признаки — данные, не список в алгоритме. |
| [l2_frontend_lower.lm2](../../selfbuild/src/l2src/l2_frontend_lower.lm2), `lm_compiler_table_find:1070`, `table_col:1082`, `prim_row:1140`, `prim_load:1161`, `prim_kind:4776` | Уже находят таблицу/столбцы, строки и признаки `cell`/`convert`. Они зависят от frontend table-state и заимствованных P0 nodes; прямо вызывать их из чистого Graph нельзя. |
| [l2_frontend_core.lm2](../../selfbuild/src/l2src/l2_frontend_core.lm2), `table_call:3214`, `program_tables:3403` | Общая существующая загрузка source-таблиц; строки режутся числом колонок через существующий разбор аргументов. Второй сканер текста каталога не нужен. |
| [l2_frontend_emit.lm2](../../selfbuild/src/l2src/l2_frontend_emit.lm2), `lm_compiler_translate:864`, участок965–982 | `snap_parse` → `program_tables` → `parts_read` загружают source-таблицы до `translate_unit`. Source-table не становится runtime-значением только потому, что файл передан в translation. |
| [l2_frontend_resolve.lm2](../../selfbuild/src/l2src/l2_frontend_resolve.lm2), `lm_compiler_declaration:803`, участок948–1010 | Рекурсивный reader `L2TypeContract`: kind0 leaf, 1 Array, 2 reference, 3 const, 4 immutable, 5 independent. Зависит от P0/состояния frontend и содержит прежние правила структурных ссылок; целиком переносить его в Graph нельзя. |
| [l2_frontend_helpers.lm2](../../selfbuild/src/l2src/l2_frontend_helpers.lm2), `lm_compiler_contract_leaf:1005` | Снимает reference/const и считает глубину; для Array, immutable, independent возвращает0. Это не готовый reader всех квалификаторов. |
| [lmx_graph.lm2](../../selfbuild/src/l2src/lmx_graph.lm2), `formal_name:718`, `formal_model:748` | `formal_name` обслуживает также псевдоформалы встроенных ресиверов: пустые именованные Lmx и word cells. `formal_model` понимает плоское `@` с2–3 полями, затем принимает любую голову с одним полем как model; этот fallback не отличает `arg: Model` от объявления примитивом. Общего declaration-view здесь ещё нет. |
| [l2_frontend_graph.lm2](../../selfbuild/src/l2src/l2_frontend_graph.lm2), `graph_scalar:110`, `door_word:121`, `number:141`, `formal_type:167` | Lowering знает `int char size_t unsigned ulong` и непустое `c.X`. Формалы: физические int/uninitialized-int, reference-to-int, плоское `@: name T`, одно поле у поддержанного scalar head. Общего qualifier/Array reader нет. Это предел lowering, не норма языка. |

В каталоге сейчас23 строки: `None void char short int long float double unsigned uint ulong
size_t Boolean bool u8 u16 u32 u64 i8 i16 i32 i64 FILE`. У `None`/`void` признак `cell=0`,
у остальных `cell=1`; одного membership bool для проверки контекстов недостаточно.
Комментарий `primitive.lm2:5–7` прямо перечисляет ещё не перенесённые legacy rows:
`Cell Count Integer Flag Ratio Float Complex Atom Address Opaque Text llong flong signed
uchar ushort ullong usize isize categoryFlag uint8 int8 f32 f64 bigint real decimal DecimalText`.
Их отсутствие сейчас — ограничение данных каталога; оно не доказывает запрет соответствующих
языковых форм. Нельзя объявить полную formal-validation выполненной экспортом23 строк.

`lmx_graph_receivers_in:108` содержит общий ручной набор слов языка, а не каталог типов:
там есть `signed`/`_Bool`, но нет `u8`/`Boolean`/`[]`. `language_receiver:1992` читает этот
набор; использовать его целиком как primitive classifier нельзя. Ещё один признак ширины
frontend — `lm_compiler_unimpl_numeric` в `l2_frontend_helpers.lm2:1737`: он узнаёт больше
числовых форм, чем умеет lowering, и сообщает об их неподдержанной реализации.

## Кандидат: экспорт данных во время генерации

Самый малый найденный путь без второго ручного списка — небольшой явный frontend-export
из уже загруженной `primitive.description`. Результат — только generated L1 data unit:
имена классов в порядке строк, число строк, признаки `cell` (другие столбцы лишь при нужде).
Например, NUL-separated blob не требует собственного парсера и сохраняет границы имён.
Алгоритм чистого запроса остаётся поддерживаемым L2 в Graph. Это кандидат, не обязательное
введение нового генератора, CLI или самостоятельной инфраструктуры.

Для такого варианта можно использовать:

- `lm_compiler_cli_main` в `l2_frontend_emit.lm2:18133` как существующий вход;
  `prim_load`/table-state для чтения, не повторный разбор исходного текста.
- `lm_compiler_emit_cstr` в [l2_frontend_values.lm2](../../selfbuild/src/l2src/l2_frontend_values.lm2):1235
  и правила payload из `l2_frontend_helpers.lm2`, `payload_same:1260`/`payload_eq:1902`.
  Обратные кавычки — оболочка payload, не часть canonical имени класса.
- `pub_prepare` в `l2_frontend_core.lm2:5150` и `pub_commit` в
  `l2_frontend_emit.lm2:16823`: существующая публикация со snapshot verification.
  Ошибки таблицы/вывода должны возвращать failure, не выглядеть отсутствием строки.
- [build.lm2](../../selfbuild/tools/build.lm2), `bld_kernel_l2:2143`: после
  `decls_write_all:1998`, до перевода Graph, получить unit и записать его/input hash.
  `lmx_graph.lm2` подключает generated data без P0/табличного состояния frontend.
  [suite.lm2](../../selfbuild/tools/suite.lm2), `generation_snapshot:1262`, уже сохраняет
  producer-каталоги `src/l2src` и generated headers для следующего поколения.

Возможная упаковка canonical membership без нового binding registry/GraphState ABI:
при создании process state интернировать строки в suffix уже существующего `state.receivers`;
чистый helper сравнивает указатели только в suffix длиной generated row count, flags
соответствуют порядку строк. Это лишь вариант повторного использования массива.
Расширять одновременно семантику `language_receiver` необязательно: его прежний prefix
можно сохранить. Он влияет также на `l2_graph_build.lm2:952` и классификацию
`lmx_graph_run.lm2:1555,2100`, поэтому такое расширение требует отдельного осознанного решения.

`decl_primitive` в `build.lm2:1754` генерирует **PRIM callback ABI** (`LmxPrimitive`,
entry/signature/owner), к primitive type catalog отношения не имеет. `bld_machine_module_from`
уже передаёт `primitive.lm2` каждому machine-module переводу (`build.lm2:1069`), а
`bld_self` передаёт его при сборке tool (`3779`). Это не даёт lmxtool runtime-доступа
к таблице; добавлять для этого P0 в kernel/tool не требуется.

**Bootstrap-зависимость:** штатный `build_generation` строит runtime предыдущим frontend
(`suite.lm2:1379`), а новый frontend связывает после runtime (`1385`). Если кандидат
получит новый frontend-export, первый seed этой команды ещё не знает. Нужен обычный
одноразовый bridge frontend, собранный принятым seed и связанный с совместимым существующим
runtime через `bld_frontend_objects`/`bld_frontend_link` (`build.lm2:3384,3433`). После
него — штатные G1/G2. Скрытый fallback на сохранённый unit или старый ручной список не нужен.

## Следующий небольшой объём и приёмка

Сначала выбрать общий чистый declaration-view, учитывая данные каталога и структурные
receiver compositions. Проверять написанные пользовательские формалы перед `fn_data`
(`lmx_graph_run.lm2`, `fn_make:5016`, вызов `fn_data:4869`), не ужесточая глобальный
`formal_name` так, чтобы сломать внутренние receiver pseudo-formals. Общие consumers
имени/требования должны получать согласованное чтение; отдельный runtime registry не нужен.

Следующая приёмка — требование к будущему изменению, ниже нет новых PASS:

1. `sub: bad (arg: Model) ()` и соответствующий `fn` отказывают при построении;
   побочные эффекты initializer/data ещё не исполнены. Whole descriptor DATA с полями
   `name/args/return/data/code` сохраняет обычное чтение данных.
2. `sub: good (@: arg Model) ()` принимается как объявление ссылочного формала;
   имя и model совпадают у общих consumers. Сохранить builtin receiver contracts.
3. Принять существующие primitive signatures самосборки, включая `size_t`, `unsigned`,
   `ulong`, и проверить строки вне пяти machine scalar names (`u8`, `Boolean`, `float`).
   Отделить принятие описания от ещё не реализованного машинного исполнения такого типа.
   `None/void` проверять в соответствующем контексте по признакам, не как обычный cell formal.
4. Прочитать допустимые `const`/`immutable`/`independent` compositions, ссылки произвольной
   глубины и `c.T` без сведения к пяти scalar names; сохранить имя, leaf и квалификацию.
   Формы сверять с [квалификацией](../../docs/spec/LMX_semantics.ru.md#qualification) и L2.
5. Прочитать Array и вложенный Array/reference/qualifier contract без sole-child unwrap
   и без потери мерности; опираться на [Array](../../docs/spec/LMX_semantics.ru.md#arrays),
   не объявлять machine `formal_type` полным синтаксическим валидатором.
6. Изменение одной строки/признака исходного каталога должно отражаться в generated data
   без правок второго списка; malformed catalog — явный generation failure.
   Затем обычные последовательные приёмка writer, bridge при необходимости и G1/G2.

Исследование не меняет v3, kernel/tools/tests и не закрывает M11.5е либо последующие этапы.
