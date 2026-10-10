# from_opus: передача эстафеты кодинга Codex (2026-10-08)

Писал Opus (Claude Code, Opus 5.5) — единственный writer/build ядра с 2026-10-05. По указанию автора
(2026-10-08) и запросу Codex CODEX-OPUS-HANDOFF-20261008-01 эстафета последовательного кодинга по плану
`next_core_tasks_v2.md` переходит к Codex; **слот единственного writer/build освобождён в пользу Codex**. Opus больше
не кодит и не запускает сборки и гейты — только отвечает на вопросы. Это рабочая передача, не спецификация:
нормы — `docs/`, план — `next_core_tasks_v2.md`, словарь — `next_core_tasks_dictionary_v2.md`, карта ядра —
`CORE_L2_L3_v2.md`, журнал — `steps/fable-continuation-20261003.md`, дефекты — `steps/defects.md`.

## 0. Вход

1. `AGENTS.md` → `READ.ME` → `steps/current.md` → план v2 §1 (протокол); пункт G4 MERGE-PARENT-SITE-OVERRIDE
   (`next_core_tasks_v2.md`, отметки контрольных точек 2026-10-08) и абзацы «Next (Codex …)» раздела K03.
   `steps/current.md` на момент передачи ещё называет Opus единственным writer — передачу фиксирует этот файл.
2. Журнал моих срезов — §§118–123 `steps/fable-continuation-20261003.md`; §123 (`#copied-formal`) — последняя
   контрольная точка.
3. Цепочка запросов Codex: родитель K03-UNIFIED-HEAD-IMPLEMENT-20261006-01, текущий
   K03-READ-FIELD-CLOSURE-20261008-31. Последние записи Codex по ней (ответы на PROGRESS 5–7, аудит оракула T7)
   дословно — `build/opus_handoff/messages/codex_*.txt`; мои сообщения — там же, `msg_rf31_*.txt`.

## 1. Git

- Код и документы контрольной точки: `4fb6dbbe61a6249dbb40f00ce2ed4aa1cd637b30` на `main`, отправлен fast-forward от
  `3f1167c5`; `git ls-remote origin main` = `4fb6dbbe…` на момент отправки. Этот файл коммитится поверх отдельным
  документным коммитом (единственный путь `from_opus.md`).
- 27 точных путей коммита `4fb6dbbe`: 6 изменённых (`dev/l2src_sandbox/l2trans.lm1`, `tools/l2_harness.ps1`,
  заголовки `unit_merge_parent_method_formal`, `_callable_actual`, `_model_subref` и исправленный оракул
  `_t7_local_proc`), 16 новых фикстур (`unit_formal_recv_{name,reference,classes,models,static,ordinal,write,reuse,
  absent,context}`, `unit_merge_parent_t7_{caller,formal,path,local_call,part}` и часть `_t7_part_part`), 5
  документов (`steps/defects.md`, `next_core_tasks_v2.md`, `CORE_L2_L3_v2.md`, `steps/current.md`, журнал §123).
- WIP нет, staged нет. Неотслеживаемый `l2_driver_launch.err` — артефакт драйвера, не коммитится никогда (не
  удалять, не добавлять). Мои процессы: ни одного (гейты завершены, наблюдатели остановлены).

## 2. Проверенные байты и доказательства

- `dev/l2src_sandbox/l2trans.lm1`: blob `0b4fb72e66b27661da6386b1e0a9f57400019643`, SHA256
  `A47CE778…8B323`; `tools/l2_harness.ps1`: blob `81471846…`; `dev/l2src_sandbox/lmx_walk.lm1` `0096e93c`,
  `lmx_walk.h.lm1` `1216c630` — не менялись. Все 22 гейтуемых пути захэшированы до цепочки
  (`build/opus_handoff/notes/pre_full_ff.txt`), не менялись ни в одном гейте, равны в рабочем дереве перед
  `git add` и staged (22 из 22). `bin/l1trans.exe` SHA256 `601d350e…aa2196`.
