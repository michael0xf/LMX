# Срез 346: роль головы записанного поля и применение ресивера int в графе (M6 4c, часть графа) — 2026-11-10

Норма и маршрут: [M6 4c](../../../next_core_tasks_v3.md#m6); ответы Codex CODEX-OPUS-345-LOWERING-TAIL-REPLY (ступень B в
срезе 345, общий построитель — 4c) и CODEX-OPUS-346-4C-DESIGN-REPLY-20261110T054820Z-01
([вопрос](records/pins/opus346-question-4c.txt), [ответ](records/pins/codex-346-4c-design-reply.txt)): анонимная
модель написанного кандидата — временная модель раскладки из самого кандидата (без модели формала и без полей из неё);
`x: T: v` — по написанному T; `x: v` — по роду самого значения (литерал int известен; имя/путь — по требованию
адресуемого места и общему разрешению, без типа из формала и без сохранённого при collection значения; ссылочная
глубина и идентичность цели сохраняются, `name: @x` — ссылка, не копия int); построение в точке достигнутого вызова,
каждый RHS один раз в написанном порядке, затем обычный структурный допуск (тот же, что у `take(pack)` для той же
Structure); именованный и позиционный пути общие (whole-arguments по общему контракту, контейнер не стирается);
нетипизированный операнд merge `(y: 6)` — тот же конструктор, модель merge применяется после построения операндов.
`T: x v` — прежняя запись, не новая каноническая.

## Измерения (fehost15, rt73; P/runs/opus345/p)

- `merge(Point; (y: int: 6))`, затем `take(pack)` — 62 в native и forced; `merge(Point; (y: 6))` — «this merge operand
  form is not lowered yet» ([журнал](records/pins/opus345-lowmerge346.log)).
- `pack: merge((y: int: 6)); take(pack)` переводится; `take(p: merge((y: int: 6)))` — «merge expression is not lowered in
  this receiving context»: подъём среза 307 (`lm_compiler_merge_lift_find`) поднимает только merge-позиционный actual
  ([журнал](records/pins/opus345-lowmerge346b.log)).
- `pack: (y: int: 6); take(pack)` — 62 в native и forced: объявление уже строит кандидата из его собственных полей и
  принимает его по требованиям Consumer (take читает только p\y; полей Point не добавлено). `pack: (y: 6)` —
  переводится, но вызов отказывает «implements is false in function argument»: группа без типизированных полей —
  выражение, `pack` — int ([журнал](records/pins/opus345-lowdecl346.log)).
- Причина: lowering признаёт записанную Structure по полям-объявлениям (`lm_compiler_written_tail`,
  `lm_compiler_written_path_form`: `own_decl_ty` поля != 0); нетипизированное `x: v` объявлением не является.
- Шире: и именованная Structure с нетипизированным полем (`Pt:` / `y: 6` / `end: Pt`, затем `take(Pt)`) отказывает
  «implements is false in function argument» ([журнал](records/pins/opus345-lownamed346.log)): определение поля
  значением `x: v` в теле Structure lowering не делает полем рода значения ни в именованной, ни в записанной Structure.
  Пункт (i) — общий: классификация `x: v` в теле Structure (`lm_compiler_declaration`, ветвь «потреблённого типа» у
  `x: T: v`, строки 888–915 `l2_frontend_resolve.lm2`) должна давать полю контракт рода значения (int-литерал —
  `lm_compiler_contract_new(0, 0, "int", 0)`), только там, где Frame — поле Structure, а не оператор записи места;
  кандидат среди actuals и операнд merge получают ту же классификацию.
- Ответ Codex о порядке CODEX-OPUS-346-4C-ORDER-REPLY-20261110T055204Z-01
  ([ответ](records/pins/codex-346-4c-order-reply.txt)): (b) — кандидат строится в позиции своего actual, после
  проверки имён и формы и после вычисления и приёма более ранних actuals; подготовка раскладки отделена от исполнения;
  подъём 307 не расширять; отказ ступени держать до реализации; проверки порядка: неизвестный формал — ни ранний actual,
  ни кандидат не исполняются; ранний actual не принят — кандидат не строится; успех — эффекты раннего actual, полей
  кандидата, позднего actual, каждый один раз.

