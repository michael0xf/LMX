# Срез 306 — допуск всякого фактического своим формалом сразу после вычисления (CALL-ENTRY-ADMISSION-ORDER, остаток AXBY)

fable_pc, 2026-11-08. Норма — решение автора 2026-11-07 ([журнал](../../../LMX_blog/2026-11-07.md): «Каждый аргумент сразу
преобразуется, затем вычисляется следующий») и [книга :724](../../../provenance/semantics-book.md): каждый аргумент
вычисляется в порядке записи и сразу принимается формалом выбранного вызываемого с обычным преобразованием и допуском;
отказ оставляет следующие невычисленными, тело не начинается; одно правило для обычного вызова и вызова через изменяемое
место вызываемого. Срез 305 перенёс к месту фактического имена, форму и числовой приём; ревью Codex 305
(CODEX-FABLE-305-REVIEW-20261108042451Z-01) назвало остаток обязательным: правило — для каждого аргумента, не только
чисел; существующий допуск прочих значений («любое другое значение ждёт входа вызываемого» у обоих исполнителей)
переносится сразу после своего фактического без решения автора, одним механизмом для обычного и связанного вызова;
отказ оставляет следующие невычисленными. Реестр — [CALL-ENTRY-ADMISSION-ORDER](../../defects.md) (OPEN до среза),
[CALL-ARGUMENT-ORDER-AXBY](../../defects.md) (OPEN, промежуточный результат 305).

## Замер до изменения

Фикстура `entry_admission_order` на опубликованном кортеже boot168a (tool `66e2cfa6…`, frontend `10e57567…`, runtime
`6fedb4db…`), проба [p306a](records/pins/probe306-a.tsv): `walk error: INVALID` у обоих исполнителей — до проверок.
Локализация вариантами фикстуры в стейдже ([p306b](records/pins/probe306-b.tsv); варианты — файлы стейджа, не selfbuild:
[ea_v3](records/cold-tp140/tests/dyn/ea_v3.lm2) статический графовый вызов, [ea_v4](records/cold-tp140/tests/dyn/ea_v4.lm2)
графовые случаи у статического вызова и у места вызываемого, [ea_v1](records/cold-tp140/tests/dyn/ea_v1.lm2) всё без
указателей, [ea_v5](records/cold-tp140/tests/dyn/ea_v5.lm2) только указатели; копии — в records этой записи):

| Вариант | native | forced | Вывод |
|---|---|---|---|
| ea_v5 (адрес свободного имени у `@@: Point`-формала, статический вызов и место) | 7 | 7 | указательные формалы принимают кадром RECEIVE у места вызова уже сейчас — у обоих видов вызова |
| ea_v3 (`take(quote, touch())`: Shape, число, Slim) | 7 | INVALID | native статический вызов уже допускает сразу (форма 3 D-105 у места вызова; число — `convert` приёмом LMX); обходчик: число у Structure-формала — `lmx_walk_argument_storage` отвечает INVALID (NUMBER у свидетеля LMX) вместо `convert` |
| ea_v4 (графовые случаи, статический вызов и `Places\f` позиционно и по имени) | INVALID | 122 | native: INVALID ядра у `pass_place` (gdb, `lmx_call_note_walk_fail` ← `l2_m5`): допуск модели объявленного вызываемого `lmx_walk_value_admit(…, lmx_walk_slot_model(l2_c4\parent\parent, 0U), l2_cp16)` читается с выбранного узла `g`, у которого `\parent\parent` — не Places; forced: Slim у статического вызова — `implements` после `touch()` (отложен на вход) |
| ea_v1 (всё без указателей) | INVALID | INVALID | оба дефекта выше |

Итог замера: отложены на вход (а) графовый допуск у связанного вызова (оба исполнителя), (б) графовый допуск свободного
фактического у статического вызова обходчика; сверх того два дефекта — (в) INVALID обходчика на числе у Structure-формала
статического вызова, (г) INVALID native у всякого вызова через место вызываемого с Structure-формалом (модель объявленного
вызываемого, прочитанная с выбранного узла). Указательные и числовые формалы принимаются сразу у обоих видов вызова и
прежде (кадры RECEIVE объявленной сигнатуры; маршруты 301/305).

