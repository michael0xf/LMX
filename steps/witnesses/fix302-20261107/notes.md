# Срез 302 — коды идентификаторов в исполняемых цепочках (часть IDENTIFIER-CODES; промежуточный результат)

Opus (проект, устройство, кандидаты a01–a07, фокус, реестр a07, мутант m1), затем fable_pc с 2026-11-07 17:45Z по передаче автора ([to_fable.md](../../../to_fable.md): автор остановил Opus и поручил fable_pc продолжить; мутанты m2–m4, фикстура `copy_name_codes`, кандидаты a08–a09, реестр a09, whole boot164a, приёмка, посадка, документы). Поручение автора 2026-11-07 ([журнал](../../../LMX_blog/2026-11-07.md), раздел «Коды идентификаторов вместо имён-строк»; книга, «Имена и пути»): каждый идентификатор — код своего написания, одинаковое написание везде один код, новое — следующий инкрементом, без хеш-кодов; таблиц «код → имя» и «имя → код» только две, информационные для `toLmx`/`fromLmx`; ни native, ни интерпретатор не сравнивают имена строками; довести до конца во всех путях. Решения Codex по границам (CODEX-OPUS-302-IDS-HOME-SCOPE-ANSWER-20261107-01, [копия](records/pins/codex-302-ids-home-scope-answer.txt)): одна пара таблиц на процесс, один якорь сервиса `lmx_ids`, один счётчик; копирование, merge, attach переносят код без чтения написания; frontend входит в переход — за декодером входа дерево, проходы, выдача, ядро и обходчик передают код или разрешённый адрес; загрузка единицы — явная граница нормализации её идентификаторов, после ввода программы исполнение таблиц написаний не спрашивает. Этот срез — промежуточный: исполняемые цепочки ядра, обходчика и выпущенной единицы идут по кодам; внутренние сравнения транслятора, транслятор L1, AXBY и тесты RESULT остаются («Открыто»). RESULT не заявлен.

P = build2/codex_fix250generationchain01. Копии в [records](records) сделал `lmxtool stage-copy` из P, проверив хэш каждой; оригиналы связаны с [evidence.sha256](evidence.sha256).

## Проект (черновик Opus, до кода)

- Сервис `lmx_ids` (новый машинный модуль ядра): две таблицы процесса — «код → имя» (массив по коду: адрес и длина написания в неперемещаемом блоке) и «имя → код» (коды, упорядоченные по написанию; двоичный поиск, без хеша); новый код — следующий номер; простой замок записи и чтения таблиц (атомарный обмен), сравнение кодов в исполнителях замка не требует. Словарь языка (слова, которые сравнивают ядро и транслятор) засевается первым в одном порядке: константы `LMX_ID_*` в заголовке, при засеве — самопроверка совпадения номеров. Один экземпляр на процесс: якорь — модульный указатель в единственном юните состояния, который включается в амальгаму runtime (`driver.c`) один раз; программа и инструменты зовут функции сервиса.
- Привязка «адрес → код»: строка `LmxSourceName` держит код вместо текста (порты прежние); `lmx_source_name_get*` возвращают код; интерфейс мест (`place_names`) — массив кодов.
- Выпущенная единица: свои написания она один раз переводит в коды при загрузке (начало построения её графа), дальше в ней только числовые ссылки; регистрация имён графа, привязки активаций, связыватель, места интерфейса, селекторы полей, имена NAMED, ключи бросков — по кодам.
- Потребители ядра и обходчика: распознавание голов по константам словаря, `implements` (сравнение кодов вместо `lmx_implements_same_name`), формалы и фактические по коду, резолвер активаций по коду, копирование переносит код, GC больше не метит блоки написаний.

## Карта строковых путей до среза (инвентаризация Opus 2026-11-07, read-only, два агента по точным спискам файлов)

