# LMX runtime: собственный сервер, агенты и каталог

Редакция 27 ноября 2026 года. Пакет содержит патч нормативной документации, конкретный API и **LMX-заготовки**, основанные на примерах документов и предоставленном ядре. Runtime одновременно служит себе, внешним MCP-клиентам и местным агентам.

Это законченный проект и комплект исходных заготовок. Это ещё не установленный MCP-сервер: kernel/provider bindings, compiler/endturn hook и end-to-end runtime прогон остаются работой по [плану](docs/IMPLEMENTATION_PLAN.ru.md).

## Читать по задаче

| Нужно | Документ |
| --- | --- |
| Понять общую архитектуру | [ARCHITECTURE](docs/ARCHITECTURE.ru.md) |
| Точные методы, аргументы, результаты и callbacks | [API](docs/API.ru.md) |
| Текстовый обмен LMX без MCP envelope | [NATIVE_PROTOCOL](docs/NATIVE_PROTOCOL.ru.md) |
| Стандартный MCP, current и legacy | [MCP_COMPATIBILITY](docs/MCP_COMPATIBILITY.ru.md) |
| Полезная каталогизация, DDL, queries и публикация | [CATALOGUE_SQLITE](docs/CATALOGUE_SQLITE.ru.md) |
| Конкретные места ядра и исходные примеры | [SOURCE_EVIDENCE](docs/SOURCE_EVIDENCE.ru.md) |
| Что реализовать и как принять результат | [IMPLEMENTATION_PLAN](docs/IMPLEMENTATION_PLAN.ru.md) |
| Что действительно проверено | [VALIDATION](docs/VALIDATION.ru.md) |

Обновлён сам [§36 LMX_semantics RU](../spec/LMX_semantics.ru.md#edit-api) и [EN](../spec/LMX_semantics.en.md#edit-api), а также основные формулировки fromLmx/toLmx и поисковой проекции тестов. В исходной документации сохраняется весь предыдущий тензорный патч.

## Основные решения

1. Сервер, агентский цикл, state и маршрутизация — обычные LMX DATA/CODE.
2. Native LMX, стандартный MCP JSON-RPC и местный Message сходятся в один runtime path.
3. `fromLmx` даёт чистый пригодный для compile graph; `toLmx` выдаёт LMX любой Structure и любого L3Thread.
4. Один parser с делегирующим `[]`-подпарсером и один общий код группировки.
5. Стабильный service entry читает изменяемую CODE-ссылку на owner; новое интерпретируемое поведение не требует compile.
6. Компиляционный каталог SQLite сохраняет факты того же графа, их происхождение и границы знания.
7. Публикация кандидата идёт настоящим hook соответствующего успешного endturn; SQL atomicity не объявляется транзакцией всего runtime.
8. Актуальное состояние берётся у живого runtime. Исходник на диске вторичен; старый каталог остаётся обозначенным снимком.

## LMX-исходники

| Порядок | Файл | Что в нём |
| --- | --- | --- |
| 1 | [models.lmx](src/models.lmx) | Stage, Receipt, ModelAnswer, Decision, Event, Exchange и обычные constructors |
| 2 | [ports.lmx](src/ports.lmx) | Типизированные runtime/model/transport/MCP contracts |
| 3 | [core.lmx](src/core.lmx) | Общий prepare/execute path, Service, admit/replaceHandler и фасады |
| 4 | [agent.lmx](src/agent.lmx) | Настоящий bounded ask→model→command→receipt цикл через post |
| 5 | [boundaries.lmx](src/boundaries.lmx) | Native/MCP/frame adapters к тому же Service |
| 6 | [catalogue.lmx](src/catalogue.lmx) | Collector facts с while/finally, pending publication и query facades |

Затем выбираются нужные файлы [examples](examples/01_table_and_tree.lmx). При объединении исходников в один unit между файлами вставляется пустая физическая строка корневой границы. Нельзя присоединять следующий корень непосредственно после последней вложенной строки предыдущего файла. Специальный module loader не вводится: общий builder разрешает обычные имена в supplied unit/context.

Провайдерские поля сознательно не имеют фиктивных тел. До вызова связываются реальные реализации и допускаются их actual signatures/finite exits/owner lifetime. Все helpers на Python в пакете относятся к host-проверке SQL и документации; сервер на Python не написан.

## Семь примеров

| Файл | Сценарий |
| --- | --- |
| [01_table_and_tree](examples/01_table_and_tree.lmx) | Обычная таблица, aggregate, иерархия и общая ссылка |
| [02_user_ask](examples/02_user_ask.lmx) | Пользовательский Chat с реальными service/model/sink dependencies |
| [03_local_messages](examples/03_local_messages.lmx) | Текст и ready graph через post, настоящий Receipt/failure sink |
| [04_remote_documents](examples/04_remote_documents.lmx) | Полные inspect/insert/step документы |
| [05_agent_decisions](examples/05_agent_decisions.lmx) | Продолжение/завершение через обычный результат Decision |
| [06_hot_replace](examples/06_hot_replace.lmx) | Установка нового CODE без перекомпиляции старого |
| [07_stop_and_late_receipt](examples/07_stop_and_late_receipt.lmx) | Остановка новых раундов и наблюдение позднего actual receipt |

После связывания зависимостей пользовательская форма:

```lmx
Chat\ask(question := "Inspect Work and explain its state.")
```

Результат модели — целый ordinary LMX-документ. Он исполняется на стороне runtime; следующее обращение к модели использует фактический receipt. Ни модель, ни constructor Receipt не подтверждают невыполненные эффекты.

## SQLite и MCP fixtures

[schema/catalogue.sql](schema/catalogue.sql) — настоящая исполнимая схема: одна main facts table для одного owner namespace. [SQL fixtures](fixtures/catalogue/README.md) включают sample SQLite database, DDL/DML, query cases, null slot, cycles/shared refs, stale-key protection, constraints, transaction visibility и отчёт выполнения. Данные синтетические; они не выданы за kernel toLmx capture.

[MCP fixtures](fixtures/mcp/README.md) содержат эталонные JSON/SSE exchanges current 2026-07-28 и legacy 2025-11-25, positive/negative cases. Файлы проверены как данные; обмен с работающим LMX MCP-сервером пока NOT_RUN.

## Применение документационного патча

Внешний архив — delta к `27-Nov-2026-doc.tar.gz` **с уже применённым** `27-Nov-2026-doc-tensor-patch.tar.gz`. В нём два изменённых существующих документа и новый `docs/runtime_server/`; неизменённые исходники ядра и документация не включены.

Полные replacement-файлы нужны для обычного наложения на соответствующую основу. [Unified diff](changes/LMX_semantics.diff) показывает изменения двух нормативных файлов для review. Manifest и инструкция в корне delta задают исходные SHA и полный список включённых файлов. Новый пакет не отменяет ранее принятые правила тензоров, depth, приоритета/ассоциативности степени или общего parser.
