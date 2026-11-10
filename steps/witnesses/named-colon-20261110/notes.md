# Срез 345: именованная подача `a: value` (M6 4a) — 2026-11-10

Норма: книга [named-actuals](../../../docs/LMX_semantics.ru.md#named-actuals) («именованный фактический аргумент
записывается `a: value`…»), план [M6 4a/4b](../../../next_core_tasks_v3.md#m6); ответы Codex
CODEX-OPUS-344-NAMED-COLON-REPLY-20261110T030245Z-01 (перенос связывателя с `:=` на двоеточие — шаг 4a) и
CODEX-OPUS-345-4A-REPLY-20261110T041147Z-01 ([вопросы](records/pins/opus345-question-4a.txt),
[ответ](records/pins/codex-345-4a-reply.txt)): 1) `:=` среди actuals — отказ с диагностикой, без fallback, до эффектов
actuals, в обоих потребителях графа тоже; 2) `:=` снимается и из частей ресиверов (подача по головам; это форма
ресивера реализованной стадии, не объявление редакции 4 `k1: fn: …`, M6 3); 3) хвост именованной подачи потребляется
по контракту формала одним общим путём, без особого запрета числа полей: `f(a:)` — пустая Structure, `f(a: 1 2)` —
одна многополевая, `f(a: {1 2})` — явная дочерняя; 4) операторы известного присваивания `x := 5` — граница среза,
пункт M6 4b (OPEN).

## Что сделано

- **Связыватель графа** (`lmx_graph_run.lm2`). `lmx_graph_bind_formals`: в вызове Frame, чья голова — имя (не слово
  языка; `lmx_graph_named_actual`, экспорт), — именованная подача формала своей головы; имя, не являющееся формалом, —
  отказ (5); у частей ресивера — по голове, как прежде. `name := value` — отказ (5) до вычисления любого actual и в
  вызове, и в форме ресивера; ветка режима 1 (`:=`) снята в `lmx_graph_receiver_bind` и `lmx_graph_fn_decl_name`.
  Значение подачи — `lmx_graph_named_value` (экспорт): одно поле-значение вычисляется как позиционный actual
  (выражение, явный вызов `a(5)`, типизированное `int: 4`), хвост из записанных полей строится как записанный операнд
  `merge` (`lmx_graph_literal_fields`/`lmx_graph_literal_value` — вынесены из `lmx_graph_merge_literal` и
  `lmx_graph_merge_operand`, поведение merge прежнее), иначе — сам Frame; допуск формала берёт или отказывает. Скан
  динамических входов (`lmx_graph_work_scan_named`): голова подачи — формал вызываемого, не вход вызывающего; читаются
  поля хвоста.
- **Эмиттер графа** (`l2_graph_tool.lm2`, `lm_graph_emit_call`): ядро связывает при исполнении
  (`lmx_graph_bind_call`); поле-значение — операнд, хвост-Structure — вызов ядра `lmx_graph_named_value` в машинном
  коде; `:=` — уход по отказу на месте операнда (связыватель отказал раньше), без отдельной ветки связывания.
- **Lowering** (`l2_frontend_lower.lm2`): `lm_compiler_bind_value_actuals_into` — именованная подача по
  `lm_compiler_named_actual_frame` (Frame только с двоеточием, голова — идентификатор не из слов языка
  `lm_compiler_head_word`, точный идентификатор `` `a` `` — имя); `:=` — отказ «a named actual of tst is written
  a: value (M6 4a): the operator := names no argument». Тот же связыватель служит проверке, обходчику и машинному пути.
  Записанная Structure в хвосте подачи — ступень: точный отказ при переводе (Codex CODEX-OPUS-345-LOWERING-TAIL-REPLY,
  вариант B; общий построитель — M6 4c).
