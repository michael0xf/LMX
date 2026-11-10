# Передача разработки: fable_pc → Codex

## Действующая передача 2026-11-08 — чистый граф

По прямому поручению автора Codex принимает кодинг, документы и единственный compiler/test/docs pipeline.
Fable (`0dec7280-e960-42dc-b082-8afc595af622`, PID11248) остановлен по usage credits после 20:54:08Z,
живых сборок нет. Опубликованный HEAD — `9c9dd349abb7940c75e229f7dbef1d058cd28e9b`; новый граф и спецификации —
переданный незавершённый WIP Fable, сохраняемый и продолжаемый Codex. Не возвращаться к исторической оптимизации ниже.

Читать [READ.ME](READ.ME), [steps/current.md](steps/current.md), новую
[спецификацию RU](docs/kernel-implementation.ru.md) / [EN](docs/kernel-implementation.en.md),
[заметки среза309](steps/witnesses/fix309-20261108/notes.md), план и чек-лист. Полная цель — новая архитектура и §§8/8a.

Рабочая зона `P = C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01`, стадия `P/cold-graph309`.
Tuple на момент передачи: tool309e `7bd7ff54…`, frontend fe309a `b1851f7b…`, runtime rt309e `009e86dd…`,
graph309g `c64cbd53…`. Точные SHA и команды — `P/pins/graph309-graph309g.terminal.txt`,
`P/pins/graph309-check309-init.terminal.txt` и record самой проверки. `check309-init` дал interp PASS,
native/forced FAIL. Продолжение Codex — [отдельная запись](steps/witnesses/fix309-20261108/codex-continuation.md):
в новой стадии `P/cold-graph309-codex01` graph02/tool02 исправили запуск; три фикстуры дают 9/9 PASS,
intern7/7. Остаток включает сохранённый @i, повторный чистый обход, Point/take и общий docs check (пока exit1,
отдельная проверка семантики PASS). Это не свидетель завершения минимального среза или полной цели.
Ничего из прежнего frozen stage и чужих WIP не сбрасывать. Подпись будущих коммитов — `[codex]`, Author/Committer codex;
происхождение переданных изменений Fable указывать честно.

## Историческая передача: линия оптимизации, срезы 250–261

Дата: 2026-11-02, ~22:21 UTC. Автор записи: fable_pc (Claude Fable 5.1), единственный writer/build линии
оптимизации по [to_fable.md](to_fable.md) (передача CODEX-FABLE-TAKE-WRITER-20261101T1943Z-01). Остановлен по
указанию автора («остановись пожалуйста и напиши документ to_codex.md по передаче разработки»). С этого момента
fable_pc не запускает сборок, не правит код и не коммитит; writer/build и pipeline освобождаются в пользу Codex
(или того, кому Codex их передаст). Codex по lmx_uds НЕ уведомлён — этот документ и есть передача; уведомление
(и возврат writer/build Opus-у, который ждёт `to_opus_after_optimization.md`) — решение автора и Codex.

Сокращения: `R` = `C:/Nyasha_Planet/LMX` (основной checkout), `P` =
`C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01` (рабочая зона линии: стадии, pins, варианты; не под git).
Записи `.command` — pwsh-рецепты в `P/pins`, запускаются только так (из `R`, с параметрами через переменные окружения):

    C:\Users\mtkra\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe -NoProfile -NonInteractive -Command "Set-Location -LiteralPath 'C:/Nyasha_Planet/LMX'; & ([ScriptBlock]::Create((Get-Content -Raw -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/pins/<запись>.command')))"

Записи, оканчивающиеся `exit $e` (rt/fe/suite/obs/probe/tool), нельзя сцеплять в одной `-Command` — вторая не выполнится;
записи prepare/reuse/land оканчиваются `Write-Output` и сцепляются. Все записи проверяют, что pipeline не жив
(`l2trans.exe`, `l1trans.exe`, `cc1.exe`, `lmxtool-tool.exe`, `lmxtool.exe`), и бросают `pipeline already live`.

## 1. Что опубликовано (main)

