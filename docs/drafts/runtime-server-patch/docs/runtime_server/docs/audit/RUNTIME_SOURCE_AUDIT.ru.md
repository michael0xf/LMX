# Аудит основания для сервера LMX runtime

Дата: 2026-11-27. Область: восстановленные документы `documentation/docs` с финальным тензорным patch и исходники `core/selfbuild` из предоставленного архива. Это чтение исходников и нормативных документов. Ядро не изменялось; сборка, запуск примеров, сетевой обмен и conformance-тесты в рамках этого аудита не выполнялись.

SHA-256 `selfbuild.tar.gz`: `36e4dc2b2d2f94a13c4d32157781c93193823b80676882c8b72b7c69ca3c00a7`. Номера строк ниже относятся именно к этому снимку. Обозначения: **S** — `documentation/docs/spec/LMX_semantics.en.md`; **K** — `documentation/docs/spec/kernel-implementation.en.md`; имена `.lm2` без каталога — `core/selfbuild/src/l2src/`.

## 1. Главный вывод

Сервер следует оформить как прикладной слой на LMX: обычные Structure, методы, состояние, Message/post и один общий dispatcher над сервисами runtime. У него могут быть MCP JSON-граница и непосредственный обмен цельными документами LMX. Оба входа должны готовить одни и те же обычные вызовы и направлять их одному владельцу состояния. JSON-кодек не является вторым парсером LMX; разбор текста LMX, выражений и `[]` принадлежит общему языковому коду.

Архитектура уже имеет нормативное основание в **S §36, “Mutating debug API for an AI chat”**, включая вставку исходника, копирование подготовленных структур, осмотр настоящего графа, управление конкретным исполнением, внешнюю модель и различение ошибки, таймаута и неизвестного исхода. Эта глава прямо объявляет требования, а не законченную реализацию. Новый сервер должен развить этот договор и показать недостающие интеграционные границы, а не объявлять все перечисленные `sys`-приёмники доступными сегодня.

Уточнение автора принято как нормативный контракт: общий kernel receiver `fromLmx(text)` строит чистый граф, пригодный для компиляции; `toLmx(S)` получает полный LMX-код из любой Structure и любого L3Thread. Source → `fromLmx` → clean graph далее идёт либо через ordinary admission/execution, либо через явную compilation. Собственного серверного сериализатора и урезанного контракта `toLmx` не вводится.

Код содержит P0 parser/builder, типизированное выполнение и вызов, roots/activation lifetime, копирование графов, mailbox и turn boundaries. Завершённость общего переносимого `toLmx`-кодека, готовый MCP/HTTP/TLS listener, публичный комплект runtime-service receivers и безопасное прекращение любого отдельного вызова по таймеру этим чтением не подтверждены. Найденные пробелы codec — задача довести общий kernel receiver до полного договора, а не повод заменить его другим форматом.

## 2. Что есть в исходниках и что остаётся договором

