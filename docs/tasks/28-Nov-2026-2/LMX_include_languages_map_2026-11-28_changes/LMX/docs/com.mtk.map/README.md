# com.mtk.map — перенос на LMX, DRAFT

Это проект полноценной LMX-версии документной библиотеки `com.mtk.map`. Реализация находится в `src/`, исходный Java сохранён **без изменений** в [java_original](java_original/). Основной документ — позиционный MIX с устойчивыми Cursor, интервалами Tag, атрибутами и Var-якорями. Интервалы могут пересекаться. Физическое дерево страниц может иметь ветви разной глубины; вложенность Tag не определяет форму этого дерева.

**Статус: DRAFT.** В файлах `.lmx` находятся тела обычных LMX-методов, модели DATA и реальные вызовы `post`, `sys\fromLmx`, `sys\toLmx`. Это не свидетельство прохождения компиляции: производственные P0/TYPE, интерпретатор и native runtime для этой версии библиотеки ещё не запускались. Проверки исходного Java и ограниченные статические проверки LMX учитываются раздельно. Точные результаты находятся в `validation/`.

[Проверки и их запуск](validation/README.md) ·
[полная сверка 1323 исходных объявлений](validation/coverage_summary.json) ·
[общее задание и план интеграции](../tasks/INCLUDE_LANGUAGES_MAP_2026-11-28.md).

## Что сохранено и что перенесено

Исторический Java-каталог содержит рабочие алгоритмы, обёртки вокруг общих механизмов и зависимости, которых нет внутри архива. Сохранившийся Java нужен для сверки семантики и дальнейшего выполнения сравнительных тестов. Он не является обязательным runtime новой библиотеки.

Перенос использует композицию и переиспользование LMX: общая модель Item, отдельные Cursor/Tag/Var/Key DATA и общие методы доступа. Java-наследование `Tag extends Cursor`, вложенные `LocalAttr`, `Attr`, `Tail`, `TailA` не копируется в виде альтернативной системы объектов. Публичные перегрузки сведены к общему телу с явными параметрами. Каждый метод исходника включён в машинную карту: [верхний слой](validation/coverage_tags.json), [хранилище](validation/coverage_storage.json). Пояснения к профилям находятся в [PORT_COVERAGE_TAGS.md](PORT_COVERAGE_TAGS.md).

В исходной версии присутствуют синхронизации: в частности, Java `Key` синхронизирует общий словарь, `MapThreads` — доступ к исполнителям; устройство Branch/Leaf проверено отдельно. В LMX эта ответственность реализована через владение состоянием обычным **Message**. `synchronized` в высокоуровневой библиотеке не используется: он предназначен для низкого уровня L2. Message не вводит возможности deadlock.

Один Message владеет всем изменяемым физическим scope, включая связанные документы/bunches. Один запрос исполняется одним последовательным turn, поэтому другие turns не наблюдают промежуточную часть этого запроса. У других Message нет разрешения читать или изменять эти объекты напрямую. Они получают ответы владельца, проекции DATA и сериализованные снимки. Другие независимые scopes могут исполняться параллельно. Этот профиль не обещает параллельных writers над одним Java-подобным shared object.

## Файлы и повторное использование

| Файлы | Ответственность |
|---|---|
| [contracts.lmx](src/contracts.lmx), [collections.lmx](src/collections.lmx) | Общие модели, `MapNil`, ошибка `MapFailure`, массивы, таблицы, числовые индексы, проверенная арифметика размеров. |
| [storage.lmx](src/storage.lmx), [cursor.lmx](src/cursor.lmx), [bytes.lmx](src/bytes.lmx) | Дерево и bunches, страницы разной глубины, устойчивые anchors, изменение данных, журнал, ограниченные дочерние MIX-документы, байты и кодировки. |
| [values.lmx](src/values.lmx), [dictionary.lmx](src/dictionary.lmx) | Item/Key/Link, интернирование по байтовому trie, разрешение значений, словари упоминаний и индексы. |
| [tags.lmx](src/tags.lmx), [scope.lmx](src/scope.lmx), [api.lmx](src/api.lmx) | Интервалы, локальные/интервальные атрибуты, общие профили `get...ByName`/`get...ByLink`, endpoint/Upper views, копирование и вспомогательные операции. |
| [anchors.lmx](src/anchors.lmx) | Один проход Cursor, который связывает независимые Var-якоря в пересекающиеся Tag. |
| [io.lmx](src/io.lmx), [persistence_marks.lmx](src/persistence_marks.lmx) | Канонический LMX-снимок с восстановлением идентичностей Item, Var, Tag и MapSpan; обработчики событий старого reader. |
| [factory.lmx](src/factory.lmx) | Настоящие CODE bindings, операции фабрики, типизированные рецепты, явные поля объектов вместо Java reflection. |
| [bunch_metadata.lmx](src/bunch_metadata.lmx) | Проверка допустимости разрезания документа и перенос metadata с сохранением Cursor identity. |
| [concurrency.lmx](src/concurrency.lmx), [transfer.lmx](src/transfer.lmx) | Владелец документа, журнал/подписчики/ack, `post`, асинхронная загрузка и mirror через snapshots. |
| [p0/README.md](p0/README.md) | Инкрементальная связь P0 ↔ MIX, непосредственные Cursor в P0-узлах, вложенные документы и исходные координаты. |

