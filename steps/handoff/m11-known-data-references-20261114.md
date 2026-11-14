# M11: известные ссылки в written DATA

2026-11-14. Исследование после388/51929242, по WIP389. Это **кандидат следующего кода390**,
не реализация и не дополнительная норма. Разрешённая запись исследователя — только этот
handoff; код, план, index и producers не менялись.

## Норма и отдельные роли

[Книга](../../provenance/semantics-book.md), строка815: при построении объявления вне
method data известная допущенная Structure-кандидат ссылки сохраняется в ячейке,
даже если содержащее тело не вызывали. Строка1101 также отделяет заполнение места
известным значением при создании вхождения от исполнения CODE.

[R12/R14](../../LMX_blog/q/fable-self-answers-20261110.md) запрещают исполнять вычисляемые
инициализаторы просто потому, что Structure подана как DATA. Собственная method data
имеет свой контракт входа. Это не разрешение заменить известную ссылку навсегда
сохранённым Frame и не разрешение вычислять произвольный Frame ради её получения.

Построение reference field, CODE-запись в подготовленное DATA-место и bare assignment
остаются разными действиями. Разделение389 не отменяется: declaration site требует
DATA; WORD LHS выбирает bare-binding; formal хранится в activation cell.

## Подтверждённый witness и current known proof

```text
fn: a (int: x) int (return: x + 1)
fn: b (int: x) int (return: x + 2)
@: Calls (@: pick a; @: pick b)
int: first Calls\[0]pick(10)
int: second Calls\[1]pick(10)
```

Root получил run5 как на seed387, так и на388. Повтор имени не причина: один pick
попадает в ту же ветку. `a/b` — written fn; реальный текущий traversal подготавливает
их через `space_open -> space_declarations` до исполнения root. Fn-result является
настоящим значением Structure. Двухпольный `@: pick a` без дополнительной модели
может принять этот адрес обычным reference constructor.

Текущая цепь в [Run](../../selfbuild/src/l2src/lmx_graph_run.lm2):

- `read_received_value:2219` при contract2/written_group возвращает исходную группу;
- вложенный `@:pick a` остаётся raw Frame: [Builder](../../selfbuild/src/l2src/l2_graph_build.lm2)
  `build_place:601` материализует int и type-only int-reference, но не этот случай;
- `binding_read` подготавливает fn/sub, не reference fields;
- `deferred_kind:60` классифицирует двухпольный `@` как6; `step` отказывает5.

Существующие building blocks: `binding_method`, `binding_source_read` и текущий
namespace доказывают соответствие F её raw declaration; `atom_target_context`
умеет lexical DATA lookup; `lmx_ref_of` в [Graph](../../selfbuild/src/l2src/lmx_graph.lm2)
создаёт отдельную reference cell к тому же Lmx; `publish` назначает имя поля и пишет
его slot общим writer. Копировать референт или весь DATA graph не требуется.

**Чистый lookup сам по себе не является known proof.** Нельзя считать любой ненулевой
результат `resolve(...,prepare=0)` статическим кандидатом: там возможны formal,
динамический вход и изменяемая reference binding. Для witness доказательство уже есть:
точный written source, текущая F из этого namespace, отсутствие выбора по вызову.
Расширение на mutable/formal/alias candidates требует сохранять их обычный контракт
и приоритет, а не брать одноимённую lexical F вместо реально выбранного значения.

## Минимальный кандидат общего кода

1. Выделить construction-only действие над reference field выбранной **новой written
   DATA**, с явными `holder,index`. Для первого среза это двухпольный Frame `@` с
   правильным name и кандидатом, который доказанно уже является известной Structure/F.
   Actual calls, `merge`, arithmetic, unknown/pending names и retained computations
   не вычислять. Type-only/uninit reference не превращать в initialized reference.
2. Получить кандидата из реального текущего namespace/существующих значений и
   проверить source/role proof. Нельзя использовать `prepare=1` как произвольный
   evaluator. Подготовку written declarations выполнять лишь через существующий
   statusful constructor, если она нужна именно этому construction boundary;
   computed fn/sub остаются pending, пользовательский CODE не запускается.
3. После обычного допуска представления/глубины создать поле через `lmx_ref_of`,
   назначить его имя и записать выбранный slot общим `publish`/writer. `pick`-поля
   получают разные reference cells, обе могут держать свои настоящие F; addresses,
   parents и значения самих F не заменяются. Bare pick остаётся неоднозначным,
   occurrence selectors продолжают выбирать физические slots.
