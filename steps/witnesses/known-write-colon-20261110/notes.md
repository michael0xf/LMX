# Срез 349: запись известного места `left: right` доходит до каждой записи `:=` (M6 4b, часть 1) — 2026-11-10

Норма: [M6 4b](../../../next_core_tasks_v3.md#m6) (Codex CODEX-OPUS-345-4A-REPLY-20261110T041147Z-01, пункт 4: общая
запись `x: value`, перевод фикстур, удаление прежнего `:=` без fallback до завершения M6); книга
[assign-known](../../../docs/LMX_semantics.ru.md#assign-known) (RU:424: `:=` удалён, присваивание — `left: right`, включая
запись через путь; неизвестная голова в позиции объявления может определить Structure); вызов — только меткой вызова
(автор 2026-11-09; Codex CODEX-OPUS-344-M6-ANSWERS-20261110T014806Z-01, пункт 1: `f: v` и `ptr: v` не вызывают
хранимый callable — общий маршрут записи места).

## Измерения (P/runs/opus349/p, G2 boot349)

- Граф (интерпретатор, native, forced): `tests/graph/known_assignment.lm2` с `left: right` вместо каждого `:=`
  ([проба](records/runs/opus349/p/ka349.lm2), [журнал](records/pins/opus349-gp349.log)) — те же значения, что у `:=`
  (root 20, local_result 15, procedure_count 5, data 11/22, model_x 1, changed 17, clean 19/9, dirty 209/2, n 3); иной
  только текст дампа (`:=: x v` → `x: v`). Отказные строки ([журнал](records/pins/opus349-gp349b.log)): `Box\missing: tick()`
  и запись y в выбранную data без y — отказ 3, как у `:=`; имя метода `tick: tick()` — отказ 5 (у `:=` — 4; число не
  норма); `missing: tick()` с неизвестной головой — exit 0 (определение, книга RU:424), прежний отказ `:=` здесь не норма.
- Lowering: `tests/dyn/assign_known.lm2` с `left: right` ([проба](records/runs/opus349/p/ak349.lm2),
  [журнал](records/pins/opus349-low349.log)) — «more arguments than cb has formals»: внутри метода `cb: two` (callable
  формал) читается вызовом; с `cb := two` на месте ([журнал](records/pins/opus349-low349bb.log)) — «more arguments than
  target has formals»: `target: two` на корне единицы (привязка, держащая метод) — тоже вызов. Причина —
  `lm_compiler_is_asgn`: ветви «голова вызывает — не присваивание» (метод, callable формал, указатель C, held callable,
  метод единицы) не спрашивали метку вызова; `lm_compiler_head_is_call` её уже требует (срез 344).

## Сделано

- Метка вызова там, где запись отличалась от вызова только флагом `:=` (память assign-operator-classification):
  `lm_compiler_is_asgn` (ветви головы-вызова — только у Frame с меткой вызова), сканирование actuals оператора
  (`l2_frontend_lower`, связывание сайта как вызова), проверка held callable (`lm_compiler_check_primary`) и сбор
  (`lm_compiler_bind_node_content`): условие «нет флага `:=`» заменено условием «есть метка вызова» — `:=` его по-прежнему
  выполняет (метки вызова у него нет). Диспетчер конструкции кода (`lm_compiler_rw_stmt_content`) метку уже требовал.
- Фикстуры, где `:=` записывал известное место, переписаны `left: right`: dyn `assign_known` (с callable формалом swap
  и привязкой target) и `assign_typed_known`; graph `known_assignment`, `merge_reference`, `reference_alias`,
  `named_arguments` с ожиданиями (дамп `x: v`).
- Проба fehost20 (source69; [журнал](records/pins/opus349-low349c.log)): ak349 и atk349 (`x: int: 5` для известного x) —
  7 в native и forced; graph-check четырёх переписанных строк на fehost20 ([журнал](records/pins/opus349-gp349c.log)) —
  4/0.

## Проверка (source70, tool49, G0 fehost20)

- Стадия source70 ([манифест](records/pins/opus349-source70.sha256), [журнал](records/pins/opus349-stage70.log)).
- Самосборка boot350 ([журнал](records/pins/opus349-boot350.log)) — `BOOTSTRAP quick 0 failures`;
  [сравнение](records/pins/opus349-compare-g1-g2.log): G0 (fehost20, source69) = G1 = G2 (образы exe-same, тексты и
  объекты — сырой sha256; source70 отличается от source69 только фикстурами), рантайм G1 = rt76.
- Полный набор suite350 ([журнал](records/pins/opus349-suite350.log)) — G2 boot350, 149 строк, 0 отказов.
- Все проверки графа check86 ([журнал](records/pins/opus349-check86.log); tool49, rt76, graph84, G2 boot350) — 88 строк,
  0 отказов (интерпретатор, native, forced); [known_assignment](records/cold-graph309-codex01/check86-known_assignment/interp.log)
  с новым ожиданием.

## Границы (OPEN, срез 350)

- Сам `:=` ещё разбирается P0 (флаг `LM_P0_FRAME_ASSIGN`) и исполняется обоими потребителями; его удаление — отказ P0
  с диагностикой, снятие ветвей флага во frontend и построителе графа, отказ потребителей графа при прежнем операторе
  `:=` в уже построенном графе, перевод отказных фикстур `:=` (`assign_unknown_refused`, `assign_in_structure_refused`,
  `assign_typed_unknown*`, `merge_assign_operand_refused`, `assign_method_name_refused`, `assign_quoted_head_limit`,
  `named_assign_refused`, graph `known_assignment_method/_unknown/_path_missing/_selected`) — следующий срез.