| Область | Наблюдаемая реализация | Нормативная граница и работа для сервера |
| --- | --- | --- |
| Source → parser → graph | `p0_parser.lm2:6158–6205`: `lm_p0_parse_bytes`, `lm_p0_parse_string`; `l2_graph_build.lm2:1505–1530`: file parser → `lm_graph_build_root`; `l2_graph_tool.lm2:2718,2810`: сборка нескольких sources с тем же P0. | Адаптировать вход из байтов и структурированные diagnostics вокруг общего кода. Не подменять его line parser, regex-командами или парсером скобок в транспорте. |
| Общая группировка выражений | Старые пути ещё разделены; предыдущий план документирует три места/шкалы и отсутствие `**` в старых таблицах. | Цель — одна реализация группировки и общий parser с вызывающим его `[]`-компонентом. Дубликаты требуется удалить, а не согласовать серверным адаптером. См. `tasks/LMX_tensor_implementation_plan_2026-11-27.md:7,22–30,59–73`. |
| `check`, `checkL3`, `translate`, `compile` | Общие builder/frontend/backend доступны на внутренних уровнях; `l2_frontend_graph.lm2:1407–1456` использует общий builder и публикует перевод только после успешного завершения. | **S:147–170** прямо называет перечисление `sys`-путей нормативными receiver contracts. Нельзя на основании одного перечисления объявлять их установленными. Нужна привязка реальных entry points к обычным LMX receivers и отчёт о поддержанных профилях. |
| Оценка и обычный вызов | `lmx_graph_run.lm2:6013`: `lmx_graph_eval_record`; `5622–5777`: typed data invocation; `5788–5792`: `lmx_graph_invoke_values`; `7297–7402`: selection и отдельный вызов выбранного кандидата. `lmx_call.lm2:623–672`: native-or-walker dispatch. | Runtime eval/invoke должен вызывать этот механизм с реальным scope, actuals, requirements и diagnostics. Не исполнять кандидатов ради overload resolution и не заводить второй evaluator. |
| Сохранение/осмотр графа | `lmx_graph.lm2:2713–3530` содержит **toLmx-like** print/dump. При неназванном цикле `2748–2759` печатает `...`; `3511–3515` — публичный dump. | Это не полный обещанный `toLmx`: **K:1119–1143** требует null slots, shared links, cycles, parent/name/type/source receivers и переносимое восстановление. Полный export нельзя реализовать этим dump с успешным статусом. Необходимо довести общий kernel receiver до полного договора; если сборка его ещё не предоставляет, это явный implementation gap. Preview допускается только как отдельно запрошенное представление, никогда как замена полного `toLmx`. |
| Graph copy/merge | `lmx_graph_copy_owned.lm2:4264–4460` — общий copy engine; `4460–4638` — staged/profiled/owned wrappers. `lmx_graph_run.lm2:9425,9535,9632` — merge/copy consumers. | Пользоваться общей map для shared links/cycles, names, parents, qualifiers и допустимых native associations. Copy подготовленного графа не превращать в `dump → parse`. `copy(S)` один источник; `merge(A B …)` несколько; placement — отдельное действие (**S:3150–3181,3752–3758**). |
| Lifetime и активные вызовы | `lmx_call.lm2:527–579`: execution roots. `lmx_graph_run.lm2:5689–5697` удерживает actuals/body/data/code до activation; `5737–5767` выбирает native либо walker и завершает frame. | Долгоживущий сервис не может хранить сырой указатель в уже освобождённый turn/frame. Передача ref между owner/arena требует обычного retention/admission либо copy. Session handles при необходимости являются локальными данными сервера, не новыми глобальными идентификаторами объектов ядра. |
| Mail/service delivery | `lmx_service.lm2:150–237`: регистрация Thread по адресу, поиск и `lmx_post_accept_transfer`; `lmx_post.lm2:351,416,471,586,610,632`: accept/take/publish/discard/close. | `lmx_service` здесь — доставка почты конкретным Thread, а не HTTP service registry. Наличие этих функций не доказывает полную проводку каждого высокоуровневого `post`-образца. Прикладной dispatcher сохраняет ordinary call/admission semantics. |
| Turn boundary | `lmx_turn.lm2:26–105`: при успешном turn публикуется staged mail, при неуспехе оно отбрасывается, обрабатываются подготовленные children, cleanup/GC. | Это не транзакция графа. Уже сделанные stores и внешние эффекты не откатываются. Serial owner lane защищает порядок доступа, но не даёт rollback (**S:3341–3436**). |
| Clock и остановка | `lmx_clock.lm2` содержит now/ticks/deadline helpers. `lmx_thread.lm2:870–921` публикует stop/deadline без перезапуска срока повторной остановкой. | Timeout ожидания ответа, cooperative cancel, остановка Thread и аварийное завершение процесса — разные события. Нельзя вернуть “cancelled”, пока подтверждена лишь запись просьбы остановиться. |
| Process watchdog | `lmx_process_deadline.lm2:1–69` использует Win32 event/thread; timeout-ветвь `53–69` вызывает `c.abort()`. | Это guard закрытия поддерева/процесса, не переносимый механизм отмены одного запроса MCP. Обещание точного лимита CPU для произвольной native инструкции требует другой границы изоляции/исполнения. |
| Byte/text I/O | `l2_libc.lm2:1–11` даёт stdout/stderr accessors; parser читает файл через libc; backend пишет FILE (`l1_backend_text.lm2:176,198`). | Нужен узкий byte transport с точными length/encoding/partial-read/partial-write/EOF/error semantics и раздельными diagnostics. Наличие FILE I/O не равно готовому MCP stdio event loop. |
| Socket, HTTP, TLS | Поиск подключённого кода в `core/selfbuild/src` и `tools` по socket/listen/accept/recv/send/poll/select, SSL, socket headers, HTTP/1 не нашёл сетевой listener/loop. | Сетевые библиотеки в `docs/core_catalog` — каталог/заготовки. llhttp, mbedTLS и libevent не считать готовыми подключёнными bindings; их reference-файлы отмечают runtime `NOT_RUN`. “TLS” в thread-коде также может означать thread-local storage. |

