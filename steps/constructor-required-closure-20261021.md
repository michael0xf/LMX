# Общая подготовка constructor requirements97

Ненормативный checkpoint,2026-10-21 UTC. Goal ACTIVE; Codex sole writer/build.
Public dev остаётся0b8c6ded; private97 не объявлен dependency-closed ядром.

## Завершённый full95 и настоящий regression

`build/codex_catalog95_full_01.ps1` TERMINAL, exit1,1035 FAIL/3752.
Сравнение с63(1003/3752):39 новых FAIL,7 исчезли,12 прежних изменили
detail. `build/codex_catalog95_full_compare_01/results.json` сохраняет каждый
ID и обе формулировки. Actual compiler C совпадает94,driver C совпадает95.
Все прежние source/metadata oracles сохранены, изменён только sandbox path.

24 новых source failures не создавали L1 и сообщали «a refusal said nothing».
Минимум — `unit_pointer_empty_structure_assignment`:обычное `Empty: ()`,
ссылки на Empty,получение новой пустой Structure,не вызов.
`build/codex_full95_silent_{01,02}.{gdb,ps1}` показывают настоящий маршрут:
source_reference_seed→emit_seed_receive→model_admit_core→receiving_seed_record
→d105_catalog→catalog_require. При req0 уже sealed1,identity plan отсутствует,
candidate-pair count0. Предыдущий seed prepass намеренно пропускал cand=req,
но вместе с лишним template row терял необходимую required-type closure.

## Исправление общей подготовки,не FILL fallback

Private97 копирует96,меняется только l2trans.lm1.
`l2_reference_seed_plan` использует существующие catalog_add/catalog_close.
Оба уже разрешённых seed inventories — namespace fields и source-owned
reference declarations — вызывают его ДО sealing. Общий catalog подготавливает
identity requirements,owned children и declared reference pointees той же
конечной worklist,которая обслуживает исполненные receptions. Нет нового
парсера,предела глубины,backend ветки,позднего создания plan или admission
permission из Model. Равная пара по-прежнему не добавляет template candidate row.

`l2_source_plan_snapshot_bytes` теперь сериализует все retained plans,а не
только candidate-pair inventory,и включает оба selected declared pointees.
Иначе изменение required closure могло бы ложно выглядеть сходимостью при
неизменном числе possible candidates. Snapshot остаётся сравнением точных
байтов,не hash и не пределом числа проходов.

[Delta96→97](witnesses/used-scope-20261020/constructor-required-closure97.patch)
применяется к exact private96,НЕ к public dev. Raw executed source/C/recipes
остаются в numbered build dirs. [Unit](witnesses/used-scope-20261020/constructor-required-closure97.c)
включает настоящий frontend C,не второй алгоритм.

## Измерения

`build/codex_catalog97_build_01.ps1`:194 прежних compiler assertions GREEN.
`build/codex_seed97_required_values_01.ps1`:12/5 на96→12/0 на97.
Расширенный02:15/6→15/0. Unit содержит131 взаимно-рекурсивную declared
reference Model,проверяет отсутствие speculative identity rows,нетронутую
unused Model,полную sealed adaptation,refcount/extent,отказ stale count,
сохранение запрета late plan creation,изменение snapshot при pointee mutation,
побайтовое восстановление snapshot и live allocation delta0.

`build/codex_catalog97_focus_01.ps1` TERMINAL exit1:57 targets,15 FAIL.
45 original fixture rows взяты из actual full95 delta;31 GREEN:
все24 новых compiler failures и7 прежних улучшений. Реально собраны и
исполнены исходные программы,не только принята трансляция. В частности,
unit_values_deep_mixed/native,forced methods иcleared physical root проверяют
read/write/address с различимыми соседями по Structure/reference/index пути.
`unit_entry_args`,known/nested reference constructors,source-scope refs иempty
Structure assignment тоже снова GREEN. Exact summary/logs иprogram C не изменены.

Остались14 fixture FAIL:6 runtime partial-letter и8 shape/API regex goldens.
Ещё1 metadata FAIL — старый pair60 predicate «nested language positive remains
RED until templates reach both engines». Ни этот predicate,ни8 shape checks
в данном прогоне не исправлялись и не оправдывались успехом других программ.
Нельзя называть весь gate GREEN или просто вычесть их из результата.

