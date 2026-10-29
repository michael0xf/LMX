# LMX передача кодинга Codex

## Действующая передача 2026 10 29

По прямому поручению автора от **2026-10-29** (сессия fable_pc): «спасибо, напиши to_codex.md файл инструкция по передаче
дел to codex, подожди окончания работ всех агентов, допиши to_code.md , напиши to codex чтопередаешь ему дела и
останавливайся». `fable_pc` передаёт **единственный writer/build Codex** и останавливается: после отправки этой передачи
не пишет, не собирает, не запускает процессов, записей и агентов; к работе возвращается только по поручению автора.
Эта передача новее передачи Codex → fable_pc от 2026-10-27 ([to_fable.md](to_fable.md), верхний раздел) и передачи
Opus → Codex от 2026-10-24 (архив ниже в этом файле). Поручения автора из них остаются в силе и переходят к Codex.

**Что передаётся.** Задание 2026-10-27 без изменений: продолжать [next_core_tasks_v3.md](next_core_tasks_v3.md)
(§§8/8a) малыми шагами через короткий bootstrap всей цепочки к работающей source-closed L3+L2 самосборке; FULL-режим и
две FULL-проверенные последовательные самосборки — итоговые требования. Состояние на передачу: whole quick принят на
трёх кандидатах подряд (boot43/44/45), первый `bootstrap full` (full45) упал на двух известных причинах, обе исправлены в
candidate46 по решению Codex, цепочка candidate46 начата (`rebuild frontend` fe46) — продолжение описано ниже по шагам
с точными записями, pins и ожидаемыми строками. Вопросов к Codex больше не ставится: Codex решает сам; действительно
необходимые личные решения автора — через `LMX_blog/q/current/` (порядок из архива §1).

**Приём Codex, 2026-10-29.** Автор возобновил goal; Codex проверил `status=active` и переключил существующую часовую
автоматизацию `lmx-goal` на контроль своей работы и состояния goal. Единственный writer/build теперь Codex. На приёме
fe46 ещё не terminal: процессы `lmxtool` PID10888 и `l2trans` PID16940 живы, перевод core продолжается; CPU транслятора
растёт. Это подтверждённое ожидание текущего pipeline, не основание перезапускать запись или запускать rt46 заранее.
Принимать fe46 только по фактическому terminal/выходам. Уточнения текущего маршрута ниже внесены Codex; исторические
результаты boot43/44/45 и failed full45 не меняются.

**Актуальное продолжение Codex после приёма, 2026-10-29.** fe46 завершился: frontend построен, но smoke FAIL15
на L1 из-за отсутствия generated `lmx_array_owned.h.lm1` в свежей стадии. Полный C diff frontend — один ожидаемый
литерал; backend C/L1 неизменны, exe отличается лишь PE timestamp/checksum. Штатный prerequisite `rebuild runtime`
в новой стадии48 уже принят: rt48 exit0, `SUITE 9 rows, 0 failures`, оба runtime-объекта равны boot45. Он сам
сгенерировал объявления и проверил тот же fe46 с ними; failed fe46 записи не переименованы в PASS.

Очередь теперь **публикация48 → один FULL проверенного кандидата**,
а не автоматическое продолжение прежнего46. Source48 (`514564A9…`, 159 входов) добавляет к46 подготовленные
исправление временных файлов docs/диагностику фазы. tool48 `4ECFF786…` уже принят (exit0, same digest, newtool smoke9/0);
check46 —3/0, invalid — ожидаемый exit1, docs semantics —35/14/оба снимка, exit0. Tracked `selfbuild/` теперь содержит
ровно source48: stage-copy/verify159/0, GNU check0. Границы и EOL/control форматирование старых журналов —
[срез240](steps/witnesses/fix240-20261029/notes.md). Итоговый полный docs-check прошёл exit0, включая grammar/links/EOL/control.
Точное текущее состояние/handle — `P/pins/codex-active-checkpoint-20261029.md`,
команды/pins48 как Markdown-данные — `P/pins/cold-candidate48-tool-rebuild-{runtime,tool48}.md`.
Причина исходного docs-отказа и границы диагноза — [срез239](steps/witnesses/fix239-20261029/notes.md).
Прежние инструкции46 ниже — история передачи и исходные записи; повторять завершённый frontend не нужно.

### Приоритет и обязательные границы

Прочитать AGENTS.md, READ.ME, верх [steps/current.md](steps/current.md) (действующее назначение и «Срез238»),
[to_fable.md](to_fable.md) «Приоритет и обязательные границы» (всё в силе), план v3 и его «Ближайший шаг».

- **Поручение автора 2026-10-27** (дословно в `to_fable.md` и `steps/current.md`): один pipeline; тихую живую сборку не
  убивать и не перезапускать; неизменяемые source snapshots и чужой WIP сохранять; проверять реальные terminal и байты;
  переведённый компонент не называть самосборкой; первая часть допуска проверяет только используемые поля и
  интерфейсы реальных Consumer-вызовов, UNKNOWN сам по себе не отказ, дополнительный анализ — только явный `test`;
  не вводить анализ будущего поведения, protective gates, library comparator, hidden root; L3 печатает L1 как выходной
  текст, ради объявлений арены и пулов L2 не расширять; поддерживаемые ядро, build/test и генераторы — только L3+L2,
  прежние алгоритмы в строках не прятать, новый shell/Python runner не писать; не увлекаться тестовой кампанией вместо
  самосборки; корневой `build` не трогать; basename `l2_driver_launch.err` нигде не читать, не хешировать, не
  копировать; `steps/witnesses/used-scope-20261020/reference-producer117.patch` сохранить; весь проект/build2/transcripts
  не сканировать; обычные завершённые проверенные срезы коммитить и пушить в `main` самостоятельно.
- **Решения Codex, действующие на передачу** (копии в `steps/witnesses/fix238-20261027/codex-reply-*.txt`):
  - CODEX-REPLY-BOOT43-BOUNDS-20261028T052500Z, CODEX-REPLY-TOOL32-LIVE-20261028T052915Z: границы recipe — рабочие
    потолки по измеренным временам, не прогноз; отделённый процесс и Monitor — способ жизненного цикла, не обход защиты
    памяти; pressure-reap не отключать, автоматических повторов остановленных задач не делать; при остановке —
    terminal, причина, стадия, живые процессы, память — в запись.
  - CODEX-REPLY-G1-NEXT-20261028T094834Z: сравнения PE/символов с масками отмечать **отдельно от raw identity**;
    части `docs_*` — командное замыкание инструмента, не мёртвый код; `build-generation` не финализирует bootstrap.
  - CODEX-REPLY-O2-ADOPT-20261028T124940Z, CODEX-REPLY-BOOT44-PROFILE-20261028T194127Z: `-O2 -fno-strict-aliasing`
    закреплён в recipe; sampler/runner с циклом attach/сбор/классификация **не создавать** (записи
    `P/pins/prof01-lower-gdb*.withdrawn.command` не выполнять); ручные `gdb -batch -p PID -x cmds.gdb` снимки своего PID
    допустимы как диагностика; счётчики/фазовые времена — только со следующей необходимой правкой core/emit;
    UNKNOWN/test, grammar/ABI/CLI ради скорости не менять; optimization — не проект вместо §§8/8a.
  - CODEX-REPLY-BOOT45-FULL-20261029T102300Z: основание FULL — actual candidate; FAIL — сохранить terminal и первое
    содержательное место, не маскировать; долги body-guard/WALKROOT/native/admission этим не закрываются; «продолжай
    без ожидания ACK».
  - CODEX-REPLY-FULL45-FIXES-20261029T130000Z: оба блокера FULL — в candidate46 (точный diff ниже); failed full45 не
    трогать; новые FE/tool — существующим component rebuild; короткая проверка ровно исправленных случаев на
    существующих строках, без новых fixtures/matrix/whole quick; затем один `bootstrap full` на свежем label.
- **Неизменные запреты:** никаких reset/clean, массового `git add`, kill тихих процессов, новых веток/worktree/PR;
  frozen inputs не править — новый фикс = новый явно названный кандидат; каждый инструмент L2 запускать из нового
  пустого каталога (драйвер создаёт `l2_driver_launch.err` в CWD); `build2` и `buold_temp` не обходить рекурсивно.

### Снимок Git и расположение незавершённой работы

Рабочий корень `R = C:/Nyasha_Planet/LMX`, ветка `main`, всё запушено; HEAD на передачу — коммит этой передачи
(его SHA — в абзаце «Срез238» ledger-а и в сообщении Codex). От Verified237 `89caa75c` до передачи — 60+ коммитов
fable_pc: Verified238 `3c4554ab` (boot43), записи среза, документ об ускорении, поправка чек-листа; только документы и
witness-копии — **поддерживаемые исходники в tracked tree не менялись** (источники L2-порта живут в ignored `build2`).
Tracked tree чист. Чужие untracked, не трогать и не коммитить: корневой `l2_driver_launch.err`,
`steps/fable_consumer_suitability_review_20261026.md`, `steps/witnesses/fix208-20261025/`, `fix209-20261025/`,
`fix210-20261025/{build.lm2.patch,selected-os-machine.patch}`, `fix217-20261025/`,
`steps/witnesses/used-scope-20261020/reference-producer117.patch`.

Весь WIP и receipts — в ignored `P = R/build2/codex_fix250generationchain01` (не tracked; старые checkpoint-ы Codex там
же). Имена каталогов версию не выбирают: опираться на pins записей, manifests и terminal-ы. **Замороженные кандидаты**
(159 файлов: 65 src + 34 tools + 60 tests; манифест = `P/pins/source-candidateNN.raw.sha256`, список
`source-candidateNN.list`, запись `source-candidateNN-manifest.command`):

| Кандидат | SHA256 манифеста | Отличие от предыдущего | Статус |
| --- | --- | --- | --- |
| 43 | `48C330DF62422816A21B7410F127FB53C01ADDFA3935E639445D356CBD00708C` | candidate42 + границы recipe (`build.lm2:801` 6 ч, `suite.lm2` child 24 ч) | whole quick boot43 PASS — Verified238 |
| 44 | `1755CF046ACAD43ECE3DEBF98BBD34CD8A32F761A64DBE3694BAF6B2388A9C62` | `build.lm2:713` frontend `-O2 -fno-strict-aliasing` | whole quick boot44 PASS |
| 45 | `D74D30B4BB2459AFC0BCBC418953BC95E5AA7D7ED0EBD652AE98BD2D83ECA8DC` | `l2_frontend_context.lm2`: имя раньше `own_unit_seen` в 4 own-lookup | whole quick boot45 PASS; **full45 FAIL** |
| 46 | `AE0340AEA8AE8C552242A55E38A289EB6CF86E2274E96E4D57C49FA14B433111` | три файла `P/variants/full46/` (ниже) | fe46 ещё идёт; его приёмка и rt46/tool46/check46/full46 — Codex |

Старые кандидаты 39–42 и их стадии (`initial-tool32-*`, `warm-frontend39/40/41`, `cold-candidate42`) — история среза
(boot42 упал на границе recipe; tool32-05 — первый инструмент из 33 частей, `9D0C2BBD…`).

**Стадии и рабочие инструменты** (все под `P/`; каждая стадия — и живой выход, и свидетельство: не переписывать):

