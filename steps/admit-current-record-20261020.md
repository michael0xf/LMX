# Current ADMIT: private90/91 и giving-place context

Ненормативный checkpoint, 2026-10-20. Продолжает
[coordinate refinement89](receiving-coordinate-refinement-20261020.md).
Codex sole writer/build, goal ACTIVE; public dev пока `0b8c6ded`.
Ни этот срез, ни private91 не являются завершением v3 или self-build.

## Перенос оставшегося fixture

[Точный исполнявшийся fixture](witnesses/used-scope-20261020/admit-current-record-fixture.lm1)
строит только текущие ADMIT5 и ordinary receiving record4
`[catalog,coverage,mode,references]`. Старые inline default/alternative/class
поля не декодируются и не сохраняются как запасной маршрут. Обе halves
source/partial maps теперь физически содержат2n cells, а не объявленные
ранее n cells при чтении2n. Декларации source/target имеют явные собственные
layout tokens; это не присвоение кандидату происхождения из требования.

Проверены58 cases и58 исходных labels. Нельзя назвать все58 predicates
побайтно прежними: [точное сравнение](witnesses/used-scope-20261020/admit-current-record-oracles.json)
показывает55 прежних и три необходимые миграции:

- №16 проверяет неизменность тех же двух карт в ordinary catalog вместо
  удалённых inline offsets.
- №17 проверяет свежие scalar token cells копии и прежние non-owning module
  identities, теперь через вложенный catalog. Не заменён проверкой числа полей.
- №58 портирует **malformed metadata**, не malformed outer instruction.
  Ordinary receiving data даёт UNKNOWN в общем kernel и implements-throw
  у обоих backend; новое ожидание дополнительно сохраняет прежний допущенный
  адрес. Это согласовано с уже существующими malformed-record проверками
  admit_use; outer ADMIT с неверной формой по-прежнему INVALID.

Ни один положительный behavioural oracle не заменён отказом. Fixture
unknown-origin значений теперь явно задаёт **foreign giving-place ABI**
через обычный аналитический допуск к source model, не к target model.
Таким образом до проверяемого допуска у кандидата нет target correspondence
и нет физической layout. Это не прежнее разрешение нетипизированному значению
без какого-либо evidence получить guessed identity. Такой отрицательный
случай отдельно сохраняют no-evidence source witnesses.

Эквивалентность класса теперь задаётся согласованными адресами используемого
поля, а не одинаковым числом у противоречащих карт. Последняя группа tests
передаёт явную coverage поля0 (mode2); её прежние class numbers не становятся
новыми runtime codes. Comments/labels исходного fixture местами исторически
называют старую inline форму; новый helper её не создаёт.

Первый порт90/01 на89 дал58/5/broken0. Исправление текущего представления
coverage и metadata-error ожидания, без ослабления положительных проверок,
оставляет на89 **58/2**: stale target provenance и giving-place choice.
Exact same port90/02 на91 — **58/1/broken0**. Оставшийся положительный
«the giving place's own declaration decides when its entry answers» RED;
не считать перенос dependency-closed и не выбирать первую строку ради GREEN.

## Общий updater91

Уже сохранённая полная target map могла предшествовать появлению реального
свидетельства физического происхождения в другой source entry того же value.
Resolver сохранял правильные координаты, но возвращал entry.layout=0 и
не обогащал её новым известным origin. Private91 добавляет обновление в
общий prepare producer: копируемая temporary entry с неизвестным origin
получает **текущее доказанное** lmx_implements_layout(value). Не из req,
не из конструктора, не из подсказки source.schema. Карта, permission и
current-contract key от этого не сочиняются.

Actual runtime — `build/codex_impl91_runtime_01`, snapshot
`build/codex_impl91_source_snapshot_01/lmx_implements.lm1`.
Header ABI не менялся; все77 headers86/91 побайтно совпали. На91 GREEN:
stable16, current-reference83, reference112, dependencies39, original9,
refinement48, alternatives38, table169, old789+54; measured allocation
scoped78/full86/cached172, live delta0 и неизменность записей на отказе.
Прежние150 actual source/root cells и CALL-data79 также GREEN. Exact89
control того же port90/02 сохраняет58/2, поэтому исчезновение stale-origin
FAIL не приписано одному изменению fixture.

## Положительный L2 counterexample — RED4/4

[Обычная программа](witnesses/used-scope-20261020/receiving-declared-giving-view.lm2)
не использует старых class tags или ручных ADMIT records. Её
[foreign ABI helper](witnesses/used-scope-20261020/include/l2src/tests/opaque_declared_views_test.h)
аналитически принимает один raw value(7,9) к D(v,w) и E(w,v), не создавая
ни R permission, ни физическую layout. Текущее отдающее место `giving`
явно объявлено E. При передаче в `use(@: value R)` требуется брать E.v=9,
затем write41, address-write43 и сохранить E.w=7.

