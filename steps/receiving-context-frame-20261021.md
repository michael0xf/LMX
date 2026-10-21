# Текущий receiving context и стабильный допуск: private94/95

Ненормативный checkpoint, 2026-10-21 UTC; продолжение
[typed giving92/93](receiving-giving-context-20261021.md).
Codex — единственный writer/build; goal ACTIVE/unlimited, существующий
часовой `lmx-goal` ACTIVE. Public dev остаётся `0b8c6ded`.
Это проверенные частные изменения, **не завершённая frontend-интеграция**
и не подтверждение всего общего алгоритма путей.

## Один текущий формат, один аналитический механизм

Private94 сохраняет ADMIT5 `[head, record, letter, value, targetModel]`.
Обычная receiving-запись теперь имеет пять полей:
`[catalog, coverage, mode, requiredReferences, sourceContext]`.
Последнее поле отсутствует (`0`) либо содержит обычную двухпольную
Structure `[currentGivingModel, sourceReferences]`. Это графовые адреса,
переписываемые общей copyMap, не имя, opcode, копия предка, origin кандидата
или разрешение выбрать первую подходящую интерпретацию.

`lmx_implements_admit_receiving_frame` проверяет текущий формат и полный
source-reference table, затем тот же catalog decoder передаёт контекст в
`lmx_implements_admit_templates_typed` и общий `admit_operation`/DFS.
Present-but-malformed context не превращается в отсутствие контекста.
Старый record4 отвергается: запасного старого decoder не добавлено.

Оба compiler producers (`l2_rw_receiving_record` и
`l2_emit_receiving_seed_record`) переведены на одинаковый record5;
`l2_emit_receiving_cells` записывает его поля одинаково. **Оба пока явно
передают sourceContext=0.** Значит, нового автоматического выбора giving
Model из исходной L2-программы ещё нет. Формат и общий kernel не заменяют
producer полного typed source-expression result.

Из93 в94 изменены только `lmx_implements.lm1`, `lmx_walk.h.lm1`,
`l2trans.lm1` и `tests/lmx_walk_admit_use_selftest.lm1`:
[точный delta94](witnesses/used-scope-20261020/receiving-context-core94-from93.patch).
Patch проверен `git apply --check` против exact93 в
`build/codex_context95_patch_check_01/before94`; executed files не менялись.

## Manual positive и полный kernel94

Manual ADMIT fixture перенесён с90/02 на record5. Перед старым positive
«the giving place's own declaration decides when its entry answers»
записываются actual E Model и пустая таблица source references; после
этого случая контекст очищается. Все58 predicates и labels сохранены,
ни один положительный oracle не заменён отказом.
[Port от прежнего tracked fixture](witnesses/used-scope-20261020/receiving-context-admit-port.patch).

`build/codex_admit94_values_01.ps1`:58/0/broken0. Он предшествовал добавлению
полной validation source-reference table; окончательный full kernel94
проверяет уже исправленные байты. CALL-data94 — только allocation
receiving record4→5; прежние79 predicates GREEN в отдельном запуске.

Frozen full kernel94 завершился **327 OK, 0 FAIL**:
`build/codex_impl94_kernel_01.ps1`, input
`build/codex_impl94_kernel_input_01`, output
`build/l2src/codex_impl94_kernel_01`. Worker PID15792,
startUTC `2026-10-21T01:20:03.5204003Z`; прежняя session79881 терминальна.
Вход —3209 tracked public files,14 private overrides, CALL79 и ADMIT58
ports. Это pinned-L1→C kernel gate, **не L3/L2 self-build**.

Actual compiler94 `build/codex_catalog94_build_01/l2trans.exe` собран из
stage94:194 прежних compiler assertions GREEN. Унаследованные подписи
compiler86/runtime84 в helper output не определяют реальные argv/байты;
проверять пути recipe и сохранённые source/C/object, не эти подписи.

## Обычный context, глубокие пути и copyMap

`build/codex_context94_values_02.ps1`, actual runtime94/01:

