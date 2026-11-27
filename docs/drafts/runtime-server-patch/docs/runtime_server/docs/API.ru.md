# API сервера LMX runtime

**Статус:** конкретные LMX-заготовки и обязательные интеграционные контракты. Провайдеры ядра, модели, транспорта, MCP и SQLite пока не привязаны; исполнение с production runtime — **NOT_RUN**. Этот документ описывает имена и тела из поставленных исходников, а не дополнительный сервер на другом языке.

Нормативная основа — [§36: изменяющий API для AI-чата](../../spec/LMX_semantics.ru.md#edit-api). Общие решения изложены в [архитектуре](ARCHITECTURE.ru.md), текстовый обмен — в [native-протоколе](NATIVE_PROTOCOL.ru.md), профиль MCP — в [MCP compatibility](MCP_COMPATIBILITY.ru.md). Дальнейшая проводка описана в [плане реализации](IMPLEMENTATION_PLAN.ru.md).

## 1. Объекты, владение и вызовы

Все перечисленные объекты — обычные LMX Structures, ссылки и выбранные CODE. `scope` — явно переданный контекст с доступными корнями и полномочиями. Это не имя глобальной среды и не числовой идентификатор объекта. Готовый граф передаётся по настоящей ссылке с обычными условиями владения и времени жизни.

В таблицах перечислены прикладные actuals; в примерах они передаются по именам. Состояние экземпляра не следует считать исчезнувшими позициями его DATA. Выбранный CODE сохраняет фактического родителя, даже когда ссылка на него хранится в другом объекте.

Изменяющие операции выполняются на lane владельца. Между Message используются существующие `post`, `ask`, `answer`, `catch` и обработчики доставки. `private` ограничивает неявное динамическое связывание; он не скрывает данные и не заменяет проверку доступа. См. [core.lmx](../src/core.lmx), [agent.lmx](../src/agent.lmx).

## 2. Общие записи результата

Точные объявления и конструкторы находятся в [models.lmx](../src/models.lmx). Поля `@` удерживают действительные записи/ссылки; отсутствие значения не подменяется нулём.

| Запись | Поля | Условие использования |
| --- | --- | --- |
| `LmxServerStage` | `ready: int`, `payload: @` | `ready=1` — подготовленный объект конкретной операции; `ready=0` — настоящий неуспешный Receipt подготовки. Другие значения отвергаются. |
| `LmxServerReceipt` | `ok: int`, `payload: @` | `ok=1` только при действительном нормальном результате. Остальные исходы сохраняют различимый реальный payload. |
| `LmxServerModelAnswer` | `complete: int`, `text: []char`, `details: @` | Исполнять можно только целый ответ при `complete=1`; `details` сохраняет сведения провайдера о завершении. |
| `LmxServerDecision` | `finished: int`, `observation: @` | Агентский профиль: `0` — продолжить с наблюдением, `1` — закончить. Другие значения недопустимы. |
| `LmxServerEvent` | `kind: []char`, `payload: @` | Реальное наблюдение или изменение состояния агентского диалога. |
| `LmxServerExchange` | `kind: []char`, `payload: @`, `previous: @` | Начальный `question` либо следующее `observation`; история связана обычными ссылками. |

В пути команд `Stage.ready=1` несёт подготовленный, ещё не исполненный вызов. `LmxServerApply\apply(runtime; stage)` передаёт его в `runtime\execute` ровно один раз; при `ready=0` возвращает сохранённый Receipt. Каталог использует ту же форму Stage для подготовленной партии фактов: её принимает только `stagePublication`, а не `runtime\execute`.

`Receipt.ok=1` не означает «доставлено», «поставлено в очередь» или «похоже на успех». No-result, suspension, failure и turn-ended сохраняются как разные реальные исходы; ни один не превращается в `@0`, выдуманный результат или ACK исходного вызова. Обычный результат может быть данными любого разрешённого типа. Требование Decision относится только к агенту, а не ко всем native/MCP-командам.

Конструкторы `LmxServerReceiptMake\make(ok; payload)`, `LmxServerDecide\make(finished; observation)` и `LmxServerExchangeMake\make(kind; payload; previous)` копируют модель и заполняют реальные поля. Сам вызов конструктора не подтверждает, что внешний эффект произошёл.

## 3. Service и единый путь команды

| Выбранный CODE | Actuals | Результат и действие |
| --- | --- | --- |
| `LmxServerCreate\create` | `runtime: @LmxServerRuntimePort`, `scope: @` | `@LmxServerService`; создаёт экземпляр и допускает начальный обработчик через `admitHandler`. |
| `service\submitText` | `source: []char` | `@LmxServerReceipt`; целый LMX-документ проходит подготовку и исполнение. |
| `service\submitGraph` | `graph: @` | `@LmxServerReceipt`; готовый граф идёт в тот же путь без сериализации. |
| `service\replaceHandler` | `replacement: @LmxServerHandlerAPI` | `@LmxServerReceipt`; после допуска меняет слот и возвращает действительную установленную ссылку. |

`LmxServerDispatch\execute(runtime; scope; sourceKind; source)` — начальный CODE обработчика. `sourceKind=0` выбирает `prepareText`, `sourceKind=1` — `prepareGraph`, затем обе ветви используют `LmxServerApply\apply`. Неизвестный вариант вызывает `LmxServerPortFailure` с обычной диагностической Structure, содержащей исходный `sourceKind` и `source`.

Стабильные `submitText`/`submitGraph` читают физический `node\handler` **после доставки, на lane владельца**. Поэтому новые обращения могут использовать новый обработчик. Если отправитель заранее выбрал старый CODE, уже сформированный вызов сохраняет его. Смена ссылки не меняет родителя метода и не переписывает старую native entry.

```lmx
post:
    ask:
        service\submitGraph(graph := readyGraph)
    answer:
        sink\Receiver\accept
    catch: LmxServerPortFailure (@: cause)
        sink\Failure\accept(cause := cause)
```

Полные примеры локального обмена и sink: [03_local_messages.lmx](../examples/03_local_messages.lmx). Здесь `readyGraph` уже существует; запись вызова на стороне отправителя не должна случайно исполнить его вместо передачи ссылки.

## 4. RuntimePort и общий codec ядра

Все слоты [ports.lmx](../src/ports.lmx) типизированы именованными сигнатурами и оставлены без фиктивных реализаций.

| Метод `runtime` | Actuals | Результат |
| --- | --- | --- |
| `prepareText` | `source: []char`, `scope: @` | `@LmxServerStage` |
| `prepareGraph` | `graph: @`, `scope: @` | `@LmxServerStage` |
| `execute` | `prepared: @` | `@LmxServerReceipt` |
| `present` | `receipt: @LmxServerReceipt` | `[]char` |
| `inspect` | `scope: @`, `target: @`, `projection: @` | `@LmxServerReceipt` |
| `insert` | `scope: @`, `target: @`, `source: @` | `@LmxServerReceipt` |
| `copyTo` | `scope: @`, `target: @`, `source: @` | `@LmxServerReceipt` |
| `step` | `scope: @`, `execution: @`, `action: []char` | `@LmxServerReceipt` |
| `admitHandler` | `candidate: @`, `scope: @` | `@LmxServerHandlerAPI` |

`prepareText` вызывает ядровой **`sys\fromLmx`: он создаёт чистый граф, пригодный для компиляции**, после чего используется обычная подготовка и admission. Предварительная компиляция не является обязательным условием интерпретации нового обычного графа. Главный парсер содержит подпарсер `[]`, который возвращается к нему для выражений и `{...}`; сервер не добавляет собственный разбор или группировку.

**`sys\toLmx` создаёт LMX-код из любой Structure и любого L3Thread.** На него опираются `present` и `inspect`, сохраняя действительные типы, порядок, разделяемые ссылки и циклы по контракту ядра. Сервер не содержит второго AST или сериализатора. Неполная проводка codec в переданном старом ядре — состояние реализации, а не сужение этого API.

Фасады `LmxServerInspect\inspect`, `LmxServerInsert\insert`, `LmxServerCopyTo\copyTo`, `LmxServerStep\step` принимают те же actuals с дополнительным `runtime` и возвращают Receipt. Они копируют действительный `throws` выбранной операции. `insert` размещает источник, но не вызывает объявленный метод; `copyTo` отделяет копирование от размещения; `step` продолжает явно указанный execution. Автоматического отката эффектов нет.

## 5. Admission обработчика и конечные exits

```lmx
LmxServerHandlerAPI :: (@LmxServerRuntimePort: runtime; @: scope; int: sourceKind; @: source; return: @LmxServerReceipt; throws: copy(LmxServerPortThrows))
```

Именованная fn-сигнатура сравнивает позиции входов и результат; её наличие **само по себе не доказывает конечный набор exits** кандидата. `admitHandler` использует общий механизм проверки сигнатуры и реального Consumer, проверяет действительный конечный `throws` как подмножество `LmxServerPortThrows`, а также owner/lifetime. Возвращается та же ссылка на выбранный CODE; тела кандидата, скрытого копирования, перепривязки parent и автоматической перекомпиляции здесь нет.

В данном профиле `LmxServerPortThrows` содержит `LmxServerPortFailure`; его payload — настоящая диагностическая ссылка. При сборке так же допускаются реальные реализации остальных портов. Неявные ошибки ядра сохраняют свой механизм распространения; синтаксические и трансляционные отказы подготовки не объявляются обычными успешными результатами.

```lmx
post:
    ask:
        service\replaceHandler(replacement := LmxServerExampleTextOnlyHandler\execute)
    answer:
        sink\Receiver\accept
    catch: LmxServerPortFailure (@: cause)
        sink\Failure\accept(cause := cause)
```

Полный новый обработчик: [06_hot_replace.lmx](../examples/06_hot_replace.lmx). Для изменения без перекомпиляции это новый обычный CODE без готовой native entry; старые выбранные/native-вызовы продолжают пользоваться прежней реализацией.

## 6. Модель, ask и жизненный цикл Job

`LmxServerModelPort\complete(exchange: @LmxServerExchange) → @LmxServerModelAnswer` — обычный вызов привязанного провайдера модели. Он получает вопрос или действительное наблюдение с историей и возвращает целый ответ, признаки завершённости и детали. Потоковые фрагменты и правдоподобный префикс не становятся исполняемой командой.

`LmxServerAgent\ask(service; model; sink; question; roundLimit; timeoutMs) → @LmxServerAgentJob` принимает типизированные Service/ModelPort, ссылку `sink: @LmxServerEventSinkAPI`, обычный вопрос `question: @` и целые пределы. Внешний пользовательский метод `Chat\ask` из примера принимает строку и передаёт заранее связанные service/model/sink.

```lmx
Chat\ask(question := "Inspect Work and explain its state.")
```

Готовая обвязка: [02_user_ask.lmx](../examples/02_user_ask.lmx). Вопрос может ссылаться на обычную таблицу или дерево, как в [01_table_and_tree.lmx](../examples/01_table_and_tree.lmx).

Последовательность в [agent.lmx](../src/agent.lmx): `post` к модели → проверка `complete=1` → `post` к стабильному `service\submitText` → настоящий Receipt. При `ok=1` агент сначала проверяет `satisfies(payload; LmxServerDecision)` и только затем читает `finished`. `finished=0` добавляет наблюдение в связанную историю и запускает следующий ограниченный шаг; `finished=1` завершает диалог. Исчерпание числа запросов даёт `budget`, а не успешное завершение.

| Метод Job или callback | Вход / результат | Назначение |
| --- | --- | --- |
| `job\dispatch` | Без результата | Внутренний следующий запрос модели; уменьшает оставшийся бюджет. |
| `job\OnModel\accept` | `answer: @LmxServerModelAnswer` | Подготовленный маршрут ответа модели. |
| `job\OnReceipt\accept` | `receipt: @LmxServerReceipt` | Подготовленный маршрут действительного исхода команды. |
| `job\Control\cancel` | `reason: @`; без результата | Останавливает новые шаги политики, событие `agent-stopped`. |
| `job\Observation\read` | `@LmxServerEvent` | Возвращает последнее записанное событие; это не обещание завершённости. |
| `job\Events\emit` | `kind: []char`, `payload: @`; без результата | Внутренняя запись события и `post` к связанному sink. |
| `sink` | `event: @LmxServerEvent`; без результата | Обычный callback, не отдельный event bus. |

Нормальные события: `started`, `observation`, `finished`. Остановки различаются как `budget`, `agent-stopped`, `incomplete-model-answer`, `invalid-decision`, `runtime-outcome`, `model-failure`, `command-failure`, `model-undelivered`, `command-undelivered`, `model-unanswered`, `command-unanswered`. Поздние события — `late-model-answer`, `late-runtime-receipt`, `late-outcome`; они не запускают новую команду.

Timeout начинается по правилам существующего `post` и не отменяет исполнение. `cancel` также не прерывает произвольный native-вызов, не откатывает запись и не освобождает живые маршруты. Job, его родители и сформированные actuals должны жить до завершения всех маршрутов. Persistent callbacks получают Job через `parent(node)`, а не через сохранённый стек dispatch. Примеры: [05_agent_decisions.lmx](../examples/05_agent_decisions.lmx), [07_stop_and_late_receipt.lmx](../examples/07_stop_and_late_receipt.lmx).

## 7. Текстовый транспорт и узкий MCP-адаптер

| Контракт | Actuals | Результат |
| --- | --- | --- |
| `transport\readDocument` | `connection: @` | `[]char`, только полный документ; EOF/обрыв — объявленный отказ. |
| `transport\writeDocument` | `connection: @`, `document: []char` | Без результата; реальные I/O и framing принадлежат провайдеру. |
| `protocol\decodeCommand` | `request: @` | `[]char`, допущенная целая LMX-команда согласованного MCP-профиля. |
| `protocol\encodeReceipt` | `request: @`, `receipt: @LmxServerReceipt` | `@`, полный соответствующий запросу MCP result/error envelope. |

В [boundaries.lmx](../src/boundaries.lmx) `LmxServerNativeCommand\exchange(service; document) → []char` вызывает стабильный Service и `runtime\present`. `LmxServerNativeFrame\exchange(service; transport; connection)` читает один документ и записывает один ответ; результата у этого метода нет. `LmxServerMcpCommand\exchange(service; protocol; request) → @` соединяет decode, тот же Service и encode.

Эти графы-адаптеры принадлежат владельцу команды; внешняя доставка использует обычный `post`. Они не создают listener loop или поток на запрос. MCP-port — именно узкий адаптер LMX-команды: JSON codec, проверка версии/метода, discovery, другие согласованные возможности и транспортные правила описаны в [MCP_COMPATIBILITY.ru.md](MCP_COMPATIBILITY.ru.md), а не реализованы фиктивно в двух слотах. Native framing описан отдельно в [NATIVE_PROTOCOL.ru.md](NATIVE_PROTOCOL.ru.md).

Примеры полных текстовых команд inspect/insert/step: [04_remote_documents.lmx](../examples/04_remote_documents.lmx). Имена в документе разрешаются обычной подготовкой из переданного `scope`; отдельного runtime string-evaluator нет.

## 8. API производного каталога SQLite

Источник и алгоритм — [catalogue.lmx](../src/catalogue.lmx), схема, публикации и SQL-проекции — [CATALOGUE_SQLITE.ru.md](CATALOGUE_SQLITE.ru.md). Компиляторные факты относятся к тому же чистому графу. `toLmx` текущего runtime остаётся первичным источником истины; диск и SQLite — производные представления.

| Метод `LmxCataloguePort` | Actuals | Результат |
| --- | --- | --- |
| `openFacts` | `scope`, `compilation` | `@LmxCatalogueCursor` с реальными `basis` и состоянием обхода. |
| `nextFact` / `closeFacts` | `cursor: @LmxCatalogueCursor` | `@LmxCatalogueNext` / без результата. |
| `begin` | `scope`, `basis` | `@`, непубличная подготовляемая партия. |
| `append` / `discard` | `batch`, `fact: @LmxCatalogueFact` / `batch` | Без результата. |
| `finishPrepared` | `batch` | `@LmxServerStage`, ещё не публикация. |
| `stagePublication` | `scope`, `stage: @LmxServerStage` | Receipt **pending**, `ok=0` с явным payload. |
| `status` | `scope` | Receipt действительного состояния публикации. |
| `search` | `scope`, `query: []char`, `limit: int`, `cursor: @` | Receipt страницы поиска. |
| `describe` | `scope`, `item: @LmxCatalogueItemRef` | Receipt описания. |
| `callers` / `dependencies` | `scope`, `item: @LmxCatalogueItemRef`, `limit: int`, `cursor: @` | Receipt страницы связей. |

`LmxCatalogueItemRef` содержит `publication: []char` и `item: []char`: ключи конкретной публикации, а не live handles. Каждый запрос с ключом проверяет ожидаемую публикацию в той же read transaction; несоответствие — `catalogue-stale`, неизвестный ключ — `catalogue-key-not-found`. Результат содержит фактические snapshot/basis/coverage; курсор первой страницы — явный типизированный null. Query — текст поиска, не произвольный SQL.

`LmxCataloguePrepare\prepare(port; scope; compilation; maxFacts)` исполняет реальный LMX-цикл `nextFact → append → finishPrepared` с ограничением и `finally` cleanup. `LmxCatalogueQueuePublication\queue(port; scope; stage)` только регистрирует pending-публикацию. Фактическую замену активной проекции выполняет обязательный owner hook на успешной границе; кода `endturn(); publish()` нет, поскольку `endturn` не возвращается.

Фасады `LmxCatalogueSearch\search`, `LmxCatalogueDescribe\describe`, `LmxCatalogueCallers\callers`, `LmxCatalogueDependencies\dependencies`, `LmxCatalogueStatus\status` добавляют явный `port` к соответствующим actuals. SQL-ключ не даёт полномочия изменять граф и не превращается автоматически в ссылку runtime. Полный SQL здесь не дублируется.

## 9. Что необходимо привязать и проверить

Поставлены обычные LMX-тела состояния, маршрутизации, агентского цикла и сбора фактов. Runtime invocation/codec integration, model HTTP client, транспорт, MCP codec/profile provider, SQLite bindings и owner publication hook остаются объявленными зависимостями. Их соответствие полным контрактам, поздним сообщениям и native/walker-поведению требует настоящих интеграционных прогонов.

Статическая проверка ограниченного подмножества подтверждает только проверенные лексические/layout-условия. Она не заменяет P0, admission, компиляцию и runtime. Доказательная база и границы переноса из старого ядра находятся в [SOURCE_EVIDENCE.ru.md](SOURCE_EVIDENCE.ru.md); следующий этап — [IMPLEMENTATION_PLAN.ru.md](IMPLEMENTATION_PLAN.ru.md).