4. Применять общий механизм на **DATA construction boundary**, не при path-read.
   Ближайшая общая точка для witness — получение written group в `read_received_value`
   под contract2; сегодня именно там constructor получает всю группу как значение.
   Нужен отдельный construction helper, а не вызов `data_run` над её полями.
   Если выбран этот первый bounded route, назвать его охват честно: одного hook
   anonymous-group недостаточно для всех вложенных named DATA declarations и
   сохранённых DATA, содержащихся в ещё не вызванных телах. Эти роли надо подключать
   через общий constructor, не выдавать успех witness за полное исполнение строки815.
5. Уже materialized fields оставлять как значения. Не перепривязывать сохранённую
   ссылку к новой F при каждом чтении. Не backfill существующую supplied DATA в
   `work_load`, `step`, `step_place` или admission query только потому, что её
   отложенное имя стало доступно позднее. Для дальнейшего охвата alias chains/
   forward references нужен явный construction порядок; однопроходный direct-F
   вариант не доказывает их готовность.

Helper может использовать прежнюю temporary queue/visited (`scan_add`) для выбранных
DATA-ветвей с sharing/cycles, если включается вложенность. Это временная служебная
структура обхода, не новый registry. Не идти автоматически в CODE, fn args/defaults,
method data до её собственного входа или через внешние references как по дереву.
Не менять parent и не создавать отдельный граф ради материализации.

`merge_literal_open` не подходит как workaround: он создаёт новую Structure и пока
отказывает при repeated/existing name. Это изменит допустимый Calls вместо хранения
обоих fields. Из старого literal path можно использовать projection/typed constructor,
но не его ограничения и копирование.

## Где нельзя открывать этот этап

Не добавлять материализацию безусловно в `space_open`, `space_declarations` или
`fn_make`. Этот же `space_open` используется:

- `preflight:2830` с временной таблицей;
- [GraphTool](../../selfbuild/src/l2src/l2_graph_tool.lm2) `emit_program:1535`;
- [FrontendGraph](../../selfbuild/src/l2src/l2_frontend_graph.lm2) translation:1366.

F из такого обхода нельзя сохранять в программной DATA как будто это binding
фактического исполнения. Compiler/preflight namespace и следующий runtime namespace
не являются одним lifetime. Новый постоянный registry или перенос preflight F
не исправляют этот разрыв. Для source-known обычных значений без namespace возможна
ранняя работа Builder, но forward names/F требуют соответствующей реальной фазы;
не выполнять initializer из частично построенного P0 и не добавлять второй parser.

## Native и публикация M14

[GraphTool](../../selfbuild/src/l2src/l2_graph_tool.lm2)
`emit_received_operand:458` сейчас выдаёт written group простым runtime `graph_get`.
Если helper подключён к construction receiving boundary, этот generated runtime
branch contract2/live kind6 должен вызывать **тот же** helper. Иначе interpreter
материализует fields, а native сохранит raw Frames. `read_actual` уже использует
общий `read_received_value`; не дублировать field-construction в emitter.

Вызов helper не создаёт activation и не исполняет DATA body. Нельзя ради этой задачи
сбрасывать чужие dirty, перечитывать caller locals или подменять working reference
её опубликованной ячейкой. Обычная CODE-запись использует site/token389 и его dirty;
construction field получает физическое хранилище обычным constructor/writer.
Изменения опубликованного графа должны соблюдать общую invalidation/publication
[M14](../../next_core_tasks_v3.md#native-structures), включая active native continuation;
сырой `graph_put` не является способом обойти этот контракт. Полный shared direct
cache и языковой flush остаются OPEN; helper не должен вводить журнал присваиваний.

## Будущая короткая приёмка, ещё не выполнена

- Witness a/b: first11, second12, оба stored reference fields, bare pick ambiguous3.
- Один pick и два pick используют один constructor; никаких специальных правил
  только для occurrence или function-head call.
- Повторное чтение не создаёт новую F и не сбрасывает её data; mutation через один
  действительно общий referent наблюдается через другой alias после штатной публикации.
- DATA `@:pick factory()` сохраняет отложенный Frame; счётчик factory остаётся0,
  простое чтение этого места сохраняет прежний отказ5. То же для unknown/pending.
- Method DATA initializer выполняется только по своему entry-контракту; supplied D
  не получает такого исполнения. Вложенные scopes/copies не берут binding другого walk.
- Interpreter/native/forced совпадают; source graph до/после pure preflight не
  получает ссылки на временные F. Wider named/nested/alias cases отмечать отдельно.