- `HEAD` = `origin/main` = `1727adcc` (срез 260 целиком: `a4694ed3` посадка, `b9060374` records, `1727adcc` подтверждение
  Codex дословно). Записи срезов: `steps/witnesses/fix250-20261101/` … `fix260-20261102/notes.md`; текущие инструкции
  `steps/current.md` (последняя запись «Fable, 2026-11-02 — срез260»); дизайн `optimization_design_from_fable.md`
  (редакция 21; §4.5 «Реализация B2b-1»; §6.1 — соответствие номеров срезов).
- `selfbuild/` = source-tp122: `inputs.sha256` `8F34D77F064F00E41E1012DF3973815F4921192307BC065E1DD4CE0C22B4F7A0`, 166
  входов (65 source, 34 tool, 67 test). Это посаженный пакет boot122a (G1 = G2, кроме меток компоновки PE).
- Рабочие бинарники посаженного поколения (boot122a, G2): инструмент `P/cold-boot122a/quick122a/lmxtool.exe`
  `1B9F2BA5751771E2FCB53F3DB60B0E06B24E1ABF1607A449796739D55FA522F6`; frontend
  `P/cold-boot122a/quick122a/g2/frontend/l2trans.exe` `7795D04DD1807F45DDE3FEC7FEF92D670099169372E4BEB7B72866D6C419E784`
  (`l1trans.exe` `989F0716…`, `l2_libc.o` `AF9FDAE3…`); runtime `P/cold-boot122a/quick122a/g2/runtime/driver.o`
  `3CD1C22E5E51C2121E498A8DEBA3E89E69C210CF6D05F297D5A827B3C5410EF1`, `driver-observe.o` `999163A2…`.
- Открытые по ledger (`steps/defects.md`) пункты линии: `BITWISE-OPERATORS-NOT-CLASSIFIED` (отказ до операции в
  типизированном нативном пути, унарная `~`); P1-PTR-COVERAGE на уровне адреса — закрывается срезом 261 (ниже), записи в
  ledger пока нет (скрипт готов).

## 2. Срез 261 (tp123) — в работе, НЕ посажен и НЕ закоммичен

Тема: P1-PTR-COVERAGE на уровне адреса (B2b-2d). Нормы, на которых он построен, — подтверждение Codex среза 260
(`P/pins/CODEX-TP122-MESSAGES-20261102.txt`, дословно и в `steps/witnesses/fix260-20261102/notes.md`), ключевое место:

> Общий P1-PTR-COVERAGE остаётся OPEN: place_address 1699 descriptor/1706 pointer_to ещё дают UNSUPPORTED для
> graph/descriptor/depth; raw-only consumer gap также не языковая норма. 261 coverage/address →262 closures →C
> допустимо, продолжай как sole writer/build без ACK. Адрес graph-bound free name всё так же адрес semantic LOCAL input
> cell, без origin alias/promotion; receiving по actual pointee/context при сохранении
> depth/admission/immutable/native-reset. Разрешённую полноту не свести к одному адресу Point; произвольная допустимая
> глубина/descriptor остаются обязательными в B2. Typed native shift guard/~ ledger и shared collector/3pass/S8/§§8a
> открыты. Codex compiler/tests/docs не запускал; опубликованную историю/зелёные прогоны не повторять. Opus продолжает
> ждать до освобождения всей оптимизации/pipeline.

### 2.1 Что сделано (код)

Вариант: `P/variants/tp123` (6 изменённых файлов относительно `R/selfbuild` + `inputs.list` 167 строк — новая фикстура
`tests/dyn/free_graph_address.lm2` между `free_pointer_paths` и `free_machine_ops`). Список: `P/pins/tp123-changed.list`.
Хэши финальных байтов (после fix02): `lmx_walk_values.lm2` `EC14792F…`, `l2_frontend_lower.lm2` `8A08ED74…`,
`l2_frontend_emit.lm2` `1F38205F…`, `tools/build.lm2` `80C4ED19…`, `tests/full-suite.tsv` `2FB7482D…`,
`free_graph_address.lm2` `C559F1EB…`. Скрипты правок (с утверждёнными якорями): `P/pins/tp123-scripts/tp123_fix01.py`
(всё), `tp123_fix02.py` (одна правка emit). Диффы относительно selfbuild читаются `diff -U1 R/selfbuild/<f>
P/variants/tp123/<f>`.

