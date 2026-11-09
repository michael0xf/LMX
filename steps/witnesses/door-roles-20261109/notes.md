# `lmx_process_deadline` из чистого графа: роль имени C-двери по её объявлению (маршрут 331, шаг 5) — 2026-11-09

Исполнитель: opus. Основание — ответ Codex CODEX-OPUS-341-DOOR-HEAD-REPLY-20261109T144914Z-01 на вопрос
OPUS-CODEX-341-DOOR-HEAD-QUESTION-20261109T1505Z-01 ([вопрос](records/pins/opus341-question-door-head.txt),
[ответ](records/pins/codex341-door-head-reply.txt), [входящее письмо relay](records/pins/codex341-door-head-reply-relay-inbound.txt)):
«роль c.X определяется разрешённым объявлением/контрактом C-двери, а не двоеточием, скобками, числом actuals или тем,
слово ли первое поле. Используй существующий общий механизм внешних объявлений F и predef-замыкание, выбранное
исходным графом единицы»; struct/fnptr-тип — объявление места, функция прототипа — вызов, необъявленное имя — вызов
сырой C-двери, `c.sizeof` — оператор C; импорт освобождает свои документы до выпуска модуля. Предыдущие шаги —
[`lmx_clock` из графа](../clock-graph-20261109/notes.md), [растущий список типов заголовка](../header-types-20261109/notes.md)
(срез 341 снял предел, на который первая проба этого шага упёрлась в бэкенде).

## Изменение (src/l2src/l2_frontend_graph.lm2, tools/build.lm2, tools/suite.lm2, tests/cdoor/deadline_machine.lm2)

1. **Роль имени двери.** Frame `c.X: actuals` и вызов `c.X(actuals)` — один Lmx графа (построитель не хранит
   двоеточия). Модуль собирает имена двери, написанные головами Frame в телах его функций
   (`lm_compiler_graph_door_collect`, каждое написание один раз; `c.sizeof` — нет), и спрашивает их роль у
   существующего импорта C-двери фронтенда по predef-замыканию корня единицы (`lm_compiler_graph_import`:
   `lm_compiler_pd_push` для каждого слова `predef:`, затем индекс — `lm_compiler_predef_has_function` → 3 вызов,
   `_has_type` → 1 struct, `_has_fnptr` → 2 fnptr; имени, которого predef не объявляет, — 0, функция сырой двери).
   Импорт освобождается (`lm_compiler_pd_free`, `lm_compiler_snap_free`) до первой строки модуля; роли хранятся по
   адресам написаний голов. Для этого модуль получил predef-заголовки `l2_frontend_types`, `l2_frontend_intern`,
   `l2_frontend_emit`.
2. **Объявление и вызов.** `lm_compiler_graph_declaration`: голова — имя двери роли 1 или 2 → место типа двери
   (`c.T: name [value]`, форма 5) или Frame такого типа иной формы (6); имя двери иной роли — вызов, при любых
   фактических. Форма 5 пока отказывает («the graph path translates no place of a C door type yet» — представление
   не переведено), форма 6 — отказ с объяснением формы. Прежнее правило «имя двери с одним-двумя полями — место» снято.
3. **Выражения.** Строковый литерал `"..."` пишется как написан (C-дверь читает текст). `c.sizeof` — оператор C, не
   вызов: при порядке вызовов он ничего не выполняет и удерживания не требует.
4. **Рецепт.** `bld_kernel_l2` переводит `lmx_process_deadline` из графа (`bld_machine_module_from(…, 1, …,
   "lmx_process_deadline", deadline_names, 3, 0)`) в каждом runtime; комментарии `bld_runtime` и `build_generation`
   называют три модуля входа из графа.
5. **Свидетель C-двери** `tests/cdoor/deadline_machine.lm2` (строка smoke `runs cdoor/deadline_machine.lm2 7 nf`):
   `arm` отказывает без записи (80) и при нулевом дедлайне (81); `disarm` невзведённой записи — 0 без изменений (82);
   дедлайн через минуту — взведено, оба дескриптора, ожидание не больше минуты (83, 84); `disarm` сигналит, ждёт и
   очищает (85); дедлайн за пределом ширины ожидания ОС зажимается до `INFINITE - 1` = 4294967294 (86, 87, 88).

## Вывод `lmx_process_deadline` из графа

