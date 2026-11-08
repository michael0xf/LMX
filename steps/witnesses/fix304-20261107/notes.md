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
   срез 293); формал без текущего умолчания значения не держит — его слот пуст (ревью Codex 304, раздел ниже; до ревью срез
   держал ячейку нуля, как у операнда `int: a`, `lmx_walk_field_map`). Читает ядро — одна функция обоих исполнителей `lmx_callable_args_value` (конец модуля
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
   `a: int: 5` — то же; `merge(tst\args)` — c = 3, a = 0 (придуманный ноль, снят ревью — см. ниже); `tst(a := 1)` = 31
   после слияний: источник не записан; выход 7, 81..87 — отказавшая проверка), `merge_args_model_formal_refused` (формал
   `Point: p` — отказ п. 4 в 10:17). Ряды `tests/full-suite.tsv` 206–207, `inputs.list` 257 входов (до ревью).

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

## Ревью Codex 304 (CODEX-FABLE-304-REVIEW-20261108013621Z-01, [копия](records/pins/CODEX-FABLE-304-REVIEW-20261108013621Z-01.txt))

Пункты ревью: (1) обязательный формал — не числовой ноль: книга :432 (`int: x` описывает место без начального значения),
:726 (ноль — тоже поданное значение; без аргумента и допустимого дефолта вызов отказывает), :738 (`a` обязательный);
`lmx_callable_args_value` безусловно создавала ячейку нуля, фикстура `alone()` закрепляла придуманное значение — сохранить
отсутствие через общее представление и слияние, поздний операнд может заполнить, явный ноль остаётся отличимым, первый
операнд, который заполняет поздний, не отвергать; пересмотреть путь типизированного операнда, не возобновляя паузу
REPEATED-DECL; (2) формал с записанным, но не построенным умолчанием (`lm_compiler_formal_default_kind` = 2; поле 2 записи
пусто, `lm_compiler_rw_formal_default`) та же функция обращала в ноль — предел реализации, а не вычисление умолчания при
чтении `f\args` (правило автора — вычисление в каждом вызове без аргумента; FORMAL-DEFAULT-FORMS остаётся OPEN); парные
проверки missing / explicit-zero / later-filled и нелитеральное умолчание; c = 3, a = 5 сохранить; (3) защищённый basename
больше не читать и не перечислять каталоги артефактов; запись инцидента сохранить.

Проект исправления (кандидат tp167 a01):

1. Ядро (`lmx_callable_args_value`): формал с текущим умолчанием — ячейка типа свидетеля с его значением; формал без
   него — слот остаётся пустым (открыт `lmx_arena_refs_open_owned`, ничего не сохранено); имя формала несёт слот — пустой
   тоже (`lmx_source_name_set` по адресу слота). Пара позднего операнда (`lmx_merge_apply_pair`) кладёт в слот значение.
   Ни одна программа пустой слот не читает — это гарантирует транслятор (п. 2): native-эмиттер читает числовое поле по пути
   с инвариантом «a field path reads an absent place» (READ-FIELD-CLOSURE: числовая ячейка никогда не пуста там, где
   держится; пустая — место, которого частичная копия не держит), обходчик — INVALID; книга :993: нарушение инварианта
   ядра — диагностика стадии, не отказ, который ловит `catch`. Представление «место без значения» у чисел ядро не держит
   (у `LmxWalkValue` есть `present`, у ячейки — нет), поэтому отсутствие представлено единственным существующим способом —
   пустым слотом, как часть args держит отсутствие умолчания пустым полем 2.