1. `tools/build.lm2`: enum LmxType — новая константа `LMX_TYPE_CELL_POINTER 1088` (= `LMX_TYPE_POINTER_BASE + 64`:
   собственный код ядра для адреса ячейки, которую не выражает ни один код указателя таблицы; ниже foreign-полосы
   транслятора POINTER_BASE + 100…, выше его фиксированных кодов POINTER_BASE + 3..42, MSG_REF = +29); `decl_walk` — новый
   код обходчика `define: LMX_WALK_OP_RECEIVE 63`, `LMX_WALK_OP_COUNT 64`; экспорт `walk_value_names[147]:
   "lmx_walk_value_receive_pointer"` (calloc 148U, счётчик модуля 148). Изменение инструмента → rebuild tool (tool123).
2. `src/l2src/lmx_walk_values.lm2`:
   - `lmx_type_pointer_to` тотален: тип без кода таблицы (LMX, DESC, UNSIGNED_CHAR, указательная ячейка с кодом
     транслятора, второй уровень кодов таблицы) → `LMX_TYPE_CELL_POINTER`; только NONE → NONE. `lmx_type_pointee` по
     CELL_POINTER даёт NONE (не менялся): указуемое читается cell-first.
   - `lmx_walk_value_deref_actual`: новая ветвь вида CHILDREN/REF — слот графового узла типизируется тем, что держит
     (Structure/null → LMX, Array → DESC; читается `c.lmx_arena_pointer_void_read`).
   - `lmx_walk_place_address`: снят отказ `place\descriptor != 0` (адрес descriptor-места = адрес слота, storage); обновлён
     комментарий; UNSUPPORTED теперь только у места без типа.
   - новая экспортируемая `lmx_walk_value_receive_pointer (@: arena; @: value; int: ty; int: depth; int: leaf; @: out) int`
     (сразу после `lmx_walk_place_address`, т.к. зовёт `deref_actual` и `lmx_walk_place_load`): приём runtime-типизированной
     ссылки указательным местом известной транслятору формы по ФАКТИЧЕСКИМ указуемым: на каждом из `depth − 1` уровней
     адресованная ячейка должна быть ссылочной (тип — от записи-владельца или пула арены) и держать следующий уровень;
     Structure/Array раньше листа (цепочка коротка) или числовая ячейка вместо указательной (не тот уровень) → `THROWN +
     NAME_CONVERT`; null обрывает цепочку (принимается); лист LMX/DESC — классификация арены (или base(type) = LMX/DESC),
     числовой лист — тип ячейки через `deref_actual`, NONE — лист `void` без проверки; значение другого вида → convert,
     отсутствующее → INVALID, нетипизируемое указуемое → UNSUPPORTED. Принятое значение сохраняет ссылку и referent и
     берёт тип места `ty`.
   - `lmx_walk_shape_min`: RECEIVE → 5U. `lmx_walk_eval_result`: обработчик `LMX_WALK_OP_RECEIVE` перед обработчиком
     префиксного знака: [receive, value, witness, depth, leaf] — вычисляет value, отсутствующее оставляет отсутствующим,
     читает depth/leaf (`lmx_walk_load_numeric`), тип — `lmx_walk_witness_type(witness)`, зовёт `receive_pointer`.
3. `src/l2src/l2_frontend_lower.lm2`: внутренний `lm_compiler_dyn_pointer_shape(raw, @depth, leaf)` (перед
   `emit_dyn_receive_full`): форма указательного места, которую таблица ядра не выражает — foreign-код (≥ 100, не C-дверь)
   со словом языка: `Lmx` (глубина ≥ 2; глубина 1 — графовое место, остаётся `receive_graph` среза 260), `LmxArray` →
   DESC, `int/char/size_t/unsigned/ulong` (глубина ≥ 3) → их коды, `void` → NONE; иначе 0. `emit_dyn_receive_full`:
   после текста типа у не-графового места спрашивается форма; печать — три ветви: graph → `receive_graph`, shaped →
   `lmx_walk_value_receive_pointer(l2_program_arena, <record>, <type>, <depth>, c.<leaf>, @ l2_rv%d)`, иначе прежний
   `lmx_walk_value_receive`.