## Проект

1. Ядро (`lmx_walk_values.lm2`, перед `lmx_walk_receive_written`): `lmx_call_formal_reception(arena, code, index, @model,
   @record, @witness)` находит приём входа формала `index` в теле вызываемого — кадр SET_ARG источника RECEPTION (тот, что
   `lmx_walk_receive` вычисляет на входе, а трамплин native повторяет по удержанной записи `l2_cp`): тело — часть 3 `fn`
   (часть 2 `sub`; Structure как вызов — само тело), кадр — `lmx_walk_reception_parts` по совпадению индекса формала;
   1 — у формала есть приём моделью, 0 — нет (число, указатель, значение без роли). `lmx_call_receive_formal(arena, code,
   data, index, item)` — приём вычисленного фактического формалом выбранного вызываемого у места вызова, как принял бы
   его вход: у Structure-формала (свидетель LMX) — `lmx_walk_value_receive_graph` (число, чужое значение — неявный
   `convert`), затем, если у формала есть приём моделью, — модель `lmx_walk_receiving_header_model(arena, code, data,
   index)` (путь трамплина; `data` = данные вызова, 0 — `lmx_call_unary_data`) и `lmx_walk_value_admit(arena, item,
   model, record)` (граф без полей модели — неявный `implements`; значение помечено моделью и ссылками — вход затем
   находит его допущенным); у числового формала значение не-число — `lmx_walk_value_receive` (неявный `convert`). Число у
   числового формала — приём 305 (маршруты), отсутствующее или свободное значение — вход, указательный формал — кадр
   RECEIVE своего фактического (уже у места вызова): ничего. Одна функция обоих исполнителей; экспорт не нужен (ядро
   вызывает её само).
2. Обходчик, связанный вызов: `lmx_walk_receive_written` получает `callee` и `data` (через `lmx_walk_selected_values` →
   `lmx_walk_written_values`; `lmx_walk_call_in` передаёт выбранное вызываемое и данные вызова); ранний выход «не число»
   снят: соответствие `lmx_callable_bound_operand` вычисляется для всякого присутствующего значения, число у числового
   формала идёт прежним маршрутом, всё остальное (и число у нечислового формала) — `lmx_call_receive_formal(arena, callee,
   data, at, received)`; бросок — `payload`/`landing` сброшены, следующие фактические не вычисляются.
3. Обходчик, «статический» вызов: отдельного места нет. Всякий вызов `fn`/`sub` (роль FN) идёт путём сигнатуры
   (`lmx_walk_call_in`: `selected_signature` = 1 → `lmx_walk_selected_values`), так что п. 2 покрывает статический и
   связанный вызов одинаково. Кандидат a01 вставлял приём и в `lmx_walk_actuals_values` (после вычисления фактического,
   кроме обёрнутого компилятором в свой допуск); его мутант (m306-1) пережил фикстуру — путь обслуживает PRIM-записи и
   Structure как вызов, у которых приёма формала нет (`lmx_callable_headers` отвечает не-YES) — и a02 снял вставку,
   оставив комментарий о пути.
4. Ядро, связыватель native: `lmx_call_bind_receive` — ветвь `else` числового приёма: `lmx_call_receive_formal(arena, code,
   0, plan[written], item)` (данные — `lmx_call_unary_data`, как их передаёт диспетчеризация `lmx_call_prim_values`).
5. Native-эмиттер (`lm_compiler_emit_call_arguments_full`): `bind` = 1 при `sel` = 1 (всякий вызов через место вызываемого
   связывается ядром: вызываемое — то, что место держит сейчас); допуск моделью объявленной сигнатуры (форма 3
   `lm_compiler_emit_formal_admits`) при `bind` не печатается — его заменяет приём выбранного формала в
   `lmx_call_bind_receive`; после `lmx_call_bind_receive` бросок `LMX_WALK_THROWN + LMX_WALK_NAME_IMPLEMENTS` отображён
   неявным `implements` вызывающего, как `convert`.