- **Экспорт** (`tools/build.lm2`): `graph_run_names` 39 → 41 (`lmx_graph_named_actual`, `lmx_graph_named_value`).
- **Фикстуры.** Перепись `:=` (grep по tests/src/tools): в сопровождаемых исходниках `:=` среди actuals только в
  комментариях. Переведены на `a: value` dyn: `named_assign_actuals`, `named_actuals_selected`, `bound_order_axby`,
  `bound_typed_reception`, `copy_name_codes`, `entry_admission_order`, `formal_defaults`, `formal_default_none_refused`,
  `merge_args_operand`, `whole_arguments`, `whole_direct_fields`, `named_assign_unknown_refused`,
  `named_assign_positional_after_refused` (игла 7:17 → 7:15), `named_assign_quoted`; graph: `named_arguments`,
  `defined_call_actuals`, `merge_arguments`, `named_admission_order`, `named_duplicate`, `named_mixed_duplicate`,
  `named_positional_after`, `named_required`, `named_unknown`, `whole_arguments`; части ресиверов по головам:
  `fn_named_supply`, `fn_name_collision`, `fn_author_forms`, `fn_return_forms`. Новые строки: dyn
  `named_assign_refused` (отказ `:=`), `named_tail_lowering_refused` (ступень lowering), graph `named_assign_refused`
  (5, touch() не вызван), `named_tail` (35, 34, 62, 64, 73), `named_tail_unsuitable` (4). Известные присваивания (`assign_*`, `known_assignment*`, операторы в
  `named_arguments`, литерал `merge_assign_operand_refused`) не тронуты — M6 4b.

## Команды и результаты (P = build2/codex_fix250generationchain01, S = P/cold-graph309-codex01, CWD = P/runs/opus345)

1. **Стадии** source53–source58 (`manifest`/`stage-copy`/`verify` tool45, 413–417 входов; рецепты и журналы
   [53](records/pins/opus345-stage53.command), [54](records/pins/opus345-stage54.command),
   [55](records/pins/opus345-stage55.command), [56](records/pins/opus345-stage56.command),
   [57](records/pins/opus345-stage57.command), [58](records/pins/opus345-stage58.command)). Комментарии рецептов 55 и 56
   исправлены после запуска (переименование их исказило; команды те же).
2. **Инструмент и ядро.** tool46 (`build-self` source53, c357564a…) → rt72 → graph80; затем экспорт
   `lmx_graph_named_value` — tool47 (source54, 4c9f7b18…, [журнал](records/pins/opus345-tool47.log)) → rt73
   ([журнал](records/pins/opus345-rt73.log)) → graph81 ([журнал](records/pins/opus345-graph81.log)). driver.c rt72
   против rt71: все отличия — в функциях `lmx_graph_*` (перенумерация локальных после первой изменённой функции, три
   новые функции).
3. **Пробы интерпретатора** (graph80, затем graph81; например [put():](records/runs/opus345/p/tail_layout.lm2) и
   [его прогон](records/runs/opus345/p/tail_layout.run81.txt)): на graph80 хвост `p: y: 6`
   отказывал при допуске (4: Frame вместо Structure — построения ещё не было); на graph81 `take(p: y: 6)` 62,
   `take(p: (y: 6; unused: 1); q: 4)` 64, оформление `put():` с вертикальным блоком `p:` 73, `tst(a: 2 + 3)` 35,
   `tst(a: int: 4)` 34, `tst(a: y: 6)` — отказ допуска 4; `take(p:)` — отказ P0 «empty colon Frame is not allowed»
   (пустые формы — M6 1); вертикальный блок внутри круглых скобок P0 не держит (`end: p` становится отдельным
   actual; [журнал](records/runs/opus345/p/tail_block.run81.txt)) — блок пишется оформлением `f():`.