Отдельное96 измерение завершено ранее:resolved-source projection13/6→13/0,
compiler96 original194 GREEN. Synthetic prepared metadata — не proof новых
typed-giving L2 values. Позднее исполнился отдельный baseline97 ниже;
он не включён в31 GREEN или focused57.

## Незакрытый runtime маршрут

`build/codex_partial95_debug_01.ps1` пересобирает неизменённый full95 program C
с debug95 runtime и воспроизводит exit1/expected7. Никакой правки программы.
GDB03/04 устанавливают первый отказ внутри общей цепочки admission:
receiving_frame→typed frame→admit_operation→walk_project_resolve→resolved_view.
Это UNKNOWN при MainLetter/field0(Array type11),sourceContext0,pending0,
template_count1,full_receiver1. Почему не выбрана доказанная correspondence,
пока не установлено. Не превращать это в исключение по имени MainLetter,
форме письма или native-only guard.

Ранние GDB01/02 на full executable без DWARF не могли читать typed return
values; отсутствие их printed helper events НЕ доказывало,что implements
не был вызван. GDB05 попал в оптимизированный соседний resolve_close вместо
нужного return site; его locals НЕ evidence failing view. Все попытки сохранены.

Далее:согласовать genuine current typed source иproof namespaces по общему
producer/COUNT/EMIT,затем исходные runtime positives иполный L2. Copy-view
dependency closure,Array/pointee/dynamic-index bounds,current callable/result
interfaces,uniform native,self-build иmail не объявляются закрытыми этим unit.

## Terminal receipt

`build/codex_constructor97_terminal_01.ps1` независимо перепроверил28449
локальных artifacts из явно названных завершённых запусков:full95,focused97,
compiler96/97,metadata differentials,GDB attempts,неизменённый debug control,
точный unit иприменение delta кprivate96. Manifest:
`build/codex_constructor97_terminal_01.inputs.sha256`,SHA256
`58D56D5BEE2F37F436F9A19F1F07D08D7D0EF87C59675E8AEFF16BF453475E30`.
Предыдущие context04 иobservations01 receipts только referenced,не объявлены
снова перепроверенными. Forbidden l2_driver_launch.err отфильтрован доI/O.
Позднейший source-giving baseline97 не входит вэтот receipt;он выполняется
вотдельных numbered dirs.

Latest canonical receipt02:28452 pins rehashed,28448 прежних artifacts
неизменны. Уpublished patch удалён только один пробел пустой context line
ради git diff --check;raw diff сохранён отдельно,аcanonical patch повторно
применён кexact96 иснова побайтно воспроизвёл executed97 source.
`build/codex_constructor97_terminal_02.inputs.sha256`,SHA256
`0B33A84C23C4F3F8D97749EF50254E76FD10254F60D4CDA1CF89B231B5637B69`.

## Поздний source baseline:не общий GREEN

`build/codex_giving97_baseline_values_01.ps1` TERMINAL0 как сборщик наблюдений,
но все32 value cells RED. Eight original sources:formal,node,index,return,
copy,mixed,capture,covariant. Все прошли L2→L1→C→compile→link. Каждая
программа исполнена вnative/forced-method переводе иnative/cleared-root
запуске. Уforced вариантов2 native bindings(door+launcher),не скрытые bodies.
Ожидаемый exit7 иread/write/address/sibling oracles НЕ менялись.

26 cells дают exit1,6 —exit3:все4 node cells «a field path met no Structure»;
copy/native2 cells «the record of a proved admission was not kept»,аcopy/walk2
cells exit1. Нельзя приписать все32 одной недоказанной причине или считать
успешную трансляцию GREEN. Значения первых семи sources требуют9→41→43 с
неизменным7;covariant result отдельно требует7→41→43,неизменный9 иодин вызов.
Source-specific failures иобщий typed source producer остаются работой.
Exact per-cell args,cwd,source/graph/exe SHA,bindings истатусы:
`build/codex_giving97_baseline_values_01/results.json`.
