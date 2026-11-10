# Срез 344: метка вызова (M6, шаг а) — 2026-11-10

Норма: автор 2026-11-09 ([журнал](../../../LMX_blog/2026-11-09.md)), «_только_ f(3) или f(): 3 или f(): / . 3 / end: f /
других способов вызова больше нет!»; ответы Codex CODEX-OPUS-344-M6-ANSWERS-20261110T014806Z-01 (порядок работ, `f: v` и
`c.name: args` ничего не вызывают, метка вызова видима в графе как обычная Lmx) и
CODEX-OPUS-344-NAMED-COLON-REPLY-20261110T030245Z-01 (`f(a: 5)` — именованная подача по книге; перенос связывателя —
следующий шаг). План: [M6](../../../next_core_tasks_v3.md#m6) пункты 1, 2, 4, 4a.

## Что сделано

- **P0** (`p0_parser.lm2`): оформление вызова `f(): args` и блочное `f():` … `end: f` — Frame с меткой вызова
  `LM_P0_FRAME_COMPACT` (вместе с `COLON`); `end: f` такого блока — синтаксис, P0 его снимает
  (`lm_p0_end_closes_layout_call`). Frame только с двоеточием метки не получает.
- **Lowering, проверка, обходчик** (`l2_frontend_lower.lm2`, `l2_frontend_emit.lm2`): `lm_compiler_head_is_call` и
  `lm_compiler_frame_is_call` вызывают callable (метод, удерживаемый callable, C-дверь, fnptr) только по метке вызова;
  ветки обходчика (оператор и значение) — тоже. Двоеточечный Frame метода в операторе — запись места метода, которую
  транслятор не выполняет (отказ при проверке); в значении — отказ; `c.X: …` — только объявление места C-типа из predef
  (`lm_compiler_predef_receiver`), иначе отказ; fnptr-локал по двоеточию идёт путём присваивания.
- **Чистый граф** (маршрут 331): построитель делает из метки вызова обычную Lmx операции применения `[(), frame]`
  (`lm_graph_build_apply`; слово `()` — `LmxGraphState\w_apply`, экспорт `lmx_graph_applied`); слово языка в круглой
  записи (`merge(f1)`, `int(5)`) остаётся своим Frame. Интерпретатор (`lmx_graph_eval_apply`, `lmx_graph_applies`),
  эмиттер графа (`lm_graph_emit_apply`, `lm_graph_emit_apply_held`, `lm_graph_emit_refuse_held`), машинный путь
  frontend и печать графа (`lmx_graph_dump_apply`: `head(actuals)`) читают применение; двоеточечный Frame ничего не
  вызывает. Связыватель частей ресивера по голове больше не исключает часть, чья голова называет вызываемое (прежнее
  чтение среза 334 снято вместе с вызовом через двоеточие).
- **Перепись исходников**: диагностика `M6CENSUS` в `lm_compiler_head_is_call` (временная копия стадии) над переводом
  frontend, runtime и инструмента — ~840 срабатываний, все — объявления `c.T: name` C-типов: настоящих вызовов через
  двоеточие в сопровождаемых исходниках нет. Тестовые фикстуры — по переписи полного списка (ниже).

## Команды и результаты (P = build2/codex_fix250generationchain01, S = P/cold-graph309-codex01)

1. **Перепись.** census344 — `build-frontend-host` стадии source45 с временной диагностикой `M6CENSUS <вид> <голова>`
   в `lm_compiler_head_is_call` (boot342, его G2 frontend, rt68; [рецепт](records/pins/opus344-census-fe.command));
   положительная проба `twice: 4` → `M6CENSUS method twice`. Перевод им инструмента (`build-self`): 0 срабатываний;
   ядра (`build-runtime`, [журнал](records/pins/opus344-census-rt.log)): ~240 в 15 модулях; frontend
   (`build-frontend-host`, [журнал](records/pins/opus344-census-fe2.log)): 598 — все `cdoor c.T` объявлений C-типов.
   Полный список строк suite ([журнал](records/pins/opus344-census-suite.log)): вызовы через двоеточие в 12 фикстурах
   (os_twins 8, `source_occurrences`, `named_assign_actuals`, `os_callable_result`) — переведены на `f(args)` /
   `f(): args` / блочное `f():`; графовые фикстуры — по проверке check78 (ниже). Стадия восстановлена stage-copy.
2. **Lowering.** source46/47, fehost10/fehost11 (`build-frontend-host`, boot342 G2, rt68). Пробы
   ([список](records/runs/opus344/m6/probes.tsv), [журнал](records/pins/opus344-probes4.log)): `call_marked_forms`
   (компакт, оформление, блок, значения) — 7 во всех четырёх исполнениях (native/forced × корень 0/1); двоеточечные
   формы метода в операторе и в значении и `c.free: q` — отказ перевода. Тот же список прежним frontend boot342
   ([журнал](records/pins/opus344-probes-old2.log)): `bump: q, 1` и `(twice: 3)` вызывали (выход 80), `c.free: q`
   освобождал буфер дважды (крах), оформление `f():` не переводилось.
3. **Регрессия перевода.** Перевод fehost11 против census344 (перевод до M6): runtime — 137 файлов байт в байт
   ([журнал](records/pins/opus344-regress11-rt.log)); инструмент — `lmxtool.lm1`, `lmxtool.c` одни байты, отличается
   только exe (штампы); frontend — отличаются лишь `p0_parser`, `l2_frontend_lower`, `l2_frontend_emit` (их исходники
   изменены), `backend.c` (включает P0) и exe ([журнал](records/pins/opus344-regress11-fe.log)).
4. **Граф.** source48: tool45 (`build-self`, 9378be3e…, заголовки с `w_apply`, экспорт `lmx_graph_applied`), rt69
   (`build-runtime` tool45 + fehost11: отличаются только `lmx_graph*`, `lmx_arena.h.lm1`, driver), fehost12
   (frontend source48 на rt69), rt70 (машинный путь fehost12 над применением) = rt69 во всех 137 файлах — три модуля
   из чистого графа (`lmx_schedule`, `lmx_clock`, `lmx_process_deadline`) переводятся в те же байты. graph78; check78
   (82 строки, [журнал](records/pins/opus344-check78.log)): 23 отказа — 15 только в записи вызовов в GRAPH-AFTER
   (проверено сравнением без скобок, двоеточий и пробелов: значения те же; ожидаемые файлы заменены), остальные —
   фикстуры, закреплявшие вызов через двоеточие (`tst(a: 5)`, `mytest(a: 5)`, `merge(M; f: 3)`, `name: 7`) или поля
   литерала `c(4)`/`p(@N\a)`: переведены на `a(): 5`, `f(3)`, `name: name(7)`, `c: 4`, `p: @N\a` при прежних значениях;
   `defined_not_callable` отвечает 5 (применение не-вызываемого места; прежде 2 — запись двух значений).
   source51: связыватель частей по голове без исключения вызываемой головы (чтение среза 334 снято) — rt71
   (отличается от rt70 только `lmx_graph_run` и driver), graph79, check79 ([список](records/pins/opus344-graph-check79.tsv),
   [журнал](records/pins/opus344-check79.log)): **83 строки, 0 отказов, 249 PASS**, с новой строкой `call_layout`
   (компакт 7, оформление 8, в фактическом 39, в теле 4, вызовов 8). `colon_call_refused` — отдельно: graph-check
   ccr80 (graph79, rt71; ожидание — выход 1, ответ интерпретатора 5; [рецепт](records/pins/opus344-ccr80.command),
   [журнал](records/pins/opus344-ccr80.log)): интерпретатор отказывает (5, PASS); forced переводится в программу,
   которая исполняет граф при запуске и отказывает на `a: 5` (R0 закрыт с success = 0, выход 1, PASS,
   [журнал](records/cold-graph309-codex01/check80-colon_call_refused/forced/run.log)); native-эмиттер графа
   отказывает в самом переводе (`emit-check native` отвечает 5,
   [журнал](records/cold-graph309-codex01/check80-colon_call_refused/native/emit.log)), поэтому строка native — FAIL:
   отказ перевода, не исполнения (см. «Границы»). Прежние ручные пробы ([журнал](records/runs/opus344/m6g/ccr.run.txt))
   программу forced не собирали: её отказ при исполнении проверен только ccr80. Комментарий фикстуры, прежде
   утверждавший отказ перевода и у forced, исправлен после ccr80 (только комментарий; копия стадии обновлена той же).
5. **Самосборка и полный список.** boot344 — `tool45 bootstrap quick R S B S/fehost12/l2trans.exe boot344
   S/tests/smoke.tsv` (стадия source52, 411 входов, 03:27–03:40Z; [рецепт](records/pins/opus344-boot344.command),
   [журнал](records/pins/opus344-boot344.log), [G2](records/cold-graph309-codex01/boot344/g2-build.log)):
   **`BOOTSTRAP quick 0 failures`**, smoke 10 строк, 0 отказов (с `call_marked_forms`). Сравнение
   ([рецепт](records/pins/opus344-compare-g1-g2.command), [журнал](records/pins/opus344-compare-g1-g2.log)): frontend,
   backend и tool G1 и G2 — одни образы кроме штампа (`exe-same` 1); `l2trans.lm1/.c`, `lmxtool.lm1/.c`, `l2_libc.o`,
   `launch.txt`, runtime `driver.c`, `driver.o`, `driver-observe.o` — одни байты; runtime G1 = rt71 байт в байт. G0
   (fehost12) отличается от frontend G1 двумя текстами отказов `l2_frontend_emit`, переписанными после source48, и
   runtime (rt69 против rt71); `l2trans.lm1` корня и `launch.txt` — те же байты, backend — тот же образ. Первая попытка
   сравнения ([журнал](records/pins/opus344-compare-g1-g2.try1.log)) хешей не посчитала: имя функции `H` в PowerShell —
   псевдоним Get-History. suite344 — полный список frontend G2 boot344 на rt71
   ([рецепт](records/pins/opus344-suite344.command), [журнал](records/pins/opus344-suite344.log), 03:41–03:58Z):
   **`SUITE 143 rows, 0 failures`**, 1125 PASS (с четырьмя строками `calls/`).
6. **Архив и docs check** (tool45, CWD = P/runs/opus344 и P/docs73*-check-run-01). 82 записи: `manifest` и
   `stage-copy` — 82 и 82, 0 отказов; 33 копии с CR переписаны из индекса в LF. 19 журналов рецептов PowerShell
   (UTF-16LE из `*>`; `opus344-stage52.log` — UTF-8 со строками UTF-16LE) git читает как двоичные: они названы
   поимённо с `-text` в `.gitattributes` и хранятся байт в байт. docs73 нашла их (DOCS-EOL, 19 находок); docs73b после
   атрибутов — управляющий байт BEL в строке-комментарии `opus344-graph-check78b.tsv` (`@N\a` стал BEL ещё при записи
   списка оболочкой): байт исправлен в самом списке P/pins (только комментарий, строки проверки прежние), копия и оба
   манифеста пересчитаны (изменилась одна строка каждого); docs73c — OK (35 парных глав, 27 разделов грамматики,
   ссылки, LF всех отслеживаемых файлов в индексе).
7. **Промахи защиты имени** `l2_driver_launch.err` (все сообщены пользователю в срезе): четырнадцатый — при переписи
   простой `ls` корня исходников стадии `S/src` напечатал имя, а `grep -rln … .` оттуда прочитал файл; пятнадцатый —
   `ls` каталога проверки `S/check78-fresh_traversals` напечатал имя; шестнадцатый — `ls` каталога прогона
   `P/runs/opus344/m6g/` (вывод отброшен `head -0`, имя не напечатано; перечисление — само нарушение). Файл нигде не
   скопирован, не хеширован и не заархивирован (списки записей — точные имена; проверено поиском имени в списках).

Архив: [список](records.list), [SHA оригиналов](records.sha256), [SHA LF-копий](records-lf.sha256); docs check и
архивные журналы — [список](records2.list), [SHA](records2.sha256), [SHA LF](records2-lf.sha256).

## Границы

- Именованная подача `a: value` в фактических (книга, named-actuals) ещё не реализована: связыватель вызова принимает
  только `:=`; Frame `a: 5` среди фактических ничего не вызывает и сейчас отказывает — незавершённый перенос, не норма
  (Codex, CODEX-OPUS-344-NAMED-COLON-REPLY; M6 4a — следующий шаг).
- Запись в место метода двоеточием в lowering — отказ проверки (предел перевода); запись в fnptr-локал двоеточием идёт
  путём присваивания, строкой не проверена.
- Двоеточечный оператор на месте функции, известной при переводе (`a: 5` при `fn: a`): интерпретатор отказывает,
  дойдя до оператора; native-эмиттер графа отказывает во всём переводе (`lm_graph_emit_statements_from`: 5), а не
  выпускает отказ на месте оператора, как для мест, определяемых при исполнении (`lm_graph_emit_refuse_held`).
  Поэтому `colon_call_refused` не строка graph-check (native там FAIL) и проверен отдельно (ccr80).
- Не сделаны: объявления `name: fn: …` (M6 3), проверка пустых невызовных форм и анонимной круглой Structure (M6 1),
  мутанты (M6 5), `var` с корня (M6 6), запись `Code(Data)` вместо ресивера `call:`.
