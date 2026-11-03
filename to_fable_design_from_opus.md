# Передача дизайна от Opus к fable_pc

Дата: 2026-11-01, около 19:40 UTC. От: Opus. Основания:
- поручение — верх `to_opus.md`;
- требования — [optimization_three_passes_shared_runtime.md](optimization_three_passes_shared_runtime.md);
- уточнения автора — [LMX_blog/2026-11-01.md](LMX_blog/2026-11-01.md).

Мои предложения:
[optimization_proposal_from_opus.md](optimization_proposal_from_opus.md), sha256
`c4aaee704fc475e4292ba89a39cda83c99f7bea786f2b21d3ba8fb809d897892`.

С этого момента я не пишу код, ничего не собираю и не запускаю переводы,
тесты и docs-проверки параллельно с Fable. Сессию не закрываю: жду в ней и
отвечаю на вопросы Codex. Writer/build переходит по координации Codex.

## 1. Репозиторий (main)

- `HEAD` = `origin/main` = `3984006f39268690978eaf131a610fab44eff4f8`
  (срез 249). После него ничего не закоммичено и не запушено.
- Изменены tracked-файлы:
  - `steps/witnesses/fix249-20261101/notes.md` — **мой WIP**. Одно сужение
    строк 64–66: проверки срезов 247/248 шли на runtime RT92, и их
    результаты относятся к RT92, а не к runtime `40B84ECF`.
  - `to_fable.md`, `to_opus.md` — файлы Codex, не мои.
- Неотслеживаемые, мои:
  - `optimization_proposal_from_opus.md`;
  - этот файл;
  - `steps/witnesses/fix250-20261101/` — запись среза 250: `notes.md`,
    `records/` (27 файлов), `coherent100.diff`, `coherent101-draft.diff`,
    `evidence.list` (72 пути). **Не закоммичено, docs-проверка не
    прогонялась**; см. §5.
- Неотслеживаемые, Codex: `optimization_three_passes_shared_runtime.md`,
  `LMX_blog/2026-11-01.md`.
- Чужие неотслеживаемые, были до меня; не трогать:
  - `steps/fable_consumer_suitability_review_20261026.md`;
  - `steps/witnesses/fix208-20261025/`, `fix209-20261025/`,
    `fix210-20261025/{build.lm2.patch,selected-os-machine.patch}`,
    `fix217-20261025/`.

  Защищённые: файл с защищённым basename в корне и
  `steps/witnesses/used-scope-20261020/reference-producer117.patch` — не
  читать, не перечислять, не менять.

## 2. build2 (ignored): моя рабочая зона

`P = build2/codex_fix250generationchain01`.

### Источник и stage

- `P/pins/source-full100.sha256` = `AA841167…` (159 входов) =
  source-candidate94 (`1F374773…`) с одним изменённым файлом: Lower
  coherent100 `47EF085E…` (`P/variants/coherent100/`). Это исправление отказа
  full99 (устаревшее рабочее Value числа или char, строка `sha256_vectors`
  native).
- Stage `P/cold-full100/`. **Внимание: после частичного G2 он уже не
  целый.** В `src/l2src/` нет выходов `l2_frontend_core` и `l2_frontend_emit`
  (`.lm1`/`.h.lm1`), их удалил G2 перед переводом. Входы `.lm2` целы.
  Для сборки из этого stage нужен новый stage или копия по манифесту.

### Поколения full100

- **G1** (`P/cold-full100/full100/g1/`) — **полный**:
  - frontend: `l2trans.exe` `bf6d713e…`, `l1trans.exe` `1b5acb5a…`,
    `l2_libc.o` `af9fdae3…`;
  - runtime: `driver.o` `40b84ecf…`, `driver-observe.o` `16a0c54a…`;
  - `SUITE 37 rows, 0 failures`, `OSWALK 0 failures`, `SELFTEST 0 failures`;
  - tool `lmxtool-tool.exe` `e8150e60…`; продвинутый рабочий tool
    `P/cold-full100/full100/lmxtool.exe` `e8150e60…`;
  - снимок потреблённых входов `consumed-inputs/` (306 файлов), манифест
    `f8826e9a…`.
- **G2** (`full100/g2/`) — частичный. Все 38 выходов frontend-шагов
  (19 модулей, от `p0_own` до `l2_consumer_uses`) побайтно равны G1.
  Остановлен во время перевода Core.

### Варианты

- `P/variants/coherent101/src/l2src/l2_frontend_lower.lm2` `d78dc8a1…` —
  **черновик** ремонта указательного рабочего места. Не staged, не собран,
  не проверен.
- `P/variants/working-pointer101/unit_pointer_context_copy.lm2` `30EA66CE…`
  со списком `P/pins/pointer-copy101.tsv` `53E12702…` — свидетель pointer101.
  `P/pins/red101.command` **не запускался**: он указывает на G2 full100,
  которого нет.
- `P/pins/docs250.command`, `docs250-check.command` — не запускались.

### perf251 (подробно в §1.2 предложений)

- Записи `P/pins/perf251-emit-before-01*.command` и `-02*.command` — копии
  as-run. Действующие `perf251-emit-before.command` и
  `perf251-emit-before-detached.command` относятся к attempt03.
- Дерево `P/pins/perf251-tree03-prepare.command`, его манифесты
  `perf251-emit-tree-03-{all,from-snapshot,from-stage}.sha256` (all =
  `eddc401b…`) и `perf251-emit-tree-03-prepare*.{terminal.txt,log}`.
- Команды gdb: `P/pins/perf251-snapshot.gdb`.
- Каталоги:
  - `P/perf251-emit-before-0{1,2,3}/` — stdout/stderr;
  - `P/perf251-emit-tree-03/` — дерево CWD attempt03, выходов emit в нём нет;
  - `P/perf251-emit-before-0{2,3}-snaps/` — снимки и `times.txt`;
    у 02 снимки отозваны.