| Стадия | Что | Инструмент / связка |
| --- | --- | --- |
| `cold-candidate43/boot43` | whole quick candidate43 (G0 = tool32-05 `9D0C2BBD…`, previous_fe warm41 `F70A00DA…`) | G2 `boot43/lmxtool.exe` `BDA3AB45…`, FE `boot43/g2/frontend/l2trans.exe` `37AA0FB5…` |
| `cold-candidate44-tool/{rt44,tool44b}` | `rebuild runtime` + `rebuild tool` candidate44 инструментом boot43 G2 | `tool44b/lmxtool-tool.exe` `E9B58831…` |
| `cold-candidate44/boot44` | whole quick candidate44 (G0 = tool44b, previous_fe `warm-frontend41-O2` `F6E8B9FA…`) | G2 `boot44/lmxtool.exe` `4B615C32…`, FE `58A8D274…` |
| `cold-candidate45/boot45` | whole quick candidate45 (G0 = boot44 G2, previous_fe boot44 g2/frontend) | G2 **`boot45/lmxtool.exe` `A69A7EE26315C058E85FE0FA9D1EFD921B4C3032421030704948575C16997FB4`**; связка `boot45/g2/frontend/` `l2trans.exe` `159F3D5EA3F5EA77CD42A8A8706750369CFC36584A28EE3D43D78995E69C06A7`, `l1trans.exe` `DF1FBCD5516C6C463B4BD02D0223342360245538D75BE1834312D0F3E07600A9`, `l2_libc.o` `AF9FDAE33655F8E6235310720787102921450F0F88F9B7BB2F365D372F553D37`; runtime `boot45/g2/runtime/` `driver.o` `8C2708AF530BC624F1A1C48207F00685AC5C6F5FB72843A49C4C0258277BEEDC`, `driver-observe.o` `0A1C51D9BAF3B3449D65419169659DD77F1C787697CDE03821203BD3F96A2DB4` |
| `cold-candidate45-full/full45` | `bootstrap full` candidate45 — FAIL, сохранён | G1 собрана (FE `E519A698…`), полный список 3 FAIL |
| `cold-candidate46-tool` | стадия сборки компонентов candidate46: `fe46/` ещё строится; `rt46/`, `tool46/` — после приёмки | `fe46/` (ниже) |
| `cold-candidate46` | свежая stage-копия candidate46 для `bootstrap full` (STAGED 159, GNU 0; `src/tests/tools` только) | — |

Репозиторные копии источников порта старее кандидатов: `dev/l2src_sandbox/` хранит лишь часть модулей (например,
`l2_frontend_context.lm2` в версии candidate44), `tools/l2/build.lm2`, `tools/l2/suite.lm2`, `tests/l2/suite.tsv` —
прежние версии. Когда и как переносить принятые кандидаты в отслеживаемые maintained-пути — **открытый вопрос, теперь
решение Codex** (поставлен в абзаце «Срез238» 2026-10-29; ответа не было).

### Что проверено и что нет

- **boot43** (Verified238 `3c4554ab`): первый whole quick с L2-портом frontend-а на source-only кандидате: G0 (tool32-05)
  строит и проверяет G1, G1 — G2, G2 продвинута; 24990 с (G1 под нагрузкой сессии). G2 воспроизводит G1 raw по всем
  выходам, кроме трёх PE-файлов, равных под маской TimeDateStamp+CheckSum — неподвижная точка; самосборный
  `frontend.c`/`l2trans.exe` = warm41 (маска PE). Witness `steps/witnesses/fix238-20261027/cold-candidate43-boot43/`.
- **boot44**: `-O2` для frontend-а принят whole quick, 22178 с (−11.3 %); G2 = G1 raw кроме PE; recipe-сборка `-O2`
  воспроизводит ручной FE-O2 под маской PE. Witness `cold-candidate44-boot44/` (+ `records/`).
- **boot45**: own-lookup принят whole quick (51358 с **включая ≈ 8 ч сна машины** — не benchmark); G2 под изменённым FE:
  frontend 9304 с против 10081 (−7.7 %); lower 1310 (−12.3 %), core 3085 (−8.6 %), emit 4493 (−5.4 %); `frontend.c` G1 =
  G2 = development-FE `712126F6…`. Witness `cold-candidate45-boot45/`.
- **full45 FAIL** (12:53:49 UTC, 8933 с): G1 собрана (frontend 8639 с: lower ≈ 1310, core 2714, emit 4275; runtime 160 с),
  полный список `SUITE 37 rows, 3 failures` → `FAIL bootstrap: G0 builds and tests whole G1: 1`. Две причины, ни одна не
  замаскирована: (1) `c_call_one_actual_root` native/forced **root1** — `lmx: walk error: UNSUPPORTED`, driver exit 3 —
  известный OPEN WALKED-ROOT-C-DOOR-UNSUPPORTED (обходчик не исполняет C-дверь; решение Codex 2026-10-23: общий выбор
  roots в runner-е); (2) `os_second_block_refused native: the refusal says the needle` — порт отказывает в той же позиции
  12:1, но раньше (счётчик `os_count` в `lm_compiler_source_directives`, `emit.lm2:531–551`) и текстом «(a source unit
  reads one os block)» вместо текста twin-а «(the program reads one os block)» — PORT-SECOND-OS-BLOCK-MESSAGE.
  Witness `cold-candidate45-full45/` (terminal, лог, record.txt, `failures.tsv`, логи упавших строк).
- **Не покрыто:** ни один `bootstrap full` не прошёл; двух последовательных FULL-самозамещений нет; FULL добавляет к
  quick на генерацию полный список, os walk witness, child + selftest и в конце три байтовые проверки (`G2's L1 is G1's
  bytes`, `G2's C is G1's bytes`, `G1 and G2 are one image apart from the link stamp`) — они **ещё ни разу не
  исполнялись**. Это не S8.6 и не завершение плана: общая почта §8a, чистое ядро/clean native, долги body-guard
  (MACHINE-HEADER-OS-GUARD), WALKROOT-PARTS36-UNSUPPORTED, native/admission, перенос принятых кандидатов в maintained-пути
  — открыты.

### candidate46 и точная цепочка до full46

**Diff candidate46 против candidate45 — ровно три файла** (`P/variants/full46/`, те же байты в `P/source-candidate46/`):

- `src/l2src/l2_frontend_emit.lm2` `D461991F22087329AA1461B452BA0D05E140F7EB78062E9F0F60AA649596A753`: одна строка 550 —
  литерал → `"a second os block is not supported yet (the program reads one os block)"`; `os_count`, ранняя проверка и
  порядок оставлены (решение Codex; twin — свидетель прежней диагностики, не оракул нормы).
- `tools/suite.lm2` `3F38AF62C153C77231B5FAE6F025F5AEA54C9AAEA52EF84B00D9ADA37762E01C` (+31 строка): `runs_modes_ok`
  после `modes_ok` (буквы n/f — режимы сборки, суффикс `0` только root0, `1` только root1, `01`/`10` оба; без суффикса —
  оба, как прежде; недопустимый selector — отказ строки как malformed, не молчаливое игнорирование); в `suite_row_check`
  для `runs` — `runs_modes_ok` с why «MODES is not n, f, nf or fn, optionally followed by the roots 0, 1 or 01»; в
  `suite_runs` — `run0/run1` по `c.strchr(modes, 48/49)` и цикл roots под условием выбора; `modes_ok` для
  refuses/twins/links не расширен; комментарий заголовка списка документирует суффикс.
- `tests/full-suite.tsv` `CB3A4CC72B7BE96F895BC803E7F537BD04483FA29A6B87E1A3B9830C207F1ACE`: строка 32
  `runs cdoor/c_call_one_actual_root.lm2 7 nf0` (было `nf`); строка 6 документирует суффикс. `tests/l2/suite.tsv:28`
  (needle os) не менялся.

Stage-копии candidate46 инструментом boot45 G2 (13:06 UTC, `P/pins/cold-candidate46-tool-stage-copy.*`,
`cold-candidate46-stage-copy.*`): обе `STAGED 159 files, 0 failed`, `sha256sum -c` 0.

**Шаг 1 — `rebuild frontend` fe46 (запущен fable_pc, приёмка Codex после terminal).** Запись
`P/pins/cold-candidate46-tool-rebuild-frontend.command` (11 pins: gcc, timeout, инструмент `A69A7EE2…`, связка
`boot45/g2/frontend/` ×3, runtime `boot45/g2/runtime/` ×2 — для smoke, stage `tools/build.lm2`
`28DFBFA951A20B50F1E1E97DA13232CC543FCC0F6CEAC8A4A62E25B8B053F4C3`, stage `tools/suite.lm2` `3F38AF62…`, smoke-список
`tests/smoke-kernel225.tsv` `32EAD2C43E749EA531B0B6D4D610891C17EC9704134FA1C72C63864F51AA3EC6`); argv
`rebuild frontend R P/cold-candidate46-tool P/cold-candidate45/boot45/g2/frontend P/cold-candidate45/boot45/g2/frontend/l2trans.exe
P/cold-candidate45/boot45/g2/runtime fe46 P/cold-candidate46-tool/tests/smoke-kernel225.tsv`; bound 14400 с; отделённый
запуск через `…-detached.command`; лог `P/pins/cold-candidate46-tool-rebuild-frontend.log`, terminal
`…-rebuild-frontend.terminal.txt`. Запущен 13:07:17 UTC.
**Состояние на остановку fable_pc (2026-10-29 ≈ 13:45 UTC, по указанию автора «останавливай всё и передавай работу to
codex»): fe46 ещё идёт** отделённым процессом — его не останавливаю (действующее правило автора и Codex: тихую живую
сборку не убивать и не перезапускать). Ход: мелкие модули 13:07–13:10 UTC, useplan до 13:12:12, lower 13:12:12 → 13:33:46
UTC (1294 с), `l2_frontend_core` переводится с 13:33:46 UTC (l2trans PID 16940; ожидание ≈ 2700–3100 с), затем emit
(≈ 4300–4500 с), затем l1trans/gcc связки и smoke предыдущим runtime; **ожидаемый terminal ≈ 15:45 UTC**. Результат читать
в `P/pins/cold-candidate46-tool-rebuild-frontend.terminal.txt` (`EndUTC`, `ElapsedSeconds`, `RebuildExit`, hash-и
`l2trans.exe`/`l1trans.exe`/`l2_libc.o`/`frontend.c`, затем `EXIT=`/`done` от launcher-а) и в логе `…-rebuild-frontend.log`
(`REBUILD frontend 0 failures`, `SUITE 9 rows, 0 failures`); выходы — `P/cold-candidate46-tool/fe46/` (связка, `record.txt`,
`*.L2.log` модулей; их mtime в UTC — времена шагов) и `P/cold-candidate46-tool/src/l2src/*.lm1`. Ожидания по байтам: все
`*.lm1` модулей raw = стадия boot45 (`P/cold-candidate45/src/l2src/`), кроме `l2_frontend_emit.lm1` (один литерал);
`frontend.c` ≠ boot45 G2 только этим литералом; `l2_libc.o` = `AF9FDAE3…`; `l1trans.exe` raw ≠, под маской PE = boot45
(`1523CA69…`; backend не менялся). Если terminal — FAIL или остановка (reaper, память, граница recipe): сохранить
terminal/лог (и `killed-<stamp>/`, если процесс исчез), разобрать первое содержательное место; повтор той же записи —
решение Codex, те же байты без причины не повторять. Копии записей candidate46 и check-списков уже лежат в
`steps/witnesses/fix238-20261027/cold-candidate46-fe46/records/`; terminal и лог fe46 после конца — скопировать туда же.