4. **Граф.** check81 ([список](records/pins/opus345-graph-check81.tsv), [журнал](records/pins/opus345-check81.log)):
   86 строк, 81 без отказов, в том числе новые `named_assign_refused`, `named_tail` (native и forced тоже),
   `named_tail_unsuitable`; 5 отказов — только записи вызовов и частей в GRAPH-AFTER у переведённых фикстур (сверка:
   прежние `(:= b 7)` и `fn: (:= name k1) …` против `(b 7)` и частей по головам, значения те же; в `fn_return_forms`
   копия R2 теперь та же, что R3, — p2 записан как p3). Ожидаемые файлы обновлены; check81c — эти 5 строк, 0 отказов
   ([журнал](records/pins/opus345-check81c.log)). check81b прогнал пустой список (фильтр `grep -P` отвергнут локалью)
   — [журнал](records/pins/opus345-check81b.log), результата не даёт.
5. **Frontend.** fehost13 отказал при переводе `l2_frontend_lower`: «node is a word of the language»
   ([журнал](records/cold-graph309-codex01/fehost13/l2_frontend_lower.L2.log)) — параметр новой функции переименован в
   `actual` (source57). fehost14 (`build-frontend-host` source57, tool47, G0 boot344 G2, rt73;
   [журнал](records/pins/opus345-fehost14.log)) — собран. named345 — строки suite с переведёнными фикстурами и новой
   `named_assign_refused` ([список](records/pins/opus345-named.tsv), [журнал](records/pins/opus345-named345.log)):
   15 строк без отказов в обоих исполнителях (native/forced), отказы с прежними иглами (позиционный после
   именованного — 7:15) и новой иглой `:=`. Проба lowering `take(p: y: 6)` ([исходник](records/runs/opus345/p/low_tail.lm2),
   [журнал](records/cold-graph309-codex01/named345/low_tail-native/p.L2.log)) — отказ «unknown method» (frame=y): хвост
   `y: 6` проверяется как вызов y. Позиционные записанные Structure lowering тоже не строит
   ([журнал](records/pins/opus345-lowprobe345.log)): `take((y: 6))` — «y is not an argument of take» (нынешняя
   реализация снимает единственный контейнер и читает `y: 6` как подачу y; это не норма: непустой явно написанный
   контейнер P0 сохраняет, книга RU:119, а приём одной Structure решает общий контракт вызова, whole-arguments —
   поправка Codex, CODEX-OPUS-345-LOWERING-TAIL-REPLY пункт 3), `take({y: int: 6})` — «take has no argument p». Вопрос
   Codex OPUS-CODEX-345-LOWERING-TAIL-Q ([текст](records/pins/opus345-question-lowering-tail.txt),
   [ответ](records/pins/codex-345-lowering-tail-reply.txt)): ступень (B) — честный отказ распознанной формы в lowering,
   затем общий построитель записанной Structure для именованных и позиционных actuals отдельным пунктом M6.
   Ступень (source58): `lm_compiler_bind_value_actuals_into` у вызова (не у частей ресивера) отказывает распознанному
   хвосту из записанных полей (`lm_compiler_written_structure_span`, `lm_compiler_written_field`: `x: v` и явная
   Structure таких полей; типизированное значение `size_t: 3U` и выражения — не хвост-Structure) словами «the named
   actual p of take is a written Structure: building a written Structure value among the actuals of a call is not
   implemented in this translation yet (M6 4a)»; строка `named_tail_lowering_refused` закрепляет ступень.
6. **Промежуточная самосборка.** boot345 (`bootstrap quick` source57, tool47, G0 fehost14, 04:53–05:06Z;
   [рецепт](records/pins/opus345-boot345.command), [журнал](records/pins/opus345-boot345.log),
   [G2](records/cold-graph309-codex01/boot345/g2-build.log)): `BOOTSTRAP quick 0 failures`, smoke 10 строк, 0 отказов.
   Ответ Codex о ступени пришёл во время boot345 (перезапускать не велено); ступень — source58, fehost15, boot346.
   fehost15 (`build-frontend-host` source58; [журнал](records/pins/opus345-fehost15.log)) — собран; named345b
   ([список](records/pins/opus345-named2.tsv), [журнал](records/pins/opus345-named345b.log)): 16 строк, 0 отказов,
   `named_tail_lowering_refused` — отказ перевода с иглой 13:10 в native и forced, L1 не оставлен.