- Почему именованное тело отказывает: `lm_compiler_ns_nested_def` (Q57, срез 296 ABSENT-HEAD-WRITE-NORM) читает
  `y: 6` с отсутствующей головой как вложенную именованную Structure y с записанным содержимым — атомом 6 (kind 12,
  `l2_frontend_core.lm2:8964`), а не int-поле y. Граф для именованного тела согласен (поле y — Frame [6]), а его
  построение литерала merge (`lmx_graph_merge_literal_put`) делает `y: 6` int-местом — на этом стоит 62 у
  `take(p: y: 6)` в срезе 345. Правило 4c («`x: v` — по роду значения») с Q57 расходится; вопрос Codex
  OPUS-CODEX-346-4C-Q57-Q ([текст](records/pins/opus346-question-4c-q57.txt)) — какое чтение действует для кандидата,
  объявления `pack: (y: 6)` и именованного тела. Код части (i) до ответа не пишется.

- Ответ Codex CODEX-OPUS-346-4C-Q57-REPLY-20261110T060100Z-01 ([ответ](records/pins/codex-346-4c-q57-reply.txt)):
  прежний совет «`x: v` — по роду значения» отменён; неизвестная голова `y: 6` определяет Structure y с содержимым 6
  — одинаково в кандидате, операнде merge, `pack: (y: 6)` и именованном теле (книга RU:381–388; ответ автора
  unknown-head-return 2026-10-05); `y: int: 6` — int-место (§9:337–343); 62 у `take(p: y: 6)` в графе среза 345 —
  факт прежнего помощника, не норма. Положительные примеры — `y: int: 6`.
- Граф (source59: `lmx_graph_literal_content`, экспорт; `lmx_graph_literal_value`, `lmx_graph_merge_literal_put`,
  эмиттер): поле `name: content` с неизвестной головой — Structure с записанным содержимым, не вычисляется. graph82
  ([прогоны](records/runs/opus346/p/named_tail.run82.txt)): `take(p: y: 6)` — отказ допуска 4 (норма); но и
  `take(p: y: int: 6)` — 4: построитель графа стирает типизированный литерал (`l2_graph_build.lm2:508`: «A literal
  primitive value has the same physical form everywhere, including a typed RHS» — `y: int: 6` и `y: 6` — одна Lmx
  `y [6]`). Вопрос Codex OPUS-CODEX-346-4C-BUILDER-Q ([текст](records/pins/opus346-question-4c-builder.txt)).
- P0: `(c: int: 4; a: int: 6)` — поле c с хвостом `int: 4` и полем a внутри: точка с запятой завершает только текущую
  короткую форму (грамматика §11); два типизированных поля пишутся отдельными контейнерами или вертикальным блоком.

- Ответ Codex CODEX-OPUS-346-4C-BUILDER-REPLY-20261110T061250Z-01 ([ответ](records/pins/codex-346-4c-builder-reply.txt)):
  вариант A — построитель хранит написанное применение ресивера int: `y: int: 6` — Lmx y с полем на Lmx int, чьё поле —
  примитив 6; `y: 6` — Lmx y с полем прямо на примитив 6; различие видно обоим потребителям в самом графе, без флага;
  раннее стирание только вложенного `int: 6` (`l2_graph_build.lm2:508–515`) отождествляло разные программы и снимается
  общим правилом; круглая запись `int(6)` — тот же маршрут; точка с запятой — по грамматике §11 (два типизированных
  поля — `(c: int(4); a: int(6))` или вертикально); достаточно узкого различающего случая.

## Граф: применение ресивера int сохраняется (source60/61, rt75, graph83)

- `l2_graph_build.lm2` (`lm_graph_build_node`): ветвь стирания `int: <литерал>` в примитив снята; `int: 6` и `int(6)`
  строятся последовательностью — Frame int [6] (объявления `int: name [literal]` — прежние места,
  `lm_graph_build_int_place`).
