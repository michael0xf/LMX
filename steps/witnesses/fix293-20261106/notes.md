# Срез 293 — умолчание формала (FORMAL-DEFAULT)

Опубликован 2026-11-07, Opus. Часть U3 [плана N4-U](../../../next_core_tasks_v3.md). Задание: ответ Codex на результат 292 ([дословно](records/pins/codex-292-review-next.txt), CODEX-OPUS-292-REVIEW-NEXT-20261106-01) — дальше FORMAL-DEFAULT, CALLABLE-PLACE-NAMED-ACTUALS и долги общего построения. Норма — книга ([docs/LMX_semantics.ru.md](../../../docs/LMX_semantics.ru.md)): :467 «Формальный параметр с предусмотренным значением по умолчанию остаётся частью полного принимаемого интерфейса. При отсутствии явно поданного аргумента используется это значение … одноимённое значение в контексте вызывающего не становится поданным аргументом … ноль — тоже поданное значение. Источник дефолта и значение аргумента текущей активации различаются … Нет ни аргумента, ни допустимого дефолта — обычный отказ вызова»; :381 «Сигнатура описывает входы, а не исполняет записанные в ней формы … Если в сигнатуре записано значение, оно является умолчанием»; :455 «`merge` может дать формалу значение по умолчанию»; :485 «Формал вызываемого — не свободное имя его тела: он получает поданный аргумент или своё значение по умолчанию»; ответ Codex на вопросы нормы 285, п. 3 — контракт фактически выбранного вызова «с учётом допустимых умолчаний». Норма и книга не менялись.

P = build2/codex_fix250generationchain01. Копии в [records](records) сделал `lmxtool stage-copy` из P, проверив хэш каждой; оригиналы связаны с [evidence.sha256](evidence.sha256).

## На опубликованном кортеже 292

Пробы P на рабочем tool, G2 frontend и runtime boot154a (рецепт [tp151-probe](../fix289-20261106/records/pins/tp151-probe.command) с параметрами кортежа):

| Проба | 292 |
| --- | --- |
| [p293a](records/cold-tp140/tests/dyn/p293a_static_default.lm2): `d()`, `d(3)`, снова `d()`, `d(0)`, `d(a: 4)`, `e(1)` и `e(x: 2)` при умолчании `y`, `same()` с собственным `a` = 9 | отказ трансляции `d has no argument a` ([f293a](records/pins/tp151-probe-f293a.log)) |
| [p293b](records/cold-tp140/tests/dyn/p293b_dynamic_default.lm2): место `Places\f (int: x 5)`, после записи `g (int: x 8)`, после `g2 (int: x)`, `call: Hw` над `gd (int: a 6)` | отказ трансляции `Places\f has no argument x` ([f293b](records/pins/tp151-probe-f293b.log)) |
| [p293d](records/cold-tp140/tests/dyn/p293d_call_receiver_default.lm2): `call: Hw` над `g` без умолчания и над `gd (int: a 6)` | 92 в обоих режимах и корнях: неявный `call` и там, где умолчание есть ([f293b](records/pins/tp151-probe-f293b.log)) |
| [p293f](records/cold-tp140/tests/dyn/p293f_default_kinds.lm2): умолчания `-1`, `'x'`, `size_t 9` | `neg has no argument a` ([f293c](records/pins/tp151-probe-f293c.log)) |
| [p293g](records/cold-tp140/tests/dyn/p293g_default_expression.lm2): умолчание-выражение `(int: a 2 + 3)`, вызов с аргументом | 7 ([f293c](records/pins/tp151-probe-f293c.log)) |
| [p293e](records/cold-tp140/tests/dyn/p293e_positional_skip.lm2): позиционный пропуск `e(, 2)` (грамматика :287) | `unsupported body`, `atom=` ([f293c](records/pins/tp151-probe-f293c.log)) |
| [p293h](records/cold-tp140/tests/dyn/p293h_expression_default_omitted.lm2), [p293i](records/cold-tp140/tests/dyn/p293i_named_after_omitted.lm2), [p293j](records/cold-tp140/tests/dyn/p293j_callable_formal_default.lm2) | `d has no argument a`, `s has no argument v`, `f has no argument a` ([f293d](records/pins/tp151-probe-f293d.log), [f293e](records/pins/tp151-probe-f293e.log)) |
| [p293c](records/cold-tp140/tests/dyn/p293c_no_default.lm2): `e(y: 3)`, у `x` умолчания нет | `e has no argument x` ([f293a](records/pins/tp151-probe-f293a.log)) |