Ядро и обходчик (selfbuild/src/l2src):
- `lmx_source_names`: строка `LmxSourceName` {key, port, text (VoidArray в CHAR-пуле арены), place_names char*, place_spec, model_layout, place_uses, place_callable, pending_next}; `prepare_at` сравнивает повтор написания (size + `memcmp`), копирует байты; `get`/`get_at` (промах — домашняя арена ключа) отдают текст; `drop` снимает строки по пересечению текста; `mark` метит CHAR-блок написания. Порты: 0 — вхождение, −1 — интерфейс мест, −2 — реестр корневых голов, 1.. — свободные входы.
- `lmx_walk_values`: `receiving_head_is` (`strlen`/`memcmp`: const, immutable, independent, int, char, size_t, unsigned, ulong, void, [], fn, fm, sub), `receiving_reference_head` (все байты `@`); `lmx_walk_value_field_place`/`named_place` (селектор `name`, `[N]name`, `[]name`, `[][N]name`, разбор байтов `[`, `]`, цифр, `strlen`) — селектор хранится CHAR_PTR-ячейкой кадра OF/PUT_OF (`lmx_walk_field_selector`, `lmx_walk_field_target`, `lmx_walk_place_mode`); `lmx_call_unary_data` («var»); `lmx_walk_capture_actual_name`, `lmx_walk_written_values`, `lmx_walk_capture_receiving` (копия байтов имени NAMED); `lmx_call_bind_actuals` (`names[]` char*, `strlen`); `lmx_walk_selected_values`/`_ready_values` (`actual_names`); `lmx_walk_observe_body` (печать имени); резолвер активаций — `lmx_activation_input_name`, `lmx_activation_name_is` (`memcmp`), `lmx_activation_inputs_find`, `lmx_activation_record_find` (`binding\name`/`length`, `memcmp`), `lmx_activation_resolve(text, len)`, `lmx_walk_held_capture`, `lmx_activation_resolve_input` («var»); проверки наличия — `lmx_walk_input_width`, `lmx_walk_args_open_values`, `lmx_activation_input_formal`; кадры PLACE/CALL_DATA несут текст имён (`tokens`) в именованном режиме таблицы.
- `lmx_implements`: `lmx_implements_same_name` (`memcmp`), `place_name`/`head_name`/`view_name`, `named_view`/`named_resolve`/`fill_holes`/`source_view`, `lmx_callable_named_formal`, `actual_target`, `actual_place`, `bind_prefix`, `bind_written`, `source_binding`, `call_field`, `own_field`, `own_head_slot`, `head_slot`, `named_places` (спецификация [m, SIZE_MAX, (смещение, длина, тип)…] над текстом имён), `repeated_var` («var»), `unary_admission`, `call_places_open`, `places`, `admit_edge`.
- `lmx_graph_copy_owned`: `lmx_copy_spelling_prepare` (сравнение текста внутри пакета, копия байтов), `lmx_copy_name_prepare` (порты 0, −2, 1.., −1), `lmx_copy_names`, `lmx_copy_names_finish`; `merge`/`reparent` передают пакет.
- `lmx_call`: `lmx_activation_bind(arena, name, len, …)` хранит указатель на литерал программы; `LmxActivationBinding` {name, length, storage, type, value}.
- `lmx_arena_refs`: только проверки наличия имени; `lmx_gc_graph`/`lmx_range`: метка и снятие строк имён.
- `l2_driver` (тестовый драйвер): `shape_dump_source_name`, `shape_has_spell`, `shape_spell_is`, `shape_paths_check` (namepath/placenamepath), `shape_copy_native_call` (сравнение написаний копии), литералы фикстур при `lmx_source_name_set` и `lmx_activation_resolve`; слова CLI — не идентификаторы.
- tools/build.lm2: декларации `LmxSourceName`, `LmxActivationBinding`, прототипы; `l1_binds_native` ищет литерал имени метода в выпущенном L1; `os_walk_witness` считает строки `LMX_OBSERVE WALK_BODY имя`.

Выпуск frontend (что пишет написания в выпущенный код; B — построение при загрузке, F — кадры из B, R — тело метода при каждом исполнении, RB — строители merge/view при исполнении):
- регистрация `lmx_source_name_set`/`_set_at`: `lm_compiler_emit_source_name` (values) и его вызыватели в emit/core (оболочки источника, ячейки, вложения, поля методов, сигнатуры и заголовки, головы операторов, ячейки и единица, слои источника, атомы, ключи бросков, имена пространств, узел `rw_source_name`, атомы `rw_source_atom`), `lm_compiler_emit_method_part_name` (args/return/var/body), корневая голова (порт −2), свободные входы (порты 1..) — B, F, RB;
- `lmx_source_places_set` и таблицы мест `l2_cpn` (текст имён) / `l2_cpt` — B, F; `lmx_implements_places(…, l2_cpn, l2_cpt, …)` на входе метода — R;
- `lmx_activation_bind(…, "имя", длина, …)` (`lm_compiler_emit_work_decl`) — R;
- `l2_bn` (имена именованных фактических) для `lmx_call_bind_actuals` — R;
- селекторы `lmx_walk_value_field_place`/`named_place` (lower) и CHAR_PTR-селектор кадра OF/PUT_OF (emit) — R, F;
- ключи бросков: номера `lm_compiler_throw_key` (неявные 1..7 = LMX_WALK_NAME_*, свои — 8 + i в таблице единицы) в ячейках ключей кадров и в сравнениях площадок native.
- Строитель библиотеки исполняется при каждом вызове конструкции, поэтому нормализация её написаний должна быть однократной.

## Устройство (как сделано, кандидат tp164 a03–a09)

- Ядро: новый машинный модуль `lmx_ids` (6 экспортов: `lmx_ids_code`, `lmx_ids_name`, `lmx_ids_count`, `lmx_ids_reference`,
  `lmx_ids_unit_loaded`, `lmx_ids_unit_publish`), заголовок и юнит состояния пишет рецепт (`decl_ids`, `decl_ids_state`);
  засев 20 слов языка в порядке констант `LMX_ID_*` (неявные броски 1..7 совпадают с `LMX_WALK_NAME_*`); при выдаче кода
  запоминается, является ли написание головой ссылки любой глубины (`lmx_ids_reference` — метка, не чтение написания).