6. Фикстура `entry_admission_order` (Entry 7; 80.. — отказавшая проверка): `Point (y, x)`, `Shape (y 2, x 1)`, `Slim (pad)`,
   `Thin (pad)`, `Trace\t`; свободное имя `quote`; `touch()` приписывает 9; `take (Point: p; int: q)` и `g` (у `Places\f`),
   `num_take (int: n; int: q)` и `gn` (у `Nums\f`), `ptr_take (@@: pp Point; int: q)` и `gp` (у `Ptrs\f`); вызовы
   `take(quote, touch())`, `Places\f(quote, touch())`, `Places\f(p := quote; q := touch())`, `num_take(quote, touch())`,
   `Nums\f(quote, touch())`, `ptr_take(@ quote, touch())`, `Ptrs\f(@ quote, touch())` под вложенными `catch: implements`
   (90) и `catch: convert` (91). `outer (Point: p)` связывает Shape: 29 и `Trace` 9 у графовых и указательных вызовов,
   `convert` без `touch()` у числовых формалов; `outer_num` (число): 59 и 9 у числовых формалов, `convert` без `touch()`
   у графовых и указательных; `outer_slim (Thin: t)` (Slim): `implements` без `touch()` у графовых. Ряд
   `tests/full-suite.tsv` после `bound_order_axby`, `inputs.list` 261 входов.

## Устройство

Стейдж cold-tp140 (вариант tp169), рецепты — копии рецептов tp168/305 с заменой имён и хешей: tp169-prepare (рабочий tool
boot164a `8b106da5…`), tp169-rt и tp169-fe (опубликованный tool boot168a `66e2cfa6…` — `tools/build.lm2` не изменён, —
предыдущий frontend G2 boot168a `10e57567…`), tp151-probe (фокус [probe306-c](records/pins/probe306-c.tsv), реестр
[registry306-a](records/pins/registry306-a.tsv)), mut306-restore, boot169-prepare/quick/detached (G0 — опубликованный tool
boot168a).

| Кандидат | Изменение | Сборки | Результат |
|---|---|---|---|
| a01 | lmx_walk_values.lm2 (приём в `lmx_walk_receive_written`, `lmx_call_bind_receive` и в `lmx_walk_actuals_values`), l2_frontend_lower.lm2, фикстура, full-suite.tsv, inputs.list (261) — [список](records/pins/tp169-changed-a01.list), [манифест](records/pins/tp169-changed-a01.sha256); стейдж — source-tp169-a01 `4f9d7ace…` (261 файлов) ([prepare](records/pins/tp169-prepare-a01.log), 5/0) | rt169a `04e9fa49…`/`4aeaa51a…` ([лог](records/pins/tp169-rt-a01.log), 05:05:42→05:06:29Z), fe169a `4bf7b38a…`/`ea2e7b79…`/`af9fdae3…` ([лог](records/pins/tp169-fe-a01.log), 05:06:55→05:10:24Z) | фокус p306c 18 рядов 108/0; реестр r306a 136 рядов 1084/0; мутант m306-1 (приём в `lmx_walk_actuals_values` снят) пережил — место мёртвое |
| a02 | a01 без приёма в `lmx_walk_actuals_values` (сигнатура и вызывающие прежние; комментарий о пути) — [список](records/pins/tp169-changed-a02.list), [манифест](records/pins/tp169-changed-a02.sha256); стейдж — source-tp169-a02 `47a516d8…` ([prepare](records/pins/tp169-prepare-a02.log), 5/0) | rt169b `78b6e2b0…`/`63e2746f…` ([лог](records/pins/tp169-rt-a02.log), 05:34:28→05:35:15Z); frontend — fe169a (frontend не менялся) | фокус и реестр ниже |

## Результаты

