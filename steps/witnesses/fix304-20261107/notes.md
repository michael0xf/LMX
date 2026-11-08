# Срез 304 — операнд `merge` «часть вызываемого» `f\args`: args вызываемого как Structure его формалов

fable_pc, 2026-11-07/08. Остаток поручения автора о `merge` (CODEX-OPUS-AUTHOR-FINISH-ASSIGN-MERGE-NATIVE-WALKER-20261107-01;
пример автора `test(merge(test\args; (a: int: 5)))`, [журнал](../../../LMX_blog/2026-11-07.md)) после среза 303, в его
независимой части: операнд `merge`, записанный частью `args` вызываемого (MERGE-OPERAND-FORMS, [реестр](../../defects.md)).
Норма — [книга](../../../docs/LMX_semantics.ru.md#whole-arguments) (`mytest\args` — часть `args` вызываемого: формал `c` с
записанным умолчанием 3 и обязательный `a`; результат `merge` — Structure с `c` = 3 и `a` = 5; `merge` строит новое
значение и не пишет в `mytest\args`) и [явная композиция тела вызываемого](../../../docs/LMX_semantics.ru.md#composition)
(«отдельные варианты … композицию `add\args`»). Подача результата единственным позиционным аргументом
(CALL-WHOLE-ARGUMENTS-STRUCTURE) удержана: Codex (CODEX-FABLE-304-CHOICE-HOLD-20261107T233359456Z-01,
[копия](records/pins/CODEX-FABLE-304-CHOICE-HOLD-20261107T233359456Z-01.txt)) не утверждает ни чтения «два метода одного
имени», ни чтения «два чтения одного требования» и задал автору один вопрос о записи этих двух методов; срез не вводит ни
новой ветви `lmx_call_bind_actuals`, ни соответствующего понижения.

## Проект

1. Значение части `args` вызываемого — Structure его формалов: по полю на каждый записанный формал, в порядке формалов,
   со значением текущего умолчания формала (`lmx_walk_current_default` — то, что формал получает, когда вызов его опускает,
   срез 293); формал без умолчания держит ноль своего типа, как типизированное объявление без значения, записанное операндом
   (`lmx_walk_field_map`). Читает ядро — одна функция обоих исполнителей `lmx_callable_args_value` (конец модуля
   `lmx_walk_values`; `lmx_callable_headers` → часть args, `lmx_walk_args_formal` считает формалы — они стоят первыми, скрытые
   входы за ними; свежая owned Structure арены, ячейки типа свидетеля формала, имена полей — коды имён формалов, снятые с
   ячеек части args тем же чтением, что `lmx_implements_place_name`); вызываемое не пишется. Для программы обходчика — PRIM
   `lmx_walk_args_value_map` с одним входом, вхождением вызываемого (отказ ядра — бросок `merge`, как у `lmx_walk_merge_map`).
   Экспорт обоих — `walk_value_names[170..171]` (`tools/build.lm2`; заголовок `lmx_walk_values.h.lm1` пишет tool).
2. Распознавание операнда — `lm_compiler_merge_args_callee` (конец `l2_frontend_useplan`, экспорт `frontend_useplan_names[151]`):
   тот же факт пути, который читает всякое чтение операнда (`lm_compiler_reference_source` → `source\path`); факт без
   пройденных шагов проходится как связанный путь (`lm_compiler_source_use_resolve`); последний шаг — часть 0 (args) метода
   (`lm_compiler_method_part_seg`, locus 5, row 0) → метод `ent`, иначе −1. Никакого разбора текста операнда: один общий
   алгоритм пути.
3. Форма 4 операнда `merge` (`lm_compiler_merge_decl_operand`, перед общим отказом): `lm_compiler_mu_operand_model` — у формы
   нет модели (как у формы 3); карта слотов результата `lm_compiler_mrs_build` присоединяет формалы как типизированные поля
   их объявлений (`lm_compiler_lit_field_kind` объявления формала: род и слово типа; `lm_compiler_mrs_join` по порядку
   формалов — INTO слот своего имени при совпадении рода), у одно-операндного `merge` без тела источник результата остаётся
   собственным (как у формы 3); native (`lm_compiler_emit_stmts_with_position`, цикл операндов): `l2_margs: 0`,
   `lmx_callable_args_value(l2_program_arena, <вхождение lm_compiler_occ_expr>, @ l2_margs) != c.LMX_WALK_OK` → неявный бросок
   `merge`, `l2_mops[k]: l2_margs`; свежий операнд без профиля (как форма 3); `l2_margs` объявлен среди локалов `merge`
   (`@: Lmx l2_margs 0`); обходчик (`lm_compiler_rw_merge_prim`): `lm_compiler_rw_merge_args_operand` — PRIM с fn
   `lmx_walk_args_value_map`, вход — `lm_compiler_rw_method_occurrence`, контракт одного Structure-входа.
4. Предел реализации, сказанный у операнда: формал не числового типа не имеет рода поля в карте результата —
   «a formal that is not a number is not lowered as a field of the args part yet» (`lm_compiler_mrs_build`); ядро отвечает
   UNSUPPORTED на такой свидетель. Не правило языка (у формалов других типов и умолчание не строится — срез 293,
   `lm_compiler_formal_default_kind` = 2).
5. Фикстуры: `merge_args_operand` (tst (int: c 3; int: a): `merge(tst\args; (a: int: 5))` — a = 5, c = 3; голая форма
   `a: int: 5` — то же; `merge(tst\args)` — c = 3, a = 0; `tst(a := 1)` = 31 после слияний: источник не записан; выход 7,
   81..87 — отказавшая проверка), `merge_args_model_formal_refused` (формал `Point: p` — отказ п. 4 в 10:17). Ряды
   `tests/full-suite.tsv` 206–207, `inputs.list` 257 входов.

## Устройство

P = `C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01`; стейдж `cold-tp140` (= selfbuild a15 среза 303 перед
правками), вариант `variants/tp166`, кандидаты `tp166-changed-aNN.list/.sha256`, манифесты стейджа `source-tp166-aNN.sha256`
([tp166-prepare](records/pins/tp166-prepare.command), `steps` рабочего tool boot164a `8b106da5…`). Tool среза `tool166a`
(`cold-tp140/tool166a/lmxtool-tool.exe`, `3d4ff36bb264cadcad25aa8b0f4328486d5dd47a688acca585e947e32394ef75`) — `rebuild tool`
опубликованного кортежа boot165b (G2 tool `c5de7e8f…`, frontend `0c287001…`, runtime `f5eaed6f…`/`4e3fc11a…`;
[tp166-tool](records/pins/tp166-tool.command), [терминал](records/pins/tp166-tool-a01.terminal.txt),
[лог](records/pins/tp166-tool-a01.log), 00:07:00→00:08:19Z, smoke 0 отказов) — `tools/build.lm2` экспортирует две функции
ядра и распознаватель; runtime среза — `build-runtime` новым tool с G2 frontend boot165b ([tp166-rt](records/pins/tp166-rt.command));
frontend среза — `build-frontend` новым tool с G2 frontend boot165b ([tp166-fe](records/pins/tp166-fe.command)).

| Кандидат | Изменено | Сборка | Итог |
| --- | --- | --- | --- |
| a01 | tools/build.lm2, lmx_walk_values.lm2, l2_frontend_useplan/lower/emit.lm2, inputs.list, full-suite.tsv, 2 фикстуры | tool166a | собран, smoke 0 |
| a01 | то же | rt166a | отказ трансляции `lmx_walk_values.lm2:8010:8: node is a word of the language: a program cannot bind it` ([лог модуля](records/cold-tp140/rt166a/lmx_walk_values.L2.log)) — локал `node` новых функций |
| a02 | lmx_walk_values.lm2 (локал `node` → `built`) | rt166b | собран (00:10:38→00:11:25Z): driver.o `d1ccbcd4…`, driver-observe.o `15b67666…`, заголовок `lmx_walk_values.h.lm1` `809a24d8…` (172 прототипа) |
| a02 | — | fe166a | собран (00:11:47→00:15:51Z): l2trans `6c07f464…`; проба [p304b](records/pins/probe304-b.tsv) на tool166a/fe166a/rt166b ([терминал](records/pins/tp151-probe-p304b.terminal.txt), [лог](records/pins/tp151-probe-p304b.log)): `merge(tst\args; …)` по-прежнему «this merge operand form is not lowered yet» — распознаватель требовал операнда в одно поле, а путь — ряд полей (косая — свой атом) |
| a03 | l2_frontend_useplan.lm2 (ограничение `span != 1` снято: весь ряд полей — операнд) | fe166b | собран (00:17:18→00:20:55Z): l2trans `0ef1db3d…`, l1trans `d4192827…`; проба p304c на tool166a/fe166b/rt166b ([терминал](records/pins/tp151-probe-p304c.terminal.txt), [лог](records/pins/tp151-probe-p304c.log)): трансляция проходит, контроль `merge_args_model_formal_refused` — отказ с иглой в обоих исполнителях, но `merge` бросает (p302n_m: 91, фикстура: R0 остановлен); gdb на native-программе ряда ([receipt](records/pins/gdb304-fe166b-p302n_m_merge.txt)): `lmx_callable_args_value` отвечает 5 = UNSUPPORTED после обоих формалов — счёт формалов шёл за число источников части на ребро LAST, которое `lmx_walk_args_formal` читает формалом, и третий `lmx_callable_source_entry` отказывал |
| a04 | lmx_walk_values.lm2 (счёт формалов ограничен `lmx_callable_source_count`, как в `lmx_call_bind_actuals`) | rt166c | собран (00:27:21→00:28:08Z): driver.o `c03afca5…`, driver-observe.o `dddeb0ec…`; заголовок тот же `809a24d8…`; проба p304d на tool166a/fe166b/rt166c — см. «Результаты» |

## Результаты

Проба на опубликованном кортеже (tool165b `850707ed…`, fe165i `765a8404…`, runtime G2 boot164a;
[probe304-a](records/pins/probe304-a.tsv), [терминал](records/pins/tp151-probe-p304a.terminal.txt),
[лог](records/pins/tp151-probe-p304a.log)): `merge(tst\args; a: int: 5)` — «this merge operand form is not lowered yet» в
10:17 (пробы Opus p302n_m, p302n_m2), чтение `tst\args\c` путём — «unknown field path segment» в 8:22
([p304a_args_read](records/cold-tp140/tests/dyn/p304a_args_read.lm2)); native и forced.

| Шаг | Результат | Receipts |
| --- | --- | --- |
| Фокус p304d (a04) | [probe304-b](records/pins/probe304-b.tsv) на tool166a `3d4ff36b…`, fe166b `0ef1db3d…`, rt166c `c03afca5…`/`dddeb0ec…`: `merge_args_operand` 7 native и forced, оба корня; `merge_args_model_formal_refused` — отказ с иглой `:10:17: a formal that is not a number is not lowered as a field of the args part yet` в обоих исполнителях; проба Opus p302n_m — 7 в обоих; p302n_m2 — отказ трансляции `unknown field path segment` (путь `tst\args\c`, вне среза) (00:28:18→00:28:25Z) | [терминал](records/pins/tp151-probe-p304d.terminal.txt), [лог](records/pins/tp151-probe-p304d.log) |
| Фокус p304e (a05) | тот же список на том же кортеже, фикстура `merge_args_operand` расширена проверкой `later()` (`merge(Args; two\args)`): 18/18 проверок двух фикстур и p302n_m, p302n_m2 — прежний отказ пути (00:53:17→00:53:25Z) | [терминал](records/pins/tp151-probe-p304e.terminal.txt), [лог](records/pins/tp151-probe-p304e.log) |
| Реестр на кандидате a04 | весь поддерживаемый реестр — байты `selfbuild/tests/full-suite.tsv` ([копия](records/pins/registry304-a.tsv), `efc7a3fa…`): 132 ряда, 0 отказов, 1060 проверок, 00:28:56.76→00:44:24.52Z (927.76 с); native и forced, оба корня; тот же кортеж | [терминал](records/pins/tp151-probe-r304a.terminal.txt), [лог](records/pins/tp151-probe-r304a.log) |
| Реестр на кандидате a05 | те же байты списка (фикстура `merge_args_operand` расширена), тот же кортеж tool166a `3d4ff36b…`, fe166b `0ef1db3d…`, rt166c `c03afca5…`/`dddeb0ec…`: 132 ряда, 0 отказов, 1060 проверок, 00:53:48.51→01:09:16.58Z (928.07 с) | [терминал](records/pins/tp151-probe-r304b.terminal.txt), [лог](records/pins/tp151-probe-r304b.log) |
| Стейдж bootstrap | `steps` рабочего tool boot164a по [boot166a-prepare](records/pins/boot166a-prepare.tsv) ([рецепт](records/pins/boot166-prepare.command)): 5/0, стейдж `cold-boot166a` 257/0, source-boot166a = source-tp166-a05 (`same` 1), 01:09:27.14→01:09:28.83Z | [лог](records/pins/boot166a-prepare.log), [терминал](records/pins/boot166a-prepare.terminal.txt) |
| Whole boot166a | [boot166-quick](records/pins/boot166-quick.command) через [boot166-detached](records/pins/boot166-detached.command): 01:09:39.87→01:20:54.29Z, BootstrapExit 0, 674.41 с; `BOOTSTRAP quick 0 failures`; smoke 9/0 в обеих генерациях; G0 — tool166a стейджа `3d4ff36b…` (`tools/build.lm2` изменён срезом: экспорт двух функций ядра и распознавателя), предыдущий frontend — G2 boot165b `0c287001…`; G2: lmxtool.exe = g2/tool `ace2a5d8…`, l2trans `44b2fe8f…`, l1trans `2de79a84…`, l2_libc.o `af9fdae3…`, driver.o `c03afca5…`, driver-observe.o `dddeb0ec…` (байт в байт rt166c) | [терминал](records/pins/boot166a-quick.terminal.txt), [лог](records/pins/boot166a-quick.log), [verify](records/pins/boot166a-quick-verify.log), [launcher](records/pins/boot166a-detached.terminal.txt) |
| Приёмка `checks` | рабочий tool boot164a, [список](records/pins/boot166a-check.tsv) ([рецепт](records/pins/checks303.command)): 38/0 (01:21:10.40→01:21:10.77Z) — стейдж 257/0; записи producers G1 и G2 и запись сборки G2 замкнуты, без script host; G1 и G2: `exe-same` l2trans, l1trans, tool, `same` l2_libc.o, driver.o, driver-observe.o, lmxtool.lm1/.c, consumed-inputs; рабочий tool = G2, bundle = G2; rt166c `same` G2 runtime (оба объекта), fe166b `exe-same` G2 frontend (l2trans, l1trans), `same` l2_libc.o; хеши | [лог](records/pins/boot166a-check.log), [терминал](records/pins/boot166a-check.terminal.txt) |

## Мутанты

Каждый мутант — правка одной строки стейджа `cold-tp140` (`sed` по номеру строки, diff с рабочей копией — одна строка),
сборка кандидатного runtime или frontend с меткой мутанта, фокус [probe304-m](records/pins/probe304-m.tsv) (две фикстуры
среза и проба p302n_m) на tool166a с мутантной сборкой, возврат стейджа [mut304-restore](records/pins/mut304-restore.command)
(`stage-copy` из варианта tp166 по манифесту его девяти файлов, `verify` всего стейджа по source-tp166-a04) с проверкой
`diff` рабочей копии.

| Мутант | Что снято | Итог |
| --- | --- | --- |
| m1 (rt166m1, `lmx_walk_values.lm2:8057` `if: current\present < 0`: текущее умолчание формала не записывается в ячейку поля) | значение формала в Structure args | убит: `merge_args_operand` и p302n_m — выход 82 (`c` ≠ 3) в native и forced, оба корня (8 отказов из 8 запусков; контроль отказа проходит) — [лог](records/pins/tp151-probe-m304a.log), [терминал](records/pins/tp151-probe-m304a.terminal.txt), сборка [терминал](records/pins/tp166-rt-m1.terminal.txt); возврат [лог](records/pins/mut304-restore-m1.log) 257/0 |
| m2 (rt166m2, `lmx_walk_values.lm2:8096`: примитив `lmx_walk_args_value_map` отдаёт вхождение вызываемого вместо построенной Structure) | результат примитива в программе обходчика | убит только в forced: `merge_args_operand` и p302n_m — R0 остановлен (4 отказа из 4 forced-запусков), native проходит (его `merge` зовёт `lmx_callable_args_value` напрямую) — [лог](records/pins/tp151-probe-m304b.log), [терминал](records/pins/tp151-probe-m304b.terminal.txt), сборка [терминал](records/pins/tp166-rt-m2.terminal.txt); возврат [лог](records/pins/mut304-restore-m2.log) 257/0 |
| m3 (fe166m3 `6c6d2c73…`, `l2_frontend_emit.lm2:16030`: каждый формал присоединяется к карте результата полем операнда 0 — `lm_compiler_mrs_join(res, k, 0, …)` вместо `j`) | индекс поля формала в парах карты результата | **пережил** фокус на фикстуре a04 (18/18 проверок прошли — [лог](records/pins/tp151-probe-m304c.log)): первый операнд `merge` копируется по позициям, индекс поля читается лишь у пары позднего операнда (`lm_compiler_mrs_join`: поиск слота по имени только при `k > 0`), а `tst\args` стоял только первым; фикстура расширена (a05): `later()` — `merge(Args; two\args)` для `two (int: c 3; int: a 4)` читает `c` = 3 и `a` = 4, `Args` не записан (88–90); повторный фокус на a05 ([лог](records/pins/tp151-probe-m304d.log), [терминал](records/pins/tp151-probe-m304d.terminal.txt)): убит — `merge_args_operand` в native и forced, оба корня, R0 остановлен (две пары карты читают одно поле операнда; выход 1, а не 89 — отказ ядра раньше чтения `pack\a`), контроль отказа и p302n_m проходят; возврат [лог](records/pins/mut304-restore-m3.log) 257/0 (до a05) |

## Границы

- Вся структура аргументов из одной Structure (`mytest(merge(mytest\args; (a: int: 5)))` = 35, та же Structure в переменной)
  — удержана по CODEX-FABLE-304-CHOICE-HOLD: вопрос Codex автору о записи двух методов; связыватель вызова
  (`lm_compiler_bind_value_actuals_into`) по-прежнему кладёт результат `merge` в первую позицию и отказывает «has no
  argument a». Ни (а) перегрузка одного имени, ни (б) два чтения одного требования не введены.
- Чтение поля части args путём (`tst\args\c`) не разрешается: `lm_compiler_method_part_own_seg` отвечает только за части var
  и body («unknown field path segment»). Вне среза; записано здесь.
- Формал не числового типа как поле результата `merge` — предел п. 4 проекта.
- Формал без умолчания в результате `merge` держит ноль своего типа (как `int: a` операндом): нормой не определено;
  измерено и закреплено фикстурой как поведение реализации, не как правило.

| Самотест G2 tool | G2 tool boot166a `ace2a5d8…` (= рабочий bundle), ребёнок `tool153a-child` `40c935bc…`, рецепт [tp152-selftest](records/pins/tp152-selftest.command): `SELFTEST 0 failures` (12 строк `FAIL` — ожидаемые отказы негативных проверок схемы, как у 298–303), 01:21:21.90→01:21:33.79Z | [терминал](records/pins/tp152-selftest-s304a.terminal.txt), [лог](records/pins/tp152-selftest-s304a.log) |
| Посадка | `steps` рабочего tool boot164a по [land304](records/pins/land304.tsv) ([рецепт](records/pins/steps303.command)): 9/0, `selfbuild/inputs.sha256` = source-tp166-a05 `b7356645…` (257 входов), G2 consumed = G1 consumed, стейдж boot166a держит байты G2, `variants/tp166/inputs.list` = selfbuild, 01:22:12.52→01:22:13.93Z | [лог](records/pins/land304.log), [терминал](records/pins/land304.terminal.txt) |

## Документы

- [Реестр дефектов](../../defects.md): MERGE-OPERAND-FORMS — CLOSED срезом 304 (абзац «Срез 304»: механизм, фикстуры,
  два предела); CALL-WHOLE-ARGUMENTS-STRUCTURE — статус «реализация удержана с 2026-11-07 23:33Z: вопрос Codex автору о
  записи двух методов», абзац «Срез 304» с содержанием сверки и удержания.
- [Книга](../../../provenance/semantics-book.md), абзац whole-arguments (RU и EN): статус примера — `:=` и краткая форма
  срезом 303, операнд `merge` `mytest\args` срезом 304, подача результата единственным аргументом не реализована, пока
  открыт вопрос Codex автору. Generated docs перерисованы и проверены ([docs304-render](records/pins/docs304-render.tsv),
  [лог](records/pins/docs304-render.log), [терминал](records/pins/docs304-render.terminal.txt)): изменены только две
  строки `docs/LMX_semantics.ru.md` и `docs/LMX_semantics.en.md`, грамматика без изменений.
- [Заметки о реализации 4.2](../../../docs/implementation-notes.ru.md#assign-named-merge) RU и EN: заголовок «реализация
  срезов 303–304, подача всей структуры удержана»; пункт об операнде `f\args` с пределами; пункт «Не сделано» — удержание
  304 и вопрос Codex.
- [selfbuild/README.md](../../../selfbuild/README.md): 257 входов (66 исходников, 34 инструмента, 157 тестов — счёт
  `inputs.list`; прежнее «247 … 147» не было обновлено срезом 303), абзац Slice304, статус whole-arguments в абзаце
  Slice303.
- [steps/current.md](../../current.md): абзац среза 304 перед абзацем 303.
- Журнал LMX_blog: новых реплик автора нет — не меняется.
- Проверка документов `docs check` по индексу git ([список](records/pins/docs304-check-a.tsv), рецепт checks303 с
  приватным каталогом вывода): проход a — 78 находок DOCS-EOL (копии логов в records — CRLF рабочие копии; переписаны из
  индекса, [crlf304-1](records/pins/crlf304-1.list), 133 пути) — [лог](records/pins/docs304-check-a.log); проход b — 1
  находка DOCS-CTRL: байт 7 (BEL) в комментарии рецепта `tp166-prepare.command` (строка 2, след `sed`-замены с `\a`);
  строка переписана из heredoc, архив повторён (arch304-1b) — [лог](records/pins/docs304-check-b.log); проход c — 0
  отказов («35 paired semantic chapters … line endings LF») — [лог](records/pins/docs304-check-c.log),
  [терминал](records/pins/docs304-check-c.terminal.txt); проход d над окончательным индексом (после второго прохода
  архива) — receipt только в P (`docs304-check-d.*`), как у 303.

## Провенанс

Правки исходников selfbuild и документов — Edit/Write и `sed` по точным строкам (замена локала `node` → `built` в
диапазоне новых функций); списки `tp166-changed-aNN.list`, `tp166-prepare-aNN.tsv`, `probe304-*.tsv`, `records304.list`,
`allow304-1.list` — `printf`; рецепты `.command` — копии рецептов 303/302 с заменой имён и хешей (`sed`), строки с путями
`\` — из heredoc. Каждый список исполнен `steps`/`checks`/`suite` без отказа строки; каждый запуск — из своего нового
каталога (`P/<имя>-run`). Возвраты после мутантов — `stage-copy` из варианта tp166 по манифесту его файлов с проверкой
всего стейджа и `diff` рабочей копии. Диагностика броска `merge` на кандидате a03 — gdb из состава mingw на готовой
native-программе ряда p302n_m пробы p304c ([receipt](records/pins/gdb304-fe166b-p302n_m_merge.txt); командные файлы — в
scratchpad, стейдж не писался): чтение существующей сборки, не новая проба. Фикстуры-пробы `p304a_args_read` и пробы Opus
p302n_m, p302n_m2 — только в стейдже и записи, не в реестре. Архив — `steps` ([arch304-1](records/pins/arch304-1.tsv):
манифест 130 путей P по [records304.list](records/pins/records304.list), байтовые копии в [records](records), проверка
копий 130/0; второй проход — receipts первого прохода и docs check, [evidence.list](evidence.list) обоих проходов,
[evidence.sha256](evidence.sha256) против P). Логи tool в P — CRLF (перенаправление pwsh); git держит их копии с LF.

## Отклонения

1. Первая попытка правки строк рецепта с путями `\` через `sed` съела обратные косые (`\c`, `\q`, `\f`, `\r` как
   escape-последовательности): строки переписаны из heredoc; содержательных последствий нет (рецепт не запускался в
   испорченном виде — его проверка хеша отказала бы).
2. Кандидат a01 ядра отказал по слову языка `node` (локал); исправлено переименованием (a02), без изменения смысла.
3. Нарушение правила передачи о basename `l2_driver_launch.err`: при разборе отказа p304c каталог ряда
   `tp151-probe/p304c/merge_args_operand-native` был перечислен (`ls`) и цикл по именам `root0|r0|run|err|out` вывел
   начало этого файла (то же содержание, что у `run-root0.log`). Файл не менялся и не архивируется; дальнейшие чтения —
   только по точным именам `run-root*.log`, `p.L2.log`, `p.lm1`.
4. Мутант m3 пережил первый фокус как эквивалентный для первого операнда (индекс поля читается лишь у поздних операндов);
   не «чиненный» мутант, а расширенная фикстура: проверка позднего операнда `merge(Args; two\args)`, после чего m3 убит.
   Реестр перезапущен на a05 (r304b).
5. `sed`-замена в комментарии рецепта `tp166-prepare.command` превратила `\a` в байт BEL (как прежде в MEMORY.md); найдено
   проверкой документов (DOCS-CTRL) по архивной копии, строка переписана из heredoc, архив повторён. Рецепт исполнялся с
   испорченным комментарием (a01–a05) — комментарий не влияет на его команды.

## Открыто

- Вопрос Codex автору о записи «двух методов» whole-arguments; реализация CALL-WHOLE-ARGUMENTS-STRUCTURE — после ответа.
- Чтение полей части args путём (`f\args\c`).
- Формалы не числовых типов как поля результата `merge` над `f\args`.