2. Транслятор (`lm_compiler_mrs_build`, после сборки карты, включая тело как операнд n): для каждого операнда формы 4 и
   каждого формала с родом умолчания 0 или 2 — слот формала в карте (`lm_compiler_mexec_slot(res, k, j)`) должен писать
   операнд с номером больше k (строки соответствия `l2_msrc_*`: `op > k`, тот же слот); иначе отказ у операнда: род 0 —
   «a formal with no default that no later operand writes is not lowered as a field of the args part yet», род 2 — «a formal
   whose written default is not built and that no later operand writes is not lowered as a field of the args part yet».
   Предел фазы, не правило языка: что читает программа из незаполненного обязательного формала и пишет ли незаполненный
   поздний операнд поверх значения модели, не решено (без слова автора); первый операнд, который заполняет поздний,
   допускается; умолчание при чтении `f\args` не вычисляется.
3. Фикстура `merge_args_operand` переписана (выход 7, 81..96): `parens`/`bare` — c = 3, a = 5 (прежние); `zero` —
   `merge(zed\args)` для `zed (int: c 3; int: z 0)`: c = 3, z = 0, и `zed()` = 30 (явный ноль — значение); `later` —
   `merge(Args; two\args)`: c = 3, a = 4, `Args` не записан (прежняя); `filled` — `merge(Args; tst\args; (a: int: 5))`:
   незаполненный `a` поздним операндом, заполненный следующим — c = 3, a = 5, `Args` не записан; `computed` —
   `merge(comp\args; (a: int: 5))` для `comp (int: c 3; int: a 2 + 3)`: c = 3, a = 5, умолчание не вычислено;
   `tst(a := 1)` = 31. Контроли отказа: `merge_args_unfilled_refused` (`merge(tst\args)` — 9:17, род 0),
   `merge_args_computed_default_refused` (`merge(comp\args)` — 10:17, род 2). Ряды `tests/full-suite.tsv` 206–209,
   `inputs.list` 259 входов.
4. Типизированный операнд без значения (`int: w`, `lmx_walk_field_map`, PRIM [kind]) пересмотрен без изменения: по
   комментарию ядра это ячейка неизвестного содержимого в памяти (автор, q56; нулевое заполнение — акт арены, не
   инициализатор языка) — объявленное место, а не слот формала без значения; REPEATED-DECL на паузе автора. Сказано Codex
   в отчёте.

Кандидаты ревью (стейдж cold-tp140, вариант tp167; рецепты — копии рецептов 304 с заменой имён: tp167-prepare/rt/fe,
mut304r-restore, boot167-prepare/quick/detached; рабочий tool рецептов — boot164a `8b106da5…`, tool стейджа — tool166a
`3d4ff36b…` без изменений (`tools/build.lm2` ревью не трогает), предыдущий frontend — G2 boot166a `44b2fe8f…`):

| Кандидат | Изменение | Сборки | Результат |
|---|---|---|---|
| a01 | lmx_walk_values.lm2, l2_frontend_emit.lm2, три фикстуры, full-suite.tsv (ряды 208–209), inputs.list (259) — [список](records/pins/tp167-changed-a01.list), [prepare](records/pins/tp167-prepare-a01.tsv), [лог](records/pins/tp167-prepare-a01.log) 5/0, стейдж 259/0 | rt167a: driver.o `d7e7c4bf…`, driver-observe.o `857dcb0c…` ([терминал](records/pins/tp167-rt-a01.terminal.txt), [лог](records/pins/tp167-rt-a01.log), 02:01:44→02:02:32Z); fe167a: l2trans `83d25d35…`, l1trans `292bc0e4…`, l2_libc.o `af9fdae3…` ([терминал](records/pins/tp167-fe-a01.terminal.txt), [лог](records/pins/tp167-fe-a01.log), 02:04:34→02:08:11Z) | собраны с первого раза |
| a02 | только full-suite.tsv: комментарий ревью (4 строки) перед его рядами — [prepare](records/pins/tp167-prepare-a02.tsv), [лог](records/pins/tp167-prepare-a02.log) 5/0, стейдж 259/0, [source-tp167-a02](records/pins/source-tp167-a02.sha256) | те же rt167a, fe167a | стейдж = selfbuild |

