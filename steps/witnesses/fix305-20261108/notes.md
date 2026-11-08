# Срез 305 — порядок аргументов связанного вызова: имена и форма до аргументов, числовой приём каждого сразу (промежуточный результат CALL-ARGUMENT-ORDER-AXBY)

fable_pc, 2026-11-08. Решение автора 2026-11-07 ([журнал](../../../LMX_blog/2026-11-07.md): «Каждый аргумент сразу
преобразуется, затем вычисляется следующий. Имена и форму вызова проверять до вычисления аргументов»; передано Codex,
CODEX-OPUS-301-AUTHOR-ORDER-SHAPE-20261107-01), норма — [книга :724](../../../provenance/semantics-book.md) (имена и форма
вызова проверяются по выбранному вызываемому до вычисления аргументов; несоответствие — неявный `call` без эффектов
аргументов; затем аргументы вычисляются в порядке записи, и каждый сразу принимается формалом выбранного с обычным
преобразованием; отказ вычисления или приёма оставляет следующие невычисленными, тело не начинается; одно правило для
обычного вызова и вызова через изменяемое место вызываемого; вызываемое выбирается один раз, до аргументов). Реестр —
[CALL-ARGUMENT-ORDER-AXBY](../../defects.md): статический вызов уже следовал правилу (форма проверяется при трансляции,
каждый фактический принимается сразу), связанный (вызываемое выбрано при исполнении, срезы 294, 297, 301) — нет: оба
исполнителя вычисляли все записанные фактические, затем связывали их с формалами выбранного (`lmx_call_bind_actuals`,
`lmx_walk_selected_ready_values`), отказ `call` по имени наступал после эффектов фактических, приём выбранным формалом —
после всех (проба Opus p301b — 1233 вместо 1323). Поручение реестра: исправление вместе с IDENTIFIER-CODES —
соответствие формалов выбранного устанавливается до фактических по кодам имён, без строкового поиска. Codex
(CODEX-FABLE-304-REVIEW-VERIFIED-20261108030330Z-01): продолжать остаток IDENTIFIER-CODES и AXBY в единственном
конвейере; публикация готового среза без ACK.

## Проект

1. Ядро, native (`lmx_walk_values.lm2`): `lmx_call_bind_actuals` заменена тремя фазами в порядке текста вызова, без
   параллельного пути. `lmx_call_bind_form(arena, code, count, written_count, slots, names, plan)` — до вычисления
   фактических: арность выбранного (формалы части args, `lmx_walk_args_formal`), имена и позиции по кодам
   (`lmx_callable_bind_prefix` — та же функция обоих исполнителей: позиционный — формал своего порядкового номера,
   именованный — формал своего имени, позиционный после именованного, имя без формала, повтор формала — NO), имя,
   которое несёт только скрытый вход, и наличие текущего умолчания у каждого формала, которого вызов не пишет
   (`lmx_walk_current_default` — чтение части args, не вычисление; книга :726 — без аргумента и допустимого дефолта
   вызов отказывает); несоответствие — `LMX_WALK_THROWN + LMX_WALK_NAME_CALL`, план `plan[i]` = индекс выбранного формала
   записанного фактического i. `lmx_call_bind_receive(arena, code, count, written_count, slots, plan, written, values,
   маршруты)` — сразу после вычисления фактического `written`: число у числового формала выбранного принимается по
   маршруту, разрешённому местом вызова для типа этого формала (`lmx_call_bound_route`, срез 301), иначе неявный `convert`
   (`lmx_walk_receive_selected`); значение принимается на месте, `values[slots[written]]`. `lmx_call_bind_finish(arena,
   code, count, written_count, slots, plan, values)` — после всех: значения в порядке формалов выбранного
   (`bound[plan[i]] = values[slots[i]]`), формалам без фактического — умолчание (`lmx_call_formal_default`; его наличие
   проверила форма). Значение без собственной сигнатуры (результат `merge`, Structure как вызов): форма принимает
   фактические, как их располагает сигнатура записи (`plan = slots`), приём и финиш ничего не меняют. Экспорт —
   `walk_value_names[168]` (`lmx_call_bind_form` на месте `lmx_call_bind_actuals`), `[172]`, `[173]`
   (`tools/build.lm2`, 174 имён; заголовок ядра пишет tool).