| Шаг | Результат | Receipts |
|---|---|---|
| Фокус p306c (a01) | [probe306-c](records/pins/probe306-c.tsv) на tool boot168a / fe169a / rt169a: 18 рядов, 108 PASS, 0 отказов — `entry_admission_order` 7 native и forced, оба корня; с ним ряды допуска графов, свободных значений, мест вызываемого, именованной подачи, умолчаний, копий | [лог](records/pins/tp151-probe-p306c.log), [терминал](records/pins/tp151-probe-p306c.terminal.txt) |
| Реестр на кандидате a01 | весь поддерживаемый реестр — байты `selfbuild/tests/full-suite.tsv` ([копия](records/pins/registry306-a.tsv)): 136 рядов, 1084 PASS, 0 отказов (native и forced, оба корня; 05:14:16→05:30:24Z) на tool boot168a `66e2cfa6…` / fe169a `4bf7b38a…` / rt169a `04e9fa49…` | [лог](records/pins/tp151-probe-r306a.log), [терминал](records/pins/tp151-probe-r306a.terminal.txt) |
| Фокус p306d (a02) | тот же список на fe169a / rt169b: 18 рядов, 108 PASS, 0 отказов (05:35:28→05:38:30Z) | [лог](records/pins/tp151-probe-p306d.log), [терминал](records/pins/tp151-probe-p306d.terminal.txt) |
| Реестр на кандидате a02 | тот же список на fe169a / rt169b `78b6e2b0…`: 136 рядов, 1084 PASS, 0 отказов (native и forced, оба корня; 05:38:43→05:54:33Z) | [лог](records/pins/tp151-probe-r306b.log), [терминал](records/pins/tp151-probe-r306b.terminal.txt) |
| Стейдж bootstrap | `steps` рабочего tool boot164a по [boot169a-prepare](records/pins/boot169a-prepare.tsv) ([рецепт](records/pins/boot169-prepare.command); его строка вывода осталась с меткой «BOOTPREP168» — косметика клона): 5/0, стейдж cold-boot169a = source-tp169-a02 `47a516d8…` (source-boot169a тот же хеш) | [лог](records/pins/boot169a-prepare.log), [терминал](records/pins/boot169a-prepare.terminal.txt) |
| Whole boot169a | [boot169-quick](records/pins/boot169-quick.command) через [boot169-detached](records/pins/boot169-detached.command): G0 — опубликованный tool boot168a `66e2cfa6…` (`tools/build.lm2` не менялся), предыдущий frontend — G2 boot168a `10e57567…`; `BOOTSTRAP quick 0 failures`, smoke 9/0 (06:08:25→06:19:29Z, 664.8 с); G2: tool `3158d8dc…` (= рабочий bundle), l2trans `9e20bcb5…`, l1trans `56a5ada6…`, l2_libc.o `af9fdae3…`, driver.o `78b6e2b0…` (= rt169b), driver-observe.o `63e2746f…` | [лог](records/pins/boot169a-quick.log), [verify](records/pins/boot169a-quick-verify.log), [терминал](records/pins/boot169a-quick.terminal.txt), [launcher](records/pins/boot169a-detached.terminal.txt) |
| Приёмка `checks` | рабочий tool boot164a, [список](records/pins/boot169a-check.tsv) ([рецепт](records/pins/checks303.command)): первый прогон [checks306-a](records/pins/checks306-a.log) 36/38 — две строки `same` сравнивали G2 runtime с rt169a (кандидат a01) вместо rt169b: ошибка клонированного списка, не кортежа; список исправлен (rt169b), [checks306-b](records/pins/checks306-b.log) 38/0 (06:20:15Z) — стейдж 261/0, записи обоих поколений и записи G2, deps без скрипт-хостов, G1 = G2 (exe-same/same), рабочий tool и bundle = G2, rt169b same как G2 runtime, fe169a exe-same как G2 frontend, l2_libc same | [терминал a](records/pins/checks306-a.terminal.txt), [терминал b](records/pins/checks306-b.terminal.txt) |
| Самотест G2 tool | G2 tool boot169a `3158d8dc…` (= рабочий bundle), ребёнок `tool153a-child` `40c935bc…` (`cold-tp140/tool153a-child/lmxchild-prod.exe`), рецепт [tp152-selftest](records/pins/tp152-selftest.command): `SELFTEST 0 failures` (12 строк `FAIL` — ожидаемые отказы негативных проверок), 06:20:30→06:20:42Z | [лог](records/pins/tp152-selftest-s306a.log), [терминал](records/pins/tp152-selftest-s306a.terminal.txt) |
| Посадка | `steps` рабочего tool boot164a по [land306](records/pins/land306.tsv) ([рецепт](records/pins/steps303.command)): первый прогон [land306](records/pins/land306.log) остановился на строке 3 — два пути `consumed-inputs.sha256` клонированного списка несли метку `quick168a` (в selfbuild ничего не скопировано: `verify` и первая `same` прошли); список исправлен (`quick169a`), [land306b](records/pins/land306b.log) 9/0 (06:21:11Z): стейдж boot169a = source-tp169-a02, consumed G1 = G2 (311 файлов), `variants/tp169/inputs.list` = selfbuild, источники скопированы в selfbuild, `selfbuild/inputs.sha256` = source-tp169-a02 `47a516d8…` (261 входов) | [терминал](records/pins/land306.terminal.txt), [терминал b](records/pins/land306b.terminal.txt) |
| Документы | generated semantics перерисованы из provenance по [docs306-render](records/pins/docs306-render.tsv) (render/verify semantics, render grammar — 3/0, 06:21:27Z; изменены по одной строке `docs/LMX_semantics.ru.md` и `.en.md`, грамматика без изменений); `docs check` индекса после `git add` точного allowlist ([allow306-1](records/pins/allow306-1.list)) по [docs306-check-a](records/pins/docs306-check-a.tsv): OK — 35 парных глав, 14 случаев implements, 27 парных разделов грамматики, 44 выдержки, 615 импортированных файлов, ссылки, LF в индексе (06:22:29→06:24:08Z); 70 копий receipts приведены к LF из индекса (`git show :path`) перед проверкой; окончательный проход после архива второго прохода — receipt только в P (как у 303–305) | [лог render](records/pins/docs306-render.log), [лог check](records/pins/docs306-check-a.log), [терминал](records/pins/docs306-check-a.terminal.txt) |
| Архив | `steps` рабочего tool boot164a: [arch306-1](records/pins/arch306-1.tsv) — 105 путей P по [records306.list](records/pins/records306.list) (рецепты, списки, логи и терминалы tp169/проб/мутантов/boot169a/checks/самотеста/посадки/render, четыре пробных варианта фикстуры из стейджа), копии проверены 105/0; второй проход [arch306-2](records/pins/arch306-2.tsv) — receipts первого прохода и проверки docs, 8 путей; [evidence.list](evidence.list) и [evidence.sha256](evidence.sha256) — объединение обоих манифестов | [лог 1](records/pins/arch306-1.log), [лог 2](records/pins/arch306-2.log) |