- Выпущенная единица: таблица `@: size_t l2_ids 0` и прототип `l2_ids_load` рядом с ячейками модуля (у библиотеки — под
  хэшированными именами `define:`), вызов `l2_ids_load()` первым оператором строителя (программы и конструкции
  библиотеки), определение загрузки в конце единицы: `l2_ids_table[K]: lmx_ids_code("написание", n)` для каждого места
  выпуска, затем `lmx_ids_unit_publish`; каждое место выпуска пишет `l2_ids[KU]` (`lm_compiler_unit_id`: свой K на
  место, транслятор написаний не сравнивает).
- Переведены места выпуска: регистрация имён (`lm_compiler_emit_source_name`, части методов, корневые головы порт −2,
  свободные входы), таблицы мест (`[m, SIZE_MAX, (код, тип)…]`, без `l2_cpn`; кадр PLACE без токенов, ядро
  `lmx_walk_table_cells` принимает таблицу именованного режима без токенов), `lmx_activation_bind` (код), `l2_bn`
  (`size_t`, коды), селекторы (`lmx_walk_store_selector` в обходчике и `lmx_walk_value_field_place`/`named_place` в
  native: код, вхождение `[N]` или SIZE_MAX, признак `[]` — разбор при трансляции, `lm_compiler_path_selector_parts`),
  ключи бросков (ячейки ключей обходчика и площадки native — код имени).
- Ядро и обходчик сравнивают коды: `receiving_head_is` по константам, `receiving_reference_head` по метке,
  `lmx_implements_same_name`, `lmx_callable_named_formal`, `lmx_implements_named_places` (спецификация из пар), резолвер
  активаций (`lmx_activation_input_name`/`name_is`/`inputs_find`/`record_find`/`resolve`), `LmxActivationBinding\code`;
  `lmx_walk_capture_actual_name`, копия байтов NAMED и GC-метка блоков написаний удалены; `lmx_copy_spelling_prepare` /
  `lmx_copy_name_prepare` переносят код вхождения; `lmx_walk_observe_body` и драйвер печатают через `lmx_ids_name`.
- Рецепт: `l1_binds_native` узнаёт имя метода в выпущенном L1 по коду (`l1_is_name_code`: `l2_ids[K]` и строка загрузки
  с этим написанием); `inputs.list` + `src/l2src/lmx_ids.lm2` (238 входов), с a08 + `tests/dyn/copy_name_codes.lm2` (239).
- Драйвер: проверка `ids_check` таблиц процесса (слова языка, одно написание — один код после другого, следующий номер,
  код → имя, метка ссылки, однократная публикация таблицы единицы, отказ таблицы с кодом 0).
- Фикстура [copy_name_codes](../../../selfbuild/tests/dyn/copy_name_codes.lm2) (a08–a09; ряд 178 реестра): `Copy: merge: Holder`
  копирует Structure с двумя вызываемыми; ссылка `@: hc Holder Copy` держит копию, так что вызовы выбирают скопированные
  вызываемые при исполнении: `hc\f(y: 3; x: 4)` — именованная подача копии в переставленном порядке связывает формалы по
  кодам имён (43); `hc\g(x: 5)` — формал `x` копии есть ближайшая привязка свободного входа `x` метода `k`, найденная по
  коду через цепочку активаций (6, а не корневое `x` 11: одно написание в другом методе — тот же код); `Copy\base` (100) и
  исходный `Holder\f(y: 3; x: 4)` (43). Выход 7; 81–84 называют отказавшую проверку.

## Сборки кандидата (по ходу)

Стейдж `cold-tp140`, подготовка — `lmxtool steps` рабочего tool boot163a по спискам `tp164-prepare-aNN.tsv` (13–16 изменённых
путей, копия в `variants/tp164`, манифест стейджа по `inputs.list`, сверка с рабочей копией — 238/0 до a07, 239/0 с a08).

| Сборка | Кандидат | Итог |
| --- | --- | --- |
| tool164a | a01 | собран (Opus, 16:25:24→16:28:33Z), `059c4603…`, smoke 0 отказов (`tools/build.lm2` не менялся до a07) |
| rt164a | a02 | отказ трансляции: `length` — слово языка (`lmx_ids.lm2:63`) |
| rt164b | a03 | собран (16:38:20→16:39:08Z): driver.o `f5eaed6f…`, driver-observe.o `4e3fc11a…`; заголовки `lmx_ids.h.lm1` `44f17b95…`, `lmx_source_names.h.lm1` `623625c6…`, `lmx_walk_values.h.lm1` `e755f33b…` |
| fe164a | a03 | отказ трансляции: `length` в новых функциях `l2_frontend_values` |
| fe164b | a04 | отказ P0: `l2_frontend_lower.lm2:6922` — спуск на два уровня без `---` |
| fe164c | a05 | отказ gcc: поле локальной структуры по значению (`t\length`) в аргументе C-вызова распалось на `t, ., length` (`lm_compiler_emit_unit_ids`) |
| fe164d | a06 | собран (17:09:57→17:13:14Z): l2trans `b5d87c15…`, l1trans `06458a1c…`, l2_libc `af9fdae3…` |
| — | a07 | фикстура `free_c_pointer` на `const char *` у `lmx_ids_code`; ядро, frontend и tools как a06 |
| — | a08 | + фикстура `copy_name_codes`, её ряд в `tests/full-suite.tsv`, `inputs.list` 239 (fable_pc, 18:16:34Z) |
| — | a09 | фикстура `copy_name_codes` переписана (вызовы через ссылку модели `Holder`); ядро, frontend и tools как a07 (18:18:59Z) |