Результаты ревью:

| Шаг | Результат | Receipts |
|---|---|---|
| Фокус p304r-a (a02) | [probe304-r1](records/pins/probe304-r1.tsv) на tool166a / fe167a / rt167a: 10 рядов, 54 PASS, 2 FAIL — оба у пробы Opus `p302n_m2_merge_source` (native и forced: отказ трансляции `14:22: unknown field path segment` — путь в часть args `tst\args\a`, предел 304, не ревью); `merge_args_operand` 7 native и forced, оба корня; `merge_args_unfilled_refused` 9:17 и `merge_args_computed_default_refused` 10:17 — отказ с иглой, L1 не оставлен, native и forced; контроль 304 и ряды умолчаний 293 проходят | [терминал](records/pins/tp151-probe-p304r-a.terminal.txt), [лог](records/pins/tp151-probe-p304r-a.log) |
| gdb на native-программе ряда `merge_args_operand` (p304r-a) | остановы на `lmx_callable_args_value` (RCX = arena, R8 = out), после `finish` — построенная Structure: у `tst\args` (parens; и вторым операндом в filled) и `comp\args` (computed) слот 1 пуст (child 0x0) и несёт код имени `a` (31), слот 0 — ячейка со значением 3 (код `c` 32); у `zed\args` слот 1 — ячейка со значением 0 (код `z` 27): явный ноль — значение, отсутствие — пустой слот; статус 0 при каждом вызове | [receipt](records/pins/gdb304r-fe167a-merge_args_operand.txt), [скрипт](records/pins/gdb304r.gdb) |
| Реестр на кандидате a02 | весь поддерживаемый реестр — байты `selfbuild/tests/full-suite.tsv` ([копия](records/pins/registry304-r1.tsv)): 134 ряда, 0 отказов, 1072 проверки PASS, native и forced, оба корня, кортеж tool166a `3d4ff36b…` / fe167a `83d25d35…` / rt167a `d7e7c4bf…`/`857dcb0c…`, 02:10:26→02:25:54Z | [терминал](records/pins/tp151-probe-r304r-a.terminal.txt), [лог](records/pins/tp151-probe-r304r-a.log) |
| Стейдж bootstrap | `steps` рабочего tool boot164a по [boot167a-prepare](records/pins/boot167a-prepare.tsv) ([рецепт](records/pins/boot167-prepare.command)): 5/0, стейдж `cold-boot167a` 259/0, [source-boot167a](records/pins/source-boot167a.sha256) `185952dd…` = source-tp167-a02 | [лог](records/pins/boot167a-prepare.log), [терминал](records/pins/boot167a-prepare.terminal.txt) |
| Whole boot167a | [boot167-quick](records/pins/boot167-quick.command) через [boot167-detached](records/pins/boot167-detached.command): G0 — рабочий tool опубликованного boot166a `ace2a5d8…` (`tools/build.lm2` ревью не меняет), предыдущий frontend — G2 boot166a `44b2fe8f…`; `BOOTSTRAP quick 0 failures`, smoke 9/0 (`SUITE 9 rows, 0 failures` в логе; `PASS bootstrap: actual G1 builds and tests whole G2`), 02:41:27→02:52:37Z (670 с); G2: tool `7e220363…`, l2trans `27a9b8a8…`, l1trans `c239dbe0…`, l2_libc.o `af9fdae3…`, runtime `d7e7c4bf…`/`857dcb0c…` | [лог](records/pins/boot167a-quick.log), [терминал](records/pins/boot167a-quick.terminal.txt), [verify](records/pins/boot167a-quick-verify.log), [detached](records/pins/boot167a-detached.terminal.txt) |
| Приёмка `checks` | рабочий tool boot164a, [список](records/pins/boot167a-check.tsv) ([рецепт](records/pins/checks303.command)): 38/0 (02:53:06.71→02:53:07.07Z) — стейдж 259/0; записи producers обеих генераций и G2-build-record закрыты и без script hosts; G1 = G2 (exe-same frontend и tool, same runtime, l2_libc.o, lmxtool.lm1/.c, consumed inputs); рабочий tool и bundle = G2; rt167a `same` G2 runtime; fe167a `exe-same` G2 frontend, его l2_libc.o `same`; хеши G2 | [лог](records/pins/checks304r-a.log), [терминал](records/pins/checks304r-a.terminal.txt) |
| Самотест G2 tool | G2 tool boot167a `7e220363…` (= рабочий bundle), ребёнок `tool153a-child` `40c935bc…`, рецепт [tp152-selftest](records/pins/tp152-selftest.command): `SELFTEST 0 failures` (12 строк `FAIL` — ожидаемые отказы негативных проверок схемы, как у 298–304), 02:53:24.74→02:53:36.73Z | [терминал](records/pins/tp152-selftest-s304r-a.terminal.txt), [лог](records/pins/tp152-selftest-s304r-a.log) |
| Посадка | `steps` рабочего tool boot164a по [land304r](records/pins/land304r.tsv) ([рецепт](records/pins/steps303.command)): 9/0, `selfbuild/inputs.sha256` = source-tp167-a02 `185952dd…` (259 входов), G2 consumed = G1 consumed (311 файлов проверены в стейдже), стейдж boot167a держит байты G2, `variants/tp167/inputs.list` = selfbuild, 02:53:37.31→02:53:38.78Z | [лог](records/pins/land304r.log), [терминал](records/pins/land304r.terminal.txt) |

