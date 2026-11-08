# Срез 309 — вертикальный срез новой реализации ядра: построитель → чистый Lmx-граф → оба потребителя (§11 п. 0 спецификации)

Запись fable_pc, начата 2026-11-08 19:25Z. Это первый срез перехода по [спецификации реализации ядра](../../../docs/kernel-implementation.ru.md)
(RU; [EN](../../../docs/kernel-implementation.en.md)), разрешённого вторым ревью Codex (CODEX-FABLE-KERNEL-SPEC-REVIEW2-20261108T185727823Z-01)
после поручения автора 2026-11-08 остановить направление числовых кодов (дословно — [журнал](../../../LMX_blog/2026-11-08.md)).
Номер 309 — следующий в последовательности записей; это **не** срез «309» остановленного плана кодов (транслятор L1), тот не
возобновляется.

## Цель среза (§11 п. 0)

(а) Отдельный вход инструмента: минимальный построитель из текста → чистый граф (типизированные участки, слоты `ref`,
примитивы, примитивы-слова, таблица адрес → name) → интерпретатор по §6 и выпуск native по §7 на одном графе с уже
инициализированным `int`, арифметикой и повторной записью (`int: x 5`, `x: x + 1`, `x: 7`); результаты обоих потребителей
совпадают.
(б) Первое присваивание: `int: x`, `x: 5`, `x + 1`; с заранее взятым адресом — `int: i`, `@i` сохранён без чтения
незаписанных байтов, `i: 5` даёт 5 по адресу, `i: 7` — 7 по тому же адресу (автор 19:02Z); второй чистый обход того же
графа с пустыми таблицами.
(в) Пример §10 целиком: `Point`, `fn: take (Point: p; int: q) int`, `int: r take(Point, 1)`; `toLmx` до и после исполнения;
паритет native/интерпретатор; критерий чистого обхода (§11 п. 6б).

Новый путь строится рядом со старым под отдельным входом инструмента и не трогает выпуск старого, пока не покроет фикстуру.

## Состояние перед срезом

- Рабочее дерево: исходники `selfbuild/src/l2src` и `selfbuild/tools/build.lm2` возвращены к HEAD (9c9dd349) точечным
  `git checkout -- <пути>` после проверки, что сохранённый патч WIP 308 (`../fix308-20261108/records/wip308-a15.patch`,
  sha256 f3079d04…6b1c) байт в байт равен снятому diff; документы (спецификация, книга, L2, READ.ME, journal, steps,
  план v3, чеклист) изменены и не закоммичены.
- Рабочий инструмент: boot164a `lmxtool.exe` 8b106da5…; опубликованный кортеж boot170b (tool 41fe7cbe…, fe 69e8c17d…,
  rt driver.o b6a65587…). Стейдж cold-tp140 остался состоянием a15 остановленного 308 и для этого среза не используется.
- Свободная память перед началом: 7.1 GiB физической, 8.1 GiB виртуальной; процессов pipeline нет.

## Ход (дополняется)

### Исходники среза (рабочее дерево, не закоммичено)

- Ядро: `selfbuild/src/l2src/lmx_graph.lm2` (состояние процесса — строки написаний, записи графов; примитивы `int`,
  слово, «int без инициализации» как указатель на свою ячейку; Lmx со слотами; таблица адрес → name арены; чтение и запись
  места; печать вида `toLmx` с маркерами `GRAPH-<mark>-BEGIN/END`) и `lmx_graph_run.lm2` (интерпретатор по §6 для
  `int: name expr`, `name: expr`, арифметики `+ - * / %` со скобками). Оба входят в `driver.o` через список
  `bld_kernel_l2` (экспорты `lmx_graph_*`, 25 и 2 имени) и `decl_driver_carrier`; записи `LmxName`, `LmxGraph`,
  `LmxGraphState`, типы `LMX_TYPE_WORD 37`, `LMX_TYPE_NAME 38`, `LMX_TYPE_TEXT 39`, `LMX_TYPE_UNINIT_INT 1001024` — в
  `lmx.h.lm1` (`decl_lmx`), якорь состояния — `l2src/lmx_graph_state.lm1` (`decl_graph_state`, вид 59).
- Инструмент графа: `selfbuild/src/l2src/l2_graph_tool.lm2` (P0 → построитель чистого графа; выпуск L1 программы с
  native-телом над графом или с принудительным вызовом интерпретатора; команды `run`, `emit`, `p0`, `intern`) и программа
  `selfbuild/tools/graph_trans.lm2` (форма `lmxtool.lm2`); рецепты `bld_graph` (`build-graph`) и `bld_graph_check`
  (`graph-check`: интерпретатор, native, forced — сравнение секции GRAPH-AFTER с `.expected`) в `tools/build.lm2`,
  ветки в `tool_main`.
