# Основание проекта: документы, примеры и код ядра

Этот проект развивает существующий §36 LMX_semantics. Он не выводится только из краткой старой главы: проверены поставленные примеры, общие правила языка, документация ядра и конкретный source snapshot. MCP и SQLite проверены по первичным спецификациям.

## 1. Снимки

| Архив | SHA-256 | Использование |
| --- | --- | --- |
| 27-Nov-2026-doc.tar.gz | `7b3c31171b98ad1878b821cb1d0d23ff293187ab71f861e760b1d71cf4e5f94c` | Исходные документы, примеры и core catalog |
| 27-Nov-2026-doc-tensor-patch.tar.gz | `d221f6abb48faad1572c45a426339d2935fd99a07fbffcb588e3cc2ce7015a3f` | Предыдущий принятый тензорный delta; применён перед новым патчем |
| selfbuild.tar.gz | `36e4dc2b2d2f94a13c4d32157781c93193823b80676882c8b72b7c69ca3c00a7` | Предоставленный снимок ядра; использован для чтения, не изменялся |

Рабочая основа патча — исходная документация **после применения** предыдущего tensor patch. Поэтому замена только исходного ноябрьского архива без того патча не является правильным порядком применения. Manifest нового архива сохраняет SHA исходных и изменённых документов.

Исходники ядра не входят в delta и не исправлены этим пакетом. Номера строк ниже относятся к `selfbuild.tar.gz`, а не к произвольной более поздней версии. Корень файлов ядра — `selfbuild/src/l2src/`.

## 2. Конкретные опорные механизмы

| Задача | Основание в source | Вывод для API |
| --- | --- | --- |
| Parse source bytes/string | `p0_parser.lm2`, 6158–6205; `l2_graph_build.lm2`, 1505–1530 | Присоединить kernel fromLmx к общему parser/builder |
| Единая группировка | Нормативные grammar/EXPRESSION_ALGORITHM и тензорный implementation plan | Удалить дублирующий внутренний код; сервер не создаёт свой parser |
| Typed invocation | `lmx_graph_run.lm2`, 5622–5777 и 7297–7402 | Общий допуск, actuals, origins, roots и выбор callable |
| Native/walker dispatch | `lmx_call.lm2`, 623–672 | Новая CODE-ссылка без native исполняется обычным интерпретируемым путём |
| Удержание frames/roots | `lmx_call.lm2`, 527–579; `lmx_graph_run.lm2`, 5689–5697 | Callback и возвращённые refs не ссылаются на освобождённые locals |
| Copy/merge | `lmx_graph_copy_owned.lm2`, 4264–4638 | Одна operation map сохраняет cycles/sharing/parents; без text roundtrip |
| Диагностический dump | `lmx_graph.lm2`, 2713–3530; цикл в 2748–2759 | Найденное `...` не является полным kernel toLmx; общий ресивер требует доведения |
| Mail delivery | `lmx_service.lm2`, 150–237; `lmx_post.lm2` | Использовать существующий Message/post, не второй dispatcher/registry |
| Turn boundary | `lmx_turn.lm2`, 26–105 | Реальные publication/cleanup; это не rollback всех graph stores |
| Deadline/stop | `lmx_thread.lm2`, 870–921 | Просьба остановки, timeout и подтверждённая остановка различны |
| Process watchdog | `lmx_process_deadline.lm2`, 53–69 | `c.abort()` — процессная аварийная граница, не отмена отдельного MCP request |
| Графовый обход для каталога | `l2_graph_tool.lm2`, 73–315, 2511–2572 | Local map выделяет label до edges, сохраняет cycles/sharing и parents |
| Native association publication | `lmx_call.lm2`, 206–268; callers в copy engine | Полезный primitive, но не готовая проводка compiler catalogue на endturn |
| Network byte providers | Каталог llhttp/mbedTLS/libevent; source I/O в `l2_libc.lm2` | Каталожные bindings NOT_RUN; готовый HTTP/TLS/MCP listener не подтверждён |

Полные аргументы и source hashes — в [аудите ядра](audit/RUNTIME_SOURCE_AUDIT.ru.md), [машиночитаемых доказательствах](audit/SOURCE_EVIDENCE.json) и [аудите компиляционного каталога](audit/COMPILER_CATALOGUE_AUDIT.ru.md). Их пути `documentation/docs` и `core/selfbuild` обозначают восстановленные input trees. Они не требуют включать неизменённое ядро в патч.