Вывод граф-пути — 2748 байт, d8a8fb90b0c5b181e4d14cfce60e98cf6a09fd46b6e8f359adf2afb0de877d20
([целиком](records/runs/opus342/graph-lmx_process_deadline.lm1)); вывод P0 того же hosted F — 2971 байт, 4f02dad4…
([целиком](records/runs/opus342/p0-lmx_process_deadline.lm1)). Вызовы двери как операторы
(`c.CloseHandle(l2_p0_0_d\event)`, `c.SetEvent(…)`, `c.fflush(0)`, `c.abort()`), константы двери (`c.INFINITE`,
`c.WAIT_OBJECT_0`), приведение имени функции модуля к типу-указателю двери (`(cast: (LmxWin32ThreadStart)
c.lmx_process_deadline_body)`), строка — как написаны; `||` записан прямо (у P0 — временный `l2_t0`).

## Проверки

1. **Проба модуля** (связка fehost09: T41 `build-frontend-host` от boot341 G2 на rt67, source42;
   [журнал](records/pins/opus342-build-fehost09.log)). `lmx_process_deadline` переводится обоими путями
   ([журнал](records/runs/opus342/probe-deadline.log)); оба вывода — l1trans и `gcc -std=c99 -O2 -Wall -Wextra
   -Werror=…` `-c` — 0 ([журнал](records/runs/opus342/probe-deadline-cc.log), [C графа](records/runs/opus342/graph-lmx_process_deadline.c)).
   Прежние модули графа той же связкой — те же байты: `lmx_clock` 5af3e1b5…, `lmx_schedule` 89fdc1c2…
   ([журнал](records/runs/opus342/probe-regress.log)).
2. **Роли двери** ([журнал](records/runs/opus342/probe-door.log)). [door_probe.lm2](records/runs/opus342/door_probe.lm2) →
   [L1](records/runs/opus342/door_probe.lm1): `c.CloseHandle: h` и `c.CloseHandle(h)` — оба вызов функции прототипа;
   `c.door_probe_undeclared(x, "text")` — вызов сырой двери со строкой; `c.sizeof(c.LmxWin32ThreadStart) + (cast:
   (size_t) c.CloseHandle(h))` — без удерживаемого локала. Отказы на месте, вывода не остаётся:
   [место типа двери](records/runs/opus342/door_refuse_place.lm2) (форма 5),
   [Frame типа двери иной формы](records/runs/opus342/door_refuse_shape.lm2) (форма 6).
3. **Runtime связан с выводом графа.** Стадия source43 (404 входа: рецепт, свидетель, строка smoke;
   [журнал](records/pins/opus342-stage43.log)); tool42 — `build-self` переводом fehost09 с rt67/driver.o
   ([журнал](records/pins/opus342-build-self42.log), 684cff5b…); `build-runtime R S B S/fehost09/l2trans.exe rt68`
   ([журнал](records/pins/opus342-build-runtime68.log), [запись](records/cold-graph309-codex01/rt68/record.txt)):
   driver.c 94553c65…, driver.o 0ee3203b…. C rt68 отличается от rt67 только в трёх функциях `lmx_process_deadline`
   ([diff](records/pins/opus342-driver-rt67-rt68.diff)): `||` прямо, меньше скобок, стабильный формал без локала.
   Smoke на rt68 — 9 строк без отказов, `deadline_machine` — 7 native и forced, корни 0 и 1
   ([журнал](records/pins/opus342-suite-smoke-rt68.log)).
4. **Мутант.** В стадии зажим `INFINITE - 1U` → `- 2U` ([diff](records/pins/opus342-mutant-lmx_process_deadline.diff));
   runtime rt68m ([запись](records/cold-graph309-codex01/rt68m/record.txt), C отличается одной строкой —
   [diff](records/pins/opus342-driver-rt68-rt68m.diff)); `deadline_machine` на нём — выход 87 во всех четырёх запусках
   ([журнал](records/pins/opus342-mutant-rt68m.log),
   [native 0](records/cold-graph309-codex01/smoke342-rt68m/deadline_machine-native/run-root0.log),
   [native 1](records/cold-graph309-codex01/smoke342-rt68m/deadline_machine-native/run-root1.log),
   [forced 0](records/cold-graph309-codex01/smoke342-rt68m/deadline_machine-forced/run-root0.log),
   [forced 1](records/cold-graph309-codex01/smoke342-rt68m/deadline_machine-forced/run-root1.log)), прочие строки —
   без отказов. Стадия восстановлена из репозитория, `verify` source43 — 404, 0 отказов
   ([журнал](records/pins/opus342-restore43.log)).
