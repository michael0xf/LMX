# LMX — передача кодинга Codex

Это снимок состояния **на момент передачи** 2026-10-17 (утро); принятые
после неё коммиты и текущий остаток перечислены в
[steps/current.md](steps/current.md).

Передачу назначил автор 2026-10-17. **Codex принимает единственный слот
writer/build** в общей рабочей копии `C:\Nyasha_Planet\LMX` — **сразу**.
OpenRouter после этого не меняет ядро, не запускает сборки и gate, не
коммитит; он отвечает на вопросы. [to_openrouter.md](to_openrouter.md)
от 2026-10-16 — датированное свидетельство прежней передачи, не новое
назначение.

## Когда начинать

**Сейчас.** Автор, 2026-10-17:

> закончи текущий шаг и напиши инструкцию to_codex.md для передачи ему дел

OpenRouter остановлено на отметке полного gate шага P1#1 (kernel GREEN,
полный L2 RED — срез открыт, см. ниже). Фоновых процессов gcc, harness и
L3 не осталось.

## Состояние на передаче

### Коммиты и незакоммиченное

- Последний кодовый срез в `main` — `8f693011` (N2/K03: пять общих
  фиксов; полный L2 `openrouter_n2_full_02` на его байтах — 3546
  целей / 1067 FAIL, минус 93 FAIL-ID против `full_01`). Записи
  `63707e7e` (два P1 из ревью 8f693011) и `e8e67ceb` (измеренная
  развилка P1#1 + дельта full_02) плюс этот документальный коммит.
- Незакоммиченный WIP P1#1 в `dev/l2src_sandbox/l2trans.lm1`,
  `lmx_walk.lm1`, `lmx_walk.h.lm1`. **Полный gate на этих байтах RED —
  не коммитить как есть**; семьи регрессий ниже. `lmx_call.lm1`
  откачен к HEAD: правило унарных данных внутри него роняло kernel
  gate 57/305 (юнит call линкует только заголовки — вызов walk-фн
  из него даёт implicit declaration в каждом selftest C).
- `l2_driver_launch.err` — несвязанный артефакт, **не трогать**.
- Точный список перед работой — `git status --short`.

### Свидетельства на байтах WIP

- Kernel gate **GREEN 305/305**:
  `build/l2src/20261017_030353/summary.txt`.
- Эмпирическая петля stage4 во вход-режиме (`0 entry N`):
  `witness_p1_unary`, `unit_walk_make_adder`, `unit_a3_node_direct`,
  `unit_held_call_statement`, `unit_v2_outer_method` и 7 проб
  `probe_v2_*` — все native и walk GREEN. Алиас `call: count count`
  честно отказан M2-замыканием на трансляции (молчаливой подмены var
  больше нет).
- Полный L2 `build/l2_harness/openrouter_p1_full_03/summary.txt`:
  **RED 3546/1088** против `full_02` (1067): исправлено 0, добавлено
  21, у 7 сменилась диагностика (сравнение FAIL-ID — scratchpad
  `compare_fail_ids.py`, обе summary лежат в `build/l2_harness/`).
- L3 `build/l3/openrouter_p1_01` — 11/11 suites, бюджеты типов без
  изменений.
- `python tools/check_docs.py` OK; `git diff --check` чисто.

### Механизм P1#1 (что уже стоит в дереве)

`lmx_call_unary_data(arena, code)` в `lmx_walk.lm1` (прототип в
`lmx_walk.h.lm1`): fn-голова по таблице адрес→имя, 4 части →
`struct(code, 2U)` (var), иначе сам `code`. Три унарных места
`lmx_walk_call` (короткий CALL, CALL с пустым слотом 2, EXEC с пустым
слотом 1) выбирают var структурно; равенство `data = code` снято из
`lmx_walk_activate`. Эмитированные native-хвосты НЕ менялись (data =
callee): траншемплин берёт owner = data как `self`, и var-часть в роли
owner перебазирует madc-родителей и лексические цепи (`struct(чужой
unit, 0)` — мусорный callee). Правило для native-нулевых переходов
живёт в хуке `lmx_walk_call_prim_dispatch`: `if: data = code → data:
lmx_call_unary_data(arena, code)` — receiver-data, отличный от code,
не трогается. `(iv)` в `l2trans.lm1`: графовые места четырёхчастного
метода — из `l2_call_code` (split **или** parts_on), self-проекция
ограждена `l2_fn_parts_on(mi) = 0`; собственная ячейка — через
`l2_source_part_field(mi, 2|3, oi)`.

### Семьи регрессий полного gate (куда копать)

- **Семья A (9 строк):** транслятор отказывает `internal: a method own
  field lives in no part` — `unit_make_adder_after_return_{decl,call,
  call_native}`, `unit_pap_add5`, `unit_pap_add5_method`,
  `unit_walk_pap_add5_method`, `unit_k03_merge_op_pap_group{,_walk}`,
  `graph_shape_inert_pap`. Новая ветка `l2_own_from_expr` считает «нет
  ни в части 2, ни в 3» ошибкой, но own-проверка идёт **до выбрасывания
  мёртвых строк** (объявления после `return`, синтетические поля PAP).
  Направление: только живое поле обязано жить в части; мёртвое
  разрешается безвредно, как делала старая плоская ветка.
- **Семья B (19 строк):** падает **только native-половина** строк
  (аргумент драйвера `walkroot 1` — физический обход корня); их
  `--walk-methods` двойники GREEN. Подписи: «a field of an admitted
  reference is not carried by its value (no record, or a hole)» (exit
  3); «a dynamic call of a value that is not a Structure» (exit 3);
  неверный exit (1). Затронуты `unit_held_capture_chain`,
  `unit_held_actual_reference`, `unit_held_reference_{chain,write_chain}`,
  `unit_held_capture_host_field`, `unit_held_call_{bare_name_result,
  required_input_from_caller, to_callable_formal}`,
  `unit_absent_input_{forward,reader}`, `unit_absent_input_forward_
  host_local`, `unit_t7_actual_in_definition`, `unit_v2_nested_recursive`,
  `unit_v2_outer_method`, `unit_nested_definition_structure_{override,
  path}`, `unit_k03_ref_local`, `unit_local_reference_contract_copy`,
  `unit_admit_dynamic_hidden_catch`. Корень — взаимодействие трёх
  унарных мест `lmx_walk_call`, снятия равенства в `lmx_walk_activate`
  и хука prim-dispatch с walkroot-обходом корня; во вход-режиме те же
  фикстуры GREEN. Направление: предикат унарности **на кадр** CALL/EXEC
  (пустые слоты данных), различающий истинную унарную форму от явных
  данных/контракта, а не blanket-замена `data = callee`.

## Очередь (по зависимостям)

1. **P1#1 до полного gate** — семьи A и B выше, потом коммит среза
   (native + принудительный walker + отрицательный мутант + полный
   gate + сравнение FAIL-ID с `full_02`/`full_03`).
2. **P1#2** — mad-конструкторы копируют var/body через
   `lmx_walk_cell_copy`, который возвращает исходную Structure
   (шаринг, не полный граф-копией; en.md:665–693). Одна карта копии
   графа для owned-частей, перезапись внутренних ссылок/родителей,
   доказать отсутствие алиасинга; native/walker согласны.
3. **M2** — допуск алиаса `call: F F` на методе (сейчас честный отказ
   «the current Structure body is not proved»; en.md:416).
4. **47-witness миграция** (19 shape + 22 каскадных мутанта на
   зелёных базах + 3 GraphCALL).
5. **unit_walk_body_path_*** — AT-цепочка `lmx_walk_slot` на инлайн
   else-ссылках; перепроверить после P1.
6. Далее по [next_core_tasks_v3.md](next_core_tasks_v3.md) (N4-U,
   N5, N6 …).

## Ревью и почта

`lmx_uds` почтальон умер по квоте Claude (автор, 2026-10-17); обмен с
OpenRouter идёт cross-session сообщениями. Ревью 8f693011 получено
(два P1, записаны в `63707e7e`); ревью `63707e7e` и `e8e67ceb` к
моменту передачи не поступало. После принятия слота OpenRouter ревью
не ведёт.

## Материалы OpenRouter

Scratchpad **временный** и может исчезнуть:
`C:\Users\mtkra\AppData\Local\Temp\claude\C--Nyasha-Planet-LMX\
cc331a2a-7399-4de7-b878-157b41a8f936\`

- `stage4/` — дерево P1: `l2src/` (копии живых dev-файлов WIP),
  `bin/l2trans.exe` (сборка этих байтов), `gen/` (C-выходы и .o
  драйвера), `headers/`, `verify_p1.sh` — петля
  «переведи→собери→прогони» во вход-режиме (третий аргумент `walk` —
  принудительный walker);
- `stage4/witness_p1_unary.lm2` (var с `x`, унарный вызов пишет строку
  var, exit 7), `witness_p1_alias.lm2` (отказ), `p1probes/` — 7 проб
  декомпозиции `unit_v2_outer_method` (entry 0);
- `compare_fail_ids.py` — сравнение FAIL-ID двух summary;
- патч-скрипты по истории правок (`patch_iv.py`, `patch_self_guard.py`,
  `patch_revert_iii.py`);
- летопись среза — memory-файл `n2-slice-regressions-20261016.md`
  (вне репо, у агентов Claude).

## Ловушки (новые; прежний список в git-истории этого файла остаётся верным)

- Bash-heredoc со строками, содержащими `\n`/`\\`, рвёт литералы L1/C
  — правки делать скриптом, записанным инструментом записи файла, а
  не heredoc.
- Юнит `lmx_call.lm1` линкует только заголовки: вызывать walk-фн из
  него нельзя (implicit declaration во всех генерированных selftest C).
  Кросс-зависимость — через установленный хук или header-predef.
- Entry значения строк harness — двойники ожидаемого exit (eternal-runs):
  проба с чужим entry даёт ложный RED.
- Native-половина строк идёт с `walkroot 1` — зелёный вход-режим
  (`0 entry N`) этот путь не покрывает.
- Зелёная локальная петля ≠ зелёный полный gate: 12 свидетелей stage4
  были зелёные, полный gate нашёл 21 новую регрессию.

## Правила (без изменений)

- Нет исключений по имени, типу, форме, месту или backend; отложенный
  отказ называет свой будущий пакет; оракул меняется только со ссылкой
  на норму.
- Для среза: native, принудительный walker, отрицательный мутант и
  полный gate; перед коммитом `python tools/check_docs.py` и
  `git diff --check`.
- Окончания строк — LF; одна сборка gcc на машине; не трогать входы
  идущего gate; `LMX_blog` — только технические формулировки автора по
  [READ.ME](READ.ME).
- Коммитить пути из `git status`; после `git add` проверить, что ничего
  отслеживаемого не осталось изменённым; push ff-only (автор читает
  main-checkout).