- Фикстуры `selfbuild/tests/graph/{init_arith,first_assign,precedence}.lm2` с `.expected`; `inputs.list` — 274 строки.
- Правки по read-only ревью Codex `CODEX-FABLE-KERNEL-VERTICAL-READONLY-20261108T195756101Z-01` (копия дословно в
  `P/pins/`): (1) байт 0x07 в `lmx_graph.lm2:136` — след свёрнутого escape в heredoc Bash (известная ловушка); вставка
  удалена, в четырёх новых файлах и обоих `tools/*.lm2` управляющих байтов 0 (`tr -d '[:print:][:space:]'`); (2) байты
  канонических написаний теперь лежат в участке `text` (`LMX_TYPE_TEXT`) собственной арены состояния строк (пул с шагом
  1 байт и чанками 4096, `lmx_arena_take_n`), а не в heap; индекс поиска по байтам остаётся служебным состоянием; экспорт
  `lmx_graph_intern_owned` и команда `graph_trans intern` — свидетель §4: одно написание из двух живых арен — один адрес,
  классифицируемый участком владельца и ни одной из арен графов, неизменный после роста индекса на 300 написаний;
  heap-строка — не написание; (3) §6.5 RU/EN переписан: роль слота — по исполняемой Lmx (вызываемое с частями, обычная
  исполняемая Structure без частей `fn`, корень с операторами, `call: code data`/`call: code code`, неисполненное
  объявление), не по именам `args`/`return`/`body`, не по имени места назначения и не по ссылке; добавлен свидетель (5).

### Стадия и сборки

- `graph309a-prepare` (список `pins/graph309a-prepare.tsv`, инструмент boot164a 8b106da5…): `MANIFEST 274 files, 0
  failed` → `pins/source-graph309-a01.sha256`; `STAGED 274`, `VERIFIED 274` в `P/cold-graph309`; `CHECKS 3 lines, 0
  failed` (журнал `pins/graph309a-prepare.log`, квитанция `.terminal.txt`).
- `rt309a` — `rebuild runtime` инструментом boot164a: отказ на шаге 5 — `--machine lmx_call_bind_actuals names no
  function with a body` в `lmx_walk_values.lm2` (список машинных имён старого инструмента старше срезов 305–307; журнал
  `pins/graph309-rt309a.log`, `cold-graph309/rt309a/lmx_walk_values.L2.log`). Каталог `rt309a` оставлен как след.
- `rt309b` — `rebuild runtime` опубликованным инструментом boot170b (`cold-boot170b/quick170b/lmxtool.exe`
  41fe7cbe…), чьи списки соответствуют HEAD; этот инструмент ещё не знает `lmx_graph*`: его сборка даёт runtime и
  заголовки стадии для сборки инструмента среза (`rebuild tool` → `tool309a`), которым затем собираются runtime с модулями
  графа (`rt309c`) и `graph_trans` (`build-graph`). Результат: `REBUILD runtime 0 failures`, `SUITE 9 rows, 0 failures`
  (94 с); `rt309b/driver.o` b6a65587… — те же байты, что у опубликованного runtime boot170b (старый список модулей;
  новых модулей в нём нет), `driver-observe.o` 565b0a16… (квитанция `pins/graph309-rt309b.terminal.txt`, журнал
  `pins/graph309-rt309b.log`).
- `tool309a` — `rebuild tool` инструментом boot170b с runtime `rt309b`: инструмент из `tools/build.lm2`,
  `tools/lmxtool_methods.lm2` стадии (рецепты `build-graph`, `graph-check`, записи и типы графа в `decl_lmx`, модули
  `lmx_graph`/`lmx_graph_run` в `bld_kernel_l2`). `REBUILD tool 0 failures` (79 с); `tool309a/lmxtool-tool.exe`
  4579a470….
- `rt309c` — `rebuild runtime` инструментом tool309a: `lmx_graph.lm2` транслирован (заголовок `lmx_graph.h.lm1` с 25
  прототипами); `lmx_graph_run.lm2:41:5: assignment value has unknown type` — вызов функции другого модуля без двери
  `c.` (транслятор L2 знает только функции своего модуля; межмодульные вызовы ядра идут через `c.имя` по прототипам
  предопределённого заголовка). Исправление в `lmx_graph_run.lm2` и `l2_graph_tool.lm2`: все вызовы `lmx_graph_*`
  другого модуля — через `c.`, инициализаторы объявлений с такими вызовами — через `cast:`; взаимная рекурсия
  операнд ↔ выражение заменена одной саморекурсивной функцией (`lmx_graph_eval_from`, `l2_graph_emit_from`: разбор
  операнда внутри, вложенная Lmx — тот же подъём по приоритету), так как ссылка вперёд на функцию своего модуля
  транслятором не принимается; проверка `fwdrefs` по трём модулям: 0 ссылок вперёд.