2. Обходчик (`lmx_walk_selected_values`): имена записанных фактических читаются из операндов вызова без вычисления
   (`lmx_walk_written_names` — обёртка NAMED, код имени); текущая часть args выбранного — `lmx_walk_selected_inputs`;
   форма — `lmx_callable_bind_written` (как прежде, но до фактических; NO — `call` без эффектов) и `lmx_walk_selected_form`
   (занятость формалов по соответствию всех операндов транспорта — записанных и суффикса скрытых входов EXEC, пустой слот
   суффикса считается поданным отсутствующим; у незанятого формала должно быть текущее умолчание, иначе `call`); затем
   `lmx_walk_written_values` вычисляет каждый записанный фактический и сразу принимает его выбранным формалом
   (`lmx_walk_receive_written`: соответствие `lmx_callable_bound_operand`, маршрут NAMED-операнда `lmx_walk_named_route`,
   `lmx_walk_publish` перед ресивером программы, `lmx_walk_receive_selected`; бросок — `payload`/`landing` сброшены,
   следующие не вычисляются); суффикс — после записанных, как прежде; `lmx_walk_publish`; `lmx_walk_selected_ready_values`
   — только раскладка в порядок выбранного (`lmx_walk_scatter_written`), умолчания, скрытые входы, хранилище (приёма в ней
   больше нет).
3. Native-эмиттер (`lm_compiler_emit_call_arguments_full`): решение `bind` (именованный фактический или пропущенный
   формал) — до цикла фактических; до цикла — массивы `l2_bs`/`l2_bn`/`l2_bp`, маршруты (`lm_compiler_emit_bound_routes`),
   `lmx_call_bind_form` с неявным броском `call`; в цикле после каждого фактического — `lmx_call_bind_receive` с неявным
   броском `convert`; после цикла — `lmx_call_bind_finish`. Вызов, пишущий все формалы по позициям (`bind` = 0), связывается
   как записан, без фаз. Вызываемое выбиралось один раз до фактических и прежде (`l2_c`).
4. Фикстура `bound_order_axby` (из пробы Opus p301b, именованная подача через `:=`): `Places\f (int x; int y; char u;
   char v)` держит `g (int u; int v; char x; char y)`; `Places\f(x := a1(); y := a2(); u := 3; v := 4)` — результаты
   a1 и a2 принимаются char-формалами g ресивером int → char программы, каждый эффект приписывает цифру к `Trace\t`:
   1323 (a1, его приём, a2, его приём), результат 1234; с отказывающим ресивером (`Fail\on`) — неявный `convert` после a1 и
   его приёма, a2 не вычислен — 13; `Two\f (int x; int y)` держит `gq (int p; int q)`: `Two\f(x := touch(); y := 1)` —
   у gq нет формала x: `call` без `touch()`; `Dflt\f (int x 1; int y 2)` держит `g2 (int y; int x)` без умолчаний:
   `Dflt\f(x := touch())` — у y нет входа: `call` без `touch()`. Выход 7, 80..88 — отказавшая проверка. Ряд
   `tests/full-suite.tsv` после `bound_typed_reception`, `inputs.list` 260 входов.
5. Граница (не правило языка; записана в реестр): допуск Structure-фактического моделью формала (implements) по-прежнему
   выполняется на входе вызываемого после вычисления всех фактических — у статического и связанного вызова одинаково;
   срез переносит к месту фактического лишь числовой приём и проверку формы, как требовало поручение реестра.

## Устройство

Стейдж cold-tp140 (вариант tp168), рецепты — копии рецептов tp167/304 с заменой имён и хешей: tp168-prepare (рабочий tool
boot164a `8b106da5…`), tp168-tool (`rebuild tool` стейджа кортежем опубликованного boot167a: tool `7e220363…`, frontend
`27a9b8a8…`, runtime `d7e7c4bf…`/`857dcb0c…`), tp168-rt и tp168-fe (tool168a стейджа, предыдущий frontend — G2 boot167a),
tp151-probe (фокус [probe305-a](records/pins/probe305-a.tsv)), mut305-restore, boot168-prepare/quick/detached (G0 — tool168a
стейджа: `tools/build.lm2` изменён срезом).