Для сборки одного исходного графа определения загружаются в следующем порядке: `contracts`, `collections`, `bytes`, `storage`, `cursor`, `values`, `dictionary`, `tags`, `scope`, `anchors`, `persistence_marks`, `api`, `io`, `factory`, `bunch_metadata`, `concurrency`, `transfer`. Это порядок композиции определений в общий контекст, а не новая директива `include` языка. CODE-ссылки разрешаются в этом общем графе. После него можно добавить `p0/` и выбранные `examples/`.

Каждая модель сначала копируется как `(copy(Model))`, затем получает ссылки на действующий документ/владельца. Такое создание не копирует живой документ вместе с шаблоном. `MapNil` — независимая неизменяемая sentinel-ссылка; обычный integer `0` остаётся числом. В переносимых снимках optional-поля имеют отдельные presence bits: адрес sentinel не является wire ABI.

Нормативные основания: [объекты и композиция](../spec/patterns/08_objects_and_composition/README.md), [Message и post](../spec/patterns/06_async_and_messages/README.md), [координация состояния](../spec/patterns/07_state_coordination/README.md), [семантика LMX](../spec/LMX_semantics.en.md). Примеры `selfbuild` использовались для сверки наблюдаемого ядра; правила синтаксиса берутся из актуальных спецификаций.

## Основные API

Все перечисленные операции вызываются на владельце документа. Передача ссылок в обычный локальный вызов внутри этого владельца разрешена.

| Вызов | Результат и договор |
|---|---|
| `MapTree\create(pageCapacity)` | Новый документ. Capacity не задаёт единую глубину всего физического дерева. |
| `MapCursor\create(document; position; bias)` | Устойчивая нулевая по ширине позиция; `bias=0` остаётся перед вставкой, `1` — после неё. |
| `MapCursor\cloneAt(cursor; bias)` | Новый anchor в уже известном leaf/slot без поиска позиции от начала документа. |
| `MapKeys\intern(document; text)` | Один Key для одинаковых байтов имени в данном документе. |
| `MapTag\create(document; key; begin; end; value)` | Tag над интервалом. По умолчанию начало имеет bias0, конец bias1. |
| `MapTag\createAt(...; beginCursor; endCursor)` | То же общее тело с захваченными anchors. Числовые координаты и Cursor обязаны описывать одни позиции; это внутренний договор P0-производителя. Внешний API редактирования сначала проверяет координаты. |
| `MapTag\setAttribute(tag; key; value; local)` | Локальный атрибут или атрибут, действующий на интервале Tag. Значение с именем самого Tag относится к этому Tag. |
| `MapItem\setValue(item; value; valueKind)` | `0` — обычное DATA/record, `1` — Link, `2` — ссылка на Item. Явная классификация убирает Java `instanceof`. |
| `MapItem\terminal` / `value` / `integer` / `string` | Общий алгоритм разрешения Item/Link. Цикл проверяется по активному пути; повторное независимое использование объекта допустимо. |
| `MapQuery\range(...; relation)` | `0` — полностью внутри, `1` — начало в полуинтервале, `2` — пересечение, `3` — активность в позиции. |
| `MapTag\remove` / `clearBody` / `wholeDelete` | Удалить аннотацию; очистить тело; удалить тело и аннотацию. Различие сохранено. |
| `MapTag\cloneTo(tag; document; position)` | Общий snapshot/import копирует текст, атрибуты, Var и child scopes. Внутренние Item refs перепривязываются; в том же документе ссылки вне фрагмента сохраняются через локальную ID-таблицу. |
| `MapSpan\create` / `createAt` | Отдельный ограниченный MIX-документ с собственным ID/local root поверх общего backing, без копирования текста. |

Для P0 обычный source span использует начало с bias1 и конец с bias0: вставка ровно на внешней границе не попадает внутрь прежнего узла. Нулевой интервал первоначально использует один anchor. Если удаление схлопнуло существующую пару anchors, **после erase и до insert** вызывается `MapTag\normalize(document)`. Он сохраняет обе Cursor identity и выравнивает bias совпавшей пары. `MapTag\resize` возвращает заданные для ненулевого интервала biases. В `MapOwnerApply` этот порядок уже реализован. У root/source-wide границ может быть свой выбранный профиль.