## Мутанты

Стейдж правится по точной строке (Edit; проверка `sed -n` до и после), кандидатный runtime или frontend собирается с
меткой мутанта (tp169-rt / tp169-fe), фокус [probe306-a](records/pins/probe306-a.tsv) (один ряд фикстуры) на tool boot168a
с fe169a / rt169a другой стороны, возврат — [mut306-restore](records/pins/mut306-restore.command) по
[списку](records/pins/mut306-restore.tsv): два пути из варианта tp169, весь стейдж против source-tp169-a01.

| Мутант | Что снято | Результат |
|---|---|---|
| m306-1 на a01 (rt169m1 `c00908a8…`/`7410ab67…`, `lmx_walk_values.lm2:5301` в `lmx_walk_actuals_values`: приём не вызывается — `status: c.LMX_WALK_OK`) | фикстура 7 native и forced — пережил: место не достигается вызовом `fn`/`sub` (путь сигнатуры); вставка снята в a02 ([лог](records/pins/tp151-probe-m306-1.log), [rt](records/pins/tp169-rt-m1.log), [возврат](records/pins/mut306-restore-m1.log)) |
| m2 (rt169m2 `c1d1212d…`/`7196442d…`, `lmx_walk_values.lm2:4885` в `lmx_walk_receive_written`: приём не-числа выбранным формалом не вызывается — `status: c.LMX_WALK_OK`) | forced: `walk error: INVALID` у обоих корней (число у Structure-формала — проверка хранения вместо `convert`, как до среза); native 7 — убит обходчиком ([лог](records/pins/tp151-probe-m306-2.log), [rt](records/pins/tp169-rt-m2.log), [возврат](records/pins/mut306-restore-m2.log)) |
| m3 (rt169m3 `3c12525e…`/`d720f0ec…`, `lmx_walk_values.lm2:6279` в `lmx_call_bind_receive`: ветвь не-числа не принимает — `status: c.LMX_WALK_OK`) | native: выход 124 у обоих корней (`Places\f(quote, touch())` со Slim — `implements` пришёл с входа трамплина после `touch()`; число у Point-формала — `convert` ещё кадром RECEIVE места вызова, проверки 105–110 прошли); forced 7 — убит native ([лог](records/pins/tp151-probe-m306-3.log), [rt](records/pins/tp169-rt-m3.log), [возврат](records/pins/mut306-restore-m3.log)) |
| m4 (fe169m4 `0aa4a4d0…`/`2e451798…`, `l2_frontend_lower.lm2:11685`: вызов через место вызываемого не связывается ядром — `sel = 1 && nact < 0`) | native: `walk error: INVALID` у обоих корней (позиционный `Places\f(quote, touch())` снова печатает допуск модели объявленной сигнатуры с выбранного узла — дефект замера); forced 7 — убит native ([лог](records/pins/tp151-probe-m306-4.log), [fe](records/pins/tp169-fe-m4.log), [возврат](records/pins/mut306-restore-m4.log)) |
| m5 (fe169m5 `b1ab9d61…`/`04a5f81e…`, `l2_frontend_lower.lm2:11844`: бросок `implements` связывателя не отображён — условие печатается с `LMX_WALK_NAME_INTERPRETER`) | native: выход 123 у обоих корней (`Places\f(quote, touch())` со Slim — отказ ядра ушёл в `lmx_call_note_walk_fail` и `return: 0`, вызывающий не получил `implements`); forced 7 — убит native ([лог](records/pins/tp151-probe-m306-5.log), [fe](records/pins/tp169-fe-m5.log), [возврат](records/pins/mut306-restore-m5.log)) |

