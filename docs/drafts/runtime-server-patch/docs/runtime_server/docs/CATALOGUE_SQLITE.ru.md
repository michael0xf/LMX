# Каталог LMX графа: SQLite projection при компиляции

Версия проекта: 0.1. Дата: 2026-11-27.

**Каталог помогает найти и объяснить существующий граф. Сам граф, его исполнение и актуальная сериализация остаются в LMX runtime.** При компиляции формируется явный снимок фактов; на границе владельца `endturn` он публикуется в SQLite одной транзакцией. Каталог не становится вторым runtime, новым деревом программы или системой глобальных идентификаторов объектов.

## 1. Что считать источником истины

Целевой договор ядра универсален:

- `sys\fromLmx(text)` даёт чистый граф, пригодный для последующей компиляции.
- `sys\toLmx(S)` выдаёт LMX-код любой Structure и любого L3Thread из текущего графа.
- Сервер и catalogue provider используют эти обычные ядровые receivers. Собственные AST, parser или serializer для каталога не вводятся.

Если требуется **актуальный код**, ответ строится через `sys\toLmx` над реальной ссылкой в выбранной области. Текст на диске — дополнительное происхождение: он может отсутствовать, отставать после runtime edits или соответствовать другой компиляции. SQL `payload_lmx` — сохранённый вывод ядрового `toLmx` с явно названной основой снимка; его нельзя выдавать за текущий граф без новой проверки.

В переданном source snapshot diagnostic `lmx_graph_dump` не доказывает готовность полного универсального codec; это задача интеграции, **не ограничение целевого API**. В частности, диагностическое сокращение цикла до `...` не считается полным `toLmx`. Приложенные SQL fixtures помечены `kernel_toLmx_capture: NOT_RUN`.

## 2. Какие виды каталогизации полезны

Приоритет определяется вопросом, который разработчик или модель действительно задаёт перед действием.

| Вопрос | Что каталогизировать | Полезный результат |
|---|---|---|
| «Где определено это имя?» | Имена, типы, определения, scope, упорядоченные вхождения | Все совпадения с контекстом; без выбора первого дубликата |
| «Что это за объект?» | Тип/TypeRef, роль в конкретном контексте, реальные поля | Структура и текущий `toLmx` через runtime |
| «Как вызвать?» | Параметры, порядок, роли, defaults, результат, написанные throws | Подсказка вызова с точной полнотой и provenance |
| «Кто использует эту часть?» | uses/reads/writes/calls/depends, evidence | Callers/callees и известные зависимые части |
| «Что проверить после изменения?» | Обратные зависимости и написанные связи с tests | Набор связанных тестов с отдельным статусом выполнения |
| «Что уже экспортируется native?» | Module artifact, entry symbol, ABI, состояние binding | Поиск экспортов без хранения RAM-адресов |
| «Где объяснение или пример?» | Documentation, examples, evidence, secondary source URI/span | Контекст для ответа модели и проверяемая причина вывода |
| «Чего анализ не знает?» | Dynamic targets, недоступные spans, coverage | Явный список неизвестного вместо ложного доказательства отсутствия |

Структурный inventory и статический анализ имеют разную полноту. Полный обход графа возможен без полного знания динамических целей вызова. Набор вспомогательных проверок READ/WRITE в текущем frontend нельзя автоматически объявлять исчерпывающим effect analysis.

## 3. Одна таблица на владельца

Базовый вариант — **один active snapshot, одна основная facts-table на L3Thread owner**. Достаточно одной схемы с общими индексируемыми колонками и LMX payload; отдельные таблицы для каждого вида заметок не нужны.

