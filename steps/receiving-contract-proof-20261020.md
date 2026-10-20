# Текущий receiving contract: private84

Ненормативный checkpoint реализации, 2026-10-20. Public dev остаётся
`0b8c6ded`; исходники84 пока private. Цель и writer/build —
[current.md](current.md), дальнейший маршрут — [v3](../next_core_tasks_v3.md).
Не считать этот локальный срез выполненной самосборкой или общим gate.

## Причина и механизм

Runtime75 заново проверял изменившиеся значения даже при неизменном полном
допуске. Shortcut80 исправил этот случай, но пропускал изменение самого
текущего declared reference requirement: контрпример83 получал YES вместо NO.

84 хранит управляемый типизированный набор зависимостей требуемой модели.
Один producer описывает owner/field, вид и тип, размер Structure, вложенную
модель и declared pointee; он же используется аналитическим DFS и проверкой
актуальности сохранённого full proof. Набор строится конечной рабочей очередью
с дедупликацией owner, без предела глубины. Это не копия исполняемого графа:
значения примитивов, source names и содержимое executable body не сохраняются.
Рабочая ссылка на текущую ячейку используется лишь подготовленным DFS,
но не сравнивается при последующем повторном допуске.

Неизменный полный контракт допускает reuse; новый scoped Consumer выполняет
свой анализ; изменение типов, размера или model/reference edges требует
нового допуска. Ошибочная текущая metadata остаётся UNKNOWN. Физическая
классификация сама по себе не меняет семантическое требование: её прямой
layout-token удалён из ключа после measured RED на84/04. Declared pointee
продолжает выбираться общим reference-contract producer и входит в ключ.

Затронуты пять LM1 файлов private84: arena header/body, implements body,
resolve header, graph-copy body. Это переходная работа внутри ещё открытого
kernel closure, не утверждение, что поддерживаемое ядро уже перенесено на L3/L2.
Указатель контракта в LmxImplEntry — служебное управляемое владение, не поле
обычной Structure. Copy сбрасывает прежние dependency addresses; append/put,
prune/truncate/release и attach согласованы по retain/release/transfer.
Счётчик identity-карты при новом допуске обновляется вместе с размером/key.
Все переданные координатные обещания проверяются до атомарной публикации,
даже если отдельная строка не потреблялась текущим обходом.

## Измеренные проверки

| Проверка | Фактический результат runtime84/05 |
| --- | --- |
| Прежний stable full proof witness | 16 checks / 0 failures |
| Контрпример83 со сменой declared pointee | changed=0, no-publication=1 |
| Прежний declared-reference kernel | 112 / 0 |
| [Current dependencies](witnesses/used-scope-20261020/receiving-current-contract-dependencies.c) | 39 / 0: значения/типы, размер и map n, nested/ref edges, row order, defaults, malformed declarations, attach/truncate/release, physical classification, 129 owners, цикл и копия вложенного графа |
| Прежние templates + pending views | 789 / 0 и54 / 0, predicates не изменены |
| Прежние scoped allocation faults | 62 baseline/fault процессов, live delta0 |
| [Full contract faults](witnesses/used-scope-20261020/receiving-current-contract-faults.c) | 70 baseline/fault процессов: ни одной частичной публикации/утечки, сохранены все старые entries |
| Прямой record4 CALL-data port81 | Все79 прежних check predicates/labels, 0 failures |
| Исходные программы79 | 130 native/walk translation/root cells: сохранены actual-value oracles, весь C заново скомпилирован против ABI84 |
| Полный frozen kernel85 | 327 targets / 1 failed, actual exit1. Только прежний manual admit_selftest:58/25/broken0; CALL-data GREEN |

Source130: 37 fixtures ×2 roots и14 mixed witnesses ×4 translation/root cells.
Проверяются реальные read/write/address результаты с сохранёнными чужими
полями, не только успешная трансляция. Число machine bindings не скрывается:
hidden declared/indexed используют foreign C door; поэтому эти случаи не
объявляются полностью свободными от native. Компилятор79 не менялся.
Старые79 program.o не использованы: новый LmxImplEntry имеет другое ABI.

