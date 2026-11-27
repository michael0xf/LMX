# MCP для LMX runtime: проверенный протокольный контракт

Дата проверки: **2026-11-27**. Статус: исследование первичных источников и архитектурное предложение; это не заявление о готовой реализации или пройденной сертификации. Документы и исходники LMX этим исследованием не изменяются.

## 1. Базовая ревизия

Текущая стабильная ревизия MCP — **2026-07-28**. Официальная страница версий прямо помечает её current. `draft` — изменяемая разработка, не контракт этого проекта. В предыдущей стабильной `2025-11-25` используются существенно иные lifecycle и направления сообщений. Поэтому нужны два явно названных профиля, если проект обещает совместимость с обоими поколениями: `mcp/2026-07-28` и `mcp/2025-11-25`. [S01][S02]

Релиз 2026 удалил handshake `initialize`, протокольные сессии и отдельные серверные JSON-RPC requests. Их заменяют метаданные каждого запроса, discovery, MRTR и явные подписки. Состояние приложения по-прежнему допустимо: отсутствие протокольной сессии не требует уничтожать LMX runtime, историю диалога или граф между вызовами. [S02]

| Аспект | Current 2026-07-28 | Legacy 2025-11-25 |
|---|---|---|
| Начало работы | Любой корректный запрос; `server/discover` доступен всегда | `initialize` → ответ → `notifications/initialized` |
| Версия/capabilities | В каждом request `_meta` | Negotiation при initialize |
| Итог | `resultType: complete` | Обычный result без обязательного discriminator |
| Вопрос клиенту | `resultType: input_required`, вложенные `inputRequests` | Самостоятельный S→C JSON-RPC request |
| Долговременные notifications | `subscriptions/listen` | Resources subscriptions; HTTP GET SSE |
| HTTP session ID | Отсутствует | Необязательный `MCP-Session-Id` |
| HTTP disconnect | Отмена соответствующего запроса | Сам по себе не означает отмену |
| Асинхронные tasks | Отдельное согласованное расширение | Experimental механизм в core |

Источники строк: current [S02][S04][S06][S07][S08]; legacy [S22][S23][S25].

## 2. Что считается надмножеством MCP

**Проектное решение:** один работающий LMX runtime принимает один и тот же смысловой `Message/post` через локальный вызов, native LMX и MCP адаптеры. Добавление native интерфейса расширяет возможности сервера, но не меняет стандартный MCP wire: в нём остаётся JSON-RPC 2.0. Прямой текст LMX — отдельный интерфейс с собственным framing и версией. Пользовательская LMX просьба, ответ модели с LMX-командами и результат runtime проходят общий код исполнения. Локальные агенты передают типизированные ссылки напрямую, без искусственной сериализации и глобального поиска объектов по строковым идентификаторам.

Входной MCP адаптер преобразует стандартную операцию в существующее сообщение LMX; он не создаёт второй диспетчер семантики команд. Вызов API модели — самостоятельная исходящая граница. MCP sampling не следует делать обязательной частью цикла runtime→model→runtime: эта возможность уже deprecated, а официальная рекомендация — прямые API провайдеров. [S03][S16]

## 3. Минимальный проверяемый профиль LMX

**Предлагаемый порядок реализации:**

1. Current core: JSON-RPC codec, version/capability validation, `server/discover`, общие message patterns, request correlation, cancellation, подписки с точным подтверждением поддержанных фильтров.
2. `tools/list` и `tools/call` с одним инструментом `lmx` либо `lmx.submit`: аргумент `document` — полный LMX документ. Передавать его в тот же общий parser/runtime, что обслуживает native интерфейс. Название — выбор проекта; не стандартный метод MCP.
3. `resources/list`, `resources/read`, `resources/templates/list`: спецификация языка, описание runtime API, примеры, схема доступных сообщений. Resource URI — имя экспортируемого ресурса, не глобальный ID объекта ядра.
4. По готовности: prompts, completion, change subscriptions, negotiated Tasks.
5. Отдельный legacy адаптер lifecycle/callbacks для существующих MCP клиентов. Поддержку конкретных capabilities заявлять только после реализации.

