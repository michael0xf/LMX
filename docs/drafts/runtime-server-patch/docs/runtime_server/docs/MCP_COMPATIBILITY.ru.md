# MCP compatibility profiles для LMX runtime

Версия предложения: 0.1. Дата проверки внешних спецификаций: **2026-11-27**.

Этот документ задаёт границу совместимости и критерии реализации. Он не утверждает, что прилагаемые LMX заготовки уже реализуют MCP transports, JSON codec, OAuth или durable tasks. JSON/SSE fixtures — эталонные обмены; их выполнение ядром помечено `NOT_RUN`.

## 1. Архитектурная граница

Runtime остаётся одним LMX runtime с обычным механизмом сообщений, описанным в §36 нормативной спецификации. Пользователь, локальный агент, удалённый native клиент и MCP клиент обращаются к одному пути выполнения. Вызов модели выполняет отдельный исходящий provider adapter; возвращённый моделью LMX документ поступает в тот же parser и runtime.

| Вход | Представление на границе | Что получает общий runtime |
|---|---|---|
| Локальный `Message/post` | Типизированные объекты/ссылки | Обычный локальный вызов без сериализации |
| Native LMX | Полный документ, `application/lmx` | Результат общего LMX parser |
| MCP | Стандартный JSON-RPC 2.0 | Типизированное сообщение после проверки wire envelope |
| Ответ API модели | Извлечённый LMX документ | Тот же parser и обычный путь вызова |

MCP codec не реализует собственные правила группировки LMX. Подпарсер `[]` и вызов им основного parser для выражений и `{…}` принадлежат общему parser. Ни HTTP framing, ни JSON codec, ни model-provider adapter не ищут самостоятельно закрывающие скобки внутри LMX программы.