Первая p293b шла через `Hd\f()` у свободного держателя — форму, которую транслятор не строит (запись 286, «Прямой динамический вызов значения»: `a call path must end at a callable field`); проба переписана на объявленное место и ресивер `call:`. Первая p293j писала callable-формал как `fn: f (...)` (`unknown type`); форма языка — `f(fn: (...) int)`.

## Где было

Карта (агент Explore, только чтение; выводы проверены чтением кода): у каждого написанного формала в части `args` вызываемого — запись из четырёх полей (SOURCE, свидетель, текущее умолчание, собственная запись приёма); ядро уже читало поле 2 (`lmx_walk_current_default`) в двух местах — ресивер `call:` (`lmx_call_selected_structure`) и связыватель выбранного вызова (`lmx_walk_selected_ready_values`, для формала без операнда), но эмиттер поле 2 оставлял пустым («unavailable until produced», `lm_compiler_rw_header_parts`). Связыватель трансляции (`lm_compiler_bind_value_actuals_into`) отказывал каждому формалу без фактического. Native-вызов шёл по всем формалам по рангу записи, обходчик ставил фактические на `5 + ранг`, а суффиксный слот EXEC без операнда ядро помечало FREE — свободный вход, который ищется по цепочке вызывающих.

## Механизм

- **Умолчание — состояние вызываемого, поле 2 его записи формала.** `lm_compiler_rw_formal_default` (в конце l2_frontend_emit.lm2) пишет в поле 2 записи формала ячейку типа формала со значением литерала сигнатуры (`lm_compiler_rw_header_parts`). Что записано, решает `lm_compiler_formal_default_kind` (в конце l2_frontend_lower.lm2): 1 — литерал собственного примитивного числового типа формала (int, char, size_t, unsigned, ulong), строится; 2 — иная записанная форма (имя, выражение, значение Structure-формала) — не строится; -1 — литерал, который не значение типа формала, — отказ там, где сигнатура его пишет. Записанная сигнатура callable-формала — не умолчание.
- **Одно чтение умолчания в ядре.** `lmx_call_formal_default` (lmx_walk_values.lm2; экспорт `walk_value_names[167]` в tools/build.lm2, поэтому новый G0) читает текущее умолчание выбранного вызываемого (`lmx_callable_headers` → `lmx_walk_current_default`), принимает его свидетелем формала как любое значение формала; умолчания нет — `THROWN + NAME_CALL`, неявный `call` до тела. Им пользуются ресивер `call:` (прежний код заменён вызовом), связыватель обходчика и native-вызов.
- **Обходчик.** В `lmx_walk_selected_ready_values` формал выбранного вызываемого, которому вызов не дал операнда (суффиксный слот без операнда или слота нет), берёт умолчание; FREE и цепочка вызывающих остаются только для скрытых входов. Написанный операнд (занятость 1) умолчания не выбирает никогда.
- **Связыватель трансляции.** `lm_compiler_bind_value_actuals(_into)` получил индекс метода: формал без фактического допустим только при построенном умолчании; иначе прежний отказ `… has no argument …`, для формы, которая не строится, — `…: its written default is not a literal value and is not built`, для литерала не того типа — `…: its written default is no value of its type`. Удерживаемые (held) вызовы и таблица передают -1 (умолчаний нет). Поиск фактического по рангу (`lm_compiler_value_actual_written`) берёт только написанные слоты: у пропущенного ранг 0, и он подменял первый написанный.
- **Native-вызов.** `lm_compiler_emit_call_arguments_full` обходит только написанные фактические, затем для каждого пропущенного формала пишет `lmx_call_formal_default(l2_call_arena, l2_c<вызов>, t, @ l2_av[t])` — после фактических, у вызываемого, выбранного до них; `call` — неявный `call` вызывающего (`lm_compiler_emit_implicit_throw`), иной статус — `lmx_call_note_walk_fail`. Вызов машинной функции, пропускающий формал, — отказ трансляции: у неё нет графа (FORMAL-DEFAULT-MACHINE).
- **Кадр обходчика.** `lm_compiler_rw_call_arguments` не ставит операнда пропущенному формалу; контракт вызова (`lm_compiler_rw_call_contract_for`) перечисляет написанные формалы по рангу, затем пропущенные в объявленном порядке, затем скрытые входы: суффиксный слот ядро связывает по имени входа контракта на той же позиции (`lmx_callable_bind_written`), и при именованном фактическом после пропущенного формала (`w(y: 2)`) суффикс принадлежит пропущенным. Без пропусков порядок прежний.
- **Проходы проверки и старая проекция.** Пропущенный формал пропускают проверка фактических (`lm_compiler_check_call_arguments`), ожидание (`lm_compiler_application_actuals_waits`), приём классов callable-формала (`lm_compiler_rw_call_class_receiving`); старый связыватель (`lm_compiler_bind_actuals`, `lm_compiler_bind_call_in`) не даёт ему полей, не считает именованным, а сосед, к которому присоединяется выражение, — следующий формал с полями.

