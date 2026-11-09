# Hosted F — frontend цепочки: маршрут 331, шаг 3 — 2026-11-09

Исполнитель: opus. Основание — ответ Codex на вопрос Opus ([вопрос](records/pins/opus338-question-step3.txt)),
CODEX-OPUS-338-STEP3-REPLY-20261109T125914Z-01 ([текст](records/pins/codex338-step3-reply.txt), сверен байт в байт с
оригиналом в журнале relay — [входящая копия relay](records/pins/codex338-step3-reply-relay-inbound.txt)): «Да, выбирай
(c): готовый hosted F(n-1), работающий со своим runtime(n-1), переводит перенесённый lmx_schedule из источника
поколения n через чистый граф. Полученный машинный объект связывается в runtime(n); затем frontend-модули n и
runtime(n) дают hosted F(n)»; «Модули frontend(n), включая новый граф-путь, связываются только со своим rt(n)»;
«hosted F(n) должен стать frontend выбранного bundle поколения n и входом следующего поколения… Второй постоянно
строящийся standalone F(n) для той же роли не нужен»; «Сохрани в существующем языковом рецепте явную форму запуска,
argv[0], порядок CLI, --library/--machine/--header, exit/stdout/stderr и известный CWD; не угадывай способ запуска по
basename и не добавляй новый shell/C runner». Шаг 2 — [`lmx_schedule` из чистого графа](../graph-machine-20261109/notes.md).

## Изменение (tools/build.lm2, tools/suite.lm2, tools/replay.lm2, tools/lmxtool_methods.lm2)

1. **Запуск frontend — объявление связки.** Связка frontend — каталог с `l2trans.exe`, backend `l1trans.exe` и libc
   `l2_libc.o` — объявляет запуск в `launch.txt`: слова драйвера `0 entry 0 --`, которые идут после argv[0] и перед
   собственными словами frontend. `bld_frontend_launch(a, cap, fe)` пишет fe и эти слова; связка без объявления —
   обычная программа (прежний seed fe309a). Этим помощником запускают frontend все рецепты: перевод программы
   (`bld_program_k`), машинного модуля (`bld_machine_module_from`), библиотеки инструмента (`bld_self`), строки
   `refuses` сюиты, проба snapshot и replay; результат `< 0` — отказ шага, не индекс.
2. **`lmx_schedule` — из графа в каждом runtime.** `bld_machine_module_from(…, int: graph, …)`: при `graph != 0`
   первое собственное слово — `--graph`; `bld_kernel_l2` переводит так `lmx_schedule` всегда. `bld_runtime(REPO STAGE
   BASE FE LABEL)` — снова одна форма, FE — hosted F (обычный F слово `--graph` не принимает, и шаг отказывает —
   отката на P0 нет); седьмое слово `build-runtime` из среза 338 снято.
3. **Объекты и связывание — отдельные стадии.** `bld_frontend_objects`: модули P0 и frontend, построитель
   `l2_graph_build` и граф-путь `l2_frontend_graph` переводит предыдущий frontend, затем backend и libc связки.
   `bld_frontend_link`: агрегат (вид 60), заголовки, корень `tools/l2trans.lm2` от того же предыдущего frontend,
   связывание с `rt/driver.o` → `l2trans-host.exe`, его копия `l2trans.exe` (сверена по хешу) и `launch.txt`; запись —
   `link-record.txt`. `bld_frontend_host` = объекты + связывание (команда `build-frontend-host` даёт целую связку).
4. **Поколение.** `build_generation`: объекты frontend, backend, libc → runtime — оба предыдущим hosted F
   (`lmx_schedule` из графа) → связывание нового hosted F с этим runtime → smoke, полный список, свидетели и tool —
   новым hosted F. Обычный frontend поколение не строит. `generation_bundle` хеширует и `frontend/launch.txt`;
   `rebuild frontend` строит связку (`bld_frontend_host` на RUNTIME-DIR). Слова usage: PREVIOUS-HOSTED-FRONTEND.

## Проверки

1. **Seed-связка.** tool38 (T37 build-self, seed fe309a, rt65). `build-frontend-host R S B fe309a S/rt65 fehost03`:
   `l2trans.exe` cebdf868…, `launch.txt` 52ce29da… (`0 entry 0 --`), libc = libc fe309a байт в байт, backend = backend
   fe309a кроме штампа (`exe-same` 1).
2. **Runtime и граф-инструмент от hosted F.** `build-runtime R S B S/fehost03/l2trans.exe rt66`: все 39 переводов —
   `fehost03/l2trans.exe 0 entry 0 -- …`, `lmx_schedule` — с `--graph`; `driver.c`, `driver.o`, `driver-observe.o` rt66
   = rt65 байт в байт. `build-graph … fehost03 … graph77`: `graph_trans.lm1`/`.c` = graph76, exe — кроме штампа.
   `checks opus339-graph-check77.tsv` (frontend-связка fehost03) — `CHECKS 82 lines, 0 failed`, 246 PASS; `mutation`
   12/12, `method-mutation` 8/8, журналы как у graph76. tool39 — `build-self` с fehost03 на rt66.