### Профиль исходника P0

При `document.p0Source=1` новый source cell допускается общим `MapStorage\admitValues`: это проверенная и заново материализованная byte value, а не чужая mutable ссылка. `MapOwnerApply` использует этот же путь staging перед началом изменения. Редактирование исходника проходит через source-splice владельца и уведомление P0.

В этом профиле `MapTag\clearBody/wholeDelete` заранее отказывают и направляют вызывающего к source-splice: прежние P0 bindings должны сохранить свои Cursor до публикации нового результата. Удалять native P0 annotation посредством обычного `MapTag\remove(origin!=2)` также нельзя; её retire/discard выполняет P0 с origin2. У пользовательских семантических Tag и у parser annotations различаются владельцы жизненного цикла.

## Var-якоря и вложенный MIX

P0 сообщает о позиции и содержимом каждого `{...}` и оставляет Var-якорь. Он не обязан вычислять пару. `MapAnchors\create` принимает `role`, `headKey`, `closeKey`, `payload`, `sourceOrdinal`, `scope`, `childDocument` и при наличии захваченный `atCursor`. Роль1 открывает интервал, роль2 закрывает, роль3 представляет самостоятельный вложенный документ. `explicitPairId` допускается для уже подготовленных данных, но не требуется от P0.

`MapAnchors\scan(document; scope)` идёт одним Cursor по выбранному документу, сортирует совпавшие по позиции marks по исходному ordinal и поддерживает общий список активных открытий плюс список по close-value. Правила соответствуют §29:

- `{color:red}`, `{color:green}`, текст, `{end:red}`, `{end:green}` создают **пересекающиеся** интервалы.
- `{end}` закрывает последнее активное открытие этого scope.
- `{end:red}` закрывает последнее открытие с close-value `red`, независимо от имени head: после `{style:red}`, `{color:red}` первым закрывается `color`.
- Незакрытые открытия и лишние закрытия возвращаются отдельными массивами; автоматического закрытия на границе нет.

Child document передаётся как `MapSpan`: это отдельный локальный MIX-контекст внутри ограниченного диапазона parent source. Его marks имеют `scope=child`; внешний сканер их не объединяет со своими. String overlay также изолирован собственным scope. Эти границы задаёт P0, а не алгоритм спаривания Var. Слова `{LMX}`/`{MIX}` в обсуждении обозначают содержимое и документы; обязательные новые буквальные ключевые слова не вводятся.

`rawByteOffset` и `sourceTokenChar` различаются. Последний считает Unicode scalar **исходного токена**, включая открывающую кавычку. Он не равен индексу декодированной строки. Поэтому сохранены наблюдаемые примеры `x:"{a}{b:c}"` →1,4; `x:"a{}b"` →2; один 🙂 считается одним scalar. Отображаемая decoded-позиция требует отдельной source map.

Один проход означает один проход исходного Cursor, а не обещание общей сложности O(n): baseline-коллекции для bucket lookup, coincident marks и interval queries ещё могут выполнять линейный поиск. `createAt` устраняет повторный поиск листа от начала документа для каждого захваченного P0 boundary.

## События, commit и асинхронность

`MapTree\begin/commit` группирует изменения и сохраняет упорядоченный список edits. Каждый edit описан в координатах состояния **непосредственно перед ним**. Поля одного диапазона разрешено использовать только при `hasSingleRange=1`. Из разных систем координат нельзя брать общий min/max.

Origin1 означает пользовательское/source изменение, origin3 — семантические атрибуты. Origin2 предназначен для производных P0/Var annotations: он не увеличивает source revision, не создаёт source notice и не допускает изменение source cells. Вложенный begin сохраняет origin внешнего batch. Это позволяет при начальном чтении одновременно добавлять bytes и P0 annotations одним origin1 batch, а последующую актуализацию metadata выполнять с origin2.

`commit` сохраняет журнал. Публикация выполняется **после commit** через `MapOwnerPublish` и настоящий `post`. Уведомление содержит ID, revision, origin и диапазоны, а не живые Cursor/Tag/P0 pointers. `takeChanges` не удаляет события. При нескольких подписчиках `MapOwnerAcknowledge` удаляет только подтверждённый всеми prefix. Отсутствие подписчиков само по себе журнал не очищает. Подписка со слишком старым `since` требует нового snapshot baseline. Повторная доставка использует сохранённое событие и не повторяет исходное изменение. `MapOwnerSubscribe` регистрирует baseline; для немедленной отправки уже накопленного backlog вызывается `MapOwnerPublish` или `replay`. P0 подписывается на текущей подтверждённой ревизии.