| Кандидат | Изменение | Сборки | Результат |
|---|---|---|---|
| a01 | lmx_walk_values.lm2, l2_frontend_lower.lm2, lmx_implements.lm2 (комментарий), tools/build.lm2, фикстура, full-suite.tsv, inputs.list (260) — [список](records/pins/tp168-changed-a01.list), [prepare](records/pins/tp168-prepare-a01.tsv), [лог](records/pins/tp168-prepare-a01.log) 5/0, стейдж 260/0 | tool168a `af93bd41…` ([tp168-tool](records/pins/tp168-tool.command), [терминал](records/pins/tp168-tool-a01.terminal.txt), [лог](records/pins/tp168-tool-a01.log): `REBUILD tool 0 failures`, smoke пройден, 03:23:31→03:24:51Z); rt168a: driver.o `6fedb4db…`, driver-observe.o `edcec97a…` ([терминал](records/pins/tp168-rt-a01.terminal.txt), [лог](records/pins/tp168-rt-a01.log)); fe168a: l2trans `190ae1f6…`, l1trans `e464c6f4…`, l2_libc.o `af9fdae3…` ([терминал](records/pins/tp168-fe-a01.terminal.txt), [лог](records/pins/tp168-fe-a01.log)) | собраны с первого раза; фокус ниже |

## Результаты

| Шаг | Результат | Receipts |
|---|---|---|
| Фокус p305a (a01) | [probe305-a](records/pins/probe305-a.tsv) на tool168a / fe168a / rt168a: 13 рядов, 78 PASS, 0 отказов — `bound_order_axby` 7 native и forced, оба корня (порядок 1323 и результат 1234; с отказывающим ресивером — `convert` после a1 и его приёма, a2 не вычислен — 13; `Two\f(x := touch(); y := 1)` у gq без x и `Dflt\f(x := touch())` у g2 без умолчания y — `call` без `touch()`); прежние ряды связанных вызовов, именованной подачи, умолчаний, копий и операнда `merge` проходят | [терминал](records/pins/tp151-probe-p305a.terminal.txt), [лог](records/pins/tp151-probe-p305a.log) |
| Реестр на кандидате a01 | весь поддерживаемый реестр — байты `selfbuild/tests/full-suite.tsv` ([копия](records/pins/registry305-a.tsv)): 135 рядов, 0 отказов, 1078 проверок PASS, native и forced, оба корня, кортеж tool168a `af93bd41…` / fe168a `190ae1f6…` / rt168a `6fedb4db…`/`edcec97a…` (runtime среза — новое ядро), 03:33:01→03:48:37Z | [терминал](records/pins/tp151-probe-r305a.terminal.txt), [лог](records/pins/tp151-probe-r305a.log) |
| Стейдж bootstrap | `steps` рабочего tool boot164a по [boot168a-prepare](records/pins/boot168a-prepare.tsv) ([рецепт](records/pins/boot168-prepare.command)): 5/0, стейдж `cold-boot168a` 260/0, [source-boot168a](records/pins/source-boot168a.sha256) `6ca4650c…` = source-tp168-a01 | [лог](records/pins/boot168a-prepare.log), [терминал](records/pins/boot168a-prepare.terminal.txt) |
| Whole boot168a | [boot168-quick](records/pins/boot168-quick.command) через [boot168-detached](records/pins/boot168-detached.command): G0 — tool168a стейджа `af93bd41…` (`tools/build.lm2` изменён срезом: экспорт трёх фаз), предыдущий frontend — G2 boot167a `27a9b8a8…`; `BOOTSTRAP quick 0 failures`, smoke 9/0 (`SUITE 9 rows, 0 failures`; `PASS bootstrap: actual G1 builds and tests whole G2`), 04:05:55→04:17:18Z (683 с); G2: tool `66e2cfa6…`, l2trans `10e57567…`, l1trans `703b5002…`, l2_libc.o `af9fdae3…`, runtime `6fedb4db…`/`edcec97a…` | [лог](records/pins/boot168a-quick.log), [терминал](records/pins/boot168a-quick.terminal.txt), [verify](records/pins/boot168a-quick-verify.log), [detached](records/pins/boot168a-detached.terminal.txt) |
| Приёмка `checks` | рабочий tool boot164a, [список](records/pins/boot168a-check.tsv) ([рецепт](records/pins/checks303.command)): 38/0 (04:17:33.02→04:17:33.38Z) — стейдж 260/0; записи producers обеих генераций и G2-build-record закрыты и без script hosts; G1 = G2 (exe-same frontend и tool, same runtime, l2_libc.o, lmxtool.lm1/.c, consumed inputs); рабочий tool и bundle = G2; rt168a `same` G2 runtime; fe168a `exe-same` G2 frontend, его l2_libc.o `same`; хеши G2 | [лог](records/pins/checks305-a.log), [терминал](records/pins/checks305-a.terminal.txt) |
| Самотест G2 tool | G2 tool boot168a `66e2cfa6…` (= рабочий bundle), ребёнок `tool153a-child` `40c935bc…`, рецепт [tp152-selftest](records/pins/tp152-selftest.command): `SELFTEST 0 failures` (12 строк `FAIL` — ожидаемые отказы негативных проверок схемы, как у 298–304), 04:17:52.73→04:18:04.63Z | [терминал](records/pins/tp152-selftest-s305a.terminal.txt), [лог](records/pins/tp152-selftest-s305a.log) |
| Посадка | `steps` рабочего tool boot164a по [land305](records/pins/land305.tsv) ([рецепт](records/pins/steps303.command)): 9/0, `selfbuild/inputs.sha256` = source-tp168-a01 `6ca4650c…` (260 входов), G2 consumed = G1 consumed (311 файлов проверены в стейдже), стейдж boot168a держит байты G2, `variants/tp168/inputs.list` = selfbuild, 04:18:05.21→04:18:06.67Z | [лог](records/pins/land305.log), [терминал](records/pins/land305.terminal.txt) |