**Шаг 2 — `rebuild runtime` rt46 (Codex).** Вывести запись из `P/pins/cold-candidate44-tool-rebuild-runtime.command`
(и её `-detached.command`): CWD `P`; инструмент → `P/cold-candidate45/boot45/lmxtool.exe` (`A69A7EE2…`); STAGE →
`P/cold-candidate46-tool`; BASE → `P/cold-candidate45/boot45/g2/frontend` (recipe BASE не использует; как в fe46); FE →
`P/cold-candidate46-tool/fe46/l2trans.exe`; RT-аргумент → `P/cold-candidate45/boot45/g2/runtime`; label `rt46`; SMOKE
`P/cold-candidate46-tool/tests/smoke-kernel225.tsv`; лог `P/pins/cold-candidate46-tool-rebuild-runtime.log`. Pins:
toolchain, инструмент, связка fe46 (`l2trans.exe`, `l1trans.exe`, `l2_libc.o` — hash-и из terminal fe46), stage
`build.lm2`/`suite.lm2`, smoke-список; outputs-must-not-exist — `P/cold-candidate46-tool/rt46` и лог. Ожидание:
`REBUILD runtime 0 failures`, `SUITE 9 rows, 0 failures`, ≈ 4 мин; выходы `rt46/driver.o`, `driver-observe.o`, `driver.c`.
Raw-ожидание: `driver.o` = `8C2708AF…`, `driver-observe.o` = `0A1C51D9…` (те же источники ядра; изменение emit.lm2 —
только текст диагностики) — расхождение разобрать, не маскировать.

**Шаг 3 — `rebuild tool` tool46 (Codex).** Вывести из `P/pins/cold-candidate44-tool-rebuild-tool44b.command`: тот же
инструмент/STAGE/BASE/FE, RT → `P/cold-candidate46-tool/rt46`, label `tool46`, лог
`P/pins/cold-candidate46-tool-rebuild-tool46.log`; pins + объекты rt46. Ожидание: `REBUILD tool 0 failures`,
`PASS the tool tool starts and hashes a file as this tool does: the same digest`, `PASS rebuild: the new tool runs the
smoke list`, ≈ 12–13 мин; выходы `tool46/lmxtool-tool.exe`, `lmxtool.lm1`, `lmxtool.c`. Против `lmxtool.lm1`/`lmxtool.c`
инструмента boot45 G2 (`P/cold-candidate45/boot45/g2/tool/lmxtool.lm1`, `lmxtool.c`; после маски префикса единицы
`l2_u[0-9A-F]{16}_` — путь источника различен) отличие должно сводиться к изменению `suite.lm2` (recipe входит в методы
инструмента; frontend в инструмент не входит).

**Шаг 4 — короткая проверка check46 (Codex)** — ровно исправленные случаи на существующих fixtures, без новых
fixtures/matrix/whole quick (решение Codex). Списки готовы: `P/component-check46/check46.tsv`
(`1363FBAE143C90D983E51CD105DBEF487A06831F575DE81CF3700BFF8C7B78DF`; три строки с абсолютными путями fixtures стадии
`cold-candidate46-tool/tests/`: `refuses os/os_second_block_refused.lm2` с прежним needle; `runs
cdoor/c_call_one_actual_root.lm2 7 nf0`; `runs cdoor/c_call_one_actual.lm2 7 nf`) и `check46-invalid.tsv`
(`EA29D6619041DCACD2A2923E638BF9809CB5744325689DB95067D6F439015A64`; одна строка `… 7 nf2`). Команда инструмента
(usage `lmxtool_methods.lm2:1383`): `suite LIST REPO STAGE BASE FRONTEND RUNTIME OUT [OBSERVED]` — из нового пустого
каталога (например `P/component-check46/run-01/`), `timeout` ≈ 1800 с:
`P/cold-candidate46-tool/tool46/lmxtool-tool.exe 0 entry 0 -- suite P/component-check46/check46.tsv R
P/cold-candidate46-tool P/cold-candidate45/boot45/g2/frontend P/cold-candidate46-tool/fe46/l2trans.exe
P/cold-candidate46-tool/rt46/driver.o P/component-check46/out-01` (по `fixture_suite`, `suite.lm2:620`, и
`lmxtool_methods.lm2:1341`: FRONTEND — путь к `l2trans.exe`, как FE у `rebuild`; RUNTIME — путь к **`driver.o`**, не каталог
(`prod`, `objs[0]`); необязательный OBSERVED — `driver-observe.o`, нужен только строкам `twins`, которых в check46 нет). Ожидание: `SUITE 3 rows, 0 failures`, exit 0; у строки `nf0` только
root0 (native и forced дают 7), у строки `nf` — оба roots; refuses — `PASS … the refusal says the needle` native и walked.
Второй запуск с `check46-invalid.tsv` в `out-02`: ожидание — строка FAIL с why «MODES is not n, f, nf or fn, …», `SUITE 1
rows, 1 failures`, exit 1 (недопустимый selector не игнорируется). Иное — дефект candidate46, не норма: новый кандидат.

**Шаг 5 — `bootstrap full` full46 (Codex).** Вывести из `P/pins/cold-candidate45-full-bootstrap.command` (13 pins) и
`…-detached.command`: инструмент G0 → `P/cold-candidate46-tool/tool46/lmxtool-tool.exe`; STAGE → `P/cold-candidate46`
(свежая; outputs-must-not-exist: `full46`, `headers`, `src/l2src/lmx.h.lm1`, `src/l1src/libc_abi.lm1`, лог, preflight-лог);
BASE → `P/cold-candidate46-tool/fe46`; previous_fe → `P/cold-candidate46-tool/fe46/l2trans.exe` (pins: его `l1trans.exe`,
`l2_libc.o`); манифест → `P/pins/source-candidate46.raw.sha256` (`AE0340AE…`, preflight `sha256sum -c --quiet` в стадии);
label `full46`; SMOKE `P/cold-candidate46/tests/smoke-kernel225.tsv`; FULL-LIST `P/cold-candidate46/tests/full-suite.tsv`
(`CB3A4CC7…`, 56 строк); внешний bound 172800 с; лог `P/pins/cold-candidate46-full-bootstrap.log`. Ожидание ≈ 6 ч без
сна машины (full45: G1 до полного списка 2.45 ч; плюс список ≈ 37 строк, os walk witness, child + selftest, tool ≈ 12 мин;
затем G2 столько же и три байтовые проверки). Приёмка: `BOOTSTRAP full 0 failures`, BootstrapExit 0, `PASS` обеих
генераций, `SUITE 37 rows, 0 failures` ×2, `G2's L1 is G1's bytes`, `G2's C is G1's bytes`, `G1 and G2 are one image apart
from the link stamp`, `MANIFEST`/`STAGED … 0 failed`; `full46/lmxtool.exe` = инструмент G2. Raw сверить с boot45 G2:
ожидание — все выходы модулей кроме `l2_frontend_emit.lm1`/`frontend.c` (один литерал) и инструмента (suite.lm2) равны;
PE — отдельно под маской. При FAIL — сохранить всё, разобрать первое содержательное место, не маскировать, не
перезапускать те же байты; исправление — следующий кандидат.

**Дальше (уточнение Codex, 2026-10-29).** Один штатный успешный `bootstrap full` уже строит и полностью проверяет
два последовательных поколения G1/G2 с обеими фактическими заменами; именно это требует S8.6 в плане v3. После full46
сверить эти факты, source closure и публикацию принятых maintained-источников, затем продолжать незакрытые зависимости
§§8/8a и долги ниже. Второй целый FULL на неизменных байтах автоматически не назначается: он добавил бы ещё два
поколения без отдельного требования. Повтор всей цепочки нужен после соответствующего изменения или для конкретного
недостающего доказательства, включая предусмотренную планом проверку после почтового среза. Один зелёный FULL сам по
себе не закрывает source closure, clean/native/admission или почту. Второй пункт плана «Ближайший шаг: ускорение»
(фазовые времена/счётчики) — со следующей необходимой правкой core/emit, не отдельно.

### Открытые дефекты и долги

Статусы — [steps/defects.md](steps/defects.md). Открыты из среза 238: **MACHINE-HEADER-OS-GUARD** (у производителя
заголовок закрыт; остаток — guard тела при `--header`), **PORT-SECOND-OS-BLOCK-MESSAGE** (исправлен в candidate46 по решению
Codex — закрыть по приёмке full46), **WALKROOT-PARTS36-UNSUPPORTED**, **BARE-DEREF-ACTUAL-MERGED**. Открыт
**WALKED-ROOT-C-DOOR-UNSUPPORTED** (диагностический долг; строка полного списка теперь `nf0` — не закрытие дефекта).
Закрыты в 238: RECIPE-MACHINE-MODULE-BOUND, TOOLS-WIP-NEVER-TRANSLATED, PORT-NAME-COLLISION-USE-NOTE. Прежние OPEN/IN WORK
(Opus/Codex 2026-09-30…10-25, список в архиве §7) — обязательства без изменений.

[optimization_proposal_from_fable.md](optimization_proposal_from_fable.md) (§1 факты, §7 состязательная проверка,
ответ Codex): пункты (1) и (3) «Ближайшего шага» плана выполнены по одному разу (boot44, boot45); пункт (2) — с правкой;
дальнейшие участки (predef name-set — ячейка состояния = правка recipe; `node_in` под `own_source_visible`) — не
начаты, по решению Codex «не сейчас».

### Документы, свидетели, записи

- [steps/current.md](steps/current.md): «Срез238 — fable_pc» — абзацы по шагам (эмиттер07, warm39/40/41, tool32-02…05,
  candidate40–46, boot42–45, документ об ускорении, профиль, full45, candidate46, fe46, передача).
- `steps/witnesses/fix238-20261027/`: `cold-candidate42-boot42/`, `cold-candidate43-boot43/`, `cold-candidate44-boot44/`
  (+ `records/`), `cold-candidate45-boot45/`, `cold-candidate45-full45/`, `o2exp01/`, `prof02-useplan-gdb/`,
  `devfe45-context-ownat12/`, `candidate44-tool44-fail/`, `initial-tool32-43-killed-20261028T0524Z/`, `decl4143/`,
  `lower439/`, `probes/`, `ccall-actuals-probes01/`, `p0-tailcutter-probe01/`; копии всех ответов Codex и моих
  сообщений (`codex-reply-*.txt`, `fable-*.txt`); копии записей fe46 и этой передачи — `cold-candidate46-fe46/`.
- `P/pins/`: записи и terminal-ы `cold-candidate4N-{stage-copy,bootstrap(-detached)}`, `cold-candidate44-tool-rebuild-*`,
  `cold-candidate45-full-*`, `cold-candidate46-{stage-copy,tool-stage-copy,tool-rebuild-frontend(-detached)}`,
  `source-candidate4N-manifest.*`, `warm41-*`, `o2exp01-*`, `devfe45-*`; `P/variants/` — варианты по имени;
  `P/component-check46/` — списки проверки; `P/component-prof01/cmds.gdb` — команды ручного снимка.
- [next_core_tasks_v3.md](next_core_tasks_v3.md) «Ближайший шаг: ускорение следующей сборки» (строки «Выполнено»);
  [next_core_tasks_v3_checklist.md](next_core_tasks_v3_checklist.md) — датированная поправка сводки 237 (2026-10-29).

### Практика и подводные камни (измерено в срезе 238)

