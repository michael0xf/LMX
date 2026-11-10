# Срез 350: прежний оператор `:=` удалён (M6 4b, часть 2) — 2026-11-10

Норма: книга [assign-known](../../../docs/LMX_semantics.ru.md#assign-known) (RU:424: прежний оператор `:=` удалён,
присваивание — `left: right`); грамматика EN:816, :1235 («there is no separate := operator»); [M6 4b](../../../next_core_tasks_v3.md#m6)
(Codex CODEX-OPUS-345-4A-REPLY-20261110T041147Z-01, пункт 4: удаление `:=` без fallback до завершения M6). Часть 1 —
[срез 349](../known-write-colon-20261110/notes.md): `left: right` доходит до каждой записи прежнего `:=`.

## Сделано

- P0 (`p0_parser.lm2`): `:=` после головы — слитно (`a:=5`) или раздельно (`a := 5`), после точного идентификатора тоже
  (поиск начинается после токена в кавычках) — отказ разбора с диагностикой 33 «the operator := is removed: a write is
  written left: right (the book, assign-known)» на позиции оператора, до любого потребителя документа; никогда не голова
  `a:` с телом `=5`. Оба потребителя (frontend и построитель графа) начинают с P0, так что прежней формы нет нигде.
- Frontend: сняты ветви флага `LM_P0_FRAME_ASSIGN` — `lm_compiler_is_asgn`, `lm_compiler_head_is_call`, отказ `:=`
  среди actuals, «`:=` ничего не определяет» (связывание, вложенное определение, поле namespace, типизированное поле
  Structure, определение из правой части), `lm_compiler_assign_new_name` и `lm_compiler_assign_host_place` (только для
  `:=`), отказ «:= writes a place already known», маски флагов, поле имени операнда `merge` (`(zz := int: 5)`).
- Граф: построитель без `lm_graph_build_assignment` и ветвей флага; интерпретатор без `lmx_graph_eval_assignment` и
  слова `w_assign` (оператор, связыватель формалов, чтение левого операнда, слова языка, целая структура аргументов);
  эмиттер без `lm_graph_emit_assignment` и отказа `:=` среди actuals. Слово `:=` больше не интернируется
  (`lmx_graph.lm2`); поле `w_assign` снято из `LmxGraphState` и `LM_P0_FRAME_ASSIGN` — из заголовка P0 (шаблоны
  `tools/build.lm2`), поэтому новая цепочка tool50 → rt77 → graph85 → fehost21.
- Фикстуры: отказы P0 в разных позициях — dyn `assign_operator_removed_refused` (оператор метода), `_root_refused`
  (корень, типизированная правая часть), `_structure_refused` (тело именованной Structure), `_quoted_refused` (точный
  идентификатор), `named_assign_refused` (actual вызова), `merge_assign_operand_refused` (операнд merge); имя метода
  слева — `assign_method_name_refused` в форме `one: two` (отказ проверки «a Frame written with a colon calls
  nothing … the place of a method»); graph `known_assignment_method` (`tick: tick()`: отказ 5), `_path_missing` (3),
  `_selected` (3, переданная data не дополняется). Сняты фикстуры отменённых книгой правил: неизвестная левая часть
  `:=` (`assign_unknown_refused`, `assign_in_structure_refused`, `assign_typed_unknown*`: `zz: 5` и `zz: int: 5` теперь
  определяют), `assign_quoted_head_limit` (заменена `assign_operator_quoted_refused`), graph `known_assignment_unknown`
  (`missing: tick()` — определение, exit 0) и graph `named_assign_refused` (строка graph-check не выражает отказ P0:
  его проверяют строки dyn — P0 общий). Комментарии фикстур и строк suite о `:=` обновлены.

## Измерения

- fehost21 (source71, tool50, rt77; [журнал](records/pins/opus350-low350.log)): шесть отказов P0 — позиции и текст
  ожидаемые, но главный файл печатается как «l2trans parse error 33 at L:C: …» без имени файла — иглы строк исправлены
  (source72); `assign_method_name_refused` — отказ проверки 13:5; `assign_known`, `assign_typed_known` — 7.
- graph-check на fehost21 и graph85 ([журнал](records/pins/opus350-gp350.log)) — 11 из 12; `known_assignment_method`:
  интерпретатор 5, forced — отказ при исполнении, native-эмиттер отказывает при переводе (emit 5;
  [журнал](records/cold-graph309-codex01/gp350-known_assignment_method/native/emit.log)), а graph-check требует
  успешного emit — поэтому, как `colon_call_refused` среза 344, это не строка graph-check, а отдельная проверка.

## Проверка (source72, tool50, rt77, graph85, G0 fehost21)

- Цепочка: tool50 ([журнал](records/pins/opus350-tool50.log); build-self tool49, G2 boot350, rt76/driver.o; SHA256
  6FCB73B4…), rt77 ([журнал](records/pins/opus350-rt77.log)), graph85 ([журнал](records/pins/opus350-graph85.log)),
  fehost21 ([журнал](records/pins/opus350-fehost21.log)); стадии source71 и source72
  ([манифест](records/pins/opus350-source72.sha256)).
- Самосборка boot351 ([журнал](records/pins/opus350-boot351.log); tool50, G0 fehost21) — `BOOTSTRAP quick 0 failures`;
  [сравнение](records/pins/opus350-compare-g1-g2.log): G0 = G1 = G2 (образы exe-same, тексты и объекты — сырой sha256;
  source72 отличается от source71 только иглами строк), рантайм G1 = rt77.
- Полный набор suite351 ([журнал](records/pins/opus350-suite351.log)) — G2 boot351, 147 строк (149 − 6 снятых + 4 новых),
  0 отказов.
- Все проверки графа check87 ([журнал](records/pins/opus350-check87.log); tool50, rt77, graph85, G2 boot351) — 85
  строк (88 − known_assignment_unknown, graph named_assign_refused, known_assignment_method), 0 отказов: интерпретатор,
  native, forced; `known_assignment_method` — отдельно в gp350 (интерпретатор 5, forced — отказ при исполнении, native —
  отказ эмиттера 5).

## Границы

- graph-check не выражает отказ разбора или перевода (emit) как ожидаемый: строки с отказом P0 — только dyn;
  `known_assignment_method` и `colon_call_refused` проверены отдельно.