- `rt309d` — оба модуля транслированы, `HEADERS 50 regenerated`, `driver.lm1` → C; компиляция `driver.c` отказала:
  `headers/l2src/lmx.lm1.h:216: unknown type name 'LmxArena'` — записи `LmxGraph`/`LmxGraphState` в `lmx.h.lm1`
  ссылались на `LmxArena`, объявленную позже (`lmx_arena.h.lm1` предопределяет `lmx.h.lm1`, не наоборот); остальные 19
  ошибок — следствие. Исправление: записи `LmxName`, `LmxGraph`, `LmxGraphState` перенесены в `decl_arena`
  (`lmx_arena.h.lm1`, сразу после `end: LmxArena`); `decl_graph_state` предопределяет `lmx_arena.h.lm1`.
- `tool309b` — `rebuild tool` инструментом boot170b с runtime `rt309b` по исправленному `build.lm2`: отказ на
  компиляции C — тот же `lmx.lm1.h:216: unknown type name 'LmxArena'`: сборка инструмента компилируется против
  заголовков стадии `cold-graph309/headers/`, которые `rt309d` перегенерировал по старым `decl_*` tool309a (сборка
  инструмента заголовки не перегенерирует). Порядок восстановления: `rebuild runtime` инструментом boot170b
  (`rt309b2`: заголовки стадии вновь формы HEAD) → `rebuild tool` (`tool309c`) → `rebuild runtime` им (`rt309e`).
- `rt309b2` — `REBUILD runtime 0 failures`, `driver.o` b6a65587… (те же байты), `lmx.h.lm1` стадии без записей графа;
  `tool309c` — `REBUILD tool 0 failures`, `tool309c/lmxtool-tool.exe` 7130eb7d… (build.lm2 стадии c08bf9d8…).
- `rt309e` — `rebuild runtime` инструментом tool309c: оба модуля графа транслированы, `driver.c` скомпилирован,
  `REBUILD runtime 0 failures`, `SUITE 9 rows, 0 failures` (92 с); `rt309e/driver.o` 009e86dd… (620583 байт; старое
  ядро 608819), `driver-observe.o` 6fd934e4…. Первый runtime с `lmx_graph_*` в составе.
- `graph309a` — `build-graph` инструментом tool309c с runtime `rt309e`: части P0 стадии транслированы
  (`p0_own`, …), модуль `l2_graph_tool` отказан: `--machine l2_graph_main: a machine function's C name is not l2_,
  the translator's own` — префикс `l2_` закреплён за именами самого транслятора. Функции модуля переименованы в
  `lm_graph_*` (как `lm_compiler_*` во `l2_frontend_*.lm2`; имя файла `l2_graph_tool.lm2` оставлено по тому же
  образцу), экспорты в `bld_graph` и вызов в `tools/graph_trans.lm2` — тоже; имена L1 выпускаемой программы (`l2_g`,
  `l2_t<n>`, `lm_graph_body`) — имена L1, не машинные. Новая сборка инструмента `tool309d` (boot170b, runtime
  `rt309e`): `REBUILD tool 0 failures`, `tool309d/lmxtool-tool.exe` 3d08b5d2… (build.lm2 3dc907eb…); затем
  `build-graph` → `graph309b`.
- `graph309b` — отказ трансляции модуля: `l2_graph_tool.lm2:35:25: node is a word of the language: a program cannot
  bind it` (слово языка `node`, известная ловушка); параметры и локальные `node` переименованы в `nd`.
- `graph309c` — отказ: `46:42: assignment value has unknown type (atom=field)` — чтение поля записи P0
  (`field\value`) в типизированный формал: транслятор L2 не знает типов полей записей, объявленных `l1src/p0.h.lm1`
  (фронтенд оборачивает такие чтения в `cast:`, обёртки `lm_compiler_port249_*`). Добавлены 10 обёрток
  `lm_graph_p0_*` (value, next, first, atom, frame, structure, head, body, data, length) с одним `cast:` каждая; все
  чтения полей P0, попадающие в формалы, локальные или возвраты, идут через них; сравнения в условиях — без обёрток,
  как во фронтенде. Проверка `fwdrefs`: 36 функций, 0 ссылок вперёд. Сборка `graph309d`.