- Гейты, свежие, последовательные, на этих байтах:
  - kernel `build/l2src/opus_kernel_59`: GREEN297, 114 самотестов ran (113 exit 0, watchdog — ожидаемый fatal);
  - focus `build/l2_harness/opus_focus_ff_01`: 615 целей; красные ровно 14 — девять базовых строк
    `opus_full_63` (сообщения те же), пара `unit_node_path_anon_struct` и зарегистрированные строки
    T7-LOCAL-NAMED-UNIT `unit_merge_parent_t7_local_call`, `unit_merge_parent_t7_part` и `_walk`. Раскрытие: моё
    ожидание в скрипте цепочки ошибочно называло и `unit_merge_parent_t7_local_call_walk` — эта строка исполняет
    трансляцию с обходом методов и зелёная (77); исправлен список, не измерение;
  - L3 `build/l3_selftest/opus_l3_56`: все 11 наборов ok, бюджет типов ok;
  - full `build/l2_harness/opus_full_65`: RED68/2616. Против `opus_full_63` (RED71/2586): FAIL→OK 6 (пары
    `unit_merge_parent_method_formal`, `_callable_actual`, `_t7_local_proc`), OK→FAIL 0, добавлено 30 (27 OK, 3
    красных: `unit_merge_parent_t7_local_call`, пара `unit_merge_parent_t7_part`), удалено 0, ни одно сообщение
    красной строки не изменилось. `opus_full_64` на тех же байтах остановлен Claude Code из-за нехватки памяти
    машины на 5781 логе (неполный, не доказательство) и прогнан заново как `opus_full_65`.
- Реплей 2585 трансляций `opus_full_63` (байты `3f1167c5` против этих): 200 строк отличаются только L1 —
  пространство требования нативного допуска (188 строк), обходимый RECEIVING (186), селектор (8), вызываемые
  аргументы-пути (6); ни один выход и ни одно сообщение не изменились.
- 12 мутантов по одному правилу (`build/opus_handoff/notes/mut35_results.txt`): 11 пойманы, мутант «остаток
  вместо инварианта» не достигает ни одной программы (у каждого вхождения есть класс).

## 3. Статус исправлений (§123)

- **COPIED-METHOD-DECLARED-FORMAL — FIXED.** Объявленный структурный формальный допускается на вызове к требованию,
  прочитанному в пространстве выбранного вхождения, после единственного вычисления своего фактического аргумента и
  до следующего (нативно `l2_recv_ref` — `<вхождение>\parent` для тела, читающего через `node`; при обходе — допуск
  RECEIVING, `l2_rw_recv_req`). Через параметр-вызываемое класс выбирается один раз до фактических аргументов
  (`l2_emit_call_select`: держатель по связям `parent`, `l2_occ_hops`; каждый класс проверяется, остатка нет,
  отсутствующее или бесклассовое вхождение — общий инвариант) и допускает своей моделью (`l2_emit_formal_admits`,
  `l2_emit_class_admit` — неявный `implements` вызывающего только у выбранного класса). Факты D-105 такого вызова —
  аналитика для каждого достигающего метода (`l2_cfa_note/source/anchor/apply`), переданное место — мягкое ребро
  (`l2_d105_edge_add`, `l2_d105_possible`). `l2_method_sig_compatible` не усилен.
- **COPIED-CALLABLE-ACTUAL — FIXED.** Нативно вызываемый аргумент-путь — вхождение, которое путь выбирает
  (`l2_cf_actual_emit` → `l2_emit_path`), как при обходе `l2_rw_callable_actual`.
- Найдены и исправлены по пути: **CALLABLE-FORMAL-OTHER-MODEL** (допуск модели договора, а не выбранного
  вызываемого) и **CALLABLE-FORMAL-CLASS-REMAINDER** (вхождение копии исполнялось как последний класс).
- Свидетели с обходимыми двойниками, зелёные в трёх режимах: `unit_merge_parent_method_formal`,
  `_callable_actual`, `_model_subref`, `unit_formal_recv_*` (10; `_name`, `_absent` — контроли маршрута, зелёные и
  на HEAD; `_models`, `_static` — контроль «посторонний класс не спрашивается» и «выбранный класс отказывает до
  следующего аргумента» с сохранёнными эффектами слева направо).
- Долг реализации (ожидаемый позитив, не правило языка): метод с вызовом через параметр-вызываемое с несколькими
  классами под `--walk-methods` остаётся нативным (`l2_rw_machine`); обходимые двойники это закрепляют.

## 4. T7-LOCAL-NAMED-UNIT: исправление оракула против настоящего дефекта

- **Оракул был неверен (аудит Codex).** В `unit_merge_parent_t7_local_proc` S делает `v: cnt`, cnt — свободное имя;
  model пересылает его скрытым входом, корень на вызове `w()` отдаёт свою привязку — рабочее значение cnt, 9. По
  правилу динамики привязка вызывающего первая, копия лексического контекста — только запасной путь. Строка теперь
  ожидает 9 (зелёная); позитивы с различимыми источниками: `_t7_caller` (привязка корня 9, ячейка единицы 11, копия 7
  → 9), `_t7_formal` (формальный вызывающего → 40), `_t7_path` (явный `node\cnt` → копия, 7). Ноль от
  неинициализированного `int: cnt` — значение памяти прогона, не норма; дефект связывания не регистрировался.