Базовая спецификация требует base protocol, versioning и message patterns; tools/resources/prompts и прочие feature families выбираются по нуждам приложения. `subscriptions/listen` относится к patterns; пустое подтверждённое множество фильтров не означает поддержку всех событий. [S03][S08]

## 4. Current: входящие методы

`C→S` — JSON-RPC request клиента серверу. В каждом случае обязательны общие метаданные из §6. Все обычные результаты содержат `resultType: complete`.

| Метод | Направление | Capability / обязательность | Методические параметры и ответ |
|---|---|---|---|
| `server/discover` | C→S | Обязателен; клиент может не вызывать | `supportedVersions`, `capabilities`, `instructions?`, serverInfo в `_meta`; cache hints |
| `subscriptions/listen` | C→S | Core pattern; конкретные события зависят от feature capabilities | `notifications` filter; первая notification — acknowledged; долгий запрос |
| `tools/list` | C→S | Обязателен при `tools` | `cursor?`; `tools[]`, `nextCursor?`, cache hints |
| `tools/call` | C→S | `tools` | `name`, `arguments?`; content/structuredContent/isError; MRTR допустим |
| `resources/list` | C→S | Обязателен при `resources` | `cursor?`; `resources[]`, `nextCursor?`, cache hints |
| `resources/templates/list` | C→S | `resources`; обслужить также пустой список | `cursor?`; `resourceTemplates[]`, `nextCursor?`, cache hints |
| `resources/read` | C→S | `resources` | `uri`; `contents[]`, cache hints; MRTR допустим |
| `prompts/list` | C→S | Обязателен при `prompts` | `cursor?`; `prompts[]`, `nextCursor?`, cache hints |
| `prompts/get` | C→S | `prompts` | `name`, `arguments?` со строковыми значениями; `description?`, `messages[]`; MRTR допустим |
| `completion/complete` | C→S | `completions` | prompt/resource reference, argument name/value, context?; completion values/total?/hasMore? |

Методы `ping`, `initialize`, `logging/setLevel`, `resources/subscribe`, `resources/unsubscribe`, `tasks/result` и `tasks/list` отсутствуют в current core schema. Их нельзя считать обязательными методами ревизии 2026. [S05][S09][S10][S11][S12][S19]

### Tools, resources, prompts: существенные детали

Tool input — JSON Schema объекта; default dialect 2020-12. Если есть `outputSchema`, structured result обязан ему соответствовать. В current `structuredContent` допускает любое JSON значение. Domain/runtime failure возвращать через `isError: true`; неизвестный tool или неверный envelope — JSON-RPC error. Список инструментов может зависеть от authorization, но не от случайной истории запросов данного соединения. [S09]

LMX результат целесообразно возвращать полноценным текстовым блоком `content[].text`, а `structuredContent` использовать только для простой JSON-оболочки: статус, формат документа, диагностические позиции, ограниченные метаданные. Это предложение сохраняет графовую семантику LMX: JSON не объявляется полным сериализатором объектов, ссылок, таблиц или исполняемых определений. Для compatibility с legacy использовать object-shaped metadata. При structuredContent рекомендуем добавлять второй text block с JSON-представлением этой оболочки, как рекомендует Tools spec. [S09]

Resources возвращают текст или base64 blob с URI и MIME. Несуществующий URI: `-32602`, не пустой `contents[]`; legacy клиенты могут ещё встречать `-32002`. Custom URI схемы допустимы. `https://` использовать только если клиент способен непосредственно получить ресурс этим URL. [S10]

Prompts возвращают сообщения `user`/`assistant` с типизированным content. Они полезны как шаблоны работы с LMX, но не заменяют обязательную проверку команд runtime. Completion дополняет аргументы prompt/resource, а не служит произвольным запуском LMX; максимум 100 значений за ответ. [S11][S12]

## 5. Notifications и запросы ввода