Проверка исходника не равна доказательству runtime-conformance. Например, `spec/patterns/06_async_and_messages/verification.json` явно содержит `lmx_runtime_executed: false`. Примеры полезны для формы LMX и границ зависимостей, но не являются результатом текущего запуска.

## 3. Что уже требует §36 и следует перенести в новый API

**Цельный ответ модели.** Законченное сообщение рассматривается как один целый command document. Оборванный ответ нельзя исполнить до последней “похожей на законченную” строки. После получения всего документа идут обычный parse/translation/admission и исполнение владельцем. Один ответ модели не означает автоматически одну команду или один turn (**S:3715–3720**).

**Четыре разных роли.** Source reference, placement target, execution target и observation root нельзя сводить к одному неоднозначному `target`. Имена разрешаются при подготовке в явно переданном контексте. Для записи нужен настоящий PLACE с владельцем. У ядра не появляется глобальный object-ID/string-lookup registry; адрес RAM не переносим между процессами (**S:3721–3725**).

**Полнота наблюдения.** `toLmx` обязан представлять запрошенную разрешённую область. Для больших результатов нужны явные диапазоны/chunks и continuation; молчаливое `…` или ограничение глубины не доказывает отсутствие содержимого. Наблюдение одного owner не является снимком всего распределённого процесса (**S:3727–3732**). Для пагинации нужно сообщать согласованность наблюдения и не выдавать несколько изменившихся чтений за атомарный snapshot.

**Insert — не invoke.** Вставка source использует настоящий контекст, parser/builder и owner placement. Декларация метода не запускает его. Неуспешная подготовка до размещения не разрешает менять target; это не обещание откатить любые уже совершённые внешние эффекты (**S:3738–3750**).

**Выполнение — не предсказание.** `interpreter ... next` продвигает конкретный Thread/continuation до поддержанной точки наблюдения. Native call может быть неделимым. Адаптер не обнуляет native association и не включает принудительный walker для обещания удобного шага. Step/turn/Thread end — разные границы (**S:3785–3808**).

**Состояние результата должно быть честным.** Parse/admission error, execution failure, not delivered, still running, lost answer и неизвестный исход имеют разные значения. Доставка не есть успех выполнения. Повтор эффекта после потерянного ответа без явной идемпотентности может выполнить его ещё раз (**S:3809–3818**).

**Провайдер модели — внешний адаптер.** **S:3824–3827** уже задаёт текстовый request/response; HTTP, JSON, SDK, credentials, model и price являются конфигурацией адаптера, не семантикой графа или языка. Локальная модель пользуется тем же договором.

## 4. Доработка без перекомпиляции: корректная граница

Такой режим согласуется и с документами, и с текущим dispatch. **S:2610–2639** требует: обычная запись графа не очищает native, не создаёт dirty/version tracking и не вызывает скрытую компиляцию. Приходящие как Message скрипты интерпретируются; compile вызывается явно. Существующий direct native A→B не перенаправляется заменой графового B или его отдельной перекомпиляцией.

