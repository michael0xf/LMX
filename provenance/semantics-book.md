@@ scope | Предмет языка и способы исполнения | Language scope and execution modes | 0; 0.0; 0.0.1; 0.0.3; 0.1.1; 1; 1.7
[RU]
LMX одновременно представляет данные, исполняемые выражения, модели, запросы и сообщения. Исходная запись строит структуры; принимающее выражение задаёт их смысл. Записи, деревья, конфигурации, схемы, таблицы и программные тела используют одну структурную основу. Реестр, сервис, таблица и Mix — семейства данных и принимающих выражений, а не дополнительные уровни языка.

Все правила языка универсальны в пределах своей объявленной области и применяются одинаково ко всем подходящим конструкциям. Имя, тип, форма записи, уровень вложенности, путь трансляции или удобство реализации не создают неявного исключения. Если реализация требует исключения либо исследование обнаруживает противоречие между правилами, это останавливает соответствующее решение до явного обсуждения; транслятор, интерпретатор и runtime не вправе самостоятельно вводить обходную семантику.

L3 сохраняет изменение графа, структурные вызовы, таблицы, сообщения и локальные акторы. Низкоуровневые адресные операции, необработанный доступ к памяти, вызовы сырых машинных интерфейсов и явная низкоуровневая синхронизация относятся к [L2](L2_spec_ru.md). Различие уровней не устанавливает само по себе чистоту вычисления, полномочия пользователя или отдельную систему безопасности.

Расширение файла выбирает внешний профиль: `.lm1` — прямое понижение L1, `.lm2` — L2, `.lm3` — L3. `.lm4` и `.lm5` не задают действующих профилей. Файл сам является Structure: его корневое тело — L3-Structure, исполняемая с начала в любом профиле, в том числе в `.lm2` — в интерпретируемом теле нет L2-операций, потому что интерпретатор исполняет только L3; функции `main` нет. L3 компилируется по тем же правилам, что и L2; различие одно: построенный граф L3 *может* исполняться интерпретатором, L2-операции — нет. Заполненное слово `native` выбирает нативное исполнение, пустое — интерпретатор, и он исполняет только L3. Правило «нативное исполнение только внутри методов» снято. Режимов «интерпретация / нативное исполнение» у потока нет — единственный переключатель: дескриптор вызываемого вхождения с нативным адресом исполняется нативно, без адреса — интерпретируется. Значение исполнения файла (код завершения) — значение последнего вычисленного выражения корневого тела; корень, как всякая callable-Structure, значения не объявляет, и `return` в нём только голый. Профиль сервиса может выбрать явную функцию, `start`, обработчик или отправку сообщения. Точка входа получает управление после подготовки окружения и графа исполнения.

Модель допускает интерпретацию построенного графа L3 и трансляцию с сохранением той же семантики. Интерпретатор исполняет только L3: не исходный текст, не L1/L2 и не операции `c.*`. Реализация самого интерпретатора не расширяет язык интерпретируемой программы. L2 задаёт машинные механизмы, L3 — высокоуровневые программы, а L1 служит промежуточной стадией понижения к C99. Парсер, интерпретатор графа и транслятор имеют разные задачи. Грамматические формы, границы тел, литералы, комментарии и нормализация определены в [спецификации грамматики](LMX_grammar.ru.md).

Уровни соотносятся как множества: L3 — подмножество L2. Именованная Structure и безымянная Structure всегда принадлежат уровню L3; операции L2 — адресные, машинные, `c.*` — отсутствуют в интерпретируемом теле, потому что интерпретатор исполняет только L3; в откомпилированном теле они могут стоять. Запись `@` любой глубины (`@:`, `@@:`, `@@@:` …) в L3 — только receiver объявления ссылки; остальные её употребления являются операциями L2 и в L3 запрещены. Поэтому граф Structure, построенный из любого профиля, пригоден интерпретатору L3, а тело метода может требовать нативного понижения.

<a id="l3-receiver"></a>
### Принимающее выражение L3