## Мутанты

Стейдж правится `sed` по точной строке (проверка `sed -n` до и после), кандидатный runtime или frontend собирается с меткой
мутанта (tp168-rt / tp168-fe), фокус [probe305-a](records/pins/probe305-a.tsv) на tool168a с fe168a / rt168a другой стороны,
возврат — [mut305-restore](records/pins/mut305-restore.command) по [списку](records/pins/mut305-restore.tsv): семь путей из
варианта tp168, весь стейдж против source-tp168-a01.

| Мутант | Что снято | Результат |
|---|---|---|
| m1 (rt168m1 `64f1e63b…`/`91ab1933…`, `lmx_walk_values.lm2:6096` в `lmx_call_bind_form`: наличие умолчания у непрописанного формала не требуется — `current\present = 2`) | проверка обязательных входов в форме native | **убит** native (`bound_order_axby` оба корня: `Dflt\f(x := touch())` — `touch()` выполнен, `call` лишь из финиша — выход 88); forced проходит (у обходчика своя форма, `lmx_walk_selected_form`) ([лог](records/pins/tp151-probe-m305-1.log), [терминал](records/pins/tp151-probe-m305-1.terminal.txt)); возврат [лог](records/pins/mut305-restore-m1.log) 260/0 |
| m2 (rt168m2 `86535aa4…`/`0fba1df5…`, `lmx_walk_values.lm2:4902` в `lmx_walk_written_values`: приём сразу после вычисления не вызывается — `if: selected_args = 0`) | приём каждого фактического выбранным формалом у обходчика | **убит**: forced `bound_order_axby`, `bound_typed_reception`, `named_actuals_selected`, `formal_defaults` (и native `formal_defaults` root1, `copy_name_codes` root0 — пути, идущие через обходчик) — R0 остановлен (`driver exit 3`: значение не принято типом выбранного формала) ([лог](records/pins/tp151-probe-m305-2.log), [терминал](records/pins/tp151-probe-m305-2.terminal.txt)); возврат [лог](records/pins/mut305-restore-m2.log) 260/0 |
| m3 (fe168m3 `29c59e74…`, `l2_frontend_lower.lm2:11829`: native не печатает `lmx_call_bind_receive` после фактического — `nact < 0`) | приём каждого фактического выбранным формалом у native | **убит**: native `bound_order_axby`, `bound_typed_reception`, `named_actuals_selected`, `copy_name_codes`, `formal_defaults` — программа падает (`driver exit -1073741819`, access violation: непринятое значение у формала выбранного другого типа читается телом как свой тип) или отказывает (`formal_defaults` root0 — выход 1); forced проходит ([лог](records/pins/tp151-probe-m305-3.log), [терминал](records/pins/tp151-probe-m305-3.terminal.txt)); возврат [лог](records/pins/mut305-restore-m3.log) 260/0, `l2_frontend_lower.lm2` стейджа = selfbuild |
| m4 (rt168m4 `d14eda90…`/`ca80168d…`, `lmx_walk_values.lm2:6384` в `lmx_walk_selected_values`: `lmx_walk_selected_form` не вызывается — `status: c.LMX_WALK_OK`) | проверка обязательных входов в форме обходчика | **убит** forced (`bound_order_axby` оба корня: `Dflt\f(x := touch())` — `touch()` выполнен, `call` лишь из умолчаний готовой фазы — выход 88); native проходит (у native своя форма, `lmx_call_bind_form`) ([лог](records/pins/tp151-probe-m305-4.log), [терминал](records/pins/tp151-probe-m305-4.terminal.txt)); возврат [лог](records/pins/mut305-restore-m4.log) 260/0, `lmx_walk_values.lm2` стейджа `817709bc…` = selfbuild |