5. **`bootstrap quick` boot342** — `T42 bootstrap quick R S B S/fehost09/l2trans.exe boot342 S/tests/smoke.tsv`,
   0 отказов (16:16:28→16:29:11Z; [журнал](records/pins/opus342-bootstrap-quick.log), G2 —
   [журнал](records/cold-graph309-codex01/boot342/g2-build.log)). boot341 G2 не знает ролей двери, поэтому цепочка
   начата с промежуточной связки fehost09. Smoke обоих поколений — 9 строк без отказов (с `deadline_machine`); оба
   поколения переводят `lmx_schedule`, `lmx_clock` и `lmx_process_deadline` из графа. Runtime G1 = runtime G2 = rt68
   (`driver.c`, `driver.o`, `driver-observe.o` байт в байт); frontend, backend и tool G1 и G2 — одни образы кроме штампа
   (`exe-same` 1), их `l2trans.lm1/.c`, `lmxtool.lm1/.c`, `l2_libc.o`, `launch.txt` — одни байты. fehost09 и frontend G1:
   L1, C, `l2_libc.o` и `launch.txt` — одни байты, backend — один образ; frontend-образы различаются, потому что
   fehost09 связан с rt67, а G1 — с rt68, чьи объекты теперь другие
   ([сравнение](records/pins/opus342-compare-g1-g2.log)). Связки: [g1](records/cold-graph309-codex01/boot342/g1/bundle.sha256),
   [g2](records/cold-graph309-codex01/boot342/g2/bundle.sha256),
   [рабочая](records/cold-graph309-codex01/boot342/working-bundle.sha256); frontend G2 l2trans.exe 979c2a1e…,
   l1trans.exe faeeda4a…; рабочий инструмент boot342/lmxtool.exe
   22d4f0ea6818b303994efb9783f83d7660cc6f392772fa5c2ccd6d8d517f3692 (tool G2).

## Границы

Место типа C-двери (`c.T: name [value]`) граф-путь пока отказывает: представление не переведено.
Опрос следующих модулей ядра связкой fehost09 ([журнал](records/runs/opus342/survey.log); команды — строки рецепта
runtime с `--graph`): `lmx_turn` теперь переводится (прежде отказ на `c.lmx_post_discard: mail`, принятом за место;
в рецепт не включён); `lmx_settle` — место `round_fn` типа-указателя двери `c.LmxManagerRound` (форма 5); `lmx_gc` —
операция в `lmx_gc_mark` (оператор 17); `lmx_scratch` — формал `@@:`; `lmx_orphan` — оператор цикла;
`lmx_gc_graph`, `lmx_ids` — `sub` в корне. `bootstrap full` с hosted F — ПОЗЖЕ.

## Команды (P = build2/codex_fix250generationchain01, S = P/cold-graph309-codex01, B = P/cold-candidate48/full48/g2/frontend)

```text
T41 0 entry 0 -- build-frontend-host R S B S/boot341/g2/frontend/l2trans.exe S/rt67 fehost09
(cd S/src) S/fehost09/l2trans.exe 0 entry 0 -- --graph --library --machine lmx_process_deadline_arm
    --machine lmx_process_deadline_disarm --machine lmx_process_deadline_body src/l2src/lmx_process_deadline.lm2
    src/l2src/convert.lm2 src/l2src/primitive.lm2 OUT.lm1
T41 0 entry 0 -- build-self R S B S/fehost09/l2trans.exe S/rt67/driver.o tool42
T42 0 entry 0 -- build-runtime R S B S/fehost09/l2trans.exe rt68
T42 0 entry 0 -- suite S/tests/smoke.tsv R S B S/fehost09/l2trans.exe S/rt68/driver.o S/smoke342-rt68 S/rt68/driver-observe.o
T42 0 entry 0 -- bootstrap quick R S B S/fehost09/l2trans.exe boot342 S/tests/smoke.tsv
```

Записи из build2 скопированы `stage-copy` по [списку](records.list), хеши — [records.sha256](records.sha256) и после
нормализации LF — [records-lf.sha256](records-lf.sha256).