- **Настоящий дефект — выбор единицы.** `l2_m_unit_ref` даёт `l2_program_unit` коду методов части (с построенным
  корнем), вложенных (hosted) методов, вложенных и локальных именованных Structure; все читатели единицы в их коде
  наследуют это. Свидетель `unit_merge_parent_t7_local_call`: локальная S модели вызывает метод единицы get
  (`node\cnt`) — нативно и при обходе корня S берёт get программы (`lmx_arena_ref_struct(l2_program_unit, 2U)`),
  117 вместо 77; двойник `_walk` зелёный (обходчик «запекает» вхождения из копии вида при её построении).
  Производитель запасного пути через часть отсутствует: `unit_merge_parent_t7_part` (+`_walk`) — отказ
  «unresolved name» у cnt в S (код, вложенный в метод части, не видит поля корня части; `l2_own_unit_seen`).

## 5. Красные строки `opus_full_65` (68) и открытое

Все 68 зарегистрированы (`steps/defects.md`, журнал): `entry_arg_len`, `entry_index`, `entry_strcmp`,
`entry_parse_min`, `unit_l2_puts_library`, `unit_charpp_return`, `unit_arr_path_variable_index_refused`,
`unit_arr_path_inner_value_refused`, `unit_arr_path_three_refused`, `unit_asgn_fallback`, `unit_eternal_shape`,
`unit_eternal_xref` (+`_walk`), `unit_capture_struct_whole`, `unit_capture_struct_merge_two`, `unit_ns2_ref_arg`,
`_ref_return`, `_ref_admit`, `_ref_capture`, `_bind_callable`, `_bind_value`, `_local_bind` (все `unit_ns2_*` с
`_walk`), `unit_output_named_receive_address` и `unit_output_receive_address_method` (+`_walk`;
critical_pointer_to_struct_bug), `unit_s6_own_fn_capture_value` (+`_walk`), `unit_k03_merge_op_anon_typed`
(+`_walk`), `unit_callable_sub_transport`, `unit_callable_forward`, `unit_callable_nullary_forms`,
`unit_callable_returning_two_contracts`, `unit_d112_nested_return`, `unit_d113_nested_expr`,
`unit_local_ns_stmt_unresolved`, `unit_s7_nested_shape`, `unit_held_actual_among_methods`,
`unit_held_actual_two_models`, `unit_node_path_anon_struct` (+`_walk`), `unit_merge_parent_t7_local_call`,
`unit_merge_parent_t7_part` (+`_walk`), `unit_t7_host_nested_return`, `unit_free_path_field_converted`
(+`_swapped`), `unit_formal_field_converted`, `unit_held_definition_free_name`, `unit_letter_alias_before`,
`unit_held_call_free_name_two_types`, `unit_callable_formal_unfollowed_actual`, `unit_lib_callable_formal`,
`unit_callable_formal_free_names_self_walk`, `unit_free_conv`, `unit_walk_free_conv`, `unit_copy_call_addressed`,
`unit_copy_call_from_method`, `unit_copy_call_other_owner`, `unit_dormant_free_body`. Список с сообщениями —
`build/l2_harness/opus_full_65/summary.txt`, строки `^FAIL`.

Открытые записи, ближайшие к работе: T7-LOCAL-NAMED-UNIT, PATH-STRUCTURE-LEAF, NODE-PATH-ANON-STRUCT,
T7-MODEL-OPERAND-SOURCE, T7-MODEL-ONLY-UNIT-METHOD, RETURNED-NODE-PARTIAL-COPY, MERGE-WRITTEN-OPERAND,
OWN-CALLABLE-LIMITS, REFERENCE-FIELD-CONSUMERS, MERGE-OF-QUALIFIED-REFERENCE-CELLS, SLOT-FAMILY-DEAD; долги
покрытия: обходимый корень `Model: m`, вид 3 в собственной именованной Structure метода, обходимый селектор (§3).
Не трогать без автора: голое поле как операнд merge (`LMX_blog/q/merge-bare-field-operand.md`),
семейство model-constrained null.

## 6. Следующая зависимость (по `next_core_tasks_v2.md` и порядку Codex)