- **Записи.** Каждая команда — рукописная запись pwsh 7 (`C:/Users/mtkra/.cache/codex-runtimes/codex-primary-runtime/
  dependencies/native/powershell/pwsh.exe`): проверка CWD, `$taskPins` (JSON путь/sha256, счёт pins), guard pipeline
  (`^(gcc|cc1|collect2|ld|as|l1trans|l2trans|lmxtool-tool)\.exe\z` — ни одного процесса), свободная virtual memory
  ≥ 838861 KiB, outputs-must-not-exist, сброс `CPATH`-переменных, `StartUTC`/`PreVMKiB`/hash-и входов, `timeout.exe`
  с bound, `EndUTC`/`ElapsedSeconds`/`…Exit`, hash-и выходов, выборка `PASS|FAIL|REBUILD|SUITE|MANIFEST` из лога.
  Запуск: `pwsh.exe -NoProfile -NonInteractive -Command "Set-Location -LiteralPath '<ctx>'; & ([ScriptBlock]::Create((Get-Content
  -Raw -LiteralPath '<запись>')))"` с tee в `<запись>.terminal.txt`. Многоминутные и многочасовые шаги — **отделённым
  процессом** через launcher-запись `…-detached.command` (`Start-Process` скрытого pwsh; дочерний pwsh исполняет запись и
  дописывает `EXIT=`/`done` в terminal): фоновая оболочка сессии дважды убивалась reaper-ом при простое по памяти
  (tool32-05 05:24 UTC, цикл ожидания), отделённые процессы — ни разу; boot45 пережил ≈ 8 ч сна машины (после сна
  медленнее: emit 96 мин CPU против 79). Наблюдение — Monitor с перевооружением по логу стадии, terminal `done` и потере
  процесса; тишина буферизованного stdout — не зависание (смотреть mtime `*.L2.log` стадии и `record.txt`).
- **Recipe.** `rebuild tool` на свежей стадии падает на корневом L1 (`cannot read import l2src/lmx_array_owned.h.lm1`):
  объявления ядра пишет шаг runtime — сначала `rebuild runtime` (witness `candidate44-tool44-fail/`). `rebuild frontend`
  пишет L1 модулей в `STAGE/src/l2src/` и связку в `STAGE/<label>/`, smoke — предыдущим runtime. Границы recipe: модуль
  21 600 000 мс, дочерняя генерация 86 400 000 мс, методы/корень инструмента 3 600 000 мс; внешний bound bootstrap
  172800 с. BASE recipe не использует.
- **Идентичность.** Сначала raw sha256; «равно после маски X» — отдельной фразой: PE TimeDateStamp+CheckSum (три
  exe/связки), префикс единицы `l2_u<16 hex>_` (hash пути источника: инструмент на разных стадиях). Выходы модулей и
  `frontend.c`/`driver.c`/`lmxtool.c` сравниваются raw.
- **Времена** (одна машина 16 ГБ, один pipeline): whole quick 24990 (boot43) / 22178 (boot44) с; генерация ≈ 10200–11800
  с, из них шаг frontend 9304–10917 с (lower 1310–1751, core 2714–3618, emit 4275–5042 с), runtime 160–180 с, smoke 40 с,
  tool 695–760 с; `rebuild runtime` 234 с, `rebuild tool` 780 с; стадия-копия ≈ 1–2 с; манифест ≈ 90–140 с.
- **Языковые факты среза** (дефекты/памятки): голый `\x` после запятой склеивается с предыдущим актуалом
  (BARE-DEREF-ACTUAL-MERGED; в порту — `p[0]\f`, cast-формы); WIP-инструменты Codex были непереводимы (P0 tail-cutters
  `---/end/return/until`, языковые слова как имена: `end`→`end_at`, `chain_table`); имя порта может совпасть с экспортом
  ядра (`lm_compiler_use_note` → `…_lexical`); заголовок машинного модуля при `--header` несёт только объявления — guard
  `os:` принадлежит телу; актуалы вызова C хранятся в лексическом порядке.
- **Среда.** `build2/` в `.gitignore`; `C:/Nyasha_Planet/LMX/build` не читать; `buold_temp` — старые зависимости; GCC
  `C:/Qt/Tools/mingw1310_64/bin/gcc.exe` (`920A4FC6…`), `timeout`/`sha256sum` из `C:/Git/usr/bin/` (hash-и в pins).
  Свободной virtual memory при запусках было 4.2–4.5 ГБ; физической ≈ 8 ГБ.

### Результаты агентов перед передачей

Собственных субагентов у fable_pc перед передачей не было; завершились агенты запущенного автором `/code-review` (max, по
коммиту `73e53a32` — абзац поправки чек-листа — и untracked файлам рабочего дерева; 15 находок, ни один файл агентами не
менялся). Разбор fable_pc — только ниже; ничего из кода не правилось.

- **Исправлено при передаче в `next_core_tasks_v3_checklist.md`** (абзац 2026-10-29, с датой; история не переписана):
  ссылка на манифест candidate43 (он лежит в `fix238-20261027/source-candidate43.raw.sha256`, не под `records/`);
  «инструмент» убран из корней, печатаемых L3 — `lmxtool.lm1` переводит фронтенд из `tools/lmxtool.lm2` (`bld_self` →
  `bld_program_k`); счёт «12 decl-файлов + 36 ядра» заменён на виды `decl_write` 0–56 (включая `lmx_thread_state`,
  `lmx_walk`, `lmx_walk_state_decl`, `libc_abi.lm1`, state/scratch-файлы backend/frontend); утверждение о трёх PE-парах
  boot45 под маской — измерено 2026-10-29 13:30 UTC (все три равны под маской, raw различны; witness
  `cold-candidate45-boot45/boot45-pe-mask-20261029.txt`); добавлено, что источники кандидатов не опубликованы в tracked
  tree; строка 29 обновлена результатом full45 и передачей; заголовок файла называет текущего writer/build; ячейки
  S8.4/S8.5 таблицы «Не сделано» получили датированную поправку (reviewer: present-tense ячейки устарели против правила
  самого чек-листа «устаревшую текущую отметку заменять»).
- **Для решения Codex (не правилось):**
  1. `dev/l2src_sandbox/l2trans.lm1:31396–31413` (fix209 `common-c-address.patch`): адрес opaque C-символа вида kind 9 —
     второе представление рядом с kind 6 + descriptor 1; понимает только native emitter; walked (не machine) метод с
     `@ c.NAME` падает в `l2_rw_refuse(0, "an address without a retained declared place")` с node 0 → отказ с
     фиктивной позицией `1:1` (`tests/l2/native_closure_values.lm2:193`). Общее исправление — одна ветвь C-binding в
     `l2_address_root` (kind 6, descriptor 1, text = символ).
  2. `l2trans.lm1:31404`: kind-9 дверь решает «известен ли C-символ как вызываемый» через `lm_compiler_predef_has_function`
     — полный обход всех `prototype:` блоков транзитивного predef-замыкания на каждый `(@ c.NAME)` в каждом из ≥ 5
     проходов, без memo (`l2_frontend_types.lm2:394–462`); для данных-символов ответ всегда «нет» после полного обхода
     (`l2_frontend_coords.lm2`: 344 таких span-ов). Совпадает с пунктом «predef name-set» документа об ускорении.
  3. `dev/l2src_sandbox/lmx_thread.lm2:878/888`: `lmx_stop_request` пишет `message\running: 0` до публикации
     `close_deadline`; дорожка ребёнка читает deadline только после `running = 0` → может прочитать 0 (подтверждено
     верификатором; унаследовано от L1 `lmx_thread.lm1:844/854`; низкая серьёзность — эффективные границы те же).
     Предложение: публиковать deadline до сброса `running`.
  4. `dev/l2src_sandbox/lmx_walk_values.lm2:2413` (`lmx_walk_shape_min`, перенесён fix217): 43 из 57 ops перечислены,
     остальные 14 получают `1U` — обещание «кадр проверен до вычисления операндов» для EXPECT_INT/ADMIT_AS/PAD держится
     только проверками их обработчиков; EXPECT_INT на коротком кадре молча даёт int 0 (plausible, кадры транслятора
     всегда полные).
  5. Untracked `steps/witnesses/fix208/209/210/217-20261025/*` (WIP Codex): дублируют закоммиченные записи
     (`fix208 lmx_reparent.lm2.patch` = `fix210`, и т. д.), не соответствуют живому ABI (`lmx_qualify_tree_preflight_full`
     9 аргументов против 8 живых; формал `roles` в `values.from216.patch`). Reviewer: оставить на диске, не коммитить,
     отметить в `fix210/notes.md` — это чужой WIP, fable_pc его не трогал.
  6. Untracked `steps/fable_consumer_suitability_review_20261026.md` (Codex): §7.3 п.5 — `lib_m_take (unary: f)` без вызова
     даёт отсутствие reception, и общий fallback (interface = 1, uses = 0) отвергает `seven` (`() int`) против `unary (int: a)
     int` → ломает `tests/l2/lib/lib_owner.lm2:116/176–179`; §7.3 п.2/§5 — слот 2 записи ARG (`fallback`) пишется только
     для скрытых входов `pi >= arity`, умолчания формалов помечены OPEN (`lmx_implements.lm2:1196–1199`), так что ветвь
     «умолчание» мертва.
  7. Чек-лист: таблица «Не сделано» S8.4/S8.5 — датированная поправка внесена (выше), полная перепись ячеек — Codex;
     коммит `73e53a32` не записал результат проверок READ.ME:33 (`check_docs`, `git diff --check`) — для коммита передачи
     результат записан в абзаце «Срез238».
  8. Отвергнуто верификацией (не дефекты): изменение stop-семантики Thread `lmx_thread.lm2:668`, null `pool`
     `lmx_reparent.lm2:251`, дедупликация accessor-identity в reparent, ослабленный тест `lmx_thread_reparent_operand`,
     разбиение предиката os-ветки в `lm_compiler_m_machine`. Вне cap: двойная копия staged forest в
     `lmx_reparent_prepare:1100` (намеренный dry-run), квадратичная регистрация implements в `lmx_walk_capture:3419`,
     повторные сканы `lmx_reparent_profile_root`, неиспользуемые локалы `view_p`/`stride`/`value_p`, лишний `---`
     `lmx_thread.lm2:746`, дубль `cycle_reading`, null ARG ordinal `lmx_walk_values.lm2:2470`, устаревшие сгенерированные
     копии заголовков в `dev/l2src_sandbox` (`lmx_graph_copy_owned.h.lm1:151` ещё с `roles`).
  Коммиты `426cd4d4` и `262ef4ba` (full45, candidate46) в review не входили.

### Остановка fable_pc

- Остановка по указанию автора 2026-10-29 (≈ 13:40 UTC): «останавливай всё и передавай работу to codex потому что у тебя
  квоты не хватит на два часа» — до конца fe46.
- Мои агенты и наблюдатели: `/code-review` автора завершён (результаты выше); мой Monitor на fe46 остановлен; других
  субагентов нет.
- Процессы на момент остановки: отделённые pwsh launcher-а и записи fe46, `lmxtool.exe` (boot45 G2, `rebuild frontend`) и
  его `l2trans.exe` — **живые, не тронуты**; иных gcc/cc1/l1trans/l2trans/lmxtool-tool нет (снимок `tasklist` — в абзаце
  «Срез238» ledger-а).
- Git: коммит этой передачи запушен в `main` (SHA — в сообщении Codex и в абзаце «Срез238»); tracked tree чист; чужие
  untracked перечислены выше.
- Сообщение Codex через `lmx_uds`: `FABLE-CODEX-HANDOFF-20261029T134500Z` (копия —
  `steps/witnesses/fix238-20261027/fable-codex-handoff-20261029T134500Z.txt`).
- После отправки fable_pc ничего не запускает и не пишет; возвращается только по поручению автора.

## Архив: передача работы Codex (Opus, 2026-10-24)