Принимающее выражение L3 задаёт контракт потребления построенного графа как программы L3. Оно определяет поддерживаемое подмножество и точку входа выбранного профиля; наличие синтаксического дерева само по себе не устанавливает допустимость программы. Неподдерживаемая операция не становится допустимой из-за наличия машинного адреса реализации. Ограниченный профиль исполнения должен явно сообщать о неподдерживаемой конструкции, а не молча пропускать её или исполнять как L2. Это ограничение профиля не отменяет [единого механизма допуска кандидатов](#admission).

Исполнение следует разрешённым ссылкам и позициям бинарного графа, а не исходным именам; диагностическая таблица адресов и имён не участвует в выполнении, см. [имена и пути](#fields). Высокоуровневая операция может иметь явно выбранную машинную реализацию с L3-контрактом, как описано в [границе числовых и машинных операций](#mathematics); это не разрешает произвольный вызов `c.*` из интерпретируемой программы.

Представление исполняемого графа в первую очередь использует физические ссылки. Числовой код применяется только там, где физическую ссылку сохранить или передать невозможно; после разрешения такого кода дальнейшее исполнение снова следует полученной ссылке. Текстовые имена не участвуют в распознавании операций, выборе принимающего выражения или диспетчеризации. Внутренний числовой тег реализации допустим как локальная оптимизация интерпретатора, но сам по себе не устанавливает смысл узла L3.

Простейшая программа скриптового профиля:

```text
print: "Hello World"
```
[EN]
LMX represents data, executable expressions, models, queries and messages. Source notation constructs Structures; a receiving expression assigns their meaning. Records, trees, configurations, schemas, tables and program bodies share the same structural basis. Registries, services, tables and Mix are families of data and receivers, not additional language levels.

Every language rule is universal within its declared domain and applies uniformly to every matching construct. A name, type, source spelling, nesting level, lowering path, or implementation convenience creates no implicit exception. If an implementation appears to require an exception, or investigation finds a contradiction between rules, the affected decision is suspended for explicit discussion; translator, interpreter, and runtime must not invent workaround semantics.

L3 retains graph mutation, structural calls, tables, messages and local actors. Low-level address operations, raw memory access, raw machine interfaces and explicit low-level synchronization belong to [L2](L2_spec_en.md). The level distinction does not by itself establish computational purity, user authority or a separate security system.

A file extension selects its outer profile: `.lm1` selects direct L1 lowering, `.lm2` L2, and `.lm3` L3. `.lm4` and `.lm5` do not select current profiles. The file is itself a Structure: its root body is an L3 Structure executed from the start in every profile, including `.lm2` -- an interpreted body has no L2 operations, because the interpreter executes only L3; there is no `main` function. L3 is compiled by the same rules as L2; the one difference: a constructed L3 graph *may* be executed by the interpreter, L2 operations may not. A filled `native` word selects native execution; an empty word selects the interpreter, which executes only L3. The rule that native execution is enabled only inside methods is withdrawn. A Thread has no "interpreted / native" modes -- the only switch is the callable occurrence's descriptor: with a native address it executes natively, without one it is interpreted. The value of executing a file (its exit code) is the value of the root body's last evaluated expression; the root, like every callable Structure, declares no result, and `return` in it is bare only. A service profile may select an explicit function, `start`, a handler or a message send. The entry point receives control after its environment and runtime graph are prepared.

The model supports interpretation of the constructed L3 graph and translation preserving the same semantics. The interpreter executes L3 only: not source text, L1/L2 or `c.*` operations. The interpreter's implementation does not expand the language of the interpreted program. L2 defines machine mechanisms, L3 defines high-level programs, and L1 is an intermediate lowering stage toward C99. The parser, graph interpreter and translator serve different purposes. Grammatical forms, body boundaries, literals, comments and normalization are defined in the [grammar specification](LMX_grammar.en.md).

The levels relate as sets: L3 is a subset of L2. A named Structure and an anonymous Structure always belong to level L3; L2 operations -- address, machine, `c.*` -- are absent from an interpreted body, because the interpreter executes only L3; a compiled body may contain them. The `@` spelling of any depth (`@:`, `@@:`, `@@@:` ...) in L3 is a reference-declaration receiver only; its other uses are L2 operations and are prohibited in L3. Hence a Structure graph built from any profile is admissible to the L3 interpreter, while a method body may require native lowering.

<a id="l3-receiver"></a>
### L3 receiving expression

The L3 receiving expression defines the contract for consuming a constructed graph as an L3 program. It determines the supported subset and the selected profile's entry point; the mere presence of a syntax tree does not establish program admissibility. An unsupported operation does not become admissible because a machine implementation address exists. A restricted execution profile must explicitly report an unsupported construct rather than silently skip it or execute it as L2. This profile restriction does not replace the [single candidate-admission mechanism](#admission).

Execution follows resolved references and positions in the binary graph, not source names; the diagnostic address-to-name table does not participate in execution, as specified under [names and paths](#fields). A high-level operation may have an explicitly selected machine implementation with an L3 contract, as described at the [numeric/machine-operation boundary](#mathematics); this does not authorize arbitrary `c.*` calls from the interpreted program.

The executable graph representation uses physical references wherever possible. A numeric code is used only where a physical reference cannot be retained or transported; after such a code is resolved, subsequent execution again follows the resulting reference. Textual names do not participate in operation recognition, receiving-expression selection, or dispatch. An internal numeric implementation tag may be used as a local interpreter optimization, but it does not by itself establish the meaning of an L3 node.

The simplest script-profile program is:

```text
print: "Hello World"
```
@@ values | Значения, структуры и массивы | Values, Structures and Arrays | 2; 2.2.1; 2.2.2.6-7; 3.1-3.3; 12.1
[RU]
Структура — упорядоченная совокупность непосредственных полей. Поля содержат ссылки на значения: примитивные ячейки, другие структуры, массивы и записи методов. Лексическая вложенность образует лес; дополнительные ссылки соединяют его в граф с общими объектами и циклами. Примитивная ячейка не получает отдельную структуру-обёртку только потому, что на неё ссылается поле.

Массив содержит элементы одного типа. Его длина относится к элементам массива, а число полей структуры — к непосредственным полям структуры. Массив ссылок на массивы и прямоугольный многомерный массив — разные значения. Запись объявления различает их так: `T: [][]: x` — один прямоугольный многомерный массив, ровный и неотличимый от объемлющего его одномерного (как в C); `T: []: []: x` — два применения `[]:` создают два уровня самостоятельных одномерных массивов: внешний хранит ссылки на дескрипторы внутренних массивов `T`, у каждого внутреннего своя длина. Одномерный массив одномерных массивов — не двумерный массив. Правило общее для любого `T`; например, поле `char: []: []: mainArgs` — массив строк, где каждая строка — свой массив `char` с точной длиной `len` и без завершающего NUL (`LmxCharArray`, [L2 §5](L2_spec_ru.md#method-array)); NUL — форма двери `c.*`, не значения в графе. Детали представления и классификации ячеек по диапазонам адресов определены в [L2](L2_spec_ru.md#type-by-range).

Пустая структура — присутствующее значение с нулём полей. Она отличается от отсутствующего поля, числового нуля и `void`, означающего отсутствие содержимого примитивной ячейки. Список аргументов Frame сам является Structure; единственная анонимная Structure на месте всего списка прозрачна уже при нормализации P0: её поля становятся полями списка, независимо от головы и от того, пустая она или нет. Поэтому `f()`, `f: ()` и явно закрытое пустое вертикальное тело дают одно дерево с пустым телом; `f(a b)` и `f: (a b)` также дают один список. Анонимная Structure среди других полей или в именованной позиции остаётся отдельным значением. Для передачи пустой Structure как одного значения нужна такая непрозрачная позиция; см. [пустое тело](LMX_grammar.ru.md#empty-colon).

`None` — контекстное значение: его представление задаёт ожидаемый тип принимающего выражения. Единого кодирования для всех типов нет; тип без соответствующего определения `None` его не принимает. Число `0` остаётся нулём, в логических операциях — ложью, и не является общим признаком отсутствия. В прежнем профиле `Boolean` использует диапазон −1…1: `None = −1`, ложь — 0, истина — 1. Это конкретное определение профиля, а не универсальное кодирование всех отсутствующих значений.

Текст, изображение, десятичная запись и машинное слово до распознавания принимающим выражением являются исходным хранилищем данных. После разбора или декодирования они представлены значениями того же графа. Имена форматов и численных библиотек не вводят дополнительные фундаментальные виды значений.
[EN]
A Structure is an ordered collection of direct fields. Fields hold references to values: primitive cells, other Structures, Arrays and method records. Lexical nesting forms a forest; additional references connect it into a graph containing shared objects and cycles. A primitive cell does not acquire a Structure wrapper merely because a field references it.

An Array contains elements of one type. Its length counts Array elements, while a Structure's field count counts its direct fields. An Array of references to Arrays differs from a rectangular multidimensional Array. The declaration spelling tells them apart: `T: [][]: x` is one rectangular multidimensional Array, flat and indistinguishable from the one-dimensional Array containing it (as in C); `T: []: []: x` applies `[]:` twice and creates two levels of independent one-dimensional Arrays: the outer one holds references to the descriptors of the inner `T` Arrays, each with its own length. A one-dimensional Array of one-dimensional Arrays is not a two-dimensional Array. The rule is general for any `T`; for example the field `char: []: []: mainArgs` is an Array of strings, each string its own `char` Array with an exact `len` and no terminating NUL (`LmxCharArray`, [L2 §5](L2_spec_en.md#method-array)); a NUL is the form at the `c.*` door, not of a value in the graph. Representation details and address-range classification of cells are defined in [L2](L2_spec_en.md#type-by-range).

An empty Structure is a present value with zero fields. It differs from an absent field, numeric zero, and `void`, which denotes no primitive-cell content. A Frame's argument list is itself a Structure; the sole anonymous Structure occupying the entire list is transparent already in P0 normalization: its fields become the list's fields, independently of the head and whether it is empty. Thus `f()`, `f: ()`, and an explicitly closed empty vertical body yield one tree with an empty body; `f(a b)` and `f: (a b)` yield one list as well. An anonymous Structure among other fields or in a named position remains a distinct value. Passing an empty Structure as one value requires such a nontransparent position; see [empty bodies](LMX_grammar.en.md#empty-colon).

`None` is contextual: its representation is defined by the type expected by the receiving expression. There is no encoding shared by all types; a type without a corresponding definition of `None` does not accept it. The numeral `0` remains zero and means false in logical operations; it is not a universal absence marker. The earlier `Boolean` profile uses the range −1…1: `None = −1`, false is 0 and true is 1. This is a particular profile definition, not the universal encoding of missing values.

Text, images, decimal notation and machine words are substrate storage before recognition by a receiving expression. After parsing or decoding, they are values of the same graph. Format and numeric-library names do not introduce additional fundamental value kinds.
@@ identity | Идентичность и лексическое дерево | Identity and lexical trees | 2; 9.1.3; 19.29.1-2
[RU]
Живые структуры, записи массивов и локальные Message сохраняют физические адреса. Физический адрес записи является идентичностью Message внутри процесса; локальная идентичность не дополняется индексом родителя. Рост хранилища добавляет новые участки; существующие объекты не перемещаются. Равенство содержимого не означает тождества объектов. Явное копирование создаёт новые идентичности и сохраняет связи между ними по правилам [копирования](#composition). Иерархические цепочки индексов принадлежат только [WorldWideMix](#worldwide).

Лексический родитель определяет положение структуры в дереве; у корня родителя нет. Владение памятью и лексическое родство независимы. Присоединение хранилища другого Message сохраняет существующие лексические ссылки, не добавляет само по себе ссылку из корня получателя и не превращает присоединённый корень в лексического ребёнка получателя.

Отсечение внешнего лексического родителя при построении задаёт [квалификатор independent](#qualification); получение входов от вызывающего выражения подчиняется [динамической видимости](#dynamic). Эти механизмы не меняют отношения владения и тождества объектов.
[EN]
Live Structures, Array records, and local Messages retain their physical addresses. A record's physical address is the Message's in-process identity; local identity is not supplemented by a parent index. Storage grows by adding new regions; existing objects do not move. Equal contents do not imply object identity. Explicit copying creates new identities and preserves relationships under the [copying rules](#composition). Hierarchical index chains belong only to [WorldWideMix](#worldwide).

A lexical parent determines a Structure's position in its tree; a root has no parent. Storage ownership and lexical ancestry are independent. Attaching another Message's storage preserves existing lexical links, does not itself add a reference from the recipient's root and does not make the adopted root a lexical child of the recipient.

The [independent qualifier](#qualification) cuts the external lexical parent at construction; obtaining inputs from the caller follows [dynamic visibility](#dynamic). Neither mechanism changes storage ownership or object identity.
@@ fields | Имена, пути и повторные вхождения | Names, paths and repeated occurrences | 2.3; 13.1; 14.1; 21.1-2; 21.11
[RU]
Имена разрешают исходные обращения; исполнение следует полученным ссылкам и позициям. Диагностическое соответствие «адрес → короткое исходное имя» не является таблицей связывания переменных, типом или идентификатором исполнения. Конструирование, копирование и вызов не требуют регистрации исходного имени. Анонимные и позиционные значения не нуждаются в синтетических именах.

Структурный путь `object\field\nested` последовательно выбирает поля графа. Наличие каждого перехода и его допустимость определяются выбранным объектом. Вычисляемый путь не заменяется выдуманным статически известным именем. Зарезервированный `node` обозначает лексическое пространство над методом и остаётся одним и тем же во всей его активации; `node\field` начинает явный обход из этого пространства. Голое `field`, полученное по лексическому fallback, передаётся как скрытый аргумент текущей активации и не тождественно явному пути `node\field`.

`node` — зарезервированное слово языка. Его нельзя объявить, затенить, перепривязать или передать как динамическое одноимённое значение, в том числе посредством цитированного написания имени. При понижении это буквально обязательный первый параметр `Lmx *node` (на L1 — `@: Lmx node`): физическая ссылка на лексическое пространство над выбранным методом. Wrapper, closure или объект namespace между исходным `node` и этим адресом не вставляется. В рабочем графе каждое вызываемое вхождение, тело `if`, цикл и другая вложенная Structure отдельно хранит обычную ссылку `parent` на непосредственно объемлющую Structure. Для вызываемого вхождения эта ссылка задаёт над-методное пространство, передаваемое как `node`; ссылки `parent` вложенных тел могут вести по произвольной внутренней цепочке, но не меняют параметр `node` текущей активации. `parent` не является зарезервированным словом или доступным программе псевдонимом: это поле реализации, по которому работают лексическая и динамическая видимость. Голый `field`, пришедший скрытым аргументом, локален по отношению к вызывающему выражению и над-методному пространству. Если тело содержит разрешённое присваивание `field: value`, транслятор подготавливает own-поле этого тела, а исполнение связывает с ним локальный кэш и ставит `dirty`; контрольная точка публикует в это own-поле, но не в источник скрытого аргумента. Для явного изменения над-методного графа программа пишет `node\field: value`.

| Имя | Где существует | Значение |
| --- | --- | --- |
| `node` | зарезервированное слово L3 и первый ABI-параметр метода | пространство над методом; неизменно для всей активации, включая вложенные тела |
| `parent` | обычное поле каждой `Lmx` Structure рабочего графа | непосредственно объемлющая Structure; различается у метода, `if`, цикла и других вложенных тел |
| `self` | только скрытый ABI-контекст | экземпляр данных текущей активации; не слово языка |

Исполнение отдельно удерживает физическую ссылку на экземпляр данных текущей активации (§12). Это скрытый ABI-контекст, а не новое исходное имя `self` и не замена зарезервированного `node`.

Повторные исходные имена сохраняются. Неуточнённое `name` выбирает **последнее** вхождение имени, то есть эквивалентно `[lastIndex]name`; явный селектор `[N]name` нумерует вхождения в лексическом порядке: `[0]name` — первое, `[1]name` — второе. Номер вхождения имени отличается от физического номера поля среди всех полей. `merge` повторных имён не создаёт: одноимённое поле операнда записывается в слот модели (см. [композицию](#composition)). Изменение порядка различных имён не меняет именованный путь; изменение порядка одноимённых вхождений меняет выбранное значение. Вхождение создаёт только объявление: повторное голое присваивание тому же имени пишет в ту же ячейку и вхождением не является.

Число и расположение полей структуры фиксируются при создании. Порядок полей графа строго лексический; порядок выдачи нативного кода не разрешает переставлять поля самого графа. Обновление существующего поля заменяет содержащуюся в нём ссылку; оно не добавляет новое вхождение. Для иного набора полей создаётся новая структура. Операции над массивом следуют собственному контракту и не изменяют это правило структуры.
[EN]
Names resolve source-level accesses; execution follows the resulting references and positions. A diagnostic mapping from address to short source name is not a variable-binding table, a type or an execution identifier. Construction, copying and calls do not require source-name registration. Anonymous and positional values need no synthetic names.

A structural path `object\field\nested` selects graph fields in sequence. Each step's presence and validity are determined by the selected object. A computed path is not replaced by an invented statically known name. Reserved `node` denotes the lexical space above the method and stays fixed throughout that method activation; `node\field` starts explicit traversal in that space. A bare `field` obtained by lexical fallback is supplied as a hidden argument of the current activation and is not identical to the explicit `node\field` path.

`node` is a reserved language word. It cannot be declared, shadowed, rebound or dynamically supplied as a same-named value, including by quoted identifier spelling. In lowering it is literally the mandatory first `Lmx *node` parameter (`@: Lmx node` in L1): the physical reference to the lexical space above the selected method. No wrapper, closure or namespace object is inserted between source `node` and that address. In the working graph every callable occurrence, `if` body, loop and other nested Structure separately holds an ordinary `parent` link to its immediately enclosing Structure. For a callable occurrence that link supplies the above-method space passed as `node`; nested bodies may have an arbitrary internal `parent` chain, but that chain never rebinds the activation's `node` parameter. `parent` is neither a reserved language word nor a program-visible alias: it is an implementation field traversed by lexical and dynamic visibility. A bare `field` supplied as a hidden argument is local with respect to the caller and the above-method space. If the body contains a resolved assignment `field: value`, the translator prepares that body's own field, while execution binds the local cache to it and marks it `dirty`; the checkpoint publishes into this own field, never into the hidden argument's source. Mutating the above-method graph requires explicit `node\field: value`.

| Name | Where it exists | Meaning |
| --- | --- | --- |
| `node` | reserved L3 word and first method ABI parameter | space above the method; fixed for the whole activation, including nested bodies |
| `parent` | ordinary field of every working-graph `Lmx` Structure | immediately enclosing Structure; differs for a method, `if`, loop and other nested bodies |
| `self` | hidden ABI context only | the current activation's data instance; not a language word |

Repeated source names are retained. An unqualified `name` selects the **last** occurrence of the name, i.e. it is equivalent to `[lastIndex]name`; the explicit selector `[N]name` numbers occurrences in lexical order: `[0]name` is the first, `[1]name` the second. A name's occurrence number differs from the physical field index among all fields. `merge` creates no repeated names: an operand's same-name field is written into the model's slot (see [composition](#composition)). Reordering distinct names does not change a named path; reordering same-name occurrences changes the selected value. Only a declaration creates an occurrence: a repeated bare assignment to the same name writes into the same cell and is not an occurrence.

A Structure's field count and positions are fixed at construction. Graph fields follow strictly lexical order; native-code emission order does not authorize rearranging the graph's fields. Updating an existing field replaces its stored reference; it does not append an occurrence. A different set of fields requires a new Structure. Array operations follow their own contracts and do not change this Structure rule.

Execution separately retains the physical reference to the current activation's data instance (§12). This is hidden ABI context, not a new source name `self` and not a replacement for reserved `node`.
@@ descriptions | Явные описания значений и преобразования | Explicit value descriptions and conversions | 2.2.2-2.2.4; 2.4; 9.1; 9.1.1; 9.2
[RU]
Описание значения — обычная явно доступная структура. Принимающее выражение получает его через аргумент или ссылку. Описание не прикрепляется скрыто к каждому примитиву и не нужно для определения физического типа по адресу. Названия `class`, `class.range` и подобных таблиц обозначают данные конкретного профиля, а не обязательные глобальные сущности языка.

Описание разделяет семантический контракт и архитектурное представление. Контракт задаёт смысл: счётное число, целое, рациональное, число с выбранной точностью, комплексное, атом, адрес, непрозрачный ресурс или отсутствие содержимого. Представление задаёт ширину, знаковость, диапазон и обозначение целевого типа. Одинаковое представление не делает контракты одинаковыми: `Boolean` и `int8` могут храниться одинаково, но иметь разные допустимые значения.

Обычные поля описания включают `cell`, `semantic`, признаки `numeric`/`integer`/`floating`/`reference`/`opaque`, `width`, `signed`, `range`, `spelling` и ключи преобразований `convert`. Имена полей выбирает профиль. Указание диапазона является данными контракта; его выполнение проверяется [единым механизмом допуска](#admission), а не самим наличием поля.

Численная цепочка контрактов: флаг → неотрицательное целое → целое → рациональное → число с точностью профиля → комплексное. Неотрицательные целые включают ноль. Машинное `double` не является множеством всех вещественных чисел. Атомы, адреса и непрозрачные ресурсы — отдельные контракты, не ступени этой численной цепочки. `unit` — пустая структура; `void` — отсутствие содержимого ячейки.

Описания составляются обычным `merge` с общим правилом [порядка вхождений](#fields). Поля `width`, `range` или `spelling` не создают автоматически арифметические методы. Такие операции задаются вызываемыми выражениями. Пример `u32` сочетает неотрицательный целочисленный контракт, 32-битное представление и диапазон 0…4294967295; `FILE` описывает непрозрачную идентичность ресурса. Слово `FILE` само по себе не доказывает возможность чтения или закрытия: такие требования выражаются путями структуры `File`.

Преобразователь — явно выбранное принимающее выражение. Ключ преобразования поступает из явных описаний и их композиции; скрытого перебора всех пар типов нет. Аналитическая проверка не исполняет преобразователь. Если операция требует преобразования, выполняется выбранный вызов; отсутствие ключа не порождает несуществующий преобразователь. Поздний одноимённый ключ не вытесняет первый без явного выбора вхождения.

Численное преобразование сохраняет контракт диапазона назначения: `u16(255) → u8` допустимо при наличии преобразователя, `u16(256) → u8` даёт ошибку диапазона, а не ноль. Округление `1.5 → i32` и потеря точности внутри диапазона требуют отдельного правила численного профиля. Доказанная включённость диапазонов может исключать избыточную машинную операцию, сохраняя семантическое требование. Ошибки формата, диапазона и поведения преобразователя не заменяются положительным ответом `implements`.
[EN]
A value description is an ordinary explicitly accessible Structure. A receiving expression obtains it through an argument or reference. It is not secretly attached to every primitive and is unnecessary for determining a physical type from an address. Names such as `class` and `class.range` denote a particular profile's data, not mandatory global language entities.

A description separates its semantic contract from architecture binding. The contract defines meaning: count, integer, rational, profile-precision number, complex value, atom, address, opaque resource or absence of content. The binding defines width, signedness, range and target spelling. Equal representation does not imply equal contracts: `Boolean` and `int8` may share storage while admitting different values.

Ordinary description fields include `cell`, `semantic`, flags such as `numeric`/`integer`/`floating`/`reference`/`opaque`, `width`, `signed`, `range`, `spelling` and `convert` keys. The profile chooses field names. A range declaration is contract data; satisfaction is established through the [single admission mechanism](#admission), not by the field's presence alone.

The numeric contract chain is flag → nonnegative integer → integer → rational → profile-precision number → complex number. Nonnegative integers include zero. Machine `double` is not the set of all real numbers. Atoms, addresses and opaque resources are separate contracts, not rungs of this numeric chain. `unit` is an empty Structure; `void` denotes no cell content.

Descriptions are composed with ordinary `merge` under the common [occurrence-order rule](#fields). Fields such as `width`, `range` or `spelling` do not automatically create arithmetic methods. Such operations are callable expressions. For example, `u32` combines a nonnegative integer contract, 32-bit representation and range 0…4294967295; `FILE` describes opaque resource identity. A `FILE` word alone does not establish that reading or closing is valid: such requirements are expressed through paths of a `File` Structure.

A converter is an explicitly selected receiving expression. Conversion keys come from explicit descriptions and their composition; there is no hidden search across all type pairs. Analytical checking does not execute a converter. When an operation requires conversion, the selected call is executed; a missing key does not create a nonexistent converter. A later same-name key does not displace the first without explicit occurrence selection.

Numeric conversion preserves the destination-range contract: `u16(255) → u8` is admitted when the converter exists, while `u16(256) → u8` produces a range error, not zero. Rounding `1.5 → i32` and in-range precision loss require explicit numeric-profile rules. Proven range inclusion may eliminate a redundant machine operation while preserving the semantic requirement. Format, range and converter-behavior failures are not replaced by a positive `implements` result.
@@ conversion-context | Привязки типов и контекст преобразований на уровне Message | Message-local type bindings and conversion context | 2.2.3; 2.2.4; 7; 19.16
[RU]
В LMX нет процесс-глобального встроенного окружения типов, реестра преобразований, состояния инстанцирования generic-параметров или неявной системной таблицы. Описания типов, символические привязки типов, отношения преобразования и выражения, реализующие эти преобразования, — обычные явно переданные данные LMX.

У исполняющегося Message есть один контекст типов и преобразований для его графа. Этот контекст инициализируется из Structure, явно переданных Message при его построении. Начальный корень может предоставить исходные описания типов приложения, символические привязки, таблицы преобразований и связанные принимающие выражения, но дочерний Message не наследует их лишь потому, что был создан этим корнем или другим Message.

Если Message нужны такие данные, создающая операция обязана явно передать соответствующие Structure или ссылки по обычным правилам построения Message.

Концептуально:

```text
Root
    type descriptions
    symbolic type bindings
    conversion relations
    converter callables

        ↓ explicitly supplied

Message M
    application graph
    Message-local type bindings
    Message-local conversion context
```

Слово «общий» здесь означает общий для одного конкретного Message, а не глобальный для процесса.

### Устойчивые символические привязки типов

Символическое имя типа может быть привязано один раз в контексте типов Message и затем единообразно использоваться во всём этом Message.

Например, Message может содержать привязки:

```text
a -> int
b -> String
```

Каждое употребление `a` в этом Message разрешается через одну и ту же локальную для Message привязку, если явная операция языка не строит другой локальный контекст.

Привязка не выводится и не инстанцируется заново при каждом вызове функции.

Так, внутри одного Message:

```text
fn: identity (a: x) a
return: x
```

использует одну и ту же привязку `a` в каждом вхождении `a`.

Если этот Message привязывает:

```text
a -> int
```

то его действующий контракт:

```text
fn: identity (int: x) int
return: x
```

Другой Message может получить иную привязку:

```text
a -> String
```

не меняя первого.

Символическое имя типа, следовательно, обозначает устойчивое отношение внутри одного Message, а не процесс-глобальную переменную типа и не свежий generic-параметр, инстанцируемый независимо в каждом месте вызова.

Это правило не даёт разным частям одного исполняющегося графа молча приписать одному символическому имени типа разные значения.

### Обобщённость — обычный структурный случай

LMX не требует отдельной конструкции generic, шаблона или инстанцирования параметра типа, чтобы выражение принимало структурно различных кандидатов.

Выражение указывает только пути, значения, вызываемые операции, контракты результата и прочие свойства, которые действительно требует его Consumer. Допуск кандидата решает, выполнимы ли эти требования.

Поэтому структурная общность — обычный случай. Дополнительная информация о типе сужает принимаемую область, а не включает обобщённость.

Символическая привязка вроде `a` нужна лишь тогда, когда несколько позиций должны ссылаться на одно устойчивое локальное для Message отношение типов.

Например:

```text
fn: identity (a: x) a
return: x
```

утверждает, что вход и результат используют одну и ту же локальную привязку типа.

Напротив, выражение, которое просто потребляет требуемые ему поля и операции, не нуждается в искусственной переменной типа лишь для того, чтобы объявить себя обобщённым.

### Локальная для Message таблица преобразований

Таблица преобразований, используемая Message, — такие же явные локальные для Message данные.

Это не скрытый глобальный реестр, и она не разделяется неявно всеми Message.

Концептуально:

```text
Message M
    type bindings:
        a -> int
        b -> String

    conversions:
        int -> String
        String -> int
        Meter -> Foot
        Foot -> Meter
        ...
```

Фактическое представление остаётся обычными Structure, описаниями, отношениями, Table и вызываемыми выражениями LMX. Эта запись лишь иллюстрирует их роль.

Преобразование доступно операции, только когда конкретный Message может достичь соответствующего явно переданного описания/отношения/конвертера по обычным правилам графа.

Отсутствие преобразования в контексте Message не запускает поиск по всему процессу и не заставляет runtime его выдумывать.

### Преобразование и потребление кандидата

Когда Consumer требует значение описания T, кандидат не обязан исходно иметь тождественное примитивное или семантическое описание, если локальный для Message контекст преобразований явно предоставляет допустимый путь, принимаемый правилами Consumer.

Обычная последовательность:

```text
candidate value
    ↓
Consumer requirement
    ↓
explicitly available Message-local conversion
    ↓
conversion contract and range validation
    ↓
formed value satisfying the destination requirement
```

Конвертеры остаются обычными принимающими выражениями. Аналитическая проверка их не исполняет. Когда исполнение действительно требует преобразования, выбранный конвертер исполняется по своему объявленному контракту.

Диапазон, представление, единица, точность и прочие семантические ограничения принадлежат применимым описаниям и контрактам преобразования.

Успешный структурный допуск, следовательно, никогда не разрешает непроверенную переинтерпретацию примитивного хранилища.

### Единицы и семантические величины

Единицы измерения не требуют отдельного встроенного механизма ядра.

Message может явно получить описания и отношения преобразования для семантических величин, таких как:

```text
Meter
Foot
Second
Kilogram
```

Если локальный для Message контекст содержит допущенное преобразование вроде:

```text
Foot -> Meter
```

то операция, требующая Meter, может потребить значение, описанное как Foot, через этот обычный механизм преобразования.

Преобразование остаётся под своими обычными контрактами, включая диапазон, числовое представление, точность и любые условия конкретной единицы.

Ядру, следовательно, не нужен привилегированный список физических единиц. Преобразование единиц — одно из применений того же механизма описаний и преобразований, что и для других значений.

### Аргументы и результаты вызываемых выражений

Тот же локальный для Message контекст преобразований действует при формировании аргументов вызываемого выражения и потреблении его результата.

Для выбранного вызываемого выражения:

```text
actual value
    ↓
ordinary Message-local conversion if required
    ↓
formed argument
    ↓
exact selected callable argument contract
```

и при возврате:

```text
callable result
    ↓
ordinary Message-local conversion if required
    ↓
Consumer's required result contract
```

Это позволяет использовать вызываемое выражение, когда его исходные примитивные описания отличаются от описаний Consumer, при условии что конкретный Message содержит требуемые явные преобразования и все контракты преобразования успешны.

Например, Consumer может концептуально требовать:

```text
int -> int
```

тогда как выбранное вызываемое выражение имеет:

```text
String -> decimal
```

если этот Message явно предоставляет и допускает:

```text
int -> String
decimal -> int
```

Получившийся вызов остаётся полностью типизированным. Аргументы, предъявленные выбранному вызываемому выражению, должны удовлетворять его фактическому дескриптору после формирования, а значение, предъявленное Consumer результата, — требованию Consumer после преобразования результата.

### Граница Message

Привязки типов и доступность преобразований не пересекают границу Message молча.

Если Message A содержит:

```text
a -> int
```

и преобразование:

```text
String -> int
```

Message B не получает ни того, ни другого лишь потому, что A создаёт B, отправляет в B или является родителем B.

Они становятся доступны B, только если соответствующие Structure или ссылки явно переданы по применимому контракту создания или доставки Message.

Поэтому два Message могут намеренно исполнять одно и то же переиспользуемое выражение в разных контекстах типов и преобразований, оставаясь каждый внутренне согласованным.

Пример:

```text
Message A:
    a -> int

Message B:
    a -> decimal
```

Исходное выражение:

```text
fn: identity (a: x) a
return: x
```

может, следовательно, иметь разные конкретные привязки в A и B, но внутри каждого Message привязка остаётся устойчивой.

### Нет скрытого системного состояния

Реализация не вправе вводить в качестве альтернативного источника смысла ничего из следующего: процесс-глобальный реестр преобразований; неявное универсальное окружение переменных типа; автоматическое наследование контекста преобразований корня; повторное инстанцирование при каждом вызове уже привязанного в Message символического типа; скрытый поиск по провайдерам преобразований, недостижимым из Message; встроенное привилегированное знание единиц или классов семантических величин.

Реализация может кэшировать разрешённые привязки или выбор преобразований как оптимизацию, но наблюдаемый результат должен совпадать с разрешением явно переданных локальных для Message данных.

Источник смысла привязки или преобразования — всегда обычное достижимое состояние LMX.
[EN]
LMX has no process-global built-in type environment, conversion registry, generic-instantiation state, or implicit system table. Type descriptions, symbolic type bindings, conversion relations, and the expressions implementing those conversions are ordinary explicitly supplied LMX data.

An executing Message has one type-and-conversion context for its graph. That context is initialized from Structures explicitly supplied to the Message when it is constructed. The initial root may provide the application's initial type descriptions, symbolic bindings, conversion tables, and related receiving expressions, but a child Message does not inherit them merely because it was created by that root or by another Message.

If a Message requires such data, the creating operation must explicitly supply the corresponding Structures or references under the ordinary Message-construction rules.

Conceptually:

```text
Root
    type descriptions
    symbolic type bindings
    conversion relations
    converter callables

        ↓ explicitly supplied

Message M
    application graph
    Message-local type bindings
    Message-local conversion context
```

The word "common" in this context means common to one concrete Message, not global to the process.

### Stable symbolic type bindings

A symbolic type name may be bound once in the type context of a Message and then used consistently throughout that Message.

For example, a Message may contain the bindings:

```text
a -> int
b -> String
```

Every use of `a` in that Message resolves through the same Message-local binding unless an explicit language operation constructs a different Message-local context.

The binding is not repeatedly inferred or re-instantiated for each function call.

Thus, within one Message:

```text
fn: identity (a: x) a
return: x
```

uses the same binding of `a` at every occurrence of `a`.

If this Message binds:

```text
a -> int
```

then its effective contract is:

```text
fn: identity (int: x) int
return: x
```

Another Message may receive a different binding:

```text
a -> String
```

without changing the first Message.

A symbolic type name therefore represents a stable relation inside one Message, not a process-global type variable and not a fresh generic parameter instantiated independently at every call site.

This rule prevents separate parts of one executing graph from silently assigning different meanings to the same symbolic type name.

### Genericity is the default structural case

LMX does not require a separate generic, template, or type-parameter instantiation construct in order for an expression to accept structurally different candidates.

An expression states only the paths, values, callable operations, result contracts, and other properties that its Consumer actually requires. Candidate admission determines whether those requirements can be satisfied.

Consequently, structural generality is the ordinary case. Additional type information narrows the accepted domain; it does not activate genericity.

A symbolic binding such as `a` is required only when several positions must refer to one stable Message-local type relation.

For example:

```text
fn: identity (a: x) a
return: x
```

states that the input and result use the same Message-local type binding.

By contrast, an expression that merely consumes whatever fields and operations it requires does not need an artificial type variable solely to declare itself generic.

### Message-local conversion table

The conversion table used by a Message is likewise explicit Message-local data.

It is not a hidden global registry and is not implicitly shared by all Messages.

Conceptually:

```text
Message M
    type bindings:
        a -> int
        b -> String

    conversions:
        int -> String
        String -> int
        Meter -> Foot
        Foot -> Meter
        ...
```

The actual representation remains ordinary LMX Structures, descriptions, relations, Tables, and callable expressions. This notation only illustrates their role.

A conversion is available to an operation only when the concrete Message can reach the corresponding explicitly supplied description/relation/converter under the ordinary graph rules.

Absence of a conversion from the Message context does not trigger a process-wide search and does not cause the runtime to invent one.

### Conversion and candidate consumption

When a Consumer requires a value of description T, a candidate need not originate with an identical primitive or semantic description if the Message-local conversion context explicitly provides a valid path accepted by the Consumer's rules.

The ordinary sequence is:

```text
candidate value
    ↓
Consumer requirement
    ↓
explicitly available Message-local conversion
    ↓
conversion contract and range validation
    ↓
formed value satisfying the destination requirement
```

Converters remain ordinary receiving expressions. Analytical checking does not execute them. When execution actually requires the conversion, the selected converter is executed under its declared contract.

Range, representation, unit, precision, and other semantic constraints belong to the applicable descriptions and conversion contracts.

A successful structural admission therefore never authorizes unchecked reinterpretation of primitive storage.

### Units and semantic quantities

Units of measurement require no separate built-in kernel mechanism.

A Message may explicitly receive descriptions and conversion relations for semantic quantities such as:

```text
Meter
Foot
Second
Kilogram
```

If the Message-local context contains an admitted conversion such as:

```text
Foot -> Meter
```

then an operation requiring Meter may consume a value described as Foot through that ordinary conversion mechanism.

The conversion remains subject to its normal contracts, including range, numeric representation, precision, and any unit-specific conditions.

The kernel therefore needs no privileged list of physical units. Unit conversion is one application of the same description-and-conversion mechanism used for other values.

### Callable arguments and results

The same Message-local conversion context applies when forming callable arguments and consuming callable results.

For a selected callable:

```text
actual value
    ↓
ordinary Message-local conversion if required
    ↓
formed argument
    ↓
exact selected callable argument contract
```

and on return:

```text
callable result
    ↓
ordinary Message-local conversion if required
    ↓
Consumer's required result contract
```

This permits a callable to be used when its original primitive descriptions differ from the Consumer's descriptions, provided that the concrete Message contains the required explicit conversions and all conversion contracts succeed.

For example, a Consumer may conceptually require:

```text
int -> int
```

while the selected callable has:

```text
String -> decimal
```

if this Message explicitly provides and admits:

```text
int -> String
decimal -> int
```

The resulting call is still fully typed. The arguments presented to the selected callable must satisfy its actual descriptor after formation, and the value presented to the result Consumer must satisfy the Consumer's requirement after result conversion.

### Message boundary

Type bindings and conversion availability do not silently cross a Message boundary.

If Message A contains:

```text
a -> int
```

and a conversion:

```text
String -> int
```

Message B does not obtain either merely because A creates B, sends to B, or is B's parent.

They become available to B only if the relevant Structures or references are explicitly supplied under the applicable Message creation or delivery contract.

Therefore two Messages may intentionally execute the same reusable expression under different type-and-conversion contexts while each Message remains internally consistent.

Example:

```text
Message A:
    a -> int

Message B:
    a -> decimal
```

The source expression:

```text
fn: identity (a: x) a
return: x
```

may consequently have different concrete bindings in A and B, but within either Message the binding remains stable.

### No hidden system state

The implementation must not introduce any of the following as an alternative semantic source: a process-global conversion registry; an implicit universal type-variable environment; automatic inheritance of the root's conversion context; per-call re-instantiation of an already Message-bound symbolic type; a hidden search across conversion providers not reachable from the Message; built-in privileged knowledge of units or semantic quantity classes.

An implementation may cache resolved bindings or conversion selections as an optimization, but the observable result must be identical to resolving the explicitly supplied Message-local data.

The semantic source of a binding or conversion is always ordinary reachable LMX state.
@@ admission | Аналитическая проверка и валидация кандидата | Analytical checking and candidate validation | 2.1; 2.1.1-3; 2.5.1-3; 2.5.5-6; 19.21.3; 19.22; author 2026-09-20
[RU]
Единственный механизм допуска кандидата состоит из аналитического `implements` по дереву принимающего выражения и выполнения заданных этим выражением юнит-тестов через интерпретатор графа. Классификация адресов арены обслуживает представление значений; она не является альтернативной валидацией. Совпадение сигнатуры, наличие описания или положительный аналитический ответ не заменяют исполнение требуемых тестов.

<a id="analytical-tree"></a>
### Аналитическая часть

<a id="three-argument-implements"></a>
#### `implements(aVar, bVar, Consumer)`

`aVar` — предлагаемый кандидат, `bVar` — образец требуемой роли, а `Consumer` — конкретное принимающее выражение, для которого проверяется подстановка. Предикат направлен: он отвечает, можно ли предоставить `aVar` вместо `bVar` именно этому Consumer. Это не номинальная принадлежность типу, не равенство целых структур и не обещание пригодности для другого или любого будущего потребителя. Без Consumer область требований не определена, поэтому двухаргументная форма не задаёт эту модель.

Аналитическая часть строит множество `uses(Consumer, bVar)` из видимых в известном дереве Consumer обращений к `bVar`: `bVar`, `bVar\foo`, `bVar\foo\bar` и так далее. В него входят обращения во всех видимых альтернативных ветвях, а не только путь одного возможного запуска. Для аналитического результата должны одновременно выполняться условия:

```text
implements(aVar, bVar, Consumer) ⇔
    ∀ p ∈ uses(Consumer, bVar):
        present(aVar, p)
        ∧ (primitive_leaf(p) ⇒ leaf_consumption_admitted(aVar.p, Consumer, p))
        ∧ (invoked_callable(p) ⇒
            sig(aVar.p) = sig(bVar.p) = ExpectedSig(Consumer, p)
          )

admitted(aVar, bVar, Consumer) ⇔
    implements(aVar, bVar, Consumer)
    ∧ unit_tests(Consumer) ≠ ∅
    ∧ ∀ t ∈ unit_tests(Consumer):
        run_graph_test(t, aVar, bVar, Consumer) = PASS
```

Полная сигнатура вызываемого листа включает объявленные и динамические входы, их канонические имена, порядок и способы передачи, результат, выбрасываемые значения и целевой ABI. Адреса реализаций могут различаться; полные сигнатуры — нет. Если вызываемое значение только переносится как непрозрачное значение и здесь не вызывается, этот перенос не требует знания его будущих вызовов. Для примитивного листа простое чтение, передача, хранение или возврат являются тонким потреблением; следование по явным полям описания продолжает толстый путь и делает эти поля требованиями.

Неиспользуемые поля и методы `bVar`, значения за неиспользуемыми именами, порядок различно названных полей, невыбранные повторные вхождения, неиспользуемое вложенное содержимое, владение, изменяемость, эффекты и раскладка целевого языка не сравниваются. Пустое `uses(Consumer, bVar)` означает лишь отсутствие структурных требований аналитической части. Неизвестный вычисляемый путь не считается ни доказанным, ни заведомо тонким: он отдельно отмечается как непокрытый анализом.

Сам аналитический предикат не исполняет `aVar`, `bVar`, Consumer, вызываемые методы или преобразователи и не выбирает лучший кандидат среди прошедших. Положительный результат является только первым обязательным этапом. Окончательный допуск `aVar` требует вслед за ним успешного исполнения **всех** юнит-тестов, заданных этим Consumer, интерпретатором уже построенного графа; отсутствие набора тестов не считается успешной runtime-валидацией. В исполнении участвуют физические ссылки на кандидата и проверяющее выражение; исходный текст и runtime-имена не являются входом проверки. Отрицательный аналитический результат означает отсутствие допуска.

Проверка не подменяется сравнением одинаковых физических позиций. Перестановка различно названных полей при сохранении путей не меняет результат. Для повторных имён действует [выбор вхождения](#fields).

Сбор `uses` не расширяет тела всех вызываемых функций, не исполняет вычисляемые имена и не выполняет полный анализ псевдонимов и потока данных кучи.

Диагностика должна различать действительно тонкое использование и невозможность установить используемые пути. Она может показать, какая первая одноимённая ветвь выбрана после композиции, какие описательные поля не используются и какие требования остались неустановленными. Диагностика не вводит глобальный «строгий режим» и не меняет правила выбора поля.

На реально исполняемом вызове должны быть предоставлены все требуемые входы выбранного выражения. Равная сигнатура делает вызов допустимым, но не доказывает одинакового поведения реализаций.

<a id="graph-tests"></a>
### Исполнение тестов

Интерпретатор получает уже построенный граф исполняемых структур и связей. Разбор исходного текста предшествует этому этапу и не выполняет роль интерпретации. Принимающее выражение задаёт юнит-тесты, которые интерпретатор исполняет над кандидатом. Эти тесты выполняют содержательную runtime-валидацию: наличие поля с названием `range` или `unit` само по себе не доказывает соблюдение записанного ограничения.

Кандидат и проверяющее выражение имеют физическую идентичность. Успешная проверка не замораживает их состояние. Изменяемость, внешние эффекты и изменение использованных описаний должны учитываться условиями применения результата проверки. Способ повторного использования результатов, изоляция тестового исполнения и представление набора тестов требуют явного контракта; автоматическое разрешение этих вопросов из совпадения адресов не следует.

Обычные значения могут хранить результаты выполнения тестов, если это явно делает программа. Область применимости такого результата задаётся явным контрактом на идентичность кандидата, Consumer, набора тестов и проверенного состояния.

Статически установленное нарушение сообщается при анализе. Неуспех любого обязательного юнит-теста делает `admitted(aVar, bVar, Consumer)` ложным; объявленные отказы обрабатываются по правилам [исключений](#exceptions). Ни проверка, ни освобождение памяти не означают отката уже опубликованных сообщений или внешних эффектов.
[EN]
The single candidate-admission mechanism consists of analytical tree-based `implements` for the receiving expression and execution of that expression's unit tests by the graph interpreter. Arena address classification supports value representation; it is not alternative validation. A matching signature, an attached explicit description or a positive analytical answer does not replace execution of the required tests.

<a id="analytical-tree"></a>
### Analytical stage

<a id="three-argument-implements"></a>
#### `implements(aVar, bVar, Consumer)`

`aVar` is the proposed candidate, `bVar` is the exemplar of the required role, and `Consumer` is the concrete receiving expression for which substitution is checked. The predicate is directional: it answers whether `aVar` may be supplied in place of `bVar` to this particular Consumer. It is not nominal type membership, equality of whole Structures, or a promise of suitability for another or every future consumer. Without Consumer the requirement scope is undefined, so a two-argument form does not specify this model.

The analytical stage builds `uses(Consumer, bVar)` from the accesses to `bVar` visible in the known Consumer tree: `bVar`, `bVar\foo`, `bVar\foo\bar`, and so on. It includes accesses in every visible alternative branch, not only the path of one possible execution. The analytical result requires all of the following:

```text
implements(aVar, bVar, Consumer) ⇔
    ∀ p ∈ uses(Consumer, bVar):
        present(aVar, p)
        ∧ (primitive_leaf(p) ⇒ leaf_consumption_admitted(aVar.p, Consumer, p))
        ∧ (invoked_callable(p) ⇒
            sig(aVar.p) = sig(bVar.p) = ExpectedSig(Consumer, p)
          )

admitted(aVar, bVar, Consumer) ⇔
    implements(aVar, bVar, Consumer)
    ∧ unit_tests(Consumer) ≠ ∅
    ∧ ∀ t ∈ unit_tests(Consumer):
        run_graph_test(t, aVar, bVar, Consumer) = PASS
```

The complete callable-leaf signature includes declared and dynamic inputs, their canonical names, order and passing modes, result, thrown values, and target ABI. Implementation addresses may differ; complete signatures may not. If a callable value is merely transported as opaque data and is not invoked here, that transport does not require knowledge of its future calls. At a primitive leaf, plain reading, passing, storing, or returning is thin consumption; following explicit description fields continues a thick path and makes those fields requirements.

Unused fields and methods of `bVar`, values behind unused names, the order of differently named fields, unselected repeated occurrences, unused nested contents, ownership, mutability, effects, and target-language layout are not compared. Empty `uses(Consumer, bVar)` means only that the analytical stage has no structural requirements. An unknown computed path is neither certified nor classified as known-thin; it is reported separately as outside analytical coverage.

The analytical predicate itself executes none of `aVar`, `bVar`, Consumer, callable methods, or converters, and it does not rank the candidates that pass. A positive result is only the first mandatory stage. Final admission of `aVar` additionally requires the graph interpreter to execute successfully **all** unit tests defined by this Consumer against the already constructed graph; absence of a test set is not successful runtime validation. Execution receives physical references to the candidate and checking expression; source text and runtime names are not validation inputs. A negative analytical result means that admission fails.

Checking is not replaced by matching physical field positions. Reordering differently named fields while preserving paths does not change the result. Repeated names follow [occurrence selection](#fields).

Collection of `uses` does not expand every callee, execute computed names, or perform whole-heap alias and dataflow analysis.

Diagnostics should distinguish genuinely thin consumption from inability to establish used paths. They may show which first same-name branch composition selects, which descriptive fields are unused and which requirements remain unresolved. Diagnostics do not introduce a global strict mode or change field-selection rules.

An executed call must receive every input required by the selected expression. Equal signatures make the call admissible but do not prove equal implementation behavior.

<a id="graph-tests"></a>
### Test execution

The interpreter receives an already constructed graph of executable Structures and links. Parsing source text precedes this stage and does not serve as interpretation. The receiving expression defines unit tests for the interpreter to execute against the candidate. These tests provide substantive runtime validation: a field named `range` or `unit` does not by its presence prove that the stated constraint holds.

The candidate and checking expression have physical identities. Successful checking does not freeze their state. Mutation, external effects and changes to consulted descriptions must be accounted for by the conditions under which a result applies. Result reuse, isolation of test execution and representation of the test set require explicit contracts; matching addresses alone do not resolve them.

Ordinary values may store test results when the program explicitly does so. Applicability of such a result is defined by an explicit contract covering identity of the candidate, Consumer, test set, and checked state.

A statically established violation is reported during analysis. Failure of any mandatory unit test makes `admitted(aVar, bVar, Consumer)` false; declared failures follow the [exception rules](#exceptions). Neither validation nor memory reclamation rolls back already published messages or external effects.
@@ admission-recipes | Как получить требуемую гарантию: четырнадцать практических случаев | Obtaining a required guarantee: fourteen practical cases | 2.5.4; 2.5.3; author 2026-09-20
[RU]
Большинство вопросов о гарантиях сводится к практическому выбору: где именно провести различие, чтобы требуемое свойство действительно проверялось. Гарантия возникает не из глобального «строгого режима», а из части структуры, которую обязан пройти Consumer, и из тестов, которые задаёт принимающее выражение. Подобно тому как в C `typedef` лишь называет псевдоним, а оборачивающая `struct` создаёт отдельную проверяемую границу, в LMX существенны выраженный путь и контракт его потребления.

Следующие четырнадцать случаев являются рецептами: что следует выразить, чего такая запись не доказывает и где находится основное правило. Они применяют [единый механизм допуска](#admission): аналитическая часть проверяет используемые пути, затем интерпретатор графа обязательно исполняет юнит-тесты принимающего выражения.

### 1. Одно принимающее выражение для разных форм данных

Принимающее выражение записывается относительно путей, которые ему действительно нужны. Подходит любая структура, предоставляющая эти пути, допустимые листья и точные сигнатуры реально вызываемых выражений. Структуры одновременно являются обычными данными, материалом явных описаний и результатами композиции, поэтому контрактом служит используемое дерево. Отдельного объявления параметров обобщённого типа и отдельной операции инстанцирования нет. Проверка используемого дерева является механизмом структурного обобщения LMX, но не обещает всех свойств параметрического полиморфизма.

### 2. Понимание того, что проверяется в данном месте

Consumer определяет область аналитической проверки; неизвестное покрытие отличается от заведомо тонкого потребления. После анализа интерпретатор графа исполняет юнит-тесты того же принимающего выражения. Каждый реальный вызов дополнительно должен получить все требуемые сигнатурой входы. Эти этапы не поглощают друг друга: у них разные входы и область покрытия. Успех не замораживает кандидата или Consumer и не подтверждает будущие способы использования после их изменения.

### 3. Различение смыслов одинаково представимых значений

Различие кодируется именем пути, который действительно использует принимающее выражение. Для `Distance: Meter: 1` обращение `d\Meter` требует именно этого пути; структура только с `Foot` его не предоставляет. Одного внешнего имени `Meter`, поля `unit: "meter"` или квалификатора `const` недостаточно: наличие пути не сравнивает значение его листа. Если значение доступно и неизменно при сборке, анализ может заранее доказать точное равенство, но обязательные тесты остаются частью единого допуска; в остальных случаях содержательное ограничение проверяет тест принимающего выражения.

### 4. Ограничение скалярного листа

Ограничение формулируется явно и включается в тесты. Наличие `x\width` не доказывает `width = 32`: обход описания требует использованных путей, но терминальный скаляр может оставаться тонко потреблённым. Доступные при сборке неизменяемые данные можно предварительно анализировать и сравнивать точно, однако такое доказательство не объявляется альтернативным механизмом runtime-валидации.

### 5. Изменение, видимое другим держателям ссылки

Чтобы изменение увидели другие держатели значения, запись выполняется через явный путь: `p\x: value` или `a[i]: value` меняет выбранный референт. Разрешённое голое `x: value`, направленное в заранее типизированный явный либо скрытый аргумент, ещё при трансляции подготавливает одноимённое own-поле текущего тела; при исполнении строка связывает с ним локальный кэш, ставит `dirty` и на следующей контрольной точке публикует именно в это поле тела. Такая запись остаётся локальной по отношению к источнику: она не меняет аргумент вызывающего выражения и родительский граф. L3-ссылка объявляется отдельным принимающим выражением `@: Type var` и не является взятием адреса локальной переменной; полное правило находится в [рабочем состоянии](#dynamic). Поле не добавляется во время исполнения: состав графа уже зафиксирован транслятором.

### 6. Независимость от изменения другим держателем

`copy:` создаёт независимое изменяемое значение только в пределах собственного контракта копирования; настоящая неизменяемость запрещает изменение защищённого значения. Обычная передача структуры или массива копирует ссылку, не референт, поэтому внутри Message другой псевдоним может изменить общий изменяемый объект. Неизменяемость идентификатора внешнего ресурса не делает неизменяемым сам внешний ресурс.

### 7. Гарантия возможности вызова

Нужны оба условия: совместимость используемых путей и точной сигнатуры вызываемого выражения, а также наличие всех его динамических входов среди локальных значений вызывающего выражения, уже унаследованных входов или непосредственного `node\x` вызываемого вхождения. Пусть A и B предоставляют одинаковый `m`, тело которого использует голое `x`, а Consumer лишь вызывает `m`: проверка используемого вызываемого пути может пройти, но допуск вызова всё равно отвергнет отсутствие `x`. Известный случай отвергается при трансляции, динамически выбранная цель требует соответствующей runtime-границы. Это правило не добавляет разворачивание тела вызываемого выражения в `uses`.

### 8. Проверка передаваемого вызываемого значения

Передача вызываемого значения не является его исполнением и не требует знания всех требований будущего вызова. Проверка выполняется на реальном вызове: выбранное выражение должно иметь точную сигнатуру, получить все динамические входы и пройти применимый допуск, даже если прежняя частичная проверка его не исследовала. Одинаковые сигнатуры не означают одинакового поведения.

### 9. Изменение тела метода без нарушения вызовов

Свободные динамические имена тела входят в его интерфейс. Добавление такого имени меняет `DynRequired`, а следовательно и `sig`; известные вызывающие выражения требуется проверить заново, динамически выбранные остаются под допуском фактического вызова. Неизменяемость записи метода не делает неизменяемым каждое ссылающееся на неё вхождение и не запрещает явную замену ссылки на совместимое вызываемое значение. Изменение поведения при прежней сигнатуре остаётся вопросом тестов и правильности программы.

### 10. Выбор нужной части композиции

Нужное поле выбирается явно либо строится нужный набор полей. `merge` создаёт новое дерево и не меняет операнды; одноимённое поле более позднего операнда переопределяет слот модели на месте (специализация), новых вхождений того же имени не возникает. Если модель A содержит `read`, а B — тоже `read` совместимого типа, `result\read` — слот A со значением из B; `read` без соответствия в модели дописывается в конец. Аналитическая диагностика может обнаружить непреднамеренный неквалифицированный выбор после изменения импорта или композиции. Исходные части не обязаны быть соседними или статически доступными.

### 11. Изменение существующей структуры

Число полей и их слоты фиксированы. Обычные полевые операции могут заменять содержащиеся в них ссылки `void *`; изменение фактического типа цели подчиняется обычным правилам таких обновлений и последующего потребления. Иное число полей требует новой структуры, например результата `merge`. Не вводится политика разрешения конфликтов для несуществующих операций «удалить или переместить активное поле».

### 12. Надёжное численное преобразование

Используется доступный преобразователь по явному ключу с контрактом диапазона назначения: `u16(255) → u8` допустимо, `u16(256) → u8` — ошибка диапазона, а не ноль. Округление и потеря точности внутри диапазона задаются отдельной политикой численного профиля. Прохождение аналитической проверки не даёт разрешения молча обернуть значение по модулю.

### 13. Значение широкой таблицы преобразователей

Дополнительные явные ключи расширяют только набор допустимых преобразований листьев. Они не меняют требуемые структурные пути и точные сигнатуры вызываемых выражений; профиль не обязан предоставлять все пары. Ни аналитическая часть, ни тест выбора пути не исполняют преобразователь и не ищут скрытую цепочку преобразований.

### 14. Корректность внешнего ресурса

Для внешнего дескриптора нужны проверяемая высокоуровневая обёртка и явный контракт ресурса и очистки. Тонкий лист наподобие `FILE` не доказывает действительность ресурса, полномочия или однократность закрытия. Юнит-тесты принимающего выражения проверяют заявленные свойства в пределах своего контракта; неизменяемые биты дескриптора не удерживают ресурс живым. В L3 нет обычных машинных `own:`/`borrow:`/`move:`, а `copy:` не изобретает способ дублирования внешнего ресурса.
[EN]
Most questions about guarantees reduce to a practical choice: where must a distinction be placed so that the required property is actually checked? A guarantee does not arise from a global strict mode; it arises from the part of a Structure that Consumer must traverse and from the tests defined by the receiving expression. Just as a C `typedef` merely names an alias while a wrapping `struct` creates a separately enforced boundary, LMX relies on the expressed path and its consumption contract.

The following fourteen cases are recipes: what to express, what that expression does not establish, and where the governing rule lives. They apply the [single admission mechanism](#admission): its analytical stage checks used paths, then the graph interpreter must execute the receiving expression's unit tests.

### 1. One receiving expression for multiple data shapes

Write the receiving expression against the paths it actually needs. Any Structure providing those paths, admitted leaves and the exact signatures of expressions actually invoked can qualify. Structures are ordinary data, material for explicit descriptions and results of composition, so the used tree is the contract. There is no separate generic type-parameter declaration or instantiation operation. Used-tree checking is LMX's structural-generalization mechanism, not a promise of every property of parametric polymorphism.

### 2. Knowing what a particular site checks

Consumer determines analytical coverage; unknown coverage is distinguished from known thin consumption. Analysis is followed by the graph interpreter executing that same receiving expression's unit tests. Every actual call must additionally receive all inputs required by its signature. These stages do not subsume one another: they have different inputs and coverage. Success neither freezes candidate or Consumer nor certifies future uses after either changes.

### 3. Distinguishing meanings with the same representation

Encode the distinction in a path the receiving expression actually uses. With `Distance: Meter: 1`, access through `d\Meter` requires that path; a Structure exposing only `Foot` does not provide it. An outer name `Meter`, a field `unit: "meter"` or `const` alone is insufficient: path presence does not compare the value at its leaf. Immutable build-time data may permit preliminary proof of exact equality, but mandatory tests remain part of unified admission; otherwise a receiving-expression test checks the substantive constraint.

### 4. Constraining a scalar leaf

State the constraint explicitly and include it in tests. Presence of `x\width` does not establish `width = 32`: traversing a description requires its used paths, but a terminal scalar may remain thinly consumed. Immutable build-time data may undergo preliminary analysis and exact comparison, but such a proof is not an alternative runtime-validation mechanism.

### 5. Making a change visible to other reference holders

To make a change visible to other holders, write through an explicit path: `p\x: value` or `a[i]: value` changes the selected referent. A resolved bare `x: value` targeting an already typed explicit or hidden argument makes the translator prepare a same-name own field of the current body; when executed, the statement binds the local cache to that field, marks it `dirty`, and publishes specifically into the body's field at the next checkpoint. The write remains local with respect to its source: it changes neither the caller's argument nor the parent graph. An L3 reference is declared by the distinct receiver `@: Type var`, not by taking the address of a local variable; the complete rule is under [working state](#dynamic). Execution does not append the field: translation has already fixed the graph layout.

### 6. Independence from another holder's mutation

`copy:` creates an independent mutable value only within its copying contract; genuine immutability prohibits mutation of the protected value. Ordinary Structure or Array passing copies the reference, not the referent. Another alias within the Message can therefore change the shared mutable object. An immutable foreign-resource identifier does not make the foreign resource immutable.

### 7. Establishing that a call can proceed

Both conditions must hold: compatibility covers used paths and the callable's exact signature, and every dynamic input must be available from caller locals, inherited inputs or that callable occurrence's immediate `node\x`. Suppose A and B expose the same `m`, whose body uses bare `x`, while Consumer only invokes `m`: the used-callable check can pass while call admission still rejects a missing `x`. A known case is rejected during translation; a runtime-selected target requires the corresponding runtime boundary. This rule does not add callee-body expansion to `uses`.

### 8. Checking a transported callable

Transporting a callable neither executes it nor requires knowledge of every future call contract. Checking occurs at the actual call: the selected expression must have the exact signature, receive every dynamic input and satisfy applicable admission, even if an earlier partial check never inspected it. Equal signatures do not imply equal behavior.

### 9. Changing a method body without breaking calls

The body's free dynamic names are part of its interface. Adding one changes `DynRequired` and therefore `sig`; known callers require rechecking, while runtime-selected callables remain subject to actual-call admission. An immutable method record neither makes every occurrence referring to it immutable nor prohibits explicit replacement of a reference with a compatible callable. Behavioral change under the same signature remains a matter for tests and program correctness.

### 10. Selecting the intended part of a composition

Select the field explicitly or construct the intended fields. `merge` builds a new tree and does not mutate its operands; a later operand's same-name field overrides the model's slot in place (specialization), and no new occurrence of that name arises. If model A has `read` and B has a `read` of a compatible type, `result\read` is A's slot holding B's value; a `read` with no counterpart in the model is appended at the end. Analytical diagnostics may expose an unintended unqualified selection after an import or composition changes. Source parts need not be adjacent or statically available.

### 11. Changing an existing Structure

Field count and slots are fixed. Ordinary field operations may replace the `void *` child references stored in existing fields; a change in the target's actual type follows the ordinary rules for such updates and later consumption. A different field count requires a new Structure, such as a `merge` result. No conflict policy is introduced for nonexistent operations that remove or move an active field.

### 12. Reliable numeric conversion

Use an available explicitly keyed converter with a destination-range contract: `u16(255) → u8` is admitted, while `u16(256) → u8` is a range error, not zero. In-range rounding and precision loss are a separate numeric-profile policy. Successful analytical checking does not permit silent modular wrapping.

### 13. What a broad converter table provides

Additional explicit keys widen only the available leaf conversions. They do not alter required structural paths or exact callable signatures, and a profile need not provide every pair. Neither analytical checking nor path-selection tests execute a converter or search for a hidden conversion chain.

### 14. Foreign-resource validity

A foreign handle requires a checked high-level wrapper and explicit resource and cleanup contracts. A thin `FILE`-like leaf does not establish validity, authority or single close. The receiving expression's unit tests check declared properties within their contract; immutable handle bits do not keep a resource alive. L3 has no ordinary machine-level `own:`/`borrow:`/`move:`, and `copy:` does not invent a foreign resource's duplication policy.

@@ construction | Построение значений | Value construction | 9.1–9.2; 19.20
[RU]
Структурное выражение строит значение, когда исполнение достигает этого выражения. Объявление имени, импорт или наличие описания не создаёт заранее все экземпляры. Именованные и анонимные ветви создаются единственным механизмом полного `merge`: определяется лексический родитель, обходится полное используемое замыкание графа, создаются поля с устойчивой идентичностью, вычисляются инициализаторы в исходном порядке, переписываются ссылки и `parent`, после чего публикуется полностью инициализированный результат. У корня `independent` поле `parent` равно нулю (`parent = 0`); именно это означает отсутствие внешнего лексического родителя.

Блочная, короткая и скобочная записи создают одну и ту же общую форму «голова принимает хвост»; пунктуация не определяет роль головы. После построения Frame роль выбирается по разрешённой голове в строгом порядке: (1) найденное callable-поле вызывается; (2) найденная non-callable привязка получает присваивание; (3) объявление возможно только через конструкцию, которая сама явно задаёт тип. Если имя головы отсутствует и такая объявляющая конструкция неприменима, это ошибка неизвестного имени/типа. Значение справа никогда не выводит тип новой переменной: в языке нет `var`. Само двоеточие, скобки или переход уровня не объявляют, не присваивают и не вызывают. Одноимённое заранее подготовленное физическое место не считается активной логической привязкой. Здесь callable/non-callable означает наличие или отсутствие интерфейса вызова **головы Frame**; общая возможность исполнить именованную Structure голым атомом (§10) не переклассифицирует её голову.

`f()` само по себе не означает вызов: это Frame с головой `f` и пустым Structure-телом, синтаксически равный `f: ()` и явно закрытому пустому вертикальному телу. Если `f` разрешено как callable-поле с интерфейсом вызова Frame, получается нульарный вызов. Если `f` уже существует как обычная Structure без такого интерфейса, применяется обычное присваивание пустой Structure с `implements`/admission. Если `f` отсутствует, пустое Structure-тело само явно задаёт структурный тип и объявляется новая пустая структурная переменная `f`. Так `f()` при отсутствующем `f` — объявление, а не неудавшийся вызов; ни одна из трёх операций не выбирается по скобкам. При найденном callable-поле ошибка его сигнатуры остаётся ошибкой вызова без перехода к следующим правилам. Исполнение именованной Structure голым `f` не меняет смысл `f()` и `f: ()`.

В контексте структурной переменной `target: value` сначала разрешается `target`. Если такой переменной ещё нет, а `value` является Structure, создаётся структурная переменная `target`; её тип уже задан самой Structure справа. Пустая Structure подчиняется тому же правилу, без `KnownModel`, зарезервированного имени или отдельной ветки: `target: ()`, эквивалентная пустая вертикальная форма и форма с допустимым `end: target` создают то же пустое структурное значение. Это один общий маршрут объявления. Второй общий маршрут явно задаёт тип головой: `Model: fresh` и `Model(fresh)` — синонимы и проходят одинаковое разрешение `Model`. Если `Model` callable, применяется уже выбранный высший приоритет вызова. Если `Model` является non-callable моделью/типом, а `fresh` отсутствует, конструкция объявляет структуру `fresh` типа `Model`. Полное значение получается общим `merge` модели с пустой Structure: это следствие строгой типизации и единственного полного механизма построения, а не дополнительное правило языка и не исключение для имён `Model` или `fresh`. Явная ссылка на модель сама по себе не может присвоиться неизвестному `fresh`, потому что до объявления у `fresh` нет известного типа принимающего выражения; после явного объявления ссылочное присваивание следует обычному admission. Оба маршрута одинаково действуют в блочной, короткой и скобочной форме. Создание непримитивного значения полностью материализует предусмотренную контрактом память/граф; оно не является присваиванием одной ссылки. Другие формы объявления определяет соответствующий receiver типа/конструктора, а неизвестный тип отвергается.

Если `target` уже имеет активную non-callable привязку, `value` вычисляется как кандидат, а операция является присваиванием только при выполнении контракта этой цели. До любой записи выполняется полный `implements(value, target, Consumer)`; кешированные физические адреса и оптимизированное локальное хранение не отменяют семантический вызов допуска. При неуспехе цель и её `dirty` не меняются. Для примитива записывается значение; для Structure, Array и другого non-callable ссылочного значения перепривязывается ссылка без неявного `merge`, копирования референта или смены владельца. Structure/Array уже являются ссылочными значениями: передача аргумента и возврат копируют физическую ссылку на дескриптор/вхождение, а не непримитивный объект по значению. Поэтому L1-проекция непримитивного значения не использует C by-value aggregate; концептуально Structure-привязка уже имеет вид `Lmx *`, а её `@` адресует ячейку ссылки и даёт следующий уровень `Lmx **`. Внутренние C ABI-записи ядра по значению относятся к машинной реализации, не к этой проекции. Поэтому `arg: 7` допустимо только при заранее объявленном типизированном явном **или скрытом** non-callable аргументе `arg`; это присваивание. При отсутствующем `arg` запись `arg: 7` является ошибкой: литерал `7` не объявляет переменную и не предоставляет отсутствующий тип. Объявление примитива должно явно назвать тип, например `int: arg 7`. Транслятор обязан знать контракт и место привязки, хотя физическая ссылка динамического значения может стать известна лишь при вызове. Исполнение голого присваивания связывает локальный кэш с подготовленным own-occurrence и ставит `dirty`; источник аргумента вызывающего выражения не изменяется.

Найденное callable-поле имеет высший приоритет: `ping: 7`, `ping(7)` и эквивалентная блочная форма вызывают `ping` с аргументом `7`. Если аргумент не проходит сигнатуру или admission, это ошибка вызова без перехода к присваиванию или объявлению. Такая запись никогда не означает прямое присваивание callable-полю. Callable заменяется только общими структурными механизмами: полным `merge`, где более поздняя структура предоставляет одноимённый `ping` и проходит `implements`; динамической перегрузкой из вызывающего контекста, если вызывающий уже предоставляет одноимённый callable; либо явной передачей callable в дескрипторе аргументов вызывающего выражения. Отдельный синтаксис перепривязки callable-поля не вводится.

Двоеточие строит вложенную форму применения. В `const: char: []: s "hello" "world!"` операции квалификации, выбора элемента и построения массива имеют собственные контракты. `char` задаёт примитивный элемент, `String` — высокоуровневое неизменяемое текстовое значение; `String` не является другим написанием машинного `char *`. `String: ()` строит структуру ссылок, а `String: []` — массив ссылок согласно соответствующим конструкторам.

Поле может удерживать ссылку на уже существующий объект. Это не копирование и не переподчинение его лексического родителя. Пустая структура существует как значение и не равна отсутствующему аргументу. В следующем построении два поля `count` сохраняются: `result\count` выбирает 3, `result\[1]count` — 4.

```text
(): result
    int: count 3
    String: text "hello"
    int: count 4
end: result
```

Именование не добавляет к объекту дескриптор, класс или специальную раскладку. Построение ветви является частным применением [полного `merge`](#composition), а не отдельным сокращённым конструктором; отличие исходной формы состоит в выборе операнда, предлагаемого имени и места публикации результата. Политика повторного вычисления и повторного использования значения верхнеуровневого именованного построения ещё требует определения; предварительное создание всех значений при трансляции из этого не следует.
[EN]
A structural expression constructs a value when execution reaches it. Declaring a name, importing a unit or providing a description does not eagerly create every instance. Named and anonymous branches are created by the sole full-`merge` mechanism: determine the lexical parent, traverse the complete used graph closure, create fields with stable identity, evaluate initializers in source order, rewrite references and `parent`, and publish the fully initialized result. An `independent` root has `parent = 0`; that is exactly what absence of an external lexical parent means.

Block, short, and parenthesized spellings create the same generic “head consumes tail” form; punctuation does not determine the head's role. After constructing the Frame, the role is selected from the resolved head in strict order: (1) an existing callable field is invoked; (2) an existing non-callable binding is assigned; (3) declaration is possible only through a construct that explicitly supplies the type. If the head name is absent and no such declaring construct applies, the result is an unknown-name/type error. A value on the right never infers the type of a new variable: the language has no `var`. The colon, parentheses, or source-level transition itself neither declares nor assigns nor invokes. A same-named preallocated physical location is not an active logical binding. Here callable/non-callable means presence or absence of a **Frame-head call** interface; the general ability to execute a named Structure through its bare atom (§10) does not reclassify its head.

`f()` does not mean a call by itself: it is a Frame headed by `f` with an empty Structure-body, syntactically equivalent to `f: ()` and an explicitly closed empty vertical body. If `f` resolves to a callable field with a Frame-call interface, it is invoked without arguments. If `f` already binds an ordinary Structure without that interface, ordinary assignment of the empty Structure applies, with `implements`/admission. If `f` is absent, the empty Structure-body itself explicitly supplies a structural type and declares a new empty structural variable `f`. Thus `f()` with an absent `f` is a declaration, not a failed call; parentheses select none of the three operations. Once a callable field is found, a signature error remains a call error without falling through to the later rules. Executing a named Structure through bare `f` does not change the meaning of `f()` or `f: ()`.

In structural-variable context, `target: value` first resolves `target`. If that variable does not yet exist and `value` is a Structure, a structural variable named `target` is created; its type is already supplied by the Structure on the right. An empty Structure follows the same rule without `KnownModel`, a reserved name, or a separate branch: `target: ()`, the equivalent empty vertical form, and a form with an admitted `end: target` construct the same empty structural value. This is one general declaration route. A second general route supplies the type through the head: `Model: fresh` and `Model(fresh)` are synonyms and resolve `Model` identically. If `Model` is callable, the already selected highest call priority applies. If `Model` is a non-callable model/type and `fresh` is absent, the construct declares Structure `fresh` with type `Model`. The complete value is obtained by the general merge of the model with an empty Structure: this follows from strict typing and the sole full-construction mechanism rather than adding a language rule or an exception for the names `Model` and `fresh`. A model reference cannot by itself be assigned to unknown `fresh`, because before declaration `fresh` has no known receiving type; after explicit declaration, reference assignment follows ordinary admission. Both routes apply equally to block, short, and parenthesized forms. Constructing a nonprimitive value fully materializes the memory/graph required by its contract; it is not a one-reference assignment. Other declaration forms are defined by their type/constructor receiver, and an unknown type is rejected.

If `target` already has an active non-callable binding, `value` is evaluated as the candidate and the operation is assignment only when that target's contract admits it. Before any write, full `implements(value, target, Consumer)` is performed; cached physical addresses and optimized local storage do not remove the semantic admission call. On failure neither the target nor its `dirty` state changes. A primitive stores its value; a Structure, Array, or other non-callable reference value rebinds the reference without implicit `merge`, referent copying, or ownership transfer. Structure/Array values are already reference-valued: argument passing and return copy the physical reference to the descriptor/occurrence rather than passing a nonprimitive object by value. L1 projection of a nonprimitive language value therefore does not use a C by-value aggregate; conceptually a Structure binding is already `Lmx *`, and applying `@` addresses that reference slot and produces the next `Lmx **` level. Internal by-value C ABI records of the kernel belong to machine implementation, not this projection. Thus `arg: 7` is valid only for a previously declared and typed explicit **or hidden** non-callable argument `arg`; this is assignment. When `arg` is absent, `arg: 7` is an error: literal `7` neither declares a variable nor supplies a missing type. A primitive declaration must name its type explicitly, for example `int: arg 7`. Translation must know the contract and binding location even when a dynamic value's physical reference becomes known only at call time. Executing a bare assignment binds the local cache to the prepared own occurrence and marks it `dirty`; it does not mutate the caller's argument source.

An existing callable field has highest priority: `ping: 7`, `ping(7)`, and the equivalent block form invoke `ping` with argument `7`. If the argument fails the signature or admission contract, this is a call error with no fallback to assignment or declaration. Such a form never directly assigns the callable field. A callable is replaced only through general structural mechanisms: full `merge`, where the later Structure supplies a same-named `ping` and passes `implements`; dynamic override from the calling context when the caller already provides a same-named callable; or explicit callable transport in the calling expression's argument descriptor. No separate callable-rebinding syntax is introduced.

The colon builds a nested application form. In `const: char: []: s "hello" "world!"`, qualification, element selection and Array construction have their respective contracts. `char` selects a primitive element; `String` denotes a higher-level immutable text value, not another spelling of machine `char *`. `String: ()` constructs a Structure of references, whereas `String: []` constructs an Array of references under the respective constructors.

A field can retain a reference to an existing object. This neither copies it nor reparents its lexical parent. An empty Structure is a present value, not an absent argument. In the following construction both `count` fields remain: `result\count` selects 3 and `result\[1]count` selects 4.

```text
(): result
    int: count 3
    String: text "hello"
    int: count 4
end: result
```

Naming does not add a descriptor, class or special layout to the object. Branch construction is a particular use of [full `merge`](#composition), not a separate shortened constructor; the source form selects the operand, proposed name and publication site. The evaluation/reuse policy of a top-level named construction still requires definition; eager materialization of every value during translation does not follow from it.

@@ qualification | const, immutable и independent | const, immutable and independent | 2.5.3; 9.1.2–9.1.3
[RU]
`const` защищает привязку: её нельзя присвоить, перепривязать или заменить. Значение за защищённой ссылкой может оставаться изменяемым. `immutable` защищает само значение на протяжении всей его жизни, через любые псевдонимы; переменная, содержащая ссылку на него, может оставаться перепривязываемой. `const: immutable` объединяет обе гарантии. Это независимые квалификации, а не ступени одной шкалы.

Неизменяемость применима к примитиву, структуре и выбранному дереву, массиву с дескриптором и элементами. Она охватывает позиционные поля, все одноимённые вхождения и явно включённые описания, а не только пути Consumer или первое вхождение. Передача, возврат и сохранение неизменяемого значения сохраняют его идентичность; квалификация не требует копии, в том числе для примитива. Она не замораживает внешний ресурс, обозначенный неизменяемым идентификатором.

`immutable` при построении квалифицирует новое значение до публикации. `RuntimeImmutable` квалифицирует уже существующее дерево с сохранением его идентичности. Название второй операции не обозначает второй механизм допуска аргументов: её собственный операционный контракт — изменение квалификации. Её аргументы проходят [единый допуск](#admission), как аргументы любого принимающего выражения.

Перед изменением квалификации исследуется всё выбранное дерево. Вложенная структура является ветвью дерева только тогда, когда её обычное структурное поле `parent` указывает на рассматриваемого родителя. Внешняя ссылка допустима только на уже неизменяемый объект; она терминальна, её цель не обходится и не переквалифицируется. Проверяется состояние до начала изменения: результат обработки раннего поля не может оправдать недопустимую внешнюю ссылку в позднем. Некорректная вложенность или изменяемая внешняя цель приводят к объявленному `throw`, а не к `assert`.

Примитивы и методы — листья, не ветви лексического дерева. Ссылка на массив также не создаёт ветвь `parent`: операция над деревом не замораживает неявно изменяемое хранилище внешнего массива. Неизменяемый массив строится по собственному контракту. Принадлежность ячейки служебному пулу не даёт права обходить или квалифицировать весь пул.

Квалификация применяется только после успешной полной предварительной проверки. При неудаче нет частично замороженного дерева и опубликованного успешного результата; запрещено молча пропускать ветвь, копировать её или перенаправлять ссылки. Повторная квалификация уже подходящего дерева ничего не меняет. Правило не откатывает ранее выполненные инициализаторы, вычисление аргументов или публикацию рабочих полей перед вызовом; транзакция графа не возникает.

Защита обязательна для записей через любой путь. Заведомо недопустимая запись отвергается до исполнения, динамически выбранная — проверяется при исполнении. Вызов метода разрешён, но не снимает защиты. Изменение локальной копии аргумента или перепривязка локальной ссылки не меняют защищённое значение. Построение нового значения, в том числе `merge`, не размораживает исходное.

`independent` при построении устанавливает у корня `parent = 0`; это и есть отсутствие внешнего лексического родителя. Внутренние связи `parent` дерева и собственные поля сохраняются. Квалификация не обнуляет задним числом `parent` уже существующих объектов и не запрещает явно переданные ссылки, динамические аргументы текущего вызывающего выражения, сообщения или выбор вызываемого выражения по совместимой сигнатуре. Это не требование чистоты и не закрытый интерфейс только из явных аргументов.

`const`, `immutable` и `independent` являются принимающими выражениями; их композиция задаёт квалифицированный тип результата. Физическое представление этого типа определяется общим механизмом попадания адреса в типизированный диапазон, описанным в [L2](L2_spec_ru.md#type-by-range), а не отдельными признаками на каждом значении или особым классификатором для конкретной цепочки квалификаторов. Идентичность самого диапазона является типовой областью; для каждой композиции квалификаторов не вводится новый код перечисления. Нулевой `parent` корня остаётся структурным следствием `independent`, а не заменой классификации типа.

Например, метод внутри независимой структуры S может использовать поле S через внутреннюю лексическую связь. Требуемое `x` может прийти из текущего вызывающего выражения. Если `x` находится только в прежнем текстовом окружении S, внешнего неявного доступа к нему нет. Явно переданный большой массив не становится меньше и не копируется из-за `independent`. Особый срок жизни сочетания трёх квалификаций описан в [вечных ветвях](#eternal).
[EN]
`const` protects a binding: it cannot be assigned, rebound or replaced. The value behind a protected reference may remain mutable. `immutable` protects the value itself for its entire life through every alias; a variable holding its reference may remain rebindable. `const: immutable` combines both guarantees. They are independent qualifications, not degrees of one scale.

Immutability applies to a primitive, a Structure and its selected tree, or an Array with its descriptor and elements. It covers positional fields, every repeated occurrence and explicitly included descriptions, not just Consumer's paths or the first occurrence. Passing, returning and storing an immutable value preserve its identity; qualification requires no copy, including for a primitive. It does not freeze a foreign resource denoted by an immutable identifier.

Construction-time `immutable` qualifies the new value before publication. `RuntimeImmutable` qualifies an existing tree while retaining its identity. The second operation's name does not denote a second argument-admission mechanism: changing qualification is its operational contract. Its arguments undergo [unified admission](#admission), like those of every receiving expression.

The whole selected tree is examined before qualification changes. A contained Structure is a tree branch only when its ordinary structural `parent` field points to the parent being examined. An outside reference is permitted only to an already immutable object; it is terminal, and its target is neither traversed nor requalified. The pre-change state is checked: processing an earlier field cannot justify an invalid outside reference in a later field. Malformed containment or a mutable outside target follows a declared `throw`, not `assert`.

Primitives and methods are leaves, not lexical-tree branches. An Array reference likewise establishes no `parent` branch: a tree operation does not implicitly freeze an outside Array's mutable backing. An immutable Array is constructed under its own contract. A cell's membership in a service pool does not permit traversal or qualification of the entire pool.

Qualification is applied only after successful complete preflight. Failure leaves no partially frozen tree or published successful result; silently skipping a branch, copying it or retargeting links is prohibited. Requalifying an already suitable tree changes nothing. This rule does not roll back earlier initializers, argument evaluation or pre-call publication of working fields; it establishes no graph transaction.

Protection applies to writes through every path. A known-invalid write is rejected before execution; a dynamically selected write is checked during execution. Calling a method is allowed but does not remove protection. Changing a local argument copy or rebinding a local reference does not modify the protected value. Constructing a new value, including through `merge`, does not thaw the source.

Construction-time `independent` sets the root's `parent = 0`; that is exactly the absence of an external lexical parent. Internal tree `parent` links and own fields remain. The qualification neither retroactively clears existing objects' `parent` links nor prohibits explicitly supplied references, current-caller dynamic arguments, Messages or selection of a callable by a compatible signature. It does not require purity or an interface closed over explicit arguments alone.

`const`, `immutable` and `independent` are receiving expressions; their composition establishes the result's qualified type. The physical representation of that type is determined by the common typed-address-range membership mechanism described in [L2](L2_spec_en.md#type-by-range), rather than by per-value flags or a special classifier for one particular qualifier chain. The range's own identity is the type domain; qualifier compositions do not each introduce a new enumeration code. A zero root `parent` remains the structural consequence of `independent`, not a replacement for type classification.

For example, a method inside independent Structure S can use S's field through its internal lexical link. Required `x` can come from the current caller. If `x` exists only in S's former textual surroundings, implicit external access is unavailable. An explicitly passed large Array neither shrinks nor gets copied because of `independent`. The special lifetime of the three qualifications together is described under [eternal branches](#eternal).

@@ callables | Вызываемые выражения и их интерфейсы | Callable expressions and their interfaces | 7–7.3; 7.5.1; 8.5–8.8; 19.21; 21.9
[RU]
Исполняемое тело — структурное выражение. Всякая именованная Structure может исполняться голым атомом имени, но её объявление и построение сами по себе тело не исполняют. `fn` определяет выражение с одним логическим результатом; `sub` — выполнение без возвращаемого значения; `fm` — один результат-структуру, поля которой образуют поверхность множественного возврата. Сигнатура задаёт явные аргументы, требуемые динамические и лексические входы, способ передачи каждого значения, результат и объявленные выходы `throws`. Голый `return` завершает исполнение без значения; `return: value` передаёт значение в допускающем результат теле. Обычная именованная Structure — callable без результата: в ней допустим только голый `return`, а `return: value` отвергается; `sub` также допускает голый `return`, но не приобретает от него результат. На уровне открытия `return` — голый, а в допускающем результат теле и со значением — может также закрывать любую callable Structure (метод или именованную Structure) как trailer по общему правилу грамматики; не-callable Structure `return` не закрывает. Структурный путь через callable Structure (`Counter\n`) читает её опубликованное поле и не исполняет её, даже если она метод.

Вызываемое вхождение имеет собственную структурную идентичность и поле `parent`, указывающее в его над-методное лексическое пространство. Несколько вхождений могут ссылаться на один неизменяемый метод. Копирование графа не создаёт новую реализацию метода и не меняет его сигнатуру; состояние принадлежит конкретным структурным вхождениям и активациям. Вложенное определение не захватывает кадр вызывающего выражения в скрытое окружение.

Вход в метод не копирует его вызываемое вхождение, тело или другую часть графа. Нативное и интерпретируемое исполнение используют одну модель: исполнение — пара из кода и данных, где роль задаётся позицией (Structure в позиции головы — код, переданная ей Structure — данные), а не свойством Structure, и одному графу разрешено быть и кодом, и данными. Исполнение не пишет в операторы и литералы, только в объявленные поля; обычная активация работает над полями самого вызываемого вхождения, а свежий экземпляр его объявленных полей создаётся только при повторном входе или при явно переданных данных; фактические аргументы, локальные значения и результат принадлежат обычной машинной активации со временем жизни стекового вызова, а аргумент становится полем только по правилу [§12](#dynamic) или связыванием через merge. Рекурсивный вызов создаёт другой экземпляр и кадр над тем же методом; снаружи видны поля самого вхождения, результат через них не читается. Реализация может размещать служебное хранилище кадра в переиспользуемой памяти, если это не создаёт копию метода или скрытое состояние графа и не делает вход существенно дороже нативного вызова; память графа копируется только явно выраженной операцией, а не самим вызовом.

Выбор вызова начинается с явной ссылки, структурного пути либо текстового пути с явно переданным корнем. Выбор реализации и подача её аргументов — разные действия. Обнаруженный кандидат проходит [допуск](#admission); затем вызов должен получить все входы сигнатуры. Наличие подходящего поля с методом ещё не обеспечивает его динамические входы. Передача метода как данных не равна его вызову.

Позиционные фактические аргументы предшествуют именованным. После первого именованного аргумента последующие также именованные. Неизвестное имя, повторное присваивание одного аргумента, недостающий обязательный аргумент или нарушение порядка — ошибка. Тело именованного аргумента передаётся как структурное значение, если именно такой режим задаёт принимающее выражение; оно не становится произвольной последовательностью немедленных вызовов. В позиции аргумента принимающий контракт выбирает результат или саму ссылку: явно объявленный callable-формал получает ссылку на callable-вхождение, а не результат его исполнения; если принимается результат, исполняется callable с возвращаемым значением; не возвращающее значения callable, включая `sub`, передаётся ссылкой. Голый `return` означает только выход и не делает callable возвращающим значение. Объявленный без тела `fn` остаётся дескриптором интерфейса и может передаваться ссылкой, но прямое исполнение не получает вымышленного тела.

Синтаксические границы имени функции, списка аргументов, описания результата и тела определены в [грамматике](LMX_grammar.ru.md). Пустое Structure-тело Frame содержит ноль полей, независимо от записи завершённого пустого списка; голый `f:` без аргумента или явного закрытия недопустим. Описания и подписи не создают неявный вызов. Формы объявления без тела и связывания части аргументов сами по себе не создают автоматическое каррирование или замыкание.

В исполняемом теле безголовая запись — обычное выражение, а не ошибка и не особая форма вызова. Это относится к одиночному `2`, голому `f`, последовательности `2 + 2`, анонимной структуре `(f)` или `(2 + 2)` и пустой `()`. Их поля разрешаются и вычисляются в лексическом порядке тем же механизмом выражений; результат, которому не указан получатель, отбрасывается. Анонимная структура с несколькими полями, в том числе с Frame и безголовыми выражениями, сохраняет порядок исполнения всех полей; ограниченная и соответствующая вертикальная запись не выбирают разные операции. Голое `f` исполняет разрешённую именованную Structure без аргументов; для метода это тот же нульарный вход. В позиции аргумента действует контракт получателя (§10, выше), а не обязательное исполнение по одному лишь наличию имени. Литерал `2` не объявляет тип для `f: 2`. Пустая `()` допустима как присутствующая пустая Structure без внутренних выражений. Ни форма скобок, ни факт отбрасывания результата не обходят обычное разрешение, admission или диагностику неизвестного имени.

Именованные результаты `fm` — поля уже существующей структуры результата. `return` завершает их обновление и передаёт эту структуру; сам переход управления не выделяет и не копирует её. Несколько значений в хвосте `return` заполняют предусмотренные сигнатурой поля той же структуры. Точные поверхностные формы распаковки требуют отдельного правила профиля.

Сокращённая запись с присваиванием имени функции, например `square: x * x` внутри `square`, допустима только если принимающий `fn` определяет одноимённую локальную ячейку результата. Она не заменяет постоянную ссылку на вызываемое выражение. Без такого контракта форма отвергается. Структурное закрытие `end: f` не добавляет неявный возврат значения; основной вариант — явный `return: value`.

```text
fn: square (int(x)) (int)
return: x * x

fm: coordinates () (int(x) int(y))
return: 10 20
```

Возвращаемая ссылка сохраняет точную идентичность цели. Построение результата, если нужно, принадлежит вычислению возвращаемого выражения, а не операции перехода. Возврат вложенной функции завершает её активацию, а не автоматически весь актор. Порядок публикации и очистки задан в [выходах](#exits).
[EN]
An executable body is a structural expression. Every named Structure may be executed through the bare atom of its name, but declaring or constructing it does not itself execute its body. `fn` defines an expression with one logical result; `sub` performs execution without a returned value; `fm` has one result Structure whose fields provide a multiple-return surface. The signature defines explicit arguments, required dynamic and lexical inputs, each value's pass mode, the result and declared `throws` exits. Bare `return` exits without a value; `return: value` supplies a value in a body admitting a result. An ordinary named Structure is a callable without a result: only bare `return` is admitted in it, and `return: value` is rejected; `sub` likewise admits bare `return` but does not acquire a result from it. At the opening level `return` -- bare, or with a value in a body admitting a result -- may also close any callable Structure (a method or a named Structure) as a trailer under the general grammar rule; `return` does not close a non-callable Structure. A structural path through a callable Structure (`Counter\n`) reads its published field and does not execute it, even when it is a method.

A callable occurrence has its own structural identity and a `parent` link into its above-method lexical space. Multiple occurrences can reference one immutable method. Graph copying neither creates another method implementation nor changes its signature; state belongs to particular structural occurrences and activations. A nested definition does not capture a caller frame in a hidden environment.

Entering a method does not copy its callable occurrence, body or any other part of the graph. Native and interpreted execution use the same model: an execution is a pair of code and data, where the role is given by position (the Structure in head position is code, the Structure passed to it is data), not by a property of the Structure, and one graph may be both code and data. Execution does not write operators or literals, only declared fields; an ordinary activation works over the fields of the callable occurrence itself, and a fresh instance of its declared fields is created only on re-entry or when data is passed explicitly; the actual arguments, local values and the result belong to the ordinary machine activation with the lifetime of a stack call, and an argument becomes a field only by the rule of [§12](#dynamic) or by binding through merge. A recursive call creates another instance and frame over the same method; from outside the occurrence's own fields are visible, and the result is not read through them. An implementation may place the frame's auxiliary storage in reusable memory provided that this neither creates a method copy nor hidden graph state and does not make entry substantially more expensive than a native call; graph memory is copied only by an explicitly expressed operation, not by invocation itself.

Callable selection starts from an explicit reference, structural path or textual path with an explicitly supplied root. Selecting an implementation and providing its arguments are distinct actions. The selected candidate undergoes [admission](#admission); the call must then receive every signature input. A suitable method field does not by itself supply its dynamic inputs. Transporting a method as data is not invoking it.

Positional actual arguments precede named ones. After the first named argument, subsequent arguments must also be named. An unknown name, duplicate assignment to one argument, missing required argument or ordering violation is an error. A named argument's body is supplied as a structural value when that is the receiving expression's specified mode; it does not become an arbitrary sequence of immediate calls. In argument position the receiving contract selects a result or the reference itself: an explicitly declared callable formal receives a reference to the callable occurrence, not the result of executing it; when a result is received, a value-returning callable is executed; a callable with no returned value, including `sub`, is passed by reference. Bare `return` means only exit and does not make a callable value-returning. A bodyless `fn` remains an interface descriptor and may be passed by reference, but direct execution gains no invented body.

The syntactic boundaries of the function name, argument list, result description and body are defined in the [grammar](LMX_grammar.en.md). An empty Frame Structure-body has zero fields regardless of the spelling of a completed empty list; bare `f:` without an argument or explicit closure is invalid. Descriptions and signatures do not create implicit calls. Bodyless declarations and partial-argument binding forms do not by themselves create automatic currying or a closure.

In an executable body, a headless form is an ordinary expression, neither an error nor a special call form. This covers lone `2`, bare `f`, the sequence `2 + 2`, anonymous Structures `(f)` and `(2 + 2)`, and empty `()`. Their fields are resolved and evaluated in lexical order by the same expression mechanism; a result without a destination is discarded. An anonymous Structure containing several fields, including Frames and headless expressions, retains the execution order of all fields; bounded and corresponding vertical spellings do not select different operations. Bare `f` executes the resolved named Structure without arguments; for a method this is the same nullary entry. In argument position the receiver's contract applies (§10, above), rather than execution merely because a name is present. Literal `2` does not declare a type for `f: 2`. Empty `()` is a valid present empty Structure with no inner expressions. Neither parentheses nor discarding a result bypasses ordinary resolution, admission, or unknown-name diagnostics.

Named `fm` results are fields of an already existing result Structure. `return` completes their updates and forwards that Structure; the control transfer itself neither allocates nor copies it. Multiple values in the `return` tail populate signature-defined fields of the same Structure. Exact surface unpacking forms require a separate profile rule.

Function-name assignment shorthand, such as `square: x * x` inside `square`, is admitted only if the receiving `fn` defines a same-named local result slot. It does not replace the persistent callable reference. Without that contract the form is rejected. Structural closing with `end: f` adds no implicit value return; explicit `return: value` is the core form.

```text
fn: square (int(x)) (int)
return: x * x

fm: coordinates () (int(x) int(y))
return: 10 20
```

A returned reference preserves its exact target identity. Constructing a result, if necessary, belongs to evaluation of the returned expression, not the transfer operation. Returning from a nested function ends its activation, not automatically the entire actor. Publication and cleanup ordering is defined under [exits](#exits).

@@ dynamic | Динамические входы и рабочее состояние | Dynamic inputs and working state | 7.3.1–7.4.3; 21.1–21.8; 21.10–21.12
[RU]
Следует различать постоянное поле графа, поле экземпляра данных текущей активации, явный формальный аргумент и динамический вход. Это разные места хранения с разными правилами изменения. Обычная передача изменяемого примитива копирует значение, структуры и массива — ссылку; особая идентичность неизменяемого значения сохраняется согласно [квалификации](#qualification).

Для свободного имени вызываемое выражение получает текущее значение из доступного контекста вызывающего выражения; при его отсутствии используется допустимый лексический поиск по `node`. Внутренние собственные объявления и формальные параметры имеют свои разрешённые места, а не ищутся в глобальном реестре. Список необходимых сквозных имён входит в сигнатуру: добавление свободного имени меняет интерфейс. При отсутствии необходимого входа вызов недопустим; молчаливое создание нуля или нового поля запрещено.

Приоритет источников свободного имени: ближайшая текущая локальная привязка вызывающего выражения, затем уже унаследованный им динамический вход, затем лексический поиск вызываемого выражения. Локальная привязка включает используемое собственное поле, формальный аргумент, результат или иное локальное значение, определённое принимающим выражением. Требования статически известных вызовов распространяются до неподвижной точки, в том числе через взаимную рекурсию. Имя, нужное только следующему вызову, также должно сохраняться и передаваться; само по себе это не создаёт поле графа.

Лексический поиск использует реальные связи структуры, заканчивается на нулевом родителе и выбирает прямое первое одноимённое вхождение на соответствующем шаге. `independent` отсекает только внешний лексический запасной путь. Явное обращение `node\x`, `reference\x` или `array[index]` обращается к графу, а не подменяется динамическим `x` текущего вызова.

Собственное поле текущей активации — поле самого вызываемого вхождения (или его экземпляра при повторном входе); присваивание такому имени пишет в это поле непосредственно, рабочих копий и отметки изменения нет. Явная запись через ссылку меняет выбранный объект непосредственно и наблюдаема через другие ссылки на него. Явный или скрытый аргумент — значение машинной активации; полем экземпляра он становится только при направленном в него голом присваивании (ниже), а без такого присваивания остаётся обычным входным значением без обратной записи вызывающему выражению.

Наличие в исходном теле разрешённого голого присваивания `x: value`, где `x` — заранее типизированный изменяемый явный либо скрытый аргумент, делает `x` полем прототипа данных этого тела. Тело здесь — вызываемое выражение (метод), а не вложенное тело `if`/`while`/блока: голое присваивание внутри вложенного тела полей этому вложенному телу не заводит и пишет в ту же ячейку вызываемого; вложенная Structure тела держит только поля, объявленные в ней (`fn: keep (int: n) int` с телом `int: n` / `if: 1` / `n: n + 1` / `return: n` даёт `keep(3) = 4`). См. L2 §10. Для роли присваивания `value` также должно быть разрешено как существующее типизированное значение либо непосредственно как литерал; иначе поле по этому правилу не создаётся, а выбирается другая уже определённая роль двоеточия либо выдаётся ошибка трансляции. Исполнение строки записывает значение в это поле; не взятая ветка ничего не записывает, и поле хранит прежнее значение. Трансляция уже зафиксировала раскладку прототипа, поэтому исполнение не меняет число полей. Запись попадает в экземпляр данных этого тела, никогда — в источник аргумента вызывающего выражения или в родительский граф.

Локальность и длительность хранения здесь являются разными свойствами. Поля вызываемого вхождения остаются после активации и доступны снаружи путём `M\x`, но запись в него не является изменением внешней привязки: ячейка аргумента вызывающего выражения и поле над-методного пространства остаются неизменными. Это внешнее поле меняется только явной записью через путь `node\x`, где `node` — данные лексического родителя.

В L3 `@` существует только как голова отдельного принимающего выражения объявления ссылки. Форма `@: Type var` объявляет типизированную ссылочную привязку `var`; `Type` и `var` являются двумя отдельными полями хвоста, а `Type` должен быть разрешён. Глубина головы не ограничена: `@@: Type var` объявляет ссылку на ссылку, `@@@: Type var` — следующую глубину; так Structure-данные L3 хранят ссылки любой глубины, а метод работает с полученной Structure как с данными C. Это объявление не создаёт новый экземпляр `Type`, не берёт адрес привязки и не открывает машинную ячейку. Значение предоставляет аргумент либо последующее обычное присваивание `var: value` с обязательным admission до первого чтения; использование ещё не связанной ссылки является ошибкой.

```text
@: Type var
```

| Форма | Смысл в L3 |
| --- | --- |
| `@: Type var` | Объявление ссылки `var` на значение разрешённого `Type` |
| `@: Type: var` | Другая структура `@(Type(var))`; не объявление ссылки и не синоним предыдущей формы |
| `@x`, включая `return: @x` и передачу `@x` аргументом | Недопустимая в L3 префиксная address-of форма |
| `@@: Type var`, `@@@: Type var` и последующие головы | Объявление ссылки большей глубины (ссылка на ссылку …); в L3 допустимо только как receiver объявления |

Ссылочная привязка переносит уже существующую ссылочную идентичность: её обычная передача и `return: var` передают `var`, а не адрес локальной переменной. Присваивание перепривязывает её только после общего `implements`/admission. Для нового значения используется обычное типизированное построение, например `Type: fresh`, а не `@`. L3 не содержит префиксного address-of, сырой загрузки, арифметики адресов, машинного `cast` либо доступа к backing; одноимённый `@`-receiver не переиспользует реализацию машинного семейства L2.

Каждое тело, которое принимающее выражение исполняет по операторам, — структура графа и владелец непосредственно объявленных в нём полей. Тела `if` и `else`, циклов и других принимающих выражений образуют вложенную иерархию, не плоский список полей метода. Невыполненная ветвь не производит присваиваний. Обычный вложенный блок не создаёт новую активацию метода или границу динамических входов. Условие, аргумент вызова и аргумент `return` сами по себе не являются исполняемыми телами: их роль задаёт принимающее выражение, а не наличие вложенной структуры в последней синтаксической позиции.

```text
fn: remember (int: x) int
    x: 7
    return: x
end: remember
```

Здесь входной `x` становится полем экземпляра данных тела при исполнении `x: 7`. Меняется состояние `remember`, а не переменная вызывающего выражения. Кэшей нет: голое имя после связывания читает и пишет это поле; явный путь читает граф; поле не исчезает из графа оттого, что голое имя его не использует.

Публикации нет: запись в поле экземпляра видна сразу любому пути к нему, в том числе вложенному вызову через `node\x`, и после возврата вызывающая активация читает то же поле. Невозможность разрешить или записать связанное поле — диагностический `assert`; предназначенный внешний вызов после этого не выполняется. Общей транзакции с откатом предыдущих записей нет.

Отметок `dirty`, рабочих копий и контрольных точек нет; внешняя граница, способная вызвать LMX обратно или показать состояние графа, видит текущие поля экземпляров.

Следовательно, после вложенного изменения `node\x` голое `x` вызывающего выражения видит новое значение: это одно и то же поле экземпляра. Позднейшее присваивание голому `x` — просто следующая запись в него.

<a id="activation-history"></a>
### Стек активаций, рекурсия и явная история

Стек активаций является единственной неявной историей вызовов. Нативное исполнение использует обычный стек вызовов C; интерпретатор — эквивалентный управляющий стек. Прямая, взаимная и callback-рекурсия создаёт отдельную активацию с собственными формальными и динамическими значениями, локалами и результатом; повторный вход получает свой экземпляр объявленных полей. Скрытый узел активации, окружение замыкания или глобальная запись активного аргумента не создаются.

Вызываемое вхождение хранит поля своей последней активации над собственным графом, но не журнал вызовов: повторный вход получает свой экземпляр, а приостановленная внешняя активация продолжает работать со своими полями. Другое вызываемое вхождение того же метода имеет свои поля. Итог определяется порядком записей, а не восстановлением снимка.

Трасса рекурсивного примера ниже не вводит новый синтаксис. Метод M имеет вызываемое вхождение S с полем `x`, начальное значение по объявлению 1; внешняя активация работает над S, повторный вход получает свежий экземпляр I2, а `n` является частным объявленным аргументом каждой активации.

| Шаг | `x` внешней активации (поле S) | `x` экземпляра I2 | `S\x` снаружи |
| --- | --- | --- | --- |
| Внешний вход над S | 1 | — | 1 |
| Внешний вызов присваивает `x: 2` | 2 | — | 2 |
| Вход `M(0)` создаёт экземпляр I2 | 2 | 1 | 2 |
| Внутренний вызов присваивает `x: 9` | 2 | 9 | 2 |
| Внутренний возврат | 2 | 9, активация завершена | 2 |
| Внешний вызов продолжается | 2 | — | 2 |
| Внешний вызов возвращается | 2, активация завершена | — | 2 |

После возврата внутреннего вызова голое `x` внешней активации читает 2 — поле S; путь `S\x` снаружи тоже читает 2: экземпляр повторного входа снаружи не виден. Если внешняя активация затем выполняет `x: x + 1`, поле S становится 3, и `S\x` читает 3. Динамически переданный `x`, который ни разу не является целью разрешённого голого присваивания, остаётся только локальным аргументом; если в теле есть такое `x: ...`, скрытый аргумент подчиняется тому же правилу, что и явный.

Тем самым объявленное поле — обычное поле графа, а не стековая переменная; граф хранит поля и экземпляры повторного входа, стек — историю активаций, локалы и результаты. Неявного захвата кадра вызывающего выражения нет, поэтому кадры не приходится размещать в куче или связывать скрытой цепочкой замыканий для решения upward-funarg-проблемы.

Следующий пример вызова показывает чтение поля голым именем и явным путём и вычисление фактических аргументов; это трасса установленной формы `for:`, не новое правило грамматики. Поле `j` — поле вложенной Structure тела `for` в экземпляре; `print` здесь — высокоуровневое вызываемое выражение профиля, не операция `c.*`.

```text
fn: test () int
    int: acc
    acc: 0
    for: int(i, 0) (i < 10) i++
        int: j i
        acc: j
    end: for
    print: acc for\j
    return: 0
end: test
```

После цикла `acc` равно 9, и `for\j` тоже 9: оба — поля экземпляра, записанные последней итерацией. Перед вызовом фактические аргументы вычисляются в типизированные временные значения из этих полей, и `print` печатает `9 9`. Контрольных точек и публикации нет; явное чтение пути в любом операторе видит текущее значение поля.

Одна логическая последовательная полоса исполнения каждого Message делает эту модель безопасной без блокировок и барьеров памяти внутри такта. Приостановленные активации не участвуют в гонке; другие Message работают со своими аренами. Интерпретатор реализует ту же семантику управляющим стеком возвратов, аргументов и локалов; полное состояние метода при вызове не копируется — экземпляр прототипа создаётся только при повторном входе.

Тело, переданное принимающему выражению как структура, и аргументы исполняемого вызова также не становятся общим скрытым окружением.

Границы вызова, возврата, `throw`, диагностического прекращения и `yield` не требуют публикации: поля экземпляра уже актуальны. Выход с `finally` описан в [выходах](#exits). `retry` и локальный переход цикла сами по себе не создают новую активацию. Сигнатуры и граф сохраняют требования этой модели независимо от того, исполняется ли граф интерпретатором или транслируется.
[EN]
A persistent graph field, a field of the current activation's data instance, an explicit formal argument and a dynamic input must be distinguished. They are separate storage locations with separate mutation rules. Ordinary passing copies a mutable primitive's value and a Structure or Array's reference; the special identity of an immutable value is retained under [qualification](#qualification).

For a free name, the called expression receives the current value from the caller's available context; if unavailable, permitted lexical lookup follows `node`. Own declarations and formal parameters have their respective resolved locations rather than being searched in a global registry. Required through-names are part of the signature: adding a free name changes the interface. A missing required input makes the call inadmissible; silently creating zero or a new field is prohibited.

A free name's sources have this priority: the caller's nearest current local binding, then its already inherited dynamic input, then the callee's lexical lookup. A local binding includes a used own field, formal argument, result or another receiver-defined local value. Statically known call requirements propagate to a fixed point, including through mutual recursion. A name needed only by the next call must still be retained and forwarded; forwarding alone creates no graph field.

Lexical lookup uses real Structure links, stops at a zero parent and selects the direct first same-named occurrence at the relevant step. `independent` cuts only the external lexical fallback. Explicit access through `node\x`, `reference\x` or `array[index]` addresses the graph rather than being replaced by the current call's dynamic `x`.

An own field of the current activation is a field of the callable occurrence itself (or of its instance under re-entry); assigning that name writes into this field directly, with no working copies and no modification mark. An explicit reference write changes the selected object directly and is observable through other references to it. An explicit or hidden argument is a value of the machine activation; it becomes a field of the instance only when a bare assignment targets it (below), and without such an assignment it remains an ordinary input value with no copy-back to the caller.

The presence in a source body of a resolved bare assignment `x: value`, where `x` is an already typed mutable explicit or hidden argument, makes `x` a field of that body's data prototype. The body here is the callable expression (the method), not a nested `if`/`while`/block body: a bare assignment inside a nested body creates no field of that nested body and writes into the same cell of the callable; a nested body's Structure holds only the fields declared in it (`fn: keep (int: n) int` with the body `int: n` / `if: 1` / `n: n + 1` / `return: n` gives `keep(3) = 4`). See L2 §10. For the assignment role, `value` must also resolve as an existing typed value or intrinsically as a literal; otherwise this rule creates no field, and translation selects another already defined contextual colon role or reports an error. Executing the statement writes the value into that field; an untaken branch writes nothing, and the field keeps its previous value. Translation has already fixed the prototype's layout, so execution changes no field count. The write lands in this body's data instance, never in the caller's argument source or the parent graph.

Locality and storage duration are separate properties here. The callable occurrence's fields remain after the activation and are reachable from outside through the path `M\x`, but a write into it is not a mutation of an outer binding: the caller's argument cell and the above-method space's field remain unchanged. Only an explicit `node\x` path write mutates that outer field, where `node` is the lexical parent's data.

In L3, `@` exists only as the head of a distinct reference-declaration receiver. The form `@: Type var` declares the typed reference binding `var`; `Type` and `var` are two separate tail fields, and `Type` must resolve. The head depth is unbounded: `@@: Type var` declares a reference to a reference, `@@@: Type var` the next depth; thus L3 data Structures hold references of any depth, and a method works with a received Structure as with C data. This declaration neither constructs a new `Type` instance, takes the address of the binding, nor exposes a machine cell. An argument or a later ordinary assignment `var: value`, with mandatory admission, must supply the value before its first read; using an as-yet unbound reference is an error.

```text
@: Type var
```

| Form | L3 meaning |
| --- | --- |
| `@: Type var` | Declare reference `var` to a value of resolved `Type` |
| `@: Type: var` | Different structure `@(Type(var))`; not a reference declaration and not a synonym of the preceding form |
| `@x`, including `return: @x` and passing `@x` as an argument | Prefix address-of form, invalid in L3 |
| `@@: Type var`, `@@@: Type var`, and subsequent heads | Declaration of a deeper reference (reference to a reference ...); admissible in L3 only as a declaration receiver |

A reference binding carries an already existing reference identity: ordinary passing and `return: var` pass `var`, not the address of a local variable. Assignment rebinds it only after common `implements`/admission. A new value uses ordinary typed construction, such as `Type: fresh`, not `@`. L3 has no prefix address-of, raw load, address arithmetic, machine `cast`, or backing access; its same-spelled `@` receiver does not reuse the L2 machine-family implementation.

Every body that a receiving expression executes statement by statement is a graph Structure hosting its directly declared fields. Bodies of `if`, `else`, loops and other receivers form a containment hierarchy, not a flat method-field list. An untaken branch performs no assignments. An ordinary nested block creates neither another method activation nor a dynamic-input boundary. Conditions, call arguments and `return` arguments are not executable bodies merely by being arguments: their receiving expression determines the role, not a Structure in the last syntactic position.

```text
fn: remember (int: x) int
    x: 7
    return: x
end: remember
```

Here input `x` becomes a field of the body's data instance when `x: 7` executes. This changes `remember` state, not the caller's variable. There are no caches: after binding, the bare name reads and writes this field; an explicit path reads the graph; a field does not vanish from the graph because no bare name uses it.

There is no publication: a write into an instance field is immediately visible through every path to it, including a nested call through `node\x`, and after return the caller activation reads the same field. Failure to resolve or store into a bound field uses diagnostic `assert`; the intended outbound call is not executed afterward. There is no general transaction rolling back earlier writes.

There are no `dirty` marks, working copies or checkpoints; a foreign boundary capable of calling back into LMX or exposing graph state sees the current instance fields.

Consequently, after a nested modification of `node\x`, the caller's bare `x` observes the new value: it is the same instance field. A later assignment to bare `x` is simply the next write into it.

<a id="activation-history"></a>
### Activation stack, recursion and explicit history

The activation stack is the sole implicit call history. Native execution uses the ordinary C call stack; the interpreter uses an equivalent control stack. Direct, mutual and callback recursion creates a distinct activation with its own formal and dynamic values, locals and result; a re-entrant activation receives its own instance of the declared fields. No hidden activation node, closure environment or global active-argument record is created.

The callable occurrence holds the fields of its latest activation over its own graph, but it is not a call journal: a re-entrant activation receives its own instance, while a suspended outer activation keeps working with its own fields. Another callable occurrence of the same method has its own fields. The result is determined by the order of writes, not by restoring a snapshot.

The following recursive trace introduces no new syntax. Method M has callable occurrence S with field `x`, initial value 1 by declaration; the outer activation works over S, the re-entrant call receives a fresh instance I2, and `n` is a private declared argument in each activation.

| Step | Outer activation `x` (field of S) | Instance I2 `x` | `S\x` from outside |
| --- | --- | --- | --- |
| Outer entry over S | 1 | — | 1 |
| Outer call assigns `x: 2` | 2 | — | 2 |
| `M(0)` entry creates instance I2 | 2 | 1 | 2 |
| Inner call assigns `x: 9` | 2 | 9 | 2 |
| Inner return | 2 | 9, activation ended | 2 |
| Outer call resumes | 2 | — | 2 |
| Outer call returns | 2, activation ended | — | 2 |

After the inner return, the outer activation's bare `x` reads 2, the field of S; the path `S\x` from outside reads 2 as well: the re-entrant instance is not visible from outside. If the outer activation then executes `x: x + 1`, the field of S becomes 3 and `S\x` reads 3. A dynamically supplied `x` that is never the target of a resolved bare assignment remains only a local argument; if the body does contain such an `x: ...`, the hidden argument follows the same rule as an explicit argument.

A declared field is therefore an ordinary graph field, not a stack variable; the graph stores fields and re-entrant instances, the stack stores activation history, locals and results. There is no implicit caller-frame capture, so frames need not be heapified or connected by a hidden closure chain to avoid the upward-funarg problem.

The following call example shows a field read by bare name and by explicit path, and the evaluation of actual arguments; it is a trace using the established `for:` form, not a new grammar rule. The field `j` is a field of the nested `for` body Structure in the instance; here `print` is a high-level profile callable, not a `c.*` operation.

```text
fn: test () int
    int: acc
    acc: 0
    for: int(i, 0) (i < 10) i++
        int: j i
        acc: j
    end: for
    print: acc for\j
    return: 0
end: test
```

After the loop `acc` is 9 and `for\j` is 9 as well: both are instance fields written by the last iteration. Before the call the actual arguments are evaluated into typed temporaries from these fields, and `print` prints `9 9`. There are no checkpoints and no publication; an explicit path read in any statement sees the field's current value.

One logical serial execution lane per Message makes this model safe without locks or memory barriers within a turn. Suspended activations take no part in a race; other Messages work in their own arenas. The interpreter implements the same semantics with a control stack of returns, arguments and locals; the method's full state is not copied on a call — a prototype instance is created only on re-entry.

A body supplied to a receiving expression as a Structure and an executable call's arguments likewise do not become one hidden environment.

The boundaries of call, return, `throw`, diagnostic termination and `yield` require no publication: the instance fields are already current. Exit with `finally` is described under [exits](#exits). `retry` and a local loop transfer by themselves create no new activation. Signatures and the graph preserve this model's requirements whether the graph is interpreted or translated.

@@ branches | Ветвления и циклы | Branches and loops | 10; 19.1–19.9; 19.14; 19.16
[RU]
Управляющие принимающие выражения определяют способ потребления своих структурных тел. Принадлежность к телу не означает обязательное немедленное выполнение всех его полей. Метки управления обозначают видимые цели перехода; упоминание метки само по себе не вызывает тело и не является неявным `goto`.

`if` вычисляет условие один раз и исполняет тело при истинном результате. Непосредственно следующий `else` на том же уровне исполняется только при ложном результате. Вставка другого оператора между ними нарушает пару. Профильный `branch` с именованными ветвями может существовать отдельно и не заменяет этот контракт.

`match` выбирает подходящую ветвь по выраженным шаблонам. Ветви могут задаваться парами «шаблон — тело» или явными структурами согласно профилю; `default` является определённым профилем шаблоном, а не универсальным эффектом произвольного имени. Объединение шаблонов и требование исчерпывающего покрытия задаются контрактом. Автоматического проваливания в следующую ветвь нет, если оно явно не определено.

`while` проверяет условие перед каждой итерацией и может ни разу не выполнить тело. Закрывающий `until` задаёт проверку после тела: тело выполняется хотя бы один раз, затем повторяется, пока условие ложно. Основной `for` содержит инициализацию, условие, шаг и тело; инициализация выполняется один раз, затем проверка, тело и шаг. Сокращения диапазонов требуют отдельного явно выбранного профиля и не изменяют эту основную форму.

`each` потребляет элементы контейнера либо явно выбранного итератора. Итератор выдаёт элемент посредством `yield`, а завершение обозначает объявленным `throw: Stop`; `None` может быть обычным элементом и не заменяет сигнал конца. Другие исключения распространяются по своим объявлениям. Ссылка `words` на источник и вызов `words()` различаются: второй явно вызывает выражение без аргументов.

| Переход | while | until | for | each |
| --- | --- | --- | --- | --- |
| `continue` | Проверить условие | Проверить постусловие | Выполнить шаг | Получить следующий элемент |
| `redo` | Повторить тело без проверки | Повторить тело без проверки | Повторить тело без шага | Повторить с тем же элементом, без `next` |
| `break` | Выйти из цикла | Выйти из цикла | Выйти из цикла | Выйти из цикла |

Без метки переход относится к ближайшему подходящему активному циклу. Именованный переход требует видимой метки; `continue` к нециклической цели ошибочен. `redo` допустим только в цикле и может не обеспечивать продвижения. Все покидаемые области выполняют свои зарегистрированные очистки. Полный набор видов областей, к которым может присоединяться метка, требует отдельного грамматического определения.
[EN]
Control receivers determine how their structural bodies are consumed. Membership in a body does not require immediate execution of all its fields. Control labels denote visible transfer targets; mentioning a label neither invokes its body nor constitutes an implicit `goto`.

`if` evaluates its condition once and executes its body when true. An immediately following sibling `else` executes only when false. Another statement between them breaks the pair. A profile-specific `branch` with named branches may exist separately and does not replace this contract.

`match` selects a suitable branch using expressed patterns. Branches can be pattern/body pairs or explicit Structures according to the profile; `default` is a profile-defined pattern, not a universal effect of an arbitrary name. Pattern union and exhaustive-coverage requirements belong to the contract. There is no automatic fallthrough unless explicitly defined.

`while` checks its condition before each iteration and can execute its body zero times. Closing `until` establishes a postcondition: the body executes at least once and repeats while the condition is false. Core `for` contains initialization, condition, step and body; initialization runs once, followed by condition, body and step. Range shorthands require a separately selected profile and do not alter this core form.

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

Для выхода, уничтожающего активацию, установлен порядок: однократно вычислить результат или полезную нагрузку выхода и удержать её; опубликовать изменённые собственные рабочие поля; выполнить применимые очистки; опубликовать собственные поля, изменённые очистками; передать результат либо управление и завершить активацию. При отсутствии новых изменений вторая публикация пуста, но не может быть заранее исключена.

Динамические входы не записываются обратно, неизменённые кэшированные поля не публикуются, вызывающая активация не перечитывается. Каждая активация, пересекаемая распространением выхода, выполняет свои необходимые действия. Возврат сохраняет ссылочную идентичность результата и сам по себе не запускает сборку конца такта актора.

Выход внутри уже исполняющейся очистки не запускает ту же очистку повторно. Оставшиеся применимые внешние очистки сохраняют свои обязательства. Вызовы внутри очистки имеют обычные границы публикации. Удаление активации вследствие остановки или отмены не даёт права обойти эти правила.
[EN]
`finally` registers cleanup in the current scope without executing it at registration. Registered cleanups run in reverse order when that scope is exited. This applies to normal completion, `return`, `throw`, transfers out of a loop scope, `redo`, `retry`, diagnostic termination and other profile exits. It is neither a `try` construct nor an exception-only handler.

An exit that destroys an activation follows this order: evaluate and retain the result or exit payload once; publish dirty own working fields; perform applicable cleanups; publish own fields dirtied by cleanup; transfer the result or control and finish the activation. If no new changes occur, the second publication is empty, but it cannot be ruled out in advance.

Dynamic inputs are not copied back, clean cached fields are not published, and the caller activation is not reloaded. Every activation crossed by propagation performs its own required actions. Return preserves the result's reference identity and does not itself trigger actor end-of-turn collection.

An exit within an already running cleanup does not re-enter that cleanup. Remaining applicable outer cleanups retain their obligations. Calls within cleanup have ordinary publication boundaries. Removing an activation through stopping or cancellation does not permit these rules to be bypassed.

@@ exceptions | Объявленные отказы и диагностика | Declared failures and diagnostics | 2.5.6; 19.11–19.13.1
[RU]
`throws` перечисляет имена возможных восстанавливаемых выходов выражения, а не типы исключений. Вызывающее выражение должно предоставить `catch` для каждого такого имени либо объявить его в собственном `throws`. Вызов без одного из этих способов обработки отвергается. Условие обнаружения отказа задаётся обычным `if`; модульный `guard` не является оператором обработки отказов.

`throw: Name(arguments)` вычисляет явную полезную нагрузку и покидает текущую активацию по правилам [выходов](#exits), не возвращая объявленный результат. Параметры выбранного `catch: Name (...)` принимают нагрузку. Повторный вызов из обработчика начинает новую активацию сначала и не возобновляет брошенный кадр.

`catch` — точка приёма в блоке вызывающего выражения, не обычный вложенный `sub`. При первом прямом проходе её тело пропускается. После доставки соответствующего отказа тело выполняется, затем исполнение продолжается с операторов после этого `catch`. Поэтому обработчик, поставленный до вызова, повторно вводит выполнение в последующий участок; обработчик после вызова продолжает за собой. Участок ограничен следующим `catch` того же блока или концом блока. Обработчик действует на все вызовы своего блока, включая вызовы из вложенных в него операторных блоков (`if`, `while`, `for`, анонимный `---`): это не особое правило `catch`, а общее свойство видимости callable — обработчик, как и метод, виден во всём своём блоке в обе стороны. Блок-сосед им не покрывается.

Два одноимённых обработчика в одном блоке запрещены; отдельные вложенные блоки могут иметь каждый свой. Доставка выбирает обработчик по блоку вызова, не одноимённый обработчик соседнего блока. Повторный `throw` того же имени внутри обработчика не входит в этот обработчик заново: это отказ во внешнем вызывающем контексте. Необработанное имя распространяется только через соответствующие объявления `throws`.

Операторы языка, у которых программист не видит явного перечисления `throws` (например, `merge`, в том числе внутри объявления `Model: fresh`), тоже бросают именованный отказ, но отлавливать его не обязательно: обработчик `catch: merge` — до вызова, после него или в отдельном вложенном блоке — обрабатывает его стандартно, и никуда он не улетает; неотловленный неявный отказ улетает в корень исполняющегося Message, и поток останавливается (`running = 0`). Единственное ограничение размещения — то же, что и для объявленных имён: два одноимённых `catch` не могут спорить на одном уровне.

Рабочий пример из старой спецификации (`lingvamyxa_prev/tests/t2.lmx`): обработчики до вызова в отдельных анонимных блоках и обработчик после блоков. Каждый вызов `checkedGreeting(...)` стоит на уровне своего `catch`, после обработчика; в отрисовке старой спецификации он из-за ошибки отступа попал внутрь тела обработчика, здесь пример приведён по оригиналу (табуляция = 8).

```text
fn: checkedGreeting (HelloConfig(cfg)) (Text)
    throws:
        GreetingRetry
        GreetingSkip

    if: cfg\greeting\len = 0
        throw: GreetingRetry(cfg)

    if: cfg\greeting\len < 0
        throw: GreetingSkip(cfg\greeting)

    return: cfg\greeting


sub: helloMain
    HelloConfig: cfg
        greeting: "Hello World"
        maxI: 3
        maxJ: 3
    ---

    HelloConfig: emptyCfg
        greeting: ""
        maxI: 1
        maxJ: 1
    ---

    ---
        catch: GreetingRetry ()
            cfg\greeting\len++
        System\out\println: checkedGreeting(cfg)
    ---
        catch: GreetingRetry ()
            emptyCfg\greeting\len++
        System\out\println: checkedGreeting(emptyCfg)

    catch: GreetingSkip (Text: badText)
        System\out\println: ("handled EmptyGreeting: " + badText)
```

`checkedGreeting` завершается либо `return: cfg\greeting`, либо `throw`. Пустые параметры `GreetingRetry ()` означают, что эта точка приёма не принимает полей нагрузки; она изменяет внешний `cfg` или `emptyCfg`. `GreetingSkip` связывает `cfg\greeting` из `throw: GreetingSkip(cfg\greeting)` с `badText`. Каждый анонимный блок `---` содержит один обработчик `GreetingRetry` и один вызов, поэтому два имени `GreetingRetry` не дублируют друг друга; повторный вызов из обработчика — новая активация. `GreetingSkip` стоит в `helloMain` после этих блоков, поэтому пропуск продолжается с операторов после этого `catch`.

`assert` проверяет диагностический инвариант. Ложное условие порождает `AssertionViolation`, а не восстанавливаемый `throw`; его нельзя поймать обычным `catch`, и оно не входит в `throws`. В акторном профиле после публикации и очисток диагностика передаётся корню исполняющегося Message, Message прекращает исполнение и больше не получает тактов. Это не обязательное завершение рабочего потока ОС; остановка и уничтожение объекта различаются.

Ожидаемые ошибки входных данных обрабатываются явным условием и объявленным отказом, а не диагностической аварией. `log` и `error` записывают наблюдения через выбранный профиль. Само `error` не означает `throw`, `assert`, возврат или остановку. Нелитеральный аргумент разрешается как обычное значение; неизвестное имя не превращается автоматически в строку журнала.
[EN]
`throws` lists names of an expression's possible recoverable exits, not exception types. The caller must provide a `catch` for each name or include it in its own `throws`. A call without either treatment is rejected. Failure detection uses ordinary `if`; module `guard` is not a failure-handling operator.

`throw: Name(arguments)` evaluates an explicit payload and leaves the current activation under the [exit rules](#exits), without returning its declared result. The selected `catch: Name (...)` parameters receive the payload. A handler's repeat call begins a new activation from the start and does not resume the abandoned frame.

`catch` is a landing pad in the caller's block, not an ordinary nested `sub`. Its body is skipped on the initial straight-line pass. When the corresponding failure arrives, its body runs and execution continues with the statements after that `catch`. Consequently, a handler before a call re-enters the following region; a handler after the call continues past itself. The region ends at the next `catch` in the same block or the block's end. The handler covers every call of its block, including calls made from statement blocks nested inside it (`if`, `while`, `for`, an anonymous `---`): this is not a special `catch` rule but the general visibility property of callables -- a handler, like a method, is visible throughout its block in both directions. A sibling block is not covered.

Two same-named handlers in one block are prohibited; separate nested blocks can each have one. Delivery selects the handler by the calling block, not a same-named handler in a sibling block. Throwing the same name inside a handler does not re-enter it: this is a failure in the enclosing calling context. An unhandled name propagates only through matching `throws` declarations.

Language operators whose `throws` list the programmer does not see written out (for example `merge`, including the one inside a `Model: fresh` declaration) also throw a named failure, but catching it is optional: a `catch: merge` handler -- before the call, after it, or in a separate nested block -- handles it in the ordinary way and nothing flies anywhere; an uncaught implicit failure flies to the root of the executing Message and the Thread stops (`running = 0`). The only placement constraint is the one declared names have: two same-named `catch` handlers cannot compete at one level.

Worked example from the older specification (`lingvamyxa_prev/tests/t2.lmx`): handlers before the call in separate anonymous blocks, and a handler after the blocks. Each `checkedGreeting(...)` call stands at its `catch`'s level, after the handler; the older specification's rendering put it inside the handler body by an indentation slip, so the example here follows the original (tab = 8).

```text
fn: checkedGreeting (HelloConfig(cfg)) (Text)
    throws:
        GreetingRetry
        GreetingSkip

    if: cfg\greeting\len = 0
        throw: GreetingRetry(cfg)

    if: cfg\greeting\len < 0
        throw: GreetingSkip(cfg\greeting)

    return: cfg\greeting


sub: helloMain
    HelloConfig: cfg
        greeting: "Hello World"
        maxI: 3
        maxJ: 3
    ---

    HelloConfig: emptyCfg
        greeting: ""
        maxI: 1
        maxJ: 1
    ---

    ---
        catch: GreetingRetry ()
            cfg\greeting\len++
        System\out\println: checkedGreeting(cfg)
    ---
        catch: GreetingRetry ()
            emptyCfg\greeting\len++
        System\out\println: checkedGreeting(emptyCfg)

    catch: GreetingSkip (Text: badText)
        System\out\println: ("handled EmptyGreeting: " + badText)
```

`checkedGreeting` may leave by `return: cfg\greeting` or by `throw`. The empty `GreetingRetry ()` catch parameters mean this landing pad takes no payload fields; it mutates the outer `cfg` or `emptyCfg`. `GreetingSkip` binds `cfg\greeting` from `throw: GreetingSkip(cfg\greeting)` to `badText`. Each anonymous `---` block owns one `GreetingRetry` catch and one call, so the two `GreetingRetry` names are not duplicates; the repeat call from the handler is a new activation. `GreetingSkip` sits in `helloMain` after those blocks, so a skip continues at the statements after that `catch`.

`assert` checks a diagnostic invariant. A false condition produces `AssertionViolation`, not a recoverable `throw`; ordinary `catch` cannot handle it and it is not part of `throws`. In the actor profile, publication and cleanup precede delivery to the executing Message's diagnostic root; that Message stops executing and receives no further turns. This need not terminate the OS worker; stopping execution and destroying the object are distinct.

Expected input errors use an explicit condition and declared failure rather than a diagnostic abort. `log` and `error` record observations through the selected profile. `error` alone does not imply `throw`, `assert`, return or termination. A non-literal argument resolves as an ordinary value; an unknown name does not automatically become a log string.

@@ suspension | Повторный запуск и приостановка | Restart and suspension | 7.3; 19.12; 19.15; 21.10
[RU]
`retryable` задаёт повторяемую область. `retry` без имени повторяет ближайшую активную такую область; `retry: label` — указанную. Перед повтором выполняются очистки покидаемой попытки. Переход не откатывает внешние эффекты, изменения графа, уже опубликованные поля или сообщения. Транзакционный откат возможен только как отдельно выраженный протокол над данными.

Сам `retry` — локальный переход текущей активации, не новый вызов и не восстановление скрытого окружения. Текущие рабочие значения продолжают существовать, дополнительной публикации только из-за перехода нет. Если повтор достигает вызова или выхода, действует соответствующая обычная граница. Нагрузка пойманного отказа остаётся явными аргументами обработчика.

`yield` передаёт произведённое значение и приостанавливает активацию. Публикации перед приостановкой нет: поля экземпляра данных уже актуальны. Явные аргументы, динамические входы, локалы и их последующее состояние сохраняются для возобновления; они не превращаются в поля тела или публичное скрытое окружение. Возобновление продолжает работать с тем же экземпляром данных.

Входы производителя фиксируются при начале его активации. Следующий вызывающий `next` не заменяет их своим динамическим окружением. Если `next` реализован отдельным выражением-обёрткой, его входы относятся к его активации, пока явная операция не изменит сохранённое состояние производителя. Представление продолжения и результата итератора не наблюдаемо, если сохраняется описанная семантика.
[EN]
`retryable` defines a restartable region. Unlabelled `retry` repeats the nearest active such region; `retry: label` repeats the named one. Abandoned-attempt cleanups run before restarting. The transfer does not roll back external effects, graph mutations, already published fields or Messages. Transactional rollback requires an explicitly represented data protocol.

`retry` itself is a local transfer in the current activation, not a new call or restoration of a hidden environment. Current working values continue to exist, with no additional publication merely because of the transfer. If repeated execution reaches a call or exit, that boundary's ordinary rules apply. A caught failure's payload remains the handler's explicit arguments.

`yield` transfers a produced value and suspends the activation. There is no publication before suspension: the data instance's fields are already current. Explicit arguments, dynamic inputs, locals and their subsequent state are retained for resumption; they do not become body fields or a public hidden environment. Resumption keeps working with the same data instance.

Producer inputs are fixed when its activation begins. A later `next` caller does not replace them with its own dynamic context. If `next` is a separate wrapper expression, its inputs belong to its activation unless an explicit operation changes the producer's saved state. The continuation and iterator-result representation is not observable when it preserves these semantics.

@@ arrays | Массивы, форма и совместное хранилище | Arrays, shape and shared backing | 6.1–6.5.5; 12–13; 19.29.3
[RU]
Обычный Array — типизированное значение с устойчивой ссылочной идентичностью. Конструктор `[]` создаёт его при достижении места построения. Поле структуры, хранящее ссылку на массив, не является самим массивом. Передача ссылки не копирует элементы; изменение элемента наблюдаемо через другие ссылки, перепривязка локальной ссылки — нет.

Владеющий массив имеет единый непрерывный прямоугольный блок элементов. Вложенные размерности не означают отдельно выделенные строки. Для формы `[d0, …, dN−1]` число элементов равно произведению размерностей, последний индекс меняется быстрее остальных. Массив ссылок на другие массивы — другое значение, не замена прямоугольного многомерного массива. Примитивные элементы не приобретают лексических родителей.

Общий физический дескриптор Array — `VoidArray {size_t size, void *data}`. В `Lmx {VoidArray array, Lmx *parent}` тот же дескриптор вложен по значению первым полем и является самим массивом дочерних физических ссылок; его backing зарегистрирован как адресный диапазон арены, но запись диапазона не является самим `VoidArray`. Отдельный псевдоним `LmxArrayDesc` не нужен. У самостоятельного Array `size` — логическое число элементов, backing содержит ровно столько ячеек. У базового Array нет `capacity`, и он не растёт, не делает resize/append и не переключает backing. Динамическое членство, ёмкость и рост принадлежат только отдельным динамическим дескрипторам вида `{<T>Array array; size_t capacity}`, где `<T>Array` — уже существующий фиксированный дескриптор реального типа элемента T (void — лишь один из типов: сегодня `LmxArrayDesc` только для элементов `void *`; массив int — `{size_t len; int *data}`, без void-дескриптора и без приведений). List (`KIND_LIST`) — публичный такой DynamicArray над элементами `void *`, без скрытого префикса capacity в backing. Физические адреса объектов-ссылок от роста List не зависят; адрес ячейки закрытого backing List не сохраняется через его замену.

`shape(array)` возвращает размерности как целочисленный массив ранга 1 или структуру формы; `rank` — число размерностей; `length` при положительном ранге — первую размерность; `size` — общее число элементов. Число полей содержащей структуры, длина массива и размер служебного пула дескрипторов различаются.

Полный индекс массива ранга N содержит N целочисленных координат. В L3 доступ проверяет дескриптор массива и границы индекса; нарушение границ выражается отказом `Bounds`, а не значением `None`. Частичный индекс может дать представление (*view*), например первая строка `matrix[0]`; полный `matrix[0, 2]` выбирает элемент. Конкретная запись координат задаётся [грамматикой](LMX_grammar.ru.md), а не машинной индексацией C. Эти проверки принадлежат только L3: [доступ L2](L2_spec_ru.md#lowlevel-address), включая получение адреса элемента графового массива, работает без них. Проверки операции не являются отдельным механизмом допуска кандидата вместо [анализа и юнит-тестов](#admission).

View может разделять хранилище в пределах одного Message; копия имеет отдельное хранилище. `slice`, совместимый `reshape`, `transpose`, `permute`, `broadcast` и частичная индексация могут создавать view; `copy`/`clone`, материализация и обычный результат поэлементной арифметики создают копию, если не задан существующий выходной буфер. Представление view является внутренним, но обязано удерживать backing на всё время жизни view и явно определять изменяемый совместный доступ. Возврат ссылки не должен скрыто копировать данные для исправления времени жизни.

`reshape` сохраняет значения и общее число элементов; изменение числа требует явного контракта заполнения/усечения/копирования. Совместимое хранилище позволяет view, иначе необходима явно определённая материализация. `transpose` переставляет последние две оси при ранге не меньше двух либо следует выбранному матричному профилю. `permute(array, axes)` задаёт перестановку осей. Логические stride-данные операции не требуют дополнительных полей у каждого универсального дескриптора.
[EN]
An ordinary Array is a typed value with stable reference identity. Constructor `[]` creates it when execution reaches the construction site. A Structure field holding its reference is not the Array itself. Passing a reference does not copy elements; an element mutation is visible through other references, whereas rebinding a local reference is not.

An owning Array has one contiguous rectangular block of elements. Nested dimensions do not mean separately allocated rows. For shape `[d0, …, dN−1]`, element count is the product of dimensions, with the last index varying fastest. An Array of references to other Arrays is a different value, not a replacement for a rectangular multidimensional Array. Primitive elements acquire no lexical parents.

The common physical Array descriptor is `VoidArray {size_t size, void *data}`. In `Lmx {VoidArray array, Lmx *parent}`, the same descriptor is embedded by value as the first member and is the actual array of physical child references; its backing is registered as an arena address range, but the range entry is not the `VoidArray` itself. A separate `LmxArrayDesc` alias is unnecessary. For a standalone Array, `size` is its logical element count and the backing has exactly that many cells. Base Array has no `capacity` and does not grow, resize, append, or switch backing. Dynamic membership, capacity, and growth belong only to separate dynamic descriptors of the form `{<T>Array array; size_t capacity}`, where `<T>Array` is the already existing fixed descriptor of the real element type T (void is only one element type: today `LmxArrayDesc` solely for `void *` elements; an int array is `{size_t len; int *data}`, never the void descriptor with casts). List (`KIND_LIST`) is a public such DynamicArray over `void *` elements, with no hidden capacity prefix in the backing. Physical addresses stored as referent values are unaffected by List growth; a List backing-slot address does not survive private-backing replacement.

`shape(array)` returns dimensions as a rank-one integer Array or shape Structure; `rank` returns their count; `length` for positive rank returns the first dimension; `size` returns total element count. The containing Structure's field count, Array length and service descriptor-pool size are distinct.

A full rank-N index contains N integer coordinates. L3 access checks the Array descriptor and index bounds; an out-of-bounds access produces a `Bounds` failure, not `None`. A partial index may produce a view, such as first row `matrix[0]`; full `matrix[0, 2]` selects an element. Coordinate spelling belongs to the [grammar](LMX_grammar.en.md), not C machine indexing. These checks belong only to L3: [L2 access](L2_spec_en.md#lowlevel-address), including obtaining a graph-backed element's address, works without them. Operation checks do not constitute a separate candidate-admission mechanism in place of [analysis and unit tests](#admission).

A view can share backing within one Message; a copy has separate backing. `slice`, compatible `reshape`, `transpose`, `permute`, `broadcast` and partial indexing may create views; `copy`/`clone`, materialization and ordinary elementwise arithmetic results create copies unless an existing output buffer is selected. View representation is internal, but it must retain the backing for the view's whole lifetime and explicitly define mutable sharing. Returning a reference must not hide copying to repair lifetime.

`reshape` preserves values and total element count; changing the count requires an explicit fill/truncate/copy contract. Compatible storage permits a view; otherwise explicitly defined materialization is necessary. `transpose` exchanges the last two axes for rank at least two or follows the selected matrix profile. `permute(array, axes)` specifies an axis permutation. An operation's logical stride data need not add fields to every universal descriptor.

@@ array-operations | Операции над массивами | Array operations | 6.5.6–6.5.15
[RU]
Арифметика и сравнения массивов по умолчанию поэлементные. Операция над элементом определяется его числовым доменом и явно выбранным контекстом. `*` означает поэлементное умножение, не матричное. `matmul`, `dot`, `contract` и `outer` — отдельные выраженные операции; профильный символ матричного умножения не должен делать обычное `*` двусмысленным.

Broadcasting сопоставляет положительные размерности справа. Пара допустима, если размеры равны, один равен 1 или одна сторона отсутствует и считается 1; результат берёт максимум. Примеры: `[3]` и скаляр дают `[3]`; `[2,3]` с `[3]` рассматривается как `[2,3]` с `[1,3]`; `[2,3]` с `[2,1]` дают `[2,3]`. Повторно читаемый скаляр не размножается в отдельный массив. Внутренний нулевой stride может выражать повторное чтение одного элемента. Нулевые размерности этим правилом не определены.

`reduce` сворачивает элементы ассоциативной либо явно упорядоченной операцией. Без оси по умолчанию получается примитив; профиль может явно запросить массив ранга 0. С осью сворачивается только она. Контракт задаёт нейтральное значение, когда оно нужно, операцию элемента, тип результата и порядок. Для воспроизводимых вещественных/десятичных вычислений порядок не должен зависеть от случайного выбора backend.

`scan` — префиксная свёртка: включающий вариант суммы для `[1,2,3,4]` даёт `[1,3,6,10]`. Включающий или исключающий вариант выбирается явно. `map` применяет выражение к элементам; чистый вариант допускает векторизацию и параллельное вычисление с сохранением результата. Для эффектов необходим явный порядок; основной профиль предполагает чистое отображение.

`filter` отбирает элементы по логическому предикату и обычно материализует новый массив: выбранные позиции не обязаны образовывать регулярный view. `concat` соединяет по выбранной оси; остальные размерности должны совпадать. Его результат обычно новый массив с прямоугольным backing. Копирование, материализация и все результаты сохраняют границы владельца Message.

Определённый здесь минимальный числовой профиль охватывает ранги 1/2, непрерывное хранилище, проверяемый индекс, форму, копирование, поэлементные `+ - * /`, broadcasting скаляра, операции равной формы и полную свёртку. Другие числовые профили могут добавлять операции отдельными контрактами.
[EN]
Array arithmetic and comparisons are elementwise by default. Element operations follow their numeric domain and explicitly selected context. `*` means elementwise multiplication, not matrix multiplication. `matmul`, `dot`, `contract` and `outer` are separate explicit operations; a profile-specific matrix symbol must not make ordinary `*` ambiguous.

Broadcasting aligns positive extents from the right. A pair is admitted if equal, if one equals 1, or if one side is absent and treated as 1; the result uses the maximum. Examples: `[3]` and a scalar give `[3]`; `[2,3]` with `[3]` is treated as `[2,3]` with `[1,3]`; `[2,3]` with `[2,1]` gives `[2,3]`. A repeatedly read scalar is not expanded into another Array. Internal zero stride can represent repeated reads of one element. Zero extents are not defined by this rule.

`reduce` collapses elements with an associative or explicitly ordered operation. With no axis it returns a primitive by default; a profile may explicitly request a rank-zero Array. With an axis, only that axis is collapsed. The contract defines an identity where needed, element operation, result type and ordering. Reproducible real/decimal computations must not depend on an incidental backend choice of order.

`scan` is a prefix reduction: inclusive sum of `[1,2,3,4]` gives `[1,3,6,10]`. Inclusive or exclusive behavior is explicitly selected. `map` applies an expression to elements; a pure variant permits vectorization and parallel evaluation preserving the result. Effects need explicit ordering; the default profile expects pure mapping.

`filter` selects elements by a Boolean predicate and normally materializes a new Array: selected positions need not form a regular view. `concat` joins along the selected axis; other dimensions must match. Its result is normally a new Array with rectangular backing. Copies, materialization and all results retain Message ownership boundaries.

The minimal numeric profile defined here covers ranks 1/2, contiguous storage, checked indexing, shape, copying, elementwise `+ - * /`, scalar broadcasting, equal-shape operations and whole-array reduction. Other numeric profiles may add operations through separate contracts.

@@ mathematics | Числовые операции, чистота и контексты | Numeric operations, purity and contexts | 6.6–6.6.13
[RU]
Числовые имена и операторы разрешаются в доступные конструкторы, явные описания и вызываемые операции. Семейства включают машинные целые и вещественные, `bigint`, `real`, `decimal`; это не обязательный закрытый список типов языка. GMP, MPFR и decNumber — возможные реализации, не исходная онтология L3. Преобразования задают диапазон, точность и округление по [контракту описаний](#descriptions).

Основной профиль выражений чистый: он допускает только операции с объявленным чистым контрактом. `sqrt`, `sin`, `cos`, `pow`, `abs`, `gcd`, округление и арифметика могут иметь такие обёртки. Эффектные операции остаются допустимыми высокоуровневыми принимающими выражениями, но не становятся чистыми из-за записи в выражении. L3 не запрещает эффекты вообще и не определяет права доступа одним номером уровня.

У низкоуровневой функции с сырыми указателями нет прямого L3-вызова. Высокоуровневая обёртка определяет владение, срок заимствования, политику нуля, границы, тип элементов, изменения, отказы и результат. Без неё доступна только машинная сторона [L2](L2_spec_ru.md#lowlevel-abi). Инициализация и освобождение числового backend обычно являются обязанностью провайдера; пользовательский числовой код не должен вручную имитировать его внутреннее хранение.

Контекст `real` может задавать точность, округление, статусы, traps и требования точности результата; `decimal` — также пределы экспоненты и квантование. Контекст является явно достижимыми данными или фиксированной конфигурацией профиля, не скрытым глобальным состоянием. Конкретные имена принимающих выражений контекста остаются профильными. Детерминированный профиль обязан исключать зависимость результата от неоговорённых платформенных настроек.

Массивы используют те же скалярные операции и контексты. Векторизация, свёртка и тензорная операция не создают другого смысла сложения. Минимальный профиль математики предусматривает базовую арифметику, логические операции, сравнения, конструирование и арифметику трёх расширенных числовых семейств, явные преобразования, выбранные чистые функции и операции числовых массивов. Доступность всей C-библиотеки из этого не следует.
[EN]
Numeric names and operators resolve to available constructors, explicit descriptions and callable operations. Families include machine integers/floats, `bigint`, `real`, `decimal`; these are not a mandatory closed language type list. GMP, MPFR and decNumber are possible implementations, not L3 source ontology. Conversions specify range, precision and rounding under the [description contract](#descriptions).

The default expression profile is pure: it admits only operations with declared pure contracts. `sqrt`, `sin`, `cos`, `pow`, `abs`, `gcd`, rounding and arithmetic may have such wrappers. Effectful operations remain valid high-level receivers but do not become pure by being written in an expression. L3 does not prohibit effects generally or derive authority solely from a level number.

A low-level function with raw pointers has no direct L3 call. A high-level wrapper defines ownership, borrow duration, null policy, bounds, element type, mutation, failures and result. Without it only the machine side of [L2](L2_spec_en.md#lowlevel-abi) is available. Numeric-backend initialization and release normally belong to the provider; user numeric code should not manually reproduce its internal storage management.

A `real` context may define precision, rounding, status, traps and exactness requirements; `decimal` additionally includes exponent limits and quantization. Context is explicitly reachable data or fixed profile configuration, not hidden global state. Exact context receiver names remain profile-specific. A deterministic profile must exclude dependence on unspecified platform settings.

Arrays use the same scalar operations and contexts. Vectorization, reduction and tensor operations do not create a different meaning of addition. The minimal mathematics profile includes basic arithmetic, Boolean operations, comparisons, construction/arithmetic for the three extended numeric families, explicit conversions, selected pure functions and numeric-Array operations. It does not imply exposure of the entire C library.

@@ composition | Композиция и копирование графа | Composition and graph copying | 2.3; 19.17; 19.23; 19.29.7
[RU]
`merge` — исполняемая операция над живыми структурными операндами. Она не является препроцессорным включением, составлением C-типов или изменением исходных значений. Операнды вычисляются один раз слева направо; затем строится новый корень с непосредственными полями в порядке операндов и дописанного тела. Результат прежнего `merge` сам может быть операндом.

Копируется полный используемый граф с необходимыми ссылками и лексическими цепочками до нулевого родителя. Одна карта «источник — копия» используется для всех операндов: общие цели остаются общими, циклы сохраняются, ссылки и `parent` явно переписываются. Корни операндов и необходимые лексические предки не добавляются лишними видимыми полями результата. Лексический родитель нового корня определяется местом выражения `merge`.

Ссылки на общие методы являются терминалами своих контрактов. Когда `merge` встречает [вечную ветвь](#eternal) `independent: const: immutable`, он обязан **не копировать** её, а поместить в результат исходную физическую ссылку. Физическая идентичность сохраняется, владельцем остаётся исходный модуль. Видимость и учёт индекса диапазонов выполняются внутри merge/классификатора; это не отдельная видимая операция и не альтернатива `merge`. Остальное изменяемое использованное состояние получает отдельное хранилище. Алгоритм не оставляет ссылки на изменяемую чужую арену.

Первый операнд — модель результата. Поле более позднего операнда или дописанного тела, совпадающее с полем модели (совпадение известно при трансляции — имя и тип; допуск как при присваивании), записывается **в слот модели**, а не добавляется рядом; поле без соответствия дописывается в конец в порядке операндов. Результат имеет раскладку модели, за которой следуют новые поля, поэтому номера полей модели не сдвигаются, и никакого скрытого смещения у методов нет. Вызываемая Structure состоит из именованных частей `args`, `return` и `body`; любая другая Structure, именованная или безымянная, — это одна часть `body`; отсутствующая часть участвует в `merge` как пустая Structure того же смысла. `merge` идёт попарно по частям и рекурсивно — `args` с `args`, `return` с `return`, `body` с `body` — на каждом уровне по правилу выше: одноимённое поле операнда записывается в слот модели, новое дописывается. Модель остаётся внешней рамкой, каждый следующий операнд сливается внутрь неё, как содержимое каталога в каталог: `merge(add; y: 5)` кладёт поле `y` в `body` метода `add` (специализация), а `merge((n: 5); addN)` кладёт метод `addN` внутрь Structure с полем `n` как вложенное поле — такая Structure сама не вызываема (в её поле 0 стоит `n`), вызов пишется `w\addN(…)`; `n` в теле `addN` разрешается в поле объемлющей Structure. Безымянные операторы `body` слотов не имеют: операторы операнда заменяют операторы модели, если у операнда они есть. Там, где объявлен вызываемый тип — заголовок `fn: add5 (int: x) int merge(y: 5; add)`, результат `fn` у `fn: makeAdder (int: n) fn`, вызываемый формал или цель присваивания, — Structure, содержащая вызываемое вхождение, приводится к нему ещё одним `merge` с методом как моделью: `merge(add; {y: 5}; объявленный заголовок)` — формалы метода, которых нет в объявленной сигнатуре, связываются одноимёнными полями (проверка имени и типа как у любого приведения), объявленный заголовок переопределяет `args` и `return` (сигнатура `add` пропадает). Возврат вложенного метода — один такой `merge` с тремя операндами: метод, Structure из реально используемых значений активации, объявленный заголовок; `add5: 1` даёт 6. У результата слово `native` пусто, поэтому он исполняется интерпретатором; операции адресуют поля по слоту `node` и перенумеровываются картой позиций. Вложенные методы переносятся целиком и сохраняют свои слова `native`. Нативная реализация метода никогда не сливается. Файл сам является Structure, поэтому метод, объявленный на уровне файла, объявлен внутри неё, и её поля — его лексический родитель; поле другой Structure, ссылающееся на такой метод (`A: fn: M`), остаётся при `merge` общей ссылкой на то же вхождение: оно не копируется, а `node` метода не меняется. Метод, объявленный в теле операнда, копируется вместе с операндом и сохраняет свои номера полей. Так же строится возвращаемый вложенный метод: активация собирает Structure из реально используемых значений и копирует в неё вложенное вызываемое вхождение тем же `merge`; скрытого окружения замыкания не возникает. Успешная композиция публикует полностью инициализированный результат, не требует регистрации коротких имён и не меняет источники.

Неуспех — throw с именем `merge` (как у любого оператора, в котором программист не видит явного перечисления `throws`): отлавливать его не обязательно; неотловленный улетает в корень, и поток останавливается (`running = 0`); найденная точка обработки `catch: merge` — до вызова, после него или в отдельном вложенном блоке, по правилам [объявленных отказов](#exceptions) — обрабатывает его стандартно, и никуда он не улетает. Отдельного протокола частичного результата нет. Это не обещание отката побочных эффектов вычисления операндов. Правила освобождения временного хранилища принадлежат владельцу Message. Точный низкоуровневый механизм — [L2](L2_spec_ru.md#copy-merge).

Описание типа, схема, данные модуля или таблица являются обычными данными: применение к ним `merge` не выбирает особый алгоритм композиции дескрипторов. `table` материализует явно выбранное табличное представление; `join` создаёт новый табличный граф, не меняя операнды. Политики строк, ключей, конфликтов и приоритета задаёт табличная операция, не структурное правило поиска поля.

Передача владения уже существующим хранилищем при доставке Message — [другая операция](#delivery), без копирования и без переподчинения структурного `parent`. Сочетание политик допуска — также не `merge`: оно выбирает и проверяет явно переданные данные, не строит структурную копию по умолчанию.
[EN]
`merge` is an executable operation over live structural operands. It is neither a preprocessor include, C-type composition nor mutation of source values. Operands are evaluated once left-to-right; a fresh root is then built with direct fields in operand and appended-body order. A previous `merge` result can itself be an operand.

The complete used graph is copied with required references and lexical chains to a zero parent. One source-to-copy map spans all operands: shared targets remain shared, cycles are preserved, and references and `parent` links are explicitly rewritten. Operand roots and necessary lexical ancestors do not become extra visible result fields. The new root's lexical parent follows the `merge` expression's location.

Shared method references are terminals under their contracts. When `merge` encounters an [eternal branch](#eternal) qualified `independent: const: immutable`, it MUST **not copy** it and MUST place the original physical value reference directly into the result. Physical identity is preserved and the source module remains the owner. Range-index visibility and bookkeeping occur inside merge/classification; they are neither a separate visible operation nor an alternative to `merge`. Other used mutable state receives distinct storage, and the algorithm leaves no references into another mutable arena.

The first operand is the result's model. A field of a later operand or of the appended body that matches a model field (the match is known at translation: name and type; admission as for assignment) is written **into the model's slot**, not added beside it; a field with no counterpart is appended at the end in operand order. The result has the model's layout followed by the new fields, so the model's field indices never move and methods carry no hidden offset. A callable Structure consists of the named parts `args`, `return` and `body`; every other Structure, named or anonymous, is one `body` part; a missing part takes part in `merge` as an empty Structure of the same meaning. `merge` proceeds part by part and recursively -- `args` with `args`, `return` with `return`, `body` with `body` -- under the rule above at every level: an operand's same-name field is written into the model's slot, a new one is appended. The model stays the outer frame and each later operand merges inward, as a directory's contents into a directory: `merge(add; y: 5)` puts the field `y` into the `body` of the method `add` (specialization), while `merge((n: 5); addN)` puts the method `addN` inside the Structure holding `n` as a nested field -- such a Structure is not itself callable (its field 0 is `n`), the call is written `w\addN(...)`; `n` in the body of `addN` resolves to the enclosing Structure's field. Nameless `body` statements have no slots: the operand's statements replace the model's when the operand has any. Wherever a callable type is declared -- the header `fn: add5 (int: x) int merge(y: 5; add)`, the result `fn` of `fn: makeAdder (int: n) fn`, a callable formal or an assignment target -- a Structure holding a callable occurrence is converted to it by one more `merge` with the method as the model: `merge(add; {y: 5}; the declared header)` -- the method's formals absent from the declared signature are bound to same-name fields (name and type checked as in every conversion), the declared header overrides `args` and `return` (the signature of `add` disappears). Returning a nested method is one such `merge` with three operands: the method, the Structure of the activation's actually used values, the declared header; `add5: 1` gives 6. The result's `native` word is empty, so it executes through the interpreter; operations address fields by their slot in `node` and are renumbered by the position map. Nested methods are carried over whole and keep their `native` words. A method's native implementation is never merged. The file is itself a Structure, so a method declared at file level is declared inside it and its fields are the method's lexical parent; a field of another Structure that references such a method (`A: fn: M`) stays, under `merge`, a shared reference to the same occurrence: it is not copied and the method's `node` does not change. A method declared inside an operand's body is copied with the operand and keeps its field indices. A returned nested method is built the same way: the activation assembles a Structure from the values actually used and copies the nested callable occurrence into it by the same `merge`; no hidden closure environment arises. Successful composition publishes a fully initialized result, requires no short-name registration and leaves sources unchanged.

Failure is a throw named `merge` (as for every operator whose `throws` list the programmer does not see written out): catching it is optional; an uncaught one flies to the root and the Thread stops (`running = 0`); a handling point `catch: merge` -- before the call, after it, or in a separate nested block, under the rules of [declared failures](#exceptions) -- handles it in the ordinary way and nothing flies anywhere. There is no separate partial-result protocol. This does not promise rollback of operand-evaluation effects. Temporary-storage release follows the owning Message's rules. The exact low-level mechanism is in [L2](L2_spec_en.md#copy-merge).

A type description, schema, module data or Table is ordinary data: applying `merge` does not select a special descriptor-composition algorithm. `table` materializes an explicitly selected table representation; `join` creates a new table graph without mutating operands. Row, key, conflict and priority policies belong to the table operation, not structural field lookup.

Ownership transfer of existing storage during Message delivery is a [different operation](#delivery), without copying or changing the structural `parent`. Admission-policy combination is likewise not `merge`: it selects and checks explicit data without default structural copying.

@@ registries | Таблицы, запросы, связывание и провайдеры | Tables, queries, linking and providers | 19.18; 19.21–19.27; 19.30
[RU]
Registry, Table, RegistryView, схема и политика — роли обычных значений, не дополнительные категории и не скрытые пространства имён. Каждая операция получает корень реестра явно либо достигает его по выраженной ссылке. Само существование таблицы не включает поиск в ней; строка с ключом `class`, `type`, `provides` или `satisfies` не меняет смысл языка.

В табличном профиле первый столбец задаёт ключ строки. `columns` содержит имена и при необходимости выраженные метаданные; число ячеек плотного набора строк должно делиться на число столбцов, отсутствующие ячейки выражаются явно. Выравнивание текста не добавляет полей. Необязательное `source` обозначает запрос проекции профиля транслятора, не объявляет имена из ячеек как runtime-привязки.

Ячейка может ссылаться на данные, другой ключ, описание, политику, диагностику, свидетельство, провайдер или вызываемое выражение. Текстовый динамический поиск начинается с переданного корня и использует имена его упорядоченных детей. Он не заменяет разрешённые структурные ссылки и не делает таблицу глобальной средой выполнения. Сохранённый результат проверки остаётся данными с явными зависимостями, не бессрочным разрешением будущих вызовов.

Процедурное потребление вызывает выбранное выражение; объектное/событийное передаёт явную цель и состояние; функциональное следует ссылкам операций; логическое строит результаты и сообщения из явных входов. Правила, переменные запроса, унификация и продолжения представлены данными соответствующего графа. Результат запроса не публикует неявно новые имена для других выражений.

Реактивное обновление может создавать события, которые являются сообщениями. Агент может предложить строку или Message; каждый кандидат проходит [единый допуск](#admission). Явная политика ранжирует допущенные варианты, а отдельная операция публикует выбранный результат. Ни успешный тест, ни выбор лучшего варианта сами по себе не обновляют реестр.

Связывание модуля лишь разрешает явно выбранные операции и рецепты построения в физические ссылки. Оно не сканирует произвольный каталог, не создаёт все экземпляры и не копирует runtime-namespace. Провайдер, кодек и правило понижения выбираются явной ссылкой, конфигурацией либо переданной таблицей. План исполнения удерживает выбранную ссылку; смена провайдера — явное действие, не последствие скрытого глобального поиска. Отдельной семантической операции импорта нет: графовую композицию выполняет только `merge`.

`toLmx`/`fromLmx`, если предоставлены профилем, задают операции кодека с явной политикой. Переносимое сохранение выражает содержимое и идентичности согласно кодеку, не образ памяти с нативными адресами, состоянием аллокатора и внешними дескрипторами. Последние требуют отдельных политик внешних ресурсов.

### Ключи и ячейки

Следующие исходные примеры описывают необязательный табличный профиль. Ключи `Circle` и `int` в первой таблице — данные, не объявления. Во второй таблице строковые значения описывают целевое написание; получение `"uint8_t"` по ключам `u8` и `spelling` не меняет семантику исходного типа.

{{l1:11281-11287}}

{{l1:11302-11309}}

Операторная ячейка может прямо содержать ключ реализации. Например, из следующей таблицы выбирается `u32_eq` для соответствующей пары; `None` — установленный этим профилем маркер отсутствия ячейки, не числовой 0.

{{l1:11251-11257}}

### Отношения, связывание и запрос

Одно отношение можно представить матрицей пар типов или сгруппировать вокруг одного операнда. Это разные представления явных данных, не скрытая регистрация перегрузок. Условные обозначения разреженных ячеек принадлежат выбранному табличному профилю.

{{l1:11322-11327}}

{{l1:11331-11336}}

Потребитель таблицы может задать порядок связанных источников и численные приоритеты. Политика конфликтующих строк относится к этому потребителю, не переопределяет правило первого структурного вхождения. Построение реестра и запрос остаются отдельными операциями.

{{l1:11340-11351}}

{{l1:11358-11368}}

### Связанные таблицы результата, эффекта и реализации

Выбранная ячейка не обязана повторять ключи поиска. Выражение `plus[decimal][int] = decimal_int_add` здесь поясняет результат выбора, а не синтаксис присваивания. По полученному ключу отдельные таблицы описывают результат, эффект, целевой уровень, правило понижения и стоимость. Строка `pure` остаётся заявленным свойством: наличие строки не является доказательством чистоты выбранного выражения.

{{l1:11380-11425}}

Диагностический результат также может быть обычным значением ячейки. Для отношения большей арности явный запрос может пройти через промежуточный ключ; запись со стрелкой ниже поясняет последовательность выбора.

{{l1:11436-11445}}

{{l1:11449-11450}}

### Выбор провайдера

Таблица `sqrt.dispatch` выбирает результат и ключ реализации; две связанные таблицы описывают понижение и провайдера. Записи MPFR, ANA_SQRT и CPU_C_Libm — конкретные данные примера, не обязательные встроенные компоненты. Допуск выбранного выражения следует [общему правилу](#admission), а план исполнения удерживает полученную ссылку. Физическое хранение таблиц, backend hash/SQLite, ранжирование неоднозначных запросов и единый формат диагностик требуют отдельного профиля.

{{l1:11510-11535}}
[EN]
Registry, Table, RegistryView, schema and policy are roles of ordinary values, not additional categories or hidden namespaces. Each operation receives a registry root explicitly or reaches it through an expressed reference. Merely having a Table does not trigger lookup; a row keyed `class`, `type`, `provides` or `satisfies` does not change language meaning.

In the table profile the first column provides the row key. `columns` contains names and optional explicit metadata; the cell count of dense rows must be divisible by column count, with missing cells represented explicitly. Text alignment adds no fields. Optional `source` requests a translator-profile projection rather than declaring cell contents as runtime bindings.

A cell can reference data, another key, a description, policy, diagnostic, evidence, provider or callable expression. Dynamic textual lookup starts from a supplied root and uses its ordered children's names. It neither replaces resolved structural references nor makes the Table a global runtime environment. A saved check result remains data with explicit dependencies, not indefinite permission for future calls.

Procedural consumption invokes a selected expression; object/event consumption supplies an explicit target and state; functional consumption follows operation references; logical consumption constructs results and Messages from explicit inputs. Rules, query variables, unification and continuations are data in their respective graph. A query result does not implicitly publish new names for other expressions.

A reactive update may produce events, which are Messages. An agent can propose a row or Message; every candidate undergoes [unified admission](#admission). An explicit policy ranks admitted candidates, and a separate operation publishes the selected result. Neither a successful test nor selection of the best candidate updates the Registry by itself.

Module linking only resolves explicitly selected operations and construction recipes to physical references. It neither scans arbitrary directories, constructs every instance nor copies a runtime namespace. Providers, codecs and lowering rules are selected by an explicit reference, configuration or supplied Table. An execution plan retains the chosen reference; changing providers is explicit, not the result of hidden global lookup. There is no separate semantic import operation: only `merge` performs graph composition.

`toLmx`/`fromLmx`, when provided by a profile, specify codec operations with explicit policy. Portable persistence represents content and identities under the codec, not a memory image of native addresses, allocator state and foreign descriptors. The latter require separate external-resource policies.

### Keys and cells

The following source examples describe an optional table profile. Keys `Circle` and `int` in the first Table are data, not declarations. String values in the second describe target spellings; obtaining `"uint8_t"` through `u8` and `spelling` does not change the source type's semantics.

{{l1:11281-11287}}

{{l1:11302-11309}}

An operator cell can directly hold an implementation key. For example, the following Table selects `u32_eq` for the corresponding pair; `None` is this profile's missing-cell marker, not numeric 0.

{{l1:11251-11257}}

### Relations, linking and queries

One relation can be represented as a matrix of type pairs or organized around one operand. These are different views of explicit data, not hidden overload registration. Sparse-cell notation belongs to the selected table profile.

{{l1:11322-11327}}

{{l1:11331-11336}}

A table consumer may define linked-source order and numeric priorities. Conflicting-row policy belongs to that consumer and does not override first-occurrence structural lookup. Registry construction and querying remain separate operations.

{{l1:11340-11351}}

{{l1:11358-11368}}

### Linked result, effect and implementation tables

A selected cell need not repeat its lookup keys. Here `plus[decimal][int] = decimal_int_add` explains a selection result, not assignment syntax. Separate Tables use that key to describe result, effect, target level, lowering and cost. A `pure` row remains a declared property: its presence does not prove the selected expression's purity.

{{l1:11380-11425}}

A diagnostic result can also be an ordinary cell value. For a higher-arity relation, an explicit query can follow an intermediate key; the arrows below explain this selection sequence.

{{l1:11436-11445}}

{{l1:11449-11450}}

### Provider selection

`sqrt.dispatch` selects a result and implementation key; two linked Tables describe lowering and provider. MPFR, ANA_SQRT and CPU_C_Libm are concrete example data, not mandatory built-ins. The selected expression undergoes [ordinary admission](#admission), and the execution plan retains its reference. Physical table storage, hash/SQLite backends, ambiguous-query ranking and a common diagnostic format require a separate profile.

{{l1:11510-11535}}

@@ memory | Владение, достижимость и срок жизни | Ownership, reachability and lifetime | 19.29.0–19.29.5; 19.29.8–19.29.14
[RU]
Каждый Message, исполняющийся или нет, владеет одной логической ареной изменяемых данных. Арена может включать несколько непересекающихся областей; это не дополнительные арены исходного языка. Вызов, блок, обработчик, ветвление и повторная попытка не создают своих семантических арен. L3 не выбирает арену аргументом операции.

Лексическая вложенность, владение памятью и достижимость — разные отношения. В одной арене может быть несколько лексических деревьев. При передаче владения блоками их адреса и `parent` сохраняются; новый владелец не становится автоматически лексическим родителем и не получает неявную прикладную ссылку на каждый принятый объект.

Живость определяется достижимостью, не членством в списке блоков. Корни включают корень Message, активные структурные аргументы, удерживаемые собственные поля, результаты, ссылки формальных и динамических входов, продолжения и явно сохранённые прикладные/служебные ссылки. Обход следует типизированным рёбрам графа, необходимым родителям, связи массива с backing и ссылочным элементам. Вспомогательный индекс имён не является корнем.

Живые узлы и дескрипторы не перемещаются. Рост добавляет хранилище, не инвалидируя опубликованные ссылки. Лексический выход не уничтожает достижимый возвращённый объект; возврат не требует скрытого копирования или «продвижения» дерева. Стабильный адрес, однако, не гарантирует вечную жизнь недостижимого объекта.

В конце каждого такта выполняется один локальный проход сбора: определить исход такта, опубликовать успешные исходящие сообщения либо отбросить неуспешную подготовку, отпустить завершённые входные/временные корни, собрать арену владельца. Обычный возврат, `break`, `continue`, `retry`, `redo` и пойманный `throw` не являются отдельными точками сбора. Сохранившееся приостановленное продолжение удерживает свои ссылки.

Принятый граф, на который приложение не сохранило ссылок, после снятия временных корней может быть собран уже в конце такта. Передача арены не превращает его в вечный корень. Удерживаемая история отказа живёт по своей явной политике. Уничтожение Message в итоге освобождает его оставшееся хранилище; сбор не обходит чужую изменяемую арену и не требует глобальной блокировки.

Внешний ресурс имеет отдельный контракт владения, удержания, освобождения и передачи. `copy`, сериализация и `merge` не придумывают дублирование нативного ресурса. Неизменяемость его идентификатора не продлевает жизнь ресурса. Физический сборщик, типизированные пулы и регистрация областей описаны в [L2](L2_spec_ru.md#arena) и [L1](L1_spec_ru.md#arena).
[EN]
Every Message, executing or not, owns one logical arena of mutable data. It can contain multiple disjoint regions; these are not additional source-level arenas. Calls, blocks, handlers, branches and retries do not create their own semantic arenas. L3 does not select an arena through an operation argument.

Lexical nesting, storage ownership and reachability are distinct relationships. One arena may contain multiple lexical trees. Transferring block ownership preserves addresses and `parent`; the new owner neither becomes the lexical parent automatically nor gains an implicit application reference to every adopted object.

Liveness follows reachability, not block-list membership. Roots include the Message root, active structural arguments, retained own fields, results, formal/dynamic input references, continuations and explicitly retained application/service references. Tracing follows typed graph edges, necessary parents, Array-to-backing links and reference-valued elements. The auxiliary name index is not a root.

Live nodes and descriptors do not move. Growth adds storage without invalidating published references. Lexical exit does not destroy a reachable returned object; return requires no hidden copy or tree promotion. A stable address, however, does not guarantee indefinite life for an unreachable object.

One local collection pass runs at each end-of-turn: determine the outcome, publish successful outgoing Messages or discard failed staging, release completed input/temporary roots, and collect the owner's arena. Ordinary return, `break`, `continue`, `retry`, `redo` and caught `throw` are not separate collection points. A surviving suspended continuation retains its references.

An adopted graph with no application-retained references can be collected at end-of-turn once temporary roots are released. Arena transfer does not make it a permanent root. Retained failure history lives under its explicit policy. Destroying a Message ultimately releases its remaining storage; collection neither scans another mutable arena nor requires a global lock.

A foreign resource has a separate ownership, retention, release and transfer contract. `copy`, serialization and `merge` do not invent native-resource duplication. Immutability of its identifier does not extend resource lifetime. The physical collector, typed pools and region registration are described in [L2](L2_spec_en.md#arena) and [L1](L1_spec_en.md#arena).

@@ eternal | Вечные ветви и общие методы | Eternal branches and shared methods | 9.1.4; 19.29.6; 19.29.9
[RU]
Совместная квалификация `independent: const: immutable` задаёт запечатанную неизменяемую независимую ветвь: у её корня `parent = 0`, содержимое и защищённые привязки неизменяемы. Для начального лексически известного модуля явное удержание владельцем R0 даёт срок хранения до завершения процесса. Сама квалификация не выбирает глобального владельца и не определяет выгрузку будущего модуля. Одна из квалификаций отдельно не даёт этого контракта общего использования.

Начальная сборка процесса может создать известный трансляции неизменяемый типизированный массив физических ссылок на такие ветви и явно передать его корневому Message. `merge` и создание Message не пополняют и не наследуют этот массив автоматически. Размещение ссылки в массиве не переподчиняет лексическое дерево ветви. Допустимая инициализация значениями времени выполнения происходит до публикации и не увеличивает множество записей.

Начальная сборка может разместить опубликованные ветви и удерживающие их запечатанные типизированные диапазоны в арене Root Thread (`R0`) тем же способом, которым типизированные массивы создаются в арене любого L3 Thread. Срок процесса получается из явного владения и удержания R0, а не из скрытой таблицы, особого класса хранилища или способности, доступной только корню. Сборщик не освобождает эти явно удерживаемые начальные диапазоны; ссылка на ветвь в другом Message является внешним терминалом для его сборщика и не переносит владение.

Принадлежность значения типу вечной ветви устанавливается тем же индексом типизированных диапазонов адресов, что и принадлежность другим физическим типам. Её запечатанный диапазон остаётся в обычной арене явного владельца; срок жизни задают явное удержание владельцем и запрет сбора этого диапазона, а не отдельное постоянное хранилище. Эти правила не заменяют классификацию по диапазону и не являются флагом отдельной ветви.

Известные записи методов также могут быть явно собраны в неизменяемый типизированный массив той же арены и переданы через физические ссылки. Дополнительный индекс вместе со ссылкой не образует идентичность записи. Метод не хранит лексического родителя; его конкретное вызываемое вхождение предоставляет собственную структуру. Разделяемые записи остаются живы после завершения заимствующего дочернего Message, только если их явный владелец продолжает их удерживать. Скрытого глобального или корневого реестра методов нет.

R0 удерживает неизменяемые независимые ветви начального модуля только потому, что владеет этим лексически фиксированным модулем, порождает начальных детей и может явно передать им заранее известные физические ссылки. Позднее подключённый DLL-подобный модуль имеет собственные запечатанные типизированные диапазоны у своего владельца и в своей арене. Когда `merge` встречает его `independent: const: immutable` ветвь, потребитель получает в результате исходную физическую ссылку, а модуль остаётся владельцем. Это не превращает R0 в глобальное хранилище. Выгрузка такого модуля и срок жизни его диапазонов здесь не определены.

`merge` и создание Message сохраняют явно переданные ссылки на допущенные вечные ветви и записи методов как терминалы. Получение одной ветви не раскрывает массив удержания, настройки корня или остальные ветви. Изменяемое состояние по-прежнему копируется отдельно. Все ссылки внутри опубликованной вечной ветви должны иметь достаточный срок жизни; квалификация не делает случайную ссылку на освобождаемую память вечной.

Например, A и созданный из его шаблона B могут иметь один адрес вечной E и разные ячейки изменяемого x. Завершение A и B не освобождает E. Одинаковое содержимое двух отдельно построенных ветвей не означает их автоматического интернирования. При переносе в другой процесс нативный адрес не становится сетевой идентичностью: нужен явный кодек.
[EN]
Combined qualification `independent: const: immutable` establishes a sealed immutable independent branch: its root has `parent = 0`, and its contents and protected bindings are immutable. For the initial lexically known module, explicit retention by owner R0 gives process-long storage. The qualification itself neither selects a global owner nor defines unloading of a future module. Any one qualification alone does not establish this sharing contract.

Process bootstrap may construct a translation-known immutable typed Array of physical references to such branches and explicitly supply it to the root Message. `merge` and Message creation neither append to nor inherit this Array automatically. Placement in the Array does not reparent a branch's lexical tree. Permitted runtime-value initialization occurs before publication without increasing the entry set.

Bootstrap may place the published branches and their retaining sealed typed ranges in the Root Thread's (`R0`) arena through the same mechanism that creates typed Arrays in any L3 Thread arena. Process lifetime follows from explicit ownership and retention by R0, not from a hidden table, special storage class, or root-only capability. Collection does not release these explicitly retained initial ranges; a reference to a branch in another Message is an external terminal for that Message's collector and does not transfer ownership.

Membership in the eternal-branch type is established by the same typed-address-range index used for all other physical types. Its sealed range remains in the explicit owner's ordinary arena; explicit owner retention and exclusion of that range from collection determine its lifetime, not a separate permanent store. These rules neither replace range classification nor become a flag on each branch.

Known method records may likewise be assembled explicitly into an immutable typed Array in the same arena and supplied through physical references. A supplementary index alongside the reference does not form record identity. A method stores no lexical parent; its concrete callable occurrence supplies its own Structure. Shared records remain live after a borrowing child Message terminates only while their explicit owner retains them. There is no hidden global or root method registry.

R0 retains immutable independent branches of the initial module only because it owns that lexically fixed module, spawns the initial children, and can explicitly pass their translation-known physical references. A DLL-like module loaded later has its own sealed typed ranges under its own owner and in its own arena. When `merge` encounters its `independent: const: immutable` branch, the consumer receives the original physical reference in the result and the module remains the owner. This does not make R0 global storage. This specification does not yet define that module's unload operation or the lifetime of those ranges.

`merge` and Message creation retain explicitly supplied references to admitted eternal branches and method records as terminals. Receiving one branch does not expose its retention Array, root settings or unrelated branches. Mutable state is still copied separately. Every reference within a published eternal branch must have sufficient lifetime; qualification does not make an arbitrary reference to reclaimable storage eternal.

For example, A and B constructed from A's template can have the same eternal E address and distinct mutable x cells. Finishing A and B does not release E. Equal contents of separately constructed branches do not imply automatic interning. Across processes a native address is not wire identity: an explicit codec is required.

@@ messages | Message, актор и последовательный такт | Message, actor and serial turn | 19.28.R2.1–19.28.R2.3; 19.29.6
[RU]
Message — изолированный граф с собственным владением. Обычный шаблон или письмо не исполняется и может существовать как самостоятельный минимальный `LmxMsg`. Исполняемый объект, напротив, изначально строится как L3 Thread. Его `LmxMsg message` является первым членом по значению, поэтому Thread и его Message-префикс имеют один физический адрес. Этот общий префикс предоставляет только идентичность и операции Message: он не превращает каждый Message в Thread и не помещает почту, планирование, режим хода либо другие механизмы Thread в `LmxMsg`. Самостоятельный Message нельзя позднее преобразовать на месте в Thread. Точная классификация по диапазонам адресов по-прежнему различает отдельное хранилище Message и хранилище Thread: общий вид Message допускает оба, а доступ к хвосту Thread требует точного типа Thread. Получение письма не создаёт автоматически новый поток или актор. Для запуска отдельного ребёнка нужна явная операция.

При создании `lmx_message` или `lmx_thread` в его собственную арену попадают только данные и физические ссылки, явно переданные создающей операцией. Состояние родителя, таблицы начальной сборки, массивы методов, вечные ветви и ссылки на сервисы не копируются и не наследуются неявно. Обычный L3 Thread может хранить и использовать всё доступное R0, если эти значения переданы ему явно.

Исполняющийся Message имеет FIFO-почту и не более одного активного такта одновременно. За такт потребляется не более одного допущенного входа. Между разными Message возможна параллельность. Пустой ящик не означает завершение фоновой задачи: механизм продолжает проверять почту согласно своему режиму исполнения до условия остановки.

Во время такта один L3 Message исполняется ровно одним потоком ОС; передача другому рабочему потоку возможна только между тактами. У L3 Thread нет режима исполнения: путь каждого вызова определяет дескриптор вызываемого вхождения — с нативным адресом вызов исполняется нативно, без адреса тело (op-дерево графа) исполняет интерпретатор; интерпретироваться может только L3, L2-операции — нет. Один вызов не запускает оба пути для одного Message: диспетчер не повторяет вызов другим путём после ошибки и не подменяет путь, заданный дескриптором, ни по телу, ни по результату предыдущей диспетчеризации. Выбор пути не создаёт копию метода или второй параллельный исполнитель; `implements` и другие принимающие выражения диспетчер сам не запускает.

Одна арена имеет одну полосу записи. Обработчик, локальное управление, планировщик и служебные данные Message изменяются на его полосе. Чужой отправитель не дописывает себя в ready-list владельца и не меняет его прикладные данные. Исключение приёма почты и специальные одноячеечные протоколы управления относятся к механизму Message, не дают общего доступа к чужой памяти.

Родитель управляет только своими непосредственными детьми. Единственный состав этих детей — List (`KIND_LIST`) физических ссылок в графе родителя; планировщик родителя обходит именно его. Цепочка семейных записей, очередь членства менеджера, фиксированный набор слотов или иной параллельный реестр детей запрещены. Локальная политика порядка обхода принадлежит родителю, но не создаёт второй источник членства. Ребёнок аналогично управляет своими детьми. Нет отдельного глобального планировщика языка, общего изменяемого реестра Message или глобальной блокировки управления. Маршрутизатор, если нужен, сам является Message с собственным состоянием.

R0 является обычным L3 Thread в этом дереве и по умолчанию не имеет функций, которых нет у другого L3 Thread. Его родитель-каркас представляет верхний элемент будущего WorldWideMix и связывается с R0 обычным механизмом родителя; это надзор Message, а не лексическая связь `node`. Только сам верхний каркас не имеет родителя, но дополнительных функций от этого не получает. Внешний host-watchdog, а не каркас или R0, задаёт общий срок ожидания закрытия поддерева и завершает процесс ОС, если обычный каскад не достиг безопасной границы. Особого массива детей, иной схемы планирования или числовой идентичности для R0 нет.

L3 Thread — логическая последовательная полоса, не обещание отдельного потока ОС. Возможны собственный поток и выполнение тактов родителем/платформенным адаптером. API и политика отображения задаются реализацией L2; это не разрешает одновременно выполнять два такта одного владельца. Опрос жизнеспособности родителя и собственное обслуживание нужны и актору без детей.

Первоначальный граф процесса принадлежит корневому Message. Начальные настройки и пользовательский ввод поступают при входе, последующая координация выполняется сообщениями. Группировка ролей Mix, курсоров, страниц и уведомлений по Message остаётся выбором проектирования: не требуется ни один актор на весь документ, ни отдельный актор на каждую ячейку.
[EN]
A Message is an isolated graph with its own ownership. A plain template or letter is non-executable and may exist as a standalone minimal `LmxMsg`. An executable object is instead constructed as an L3 Thread from the beginning. Its `LmxMsg message` is the first member by value, so the Thread and its Message prefix have the same physical address. This common prefix supplies Message identity and operations only; it does not turn every Message into a Thread or put mail, scheduling, turn mode, or other Thread mechanisms into `LmxMsg`. A standalone Message cannot later be upgraded in place to a Thread. Exact address-range classification still distinguishes standalone Message storage from Thread storage: the generic Message kind admits both, whereas access to the Thread-only tail requires the exact Thread type. Receiving a letter does not automatically create a thread or actor. Launching a separate child requires an explicit operation.

Creating an `lmx_message` or `lmx_thread` places in its own arena only the data and physical references explicitly supplied by the creating operation. Parent state, bootstrap tables, method Arrays, eternal branches, and service references are neither copied nor inherited implicitly. An ordinary L3 Thread can retain and use everything available to R0 when those values are supplied explicitly.

An executing Message has FIFO mail and at most one active turn at a time. A turn consumes at most one admitted input. Different Messages may execute concurrently. An empty mailbox does not finish a background task: its mechanism keeps checking mail according to its execution mode until a stopping condition.

During a turn, one L3 Message executes on exactly one OS thread; transfer to another worker is allowed only between turns. An L3 Thread has no execution mode: each call's path is set by the callable occurrence's descriptor -- with a native address the call executes natively, without one the body (the graph's op tree) is executed by the interpreter; only L3 can be interpreted, L2 operations cannot. One call never runs both paths for one Message: the dispatcher does not retry a call through the other path after a failure and does not override the path set by the descriptor from the body or from a previous dispatch result. Choosing the path neither copies the method nor creates a second concurrent executor; the dispatcher never runs `implements` or other receiving expressions on its own.

One arena has one writing lane. A Message's handler, local management, scheduler and service state are mutated on its own lane. A foreign sender neither appends itself to the owner's ready list nor modifies its application data. Mail admission and designated single-cell control protocols belong to the Message mechanism and grant no general access to foreign memory.

A parent manages only its direct children. Sole membership of those children is a List (`KIND_LIST`) of physical references in the parent's graph, and the parent's scheduler traverses that exact List. A family-record chain, manager membership queue, fixed group of slots, or any other parallel child registry is forbidden. Local traversal-order policy belongs to the parent but does not become a second membership source. Each child likewise manages its own children. There is no separate global language scheduler, shared mutable Message registry, or global management lock. A router, if needed, is itself a Message with private state.

R0 is an ordinary L3 Thread in this tree and has no functions unavailable to another L3 Thread by default. Its parent frame represents the upper element of the future WorldWideMix and connects to R0 through the ordinary parent mechanism; this is Message supervision, not a lexical `node` link. Only the upper frame itself has no parent, but that grants it no additional functions. An external host watchdog, not the frame or R0, applies the overall subtree-close deadline and terminates the OS process if the ordinary cascade cannot reach a safe boundary. R0 has no special child Array, alternate scheduling scheme, or numeric identity.

An L3 Thread is a logical serial lane, not a promise of a dedicated OS thread. Both a dedicated thread and parent/platform-driven turns are possible. L2 implementation defines the API and mapping policy; this does not permit two simultaneous turns of one owner. Parent-liveness polling and self-maintenance are needed even by a childless actor.

The process's initial graph belongs to the root Message. Initial settings and user input arrive at entry; subsequent coordination uses Messages. Grouping Mix roles, cursors, pages and notifications into Messages remains a design choice: neither one actor for the whole document nor a separate actor for every cell is required.

@@ delivery | Доставка, владение и порядок изменений | Delivery, ownership and mutation order | 19.19; 19.28.R2.4–19.28.R2.5; 19.29.6–19.29.7
[RU]
Локальный промежуточный уровень адресует участников физическими адресами памяти в рамках допускаемых операций механизма Message. Иерархическая цепочка индексов относится к [WorldWideMix](#worldwide), начиная с третьего масштаба организации, а не к каждому локальному письму. Масштаб организации не следует смешивать с профилем языка L3. Нативный адрес не сериализуется как переносимый адрес другой машины.

Каждый L3 Thread владеет собственным почтовым ящиком и его API. Явно переданный родителем сервис доставки разрешает адрес и доставляет письмо к операции приёма целевого ящика; он не смотрит и не читает содержимое ящика. Сервис доставки не исполняет получателя, не планирует его такты и не ведёт реестр членства детей.

Доставка существующего неисполняющегося Message может передавать владение его хранилищем получателю без перемещения данных. Блоки и классификация областей переходят в единую арену получателя, бывший владелец больше не освобождает их. Лексические связи остаются прежними; прикладное включение принятого корня выполняется явно. Передача хранилища не равна созданию копии и не сохраняет отправленный объект как второго независимого владельца.

Создание нового исполняющегося Message из шаблона использует [копирование графа](#composition) и его отдельную арену. Обычные настройки копируются, допущенные вечные ссылки сохраняются. Создание не импортирует неявно всё живое окружение родителя. Передача надзора над работающим ребёнком, передача остановленного хранилища и сериализация удалённого сообщения — три разных контракта.

Одновременные поступления не имеют заранее заданного относительного порядка. Приём в ящик устанавливает FIFO-порядок, который сохраняется при потреблении. Ни случайное перемешивание, ни порядок по часам отправителей не являются правилом. Проверка пустоты и ожидание согласованы с приёмом: уже принятое письмо не должно потеряться при переходе получателя в ожидание. Вместимость, обратное давление и повторная доставка — явные политики реализации/протокола.

Несколько отправителей изменяют один объект, посылая полную операцию владельцу. Например, `add(2)` и `add(5)` при начальном 0 дают 7 в любом из двух порядков приёма. Раздельные `read` и `write` не образуют одной защищённой операции: два отправителя могут прочесть 10 и оба записать 11. Последовательные такты предотвращают перекрытие исполнения, не создают транзакционный откат или защиту разорванного протокола.

Успех доставки означает принятие, не выполнение прикладного изменения. Для результата нужна предусмотренная протоколом корреляция ответа. Ядро не добавляет автоматически историю последних идентификаторов и подавление повторов каждого отправителя. Требования дедупликации, повторов, пакетирования и сортировки выражаются отдельным протоколом, не меняющим базовый FIFO.

Исходящие письма текущего такта подготавливаются отдельно от опубликованной очереди. Успешная граница публикует их в порядке подготовки; неуспешная отбрасывает неопубликованное. Уже выполненные изменения графа этим не откатываются. Граница [сбора](#memory) наступает после обработки результата и временных корней.
[EN]
The local intermediate organization level addresses participants by physical memory addresses within admitted Message-mechanism operations. Hierarchical index chains belong to [WorldWideMix](#worldwide), starting at the third organization scale, not to every local letter. Organization scale must not be confused with language profile L3. A native address is not serialized as a portable address on another machine.

Each L3 Thread owns its mailbox and mail API. A delivery service explicitly supplied by the parent resolves an address and delivers a letter to the destination mailbox's admission operation; it neither observes nor reads mailbox contents. The delivery service does not execute the recipient, schedule its turns, or maintain a child-membership registry.

Delivery of an existing non-executing Message can transfer its storage ownership to the receiver without moving data. Blocks and region classification join the receiver's single arena; the former owner no longer releases them. Lexical links remain unchanged; application attachment of the received root is explicit. Storage transfer is not copying and does not retain the sent object as a second independent owner.

Creating a new executing Message from a template uses [graph copying](#composition) and a separate arena. Ordinary settings are copied; admitted eternal references are retained. Creation does not implicitly import the parent's entire live context. Handing off supervision of a running child, transferring stopped storage and serializing a remote Message are three different contracts.

Concurrent arrivals have no predetermined relative order. Mailbox admission establishes FIFO order, preserved by consumption. Neither random shuffling nor sender-clock order is required. Empty-check/wait coordinates with admission: an accepted letter must not disappear as the receiver begins waiting. Capacity, backpressure and redelivery are explicit implementation/protocol policies.

Multiple senders mutate one object by sending its owner a complete operation. For example, `add(2)` and `add(5)` from initial 0 produce 7 in either admission order. Separate `read` and `write` requests are not one protected operation: two senders may both read 10 and write 11. Serial turns prevent overlapping execution but establish neither transaction rollback nor protection for a split protocol.

Delivery success means admission, not application of a requested change. A result requires protocol-defined reply correlation. The core does not automatically retain per-sender last identifiers or suppress duplicates. Deduplication, retry, batching and sorting requirements belong to explicit protocols without changing base FIFO.

Current-turn outgoing letters are staged separately from the published queue. A successful boundary publishes them in staging order; failure discards unpublished staging. This does not undo graph mutations already performed. The [collection boundary](#memory) follows outcome and temporary-root processing.

@@ lifecycle | Завершение, дети и сохранение результата отказа | Completion, children and retained failure state | 19.28.R2.2–3; 19.29.6–19.29.8
[RU]
`success` исполняемого Message ставит только пользовательский код: система никогда не сбрасывает его в 0, даже при ошибке, и не ставит 1 сама; `success = 1` — достаточное условие остановки Thread на end turn. Система ставит `success = 1` только простому письму при его доставке. Пустой ящик успехом не является. После установки `success` основной алгоритм Message не получает следующий такт; завершение локального обслуживания детей зависит от реализации. `running = 0` во время работы может быть запросом остановки: физическая безопасность передачи хранилища устанавливается отдельным протоколом, не угадывается по одному флагу.

Ребёнок проверяет жизнеспособность родителя и после длительного отсутствия ответа начинает собственное упорядоченное закрытие. Принудительное закрытие сверху — аварийный второй путь. Родитель обслуживает физических адресатов из единственного графового List (`KIND_LIST`) своих прямых детей и не выполняет произвольное управление внуками. Каждый ребёнок повторяет каскад для собственного List; закрытие распространяется по семейству, а не сохраняет навсегда освобождённую ветвь.

Работающий ребёнок может пережить закрытие родителя только при явной передаче надзора другому живому родителю с подходящим полномочием. Он сохраняет свою арену, почту и такт; меняется надзор и место в планировании. Это не усыновление памяти. При передаче памяти неисполняющийся источник прекращает отдельную жизнь; новые дети из принятого содержимого принадлежат уже получателю.

Неуспешное остановленное состояние может быть передано родителю без копии и удержано как граф истории отказа; успешная история по умолчанию освобождается. Передача требует остановленного, безопасного для передачи состояния и отсутствия нативных пользователей. Необходимо сохранять различие запроса остановки, фактического выхода, безопасной передачи и освобождения; конкретные флаги и их размещение относятся к [ядру L2](L2_spec_ru.md#message).

Оставшийся без родителя участник закрывается по политике сирот: успешное завершение освобождает его, неуспешная история может сохраняться до явно заданного срока. Эта политика не создаёт второй глобальный реестр или отдельного бессрочного владельца вне Message.
[EN]
An executing Message's `success` is set only by user code: the system never resets it to 0, not even on failure, and never sets it to 1 itself; `success = 1` is a sufficient condition for stopping the Thread at end turn. The system sets `success = 1` only for a plain letter, at its delivery. An empty mailbox is not success. Once `success` is set, the Message's main algorithm receives no next turn; finishing local child maintenance depends on implementation. `running = 0` during execution may be a stop request: physical storage-handoff safety is established by a separate protocol, not inferred from one flag.

A child checks parent liveness and begins its own orderly close after sustained lack of response. Forced closure from above is the second, emergency path. A parent services physical addressees from the sole graph List (`KIND_LIST`) of its direct children rather than arbitrarily managing grandchildren. Each child repeats the cascade for its own List; closing propagates through the family instead of retaining a released branch forever.

A running child can survive parent closure only through explicit supervision handoff to another live parent with suitable authority. It retains its arena, mail and turn; supervision and scheduling placement change. This is not storage adoption. Storage transfer ends the non-executing source's separate life; new children created from adopted content belong to the receiver.

Stopped failed state may be transferred to the parent without copying and retained as failure-history graph; successful history is reclaimed by default. Transfer requires a stopped, handoff-safe source with no native users. Stop request, actual exit, safe transfer and release must remain distinct; concrete flags and placement belong to the [L2 kernel](L2_spec_en.md#message).

A participant that loses its parent closes under an orphan policy: successful completion releases it, while failure history may remain until an explicit deadline. This policy creates neither a second global registry nor an indefinite owner outside Messages.

@@ pipeline | Допуск и исполнение входящего сообщения | Incoming-message admission and execution | 19.19; 19.22; 19.28.R2.4; 19.31
[RU]
Входящие данные проходят явный декодер и становятся графом Message. Затем выбираются адресат, маршрут и принимающее выражение через заданные ссылки или поиск от заданного корня. Ни текст сообщения, ни ссылка на таблицу не устанавливают скрытое окружение и не дают автоматического доверия.

Допуск кандидата следует [единому механизму](#admission): аналитический обход используемого дерева, затем юнит-тесты принимающего выражения, исполняемые интерпретатором графа. Декодирование текста строит входной граф до этого этапа; интерпретатор тестов не интерпретирует исходный текст вместо графа.

Маршрут, полномочия, срок жизни и допустимые эффекты представлены явными данными контракта. Проверки свойств кандидата включаются в тесты принимающего выражения; криптографические операции могут предоставить проверяемые факты. Свидетельство хранит ссылку на конкретные данные, политику и установленные на входе факты. Повторное использование результата допустимо только по явному контракту применимости из [валидации кандидата](#graph-tests).

После допуска выбирается явная ссылка на реализацию/провайдер и строится план исполнения с аргументами, результатами и необходимыми политиками. Формирование плана не исполняет выбранную прикладную операцию, хотя этап допуска уже исполнял её тесты. Исполнитель следует зафиксированной ссылке. Результат или объявленный отказ становится входом следующего явного потребителя.

Логический генератор может построить ноль или несколько предложенных Message. Каждый снова проходит тот же путь; происхождение от генератора не даёт доверия. Полученный текст не переносит работающий кадр чужого актора. Работа выполняется в последовательном такте получателя, если отдельный запуск ребёнка не указан явно.
[EN]
Incoming data pass through an explicit decoder to become a Message graph. The destination, route and receiving expression are then selected through supplied references or lookup from a supplied root. Neither Message text nor a Table reference installs a hidden environment or grants automatic trust.

Candidate admission follows the [unified mechanism](#admission): analytical traversal of the used tree, followed by receiving-expression unit tests executed by the graph interpreter. Text decoding constructs the input graph before this stage; the test interpreter does not interpret source text instead of the graph.

Routes, authority, lifetime and permitted effects are explicit contract data. Candidate-property checks belong to receiving-expression tests; cryptographic operations may supply verifiable facts. Evidence references exact data, policy and authenticated ingress facts. A result may be reused only under the explicit applicability contract in [candidate validation](#graph-tests).

After admission, an explicit implementation/provider reference is selected and an execution plan is built with arguments, results and required policies. Planning does not execute the chosen application operation, although admission already executed its tests. The executor follows the retained reference. A result or declared failure becomes input to the next explicit consumer.

A logical generator may construct zero or more proposed Messages. Each re-enters the same path; generator origin confers no trust. Received text does not transfer another actor's running frame. Work executes in the receiver's serial turn unless a separate child launch is explicit.

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

Mix-слой размещает на тех же позициях пересекающиеся метки, курсоры, атрибуты и интервалы. Составление значения страницы использует обычный [merge](#composition) с первым `[0]`-вхождением, не переопределение соседних адресов. Заполнение диска не даёт права автоматически вытеснить данные к произвольному соседу: отказ, уплотнение или явно разрешённое зеркало задаются профилем хранения.
[EN]
WorldWideMix defines a placement tree: where a cell is situated. The LMX graph defines a value: its fields and what an expression consumes. These trees meet in a cell but are not identical: address `3.17.4` is not field path `file\close`, and `implements` does not number Mix neighbours.

An address is a sequence of nonnegative integers from root to cell. Neither an individual branch's depth nor index magnitude has a language-defined finite ceiling; implementations must check actual resource limits rather than overflow their representation. Leading textual zeros do not change meaning: `03.17` equals `3.17`. A prefix addresses a subtree; shortening the path reaches an ancestor.

The numbers count neighbouring positions, not bytes. A cell may hold a word, buffer or value reference. Varints, mixed-width fields and other codecs store the same integers rather than defining different address types. Changing storage from 5 to 12 bits does not rename `3.17`. Examples of tens of RAM neighbours and larger disk-sector occupancy illustrate carriers, not address-model limits.

Branches may have different depths. For prefix P, `bunch(P)` contains only occupied direct indices. If `{0,4,5}` are occupied, `P.4` is followed by `P.5` and preceded by `P.0`. `next`/`prev` neither descend, ascend nor traverse every document worldwide. `down`/`up` change depth; `next`/`prev` change the last index within one bunch.

A cursor is a path plus a buffer-cell position when needed. Insertion/deletion affects the relevant sibling level rather than readdressing every subsequent file byte. A document is a root, placement tree and mark overlay; a file is one way to serialize pages. Human names, realms, volumes and chapters are attributes/profile conventions, not DNS or a fixed number of levels.

Carriers can be RAM, disk, wire, radio or removable storage; Internet and HTTP are optional. A Message may carry a short address, authority and consumer information instead of an entire large body. The consumer reads needed parts by cursor. Content typing follows the LMX value and [admission](#admission), not its Mix address, MIME or filename extension.

Sorting services are placed outside an individual application, at WorldWideMix nodes corresponding to the placement tree and the routes between its parts. They may accumulate, batch and distribute letters by destination where carrier latency makes that processing useful. This is not a second local-mail circuit and is not a mandatory intermediary between L3 Threads in one process: the local mail collection retains its base FIFO contract. A sorter's buffer capacity, overflow policy and direct-send policy belong to a particular transport profile rather than to L3 semantics.

The Mix overlay places intersecting marks, cursors, attributes and intervals on the same positions. Page-value composition uses ordinary [merge](#composition) with first `[0]` occurrence, not neighbour-address overriding. Disk exhaustion does not authorize automatically spilling data to an arbitrary neighbour: refusal, compaction or an explicitly authorized mirror belongs to storage policy.

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

[EN]
Credentials, verifiers, authority and evidence are explicit values in Message flow, not a global role hierarchy. A protected verifier checks a primary credential without retaining its original secret. A cryptographic result is a fact for policy, not automatic authority for every action.

A module, service, archive, directory or administrative operation may have its own verifier realm. A contract may require one verifier, several for one user, or a user/session quorum. Creator/child relationships establish lifecycle management, not content-reading rights. Resetting an access verifier does not recover content encrypted using a key derived from the former credential.

The initial username and empty password permitted by an earlier installation profile are explicit installation state, not universal security policy or permission for external input to bypass admission. A user or administrator may replace the verifier. A concrete first-run policy must be represented separately.

After primary-credential confirmation, policy may issue a delegated module/service ticket with permitted operations and expiry. Changing/resetting the primary verifier invalidates dependent tickets under explicit policy. OAuth and OS login are pluggable modules; they neither automatically replace the chosen verifier nor gain authority from language level L2/L3.

AuthEvidence may explicitly contain user, verifier realm, ticket, permitted actions and quorum satisfaction. It is data with dependencies and lifetime. The receiving expression checks required properties in its unit tests under [unified admission](#admission). A password match or valid signature creates no implicit roles, name bindings or indefinite admission.

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

@@ crypto-values | Криптографические значения и провайдеры | Cryptographic values and providers | 19.32.10–19.32.12; 19.32.14–19.32.17
[RU]
L3 выражает криптографическое намерение, связи ключей, политику и состояние протокола. Провайдер реализует примитивы, защищённое хранение и платформенный интерфейс. Приведённые названия обозначают семантические роли контрактов; конкретный профиль связывает их с receiver и структурой типов. Провайдер выбирается явно по профилю, ссылке, capability, конфигурации или сервису.

AlgorithmId содержит семейство, алгоритм, версию/профиль и существенные параметры. Параметры, влияющие на совместимость байтов протокола, явно заданы либо фиксированы именованным профилем. Подмена алгоритма и скрытый downgrade запрещены. Отсутствующий статически обязательный провайдер вызывает ошибку сборки/связывания; неподдержанный динамический выбор — явный отказ операции.

PublicKey — обычные несекретные данные с алгоритмом, форматом и байтами ключа, необязательными id/метаданными. Их можно копировать, хранить и передавать. Raw, SPKI, JWK и иные кодирования являются явным выбором; внутренний объект провайдера не является форматом обмена.

KeyRef — непрозрачное полномочие на секретный ключ с контрактом владельца-провайдера, операций, срока жизни и экспорта. Это не сырой L2-адрес и не обязательный массив секретных байтов. KeyPair объединяет PublicKey и private KeyRef. Генерация не публикует приватный материал в граф автоматически; неэкспортируемый ключ — допустимая реализация.

Verifier явно обозначает алгоритм, формат/версию, salt и параметры проверки: стоимость памяти, времени/итераций и параллелизма, а также результат или каноническое кодирование. KeyPolicy может задавать использование, сроки, ротацию, отзыв, версии, связь с объектом, экспорт и получателей; точную структуру политики определяет выбранный профиль.

Передача KeyRef, возврат, сохранение в поле, композиция и смена провайдера не экспортируют секрет. Контракт определяет локальное использование разными Message, retain/transfer и допустимость сериализации. Переносимый исходный вариант — локальность провайдеру/runtime и отсутствие wire-сериализации. Передача секрета на другую машину требует явного разрешённого export/import или защищённого конверта.

Защищённая память — набор отдельных возможностей: контролируемое секретное хранилище, очистка, page locking, guard pages, неэкспортируемость, аппаратная защита. Одна не подразумевает остальные. Нельзя обещать удаление копий, которыми провайдер не владеет, в UI, VM или host. Синхронный вызов, сервисное сообщение и асинхронный адаптер могут реализовать один контракт, не вводя нового общего планировщика или готового `await` языка.
[EN]
L3 expresses cryptographic intent, key relationships, policy and protocol state. A provider implements primitives, secure storage and platform interfaces. The names below denote semantic contract roles; a concrete profile binds them to receivers and a type structure. Providers are explicitly selected by profile, reference, capability, configuration or service.

AlgorithmId contains family, algorithm, version/profile and relevant parameters. Parameters affecting interoperable protocol bytes are explicit or fixed by a named profile. Algorithm substitution and silent downgrade are prohibited. Missing statically required providers fail build/link; unsupported dynamic selection fails explicitly at the operation.

PublicKey is ordinary non-secret data with algorithm, format and key bytes, optionally id/metadata. It may be copied, stored and transmitted. Raw, SPKI, JWK and other encodings are explicit choices; a provider's internal object is not a wire format.

KeyRef is an opaque secret-key capability with a contract covering owning provider, operations, lifetime and export. It is neither a raw L2 address nor necessarily an Array of secret bytes. KeyPair combines PublicKey and private KeyRef. Generation does not automatically publish private material into the graph; non-extractable keys are valid implementations.

A Verifier explicitly identifies algorithm, format/version, salt and verification parameters: memory cost, time/iteration cost, parallelism and result or canonical encoding. KeyPolicy may define uses, expiry, rotation, revocation, versions, object association, export and recipients; the selected profile defines its exact Structure.

Passing KeyRef, returning it, storing it in a field, composition and provider changes do not export the secret. Its contract defines local multi-Message use, retain/transfer and serializability. The portable default is provider/runtime locality without wire serialization. Sending a secret to another machine requires explicit permitted export/import or a protected envelope.

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