## Свидетели

[tests/dyn/formal_defaults.lm2](../../../selfbuild/tests/dyn/formal_defaults.lm2), native и forced, оба корня:

| Код | Что проверяет |
| --- | --- |
| 81–85 | `d()` = 5, `d(3)` = 3, снова `d()` = 5 (аргумент одной активации — не умолчание), `d(0)` = 0 (ноль — поданное значение), `d(a: 4)` = 4 |
| 86–88 | `e(1)` = 17 и `e(x: 2)` = 27 при умолчании `y`, `e(1, 2)` = 12 |
| 89 | `same()`: собственное `a` = 9 вызывающего — не аргумент `d()`: 5 |
| 90–95 | умолчания `-1`, `'x'`, `size_t 9`, поданные и пропущенные |
| 96, 97 | `w(y: 2)` = 42 (именованный фактический после пропущенного формала), `w(y: 2; x: 1)` = 12 |
| 98–100 | `sub` с умолчанием (`s(u: 1)`), метод Structure по пути `Box\m(j: 5)`, рекурсия `r()` = 6 |
| 101–103 | место `Places\f (int: x 5)`: объявленное — 5; после записи `g (int: x 8)` — 8 (умолчание выбранного вызова); после `g2 (int: x)` — неявный `call` |
| 104, 105 | `call: Hw` над `gd (int: a 6)` — 6, над `g2` — неявный `call` |
| 106, 107 | callable-формал `f(fn: (int: a 5) int)`: `apply(d7)` = 7, `apply(d9)` = 9 — умолчание выбранного, не сигнатуры формала |

Отказы при трансляции: [formal_default_none_refused](../../../selfbuild/tests/dyn/formal_default_none_refused.lm2) (`e(y: 3)` — `e has no argument x`), [formal_default_form_refused](../../../selfbuild/tests/dyn/formal_default_form_refused.lm2) (умолчание-выражение и `d()`), [formal_default_type_refused](../../../selfbuild/tests/dyn/formal_default_type_refused.lm2) (`(char: c 300)` — отказ на сигнатуре и без пропуска).

Пробы на кандидате (tool155a, fe155a, rt155a; [probe293-f](records/pins/probe293-f.tsv), [лог](records/pins/tp151-probe-f293f.log)): p293a, p293b, p293d, p293f, p293g, p293j и p286g ([запись 286](../fix286-20261106/records/cold-tp140/tests/dyn/p286g_call_receiver_default.lm2); было 22) — 7 во всех запусках; p293c — `e has no argument x`; p293h — `d has no argument a: its written default is not a literal value and is not built`; p293e — прежний `unsupported body`; p286n (контроль CALLABLE-PLACE-NAMED-ACTUALS) — как на 286: native 5, обходчик `walk error: INVALID`. p293i в этом прогоне писала `w(y: 2, x: 1)`: запятая не разделяет именованные фактические (`x: 1` P0 читает в теле `y`), отказ `unknown method` — ошибка пробы; переписана с `;`. Второй прогон на fe155b ([probe293-g](records/pins/probe293-g.tsv), [лог](records/pins/tp151-probe-f293g.log)): p293i и четыре ряда фикстур — 5/0.

## Мутанты