Передача по прямому поручению автора от **2026-10-24** (сессия Opus): «после текущего шага напиши to_codex.md
инструкцию по передаче дел, скажи to codex что передаешь ему работу и останавливайся». Текущий шаг — срез 194 —
опубликован: Verified194 `03c5a3ee`, запись его SHA `bc3edf80`. После него Opus остановлен (§2). **Codex — следующий
единственный writer/build.** Opus больше не пишет, не собирает и не ревьюит; к работе возвращается только по поручению
автора. Этот файл заменяет передачу fable_pc от 2026-10-19 (`git show 8e982196:to_codex.md`).

### 1. Как работать

**Цель и поручения автора.**
- Поручение автора (`CODEX-AUTHOR-CORE-CONTINUE-20261024T091641Z`): «Пусть Opus продолжает перенос оставшегося ядра на
  L3 + L2 небольшими шагами через короткий bootstrap, не ожидая ревью. Все вопросы — тебе. Не увлекайтесь тестами:
  цель — работающая самосборка». Теперь эту работу ведёт Codex.
- Порядок (`CODEX-OPUS-ROUTE185-20261024T085140Z`): над перенесённым слоем хранения — значения и граф, затем
  copy/merge/call, mail/Thread и walker (план §8).
- Оба транслятора пишутся на L3 ([LMX_blog/2026-10-24.md](LMX_blog/2026-10-24.md)): «Транслятор написанный на L3 (L2 в
  этой  конкретно задаче избыточен) печатает L1 строки сгенерированные из L2-L3 файла, потом второй транслятор, тоже
  написанный на L3, печатает Си-строки сгенерированные из L1 файла».
- Объявления арены и пулов генерирует код L3 рецепта строками L1, без нового механизма в L2
  (`CODEX-AUTHOR-L3-DECLARATIONS-20261024T054617Z`). Тем же путём, по решениям Codex
  (`CODEX-OPUS-HEADER-SCOPE184-20261024T074034Z`, маршруты 189/193/194), пишутся остальные заголовки ядра. Рукописные
  копии удаляются со стадии до генерации и запасным входом не служат (`CODEX-AUTHOR-L3-HEADER-REVIEW-20261024T062211Z`).
- `const char *` — существующие формы автора (`CODEX-AUTHOR-CONST-FORMS-20261024-A`). Среди формалов — со скобками,
  по `CODEX-OPUS-ROUTE194-AND-CONST-GROUP-20261024-A`: «Используй существующую скобочную форму const: (@: text char)
  (либо эквивалентную const: (text: @: char)) среди формалов». Отказ без скобок измерен в срезе 193
  (`steps/witnesses/fix193-20261024/const/`).

**Тесты и честность.**
- Приоритет автора 2026-10-23 (`to_opus.md` §1): работающий проект и самосборка; широкие проверки — после неё.
  Минимальный сквозной результат текущего изменения достаточен.
- Это не разрешает выдавать RED за PASS, прятать известный RED/UNSUPPORTED или называть его ожидаемым отказом, менять
  норму ради удобства. Каждая пропущенная широкая проверка — долг LATER (§3).
- Новых тестов и служебных программ на L1/C/Python/PowerShell не писать и не прятать прежний runner в shell или
  строку (автор 2026-10-22, `to_opus.md` §2). Существующие поддерживаемые тесты и скрипты переносятся на L2/L3 без
  запасного маршрута к старым (`CODEX-AUTHOR-L2L3-NO-FALLBACK-20261022T223831Z`, S8.5).
- Проверки — командами `lmxtool`, программами L2 и текстовыми командами (diff, sed, perl, командные файлы gdb).

**Решения и вопросы.**
- Opus задавал все вопросы проекта Codex. Теперь их решает Codex сам; ревью постфактум нет, пока автор его не
  назначит.
- Если две утверждённые нормы противоречат друг другу: минимальная программа, обе нормы, измеренное поведение — вопрос
  автору в `LMX_blog/q/current/`. Останавливается только зависимый срез. Исключений по имени, типу, форме или месту в
  трансляторе нет (READ.ME, `L2_L3_CODING_INSTRUCTION.md`).
- Пауза goal Codex и напоминания `lmx-goal` — решение автора. Codex её не снимает
  (`CODEX-OPUS-REVIEW194-20261024-03C5A3EE`).

**Что читать.**
- По порядку: [AGENTS.md](AGENTS.md) → [READ.ME](READ.ME) → верх [steps/current.md](steps/current.md) → план
  [v3](next_core_tasks_v3.md) §§0/3/8/8a → [L2_L3_CODING_INSTRUCTION.md](L2_L3_CODING_INSTRUCTION.md) → L2 §17/§20/§21.
- Из [`to_opus.md`](to_opus.md) (передача 2026-10-22) в силе:
  - §1 — приоритет 2026-10-23, граница честности, коммиты в main без разрешения, правило прерванных процессов;
  - пункты-поручения автора §2 (строки 27–45): обходчик по живому дереву, `os` через общий конвейер без native-подмены
    и без позднего `#ifdef`, R169-1 (одно закрытое разрешение callee), общий допуск сигнатур, имена C;
  - остаток §5 и правила ресурсов и публикации §6.

  Точка старта §2 (168/169), §3–§4, маршрут вопросов через lmx_uds и фразы «Codex остановлен / консультант» — история.
- Цитаты автора: в `LMX_blog/` только технические ответы автора, дословно, с датой и источником вне цитаты
  (AGENTS.md, READ.ME); организационное — в `steps/`.
- Нормы правятся в первичных источниках, генерируемые документы руками не правятся: `provenance/semantics-book.md` →
  `python tools/build_semantics.py`, `provenance/grammar.json` → `python tools/build_docs.py`. Весь репозиторий — LF.

### 2. Точная точка старта

- **Репозиторий.** `C:\Nyasha_Planet\LMX`, ветка `main`: Verified194 `03c5a3ee`, запись `bc3edf80`, затем коммит этой
  передачи. Всё запушено, `origin/main` совпадает.
- **Чужие файлы.** Tracked tree чист; два чужих untracked: корневой `l2_driver_launch.err` и
  `steps/witnesses/used-scope-20261020/reference-producer117.patch`.
  - Первый basename не читать, не хешировать, не копировать и не стейджить нигде; в списках и циклах исключать
    (`ls -I`, `tar --exclude`, `diff --exclude`, `find ! -name`). **Драйвер каждой программы L2, `lmxtool` тоже,
    создаёт или усекает этот файл в своём рабочем каталоге** (`fopen("l2_driver_launch.err", "w+b")`,
    `src/l2_eternal_driver.lm1:2727`). Поэтому любую команду инструмента запускать из нового пустого каталога
    `runs/<label>`, никогда из корня репозитория, корня стадии или `stage/src`.
  - Второй файл не трогать и не коммитить. Не применять `git add .`, reset/clean и переписывание истории.
- **Где живые исходники.** Перенесённые `.lm2`, их сгенерированные `.lm1` и исходник транслятора есть только в цепочке
  стадий `build2/opus_fix194` ← `opus_fix193` ← …. Репозиторий `src/` не хранит: в нём `tools/l2`, `tests/l2` и пакеты
  срезов с создающими и `-U0` патчами. `l2src/` и `dev/l2src_sandbox/` репозитория — старые снимки с другими байтами,
  не входы сборки. Каталоги стадий — и живой исходник, и закреплённые манифестами свидетельства: их не удалять, не
  переименовывать, не переписывать; новая стадия копирует только входы. Перенесённые `.lm2` в `l2src/` и
  `dev/l2src_sandbox/` не добавлять.
- **Рабочий инструмент** — G2 среза 194: `build2/opus_fix194/boot-quick-01/lmxtool.exe`. Его фронтенд —
  `build2/opus_fix194/boot-quick-01/frontend/l2trans.exe`, runtime — каталог `build2/opus_fix194/boot-quick-01/runtime`
  (`driver.o`, `driver-observe.o`).
- **Стадия** `build2/opus_fix194`, входы — `src`, `headers`, `tests`, `tools`. Исходник транслятора
  `src/l2src/l2trans.lm1` — `D8F10E37…` (не менялся с Verified192). Рецепт `tools/l2/build.lm2` — `841AC4A5…`, его
  стадийная копия `tools/build.lm2` та же.
- **Остановка Opus.** Сборок и процессов Opus нет. Цепочка 194 (runtime, семя, bootstrap) и проверки завершились,
  сторож памяти вышел сам. В 16:38 `Get-Process gcc, cc1, cc1plus, as, ld, l1trans, l2trans, lmxtool, lmxtool-tool, gdb
  -ErrorAction SilentlyContinue` пуст. Вспомогательные агенты Opus — четыре read-only проверяющих этой передачи —
  завершились, их выводы учтены здесь; других агентов и фоновых задач нет. Срез 195 и новые сборки Opus не начинал.
  Перед своим запуском проверь снова той же командой: пустой вывод — живых сборок нет.

### 3. Цель, что перенесено и что осталось

**Готово, когда** (план §8, READ.ME) в поддерживаемых исходниках ядра, парсера, трансляторов и обычной цепочки сборки и
проверки нет рукописного L1/C/Python/PowerShell:
- S8.3 — замыкание ядра runtime;
- S8.4 — парсер и оба транслятора на L3;
- S8.5 — сборка и проверки на L2/L3, включая генераторы документов на Python, `check_docs.py` и старые PS/Python
  gates, без запасного маршрута;
- S8.6 — настоящие самозамещения G0→G1→G2, которые строят, проверяют и заменяют.

G1/G2 нынешнего bootstrap — не S8.6. Короткий и полный режимы сохраняются и после переноса.

**Перенесено.** Единица трансляции runtime — `src/l2_eternal_driver.lm1` → `driver.c`; её замыкание по `predef` — 35
модулей ядра в `src/l2src`. Перенесены 14 — машинные модули L2 (`l2trans --library --machine …`). Их L1 пишет рецепт
(`bld_kernel_l2`) на стадии на месте рукописного:

| Модуль | Срез | Заголовок |
| --- | --- | --- |
| `lmx_list_owned` | 178 | `--header` |
| `lmx_range` | 180 | нет: прототипы в `lmx_arena.h.lm1` |
| `lmx_pool` | 181 | `--header` |
| `lmx_arena_blocks` | 182 | нет: `lmx_arena_blocks.h.lm1` пишет L3 |
| `lmx_arena` | 183 | нет: `lmx_arena.h.lm1` пишет L3 |
| `lmx_chars` | 186 | `--header` |
| `lmx_chars_owned`, `lmx_array_ref_owned` | 187 | `--header` |
| `lmx_arena_refs`, `lmx_array_owned` | 188 | `--header` |
| `lmx_scratch` | 189 | нет: `lmx_scratch.h.lm1` пишет L3 |
| `lmx_value_owned` | 191 | `--header` |
| `lmx_source_names` | 193 | нет: `lmx_source_names.h.lm1` пишет L3 |
| `lmx_gc_graph` | 194 | нет: `lmx_gc.h.lm1` пишет L3 |

Код L3 рецепта (`decls_write_all`, первый шаг `bld_kernel_l2`) пишет шесть заголовков; номер — вид `decl_write`:

| Вид | Заголовок | Срез |
| --- | --- | --- |
| 0 | `lmx.h.lm1` | 185 |
| 1 | `lmx_arena_blocks.h.lm1` | 185 |
| 2 | `lmx_arena.h.lm1` | 185 |
| 3 | `lmx_scratch.h.lm1` | 189 |
| 4 | `lmx_source_names.h.lm1` | 193 |
| 5 | `lmx_gc.h.lm1` | 194 |

