# Typed giving context: private92/93

Ненормативный checkpoint, 2026-10-21 UTC. Продолжает
[ADMIT90/91](admit-current-record-20261020.md). Codex sole writer/build;
goal ACTIVE, часовое `lmx-goal` ACTIVE, без дубля. Public dev остаётся
`0b8c6ded`; private92 не переносился как dependency-closed ядро.

## Общий слой, а не backend-поправка

Private92 копирует91. Изменены три source файла:
`lmx_implements.lm1`, `lmx_implements.h.lm1`,
`lmx_implements_resolve.h.lm1`. Новый typed adapter принимает адрес
**текущего отдающего Model** и его declared-reference contracts. Прежние
API без такого контекста используют тот же `admit_operation` с пустым
контекстом; это не второй decoder старого ADMIT и не автоматический выбор
источника из кандидата.

Контекст не утверждает физический origin и не даёт permission. Exact
value/Model correspondence отдающего места либо доказанное собственное
представление нужны отдельно. Новый adapter выбирает только такой источник;
если его evidence нет, прежний общий resolver не получает guessed identity.
Положительные координаты уже принятой target pair заменить нельзя.

Одна чистая операция `lmx_implements_project_view` составляет ordinal/LAST
relations. Её используют и typed source, и прежний unqualified composition;
их физические результаты повторно не проецируются. При входе во вложенную
Structure или pointer Model общий DFS переносит source Model через тот же
`contract_field`, с нужной половиной карты и declared pointee, не через
default/current pointer value. Source входит и в ключ посещённого DFS frame.
Новых имён в графе, opcode, depth cap и парсера backend не добавлено.

Это ещё **не интеграция транслятора**. Current record4/ADMIT5 не изменены;
`L2ReferenceSource.schema` пока по-прежнему не сериализован. Нельзя назвать
исходный L2 declared-giving RED исправленным, а C kernel test — результатом
native/forced-walker программы. Следующий producer должен удерживать один
полный typed source-expression result и текущий Model для named/formal/
capture/node/copy, reference/index, callable result и composed namespaces,
через COUNT/EMIT и тот же retained record. Не добавлять второй разбор после
общего адаптера, не выбирать Model по первому layout token, не ставить
`source.schema` на место физического origin. Выбор exact carrier пока OPEN.

Также новый typed путь пока не использует старый full-proof shortcut без
контекста: прежний ключ не доказывает выбор другого giving namespace.
До переноса в public нужно общее актуальное доказательство контекста для
reuse, без повторения всей аналитики при неизменных требованиях. Старый
untyped full-proof reuse16 остаётся GREEN; это не доказательство нового reuse.

## Реальные локальные проверки

Actual runtime `build/codex_impl92_runtime_03`, stage
`build/codex_mixed_path_fold_92`, O2/strict/four guards. Runtime01 не собрался:
L1 расплющил dotted argument без скобок;02 исправляет только скобки.
03 дополнительно исправляет найденный ниже общий prepare invariant.
Экспортированные заголовки изменены: не утверждать прежние77 byte-identical.

`build/codex_declared92_values_02.ps1`: новый C fixture557/0. Проверяет
оба порядка реальных source bindings, неизвестное происхождение, отсутствие
evidence как отказ, невозможность заменить уже принятые координаты,
direct Structure и pointer chains до129 уровней, ordinal/LAST, actual read9,
write41 и address-write43 с сохранением sibling7; глубокий wrong-type отказ
не публикует prefix maps. Это не тест вычисляемого индекса и не frontend proof.

Прежние stable16/current-reference83/reference112/dependencies39/
original9/refinement48 также GREEN на runtime03. Прежний templates kernel
789+54 GREEN;94 динамически измеренных allocation baseline/fault процессов
GREEN (более крупный DFS frame меняет число scratch allocations). Exact old
public control по-прежнему old773+54 GREEN, шесть новых bounds failures.

Новый `build/codex_declared92_faults_02.ps1`:42 измеренных baseline/fault
процесса для typed source с вложенной ссылкой, уже owned partial child map,
scoped/full reception и финальным reserve. Отказ сохраняет прежние entries,
обе halves и owned buffer; `live_delta=0`. Первый fault harness01 прервался
ещё в fixture setup: запрещён `node(0)` через refs_open. GDB показал именно
setup;02 использует обычный непустой filler. Это не скрытый runtime отказ.