Для изменяемого server service layer пригоден следующий обычный pattern:

1. Новый source обрабатывается общим parser/builder в заданном context. Подготавливается **новая** ordinary callable Structure с новым interpreted body; у неё нет унаследованной от старого тела native association.
2. Проверка/admission заканчиваются до публикации новой handler reference. Новый компонент удерживается допустимым owner/arena lifetime. Если разрешения или lifetime не подходят, операция отказывает; скрытого продления умершего stack frame нет.
3. Владелец dispatcher в своём turn обычной записью заменяет **реальную reference** на обработчик. Передача запроса и замена ссылки имеют определённый порядок у этого владельца. Другие adapters не пишут его граф конкурентно.
4. При каждом новом выборе обработчика dispatcher действительно читает эту изменяемую reference и делает обычный динамический вызов. Этот участок нельзя незаметно заменить статическим прямым C-вызовом старого метода.
5. Вызов, уже выбравший прежний callable/body, сохраняет прежние объекты обычными execution roots/activation. Замена ссылки не уничтожает активный body и не переписывает его frame. Future selections после owner publication используют новую reference. Запрос, только находящийся в очереди, относится к старому или новому обработчику по фактическому моменту binding/selection, а не по сетевому времени поступления.
6. После завершения старых вызовов освобождение происходит по обычным правилам lifetime. Отдельный глобальный registry поколений, native invalidator, forced walker и новая система владения для этого не нужны.

Это **не** обещание snapshot всей изменяемой среды старого вызова. Если он обращается к другим общим данным, их видимость определяется обычными правилами owner/lifetime/turn. Для согласованной замены компонента нужно менять ссылку на новый компонент, не мутировать in-place body уже исполняющегося объекта и не обещать магический rollback.

Исходное основание: `lmx_call.lm2:645–658` выбирает native при наличии либо walker при отсутствии; `lmx_graph_run.lm2:5689–5697` удерживает body/data/code; `5737–5767` выполняет выбранный путь. Нормативное основание: **S:2610–2639,3760–3783**, **K:1032–1092**. Поскольку copy сохраняет допустимые native associations, “скопировать старый callable и заменить его body, сохранив native descriptor” нельзя выдавать за этот pattern (**S:3150–3181**).

`compile` и `endturn` остаются отдельным явным сценарием публикации native-кода. `endturn` не компилирует, не является catchable обычным return и не освобождает активные старые machine frames до их завершения. Работающий interpreted сервер можно расширять без compile; изменение произвольного уже скомпилированного direct-call участка этим автоматически не достигается.

## 5. Минимальные интеграционные границы

Следующие названия — **категории предлагаемых контрактов серверного пакета**, не утверждение о существующих глобальных `sys`-функциях. Их конкретные LMX имена должен задать основной проект. Прикладная политика, каталоги MCP, маршрутизация, correlation, обработка результатов и цикл агента остаются LMX-кодом.

| Граница | Что она обязана делать | Чего в ней не должно появиться |
| --- | --- | --- |
| Byte transport | Читать/писать конечные frames/bytes; честно различать EOF, partial I/O, oversize и error; раздельно выводить protocol и logs. | Разбора LMX bracket nesting, командной семантики, нового языка строковых команд. |
| Shared preparation | Вызывать общий parser/builder/check/translate с source, scope/context и diagnostic output. | Второго AST как source of truth, повторного группировщика, выполнения непроверенного префикса документа. |
| Ordinary runtime invocation | Подготовить настоящий callable/actuals и обратиться к общим selection, admission, dispatch и owner delivery. | Словаря экспортированных методов, автоматически меняющего semantics метода, своего evaluator или прямой конкурентной записи owner graph. |
| Graph observation and export | Осматривать реальные разрешённые значения; вызывать полный общий kernel `toLmx` для Structure/L3Thread; выдавать явные pages/chunks без потери содержания. | JSON-перекодировки, теряющей shared links, циклы, типы, пустые slots и происхождение written receivers; dump под видом полного save. |
| Retained references | Обеспечить реальный обычный root/arena lifetime на срок использования сервером; освобождать на owner boundary. Если нужны wire handles, разрешать их через session-owned explicit state и проверять срок/права. | Переноса адреса RAM, глобального реестра всех объектов языка, негласного продления stack lifetime. |
| Clock and cooperative control | Давать monotonic time, budgets, статус исполнения и допустимые точки запроса остановки. | Приравнивания timeout к отмене, закрытия answer route по timeout, обещания interrupt произвольной native инструкции. |
| Optional network/provider I/O | Socket/event loop/HTTP/TLS и typed provider request/result boundary, без раскрытия credentials в обычных graph resources. | Реализации всего dispatcher/agent loop на другом языке либо provider-specific LMX DSL. |
| Explicit build | Привязать реальные check/translate/compile profiles; вернуть diagnostics; native публиковать только по действующему договору. | Автоматического compile при вставке, графовой записи, смене handler или `endturn`. |