Четыре из четырёх убиты; каждая сторона (native, обходчик) ловит снятие своей фазы формы и своего приёма сразу; у обоих
исполнителей фазы разные функции при одном соответствии (`lmx_callable_bind_prefix`) и одном приёме (`lmx_walk_receive_selected`).

## Границы

- CALL-ENTRY-ADMISSION-ORDER (новая запись реестра, OPEN — обязательный остаток AXBY по ревью Codex 305): допуск всякого
  фактического, который не число (Structure моделью формала, ссылка, указатель, callable, свободное значение — ветви «любое
  другое значение ждёт входа вызываемого» обоих исполнителей), выполняется на входе вызываемого после вычисления всех
  фактических — у статического и связанного вызова одинаково; по книге :724 и решению автора правило — для каждого аргумента.
  Срез перенёс к месту фактического только числовой приём и форму; срез в целом — промежуточный результат AXBY, не его
  закрытие. Перенос существующего допуска сразу после своего фактического, одним механизмом для обоих видов вызова и обоих
  исполнителей, — следующий срез; решение автора не требуется.
- Скрытый вход EXEC (суффикс транспорта), который связывается с формалом выбранного и подан отсутствующим при исполнении
  (не пустым слотом кадра): умолчание или `call` даёт готовая фаза, после фактических, как прежде; статическое отсутствие
  (пустой слот) форма учитывает заранее. Экзотический путь; фикстурой не покрыт.
- Статический вызов: форма проверяется при трансляции, каждый фактический принимается сразу — без изменений (реестр).
- IDENTIFIER-CODES: соответствие формалов выбранного — по кодам имён (`l2_bn` — коды единицы; обходчик — код обёртки NAMED),
  как требовало поручение; остаток перехода (внутренние сравнения транслятора, транслятор L1, тесты RESULT) — открыт.

## Документы

- [Реестр дефектов](../../defects.md): CALL-ARGUMENT-ORDER-AXBY — CLOSED срезом 305 (абзац «Срез 305»: механизм, фикстура,
  граница); заголовки CALLABLE-PLACE-TYPED-RECEPTION (остаток — IDENTIFIER-CODES) и IDENTIFIER-CODES (AXBY — срез 305);
  новая запись CALL-ENTRY-ADMISSION-ORDER (OPEN).
- [steps/current.md](../../current.md): абзац среза 305 перед абзацем ревью 304; строка «Дальше» — AXBY закрыт, граница
  CALL-ENTRY-ADMISSION-ORDER.
- [selfbuild/README.md](../../../selfbuild/README.md): 260 входов (66 исходников, 34 инструмента, 160 тестов); абзац Slice305
  после Slice304; фраза о связанном вызове в абзаце Slice301 («the bound call does that since slice305»); исправлена
  устаревшая фраза абзаца Slice304 (`merge(tst\args)` читал `a` = 0 — после ревью 304 операнд без позднего писателя
  отказывает).
- Книга (:724 — норма), заметки о реализации, журнал LMX_blog — без изменений (новых реплик автора нет).
- Проверка документов `docs check` по индексу git ([список](records/pins/docs305-check-a.tsv), рецепт checks303 с приватным
  каталогом вывода): проход a — 0 отказов после переписи из индекса 48 CRLF-копий логов pwsh по `git ls-files --eol`
  ([crlf305-1](records/pins/crlf305-1.list); [лог](records/pins/docs305-check-a.log)); проход b после второго прохода архива
  (ещё 4 копии переписаны, `crlf305-2.list` в P) — 0 отказов («35 paired semantic chapters … line endings LF»;
  receipt `docs305-check-b.*` в P); проход c над окончательным индексом — receipt только в P, как у 303–304.
- Архив — `steps` ([arch305-1](records/pins/arch305-1.tsv): 75 путей P по [records305.list](records/pins/records305.list),
  копии проверены 75/0; второй проход — receipts первого прохода и проверки a, 9 путей; [evidence.list](evidence.list) и
  [evidence.sha256](evidence.sha256) — объединение обоих манифестов, 83 пути P).

## Ревью Codex 305 (CODEX-FABLE-305-REVIEW-20261108042451Z-01, [копия](records/pins/CODEX-FABLE-305-REVIEW-20261108042451Z-01.txt))

