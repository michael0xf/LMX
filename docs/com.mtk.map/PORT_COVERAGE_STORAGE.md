# Покрытие переноса: storage, Cursor, collections, bytes

**DRAFT; production LMX: NOT_RUN.** Этот документ объясняет изменения API. Полная таблица по каждому Java-объявлению находится в [validation/coverage_storage.json](validation/coverage_storage.json).

## Как получен список

Использован AST `JavacTask.parse`, а не поиск методом регулярных выражений. Включены конструкторы, интерфейсные объявления, вложенные классы и анонимные `Runnable`. Локальная таблица содержит **591** исходное объявление. Таблица верхнего слоя содержит ещё **732**; пересечение по исходному файлу и строке пустое, объединение содержит **1323** объявления исходного архива.

Каждая строка содержит исходный путь, `retained_source`, класс, Java-сигнатуру, начальную/конечную строку, статус, реальные LMX targets и координаты этих targets. `source` указывает прежнее расположение в архиве; `retained_source` — сохранённый оригинал в `docs/com.mtk.map/java_original/`. [Отдельный список принадлежности](validation/storage_owned_source_lines.json) нужен для автоматического объединения с таблицей верхнего слоя.

Статус **REPLACED_BY_COMMON_LMX** обозначает реальное общее тело или явный data field вместо прежней Java-функции. Это не обещание Java binary compatibility, не отметка parser PASS и не проверка исполнения. Низкий слой не скрывает незаполненные ports под такими статусами. Исторические пустые/недоопределённые интерфейсные операции получили явно названную композицию существующих тел и отдельное пояснение.

## Отображение семейств

| Исходное семейство | LMX | Что сохранено и что изменено |
| --- | --- | --- |
| Branch, Leaf, Bunch | [storage.lmx](src/storage.lmx) | Разная глубина, положительная ёмкость каждой страницы, holes, цепочки отдельных bunches, mixed-radix diagnostic address, вставка и перенос переполнения. Source mutations идут через MapTree; нельзя произвольно менять live `slots` и обходить Cursor/events. |
| Cursor, IPointer | [cursor.lmx](src/cursor.lmx) | Стабильная identity, движение в обе стороны, диапазоны, соседние значения, вставки/удаления, rebasing. Marker-slot заменён якорем нулевой ширины; logical position отделена от physical path. |
| Array, IVector | [collections.lmx](src/collections.lmx), MapVector | Create/reserve, checked get/set, alias-safe copy/insert, range erase, move/swap, first/last/pop, compact. Значения — явные ссылки. `indexOf` сравнивает identity; `indexBy` принимает обычную left/right comparator CODE для сравнения содержимого. |
| LiveVector и Element | Там же, MapLive | Отдельная запись членства `{vector,value,index}`. Удаление отвязывает членство, перестановка и вставка пересчитывают затронутые индексы. `copyFrom` создаёт новые записи членства с общими value-ссылками, поэтому одна запись не принадлежит одновременно двум векторам. |
| IntArray, LongArray | MapVector + MapNumber/MapLong | Полные значения int/i64 в value records, numeric search/remove и ordinary storage. Плотный Java `int[]`/`long[]` ABI не имитируется. Отсутствие — MapNil, а не зарезервированное число. |
| IntEnum, Array.Enumerator, Range/VoidRange | MapIterator | Прямой или snapshot-проход, направление, begin/end/position, reset и dispose. Общий статический Java-пул range buffers устранён; snapshot удерживается явной ссылкой. |
| HashArray, HashLiveVector, UniqueArray/2 | MapIndex | Отсортированные integer codes и параллельные value-ссылки; lower/upper bound, диапазоны коллизий, remove/rekey, явная уникальность code/reference. Hash policy задан вызывающим, без произвольного Java reflection. Для содержимого существуют byte/numeric hash и comparator primitives. |
| UniqueIntArray | MapOrdered | Lower/upper bound, уникальная вставка, диапазонное удаление и замена с переупорядочиванием. |
| HTable, IOTable, IntTable, IntIntTable, UTable, UOITable, U2Table | MapTable | Общие keys/values/values2. Row removal, pop и truncate меняют все столбцы. Сравнение ключей задаётся reference identity, numeric key API либо `keyEquals` CODE. Порядок reference-key таблицы — порядок вставки; code-sorted задачи используют MapIndex. |
| Bytes, IBytes | [bytes.lmx](src/bytes.lmx) | Views, поиск, сравнение, ASCII fold, copy/splice/replace, trim/split, строгий decimal и little-endian integer decode, UTF-8, legacy escaped16, HTML transforms. Все диапазоны ограничены и полуоткрыты. |
| Nodes, Container | MapVector/MapLive + value fields | Явные data carriers и ссылки вместо Java generic subclass/marker interface. |