Мутанты ревью (стейдж правится `sed` по точной строке, кандидатный frontend или runtime собирается с меткой мутанта, фокус
[probe304-r1](records/pins/probe304-r1.tsv) на tool166a / rt167a (или fe167a для мутанта ядра), возврат —
[mut304r-restore](records/pins/mut304r-restore.command) по [списку](records/pins/mut304r-restore.tsv): семь путей из варианта
tp167, весь стейдж против source-tp167-a02):

| Мутант | Что снято | Результат |
|---|---|---|
| m1 (fe167m1 `73619916…`, `l2_frontend_emit.lm2:16084`: цикл проверки операндов формы 4 не выполняется — `while: k < 0`) | вся проверка «поздний операнд пишет поле» | **убит**: обе отказные фикстуры транслируются (`the translation refuses: kind 0 exit 0`, игла не сказана, L1 оставлен) — 12 отказов, native и forced; `merge_args_operand` 7 в обоих исполнителях (все его слияния заполнены — мутант там эквивалентен); p302n_m2 — предел 304 ([лог](records/pins/tp151-probe-m304r-1.log), [терминал](records/pins/tp151-probe-m304r-1.terminal.txt)); возврат [лог](records/pins/mut304r-restore-m1.log) 7 файлов, 259/0 |
| m2 (fe167m2 `ebd02e81…`, `l2_frontend_emit.lm2:16091`: проверяется только род умолчания 0 — `if: dkind = 0`) | формал с записанным, но не построенным умолчанием (род 2) | **убит** одним рядом `merge_args_computed_default_refused` (транслируется, игла не сказана, L1 оставлен — 6 отказов, native и forced); `merge_args_unfilled_refused` по-прежнему отказывает, `merge_args_operand` 7 ([лог](records/pins/tp151-probe-m304r-2.log), [терминал](records/pins/tp151-probe-m304r-2.terminal.txt)); возврат [лог](records/pins/mut304r-restore-m2.log) 259/0 |
| m3 (fe167m3 `a15513b4…`, `l2_frontend_emit.lm2:16096`: строки соответствия самого операнда считаются заполнением — `msrc_op_cell[0][fq] >= k`) | «позднее» в проверке заполнения | **убит**: обе отказные фикстуры транслируются — 12 отказов, native и forced; `merge_args_operand` 7 ([лог](records/pins/tp151-probe-m304r-3.log), [терминал](records/pins/tp151-probe-m304r-3.terminal.txt)); возврат [лог](records/pins/mut304r-restore-m3.log) 259/0 |
| m4 (rt167m4 `ce4dbd67…`/`a7d52350…`, `lmx_walk_values.lm2:8061`: перед чтением умолчания в слот каждого формала кладётся ячейка нуля — поведение среза 304 до ревью) | представление отсутствия в ядре | **пережил** фокус (54 PASS, те же 2 отказа p302n_m2; [лог](records/pins/tp151-probe-m304r-4.log), [терминал](records/pins/tp151-probe-m304r-4.terminal.txt)) — ожидаемо эквивалентен для всякой допущенной программы: транслятор отказывает каждой, которая читала бы незаполненный слот, а заполненный поздним операндом слот не отличает пустого от нуля. Свидетель представления — не фикстура, а gdb-receipt выше (слот пуст, имя на слоте); наблюдаемым оно станет у подачи всей структуры аргументов (связыватель: «нет аргумента» против нуля) — удержано. Возврат [лог](records/pins/mut304r-restore-m4.log) 259/0 |