### Сообщения на wire

| Метод | Направление / условие | Содержание |
|---|---|---|
| `notifications/progress` | S→C, запрос содержит progressToken | token, монотонно возрастающий progress, total?, message? |
| `notifications/cancelled` | C→S по stdio | requestId, reason?; без ответа |
| `notifications/cancelled` | S→C по stdio, только закрытие listen | requestId соответствующей подписки; см. неоднозначность §14 |
| `notifications/subscriptions/acknowledged` | S→C, первым для данного listen ID | Принятый subset фильтра; subscriptionId в `_meta` |
| `notifications/tools/list_changed` | S→C по listen | `tools.listChanged` + toolsListChanged filter |
| `notifications/prompts/list_changed` | S→C по listen | `prompts.listChanged` + promptsListChanged filter |
| `notifications/resources/list_changed` | S→C по listen | `resources.listChanged` + resourcesListChanged filter |
| `notifications/resources/updated` | S→C по listen | `resources.subscribe` + URI в resourceSubscriptions |
| `notifications/message` | S→C на потоке соответствующего запроса | Deprecated `logging`; logLevel явно задан в request `_meta` |

У subscription notifications обязателен `_meta["io.modelcontextprotocol/subscriptionId"]`, равный **JSON-RPC ID listen-запроса**, с сохранением его типа. Progress/logging не направляются на listen stream. Фильтры: `toolsListChanged`, `promptsListChanged`, `resourcesListChanged`, `resourceSubscriptions`. Между несколькими подписками на stdio сообщения могут чередоваться. После нового соединения подписки устанавливаются заново. [S08]

Progress token — string/integer, уникальный среди активных запросов. Progress может быть дробным, должен возрастать; total необязателен. Уведомления допустимы лишь до завершения и лишь при переданном token. Cancellation — кооперативная остановка; её получение не доказывает откат ранее выполненных изменений. Неизвестные/уже завершённые request ID игнорируются. [S13][S14]

### MRTR: сервер просит данные, клиент продолжает запрос

| Вложенный метод | Нужная client capability | Статус |
|---|---|---|
| `elicitation/create` | `elicitation.form` или `.url` | Current optional; `{elicitation:{}}` означает form |
| `sampling/createMessage` | `sampling`; отдельно `.tools`/`.context` | Deprecated; не основа model-provider адаптера |
| `roots/list` | `roots` | Deprecated; informational, не access control |

Это объекты внутри `inputRequests`, без самостоятельных JSON-RPC `id`/`jsonrpc`. Core MRTR разрешён для `tools/call`, `resources/read`, `prompts/get`. Ответ `input_required` содержит `inputRequests?` и/или opaque `requestState?`. Клиент повторяет исходный метод и параметры с `inputResponses` и точным requestState, используя **новый request ID**. Нельзя запрашивать неподдержанные capabilities. Подписанная continuation при влиянии на доступ/бизнес-логику обязательна; привязка к principal, исходным параметрам и TTL рекомендуется. Повторяемые эффекты требуют собственной дедупликации: одна подпись не делает состояние одноразовым. [S07]

Form elicitation — ограниченная плоская JSON Schema; секреты через форму запрещены. URL mode — out-of-band workflow; `accept` подтверждает согласие открыть взаимодействие, а не завершение. Ответы — `accept`, `decline`, `cancel`. Не смешивать URL elicitation с авторизацией клиента к MCP серверу. [S15]

## 6. Envelope, capabilities, JSON и ошибки

Request: `jsonrpc="2.0"`, `id` — string/integer, не null; `method` — string, `params` — object. ID активных запросов одного отправителя не повторяются. У результата тот же тип и значение ID. Notification не имеет ID и не получает response. Результат и error взаимоисключающи. JSON-RPC разрешает batch вообще, но оба рассматриваемых MCP транспорта требуют одиночное сообщение: **MCP batch не принимать**. [S03][S06][S17][S23]

В `params._meta` current requests обязательны:

