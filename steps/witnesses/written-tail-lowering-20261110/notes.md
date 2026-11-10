# Срез 348: записанная Structure среди actuals в lowering — маршрут (a) (M6 4c) — 2026-11-10

Норма: [M6 4c](../../../next_core_tasks_v3.md#m6); граф — [срез 347](../written-tail-20261110/notes.md). Ответ Codex
CODEX-OPUS-348-ROUTE-B-REPLY-20261110T081925Z-01 ([вопрос](records/pins/opus348-question-route-b.txt),
[ответ](records/pins/codex-348-route-b-reply.txt)): вариант (a) — формал получает адрес записанной Structure в живом
графе кода, по пути actual из текущего `l2_call_code` (`lm_compiler_emit_live_code_place`), обычный
`lmx_call_bind_receive` на позиции actual; не раскладка-копия в namespace тела (разделение `written_form_split` даёт
второй объект); допуск, чтение, запись и взятие адреса `y: int: 6` — одна физическая int-ячейка (числовой литерал кода —
int-ячейка: `lm_compiler_emit_source_atom`), общей картой, без исполнения ресивера при чтении (принцип ready_slot);
вычисляемое поле — честный отказ допуска.

## Измерения (P/runs/opus348/p)

- boot348 G2: `take({y: int: 6})` — «take has no argument p» (фигурные скобки — вся структура аргументов; отдельный
  вопрос); `take(p: y: int: 6)` — отказ ступени 345 ([журнал](records/pins/opus348-low348.log)).
- Опыт fehost16 (source64: отказ ступени снят, не коммит): следующий проход — проверка
  (`lm_compiler_check_primary`) читает хвост `y: int: 6` как выражение и разрешает y как метод: «unknown method», frame y
  ([журнал](records/pins/opus348-low348b.log)).

- `take(p: 6 2)` (структурный хвост без записанных полей) на boot348 — отказ конструкции кода «root operation not
  walkable yet: this expression» ([журнал](records/pins/opus348-low348c.log)): ни один структурный именованный хвост
  дальше связывателя не понижается; конструкция кода (`lm_compiler_rw_*`) записанную Structure как значение не строит.

- Попытка 1 (source65, fehost17): перевод `l2_frontend_emit` отказал — локал `node` в `lm_compiler_rw_ready_tail`
  (слово языка; известная ловушка); попытка 2 — source66, fehost18.

- Попытка 2 (source66, fehost18; [журнал](records/pins/opus348-low348d.log)): записанная группа
  `take(p: (y: int(5); unused: int(1)); q: 2)` — 52 в native и forced; вычисляемое поле — отказ границы; хвост одним
  Frame `take(p: y: int: 6)` — «internal: a source method occurrence has no graph producer»: значение actual из одного
  отрезка — сам этот отрезок (`lm_compiler_value_argument_ref`, без массива values), а построитель ждал массив. Попытка 3
  (source67, fehost19): `lm_compiler_rw_ready_tail` читает три формы (группа, вертикальный блок, один Frame).
- Попытка 3 (source67, fehost19; [журнал](records/pins/opus348-low348e.log)): `take(p: y: int: 6)` — 62,
  `twice()` — 7, затем 8 (тот же объект при каждом достижении), группа — 52, всё в native и forced; вычисляемое поле —
  отказ границы при переводе (строка probe ждала успеха — ожидаемый отказ, не дефект).

## Сделано

- Связыватель lowering (`l2_frontend_lower.lm2`, именованный actual): готовый хвост — поля `name: int: <литерал>` или
  `name: int(<литерал>)` (`lm_compiler_ready_written_field`, `lm_compiler_ready_written_span`: целый литерал без суффикса в
  диапазоне int) — получает `structured = 2`; иной записанный хвост (вычисляемое или нетипизированное поле) — отказ
  границы «… is a written Structure with a field that is not a typed int literal (`y: int: 6`): building such a written
  Structure among the actuals of a call is not implemented in this translation yet (M6 4c)».
- Проверка (`lm_compiler_check_call_arguments`) и сканы (`lm_compiler_scan_actuals_value`): хвост с `structured = 2` —
  не выражение (его поле y не разрешается как метод); проверка только отмечает место выражения.
- Конструкция кода (`lm_compiler_rw_call_arguments` → `lm_compiler_rw_ready_tail`, `l2_frontend_emit.lm2`): узел из n
  полей в собственном месте actual внутри узла вызова (`lm_compiler_rw_plain`), место отмечено ролью 7 по узлу-обёртке
  actual; каждое поле — `lmx_int_new_profiled` + `lmx_int_store_known(литерал)` в ячейке и имя поля
  (`lmx_source_name_set`) на ячейке и значении. Формы хвоста: группа (узел значения — Structure), вертикальный блок
  (несколько отрезков), один Frame (значение из одного отрезка — сам этот отрезок).
- Native actuals (`lm_compiler_emit_call_arguments_full` → `lm_compiler_emit_ready_tail`): живой адрес места
  (`lm_compiler_expr_site_place` роли 7 + `lm_compiler_emit_live_code_place`, как `lm_compiler_emit_current_structure`)
  — значение actual `lmx_walk_value_ref(LMX)`, затем обычный приём `lmx_call_bind_receive` на позиции actual; ветви
  вычисления/ссылки/пустого actual для этого хвоста не выполняются.
- Сообщение границы переписано («not a typed int literal … building such … is not implemented»; source68).
- Фикстуры dyn: `named_tail_lowered` (62), `named_tail_lowered_twice` (7, затем 8), `named_tail_lowered_group` (52);
  границы `named_tail_lowering_refused` (`y: 6`, новая игла) и `named_tail_computed_lowering_refused` (`y: int: k + 5`).

## Устройство (прочитано)

- Конструкция графа кода (`lm_compiler_rw_*`, фаза construct 1) отмечает места выражений
  (`lm_compiler_expr_site_note_role`); живой адрес места — `lm_compiler_expr_site_place` +
  `lm_compiler_emit_live_code_place` (прецедент — `lm_compiler_emit_current_structure`, роль 6 от
  `lm_compiler_rw_struct_call`).
- Native actuals: `lm_compiler_emit_call_arguments_full` — каждое значение в запись `l2_av[t]`, сразу
  `lmx_call_bind_receive` → `lmx_call_receive_formal` → `lmx_walk_value_admit` → `lmx_implements_admit_receiving_*`; D-105:
  статическая карта пары типов транслятора с раскладкой (`lmx_implements_register_map`).

- Записанная Structure объявления — слот самого кода тела (`l2_gp<body>` слот 1: int-ячейка y = 6), а место own —
  слот объявляющей строки (pack — слот 2): данные и код — один граф; анонимная модель + статическая карта D-105
  (take(pack) 62). Вопрос Codex о форме — OPUS-CODEX-348-LAYOUT-Q ([текст](records/pins/opus348-question-layout.txt)):
  раскладка хвоста данными в собственном слоте actual внутри узла вызова (тот же узел по пути из `l2_call_code`).

- Ответ Codex CODEX-OPUS-348-LAYOUT-REPLY-20261110T083210Z-01 ([ответ](records/pins/codex-348-layout-reply.txt)): да —
  раскладка хвоста данными в собственном слоте actual внутри узла вызова (тот же узел по живому пути statement → call →
  actual → tail); `y: int: 6` — непосредственная именованная int-ячейка 6 (нормализация доказанного определения;
  ответ 346 о сохранении Frame int это допускал); раскладка готового определения переиспользуется для самого узла
  actual; проверка учитывает структурную роль хвоста; вычисляемое поле — оператор сохраняется, граница фиксируется
  (не пустая ячейка ради положительного результата).
- Построитель frames строит каждую namespace-Structure как `l2_nsp[k]` (`lmx_struct_new_profiled`, int-ячейки
  `lmx_int_new_profiled` + `lmx_source_name_set`, статические карты D-105 `l2_d105m*`) и связывает её с местом: поле
  родителя или слот единицы (`l2_frontend_emit.lm2:17630–17638`); конструкция кода ссылается на `l2_nsp[k]` в узлах
  (операция OF, `l2_frontend_emit.lm2:8912`); локальная модель (`ns_local`, `lm_compiler_rw_local_model_at`) привязана к
  own — для actual не годится (own — поле var).

## Замысел (черновик до ответа LAYOUT; сделано иначе — раскладка конструкцией кода в месте actual, см. «Сделано»)

- Хвост — анонимная namespace (тип, профиль, карта D-105 к модели формала); построитель frames строит её `l2_nsp[k]`
  без связи с родителем (новое размещение); конструкция кода кладёт этот узел в слот операнда actual (живой путь даёт
  его адрес); native — `lm_compiler_emit_live_code_place` этого места как ссылка actual, затем `lmx_call_bind_receive`;
  обходчик — тот же узел как операнд (как обходчик вычисляет операнд-данные — выяснить).

## План (черновик; пункт 6 исполнен иначе: `y: 6` и вычисляемое поле — отказ границы при переводе, не отказ допуска)

1. Проверка, сканы и сбор: структурный хвост именованного actual — записанная Structure, не выражение (без разрешения
   y как имени).
2. Модель хвоста — анонимная модель раскладки из него самого (`y: int: 6` — int); статическая карта к модели формала.
3. Конструкция кода: хвост строится на своём месте графа actuals и отмечается местом выражения.
4. Native: живой адрес хвоста — значение actual (ссылка), регистрация карты/раскладки к int-ячейкам кода, обычный приём.
5. Forced (обходчик): тот же объект и та же карта.
6. Проверки: `take(p: y: int: 6)` 62; запись `p\y` и повторное чтение того же объекта (twice — 7, 8); `y: 6` — отказ
   допуска; вычисляемое — отказ допуска; отказ ступени снимается, `named_tail_lowering_refused` переводится.

## Проверка (source68, tool49, G0 fehost19)

- Стадия source68 ([манифест](records/pins/opus348-source68.sha256), [журнал](records/pins/opus348-stage68.log)).
- Самосборка boot349 ([журнал](records/pins/opus348-boot349.log)) — `BOOTSTRAP quick 0 failures`;
  [сравнение](records/pins/opus348-compare-g1-g2.log): G1 = G2 (образы exe-same, тексты и объекты — сырой sha256),
  рантайм G1 = rt76 (ядро не менялось); G0 (fehost19, source67) отличается от G1 только одной строкой `l2trans.c` —
  переписанным сообщением границы.
- Полный набор suite349 ([журнал](records/pins/opus348-suite349.log)) — G2 boot349, 149 строк (145 + 4 новых), 0 отказов;
  новые строки — native и forced.
- Позиционная группа `take((y: int: 6))` на G2 boot349 ([журнал](records/pins/opus348-low348f.log),
  [перевод](records/cold-graph309-codex01/low348f/low348_pos-native/p.L2.log)) — прежний отказ «y is not an argument of
  take» (группа читается как именованная подача y): граница, не норма.
- Граф (`l2_frontend_graph`, ядро, инструмент) в срезе не менялся: graph-check не повторялся, кортеж графа прежний
  (tool49, rt76, graph84).

## Границы (OPEN)

- Lowering: хвост с вычисляемым полем (`y: int: k + 5` — оператор остаётся в записанном теле; раскладка пустой ячейки
  ради результата запрещена ответом LAYOUT), нетипизированное `y: 6` (вложенная Structure y), вложенные хвосты, иные
  ресиверы полей (не int); позиционная записанная Structure (`take((y: int: 6))`, `take({y: int: 6})` — прежние отказы).
- Граф (из среза 347): неизвестное `x: 4` ещё int-место; чтение `merge` готовых операндов ещё не по роли.