142 прежних source/root cells реально GREEN с заново скомпилированными
program C под текущие headers. Первый recipe
`build/codex_impl92_source_values_01.ps1` завершил118 cells, затем остановился
на отсутствующем include directory тестового helper у hidden-identity.
`...source_values_02.ps1` с тем же runtime и C добавляет fixture include и
завершает оставшиеся24 cells. Старые program objects здесь не переиспользованы.
Это прежние source oracles; typed giving context в них не появился сам.

## Общий prepare: найденный отдельный дефект

При второй несовместимой temporary map одной value/req pair
`prepare_view` мог сохранить YES от `view_valid`, но вернуть пустой `out`.
В private92/03 исход ответа перед сравнением сбрасывается в UNKNOWN.
Ни ветки native, ни специального отказа для source E не добавлено.

Один и тот же557-test на actual runtime02 (до этого исправления) даёт557/1:
два reference пути с разными declared source требуют противоречащих карт
одной ещё не опубликованной child pair. На03 он даёт557/0 и атомарный отказ.
Exact differential — `build/codex_declared92_prepare_control_01.ps1`.

Первый запуск самого нового557 fixture имел556 checks/4 FAIL, поскольку
четыре отрицательных запроса ожидали именно UNKNOWN, а получили NO.
В новом fixture отрицательный oracle уточнён до «не YES»; положительные
адреса/значения не менялись. Raw executed556 source сохранён в output01.
Нельзя назвать новый557 fixture побайтно тем же556 fixture.

## Индексное поддерево: измеренный пропуск и private93

Полный frozen kernel92 завершился326 OK/1 FAIL из327, actual exit1:
`build/codex_impl92_kernel_01.ps1`, worker PID16600,
startUTC `2026-10-21T00:43:58.2303171Z`, session50129 terminal.
Единственный FAIL — прежний giving-place positive58/1/broken0, не новый
регресс. Input3209 tracked public files,
14 private core overrides92 и прежние call_data81/ADMIT90/02 ports.

Whole Array storage-type admission и вход в фактически используемый
indexed subtree — разные обязательства. Дополнительный kernel witness
Structure→Array index→reference→ambiguous held child на actual92 дал10/8:
положительный запрос оставлял без карты реально используемый child, а
отрицательный wrong-type leaf ошибочно получал YES и публиковал root prefix.
Проверены ordinal/LAST. Exact control:
`build/codex_declared92_array_control_01.ps1`.

Private93 копирует92 и меняет вход в поддерево **того же DFS**: известный
used subtree продолжается через graph Array, как через Structure. Отдельного
обходчика индексов, защиты native или повторного отображения адреса нет.
Whole Array transport не получил сравнения длины с динамическим exemplar.
Full Array element/pointee obligations, в том числе пустой exemplar, этим
узким исправлением не объявляются доказанными.
Индекс вне длины самого Model exemplar, вычисляемый индекс и его declared
element Model тоже нужно проследить в общем field/coverage producer;
положительные fixtures с заполненным Model этого не доказывают.

Actual runtime93/01, `build/codex_declared93_values_02.ps1`:

- Прежний557 fixture GREEN, все положительные oracle сохранены.
- Exact10 indexed fixture теперь10/0: wrong-type NO до публикации, actual9
  через выбранный адрес меняется на43, sibling7/pad29 сохранены.
- Новый mixed fixture528/0: вперемешку Array index, pointer и Structure,
  до129 transitions, оба halves, actual child identities, read9/address-write43,
  deep wrong-type отказ без prefix maps. Это не увеличение допустимого лимита:
  никаких проверок `depth <= 129` в runtime нет.
- Прежние stable16/current-reference83/reference112/dependencies39/
  original9/refinement48 GREEN.

142 прежних source/root native/walker cells также GREEN на93. Они используют
только уже пересобранные92 program objects: все77 headers92/93 перед этим
побайтно сравнены. Recipe `build/codex_impl93_source_values_01.ps1`.
Они не доказывают frontend typed-context integration; новое1095 kernel
assertions (557+10+528) не выдаются за1095 выполнений языка.

