# v3 §8: инвентаризация closure самосборки

## Текущий source-root после передачи 2026-10-29

Поддерживаемый отслеживаемый пакет — [selfbuild/](../selfbuild/README.md):
159 входов candidate48 с относительным manifest `514564A9…` и прежней раскладкой
src/tools/tests. Обычный языковой stage-copy берёт этот корень, затем существующий
recipe читает только входы стадии и генерирует L1/C перед потребителями. Старые
шесть списков tools/l2/inputs и dev-снимки ниже — история, не запасной источник
при ошибке генерации. Whole quick boot45 принят; full45 остался FAIL.
Candidate48 включает проверенные component/runner/docs-исправления поверх45;
результаты и границы — [срез240](witnesses/fix240-20261029/notes.md), FULL ещё не принят.
Эта публикация исходников не объявляет S8.6,
полный аудит импортов, clean-clone G0 или почту завершёнными.

## Историческая инвентаризация

Исходный снимок 2026-10-17, `8adaed16` + WIP P1#2; текущий перенос — в
[текущей сводке](#current-kernel-state) ниже. Источник требований —
[план v3](../next_core_tasks_v3.md), §§3, 8 и 8a. Это исходная
инвентаризация S8.3, **не принятый manifest G0** и не подтверждение
переноса. Кодинг S8 следует после принятого чистого ядра; сейчас ещё
проверяется P1#2, остаются M2/N1–N6 и другие зависимости §3.
Старая карта `next_core_tasks.md` с назначениями сентября удалена из
текущего текста; она доступна в истории этого файла.
Указанные здесь порядок и состояние P1#2 относятся к исходному снимку 2026-10-17,
не задают новый gate перед текущим переносом. Действующий приоритет короткого
сквозного bootstrap и последующего широкого тестирования — в [READ.ME](../READ.ME).

## Фактические входы проверок снимка 2026-10-17

- `tools/build_l2src.ps1` использует pinned `bin/l1trans.exe` и
  поддерживаемые вручную `dev/l2src_sandbox/*.lm1`, включая заголовки.
  Его собственная шапка прямо говорит: это **не самосборка**.
- `tools/l2_harness.ps1` собирает `l2trans.lm1` тем же L1→C маршрутом.
  Generated `.lm1` фикстур проверяет L2, но не превращает исходник
  транслятора в L2 или L3.
- Kernel и L3 gates берут `l1src` из **`dev/l2src_sandbox/l1src/`**.
  Корневой `l1src/` — другой набор, не symlink. Например, их `libc_abi.lm1`
  различаются; эти входы нельзя молча подменять друг другом.
- `tools/run_l3_selftest.py` собирает `dev/l3_interp/l3*.lm1` и kernel
  из L1; его per-suite `manifest.json` перечисляет staged источники,
  SHA-256 и команды. GREEN 11 suites не доказывает L3+L2 self-build.
- `tools/run_self_build.ps1` строит старую цепь L1 B0/B1/B2 и сравнивает
  восемь generated C/header файлов. Это не G0→G1→G2 из §8 и не доказательство
  build/test orchestration силами языка.

## Карта переноса и границы доказательства

Ни одна строка таблицы не закрывает S8.3. Для каждой живой зависимости
понадобится точный поддерживаемый L3/L2-путь, generated L1/C, импорты,
проверка и удаление старого поддерживаемого тела/заголовка. Отсутствующий
новый путь означает **не перенесено**, а не разрешённый постоянный L1 shim.

| Слой | Нынешние входы | Состояние переноса / необходимое доказательство |
| --- | --- | --- |
| Арена, адреса, пулы, GC | `dev/l2src_sandbox/lmx_arena*.lm1`, `lmx_pool*.lm1`, `lmx_scratch*.lm1`, `lmx_gc*.lm1` | Поддерживаемые L1 тела/заголовки. Перенести вместе классификацию адресов, типизированные пулы и гарантии стабильных слотов. |
| Значения, Structure, Array, List | `lmx_value_owned*.lm1`, `lmx_array*.lm1`, `lmx_chars*.lm1`, `lmx_dec*.lm1`, `lmx_list*.lm1` в том же sandbox | Не считать имя каталога L2 доказательством языка источника. Сохранить общую базу Lmx/Array; растущий List не перемещает слоты уже созданных Lmx. |
| Допуск, копия, merge, call | `lmx_implements*.lm1`, `lmx_graph_copy_owned*.lm1`, `lmx_merge_owned*.lm1`, `lmx_call*.lm1` | Порт после принятия общей модели; одна карта копии и допуска, реальные code/data, без второго runtime resolver. Текущий P1#2 ещё WIP, не S8-порт. |
| Message/Thread и сервисы | `lmx_message*.lm1`, `lmx_thread*.lm1`, `lmx_child*.lm1`, `lmx_orphan*.lm1`, `lmx_root*.lm1`, `lmx_deliver*.lm1`, `lmx_settle*.lm1`, `lmx_service*.lm1`, `lmx_manager*.lm1`, `lmx_turn*.lm1` | Перенос ownership/почты в S8.3; S8a затем мигрирует языковой post/send/receive через этот же механизм, не создаёт вторую очередь. |
| Обходчик и L3 adapter | `lmx_walk*.lm1`, `lmx_interp*.lm1`; `dev/l3_interp/l3*.lm1` | Источник adapter пока содержит `LmxOp` и `L3_NODE_*` (`l3_exec.lm1`, `l3_recv.h.lm1`). Это отдельный legacy-путь, не доказательство новой нормы написанной головы/типизированных пулов. Устранить расхождение до приёмки единого L3 runtime. |
| P0, текст, диагностика | `dev/l2src_sandbox/l1src/{p0.h,own,parser,parser_text}.lm1`; parser-port исходники sandbox | Реальные частичные L2-порты уже есть: `parser_scan_port.lm2`, `parser_alloc_port.lm2`. Но они зависят от рукописных `parser_*_port_l2.h.lm1`, а alloc ещё вызывает неперенесённые `lm_p0_*`. Это не замкнутый порт P0. |
| L2/L3 frontend | `dev/l2src_sandbox/l2trans.lm1`, `l2_application.h.lm1`, `l2_immut_query*.lm1` | L2 fixtures и native/walker parity не являются поддерживаемым L3 frontend. Требуется перенос тела и всех closure-зависимостей, не только driver. |
| L1→C backend и bootstrap | `l1src/{l1trans,printTree,parser,own,libc_abi}.lm1`, `lm1/build/*` | Однократный bootstrap допустим. В обычном цикле эти поддерживаемые вручную L1 не должны оставаться скрытыми входами; generated L1 сохраняется как промежуточный формат. |
| Build/test orchestration | `l1src/{buildCore,make,finalize,build_l1}.lm1`; `tools/run_self_build.ps1`, `tools/build_l2src.ps1`, `tools/l2_harness.ps1`, `tools/run_l3_selftest.py` | Обычный build/check/finalize и внутренние тесты переносит S8.5. PS/Python audit сегодняшнего bootstrap не засчитывается вместо language-owned инструмента. |
| Машинная граница | `l2_libc.lm1`, platform-варианты clock/process/manager; `third_party/decNumber/decNumber-icu-368` | Фиксировать точный выбранный вариант, headers, C/OS import и контракт. Наличие C compiler/OS не разрешает скрытую поддерживаемую L1-библиотеку в closure. |

## S8.2: растущий список (снимок 2026-10-23, Verified176 `75000a3c`; перенос — Verified178)

Источник — `build2/opus_fix176/src`. Это инвентаризация до переноса; его итог — в конце раздела.

- Модуль: `lmx_list_owned.lm1` (217 строк) и `lmx_list_owned.h.lm1` (22). Заголовок списка — `VoidDynamicArray` в пуле
  KIND_LIST арены; ячейки — в пулах вида элемента и профиля заголовка. Операции: `lmx_list_new_owned`,
  `_new_profiled`, `_append_owned`, `_remove_owned`, `_value`, `_len`, `_cap`, `_data`; внутренняя `lmx_list_grow`.
- Под ним — только слой хранения: `lmx_range.lm1` (`lmx_range_home`, `_classify`, `_type_of`, `_profile`) и
  `lmx_arena.lm1` (`lmx_arena_take_profiled`, `_take_n_profiled`, `_pointer_cells_profiled`,
  `_pointer_void_read`/`_write`).
- Над ним — L1-потребители:
  - `lmx_thread.lm1`: список детей потока, 14 вызовов и проверка вида;
  - `lmx_root.lm1`: два списка корня;
  - `lmx_graph_copy_owned.lm1`: копия и квалификация значений-списков, 5 вызовов и 9 ветвей KIND_LIST;
  - `lmx_reparent.lm1`: 1 вызов и 1 ветвь;
  - самопроверка `l2_eternal_driver.lm1` (1) и `lmx_gc_selftest.lm1` (3 вызова и 1 проверка).
- Типы: KIND_LIST (`lmx.h.lm1`), `VoidDynamicArray`, типы списков `LMX_TYPE_ARRAY_OF_LMX`, `_ARRAY_OF_DESC` и
  `LMX_TYPE_ARRAY_OF_POINTER_BASE` плюс домен.

Разрыв: потребители — L1 и вызывают список по C ABI, а граница экземпляра L2 (S8.1) требует графа и вхождения.
Нормативный выбор Codex вынес автору (CODEX-OPUS-S82-MECHANISM-20261023T2136Z). Автор разрешил общий C-совместимый
экспорт машинных функций L2 без обязательного графа и уточнил: прямой машинный вход в существующем генераторе, без
отдельного языка и второго разбора (CODEX-AUTHOR-L2-CABI-EXPORT-20261023T235436Z,
CODEX-AUTHOR-DIRECT-MACHINE-ENTRY-20261023T235752Z; [L2 §20](../docs/L2_spec_ru.md#lowlevel-abi)). Отдельный режим
трансляции модулей и скрытый экземпляр по-прежнему не разрешены.
- Список переносится один: его L1-потребители вызывают перенесённые функции через прямой машинный вход, старое тело
  удаляется.

Перенос (срез 178, [пакет](witnesses/fix178-20261024/notes.md)):
- Вход реализован в существующем генераторе: `l2trans --library --machine NAME ... --header FILE` транслирует
  машинный модуль. Имена `--machine` — его экспорты в заголовке; остальные функции корня — собственные функции модуля.
- Поддерживаемый источник — `src/l2src/lmx_list_owned.lm2`. Его L1-модуль и заголовок пишет сборка
  (`bld_kernel_l2` в `tools/l2/build.lm2`) на месте прежних, старое рукописное тело удалено. Экспортов восемь,
  `lmx_list_grow` остаётся внутренней.
- 30 вызовов L1-потребителей идут через вход: thread 16, graph copy 6, gc self-test 5, root 2, reparent 1. Слой
  хранения под списком (`lmx_range`, `lmx_arena`) остаётся L1 и вызывается дверью C.
- OPEN: C ABI объявленного выхода машинной функции (MACHINE-STATUS-CHANNEL), широкие тесты роста, удаления, адресов и
  жизни mail/root/child (после самосборки), сборка инструмента с новым рецептом (память).
- Срез 179: вызов машинной функции идёт общим связыванием вызова (именованные фактические, лексический порядок),
  операторы машинной функции — C99 (L2 §17, §21). Типы слоя хранения остаются в `.h.lm1`: явное описание машинной
  C-раскладки ждёт решения автора (вопрос Codex), до него они не объявляются перенесёнными.

## S8.3: слой хранения (с Verified180)

Порядок — по зависимостям, малыми шагами: индекс арены, затем пулы, затем арена (ревью Codex
CODEX-OPUS-REVIEW179-20261024T024436Z).
- Срез 180 ([пакет](witnesses/fix180-20261024/notes.md)): индекс арены (`lmx_range`) — машинный модуль L2. Поддерживаемый
  источник — `src/l2src/lmx_range.lm2`, 26 функций в прежнем порядке, 24 экспорта. Сборка (`bld_kernel_l2`) пишет его
  L1 на месте рукописного тела без заголовка: модуль объявляет свои функции сам. Ядро вызывает 22 из них через прежние
  прототипы `lmx_arena.h.lm1`, `lmx_range_keep_chunk` (пулы) и `lmx_range_cell_chunk` (сборщик) — как прежде, после
  модуля в единице трансляции ядра.
- Типы (`LmxArena`, `LmxRange`, `LmxPool`, `LmxChunk`) и прототипы индекса остаются в рукописных `lmx.h.lm1` и
  `lmx_arena.h.lm1`, пока их не пишет код L3 (уточнение автора 2026-10-24; source closure OPEN). Сгенерированному
  заголовку индекса нужен `LmxArena` из `lmx_arena.h.lm1`, а l1trans отказывает циклу импортов, поэтому сначала нужен
  раздел этого заголовка.
- Под индексом — средства доступа арены (`lmx_arena_index_*`) и чанка (`lmx_chunk_*`) и `lmx_source_names_drop`: функции
  C ядра, вызываемые дверью C.
- Срез 181 ([пакет](witnesses/fix181-20261024/notes.md)): типизированные служебные массивы (`lmx_pool`) — машинный модуль
  L2 `src/l2src/lmx_pool.lm2`, 21 функция, все экспорты. Сборка пишет его L1 и заголовок `lmx_pool.h.lm1` на месте
  рукописных; заголовок держит только импорты заголовков, импорт модуля индекса остаётся в модуле. Адрес вложенного по
  значению члена (`@ chunk\cells`) и запись через адрес члена по значению (`array: @ desc\array`) — существующий C ABI.
- Срез 182 ([пакет](witnesses/fix182-20261024/notes.md)): список блоков арены (`lmx_arena_blocks`) — машинный модуль L2
  `src/l2src/lmx_arena_blocks.lm2`, 6 функций, все экспорты, без заголовка; запись блока, тип его освободителя и
  прототипы остаются в `lmx_arena_blocks.h.lm1`. Вызов через указатель на функцию C, который держит машинная функция, —
  роль двери C; вызов C фиксирует фактические в лексическом порядке.
- Срез 183 ([пакет](witnesses/fix183-20261024/notes.md)): менеджер арены (`lmx_arena`) — машинный модуль L2
  `src/l2src/lmx_arena.lm2`, 35 функций, 34 экспорта, без заголовка; сборка пишет его L1 после списка блоков, ядро
  вызывает его через прежние прототипы `lmx_arena.h.lm1`. Тела слоя хранения (индекс, пулы, список блоков, менеджер)
  теперь пишет сборка; их записи и прототипы — рукописные `lmx.h.lm1`, `lmx_arena.h.lm1` и `lmx_arena_blocks.h.lm1`.
- Срез 185 ([пакет](witnesses/fix185-20261024/notes.md)): объявления слоя хранения — `lmx.h.lm1` целиком,
  `lmx_arena_blocks.h.lm1` и `lmx_arena.h.lm1` — пишет код L3 сборки строками L1 (уточнение автора 2026-10-24): функции
  `decl_*` и `decls_write_all` в `tools/l2/build.lm2`, первый шаг `bld_kernel_l2`. Он удаляет прежние заголовки и
  C-заголовки стадии, пишет каждый, отмечает его хеш и переводит C-заголовок до всех потребителей; отказ останавливает
  сборку runtime. Байты заголовков прежние; короткий bootstrap прошёл, рукописные копии удалены со стадии до него.
- Граница (Codex, CODEX-OPUS-ROUTE185-20261024T085140Z): отслеживаемые старые копии этих заголовков в `l2src/` и
  `dev/l2src_sandbox/` — исторические снимки, исходный материал переноса и исторических воспроизведений, а не запасной
  путь обычной сборки и не замена языкового gate. Старый PS/Python gate — не разрешённый обычный цикл, его перенос —
  S8.5. Нынешние `bootstrap quick|full` и `rebuild` берут эти три заголовка только от генератора текущего recipe.
- Срез 186 ([пакет](witnesses/fix186-20261024/notes.md)): первый модуль над слоем хранения — таблица
  интернированных символов (`lmx_chars`) — машинный модуль L2 `src/l2src/lmx_chars.lm2`, 3 функции, все экспорты;
  сборка пишет его L1 и заголовок `lmx_chars.h.lm1` на месте рукописных, последним в `bld_kernel_l2`.
- Срез 187 ([пакет](witnesses/fix187-20261024/notes.md)): собственные таблицы символов (`lmx_chars_owned`, 2 экспорта)
  и массивы ссылок (`lmx_array_ref_owned`, 4 экспорта и своя функция) — машинные модули L2 с заголовками, которые
  пишет сборка, после таблицы интернированных символов.
- Срез 188 ([пакет](witnesses/fix188-20261024/notes.md)): ссылки арены (`lmx_arena_refs`, 14 экспортов) и собственные
  скалярные массивы (`lmx_array_owned`, 7 экспортов и своя функция) — машинные модули L2 с заголовками, которые пишет
  сборка; массивы читают заголовок ссылок.
- Срез 189 ([пакет](witnesses/fix189-20261024/notes.md)): хранилище временных кадров (`lmx_scratch`, 5 экспортов) —
  машинный модуль L2 без заголовка; его заголовок (ответы, записи `LmxScratch` и `LmxScratchMark`, прототипы) пишет
  код L3 сборки (`decl_scratch` в `decls_write_all`), байты прежние.
- Срез 191 ([пакет](witnesses/fix191-20261024/notes.md)): модуль значений (`lmx_value_owned`, 53 экспорта и своя
  функция) — машинный модуль L2 с заголовком, который пишет сборка; `lmx_value_context_copy` объявлен и в рукописном
  `lmx_value.h.lm1`, который читают заголовки обходчика и вызова.
- Срез 193 ([пакет](witnesses/fix193-20261024/notes.md)): имена источника графа (`lmx_source_names`, 7 экспортов и
  своя функция) — машинный модуль L2 без заголовка; его заголовок (запись `LmxSourceName` и прототипы) пишет код L3
  сборки (`decl_source_names`, пятый заголовок `decls_write_all`), байты прежние.
- Срез 194 ([пакет](witnesses/fix194-20261024/notes.md)): физическая разметка и сборка графа (`lmx_gc_graph`, 5
  экспортов и 6 своих функций) — машинный модуль L2 без заголовка; заголовок сборки (`lmx_gc.h.lm1`: ответы, предел
  глубины, прототипы разметки, сборки и собирателя Thread) пишет код L3 сборки (`decl_gc`, шестой заголовок
  `decls_write_all`), байты прежние; тела собирателя Thread (`lmx_gc`) остаются L1.
- Срез 195 ([пакет](witnesses/fix195-20261024/notes.md)): существующий L1-фронтенд хранит один успешный P0-разбор
  каждого файла predef в снимке программы, вместо разбора при каждом запросе. Перевод GC — 2 с вместо 300 с;
  `bootstrap quick` — 0 отказов за 1124 с, прежние L1/C и runtime. Число перенесённых модулей не изменилось (14 из 35).
- Срез 196 ([пакет](witnesses/fix196-20261024/notes.md)): общий адаптер разрешает bare predef рядом с включающим
  файлом, как L1; четыре запроса следуют всем объявленным вложенным зависимостям, без второго parser или поиска
  запасного файла. GC без прямого импорта заголовка блоков проходит L2→L1→C, где195 отказывал на `disposer`.
  `bootstrap quick` — 0 отказов за 1117 с, runtime/модули/заголовки прежние. Число перенесённых модулей — 14 из 35.
- На конец196 остальные входы ядра (21 из 35 модулей единицы трансляции runtime), драйвер и оба транслятора — L1 (source closure
  OPEN). Порядок (Codex): значения и граф, затем copy/merge/call, mail/Thread, walker.
- Срез 190 ([пакет](witnesses/fix190-20261024/notes.md)) — транслятор перед модулем значений (ответы Codex
  CODEX-OPUS-VALUE-OWNED-ROUTE-20261024-A, CODEX-OPUS-RECORD-ADDRESS-ROUTE-20261024-A): локал указателя на функцию и
  по-значению локал C-записи имеют тип значения из своего объявления через дверь C, их адреса — указатели на этот тип.
  Модули ядра не изменились. Затем — модуль значений (срез 191; порядок с именами C Codex переставил), имена C с
  исходным именем после индекса — срез 192.
- Срез 192 ([пакет](witnesses/fix192-20261024/notes.md)) — транслятор: имя C привязки источника — служебный индекс и
  после него имя привязки из набора C (`l2_p0_0_cell`, `l2_q101_words_from`), один производитель на все семейства.
  Двенадцать модулей ядра, которые пишет рецепт, и runtime отличаются от среза 191 только именами; число перенесённых
  модулей не изменилось.

<a id="current-kernel-state"></a>
## Текущий перенос ядра

Проверенный225,2026-10-26 ([пакет](witnesses/fix225-20261026/notes.md)): оставшиеся204 P0 parser bodies
перенесены в ordinary L2; oldmaintained l1src/parser.lm1 удалён. L3 пишет forward/declarations, machine modules
own/text/scan/types/parser/copy-use строятся до frontend. Canonical49+1+1+8+17=76inputs,
в P0list только libc_abi.lm1. Generated26 P0 outputs/headers отсутствовали до coldlaunch.
ONE wholeSHORT0/smoke9-0/G1→G2/start/hash/replace, source15/future3pins языком иGNU0/EXE-SAME1.
MM9frontend/39runtimeheaders толькоcoldgenerated; generated59 не означаетconsumed59.
Qualified225 construction/copy/receiving transport включён, но actual/named/default/result/exits
и общий logical receiving/Consumer signature admission остаются OPEN. Artifact53 языком/GNU0;
compiler/backend/driver/libc/tooling, immutable/native effects и настоящая sourceclosedS8.6/mail OPEN.

Далее — исторические срезы переноса.

Verified203 `912fb510`. После исторического снимка196 перенесены `lmx_implements` (197), `lmx_graph_copy_owned` (198),
`lmx_merge_owned` (199), `lmx_call` (200), `lmx_post` (201);202 переноса не добавлял, а перенёс три backing precheck
под существующий monitor.203 переносит `lmx_clock`, `lmx_process_deadline`, `lmx_schedule`: итого22 из35
runtime-модулей. Поддерживаемые источники этих модулей — L2; их L1 пишет обычная сборка. Заголовки
clock/deadline/schedule печатает L3,15 писателей до потребителей; прежние L1/C-байты заголовков сохранены.
[Пакет203](witnesses/fix203-20261024/notes.md) связывает исходные патчи, рецепт, команды и реальные значения;
один короткий bootstrap0, smoke6/0, G1 строит G2,32 равенства и манифест148 проверены.

204 (Verified204 `d7cfc918`, [пакет](witnesses/fix204-20261025/notes.md)) переносит `lmx_turn` и `lmx_settle`:9 функций,6 публичных входов,
17 L3-писателей до потребителей, прежние L1/C заголовки. Один короткий bootstrap0 за наблюдённые1414с, smoke6/0,
G1 строит G2;26 равенств/нормализованный EXE/манифест135 проверены. Реальный native-свидетель сохраняет адреса при
attach и читает43 после изменения,0 ошибок; новый фронтенд даёт те же исполненные L1/C. Итого24 из35 модулей.

205 (Verified205 `737d6cec`, [пакет](witnesses/fix205-20261025/notes.md)) переносит service/manager:29 функций/23 публичных входа.
19 L3-писателей, прежние L1/C заголовки; uintptr_t-порядок и состояние registry/API/owner явные. Один короткий
bootstrap0 за наблюдённые1438с, smoke6/0, G1 строит G2;26 равенств/нормализованный EXE проверены, манифест144 —
языковым verifier и независимым sha256sum. Native-свидетель сохраняет attach/43 и даёт callback-count1→0/routes1/failed0; новый фронтенд даёт те же
исполненные L1/C. Итого26 из35 модулей, без изменения языка/компилятора/допуска.

206 (Verified206 `09114b1d`, [пакет](witnesses/fix206-20261025/notes.md)) переносит running manager/OS lane:18 функций L2,
14 публичных входов и2 OS-callback.20 L3-писателей до потребителей, прежние L1/C заголовки, явное состояние
manager/API/Thread/schedule и прежний per-OS-thread контекст ещё не перенесённого Thread. Один короткий bootstrap0
за наблюдённые1517с, smoke6/0, G1 строит G2;24 равенства/нормализованный EXE и манифест116 проверены,
последний также независимым sha256sum. Реальная OS-полоса пишет42→43, main/worker разные, ready1/count1/failed0;
новый фронтенд воспроизводит исполненные L1/C без повторной C-сборки. Итого28 из35, без изменения компилятора/языка/допуска.

207 (Verified207 `24fe2c48`, [пакет](witnesses/fix207-20261025/notes.md)) переносит child/orphan/собиратель Thread:18 функций L2;
22 L3-писателя до потребителей, прежние L1/C заголовки, общий graph marker и явное владение.
Один короткий bootstrap0 за наблюдённые1577с, smoke6/0, G1 строит G2;30 равенств/нормализованный EXE,
манифест144 языком и GNU. Native-свидетель: before0→after1,copy43/source42,adopted1/old0,
held1/released0/reclaimed1, GC generation1/1,failed0; новый фронтенд воспроизводит исполненные L1/C без C-пересборки.
Итого31 из35; компилятор, язык и допуск прежние.

210 (Verified210 `e35d761c`, [пакет](witnesses/fix210-20261025/notes.md)) переносит reparent/Thread/Root одним общим срезом:
122 функции L2/96 публичных C-входов;25 L3-писателей и отдельная прежняя TLS-декларация до потребителей.
Общий адрес C-ячейки и существующая selected-os identity, без новой грамматики/допуска/скрытого owner graph.
RED01 missing Thread header сохранён; исправленный рецепт сначала пишет все L1 headers, затем переводит C.
SHORT02 exit0 за наблюдённые1631с, smoke6/0, G1 строит G2;32 равенства/EXE-SAME1, манифест188 языком и GNU.
Native: reparent29→57/other11, Thread binding1/1/errno61→62/lane43, Root42→43/other100/report/close0/failed0;
новый frontend даёт исполненные L1/C без C-пересборки. Все4 S8.1-вывода прочитаны, прежние значения.
Итого34 из35 runtime-модулей; отдельные Verified208/209 не заявлены. Walker и его globals/явная защита мест OPEN.

211 (Verified211 `11bc76bc`, [пакет](witnesses/fix211-20261025/notes.md)) переносит28 stateless value/storage/numeric функций обходчика в L2;
старые тела удалены,100 функций engine ещё L1. Recipe5DBF5B5D использует существующий machine step/header,
25 L3-писателей прежние. Native:41→42/snapshot41, size_t18446744073709551614→18446744073709551613,
present-null1, char refusal1/65/temp43, sum42/overflow12/division12,failed0. Прежние Reparent/Thread/Root случаи проходят.
SHORT terminal marker0 failures/smoke6/0, G1 строит G2, оба start/hash/replace,20 равенств/EXE-SAME1;
манифест127 проверен языком и GNU. Внешний exit после потери exec handle не восстановлен и не подменён отчётом.
Итого по-прежнему34/35: это историческая инвентаризация тел текущего runtime TU, не всех L1 файлов или заголовков.
Живые Message/value/primitive/walker/platform headers, реальные program/test dependencies и позднее подключаемая
delivery closure ещё требуют переноса; наличие legacy-файла само по себе не доказывает его участие или завершённость.

212 (Verified212 `6ecea001`, [пакет](witnesses/fix212-20261025/notes.md)) закрывает измеренный native bypass: метод другого unit без собственных
qualified constructions писал через int* в sealed y2→3, тогда как genuinely walked provider отказывал INVALID.
Общие existing graph-store/publication guards теперь зависят от физического профиля, не inventory текущего перевода.
Direct-machine ABI без скрытой арены сохранён; новый syntax/parser/library-only comparator не добавлен.
Тот же host.o с новым native provider даёт INVALID/exit3; ordinary FE воспроизводит исполненные L1/C rawcmp0.
Один полный SHORT212 exit0 за1658 наблюдённых секунд, smoke6/0; G1 строит G2, оба start/hash/replace;
25 равенств/EXE-SAME1, manifest148 проверен языком и GNU. Runtime C/prod/observe raw-равны211,
25 L3-писателей и34/35 body counter прежние. Это не весь C-effect/admission/native контракт и не S8.6.

213 (Verified213 `e352b290`, [пакет](witnesses/fix213-20261025/notes.md)) переносит11 оставшихся Lmx declaration headers в L3-строки рецепта:
36 writers+9 API=45 Lmx headers из50,5 parser/frontend headers остаются. Все L1 до C; error paths не восстанавливают старые копии.
10 L1 raw-равны, deliver лишь без3-байт BOM; все11 C raw-равны212. Изначальный35-pin RED сохранён, нормализованный reference независим.
GCC-MM выбирает39 kernel headers только generated213. Один SHORT outerexit0 за1731 наблюдённую секунду, smoke6/0/G1→G2,
оба start/hash/replace/working-G2 rawcmp0;39 pins/EXE-SAME1, manifest138/0DA1C17E проверены языком и GNU.
Реальные4 S8.1-вывода прежние. Это staged декларации, не canonical/dev интеграция;100 engine тел/globals,34/35 body counter и S8.6 OPEN.

214 (Verified214 `40914045`, [пакет](witnesses/fix214-20261025/notes.md)) переносит18 classification/throws/construction fn в L2:
46 exports;82 fn+1sub и3globals остаются L1,34/35 body counter не увеличен. Qualified/retained guards прежние.
Native03 key9/ordinal1/implicit1-2/classified3,OP53->111/sealed отказ1/failed0; прежние value/Reparent/Thread/Root проходят.
Новый FE повторяет исполненные L1/C, ordinary module/API/Cheader rawcmp0; потерянный direct CCexit не выдуман.
Один SHORT214 outerexit0 за1768 наблюдённых секунд, smoke6/0/G1->G2/start/hash/replace/working-G2 rawcmp0.
47 заданных до целей pins/EXE-SAME1 и manifest124/99F56B92 проверены языком и GNU. Canonical witness9D6C468D обновлён после terminal.
Это partial walker closure, не полная source/header/canonical integration или clean/native/admission/Q49/S8.6/mail.

215 (Verified215 `6c479303`, [пакет](witnesses/fix215-20261025/notes.md)) переносит ещё17 source-check/order/activation-place/native-result fn в L2:
63exports,65fn+1sub/globals остаются L1;34/35 counter прежний, compiler/ABI/admission/guards не менялись.
Native01 CC/RUNexit0, прежние41->42/snapshot41/wide-2->-3/key9/sealed refusal1/failed0; новымFE получены те же L1/C без пересборки EXE.
Один SHORT215 outerexit0 за1752 наблюдённых секунд,smoke6/0/G1->G2/start/hash/replace/working-G2 rawcmp0.
16pins/EXE-SAME1 и manifest179/65736FD9 проверены языком и GNU; все4 S8.1 значения прежние.
Это partial walker closure; source reachability13/17 не индивидуальное runtime coverage. Draft216 не принят здесь.

Verified216 `201938e9` ([пакет](witnesses/fix216-20261025/notes.md); bootstrap/manifest/main readback подтверждены) переносит35 существующих тел (19+16) в L2:
63→98 exports, sourceB06AEC80/engineDD67F970/recipe8604B631;31 top-level L1 fn,3globals и ifdef-observer остаются.
Qualified/retained guards сохранены. Прототип walk.h реально печатает L3 до потребителей: L1B4663C8E/C578553C.
Native216 FE02/L1exit0/C2F9568D5, один strictCC02 exit0 за6.896с/EXE71D4A454/RUN02exit0; прежние реальные значения проходят.
Ordinary FE09098687 воспроизводит исполненные L1/C без новой C-сборки. Runtime CA0912871/prod5194C29A/observe61448AE1.
Один SHORT216/session7840:12:54:11→13:26:01 UTC/1910 наблюдённых секунд, actual outerexit0,smoke6/0/13checks0roots.
G1 реально строит G2, оба start/hash/replace; G11AD68095/G2+working708A39F4, working/G2 rawcmp0,
L1E556B77A/C1AB8B2BB raw-равны seed/peer, EXE-SAME1/session13864 exit0; final17pins language74992 exit0/GNU0.
Все4 S8.1-вывода прочитаны:41/41/42/42/43/42,A1=101/A2=43,runtime142/field map/отказы30/33/34(y2)/callable3→8.
Это два owner EXE/восемь library objects на production runtime, не четыре owner-компиляции. Frozen215 не менялся.
Finalmanifest565 language51767/81843 и GNU0, SHA C284542E;9patchreceipts -U0/replay raw-equal, не новые сборки.
Push/fetch/ls-remote main/90 owned paths/13 raw Git blobs подтверждены; это не полная source/native/admission/Q49/S8.6/mail closure.

Verified218 опубликован `98ee7764c938df6907014027edfba71613c5562a` ([пакет](witnesses/fix218-20261025/notes.md));
push/fetch/ls-remote main и132 exact owned raw Git blobs совпали с закреплёнными локальными байтами.
Единый перенос25 тел (draft21719 +2186) даёт123 exports/6 remaining top-level L1 fn/3globals/ifdef-observer;
source6569145D/engineFEED32E6/recipe6FEE6135. Отдельного bootstrap217 нет, qualified/retained guards не сняты.
Native218 один strictCC01 exit0 за6.758с/EXE951E0125/freshRUN01exit0 сохраняет реальные значения/failed0.
Ordinary FE9E288AA9/source09649180/C0C476E32 воспроизводит исполненные L1/C11715967/8FD4ABDC,
GNU rawcmp0 и language2pins PASS, без C-пересборки/повторного исполнения. Native helpers не названы genuinely walked.
Один SHORT218/session36182:13:55:48→14:26:12 UTC/1824 наблюдённых секунд, actual outerexit0,smoke6/0/13checks0roots.
G17F3E7943 действительно строит G2+working3DB51437, оба start/hash/replace, working/G2 GNU rawcmp0;
L179B5C38E/C7DB772AD pinned independent seed до G1 и peer до обоих G2 outputs. Final17pins language9684/GNU0 PASS.
Runtime C4E4DB5AA/prod7098BDC6/observe199B506D. Четыре existing S8.1-лога прочитаны:
41/41/42/42/43/42/counts42/42/43, A1=101/A2=43, runtime142/p.y42/p.x1/p.pad9/q.w10,
отказы30/33/34(y2)/callable3→8; линковка production, не observed. Не заявлены25/25 body coverage или полная приёмка S8.1.
Полные35 LM2 добавлены в `dev/l2src_sandbox/`:34 raw-equal frozen218, walker values лишь без2 EOF LF
(stage6569145D→canonicalDEC369EB);70 точных path/hash pairs language7794/GNU0 PASS.
На checkpoint218 это source-control promotion, ещё не canonical preparation; handwritten compiler/P0 остаются.
EXE-SAME1/70522 exit0; manifest612/110AB3D9 generation72019/language44765/GNU0; публикация218 подтверждена.
Draft219, external BASE/mixed bootstrap, globals/retention,
source/native/admission/Q49/S8.6 и весь §§8/8a результат остаются OPEN.

### Canonical preparation219: маршрут, не приёмка S8.6

[Пять поддерживаемых списков](../tools/l2/inputs/README.md) выбирают 73 файла из репозитория:
44 из `dev/l2src_sandbox/` в `STAGE/src/l2src`, 7 из его `l1src/` в `STAGE/src/l1src`,
1 driver из его `harness/` в `STAGE/src`, 8 из `tools/l2/` в `STAGE/tools` и 13 из `tests/l2/` в `STAGE/tests`.
Это данные для уже существующих языковых `manifest` и `stage-copy`, не новый preparation runner.
В cold219 эти команды подготовили новую пустую стадию без 45 прежних L1-заголовков,
35 generated module bodies, generated TLS и C-заголовков. Выбор 73 файлов не означает,
что каждый из них прочитан каждым потребителем или что 13 test files замыкают полный набор.

Runtime-модули и генерируемые заголовки обычный `bootstrap quick` получает из явно подготовленных источников:
source-first pass создаёт frontend C headers, L3-писатели выпускают 36 L1 declarations/TLS,
полный machine-перевод создаёт 35 модулей и 9 APIs,
после чего общий header pass создаёт C headers до runtime-потребителей. Старый module/header LM1 не выбирается
при отсутствии результата или ошибке генерации. Итог всего SHORT/G2 фиксируется отдельно в
[пакете219](witnesses/fix219-20261025/notes.md); этот маршрут не утверждает его terminal PASS.
Seed-инструмент с прежними bootstrap headers/runtime — явная граница bootstrap, не source-closed seed.

`tools/build_l2src.ps1` и `tools/l2_harness.ps1` остаются отдельно запускаемыми legacy gates:
они копируют старые handwritten LM1 и исполняют прежние assertions, но текущий language-owned bootstrap/rebuild
их не вызывает и не использует как error-path fallback. Их fixtures/assertions сохранены и ещё требуют переноса
по S8.5; короткий bootstrap не объявлен полной заменой этих gates. Исторические LM1-снимки в dev/root также
не становятся входами обычной сборки только из-за присутствия в дереве.

Handwritten compiler/API, residual walker, P0/libc ABI и driver перечислены явно; внешний backend,
BASE support/libc object, оставшиеся tools и полная тестовая closure ещё не перенесены.
Canonical preparation не закрывает эти долги и не является настоящей S8.6.

Verified219 опубликован722b30dce0a9c71027494dffa232bb2bbf60c8a8:одинcoldSHORT0/smoke6-0/G1→G2,
обаstart/hash/replace;G1/G2L1/C/objectrawcmp0,EXE-SAME1,17pins/manifest711 языком иGNU.
ActualL3writers→generatedheaders→39выбранныхGCCkernelheaders иpositiveobservedобычныеos_mix/os_twice подтверждены,
безстарыхkernelheaderinputs/новогоL2mechanism. Push/fetch/ls-remote и140ownedrawGitblobs совпали.
Canonicalvaluesпослеисполнениятолькобез2EOF-LF(AE3FA5F8→C2B3D29C);actualstage/manifests не переписаны.

Оставшийся runtime-обходчик, драйвер, P0 и оба транслятора, build/test/doc tooling ещё не образуют поддерживаемую
L3/L2 closure. Стадийные generated L1/C не запрещены, но оставшиеся handwritten L1 не считаются generated.
G1/G2 bootstrap-инструмента не закрывают S8.6. Далее walker с явным контекстом/qualified-root защитой,
без C shim, скрытого owner graph, runtime name lookup или удаления write guards; затем toolchain/canonical integration.
Общий runtime-callable/Q49 и mail T01–T26 также OPEN; широкая кампания не подменяет перенос к самосборке.

### Срез226: SOURCE/ABI carrier, не полный допуск

Проверенный226,2026-10-26 ([пакет](witnesses/fix226-20261026/notes.md)): объявленные входы и результат
вызываемого сохраняют активный receiving SOURCE и точный физический ABI witness обычной парой в заголовке.
Поддерживаемый producer — `l2_receiving_source.lm2`; callback declarations печатает L3 writer44 до его потребителей.
Ledger удаляет31 generated target до регенерации; нового L2 syntax/parser/layout mechanism нет.
Читатель раскрывает пару только в контексте header entry; это перенос контракта, не его полный аналитический допуск.

Текущие списки выбирают50+1+1+8+17=77 maintained inputs. Пять изменённых source-файлов и строка runtime.list
публикуются отдельно от frozen cold77: P0 стадии сохраняет известный225 EOF blank line
(272DC7F7 против canonical872A0144), поэтому raw-равенство всех77 canonical inputs не заявлено.
Один SHORT226/session80535 завершён с actual outerexit0,smoke9/0; старт04:53:59 UTC,
terminal наблюдён05:27:58 UTC.
G1 действительно построилG2, оба start/hash/replace; рабочий binary raw-равен соответствующему поколению.
Три заранее заданных G2 L1/C/object pins проверены языком иGNU0, EXE-SAME1/exit0.
Serial GCC-MM выбирает11 frontend и39 runtime headers только из generated component03;
созданные16/61 headers не названы16/61 прочитанными. Повторной компиляции для dependency readback нет.

Полные actual/named/default/Consumer-result/exits demands, общий runtime-callable/Q49, immutable effects и
uniform native остаются OPEN. Compiler/backend/driver/libc/tooling ещё дают mixed bootstrap, не source-closedS8.6;
mailT01–T26 также OPEN. Сохранение SOURCE и точного ABI — основа следующего общего admission шага, не его приёмка.

### Срез227: конкретные CALL и coverage coordinates

Проверенный227,2026-10-26 ([пакет](witnesses/fix227-20261026/notes.md)): ordinary L2 producer
сохраняет original written path-call и полный source environment; существующий PLACE связывает role4.
Шестой slot receiving record получает обычные graph refs на Consumer-code/CALL и точную координату coverage.
COUNT/PLACE/FILL выделяют один `1+5*n` holder, end-of-view fixup не создаёт и не исполняет ещё один CALL.
Result/exits пока null; checker slot5 ещё не читает, поэтому общий signature admission не принят.
L3 writer45 печатает9 callback declarations;36 generated targets удаляются до потребителей, нового syntax/parser нет.

Selection51+1+1+8+17=78. Шесть source-дельт и runtime.list продвинуты exact candidate bytes;
originalfuture3 и canonical7: G2language final10/0failed, GNU0. Patchfrom226 GNU--fuzz0/7pins0.
Один SHORT12137 actualouter0 за2065.5299907с,smoke9/0; G1CC23AA03 строитG248030C0E,
оба start/hash/replace/workingrawcmp0, EXE-SAME1. SerialMM выбирает13frontend/39runtime толькоgenerated.
Existing owner EXE без пересборки читает actual carrier width31/count6/coordinate2/code/CALL/null demands:
143checks0roots/exit0 и те же mutable S8.1 values. Raw52 selected Cheaders включены в binding.
P0 теперь exactcanonical872A; inherited native_closure_values snapshot225/226 остаётся отличным — all78 equality нет.

Consumer data home, independent required/provider homes, actual/named/default/conversion/result/exits,
root-formal/forwarded contexts, runtime-callable/Q49 и immutable/native effects OPEN.
Compiler/backend/driver/libc/tooling ещё дают mixed bootstrap; sourceclosedS8.6 и mailT01–T26 не закрыты.

### Срез231: helpers драйвера без старых L1-тел

Проверенный231,2026-10-26 ([пакет](witnesses/fix231-20261026/notes.md)):25 explicit-argument
helpers драйвера перенесены в `dev/l2src_sandbox/l2_driver_shape.lm2`,22machine exports/3private.
В maintained harness32 тела вместо57; прежние58 process globals сохранены, не названы
устранённым ambient-state долгом. Runtime inventory получает один L2 input:
47+1+1+8+17=74. Пять compiler declaration headers уже генерирует L3 после229,
они больше не maintained inputs. Нового L2 механизма или helper-body fallback нет.

Source-only cold74 не получал generated seed headers. Один corrected SHORT54130
завершён0 за2129.0090553с,smoke9/0; G14B545D80 строитG27E9586D4,
обаstart/hash/replace, rawL1/C/object equality/EXE-SAME1. SerialMM13frontend/40runtime
выбирает stage-generated Cheaders, включая новый helper API, не прежний source root.
Source74 и future2 pins подтверждены языком/GNU; canonical3 raw-равны candidate,
helper00D3332A отличается от исполненногоA808 только тремя удалёнными EOF LF.
Inherited native_closure_values snapshot остаётся отдельно привязанным, all74 equality нет.

Это source-port с прежними четырьмя S8.1 значениями, не выполнение всех25 helper bodies
или clean-native/admission closure. Initial cold02 refusal и warm diagnostic03 variants
сохранены отдельно от actualcold04. Следующий полный driver source-only batch ещё не проверен;
compiler/backend/libc/tooling, common admission, sourceclosedS8.6 и mailT01–T26 OPEN.

### Frontend helpers233

[Срез233](witnesses/fix233-20261026/notes.md) переносит248 helpers/249platform bodies
из maintained frontend в `l2_frontend_helpers.lm2`; API и body пишет существующий
machine-перевод до receiving/Consumer/frontend consumers. Остальные2072 тела
frontend остаются handwritten L1. Старые helper bodies удалены; новых L2 grammar,
checker/admission правил или storage нет. Canonical selection48+0+1+8+17=74
включает новый helper;48 runtime/compiler inputs совпадают с исполненными cold bytes.
Whole SHORT0/smoke9-0/G1→G2/start/hash/replace, EXE-SAME1; serialMM14frontend/40runtime
читает только cold-generated headers. Это не source-closed S8.6.

### Allocation helpers234

[Срез234](witnesses/fix234-20261026/notes.md) переносит ещё20 функций в ordinary
L2 `l2_frontend_alloc.lm2`; прежние тела и20 prototypes удалены, остаются2052
frontend definitions.32 local aliases обращаются к тем же19 cells перед body
import; новых storage/grammar/admission правил нет. Recipe05095665 переводит
20 exports до receiving/Consumer/C consumers и очищает52 generated targets.
Selection49+0+1+8+17=75; все49 runtime/compiler inputs raw-равны cold bytes.
Whole SHORT41954 terminal0/smoke9-0, G1→G2/start/hash/replace, EXE-SAME1 и
source75/expected2/canonical5/runtime49 language/GNU0. SerialMM15frontend/40runtime
читает только generated headers. Frontend/backend/libc/tooling и S8.6 OPEN.

### Value and ownership helpers235

[Срез235](witnesses/fix235-20261026/notes.md) переносит150 старых функций
в ordinary L2 `l2_frontend_values.lm2` F2CE48ED; private helper принимает
прежний C long результат ftell без нового языкового механизма.123 старых
prototypes удалены,1902 frontend definitions и732 storage остаются.
134 aliases обращаются к тем же26 cells. Recipe8A63048A генерирует150exports
до consumers и очищает55 targets; incoming Machine/Consumer calls используют
тот же ABI. Ordinary selection50+0+1+8+17=76, все50 runtime/compiler inputs
raw-равны выполненным cold bytes; maintained libc ABI пока остаётся входом.

Corrected cold04 whole31515 terminal0/smoke9-0, G1→G2/start/hash/replace,
EXE-SAME1; source76/expected2/canonical6/runtime50 language/GNU0 и replay6--fuzz0.
SerialMM16frontend/40runtime выбирает только generated headers. Прежние4
owner logs сохранены, без general graph-built admission/bodywalk claim.
Следующий L3 ABI writer и265 helpers пока приватная подготовка; их исходники
не подменяют подтверждённую closure235. Frontend/backend/libc/tooling,
clean native/Q49, source-closed S8.6 и mail остаются OPEN.

## Что требуется перед G0

1. Принять зависимости §3, включая единые native/walker semantics.
   Ни зелёный kernel, ни старый L3 adapter по отдельности этого не доказывают.
2. Раскрыть таблицу до **каждого** production-источника и test-tool source:
   старый путь → поддерживаемый L3/L2 → generated L1/C/header → импорты →
   конкретный тест. Для одинаковых логических имён указывать реальный корень.
3. Из фактических команд компиляции/линковки и staged manifest проверить
   транзитивность: ни один header, object/archive, parser ABI или build helper
   не должен скрытно возвращать рукописный L1. Каждый OS-вариант учитывается
   явно; параллельных авторитетных старого и нового тела не остаётся.
4. S8.6 сохраняет два **факта самозамещения**: G0 строит/проверяет/заменяет
   себя на G1, G1 повторяет это для G2, из поддерживаемых L3+L2 исходников.
   Совпадение C/бинарников полезно, но не заменяет этот факт.
5. После принятого §8 выполнить S8a и T01–T26 через общую почту и повторить
   самосборку/mail regressions. Удаление L1 из одного wrapper не закрывает цель.

Итоговая приёмка остаётся в [плане v3](../next_core_tasks_v3.md), а конкретные
гейты, текущий writer/build и следующие зависимости — в [рабочем журнале](current.md).