| Ключ | Тип / правило |
|---|---|
| `io.modelcontextprotocol/protocolVersion` | string; поддержанная точная версия |
| `io.modelcontextprotocol/clientCapabilities` | object; допустим `{}` |
| `io.modelcontextprotocol/clientInfo` | Implementation; SHOULD, не REQUIRED |
| `progressToken` | optional string/integer |
| `io.modelcontextprotocol/logLevel` | optional; управляет логированием данного запроса |

Общие `_meta` и `resultType` определены base/schema. Имена server/clientInfo — самодекларация, не authenticated identity. Extension capabilities имеют prefixed identifiers; неизвестное расширение не разрешает произвольно менять core. Capability `experimental` также не означает стабильную совместимость. [S03][S04][S19]

| Код | Значение / current правило |
|---|---|
| `-32700` | Неразбираемый JSON |
| `-32600` | Некорректный JSON-RPC request |
| `-32601` | Неизвестный/недоступный метод |
| `-32602` | Некорректные params; неизвестные tool/prompt/resource |
| `-32603` | Internal protocol error |
| `-32020` | HeaderMismatch |
| `-32021` | MissingRequiredClientCapability; data.requiredCapabilities |
| `-32022` | UnsupportedProtocolVersion; data.supported и data.requested |

`-32000…-32019` оставлены legacy; новые коды туда не выделять. `-32020…-32099` зарезервированы MCP. Собственные ошибки проекта выбирать вне JSON-RPC reserved range `[-32768,-32000]`. Current не должен отправлять исторические `-32002` и `-32042`. [S03]

**Codec design:** независимо хранить JSON null и отсутствие поля, boolean и number, array и object, string ID и integer ID. Нельзя преобразовывать произвольный ID через float, теряя точность. Непредставимые JSON значения LMX не «нормализовать» молча: возвращать текст LMX/явную ошибку экспорта. Для строковых opaque tokens пустая строка допустима; это относится также к pagination cursors. Эти ограничения codec — проектные выводы из типов JSON и схем MCP. [S17][S18]

## 7. Transport bindings

### stdio current

UTF-8 JSON; одно сообщение на строку, без literal newline внутри. `stdout` содержит только MCP; диагностика — `stderr`. S→C самостоятельные JSON-RPC requests запрещены; C→S responses запрещены. Вопросы клиенту проходят MRTR. Отмена через notification; после отмены сервер не отправляет дальнейшие сообщения по этому запросу. EOF stdin завершает процесс; перезапуск не восстанавливает inflight запросы/подписки. Custom byte streams могут использовать этот binding. Native LMX framing с многострочными документами нельзя смешать с MCP stdout. [S06]

### Streamable HTTP current

| Область | Норма |
|---|---|
| Endpoint | Один POST endpoint; один request/notification в body; C→S responses запрещены |
| Accept | Клиент поддерживает `application/json` и `text/event-stream` |
| Response | JSON object либо SSE; принятая notification → 202 без body |
| Headers | `MCP-Protocol-Version`, `Mcp-Method`; `Mcp-Name` для tools/call, resources/read, prompts/get |
| Проверка | Версия/метод/имя header соответствуют body; отсутствие/расхождение → HTTP400 / -32020 |
| Версия/метод | Unsupported version → HTTP400 / -32022; unknown method → HTTP404 / -32601 |
| Extensions | `x-mcp-header` → `Mcp-Param-*`; только допустимые scalar schema paths; unsafe header values — specified base64 sentinel |
| Origin | Проверять; присутствующий invalid Origin → HTTP403 |
| Локальный bind | SHOULD localhost; SHOULD authentication |
| Сессии | Нет session ID, GET-listen, Last-Event-ID resumption |
| Подписки | POST subscriptions/listen → SSE |
| Отмена | SSE disconnect отменяет запрос; далее не отправлять сообщения |
| Keepalive | SSE comments; SHOULD X-Accel-Buffering:no |

Все строки таблицы — [S20]. Это краткий checklist; точные header escaping/validation правила необходимо взять из закреплённой спецификации, не восстанавливать по названию поля.