Ядро a03 = a07 = a09 (rt164b), frontend a06 = a09 (fe164d), tools a01 = a09 (tool164a): байты этих файлов в `source-tp164-a09.sha256` те же, что в сборочных терминалах.

## Фокус и реестр

| Запуск | Кортеж | Итог |
| --- | --- | --- |
| f302a (Opus) — 21 ряд реестра по путям имён ([список](records/pins/f302a.tsv)) | tool164a, fe164d, rt164b | 17:13:25→17:17:20Z: 21/0 ([лог](records/pins/tp151-probe-f302a.log)) |
| r302a (Opus) — весь реестр a07 ([список](records/pins/registry302-a.tsv) = байты `tests/full-suite.tsv` до 302) | тот же | 17:17:48→17:32:34Z: 113 рядов, 2 отказа — `free_c_pointer`, оба режима, gcc: фикстура звала C-дверью `lmx_walk_value_field_place` прежней сигнатуры ([лог](records/pins/tp151-probe-r302a.log)) — миграция теста из-за сигнатуры ядра, не ошибка связывания |
| f302b (Opus) — `free_c_pointer` на a07 ([список](records/pins/f302b.tsv)) | тот же | 17:35:04→17:35:17Z: 1/0 ([лог](records/pins/tp151-probe-f302b.log)) |
| f302c — `copy_name_codes` a08 ([список](records/pins/f302c.tsv)) | тот же | 18:16:48Z: отказ трансляции обоих режимов — `copy_name_codes.lm2:25:18: a call path must end at a callable field` (`frame=Copy\f`): путь вызова через сам результат `merge` транслятор не принимает ([лог](records/pins/tp151-probe-f302c.log)); фикстура переписана (a09) |
| f302d — `copy_name_codes` a09 (тот же список) | тот же | 18:19:00→18:19:04Z: 1/0, 7 в native и forced, корни 0 и 1 ([лог](records/pins/tp151-probe-f302d.log), [native root0](records/tp151-probe/f302d/copy_name_codes-native/run-root0.log)) |
| r302b — весь реестр a09 ([список](records/pins/registry302-b.tsv) = байты `tests/full-suite.tsv`, 114 рядов) | тот же | 18:19:47.49→18:34:41.74Z (894.25 с): 114 рядов, 0 отказов, 952 проверки `PASS` ([terminal](records/pins/tp151-probe-r302b.terminal.txt), [лог](records/pins/tp151-probe-r302b.log)) |

## Мутанты

Ручная правка стейдж-файла (инструмент Edit), сборка runtime ([tp164-rt](records/pins/tp164-rt.command)) или frontend ([tp164-fe](records/pins/tp164-fe.command)) отдельным сообщением после правки (хэши изменённых файлов — в терминале сборки), девять рядов реестра по путям имён ([mut302](records/pins/mut302.tsv): броски, поля библиотеки через единицы, копия, удерживаемые места, свободные поля, таблицы мест, вхождения, поля места callable, именованные фактические) рецептом [tp151-probe](records/pins/tp151-probe.command) на мутантной сборке; после каждого — возврат изменённых файлов стейджа из варианта a07 и проверка всего стейджа ([mut302-restore](records/pins/mut302-restore.tsv): 14 файлов, 238/0; терминалы с хэшами до и после).