- Частные CWD (`*-run-*`, `*-prepare-run-*`) не перечислять: в CWD
  языкового CLI или tool может лежать файл с защищённым basename.

## 3. Точные receipts

- **full99**: FAILED, `BootstrapExit 1`, 13:00:28Z → 15:21:28Z
  (`P/pins/full99.terminal.txt`). В G1 `SUITE 37 rows, 2 failures`, оба —
  `sha256_vectors native`. Причина и исправление —
  `P/pins/OPUS-CODEX-RESULT250-20261101T1550Z.md`.
- **full100**:
  - launcher 15:47:53.26Z, StartUTC 15:47:53.73Z;
  - `EndUTC 2026-11-01T19:06:29.8878065Z BootstrapExit 127`
    (`P/pins/full100.terminal.txt`), `FULL100 EXIT=127`,
    `done 19:06:29.9579116Z` (`P/pins/full100-detached.terminal.txt`);
  - **остановлен Codex по прямой команде пользователя**; не считается ни
    пройденным, ни регрессией;
  - журнал `P/pins/full100.log`: `SUITE 37 rows, 0 failures` (:746),
    `OSWALK 0 failures` (:771), `SELFTEST 0 failures` (:908), `MANIFEST/STAGED
    306 files, 0 failed` (:920–921); G2 — `P/cold-full100/full100/g2-build.log`.
- **perf251 attempt01**: терминалы `P/pins/perf251-emit-before.terminal.txt`
  и `perf251-emit-before-detached.terminal.txt`. Недействителен: помощник `H`
  оказался `Get-History`. 25,7 с.
- **perf251 attempt02**: терминалы `P/pins/perf251-emit-before-02.terminal.txt`
  и `-02-detached.terminal.txt`. Недействителен: пустой CWD, predef не
  открывались, снимки отозваны. 182,0 с.
- **perf251 attempt03**: терминалы `P/pins/perf251-emit-before-03.terminal.txt`
  и `-03-detached.terminal.txt`. Корректный CWD; остановлен в
  19:32:22.45Z по author-priority: 366,0 с wall, 360,3 с CPU, пиковый
  working set 99,0 МБ, выходов нет. 4 снимка — в
  `perf251-emit-before-03-snaps/`, причина остановки — в его `times.txt`.
- **Сообщения Codex** (thread `01a0c718-c517-7ff0-adaf-08ce1aaeb861`):
  RESULT251 (остановка full100, проверка -O2/candidate45, старт профиля),
  NOTE251A (поправка про CWD attempt02), NOTE251B (принятие трёх обходов,
  вопросы Q1/Q2; ответ Codex получен). Файлы
  `P/pins/OPUS-CODEX-{RESULT251,NOTE251A,NOTE251B}-*.md`.

## 4. Процессы и агенты

- Живых процессов моих pipeline нет. Проверено после остановки attempt03:
  `l2trans`, `l1trans`, `lmxtool`, `lmxtool-tool`, `cc1`, `timeout`, `gdb` —
  ни одного.
- Субагентов в этой сессии я не запускал. Фоновые ожидатели завершились:
  full100 done, attempt02 done, attempt03 done.
- lmx_uds — relay-сессия Codex, не мой агент.

## 5. Незавершённое (состояние честно)

1. **Срез 250** не закоммичен.
   - В `notes.md` раздел full100 всё ещё говорит «STARTED».
   - Дописать: G1 прошёл целиком; G2 остановлен 19:06:29Z по команде
     пользователя через Codex; 38/38 выходов G2 равны G1; red101 не
     запускался.
   - В `evidence.list` нет receipts full100 и perf251.
   - Записи в `steps/current.md` и в checklist не сделаны, docs250 не
     прогонялся.
   - Codex: формальное закрытие среза не условие передачи.
2. Правка `steps/witnesses/fix249-20261101/notes.md` (tracked) не
   закоммичена.
3. Указательный родственник рабочего места остаётся **OPEN**. Свидетель
   готов, но не запускался; coherent101 — только черновик.
4. Посадка source-full100 в `selfbuild/` не делалась. Требование FULL перед
   посадкой Codex отменил 2026-11-01.
5. Нормативные тексты, конфликтующие с уточнением автора, **не правлены**:
   перечень в §6 предложений.
6. Полного профиля перевода нет: attempt03 частичный, 4 выборки за первые
   6,1 мин.

## 6. Что пригодится дизайну

- **Корректный автономный перевод модуля требует дерева CWD.** Транслятор
  открывает predef по путям относительно CWD (`l2_frontend_types.lm2:153`,
  `l2_frontend_values.lm2:135` и `:2582`), а build запускает шаг из
  `stage/src`. Готовый образец дерева — `pins/perf251-tree03-prepare.command`
  (по записи frontend G1 и снимку потреблённых входов).
- Порядок проходов, места замыканий и дубли с walker — §2 предложений.
  Подтверждённое: walker берёт скрытые входы из сигнатуры, построенной
  frontend-замыканием (`lmx_walk_input_width`, `lmx_walk_values.lm2:1103`).
  Общего runtime-сброса `native` при записи кода я не нашёл.
- Действующие правила передачи остаются:
  - корневой `build` не трогать;
  - защищённый basename и `reference-producer117.patch` не трогать;
  - без reset/clean, массового `git add`, веток, worktree и PR;
  - не сканировать весь проект, `build2` и transcripts;
  - каждый языковой CLI запускать из своего частного CWD (с учётом
    предыдущего пункта);
  - FULL — только финал.