**Проектное решение:** `/mcp` обслуживает JSON-MCP; `/lmx` либо явно выбранный native transport принимает LMX. Не угадывать протокол по первым символам пользовательской программы. Persistent runtime и scope диалога принадлежат приложению; connection ID/MCP request ID не становятся ID объектов графа.

## 8. Authorization boundary

MCP auth необязателен как компонент, но защищённый HTTP deployment должен реализовывать выбранный OAuth profile: bearer token в Authorization **каждого** запроса, проверка intended audience, Protected Resource Metadata и discovery authorization server. OAuth 2.1 в самой текущей спецификации всё ещё указан как IETF draft, поэтому его нельзя описывать как уже выпущенный RFC. Client ID Metadata Documents рекомендуются; Dynamic Client Registration deprecated, остаётся compatibility option. Токены нельзя передавать в query string. STDIO получает credentials из окружения. [S21] Inbound MCP token запрещено передавать upstream; для API провайдера модели нужен отдельный token/credentials. [S33]

**Проектное решение:** runtime authorization context общий у MCP/native/local entry points; его получают из доверенной границы, а не из поля LMX `principal` или clientInfo. Разрешённый текст команды и возможные изменения runtime проверяются в общем обработчике. Модель — источник входных данных, а не новый источник системных прав. Локальные агенты могут модифицировать runtime через уже существующий Message/post API, если уполномочены на конкретную операцию. Outbound provider credentials не включать в результаты tool или ресурс описания runtime.

## 9. Caching и pagination

Complete-результаты `server/discover`, `tools/list`, `prompts/list`, `resources/list`, `resources/templates/list`, `resources/read` обязаны содержать `ttlMs` (integer ≥0) и `cacheScope` (`public`/`private`). Для динамического runtime простой корректный старт: `ttlMs:0`, `cacheScope:"private"`. Private cache нельзя переиспользовать между различными authorization contexts. `input_required` и повторы с requestState/inputResponses не кэшируются. TTL — подсказка, не обещание неизменности. [S26]

Paginated methods — tools/list, prompts/list, resources/list, resources/templates/list. Cursor — opaque string; отсутствие nextCursor означает конец, пустая строка концом не является. Не фиксировать размер страницы на клиенте. **Проектное решение:** привязать cursors к identity/фильтру и версии каталога, чтобы hot updates не смешивали страницы разных снимков. [S18]

## 10. Optional stable Tasks 2026

Это отдельный контракт **`io.modelcontextprotocol/tasks`**, stable schema snapshot `2026-07-28`. Draft этого расширения отдельно существует и не включён в обещания проекта. [S27][S28]

| Operation | Current extension |
|---|---|
| Negotiate | Client `_meta.clientCapabilities.extensions` + server discover `capabilities.extensions` |
| Create | Сервер выбирает asynchronous outcome; `resultType:"task"`; durable создание до ответа |
| `tasks/get` | Текущее состояние и сразу terminal result/error либо inputRequests |
| `tasks/update` | taskId + inputResponses; empty acknowledgment с resultType complete |
| `tasks/cancel` | taskId; acknowledgment, кооперативная отмена |
| `notifications/tasks` | Optional full task state через subscriptions/listen |
| Subscription filter | `taskIds?: string[]` в стабильной schema |
| Нет | `tasks/list`, `tasks/result`, client-side request `task` flag |

CreateTaskResult плоский: `resultType`, `taskId`, `status`, `createdAt`, `lastUpdatedAt`, `ttlMs:number|null`, `pollIntervalMs?`, `statusMessage?`. GetTaskResult также плоский с `resultType:"complete"`; status-specific поля — `inputRequests`, `result` либо `error`. Состояния `working`, `input_required`, `completed`, `failed`, `cancelled`; последние три terminal. [S28]