| Мутант | Правка | Итог |
| --- | --- | --- |
| m1 (rt164m1, ядро `lmx_ids.lm2` `2ca2e51e…`; Opus) | `lmx_ids_put` не находит прежнее написание (`if: r = 0 && nb = 0U`): одно написание — новый код каждый раз | убит: 36 отказов из 36 ([лог](records/pins/tp151-probe-m302a.log)); в каждом запуске отказывают и самопроверка драйвера (`ids: the words of the language have their fixed first codes`, `one spelling has one code`), и построение программы (`the host built R0's program exactly once, and the builder succeeded`; `the host could not make R0`) — программа не строится, не только `ids_check` ([native root0](records/tp151-probe/m302a/os_throws-native/run-root0.log)); восстановление — [m1](records/pins/mut302-restore-m1.log) |
| m2 (rt164m2, ядро `lmx_graph_copy_owned.lm2` `049d2eca…`) | `lmx_copy_name_prepare`: имя вхождения (порт 0) копируется кодом `0U` вместо `c.lmx_source_name_get(src_arena, source)` — копия теряет коды имён своих вхождений | **пережил** девять рядов: 36 из 36 прошли, в том числе `split_copy_bound_data` (`Copy: merge: A`) и `source_occurrences` (`Copied: merge: D`) ([лог](records/pins/tp151-probe-m302b.log)) — поля данных копии по-прежнему находятся по строкам реестра корневых голов (порт −2, копируется отдельно), а опущенные операторы тел диспетчеризуют типизированные OP-записи; только места с именем порта 0 и без строки головы — ячейки заголовка `args` вызываемого — читают код: `lmx_callable_named_formal` (именованная подача выбранному при исполнении) и `lmx_activation_input_name` (свободный вход через скопированный формал). Убит новым рядом `copy_name_codes` на том же rt164m2: m302e — 4 отказа из 4, `walk error: UNSUPPORTED` (связыватель не находит формалов копии) в native и forced, корни 0 и 1 ([лог](records/pins/tp151-probe-m302e.log), [native root0](records/tp151-probe/m302e/copy_name_codes-native/run-root0.log)); на rt164b тот же ряд — 7 (f302d). Восстановление — [m2](records/pins/mut302-restore-m2.log) |
| m3 (rt164m3, ядро `lmx_walk_values.lm2` `1515c75e…`) | `lmx_walk_table_cells`: прежнее условие 301 `if: \tokens = 0` — таблица именованного режима снова требует токенов | убит: 12 отказов из 36 — `split_copy_bound_data`, `held_structure_places`, `place_map`, `callable_place_fields` в forced и `source_occurrences` в обоих режимах, `lmx: walk error: INVALID` ([лог](records/pins/tp151-probe-m302c.log), [forced root0](records/tp151-probe/m302c/place_map-forced/run-root0.log)); восстановление — [m3](records/pins/mut302-restore-m3.log) |
| m4 (fe164m4, frontend `l2_frontend_values.lm2` `e5d2969b…`, l2trans `88bc278e…`) | `lm_compiler_path_selector_parts`: `selected[0]: (cast: (size_t) -1)` вместо `v` — записанное `[N]` теряется в обоих исполнителях | убит: 8 отказов из 36 — `source_occurrences` и `callable_place_fields` в native и forced, корни 0 и 1: R0 остановлен непойманным броском ([лог](records/pins/tp151-probe-m302d.log), [native root0](records/tp151-probe/m302d/source_occurrences-native/run-root0.log)); восстановление — [m4](records/pins/mut302-restore-m4.log) |

Четыре из четырёх убиты; m2 — только новым рядом, который с a08 входит в поддерживаемый реестр. Не различены отдельным мутантом: внутренние сравнения транслятора (остаются строковыми — «Открыто»); копия в другую арену (в программе языка такой копии пока нет, см. «Открыто»).

## Приёмка

| Шаг | Результат | Receipts |
| --- | --- | --- |
| Кандидат a09 | 16 изменённых файлов `steps` рабочего tool boot163a по [tp164-prepare-a09](records/pins/tp164-prepare-a09.tsv): 5/0, манифест стейджа 239/0 (18:18:59.82→18:19:00.32Z); ядро/frontend/tools как a03/a06/a01 — rt164b, fe164d, tool164a стоят | [лог](records/pins/tp164-prepare-a09.log), [терминал](records/pins/tp164-prepare-a09.terminal.txt); a08 — [tp164-prepare-a08](records/pins/tp164-prepare-a08.tsv), [лог](records/pins/tp164-prepare-a08.log) |
| Реестр на кандидате | tool164a, fe164d, rt164b, весь поддерживаемый реестр a09 ([копия](records/pins/registry302-b.tsv), байты `selfbuild/tests/full-suite.tsv`): 114 рядов, 0 отказов, 952 проверки, 18:19:47.4871859Z→18:34:41.7401572Z (894.25 с) | [terminal](records/pins/tp151-probe-r302b.terminal.txt), [лог](records/pins/tp151-probe-r302b.log) |
| Стейдж bootstrap | `steps` рабочего tool boot163a по [boot164a-prepare](records/pins/boot164a-prepare.tsv): 5/0, стейдж `cold-boot164a` 239/0, source-boot164a = source-tp164-a09 (`b67a2bdd…`), 18:35:27.61→18:35:29.89Z | [лог](records/pins/boot164a-prepare.log), [терминал](records/pins/boot164a-prepare.terminal.txt) |
| Whole boot164a | 18:35:51.6088060Z→18:46:43.1927342Z, BootstrapExit 0, 651.58 с; `BOOTSTRAP quick 0 failures`; smoke 9/0 в обеих генерациях; G0 — tool164a стейджа `059c4603…` (`tools/build.lm2` изменён срезом), предыдущий frontend — G2 boot163a `57ad3f2e…`; G1: l2trans `6febd7c5…`, l1trans `dd171bf1…`, driver.o `f5eaed6f…`, tool `caec2397…`; детачированный запуск pwsh 7 (терминал без BOM) | [terminal](records/pins/boot164a-quick.terminal.txt), [log](records/pins/boot164a-quick.log), [verify](records/pins/boot164a-quick-verify.log), [detached](records/pins/boot164a-detached.terminal.txt), [G2](records/cold-boot164a/quick164a/g2-build.log) |
| Приёмка `checks` | рабочий tool boot163a, [список](records/pins/boot164a-check.tsv): 38/0 (18:47:13.41→18:47:13.80Z) — стейдж 239/0; записи producers G1 и G2 и запись сборки G2 замкнуты, без script host; G1 и G2: `exe-same` l2trans, l1trans, tool, `same` l2_libc.o, driver.o, driver-observe.o, L1 и C tool, consumed-inputs; рабочий tool и bundle = G2; runtime, на котором шёл реестр (rt164b), = G2 runtime boot164a байт в байт; fe164d = G2 по `exe-same`, l2_libc `same` | [лог](records/pins/boot164a-check.log), [терминал](records/pins/boot164a-check.terminal.txt) |
| Самотест G2 tool | рабочий tool boot164a `8b106da5…` (= G2 tool), ребёнок `tool153a-child` (`40c935bc…`), рецепт [tp152-selftest](records/pins/tp152-selftest.command): `SELFTEST 0 failures` (12 строк `FAIL` — ожидаемые отказы негативных проверок схемы, как у 298–301), 18:47:35.59→18:47:47.63Z | [terminal](records/pins/tp152-selftest-g302.terminal.txt), [лог](records/pins/tp152-selftest-g302.log) |
| Посадка | `steps` рабочего tool boot164a по [land302](records/pins/land302.tsv): 9/0, `selfbuild/inputs.sha256` = source-tp164-a09 `b67a2bdd…` (239 входов), G2 consumed 311/0, 18:48:10.45→18:48:11.80Z; git по точному списку 239 входов и манифеста — изменены ровно 11 модулей ядра/frontend/драйвера, `tools/build.lm2`, `free_c_pointer`, `full-suite.tsv`, `inputs.list` и манифест, новые `lmx_ids.lm2` и `copy_name_codes.lm2`; `selfbuild/inputs.list` (сам себя не перечисляет) равен списку варианта tp164 | [терминал](records/pins/land302.terminal.txt), [лог](records/pins/land302.log) |