- [frame witness](witnesses/used-scope-20261020/receiving-context-frame.c):23/0.
  Несколько настоящих D/E maps при origin0; E даёт actual9, write41 и
  address-write43, sibling7 сохранён. Malformed source Model/reference
  table не проходит даже после установленного target proof. Отсутствие
  контекста не выбирает из несовместимых views; record4 отвергается.
- Та же fixture проверяет общий graph-copy: context ссылается на copied
  Model, а не исходный; после освобождения исходной арены copied admission
  и реальные значения/адрес остаются правильными.
- [mixed-frame adapter](witnesses/used-scope-20261020/receiving-context-mixed.c)
  запускает прежние528 predicates через ordinary record5 вместо vector API:
  до129 чередований Structure/Array/index/reference, ordinal/LAST, глубокий
  атомарный отказ. Adapter **только тестовый**: переносит уже готовые cells,
  не разрешает путь. Native и walker production не получили отдельной ветки.
- Прежние vector mixed528, indexed10, typed557 и full16/current83/
  reference112/dependencies39/refinement48 GREEN на actual94.

Эти C kernel tests не объявляются исходными L2 forced-walker witnesses.
Три C witnesses сохранены побайтно; у `receiving-typed-kernel95.c`
убрана только одна лишняя пустая строка EOF ради `git diff --check`.
Исполненный raw source сохранён отдельно и pinned. Локальные quoted
includes указывают на конкретные прежние build fixtures из terminal receipt.

## Private95: reuse определяется текущим принимающим требованием