Task `failed` означает JSON-RPC failure. Завершившийся tool result с `isError:true` остаётся task `completed`. Task ID сохраняется между соединениями, но это ограниченный внешний handle задачи, не глобальный ID LMX объектов. Клиент без negotiated extension не должен получать `resultType:"task"`. Длительный runtime job можно экспортировать ordinary tool API до реализации Tasks, явно не называя это поддержкой расширения. [S27]

## 11. Legacy compatibility 2025-11-25

Legacy adapter хранит lifecycle state и согласованные capabilities. Initialize обязателен первым, затем initialized notification; во время обычной работы используются negotiated features. Shutdown RPC отсутствует. HTTP session ID необязателен; если выдан, повторяется клиентом. Истекший ID → HTTP404 и новая initialization. DELETE для закрытия сессии можно не поддерживать (405). Header version нужен после negotiation. SSE replay допустим в отличие от modern; disconnect сам по себе не cancellation. [S22][S23]

| Legacy method / notification | Направление | Реализация compatibility profile |
|---|---|---|
| `initialize` / `notifications/initialized` | C→S | Обязательный lifecycle |
| `ping` | C↔S | Optional механизм; при получении быстро вернуть `{}` |
| tools/resources/prompts/completion | C→S | Те же common operations, legacy DTO/result |
| `resources/subscribe`, `resources/unsubscribe` | C→S | Только при `resources.subscribe` |
| `logging/setLevel` | C→S | Только при `logging` |
| `roots/list` | S→C | Только client roots |
| `notifications/roots/list_changed` | C→S | Только roots.listChanged |
| `sampling/createMessage` | S→C | Только client sampling, matching sub-capabilities |
| `elicitation/create` | S→C | Только объявленный mode |
| `notifications/elicitation/complete` | S→C | Optional URL elicitation completion; elicitationId |
| cancellation/progress | Requestor/receiver | Корреляция request ID/token legacy profile |

Legacy ping и lifecycle подтверждены [S22][S24]; legacy method inventory проверен по [S29]. Нельзя просто удалить `resultType` из current response и считать, что реализована совместимость: отличаются callback delivery, continuation, session/subscription handling и некоторые field shapes.

Experimental Tasks2025 намеренно исключить из первого compatibility профиля: там negotiated `tasks.requests.*`, per-tool `execution.taskSupport`, request `task.ttl`, вложенный task result, отдельные `tasks/get`, `tasks/result`, optional `tasks/list`, `tasks/cancel` и `notifications/tasks/status`. Это другая state machine/protocol mapping, не alias stable Tasks2026. [S25]

## 12. Общие outcome и границы адаптеров — предложение

Общий код получает типизированное сообщение и контекст, проверяет права/ограничения, выполняет операции существующего LMX runtime и возвращает один из исходов:

| Общий исход | MCP current projection | Native/local projection |
|---|---|---|
| Значение/документ | complete tool/resource result | Полноценный LMX документ / typed reference |
| Диагностика выполнения | complete tool result, isError true | LMX diagnostic result |
| Нужен пользовательский ввод | input_required | LMX продолжение/сообщение UI |
| Длительная задача | task при negotiated extension | Явный runtime job contract |
| Protocol failure | JSON-RPC error | Native envelope error |

Протокольная проверка JSON/header/ID выполняется до common operation, потому что это свойства канала. Синтаксис и группировка LMX разбираются только общим парсером; bracket subparser делегирует любые выражения и `{…}` обратно ему. Model-provider адаптер получает результаты этого же выполнения, строит следующий запрос модели и возвращает модельный LMX документ в тот же вход. Ни MCP, ни model-provider codec не должны повторно реализовывать правила группировки LMX или «договариваться» о семантике операторов.

Отдельные correlation IDs нужны для transport requests, MRTR inputs, provider turns, задач и подписок. Они не заменяют типизированные ссылки runtime. Обновление runtime во время работы требует снимка зарегистрированных обработчиков на текущий вызов и понятной области видимости нового определения; это внутреннее проектное решение, не MCP session semantics. Перед повтором команды после обрыва необходимо знать, повторяем ли её эффект; request ID — средство корреляции, не гарантия exactly-once.