Byte transport и network/provider могут быть платформенными L2/C bindings. Это не мешает серверу быть написанным на LMX: такая граница выполняет I/O и уже существующие runtime primitives; бизнес-операции и self-hosted цикл реализованы ordinary LMX services. Нельзя каждую серверную операцию скрыть за одним непрозрачным host `executeAnything` и назвать оставшиеся декларации реализацией сервера на LMX.

## 6. Категории API, подходящие этому основанию

Один сервисный набор полезно разделить на группы по предмету операции, сохранив общий dispatcher:

- Документация и договор: описание доступных profiles, именованных API, ошибок, build capabilities и source/version evidence.
- Контексты: выбрать доступный evaluation context/owner, подготовить source, связать полученные refs с разрешённым lifetime.
- Graph/value: inspect, полный export, явно запрошенные ranges/chunks, metadata/provenance, release удержанной reference. Детали машинного хранения не становятся portable wire identity.
- Runtime: eval подготовленного выражения, invoke настоящего callable с actuals, insert/replace на настоящем PLACE, copy подготовленного graph, наблюдение/next конкретного исполнения.
- Build: check/checkL3, translate, explicit compile; доступные уровни/профили сообщаются по фактической реализации.
- Операции: status, progress, request cancellation, truthful terminal outcome, retention результата, idempotency только как явно выбранная прикладная политика.
- MCP presentation: tools/resources/prompts описывают этот же набор ordinary services и permitted graph/doc views. Они не образуют отдельный движок исполнения.
- Model provider: текстовый запрос с явными настройками/limits и полный результат/ошибка; исходные parts/finish reason/usage могут храниться как обычные metadata provider layer, не команды runtime.

Для поддержки native LMX commands нет необходимости сделать JSON form обязательной внутренней моделью. LMX document уже может описывать данные и ordinary вызовы. MCP JSON adapter должен создавать эквивалентные actuals к существующим сервисам; типы, не представимые обычным JSON без потерь, экспортируются явным LMX representation/profile или reference согласно договору сервиса.

## 7. Self-hosted цикл модели и местных агентов

Желаемый пользователем цикл можно собрать поверх предыдущих контрактов: ordinary LMX agent получает запрос → готовит observation/prompt в разрешённом контексте → вызывает provider adapter → получает законченный текст → передаёт **весь** command document общему parser/builder → допускает запрошенные operations → направляет их owner → получает фактические результаты → при необходимости повторяет цикл.

Local agents используют тот же сервисный слой через ordinary Message/post. Им не требуется путь HTTP/MCP для доступа к соседнему LMX service. MCP нужен внешнему клиенту, а локальные агенты могут вызывать подготовленные ordinary методы с настоящими typed values и refs, сохраняя common admission and lifetime.

`post` не является новым engine вызова и не создаёт скрытой экспортной таблицы. **S:3411–3436** задаёт нормальные signatures/conversions/throws, sender-owned waits и original send time. Timeout ожидания не отменяет выполнение, не закрывает route и не отбрасывает поздний answer. Сеть/provider adapter обязаны различать “запрос не отправлен”, “отправлен, исход неизвестен”, “пришёл полный ответ”, “ответ оборвался” и “выполнение команд подтверждено”. Автоматический retry после lost answer возможен только с явной безопасной/idempotent политикой конкретной операции.