Compiler86/current runtime91 даёт exit1 вместо7 во всех четырёх
translation/root cells. В forced-walk только foreign door+launcher имеют
machine bindings (2); ещё не достигнутые write/address oracles не объявляются
прошедшими. No catch превращает отказ в успех.

Ограниченная GDB-трасса native подтверждает место: допуск opaque value к
самому E проходит; последний common admission вызывается перед `use`,
из native.c:1840 с req=R. До тела `use` дело не доходит. Это не сбой
выделения helper, не несоответствие seed D/E и не запрет C foreign function.
Raw trace — `build/codex_declared91_gdb_01.log`; не читать полный graph dump
ради этого вывода, достаточно reception backtraces/первых строк журнала.

Транслятор имеет `L2ReferenceSource.schema`, но current record4 содержит
только catalog/coverage/mode/references. Когда raw value имеет несколько
завершённых views, resolver без текущего declared giving context не знает,
какой именно input namespace был выбран. Layout, declared source и target
contract — разные факты. Нельзя вместо переноса этого контекста выбрать
первую строку, последнюю регистрацию value, D/E-имя или отдельный native путь.

Следующий общий срез обязан переносить typed giving-place context от полного
результата source-expression resolution через retained admission data,
COUNT/EMIT, native и walker в один kernel. Он должен оставаться адресным,
переноситься обычной graph copy и сохранять текущий namespace. Это не новый
graph opcode и не новый executable graph. Контекст **не** разрешает value
сам по себе: нужна реальная source correspondence, текущие типовые проверки
Consumer и стабильность уже принятых положительных координат. Проверить
вложенные fields/references/indices и context на каждом шаге, а не только
корневой пример; не оставлять отдельный поиск в backend. Точный layout
будущего протокола здесь не объявлен реализованным ABI.

## Recipes, pins и полный gate

Recipes в build/: codex_admit90_values_01, codex_admit90_control_02,
codex_admit91_values_01, codex_impl91_runtime_01, codex_table91_values_01,
codex_proof91_values_01, codex_alternatives91_values_01,
codex_impl91_kernel_values_01, codex_contract91_faults_01,
codex_refinement91_faults_01, codex_impl91_source_values_01,
codex_catalog91_nested_variants_01, codex_call_data91_values_01 (.ps1).
Raw91 logs местами наследуют строки `Runtime87`/`on89`: actual paths,
runtime SHA и argv показывают91; журналы задним числом не исправлялись.

1285 completed raw pins независимо повторно хешированы:
`build/codex_admit90_91_completed_02.inputs.sha256`, SHA256
`30AD7BE4350748504F960F1D9008B493760AA3CBB50AF8A7419287F25F2CEB26`.
Previous8415 manifest включён как ссылка на прежний frozen результат;
это не заявление, что8415 заново rehashed в этом наборе. Receipt01 имел
syntax error foreach,02 исправляет только harness. Запрет чтения/копирования/
хеширования l2_driver_launch.err соблюдён до операций. Live full91 outputs
на момент receipt исключены.

Полный frozen kernel91 завершён326 OK/1 FAIL из327, actual exit1:
session18454 закрыта, worker PID10896,
startUTC2026-10-20T23:45:39.9325030Z, build/codex_impl91_kernel_01.ps1.
3209 tracked inputs,14 private core overrides91, call_data81 port и
ADMIT90/02 port. Единственный FAIL — lmx_walk_admit_selftest58/1/broken0,
точно положительный giving-place choice. Table в полном gate169/0.
Не сравнивать этот actual327/1 с прежним327/1 как одинаковые failures:
раньше ADMIT давал25 FAIL labels, теперь1 на текущем формате.

6373 terminal raw pins независимо повторно проверены, session32099 terminal0:
`build/codex_kernel91_terminal_01.inputs.sha256`, SHA256
`AAA33D41FCFDDF892B82459467CB96434017B05231563E495C849894881D8EAA`.
Включены весь frozen91 input/output/tools и все прежние1285 completed pins
без изменений. Live GCC/receipt jobs не осталось. Следующий срез — перенос
typed giving context через shared Model/address producer и common typed
path result, со всеми child/reference/index и COUNT/EMIT потребителями.
Все остальные долги v3, full L2 re-gate, public promotion, self-build и
mail T01–T26 остаются открытыми. Goal не ставить на паузу.