Остальные `.h.lm1` перенесённых модулей пишет `--header` их перевода. Только транслятор меняли срезы 179, 184, 190 и
192, только объявления — 185. Транслятор менялся и в срезах с модулями: 178, 180, 181, 182, 191 (их
`steps/witnesses/fixNNN-*/l2trans.lm1.patch`).

**Осталось на L1.**
- 21 модуль:
  - copy/merge/call: `lmx_implements`, `lmx_graph_copy_owned`, `lmx_merge_owned`, `lmx_call`;
  - ещё 17: `lmx_thread`, `lmx_post`, `lmx_turn`, `lmx_schedule`, `lmx_service`, `lmx_manager`, `lmx_manager_running`,
    `lmx_manager_running_lane`, `lmx_child`, `lmx_orphan`, `lmx_reparent`, `lmx_settle`, `lmx_process_deadline`,
    `lmx_clock`, `lmx_gc` (собиратель Thread), `lmx_root`, `lmx_walk`.
- Рукописный L1-модуль `src/l1src/libc_abi.lm1` и драйвер `src/l2_eternal_driver.lm1`.
- 24 рукописных заголовка:

  ```text
  lmx_call  lmx_child  lmx_clock  lmx_graph_copy_owned  lmx_implements  lmx_implements_resolve  lmx_manager
  lmx_manager_running  lmx_merge_owned  lmx_message  lmx_orphan  lmx_post  lmx_primitive  lmx_process_deadline
  lmx_reparent  lmx_root  lmx_schedule  lmx_service  lmx_settle  lmx_thread  lmx_turn  lmx_value  lmx_walk
  lmx_win32_api
  ```

  У пяти из них нет кодового модуля: `lmx_implements_resolve`, `lmx_message`, `lmx_primitive`, `lmx_value`,
  `lmx_win32_api`. Их уберёт не перенос модуля, а свой писатель `decl_X` в `decls_write_all`, как `lmx.h.lm1` в 185.
- Замыкание трансляторов: `src/l2src/l2trans.lm1`, `src/l1src/l1trans.lm1`, парсер P0 `src/l1src/parser.lm1` и
  остальные файлы `src/l1src`.

**Долг LATER** (честно не запущено; не готовность).
- В последних срезах не запускались kernel gate, gate, replay корпуса и мутанты.
- `bootstrap full` реализован, но ни разу не запускался.
- Доходит ли smoke до модулей 187, 193 и 194, не измерено.
- Строки gate LIBRARY-ROWS-OLD-PROFILE устарели.

### 4. Следующий шаг: срез 195 — каждый файл predef разбирается один раз (черновик, Opus его не начинал)

**Дефект** PREDEF-HEADER-REPARSED-PER-QUERY (`steps/defects.md`). Запросы транслятора к файлу predef (заголовку или
кодовому модулю) каждый раз заново разбирают файл и разрушают документ: снимок программы хранит только байты. Таких
запросов четыре — `l2_predef_file_has_type`, `_define`, `_has_function`, `_result_ty`; они идут и по вложенным
`predef`. Перевод `lmx_gc_graph.lm2` командой рецепта занимает 300 с (`gen-194-06`); в bootstrap 194 шаг модуля —
295 с. Все три выборки gdb — в `lm_p0_parse_bytes` под `l2_snap_parse`. С ростом перенесённых модулей цена растёт.

**Черновик Opus** — приложение A. Это `-U0` к `src/l2src/l2trans.lm1`, 24 куска. **Не транслирован и не собран.**
- База: `d8f10e375087296766a7bc1562a94d48d7e4dd1969ff94d5c10667a687844733`.
- Результат `patch -p1` с корня стадии: `7a1442f9bb7efcaf1b9a7c31675fc620197da5b28ecdccd5c45e8d5381490a77`.
- Рядом с байтами снимка — массив документов `l2_snap_doc`, растёт вместе с остальными в `l2_snap_bytes`.
- `l2_snap_document(path)` разбирает файл при первом запросе и дальше отдаёт тот же документ.
- Четыре читателя берут его и больше не разрушают; `l2_snap_free` разрушает документы вместе с байтами.
- Неудачный разбор не хранится; его документ теперь разрушается — прежде он утекал.
- Исходник и части по-прежнему разбираются через `l2_snap_parse`: трансляция пишет их деревья.
- Два комментария, которые говорили «документ разрушается здесь» и «разбирается заново», исправлены.

**Почему документ можно делить** (чтение кода; независимая read-only проверка подтвердила по строкам):
- Читатели только читают дерево (`l2_next_active`, `l2_count_active`, `l2_frame_head`, `l2_text_same`, `memcmp`). У
  `_define` есть ещё `l2_array_count_is`, а `l2_cnt_keep` копирует текст.
- `_result_ty` строит из узла заголовка контракт (`l2_ret_type_node` → `l2_contract_new`). Контракт держит указатель на
  атом заголовка в глобальном списке, но через него никто не пишет (`l2_foreign_intern_parts` копирует текст). До патча
  этот указатель после разрушения документа висел; теперь он жив до `l2_snap_free`.
- Документ получают только четыре читателя; вызывающим он не отдаётся. Разбор P0 зависит только от байтов: в
  `parser.lm1` нет переменных модуля.
- Единственный писатель флагов узла (`l2_tables_in`, INACTIVE) ходит по исходнику и частям, не по файлам predef.
- `lm_p0_parse_bytes` копирует байты в арену документа.
- Пиковая память — теперь сумма документов, а не максимум: сотни КБ исходника.

**Прогон.** Изменение только транслятора, поэтому достаточно `bootstrap quick` инструментом G2 среза 194. В 190 и 192
перед ним шёл быстрый `rebuild frontend` (192: 59 с), это по желанию.

```text
cd C:/Nyasha_Planet/LMX/build2 && test ! -e opus_fix195 && mkdir opus_fix195 &&
  tar -C opus_fix194 --exclude=l2_driver_launch.err -cf - src headers tests tools | tar -C opus_fix195 -xf -
mkdir -p opus_fix195/runs/packet
sed -n '/^```diff$/,/^```$/p' C:/Nyasha_Planet/LMX/to_codex.md | sed '1d;$d' > opus_fix195/runs/packet/appendix-a.patch
(cwd build2/opus_fix195) sha256sum src/l2src/l2trans.lm1        -> d8f10e37… (база)
(cwd build2/opus_fix195) patch -p1 < runs/packet/appendix-a.patch; sha256sum src/l2src/l2trans.lm1   -> 7a1442f9…
mkdir -p opus_fix195/runs/run-boot-01        (cwd этот пустой каталог)
C:/Nyasha_Planet/LMX/build2/opus_fix194/boot-quick-01/lmxtool.exe 0 entry 0 -- bootstrap quick C:/Nyasha_Planet/LMX
  C:/Nyasha_Planet/LMX/build2/opus_fix195 C:/Nyasha_Planet/LMX/buold_temp boot-quick-01
  C:/Nyasha_Planet/LMX/build2/opus_fix195/tests/smoke.tsv
```

Дельта пакета — по соглашению fix190/fix192, с метками стадий: (cwd `build2`) `diff -U0 --label
stage194/src/l2src/l2trans.lm1 --label stage195/src/l2src/l2trans.lm1 opus_fix194/src/l2src/l2trans.lm1
opus_fix195/src/l2src/l2trans.lm1 > opus_fix195/runs/packet/l2trans.lm1.patch`. Replay — как
`steps/witnesses/fix190-20261024/u0-same.command`: копия базы, `patch -p0` на явный файл, затем `same`. Конец прогона —
`boot-quick-01/bootstrap.txt` и строка `exit=` в `.out` (обёртка — §5.4).

**Ожидаемо: скорость меняется, байты прежние.** Проверки — инструментом G2 нового bootstrap, из пустого
`runs/checks-01`, набором по образцу `steps/witnesses/fix190-20261024/checks/commands.txt`.
- `BOOTSTRAP quick 0 failures`. Сам `bootstrap quick` G1 и G2 не сравнивает: `same` их `lmxtool.lm1` и
  `lmxtool.c`, `exe-same` их `lmxtool-tool.exe`.
- `same` трёх файлов `build2/opus_fix194/boot-quick-01/runtime/{driver.c,driver.o,driver-observe.o}` с такими же
  файлами 195.
- Всё, что переписал рецепт, — прежние байты: (cwd `build2`) `diff -rq --exclude=l2_driver_launch.err opus_fix194/src
  opus_fix195/src` даёт только `l2src/l2trans.lm1`, такой же `diff -rq` по `headers` пуст. Модули ядра префикса `l2_u…`
  не несут.
- L1/C инструмента отличаются от G2 среза 194 только префиксом единицы: (cwd `build2`)
  `E='s/l2_u[0-9A-F]\{16\}_/l2_uHASH_/g'`; `diff <(sed "$E" opus_fix194/boot-quick-01/tool-g2/lmxtool.lm1) <(sed "$E"
  opus_fix195/boot-quick-01/tool-g2/lmxtool.lm1)` пуст, так же для `lmxtool.c` (образец —
  `steps/witnesses/fix192-20261024/checks/normalized.command`).
- Время: после bootstrap, без других прогонов рядом, попытка `runs/gen-195-01` — команда `gen-194-06` с новым
  фронтендом `opus_fix195/boot-quick-01/frontend/l2trans.exe`, исходником и выходом новой стадии. Ждать exit 0 и
  `same` с `opus_fix194/runs/gen-194-06/lmx_gc_graph.lm1`. В 194 — 300 с; в bootstrap шаг модуля (от создания
  `boot-quick-01/runtime/lmx_gc_graph.L2.log` до публикации `src/l2src/lmx_gc_graph.lm1`) — 295 с.
- Пакет — по образцу fix190/fix192 (только транслятор): `l2trans.lm1.patch`, `u0-same.*`, `bootstrap-quick-01.*`,
  `chain-memory.*`, `gen/` (замер), `checks/`, `trace/runtime-record.txt` (вся запись), `manifest/`,
  `evidence-195.list|.sha256`. Документы: строка в разделе «Реализовано в указанном объёме» чек-листа (как 192),
  раздел E30, пункт closure-map без изменения счёта; дефект — «…, FIXED Verified195» и абзац «Исправлено в срезе 195 …»;
  из «Открыты …» его убрать.

Если какой-то байт изменился, это дефект черновика, а не новая норма. Затем PREDEF-HEADER-REPARSED-PER-QUERY — FIXED.

**Следом** (рекомендация Opus — срез 196, до copy/merge/call) исправить PREDEF-BARE-NESTED-PATH-FROM-CWD. Голый
вложенный путь `predef` разрешать рядом с включающим файлом, как l1trans (`l1_resolve_bare_import`), во всех четырёх
читателях. Без этого переносы упрутся в него: рукописные `lmx_graph_copy_owned.lm1` и `lmx_merge_owned.lm1` пишут
голые `predef` («"lmx_graph_copy_owned.h.lm1" "lmx_walk.h.lm1" …»), `lmx_merge_owned.h.lm1` — голый
`"lmx_graph_copy_owned.h.lm1"`. Иначе — в каждом `.lm2` все `predef` писать от `stage/src` (`l2src/…`, `l1src/…`), а
заголовок каждого типа двери C, до которого доходят голым вложенным `predef`, объявлять прямо. Прямой `predef`
заголовка списка блоков в `lmx_gc_graph.lm2` законен и может остаться.

**Открытые вопросы переносов copy/merge/call** (решает Codex).
- Какой модуль первым: `lmx_implements`, `lmx_graph_copy_owned`, `lmx_merge_owned` или `lmx_call`.
- Экспорты для `--machine` — функции с прототипом в рукописном заголовке (`grep -c '^fn: \|^sub: '` и блок
  `prototype:`): `lmx_implements` 51 из 90, `lmx_graph_copy_owned` 26 из 91, `lmx_merge_owned` 24 из 34, `lmx_call` 20
  из 22. Остальные — свои.