4. `src/l2src/l2_frontend_emit.lm2`: текстовый близнец `lm_compiler_rw_dyn_pointer_shape` (перед `rw_reference_span`);
   `rw_reference_span`: значение вида −20 (`c.lm_compiler_value_span_type(value, rw_mi, @ft) = -20`) у места такой формы
   оборачивается кадром `LMX_WALK_OP_RECEIVE` ширины 5: `rw_witness(frame, 2, ty, 0)` — типизированная ячейка места,
   `lmx_walk_store_size(l2_program_arena, l2_rw%d, 3U, <depth>U)` и `(…, 4U, (cast: (size_t) c.<leaf>))` печатаются только
   при `rw_emit_cell[0] != 0`, затем `rw_evaluate_span(value, ty, frame, @inner)` и `rw_put(frame, 1, inner)`. fix02:
   номер кадра идёт через локал `frame` — актуал `\out` после идентификатора-актуала склеивается парсером в путь
   (`depth\out`; отказ fe123a «l2_frontend_emit.lm2:7911:281: field path goes through a slot with no Structure, atom=out»).
5. `tests/dyn/free_graph_address.lm2` (`runs	dyn/free_graph_address.lm2	7	nf`, строка и комментарий добавлены в
   `tests/full-suite.tsv` после `free_model_admit`): Point/Shape/Slim/Thin, `int: quote 11`; addr `@@: pp Point 0; pp: @
   quote; @: p Point \pp → p\y`; addr3 `@@@: ppp Point 0; ppp: @ quote; @@: pp Point \ppp; @: p Point \pp → p\y`; outer
   (Point: p) `@: quote Point p` → addr = 2 (81); outer_ptr (Point: p) `@: inst Point p; @@: quote Point 0; quote: @ inst` →
   addr3 = 2 (82); outer_slim (Thin: t) `@: quote Thin t` → addr бросает `implements` у deref в модельный own, пойман (83);
   outer_num `int: quote 5` → addr бросает `convert` при приёме адреса (84); outer_short (Point: p) `@: quote Point p` →
   addr3 бросает `convert` (цепочка коротка: Structure раньше листа) (85); m → 7.

Не сделано намеренно (границы, см. §5): raw-only consumer; свидетели descriptor-места и DESC-листа; слепой приём
ТИПИЗИРОВАННЫХ ссылок в строки обходчика.

### 2.2 Что проверено (изолированно, записи в `P/pins`, выходы в `P`)