Кортеж: рабочий tool `8b106da588fad35dc7b0139d963867f7087fae657b601e38920a0e8d1543f07e` (= G2 tool), G2 l2trans `0213ad799179b30f95d52a785bc7159cf1b13d7e90ce77231ab23f5b81018ab6`, l1trans `dbd894e549f97eb6b7773ea59c84daa5853f4d5d341e2f88b188385f5347e7c8`, l2_libc `af9fdae33655f8e6235310720787102921450f0f88f9b7bb2f365d372f553d37`, driver `f5eaed6ff0c8ccfdd27a3198f3e9c7ff70a7743751a311f0809a26b674eba8d8`, observe `4e3fc11a68706feab90af250a594212451abaff260a76921ce7c81c13560ada6` (= rt164b — runtime изменённого ядра, на котором шли реестр и мутанты); G0 — tool164a стейджа `059c4603626ffe9c37ce66f7d068206e282463a1857aeb49494b6cde0ec14796`, предыдущий frontend — G2 boot163a `57ad3f2e8a05b4262c6a690c5e7dc4751611d5a486c77801d6c4d8390da69ffb`. Source 239 входов, manifest `b67a2bddd4f6ef7037b17674752ac03a25c7adfb293de1295f14f0b81749886c` (source-tp164-a09 = source-boot164a = `selfbuild/inputs.sha256`).

## Границы

- Промежуточный результат: по кодам идут исполняемые цепочки ядра, обходчика и выпущенной единицы; транслятор внутри
  (P0, области видимости, resolve, intern сигнатур `l2_frontend_intern`, таблица `lm_compiler_throw_key`) и транслятор L1
  по-прежнему сравнивают написания — остаток того же перехода; AXBY и ранняя проверка имён и формы не сделаны
  (CALL-ARGUMENT-ORDER-AXBY); связывание именованных фактических по-прежнему ищет формал выбранного при исполнении — теперь
  по коду, а не по строке.
- Граница ввода единицы (`l2_ids_load` первым оператором строителя; у библиотеки — при первом вызове конструкции, повторный
  находит таблицу) и один сервис процесса — техническое решение Codex в рамках поручения автора, не слова автора; в книге
  помечено так же.
- Тесты, которых RESULT требует отдельно (ответ Codex): одно написание в разных единицах и аренах при любом порядке ввода,
  затенение при одном коде, копия в другую арену без текста и узнавание скопированной головы. `copy_name_codes` даёт копию
  `merge` в той же арене и одно написание в разных методах; `ids_check` драйвера — порядок кодов и однократную публикацию
  таблицы единицы. Межаренная копия в программе языка недоступна (`post`/`sendMessage` — §8a); режим `copycall` драйвера
  (`shape_copy_native_call`) проверяет коды головы и поля межаренной копии, но ряд реестра не передаёт слов драйверу
  (`bld_run`: `0 entry N [walkroot 1]`).