3. **Цепочка.** `T39 bootstrap quick R S B S/fehost03/l2trans.exe boot339b S/tests/smoke.tsv` — `BOOTSTRAP quick 0
   failures` (13:20:18→13:32:38Z). G1: объекты, runtime и корень frontend переводит fehost03 (38 модулей путём P0,
   `lmx_schedule` — `--graph`), G2 — hosted frontend G1 так же; smoke обоих поколений — 7 строк, 0 отказов, и
   `schedule_machine` даёт 7 на native/forced, корни 0 и 1. runtime G1 = runtime G2 = rt65 (`driver.c`, `driver.o`,
   `driver-observe.o` байт в байт); frontend, backend и tool G1 и G2 — одни образы кроме штампа (`exe-same` 1), их
   `l2trans.lm1/.c`, `lmxtool.lm1/.c` — одни байты; fehost03 = frontend G1 кроме штампа
   ([сравнение](records/pins/opus339-compare-g1-g2.log)). Рабочий инструмент boot339b/lmxtool.exe = tool G2.
4. **Остановленный запуск.** Первый `bootstrap quick` (boot339, T38) остановлен через 1,5 мин (шаг объектов): при
   разборе diff найден отрицательный индекс при неудачном чтении запуска в двух местах suite; добавлены проверки,
   source37, tool39, запуск boot339b. Метка boot339 сожжена; её журнал — [здесь](records/pins/opus339-bootstrap-quick.log).

## Кортеж

R = C:/Nyasha_Planet/LMX; P = R/build2/codex_fix250generationchain01; S = P/cold-graph309-codex01;
B = P/cold-candidate48/full48/g2/frontend; CWD = P/runs/opus339.

- P/pins/opus339-source37.sha256, 402 входа: 7e4a1fc2bec916860d4997651d5ac5a086be69f0fb66465fe2b995c986daabaa
  (source36 отличается только tools/suite.lm2 — без проверок `n < 0`).
- T38 S/tool38/lmxtool-tool.exe 801fcecfadb85d079d52efddb508bd2f6a150d5851290cfc3a2d487b1eb751e7 (source36);
  T39 S/tool39/lmxtool-tool.exe 13fda0acbd1e0a6721aa740b5441e6eb8f5c0a0a1f29d1f20a0394e2d99ac063 (source37, fehost03, rt66).
- S/fehost03: l2trans.exe cebdf868c6b0c766a1cfef4b543b6d365a21d698c33ffceef946ff0ea61aac31, l1trans.exe
  4d13dbcc1e80a946…, l2_libc.o af9fdae33655f8e6…, launch.txt 52ce29dadaeed2b1….
- S/rt66/driver.o fa5b2855afd0e55fb27f7d2cb836be6e709be9e8006f199024dae3b2aa231123 (= rt65), driver-observe.o
  6efcd754c269fe6c428a66182af49e7f25b22dd68bd826b8228d26f7b5cb3a23.
- G77 S/graph77/graph_trans-prod.exe 36f4a3905586f4d3f67bfbc86118ba515ca952e9fd9acc89c5e5cbb48ba71799.
- boot339b: связки G1 и G2 — [g1](records/cold-graph309-codex01/boot339b/g1/bundle.sha256),
  [g2](records/cold-graph309-codex01/boot339b/g2/bundle.sha256); рабочий lmxtool.exe 104cc8cb28b121b0… (tool G2).

```text
T37 0 entry 0 -- build-self R S B F(fe309a) S/rt65/driver.o tool38
T38 0 entry 0 -- build-frontend-host R S B F(fe309a) S/rt65 fehost03
T38 0 entry 0 -- build-runtime R S B S/fehost03/l2trans.exe rt66
T38 0 entry 0 -- build-graph R S B S/fehost03/l2trans.exe S/rt66 graph77
T38 0 entry 0 -- checks P/pins/opus339-graph-check77.tsv
T38 0 entry 0 -- build-self R S B S/fehost03/l2trans.exe S/rt66/driver.o tool39
T39 0 entry 0 -- bootstrap quick R S B S/fehost03/l2trans.exe boot339b S/tests/smoke.tsv
```

Архив: [список](records.list), [SHA оригиналов](records.sha256), [SHA LF-копий](records-lf.sha256); docs check и
архивные журналы — [список](records2.list), [SHA](records2.sha256), [SHA LF](records2-lf.sha256).

## Граница и следующее

1. Граф-путь переводит один модуль (`lmx_schedule`); следующие машинные модули ядра — `sub`, `--header`, локальные
   места, циклы, вызовы и приведения (lmx_clock: типы C-двери, cast, вызовы своих функций и C-двери).
2. `bootstrap full` с hosted F не запускался (ПОЗЖЕ: полный список, свидетели и G1=G2 полного режима).
3. Обычный frontend остаётся только командой `build-frontend`/`build-frontend-part` (seed и диагностика); цепочка его
   не строит.