Ручные правки стейдж-файлов (инструмент Edit), каждая — сборка (frontend [tp155-fe](records/pins/tp155-fe.command) или runtime [tp155-rt](records/pins/tp155-rt.command)) и фикстура ([mut293](records/pins/mut293.tsv)); после каждой изменённые файлы стейджа возвращены из варианта и весь стейдж проверен `lmxtool verify` (229/0: [m1](records/pins/mut293-restore-m1.log), [m2](records/pins/mut293-restore-m2.log), [m3](records/pins/mut293-restore-m3.log), [m4](records/pins/mut293-restore-m4.log), [m5](records/pins/mut293-restore-m5.log)).

| Мутант | Сборка | Итог |
| --- | --- | --- |
| m1: связыватель обходчика не берёт умолчание формала (прежний FREE) | [rt155m1](records/pins/tp155-rt-m1.terminal.txt) | убит ([m293a](records/pins/tp151-probe-m293a.log)): forced root0 — код 89 (обходчик взял одноимённое `a` = 9 вызывающего), native root1 — `walk error: INVALID`, forced root1 — R0 остановлен; native root0 проходит |
| m2: native не заполняет пропущенный формал | [fe155m2](records/pins/tp155-fe-m2.terminal.txt) | убит ([m293b](records/pins/tp151-probe-m293b.log)): native root0, root1 и forced root0 — `walk error: INVALID`; forced root1 (всё обходом) проходит |
| m3: поле 2 не строится | [fe155m3](records/pins/tp155-fe-m3.terminal.txt) | убит ([m293c](records/pins/tp151-probe-m293c.log)): во всех четырёх запусках R0 остановлен непойманным неявным `call` |
| m4: контракт вызова в объявленном порядке | [fe155m4](records/pins/tp155-fe-m4.terminal.txt) | убит ([m293d](records/pins/tp151-probe-m293d.log)): все запуски с обходчиком — `walk error: INVALID` (двойная привязка у `w(y: 2)`); native root0 проходит |
| m5: поиск по рангу и среди пропущенных | [fe155m5](records/pins/tp155-fe-m5.terminal.txt) | убит ([m293e](records/pins/tp151-probe-m293e.log)): отказ трансляции `internal: binding has no prepared value` в обоих режимах |

## Приёмка

| Проверка | Результат | Receipt |
| --- | --- | --- |
| Кандидат | a01: шесть изменённых файлов (core, emit, helpers, lower, ядро lmx_walk_values, tools/build.lm2) сняты и скопированы, стейдж 225/0; fe155a 23:12:57→23:16:25Z, l2trans `cd84c164…`; tool155a (`rebuild tool` рабочим tool, G2 frontend и runtime boot154a; 168 имён `walk_value_names`) 23:16:40→23:17:57Z, `082779f9…`, `REBUILD tool 0 failures`; rt155a 23:18:13→23:18:58Z: driver `4135026a…`, observe `abe916b8…`, в `lmx_walk_values.h.lm1` прототип `lmx_call_formal_default` | [a01](records/pins/tp155-prepare-a01.log), [fe155a](records/pins/tp155-fe-a01.terminal.txt), [tool155a](records/pins/tp155-tool-a01.terminal.txt), [rt155a](records/pins/tp155-rt-a01.terminal.txt) |
| Пакет кандидата | a02: + отказ связывателя литералу не того типа (lower), четыре фикстуры, ряды реестра, список входов (229); изменённые файлы — [список](records/pins/tp155-changed-b.list); fe155b 23:20:58→23:24:17Z, l2trans `1fd7ebc5…`, l1trans `d815c37c…`, l2_libc `af9fdae3…` | [a02](records/pins/tp155-prepare-a02.log), [fe155b](records/pins/tp155-fe-a02.terminal.txt) |
| Реестр на кандидате | tool155a, fe155b, rt155a, весь поддерживаемый реестр ([копия](records/pins/registry293-a.tsv), байты `selfbuild/tests/full-suite.tsv`): 106 рядов, 0 отказов, 904 проверки, 23:25:10.0392205Z→23:38:37.3926197Z (807.35 с) | [terminal](records/pins/tp151-probe-r293a.terminal.txt), [лог](records/pins/tp151-probe-r293a.log) |
| Стейдж bootstrap | `steps` рабочего tool boot154a по [boot155a-prepare](records/pins/boot155a-prepare.tsv): 5/0, source-boot155a = source-tp155-a02 | [лог](records/pins/boot155a-prepare.log) |
| Whole boot155a | 23:57:33.4516477Z→00:08:41.1613318Z, BootstrapExit 0, 667.71 с; `BOOTSTRAP quick 0 failures`; smoke 9/0 в обеих генерациях; G0 — tool155a `082779f9…` (tools/build.lm2 изменён), предыдущий frontend — G2 boot154a `f43e1878…` | [terminal](records/pins/boot155a-quick.terminal.txt), [log](records/pins/boot155a-quick.log), [G2](records/cold-boot155a/quick155a/g2-build.log), [рецепт](records/pins/boot155-quick.command) |
| Приёмка `checks` | рабочий tool boot154a, [список](records/pins/boot155a-check.tsv): 38/0 — стейдж 229/0; записи producers G1 и G2 и запись сборки G2 замкнуты, без script host; G1 и G2: `exe-same` l2trans, l1trans, tool, `same` l2_libc.o, driver.o, driver-observe.o, L1 и C tool, consumed-inputs; рабочий tool и bundle — G2; кандидат rt155a — байты G2 runtime; кандидат fe155b и G2: `exe-same` l2trans и l1trans, `same` l2_libc.o — поэтому реестр на G2 не повторялся | [лог](records/pins/boot155a-check.log) |
| Самотест G2 tool | рабочий tool boot155a `179f0b3d…` (= G2 tool), ребёнок `tool153a-child` 291-го: `SELFTEST 0 failures` (12 строк `FAIL` — ожидаемые отказы негативных проверок схемы, как в 292) | [terminal](records/pins/tp152-selftest-g293.terminal.txt), [лог](records/pins/tp152-selftest-g293.log) |
| Посадка | `steps` рабочего tool boot155a по [land293](records/pins/land293.tsv), 00:09:47→00:09:48Z: 9/0, `selfbuild/inputs.sha256` = source-tp155-a02 `3c2ab9eb…` (229 входов) | [лог](records/pins/land293.log) |

