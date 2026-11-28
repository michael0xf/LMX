# Покрытие верхнего слоя Java → LMX

Статус: **DRAFT / production LMX NOT_RUN**. Исходный код сохранён в `java_original/`. Машинная [coverage_tags.json](validation/coverage_tags.json) перечисляет каждое method/constructor/interface declaration верхнего слоя с class, Java signature, line/end_line, исходным архивным путём, новым путём к Java и конкретным LMX target. `target_location` указывает файл и строку определения; callable aliases дополнительно указывают общее тело. Объявления получены через JDK `JavacTask.parse()`, включая вложенные и anonymous классы, без необходимости разрешать отсутствующие imports. Воспроизводимый extractor — [MapJavaInventory.java](validation/MapJavaInventory.java); он запускается через `java -m jdk.compiler/com.sun.tools.javac.Main`, затем обычный `java -cp` над сохранённым `java_original`.

Верхний слой: **732 объявления**. Из них 716 сведены к общим LMX-телам/явным DATA-полям, 8 имеют отдельное прямое соответствие, 4 являются настоящими TODO исходного `Tag implements Selector`, 4 требуют отсутствующей внешней зависимости или реального Message lifecycle. Эти числа описывают карту переноса, **не процент выполненных runtime-тестов**. Вместе с 591 объявлением нижнего слоя это 1323 объявления исходного Java-пакета; отдельные константы без методов разобраны ниже.

## Статусы карты

| Статус | Значение |
|---|---|
| `IMPLEMENTED_DRAFT` | Есть реальное LMX-тело выбранной операции; выполнение ещё не подтверждено. |
| `REPLACED_BY_COMMON_LMX` | Перегрузка, интерфейс, getter, наследованный профиль или старый служебный индекс отображён на названный общий алгоритм/поле. Mapping описывает параметры и изменение представления. |
| `SOURCE_TODO` | В Java уже было незавершённое тело. Указан usable LMX-эквивалент, но пустой исходник не приписывается как перенос работающей функции. |
| `EXTERNAL_DEPENDENCY` | Часть исходного поведения зависит от отсутствовавшего XML lexer или от существующего runtime launch API. Рабочие соседние алгоритмы перенесены; граница не скрыта заглушкой. |

`SOURCE_TODO` — четыре метода `Tag.addElement/init/clear/end` вокруг строк179–195. Они не превращены в фиктивный успешно работающий Tag collector: предлагается отдельный настоящий `MapSelectBufferModel` и общий `MapDictionary\visit`.

`EXTERNAL_DEPENDENCY` — `MapReader.getXParserImpl`, `MapThreads.openXmlFile`, `getOrNewThreadByName` и `getFileThread`. `MapReader` умеет принимать события; `MapFileMessage` умеет читать canonical LMX snapshot. Запуск исполнителя должен выполняться самим runtime. Наличие класса-шаблона с названием Message не считается запуском.

## Общие профили доступа

| Семейство исходных методов | Общее отображение |
|---|---|
| `get...ByName` | `MapAccess\resolve(context; name; mode; create)`; Key интернируется внутри документа. |
| `get...ByLink(String/Bytes/Link)` | String/Bytes допускается через `MapLinks\parse`; подготовленный Link передаётся напрямую; затем `MapAccess\resolve(link:=...)`. |
| `getObject` / `getInt` / `getString` / Item / Tag | `MapAccess\project`: projection0 = value, 1 = terminal Item, 2 = его Tag, 3 = int record, 4 = text. При обычном typed call можно сразу вызвать `MapItem\integer/string`. |
| `getOrNew...` | Тот же метод с `create=1`; отсутствующее значение создаёт явно заданный constructor CODE, а не Java Class.newInstance. |
| `...Local...` | mode37 (`%`), поиск в tag.attributes. |
| `...Global...` | mode64 (`@`) в выбранном owner document. |
| `equalsByName` | Resolve, затем `MapAccess\equal`, который использует equality int/text/identity; пользовательский критерий допускается отдельным CODE. |
| `getKeysByName` | Resolve, `MapAccess\keys`: разделить строку по запятым и интернировать имена. |
| `getObject(Class)` | Явный admitted `accept(value)` CODE вместо динамической Java reflection. |
| `fillProperties` | `MapScope\properties`: новая таблица ключей и значений, а не ссылка на чужой Properties object. |

Для старого автоопределения ссылочного текста существует `MapLegacyAssign\assign`: он использует `MapAccess\checkLink` и вызывает общее `MapItem\setValue`. В нативном LMX API `valueKind` задаётся явно; текст, который начинается с `$`, сам по себе не запускает код. Передача Item в качестве значения требует `valueKind=2`. Doubled initial sigil остаётся способом сохранить literal text legacy-профиля.

Эти профили — реальные композиции указанных методов, а не обещание наличия сотен отдельных одноимённых Java overloads в LMX. Все входы нормализуются один раз, далее работает общий алгоритм разрешения.

## Tag, атрибуты и endpoint views

`MapTagModel` переиспользует DATA `MapItemModel` через `copy`. `MapItemModel` хранит `cursor`, `tail`, `tag`, `key`, `value`, `valueKind`, `local`, `deleted`. Tag добавляет `attributes`, biases и optional Var/scope связи. Обычный getter соответствует чтению этих полей. `getBaseRoot` возвращает document; `getDict` — document.keys. Root facade хранит отдельно физический document и семантический root Tag.