- `graph309d` — отказ: `238:45: this C call's actual has no C type to keep its value before a later actual runs a call
  (OPEN)` — `c.lmx_arena_pointer_void_read(cell)` как аргумент перед аргументами-вызовами (известная ловушка «C calls
  keep actuals in order»); значение вынесено в типизированную локальную `value`. Сборка `graph309e`.
- `graph309e` — модуль `l2_graph_tool` транслирован (заголовок и тело), программа `graph_trans.lm2` → L1; отказ
  L1-транслятора: `cannot read import l2src/lm_graph_tool.lm1` — слепое переименование `l2_graph_` → `lm_graph_`
  задело путь `predef` в `tools/graph_trans.lm2` (имя файла модуля); путь восстановлен (`l2src/l2_graph_tool.lm1`),
  комментарии тоже. Сборка `graph309f`.
- `graph309f` — программа `graph_trans.lm1` выпущена; отказ L1-транслятора: `l2src/lmx_manager.h.lm1:46:1: too many
  header type names` — фиксированная таблица имён типов заголовков L1-транслятора (128 имён / 8192 байт,
  `l1_hdr_type_add` в `src/l2src/l1_backend_state_helpers.lm2`, поднята один раз для FABLE-134): программа графа —
  первая, что предопределяет одновременно заголовки ядра (их выпускает фронтенд для любой программы) и заголовок
  P0 (27 записей/fnptr). По правилу автора о фиксированных пределах (локализованный предел снимается у причины)
  таблица сделана растущей: ячейки состояния `l1_hdr_types`/`l1_hdr_kinds` — указатели с ёмкостями
  `l1_hdr_typescap`/`l1_hdr_kindscap` (`decl_l1_backend_state`, tools/build.lm2), `l1_hdr_type_add` удваивает через
  `realloc` (минимум 8192 байт / 128 имён), `l1_hdr_type_has`/`l1_hdr_kind_of_cstr` читают через ячейки; сброс единицы
  обнуляет счётчик, не память. Следствие: новый фронтенд (`l1trans.exe` — часть связки фронтенда): `rebuild tool`
  (`tool309e`, ячейки состояния пишет инструмент) → `rebuild frontend` им (`fe309a`) → `build-graph` с `fe309a`
  (рецепты получили необязательные TP_FE/TP_FE_SHA). Бюджет L3 `tools/l3_type_budget.py` (EXPECT 85 + ABI) измеряет
  замыкание заголовков дерева `dev/l2src_sandbox` закреплённым транслятором — этот срез то дерево не трогает (записи
  графа объявляет `decl_arena` только для `selfbuild`), EXPECT не меняется; сам комментарий инструмента о «cliff
  128/8192» описывает закреплённый старый транслятор, не новый.
- `tool309e` — `REBUILD tool 0 failures` (77 с), `tool309e/lmxtool-tool.exe` 7bd7ff54… (build.lm2 f9688c70…).
- `fe309a` — `rebuild frontend` инструментом tool309e (предыдущий фронтенд boot170b 69e8c17d…, runtime `rt309e` для
  дымового прогона): `l2trans.exe` и `l1trans.exe` с растущей таблицей имён типов. `REBUILD frontend 0 failures`,
  `SUITE 9 rows, 0 failures` (264 с); `fe309a/l2trans.exe` b1851f7b… (1638982 байт), `fe309a/l1trans.exe` 27c112a3…
  (485358 байт).
- `graph309g` — `build-graph` инструментом tool309e, фронтендом fe309a, runtime `rt309e`: части P0, модуль
  `l2_graph_tool`, `HEADERS 88 regenerated`, программа `graph_trans` → `graph309g/graph_trans-prod.exe` c64cbd53…
  (913832 байт), 8 с. Ручной прогон для диагностики (без квитанции): `p0 tests/graph/precedence.lm2` показывает
  скобочную группу `(c - 2)` вложенной `structure fields=3` внутри тела Frame `c`, как предполагал построитель;
  `run tests/graph/init_arith.lm2` печатает `GRAPH-BEFORE` (`int: x 5`, `x: x + 1`, `x: 7`) и `GRAPH-AFTER`
  (`int: x 7`, те же операторы), выход 0.

### Проверки (а)

- `check309-init` — `graph-check` фикстуры `init_arith` (интерпретатор; native и forced через выпуск L1 → l1trans
  fe309a → gcc -O0 → линковка с `rt309e/driver.o`): сравнение секции GRAPH-AFTER с `init_arith.expected`.