## 13. Проверки соответствия перед включением capability

Рекомендуемые тесты адресуют реальные риски интеграции:

- Одно LMX сообщение, полученное через MCP/native/local, вызывает одну и ту же операцию и диагностику; native/local сохраняют ссылки.
- String ID `"1"` и integer ID `1` не смешиваются; отсутствующее поле, null, false, 0 и пустые коллекции не теряются в codec.
- Modern request без обязательных `_meta` отвергается до исполнения; headers не могут противоречить body.
- JSON-RPC malformed request, missing params, domain tool error различаются; resource not found не превращается в пустой успех.
- Пример `lmx(document)` содержит полноценный документ с вложенными скобками и текстом `{…}`; никакой транспортный split по скобкам не вмешивается в основной parser.
- MRTR повтор с новым request ID продолжает ту же операцию; чужой/просроченный/tampered state отвергается; declined input не трактуется как accept.
- Подписка сначала acknowledged, затем только разрешённые фильтром события; streams не смешивают progress и catalog updates.
- HTTP disconnect current и legacy дают разное протокольное поведение, но общий cancellation context понятен runtime.
- Hot update меняет каталог/обработчик только по принятому правилу снимка; следующий tools/list отражает изменения, cache scope не раскрывает чужой каталог.
- Tasks/legacy features не advertised, пока не готовы lifecycle/durability/access-control проверки.

Это критерии приёмки будущей реализации, а не сообщение о выполненных тестах.

## 14. Known source issues: не скрывать нормативные противоречия

1. **Subscription teardown.** Current cancellation page требует server `notifications/cancelled` при teardown подписки; current subscriptions page рекомендует финальный successful response; current schema comments ограничивают server cancellation stdio. Утверждать один бесспорный алгоритм для всех transports нельзя. Практическое предложение: зафиксировать explicit profile policy и interoperability vectors; поддержать распознавание обоих сигналов, не завершать одну подписку дважды. Для отправки ориентироваться на transport-specific правила и уточнение upstream перед объявлением полной совместимости. [S08][S13][S19]
2. **Malformed error ID.** Общий JSON-RPC требует `id:null`, когда ID неизвестен; current MCP schema задаёт optional `id:RequestId` без null и HTTP допускает errors без ID. Следует явно задать отдельный error-encoding policy MCP profile, не «чинить» schema неявным превращением null в отсутствующее поле во всех данных. [S17][S19][S20]
3. **Tasks subscription comment.** Stable tasks schema comment упоминает `tasksStatus`, но фактическое поле интерфейса — `taskIds`. В proposal использовать поле `taskIds` из type definition; не рекламировать неверный filter. [S28]

Эти issues не блокируют проектирование общей семантики LMX. Они означают, что conformance assertion нужно привязать к версии schema и реальным проверкам, а не к слову «MCP» вообще.

## 15. Первичные источники и evidence refs

Все источники открыты 2026-11-27. Web ref — локатор исследования для родительского агента; перед цитированием в ответе root должен самостоятельно открыть источник. URL ниже закрепляют ревизию, где это возможно.