Кортеж: рабочий tool `179f0b3dc9b56f11…` (= G2 tool), G2 frontend `1901bf61787f5527…`, l1 `580e362ee4b2eb46…`, l2_libc `af9fdae33655f8e6…`, driver `4135026a350b140a…`, observe `abe916b86bfca50d…`. Изменились l2_frontend_core, l2_frontend_emit, l2_frontend_helpers, l2_frontend_lower, ядро lmx_walk_values, tools/build.lm2, реестр, список входов и четыре новые фикстуры.

## Что не сделано и находки

- **FORMAL-DEFAULT-FORMS** (OPEN): строится только литерал примитивного числового формала. Имя, выражение (`2 + 3`), значение Structure- или callable-формала в позиции умолчания определение принимает, как и до среза, поле 2 пусто: статический вызов, пропускающий такой формал, отказывает при трансляции, выбранный во время исполнения — неявный `call`. Допустимы ли такие формы умолчанием (:381 — сигнатура не исполняет записанные формы), — вопрос нормы к Codex.
- **FORMAL-DEFAULT-MERGE** (OPEN): умолчание, данное формалу `merge` (:455, пример `fn: add5 merge(add\args; y: int: 5) int ()` в путеводителе), не строится; копия частей merge не переносит поле 2 (`lmx_graph_copy_owned`, частичная копия).
- **FORMAL-DEFAULT-POSITIONAL-SKIP** (OPEN): P0 хранит позиционный пропуск (`LM_P0_NODE_POSITIONAL_SKIP`, грамматика :287), транслятор его не читает — `e(, 2)` отказывает случайным `unsupported body`, как до среза.
- **FORMAL-DEFAULT-MACHINE** (OPEN): вызов машинной функции, пропускающий формал, — отказ трансляции: умолчание — состояние графа, у машинной функции графа нет.
- **Допуск по арности** не менялся: `fn` с умолчанием в место с меньшей арностью не допускается (`lm_compiler_sig_takes`, `lmx_implements_call_takes`; в ядре Q49 OPEN).
- **CALLABLE-PLACE-NAMED-ACTUALS** не тронут (p286n как на 286): native связывает по позиции, обходчик по имени; для пропущенного формала это так же — native читает умолчание выбранного по позиции, обходчик по имени входа контракта.