- Путь вызова через сам результат `merge` (`Copy\f(...)`) транслятор не принимает («a call path must end at a callable
  field») — предел транслятора, не норма; вызов через ссылку модели (`@: hc Holder Copy; hc\f(...)`) принимает.

## Провенанс

Правки стейджа для мутантов — инструмент Edit; фикстура — Write; списки `mut302-restore.tsv`, `tp164-changed-a08/a09.list`,
`tp164-prepare-a08/a09.tsv`, `f302c.tsv`, `docs302-render.tsv`, `docs302-check-a.tsv` — `printf` (a08 → a09 списки: `cp` и
`printf`); `registry302-b.tsv` — `cp` байтов `selfbuild/tests/full-suite.tsv` (как registry302-a у Opus);
`boot164a-prepare.tsv`, `boot164a-check.tsv`, `land302.tsv`, `boot164-quick.command`, `boot164-detached.command` — из
аналогов 301 одной подстановкой меток `sed` в новый файл (шаблон не менялся), затем правки Edit (см. отклонения 5–6).
Каждый список разобран при исполнении `steps`/`checks` без отказа строки. Возвраты после мутантов — `stage-copy` из
варианта и `verify` всего стейджа. Все запуски — из своих новых каталогов `P/<имя>-run`, рецепты `.command` — pwsh 7 по
полному пути формой `ScriptBlock::Create`.

### Отклонения

1. (Opus) Хэш нового tool в рецептах tp164-rt/tp164-fe (написаны инструментом Write с меткой `TOOLHASH`) подставлен `sed -i`, а
   не правкой Edit.
2. (Opus) После сборки rt164b выведен список каталога `cold-tp140/rt164b` (`ls … | grep L2.log`) — перечисление каталога стейджа,
   запрещённое правилом точных путей; защищённое имя не выведено, но это нарушение границы.
3. (Opus) Первый запуск сборки fe164c (`pwsh -File` с рецептом `.command`) не стартовал: pwsh принимает `-File` только у `.ps1`;
   рецепт не исполнялся, ничего не создано; повтор — прежней формой `ScriptBlock::Create`.
4. (Opus) Первая версия списка мутантов `pins/mut302.tsv` записана циклом `for` в bash (по `sed -n` на строку); до первого
   использования переписана одной командой `sed -n -e … registry302-a.tsv` (`f795bf60…`), ни один запуск первую версию не
   читал.