Точные предложенные core deltas сохранены как evidence, не как вторая
поддерживаемая реализация:
[91→92](witnesses/used-scope-20261020/typed-giving-core92-from91.patch),
[92→93](witnesses/used-scope-20261020/typed-indexed-core93-from92.patch).
Fixtures — [typed](witnesses/used-scope-20261020/typed-giving-kernel.c),
[indexed](witnesses/used-scope-20261020/typed-indexed-kernel.c),
[mixed](witnesses/used-scope-20261020/typed-mixed-kernel.c).
Это точные raw C sources из частного build, включая его include paths;
переносимый harness/поддерживаемые L3/L2 тесты остаются частью дальнейшей миграции.

Полный frozen kernel93 TERMINAL:326 OK/1 FAIL из327, actual exit1,
worker PID15236, startUTC `2026-10-21T00:51:15.0170518Z`, session37787
закрыта, `build/codex_impl93_kernel_01.ps1`. Единственный FAIL — тот же
giving-place58/1/broken0; новые indexed/mixed tests не заменяют этот oracle.
Input93 и output93 независимы от завершённого92; повторять gate не нужно.

Отдельный `build/codex_declared93_array_faults_01.ps1` проверил26 измеренных
scoped allocation baseline/fault процессов уже на93: Structure→pointer→
Array index→pointer→child, уточнение прежней owned partial map и финальный
reserve. Все26 GREEN, entries/halves/owned map сохранены при отказе,
`live_delta=0`. Строка `Full typed-contract proof` унаследована harness:
actual mode0 этого нового теста **scoped**, не full Array-element proof.

## Ещё открыто

Не закрыты current-record serialization, typed proof reuse, все реальные
native/walker giving-context values, scoped ambiguity/consumer completeness,
legacy typed-take/empty, callable graph fidelity, полный L2 re-gate,
public promotion, §§8/8a, L3/L2 self-build и mail T01–T26. Goal не ставить
на паузу из-за этих незавершённых зависимостей.

При продолжении отдельно проверить совместимые, но не побайтно равные
temporary maps повторной value/req pair: исправление YES/null защищает от
конфликта, но само по себе не доказывает Consumer-relative объединение всех
partial giving interpretations. Не заменять положительный oracle отказом.

## Exact bytes и проверка документов

11500 terminal raw pins независимо повторно хешированы, session3170 exit0:
`build/codex_typed92_93_terminal_01.inputs.sha256`, SHA256
`24F6621B0DF18B80237A3E206B376D15E59212343ECB0CF1DDB49D946CB9721E`.
Включены оба frozen full gates92/93, исходные входы, private core/headers,
actual C/objects/executables, failed attempts и controls,142 source objects
и reachable quoted includes. Previous91 receipt включён **как ссылка**;
не утверждать, что его прежние6373 files заново rehashed в этом наборе.
Ни живые журналы, ни запрещённый `l2_driver_launch.err` не читались/не
копировались/не хешировались. Все GCC и receipt jobs завершены.

После канонизации шести пустых context lines одного evidence diff
`git diff --check` также чист. Исходный diff сохранён в build/, новый
по-прежнему проходит `git apply --check`; исполнявшиеся source/object/log
не менялись. Latest receipt02:11504 independently rehashed pins,
`build/codex_typed92_93_terminal_02.inputs.sha256`, SHA256
`DA8BFC3990AD7C1C0F2CD834D615D848302ED924E3C0B783998386A904C43C1C`.
11499 прежних artifacts побайтно прежние; единственное изменение — формат
evidence patch, не тест, oracle или реализация. Receipt01 и его exact old
patch сохранены; не проверять его прежний path как будто он не изменялся.

Exact core SHA256:91 `04C5C18EA59FD3705A9AA30AD885C09FF4B8D62E3C7BBF3F0ADE3A39611AFCD6`,
92 `723BCF98233954A546141D24B8B9CA67EAABAF77D6646DB2E240CE3DECD9593E`,
93 `9E7E68ECE65F08DF2BA87159356E704062177680CDC935CA29A7805A1AEA763B`.
Evidence patches проверены `git apply --check` против exact bases; три
tracked C fixtures побайтно совпадают с исполнявшимися источниками.

`build_semantics.py`, `build_docs.py`, `check_docs.py` и `git diff --check`
проверяются перед публикацией. Это не изменение нормы или новый утверждённый
ABI source-context record. Полного L2 re-gate здесь не было. Продолжать
общий retained typed source/Model producer, не root-only сериализацию.