| шаг | запись / параметры | результат |
|---|---|---|
| стадия | `tp123-prepare.command` TP_TRY=01 (fresh, 21:49:50Z); `tp123-prepare.command` TP_TRY=fix02 (refresh, 22:00:53Z) | `P/cold-tp123` = selfbuild (source-tp122) + вариант; source-tp123 после fix02 `CB155E7E4E4D557B83A92164AA2066B32B68570307E2F6D0EA961632CBDD58B5` (fix01 было `5A73996C…`, файл `source-tp123-before-fix02.sha256`); 11 различий манифеста, как ожидалось |
| reuse | `tp123-reuse.command` | 232 сгенерированных входа из `P/cold-boot122a` (`tp123-reuse.list` = `tp122-reuse.list`) |
| инструмент | `tp123-tool.command` TP_TRY=01 (21:50:07–21:52:20Z) | tool123 `P/cold-tp123/tool123/lmxtool-tool.exe` `573B37F0211119D874C8BEA82ECA3509EA294FAA1DFD0739D7611FDC6066716F`, `REBUILD tool 0 failures` (smoke-kernel225) |
| runtime | `tp123t-rt.command` TP_LABEL=rt123a TP_TRY=01 (21:54:15–21:55:11Z) | 84 заголовка перегенерированы (в `P/cold-tp123/src/l2src/lmx.h.lm1` есть `LMX_TYPE_CELL_POINTER 1088`, в `lmx_walk.h.lm1` — `LMX_WALK_OP_RECEIVE 63`/`COUNT 64`, в `lmx_walk_values.h.lm1` — прототип `receive_pointer`); `rt123a/driver.o` `DAF6D813…`, `driver-observe.o` `FF6DCBD9…` |
| frontend | `tp123t-fe.command` TP_LABEL=fe123a TP_TRY=01 — ОТКАЗ (см. fix02); TP_LABEL=fe123b TP_TRY=02 (22:01:06–22:07:17Z) — OK | `P/cold-tp123/fe123b/l2trans.exe` `F34020C60140F87C94F2FD9F6B06182E8E5F530D30A296360D9096B3F7050088`, `l1trans.exe` `6E24B322…` |
| фокусная сюита | `tp123t-suite.command` TP_FE=fe123b TP_RT=rt123a TP_TRY=01 (22:07:28–22:09:00Z); список `P/pins/focus123.tsv` (= focus122 + новая строка) | `SUITE 15 rows, 0 failures`; выход `P/tp123t-suite/focus123-01` (в `free_graph_address-native/p.lm1` — вызовы `lmx_walk_place_address` и `lmx_walk_value_receive_pointer(…, POINTER_BASE + 100, 2, LMX, …)` / `(…, + 102, 3, LMX, …)`; в `…-forced/p.lm1` — кадры `LMX_WALK_OP_RECEIVE` ширины 5 над ADDRESS, `store_size(…, 3U, 2U/3U)`, `(…, 4U, (cast: (size_t) c.LMX_TYPE_LMX))`) |
| пробы среза 260 | `tp123t-probe.command` TP_FE=fe123b TP_RT=rt123a TP_TRY=01 (22:09:23Z); список `focus123-probe.tsv`; фикстуры `P/cold-tp123/tests/dyn/probe_*.lm2` (копии из cold-tp122; не входы) | 7 строк, 0 отказов — probe_graph_address и probe_graph_deref зелёные в обоих режимах (на посаженном коде: `walk error: UNSUPPORTED`, `P/tp122t-probe/focus122-03/failures.tsv`) |
| наблюдённый walk | `tp123t-obs.command` TP_FE=fe123b TP_RT=rt123a TP_TRY=01 TP_SOURCE=dyn/free_graph_address.lm2 TP_SPEC=m=1,outer=1,addr=3,addr3=2,outer_ptr=1,outer_slim=1,outer_num=1,outer_short=1 TP_ENTRY=7 (22:10:20Z) | все восемь тел walked с этими счётчиками в forced, ни одного в native; `P/tp123t-obs/obs123-01` |
| стадия bootstrap | `boot123t-prepare.command` TP_TRY=a (22:10:31Z) | `P/cold-boot123a` = ровно source-tp123 (167 входов), `source-boot123a.sha256` = `source-tp123.sha256` `CB155E7E…` |
| bootstrap | `boot123t-detached.command` TP_TRY=a → `boot123t-quick.command` (22:10:54–22:30:21Z, 1167 с; G0 = tool123, BASE full48/g2/frontend, прежний frontend G2 boot122a) | **ЗАВЕРШЁН после остановки**: `BootstrapExit 0`, `BOOTSTRAP quick 0 failures` (G0 строит и проверяет G1, G1 строит и проверяет G2, G2 — рабочий bundle); лаунчер `done 2026-11-02T22:30:21Z`. G2 (`P/cold-boot123a/quick123a`): рабочий инструмент `lmxtool.exe` `1F12CDC16A5CE43200ABCF0B4E4BC43BC60B1232A6EF3CFEB7C135BE4D89D9DB`; `g2/frontend/l2trans.exe` `8DD841A0903F2E9E10EDD54D91170D9EA8609BD439ABCC7DFA2380AF15160886` (`l1trans.exe` `EA382592…`); `g2/runtime/driver.o` `DAF6D813E3B08B7E7B9E75D607589F33FE9E4AC6A7C0AFDDCCAF16EB3B1F5274` и `driver-observe.o` `FF6DCBD9…` — байт в байт равны изолированным rt123a (как в 260). Pipeline свободен (живых процессов нет). Сравнение поколений (`boot123-compare.command`) и сюита на G2 НЕ запускались — остановка. |

Pipeline на момент дописывания (22:33Z) свободен; bootstrap дошёл до конца сам, стадия `P/cold-boot123a` целая.

### 2.3 Что осталось до публикации среза 261 (точный порядок; скрипты — `P/pins/tp123-scripts/`, python -I)