5. (fable_pc) `boot164-quick.command`, полученный подстановкой `sed` из `boot163-quick.command`, сохранил путь G0 и пути
   предыдущего frontend 301 (подстановки с `\` не совпали) и метку `source-boot163` в терминале; исправлено Edit до
   какого-либо запуска (рецепт в неверном виде не исполнялся). Комментарий `boot164a-check.tsv` исправлен так же.
6. (fable_pc) Первый `tp164-prepare-a09.tsv`, полученный `sed` из a08, содержал «a09 with» и символ перевода страницы вместо
   `\f` в комментарии; переписан `printf` до использования, ни один запуск его не читал.
7. (fable_pc) Первая версия фикстуры (a08, `Copy\f(...)` на результате `merge`) отказана трансляцией (f302c); receipts a08
   сохранены, фикстура переписана (a09). Список `f302c.tsv` использован запусками f302c, f302d, m302e.
8. (fable_pc) Книга, заметки о реализации, реестр дефектов, план, чек-лист, current.md и README правились инструментом Edit
   до завершения whole boot164a; числа приёмки внесены после receipts (плейсхолдеры в рабочей копии до коммита не
   публиковались).
9. (fable_pc) Первый каталог запуска архива `docs302-archive-1-run` создан, но запуск не состоялся: команда после `cd` в
   каталог запуска использовала относительные пути (терминал не записан, tool не стартовал); повтор из
   `docs302-archive-1-run-02` с абсолютными путями, пустой первый каталог оставлен. `records302-2.list` с первого раза не
   записан по той же причине (параллельная команда сменила cwd), записан повторно по абсолютному пути; ни один запуск
   неверные пути не читал.

## Документы

Записаны: [реестр дефектов](../../defects.md) — заголовок и абзац 302 в IDENTIFIER-CODES (OPEN; остаток); абзац 302 в [плане](../../../next_core_tasks_v3.md); строки 3–5 и 45 [чек-листа](../../../next_core_tasks_v3_checklist.md); [steps/current.md](../../current.md) — назначение fable_pc с 2026-11-07 17:45Z и абзац 302; [selfbuild/README.md](../../../selfbuild/README.md) — 239 входов и абзац Slice302. Книга [provenance/semantics-book.md](../../../provenance/semantics-book.md) (RU и EN парно): принимающее выражение L3 — обходчик читает код написания, привязанный к адресу вхождения, и сравнивает его с кодом слова языка (не таблица «адрес → имя»); имя головы — в привязке адреса вхождения к коду; «Имена и пути» — привязка «адрес вхождения → код», написание даёт только информационная таблица «код → имя», граница ввода единицы и единственный сервис процесса (помечены как техническое решение Codex в рамках поручения автора), реализация 302 и остаток; построение — имена вхождений хранятся кодами, обходчик узнаёт голову Frame по коду её вхождения; части вызываемой Structure и `call` — голова `fn` по коду, распознавание по коду её вхождения; `toLmx` — информационная таблица «код → имя». [docs/LMX_semantics.ru.md](../../../docs/LMX_semantics.ru.md) и [.en.md](../../../docs/LMX_semantics.en.md) порождены языковым render рабочего tool boot164a ([docs302-render](records/pins/docs302-render.tsv), [лог](records/pins/docs302-render.log), [терминал](records/pins/docs302-render.terminal.txt): 35 парных глав, 14 случаев implements, оба снимка источников; verify 0) — изменились ровно два сгенерированных документа, 16 строк каждый. [Заметки о реализации](../../../docs/implementation-notes.ru.md) RU/[EN](../../../docs/implementation-notes.en.md), раздел 3 — абзац о сервисе `lmx_ids`, границе загрузки единицы и остатке. Журнал без изменений: новых слов автора в срезе нет.

Архив и docs check — `steps`/`checks` рабочего tool boot164a. Первый проход ([docs302-archive-1](records/pins/docs302-archive-1.tsv), [лог](records/pins/docs302-archive-1.log), [терминал](records/pins/docs302-archive-1.terminal.txt)): манифест 133 путей P из [records302.list](records/pins/records302.list), их байтовые копии `stage-copy` в [records](records), [evidence.sha256](evidence.sha256) проверен против P и против копий (133/0). Точный allowlist ([allow302-1](records/pins/allow302-1.list), 163 пути: 30 путей записаны `printf`, 133 пути копий — `sed` из списка records) проиндексирован `git add --pathspec-from-file` при пустом индексе; индекс сверен со списком `diff` ([листинг](records/pins/index302-1.txt)); 74 копии с CR ([список](records/pins/crlf302-1.list), один `grep -l -U` по списку) удалены по точному списку (`xargs rm`) и записаны git из индекса с LF (`git checkout-index --stdin`); пересчёт тем же `grep` — 0 (`.gitattributes`: `* text=auto eol=lf`, `core.autocrlf=false`; двоичных копий нет — терминал детачированного запуска pwsh 7 чистый UTF-8). PRIVATE_OUT создан до запуска; docs check ([список](records/pins/docs302-check-a.tsv), [terminal](records/pins/docs302-check-a.terminal.txt), [лог](records/pins/docs302-check-a.log)): `CHECKS 1 lines, 0 failed` — 35 парных глав, 14 implements, оба снимка, 27 парных разделов грамматики, 44 выдержки, 615 импортов, ссылки, точное открытие семантики, LF в индексе у всех отслеживаемых файлов (18:51:40→18:57:16Z). Второй проход ([docs302-archive-2](records/pins/docs302-archive-2.tsv), [records302-2](records/pins/records302-2.list)): 13 копий receipts первого прохода и docs check, итоговый [evidence.sha256](evidence.sha256) по [evidence.list](evidence.list) (146 путей) против P — 146/0 (18:58:35→18:58:36Z); затем этот файл, копии второго прохода и evidence добавлены к индексу вторым точным списком (176 путей, индекс сверен `diff`), 2 копии с CR переписаны из индекса с LF, пересчёт по всем 146 копиям — 0; `git diff --cached --check` — одна строка `records/pins/tp152-selftest-g302.log:5: trailing whitespace` (`PASS ARG 2 ` — вывод самотеста инструмента, скопированный байт в байт, та же строка в копии 301; не правится, чтобы хэш копии совпадал с P), иных замечаний нет; docs check повторён над итоговым индексом (receipts второго прохода и повторного docs check остаются в P: `pins/docs302-archive-2.log`, `pins/allow302-2.list`, `pins/index302-2.txt`, `pins/crlf302-2.list`, `pins/docs302-check-b.*`).

## Открыто

- Внутренние сравнения транслятора (P0, области видимости, resolve, intern сигнатур, ключи бросков) и транслятор L1 — следующие срезы того же перехода; AXBY и ранняя проверка имён и формы (CALL-ARGUMENT-ORDER-AXBY) — вместе с ним.
- Межаренная копия без текста и узнавание скопированной головы в программе языка — для RESULT (пока только режим `copycall` драйвера вне рядов реестра и копия `merge` в той же арене).
- Происхождение нормы (CODEX-OPUS-REDECL-TYPE-PROVENANCE-CORRECTION-20261107-01, [копия](records/pins/codex-302-redecl-type-provenance.txt)): «повтор не переобъявляет контракт или C-тип места» — вывод Codex в ревью 295 из правила автора «повторное объявление — не ошибка, а присваивание» (LMX_blog/2026-11-03.md:34–45), не дословное решение автора; обратного разрешения менять тип автор тоже не вводил. В записи REPEATED-DECL-TYPED-RECEPTION уточнить атрибуцию; типизацию на этом основании не менять; случай, где нужен выбор о смене требования или типа места, — к Codex.