Исполняемая схема: [catalogue.sql](../schema/catalogue.sql). В примере таблица называется `lmx_catalogue`. Если несколько владельцев используют один database file, provider заранее назначает доверенные table/index namespaces и привязывает их к настоящим owner refs. Имя таблицы не приходит из пользовательской программы; SQL parameters используются для значений. Идентификатор SQL-таблицы не заменяет ссылку LMX. [SQLite binding API](https://www.sqlite.org/c3ref/bind_blob.html)

SQLite поддерживает только одного writer на database file одновременно; отдельная таблица на поток сама по себе не создаёт параллельных writers. Разделение databases — возможная поздняя настройка deployment, не требование первого варианта. [Transactions](https://www.sqlite.org/lang_transaction.html)

| Колонка | Назначение |
|---|---|
| record_key | Ключ записи только внутри текущего owner snapshot |
| record_kind | snapshot/node/field/relation/attribute/text/coverage |
| subject_key | Локальный ключ сущности, о которой сообщается факт |
| predicate | Вид связи или атрибута |
| object_key | Локальная цель связи; NULL для unknown target или явно отмеченного null slot |
| ordinal | Позиция поля, параметра или элемента описанного binding |
| name | Точное написание, пригодное для поиска; BINARY comparison |
| type_name | Удобная поисковая проекция типа, не замена полному TypeRef |
| value_text | Короткое индексируемое значение/объяснение |
| evidence | Как установлен факт |
| evidence_key | Ссылка на запись evidence внутри этого же snapshot |
| payload_lmx | Полный соответствующий фрагмент/снимок в LMX, полученный от ядра |

В таблице `STRICT` проверяет базовые SQL-типы, а `CHECK` и частичные индексы — локальные инварианты. Требуется SQLite **3.37.0 или новее**. Это не проверка типов LMX: их понимает ядро. [STRICT tables](https://www.sqlite.org/stricttables.html), [CREATE TABLE](https://www.sqlite.org/lang_createtable.html), [partial indexes](https://www.sqlite.org/partialindex.html)

Значения LMX не преобразуются произвольно в SQL INTEGER/REAL/JSON. Числовая точность, modifiers, uninit, вложенность, общие ссылки и циклы сохраняются ядровым LMX payload и отдельными структурными фактами. Поисковые колонки не объявляются достаточным форматом восстановления графа.

## 4. Точные правила проекции графа

### Узлы, поля и связи

`node` представляет одну реальную сущность обхода. Два равных значения в разных местах не сливаются по имени или содержимому. Обход использует реальные типизированные ссылки и visited set; SQL получает только локальные ключи, без адресов памяти.

`field` представляет **каждое вхождение** в физически упорядоченном наборе. Уникальна пара `(subject_key, ordinal)`, но не имя и не target. Поэтому допустимы и сохраняются:

- несколько полей с одинаковым именем;
- несколько вхождений, указывающих на одну сущность;
- анонимные/позиционные значения;
- физический null slot без искусственного узла значения;
- цикл ссылок.

У настоящего null slot сохраняется field row с ordinal, `object_key=NULL` и обязательным discriminator `value_text='null-slot'`. Это отличается от `uninit:T` и типизированного null reference: у них есть собственная typed value record, поэтому field ссылается на обычную node row. В ordered-fields query используется LEFT JOIN, чтобы null slot не исчезал из результата.

`realparent` записывается отдельной relation по данным ядра. Его нельзя вывести выбором первого входящего field: shared target может быть виден из нескольких мест. Явные Link/reference records и их `link_target` отражаются такими, какие они есть в графе. Нельзя приписать другому вхождению новое alias-имя, перезаписав имя общей цели; aliases требуют соответствующих разных source occurrence/reference records.

`type_name` помогает найти, например, `int`. Полное различие TypeRef, modifiers и declaration form берётся из графа/LMX. Body DATA/CODE role относится к определённому контексту использования; каталог сохраняет этот контекст в evidence/payload, а не делает роль универсальным свойством всех обращений к объекту.

### Scope и полнота

«Полный граф» означает объявленную область выбранного owner. Внутри неё перечисляются все доступные элементы и связи без скрытого depth-limit. Для ссылок за границу владельца нужны явные boundary descriptions, scope и coverage; они не должны выглядеть как полностью исследованные объекты другого потока. Ограничение доступа или неподдержанный тип отражается как partial/unavailable с причиной.

Минимальные coverage facets:

| Facet | Что именно покрывается |
|---|---|
| graph-topology | Полнота объявленной owner-области, полей и связей |
| runtime-lmx | Полный сохранённый вывод универсального `toLmx` той же основы |
| call-targets | Полнота разрешения целей вызовов |
| effects | Полнота uses/reads/writes/dependencies |
| disk-source | Наличие вторичного provenance к файлам/spans |
| tests | Полнота каталога связей/сведений о tests; не «все тесты прошли» |

Значения: complete, partial, unavailable, not-applicable. Нельзя ставить `runtime-lmx=complete`, не сохранив полный payload той же основы. SQL gate проверяет наличие payload; соответствие графу и семантическую полноту подтверждает provider через ядровой codec.

## 5. Evidence: факт, декларация и неизвестное

| Evidence | Значение |
|---|---|
| graph-observed | Непосредственно прочитано из графа указанной основы |
| written | Связь/сигнатура/throws/test записаны автором; выполнение не доказывается |
| resolved-for-this-compilation | Точное разрешение в данной компиляции и её контексте |
| runtime-observed | Наблюдалось в конкретном запуске; это не полный набор возможных случаев |
| dynamic-unresolved | Цель/эффект зависит от runtime, полного разрешения нет |
| not-analysed | Соответствующий анализ не выполнялся |

Для `resolved-for-this-compilation` обязательна evidence record: collector/version, compile token, контекст и причина вывода. В SQL unknown call имеет `object_key=NULL`, а выражение цели и объяснение остаются в name/value_text/payload. Отсутствие найденной связи не является доказательством отсутствия эффекта.

Пример различия: `throws E` — написанное обещание/объявление, не доказательство исчерпывающего множества исключений. `tested_by` — связь с тестом, не статус passed. `private` не превращается в access-control policy каталога; чтение разрешает общая admission policy выбранной области.

## 6. Basis: компиляция и граф после tests

Snapshot metadata — обычные записи таблицы, а не скрытое состояние runtime:

- `@snapshot.value_text` — локальный publication token;
- `basis` — compile-input либо post-tests-current;
- `compile-token` — происхождение анализа;
- `graph-root-key` — локальная точка входа inventory;
- `published-at` — время SQL-публикации, не время появления всех значений графа.

**Первый вариант использует `basis=compile-input`.** Collector фиксирует граф и разрешения, использованные компиляцией. Interpreted tests могут затем изменить runtime; публикация на endturn не делает сохранённый compile-input автоматически равным текущему графу.

Если требуется отдельный `post-tests-current` snapshot, он явно собирается после tests. Старые compile-input semantic facts нельзя переносить туда как доказанные без повторного разрешения для новой основы. Можно честно опубликовать полную topology/toLmx и `effects=unavailable`, если соответствующий повторный анализ отсутствует.

При запросе актуального кода вызывается `sys\toLmx` текущей Structure/L3Thread. При запросе каталога возвращаются его basis, publication token и coverage. Модель видит, о каком состоянии идёт речь, и не пытается исправить живой граф по «вчерашнему» locator.

## 7. Capture и публикация на endturn

1. Общий compiler/graph walk собирает facts, пользуясь существующим разрешением имён и ролей. Второй parser или AST не создаётся.
2. Формируется immutable candidate для данного owner и basis. Полный LMX payload выдаёт ядровой `toLmx`. Compile errors не публикуют новый successful snapshot.
3. На успешной owner boundary подготовленный candidate передаётся catalogue provider **до необратимого перехода управления в `endturn`**. `endturn` не возвращается; код «после endturn» не является рабочим hook.
4. Provider открывает `BEGIN IMMEDIATE`, заменяет active rows, вставляет candidate, запускает publication gate и делает `COMMIT`.
5. При SQL ошибке или ненулевом gate — `ROLLBACK`; прежний каталог остаётся доступен. Ошибка публикации — отдельная обычная диагностика; candidate может быть сохранён для явного retry. Успех native/runtime не подменяется успехом SQL.

Исполняемый образец полной замены — [sample_publication.sql](../fixtures/catalogue/sample_publication.sql). В production вставляются prepared values, не SQL-текст, собранный из LMX программы. Временный candidate может оставаться в памяти provider; staging tables обязательными не являются.

SQLite atomicity относится к **своей транзакции**. Она не делает изменение runtime, native installation, внешний I/O и SQL commit общей атомарной операцией. `BEGIN IMMEDIATE` может вернуть SQLITE_BUSY; provider либо выполняет ограниченную согласованную политику ожидания, либо возвращает ошибку без выдачи нового каталога. [Transactions](https://www.sqlite.org/lang_transaction.html), [Atomic commit](https://www.sqlite.org/atomiccommit.html)

Читатели используют отдельные соединения, обычную изоляцию и при нескольких связанных SELECT — одну read transaction. Тогда они видят один committed SQL snapshot. Shared-cache dirty reads не включаются. [SQLite isolation](https://www.sqlite.org/isolation.html)

Этот проект не добавляет автоматические watchers, native invalidation или перестройку после каждой записи графа. Публикация — конкретная операция owner boundary; последующие изменения выявляются явной проверкой/новой компиляцией/новым snapshot по выбранному workflow. История выключена по умолчанию; позднее её можно добавить как отдельный explicit archive profile, не раздувая active table.

## 8. Именованные запросы API

Все SQL-файлы ниже исполняются в SQLite с bind parameters. Query names стабильны для provider API. Параметры `*_key` выбирают запись **данного catalogue snapshot**; они не запускают команды над runtime.

Для запроса по ключу provider обязательно получает `expected publication`, начинает одну read transaction, сверяет token и проверяет наличие ключа, затем выполняет query в том же snapshot. Готовый SQL gate: [14_admit_key.sql](../fixtures/catalogue/queries/14_admit_key.sql). Несовпадение даёт `catalogue-stale`, неизвестный ключ — `catalogue-key-not-found`; отсутствующий expected token — `catalogue-snapshot-required`. Повторно использованный key нового snapshot не может молча означать старый объект. Первый search без item key выбирает текущий snapshot; continuation/cursor уже привязан к его publication и исходным фильтрам. Каждый ответ содержит actual publication, basis и coverage.

| Query | Parameters | Результат |
|---|---|---|
| publication | — | Snapshot metadata и coverage |
| name | name | Все точные совпадения, тип и snapshot |
| type | type_name | Сущности поисковой проекции типа |
| callers | callee_key | Все известные callers с evidence, включая observed |
| callees | caller_key | Разрешённые и динамически неизвестные call sites |
| impact | changed_key | Обратная достижимость по разрешённым dependencies |
| native_exports | — | Module, entry, ABI, binding status |
| related_tests | changed_key | Связанные с affected набором tests и execution status |
| documentation | term | Простой поиск по тексту документации |
| ordered_fields | owner_key | Все вхождения по ordinal, включая дубликаты/shared targets |
| signatures | callable_key | Параметры/defaults/returns/throws/контекст роли |
| unresolved | — | Неизвестные/неанализированные факты с причинами |
| graph_cycle | start_key | Есть ли возврат к start по forward field/link edges |

Код запросов: [queries](../fixtures/catalogue/README.md). `validate` — отдельный внутренний gate, не пользовательская команда; до COMMIT он должен вернуть ноль строк.

Текущая LMX заготовка объединяет эти операции в `search`, `describe`, `callers`, `dependencies`, `status`. Таблица выше — внутренний набор SQL запросов provider, не обещание отдельного публичного receiver для каждой строки. `dependencies` читает исходящие отношения; `impact` выполняет обратный обход и не должен незаметно подменять смысл dependencies.

### Пример: кто вызывает функцию

Полная версия находится в [04_callers.sql](../fixtures/catalogue/queries/04_callers.sql). Принцип — вернуть evidence, а не только имя:

```sql
SELECT caller.name, r.evidence, r.evidence_key
FROM lmx_catalogue AS r
JOIN lmx_catalogue AS caller ON caller.record_key = r.subject_key
WHERE r.record_kind = 'relation'
  AND r.predicate = 'calls'
  AND r.object_key = :callee_key
ORDER BY r.evidence, caller.name;
```

### Пример: что может затронуть изменение

[06_impact.sql](../fixtures/catalogue/queries/06_impact.sql) идёт по обратным calls/reads/writes/uses/uses_type/depends только с evidence `resolved-for-this-compilation`. Recursive CTE хранит множество одного node key и использует `UNION`, поэтому циклы не создают бесконечное добавление одинаковых узлов. Добавление depth/path в ту же строку без отдельной защиты изменило бы это свойство. [Recursive graph queries](https://www.sqlite.org/lang_with.html)

Результат означает возможное влияние по известным отношениям, не доказанную поломку. Запрос также выдаёт snapshot, effects coverage и число unresolved relations. В fixture взаимная рекурсия total↔reduce завершается, а dynamic call остаётся отдельно видимым.

### От поиска к действию

Результат SQL может подсказать имя, scope, occurrence и ожидаемую форму. Для следующего действия runtime получает настоящую типизированную owner/scope reference и разрешает текущую цель обычным путём. Если locator неоднозначен или относится к другой основе, требуется явное повторное разрешение. Строки `record_key`, publication token и native entry metadata не являются адресами команд и не открывают глобальный lookup объектов.

## 9. Native, docs, source и tests

Для native bindings сохраняются module artifact identity, entry symbol, ABI description и состояние binding. Ordinal связывает несколько атрибутов одного экспорта. Текущий RAM address, функция по адресу или указатель поля не попадают в публичный SQL контракт. Это позволяет отвечать «какой код поставляет данный export?» без привязки снимка к одному размещению процесса.

Document/test/source/evidence остаются связаны с теми же graph entities. Source URI и spans nullable: runtime edits нормально существуют без файла и координат. Disk text не перепарсивается, чтобы незаметно заменить живой граф. Tests исполняются только обычным runtime workflow; сбор каталога сам их не запускает и не переводит declared association в passed.

## 10. Полнотекстовый поиск — optional

Базовый вариант использует индексы имён/типов и `instr` для небольших текстов. FTS5 полезен для документации, описаний API, examples и diagnostics, когда каталог вырастет. Он не нужен для точной идентичности имени LMX.

Исполняемый optional пример: [optional_fts5.sql](../fixtures/catalogue/optional_fts5.sql). Он создаёт отдельную FTS virtual table и служебные shadow tables SQLite; поэтому **не входит в вариант с одной основной таблицей**. Используется unicode61 без удаления диакритики; English Porter stemming для русскоязычной документации не включается. Query string параметризуется, а интерпретация FTS operators оговаривается API. [FTS5](https://www.sqlite.org/fts5.html)

FTS перестраивается явно вместе с publication, без triggers/watchers. В production DELETE/INSERT FTS выполняются внутри той же SQL-транзакции замены facts; демонстрационный файл отдельно индексирует уже загруженный sample. Провайдер не объявляет FTS-ready, пока module не доступен и индекс не соответствует active publication. Host availability не доказывает наличие LMX FTS provider.

## 11. Что исполнено и что ещё требуется

На host SQLite **3.53.1** реально выполнены:

- схема с одной main table и 76 synthetic facts;
- 21 query cases: имена, типы, calls, impact с циклом, exports, tests, ordered duplicate/null fields, signatures, unknown targets, graph cycle и publication admission;
- 10 негативных проверок constraints/provider gate;
- проверка, что reader до commit видит прежний snapshot, после commit — новый;
- rollback неполного candidate с сохранением предыдущей публикации;
- отклонение старого publication token после замены snapshot;
- optional FTS5 query по русскому тексту;
- `PRAGMA integrity_check` с результатом `ok`.

Доказательство выполнения: [validation_receipt.json](../fixtures/catalogue/validation_receipt.json), результаты: [query_results.json](../fixtures/catalogue/query_results.json). Готовая демонстрационная БД: [sample.sqlite3](../fixtures/catalogue/sample.sqlite3).

Все facts примера синтетические; evidence labels проверяют выборки SQL, а не изображают реальную компиляцию. Для native указано not-linked, для tests — not-run; универсальный codec и endturn hook здесь **NOT_RUN / integration required**.

| Часть | Статус этого пакета |
|---|---|
| DDL, индексы и concrete SQL queries | HOST_SQL_VALIDATED |
| SQLite publication rollback/isolation | HOST_SQL_VALIDATED |
| FTS5 example | HOST_SQL_VALIDATED, optional |
| Полный owner graph collector в compiler | Требуется интеграция общего обхода |
| Универсальные kernel fromLmx/toLmx | Нормативный контракт; provider seam требуется подключить |
| Publish перед nonreturning endturn | Требуется owner boundary hook |
| Exhaustive effects/dynamic targets | Не обещаются без реального анализа |
| Общая atomicity runtime/native/SQL | Не заявляется |

Реализация каталога завершается, когда compiler формирует снимок указанной основы, kernel codec даёт полный payload, endturn boundary вызывает publisher, а runtime API возвращает catalog facts вместе с provenance и актуальный код через `sys\toLmx`.