| Код | Официальный источник | Web ref |
|---|---|---|
| S01 | [Current version](https://modelcontextprotocol.io/docs/2026-07-28/learn/versioning) | turn811000821view0 |
| S02 | [Release 2026-07-28](https://blog.modelcontextprotocol.io/posts/2026-07-28/) | turn739777991view2 |
| S03 | [Base protocol](https://modelcontextprotocol.io/specification/2026-07-28/basic) | turn448008425view1 |
| S04 | [Versioning and compatibility](https://modelcontextprotocol.io/specification/2026-07-28/basic/versioning) | turn573186027view1 |
| S05 | [Discovery](https://modelcontextprotocol.io/specification/2026-07-28/server/discover) | turn573186027view2 |
| S06 | [stdio](https://modelcontextprotocol.io/specification/2026-07-28/basic/transports/stdio) | turn573186027view3 |
| S07 | [MRTR](https://modelcontextprotocol.io/specification/2026-07-28/basic/patterns/mrtr) | turn813667405view2 |
| S08 | [Subscriptions](https://modelcontextprotocol.io/specification/2026-07-28/basic/patterns/subscriptions) | turn448008425view0 |
| S09 | [Tools](https://modelcontextprotocol.io/specification/2026-07-28/server/tools) | turn258601934view1; turn131029482view3 |
| S10 | [Resources](https://modelcontextprotocol.io/specification/2026-07-28/server/resources) | turn131029482view4 |
| S11 | [Prompts](https://modelcontextprotocol.io/specification/2026-07-28/server/prompts) | turn131029482view5 |
| S12 | [Completion](https://modelcontextprotocol.io/specification/2026-07-28/server/utilities/completion) | turn844985485view2 |
| S13 | [Cancellation](https://modelcontextprotocol.io/specification/2026-07-28/basic/patterns/cancellation) | turn197496297view1 |
| S14 | [Progress](https://modelcontextprotocol.io/specification/2026-07-28/basic/patterns/progress) | turn133240868view5 |
| S15 | [Elicitation](https://modelcontextprotocol.io/specification/2026-07-28/client/elicitation) | turn957692770view1 |
| S16 | [Sampling](https://modelcontextprotocol.io/specification/2026-07-28/client/sampling) | turn131029482view1 |
| S17 | [JSON-RPC 2.0](https://www.jsonrpc.org/specification) | turn421751885view0 |
| S18 | [Pagination](https://modelcontextprotocol.io/specification/2026-07-28/server/utilities/pagination) | turn131029482view2 |
| S19 | [Current schema reference](https://modelcontextprotocol.io/specification/2026-07-28/schema) | turn813667405view3; turn197496297view3 |
| S20 | [Current Streamable HTTP](https://modelcontextprotocol.io/specification/2026-07-28/basic/transports/streamable-http) | turn448008425view2 |
| S21 | [Authorization](https://modelcontextprotocol.io/specification/2026-07-28/basic/authorization/index) | turn957692770view0 |
| S22 | [Legacy lifecycle](https://modelcontextprotocol.io/specification/2025-11-25/basic/lifecycle) | turn103933606view0 |
| S23 | [Legacy transports](https://modelcontextprotocol.io/specification/2025-11-25/basic/transports) | turn103933606view1; turn197496297view0 |
| S24 | [Legacy ping](https://modelcontextprotocol.io/specification/2025-11-25/basic/utilities/ping) | turn103933606view2 |
| S25 | [Legacy experimental tasks](https://modelcontextprotocol.io/specification/2025-11-25/basic/utilities/tasks) | turn103933606view3 |
| S26 | [Caching](https://modelcontextprotocol.io/specification/2026-07-28/server/utilities/caching) | turn844985485view4 |
| S27 | [Tasks extension overview](https://modelcontextprotocol.io/extensions/tasks/overview) | turn258601934view2 |
| S28 | [Tasks stable schema](https://github.com/modelcontextprotocol/ext-tasks/blob/main/schema/2026-07-28/schema.ts) | turn458124201view2 |
| S29 | [Legacy schema](https://modelcontextprotocol.io/specification/2025-11-25/schema) | turn103426843view0; turn887639396view1 |
| S30 | [Deprecated registry](https://modelcontextprotocol.io/specification/2026-07-28/deprecated) | turn844985485view1 |
| S31 | [Roots](https://modelcontextprotocol.io/specification/2026-07-28/client/roots) | turn131029482view0 |
| S32 | [Logging](https://modelcontextprotocol.io/specification/2026-07-28/server/utilities/logging) | turn844985485view3 |
| S33 | [Authorization security](https://modelcontextprotocol.io/specification/2026-07-28/basic/authorization/security-considerations) | turn213333318view0 |

Roots, sampling и logging deprecated с 2026-07-28, сохраняются минимум 12 месяцев; потенциальное удаление не раньше ревизии от 2027-07-28. Это не уже удалённые возможности. [S30][S31][S32]