Model output, source comments и полученные через resources документы не приобретают полномочий. Они обрабатываются как данные до явного допуска всей программы в выбранном контексте. Это правило уже присутствует в **S §36**; оно совместимо с полностью автономным авторизованным агентом и не означает обязательного подтверждения человеком на каждом turn.

## 8. Найденные примеры и честная готовность

`spec/patterns/06_async_and_messages/examples/lmx/060_actor_model.lm3` содержит ordinary `CounterMessage` с параметром, состоянием, `add` и `read`. Это полезная форма local service body; имя само по себе не доказывает запущенный Thread/message server.

`spec/patterns/02_architecture_and_boundaries/examples/lmx/009_microservices.lm3` содержит `Catalog` и `Checkout`; `Checkout` принимает ordinary `@: exchange` и вызывает его с endpoint/route/quantity. Это существующий пример явной внешней зависимости, а не доказательство установленного HTTPS client.

`spec/patterns/06_async_and_messages/verification.json` фиксирует, что LMX runtime не запускался. Наличие файлов fixtures в `core/selfbuild/tests`, в том числе `dyn/native_descriptor_storage.lm2`, `dyn/execution_gc_native.lm2`, `graph/copy_callable_current.lm3`, `graph/path_write_native_level2.lm2`, полезно для выбора будущих checks, но не является сегодняшним PASS.

`core_catalog/reference/http_parser_llhttp.md`, `base_mbedtls.md`, `network_extra_libevent.md` и соответствующие `.lm3` bindings показывают направления интеграции. Их `NOT_RUN` нельзя заменять заявлением о готовом listener, TLS или event loop.

## 9. Практическая последовательность реализации

1. Зафиксировать snapshot и воспроизводимую исходную сборку; выбрать действительно исполняемый профиль LMX skeletons. Это отдельный gate от статической корректности новых документов.
2. Подключить source bytes, diagnostics и ordinary call seams к существующему runtime; завершать общий parser/grouper согласно принятому тензорному плану. Не поддерживать серверный обходной синтаксис до готовности общего кода.
3. Сначала local interpreted dispatcher и небольшой service body: read/inspect profile, invoke, insert, owner-side handler replacement. Проверить old-call lifetime, новый handler для последующих selections и отсутствие автоматического compile/native clearing.
4. Довести общий kernel `toLmx` до полного договора для любой Structure/L3Thread; сервер не вводит альтернативный serializer. Проверить shared links, unnamed cycles, null slots, типы/requirements, parent/name и written receiver provenance. Простой успешный build этого не доказывает.
5. Добавить framed native text transport и MCP boundary на той же service implementation. Frame length не должен требовать от транспорта самостоятельного поиска закрывающих LMX скобок.
6. Подключить provider adapter и минимальный self-hosted цикл. Проверить complete answer, truncated answer, preparation failure до placement, error после начавшихся effects, timeout, late answer и lost outcome без повторного side effect.
7. Подключить полноценный asynchronous owner/mail loop, выбранные cooperative cancellation points и operation lifecycle. Проверить остановку отдельно от timeout ожидания и от process watchdog.
8. HTTP/TLS/streaming, большая пагинация, multi-session rights и optional native compilation проходят отдельные gates; каталожные binding files не засчитываются за интеграционные тесты.

Ключевые критерии приёмки уже перечислены в **S:3840–3853**. Документация и skeletons могут быть завершены раньше готового исполняемого сервера, но должны явно отражать этот статус и именовать конкретные ещё не подключённые host seams.

## 10. Проверка typed call slots, owner, node и private в LMX-заготовках

Этот дополнительный список предназначен для проверки настоящих исходников серверного пакета, а не для создания новых правил языка.