Четыре из четырёх мутантов a02 убиты (m2 обходчиком, m3–m5 native); m306-1 пережил как мутант мёртвого места кандидата
a01 и привёл к a02. Каждое из трёх мест приёма и оба решения эмиттера ловятся фикстурой с той стороны, которую они держат.

## Границы

- Скрытый вход EXEC (суффикс транспорта), поданный отсутствующим при исполнении: умолчание или `call` — готовая фаза после
  фактических, как в срезе 305 (экзотический путь; фикстурой не покрыт).
- Указательные формалы (`@@: T`): приём кадром RECEIVE фактического у места вызова, у статического и связанного вызова
  (замер ea_v5) — без изменений; `lmx_call_receive_formal` их не трогает.
- Приём на входе (`lmx_walk_receive`, трамплин) остаётся — инвариант входа для любого вызывающего; у допущенного у места
  вызова значения он находит запись допуска (значение несёт модель и ссылки) и ничего не меняет.
- Данные вызова для модели формала: у связанного вызова native и обходчика — `lmx_call_unary_data` выбранного вызываемого
  (как передаёт диспетчеризация); у статического вызова обходчика — данные вызова (`lmx_walk_call_in`). Модель, зависящая
  от явно переданных данных у связанного вызова, фикстурой не покрыта.
- Статический вызов native: допуск у места вызова (форма 3, D-105) — без изменений; статический вызов native в walked
  вызываемое без тела (`m_native` = 0) — прежний путь (вход).

## Документы

- [Реестр дефектов](../../defects.md): CALL-ENTRY-ADMISSION-ORDER — CLOSED срезом 306 (абзац «Срез 306»: механизм, два
  попутных дефекта, фикстура, граница; исходная запись сохранена); CALL-ARGUMENT-ORDER-AXBY — CLOSED срезами 305–306
  (прежний заголовок сохранён в новом); заголовки CALLABLE-PLACE-TYPED-RECEPTION и IDENTIFIER-CODES («AXBY закрыт срезами
  305–306»); CALL-WHOLE-ARGUMENTS-STRUCTURE — удержание снято ответом автора 2026-11-08 (см. ниже).