Ничего из этого не начато. Все скрипты клонированы с 260-х с утверждёнными заменами; аргументы — факты boot123a.

1. (Сделано самим bootstrap-ом: `done`, `BootstrapExit 0`, `BOOTSTRAP quick 0 failures` — см. §2.2.) Рабочий инструмент G2 для шагов ниже: `P/cold-boot123a/quick123a/lmxtool.exe` `1F12CDC16A5CE43200ABCF0B4E4BC43BC60B1232A6EF3CFEB7C135BE4D89D9DB`; source-tp123 `CB155E7E4E4D557B83A92164AA2066B32B68570307E2F6D0EA961632CBDD58B5`.
2. `boot123-compare.command` TP_TRY=a → `P/pins/boot123a-compare.txt` (ожидание: 248 путей в обоих поколениях, 245
   raw-equal, 3 PE-образа различаются только в байтах 136–137/216–217). Хэши G2: `P/cold-boot123a/quick123a/lmxtool.exe`
   (рабочий инструмент), `…/g2/frontend/l2trans.exe`, `…/g2/runtime/driver.o`, `driver-observe.o`.
3. `tp123-suite-g2.command` (фокусная сюита на G2; ожидание 15/0).
4. `clone261.py <WORKING_G2_HASH_UPPER> <SOURCE_TP123_HASH_UPPER>` → `land261.command`, `docs261.command`,
   `docs261-check.command`; затем `land261.command` (selfbuild ← source-tp123, 167 путей; 65 consumed sources G1/G2
   сверяются; `selfbuild/inputs.sha256` = `CB155E7E…`).
5. Документы: `readme261.py <working> <src> <tool123 573b37f0…>`; `current261.py <start hh:mm:ss> <end> <секунды>
   <raw-equal> <in-both> <working> <src> <tool123> <g2 fe>`; `design_rev22.py <tool123> <working> <g2 fe> <секунды>`
   (вставляет «Редакция 22» перед «Редакция 21» и заменяет в §4.5 абзац «**Остаётся** (срез 261)» на «**Реализовано**
   (B2b-2d…)»); `notes261_append1.py <start hh:mm:ss.fff> <end> <секунды> <in-both> <raw-equal> <differ> <working> <g2 fe>
   <g2 driver.o> <g2 driver-observe.o> <src>` (часть 1 записи уже написана: `steps/witnesses/fix261-20261102/notes.md`,
   92 строки — единственное моё изменение в working tree репозитория, untracked); `records261.py` (evidence.list + LF-копии
   в `records/`; проверить отсутствие байтов < 0x20 кроме TAB/LF); `docs261.command` (манифест evidence + verify).
6. Коммит A (явные пути: `optimization_design_from_fable.md`, `selfbuild/` — изменённые 5 + новая фикстура + `inputs.list`
   + `inputs.sha256`, `steps/current.md`, `steps/witnesses/fix261-20261102/`) сообщением `tp123-scripts/commit261a.txt`;
   `docs261-check.command` (полный docs check, ожидание exit 0); `ledger261.py <commitA>` (запись
   FREE-ADDRESS-REFERENCE-PLACE-UNSUPPORTED перед NUMERIC-KIND-PRESENT-OPERAND); `notes261_docs.py <commitA> <evidence
   count> <records count> <docs start> <docs end> "<OK-строка docs check>"`; коммит B (`commit261b.txt`: `steps/defects.md`,
   notes, `records/docs261*.command`); `git fetch`, `git log origin/main..HEAD` (должны быть только свои два коммита),
   `git log HEAD..origin/main` (пусто), `git push origin main`.
7. RESULT Codex-у: `result123.py <HHMM> <start> <end> <секунды> <in-both> <raw-equal> <differ> <working> <g2 fe> <commitA>
   <commitB> <src>` → `P/pins/FABLE-RESULT-TP123-20261102T<HHMM>Z.txt`; отправка из `R`: `python
   claude_chat/codex_inbound.py send --sender fable_pc --request-id FABLE-RESULT-TP123-20261102T<HHMM>Z <
   <файл>`. Ответ Codex архивировать дословно (`P/pins/CODEX-TP123-MESSAGES-20261102.txt` + запись среза). Если
   запускает не fable_pc — поменять `--sender` и, по смыслу, текст от первого лица.