**Выбранный C и его DATA.** Обычный `C()`/`call(C)` исполняет C самого; приёмник не ищет внутри него поле `code` или `apply`. DATA — настоящий `parent(C)`, return description принадлежит этому DATA. Поэтому ссылка на `Handler\apply` и ссылка на `Handler` — разные вызываемые объекты; передача первой в dispatcher не перепривязывает её DATA или lexical node к dispatcher (**S:1651–1697,3154**). Нельзя использовать обёртку “любой объект с полем apply автоматически callable” как новую семантику runtime.

**Позиции actuals.** Input declarations DATA принимаются по обычной карте. Private и другие receiver wrappers не удаляют declaration из интерфейса, а physical fields и формальные позиции не всегда имеют один номер. В source `lmx_graph_formal_width`/`formal_place` (`lmx_graph_run.lm2:1201–1235`) учитывают declarations в written order и marked occurrences; `work_open_parts:1463–1541` специально различает input ordinal, physical slot и formal position. `invoke_data_value:5698–5733` использует полученную `bindings[]`, не сжимает sparse named actuals и не заменяет отсутствующие values нулём. Для крупных service DATA с state/dependencies безопаснее и яснее использовать именованные actuals, связываемые общей логикой; сервер не должен сам строить позиционные ABI-векторы по JSON field order.

**Typed values и происхождение.** `lmx_call_prim_values_origins:623–672` передаёт typed input Values, result context, origins и private flags в общую native/walker activation. `lmx_activation_bind_origin:464–497` привязывает настоящее origin и читает private metadata декларации. Передача одного raw pointer вместо этого контекста может потерять declared width, initialization/absence, binding origin или допустимую область жизни. Привязка runtime-service boundary обязана использовать типизированный общий путь, а не самостоятельно выводить тип из адреса/пула.

**Где действительно изменяется состояние.** Bare `x := value` меняет выбранное логическое место вызова; когда это own place, при return нет write-back. `node\x := value` либо путь от явной ref на owner обращается к настоящему graph field. Caller-place binding имеет свои правила и может менять место caller немедленно; его нельзя незаметно заменить copy-back. Поэтому замену persistent handler/state надо показывать через явный graph PLACE у настоящего owner. `node` является lexical operation выбранного occurrence, а не “последним сервисом, который нашёл эту ссылку”, и не Thread supervision parent (**S:2555–2583,3154,3328–3355**).

**Private не является секретностью.** **S:2361–2372**: `private:` запрещает implicit dynamic participation в обе стороны. Marked source не снабжает caller place/value; реально видимый marked receiver не подменяется динамическим одноимённым источником и не autofill-ится. Explicit actual и explicit lexical path остаются разрешены. Private не является access boundary и не скрывает поле от inspect/export. Written wrapper не выпрямляется: если поле записано как `private: @: host ...`, явный путь включает `private` — например `S\private\host`, а не `S\host`. Это видно и в source `lmx_graph_lexical_private:2935–2943`, где проверяется реально выбранная lexical declaration.

Service-local dependencies и скрываемые от implicit binding промежуточные значения уместно помечать private, сохраняя разрешённые explicit actuals. Секрет провайдера защищается отдельным opaque provider capability и разрешённой областью осмотра, а не private marker. Один `private` на далёком одноимённом предке не запрещает новую внутреннюю unmarked declaration.

**Default и computed field.** Call entry не исполняет все omitted initializers. Явный путь к computed declaration возвращает её исходную запись, а не вычисленное значение; bare имя получает activation-local value по обычному demand. Поэтому код, который читает `State\handler`, должен хранить там уже готовую reference, если ему требуется вызвать именно её. Запись вида `@: handler makeHandler()` и explicit path к ней имеют другое значение; нельзя тайно вычислить initializer в серверном graph inspector (**S:2555–2583**).

**Result lifetime.** Возврат ordinary ref не захватывает local activation. Если model request/answer или operation result живёт после turn, он должен существовать в допустимой arena/owner relationship и быть удержан обычными roots/references. Сохранение адреса временного typed slot в таблицу операций или transport handle не делает его допустимым. Copy подготовленного component должен переносить нужные связи и node map, а не получать новый lexical recipient только из-за места присваивания.