MCP использует JSON-RPC: замена JSON на LMX в том же wire contract не является стандартным MCP. Здесь надмножество означает стандартный MCP frontend плюс native LMX frontend с общей семантикой. [Base protocol](https://modelcontextprotocol.io/specification/2026-07-28/basic)

## 2. Две закреплённые ревизии

На дату проверки current stable MCP — **2026-07-28**; `2025-11-25` — legacy revision для compatibility adapter. Draft и будущие revisions не обещаются. Профиль выбирается явной конфигурацией transport/endpoint либо стандартным version negotiation, а не эвристикой по первым символам LMX текста. [Versioning](https://modelcontextprotocol.io/docs/2026-07-28/learn/versioning)

| Правило | `mcp/2026-07-28` | `mcp/2025-11-25` |
|---|---|---|
| Lifecycle | Каждый request самодостаточен | Initialize handshake |
| Discovery | `server/discover` обязателен серверу | Capabilities/serverInfo в initialize result |
| Client capabilities | В `_meta` каждого request | Согласованы в initialize |
| Success result | Обязателен `resultType` | Discriminator не требуется |
| Ввод от клиента | MRTR input_required | Самостоятельный серверный request |
| HTTP session | Отсутствует | Необязательный MCP-Session-Id |
| Catalog notifications | `subscriptions/listen` | Legacy notification/session mechanism |
| HTTP disconnect | Отмена соответствующего SSE request | Не означает отмену сам по себе |
| Tasks | Optional stable extension | Optional experimental mechanism |
| Logging/roots/sampling | Сохранены, deprecated | Поддерживаются по capabilities |

Смена поколений подтверждена [релизом 2026-07-28](https://blog.modelcontextprotocol.io/posts/2026-07-28/), [current version negotiation](https://modelcontextprotocol.io/specification/2026-07-28/basic/versioning), [legacy lifecycle](https://modelcontextprotocol.io/specification/2025-11-25/basic/lifecycle). Это два codec/lifecycle bindings к общим runtime операциям, а не два независимых диспетчера команд.

## 3. Приоритет внедрения и truthful capabilities

Реализация начинается с core envelope, versioning, discovery и message patterns. Затем регистрируется один универсальный tool `lmx`; resources предоставляют язык, примеры и runtime API. Prompts/completion, notifications и Tasks добавляются по готовности соответствующих providers.

**Stub не объявляет capabilities, для которых нет работающего provider.** В частности, `{}` в core discovery fixture означает отсутствие обещаний tools/resources/prompts. Tool fixtures требуют отдельно включённого test provider; они не доказывают, что этот provider есть в текущем ядре. Не следует выдавать `resultType:"task"` или объявлять `listChanged:true` только потому, что соответствующие типы записаны в документации.

Обязательность ниже означает норму протокола после выбора профиля/feature; это не отметка реализованности заготовки.

## 4. Полная матрица current core

### 4.1 Requests клиента серверу

| Метод | Gate | Method-specific params | Complete result |
|---|---|---|---|
| `server/discover` | Core, обязателен | Только общие params | supportedVersions, capabilities, instructions?, cache hints |
| `subscriptions/listen` | Core message pattern | notifications filter | Долговременный stream; ack перед событиями |
| `tools/list` | tools | cursor? | tools[], nextCursor?, cache hints |
| `tools/call` | tools | name, arguments?, inputResponses?, requestState? | content[], structuredContent?, isError? |
| `resources/list` | resources | cursor? | resources[], nextCursor?, cache hints |
| `resources/templates/list` | resources | cursor? | resourceTemplates[], nextCursor?, cache hints |
| `resources/read` | resources | uri, inputResponses?, requestState? | contents[], cache hints |
| `prompts/list` | prompts | cursor? | prompts[], nextCursor?, cache hints |
| `prompts/get` | prompts | name, arguments?, inputResponses?, requestState? | description?, messages[] |
| `completion/complete` | completions | ref, argument, context? | completion.values, total?, hasMore? |

При объявленной tools/resources/prompts capability соответствующий list-метод обязан отвечать; пустой список допустим. MRTR разрешён для call/read/get, но не для всех RPC произвольно. Prompt arguments — string-valued map. Completion reference относится к prompt/resource template; не объявлять этим API произвольное выполнение программы. Источники: [discovery](https://modelcontextprotocol.io/specification/2026-07-28/server/discover), [tools](https://modelcontextprotocol.io/specification/2026-07-28/server/tools), [resources](https://modelcontextprotocol.io/specification/2026-07-28/server/resources), [prompts](https://modelcontextprotocol.io/specification/2026-07-28/server/prompts), [completion](https://modelcontextprotocol.io/specification/2026-07-28/server/utilities/completion).

### 4.2 Notifications

| Метод | Направление | Gate / correlation |
|---|---|---|
| `notifications/progress` | S→C | Request `_meta.progressToken`; increasing progress |
| `notifications/cancelled` | C→S, stdio | Inflight requestId; без response |
| `notifications/cancelled` | S→C, stdio | Только listen termination; source issue в §12 |
| `notifications/subscriptions/acknowledged` | S→C | Первый message данного subscriptionId |
| `notifications/tools/list_changed` | S→C | tools.listChanged + toolsListChanged filter |
| `notifications/prompts/list_changed` | S→C | prompts.listChanged + promptsListChanged filter |
| `notifications/resources/list_changed` | S→C | resources.listChanged + resourcesListChanged filter |
| `notifications/resources/updated` | S→C | resources.subscribe + resourceSubscriptions URI filter |
| `notifications/message` | S→C | logging + per-request logLevel; deprecated |

Listen request содержит `notifications` с полями `toolsListChanged`, `promptsListChanged`, `resourcesListChanged`, `resourceSubscriptions`. Ack перечисляет только принятое подмножество; необъявленные события отправлять нельзя. Subscription messages содержат `_meta["io.modelcontextprotocol/subscriptionId"]` того же типа и значения, что ID listen request. Request progress/logging не посылаются на subscription stream. После reconnect клиент заново открывает подписки. [Subscriptions](https://modelcontextprotocol.io/specification/2026-07-28/basic/patterns/subscriptions)

### 4.3 Вложенные запросы ввода MRTR

| Метод | Client capability | Представление |
|---|---|---|
| `elicitation/create` | elicitation.form/url | В `inputRequests`; form либо URL mode |
| `sampling/createMessage` | sampling; отдельно tools/context | В `inputRequests`; deprecated |
| `roots/list` | roots | В `inputRequests`; deprecated |

Это не самостоятельные JSON-RPC requests сервера. Вложенные request objects не имеют собственных `jsonrpc` и `id`; ключи map коррелируют ответы. Сервер возвращает `resultType:"input_required"`. Клиент повторяет исходный request с **новым** outer ID, `inputResponses` и неизменённым opaque `requestState`, если он был выдан. Достаточно inputRequests или requestState, но нельзя опустить оба. Продолжение, влияющее на доступ/эффекты, требует проверки integrity и контекста; повторный эффект требует отдельного контроля replay. [MRTR](https://modelcontextprotocol.io/specification/2026-07-28/basic/patterns/mrtr)

Form elicitation не переносит секреты; URL acceptance ещё не означает завершённую внешнюю операцию. Sampling optional и deprecated: основной model-provider цикл LMX обращается к API модели самостоятельно. Roots информируют о путях, но не предоставляют права. [Elicitation](https://modelcontextprotocol.io/specification/2026-07-28/client/elicitation), [Sampling](https://modelcontextprotocol.io/specification/2026-07-28/client/sampling), [Roots](https://modelcontextprotocol.io/specification/2026-07-28/client/roots)

В current core нет `initialize`, `notifications/initialized`, `ping`, `logging/setLevel`, `resources/subscribe`, `resources/unsubscribe`, `notifications/roots/list_changed`, `notifications/elicitation/complete`. Их наличие в legacy не переносится автоматически в current профиль. [Current schema](https://modelcontextprotocol.io/specification/2026-07-28/schema)

## 5. Envelope и JSON boundary

| Поле | Current правило |
|---|---|
| jsonrpc | Строка `2.0` |
| id | String/integer; не null; уникален среди активных request ID данного sender |
| params | Object, включая обязательную `_meta` |
| `_meta["io.modelcontextprotocol/protocolVersion"]` | Required string |
| `_meta["io.modelcontextprotocol/clientCapabilities"]` | Required object; `{}` допустим |
| `_meta["io.modelcontextprotocol/clientInfo"]` | SHOULD Implementation |
| result.resultType | Required complete/input_required/negotiated extension value |
| result либо error | Ровно один вариант |

Notification не содержит ID и не получает response. Ответ коррелируется с request ID без преобразования string↔number. ClientInfo/serverInfo не являются удостоверением личности. [Base](https://modelcontextprotocol.io/specification/2026-07-28/basic)

Codec сохраняет различия null/отсутствие поля, false/0, object/array, string/integer. Если число ID нельзя сохранить точно, нельзя округлять его. JSON-RPC в общем случае допускает batch, но применяемые MCP stdio/HTTP bindings требуют одиночные сообщения. Native LMX документ с несколькими действиями не становится JSON-RPC batch. [JSON-RPC](https://www.jsonrpc.org/specification), [stdio](https://modelcontextprotocol.io/specification/2026-07-28/basic/transports/stdio)

### Errors

| Code | Current meaning |
|---|---|
| -32700 | Parse error: JSON |
| -32600 | Invalid request envelope |
| -32601 | Method not found |
| -32602 | Invalid params; unknown tool/prompt/resource |
| -32603 | Internal error |
| -32020 | HeaderMismatch |
| -32021 | MissingRequiredClientCapability + data.requiredCapabilities |
| -32022 | UnsupportedProtocolVersion + data.supported/requested |

`-32000…-32019` — legacy allocation; новые коды не выделять. `-32020…-32099` выделяет MCP. Domain ошибки LMX в tools/call оформлять как tool execution result `isError:true`, если envelope корректен. Ошибки синтаксиса переданного LMX документа относятся к результату выполнения инструмента; ошибка JSON envelope — к протоколу. [Base](https://modelcontextprotocol.io/specification/2026-07-28/basic), [Tools error handling](https://modelcontextprotocol.io/specification/2026-07-28/server/tools)

## 6. Универсальный инструмент `lmx`

`lmx` — имя проектного инструмента, не новый стандартный MCP RPC. Его wire вход намеренно мал:

```json
{
  "name": "lmx",
  "inputSchema": {
    "type": "object",
    "properties": {"document": {"type": "string"}},
    "required": ["document"],
    "additionalProperties": false
  }
}
```

Контекст исполнения выбирается явной конфигурацией endpoint/provider и admission, а не полем с недоверенным глобальным object ID. Документ может содержать данные, выражения или разрешённые сообщения изменения runtime. Сам факт вызова tool не расширяет права контекста.

Ответ содержит LMX документ в text content. Optional structuredContent — JSON metadata и/или строка документа; он не объявляет весь LMX граф JSON-совместимым. Для универсального инструмента не следует обещать readOnly/idempotent annotations: допустимость конкретных эффектов определяет common runtime API. Output schema, если объявлена, проверяет именно JSON envelope результата. [Tools](https://modelcontextprotocol.io/specification/2026-07-28/server/tools)

### Current call fixture

HTTP headers для этого request: `MCP-Protocol-Version: 2026-07-28`, `Mcp-Method: tools/call`, `Mcp-Name: lmx`, `Content-Type: application/json`, `Accept: application/json, text/event-stream`.

```json
{
  "jsonrpc": "2.0",
  "id": 7,
  "method": "tools/call",
  "params": {
    "_meta": {
      "io.modelcontextprotocol/protocolVersion": "2026-07-28",
      "io.modelcontextprotocol/clientCapabilities": {}
    },
    "name": "lmx",
    "arguments": {"document": "1 + 2"}
  }
}
```

Математически ожидаемый результат — 3. Для reference fixture выбран typed LMX document `int: result 3`. Его получение конкретным runtime/serializer здесь **NOT_RUN**.

```json
{
  "jsonrpc": "2.0",
  "id": 7,
  "result": {
    "resultType": "complete",
    "content": [
      {"type": "text", "text": "int: result 3"},
      {"type": "text", "text": "{\"format\":\"application/lmx\",\"document\":\"int: result 3\"}"}
    ],
    "structuredContent": {
      "format": "application/lmx",
      "document": "int: result 3"
    },
    "isError": false
  }
}
```

Второй text block отражает JSON metadata для клиентов, использующих текстовое представление structuredContent. Полный обмен: [current lmx fixture](../fixtures/mcp/2026-07-28/positive/03_lmx_tool_call.json).

## 7. Transports и HTTP authorization

| Свойство | Current binding |
|---|---|
| stdio encoding | UTF-8; одна JSON message на строку; embedded literal newline запрещён |
| stdio output | stdout только MCP; diagnostics stderr |
| current directions | Нет standalone S→C JSON-RPC requests и C→S JSON-RPC responses |
| stdio cancellation | notifications/cancelled по requestId |
| HTTP body | Один request/notification на POST |
| HTTP result | application/json либо text/event-stream; клиент поддерживает оба |
| HTTP request headers | Version, Method; Name для tools/call, resources/read, prompts/get |
| Header validation | Body/headers совпадают; failure → HTTP400/-32020 |
| Unknown version/method | HTTP400/-32022 либо HTTP404/-32601 |
| Origin | Присутствующий invalid Origin → HTTP403 |
| HTTP subscriptions | POST subscriptions/listen, SSE response |
| HTTP cancellation | SSE disconnect; дальнейшие сообщения запроса запрещены |
| Removed modern features | Session-ID, GET listener, Last-Event-ID resumption |

Если tool schema использует `x-mcp-header`, client зеркалирует разрешённые scalar поля в `Mcp-Param-*`. Validation и base64 sentinel encoding берутся непосредственно из закреплённой [HTTP specification](https://modelcontextprotocol.io/specification/2026-07-28/basic/transports/streamable-http). Входной LMX document для универсального tool не следует зеркалировать в header. [stdio specification](https://modelcontextprotocol.io/specification/2026-07-28/basic/transports/stdio)

Core auth optional; защищённый HTTP deployment использует MCP OAuth contract: discovery через Protected Resource Metadata, audience validation и bearer credentials для каждого запроса. Client ID Metadata Documents рекомендованы; DCR deprecated. STDIO использует credentials окружения. Inbound MCP token запрещено пересылать провайдеру модели: outbound API credentials отдельные. [Authorization](https://modelcontextprotocol.io/specification/2026-07-28/basic/authorization/index), [token boundary](https://modelcontextprotocol.io/specification/2026-07-28/basic/authorization/security-considerations)

## 8. Cache, cursors, progress

Complete results `server/discover`, tools/list, prompts/list, resources/list, resources/templates/list, resources/read содержат `ttlMs` и `cacheScope`. Для изменяемого runtime безопасный по корректности старт — `ttlMs:0`, `cacheScope:"private"`. Cache не переносится между authorization contexts; MRTR responses/continuations не кэшируются. [Caching](https://modelcontextprotocol.io/specification/2026-07-28/server/utilities/caching)

List RPC используют opaque cursors; отсутствие nextCursor означает конец, пустая строка — допустимый cursor. Stable catalog snapshot/epoch и приватность cursor определяет provider. [Pagination](https://modelcontextprotocol.io/specification/2026-07-28/server/utilities/pagination)

ProgressToken — string/integer. Progress возрастает и может быть дробным; total необязателен. Отмена не означает rollback уже выполненных LMX изменений. Различать transport cancellation и durable tasks/cancel. [Progress](https://modelcontextprotocol.io/specification/2026-07-28/basic/patterns/progress), [Cancellation](https://modelcontextprotocol.io/specification/2026-07-28/basic/patterns/cancellation)

## 9. Stable Tasks 2026: отдельный opt-in

Extension identifier — `io.modelcontextprotocol/tasks`; закреплённая schema revision — `2026-07-28`. Клиент объявляет extension в per-request capabilities, сервер — в discover. Только после этого сервер может выбрать `resultType:"task"` вместо синхронного результата. [Tasks overview](https://modelcontextprotocol.io/extensions/tasks/overview)

| Метод/результат | Contract |
|---|---|
| CreateTaskResult | Плоский resultType:task + taskId/status/timestamps/ttlMs/pollIntervalMs? |
| `tasks/get` | resultType:complete + текущее состояние и result/error/inputRequests |
| `tasks/update` | taskId + inputResponses; empty complete acknowledgement |
| `tasks/cancel` | Кооперативная отмена; empty complete acknowledgement |
| `notifications/tasks` | Optional full task state через subscriptions/listen |
| Subscription filter | taskIds:string[] |

Состояния: working, input_required, completed, failed, cancelled. Последние три terminal. Durable task создаётся **до** ответа; process-local временный ID этой гарантии не обеспечивает. `tasks/get` включает terminal payload; отдельного `tasks/result` нет. `tasks/list` в stable Tasks2026 также нет. Tool result с isError:true соответствует completed task, если выполнение RPC завершилось штатно. [Stable Tasks schema](https://github.com/modelcontextprotocol/ext-tasks/blob/main/schema/2026-07-28/schema.ts)

Предлагаемый common runtime job API может появиться раньше MCP Tasks, но тогда Tasks capability не объявляется. Exported task handles не превращаются в глобальные ID объектов LMX.

## 10. Полная матрица legacy 2025-11-25

### 10.1 Requests

| Метод | Направление | Gate / отличие от current |
|---|---|---|
| `initialize` | C→S | Первый lifecycle request; version/caps/clientInfo |
| `ping` | C↔S | Optional ping; при получении promptly return empty result |
| `tools/list`, `tools/call` | C→S | tools; legacy result shapes |
| `resources/list`, `resources/read`, `resources/templates/list` | C→S | resources |
| `resources/subscribe`, `resources/unsubscribe` | C→S | resources.subscribe; URI |
| `prompts/list`, `prompts/get` | C→S | prompts |
| `completion/complete` | C→S | completions |
| `logging/setLevel` | C→S | logging; session log level |
| `roots/list` | S→C | Client roots |
| `sampling/createMessage` | S→C | Client sampling + sub-capabilities |
| `elicitation/create` | S→C | Client elicitation mode |
| `tasks/get`, `tasks/result` | Task requester→receiver | Только experimental tasks profile |
| `tasks/list`, `tasks/cancel` | Task requester→receiver | Только matching experimental tasks capabilities |

### 10.2 Notifications

| Метод | Направление | Gate |
|---|---|---|
| `notifications/initialized` | C→S | После initialize result |
| `notifications/cancelled` | Requester→receiver | Inflight requestId |
| `notifications/progress` | Receiver→requester | progressToken |
| `notifications/tools/list_changed` | S→C | tools.listChanged |
| `notifications/prompts/list_changed` | S→C | prompts.listChanged |
| `notifications/resources/list_changed` | S→C | resources.listChanged |
| `notifications/resources/updated` | S→C | resources.subscribe |
| `notifications/roots/list_changed` | C→S | roots.listChanged |
| `notifications/message` | S→C | logging |
| `notifications/elicitation/complete` | S→C | Optional URL elicitation completion |
| `notifications/tasks/status` | Task receiver→requester | Experimental tasks |

Источник полного inventory — [legacy schema](https://modelcontextprotocol.io/specification/2025-11-25/schema). Ping — [отдельный optional механизм](https://modelcontextprotocol.io/specification/2025-11-25/basic/utilities/ping). Experimental tasks исключены из первоначального compatibility profile: у них другие negotiation fields, request `task.ttl`, per-tool taskSupport и retrieval API. [Legacy tasks](https://modelcontextprotocol.io/specification/2025-11-25/basic/utilities/tasks)

### 10.3 Lifecycle пример

Клиент:

```json
{
  "jsonrpc": "2.0",
  "id": "init-1",
  "method": "initialize",
  "params": {
    "protocolVersion": "2025-11-25",
    "capabilities": {},
    "clientInfo": {"name": "lmx-fixture-client", "version": "0.1.0"}
  }
}
```

Сервер core-only:

```json
{
  "jsonrpc": "2.0",
  "id": "init-1",
  "result": {
    "protocolVersion": "2025-11-25",
    "capabilities": {},
    "serverInfo": {"name": "lmx-runtime", "version": "0.1.0-proposal"}
  }
}
```

Клиент завершает handshake:

```json
{"jsonrpc":"2.0","method":"notifications/initialized"}
```

Если подключён tools provider, initialize result объявляет `tools:{}`. Тогда subsequent tools/call для `lmx` содержит name/arguments без обязательной modern metadata; ожидаемый result аналогичен §6 без обязательного resultType. Одного удаления поля resultType недостаточно для всей compatibility: callbacks и subscription lifecycle тоже преобразует adapter.

HTTP2025 поддерживает POST и GET на одном endpoint; GET SSE можно отклонить 405, если listener отсутствует. Optional session ID выдаётся на initialize, затем повторяется клиентом; истечение → 404 и reinitialize. DELETE optional. Возможна Last-Event-ID resumption, а disconnect сам по себе не отменяет request. Эти правила остаются только в legacy binding. [Legacy transports](https://modelcontextprotocol.io/specification/2025-11-25/basic/transports)

## 11. Fixtures и проверка

Каталог [fixtures/mcp](../fixtures/mcp/README.md) содержит отдельные revision directories. Обёртка exchange описывает HTTP headers/status, направления и preconditions; только поле `body` является JSON-RPC wire message. SSE fixture — действительное SSE тело.

Включены: core discovery, tool listing, LMX document call, MRTR form exchange, subscription ack/event, progress/cancel, negotiated Tasks, unsupported method/version, header mismatch, missing metadata/capability, rejected batch, legacy lifecycle/ping/call и негативная проверка modern MRTR в legacy.

Приёмка интеграции требует исполнения соответствующих vectors реальным codec/runtime. Пока проверяется только корректность самих JSON/SSE fixtures и базовая внутренняя согласованность examples. Optional vectors не являются списком уже доступных возможностей. Conformance имеет смысл только для конкретного revision + transport + feature subset.

## 12. Известные неоднозначности первичных документов

1. **Subscription teardown:** current Cancellation требует server cancellation notification; Subscriptions рекомендует successful final response; schema ограничивает server cancellation stdio. Поэтому open-stream fixture не выбирает спорный способ server closure. Отдельный interoperability policy должен быть закреплён перед заявлением полной совместимости. Источники: [Cancellation](https://modelcontextprotocol.io/specification/2026-07-28/basic/patterns/cancellation), [Subscriptions](https://modelcontextprotocol.io/specification/2026-07-28/basic/patterns/subscriptions), [Schema](https://modelcontextprotocol.io/specification/2026-07-28/schema).
2. **Unknown error ID:** JSON-RPC требует id:null, а MCP schema задаёт optional ID без null. Negative batch vector не скрывает расхождение самодельным обязательным ID. Profile codec должен документировать выбранное поведение и проверять совместимость. [JSON-RPC](https://www.jsonrpc.org/specification), [MCP schema](https://modelcontextprotocol.io/specification/2026-07-28/schema).
3. **Tasks filter:** comment стабильной schema упоминает tasksStatus, но поле TypeScript interface называется taskIds. Контракт/fixtures используют именно taskIds. [Stable schema](https://github.com/modelcontextprotocol/ext-tasks/blob/main/schema/2026-07-28/schema.ts).

Roots, sampling и logging остаются в current спецификации, хотя deprecated; минимальное сохранение — 12 месяцев после 2026-07-28. Наличие deprecated feature не делает её обязательной для нового LMX сервера. [Deprecated registry](https://modelcontextprotocol.io/specification/2026-07-28/deprecated)