- Режим заголовка: заголовки всех четырёх держат записи и `define`. Похоже на 189/193/194: модуль без `--header`,
  заголовок пишет код L3.
- У `lmx_implements` два рукописных заголовка (`lmx_implements.h.lm1`, `lmx_implements_resolve.h.lm1` — только записи,
  читает только он). Переносить оба в срезе модуля, или оставить один рукописным до отдельного среза, как 180–183 до
  185.
- У `lmx_call` четыре переменные модуля (`lmx_call_walk_fn`, `lmx_call_walk_status_mode`, `lmx_call_prim_walk_fn`,
  `lmx_call_walk_fail_status_g`) — общие для процесса крючки. Ни у одного перенесённого модуля хранилища уровня модуля
  нет, а прямой машинный вход автора исключает скрытый singleton.

### 5. Рабочий цикл среза (как его вёл Opus)

1. **Новая стадия** — из предыдущей, командой `tar` из §4. Каждая попытка — новый label. Инструмент сам отказывается
   писать в существующий: «exists: a new label for every attempt».
2. **Модуль.** `src/l2src/M.lm2` — перенос рукописного `M.lm1`: те же функции в том же порядке. Переводится командой
   рецепта в новый каталог `runs/gen-NNN-0K`; запуск из этого каталога, имена файлов абсолютные:

   ```text
   FE --library --machine E1 ... --machine En [--header STAGE/src/l2src/M.h.lm1] STAGE/src/l2src/M.lm2
      C:/Nyasha_Planet/LMX/buold_temp/l2_harness/codex_consumer49_full_01/src/convert.lm2
      C:/Nyasha_Planet/LMX/buold_temp/l2_harness/codex_consumer49_full_01/src/primitive.lm2 OUT/M.lm1
   ```

   FE — фронтенд предыдущего G2. Удачный L1 копируется на стадию в `src/l2src/M.lm1`: `rebuild runtime` предыдущим
   инструментом нового модуля ещё не переводит.
3. **Рецепт.** Модуль добавляется в `bld_kernel_l2`: имена экспортов и `bld_machine_module(…, header)`. Новый
   заголовок L3 — это `decl_X`, новый вид в `decl_write` и в `decls_write_all`.
   - Писатель `decl_X` — куски `c.fputs`, разрезанные по концам строк и экранированные `\\`, `\"`, `\n`. У новых
     писателей (`decl_source_names`, `decl_gc`) куски не длиннее 900 символов; у старых — до 2 055.
   - Куски Opus резал временным неопубликованным помощником на Python в своей сессии и проверял обратным
     декодированием. Надёжнее: команда, сохранённая текстом, или программа L2, затем `same` против байтов рукописного
     заголовка.
   - **Порядок `decls_write_all`.** Он сначала удаляет все свои заголовки и их C-заголовки, затем пишет каждый и сразу
     переводит его l1trans. Поэтому новый заголовок L3 ставится раньше всех заголовков L3, которые читают его через
     `predef` — прямо или через рукописный: `lmx_scratch.h.lm1` (вид 3) читает `lmx_implements.h.lm1`, а
     `lmx_gc.h.lm1` (вид 5) — `lmx_thread.h.lm1`, который читает `lmx_call.h.lm1`. Добавленный в конец, такой
     заголовок сломает шаг C-заголовка вида 3 или 5. Тогда виды перенумеровать (и таблицу §3) или вести порядок
     отдельно.
   - Рецепт правится в репозитории и копируется на стадию `tools/build.lm2`.
4. **Цепочка при изменении рецепта** (команды среза 194; `T0 = build2/opus_fix193/boot-quick-01/lmxtool.exe`, FE0 —
   его фронтенд; `REPO = C:/Nyasha_Planet/LMX`, `BASE = C:/Nyasha_Planet/LMX/buold_temp`; каждый шаг — из своего
   пустого `runs/run-*`). В следующем срезе `T0`, `FE0` — G2 и фронтенд предыдущего среза (после 195 —
   `build2/opus_fix195/boot-quick-01/lmxtool.exe` и `…/frontend/l2trans.exe`):

   ```text
   T0 0 entry 0 -- rebuild runtime REPO STAGE BASE FE0 none rt-01 STAGE/tests/smoke.tsv         (194: 837 s)
   T0 0 entry 0 -- rebuild tool REPO STAGE BASE FE0 STAGE/rt-01 tool-01 STAGE/tests/smoke.tsv  (194: 605 s)
   STAGE/tool-01/lmxtool-tool.exe 0 entry 0 -- bootstrap quick REPO STAGE BASE boot-quick-01 STAGE/tests/smoke.tsv
   ```

   `tool-01` — семя G0 с новым рецептом. Bootstrap этим семенем делает по порядку:
   - строит фронтенд из L1 (`bin/l1trans.exe`);
   - строит runtime: пишет все заголовки L3 и переводит все модули;
   - прогоняет smoke;
   - строит G1; G1 строит G2.

   Рабочим `label/lmxtool.exe` становится сначала G1, затем G2. Вывод инструмента в файл виден только после конца:
   следить за каталогом label. Команды и выводы лежат в корне стадии (`STAGE/rebuild-runtime-01.command|.out`,
   `rebuild-tool-01.*`, `bootstrap-quick-01.*`); обёртка Opus (bash), по шагу на label:

   ```text
   run() { mkdir -p $B/runs/run-$1 && cd $B/runs/run-$1 && s=$(date +%s) && bash $B/$2.command > $B/$2.out 2>&1;
     x=$?; echo "elapsed $(( $(date +%s) - s ))s" >> $B/$2.out; echo "exit=$x" >> $B/$2.out; return $x; }
   run rt-01 rebuild-runtime-01 && run tool-01 rebuild-tool-01 && run boot-01 bootstrap-quick-01
   ```
5. **Сторож памяти** — фоновый цикл PowerShell рядом с цепочкой, текст —
   `steps/witnesses/fix194-20261024/chain-memory.command`.
   - Каждые 3 с он пишет в `runs/chain-memory.log` свободный commit и память cc1.
   - При свободном commit ниже 0.8 GiB он останавливает **все** cc1 машины.
   - Выходит через 10 с после конца `lmxtool`.

   Путь `$log` указывает на стадию 194, предел цикла — 3000 × 3 с, около 2.5 ч: для новой цепочки их поправить.
   Первой строкой лога Opus писал `--- chain <labels>`. Это вспомогательный наблюдатель оператора, не шаг сборки:
   файлом `.ps1` в репозитории не хранится; запуск отдельным процессом Windows PowerShell 5.1 до цепочки (например,
   `Start-Process powershell.exe -WindowStyle Hidden -ArgumentList '-NoProfile','-Command',$text`).
6. **Проверки** — `T 0 entry 0 -- same A B` и `exe-same A B`, из своего пустого `runs/checks-NN`. Набор как в
   `steps/witnesses/fix194-20261024/checks/commands.txt`:
   - L1 и C у `tool-01`, G1 и G2; `exe-same` G1 и G2;
   - runtime bootstrap равен `rt-01`;
   - модуль равен своей попытке `gen`;
   - заголовок и его C-заголовок равны рукописным байтам.

   C runtime сравнивается с предыдущим срезом: изменение должно ограничиваться модулем (`runtime-diff.command`).
7. **Пакет** — `steps/witnesses/fixNNN-20261024/`, образец — fix193 и fix194.
   - `notes.md`; создающий патч модуля (`diff -U0 --label /dev/null --label stageNNN/src/l2src/M.lm2 /dev/null M.lm2`).
   - `u0-same.*`: GNU patch в пустую стадию, затем `same`.
   - `gen/`, `checks/`, `trace/runtime-record.txt` (запись runtime bootstrap: генератор и перевод модуля),
     `chain-memory.*`, команды и выводы цепочки.
   - `manifest/`: `T 0 entry 0 -- manifest LIST C:/Nyasha_Planet/LMX OUT`, затем `sha256sum -c`.

   Список evidence — явные пути, без glob каталога прогона. Манифест хеширует оригиналы в `build2`. Копии в пакете —
   без CR, без хвостовых пробелов и пустых строк в конце; выводы инструмента их несут. Opus нормализовал так:

   ```text
   awk '{ sub(/\r$/, ""); sub(/[ \t]+$/, ""); lines[NR] = $0 } END { n = NR; while (n > 0 && lines[n] == "") n--;
     for (i = 1; i <= n; i++) print lines[i] }' IN > OUT
   ```
8. **Документы среза:**
   - `steps/current.md` — абзац «СрезNNN …» (RU), при изменении дефектов — абзац «Открыты …», и блок
     «**VerifiedNNN (`sha`) — …**» (EN) над предыдущим;
   - чек-лист — строка основания, строка S8.3 со счётом «перенесены N», раздел ENN;
   - `steps/closure-map.md` — пункт и счёт «N из 35»;
   - `steps/native-selfbuild-20260930.md` — фраза в пункте 4 списка «Concrete §8 route after clean-kernel»;
   - `steps/defects.md`.

   Затем `git add` явных путей и только после него `python tools/check_docs.py` (концы строк он проверяет по индексу),
   `git diff --check`, `git diff --cached --check`.
9. **Коммит:**
   - пути — из `git status --short`, только явные; после коммита ни одного изменённого tracked файла;
   - перед push: `git fetch`, `git log origin/main..HEAD` (только свои коммиты) и `git log HEAD..origin/main`
     (пусто). Сессии-соседи коммитят в основной checkout: чужой коммит однажды уехал с push (Verified177). Если что-то
     не так — не пушить и не делать merge или force, а установить, чей коммит и какие пути он трогает;
   - без веток, worktree и PR; автор читает сам `C:\Nyasha_Planet\LMX`;
   - без glob-удалений в репозитории: однажды `rm -f parser_*.lm1` в `dev/l2src_sandbox` удалил tracked заголовки;
     удалять только названные пути и сразу смотреть `git status`;
   - после push — отдельный коммит «Record the VerifiedNNN commit in the current state and checklist», вписывающий SHA
     («…, checklist and defects», если SHA вписывается и в дефект, как c1ec46e2).

### 6. Подводные камни переноса (измерено в срезах 178–194)

- **Режим заголовка модуля.**
  - `--header` кладёт в сгенерированный заголовок все `.h.lm1`-predef модуля; predef кодового `.lm1` остаётся в
    модуле (`l2_pd_is_header`).
  - Без `--header` модуль объявляет все свои функции сверху. Так делают модули, чьи прототипы в чужом заголовке
    (`lmx_range` в `lmx_arena.h.lm1`) или в заголовке L3.
  - Перенос прототипов в новый заголовок даёт цикл импорта и меняет replay (срез 180).
- **Порядок функций.** Ядро — одна единица C с `-Werror=implicit-function-declaration`. Функции перенесённого модуля
  объявляет сам l2trans: экспорты — в заголовке, свои — блоком prototype в начале модуля. Поэтому порядок внутри
  `.lm2` для C не важен. Функция без прототипа в заголовке видна только модулям, стоящим в единице после её модуля
  (`lmx_range_keep_chunk`). В рукописном `.lm1` своя функция стоит выше первого вызова.
