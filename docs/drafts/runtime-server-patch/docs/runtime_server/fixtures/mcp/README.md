# MCP wire reference fixtures

Дата: 2026-11-27. Статус: **REFERENCE_FIXTURES_NOT_RUN**.

Эти файлы задают versioned wire shapes и ожидаемую корреляцию. Они не утверждают, что прилагаемый LMX runtime уже реализует MCP или что fixtures выполнены ядром. Полный контракт: [MCP_COMPATIBILITY.ru.md](../../docs/MCP_COMPATIBILITY.ru.md).

## Формат

JSON-файл — exchange fixture, не целиком MCP request. Поле `fixture` содержит revision, preconditions и runtimeStatus. В HTTP exchanges поля `request.body`/`response.body` — сообщения wire, а headers/status описывают transport. В stdio exchanges wire messages находятся в `request`/`response` либо `exchange[].body`; направление явно задано. Для фактического stdio JSON нужно компактно сериализовать в одну строку и добавить newline.

`05_subscriptions_open.sse` — готовое тело SSE с двумя `event: message`; JSON внутри data совпадает с соответствующими объектами в соседнем JSON fixture. Server teardown намеренно не включён из-за расхождения нормативных страниц; см. документ совместимости.

## Current 2026-07-28

| Positive | Что проверять |
|---|---|
| 01_discover_core | Required metadata; no optional capabilities; resultType; cache hints |
| 02_tools_list | Test tools provider; schemas; complete/cache fields |
| 03_lmx_tool_call | Header/body match; string document; JSON metadata + LMX text |
| 04_mrtr_form | Embedded client request; capability; new ID on retry |
| 05_subscriptions_open | First ack; filter subset; subscriptionId type/value |
| 06_stdio_progress_cancel | Progress token; cancellation requestId; no messages after cancel |
| 07_tasks_extension | Both-peer opt-in; flat createTask/get shapes; terminal result |

| Negative | Ожидание |
|---|---|
| 01_unknown_method | HTTP404 / -32601 |
| 02_header_mismatch | HTTP400 / -32020; runtime не вызван |
| 03_unsupported_version | HTTP400 / -32022 + requested/supported |
| 04_missing_client_capabilities | stdio -32602 |
| 05_batch_not_supported | Нет MCP batch; -32600; error-ID policy отдельно |
| 06_missing_required_feature | -32021 + requiredCapabilities; provider не вызывается |

## Legacy 2025-11-25

Positive: initialize/initialized core-only, ping, tools/call после tools-enabled handshake. Negative: современный MRTR result не заменяет legacy серверный request/callback. Наличие неизвестных result fields само по себе не объявляется schema failure; проверяется смысловая несовместимость flow.

## Связь с LMX

`1 + 2` — короткий полный ExpressionCODE input. Математическое ожидаемое значение — 3. `int: result 3` — reference typed-document output, не лог исполнения неизвестного serializer. Context выбирает конфигурация endpoint/provider и admission; в arguments отсутствует глобальный runtime object ID.

Tool/MRTR/Tasks examples имеют явные prerequisites. Core discovery fixture с `capabilities:{}` не обещает эти возможности. Для реального стенда сначала требуется зарегистрировать providers и объявить соответствующие capabilities.

## Проверено здесь

- Файлы JSON синтаксически корректны.
- SSE data синтаксически корректны и совпадают с exchange fixture.
- Направления и IDs в reference обменах согласованы; обязательные current metadata присутствуют в positive requests.
- Runtime execution, HTTP server, OAuth, durable persistence, JSON Schema 2020-12 conformance — **NOT_RUN**.

Список файлов: [MANIFEST.json](MANIFEST.json).