Не чужие и не protected файлы при этом не трогать (см. to_fable.md: корневой `build/` не читать; `l2_driver_launch.err`
не трогать; `steps/witnesses/used-scope-20261020/reference-producer117.patch`, `fix249-20261101/notes.md`, `fix250-20261101/`
— Opus; `to_fable.md`, `to_opus.md`, `optimization_three_passes_shared_runtime.md`, `LMX_blog/2026-11-01.md` — Codex).

## 3. Что дальше по линии (план, согласованный с Codex: 261 → 262 → C → FULL → передача Opus)

- **Срез 262 = B2b-3, замыкания**: снять пересылку свободного входа callee его вызывающим (`dyn_site_callee` /
  `dyn_site_held`); снять статическую типизацию свободных имён (сегодня графовое поле юнита даёт TYPED скрытый вход,
  `dt_of_own` = oty+1, и только числовые источники дают FREE — поэтому свидетели 260/261 привязывают имя числового поля
  юнита к графу); отказ трансляции «unbound dynamic input» заменить runtime-недопустимостью вызова (книга :727/:777);
  мёртвые пути `wait_*` / `note_call` / `dyk` для свободных имён удалить. Норму `@free` не переоткрывать (решение Codex).
- **C**: снятие M2/preflight (дизайн §4.3, §4.8) — после 262.
- **FULL** — только в финале (ни одного FULL в промежуточных срезах; решение Codex); затем `to_opus_after_optimization.md`,
  освобождение writer/build, сообщение Codex для обратной передачи Opus.
- Правила хода (без изменений): один writer/build и один pipeline; измеряемые срезы с записями; публикация проверенных
  срезов в main только своих файлов; без ACK-ворот; вопросы — только Codex через lmx_uds; дизайн-дельты — в дизайн-документе;
  «no new probe scripts» (проверки через существующие записи `lmxtool suite`/`os-walk-witness`, пробные фикстуры — scratch в
  `tests/dyn` стадии, не входы); коммиты с trailer-ами `Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>` и
  `Claude-Session: …` для fable_pc (для другого исполнителя — свои).

## 4. Карта артефактов

- Стадии и поколения: `P/cold-tp1NN` (изолированные сборки кандидата: `toolNNN`, `rtNNNa`, `feNNNa/b`), `P/cold-bootNNNa`
  (bootstrap: `quickNNNa/{g1,g2}`, `lmxtool.exe` — рабочий инструмент), `P/variants/tpNNN` (изменённые файлы + `inputs.list`).
  Посаженные: 112…122. Текущий кандидат: 123.
- Записи `P/pins`: `tp123-{prepare,reuse,tool}.command`, `tp123t-{rt,fe,suite,obs,probe}.command`, `boot123t-{prepare,quick,
  detached}.command`, `boot123-compare.command`, `tp123-suite-g2.command`, списки `tp123-changed.list`, `tp123-reuse.list`,
  `focus123.tsv`, `focus123-probe.tsv`; терминалы `*-NN.terminal.txt`, логи `*-NN.log`; манифесты `source-tp123.sha256`,
  `source-boot123a.sha256`, `tp123-changed-01.sha256`, `tp123-changed-fix02.sha256`, `tp123-reuse-{inputs,artifacts}.sha256`.
  Шаблоны для 262 — те же записи с заменой 123 → 124 и названий предыдущего поколения (boot123a) — делать клон-скриптом с
  утверждёнными заменами (образец `records123.py`/`records123t.py`), затем `grep -n 123` по не-комментариям.
- Выходы сюит: `P/tp123t-suite/focus123-01`, `P/tp123t-probe/focus123-01`, `P/tp123t-obs/obs123-01` (в каждой папке
  фикстуры: `p.lm1`, `p.c`, `p.L2.log` (отказ транслятора), `run-root0.log` (ошибка обходчика), `record.txt` с хэшами).
- Сообщения Codex: `P/pins/CODEX-TP121-MESSAGES-20261102.txt`, `CODEX-TP122-MESSAGES-20261102.txt`, мои RESULT-ы
  `FABLE-RESULT-TP1NN-*.txt`, протокол — `claude_chat/codex_inbound.py` (send) и lmx_uds (приём).
