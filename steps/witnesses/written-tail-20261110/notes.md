# Срез 347: записанная Structure среди actuals — ссылкой, поля по роли (M6 4c, часть графа) — 2026-11-10

Норма и маршрут: [M6 4c](../../../next_core_tasks_v3.md#m6); предыдущий срез —
[346](../written-structure-20261110/notes.md). Ответы Codex этого среза:
[INIT-REPLY](records/pins/codex-347-4c-init-reply.txt) (A — записанная форма; B снят следующим),
[DIRTY-CORRECTION](records/pins/codex-347-4c-dirty-correction.txt), [ROUTE-REPLY](records/pins/codex-347-4c-route-reply.txt),
[READER-REPLY](records/pins/codex-347-4c-reader-reply.txt); вопросы — [INIT](records/pins/opus347-question-4c-init.txt),
[INIT2](records/pins/opus347-question-4c-init2.txt), [ROUTE](records/pins/opus347-question-4c-route.txt),
[READER](records/pins/opus347-question-4c-reader.txt).

## Измерения (boot347 G2, graph83; P/runs/opus347/p)

- Уточнение среза 346: lowering не читает `pack: (y: 6)` как int. `pack: (y: 6)` / `return: pack + 1` — отказ «a reference
  where a number is asked» ([журнал](records/pins/opus347-low347.log)); `take(pack)` — отказ допуска «implements is
  false in function argument» ([журнал](records/pins/opus347-low347b.log)) — как требует Q57. Запись (i) среза 346
  («читается как выражение int») была выводом из отказа и исправлена в плане, `steps/current.md` и заметках 346.
- Вычисляемое поле записанной Structure: `pack: (y: int: k + 5)`, `pack: (int: y k + 5)`, блок `T:` / `int: y k + 5` в
  теле и на корне — y читается 0, take даёт 2 ([low347b](records/pins/opus347-low347b.log),
  [low347c](records/pins/opus347-low347c.log), [low347d](records/pins/opus347-low347d.log)); граф на том же корне
  оставляет `T: (int y (k + 5))` и отказывает при допуске (4) ([прогон](records/runs/opus347/p/g347_root_named_computed.run83.txt));
  в теле fn граф отказывает в самой форме `pack: (...)` (3). Незаполненное int-место читается 0 и без вычисляемого
  инициализатора: поле `int: y` блока и собственное `int: x` функции ([low347e](records/pins/opus347-low347e.log)).
- Ответ A (INIT-REPLY): строка `T:`/`pack: (…)` присваивает допущенную ссылку на текущую записанную Structure;
  вычисляемый оператор поля принадлежит вложенному телу и исполняется только при явном исполнении этого тела; ни 62, ни 2
  не служат ожидаемым результатом take(T); у реально выделенного места без значения — модель uninit:T без обещанного
  значения (слова автора 2026-11-08: «не обещание нуля и не новая проверка чтения»; безопасный физический выбор байтов —
  деталь реализации). Значит, 0 lowering — допустимый физический выбор, а не нарушение; отказ графа — тоже по норме
  (у кандидата нет int-места). Код не меняется; фикстуры не утверждают ни 2, ни 62.
- `merge` записанного операнда с вычисляемым полем строит и вычисляет (62) и в объявлении, и поднятым actual 307
  ([low347f](records/pins/opus347-low347f.log)).
- Ответы DIRTY-CORRECTION и ROUTE-REPLY: для записанной Structure среди actuals Structure не строится — формал получает
  ссылку на записанную в коде Structure, тот же объект при каждом достижении (запись `p\y: 9` видна следующему вызову той
  же строки, REPEAT-IDENTITY 278); новый узел строит только операция построения (явный `merge`); в lowering — маршрут
  (b): адрес уже написанной Structure в её месте графа actuals, без служебного объявления `l2_lift_*`, нового поля var или
  второго узла описания; допуск к p на позиции actual. Ответ READER-REPLY: для обычного чтения действует Q57 —
  `y: 6`/`y: x` при неизвестной голове читается как сам узел y; `y: int: 6` — int-место; `@` — ссылка; чтение готовых
  мест и потребление правой части достигнутой записи — разные операции; корень с неизвестным `x: 4` — тоже Structure x.

## Граф (source62, tool49, rt76, graph84)

- `lmx_graph_named_value`: Structure не строится — значение формала есть сам записанный хвост (Frame `p` или записанная
  группа `(y: int: 6)`); `lmx_graph_literal_value` остаётся только построением операнда `merge`.
- Чтение поля по роли: `lmx_graph_ready_slot` / `lmx_graph_ready_field` (экспорт, graph_run_names 44) — физическое поле,
  а для `name: int: <литерал>` — int-ячейка значения (слот 0 Frame int); ими читают путь (`lmx_graph_eval_value`,
  эмиттер `lm_graph_emit_operand`), пишут путь (`lmx_graph_path_field`, `lm_graph_emit_field_place` — одна ячейка для
  чтения и записи) и допускают формал (`lmx_graph_admit_path`). `lmx_graph_field_value` (потребление правой части,
  связыватель, части ресиверов, запись поздних полей merge) не менялся.
- Фикстуры: `named_tail` — `twice()` дважды вызывает `bump(p: y: int: 6)` из тела: 7, затем 8 (тот же объект);
  `named_tail_computed` — `take(p: y: int: k + 5)` отказывает при допуске (4); `defined_not_callable` — `x: int: 4`.

- Проверки графа: check85 ([таблица](records/pins/opus347-graph-check85.tsv), [журнал](records/pins/opus347-check85.log))
  — 88 строк, 87 PASS; named_tail — только новые строки дампа (`first 7`, `second 8`; записанная Structure в коде
  twice стала `(y (int 8))` — записан сам объект), значения прежних строк (62, 64, 52, 73) те же, три режима совпали;
  ожидание обновлено (source63), check85b ([журнал](records/pins/opus347-check85b.log)) — 1/0. Итого 88/0;
  [named_tail_computed](records/cold-graph309-codex01/check85-named_tail_computed/interp.log) — отказ допуска 4.

- Самосборка boot348 (source63, tool49, fehost15; [журнал](records/pins/opus347-boot348.log)) — `BOOTSTRAP quick 0
  failures`; [сравнение](records/pins/opus347-compare-g1-g2.log): G1 = G2 (образы exe-same, тексты и объекты — сырой
  sha256), рантайм G1 = rt76; G0 (fehost15, source58) отличается от G1 только `l2trans.c` (построитель графа, срез 346).
- Полный набор suite348 ([журнал](records/pins/opus347-suite348.log)) — G2 boot348, 145 строк, 0 отказов.

## Границы (OPEN)

- Граф: неизвестное `x: 4` среди непосредственных полей внешней Structure единицы (и в теле) по-прежнему определяет
  int-место из литерала (`lmx_graph_root_structure`, ветвь определения); по READER-REPLY это Structure x с содержимым 4,
  а уточнение CODEX-OPUS-347-4C-CONVERT-CLARIFICATION-20261110T074300Z-01
  ([текст](records/pins/codex-347-4c-convert-clarification.txt)): роль головы и допуск определяет общий контракт, уровень
  строки ничего не выбирает; `x: 4` при разрешённом месте — обычный допуск к его контракту (другое примитивное
  требование может принять 4 через преобразование, найденное при проверке пригодности и применяемое при потреблении). Чтение `merge` готовых операндов с полями-Frame
  `name: v` (`lmx_graph_merge_level` через `lmx_graph_field_value`) — роль поля пока не применена.
- Lowering: записанная Structure среди actuals — маршрут (b) не реализован, отказ ступени `named_tail_lowering_refused`
  держится.

## Уточнение автора 2026-11-10 (code и data)

Передано Codex CODEX-OPUS-AUTHOR-CODE-DATA-SCOPE-20261110T074510Z-01 ([письмо](records/pins/codex-author-code-data-scope.txt));
дословная реплика сохранена в [журнале](../../../LMX_blog/2026-11-10.md): сквозная видимость — для собственных мест
внутри code метода, корень — у data (var). По нему исправлен §3 `docs/bugs_for_fixing.md` (было «включая корневую
Structure»: сквозная видимость не распространяется на корень, корень — правило выбора полей data и автозаполнения var) и
дополнен пункт 6 M6 плана.

## Происхождение

- rt76 и graph84 запущены одной фоновой командой (`rt76 && graph84`): graph84 начат по коду выхода rt76, до чтения его
  журнала — отклонение от правила «один рецепт на фоновую команду» (как в 288–290).
