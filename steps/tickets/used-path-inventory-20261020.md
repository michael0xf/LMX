# USED-PATH-INVENTORY: общий результат пути вместо старого used-parser

Перенесённый compiler49 уже удаляет старый runtime ruse scanner; полный
общий Consumer/map срез остаётся OPEN. Последние доказательства:
[private48/49](#consumer49), [kernel prototype50](#templates50); очередь — в
[current.md](../current.md). Старые координаты17/23 ниже исторические.

Статус: **OPEN**, обнаружен Codex2026-10-20. Это дефект реализации и
зависимость общего producer вложенных карт, не новая норма языка.
База обнаружения `01841adf`, принятый тогда code slice `c277fab4`.
Frontend17 raw blob `48e945b61576ae59b2e1c35da9615799a8cf4ed4`
совпадал с dev на момент обнаружения. Позднее опубликован planning/kernel
срез `7cba7b48520cd7da0e58842a75c7c863c8d22da4`; в нём старый Consumer
ещё не заменён. Исправляющий private26 не включён в этот commit.

## Воспроизводимый дефект области видимости

- [shadow](../witnesses/used-scope-20261020/shadow.lm2): вложенный `inner`
  объявляет собственный формал `m`, внешний `check` использует только `m\x`.
  Требуемое наблюдение —7; вложенный формал не требует `y` от внешнего `m`.
- [renamed](../witnesses/used-scope-20261020/renamed.lm2): тот же вложенный
  формал переименован в `q`; внешнее поведение не должно меняться.
- [required](../witnesses/used-scope-20261020/required.lm2): внешний `check`
  действительно читает `m\y`; отсутствие поля должно оставаться отказом.

Норма: новая callable-активация имеет свою область связывания, inline
управление — нет; требования Consumer следуют разрешённым употреблениям,
не совпадению написания имён. См. [инструкцию](../../L2_L3_CODING_INSTRUCTION.md)
и [v3](../../next_core_tasks_v3.md). Здесь нет конфликта двух норм и
не требуется новое решение автора.

`build/codex_used_scope_probe_04/results.json`: на принятом17 shadow
отвергнут при передаче `check(copy)` с `implements is false in function
argument`, renamed даёт L1, required правильно отвергнут; одинаково
native и `--walk-methods`. Тот же результат на private23 сохранён в
`build/codex_used_scope_probe_03/results.json`. Это **12 проверок
трансляции**, не12 реальных исполнений. Renamed ещё требует runtime
oracle7 в обоих режимах и обоих root routes; компиляции во вторую
GCC очередь не запускались. Не добавлять этому GREEN только по MadeL1.

Дополнительно тот же результат подтверждён **шестью трансляциями самим
замороженным опубликованным compiler17**, не только его debug-сборкой:
`build/codex_used_scope_published17_01/results.json`. SHA256 бинарника
`9a7327666a5eff8dad665b678febc7adba85383a1e790fa6cc924ffc743b772b`
проверен по immutable manifest полного08. Для запуска скопированы те же
байты под другим именем, чтобы не попасть в process-name memory sampler
активного full11. Это ещё не runtime-проверки значений и не измерение
изолированного пика памяти.

Источники17/23, три свидетеля, результаты18 завершённых трансляций,
неудачные попытки probe01/02 и обе causal traces заморожены65 независимо
проверенными пинами `build/codex_used_scope_completed_01.inputs.sha256`.
Verifier02 исправляет опечатку в ожидаемом SHA required; verifier01
остановился до создания receipt и ничего не принимал.

Оригинальные build sources соответствуют versioned witnesses по сырым
байтам, а не по текстовому сходству; basename/absolute diagnostic path
у probe другой. SHA256 content:

| Witness | SHA256 |
| --- | --- |
| shadow | `a5513664b2e238a0fa1bdcf46f2c07bbdc4f8a76ca02d50e7b6828dfac726921` |
| renamed | `7617c909685626bed9431539e4e20e72a088df902aa1c1a15a19dce465c57fec` |
| required | `e3e1d3211fef7774261135726b3a46745b93ea0bbe46c56b009d6c1128db9fc0` |

## Причина проверена, не выведена только из grep

`build/codex_used_scope_cause_01.gdb` на23 остановился в
`l2_descriptor_used`: у shadow к Consumer внешнего `check` собраны
`y` и `x`, у renamed — только `x`. Логи по двум программам имеют
prefix `build/codex_used_scope_cause_01.`.

При этом `build/codex_used_scope_roots_01.gdb/.log` показывает, что
общий `l2_path_walk_steps` уже различает исходные употребления:
`m\x` — method0/formal0/schema0; `m\y` — method1/formal0/schema1.
Старый отдельный collector теряет разрешённую принадлежность корня и
потом объединяет их по одному написанию. Следовательно, нельзя лечить
это списком исключений `fn`/`if` либо новым сканером shadowing.

## Оставшиеся отдельные маршруты

Места в принятом17 frontend, не координаты private23:

- `l2_uses_scan_follow`:23877 и `l2_uses_walk_node`:23983 — отдельное
  распознавание строк/атомов и склейка `l2_uses_buf`;
- `l2_descriptor_used`:24032 — повторно делит suffix по `\`, разбирает
  `[N]`, отдельно идёт по двум схемам;
- `l2_anchor_covers`:38783 и `l2_anchor_used`:46388 — другие повторные
  разборы того же буфера;
- `l2_ruse_path`:44943 уже вызывает общий resolver, но получает заново
  склеенный текст от собственного `l2_ruse_follow`/сканера упоминаний;
  `ruse` имеет собственные неизвестность/пересылку/definition эвристики.

Поэтому принятые полные mixed-path folds для эмиссии/receiving ещё
**не являются доказательством единого анализа всех Consumer**.
Прежние выводы конкретных gates остаются в своих границах; весь K09,
общий static path analysis и §§8/8a здесь не объявляются закрытыми.

## Направление одного исправления

Сохранить результат общего root/step resolver с исходным связыванием
и полным AST индексов; именно он должен стать инвентарём требований
Consumer. Передавать требования по существующим адресным фактам
formals/hidden/own/fields/calls, а не считать строку имени идентичностью.
Inline `if`/`for`, копии и тела управления пользуются тем же владельцем
связывания; вложенный callable — своим уже разрешённым namespace.

Из этого одного инвентаря получить static comparison, anchors, coverage,
child-pair projections и обе backend representations. Не сохранять
старые парсеры запасным маршрутом, не брать candidate.parent/global
Model вместо текущего model origin, не публиковать часть nested maps
раньше общего successful admission. Частные ядра pending10 дают
механику совместного доказательства/публикации, а не этот producer.

Перед приёмкой нужны все положительные/отрицательные/forwarding/
capture/node/copy/control/index случаи, реальные значения и `@` в
native/forced walker, mutants потери scope/map и полный gate на тех же
байтах. Не заменять перечисленное условием «добавлен общий helper».

## Частный ранний producer25 — ещё не исправление

В `build/codex_mixed_path_fold_25` существующий `l2_scan_path` прохода
свободных имён сохраняет подготовленный путь, AST индексов и разрешённую
принадлежность корня **до** раннего отсечения кандидатов. Новый сканер
текста или исключение для вложенного `fn` не добавлены. Новые observations
различают исходное употребление и служебный запрос транслятора; stage0
хранит грамматику/корень, stage1 означает выполненный общий semantic walk,
а не обязательно успешное разрешение. Контекст хранится существующим
`L2SourceSite`, освобождение его scopes включено в общий cleanup.

`build/codex_path_facts25_syntax_01/result.json`: frontend и header25
переведены L1→C теми же pinned bootstrap bytes. Чтобы не попасть в sampler
живого full11, использовано другое имя byte-identical бинарника; GCC и
исполнения не запускались.277 syntax/input pins независимо проверены
в `build/codex_pathfacts25_syntax_evidence_01.inputs.sha256`;187 прочих
source files совпадают с24 по сырым байтам. Это **не** C build, runtime
proof, полный инвентарь Consumer или приёмка.25 пока не queued и в dev
не переносился; recipe/probe сохранены для проверки после текущей очереди.

Следующие обязательные зависимости не исчезли: replay сохранённого
контекста после замыкания типов, роли употреблений, перенос требований
по разрешённым forwarding/capture edges и удаление старых consumers.
Передача целой ссылки сама по себе не означает потребление каждого поля
её объявленной модели; нельзя подменять этим точный анализ downstream uses.

## Частный26 — первые потребители переведены, приёмка OPEN

В `build/codex_mixed_path_fold_26` удалены packed use buffer, его builder,
старый AST walk и повторные разборы в `l2_descriptor_used`,
`l2_anchor_covers`, `l2_anchor_used`. Consumer выбирается по уже известному
method/input key, не по совпадению написания во вложенных телах. Для
candidate и requirement читается одна подготовленная грамматика через
`l2_path_walk_steps`; identity entry берёт слот через существующий
`l2_path_step_slot`, не ищет его по имени. Неизготовленный инвентарь,
включая поздно созданный метод, не выдается за пустой Consumer.

Compact heads с `\` и индексами используют один сохранённый P0/adapter;
ранний source-use record поэтому видит также path-write heads. Дублирующий
lexical-body Consumer check присваивания удалён: обычная receiving/source
подготовка и обязательный runtime implements в `l2_check_reference_receiving`
не отключены. Прежний ruse-анализ ещё существует и не назван унифицированным.

Private24 дал настоящий C-RED: dotted аргумент dump без скобок превращался
в три C аргумента.26 исправляет его; его syntax01 отдельно RED на двух
L1 tail-cutters, исходник ошибки сохранён. Исправленный syntax02 и C build
с четырьмя guards завершены.6 переводов: shadow и renamed положительные
в обоих modes, required отрицательный в обоих; renamed L1 raw-equal23.
8 O2/fstrict shadow/renamed исполнений и64 inherited mixed-path исполнений
дали oracle7: native/forced walker, оба root routes, source-method flags
проверены. Не утверждается исполнение невызываемого `inner`.

Все эти completed narrow результаты и failed attempts заморожены679
проверенными пинами `build/codex_consumer26_narrow_completed_01.inputs.sha256`.
Это не полный gate и не исправление всех ruse/forwarding/nested случаев.
Широкий replay01 ошибочно передавал relative части через ProcessStartInfo,
для которого PS Location не был OS cwd; отдельно воспроизведены
relative1/noL1 и absolute0/L1 на одном source/compiler. Его результаты
не классифицировать как регрессии26. Replay02 исправил top-level inputs,
но ещё не relative predef: unit_bad_sizeof с тем же argv/source/compiler
даёт supervisor-cwd1/noL1 и recorded-cwd0/L1. Это также ошибка окружения
replay, не новый отказ языка;02 завершился сам, partial/complete outputs
сохранены, никакие его дельты не приняты. Правильный replay03 воспроизвёл
исходный argv и реальный OS cwd baseline full11:3681 перевод,
3652 SAME,28 L1,1 EXIT,0 MSG/OUTPUT/INCOMPLETE. Единственный снятый отказ —
известный literal-кандидат `unit_at_candidate_literal_refused`:26 ошибочно
удалил аналитическую проверку вместе со старым parser. Ожидание не ослаблено.

## OOM текущего общего результата — отдельный измеренный дефект

`build/codex_consumer26_alloc_01/results.json`:620 фактически инъецированных
source-use/resolved-path record/text/steps/site allocations;306 failures.
294 дали exit0 с L1 при sticky allocator error,12 — ложный
`malformed implements descriptor`. Все620 освободили tracked storage.
Общий path failure оставлял пригодный на вид leaf verdict; optional query
мог его потерять как обычный semantic miss, а публикация не проверяла
fatal allocator state. Это не ошибка native и не норма допуска.

Private27 очищает leaf при fatal path failure, сохраняет sticky allocation
state и проверяет общие фазовые/публикационные границы, сохраняя старый output.
Новые trace notes в общих step/scope allocator helpers показали дополнительные
позиции.742 events × absent/existing destination: публикации уже нет, но96
ложных path diagnostics остаются. Оба RED и completed replay03 заморожены
17299 проверенными пинами `build/codex_consumer26_27_failed_01.inputs.sha256`.

Private28 выдаёт одну allocator diagnostic также в speculative walker query;
742 events ×2 destinations прошли, старый output raw-сохранён, tracked live0.
В нём известный constructor source проверяется через resolved own key тем же
`l2_admit_consumer_ix`, не по имени/новому обходу body; literal-negative опять
отвергается в8:5.64 mixed-path +8 scope actual runs дали7, required отказан.
Расширение на все прочие common path-steps/source-scopes выявило ранние
возвраты без диагностики;28 также не принят. Его allocation02/replay ещё идут.

Private29 завершает fatal allocation diagnostic на общем выходе translation,
пока source ещё жив. Его объединённый проход всех измеренных common
steps/scopes и fact allocations завершён5474 events ×2 destinations:
10948 actual invocations,0 failures, tracked live0 и сохранённый old output.
Это не claim всех OS allocations. Causal trace
`build/codex_path_fatal_cause_02.log`: один и тот же measured fault1408,
26 возвращает leaf7/why4,29 leaf−1/why7; tracked live0. Это проверка
самого общего результата, не только финального запрета публикации.
Verifier01 ошибся в ожидаемом числовом kind (0 вместо реального7);
02 проверил первый лог без перезапуска26, источник не правился.

## Prepared nonindexed head и effect ABI

Runtime focus29 дал44/22,21 новую C-регрессию. Общий adapter26 уже возвращал
prepared result для `a\b`, но `l2_head_path_effect` сохранял условие
`prepared.indexed = 0 -> no effect` от прежнего indexed-only helper.
В итоге native содержал `l2_out_throw`, а ABI метода его не объявлял.
Пример — неизменённый `unit_local_model_arg`, writer `x\value: 99U`.
Это не новый тип исключения и не основание просто добавить параметр native.

Private30 меняет потребителя: все prepared path steps, indexed или нет,
разрешаются одним fold; старый текстовый запасной разбор effect-head удалён.
Focus30/01 завершён44/2, fixture regressions0, changed old FAIL0.
Один FAIL прежний `unit_at_third_candidate_thin`; второй — metadata check
с устаревшим ожиданием, что head `values\field` вообще не получает adapter.
Его не заменили удобным no-effect: новый тест требует полного nonindexed
prepared result, effect1 от того же resolver, retained ownership и очищения
всего leaf verdict при fatal error; отдельный bare root остаётся no-path.
Расширенный97-check тест реально прошёл0 failures/четыре C guards в
`build/codex_consumer30_test_tools_01/prepared.result.json`.

Точный source30 SHA256
`05717a22b0e56f77dcb6bffc4255eec7884936e7a975ebdc8f557eef223875fb`.
Focus30/02 с новым тестом завершён44/1:0 regressions/newFAIL/changedCommonFAIL,
единственный старый FAIL `unit_at_third_candidate_thin`;7newOK.
Replay30 завершён3681 SAME,0 EXIT/L1/MSG/OUTPUT/INCOMPLETE: прежний корпус
raw-эквивалентен full11. Это не заменяет реальное исполнение новых witnesses
или OOM-проверки. Allocation28/02 завершён4732 events ×2 destinations/16failures
(измеренный silent-diagnostic control), объединённый29 завершён5474/0,
а30 завершён5490 events ×2 destinations/0failures (10980 invocations).
Единственная очередь
`build/codex_consumer30_full_sequence_01.ps1` выполнила strict64actual/0failures
и запустила full
`build/l2_harness/codex_consumer_full_01`; никакой другой GCC pipeline
в это время не запускать. Private30 в dev не перенесён. Старые
ruse/forwarding/роли употреблений и общий nested producer остаются OPEN.

## Ранний input position не является идентичностью binding

Новый [hidden-order](../witnesses/used-scope-20261020/hidden-order.lm2)
имеет нормальный oracle7 (ещё не измерен в runtime). Сначала читается
`b\x`, затем `a\y`: свободный `a` вставляется перед уже записанным `b`
в существующей sorted input table. Source-use факт b оставляет старое fi0,
хотя текущий b — input1. Это общий дефект стабильности source binding,
не особый случай одного hidden имени.

`build/codex_used_hidden_order_probe30_01`: два перевода дали L1, dump
показывает source-use1 b/fi0 и typed query b/fi1. Причинная GDB-проверка
`build/codex_used_hidden_order_cause30_02.log` остановилась в реальном
`l2_uses_select`: a0 получает2 path uses, b1 —0 вместо1. Оба имени и
адреса canonical rows сняты из текущей input table. Попытка01 сохранена
ошибкой printf debugger (`*` width/precision не поддержан), не отказом
языка. **30 не принят и не переносится даже при прежнем full verdict.**

Private31 сохраняет whole binding reads в существующем fact lifetime,
из обычного capture/namespace traversal, после регистрации скрытого входа.
Source-use2/zero-step root не является field Consumer или full Model;
path Consumers по-прежнему требуют source-use1. Это foundation ролей и
forwarding, не уже удалённый ruse. Private32 добавляет stable canonical
input-row address: method + row address выбирают Consumer после перестановки,
без повторного поиска имени или подгонки native/walker. Если row перестал
принадлежать текущей signature, это fatal compiler inventory error, не
нулевое потребление. Никаких новых имён или opcodes в user graph нет.

31/32 прошли только L1→C syntax; C build/runtime/полный gate не приписаны.
Source32 `9b69c42076bb63f954265e8ebb5ede22d8f4ac80bfdda5604721becf97487fd6`.
После окончания full30 единственная queue
`build/codex_roots32_after_full30_01.ps1` собирает32 и выполняет8 translation
probes. Ожидается по-прежнему по одному пути для a0/b1, runtime7 для
нового свидетеля и прежних shadow/renamed, отказ required. Отдельный unit
`build/codex_binding_symbols32_test_01.c` ещё не исполнялся: проверяет
address identity, method namespace, исчезнувший/equal-spelling row и
whole-value observation, не подменяет native/walker runtime или ruse audit.

## Поведенческие контрпримеры стабильности input

[hidden-consumers](../witnesses/used-scope-20261020/hidden-consumers.lm2)
использует один Model(x,y), но фактически читает только a.y и b.x.
Caller даёт соответственно OnlyY/OnlyX.30 отказывает в обоих режимах.
`build/codex_used_hidden_consumers_cause30_01.log` показывает непосредственно
в `l2_admit_finish`: cand1/req0, selected method0/input0/uses2;
stack ведёт из общего `l2_d105_close`, не из backend-проверки.
16 counterexample pins независимо проверены в
`build/codex_hidden_consumers30_completed_01.inputs.sha256`.

[hidden-growth](../witnesses/used-scope-20261020/hidden-growth.lm2)
читает41 скрытую привязку в обратном порядке. Настоящий `l2_hidden_reserve`
начинает с4, потому этот исходник требует роста8/16/32/64; сортировка
меняет текущие номера на каждой вставке. Sparse кандидаты должны дать7,
но старый30 отказывает в обоих режимах. Результаты перевода сохранены в
`build/codex_hidden_growth30_probe_01/results.json`; runtime ещё не измерен.

[hidden-required](../witnesses/used-scope-20261020/hidden-required.lm2)
обнаруживает unsound направление той же причины: a получает полный Model,
b — OnlyY без x.30 выдаёт L1/exit0 в native и walk
(`build/codex_hidden_required30_probe_01`); реальное исполнение этим
не утверждается. Новый32 обязан дать обычный false implements, а не
внутреннюю metadata diagnostic. Так положительные witnesses не заменяют
сохранение обязательного допуска.

91753 completed pins OOM29/30, strict64/replay30, syntax31/32 и causal30
проверены отдельно: `build/codex_consumer30_roots32_completed_01.inputs.sha256`.
Это не результаты C/runtime32 или ещё живого full30. After-build32 queued
actual11 unit +76 value runs (session36548), затем два sparse positives,
missing-x negative, replay32 и allocation32 (session85517); пока только
подготовка/очередь. Allocation32 дополнительно выбирает measured
`source-root` notes, не повторяет старые номера или ограниченный regex30.

## Completed32 и общий результат admission33

Full30 завершился3701/1015 без новых регрессий/FAIL/removed/changedCommonFAIL,
6newOK;3960 staged inputs raw-сверены и30086 pins проверены
(`build/codex_consumer_full30_completed_02.inputs.sha256`). Это не его
приёмка.01 verifier искал convert.lm2 среди fixture tests, а02 учёл
существующие корневые inputs;01 сохранён. Старый PID guard очереди Cbuild32
завершился до запуска, зависимые01 тоже не исполняли своих proofs из-за
отсутствующего C. После окончания full30 Cbuild32 сделан явно, без изменения
frozen source32. C/header совпали с syntax;8 probes, actual11 unit и76 value
runs прошли. Replay32 завершён3681 SAME/0 иных изменений, OOM32 ещё идёт.

Sparse-positive32 добавил8 actual runs:4 native дают7,4 forced walker
заканчиваются INVALID. Missing-x negative32 даёт обычный implements отказ
в обоих режимах; ожидаемую обязательную проверку не ослабляли.
GDB `build/codex_hidden_walk32_debug_01/admitted-map.log` измерил точку
после допуска: map уже зарегистрирован, out.type1040 от source @void
не совпадает с expected1124 принимающего аргумента. Ранние ограниченные
debugger scripts не поймали источник, они сохранены; `status.gdb` и
`admitted-map.gdb` проследили actuals и саму установленную карту.

Runtime33 нормализует **результат успешной общей admission-операции**,
не добавляет coercion в actuals: существующий `lmx_walk_value_ref` возвращает
Structure reference только после доказанного YES или для допустимого null.
Неуспех и unrelated primitive pointer values не меняются. Нового opcode,
поля графа, второго map/resolver или name runtime lookup нет.
Все84 inherited/new executions с неизменёнными O2/fstrict/four-guard
program objects дали7 с новым driver O0/g; это ещё не full kernel proof.
3954 source inputs exact,4902 completed pins:
`build/codex_binding32_result33_completed_01.inputs.sha256`.
Kernel13 extra-Strict ещё идёт с прежними warning errors; для сравнения
нужен режим принятого kernel12, не представление нового набора флагов как
регрессии33: app_min C12/C13 raw-одинаков, hash282acd31…7751bdfaf2.
Очередь `build/codex_kernel14_full33_sequence_01.ps1`, session64511,
выполнит baseline-mode kernel14 после exact process handle13, затем full16
при325/0; competing GCC не запускать. Полный combined gate16 и kernel delta ещё не приняты;
source/header/ABI source-plan32, runtime33 и новые tests пока private.

Allocation32 завершена:5766 measured events ×2 destinations,11532 actual
invocations/0fail, tracked live0, old output сохранён. Новые source-root
notes включены, а не пропущены прежним фильтром30. Replay32 —3681 SAME,
0 прочих изменений. Эти завершённые результаты пока отдельно от4902
runtime/type pins; full/compiler acceptance этим не объявляется.
Теперь они отдельно заморожены52323 проверенными пинами
`build/codex_binding32_alloc_replay_completed_01.inputs.sha256`.

Kernel14 завершён325/0, сохранил все325 baseline target IDs,307 staged
inputs raw-equal; Kernel13 extra-Strict завершён325/173.3160 checked pins
в `build/codex_kernel14_completed_01.inputs.sha256` сохраняют оба режима,
не объявляя global warning debt решённым. Full combined32/33 уже запущен
в session64511/PID14120 (creation08:00:55.4445905UTC),
`build/l2_harness/codex_binding_result_full_01`; не повторять и не менять
frozen gate16. Помимо8 hidden rows добавлены2 present-null @void→Model
rows, source translation0/AS present, runtime пока ожидается. Expected3711
targets — ещё не verdict. Свидетельства full не включены в completed pins.

## Завершённый full33 и точное различение source uses34

Full33 завершился3711/1015, actual1. К full30 нет regressions/newFAIL/
removed/changedCommonFAIL,10newOK; обе дополнительные present-null строки
реально исполнились.3970 inputs raw-equal и30179 checked pins сохранены
в `build/codex_binding_full33_completed_02.inputs.sha256`. Это узкая дельта
compiler32/runtime33, не удаление ruse и не полный чистый gate.

Private34 отделяет регистрацию корня пути от настоящего чтения целого
binding в общем producer, без нового parser или backend exception.
16 переводов/fact checks: у одного source occurrence нет одновременно
source-use1 и ложного use2; relay(p) и INDEX operand i сохранили реальные
whole observations. Два запуска старого32 воспроизводят дубликат.
Прежние L1 raw-сохранены, обязательный missing-field отказ сохранён.
12 actual runs нового whole-path-use и двух ruse controls:8 oracle7,
4 положительных RED taint.332 завершённых narrow pins:
`build/codex_source_kinds34_completed_01.inputs.sha256`.

[Ruse-control](../witnesses/used-scope-20261020/ruse-control.lm2) и
[ruse-taint](../witnesses/used-scope-20261020/ruse-taint.lm2) требуют7;
различается лишь имя q/m неиспользуемого поля Unrelated. GDB32 в настоящем
приёме показывает у одной own-привязки с тем же direct path state2/known
в контроле и state1/unknown в taint из-за `l2_ruse_named_by_path`.
Так доказано влияние чужого spelling, не отсутствие карты kernel.
Не закреплять этот отказ тестом и не удалять guard локально: взамен нужен
общий source-use/typed value-flow с reachability и косвенными путями.

Replay34 завершён3697 SAME/0 иных изменений к full33. OOM34/session39076
завершён0:5544 measured events ×2 destinations,11088 actual invocations,
0fail/live0, existing output raw-сохранён.50810 checked pins:
`build/codex_binding34_alloc_replay_completed_01.inputs.sha256`.
Full34/session30003 ещё идёт на frozen gate17;3713 targets пока не verdict.
Private35 выделил общий bound-root walk из существующего resolver и
формальный Array contract по уже готовому индексу. Сейчас лишь syntax04,
не C/runtime приёмка; after-full queue/session67832 ждёт завершения34.

## Общий cursor и фактические связи употреблений

Шесть реальных GDB/translation runs34 для
[forward](../witnesses/used-scope-20261020/ruse-forward.lm2),
[compare](../witnesses/used-scope-20261020/ruse-compare.lm2) и
[node](../witnesses/used-scope-20261020/ruse-node.lm2) завершились0/L1.
Нормативный oracle7 сохранён, фактическое runtime значение ещё не проверено.
У forward уже есть общий D105 edge own0/mi1/key−2→callee0/input0 и целый
операнд m; у сравнения — whole observation без такого forwarding edge;
у node — полный source path с root own−1/input−1, а не прямой m-root.
Значит анализ обязан читать разрешённую выбранную ячейку в середине пути,
а не возвращать project-wide поиск по имени или объявлять Model целиком
потреблённой из-за факта whole read.

Private36 добавил cursor в **то же тело semantic fold**, не второй walker.
Прежние CHECK/native/walker и root Consumer входят с begin0; разрешённый
suffix проецируется с выбранного begin, все offsets/INDEX AST/счётчики и
владение полного grammar остаются неизменными. Только [begin,n) получает
verdict; begin — обязательная часть запроса читателя, не скрытый срез и не
разрешение передавать частичную проекцию backend как whole-path verdict.
Syntax01 прошёл; source `ac326410fcf37e41778e9675e510704a3615de08df103af28d47de661f0e2d01`.
C tests35/36 с реальным frontend и глубоким cursor1031 пока лишь подготовлены.
38 checked pins `build/codex_source_roles36_narrow_01.inputs.sha256`
сохраняют шесть наблюдений34, syntax35/36 и неисполненные тестовые исходники;
это не C build, cursor unit, native/walker values или удаление старого ruse.

## Перенос34/33 и следующий common-flow остаток

В dev перенесены exact compiler34/header34/walker33 и9 source fixtures;
production harness сохраняет исходные root/sandbox пути, получает tested97
metadata assertions и18 проверенных rows. Full34 завершён3713/1015,
actual1,0 regressions/newFAIL/removed/changedCommonFAIL,2newOK.3972 inputs
exact/30202 checked pins. Kernel15 завершён325/0 на тех же5 core bytes,
same325 target IDs,307 exact inputs/1870 pins. Public focus02:23/0,
все18 новых rows прошли;198 его inputs raw-equal full34. Promotion receipt:
`build/codex_consumer34_result33_promotion_01/verified.json`.
Focus01 был runner-RED до fixtures (PowerShell comma/+ precedence,
получилось9 отдельных `_walk`);02 исправляет лишь скобки списка.

Private36: actual C, unit25, source-kind16 и bound-source8 пройдены;
481 pins `build/codex_step_cursor36_completed_01.inputs.sha256`.
Unit02 падал в `l2_ns_find` из-за неинициализированной synthetic name table;
03 заполняет namespace/method arrays, не меняя compiler C и ожидания.
Replay36 —3699 SAME/0 иных изменений; allocation36 завершён5544events ×2,
0fail/live0, existing output сохранён.50816 независимо проверенных пинов:
`build/codex_binding36_alloc_replay_completed_01.inputs.sha256`. Ни36,
ни следующий37 этим в main не приняты.

[node-formal-source](../witnesses/used-scope-20261020/node-formal-source.lm2)
передаёт полученный формал по `node\p`; обычный
[capture control](../witnesses/used-scope-20261020/direct-formal-source.lm2)
передаёт его голым именем. Требуется7 на переставленной Actual(y99,x7),
не Model(x1,y2). Пока проверены только переводы: node получает internal
late D105 pair/occurrence refusal, control0/L1 в обоих режимах.
GDB36 в фактическом `l2_check_call_at` после source query: schema0/layout0,
method−1/place−1 (формал ошибочно стал constructor evidence).37 объединяет
root/selected-formal origin producer, сохраняет method1/place0/layout−1;
GDB это подтвердил, но переводы node остались RED. Значит недостаёт общего
раннего приёма source spans в receiving-flow closure, не разрешения
создавать новые pair maps после их declaration. Не обходить общий guard
и не чинить лишь native emission. Первые debugger CLI arguments были
переданы неверно, source-cause02.gdb сохранил нормальное наблюдение;
каузальная остановка debugger не выдана за завершённую трансляцию.

Перенос34/33 опубликован в `924cf319104d69e212690d22b29b9b06c06310c4`.
Private38 объединяет structural source-note phase, но node остаётся RED.
Actual debugger `build/codex_formal_sources38_probe_01/occurrence-cause.log`
показывает в `l2_occ_actual(span3)` ложный callee4 (proc Model), хотя
выбрано полученное значение формала.39 меняет общий callee projector:
для выбранного input читать тот же callable contract, что у root input,
не получать исполнение от принимающего прототипа. Это ещё исследование,
не признанная приёмка39/native/walker или закрытие всех flow roles.

39 теперь прошёл32 actual-frontend assertions и3699 SAME replay. Новые
factory witnesses действительно возвращают сформированный метод и посылают
exit Message;8 O2/fstrict/four-guard executions дали7 в обоих движках и root
routes. Старое `exit: go()` — обычная source Structure, не отправка; его
values01/8fail нельзя приписывать вычислению go. Runtime02 с настоящей
отправкой дал direct4actual7, node4X1/INVALID без формирования context.
Этот прямой маршрут не закрыт переходом к отдельному factory witness.

Control06:24 actual executions,20OK/4positive RED. Sparse Actual(x7)
в factory через node даёт7, через hidden input — implements2; generated
inner знает лишь Model layout, а host имеет partial Actual map. Отсутствие
потребляемого x отказано (node compile/hidden actual2). Ожидание7 sparse
сохранено; нужен общий source/Consumer перенос, не ослабление допуска.
Callable-forward walk-marked control имеет прежний native method2,
raw-equal actual34: это legacy hybrid, не полностью walked proof.
01–05 failed probes/runner mistakes и06 все сохранены;10832 independently
verified pins `build/codex_formal_sources39_narrow_completed_02.inputs.sha256`.
01 pinner случайно попытался читать собственный открытый log;02 исключил
live log, старый partial manifest не перезаписывался. Allocation39 ещё идёт,
в narrow pins не входит; private39 в main не принят.

## Private42: одна передача источника и hidden-input reception

40 регистрирует source→input при формировании возвращаемого метода до
D105 closure. Физическая дедупликация capture slot не удаляет edges других
читателей. Actual GDB39/40 подтвердил недостающую связь host1/input0→2/0.
Sparse positives проходят, genuine missing-x отказывает. Дополнительный
shared source в40 всё ещё дал walker2RED при native2actual7; GDB runtime33
показал старую identity-only instruction с Model source token при Actual
layout.42 убирает эту ветвь для call и held-call в native и walker:
обе формы читают тот же hidden-source producer и принимающий input.
Удалены `l2_cap_src_marked`/`l2_cap_emit_admit`, не оставлены fallback.
41 C-RED — забытый старый helper prototype;42 синхронизирует декларацию.

42 actual32/0fail, actual-frontend unit32/0fail,8 positive/negative
translations;10735 independently checked narrow pins:
`build/codex_capture_hidden42_narrow_completed_02.inputs.sha256`.
Replay42 —3689 SAME/10L1/0EXIT/MSG/OUTPUT/INCOMPLETE. Изменения capture L1
не объявлены runtime-эквивалентными по одному replay: full42/session10981
ещё идёт (gate18/tools42,14 дополнительных rows, expected3727 не verdict).
Общий OOM42/session60879 завершён5544×2/0fail/live0/old output preserved;
completed pinner42 проверил50816 pins:
`build/codex_binding42_alloc_replay_completed_01.inputs.sha256`.
OOM39 завершён5544×2/0fail и50816
pins; не подменять им proof42.

На6 читателях GDB42 измерил source-edge growth12→18/cap16→32 и6 allocations
в каждом backend. Все12events ×2 destinations прошли,0fail/live0/old output
сохранён. Runtime6-reader остаётся непроверенным. Меньшие trace01/02 не
вызывали growth; отрицание их coverage сохранено, не выдано за успешный
fault-test. Ruse/remaining role and source Consumers, чистый gate и §§8/8a
остаются OPEN. Единственный writer/build Codex, goal active.

43 — только cleanup новых unused locals после удаления capture identity
ветвей и устаревшего комментария. Reviewed generated C отличается от42
исключительно удалением11 лишних locals/двух assignment targets; прежние
side-effecting source queries сохранены. Source `be010c9f…ad9e9b`,
syntax C `76933afd…946cd7`, не C build. Queue64371 ждёт exact full42 handle,
затем собирает43 с четырьмя guards/предупреждениями, исполняет unit32 и
делает replay к завершённому full42 (включая новые14 rows). Main/code
по-прежнему34/33; ни43, ни full42 пока не объявлены принятыми.

Полный warning multiset34→42:12 новых entries,11 locals плюс старый
capture-mode параметр `mcall` в `l2_emit_call_hides`.44 удаляет последний
аргумент с prototype/двух callers; только syntax C, ещё не GCC. Source
`6c20ba31…7dbade`, C `32492f3c…3db71c`. После queue43 проверить44, не
называть43 warning-clean и не менять уже frozen inputs. Completed replay42/
flow42 и43 syntax сохранены10001 checked pins:
`build/codex_capture42_replay_flow_completed_01.inputs.sha256`.

## Следующий общий Consumer, не ослабление старого ruse

В reviewed44 остаются `l2_ruse_named_by_path`:45822 и семейство
`l2_ruse_scan_*`/`l2_ruse_follow`:45600–45971. Это всё ещё второй разбор
и project-wide spelling taint; очистка capture reception его не исправляет.
Нельзя просто удалить проверку одноимённости: `source_use=2` пока не имеет
семантической receiving-role и его пропуск разрешил бы неизвестное escape
как будто Consumer пуст. Нормативные исходы сравнения, forwarding и
неизвестного использования различны (семантика §§4,12; без Consumer —
полная пригодность), даже если все три записаны одним целым атомом.

Следующий срез должен получать роль целого операнда **там же, где CHECK
уже разрешил выражение/принимающее место**, а не новым AST walk. Для
пересылки доступны существующие `(method,key)` edges D105; канонические
input-row addresses переживают вставку скрытых входов. Для выбранного
внутри пути own/formal готов `l2_source_use_resolve`:24087; проекция
`l2_uses_project_from`:24169 сохраняет полный record и cursor, а не отрезает
suffix с рассогласованными n/names/index/run counters. Полезные зависимости
нужно переносить как разрешённые места/шаги, не как имя прототипа Model.
Статически известные требования распространяются по тем же edges с
остановкой циклов; ни исполнение кандидата, ни второй обход вызываемых
тел, ни старый scanner как fallback не являются заменой такого результата.

Приёмка обязана сохранить реальные positive7 у control/taint, forwarding,
identity comparison и reached nested consumer, а также refusals missing
используемого поля; оба движка/оба root routes. Старые `exit: go()` не
посылают Message и потому сами по себе не измеряют return7. Ни этот план,
ни набор direct-path facts не объявляют все whole-value roles закрытыми.

## Перенос44/33: capture закрыт, общий Consumer остаётся открыт

Compiler44 raw `6c20ba31…7dbade`, actual C `32492f3c…3db71c`;
cleanup не меняет generated graphs42: replay43/44 по3713 SAME, unit32/0
каждый.12 real O2/fstrict executions44 (six-reader growth/nested Data/
whole hidden forwarding) дали7 во всех движках/root routes.23568 checked
completed pins `build/codex_capture44_completed_01.inputs.sha256`.
Kernel16 завершён325/0,307 exact inputs, те же325 IDs,1870 pins.

Полный42 реально завершился3727/1016, actual1. Все14 новых rows прошли,
старые FAIL/диагностики не изменились, кроме одной новой структурной
ошибки native exact-capture до runtime: test требовал удалённый
identity-only register_map shim.30312 checked RED pins:
`build/codex_capture_hidden_full42_red_completed_01.inputs.sha256`.
Новый чистый full verdict отсюда не выводится.

Обе exact/direct-vs-copy программы сохранили шесть реальных значений/
записей/независимость копии и oracle7. Private frozen-route focus9/0 плюс
4 walkroots дали8 accepted executions. Старый walker exact row уже был
RED из-за observer: обе CALL/8 имели все прежние нужные shapes, но
observer не входил в var/body вызванного fn и терял plain widths на
физических aliases. Исправлен общий observer; data с четырьмя такими
полями не классифицируется как fn.26 постоянных controls и7 mutants
проверяют это, исходные GraphShapes сохранены.

После переноса compiler/tools и восьми source fixtures обычный production
маршрут прошёл focus25/0 (20 fixtures), затем16 extra walkroots:32 actual
positive executions,4 ordinary missing-x compiler refusals.200 staged
inputs raw-сверены;16 L1 raw-equal completed proofs.559 checked pins:
`build/codex_capture44_public_completed_01.inputs.sha256`.
Первый дополнительный root runner ожидал13 driver checks вместо реальных17;
checker исправлен, bytecode/программы/ожидание7 не менялись. PS unit01
остановился на array-expression syntax;02 исправил runner, не shape.

Это приёмка source/capture delta, а не удаление старого ruse: следующий
срез остаётся описанным выше общим role/port Consumer. Прямой node-formal
маршрут без сформированного capture context отдельно остаётся недоказанным.

## Private45: исторический checkpoint до GCC

Текущее продолжение — private46 в последнем разделе ниже; этот45
checkpoint сохраняет состояние подготовки, не назначает новую очередь.

`build/codex_mixed_path_fold_45` добавляет к source-use observation
роль употребления и разрешённые принимающие порты существующих D105/CFA
checks. Выбор observation — исходный P0-адрес/метод/полный span, не имя;
прозрачная группировка пользуется существующим `l2_reference_fields`.
Неоднозначное вхождение остаётся unknown. Сравнение ссылки отмечается
общим typed-expression fold только при CHECK, не поздним type query;
`relay(m) = 0` не превращает аргумент m в identity-use результата relay.
Получающий input и динамический selector хранят canonical input-row
addresses: перестановка hidden inputs не выбирает другой порт. Роль
динамического контракта не является свидетельством исполнения его
descriptor-only тела; дальше требуется имеющееся callable-class closure.
Новых runtime полей/opcode/таблицы связывания в графе нет.

Это **не** ещё один Consumer и **не** готовая замена ruse: допуск и оба
backend пока не читают роли. Unknown не получает пустое разрешение.
Нужны дальнейшая общая композиция requirements/путей/receivers и удаление
старого scanner без fallback; opaque escape, selected own/formal/capture/
node/control/index и все источники не объявлены закрытыми этой записью.

Header/frontend45 переведены L1→C с тем же pinned bootstrap. Source raw
`013fb8af…3b76a9`, header source `2e32d99d…6a3287`, C
`0d3da573…974faa`. Syntax01 сохранён RED на двух недостающих L1 tail
cutters;02 исправил отступы,03 дедуплицирует по canonical receiving input,
а не временному key. Никакой GCC45/исполнение не запускались во время
живого full44.187 остальных source/header dependencies raw-равны44,
266 checked **preparation-only** pins:
`build/codex_use_roles45_prepared_01.inputs.sha256`.

Подготовлены, но не исполнены `codex_use_roles45_build_01.ps1`
(четыре guards,32 inherited assertions и24 новых),
`codex_use_roles45_probe_01.ps1` (12 точных translation/role comparisons),
`codex_use_roles45_alloc_01.ps1` (все измеренные новые receiver allocations,
absent/existing output). Guard сверяет живой full44 по той же CIM API;
её microsecond timestamp заканчивается `.3329730Z`, Process.StartTime
того же PID15952 — `.3329731Z`. Между этими представлениями нельзя
выводить, что прежняя сборка закончилась. После terminal handle/full
summary —45 build, actual probes/faults, затем replay и runtime witnesses.

Baseline44 `build/codex_use_roles45_baseline_01` — лишь12 переводов
шести новых программ в двух modes: compare/forward/dynamic/nested-call
и missing-x дали L1, bad-compare с1 отказан. Missing-x не считается
положительным значением7 или compile-refusal: нужен действительный
runtime отказ. Эти preparations не закрывают project spelling taint,
старые положительные RED, общий gate или §§8/8a.

Дополнение preparation03:298 независимо сверенных pins сохраняют
ещё шесть успешных переводов44 неизменённых источников ordinary nested
Structure, node-formal factory и40-step actual. Это калибровка исходных
P0/path facts, не45 role/runtime acceptance. Новый path-role probe обязан
найти ровно исходное source-use=1 вхождение и получающий порт, а не
compiler-query observation. Runtime recipe02 дополнительно ждёт terminal
full44 по точной Process.StartTime, не только отсутствие gcc в моменте.

Очередь `build/codex_use_roles45_after_full44_01.ps1` запущена:
session64150, PID7076/creationUTC `2026-10-20T12:46:09.6440447Z`.
На старте она ждёт тот же живой full44, GCC45 не запускает. После
его завершения последовательно выполняются build32+24, probe12,
path probe6, receiver OOM, broad replay и value/refusal20; каждая
ненулевая child exit прерывает дальнейшие стадии без слепого повтора.
Очередь не публикует source45 и не считает весь ruse/goal завершённым;
actual evidence и delta полного gate ещё требуют отдельного чтения.

## Full44 завершён, private46 проверен, legacy Consumer ещё OPEN

Full44 actual exit1,3729/1004;3988 staged inputs raw-сверены,
30428 checked completed pins:
`build/codex_capture44_full_completed_01.inputs.sha256`.
К34 regression0/newFAIL0/fixed11/newOK16; к42 fixed12/newOK2, также
без regressions/newFAIL. Пять старых RED изменили фазу после исправления
общего observer: array selector/named-Structure call исполняются с exit7,
но прежние width/name/path assertions не проходят; erase-index mutant
не имеет успешного baseline; formal-bind видит1 вместо3 SET. Это всё
ещё RED, не разрешённые ошибки языка и не повод ослабить physical witness.
Из17 changed/fixed graphs16 raw-равны42, один отличается двумя quoted
diagnostic source filenames build stamp. Verifier01 требовал raw equality
и сохранён RED;02 отдельно проверяет только эти точные имена, а не
нормализует код/поля/значения. Ни новый чистый gate, ни11 новых языковых
ремонтов отсюда не выводятся: observer стал видеть реальные исполнения.

После full44 очередь45 действительно собрала frontend/header45 с четырьмя
guards, выполнила unit32+24 и role probe12. Path-role positive для
[обычной selected Structure](../witnesses/used-scope-20261020/receiving-role-selected-structure.lm2)
выявил пропуск: target0/input0 получает значение через CFA source branch,
не через source-note. Actual GDB45 показывает CHECK_SOURCE/schema2,
без CHECK_NOTE/CHECK_ROLE; программа переводится, metadata роль отсутствует.
Очередь64150 остановилась с actual1, не выполняла свои последующие
OOM/replay/runtime stages. Frozen45 и исходный RED не редактировались.

46 переносит запись receiving role в общий цикл всех проверенных actuals,
не зависящий от source class. Отдельный dynamic CFA hook удалён;
assignment/return используют прежний общий source-note entry. Source
grammar/resolver/admission/emission не менялись и новый AST walk не
добавлялся. Original P0/full span и canonical receiving/selector input
addresses сохраняются; descriptor-only контракт не выдаётся за выбранное
тело. Source `662f16f5…342010`, header source `2e32d99d…6a3287`, C
`69eb1138…51671f`, actual binary `a7afbcbd…15a268`.

Завершены и независимо проверены:

- 32 inherited cursor assertions и24 role assertions;12 обычных role
  translations плюс6 original path-role facts/receiving ports (nested
  data, selected node-formal и40-step actual), без query-fact подмены.
- 18 measured receiver allocations × absent/existing output=36 actual
  fault invocations,0fail/live0/old output preserved. Это новые sites,
  не все OS allocations.
- Exact-argv/реальный OS cwd replay к full44:3715 SAME,0 EXIT/MSG/OUTPUT/
  L1/INCOMPLETE. Все3715 input/log/argv/output records независимо сверены,
  без нормализации source paths в этом replay.
- 64 O2/fstrict/four-guard value/refusal mode cells, затем все64 повторно
  исполнены с явными argv/cwd и неизменёнными binaries. Source fn IDs
  проверены native/forced walker, root native/cleared physical walk.
  Positive7 rows56, обычных runtime implements2 rows8. Из ранних20 rows
  16 positives имели Model.x7=Candidate.x7 и сами не исключают подстановку
  конструктора; четыре missing-x negatives не имеют x вообще. Новый20-row
  набор различает Model.x1/Candidate.x7, ещё12 подтверждают nested/node
  и40-level leaf write; ещё12 — переставленные implements fields,
  references/indices, read/write/полученный адрес/разыменование, intact
  neighbors/model defaults и exactly-once index calls.

### Private47: actual receiving ports, ещё не новый Consumer

Продолжение46 — `build/codex_mixed_path_fold_47`. Из189 staged source
files относительно46 изменён только `l2trans.lm1`: source
`8082c48fd6b21ba6f338f3f6f09aeaee505226d3fd7f8e5b7cff5e323bbfb293`,
generated C `032ef16b820d749099cae684be548f31d6a21d799acc322a2230327b2bee392c`,
actual debug binary `b206cd20c06905186707bc32cd0c8ba7cd4f948b69115a07b774b69f524b7533`.
Header source/generated header raw-равны46; четыре C guards сохранены.

`l2_use_receiver_port(fact, receiver, which, method, key)` читает только
существующие адресные receiver/CFL факты. Static port следует canonical
input row, negative own/result/namespace-field keys остаются в том же
D105 пространстве. Для dynamic selector берётся его нынешний binding
index, затем реальные методы из того же CFL closure, которым пользуется
CFA; позиция соответствует проверенному интерфейсу. Имя фактического
формала не обязано совпадать с prototype. Hidden input не угадывается по
позиции explicit actual.0=port,1=end,2=unknown/invalid, outputs при отсутствии
port очищаются. Ноль известных реализаций или смесь известных с unfollowed
source —2, не успешное пустое множество и не тело descriptor-only метода.
Никакого второго обхода P0/разбора пути/реестра имён нет.

`build/codex_use_ports47_test_01.c` компилируется против actual frontend:
31 assertions, включая input/selector permutation, другой адрес с тем же
spelling, обе реальные реализации с другими именами формалов, unfollowed/
пустой класс, invalid/missing ports, own host, result и namespace-field
keys, отсутствие allocation.32 inherited cursor и24 role checks тоже GREEN.
Syntax01 остановился на отсутствующих L1 tail cutters; его лог и точный
failed source сохранены. Syntax02 исправил только эту запись.

12 inherited role translations +6 path-role translations raw-сохраняют
прежние L1/diagnostics.20 stronger runtime cells из46 повторены47:
16 program7/4 ordinary runtime implements2, не compile refusals.
Новый [byte-identical witness](../witnesses/used-scope-20261020/receiving-role-dynamic-classes.lm2)
из `build/codex_use_ports47_cases_02/dynamic-two.lm2` добавляет4 actual
O2/fstrict runs: два differently named actual methods0/1 вместо пустого
prototype3, переставленные Candidate поля, Model.x1/y2 против Candidate.x7/
y99 и `x*10+y-162=7`. Асимметрия не скрывает перестановку x/y.
`build/codex_use_ports47_values_01`: оба source engines и оба root routes.
Ранний симметричный source/probe01 сохранён отдельно и не подменяет02.

`build/codex_use_ports47_audit_01` независимо повторил все24 неизменённых
runtime binaries с явными argv/реальным OS cwd, хешами source/graph/exe,
всеми explicit fn IDs и строгими13/15/17/19 checks. Итого48 исполнений,
24 source/mode/root cells,20 positive7/4 ordinary refusal2.467 completed
checked pins `build/codex_use_ports47_completed_01.inputs.sha256`.
Новых allocating sites здесь нет; прежние fault proofs не выдаются за
новый полный OOM/gate.

Граница: helper пока читает diagnostic dump/unit, не backends/admission.
Это адресная проекция для будущего общего Consumer, **не** удаление ruse.
Старый scanner/global spelling fallback и все требования общего замыкания
по-прежнему OPEN. Широкого replay/full gate47 нет; public dev остаётся44/33.

Mixed recipe04 записал3 из4 source fn IDs у nestedrefs; independent audit02
добавил четвёртый на тех же скомпилированных и реально исполненных
бинарниках. Audit01 искал harness command headers в stdout-only private
logs и сохранён RED.02 повторно исполнил64 с записанными argv/OS cwd;
13/15/17/19 driver assertions проверяют ordinary/refusal/cleared-root
режимы, а четыре дополнительных root assertions действительно очищают
root native в том же pinned driver. Оракулы программ и бинарники не
подкручивались.11007 checked pins:
`build/codex_use_roles46_completed_01.inputs.sha256`.

Private46 **не переносился** в dev. Это законченная проверка foundation,
не полный Consumer: новые roles ещё не используются для permission,
старый ruse/scanner/global spelling test существует. Следующий срез
должен замкнуть bound requirements по actual receiving ports и полному
semantic cursor, включая selected own/formal/capture/node/control/index/
address, затем удалить legacy маршруты без fallback. Unknown не пустое
разрешение; Model declaration не constructor evidence; callable prototype
не фактический body. Native/walker должны получить тот же resolved use
и карты каждого шага, а не свой повторный поиск. Нужны сохранённые
control/taint/sparse/negative witnesses, настоящий runtime и общая матрица
до приёмки; full1004 FAIL и §§8/8a не закрыты. Все новые очереди завершены,
Codex остаётся writer/build, goal active.

<a id="consumer49"></a>
## Private48/49: runtime ruse scanner удалён, общий Consumer ещё не принят

На49 `l2_ruse_scan_*`, `l2_ruse_follow`, `l2_ruse_named_by_path`,
spelling/definition/формальный body-compose обход удалены, не оставлены
fallback.909 строк прежнего блока заменены finite bound equations.
`L2UsePlanLevel/Edge/Link` — compiler-only требования, не новый value/
source graph и не Lmx поля. Query key — method/place/required schema;
source occurrence — original fact и cursor в полном prepared grammar.
Typed Model не считается физическим constructor кандидата.

Original scopes берутся из source inventory и semantic resolver;
receiving ports — из CHECK, actual callable implementations — из того же
CFL closure, hidden captures/value flow — из существующих D105 edges.
Отсутствие role/класса/валидного inventory не становится пустым разрешением.
Typed return без конкретного Consumer сохраняет full structural fitness.
Проверенные call edges определяют достижимые source Consumers: одна
definition/value formation не означает исполнение тела. Новый обход P0
по написанию и разворачивание тела не используются.

Query equations дедуплицируются, nested anonymous scopes остаются
раздельными. Alias fixed point не объединяет child scopes: совпадающие
field obligations могут оставаться двумя conjunctive entries с разными
`below`. Runtime walk использует тот же индексный uses protocol.
Это предотвращает перенос требования одного вложенного значения на
соседнее через общий downstream formal и не вводит pass/depth limit.
Повторные поля здесь — **требования**, не дополнительные поля Lmx data.

49 source `38c668a6d6666ee97f30f9b85d16b9ec05879a72c8ebd09b812eb67627da5f37`,
header `14b6468d9ea03f8205831e8294440aac71a4595cda25e30843bc49160669a4ae`,
actual C `e763bf5861d5a1650aeeb3e317fa40e55d28d5732aa05481341285695005d6d9`,
debug exe `27342a653171bd976e0b609efec03f44a2b967968641afe7314a29170eae70e9`.
Actual48/49 собраны с четырьмя guards;49 source-linked unit32+24+31+33
прошли.33 новых assertions включают finite recursion, exact alias closure,
раздельные nested scopes, identity empty vs unknown full, forwarding/
return contract, OOM без partial publication, duplicate requirements и
счётчик uses topology без физической ширины, release/live balance.

Первый48 native/walker probe RED: COUNT спрашивал реальные coverage cells
до PLACE. `build/codex_consumer48_place_01.gdb/.log`: row0/slot0 уже
выбран, physical width0, отказ в `l2_ruse_cell`.49 отделяет topology
от values: COUNT берёт готовое число cells/extent, не вызывает projector;
FILL/native читают те же stored semantic coordinates после layout.
Нет выдуманного нулевого slot/width для ранней фазы. Failed source/C/logs
48 сохранены. Его первые два C build также RED из-за L1 `prototype:`
как reserved receiver и dotted embedded member в argument;03 устраняет
запись через selected_proto/local key, не изменяет языковую норму/oracle.

### Значения, отказы и оставшийся положительный RED

`build/codex_consumer49_values_01` —28 реальных O2/fstrict cells:
control/taint/compare/forward/node/identity по4 маршрута дают7,
required-y по4 даёт ordinary runtime implements2. Это не compile refusals.
[Control-x1](../witnesses/used-scope-20261020/receiving-consumer-control-x1.lm2)
и [taint-x1](../witnesses/used-scope-20261020/receiving-consumer-taint-x1.lm2)
raw-равны исполненным source: Model.x1 не подменяет Candidate.x7.
Постороннее одинаковое имя больше не меняет результат receiving Consumer.
Identity-only candidate — пустая Structure при непустом Model.

`build/codex_consumer49_values_02` намеревался исполнить32 positive cells:
28 выполнены с7; две translation refusals `scopes native/walk`
оставили4 cells неисполненными, matrix **RED**, а не32/0.
[Dynamic partial](../witnesses/used-scope-20261020/receiving-consumer-dynamic-partial.lm2)
исполняет две actual реализации с differently named formals, требует x/y,
но не требует third Model field unused; переставленный Candidate и
асимметричное `x*10+y-162=7` проверены во всех4 маршрутах.
Другие24 успешных cells — те же nested/node/40-step и mixed crossing/
nestedrefs fixtures: реальные значения, write, read через взятый адрес,
intact model/neighbors, exactly-once indices. Исходные oracles не менялись.

[Nested scopes](../witnesses/used-scope-20261020/receiving-consumer-nested-scopes.lm2)
не заменён удобным отказным тестом: требуемое значение7 остаётся.
GDB49 `build/codex_consumer49_nested_01.gdb/.log`:
parent cand4→req1, `kind2 required_model2 actual_model6 physical_hit1`;
после найденного физического поля `l2_d105_cell` возвращает старую
границу slice1. Native/walk на47 отвергают тот же source тем же текстом;
это preexisting restriction, не новая регрессия49. Нужен общий nested
pair-map producer/transactional publication во всех движках, не удаление
guard без подготовленных вложенных карт и не flatten этого witness.

Независимый `build/codex_consumer49_audit_01` повторил все56 завершённых
cells неизменёнными binaries:52 positive7/4 ordinary refusal2, все
explicit source fn IDs, argv/реальный OS cwd, source/graph/exe hashes
и строгие13/15/17/19 checks. Итого112 executions56 cells; четыре
положительных nested-scope cells по-прежнему не исполнены.

38 реально записанных `source-use-consumer level/alias/edge/reachable`
allocation notes × absent/existing destinations =76 fault invocations,
0fail/live0/old output preserved. Скопированный footer recipe/results
`codex_consumer49_alloc_01` ошибочно говорит «source-use-role receiver»;
records и injected ordinals относятся к equation sites. Сырые файлы
сохранены, scope correction — в selected verified JSON. Это не все
OS allocations и не новый полный OOM claim.

### Replay и границы приёмки

3715 invocations full44 повторены с exact argv prefix/реальным OS cwd:
3566 SAME,149 changed L1;0 EXIT/MSG/OUTPUT/INCOMPLETE. Все3715
source/log/output hashes, argv/cwd independently checked.149 changed L1
не нормализованы и не названы эквивалентными по grep/тексту.
Отдельный full49 проверяет их через прежние поведенческие assertions.
3200 frozen inputs сравнены с frozen44: отличаются ровно frontend/header.
14151 selected checked pins:
`build/codex_consumer49_selected_01.inputs.sha256`,
scope correction `build/codex_consumer49_selected_01.verified.json`.
Это selected receipt, не completed full49 и не pre-start manifest.

Full49 завершён actual1, RED3729/1003: к полному44 нет regressions,
newFAIL, removed или changedCommonFAIL; fixed1 — thin third candidate.
3988 staged inputs raw-сверены, actual frontend C равен reviewed49.
30416 checked completed pins:
`build/codex_consumer49_full_completed_01.inputs.sha256`.
В dev перенесён49/33: source/header raw-равны tested49, runtime unchanged.
Public production focus26/0 включает120 compiler metadata assertions,
8 новых source fixtures/16 rows и old thin candidate.28 positive7 и4
ordinary runtime implements2 через два source-method mode × два root
routes, плюс2 thin-candidate positives.201 staged inputs exact,763
checked public pins:
`build/codex_consumer49_public_completed_01.inputs.sha256`.
Новые equations пока заменили runtime own
receiving coverage; `l2_descriptor_used/l2_anchor_covers/l2_anchor_used`
ещё не потребляют всё это замыкание. Их CHECK до получения всех roles/CFL
требует общего staged результата, а не unknown→empty или раннего ложного
full отказа. Array/callable/code-part whole contract в coverage ещё не
доказывает все требования последующего чтения/вызова. Typed result,
field/capture/control/index/alias потребители и nested producer должны
получить единый результат без запасного маршрута. Full1003 FAIL,
clean kernel и §§8/8a остаются OPEN.

<a id="templates50"></a>
## Private50: подготовка nested views в том же DFS, без публикации до успеха

Следующий kernel-only prototype — `build/codex_mixed_path_fold_50`.
`lmx_implements_walk_project_resolve` — тот же прежний аналитический
DFS; старые public entry points идут в него без нового resolver. Новый
`admit_receiving_templates` передаёт operation-local context тому же
обходу: actual value/required addresses, genuine layout evidence,
подготовленные ordinal/LAST correspondences. Не имя, тело или отдельный
разбор пути. Шаблон не даёт permission: его proof/owned/exec fields
игнорируются. Unknown actual layout не заменяется конструктором модели.

`compose_view` выделяет только результирующие координаты; старый
`compose_receiving` сохраняет прежнюю семантику через него. Внешний
context держит стабильные scratch views и только временные computed maps.
Сначала один полный receiving walk, затем общий preallocated publisher;
при отказе любого потомка прежний cache/proofs неизменны. После успеха
owned map передаётся только записи, сохранившей эту же allocation.
Borrowed module/frame template maps не освобождаются и не присваивают
ownership просто фактом совпадения.

Actual unit04 O2/fstrict/four guards:275 новых assertions +54 неизменённых
pending/atomic assertions из исправленного historical10. Два представления
карт, отдельные A.y/B.x, B без y, значение7 не из модели, write/соседний99/
rebind через взятый адрес,36 cyclic nested levels; неоднозначный последний
шаблон, wrong width, absent physical evidence, compose по bound source,
alias-output protection и отсутствие fabricated full proof/layout.
Это **kernel data**, не L2 native/walker source-программа.

Fault04:12 реальных wrapped OS allocation positions для каждой из двух
форм maps/coverage, по baseline и12 fresh processes =26 actual invocations.
Все24 faults дают UNKNOWN без partial publication, старые entry bytes/
proofs сохранены; balance возвращается к process-entry baseline. Финальный
reserve faulted ровно по разу в каждом представлении. Ранний fault01
ошибочно требовал live0 всего процесса; GDB startup01 доказал4 живых
allocations до main из `__tmainCRTStartup`, поэтому04 проверяет дельту,
не скрывает runtime allocations.

Syntax01/02 RED (tail cutter и struct в body), C unit01 RED (неполные
стендовые headers), unit02 RED (dotted argument + старый несуществующий
size_load_known в historical05), unit03 RED (тот же старый test06).
Syntax05/unit04 используют уже проверенный historical10, без ослабления54
oracles; old failed sources/C/logs сохранены. Fault02 диагностический
wrapper сам не собрался;03 установил startup baseline,04 прошёл.
361 независимо проверенный pin:
`build/codex_impl50_completed_01.inputs.sha256`.
Публичный runtime33 не изменён. Compiler nested pair producer/closure,
выбранное общее хранилище и передача templates текущему графу обоим
backend, source scopes7, write/address values native+walker, GC/copy/
attach lifetimes и все static Consumers — ещё OPEN. Kernel prototype
не является разрешением просто удалить D105 boundary.

<a id="pair-plan52"></a>
## Private51/52: удержанный типизированный результат пары

Kernel50 default regression завершён327/0 actual0:308 staged sources
raw-сверены с frozen input;5124 checked completed pins
`build/codex_impl50_kernel_completed_01.inputs.sha256`. Дополнительный
O2/fstrict closure50 вместо closure33, без изменения source objects49,
дал32 actual cells:28 positive7/4 ordinary implements2, source native/
walker × root native/walk. Новый templates API ещё не вызывается ими.

В51 D105 selector resolution даёт `L2D105Step` с requirement/actual,
selector, physical/slot, status, child pair; `L2D105Plan` держит полный
набор и requirement/physical/source extents. Это compiler-only result,
не runtime graph marker. Изменения карты/типов/counts сериализуются в
тот же exact source planning fixed point. После seal `l2_d105_table`
только проецирует подготовленный результат; отсутствующий результат
отклоняется, а не включает старый fallback.

51 source-linked unit сначала упал на настоящем скрытом повторном
lookup: width initializer вызывал schema_width ещё до sealed guard.
GDB `build/codex_pair51_unit_crash_02.log` подтверждает маршрут.
Вычисление перенесено после guard; первый неудачный GDB invocation01
имел ошибку Windows argv и не является stack evidence. Второй RED
assert был в test setup duplicate x: бывший y сохранил kind size_t.
В test02 оба x имеют int, положительные ordinal0/LAST1 ожидания не менялись.
120 старых +26 новых metadata assertions прошли. Затем3715 original
full49 argv с реальным inherited OS cwd дали3715 SAME: source/output
hashes, invocation prefix, statuses и diagnostics отдельно перепроверены.
10369 completed pins: `build/codex_pair51_completed_03.inputs.sha256`.
Verifier01/02 failed до manifest;03 исправляет формат raw helper log и
descending empty-message slice, исключая лишь пустые wrapper lines.

52 дополнительно удаляет неиспользуемый old single-cell adapter и
блокирует сам preparer после seal. Unit перед замкнутым чтением делает
namespace metadata недоступной; чтение prepared map всё равно работает,
raw preparer возвращает явный4 без lookup, missing prepared pair —
отказ без fallback.27 новых+120 прежних actual checks;301 selected pins
`build/codex_pair52_selected_01.inputs.sha256`. Затем replay52 завершён:
3715 SAME к full49,0 changed/missing/incomplete. Все3715 argv/OS-cwd/
source/output identities и diagnostics independently checked;10328
completed pins: `build/codex_pair52_completed_01.inputs.sha256`.

52 перенесён в dev после production-route27/0:147 metadata assertions,
те же17 source fixtures (backend × roots),202 staged input bytes exact.
Actual compiler C равен private52, runtime closure C равен full49;
768 public checked pins
`build/codex_pair52_public_completed_01.inputs.sha256`.
Runtime50 остаётся private; nested positive остаётся RED. Удалять status3
для разных вложенных моделей можно только вместе с общей source producer/
transport до native и walker. В частности, root selection должен
использовать тот же bound-template resolver, что и children: нельзя
объявленную source/model карту выдавать за actual candidate layout.
Нужны реальные source scopes7, reorder/write/taken-address proofs,
копии и arena lifetimes. Transport должен сохранить текущий граф после
copy/edit, не удерживать адрес старого графа или Model constructor.

<a id="templates56"></a>
## Private53–56: общий root/child resolver и текущий frame

Проверенная реализация и постоянные tests перенесены в main: `d0dc3de9`.

53 убирает обязательную root seed из нового templates API: root и каждый
child выбираются одним `resolved_view`. Existing exact records копируются
в stable operation context перед возможным reserve индекса. Непотреблённые
координаты не изобретаются: пустой identity-only Consumer может дать YES
без retained correspondence; последующий used x при неизвестной physical
layout остаётся UNKNOWN, а после настоящего layout evidence читает7,
не Model1. Проверен known physical root, для которого нет direct template,
но есть genuinely admitted source basis; композиция не отключается из-за
того, что physical layout известна. Старый setup первого unit53 ошибочно
пытался register root до child evidence; корректный setup02 использует
законный prior identity-only scoped admission с уже известной root map.
369+54 assertions/26 measured baseline+fault invocations прошли.

54 добавляет только representation adapter обычного текущего frame:
row count, затем source-layout/required-layout/width и две половины карты
каждой строки. За ним тот же analytical DFS и atomic publisher; coordinate
preparation не выдаёт receiving permission. Подмена proof/owned/exec полей
шаблона игнорируется. Selected copied frame действительно независим от
ancestor; edit текущей LAST координаты читается из этого frame, неизменённая
ordinal координата и взятый physical address не отображаются повторно.
Malformed count/extent/token/type/width отказываются без publication или
другого маршрута.773+54 O2/fstrict/four-guard assertions; typed metadata
и data frame × ordinary/frame coverage дают12/17 измеренных allocations
каждого baseline:58 injected refusals+4 baselines,62 fresh processes.
Каждый final cache reserve faulted; old records byte-identical и allocation
balance restored относительно доказанного CRT process-entry baseline.
671 checked completed53/54 pins:
`build/codex_impl53_54_completed_01.inputs.sha256`.

Полный54: **RED327/3**, не GREEN. Два link failures обнаружили новую
getter dependency: symbol-based loader подтянул перекрывающиеся
whole-source runtime units.55 читает те же known typed cells после строгой
domain/type проверки, не меняя loader и не смягчая tests.773+54 assertions
и62 fault runs55 повторены. Третий FAIL выявил ошибку опубликованного52:
`capacity` у `L2D105Plan` вне DynamicArray.56 меняет реальный контейнер
на `L2D105StepDynamicArray`, синхронизирует initialized size/semantic width,
добавляет shrink/restore/failed growth/sealed mismatch checks.120+33=153
metadata assertions и live capacity gate прошли; прежние positive/negative
oracles сохранены.652 checked selected pins:
`build/codex_impl55_pair56_selected_01.inputs.sha256`.

В dev перенесён compiler56/runtime55 с постоянными kernel value
и allocation-fault tests в обычном harness. Полный56 завершён **327/0**,
actual0;308 staged sources raw-равны frozen input,10205 checked pins
`build/codex_impl56_kernel_completed_01.inputs.sha256` сохраняют также
полный RED54. Four default hard guards — не blanket Strict/O2.
Replay56 завершён3715 SAME к полному49: statuses/diagnostics/graphs,
exact argv и actual inherited OS cwd/source hashes independently checked;
10327 pins `build/codex_pair56_completed_01.inputs.sha256`. Упомянутая там
value32 проверка kernel50 — историческая, не выдана за новое исполнение55.
Public production route56 **29/0**,153 metadata assertions,773+54 kernel
assertions,62 fresh fault processes,17 source rows.206 staged inputs
raw-равны dev/tools; actual frontend C равен private56, driver runtime C
равен private56 closure, unit runtime C равен actual55 unit/fault input.
850 checked pins `build/codex_impl56_public_completed_01.inputs.sha256`.
Обе source-method modes и оба root routes повторяют28 positive7/4 ordinary
implements2, плюс2 old thin-candidate positive7. Это регрессия старых
source APIs: compiler пока **не эмитирует** новый template-frame API.
Public56 повторно отклонил исходный nested-scope positive7 в обоих modes,
actual exit1/no graph: `build/codex_pair56_nested_open_01`. Он остаётся
OPEN positive, а не новым успешным negative test.
Это **не закрывает** source templates producer/transport, arbitrary source
nested scopes, все static Consumers или self-build. Старый status3 guard
остаётся, source positive7 не заменён refusal test. Native и walker ещё
нужно перевести с их отдельных root/default/identity selections на один
prepared catalog из выбранного current graph operand. Особо сверить
identity-class ambiguity/receiving scopes, чтобы общий catalog не стал
новым необоснованным whole-width отказом или Model-constructor fallback.

<a id="catalog57"></a>
## Private57–62: typed catalog и exact source operation metadata — WIP

База dev: compiler56/runtime55, реализация `d0dc3de9`, документы
`ed7802e0`. Ниже частные immutable inputs, не опубликованная реализация.
`build/codex_mixed_path_fold_57` вводит обычные compiler-only catalog rows,
заимствующие typed D105 plans. `l2_d105_catalog` выбирает seed pairs по
существующим source/receiving facts; одно worklist closure следует
`step.child_pair`, дедуплицирует циклы и согласует extent/count. Cell
adapter читает prepared physical coordinates, включая nested selector;
legacy status3 boundary не снят и источник positive7 не превращён в
negative test. No schema/name lookup после seal, missing sealed pair
не включает fallback. Width/type/extent/overflow и OOM проверены.
72 cyclic pairs замыкаются в361 cell без ограничения глубины.

57 actual compiler checks:120+50=170.58 временно вызывает общий catalog
из native и COUNT/PLACE/FILL:17 focus programs translated; replay3715
дал3713 SAME/2 changed L1, без изменения exit/diagnostics/presence.
Два changed cursor graphs переставили pair IDs1/2 вместе с uses/maps;
bytes не объявлены тождественными.59 сохраняет catalog как payload
existing expression-site role3: exact source operand run, executing
method/view, receiving port по canonical input-row pointer, requirement,
mode/own и bound current GraphPlace. Snapshot сериализует стабильные
факты и pair IDs, не адрес свежего allocation. Это compiler metadata,
не opcode/служебные поля/ещё один граф Lmx.

`build/codex_catalog59_values_03`:38 actual source/root cells actual0,
new program objects O2/fstrict/four guards, immutable completed runtime55:
17 programs59 ×2 roots и2 changed58 ×2 roots. Сохранены exact production
driver argv/value/refusal expectations, commands/cwd/hashes в results.json.
Нужно брать все recorded ABI hooks, не только переименование main:
failed recipes01/02 (link и observer wiring) сохранены, не названы
языковыми отказами. Эти программы **ещё используют старый map protocol**;
значения не доказывают template transport или nested positive acceptance.

59 binding probe потребовал exact retained ADMIT для каждого native
приёма и выявил167 diagnostic EXIT на прежних source successes:
`build/codex_pair59_replay_01/summary.txt` (terminal session40596).
GDB показал две реальные потери compiler metadata: hidden source had
NULL origin; receiving context idx подставлялся вместо executing owner.
60 явно проводит original call event и executing method через общий
hidden admission chain. Factory capture с обеих сторон использует
существующий узел фабрики, не последний diagnostic cursor. Одноимённый
input не ищется в другом событии. Public execution behavior не менялось.
Failed60 compile attempt01 сохранил старые forward declarations; input
preimage и C/logs в `codex_pair60_attempt01_source`/syntax01/build_unit01;
02 исправляет настоящие декларации, не флаги compiler.

Повтор исходных167 cases на60:14 diagnostic EXIT/153 changed L1.
61 отличает at_mi (активация отказа) от input port результата, который
отсутствует: receiving key канонизирован в -1/-1.176 actual assertions
(120+56), в том числе executing owner, distinct canonical ports, отсутствие
neighbour cursor fallback и result key, прошли; повтор167:9 EXIT/158 L1.
Остаток: `unit_callable_formal_site_names_reference`,
`unit_callable_formal_site_reference_forwarded`,
`unit_callable_formal_site_reference_unasked`,
`unit_formal_recv_classes{,_walk}`, `unit_formal_recv_models{,_walk}`,
`unit_formal_recv_static{,_walk}`. Это не новый normative refusal.

GDB `build/codex_admit60_unit_formal_recv_models.gdb.log`: retained event
несёт только req0/target2, native на том же event требует req1/target3.
В `l2_rw_call_at` уже существующий `sneed > 1` ставит machine-only и не
строит hidden inputs всех actual CFL classes; native выбирает их отдельно.
Просто выбрать retained req0 для остальных классов — неверно. Нужен
общий producer всех receiving variants, привязанный к текущему selected
CALL/contract, с одним transport для обоих движков. Descriptor/prototype
не заменяет actual callable Consumer. Отсутствие ADMIT в native-only
ветви не разрешает брать соседний узел или AST/Model fallback.

62 сохраняет producer/retained metadata без экспериментального native
запрета59–61; старые backend selection loops пока явно остаются. Это
подготовительный срез, не переключение transport. Dev исходники ещё56.
Immutable62 syntax01 и metadata build_unit01 завершены actual0,
176 assertions, session57007 terminal. Lifecycle17 translated actual0;
full translation replay01 session86605 идёт. Values62 recipe01 завершён
до GCC на проверке отсутствующего ещё replay output `unit_ns2_ref_return`;
каталог01 не перезаписывать. После replay продолжить02 на тех же oracles.
Inherited footer syntax recipe всё ещё говорит Pair52; это не версия
исходника: actual62 C/exe лежат в названных62 inputs/outputs и pin-ятся
отдельно. Результаты обновлять по реальным завершениям, не по quiet logs.
Native/walker typed-frame transport,
все actual-class contracts и source nested-scope positive7 остаются OPEN.

429 selected raw pins57–62 независимо перепроверены:
`build/codex_catalog62_selected_01.inputs.sha256`. Они сохраняют actual
C/exe/headers, source snapshots, unit/failure logs, completed probe
summaries и GDB; ещё живой replay62 и будущие runtime cells62 не выданы
за completed evidence.02 value recipe подготовлен с проверкой наличия
всех inputs до создания output directory. Multiple-class CALL boundary
остаётся machine-only: оба root routes не доказывают pure walked call
этих классов. Checks docs и staged diff прошли; переноса dev62 пока нет.

<a id="catalog63"></a>
## Private63: source-emitted current catalog и все actual receiving ports

Это private dependency WIP, dev остаётся56/55.62 replay завершён:
3715:3248 SAME/467 L1,0 EXIT/MSG/OUTPUT/INCOMPLETE; session86605 terminal.
`codex_catalog62_values_02`:78 actual O2/fstrict source/root cells actual0,
session87394 terminal. Эти результаты не приписаны63.

В63 `l2_rw_catalog_frame` эмитирует реальный ordinary frame по retained
typed rows: source/required tokens, physical width, ordinal/LAST cells.
COUNT и FILL используют один count/extent; malformed count/extent не
публикуются. Nested selector берётся из prepared child pair, не из нового
поиска поля. `l2_rw_receiving_record` создаёт ordinary three-cell data
(catalog, optional coverage, mode). Exact source-event/owner/port остаётся
compiler metadata, не попадает в граф как marker/opcode.

Недостающие actual callable variants сохраняются в существовавшем пустом
long CALL/EXEC slot4. Старый комментарий называл его rtype, но actual
walker читает result type из return-part контракта и slot4 не использует.
Не добавлены поля fn, вторая signature или shape-based call classifier.
Производитель следует реальным CFL class heads, сохраняет дополнительные
формальные и нужные hidden receiving ports; прототип не добавляет Consumers.
Declared formal уже имеет свой ADMIT, его не дублируют. Пока multiple-class
CALL остаётся machine-only; новая data ещё не исполняет эти вызовы обходчиком.

Снова включён exact binding assertion для ВСЕХ native model admissions,
кроме construction-time seed work (outcome): running operation не имеет
запасного поиска.9 прежних пропусков translated actual0. Полный63 replay:
3715:3240 SAME/475 L1,0 EXIT/MSG/OUTPUT/INCOMPLETE, actual0,
session73410 terminal. Diff не назван byte-SAME. Metadata:120+60=180
assertions actual0 (четыре прежних units в build_unit02 и pair в pair_unit03).
78 actual O2/fstrict source/root cells63 actual0,
`build/codex_catalog63_values_01`, session43606 terminal. Ordinary values
ещё используют old backend map protocol; source nested positive7 OPEN.

Отдельная интеграция producer → common kernel frame adapter:
`build/codex_catalog63_runtime_frame_05`,19 O2/fstrict/four-guard assertions.
Без правки generated C настоящий `l2_program_build` создаёт программу
`unit_formal_recv_models`; test-only typed-store observer фиксирует точный
emitted Wide→Other catalog. Свежий candidate имеет physical Wide evidence,
но не имеет target entry, который позволил бы обойти decoder. Ordinary
copy catalog независима от ancestor; ancestor coordinates испорчены, но
selected copy даёт actual41, не pad99/Model5. Проверены mapped write73,
взятый physical reference-cell address и rebind88, edit текущей LAST map,
отсутствие повторной проекции адреса. Malformed row count даёт UNKNOWN,
не публикует partial entries, прежняя correspondence byte-identical.
Это интеграция **constructor data с kernel API**, не заявленное подключение
нового API к native/walker executable body и не language nested-positive.

Failed setups сохранены, production producer не подменялся ради oracle:

- Syntax63/01 — отсутствовал L1 tail cutter перед dedent; source preimage
  `codex_pair63_attempt01_source`,02 исправляет настоящий источник.
- Pair unit02 — Windows `tmpfile()` вернул NULL (GDB confirms), а не
  catalog failure. Unit03 даёт явный output filename;60 checks actual0.
- Runtime-frame01 — L1 запущен не из staged source cwd; нет нужного predef.
- 02 — observer не включал arena_refs header; четыре hard guards отказали
  compile, actual runtime/program objects при этом построены и сохранены.
- 03 — observer ошибочно ожидал логические widths2/1 и physical x1. Реальный
  source graph имеет widths4/2, x2, auxiliary hole и второй actual source
  token.04 использует полные physical descriptors, read/write oracle тот же.
- 04 —18 проверок прошли, последняя неверно держала адрес ImplEntry через
  возможный arena-index reserve.05 сравнивает stable record bytes с новым
  lookup после операции;19 actual0. Pointer stability не объявлена ABI.

Полный frozen L2 gate63 **запущен, не завершён**:
`build/l2_harness/codex_catalog63_full_01`, session85484,
PID17480, startedUTC `2026-10-20T17:57:41.1448152Z`.
3209 tracked sources/36 tools; explicit overrides source/header63 и60-check
test. Named output argv добавлен лишь этому unit вместо Windows tmpfile.
Ни один source-value/refusal oracle не ослаблен. Единственный GCC pipeline;
не дублировать его по quiet log. Перед переносом сравнить actual FAIL-ID
с full49 и source/runtime bytes; selected results не заменяют full receipt.
Следующий кодовый шаг: единый receiving-record transport обоим backend,
source identity/Consumer-scope closure и реальные nested/write/address proofs.

674 selected raw pins63 независимо перепроверены:
`build/codex_catalog63_selected_01.inputs.sha256`. Actual compiler C/exe,
headers, emitter/unit snapshots, failed setups, generated program objects,
immutable runtime closure и78 source/root logs включены. Живой full gate
исключён. Этот selected receipt не выдан за проверку всех replay output
bytes или completed full gate; такую сверку выполнить отдельно до переноса.

<a id="receiving64"></a>

## Private64 — общий receiving-record transport, PREBUILD, 2026-10-20

База dev остаётся implementation d0dc3de9, docs 61529305. Private64
начат копией63, не меняет frozen63/input полного gate. Sole writer/build
Codex, goal ACTIVE; единственный живой GCC pipeline по-прежнему full63.

Новый runtime adapter принимает обычную текущую тройку
[catalogFrame, optionalCoverageFrame, modeSize]: coordinate0, full1,
scoped2. Он проверяет domain/type/shape и передаёт данные тому же
admit_template_frame → analytical resolver/DFS/publisher, без собственного
выбора полей/источников и без native/model constructor fallback.
Unknown coverage не означает empty Consumer. Не добавлены Lmx opcode,
поля fn или runtime-имена.

Compiler64 свёл l2_rw_admit_project_at к пяти физическим operands
[ADMIT, record, payloadFromLetter, candidate, model]. Flag не удалён:
он действительно эмитируется при приёме payload письма; candidate/model
остались в slots3/4. Role3 точного source-event/owner/port теперь хранит
место record, а не всего ADMIT. Native загружает его из текущего code через
общий retained GraphPlace; отсутствующее/повреждённое место не ищется
рядом и не восстанавливается из P0. Walker оценивает candidate один раз,
извлекает payload при реальном flag и вызывает тот же kernel adapter.
Их прежние source/default/alternative/identity selection loops удалены.

Seeds — construction work, не runtime code lookup. Они строят тот же
data record из того же closed catalog; cell writers общие с RW FILL,
карты живут в arena, не в borrowed stack arrays. Constructor failure
остаётся return:1, live construction failure — существующий invariant
failure. COUNT сохраняет точные record/catalog/coverage topology и
проверяет count/extent, FILL пишет реальные координаты. Мёртвые
l2_rw_map_inline и l2_ruse_emit_native удалены, а не оставлены запасом.

Это **не** закрытие всех путей и Consumers. Legacy l2_emit_occ_admit,
flat table consumers, ранний status3, source nested positive7 и
machine-only multiclass CALL ещё требуют общего решения. Старые ручные
ADMIT fixtures пока имеют прежнюю физическую форму и подлежат явному
переносу; их положительные ожидания нельзя превратить в отказы.

Сейчас выполнена только pinned L1 translation:
build/codex_receiving64_syntax_03 содержит actual frontend/runtime/walker/
driver C и headers. Syntax02 preserved: просмотр его actual C выявил
catalog . extent в argument span, который L1 неверно разложил на C
tokens;03 использует явный typed pointer/scalar и больше не содержит
этой формы. Это source syntax correction, не посчитанный GCC-pass.

Prepared tests, **не исполненные результаты**:

- build/codex_pair64_test_01.c: прежние60 assertions сохранены, ещё3
  проверяют receiving-record COUNT/FILL и unknown-coverage/full mode.
  С четырьмя прежними metadata units ожидается183 assertions.
- build/codex_receiving64_runtime_frame_01.c: ожидается32 assertions.
  Настоящий неизменённый constructor63 создаёт receiving data; observer
  не подменяет producer. Проверяются ordinary copy/edit record, typed
  mode/coverage, actual41/write73/address/rebind88, no double projection,
  malformed/atomic refusal. В отдельном plain body без native тот же
  current record должен пройти forced walker read/write/address/deref
  и implements-refusal. Это не весь source-generated body transport.
- build/codex_receiving64_build_01.ps1 последовательно строит frontend,
  metadata units, actual runtime64 driver O2/fstrict/four guards и observer.
  Его hard guard требует terminal63, исчезнувший прежний worker и
  отсутствие других GCC; рецепт пока не запущен.

23 explicit source/C/header/test/recipe/input pins независимо проверены:
build/codex_receiving64_prebuild_01.inputs.sha256. Это PREBUILD receipt,
не runtime proof, не full receipt и не разрешение переносить64 в dev.

Read-only inventory оставшихся consumers64 также явно нашёл живой
primitive route l2_rw_admit → lmx_walk_admit_against: четыре семейства
callers — typed take, EMPTY actual, opaque hidden input, factory hidden
input. Native l2_emit_admit тоже ещё вызывается. Эти пути нельзя выдать
за переключённые или оставить запасом после общего transport. Сам
adapter без templates для неизвестного source не является разрешением
угадать физическую layout или заменить неизвестный Consumer пустым.

Подготовлен дополнительный source discriminator:
build/codex_receiving64_live_map_01.c/.ps1. Он должен исполнить unchanged
unit_d105r_formal с исходным read10/exit7 и с изменённой CURRENT ordinary
Other→Model map, где read20/exit5. Сохраняются исходные program bytes;
test-only store hook меняет только завершённые catalog coordinates.
Ожидается8 процессов: native/forced-walk translation × native/walk root
× baseline/edit. Пока **не запускался**. Он нужен, чтобы native со
старыми константами не прошёл под видом нового transport; чистый forced
walk отдельно требует отсутствия machine binding у всех трёх методов.

<a id="scope66"></a>

## Private65/66 — current receiving transport и общий Consumer scope

Full63 закончен:3752/1003, actual exit1, session85484 terminal. Exact
множество1003 FAIL-ID равно baseline49; все23 добавленных target ID OK
(5 compiler metadata,2 template kernel/fault tests,16 source Consumer
fixtures). Actual frontend C byte-identical private63 C.
30731 raw inputs/evidence независимо rehashed:
build/codex_catalog63_completed_01.inputs.sha256. Исключены все
l2_driver_launch.err без чтения. Это честный inherited RED, не GREEN.

Failed64 compile — старая декларация receiving_record и отсутствующие
prototypes двух coverage helpers; исходники/pins64 сохранены.65 правит
только declarations. Failed metadata65/01 был recipe setup: PowerShell
scalar splatting не передал filename. Direct named argv на том же
pair.exe даёт63/0; continuation65/02 повторил все183 checks без смены
compiler bytes. Runtime65 O2/fstrict/four guards исполнил32 checks
actual-emitted-record и настоящего plain walker body без native.
Проверены scope/mode, copy/edit record, write/read/address/deref, атомарный
implements-refusal; data созданы настоящим неизменённым constructor63.

Source65 проверил16 fixtures на обоих physical roots:14 GREEN, два
formal_recv_models abort3, не скрытая неудача setup. GDB break abort/slot
доказал getz, req token2/Zed, coordinate mode0 и composed map с дыркой z.
Старые selection loops не возвращены: причина — нет Consumer actual
formal в новом record. Запрет общей композиции тоже не решение:
существующий nested kernel positive требует composition при известном
physical layout через ранее доказанный source view.

66 обобщает существующий Consumer equation producer, не создаёт второй
анализатор: L2UseScope(method,key,schema,state,first,count,levels)
принадлежит compiler arena. Own/formal/hidden порты используют один
l2_use_scope_get, один finite L2UsePlan closure и один physical-cell fold.
Старые own-row arrays/API — view тех же range/edges для прежних consumers,
не второй solver. Кэш сбрасывается с source lifetime. Nested scopes не
объединяются лишь по schema или parent field. OOM не создаёт empty use.

Known actual formal/hidden scope эмитируется как обычная coverage frame
в том же receiving record (mode2). Unknown receiving-port use — full
interface (mode1), не прежний coordinate skip-holes и не empty Consumer.
Role3 payload хранит тот же prepared scope; native не вычисляет его
вновь, а читает current graph data. Runtime resolver65 и66 raw-identical.
Нового Lmx opcode, поля fn или runtime имени нет. Идентичность модели
по source schema не заменяет ни физическую evidence, ни Consumer scope.

Завершённые66 проверки:

- build/codex_receiving66_build_01, session55280 terminal0:
  metadata183,32 actual emitted-record/kernel/pure-walker checks.
- build/codex_consumer66_scope_unit_02:42/0, прежние33 checks сохранены;
  192 distinct compiler assertions, не двойной счёт повторённых33.
  Проверены actual/prototype, hidden и schema identities, один physical
  fold для own/formal и очистка scope cache.
- build/codex_receiving66_values_01, session58672 terminal0:
  16/16 source fixtures,32 root cells с исходными value/side-effect
  oracles; оба formal_recv_models снова правильно отказывают до tick.
- build/codex_receiving66_live_map_01:8/8 процессов. Unchanged source
  unit_d105r_formal даёт read10/exit7, edit текущей обычной карты даёт
  read20/exit5, native/WalkMethods translation × оба roots. WalkMethods
  artifact действительно имеет0 из3 machine bindings, а не просто
  второй root, вызывающий native.65 также имел8/8 в live_map02.

Failed live-map65/01 preserved: observer ошибочно ждал logical width2;
actual Model/Other/merge имеют token0/1/2, physical width4, значения в
slots0/2, остальные source cells — executable initializers.65/02
исправляет observer по actual source data, не меняет producer/program
bytes и сохраняет оба baseline/edit oracles.

Завершены Consumer values66:21 fixtures/42 root cells; вместе с values66
это37 fixtures/74 cells. Replay66:3715 =3183 SAME/532 changed L1,
0 EXIT/MSG/OUTPUT/INCOMPLETE. Независимая проверка JSON/source/diagnostic/
output hashes и отдельное сравнение executable/исходного argv/CWD сделаны.
Selected65/66 receipt11315:
build/codex_receiving65_66_completed_01.inputs.sha256;
build/codex_receiving66_replay_argv_audit_01.ps1/.log — дополнительный
audit после receipt. Отсутствующий intentional input имеет ABSENT marker.
Kernel66 завершён327/3: старые lmx_walk_admit_selftest,
lmx_walk_admit_use_selftest, lmx_walk_call_data_selftest. Переноса в dev,
закрытия nested-positive7 и multiclass pure CALL нет.

<a id="bounds69"></a>

## Private67–69 — общий coverage owner bound и прямой fixture port

67 переводит только ручной admit_use fixture на ADMIT5/receiving-record3,
catalog8 и отдельную coverage frame, без production compatibility parser.
Все положительные value/side-effect oracles сохранены. Три malformed-data
ожидания классифицированы как implements THROWN, не прежний shape INVALID.
Failed67/01 setup сохранён (три старых token writes портили record);
67/02 исправляет source-token cells и выявляет реальный bounds дефект:
count9 при physical owner4 давал YES, ещё два отказа были следствиями
ложной публикации. Это не основание ослабить неизвестную layout до
позиционной или запретить законную композицию известных source views.

68 правит один lmx_implements_use_cell для всех frame scopes: min2,
проверенный arena owner, declared extent <= owner.size-at, overflow.
Настоящий offset view с чужим prefix/trailer разрешён; raw metadata
имеет тот же minimum header. Private fixture68:21/0. Actual runtime68:
783+54 O2/fstrict/four-guard assertions (прежние773 сохранены +10 новых),
62 measured fault/baseline процессов,82 unchanged source/current-map
процесса и34 actual-emitted/kernel/pure-walker assertions.
build/codex_impl68_kernel_values_01,
build/codex_impl68_source_values_01. Kernel68 завершён327/2, actual exit1:
остались admit_selftest/call_data_selftest, старый admit_use уже GREEN.

Независимый public69 branch-free срез основан на public56/runtime55:
изменён ТОЛЬКО общий use_cell, ADMIT ABI и fixtures остаются прежними.
Runtime source SHA256 6D7C43F22CA488AE3DE9B1C1201638476CC04D5723E3BC9187338F79B0284D53.
build/codex_impl69_kernel_01.ps1 frozen3209 tracked inputs; session24758
terminal0, полный kernel327/0 без смены старых ADMIT ABI/fixtures.
Public69 добавляет к прежним773 постоянные16 assertions:10 helper bounds
и6 actual admission/value checks (в том числе2 вложенных read_slot).
Failed recipe69/01 ожидал787 вместо измеренных789/0; production source
и test C не менялись. Recipe02 повторил789+54 actual O2/fstrict/four-guard
values и62 measured fault/baseline процессов, session4181 terminal0.
Control на exact old public runtime даёт789/6: прежние773+54 GREEN,
красные только новые bounds, ложное разрешение и публикация map.

После переноса69 в dev public production focus завершён29/0,
session47862 terminal0:153 compiler-use assertions +125 path selections,
789+54 runtime assertions,62 measured faults и17 source fixtures с
native/WalkMethods translations и обоими physical roots. Native/walker
наблюдаемые values сохранены. Actual frontend C unchanged56;
driver C A25D9C6E512FDACCDE1886F53C4C2BB8CA6ED8175EFC550BA912EE8F0F7B46BD,
unit C F805A36A4BD632D87BD4BEED1E0C33CBF4271BE1FBC2FC0AE1A97523866B71D7.
Все3209 frozen kernel inputs и206 focus staged inputs raw-точны dev/tools.
6291 independently rehashed completed pins:
build/codex_impl69_completed_01.inputs.sha256. Отдельный completed67/68
receipt10985:build/codex_impl67_68_completed_01.inputs.sha256, включая
оба старых failed fixture setups, kernel66 RED327/3 и kernel68 RED327/2.
Во всех новых receipts err исключены до hash без чтения.

Guard и постоянные tests опубликованы c9cbbd9a. При этом весь private66/68
receiving transport не опубликован; два manual ADMIT fixtures, primitive/
static Consumers, nested source positive7 и multiclass pure CALL OPEN.
Живых GCC/replay процессов этого среза нет; goal ACTIVE, продолжать v3.

<a id="catalog71"></a>

## Private70/71 — один typed projection и роль значения resolved leaf

База public ccba4b2e (compiler56/runtime69), main/only writer Codex.
Private source71 продолжает68 receiving transport, не переносится в dev.
70 заменяет flat l2_d105_table на view общего catalog_cell и finite
pair child closure. Следовательно nested selected edge больше не даёт
искусственный status3 refusal. Typed field status остаётся child obligation,
не выдуманной пригодностью листа. Holes, primitive type disagreement,
sealed/OOM/count tests сохранены; pair unit63 меняет старый boundary
oracle на реальные общие parent coordinates, не позитив на отказ.
192 distinct compiler-use assertions70/71 GREEN.

Original source positive7 неизменён, SHA256
6D9270456C7B51B98A3BC0575BE961C4D21BF66A3614AC06C7ABAD91C3CBA276.
build/codex_catalog70_nested_values_01: walked methods7 на обоих roots,
native abort3 на обоих. Нативный L1 показал legacy register_map перед
readX(m\\B), то есть data leaf ошибочно прошёл как callable occurrence
из-за ns_proc.71 меняет общую value classification обоих path spellings,
используя готовую terminal role, не новый path parser и не source names.
Для явного call обычная Structure по-прежнему имеет свою procedure.

build/codex_path71_value_roles_01:12/0, включая genuine callable field,
callable/noncallable formal, ordinary Structure/payload, invalid/absent
resolved record и namespace metadata=NULL после разрешения. Тесты
показывают, что никакого fallback lookup для value role нет.
build/codex_catalog71_nested_values_01: original positive7 —4/4 actual
O2/fstrict translation/root cells. Новые witnesses nested-write и
nested-address (в этой папке witnesses) — ещё8/8. Запись/readback через
взятый адрес, тот же явный путь, соседний A.x=99 и B.x=9 сохранены.
Machine bindings: native10, WalkMethods1 (только root launcher m9);
readX/go и nested procedures truly walked. Runtime object raw68,
новых runtime API/graph fields/opcodes нет.

Failed orchestration setup71: chained shell смотрел UNSET LASTEXITCODE
после bounded-process-only build; поэтому закончил после metadata и
не вызвал вторую nested command. Сам build завершён GREEN, это не
результат nested исполнения. Отдельный прямой nested71 запуск реально
создал все4 rows и values7; они приведены выше. В новых37-case recipes
добавлен явный exit0, чтобы unset shell state не маскировал продолжение.
Первый apply_patch70 был atomically rejected из-за обратного порядка
двух hunks; до компиляции повторён в source order, preimage не менялся.

Catalog71_values_01 и consumers_01 завершены, session6608 terminal0:
прежние16+21 fixtures,74/74 root cells с неизменными oracle/argv/CWD.
Shared runtime driver68 object сохраняется с origin hashes, а не
заменяется старым66. catalog71_live_map_02 завершён8/8:
read10→20 при изменении current ordinary map; native bindings3,
WalkMethods bindings0. Живых GCC процессов нет.
Failed setup71/live_map01 проверял старый build/runtime.o, которого
в новом standalone recipe нет; остановился до GCC/создания out.
02 меняет только guard/link на реальный unchanged68 renamed.o.
Translation-only replay71 session82839 завершён, terminal0: к49
EXIT7 (все1→0/outputFalse→True),3176 SAME/532 L1,0 INCOMPLETE/MSG/OUTPUT.
Independent replay_delta01 перепроверил actual inputs/diagnostics/output
hashes и CWD по всем3715: к66 identical3698, changed L1=10 и7 exit1→0,
ни нового отказа, ни changed refusal. Это не значит7 value successes.
Recovered values:7 targetIDs —5 физических source files, _walk — alias.
Четыре distinct source positives (d112,d113,path-transport-nested,s7-shape)
дали7 во всех16 cells. Reference-pointee ns2_ref_admit —4 RED cells;
native abort3, walked exit1. Batch recipe01 сперва остановился на
несуществующем alias source, первые3 cases сохранены; отдельные remaining
cases и recovered_audit02 проверили все20 реальных values без подмены
ожиданий.10 changed-L1 fixtures завершены20/20 с прежними argv/value
oracles, catalog71_changed_values_01; session31611 terminal0.
Включены deep40 path expression/return/ordinary value cases. Живых
GCC/replay jobs нет. Supplemental completed71 receipt9983:
build/codex_catalog71_completed_01.inputs.sha256; actual replay,
recovered/changed value cells, debug rebuild/traces и failed setups
независимо rehashed. Reference RED не выдан за успешный refusal.

GDB reference_trace01 на O2 не увидел optimized locals; debug01
пересобрал ТОЛЬКО тот же runtime68 C с O0, неизменённый O2 program.o.
Это диагностика, не новый value gate. Trace02 нашёл abort до тела;
trace03 ошибочно читал resolver=NULL у прежнего constructor admission;
04 условно показал реальный NO: mode2,rows1,edge2/below7, view_ready1,
отказ до primitive leaf, root map holes. Frontend plan01 сначала
поставил breakpoint на не тот путь C (stage vs compiled build);02 на
actual build C зафиксировал kind10 physical0/modelABI100 обеих сторон,
child_pair=-1. Следовательно retained field result теряет тип pointee
Inner/Box, сравнивая type_word, а не закрывая child contract. Упрощать
это до совпадения ABI или делать local native fallback запрещено:
нужен общий bound pointee contract и общий reference-aware DFS,
с declared model отдельно от current/null value и типизированным
pointer-pool read. Это следующий dependency, ещё не implemented.

Selected70/71 receipt1106 independently rehashed:
build/codex_catalog70_71_selected_01.inputs.sha256. Содержит completed
source/metadata/12 new+74 old+8 map value cells и failed70/recipe setups;
НЕ включает replay output, recovered/debug/changed-values после него.
Полного kernel71/L2 re-gate и promotion нет;
primitive/static consumers, manual ADMIT fixtures и pure multiclass CALL
не закрыты этим срезом. Goal ACTIVE.

<a id="references75"></a>

## Private72–75 — declared pointee, общий DFS и единственный typed reader

База26210cbf, sole writer/build Codex; public dev остаётся compiler56/
runtime69. Ниже — private source/result evidence, не объявление всего
receiving transport принятым или опубликованным. Все новые SHA/pins —
raw SHA256, err исключён ДО чтения/хеширования.

72 добавляет `L2SchemaField.pointee` отдельно от машинного `model` ABI.
Namespace/own/merge source declaration связывает тип до sealed emission.
Kind10 pair edge удерживает тот же selected physical slot и child_pair,
если оба структурных pointee известны и машинный ABI совпадает. Разный
foreign ABI, отсутствующее provisional binding и malformed ordinal
не превращаются в совпадение типа.20 новых metadata checks + прежние192
проходят. Actual reference source72 RED4: root edge появился, но child
не был допущен; диагностика уже missing admitted-reference child map.

73/74 передают declared Model обычными данными. Receiving record теперь
ровно4 cells: catalog, coverage, mode, referenceContracts. Нет старого
декодера record3. Reference frame=[count, triples(required layout token,
physical required field, declared pointee Model graph address)]. Это
требование декларации, не текущее значение pointer cell: null exemplar
не означает отсутствие типа. Graph copy переносит эти обычные ссылки
той же картой. COUNT/PLACE/FILL учитывают отдельный frame/точный extent;
constructor seed и исполняемый source record используют один cell writer.

`L2D105Catalog` замыкает required type identities через ТОТ ЖЕ retained
`L2D105Plan`/`L2D105Step`, включая identity-only и recursive requirements.
Это не candidate layout evidence и не новый parser/проверяющий обход
путей. Sealed consumers не вызывают schema/name resolver. Reference-count
и typed-step extents проверяются перед COUNT и FILL. Pair unit63→65
сохраняет прежние проверки и усиливает owner/count; reference unit20→28
проверяет required closure, stale count/steps и sealed metadata=NULL.
Всего194+28=222 distinct compiler assertions. Старый текстовый footer
build74 ещё пишет192/unchanged68; это устаревшая подпись recipe, не
источник результата: actual compiler logs65/42 и runtime C/object/link
в той же папке фиксируют действительные входы.

`lmx_implements_walk_project_resolve` нормализует typed reference через
общий pool callback, затем продолжает СВОЮ ЖЕ очередь child frames и
общий resolved-view/publisher. Field maps, primitive mismatch, recursive
seen set и атомарная публикация не вынесены в native или interpreter.
Null, который только держат, допустим; конкретный отсутствующий путь
не сертифицируется. Full type admission не изобретает объект для null.
Foreign pointer без structural declaration не получает guessed Model.

Actual74 evidence:

- Исходный unit_ns2_ref_admit —4/4 oracle7 cells; reference-chain-address
  —4/4 (две переставленные reference edges, leaf x/y, write through @,
  тот же путь/адрес, untouched neighbors). Plain merge copy-address —4/4,
  copied leaf меняется41, исходный LeafActual.x остаётся7.
- Indexed-reference-write/refusal, mixed-reference-values и nested-
  reference-values —16/16. Индексы с side effects вычисляются в прежнем
  количестве; запись, dereference взятого адреса и caught refusal
  сохраняют свои реальные значения/исходную ссылку. Прежние nested
  scope/write/address —12/12. Всего40 actual oracle7 cells, не L2 success.
- Прежние16+21 fixture IDs —74/74 root cells с прежними argv/oracles.
  Independent `codex_catalog74_values_audit_01` проверяет114 completed
  rows, актуальные graph/exe hashes и forced bindings. В40 новых cells
  WalkMethods имеет только machine launcher1, пользовательские методы
  truly walked; inherited multiclass cases не объявлены pure walker.
- `codex_reference74_kernel_unit_01`:112 checks/0, включая80 typed
  reference edges, reordered physical x=0/next=1, actual address write,
  noncanonical C pointer-pool callback, null, malformed count и deep
  primitive NO без частичной публикации. Это kernel data, не дополнительный
  language/backend gate.

Прямой `@: copied TopModel merge(TopActual)` остаётся требуемым позитивом,
но74 отвергает его на L2 в обоих modes. Точный compiler71 повторяет тот
же старый отказ «merge expression is not lowered in this receiving
context»; ни одна value7 там не исполнялась. Новый witness сохранён,
не заменён отказным тестом. Plain binding — отдельный исполнившийся
позитив, не исправление прямой формы. Это прежняя открытая граница
[MERGE-RESULT-VALUE-PROJECTION](../defects.md#merge-result-value-projection).

Kernel74 завершён327/4, actual1, session77287 terminal. Два manual ADMIT
fixtures унаследованы68; admit_use перенесён прямо на record4 и сохранил
21/0. Два НОВЫХ FAIL — post_mpsc/post_take_refusal link duplicates:
новые вызовы pointer_pool/value_in из implements тянули allocation/root
object closure.75 переносит ровно существующие reader bodies из
value_owned в lmx_range, prototype — в arena.h. Source owner audit
сравнил оба тела после нормализации CRLF, нашёл по одному определению;
нет частной копии reader в implements, ABI/semantics не меняются.

Runtime75 actual O2/fstrict/four-guard: все114 source/root rows повторены
неизменёнными74 program objects; reference kernel112/0. Current record
map read10→20 discriminator —8/8, WalkMethods0 bindings. Прежние789+54
kernel assertions и62 измеренных allocation-fault/baseline процесса
GREEN. Exact old public runtime контроль всё ещё имеет6 bounds FAIL,
это ожидаемая чувствительность, не RED нового75. Два точных standalone
post fixtures теперь17/0 (20000 messages),30/0; минимальный link содержит
lane/char/source-name/libc objects, НЕ root и НЕ второй reader.

Failed attempts сохранены:73 dotted-member L1 arg;74/build01 старый
COUNT node expectation2 вместо3 (исправление recipe/test протокола,
не ослабление behavior); mixed wrapper02 ошибочно получил8 RED из
UNSET LASTEXITCODE bounded-only script, independent audit фактических
32 RUN rows подтвердил0 ошибок. Variant02 добавляет явный exit0 для
будущих запусков, сами114 значения не переписаны. Pin01 включил собственный
ещё открытый log и остановился до receipt;02 исключил live log.75/link01
связал broad manager_running вместо lane,02 не добавил chars,03 исправил
только явный рецепт. Все ошибочные логи остаются в evidence.

Completed72–74 selected receipt1563 independently rehashed raw pins:
`build/codex_catalog72_74_completed_01.inputs.sha256`. Включает source,
actual generated C/objects/results, metadata, failed builds/recipes и
source RED, но не поздний full kernel74. Отдельный completed74/full и
75/runtime receipt5719 — `build/codex_impl74_75_completed_01.inputs.sha256`.
Full75 исключён из этого более раннего receipt.

Полный kernel75 завершён327/2, actual1, session50629 terminal;
оба FAIL — прежние manual ADMIT fixtures. Post link failures устранены
также в полном gate; admit_use21/0, post MPSC17/0 и take-refusal30/0.
Он был запущен ОДНОЙ GCC очередью, PID2772,
startUTC2026-10-20T20:43:20.9987229Z,
`build/codex_impl75_kernel_01.ps1`, output
`build/l2src/codex_impl75_kernel_01`. Это RED, не завершённое чистое ядро.
Нет promotion и full L2 gate75. Primitive/static Consumers,
fake method-own schema, два manual ADMIT fixtures, multiclass pure CALL
и все маршруты v3 остаются OPEN.112/114/789 GREEN не являются
доказательством единого алгоритма абсолютно всех потребителей. Goal ACTIVE.

После75 запущен ИЗОЛИРОВАННЫЙ reader76: frozen published69 плюс только
lmx_range, arena.h, value_owned/header из75, то есть pure owner move
без receiving ABI/compiler/test ports. Единственный GCC pipeline теперь
session69804/PID5084, startUTC2026-10-20T20:47:41.9034466Z,
`build/codex_reader76_kernel_01.ps1`, output
`build/l2src/codex_reader76_kernel_01`. Пока не принят/не перенесён.
Это независимая закрываемая зависимость, не способ объявить транспорт75
опубликованным. Следующий шаг — его полный gate, точный перенос четырёх
файлов и public production focus, затем commit/push, только при actual
проверках. Ни пауза goal, ни новое подтверждение автора не нужны.

Reader76 затем ЗАВЕРШЁН327/0, actual0, session69804 terminal. Четыре
проверенных файла перенесены byte-for-byte, normal public focus76
завершён29/0, actual0, session79820 terminal:153 compiler-use и125 path
assertions,17 исходных fixtures,789+54 kernel assertions и62 measured
allocation fault/baseline процесса. Frontend source/header56, ADMIT ABI
и tests не изменялись; actual generated frontend C сохраняет SHA256
56DE7A1CEDA73A09DBE6F566C6988EDC383F333A336D5B5541F68BCD355515CE.
Все3209 current dev sources сверены с frozen input76, не только четыре
overrides. Completed76 canonical receipt5756 independently rehashed raw pins:
`build/codex_reader76_completed_03.inputs.sha256`.

Дополнительный private75 interleaved witness меняет порядок требований:
перед reference стоят primitive declaration/initializer slots.4 actual
translation/root cells дают7, физические parent/child maps, write и
taken-address readback сохранены, WalkMethods binding1 — launcher.
Первый build-probe и tracked copy различались терминальным LF, поэтому
первый strict receipt stopped, не выдал их за равные. Exact tracked
`receiving-reference-interleaved-address.lm2` повторно исполнили в4 cells.
Затем staged diff-check поймал оставшиеся blank EOF lines; финальный
canonical source повторно исполнили во всех4 cells. Receipt recipe04
проверяет именно его raw SHA в measured result rows. Все preimage версии,
старые receipts5750/5753 и failed01 сохранены; они не выданы за exact
bytes финального tracked source. Значения не заменялись переводом/отказом.

Full75 отдельно заморожен5088 independently rehashed raw pins:
`build/codex_impl75_kernel_completed_01.inputs.sha256`. Failure lines
обоих manual fixtures сравниваются с68 буквально (без строки
пути запуска), не только по ID. Receiving transport всё ещё PRIVATE:
не путать опубликованный pure reader owner move с его принятием.
GCC/replay live jobs больше нет. Продолжать общие Consumers/прямой
перенос manual fixtures, не добавлять старый ABI decoder или positional
fallback для неизвестного layout. Goal ACTIVE.

<a id="hidden79"></a>
## Private77–79: hidden source admission и общий input path map

Base/public `0b8c6ded` не менялся.77/79 — private continuation75;
в256 общих staged src/header files отличается только l2trans.lm1.
Standalone scratch `src/pending_views_selftest.lm1` из75 не staged;
это явно записано, не выдано за удаление kernel dependency. Runtime79
raw-identical75, actual O2 program links используют тот же75 driver.o.

77 убирает positional ветки при неизвестной source schema в
`l2_source_emit_admit`/`l2_rw_hidden_admit`; общий classification
`l2_source_admits_dynamic` относит такой runtime refusal к выполняющейся
активации. `l2_rw_ns_hidden` делегирует тому же producer, что CALL.
Source LM1 SHA256 EDD36FC3857E165455F7C723B8A0CF0E61583FFD5C49CFB0C7EFF70C2FCEECD0.
194 distinct assertions,37 old fixtures/74 cells GREEN. Новый
[opaque identity-only positive7](../witnesses/used-scope-20261020/receiving-hidden-opaque-identity.lm2)
исполнился4/4; exact74/75 control останавливается на L2 в обоих режимах
с `internal: a source method occurrence has no graph producer`. Это
не успешное выполнение отрицательного oracle и не runtime value proof.

Следующий [declared hidden reference](../witnesses/used-scope-20261020/receiving-hidden-declared-address.lm2)
с genuine Good→Model admission обнаружил другую эвристику: общий
`l2_path_walk_bound` назначал view_model только по descriptor/source
substitution/capture flags, а не по существующему input_schema.
77 therefore emits physical0, хотя Model.v соответствует Good slot2.
Diagnostic return-use source `build/codex_hidden77_declared_result_01.lm2`
даёт81 в native и forced walker вместо7; это реальное чтение pad29.
79 меняет только общий root verdict: любой input с receiving schema
сохраняет её map, без повторного разбора и backend-specific проверки.

Actual79 metadata196 + reference28 + value-role12 =236 distinct GREEN;
cursor34 сохраняет старые32 и добавляет2, exact77 control даёт1 FAIL.
Recipes: `build/codex_catalog79_build_01.ps1`, `_metadata_01.ps1`.
Source SHA256 AD64BC0699ED1BDB73B114FB59645A4D63E3402556ECC5801CFC0ADF73EEB72A.
37 прежних fixture IDs/74 root cells повторены с прежними argv/oracles
(`codex_catalog79_values_01`, `_consumers_01`). Ещё14 source witnesses
из `codex_catalog79_mixed_01.ps1` дают56 actual translation/root cells:
original ns2_ref_admit, reordered ref chains, copy, interleaved required
fields, deep mixed refs/indices, nested scopes/write/address/refusal и
три новых hidden cases. Всего130; дополнительный diagnostic result
variant GREEN4 в этот счёт не включён.

[Hidden indexed positive7](../witnesses/used-scope-20261020/receiving-hidden-indexed-address.lm2)
и declared-hidden case проверяют чтение7, запись41, запись43 через
взятый @ и физический readback/neighbor29. Их WalkMethods artifacts
имеют2 native bindings — foreign door m0 и launcher m5; user use/check
не machine-bound. Без foreign door старые pure cases имеют launcher1.
Точные raw bytes четырёх новых tracked witnesses сверены с actual
компилированными probe sources; зелёный oracle7 не менялся.

[Synthetic requirement positive7](../witnesses/used-scope-20261020/receiving-hidden-synthetic-address.lm2)
остаётся RED4/UNKNOWN. Observer78 показывает actual Good layout1,
существующий Good→Model0 map, но requirement от merge(Model) имеет
distinct token2 и не получает нужный bridge. Runtime78 пробовал общую
identity composition, но этот defect не исправил; его source/C/objects,
наблюдения и RED сохранены.79 НЕ включает runtime78. Нельзя объявить
этот positive удобным отказом, подставить constructor layout кандидата
или прикрыть positional decoder. Legacy primitive typed-take/empty
receivers, два manual ADMIT fixtures, synthetic bridge и multiclass
pure CALL OPEN; ни полного replay/re-gate79, ни promotion не было.

Completed selected receipt1372 independently rehashed raw pins:
`build/codex_catalog77_79_completed_03.inputs.sha256`. Включает compiler
source/C/binaries,236 metadata assertions/77 control,130 values,
failed controls/78 experiment и exact tracked witnesses.01 не учёл
standalone scratch test при stage comparison;02 неправильно нормализовал
разделитель. Сохранены оба failed recipes. Исходный value setup77/01
не имел include root C-door header;02 исправил только recipe. Попытка
запустить witness до завершения compiler79 была остановлена one-GCC
guard, не создала второй pipeline; после terminal build выполнена.
Живых GCC jobs нет. Goal ACTIVE; часовой lmx-goal уже существует.

<a id="proof83"></a>
## Private80–83: stable full proof, port call_data и отвергающий контрпример

Норма §7 сохраняет установленное соответствие при изменении значений,
но новый Consumer/новые требования получают свой допуск. Existing
`lmx_implements_admit_receiving` умеет full-pair reuse; новый template/
current-frame transport75/79 всегда повторял аналитический type walk.
Исходный private80 C control измерил2/12 FAIL: повтор после raw смены
primitive value отвечает NO вместо прежнего positive YES. Обе формы
admission и новый incompatible required pair проверяются независимо.

[Расширенный16 witness](../witnesses/used-scope-20261020/receiving-full-proof-stability.c)
сохраняет эти12 и добавляет4 проверки нового scoped Consumer и malformed
current reference/catalog metadata. Proposed80 делегировал exact full
pair без нового Consumer прежнему common API, предварительно вызвав
reference_contract для format validation. Exact75 —3/16 FAIL (два
repeat и неверный malformed-reference status);80 —16/0. Recipe02 ошибся
в ожидаемом старом числе2;03 сохранил actual source/oracles, поправив
только expected counter3. Это измерения, НЕ общее доказательство cache.
Actual80 implements SHA256
EECA6DF8E4D3D52FCE938C5A1746BDABD98ED0461B7A63A2FE5A3C054FF79F21.

Runtime80 source rerun130/130, reference112/0, прежние789+54 O2/fstrict/
four-guard assertions и62 measured allocation fault/baseline процессов
GREEN. Exact old public runtime control всё ещё даёт6 новых bounds FAIL,
старые773+54 сохраняются. Program objects130 — unchanged actual79,
заново linked с80 driver, не повторная трансляция по другим правилам.

Call_data81 прямо переносит fixture на ADMIT5/record4 с full mode1,
empty catalog/reference table и настоящими self-layout tokens явно
созданных one-int declarations. RECEIVING model остаётся в selected
code space, operand — в caller space. Все79 исходных predicates И labels
сверены с public fixture; они не изменены, не удалены, новые check calls
не добавлялись.80 проходит79/0, exact75/79 runtime того же81 source
проваливает ровно1/79 — stable repeat. Source:
`build/codex_call_data81_selftest_01.lm1`; actual artifacts
`build/codex_call_data81_values_02`, control `_control_03`.
Failed link recipe01 добавил уже имеющиеся lane/chars bodies;02 взял
измеренную прежнюю closure (source_names + libc), source не правил.

Frozen full kernel82 завершён327/1, actual1, session8594 terminal:
единственный FAIL `selftest:lmx_walk_admit_selftest`,58 checks/25 failed/
broken0; новый call_data81 —79/0 и здесь. Frozen3209 public inputs плюс
те же private80 core overrides и81 fixture; tools и outputs сохранены
как `build/codex_impl82_kernel_input_01`, `_tools_01`,
`build/l2src/codex_impl82_kernel_01`. Это RED, не чистое принятое ядро.

Затем [контрпример83](../witnesses/used-scope-20261020/receiving-current-reference-proof.c)
ОТВЕРГ private80 cache shortcut. Кандидат, root req и primitive value7
не меняются. Меняется именно current referenceContracts pointee:
LeafA(int)→LeafB(char). На exact75/79 повторный допуск НОВОГО требования
даётNO без публикации;80 даёт ложныйYES по прежнему root full2. Actual
`build/codex_reference_proof83_values_01`:75 exit0/GREEN,80 exit1/RED,
first1/full2/changed1 против wanted0. Ни oracle, ни raw graph mutation
не заменены более удобной проверкой. Нельзя объявить16/0/130/112/789
или327/1 доказательством cache safety после этого контрпримера.

Следующий общий механизм должен различать неизменный полный контракт
и новые текущие требования/Consumer. Key только по (value,req,full)
неполон. Не вводить частный запрет для refs, другой native guard,
подмену Consumer full/empty или legacy positional decoder. Не терять
stable full-pair positive и current-contract negative. Private80 НЕ
переносить; safe continuation — compiler79/runtime75.81 port зависит
от принятого общего fix. Synthetic requirement bridge, legacy typed-
take/empty Consumers, последний manual ADMIT fixture и pure multiclass
CALL также OPEN; full L2 re-gate/promotion не делались.

Completed80/81/full82 + counterexample83 receipt5501 independently
rehashed raw pins: `build/codex_impl80_82_completed_01.inputs.sha256`.
Все jobs terminal; goal ACTIVE, часовой lmx-goal уже существует.
