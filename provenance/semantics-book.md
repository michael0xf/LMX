@@ scope | Предмет языка и способы исполнения | Language scope and execution modes | 0; 0.0; 0.0.1; 0.0.3; 0.1.1; 1; 1.7
[RU]
R0 — обычный скомпилированный C-метод с локальным указателем на граф R0, в том числе когда программа использует интерпретатор. Он остаётся процедурным входом без DATA и пользовательских фактических аргументов ([корневой вход](#root-entry)). Прочие выбранные исполняемые тела используют подходящую нативную реализацию, когда она доступна; в противном случае скомпилированные методы интерпретатора исполняют эти тела из того же полного графа. Тело, содержащее только заполнения полей, может не иметь собственной отдельной нативной реализации, если это сохраняет его семантику. Интерпретация не удаляет бинарный R0 и не создаёт другого представления программы.

LMX одновременно представляет данные, исполняемые выражения, модели, запросы и сообщения. Исходная запись строит структуры; принимающее выражение задаёт их смысл. Записи, деревья, конфигурации, схемы, таблицы и программные тела используют одну структурную основу. Реестр, сервис, таблица и Mix — семейства данных и принимающих выражений, а не дополнительные уровни языка.

Каждое правило языка универсально в своей объявленной области и единообразно применяется к каждой подходящей конструкции. Имя, тип, написание в исходном тексте, уровень вложенности, путь понижения или удобство реализации не создают неявного исключения. Применяйте действующие требования по их конкретному предмету и редакции, а устаревшую документацию исправляйте непосредственно. Автору передаётся только явное противоречие, сохраняющееся между действующими определяющими требованиями, с конфликтующими положениями и минимальным примером, результаты которого различаются. Обычный вывод из общих правил не является отдельным шлюзом одобрения; транслятор, интерпретатор и runtime не должны придумывать обходные семантики.

L3 сохраняет изменение графа, структурные вызовы, таблицы, сообщения и локальные акторы. Низкоуровневые адресные операции, необработанный доступ к памяти, вызовы сырых машинных интерфейсов и явная низкоуровневая синхронизация относятся к [L2](L2_spec_ru.md). Различие уровней не устанавливает само по себе чистоту вычисления, полномочия пользователя или отдельную систему безопасности.

Действующие исходные профили — `.lm2` для L2 и `.lm3` для L3; L1 — генерируемая промежуточная стадия перед C99. Исторический ввод `.lm1` без обёртки относится к отдельно выбираемому прежнему профилю, а не к обязательному действующему исходному пути. Код L2 пишется под ресивером `L2:`; его запись лежит в графе как записана, и по ней транслятор и интерпретатор узнают уровень кода. Написания `L1` и `L3` сами по себе профиль не выбирают и остаются обычными именами. Файл `.lm2` сам по себе как обёрнут в этот ресивер (решение автора 2026-11-17). `.lm4` и `.lm5` не задают действующих профилей. Файл сам является Structure: его корневое тело — L3-Structure, исполняемая с начала в любом профиле, в том числе в `.lm2`, где это тело — запись `L2:` с содержимым файла; функции `main` нет. L3 компилируется в нативный код, как и L2, и построенный граф обоих уровней может исполняться интерпретатором. Код L2 интерпретатор исполняет с теми же проверками, что и код L3; адресную операцию, которой в L3 нет вообще, он исполняет со своими проверками; нативный код L2 компилируется без этих проверок (решение автора 2026-11-18). Различие уровней этим не исчерпывается: у L3 свои типы данных без внешней адресной арифметики. Доступ к элементу массива проверяется по текущей длине ([индекс](#structure-index)); указатели на Structure и на методы не меняют своё числовое значение произвольно — они присваиваются только друг другу и обнуляются; указатели на данные — обёртки (уточнение автора 2026-11-17). Подходящий вход в таблицах call выбирает нативное исполнение; при его отсутствии тело исполняет интерпретатор. Правило «нативное исполнение только внутри методов» снято. Режимов «интерпретация / нативное исполнение» у потока нет — выбирается зарегистрированный native-вариант конкретного вызова либо обходчик; известный native-вызов понижается прямо в C. Значение исполнения файла (код завершения) — значение последнего вычисленного выражения корневого тела; корень — вход без данных ([R0](#root-entry)), значения не объявляет, и `return` в нём только голый. Профиль сервиса может выбрать явную функцию, `start`, обработчик или отправку сообщения. Точка входа получает управление после подготовки окружения и графа исполнения.

Модель допускает интерпретацию построенного графа и трансляцию с сохранением той же семантики. Интерпретатор исполняет построенный граф, а не исходный текст и не L1. Реализация самого интерпретатора не расширяет язык интерпретируемой программы. L2 задаёт машинные механизмы, L3 — высокоуровневые программы, а L1 служит промежуточной стадией понижения к C99. Парсер, интерпретатор графа и транслятор имеют разные задачи. Грамматические формы, границы тел, литералы, комментарии и нормализация определены в [спецификации грамматики](LMX_grammar.ru.md).

Уровни соотносятся как множества: L3 — подмножество L2. Структурные значения и именованные или анонимные тела используют одну и ту же модель графа. Операции, доступные только в L2 и требующие сырой машинной памяти, произвольной манипуляции адресами или `c.*`, записываются под `L2:`. Ресивер объявления `@` может сохранять ссылку на Structure или метод в L3 без числовой адресной арифметики. Префиксное взятие адреса — отдельная операция по [§9](#method-reference-assignment); её использование и доступ к сырой памяти остаются подчинёнными контракту выбранного уровня. Граф, построенный из любого профиля, может быть передан интерпретатору, который применяет соответствующие проверки.

<a id="program-representation"></a>
### Полный граф и скомпилированные методы

Полная программа — это её граф LMX вместе с бинарным образом скомпилированных методов. Рядом с ним нет рабочего графа, постоянной копии исполнения, расширенного графа-замены, отдельного графа вызываемых, материализованного графа namespace или скрытого хранилища данных программы. Переименование такой копии в кэш, контрольную точку или подготовленное представление не делает её частью этой модели.

Структурные связи исходника и число элементов логически определяют `parent` и `length`. Прочий записанный материал хранится через массив указателей Lmx, включая Structure и примитивные листья в их собственном типизированном представлении. Это не требует удалять физический заголовок `parent/length/storage` или вычислять поля заголовка только по запросу. Таблицы ядра и их данные так же принадлежат графу по их существующему владению; они не являются вторым хранилищем данных программы, встроенным в бинарный образ.

Бинарный образ содержит скомпилированные методы, включая R0 и реализацию интерпретатора. R0 хранит **локальный** указатель на свой граф; постоянный глобальный указатель R0, статическое зеркало данных C или искусственный объект DATA=CODE не добавляются. Значения кадров и регистров времени выполнения, переходные отображения имён и адресов и ссылки на существующие исходные записи являются обычным состоянием исполнения, а не другой версией графа. Namespace описывает эти места и ссылки; он не материализуется как программа-замена. Явно записанные `copy`/`merge` и операции построения, разумеется, могут создавать свои обычные результирующие значения. Они не разрешают скрытую копию исполнения на входе. Это актуальное [уточнение автора](tasks/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

<a id="l3-receiver"></a>
### Принимающее выражение L3

Принимающее выражение L3 задаёт контракт потребления построенного графа как программы L3. Оно определяет поддерживаемое подмножество и точку входа выбранного профиля; наличие синтаксического дерева само по себе не устанавливает допустимость программы. Неподдерживаемая операция не становится допустимой из-за наличия машинного адреса реализации. Ограниченный профиль исполнения должен явно сообщать о неподдерживаемой конструкции, а не молча пропускать её или исполнять как L2. Это ограничение профиля не отменяет [единого механизма допуска кандидатов](#admission).

Обходчик исполняет текущий бинарный граф, а не исходный текст. Голова написанного Frame — примитив-слово: ячейка с указателем на единственную переиспользуемую строку её написания; обходчик узнаёт ресивер, сравнив адрес этой строки с адресом строки слова языка (решения автора 2026-11-08, заменившие коды написания 2026-11-07) — без отдельного opcode в графе, без числовых кодов и без чтения байтов написаний. После распознавания головы операнды и места данных находятся по именам через служебные таблицы текущего обхода и далее по адресам графа; эти таблицы нигде не хранятся вне обхода. Транслятор потребляет тот же построенный граф и разрешает ту же голову при генерации кода; готовому `native` имя при вызове не нужно, см. [имена и пути](#fields). Высокоуровневая операция может иметь явно выбранную машинную реализацию с L3-контрактом, как описано в [границе числовых и машинных операций](#mathematics); это не разрешает произвольный вызов `c.*` из интерпретируемой программы.

Имя головы хранится не внутри Structure как тег: голова — поле Lmx, ссылающееся на примитив-слово с адресом единственной строки написания; обходчик распознаёт по этому адресу ресивер и применяет его контракт к аргументной Structure. Адрес строки написания и есть имя головы, общее для всех её употреблений; служебные операторы и ресиверы (`for`, `=`, `**`, `fn`, `merge`) отдельных кодов не имеют — те же адреса строк (решение автора 2026-11-08). Отдельный числовой код операции не заменяет голову и не является семантическим основанием исполнения; после распознавания остальные связи остаются физическими. Компиляция может пользоваться числовыми кодами как собственными внутренними метками понижения, но они не становятся обязательной частью L3-графа или дополнительным способом определить смысл ресивера.

Имя вызываемой Structure подчиняется тому же правилу, что и любое другое имя: оно привязано во внешнем namespace к адресу существующего поля владельца и не записывается как поле Lmx. При L2-построении результата разрешённый ресивер ставит записи соответствующий код типа; это не создаёт второго графа и не заменяет классификацию написанной головы. Исполняемого `fn` нет: `fn` описывает сигнатуру и вызываемого не создаёт ([сигнатура `fn`](#fn-signature), [что снято](#removed-builtins)); запись, объявленная внутри `data`, остаётся обычной Structure, и данные не классифицируются по названиям своих полей или сходству формы. Аналогично графовый Array остаётся Structure с общей основой `Lmx`, а разновидность и тип элементов задаются кодом типа в его записи значения; диапазоны арены определяют владение, а не тип. После распознавания головы доступ к полям идёт по адресам, без повторного поиска их имён.

Простейшая программа скриптового профиля:

```text
print: "Hello World"
```
[EN]
R0 is an ordinary compiled C method with a local pointer to the R0 graph, including when the program uses the interpreter. It remains a procedural entry without DATA or user actuals ([root entry](#root-entry)). Other selected executable bodies use a suitable native implementation when available; otherwise the compiled interpreter methods execute those bodies from the same complete graph. A body with only field fillings may omit its own separate native implementation when that preserves its semantics. Interpretation does not remove the binary R0 or create another program representation.

LMX represents data, executable expressions, models, queries and messages. Source notation constructs Structures; a receiving expression assigns their meaning. Records, trees, configurations, schemas, tables and program bodies share the same structural basis. Registries, services, tables and Mix are families of data and receivers, not additional language levels.

Every language rule is universal within its declared domain and applies uniformly to every matching construct. A name, type, source spelling, nesting level, lowering path, or implementation convenience creates no implicit exception. Apply the current requirements by their specific subject and revision, and correct superseded documentation directly. Only an explicit contradiction remaining between current governing requirements is referred to the author, with the conflicting provisions and a minimal example whose outcomes differ. Ordinary derivation from the shared rules is not a separate approval gate; translator, interpreter, and runtime must not invent workaround semantics.

L3 retains graph mutation, structural calls, tables, messages and local actors. Low-level address operations, raw memory access, raw machine interfaces and explicit low-level synchronization belong to [L2](L2_spec_en.md). The level distinction does not by itself establish computational purity, user authority or a separate security system.

The current source profiles are `.lm2` for L2 and `.lm3` for L3; L1 is the generated intermediate stage before C99. Historical wrapperless `.lm1` input belongs to a separately selected former profile, not a required current source path. L2 code is written under the receiver `L2:`; its record lies in the graph as written, and by it the translator and the interpreter learn the level of the code. The spellings `L1` and `L3` do not themselves select a profile and remain ordinary names. An `.lm2` file by itself is as if wrapped in this receiver (the author's decision of 2026-11-17). `.lm4` and `.lm5` do not select current profiles. The file is itself a Structure: its root body is an L3 Structure executed from the start in every profile, including `.lm2`, where that body is the record `L2:` with the contents of the file; there is no `main` function. L3 is compiled into native code as L2 is, and a constructed graph of either level may be executed by the interpreter. The interpreter executes L2 code with the same checks as L3 code; an address operation that L3 does not have at all it executes with checks of its own; native L2 code is compiled without these checks (the author's decision of 2026-11-18). That is not the only difference of the levels: L3 has data types of its own, without external address arithmetic. Access to an element of an array is checked against the current length ([index](#structure-index)); pointers to Structures and to methods do not change their numeric value arbitrarily -- they are assigned only to one another and nulled; pointers to data are wrappers (the author's clarification of 2026-11-17). A suitable entry in call tables selects native execution; in its absence the interpreter executes the body. The rule that native execution is enabled only inside methods is withdrawn. A Thread has no "interpreted / native" modes -- the registered native variant for the particular call or the walker is selected; known native calls lower directly to C. The value of executing a file (its exit code) is the value of the root body's last evaluated expression; the root is an entry without data ([R0](#root-entry)), declares no result, and `return` in it is bare only. A service profile may select an explicit function, `start`, a handler or a message send. The entry point receives control after its environment and runtime graph are prepared.

The model supports interpretation of the constructed graph and translation preserving the same semantics. The interpreter executes the constructed graph, not source text and not L1. The interpreter's implementation does not expand the language of the interpreted program. L2 defines machine mechanisms, L3 defines high-level programs, and L1 is an intermediate lowering stage toward C99. The parser, graph interpreter and translator serve different purposes. Grammatical forms, body boundaries, literals, comments and normalization are defined in the [grammar specification](LMX_grammar.en.md).

The levels relate as sets: L3 is a subset of L2. Structural values and named or anonymous bodies use the same graph model. L2-only operations requiring raw machine memory, arbitrary address manipulation or `c.*` are written under `L2:`. The declaration receiver `@` can retain a Structure or method reference in L3 without numeric address arithmetic. Prefix address-taking is a distinct operation under [§9](#method-reference-assignment); its use and raw memory access remain subject to the selected level's contract. A graph built from any profile can be supplied to the interpreter, which applies the appropriate checks.

<a id="program-representation"></a>
### The full graph and compiled methods

The complete program is its LMX graph together with the binary of compiled methods. There is no
working graph, persistent execution copy, expanded replacement graph, separate callable graph,
materialized namespace graph or hidden program-data repository beside it. Renaming such a copy
as a cache, checkpoint or prepared representation does not make it part of this model.

The source's structural relationships and element count logically determine `parent` and `length`.
The other written material is held through the Lmx array of pointers, including Structures and
primitive leaves in their own typed representation. This does not require removing the physical
`parent/length/storage` header or computing header fields only on demand. Kernel tables and their
data likewise belong to the graph under their existing ownership; they are not a second store of
program data embedded in the binary.

The binary contains the compiled methods, including R0 and the interpreter's implementation.
R0 keeps a **local** pointer to its graph; no permanent global R0 pointer, static C data mirror or
artificial DATA=CODE object is added. Runtime frame/register values, transient name/address maps
and references to existing source records are ordinary execution state, not another graph version.
A namespace describes those places and references; it is not materialized as a replacement program.
Explicitly written `copy`/`merge` and construction operations may of course create their ordinary
result values. They do not authorize a hidden execution copy at entry. This is the latest
[author clarification](tasks/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

<a id="l3-receiver"></a>
### L3 receiving expression

The L3 receiving expression defines the contract for consuming a constructed graph as an L3 program. It determines the supported subset and the selected profile's entry point; the mere presence of a syntax tree does not establish program admissibility. An unsupported operation does not become admissible because a machine implementation address exists. A restricted execution profile must explicitly report an unsupported construct rather than silently skip it or execute it as L2. This profile restriction does not replace the [single candidate-admission mechanism](#admission).

The walker executes the current binary graph rather than source text. The head of a written Frame is a word primitive: a cell with the pointer to the single reused string of its spelling; the walker recognizes the receiver by comparing the address of that string with the address of a language word's string (the author's decisions of 2026-11-08, which replaced the spelling codes of 2026-11-07) -- without a separate opcode in the graph, without numeric codes and without reading the bytes of spellings. Once the head is recognized, operands and data places are found by name through the service tables of the current traversal and then by graph addresses; those tables are kept nowhere outside a traversal. The translator consumes the same built graph and resolves the same head when generating code; completed `native` needs no name when invoked, as specified under [names and paths](#fields). A high-level operation may have an explicitly selected machine implementation with an L3 contract, as described at the [numeric/machine-operation boundary](#mathematics); this does not authorize arbitrary `c.*` calls from the interpreted program.

The head's name is not stored inside a Structure as a tag: the head is a field of the Lmx referring to a word primitive with the address of the single string of its spelling; the walker recognizes the receiver by that address and applies its contract to the argument Structure. The address of the spelling's string is the head's name itself, shared by all its uses; service operators and receivers (`for`, `=`, `**`, `fn`, `merge`) have no separate codes -- the same string addresses (the author's decision of 2026-11-08). A separate numeric operation code neither replaces this head nor establishes execution semantics; subsequent links remain physical. Compilation may use numeric codes as its own internal lowering labels, but they are not a required part of the L3 graph or another way to determine a receiver's meaning.

The name of a callable Structure follows the same rule as every other name: the external namespace keys it by the address of an existing owning field, and it is not stored as an Lmx field. When constructing a result in L2, the resolved receiver gives the record the corresponding type code; this creates no second graph and does not replace classification of the written head. There is no executable `fn`: `fn` describes a signature and does not create a callable ([`fn` signature](#fn-signature), [what is withdrawn](#removed-builtins)); a record declared inside `data` remains an ordinary Structure, and data is not classified by its field names or apparent shape. Likewise, a graph Array remains a Structure with the common `Lmx` base, while the type code in its value record determines the Array variant and element type; arena ranges determine ownership, not type. Field access after head recognition uses addresses, without another lookup of field names.

The simplest script-profile program is:

```text
print: "Hello World"
```
@@ values | Значения, структуры и массивы | Values, Structures and Arrays | 2; 2.2.1; 2.2.2.6-7; 3.1-3.3; 12.1
[RU]
Структура — упорядоченная совокупность непосредственных полей. Поля содержат ссылки на значения: примитивные ячейки, другие структуры (в том числе Array) и записи методов. Лексическая вложенность образует лес; дополнительные ссылки соединяют его в граф с общими объектами и циклами. Примитивная ячейка не получает отдельную структуру-обёртку только потому, что на неё ссылается поле.

<a id="header-receivers"></a>
<a id="system-receivers"></a>
### Вспомогательные ресиверы sys

Вспомогательные операции объединяются в группу `sys\` и вызываются обычным путём. Имена её членов не становятся глобальными зарезервированными словами. В группу входят `sys\check(S)` (проверки чистого графа: имена и статически известные требования), `sys\checkL3(S)` (принадлежность тела уровню L3: операции L2 в нём), `sys\translate(S)`, `sys\compile(S)`, `sys\endturn()`, а также `sys\native`, `sys\storage`, `sys\descriptor`, `sys\capacity`, `sys\resize`, `sys\reserve`, `sys\typeof`, `sys\toLmx`, `sys\fromLmx`, `sys\assert`, `sys\indexof`, `sys\name`, `sys\priority` и `sys\eval`. `length` остаётся общедоступным по решению автора; `parent` сохраняется рядом как обычная навигация. Поля заголовка Lmx — parent/length/storage; native и capacity в него не входят.

Проверки возвращают диагностики и используют работающий код сборщика. Они не исполняют проверяемую программу, инициализаторы или пользовательские test. `sys\translate(S)` понижает Structure в **текст L1** и возвращает обычную Structure с полями `l1` и `errors`; при ошибках готового L1 нет. Это не вывод LMX: `sys\toLmx` сериализует текущее состояние графа, `sys\fromLmx` разбирает LMX. Translate не устанавливает native и не исполняет S; необходимые проверки выполняет общим кодом без обязательного отдельного вызова check. Сборщик — первая реализация; нужные части выносятся в runtime для этих конкретных операций, без второго построителя, универсальных обёрток или дополнительных состояний. Это нормативные контракты ресиверов, а не отчёт о доступности runtime.

Компиляция — это вся явно запрошенная цепочка: построение и проверка чистого графа, понижение в L1 и C, машинная компиляция и регистрация получившихся записей. `sys\compile(S)` применяет её к выбранному корню S и возвращает результат и диагностики общим механизмом; при неудаче новый native не устанавливается. Она не запускает точку входа приложения S и не выполняется автоматически при записи. После построения чистого графа отдельная обязательная фаза сборочных тестов может исполнить проверочные выражения и кандидатные вызовы, которые они явно делают, перед окончательной компиляцией C ([фазы тестов](#admission)). Это не проход инициализаторов. `sys\translate` по-прежнему возвращает только L1 и не исполняет ни приложение, ни эти сборочные тесты. [Контракт native и граница хода](#explicit-compilation).

<a id="system-indexof"></a>
#### Индекс поля в родительской структуре

`sys\indexof(field parent)` возвращает физический индекс единственного вхождения `field` среди
непосредственных элементов Structure `parent`. Если поле отсутствует или та же ссылка встречается
несколько раз, операция сообщает ошибку по общим правилам отказа.

`sys\indexof(field index parent)` выбирает вхождение той же ссылки с номером `index`, считая с нуля,
и возвращает его физический индекс в `parent`. Если указанного вхождения нет, это ошибка.
Номер вхождения и возвращаемый индекс — разные величины: при вхождениях одной ссылки в позициях
2 и 5 вызов с `index = 1` возвращает 5. Обе формы получают `parent` явно; формы без аргументов нет.

Искомое поле определяется его идентичностью/ссылкой, а не совпадением имени или примитивного значения.
Поиск не следует вложенным структурам или графовым ссылкам. Для Structure и Array<@> действует один
механизм чтения непосредственных элементов. Использовать существующую адресацию; отдельная таблица
обратных индексов и её обслуживание при записях не нужны.


### Ресиверы parent, length, sys\native, sys\storage

Обычные не объявляющие ресиверы принимают одну Structure S, включая Array, либо работают без аргумента:

| Вызов | Результат | Без аргумента |
| --- | --- | --- |
| `parent(S)` | Структурный родитель S, значение поля заголовка `parent`; 0 у корня | `parent()` — `parent(D)` |
| `sys\native(S)` | Native-дескриптор S из таблиц call, включая варианты сигнатур; 0 при отсутствии; чтение не вызывает его | `sys\native()` — `sys\native(D)` |
| `length(S)` | Число непосредственных полей Structure или элементов Array, значение `length` | `length()` — `length(D)` |
| `sys\storage(S)` | Указатель на хранилище элементов, значение `storage` | `sys\storage()` — `sys\storage(D)` |
| `sys\capacity(S)` | Вместимость в элементах из таблицы арены по адресу S | `sys\capacity()` — `sys\capacity(D)` |

Здесь `D` — DATA текущего вызова, где он существует: для исполняемой `C` это фактический `parent(C)`. Встроенное тело не подменяет DATA другим. `call(A C)` передаёт фактические аргументы A и не заменяет D. У R0 нет сфабрикованного D по умолчанию. Явные аргументы выбирают другие Structure, включая сам выбранный код. Формы ресивера с двоеточием и с круглыми скобками имеют один и тот же контракт; голое имя ничего не вызывает. Зарезервированное лексическое `node` — другая операция и не является запросом parent без аргументов.

В роли `code` ресивер исполняется; в роли `data` одноимённая структурная запись остаётся данными. При одном вхождении `D\parent`, `D\native`, `D\length` и `D\storage` выбирают записанные Structure так же, как `D\for`; повторяющиеся имена требуют обычного индекса вхождения. Пути не получают псевдополей заголовка. Проход namespace DATA интерпретирует корневые объявления и потребляет явно заданные `import`, `copy` и `merge`, если этого требуют их контракты; все три используют стандартные исходные аргументы CODE. Он не исполняет произвольные тела DATA. Код, явно потреблённый ресивером, следует контракту этого ресивера ([правило](#data-root-declaration-execution)).

В физическом заголовке Lmx прежние `size` и `data` переименованы в `length` и `storage`; итоговый порядок — `parent/length/storage`. Native-дескрипторы находятся в таблицах call; вместимость — в таблице арены. `data` и `code` — названия ролей ([роли `data` и `code`](#data-code-roles)); особого имени `data` нет ([имя `data`](#ordinary-var)), а `code` — имя параметра ресивера `call` для исполняемой Structure ([структурный вызов](#call-receivers)). Их смысл не связан с указателем на хранилище. `node` сохраняет действующий контракт зарезервированного контекста активации, неизменного во вложенных телах; ресивер `node(S)` не вводится.

Чтение parent/length/storage обращается к своему полю заголовка напрямую; native/capacity используют свои соответствующие таблицы арены. Эти запросы не строят вспомогательного дескриптора. `sys\descriptor` возвращает адреса настоящих полей для явных записей по [контракту дескриптора L2](L2_spec_ru.md#get-descriptor).

<a id="get-descriptor"></a>
`sys\descriptor(S)` и `sys\descriptor: S` выбирают явно переданную Structure. Без аргумента `sys\descriptor()` и `sys\descriptor:` равнозначны `sys\descriptor(D)` от данных текущего запуска `D` (для исполняемой `C` это `parent(C)`, [структурный вызов](#call-receivers)), в том числе во вложенных телах управления; для code нужен явный аргумент. В data одноимённая запись остаётся обычной Structure. Оба варианта возвращают адреса полей выбранной Structure по одному контракту. Решение автора.

Обычный ресивер `sys\descriptor: S` возвращает Structure d с адресами трёх настоящих полей заголовка S: `parent`, `length`, `storage`, в таком порядке, без вложенного VoidArray. Типы адресов — `Lmx **`, `size_t *`, `void **`. `\(d\length) := n` непосредственно меняет S.length; `d\length := p` меняет лишь указатель в d. Это адреса живых полей, не копия или прокси. Прямая запись length сама не выделяет storage; согласованное изменение размера выполняет `sys\resize`. Дескриптор не продлевает жизнь S и не передаёт владение. Native и capacity не являются его полями; `S\native` выбирает обычное поле, если оно есть. [Контракт L2](L2_spec_ru.md#get-descriptor).

Глубина указателя и ранг Array — независимые произвольные конечные величины; язык не имеет фиксированного предела. Уровень косвенности типизированной ссылки отличен от префикса `@`, который явно получает числовой адрес по адресному контракту выбранного уровня; обычным ссылкам на Structure и методы префикс `@` не нужен. Разыменование следует контракту ссылки или допущенного адреса, не вызывая её цели. Явная запись через `S\field` или типизированное разыменование подчиняется общему требованию к месту, включая ссылки и указатели на функции. Ограничения на присваивание через голое имя Structure или функции и на неявный внешний поиск не запрещают такие явные записи.

Array — такая же Structure графа с собственным структурным `parent`; ресивер `[]` задаёт ей элементы и тип их хранения, а не создаёт другую семью языковых объектов. Массив содержит элементы одного типа. Его длина относится к элементам массива, а число полей содержащей Structure — к её непосредственным полям. Массив ссылок на массивы и прямоугольный многомерный массив — разные значения. Вложенность `a: b: c: d:...` является общей формой применения принимающих выражений и не имеет фиксированного предела глубины. `[]: []:` — применения обычного ресивера Array в этой общей форме, не отдельная конструкция или особый тип «массив массивов». Элемент Array может быть примитивом или ссылкой на непримитивное значение по общим правилам хранения; у каждого самостоятельного массива своя длина. Си-подобная голова `[][][]` задаёт ровный многомерный массив и не относится к композиции отдельных ресиверов `[]:`. Размерность из физического хранения не восстанавливается. Промежуточный массив можно связать с именем обычным типизированным связыванием: для `[]: []: []: a` шаги `[]: []: b a[i]` и `[]: c b[j]` используют по одному индексированию самостоятельного массива, без копирования непримитивного значения. Прямой доступ через несколько массивов использует обычный путь `a[i]\[j]\[k]` ([пути](#fields)), а не соседние индексы ровного массива. Например, `char: []: []: mainArgs` использует ту же общую вложенность для массива строк: каждая строка — самостоятельный массив `char` с точной длиной `len` без завершающего NUL (`LmxCharArray`, [L2 §5](L2_spec_ru.md#method-array)); NUL — форма двери `c.*`, не значения в графе. Детали представления и запись значения — код типа и сразу за ним значение — определены в [L2](L2_spec_ru.md#value-record).

Пустая структура — присутствующее значение с нулём полей. Она отличается от отсутствующего поля, числового нуля и `void`, означающего отсутствие содержимого примитивной ячейки. Список аргументов Frame сам является Structure; анонимная Structure в нём остаётся отдельным значением и тогда, когда она одна занимает весь список: P0 её не раскрывает, пустая она или нет (решение автора 2026-11-10). Поэтому в дереве разбора `f()`, `f:` и явно закрытое пустое вертикальное тело — одно дерево с пустым телом, `f: ()` и `f(())` — одно дерево с одним полем, пустой Structure; `f(a b)` и `f: a b` — одно дерево с двумя полями, `f((a b))` и `f: (a b)` — одно дерево с одним полем-Structure. Сказано это только о дереве; в чистом графе запись лежит так же, как записана. Что запись делает, определяется при трансляции и интерпретации — по роли записи ([роли `data` и `code`](#data-code-roles)) и по виду ресивера ([два вида ресиверов](#two-kinds-of-receivers)). При вызове вызываемого и ресивера, принимающего аргументы как `code`, четыре записи `f: a b`, `f(a b)`, `f: (a b)` и `f((a b))` — один и тот же вызов, когда выбрано чтение E: единственная Structure в аргументах раскрывается в цепочку своих полей, один раз и только при обработке вызова; чтение W принимает её целиком, и оба чтения равноправны ([выбор объявления по вызову](#declaration-selection), [вся структура аргументов](#whole-arguments)). Ресивер, принимающий аргументы как `data`, получает ровно то, что записано; в роли `data` записи тоже не меняются, и ничего не раскрывается: `f: (a b)` объявляет `f`, внутри которой одна анонимная Structure, а `f(a b)` и `f: a b` объявляют Structure с полями `a` и `b` (уточнение автора 2026-11-18). См. [пустое тело](LMX_grammar.ru.md#empty-colon).

`None` — контекстное значение: его представление задаёт ожидаемый тип принимающего выражения. Единого кодирования для всех типов нет; тип без соответствующего определения `None` его не принимает. Число `0` остаётся нулём, в логических операциях — ложью, и не является общим признаком отсутствия. В прежнем профиле `Boolean` использует диапазон −1…1: `None = −1`, ложь — 0, истина — 1. Это конкретное определение профиля, а не универсальное кодирование всех отсутствующих значений.

Текст, изображение, десятичная запись и машинное слово до распознавания принимающим выражением являются исходным хранилищем данных. После разбора или декодирования они представлены значениями того же графа. Имена форматов и численных библиотек не вводят дополнительные фундаментальные виды значений.
[EN]
A Structure is an ordered collection of direct fields. Fields hold references to values: primitive cells, other Structures (including Arrays) and method records. Lexical nesting forms a forest; additional references connect it into a graph containing shared objects and cycles. A primitive cell does not acquire a Structure wrapper merely because a field references it.

<a id="header-receivers"></a>
<a id="system-receivers"></a>
### Auxiliary sys receivers

Helper operations are grouped under `sys\` and called through ordinary paths. Member names do not
become globally reserved words. The group contains `sys\check(S)` (clean-graph name and statically known
requirement checks), `sys\checkL3(S)` (whether the body belongs to level L3: the L2 operations in it), `sys\translate(S)`,
`sys\compile(S)`, `sys\endturn()`, and `sys\native`, `sys\storage`, `sys\descriptor`,
`sys\capacity`, `sys\resize`, `sys\reserve`, `sys\typeof`, `sys\toLmx`, `sys\fromLmx`, `sys\assert`,
`sys\indexof`, `sys\name`, `sys\priority`, and `sys\eval`.
`length` stays globally available by the author's decision; `parent` remains ordinary structural navigation.
Lmx header fields are parent/length/storage; neither native nor capacity is in the header.

Checks return diagnostics and use the working builder's code. They execute neither the inspected program,
initializers, nor user test. `sys\translate(S)` lowers a Structure to **L1 text**, returning an ordinary
Structure with `l1` and `errors`; on errors there is no completed L1 result. This is not LMX output:
`sys\toLmx` serializes current graph state and `sys\fromLmx` parses LMX. Translate neither installs native
nor executes S; it performs necessary checks through shared code without a required separate check call.
The builder is the initial implementation; needed parts move into runtime for these concrete operations,
without another builder, universal wrappers, or extra states.
These are normative receiver contracts, not a runtime availability report.

Compilation is the entire explicitly requested chain: clean-graph construction and checking, lowering to L1
and C, machine compilation, and registration of resulting entries. `sys\compile(S)` applies it to selected
root S and returns the result and diagnostics through the common mechanism; failure installs no new native.
It does not launch S's application entry or run automatically on a write. After clean-graph construction,
the separate required build-test phase may execute checking expressions and the candidate calls they
explicitly make before final C compilation ([test phases](#admission)). It is not an initializer pass.
`sys\translate` still returns only L1 and executes neither the application nor these build tests.
[Native and turn-boundary contract](#explicit-compilation).

<a id="system-indexof"></a>
#### A field's index in its parent Structure

`sys\indexof(field parent)` returns the physical index of the unique occurrence of `field` among
the immediate elements of Structure `parent`. An absent field or multiple occurrences of the same
reference produce an error under the ordinary failure rules.

`sys\indexof(field index parent)` selects occurrence `index` of that same reference, counted from zero,
and returns its physical index in `parent`. A missing selected occurrence is an error.
The occurrence number and returned index differ: when a reference occurs at positions 2 and 5,
`index = 1` returns 5. Both forms receive `parent` explicitly; there is no zero-argument form.

Lookup uses the field's identity/reference, not an equal name or primitive value. It follows neither
nested Structures nor graph references. Structure and Array<@> use one mechanism for reading immediate
elements. Reuse existing addressing; no reverse-index table or per-write maintenance is needed.


### Receivers parent, length, sys\native, sys\storage

These ordinary non-declaring receivers accept one Structure S, including an Array, or operate without an argument:

| Call | Result | Without an argument |
| --- | --- | --- |
| `parent(S)` | S's structural parent, the value of header field `parent`; 0 at a root | `parent()` — `parent(D)` |
| `sys\native(S)` | S's native descriptor from call tables, including signature variants; 0 when absent; reading does not invoke it | `sys\native()` — `sys\native(D)` |
| `length(S)` | The number of immediate Structure fields or Array elements, the value of `length` | `length()` — `length(D)` |
| `sys\storage(S)` | The pointer to element storage, the value of `storage` | `sys\storage()` — `sys\storage(D)` |
| `sys\capacity(S)` | Capacity in elements from the arena table keyed by S's address | `sys\capacity()` — `sys\capacity(D)` |

Here `D` is the DATA of the current call, where it exists: for executable `C` it is actual `parent(C)`. An inline body does not substitute another DATA. `call(A C)` supplies actuals A and does not replace D. R0 has no fabricated default D. Explicit arguments select other Structures, including the selected code itself. Colon and parenthesized receiver forms have the same contract; a bare name invokes nothing. The reserved lexical `node` is a different operation and is not a zero-argument parent query.

In the role of `code` the receiver executes; in the role of `data` a same-headed structural form remains data. With one occurrence, `D\parent`, `D\native`, `D\length` and `D\storage` select the written Structures just as `D\for` does; repeated names require the ordinary occurrence index. Paths gain no header pseudo-fields. The DATA namespace pass interprets root declarations and consumes explicitly specified `import`, `copy` and `merge` where their contracts require it; those three use standard CODE source arguments. It does not execute arbitrary DATA bodies. Code explicitly consumed by a receiver follows that receiver's contract ([rule](#data-root-declaration-execution)).

In Lmx's physical header the former `size` and `data` are renamed to `length` and `storage`; the final order is `parent/length/storage`. Native descriptors reside in call tables in the Thread's arena; capacity resides in another table of the same arena. `data` and `code` are the names of roles ([the roles `data` and `code`](#data-code-roles)); there is no special name `data` ([the name `data`](#ordinary-var)), while `code` is the name of a parameter of the `call` receiver for an executable Structure ([structural call](#call-receivers)). Their meaning is separate from the storage pointer. `node` keeps its existing contract as the reserved activation context, unchanged throughout nested bodies; no `node(S)` receiver is introduced.

Reading parent/length/storage accesses its header field directly; native/capacity use their corresponding arena tables. These queries construct no auxiliary descriptor. `sys\descriptor` returns addresses of actual fields for explicit writes under the [L2 descriptor contract](L2_spec_en.md#get-descriptor).

<a id="get-descriptor"></a>
`sys\descriptor(S)` and `sys\descriptor: S` select an explicitly supplied Structure. With no argument, `sys\descriptor()` and `sys\descriptor:` equal `sys\descriptor(D)` for the data `D` of the current launch (for an executable `C` it is `parent(C)`, [structural call](#call-receivers)), including inside nested control bodies; code requires an explicit argument. In data, a same-headed form remains an ordinary Structure. Both variants return the selected Structure's field addresses under the same contract. Author's decision.

Ordinary receiver `sys\descriptor: S` returns a Structure d containing addresses of S's three actual header fields: `parent`, `length`, `storage`, in that order, without nested VoidArray. Address types are `Lmx **`, `size_t *`, `void **`. `\(d\length) := n` directly changes S.length; `d\length := p` changes only the pointer inside d. These are live field addresses, not a copy or proxy. A direct length write does not allocate storage; `sys\resize` performs coordinated resizing. The descriptor neither extends S's lifetime nor transfers ownership. Native and capacity are not its fields; `S\native` selects an ordinary field if present. [L2 contract](L2_spec_en.md#get-descriptor).

Pointer depth and Array rank are independent arbitrary finite quantities; the language has no fixed limit. A typed reference's indirection level is distinct from prefix `@`, which explicitly obtains a numeric address under the selected level's address contract; ordinary Structure and method references need no prefix `@`. Dereferencing follows the reference or admitted address contract without calling its target. An explicit write through `S\field` or a typed dereference follows the place's general requirement, including references and function pointers. Restrictions on assignment through a bare Structure or function name and on implicit external lookup do not prohibit such explicit writes.

An Array is an ordinary graph Structure with its own structural `parent`; receiver `[]` supplies its elements and their storage type rather than creating a separate family of language objects. An Array contains elements of one type. Its length counts Array elements, while the containing Structure's field count counts its direct fields. An Array of references to Arrays differs from a rectangular multidimensional Array. Nesting `a: b: c: d:...` is the general form of receiving-expression application and has no fixed depth limit. `[]: []:` applies the ordinary Array receiver through that general form; it is not a separate construct or a special array-of-arrays type. An Array element may be a primitive or a reference to a nonprimitive value under the ordinary storage rules; each independent Array has its own length. The C-like head `[][][]` denotes a flat rectangular multidimensional Array and is unrelated to composing separate `[]:` receivers. Dimensionality is not recovered from physical storage. An intermediate Array can be bound to a name through ordinary typed binding: for `[]: []: []: a`, the steps `[]: []: b a[i]` and `[]: c b[j]` each index one independent Array without copying a nonprimitive value. Direct access through multiple Arrays uses the ordinary path `a[i]\[j]\[k]` ([paths](#fields)), not adjacent indices of a flat Array. For example, `char: []: []: mainArgs` uses the same general nesting for an Array of strings: each string is an independent `char` Array of exact length `len` without a trailing NUL (`LmxCharArray`, [L2 §5](L2_spec_en.md#method-array)); NUL belongs to the `c.*` door representation, not the graph value. Representation and the value record -- a type code immediately followed by the value -- are specified in [L2](L2_spec_en.md#value-record).

An empty Structure is a present value with zero fields. It differs from an absent field, numeric zero, and `void`, which denotes no primitive-cell content. A Frame's argument list is itself a Structure; an anonymous Structure in it remains a distinct value also when it alone occupies the entire list: P0 does not unwrap it, whether it is empty or not (author's decision of 2026-11-10). Thus in the parse tree `f()`, `f:`, and an explicitly closed empty vertical body are one tree with an empty body, `f: ()` and `f(())` are one tree with one field, an empty Structure; `f(a b)` and `f: a b` are one tree with two fields, `f((a b))` and `f: (a b)` one tree with one Structure field. This is said of the tree only; in the clean graph the form lies as it is written, too. What a form does is determined in translation and interpretation -- by the role of the form ([the roles `data` and `code`](#data-code-roles)) and by the kind of the receiver ([two kinds of receivers](#two-kinds-of-receivers)). In a call of a callable and of a receiver that takes its arguments as `code`, the four forms `f: a b`, `f(a b)`, `f: (a b)` and `f((a b))` are one and the same call when reading E is selected: the sole Structure among the arguments is expanded into the chain of its fields, once and only when the call is processed; reading W accepts it as a whole, and the two readings are equal ([choosing the declaration by the call](#declaration-selection), [the whole argument structure](#whole-arguments)). A receiver that takes its arguments as `data` receives exactly what is written; in the role of `data` the forms do not change either, and nothing is unwrapped: `f: (a b)` declares `f` with one anonymous Structure inside it, while `f(a b)` and `f: a b` declare a Structure with the fields `a` and `b` (the author's clarification of 2026-11-18). See [empty bodies](LMX_grammar.en.md#empty-colon).

`None` is contextual: its representation is defined by the type expected by the receiving expression. There is no encoding shared by all types; a type without a corresponding definition of `None` does not accept it. The numeral `0` remains zero and means false in logical operations; it is not a universal absence marker. The earlier `Boolean` profile uses the range −1…1: `None = −1`, false is 0 and true is 1. This is a particular profile definition, not the universal encoding of missing values.

Text, images, decimal notation and machine words are substrate storage before recognition by a receiving expression. After parsing or decoding, they are values of the same graph. Format and numeric-library names do not introduce additional fundamental value kinds.
@@ identity | Идентичность и лексическое дерево | Identity and lexical trees | 2; 9.1.3; 19.29.1-2
[RU]
Живые структуры, включая Array, и локальные Message сохраняют физические адреса. Физический адрес записи является идентичностью Message внутри процесса; локальная идентичность не дополняется индексом родителя. Рост хранилища добавляет новые участки; существующие объекты не перемещаются. Равенство содержимого не означает тождества объектов. Явное копирование создаёт новые идентичности и сохраняет связи между ними по правилам [копирования](#composition). Иерархические цепочки индексов принадлежат только [WorldWideMix](#worldwide).

Лексический родитель определяет положение структуры в дереве; у корня родителя нет. Владение памятью и лексическое родство независимы. Присоединение хранилища другого Message сохраняет существующие лексические ссылки, не добавляет само по себе ссылку из корня получателя и не превращает присоединённый корень в лексического ребёнка получателя.

Отсечение внешнего лексического родителя при построении задаёт [квалификатор independent](#qualification); получение входов от вызывающего выражения подчиняется [динамической видимости](#dynamic). Эти механизмы не меняют отношения владения и тождества объектов.
[EN]
Live Structures, including Arrays, and local Messages retain their physical addresses. A record's physical address is the Message's in-process identity; local identity is not supplemented by a parent index. Storage grows by adding new regions; existing objects do not move. Equal contents do not imply object identity. Explicit copying creates new identities and preserves relationships under the [copying rules](#composition). Hierarchical index chains belong only to [WorldWideMix](#worldwide).

A lexical parent determines a Structure's position in its tree; a root has no parent. Storage ownership and lexical ancestry are independent. Attaching another Message's storage preserves existing lexical links, does not itself add a reference from the recipient's root and does not make the adopted root a lexical child of the recipient.

The [independent qualifier](#qualification) cuts the external lexical parent at construction; obtaining inputs from the caller follows [dynamic visibility](#dynamic). Neither mechanism changes storage ownership or object identity.
@@ fields | Имена и пути | Names and paths | 2.3; 13.1; 14.1; 21.1-2; 21.11
[RU]
Имена исходных сущностей не хранятся в самих ячейках графа. Имя примитива или Lmx получается из таблицы «адрес → name»; name — адрес единственной канонической строки этого написания в типизированной арене. Идентификаторы, служебные операторы и ресиверы сравниваются по адресам этих строк, без отдельных числовых кодов. «Атом» относится к парсеру; физические элементы графа включают и Lmx Structure, и непосредственно закодированные примитивы. Обходчик распознаёт записанную голову по каноническому указателю, транслятор потребляет тот же чистый граф и выпускает native. Таблица имён не хранит разрешение переменных или состояние прошлого обхода: namespace текущего обхода создаётся заново и уничтожается при его завершении. Копирование графа переносит имена копируемых адресов, интернируя написания на принимающей границе. Анонимные и позиционные значения не требуют синтетических имён. Физическая модель определена в [спецификации реализации](kernel-implementation.ru.md), вывод текущего графа — в [контракте sys\toLmx](#source-codec).

Одно написание имеет одну каноническую строку со стабильным адресом в типизированной арене. Головы, поля, формальные параметры, имена фактических аргументов, пути, имена отказов и служебные операторы используют одно и то же представление; отдельных инкрементных кодов идентификаторов или операторов нет. Написание интернируется на входных границах, таких как разбор, загрузка, `sys\fromLmx` и присоединение внешних областей. Разрешение имён, специфичное для обхода, временно и начинается с чистого состояния. Пользовательские символьные Array — обычные строковые значения, а не канонические идентификаторы. [Физическое представление](kernel-implementation.ru.md) и [явные запросы по строковым именам](#string-identifier) сохраняют это различие.

Структурный путь `object\field\nested` последовательно выбирает поля графа. Наличие каждого перехода и его допустимость определяются выбранным объектом. Вычисляемый путь не заменяется выдуманным статически известным именем. Зарезервированный `node` обозначает лексическое пространство над методом и остаётся одним и тем же во всей его активации; `node\field` начинает явный обход из этого пространства. Голое `field`, полученное по лексическому fallback, передаётся как скрытый аргумент текущей активации и не тождественно явному пути `node\field`.

Путь может содержать безымянный индексный шаг `a\[i]`, выбирающий элемент типизированного Array. `a[i][j]` адресует ровный многомерный массив, тогда как `a[i]\[j]` индексирует отдельный Array, полученный через значение элемента `a[i]`; цепочка `a[i]\[j]\[k]` следует последующим ссылкам. Индексный шаг может сочетаться с полями Structure и иметь произвольную конечную глубину. В Structure, рассматриваемой как `data`, `s\[N]field` с отсчётом `N` от нуля выбирает N-е вхождение имени `field` на её коренном уровне: вхождение — запись данных, объявляющая это имя, будь то объявление ресивером места или структурная запись с такой головой; вложенные записи принадлежат своим Structure. Это не шаг Array. При одном вхождении допустим `s\field`; при двух и более такой путь неоднозначен и требуется индекс: повторное объявление в данных прежнего не заменяет и в него не пишет и остаётся ещё одним вхождением (решения автора 2026-11-11, [роли `data` и `code`](#data-code-roles)). Автоматически выбирать первое вхождение нельзя.

Исходные формы DATA Structure D сохраняют свою записанную вложенность: корневой `if:` — это форма, адресуемая как `D\if`, а объявление y внутри неё достигается через охватывающую форму, а не поднимается до корневого `D\y`. Другие управляющие и обычные формы вызова подчиняются тому же правилу. Семантические корневые объявления под модификаторами и под ресиверами потоков участвуют в namespace согласно их контрактам; это не уплощает исходный граф. Явный путь начинается с именованной Structure, которую выбирает программа. Специальной ссылки `data` нет, а `node` остаётся явной лексической операцией, а не общим синонимом этой Structure.

<a id="primitive-declaration-is-the-element"></a>
Шага для ресивера, объявляющего примитив, в пути нет: при `S: int: x 10` поле читается путём `S\x`, а не `S\int\x`. Это не особое правило пути, а устройство памяти Structure. Structure хранит свои элементы массивом, и каждый элемент указывает на запись значения: тип и сразу за ним значение ([L2, §3](L2_spec_ru.md#value-record)); имя элемента держит строка «адрес → имя». Полное терминальное объявление `int: x 10` поэтому присутствует как запись этого элемента: «тип `int`, значение 10» с именем `x`. Это его непосредственное физическое кодирование, а не удаление объявления из графа. Потери при этом нет: текст объявления однозначно восстанавливается по типу, значению и имени, так его и печатает `sys\toLmx`. Объявление без значения содержит только код типа `uninit:T`, при нулевом размере значения и без зарезервированной ячейки T, и так же восстанавливается как `int: x`. Это компактное типизированное листовое представление входит в полный буквальный исходный граф, а не выпадает из него. Запись модификатора, ресивера управления или вызова по типу и значению не восстановить, поэтому она лежит в графе как записана — Structure, названной своей головой, — и путь идёт через неё: `S\private\x`, `D\if\y`. Вычисляемое объявление `int: x f()` готовым значением тоже не является: путь `S\x` даёт его запись ([явный путь](#path-reads-no-execution)) (уточнения автора 2026-11-11; 2026-11-17; 2026-11-18).

`node` зарезервирован: его нельзя объявить, затенить, перепривязать или передать динамически, в том числе через точное написание идентификатора. Он обозначает установленное лексическое пространство над выбранным методом и остаётся фиксированным на время этой активации, включая вложенные тела управления. Это **не** общий запрос к непосредственному родителю текущей посещаемой формы или к текущему получателю потока. Понижение передаёт соответствующую физическую лексическую ссылку как обязательный параметр `Lmx *node`; никакое новое пользовательское замыкание или объект namespace не вставляется. Обычные структурные связи с родителем сохраняют исходную вложенность и контракт копирования, но цепочка родителей inline-тела не перепривязывает node. Отношение DATA `D = parent(C)` и лексическая операция node сохраняют свои контракты.

`parent(S)` — обычный ресивер, который читает структурную связь, а не зарезервированное имя или псевдополе пути. Скрытое голое поле использует место, выбранное связыванием: явные фактические аргументы, автозаполнение и сохранённый запасной вариант имеют собственные рабочие места; прозрачное связывание вызывающего обозначает настоящее место вызывающего. Присваивание этому имени не создаёт ни исходного поля, ни постоянного состояния метода. Достигнутые объявления CODE работают в namespace, тогда как явные пути адресуют граф. Граф полностью отражает записанный исходник: каждый ресивер остаётся как записан, а терминальные примитивные листья присутствуют в собственном представлении `{type value}` по адресу, который хранит ячейка Lmx. Неинициализированный лист имеет только код типа и значение нулевого размера.

| Имя | Где существует | Значение |
| --- | --- | --- |
| `node` | зарезервированное слово L3 и первый ABI-параметр метода | пространство над методом; неизменно для всей активации, включая вложенные тела |
| `data` (до 2026-11-11 — `var`) | не зарезервировано с 2026-11-19: название роли и обычное пользовательское имя | особого смысла нет; данные исполняемой Structure — её `parent` ([правило](#ordinary-var)) |
| `code` | доступная при исполнении Structure кода, аргумент запуска | код, выбранный запуском; не физическое поле заголовка Lmx |
| `parent` | физическое поле каждой Lmx, читаемое обычным ресивером | непосредственно объемлющая Structure; `parent()` берёт данные текущего запуска, `parent(S)` — явную S; обычный путь выбирает пользовательское поле |
| `self` | только скрытый ABI-контекст | активная Structure текущего вызова; не слово языка |

Исполнение удерживает физическую ссылку на активную Structure (§12). Это скрытый ABI-контекст, а не новое исходное имя `self`, не второй граф данных и не замена зарезервированного `node`.

Имена графовых полей и переменные namespace вызова различаются. Все одноимённые объявления в данных сохраняются; неоднозначное имя требует индекса вхождения. Namespace вызова готовится по корневым объявлениям `data` и `code`, включая объявления, предоставленные явными потоковыми контрактами, без общего обхода вложенных ветвей и графовых ссылок ([потребление namespace](#data-root-declaration-execution)). Новое локальное имя ветви видно на её уровне и во вложенных ветвях, но не снаружи. Имя, уже объявленное на том же уровне, при повторном объявлении в коде обозначает прежнюю локальную ячейку, а объявление на вложенном уровне затеняет внешнее одноимённое ([уровни объявлений](#shadowing-levels)); вызов и присваивание в `int: x bump()` сохраняются. См. [кадр вызова](#call-frame-20261115).

Например, `int: y give()` описывает именованное место y и сохраняет своё вычисляемое объявление в графе. Его инициализатор выполняется, когда достигнуто объявляющее действие или когда запрошено его разрешённое вычисляемое значение namespace, а не при осмотре исходного пути. В CODE последующее `int: y 7` на том же уровне выполняет проверку типа и пишет в то же логическое место; `int: y` без новой правой части ни сбрасывает его, ни добавляет вторую C-переменную. В DATA повторные объявления остаются различными записанными вхождениями. Переданное объявление вместо этого сохраняет свою форму в рамках [аргументов-объявлений](#declaration-arguments).

Самостоятельный вызов вызываемого создаёт новый namespace; [принятые формы объявлений](#declaration-arguments) и связанные с ними тела разделяют установленные места принимающего исполнения согласно их конкретному контракту. Вложенные тела управления в вызове не создают активации, но новые локальные имена принадлежат своей лексической ветви. Повторное объявление переменной, уже объявленной на том же уровне, не создаёт второй C-переменной; объявление на вложенном уровне создаёт собственное место и затеняет внешнее одноимённое ([уровни объявлений](#shadowing-levels)). Это не сворачивает повторные объявления в исходном графе. Подготовка корня не поднимает объявления ветвей и не дополняет `data` полями из `code`.

Начальные число и порядок полей Structure задаются построением и лексическим порядком; порядок выдачи native не разрешает переставлять поля графа. Обновление существующего поля заменяет содержащуюся в нём ссылку, не добавляя вхождение. Structure и Array<@> используют общее явное изменение размера через sys\resize и sys\reserve; length меняется только явной операцией размера или записью заголовка, не автоматически при записи элемента. См. [переменные массивы](#array-capacity).
[EN]
Source entity names are not stored inside graph cells. A primitive or Lmx name comes from the address → name table; name is the address of the one canonical string for that spelling in the typed arena. Identifiers, service operators and receivers are compared by those string addresses, without separate numeric codes. Atom is a parser term; physical graph elements include both Lmx Structures and directly encoded primitives. The walker recognizes a written head by its canonical pointer, while the translator consumes the same clean graph and emits native. The name table stores neither variable resolution nor prior traversal state: each traversal creates and discards its own namespace. Graph copying transfers names for copied addresses, interning spellings at the receiving boundary. Anonymous and positional values need no synthetic names. The physical model is specified in the [implementation specification](kernel-implementation.en.md); current-graph serialization is defined by the [sys\toLmx contract](#source-codec).

One spelling has one canonical string with a stable address in the typed arena. Heads, fields, formals, actual names, paths, failure names and service operators use that same representation; there are no separate incremental identifier or operator codes. A spelling is interned at input boundaries such as parsing, loading, `sys\fromLmx`, and attachment of foreign regions. Traversal-specific name resolution is temporary and starts clean. User character Arrays are ordinary string values, not canonical identifiers. The [physical representation](kernel-implementation.en.md) and [explicit string-name queries](#string-identifier) preserve this distinction.

A structural path `object\field\nested` selects graph fields in sequence. Each step's presence and validity are determined by the selected object. A computed path is not replaced by an invented statically known name. Reserved `node` denotes the lexical space above the method and stays fixed throughout that method activation; `node\field` starts explicit traversal in that space. A bare `field` obtained by lexical fallback is supplied as a hidden argument of the current activation and is not identical to the explicit `node\field` path.

A path may contain an unnamed index step `a\[i]` selecting a typed Array element. `a[i][j]` addresses a rectangular multidimensional Array, whereas `a[i]\[j]` indexes a separate Array obtained through the value of `a[i]`; `a[i]\[j]\[k]` follows further references. Index steps may be mixed with Structure fields to any finite depth. In a Structure used as `data`, `s\[N]field` with zero-based `N` selects the Nth occurrence of the name `field` at its root level: an occurrence is a form of the data that declares that name, be it a declaration by a receiver of a place or a structural form with that head; nested forms belong to their own Structures. This is not an Array step. With one occurrence, `s\field` is allowed; with two or more it is ambiguous and an index is required: a repeated declaration in data neither replaces the former one nor writes into it and remains one more occurrence (the author's decisions of 2026-11-11, [the roles `data` and `code`](#data-code-roles)). The first occurrence is not selected automatically.

The source forms of a DATA Structure D retain their written nesting: a root `if:` is a form addressed as `D\if`, while a y declaration inside it is reached through that enclosing form, not promoted to root `D\y`. Other control and ordinary call forms follow the same rule. Semantic root declarations under modifiers and stream receivers participate in the namespace under their contracts; this does not flatten the source graph. An explicit path starts from the named Structure selected by the program. There is no special `data` reference, and `node` remains an explicit lexical operation rather than a generic synonym for that Structure.

<a id="primitive-declaration-is-the-element"></a>
A path has no step for a receiver that declares a primitive: with `S: int: x 10` the field is read by the path `S\x`, not `S\int\x`. This is not a special rule of paths but the way the memory of a Structure is arranged. A Structure keeps its elements as an array, and each element refers to a value record: a type and, right after it, a value ([L2, section 3](L2_spec_en.md#value-record)); the name of the element is held by an «address -> name» row. The complete terminal declaration `int: x 10` is therefore present as that element's record «type `int`, value 10» with the name `x`. This is its direct physical encoding, not removal of the declaration from the graph. Nothing is lost: the text of the declaration is recovered unambiguously from the type, the value and the name, and that is how `sys\toLmx` prints it. A declaration without a value contains only the type code `uninit:T`, with zero value bytes and no reserved T cell, and is recovered as `int: x` in the same way. This compact typed-leaf representation is part of the full literal source graph, not an omission from it. The record of a modifier, of a control receiver or of a call cannot be recovered from a type and a value, so it lies in the graph as it is written -- a Structure named by its head -- and the path goes through it: `S\private\x`, `D\if\y`. A computed declaration `int: x f()` is not a ready value either: the path `S\x` gives its record ([explicit path](#path-reads-no-execution)) (the author's clarifications of 2026-11-11; 2026-11-17; 2026-11-18).

`node` is reserved and cannot be declared, shadowed, rebound or dynamically supplied, including through exact-identifier spelling. It denotes the established lexical space above the selected method and remains fixed during that activation, including nested control bodies. It is **not** a generic query for the immediate parent of the currently visited form or for the current stream recipient. Lowering carries the corresponding physical lexical reference as the required `Lmx *node` parameter; no new user closure or namespace object is inserted. Ordinary structural parent links retain the source nesting and the copying contract, but an inline body's parent chain does not rebind node. The DATA relation `D = parent(C)` and the lexical node operation keep their respective contracts.

`parent(S)` is an ordinary receiver that reads a structural link, not a reserved name or path pseudo-field. A hidden bare field uses the place selected by binding: explicit actuals, autofill and retained fallback have their own working places; a transparent caller binding denotes the caller's real place. Assigning that name creates neither a source field nor persistent method state. Reached CODE declarations work in the namespace, while explicit paths address the graph. The graph fully reflects the written source: every receiver remains as written, and terminal primitive leaves are present in their own `{type value}` representation at the address held by the Lmx cell. An uninitialized leaf has its type code only and a zero-size value.

| Name | Where it exists | Meaning |
| --- | --- | --- |
| `node` | reserved L3 word and first method ABI parameter | space above the method; fixed for the whole activation, including nested bodies |
| `data` (`var` until 2026-11-11) | not reserved since 2026-11-19: the name of a role and an ordinary user name | no special meaning; the data of an executable Structure is its `parent` ([rule](#ordinary-var)) |
| `code` | the code Structure accessible during execution, a launch argument | the code selected by the launch; not a physical Lmx header field |
| `parent` | a physical field of each Lmx, read through an ordinary receiver | the immediately enclosing Structure; `parent()` takes the data of the current launch, `parent(S)` an explicit S; ordinary paths select user fields |
| `self` | hidden ABI context only | the active Structure of this call; not a language word |

Execution retains the physical reference to the active Structure (§12). This is hidden ABI context, not a new source name `self`, a second data graph or a replacement for reserved `node`.

Graph-field names and call-namespace variables are distinct. All same-named data declarations remain; ambiguous names require an occurrence index. The call namespace is prepared from root declarations in `data` and `code`, including declarations supplied by the explicit stream contracts, without a general walk of nested branches or graph references ([namespace consumption](#data-root-declaration-execution)). A new branch-local name is visible at its own level and in descendants, not outside. A name already declared on the same level, when re-declared in code, denotes the existing local cell, while a declaration on a nested level shadows the outer one of the same name ([levels of declarations](#shadowing-levels)); the call and assignment in `int: x bump()` remain. See [call frames](#call-frame-20261115).

For example, `int: y give()` describes the named place y and retains its computed declaration in the graph. Its initializer runs when the declaring action is reached or its permitted computed namespace value is demanded, not by inspecting the source path. In CODE a subsequent same-level `int: y 7` performs type checking and writes the same logical place; `int: y` with no new RHS neither resets it nor adds a second C variable. In DATA repeated declarations remain distinct written occurrences. A passed declaration instead preserves its form under [declaration arguments](#declaration-arguments).

An independent callable invocation creates a new namespace; [accepted declaration forms](#declaration-arguments) and their associated bodies share the receiving execution's established places under their specific contract. Nested control bodies in a call do not create an activation, but new local names belong to their lexical branch. Re-declaring a variable already declared on the same level creates no second C variable; a declaration on a nested level creates its own place and shadows the outer one of the same name ([levels of declarations](#shadowing-levels)). This does not collapse repeated declarations in the source graph. Root preparation neither lifts branch declarations nor completes `data` with `code` fields.

A Structure's initial field count and order follow construction and lexical order; native-emission order does not authorize rearrangement. Updating an existing field replaces its stored reference without appending an occurrence. Structure and Array<@> share explicit resizing through sys\resize and sys\reserve; length changes only through an explicit size operation or explicit header write, not implicitly on an element store. See [variable Arrays](#array-capacity).
@@ descriptions | Явные описания значений и преобразования | Explicit value descriptions and conversions | 2.2.2-2.2.4; 2.4; 9.1; 9.1.1; 9.2
[RU]
Описание значения — обычная явно доступная структура. Принимающее выражение получает его через аргумент или ссылку. Описание не прикрепляется скрыто к каждому примитиву и не нужно для определения физического типа: его даёт код в записи значения. Названия `class`, `class.range` и подобных таблиц обозначают данные конкретного профиля, а не обязательные глобальные сущности языка.

Таблица преобразований задаёт соответствия примитивных значений и их описаний, а не всех пар Structure или их имён. Разные структуры `A` и `B` имеют общее физическое представление `Lmx` — запись с кодом типа ([L2 §3](L2_spec_ru.md#value-record)); имя и состав полей не создают отдельный физический тип или массив из одного элемента. Структурная пригодность `B` требованию `A` определяется `implements` относительно Consumer, не строкой конверсии `B → A`. Получение или перенос ссылки на Structure также не требует отдельного конвертера для каждой модели. Общность физического представления не отменяет структурный допуск, квалификации и различие ссылки на Structure со ссылкой на ссылочную ячейку.

Описание разделяет семантический контракт и архитектурное представление. Контракт задаёт смысл: счётное число, целое, рациональное, число с выбранной точностью, комплексное, атом, адрес, непрозрачный ресурс или отсутствие содержимого. Представление задаёт ширину, знаковость, диапазон и обозначение целевого типа. Одинаковое представление не делает контракты одинаковыми: `Boolean` и `int8` могут храниться одинаково, но иметь разные допустимые значения.

Обычные поля описания включают `cell`, `semantic`, признаки `numeric`/`integer`/`floating`/`reference`/`opaque`, `width`, `signed`, `range`, `spelling` и ключи преобразований `convert`. Имена полей выбирает профиль. Указание диапазона является данными контракта; его выполнение проверяется [единым механизмом допуска](#admission), а не самим наличием поля.

Численная цепочка контрактов: флаг → неотрицательное целое → целое → рациональное → число с точностью профиля → комплексное. Неотрицательные целые включают ноль. Машинное `double` не является множеством всех вещественных чисел. Атомы, адреса и непрозрачные ресурсы — отдельные контракты, не ступени этой численной цепочки. `unit` — пустая структура; `void` — отсутствие содержимого ячейки.

Описания составляются обычным `merge` с общим правилом [порядка вхождений](#fields). Поля `width`, `range` или `spelling` не создают автоматически арифметические методы. Такие операции задаются вызываемыми выражениями. Пример `u32` сочетает неотрицательный целочисленный контракт, 32-битное представление и диапазон 0…4294967295; `FILE` описывает непрозрачную идентичность ресурса. Слово `FILE` само по себе не доказывает возможность чтения или закрытия: такие требования выражаются путями структуры `File`.

Преобразователь — явно выбранное принимающее выражение. Его ключ поступает из явных описаний и их композиции; скрытого перебора пар нет. Проверка пригодности не исполняет преобразователь, а требующее преобразования действие выполняет выбранный вызов. Повторное объявление ключа в одной Structure читается по роли ([роли `data` и `code`](#data-code-roles)): в данных это ещё одно вхождение имени — прежнего оно не заменяет и в него не пишет, и ключ после него адресуется только с индексом вхождения ([имена и пути](#fields)); в коде повторное объявление ресивером записывает в уже объявленное место после проверки типа, не создавая второго поля. Композиция записывает одноимённый ключ позднего операнда в слот модели. Если таблица содержит несколько строк с одним ключом, выбор строки задаёт её собственная политика ([таблицы](#registries)).

Численное преобразование сохраняет контракт диапазона назначения: `u16(255) → u8` допустимо при наличии преобразователя, `u16(256) → u8` даёт ошибку диапазона, а не ноль. Округление `1.5 → i32` и потеря точности внутри диапазона требуют отдельного правила численного профиля. Доказанная включённость диапазонов может исключать избыточную машинную операцию, сохраняя семантическое требование. Ошибки формата, диапазона и поведения преобразователя не заменяются положительным ответом `implements`.
[EN]
A value description is an ordinary explicitly accessible Structure. A receiving expression obtains it through an argument or reference. It is not secretly attached to every primitive and is unnecessary for determining a physical type: the code in the value's record gives it. Names such as `class` and `class.range` denote a particular profile's data, not mandatory global language entities.

The conversion table defines relations between primitive values and their descriptions, not between every pair of Structures or their names. Distinct Structures `A` and `B` share the physical `Lmx` representation -- a record with a type code ([L2 §3](L2_spec_en.md#value-record)); a name or field composition creates neither a separate physical type nor a one-element array. Whether `B` satisfies requirement `A` is determined by `implements` relative to the Consumer, not by a `B → A` conversion row. Obtaining or transferring a Structure reference likewise requires no converter for each model. Shared physical representation does not remove structural admission, qualifications, or the distinction between a Structure reference and a reference to a reference cell.

A description separates its semantic contract from architecture binding. The contract defines meaning: count, integer, rational, profile-precision number, complex value, atom, address, opaque resource or absence of content. The binding defines width, signedness, range and target spelling. Equal representation does not imply equal contracts: `Boolean` and `int8` may share storage while admitting different values.

Ordinary description fields include `cell`, `semantic`, flags such as `numeric`/`integer`/`floating`/`reference`/`opaque`, `width`, `signed`, `range`, `spelling` and `convert` keys. The profile chooses field names. A range declaration is contract data; satisfaction is established through the [single admission mechanism](#admission), not by the field's presence alone.

The numeric contract chain is flag → nonnegative integer → integer → rational → profile-precision number → complex number. Nonnegative integers include zero. Machine `double` is not the set of all real numbers. Atoms, addresses and opaque resources are separate contracts, not rungs of this numeric chain. `unit` is an empty Structure; `void` denotes no cell content.

Descriptions are composed with ordinary `merge` under the common [occurrence-order rule](#fields). Fields such as `width`, `range` or `spelling` do not automatically create arithmetic methods. Such operations are callable expressions. For example, `u32` combines a nonnegative integer contract, 32-bit representation and range 0…4294967295; `FILE` describes opaque resource identity. A `FILE` word alone does not establish that reading or closing is valid: such requirements are expressed through paths of a `File` Structure.

A converter is an explicitly selected receiving expression. Its key comes from explicit descriptions and their composition; there is no hidden search over pairs. Suitability checking does not run the converter; an action requiring conversion performs the selected call. A repeated declaration of a key in one Structure is read by the role ([the roles `data` and `code`](#data-code-roles)): in data it is one more occurrence of the name -- it neither replaces the former one nor writes into it, and after it the key is addressed only with the index of an occurrence ([names and paths](#fields)); in code a repeated declaration by a receiver writes into the already declared place after the type check and creates no second field. Composition writes a later operand's same-name key into the model's slot. If a table has several rows with one key, the table operation's own policy selects the row ([tables](#registries)).

Numeric conversion preserves the destination-range contract: `u16(255) → u8` is admitted when the converter exists, while `u16(256) → u8` produces a range error, not zero. Rounding `1.5 → i32` and in-range precision loss require explicit numeric-profile rules. Proven range inclusion may eliminate a redundant machine operation while preserving the semantic requirement. Format, range and converter-behavior failures are not replaced by a positive `implements` result.
@@ conversion-context | Привязки типов и контекст преобразований на уровне Message | Message-local type bindings and conversion context | 2.2.3; 2.2.4; 7; 19.16
[RU]
У каждого исполняющегося Message один контекст описаний типов, их символических привязок и преобразований. Он состоит из обычных Structure и ссылок, явно переданных при построении Message или достижимых из них. Создание, отправка и родство Message сами по себе не передают контекст родителя. Встроенного процесс-глобального реестра, неявного окружения типов и скрытого поиска преобразователей нет. Таблицу преобразований, которой пользуется `implements`, можно изменить при создании нового L1 Thread (слова автора 2026-11-18).

### Устойчивые привязки и структурная общность

Символическое имя типа связывается один раз для Message и одинаково разрешается во всех его употреблениях, включая аргументы и результаты; каждый вызов не инстанцирует его заново. Другой Message может связать то же имя иначе. Это отношение внутри контекста, а не дополнительное пространство runtime-имён.

Структурная обобщённость — обычный случай [допуска](#admission): Consumer требует только используемые пути, операции и контракты. Отдельный generic-шаблон не нужен. Символическая привязка требуется, когда несколько позиций должны разделять одно устойчивое отношение типов, а не для объявления обобщённости как таковой.

### Преобразования при потреблении

Достижимая таблица преобразований касается примитивных описаний, включая явно заданные семантические величины и единицы; это не каталог совместимости Structure. Иное примитивное описание допустимо только через доступное в данном Message преобразование, разрешённое контрактом Consumer. Первая часть допуска — проверка пригодности — не исполняет преобразователь. При действительном потреблении он исполняется как обычное вызываемое выражение с проверками диапазона, представления, точности и семантических условий. Успех структурной проверки не разрешает переинтерпретировать примитивное хранилище без такого преобразования.

Перед вызовом преобразованный фактический аргумент должен удовлетворять действительному дескриптору выбранного вызываемого выражения; после вызова результат отдельно приводится к требованию его Consumer. Отсутствующий в достижимом контексте преобразователь не заменяется скрытой цепочкой или поиском по процессу. Реализация вправе кэшировать разрешённые привязки и маршруты, только сохраняя результат явного разрешения.

Развёрнутые [примеры контекста Message](LMX_semantics_guide.ru.md#message-conversion-context) вынесены из нормативного текста.
[EN]
Each executing Message has one context of type descriptions, symbolic bindings, and conversions. It consists of ordinary Structures and references explicitly supplied when the Message is built or reachable from them. Message creation, sending, and parenthood do not implicitly pass the parent's context. There is no built-in process-global registry, implicit type environment, or hidden converter search. The table of conversions that `implements` uses can be changed when a new L1 Thread is created (the author's words of 2026-11-18).

### Stable bindings and structural genericity

A symbolic type name is bound once for a Message and resolves consistently at every use, including arguments and results; each call does not instantiate it anew. Another Message may bind the same name differently. This is a relation within the context, not another runtime name space.

Structural genericity is the ordinary case of [admission](#admission): a Consumer requires only the paths, operations, and contracts it uses. It needs no separate generic template. A symbolic binding is needed when multiple positions must share one stable type relation, not merely to declare genericity.

### Conversion at consumption

The reachable conversion table concerns primitive descriptions, including explicitly supplied semantic quantities and units; it is not a Structure-compatibility catalog. Another primitive description is admissible only through a conversion available in this Message and allowed by the Consumer's contract. The first part of admission, suitability checking, does not execute a converter. At actual consumption it executes as an ordinary callable with checks for range, representation, precision, and semantic conditions. Structural success does not permit reinterpretation of primitive storage without such a conversion.

Before a call, each converted actual argument must satisfy the selected callable's actual descriptor; afterward its result is converted separately to the Consumer's requirement. A converter absent from the reachable context is not replaced by a hidden chain or process-wide search. An implementation may cache resolved bindings and routes only while preserving the result of explicit resolution.

Expanded [Message-context examples](LMX_semantics_guide.en.md#message-conversion-context) are kept outside the normative text.
@@ admission | Проверка используемого интерфейса и test | Used interface checking and test | 2.1; 2.1.1-3; 2.5.1-3; 2.5.5-6; 19.21.3; 19.22; author 2026-09-20; author 2026-10-26; author 2026-11-13
[RU]
Допуск кандидата использует один механизм: проверку интерфейса направленным `implements`, затем явно заданные аналитические проверки (`test`) принимающего выражения там, где контракт допуска их требует. Физические коды типов определяют представление, но допуск не заменяют. Обычная проверка используемого интерфейса сверяет фактические потребности конкретного Consumer; явный структурный шаблон требует всего заявленного дерева, а именованное описание fn выбирает [правило позиционной сигнатуры](#fn-signature). Это ветви одного и того же механизма, а не альтернативные системы типов.

Построение чистого графа проверяет статически известных кандидатов, не исполняя их тела и вычисляемые инициализаторы. Подготовленное native-исполнение не добавляет автоматического `implements` во время выполнения; явный `implements`, записанный в программе, всё равно исполняется. Интерпретатор применяет стандартный `implements` автоматически в достигнутых вызовах, а не как независимый валидатор, и не выполняет предварительного обхода неисполненных ветвей. Приём сохраняет установленное соответствие для операций этого приёма; последующий обход получает собственную информацию из графа. Ни один из механизмов не добавляет постоянного кэша допуска или автоматического отслеживания записи в граф. Подготовленные машинные входы меняются только через [явную компиляцию](#explicit-compilation).

После построения чистого графа интерпретатор исполняет обязательные ресиверы `test` сборки до финального шага C-компиляции. Обычные контракты сборки и ресиверов приводят к этим тестам; это не поиск, который исполняет произвольные формы `test` во вложенных DATA лишь потому, что они существуют. Неуспешный тест не допускает принятия и компиляции этой сборки. Эта фаза тестирования отлична от построения графа и от спекулятивного исполнения кода аргументов, умолчаний и test при перечислении кандидатов на вызов. Динамический приём и явно запрошенные проверки сохраняют своё обычное поведение достигнутого исполнения. Проверяющее выражение и вызовы кандидатов и вспомогательных функций, которые оно делает, используют обычную диспетчеризацию; тестирование, которое ведёт интерпретатор, не заставляет каждый вложенный вызов идти через обходчик. Неописанный анализ будущих значений или поведения не добавляется.

<a id="analytical-tree"></a>
### Проверка используемого интерфейса

<a id="three-argument-implements"></a>
#### `implements(aVar, bVar, Consumer)`

`aVar` — кандидат, `bVar` — требуемая роль, а `Consumer` — конкретное принимающее выражение. Для используемого интерфейса, выведенного из Consumer, его известные обращения в видимых ветвях определяют требуемые пути; побочные поля в это требование не переходят. Когда обычная Structure явно выбрана как структурный шаблон, требуется всё её заявленное дерево, включая явно включённые методы и их поддеревья; непосредственное использование Consumer их не отменяет. Без Consumer проверяются заявленные требования `bVar`, а не пустой набор обращений. Дополнительные поля кандидата допускаются. Требование `fn` вместо этого использует упорядоченное сравнение типа и результата, описанное в [§11](#fn-signature). Неизвестный вычисляемый путь не отмечается как проверенный, а одна неопределённость не устанавливает несовместимости; ошибка требует гарантированно невыполнимого требования.

Для использованного пути необходимы соответствующее поле кандидата и совместимость интерфейса его фактического потребления. Если Consumer явно вызывает поле, проверяются только записанные вызовы: фактические и именованные аргументы, умолчания и доступные преобразования должны удовлетворять выбранному интерфейсу и действительному дескриптору реализации; объявленный результат и объявленные выходы — требованию Consumer. Это проверка совместимости интерфейсов, не предсказание будущего результата. Непрозрачная передача callable не проверяет будущих вызовов. Простая передача примитивного листа не доказывает его значение; содержательные свойства проверяют явные тесты.

Проверка используемого интерфейса не исполняет кандидата, Consumer, метод или преобразователь и не добавляет анализа будущего поведения. Она устанавливает совместимость для данного Consumer, не равенство структур и не пригодность для всякого будущего потребителя. При положительном результате каждому использованному полю модели сопоставляется физическое поле кандидата, возможно на другой позиции. Это **общая** карта для любой допущенной пары Structure, а не особая таблица метода, `data` или `call`. Явное структурное чтение, запись и взятие адреса через допущенное соответствие используют эти физические места; доступ к уже сопоставленным полям не ищет имена заново ([L2 §14](L2_spec_ru.md#implements), [механизмы L2](L2_spec_ru.md)).

<a id="correspondence-stability"></a>
#### Сохранение установленного соответствия

Именованное принимающее место проверяется по общему контракту допуска. Для `S\x := value` и `S\[n]x := value` требование поля учитывается при построении чистого графа, когда оно и кандидат известны. `S[n] := p` — запись `void*` в массив, одинаковая для Structure и `Array<@>`. Она не наследует имя, тип или требование прежнего содержимого и не выполняет допуска по полю. Последующее структурное обращение интерпретирует текущее содержимое графа. Таблица прежних требований к физическим элементам для такой записи не нужна. Допуск сохраняется там, где программа действительно принимает значение по описанию.

<a id="argument-compatibility-stage"></a>
Трансляция проверяет сигнатуры, присваивания аргументов и обязательства, необходимые для корректного порождённого кода, включая записанные throw/catch. Она использует те же правила допуска, что и другие потребители. Одного имени известного метода недостаточно, чтобы доказать текущий тип изменяемой привязки. Вызовы используют выбранное объявление и карту фактических аргументов в формальные; их требование к входу получается из фактического `parent(C)`, а ссылка с ограничением fn также применяет свою карту публичных меток и позиций. Интерпретатор проверяет через стандартный механизм в достигнутых операциях; подготовленный native-код не добавляет автоматического слоя допуска времени выполнения.

Преобразование отлично от проверки интерфейса. Приём числового значения всё так же подчиняется правилам диапазона целевого типа, поэтому допущенное преобразование `u16(256)` в `u8` может завершиться ошибкой из-за диапазона, а не молча обернуться. Установленная структурная карта адресов не отменяет приём нового фактического аргумента и не перезапускает каждый пользовательский тест при каждой записи. Обычные выбранные вызываемые, преобразователи и тесты разделяют исполнение и обработку отказов; будущие тела не исполняются спекулятивно, чтобы решить вызов.

<a id="graph-tests"></a>
### Аналитическая часть test

Там, где контракт допуска требует аналитических проверок, он исполняет явно заявленные проверки принимающего выражения над построенным графом. Само сопоставление интерфейса не исполняет ни одну из этих проверок и никакие тела кандидатов. Построение графа не исполняет `test`; отдельная фаза тестов сборки до C и достигнутые проверки времени выполнения используют общий исполнитель. Без явного Consumer проверки относятся к принимающему описанию `bVar`, а не к кандидату `aVar`. Отсутствие заданных тестов означает отсутствие дополнительного анализа, а не доказательство поведения. Первый результат 0 останавливает допуск; оставшиеся проверки не исполняются, а успех требует успеха всех заданных проверок. Объявленные отказы используют обычные throw/catch. Проверки не являются наблюдателями каждой записи в граф.

<a id="test-receiver-contract"></a>
#### Ресивер `test:`

При исполнении внутри Structure запись `test: op checkIncrement` связывает принимаемое место `op` с обычным проверяющим выражением `checkIncrement`. Оба имени разрешаются как аргументы ресивера, а не вызываются неявно. Имя `test` зарезервировано; пользовательское имя для обычного метода может быть `mytest`. Связь принадлежит Consumer, не кандидату; несколько `test:` задают несколько обязательных проверок. Проверки вложенного Consumer не становятся автоматически проверками внешнего.

Форма `test` подчиняется общим [правилам исполнения через ресиверы](#data-root-declaration-execution). Проход namespace DATA интерпретирует корневые объявления и, когда до них доходят или когда они требуются, потребляет явно заданные `import`, `copy` и `merge`, используя их стандартные аргументы-источники CODE. Это не проход произвольного исполнения тела DATA: форма `test:` среди данных не исполняется лишь потому, что присутствует. Исполняющийся ресивер может достичь переданного ему кода, а этот код может достичь `test`. Отдельного прохода, который находит и исполняет `test` во вложенных данных, нет (уточнение автора).

Проверяющему выражению передаётся фактический кандидат обычным аргументом. Пригодность структуры для его собственных обращений проверяется до исполнения; `@` не добавляется ради передачи Structure, уже передаваемой ссылкой. Проверка возвращает обычный `int`: 1 — успех, 0 — неуспех. Ожидаемый отказ проверяется обычным `catch`, а произвольный `throw` не считается успехом.

Исполнение проверки завершает уже начатый допуск, не начинает тот же допуск заново. Цикл незавершённых проверок не является успехом. Написанная связь и тело проверки находятся в том же графе для `sys\toLmx`, копирования и исполнения, пока не изменены явной записью; отдельного каталога тестов, вспомогательного графа, дополнительной runtime-таблицы связывания имён и скрытого отключения типизации нет. Тесты вызывают методы через обычную диспетчеризацию native/обходчика и не принуждают всё исполнение к обходу.
[EN]
Candidate admission uses one mechanism: interface checking by directional `implements`, then the explicitly specified analytical checks (`test`) of the receiving expression where that admission contract requires them. Physical type codes identify representation but do not replace admission. Ordinary used-interface checking examines a concrete Consumer's actual demands; an explicit structural template requires its whole stated tree, and a named fn description selects the [positional signature rule](#fn-signature). These are branches of the same mechanism, not alternative type systems.

Clean-graph construction checks statically known candidates without running their bodies or computed initializers. Prepared native execution does not add automatic runtime `implements`; an explicit `implements` written in the program still executes. The interpreter uses the standard `implements` automatically at reached calls, not an independent validator, and does not pre-walk unexecuted branches. A reception retains its established correspondence for that reception's operations; a later traversal obtains its own information from the graph. Neither mechanism adds a persistent admission cache or automatic graph-write tracking. Prepared machine entries change only through [explicit compilation](#explicit-compilation).

After the clean graph is constructed, the interpreter executes the build's required `test` receivers before the final C compilation step. The ordinary build and receiver contracts reach these tests; this is not a search that executes arbitrary `test` forms in nested DATA merely because they exist. A failed test prevents acceptance and compilation of that build. This test phase is distinct from constructing the graph and from speculatively executing argument/default/test code while enumerating call candidates. Dynamic reception and explicitly requested checks retain their ordinary reached-execution behavior. The checking expression and the candidate/helper calls it makes use ordinary dispatch; interpreter-led testing does not force every nested call onto the walker. No unspecified analysis of future values or behavior is added.

<a id="analytical-tree"></a>
### Used interface checking

<a id="three-argument-implements"></a>
#### `implements(aVar, bVar, Consumer)`

`aVar` is the candidate, `bVar` the required role, and `Consumer` the concrete receiving expression. For a Consumer-derived used interface, its known accesses in visible branches determine the demanded paths; unused incidental fields are not promoted into that requirement. When an ordinary Structure is explicitly selected as a structural template, all of its stated tree is required, including explicitly included methods and their subtrees; a Consumer's immediate use does not erase them. Without Consumer, the stated requirements of `bVar` are checked rather than an empty access set. Extra candidate fields are allowed. A `fn` requirement instead uses the ordered type/result comparison described in [§11](#fn-signature). An unknown computed path is not reported as checked, and uncertainty alone does not establish an incompatibility; an error requires a guaranteed unsatisfiable requirement.

A used path requires a corresponding candidate field and interface compatibility with its actual consumption. If Consumer explicitly invokes a field, only the written calls are checked: actual and named arguments, defaults and available conversions must fit the selected interface and the implementation's actual descriptor; the declared result and declared exits must meet Consumer's requirement. This checks interface compatibility, not a future result's value. Opaque transport of a callable does not check future calls. Merely transporting a primitive leaf proves nothing about its value; explicit tests check substantive properties.

Used interface checking executes none of the candidate, Consumer, method or converter and adds no analysis of future behavior. It establishes compatibility for this Consumer, not equality of Structures or suitability for every future consumer. A positive result maps each used model field to a physical candidate field, possibly at another position. This is a **general** map for any admitted pair of Structures, not a table specific to methods, `data`, or `call`. Explicit structural reading, writing and taking addresses through the admitted correspondence use these physical places; access to those mapped fields performs no further name lookup ([L2 §14](L2_spec_en.md#implements), [L2 mechanisms](L2_spec_en.md)).

<a id="correspondence-stability"></a>
#### Preservation of established correspondence

Named receiving places use the ordinary admission contract. For `S\x := value` and `S\[n]x := value`, the field requirement is checked during clean-graph construction where it and the candidate are known. `S[n] := p` is a `void*` array write, identical for a Structure and `Array<@>`. It inherits no name, type, or requirement from the previous content and performs no field admission. Subsequent structural access interprets current graph content. No table of former physical-slot requirements is needed for this write. Admission still applies where a value is actually received against a description.

<a id="argument-compatibility-stage"></a>
Translation checks the signatures, argument assignments and obligations needed for correct generated code, including written throws/catch. It uses the same admission rules as other consumers. A known method name alone does not prove the current type of a mutable binding. Calls use the selected declaration and actual-to-formal map; their input requirement is obtained from actual `parent(C)`, and a fn-constrained reference also applies its public-label/position map. The interpreter checks through the standard mechanism at reached operations; prepared native code does not add an automatic runtime admission layer.

Conversion is distinct from interface checking. Receiving a numeric value still obeys destination-range rules, so an admitted conversion of `u16(256)` to `u8` can fail for range rather than silently wrap. An established structural address map neither removes reception of a new actual nor reruns every user test on every write. Ordinary selected callables, converters and tests share execution and failure handling; future bodies are not speculatively run to decide a call.

<a id="graph-tests"></a>
### Analytical part test

Where the admission contract requires analytical checks, it executes the receiving expression's explicitly stated checks against the constructed graph. Interface matching itself runs none of those checks or candidate bodies. Graph construction performs no `test` execution; the separate pre-C build-test phase and reached runtime checks use the common executor. Without explicit Consumer, checks belong to the receiving description `bVar`, not to candidate `aVar`. No specified tests means no additional analysis, not proof of behavior. The first result 0 stops admission; remaining checks do not execute, and success requires all specified checks to succeed. Declared failures use ordinary throw/catch. Checks are not watchers on every graph write.

<a id="test-receiver-contract"></a>
#### The `test:` receiver

When executed inside a Structure, `test: op checkIncrement` associates receiving place `op` with ordinary checking expression `checkIncrement`. Both names resolve as receiver arguments, not implicit calls. The name `test` is reserved; an ordinary user method may be called `mytest`. The association belongs to Consumer, not the candidate; multiple `test:` forms require multiple checks. A nested Consumer's checks are not automatically promoted to its outer Consumer.

A `test` form follows the general [rules for execution through receivers](#data-root-declaration-execution). The DATA namespace pass interprets root declarations and, when reached or required, consumes explicitly specified `import`, `copy` and `merge` using their standard CODE source arguments. It is not an arbitrary DATA-body execution pass: a `test:` form among the data does not run merely by being present. An executing receiver may reach code supplied to it, and that code may reach `test`. There is no separate pass that finds and executes `test` in nested data (the author's clarification).

The actual candidate is supplied to the checker as an ordinary argument. Structural suitability for the checker's own accesses is checked before execution; no `@` is added merely to transport a Structure, which already travels by reference. A checker returns an ordinary `int`: 1 for success, 0 for failure. An expected failure uses ordinary `catch`; an arbitrary `throw` is not success.

Running a check completes admission already in progress rather than starting that same admission over again. A cycle of unfinished checks is not success. The written association and checking body reside in the same graph for `sys\toLmx`, copying and execution until changed by an explicit write; there is no separate test catalogue, auxiliary graph, additional runtime variable-binding table or hidden typing-disabled mode. Test calls use ordinary native/walker dispatch and do not force every call to be walked.
@@ admission-recipes | Как получить требуемую гарантию: четырнадцать практических случаев | Obtaining a required guarantee: fourteen practical cases | 2.5.4; 2.5.3; author 2026-09-20
[RU]
Эти случаи применяют [единый допуск](#admission), а не вводят четырнадцать разновидностей типизации.

### 1. Одно принимающее выражение для разных форм данных

Consumer требует используемые им пути, а не номинальный тип всей Structure.

### 2. Понимание того, что проверяется в данном месте

Первая часть проверяет пригодность структуры для реальных обращений Consumer; вторая, аналитическая часть `test`, проверяет заявленное поведение. Неизвестное покрытие не считается доказательством.

### 3. Различение смыслов одинаково представимых значений

Смысловое различие выражают используемым путём и, когда важны значения листьев, тестом; одно имя типа не доказывает равенства значений.

### 4. Ограничение скалярного листа

Наличие поля `width` не доказывает `width = 32`; проверку конкретного числа задаёт тест Consumer.

### 5. Изменение, видимое другим держателям ссылки

Запись через явный путь меняет адресованный общий референт; присваивание аргументу или другой собственной локальной переменной меняет только место текущей активации, без обратной публикации; имя, связанное как место вызывающего, обозначает место вызывающего, и запись в него действует сразу ([собственное место и место вызывающего](#binding-places)). [Кадр вызова](#call-frame-20261115).

### 6. Независимость от изменения другим держателем

Обычная передача Structure или Array переносит ссылку. Независимую изменяемую копию даёт явное копирование, неизменяемость запрещает изменение защищённого значения.

### 7. Гарантия возможности вызова

Помимо подходящего вызываемого интерфейса, вызову нужны источники его свободных (динамических) входов. Обычные объявленные входы необязательны, если только вход с `required` или другой применимый контракт не исключает пропуск: вход без значения, которому не подано значение, вызову не отказывает: его заполняет [автозаполнение](#binding-autofill), а где оно неприменимо, он держит «T без инициализации» (решение автора 2026-11-16); что поле инициализировано, проверяет ресивер [`required`](#required-receiver).

### 8. Проверка передаваемого вызываемого значения

Передача callable не исполняет его и не доказывает пригодность для каждого будущего вызова; конкретный вызов проходит собственный допуск.

### 9. Изменение тела метода без нарушения вызовов

Новый свободный динамический вход меняет интерфейс метода и требует проверки затронутых вызовов; неизменная сигнатура сама не гарантирует прежнее поведение.

### 10. Выбор нужной части композиции

`merge` составляет только свои явные источники: совместимое более позднее поле заменяет соответствующий элемент модели первого источника, а новое поле добавляется. Он выдаёт результирующие поля потоком; группировка получает одну Structure. Приёмник не является неявной моделью.

### 11. Изменение существующей структуры

Structure использует общий механизм переменных массивов: sys\resize меняет length и при необходимости storage; адрес дескриптора сохраняется. Сырые адреса прежнего storage автоматически не исправляются; L3-ссылка на элемент хранит дескриптор и index.

### 12. Надёжное численное преобразование

Преобразователь соблюдает диапазон назначения: `u16(256) → u8` не означает молчаливое обёртывание. Отказ обрабатывается обычным механизмом отказов.

### 13. Значение широкой таблицы преобразователей

Дополнительные преобразователи расширяют доступные явные преобразования листьев, но не меняют требуемые пути и интерфейсы callable.

### 14. Корректность внешнего ресурса

Тонкий дескриптор не доказывает действительность ресурса и право доступа; эти свойства задаются контрактом обёртки и проверками Consumer.
[EN]
These cases apply [unified admission](#admission); they are not fourteen separate type systems.

### 1. One receiving expression for multiple data shapes

Consumer requires the paths it uses, not a nominal type for the entire Structure.

### 2. Knowing what a particular site checks

The first part checks structural suitability for actual Consumer accesses; the second, analytical part `test`, checks the stated behavior. Unknown coverage is not proof.

### 3. Distinguishing meanings with the same representation

Express a semantic distinction through a used path and, where leaf values matter, a test; a type name alone proves no equality of values.

### 4. Constraining a scalar leaf

A `width` field does not establish `width = 32`; Consumer's test states the check of the concrete number.

### 5. Making a change visible to other reference holders

An explicit path write changes the addressed shared referent; assignment to an argument or another own local variable changes only the current activation's place, without write-back; a name bound as the caller's place denotes the caller's place, and a write into it takes effect at once ([own place and caller's place](#binding-places)). [Call frame](#call-frame-20261115).

### 6. Independence from another holder's mutation

Ordinary Structure or Array passing transports a reference. Explicit copying creates an independent mutable copy; immutability prohibits mutation of the protected value.

### 7. Establishing that a call can proceed

Besides a suitable callable interface, the call needs a source for each of its free (dynamic) inputs. Ordinary declared inputs are optional unless input `required` or another applicable contract rules out omission: an input without a value, to which no value is supplied, does not make the call refuse: [autofill](#binding-autofill) fills it, and where that is inapplicable it holds "T without initialization" (the author's decision of 2026-11-16); the receiver [`required`](#required-receiver) checks that a field is initialized.

### 8. Checking a transported callable

Transporting a callable neither executes it nor proves suitability for every future call; each concrete call has its own admission.

### 9. Changing a method body without breaking calls

A new free dynamic input changes the method interface and requires affected calls to be checked; an unchanged signature alone does not guarantee unchanged behavior.

### 10. Selecting the intended part of a composition

`merge` composes only its explicit sources: a compatible later field replaces the corresponding first-source model slot, and a new field appends. It emits the resulting fields as a stream; grouping obtains one Structure. The destination is not an implicit model.

### 11. Changing an existing Structure

A Structure uses common variable-array resizing: sys\resize changes length and, when necessary, storage; the descriptor address stays stable. Raw addresses into old storage are not repaired automatically; an L3 element reference holds the descriptor and index.

### 12. Reliable numeric conversion

A converter respects the destination range: `u16(256) → u8` is no silent wraparound. Refusal follows ordinary failure handling.

### 13. What a broad converter table provides

Additional converters extend available explicit leaf conversions but do not change required paths or callable interfaces.

### 14. Foreign-resource validity

A thin handle does not prove resource validity or authority; its wrapper contract and Consumer checks state those properties.
@@ construction | Построение значений | Value construction | 9.1–9.2; 19.20
[RU]
Исходная запись строит полный граф записанных форм: объявления, значения и исполняемые выражения остаются вместе. **Все ресиверы остаются такими, как записаны. Все вычисления и преобразования происходят в namespace.** Терминальные примитивные объявления входят в это полное отражение в своей прямой форме `{type value}`, а имена — в обычной таблице имён. Неинициализированный примитив содержит свой код `uninit:T` и нулевые байты значения; ячейка T не резервируется. Вычисляемая правая часть (RHS) не является терминальной и не сворачивается запуском программы. Запись модификатора, вызова, `import`, `copy` или `merge` в исходном графе не заменяется своим результатом. Копирование может строить новые узлы результата по [контракту копирования графа](#composition), а явные записи программы сохраняют собственный контракт мутации графа.

Обычные отступы и явные хвосты закрывают формы в соответствии с [грамматикой](LMX_grammar.ru.md#levels). Пустая физическая строка вне экранированного содержимого закрывает **все** открытые вертикальные и короткие формы до корня текущего документа как терминатор на виртуальном уровне −1. Её отступ не имеет значения; одиночный перевод строки между непустыми строками не является этим событием. Корень сохраняется, и последующие формы начинаются от него. Пустая строка не создаёт поля, пустой Structure, исполняемой инструкции или return; она не синтезирует недостающие парные разделители. Внутри Mix она закрывает блок локального документа Mix, а не окружающий документ или его `}`. EOF по-прежнему закрывает завершённый обычный блок. Генерируемый исходный код должен ставить пустые строки только на предназначенных полных границах.

Построение описания тела не исполняет его. Именованная Structure объявляется в контексте данных; форма с головой в коде вызывает свою разрешённую голову. Анонимное тело исполняется только по своему принимающему контракту. Лексическое родительство следует за записанной структурой и явными правилами копирования и квалификации, независимо от владения хранилищем. Не создаются ни скрытая процедура, ни второй авторитетный граф, ни постоянный namespace. Имена и сохранённые комментарии следуют [§4](#fields); комментарии не исполняются.

### Разрешение головы и роль хвоста

Ресивер применяет свой объявленный контракт к записанному хвосту: он может объявить место, описать сигнатуру, потребить тело кода или выдать значение либо поток полей. Один только синтаксис Frame не определяет эти роли. Имя, потреблённое как имя, не вызывается: `catch: merge ()` задаёт имя отказа и описание параметра, а `fn: SumSignature (int: a; int: b; return: int)` задаёт имя сигнатуры и шаблон данных. Оба используют общий механизм разбора и разрешения.

<a id="resolved-head-consumption"></a>
#### Одна модель, одно разрешение, одно потребление

Сначала в памяти транслятора целиком формируется записанная структурная модель «голова — аргументы», без знания того, чем является голова. Ни имя, ни сигнатура, ни категория сущности не определяют границы этой модели и не позволяют собирать дополнительные аргументы. Только после её формирования запись читается по роли Structure в запуске ([роли `data` и `code`](#data-code-roles)) и по разрешённому контракту ресивера. Обычная форма DATA объявляет Structure; ресивер объявления места объявляет место. Форма CODE с головой — это вызов. Ресиверы вроде `import`, `copy` и `merge` сохраняют собственные контракты аргументов и потока полей, когда их записи написаны в DATA. Во всех случаях общий алгоритм разрешения в едином пространстве имён находит голову: ресивер, вызываемое или Structure. Значение в известное место такая форма не записывает ([структурные формы](#forms-declare-or-call)). Один общий механизм потребления применяет контракт разрешённой сущности; различие контрактов не создаёт отдельных разборщиков, пространств имён или маршрутов разрешения.

<a id="data-code-roles"></a>
### Роли `data` и `code`

DATA и CODE называют семантические роли, а не новые ключевые слова или постоянные виды Structure. Для выбранной исполняемой Structure `C` CODE — это `C`, а DATA — её фактический `parent(C)`, если он есть. `call(C)` и `C()` исполняют это вхождение без явных фактических аргументов; `call(A C)` и вызов по имени с теми же выбранными фактическими аргументами исполняют его с аргументами `A`. Вызов не может подменить другую DATA. R0 — это вход без DATA и пользовательских фактических аргументов ([структурный вызов](#call-receivers), [корневой вход](#root-entry)).

В DATA обычная форма с головой объявляет Structure с записанным содержимым. Так, `S()` объявляет пустую `S`, `S(D)` содержит атом ссылки `D`, а запись `if:` остаётся Structure, адресуемой через свою голову. Ресиверы объявления мест, такие как `int` и `@`, вместо этого объявляют свои места через namespace. Присваивание `:=` сохраняется как исходный материал и не исполняется лишь потому, что оно встретилось в DATA. Повторные объявления в DATA остаются отдельными вхождениями; применяются обычные правила повторного объявления и выбора вхождения.

В CODE форма с головой применяет свою разрешённую голову. `S(args)`, `S: args` и её вертикальная форма исполняют `S` с выбранными фактическими аргументами; они не присваивают `S` и не объявляют новую Structure. Ресивер объявления, такой как `int: i 6`, устанавливает или обновляет своё логическое место по контракту ресивера. Числовая или нулевая голова не вызываема. Вызов, используемый ради значения, должен иметь допущенный результат, описанный полем `return` в своих фактических DATA. Голое `S` — это ссылка, и оно не вызывает её.

Эти правила ролей применяются разрешённым принимающим контрактом. В частности, [ресивер объявления места, поданный как аргумент CODE](#declaration-arguments), читается как DATA и сохраняет свою форму. Это не превращает обычные `Producer()` или `Producer: tail` в объявление: их голова — обычное вызываемое, и они остаются вызовами CODE.

`import`, `copy` и `merge` всегда потребляют стандартные аргументы CODE через общий алгоритм транслятора, независимо от того, встречаются ли их записи ресиверов в DATA или в CODE. Обычный выбор W/E применяется везде, где потребляются эти аргументы. Голая ссылка на Structure или анонимная Structure, поданная как источник, сама по себе не является вызовом. Содержимое может включать вызовы или инициализаторы, управляемые их обычными потребляющими контрактами; группа не превращает их в цитаты и не заставляет их все выполниться заранее. Явный `Producer()` является вызовом, когда этот ресивер потребляется. Их выбранные или вычисляемые поля потребляются через namespace; исходные формы остаются нетронутыми. Например, DATA `Struct: merge(A B)` — это обычное объявление `Struct`, содержащее запись ресивера; `merge` поставляет поток полей для этого чтения DATA. Объявление делается через `Struct:`, а не особым синтаксисом объявления merge. Несколько таких операций независимы, и `Struct` никогда не является неявным источником merge или моделью ([композиция](#composition), [import](#import-receiver)).

<a id="data-root-declaration-execution"></a>
#### Прямой проход по данным и выполнение ресивера

Подготовка namespace интерпретирует корневые объявления DATA и CODE, не исполняя все вычисляемые инициализаторы. Модификаторы `private`, `required`, `const`, `immutable` и `independent` применяют свои контракты через тот же механизм; объявления, которые они отмечают, считаются корневыми объявлениями там, где так говорят обычные правила DATA. Одного физического родительства недостаточно для этого семантического корневого статуса. Записи модификаторов остаются в исходном графе, поэтому явный путь всё равно проходит через них, например `S\private\x`.

`import`, `copy` и `merge` участвуют через обычное потребление потока полей с тем же стандартным контрактом исходного аргумента CODE в любом размещении. Когда такой ресивер действительно потребляется, явный исходный вызов вычисляется по этому контракту. P0, инспекция namespace/сигнатуры и следование по явному исходному пути не исполняют ресивер или его аргументы досрочно. Это не разрешает общего рекурсивного прохода исполнения через вложенные тела или цели ссылок. Достигнутый ресивер может исполнить поданное тело, когда того требует его контракт; одна лишь подготовка или передача вычисляемого объявления места не исполняет его правую часть (RHS).

Терминальные примитивные объявления могут быть представлены непосредственно как типизированные значения. Каждый другой ресивер, записанная группа и порядок исходного кода остаются такими, как записаны, в том числе после того, как результат их DATA получен через namespace. Ни построение namespace, ни исполнение не сериализуют преобразованный заменяющий граф поверх исходного.

#### Анонимные Structure и позиции значений

Безымянная Structure не имеет головы и не является вызовом с аргументами. Как самостоятельное тело CODE она исполняет свои записанные записи в текущей активации, с обычной вложенной видимостью. Как значение или аргумент она остаётся записанной Structure, чтение которой определяет её потребитель. Числовой потребитель может читать группу как выражение; потребитель DATA читает её как данные; потребитель тела исполняет её. P0 не удаляет группу только потому, что в ней ноль или одно поле. Анонимная Structure может содержать вызовы или инициализаторы; одна лишь её граница не подавляет их и не исполняет их все досрочно.

```lmx
Holder:
    return: int
    anon:
        int: r 0
        ---
            int: q 4
            r := q
        ---
        return: r
```

`Holder\anon()` возвращает 4: безымянный блок исполняется в этой активации. Самостоятельное `()` ничего не делает. Слева от `:=` безымянная Structure является последовательностью мест для [группового присваивания](#group-assign).

Присваивание обновляет разрешённые места примитивов или переменных-ссылок. Имена структурных объявлений являются константными связываниями и не являются присваиваемыми переменными: `Model := KnownStruct` недопустимо, когда `Model` называет Structure. `@: ptr KnownStruct` объявляет переменную-ссылку; `ptr := Other` может её обновить. `Model: KnownStruct` в DATA содержит атом ссылки без копирования или смены родителя `KnownStruct`; в CODE оно вызывает `Model` ([двоеточие объявляет](#colon-declares)).

Входные места и умолчания принадлежат `parent(C)`; `args` в `call` — это поданный материал аргументов, а не ещё одна часть описания формалов. Поле `return` в DATA описывает результат, не присваивая его. `fn: name data` создаёт именованное описание сигнатуры, а не код. Удалённый отдельный параметр DATA, исполняемые `fn`, `sub` и `fncall` не имеют текущего встроенного смысла ([примечание о миграции](#removed-builtins)).

<a id="receiver-args-only"></a>
### Объявление места: ресивер и его аргументы

Место с требованием объявляется собственной формой аргументов ресивера: `int: i 5`, `int: x`, `@: ptr 0`, `@: ptr Model`. Его первый аргумент называет место; примитивный ресивер без значения объявляет типизированное отсутствие, а соответствующая форма проверки значения может проверить примитивный литерал. P0 строит те же обычные Frame; арность и роли полей берутся из разрешённого ресивера.

Составная форма `name: receiver: value` не объявляет переменную с именем внешней головы. В DATA `timeout: ms: int: time 500` объявляет timeout, содержащий ms, содержащий примитив time; его путь — `timeout\ms\time`. В CODE та же внешняя форма вызывает timeout. Аналогично `i: int: 5` в DATA — это Structure i, содержащая форму ресивера, а не переменная int i; в CODE она применяет i и недопустима, если i — не вызываемое числовое место. Объявление примитива или ссылки делается через их ресивер, а не заменой родителя этого ресивера. `:=` присваивает существующее место; оно не объявляет его.

Голый атом не добавляет ненаписанный вызов ресивера или callable. Если разрешённое поле содержит вычисляемое объявление, явный путь читает запись объявления и ничего не исполняет ([явный путь](#path-reads-no-execution)); написанное выражение исполняет вызов, читая своё локальное место по голому имени, и это не вызов возвращённого callable без аргументов. Выражение формируется и вычисляется одним способом независимо от того, будет ли его результат потреблён; запись в место возникает у непотреблённой объявляющей формы, а не из особого разбора правого операнда. Так, `Model: 0`, потреблённое другим выражением, `Model` не меняет: в аргументах это вызов `Model` — прежде оно давало кандидата с требованием `Model`, теперь требование и кандидат записываются плоско, `@: ptr Model 0` ([роли `data` и `code`](#data-code-roles)); если `Model` — Structure, это её вызов с аргументом `0`, и на месте, где нужно значение (операнд выражения, фактический аргумент вызова, начальное значение, операнд `merge`), он даёт значение, только если данные `Model` описывают результат полем `return` ([`return` в DATA](#return-in-data)); отдельным оператором `Model: 0` всё равно вызывает выбранную Structure по её обычному контракту аргументов и отбрасывает любой непотреблённый результат. Если `Model` вместо этого — не вызываемое примитивное место, форма является ошибкой; ни в одном из этих случаев двоеточие не присваивает ([структурные формы](#forms-declare-or-call)).

Двухполевое `int: x 5` объявляет место `x` с требованием `int` и значением `5`: в данных оно создаёт место, в коде это вызов ресивера — проверка типа с присваиванием локальному месту `x` namespace ([роли `data` и `code`](#data-code-roles)). Однополевое `int: x` описывает место `x` с требованием `int` без придуманного начального значения: при первом определении место создаётся; при уже известном `x` та же запись в коде проверяет его совместимость общим допуском без новой записи или второго поля, а в данных остаётся ещё одним вхождением имени, которое после этого адресуется только с индексом вхождения. Место графа без инициализации содержит только отдельный код типа `uninit:int` с `sizeof(value) = 0`, а не зарезервированную int-ячейку, числовой ноль или внешнюю метку инициализации; для каждого примитива есть такой тип, одинаково в коде, данных и сигнатуре, где он отличает формал без умолчания `int: q` от умолчания `int: q 0`: такой формал не обязателен — вход без значения, которому не подано значение, вызову не отказывает: его заполняет [автозаполнение](#binding-autofill), а где оно неприменимо, он держит этот тип (решение автора 2026-11-16), а инициализацию данного поля проверяет ресивер [`required`](#required-receiver); последнее [авторское уточнение](tasks/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md) уточняет, что явное присваивание в граф (`D\a := 5`) заменяет фрагмент в этом структурном месте: `{uninit_int}` становится `{int 5}`. Оно не переписывает метку типа у заранее выделенной T-ячейки, не требует расширения на месте и не сохраняет адрес сырой полезной нагрузки при замене ([L2 §3.1](L2_spec_ru.md#uninit-record-control)). Присваивание локалу вызова — `a := 5` для формала, которому не подано значение, — пишет в место вызова: граф не меняется и данные не публикуются. Отсутствие значения записывается как значение этого отдельного типа: `nil: T` (`nil: int`; вместо `int` — любой другой примитивный тип), а где возможно — просто `nil`. `int: var` объявляет переменную без инициализации, и для этого есть отдельный тип; он вводился для передачи аргументов и остаётся нужен при `required`. Переменную можно сравнить с `nil` по её состоянию отсутствия; числовой сентинел и мнимые байты значения не вводятся. В графе нет ничего, кроме Structure и примитивов: примитив — объявление типа со значением либо с отсутствием значения, всё остальное записано Structure. Нулевой указатель остаётся `0`, где это можно; указатель, объявленный без значения (`@: ptr`), нулём не является и записывается тем же `nil` (решение автора 2026-11-17). Одноаргументная форма есть у каждого ресивера, который прежде писался без аргументов на месте типа: вместо `i: int` пишется `int: i` (решение автора 2026-11-10). При уже объявленном `i` запись `int: i` в коде — не ошибка, а проверка соответствия типа: повторные объявления разрешены. Одноаргументная форма с самим примитивом вместо имени, `int: 54554878477838734`, в выражении возвращает число либо выбрасывает отказ, который принимает `catch`. В сигнатуре эти формы описывают формал, а записанное значение служит умолчанием при отсутствии фактического аргумента; описание формала не исполняется как тело. Это один механизм для примитивов, ссылок, Structure и callable, без отдельной ветки парсера по имени ресивера. Построенный исходный граф фиксирует свои физические элементы, пока явная операция над графом их не изменит. Логические места namespace и видимость по голому имени следуют за последовательными объявлениями, лексическими областями и явным потреблением потока ресивера; достижение ветки не добавляет скрытый элемент в исходный `Lmx`.

У встроенных ресиверов значения и типа, включая `int` и `@`, объявляющий контракт — `R: name value`: первое поле — атом имени принимающего места, второе — выражение значения или требования, а у `@` с требованием необязательное третье поле — кандидат (`@: ptr Model Other`); без второго поля место объявляется без начального значения. Арность и роль полей задаёт контракт разрешённого ресивера после P0; парсер не выделяет этот класс и не меняет дерево, а другие ресиверы сохраняют собственные контракты аргументов. Атом имени не вызывается и не вычисляется как значение: место разрешается в том же пространстве имён, что голова Frame. Кандидат вычисляется один раз до записи, проходит обычный допуск, затем место впервые определяется либо, если оно уже известно, в коде получает значение как повторное объявление: перечисление аргументов ресивера остаётся его делом и всегда может быть объявлением — `@: ptr1 ptr2` может объявлять `ptr1` (уточнение автора 2026-11-10, [структурные формы](#forms-declare-or-call)); в данных повторное объявление в прежнее место не пишет и остаётся ещё одним вхождением имени ([роли `data` и `code`](#data-code-roles)). Потребление всей формы другим выражением само по себе не публикует поле и не выполняет запись. `@: new_field Model` связывает ссылку на `Model`, не требуя префиксного взятия адреса.

Требование и кандидат записываются плоско: в `@: ptr Model Other` у `@` три поля — атом места `ptr`, требование `Model` и кандидат `Other`; нулевой адрес даёт `@: ptr Model 0`. Вложенная форма `@: ptr Model: Other` для этого не служит: аргументы ресивера читаются как код, и `Model: Other` в них — вызов `Model` с аргументом `Other` (решение 2026-11-11, [роли `data` и `code`](#data-code-roles)), а не требование с кандидатом; прежде потреблённый `Model: Other` давал кандидата `Other` с требованием `Model`. Допуск кандидата не записывает в `Model` и не создаёт адресуемой временной ячейки. После допуска форма строит ссылочное значение и связывает `ptr` по общему правилу; кандидат вычисляется один раз до записи. Если `ptr` callable, форма ресивера `@` обозначает место связывания `ptr` и подчиняется ограничениям записи в него, а запись `ptr: @: Model Other` в коде — вызов `ptr` с аргументом.

В позиции вычисления голый идентификатор проходит тот же поток разрешения, но сам не образует вызов и не передаёт пустой список аргументов. Он обозначает разрешённое значение, ссылку на Structure или callable либо имя ресивера по контракту принимающей позиции; голые `merge` и `int` также не исполняются. Если позиция требует значения, которого обозначенная сущность не предоставляет, это ошибка, а не скрытый нульарный вызов или свободный вход. Для применения разрешённой головы нужен явный Frame с `()` либо `:` и структурным хвостом, в том числе пустым; роль этого Frame по-прежнему определяет контракт головы. Исполнение именованной Structure записывается ресивером `call: A` или, в коде, записью с её именем в голове, `A()` или `A(args)` ([роли `data` и `code`](#data-code-roles)). Соседние атомы не захватываются. В `if: p` голое `p` только читается: даже если оно указывает на метод, метод не вызывается. Допустимость самого значения `p` как условия этим правилом не определяется.


<a id="colon-declares"></a>
В DATA обычная запись `Name: tail` объявляет Structure, содержимым которой является этот хвост. `Struct1: Struct2` содержит один ссылочный атом на существующую Struct2: она не делает два имени равными и не копирует и не раскрывает поля Struct2. Её родитель не меняется, поэтому путь, такой как `Struct1\Struct2\a`, достигает исходной цели. В `Struct1: (Struct2 a b c)` записанная группа остаётся одной анонимной Structure; её собственное a и a, достигаемое через Struct2, — различные поля. Циклические ссылки, такие как `A: B` и `B: A`, не раскрываются бесконечно. Нераспознанный атом остаётся словом.

Структурное имя — это константное связывание. `Struct1 := Struct2` не переприсваивает его. Изменяемая ссылка вместо этого объявляется записью `@: ptr Model`, может явно получить null записью `@: ptr Model 0` и позже обновляется записью `ptr := Other`. Физический элемент атома остаётся доступным обычными индексными операциями графа; это не делает его голое имя присваиваемой переменной. Повторение объявления в DATA сохраняет ещё одно вхождение и требует обычного выбора вхождения. В CODE соответствующая запись `Name: tail` или `Name(args)` является вызовом, а не объявлением или присваиванием. Передача по ссылке не переназначает родителя её цели и не захватывает её вызывающего.

В данных структурная форма объявляет Structure, хвост — её содержимое: `A(int: x 1)` и `A: int: x 1` объявляют `A` с полем `x`. Пустые `A()` и `A:` объявляют Structure без полей. `A: ()` объявляет `A`, внутри которой одна пустая безымянная Structure, а `A: (int: x 1)` — `A`, внутри которой безымянная Structure с полем `x`: единственную Structure в хвосте P0 не раскрывает ([значения](#values)). Голое `A` читает ссылку на уже выбранную обычную Structure. Если `A` уже объявлена на этом уровне, повторная структурная форма, включая пустую, — повторное объявление, а не присваивание: ещё одно вхождение имени `A`, которое после этого адресуется только с индексом вхождения; в данных вызова прежней `A` нет. В исполняемом коде описания Structure нет — такая запись там вызов своей головы; собственная область возникает при вызове Structure — явным `call` или записью `A()`. Inline-операторы `if`/`for` остаются в той же активации. Именованные Structure и callable видны в обе стороны; переменные, включая const, — последовательно от первоначального объявления в своём блоке и ниже. Корневые входы data доступны исполняемому code; подготовка namespace не открывает будущие локалы code и не вычисляет инициализаторы ([видимость](#declaration-visibility), [кадры вызова](#call-frame-20261115)). Форма с путём в голове, `Outer\Model()` или `Outer\Model:`, в коде — вызов того, что стоит по этому пути; голый `Outer\Model` читает ссылку без вызова. Для исполнения выбранной обычной Structure служит `call: Outer\Model` или, в коде, запись `Outer\Model()`.

<a id="ordinary-var"></a>
### Имя `data`

Имя `data` — обычное пользовательское имя и описательное имя семантической роли. Оно не является неявной ссылкой на DATA вызова и не может перепривязать этот DATA. Выбранный код C использует фактический `parent(C)`; явный путь `D\x` адресует эту известную Structure, тогда как `node\x` явно выбирает установленный лексический контекст. Эти выражения не взаимозаменяемы лишь потому, что ресивер в данный момент читает DATA. Если объявлена переменная с именем data, то `data := ptr` имеет только своё обычное значение присваивания. Форма с головой `data(...)` подчиняется тем же правилам ролей, что и любая другая пользовательская голова:

| Где стоит запись `data(...)` | Действие |
| --- | --- |
| В данных, имя ещё не объявлено | Объявить обычную Structure `data` с записанным содержимым. |
| В данных, имя уже объявлено | Повторное объявление: ещё одно вхождение имени, которое после этого адресуется с индексом вхождения; это не замена и не присваивание. |
| В коде | Вызов головы по общим правилам ([структурный вызов](#call-receivers)): если `data` называет Structure, она исполняется; если голова ничего не называет, запись ошибочна. |

Историческое примечание: прежние спецификации использовали зарезервированную ссылку data и допускали отдельный аргумент DATA у вызова. Оба положения отменены. Миграция должна выбрать фактическое структурное вхождение и его родителя; восстановить прежнее поведение переименованием переменной она не может.

В данных последовательность `data(int: x 2); data(int: x 5)` — два объявления: два вхождения имени `data`, каждое со своим содержимым; второе первого не заменяет и в него не пишет. Объявление, первое или повторное, само по себе не исполняет содержимое Structure: её исполнение задаёт запуск — явный `call` или, в коде, запись с именем этой Structure в голове, `A()` либо `A(args)`. В исполняемом `code` имя `data` пользуется общими правилами имён и мест, без особого алгоритма.

В этой главе DATA называет роль фактического `parent(C)`, тогда как пользовательское имя `data` следует обычному разрешению. Отдельного аргумента данных у `call` нет: `call(C)` и `call(A C)` исполняют выбранную `C` над `parent(C)`, а `A` — её фактические аргументы ([структурный вызов](#call-receivers)). Вызов создаёт локальный namespace, не дописывая в исходный граф места code. Обычную Structure в коде запускает и запись с её именем в голове — `A()` и `A(args)`; это самостоятельная запись, а не форма ресивера, и её аргументы подаются по общим правилам ([структурные формы](#forms-declare-or-call)). Запись `data(...)` в данных объявляет Structure по тем же правилам, что и любое другое объявление; содержимое Structure этим не запускается. Голый атом `data`, как и любой голый атом, лишь называет то, что стоит под этим именем, и ничего не вызывает, в том числе когда на его месте ссылка на метод.

Если `put` уже определена как вызываемая Structure, следующее объявление `Batch`, записанное в данных, сохраняет тело с оператором `put: 7`, не исполняя его. Пример записан формами нормы 2026-11-19: вход `n` и результат — поле `return` — описаны в данных `Context`, код `put` — вложенная Structure, а `Batch` лежит рядом с ней:

```text
Context:
    int: n
    return: int
    put:
        return: n
    Batch(put: 7)
```

Это обычный оператор в полном бинарном дереве, не отдельное значение «сохранённый вызов», скрытое замыкание или второй граф. При исполнении Batch достижение оператора put подчиняется обычному вызову. Наличие нативной реализации Batch выбирает её, отсутствие — обход сохранённого тела в допустимом профиле; само отсутствие нативной реализации не делает дерево потерянным или неисполняемым.


Последующее чтение имени не меняет задним числом роль уже записанной головы. В следующем примере у `f` нет входа `x` в данных `F`, видимого внешнего значения или ранее установленного свободного входа `x`: запись `x: j` стоит в коде, поэтому она — вызов `x`, а не присваивание примитиву и не объявление Structure; голова `x` не называет ни вызываемого, ни Structure, и запись ошибочна ([роли `data` и `code`](#data-code-roles)). Прежде она определяла именованную Structure, и ошибочным был `return: x`. Одноимённое значение вызывающего не меняет эту классификацию. Пример записан формами нормы 2026-11-19: результат описывает поле `return` данных `F`, код — вложенная Structure `f`.

```text
F:
    return: int
    f:
        int: j 3
        x: j
        return: x
```

Свободный вход — это свободное значение, которое используется вызываемым без объявления его явным формалом; его установление и выбор источника следуют [§12](#dynamic). Этот термин не вводит ни дополнительной Structure, ни отдельного постоянного контекстного графа. Обходчик разрешает достигнутые имена через общее временное namespace, а подготовленный нативный код использует соответствующие выбранные места и скрытые аргументы; ни один из этих путей не создаёт второго хранилища имён.

<a id="explicit-copy"></a>
### Явное копирование и указатели-переменные

Ресивер ссылки использует обычные объявляющие формы. `@: ptr` создаёт неинициализированное место ссылки; `@: ptr 0` задаёт null. `@: ptr Model` сохраняет ссылку на Model, а `@: ptr Model Other` явно задаёт требование и кандидата. Требование и кандидат — плоские аргументы. В позиции чтения CODE вложенная запись `Model: Other` является обычным вызовом, который должен давать допущенный результат, если требуется значение; это не альтернативная запись требования и кандидата. Позиции чтения DATA и передаваемого объявления сохраняют собственные контракты.

Повторное объявление на том же уровне CODE без нового кандидата проверяет существующее место, не очищая его значение. Поданный кандидат проходит обычное преобразование/допуск перед записью. Присваивание адреса задним числом не задаёт тип уже объявленного места void-ссылки. Внешняя форма `ptr: @: Model` вместо этого объявляет Structure в DATA или вызывает ptr в CODE; это не объявление переменной-ссылки. Это контракты ресивера, разрешаемые после общего парсера.

Явные [copy и merge](#composition) порождают потоки полей. `copy(A)` имеет один допущенный источник; `merge(A C)` — по меньшей мере два. Чтобы сохранить одно структурное значение в переменной-ссылке, запишите `@: b (copy(A))` или `@: b (merge(A C))`; присваивание существующей ссылке аналогично использует `b := (merge(A C))`. Приёмник никогда не бывает источником или моделью. Без группы RHS остаётся потоком, а его допустимость определяется контрактом приёма; он не становится автоматически одним контейнером и не является синтаксической ошибкой во всех случаях.

В DATA `b: merge(A C)` обычно объявляет `b`, а заключённый в скобки ресивер поставляет поля через это namespace DATA. В CODE та же внешняя форма вызывает `b` с потоком, поставляемым `merge`. Голый атом `merge` не захватывает соседних полей: `b: merge A C` — не то же самое применение. Обычные ссылки и неизвестные имена не запускают неявного копирования. Сгруппированный результат сохраняет записанную границу, хотя последующий вызов в CODE может всё ещё рассматривать W и E в рамках [обычного выбора](#declaration-selection).

Ресивер `@:` принимает имя места своим первым полем; новое место и запись в уже существующее проходят один resolver и обычный [допуск](#admission). В сигнатуре тот же ресивер описывает требование к входу. Место кандидата определяется общим разрешением; после допуска обращения используют полученные адреса и карты, без повторного поиска имени по тексту. Известный указатель на метод `b` вызывается записью `b: args`, `b(args)` или `(\b)(args)`; `\b(args)` разыменовывает результат вызова по общему приоритету. Унарное `@b` отдельно адресует ячейку ссылки.

<a id="method-reference-assignment"></a>
Ссылка на метод присваивается через `@`, который стоит первым: `@: ptr method`. Первый аргумент `ptr` — атом имени места; второй, `method`, — атом, обозначающий значение метода. **Голый атом не является вызовом**, поэтому ни `ptr`, ни `method` здесь не вызываются. Ресивер `@` получает эти аргументы по своему двухполевому контракту: при первом определении создаётся ссылочное место, при уже объявленном — в коде после допуска присваивается новое значение в то же место, а в данных повторное объявление остаётся ещё одним вхождением имени ([имена и пути](#fields)). `@: ptr 0` аналогично передаёт явный нулевой кандидат. У `ptr(args)` или `ptr: args`, напротив, есть явное применение callable к аргументам; если `ptr` держит ссылку на обычную Structure, те же записи запускают её по формам запуска Structure ([структурные формы](#forms-declare-or-call)). Запись `ptr: @: method` присваиванием не является, каким бы ни был `ptr`: в коде она — вызов `ptr`, в данных — объявление Structure `ptr` ([роли `data` и `code`](#data-code-roles)); `@` во вложенном аргументе этого не меняет, и для присваивания служит форма `@: ptr method`.

Унарное `@ptr` выбирает адрес ячейки переменной ptr, отличный от её хранимой ссылки на цель; оно не является присваиванием `@: ptr method` и не подменяет хранимую ссылку на метод адресом её ячейки. Явно поданный аргумент, автозаполненное значение и значение прежнего связывания (запасного пути) имеют собственные локальные ячейки активации: `@x` адресует ту же локальную переменную, которую читает и меняет голое `x`. Там, где выбранный уровень допускает разыменование этого числового адреса, после локального `x := 9` чтение `\(@x)` даёт `9`; запись через этот адрес меняет собственную ячейку, а не источник связывания ([собственное место](#binding-places), [автозаполнение](#binding-autofill), [прежнее связывание](#binding-fallback)). Если имя связано как прозрачное место вызывающего ([место вызывающего](#binding-caller-place)), то `x`, `x := 9` и `@x` действуют на это место сразу: `@x` — адрес места вызывающего, а запись видна вызывающему без копирования обратно. Внешнее место адресуется явно, например `@(node\x)`. Взятие адреса не продлевает срок жизни ячейки; ссылка на объект и ячейка переменной, содержащая её, различны.

Преобразование кандидата и его допуск следуют контракту приёма; хранимая ссылка меняется только после успешного приёма. Обычные значения Structure и метода уже передаются по ссылке: `@: ptr Struct` сохраняет эту обычную ссылку, не вызывая `Struct`. Префикс `@Struct` явно получает его числовой адрес, как в `int: value 1 + @Struct`, где числовые адреса допускаются профилем; его не требуется, чтобы передать `Struct`, и оно не подавляет роль оператора. Префикс `@x` у переменной выбирает реальную логическую ячейку переменной, выбранную связыванием, включая ячейку вызывающего для прозрачного связывания. Он не должен случайно адресовать только объект, хранимый в переменной-ссылке, или транспортную ABI-ячейку. Операции над машинными адресами сохраняют применимый [контракт L2](L2_spec_ru.md#lowlevel-address). Взятие адреса не продлевает срок жизни, а разыменование `\` следует за допущенным адресом/ссылкой без выполнения кода.

### Сигнатура не исполняется

Именованная сигнатура `fn: name data` описывает упорядоченные типы входов и при наличии результата — поле `return`; записанные в ней формы не исполняются как тело вызываемого. Оба аргумента `fn` читаются в роли данных, и его вложенные записи только описывают ([сигнатура `fn`](#fn-signature)); так же устроено описание входов в данных вызываемой Structure ([структурный вызов](#call-receivers)). Входные места описываются объявлениями ресиверами. Для непримитивного `A` формал с требованием `A` записывается `@: p A`, допускает кандидата через `implements(c, A, Consumer)` и передаёт ссылку на дескриптор без копирования или неявного `merge`. Требования значения и ссылки записываются теми же формами ресивера, что в теле, но описание формала не присваивает место при построении вызываемого. Если в описании записано значение, оно является умолчанием, а не результатом исполнения тела.

Для структурного `c`, `mytest(c)` передаёт обычную ссылку, тогда как `mytest(@c)` явно получает адрес по контракту префикса-@; это не взаимозаменяемые аргументы. Лишний уровень не снимается ради формала. Это одинаково для Structure, указателя-переменной и непримитивного формала; адресуется собственное языковое хранилище, не транспортная ABI-ячейка. Примитивное значение и ссылка на его ячейку также не синонимы. Передача и возврат непримитивов не используют C by-value aggregate.

### Присваивание и места объявления

В коде повторное объявление уже объявленной на том же уровне переменной сохраняет проверку типа, вычисление RHS и присваивание, но не создаёт вторую C-переменную. В `int: i 5; int: i 6` исполняемые действия используют одно локальное место. Обе написанные записи остаются в исходном графе; локальное исполнение их не перезаписывает. В данных повторное объявление остаётся отдельным вхождением имени и выбирается индексом. Новые имена ветви видны внутри неё и ниже; повторная форма на том же уровне использует существующее место, а объявление на вложенном уровне затеняет внешнее одноимённое ([уровни объявлений](#shadowing-levels)). Структурная форма `name:...` в коде вызывает голову; для записи значения без объявления служит `:=`.


Входы вызываемой Structure — объявленные места её данных — и собственные переменные code — локальные места активации: присваивание им не пишет в исходный граф и не пишет вызывающему — ни явно поданное значение, ни автозаполненное, ни копия прежнего связывания не являются псевдонимом источника ([собственное место](#binding-places), [прежнее связывание](#binding-fallback)). Иначе у внешнего имени без собственного объявления: если оно связано как прозрачное место вызывающего, присваивание действует на место вызывающего сразу, без копирования обратно ([место вызывающего](#binding-caller-place)). Оператор объявления остаётся в code. Описание входов в данных не исполняет их вычисляемые инициализаторы при построении графа. См. [кадры](#call-frame-20261115).

<a id="forms-declare-or-call"></a>
#### Структурные формы объявляют или вызывают

Структурная форма с головой — в скобках, короткая или вертикальная — применяет тот же разрешённый контракт. Обычные формы DATA объявляют Structure; формы CODE вызывают свои головы; объявляющие ресиверы объявляют или обновляют свои места. Структурная форма не является присваиванием лишь потому, что её голова называет существующее место: `i: 6` не может обновить числовую переменную i. Используйте `i := 6` или достигнутое объявление ресивера того же уровня, например `int: i 6`. Последнее сохраняет проверку типа, вычисление RHS и присваивание, не создавая второго логического места.

Входы корневого DATA доступны выбранному CODE; переменные и константы CODE сохраняют последовательную видимость. Настоящие вложенные объявления затеняют внешние места. Исходный граф сохраняет оба записанных вхождения ресивера, а локальные переменные CODE не становятся полями исходного DATA. P0 не классифицирует голову и не придумывает другого дерева для реализации этих правил.

В CODE `A()`, `A(args)`, `A: args` и соответствующая вертикальная форма запускают разрешённую Structure A. Они используют фактический `parent(A)` как DATA и обычный выбор явных фактических аргументов. Неизвестная, числовая или null-голова не может использоваться как обычный вызываемый. `call(A)` и `call(X A)` — явные формы ресивера с теми же выбранными фактическими аргументами; ресивер не выбирает дочернее тело автоматически. В DATA `A()` объявляет пустую A, а `A(args)` объявляет своё записанное содержимое, не вызывая прежнюю A. Один записанный фактический аргумент Structure может иметь чтения W и E только по [контракту выбора вызова в CODE](#declaration-selection).

Повторные объявления разрешены. Исполнение повторного ресивера переменной сохраняет его действия, включая `bump()` в `int: x bump()`. Графовые объявления одноимённых полей не сливаются. Запись `Struct1: Struct2` в данных объявляет Structure с атомом-ссылкой на Struct2, а не копирует её поля; в коде вызывает голову Struct1. Форма `b(args)` вызывает то, на что указывает b, если это вызываемое или Structure. Число или пустая ссылка не становятся вызываемыми. Двоеточие не заменяет `:=`. Вызов не дописывает места в исходные данные и код: новые места code существуют в namespace вызова по [общему правилу](#call-frame-20261115).

<a id="assignment-inside-expression"></a>
### Выражения, присваивание и запрос

P0 — единственный парсер. Он сохраняет записанный граф голова/хвост, группы и порядок исходного текста; он не применяет приоритетов, не удаляет контейнеры и не переписывает `parent` и `length`. После разбора общий механизм выражений разрешает головы, приоритеты и зависимости в namespace. Записанный оператор является головой ресивера: `(1 + 2 + 3 + 4)` имеет соответствующую цепочку форм `plus`, тогда как `(+ 1 2 3 4)` и `(1 + 2 3 4)` содержат одно вариадическое применение. Обычная математическая форма `(+ 2 - 3)` даёт −1. Эти чтения не вводят парсера, специфичного для операторов.

Поддерживаемые операции имеют следующий относительный приоритет, от сильнейшего к слабейшему. Шкала общая для встроенных и пользовательских операндов; эти строки не задают числовых кодов приоритета.

| Уровень | Операции | Ассоциативность |
| --- | --- | --- |
| Постфиксный | вызов, индекс, доступ к полю, постфиксные `++` и `--` | слева направо |
| Унарный | префиксные `+`, `-`, `!`, `~`, `++`, `--`, существующие операции адреса | справа налево |
| Мультипликативный | `*`, `/`, `%` | слева направо |
| Аддитивный | `+`, `-` | слева направо |
| Сдвиг | `<<`, `>>` | слева направо |
| Отношения | `<`, `<=`, `>`, `>=` | слева направо |
| Равенство | `=`, `!=` | слева направо |
| Побитовое И | `&` | слева направо |
| Побитовое исключающее ИЛИ | `^` | слева направо |
| Побитовое ИЛИ | `\|` | слева направо |
| Логическое И | `&&` | слева направо |
| Логическое ИЛИ | `\|\|` | слева направо |
| Присваивание | `:=` и поддерживаемые составные присваивания, включая `**=` | справа налево |

Правило степени сохраняется: `**` группируется справа, связывается слабее вызова, индексации и доступа к полю, но сильнее умножения, сильнее унарных `+`, `-`, `~` слева от себя и допускает унарный операнд справа от себя. Так, `-2 ** 2` равно −4, `(-2) ** 2` равно 4, `2 ** -2` группируется как `2 ** (-2)`, а `2 ** 3 ** 2` равно 512. Допустимость числовых значений остаётся выбранным числовым контрактом LMX. `=` — это сравнение, соответствующее C `==`; `:=` — это присваивание. Запятые и точки с запятой сохраняют свои структурные роли. Условный оператор C и оператор-запятая C не вводятся.

Перед выполнением ресивера получаются значения, которые он фактически требует. Для нужного результата может потребоваться выполнить другой ресивер с меньшим приоритетом; собственные операнды производителя сохраняют свои записанные и определённые приоритетом границы. Это не повышает приоритет производителя. Головная часть присваивания связывается с местом, записанным непосредственно слева от неё: `1 + v := 2 + 3` не должно повторно разбираться как присваивание `1 + v`. Здесь первое сложение требует результат этого присваивания; его правая часть вычисляет 5, присваивание записывает `v = 5`, а сложение возвращает 6. Прежнее значение `v` не заменяет результат этого вхождения.

Каждое вхождение операции выполняется однократно в одном динамическом вычислении. Потребитель получает сохранённый результат, а не более позднее повторное чтение изменяемого места. Новый вызов, итерация, проверка условия или явный `sys\eval` начинают новое вычисление. Кэш результатов в исходном графе не устанавливается. Обычное чтение имён не ищет будущих присваиваний: `v := v + 1` читает прежний `v` справа. Соседние операции сами по себе не создают зависимости; `10 * 2 + 3` равно 23.

Вычисление по требованию сохраняет укороченное вычисление: ни `0 && (x := 1)`, ни `1 || (x := 1)` не записывают `x`. Пропущенный операнд, включая вызов или применение пользовательского оператора, не выполняется позже лишь потому, что обходчик доходит до его записи. Предварительного прохода по всем группам, инициализаторам или присваиваниям нет, и выбор не выполняет кандидатов спекулятивно.

| Выражение | Результат | Записанное значение `v` |
| --- | ---: | ---: |
| `1 + v := 2 + 3` | 6 | 5 |
| `10 * v := 2 + 3` | 50 | 5 |
| `1 + v := 2 * 3` | 7 | 6 |
| `1 + (v := 2) + 3` | 6 | 2 |
| `(1 + v := 2 + 2) * (v + 1)` | 25 | 4 |
| `v := 2 - 3` | −1 | −1 |

#### Присваивание внутри фактического выражения

Отдельное `v := expression` в позиции аргумента — это именованный фактический аргумент. Присваивание, встроенное в фактическое выражение, вместо этого записывает соответствующее место в namespace принимающего вызова и вносит своё значение в объемлющее выражение; оно не создаёт дополнительного фактического аргумента и не сдвигает позиционный счётчик. “DATA вызываемого” здесь обозначает объявленные логические места вызова, а не физическое изменение его исходного графа DATA.

Для `f` с первым формальным `x` и другим объявленным местом `v`, `f(1 + v := 2 + 3)` передаёт ровно один позиционный фактический аргумент, 6, и записывает 5 в `v` этого вызова. `f(1 + (v := 2) + 3)` тоже передаёт 6, но записывает 2. Отдельный одноимённый `v` вызывающего не изменяется. Напротив, `f(v := 2 + 3; 6)` содержит два фактических аргумента и допускается только тогда, когда подходит обычный порядок именованных и позиционных аргументов; когда `v` стоит первым, его именование на этой позиции оставляет позиционный счётчик активным. Обязательные принимающие места существуют, когда фактическое выражение к ним обращается.

Объявление, выполняемое внутри выражения, сохраняет обычные правила объявления/допуска и области видимости; его значение — присвоенное значение. Ресивер объявления места, *переданный как фактическая форма*, вместо этого сохраняется как DATA в соответствии с [аргументами объявления](#declaration-arguments): одна только передача никогда не вычисляет его инициализатор. Это разные позиции потребления, а не разные парсеры. Обычный фактический аргумент `Producer()` остаётся вызовом.

`while` использует DATA и активацию окружающего вызываемого. При каждом вычислении `while ((c := getchar()) != EOF)` `getchar()` выполняется однократно, его результат записывается в `c`, и этот же результат сравнивается с `EOF`. Для последовательности A, B, EOF происходит три чтения и два выполнения тела, после чего `c = EOF`. Вариант `while(c := getchar() != EOF)` не эквивалентен: эта правая часть вычисляет булево значение, а отдельный именованный аргумент также подчиняется обычному контракту аргументов `while`.

<a id="operand-receiver"></a>
### Пользовательские операнды: структурное обнаружение и обычные результаты

Пользовательский операнд — это обычный исполняемый метод, найденный обычным разрешением имён. Его имя — это имя его оператора. Его фактическое DATA остаётся `parent(C)`; import, ссылки, затенение и двусторонний `private` применяются обычным образом. **Ни регистрации `sys\operand`, ни отдельного реестра имён операндов не существует.** Временный производный индекс на время анализа допускается, но он не является другим исходным графом или постоянным окружением.

Обычное требование к структурному заголовку таково:

```lmx
operand_template:
    @: left
    []: @ right
    const: int: PASS_ARGS_AS_IS
    const: int: PRIORITY
```

Все четыре именованных поля должны присутствовать в DATA кандидата. `left` — это входная ссылка, а `right` — Array ссылок. `PASS_ARGS_AS_IS` должен давать готовое константное целое 0 или 1; `PRIORITY` должен давать готовое константное целое на общей шкале выражений до того, как группировка определена. Недостающие поля не предоставляются проверкой шаблона, даже если шаблон записывает значения по умолчанию. Обычная явная композиция может их построить; `implements` только проверяет фактический результат. Готовые свойства не заменяются локальными значениями вызывающего, и чтение их не выполняет тела оператора. Циклические или недоступные свойства не могут быть разрешены пробным выполнением.

Заголовок — это обычное структурное требование: важны его имена и вся явно заданная древовидная структура. Он не ограничивает результат значением `@`. Конкретный метод объявляет свой обычный результат, например `return: int` или `return: @`; процедура не может предоставить значение выражения лишь потому, что её DATA совпадает с заголовком. Необязательный специализированный шаблон может добавить `@: left int`, `[]: @(int) right` и `return: int`. Такие типизированные ссылки требуют фактических адресуемых целых чисел; они не означают невычисленного кода, который может позже вернуть целое число.

Позиционное требование `fn` остаётся отдельной проверкой. Например, `fn: PairSignature (@: first; []: @ rest; return: int)` может допустить совместимые входы с именами `lhs/rhs`, но это не устанавливает именованный структурный заголовок `left/right/PASS_ARGS_AS_IS/PRIORITY`. Ссылка на вызываемое не вызывается лишь потому, что потребителю нужно значение: `@: ptr add` сохраняет ссылку на метод, `add(...)` вызывает его явно, `a add b` применяет его контракт оператора, а `\ptr` только разыменовывает.

#### Подготовленные значения: `PASS_ARGS_AS_IS 0`

Анализ выражения определяет записанное левое вхождение и последовательность правых вхождений с помощью групп и приоритетов. Нужные вхождения вычисляются однократно. Ссылка на левое значение передаётся в `left`, а ссылки на правые значения образуют `right` в порядке исходного текста. Поэтому `(1 foo 2 3 4)` передаёт ссылку на 1 и Array из трёх ссылок. `(foo 1 2 3 4)` не имеет записанного левого фактического аргумента и четырёх правых вхождений; первое правое значение не переносится в `left`. Опущенные входы, значения по умолчанию и обязательность остаются обычными правилами вызова. Присутствующий пустой правый Array отличается от опущенного фактического аргумента.

Каждый записанный контейнер — это один операнд: `(foo A)` с Array `A` даёт одну ссылку в `right`, а `(A foo B C)` даёт одну левую и две правые ссылки. Общего расширения Array/строк не вводится. Обычное правило W/E для одиночной Structure сохраняет свою определённую область выбора вызова. У операнда своё правило: если `left` — безымянная Structure и единственный аргумент `right` — тоже безымянная Structure, скобки справа раскрываются, и в `right` приходит всё их содержимое; Structure, возвращённую функцией, не раскрывают (решения автора 2026-11-21 и 2026-11-22). `a foo b` нельзя текстуально заменить на `foo(a; b)`, потому что второй входной операнд оператора является Array ссылок.

Ссылки указывают на значения записей типизированного хранения, причём код типа находится непосредственно перед значением. Ссылка на контейнер адресует его типизированный дескриптор. Плотный `Array<T>` не переинтерпретируется как `Array<@>`, а нетегированный нативный временный объект не трактуется как запись арены чтением четырёх байт перед его адресом. Общий механизм хранения значений материализует подходящую запись только тогда, когда это требуется, с обычным временем жизни.

Метод возвращает своё обычное объявленное значение: `return: int` даёт целое число; `return: @` даёт ссылку. Использование оператора и явный вызов не снимают разного числа уровней ссылок. Представление хранения выражения — это вопрос реализации и не создаёт универсального контракта возврата ссылки.

```lmx
operands:
    @: left int
    []: @(int) right
    const: int: PASS_ARGS_AS_IS 0
    const: int: PRIORITY sys\priority("+")
    return: int
    add:
        return: \left + \right[0]

Example:
    int: n
    return: int
    calculate:
        import: operands
        return: (n add 3) add n
    demo:
        return: calculate(2) + calculate(5)
```

Требуемые результаты — 7 для `Example\calculate(2)`, 13 для `Example\calculate(5)` и 20 для `Example\demo()`. Это тело использует один правый операнд; более строгий бинарный контракт проверяет эту длину через существующий механизм допуска, тогда как вариативная реализация явно перебирает Array. Автоматическая свёртка и дополнительная таблица арности не подразумеваются.

<a id="raw-operands"></a>
#### Исходные вхождения: `PASS_ARGS_AS_IS 1`

Тот же анализ выражений определяет границы аргументов, но подаёт ссылки на исходные вхождения, не исполняя их. Вхождения могут содержать литералы, имена, вызовы, присваивания или группы. Обработчик произвольных исходных форм использует общие ссылки `@: left` и `[]: @ right`, а не требование к физическому int. Одно лишь чтение или сохранение такой ссылки ничего не исполняет. Неиспользованное вхождение не имеет эффектов; явное повторное вычисление повторяет эффекты. Записанные группы не вынуждают немедленного вычисления и не отменяют сырой контракт.

<a id="expression-eval"></a>
`sys\eval(fragment)` использует единственный исполнитель выражений, чтобы получить обычное значение сырого вхождения. Литералы дают значения, имена разрешаются обычным образом, записанные вызовы исполняются; сохранённая ссылка на вызываемое остаётся ссылкой, если форма его не вызывает. `\fragment` не является сокращением для вычисления. Каждый явный `sys\eval` — новое вычисление с эффектами, однократными для каждого вхождения внутри этого вычисления, а не постоянный кэш.

Вхождение сохраняет свой исходный контекст вычисления на всё время применения, в том числе при передаче вспомогательной функции. Одноимённые локальные переменные вспомогательной функции не могут его захватить. Встроенные присваивания сохраняют своё правило приёма в DATA, а исходный доступ binding/private сохраняется без предоставления операнду нового неявного доступа к private-местам. Один лишь физический исходный адрес не определяет живую активацию; существующий механизм передачи контекста должен сохранять это различие. Сырая передача не продлевает время жизни активации и не может восстановить завершённый Frame. Статически известные фрагменты могут использовать ту же подготовленную native-реализацию; ни второй парсер, ни вторая VM не требуются.

Сырая версия `add` использует эти DATA и тело:

```lmx
raw_operands:
    @: left
    []: @ right
    const: int: PASS_ARGS_AS_IS 1
    const: int: PRIORITY sys\priority("+")
    return: int
    add:
        int: a sys\eval(left)
        int: b sys\eval(right[0])
        return: a + b
```

С тем же телом `calculate`, импортирующим `raw_operands`, результаты остаются 7, 13 и 20. Внешний `add` получает слева исходную группу `(n add 3)`; его явное вычисление вызывает внутренний сырой `add`. Сырая реализация управляет тем, вычислять ли вхождение и как часто.

До запуска операндных аргументов с эффектами группировка и режим потребления должны быть однозначны. Нерешённые кандидаты с разными приоритетами или режимами дают обычную неоднозначность; кандидаты с одинаковыми свойствами могут перейти к обычному выбору по явному фактическому аргументу. Скрытое связывание никогда не выбирает сигнатуру оператора.

<a id="string-identifier"></a>
### `sys\name`: написание идентификатора

`sys\name(identificator)` потребляет один записанный идентификатор и возвращает его написание как обычный LMX `Array<char>` переменной длины. Он не разрешает переменную, не читает её значение, не выполняет её инициализатор и не вызывает одноимённый метод. Допустимый идентификатор не обязан быть объявлен. Кавычки точного идентификатора снимаются, а удвоенная обратная кавычка становится одной буквальной обратной кавычкой: ``sys\name(`long name`)`` даёт `"long name"`; пустой точный идентификатор даёт пустую строку. `sys\name(ptr)` даёт `"ptr"`, а не имя своей цели.

Существующее каноническое представление имени и таблица служебных имён дают написание. Таблица регистрации, новая кодировка, обязательное выделение памяти на каждый вызов или гарантия тождества адресов не вводятся. Результат — обычный символьный Array Lmx без завершающего NUL. `f(sys\name(foo))` и `f(a := sys\name(foo))` каждый передаёт по одному целому Array; символы не раскрываются в фактические аргументы.

<a id="expression-priority"></a>
### `sys\priority`: приоритет по строковому имени

Именованная сигнатура запроса — `fn: PrioritySignature ([]: char name; return: int)`. Она описывает вызов и не создаёт реализацию; её полное имя реализации — `sys\priority`. Она принимает одну строку LMX и возвращает приоритет доступного встроенного или структурно обнаруженного пользовательского операнда с этим именем, используя те же сведения о видимости и свойствах, что и анализ выражений. `sys\priority("+")` запрашивает сложение, `"-"` — вычитание и `"*"` — умножение; контекстные унарные и постфиксные употребления произвольным образом не меняют результат этого запроса.

Имена сопоставляются по содержимому строки на этой явной границе поиска. Отдельно созданная строка с тем же содержимым даёт тот же ответ; обычные разрешённые идентификаторы по-прежнему используют канонические адреса. `sys\priority(sys\name(foo))` не выполняет вызова `foo`. Запрос читает свой готовый `PRIORITY`, ничего не регистрирует и не вычисляет операндные аргументы. Отсутствующие, непригодные или неоднозначные операнды дают обычные диагностики разрешения/контракта; приоритет не выдумывается. Обнаружение и запрос используют одно и то же описание, а не расходящиеся реестры.

Эти правила выражений полностью заданы предоставленными [требованиями к операндам](tasks/to_fable_operands_arguments_priorities.md).

<a id="assign-known"></a>
#### Запись в известное место: `:=`

`left := right` записывает уже разрешённое место; неизвестная левая часть — ошибка и никогда не объявление. В CODE он вычисляет правую часть по [приоритету и спросу выражений](#assignment-inside-expression), допускает результат по принимающему контракту, записывает место и даёт присвоенное значение. В DATA оператор остаётся записанным материалом и не исполняется. Перенос или копирование формы в другой контекст не превращает её в объявление. Имена Structure сами по себе являются константными связываниями, тогда как примитивные места и места переменных-ссылок могут получать присваивание с учётом своих ограничений. `ptr := other_method` сохраняет ссылку на метод, не вызывая его. Самостоятельное присваивание в позиции аргумента подаёт именованный фактический аргумент; присваивание, встроенное в фактическое выражение, следует правилу места принимающего вызова. Ни одна форма не создаёт поля, не снимает уровни адреса и не публикует Frame одним лишь присваиванием.

<a id="graph-fragment-assignment"></a>
### Явное присваивание графа заменяет записанный материал

Чистый граф — полное буквальное отражение исходного текста, включая примитивные листья в форме `{type value}`. `for`, `if`, `merge`, `copy`, `import`, объявления и все прочие структуры-ресиверы остаются в записанном виде. Их присутствие не делает их постоянными или не подлежащими замене. Явно выбранная ячейка графа может получить новый фрагмент графа, в том числе другую Structure-ресивер или иной материал; на уровне представления нет белого списка редактируемых форм и специального API мутации только для кода. Обычная область видимости и явные контракты квалификации и защиты остаются отдельными от этой представимости. Голое имя константной Structure тем самым не превращается в изменяемую локальную переменную.

Для исходного `int: novalue` граф содержит `{uninit_int}` без хранилища значения. Локальное `novalue := 5` записывает Frame и оставляет этот исходный граф неизменным. Явное `S\novalue := 5` заменяет фрагмент графа в выбранном для S структурном месте на `{int 5}`. Каждый новый доступ через это место видит новый фрагмент; язык не требует роста записи на месте, постоянного прокси или совпадения адресов старого и нового сырых значений. Алиасинг во время исполнения одного локального места и двух ячеек графа, ссылающихся на один и тот же старый фрагмент, — разные отношения.

Если замена исходного материала требует нового машинного кода, применяется существующая [граница компиляции и перезапуска endturn](#explicit-compilation). Замена не стирает полный граф и не создаёт альтернативного исполняемого представления, и никакой автоматический механизм отслеживания правок не вводится. Это учитывает последнее [уточнение автора](tasks/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

<a id="compound-assign"></a>
#### Составные присваивания и степень

К `:=` добавляются составные присваивания `+=`, `-=`, `*=`, `/=`, `%=`, `<<=`, `>>=`, `&=`, `^=`, `|=`, `**=` и оператор степени `**` для выражений. Составное присваивание записывает уже известное место результатом операции над его текущим значением и правым операндом: `a += b` соответствует `a := (a + b)`, `a -= b` — `a := (a - b)`, `a *= b` — `a := (a * b)`, `a /= b` — `a := (a / b)`, `a %= b` — `a := (a % b)`, `a <<= b` — `a := (a << b)`, `a >>= b` — `a := (a >> b)`, `a &= b` — `a := (a & b)`, `a ^= b` — `a := (a ^ b)`, `a |= b` — `a := (a | b)`, `a **= b` — `a := (a ** b)`; авторская запись этих эквивалентностей через C-подобное `=` сохранена в журнале, в LMX `=` остаётся сравнением. Левая часть — уже известное место со всеми правилами `:=`, включая допуск `implements` и ошибку неизвестной левой части; `:=` сохраняет свой общий узкий смысл записи известного места, включая ссылки на методы и именованную подачу, и не сужается до чисел. `**` — степень; `^` остаётся побитовым исключающим ИЛИ. Ассоциативность и приоритет `**` — как в Python (уточнение автора 2026-11-07): `**` группируется справа — `a ** b ** c` есть `a ** (b ** c)`; связывает сильнее `*`, `/`, `%`, `+` и `-`; вызов, индекс и доступ к полю образуют операнд раньше `**`; слева `**` связывает сильнее унарных `+`, `-`, `~`, справа унарный операнд допустим — `-2 ** 2` есть `-(2 ** 2)`, `(-2) ** 2` сохраняет скобки, `2 ** -2` есть `2 ** (-2)`, `2 * 3 ** 2` есть `2 * (3 ** 2)`; правая сторона `**=` группируется так же. Группировка и исполнение различны: достигаемые эффекты следуют общим правилам спроса и записанного порядка LMX, а не неопределённому порядку операндов C. Составное присваивание однократно вычисляет место назначения и получает результат операции до записи; эквивалентности не являются текстовыми макросами, повторяющими эффекты места назначения. Числовые типы и преобразования `**` и `**=`, отрицательные или дробные степени, `0 ** 0`, числовые сбои и атомарность следуют выбранным контрактам числа и записи. Выбранный числовой контракт целых (решение автора 2026-11-22): интерпретатор отказывает всякий раз, когда точный результат операции не помещается в тип, — `2147483647 + 1` над `int` отказывает; машинный профиль L2 считает по машинному контракту ([L2](L2_spec_ru.md)). Числовые операции, типы выражений и допуск не привязаны к `int`: разбор и типы выражений — обычные, как в типизированных языках, для каждого числового типа (то же решение). Из Python берётся только группировка степени; никакая иная числовая политика Python не подразумевается. Реализация должна сохранять эти результаты на каждом поддерживаемом пути исполнения; эта спецификация не является отчётом о реализации.

<a id="group-assign"></a>
#### Групповое позиционное присваивание

Решения автора 2026-11-10. Левой частью оператора `:=` может быть безымянная Structure мест: `(a b c) := (c, a, b)` присваивает по позиции — первому месту первое значение, второму второе, третьему третье. Сначала автор записал эту форму с двоеточием, `(a b c): c, a, b`; после правила, что структурные формы не присваивают ([структурные формы](#forms-declare-or-call)), она пишется через `:=`, и Structure как голова Frame перед двоеточием не вводится. Все правые значения вычисляются до первой записи, поэтому эта запись переставляет три значения по кругу. Каждая позиция записывается по правилам `:=`: место должно быть доступно в точке присваивания по [общему правилу видимости](#declaration-visibility). Переменные и `const` видны последовательно; групповая форма этого правила не меняет. Явный путь выбирает поле по обычным правилам путей; оно не становится от этого видимым голым именем раньше объявления. При обращении по имени неизвестное имя, имя Structure и имя функции слева — ошибка, каждое значение проходит обычный допуск своего места. Слева стоит безымянная Structure, и безымянная Structure, записанная справа, — единственный аргумент `right` операнда `:=`: скобки справа раскрываются, и в `right` приходят значения позиций. Когда слева не безымянная Structure, скобки справа не раскрываются: `struct := (copy(args))` присваивает ссылке `struct` одну Structure (решение автора 2026-11-22). Это присваивание между безымянными Structure — общий случай присваивания, а не особая форма (решения автора 2026-11-16 и 2026-11-21). Structure, возвращённую функцией, не раскрывают: в `(a, b, c) := myFn()` справа одно значение ([результат-Structure](#structure-result)). Разное число мест и значений — отказ: при трансляции, когда число известно, иначе при исполнении до первой записи. Structure слева содержит хотя бы одно место; голова `()` с пустыми скобками остаётся прежней отдельной формой ([грамматика](LMX_grammar.ru.md#bounded)). Поток полей записывается внутри явной группы, и она раскрывается так же: `(a b) := (copy(Pair))` присваивает два полученных поля по позиции; голый поток `(a b) := copy(Pair)` — ошибка (решение автора 2026-11-21). Правая сторона группового присваивания — одна безымянная Structure, записанная в скобках, форма `() := ()`; несколько значений, записанных без группы, — ошибка (решение автора 2026-11-21). В `(c b d a) := (a b c d)` при старте a=1, b=2, c=3, d=4 итоговые значения: c=1, b=2, d=3, a=4. Все значения правой части предшествуют первой записи; это не обещает отката эффектов, уже произведённых при их вычислении.
[EN]
Source notation constructs the complete graph of written forms: declarations, values and executable expressions remain together. **All receivers remain as written. All computation and transformation take place in the namespace.** Terminal primitive declarations are included in that complete reflection in their direct `{type value}` form, with names in the ordinary name table. An uninitialized primitive contains its `uninit:T` code and zero value bytes; no T cell is reserved. A computed RHS is not terminal and is not folded by running the program. A modifier, call, `import`, `copy` or `merge` record is not replaced in the source graph by its result. Copying may construct new result nodes under the [graph-copying contract](#composition), and explicit program writes retain their own graph-mutation contract.

Ordinary indentation and explicit trailers close forms according to the [grammar](LMX_grammar.en.md#levels). A blank physical line outside escaped content closes **all** open vertical and short forms to the current document root, as a terminator at virtual level −1. Its indentation is irrelevant; a single newline between nonblank lines is not this event. The root survives and subsequent forms begin there. A blank line creates no field, empty Structure, executable instruction or return; it does not synthesize missing paired delimiters. Within Mix it closes the local Mix document's block, not the surrounding document or its `}`. EOF still closes a completed ordinary block. Generated source must put blank lines only at intended full boundaries.

Constructing a body description does not execute it. A named Structure is declared in a data context; a headed form in code calls its resolved head. An anonymous body executes only under its receiving contract. Lexical parenthood follows written structure and the explicit copying/qualification rules, independently of storage ownership. No hidden procedure, second authoritative graph or persistent namespace is created. Names and retained comments follow [§4](#fields); comments do not execute.

### Head resolution and the role of the tail

A receiver applies its declared contract to the written tail: it may declare a place, describe a signature, consume a code body, or produce a value or field stream. Frame syntax alone does not determine those roles. A name consumed as a name is not called: `catch: merge ()` supplies a failure name and parameter description, and `fn: SumSignature (int: a; int: b; return: int)` supplies a signature name and data template. Both use the common parser and resolution mechanism.

<a id="resolved-head-consumption"></a>
#### One model, one resolution, one consumption

First, the complete written structural head/arguments model is formed in translator memory, without knowing what the head denotes. Neither its name, signature, nor entity category determines that model's boundaries or permits collecting additional arguments. Only after the model has been formed is the form read by the role of the Structure in the launch ([the roles `data` and `code`](#data-code-roles)) and the resolved receiver contract. An ordinary DATA form declares a Structure; a place-declaration receiver declares a place. A CODE headed form is a call. Receivers such as `import`, `copy` and `merge` retain their own argument and field-stream contracts when their written records occur in DATA. In every case, the common resolution algorithm in the single namespace finds the head: a receiver, a callable or a Structure. Such a form does not write a value into a known place ([structural forms](#forms-declare-or-call)). One common consumption mechanism applies the resolved entity's contract; differing contracts do not create separate parsers, namespaces, or resolution routes.

<a id="data-code-roles"></a>
### The roles `data` and `code`

DATA and CODE name semantic roles, not new keywords or permanent kinds of Structure. For a selected executable Structure `C`, CODE is `C` and DATA is its actual `parent(C)`, where present. `call(C)` and `C()` execute that occurrence without explicit actuals; `call(A C)` and a by-name call with the same selected actuals execute it with arguments `A`. A call cannot substitute another DATA. R0 is an entry without DATA or user actuals ([structural call](#call-receivers), [root entry](#root-entry)).

In DATA, an ordinary headed structural form declares a Structure with its written content. Thus `S()` declares an empty `S`, `S(D)` contains the reference atom `D`, and an `if:` record remains a Structure addressed through its head. Place-declaration receivers such as `int` and `@` instead declare their respective places through the namespace. An assignment `:=` is retained source material and is not executed merely because it occurs in DATA. Repeated DATA declarations remain separate occurrences; ordinary repeated-declaration and occurrence-selection rules apply.

In CODE, a headed form applies its resolved head. `S(args)`, `S: args` and its vertical form execute `S` with the selected actuals; they do not assign to `S` or declare a new Structure. A declaration receiver such as `int: i 6` establishes or updates its logical place under the receiver's contract. A numeric or null head is not callable. A call used for its value must have an admitted result described by `return` in its actual DATA. Bare `S` is a reference and does not call it.

These role rules are applied by the resolved receiving contract. In particular, a [place-declaration receiver supplied as a CODE argument](#declaration-arguments) is read as DATA and preserves its form. This does not change an ordinary `Producer()` or `Producer: tail` into a declaration: its head is an ordinary callable, so it remains a CODE call.

`import`, `copy` and `merge` always consume standard CODE arguments through the common translator algorithm, whether their receiver records occur in DATA or CODE. Ordinary W/E selection applies wherever these arguments are consumed. A bare Structure reference or an anonymous Structure supplied as a source is not itself a call. Its contents may contain calls or initializers governed by their ordinary consuming contracts; the group neither quotes them nor forces them all early. An explicit `Producer()` is a call when that receiver is consumed. Their selected or computed fields are consumed through the namespace; the source forms remain intact. For example, DATA `Struct: merge(A B)` is an ordinary declaration of `Struct` containing a receiver record; `merge` supplies a field stream for that DATA reading. The declaration is made by `Struct:`, not by a special merge-declaration syntax. Multiple such operations are independent, and `Struct` is never an implicit merge source or model ([composition](#composition), [import](#import-receiver)).

<a id="data-root-declaration-execution"></a>
#### Direct data traversal and receiver execution

Namespace preparation interprets root declarations of DATA and CODE without executing all computed initializers. Modifiers `private`, `required`, `const`, `immutable` and `independent` apply their contracts through that same mechanism; declarations they mark count as root declarations where the ordinary DATA rules say so. Physical parenthood alone does not define this semantic root status. The modifier records remain in the source graph, so an explicit path still passes through them, for example `S\private\x`.

`import`, `copy` and `merge` participate through ordinary field-stream consumption, with the same standard CODE source-argument contract in every placement. When such a receiver is actually consumed, an explicit source call is evaluated under that contract. P0, namespace/signature inspection and following an explicit source path do not eagerly execute the receiver or its arguments. This does not authorize a general recursive execution pass through nested bodies or reference targets. A reached receiver can execute a supplied body when its contract calls for it; merely preparing or passing a computed place declaration does not execute its RHS.

Terminal primitive declarations may be represented directly as typed values. Every other receiver, written group and source order remains as written, including after its DATA result has been obtained through the namespace. Neither namespace construction nor execution serializes a transformed replacement graph over the source.

#### Anonymous Structures and value positions

An unnamed Structure has no head and is not a call with arguments. As a standalone CODE body it executes its written records in the current activation, with ordinary nested visibility. As a value or argument it remains a written Structure whose consumer determines its reading. A numeric consumer can read a group as an expression; a DATA consumer reads it as data; a body consumer executes it. P0 does not remove a group merely because it has zero or one field. An anonymous Structure can contain calls or initializers; its boundary alone neither suppresses them nor executes them all early.

```lmx
Holder:
    return: int
    anon:
        int: r 0
        ---
            int: q 4
            r := q
        ---
        return: r
```

`Holder\anon()` returns 4: the unnamed block executes in that activation. A standalone `()` does nothing. On the left of `:=`, an unnamed Structure is a sequence of places for [group assignment](#group-assign).

An assignment updates resolved primitive or reference-variable places. Names of structural declarations are constant bindings and are not assignable variables: `Model := KnownStruct` is invalid when `Model` names a Structure. `@: ptr KnownStruct` declares a reference variable; `ptr := Other` can update it. `Model: KnownStruct` in DATA contains a reference atom without copying or reparenting `KnownStruct`; in CODE it calls `Model` ([colon declares](#colon-declares)).

Input places and defaults belong to `parent(C)`; `args` in `call` is supplied argument material, not another formal-description part. The `return` field of DATA describes a result without assigning it. `fn: name data` creates a named signature description, not code. The removed separate DATA parameter, executable `fn`, `sub` and `fncall` have no current built-in meaning ([migration note](#removed-builtins)).

<a id="receiver-args-only"></a>
### Declaring a place: a receiver and its arguments

A place with a requirement is declared by the receiver's own argument form: `int: i 5`, `int: x`, `@: ptr 0`, `@: ptr Model`. Its first argument names the place; a primitive receiver without a value declares typed absence, while the corresponding value-check form can check a primitive literal. P0 builds the same ordinary Frames; arity and field roles come from the resolved receiver.

The composed form `name: receiver: value` does not declare a variable named by the outer head. In DATA, `timeout: ms: int: time 500` declares timeout containing ms containing the primitive time; its path is `timeout\ms\time`. In CODE the same outer form calls timeout. Likewise `i: int: 5` in DATA is a Structure i containing the receiver form, not an int variable i; in CODE it applies i and is invalid if i is a noncallable numeric place. Declaring a primitive or reference is done with its receiver, not by replacing that receiver's parent. `:=` assigns an existing place; it does not declare one.

A bare atom does not add an unwritten receiver or callable invocation. If the resolved field contains a computed declaration, an explicit path reads the record of the declaration and executes nothing ([explicit path](#path-reads-no-execution)); the written expression is evaluated by a call when it reads its local place by a bare name, and that does not call the returned callable with no arguments. The expression is formed and evaluated the same way whether its result is consumed or not; a write into a place is an effect of an unconsumed declaring form, not a special parse of the right operand. Thus `Model: 0` consumed by another expression does not change `Model`: in arguments it is a call of `Model` -- formerly it yielded a candidate under the requirement `Model`, now the requirement and the candidate are written flat, `@: ptr Model 0` ([the roles `data` and `code`](#data-code-roles)); if `Model` is a Structure, this is its call with the argument `0`, and at a place where a value is needed (an operand of an expression, an actual argument of a call, an initial value, an operand of `merge`) it yields a value only if the data of `Model` describe a result by the field `return` ([`return` in DATA](#return-in-data)); as a statement of its own, `Model: 0` still calls the selected Structure under its ordinary argument contract and discards any unconsumed result. If `Model` is instead a noncallable primitive place, the form is an error; in neither case does the colon assign ([structural forms](#forms-declare-or-call)).

Two-field `int: x 5` declares place `x` with an `int` requirement and value `5`: in data it creates the place, in code it is a call of the receiver -- a check of the type with an assignment to the local namespace place `x` ([the roles `data` and `code`](#data-code-roles)). Unary `int: x` describes place `x` with an `int` requirement and no invented initial value: a first definition creates the place; with an already known `x` the same form in code checks its compatibility by ordinary admission without a new write or second field, and in data it stays one more occurrence of the name, which is addressed only with the index of an occurrence after that. An uninitialized graph place contains only the distinct type code `uninit:int`, with `sizeof(value) = 0`, not a reserved int cell, numeric zero or an external initialization mark; every primitive has such a type, alike in code, data and a signature, where it distinguishes a formal without a default `int: q` from the default `int: q 0`: such a formal is not mandatory -- an input without a value, to which no value is supplied, does not make the call refuse: it is filled by [autofill](#binding-autofill), and where that is inapplicable it holds this type (the author's decision of 2026-11-16), and the receiver [`required`](#required-receiver) checks that a given field is initialized; the latest [author clarification](tasks/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md) specifies that explicit graph assignment (`D\a := 5`) replaces the fragment at that structural place: `{uninit_int}` becomes `{int 5}`. It does not retag a preallocated T cell, require in-place expansion, or preserve a raw payload address across replacement ([L2 §3.1](L2_spec_en.md#uninit-record-control)). An assignment to a local of the call -- `a := 5` for a formal that received no value -- writes into the place of the call: the graph does not change and the data are not published. The absence of a value is written as a value of that separate type: `nil: T` (`nil: int`; any other primitive type in place of `int`), and simply `nil` where possible. `int: var` declares a variable without initialization, and a separate type exists for that; it was introduced for passing arguments and stays needed with `required`. A variable can be compared with `nil` by its absence state; no numeric sentinel or imaginary value bytes are introduced. The graph holds nothing but Structures and primitives: a primitive is the declaration of its type with a value or with the absence of a value, and everything else is written as Structures. The null pointer stays `0` where that is possible; a pointer declared without a value (`@: ptr`) is not zero and is written with the same `nil` (the author's decision of 2026-11-17). Every receiver that used to be written without arguments in the place of a type has a one-argument form: `int: i` is written instead of `i: int` (the author's decision of 2026-11-10). With `i` already declared, `int: i` in code is not an error but a check that the type conforms: repeated declarations are allowed. The one-argument form given the primitive itself instead of a name, `int: 54554878477838734`, returns the number in an expression or throws a failure that `catch` receives. In a signature these forms describe a formal, and a written value supplies a default when an actual argument is absent; describing a formal does not execute it as a body. This is one mechanism for primitives, references, Structures, and callables, with no parser branch for a receiver's name. The constructed source graph fixes its physical slots until an explicit graph operation changes them. Logical namespace places and bare-name visibility follow sequential declarations, lexical scopes and explicit receiver-stream consumption; reaching a branch does not append a hidden slot to the source `Lmx`.

The declaring contract of built-in value/type receivers, including `int` and `@`, is `R: name value`: the first field is an atom naming the receiving place, and the second is a value or requirement expression, while `@` with a requirement has an optional third field, the candidate (`@: ptr Model Other`); without the second field the place is declared with no initial value. The resolved receiver's contract determines arity and field roles after P0; the parser neither singles out this class nor changes the tree, and other receivers retain their own argument contracts. The name atom is neither called nor evaluated as a value: the place is resolved in the same namespace as a Frame head. The candidate is evaluated once before any write, undergoes ordinary admission, and then the place is first defined or, when it is already known, receives the value in code as a repeated declaration: enumerating a receiver's arguments remains that receiver's business and can always be a declaration — `@: ptr1 ptr2` may declare `ptr1` (author's clarification of 2026-11-10, [structural forms](#forms-declare-or-call)); in data a repeated declaration does not write into the former place and stays one more occurrence of the name ([the roles `data` and `code`](#data-code-roles)). Consumption of the entire form by another expression does not itself publish a field or perform a write. `@: new_field Model` binds the reference to `Model` without requiring prefix address-taking.

A requirement and a candidate are written flat: in `@: ptr Model Other`, `@` has three fields -- the place atom `ptr`, the requirement `Model` and the candidate `Other`; `@: ptr Model 0` gives a null address. The nested form `@: ptr Model: Other` does not serve for that: the arguments of a receiver are read as code, and `Model: Other` in them is a call of `Model` with the argument `Other` (the decision of 2026-11-11, [the roles `data` and `code`](#data-code-roles)), not a requirement with a candidate; formerly a consumed `Model: Other` yielded candidate `Other` under requirement `Model`. Admitting the candidate neither writes to `Model` nor creates an addressable temporary cell. After admission, the form builds a reference value and binds `ptr` by the common rule; the candidate is evaluated once before the write. If `ptr` is callable, the form of the receiver `@` designates `ptr` as a binding place subject to its write constraints, while `ptr: @: Model Other` in code is a call of `ptr` with an argument.

In evaluation position, a bare identifier enters the same resolution flow but does not itself form a call or supply an empty argument list. It denotes the resolved value, a reference to a Structure or callable, or a receiver name according to the receiving position's contract; bare `merge` and `int` likewise do not execute. If that position requires a value the named entity does not provide, this is an error, not a hidden nullary call or free input. Applying a resolved head requires an explicit Frame with `()` or `:` and a structural tail, possibly empty; that head's contract still determines the Frame's role. A named Structure is executed through the receiver `call: A` or, in code, by a form with its name as the head, `A()` or `A(args)` ([the roles `data` and `code`](#data-code-roles)). Neighboring atoms are not captured. In `if: p`, bare `p` is only read: even if it points to a method, that method is not called. This rule does not decide whether the value of `p` is admissible as a condition.


<a id="colon-declares"></a>
In DATA, an ordinary `Name: tail` declares a Structure whose content is that tail. `Struct1: Struct2` contains one reference atom to the existing Struct2: it neither makes the two names equal nor copies or expands Struct2's fields. Its parent is unchanged, so a path such as `Struct1\Struct2\a` reaches the original target. In `Struct1: (Struct2 a b c)` the written group remains one anonymous Structure; its own a and the a reached through Struct2 are different fields. Cyclic references such as `A: B` and `B: A` are not infinitely expanded. An unresolved atom remains a word.

A structural name is a constant binding. `Struct1 := Struct2` does not reassign it. A mutable reference is instead declared by `@: ptr Model`, may explicitly receive null by `@: ptr Model 0`, and is later updated by `ptr := Other`. The atom's physical slot remains accessible by ordinary indexed graph operations; that does not make its bare name an assignable variable. Repeating a DATA declaration preserves another occurrence and requires ordinary occurrence selection. In CODE the corresponding `Name: tail` or `Name(args)` is a call, not a declaration or assignment. Reference passing does not reparent its target or capture its caller.

In data a structural form declares a Structure, and its tail is the content: `A(int: x 1)` and `A: int: x 1` declare `A` with a field `x`. Empty `A()` and `A:` declare a Structure without fields. `A: ()` declares `A` with one empty anonymous Structure inside it, and `A: (int: x 1)` declares `A` with an anonymous Structure inside it that has the field `x`: P0 does not unwrap a sole Structure in a tail ([values](#values)). Bare `A` reads a reference to an already selected ordinary Structure. If `A` is already declared at this level, a repeated structural form, including an empty one, is a repeated declaration, not an assignment: one more occurrence of the name `A`, which is addressed only with the index of an occurrence after that; in data no call of the former `A` results. Executable code has no description of a Structure -- such a form there is a call of its head; a distinct scope arises on a call of a Structure -- by an explicit `call` or by a form `A()`. Inline `if`/`for` operators remain in the same activation. Named Structures and callables are visible in both directions; variables, including const, are visible sequentially from their initial declaration in their scope and below. Root data inputs are available to executing code; namespace preparation neither exposes future code locals nor evaluates initializers ([visibility](#declaration-visibility), [call frames](#call-frame-20261115)). A form with a path in its head, `Outer\Model()` or `Outer\Model:`, is in code a call of what stands at that path; bare `Outer\Model` reads its reference without calling. To execute the selected ordinary Structure, use `call: Outer\Model` or, in code, the form `Outer\Model()`.

<a id="ordinary-var"></a>
### The name `data`

The name `data` is an ordinary user name and the descriptive name of a semantic role. It is not an implicit reference to a call's DATA and cannot rebind that DATA. The selected code C uses actual `parent(C)`; an explicit path `D\x` addresses that known Structure, while `node\x` explicitly selects the established lexical context. These expressions are not interchangeable merely because a receiver is currently reading DATA. If a variable named data is declared, `data := ptr` has only its ordinary assignment meaning. A headed `data(...)` form follows the same role rules as any other user head:

| Where the form `data(...)` stands | Action |
| --- | --- |
| In data, the name not yet declared | Declare an ordinary Structure `data` with the written content. |
| In data, the name already declared | A repeated declaration: one more occurrence of the name, which is addressed with the index of an occurrence after that; this is neither a replacement nor an assignment. |
| In code | A call of the head by the general rules ([structural call](#call-receivers)): if `data` names a Structure, it is executed; if the head names nothing, the form is an error. |

Historical note: earlier specifications used a reserved data reference and allowed a separate DATA argument on call. Both are withdrawn. Migration must choose the actual structural occurrence and its parent; it cannot restore the former behavior by renaming a variable.

In data the sequence `data(int: x 2); data(int: x 5)` is two declarations: two occurrences of the name `data`, each with its own content; the second neither replaces the first nor writes into it. A declaration, first or repeated, does not by itself execute the content of a Structure: its execution is given by a launch -- an explicit `call` or, in code, a form with the name of that Structure as the head, `A()` or `A(args)`. In executable `code` the name `data` follows the common rules of names and places, with no separate algorithm.

In this chapter DATA names the role of actual `parent(C)`, while a user name `data` follows ordinary resolution. `call` has no separate data argument: `call(C)` and `call(A C)` execute the selected `C` over `parent(C)`, and `A` is its actual arguments ([structural call](#call-receivers)). A call creates a local namespace without appending code places to the source graph. An ordinary Structure in code is launched also by a form with its name as the head -- `A()` and `A(args)`; this is a form of its own, not a form of a receiver, and its arguments are supplied by the general rules ([structural forms](#forms-declare-or-call)). A form `data(...)` in data declares a Structure under the same rules as any other declaration; this does not launch the Structure's content. Bare atom `data`, like any bare atom, only names what stands under that name and invokes nothing, including when a method reference stands in its place.

If `put` is already defined as a callable Structure, the following declaration of `Batch`, written in data, retains a body with the statement `put: 7` without executing it. The example is written in the forms of the norm of 2026-11-19: the input `n` and the result -- the field `return` -- are described in the data `Context`, the code `put` is a nested Structure, and `Batch` lies next to it:

```text
Context:
    int: n
    return: int
    put:
        return: n
    Batch(put: 7)
```

This is an ordinary operator in the complete binary tree, not a separate “saved call” value, hidden closure or second graph. When execution of Batch reaches the put operator, the ordinary call rules apply. An available native implementation of Batch is selected; otherwise its retained body is walked in the admissible profile. Absence of a native implementation alone does not mean the tree is lost or unexecutable.


A later read does not retroactively change the role of an already written head. In the following example, `f` has no input `x` in the data `F`, no visible outer value and no previously established free input `x`: the form `x: j` stands in code, so it is a call of `x`, neither an assignment of a primitive nor a declaration of a Structure; the head `x` names neither a callable nor a Structure, and the form is an error ([the roles `data` and `code`](#data-code-roles)). Formerly it defined a named Structure, and `return: x` was the error. A caller's same-named value does not change this classification. The example is written in the forms of the norm of 2026-11-19: the result is described by the field `return` of the data `F`, the code is the nested Structure `f`.

```text
F:
    return: int
    f:
        int: j 3
        x: j
        return: x
```

A free input is a free value used by a callable without being declared as its explicit formal; establishing it and selecting its source follow [§12](#dynamic). This term introduces neither an additional Structure nor a separate persistent context graph. The walker resolves reached names through the common transient namespace, and prepared native code uses the corresponding selected places and hidden arguments; neither path creates a second name store.

<a id="explicit-copy"></a>
### Explicit copying and pointer variables

The reference receiver uses ordinary declaring forms. `@: ptr` creates an uninitialized reference place; `@: ptr 0` supplies null. `@: ptr Model` retains a reference to Model, and `@: ptr Model Other` explicitly supplies a requirement and a candidate. Requirement and candidate are flat arguments. In a CODE-reading position, nested `Model: Other` is an ordinary call, which must produce an admitted result if a value is demanded; it is not an alternative requirement/candidate notation. DATA-reading and passed-declaration positions retain their own contracts.

A repeated declaration at the same CODE level with no new candidate checks the existing place without clearing its value. A supplied candidate follows ordinary conversion/admission before the write. Address assignment does not retroactively type an already declared void-reference place. The outer form `ptr: @: Model` instead declares a Structure in DATA or calls ptr in CODE; it is not a reference-variable declaration. These are resolved receiver contracts after the common parser.

Explicit [copy and merge](#composition) produce field streams. `copy(A)` has one admitted source; `merge(A C)` has at least two. To retain one structural value in a reference variable, write `@: b (copy(A))` or `@: b (merge(A C))`; assignment to an existing reference likewise uses `b := (merge(A C))`. The destination is never a source or model. Without the group, the RHS remains a stream and its admissibility follows the receiving contract; it is neither automatically one container nor universally a syntax error.

In DATA, `b: merge(A C)` ordinarily declares `b`, and the enclosed receiver supplies fields through that DATA namespace. In CODE the same outer form calls `b` with the stream supplied by `merge`. A bare atom `merge` captures no neighboring fields: `b: merge A C` is not the same application. Ordinary references and unknown names do not trigger implicit copying. A grouped result retains its written boundary, although a subsequent CODE call may still consider W and E under [ordinary selection](#declaration-selection).

The `@:` receiver takes the place name as its first field; both a new place and a write to an existing one use the same resolver and ordinary [admission](#admission). In a signature the same receiver describes an input requirement. The candidate's place is determined by common resolution; after admission, accesses use the resulting addresses and maps without repeating textual name lookup. A known method pointer `b` is invoked as `b: args`, `b(args)` or `(\b)(args)`; `\b(args)` dereferences the call result under ordinary precedence. Unary `@b` separately addresses the reference cell.

<a id="method-reference-assignment"></a>
A method reference is assigned through `@`, which comes first: `@: ptr method`. The first argument `ptr` is a place-name atom; the second, `method`, is an atom denoting the method value. **A bare atom is not a call**, so neither `ptr` nor `method` is invoked here. The `@` receiver consumes these arguments under its two-field contract: the first definition creates a reference place; on an already declared place, in code a new value is assigned to that same place after admission, while in data a repeated declaration stays one more occurrence of the name ([names and paths](#fields)). Likewise, `@: ptr 0` supplies an explicit null candidate. In contrast, `ptr(args)` or `ptr: args` explicitly applies a callable to arguments; if `ptr` holds a reference to an ordinary Structure, the same forms launch it by the launch forms of a Structure ([structural forms](#forms-declare-or-call)). The form `ptr: @: method` is not an assignment, whatever `ptr` is: in code it is a call of `ptr`, in data a declaration of a Structure `ptr` ([the roles `data` and `code`](#data-code-roles)); an `@` in the nested argument does not change that, and assignment uses `@: ptr method`.

Unary `@ptr` selects the address of the variable cell ptr, distinct from its stored target reference; it is not the assignment `@: ptr method` and does not replace the stored method reference with its cell address. An explicitly supplied argument, an autofilled value and a value of the former binding (the fallback) have their own local activation cells: `@x` addresses the same local variable that bare `x` reads and writes. Where the selected level admits dereferencing this numeric address, after a local `x := 9`, reading `\(@x)` yields `9`; writing through that address changes its own cell, not the binding's source ([own place](#binding-places), [autofill](#binding-autofill), [former binding](#binding-fallback)). If the name is bound as a transparent caller place ([caller's place](#binding-caller-place)), then `x`, `x := 9` and `@x` act on that place at once: `@x` is the address of the caller's place, and the write is visible to the caller without copying back. An external place is addressed explicitly, for example `@(node\x)`. Taking an address does not extend cell lifetime; an object reference and the variable cell holding it are distinct.

Candidate conversion and admission follow the receiving contract; reference storage changes only after successful reception. Ordinary Structure and method values already travel by reference: `@: ptr Struct` retains that ordinary reference without invoking `Struct`. Prefix `@Struct` explicitly obtains its numeric address, as in `int: value 1 + @Struct` where numeric addresses are admitted by the profile; it is not required to pass `Struct` and does not suppress an operator role. Prefix `@x` on a variable selects the real logical variable cell chosen by binding, including the caller's cell for a transparent binding. It must not accidentally address only the object stored in a reference variable or an ABI transport box. Machine-address operations retain the applicable [L2 contract](L2_spec_en.md#lowlevel-address). Taking an address extends no lifetime, and dereference `\` follows an admitted address/reference without executing code.

### A signature is not executed

A named `fn: name data` signature describes ordered input types and, where there is a result, the field `return`; the forms written in it are not executed as the body of a callable. Both arguments of `fn` are read in the data role, and its nested records only describe ([`fn` signature](#fn-signature)); the description of inputs in the data of a called Structure is arranged the same way ([structural call](#call-receivers)). Input places are described by declarations by receivers. For nonprimitive `A`, a formal requiring `A` is written `@: p A`, admits a candidate through `implements(c, A, Consumer)` and transports its descriptor reference without copying or implicit `merge`. Value and reference requirements are written with the same receiver forms as in a body, but describing a formal does not assign a place while the callable is built. A value written in the description is a default, not a result of executing the body.

For structural `c`, `mytest(c)` passes its ordinary reference, while `mytest(@c)` explicitly obtains an address under the prefix-@ contract; these are not interchangeable arguments. No extra level is removed to fit a formal. This applies equally to a Structure, a pointer variable and a nonprimitive formal; the target is its own language storage, not a transport-ABI box. A primitive value and a reference to its cell are not synonyms either. Passing and returning nonprimitives never use C by-value aggregates.

### Assignment and declaration sites

In code, re-declaring a variable already declared at the same level retains its type check, RHS computation, and assignment, but creates no second C variable. Executing `int: i 5; int: i 6` uses one local place. Both written forms remain in the source graph; local execution does not overwrite them. In data, a repeated declaration remains a separate named occurrence selected by index. New branch names are visible inside that branch and below; a repeated form at the same level uses the existing place, while a declaration at a nested level shadows the outer one of the same name ([declaration levels](#shadowing-levels)). A structural `name:...` form in code calls its head; `:=` assigns without declaring.


The inputs of a called Structure -- the declared places of its data -- and code's own variables are activation-local places: assignment to them writes neither into the source graph nor to the caller -- neither an explicitly supplied value, nor an autofilled one, nor a copy under the former binding is an alias of the source ([own place](#binding-places), [former binding](#binding-fallback)). It is otherwise for an external name without a declaration of its own: if it is bound as a transparent caller place, an assignment acts on the caller's place at once, without copying back ([caller's place](#binding-caller-place)). The declaration operator remains in code. The description of inputs in data does not execute their computed initializers during graph construction. See [frames](#call-frame-20261115).

<a id="forms-declare-or-call"></a>
#### Structural forms declare or call

A headed structural form—parenthesized, short, or vertical—applies the same resolved contract. Ordinary DATA forms declare Structures; CODE forms call their heads; declaration receivers declare or update their places. A structural form is not an assignment merely because its head names an existing place: `i: 6` cannot update a numeric i. Use `i := 6` or a reached same-level receiver declaration such as `int: i 6`. The latter retains type checking, RHS computation and assignment while creating no second logical place.

Root DATA inputs are available to the selected CODE; CODE variables and constants retain sequential visibility. True nested declarations shadow outer places. The source graph retains both written receiver occurrences, and CODE locals do not become source DATA fields. P0 does not classify a head or invent a different tree to implement these rules.

In CODE, `A()`, `A(args)`, `A: args` and a corresponding vertical form launch the resolved Structure A. They use actual `parent(A)` as DATA and the ordinary selection of explicit actuals. An unknown, numeric or null head cannot be used as an ordinary callable. `call(A)` and `call(X A)` are the explicit receiver forms with the same selected actuals; the receiver does not choose a child body automatically. In DATA, `A()` declares empty A and `A(args)` declares its written content without invoking a prior A. A single written Structure actual may have W and E readings only under the [CODE call-selection contract](#declaration-selection).

Repeated declarations remain allowed. Executing a repeated variable receiver retains its actions, including `bump()` in `int: x bump()`. Same-named graph-field declarations do not merge. In data, `Struct1: Struct2` declares a Structure containing a reference atom to Struct2, not a copy of its fields; in code it calls Struct1. `b(args)` calls b's referent when it is callable or a Structure. A number or null reference is not callable. Colon does not replace `:=`. A call appends no places to the source data and code: new code places live in the call namespace under the [common rule](#call-frame-20261115).

<a id="assignment-inside-expression"></a>
### Expressions, assignment and demand

P0 is the only parser. It preserves the written head/tail graph, groups and source order; it does not apply precedence, remove containers, or rewrite `parent` and `length`. After parsing, the common expression mechanism resolves heads, priorities and dependencies in the namespace. A written operator is a receiver head: `(1 + 2 + 3 + 4)` has the corresponding chain of `plus` forms, whereas `(+ 1 2 3 4)` and `(1 + 2 3 4)` contain one variadic application. The ordinary mathematical form `(+ 2 - 3)` yields −1. These readings introduce no operator-specific parser.

Supported operations have the following relative precedence, strongest first. The scale is shared by built-in and user operands; these rows do not prescribe numeric priority codes.

| Level | Operations | Associativity |
| --- | --- | --- |
| Postfix | call, index, field access, postfix `++` and `--` | left to right |
| Unary | prefix `+`, `-`, `!`, `~`, `++`, `--`, existing address operations | right to left |
| Multiplicative | `*`, `/`, `%` | left to right |
| Additive | `+`, `-` | left to right |
| Shift | `<<`, `>>` | left to right |
| Relational | `<`, `<=`, `>`, `>=` | left to right |
| Equality | `=`, `!=` | left to right |
| Bitwise AND | `&` | left to right |
| Bitwise XOR | `^` | left to right |
| Bitwise OR | `\|` | left to right |
| Logical AND | `&&` | left to right |
| Logical OR | `\|\|` | left to right |
| Assignment | `:=` and supported compound assignments, including `**=` | right to left |

The special power rule remains: `**` groups right, binds below call/index/field access and above multiplication, binds tighter than unary `+`, `-`, `~` on its left, and admits a unary operand on its right. Thus `-2 ** 2` is −4, `(-2) ** 2` is 4, `2 ** -2` groups as `2 ** (-2)`, and `2 ** 3 ** 2` is 512. Numerical admissibility remains the selected LMX numeric contract. `=` is comparison, corresponding to C `==`; `:=` is assignment. Commas and semicolons keep their structural roles. No C conditional or comma operator is introduced.

Before a receiver executes, the values it actually needs are obtained. A needed result can require executing another receiver of lower priority; the producer's own operands retain their written and priority-defined boundaries. This does not raise the producer's priority. An assignment head is tied to the place written immediately to its left: `1 + v := 2 + 3` must not be reparsed as assignment to `1 + v`. Here the first addition needs the result of that assignment; its RHS computes 5, the assignment writes `v = 5`, and the addition returns 6. The prior value of `v` does not replace the result of this occurrence.

Each operation occurrence executes once in one dynamic evaluation. The consumer receives its retained result, not a later reread of a mutable place. A new invocation, iteration, condition check or explicit `sys\eval` starts a new evaluation. No result cache is installed in the source graph. Ordinary name reads do not search for future assignments: `v := v + 1` reads the old `v` on the right. Neighboring operations alone create no dependency; `10 * 2 + 3` is 23.

Demand preserves short-circuiting: neither `0 && (x := 1)` nor `1 || (x := 1)` writes `x`. A skipped operand, including a call or a user operator application, does not later run because the walker reaches its record. There is no eager pass through all groups, initializers or assignments, and selection does not speculatively execute candidates.

| Expression | Result | Written value of `v` |
| --- | ---: | ---: |
| `1 + v := 2 + 3` | 6 | 5 |
| `10 * v := 2 + 3` | 50 | 5 |
| `1 + v := 2 * 3` | 7 | 6 |
| `1 + (v := 2) + 3` | 6 | 2 |
| `(1 + v := 2 + 2) * (v + 1)` | 25 | 4 |
| `v := 2 - 3` | −1 | −1 |

#### Assignment inside an actual expression

A standalone argument-position `v := expression` is a named actual. An assignment embedded inside an actual expression instead writes the corresponding place in the receiving call's namespace and contributes its value to the enclosing expression; it creates no additional actual and does not move the positional counter. “The callee's DATA” here identifies the call's declared logical places, not physical mutation of its source DATA graph.

For `f` with first formal `x` and another declared place `v`, `f(1 + v := 2 + 3)` supplies exactly one positional actual, 6, and writes 5 to that call's `v`. `f(1 + (v := 2) + 3)` also supplies 6 but writes 2. The caller's separate same-named `v` is unchanged. In contrast, `f(v := 2 + 3; 6)` contains two actuals and is allowed only if the normal named/positional ordering fits; when `v` is first, naming it at that position leaves the positional counter active. Required receiving places exist when an actual expression addresses them.

A declaration *executed inside an expression* retains ordinary declaration/admission and scope rules; its value is the value assigned. A place-declaration receiver *supplied as an actual form* is instead preserved as DATA under [declaration arguments](#declaration-arguments): transmission alone never evaluates its initializer. These are different consuming positions, not separate parsers. An ordinary `Producer()` actual remains a call.

`while` uses the surrounding callable's DATA and activation. On each evaluation of `while ((c := getchar()) != EOF)`, `getchar()` runs once, its result is written to `c`, and that same result is compared with `EOF`. For the sequence A, B, EOF there are three reads and two body executions, with `c = EOF` afterward. `while(c := getchar() != EOF)` is not equivalent: that RHS computes a Boolean, and a standalone named argument is also subject to `while`'s ordinary argument contract.

<a id="operand-receiver"></a>
### User operands: structural discovery and ordinary results

A user operand is an ordinary executable method found by normal name resolution. Its name is its operator name. Its actual DATA remains `parent(C)`; import, references, shadowing and two-way `private` apply normally. **There is no `sys\operand` registration or separate operand-name registry.** A temporary derived index during analysis is permitted, but it is not another source graph or persistent environment.

The ordinary structural header requirement is:

```lmx
operand_template:
    @: left
    []: @ right
    const: int: PASS_ARGS_AS_IS
    const: int: PRIORITY
```

All four named fields must be present in the candidate's DATA. `left` is a reference input and `right` an Array of references. `PASS_ARGS_AS_IS` must give a ready constant integer 0 or 1; `PRIORITY` must give a ready constant integer on the common expression scale before grouping is settled. Missing fields are not supplied by template checking, even if a template writes defaults. Ordinary explicit composition can construct them; `implements` only checks the actual result. Ready properties are not replaced by caller locals, and reading them executes no operator body. Cyclic or unavailable properties cannot be resolved by trial execution.

The header is an ordinary structural requirement: its names and entire explicitly stated tree matter. It does not constrain the result to `@`. A concrete method declares its normal result, such as `return: int` or `return: @`; a procedure cannot supply an expression value merely because its DATA matches the header. An optional specialized template can add `@: left int`, `[]: @(int) right`, and `return: int`. Such typed references require actual addressable integers; they do not mean unevaluated code that might later return an integer.

A positional `fn` requirement remains a different check. For example, `fn: PairSignature (@: first; []: @ rest; return: int)` can admit compatible inputs named `lhs/rhs`, but this does not establish the named structural header `left/right/PASS_ARGS_AS_IS/PRIORITY`. A callable reference is not called just because a consumer needs a value: `@: ptr add` stores the method reference, `add(...)` calls it explicitly, `a add b` applies its operator contract, and `\ptr` only dereferences.

#### Prepared values: `PASS_ARGS_AS_IS 0`

Expression analysis identifies the written left occurrence and the right occurrence sequence using groups and priorities. Needed occurrences are evaluated once. The reference to the left value is supplied to `left`, and references to the right values form `right` in source order. `(1 foo 2 3 4)` therefore supplies a reference to 1 and an Array of three references. `(foo 1 2 3 4)` has no written left actual and four right occurrences; the first right value is not moved into `left`. Omitted inputs, defaults and requiredness remain ordinary call rules. A present empty right Array differs from an omitted actual.

Each written container is one operand: `(foo A)` with an Array `A` gives one reference in `right`, and `(A foo B C)` gives one left and two right references. No general Array/string expansion is introduced. The ordinary single-Structure W/E rule keeps its defined call-selection scope. An operand has its own rule: when its `left` is an unnamed Structure and its single `right` argument is an unnamed Structure too, the parentheses on the right are opened and `right` receives all their content; a Structure returned from a function is not opened (the author's decisions of 2026-11-21 and 2026-11-22). `a foo b` cannot be textually replaced by `foo(a; b)`, because the second operator input is an Array of references.

References point at values of typed storage records, with the type code immediately before the value. A reference to a container addresses its typed descriptor. A dense `Array<T>` is not reinterpreted as `Array<@>`, and an untagged native temporary is not treated as an arena record by reading four bytes before its address. The common value-storage mechanism materializes a suitable record only when required, with ordinary lifetime.

The method returns its ordinary declared value: `return: int` produces an integer; `return: @` produces a reference. Operator use and explicit call do not remove different numbers of reference levels. Expression storage representation is an implementation matter and does not create a universal reference-return contract.

```lmx
operands:
    @: left int
    []: @(int) right
    const: int: PASS_ARGS_AS_IS 0
    const: int: PRIORITY sys\priority("+")
    return: int
    add:
        return: \left + \right[0]

Example:
    int: n
    return: int
    calculate:
        import: operands
        return: (n add 3) add n
    demo:
        return: calculate(2) + calculate(5)
```

The required results are 7 for `Example\calculate(2)`, 13 for `Example\calculate(5)`, and 20 for `Example\demo()`. This body uses one right operand; a stricter binary contract checks that length through the existing admission mechanism, while a variadic implementation explicitly visits the Array. No automatic fold or additional arity table is implied.

<a id="raw-operands"></a>
#### Original occurrences: `PASS_ARGS_AS_IS 1`

The same expression analysis determines argument boundaries but supplies references to original occurrences without executing them. Occurrences can contain literals, names, calls, assignments or groups. A handler for arbitrary source forms uses general references `@: left` and `[]: @ right`, not a physical-int requirement. Merely reading or retaining such a reference executes nothing. An unconsumed occurrence has no effects; explicit repeated evaluation repeats effects. Written groups do not force eager evaluation or remove the raw contract.

<a id="expression-eval"></a>
`sys\eval(fragment)` uses the single expression executor to obtain the ordinary value of a raw occurrence. Literals yield values, names resolve normally, and written calls execute; a stored callable reference remains a reference unless the form calls it. `\fragment` is not shorthand for evaluation. Each explicit `sys\eval` is a new evaluation with once-per-occurrence effects within that evaluation, not a persistent cache.

The occurrence retains its source evaluation context for the duration of the application, including when passed to a helper. The helper's same-named locals cannot capture it. Embedded assignments keep their receiving-DATA rule, and the original binding/private access is preserved without granting the operand new implicit access to private places. A physical source address alone does not identify a live activation; the existing context transport must retain that distinction. Raw passing extends no activation lifetime and cannot restore a finished frame. Statically known fragments may use the same prepared native implementation; neither a second parser nor a second VM is required.

The raw version of `add` uses this DATA and body:

```lmx
raw_operands:
    @: left
    []: @ right
    const: int: PASS_ARGS_AS_IS 1
    const: int: PRIORITY sys\priority("+")
    return: int
    add:
        int: a sys\eval(left)
        int: b sys\eval(right[0])
        return: a + b
```

With the same `calculate` body importing `raw_operands`, the results remain 7, 13 and 20. The outer `add` receives the original group `(n add 3)` on its left; its explicit evaluation invokes the inner raw `add`. The raw implementation controls whether and how often to evaluate an occurrence.

Before effectful operand arguments run, grouping and consumption mode must be unambiguous. Unresolved candidates with different priorities or modes produce ordinary ambiguity; candidates with identical properties can proceed to ordinary explicit-actual selection. Hidden binding never chooses an operator signature.

<a id="string-identifier"></a>
### `sys\name`: an identifier's spelling

`sys\name(identificator)` consumes one written identifier and returns its spelling as an ordinary variable-length LMX `Array<char>`. It does not resolve a variable, read its value, execute its initializer or call a same-named method. A valid identifier need not be declared. Exact-identifier quoting is removed and a doubled backtick becomes one literal backtick: ``sys\name(`long name`)`` yields `"long name"`; an empty exact identifier yields an empty string. `sys\name(ptr)` yields `"ptr"`, not the name of its target.

The existing canonical-name representation and service name table supply the spelling. No registration table, new encoding, mandatory per-call allocation or address-identity guarantee is introduced. The result is an ordinary Lmx character Array with no trailing NUL. `f(sys\name(foo))` and `f(a := sys\name(foo))` each pass one complete Array; characters are not expanded into actuals.

<a id="expression-priority"></a>
### `sys\priority`: a priority by string name

The query's named signature is `fn: PrioritySignature ([]: char name; return: int)`. This describes a call and does not create the implementation; its full implementation name is `sys\priority`. It accepts one LMX string and returns the priority of the available built-in or structurally discovered user operand with that name, using the same visibility and property information as expression analysis. `sys\priority("+")` queries addition, `"-"` subtraction and `"*"` multiplication; contextual unary/postfix uses do not arbitrarily change that query result.

Names are matched by string content at this explicit lookup boundary. A separately created string with the same contents yields the same answer; ordinary resolved identifiers still use canonical addresses. `sys\priority(sys\name(foo))` performs no call of `foo`. The query reads its ready `PRIORITY`, registers nothing and evaluates no operand arguments. Missing, unsuitable or ambiguous operands produce ordinary resolution/contract diagnostics; no priority is invented. Discovery and query share the same description, not divergent registries.

These expression rules are specified in full by the supplied [operand requirements](tasks/to_fable_operands_arguments_priorities.md).

<a id="assign-known"></a>
#### Writing a known place: `:=`

`left := right` writes an already resolved place; an unknown left side is an error and never a declaration. In CODE, it evaluates the RHS under [expression precedence and demand](#assignment-inside-expression), admits the result under the receiving contract, writes the place, and yields the assigned value. In DATA the operator remains written material and is not executed. Moving or copying the form into another context does not turn it into a declaration. Structure names themselves are constant bindings, while primitive and reference-variable places can be assigned subject to their restrictions. `ptr := other_method` stores a method reference without invoking it. A standalone argument-position assignment supplies a named actual; an assignment embedded in an actual expression follows the receiving-call place rule. No form creates fields, removes address levels or publishes a frame merely by assigning.

<a id="graph-fragment-assignment"></a>
### Explicit graph assignment replaces written material

The clean graph is a full literal reflection of the source, including primitive leaves in `{type value}`
form. `for`, `if`, `merge`, `copy`, `import`, declarations and all other receiver structures remain as
written. Their presence does not make them permanent or nonreplaceable. An explicitly selected graph
cell can receive a new graph fragment, including a different receiver Structure or other material;
there is no representation-level whitelist of editable forms or special code-only mutation API.
Ordinary scope and explicit qualification/protection contracts remain separate from that representability.
A bare constant Structure name is not thereby made into a mutable local variable.

For source `int: novalue`, the graph holds `{uninit_int}` with no value storage. A local
`novalue := 5` writes the frame and leaves that source graph unchanged. An explicit
`S\novalue := 5` replaces the graph fragment at S's selected structural place with `{int 5}`.
Fresh access through that place sees the new fragment; the language does not require in-place record
growth, a persistent proxy, or equality of old and new raw value addresses. Runtime aliasing of one
local place and two graph cells referring to the same old fragment are different relationships.

If replacing source material requires new machine code, the existing
[compilation and endturn restart boundary](#explicit-compilation) applies. Replacement does not erase
the full graph or create an alternative executable representation, and no automatic edit-tracking
mechanism is introduced. This incorporates the latest
[author clarification](tasks/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

<a id="compound-assign"></a>
#### Compound assignments and the power

The compound assignments `+=`, `-=`, `*=`, `/=`, `%=`, `<<=`, `>>=`, `&=`, `^=`, `|=`, `**=` and the power operator `**` for expressions join `:=`. A compound assignment writes a place already known with the result of the operation over its current value and the right operand: `a += b` corresponds to `a := (a + b)`, `a -= b` to `a := (a - b)`, `a *= b` to `a := (a * b)`, `a /= b` to `a := (a / b)`, `a %= b` to `a := (a % b)`, `a <<= b` to `a := (a << b)`, `a >>= b` to `a := (a >> b)`, `a &= b` to `a := (a & b)`, `a ^= b` to `a := (a ^ b)`, `a |= b` to `a := (a | b)`, `a **= b` to `a := (a ** b)`; the author's spelling of these equivalences with a C-like `=` is kept in the journal, and in LMX `=` stays a comparison. The left side is a place already known under every rule of `:=`, the `implements` admission and the error of an unknown left side included; `:=` keeps its general narrow meaning of writing a known place, method references and the named supply included, and is not narrowed to numbers. `**` is the power; `^` stays the bitwise exclusive or. The associativity and precedence of `**` are Python's (the author's clarification of 2026-11-07): `**` groups to the right -- `a ** b ** c` is `a ** (b ** c)`; it binds tighter than `*`, `/`, `%`, `+` and `-`; a call, an index and a field access form the operand before `**`; on its left `**` binds tighter than the unary `+`, `-`, `~`, on its right a unary operand is admitted -- `-2 ** 2` is `-(2 ** 2)`, `(-2) ** 2` keeps its parentheses, `2 ** -2` is `2 ** (-2)`, `2 * 3 ** 2` is `2 * (3 ** 2)`; the right side of `**=` groups the same way. Grouping and execution are distinct: reached effects follow the common LMX demand and written-order rules, not C's unspecified operand order. A compound assignment evaluates its destination once and obtains the operation result before the write; the equivalences are not textual macros that repeat destination effects. Numeric types and conversions of `**` and `**=`, negative or fractional exponents, `0 ** 0`, numeric failures and atomicity follow the selected numeric and write contracts. The selected numeric contract of integers (the author's decision of 2026-11-22): the interpreter refuses whenever the exact result of an operation does not fit the type -- `2147483647 + 1` over `int` refuses; the machine profile of L2 computes under the machine contract ([L2](L2_spec_en.md)). Numeric operations, the types of expressions and admission are not tied to `int`: the analysis and the types of expressions are the ordinary ones of typed languages, for every numeric type (the same decision). Only power grouping is taken from Python; no other Python numeric policy is implied. Implementation must preserve these results on each supported execution path; this specification is not an implementation report.

<a id="group-assign"></a>
#### Group positional assignment

Author's decisions of 2026-11-10. The left side of the `:=` operator may be an unnamed Structure of places: `(a b c) := (c, a, b)` assigns by position — the first value to the first place, the second to the second, the third to the third. The author first wrote this form with a colon, `(a b c): c, a, b`; after the rule that structural forms do not assign ([structural forms](#forms-declare-or-call)) it is written with `:=`, and a Structure as the head of a Frame before a colon is not introduced. All right-hand values are computed before the first write, so this statement rotates the three values. Each position is written by the rules of `:=`: the place must be available at the assignment site under the [common visibility rule](#declaration-visibility). Variables and `const` are visible sequentially; grouping does not change that rule. An explicit path selects a field under the ordinary path rules; this does not make its bare name visible before declaration. For name-based access, an unknown name, the name of a Structure or a function name on the left is an error, and each value passes the ordinary admission of its place. The left side is an unnamed Structure, and the unnamed Structure written on the right is the single `right` argument of the operand `:=`: the parentheses on the right are opened and `right` receives the values of the positions. When the left side is not an unnamed Structure, the parentheses on the right are not opened: `struct := (copy(args))` assigns one Structure to the reference `struct` (the author's decision of 2026-11-22). This is an assignment between unnamed Structures, the general case of assignment and not a special form (the author's decisions of 2026-11-16 and 2026-11-21). A Structure returned from a function is not opened: in `(a, b, c) := myFn()` the right side is one value ([Structure result](#structure-result)). A different number of places and values is a refusal: at translation when the number is known, otherwise at execution before the first write. A Structure on the left holds at least one place; the head `()` with empty parentheses remains the earlier separate form ([grammar](LMX_grammar.en.md#bounded)). A field stream is written inside an explicit group, which is opened the same way: `(a b) := (copy(Pair))` assigns the two resulting fields by position; the bare stream `(a b) := copy(Pair)` is an error (the author's decision of 2026-11-21). The right side of a group assignment is one unnamed Structure written in parentheses, the form `() := ()`; several values written without the group are an error (the author's decision of 2026-11-21). In `(c b d a) := (a b c d)`, starting from a=1, b=2, c=3, d=4, the final values are c=1, b=2, d=3, a=4. All RHS values precede the first write; this promises no rollback of effects already produced while computing them.
@@ qualification | const, immutable и independent | const, immutable and independent | 2.5.3; 9.1.2–9.1.3
[RU]
`const` защищает привязку: её нельзя присвоить, перепривязать или заменить. Значение за защищённой ссылкой может оставаться изменяемым. `immutable` защищает само значение на протяжении всей его жизни, через любые псевдонимы; переменная, содержащая ссылку на него, может оставаться перепривязываемой. `const: immutable` объединяет обе гарантии. Это независимые квалификации, а не ступени одной шкалы.

Неизменяемость применима к примитиву, Structure и выбранному дереву, Array с дескриптором и элементами. Она охватывает все поля и явно включённые описания, а не только пути Consumer. Передача, возврат и сохранение неизменяемого значения сохраняют его идентичность; квалификация не требует копии, в том числе для примитива. Она не замораживает внешний ресурс, обозначенный неизменяемым идентификатором.

`immutable` задаёт надтип нового значения при построении до публикации: записи получают коды соответствующих immutable-типов. Обычная уже построенная Structure, запись которой держит код изменяемой Structure, не переводится задним числом в immutable-тип: попытка `immutable: Existing` с таким значением получает отказ при потреблении. Это снимает прежнее обещание `RuntimeImmutable` переквалифицировать существующее дерево без смены адреса. Уже immutable-значение может проходить как значение своего типа без повторной переквалификации. Допуск аргумента остаётся [единым](#admission), как у прочих принимающих выражений.

Перед публикацией нового immutable-значения исследуется всё выбранное дерево. Вложенная структура является ветвью дерева только тогда, когда её обычное структурное поле `parent` указывает на рассматриваемого родителя. Внешняя ссылка, **уже сохранённая как значение данных**, допустима только на уже неизменяемый объект; она терминальна, её цель не обходится и не переквалифицируется. Собственный `parent` корня — структурная лексическая связь с узлом вне выбранного дерева, а не такая сохранённая ссылка: `immutable` без `independent` строит значение под его обычным родителем, которого не замораживает и неизменяемости которого не требует; `independent` — единственный ресивер, касающийся этой связи. Операнд сохранённого исполняемого кода до его выполнения ещё не является таким значением (см. ниже). Проверяется состояние до публикации: результат обработки раннего поля не может оправдать недопустимую внешнюю ссылку в позднем. Если исходное объявление `immutable` нарушает это условие, транслятор отказывает в построении; даже при интерпретации граф сначала строится, и такой отказ не является исключением исполняемого тела. Если же ошибка обнаружена при исполняемой операции над уже существующим деревом, интерпретатор передаёт её обычным `throw`, который обрабатывается обычным `catch`, без особого канала для `immutable`. Ни один из этих случаев не превращается в `sys\assert`.

Квалификация проверяет значения и ссылки, уже сохранённые в дереве. Готовое терминальное объявление представляется непосредственно при построении чистого графа без исполнения программы; вычисляемый инициализатор не является уже сохранённым результатом. Его код не выполняется при квалификации. Результат проверяется при фактическом получении и потреблении по обычному контракту, без прогнозирования будущего тела. Это правило одинаково для data и code. Неизменяемая Structure может хранить код, который позже читает изменяемые данные, не замораживая их.

Примитивы и методы — листья, не ветви лексического дерева. Это правило описывает топологию `parent`, а не освобождает от проверки изменяемое хранилище, физически удерживаемое квалифицированным графом: сохранённая запись кода метода и уже сохранённые данные должны удовлетворять контракту неизменяемого построения. Отложенные операнды являются кодом, а не своими возможными будущими значениями; ячейки последующей активации эта проверка не замораживает. Ссылка на массив также не создаёт ветвь `parent`: операция над деревом не замораживает неявно изменяемое хранилище внешнего массива. Неизменяемый массив строится по собственному контракту. Принадлежность ячейки служебному пулу не даёт права обходить или квалифицировать весь пул.

Квалификация нового значения завершается только после успешной полной предварительной проверки. При неудаче нет частично опубликованного immutable-дерева или успешного результата; запрещено молча пропускать ветвь, копировать уже существующий обычный объект ради смены его типа или перенаправлять ссылки. Уже immutable-значение не нуждается в повторной квалификации. Правило не откатывает ранее выполненные инициализаторы, вычисление аргументов или явные записи в граф; транзакция графа не возникает.

Защита применяется к фактической записи в защищённое значение; локальные кадры в граф не публикуются. Ресивер immutable проверяет уже построенное значение и сохранённые ссылки по правилам выше; он не прогнозирует записи будущего исполнения сохранённого тела и не требует доказательства их отсутствия. Вне явно написанного test такой анализ не выполняется. Если достигнутая запись затрагивает защищённое место, общий runtime-механизм отказывает до изменения этого места. Это относится и к собственному сохранённому телу, и к внешнему коду. Сам вызов метода не снимает защиты. Изменение локальной копии аргумента или перепривязка локальной ссылки не меняют защищённое значение. Построение нового значения, в том числе merge, не размораживает исходное. См. уточнение автора от 1 ноября.

`independent` при построении устанавливает у корня `parent = 0`; это и есть отсутствие внешнего лексического родителя. Внутренние связи `parent` дерева и собственные поля сохраняются. Квалификация не обнуляет задним числом `parent` уже существующих объектов и не запрещает явно переданные ссылки, динамические аргументы текущего вызывающего выражения, сообщения или выбор вызываемого выражения по совместимой сигнатуре. Это не требование чистоты и не закрытый интерфейс только из явных аргументов.

`const`, `immutable` и `independent` являются принимающими выражениями; их композиция задаёт квалифицированный тип результата. Действию каждого из них нужен один аргумент, поэтому аргументов можно записать несколько, и действие применяется к каждому по очереди, в записанном порядке: в `const: int: a 1; int: b 2`, в `const(int: a 1; int: b 2)` и в блоке под `const:` с двумя объявлениями аргументов два, и это то же, что две записи с одним аргументом. Сколько аргументов передано и какие они, определяет запись по общим правилам разбора, а не наличие скобок. Так же записываются [`private`](#private-binding) и [`required`](#required-receiver) (уточнения автора 2026-11-18). Аргументы эти ресиверы принимают как `data`, поэтому аргумент, который сам является Structure, они не раскрывают: в `const: (int: a 1; int: b 2)` и в блоке под `const:`, где записана одна безымянная Structure с этими объявлениями, аргумент один — эта Structure ([два вида ресиверов](#two-kinds-of-receivers); уточнение автора 2026-11-18). `immutable` — надтип значения, задаваемый при построении. Для каждого базового типа есть соответствующий код immutable-типа. Обычные и immutable записи выделяются одним и тем же механизмом потока записей арены; immutable-Structure не требуют отдельного пула, а пользовательские модели полей не создают новых физических типов. Квалификация одной Structure не распространяется на посторонние значения; все псевдонимы построенного immutable-значения видят один и тот же надтип: его держит код в записи значения. Запись значения описана в [L2](L2_spec_ru.md#value-record); не вводится новый тип на каждую модель Structure или дополнительная таблица связывания имён для квалификаторов. Нулевой `parent` корня остаётся структурным следствием `independent`, а не заменой классификации типа. Как принимающие выражения они стоят везде, где принимается значение Structure, — в хвосте объявления, в `return:` метода, операндом `merge`, — и компонуются в том порядке и составе, в каком написаны в исходнике, каждое со своим контрактом; цепочка над именованной Structure в корне модуля — один из случаев этого чтения, а не его определение.

Например, метод внутри независимой структуры S может использовать поле S через внутреннюю лексическую связь. Требуемое `x` может прийти из текущего вызывающего выражения. Если `x` находится только в прежнем текстовом окружении S, внешнего неявного доступа к нему нет. Явно переданный большой массив не становится меньше и не копируется из-за `independent`. Особый срок жизни сочетания трёх квалификаций описан в [вечных ветвях](#eternal).
[EN]
`const` protects a binding: it cannot be assigned, rebound or replaced. The value behind a protected reference may remain mutable. `immutable` protects the value itself for its entire life through every alias; a variable holding its reference may remain rebindable. `const: immutable` combines both guarantees. They are independent qualifications, not degrees of one scale.

Immutability applies to a primitive, a Structure and its selected tree, or an Array with its descriptor and elements. It covers every field and explicitly included descriptions, not just Consumer's paths. Passing, returning and storing an immutable value preserve its identity; qualification requires no copy, including for a primitive. It does not freeze a foreign resource denoted by an immutable identifier.

`immutable` gives a new value its supertype during construction, before publication: records get the codes of the corresponding immutable types. An ordinary Structure already built, whose record holds the code of a mutable Structure, is not retroactively converted; `immutable: Existing` on that value refuses at consumption. This supersedes the earlier promise that `RuntimeImmutable` would requalify an existing tree without changing its identity. An already immutable value can pass as a value of its type without requalification. Argument admission remains [unified](#admission), as for every receiving expression.

The whole selected tree is examined before the new immutable value is published. A contained Structure is a tree branch only when its ordinary structural `parent` field points to the parent being examined. An outside reference **already stored as a data value** is permitted only to an already immutable object; it is terminal, and its target is neither traversed nor requalified. The root's own `parent` is a structural lexical link to a node outside the selected tree, not such a stored reference: `immutable` without `independent` constructs the value under its ordinary parent, which it neither freezes nor requires to be immutable; `independent` is the one receiver that touches that link. An operand of stored executable code is not such a value before that code runs (see below). The pre-publication state is checked: processing an earlier field cannot justify an invalid outside data reference in a later field. If a source `immutable` declaration violates this condition, the translator refuses construction; even under interpretation the graph is built first, so this refusal is not an exception thrown by the executable body. If an executed operation on an already existing tree encounters an error, the interpreter uses the ordinary `throw` caught by the ordinary `catch`, with no special `immutable` channel. Neither case becomes an `sys\assert`.

Qualification checks values and references already stored in the tree. Ready terminal declarations are represented directly during clean-graph construction without program execution; a computed initializer is not an already stored result. Qualification does not execute it. Its result is checked when actually obtained and consumed under the ordinary contract, without predicting future body behavior. This is the same for data and code. An immutable Structure can hold code that later reads mutable data without freezing that data.

Primitives and methods are leaves, not lexical-tree branches. This describes the `parent` topology, not an exemption for mutable storage physically retained by the qualified graph: a saved method's code record and already stored data must satisfy the immutable construction contract. Its deferred operands are code, not their possible future values, and cells of a later activation are not frozen by this check. An Array reference likewise establishes no `parent` branch: a tree operation does not implicitly freeze an outside Array's mutable backing. An immutable Array is constructed under its own contract. A cell's membership in a service pool does not permit traversal or qualification of the entire pool.

Construction of an immutable value completes only after successful full preflight. Failure leaves no partially published immutable tree or successful result; silently skipping a branch, copying an already existing ordinary object merely to change its type, or retargeting links is prohibited. An already immutable value needs no requalification. This rule does not roll back earlier initializers, argument evaluation or explicit graph writes; it establishes no graph transaction.

Protection applies to actual writes to protected values; local frames are never published into the graph. The immutable receiver checks the constructed value and stored references under the rules above; it neither predicts writes by future execution of the saved body nor requires proof of their absence. Such analysis is not performed outside an explicitly written test. If a reached write targets a protected place, the shared runtime mechanism refuses before changing that place. This applies both to its own saved body and to external code. Calling a method does not remove protection. Changing a local argument copy or rebinding a local reference does not change the protected value. Constructing a new value, including merge, does not thaw the original. See the author clarification of November 1.

Construction-time `independent` sets the root's `parent = 0`; that is exactly the absence of an external lexical parent. Internal tree `parent` links and own fields remain. The qualification neither retroactively clears existing objects' `parent` links nor prohibits explicitly supplied references, current-caller dynamic arguments, Messages or selection of a callable by a compatible signature. It does not require purity or an interface closed over explicit arguments alone.

`const`, `immutable` and `independent` are receiving expressions; their composition establishes the result's qualified type. The action of each needs one argument, so several arguments may be written and the action applies to each in turn, in the written order: in `const: int: a 1; int: b 2`, in `const(int: a 1; int: b 2)` and in a block under `const:` with two declarations there are two arguments, and that is the same as two forms with one argument each. How many arguments are passed and what they are is determined by the form under the general rules of parsing, not by the presence of parentheses. [`private`](#private-binding) and [`required`](#required-receiver) are written the same way (the author's clarifications of 2026-11-18). These receivers take their arguments as `data`, so an argument that is itself a Structure is not unwrapped: in `const: (int: a 1; int: b 2)` and in a block under `const:` where one anonymous Structure with these declarations is written there is one argument -- that Structure ([two kinds of receivers](#two-kinds-of-receivers); the author's clarification of 2026-11-18). `immutable` is a supertype determined when the value is built. Each base type has a corresponding immutable type code. Ordinary and immutable records are allocated by the same arena record-stream mechanism; immutable Structures do not require a separate pool, and user field models do not create new physical types. Qualifying one Structure does not affect unrelated values; every alias of a constructed immutable value sees the same supertype: the code in the value's record holds it. The value record is described in [L2](L2_spec_en.md#value-record); this does not introduce a new type for every Structure model or an additional qualifier-specific name-binding table. A zero root `parent` remains the structural consequence of `independent`, not a replacement for type classification. As receiving expressions they stand wherever a Structure value is received -- a declaration's tail, a method's `return:`, a `merge` operand -- composed in the order and part the source writes, each with its own contract; the root-level chain over a named Structure is one case of that reading, not its definition.

For example, a method inside independent Structure S can use S's field through its internal lexical link. Required `x` can come from the current caller. If `x` exists only in S's former textual surroundings, implicit external access is unavailable. An explicitly passed large Array neither shrinks nor gets copied because of `independent`. The special lifetime of the three qualifications together is described under [eternal branches](#eternal).
@@ callables | Вызываемые выражения и их интерфейсы | Callable expressions and their interfaces | 7–7.3; 7.5.1; 8.5–8.8; 19.21; 21.9
[RU]
<a id="declaration-visibility"></a>
### Видимость объявлений

Переменные, включая `const`, видны с первоначального объявления вперёд на своём лексическом уровне и во вложенных областях. До объявления это локальное имя не участвует в поиске; доступные внешние и динамические имена разрешаются по общим правилам. Двусторонняя видимость остаётся у имён именованных Structure и callable. Переменная с указателем на callable остаётся переменной. Правило одинаково для разрешения головы и других употреблений имени; скобки и trailer его не меняют. Уточнение автора.

Последовательная видимость голого имени не ограничивает явный выбор поля построенного графа: `D\field` (путь от Structure данных `D`), `S[n]` и `S\[n]field` используют обычную адресацию. Наличие поля в графе не означает, что его вычисляемое значение уже получено.

Вызов создаёт новый namespace. Подготовка собирает корневые объявления данных и кода: данные — это `parent(C)`, а код — исполняемый `C` ([структурный вызов](#call-receivers)). Сюда входит явное потребление потока в рамках [общего контракта namespace](#data-root-declaration-execution); подготовка не исполняет заранее вычисляемые инициализаторы мест и не поднимает произвольные вложенные объявления в корень. Входные места данных доступны исполняемому коду как входы этого вызова; сбор корня code не делает его будущие переменные видимыми до их объявлений. Имя новой ветви видно на своём уровне и ниже, а снаружи — нет. Повторное объявление имени на том же уровне использует уже существующее локальное место; поданная RHS сохраняет вычисление, допуск и присваивание. Объявление на вложенном уровне создаёт собственное место и затеняет внешнее место с тем же именем ([уровни объявлений](#shadowing-levels)).

Описание вызываемого — данные с общими правилами видимости и выбора повторных вхождений. Положение описания входов, поля `return` и кода не создаёт отдельного правила раннего вычисления. Входы сопоставляются namespace вызова без исполнения вычисляемых объявлений. Общий разбор не размечает роль поля по частному имени.

Файлы программы не образуют категорий «основной» и «часть»: message — Structure, подключённые файлы встраиваются в граф программы. Порядок объявления переменных и `const`, как и двусторонняя видимость именованных Structure и callable, определяется получившимся лексическим деревом. Сравнение смещений строк разных исходных документов видимость не определяет.

Сигнатура описывает входы и результат; она не является исполняемым телом ([сигнатура `fn`](#fn-signature)). Запись формала не выполняет вызов, объявление или присваивание, которое та же запись могла бы означать в теле. Формалы объявляются ресиверами — `int: arg default`, `@: arg Template`; структурная запись формал-переменную не объявляет: в роли данных она — объявление Structure (так записывается, например, структурный результат в поле `return`), и прежняя синонимия двух описаний формала в сигнатуре — структурной записью и ресивером — снята ([роли `data` и `code`](#data-code-roles)). Подача фактического аргумента выполняет предусмотренные контрактом преобразования и допуск, но не исполняет описание формала как оператор тела. Использование полученного параметра в теле разрешается по его контракту и общим правилам выражений, а не исполнением текста сигнатуры.

<a id="method-parts"></a>
### Части вызываемой Structure

Входные места, требования и значения по умолчанию исполняемого C принадлежат фактическому `parent(C)`; его описание результата — поле `return` этого DATA. Сам C — это code. `args` у call — фактический поданный материал, а не отдельная часть функции. `fn: name data` создаёт именованное позиционное требование и не создаёт реализации. Разные наборы поданных аргументов могут давать разные нативные сигнатуры, тогда как скрытые служебные параметры не становятся позициями входов fn. Catch сохраняет роль обработчика с тем же общим представлением входов и фактического родителя ([catch](#catch-common-model)).

Повторяющиеся физические объявления DATA сохраняют различные вхождения и могут требовать выбора по индексу. Достигнутые объявления ресиверов CODE на одном уровне вместо этого обновляют существующее логическое место. `call(C)` выбирает сам C: он не выбирает ни дочернее поле code, ни дочернее поле данных. Эти различия следуют обычным правилам ролей и namespace, а не отдельному поиску вызова.

Callable — это обычная Structure, выбранная для исполнения. Её DATA — это её фактический родитель; именованная сигнатура — отдельное требование. Головы разрешаются через канонические имена, а подготовка вызова читает корневые объявления в локальный namespace по [общим контрактам ресиверов](#data-root-declaration-execution), включая явные потоки полей, не исполняя заранее вычисляемые инициализаторы мест и не дополняя исходный граф локалами тела. Все формы ресиверов сохраняются, причём терминальные примитивные объявления входят в своё прямое представление типизированных листьев; исполнение меняет места namespace или явно адресованные данные программы, а не неявный подменяемый граф.

Любая Structure исполняется в роли кода ресивером `call` или записью по имени в коде: `S()` равнозначно `call(S)`, `S(args)` — `call(A S)` при тех же выбранных фактических аргументах `A`; данными в обоих случаях служит `parent(S)` ([структурный вызов](#call-receivers)). Явные пути сохраняют исходный граф; локальные места подготавливаются в namespace по корневым объявлениям без дополнения графа. Внешние имена связываются по общему порядку ([связывание](#binding-places)) и не становятся полями данных по совпадению имени. `node` сохраняет прежний смысл. Общие правила повторных вхождений, ролей данных и кода и допуска действуют для всех форм; отдельного исполнительного пути нет. Подробнее — [кадр вызова](#call-frame-20261115).

Callable — просто Structure: ресивер запуска не выбирает часть внутри поданной Structure — `call(A s)` исполняет саму `s`, дочернее поле `code` автоматически не ищется (решение автора 2026-11-16; подробнее — [структурный вызов](#call-receivers)). Обычный объявленный вход необязателен, если только его не ограничивает входной `required`: вход без значения, которому не подано значение, вызову не отказывает; его заполняет [автозаполнение](#binding-autofill), а где оно неприменимо, вход держит «T без инициализации»; что данное поле инициализировано, проверяет ресивер [`required`](#required-receiver) (решение автора 2026-11-16).

Структурная запись в исполняемом code, включая name:... end: name, вызывает свою голову; это не объявление или присваивание исходных данных ([роли](#data-code-roles)). Поэтому блок data: в исполняемом code тоже запускает свою голову с собственным хвостом на месте аргументов; особого смысла у имени `data` нет ([что снято](#removed-builtins)). Данные и код описывают структурно: код записывают вложенной Structure внутри её данных, и вызов выбирает это вхождение; именованное определение само своего содержимого не исполняет.

Ресивер объявления переменной в code работает с локальным namespace вызова: первое объявление вводит место, повторное на том же уровне сохраняет RHS, допуск и присваивание этому месту, а объявление на вложенном уровне создаёт своё место ([уровни объявлений](#shadowing-levels)). Вложенный if/for остаётся той же активацией; новое имя ветви видно в ней и ниже, снаружи не видно. Ни глубина записи, ни отсутствие одноимённого поля данных не требуют добавления поля в граф: code-локалы не обязаны иметь соответствие в исходных данных. Подготовка учитывает корни данных и кода и их явные контракты потоков, не выполняя заранее вычисляемые инициализаторы мест и не открывая будущие локалы. Физические повторные поля данных остаются отдельными вхождениями и выбираются явным D\[N]y; D\y при повторе неоднозначно. Контракты вызова и обычный допуск поданных входов сохраняются; это не проверка обязательного наличия всех code-локалов в D. См. [кадры](#call-frame-20261115).

Явный `call` подчиняется той же модели свежего namespace. Корневые объявления данных `D = parent(C)` дают входные места, корневые объявления `C` — остальные местные места. Подготовка использует [общие контракты namespace и явных потоков](#data-root-declaration-execution); она не меняет `D` и `C` и не исполняет вычисляемые объявления мест заранее. Явные пути от `D` и путь `code\` сохраняют исходные `D` и `C`.

Ни вход в вызов, ни запись в граф не обнуляют native. Локальная запись меняет только namespace, явная запись — исходный граф. Обновление машинного исполнения требует [явной компиляции](#explicit-compilation); один endturn его не выполняет.

Исполняемое тело — это структурное выражение. Объявление его не исполняет; голое имя обозначает его ссылку; `A()` или `call(A)` явно исполняют его с учётом общего выбора аргументов. `A()` не имеет записанного фактического аргумента, тогда как `A: ()` содержит одну пустую Structure и следует контракту приёма. Результат описывается полем `return` родителя; без этого описания вызов не поставляет значения результата. Объявленные throws и другие ограничения вызова остаются ограничениями кандидата, а не политиками, переданными из шаблона fn.

Голый `return` завершает исполнение без значения; `return: value` допустим лишь там, где результат описан полем `return` данных ([`return` в данных](#return-in-data)). На уровне открытия `return` также может быть trailer любой callable-Structure по общему правилу грамматики; для невызываемой Structure это не закрыватель. Явный `end: Name` не обязателен, а завершение тела без `return` не создаёт узел возврата.

Путь через Structure читает поле и не добавляет вызова выбранной Structure или callable. Вычисляемое объявление путь тоже не исполняет: он читает его запись ([явный путь](#path-reads-no-execution)). Путь от данных — `D\x` при `D = parent(M)` — адресует исходный граф; голое `x` и `@x` в вызове адресуют логическое место, выбранное связыванием ([связывание](#binding-places)). Собственное место вызова и поле графа — разные места даже при одинаковом начальном значении.

Вхождение callable сохраняет собственную структурную идентичность, фактического родителя и установленный лексический контекст. DATA следует за фактическим родителем выбранного исполняемого C; node сохраняет лексическую операцию выбранного вхождения и не перепривязывается путём, которым найден C, адресом общей C-функции или получателем потока. Разные вхождения code могут разделять совместимую нативную реализацию, сохраняя собственные данные и связи. Копирование графа сохраняет эти связи или перенаправляет их через своё отображение. Вложенное объявление не захватывает кадр вызывающего в скрытом окружении.

Вход создаёт локальный кадр без обратной публикации. Обязательная копия исполняемого code отменена: для правок кода до endturn момент применения не гарантируется, а обновление native требует явной компиляции. Остальные правила исполнения общие для native и обходчика. Связывание передаётся скрытыми аргументами без копии лексического окружения — значением для собственного места, адресом ячейки для места вызывающего ([исполнители](#binding-executors)); [граница](#explicit-compilation).

Исходные данные с полем `return` и код принадлежат графу — данным `parent(C)` и самой `C`; локальный namespace принадлежит активации. Повторное объявление переменной в коде на том же уровне сохраняет проверку типа, вычисление и присваивание; только повторная C-декларация не выпускается.

Именованная Structure может получать явные фактические аргументы через объявления входов своего фактического родителя, а прочие значения, используемые её телом, по-прежнему требуют разрешения. Её явно построенные поля остаются в самой Structure; `call` не создаёт в ней дополнительных полей по упоминаниям внешних имён. Корневые места данных доступны коду как входы вызова; подготовка не отменяет последовательной видимости переменных и const в исполняемом лексическом дереве. Объявление ресивером в code, которому нет соответствия в данных, задаёт локальное место вызова, а не требование дополнить исходные данные. Namespace готовится по корням данных и кода и их явным контрактам потоков, не исполняя вычисляемый RHS места заранее. Голое имя будущего локала ещё не видно; раннее чтение через явный путь не отменяет исполнения строки объявления при её достижении ([согласованные уточнения](#activation-history)). Для внешнего имени без собственного объявления место выбирается во время исполнения по общему порядку: помеченный `private:` лексический источник, прозрачное место вызывающего, прежнее связывание ([связывание](#binding-places)). Так, `named_called_struct` может читать внешнее `k` и присваивать ему, но поле `named_called_struct\k` не возникает, если оно явно не объявлено внутри Structure. Куда попадает запись, определяет выбранный путь: через прозрачное место вызывающего она сразу меняет локальную переменную вызывающего, через прежнее связывание — собственную рабочую копию и источник не переписывает; поле графа меняется только по явно записанному пути. Отдельного режима разрешения внешних имён для именованной Structure нет.

Различие сохраняется и внутри одной Structure: `int: a` создаёт типизированное место (в данных запись ресивера объявляет место, в коде она на своей строке проверяет тип и, если записано значение, присваивает — [роли `data` и `code`](#data-code-roles)), а последующий оператор `a := get_a()` вычисляет и записывает новое значение при достижении этой строки. Объявление code определяет локальное место вызова, а не дополнение исходных данных; подготовка namespace не исполняет вычисляемый оператор заранее. Совместное хранение частей в графе не делает их взаимозаменяемыми.

Выбор вызова начинается с явной ссылки, структурного пути либо текстового пути с явно переданным корнем. Выбор реализации и подача её аргументов — разные действия. Обнаруженный кандидат проходит [допуск](#admission); затем вызов получает входы сигнатуры: объявленные входы подчиняются своему обычному контракту необязательности/обязательности ([структурный вызов](#call-receivers)), а у внешних (динамических) входов должен быть источник. Наличие подходящего поля с методом ещё не обеспечивает его динамические входы. Передача метода как данных не равна его вызову.

<a id="call-receivers"></a>
<a id="structural-call"></a>
### Структурный вызов

Выбранная Structure C исполняется как CODE; её фактический родитель поставляет DATA. Вызов не может поставить подменяющего родителя или автоматически выбрать внутреннее тело. Эти формы используют общие механизмы выбора, namespace, связывания, допуска и возврата результата.

| Форма после однозначного выбора | Исполняемый объект | Явные фактические аргументы | Данные |
|---|---|---|---|
| `call(C)` | `C` | не поданы | `parent(C)` |
| `call(A C)` | `C` | Structure `A` | `parent(C)` |
| `C()` | `C` | пустой хвост | `parent(C)` |
| `C(args)` | `C` | написанные фактические аргументы по общему алгоритму | `parent(C)` |

`args` — Structure фактически передаваемых значений, ровно та, которая является структурой аргументов обычного вызова. Это не объявления формалов, не сигнатура и не отдельная часть callable. Входные места, требования и умолчания описывают данные `parent(C)`; там же полем `return` описан результат ([`return` в данных](#return-in-data)). `code` — исполняемая Structure: `call` исполняет саму выбранную `C`, дочернее поле `code` автоматически не ищется.

У `call` две формы — два отдельных объявления: `call(code)` и `call(args code)`. Параметры называются `args` и `code` и обязательны, `required`: у одноаргументной формы — `code`, у двухаргументной — `args` и `code`; поэтому отсутствие `args` не делает двухаргументную форму подходящей для `call(code := C)`. Объявление выбирается по вызову общим алгоритмом, без исключения для встроенного `call` ([выбор объявления по вызову](#declaration-selection)): если целая `C` подходит форме `call(code)`, а её поля — форме `call(args code)`, запись `call(C)` — ошибка неоднозначности; `call(code := C)` явно подаёт `C` как `code` и раскрытие этого аргумента исключает. Именованные аргументы самого ресивера обычные: `call(args := A; code := C)`; имена членов `A` обозначают входы из данных, а не части ресивера.

Таблица не отменяет выбор чтения единственного структурного фактического аргумента: `C(A)` может принять `A` целиком или выбрать передачу её полей — это определяет [выбор объявления](#declaration-selection). Равенство эффекта разных записей проверяется при одинаковых выбранных фактических аргументах, а не произвольной текстовой подстановкой: при одних и тех же выбранных `A` запись по имени и `call(A C)` — один вызов.

Для `args` действуют обычные позиционная и именованная подача, порядок вычисления, проверка формы вызова, допуск и передача целой Structure. Уже полученные значения не вычисляются повторно. Поданная форма объявления места сохраняет свой контракт DATA и при передаче не сводится к вычисленному значению. Поданный фактический аргумент заменяет соответствующее описание места в свежем namespace; исходные данные и код не меняются, входного исполнения инициализаторов нет. Интерпретатор направляет вызов по имени, вызов через указатель и обе явные формы `call` в один механизм связывания, допуска, кадра, исполнения и передачи результата; второго исполнительного пути для обработчика `catch` или явного ресивера нет. Достигнутые вызовы из test и преобразователей используют тот же путь. Служебные C-функции, мост и диспетчер `call` не подменяют контекст вызывающего своими служебными локалами: источники языка определяет программное место вызова. Уточнение автора 2026-11-15 о том, что `args` передаёт значения, а не описывает входы, сохраняет силу.

Callable — просто Structure (решение автора 2026-11-16). Особого правила для вызываемого у ресивера запуска нет: он не выбирает часть внутри поданной Structure. В `call` можно передать любую Structure (уточнение автора 2026-11-16): исполняется поданный объект по его фактическим полям и общим правилам; запрета, автоматического выбора тела и особого порядка для вызываемого нет, а что при этом наблюдается — следствие общих механизмов, отдельной нормой не закрепляемое.

```text
Counter:
    int: steps 0

Step:
    int: x 5
    add:
        Counter\steps := Counter\steps + x

Step\add()
Step\add(x := 2)
call(Step\add)
```

Объявления записаны в данных, три записи вызова — в коде. Во всех трёх исполняется `add`, а её данные — `Step`: `x` — собственное объявленное место вызова, описанное данными. Первая и третья записи фактических аргументов не подают, и `x` берёт своё значение 5; вторая подаёт 2. После трёх вызовов `Counter\steps` равно 12. Запись `Step()` исполняла бы саму `Step` — другую Structure; `add` она автоматически не ищет.

Подставить другие данные самим вызовом нельзя: для другой комбинации данных и кода сначала создаётся нужная структурная связь — объявлением, копией или `merge` по их правилам о `parent`, — затем вызывается выбранное вхождение `C`. Запись `NewContainer: ExistingCode` хранит ссылку на `ExistingCode` и его `parent` не меняет ([двоеточие объявляет](#colon-declares)), поэтому прежний `call(NewData ExistingCode)` она сама не заменяет. Копирование и `merge` сохраняют или перенаправляют `parent` по действующим правилам копирования. `node` и его явный лексический доступ сохраняются для фактически выбранного вхождения.

Входы необязательны, если только контракт их приёма, включая входной `required`, не исключает пропуск. Объявленное входное место данных, которому не подано значение и у которого нет значения в объявлении, вызову не отказывает: его заполняет [автозаполнение](#binding-autofill), а где оно неприменимо, место держит «T без инициализации», и вызов исполняется.

```text
E:
    int: x
    step:
        int: i
        i := 5
        Counter\steps := Counter\steps + i

E\step()
call(E\step)
```

Оба вызова исполняются, потому что x — обычный необязательный вход: пропуск без инициализатора оставляет его неинициализированным, если только разрешённое автозаполнение не подаёт значение. Обязательность входа, напротив, может отвергнуть вызов при выборе; отдельный достигнутый required в CODE проверяет место в его текущем состоянии. Отсутствующее внешнее имя, которое фактически используется и для которого нет разрешённого источника (вызывающего, активации или лексического), по-прежнему отвергается по правилам [связывания](#dynamic). Необязательные объявленные входы не дают права выдумывать значения свободных имён.

<a id="root-entry"></a>
#### R0: вход без данных

R0 — обычный метод, написанный на C, с локальным указателем на граф R0. Интерпретатор работает также на скомпилированном бинарнике и имеет этот бинарный R0. На границе языка R0 начинается как процедура без DATA и без пользовательских фактических аргументов. Никакая искусственная связь D=C, пустая служебная Structure DATA или синтетическое поле данных не компенсирует её отсутствие. R0 может содержать исполняемые объявления и использовать обычные доступные ссылки; внутренние параметры запуска рантайма и доступ к графу нативного корня не становятся пользовательскими аргументами. Отсутствие DATA влияет на связывание входов, а не на общую классификацию записанных форм: исполняемые объявления-ресиверы и вызовы следуют своим обычным контрактам CODE, а форма, принятая как DATA, следует контракту DATA этого ресивера. Никакого разбора, специфичного для корня, неявного самовызова или подменяющего объекта DATA не вводится.

<a id="removed-builtins"></a>
#### Что снято нормой 2026-11-19

Сняты (ТЗ 2026-11-19, §4.4): особый смысл имени `data` — зарезервированное имя явной ссылки на данные запуска, путь `data\…` и запись `data := …`; отдельный параметр данных у `call`; встроенные `fncall` и `sub`; исполняемая форма `fn`. Слово «data» остаётся названием роли и обычным пользовательским именем по общим правилам; для `data`, `sub` и `fncall` различаются снятый встроенный смысл и явно объявленное обычное пользовательское имя. `node` остаётся зарезервированной операцией.

Историческая заметка о миграции: в текущем `call(D C)` D — это Structure фактических аргументов, а не подменяющая DATA; `C(D)` аналогично подаёт фактический аргумент. `call(C)` использует parent(C), а не C как собственные DATA. Старые семейства call с тремя аргументами и fncall сняты. Исполняемые объявления fn/sub заменены обычными структурными отношениями data/code и описаниями результата в фактическом родителе. Прежний путь `data\x` нужно заменить явным путём к нужной Structure; `node\x` уместен только тогда, когда задуманная цель — именно этот установленный лексический контекст. Обычное имя data и сохранённую зарезервированную операцию node нельзя смешивать.

<a id="fn-signature"></a>
#### Именованная сигнатура: `fn: name data`

`fn` принимает ровно два аргумента, оба в роли DATA: атом имени и обычную Structure, поставляющую её шаблон данных. Он создаёт константное именованное описание позиционной сигнатуры вызова без исполняемого тела и нативной точки входа. Это имя можно повторно использовать как требование и импортировать по [правилу корневой константы](#import-receiver). Выбор W/E для фактических аргументов CODE не разворачивает два аргумента `fn`.

```lmx
fn: SumSignature (int: a; int: b; return: int)

SumContext:
    int: a
    int: b
    return: int
    sum:
        return: a + b

@: sumPtr SumSignature SumContext\sum
```

Три аргумента `@` — это имя ссылки, требование сигнатуры и фактический callable. `sumPtr(a := 2; b := 3)` и прямой вызов `SumContext\sum(a := 2; b := 3)` возвращают 5. `SumContext()` исполнил бы другую Structure и не выбирает `sum` автоматически. Обычная двухаргументная форма `@: p Model` вначале указывает на сам `Model`; она не придумывает реализацию для сигнатуры.

Позиции входов — это обычные объявленные входные места шаблона данных по порядку. `return` описывает результат и не является входом; вложенная пользовательская Structure автоматически не становится формальным параметром, а Array — один вход независимо от числа элементов. Отсутствие `return` означает процедурную сигнатуру. Структурированный результат записывается обычной нотацией DATA:

```lmx
PairData:
    int: count
    return:
        int: x
        int: y

fn: PairSignature PairData
```

#### Позиционная ветвь `implements`

Общий `implements` имеет отдельное правило для разрешённого требования `fn`. Оно извлекает упорядоченные типы входов и наличие и тип результата из именованного описания, получает соответствующий контракт кандидата `C` из его фактического `parent(C)` и сравнивает соответствующие позиции. Количество и порядок входов имеют значение; необязательные входы и входы со значением по умолчанию остаются позициями. Типы включают фактические требования LMX к типизированным ссылкам, элементам Array и структурным результатам, а не только размеры в C или сырые теги.

Формальные имена, значения инициализаторов и деревья тел реализации не являются критериями сопоставления fn. Позиции кандидата никогда не переставляются, чтобы совпасть по именам. Скрытые нативные аргументы, динамически связываемые свободные имена и локальные имена CODE не являются дополнительными явными позициями. Сравнение не выполняет ни тела, ни инициализатора и не создаёт второго парсера или движка допуска. Оно не подставляет шаблон вместо `parent(C)`.

Обычная Structure, явно используемая как структурная модель, вместо этого требует **всего заявленного дерева**, включая любое поле метода и поддерево, которое она включает; дополнительные поля кандидата допускаются. Проверка используемого интерфейса для конкретного Consumer остаётся отличной от этого явного обязательства шаблона. Для модели, которая должна требовать только вход и результат, запишите минимальное дерево:

```lmx
PrioritiesTemplate:
    []: char name
    return: int

Priorities:
    []: char name
    return: int
    lookup:
        return: sys\priority(name)

fn: PrioritySignature PrioritiesTemplate
@: priorities_data PrioritiesTemplate Priorities
@: priority_fn PrioritySignature Priorities\lookup
```

`implements(Priorities, PrioritiesTemplate)` проверяет весь минимальный шаблон, в котором нет требования `lookup`. Выбор всего `Priorities` как структурной модели включает `lookup` и его заявленное поддерево. `PrioritySignature`, напротив, проверяет упорядоченные типы входов и результат выбранного вызываемого; `name` не обязано физически находиться внутри `lookup`. Ни поле `return`, ни имя, оканчивающееся на «Signature», не превращают обычную Structure в `fn`.

Та же композиция может быть записана как `PrioritiesMerged: merge(PrioritiesTemplate (lookup: return: sys\priority(name)))`. Обычно это объявляет `PrioritiesMerged`; `merge` принимает свои источники как стандартные аргументы CODE и поставляет свои поля через namespace. Простая ссылка `PrioritiesTemplate` и анонимная Structure являются значениями, а не вызовами этих Structure. Содержимое группы сохраняет обычные контракты. В частности, передача Structure, содержащей `lookup`, не выполняет этот метод или его вызов `sys\priority`. Копирование сохраняет фактические лексические и DATA-связи выбранного метода через общее отображение; принятие потока — не произвольная смена родителя.

#### Публичные метки и собственный контракт кандидата

При вызове через ссылку, ограниченную `fn`, формальные имена сигнатуры являются публичными метками явных фактических аргументов. Обычное позиционное и именованное отображение сначала определяет позицию сигнатуры; эта позиция отображается на вход кандидата с тем же индексом. Собственные имена кандидата используются прямыми вызовами и не являются запасными псевдонимами публичного интерфейса. Фактические выражения по-прежнему вычисляются один раз в порядке записи, а не в порядке позиций. Фактические аргументы в форме объявления используют то же внешнее отображение, не меняя внутреннего имени сохранённой формы ([аргументы в форме объявления](#declaration-arguments)).

```lmx
fn: SelectSignature (int: count; []: char text; return: int)

First:
    int: n
    []: char s
    return: int
    select:
        return: n

Reordered:
    []: char text
    int: count
    return: int
    select:
        return: count

@: chosen SelectSignature First\select
```

В CODE `chosen(text := "x"; count := 3)` отображает text на позицию 2 (`s`) и count на позицию 1 (`n`) и возвращает 3. Прямой вызов `First\select(s := "x"; n := 3)` также допустим. Прямой вызов `Reordered\select(count := 3; text := "x")` может быть допустим, но присваивание этого вызываемого `chosen` завершается ошибкой: `[Array<char>, int]` не совпадает с `[int, Array<char>]`. Если бы оба типа были `int`, переименованные или переставленные метки не изменили бы позиционного отображения: публичные `a=1, b=2` по-прежнему попадают в позиции кандидата 1 и 2.

Сопоставление fn извлекает форму типа; оно не переносит из шаблона ни значений по умолчанию, ни требований обязательности, ни throw, ни политики выполнения. `fn: StepSignature (int: step 1)` описывает один вход int и отсутствие результата, но его 1 не становится значением по умолчанию кандидата. Совместимый кандидат с обязательным входом может отвергнуть опущенный фактический аргумент, несмотря на положительное сопоставление fn; скрытое автозаполнение не может спасти его во время выбора. После явной подстановки неявное связывание использует реальные имена кандидата, его объявления и пометки private, а не метки fn. Положительное сравнение сигнатур никогда не доказывает идентичность алгоритмов или допустимость каждого будущего набора фактических аргументов.

<a id="return-in-data"></a>
#### `return` в данных

Результат вызова описывает поле `return` данных (ТЗ 2026-11-19, решение R11): `return: int` либо вложенный блок для [результата-Structure](#structure-result). Объявление `return` в данных ничего не присваивает и не становится общей изменяемой ячейкой рекурсивных активаций. В коде `return` — ресивер возврата: голый `return` сохраняет выход без значения, `return: value` передаёт допустимый результат туда, где он описан, а достижение конца тела `return` не создаёт. Правила структурного результата, принимающих мест и очистки сохраняются ([выходы](#exits)). И `call`, и вызов Structure по имени возвращают значение по этому контракту; прежний безусловный запрет результата у запуска обычной Structure и у `call` снят вместе с `fncall`.

<a id="named-actuals"></a>
### Именованные, позиционные и фактические аргументы в форме объявления

Самостоятельный фактический аргумент `a := value` выбирает формальный `a` и поставляет правую часть по его принимающему контракту. Через ссылку, ограниченную fn, `a` является публичной меткой этой сигнатуры и отображается на позицию кандидата; прямые вызовы используют собственные имена кандидата. `f(a := a(5))` вычисляет явный внутренний вызов один раз. Обычный фактический аргумент `a(5)` или `a: 5` — это вызов, результат которого поставляется позиционно, а не именованный фактический аргумент лишь потому, что его головная часть совпадает с формальным. Простое имя вызываемого — это ссылка, и оно ничего не вызывает.

Счётчик позиций следует одному правилу. Именование формального на текущей позиции по-прежнему считается позиционным и оставляет счётчик активным. Именование другой позиции отключает его; все последующие фактические аргументы должны быть именованными. Он никогда не перезапускается. Неизвестные явные имена, повторная подстановка и лишние фактические аргументы являются ошибками. Разделяйте именованные фактические аргументы символом `;`: `f(a := 1; b := 2)` поставляет два фактических аргумента; запятая не обязательно завершает правую часть первого присваивания.

<a id="declaration-arguments"></a>
#### Сохранение поставленного объявления

**Ресивер объявления места**, поставленный как аргумент в контексте аргументов CODE, читается как DATA. Аргумент — это само объявление, и одна лишь передача не выполняет инициализатора. Если соответствующее ему объявление найдено в принимающем DATA, поставленная форма заменяет это объявление **в namespace этого вызова**, а не сохранением её предвычисленного значения и не изменением исходного DATA. Контракт разрешённой головной части отличает ресивер объявления от обычного вызова; это правило относится к `int(item expression)` так же, как и к `int: item expression`, и не является частным случаем для имён из примеров.

| Форма фактического аргумента | Отображение | Сохраняемый материал |
| --- | --- | --- |
| Его объявленное имя найдено в принимающем DATA/интерфейсе | Обычное отображение имени/позиции | Поставленное объявление заменяет это описание namespace |
| Его внутреннее имя отсутствует | Всё объявление занимает текущую позицию как одна Structure | Ссылка на эту форму; её внутреннее имя остаётся внутри неё |
| Записано внешнее `formal := declaration` | Внешнее присваивание выбирает назначение | Объявление остаётся значением правой части со своим внутренним именем |

Таким образом, при входах `a`, затем `b`, `g(int: b producer())` поставляет описание для `b` по имени; оно не предвычисляет `producer()`, а следующий безымянный фактический аргумент нарушил бы позиционное правило. При входах `iteration`, затем `body`, объявление `int: item numbers\next()` не имеет соответствующего формального `item` и передаётся в `iteration` как одна Structure; его внутреннее имя не становится неизвестным именованным фактическим аргументом и не отключает счётчик. `iteration := int(item numbers\next())` явно выбирает `iteration` независимо от внутреннего имени.

Корневое объявление принятой формы логически дополняет корень **namespace CODE принимающего выполнения**. Каждое достигнутое выполнение этой формы повторяет её инициализатор и объявляет или обновляет то же корневое место по обычным правилам повторного объявления на том же уровне. Сохранённая форма и её последнее вычисленное значение различны: результат не заменяет исполняемую форму. Подготовка, передача и непотреблённые формы не выполняются раньше потребности.

Ассоциированное переданное тело использует установленное место напрямую. Оно не создаёт новой вычисленной копии и не повторяет инициализатор только оттого, что в него вошли или его прочитали. Физическим родителем тела остаётся исходная Structure аргумента; логическое дополнение корня не меняет ни этого родителя, ни исходный граф CODE. Настоящие вложенные области видимости сохраняют затенение. Независимые принимающие вызовы сохраняют независимые контексты, и ни передача формы, ни удержание ссылки не продлевают время жизни завершённого Frame.

```lmx
cycles:
    @: iteration
    @: body
    iterate:
        while: 1
            iteration()
            catch: Stop ()
                break
            body()

use:
    import: cycles
    run:
        iterate: int: item numbers\next()
            item *= 2

use\run()
```

Здесь `numbers` — доступный итератор, метод `next()` которого выдаёт целые числа или бросает `Stop`. [Import](#import-receiver) предоставляет константное объявление Structure `iterate`; `iteration` и `body` — обычные входы-ссылки, и они остаются в фактическом DATA `cycles`. Первый фактический аргумент сохраняет форму объявления в `iteration`; второй — связанное с ним тело. `iteration()` продвигает итератор и устанавливает/обновляет `item`; `body()` изменяет то же самое место. Его физический родитель — записанная Structure аргументов, содержащая форму объявления, а не библиотечное определение `cycles\iterate`.

| Итерация | Шаг | Тело |
| --- | --- | --- |
| 1 | Один вызов `next()` выдаёт 10; `item` становится 10 | То же место становится 20 |
| 2 | Один вызов `next()` выдаёт 20; то же место становится 20 | То же место становится 40 |
| Конец | Один вызов `next()` бросает `Stop` | Не выполняется |

Есть три вызова `next()` и два выполнения тела. Чтение `item` не добавляет вызовов. Конструкция catch охватывает весь свой блок цикла, включая `body()`, по обычным правилам обработчиков.

Именованная форма `iterate(body := (item *= 2); iteration := int(item numbers\next()))` передаёт обе Structure, не выполняя тело до шага. `iterate(iteration := int(item numbers\next()); (item *= 2))` оставляет позиционный счётчик активным после своего первого фактического аргумента. `iterate(body := (); iteration := int(item numbers\next()))` передаёт присутствующее пустое тело, а не опущенное.

Это правило не публикует все поля каждой обычной ссылки на Structure как локалы корня. Обычный фактический аргумент `Producer()` остаётся вызовом CODE, а простая передача `p := S` не выполняет весь `S` и не дополняет корень каждым полем.

#### Вычисление, приём и значения по умолчанию

Проверки формы вызова, доступные до выполнения эффектов, идут первыми: неизвестное явное имя формального параметра в `f(x := touch())` не запускает `touch()`. Сопоставление кандидатов не должно выполнять аргумент отдельно для каждого возможного объявления. Необходимые места приёма существуют раньше выражений, которые их используют. Вычисленные фактические аргументы выполняются один раз в записанном порядке, и каждый принимается раньше следующего; ошибка останавливает последующие фактические аргументы и предотвращает вход в тело. Фактические объявления DATA сохраняют свою форму вместо немедленного выполнения их правой части. Выбранные отображения сохраняются на протяжении всего выполнения.

Переданный фактический аргумент заменяет соответствующее описание источника namespace и подавляет исходный инициализатор. Ноль — переданное значение; явный `nil` и опущение различаются. Несовместимое значение не заменяется значением по умолчанию. Без фактического аргумента остаётся собственное готовое значение выбранного кандидата или вычисляемое значение по умолчанию; локалы вызывающего не могут его заменить. Вычисляемые значения по умолчанию не выполняются ни при построении графа, ни в общем проходе по всей точке входа: неиспользуемое не выполняется. Опущенный вход без инициализатора может получить разрешённое автозаполнение после выбора, иначе он остаётся `uninit:T`. Вход `required` участвует в выборе, а достигнутый CODE `required` проверяет фактическое место в этой точке. Локальные записи не меняют ни значений по умолчанию будущих вызовов, ни объявлений в исходном тексте.

<a id="native-structures"></a>
### Native обычной Structure и кадр

Любая Structure `C` компилируется общим механизмом тела и кадра. Вызов не требует именованности `C` или искусственного объявления `fn`; данными служит `parent(C)` ([структурный вызов](#call-receivers)). Входы и C-сигнатуры формируются из реальных вызовов, а не полной входной модели. Разные наборы аргументов дают разные сигнатуры; это не основание заранее строить реестр версий или универсальный адаптер.

`sys\native(C)` получает native-дескриптор из таблиц call и не исполняет его. Записи не отслеживаются ради native и не обнуляют входы; обновление выполняется явной компиляцией. Известный native вызывает известный native прямо в C, динамический вызов выбирает подходящий вариант в таблицах. Локалы не публикуются, явные записи меняют граф. [Полный контракт](#explicit-compilation).

<a id="whole-arguments"></a>
### Structure целиком, группы и потоки

CODE-потребитель рассматривает два равноправных чтения единственного фактического аргумента Structure, при условии что он не был явно передан конкретному формальному параметру: **W** — Structure в записанном виде и целиком; и **E** — её непосредственные поля как последовательность аргументов. Ровно одно допущенное сочетание объявления, чтения и отображения выбирается. Предпочтения для W, конкретной арности или первого объявления нет. E применяется однократно, на одном уровне, и никогда не переписывает граф. Ссылка на подготовленную Structure допустима точно так же, как записанная группа. `f(arg0 := S)` явно передаёт значение целиком и исключает E.

P0 сохраняет `f(a b)` как два записанных поля, а `f((a b))` — как одну группу. Они могут давать одну и ту же выбранную последовательность аргументов, когда E допущено однозначно, но не являются безусловно взаимозаменяемыми. Пустой Frame `f()` отличается от Frame, содержащего одну пустую Structure `f(())`. Ресивер, контракт аргументов которого — DATA, получает записанные границы без раскрытия W/E, свойственного CODE. Сюда не относятся `import`, `copy` и `merge`, аргументы которых всегда CODE.

`copy`, `merge` и вложенный `import` передают **потоки полей** окружающему потребителю. `f(copy(A))` получает результирующий поток; `f((copy(A)))` сначала собирает его в одну записанную Structure. Группировка не отключает W/E в `f`; используйте `f(arg0 := (copy(A)))`, когда указанный формальный `arg0` должен получить весь результат без E. Пустой поток отличается от сгруппированной пустой Structure. Из этих контрактов ресиверов не следует никакого общего раскрытия Array или строк ([композиция](#composition)).

<a id="two-kinds-of-receivers"></a>
### Роли аргументов принадлежат контрактам ресиверов

| Ресивер/контракт | Чтение аргументов | Раскрытие одной Structure |
| --- | --- | --- |
| Обычное вызываемое; CODE-потребляющий ресивер, например `call` | CODE, с учётом объявленной потребляющей роли каждого аргумента | Обычный выбор W/E |
| Ресивер уровня `L2`; `required`, `private`, `const`, `immutable`, `independent`; `fn: name data` | DATA | Сохраняются записанные аргументы; без W/E |
| `import`, `copy`, `merge` в любой позиции | Стандартный CODE | Обычный W/E по допущенной последовательности источников |
| Ресивер объявления места, переданный как фактический аргумент CODE | Форма объявления DATA | Сохранить и отобразить по [правилам аргументов объявления](#declaration-arguments) |

Роль принадлежит контракту, а не написанию скобок или числу аргументов. Голое имя Structure всегда обозначает ссылку и ничего не вызывает. `import` принимает один или более источников, `copy` — ровно один, а `merge` — два или больше; арность источников отличается от числа выходных полей. `merge(S)` не отвергается синтаксически лишь потому, что записана одна Structure: E может допустить её поля как несколько источников по тому же алгоритму CODE в любой позиции. Если подходят и W, и E, вызов неоднозначен. Скрытое связывание не поставляет недостающего источника.

```lmx
Defaults:
    int: c 3
    int: a

Calc:
    int: c
    int: a
    return: int
    mytest:
        return: c * 10 + a

int: r Calc\mytest(merge(Defaults (int: a 5)))
```

В контексте CODE merge объединяет два своих источника и передаёт получившиеся поля `c=3`, `a=5` как поток аргументов вызова; `r` равно 35 при единственном подходящем совпадении. Это явная композиция, а не автозаполнение и не изменение исходных значений по умолчанию. Добавление внешней группы создаст одну Structure до обычного выбора W/E.

Анонимная группа, используемая как самостоятельный оператор CODE, выполняется на месте: `(tick())` вызывает `tick`, `(2 + 2)` вычисляет и отбрасывает результат, `(a b c)` читает имена, а `()` ничего не делает. На позиции значения или аргумента её потребитель определяет, является ли она выражением, DATA или явно принятым телом кода. Это общее правило сохраняет как записанные границы контейнеров, так и обычное выполнение управляющего тела.

<a id="declaration-selection"></a>
### Выбор объявления по вызову

Этот алгоритм применяется к обычным вызываемым и к ресиверам, аргументы которых являются CODE. Контракты вроде `f(int a; required int b)` ниже являются аналитической записью объявлений входов, а не новой грамматикой исходного текста. Перекрывающиеся видимые объявления порождают ошибку в вызове, который допускает более одного кандидата; native-варианты уже выбранного языкового вызова не являются дополнительными объявлениями языка.

1. Разрешить имя/ссылку вызываемого и его видимые объявления обычным образом. Если у ссылки-ресивера есть требование fn, установить её позиционное совпадение типов и отображение публичных меток по правилам [fn](#fn-signature).
2. Образовать кандидатов **(видимое объявление, чтение W или E, отображение фактических аргументов в формальные)** из явно переданного материала. W сохраняет записанные значения. E дополнительно рассматривается только для ровно одного фактического аргумента Structure или ссылки на одну Structure, которая не передана присваиванием конкретному формальному параметру. E раскрывает непосредственные поля один раз и сохраняет их объявленные имена при обычном отображении. Формы объявления места используют случаи найденного имени, отсутствующего имени и явного имени из [аргументов объявления](#declaration-arguments).
3. Проверить порядок позиционных и именованных аргументов, известные имена, дубликаты, лишние фактические аргументы, собственные значения по умолчанию кандидата и обязательность входов. Явный `formal := S` не имеет E. Отсутствующие необязательные входы остаются позициями; опущение не то же самое, что явный `nil` или ноль.
4. Применить общий допуск интерфейса, включая его позиционную ветку fn, там, где это требуется. Обычная явная структурная модель сохраняет всё заявленное дерево целиком. Сопоставление не выполняет пользовательские значения по умолчанию, присваивания, преобразователи или тесты отдельно для каждого кандидата. Проверки, доступные до эффектов аргументов, выполняются первыми; уже полученные значения не пересчитываются для E или другого кандидата. Обычные фазы преобразования и тестов сохраняют [контракт допуска](#admission).
5. Подсчитать **все** допущенные кандидаты. Нет ни одного — отказ; ровно один выбирает полное объявление/чтение/отображение; больше одного — неоднозначность, включая два чтения одного и того же объявления. Предпочтения по целому значению, арности, порядку обхода или скрытому входу нет.
6. Вычислить и принять выбранные фактические аргументы по их контрактам один раз в записанном порядке, сохраняя выбранное отображение. W передаёт Structure целиком. E использует свои выбранные поля без другого раскрытия или поиска. Фактическое объявление остаётся формой, пока не будет потреблено или выполнено по собственному контракту.
7. Применить допустимое неявное связывание к выбранному вызову: собственные значения по умолчанию, автозаполнение, прозрачные места вызывающего и резервный вариант. Скрытые источники никогда не добавляют кандидата, не спасают отвергнутого кандидата и не запускают повторный выбор. Достигнутый CODE `required` проверяет место, актуальное на тот момент.

Вход, помеченный `required`, без фактического аргумента и без собственного инициализатора отвергает кандидата даже тогда, когда у вызывающего есть это имя. Собственное значение по умолчанию кандидата может удовлетворить обязательность; неиспользуемое вычисляемое значение по умолчанию не выполняется лишь для перечисления кандидатов. Модификаторы шаблона fn не заменяют правила выбранного кандидата. Существующее подготовленное native-исполнение использует выбранный вызов, не вводя автоматического допуска во время выполнения, которого нет в его контракте; интерпретатор использует стандартный механизм допуска на достигнутых вызовах.

<a id="selection-examples"></a>
#### Примеры требуемого выбора

| Контракты/условия | Вызов | Требуемый результат |
| --- | --- | --- |
| `f(int a)` и `f(int a; int b)`, b необязательный | `f(5)` | Два кандидата: неоднозначность |
| `f(int a)` и `f(int a; required int b)`, у вызывающего есть b | `f(5)` | Первое объявление; скрытый b не спасает второе |
| Те же объявления | `f(5; 6)` | Второе объявление |
| Только `f(required int b)`, без значения по умолчанию, у вызывающего есть b | `f()` | Нет кандидата |
| Только `f(required int b = 9)` | `f()` | Собственное значение по умолчанию допускает вызов |
| Только `f(int a; int b)`, у вызывающего b=6 | `f(5)` | Выбор без скрытого b; затем разрешённое автозаполнение может заполнить b |
| Целиком S подходит; E не подходит | `f(S)` | W; S остаётся целиком |
| `h(int x)`; Arg содержит `int: x 9`, целиком Arg не подходит | `h(Arg)` | E с одним полем; x получает 9 |
| Поля S подходят к двум входам, целиком S не подходит | `f(S)` | E с выбранным отображением полей |
| W и E подходят к одному объявлению | `f(S)` | Два кандидата: неоднозначность |
| W подходит к одному объявлению, E — к другому | `f(S)` | Неоднозначность без приоритета |
| S присвоена формальному | `f(a := S)` | Только W |
| Целиком C подходит к `call(code)`; поля подходят к `call(args code)` | `call(C)` | Неоднозначность |
| Тот же C явно называет свой формальный ресивер | `call(code := C)` | Без E; required-аргументы исключают другую форму |
| У fn есть вложенная Structure в шаблоне | `fn: SignatureName DataTemplate` | Два аргумента DATA, без CODE W/E |
| Группа собирает поток copy | `f((copy(A)))` | Одна записанная Structure, затем обычный W/E |
| Группа явно передана формальному | `f(arg0 := (copy(A)))` | Structure целиком, без E |
| Одна записанная S раскрывает два допущенных структурных источника | `merge(S)` в любой позиции | Обычный CODE E может удовлетворить минимум merge из двух источников |

Случай `h(Arg)` не означает, что E требует нескольких входов. И наоборот, `h((5))`, потребляемое числовым формальным параметром, — это обычное поведение группы как выражения, а не глобальное правило снятия обёртки. Объявление, раскрытое через E, сохраняется по контракту аргументов объявления; его готовое примитивное значение остаётся доступным без выполнения придуманного инициализатора.

Для ресивера с одним входом, например `length`, `parent`, `return`, или подходящего запроса `sys`, Structure передаётся целиком только тогда, когда W является единственным допущенным чтением. Structure с одним полем также может подходить под E и вызывать неоднозначность. Потребитель DATA, например `fn`, не входит в этот алгоритм выбора CODE. Арность `copy`, `merge` и `import` проверяется по допущенным **входным источникам**, а никогда по числу полей, которые они выдают.

<a id="structure-result"></a>
Результатом вызова может быть Structure с несколькими полями, описанная вложенным блоком return в его DATA, например return с `int: x`, `int: y` и `int: z`. Return не описывает никакой общей изменяемой ячейки результата. Structure, возвращённая функцией, — одно значение: групповое присваивание её не раскрывает (решение автора 2026-11-21; [групповое присваивание](#group-assign)). Построение выражения результата и обычные места приёма следуют существующему контракту; сама передача через return не копирует возвращённую ссылку и не создаёт второго контейнера. Хвост return `return: 1 2 3` передаёт описанные поля результата по порядку. Отдельный ресивер `fm` не вводится. Явно сгруппированный результат copy использует `return: (copy(A))`, когда требуется одна Structure.

Сокращённая запись, в которой слева от `:=` стоит имя вызываемого, например `square := x * x` внутри `square`, отвергается: имени вызываемого ничего не присваивается — имена Structure не присваиваются ([роли `data` и `code`](#data-code-roles)). Прежнее условие её допустимости — принимающий `fn` определяет одноимённую локальную ячейку результата — нормой 2026-11-19 не выполняется никогда: исполняемого `fn` нет, а поле `return` в данных описывает результат и ячейкой с именем вызываемого не является (следствие нормы, чтение исполнителя). Структурное закрытие `end: f` не добавляет неявный возврат значения; результат передаёт явный `return: value`.

Возвращаемая ссылка сохраняет точную идентичность цели. Построение результата, если нужно, принадлежит вычислению возвращаемого выражения, а не операции перехода. Возврат вложенной функции завершает её активацию, а не автоматически весь актор. Порядок выхода и очистки задан в [выходах](#exits).
[EN]
<a id="declaration-visibility"></a>
### Declaration visibility

Variables, including `const`, are visible from their initial declaration onward at their lexical level and in nested scopes. Before that declaration, this local name does not participate in lookup; available outer and dynamic names follow the common rules. Names of named Structures and callables remain visible in both directions. A variable containing a callable pointer remains a variable. The rule governs head resolution and other name uses alike; brackets and trailers do not change it. The author's clarification.

Sequential visibility of a bare name does not restrict explicit selection of a field in a constructed graph: `D\field` (a path from the data Structure `D`), `S[n]`, and `S\[n]field` use ordinary addressing. A field's presence in the graph does not mean that its computed value has already been obtained.

A call creates a new namespace. Preparation collects data and code root declarations: the data is `parent(C)` and the code is the executed `C` ([structural call](#call-receivers)). This includes explicit stream consumption under [the common namespace contract](#data-root-declaration-execution); it does not eagerly run computed place initializers or lift arbitrary nested declarations into the root. Data input places are available to the executing code as this call's inputs; collecting the code root does not make its future variables visible before their declarations. A new branch name is visible at its level and below, not outside. Re-declaring a name at the same level uses its existing local place; a supplied RHS retains evaluation, admission, and assignment. A declaration at a nested level creates its own place and shadows the outer one of the same name ([declaration levels](#shadowing-levels)).

A callable description is data with the common visibility and occurrence-selection rules. The position of the description of inputs, of the `return` field and of the code creates no separate early-evaluation rule. Inputs map to the call namespace without executing computed declarations. The common parser does not classify a field's role through a special case for its name.

Program files form no categories of a main file and parts: a message is a Structure, and included files join the program graph. Declaration order for variables and `const`, and bidirectional visibility for named Structures and callables, follow the resulting lexical tree. Comparing line offsets in separate source documents does not define visibility.

A signature describes inputs and the result; it is not an executable body ([`fn` signature](#fn-signature)). A formal's spelling does not execute the call, declaration, or assignment that the same spelling might denote in a body. The formals are declared by receivers -- `int: arg default`, `@: arg Template`; a structural form does not declare a formal variable: in the data role it is a declaration of a Structure (this is how, for example, a structural result is written in the `return` field), and the former synonymy of the two descriptions of a formal in a signature -- by a structural form and by a receiver -- is withdrawn ([the roles `data` and `code`](#data-code-roles)). Supplying an actual argument performs the contract's conversions and admission, but does not execute the formal description as a body operator. Uses of the resulting parameter in the body are resolved by its contract and the general expression rules, not by executing the signature text.

<a id="method-parts"></a>
### Parts of a callable Structure

The input places, requirements and defaults of executable C belong to actual `parent(C)`; its return description is the `return` field of that DATA. C itself is the code. `args` on call is actual supplied material, not a separate part of a function. `fn: name data` creates a named positional requirement and no implementation. Different supplied argument sets can produce different native signatures, while hidden service parameters do not become fn input positions. Catch retains its handler role with the same general input and actual-parent representation ([catch](#catch-common-model)).

Repeated physical DATA declarations retain distinct occurrences and may require indexed selection. Reached CODE receiver declarations at one level instead update the existing logical place. `call(C)` chooses C itself: it selects neither a child code field nor a child data field. These distinctions follow ordinary role and namespace rules rather than a separate call lookup.

A callable is an ordinary Structure selected for execution. Its DATA is its actual parent; a named signature is a separate requirement. Heads resolve through canonical names, and call preparation reads root declarations into a local namespace under [the common receiver contracts](#data-root-declaration-execution), including explicit field streams, without eagerly executing computed place initializers or completing the source graph with body locals. All receiver forms are retained, with terminal primitive declarations included in their direct typed-leaf representation; execution changes namespace places or explicitly addressed program data, not an implicit replacement graph.

Any Structure executes in the code role through the receiver `call` or a by-name form in code: `S()` equals `call(S)`, and `S(args)` equals `call(A S)` with the same selected actual arguments `A`; in both cases the data is `parent(S)` ([structural call](#call-receivers)). Explicit paths retain the source graph; root declarations prepare local namespace places without completing the graph. External names are bound in the common order ([binding](#binding-places)) and do not become data fields by name coincidence. `node` retains its existing meaning. Repeated occurrences, data and code roles, and admission follow the common rules in all forms; there is no special executor. See [call frames](#call-frame-20261115).

A callable is just a Structure: the launch receiver does not select a part inside the Structure it is given -- `call(A s)` executes `s` itself, and the child `code` field is not searched for automatically (the author's decision of 2026-11-16; details -- [structural call](#call-receivers)). An ordinary declared input is optional unless constrained by input `required`: an input without a value, to which no value is supplied, does not make the call refuse; [autofill](#binding-autofill) fills it, and where that is inapplicable the input holds "T without initialization"; the receiver [`required`](#required-receiver) checks that a given field is initialized (the author's decision of 2026-11-16).

A structural form in executable code, including name:... end: name, calls its head; it neither declares nor assigns source data ([roles](#data-code-roles)). A data: block in executing code therefore also launches its head with its own tail in the place of the arguments; the name `data` has no special meaning ([what is withdrawn](#removed-builtins)). Data and code are described structurally: the code is written as a nested Structure inside its data, and the call selects that occurrence; a named definition does not itself execute its contents.

A variable-declaration receiver in code works with the call-local namespace: its initial declaration introduces a place, repeating the name at the same level preserves the RHS, admission and assignment to that place, and a declaration at a nested level creates its own place ([declaration levels](#shadowing-levels)). Nested if/for stays in the same activation; a new branch name is visible there and below, not outside. Neither nesting depth nor a missing same-named data field requires adding a graph field: code locals need not correspond to source data. Preparation considers data and code roots and their explicit stream contracts, without eagerly running computed place initializers or exposing future locals. Repeated physical data fields remain distinct occurrences selected explicitly by D\[N]y; D\y is ambiguous when repeated. The call contracts and ordinary admission of supplied inputs remain; this is not a requirement for D to contain all code locals. See [frames](#call-frame-20261115).

An explicit `call` uses the same fresh-namespace model. The root declarations of the data `D = parent(C)` provide inputs; the root declarations of `C` provide the remaining locals. Preparation uses [the common namespace and explicit stream contracts](#data-root-declaration-execution); it neither changes `D` or `C` nor executes computed place declarations early. Explicit paths from `D` and the path `code\` retain the original `D` and `C`.

Neither call entry nor a graph write clears native. A local write changes only the namespace; an explicit write changes the source graph. Updating machine execution requires [explicit compilation](#explicit-compilation); endturn alone does not perform it.

An executable body is a structural expression. A declaration does not run it; a bare name denotes its reference; `A()` or `call(A)` explicitly executes it, subject to the common argument selection. `A()` has no written actual, whereas `A: ()` contains one empty Structure and follows the receiving contract. A result is described by the parent's `return` field; without that description the call supplies no result value. Declared throws and other call restrictions remain those of the candidate, not policies transferred from a fn template.

Bare `return` exits without a value; `return: value` is admitted only where the result is described by the `return` field of the data ([`return` in data](#return-in-data)). At the opening level, `return` may also be a trailer for any callable Structure under the general grammar rule; it is not a closer for a non-callable Structure. Explicit `end: Name` is optional, and reaching the end of a body without `return` does not synthesize a return node.

A path through a Structure reads a field without adding an invocation of the selected Structure or callable. A computed declaration is not executed by a path either: the path reads its record ([explicit path](#path-reads-no-execution)). A path from the data -- `D\x` with `D = parent(M)` -- addresses the source graph; bare `x` and `@x` in a call address the logical place selected by binding ([binding](#binding-places)). The call's own place and a graph field are different places even when their initial values match.

A callable occurrence retains its own structural identity, actual parent and established lexical context. DATA follows the actual parent of the selected executable C; node preserves the selected occurrence's lexical operation and is not rebound by the path used to find C, the address of a shared C function, or a stream recipient. Different code occurrences may share a compatible native implementation while retaining their own data and links. Graph copying preserves or redirects those links through its map. A nested declaration does not capture a caller frame in a hidden environment.

Entry creates a local frame without write-back. A mandatory executable-code copy is cancelled: edit-application timing before endturn is unspecified, while native updates require explicit compilation. Other execution rules remain shared by native and the walker. Bindings use hidden arguments without a lexical-environment copy -- a value for an own place, the address of a cell for the caller's place ([executors](#binding-executors)); see the [boundary](#explicit-compilation).

The source data with the `return` field and the code belong to the graph -- to the data `parent(C)` and to `C` itself; the local namespace belongs to the activation. Re-declaring a variable in code at the same level retains its type contract, computation, and assignment; only the repeated C declaration is omitted.

A named Structure can receive explicit actuals through the input declarations of its actual parent, and its body's other used values still need resolution. Its explicitly constructed fields remain in the Structure itself; `call` does not create further fields from mentions of external names. Root data places are available to code as call inputs; preparation does not cancel sequential variable/const visibility in the executable lexical tree. A receiver declaration in code with no corresponding place in the data defines a call-local place, without extending source data. Namespace preparation uses the roots of data and code and their explicit stream contracts; it does not eagerly execute a computed place RHS. A future local's bare name is not yet visible; an early read through an explicit path does not suppress execution of its declaration statement when reached ([agreed clarifications](#activation-history)). For an external name without its own declaration, the place is selected during execution by the common order: a lexical source marked `private:`, the transparent caller place, the former binding ([binding](#binding-places)). Thus `named_called_struct` can read and assign the external `k`, but no `named_called_struct\k` field exists unless explicitly declared inside that Structure. Where a write lands is determined by the selected path: through the transparent caller place it immediately changes the caller's local variable, through the former binding it changes the own working copy and does not rewrite the source; a graph field changes only through an explicitly written path. A named Structure has no separate external-name resolution mode.

The distinction also holds within one Structure: `int: a` creates a typed place (in data a receiver form declares the place, in code it checks the type on its own line and, when a value is written, assigns -- [the roles `data` and `code`](#data-code-roles)), while a later `a := get_a()` computes and stores a new value when reached. A code declaration defines a call-local place, without extending source data; namespace preparation does not execute a computed operator early. Keeping these parts in one graph does not make them interchangeable.

Callable selection starts from an explicit reference, structural path or textual path with an explicitly supplied root. Selecting an implementation and providing its arguments are distinct actions. The selected candidate undergoes [admission](#admission); the call then receives the signature inputs: declared inputs follow their ordinary optional/required contract ([structural call](#call-receivers)), while each external (dynamic) input must have a source. A suitable method field does not by itself supply its dynamic inputs. Transporting a method as data is not invoking it.

<a id="call-receivers"></a>
<a id="structural-call"></a>
### Structural call

The selected Structure C is executed in CODE; its actual parent supplies DATA. A call cannot supply a replacement parent or automatically select an inner body. These forms use the common selection, namespace, binding, admission and return mechanisms.

| Form after an unambiguous choice | Executed object | Explicit actual arguments | Data |
|---|---|---|---|
| `call(C)` | `C` | not supplied | `parent(C)` |
| `call(A C)` | `C` | the Structure `A` | `parent(C)` |
| `C()` | `C` | an empty tail | `parent(C)` |
| `C(args)` | `C` | written actual arguments by the common algorithm | `parent(C)` |

`args` is the Structure of actual supplied values, exactly the argument Structure of an ordinary call. It is not formal declarations, a signature, or a separate part of a callable. The input places, requirements and defaults are described by the data `parent(C)`; the same data describe the result by the `return` field ([`return` in data](#return-in-data)). `code` is the executable Structure: `call` executes the selected `C` itself, and the child `code` field is not searched for automatically.

`call` has two forms -- two separate declarations: `call(code)` and `call(args code)`. The parameters are named `args` and `code` and are mandatory, `required`: in the one-argument form `code`, in the two-argument form `args` and `code`; therefore the absence of `args` does not make the two-argument form suit `call(code := C)`. The declaration is chosen by the call by the general algorithm, without an exception for the built-in `call` ([choosing the declaration by the call](#declaration-selection)): if the whole `C` suits the form `call(code)` and its fields suit the form `call(args code)`, the record `call(C)` is an error of ambiguity; `call(code := C)` explicitly supplies `C` as `code` and excludes the unwrapping of that argument. The receiver's own named arguments are ordinary: `call(args := A; code := C)`; the names of the members of `A` denote inputs of the data, not parts of the receiver.

The table does not cancel the choice of the reading of a single structural actual argument: `C(A)` may take `A` whole or choose to pass its fields -- this is determined by the [declaration selection](#declaration-selection). The equality of the effect of different records is checked with the same selected actual arguments, not by arbitrary textual substitution: with the same selected `A`, a by-name record and `call(A C)` are one call.

For `args` the ordinary positional and named supply, evaluation order, call-shape checks, admission, and whole-Structure argument passing apply. Values already obtained are not evaluated again. A supplied place-declaration form keeps its DATA contract and is not reduced to a computed value during transmission. A supplied actual replaces the corresponding place description in a fresh namespace; the source data and code are unchanged, and entry executes no initializers. The interpreter sends a by-name call, a call through a pointer and both explicit forms of `call` through one mechanism for binding, admission, frame, execution and result transfer; there is no second execution path for a `catch` handler or an explicit receiver. Reached calls from test and converters use that path too. Service C functions, the bridge and the `call` dispatcher do not substitute their own service locals for the caller's context: the sources of the language are determined by the program place of the call. The author's clarification of 2026-11-15 that `args` supplies values and does not describe inputs remains in force.

A callable is just a Structure (the author's decision of 2026-11-16). The launch receiver has no special rule for a callable: it does not select a part inside the Structure it is given. Any Structure may be given to `call` (the author's clarification of 2026-11-16): the given object is executed by its actual fields under the general rules; there is no prohibition, no automatic selection of the body and no special order for a callable, and what is observed is a consequence of the general mechanisms, not fixed as a separate norm.

```text
Counter:
    int: steps 0

Step:
    int: x 5
    add:
        Counter\steps := Counter\steps + x

Step\add()
Step\add(x := 2)
call(Step\add)
```

The declarations are written in data, the three records of the call in code. In all three `add` is executed, and its data is `Step`: `x` is the call's own declared place, described by the data. The first and third records supply no actual arguments, and `x` takes its own value 5; the second supplies 2. After the three calls `Counter\steps` is 12. The record `Step()` would execute `Step` itself -- another Structure; it does not look for `add` automatically.

Other data cannot be substituted by the call itself: for another combination of data and code the needed structural link is created first -- by a declaration, a copy or `merge`, under their rules about `parent` --, and then the selected occurrence of `C` is called. The record `NewContainer: ExistingCode` keeps a reference to `ExistingCode` and does not change its `parent` ([a colon declares](#colon-declares)), so it does not by itself replace the former `call(NewData ExistingCode)`. Copying and `merge` preserve or redirect `parent` under the current copying rules. `node` and its explicit lexical access are preserved for the actually selected occurrence.

Inputs are optional unless their receiving contract, including input `required`, rules out omission. A declared input place of the data that is given no value and has no value in its declaration does not make the call refuse: [autofill](#binding-autofill) fills it, and where that is inapplicable the place holds "T without initialization", and the call executes.

```text
E:
    int: x
    step:
        int: i
        i := 5
        Counter\steps := Counter\steps + i

E\step()
call(E\step)
```

Both calls execute because x is an ordinary optional input: omission with no initializer leaves it uninitialized unless permitted autofill supplies a value. Input requiredness can instead reject a call during selection; a separate reached CODE required checks the then-current place. A missing external name that is actually used, with no permitted caller/activation/lexical source, still refuses under [binding](#dynamic). Optional declared inputs do not license inventing free-name values.

<a id="root-entry"></a>
#### R0: entry without data

R0 is an ordinary C method with a local pointer to the R0 graph. The interpreter also runs on the compiled binary and has this binary R0. At the language boundary R0 starts as a procedure without DATA and without user actuals. No artificial D=C relation, empty service DATA Structure or synthetic data field compensates for its absence. R0 may contain executable declarations and use ordinary accessible references; internal runtime launch parameters and native-root graph access do not become user arguments. The absence of DATA affects input binding, not the common classification of written forms: executable declaration receivers and calls follow their ordinary CODE contracts, and a form received as DATA follows that receiver's DATA contract. No root-specific parser, implicit self-call or replacement DATA object is introduced.

<a id="removed-builtins"></a>
#### What is withdrawn by the norm of 2026-11-19

Withdrawn (the requirements of 2026-11-19, §4.4): the special meaning of the name `data` -- the reserved name of an explicit reference to the data of a launch, the path `data\…` and the record `data := …`; the separate data parameter of `call`; the built-in `fncall` and `sub`; the executable form of `fn`. The word "data" remains the name of a role and an ordinary user name under the general rules; for `data`, `sub` and `fncall` the withdrawn built-in meaning is distinguished from an explicitly declared ordinary user name. `node` remains a reserved operation.

Historical migration note: in current `call(D C)`, D is the actual-argument Structure, not substitute DATA; `C(D)` likewise supplies an actual. `call(C)` uses parent(C), not C as its own DATA. The older three-argument call and fncall families are withdrawn. Executable fn/sub declarations are replaced by ordinary structural data/code relationships and return descriptions in the actual parent. A former `data\x` path must be replaced with an explicit path to the intended Structure; `node\x` is appropriate only when the intended target is that established lexical context. The ordinary name data and the retained reserved operation node must not be conflated.

<a id="fn-signature"></a>
#### Named signature: `fn: name data`

`fn` takes exactly two arguments, both in the DATA role: a name atom and an ordinary Structure supplying its data template. It creates a constant named description of a positional call signature, with no executable body or native entry. That name can be reused as a requirement and imported by the [root-constant rule](#import-receiver). W/E selection for CODE actuals does not expand the two arguments of `fn`.

```lmx
fn: SumSignature (int: a; int: b; return: int)

SumContext:
    int: a
    int: b
    return: int
    sum:
        return: a + b

@: sumPtr SumSignature SumContext\sum
```

The three arguments of `@` are the reference name, signature requirement and actual callable. `sumPtr(a := 2; b := 3)` and direct `SumContext\sum(a := 2; b := 3)` return 5. `SumContext()` would execute a different Structure and does not automatically choose `sum`. The ordinary two-argument form `@: p Model` initially points at `Model` itself; it does not invent an implementation for a signature.

Input positions are the data template's ordinary declared input places in order. `return` describes a result and is not an input; a nested user Structure is not automatically a formal, and an Array is one input regardless of element count. No `return` means a procedural signature. A structured result uses ordinary DATA notation:

```lmx
PairData:
    int: count
    return:
        int: x
        int: y

fn: PairSignature PairData
```

#### The positional branch of `implements`

The common `implements` has a distinct rule for a resolved `fn` requirement. It extracts the ordered input types and presence/type of the result from the named description, obtains the candidate `C`'s corresponding contract from its actual `parent(C)`, and compares corresponding positions. Input count and order matter; optional/defaulted inputs remain positions. Types include the actual LMX requirements for typed references, Array elements and structural results, not just C sizes or raw tags.

Formal names, initializer values and implementation-body trees are not fn-match criteria. Candidate positions are never rearranged to match names. Hidden native arguments, dynamically bound free names and CODE locals are not additional explicit positions. The comparison executes no body or initializer and creates no second parser or admission engine. It does not substitute the template for `parent(C)`.

An ordinary Structure used explicitly as a structural model instead requires its **whole stated tree**, including any method field and subtree it includes; extra candidate fields are allowed. Used-interface checking for a concrete Consumer remains distinct from this explicit template obligation. For a model that should require only an input and result, write the minimum tree:

```lmx
PrioritiesTemplate:
    []: char name
    return: int

Priorities:
    []: char name
    return: int
    lookup:
        return: sys\priority(name)

fn: PrioritySignature PrioritiesTemplate
@: priorities_data PrioritiesTemplate Priorities
@: priority_fn PrioritySignature Priorities\lookup
```

`implements(Priorities, PrioritiesTemplate)` checks all of the minimal template, which has no `lookup` requirement. Choosing the whole `Priorities` as a structural model includes `lookup` and its stated subtree. `PrioritySignature` instead checks the selected callable's ordered input types and result; `name` need not physically occur inside `lookup`. Neither a `return` field nor a name ending in “Signature” turns an ordinary Structure into `fn`.

The same composition can be written `PrioritiesMerged: merge(PrioritiesTemplate (lookup: return: sys\priority(name)))`. This ordinarily declares `PrioritiesMerged`; `merge` consumes its sources as standard CODE arguments and supplies its fields through the namespace. The bare `PrioritiesTemplate` reference and the anonymous Structure are values, not calls of those Structures. The contents of the group retain their ordinary contracts. In particular, supplying the Structure containing `lookup` does not execute that method or its `sys\priority` call. Copying preserves the selected method's actual lexical/DATA links through the common map; acceptance of a stream is not arbitrary reparenting.

#### Public labels and the candidate's own contract

On a call through a reference constrained by `fn`, the signature's formal names are the public labels of explicit actuals. Normal positional/named mapping first identifies a signature position; that position maps to the candidate input at the same index. The candidate's own names are used by direct calls and are not fallback aliases of the public interface. Actual expressions still evaluate once in written order, not in position order. Declaration-form actuals use that same external map without changing the preserved form's internal name ([declaration arguments](#declaration-arguments)).

```lmx
fn: SelectSignature (int: count; []: char text; return: int)

First:
    int: n
    []: char s
    return: int
    select:
        return: n

Reordered:
    []: char text
    int: count
    return: int
    select:
        return: count

@: chosen SelectSignature First\select
```

In CODE, `chosen(text := "x"; count := 3)` maps text to position 2 (`s`) and count to position 1 (`n`), and returns 3. Direct `First\select(s := "x"; n := 3)` is also valid. Direct `Reordered\select(count := 3; text := "x")` can be valid, but assigning that callable to `chosen` fails: `[Array<char>, int]` does not match `[int, Array<char>]`. If both types were `int`, renamed or swapped labels would not change the positional map: public `a=1, b=2` still reaches candidate positions 1 and 2.

Fn-match extracts a type shape; it transfers no defaults, requiredness, throws or execution policy from the template. `fn: StepSignature (int: step 1)` describes one int input and no result, but its 1 does not become a default of the candidate. A compatible candidate with a required input can reject an omitted actual despite positive fn-match; hidden autofill cannot rescue it during selection. After explicit supply, implicit binding uses the candidate's real names, declarations and private marks, not the fn labels. A positive signature comparison never proves identical algorithms or admissibility of every future actual set.

<a id="return-in-data"></a>
#### `return` in data

The result of a call is described by the `return` field of the data (the requirements of 2026-11-19, decision R11): `return: int` or a nested block for a [Structure result](#structure-result). A `return` declaration in data assigns nothing and does not become a common mutable cell of recursive activations. In code `return` is the return receiver: bare `return` keeps the exit without a value, `return: value` passes an admissible result to where it is described, and reaching the end of the body does not create `return`. The rules for a structural result, receiving places and cleanup are preserved ([exits](#exits)). Both `call` and a by-name call of a Structure return a value by this contract; the former unconditional prohibition of a result for the launch of an ordinary Structure and for `call` is withdrawn together with `fncall`.

<a id="named-actuals"></a>
### Named, positional and declaration-form actuals

A standalone actual `a := value` selects formal `a` and supplies the RHS under its receiving contract. Through a fn-constrained reference, `a` is the public label of that signature and maps to the candidate's position; direct calls use the candidate's own names. `f(a := a(5))` evaluates the explicit inner call once. An ordinary `a(5)` or `a: 5` actual is a call whose result is supplied positionally, not a named actual merely because its head matches a formal. A bare callable name is a reference and invokes nothing.

The positional counter follows one rule. Naming the formal at the current position still counts as positional and leaves the counter active. Naming a different position disables it; all subsequent actuals must be named. It never restarts. Unknown explicit names, duplicate supply and excess actuals are errors. Separate named actuals with `;`: `f(a := 1; b := 2)` supplies two actuals; a comma does not necessarily terminate the first assignment's RHS.

<a id="declaration-arguments"></a>
#### Preserve a supplied declaration

A **place-declaration receiver** supplied as an argument in a CODE argument context is read as DATA. The argument is the declaration itself, and transmission alone executes no initializer. If its corresponding declaration is found in the receiving DATA, the supplied form replaces that declaration **in this call's namespace**, not by storing its precomputed value and not by changing source DATA. The resolved head's contract distinguishes a declaration receiver from an ordinary call; this rule applies to `int(item expression)` as well as `int: item expression`, and is not a special case for example names.

| Actual form | Mapping | Preserved material |
| --- | --- | --- |
| Its declared name is found in the receiving DATA/interface | Ordinary name/position mapping | The supplied declaration replaces that namespace description |
| Its internal name is absent | The entire declaration occupies the current position as one Structure | A reference to that form; its internal name remains inside it |
| An external `formal := declaration` is written | The external assignment chooses the destination | The declaration remains the RHS value, with its own internal name |

Thus with inputs `a`, then `b`, `g(int: b producer())` supplies the description for `b` by name; it does not precompute `producer()`, and a following unnamed actual would violate the positional rule. With inputs `iteration`, then `body`, a declaration `int: item numbers\next()` has no matching `item` formal and goes as one Structure into `iteration`; its internal name neither becomes an unknown named actual nor disables the counter. `iteration := int(item numbers\next())` explicitly chooses `iteration` regardless of the internal name.

The accepted form's root declaration logically supplements the root of the **receiving execution's** CODE namespace. Each reached execution of that form repeats its initializer and declares or updates the same root place under ordinary same-level redeclaration rules. The preserved form and its most recent computed value are distinct: a result does not replace the executable form. Preparation, passing and unconsumed forms do not run ahead of demand.

An associated passed body uses that established place directly. It does not create a new computed copy or repeat the initializer just by entering or reading it. The body's physical parent remains the original argument Structure; logical root supplementation changes neither that parent nor the source CODE graph. Genuine nested scopes retain shadowing. Independent receiving invocations keep independent contexts, and neither form passing nor retaining a reference extends a finished frame's lifetime.

```lmx
cycles:
    @: iteration
    @: body
    iterate:
        while: 1
            iteration()
            catch: Stop ()
                break
            body()

use:
    import: cycles
    run:
        iterate: int: item numbers\next()
            item *= 2

use\run()
```

Here `numbers` is an available iterator whose `next()` yields integers or throws `Stop`. [Import](#import-receiver) exposes the constant Structure declaration `iterate`; `iteration` and `body` are ordinary reference inputs and remain in the actual DATA `cycles`. The first actual preserves the declaration form in `iteration`; the second is the associated body. `iteration()` advances the iterator and establishes/updates `item`; `body()` changes that very place. Its physical parent is the written argument Structure containing the declaration form, not the library definition `cycles\iterate`.

| Iteration | Step | Body |
| --- | --- | --- |
| 1 | One `next()` yields 10; `item` becomes 10 | Same place becomes 20 |
| 2 | One `next()` yields 20; same place becomes 20 | Same place becomes 40 |
| End | One `next()` throws `Stop` | Not executed |

There are three `next()` calls and two body executions. Reading `item` adds no calls. The catch covers its whole loop block, including `body()`, under the ordinary handler rules.

The named form `iterate(body := (item *= 2); iteration := int(item numbers\next()))` supplies both Structures without running the body before the step. `iterate(iteration := int(item numbers\next()); (item *= 2))` leaves the positional counter active after its first actual. `iterate(body := (); iteration := int(item numbers\next()))` supplies a present empty body, not an omitted one.

This rule does not publish all fields of every ordinary Structure reference as root locals. An ordinary `Producer()` actual remains a CODE call, and merely passing `p := S` does not execute all of `S` or supplement the root with every field.

#### Evaluation, reception and defaults

Call-shape checks available before effects run first: an unknown explicit formal name in `f(x := touch())` does not run `touch()`. Candidate matching must not execute the argument separately for each possible declaration. Necessary receiving places exist before expressions that use them. Evaluated actuals run once in written order and each is received before the next; a failure stops later actuals and prevents body entry. DATA declaration actuals preserve their form instead of eagerly running their RHS. Selected mappings are retained through execution.

A supplied actual replaces the corresponding namespace source description and suppresses that original initializer. Zero is a supplied value; explicit `nil` and omission differ. An incompatible value is not replaced by a default. Without an actual, the chosen candidate's own ready value or computed default remains; caller locals cannot replace it. Computed defaults execute neither at graph construction nor in an entry-wide pass: an unused one does not run. An omitted input with no initializer may receive permitted autofill after selection, otherwise it remains `uninit:T`. Input `required` participates in selection, while a reached CODE `required` checks the actual place at that point. Local writes change neither future calls' defaults nor source declarations.

<a id="native-structures"></a>
### Ordinary Structure native code and frames

Any Structure `C` is compiled by the common body and frame mechanism. A call does not require `C` to be named or an artificial `fn` declaration; the data is `parent(C)` ([structural call](#call-receivers)). Entries and C signatures derive from actual calls rather than the complete input model. Different argument sets give different signatures; this does not justify a speculative version registry or universal adapter.

`sys\native(C)` obtains the native descriptor from call tables without executing it. Writes are not tracked for native and do not clear entries; explicit compilation performs updates. Known native calls go directly to known C functions; dynamic calls select a suitable table variant. Locals are not published and explicit writes change the graph. [Complete contract](#explicit-compilation).

<a id="whole-arguments"></a>
### Whole Structures, groups and streams

A CODE consumer considers two equal readings of a sole Structure actual, provided it was not explicitly assigned to a formal: **W**, the Structure as written and whole; and **E**, its immediate fields as an argument sequence. Exactly one admitted combination of declaration, reading and map is selected. There is no preference for W, a particular arity or the first declaration. E occurs once, at one level, and never rewrites the graph. A reference to a prepared Structure is eligible just as a written group is. `f(arg0 := S)` explicitly supplies the whole value and excludes E.

P0 preserves `f(a b)` as two written fields and `f((a b))` as one group. They can produce the same selected argument sequence when E is uniquely admitted, but are not unconditionally interchangeable. An empty Frame `f()` differs from a Frame containing one empty Structure `f(())`. A receiver whose argument contract is DATA receives the written boundaries without CODE's W/E expansion. This does not include `import`, `copy` or `merge`, whose arguments are always CODE.

`copy`, `merge` and nested `import` supply **field streams** to their surrounding consumer. `f(copy(A))` receives the resulting stream; `f((copy(A)))` first collects it into one written Structure. Grouping does not turn off W/E at `f`; use `f(arg0 := (copy(A)))` when an actual formal `arg0` must receive the whole result without E. An empty stream differs from a grouped empty Structure. No general Array/string expansion follows from these receiver contracts ([composition](#composition)).

<a id="two-kinds-of-receivers"></a>
### Argument roles belong to receiver contracts

| Receiver/contract | Argument reading | Single-Structure expansion |
| --- | --- | --- |
| Ordinary callable; CODE-consuming receiver such as `call` | CODE, subject to each argument's declared consuming role | Ordinary W/E selection |
| Level receiver `L2`; `required`, `private`, `const`, `immutable`, `independent`; `fn: name data` | DATA | Preserve written arguments; no W/E |
| `import`, `copy`, `merge` in any placement | Standard CODE | Ordinary W/E over the admitted source sequence |
| Place-declaration receiver supplied as a CODE actual | DATA declaration form | Preserve and map it under [declaration-argument rules](#declaration-arguments) |

The role belongs to the contract, not the spelling of parentheses or the number of arguments. A bare Structure name always denotes a reference and invokes nothing. `import` accepts one or more sources, `copy` exactly one, and `merge` two or more; source arity is distinct from output field count. `merge(S)` is not rejected syntactically merely because one Structure was written: E may admit its fields as multiple sources under the same CODE algorithm in any placement. If both W and E fit, the call is ambiguous. Hidden binding supplies no missing source.

```lmx
Defaults:
    int: c 3
    int: a

Calc:
    int: c
    int: a
    return: int
    mytest:
        return: c * 10 + a

int: r Calc\mytest(merge(Defaults (int: a 5)))
```

In a CODE context the merge combines its two sources and supplies the resulting fields `c=3`, `a=5` as the call's argument stream; `r` is 35 under the unique matching. This is explicit composition, not autofill or modification of the source defaults. Adding an outer group would create one Structure before normal W/E selection.

An anonymous group used as a standalone CODE statement executes in place: `(tick())` calls `tick`, `(2 + 2)` evaluates and discards the result, `(a b c)` reads names, and `()` does nothing. At a value or argument position its consumer determines whether it is an expression, DATA, or an explicitly accepted code body. This common rule preserves both written container boundaries and ordinary control-body execution.

<a id="declaration-selection"></a>
### Choosing the declaration by the call

This algorithm applies to ordinary callables and receivers whose arguments are CODE. Contracts such as `f(int a; required int b)` below are analytical notation for input declarations, not new source grammar. Overlapping visible declarations produce an error at a call that admits more than one candidate; native variants of an already chosen language call are not extra language declarations.

1. Resolve the callable name/reference and its visible declarations normally. If the receiving reference has an fn requirement, establish its positional type match and public-label map under [fn](#fn-signature).
2. Form candidates **(visible declaration, reading W or E, actual-to-formal map)** from explicitly supplied material. W keeps the written values. E is additionally considered only for exactly one Structure actual or reference to one that was not supplied by assignment to a specific formal. E exposes immediate fields once and preserves their declaration names under ordinary mapping. Place-declaration forms use the found-name/absent-name/explicit-name cases of [declaration arguments](#declaration-arguments).
3. Check positional/named ordering, known names, duplicates, excess actuals, the candidate's own defaults and input requiredness. Explicit `formal := S` has no E. Absent optional inputs remain positions; omission is not the same as an explicit `nil` or zero.
4. Apply the common interface admission, including its positional fn branch where that is the requirement. An ordinary explicit structural model keeps its whole stated tree. Matching does not execute user defaults, assignments, converters or tests separately for each candidate. Checks available before argument effects occur first; already obtained values are not recomputed for E or another candidate. Ordinary conversion and test phases retain the [admission contract](#admission).
5. Count **all** admitted candidates. None refuses; exactly one selects the complete declaration/reading/map; more than one is ambiguity, including two readings of the same declaration. There is no whole-value, arity, traversal-order or hidden-input preference.
6. Evaluate and receive the selected actuals under their contracts once in written order, retaining the chosen map. W passes the Structure whole. E uses its selected fields without another expansion or search. A declaration actual stays a form until consumed/executed under its own contract.
7. Apply permissible implicit binding to the selected call: own defaults, autofill, transparent caller places and retained fallback. Hidden sources never add a candidate, rescue a rejected candidate or trigger reselection. Reached CODE `required` checks the then-current place.

An input marked `required` with no actual and no own initializer rejects the candidate even when the caller has that name. A candidate's own default may satisfy requiredness; an unused computed default is not executed just to enumerate candidates. Fn-template modifiers do not replace the selected candidate's rules. Existing prepared native execution uses the selected call without introducing automatic runtime admission absent from its contract; the interpreter uses the standard admission mechanism at reached calls.

<a id="selection-examples"></a>
#### Required selection examples

| Contracts/conditions | Call | Required result |
| --- | --- | --- |
| `f(int a)` and `f(int a; int b)`, b optional | `f(5)` | Two candidates: ambiguity |
| `f(int a)` and `f(int a; required int b)`, caller b exists | `f(5)` | First declaration; hidden b does not rescue the second |
| Same declarations | `f(5; 6)` | Second declaration |
| Only `f(required int b)`, no default, caller b exists | `f()` | No candidate |
| Only `f(required int b = 9)` | `f()` | Own default admits the call |
| Only `f(int a; int b)`, caller b=6 | `f(5)` | Select without hidden b; then permitted autofill may fill b |
| Whole S fits; E does not | `f(S)` | W; S stays whole |
| `h(int x)`; Arg contains `int: x 9`, whole Arg fails | `h(Arg)` | E with one field; x obtains 9 |
| S's fields fit two inputs, whole S fails | `f(S)` | E with the selected field map |
| W and E fit one declaration | `f(S)` | Two candidates: ambiguity |
| W fits one declaration, E another | `f(S)` | Ambiguity without priority |
| S is assigned to a formal | `f(a := S)` | Only W |
| Whole C fits `call(code)`; fields fit `call(args code)` | `call(C)` | Ambiguity |
| Same C explicitly names its receiver formal | `call(code := C)` | No E; required args prevents the other form |
| Fn has a nested Structure in its template | `fn: SignatureName DataTemplate` | Two DATA arguments, no CODE W/E |
| Group collects a copy stream | `f((copy(A)))` | One written Structure, then ordinary W/E |
| Group explicitly assigned to a formal | `f(arg0 := (copy(A)))` | Whole Structure, no E |
| One written S exposes two admitted structural sources | `merge(S)` in any placement | Ordinary CODE E can meet merge's minimum of two sources |

The `h(Arg)` case does not mean E requires multiple inputs. Conversely `h((5))` consumed by a numeric formal is ordinary group-as-expression behavior, not a global unwrapping rule. A declaration exposed by E is preserved under the declaration-argument contract; its ready primitive value remains obtainable without executing an invented initializer.

For a one-input receiver such as `length`, `parent`, `return`, or a suitable `sys` query, a Structure is passed whole only when W is the uniquely admitted reading. A one-field Structure can also fit E and cause ambiguity. A DATA consumer such as `fn` does not enter this CODE selection algorithm. Arity of `copy`, `merge` and `import` is checked on the admitted **input sources**, never on the number of fields they output.

<a id="structure-result"></a>
A call's result may be a Structure with several fields, described by a nested return block in its DATA, for example return with `int: x`, `int: y`, and `int: z`. Return describes no shared mutable result cell. A Structure returned from a function is one value: a group assignment does not open it (the author's decision of 2026-11-21; [group assignment](#group-assign)). Result-expression construction and ordinary receiving places follow their existing contract; transfer by return itself neither copies a returned reference nor creates a second container. A return tail `return: 1 2 3` supplies the described result fields in order. No separate `fm` receiver is introduced. An explicitly grouped copy result uses `return: (copy(A))` when one Structure is required.

The shorthand with the callable's name to the left of `:=`, such as `square := x * x` inside `square`, is rejected: nothing is assigned to the name of a callable -- the names of Structures are not assigned ([the roles `data` and `code`](#data-code-roles)). The former condition of its admissibility -- the receiving `fn` defines a same-named local result cell -- is never fulfilled under the norm of 2026-11-19: there is no executable `fn`, and the `return` field in data describes the result and is not a cell named as the callable (a consequence of the norm, the executor's reading). Structural closing with `end: f` adds no implicit value return; the result is passed by explicit `return: value`.

A returned reference preserves its exact target identity. Constructing a result, if necessary, belongs to evaluation of the returned expression, not the transfer operation. Returning from a nested function ends its activation, not automatically the entire actor. Exit and cleanup ordering is defined under [exits](#exits).
@@ dynamic | Динамические входы и рабочее состояние | Dynamic inputs and working state | 7.3.1–7.4.3; 21.1–21.8; 21.10–21.12
[RU]
Следует различать хранилище объявленного значения в полной Structure, рабочее значение текущей активации, явный формальный аргумент, динамический вход и место вызывающего. Эти значения имеют разные правила изменения; рабочая копия не создаёт второго постоянного графа. Обычная передача изменяемого примитива копирует значение, структуры и массива — ссылку; особая идентичность неизменяемого значения сохраняется согласно [квалификации](#qualification).

<a id="binding-places"></a>
### Собственное место и место вызывающего

Норма 2026-11-19 ([ТЗ](tasks/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), R01–R07). Разрешение имени в вызове определяет источник и логическое место. Мест два вида. Собственное место: поданный фактический аргумент, автозаполнение или прежнее связывание дают значение либо описание в место текущей активации. Место вызывающего: имя обозначает уже существующую локальную переменную вызывающего, без промежуточной рабочей копии. В обоих случаях переменная `x` имеет свой обычный тип `T`; чтение `x`, запись `x := value`, выражения с `x` и `@x` действуют на выбранное логическое место. Скрытый указатель, которым native передаёт место вызывающего, — способ реализации: тип `x` указателем не становится, и писать `\x` вместо `x` не требуется. У переменной-ссылки обычным типом остаётся её тип ссылки; дополнительный уровень адреса её ячейки — транспортный и к типу не добавляется.

Неявных способов три, и различаются они местом записи. [Автозаполнение](#binding-autofill) даёт объявленному без значения месту вызываемого значение одноимённой локальной переменной вызывающего — в собственное место. [Прозрачное место вызывающего](#binding-caller-place) связывает используемое внешнее имя без действующего собственного объявления с локальным местом вызывающего. [Прежнее связывание](#binding-fallback) сохранено целиком, относительно двух новых способов имеет низший приоритет и, как раньше, даёт собственное рабочее значение или описание. Действует ли у имени собственное объявление, решают [уровни объявлений](#shadowing-levels); на все три способа распространяется [двусторонний `private`](#private-binding). Неявное связывание применяется после [выбора объявления](#declaration-selection): оно не создаёт вариант выбора, не спасает отклонённый и не запускает выбор заново.

<a id="binding-autofill"></a>
#### Собственное объявленное место: порядок заполнения и автозаполнение

Для действующего собственного объявления порядок такой. Первое: явно поданный фактический аргумент заполняет место по обычным правилам; `private` явной подаче не мешает. Второе: если фактический аргумент не подан, источником остаётся собственное готовое значение или описание инициализатора. Третье: если место объявлено без инициализации и фактический аргумент не подан, автозаполнение берёт одноимённое значение из разрешённого локального контекста вызывающего. Четвёртое: автозаполнение запрещено, когда принимающее место помечено `private` или помечен выбранный автоматический источник. Пятое: без подходящего заполнения место сохраняет обычное состояние «T без инициализации», и действуют существующие проверки [`required`](#required-receiver).

Подача значения заполняет собственную ячейку, а не создаёт алиас: запись в неё места вызывающего не меняет.

~~~lmx
Caller:
    run:
        int: x 5
        Callee\work()

Callee:
    int: x
    work:
        x := 9
~~~

Место x вызова Callee\work() объявлено данными Callee без значения; фактический аргумент не подан, и автозаполнение даёт ему 5 из локального x кода run. Запись `x := 9` меняет собственную ячейку вызова work; у run остаётся 5.

Готовый инициализатор одноимённой локальной переменной вызывающего не заменяется: при `int: x 7` в Callee место держит 7, и заменить это значение может только явный фактический аргумент. Вычисляемый инициализатор не считается отсутствующим оттого, что ещё не исполнен. Подан ли фактический аргумент, определяет факт подачи, а не значение: 0 пропуском не является; отсутствие фактического аргумента и явно поданный `nil` различаются по-прежнему. Прежний механизм свободных имён на пропущенные входы дополнительно не распространяется: пропущенный вход заполняет только автозаполнение, а где оно неприменимо, место остаётся без значения.

<a id="binding-caller-place"></a>
#### Внешнее имя: прозрачное место вызывающего

Для используемого имени без действующего собственного объявления порядок такой. Первое: если действительно видимый лексический источник помечен `private`, динамическая подмена не выполняется — используется разрешённая лексическая связь. Второе: иначе имя связывается с подходящим доступным локальным местом вызывающего. Третье: если такого места нет, действует [прежнее связывание](#binding-fallback) — с прежними источниками и двусторонним `private`.

Имя, связанное вторым шагом, — обычная переменная типа `T`, обозначающая место вызывающего: чтение получает его значение, допустимая запись меняет его, `@x` адресует его. Взятие адреса записью не является и время жизни места не продлевает. Запись действует сразу, без копирования обратно при выходе: вложенный вызов и другой алиас того же места видят её немедленно. Если место вызывающего держало «T без инициализации», запись меняет и состояние инициализации, наблюдаемое обычными проверками `nil` и `required`. Для переназначения переменной-ссылки передаётся адрес её ячейки, а не только указатель на общий объект. Допустимость самой записи определяет контракт настоящего адресата: `const` и `immutable` действуют как обычно.

~~~lmx
Caller:
    run:
        int: x 5
        Worker\work()

Worker:
    work:
        x := 9
~~~

У вызова Worker\work() собственного объявления x нет, и помеченного лексического x он не видит; имя связывается с локальным местом x кода run, и после вызова там 9.

<a id="binding-fallback"></a>
#### Прежнее связывание — запасной путь

Прежнее связывание — правила этого подраздела — сохранено целиком (R01) и действует, когда два новых способа источника не дали. Оно сохраняет прежнюю семантику собственного значения или описания в namespace активации (R02, вариант A): голое присваивание меняет эту рабочую копию, а не исходное место; для ссылочного значения копируется ссылка, а не объект, и операции через неё подчиняются обычным правилам. Запрещены две подмены: заменить прозрачное место вызывающего временной копией с копированием обратно при выходе и заменить рабочую копию прежнего связывания адресом исходного места ради оптимизации — прочитанное число при этом может совпасть, но место записи другое. Варианты «только чтение» и «всякое внешнее имя — алиас» не вводятся. Выбранная связь удерживается в пределах своей обычной области действия: новое чтение не выбирает другой источник оттого, что вокруг изменились значения, а начало действия нового вложенного объявления — отдельное событие [затенения](#shadowing-levels), не повторный поиск источника.

Для свободного имени вызываемое выражение получает текущее значение из доступного контекста вызывающего выражения; при его отсутствии используется допустимый лексический поиск по `node`. Внутренние собственные объявления и формальные параметры имеют свои разрешённые места, а не ищутся в глобальном реестре. Собственные свободные имена вызываемого выражения — часть его интерфейса: добавление свободного имени в его тело меняет интерфейс этого выражения. Имена, нужные лишь выражениям, которые оно вызывает, в его интерфейс не входят и по цепочке вызовов не накапливаются (транзитивного замыкания нет; уточнение автора 2026-11-01): пересылающее выражение ничего не объявляет и не передаёт. Если у свободного имени нет источника — ни привязки по цепочке активаций, ни лексического — вызов недопустим; молчаливое создание нуля или нового поля при исполнении запрещено. Это правило о свободном имени, а не об объявленном входном месте данных: объявленный вход без значения вызову не отказывает (решение автора 2026-11-16). Уже существующее поле данных и значение свободного входа — разные места; совпадение имени само значение не копирует. Формал вызываемого — не свободное имя его тела: он получает поданный аргумент или своё значение по умолчанию ([§11](#callables)), без них — [автозаполнение](#binding-autofill), а где оно неприменимо, остаётся «T без инициализации» и вызову не отказывает ([структурный вызов](#call-receivers)); приоритет источников ниже на пропущенный формал не распространяется. Тип свободного имени — тип значения выбранной привязки, известный в момент использования, а не статическое замыкание по вызывающим выражениям: одно и то же вызываемое выражение принимает привязки разных типов. Принимающее место — объявленный локал или поле, результат, формальный аргумент, запись через само имя — принимает это значение одним допуском исполнителя по типу места; литерал рядом с таким значением берёт его тип; несовпадение типов в операции или при приёме — неявное исключение `convert` ([выходы](#exits)), а не молчаливое приведение.

Приоритет источников свободного имени: ближайшая текущая локальная привязка вызывающего выражения, доступная для динамического связывания, затем уже унаследованный им динамический вход, затем лексический поиск вызываемого выражения. Помеченные `private:` места исключаются из динамического выбора, а действительно видимое помеченное лексическое объявление динамическим источником не заслоняется ([двусторонний `private`](#private-binding)). Локальная привязка включает используемое собственное поле, формальный аргумент, результат или иное локальное значение, определённое принимающим выражением. Источники доступны по цепочке активаций: его собственные свободные имена, и только они, разрешаются по записям активаций вызывающих — ближайшая привязка первая; статическое замыкание требований по цепочке вызовов, в том числе через взаимную рекурсию, не вычисляется (транслятор не анализирует код на исполнение; уточнение автора 2026-11-01). Имя, нужное только следующему вызову, не требует ни передачи, ни локального значения; само по себе это не создаёт поле графа. Отсюда следует: метод, который сам потребляет имя, формирует значение своей активации из этих же источников, включая собственный лексический поиск, и это сформированное значение входит в его доступный контекст с учётом `private:`: при разрешённом динамическом связывании вызываемое им получает его, каким бы источником оно ни было дано. Метод, который имя только пересылает, ничего не формирует: вход, пришедший отсутствующим, идёт дальше отсутствующим, и конечный потребитель использует собственный лексический поиск. Присваивание имени меняет только значение этой активации, а явное чтение `node\x` привязки не создаёт.

Потребляемое свободное имя, в том числе используемое в полезной нагрузке throw, получает своё связывание из допустимого контекста места вызова. После выбора прежнее связывание удерживает собственное значение или вычисленное описание независимо от последующей замены источника; это не исполняет вычисляемый RHS лишь ради выбора. Пересылаемое, но не потребляемое имя не получает фиктивной локальной копии. Объявление вложенного кода не исполняет этот код и не связывает все его будущие свободные имена.

Интерпретатор не обходит тело заранее при входе. Открытие namespace просматривает только соответствующий уровень, нужный для объявлений Structure/вызываемых, видимых в обе стороны, и обычной подготовки корня; неисполняемые ветви и будущие локалы он не просматривает. Поэтому отсутствующее свободное имя отказывает при достижении его использования, а не только потому, что недостижимая ветвь о нём упоминает. Связывание, выбранное при этом достигнутом использовании, сохраняется на время своей области. Известный нативный код получает свои выбранные скрытые связывания при вызове по тем же контрактам источника и места. Ни один путь исполнения не накапливает статически требования к свободным именам всех потомков и не создаёт снимков исходного графа для выравнивания неуточнённого времени правок до endturn.

Лексический поиск следует реальным связям Structure до нулевого родителя и выбирает единственное поле нужного имени на соответствующем уровне ([имена](#fields)). `independent` отсекает внешний лексический запасной путь. Явные `node\x`, `reference\x` и `array[index]` обращаются к графу, не подменяясь динамическим `x`; контекст, скопированный `merge`, участвует лишь как запасной путь ([композиция](#composition)). Для явных путей и `node` отдельной проверки «поле принадлежит чужому вызывающему» нет; ограничения записи, типы, `const`, `immutable` и правила допустимости адреса действуют как обычно.

<a id="binding-chain"></a>
#### Цепочка вызовов

Для цепочки A → B → C, где у A есть `x`, B сам `x` не потребляет, а C потребляет, прежняя достижимость сохраняется (R07): B не обязан вводить явный аргумент, фиктивную локальную переменную или транзитивный перечень потребностей вызываемых. Если при этом сработало прежнее связывание, C получает собственное значение, и запись C в место A не идёт. Если у B есть собственная копия `x`, полученная от A, то C, получивший место `B.x`, меняет `B.x`, а исходное `A.x` сохраняется: происхождение копии не раскручивается обратно в алиас. Если у B — прозрачная связь с `A.x`, передача места `B.x` сохраняет адрес `A.x` без промежуточной копии. Запрет статического транзитивного накопления скрытых требований сохраняется: собственные непосредственно используемые входы выбранного тела не объединяются с входами всех его возможных вызываемых.

<a id="private-binding"></a>
### Ресивер private: и динамическое связывание

Динамическое связывание подаёт используемое внешнее имя из разрешённого вызывающего контекста вместо его лексического прежнего связывания. Общие правила связывания различают прозрачное место непосредственно вызывающего и собственное значение, поданное удержанным прежним связыванием. Явные лексические пути, такие как `node\x`, по-прежнему выбирают граф напрямую; это не динамическая подстановка. Видимое лексическое объявление важно для двустороннего фильтра `private`, описанного ниже, тогда как непомеченное свободное имя остаётся пригодным для динамического связывания. Так сохраняется явный лексический доступ, заданный определением автора 2026-11-17, при пересмотренном порядке связывания 2026-11-19. Ресивер `private:` запрещает неявное динамическое участие помеченного объявления и соответствующего ему места в обоих направлениях (норма 2026-11-19, [ТЗ](tasks/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), R05 и R06). Со стороны источника: помеченное место вызывающего автоматически не подаёт ни своего значения, ни своего изменяемого места. Со стороны принимающего: действительно видимое помеченное объявление лексического контекста вызываемого не затеняется значением или местом из динамического контекста, а помеченное принимающее место не заполняется автоматически. Правило применяется к [автозаполнению](#binding-autofill), [прозрачному месту вызывающего](#binding-caller-place) и динамической части [прежнего связывания](#binding-fallback). Поэтому до принятия внешнего динамического связывания устанавливается, какое лексическое объявление действительно видимо и помечено ли оно: проверки одного лишь источника недостаточно. Это свойство конкретного объявления и соответствующего ему связывания, а не запрет на написание имени. Помеченный источник пропускается, и поиск продолжается в обычном порядке: более дальний разрешённый источник того же имени остаётся доступным. Защита на стороне принимающего касается выбранного видимого объявления: помеченный `x` далёкого предка не закрывает новый внутренний непомеченный `x`. До 2026-11-19 правило было односторонним — `private:` лишь исключал поле из источников; эта формулировка снята.

Прямой видимости откуда угодно поле не лишается: явный путь, `node` и обычный лексический поиск сохраняются, вложенный лексический код поле видит. В графе ресиверы не исполняются, запись `private:` лежит в нём как записана, поэтому путь к полю идёт через неё: `S\private\field` (уточнение автора 2026-11-18); связывание эту запись в `S\field` не выпрямляет. Ресивер не вводит границу доступа, не меняет правила последовательной видимости, не заменяет `const` и `immutable` и не запрещает ни явно передать помеченное значение аргументом, ни явно заполнить помеченное принимающее место допустимым фактическим аргументом. Явно переданное значение не несёт на свои копии историю помеченного источника, и непомеченное место получателя помеченным от этого не становится. Новое внутреннее объявление обычным лексическим образом затеняет внешнее помеченное ([уровни объявлений](#shadowing-levels)). Если поле разрешилось обычным лексическим поиском, это не динамическое связывание. Не является им и чтение кодом поля собственных данных вызова: при `D: private: int: x 5` код `C` с данными `D` читает `x` как своё входное место и получает 5, а вызываемое из `C` своё `x` из этого места не получает ни одним из неявных способов — `private` запрещает только динамическое связывание (уточнение автора 2026-11-17; в уточнении данные задавала прежняя запись `call(D C)`, теперь данные — `parent(C)`).

Правило одинаково для вызова Structure по имени и обеих форм `call`, в интерпретаторе и native. Оно применяется при выборе связи существующим общим механизмом; отдельные таблицы запретов по именам, защищённый тип значения и проверки каждого прямого чтения не требуются.

Запись ресивера `private:` лежит в чистом графе, как и другие записанные ресиверы. Walker распознаёт и потребляет эту исходную запись; транслятор читает ту же запись и отражает её правило связывания в генерируемых инструкциях методов и скрытых аргументах. Ни walker, ни транслятор не строят в двоичном коде другой граф, содержащий пометки private, флаги доступа или копию исходного дерева. Обычной генерируемой логики связывания достаточно. Регрессионная проверка должна сохранять `S\private\field`, проверять то же поведение private при вызовах native/walker и отвергать второй помеченный граф, даже если его выходы случайно совпадают. Это включает последний [пример автора](tasks/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md#private-without-marked-graph).


<a id="private-examples"></a>
#### Примеры private: в data и code

Эти примеры задают оба направления private; это не подтверждения реализации. Они используют обычную композицию ресиверов: `private: int: x 10` помечает объявляемое поле x. Действию ресивера нужен один аргумент, поэтому можно передать несколько аргументов, и действие применяется к каждому по очереди: `private: int: x 10; int: y 20`, `private(int: x 10; int: y 20)` и блок под `private:` с двумя объявлениями помечают x и y, как это делают две формы с одним аргументом каждая (уточнения автора 2026-11-18). `private` принимает свои аргументы как `data` и не разворачивает аргумент, который сам является Structure ([два вида ресиверов](#two-kinds-of-receivers)): в `private: (int: x 10)` аргумент — анонимная Structure с полем x, а не объявление поля x; как аргумент-объявление он записывается в виде `private: int: x 10` и `private(int: x 10)` (уточнение автора 2026-11-18). Когда вызов исполняет объявление, поля с именем private не возникает: объявляется x. В графе каждый ресивер лежит ровно так, как записан, — граф уже есть то, что читают явные пути (уточнение автора 2026-11-17).

В роли data:

~~~lmx
Library:
    private: int: x 10
    Reader:
        return: int
        read:
            return: x
~~~

Поле хранит 10; путь к нему — Library\private\x: в графе ресиверы не исполняются, запись `private:` лежит как записана, а шага `int` в пути нет — запись примитива однозначно восстанавливается по типу и значению. Поля x у самой Library в графе нет. Данные кода `read` — его `parent`, Structure `Reader`; собственного объявления x у вызова Library\Reader\read() нет. Действительно видимое лексическое объявление x — помеченное поле Library, поэтому имя связывается лексически, и результат равен 10, какое бы x ни было у вызывающего: динамическая подмена не выполняется (сторона приёмника). Лексическому поиску метка private не мешает. Помеченное принимающее место, объявленное без значения, — `private: int: x` в данных вызова — автозаполнением не заполняется и остаётся «int без инициализации», даже когда у вызывающего есть непомеченное x; явно поданный фактический аргумент заполняет его по обычному контракту.

В роли code:

~~~lmx
Run:
    return: int
    run:
        private: int: x 20
        x := 21
        return: Library\Reader\read()
~~~

Голое x внутри run доступно после объявления; присваивание меняет его локальную ячейку на 21. Это место исключено из неявных динамических источников следующего вызова (сторона источника), и Run\run() возвращает 10. Если убрать private только у объявления внутри run, результат остаётся 10: помеченное лексическое объявление Library динамическим источником не заслоняется. Если убрать private только у x в Library, результат тоже 10: помеченный источник в run пропущен, и прежнее связывание даёт read собственную рабочую копию лексического значения. Если убрать обе пометки, read получает [прозрачное место вызывающего](#binding-caller-place) — локальное x кода run — и возвращает 21.

Прямой доступ в code сохраняется:

~~~lmx
Library\private\x := 30
int: observed Library\private\x
~~~

`observed` получает 30 независимо от одноимённых динамических переменных. Последующий Run\run() вернёт 30 по лексическому пути при тех же условиях. Ресивер private не делает поле const. Значение можно также явно передать аргументом: f(Library\private\x) использует обычный контракт f.

В run голое x и исходная запись объявления Run\run\private\x остаются разными местами по [правилу кадра](#call-frame-20261115): после локального x := 21 исходное объявление по-прежнему содержит 20. Private не добавляет обратной публикации или запрета прямого доступа.

<a id="shadowing-levels"></a>
### Уровни объявлений и затенение

Правило автора (решение автора; [ТЗ](tasks/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), R16): объявление на вложенном уровне затеняет внешнее одноимённое объявление; на одном уровне затенять нечего — используется родительское. Правило применяется через владельца объявления и лексическую область: доступная внешняя привязка и собственное объявление текущего уровня не становятся одним местом лишь из-за совпадения имени.

Последовательная видимость переменных и `const` сохраняется. До начала действия собственного объявления имя разрешается обычным образом через доступный родительский и внешний контекст; объявление ниже по тексту или в другой ветви раннему употреблению не мешает. Новое объявление во вложенной области создаёт своё место и затеняет внешнее: внутреннее `Text: x` над внешним `int: x` — собственное место типа Text, а не попытка записать Text во внешнюю int-ячейку. Повтор собственного объявления на том же уровне работает с тем же местом по общему контракту ресивера: новый RHS вычисляется и присваивается, отсутствие RHS существующее значение не обнуляет, второй ячейки не возникает. После выхода из внутренней области снова видна прежняя внешняя привязка со своим местом, режимом записи и `private` — без публикации внутренних локальных мест. Слова «собственного объявления нет» в [порядке связывания](#binding-caller-place) относятся к действующему объявлению соответствующей области, а не к предварительному поиску будущих объявлений по всему телу.

Инициализация следует из того, какое место выбрано. Существующее место при повторе на том же уровне сохраняет значение до обычной записи. Новое место с RHS или значением по умолчанию получает значение по действующим правилам и в действующее время. Новый вход без значения получает [автозаполнение](#binding-autofill) там, где выполнен его контракт и `private` разрешает обе стороны. Без допустимой инициализации место держит «T без инициализации», без неявной подстановки 0. Общего предварительного прохода с исполнением инициализаторов по-прежнему нет ([кадр вызова](#call-frame-20261115)).

<a id="inline-declaration-control"></a>
#### Контрольный пример: новое место во вложенном блоке

~~~lmx
Worker:
    work:
        int: x 5
        if: x = 5
            int: x
            required: x
~~~

У вызывающего `Worker\work()` нет локального x. Внутреннее `int: x` создаёт отдельное место и затеняет внешнее x=5. У него нет фактического, готового значения или инициализатора. Автозаполнение берёт источник из допустимого локального контекста непосредственного вызывающего; вход во встроенный `if` не создаёт нового вызывающего, поэтому объемлющий локальный x=5 не является этим источником. Внутреннее место поэтому остаётся `uninit:int`, и достигнутое `required: x` отказывает в инициализации. Внешнее место остаётся 5. Это следствие приведённых [Связывания и вызываемых §§6.1, 7.2 и 7.4](tasks/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), а не отдельное правило, которое копирует внешние локалы или заранее исполняет значения по умолчанию. При явном внутреннем инициализаторе `int: x 9` проверка проходит, а внешнее место по-прежнему остаётся 5. Это требуемые результаты, а не отчёт о выполненных тестах.

<a id="required-receiver"></a>
### Ресивер required: проверка инициализации поля

`required` проверяет инициализацию, а не истинность значения. `uninit:T` проверку не проходит; нулевое значение может её пройти. На входном объявлении она ограничивает выбор вызова: кандидату нужен явный фактический аргумент или собственный применимый инициализатор/значение по умолчанию, и скрытое автозаполнение не может подать отсутствующий обязательный вход при этом выборе. В достигнутом CODE она проверяет фактическое место в этой точке, включая любое допустимое автозаполнение или предшествующее присваивание. Это одно требование инициализации в разных потребляющих позициях, а не отдельный тип обязательного аргумента.

Писать `required` можно где угодно: все Structure взаимозаменяемы, и заранее неизвестно, какая в какой роли окажется (ответ автора 2026-11-16). Ограничений на то, в каком объявлении он стоит, нет — как нет их у `private:` ([ресивер private:](#private-binding)): `required: int: a` — обычная композиция ресиверов объявления, помечающая объявляемое поле `a`; при исполнении в вызове поля с именем `required` не возникает, а в графе запись лежит как записана. Проверку уже видимого поля можно записать и отдельной строкой — `required: a`. Аргументов может быть несколько — `required: a b c`, `required: int: a; int: b`, `required(int: a; int: b)`: действию нужен один аргумент, и ресивер применяет его к каждому по очереди, в записанном порядке (уточнение автора 2026-11-18). Возможны все сочетания — в `data` и в `code`, пометкой объявления и строкой с именем поля — и любое число проверок одной переменной: в `code` каждая выполняется на своей строке и другим не мешает. Это разные пути к одной проверке, и ни один не требует отдельного прохода: при входе в вызываемое нет ходов инициализации, кроме подачи аргументов, остальное исполняется по достижении ([кадр вызова](#call-frame-20261115)).

`required` во входных данных вызова проверяется при подаче аргументов — том действии входа, которое и так проходит по входным местам: если месту не досталось ни значения объявления, ни поданного actual, это ошибка, и ни одна запись `code` не исполняется. [Автозаполнение](#binding-autofill) за такой вход проверку не проходит: `required` во входном описании участвует в [выборе объявления](#declaration-selection), а неявное связывание в выборе не участвует (норма 2026-11-19, [ТЗ](tasks/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), §9.7). Запись `required` в `code` — помеченное объявление или строка `required: a` — проверяется на той же строке, когда до неё доходит исполнение: у объявления после его обычного действия, проверки типа с присваиванием, у строки с именем — по полю, найденному в этом месте по общим правилам [видимости](#declaration-visibility); проверяется фактическое состояние места, в том числе после разрешённого автозаполнения.

Правил видимости `required` не меняет, и из этого следует, где он не действует. Пометка относится к своему объявлению и срабатывает только там, где это объявление само действует — как входное место запуска или как достигнутая запись кода. Условий связыванию она не добавляет: помеченное поле остаётся видимым и доступным по общим правилам — лексически, динамически и по явному пути, — и вызываемое, получившее его свободным именем, этой пометкой не проверяется. Строка `required: a` не видит переменную, объявленную ниже, и имя ветви после выхода из неё: такое имя ищется обычным образом среди доступных внешних и динамических связей. Проверка выполняется один раз; на дальнейшие записи в поле она не влияет.

```text
F:
    required: int: a
    return: int
    f:
        return: a

G:
    int: a
    return: int
    g:
        required: a
        return: a

F\f(7)
F\f()
G\g(7)
G\g()
```

`F\f(7)` и `G\g(7)` возвращают 7: поле `a` инициализировано поданным actual. `F\f()` даёт ошибку при подаче аргументов, до первой записи `code`: помеченному входу `a` не досталось ни значения объявления, ни поданного actual, и одноимённое локальное место вызывающего его не спасает. `G\g()` отказывает на первой строке `code`, не исполняя остальных записей, когда у вызывающего нет доступного локального `a`; при таком `a` автозаполнение заполняет объявленное без значения место, и проверка проходит. Значение в объявлении — `required: int: a 5` у `F`, `int: a 5` у `G` — делает поле инициализированным: `F\f()` и `G\g()` возвращают 5. Пример записан формами нормы 2026-11-19: входы и поле `return` описаны данными, код — вложенная Structure ([структурный вызов](#call-receivers)).

Невыполнение обязательности входа — отказ допуска вызова; невыполнение достигнутого required в CODE — сбой на этой достигнутой форме. Используются обычная диагностика и обычная обработка сбоев. Различие общее для вызовов по имени, явного call, интерпретатора и подготовленного нативного исполнения; оно не вводит другого канала и не подразумевает статуса реализации во время выполнения.


<a id="call-frame-20261115"></a>
### Кадр вызова без обратной публикации — решение 2026-11-15

Входные места вызова описываются данными — `parent(C)` исполняемой Structure `C`; `args` в `call` и хвост формы `C(args)` подают им фактические значения по [общему контракту вызова](#call-receivers). В решении 2026-11-15 это записано для `fn`, `sub` и `catch` с одним входом `data` и для `call(D, C)`; эти формы снимаются нормой 2026-11-19 ([что снято](#removed-builtins)), правила кадра сохраняются. Каждый самостоятельный вызов вызываемого создаёт собственный namespace и локальные места. Исполнение принятой формы объявления и связанного с ней тела использует установленные места этого принимающего исполнения по [§11](#declaration-arguments); оно не создаёт свежего изолированного элемента и не перезапускает инициализатор при каждом входе в тело. Позиционные и именованные фактические аргументы отображаются на описание входа. Поданный фактический аргумент заменяет соответствующее описание namespace и подавляет исходный инициализатор. Фактический аргумент в виде объявления сохраняет саму форму замены; исполнение этой принятой формы позже следует её собственному контракту исполнения при достижении. Вход в вызов не исполняет инициализаторы пропущенных полей.

Подготовка namespace собирает объявления в корнях `data` и `code`, включая поля, поданные явными `import`, `copy` и `merge`, когда их контракты требуют потребления. Эти ресиверы всегда потребляют стандартные исходные аргументы CODE; это отделено от немедленного исполнения вычисляемых инициализаторов мест, которое подготовка не выполняет. Общего обхода лексических ветвей и рёбер ссылок графа не существует. Собственные места кода, отсутствующие во входных данных, принадлежат этому вызову и в исходные данные не дописываются. Сбор мест не отменяет последовательной видимости переменных и `const`. В графе ничего не заполняется автоматически: [автозаполнение](#binding-autofill) заполняет собственное место кадра и не пишет в граф.

Общая инициализация готовых данных происходит при построении чистого графа без вызовов программы: например, `int: i 5` присутствует в виде именованного листа `{int 5}` через существующий механизм. Вычисляемое объявление сохраняет написанный код. На входе нет отдельной фазы его исполнения: в `mark(); int: y makeValue()` вызов makeValue() происходит при достижении объявления, после mark(). Неиспользуемое вычисляемое поле входной data не выполняется. Типы «без значения» (`uninit:T`) сохраняются; отсутствие инициализатора не заменяется случайным обычным T.

Голое `x` и `@x` относятся к логическому месту, выбранному [связыванием](#binding-places). Собственное место текущего вызова после входа независимо от последующих замен исходного поля — одинаково для поданного фактического, автозаполнения, лексического и динамического источника прежнего связывания. Выбранное значение или вычисляемое описание удерживаются в виде значений или ссылок на уже существующие описания, без копии графа исполнения и без общего прохода исполнения RHS на входе; достигнутое связывание свободного имени следует временному порядку интерпретатора и нативного исполнения, указанному в [прежнем связывании](#binding-fallback). Это не глубокая копия всех объектов по ссылкам: явно переданные ссылки сохраняют идентичность целей. Локальное присваивание собственному месту не записывается обратно. Имя, связанное с [прозрачным местом вызывающего](#binding-caller-place), обозначает само это место: запись меняет его сразу, `@x` адресует его. Явный путь от Structure данных `D\x` и `code\x` обращаются к исходному графу; явные записи наблюдаются через его реальные алиасы в порядке исполнения (прежняя запись первого пути, `data\x`, снята вместе с особым именем `data`, [что снято](#removed-builtins)). Для `p\x` текущее локальное значение p выбирает референт.

Чтение вычисляемого места по голому имени — работа вызова: исполняется уже написанное выражение объявления, а не придумывается нульарный вызов полученной ссылки. Явный путь `D\field` ничего не исполняет и читает запись объявления ([явный путь](#path-reads-no-execution)). При исходном `@: fptr getFuncPtr()` запись `fptr("hello world")` сначала выполняет getFuncPtr(), затем вызывает полученную функцию. `fptr := 0` меняет только namespace; `D\fptr := 0` меняет исходное поле так, чтобы оно читалось как `@: fptr 0`. Если исходное поле изменено до первого чтения голого fptr, выбранное при входе описание кадра от этого не меняется.

<a id="path-reads-no-execution"></a>
#### Явный путь ничего не исполняет

Чтение вычисляемого объявления по явному пути ничего не исполняет. Это заменяет прежнее правило вычисления по пути. Явный путь — `struct\field` — читает то, что записано в графе, и не делает ни одного вызова; в решении назван и путь `data\field` — особое имя `data` нормой 2026-11-19 снято ([что снято](#removed-builtins)), и к полю данных вызова ведёт путь от самой Structure данных, `D\field`. Если поле объявлено готовым значением, `int: field 5`, путь даёт это значение — число 5 типа `int`. Если объявление вычисляемое, `int: field f()`, путь даёт саму запись объявления — Structure ресивера с именем и написанным вызовом; `f()` не исполняется. Выражение ничем не отличается от вызова: при `int: field 5 * 2` путь возвращает не 10, а полную Structure, которая начинается с `int:` (уточнение автора). Так же `D\S` при записи `S: merge: A B` в данных `D` никакого `merge` не исполняет и даёт запись.

Вычисляемое объявление исполняет вызов, и только он: вызов готовит свой namespace по корневым объявлениям данных и исполняет написанное выражение, когда обращается к своему локальному месту по голому имени ([кадр вызова](#call-frame-20261115)). Эта работа вызова остаётся прежней: общей инициализации нет, вызов готовит место по конкретному обращению (подтверждение автора). К чтению по явному пути она отношения не имеет. Поэтому `sys\toLmx` выводит записи как они написаны, а запись по явному пути меняет сам граф — без скрытых вызовов и без кеша результатов. Вывод графа сводится к выводу Structure и примитивных значений, уже записанных в арене со своим типом: ресиверы по пути возвращаются как Structure.

<a id="computed-field-address"></a>
Взятие адреса локального места также получает вычисляемое значение: для входного `int: x next()` обращение `@x` выполняет next() и даёт адрес обычной локальной int-ячейки. `@(D\field)`, где в данных `D` записано `int: field getValue()`, адресует запись объявления, а не результат getValue(): явный путь ничего не исполняет (решение автора 2026-11-17, [явный путь](#path-reads-no-execution); прежнее правило от 2026-11-15, по которому адресовался результат, им снято). Готовое место адресуется непосредственно; время жизни места остаётся обычным. `@f()` было исследовательским примером, не отдельной задачей реализации или запрета по аналогии с C. Уточнения автора.

Повторное объявление имени на том же уровне не вводит ещё одну C-переменную, но сохраняет остальные действия: `int: x bump()` вычисляет bump(), выполняет общий допуск и присваивает существующей x. Объявление того же имени на вложенном уровне создаёт своё место и затеняет внешнее ([уровни объявлений](#shadowing-levels); прежняя формулировка — любое повторное объявление уже видимого имени пишет в прежнюю ячейку — нормой 2026-11-19 сужена до одного уровня). Новое имя ветви видно с объявления на её уровне и ниже, не снаружи. Два объявления в данных остаются двумя физическими вхождениями: `S\[0]x` и `S\[1]x`; `S\x` неоднозначно. Последовательная видимость переменных и const снимает прежнее раннее обращение к будущему локалу по голому имени. Чтение написанного вычисляемого объявления через явный путь его не исполняет; RHS исполняет достижение его строки в code. Отдельных исключений и скрытого кеша вычислений нет.

Для исполнения изменяемого code действует [явная компиляция и граница endturn](#explicit-compilation). Обязательный снимок code при входе отменён; неизменность выбранных локальных значений/описаний namespace этим не отменяется. Фазы исполнения инициализаторов на входе по-прежнему нет.

C-сигнатуры выводятся из реальных вызовов. Разные наборы поданных аргументов дают разные сигнатуры; полное описание данных само по себе не становится списком параметров каждого C-входа. [Сигнатура `fn`](#fn-signature) описывает контракт вызова, а не исполняемую реализацию. Обычная Structure и метод используют общий механизм компиляции тела и кадра; данные вызова — `parent` исполняемой Structure ([структурный вызов](#call-receivers)), а у корневого входа R0 данных нет ([R0](#root-entry)).

<a id="binding-executors"></a>
### Связывание у исполнителей

Норма одна для интерпретатора и native ([ТЗ](tasks/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), §11–§12). Прямой вызов native → native сохраняется там, где выбранные реализация, типы и связывание известны. Автозаполненное значение понижается тем же параметром `T`, что и явный фактический аргумент; [прозрачное место вызывающего](#binding-caller-place) — скрытым адресом его ячейки; [прежнее связывание](#binding-fallback) по-прежнему даёт собственное место. Общее C-тело может разделяться между режимами через адаптеры, но адаптер сохраняет владельца записи и поведение `@`. При одинаковых явных фактических режим скрытого входа может различаться из-за контекста вызывающего и `private`: нативный вход соответствует действительному контракту либо получает описание места; новые пользовательские типы указателей не вводятся.

У обычной нативной локальной переменной нет заголовка арены «тип, значение»: её тип нельзя прочитать из четырёх байтов перед адресом. Тип, способ доступа, состояние инициализации и применимые ограничения следуют из общего представления места и контракта вызова. Сочетаний исполнителей четыре — native → native, native → интерпретатор, интерпретатор → native, интерпретатор → интерпретатор, — и во всех `x` имеет один логический тип `T`, а допустимая запись меняет одно и то же логическое место. Для цели, известной только при исполнении, действует существующий доступ к разрешённым локальным контекстам: сырой C-стек словарём имён не служит, статическое транзитивное замыкание требований не вводится. Служебные C-функции, мост и диспетчер `call` не подменяют контекст вызывающего своими служебными локальными переменными: источники определяет программное место вызова.

Границы. Load-dirty, `flush`, публикация локальных кадров и копирование обратно при выходе не возвращаются ([отмена публикации](#flush-receiver-contract)). Чтение через место вызывающего не заменяется снимком без доказательства, что наблюдаемое поведение при вложенных вызовах сохраняется. Отсутствие подходящего нативного входа не запускает скрытую компиляцию ([явная компиляция](#explicit-compilation)); постоянные кеши окружений и автоматическая инвалидация графа не добавляются; `restrict` не ставится лишь из-за скрытой передачи указателя или `private`. Связывание не добавляет полей в исходные данные и код и не меняет их структуру; служебные сведения namespace — не второй граф и не постоянное хранилище разрешений имён, нативные дескрипторы остаются в таблицах `call`. Прозрачная связь не продлевает время жизни локального места; сохранение графа не делает адрес временной C-переменной переносимой ссылкой; при `yield` выбранная связь не перепривязывается к одноимённой локальной переменной нового вызывающего `next`.

<a id="explicit-compilation"></a>
### Явная компиляция, native и endturn

Компиляция явно выбранного корня включает построение чистого графа и его проверку без вызовов программы, отдельную обязательную фазу build-test на этом чистом графе, понижение до L1 и C, машинную компиляцию и регистрацию входа в таблицах `call`. Тесты используют свои обычные контракты ресиверов и вызовов; точка входа приложения не запускается лишь для того, чтобы её скомпилировать. `sys\compile(S)` вызывает эту общую цепочку; `sys\translate(S)` останавливается на тексте L1. Неудача возвращает диагностику и не даёт нового нативного входа. Операция времени выполнения переиспользует нужные части той же цепочки построителя без второго компилятора.

Native — это явный дескриптор: обычная Structure, содержащая варианты машинных входов и сигнатуры, ссылки на двоичный модуль/вход и доступные пути к исходному тексту L1/C. Его основное хранилище — таблицы call арены, общие для методов и обычных исполняемых Structure. `sys\native(S)` запрашивает эти таблицы, не запуская S. Заголовок Lmx имеет parent/length/storage и не имеет поля native.

Исходный граф не дополняется синтетическими полями native как побочным эффектом трансляции или создания описания fn. Любое явно присутствующее обычное поле с именем native остаётся обычным материалом графа; оно не является псевдополем заголовка. Исходные формы остаются записанными как есть, а служебные и нативные дескрипторы остаются в установленных таблицах. Динамические вызовы выбирают подходящие варианты для фактической цели и вызова; иначе допустимое тело использует walker. Компиляция и регистрация явные, а не скрытые следствия входа в вызов, копирования или правок графа.

Вызов известного native из native сразу понижается в прямой C-вызов выбранного варианта:
обычные параметры и необходимые скрытые аргументы связывания, без обхода графа, поиска в таблице call,
универсальной упаковки actuals или графового кадра ради организации вызова. Явные обращения программы
к данным и коду вызова по путям сохраняются. Это основной маршрут генерации, а не отложенная оптимизация.

Запись меняет адресованный граф сразу и не отслеживается ради native. Она не обнуляет входы,
не запускает проверку или компиляцию и не обслуживает обратные зависимости машинного кода.
Удаляются такие обходы, таблицы, переносы и ветки генератора вместе с проверками. Обычные обязанности
памяти и ссылок сохраняются; они не являются системой актуальности native. Без явной компиляции
изменение графа не обещает обновления машинного кода или автоматического исправления программы.

До завершения такта момент применения правок при исполнении не гарантируется: обходчик может увидеть
их раньше native. Копировать code ради одинакового момента применения не требуется, включая прежний
снимок кода соответствующей C-функции. Независимость выбранных собственных мест namespace от исходной data
сохраняется; связывание передаётся скрытыми аргументами — значением для собственного места, адресом ячейки
для [места вызывающего](#binding-executors), — лексическое окружение не копируется.
После успешной явной компиляции и endturn следующий вход использует подготовленное обновление.
Один endturn не обнаруживает правки, не проверяет граф и не компилирует его.

Схема (решение автора 2026-11-18). Транслятор строит полный чистый граф и выдаёт C для скомпилированных методов; он не выдаёт второй граф данных как статическое состояние C. Рабочего графа нет. Двоичный код включает R0 и методы интерпретатора; R0 держит свой указатель на граф локально. Интерпретатор запускается только на чистом графе и исполняет обязательные ресиверы сборки `test` по обычным контрактам сборки и ресиверов до финальной компиляции C. Это не рекурсивный поиск каждой формы `test` в DATA, а вложенные вызовы сохраняют обычную диспетчеризацию native/walker. Во время исполнения схема та же: интерпретатор работает на чистом графе, и изменения графа на это не влияют; следующий цикл генерации C и компиляции выполняется только механизмом, описанным здесь, — явной компиляцией и границей endturn. Подключаемые позже скрипты интерпретирует собранное ядро по той же схеме: C генерируется, а полная компиляция выполняется только по запросу пользовательского кода; скрипт поступает как обычное Message.

Прямой C-вызов A→B остаётся частью скомпилированного A. Перекомпиляция только B не переписывает старый A: для обновления цепочки явно компилируют общую единицу, содержащую нужные вызывающие функции и цели. Это работа компиляции, без наблюдения за присваиваниями или поиска native перед каждым прямым вызовом. Старые активные машинные кадры, включая finally, должны завершиться до освобождения используемого ими машинного кода.


<a id="direct-access-cache"></a>
### Прямой доступ без отдельного кеша языка

Предлагаемый кеш прямого доступа, общий для вызовов, отменяется вместе с load-dirty. Алиасы одного и того же локального места времени выполнения наблюдают его последовательные записи. Пути, выбирающие одну и ту же структурную ячейку графа, наблюдают фрагмент, который сейчас держит эта ячейка, включая явную замену. Две разные ячейки графа, которые прежде держали ссылки на один примитивный фрагмент, не становятся одним записываемым местом лишь потому, что эти ссылки совпали; замена одной ячейки не обещает перенаправить другую. Локальная переменная остаётся собственным местом текущего кадра, отдельным от исходной записи графа; имя, связанное как место вызывающего, обозначает место вызывающего ([собственное место и место вызывающего](#binding-places)). Обычные оптимизации компилятора сохраняют эти правила без новых таблиц когерентности и обязательных контрольных точек.

<a id="flush-receiver-contract"></a>
### Отмена публикации локальных кадров и flush()

Кадры `data` и `code` не публикуются в граф. Удаляются load-dirty, обратная запись на вызове и выходе, общий кеш прямого доступа и запланированный ресивер `flush()`. Прежние примеры с публикацией внешнего `x = 2` и вложенного `x = 9` описывали отменённую модель. Теперь это независимые локальные места; исходный граф меняют только явные операции. Запись через [прозрачное место вызывающего](#binding-caller-place) публикацией не является: она сразу меняет локальное место вызывающего, а копирования при выходе нет. Публикация Message и выдача результата построения — другие операции, этим решением они не отменяются.

<a id="activation-history"></a>
### Активации и согласованные границы

Стек вызовов остаётся единственной неявной историей активаций: обычный C-стек у native и соответствующий управляющий стек у интерпретатора. Рекурсивные и вложенные вызовы получают разные собственные локальные ячейки, в том числе разные `@x`. Возврат, `throw`, `finally`, `retry` и `yield` не создают обратной публикации этих ячеек. Имя, связанное с [прозрачным местом вызывающего](#binding-caller-place), собственной ячейки не получает: оно обозначает место вызывающего, запись меняет его сразу, и `@x` адресует его. Явно переданные ссылки сохраняют идентичность своих целей.

Установленные границы активаций таковы: без общего прохода инициализаторов на входе; последовательные переменные/const; достигнутое вычисление и запрос через логический namespace; явные пути, не исполняющие исходные записи; и явная компиляция плюс endturn для гарантированных нативных обновлений. Собственные места остаются независимыми от исходных записей, тогда как прозрачные связывания вызывающего обозначают свои реальные исходные ячейки. Прежние модели load-dirty, flush и исполняемых fn/sub сняты. Catch следует сохранённому [контракту обработчика](#catch-common-model). Это семантические требования, а не результаты реализации или тестов.
[EN]
Value storage at a declaration in the complete Structure, a working value of the current activation, an explicit formal argument, a dynamic input and the caller's place must be distinguished. They have distinct mutation rules; a working copy does not create a second persistent graph. Ordinary passing copies a mutable primitive's value and a Structure or Array's reference; the special identity of an immutable value is retained under [qualification](#qualification).

<a id="binding-places"></a>
### Own place and caller's place

The norm of 2026-11-19 ([the requirements](tasks/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), R01–R07). Name resolution in a call determines the source and the logical place. There are two kinds of places. Own place: a supplied actual argument, autofill or the former binding gives a value or a description into the place of the current activation. Caller's place: the name denotes an already existing local variable of the caller, with no intermediate working copy. In both cases the variable `x` has its ordinary type `T`; reading `x`, writing `x := value`, expressions with `x` and `@x` act on the selected logical place. The hidden pointer by which native passes the caller's place is a way of implementation: the type of `x` does not become a pointer, and writing `\x` instead of `x` is not required. For a reference variable its ordinary type remains its reference type; the additional level of the address of its cell is transport-only and is not added to the type.

There are three implicit ways, and they differ by the place of the write. [Autofill](#binding-autofill) gives a place of the callee declared without a value the value of the same-named local variable of the caller -- into its own place. The [transparent caller place](#binding-caller-place) binds a used external name that has no own declaration in force to the caller's local place. The [former binding](#binding-fallback) is kept in full, has the lowest priority relative to the two new ways and, as before, gives an own working value or description. Whether a name has an own declaration in force is decided by [declaration levels](#shadowing-levels); [two-way `private`](#private-binding) applies to all three ways. Implicit binding is applied after [declaration selection](#declaration-selection): it does not create a variant of selection, does not rescue a rejected one and does not restart the selection.

<a id="binding-autofill"></a>
#### An own declared place: the order of filling and autofill

For an own declaration in force the order is as follows. First: an explicitly supplied actual argument fills the place by the ordinary rules; `private` does not hinder an explicit supply. Second: if no actual argument is supplied, the source remains the own ready value or the description of the initializer. Third: if the place is declared without initialization and no actual argument is supplied, autofill takes the same-named value from the permitted local context of the caller. Fourth: autofill is forbidden when the receiving place is marked `private` or the selected automatic source is marked. Fifth: without a suitable filling the place keeps the ordinary state "T without initialization", and the existing checks of [`required`](#required-receiver) apply.

Supplying a value fills an own cell and does not create an alias: a write into it does not change the caller's place.

~~~lmx
Caller:
    run:
        int: x 5
        Callee\work()

Callee:
    int: x
    work:
        x := 9
~~~

The place x of the call Callee\work() is declared by the data of Callee without a value; no actual argument is supplied, and autofill gives it 5 from the local x of the code run. The write `x := 9` changes the own cell of the call of work; run keeps 5.

A ready initializer is not replaced by the same-named local variable of the caller: with `int: x 7` in Callee the place holds 7, and only an explicit actual argument can replace this value. A computed initializer is not considered absent just because it has not been executed yet. Whether an actual argument is supplied is determined by the fact of supplying, not by the value: 0 is not an omission; the absence of an actual argument and an explicitly supplied `nil` are still distinguished. The former mechanism of free names does not extend to omitted inputs in addition: an omitted input is filled only by autofill, and where it is inapplicable the place remains without a value.

<a id="binding-caller-place"></a>
#### An external name: the transparent caller place

For a used name with no own declaration in force the order is as follows. First: if the really visible lexical source is marked `private`, dynamic substitution is not performed -- the permitted lexical binding is used. Second: otherwise the name is bound to a suitable available local place of the caller. Third: if there is no such place, the [former binding](#binding-fallback) applies -- with the former sources and two-way `private`.

A name bound by the second step is an ordinary variable of type `T` that denotes the caller's place: a read gets its value, a permitted write changes it, `@x` addresses it. Taking an address is not a write and does not extend the lifetime of the place. A write takes effect at once, without copying back at exit: a nested call and another alias of the same place see it immediately. If the caller's place held "T without initialization", the write also changes the initialization state observed by the ordinary checks of `nil` and `required`. For reassigning a reference variable the address of its cell is passed, not only the pointer to the shared object. Whether the write itself is permitted is determined by the contract of the real addressee: `const` and `immutable` act as usual.

~~~lmx
Caller:
    run:
        int: x 5
        Worker\work()

Worker:
    work:
        x := 9
~~~

The call Worker\work() has no own declaration of x and does not see a marked lexical x; the name is bound to the local place x of the code run, and after the call it holds 9 there.

<a id="binding-fallback"></a>
#### The former binding -- the fallback

The former binding -- the rules of this subsection -- is kept in full (R01) and acts when the two new ways have given no source. It keeps the former semantics of an own value or description in the namespace of the activation (R02, variant A): a bare assignment changes this working copy rather than the source place; for a reference value the reference is copied, not the object, and operations through it follow the ordinary rules. Two substitutions are forbidden: replacing the transparent caller place with a temporary copy that is copied back at exit, and replacing the working copy of the former binding with the address of the source place for the sake of optimization -- the number read may then coincide, but the place of the write differs. The variants "read-only" and "every external name is an alias" are not introduced. The selected binding is held within its ordinary scope: a new read does not choose another source because the values around have changed, and the coming into force of a new nested declaration is a separate event of [shadowing](#shadowing-levels), not a repeated search for the source.

For a free name, the called expression receives the current value from the caller's available context; if unavailable, permitted lexical lookup follows `node`. Own declarations and formal parameters have their respective resolved locations rather than being searched in a global registry. The called expression's own free names are part of its interface: adding a free name to its body changes that expression's interface. Names needed only by the expressions it calls are not part of its interface and do not accumulate along call chains (there is no transitive closure; the author's clarification of 2026-11-01): a forwarding expression declares and passes nothing. A free name with no source -- no binding along the chain of activations and no lexical source -- makes the call inadmissible; silently creating zero or a new field during execution is prohibited. This is a rule about a free name, not about a declared input place of the data: a declared input without a value does not make the call refuse (the author's decision of 2026-11-16). An existing data field and a free input's value are distinct places; matching names do not copy the value itself. A callable's formal is not a free name of its body: it receives the supplied argument or its default value ([§11](#callables)), without them -- [autofill](#binding-autofill), and where it is inapplicable it stays "T without initialization" and does not make the call refuse ([structural call](#call-receivers)); the source priority below does not extend to an omitted formal. A free name's type is the type of the value of the selected binding, known when the value is used, not a static closure over the callers: one and the same called expression accepts bindings of different types. The receiving place -- a declared local or field, a result, a formal argument, a write through the name itself -- admits that value by the executor's one admission by the place's type; a literal beside such a value takes its type; a type mismatch in an operation or at a reception is the implicit `convert` throw ([exits](#exits)), never a silent conversion.

A free name's sources have this priority: the caller's nearest current local binding eligible for dynamic binding, then its already inherited dynamic input, then the callee's lexical lookup. Places marked `private:` are excluded from dynamic selection, and a really visible marked lexical declaration is not shadowed by a dynamic source ([two-way `private`](#private-binding)). A local binding includes a used own field, formal argument, result or another receiver-defined local value. The sources are available along the chain of activations: its own free names, and only those, are resolved through the activation records of its callers, nearest binding first; no static closure of requirements along call chains, mutual recursion included, is computed (the translator does not analyse code for its execution; the author's clarification of 2026-11-01). A name needed only by the next call requires neither forwarding nor a local value; by itself it creates no graph field. It follows that a method which itself consumes the name forms its activation's value of it from these same sources, its own lexical lookup included, and that formed value belongs to its available context subject to `private:`: when dynamic binding is permitted, what it calls receives it, whichever source gave it. A method that only forwards the name forms nothing: an entry that arrived absent travels on absent, and the eventual consumer uses its own lexical lookup. Assigning the name changes that activation's value only, and an explicit `node\x` read forms no binding.

A consumed free name, including one used in a throw payload, obtains its binding from the permitted context of the language call site. Once selected, fallback holds its own value or computed description independently of later source replacement; this does not execute a computed RHS merely to select it. A forwarded but unconsumed name gains no dummy local copy. Declaring nested code does not run that code or bind all its future free names.

The interpreter does not pre-walk the body on entry. Opening a namespace scans only the relevant level needed for bidirectionally visible Structure/callable declarations and ordinary root preparation; it does not scan unexecuted branches or future locals. A missing free name is therefore refused when its use is reached, not merely because an unreachable branch mentions it. A binding selected at that reached use is retained for its scope. Known native code receives its selected hidden bindings at the call under the same source and place contracts. Neither execution path statically accumulates all descendants' free-name requirements or invents source-graph snapshots to equalize unspecified pre-endturn edit timing.

Lexical lookup follows real Structure links to a zero parent and selects the sole field of the required name at the relevant level ([names](#fields)). `independent` cuts the external lexical fallback. Explicit `node\x`, `reference\x` and `array[index]` address the graph rather than being replaced by a dynamic `x`; a context copied by `merge` participates only as fallback ([composition](#composition)). For explicit paths and `node` there is no separate check "the field belongs to a foreign caller"; write restrictions, types, `const`, `immutable` and the rules for the admissibility of an address act as usual.

<a id="binding-chain"></a>
#### The chain of calls

For a chain A → B → C, where A has `x`, B itself does not consume `x` and C does, the former reachability is kept (R07): B need not introduce an explicit argument, a dummy local variable or a transitive list of the needs of its callees. If the former binding has acted in this case, C receives its own value, and C's write does not go into A's place. If B has an own copy of `x` received from A, then C, which received the place `B.x`, changes `B.x`, and the original `A.x` is kept: the origin of a copy is not unwound back into an alias. If B has a transparent link with `A.x`, passing the place `B.x` keeps the address `A.x` without an intermediate copy. The ban on static transitive accumulation of hidden requirements is kept: the own directly used inputs of the selected body are not merged with the inputs of all its possible callees.

<a id="private-binding"></a>
### Receiver private: and dynamic binding

Dynamic binding supplies a used external name from the permitted calling context instead of its lexical fallback. The common binding rules distinguish a transparent immediate-caller place from an own value supplied by the retained fallback. Explicit lexical paths such as `node\x` still select the graph directly; they are not dynamic substitution. The visible lexical declaration matters to the two-way `private` filter below, while an unmarked free name remains eligible for dynamic binding. This preserves explicit lexical access from the author's definition of 2026-11-17 under the revised binding order of 2026-11-19. Receiver `private:` forbids the implicit dynamic participation of the marked declaration and of the place corresponding to it in both directions (the norm of 2026-11-19, [the requirements](tasks/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), R05 and R06). The source side: a marked place of the caller automatically supplies neither its value nor its mutable place. The receiver side: a really visible marked declaration of the lexical context of the callee is not shadowed by a value or a place from the dynamic context, and a marked receiving place is not autofilled. The rule applies to [autofill](#binding-autofill), the [transparent caller place](#binding-caller-place) and the dynamic part of the [former binding](#binding-fallback). Therefore, before an external dynamic binding is accepted, it is established which lexical declaration is really visible and whether it is marked: checking only the source is not enough. This is a property of a particular declaration and its corresponding binding, not a ban on the name's spelling. A marked source is skipped, and the search continues in the ordinary order: a more distant permitted source of the same name remains available. The receiver-side protection concerns the selected visible declaration: a marked `x` of a distant ancestor does not close a new inner unmarked `x`. Before 2026-11-19 the rule was one-sided -- `private:` merely excluded a field from the sources; that wording is withdrawn.

The field remains directly visible from anywhere: an explicit path, `node` and ordinary lexical lookup remain available, and nested lexical code sees the field. Receivers are not executed in the graph, and the `private:` record lies there as it is written, so the path to the field goes through it: `S\private\field` (the author's clarification of 2026-11-18); binding does not straighten this record into `S\field`. The receiver introduces no access boundary, does not change sequential visibility, does not replace `const` and `immutable`, and prohibits neither explicitly passing the marked value as an argument nor explicitly filling a marked receiving place with a permitted actual argument. An explicitly passed value does not carry the history of the marked source onto its copies, and an unmarked place of the recipient does not become marked from this. A new inner declaration shadows an outer marked one in the ordinary lexical way ([declaration levels](#shadowing-levels)). Resolving the field through ordinary lexical lookup is not dynamic binding. Neither is a code's reading of a field of its own call data: with `D: private: int: x 5` the code `C` with the data `D` reads `x` as its own input place and gets 5, while what `C` calls does not get its `x` from that place by any of the implicit ways -- `private` forbids only dynamic binding (the author's clarification of 2026-11-17; in the clarification the data were given by the former form `call(D C)`, now the data are `parent(C)`).

The rule is identical for calling a Structure by name and both forms of `call`, in the interpreter and native execution. The existing common binding mechanism applies it when selecting a binding; it requires no separate name-denial tables, protected value type, or checks on every direct read.

The record of the receiver `private:` lies in the clean graph like the other written receivers. The walker recognizes and consumes that original record; the translator reads the same record and reflects its binding rule in generated method instructions and hidden arguments. Neither builds another graph containing private marks, access flags or a replica of the source tree in the binary. The ordinary generated binding logic is sufficient. A regression must preserve `S\private\field`, verify the same private behavior across native/walker calls, and reject a second marked graph even if its outputs happen to match. This incorporates the latest [author example](tasks/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md#private-without-marked-graph).


<a id="private-examples"></a>
#### Examples of private: in data and code

These examples specify both directions of private; they are not implementation receipts. They use ordinary receiver composition: `private: int: x 10` marks the declared field x. The receiver's action needs one argument, so several arguments may be passed and the action applies to each in turn: `private: int: x 10; int: y 20`, `private(int: x 10; int: y 20)` and a block under `private:` with two declarations mark x and y, as two forms with one argument each do (the author's clarifications of 2026-11-18). `private` takes its arguments as `data` and does not unwrap an argument that is itself a Structure ([two kinds of receivers](#two-kinds-of-receivers)): in `private: (int: x 10)` the argument is an anonymous Structure with the field x, not a declaration of the field x; as a declaration argument it is written in `private: int: x 10` and in `private(int: x 10)` (the author's clarification of 2026-11-18). When a call executes the declaration, no field named private arises: x is declared. In the graph every receiver lies exactly as it is written -- the graph is already what the explicit paths read (the author's clarification of 2026-11-17).

In the data role:

~~~lmx
Library:
    private: int: x 10
    Reader:
        return: int
        read:
            return: x
~~~

The field holds 10; the path to it is Library\private\x: receivers are not executed in the graph, the `private:` record lies there as it is written, and the path has no `int` step -- the record of a primitive is recovered unambiguously from its type and value. Library itself has no field x in the graph. The data of the code `read` is its `parent`, the Structure `Reader`; the call Library\Reader\read() has no own declaration of x. The really visible lexical declaration of x is the marked field of Library, so the name is bound lexically, and the result is 10 whatever x the caller has: dynamic substitution is not performed (the receiver side). The mark private does not hinder lexical lookup. A marked receiving place declared without a value -- `private: int: x` in the data of the call -- is not filled by autofill and remains "int without initialization" even when the caller has an unmarked x; an explicitly supplied actual argument fills it by the ordinary contract.

In the code role:

~~~lmx
Run:
    return: int
    run:
        private: int: x 20
        x := 21
        return: Library\Reader\read()
~~~

Bare x inside run is available after its declaration; assignment changes its local cell to 21. This place is excluded from the implicit dynamic sources of the next call (the source side), and Run\run() returns 10. If private is removed only from the declaration inside run, the result remains 10: the marked lexical declaration of Library is not shadowed by a dynamic source. If private is removed only from x in Library, the result is also 10: the marked source in run is skipped, and the former binding gives read an own working copy of the lexical value. If both marks are removed, read gets the [transparent caller place](#binding-caller-place) -- the local x of the code run -- and returns 21.

Direct access in code remains:

~~~lmx
Library\private\x := 30
int: observed Library\private\x
~~~

`observed` receives 30 regardless of same-named dynamic variables. A later Run\run() returns 30 through lexical lookup under the same conditions. Private does not make the field const. The value may also be passed explicitly: f(Library\private\x) follows f's ordinary contract.

In run, bare x and the source record of the declaration Run\run\private\x remain distinct places under the [frame rule](#call-frame-20261115): after local x := 21, the source declaration still holds 20. Private introduces neither write-back nor a restriction on direct access.

<a id="shadowing-levels"></a>
### Declaration levels and shadowing

The author's rule (author decision; [the requirements](tasks/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), R16): a declaration at a nested level shadows an outer declaration of the same name; at one level there is nothing to shadow -- the parent one is used. The rule is applied through the owner of the declaration and the lexical scope: an available outer binding and an own declaration of the current level do not become one place merely because the names coincide.

Sequential visibility of variables and `const` is kept. Before an own declaration comes into force, the name is resolved in the ordinary way through the available parent and outer context; a declaration lower in the text or in another branch does not hinder an early use. A new declaration in a nested scope creates its own place and shadows the outer one: an inner `Text: x` above an outer `int: x` is an own place of type Text, not an attempt to write Text into the outer int cell. Repeating an own declaration at the same level works with the same place under the general contract of the receiver: the new RHS is evaluated and assigned, the absence of an RHS does not reset the existing value, and no second cell arises. After leaving the inner scope the former outer binding is visible again with its own place, write mode and `private` -- without publication of inner local places. The words "there is no own declaration" in the [order of binding](#binding-caller-place) refer to the declaration in force in the corresponding scope, not to a preliminary search for future declarations over the whole body.

Initialization follows from which place is selected. An existing place, on a repeat at the same level, keeps its value until an ordinary write. A new place with an RHS or a default value gets the value by the rules in force and at the time in force. A new input without a value gets [autofill](#binding-autofill) where its contract is satisfied and `private` permits both sides. Without a permitted initialization the place holds "T without initialization", with no implicit substitution of 0. There is still no general preliminary pass that executes initializers ([call frame](#call-frame-20261115)).

<a id="inline-declaration-control"></a>
#### Control example: a new place in a nested block

~~~lmx
Worker:
    work:
        int: x 5
        if: x = 5
            int: x
            required: x
~~~

The caller of `Worker\work()` has no local x. The inner `int: x` creates a distinct place and shadows the outer x=5. It has no actual, ready value or initializer. Autofill takes its source from the immediate caller's permitted local context; entering an inline `if` does not create a new caller, so the enclosing local x=5 is not that source. The inner place therefore remains `uninit:int`, and the reached `required: x` refuses initialization. The outer place remains 5. This is the consequence of the supplied [Binding and Callables §§6.1, 7.2 and 7.4](tasks/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), not a separate rule that copies outer locals or eagerly executes defaults. With an explicit inner initializer, `int: x 9`, the check passes and the outer place still remains 5. These are required outcomes, not a report of executed tests.

<a id="required-receiver"></a>
### Receiver required: checking that a field is initialized

`required` checks initialization, not the truthiness of a value. `uninit:T` fails; zero can satisfy it. On an input declaration it constrains call selection: the candidate needs an explicit actual or its own applicable initializer/default, and hidden autofill cannot supply a missing required input during that selection. In reached CODE it checks the actual place at that point, including any allowed autofill or prior assignment. This is one initialization requirement in different consuming positions, not a separate mandatory-argument type.

`required` may be written anywhere: all Structures are interchangeable, and it is not known in advance which one ends up in which role (the author's answer of 2026-11-16). There is no restriction on which declaration it stands in -- just as `private:` has none ([receiver private:](#private-binding)): `required: int: a` is the ordinary composition of declaration receivers that marks the declared field `a`; when a call executes it, no field named `required` arises, while in the graph the record lies as it is written. The check of an already visible field may also be written as a separate line -- `required: a`. There may be several arguments -- `required: a b c`, `required: int: a; int: b`, `required(int: a; int: b)`: the action needs one argument, and the receiver applies it to each in turn, in the written order (the author's clarification of 2026-11-18). All combinations are possible -- in `data` and in `code`, as a mark of a declaration and as a line with the name of a field -- and so is any number of checks of one variable: in `code` each runs on its own line and does not interfere with the others. These are different paths to one check, and neither needs a separate pass: on entry to a callable there are no initialization passes besides the supply of arguments, and the rest is executed when reached ([call frame](#call-frame-20261115)).

`required` in the input data of a call is checked when the arguments are supplied -- the one action of the entry that passes over the input places anyway: if the place received neither a value of its declaration nor a supplied actual, it is an error, and no record of `code` is executed. [Autofill](#binding-autofill) does not make such an input pass the check: `required` in the input description takes part in [declaration selection](#declaration-selection), and implicit binding does not take part in selection (the norm of 2026-11-19, [the requirements](tasks/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), §9.7). A `required` form in `code` -- a marked declaration or the line `required: a` -- is checked on that same line, when execution reaches it: for a declaration after its ordinary action, the check of the type with an assignment, for the line with a name by the field found at that place under the general [visibility](#declaration-visibility) rules; the actual state of the place is checked, including after a permitted autofill.

`required` does not change the visibility rules, and from this follows where it does not act. The mark belongs to its declaration and fires only where that declaration itself acts -- as an input place of a launch or as a reached record of code. It adds no condition to binding: the marked field remains visible and accessible under the general rules -- lexically, dynamically and by an explicit path -- and a callable that received it as a free name is not checked by this mark. The line `required: a` does not see a variable declared below it, nor a name of a branch after the branch is left: such a name is looked up in the ordinary way among the available outer and dynamic bindings. The check runs once; it does not affect later writes into the field.

```text
F:
    required: int: a
    return: int
    f:
        return: a

G:
    int: a
    return: int
    g:
        required: a
        return: a

F\f(7)
F\f()
G\g(7)
G\g()
```

`F\f(7)` and `G\g(7)` return 7: the field `a` is initialized by the supplied actual. `F\f()` gives an error when the arguments are supplied, before the first record of `code`: the marked input `a` received neither a value of its declaration nor a supplied actual, and a same-named local place of the caller does not rescue it. `G\g()` refuses on the first line of `code`, without executing the other records, when the caller has no available local `a`; with such an `a`, autofill fills the place declared without a value, and the check passes. A value in the declaration -- `required: int: a 5` for `F`, `int: a 5` for `G` -- makes the field initialized: `F\f()` and `G\g()` return 5. The example is written in the forms of the norm of 2026-11-19: the inputs and the field `return` are described by data, the code is a nested Structure ([structural call](#call-receivers)).

Failure of input requiredness is a call-admission refusal; failure of a reached CODE required is a failure at that reached form. It uses ordinary diagnostics and failure handling. The distinction is common to by-name calls, explicit call, the interpreter and prepared native execution; it does not introduce another channel or imply runtime implementation status.


<a id="call-frame-20261115"></a>
### Call frames without write-back — decision of 2026-11-15

The input places of a call are described by the data -- `parent(C)` of the executed Structure `C`; `args` in `call` and the tail of the form `C(args)` supply actual values to them under the [common call contract](#call-receivers). In the decision of 2026-11-15 this is written for `fn`, `sub` and `catch` with one input `data` and for `call(D, C)`; these forms are withdrawn by the norm of 2026-11-19 ([what is withdrawn](#removed-builtins)), the frame rules are kept. Every independent callable invocation creates its own namespace and local places. Executing an accepted declaration form and its associated body uses the established places of that receiving execution under [§11](#declaration-arguments); it does not create a fresh isolated item or rerun an initializer at every body entry. Positional and named actuals map to the input description. A supplied actual replaces the corresponding namespace description and suppresses that original initializer. A declaration-form actual preserves the replacement form itself; executing that accepted form later follows its own reached-execution contract. Call entry does not execute initializers of omitted fields.

Namespace preparation collects declarations at the roots of `data` and `code`, including the fields supplied by explicit `import`, `copy` and `merge` when their contracts require consumption. These receivers always consume standard CODE source arguments; this is separate from eager execution of computed place initializers, which preparation does not perform. There is no general traversal of lexical branches or graph reference edges. Code's own places absent from the input data belong to this call and are not appended to source data. Collecting places does not override sequential visibility of variables and `const`. Nothing is auto-filled in the graph: [autofill](#binding-autofill) fills the own place of the frame and does not write into the graph.

Ready data receives its ordinary initialization during clean-graph construction without program calls: for example, `int: i 5` is present as its named `{int 5}` leaf through the existing mechanism. A computed declaration retains its written code. There is no separate entry phase that executes it: in `mark(); int: y makeValue()`, makeValue() runs when the declaration is reached, after mark(). An unused computed input-data field is not executed. Types without a value (`uninit:T`) remain; an absent initializer is not replaced by a random ordinary T.

Bare `x` and `@x` refer to the logical place selected by [binding](#binding-places). The own place of the current call after entry is independent of later replacement of the source field -- equally for a supplied actual, autofill, and a lexical and a dynamic source of the former binding. The selected value or computed description is held as values or references to the already existing descriptions, without an execution-graph copy or entry-wide RHS execution pass; a reached free-name binding follows the interpreter/native timing stated in [fallback](#binding-fallback). This does not deep-copy all referenced objects: explicitly passed references retain target identity. A local assignment to an own place does not write back. A name bound to the [transparent caller place](#binding-caller-place) denotes that place itself: a write changes it at once, `@x` addresses it. An explicit path from the Structure of the data `D\x` and `code\x` access the source graph; explicit writes are observed through its actual aliases in execution order (the former form of the first path, `data\x`, is withdrawn together with the special name `data`, [what is withdrawn](#removed-builtins)). For `p\x`, the current local value of p selects the referent.

Reading a computed place by a bare name is the work of the call: it executes the declaration's already written expression rather than inventing a nullary call on the resulting reference. The explicit path `D\field` executes nothing and reads the record of the declaration ([explicit path](#path-reads-no-execution)). Given source `@: fptr getFuncPtr()`, `fptr("hello world")` first runs getFuncPtr(), then calls the obtained function. `fptr := 0` changes only the namespace; `D\fptr := 0` changes the source field so that it reads as `@: fptr 0`. Changing that source field before the first bare fptr read does not change the frame description selected at entry.

<a id="path-reads-no-execution"></a>
#### An explicit path executes nothing

Reading a computed declaration by an explicit path executes nothing. This supersedes the earlier path-evaluation rule. An explicit path -- `struct\field` -- reads what is written in the graph and makes no call; the decision also names the path `data\field` -- the special name `data` is withdrawn by the norm of 2026-11-19 ([what is withdrawn](#removed-builtins)), and the path to a field of the data of a call leads from the Structure of the data itself, `D\field`. If the field is declared with a ready value, `int: field 5`, the path gives that value, the number 5 of type `int`. If the declaration is computed, `int: field f()`, the path gives the record of the declaration itself -- the Structure of the receiver with the name and the written call; `f()` is not executed. An expression is no different from a call: for `int: field 5 * 2` the path returns not 10 but the full Structure that begins with `int:` (the author's clarification). Likewise `D\S` for the record `S: merge: A B` in the data `D` executes no `merge` and gives the record.

A computed declaration is executed by a call, and by it alone: a call prepares its namespace from the root declarations of its data and executes the written expression when it refers to its local place by a bare name ([call frame](#call-frame-20261115)). That work of the call stays as it was: there is no general initialization, a call prepares a place on a concrete access (the author's confirmation). It has nothing to do with a read by an explicit path. Therefore `sys\toLmx` prints the records as they are written, and a write by an explicit path changes the graph itself -- with no hidden calls and no cache of results. The print of a graph comes down to the print of Structures and of primitive values already recorded in the arena with their type: by a path the receivers come back as Structures.

<a id="computed-field-address"></a>
Taking the address of a local place also obtains a computed value: for input `int: x next()`, `@x` runs next() and gives the ordinary local int cell's address. `@(D\field)`, where `int: field getValue()` is written in the data `D`, addresses the record of the declaration, not the result of getValue(): an explicit path executes nothing (the author's decision of 2026-11-17, [explicit path](#path-reads-no-execution); it withdraws the former rule of 2026-11-15 under which the result was addressed). A ready place is addressed directly; place lifetime remains ordinary. `@f()` was a research example, not a separate implementation task or a request for a C-like prohibition. The author's clarifications.

Re-declaring a name at the same level introduces no additional C variable but retains the other actions: `int: x bump()` evaluates bump(), performs ordinary admission, and assigns the existing x. A declaration of the same name at a nested level creates its own place and shadows the outer one ([declaration levels](#shadowing-levels); the former wording -- any re-declaration of an already visible name writes into the former cell -- is narrowed by the norm of 2026-11-19 to one level). A new branch name is visible from its declaration at its level and below, not outside. Two declarations in data remain two physical occurrences, `S\[0]x` and `S\[1]x`; `S\x` is ambiguous. Sequential visibility of variables and const removes the old early bare-name access to a future local. Reading a written computed declaration through an explicit path does not execute it; the RHS is executed when its code statement is reached. There are no separate exceptions or hidden computation cache.

Execution of mutable code follows [explicit compilation and the endturn boundary](#explicit-compilation). A mandatory code snapshot at entry is cancelled; selected local namespace values/descriptions remain independent. There is still no initializer-execution phase at entry.

C signatures are derived from actual calls. Different supplied argument sets yield different signatures; the full description of the data does not itself become every C entry's parameter list. The [`fn` signature](#fn-signature) describes a call contract, not an executable implementation. Ordinary Structures and methods share body and frame compilation; the data of a call are the `parent` of the executed Structure ([structural call](#call-receivers)), and the root entry R0 has no data ([R0](#root-entry)).

<a id="binding-executors"></a>
### Binding in the executors

The norm is one for the interpreter and native ([the requirements](tasks/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), §11–§12). A direct native → native call is kept where the selected implementation, types and binding are known. An autofilled value is lowered by the same parameter `T` as an explicit actual argument; the [transparent caller place](#binding-caller-place) -- by the hidden address of its cell; the [former binding](#binding-fallback) still gives an own place. A common C body may be shared between modes through adapters, but an adapter keeps the owner of the record and the behaviour of `@`. With identical explicit actuals the mode of the hidden input may differ because of the caller's context and `private`: a native entry conforms to the real contract or receives a description of the place; new user pointer types are not introduced.

An ordinary native local variable has no arena header "type, value": its type cannot be read from the four bytes before the address. The type, the way of access, the initialization state and the applicable restrictions follow from the common representation of the place and the call contract. There are four combinations of executors -- native → native, native → interpreter, interpreter → native, interpreter → interpreter -- and in all of them `x` has one logical type `T`, and a permitted write changes the same logical place. For a target known only at execution, the existing access to the permitted local contexts applies: the raw C stack does not serve as a dictionary of names, and a static transitive closure of requirements is not introduced. Service C functions, the bridge and the `call` dispatcher do not substitute their own service local variables for the caller's context: the sources are determined by the program place of the call.

Boundaries. Load-dirty, `flush`, publication of local frames and copying back at exit do not return ([withdrawal of publication](#flush-receiver-contract)). A read through the caller's place is not replaced by a snapshot without proof that the observable behaviour under nested calls is preserved. The absence of a suitable native entry does not start hidden compilation ([explicit compilation](#explicit-compilation)); persistent environment caches and automatic graph invalidation are not added; `restrict` is not applied merely because of hidden passing of a pointer or `private`. Binding adds no fields to the source data and code and does not change their structure; the service information of the namespace is neither a second graph nor a persistent store of name resolutions, and native descriptors remain in the `call` tables. A transparent link does not extend the lifetime of the local place; preserving the graph does not make the address of a temporary C variable a portable reference; at `yield` the selected binding is not rebound to the same-named local variable of the new caller of `next`.

<a id="explicit-compilation"></a>
### Explicit compilation, native, and endturn

Compilation of an explicitly selected root includes clean-graph construction and checking without program
calls, the separate required build-test phase on that clean graph, lowering to L1 and C, machine compilation,
and entry registration in `call` tables. The tests use their ordinary receiver and call contracts; the
application entry is not launched merely to compile it.
`sys\compile(S)` invokes this shared chain; `sys\translate(S)` stops at L1 text.
Failure returns diagnostics and provides no new native entry. The runtime operation reuses the
required parts of the same builder chain, without a second compiler.

Native is an explicit descriptor: an ordinary Structure containing machine-entry variants and signatures, binary-module/entry references, and available L1/C source paths. Its primary storage is the arena's call tables shared by methods and ordinary executable Structures. `sys\native(S)` queries those tables without running S. The Lmx header has parent/length/storage and no native field.

The source graph is not supplemented with synthetic native fields as a side effect of translation or fn-description creation. Any explicitly present ordinary field named native remains ordinary graph material; it is not a header pseudo-field. Source forms remain as written, and service/native descriptors stay in the established tables. Dynamic calls select suitable variants for the actual target and call; otherwise an admissible body uses the walker. Compilation and registration are explicit, not hidden consequences of call entry, copying or graph edits.

A known native-to-native call lowers directly to the selected C function: ordinary parameters and necessary
hidden binding arguments, without graph traversal, call-table lookup, universal actual packaging, or a graph
frame just to arrange the call. Explicit program accesses to the data and code of the call by paths remain. This is the primary generation
route, not a deferred optimization.

A write immediately changes the addressed graph and is not tracked for native. It neither clears entries
nor starts checking or compilation, and maintains no reverse machine-code dependencies. Remove those
traversals, tables, transfers, and generator branches together with the checks. Ordinary memory/reference
duties remain; they are not native-freshness tracking. Without explicit compilation a graph edit promises
neither updated machine code nor automatic program repair.

Before the turn ends, the time an edit affects execution is unspecified: the walker may see it before native.
Copying code to equalize this timing is unnecessary, including the former per-C-function code snapshot.
Selected own namespace places remain independent of source data; bindings are passed as hidden arguments -- a value for an own place, the address of a cell
for the [caller's place](#binding-executors) -- and the lexical environment is not copied.
After successful explicit compilation and endturn, the next entry uses the
prepared update. Endturn alone neither detects edits nor checks or compiles the graph.

The scheme (the author's decision of 2026-11-18).
The translator constructs the full clean graph and emits C for the compiled methods; it does not
emit a second data graph as static C state. There is no working graph. The binary includes R0 and
the interpreter methods; R0 holds its graph pointer locally. The interpreter starts only on the clean graph and executes the build's required receivers `test` under the
ordinary build/receiver contracts before the final C compilation. This is not recursive discovery of
every `test` form in DATA, and nested calls keep ordinary native/walker dispatch. At run time the
scheme is the same: the interpreter works on the clean graph, and changes of the
graph do not affect that; the next cycle of generating C and compiling is performed only by the
mechanism described here -- explicit compilation and the endturn boundary. Scripts attached later are
interpreted by the built kernel by the same scheme: C is generated, and the full compilation is
performed only at the request of user code; a script arrives as an ordinary Message.

A direct C call A→B belongs to compiled A. Recompiling only B does not rewrite old A: updating that chain
requires explicitly compiling a common unit containing the needed callers and targets. This is compilation
work, without observing assignments or looking up native before each direct call. Old active machine frames,
including finally, must finish before their machine code is released.


<a id="direct-access-cache"></a>
### Direct access without a separate language cache

The proposed direct-access cache shared across calls is cancelled together with load-dirty. Aliases of the same runtime local place observe its sequential writes. Paths that select the same structural graph cell observe the fragment currently held by that cell, including an explicit replacement. Two different graph cells that previously held references to one primitive fragment do not become one writable place merely because those references matched; replacing one cell does not promise to retarget the other. A local variable remains an own place of the current frame, separate from the source record of the graph; a name bound as the caller's place denotes the caller's place ([own place and caller's place](#binding-places)). Ordinary compiler optimizations preserve these rules without new coherence tables or mandatory checkpoints.

<a id="flush-receiver-contract"></a>
### Removal of local-frame publication and flush()

Neither the `data` nor the `code` frame is published into the graph. Remove load-dirty, write-back at calls and exits, the shared direct-access cache, and the proposed `flush()` receiver. Earlier examples of an outer published `x = 2` and an inner published `x = 9` describe the superseded model. These are now independent local places; only explicit operations change the original graph. A write through the [transparent caller place](#binding-caller-place) is not publication: it changes the caller's local place at once, and there is no copying at exit. Message publication and exposing a construction result are different operations and are not cancelled.

<a id="activation-history"></a>
### Activations and agreed boundaries

The call stack remains the sole implicit activation history: the ordinary C stack for native and the corresponding control stack for the interpreter. Recursive and nested calls have different own local cells, including different `@x` addresses. Return, `throw`, `finally`, `retry`, and `yield` introduce no write-back of these cells. A name bound to the [transparent caller place](#binding-caller-place) gets no own cell: it denotes the caller's place, a write changes it at once, and `@x` addresses it. Explicitly passed references preserve their targets' identity.

The established activation boundaries are: no entry-wide initializer pass; sequential variables/const; reached computation and demand through the logical namespace; explicit paths that do not execute source records; and explicit compilation plus endturn for guaranteed native updates. Own places remain independent of source records, while transparent caller bindings denote their real source cells. The old load-dirty, flush and executable fn/sub models are withdrawn. Catch follows its preserved [handler contract](#catch-common-model). These are semantic requirements, not implementation or test results.
@@ branches | Ветвления и циклы | Branches and loops | 10; 19.1–19.9; 19.14; 19.16
[RU]
Управляющие принимающие выражения определяют способ потребления своих структурных тел. Принадлежность к телу не означает обязательное немедленное выполнение всех его полей. Метки управления обозначают видимые цели перехода; упоминание метки само по себе не вызывает тело и не является неявным `goto`. Глава описывает действие ресиверов управления в роли кода. В данных запись ресивера управления — `if`, `for` и других — Structure, названная своей головой: она не исполняется, и до неё доходят путём по её голове от Structure данных `D` — `D\if`, до вложенной — `D\if\if`, при нескольких одноимённых — с индексом вхождения ([роли `data` и `code`](#data-code-roles)).

`if` вычисляет условие один раз и исполняет тело при истинном результате. Непосредственно следующий `else` на том же уровне исполняется только при ложном результате. Вставка другого оператора между ними нарушает пару. Профильный `branch` с именованными ветвями может существовать отдельно и не заменяет этот контракт.

`match` выбирает подходящую ветвь по выраженным шаблонам. Ветви могут задаваться парами «шаблон — тело» или явными структурами согласно профилю; `default` является определённым профилем шаблоном, а не универсальным эффектом произвольного имени. Объединение шаблонов и требование исчерпывающего покрытия задаются контрактом. Автоматического проваливания в следующую ветвь нет, если оно явно не определено.

`while` проверяет условие перед каждой итерацией и может ни разу не выполнить тело. Закрывающий `until` задаёт проверку после тела: тело выполняется хотя бы один раз, затем повторяется, пока условие ложно. Анонимное тело с `until` — такой цикл в текущей активации, как всякое управляющее тело; именованная Structure, закрытая `until`, — обычная именованная Structure, чьё исполняемое тело — этот цикл: объявляет её запись данных, и объявление цикл не исполняет — его исполняет вызов (ресивером `call` либо записью по её имени в коде: `S()`, `S(args)`; см. [структурный вызов](#call-receivers)); в коде та же запись — вызов своей головы, а не объявление: поля после головы — фактические аргументы, и ошибочна она, когда голова не называет ни вызываемого, ни Structure, либо когда эти поля не принимаются общим [выбором объявления](#declaration-selection) ([роли `data` и `code`](#data-code-roles)). Основной `for` содержит инициализацию, условие, шаг и тело; инициализация выполняется один раз, затем проверка, тело и шаг. Сокращения диапазонов требуют отдельного явно выбранного профиля и не изменяют эту основную форму.

`each` потребляет элементы контейнера либо явно выбранного итератора. Итератор выдаёт элемент посредством `yield`, а завершение обозначает объявленным `throw: Stop`; `None` может быть обычным элементом и не заменяет сигнал конца. Другие исключения распространяются по своим объявлениям. Ссылка `words` на источник и вызов `words()` различаются: второй явно вызывает выражение без аргументов.

| Переход | while | until | for | each |
| --- | --- | --- | --- | --- |
| `continue` | Проверить условие | Проверить постусловие | Выполнить шаг | Получить следующий элемент |
| `redo` | Повторить тело без проверки | Повторить тело без проверки | Повторить тело без шага | Повторить с тем же элементом, без `next` |
| `break` | Выйти из цикла | Выйти из цикла | Выйти из цикла | Выйти из цикла |

Без метки переход относится к ближайшему подходящему активному циклу. Именованный переход требует видимой метки; `continue` к нециклической цели ошибочен. `redo` допустим только в цикле и может не обеспечивать продвижения. Все покидаемые области выполняют свои зарегистрированные очистки. Полный набор видов областей, к которым может присоединяться метка, требует отдельного грамматического определения.
[EN]
Control receivers determine how their structural bodies are consumed. Membership in a body does not require immediate execution of all its fields. Control labels denote visible transfer targets; mentioning a label neither invokes its body nor constitutes an implicit `goto`. The chapter describes how control receivers act in the role of code. In data a form of a control receiver -- `if`, `for` and the others -- is a Structure named by its head: it is not executed, and it is reached by a path through its head from the data Structure `D` -- `D\if`, a nested one by `D\if\if`, with the index of an occurrence when several bear one name ([the roles `data` and `code`](#data-code-roles)).

`if` evaluates its condition once and executes its body when true. An immediately following sibling `else` executes only when false. Another statement between them breaks the pair. A profile-specific `branch` with named branches may exist separately and does not replace this contract.

`match` selects a suitable branch using expressed patterns. Branches can be pattern/body pairs or explicit Structures according to the profile; `default` is a profile-defined pattern, not a universal effect of an arbitrary name. Pattern union and exhaustive-coverage requirements belong to the contract. There is no automatic fallthrough unless explicitly defined.

`while` checks its condition before each iteration and can execute its body zero times. Closing `until` establishes a postcondition: the body executes at least once and repeats while the condition is false. An anonymous body closed by `until` is such a loop in the current activation, as any control body; a named Structure closed by `until` is an ordinary named Structure whose executable body is that loop: a form of data declares it, and declaring it does not run the loop -- a call does (by the receiver `call` or by a form calling it by name in code: `S()`, `S(args)`; see [structural call](#call-receivers)); in code the same form is a call of its head, not a declaration: the fields after the head are actual arguments, and it is an error when the head names neither a callable nor a Structure, or when these fields are not accepted by the general [choice of the declaration](#declaration-selection) ([the roles `data` and `code`](#data-code-roles)). Core `for` contains initialization, condition, step and body; initialization runs once, followed by condition, body and step. Range shorthands require a separately selected profile and do not alter this core form.

`each` consumes a container's elements or an explicitly selected iterator. The iterator produces an element through `yield` and indicates completion by declared `throw: Stop`; `None` can be an ordinary element and does not replace end-of-stream. Other exceptions propagate under their declarations. A source reference `words` differs from `words()`: the latter explicitly invokes the expression with no arguments.

| Transfer | while | until | for | each |
| --- | --- | --- | --- | --- |
| `continue` | Check condition | Check postcondition | Perform step | Obtain next element |
| `redo` | Repeat body without check | Repeat body without check | Repeat body without step | Repeat with same element, without `next` |
| `break` | Exit loop | Exit loop | Exit loop | Exit loop |

An unlabelled transfer targets the nearest suitable active loop. A labelled transfer requires a visible label; `continue` to a non-loop target is erroneous. `redo` is valid only within a loop and may fail to make progress. Every abandoned scope performs its registered cleanups. The complete set of scope kinds that can carry a label requires a separate grammar definition.
@@ exits | Выходы и finally | Exits and finally | 8.8; 19.7; 19.10; 19.11.2; 19.13
[RU]
`finally` регистрирует очистку в текущей области и не исполняет её в момент регистрации. При выходе из области зарегистрированные очистки выполняются в обратном порядке. Правило действует при обычном завершении, `return`, `throw`, переходах из области цикла, `redo`, `retry`, диагностическом прекращении и других прекращениях профиля. Это не конструкция `try` и не обработчик только исключений.

Для выхода, уничтожающего активацию: однократно вычислить и удержать результат или полезную нагрузку, выполнить применимые очистки, передать результат либо управление и завершить активацию. Локальные значения не публикуются ни до, ни после очистки.

Входы и остальные локальные значения не записываются обратно; локалы вызывающей активации не перечитываются. Явные записи очистки меняют адресованный граф. Каждая активация, пересекаемая выходом, выполняет свои очистки. Возврат сохраняет идентичность ссылки результата и сам не запускает сборку конца такта актора.

Выход внутри исполняющейся очистки не запускает её повторно. Оставшиеся внешние очистки сохраняют свои обязательства; вложенные вызовы получают обычные кадры без публикации. Остановка или отмена не отменяет эти правила.

<a id="endturn-receiver"></a>
`sys\endturn()` — системный выход к штатной границе текущего такта. Он проходит все вложенные
вызовы и выполняет зарегистрированные finally покидаемых областей в обычном обратном порядке.
Обычный catch его не перехватывает; он не возвращается к месту вызова и не сохраняет продолжение стека.
После очисток выполняется штатное завершение такта. Сам ресивер не меняет running/success и не
объявляет Message завершённым; следующий такт, если он предусмотрен, начинается обычным входом.
Это общий механизм выходов, не отдельный обход стека или прыжок мимо finally.
Он не является flush, не публикует локалы, не обнаруживает правки и не запускает компиляцию.
После успешной явной компиляции и этой границы следующий вход использует подготовленное обновление;
без компиляции один endturn не обещает актуализации native. [Полный контракт](#explicit-compilation).
[EN]
`finally` registers cleanup in the current scope without executing it at registration. Registered cleanups run in reverse order when that scope is exited. This applies to normal completion, `return`, `throw`, transfers out of a loop scope, `redo`, `retry`, diagnostic termination and other profile exits. It is neither a `try` construct nor an exception-only handler.

An exit that destroys an activation evaluates and retains its result or payload once, performs applicable cleanups, transfers the result or control, and finishes the activation. Local values are published neither before nor after cleanup.

Inputs and other locals are not written back, and the caller's locals are not reloaded. Explicit cleanup writes affect the addressed graph. Every activation crossed by an exit performs its cleanups. Return preserves the result reference's identity and does not itself trigger actor end-of-turn collection.

An exit inside a running cleanup does not re-enter it. Remaining outer cleanups retain their obligations; nested calls use ordinary frames without publication. Stopping or cancellation does not bypass these rules.

<a id="endturn-receiver"></a>
`sys\endturn()` is a system exit to the current turn's ordinary boundary. It propagates through nested
calls and runs registered finally cleanups of exited scopes in the usual reverse order.
An ordinary catch does not intercept it; it neither returns to its call site nor retains a stack continuation.
Ordinary end-of-turn processing follows cleanup. The receiver itself changes neither running nor success
and does not declare the Message completed; a subsequent turn, if scheduled, starts at the ordinary entry.
Use the common exit mechanism, not a separate stack walk or a jump bypassing finally.
It is not flush, publishes no locals, detects no edits, and starts no compilation.
After successful explicit compilation and this boundary, the next entry uses the prepared update;
without compilation, endturn alone promises no native refresh. [Full contract](#explicit-compilation).
@@ exceptions | Объявленные отказы и диагностика | Declared failures and diagnostics | 2.5.6; 19.11–19.13.1
[RU]
`throws` перечисляет имена возможных восстанавливаемых выходов выражения, а не типы исключений. Вызывающее выражение должно предоставить `catch` для каждого такого имени либо объявить его в собственном `throws`. Вызов без одного из этих способов обработки отвергается. Условие обнаружения отказа задаётся обычным `if`; модульный `guard` не является оператором обработки отказов.

`throw: Name(arguments)` вычисляет явную полезную нагрузку и покидает текущую активацию по правилам [выходов](#exits), не возвращая объявленный результат. Параметры выбранного `catch: Name (...)` принимают нагрузку. Повторный вызов из обработчика начинает новую активацию сначала и не возобновляет брошенный кадр.

`catch` — точка приёма в блоке вызывающего выражения, не обычная вложенная вызываемая Structure ([`catch` в общей модели](#catch-common-model)). При первом прямом проходе её тело пропускается. После доставки соответствующего отказа тело выполняется, затем исполнение продолжается с операторов после этого `catch`. Поэтому обработчик, поставленный до вызова, повторно вводит выполнение в последующий участок; обработчик после вызова продолжает за собой. Участок ограничен следующим `catch` того же блока или концом блока. Обработчик действует на все вызовы своего блока, включая вызовы из вложенных в него операторных блоков (`if`, `while`, `for`, анонимный `---`): обработчик, как именованные Structure и вызываемые, виден во всём своём блоке в обе стороны. Блок-сосед им не покрывается. Это двусторонняя видимость имени callable, а не всех мест данных. Переменные, включая `const` и переменные с указателем на метод, видны последовательно; имена именованных Structure и callable — в обе стороны по [общему правилу видимости](#declaration-visibility).

Два одноимённых обработчика в одном блоке запрещены; отдельные вложенные блоки могут иметь каждый свой. Доставка выбирает обработчик по блоку вызова, не одноимённый обработчик соседнего блока. Повторный `throw` того же имени внутри обработчика не входит в этот обработчик заново: это отказ во внешнем вызывающем контексте. Необработанное имя распространяется только через соответствующие объявления `throws`.

Операторы языка, у которых программист не видит явного перечисления `throws` (например, `merge`), тоже бросают именованный отказ, но отлавливать его не обязательно: обработчик `catch: merge` — до вызова, после него или в отдельном вложенном блоке — обрабатывает его стандартно, и никуда он не улетает; неотловленный неявный отказ улетает в корень исполняющегося Message, и поток останавливается (`running = 0`). Единственное ограничение размещения — то же, что и для объявленных имён: два одноимённых `catch` не могут спорить на одном уровне.

Если интерпретатор при исполнении корректно построенного графа обнаруживает ошибку самой выполняемой операции, он создаёт обычный неявный отказ с единым именем `interpreter`. Его принимает `catch: interpreter ()` по тем же правилам области действия и распространения, что и другие неявные отказы; отдельного канала исключений интерпретатора нет. Ошибка построения исходного графа при трансляции, повреждённая форма графа и нарушение инварианта ядра не являются таким отказом: это диагностика соответствующей стадии, которую `catch` исполняемой программы не перехватывает.

<a id="catch-common-model"></a>
### `catch` в общей модели данных и вызова

Норма 2026-11-19 ([ТЗ](tasks/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), R17). Обработчик `catch` описывается общей моделью входов и фактической связью: код обработчика читается в роли кода, а роль данных у него исполняет его `parent`, как у всякого исполняемого кода ([структурный вызов](#call-receivers)). Полезная нагрузка `throw: Name(arguments)` — явно поданные значения; параметры обработчика принимают их по общим правилам фактических аргументов. На остальные зависимости обработчика — имена, которые он использует, но не получает нагрузкой, — действуют обычное [связывание](#binding-places) и [двусторонний `private`](#private-binding).

Семантика обработчика при этом сохранена целиком: обработчик выбирается по имени отказа и своей области; его тело не исполняется при первом прямом проходе; вложенные и соседние области различаются; двух спорящих одноимённых `catch` на одном уровне нет; продолжение после обработчика, повторный вызов, `throws` и очистка действуют так, как описано в этой главе. `catch` не исчезает вместе со снятым `sub` и не превращается в обычную функцию от того, что представление входов стало единым. От снятых форм — исполняемых `fn` и `sub`, `fncall` и отдельной подстановки данных ([что снято](#removed-builtins)) — обработчик не зависит. Роли его частей следуют контракту обработчика: то, что `fn` вошёл в группу ресиверов [роли данных](#whole-arguments), само `catch` не переопределяет. Запись заголовка `catch: Name (параметры)` этой нормой не менялась.

Следующий пример изолирует размещение catch. Каждый анонимный блок имеет собственный обработчик RetryGreeting перед своим вызовом, а внешний блок run имеет обработчик SkipGreeting после блоков. Два обработчика RetryGreeting находятся в разных областях и не конкурируют.

```lmx
Greeting:
    int: value
    return: int
    checkedGreeting:
        throws:
            RetryGreeting
            SkipGreeting
        if: value = 0
            throw: RetryGreeting()
        if: value < 0
            throw: SkipGreeting(value)
        return: value

Hello:
    run:
        int: first 0
        int: second 0
        ---
            catch: RetryGreeting ()
                first := 1
            Greeting\checkedGreeting(first)
        ---
            catch: RetryGreeting ()
                second := 2
            Greeting\checkedGreeting(second)
        ---
        catch: SkipGreeting (int: badValue)
            int: observed badValue
```

Каждый вызов с нулевым значением выбрасывает RetryGreeting без полезной нагрузки. Его локальный обработчик изменяет соответствующую переменную в namespace вызова и продолжает выполнение со следующего вызова, который начинает новую активацию с новым фактическим аргументом. Отрицательное значение выбросило бы SkipGreeting с полезной нагрузкой int, которая допускается в badValue обычным контрактом входа обработчика; затем управление продолжается после этого внешнего обработчика. Тела обработчиков на первом проходе пропускаются. Пустая строка внутри предназначенного вертикального блока не появляется: пустая строка между Greeting и Hello — намеренная граница полного корня.

`sys\assert` проверяет диагностический инвариант. Ложное условие порождает `AssertionViolation`, а не восстанавливаемый `throw`; его нельзя поймать обычным `catch`, и оно не входит в `throws`. В акторном профиле диагностическое прекращение выполняет правила выхода и очистки активации из [выходов](#exits) до передачи диагностики корню исполняющегося Message. Message прекращает исполнение и больше не получает тактов. Это не делает неуспешный такт успешным и не разрешает публикацию его ожидающих исходящих писем: они по-прежнему подчиняются [доставке](#delivery). Это не обязательное завершение рабочего потока ОС; остановка исполнения и уничтожение объекта различаются.

Ожидаемые ошибки входных данных обрабатываются явным условием и объявленным отказом, а не диагностической аварией. `log` и `error` записывают наблюдения через выбранный профиль. Само `error` не означает `throw`, `sys\assert`, возврат или остановку. Нелитеральный аргумент разрешается как обычное значение; неизвестное имя не превращается автоматически в строку журнала.
[EN]
`throws` lists names of an expression's possible recoverable exits, not exception types. The caller must provide a `catch` for each name or include it in its own `throws`. A call without either treatment is rejected. Failure detection uses ordinary `if`; module `guard` is not a failure-handling operator.

`throw: Name(arguments)` evaluates an explicit payload and leaves the current activation under the [exit rules](#exits), without returning its declared result. The selected `catch: Name (...)` parameters receive the payload. A handler's repeat call begins a new activation from the start and does not resume the abandoned frame.

`catch` is a landing pad in the caller's block, not an ordinary nested callable Structure ([`catch` in the common model](#catch-common-model)). Its body is skipped on the initial straight-line pass. When the corresponding failure arrives, its body runs and execution continues with the statements after that `catch`. Consequently, a handler before a call re-enters the following region; a handler after the call continues past itself. The region ends at the next `catch` in the same block or the block's end. The handler covers every call of its block, including calls made from statement blocks nested inside it (`if`, `while`, `for`, an anonymous `---`): a handler, like named Structures and callables, is visible throughout its block in both directions. A sibling block is not covered. This is bidirectional visibility of a callable name, not of all data places. Variables, including `const` and variables holding method pointers, are visible sequentially; names of named Structures and callables are visible in both directions under the [common visibility rule](#declaration-visibility).

Two same-named handlers in one block are prohibited; separate nested blocks can each have one. Delivery selects the handler by the calling block, not a same-named handler in a sibling block. Throwing the same name inside a handler does not re-enter it: this is a failure in the enclosing calling context. An unhandled name propagates only through matching `throws` declarations.

Language operators whose `throws` list the programmer does not see written out (for example `merge`) also throw a named failure, but catching it is optional: a `catch: merge` handler -- before the call, after it, or in a separate nested block -- handles it in the ordinary way and nothing flies anywhere; an uncaught implicit failure flies to the root of the executing Message and the Thread stops (`running = 0`). The only placement constraint is the one declared names have: two same-named `catch` handlers cannot compete at one level.

If the interpreter detects an error in an operation while executing a correctly constructed graph, it raises an ordinary implicit failure with the single name `interpreter`. `catch: interpreter ()` receives it under the same scope and propagation rules as other implicit failures; there is no separate interpreter-exception channel. An error while constructing the source graph during translation, a malformed graph, or a violated kernel invariant is not such a failure: it is a diagnostic of the corresponding stage, which the executing program's `catch` cannot intercept.

<a id="catch-common-model"></a>
### `catch` in the common model of data and call

The norm of 2026-11-19 ([the requirements](tasks/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), R17). The handler `catch` is described by the common model of inputs and the actual link: the code of the handler is read in the role of code, and its role of data is played by its `parent`, as for any executable code ([structural call](#call-receivers)). The payload `throw: Name(arguments)` is the explicitly supplied values; the handler's parameters accept them under the general rules of actual arguments. The other dependencies of the handler -- the names it uses but does not receive as payload -- are subject to the ordinary [binding](#binding-places) and [two-way `private`](#private-binding).

The semantics of the handler is preserved in full: the handler is selected by the failure name and by its scope; its body is not executed on the initial straight-line pass; nested and sibling scopes are distinguished; there are no two competing same-named `catch` at one level; continuation after the handler, the repeat call, `throws` and cleanup act as described in this chapter. `catch` does not vanish together with the withdrawn `sub` and does not turn into an ordinary function because the representation of inputs has become unified. The handler does not depend on the withdrawn forms -- the executable `fn` and `sub`, `fncall` and the separate substitution of data ([what is withdrawn](#removed-builtins)). The roles of its parts follow the handler's contract: that `fn` has entered the group of receivers with [the data role](#whole-arguments) does not itself redefine `catch`. The notation of the header `catch: Name (parameters)` is not changed by this norm.

The following example isolates catch placement. Each anonymous block has its own RetryGreeting handler before its call, and the outer run block has a SkipGreeting handler after the blocks. The two RetryGreeting handlers are in different scopes and do not compete.

```lmx
Greeting:
    int: value
    return: int
    checkedGreeting:
        throws:
            RetryGreeting
            SkipGreeting
        if: value = 0
            throw: RetryGreeting()
        if: value < 0
            throw: SkipGreeting(value)
        return: value

Hello:
    run:
        int: first 0
        int: second 0
        ---
            catch: RetryGreeting ()
                first := 1
            Greeting\checkedGreeting(first)
        ---
            catch: RetryGreeting ()
                second := 2
            Greeting\checkedGreeting(second)
        ---
        catch: SkipGreeting (int: badValue)
            int: observed badValue
```

Each zero-valued call throws RetryGreeting with no payload. Its local handler changes the corresponding call-namespace variable and continues to the following call, which begins a new activation with the new actual. A negative value would throw SkipGreeting with an int payload, admitted to badValue by the ordinary handler input contract; control then continues after that outer handler. Handler bodies are skipped on the initial pass. No blank line appears inside an intended vertical block: the one between Greeting and Hello is an intentional full root boundary.

`sys\assert` checks a diagnostic invariant. A false condition produces `AssertionViolation`, not a recoverable `throw`; ordinary `catch` cannot handle it and it is not part of `throws`. In the actor profile, diagnostic termination follows the activation's exit and cleanup rules in [exits](#exits) before the diagnostic is delivered to the executing Message's diagnostic root. That Message stops executing and receives no further turns. This does not make the failed turn successful or authorize publication of its pending outgoing Messages; those remain governed by [delivery](#delivery). This need not terminate the OS worker; stopping execution and destroying the object remain distinct.

Expected input errors use an explicit condition and declared failure rather than a diagnostic abort. `log` and `error` record observations through the selected profile. `error` alone does not imply `throw`, `sys\assert`, return or termination. A non-literal argument resolves as an ordinary value; an unknown name does not automatically become a log string.
@@ suspension | Повторный запуск и приостановка | Restart and suspension | 7.3; 19.12; 19.15; 21.10
[RU]
`retryable` задаёт повторяемую область. `retry` без имени повторяет ближайшую активную такую область; `retry: label` — указанную. Перед повтором выполняются очистки покидаемой попытки. Переход не откатывает внешние эффекты, изменения графа или опубликованные сообщения. Транзакционный откат возможен только как отдельно выраженный протокол над данными.

Сам `retry` — локальный переход текущей активации, не новый вызов и не восстановление скрытого окружения. Текущие рабочие значения продолжают существовать, дополнительной публикации только из-за перехода нет. Если повтор достигает вызова или выхода, действует соответствующая обычная граница. Нагрузка пойманного отказа остаётся явными аргументами обработчика.

`yield` передаёт произведённое значение и приостанавливает активацию. Её локальные входы, namespace и рабочие значения сохраняются для возобновления; в граф они не публикуются и при возобновлении из исходной Structure не перечитываются.

Входы производителя фиксируются при начале его активации. Следующий вызывающий `next` не заменяет их своим динамическим окружением. Если `next` реализован отдельным выражением-обёрткой, его входы относятся к его активации, пока явная операция не изменит сохранённое состояние производителя. Представление продолжения и результата итератора не наблюдаемо, если сохраняется описанная семантика.
[EN]
`retryable` defines a restartable region. Unlabelled `retry` repeats the nearest active such region; `retry: label` repeats the named one. Abandoned-attempt cleanups run before restarting. The transfer does not roll back external effects, graph mutations or published Messages. Transactional rollback requires an explicitly represented data protocol.

`retry` itself is a local transfer in the current activation, not a new call or restoration of a hidden environment. Current working values continue to exist, with no additional publication merely because of the transfer. If repeated execution reaches a call or exit, that boundary's ordinary rules apply. A caught failure's payload remains the handler's explicit arguments.

`yield` transfers a produced value and suspends the activation. Its local inputs, namespace, and working values remain for resumption; they are not published into the graph or reloaded from the source Structure on resumption.

Producer inputs are fixed when its activation begins. A later `next` caller does not replace them with its own dynamic context. If `next` is a separate wrapper expression, its inputs belong to its activation unless an explicit operation changes the producer's saved state. The continuation and iterator-result representation is not observable when it preserves these semantics.
@@ arrays | Массивы и хранилище | Arrays and backing | 6.1–6.5.5; 12–13; 19.29.3
[RU]
Обычная Structure и Array ссылок `Array<@>` полностью взаимозаменяемы: индексирование, именованные пути при наличии имён, `length`, допуск, копирование, исполнение, `sys\typeof` и `sys\descriptor` используют общий контракт. Категория ARRAY/STRUCT сама по себе не основание для отказа. `length` читает поле `length` заголовка; `parent/length/storage` не входят в число элементов. Числовой `Array<T>` хранит непосредственно T. Structure, Array и служебные списки используют общий механизм изменения длины и вместимости. Конечная мерность прямоугольного массива не имеет фиксированного предела и не зависит от глубины указателя. [Раскладка](L2_spec_ru.md#lmx).

Обычный Array — типизированная Structure графа с устойчивой ссылочной идентичностью. Конструктор `[]` создаёт её при достижении места построения. В `[]: arr (... )` место `arr` принадлежит текущей Structure, Array имеет структурным родителем вхождение `arr`, а созданные из аргументов структурные элементы имеют родителем Array. Скобки вокруг аргументов лишней анонимной обёртки в Array не создают: P0 их не раскрывает, но записанную в них Structure ресивер `[]` читает по своему контракту — как список аргументов ([общее правило](#values)). В данных `MyLmxStructFromArray: arr` объявляет Structure `MyLmxStructFromArray` с одним атомом `arr`; этот атом — указатель на **этот же Array**, неизменяемая по имени ссылка: в дереве под `MyLmxStructFromArray` стоит только атом, Array не восстанавливается и не копируется, и его `parent` не меняется ([объявление Structure](#colon-declares)); указатель-переменную на тот же Array объявляет `@: p arr`, а в коде запись `MyLmxStructFromArray: arr` — вызов своей головы. Поле структуры, хранящее ссылку на Array, не является самим Array. Передача ссылки не копирует элементы; изменение элемента наблюдаемо через другие ссылки, перепривязка локальной ссылки — нет.

Владеющий массив имеет единый непрерывный прямоугольный блок элементов. Вложенные размерности не означают отдельно выделенные строки. Для формы `[d0, …, dN−1]` число элементов равно произведению размерностей, последний индекс меняется быстрее остальных. Массив ссылок на другие массивы — другое значение, не замена прямоугольного многомерного массива. Структурный элемент вложен в Array; примитивный элемент находится в его хранилище, но не приобретает отдельного поля `parent`.

У графового Array общая основа Lmx с полями parent/length/storage и устойчивым адресом дескриптора; типизированное storage не является отдельным графовым Array. Structure и Array имеют переменную длину и вместимость. Прежнее разделение фиксированного Array и отдельно растущего List отменено: один механизм обслуживает обе операции и все типы элементов. Native находится в таблицах call, а не в заголовке.

<a id="array-capacity"></a>
В арене хранится таблица «адрес структуры-дескриптора → capacity», где capacity измеряется в элементах.
Она обслуживает общий механизм выделения и изменения размера, но не участвует в обычном индексировании.
`sys\resize(S, n)` меняет length и при необходимости обеспечивает storage; `sys\reserve(S, n)`
обеспечивает вместимость, не меняя length; `sys\capacity(S)` читает таблицу.
Storage может перемещаться, сам дескриптор массива сохраняет адрес. Общая реализация применяется
также к служебным массивам; не добавлять capacity в Lmx, скрытый префикс или отдельную семью DynamicArray.
Существующие обязанности типизированного выделения и освобождения решаются в том же механизме.

<a id="l3-array-reference"></a>
L3-указатель на элемент массива имеет отличный от сырого L2-указателя тип и хранит ссылку на сам
дескриптор массива и явный index. Он не хранит адрес storage и не требует исправления при его переносе.
При доступе используются текущие length/storage дескриптора и один итоговый линейный индекс.
Промежуточные `[i][j]` не создают новых дескрипторов. L3-указатель на примитив также имеет собственный
тип; использовать общий задел типизированных ссылок и uninit:T, не смешивая тип ссылки с отсутствием
значения. Глубина указателей остаётся произвольной конечной. L2 сохраняет сырые машинные адреса,
без автоматического переноса ранее полученного адреса вслед за storage.


`length(array)` читает число элементов Array; для прямоугольного массива это общее число, не первая размерность. Физическое хранилище не обязано сохранять размерности и не позволяет восстановить их из общего числа элементов. Число полей содержащей Structure, длина Array и размер служебного пула различаются.

<a id="structure-index"></a>
Structure и `Array<@>` адресуются одинаково. `S[i]` читает `void*` из физического массива `storage`, `S[i] := p` записывает туда другой `void*`. Никакого требования бывшего поля, его имени или вида ячейки эта операция не проверяет и не переносит: это просто запись значения в массив без проверок (уточнение автора 2026-11-17). Число и адреса элементов от записи не меняются. Имя и тип определяются при последующей интерпретации текущего содержимого; сама запись не присваивает элементу имя. `S\[N]field` и `voidarray\[N]field` — структурный выбор N-го вхождения имени с контрактом именованного поля. Обычный типизированный `Array<T>` сохраняет представление своих элементов. `length(S)` читает число элементов. Индексная запись не требует таблицы требований прежнего элемента и связанного с ней механизма публикации/проверки.

<a id="get-type"></a>
`sys\typeof(arg)` возвращает код типа выбранной типизированной записи; запись `uninit:T` поставляет свой код без чтения какого-либо значения. После замены фрагмента графа свежий поиск через структурное место выбирает запись замены, без обещания насчёт старого сырого адреса: `sys\typeof(S[i])` определяет выбранное значение поля, `sys\typeof(@i)` — адресованную ячейку i, а `sys\typeof(S)` — дескриптор Structure. Она принимает адрес или ссылку, а не произвольный скаляр, притворяющийся одним из них. Ноль или адрес вне арены Message даёт код отсутствия типа по контракту этого ресивера. Коды берутся из именованных констант типов региона ядра; числовые значения кодов этой спецификацией не фиксируются. Интерпретатор и нативное исполнение используют один и тот же контракт результата. Обычные нативные локальные переменные не имеют префикса арены: их логические метаданные места и типа нельзя получить слепым чтением перед адресом C ([исполнители связывания](#binding-executors)).

Встроенные машинные типы элементов сохраняют [смысл типов целевого профиля C99](L2_spec_ru.md#lowlevel-scope), включая знаковость обычного `char`; дескриптор не переопределяет их. L3 добавляет проверяемый доступ, а не другое представление примитивов.

Полный индекс N-мерного прямоугольного массива содержит N целочисленных координат. Для прямоугольного массива координаты сводятся к одному линейному индексу элемента, последний индекс меняется быстрее: `k = (...((i0 * d1 + i1) * d2 + i2)...)`. L3 проверяет только итоговый элемент относительно общей длины в дескрипторе: `0 <= k < length(array)`. Каждая координата отдельно с размерностью не сверяется, вектор длин размерностей ради этих проверок не хранится. Например, в прямоугольнике `[2,3]` координаты `[0,3]` дают линейный индекс 3 и выбирают тот же элемент, что `[1,0]`; линейный индекс 6 вызывает неявный `throw: interpreter`, а не возвращает `None`. Вычисление индекса не должно превращать математически выходящий за границы результат в допустимый элемент через машинное переполнение. Массив ссылок на массивы отличается: каждый шаг обращается к другому действительному Array со своим дескриптором.

Соседние индексы `matrix[i][j]` адресуют один ровный массив по известным из описания ша́гам, а `a[i]\[j]` адресует ссылочное значение, полученное предыдущим выбором, через разделитель пути ([пути](#fields)). Дескриптор не восстанавливает размерности и неполная запись индексов сама по себе не создаёт отдельный Array строки или скрытый view-дескриптор. Эти проверки доступа делает L3, как нативный, так и интерпретируемый, и интерпретатор, когда исполняет код L2; нативный [доступ L2](L2_spec_ru.md#lowlevel-address), включая получение адреса элемента графового массива, работает без них (решение автора 2026-11-18). Проверки операции не являются отдельным механизмом допуска кандидата вместо [анализа и юнит-тестов](#admission).

L2-индексация любой конечной мерности, включая `array[-1]`, — вычисление смещения и обычный доступ. Не порождать проверки length, знака индекса, принадлежности арене или требования бывшего поля. Знаковое смещение не превращать в ранний отказ через приём в size_t. Чтение, запись и взятие адреса используют один расчёт; L3 добавляет одну проверку итогового элемента, а не проверки каждой скобки.

Копия массива имеет отдельное хранилище; передача ссылки сама по себе его не создаёт. Возврат ссылки не должен скрыто копировать данные для исправления времени жизни. Совместное хранилище сохраняет обычные границы владельца Message.
[EN]
An ordinary Structure and a reference Array `Array<@>` are fully interchangeable: indexing, named paths where names exist, `length`, admission, copying, execution, `sys\typeof` and `sys\descriptor` use the common contract. An ARRAY/STRUCT category alone is no reason for refusal. `length` reads the header field `length`; `parent/length/storage` are not counted as elements. A numeric `Array<T>` stores T directly. Structures, Arrays, and service lists share length and capacity management. Finite rectangular Array rank has no fixed limit and is independent of pointer depth. [Layout](L2_spec_en.md#lmx).

An ordinary Array is a typed graph Structure with stable reference identity. Constructor `[]` creates it when execution reaches the construction site. In `[]: arr (... )`, binding occurrence `arr` belongs to the current Structure, the Array's structural parent is that `arr` occurrence, and structural elements materialized from the arguments have the Array as their parent. Parentheses around the arguments create no extra anonymous wrapper in the Array: P0 does not unwrap them, but the receiver `[]` reads the Structure written in them by its own contract, as the list of its arguments ([general rule](#values)). In data `MyLmxStructFromArray: arr` declares a Structure `MyLmxStructFromArray` with the one atom `arr`; that atom is a pointer to **that same Array**, a reference immutable by name: in the tree under `MyLmxStructFromArray` stands only the atom, the Array is neither reconstructed nor copied, and its `parent` does not change ([declaring a Structure](#colon-declares)); a pointer variable to that same Array is declared by `@: p arr`, and in code the form `MyLmxStructFromArray: arr` is a call of its head. A Structure field holding an Array reference is not the Array itself. Passing a reference does not copy elements; an element mutation is visible through other references, whereas rebinding a local reference is not.

An owning Array has one contiguous rectangular block of elements. Nested dimensions do not mean separately allocated rows. For shape `[d0, …, dN−1]`, element count is the product of dimensions, with the last index varying fastest. An Array of references to other Arrays is a different value, not a replacement for a rectangular multidimensional Array. A structural element is nested under the Array; a primitive element occupies its storage but acquires no separate `parent` field.

A graph Array has the common Lmx base with parent/length/storage and a stable descriptor address; its typed storage is not a separate graph Array. Structures and Arrays have variable length and capacity. The former fixed-Array/separately-growing-List distinction is cancelled: one mechanism serves both operations and all element types. Native resides in call tables, not in the header.

<a id="array-capacity"></a>
The arena holds a table “Structure descriptor address → capacity”, measured in elements.
It supports common allocation and resizing, but is not consulted by ordinary indexing.
`sys\resize(S, n)` changes length and provides storage as needed; `sys\reserve(S, n)` ensures capacity
without changing length; `sys\capacity(S)` reads the table.
Storage may move while the Array descriptor retains its address. Service arrays use the same mechanism;
do not add capacity to Lmx, a hidden prefix, or a separate DynamicArray family.
Existing typed-allocation and release duties belong to that same mechanism.

<a id="l3-array-reference"></a>
An L3 pointer to an Array element has a type distinct from a raw L2 pointer and stores a reference to the
Array descriptor itself plus an explicit index. It stores no storage address and needs no repair when
storage moves. Access uses current descriptor length/storage and one final linear index.
Intermediate `[i][j]` steps create no additional descriptors. An L3 primitive pointer also has its own type;
reuse typed-reference and uninit:T foundations without conflating reference type with absence of a value.
Pointer depth remains arbitrary and finite. L2 retains raw machine addresses, without automatically
moving an earlier obtained address along with storage.


`length(array)` reads the Array's element count; for a rectangular Array this is the total count, not its first dimension. Physical backing need not retain dimensions and cannot reconstruct them from the total element count. The containing Structure's field count, Array length and service-pool size are distinct.

<a id="structure-index"></a>
A Structure and `Array<@>` are addressed identically. `S[i]` reads a `void*` from physical `storage`; `S[i] := p` stores another `void*` there. This operation neither checks nor transfers a former field's requirement, name, or cell kind: it is simply a write of a value into the array, without checks (the author's clarification of 2026-11-17). Slot count and addresses do not change. Names and types are interpreted from current content when subsequently needed; the write itself does not assign a name to the slot. `S\[N]field` and `voidarray\[N]field` structurally select the Nth occurrence under the named field contract. An ordinary typed `Array<T>` retains its element representation. `length(S)` reads the element count. Index writes require no former-slot requirement table or associated publication/checking mechanism.

<a id="get-type"></a>
`sys\typeof(arg)` returns the type code of the selected typed record; an `uninit:T` record supplies its code without any value read. After graph-fragment replacement, a fresh lookup through the structural place selects the replacement record, without a promise about an old raw address: `sys\typeof(S[i])` identifies the selected field value, `sys\typeof(@i)` the addressed cell of i, and `sys\typeof(S)` the Structure descriptor. It consumes an address or reference, not an arbitrary scalar pretending to be one. Zero or an address outside the Message's arena gives the no-type code under this receiver's contract. Codes come from the kernel's named region-type constants; numeric code values are not fixed by this specification. The interpreter and native execution use the same result contract. Ordinary native locals have no arena prefix: their logical place/type metadata cannot be obtained by blindly reading before a C address ([binding executors](#binding-executors)).

Built-in machine element types retain their [C99 target-profile meaning](L2_spec_en.md#lowlevel-scope), including plain `char` signedness; a descriptor does not redefine them. L3 adds checked access, not a different primitive representation.

A full N-dimensional rectangular Array index contains N integer coordinates. For a rectangular Array, coordinates are reduced to one linear element index in row-major order: `k = (...((i0 * d1 + i1) * d2 + i2)...)`. L3 checks only the final element against the descriptor's total length: `0 <= k < length(array)`. It does not check each coordinate against its dimension or store a vector of dimension lengths for those checks. For example, in a `[2,3]` rectangle, `[0,3]` has linear index 3 and selects the same element as `[1,0]`; linear index 6 raises implicit `throw: interpreter` rather than returning `None`. Computing the index must not wrap an out-of-range mathematical result into a valid element. An Array of references to Arrays is different: each step accesses another actual Array with its own descriptor.

Adjacent indices `matrix[i][j]` address one flat Array using strides known from its description, whereas `a[i]\[j]` addresses the previously selected reference value through the path separator ([paths](#fields)). The descriptor does not recover dimensions, and an incomplete index spelling does not by itself construct a separate row Array or hidden view descriptor. These access checks are made by L3, whether executed natively or interpreted, and by the interpreter when it executes L2 code; native [L2 access](L2_spec_en.md#lowlevel-address), including obtaining a graph-backed element's address, works without them (the author's decision of 2026-11-18). Operation checks do not constitute a separate candidate-admission mechanism in place of [analysis and unit tests](#admission).

L2 indexing of any finite rank, including `array[-1]`, is offset calculation and ordinary access. Emit no length, index-sign, arena-membership, or former-field-requirement checks. Do not turn a signed offset into an early rejection by receiving it into size_t. Reading, writing, and address-taking share one calculation; L3 adds one final-element check rather than a check for each bracket.

An Array copy has separate backing; passing a reference does not itself create it. Returning a reference must not hide copying to repair lifetime. Shared backing retains ordinary Message ownership boundaries.
@@ array-operations | Операции над массивами | Array operations | 6.5.6–6.5.15
[RU]
Арифметика и сравнения массивов по умолчанию поэлементные. Операция над элементом определяется его числовым доменом и явно выбранным контекстом. `*` означает поэлементное умножение, не матричное. `matmul`, `dot`, `contract` и `outer` — отдельные выраженные операции; профильный символ матричного умножения не должен делать обычное `*` двусмысленным.

`reduce` сворачивает элементы ассоциативной либо явно упорядоченной операцией. Контракт задаёт нейтральное значение, когда оно нужно, операцию элемента, тип результата и порядок. Для воспроизводимых вещественных/десятичных вычислений порядок не должен зависеть от случайного выбора backend.

`scan` — префиксная свёртка: включающий вариант суммы для `[1,2,3,4]` даёт `[1,3,6,10]`. Включающий или исключающий вариант выбирается явно. `map` применяет выражение к элементам; чистый вариант допускает векторизацию и параллельное вычисление с сохранением результата. Для эффектов необходим явный порядок; основной профиль предполагает чистое отображение.

`filter` отбирает элементы по логическому предикату и обычно материализует новый массив. Копирование, материализация и все результаты сохраняют границы владельца Message.
[EN]
Array arithmetic and comparisons are elementwise by default. Element operations follow their numeric domain and explicitly selected context. `*` means elementwise multiplication, not matrix multiplication. `matmul`, `dot`, `contract` and `outer` are separate explicit operations; a profile-specific matrix symbol must not make ordinary `*` ambiguous.

`reduce` collapses elements with an associative or explicitly ordered operation. The contract defines an identity where needed, element operation, result type and ordering. Reproducible real/decimal computations must not depend on an incidental backend choice of order.

`scan` is a prefix reduction: inclusive sum of `[1,2,3,4]` gives `[1,3,6,10]`. Inclusive or exclusive behavior is explicitly selected. `map` applies an expression to elements; a pure variant permits vectorization and parallel evaluation preserving the result. Effects need explicit ordering; the default profile expects pure mapping.

`filter` selects elements by a Boolean predicate and normally materializes a new Array. Copies, materialization and all results retain Message ownership boundaries.
@@ mathematics | Числовые операции, чистота и контексты | Numeric operations, purity and contexts | 6.6–6.6.13
[RU]
Числовые имена и операторы разрешаются в доступные конструкторы, явные описания и вызываемые операции. Семейства включают машинные целые и вещественные, `bigint`, `real`, `decimal`; это не обязательный закрытый список типов языка. GMP, MPFR и decNumber — возможные реализации, не исходная онтология L3. Преобразования задают диапазон, точность и округление по [контракту описаний](#descriptions).

Выбранный чистый профиль выражений допускает только операции с объявленным чистым контрактом; общий механизм выражений также поддерживает достигнутые присваивания и эффектные вызовы, описанные в §9. `sqrt`, `sin`, `cos`, `pow`, `abs`, `gcd`, округление и арифметика могут иметь такие обёртки. Эффектные операции остаются допустимыми высокоуровневыми принимающими выражениями, но не становятся чистыми из-за записи в выражении. L3 не запрещает эффекты вообще и не определяет права доступа одним номером уровня.

У низкоуровневой функции с сырыми указателями нет прямого L3-вызова. Высокоуровневая обёртка определяет владение, срок заимствования, политику нуля, границы, тип элементов, изменения, отказы и результат. Без неё доступна только машинная сторона [L2](L2_spec_ru.md#lowlevel-abi). Инициализация и освобождение числового backend обычно являются обязанностью провайдера; пользовательский числовой код не должен вручную имитировать его внутреннее хранение.

Контекст `real` может задавать точность, округление, статусы, traps и требования точности результата; `decimal` — также пределы экспоненты и квантование. Контекст является явно достижимыми данными или фиксированной конфигурацией профиля, не скрытым глобальным состоянием. Конкретные имена принимающих выражений контекста остаются профильными. Детерминированный профиль обязан исключать зависимость результата от неоговорённых платформенных настроек.

Массивы используют те же скалярные операции и контексты. Векторизация, свёртка и тензорная операция не создают другого смысла сложения. Минимальный профиль математики предусматривает базовую арифметику, логические операции, сравнения, конструирование и арифметику трёх расширенных числовых семейств, явные преобразования, выбранные чистые функции и операции числовых массивов. Доступность всей C-библиотеки из этого не следует.
[EN]
Numeric names and operators resolve to available constructors, explicit descriptions and callable operations. Families include machine integers/floats, `bigint`, `real`, `decimal`; these are not a mandatory closed language type list. GMP, MPFR and decNumber are possible implementations, not L3 source ontology. Conversions specify range, precision and rounding under the [description contract](#descriptions).

A selected pure expression profile admits only operations with declared pure contracts; the general expression mechanism also supports the reached assignments and effectful calls described in §9. `sqrt`, `sin`, `cos`, `pow`, `abs`, `gcd`, rounding and arithmetic may have such wrappers. Effectful operations remain valid high-level receivers but do not become pure by being written in an expression. L3 does not prohibit effects generally or derive authority solely from a level number.

A low-level function with raw pointers has no direct L3 call. A high-level wrapper defines ownership, borrow duration, null policy, bounds, element type, mutation, failures and result. Without it only the machine side of [L2](L2_spec_en.md#lowlevel-abi) is available. Numeric-backend initialization and release normally belong to the provider; user numeric code should not manually reproduce its internal storage management.

A `real` context may define precision, rounding, status, traps and exactness requirements; `decimal` additionally includes exponent limits and quantization. Context is explicitly reachable data or fixed profile configuration, not hidden global state. Exact context receiver names remain profile-specific. A deterministic profile must exclude dependence on unspecified platform settings.

Arrays use the same scalar operations and contexts. Vectorization, reduction and tensor operations do not create a different meaning of addition. The minimal mathematics profile includes basic arithmetic, Boolean operations, comparisons, construction/arithmetic for the three extended numeric families, explicit conversions, selected pure functions and numeric-Array operations. It does not imply exposure of the entire C library.
@@ composition | Композиция и копирование графа | Composition and graph copying | 2.3; 19.17; 19.23; 19.29.7
[RU]
`copy` и `merge` обрабатывают явные структурные источники и производят **поток результирующих полей** для окружающего потребителя. Они не возвращают неявно один внешний контейнер. `copy` принимает ровно один источник; `merge` принимает два или более, и его первый допущенный источник является моделью этой операции. `import` связан только тем, как его выбранные объявления потребляются через namespace; он не копирует графы ([import](#import-receiver)).

| Операция | Источники | Выход | Связи |
| --- | --- | --- | --- |
| `import` | Один или более | Допустимые корневые константные объявления | Исходные ссылки на объявления и родители |
| `copy` | Ровно один | Глубоко скопированные поля и требуемый граф | Одна карта соответствия источник–копия; методы сохраняют соответствующих скопированных владельцев |
| `merge` | Два или более | Глубоко скопированная композиция допущенных источников | Одна общая карта для всех источников; методы сохраняют соответствующих скопированных владельцев |

Различие в идентичности категориально. Import предоставляет ссылки на исходные допустимые объявления и сохраняет их исходных владельцев: DATA или лексических. Copy и merge глубоко копируют используемый граф по общему контракту, указанному ниже. Явный контейнер группировки имеет собственные ячейки хранения, отличные от ячеек как исходного владельца, так и скопированного владельца. Его элементы хранят ссылки на материал, порождённый операцией. Сбор этих ссылок не передаёт лексическое владение группе и не делает элементы группы псевдонимами элементов владельца.

**Текущий приёмник никогда не является неявным источником или моделью.** Получение потока merge — это не ещё одно merge. Независимые операции `merge` или `copy` используют независимые карты, даже если один и тот же потребитель DATA получает их выходы.

<a id="merge-two-forms"></a>
### Один контракт аргумента-источника в каждом размещении

Все три ресивера всегда читают свои аргументы как стандартный CODE, используя общий алгоритм транслятора и обычный выбор W/E. Размещение записи ресивера в DATA не создаёт варианта DATA-аргумента. Анонимная Structure, используемая как источник, и простая ссылка на Structure являются обычными значениями, а не вызовами этих Structure. Анонимная Structure, тем не менее, может содержать вызовы и инициализаторы: их обычные контракты приёма и выполнения определяют, когда они выполняются. Группировка не создаёт ни особой квотированной, ни ленивой формы, ни предварительного прохода по каждому инициализатору. Явный `Producer()` вычисляет свой источник один раз, когда ресивер действительно потребляется, в том числе тогда, когда запись этого ресивера хранится в DATA. Несколько вычисляемых источников вычисляются в порядке записи; выбор кандидатов не вычисляет их повторно. P0 и инспекция исходного графа не выполняют ни одной из этих операций.

Следующие формы DATA имеют одинаковый смысл:

```lmx
Struct: merge(A B)
```

```lmx
Struct:
    merge(A B)
```

`Struct:` обычно объявляет `Struct`; `merge` подаёт свой поток в это чтение DATA через namespace. Его запись источника остаётся `merge(A B)` в графе, и явный путь к этой записи её не запускает. То же верно для `copy`, `import` и их охватывающих групп. Только терминальный примитив использует прямое представление `{type value}`. Сериализация сохраняет ресиверы и группы, а не печатает раскрытие namespace над ними.

```lmx
Struct:
    merge(A B)
    merge(C D)
    copy(E)
```

Это выполняет три независимые операции в порядке записи. Это не `merge(Struct A B C D E)`, не последовательность наложений на `Struct` и не одно merge из пяти источников с общей картой copy. `Struct: extern` сохраняет свой обычный структурный смысл и не становится присваиванием или неявным раскрытием `extern`.

### Элементы модели, совпадение и порядок

Внутри **одного** `merge(A B...)` первый допущенный источник задаёт раскладку модели. Более позднее поле, совпадающее с полем модели по установленному соответствию имён/типов и правилам допуска, заменяет значение **в этом элементе модели**. Поле без пары добавляется в порядке источников. Индексы модели остаются стабильными, и методы не получают скрытого смещения. Ранее полученные поля родительского ресивера DATA находятся вне этой модели.

```lmx
Struct:
    int: x 1
    merge(A B)
```

Если A и B имеют совместимый x, их merge определяет его результирующий x. Уже записанный `int: x 1` не является элементом модели этой операции. Приём потока следует обычному повторению DATA, включая множественные вхождения и обычное разрешение неоднозначных имён. Это семантическое чтение не заменяет ни одну из записей источников в `Struct`.

Обычный источник `f(args)` является вызовом CODE всякий раз, когда его потребляет `merge` и он должен давать допустимый источник, независимо от того, где была записана запись ресивера. Поле модели с тем же именем не может его перехватить. Записанная группа, такая как `(int: v 9)`, подаёт Structure, содержащую объявление примитива, тогда как `(v: 9)` содержит Structure с именем v. Фактический аргумент — объявление места сохраняет [контракт формы объявления](#declaration-arguments); обычные вызовы не захватываются как объявления.

### Поток или один сгруппированный результат

| Назначение | Форма |
| --- | --- |
| Передать скопированные поля в вызов | `f(copy(A))` |
| Передать объединённые поля в вызов | `f(merge(A B))` |
| Построить одну Structure до обычного выбора вызова | `f((copy(A)))`, `f((merge(A B)))` |
| Принудительно передать всю доставку настоящему формальному параметру без E | `f(arg0 := (copy(A)))` |
| Инициализировать ссылку одним результатом | `@: result (merge(A B))` |
| Присвоить один результат существующей переменной-ссылке | `result := (copy(A))` |
| Вернуть одну скопированную Structure | `return: (copy(A))` по обычному допуску return |
| Потребить два поля по позиции | `(a b) := (copy(Pair))` |

Без группировки `result := copy(A)` всё ещё имеет правую часть в виде потока полей. Её допустимость определяется обычным потребителем присваивания; это не автоматически прежнее присваивание в один контейнер и не является безусловно синтаксической ошибкой. `result` здесь должна быть присваиваемой переменной-ссылкой, а не именем-константой объявления Structure.

`copy(Empty)` даёт ноль полей; `(copy(Empty))` даёт одну пустую Structure. Ни одна из этих форм не совпадает с `copy()` без источника. Группа, содержащая ноль или одно поле, остаётся в исходном графе. Группировка не выполняет второго независимого копирования и не отключает W/E в последующем потребителе CODE. `merge(S)` может допускать E как два или более источника по своему стандартному контракту аргументов CODE в любой позиции; настоящее копирование из одного источника использует `copy`, а копирование с нулём источников или с несколькими источниками завершается ошибкой арности. Арность входа и количество полей на выходе — это отдельные этапы.

### Общая карта копирования графа

Одна операция копирует полный используемый граф с необходимыми ссылками и лексическими цепочками к нулевому родителю, используя одну карту для всех своих источников и полей. Общие цели остаются общими, а циклы остаются циклами: копирование полей независимо было бы ошибочным. Ссылки и связи `parent` переписываются через ту же карту, включая необходимые скопированные лексические предки. Корни источников и предки не становятся дополнительными видимыми выходными полями лишь потому, что они нужны для связей.

Ячейка-ссылка и используемый объект, на который она указывает, копируются через эту карту. Если `Holder` содержит ссылку p на Model, композиция `(merge(Model Holder))` использует уже установленную копию Model для p, а не создаёт третий экземпляр и не сохраняет исходную изменяемую цель. Более поздняя группа, собирающая поток, не дублирует эти поля независимо. Группа — это отдельный контейнер, принимающие ячейки которого отличны от ячеек скопированного лексического владельца. Запись состояния, предназначенная скопированному методу, должна выбирать его фактические скопированные DATA или лексического владельца; замена поля в контейнере группировки меняет только выбранную ячейку. Если ссылки в обоих контейнерах ведут к одной и той же вложенной Structure, пути через эти ссылки могут достигать одной и той же ячейки этой вложенной Structure; различные внешние ячейки не означают второго глубокого копирования их общих целей. Обычная `Struct1: Struct2` содержит атом-ссылку; копирование трактует его как ссылку, а не как синтаксически развёрнутое поддерево. Источники Structure и reference Array сохраняют свою существующую общую область; новое ограничение на одну категорию контейнера не добавляется.

Принятие в другое namespace DATA не меняет лексический контекст скопированных методов и не превращает `node` в “текущего получателя потока”. `node` остаётся лексическим оператором выбранного вхождения. Его реальные связи DATA/parent и порядок связывания сохраняются. Одно лишь помещение существующей ссылки на метод в новую Structure не переназначает ему родителя; иная пара данных и кода требует фактического разрешённого построения или копирования соответствующих связей.

Существуют два установленных случая сохранения. Повторно используемые ссылки на нативную реализацию — это конечные машинные реализации, отличные от изменяемых вхождений вызываемых и от лексических данных. Надлежащим образом квалифицированная ветвь `independent: immutable` **должна сохранять свою исходную физическую ссылку**, независимо от того, присутствует ли также `const`. Её корень не имеет внешнего лексического родителя, а её хранимый граф прошёл предварительную проверку immutable. Одна лишь метка, одно лишь `independent`, одно лишь `immutable` или один лишь нулевой родитель недостаточны; неудачная квалификация приводит к отказу, а не к молчаливому копированию, скрывающему сбой. Её исходные правила владельца и времени жизни остаются в силе. Весь прочий используемый изменяемый материал графа получает отдельное хранилище.

Копирование не предоставляет полномочий доступа или экспорта для защищённой ветви. Допуск источника, владение, время жизни указателя и [защита объектов](#protected-structures) остаются применимыми. Карта не является вторым механизмом разрешения имён и не связывает аргументы вызова, не захватывает frame вызывающего, не меняет приоритеты динамических входов и не создаёт отсутствующие значения по умолчанию путём проверки модели.

### Повторное использование нативного кода и структурная композиция вызываемых

Вызываемое — это обычная Structure, фактический родитель которой описывает входы и результат. Копирование/композиция сохраняют эти части и их связи; ни описание входов, ни требование к результату, ни место назначения не являются дополнительным неявным операндом. Успешная общая карта соответствия может связывать разные физические позиции полей без поиска по тексту во время выполнения, но эта карта не выбирает исполняемое тело.

Copy/merge сохраняют разрешённые нативные связи по существующему контракту; они не компилируют новый код и не регистрируют новые машинные варианты автоматически. Совместимое выбранное тело и ABI могут повторно использовать реализацию. Изменение тела не может сохранить несвязанную нативную точку входа лишь потому, что её явная форма типа совпадает. Повторное использование машинного кода не подразумевает совместного использования изменяемого вхождения вызываемого. [Явная компиляция](#explicit-compilation) остаётся границей обновления.

### Возвращаемый вложенный метод

Результат, которому нужна одна скопированная Structure, использует явную группу, например `return: (copy(Product))`; `merge(Product)` с одним источником больше не является формой копирования. Для нескольких источников используется `return: (merge(Model Values))`. Описание результата допускает построенное значение и не является другим источником. Любые необходимые значения активации должны поступать через явный исходный материал или обычные явные операции; copy/merge не захватывают молча stack frame и не продлевают время жизни сохранённых адресов стека. Скопированное значение формального параметра может служить значением по умолчанию, а скопированное значение свободного имени — лексическим запасным вариантом по обычным правилам вызова.

<a id="factory-reference-result"></a>
Ресивер-ссылка может сохранить результат фабрики, например `@: product Factory\create()`, и позже вызвать выбранный вложенный метод. Он не добавляет префикс `@`, чтобы получить обычную ссылку на Structure. `add5(1)` или `(\add5)(1)` вызывает сохранённую ссылку на метод; `\add5(1)` разыменовывает результат вызова согласно приоритету. См. [пример с фабрикой](LMX_semantics_guide.ru.md#factory-result).

### Связывание, сбои и другие потребители

Copy/merge не переопределяют [приоритеты связывания](#binding-places). Фильтр private и правило прозрачного места вызывающего применяются первыми, где это уместно; сохранённый запасной вариант по-прежнему обращается к разрешённым динамическим источникам раньше лексических. Явное `node\...` выбирает установленный лексический контекст. Никакой поток результата не устанавливает скрытого замыкания или частичного применения.

Каждый ресивер сообщает о сбое по собственному контракту: `copy` и `import` не должны случайно сообщать о `merge` лишь потому, что низкоуровневый вспомогательный механизм общий. Как и в случае других неявных сбоев операторов, применимый обычный catch обрабатывает названный сбой; необработанный сбой останавливает выполняющийся Thread согласно [§15](#exceptions). Не гарантируется ни публикация частичного результата, ни откат уже завершённых эффектов исходного выражения. Временное хранилище следует правилам времени жизни владеющего Message; [копирование в L2](L2_spec_ru.md#copy-merge) задаёт механизмы.

Схемы, описания типов и таблицы используют ту же структурную операцию. Политики строк, ключей и конфликтов таблицы принадлежат выбранному потребителю таблицы и не изменяют правила повторения модельных мест или DATA. Передача хранилища Message — это [другая операция](#delivery): она передаёт владение без копирования и без лексического переназначения родителя. Определяющее уточнение потока — [предоставленное ТЗ от 21 ноября](tasks/LMX_Fable_TZ_Import_Copy_Merge_Field_Streams_2026-11-21.md).
[EN]
`copy` and `merge` process explicit structural sources and produce a **stream of resulting fields** for the surrounding consumer. They do not implicitly return one outer container. `copy` accepts exactly one source; `merge` accepts two or more, and its first admitted source is the model of that operation. `import` is related only in how its selected declarations are consumed through the namespace; it does not copy graphs ([import](#import-receiver)).

| Operation | Sources | Output | Relationships |
| --- | --- | --- | --- |
| `import` | One or more | Eligible root constant declarations | Original declaration references and parents |
| `copy` | Exactly one | Deep-copied fields and their required graph | One source-to-copy map; methods retain their corresponding copied owners |
| `merge` | Two or more | Deep-copied composition of the admitted sources | One common map for all sources; methods retain their corresponding copied owners |

The identity difference is categorical. Import supplies references to the original eligible declarations and keeps their original DATA/lexical owners. Copy and merge deeply copy the used graph under the common contract below. An explicit grouping container has its own storage cells, distinct from cells of either an original owner or a copied owner. Its slots hold references to the material emitted by the operation. Collecting those references neither transfers lexical ownership to the group nor makes the group's slots aliases of the owner's slots.

**The current destination is never an implicit source or model.** Receiving a merge stream is not another merge. Independent `merge` or `copy` operations use independent maps even when the same DATA consumer receives their outputs.

<a id="merge-two-forms"></a>
### One source-argument contract in every placement

All three receivers always read their arguments as standard CODE, using the common translator algorithm and ordinary W/E selection. Placement of a receiver record in DATA does not create a DATA-argument variant. An anonymous Structure used as a source and a bare reference to a Structure are ordinary values, not calls of those Structures. An anonymous Structure may nevertheless contain calls and initializers: their ordinary receiving and execution contracts determine when they run. Grouping creates neither a special quoted or lazy form nor an eager pass over every initializer. An explicit `Producer()` computes its source once when the receiver is actually consumed, including when that receiver record is stored in DATA. Multiple computed sources are evaluated in written order; candidate selection does not evaluate them repeatedly. P0 and source-graph inspection execute none of these operations.

The following DATA forms have the same meaning:

```lmx
Struct: merge(A B)
```

```lmx
Struct:
    merge(A B)
```

`Struct:` ordinarily declares `Struct`; `merge` supplies its stream to that DATA reading through the namespace. Its source record stays `merge(A B)` in the graph, and an explicit path to the record does not run it. The same is true of `copy`, `import`, and their enclosing groups. A terminal primitive alone uses direct `{type value}` representation. Serialization preserves the receivers and groups rather than printing namespace expansion over them.

```lmx
Struct:
    merge(A B)
    merge(C D)
    copy(E)
```

This performs three independent operations in written order. It is neither `merge(Struct A B C D E)`, nor a sequence of overlays onto `Struct`, nor one five-source merge with a shared copy map. `Struct: extern` retains its normal structural meaning and does not become assignment or implicit expansion of `extern`.

### Model slots, matching and order

Inside **one** `merge(A B...)`, the first admitted source supplies the model layout. A later field matching a model field by the established name/type correspondence and admission rules replaces the value **in that model slot**. A field with no counterpart appends in source order. Model indices remain stable, and methods gain no hidden offset. A parent DATA receiver's previously received fields are outside this model.

```lmx
Struct:
    int: x 1
    merge(A B)
```

If A and B have a compatible x, their merge decides its result x. The already written `int: x 1` is not that operation's model slot. Acceptance of the stream follows ordinary DATA repetition, including multiple occurrences and ordinary ambiguous-name resolution. This semantic reading does not replace either source record in `Struct`.

An ordinary `f(args)` source is a CODE call whenever `merge` consumes it and must yield an admissible source, regardless of where the receiver record was written. A model field sharing its name cannot intercept it. A written group such as `(int: v 9)` supplies a Structure containing a primitive declaration, whereas `(v: 9)` contains a Structure named v. A place-declaration actual retains the [declaration-form contract](#declaration-arguments); ordinary calls are not captured as declarations.

### A stream or one grouped result

| Intent | Form |
| --- | --- |
| Supply copied fields to a call | `f(copy(A))` |
| Supply merged fields to a call | `f(merge(A B))` |
| Build one Structure before the call's ordinary selection | `f((copy(A)))`, `f((merge(A B)))` |
| Force whole delivery to a real formal without E | `f(arg0 := (copy(A)))` |
| Initialize a reference with one result | `@: result (merge(A B))` |
| Assign one result to an existing reference variable | `result := (copy(A))` |
| Return one copied Structure | `return: (copy(A))` under return's ordinary admission |
| Consume two fields positionally | `(a b) := (copy(Pair))` |

Without grouping, `result := copy(A)` still has a stream RHS. Its validity follows the ordinary assignment consumer; it is not automatically the old one-container assignment and is not universally a syntax error. `result` here must be an assignable reference variable, not the constant name of a Structure declaration.

`copy(Empty)` yields no fields; `(copy(Empty))` yields one empty Structure. Neither is the same as `copy()` with no source. A group containing zero or one field remains in the source graph. Grouping does not perform a second independent copy or switch off W/E in a subsequent CODE consumer. `merge(S)` may admit E as two or more sources under its standard CODE argument contract in every placement; a true one-source copy uses `copy`, and zero-source or multi-source copy fails arity. Input arity and output field count are separate stages.

### The common graph-copying map

One operation copies the complete used graph with required references and lexical chains to a zero parent, using one map across all of its sources and fields. Shared targets remain shared and cycles remain cycles: copying fields independently would be wrong. References and `parent` links are rewritten through the same map, including necessary copied lexical ancestors. Source roots and ancestors do not become extra visible output fields merely because they are needed for relationships.

A reference cell and its used pointee are copied through this map. If `Holder` contains a reference p to Model, the composition `(merge(Model Holder))` uses the already established copy of Model for p, rather than making a third instance or retaining the original mutable target. A later group collecting the stream does not independently duplicate those fields. The group is a distinct container whose receiving cells are distinct from the copied lexical owner's cells. A state write intended for a copied method must select its actual copied DATA or lexical owner; replacing a field in the grouping container changes only that selected cell. If references in both containers lead to the same nested Structure, paths through those references can reach that nested Structure's same cell; distinct outer slots do not imply a second deep copy of their shared targets. Ordinary `Struct1: Struct2` contains a reference atom; copying treats it as a reference, not a syntactically expanded subtree. Structure and reference Array sources retain their existing common domain; no new single-container-category restriction is added.

Acceptance into another DATA namespace does not change copied methods' lexical context or turn `node` into “the current stream recipient”. `node` remains the lexical operator of the selected occurrence. Its real DATA/parent relationships and binding order are preserved. Merely placing an existing method reference in a new Structure does not reparent it; a different data/code pairing requires an actual permitted construction or copying of the relevant relationships.

There are two established retention cases. Reusable native implementation references are terminal machine implementations, distinct from mutable callable occurrences and lexical data. A properly qualified `independent: immutable` branch **must retain its original physical reference**, whether or not `const` is also present. Its root has no external lexical parent and its stored graph has passed immutable preflight. A label alone, `independent` alone, `immutable` alone or zero parent alone is insufficient; failed qualification refuses rather than silently copying to hide failure. Its original owner/lifetime rules remain. All other used mutable graph material receives distinct storage.

Copying does not grant access or export authority for a protected branch. Source admission, ownership, pointer lifetime and [object protection](#protected-structures) remain applicable. The map is not a second name-resolution mechanism and does not bind call arguments, capture a caller frame, change dynamic-input priorities or create missing defaults by checking a model.

### Native reuse and structural callable composition

A callable is an ordinary Structure whose actual parent describes inputs and result. Copying/composition preserves these parts and their links; neither the input description, result requirement nor destination is an additional implicit operand. A successful general correspondence map can relate different physical field positions without runtime textual lookup, but that map does not select an executable body.

Copy/merge preserve permitted native links by the existing contract; they neither compile new code nor register new machine variants automatically. A compatible selected body and ABI can reuse an implementation. Changing the body cannot retain an unrelated native entry merely because its explicit type shape matches. Machine-code reuse does not imply sharing a mutable callable occurrence. [Explicit compilation](#explicit-compilation) remains the update boundary.

### Returned nested methods

A result that needs one copied Structure uses an explicit group, such as `return: (copy(Product))`; one-source `merge(Product)` is no longer the copying form. Multiple sources use `return: (merge(Model Values))`. The result description admits the constructed value and is not another source. Any needed activation values must enter through explicit source material or ordinary explicit operations; copy/merge do not silently capture a stack frame or give stored stack addresses longer life. A copied formal value can serve as a default and a copied free-name value as lexical fallback, under the ordinary call rules.

<a id="factory-reference-result"></a>
A reference receiver can retain a factory result, for example `@: product Factory\create()`, and later call a selected nested method. It adds no prefix `@` to obtain an ordinary Structure reference. `add5(1)` or `(\add5)(1)` calls a stored method reference; `\add5(1)` dereferences the call's result according to precedence. See the [factory example](LMX_semantics_guide.en.md#factory-result).

### Binding, failures and other consumers

Copy/merge do not override [binding priorities](#binding-places). The private filter and transparent caller-place rule apply first where relevant; retained fallback still consults permitted dynamic sources before lexical ones. Explicit `node\...` selects the established lexical context. No result stream establishes a hidden closure or partial application.

Each receiver reports failure under its own contract: `copy` and `import` must not accidentally report `merge` merely because a low-level helper is shared. As with other implicit operator failures, an applicable ordinary catch handles the named failure; an uncaught failure stops the executing Thread under [§15](#exceptions). No partial-result publication or rollback of already completed source-expression effects is promised. Temporary storage follows the owning Message's lifetime rules; [L2 copying](L2_spec_en.md#copy-merge) specifies mechanisms.

Schemas, type descriptions and tables use the same structural operation. Table row/key/conflict policies belong to their selected table consumer and do not alter model-slot or DATA repetition rules. Message storage transfer is a [different operation](#delivery): it transfers ownership without copying or lexical reparenting. The governing stream clarification is [the supplied 21 November TZ](tasks/LMX_Fable_TZ_Import_Copy_Merge_Field_Streams_2026-11-21.md).
@@ registries | Таблицы, запросы, связывание и провайдеры | Tables, queries, linking and providers | 19.18; 19.21–19.27; 19.30
[RU]
Registry, Table, RegistryView, схема и политика — роли обычных значений, не дополнительные категории или пространства имён. Операция получает корень реестра явно либо по выраженной ссылке. Наличие таблицы или строки с ключом `class`, `type`, `provides`, `satisfies` само по себе не запускает поиск и не меняет язык.

В табличном профиле первый столбец — ключ строки; `columns` задаёт имена и явные метаданные. Число ячеек плотных строк кратно числу столбцов, отсутствующая ячейка выражается явно; выравнивание текста полей не добавляет. Необязательное `source` запрашивает проекцию профиля транслятора, а не объявляет runtime-имена из ячеек. Ячейка может ссылаться на данные, ключ, описание, политику, диагностику, свидетельство, провайдера или вызываемое выражение.

Текстовый динамический запрос начинает с переданного корня и имён его упорядоченных детей; он не заменяет уже разрешённые структурные ссылки. Правила запроса, переменные, унификация, продолжения, приоритеты и конфликты принадлежат явно выбранным данным и политике потребителя, не общему правилу поиска поля Structure. Сохранённый результат проверки содержит явные зависимости и не даёт бессрочного разрешения будущим вызовам. Выбор кандидата проходит [общий допуск](#admission); ранжирование и публикация результата — отдельные явные действия.

Связывание модуля разрешает явно выбранные операции и рецепты построения в физические ссылки. Провайдер, кодек или правило понижения выбираются выраженной ссылкой, конфигурацией либо переданной Table; смена провайдера явна. Автоматического сканирования каталогов, процесс-глобального поиска или неявной публикации имён запросом нет. `import` предоставляет допустимые константные объявления по ссылке через текущий namespace; `copy` и `merge` копируют или составляют явные источники. Хранение таблиц и ранжирование неоднозначных запросов остаются политиками выбранного профиля. [Примеры таблиц и провайдеров](LMX_semantics_guide.ru.md#tables-and-registries) приводят примеры применения.

<a id="import-receiver"></a>
### `import`: корневые константные объявления по ссылке

`import` принимает один или несколько источников и всегда потребляет их как стандартные аргументы CODE, независимо от того, встречается ли его запись в DATA или в CODE. Он выбирает только те объявления, которые обычные правила call-DATA трактуют как **корневые константы**. Объявление обычной пользовательской Structure по своей сути константно даже без явного `const`, так как имя Structure не является присваиваемой переменной. Имя корневой константы, созданное через `fn`, тоже допустимо; при этом слово-ресивер `fn` не импортируется. Статус корневого уровня определяется общими правилами объявлений и модификаторов, а не только непосредственным физическим родительством.

Обычные изменяемые места для примитивов и ссылок не импортируются. Вложенные имена не поднимаются лишь потому, что импортируется охватывающая их Structure. Import сохраняет ссылки на исходные объявления, а также их идентичность, содержимое и физических родителей. Импорт метода поэтому сохраняет его исходные DATA и лексический контекст; импортирующая Structure не становится его родителем. Константное имя Structure не делает каждое поле неизменяемым.

```lmx
Library:
    const: int: limit 10
    int: counter 0
    Settings:
        int: width 2

Other:
    Tool:
        int: value 3

Use:
    import: Library Other
```

Чтение DATA у Use открывает `limit`, `Settings` и `Tool`; counter не открывается, и width/value по отдельности не поднимаются. Граф Use по-прежнему содержит `import: Library Other`. Аналогично, импорт циклов в [пример с аргументом-объявлением](#declaration-arguments) открывает его константное объявление iterate, оставляя iteration/body входами в циклах.

`import(A Producer())` вызывает Producer один раз, когда import фактически потребляется, и выбирает допустимые объявления из этого результата, а также из A. Это верно и тогда, когда запись import находится в DATA; P0 и просмотр исходной записи import его не выполняют. Голые ссылки на источники и анонимные Structure-источники сами по себе не являются вызовами. Вызовы или инициализаторы внутри анонимной Structure по-прежнему подчиняются своим обычным контрактам потребления; import не вводит ни общего подавления, ни жадного обхода. Несколько вычисляемых источников сохраняют обычный порядок вычисления слева направо и не повторяются при отборе кандидатов. Обычные правила CODE W/E действуют в каждой позиции: единственная библиотека из Structure может соответствовать и чтению целой библиотеки, и чтению развёрнутого источника, и тогда выбор неоднозначен. У Import нет скрытого предпочтения для W. Его исходная запись и записанные границы аргументов остаются неизменными.

Самостоятельный import передаёт свой выбранный поток объявлений в текущий namespace в порядке источников и объявлений. Вложенный `f(import(A B))`, напротив, передаёт этот поток потребителю аргументов f и не выполняет никакого дополнительного скрытого импорта в вызывающий контекст. `f((import(A B)))` собирает одну Structure до обычных правил W/E; явное именованное присваивание настоящему формальному параметру исключает E, когда требуется доставка целиком. Это обычные группы, а не новый синтаксис import.

Повторяющиеся имена подчиняются обычным правилам повторного объявления принимающего контекста. Import не имеет отдельной политики победы последнего источника и не вводит наложения model-элементов при merge. Содержимое источника и связи с родителем сохраняются независимо от того, является ли импортируемое имя пользовательской Structure, константным примитивом/ссылкой или именованной сигнатурой.

<a id="source-codec"></a>
### Вывод текущего графа: sys\toLmx

`sys\toLmx` выводит LMX-текст текущего графа с каноническими именами и сохранёнными комментариями. Все записи ресиверов и записанные границы группировки сохраняются; расширение потока namespace не заменяет исходные записи import/copy/merge. Терминальные примитивные объявления восстанавливаются из типа, значения и имени. Форматирование вставляет пустые строки только на задуманных границах полного корня документа, чтобы повторный разбор сохранял структуру. Явно перезаписанная конструкция выводится в своём текущем виде; ни история, ни native не восстанавливают более ранний исходный текст. Локальное выполнение не публикует свой frame и не заменяет инициализатор в исходных данных. Эта сериализация отличается от `sys\translate`, который возвращает текст L1 для последующей компиляции и ошибок понижения.

Аргумент `sys\toLmx(S)` задаёт сохраняемую структуру. Для L3 Thread сохраняются также все таблицы его арены, включая таблицы call и native-дескрипторы. Таблицами владеет арена: они не являются полями R0, и R0 — не единственный подходящий Thread. К произвольной S внешние таблицы арены скрыто не добавляются. Сохраняются порядок и пустые позиции, общие ссылки, циклы, имена и типизированные значения: это восстанавливаемый текущий граф, не только печать похожего исходника. Скрытых данных в чистом графе нет: все данные лежат в `void *`-хранилище его Structure и отображаются `toLmx` элементарно, а `length` и `parent` выводятся из сформированного им текста (решение автора 2026-11-17). Таблицу имён `fromLmx` восстанавливает из текста; она и остальные таблицы ядра — данные самого ядра, которое собирает само себя и написано на L2 и L3, то есть такие же Structure чистого графа, а не скрытые данные рядом с ним. Весь программный материал, включая эти таблицы, лежит в чистом графе LMX. Отдельный бинарник содержит скомпилированные методы, включая R0 и интерпретатор; R0 обращается к своему графу через локальный указатель. Переносимый C генерируется для реализаций этих методов по пути L3/L2 → L1 → C и не поставляет скрытого зеркала статических данных графа. Транслятор написан на L2 и L3, и вставки L1 в итоге тоже убираются.

`sys\fromLmx` разбирает сохранённый граф общим кодом построения и интернирует имена в принимающей арене. Восстановление чистого графа после перезапуска на той же платформе не требует заново транслировать всю программу. Сохранённые native-дескрипторы связываются с готовым бинарным модулем и именами входов соответствующего ABI; прежние машинные адреса не копируются. Пути к L1/C сохраняются как данные, но не заменяют ссылку на бинарник и вход. Таблица capacity восстанавливается по выделенному storage, например с capacity = length; прежний резерв сохранять не требуется. Это задача реализации, а не утверждение готовности нынешнего графового dumper.
[EN]
Registry, Table, RegistryView, schema, and policy are roles of ordinary values, not additional categories or namespaces. An operation obtains a registry root explicitly or through an expressed reference. Merely having a Table or a row keyed `class`, `type`, `provides`, or `satisfies` triggers no lookup and changes no language rule.

In the table profile, the first column is the row key; `columns` supplies names and explicit metadata. Dense-row cell counts are divisible by column count, absent cells are expressed explicitly, and text alignment adds no fields. Optional `source` requests a translator-profile projection rather than declaring runtime names from cells. A cell may refer to data, a key, description, policy, diagnostic, evidence, provider, or callable expression.

A dynamic textual query begins at its supplied root and its ordered children's names; it does not replace already resolved structural references. Query rules, variables, unification, continuations, priorities, and conflicts belong to explicitly selected data and the consumer's policy, not to the general Structure-field rule. A saved check result carries explicit dependencies and grants no indefinite permission for future calls. Candidate selection uses [ordinary admission](#admission); ranking and publishing a result are separate explicit actions.

Module linking resolves explicitly selected operations and construction recipes to physical references. A provider, codec or lowering rule is selected by an expressed reference, configuration or supplied Table; changing it is explicit. There is no automatic directory scan, process-global search, or implicit publication of names by a query. `import` exposes eligible constant declarations by reference through the current namespace; `copy` and `merge` copy or compose explicit sources. Table-storage and ambiguous-query ranking remain selected-profile policies. [Table and provider examples](LMX_semantics_guide.en.md#tables-and-registries) give applications.

<a id="import-receiver"></a>
### `import`: root constant declarations by reference

`import` accepts one or more sources and always consumes them as standard CODE arguments, whether its record occurs in DATA or CODE. It selects only declarations that ordinary call-DATA rules treat as **root-level constants**. An ordinary user Structure declaration is intrinsically constant even without explicit `const`, because the Structure's name is not an assignable variable. A root constant name created by `fn` is eligible too; the receiver word `fn` is not thereby imported. Root status uses the common declarative/modifier rules, not only immediate physical parenthood.

Ordinary mutable primitive/reference places are not imported. Nested names are not lifted merely because their enclosing Structure is imported. Import retains references to original declarations, their identity, contents and physical parents. Importing a method therefore preserves its original DATA and lexical context; it does not make the importing Structure its parent. A constant Structure name does not make every field immutable.

```lmx
Library:
    const: int: limit 10
    int: counter 0
    Settings:
        int: width 2

Other:
    Tool:
        int: value 3

Use:
    import: Library Other
```

The DATA reading of Use exposes `limit`, `Settings` and `Tool`; it does not expose counter or separately lift width/value. The graph of Use still contains `import: Library Other`. Similarly, importing cycles in [the declaration-argument example](#declaration-arguments) exposes its constant iterate declaration while leaving iteration/body as inputs in cycles.

`import(A Producer())` calls Producer once when import is actually consumed and selects eligible declarations from that result as well as A. This holds even when the import record occurs in DATA; P0 and inspection of its source record do not execute it. Bare source references and anonymous source Structures are not themselves calls. Calls or initializers inside an anonymous Structure still follow their ordinary consuming contracts; import adds no blanket suppression or eager traversal. Multiple computed sources retain ordinary left-to-right evaluation and are not repeated during candidate selection. Ordinary CODE W/E applies in every placement: a sole library of Structures may fit both whole-library and expanded-source readings and be ambiguous. Import has no hidden preference for W. Its source record and written argument boundaries remain intact.

Standalone import supplies its selected declaration stream to the current namespace in source and declaration order. Nested `f(import(A B))` instead supplies that stream to f's argument consumer and performs no additional hidden import into the caller. `f((import(A B)))` collects one Structure before ordinary W/E; explicit named assignment to a real formal excludes E when whole delivery is required. These are ordinary groups, not new import syntax.

Repeated names follow the receiving context's ordinary redeclaration rules. Import has no separate last-source-wins policy and no merge model-slot overlay. Source content and parent links remain intact whether the imported name is a user Structure, a const primitive/reference, or a named signature.

<a id="source-codec"></a>
### Current-graph serialization: sys\toLmx

`sys\toLmx` emits LMX text of the current graph with canonical names and retained comments. All receiver records and written grouping boundaries are preserved; namespace stream expansion does not replace source import/copy/merge records. Terminal primitive declarations are reconstructed from type, value and name. Formatting inserts blank lines only at intended full document-root boundaries so reparsing retains structure. An explicitly overwritten construct is emitted in its current form; neither history nor native reconstructs earlier source. Local execution does not publish its frame or replace the initializer in source data. This serialization differs from `sys\translate`, which returns L1 text for subsequent compilation and lowering errors.

The argument of `sys\toLmx(S)` selects the saved Structure. For an L3 Thread it also saves all tables of that Thread's arena, including call tables and native descriptors. The arena owns these tables; they are not fields of R0, and R0 is not the only eligible Thread. External arena tables are not silently attached to an arbitrary S. Preserve order and empty positions, shared references, cycles, names, and typed values: this is a reconstructable current graph, not merely source-like output. The clean graph holds no hidden data: all data lie in the `void *` storage of its Structures and are mapped by `toLmx` in an elementary way, while `length` and `parent` are derived from the text it forms (the author's decision of 2026-11-17). The table of names is restored by `fromLmx` from the text; it and the other tables of the kernel are data of the kernel itself, which builds itself and is written in L2 and L3 -- that is, the same Structures of the clean graph, not hidden data beside it. All program material, these tables included, lies in the clean LMX graph. The separate binary contains the compiled methods, including R0 and the interpreter; R0 accesses its graph through a local pointer. Portable C is generated for those method implementations along L3/L2 -> L1 -> C and does not supply a hidden static-data mirror of the graph. The translator is written in L2 and L3, and the L1 inserts are removed in the end too.

`sys\fromLmx` parses the saved graph through shared construction code and interns names in the receiving arena. Restoring a clean graph after restart on the same platform does not require retranslating the whole program. Saved native descriptors bind to ready binary modules and entry names for the corresponding ABI; old machine addresses are not copied. L1/C paths remain ordinary data but do not replace a binary-module and entry reference. The capacity table is rebuilt from allocated storage, for example capacity = length; prior reserve need not be saved. This is an implementation requirement, not a claim that the present graph dumper is complete.
@@ memory | Владение, достижимость и срок жизни | Ownership, reachability and lifetime | 19.29.0–19.29.5; 19.29.8–19.29.14
[RU]
Каждый Message, исполняющийся или нет, владеет одной логической ареной изменяемых данных. Арена может включать несколько непересекающихся областей; это не дополнительные арены исходного языка. Вызов, блок, обработчик, ветвление и повторная попытка не создают своих семантических арен. L3 не выбирает арену аргументом операции.

Лексическая вложенность, владение памятью и достижимость — разные отношения. В одной арене может быть несколько лексических деревьев. При передаче владения блоками их адреса и `parent` сохраняются; новый владелец не становится автоматически лексическим родителем и не получает неявную прикладную ссылку на каждый принятый объект.

Живость определяется достижимостью, не членством в списке блоков. Корни включают корень Message, активные структурные аргументы, удерживаемые собственные поля, результаты, ссылки формальных и динамических входов, продолжения и явно сохранённые прикладные/служебные ссылки. Обход следует типизированным рёбрам графа, необходимым родителям, связи массива с backing и ссылочным элементам. Вспомогательный индекс имён не является корнем.

Живые узлы и дескрипторы не перемещаются только потому, что хранилище растёт. Явное присваивание графа может заменить фрагмент, выбранный структурной ячейкой; старая ссылка на вытесненный фрагмент автоматически не становится ссылкой на его замену. Устойчивость дескрипторов и ссылки Array в L3 на основе дескриптора и индекса сохраняют собственные контракты. Лексический выход не уничтожает достижимый возвращаемый объект; возврат не требует скрытого копирования или продвижения в дерево. Однако устойчивый адрес не гарантирует неограниченного срока жизни недостижимого объекта.

В конце каждого такта выполняется один локальный проход сбора: определить исход такта, опубликовать успешные исходящие сообщения либо отбросить неуспешную подготовку, отпустить завершённые входные/временные корни, собрать арену владельца. Обычный возврат, `break`, `continue`, `retry`, `redo` и пойманный `throw` не являются отдельными точками сбора. Сохранившееся приостановленное продолжение удерживает свои ссылки.

Принятый граф, на который приложение не сохранило ссылок, после снятия временных корней может быть собран уже в конце такта, кроме лексически объявленных ветвей `independent: immutable` (с `const` или без него): их владелец сохраняет до удаления всей арены (§23). Передача арены не превращает прочий граф в вечный корень. Удерживаемая история отказа живёт по своей явной политике. Уничтожение Message в итоге освобождает его оставшееся хранилище; сбор не обходит чужую изменяемую арену и не требует глобальной блокировки.

Внешний ресурс имеет отдельный контракт владения, удержания, освобождения и передачи. `copy`, сериализация и `merge` не придумывают дублирование нативного ресурса. Неизменяемость его идентификатора не продлевает жизнь ресурса. Физический сборщик и выделение записей арены описаны в [L2](L2_spec_ru.md#arena).
[EN]
Every Message, executing or not, owns one logical arena of mutable data. It can contain multiple disjoint regions; these are not additional source-level arenas. Calls, blocks, handlers, branches and retries do not create their own semantic arenas. L3 does not select an arena through an operation argument.

Lexical nesting, storage ownership and reachability are distinct relationships. One arena may contain multiple lexical trees. Transferring block ownership preserves addresses and `parent`; the new owner neither becomes the lexical parent automatically nor gains an implicit application reference to every adopted object.

Liveness follows reachability, not block-list membership. Roots include the Message root, active structural arguments, retained own fields, results, formal/dynamic input references, continuations and explicitly retained application/service references. Tracing follows typed graph edges, necessary parents, Array-to-backing links and reference-valued elements. The auxiliary name index is not a root.

Live nodes and descriptors do not move merely because storage grows. Explicit graph assignment can replace the fragment selected by a structural cell; an old reference to the displaced fragment is not automatically a reference to its replacement. Descriptor stability and L3 descriptor-plus-index Array references retain their own contracts. Lexical exit does not destroy a reachable returned object; return requires no hidden copy or tree promotion. A stable address, however, does not guarantee indefinite life for an unreachable object.

One local collection pass runs at each end-of-turn: determine the outcome, publish successful outgoing Messages or discard failed staging, release completed input/temporary roots, and collect the owner's arena. Ordinary return, `break`, `continue`, `retry`, `redo` and caught `throw` are not separate collection points. A surviving suspended continuation retains its references.

An adopted graph with no application-retained references can be collected at end-of-turn once temporary roots are released, except for lexically declared `independent: immutable` branches (with or without `const`): their owner retains them until the entire arena is destroyed (§23). Arena transfer does not make other graphs permanent roots. Retained failure history lives under its explicit policy. Destroying a Message ultimately releases its remaining storage; collection neither scans another mutable arena nor requires a global lock.

A foreign resource has a separate ownership, retention, release and transfer contract. `copy`, serialization and `merge` do not invent native-resource duplication. Immutability of its identifier does not extend resource lifetime. The physical collector and the allocation of an arena's records are described in [L2](L2_spec_en.md#arena).
@@ eternal | Вечные ветви и общие методы | Eternal branches and shared methods | 9.1.4; 19.29.6; 19.29.9
[RU]
Совместная квалификация `independent: immutable` задаёт запечатанную неизменяемую независимую ветвь: у её корня `parent = 0`, содержимое и защищённые привязки неизменяемы. `const` можно добавить, но для сохранения адреса при `merge` и срока жизни до удаления арены он не требуется. Такая ветвь может быть лексически объявлена и внутри обычного тела, не только в корне Message. Владелец удерживает каждое её созданное вхождение до уничтожения всей своей арены, даже если обычный окружающий граф позже перестал на него ссылаться. Для начального лексически известного модуля владение ареной R0 даёт срок хранения до завершения процесса. Сама квалификация не выбирает глобального владельца и не определяет выгрузку будущего модуля. Ни одна из двух квалификаций отдельно не даёт этого контракта общего использования.

Начальная сборка процесса может создать известный трансляции неизменяемый типизированный массив физических ссылок на такие ветви и явно передать его корневому Message. Этот массив служит доступу и передаче известных ссылок, а не является условием удержания всех лексически объявленных ветвей в их арене. `merge` и создание Message не пополняют и не наследуют этот массив автоматически. Размещение ссылки в массиве не переподчиняет лексическое дерево ветви. Допустимая инициализация значениями времени выполнения происходит до публикации и не увеличивает множество записей.

Начальная сборка может разместить опубликованные ветви и их запечатанные записи в арене Root Thread (`R0`) тем же способом, которым типизированные массивы создаются в арене любого L3 Thread. Срок процесса получается из явного владения и удержания R0, а не из скрытой таблицы, особого класса хранилища или способности, доступной только корню. Сборщик не освобождает эти явно удерживаемые начальные диапазоны; ссылка на ветвь в другом Message является внешним терминалом для его сборщика и не переносит владение.

Принадлежность значения типу вечной ветви устанавливается так же, как принадлежность другим физическим типам: кодом в записи значения. Её запечатанный диапазон остаётся в обычной арене явного владельца; срок жизни задают удержание владельцем до уничтожения арены и запрет преждевременного сбора, а не отдельное постоянное хранилище. Перед переносом Message к новому надзирающему родителю проверяется иерархия Message: владелец каждой ветви `independent: immutable`, используемой переносимым Message или его потомками, должен остаться соответствующим Message либо одним из его новых Message-предков. Если владелец выпадет из этой цепи, перенос отказывается **до** изменения членства и ссылки на родителя: прежняя цепочка взаимного контроля больше не гарантировала бы существование арены владельца на протяжении жизни перенесённого Message. Перенос, сохраняющий это условие, не запрещается лишь из-за существования ветви. Здесь речь о надзирающем `Thread.parent` и сроке жизни арен, а не о структурном `Lmx.parent`, языковом `node` или лексической видимости имён. Эти правила не заменяют код типа в записи и не являются флагом отдельной ветви.

Переподчинение имеет явную форму `adopt: msg newParent`: `msg` — переносимый Message с исполняющим Thread, `newParent` — новый надзирающий Message с Thread. Оно не копирует ветви и не маскирует отказ. Если предварительная проверка владельцев не проходит, операция даёт обычный неявный отказ `adopt`, который принимает `catch: adopt ()`; до отказа ни членство в `Thread.children`, ни `Thread.parent` не меняются. Подготовка `independent: msg newParent` — отдельная явная операция: она копирует в арену `msg` только те фактически используемые им или его потомками вечные ветви, владельцы которых не остались бы в новой цепи предков, и перенаправляет соответствующие ссылки на копии. Она не переподчиняет Message. Копии сохраняют свойства `independent: immutable`, а общие ссылки и циклы сохраняются одной картой исходных адресов к копиям; частичная публикация при ошибке запрещена. Ветви, не мешающие именно этому переносу, остаются по прежним адресам. После подготовки `adopt: msg newParent` проходит обычную предварительную проверку заново. При неудаче подготовки действует обычный неявный отказ `independent`, без изменения опубликованного графа.

Известные записи методов — переиспользуемые нативные реализации, не вызываемые вхождения — также могут быть явно собраны в неизменяемый типизированный массив той же арены и переданы через физические ссылки. Дополнительный индекс вместе со ссылкой не образует идентичность записи. Метод не хранит лексического родителя; его конкретное вызываемое вхождение предоставляет собственную структуру. Разделяемые записи остаются живы после завершения заимствующего дочернего Message, только если их явный владелец продолжает их удерживать. Скрытого глобального или корневого реестра методов нет.

R0 удерживает неизменяемые независимые ветви начального модуля только потому, что владеет этим лексически фиксированным модулем, порождает начальных детей и может явно передать им заранее известные физические ссылки. Позднее подключённый DLL-подобный модуль имеет собственные запечатанные записи у своего владельца и в своей арене. Когда `merge` встречает его `independent: immutable` ветвь, с `const` или без него, потребитель получает в результате исходную физическую ссылку, а модуль остаётся владельцем. Это не превращает R0 в глобальное хранилище. Выгрузка такого модуля и срок жизни его диапазонов здесь не определены.

`merge` и создание Message сохраняют явно переданные ссылки на допущенные вечные ветви — по исключению квалифицированной ветви ([композиция](#composition)) — и на переиспользуемые нативные реализации методов как терминалы; обычное изменяемое вызываемое вхождение и его лексический контекст этим не разделяются, а копируются. Получение одной ветви не раскрывает массив удержания, настройки корня или остальные ветви. Изменяемое состояние по-прежнему копируется отдельно. Все ссылки внутри опубликованной вечной ветви должны иметь достаточный срок жизни; квалификация не делает случайную ссылку на освобождаемую память вечной.

Например, A и созданный из его шаблона B могут иметь один адрес вечной E и разные ячейки изменяемого x — это задуманное исключение для вечной ветви, а не ошибка псевдонимов. Завершение A и B не освобождает E. Одинаковое содержимое двух отдельно построенных ветвей не означает их автоматического интернирования. При переносе в другой процесс нативный адрес не становится сетевой идентичностью: нужен явный кодек.
[EN]
Combined qualification `independent: immutable` establishes a sealed immutable independent branch: its root has `parent = 0`, and its contents and protected bindings are immutable. `const` may be added but is not required for address retention by `merge` or lifetime until arena destruction. Such a branch may be lexically declared inside an ordinary body, not only at a Message root. Its owner retains every created occurrence until the entire owning arena is destroyed, even if the ordinary surrounding graph later ceases to reference it. For the initial lexically known module, R0's ownership of that arena gives process-long storage. The qualification itself neither selects a global owner nor defines unloading of a future module. Neither of the two qualifications alone establishes this sharing contract.

Process bootstrap may construct a translation-known immutable typed Array of physical references to such branches and explicitly supply it to the root Message. This Array provides access to and transfer of known references; inclusion in it is not required for retention of every lexically declared branch in its arena. `merge` and Message creation neither append to nor inherit this Array automatically. Placement in the Array does not reparent a branch's lexical tree. Permitted runtime-value initialization occurs before publication without increasing the entry set.

Bootstrap may place the published branches and their sealed records in the Root Thread's (`R0`) arena through the same mechanism that creates typed Arrays in any L3 Thread arena. Process lifetime follows from explicit ownership and retention by R0, not from a hidden table, special storage class, or root-only capability. Collection does not release these explicitly retained initial ranges; a reference to a branch in another Message is an external terminal for that Message's collector and does not transfer ownership.

Membership in the eternal-branch type is established as for all other physical types: by the code in the value's record. Its sealed range remains in the explicit owner's ordinary arena; retention until arena destruction and exclusion from premature collection determine its lifetime, not a separate permanent store. Before moving a Message under a new supervising parent, check the Message hierarchy: the owner of every `independent: immutable` branch used by the moved Message or its descendants must remain the corresponding Message itself or one of its new Message ancestors. If an owner would leave that chain, refuse the move **before** changing membership or the parent reference: the former chain of mutual control would no longer guarantee the owner's arena throughout the moved Message's lifetime. A move preserving this condition is not forbidden merely because such a branch exists. This concerns supervising `Thread.parent` and arena lifetime, not structural `Lmx.parent`, the language's `node`, or lexical name visibility. These rules neither replace the type code of the record nor become a flag on each branch.

Reparenting has the explicit form `adopt: msg newParent`: `msg` is the moved Message with an executing Thread, and `newParent` is the new supervising Message with a Thread. It copies no branches and does not mask refusal. If the owner preflight fails, the operation raises the ordinary implicit failure `adopt`, handled by `catch: adopt ()`; neither `Thread.children` membership nor `Thread.parent` changes before that refusal. `independent: msg newParent` is a separate, explicit preparation: it copies into `msg`'s arena only the eternal branches actually used by it or its descendants whose owners would leave the new ancestor chain, and redirects the corresponding references to the copies. It does not reparent the Message. The copies retain `independent: immutable` properties, shared references and cycles follow one source-to-copy map, and partial publication on failure is forbidden. Branches that do not obstruct this particular move retain their old addresses. After preparation, `adopt: msg newParent` performs its ordinary preflight anew. Preparation failure raises the ordinary implicit failure `independent` without changing the published graph.

Known method records -- reusable native implementations, not callable occurrences -- may likewise be assembled explicitly into an immutable typed Array in the same arena and supplied through physical references. A supplementary index alongside the reference does not form record identity. A method stores no lexical parent; its concrete callable occurrence supplies its own Structure. Shared records remain live after a borrowing child Message terminates only while their explicit owner retains them. There is no hidden global or root method registry.

R0 retains immutable independent branches of the initial module only because it owns that lexically fixed module, spawns the initial children, and can explicitly pass their translation-known physical references. A DLL-like module loaded later has its own sealed records under its own owner and in its own arena. When `merge` encounters its `independent: immutable` branch, with or without `const`, the consumer receives the original physical reference in the result and the module remains the owner. This does not make R0 global storage. This specification does not yet define that module's unload operation or the lifetime of those ranges.

`merge` and Message creation retain explicitly supplied references to admitted eternal branches -- under the qualified-branch exception ([composition](#composition)) -- and to reusable native method implementations as terminals; an ordinary mutable callable occurrence and its lexical context are not shared this way but copied. Receiving one branch does not expose its retention Array, root settings or unrelated branches. Mutable state is still copied separately. Every reference within a published eternal branch must have sufficient lifetime; qualification does not make an arbitrary reference to reclaimable storage eternal.

For example, A and B constructed from A's template can have the same eternal E address and distinct mutable x cells -- the intended eternal-branch exception, not an aliasing defect. Finishing A and B does not release E. Equal contents of separately constructed branches do not imply automatic interning. Across processes a native address is not wire identity: an explicit codec is required.
@@ messages | Message, актор и последовательный такт | Message, actor and serial turn | 19.28.R2.1–19.28.R2.3; 19.29.6
[RU]
Message — изолированный граф с собственным владением. Обычный шаблон или письмо не исполняется и может существовать как самостоятельный минимальный `LmxMsg`. Исполняемый объект, напротив, изначально строится как L3 Thread. Его `LmxMsg message` является первым членом по значению, поэтому Thread и его Message-префикс имеют один физический адрес. Этот общий префикс предоставляет только идентичность и операции Message: он не превращает каждый Message в Thread и не помещает почту, планирование, режим хода либо другие механизмы Thread в `LmxMsg`. Самостоятельный Message нельзя позднее преобразовать на месте в Thread. Код типа записи различает отдельное хранилище Message и хранилище Thread: общий вид Message допускает оба, а доступ к хвосту Thread требует точного типа Thread. Получение письма не создаёт автоматически новый поток или актор. Для запуска отдельного ребёнка нужна явная операция.

При создании `lmx_message` или `lmx_thread` в его собственную арену попадают только данные и физические ссылки, явно переданные создающей операцией. Состояние родителя, таблицы начальной сборки, массивы методов, вечные ветви и ссылки на сервисы не копируются и не наследуются неявно. Обычный L3 Thread может хранить и использовать всё доступное R0, если эти значения переданы ему явно.

Исполняющийся Message имеет FIFO-почту и не более одного активного такта одновременно. За такт потребляется не более одного допущенного входа. Между разными Message возможна параллельность. Пустой ящик не означает завершение фоновой задачи: механизм продолжает проверять почту согласно своему режиму исполнения до условия остановки.

Во время такта один L3 Message исполняется ровно одним потоком ОС; передача другому рабочему потоку возможна только между тактами. У L3 Thread нет режима исполнения: путь каждого вызова определяет дескриптор вызываемого вхождения — с нативным адресом вызов исполняется нативно, без адреса тело (op-дерево графа) исполняет интерпретатор — код L2 с теми же проверками, что и код L3 ([§1](#scope)). Один вызов не запускает оба пути для одного Message: диспетчер не повторяет вызов другим путём после ошибки и не подменяет путь, заданный дескриптором, ни по телу, ни по результату предыдущей диспетчеризации. Выбор пути не создаёт копию метода или второй параллельный исполнитель; `implements` и другие принимающие выражения диспетчер сам не запускает.

Одна арена имеет одну полосу записи. Обработчик, локальное управление, планировщик и служебные данные Message изменяются на его полосе. Чужой отправитель не дописывает себя в ready-list владельца и не меняет его прикладные данные. Исключение приёма почты и специальные одноячеечные протоколы управления относятся к механизму Message, не дают общего доступа к чужой памяти.

Родитель управляет только своими непосредственными детьми. Единственный состав — обычный Array ссылок переменной длины, удерживаемый полем `Thread.children` в арене родителя; планировщик родителя обходит именно этот Array ([L2 §8](L2_spec_ru.md#thread)). Это runtime-членство не дописывает полей в исходную Structure. Цепочка семейных записей, очередь членства менеджера, фиксированный набор элементов или иной параллельный реестр детей запрещены. Локальная политика порядка обхода принадлежит родителю, но не создаёт второй источник членства. Ребёнок аналогично управляет своими детьми. Нет отдельного глобального планировщика языка, общего изменяемого реестра Message или глобальной блокировки управления. Маршрутизатор, если нужен, сам является Message с собственным состоянием.

R0 является обычным L3 Thread в этом дереве и по умолчанию не имеет функций, которых нет у другого L3 Thread. Его родитель-каркас представляет верхний элемент будущего WorldWideMix и связывается с R0 обычным механизмом родителя; это надзор Message, а не лексическая связь `node`. Только сам верхний каркас не имеет родителя, но дополнительных функций от этого не получает. Внешний host-watchdog, а не каркас или R0, задаёт общий срок ожидания закрытия поддерева и завершает процесс ОС, если обычный каскад не достиг безопасной границы. Особого массива детей, иной схемы планирования или числовой идентичности для R0 нет.

L3 Thread — логическая последовательная полоса, не обещание отдельного потока ОС. Возможны собственный поток и выполнение тактов родителем/платформенным адаптером. API и политика отображения задаются реализацией L2; это не разрешает одновременно выполнять два такта одного владельца. Опрос жизнеспособности родителя и собственное обслуживание нужны и актору без детей.

Первоначальный граф процесса принадлежит корневому Message. Служебные данные запуска и начальные настройки удерживаются уже определённым родителем-заглушкой R0; ссылки на настройки и пользовательский ввод передаются явно при входе, без добавления неявных полей в исходный граф программы; последующая координация выполняется сообщениями. Группировка ролей Mix, курсоров, страниц и уведомлений по Message остаётся выбором проектирования: не требуется ни один актор на весь документ, ни отдельный актор на каждую ячейку.
[EN]
A Message is an isolated graph with its own ownership. A plain template or letter is non-executable and may exist as a standalone minimal `LmxMsg`. An executable object is instead constructed as an L3 Thread from the beginning. Its `LmxMsg message` is the first member by value, so the Thread and its Message prefix have the same physical address. This common prefix supplies Message identity and operations only; it does not turn every Message into a Thread or put mail, scheduling, turn mode, or other Thread mechanisms into `LmxMsg`. A standalone Message cannot later be upgraded in place to a Thread. The type code of the record distinguishes standalone Message storage from Thread storage: the generic Message kind admits both, whereas access to the Thread-only tail requires the exact Thread type. Receiving a letter does not automatically create a thread or actor. Launching a separate child requires an explicit operation.

Creating an `lmx_message` or `lmx_thread` places in its own arena only the data and physical references explicitly supplied by the creating operation. Parent state, bootstrap tables, method Arrays, eternal branches, and service references are neither copied nor inherited implicitly. An ordinary L3 Thread can retain and use everything available to R0 when those values are supplied explicitly.

An executing Message has FIFO mail and at most one active turn at a time. A turn consumes at most one admitted input. Different Messages may execute concurrently. An empty mailbox does not finish a background task: its mechanism keeps checking mail according to its execution mode until a stopping condition.

During a turn, one L3 Message executes on exactly one OS thread; transfer to another worker is allowed only between turns. An L3 Thread has no execution mode: each call's path is set by the callable occurrence's descriptor -- with a native address the call executes natively, without one the body (the graph's op tree) is executed by the interpreter -- L2 code with the same checks as L3 code ([§1](#scope)). One call never runs both paths for one Message: the dispatcher does not retry a call through the other path after a failure and does not override the path set by the descriptor from the body or from a previous dispatch result. Choosing the path neither copies the method nor creates a second concurrent executor; the dispatcher never runs `implements` or other receiving expressions on its own.

One arena has one writing lane. A Message's handler, local management, scheduler and service state are mutated on its own lane. A foreign sender neither appends itself to the owner's ready list nor modifies its application data. Mail admission and designated single-cell control protocols belong to the Message mechanism and grant no general access to foreign memory.

A parent manages only its direct children. Sole membership is the ordinary variable-length reference Array held by `Thread.children` in the parent's arena, and the parent's scheduler traverses that exact Array ([L2 §8](L2_spec_en.md#thread)). This runtime membership does not append fields to the source Structure. A family-record chain, manager membership queue, fixed group of slots, or any other parallel child registry is forbidden. Local traversal-order policy belongs to the parent but does not become a second membership source. Each child likewise manages its own children. There is no separate global language scheduler, shared mutable Message registry, or global management lock. A router, if needed, is itself a Message with private state.

R0 is an ordinary L3 Thread in this tree and has no functions unavailable to another L3 Thread by default. Its parent frame represents the upper element of the future WorldWideMix and connects to R0 through the ordinary parent mechanism; this is Message supervision, not a lexical `node` link. Only the upper frame itself has no parent, but that grants it no additional functions. An external host watchdog, not the frame or R0, applies the overall subtree-close deadline and terminates the OS process if the ordinary cascade cannot reach a safe boundary. R0 has no special child Array, alternate scheduling scheme, or numeric identity.

An L3 Thread is a logical serial lane, not a promise of a dedicated OS thread. Both a dedicated thread and parent/platform-driven turns are possible. L2 implementation defines the API and mapping policy; this does not permit two simultaneous turns of one owner. Parent-liveness polling and self-maintenance are needed even by a childless actor.

The process's initial graph belongs to the root Message. Launch service data and initial settings are held by the already defined R0 parent stub; settings references and user input are passed explicitly at entry, without adding implicit fields to the program's source graph; subsequent coordination uses Messages. Grouping Mix roles, cursors, pages and notifications into Messages remains a design choice: neither one actor for the whole document nor a separate actor for every cell is required.
@@ delivery | Доставка, владение и порядок изменений | Delivery, ownership and mutation order | 19.19; 19.28.R2.4–19.28.R2.5; 19.29.6–19.29.7
[RU]
Локальный промежуточный уровень адресует участников физическими адресами памяти в рамках допускаемых операций механизма Message. Иерархическая цепочка индексов относится к [WorldWideMix](#worldwide), начиная с третьего масштаба организации, а не к каждому локальному письму. Масштаб организации не следует смешивать с профилем языка L3. Нативный адрес не сериализуется как переносимый адрес другой машины.

Каждый L3 Thread владеет собственным почтовым ящиком и его API. Явно переданный родителем сервис доставки разрешает адрес и доставляет письмо к операции приёма целевого ящика; он не смотрит и не читает содержимое ящика. Сервис доставки не исполняет получателя, не планирует его такты и не ведёт реестр членства детей.

Доставка существующего неисполняющегося Message может передавать владение его хранилищем получателю без перемещения данных. Блоки и классификация областей переходят в единую арену получателя, бывший владелец больше не освобождает их. Лексические связи остаются прежними; прикладное включение принятого корня выполняется явно. Передача хранилища не равна созданию копии и не сохраняет отправленный объект как второго независимого владельца.

Создание нового исполняющегося Message из шаблона использует [копирование графа](#composition) и его отдельную арену. Обычные настройки копируются, допущенные вечные ссылки сохраняются — по тому же исключению квалифицированной ветви, что у [`merge`](#composition); отдельной политики копирования для Message нет. Создание не импортирует неявно всё живое окружение родителя. Передача надзора над работающим ребёнком, передача остановленного хранилища и сериализация удалённого сообщения — три разных контракта.

Одновременные поступления не имеют заранее заданного относительного порядка. Приём в ящик устанавливает FIFO-порядок, который сохраняется при потреблении. Ни случайное перемешивание, ни порядок по часам отправителей не являются правилом. Проверка пустоты и ожидание согласованы с приёмом: уже принятое письмо не должно потеряться при переходе получателя в ожидание. Вместимость, обратное давление и повторная доставка — явные политики реализации/протокола.

Несколько отправителей изменяют один объект, посылая полную операцию владельцу. Например, `add(2)` и `add(5)` при начальном 0 дают 7 в любом из двух порядков приёма. Раздельные `read` и `write` не образуют одной защищённой операции: два отправителя могут прочесть 10 и оба записать 11. Последовательные такты предотвращают перекрытие исполнения, не создают транзакционный откат или защиту разорванного протокола.

Успех доставки означает принятие, не выполнение прикладного изменения. Для результата нужна предусмотренная протоколом корреляция ответа. Ядро не добавляет автоматически историю последних идентификаторов и подавление повторов каждого отправителя. Требования дедупликации, повторов, пакетирования и сортировки выражаются отдельным протоколом, не меняющим базовый FIFO.

Исходящие письма текущего такта подготавливаются отдельно от опубликованной очереди. Успешная граница публикует их в порядке подготовки; неуспешная отбрасывает неопубликованное. Уже выполненные изменения графа этим не откатываются. Граница [сбора](#memory) наступает после обработки результата и временных корней.
[EN]
The local intermediate organization level addresses participants by physical memory addresses within admitted Message-mechanism operations. Hierarchical index chains belong to [WorldWideMix](#worldwide), starting at the third organization scale, not to every local letter. Organization scale must not be confused with language profile L3. A native address is not serialized as a portable address on another machine.

Each L3 Thread owns its mailbox and mail API. A delivery service explicitly supplied by the parent resolves an address and delivers a letter to the destination mailbox's admission operation; it neither observes nor reads mailbox contents. The delivery service does not execute the recipient, schedule its turns, or maintain a child-membership registry.

Delivery of an existing non-executing Message can transfer its storage ownership to the receiver without moving data. Blocks and region classification join the receiver's single arena; the former owner no longer releases them. Lexical links remain unchanged; application attachment of the received root is explicit. Storage transfer is not copying and does not retain the sent object as a second independent owner.

Creating a new executing Message from a template uses [graph copying](#composition) and a separate arena. Ordinary settings are copied; admitted eternal references are retained -- under the same qualified-branch exception as in [`merge`](#composition); there is no second, Message-specific copying policy. Creation does not implicitly import the parent's entire live context. Handing off supervision of a running child, transferring stopped storage and serializing a remote Message are three different contracts.

Concurrent arrivals have no predetermined relative order. Mailbox admission establishes FIFO order, preserved by consumption. Neither random shuffling nor sender-clock order is required. Empty-check/wait coordinates with admission: an accepted letter must not disappear as the receiver begins waiting. Capacity, backpressure and redelivery are explicit implementation/protocol policies.

Multiple senders mutate one object by sending its owner a complete operation. For example, `add(2)` and `add(5)` from initial 0 produce 7 in either admission order. Separate `read` and `write` requests are not one protected operation: two senders may both read 10 and write 11. Serial turns prevent overlapping execution but establish neither transaction rollback nor protection for a split protocol.

Delivery success means admission, not application of a requested change. A result requires protocol-defined reply correlation. The core does not automatically retain per-sender last identifiers or suppress duplicates. Deduplication, retry, batching and sorting requirements belong to explicit protocols without changing base FIFO.

Current-turn outgoing letters are staged separately from the published queue. A successful boundary publishes them in staging order; failure discards unpublished staging. This does not undo graph mutations already performed. The [collection boundary](#memory) follows outcome and temporary-root processing.
@@ lifecycle | Завершение, дети и сохранение результата отказа | Completion, children and retained failure state | 19.28.R2.2–3; 19.29.6–19.29.8
[RU]
`success` исполняемого Message ставит только пользовательский код: система никогда не сбрасывает его в 0, даже при ошибке, и не ставит 1 сама; `success = 1` — достаточное условие остановки Thread на end turn. Система ставит `success = 1` только простому письму при его доставке. Пустой ящик успехом не является. После установки `success` основной алгоритм Message не получает следующий такт; завершение локального обслуживания детей зависит от реализации. `running = 0` во время работы может быть запросом остановки: физическая безопасность передачи хранилища устанавливается отдельным протоколом, не угадывается по одному флагу.

Ребёнок проверяет жизнеспособность родителя и после длительного отсутствия ответа начинает собственное упорядоченное закрытие. Принудительное закрытие сверху — аварийный второй путь. Родитель обслуживает физических адресатов из единственного Array ссылок своих прямых детей, удерживаемого `Thread.children` и не выполняет произвольное управление внуками. Каждый ребёнок повторяет каскад для собственного Array детей; закрытие распространяется по семейству, а не сохраняет навсегда освобождённую ветвь.

Работающий ребёнок может пережить закрытие родителя только при явной передаче надзора другому живому родителю с подходящим полномочием. Он сохраняет свою арену, почту и такт; меняется надзор и место в планировании. Это не усыновление памяти. При передаче памяти неисполняющийся источник прекращает отдельную жизнь; новые дети из принятого содержимого принадлежат уже получателю.

Неуспешное остановленное состояние может быть передано родителю без копии и удержано как граф истории отказа; успешная история по умолчанию освобождается. Передача требует остановленного, безопасного для передачи состояния и отсутствия нативных пользователей. Необходимо сохранять различие запроса остановки, фактического выхода, безопасной передачи и освобождения; конкретные флаги и их размещение относятся к [ядру L2](L2_spec_ru.md#message).

Оставшийся без родителя участник закрывается по политике сирот: успешное завершение освобождает его, неуспешная история может сохраняться до явно заданного срока. Эта политика не создаёт второй глобальный реестр или отдельного бессрочного владельца вне Message.
[EN]
An executing Message's `success` is set only by user code: the system never resets it to 0, not even on failure, and never sets it to 1 itself; `success = 1` is a sufficient condition for stopping the Thread at end turn. The system sets `success = 1` only for a plain letter, at its delivery. An empty mailbox is not success. Once `success` is set, the Message's main algorithm receives no next turn; finishing local child maintenance depends on implementation. `running = 0` during execution may be a stop request: physical storage-handoff safety is established by a separate protocol, not inferred from one flag.

A child checks parent liveness and begins its own orderly close after sustained lack of response. Forced closure from above is the second, emergency path. A parent services physical addressees from the sole reference Array of its direct children held by `Thread.children` rather than arbitrarily managing grandchildren. Each child repeats the cascade for its own child Array; closing propagates through the family instead of retaining a released branch forever.

A running child can survive parent closure only through explicit supervision handoff to another live parent with suitable authority. It retains its arena, mail and turn; supervision and scheduling placement change. This is not storage adoption. Storage transfer ends the non-executing source's separate life; new children created from adopted content belong to the receiver.

Stopped failed state may be transferred to the parent without copying and retained as failure-history graph; successful history is reclaimed by default. Transfer requires a stopped, handoff-safe source with no native users. Stop request, actual exit, safe transfer and release must remain distinct; concrete flags and placement belong to the [L2 kernel](L2_spec_en.md#message).

A participant that loses its parent closes under an orphan policy: successful completion releases it, while failure history may remain until an explicit deadline. This policy creates neither a second global registry nor an indefinite owner outside Messages.
@@ pipeline | Допуск и исполнение входящего сообщения | Incoming-message admission and execution | 19.19; 19.22; 19.28.R2.4; 19.31
[RU]
Входящие данные проходят явный декодер и становятся графом Message. Затем выбираются адресат, маршрут и принимающее выражение через заданные ссылки или поиск от заданного корня. Ни текст сообщения, ни ссылка на таблицу не устанавливают скрытое окружение и не дают автоматического доверия.

Допуск кандидата следует [единому механизму](#admission): проверка структурной пригодности для фактических вызовов Consumer, затем требуемые аналитические проверки принимающего выражения, `test`. Этот этап входящего допуска работает над построенным графом через общий механизм исполнения. Валидация под управлением интерпретатора не переводит на walker каждое проверяющее выражение, кандидата или вспомогательный вызов: каждый достигнутый вызов сохраняет обычную диспетчеризацию native/walker и те же контракты связывания, приёма и отказа. Декодирование текста строит входной граф до этого этапа; допуск не интерпретирует исходный текст вместо графа.

Маршрут, полномочия, срок жизни и допустимые эффекты представлены явными данными контракта. Проверки свойств кандидата включаются в тесты принимающего выражения; криптографические операции могут предоставить проверяемые факты. Свидетельство хранит ссылку на конкретные данные, политику и установленные на входе факты. Повторное использование результата допустимо только по явному контракту применимости из [валидации кандидата](#graph-tests).

После допуска выбирается явная ссылка на реализацию/провайдер и строится план исполнения с аргументами, результатами и необходимыми политиками. Формирование плана не исполняет выбранную прикладную операцию, хотя этап допуска уже исполнял её тесты. Исполнитель следует зафиксированной ссылке. Результат или объявленный отказ становится входом следующего явного потребителя.

Логический генератор может построить ноль или несколько предложенных Message. Каждый снова проходит тот же путь; происхождение от генератора не даёт доверия. Полученный текст не переносит работающий кадр чужого актора. Работа выполняется в последовательном такте получателя, если отдельный запуск ребёнка не указан явно.
[EN]
Incoming data pass through an explicit decoder to become a Message graph. The destination, route and receiving expression are then selected through supplied references or lookup from a supplied root. Neither Message text nor a Table reference installs a hidden environment or grants automatic trust.

Candidate admission follows the [unified mechanism](#admission): checking structural suitability for actual Consumer calls, followed by the receiving expression's required analytical checks, `test`. This incoming-admission stage operates on the constructed graph through the common execution mechanism. Interpreter-led validation does not force every checking-expression, candidate or helper call onto the walker: each reached call retains ordinary native/walker dispatch and the same binding, reception and failure contracts. Text decoding constructs the input graph before this stage; admission does not interpret source text instead of the graph.

Routes, authority, lifetime and permitted effects are explicit contract data. Candidate-property checks belong to receiving-expression tests; cryptographic operations may supply verifiable facts. Evidence references exact data, policy and authenticated ingress facts. A result may be reused only under the explicit applicability contract in [candidate validation](#graph-tests).

After admission, an explicit implementation/provider reference is selected and an execution plan is built with arguments, results and required policies. Planning does not execute the chosen application operation, although admission already executed its tests. The executor follows the retained reference. A result or declared failure becomes input to the next explicit consumer.

A logical generator may construct zero or more proposed Messages. Each re-enters the same path; generator origin confers no trust. Received text does not transfer another actor's running frame. Work executes in the receiver's serial turn unless a separate child launch is explicit.
@@ thread-message-api | Обычные вызовы LMX через Message-транспорт: `post` и ожидания ответов | Ordinary LMX calls over Message transport: `post` and reply waits | docs/new_parts; author 2026-09-26
[RU]
`post` — обычный ресивер описания обмена через существующий Message-транспорт, а не вторая машина вызова. Ветвь `ask` содержит явно адресованные обычные вызовы LMX; `answer` — назначения их результатов; `timeout` — отдельную настройку ожидания; `undelivered`, `unanswered` и `catch` — соответствующие обработчики. Всё описание, включая стоящие ниже ветви, связывается **до** выпуска запросов. Транспорт не создаёт экспортируемый словарь методов, не перебирает методы адресата и не вводит собственных правил выбора callable, аргументов, результатов или `throws`.

Каждый `ask` исполняет выбранный callable один раз. Один исходный результат распределяется по всем явно подготовленным для него назначениям `answer`; каждый адресат затем совершает собственный обычный вызов LMX. Строки `ask` и `answer` не сопоставляются по позиции. Несколько запросов дают независимые исходные исполнения и ответы, даже если результаты размножаются по одним назначениям. Вызов без результата не создаёт синтетический ответ или пользовательский ACK. Группировка не вводит join-барьер, транзакцию либо автоматический повтор.

### Ожидание, допуск и маршрутизация

Ожидания принадлежат отправителю и хранятся отдельно от callable-API адресата и его ящика. Каждое ожидание связано с исходным Message и подготовленными назначениями; одновременные экземпляры одного `post` различаются по исходным сообщениям, не по исходному имени. Сформированные аргументы, отметка отправки и состояние доставки остаются связанными с исходным письмом. Записи обслуживаются на единственной полосе отправителя, а их ссылки подчиняются обычным правилам владения и времени жизни: завершившийся стековый кадр нельзя сохранить как окружение обработчика.

До отправки действуют те же `implements`, обязательные тесты, преобразования, сигнатуры и объявленные выходы, что при местном вызове. Каждое направление «результат исходного callable → принимающее место `answer`» допускается при подготовке, а не выбирается новым поиском слушателей при приходе результата. Зависящие от значения преобразования исполняются при действительном потреблении. Несовместимость до вызова не выдаётся за `throw` ещё не исполнявшегося метода. Контекст преобразований принадлежит конкретному Message и явно доступен по [§6](#conversion-context); обычный допуск не даёт права открыть защищённую ветвь графа.

### События и время

Недоставленный исходный запрос вызывает связанный `undelivered` с исходным адресатом и **сохранёнными сформированными аргументами**. Успешный результат коррелируется с исходным запросом и идёт по подготовленным `answer`-маршрутам. Объявленный `throw` передаёт имя и payload обычному связанному `catch`. Истечение ожидания вызывает `unanswered` с данными исходного запроса и времени. Отказ доставить уже вычисленный ответ одному назначению подчиняется правилам этой доставки и не превращает исходный успешный вызов в недоставленный запрос.

`timeout` отсчитывается от отметки **отправки исходного письма**. Его истечение само не отменяет вызов, не удаляет маршруты, не подавляет поздний ответ и не освобождает живую арену; дальнейшее решение — пользовательская политика. Письмо без контракта результата не считается неответившим лишь из-за отсутствия ответа. Наблюдение состояния доставки использует существующий почтовый API, а не новый прикладной ACK. Диагностика исходного запроса не пересчитывает его выражения-аргументы после их изменения.

### Вложенное описание и общий почтовый механизм

В данных форма `timeout: ms: int: time 500` объявляет Structure `timeout`, в ней Structure `ms`, в ней поле `time` с требованием `int` и значением 500 ([объявление места](#receiver-args-only)); путь данных — `timeout\ms\time`, без поля `int`; в коде та же запись — вызов `timeout` ([роли `data` и `code`](#data-code-roles)). Входящий формал с тем же структурным требованием проходит обычные `implements` и связывание аргументов для любой глубины вложенности, местно и через `post`. Значение `time`, переданное обработчику, отличается от настроенного `timeout\ms\time`; отдельной системы типов длительностей нет.

`post`, `send` и `receive` опираются на один ящик, одни правила публикации/владения и одну машину вызова. Публичные формы `send`/`receive` (до переименования 2026-11-10 — `sendMessage`/`receiveMessage`), отбор по адресу, получение всей доступной почты и `0` как конец итератора сохраняются. Одно письмо не потребляется дважды ручным и протокольным путём; получение письма как данных само не вызывает его содержимое. Исполнение входящего вызова идёт на полосе адресата, а `answer` и обработчики исхода — на полосе отправителя. Сохраняются оба режима Thread (с потоком ОС и без), обычный жизненный цикл до пользовательского `success := 1`, публикация последнего исходящего письма и существующие надзор/остановка; отдельный цикл входа, ящик или таймерный поток для `post` не вводятся.

[Пояснение исходов обмена](LMX_semantics_guide.ru.md#post-transport) находится рядом со спецификацией и не добавляет новых правил.
[EN]
`post` is an ordinary exchange-description receiver over the existing Message transport, not a second call engine. `ask` contains explicitly addressed ordinary LMX calls; `answer` contains their result destinations; `timeout` is a separate wait setting; `undelivered`, `unanswered`, and `catch` are the applicable handlers. The entire description, including later branches, is bound **before** requests are published. Transport creates no exported method dictionary, does not enumerate the recipient's methods, and defines no separate rules for selecting callables, arguments, results, or `throws`.

Each `ask` executes the selected callable once. One source result is distributed to every `answer` destination explicitly prepared for it; each recipient then makes its own ordinary LMX call. `ask` and `answer` rows are not matched by position. Multiple requests produce independent source executions and replies even when their results fan out to the same destinations. A no-result call creates neither a synthetic reply nor an application ACK. Grouping adds no join barrier, transaction, or automatic retry.

### Pending replies, admission, and routing

Pending replies belong to the sender and are stored separately from the recipient's callable API and inbox. Each wait is associated with its original Message and prepared destinations; concurrent instances of one `post` differ by their source messages, not a source-level name. Formed arguments, the send timestamp, and delivery state remain associated with the original letter. Entries are serviced on the sender's single execution lane, and their references obey ordinary ownership and lifetime rules: an expired stack frame cannot become a handler environment.

The same `implements`, mandatory tests, conversions, signatures, and declared exits as a local call apply before sending. Every route “source callable result → receiving `answer` place” is admitted during preparation, not selected by a new listener search when the result arrives. Value-dependent conversions execute at actual consumption. Pre-call incompatibility is not misreported as a `throw` from a method that never ran. Conversion context belongs to the concrete Message and is explicitly available under [§6](#conversion-context); ordinary admission does not authorize opening a protected graph branch.

### Events and time

An undelivered source request invokes its bound `undelivered` with the original recipient and **stored formed arguments**. A successful result is correlated with its source request and takes the prepared `answer` routes. A declared `throw` conveys its name and payload to the ordinary associated `catch`. Expiry invokes `unanswered` with the original request's data and timing. Failure to deliver an already computed answer to one destination follows that delivery's rules; it does not turn the successful source call into an undelivered request.

`timeout` starts at the **original letter's send timestamp**. Expiry alone does not cancel the call, remove routes, suppress a late reply, or release a live arena; subsequent action is user policy. A call with no result contract is not deemed unanswered merely because it produced no reply. Delivery-state inspection uses the existing mail API, not a new application ACK. Diagnostics for a source request do not reevaluate its argument expressions after they change.

### Nested descriptions and the shared mail mechanism

In data the form `timeout: ms: int: time 500` declares a Structure `timeout`, in it a Structure `ms`, in it a field `time` with requirement `int` and value 500 ([declaring a place](#receiver-args-only)); the data path is `timeout\ms\time`, with no `int` field; in code the same form is a call of `timeout` ([the roles `data` and `code`](#data-code-roles)). An incoming formal with the same structural requirement uses ordinary `implements` and argument binding at any nesting depth, locally and through `post`. Handler-supplied `time` differs from the configured `timeout\ms\time`; there is no separate duration type system.

`post`, `send`, and `receive` use one inbox, one set of publication/ownership rules, and one call engine. The public `send`/`receive` forms (`sendMessage`/`receiveMessage` before the renaming of 2026-11-10), address-filtered iterator, all-available-mail option, and `0` end marker remain. One letter cannot be consumed twice by manual and protocol paths; receiving a letter as data does not itself execute its contents. An incoming call runs on the recipient's lane, while `answer` and outcome handlers run on the sender's lane. Both Thread modes (with and without an OS thread), the ordinary lifecycle up to user `success := 1`, final outbound publication, and existing supervision/stopping remain; `post` adds no second entry loop, inbox, or timer thread.

An [explanation of exchange outcomes](LMX_semantics_guide.en.md#post-transport) is adjacent to this specification and adds no new rules.
@@ mix | Mix: активные метки и интервалы | Mix: active marks and intervals | 0.0.2
[RU]
Mix — параллельный слой меток и интервалов над позициями документа, не второе дерево разбора и не XML-подобная вложенность. Один проход исходного текста строит обычные структуры и привязывает Mix-метки. Структурные узлы, поля, строки массивов и исходные интервалы могут участвовать в пересекающихся активных множествах и без явно написанных фигурных скобок.

Форма `{…}` добавляет явно заданную структурную нагрузку метки. Её локальный разбор, строки, комментарии и привязка к исходному уровню определены в [грамматике](LMX_grammar.ru.md). Обычный структурный потребитель может игнорировать узлы с Mix-признаком; документный потребитель строит по ним активный слой. Парсер не выбирает политику конфликта атрибутов.

`{color: red}` открывает активную запись с головой `color` и именем/значением закрытия `red`. `{end}` закрывает последнюю ещё активную явную метку; `{end: red}` — последнюю активную запись с таким значением закрытия, независимо от головы. При активных `{style: red}` и затем `{color: red}` именованное закрытие снимает вторую запись, не первую.

```text
{color: red}
{color: green}
text
{end: red}
{end: green}
```

Закрытие red здесь не закрывает green. Более поздняя метка не уничтожает прежнюю: простой renderer может показывать последнее активное значение, а семантический потребитель — исследовать всю упорядоченную цепочку и пересечения. Поэтому базовая модель не является плоской таблицей «ключ — единственное значение». Незакрытая запись остаётся учтённой до границы документа/профиля и может стать интервалом, состоянием или диагностикой согласно контракту.

Три роли Mix различаются: слой исходных меток, дерево размещения документа и исполнение взаимодействующих Message. Интервал, ячейка размещения и Message не соответствуют друг другу один к одному. Изменение документа, уведомления и курсоры соблюдают владельцев и FIFO; блокировки и callbacks не возникают неявно из принадлежности к Mix.
[EN]
Mix is a parallel mark/interval overlay on document positions, not a second parse tree or XML-like nesting. One source traversal builds ordinary Structures and anchors Mix marks. Structural nodes, fields, Array rows and source intervals can participate in overlapping active sets even without explicit braces.

`{…}` adds explicit structural mark payload. Its local parsing, strings, comments and source-level anchoring are defined in the [grammar](LMX_grammar.en.md). An ordinary structural consumer may ignore Mix-flagged nodes; a document consumer projects them into the active overlay. The parser does not choose attribute-conflict policy.

`{color: red}` opens an active entry with head `color` and close name/value `red`. `{end}` closes the latest still-active explicit mark; `{end: red}` closes the latest active entry with that close value, regardless of its head. With active `{style: red}` followed by `{color: red}`, the named close removes the latter, not the former.

```text
{color: red}
{color: green}
text
{end: red}
{end: green}
```

Closing red here does not close green. A later mark does not destroy an earlier one: a simple renderer may display the latest active value, while a semantic consumer can inspect the whole ordered chain and intersections. The base model is therefore not a flat key-to-single-value table. An unclosed entry remains tracked to the document/profile boundary and may become an interval, state or diagnostic under the contract.

Mix has three distinct roles: source-mark overlay, document placement tree and cooperating-Message execution. An interval, placement cell and Message do not correspond one-to-one. Document updates, notifications and cursors follow ownership and FIFO; locks and callbacks do not arise implicitly from Mix membership.
@@ worldwide | WorldWideMix: адреса, ячейки и навигация | WorldWideMix: addresses, cells and navigation | 19.28.10.1–19.28.10.10; 19.28.10.13–15
[RU]
WorldWideMix задаёт дерево размещения: где находится ячейка. Граф LMX задаёт значение: какие поля оно имеет и что потребляет выражение. Эти деревья встречаются в ячейке, но не совпадают: адрес `3.17.4` не является полевым путём `file\close`, а `implements` не нумерует соседей Mix.

Адрес — последовательность неотрицательных целых от корня до ячейки. Глубина отдельной ветви и величина индекса не имеют установленного языком конечного потолка; реализация обязана проверять реальные ресурсные пределы, не переполнять представление. Ведущие нули текстовой формы значения не меняют: `03.17` и `3.17` равны. Префикс адресует поддерево, сокращение пути ведёт к предку.

Числа считают соседние позиции, не байты. Размер ячейки может соответствовать слову, буферу или ссылке на значение. Varint, цепочка полей разной ширины и другие кодеки — способы хранения одних чисел, не различные типы адреса. Переход с 5 на 12 бит не переименовывает `3.17`. Примеры десятков соседей в памяти и большего числа в секторе диска иллюстрируют носитель, не ограничивают адресную модель.

Ветви могут иметь разную глубину. Для префикса P группа `bunch(P)` содержит только занятые непосредственные индексы. Если заняты `{0,4,5}`, то после `P.4` идёт `P.5`, перед ним — `P.0`. `next`/`prev` не спускаются в детей, не поднимаются к родителю и не обходят все документы мира. `down`/`up` меняют глубину; `next`/`prev` меняют последний индекс внутри одной группы.

Курсор — путь плюс позиция внутри буферной ячейки, если она нужна. Вставка/удаление затрагивает соответствующий уровень соседей, не переадресует «все последующие байты файла». Документ — корень, дерево размещения и слой меток; файл является одним способом сериализации страниц. Человеческое имя, realm, том и глава — атрибуты и соглашения профиля, не DNS и не фиксированное число уровней.

Носителем может быть память, диск, провод, радио или переносимое хранилище; Интернет и HTTP не обязательны. Сообщение может передать короткий адрес, полномочие и сведения о потребителе вместо полного большого тела. Потребитель читает нужные части курсором. Тип содержимого устанавливается по значению LMX и [допуску](#admission), не по Mix-адресу, MIME или расширению файла.

Сортировочные сервисы размещаются за границей отдельного приложения, на узлах WorldWideMix, соответствующих дереву размещения и маршрутам между его частями. Они могут накапливать, группировать и раскладывать письма по адресатам там, где задержки носителя делают такую обработку полезной. Это не второй круг локальной почты и не обязательный посредник между L3 Thread одного процесса: локальная почтовая коллекция сохраняет свой базовый FIFO-контракт. Ёмкость буфера сортировщика, политика его переполнения и прямой отправки задаются конкретным транспортным профилем, а не семантикой L3.

Mix-слой размещает на тех же позициях пересекающиеся метки, курсоры, атрибуты и интервалы. Составление значения страницы следует общему [контракту `merge`](#composition); адреса соседних ячеек при этом не переопределяются. Заполнение диска не даёт права автоматически вытеснить данные к произвольному соседу: отказ, уплотнение или явно разрешённое зеркало задаются профилем хранения.
[EN]
WorldWideMix defines a placement tree: where a cell is situated. The LMX graph defines a value: its fields and what an expression consumes. These trees meet in a cell but are not identical: address `3.17.4` is not field path `file\close`, and `implements` does not number Mix neighbours.

An address is a sequence of nonnegative integers from root to cell. Neither an individual branch's depth nor index magnitude has a language-defined finite ceiling; implementations must check actual resource limits rather than overflow their representation. Leading textual zeros do not change meaning: `03.17` equals `3.17`. A prefix addresses a subtree; shortening the path reaches an ancestor.

The numbers count neighbouring positions, not bytes. A cell may hold a word, buffer or value reference. Varints, mixed-width fields and other codecs store the same integers rather than defining different address types. Changing storage from 5 to 12 bits does not rename `3.17`. Examples of tens of RAM neighbours and larger disk-sector occupancy illustrate carriers, not address-model limits.

Branches may have different depths. For prefix P, `bunch(P)` contains only occupied direct indices. If `{0,4,5}` are occupied, `P.4` is followed by `P.5` and preceded by `P.0`. `next`/`prev` neither descend, ascend nor traverse every document worldwide. `down`/`up` change depth; `next`/`prev` change the last index within one bunch.

A cursor is a path plus a buffer-cell position when needed. Insertion/deletion affects the relevant sibling level rather than readdressing every subsequent file byte. A document is a root, placement tree and mark overlay; a file is one way to serialize pages. Human names, realms, volumes and chapters are attributes/profile conventions, not DNS or a fixed number of levels.

Carriers can be RAM, disk, wire, radio or removable storage; Internet and HTTP are optional. A Message may carry a short address, authority and consumer information instead of an entire large body. The consumer reads needed parts by cursor. Content typing follows the LMX value and [admission](#admission), not its Mix address, MIME or filename extension.

Sorting services are placed outside an individual application, at WorldWideMix nodes corresponding to the placement tree and the routes between its parts. They may accumulate, batch and distribute letters by destination where carrier latency makes that processing useful. This is not a second local-mail circuit and is not a mandatory intermediary between L3 Threads in one process: the local mail collection retains its base FIFO contract. A sorter's buffer capacity, overflow policy and direct-send policy belong to a particular transport profile rather than to L3 semantics.

The Mix overlay places intersecting marks, cursors, attributes and intervals on the same positions. Page-value composition follows the general [contract of `merge`](#composition); it does not override neighbouring cell addresses. Disk exhaustion does not authorize automatically spilling data to an arbitrary neighbour: refusal, compaction or an explicitly authorized mirror belongs to storage policy.
@@ mix-coordination | Координация префиксов и зеркала | Prefix coordination and mirrors | 19.28.10.11–12; 19.28.10.15
[RU]
Изменяемым состоянием Mix владеет Message. Запрос изменения адресуется владельцу и выполняется в его последовательном такте. Конкурирующим отправителям одного владельца достаточно FIFO; дополнительное получение разрешения-блокировки не требуется только из-за одновременности отправителей.

Логическое исключение изменений по префиксу — отдельно выбираемый протокол Message, не нативный межмашинный mutex и не обязательная часть каждой операции. Резервация P охватывает всё поддерево P, включая более глубокие группы. Координатор общего префикса согласует затронутых владельцев, но не записывает напрямую в их арены и не планирует произвольно их потомков.

Резервация `34.3.7` не мешает независимой `34.3.1`; резервация `34.3` должна учитывать конфликты обеих ветвей. Протокол обязан определить момент действия исключения, судьбу уже принятых команд и защиту от поздней команды по отозванному разрешению. Полномочие запросить изменение и действующая резервация — разные факты. Наличие записи у координатора само по себе ещё не обеспечивает соблюдение всеми путями записи.

Исключение по префиксу не означает распределённую транзакцию, общий откат или физически одновременное изменение. Для времени действия T нужны правила неопределённости часов, опоздания, недоставки и частичного отказа. Тайм-аут не доказывает, что прежний участник остановился. Форматы grant/token, поколения, повторов и восстановления остаются явными решениями протокола, а не неявными обязательствами каждого Message.

Зеркало — другой префикс с соответствующим содержимым для конкретного потребителя, не отдельный фундаментальный вид документа. Записи идут первичному владельцу, изменения доставляются зеркалу сообщениями. Читатель может допускать отставание; запись по устаревшему зеркалу не становится безопасной автоматически. Имя зеркала — атрибут, адрес — его собственный путь.

Эквивалентность первичного значения и зеркала относительна к используемому дереву и тестам принимающего выражения. Она не означает вечное равенство байтов. Проекция «последнее значение побеждает» допустима для выбранного renderer, но не уничтожает полную цепочку вхождений. История и undo могут быть потребителями изменений Mix; новая версия всего документа после каждой правки не является правилом ядра.
[EN]
Mutable Mix state belongs to a Message. A change request addresses its owner and executes in that owner's serial turn. Concurrent senders to one owner need only FIFO; concurrency alone does not require an extra lock-grant step.

Logical prefix exclusion is a separately selected Message protocol, not a native cross-machine mutex or mandatory part of every operation. Reserving P covers all of subtree P, including deeper bunches. A common-prefix coordinator reconciles affected owners but neither writes directly into their arenas nor arbitrarily schedules descendants.

A reservation on `34.3.7` leaves independent `34.3.1` work alone; one on `34.3` must account for conflicts in both branches. The protocol must define when exclusion takes effect, treatment of already admitted commands and protection against late commands under revoked grants. Authority to request a change and a current reservation are different facts. A coordinator record alone does not enforce every write path.

Prefix exclusion implies neither distributed transaction, common rollback nor physically simultaneous mutation. An effective time T requires rules for clock uncertainty, lateness, nondelivery and partial failure. A timeout does not prove the former participant stopped. Grant/token formats, generations, retries and recovery remain explicit protocol choices, not implicit obligations of every Message.

A mirror is another prefix with corresponding content for a particular consumer, not a new fundamental document kind. Writes go to the primary owner; changes reach the mirror as Messages. A reader may tolerate lag; writing through a stale mirror is not automatically safe. A mirror's name is an attribute, while its address is its own path.

Equivalence of primary and mirrored values is relative to the receiving expression's used tree and tests. It does not mean perpetual byte equality. A last-wins projection is permitted for a selected renderer but does not destroy the complete occurrence chain. History and undo may consume Mix changes; a new whole-document version on every edit is not a core rule.
@@ transport | HTTP и границы сервиса | HTTP and service boundaries | 19.26.1; 19.31
[RU]
HTTP/REST LMX — транспортный профиль, не ядро исполнения и не WorldWideMix. Сервис представляет собой взаимодействующие Message, не общую изменяемую кучу. Внешний запрос преобразуется в Message, затем проходит [приём и допуск](#pipeline), исполнение и отображение результата в транспортный ответ.

Цель HTTP-запроса складывается из нормализованных endpoint и route. Пример: endpoint `https://archive.example.org` и route `/inbox/save`. Получатель разрешает локальный маршрут в явно заданной таблице. Маршрут не именует поток ОС, не раскрывает сырой дескриптор Thread и сам по себе не даёт полномочий.

Исходный профиль отправляет полный документ LMX методом POST с `application/lmx`. Провайдер получает URI и точную последовательность байтов, возвращая транспортный отказ или статус приёма. Замена провайдера тестовым, WinHTTP, libcurl или другим адаптером не меняет Message-семантику. Универсальный процессный HTTP singleton из этого не следует.

Синхронный профиль может вернуть семантический ответ в HTTP-ответе; асинхронный — подтвердить приём и позднее доставить Message на `replyTo`. Семантический ответ содержит `correlation`, соответствующую `id` запроса. Приём, исполнение и прикладной успех остаются различными событиями.

Вместо большого тела допускается явно переданный курсор с диапазоном и режимом чтения. Его адрес, права и срок жизни входят в контракт принимающего выражения. Чтение сжатой части, расшифрование и миграция формата — явные операции; переданный `targetDescriptor` остаётся обычными данными, не скрытым дескриптором каждого значения.

Исходный пример внешнего тела передаёт ссылку на сегмент, диапазон и режим чтения. Полномочия и срок жизни курсора проверяются в составе юнит-тестов принимающего выражения; короткий конверт не отменяет допуска данных, которые затем будут прочитаны.

{{l1:11469-11483}}

Декларативное правило маршрутизации ниже является данными профиля. Оно исполняется отдельным принимающим выражением, которое интерпретирует условие и создаёт доставляемое сообщение; сама запись правила не выполняет вложенный `send`.

{{l1:11263-11270}}
[EN]
HTTP/REST LMX is a transport profile, not the execution core or WorldWideMix. A service is a set of cooperating Messages, not a shared mutable heap. An external request becomes a Message, then undergoes [intake and admission](#pipeline), execution and result-to-transport mapping.

An HTTP target combines normalized endpoint and route. Example: endpoint `https://archive.example.org` with route `/inbox/save`. The receiver resolves the local route in an explicit Table. A route neither names an OS worker, exposes a raw Thread handle nor grants authority by itself.

The original profile posts a complete LMX document with `application/lmx`. A provider receives the URI and exact bytes, returning transport failure or admission status. Substituting a test provider, WinHTTP, libcurl or another adapter does not change Message semantics. No universal process-wide HTTP singleton follows.

A synchronous profile may return the semantic reply in the HTTP response; an asynchronous one may acknowledge admission and later send a Message to `replyTo`. The semantic reply carries `correlation` matching request `id`. Admission, execution and application success remain distinct events.

Instead of a large body, an explicit cursor with range and reading mode may be supplied. Its address, authority and lifetime belong to the receiving expression's contract. Reading compressed content, decryption and format migration are explicit operations; a supplied `targetDescriptor` remains ordinary data rather than a hidden descriptor on every value.

The source external-body example supplies a segment reference, range and reading mode. Cursor authority and lifetime are checked by the receiving expression's unit tests; a short envelope does not waive admission of the data subsequently read.

{{l1:11469-11483}}

The declarative routing rule below is profile data. A separate receiving expression executes it by interpreting the condition and constructing the delivered Message; the rule record itself does not execute a nested `send`.

{{l1:11263-11270}}
@@ authentication | Идентификация, полномочия и свидетельства | Authentication, authority and evidence | 19.32.1–19.32.9; 19.32.18
[RU]
Учётные данные, verifier, полномочия и свидетельства — явные значения в потоке сообщений, не глобальная иерархия ролей. Защищённый verifier позволяет проверить первичный credential без хранения его исходного секрета. Результат криптографической операции — факт для политики, не автоматическое право на все действия.

Модуль, сервис, архив, каталог или административная операция могут иметь отдельную область verifier. Контракт может требовать один verifier, несколько для одного пользователя либо кворум пользователей/сессий. Родство создателя и ребёнка задаёт управление жизнью, не право чтения содержимого. Сброс verifier доступа не восстанавливает содержимое, зашифрованное ключом от прежнего credential.

Первоначальные имя пользователя и пустой пароль, допускавшиеся старым установочным профилем, — явное состояние установки, не общая политика безопасности и не разрешение внешнему входу обходить допуск. Пользователь или администратор может заменить verifier. Конкретная политика первого запуска должна быть выражена отдельно.

После установленного подтверждения первичного credential политика может выдать делегированный ticket для модуля/сервиса с операциями и сроком действия. Изменение или сброс исходного verifier инвалидирует зависимые tickets согласно выраженной политике. OAuth и вход ОС — подключаемые модули; они не заменяют автоматически выбранный verifier и не получают власть из номера уровня L2/L3.

AuthEvidence может явно содержать пользователя, область verifier, ticket, разрешённые действия и факт кворума. Это данные с зависимостями и временем действия. Принимающее выражение проверяет необходимые свойства в своих юнит-тестах по [единому механизму](#admission). Совпадение пароля или корректная подпись не создают неявных ролей, привязок имён или бессрочного допуска.

<a id="realm-independence"></a>
### Независимые области verifier и локальное восстановление доступа

Пространство пользователей может быть общим, но области verifier независимы. Один пользователь может иметь учётные данные в нескольких областях. Успешная аутентификация в одной области не аутентифицирует этого пользователя в другой и не открывает её защищённые объекты, даже если текст человеческого пароля совпадает. Межобластной доступ требует явно установленного отношения доверия, делегированного ticket или другого полномочия, допускаемого политикой защищённого объекта; совпадение текста credential не создаёт такого отношения.

Изменение или сброс verifier локальны для его области. Сброс default realm, в том числе замена verifier на пустой или первоначальный установочный, не сбрасывает и не заменяет автоматически verifiers, ключевой материал шифрования или защиту независимо защищённых объектов. Эти объекты остаются под собственными областями и политиками восстановления. Восстановление обычного доступа к системе не расшифровывает независимо защищённое содержимое и не даёт права его открыть.

### Явная защита вместо global lockout

Default realm должен делать обычную локальную работу спокойной. Он должен избегать постоянного `access denied` behavior для незащищенных services, directories и applications. Если service или directory не объявлены protected, empty или bootstrap verifier может быть достаточным для ordinary access.

System services и опасные administrative surfaces могут принадлежать admin realm с verifier сисадмина. Обычные user services могут оставаться в default realm. Когда пользователь или администратор решает, что конкретный service, directory или archive важен, он создает для этого объекта новый verifier realm.

Encrypted data должны принадлежать собственному protection realm:

```text
protected directory
    -> separate verifier realm
    -> separate encryption key material

`.lmz` archive
    -> separate verifier realm
    -> archive-local encryption key material
```

Это отличается от подхода, где весь диск считается одним secret. Full-disk encryption может защитить выключенное украденное устройство, но смешивает device recovery, operating-system access, ordinary files и truly protected data в один global mechanism. Если global secret потерян, можно потерять всю машину. Если он unlocked, слишком многое оказывается unlocked.

Lingvamyxa protection должна разделять recovery и secrecy:

```text
system recovery
    -> reset default realm, reinstall, recreate ordinary access

protected data recovery
    -> requires the protected realm credential or its recovery policy
```

Забытый default password не должен уничтожать компьютер. Забытый verifier от protected archive или protected directory может сделать эти protected data невосстановимыми, и это честная цена настоящего encryption.

<a id="protected-structures"></a>
### Обычные интерфейсы и защищённые ветви графа

Обычная Structure или выбранная ветвь её графа может использовать тот же явно выбранный механизм защиты объектов, что модуль, каталог или архив. Это действует независимо от того, потребляется ли ветвь как данные, реализация, описание или контекст исполнения. Защита использует область verifier объекта, полномочия/свидетельства, а при требовании конфиденциальности — [криптографического провайдера](#crypto-values) и [контракты операций](#crypto-operations). Новые ресиверы, система модификаторов доступа, правила видимости методов или таблица экспорта не вводятся.

Программа может предоставить обычную Structure с именем `public` и защитить выбранные ветви реализации или данных за ней. `public` — только выбранное программой имя: оно не публикует другие поля и не даёт полномочий. Предоставляемое поведение, включая выбор реализации, строится обычными Structures, вызовами и композицией. Выбор небольшого интерфейса сам по себе не защищает его внутренности; защита выбранных внутренних ветвей не закрывает постороннюю незащищённую работу и не требует от каждой программы такого интерфейса.

Полномочие вызвать предоставленное поведение отличается от полномочия просматривать, расшифровывать, копировать или экспортировать его защищённое представление либо ключи. Допущенная операция может использовать защищённые значения по явно предоставленному ей полномочию, не передавая это полномочие или эти значения вызывающему. Вызывающий получает то, что разрешают раскрыть обычный контракт результата и выбранная политика защиты. Переданная ссылка, совместимый тип или успешный тест сами по себе не дают дополнительных полномочий.

Защита выбранной ветви действует при доступе через полевые пути, элементы Array, псевдонимы и лексические/контекстные ссылки, а также при построении или переносе её представления. `merge`, копирование, сериализация, создание Message, перенос аргументов/результатов и `post` не обходят эту защиту и не ослабляют её неявной сменой представления. Передача владения хранилищем сама по себе не разрешает читать или экспортировать защищённое содержимое. Передача допустимого интерфейса или непрозрачной ссылки не публикует достижимый за ней защищённый контекст.

Полный используемый контекст при [композиции](#composition) и [вызовах через транспорт](#thread-message-api) остаётся под тем же выбранным контрактом защиты объекта. Разрешённое использование ветви и экспорт её содержимого — разные операции; вызов предоставленного поведения сам по себе не экспортирует защищённую реализацию или ключи. Если формирование аргумента, результата или копируемого контекста раскрыло бы запрещённый применимой политикой материал, операция следует своему существующему контракту отказа, а не публикует расшифрованную копию и не пропускает молча обязательный вход. Явное разрешённое раскрытие/экспорт остаётся возможным по этой политике. Эти правила применяют общий механизм защиты, а не создают другую семантику почтового вызова или скрытого контекста.
[EN]
Credentials, verifiers, authority and evidence are explicit values in Message flow, not a global role hierarchy. A protected verifier checks a primary credential without retaining its original secret. A cryptographic result is a fact for policy, not automatic authority for every action.

A module, service, archive, directory or administrative operation may have its own verifier realm. A contract may require one verifier, several for one user, or a user/session quorum. Creator/child relationships establish lifecycle management, not content-reading rights. Resetting an access verifier does not recover content encrypted using a key derived from the former credential.

The initial username and empty password permitted by an earlier installation profile are explicit installation state, not universal security policy or permission for external input to bypass admission. A user or administrator may replace the verifier. A concrete first-run policy must be represented separately.

After primary-credential confirmation, policy may issue a delegated module/service ticket with permitted operations and expiry. Changing/resetting the primary verifier invalidates dependent tickets under explicit policy. OAuth and OS login are pluggable modules; they neither automatically replace the chosen verifier nor gain authority from language level L2/L3.

AuthEvidence may explicitly contain user, verifier realm, ticket, permitted actions and quorum satisfaction. It is data with dependencies and lifetime. The receiving expression checks required properties in its unit tests under [unified admission](#admission). A password match or valid signature creates no implicit roles, name bindings or indefinite admission.

<a id="realm-independence"></a>
### Independent verifier realms and realm-local recovery

The principal namespace may be shared, but verifier realms are independent. The same principal may have credentials in multiple realms. Successful authentication in one realm does not authenticate that principal in another realm or unlock its protected objects, even when the human password text happens to be the same. Cross-realm access requires an explicitly established trust relation, delegated ticket or other authority admitted by the protected object's policy; equality of credential text does not create that relation.

Changing or resetting a verifier is realm-local. Resetting the default realm, including replacement with an empty or bootstrap verifier, does not automatically reset or replace the verifiers, encryption key material or protection of independently protected objects. Those objects remain protected under their own realms and recovery policies. Recovery of ordinary system access neither decrypts independently protected content nor grants authority to unlock it.

### Explicit protection instead of global lockout

The default realm should make ordinary local work boring. It should avoid permanent `access denied` behavior for unprotected services, directories and applications. If a service or directory is not declared protected, the empty or bootstrap verifier may be enough for ordinary access.

System services and dangerous administrative surfaces may belong to an admin realm with a sysadmin verifier. Ordinary user services may remain in the default realm. When a user or administrator decides that a particular service, directory or archive is important, they create a new verifier realm for that object.

Encrypted data should belong to its own protection realm:

```text
protected directory
    -> separate verifier realm
    -> separate encryption key material

`.lmz` archive
    -> separate verifier realm
    -> archive-local encryption key material
```

This is different from treating the whole disk as one secret. Full-disk encryption may protect a powered-off stolen device, but it mixes device recovery, operating-system access, ordinary files and truly protected data into one global mechanism. If the global secret is lost, the whole machine may be lost. If it is unlocked, too much may be unlocked.

Lingvamyxa protection should keep recovery and secrecy separate:

```text
system recovery
    -> reset default realm, reinstall, recreate ordinary access

protected data recovery
    -> requires the protected realm credential or its recovery policy
```

Forgetting the default password should not destroy the computer. Forgetting a protected archive or protected directory verifier may make that protected data unrecoverable, and that is the honest cost of real encryption.

<a id="protected-structures"></a>
### Ordinary interfaces and protected graph branches

An ordinary Structure or a selected branch of its graph may use the same explicitly chosen object-protection mechanism as a module, directory or archive. This applies whether the branch is consumed as data, implementation, description or execution context. Protection uses the object's verifier realm, authority/evidence and, where confidentiality is required, the [cryptographic provider](#crypto-values) and [operation contracts](#crypto-operations). It introduces no new receiver, access-modifier system, method-visibility rules or export table.

A program may expose an ordinary Structure named `public` and protect selected implementation or data branches behind it. `public` is only a program-chosen name: it neither publishes other fields nor grants authority. The exposed behaviour, including selection of an implementation, is built through ordinary Structures, calls and composition. Choosing a small interface does not by itself protect its internals; protecting selected internals does not lock unrelated unprotected work or require every program to use such an interface.

Authority to invoke the exposed behaviour is distinct from authority to inspect, decrypt, copy or export its protected representation or keys. An authorized operation may use protected values under its explicitly supplied authority without transferring that authority or those values to its caller. The caller receives what the ordinary result contract and the selected protection policy permit to be disclosed. A supplied reference, compatible type or successful test does not by itself grant additional authority.

The selected branch's protection applies to access through field paths, Array elements, aliases and lexical/context links, and to operations constructing or transferring its representation. `merge`, copying, serialization, Message construction, argument/result transport and `post` do not bypass that protection or silently downgrade the representation. Transferring storage ownership does not by itself authorize reading or exporting protected contents. Passing an allowed interface or opaque reference does not publish the protected context reachable behind it.

The complete used context in [composition](#composition) and [transported calls](#thread-message-api) remains subject to the same selected object-protection contract. Authorized use of a branch and export of its contents are distinct operations; invoking exposed behaviour does not by itself export its protected implementation or keys. If forming an argument, result or copied context would disclose material forbidden by the applicable policy, the operation follows its existing refusal contract rather than publishing a plaintext copy or silently omitting a required input. Explicit permitted disclosure/export remains possible under that policy. These rules apply the shared protection mechanism; they do not create another postal-call or hidden-context mechanism.
@@ crypto-values | Криптографические значения и провайдеры | Cryptographic values and providers | 19.32.10–19.32.12; 19.32.14–19.32.17
[RU]
L3 выражает криптографическое намерение, связи ключей, политику и состояние протокола. Провайдер реализует примитивы, защищённое хранение и платформенный интерфейс. Приведённые названия обозначают семантические роли контрактов; конкретный профиль связывает их с receiver и структурой типов. Провайдер выбирается явно по профилю, ссылке, capability, конфигурации или сервису.

AlgorithmId содержит семейство, алгоритм, версию/профиль и существенные параметры. Параметры, влияющие на совместимость байтов протокола, явно заданы либо фиксированы именованным профилем. Подмена алгоритма и скрытый downgrade запрещены. Отсутствующий статически обязательный провайдер вызывает ошибку сборки/связывания; неподдержанный динамический выбор — явный отказ операции.

PublicKey — обычные несекретные данные с алгоритмом, форматом и байтами ключа, необязательными id/метаданными. Их можно копировать, хранить и передавать. Raw, SPKI, JWK и иные кодирования являются явным выбором; внутренний объект провайдера не является форматом обмена.

KeyRef — непрозрачное полномочие на секретный ключ с контрактом владельца-провайдера, операций, срока жизни и экспорта. Это не сырой L2-адрес и не обязательный массив секретных байтов. KeyPair объединяет PublicKey и private KeyRef. Генерация не публикует приватный материал в граф автоматически; неэкспортируемый ключ — допустимая реализация.

Verifier явно обозначает алгоритм, формат/версию, salt и параметры проверки: стоимость памяти, времени/итераций и параллелизма, а также результат или каноническое кодирование. KeyPolicy может задавать использование, сроки, ротацию, отзыв, версии, связь с объектом, экспорт и получателей; точную структуру политики определяет выбранный профиль.

Передача KeyRef, возврат, сохранение в поле, композиция и смена провайдера не экспортируют секрет. Контракт определяет локальное использование разными Message, retain/transfer и допустимость сериализации. Переносимый исходный вариант — локальность провайдеру/runtime и отсутствие wire-сериализации. Передача секрета на другую машину требует явного разрешённого export/import или защищённого конверта.

Для криптографически защищённой ветви графа зашифрованная форма хранения или передачи и расшифрованное рабочее представление — разные случаи одного контракта защиты. Выбранные владелец/провайдер и профиль должны контролировать расшифрованные данные, credentials и ключи, используемые допущенной операцией, и явно определять их время жизни и разрешённое раскрытие. Расшифрование для использования не публикует автоматически открытый граф каждому держателю обычного доступного интерфейса. Провайдер не вправе обещать конфиденциальность во время использования, если не обеспечивает заявленную границу; одного шифрования хранилища, отсутствующего исходного имени или квалификатора для такой гарантии недостаточно. Это требование не предписывает обязательного провайдера, алгоритма или нового представления графа и не расширяет перечисленные ниже гарантии защищённой памяти.

Защищённая память — набор отдельных возможностей: контролируемое секретное хранилище, очистка, page locking, guard pages, неэкспортируемость, аппаратная защита. Одна не подразумевает остальные. Нельзя обещать удаление копий, которыми провайдер не владеет, в UI, VM или host. Синхронный вызов, сервисное сообщение и асинхронный адаптер могут реализовать один контракт, не вводя нового общего планировщика или готового `await` языка.
[EN]
L3 expresses cryptographic intent, key relationships, policy and protocol state. A provider implements primitives, secure storage and platform interfaces. The names below denote semantic contract roles; a concrete profile binds them to receivers and a type structure. Providers are explicitly selected by profile, reference, capability, configuration or service.

AlgorithmId contains family, algorithm, version/profile and relevant parameters. Parameters affecting interoperable protocol bytes are explicit or fixed by a named profile. Algorithm substitution and silent downgrade are prohibited. Missing statically required providers fail build/link; unsupported dynamic selection fails explicitly at the operation.

PublicKey is ordinary non-secret data with algorithm, format and key bytes, optionally id/metadata. It may be copied, stored and transmitted. Raw, SPKI, JWK and other encodings are explicit choices; a provider's internal object is not a wire format.

KeyRef is an opaque secret-key capability with a contract covering owning provider, operations, lifetime and export. It is neither a raw L2 address nor necessarily an Array of secret bytes. KeyPair combines PublicKey and private KeyRef. Generation does not automatically publish private material into the graph; non-extractable keys are valid implementations.

A Verifier explicitly identifies algorithm, format/version, salt and verification parameters: memory cost, time/iteration cost, parallelism and result or canonical encoding. KeyPolicy may define uses, expiry, rotation, revocation, versions, object association, export and recipients; the selected profile defines its exact Structure.

Passing KeyRef, returning it, storing it in a field, composition and provider changes do not export the secret. Its contract defines local multi-Message use, retain/transfer and serializability. The portable default is provider/runtime locality without wire serialization. Sending a secret to another machine requires explicit permitted export/import or a protected envelope.

For a cryptographically protected graph branch, the encrypted stored or transported form and any decrypted working representation are separate cases of the same protection contract. The selected owner/provider and profile must control the plaintext, credentials and keys used by an authorized operation and explicitly govern their lifetime and any permitted exposure. Decryption for use does not automatically publish a plaintext graph to every holder of the ordinary public interface. A provider must not claim confidentiality during use when it cannot enforce the declared boundary; encryption of storage, an omitted source name or a qualifier alone does not establish that guarantee. This requirement prescribes no mandatory provider, algorithm or new graph representation and does not enlarge the secure-memory guarantees below.

Secure memory is a set of distinct capabilities: controlled secret storage, erasure, page locking, guard pages, non-extractability and hardware protection. One does not imply the others. Erasing copies outside provider control in UI, VM or host cannot be promised. Direct calls, service Messages and asynchronous adapters may implement one contract without introducing a new common scheduler or an already defined language `await`.
@@ crypto-operations | Контракты криптографических операций | Cryptographic operation contracts | 19.32.13.1–19.32.13.9; 19.32.18–19.32.21
[RU]
Следующие сигнатуры описывают смысл входов и результатов, не физический ABI. Байтовые результаты остаются обычными значениями; непереносимое устройство ключа скрыто провайдером. Эти операции сами не создают альтернативного механизма допуска аргументов.

| Семейство | Входы и результат | Существенный контракт |
| --- | --- | --- |
| `Random.bytes` | length → bytes | Криптографически пригодная случайность либо явный отказ; без слабого fallback |
| `Crypto.equalConstantTime` | a, b → boolean | Для равной длины соблюдается заявленный timing-контракт; длина может быть публичной |
| `Hash.digest` | algorithm, data → digest | Явный алгоритм; digest — обычные данные, если политика не защищает их отдельно |
| `Mac.compute` / `Mac.verify` | algorithm, KeyRef, data, при проверке tag | Выдать tag либо boolean/отказ; не раскрывать промежуточный секрет |
| `Kdf.deriveKey` | profile, inputKeyRef, salt, info, outputKeyProfile → KeyRef | Секретный результат удерживается провайдером без лишнего export/import |
| `Kdf.deriveBytes` | profile, inputKeyRef, salt, info, length → bytes | Явно публикует производный материал в обычное хранилище |
| `PasswordVerifier.create` / `verify` | password с policy/profile либо verifier | Создать Verifier либо boolean/отказ по объявленным параметрам; пароль не становится постоянным verifier |
| `KeyPair.generate` | algorithm/profile, policy → KeyPair | Публичный ключ и приватный KeyRef с ограничениями использования |
| `PublicKey.import/export` | algorithm, format, bytes / publicKey, format | Явное преобразование публичного кодирования |
| `PrivateKey.import`, `SecretKey.import` | algorithm, format, secretBytes, policy → KeyRef | Явно вводит уже видимый секрет в хранилище провайдера |
| `PrivateKey.export`, `SecretKey.export` | KeyRef, format → secretBytes | Только явный разрешённый экспорт; неэкспортируемость даёт отказ |
| `Signature.sign/verify` | profile, соответствующий ключ, message, при проверке signature | Подпись не раскрывает приватный ключ; формат фиксирован профилем |
| `KeyAgreement.derive` | profile, privateKeyRef, peerPublicKey, outputKeyProfile → KeyRef | Предпочтительно сразу ключ сессии; сырой общий секрет требует отдельной операции |
| `Aead.seal/open` | profile, KeyRef, nonce, данные, associatedData | Шифротекст с tag либо проверенный plaintext/отказ |
| `Key.release` | KeyRef | Инвалидирует handle и освобождает/очищает контролируемое хранилище по контракту |

AEAD аутентифицирует associatedData, но не шифрует их. Правила nonce и layout ciphertext/tag фиксирует профиль; запрещённое повторение nonce нельзя молча допускать. Неуспешная аутентификация не публикует даже частичный непроверенный plaintext и отличается от успешного пустого результата. Помощник может создавать nonce, но nonce остаётся явными данными протокола.

Импорт секретного материала минимизирует время его хранения там, где провайдер управляет буфером. Экспорт явно меняет ответственность за срок жизни секрета. `release` может быть заменён автоматическим освобождением по явному контракту, но профиль вправе требовать детерминированное завершение. GC-финализация не обещает очистить неконтролируемые копии.

Отказы различают как минимум неподдержанный алгоритм/профиль, недопустимый ключ/кодирование, запрещённый экспорт, провал аутентификации, неверную подпись, неправильные nonce/параметры, отсутствие безопасной случайности, недоступность провайдера, внутреннюю и ресурсную ошибку. Проверка подписи может возвращать false по своему контракту. Ни одна ошибка не разрешает скрытое ослабление алгоритма.

Профиль совместимости фиксирует алгоритм, параметры, кодирования ключей/результатов и байты протокола. SHA-256, HMAC-SHA-256, HKDF-SHA-256, Ed25519, X25519 и Argon2id указаны в исходном проекте как кандидаты испытаний, не обязательный список каждой платформы. AES-GCM, ChaCha20-Poly1305-IETF и XChaCha20-Poly1305 — разные AEAD-профили. Argon2id-verifier не может быть молча прочитан как PBKDF2.

Проверки провайдера должны включать межреализационные векторы и отрицательные случаи: неверные signature/tag, неподдержанный профиль, неэкспортируемый либо освобождённый ключ, недоступный провайдер. Сравниваются семантические байты и результаты, не объектная раскладка backend. Функциональные тесты не доказывают timing, стирание, неэкспортируемость или качество энтропии; заявленные гарантии требуют отдельного подтверждения.

Streaming, secret streams, HSM/TPM, KEM/PQC, удалённые ключевые сервисы и формат защищённого конверта не входят в определённый здесь профиль.
[EN]
The following signatures specify semantic inputs/results, not physical ABI. Byte results remain ordinary values; provider-private key representation stays hidden. These operations do not create another argument-admission mechanism.

| Family | Inputs and result | Essential contract |
| --- | --- | --- |
| `Random.bytes` | length → bytes | Cryptographically suitable randomness or explicit failure; no weak fallback |
| `Crypto.equalConstantTime` | a, b → boolean | Claimed timing contract for equal lengths; length may be public |
| `Hash.digest` | algorithm, data → digest | Explicit algorithm; digest is ordinary data unless separately protected by policy |
| `Mac.compute` / `Mac.verify` | algorithm, KeyRef, data, plus tag for verification | Produce tag or Boolean/failure without exposing intermediate secrets |
| `Kdf.deriveKey` | profile, inputKeyRef, salt, info, outputKeyProfile → KeyRef | Provider retains the secret result without needless export/import |
| `Kdf.deriveBytes` | profile, inputKeyRef, salt, info, length → bytes | Explicitly publishes derived material into ordinary storage |
| `PasswordVerifier.create` / `verify` | password with policy/profile or verifier | Produce Verifier or Boolean/failure under declared parameters; password is not persistent verifier state |
| `KeyPair.generate` | algorithm/profile, policy → KeyPair | Public key and private KeyRef with usage restrictions |
| `PublicKey.import/export` | algorithm, format, bytes / publicKey, format | Explicit public-encoding conversion |
| `PrivateKey.import`, `SecretKey.import` | algorithm, format, secretBytes, policy → KeyRef | Explicitly imports already visible secret material into provider storage |
| `PrivateKey.export`, `SecretKey.export` | KeyRef, format → secretBytes | Explicit permitted export only; non-extractability causes failure |
| `Signature.sign/verify` | profile, respective key, message, plus signature for verification | Signing never exposes private bytes; profile fixes format |
| `KeyAgreement.derive` | profile, privateKeyRef, peerPublicKey, outputKeyProfile → KeyRef | Prefer a session key directly; raw shared secret requires a separate operation |
| `Aead.seal/open` | profile, KeyRef, nonce, data, associatedData | Ciphertext with tag or authenticated plaintext/failure |
| `Key.release` | KeyRef | Invalidates handle and releases/clears controlled storage under its contract |

AEAD authenticates associatedData without encrypting them. The profile fixes nonce rules and ciphertext/tag layout; prohibited nonce reuse cannot be silently admitted. Authentication failure publishes no partial unauthenticated plaintext and differs from successful empty output. A helper may generate nonce, but nonce remains explicit protocol data.

Secret import minimizes buffer lifetime where the provider controls storage. Export explicitly changes responsibility for secret lifetime. Automatic release may replace `release` under an explicit contract, but a profile may require deterministic disposal. GC finalization does not promise erasure of uncontrolled copies.

Failures distinguish at least unsupported algorithm/profile, invalid key/encoding, prohibited export, authentication failure, invalid signature, invalid nonce/parameters, unavailable secure randomness, unavailable provider, internal failure and resource failure. Signature verification may return false under its contract. No failure authorizes silent algorithm weakening.

An interoperability profile fixes algorithm, parameters, key/result encodings and protocol bytes. SHA-256, HMAC-SHA-256, HKDF-SHA-256, Ed25519, X25519 and Argon2id are original-project testing candidates, not a mandatory list for every platform. AES-GCM, ChaCha20-Poly1305-IETF and XChaCha20-Poly1305 are different AEAD profiles. An Argon2id verifier cannot silently be read as PBKDF2.

Provider tests must include cross-implementation vectors and negative cases: invalid signature/tag, unsupported profile, non-extractable or released key and unavailable provider. Compare semantic bytes/results, not backend object layout. Functional tests do not establish timing, erasure, non-extractability or entropy quality; claimed guarantees need separate evidence.

Streaming, secret streams, HSM/TPM, KEM/PQC, remote key services and protected-envelope formats are outside the profile defined here.