- `LocalAttr` — Item kind2/local1 с точечной привязкой; он не становится глобальным interval binding.
- `Attr` — Item kind2/local0 с интервалом Tag.
- `Var` — Item kind3, либо отдельный parser-mark из `MapAnchorModel`, пока MIX-анализатор не назначил ему пару.
- `Value` — Item kind4; value относится к enclosing tag. Raw body cells остаются в MapTree.
- `Tail/TailA` представлены endpoint view (`MapBoundaryModel`) и устойчивым Cursor. Их real/previous binding вычисляется общей interval query, а не хранится как адресный hash cache.

`MapAccess\boundaries` возвращает актуальный порядок границ. `MapAccess\upper/previous` вычисляет активные интервалы одного имени. `addUpper`, `setIndex`, `reverseWithPrev/Next` и Java `Nodes` были механизмом обслуживания изменяемых адресных кэшей. В новом представлении отдельный клиентский вызов для починки кэша не требуется: общие Cursor/Tag операции и registry отражают текущее состояние. Список Upper не является дополнительной иерархией.

`MapBoundaryMove/Step` перемещает выбранный endpoint через `MapTag\resize`, обновляя атрибуты. Смена геометрии сохраняет идентичность Tag; исторический Java `reSize`, который создавал replacement Tag и удалял старый, отображён на этот устойчивый вариант. `clearBody` удаляет вложенные annotations/Vars и bytes; `deleteBody` использует `removeNested=0`. `remove` сохраняет bytes, `wholeDelete` удаляет их.

## KeyDict и коды значений

`mentions` хранит реальные ссылки на Item. Изменение имени/значения удаляет старую запись value cache и обновляет новую. Текущая координата Cursor читается в запросе, поэтому moving address не является hash key. `indexedOn/Off` меняет профиль кэша; корректность запросов не зависит от наличия кэша. `getValues/getFromValues/getLetByValue` используют equality query; Selector посещает готовый snapshot результатов.

Для числовых range queries `MapDictionary\code` задаёт понятный профиль: integer value; hash текстовых bytes; checked owner-local identity ID для других объектов. Это не обещание совпадения с JVM `Object.hashCode`. `codeRange` сортирует по этому коду; `nearestValue` выбирает первый не меньший код или последний меньший. Java object-address hashing не сериализуется. Suffix выдаётся монотонным индексом с tombstones, поэтому удаление не создаёт коллизии повторно выданных номеров.

## Factory, reader, writer и threads

`BaseFactoryImpl` использовал Java reflection и instanceof по смешанному телу документа. В LMX сохранены сами операции, но входами являются обычные явные DATA:

| Действие | LMX-вход/реализация |
|---|---|
| copy | `from`, optional `to`; общий `MapTag\cloneTo`, результат записывается Item reference в управляющее значение. |
| If | `switch`; найти internal branch по полученному имени и вызвать общий calculator. |
| add/set/remove/wholeDelete | `target`, `name`, optional `value`; одно тело `MapFactoryAttribute`. |
| next/call | Разрешить локальное имя/target и вызвать CODE, связанный с Key. |
| removeChildren/clearChildren | `target`, `names` с именами через запятую; выбрать snapshot совпадений и обработать его общим телом. |
| removeAll/clearAll | Те же `names`, диапазон всего текущего документа. |
| clearBody | DATA `links` с подготовленными Link; разрешить targets, затем очистить их тела. |
| run/runByType | Tagged DATA `recipe` или выбранные дочерние Tag; `MapRecipeStep` явно различает Item/Link/name/CODE. |
| mirror/load | `MapTransfer\start`, source snapshot, `post`, callback `owner.loaded`; Cursor хранится только на destination owner. |

`MtkJava` заменён descriptor-таблицей: направление0 присваивает значение из документа объекту через write CODE, направление1 записывает read CODE в документ; `local/create` выбирают профиль. Слепое перечисление Java полей, private-access обход и привязка к Class/Method не переносятся в C-совместимый runtime.

Reader поддерживает реальные обработчики событий и свой property-line adapter. Lexer старого формата отсутствовал в исходном пакете. JSON синтаксис не придумывается заново: результат предоставляет выбранный decodeJson. Writer теперь канонически сериализует LMX snapshot; старые XML-like printBegin/printEnd/indent заменены одним `sys\toLmx` от подготовленного графа. Это сознательная смена формата, а не claim wire compatibility.

`MapThreads` заменён Message ownership и реестром готовых адресов; никакой второй scheduler не создаётся. `getRoot/getIThread/getMtkThread` — owner-local состояние или lookup адреса. Локальный live document не возвращается чужому Message. Исходные Bridge/waitForComplete тела заменены реальными асинхронными request/reply операциями. Java synchronization сохранена в оригиналах для аудита; высокоуровневый LMX использует только Message/post.

## Const и другие объявления без методов

`Const.java` не содержит методов и потому не входит в число1323. Его `ENC="UTF-16LE"`, `ENC2="UTF-8"` не доказывают, что все исходные Bytes являлись стандартным UTF-16. Исторический `utf16` flag использует особое escaped представление, которое `MapBytes` отделяет от standard UTF-8 codecs. Integer `NIL`, float `FNIL`, ERROR/EOF не смешиваются с действительными значениями: отсутствие ссылки выражается `MapNil`, результат поиска — явным индексом/флагом, ошибка — `MapFailure`. Строка `prpver="109"` остаётся историческим атрибутом исходника; новый snapshot имеет format2.

## Ограничение доказательств

Ни method coverage, ни наличие настоящего тела не заменяют выполнение. Статический checker может подтвердить существование target и ограниченные свойства текста. Java probe проверяет сохранённый источник. Следующие gates отдельные: общий P0 parse, TYPE/effect admission, LMX runtime cases, реальные Message providers, P0 incremental integration. В README перечислены конкретные `.lmx` случаи; нельзя помечать их PASS до настоящего запуска.
