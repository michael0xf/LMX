# USED-PATH-INVENTORY: общий результат пути вместо старого used-parser

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

## Private45: роли из существующего CHECK, только подготовка

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