В92/93 ошибочно было добавлено `source = 0 &&` перед shortcut полного
receiving proof. Поэтому даже прежнее полное `(value, requiredModel)`
с неизменным текущим required contract проходило всю аналитику снова,
если caller передавал giving context. Это противоречит
[стабильности установленного соответствия](../docs/LMX_semantics.ru.md#correspondence-stability).

Giving namespace нужен, чтобы впервые выбрать соответствие; он не является
новым требованием уже принятой полной receiving role и не даёт права
заменить её физические координаты. В95 удалено только это условие;
current `contract_matches`, required references и pending compatibility
остаются обязательными. Никакого нового context key, второй карты или
повторного анализа кандидата ради cache reuse не добавлено.
[Delta95](witnesses/used-scope-20261020/receiving-stable-core95-from94.patch)
проверен против exact94. Утверждение прошлого checkpoint92/93 о необходимом
новом context key — историческая гипотеза реализации, не норма; этот
контроль её опроверг.

Один и тот же новый [typed stable16](witnesses/used-scope-20261020/receiving-typed-stable.c)
на actual94 даёт16/4, на actual95 —16/0. Проверены vector и frame routes:
повтор с E, затем D сохраняет прежний proof/map; новая required pair и
изменённый **текущий** required primitive type по-прежнему отказывают.
Как и старый stable16, тест намеренно меняет raw primitive representation,
чтобы отличить cache reuse от повторного обхода; он не разрешает обходить
admission нормальной записи ветви и не читает char как int.

В самостоятельно добавленной557 fixture92 два последних root predicates
ранее требовали отказа при D после полного допуска через E. Эти два oracle
исправлены: YES при **побайтно неизменной** принятой entry, без append или
замены карты. Остальные555 predicates сохранены. Это не «неизменённые557».
[Исполненная fixture95](witnesses/used-scope-20261020/receiving-typed-kernel95.c)
содержит также прежний pending alias-conflict: два противоречащих впервые
подготавливаемых child maps в одной операции всё ещё атомарно отвергаются.

`build/codex_context95_values_01.ps1`: typed-stable16, framed-mixed528,
frame23, vector-mixed528, indexed10, исправленная typed557 и старые
full16/current83/reference112/dependencies39/refinement48 GREEN.
Full kernel95 также **TERMINAL327 OK/0 FAIL**, actual exit0:
`build/codex_impl95_kernel_01.ps1`, input
`build/codex_impl95_kernel_input_01`, output
`build/l2src/codex_impl95_kernel_01`. Worker PID5644,
startUTC `2026-10-21T01:32:23.6697237Z`, session16930 закрыта.
Результат95 получен собственным полным прогоном, не выведен из результата94.

## Исходные программы и остающаяся граница

Compiler94/runtime95 реально заново сгенерировали L1/C и собрали все
program objects под record5. Старые compiler86 objects с record4
**не переиспользованы**.

`build/codex_catalog95_values_01.ps1`:16 fixtures/32 root cells GREEN.
`build/codex_catalog95_consumers_01.ps1`:21/42 GREEN.
`build/codex_catalog95_mixed_01.ps1`:19/76 GREEN. Итого150 прежних
source/root value cells, включая write/address, copies, mixed paths и
отказы с сохранением прежних данных. В forced-method варианте ordinary
fixtures имеют один machine door; hidden fixtures — два door/launcher.
Multiclass machine-only implementations отдельно отмечены recipe и не
объявляются чистыми walked bodies.

Положительный `receiving-declared-giving-view.lm2` заново выполнен отдельно:
compiler94/runtime95 **RED4/4**, expected7, actual1, graph bindings9 native
и2 forced walk. Точный output
`build/codex_catalog95_nested_declared-giving_02`; oracle не менялся.
Не включать эти четыре RED в150 GREEN и не выдавать ручной ctxE за
автоматическую передачу типа из исходной программы.

Следующий зависимый срез — общий retained typed result: текущий logical
Model отдающего места **отдельно** от possible physical schema/layout,
его projection из выбранного callable/own/formal/capture/node/copy и
каждого reference/index шага. Обоим backend нужен этот resolved result,
не повторный разбор, source.schema как origin или named-only E patch.
Source result и source-reference Model addresses должны переноситься
согласованно через COUNT/EMIT и текущее code/data, включая composed и
callable-result namespaces. Полный Array pointee contract, пустые/короткие
exemplars и вычисляемый индекс также OPEN.

Запущен новый frozen full L2 gate:
`build/codex_catalog95_full_01.ps1`, вход
`build/codex_catalog95_full_input_01`, tools
`build/codex_catalog95_full_tools_01`, output
`build/l2_harness/codex_catalog95_full_01`.
Worker PID12064, startUTC `2026-10-21T01:38:26.2987539Z`, session63720.
Он использует compiler94/runtime95, заново строя compiler и driver.
У прежнего full63 harness изменён только sandbox path, **все source и
metadata oracles сохранены**, в том числе старые внутренние60/773-check
ожидания. Отказы изменившейся внутренней representation предстоит
классифицировать отдельно, не подменяя ими source failures. До terminal
summary и сравнения FAIL-ID прежние3752/1003 не объявляются новым
результатом. Public promotion, v3, self-build и mail не закрыты.

## Terminal receipt

`build/codex_context94_95_terminal_03.ps1`:11480 terminal local pins
независимо rehashed; manifest
`build/codex_context94_95_terminal_03.inputs.sha256`, SHA256
`68C688893F607C38712B16C177B6B3A59641EA44071BD586BBBEDD3657228C7F`.
Он проверяет оба327 GREEN, все150 source cells, сохранённые4 RED и
16/4→16/0 differential. Предыдущий11504 receipt только referenced:
не утверждается повторный hash всех прежних файлов. Текущий full L295
ещё не входит в этот завершённый receipt.

Первый receipt recipe остановился до manifest: bounded process log хранит
только stdout/stderr, не argv. Recipe02 читает настоящие recorded Commands
из results.json, но затем обнаружил недостающий include search decNumber.
Recipe03 добавляет настоящий tool include directory и два third-party C
source, не пропускает unresolved include и заканчивает receipt. Все три
recipe сохранены; неудачные01/02 не выдаются за завершённые receipts.
Forbidden `l2_driver_launch.err` не читался, не копировался и не хешировался.

Последний receipt04 после удаления только одной EOF blank LF в публикуемой
копии C witness:11482 pins rehashed,11479 прежних artifacts неизменны.
Executed raw C, object, executable и logs не менялись. Manifest
`build/codex_context94_95_terminal_04.inputs.sha256`, SHA256
`ECC8158DBF7ACF6AA384AA9068C90F8FF1AC646556EA5977B9002C1FFA6690BB`.
Он намеренно не читает live full-L295 subtree, отличный от всех frozen pins.