Документы ревью: [реестр дефектов](../../defects.md) — MERGE-OPERAND-FORMS (абзац «Срез 304» исправлен: слот пуст, ноль не
придумывается; новый абзац «Ревью Codex среза 304» — механизм, отказы, фикстуры, обзор типизированного операнда),
FORMAL-DEFAULT-FORMS (абзац ревью: предел операнда `f\args` при роде 2, умолчание не вычисляется); [заметки о
реализации 4.2](../../../docs/implementation-notes.ru.md#assign-named-merge) RU и EN (пункт об операнде `f\args`);
[selfbuild/README.md](../../../selfbuild/README.md) (259 входов — 66 исходников, 34 инструмента, 159 тестов; абзац
Slice304); [steps/current.md](../../current.md) (абзац ревью перед абзацем 304; абзац 304 исправлен); книга и generated
docs не менялись (абзац whole-arguments нуля не утверждал); журнал LMX_blog — новых реплик автора нет. Проверка
документов `docs check` по индексу git ([список](records/pins/docs304r-check-a.tsv), рецепт checks303 с приватным
каталогом вывода): проход a — 48 находок DOCS-EOL (копии логов pwsh в records — CRLF рабочие копии;
[лог](records/pins/docs304r-check-a.log)); проход b после переписи 12 путей из индекса ([crlf304r-1](records/pins/crlf304r-1.list)
— только те, что проверка перечислила) — 36 находок ([лог](records/pins/docs304r-check-b.log)); проход c после переписи
всех `w/crlf` по `git ls-files --eol` ([crlf304r-2](records/pins/crlf304r-2.list), 36 путей) — 0 отказов («35 paired semantic
chapters … line endings LF», [лог](records/pins/docs304r-check-c.log), [терминал](records/pins/docs304r-check-c.terminal.txt));
проход d над окончательным индексом (после второго прохода архива) — receipt только в P (`docs304r-check-d.*`), как у 303–304.

Провенанс ревью: правки исходников и документов — Edit/Write; мутанты — `sed` по точной строке стейджа с проверкой `sed -n`
до и после; списки `tp167-*`, `probe304-r1.tsv`, `records304r*.list`, `allow304r-1.list`, `crlf304r-*.list` — `printf`/`grep`;
рецепты — копии рецептов 304 с заменой имён и хешей (Write; строки с путями `\` не правились `sed`). Receipt gdb — чтение
готовой native-программы ряда фокуса (скрипт в записи). Архив — `steps` ([arch304r-1](records/pins/arch304r-1.tsv): 77 путей P
по [records304r.list](records/pins/records304r.list), копии проверены 77/0; второй проход — receipts первого прохода и docs check).

Отклонения ревью: (1) проба Opus `p302n_m2_merge_source` в фокусе отказывает пределом 304 («unknown field path segment»,
путь в часть args) — в списке фокуса оставлена как в p304b, 2 FAIL каждого прогона — не ревью; (2) первая проверка CRLF
копий циклом `grep -q $'\r'` не нашла ни одного файла (48 были): перепись по списку проверки документов, затем по
`git ls-files --eol`; (3) мутант m4 пережил фокус — ожидаемая эквивалентность (см. таблицу), не чинится фикстурой: свидетель —
gdb; (4) защищённый basename не читался и каталоги артефактов не перечислялись (п. 3 ревью): все чтения — по точным именам.

Верификация Codex (CODEX-FABLE-304-REVIEW-VERIFIED-20261108030330Z-01,
[копия](records/pins/CODEX-FABLE-304-REVIEW-VERIFIED-20261108030330Z-01.txt)): e2292fb3 прочитан read-only — HEAD = origin/main,
259 блобов selfbuild = manifest `185952dd…`, diff двух модулей и трёх фикстур, gdb-receipt, реестр 134/0, boot167a 0, checks 38/0,
самотест 0, посадка 9/0, docs check d 0; дефект 304 исправлен в рассмотренном объёме (пустой именованный слот при отсутствии
умолчания, ячейка у явного нуля, прежние результаты у заполненных форм); отказы без позднего писателя и предел
нелитерального умолчания — пределы реализации, не правило языка и не завершение поручения автора о merge/вызове;
FORMAL-DEFAULT-FORMS, путь в args, нечисловые формалы и вызов whole-arguments остаются открытыми; охрана и замена
константного выражения не доказывают реализации эффектов/времени вычисляемого умолчания. Типизированный операнд не менять:
первоисточник — `git 0a764078:LMX_blog/q/q56.md:141`, автор различает `int: i` как неизвестное значение в выделенной ячейке
памяти; недостающее поданное/умолчательное значение обязательного формала — отдельный случай; новой политики повторных
объявлений нет. m4 действительно переживает допущенные случаи — факт и gdb-свидетель сохранить, убитым не считать, различие
покрыть, когда появится запланированный путь вызова, не снимая удержания самостоятельно. Новых блокеров нет; дальше —
остаток IDENTIFIER-CODES и AXBY; финальный RESULT нужен для полной приёмки путей идентификаторов.

## Границы

- Вся структура аргументов из одной Structure (`mytest(merge(mytest\args; (a: int: 5)))` = 35, та же Structure в переменной)
  — удержана по CODEX-FABLE-304-CHOICE-HOLD: вопрос Codex автору о записи двух методов; связыватель вызова
  (`lm_compiler_bind_value_actuals_into`) по-прежнему кладёт результат `merge` в первую позицию и отказывает «has no
  argument a». Ни (а) перегрузка одного имени, ни (б) два чтения одного требования не введены.
- Чтение поля части args путём (`tst\args\c`) не разрешается: `lm_compiler_method_part_own_seg` отвечает только за части var
  и body («unknown field path segment»). Вне среза; записано здесь.
- Формал не числового типа как поле результата `merge` — предел п. 4 проекта.
- Формал без умолчания в результате `merge`: срез держал ноль его типа (как `int: a` операндом) и закрепил это фикстурой
  — снято ревью Codex 304 (раздел «Ревью Codex 304»): слот пуст, операнд допускается лишь с поздним операндом того же
  `merge`, пишущим поле; что читает программа из незаполненного обязательного формала и пишет ли незаполненный поздний
  операнд поверх значения модели — не решено (предел фазы).

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
- Операнд `f\args` с формалом без текущего умолчания, который не пишет поздний операнд того же `merge` (отказ ревью 304):
  чтение незаполненного обязательного формала программой и запись незаполненного позднего операнда поверх значения
  модели — после слова автора или общего решения представления «места без значения».