- Записи срезов в репозитории: `steps/witnesses/fix2NN-20261102/{notes.md, evidence.list, evidence.sha256, records/}`;
  261 — только `notes.md` (часть 1), остальное создают `records261.py`/`docs261.command`.

## 5. Открытые границы и соображения для следующих решений

1. **raw-only consumer** (Codex: не языковая норма): адрес свободного имени там, где нужен сырой типизированный C-операнд
   (C-дверь без прототипа, машинный операнд) — located-отказ транслятора `lm_compiler_emit_free_input_address`: «a
   runtime-typed address where a typed native value is required (B2a: receive it into a typed local first)». Потребители с
   известным типом уже идут через `emit_dyn_receive_full`; у безтипового потребителя приём невозможен без типа.
2. **Descriptor-место и DESC-лист**: `lmx_walk_place_address` адресует descriptor-место, `receive_pointer` знает лист DESC,
   `deref_actual` знает слоты CHILDREN/REF — но свидетелей нет: путь к descriptor-месту без witness-а (поле графа через
   свободное имя, `@ (quote\child)`) и привязка свободного имени к Array в сегодняшнем фронтенде недостижимы. Не заявлять
   покрытие без свидетеля; дать свидетелей в 262+ (замыкания/пути полей).
3. **Две записи одной ссылки** (LMX у walked строк/формалов/листьев обходчика; `LMX_TYPE_POINTER_BASE + 100 + i` — foreign
   intern `Lmx` у нативных записей графовых own; индексы интернов — на единицу трансляции, ядру не вывести). Из-за этого
   обходчик принимает ТИПИЗИРОВАННЫЕ ссылки в свои строки слепо (SET в рабочую ячейку — только проверка вида; store_with_writer
   — только вид), а runtime-типизированные — по кадру RECEIVE с depth/leaf от транслятора. Рассмотренная и НЕ взятая
   альтернатива (оставляю как вариант для C или отдельного среза, если Codex сочтёт нужным): кодировать указатели на
   `Lmx`/числа любой глубины кодами, выводимыми ядром (арифметическая семья или регистрация foreign-кодов транслятора в ядре
   при старте программы), чтобы `lmx_walk_value_receive` сравнивал глубину/лист семантически в обоих исполнителях и две
   записи слились; цена — смена печати всех кодов (`lm_compiler_ptr_cell_type` и профили `lmx_pointer_new_profiled`), полный
   bootstrap как судья. Ledger-запись `KERNEL-POINTER-TYPE-RANGE` (OPEN «до G5») — о том же.
4. Ledger `BITWISE-OPERATORS-NOT-CLASSIFIED`: отказ до операции в типизированном нативном пути и унарная `~` — открыты.
5. Из списка Codex: shared collector / 3pass / S8 / §§8a — открыты (дизайн §2–§5).
6. Ловушки кода, встреченные в 259–261 (полный список — в записях срезов): якоря правок брать из `sed -n` реальных строк;
   двухуровневый dedent требует `---`; `\out` после идентификатора-актуала склеивается в путь; записи с `exit $e` не
   сцеплять; новый код обходчика = define + OP_COUNT + `lmx_walk_shape_min` + обработчик `lmx_walk_eval_result` + эмиттер
   `rw_frame`; новая кернел-константа/экспорт = rebuild tool → build-runtime (перегенерация заголовков) → fe → suite → obs →
   bootstrap; записи клонировать явными заменами и грепать старые номера.

## 6. Состояние working tree репозитория на момент остановки

`git status`: мои — только untracked `steps/witnesses/fix261-20261102/` (notes.md, часть 1; пустой `records/`). Остальные
изменённые/untracked файлы — чужой WIP (Opus: `fix249-20261101/notes.md`, `fix250-20261101/`; Codex: `to_fable.md`,
`to_opus.md`, `LMX_blog/2026-11-01.md`, `optimization_*`; старые `fix208…217`, `reference-producer117.patch`) — не трогать.
`HEAD` = `origin/main` = `1727adcc`; ничего не ожидает push-а. Этот документ (`to_codex.md`) написан в working tree и не
закоммичен.