1. **T7-LOCAL-NAMED-UNIT** — общая проекция единицы/лексики фактического вхождения по реальным связям
   `parent`/координат источника, без отката к единице программы для копии, вложения и части; чистые статические
   метаданные — под доказанным договором. Перепись и кодинг мною **не начаты**. Подготовлено, не запущено:
   черновик дизайна `build/opus_handoff/notes/t7l_design.md` (родители построения по видам методов; цепочка
   `l2_lex_up`/`l2_lex_links`/`l2_lex_depth`; семь групп читателей: `l2_m_unit_ref` и его читатели,
   `l2_recv_ref`, `l2_own_ctr`, `l2_hid_own_lex`/`l2_emit_tramp_lex`, `l2_hidden_lex`, видимость
   `l2_own_unit_seen` для кода в части, копия T7 — источник из фактической единицы места и узел модели части под
   копией корня части), маркеры переписи `build/opus_handoff/tools/patch_census36.py` (якоря проверены на этих
   байтах) и анализ L1 `cen36_l1.py`. Важное из чтения: локальная S внутри тела `if:` строится под Structure
   этого тела (`probes/lb_body.lm2`), то есть до единицы на звено больше; `l2_cfl_recv_alike` и `l2_rw_recv_req`
   сравнивают строку `l2_m_unit_ref` — при переходе на цепочку сравнивать число звеньев; `l2_t7_make_<k>` получает
   вхождение места (`l2_t7_at`), но копирует всегда `l2_program_unit`.
2. Затем **PATH-STRUCTURE-LEAF**, затем NODE-PATH-ANON-STRUCT.

## 7. Команды (что реально работало)

- Один конвейер gcc на машине. Kernel: `tools\build_l2src.ps1 -Run -KeepAll -OutDir <абс.>` (смотреть «114 …
  ran»); focus/full: `tools\l2_harness.ps1 -KeepAll -Translator C:\Nyasha_Planet\LMX\bin\l1trans.exe -OutDir
  <абс.> [-OnlyFixture <строки>]`; L3: `python tools\run_l3_selftest.py --output <абс.>`; полный ~40 мин.
  Образец цепочки с хэшами до/после каждого гейта — `build/opus_handoff/tools/run_gates_ff*.ps1`.
- При остановке фонового гейта из-за памяти (правило автора) — перезапуск сразу, сначала убедиться, что нет сирот
  (`Get-CimInstance Win32_Process`: bash/powershell/gcc/cc1).
- Сравнение полных: `python build/opus_handoff/tools/cmpfull.py <base summary> <new summary>`.
- Реплей трансляций без gcc (~30 с на 2600 строк): `python build/opus_handoff/tools/replay.py run <evidence dir>
  <l2trans.exe> <out>`, затем `replay.py cmp <A> <B>`.
- Стадия-копия для пробы/мутанта/переписи: `build/opus_handoff/tools/mp_stage.sh` (NOPATCH=1, EXTRA=<patch>.py;
  база — `build/l2_harness/opus_mp_ff2`, равная этим байтам); одна фикстура в трёх режимах — `run3.sh`
  (`runprobe.sh`). Внутри скриптов `S=` указывает на мой скретчпад сессии — поправить при переносе.
- Мутант — одно правило, своя стадия; охранник — константа слева (`0 != 0 && call()`), иначе вызов исполняется и
  мутант мнимый; «не достиг» ≠ «мёртвый». Оракул — из правила, значения источников различимы.
- L1 в Python — raw-строки из файла (не heredoc); LF везде. Коммит — явные пути, `check_docs`, `git diff --check`,
  без CR и роста управляющих байтов, staged blob = гейтованный, `git push`, `git ls-remote`.

## 8. Мои каталоги (вне git, `build/` игнорируется)

- `build/opus_handoff/` — `tools/`, `notes/` (`HANDOFF_rf.md` — пошаговый журнал -31, `t7l_design.md`,
  `pre_full_ff.txt`, `commit35.txt`, `mut35_results.txt`, `cen35_ff2.txt`), `messages/`, `probes/` (пробы T7,
  `lb_body.lm2`).
- Стадии: `build/l2_harness/opus_mp_ff2` (эти байты), `opus_mp_m35_*` (мутанты), `opus_mp_c35` (перепись
  формального). Доказательства: `build/l2src/opus_kernel_59`, `build/l2_harness/opus_focus_ff_01`,
  `build/l3_selftest/opus_l3_56`, `build/l2_harness/opus_full_65`; база сравнения `opus_full_63`.

## 9. Вопросы ко мне

Через `lmx_uds` для сессии `opus` (Opus, сессия 8e73acaf-29ac-437d-b823-3a24f0537ba0); отвечаю через
`python claude_chat/codex_inbound.py send --sender opus --request-id <ID>`. Кода, сборок и гейтов больше не запускаю.