Standalone C witnesses — инструменты проверки переходного runtime, не новая
поддерживаемая C реализация языка. Fault witness включает generated
`lmx_implements_pending_views_selftest.c`, чтобы проверять настоящие LM1 тела;
его compile/link closure сохранён в рецепте. Компоновка include/ABI важна.

## Рецепты и отрицательные наблюдения

- Exact runtime: `build/codex_impl84_runtime_05.ps1`, snapshot пяти файлов
  `build/codex_impl84_source_snapshot_05`, generated driver.c/driver.o/renamed.o.
- Основные16/83/112/39: `build/codex_proof84_values_06.ps1` и одноимённые log/output.
- 789+54/62 и старый public sensitivity control:
  `build/codex_impl84_kernel_values_03.ps1`; exact old public по-прежнему
  RED ровно6 новых bounds assertions, не новый regression84.
- FULL70: `build/codex_contract84_faults_01.ps1`; CALL79:
  `build/codex_call_data84_values_01.ps1`.
- Source130: `build/codex_impl84_source_values_02.ps1`, results.json хранит
  исходные/run SHA и argv. Рецепт01 ошибочно выбрал RUN-native вместо
  RUN-walk для второй строки;02 исправляет selector, не oracle/исходник.
- Runtime02: shrink прошёл новый допуск, но оставил старое identity n (24/1).
  Runtime03 обновил map n; прежний54 выявил непроверенные pending layout
  promises и утрату явно переданного координатного default (54/4).
  Runtime04 сохранил контракт explicit vector-view API и общий pending validator;
  source catalogs такого default не получают. Затем28/1 нашёл layout-token key;
  runtime05 его удаляет без отключения проверки текущего reference requirement.
- Первоначальный дополнительный copy test ожидал переноса layout у composition
  root:39/3. Диагностика показала предусмотренный сброс корневой layout.
  Исправлен сам fixture — копируется внешний holder и проверяется вложенный
  retained graph. Старые assertion inventories не изменены; не добавлен decoder.

## Границы

Полный frozen kernel85 завершён отдельно:327/1. Сверены все25 FAIL labels и
summary с82; различается лишь строка invoke с каталогом exe82/exe85.
Старые исходные журналы не переписаны. Это остаётся RED gate.
Последний старый manual ADMIT fixture, synthetic requirement bridge,
legacy primitive typed-take/empty Consumers, multiclass pure CALL, full L2
re-gate и дальнейшие §§8/8a открыты. Предыдущий kernel82 дал327/1 на unsafe80;
это не oracle результата85 и не основание переносить shortcut80.
Рецепт85 — `build/codex_impl85_kernel_01.ps1`; frozen input/tools/output
имеют те же имена85.3209 public tracked files,14 core overrides84 и прямой
call_data81 port. Рецепт raw-pin `build/codex_impl84_85_completed_02.ps1`
нормализует только каталог invoke для сравнения отказов, затем хеширует
неизменённые журналы целиком. Версия01 остановилась до записи manifest
на ожидаемом различии каталога invoke, не на различии тестов.
6415 файлов независимо повторно хешированы в
`build/codex_impl84_85_completed_02.inputs.sha256`; SHA256 manifest:
`845C349861FBDC3BE2A2065E4FD6D77A88BB4D1E777E1CF094D7C0C2A3AE78E7`.
Runtime05 implements LM1:
`71BC5D593F2E0B276961F7E699281E798897F9315FD5FCB3C19BCB853AE4391F`;
arena header:
`E0AFB63C58C0405A6F3E582977B63F878AB265B4F65A61DBABA318CCDD068ADA`;
неизменённый compiler79:
`AD64BC0699ED1BDB73B114FB59645A4D63E3402556ECC5801CFC0ADF73EEB72A`.
Tracked dependency witness точно совпадает с измеренным39-test C:
`7DF7484DACE1016A906553042B72E757943742A973E4F95578BB7CD41DF37B5C`;
FULL70 witness:
`4EC023FC004BC5C0B139F36B06DD72980559EC1390136633B68CD070293006AA`.
Действительный следующий шаг всегда в current.md.