- [steps/current.md](../../current.md): абзац среза 306 перед абзацем 305; строка «Дальше» — AXBY закрыт, затем
  whole-arguments.
- [selfbuild/README.md](../../../selfbuild/README.md): 261 входов (66 исходников, 34 инструмента, 161 тест); абзац Slice306
  после Slice305 (фраза о «numeric part» переписана).
- Журнал [LMX_blog/2026-11-08.md](../../../LMX_blog/2026-11-08.md) — выдержка автора о двух методах (дословно; передана
  CODEX-FABLE-AUTHOR-STRUCTURE-AMBIGUITY-RESOLVED-20261108044825Z-01, [копия](../fix304-20261107/records/pins/CODEX-FABLE-AUTHOR-STRUCTURE-AMBIGUITY-RESOLVED-20261108044825Z-01.txt))
  и его уточнение о применимости первой частью `implements` (дословно; CODEX-FABLE-AUTHOR-IMPLEMENTS-MATCH-20261108T052418Z-01,
  [копия](../fix304-20261107/records/pins/CODEX-FABLE-AUTHOR-IMPLEMENTS-MATCH-20261108T052418Z-01.txt)):
  удержание whole-arguments снято — книга (provenance RU/EN, абзац whole-arguments; generated docs перерисованы), заметки
  о реализации 4.2 RU/EN, записи 304 и реестр.
- Уточнение формулировки границы п. 2 ревью 305 по второму письму Codex (CODEX-FABLE-305-DOCS-REVIEW-20261108043021Z-01,
  [копия](../fix305-20261108/records/pins/CODEX-FABLE-305-DOCS-REVIEW-20261108043021Z-01.txt)) — реестр и запись 305.

## Открыто

- Вся структура аргументов из одной Structure — CALL-WHOLE-ARGUMENTS-STRUCTURE (следующий срез по ответу автора
  2026-11-08: два действительно подходящих метода — отказ по неоднозначности, один — обычное сопоставление;
  применимость метода с формалом `d: S` — первой частью `implements` при трансляции, уточнение автора
  CODEX-FABLE-AUTHOR-IMPLEMENTS-MATCH-20261108T052418Z-01; приёмка —
  `mytest(merge(mytest\args; (a: int: 5)))` = 35, та же Structure через переменную, обе однозначные формы и
  неоднозначный случай; native и forced).
- Остаток IDENTIFIER-CODES: внутренние сравнения транслятора, транслятор L1, тесты RESULT; затем RESULT.

## Провенанс

Правки исходников и документов — Edit/Write; вставка двух функций ядра — `sed r` по уникальному якорю
(`end: lmx_walk_selected_form`) из файла scratchpad; остальные правки ядра и эмиттера — Edit по уникальным строкам.
Списки `tp169-*`, `probe306-*.tsv`, `registry306-a.tsv` (байты full-suite.tsv), `records306*.list`, `allow306-1.list` —
`printf`/`cat`/`cp`; рецепты — копии рецептов tp168/boot168 с заменой имён и хешей (`sed`; строки с путями `\`
правились Edit). Каждый список исполнен `steps`/`checks`/`suite` без отказа строки; каждый запуск — из своего нового
каталога. Возвраты после мутантов — `stage-copy` из варианта tp169 по манифесту его файлов с проверкой всего стейджа.
Диагностика INVALID native — gdb из состава mingw на готовой программе ряда `ea_v4-native` (`p-prod.exe 0 entry 7`,
останов на `lmx_call_note_walk_fail`, `bt`; стейдж не писался).

## Отклонения

1. Правило передачи о basename `l2_driver_launch.err`: при поиске программы ряда `tp151-probe/p306b/ea_v4-native` каталог
   ряда был перечислен (`ls`), и в выводе появилось имя защищённого файла; файл не читался и не менялся. Дальнейшие
   обращения — только по точным именам (`p-prod.exe`, `p.lm1`, `run-root0.log`, логи pins). Отклонение записано здесь и
   сообщено Codex в отчёте среза.
2. Пробные варианты фикстуры (ea_v1/v3/v4/v5) — файлы, написанные в стейдж для локализации INVALID; в selfbuild не вносятся,
   копии — в records/pins этой записи.