7. **Самосборка и полный список.** boot346 — `tool47 bootstrap quick R S B S/fehost15/l2trans.exe boot346
   S/tests/smoke.tsv` (стадия source58, 417 входов, 05:12–05:25Z; [рецепт](records/pins/opus345-boot346.command),
   [журнал](records/pins/opus345-boot346.log), [G2](records/cold-graph309-codex01/boot346/g2-build.log)):
   **`BOOTSTRAP quick 0 failures`**, smoke 10 строк, 0 отказов. Сравнение
   ([рецепт](records/pins/opus345-compare-g1-g2.command), [журнал](records/pins/opus345-compare-g1-g2.log)): G0
   (fehost15), G1 и G2 — frontend, backend, tool — одни образы кроме штампа (`exe-same` 1); `l2trans.lm1/.c`,
   `lmxtool.lm1/.c`, `l2_libc.o`, `launch.txt`, runtime `driver.c`, `driver.o`, `driver-observe.o` — одни байты;
   runtime G1 = rt73 байт в байт. suite346 — полный список frontend G2 boot346 на его runtime G2
   ([рецепт](records/pins/opus345-suite346.command), [журнал](records/pins/opus345-suite346.log), 05:25–05:41Z):
   **`SUITE 145 rows, 0 failures`**, 1137 PASS (с `named_assign_refused` и `named_tail_lowering_refused`).
8. **Архив и docs check** (tool47, CWD = P/runs/opus345 и P/docs74*-check-run-01). 124 записи: `manifest` и
   `stage-copy` — 124 и 124, 0 отказов; копии с CR переписаны из индекса в LF; 24 журнала рецептов PowerShell
   (UTF-16LE из `*>`; журналы стадий — UTF-8 со строками UTF-16LE) названы поимённо с `-text` в `.gitattributes` и
   хранятся байт в байт; управляющих байтов в текстовых записях нет (проверено до индексации). Проверка документации —
   docs74 по индексу; её журналы и журналы архива — во втором архиве.

Архив: [список](records.list), [SHA оригиналов](records.sha256), [SHA LF-копий](records-lf.sha256); docs check и
архивные журналы — [список](records2.list), [SHA](records2.sha256), [SHA LF](records2-lf.sha256).

## Отклонения процесса

- Первая правка списка экспорта `tools/build.lm2` (39 → 40) сделана одноразовой заменой python, а не инструментом
  Edit; результат сверен по diff, дальнейшие правки — Edit.
- `replace_all` инструмента Edit с новой строкой `": "` срезал конечный пробел: семь фикстур dyn получили слитную запись
  `x:a1()`; исправлено заменой целых лексем (`f(x: n; y: 7)`), diff проверен.
- rt73 и graph81 запущены одной командой переднего плана (`&&`, последовательно, не параллельно).
- check81b прогнал пустой список (`grep -P` отвергнут локалью); его журнал сохранён, результат дала check81c.
- Перечислений каталогов прогона и файла `l2_driver_launch.err` в этом срезе не было (списки записей — точные имена).

## Границы

- `f(a:)` — отказ P0 (пустой двоеточечный Frame): норма Codex — пустая Structure; пустые формы — M6 1 (OPEN).
- Записанная Structure среди actuals в lowering (C-путь) не строится — ступень: распознанный хвост из записанных полей
  именованной подачи отказывает при переводе с указанием места и формы (`named_tail_lowering_refused`) — ограничение
  реализации, не отрицательный пример языка; графовые interp/native/forced результаты поддержку в C-lowering не
  доказывают. Позиционные `take((y: 6))` и `take({y: int: 6})` отказывают прежними сообщениями нынешней реализации
  (не норма). Общий построитель — M6 4c (OPEN, следующий пункт).
- Операторы известного присваивания `x := v` — M6 4b (OPEN): общая запись `x: value`, перевод фикстур, снятие `:=`.
- Не сделаны: объявления `name: fn: …` (M6 3), мутанты (M6 5), `var` с корня (M6 6).