BaseRoot, Upper, Tag/Attr/Var, Key/KeyDict, Links, значения и фабрики находятся в верхнем слое. Низкий слой предоставляет для них `document.factory`, `document.keys/keyIndex`, `document.tags/entries`, stable IDs и Cursor. Высокоуровневые методы самого Java Cursor по именам/ключам/Links включены в таблицу верхнего слоя, а его physical subset и nested movement callbacks — в этой таблице.

## Существенные новые договоры

**Диапазоны.** Источник, byte views и векторы принимают `[begin,end)`. Java-методы с inclusive last требуют явного `last+1`. Некорректные диапазоны вызывают MapFailure; скрытое усечение аргументов, отрицательные смещения и чтение `arr[amount]` не сохраняются как полезное поведение.

**Источник P0.** `document.p0Source=1` включает общий byte-admission для всех путей вставки/замены. `MapStorage.admitValue(document; value)` возвращает независимый scalar int record, `admitValues(document; values)` предварительно проверяет и копирует весь payload. Type/range failure случается до первой source mutation. Generic MIX (`p0Source=0`) сохраняет свой договор обычных value-ссылок.

**Результат вставки.** `MapVector.push` возвращает вставленный index; `addElement` — результирующий size для Array-совместимого договора. `MapTree.insert` возвращает созданный Cell. Source indices не включают Cursor или Tag как искусственные байты.

**Физические helpers.** Прежние методы Branch, способные принимать произвольный Object, обобщены на typed children, Cell и owner-local операции. Structural `MapStorage` — внутренний слой. Клиент редактирует source через MapTree/MapCursor, чтобы не обходить счётчики, rebasing и журнал. Java monitor callbacks входят в те же общие тела и не образуют дополнительный механизм группировки/синхронизации.

**Идентичность и equality.** Ключи документа канонизируются верхним слоем. Общие коллекции не вызывают несуществующий Java `Object.equals`: для arbitrary content задан отдельный comparator CODE. Такая CODE исполняется владельцем, принимает `left/right`, возвращает int-предикат, не изменяет просматриваемую коллекцию и должна проходить тот же Throws/TYPE admission. `MapTable.create(keyEquals := ...)` сохраняет ссылку на этот код после создания модели.

**Снимки.** Vector copy/snapshot сохраняет value-ссылки; live граф целиком не deep-copy. Между разными Message owners передаётся конкретный snapshot верхнего слоя, а не редактируемый документ с чужими Cursor. MapNil сохраняет identity за счёт const + independent + immutable; см. [аудит](SOURCE_AUDIT.md).

**Исторические Bytes-особенности.** `utf16` — legacy escaped16. `MapBytes.trim(beginOnly := 1)` заменяет trimBegin. `takeWord` различает consumeSeparator для двух старых overloads. Метод IBytes.findOfChars не имел активного тела; profile=3 использует сохранённый в комментарии byte-separator predicate. IBytes.divideNumber не имел реализации: новый явный договор — разделение вида и строгий parseInt выбранного сегмента. `htmlFind` выполняет полную нормализацию выбранного диапазона перед поиском; прежнее поэтапное затирание байтов не сохраняется.

**Разрез и вложенные документы.** Bunch cut требует подготовленный metadata admission при наличии tags/entries. Верхний слой заранее проверяет пересекающиеся границы и перепривязывает ключи/метаданные. Обычный child MapSpan не разрезает физический bunch: он задаёт диапазон в родительском source, отдельные local coordinates и собственный actual P0 root. Перенос Cursor между документами одного scope явно выполняет rehome; иной owner scope отклоняется.

## Исполнение и приёмка

[OriginalMapProbe.java](validation/OriginalMapProbe.java) проверяет **оригинальный Java**, который сохранён для сверки. [Receipt](validation/original_java_probe.json) содержит команду компиляции, hashes и PASS 15 выбранных проверок. Java-файл не является реализацией LMX-переноса.

[storage_cases.lmx](examples/storage_cases.lmx) — настоящие LMX-тела восьми acceptance cases. [storage_cases.json](validation/storage_cases.json) содержит entrypoint, ожидаемый результат 8 и негативные сценарии. Они **не запускались production runtime**. Ограниченный [static_check.py](validation/static_check.py) проверяет текстовые инварианты и ссылки; его PASS не заменяет parser, TYPE admission, гарантии выделения памяти и запуск P0 binding.

Следующий обязательный этап — принять LMX modules в текущем parser/runtime, выполнить перечисленные cases и проверить реальные типы/эффекты native bindings. Операции batching не заявлены как транзакции с rollback; этот предел зафиксирован рядом с кодом и в аудите. Для произвольной абсолютной позиции не заявлено логарифмическое время; потоковый P0 reader использует прямой Cursor-проход и захват границ без повторного поиска префикса.