## 3. Нормативные договоры, которые нельзя подменить адаптером

[LMX_semantics](../../spec/LMX_semantics.ru.md) и `kernel-implementation` задают чистый граф, written receivers, types, DATA/CODE/TYPE/RAW roles, names, ownership, call/Message, native и source codec. Проект использует следующие правила:

- `fromLmx` возвращает чистый graph, пригодный для compile; это тот же graph, который runtime может интерпретировать.
- `toLmx` выводит LMX любой Structure и любого L3Thread, включая предусмотренные таблицы арены Thread.
- Записанный receiver не заменяется результатом его вычисления в авторитетном source graph.
- `node` и `parent(C)` относятся к действительному lexical graph, а не к последнему месту хранения ссылки.
- `private` фильтрует implicit binding в обе стороны, но не является защитой от explicit graph access.
- Named function signature не доказывает конечные throws фактического тела; concrete consumer admission остаётся общим.
- `endturn` не возвращается и сам не компилирует. После явного compile публикация требует настоящего boundary hook.
- Прямые native calls и уже выбранные frames не перенаправляются из-за записи нового graph field.
- Отсутствие файла исходника не препятствует работе живого графа и его kernel toLmx.

Сопровождающий [аудит LMX-заготовок](audit/LMX_SOURCE_REVIEW.ru.md) фиксирует точные правила callback lifetime, signature/throws, persistent writes и используемый синтаксис.

## 4. Реальные архивные примеры

| Источник в исходных документах | Что использовано |
| --- | --- |
| `spec/patterns/03_domain_and_persistence/examples/lmx/026_table_module.lm3` | `[]@` строк, цикл по length, explicit row paths и вычисление агрегата |
| `spec/patterns/06_async_and_messages/examples/lmx/061_active_object.lm3` | Обычные service calls через post/ask/answer |
| `spec/patterns/06_async_and_messages/examples/lmx/058_thread_pool.lm3` | Настоящее owner state через node, выбранные worker refs |
| `spec/patterns/06_async_and_messages/examples/lmx/060_actor_model.lm3` | Обычные методы и состояние активного объекта |
| `spec/patterns/02_architecture_and_boundaries/examples/lmx/009_microservices.lm3` | Явно переданный exchange provider |
| `spec/LMX_semantics`, §21 | Таблицы как ordinary values; columns/rows не являются namespace registry |
| `spec/LMX_semantics`, §28 и §32 | Message contracts и native application/lmx transport |

Новые примеры используют настоящие LMX DATA/CODE тела, named actuals и field references. `name :: ...` объявляет сигнатуру; исполняемое тело представлено обычным дочерним CODE. Ссылка на `Component\apply` отличается от ссылки на `Component` самого.

Архивные примеры и новые bounded source checks не являются доказательством запуска на текущем ядре. Этот статус указан в [VALIDATION](VALIDATION.ru.md).

## 5. MCP и SQLite

[MCP compatibility](MCP_COMPATIBILITY.ru.md) содержит ссылки на закреплённые primary specifications current 2026-07-28 и legacy 2025-11-25. Основной серверный инструмент `lmx` принимает точный document; стандартные resources/prompts/discovery и optional features сохраняют свои wire contracts. Полный граф не уплощается в JSON.

[Каталог SQLite](CATALOGUE_SQLITE.ru.md) ссылается на документацию STRICT tables, parameters, transactions/isolation, recursive CTE и optional FTS5. SQL fixtures действительно исполнены на host SQLite; это отдельное доказательство схемы и запросов, не запуска LMX SQLite binding.

## 6. Прямые границы готовности

Уже можно оценивать архитектуру, точный API, реальные LMX-тела и смысл SQL-запросов. Завершённый server runtime пока требует реальных provider bindings, полного kernel codec, compiler/owner publication hook, сетевого I/O и versioned MCP state machine.

Проект не заменяет эти части mocks, echo-ответом, фиктивным success либо параллельной реализацией ядра. [План](IMPLEMENTATION_PLAN.ru.md) связывает каждую доработку с конкретным источником и проверяемым результатом.
