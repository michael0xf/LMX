# Срез 303 — оператор `:=`: запись известного места и именованная подача; `a: 5` и `a(5)` — не именование

fable_pc, 2026-11-07. Поручение автора через Codex (CODEX-OPUS-AUTHOR-FINISH-ASSIGN-MERGE-NATIVE-WALKER-20261107-01 и
уточнения того же дня; приёмка — [steps/current.md](../../current.md), абзац решения о `:=`; передача —
[to_fable.md](../../../to_fable.md), раздел «После 302»). Норма — [книга](../../../docs/LMX_semantics.ru.md#assign-known)
(`assign-known`, `named-actuals`), [грамматика §21](../../../docs/LMX_grammar.ru.md#operators). Дефекты —
ASSIGN-KNOWN-OPERATOR, NAMED-BINDING-BY-HEAD ([реестр](../../defects.md)). Часть поручения о `merge` и всей структуре
аргументов (MERGE-OPERAND-FORMS, CALL-WHOLE-ARGUMENTS-STRUCTURE) — ниже, «Границы»: общая форма whole-arguments
удержана по ответу Codex до решения автора.

## Проект

1. P0: `:=` — один операторный токен. Frame левой части (голова) и правой части (тело) с флагом `LM_P0_FRAME_ASSIGN`
   (32U, `tools/build.lm2` пишет заголовок P0), без флага двоеточия: `a:=5` и `a := 5` — одна запись; `a:` головой Frame
   не становится; тело разбирается как встроенное тело Frame с двоеточием; без флага двоеточия Frame не держит уровень
   дочерних строк. Токен `:=` добавлен и в реестр компактных кусков (`lm_p0_scan_registry_compact_atom_piece`).
2. Связыватель фактических (`lm_compiler_bind_value_actuals_into`): формал именуется только Frame `:=` (голова — имя
   формала, тело — значение); Frame, чья голова лишь совпадает с именем формала (`a: 5`, `a(5)`), — позиционное
   значение, в том числе обычный вызов видимого callable `a`. Неизвестное имя при `:=` — отказ «is not an argument of»;
   позиционный после именованного — прежний отказ. Режим `by_head` для частей ресивера `table:` (`source`, `name:`,
   `columns:`, `rows:` — головы его грамматики), иначе предeф `convert.lm2` не транслируется.
3. Оператор-утверждение `left := right`: `lm_compiler_is_asgn` считает Frame `:=` присваиванием независимо от роли
   головы как вызываемого (callable в месте не вызывается — `lm_compiler_head_is_call`, `lm_compiler_bind_node_content`,
   `lm_compiler_scan_actuals_value`); неизвестная левая часть — отказ проверки «:= writes a place already known: its left
   side is not one here» (`lm_compiler_check_body`), а не определение: `lm_compiler_local_absent_def`,
   `lm_compiler_ns_nested_def`, `lm_compiler_ns_bind_item` ничего не объявляют по Frame `:=`. Запись известного места —
   прежний общий путь (`x: v`): допуск, преобразование, формал, поле по пути, ссылка на метод.
4. Фикстуры реестра с именованной подачей `x: v` переведены на `x := v` (они утверждали исправляемое связывание по
   голове): bound_typed_reception, copy_name_codes, formal_default_none_refused, formal_defaults, named_actuals_selected.
   Новые: assign_known, assign_unknown_refused, assign_in_structure_refused, named_assign_actuals,
   named_assign_unknown_refused, named_assign_positional_after_refused, merge_named_field_operand.
5. Операнд `merge`, записанный «имя: тип: значение» — `(a: int: 5)` и `a: int: 5` — типизированное поле, как
   `(int: a 5)` (`lm_compiler_named_typed_field_kind`, `lm_compiler_merge_typed_decl`, `lm_compiler_merge_typed_own`;
   карта слотов результата `lm_compiler_mrs_build` берёт род и слово типа у внутреннего Frame).
6. Что считается известным местом у `:=` (проверка `lm_compiler_check_body`): объявленные формалы (`l2_formal_find`),
   видимое поле (`l2_own_visible`: поле единицы, видимое методу, — его скрытый вход, Q52), слот, локал метода (`l2_ml_find`),
   активация хоста вложенного метода (`lm_compiler_assign_host_place`: формал или поле хоста — захват T6b/A3). Не
   `l2_param_find`: он отвечает и за динамический вход, который сбор (`lm_compiler_scan_ident`) делает из любого
   свободного имени для `x: v` («unresolved if none binds it»; история механизма — steps/free-names.md, чей §7 отозван
   уточнением 2026-10-03, норма — единое разрешение головы и книга), — для `:=` такое имя местом не является, и `zz := 5`
   отвергается после сбора, хотя сбор уже записал `zz` входом (трансляция на этом кончается).
7. Программа обходчика (`lm_compiler_rw_stmt_content`, «A call statement») не спрашивает `l2_call_head_method` для
   Frame `:=`: для привязки, держащей callable, тот отвечает держимым методом, и `target := two` уходил вызовом `one` с
   фактическим `two`; теперь запись падает в store привязки (`lm_compiler_method_pointer_candidate`), как natively.

## Устройство

P = `C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01`; стейдж `cold-tp140` (= selfbuild a09 среза 302 перед
правками), вариант `variants/tp165`, кандидаты `tp165-changed-aNN.list/.sha256`, манифесты стейджа
`source-tp165-aNN.sha256`. Tool среза `tool165a` (`cold-tp140/tool165a/lmxtool-tool.exe`,
`9402afffc4115807a16e1bcb63c63a34f5eeaf44a6646066a23f6707c859ecc0`) собран `rebuild tool` кортежа boot164a
([tp165-tool](records/pins/tp165-tool.command), [терминал](records/pins/tp165-tool-a01.terminal.txt),
[лог](records/pins/tp165-tool-a01.log), 19:48:06→19:49:25Z, 0 отказов) — только `tools/build.lm2` (a01), потому что
новый флаг заголовка P0 пишет tool; frontend среза — `build-frontend` новым tool с G2 frontend boot164a
([tp165-fe](records/pins/tp165-fe.command)); ядро не менялось — runtime G2 boot164a (`driver.o`
`f5eaed6f…`, `driver-observe.o` `4e3fc11a…`).

| Кандидат | Изменено | Сборка | Итог |
| --- | --- | --- | --- |
| a01 | tools/build.lm2 | tool165a | собран, smoke 0 |
| a02 | + P0, связыватель, is_asgn, проверка; 5 фикстур на `:=`, 5 новых, реестр, inputs 244 | fe165a `61be4962…` (19:51:17→19:54:59Z) | все трансляции отказали на предефе `convert.lm2:4` («a table column needs a name»): части `table:` шли через связыватель по голове |
| a03 | + режим by_head связывателя | fe165b `4bda5669…` (20:00:11→20:03:51Z) | f165b: 7/10; отказы — `node\f0(x: 3; y: 4)` в named_actuals_selected:330 (не переведён), `target := two` связан как вызов (`more arguments than target has formals`), `zz := 5` объявил поле |
| a04 | + := не объявляет и не вызывает (local_absent_def, bind_node_content, scan_actuals_value, head_is_call); операнд merge «имя: тип: значение»; фикстура merge_named_field_operand; :330 → `:=`; inputs 245 | fe165c (20:08:06→20:10:5xZ) | C не скомпилирован: `implicit declaration of function lm_compiler_named_typed_field_kind` — новая функция helpers не экспортирована (заголовок модуля пишет tool по списку `frontend_names` в tools/build.lm2) |
| a05 | + := в теле Structure не объявляет (ns_nested_def, ns_bind_item); фикстура assign_in_structure_refused; inputs 246; хелпер перенесён в конец l2_frontend_helpers.lm2 и экспортирован (`frontend_names[259]`, 260 имён) | tool165b `850707ed…`, fe165d `6ed6087c…` (20:14:5xZ→20:18:xxZ) | f165d: 7/12; отказы — `node\f0(x: 3; y: 4)` в named_actuals_selected:338 (не переведён); `target := two` отвергнут проверкой удержанного вызова («more arguments than target has formals»); `zz := 5` в теле метода и в теле Structure транслировался — скан сделал свободное имя скрытым входом, а проверка спрашивала `l2_param_find` (формалы + динамические входы); `merge(Args; (a: int: 5))` — «a merge operand field has another type than the model field of its name»: карта слотов брала род и слово типа у внешнего Frame (`a`) |
| a06 | + проверки удержанного вызова (`lm_compiler_check_held_call`, `rw_mad_call`) не читают Frame `:=`; :338 → `:=`; проверка `:=` спрашивает объявленные формалы, видимое поле, слот, локал метода и активацию хоста вложенного метода (`lm_compiler_assign_host_place`), не `l2_param_find`; карта слотов результата (`lm_compiler_mrs_build`) берёт род и слово типа операнда «имя: тип: значение» у внутреннего Frame | tool165b, fe165e `04d2c503…` (20:37:10→20:40:56Z) | f165e: 11/12; отказ — assign_known:51:15 «more arguments than target has formals» на `target := two`; gdb на fe165e (точка `lm_compiler_error_words`, [receipt](records/pins/gdb303-fe165e-assign_known.txt)): `lm_compiler_rw_stmt_content` → `lm_compiler_rw_call_values` — диспетчер программы обходчика («A call statement») спросил `l2_call_head_method` для головы `target`, а для привязки, держащей callable, ответ — метод, который она держит сейчас |
| a07 | + диспетчер программы обходчика не спрашивает `l2_call_head_method` для Frame `:=` — запись падает в store привязки (`lm_compiler_method_pointer_candidate`), как natively | tool165b, fe165f `ca818e96…` (l1trans `2e070f9d…`, l2_libc `af9fdae3…`; 20:52:25→20:55:50Z) | f165f: 12/12, 72 проверок, native и forced, оба корня (20:56:00→20:57:11Z) |

## Ревью Codex 303 (CODEX-FABLE-303-REVIEW-20261107T222601684Z-01, [копия](records/pins/CODEX-FABLE-303-REVIEW-20261107T222601684Z-01.txt))

Четыре пункта после публикации 35d9f80b; гипотезы измерены на опубликованном кандидате (fe165f) до правок, фокус
[f165k](records/pins/f165k.tsv) ([лог](records/pins/tp151-probe-f165k.log), [терминал](records/pins/tp151-probe-f165k.terminal.txt)):

1. Точное имя (backtick) перед `:=` — подтверждено: ветвь `:=` в P0 требовала `quoted_head = 0`; `` `x` := 5 `` — «parse
   error 6 at 10:9: unexpected character in field list», `` `zz` := 5 `` — то же (4:10). Правка a12: условие ветви без
   требования к написанию головы (скан `:=` начинается после кавычечного токена — экранирование внутри токена сохранено).
   Quoted-only имени у транслятора нет: `lm_compiler_exact_ident` принимает в кавычках лишь ident-word, а
   `lm_compiler_bind_admit` отказывает точному идентификатору как имени привязки («an exact identifier cannot name a
   binding yet») и слову языка — предел до 303, не этого среза; проверены `` `x` ``, `` `x`:=7 ``, `` tst(`a` := 5) ``,
   `` tst(`a`:=5) `` для объявленного x и неизвестный `` `zz` := 5 `` (фикстуры `assign_quoted`,
   `assign_quoted_unknown_refused`).
2. `zz := int: 5` как объявление — подтверждено во всех трёх местах и в операнде merge: `lm_compiler_declaration` даёт
   форме `zz := int: 5` вложенное типизированное объявление (resolve :888), `lm_compiler_own_decl_ty` ≠ 0, и
   `lm_compiler_collect_decls` открывала ряд own; в теле Structure `lm_compiler_ns_primitive_field` объявлял поле; в merge
   `lm_compiler_named_typed_field_kind` делал поле из `(zz := int: 5)`; `lm_compiler_is_asgn` для такой формы — 0 (объявление),
   так что проверка `:=` её не спрашивала. Все четыре отрицательные фикстуры транслировались (f165k). Правка a12:
   `lm_compiler_assign_new_name` — Frame `:=`, чьё имя ещё не место (own, формал, захват хоста), не открывает ряда в
   `collect_decls`; `ns_primitive_field` и `named_typed_field_kind` не читают Frame `:=`; проверка спрашивает Frame `:=` и в
   форме вложенного объявления (`own_decl_ty ≠ 0`). Положительный контроль `x := int: 5`, `s := size_t: 3U`, `y := int: 9`
   на корне (`assign_typed_known`) проходил и до правки (общий допуск повторной типизированной записи сохранён).
3. `one := two` внутри метода — переписано как предел реализации (`colon_hidden_write`, запись скрытого входа без значения
   активации), не правило языка и не вопрос автору: «Открыто» этой записи, реестр дефектов, заметки 4.2, current.md.
4. Ссылки на steps/free-names.md §7 переписаны: история механизма, норма — единое разрешение головы и книга (комментарий
   проверки в emit.lm2, заметки 4.2 RU/EN, п. 6 «Проекта»).

| Кандидат | Изменено | Сборка | Итог |
| --- | --- | --- | --- |
| a11 | + 7 фикстур ревью (без рядов и inputs) | — (fe165f) | f165k на fe165f: `assign_typed_known` 6/6; `assign_quoted`/`assign_quoted_unknown_refused` — parse error; четыре отрицательные `zz := int: 5` транслировались |
| a12 | + P0 без `quoted_head = 0`; `lm_compiler_assign_new_name` в collect_decls; `ns_primitive_field`, `named_typed_field_kind` не читают `:=`; проверка `:=` и для формы объявления; ряды в full-suite.tsv (130), inputs 254 | fe165g `188f2bdf…` | f165n ([лог](records/pins/tp151-probe-f165n.log)): 110 проверок прошли, в том числе `zz := int: 5` в методе и на корне отвергнуты иглой `:=`, `(zz := int: 5)` в merge — «not lowered yet», `assign_typed_known` 7; отказы: `` `x` := 5 `` и `` `zz` := 5 `` — «unsupported body» (P0 даёт Frame `:=`, но транслятор не классифицирует голову-точное имя — предел до среза, см. п. 1); `zz := int: 5` в теле Structure — «internal: a named Structure's item is neither a field nor a statement» (`lm_compiler_ns_body_stmt_here` не считала форму объявления оператором) |
| a13 | + `ns_body_stmt_here`: Frame `:=` — оператор тела в любой форме; фикстуры точных имён заменены: `named_assign_quoted` (положительная: связыватель именует формал по payload `` `a` ``), `assign_quoted_head_limit` и контроль `quoted_colon_head_limit` (предел транслятора «unsupported body», одинаковый до и после среза); `assign_quoted`, `assign_quoted_unknown_refused` удалены; inputs 255, suite 131 рядов | fe165h `03fbf9e2…` | f165p ([лог](records/pins/tp151-probe-f165p.log)): 122 проверок прошли — `zz := int: 5` в теле Structure отвергнут иглой `:=`, оба предела точных имён говорят «unsupported body»; отказ: `named_assign_quoted` — транслировался, но R0 остановлен непойманным броском в обоих исполнителях: таблица идентификаторов единицы (`lm_compiler_unit_id`) интернировала написание с кавычками — `` lmx_ids_code("`a`", 3U) `` — и код имени не совпал с кодом формала `a` у связывателя ядра ([p.lm1](records/tp151-probe/f165p/named_assign_quoted-native/p.lm1), [run-root0](records/tp151-probe/f165p/named_assign_quoted-native/run-root0.log)) |
| a14 | + `lm_compiler_unit_id` берёт payload точного идентификатора: `` `a` `` и `a` — один код (грамматика: одно имя) | fe165i `765a8404…` | — |
| a15 | комментарий фикстуры `named_assign_quoted` дополнен (таблица идентификаторов); транслятор без изменений — fe165i остаётся frontend кандидата | — (fe165i) | f165q: 21/0, 126 проверок, native и forced, оба корня (22:57:02→22:58:18Z; [лог](records/pins/tp151-probe-f165q.log), [терминал](records/pins/tp151-probe-f165q.terminal.txt)); реестр r303c — байты `full-suite.tsv` после a13 ([копия](records/pins/registry303-e.tsv), `4b00e7bd…`): 130 рядов, 0 отказов, 1048 проверок, 22:58:28.01→23:13:37.22Z (909.21 с), кортеж tool165b, fe165i `765a8404…`, runtime G2 boot164a ([лог](records/pins/tp151-probe-r303c.log), [терминал](records/pins/tp151-probe-r303c.terminal.txt)) |

Решение автора о whole-arguments пришло во время этого follow-up (22:37–22:42Z, три реплики — [журнал](../../../LMX_blog/2026-11-07.md);
копии [1](records/pins/CODEX-FABLE-AUTHOR-WHOLE-ARGUMENTS-20261107T223737232Z-01.txt), [2](records/pins/CODEX-FABLE-AUTHOR-STRUCTURE-AMBIGUITY-20261107T224133372Z-01.txt),
[3](records/pins/CODEX-FABLE-AUTHOR-NO-SPECIAL-UNFOLD-20261107T224208236Z-01.txt)): первичные документы обновлены (книга RU/EN — абзац
whole-arguments, реестр — CALL-WHOLE-ARGUMENTS-STRUCTURE и MERGE-OPERAND-FORMS, заметки 4.2, current.md, README), реализация —
следующий срез; см. «Границы».

## Результаты

| Шаг | Результат | Receipts |
| --- | --- | --- |
| Фокус f165f | 12 рядов `:=` ([f165d.tsv](records/pins/f165d.tsv): 7 новых фикстур и 5 переведённых на `:=`), tool165b, fe165f, runtime G2 boot164a: 12/0, 72 проверки, native и forced, оба корня (20:56:00→20:57:11Z) | [терминал](records/pins/tp151-probe-f165f.terminal.txt), [лог](records/pins/tp151-probe-f165f.log) |
| Реестр на кандидате a07 | весь поддерживаемый реестр — байты `selfbuild/tests/full-suite.tsv` ([копия](records/pins/registry303-b.tsv), `cc5d97b6…`): 121 ряд, 0 отказов, 994 проверки, 20:57:19.97→21:12:35.54Z (915.57 с); кортеж tool165b `850707ed…`, fe165f `ca818e96…`, driver `f5eaed6f…`, observe `4e3fc11a…` (runtime G2 boot164a — ядро срезом не менялось) | [терминал](records/pins/tp151-probe-r303a.terminal.txt), [лог](records/pins/tp151-probe-r303a.log) |
| Фокус f165j (a10) | 13 рядов ([f165h.tsv](records/pins/f165h.tsv): + `assign_method_name_refused`; `assign_known` расширен перепривязкой формала-callable `cb := two`), тот же кортеж: 13/0, 78 проверок (21:34:49→21:36:00Z) | [терминал](records/pins/tp151-probe-f165j.terminal.txt), [лог](records/pins/tp151-probe-f165j.log) |
| Реестр на кандидате a10 | байты `selfbuild/tests/full-suite.tsv` после a10 ([копия](records/pins/registry303-c.tsv), `fb414313…`): 122 ряда, 0 отказов, 1000 проверок, 21:43:33.29→21:58:47.62Z (914.33 с); тот же кортеж (a08–a10 меняли только фикстуры и списки, frontend fe165f = a07) | [терминал](records/pins/tp151-probe-r303b.terminal.txt), [лог](records/pins/tp151-probe-r303b.log) |
| Стейдж bootstrap | `steps` рабочего tool boot164a по [boot165a-prepare](records/pins/boot165a-prepare.tsv) ([рецепт](records/pins/boot165-prepare.command)): 5/0, стейдж `cold-boot165a` 247/0, source-boot165a = source-tp165-a10 (`4adc073c…`), 21:59:02.04→21:59:04.38Z | [лог](records/pins/boot165a-prepare.log), [терминал](records/pins/boot165a-prepare.terminal.txt) |
| Whole boot165a | 21:59:20.00→22:10:26.92Z, BootstrapExit 0, 666.92 с; `BOOTSTRAP quick 0 failures`; smoke 9/0 в обеих генерациях; G0 — tool165b стейджа `850707ed…` (`tools/build.lm2` изменён срезом: флаг заголовка P0 и экспорт хелпера), предыдущий frontend — G2 boot164a `0213ad79…`; G1: l2trans `7e8f2c6c…`, l1trans `cab9e8a6…`, driver.o `f5eaed6f…`, tool `12fda71d…`; детачированный запуск pwsh 7 ([boot165-quick](records/pins/boot165-quick.command), [boot165-detached](records/pins/boot165-detached.command)) | [терминал](records/pins/boot165a-quick.terminal.txt), [лог](records/pins/boot165a-quick.log), [verify](records/pins/boot165a-quick-verify.log), [launcher](records/pins/boot165a-detached.terminal.txt) |
| Приёмка `checks` | рабочий tool boot164a, [список](records/pins/boot165a-check.tsv) ([рецепт](records/pins/checks303.command)): 38/0 (22:10:52.77→22:10:53.15Z) — стейдж 247/0; записи producers G1 и G2 и запись сборки G2 замкнуты, без script host; G1 и G2: `exe-same` l2trans, l1trans, tool, `same` l2_libc.o, driver.o, driver-observe.o, L1 и C tool, consumed-inputs; рабочий tool и bundle = G2; runtime реестра (G2 boot164a) = G2 runtime boot165a байт в байт; fe165f = G2 по `exe-same`, l2_libc `same` | [лог](records/pins/boot165a-check.log), [терминал](records/pins/boot165a-check.terminal.txt) |
| Самотест G2 tool | G2 tool boot165a `720ab6ec…` (= рабочий bundle), ребёнок `tool153a-child` `40c935bc…`, рецепт [tp152-selftest](records/pins/tp152-selftest.command): `SELFTEST 0 failures` (12 строк `FAIL` — ожидаемые отказы негативных проверок схемы, как у 298–302), 22:11:11.96→22:11:23.96Z | [терминал](records/pins/tp152-selftest-g303.terminal.txt), [лог](records/pins/tp152-selftest-g303.log) |
| Посадка | `steps` рабочего tool boot164a по [land303](records/pins/land303.tsv) ([рецепт](records/pins/steps303.command)): 9/0, `selfbuild/inputs.sha256` = source-tp165-a10 `4adc073c…` (247 входов), G2 consumed 311/0, 22:11:38.20→22:11:39.62Z | [лог](records/pins/land303.log), [терминал](records/pins/land303.terminal.txt) |

Follow-up ревью (кандидат a15, те же рецепты с буквой b):

| Шаг | Результат | Receipts |
| --- | --- | --- |
| Фокус f165q | 21 ряд ([f165o.tsv](records/pins/f165o.tsv)): 21/0, 126 проверок (22:57:02→22:58:18Z) | [терминал](records/pins/tp151-probe-f165q.terminal.txt), [лог](records/pins/tp151-probe-f165q.log) |
| Реестр r303c | байты `full-suite.tsv` при a13–a15 ([копия](records/pins/registry303-e.tsv), `4b00e7bd…`): 130/0, 1048 проверок, 22:58:28.01→23:13:37.22Z (909.21 с); tool165b, fe165i `765a8404…`, runtime G2 boot164a | [терминал](records/pins/tp151-probe-r303c.terminal.txt), [лог](records/pins/tp151-probe-r303c.log) |
| Стейдж bootstrap | [boot165b-prepare](records/pins/boot165b-prepare.tsv): 5/0, `cold-boot165b` 255/0, source-boot165b = source-tp165-a15 (`a82f1741…`), 23:13:49.48→23:13:51.73Z | [лог](records/pins/boot165b-prepare.log), [терминал](records/pins/boot165b-prepare.terminal.txt) |
| Whole boot165b | 23:14:00.13→23:25:02.05Z, BootstrapExit 0, 661.92 с; `BOOTSTRAP quick 0 failures`; smoke 9/0 в обеих генерациях; G0 — tool165b, предыдущий frontend — G2 boot164a | [терминал](records/pins/boot165b-quick.terminal.txt), [лог](records/pins/boot165b-quick.log), [verify](records/pins/boot165b-quick-verify.log), [launcher](records/pins/boot165b-detached.terminal.txt) |
| Приёмка `checks` | [boot165b-check](records/pins/boot165b-check.tsv): 38/0 (23:25:15.23→23:25:15.58Z) — стейдж 255/0, записи producers замкнуты, G1 = G2 (`exe-same`/`same`), рабочий tool и bundle = G2, runtime реестра = G2 runtime boot165b байт в байт, fe165i = G2 по `exe-same` | [лог](records/pins/boot165b-check.log), [терминал](records/pins/boot165b-check.terminal.txt) |
| Самотест G2 tool | G2 tool boot165b `c5de7e8f…`, ребёнок `tool153a-child` `40c935bc…`: `SELFTEST 0 failures` (12 ожидаемых строк `FAIL`), 23:25:33.02→23:25:44.97Z | [терминал](records/pins/tp152-selftest-g303b.terminal.txt), [лог](records/pins/tp152-selftest-g303b.log) |
| Посадка | [land303b](records/pins/land303b.tsv): 9/0, `selfbuild/inputs.sha256` = source-tp165-a15 `a82f1741…` (255 входов), G2 consumed 311/0, 23:25:59.43→23:26:00.87Z | [лог](records/pins/land303b.log), [терминал](records/pins/land303b.terminal.txt) |

Кортеж follow-up: G2 boot165b — tool `c5de7e8fd88f50f79d075cc48e4571cb0d42271f59f99b4a2c85edb98fa2294d` (= рабочий `quick165b/lmxtool.exe`),
l2trans `0c28700102ebb3a7…`, l1trans `cf755cbcb146b1de…`, l2_libc `af9fdae3…`, driver `f5eaed6f…`, observe `4e3fc11a…` (= G2 boot164a: ядро не
менялось); G1: l2trans `88e50f62…`, l1trans `d015417d…`, tool `fc4c8ada…`, driver.o `f5eaed6f…`; кандидат — tool165b, fe165i
`765a8404da0db2abf…` (= G2 l2trans по `exe-same`). Source 255 входов, manifest `a82f1741f824f240f3578a675ef97cb7fae7783779774192ce61e91f02ab0ce8`
(source-tp165-a15 = source-boot165b).

Кортеж: G2 boot165a — tool `720ab6ec4506dfcf0b17d961dcccb45ace932225d95cc91ad3b67e26c46d6b1d` (= рабочий `quick165a/lmxtool.exe`),
l2trans `b00796ad9c1752eb7d147127dbb3b5014f2fd654900cd59c90e0da72cd1f3e75`, l1trans `558686352111ab033a6cbdea3be5711ac968d421e9ffb1845f933f6280bdbd78`,
l2_libc `af9fdae33655f8e6235310720787102921450f0f88f9b7bb2f365d372f553d37`, driver `f5eaed6ff0c8ccfdd27a3198f3e9c7ff70a7743751a311f0809a26b674eba8d8`,
observe `4e3fc11a68706feab90af250a594212451abaff260a76921ce7c81c13560ada6` (driver и observe = G2 boot164a: ядро не менялось);
кандидат среза — tool165b `850707ed202034e22b9b9e316a2ec4c4767f17b0061f051c118f723f7348d917`, fe165f `ca818e96301396575de01b2a896d70e53bed9b1a9814f23eec4bdff370b5bbf0`
(= G2 l2trans по `exe-same`). Source 247 входов, manifest `4adc073c1205b05fe4dc6b3a3f25ae4a49e3b0c44a15b03708fad6515e541130`
(source-tp165-a10 = source-boot165a = `selfbuild/inputs.sha256`).

## Мутанты

Ручная правка файла стейджа `cold-tp140/src/l2src/l2_frontend_lower.lm2` (инструмент Edit), сборка frontend tool165b
([tp165-fe2](records/pins/tp165-fe2.command); хэш правленого файла — в терминале сборки), 12 рядов фокуса
([f165d.tsv](records/pins/f165d.tsv)) рецептом [tp151-probe](records/pins/tp151-probe.command) на мутантной сборке; после
каждого — возврат файлов стейджа из варианта a07 и проверка всего стейджа ([mut303-restore](records/pins/mut303-restore.tsv),
[рецепт](records/pins/mut303-restore.command); терминалы с хэшами до и после).

| Мутант | Правка | Итог |
| --- | --- | --- |
| m1 (fe165m1, lower.lm2 `4e2ca011…`, l2trans `d1d74f93…`) | связыватель снова именует формал по совпадению головы любого Frame (условие `by_head != 0 || флаг ASSIGN` снято) — механизм NAMED-BINDING-BY-HEAD восстановлен | убит: 4 отказа из 72 — `named_assign_actuals` native и forced, оба корня, выход 83 вместо 7 (`tst(a: 5)` связал формал, `a` не вызван) ([лог](records/pins/tp151-probe-m303a.log), [терминал](records/pins/tp151-probe-m303a.terminal.txt), [run-root0](records/tp151-probe/m303a/named_assign_actuals-native/run-root0.log)); возврат [m1](records/pins/mut303-restore-m1.terminal.txt) 246/0 |
| m2 (fe165m2, lower.lm2 `aa316daf…`, l2trans `a340e9a6…`) | ветвь `:=` функции `lm_compiler_is_asgn` снята — роль головы как вызываемого (`l2_call_head_method`) снова решает, присваивание ли это | **пережил** 12 рядов a07 (12/0, [лог](records/pins/tp151-probe-m303b.log)): native и обходчик классифицируют `:=` через `lm_compiler_head_is_call` и исключения связывания, а не через `is_asgn`, и `target := two` на корне единицы — присваивание и без ветви (метод там не текущий); **пережил** и a08 — `cb := two` формала-callable внутри метода ([f165g](records/pins/tp151-probe-f165g.log) 12/0 на кандидате, [m303b2](records/pins/tp151-probe-m303b2.log) 12/0 на мутанте): формал — место, store формала идёт эмиттером независимо от `is_asgn`. Убит новой фикстурой `assign_method_name_refused` (a09→a10: `one := two` внутри метода — имя метода разрешается в callable-поле единицы, которое метод писать не может; кандидат говорит существующий локализованный отказ «writing a hidden input that has no activation value is not supported yet», [f165j](records/pins/tp151-probe-f165j.log) 13/0): на мутанте отказ иной — «root operation not walkable yet: a reference assignment» (диспетчер программы обходчика), в native и forced ([лог](records/pins/tp151-probe-m303b4.log), [терминал](records/pins/tp151-probe-m303b4.terminal.txt), [native](records/tp151-probe/m303b4/assign_method_name_refused-native.log)); возврат [m2](records/pins/mut303-restore-m2.terminal.txt) 246/0 (до a08) |
| m3 (fe165m3, lower.lm2 `aeabd021…`, l2trans `9bfda2b4…`) | связыватель не отвергает имя `:=`, которого нет у формалов (`is not an argument of` снято) — такой Frame идёт позиционным значением | убит: 2 отказа из 78 — `named_assign_unknown_refused` native и forced: отказ иной, «unknown method» на `zz` ([лог](records/pins/tp151-probe-m303c.log), [терминал](records/pins/tp151-probe-m303c.terminal.txt), [native](records/tp151-probe/m303c/named_assign_unknown_refused-native.log)); возврат [m3](records/pins/mut303-restore-m3.terminal.txt) 247/0 |

Три из трёх убиты; m2 — только новым рядом `assign_method_name_refused` (с a09 входит в поддерживаемый реестр), после того как
пережил два списка: классификация `:=` у эмиттеров идёт через `lm_compiler_head_is_call` и исключения привязки, а ветвь
`lm_compiler_is_asgn` наблюдаема только там, где голова — вызываемое без места (имя метода внутри метода).

Естественные свидетели без отдельной сборки: fe165d (a05) — проверка `:=` через `l2_param_find` пропускает `zz := 5` в
теле метода и в теле Structure (оба отказных ряда транслировались, [failures](records/tp151-probe/f165d/failures.tsv)) и
карта слотов без рода внутреннего Frame отвергает `merge(Args; (a: int: 5))`; fe165e (a06) — диспетчер программы
обходчика без исключения `:=` вызывает держимый метод (`assign_known`, [failures](records/tp151-probe/f165e/failures.tsv),
[gdb](records/pins/gdb303-fe165e-assign_known.txt)).

## Границы

- Вся структура аргументов из одной Structure (`mytest(merge(mytest\args; (a: int: 5)))` = 35, та же Structure в
  переменной) — удержана: столкновение нормы whole-arguments с нормой «Сигнатура не исполняется» (`mytest(c)` подаёт
  саму Structure непримитивному формалу) разбирает автор по вопросу Codex (CODEX-FABLE-WHOLE-ARGUMENTS-HOLD-20261107T195808558Z-01,
  [копия](records/pins/CODEX-FABLE-WHOLE-ARGUMENTS-HOLD-20261107T195808558Z-01.txt); мой вопрос —
  [FABLE-Q-WHOLE-ARGUMENTS](records/pins/fable-q-whole-arguments.txt)). Операнд `merge` «часть вызываемого» `f\args`
  (MERGE-OPERAND-FORMS) — вместе с ним. Ответ автора получен 2026-11-07 22:37Z (CODEX-FABLE-AUTHOR-WHOLE-ARGUMENTS-20261107T223737232Z-01,
  [копия](records/pins/CODEX-FABLE-AUTHOR-WHOLE-ARGUMENTS-20261107T223737232Z-01.txt); дословно — в [журнале](../../../LMX_blog/2026-11-07.md)):
  удержание снято. Пересказ Codex этого ответа как «принудительного раскрытия единственной позиционной Structure» отозван
  самим Codex по двум дальнейшим репликам автора (CODEX-FABLE-AUTHOR-STRUCTURE-AMBIGUITY-20261107T224133372Z-01,
  CODEX-FABLE-AUTHOR-NO-SPECIAL-UNFOLD-20261107T224208236Z-01; [копии](records/pins/), дословно — в журнале): позиционная
  передача одной Structure даёт ошибку только из-за неопределённости — когда определены два метода, один с одной
  Structure в аргументах, другой с полным набором её полей; «все остальные случаи легко вычисляются и не надо ничего
  специально раскрывать»; именованная подача `f(v := s)` — отдельный случай. Реализация (`f\args` как операнд `merge`,
  `mytest(merge(mytest\args; (a: int: 5)))` = 35 через общее сопоставление, та же Structure через переменную, отказ по
  неоднозначности, именованный контроль) — следующий срез, после сверки с действующим механизмом разрешения вызываемых.
- Составные присваивания и `**` (COMPOUND-ASSIGN-AND-POWER, план M5) — не этим срезом.

## Документы

Записаны: [реестр дефектов](../../defects.md) — NAMED-BINDING-BY-HEAD и ASSIGN-KNOWN-OPERATOR закрыты срезом 303 (абзацы
«Срез 303»), MERGE-OPERAND-FORMS — формы «имя: тип: значение» закрыты, `f\args` удержано, CALL-WHOLE-ARGUMENTS-STRUCTURE —
удержано до решения автора; абзац 303 в [steps/current.md](../../current.md); [selfbuild/README.md](../../../selfbuild/README.md) —
247 входов и абзац Slice303; [план M5](../../../next_core_tasks_v3.md#m5-assign-operators) — статус `:=` реализован, составные
OPEN; строка 40 [чек-листа](../../../next_core_tasks_v3_checklist.md); [заметки о реализации](../../../docs/implementation-notes.ru.md#assign-named-merge)
4.2 RU и EN — что сделано срезом и что удержано; книга [provenance/semantics-book.md](../../../provenance/semantics-book.md)
(RU и EN, раздел whole-arguments) — фраза о статусе: `:=` и краткая форма реализованы, пример `merge` по-прежнему
отказывает, удержан; generated docs `docs/LMX_semantics.ru.md`/`.en.md` перерисованы и проверены ([docs303-render](records/pins/docs303-render.tsv),
[лог](records/pins/docs303-render.log), [терминал](records/pins/docs303-render.terminal.txt); грамматика без изменений — `:=` в §21 записан
срезом 302n, статус токенов составных присваиваний прежний). Нормы книги и грамматики срез не менял. Docs check языка над
индексом git ([рецепт](records/pins/checks303.command)): первый проход ([docs303-check-a](records/pins/docs303-check-a.tsv),
[лог](records/pins/docs303-check-a.log)) — 93 находки DOCS-EOL: рабочие копии логов tool в records/ были CRLF; после переписи
копий из индекса (LF; списки [crlf303-1](records/pins/crlf303-1.list), [crlf303-2](records/pins/crlf303-2.list)) второй проход
(`P/pins/docs303-check-b.*`, не архивирован — receipts после последнего прохода архива) — 0 отказов: 35 парных глав семантики,
27 парных разделов грамматики, 615 импортированных файлов, ссылки, LF в индексе для всех отслеживаемых файлов.

Follow-up ревью: [журнал](../../../LMX_blog/2026-11-07.md) — раздел «Вся структура аргументов: единственная позиционная Structure»
с тремя дословными репликами автора и отозванным пересказом Codex; реестр — абзацы «Решение автора» у CALL-WHOLE-ARGUMENTS-STRUCTURE,
статусы MERGE-OPERAND-FORMS и ASSIGN-KNOWN-OPERATOR (предел записи callable-поля единицы из метода), запись IDENTIFIER-CODES (payload
точного идентификатора); заметки 4.2 RU/EN; current.md; README (255 входов); книга RU/EN — абзац whole-arguments (уточнения автора и
статус примера), generated docs перерисованы и проверены ([docs303b-render](records/pins/docs303b-render.tsv), [лог](records/pins/docs303b-render.log),
[терминал](records/pins/docs303b-render.terminal.txt)).

## Провенанс

Правки исходников selfbuild, стейджа (мутанты) и документов — инструменты Edit и Write; списки `tp165-changed-aNN.list`,
`tp165-prepare-aNN.tsv`, `f165*.tsv`, `registry303-*.tsv`, `mut303-restore.tsv`, `boot165a-*.tsv`, `land303.tsv`,
`docs303-*.tsv`, `records303.list`, `allow303-1.list` — `printf`/`cp`/`sed` по точным строкам; рецепты `.command` — heredoc.
Каждый список исполнен `steps`/`checks`/`suite` без отказа строки; каждый запуск — из своего нового каталога
(`P/<имя>-run`). Возвраты после мутантов — `stage-copy` из варианта a07/a10 с проверкой всего стейджа. Диагностика отказа
fe165e (`target := two`) — gdb из состава mingw на готовой сборке l2trans с точкой останова в `lm_compiler_error_words`
([receipt](records/pins/gdb303-fe165e-assign_known.txt); командный файл и выход — в scratchpad, стейдж не писался): ручное
чтение существующей сборки, не новая проба. Кандидаты a08–a10 меняли только фикстуры и списки: frontend fe165f (a07) и
tool165b (a05) — сборки кандидата. Архив — два прохода `steps` ([arch303-1](records/pins/arch303-1.tsv): манифест 178 путей P
по [records303.list](records/pins/records303.list), байтовые копии в [records](records), проверка копий 178/0;
[arch303-2](records/pins/arch303-2.tsv): receipts первого прохода и docs check, [evidence.list](evidence.list) обоих проходов,
[evidence.sha256](evidence.sha256) против P). Логи tool в P — CRLF (перенаправление pwsh); git держит их копии с LF, поэтому
копии первого прохода после коммита с манифестом байт в байт не сравниваются (как у 302 и шага операторов).

## Отклонения

1. Первый запуск tool165a не стартовал: pwsh получил путь `/c/...` (`Could not find a part of the path C:\c\...`);
   повтор тем же рецептом с путём `C:/...`, receipts первого запуска не создавались.
2. Кандидат a02 не транслировал ни одной программы (режим by_head не был учтён): записано в таблице, receipts
   `tp151-probe-f165a.*` сохранены.
3. Кандидат a04: frontend не скомпилирован — новая функция модуля helpers требует записи в компилируемый в tool список
   экспортов (`frontend_names`, tools/build.lm2) и нового tool; функция перенесена в конец модуля (нумерация параметров
   заголовка не сдвигается), экспортирована, tool пересобран (tool165b).
4. Проверка `:=` в a05 спрашивала `l2_param_find` и пропускала `zz := 5` (скан уже сделал `zz` скрытым входом, как для
   `x: v`): оба отказных ряда транслировались (f165d). В a06 проверка спрашивает объявленные формалы и места, не входы
   сбора; скан не менялся — для отвергаемой программы его вход безразличен.
5. Отказ `target := two` в a06 (f165e) шёл не из проверки и не из native-эмиттера, а из диспетчера программы обходчика
   (рутина `rw_methods_count` строит её и в native-режиме): найден gdb, исправлен в a07.
6. Мутант m2 пережил два списка (a07, a08 с `cb := two` формала-callable): ветвь `:=` в `lm_compiler_is_asgn` не
   наблюдаема на этих формах. Добавлен ряд `assign_method_name_refused` (a09); его первая игла была написана по моему
   ожиданию («:= writes a place already known…», строка 13) — трансляция говорит существующий локализованный отказ
   «writing a hidden input that has no activation value is not supported yet» (имя метода разрешается в callable-поле
   единицы), а правка комментария сдвинула оператор на строку 14; игла исправлена по фактическому отказу (a10), после чего
   m2 убит (на мутанте отказ иной).
7. Первая копия реестра `registry303-a.tsv` содержала только ряды `full-suite.tsv` без его комментариев; реестр шёл по
   `registry303-b.tsv` (байты файла при a07) и `registry303-c.tsv` (байты при a10, 122 ряда — один пустой не-комментарий
   считается строкой списка, не рядом).
8. Расширение `assign_known` (a08, `swap`) и ряд `assign_method_name_refused` (a09–a10) добавлены после реестра a07:
   реестр прогнан заново на a10 (122/0), frontend и tool кандидата не менялись.

## Открыто

- Вся структура аргументов из одной Structure и операнд `merge` «часть вызываемого» `f\args` — после решения автора по
  вопросу Codex (CALL-WHOLE-ARGUMENTS-STRUCTURE, MERGE-OPERAND-FORMS).
- Имя метода как левая часть `:=` внутри метода (`one := two`, фикстура `assign_method_name_refused`) — зафиксированное
  ограничение реализации, не правило языка (ревью Codex 303, п. 3): имя разрешается в callable-поле единицы, видимое методу,
  и `lm_compiler_colon_hidden_write` отказывает записи скрытого входа без значения активации («writing a hidden input that
  has no activation value is not supported yet») — тем же пределом, что и для `x: v`. Книга (:511, :516) допускает запись
  любого известного места, включая ссылку на Structure метода; поэтому ASSIGN-KNOWN-OPERATOR закрыт для мест с значением
  активации — локал, формал, поле по пути, ссылка на метод в привязке (`target := two`), поле единицы с корня, — а запись
  callable-поля единицы из метода остаётся OPEN как предел реализации (запись скрытого входа), без вопроса автору.
- Приоритет `:=` среди операций, значение записи как выражения, составные присваивания и `**` — план M5
  (COMPOUND-ASSIGN-AND-POWER).
- Остаток IDENTIFIER-CODES (внутренние сравнения транслятора, транслятор L1, AXBY, тесты RESULT) — следующие срезы.