P0 может работать в том же владельце с непосредственными Cursor refs. Отдельный P0 Message получает переносимый snapshot/patch. Различие автономного и общего журнала, а также P0 subscriber описаны в [P0-интеграции](p0/README.md).

Serial turn не является транзакционным rollback. Если отказ случился после начала изменения, новые запросы не получают ложный успех: `MapOwnerApply`/transfer оставляют владельца unhealthy до явного восстановления. Не обещается автоматический откат после OOM. При разрезании bunch сначала проверяются пересекающие границу Tag/MapSpan/Item refs; живое присоединение P0 необходимо предварительно снять/перестроить. Физический cut и metadata migration исполняются одним вызовом владельца, без промежуточного `post`.

## Фабрика, I/O и внешние границы

`MapFactory\bind` хранит настоящую CODE-ссылку. Включены copy, If, add/set/remove, wholeDelete, next/call, групповые clear/remove и исполнение рецептов. `MapRecipeStep` — обычные DATA, описывающие Item, Link, имя или явно переданный CODE. Legacy-последовательности имён/ссылок задаются DATA-полями `names`, `links`, `recipe`; никакой текст не запускается через Java reflection или отдельный eval. `MtkJava` заменён `MapObjectBinding` + `MapFieldBinding(read,write)`: объект и его допустимые поля/typed setters предоставляются явно.

Каноническое сохранение — `sys\toLmx` от `MapSavedDocument` format2; восстановление — основной `sys\fromLmx`, проверка ID/диапазонов/категорий ссылок и общий import. Raw Item, owner, Cursor, native-resource ссылки не пересекают границу. Native payload должен быть переносимым DATA-графом; приложение, хранящее в нём обратную ссылку на owner или внешний ресурс, обязано выбрать собственный codec. Native `p0.source` Tag с `parserNode` на endpoint исключается из snapshot: syntax node, binding, context и cache не являются wire DATA. Настоящие Var и их child MapSpan сохраняются; Var payload обязан быть чистой неисполняемой DATA-проекцией полей. Import восстанавливает bytes/семантические Tag/метки, а P0 создаёт свои производные bindings обычным parse. Сохранённые source offsets не делают прежние P0 cache/checkpoints действительными.

Загрузка и mirror выполняются `MapTransfer\start` → `post source.readSnapshot/exportTag` → `owner.loaded`. Destination Cursor остаётся в `pendingTransfers`; наружу уходят request ID и snapshot text. Ответ допускается только на ожидаемой destination revision. Если она изменилась за время чтения, нужен новый запрос. Завершение получает receipt с ID/revision; mutating source-команда повторно не исполняется.

Следующие границы объявлены явно и не выдаются за готовый код платформы:

| Граница | Что уже написано | Что должен предоставить runtime/application |
|---|---|---|
| Файлы | Snapshot read/write, валидация, import/export, file Message. | `MapFilePort.readText/writeText`. |
| Message lifecycle | Owner template, реестр адресов, post-протоколы, корреляция, acknowledgements. | Запуск настоящего Message существующим runtime. Простое копирование Structure не запускает Message. |
| Legacy XML-like reader | Реальные begin/end/text/finish, suffix rename, property-line conversion. | Отсутствующие в исходном пакете `mtk.util.XParserImpl/DocHandler`, если старый формат нужен. |
| JSON в legacy text | Передача результата decode в Item. | Явно выбранный `decodeJson`; `org.json` в LMX не встраивается. |
| Лог/console | Структурированный текст и настоящий `MapLogBuffer`. | Выбранный I/O sink для console/file. |

Старые Java `printBegin/printEnd` не составляют новый сериализатор: формат сохраняемого документа теперь целиком задаётся LMX. Точное бинарное/текстовое совпадение со старым Java writer не заявлено.

## Проверки и следующий запуск

[storage_cases.lmx](examples/storage_cases.lmx) задаёт случаи разной глубины, capacity1, устойчивых anchors, журнала, origin2, child scope и кодеков. [tag_cases.lmx](examples/tag_cases.lmx) проверяет пересечения, локальные значения, перестройку индекса при rename, правила закрытия Var, изоляцию child scope, snapshot round trip, схлопнувшийся half-open span внешнюю Item-ссылку при clone в том же документе и исключение native P0 cache при сохранении Var/child scopes. [message_case.lmx](examples/message_case.lmx) показывает реальный `post` и загрузку через владельца.

Производственный запуск должен сначала проверить весь общий граф в P0/TYPE, затем выполнить storage/tag cases, затем интеграционные cases с настоящими Message/file/P0 providers. Ограниченный [static_check.py](validation/static_check.py) проверяет имена, первые шаги API-путей, скобки, некоторые правила отступов, локальные ссылки и сохранность исходного Java. Он не заменяет эти этапы.