Codex прочитал 58740252 read-only (HEAD = origin, 260 блобов = manifest `6ca4650c…`, diff, фикстура, экспорты, receipts) и
подтвердил проверенный числовой объём. Два пункта.

1. Приёмка AXBY автора остаётся PARTIAL/OPEN, пока открыт CALL-ENTRY-ADMISSION-ORDER: книга :724 и решение автора — для
   каждого аргумента, не только чисел. Исправлено: заголовок записи реестра — OPEN, срез 305 — промежуточный результат
   (имена, форма, числовой приём), обязательный остаток — CALL-ENTRY-ADMISSION-ORDER; фразы «связанный вызов следует
   правилу» и «статический вызов уже следует ему» уточнены объёмом (форма и числа; допуск прочих значений — на входе);
   запись CALL-ENTRY-ADMISSION-ORDER расширена на все значения, которые ветви «любое другое значение ждёт входа
   вызываемого» откладывают (Structure, ссылка, указатель, callable, свободное значение), для обычного и связанного вызова,
   как обязательный остаток без решения автора; заголовки CALLABLE-PLACE-TYPED-RECEPTION и IDENTIFIER-CODES, current, README
   и этот документ исправлены так же. Ограничение скрытого суффикса оставлено явным (Границы).
2. Вопрос согласованности частей: обходчик берёт часть args один раз до фактических (`lmx_walk_selected_inputs`), native
   перечитывает `lmx_callable_headers(code)` в `lmx_call_bind_receive`/`finish`/`lmx_call_formal_default`; снятый
   комментарий обходчика говорил о замене части эффектами операндов. Достижимость по поддерживаемой модели частей:
   `merge` строит новый узел и не пишет `f\args` (срез 304); путь в часть (`f\args\a`) не разрешается («unknown field path
   segment»); умолчание (поле 2 записи формала) пишет только эмиттер заголовка при построении (`lm_compiler_rw_formal_default`),
   операции над ним в языке нет; перепись места вызываемого (`@: Places\f other`, в том числе из фактического или ресивера)
   меняет место, а не выбранный узел — `l2_c` native и `callee` обходчика выбраны один раз до фактических;
   `LMX_WALK_OP_LAYOUT_SWITCH` выбирает ветвь по раскладке данных, частей не меняет; в ядре нет функции, пишущей слот части
   вызываемого (`lmx_graph_ref_store_in` по узлу кода — только у построения литералов и записей). Замена части на месте
   недостижима — свидетеля нет и не строится; точная граница записана в реестр (CALL-ENTRY-ADMISSION-ORDER, второй абзац):
   перечтение заголовков того же узла и захваченная до фактических часть разрешаются в одну часть; операция, заменяющая
   часть на месте, если появится, должна признать план формы негодным в обоих исполнителях одним правилом — не
   заморозкой и не перепривязкой. Новой нормы не выводится; whole-arguments не трогается.

## Открыто

- CALL-ENTRY-ADMISSION-ORDER — допуск всех нечисловых фактических сразу после своего аргумента у обычного и связанного
  вызова, native и обходчик (обязательный остаток AXBY; следующий срез).
- Остаток IDENTIFIER-CODES: внутренние сравнения транслятора (P0, области видимости, resolve, intern сигнатур,
  `lm_compiler_throw_key`), транслятор L1, тесты RESULT; затем RESULT.
- Удержание whole-arguments (вопрос Codex автору) — без изменений.

## Провенанс

Правки исходников и документов — Edit/Write; блочные замены в `lmx_walk_values.lm2` и `l2_frontend_lower.lm2` — `sed` по
номерам строк, вычисленным по якорям (`grep -n` уникальных строк) с печатью границ до удаления, вставка из файлов
scratchpad; мутанты — `sed` по точной строке стейджа с печатью до и после. Списки `tp168-*`, `probe305-a.tsv`,
`registry305-a.tsv` (байты full-suite.tsv), `records305*.list`, `allow305-1.list` — `printf`/`grep`/`cp`; рецепты — копии
рецептов tp167/boot167 с заменой имён и хешей (`sed`, строки с путями `\` не правились; tp168-tool/rt/fe/boot168-quick —
Write). Каждый список исполнен `steps`/`checks`/`suite` без отказа строки; каждый запуск — из своего нового каталога.
Возвраты после мутантов — `stage-copy` из варианта tp168 по манифесту его файлов с проверкой всего стейджа и сверкой хеша
восстановленного файла с selfbuild. Чтения артефактов — только по точным именам (`run-root0.log`, логи pins); защищённый
basename не читался, каталоги не перечислялись.