- **Слова, которые нельзя связать** (`l2_bind_admit`, `l2_head_word`):
  - слова ресиверов: `sendMessage`, `receiveMessage`, `adopt`, `call`, `merge`, `table`, `catch`, `throw`, `throws`,
    `until`, `end`, `sub`, `fm`, `synchronized`, `length`, `cast`;
  - `fn`, `int`, `return`, `if`, `else`, `while`, `for`, `node`;
  - `break`, `continue`, `sizeof`, `const`, `immutable`, `independent`, `implements`, `test`, `post`, `external`,
    `short`, `long`, `float`, `double`, `signed`, `_Bool`;
  - слова единицы: `predef`, `define`, `include`, `profile`, `prototype`, `os`;
  - слова типов: `char`, `size_t`, `void`, `unsigned`, `ulong`.

  Прочие ключевые слова C (`struct`, `static`, `switch`, `typedef`, …) допуск не отвергает. Переименовывать:
  `node` → `block`, `length` → `text_length`.
- **P0:** `;` на одной строке закрывает только внутренний фрейм. Формал-фрейм, за которым идёт другой формал, берётся в
  скобки.
- **Чтения членов C без типа C** (C-DOOR-MEMBER-ACTUAL-UNTYPED).
  - Приводить при использовании: `(cast: (size_t) x\n)`.
  - Адрес члена по значению и его возврат — через типизированный локал: `va: @ x\member`, затем `return: va`.
  - Фактические вызова C хранятся в лексическом порядке; фактический без типа перед фактическим с вызовом
    отвергается. Тогда привести его или вычислить вызов в локал.
- **Указатель на функцию.**
  - Применение `f(v)` — то же дерево, что `f: v`, и всегда вызов. Поэтому локал получает значение только в объявлении:
    `c.LmxArenaBlockDisposer: disposer block\dispose`.
  - Вызов члена отдельным оператором (`block\dispose(block\base, block\n)`) отвергнут «a native value requires one
    complete expression» (`gen-194-04`). Вызов члена в `return:` работает: срез 191, `fnptr.lm2`, проверка 17,
    `return: pool\pointer_write(cell, 0)`. Причина отказа формы оператора не прослежена; это не общий запрет языка.
- **Хранилище** (поведение L1, измерено в ранних срезах): агрегата по значению на уровне модуля нет — писать
  `@: T name 0`. Дверь `c.*` даёт вызовы, типы и константы и хранилища не объявляет.
- **Тип за голым вложенным `predef`** l2trans не находит (PREDEF-BARE-NESTED-PATH-FROM-CWD). Заголовок такого типа
  объявлять прямо: `predef: "l2src/X.h.lm1"`.
- **Сгенерированные копии.**
  - C-заголовки ядра `STAGE/headers/l2src/X.lm1.h` — копии; bootstrap и `rebuild runtime` пересоздают их
    («HEADERS N regenerated»).
  - После изменения транслятора модули ядра надо перегенерировать первыми: они — входы runtime.
- **Инструмент.**
  - Список частей `bld_self` вкомпилирован: новый код рецепта — в существующую часть (`build.lm2`).
  - Сравнение L1/C инструмента между стадиями требует маски префикса `l2_u<16 hex>_`: он хеширует путь исходника.
  - С Verified192 имена C несут имя привязки; сравнение через 192 — после обратной замены
    (`steps/witnesses/fix192-20261024/checks/normalized.command`).
- **Транслятор.** В `l2trans.lm1` функция сначала названа в блоке прототипов. Правку привязывать к определению с
  колонки 0.

### 7. Открытые дефекты

**Открыты по абзацу «Открыты …» в `steps/current.md`** (статусы — `steps/defects.md`):
- MACHINE-STATUS-CHANNEL: решение о C ABI объявленного выхода теперь за Codex;
- PUBLICATION-FAILURE-UNSAID;
- C-DOOR-MEMBER-ACTUAL-UNTYPED;
- остаток C-DOOR-ACTUALS-UNORDERED;
- WALKED-ROOT-C-DOOR-UNSUPPORTED;
- C-DOOR-POINTER-RESULT-INT-OPERAND;
- ARENA-LOOKUPS-LINEAR;
- LIBRARY-ROWS-OLD-PROFILE;
- NAMED-ACTUAL-ADMISSION-NO-SOURCE;
- PREDEF-BARE-NESTED-PATH-FROM-CWD и PREDEF-HEADER-REPARSED-PER-QUERY (новые в 194).

**Кроме того, с линии Opus:** C-DOOR-DEREF-UNLOCATED, остаток GENERATED-CODE-SIZE, R169-1 (чек-лист K08). Более ранние
OPEN/IN WORK в `steps/defects.md` (2026-09-30…2026-10-20) остаются обязательствами. Дефекты, которые вёл Opus,
переходят к Codex.

**Препятствия масштаба** для переноса трансляторов:
- GENERATED-CODE-SIZE: около 122 строк L1 на строку L2; инструмент собирается только при `-O0`.
- ARENA-LOOKUPS-LINEAR: линейный поиск массивов арены на выделение и просмотр таблицы имён источника.
- PREDEF-HEADER-REPARSED-PER-QUERY — до среза 195.

### 8. Ресурсы и запреты

- **Только `build2`.** Корневой `C:\Nyasha_Planet\LMX\build` не читать, не сканировать, не восстанавливать, выходов там
  не создавать.
- **Без рекурсивных обходов.** `build2` и `buold_temp` — сотни ГБ: никаких рекурсивных grep, find, `ls -R`, du от корня
  репозитория или по `build2`. Поиск — `git grep` по tracked файлам или точные пути. `diff -rq` — только по названным
  подкаталогам стадии, с `--exclude=l2_driver_launch.err`.
- **`buold_temp`** — сохранённые зависимости:
  - части `l2_harness/codex_consumer49_full_01/src/convert.lm2` и `primitive.lm2`;
  - каталог включений `codex_header98_source_control_06/includes`;
  - объект `l2_harness/codex_impl56_public_focus_01/gen/l2_libc.o`.
- **Один GCC pipeline, без `-g`.** GCC — `C:/Qt/Tools/mingw1310_64/bin/gcc.exe`, L1 → C — `bin/l1trans.exe`.
  Трансляции, gcc и запуски инструмента не идут рядом с работающей цепочкой.
- **Память.** С Verified184 инструмент при `-O0` собирается в доступной памяти. В цепочке 194 свободный commit в начале
  — 4.05 GiB, при работающем cc1 не ниже 1.93 GiB (193: 1.29 GiB); cc1 держит до ~1.6 GB. Порог «около 5.4 GiB»
  относился к срезам 176–183, когда инструмент не собирался. Цепочку Opus начинал, когда не было других gcc и cc1 и
  свободного commit было около 4 GiB; ниже 0.8 GiB сторож останавливает cc1 — прерванный шаг повторять с новым label.
- **Процессы.** Остановка родительского shell или задачи оставляет gcc, cc1, l1trans, l2trans и lmxtool живыми: найти
  их по имени (`Get-Process`), проверить время старта и остановить по PID. Прерванное не перезапускать вслепую, а
  установить, что завершилось.
- **Длительность** (193/194): `rebuild runtime` 761/837 s, `rebuild tool` 601/605 s, `bootstrap quick` 1 933/2 298 s.

### Приложение A. Черновик среза 195

`-U0` к `src/l2src/l2trans.lm1` (`D8F10E37…` → `7A1442F9…`, 24 куска); с корня стадии — `patch -p1`.

```diff
--- a/src/l2src/l2trans.lm1
+++ b/src/l2src/l2trans.lm1
@@ -1005 +1005,2 @@
-# frees it (l2_snap_free).
+# frees it (l2_snap_free). A predef file's queries only read its tree, so its P0 document is parsed once too
+# (l2_snap_document) and kept beside its bytes (l2_snap_doc; 0 while that file has not been parsed so).
@@ -1008,0 +1010 @@
+@@: LmP0Document l2_snap_doc 0
@@ -2861,0 +2864 @@
+    fn: l2_snap_document (const: @(char path)) @: LmP0Document
@@ -8562 +8565,2 @@
-    if: l2_snap_parse(path, @ document) = 0 && document != 0
+    document: l2_snap_document(path)
+    if: document != 0
@@ -8621 +8624,0 @@
-        lm_p0_document_destroy(document)
@@ -8739 +8742 @@
-# follows). The literal is kept, because this document is destroyed here.  With
+# follows). The literal is kept as a copy (l2_cnt_keep); the document is the snapshot's (l2_snap_document).  With
@@ -8760 +8763,2 @@
-    if: l2_snap_parse(path, @ document) = 0 && document != 0
+    document: l2_snap_document(path)
+    if: document != 0
@@ -8785 +8788,0 @@
-        lm_p0_document_destroy(document)
@@ -9137 +9140,2 @@
-    if: l2_snap_parse(path, @ document) = 0 && document != 0
+    document: l2_snap_document(path)
+    if: document != 0
@@ -9165 +9168,0 @@
-        lm_p0_document_destroy(document)
@@ -9314 +9317,2 @@
-    if: l2_snap_parse(path, @ document) = 0 && document != 0
+    document: l2_snap_document(path)
+    if: document != 0
@@ -9360 +9363,0 @@
-        lm_p0_document_destroy(document)
@@ -11414 +11417 @@
-    # same file l2_is_known already re-parses for the yes/no check) -- a
+    # same file l2_is_known already reads for the yes/no check) -- a
@@ -68908,0 +68912 @@
+    @@: LmP0Document nv
@@ -68929 +68933,2 @@
-        if: np = 0 || nd = 0 || nl = 0
+        nv: (cast: (@@: LmP0Document) l2_xmalloc((cast: (size_t) cap) * c.sizeof(@: LmP0Document)))
+        if: np = 0 || nd = 0 || nl = 0 || nv = 0
@@ -68935,0 +68941,2 @@
+            if: nv != 0
+                l2_xfree((cast: (@: void) nv))
@@ -68942,0 +68950 @@
+            nv[i]: l2_snap_doc[i]
@@ -68950,0 +68959,2 @@
+        if: l2_snap_doc != 0
+            l2_xfree((cast: (@: void) l2_snap_doc))
@@ -68953,0 +68964 @@
+        l2_snap_doc: nv
@@ -68967,0 +68979 @@
+    l2_snap_doc[l2_snap_n]: 0
@@ -68982,0 +68995,26 @@
+# The P0 document of the snapshot's bytes of the file at path, parsed on its first use and then the same document for
+# every later query of the program: a predef file -- a header or a code module -- whose queries only read its tree
+# (l2_predef_file_has_type, _define, _has_function, _result_ty). 0 when the file cannot be read or does not parse; such
+# a parse is not kept. The snapshot owns the document: l2_snap_free destroys it.
+fn: l2_snap_document (const: @(char path)) @: LmP0Document
+    int: i 0
+    size_t: n 0U
+    const: @: char data
+    @: LmP0Document document 0
+    data: l2_snap_bytes(path, @ n)
+    if: data = 0
+        return: 0
+    while: i < l2_snap_n && l2_snap_data[i] != data
+        i: i + 1
+    if: i >= l2_snap_n
+        return: 0
+    if: l2_snap_doc[i] = 0
+        if: lm_p0_parse_bytes(data, n, @ document) != 0 || document = 0
+            if: document != 0
+                lm_p0_document_destroy(document)
+            return: 0
+        ---
+        l2_snap_doc[i]: document
+    ---
+return: l2_snap_doc[i]
+
@@ -69014,0 +69053,2 @@
+        if: l2_snap_doc[i] != 0
+            lm_p0_document_destroy(l2_snap_doc[i])
@@ -69024,0 +69065,2 @@
+    if: l2_snap_doc != 0
+        l2_xfree((cast: (@: void) l2_snap_doc))
@@ -69027,0 +69070 @@
+    l2_snap_doc: 0
```