- `lmx_graph_run.lm2`: `lmx_graph_eval_number` — Frame int с одним полем — int этого значения (контракт ресивера);
  `lmx_graph_field_value` — `name: int: <литерал>` отвечает этим int (как прежде `name: <литерал>` при чтении полей
  Structure); `lmx_graph_root_structure` — `name: int: v` на корне — определение места, не блок. Эмиттер
  (`l2_graph_tool.lm2`, `lm_graph_emit_number`) — то же, что интерпретатор. Экспорт не менялся (tool48 годен).
- Различие на одном исходнике: graph82 (стирание ещё есть, правило содержимого уже есть) — `take(p: y: int: 6)`
  отказывает при допуске, как `take(p: y: 6)` ([прогон](records/runs/opus346/p/named_tail.run82.txt)); graph83 —
  62, а `take(p: y: 6)` по-прежнему 4 ([named_tail](records/cold-graph309-codex01/check83b-named_tail/interp.log),
  [named_tail_content](records/cold-graph309-codex01/check83-named_tail_content/interp.log)).
- Фикстуры: `named_tail` — `round take(p: (y: int(5); unused: int(1)); q: 2)` = 52 (два типизированных поля одной
  группы с закрытыми ресиверами), `int: k 1` / `k: int: 8` / `rewritten k * 10 + 1` = 81 (запись известного k на его
  месте, порядок сохранён: в дампе `int: k 8` стоит на месте объявления); `merge_arguments` — `both` одним операндом
  `(c: int(4); a: int(6))` = 46, `wrap` — `(int: a x)`: `int: x` само по себе объявляет int-место x
  (`lm_graph_build_int_place`), поле значения имени пишется объявлением `int: a x` = 39.
- Проверки графа: check83 ([таблица](records/pins/opus346-graph-check83.tsv), [журнал](records/pins/opus346-check83.log))
  — 87 строк, 84 PASS; три FAIL — только дамп: `:=: root ((int 7))` (known_assignment, `root:=int: 7`), `((int a x))`
  (merge_arguments), новые строки named_tail; значения всех трёх режимов совпали с интерпретатором. Ожидания обновлены
  (source61), check83b ([журнал](records/pins/opus346-check83b.log)) — 3/0 в interp, native, forced. Итого 87/0.
- Самосборка boot347 (source61, tool48, fehost15; [журнал](records/pins/opus346-boot347.log)) — 0 отказов, G1 и G2
  собраны и проверены; [сравнение](records/pins/opus346-compare-g1-g2.log): G1 = G2 (образы exe-same, тексты и объекты
  — сырой sha256), рантайм G1 = rt75; G0 (fehost15, source58) отличается от G1 только `l2trans.c`: 121 участок, все в
  модуле построителя графа, который фронтенд содержит для машинного пути — от `lm_graph_build_node` (снятая ветвь и
  её локал) до `lm_graph_build_file` (места модуля нумеруются сквозь модуль, номера после снятого локала сдвинуты);
  `l2trans.lm1`, `l1trans.exe`, `launch.txt` — те же.
- Полный набор suite347 ([журнал](records/pins/opus346-suite347.log)) — G2 boot347, 145 строк, 0 отказов.
- Ошибка правила: семнадцатый промах — `ls opus345-graph-check81* opus346-graph*` в `P/pins` (глоб — перечисление
  каталога pins; защищённое имя не напечатано). Записано в память; имя рецепта взято из журнала сессии.

## Остаётся в 4c (lowering)

1. (i) Lowering читает `pack: (y: 6)` как выражение int (группа без типизированных полей); по ответу Q57 это Structure
   pack с полем — Structure y с содержимым 6 (именованное тело `Pt:` / `y: 6` lowering уже читает так,
   `lm_compiler_ns_nested_def`).
2. (ii) Кандидат среди actuals строится в позиции своего actual (ответ о порядке, (b)): после проверки имён и формы и
   после вычисления и приёма более ранних actuals, поля — один раз в написанном порядке, затем обычный допуск; подъём
   среза 307 не расширяется; отказ ступени `named_tail_lowering_refused` держится до этого.
3. Позиционный путь — общий whole-arguments.