## Стоимость

Native: на каждый пропущенный формал — один вызов ядра (`lmx_callable_headers`, `lmx_walk_current_default`, приём свидетелем). Обходчик: проверка записи формала на суффиксный слот без операнда. Построение: ячейка на формал с литеральным умолчанием. Отдельно не замерено.

## Происхождение

Пробы, фикстуры, рецепты и списки записаны вручную инструментом Write, правки — инструментом Edit; мутанты — ручные правки стейдж-файлов с возвратом из варианта (`stage-copy`) и `lmxtool verify` всего стейджа. Подготовка кандидата, стейджа bootstrap, приёмка, посадка и архив — `lmxtool steps`/`checks`; PS-рецепты — запуски одной команды инструмента с охранниками: `tp155-fe`, `tp155-tool`, `tp155-rt`, `boot155-quick`, `boot155-detached` (новые, по образцам 286 и 292), `tp151-probe` (289), `tp152-selftest` (290). Отступления:

1. Карту умолчаний составил агент Explore (только чтение исходников, без запусков); выводы проверены чтением кода.
2. Списки `steps` подготовки, возвратов, приёмки и посадки запущены одной командой tool с выводом в лог, без терминального файла рецепта; receipt — лог (строки `CHECK`/`CHECKS`).
3. Строки логов, каталоги вывода проб и стейджа отобраны для чтения `Get-Content`/`Select-String`/`Get-ChildItem` (с исключением защищённого имени) по явным путям.
4. Поиск строки ревизии сопровождаемых документов шёл один раз `Grep` по корню репозитория с фильтром `*.md` (без явного списка путей — нарушение правила точных путей); вывод назвал четыре отслеживаемых файла, защищённого имени и путей `build/` в нём нет. Дальше документы найдены по списку файлов коммита 292 (`git show --name-only`).
5. Первый прогон кандидата шёл на fe155a, собранном до правки связывателя (отказ литералу не того типа); пакет a02 собран заново (fe155b), на нём шли реестр, мутанты и сравнение с G2.
6. Пробы m293c (m3) запущены одной командой PowerShell вместе с чтением терминала сборки fe155m3 (чтение файла, не второй рецепт).
7. Строку 45 next_core_tasks_v3_checklist.md (около 4000 знаков) дополнили две точные замены PowerShell `Replace` с проверкой, что каждая подстрока встречается ровно один раз, вместо инструмента Edit; файл записан UTF-8 без BOM, CR нет.

Архив и docs check — `steps`/`checks` рабочего tool boot155a. Первый проход ([docs293-archive-1](records/pins/docs293-archive-1.tsv), [лог](records/pins/docs293-archive-1.log)): манифест 101 пути P из [records293.list](records/pins/records293.list), их байтовые копии `stage-copy` в [records](records), [evidence.sha256](evidence.sha256) проверен против P и против копий. Затем точный allowlist ([allow293-1](records/pins/allow293-1.list), 124 пути) проиндексирован `git add --pathspec-from-file`, индекс сверен со списком (`diff`); 61 копия с CR (receipts PowerShell; [список](records/pins/crlf293-1.list)) удалена по точному списку и записана git из индекса с LF (`git checkout-index --stdin`), CR и прочие управляющие байты пересчитаны по байтам (0 из 124) — поэтому эти копии равны оригиналам с точностью до концов строк. Каталог PRIVATE_OUT языкового docs check создан до запуска (DOCS-CHECK-SILENT-PRIVATE-OUT). Docs check ([список](records/pins/docs293-check-a.tsv)): 00:13:21→00:13:40Z, `CHECKS 1 lines, 0 failed`, «line endings LF in the index for all 19684 tracked files» ([terminal](records/pins/docs293-check-a.terminal.txt), [лог](records/pins/docs293-check-a.log)). Второй проход (`pins/docs293-archive-2.tsv`) скопировал receipts первого прохода и docs check, манифест первого прохода, allowlist и список CR; итоговый evidence-манифест проверен против P; эта записка и копии второго прохода добавлены к индексу вторым точным списком, после чего docs check повторён над итоговым индексом. Receipts второго прохода и повторного docs check остаются в P (`pins/docs293-archive-2.*`, `pins/docs293-check-b.*`).
