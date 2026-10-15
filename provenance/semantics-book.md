@@ scope | Предмет языка и способы исполнения | Language scope and execution modes | 0; 0.0; 0.0.1; 0.0.3; 0.1.1; 1; 1.7
[RU]
При статической компиляции каждое тело Structure, явно исполняемое или предназначенное для исполнения, получает нативную реализацию, включая корневое тело файла. Корень не имеет отдельного правила генерации или вызова: выбор между нативным входом и интерпретатором определяется только наличием нативной реализации у вызываемого вхождения Structure. Построенная во время исполнения Structure без неё остаётся интерпретируемой, если её тело принадлежит L3.

LMX одновременно представляет данные, исполняемые выражения, модели, запросы и сообщения. Исходная запись строит структуры; принимающее выражение задаёт их смысл. Записи, деревья, конфигурации, схемы, таблицы и программные тела используют одну структурную основу. Реестр, сервис, таблица и Mix — семейства данных и принимающих выражений, а не дополнительные уровни языка.

Все правила языка универсальны в пределах своей объявленной области и применяются одинаково ко всем подходящим конструкциям. Имя, тип, форма записи, уровень вложенности, путь трансляции или удобство реализации не создают неявного исключения. Если реализация требует исключения либо исследование обнаруживает противоречие между правилами, это останавливает соответствующее решение до явного обсуждения; транслятор, интерпретатор и runtime не вправе самостоятельно вводить обходную семантику.

L3 сохраняет изменение графа, структурные вызовы, таблицы, сообщения и локальные акторы. Низкоуровневые адресные операции, необработанный доступ к памяти, вызовы сырых машинных интерфейсов и явная низкоуровневая синхронизация относятся к [L2](L2_spec_ru.md). Различие уровней не устанавливает само по себе чистоту вычисления, полномочия пользователя или отдельную систему безопасности.

Расширение файла выбирает внешний профиль: `.lm1` — прямое понижение L1, `.lm2` — L2, `.lm3` — L3. `.lm4` и `.lm5` не задают действующих профилей. Файл сам является Structure: его корневое тело — L3-Structure, исполняемая с начала в любом профиле, в том числе в `.lm2` — в интерпретируемом теле нет L2-операций, потому что интерпретатор исполняет только L3; функции `main` нет. L3 компилируется по тем же правилам, что и L2; различие одно: построенный граф L3 *может* исполняться интерпретатором, L2-операции — нет. Заполненное слово `native` выбирает нативное исполнение, пустое — интерпретатор, и он исполняет только L3. Правило «нативное исполнение только внутри методов» снято. Режимов «интерпретация / нативное исполнение» у потока нет — единственный переключатель: дескриптор вызываемого вхождения с нативным адресом исполняется нативно, без адреса — интерпретируется. Значение исполнения файла (код завершения) — значение последнего вычисленного выражения корневого тела; корень, как всякая callable-Structure, значения не объявляет, и `return` в нём только голый. Профиль сервиса может выбрать явную функцию, `start`, обработчик или отправку сообщения. Точка входа получает управление после подготовки окружения и графа исполнения.

Модель допускает интерпретацию построенного графа L3 и трансляцию с сохранением той же семантики. Интерпретатор исполняет только L3: не исходный текст, не L1/L2 и не операции `c.*`. Реализация самого интерпретатора не расширяет язык интерпретируемой программы. L2 задаёт машинные механизмы, L3 — высокоуровневые программы, а L1 служит промежуточной стадией понижения к C99. Парсер, интерпретатор графа и транслятор имеют разные задачи. Грамматические формы, границы тел, литералы, комментарии и нормализация определены в [спецификации грамматики](LMX_grammar.ru.md).

Уровни соотносятся как множества: L3 — подмножество L2. Именованная Structure и безымянная Structure всегда принадлежат уровню L3; операции L2, требующие машинного адреса, адресной арифметики, сырой памяти или `c.*`, отсутствуют в интерпретируемом теле, потому что интерпретатор исполняет только L3; в откомпилированном теле они могут стоять. Запись `@` любой глубины допустима в L3 как receiver объявления ссылки и как операция получения ссылки на разрешённое значение, если она не требует вычисления или изменения машинного адреса. Машинные операции над адресом остаются в L2. Поэтому граф Structure, построенный из любого профиля, пригоден интерпретатору L3, а тело метода может требовать нативного понижения.

<a id="l3-receiver"></a>
### Принимающее выражение L3

Принимающее выражение L3 задаёт контракт потребления построенного графа как программы L3. Оно определяет поддерживаемое подмножество и точку входа выбранного профиля; наличие синтаксического дерева само по себе не устанавливает допустимость программы. Неподдерживаемая операция не становится допустимой из-за наличия машинного адреса реализации. Ограниченный профиль исполнения должен явно сообщать о неподдерживаемой конструкции, а не молча пропускать её или исполнять как L2. Это ограничение профиля не отменяет [единого механизма допуска кандидатов](#admission).

Исполнение следует разрешённым ссылкам и позициям бинарного графа, а не исходным именам; таблица адресов и имён служит только трансляции и `toLmx` и не участвует в выполнении ни при каких условиях, см. [имена и пути](#fields). Высокоуровневая операция может иметь явно выбранную машинную реализацию с L3-контрактом, как описано в [границе числовых и машинных операций](#mathematics); это не разрешает произвольный вызов `c.*` из интерпретируемой программы.

Представление исполняемого графа в первую очередь использует физические ссылки. Числовой код применяется только там, где физическую ссылку сохранить или передать невозможно; после разрешения такого кода дальнейшее исполнение снова следует полученной ссылке. Текстовые имена не участвуют в распознавании операций, выборе принимающего выражения или диспетчеризации. Внутренний числовой тег реализации допустим как локальная оптимизация интерпретатора, но сам по себе не устанавливает смысл узла L3.

Простейшая программа скриптового профиля:

```text
print: "Hello World"
```
[EN]
Static compilation provides a native implementation for every Structure body explicitly executed or intended for execution by the source, including the file root. The root has no separate generation or call rule: dispatch between native entry and interpreter depends only on whether the callable Structure occurrence has a native implementation. A Structure constructed at run time without one remains interpretable if its body belongs to L3.

LMX represents data, executable expressions, models, queries and messages. Source notation constructs Structures; a receiving expression assigns their meaning. Records, trees, configurations, schemas, tables and program bodies share the same structural basis. Registries, services, tables and Mix are families of data and receivers, not additional language levels.

Every language rule is universal within its declared domain and applies uniformly to every matching construct. A name, type, source spelling, nesting level, lowering path, or implementation convenience creates no implicit exception. If an implementation appears to require an exception, or investigation finds a contradiction between rules, the affected decision is suspended for explicit discussion; translator, interpreter, and runtime must not invent workaround semantics.

L3 retains graph mutation, structural calls, tables, messages and local actors. Low-level address operations, raw memory access, raw machine interfaces and explicit low-level synchronization belong to [L2](L2_spec_en.md). The level distinction does not by itself establish computational purity, user authority or a separate security system.

A file extension selects its outer profile: `.lm1` selects direct L1 lowering, `.lm2` L2, and `.lm3` L3. `.lm4` and `.lm5` do not select current profiles. The file is itself a Structure: its root body is an L3 Structure executed from the start in every profile, including `.lm2` -- an interpreted body has no L2 operations, because the interpreter executes only L3; there is no `main` function. L3 is compiled by the same rules as L2; the one difference: a constructed L3 graph *may* be executed by the interpreter, L2 operations may not. A filled `native` word selects native execution; an empty word selects the interpreter, which executes only L3. The rule that native execution is enabled only inside methods is withdrawn. A Thread has no "interpreted / native" modes -- the only switch is the callable occurrence's descriptor: with a native address it executes natively, without one it is interpreted. The value of executing a file (its exit code) is the value of the root body's last evaluated expression; the root, like every callable Structure, declares no result, and `return` in it is bare only. A service profile may select an explicit function, `start`, a handler or a message send. The entry point receives control after its environment and runtime graph are prepared.

The model supports interpretation of the constructed L3 graph and translation preserving the same semantics. The interpreter executes L3 only: not source text, L1/L2 or `c.*` operations. The interpreter's implementation does not expand the language of the interpreted program. L2 defines machine mechanisms, L3 defines high-level programs, and L1 is an intermediate lowering stage toward C99. The parser, graph interpreter and translator serve different purposes. Grammatical forms, body boundaries, literals, comments and normalization are defined in the [grammar specification](LMX_grammar.en.md).

The levels relate as sets: L3 is a subset of L2. A named Structure and an anonymous Structure always belong to level L3; L2 operations requiring a machine address, address arithmetic, raw memory or `c.*` are absent from an interpreted body, because the interpreter executes only L3; a compiled body may contain them. The `@` spelling of any depth is admissible in L3 both as a reference-declaration receiver and as an operation obtaining a reference to a resolved value, provided it neither computes nor changes a machine address. Machine operations on addresses remain in L2. Hence a Structure graph built from any profile is admissible to the L3 interpreter, while a method body may require native lowering.

<a id="l3-receiver"></a>
### L3 receiving expression

The L3 receiving expression defines the contract for consuming a constructed graph as an L3 program. It determines the supported subset and the selected profile's entry point; the mere presence of a syntax tree does not establish program admissibility. An unsupported operation does not become admissible because a machine implementation address exists. A restricted execution profile must explicitly report an unsupported construct rather than silently skip it or execute it as L2. This profile restriction does not replace the [single candidate-admission mechanism](#admission).

Execution follows resolved references and positions in the binary graph, not source names; the address-to-name table serves translation and `toLmx` only and takes no part in execution under any conditions, as specified under [names and paths](#fields). A high-level operation may have an explicitly selected machine implementation with an L3 contract, as described at the [numeric/machine-operation boundary](#mathematics); this does not authorize arbitrary `c.*` calls from the interpreted program.

The executable graph representation uses physical references wherever possible. A numeric code is used only where a physical reference cannot be retained or transported; after such a code is resolved, subsequent execution again follows the resulting reference. Textual names do not participate in operation recognition, receiving-expression selection, or dispatch. An internal numeric implementation tag may be used as a local interpreter optimization, but it does not by itself establish the meaning of an L3 node.

The simplest script-profile program is:

```text
print: "Hello World"
```
@@ values | Значения, структуры и массивы | Values, Structures and Arrays | 2; 2.2.1; 2.2.2.6-7; 3.1-3.3; 12.1
[RU]
Структура — упорядоченная совокупность непосредственных полей. Поля содержат ссылки на значения: примитивные ячейки, другие структуры, массивы и записи методов. Лексическая вложенность образует лес; дополнительные ссылки соединяют его в граф с общими объектами и циклами. Примитивная ячейка не получает отдельную структуру-обёртку только потому, что на неё ссылается поле.

Массив содержит элементы одного типа. Его длина относится к элементам массива, а число полей структуры — к непосредственным полям структуры. Массив ссылок на массивы и прямоугольный многомерный массив — разные значения. Вложенность `a: b: c: d: ...` является общей формой применения принимающих выражений и не имеет фиксированного предела глубины. `[]: []:` — применения обычного ресивера Array в этой общей форме, не отдельная конструкция или особый тип «массив массивов». Элемент Array может быть примитивом или ссылкой на непримитивное значение по общим правилам хранения; у каждого самостоятельного массива свой дескриптор и своя длина. Си-подобная голова `[][][]` задаёт ровный многомерный массив и не относится к композиции отдельных ресиверов `[]:`. Размерность из дескриптора не восстанавливается. Промежуточный массив можно связать с именем обычным типизированным связыванием: для `[]: []: []: a` шаги `[]: []: b a[i]` и `[]: c: b[j]` используют по одному индексированию самостоятельного массива, без копирования непримитивного значения. Прямой доступ через несколько дескрипторов использует обычный путь `a[i]\[j]\[k]` ([пути](#fields)), а не соседние индексы ровного массива. Например, `char: []: []: mainArgs` использует ту же общую вложенность для массива строк: каждая строка — самостоятельный массив `char` с точной длиной `len` без завершающего NUL (`LmxCharArray`, [L2 §5](L2_spec_ru.md#method-array)); NUL — форма двери `c.*`, не значения в графе. Детали представления и классификации ячеек по диапазонам адресов определены в [L2](L2_spec_ru.md#type-by-range).

Пустая структура — присутствующее значение с нулём полей. Она отличается от отсутствующего поля, числового нуля и `void`, означающего отсутствие содержимого примитивной ячейки. Список аргументов Frame сам является Structure; единственная анонимная Structure на месте всего списка прозрачна уже при нормализации P0: её поля становятся полями списка, независимо от головы и от того, пустая она или нет. Поэтому `f()`, `f: ()` и явно закрытое пустое вертикальное тело дают одно дерево с пустым телом; `f(a b)` и `f: (a b)` также дают один список. Анонимная Structure среди других полей или в именованной позиции остаётся отдельным значением. Для передачи пустой Structure как одного значения нужна такая непрозрачная позиция; см. [пустое тело](LMX_grammar.ru.md#empty-colon).

`None` — контекстное значение: его представление задаёт ожидаемый тип принимающего выражения. Единого кодирования для всех типов нет; тип без соответствующего определения `None` его не принимает. Число `0` остаётся нулём, в логических операциях — ложью, и не является общим признаком отсутствия. В прежнем профиле `Boolean` использует диапазон −1…1: `None = −1`, ложь — 0, истина — 1. Это конкретное определение профиля, а не универсальное кодирование всех отсутствующих значений.

Текст, изображение, десятичная запись и машинное слово до распознавания принимающим выражением являются исходным хранилищем данных. После разбора или декодирования они представлены значениями того же графа. Имена форматов и численных библиотек не вводят дополнительные фундаментальные виды значений.
[EN]
A Structure is an ordered collection of direct fields. Fields hold references to values: primitive cells, other Structures, Arrays and method records. Lexical nesting forms a forest; additional references connect it into a graph containing shared objects and cycles. A primitive cell does not acquire a Structure wrapper merely because a field references it.

An Array contains elements of one type. Its length counts Array elements, while a Structure's field count counts its direct fields. An Array of references to Arrays differs from a rectangular multidimensional Array. Nesting `a: b: c: d: ...` is the general form of receiving-expression application and has no fixed depth limit. `[]: []:` applies the ordinary Array receiver through that general form; it is not a separate construct or a special array-of-arrays type. An Array element may be a primitive or a reference to a nonprimitive value under the ordinary storage rules; each independent Array has its own descriptor and length. The C-like head `[][][]` denotes a flat rectangular multidimensional Array and is unrelated to composing separate `[]:` receivers. Dimensionality is not recovered from the descriptor. An intermediate Array can be bound to a name through ordinary typed binding: for `[]: []: []: a`, the steps `[]: []: b a[i]` and `[]: c: b[j]` each index one independent Array without copying a nonprimitive value. Direct access through multiple descriptors uses the ordinary path `a[i]\[j]\[k]` ([paths](#fields)), not adjacent indices of a flat Array. For example, `char: []: []: mainArgs` uses the same general nesting for an Array of strings: each string is an independent `char` Array of exact length `len` without a trailing NUL (`LmxCharArray`, [L2 §5](L2_spec_en.md#method-array)); NUL belongs to the `c.*` door representation, not the graph value. Representation and address-range cell classification are specified in [L2](L2_spec_en.md#type-by-range).

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
@@ fields | Имена и пути | Names and paths | 2.3; 13.1; 14.1; 21.1-2; 21.11
[RU]
Имена разрешают исходные обращения; исполнение следует полученным ссылкам и позициям. Имена исходных сущностей не хранятся в графе вообще: ни при атомах, ни при Structure, полях, методах или применениях. Отдельная таблица соответствия «адрес → исходное имя» позволяет восстанавливать имена при выводе исходника и инструментальном просмотре; это не таблица связывания переменных, не тип и не идентификатор исполнения. Она служит только трансляции и `toLmx`; исполнение не обращается к ней ни при каких условиях: конструирование, копирование и вызов, включая формирование входов вызова, идут по ссылкам, адресам и позициям, разрешённым при трансляции. Анонимные и позиционные значения не нуждаются в синтетических именах. Физическое хранение дерева определено в [L2 §2.1](L2_spec_ru.md#interpretable-tree); восстановление исходника — в [контракте toLmx](#source-codec).

Структурный путь `object\field\nested` последовательно выбирает поля графа. Наличие каждого перехода и его допустимость определяются выбранным объектом. Вычисляемый путь не заменяется выдуманным статически известным именем. Зарезервированный `node` обозначает лексическое пространство над методом и остаётся одним и тем же во всей его активации; `node\field` начинает явный обход из этого пространства. Голое `field`, полученное по лексическому fallback, передаётся как скрытый аргумент текущей активации и не тождественно явному пути `node\field`.

Путь может содержать безымянный индексный шаг `a\[i]`, выбирающий элемент типизированного Array. `a[i][j]` адресует ровный многомерный массив, тогда как `a[i]\[j]` индексирует отдельный Array, полученный через значение элемента `a[i]`; цепочка `a[i]\[j]\[k]` следует последующим ссылкам. Индексный шаг может сочетаться с полями Structure и иметь произвольную конечную глубину. Именованный селектор вхождения вида `node\[N]field` не существует: на одном структурном уровне нет повторных объявлений имени.

`node` — зарезервированное слово языка. Его нельзя объявить, затенить, перепривязать или передать как динамическое одноимённое значение, в том числе посредством цитированного написания имени. При понижении это буквально обязательный первый параметр `Lmx *node` (на L1 — `@: Lmx node`): физическая ссылка на лексическое пространство над выбранным методом. Wrapper, closure или объект namespace между исходным `node` и этим адресом не вставляется. В рабочем графе каждое вызываемое вхождение, тело `if`, цикл и другая вложенная Structure отдельно хранит обычную ссылку `parent` на непосредственно объемлющую Structure. Для вызываемого вхождения эта ссылка задаёт над-методное пространство, передаваемое как `node`; ссылки `parent` вложенных тел могут вести по произвольной внутренней цепочке, но не меняют параметр `node` текущей активации. `parent` не является зарезервированным словом или доступным программе псевдонимом: это поле реализации, по которому работают лексическая и динамическая видимость. Голый `field`, пришедший скрытым аргументом, локален по отношению к вызывающему выражению и над-методному пространству. Присваивание `field: value` такому имени обновляет это локальное значение и поля не создаёт — ни при исполнении, ни заранее транслятором; в источник скрытого аргумента запись не идёт, и состояния метода из этого не возникает ([рабочее состояние](#dynamic)). Поле есть только там, где его ставит объявление; объявленное own-поле идёт через рабочую копию и публикацию. Для явного изменения над-методного графа программа пишет `node\field: value`.

| Имя | Где существует | Значение |
| --- | --- | --- |
| `node` | зарезервированное слово L3 и первый ABI-параметр метода | пространство над методом; неизменно для всей активации, включая вложенные тела |
| `parent` | обычное поле каждой `Lmx` Structure рабочего графа | непосредственно объемлющая Structure; различается у метода, `if`, цикла и других вложенных тел |
| `self` | только скрытый ABI-контекст | активная Structure текущего вызова; не слово языка |

Исполнение удерживает физическую ссылку на активную Structure (§12). Это скрытый ABI-контекст, а не новое исходное имя `self`, не второй граф данных и не замена зарезервированного `node`.

В одной непосредственно объемлющей Structure действует одно пространство имён и одно поле для каждого имени. Первое определение места создаёт поле, а повторное обращение к тому же месту присваивает после проверки контракта, не создавая второе одноимённое поле. Это общее правило действует для примитивов, ссылок и обычных Structure; голова места и ресивер значения компонуются по [единой модели](#resolved-head-consumption). Вложенная Structure может затенить внешнее имя; поля метода размещаются в его явной части `var` по [правилу вызываемого](#method-parts). `merge` с одноимёнными полями разных операндов записывает значение в слот модели по [правилу композиции](#composition). Именованный путь выбирает единственное поле соответствующего уровня, в том числе через [допущенную ссылку](#admission); физический номер этого поля в модели и кандидате может различаться.

Число и расположение полей структуры фиксируются при создании. Порядок полей графа строго лексический; порядок выдачи нативного кода не разрешает переставлять поля самого графа. Обновление существующего поля заменяет содержащуюся в нём ссылку; оно не добавляет новое вхождение. Для иного набора полей создаётся новая структура. Операции над массивом следуют собственному контракту и не изменяют это правило структуры.
[EN]
Names resolve source-level accesses; execution follows the resulting references and positions. Source-entity names are not stored anywhere in the graph: not on atoms, Structures, fields, methods or applications. A separate address-to-source-name table reconstructs names for source output and inspection; it is not a variable-binding table, a type or an execution identifier. It serves translation and `toLmx` only; execution never consults it, under any conditions: construction, copying and calls, including the formation of a call's inputs, follow the references, addresses and positions resolved at translation. Anonymous and positional values need no synthetic names. Physical tree storage is defined in [L2 §2.1](L2_spec_en.md#interpretable-tree); source reconstruction is defined by the [toLmx contract](#source-codec).

A structural path `object\field\nested` selects graph fields in sequence. Each step's presence and validity are determined by the selected object. A computed path is not replaced by an invented statically known name. Reserved `node` denotes the lexical space above the method and stays fixed throughout that method activation; `node\field` starts explicit traversal in that space. A bare `field` obtained by lexical fallback is supplied as a hidden argument of the current activation and is not identical to the explicit `node\field` path.

A path may contain an unnamed index step `a\[i]` selecting a typed Array element. `a[i][j]` addresses a rectangular multidimensional Array, whereas `a[i]\[j]` indexes a separate Array obtained through the value of `a[i]`; `a[i]\[j]\[k]` follows further references. Index steps may be mixed with Structure fields to any finite depth. A named occurrence selector such as `node\[N]field` does not exist: a structural level has no repeated declarations of one name.

`node` is a reserved language word. It cannot be declared, shadowed, rebound or dynamically supplied as a same-named value, including by quoted identifier spelling. In lowering it is literally the mandatory first `Lmx *node` parameter (`@: Lmx node` in L1): the physical reference to the lexical space above the selected method. No wrapper, closure or namespace object is inserted between source `node` and that address. In the working graph every callable occurrence, `if` body, loop and other nested Structure separately holds an ordinary `parent` link to its immediately enclosing Structure. For a callable occurrence that link supplies the above-method space passed as `node`; nested bodies may have an arbitrary internal `parent` chain, but that chain never rebinds the activation's `node` parameter. `parent` is neither a reserved language word nor a program-visible alias: it is an implementation field traversed by lexical and dynamic visibility. A bare `field` supplied as a hidden argument is local with respect to the caller and the above-method space. Assigning that name (`field: value`) updates this local value and creates no field, neither during execution nor by the translator preallocating one; nothing is written into the hidden argument's source, and no method state arises from it ([working state](#dynamic)). A field exists only where a declaration puts it; a declared own field goes through the working copy and publication. Mutating the above-method graph requires explicit `node\field: value`.

| Name | Where it exists | Meaning |
| --- | --- | --- |
| `node` | reserved L3 word and first method ABI parameter | space above the method; fixed for the whole activation, including nested bodies |
| `parent` | ordinary field of every working-graph `Lmx` Structure | immediately enclosing Structure; differs for a method, `if`, loop and other nested bodies |
| `self` | hidden ABI context only | the active Structure of this call; not a language word |

One immediately enclosing Structure has one namespace and one field per name. The first definition of a place creates its field; a later use of the same place assigns after contract checking instead of creating a second same-named field. This general rule applies to primitives, references, and ordinary Structures; the place's head and value receiver compose under the [single model](#resolved-head-consumption). A nested Structure may shadow an outer name; method fields reside in its explicit `var` part under the [callable rule](#method-parts). `merge` of fields with the same name in different operands writes into the model's slot under the [composition rule](#composition). A named path selects the sole field at that level, including through an [admitted reference](#admission); its physical position may differ between model and candidate.

A Structure's field count and positions are fixed at construction. Graph fields follow strictly lexical order; native-code emission order does not authorize rearranging the graph's fields. Updating an existing field replaces its stored reference; it does not append an occurrence. A different set of fields requires a new Structure. Array operations follow their own contracts and do not change this Structure rule.

Execution retains the physical reference to the active Structure (§12). This is hidden ABI context, not a new source name `self`, a second data graph or a replacement for reserved `node`.
@@ descriptions | Явные описания значений и преобразования | Explicit value descriptions and conversions | 2.2.2-2.2.4; 2.4; 9.1; 9.1.1; 9.2
[RU]
Описание значения — обычная явно доступная структура. Принимающее выражение получает его через аргумент или ссылку. Описание не прикрепляется скрыто к каждому примитиву и не нужно для определения физического типа по адресу. Названия `class`, `class.range` и подобных таблиц обозначают данные конкретного профиля, а не обязательные глобальные сущности языка.

Таблица преобразований задаёт соответствия примитивных значений и их описаний, а не всех пар Structure или их имён. Разные структуры `A` и `B` имеют общее физическое представление `Lmx` в типизированных массивах арены ([L2 §3](L2_spec_ru.md#type-by-range)); имя и состав полей не создают отдельный физический тип или массив из одного элемента. Структурная пригодность `B` требованию `A` определяется `implements` относительно Consumer, не строкой конверсии `B → A`. Получение или перенос ссылки на Structure также не требует отдельного конвертера для каждой модели. Общность физического представления не отменяет структурный допуск, квалификации и различие ссылки на Structure со ссылкой на ссылочную ячейку.

Описание разделяет семантический контракт и архитектурное представление. Контракт задаёт смысл: счётное число, целое, рациональное, число с выбранной точностью, комплексное, атом, адрес, непрозрачный ресурс или отсутствие содержимого. Представление задаёт ширину, знаковость, диапазон и обозначение целевого типа. Одинаковое представление не делает контракты одинаковыми: `Boolean` и `int8` могут храниться одинаково, но иметь разные допустимые значения.

Обычные поля описания включают `cell`, `semantic`, признаки `numeric`/`integer`/`floating`/`reference`/`opaque`, `width`, `signed`, `range`, `spelling` и ключи преобразований `convert`. Имена полей выбирает профиль. Указание диапазона является данными контракта; его выполнение проверяется [единым механизмом допуска](#admission), а не самим наличием поля.

Численная цепочка контрактов: флаг → неотрицательное целое → целое → рациональное → число с точностью профиля → комплексное. Неотрицательные целые включают ноль. Машинное `double` не является множеством всех вещественных чисел. Атомы, адреса и непрозрачные ресурсы — отдельные контракты, не ступени этой численной цепочки. `unit` — пустая структура; `void` — отсутствие содержимого ячейки.

Описания составляются обычным `merge` с общим правилом [порядка вхождений](#fields). Поля `width`, `range` или `spelling` не создают автоматически арифметические методы. Такие операции задаются вызываемыми выражениями. Пример `u32` сочетает неотрицательный целочисленный контракт, 32-битное представление и диапазон 0…4294967295; `FILE` описывает непрозрачную идентичность ресурса. Слово `FILE` само по себе не доказывает возможность чтения или закрытия: такие требования выражаются путями структуры `File`.

Преобразователь — явно выбранное принимающее выражение. Его ключ поступает из явных описаний и их композиции; скрытого перебора пар нет. Аналитическая проверка не исполняет преобразователь, а требующее преобразования действие выполняет выбранный вызов. Повторная запись ключа в одной Structure присваивает уже объявленному полю после проверки контракта, не создавая второе поле; композиция также записывает одноимённый ключ позднего операнда в слот модели. Если таблица содержит несколько строк с одним ключом, выбор строки задаёт её собственная политика ([таблицы](#registries)).

Численное преобразование сохраняет контракт диапазона назначения: `u16(255) → u8` допустимо при наличии преобразователя, `u16(256) → u8` даёт ошибку диапазона, а не ноль. Округление `1.5 → i32` и потеря точности внутри диапазона требуют отдельного правила численного профиля. Доказанная включённость диапазонов может исключать избыточную машинную операцию, сохраняя семантическое требование. Ошибки формата, диапазона и поведения преобразователя не заменяются положительным ответом `implements`.
[EN]
A value description is an ordinary explicitly accessible Structure. A receiving expression obtains it through an argument or reference. It is not secretly attached to every primitive and is unnecessary for determining a physical type from an address. Names such as `class` and `class.range` denote a particular profile's data, not mandatory global language entities.

The conversion table defines relations between primitive values and their descriptions, not between every pair of Structures or their names. Distinct Structures `A` and `B` share the physical `Lmx` representation in the arena's typed arrays ([L2 §3](L2_spec_en.md#type-by-range)); a name or field composition creates neither a separate physical type nor a one-element array. Whether `B` satisfies requirement `A` is determined by `implements` relative to the Consumer, not by a `B → A` conversion row. Obtaining or transferring a Structure reference likewise requires no converter for each model. Shared physical representation does not remove structural admission, qualifications, or the distinction between a Structure reference and a reference to a reference cell.

A description separates its semantic contract from architecture binding. The contract defines meaning: count, integer, rational, profile-precision number, complex value, atom, address, opaque resource or absence of content. The binding defines width, signedness, range and target spelling. Equal representation does not imply equal contracts: `Boolean` and `int8` may share storage while admitting different values.

Ordinary description fields include `cell`, `semantic`, flags such as `numeric`/`integer`/`floating`/`reference`/`opaque`, `width`, `signed`, `range`, `spelling` and `convert` keys. The profile chooses field names. A range declaration is contract data; satisfaction is established through the [single admission mechanism](#admission), not by the field's presence alone.

The numeric contract chain is flag → nonnegative integer → integer → rational → profile-precision number → complex number. Nonnegative integers include zero. Machine `double` is not the set of all real numbers. Atoms, addresses and opaque resources are separate contracts, not rungs of this numeric chain. `unit` is an empty Structure; `void` denotes no cell content.

Descriptions are composed with ordinary `merge` under the common [occurrence-order rule](#fields). Fields such as `width`, `range` or `spelling` do not automatically create arithmetic methods. Such operations are callable expressions. For example, `u32` combines a nonnegative integer contract, 32-bit representation and range 0…4294967295; `FILE` describes opaque resource identity. A `FILE` word alone does not establish that reading or closing is valid: such requirements are expressed through paths of a `File` Structure.

A converter is an explicitly selected receiving expression. Its key comes from explicit descriptions and their composition; there is no hidden search over pairs. Analytical checking does not run the converter; an action requiring conversion performs the selected call. A repeated key form in one Structure assigns to its existing field after contract checking without creating a second field; composition likewise writes a later operand's same-name key into the model's slot. If a table has several rows with one key, the table operation's own policy selects the row ([tables](#registries)).

Numeric conversion preserves the destination-range contract: `u16(255) → u8` is admitted when the converter exists, while `u16(256) → u8` produces a range error, not zero. Rounding `1.5 → i32` and in-range precision loss require explicit numeric-profile rules. Proven range inclusion may eliminate a redundant machine operation while preserving the semantic requirement. Format, range and converter-behavior failures are not replaced by a positive `implements` result.
@@ conversion-context | Привязки типов и контекст преобразований на уровне Message | Message-local type bindings and conversion context | 2.2.3; 2.2.4; 7; 19.16
[RU]
У каждого исполняющегося Message один контекст описаний типов, их символических привязок и преобразований. Он состоит из обычных Structure и ссылок, явно переданных при построении Message или достижимых из них. Создание, отправка и родство Message сами по себе не передают контекст родителя. Встроенного процесс-глобального реестра, неявного окружения типов и скрытого поиска преобразователей нет.

### Устойчивые привязки и структурная общность

Символическое имя типа связывается один раз для Message и одинаково разрешается во всех его употреблениях, включая аргументы и результаты; каждый вызов не инстанцирует его заново. Другой Message может связать то же имя иначе. Это отношение внутри контекста, а не дополнительное пространство runtime-имён.

Структурная обобщённость — обычный случай [допуска](#admission): Consumer требует только используемые пути, операции и контракты. Отдельный generic-шаблон не нужен. Символическая привязка требуется, когда несколько позиций должны разделять одно устойчивое отношение типов, а не для объявления обобщённости как таковой.

### Преобразования при потреблении

Достижимая таблица преобразований касается примитивных описаний, включая явно заданные семантические величины и единицы; это не каталог совместимости Structure. Иное примитивное описание допустимо только через доступное в данном Message преобразование, разрешённое контрактом Consumer. Аналитический допуск не исполняет преобразователь. При действительном потреблении он исполняется как обычное вызываемое выражение с проверками диапазона, представления, точности и семантических условий. Успех структурной проверки не разрешает переинтерпретировать примитивное хранилище без такого преобразования.

Перед вызовом преобразованный фактический аргумент должен удовлетворять действительному дескриптору выбранного вызываемого выражения; после вызова результат отдельно приводится к требованию его Consumer. Отсутствующий в достижимом контексте преобразователь не заменяется скрытой цепочкой или поиском по процессу. Реализация вправе кэшировать разрешённые привязки и маршруты, только сохраняя результат явного разрешения.

Развёрнутые [примеры контекста Message](LMX_semantics_guide.ru.md#message-conversion-context) вынесены из нормативного текста.
[EN]
Each executing Message has one context of type descriptions, symbolic bindings, and conversions. It consists of ordinary Structures and references explicitly supplied when the Message is built or reachable from them. Message creation, sending, and parenthood do not implicitly pass the parent's context. There is no built-in process-global registry, implicit type environment, or hidden converter search.

### Stable bindings and structural genericity

A symbolic type name is bound once for a Message and resolves consistently at every use, including arguments and results; each call does not instantiate it anew. Another Message may bind the same name differently. This is a relation within the context, not another runtime name space.

Structural genericity is the ordinary case of [admission](#admission): a Consumer requires only the paths, operations, and contracts it uses. It needs no separate generic template. A symbolic binding is needed when multiple positions must share one stable type relation, not merely to declare genericity.

### Conversion at consumption

The reachable conversion table concerns primitive descriptions, including explicitly supplied semantic quantities and units; it is not a Structure-compatibility catalog. Another primitive description is admissible only through a conversion available in this Message and allowed by the Consumer's contract. Analytical admission does not execute a converter. At actual consumption it executes as an ordinary callable with checks for range, representation, precision, and semantic conditions. Structural success does not permit unchecked reinterpretation of primitive storage.

Before a call, each converted actual argument must satisfy the selected callable's actual descriptor; afterward its result is converted separately to the Consumer's requirement. A converter absent from the reachable context is not replaced by a hidden chain or process-wide search. An implementation may cache resolved bindings and routes only while preserving the result of explicit resolution.

Expanded [Message-context examples](LMX_semantics_guide.en.md#message-conversion-context) are kept outside the normative text.
@@ admission | Аналитическая проверка и валидация кандидата | Analytical checking and candidate validation | 2.1; 2.1.1-3; 2.5.1-3; 2.5.5-6; 19.21.3; 19.22; author 2026-09-20
[RU]
Допуск кандидата имеет два этапа: направленный аналитический `implements` и исполнение явно заданных проверок принимающего выражения над построенным графом. Адресная классификация определяет физический вид значения, но не заменяет допуск.

<a id="analytical-tree"></a>
### Аналитическая часть

<a id="three-argument-implements"></a>
#### `implements(aVar, bVar, Consumer)`

`aVar` — кандидат, `bVar` — описание требуемой роли, `Consumer` — конкретное принимающее выражение. При наличии Consumer анализ охватывает его известные обращения к `bVar` во всех видимых ветвях; неиспользуемые поля `bVar` не сравниваются. Без Consumer проверяется полная структурная пригодность относительно `bVar`, а не пустое множество обращений. Неизвестный вычисляемый путь не объявляется проверенным.

Для использованного пути необходимы соответствующее поле кандидата и пригодность его фактического потребления. Если Consumer явно вызывает поле, проверяются только записанные вызовы: фактические и именованные аргументы, умолчания и доступные преобразования должны удовлетворять выбранному интерфейсу и действительному дескриптору реализации; результат и объявленные выходы — требованию Consumer. Непрозрачная передача callable не проверяет будущих вызовов. Простая передача примитивного листа не доказывает его значение; содержательные свойства проверяют явные тесты.

Анализ не исполняет кандидата, Consumer, метод или преобразователь и не разворачивает все тела вызываемых методов. Он устанавливает пригодность для данного Consumer, не равенство структур и не пригодность для всякого будущего потребителя. При положительном результате каждому использованному полю модели сопоставляется физическое поле кандидата, возможно на другой позиции. Чтение, запись и взятие адреса через допущенную ссылку следуют сохранённому соответствию адресов; runtime не ищет имена ([L2 §14](L2_spec_ru.md#implements), [L1 §15](L1_spec_ru.md#implements)).

<a id="correspondence-stability"></a>
#### Сохранение установленного соответствия

Один раз установленное соответствие остаётся действующим при изменении значений. Замена ветви сначала допускает нового кандидата к прежнему принимающему месту и лишь затем записывает его; отказ оставляет старое значение. Мутация не запускает повторный прогон всех тестов и не отменяет уже установленную карту. Другой Consumer или новые требования проходят собственный допуск.

<a id="argument-compatibility-stage"></a>
Совместимость аргументов известного вызова проверяется при трансляции; при динамическом выборе — при допуске выбранного callable к данному вызову. Скомпилированный вызов с прежними требованиями не проверяет типы заново при каждом исполнении. Выполнение преобразователя и его проверок конкретного значения — отдельное действие, не повторная проверка сигнатуры.

<a id="graph-tests"></a>
### Исполнение тестов

После успешного анализа интерпретатор исполняет **все** обязательные тесты принимающего выражения над уже построенным графом. Пустой набор не считается успешной поведенческой валидацией. Без явного Consumer используются проверки, записанные в принимающем описании `bVar`, а не тесты кандидата `aVar`. Провал теста отвергает допуск; объявленные отказы идут через обычный механизм `throw`/`catch`. Проверки являются этапом допуска, а не наблюдателем каждой записи в граф.

<a id="test-receiver-contract"></a>
#### Ресивер `test:`

Внутри любой Structure `test: op checkIncrement` связывает принимаемое место `op` с обычным проверяющим выражением `checkIncrement`. Оба имени разрешаются как аргументы ресивера, а не вызываются неявно. Имя `test` зарезервировано; пользовательское имя для обычного метода может быть `mytest`. Связь принадлежит Consumer, не кандидату; несколько `test:` задают несколько обязательных проверок. Проверки вложенного Consumer не становятся автоматически проверками внешнего.

Проверяющему выражению передаётся фактический кандидат обычным аргументом. Его собственные обращения аналитически проверяются до исполнения; `@` не добавляется ради передачи Structure, уже передаваемой ссылкой. Проверка возвращает обычный `int`: 1 — успех, 0 — неуспех. Ожидаемый отказ проверяется обычным `catch`, а произвольный `throw` не считается успехом.

Исполнение проверки завершает уже начатый допуск, не начинает тот же допуск заново. Цикл незавершённых проверок не является успехом. Написанная связь и тело проверки остаются в исходном графе для `toLmx`, копирования и исполнения; отдельного каталога тестов, вспомогательного графа, runtime-таблицы имён и скрытого отключения типизации нет. Тесты вызывают методы через обычную диспетчеризацию native/обходчика и не принуждают всё исполнение к обходу.
[EN]
Candidate admission has two stages: directional analytical `implements` and execution of the receiving expression's explicitly specified checks against the constructed graph. Address classification identifies a value's physical representation but does not replace admission.

<a id="analytical-tree"></a>
### Analytical stage

<a id="three-argument-implements"></a>
#### `implements(aVar, bVar, Consumer)`

`aVar` is the candidate, `bVar` describes the required role, and `Consumer` is the concrete receiving expression. With Consumer, analysis covers its known accesses to `bVar` in every visible branch; unused fields of `bVar` are not compared. Without Consumer, full structural suitability against `bVar` is checked, not an empty access set. An unknown computed path is not reported as checked.

A used path requires a corresponding candidate field and admissibility of its actual consumption. If Consumer explicitly invokes a field, only the written calls are checked: actual and named arguments, defaults and available conversions must fit the selected interface and the implementation's actual descriptor; results and declared exits must meet Consumer's requirement. Opaque transport of a callable does not check future calls. Merely transporting a primitive leaf proves nothing about its value; explicit tests check substantive properties.

Analysis executes none of the candidate, Consumer, method or converter, and does not expand every callee body. It establishes suitability for this Consumer, not equality of Structures or suitability for every future consumer. A positive result maps each used model field to a physical candidate field, possibly at another position. Reads, writes and address-taking through the admitted reference follow the saved address correspondence; runtime performs no name lookup ([L2 §14](L2_spec_en.md#implements), [L1 §15](L1_spec_en.md#implements)).

<a id="correspondence-stability"></a>
#### Preservation of established correspondence

An established correspondence persists as values change. Branch replacement admits the new candidate to the same receiving place before storing it; refusal preserves the old value. Mutation neither reruns all tests nor invalidates the established map. Another Consumer or new requirements undergo their own admission.

<a id="argument-compatibility-stage"></a>
Known-call argument compatibility is checked during translation; dynamically selected callables are admitted to that call when selected. A compiled call under unchanged requirements does not recheck types on every execution. Running a converter and its concrete-value checks is separate from repeating signature compatibility checking.

<a id="graph-tests"></a>
### Test execution

After successful analysis the interpreter executes **all** required tests of the receiving expression against the already constructed graph. An empty test set is not successful behavioral validation. Without explicit Consumer, checks specified in the receiving description `bVar` are used, not tests owned by candidate `aVar`. A failed test rejects admission; declared failures use ordinary `throw`/`catch`. Checks are an admission stage, not a watcher on every graph write.

<a id="test-receiver-contract"></a>
#### The `test:` receiver

Inside any Structure, `test: op checkIncrement` associates receiving place `op` with ordinary checking expression `checkIncrement`. Both names resolve as receiver arguments, not implicit calls. The name `test` is reserved; an ordinary user method may be called `mytest`. The association belongs to Consumer, not the candidate; multiple `test:` forms require multiple checks. A nested Consumer's checks are not automatically promoted to its outer Consumer.

The actual candidate is supplied to the checker as an ordinary argument. The checker's own accesses undergo analytical checking before execution; no `@` is added merely to transport a Structure, which already travels by reference. A checker returns an ordinary `int`: 1 for success, 0 for failure. An expected failure uses ordinary `catch`; an arbitrary `throw` is not success.

Running a check completes admission already in progress rather than starting that same admission over again. A cycle of unfinished checks is not success. The written association and checking body remain in the source graph for `toLmx`, copying and execution; there is no separate test catalogue, auxiliary graph, runtime name table or hidden typing-disabled mode. Test calls use ordinary native/walker dispatch and do not force every call to be walked.

@@ admission-recipes | Как получить требуемую гарантию: четырнадцать практических случаев | Obtaining a required guarantee: fourteen practical cases | 2.5.4; 2.5.3; author 2026-09-20
[RU]
Эти случаи применяют [единый допуск](#admission), а не вводят четырнадцать разновидностей типизации.

### 1. Одно принимающее выражение для разных форм данных

Consumer требует используемые им пути, а не номинальный тип всей Structure.

### 2. Понимание того, что проверяется в данном месте

Аналитическая часть проверяет известные обращения Consumer; его явные тесты проверяют заявленное поведение. Неизвестное покрытие не считается доказательством.

### 3. Различение смыслов одинаково представимых значений

Смысловое различие выражают используемым путём и, когда важны значения листьев, тестом; одно имя типа не доказывает равенства значений.

### 4. Ограничение скалярного листа

Наличие поля `width` не доказывает `width = 32`; проверку конкретного числа задаёт тест Consumer.

### 5. Изменение, видимое другим держателям ссылки

Запись через явный путь меняет общий референт; присваивание аргументу меняет локальное значение активации. Публикация own-поля подчиняется §12.

### 6. Независимость от изменения другим держателем

Обычная передача Structure или Array переносит ссылку. Независимую изменяемую копию даёт явное копирование, неизменяемость запрещает изменение защищённого значения.

### 7. Гарантия возможности вызова

Помимо подходящего вызываемого интерфейса, вызову нужны все его обязательные формальные и динамические входы.

### 8. Проверка передаваемого вызываемого значения

Передача callable не исполняет его и не доказывает пригодность для каждого будущего вызова; конкретный вызов проходит собственный допуск.

### 9. Изменение тела метода без нарушения вызовов

Новый свободный динамический вход меняет интерфейс метода и требует проверки затронутых вызовов; неизменная сигнатура сама не гарантирует прежнее поведение.

### 10. Выбор нужной части композиции

`merge` строит новое дерево: совместимое одноимённое поле более позднего операнда заменяет значение слота модели, а новое поле добавляется.

### 11. Изменение существующей структуры

У созданной Structure число и адреса слотов фиксированы; другое число полей требует новой Structure.

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

The analytical stage checks Consumer's known accesses; its explicit tests check the stated behavior. Unknown coverage is not proof.

### 3. Distinguishing meanings with the same representation

Express a semantic distinction through a used path and, where leaf values matter, a test; a type name alone proves no equality of values.

### 4. Constraining a scalar leaf

A `width` field does not establish `width = 32`; Consumer's test states the check of the concrete number.

### 5. Making a change visible to other reference holders

An explicit path write changes the shared referent; assignment to an argument changes an activation-local value. Own-field publication follows §12.

### 6. Independence from another holder's mutation

Ordinary Structure or Array passing transports a reference. Explicit copying creates an independent mutable copy; immutability prohibits mutation of the protected value.

### 7. Establishing that a call can proceed

Besides a suitable callable interface, the call needs all mandatory formals and dynamic inputs.

### 8. Checking a transported callable

Transporting a callable neither executes it nor proves suitability for every future call; each concrete call has its own admission.

### 9. Changing a method body without breaking calls

A new free dynamic input changes the method interface and requires affected calls to be checked; an unchanged signature alone does not guarantee unchanged behavior.

### 10. Selecting the intended part of a composition

`merge` builds a new tree: a compatible same-name field of a later operand replaces the model slot's value, and a new field is appended.

### 11. Changing an existing Structure

A created Structure has fixed field count and slot addresses; a different field count requires another Structure.

### 12. Reliable numeric conversion

A converter respects the destination range: `u16(256) → u8` is no silent wraparound. Refusal follows ordinary failure handling.

### 13. What a broad converter table provides

Additional converters extend available explicit leaf conversions but do not change required paths or callable interfaces.

### 14. Foreign-resource validity

A thin handle does not prove resource validity or authority; its wrapper contract and Consumer checks state those properties.

@@ construction | Построение значений | Value construction | 9.1–9.2; 19.20
[RU]
Исходная запись строит полный граф Structure: значения, объявления и исполняемые выражения остаются в том же графе. Построить описание тела не означает исполнить это тело. Именованная Structure не исполняется при объявлении; безымянное тело в позиции исполнения выполняется по контракту принимающего выражения. Не создаются отдельный граф данных, скрытая процедура-обёртка или постоянный вспомогательный контекст. Лексический родитель определяется местом объявления; у корня independent он отсутствует (parent = 0). Бинарное представление сохраняет текст комментариев; имена доступны через таблицу, описанную в [правилах имён](#fields). Комментарии и таблица имён не заменяют разрешённые ссылки и не участвуют в диспетчеризации.

### Разрешение головы и роль хвоста

Ресивер — инструкция транслятору; вызов callable — действие во время исполнения. У них общий синтаксис Frame «голова принимает хвост», но не одна семантическая роль. Роль головы и смысл её аргументов определяются общим разрешением и контрактом принимающей головы. Имя в аргументах ресивера не становится из-за этого отдельным вызовом: `catch: merge ()` передаёт catch имя выхода и описание параметров, как `fn: mytest ()` передаёт fn имя и описание сигнатуры. Это следствия общего правила, не исключения для этих ресиверов или имён.

<a id="resolved-head-consumption"></a>
#### Одна модель, одно разрешение, одно потребление

Сначала в памяти транслятора целиком формируется записанная структурная модель «голова — аргументы», без знания того, чем является голова. Ни имя, ни сигнатура, ни категория сущности не определяют границы этой модели и не позволяют собирать дополнительные аргументы. Только после её формирования общий алгоритм разрешения в едином пространстве имён определяет роль головы: ресивер, callable, значение для присваивания либо определение Structure. Один общий механизм потребления применяет контракт разрешённой сущности; различие контрактов не создаёт отдельных разборщиков, пространств имён или маршрутов разрешения.

### Композиция места и значения

В целевой составной форме внешняя голова задаёт принимающее место, вложенный ресивер строит или проверяет передаваемое значение. `i: int: 5`, `ptr: Model` и `ptr: @: Model: 0` используют одну композицию Frame: типовой ресивер `int` или `Model` проверяет значение, `@` задаёт ссылочную глубину, а ни один из них сам не объявляет поле с отдельным именем из своего хвоста. Голый атом не вызывает ресивер. Выражение формируется и вычисляется одним способом независимо от того, будет ли его результат потреблён; для уже разрешённой головы эффект присваивания возникает у непотреблённого результата, а не из особого разбора правого операнда. Так, `Model: 0` не обязано менять `Model`, если его результат потребляется другим выражением.

`new_var: int()` явно создаёт ячейку с требованием `int` без придуманного начального значения; `new_var: int: 5` создаёт её со значением `5`. В сигнатуре такая форма описывает формал, а записанное значение служит умолчанием при отсутствии фактического аргумента; описание формала не исполняется как тело. Это один механизм для примитивов, ссылок, Structure и callable, без отдельной ветки по имени ресивера. Порядок и видимость мест определяются до исполнения тела; сам факт первой выполненной ветки не может добавить слот в уже созданный `Lmx`.

В позиции вычисления голый идентификатор проходит тот же поток разрешения, но сам не образует вызов и не передаёт пустой список аргументов. Он обозначает разрешённое значение, ссылку на Structure или callable либо имя ресивера по контракту принимающей позиции; голые `merge` и `int` также не исполняются. Если позиция требует значения, которого обозначенная сущность не предоставляет, это ошибка, а не скрытый нульарный вызов или свободный вход. Для применения разрешённой головы нужен явный Frame с `()` либо `:` и структурным хвостом, в том числе пустым; роль этого Frame по-прежнему определяет контракт головы. Вызов обычной именованной Structure записывается через ресивер `call: A`, а не через её имя как голову. Соседние атомы не захватываются. В `if: p` голое `p` только читается: даже если оно указывает на метод, метод не вызывается. Допустимость самого значения `p` как условия этим правилом не определяется.


При `ptr: Model` имя `ptr` задаёт место, а известная Structure `Model` — требование и передаваемую ссылку; если требуется нулевой адрес, форма `ptr: @: Model: 0` строит соответствующее ссылочное значение. Допуск другого кандидата к `Model` выполняется общим `implements`, без второго правила для имени `Model`. В переходной форме известная обычная Structure `Model` с новым именем `ptr` допускает `Model: ptr`: это одно новое поле-ссылка на тот же экземпляр, как `@: ptr Model`. Если оба имени уже существуют в той же Structure, `Model: ptr` присваивает значение `ptr` существующему месту `Model` после обычного допуска; оно не создаёт второго поля и не записывает в `ptr`. Неизвестная голова `Model` с одиночным атомным хвостом не объявляет ссылку. Вызовы `fn`/`fm`/`sub` проверяются по сигнатурам, а обычная Structure исполняется только через `call`. Вложенность ресиверов не превращает цепочку применений в один список аргументов.

Структурный хвост, например `A: (x: int: 1)`, задаёт значение для нового места `A`. Пустые `A()` и `A: ()` задают одно пустое структурное значение, а голое `A` читает ссылку на уже выбранную обычную Structure. Если `A` уже объявлена на этом уровне, непотреблённый результат повторной структурной формы, включая пустую, присваивается её существующему месту после допуска: второго поля и вызова прежней `A` нет. Вложенная Structure может затенить внешнее `A`. Обычное поле видно вперёд и вниз от своего объявления, в отличие от `fn`/`fm`/`sub` и `catch`; то же правило действует в корневой Structure файла. Заранее выделенный слот не открывает имя более раннему оператору. Путь `Outer\Model()` или `Outer\Model: ()` адресует поле и даёт ему пустую Structure по тому же общему правилу непотреблённого результата; голый `Outer\Model` читает ссылку без вызова. Для исполнения выбранной обычной Structure служит `call: Outer\Model`.

Если put уже определён как callable, следующее определение Batch сохраняет структурное тело `(put: 7)`, не исполняя его:

```text
fn: put (n: int) int
return: n
Batch: (put: 7)
```

Это обычный оператор в полном бинарном дереве, не отдельное значение «сохранённый вызов», скрытое замыкание или второй граф. При исполнении Batch достижение оператора put подчиняется обычному вызову. Наличие нативной реализации Batch выбирает её, отсутствие — обход сохранённого тела в допустимом профиле; само отсутствие нативной реализации не делает дерево потерянным или неисполняемым.



Последующее чтение имени не меняет задним числом роль уже записанной неизвестной головы. В следующем примере у `f` нет формала, видимого внешнего значения или ранее установленного свободного входа `x`: `x: j` определяет именованную Structure, а не присваивает примитиву. `return: x` не даёт объявленного результата `int` и ошибочно по общему правилу проверки и преобразования результата. Одноимённое значение вызывающего не меняет эту классификацию.

```text
fn: f () int
    j: int: 3
    x: j
    return: x
```

Свободный вход — используемое вызываемым свободное значение, не объявленное его явным формалом; его установление и выбор источника следуют [§12](#dynamic). Этот термин не обозначает дополнительную Structure, отдельный граф контекста или поиск имён во время исполнения.

### Явное копирование и ссылочные переменные

Для клонирования либо композиции уже существующих структур используется явный [merge](#composition). В `b: merge: A C` или `b: merge(A C)` операнды — A и C, внешний b получает результат; имя результата не является первым операндом merge. Это верно, где бы ни стояло b — в корне, в методе или в теле именованной Structure (тело — тело процедуры, и b там — строка этой процедуры, как в методе): роль b решает разрешение его имени, а не слово `merge` в хвосте, которое никак не выделяет b среди других неизвестных имён, принимающих Structure. Применение с операндами записывается обычным Frame по [общему правилу грамматики](LMX_grammar.ru.md#no-inference): атом `merge` не захватывает следующие поля как аргументы, и `b: merge A C` не является записью этого применения. Неявное клонирование по факту неизвестного аргумента не выполняется. Формирование возвращаемого вложенного callable с данными завершающейся активации регулируется отдельно тем же разделом композиции и не отменяется правилами объявления.

Ресивер `@:` строит или проверяет ссылочное значение для принимающего места; сам он не заводит второе имя поля из хвоста. Новое место, например `ptr: @: Model: 0`, и запись в уже существующее место проходят один resolver и обычный [допуск](#admission). В сигнатуре тот же ресивер описывает требование к входу. Имя кандидата разрешается при трансляции в адрес, а не ищется в runtime. Известный указатель на метод `b` вызывается записью `b: args`, `b(args)` или `(\b)(args)`; `\b(args)` разыменовывает результат вызова по общему приоритету. Унарное `@b` отдельно адресует ячейку ссылки.

Преобразование кандидата предшествует implements относительно требования потребителя; запись ссылки происходит после успешного допуска. Обычное значение Structure уже передаётся ссылкой. @A адресует её ячейку и не является конверсией Structure в обычную ссылку: A и @A имеют разную глубину. При присваивании имени Structure в ссылочное место читается уже хранимая ссылка, а адрес ячейки назначения используется для записи её нового значения; концептуальные `Lmx *` значения и `Lmx **` адреса ячеек не становятся одним типом выражения только потому, что C-понижение использует оба. Если само присваивание требует преобразования указательного примитивного значения, его направление, глубина и допустимость задаются обычным локальным для Message контекстом преобразований примитивов, а не особой таблицей пар пользовательских Structure; отсутствие такого правила не разрешает молча убрать уровень `@`. Пригодность референта структурному требованию устанавливает implements; физический диапазон Lmx общий, не отдельный для каждой модели.

### Сигнатура не исполняется

Сигнатура описывает входы, а не исполняет записанные в ней формы как тело метода. Для непримитивного `A` формал с требованием `A` допускает кандидата через `implements(c, A, Consumer)` и передаёт ссылку на дескриптор без копирования или неявного `merge`. Требования значения и ссылки формируются той же композицией, что в теле, но описание формала не присваивает место при построении метода. Если в сигнатуре записано значение, оно является умолчанием, а не результатом исполнения тела.

Для структурного `c` передачи `mytest(c)` и `mytest(@c)` имеют разную глубину: ссылка на Structure и ссылка на ячейку этой ссылки. Лишний уровень не снимается ради формала. Это одинаково для Structure, ссылочной переменной и непримитивного формала; адресуется собственное языковое хранилище, не транспортная ABI-ячейка. Примитивное значение и ссылка на его ячейку также не синонимы. Передача и возврат непримитивов не используют C by-value aggregate.

### Присваивание и места объявления

На одном структурном уровне повторное обращение к известному месту означает присваивание, не второе поле; вложенная Structure может затенить внешнее имя. Например, `i: int: 5; i: int: 6` оставляет одну ячейку `i`. Присваивание выполняется после допуска; отказ сохраняет прежнее значение и отметку `dirty`. Оба исходных оператора остаются в полном графе.


Явный или скрытый аргумент остаётся локальным значением активации: присваивание ему не пишет обратно вызывающему. Own-поле метода имеет физическое место в его `var` и публикуется по [§12](#dynamic); его оператор в `body` не становится отдельным полем. Описание в сигнатуре лишь задаёт формал и не исполняется как эта операция.
[EN]
Source notation constructs the complete Structure graph: values, declarations and executable expressions remain in the same graph. Constructing a body description does not execute that body. A named Structure is not executed on declaration; an anonymous body in execution position runs under its receiving expression's contract. No separate data graph, hidden wrapper procedure or persistent auxiliary context is created. The declaration site determines the lexical parent; an independent root has none (parent = 0). The binary representation retains comment text; names remain available through the table described under [name rules](#fields). Comments and the name table do not replace resolved references or participate in dispatch.

### Head resolution and the role of the tail

A receiver is an instruction to the translator; a callable call is a runtime action. They share the Frame syntax "the head consumes the tail", not a semantic role. General resolution and the receiving head's contract determine the head's role and the meaning of its arguments. A name in a receiver's arguments does not thereby become another call: `catch: merge ()` supplies catch with the failure name and parameter description, just as `fn: mytest ()` supplies fn with the name and signature description. These are consequences of the common rule, not exceptions for those receivers or names.

<a id="resolved-head-consumption"></a>
#### One model, one resolution, one consumption

First, the complete written structural head/arguments model is formed in translator memory, without knowing what the head denotes. Neither its name, signature, nor entity category determines that model's boundaries or permits collecting additional arguments. Only after the model has been formed does the common resolution algorithm in the single namespace determine the head's role: receiver, callable, assignment value, or Structure definition. One common consumption mechanism applies the resolved entity's contract; differing contracts do not create separate parsers, namespaces, or resolution routes.

### Composition of place and value

In the target composed form, the outer head selects the receiving place; a nested receiver builds or checks the value supplied to it. `i: int: 5`, `ptr: Model`, and `ptr: @: Model: 0` use one Frame composition: the type receiver `int` or `Model` checks the value, `@` establishes reference depth, and none of them itself declares a separately named field from its tail. A bare atom does not invoke a receiver. The expression is formed and evaluated the same way whether its result is consumed or not; for an already resolved head, assignment is an effect of an unconsumed result, not a special parse of the right operand. Thus `Model: 0` need not change `Model` when another expression consumes its result.

`new_var: int()` explicitly creates a cell requiring `int` without an invented initial value; `new_var: int: 5` creates it with value `5`. In a signature the same form describes a formal, and a written value supplies a default when an actual argument is absent; describing a formal does not execute it as a body. This is one mechanism for primitives, references, Structures, and callables, with no branch for a receiver's name. Places and visibility are fixed before body execution; whichever branch happens to execute first cannot add a slot to an already constructed `Lmx`.

In evaluation position, a bare identifier enters the same resolution flow but does not itself form a call or supply an empty argument list. It denotes the resolved value, a reference to a Structure or callable, or a receiver name according to the receiving position's contract; bare `merge` and `int` likewise do not execute. If that position requires a value the named entity does not provide, this is an error, not a hidden nullary call or free input. Applying a resolved head requires an explicit Frame with `()` or `:` and a structural tail, possibly empty; that head's contract still determines the Frame's role. An ordinary named Structure is invoked through receiver `call: A`, not by using its name as the head. Neighboring atoms are not captured. In `if: p`, bare `p` is only read: even if it points to a method, that method is not called. This rule does not decide whether the value of `p` is admissible as a condition.


In `ptr: Model`, `ptr` selects the place and the known Structure `Model` supplies its requirement and reference; when a null address is needed, `ptr: @: Model: 0` builds the corresponding reference value. Admitting another candidate to `Model` uses ordinary `implements`, with no second rule for the name `Model`. In the transitional form, a known ordinary Structure `Model` and a new name `ptr` admit `Model: ptr`: it creates one reference field to that same occurrence, as `@: ptr Model` does. If both names already exist in the same Structure, `Model: ptr` assigns the value of `ptr` to the existing `Model` place after ordinary admission; it neither creates a second field nor writes to `ptr`. An unknown head `Model` with a lone atom in its tail does not declare a reference. Calls of `fn`/`fm`/`sub` are checked against their signatures, and an ordinary Structure executes only through `call`. Receiver nesting does not turn an application chain into one argument list.

A structural tail such as `A: (x: int: 1)` supplies the value for a new place `A`. Empty `A()` and `A: ()` supply one empty structural value, while bare `A` reads a reference to an already selected ordinary Structure. If `A` is already declared at this level, the unconsumed result of a repeated structural form, including an empty one, is assigned to its existing place after admission: neither a second field nor a call of the former `A` results. A nested Structure may shadow the outer `A`. An ordinary field is visible forward and down from its declaration, unlike `fn`/`fm`/`sub` and `catch`; the same rule applies in the file's root Structure. A slot allocated in advance does not make the name visible to an earlier statement. A path `Outer\Model()` or `Outer\Model: ()` addresses that field and supplies an empty Structure under the same general unconsumed-result rule; bare `Outer\Model` reads its reference without calling. To execute the selected ordinary Structure, use `call: Outer\Model`.

If put is already defined as callable, the following definition of Batch retains the structural body `(put: 7)` without executing it:

```text
fn: put (n: int) int
return: n
Batch: (put: 7)
```

This is an ordinary operator in the complete binary tree, not a separate “saved call” value, hidden closure or second graph. When execution of Batch reaches the put operator, the ordinary call rules apply. An available native implementation of Batch is selected; otherwise its retained body is walked in the admissible profile. Absence of a native implementation alone does not mean the tree is lost or unexecutable.



A later read does not retroactively change the role of an already written unknown head. In the following example, `f` has no formal, visible outer value or previously established free input `x`: `x: j` defines a named Structure rather than assigning a primitive. `return: x` does not provide the declared `int` result and is erroneous under the general result checking and conversion rule. A caller's same-named value does not change this classification.

```text
fn: f () int
    j: int: 3
    x: j
    return: x
```

A free input is a free value used by a callable without being declared as its explicit formal; establishing it and selecting its source follow [§12](#dynamic). This term denotes neither an additional Structure, a separate context graph nor name lookup during execution.

### Explicit copying and reference variables

Explicit [merge](#composition) clones or composes existing Structures. In `b: merge: A C` or `b: merge(A C)` the operands are A and C and outer b receives the result; the destination name is not the first merge operand. This holds wherever b stands: at the root, in a method or in a named Structure's body (the body is a procedure's body, and b there is a row of that procedure, as in a method); b's role is decided by the resolution of its name, not by the word `merge` in the tail, which does not single b out among the other unknown names that accept a Structure. Application with operands uses an ordinary Frame under the [general grammar rule](LMX_grammar.en.md#no-inference): an atom `merge` does not capture subsequent fields as arguments, and `b: merge A C` does not spell that application. An unknown argument does not trigger implicit cloning. Formation of a returned nested callable with data from the finishing activation is governed separately by that composition section and is not removed by declaration rules.

The `@:` receiver builds or checks a reference value for a receiving place; it does not introduce another field name from its tail. A new place such as `ptr: @: Model: 0` and a write to an existing place use the same resolver and ordinary [admission](#admission). In a signature the same receiver describes an input requirement. A candidate name resolves to an address at translation, never by runtime name lookup. A known method pointer `b` is invoked as `b: args`, `b(args)` or `(\b)(args)`; `\b(args)` dereferences the call result under ordinary precedence. Unary `@b` separately addresses the reference cell.

Candidate conversion precedes implements against the Consumer's requirement; reference storage changes after admission succeeds. An ordinary Structure value already travels by reference. @A addresses its cell and is not conversion of a Structure to its ordinary reference: A and @A have different depths. Assigning a Structure name to a reference place reads the already held reference and uses the destination cell's address to store its new value; conceptual `Lmx *` values and `Lmx **` cell addresses do not become the same expression type merely because C lowering uses both. If the assignment itself requires conversion of a primitive pointer value, its direction, depth and admissibility are supplied by the ordinary Message-local primitive conversion context, not a special table of user-Structure pairs; an absent rule does not silently remove an `@` level. implements establishes the referent's suitability for a structural requirement; the physical Lmx range is common, not separate for each model.

### A signature is not executed

A signature describes inputs rather than executing its forms as a method body. For nonprimitive `A`, a formal requiring `A` admits a candidate through `implements(c, A, Consumer)` and transports its descriptor reference without copying or implicit `merge`. Value and reference requirements use the same composition as in a body, but describing a formal does not assign a place while the method is built. A value written in the signature is a default, not a result of executing the body.

For structural `c`, `mytest(c)` and `mytest(@c)` have different depths: a Structure reference and a reference to the cell holding it. No extra level is removed to fit a formal. This applies equally to a Structure, a reference variable and a nonprimitive formal; the target is its own language storage, not a transport-ABI box. A primitive value and a reference to its cell are not synonyms either. Passing and returning nonprimitives never use C by-value aggregates.

### Assignment and declaration sites

At one structural level, another use of a known place assigns to it instead of adding a second field; a nested Structure may shadow an outer name. For example, `i: int: 5; i: int: 6` leaves one `i` cell. Assignment occurs after admission; refusal preserves the old value and `dirty` state. Both source operators remain in the complete graph.


An explicit or hidden argument remains an activation-local value: assigning it does not write back to the caller. A method's own field has physical storage in `var` and is published under [§12](#dynamic); its operator in `body` is not another field. A signature describes a formal and does not execute as this operation.

@@ qualification | const, immutable и independent | const, immutable and independent | 2.5.3; 9.1.2–9.1.3
[RU]
`const` защищает привязку: её нельзя присвоить, перепривязать или заменить. Значение за защищённой ссылкой может оставаться изменяемым. `immutable` защищает само значение на протяжении всей его жизни, через любые псевдонимы; переменная, содержащая ссылку на него, может оставаться перепривязываемой. `const: immutable` объединяет обе гарантии. Это независимые квалификации, а не ступени одной шкалы.

Неизменяемость применима к примитиву, Structure и выбранному дереву, Array с дескриптором и элементами. Она охватывает все поля и явно включённые описания, а не только пути Consumer. Передача, возврат и сохранение неизменяемого значения сохраняют его идентичность; квалификация не требует копии, в том числе для примитива. Она не замораживает внешний ресурс, обозначенный неизменяемым идентификатором.

`immutable` задаёт надтип нового значения при построении до публикации: ячейки выделяются в пулах соответствующих immutable-типов. Обычная уже построенная Structure из пула изменяемых Structure не переводится задним числом в immutable-тип: попытка `immutable: Existing` с таким значением получает отказ при потреблении. Это снимает прежнее обещание `RuntimeImmutable` переквалифицировать существующее дерево без смены адреса. Уже immutable-значение может проходить как значение своего типа без повторной переквалификации. Допуск аргумента остаётся [единым](#admission), как у прочих принимающих выражений.

Перед публикацией нового immutable-значения исследуется всё выбранное дерево. Вложенная структура является ветвью дерева только тогда, когда её обычное структурное поле `parent` указывает на рассматриваемого родителя. Внешняя ссылка, **уже сохранённая как значение данных**, допустима только на уже неизменяемый объект; она терминальна, её цель не обходится и не переквалифицируется. Собственный `parent` корня — структурная лексическая связь с узлом вне выбранного дерева, а не такая сохранённая ссылка: `immutable` без `independent` строит значение под его обычным родителем, которого не замораживает и неизменяемости которого не требует; `independent` — единственный ресивер, касающийся этой связи. Операнд сохранённого исполняемого кода до его выполнения ещё не является таким значением (см. ниже). Проверяется состояние до публикации: результат обработки раннего поля не может оправдать недопустимую внешнюю ссылку в позднем. Если исходное объявление `immutable` нарушает это условие, транслятор отказывает в построении; даже при интерпретации граф сначала строится, и такой отказ не является исключением исполняемого тела. Если же ошибка обнаружена при исполняемой операции над уже существующим деревом, интерпретатор передаёт её обычным `throw`, который обрабатывается обычным `catch`, без особого канала для `immutable`. Ни один из этих случаев не превращается в `assert`.

Проверяются значения и ссылки, уже сохранённые в дереве. Известная допущенная Structure как кандидат объявления ссылки сохраняется в ячейке при построении, даже если тело именованной Structure или метода ни разу не вызывали; объявление не исполняет тело. Исполняемое выражение, сохранённое как код, не выполняется при квалификации; его возможный будущий результат не является ссылкой, сохранённой сейчас. В частности, отложенное чтение или вызов не отклоняются лишь потому, что могут вернуть изменяемый объект: результат проверяется, когда он действительно получен, присвоен или иначе потреблён по обычному контракту. Неизменяемая Structure может содержать код, который позже читает изменяемые данные, не замораживая их. Код и данные могут физически находиться в одном графе, но это не превращает адресный операнд операции в её результат.

Примитивы и методы — листья, не ветви лексического дерева. Это правило описывает топологию `parent`, а не освобождает от проверки изменяемое хранилище, физически удерживаемое квалифицированным графом: сохранённая запись кода метода и уже сохранённые данные должны удовлетворять контракту неизменяемого построения. Отложенные операнды являются кодом, а не своими возможными будущими значениями; ячейки последующей активации эта проверка не замораживает. Ссылка на массив также не создаёт ветвь `parent`: операция над деревом не замораживает неявно изменяемое хранилище внешнего массива. Неизменяемый массив строится по собственному контракту. Принадлежность ячейки служебному пулу не даёт права обходить или квалифицировать весь пул.

Квалификация нового значения завершается только после успешной полной предварительной проверки. При неудаче нет частично опубликованного immutable-дерева или успешного результата; запрещено молча пропускать ветвь, копировать уже существующий обычный объект ради смены его типа или перенаправлять ссылки. Уже immutable-значение не нуждается в повторной квалификации. Правило не откатывает ранее выполненные инициализаторы, вычисление аргументов или предвызовную публикацию рабочих полей; транзакция графа не возникает.

Защита обязательна для записей через любой путь и для публикации рабочих полей. Когда ресивер `immutable` потребляет Structure, он должен установить, что её сохранённое тело не запишет в защищаемые ячейки; заведомо недопустимая запись или невозможность доказать безопасность получает отказ **при этом потреблении**, до генерации и исполнения вызова, а не при будущей публикации рабочего поля. Например, сохранённый метод `x: int: 0; x: x + 1; return: x` пишет в поле защищаемого графа; потребление содержащей его Structure ресивером `immutable` получает отказ. Компилировать запись в заведомо неизменяемую ячейку нельзя. Динамическая проверка записи остаётся для внешнего кода, обращающегося к уже защищённому значению; она не заменяет доказательство при потреблении сохраняемого тела. Вызов метода сам по себе не снимает защиты. Изменение локальной копии аргумента или перепривязка локальной ссылки не меняют защищённое значение. Построение нового значения, в том числе `merge`, не размораживает исходное.

`independent` при построении устанавливает у корня `parent = 0`; это и есть отсутствие внешнего лексического родителя. Внутренние связи `parent` дерева и собственные поля сохраняются. Квалификация не обнуляет задним числом `parent` уже существующих объектов и не запрещает явно переданные ссылки, динамические аргументы текущего вызывающего выражения, сообщения или выбор вызываемого выражения по совместимой сигнатуре. Это не требование чистоты и не закрытый интерфейс только из явных аргументов.

`const`, `immutable` и `independent` являются принимающими выражениями; их композиция задаёт квалифицированный тип результата. `immutable` — надтип значения, задаваемый при построении. Для каждого базового типа есть собственное хранилище соответствующего immutable-типа; все immutable-Structure, независимо от модели их полей, используют общий пул своего типа, отдельный от пула обычных Structure. Квалификация одной Structure не распространяется на посторонние значения; все псевдонимы построенного immutable-значения видят один и тот же надтип по адресу. Общий механизм адресной классификации описан в [L2](L2_spec_ru.md#type-by-range); не вводится новый тип на каждую модель Structure или таблица имён времени исполнения. Нулевой `parent` корня остаётся структурным следствием `independent`, а не заменой классификации типа. Как принимающие выражения они стоят везде, где принимается значение Structure, — в хвосте объявления, в `return:` метода, операндом `merge`, — и компонуются в том порядке и составе, в каком написаны в исходнике, каждое со своим контрактом; цепочка над именованной Structure в корне модуля — один из случаев этого чтения, а не его определение.

Например, метод внутри независимой структуры S может использовать поле S через внутреннюю лексическую связь. Требуемое `x` может прийти из текущего вызывающего выражения. Если `x` находится только в прежнем текстовом окружении S, внешнего неявного доступа к нему нет. Явно переданный большой массив не становится меньше и не копируется из-за `independent`. Особый срок жизни сочетания трёх квалификаций описан в [вечных ветвях](#eternal).
[EN]
`const` protects a binding: it cannot be assigned, rebound or replaced. The value behind a protected reference may remain mutable. `immutable` protects the value itself for its entire life through every alias; a variable holding its reference may remain rebindable. `const: immutable` combines both guarantees. They are independent qualifications, not degrees of one scale.

Immutability applies to a primitive, a Structure and its selected tree, or an Array with its descriptor and elements. It covers every field and explicitly included descriptions, not just Consumer's paths. Passing, returning and storing an immutable value preserve its identity; qualification requires no copy, including for a primitive. It does not freeze a foreign resource denoted by an immutable identifier.

`immutable` gives a new value its supertype during construction, before publication: cells are allocated from pools of the corresponding immutable types. An ordinary Structure already built in the mutable-Structure pool is not retroactively converted; `immutable: Existing` on that value refuses at consumption. This supersedes the earlier promise that `RuntimeImmutable` would requalify an existing tree without changing its identity. An already immutable value can pass as a value of its type without requalification. Argument admission remains [unified](#admission), as for every receiving expression.

The whole selected tree is examined before the new immutable value is published. A contained Structure is a tree branch only when its ordinary structural `parent` field points to the parent being examined. An outside reference **already stored as a data value** is permitted only to an already immutable object; it is terminal, and its target is neither traversed nor requalified. The root's own `parent` is a structural lexical link to a node outside the selected tree, not such a stored reference: `immutable` without `independent` constructs the value under its ordinary parent, which it neither freezes nor requires to be immutable; `independent` is the one receiver that touches that link. An operand of stored executable code is not such a value before that code runs (see below). The pre-publication state is checked: processing an earlier field cannot justify an invalid outside data reference in a later field. If a source `immutable` declaration violates this condition, the translator refuses construction; even under interpretation the graph is built first, so this refusal is not an exception thrown by the executable body. If an executed operation on an already existing tree encounters an error, the interpreter uses the ordinary `throw` caught by the ordinary `catch`, with no special `immutable` channel. Neither case becomes an `assert`.

The check concerns values and references already stored in that tree. A known admitted Structure used as a reference declaration's candidate is stored in the cell at construction, even if the named Structure or method body is never called; declaration does not execute that body. An executable expression stored as code is not executed by qualification, and its possible future result is not a presently stored reference. In particular, a deferred read or call is not rejected merely because it could return a mutable object; its result is checked when it is actually received, assigned or otherwise consumed under the ordinary contract. An immutable Structure may therefore contain code that later reads mutable data without freezing those data. The representation may place code and data in the same graph; that does not turn an operation's address operand into the result of the operation.

Primitives and methods are leaves, not lexical-tree branches. This describes the `parent` topology, not an exemption for mutable storage physically retained by the qualified graph: a saved method's code record and already stored data must satisfy the immutable construction contract. Its deferred operands are code, not their possible future values, and cells of a later activation are not frozen by this check. An Array reference likewise establishes no `parent` branch: a tree operation does not implicitly freeze an outside Array's mutable backing. An immutable Array is constructed under its own contract. A cell's membership in a service pool does not permit traversal or qualification of the entire pool.

Construction of an immutable value completes only after successful full preflight. Failure leaves no partially published immutable tree or successful result; silently skipping a branch, copying an already existing ordinary object merely to change its type, or retargeting links is prohibited. An already immutable value needs no requalification. This rule does not roll back earlier initializers, argument evaluation or pre-call publication of working fields; it establishes no graph transaction.

Protection applies to writes through every path and to publication of working fields. When the `immutable` receiver consumes a Structure, it must establish that the saved body cannot write into the protected cells; a known-invalid write or inability to prove safety refuses **that consumption**, before call code is generated or executed, rather than at a later working-field publication. For example, a saved method `x: int: 0; x: x + 1; return: x` writes a field of the graph being protected; consuming its containing Structure with `immutable` is refused. A write into a known immutable cell cannot be compiled. Dynamic write checks remain for external code addressing an already protected value; they do not replace proof when the saved body is consumed. Calling a method alone does not remove protection. Changing a local argument copy or rebinding a local reference does not modify the protected value. Constructing a new value, including through `merge`, does not thaw the source.

Construction-time `independent` sets the root's `parent = 0`; that is exactly the absence of an external lexical parent. Internal tree `parent` links and own fields remain. The qualification neither retroactively clears existing objects' `parent` links nor prohibits explicitly supplied references, current-caller dynamic arguments, Messages or selection of a callable by a compatible signature. It does not require purity or an interface closed over explicit arguments alone.

`const`, `immutable` and `independent` are receiving expressions; their composition establishes the result's qualified type. `immutable` is a supertype determined when the value is built. Each base type has storage for its corresponding immutable type; all immutable Structures, regardless of their field models, use a shared pool of that type, distinct from the ordinary Structure pool. Qualifying one Structure does not affect unrelated values; every alias of a constructed immutable value sees the same supertype by address. The common address-classification mechanism is described in [L2](L2_spec_en.md#type-by-range); this does not introduce a new type for every Structure model or a runtime name table. A zero root `parent` remains the structural consequence of `independent`, not a replacement for type classification. As receiving expressions they stand wherever a Structure value is received -- a declaration's tail, a method's `return:`, a `merge` operand -- composed in the order and part the source writes, each with its own contract; the root-level chain over a named Structure is one case of that reading, not its definition.

For example, a method inside independent Structure S can use S's field through its internal lexical link. Required `x` can come from the current caller. If `x` exists only in S's former textual surroundings, implicit external access is unavailable. An explicitly passed large Array neither shrinks nor gets copied because of `independent`. The special lifetime of the three qualifications together is described under [eternal branches](#eternal).

@@ callables | Вызываемые выражения и их интерфейсы | Callable expressions and their interfaces | 7–7.3; 7.5.1; 8.5–8.8; 19.21; 21.9
[RU]
<a id="declaration-visibility"></a>
Имена методов, созданных `fn`, `fm` и `sub`, видны в обе стороны своего лексического блока. Обычная именованная Structure и ссылка на метод видны лишь с места объявления вперёд и вниз; вложенное объявление может затенить внешнее, а повторная объявляющая форма на том же уровне присваивает уже существующему полю после допуска ([§4](#fields)). Для [разрешения головы](#resolved-head-consumption) важна видимость именно в данной позиции. Скобки, форма хвоста и trailer не меняют её.

Файлы программы не образуют категорий «основной» и «часть»: message — Structure, и любой файл, подключённый любым способом, встраивается в граф программы. Видимость объявлений между файлами следует получившемуся графу и этим же правилам видимости — от места объявления вперёд и вниз, для callable `fn`, `fm`, `sub` в обе стороны в их блоке; сравнение позиций в разных документах видимость не определяет.

Сигнатура описывает входы и результат; она не является исполняемым телом. Запись формала не выполняет вызов, объявление или присваивание, которое та же запись могла бы означать в теле. Синонимия двух описаний в сигнатуре относится к контракту параметра и не переносится на исполняемые записи. Подача фактического аргумента выполняет предусмотренные контрактом преобразования и допуск, но не исполняет описание формала как оператор тела. Использование полученного параметра в теле разрешается по его контракту и общим правилам выражений, а не исполнением текста сигнатуры.

<a id="method-parts"></a>
### Части вызываемой Structure

Вызванное `fn`, `fm`, `sub` или `catch` представлено одной полной Structure с адресуемыми частями `args`, описанием `return` там, где оно есть, `var` и `body`. `var` — отдельный аргумент ресивера перед телом и после описания результата у `fn`/`fm`. Явные поля `var` и собственные поля, обнаруженные в `body`, составляют набор полей до выделения вхождения; отсутствующие в явной части добавляются к `var`, но инициализации остаются там и тогда, где их задаёт исходная запись. Предварительное определение полей не исполняет `body`, не переносит его операторы и не создаёт второго графа. Явное поле `var` видно телу с его начала; поле, добавленное из `body`, сохраняет точку своего исходного объявления и видно от неё вперёд и вниз. Выделение слота заранее не делает имя видимым назад и не обещает нуль для значения без инициализатора. Части доступны как поля одной Structure, включая путь `func\var`; размер уже построенного `Lmx` не меняется.

Обычная Structure исполняется явным ресивером `call`. Форма `call: code data` получает две Structure: `code` задаёт исполняемое тело, `data` — явно переданные данные. До исполнения необходимые коду поля должны существовать в `data` и пройти допуск; отсутствие поля отказывает, а не добавляет его скрыто. Формалы, динамические входы и `node` не становятся полями `data` по совпадению имени. Соответствие адресов code→data подготавливается до исполнения, без таблицы имён в runtime.

Исполняемое тело — структурное выражение; объявление именованной Structure или метода его не исполняет. Голое имя обычной Structure обозначает ссылку на неё; явный ресивер `call: A` исполняет её без аргументов и результата, а `A()` / `A: ()` остаются структурными формами объявления или присваивания. `fn` объявляет один результат, `sub` не возвращает значение, `fm` возвращает одну Structure с несколькими именованными полями. Сигнатура задаёт аргументы, результат и `throws`, но сама не исполняется.

Голый `return` завершает исполнение без значения; `return: value` допустим лишь там, где объявлен результат. На уровне открытия `return` также может быть trailer любой callable-Structure по общему правилу грамматики; для невызываемой Structure это не закрыватель. Явный `end: Name` не обязателен, а завершение тела без `return` не создаёт узел возврата.

Путь через Structure читает поле, но не вызывает её. Собственное поле метода физически принадлежит части `var` той же вызываемой Structure; оператор `body` обращается к этому месту и не создаёт второй ячейки. Правило композиции места и значения дано в [построении](#construction).

Вызываемое вхождение имеет собственную структурную идентичность и поле `parent`, указывающее в его над-методное лексическое пространство. Несколько вхождений могут ссылаться на один неизменяемый метод. Копирование графа не создаёт новую реализацию метода и не меняет его сигнатуру; состояние принадлежит конкретным структурным вхождениям и активациям. Вложенное определение не захватывает кадр вызывающего выражения в скрытое окружение.

Вход в метод не копирует его вызываемое вхождение и не создаёт второй граф. Нативное и интерпретируемое исполнение работают с полной Structure вызываемого; исходный порядок операторов `body` сохраняется. Каждая активация получает машинный кадр для формальных и скрытых входов, результата и рабочих значений полей `var`. Изменённые рабочие значения публикуются в полях `var` по [§12](#dynamic); операторы и литералы не переписываются. Рекурсия исполняет ту же Structure с отдельным кадром. `merge` может дать формалу значение по умолчанию, но не связывает его. Свободное имя сначала получает допустимый динамический вход, затем лексический источник; временные значения кадра не добавляют узлов в граф.

Части `args`, `return`, `var` и `body` принадлежат одной Structure; `var` не есть отдельный граф значений или скрытое окружение вызова. Программа может также явно разделять данные и код через `call: code data`, не создавая неявных полей.

Отсутствие явных аргументов у именованной Structure не отменяет скрытых аргументов. При её исполнении свободные имена получают значения по единому правилу вызываемой процедуры: сначала из текущего вызывающего выражения, затем из допустимого лексического источника ([§12](#dynamic)). Полученное значение локально для активации; присваивание голому имени не пишет обратно в источник. Отдельного режима разрешения свободных имён для именованной Structure нет.

Различие сохраняется и внутри одной Structure: `a: int()` создаёт типизированное место, а последующий оператор `a: get_a()` вычисляет и записывает новое значение при достижении этой строки. При построении метода место определяется в `var`; предварительный учёт не исполняет оператор `body`. Совместное хранение частей в графе не делает их взаимозаменяемыми.

Выбор вызова начинается с явной ссылки, структурного пути либо текстового пути с явно переданным корнем. Выбор реализации и подача её аргументов — разные действия. Обнаруженный кандидат проходит [допуск](#admission); затем вызов должен получить все входы сигнатуры. Наличие подходящего поля с методом ещё не обеспечивает его динамические входы. Передача метода как данных не равна его вызову.

Позиционные фактические аргументы предшествуют именованным. После первого именованного аргумента последующие также именованные. Неизвестное имя, повторное присваивание одного аргумента, недостающий обязательный аргумент или нарушение порядка — ошибка. Тело именованного аргумента передаётся как структурное значение, если именно такой режим задаёт принимающее выражение; оно не становится произвольной последовательностью немедленных вызовов. В позиции аргумента голое имя callable обозначает ссылку на его вхождение, а не результат исполнения. Если принимается результат, аргумент должен содержать явный вызов возвращающего значение callable (`f()` либо `f: ()` для нульарного метода), после которого действуют обычные преобразования и допуск; одно лишь требование результата не вызывает голое `f`. Callable без результата, включая `sub`, можно передать по ссылке в подходящее место, но не как значение результата. Голый `return` означает только выход и не делает callable возвращающим значение. Объявленный без тела `fn` остаётся дескриптором интерфейса и может передаваться ссылкой, но прямое исполнение не получает вымышленного тела.

Формальный параметр с предусмотренным значением по умолчанию остаётся частью полного принимаемого интерфейса. При отсутствии явно поданного аргумента используется это значение; при явной подаче используется поданный аргумент, прошедший обычные преобразования и допуск. Наличие дефолта не удаляет формал и не превращает его в свободный динамический вход: одноимённое значение в контексте вызывающего не становится поданным аргументом — для его подачи есть обычный вызов с аргументом. Эти правила не зависят от того, были ли данные параметра получены через `merge` ([§20](#composition)): один и тот же смысл получается при непосредственном задании такого аргумента и при обычной композиции его данных. Значение, неподходящее по контракту, не приравнивается к отсутствующему аргументу и не заменяется дефолтом молча; ноль — тоже поданное значение. Источник дефолта и значение аргумента текущей активации различаются: подача `y: 25` для одного вызова не меняет последующие вызовы, и значение, оставшееся в рабочей ячейке после прежнего исполнения, само по себе дефолтом не становится — изменить состояние, из которого берётся дефолт, может только обычная явная операция над ним. Нет ни аргумента, ни допустимого дефолта — обычный отказ вызова.

Синтаксические границы имени функции, `args`, описания результата, `var` и `body` определены в [грамматике](LMX_grammar.ru.md). Пустое Structure-тело Frame содержит ноль полей; голый `f:` без аргумента или явного закрытия недопустим. Описания и подписи не создают неявный вызов, каррирование или замыкание.

В исполняемом теле безголовая запись — обычное выражение, а не ошибка и не особая форма вызова. Это относится к одиночному `2`, голому `f`, последовательности `2 + 2`, анонимной структуре `(f)` или `(2 + 2)` и пустой `()`. Их поля разрешаются и вычисляются в лексическом порядке тем же механизмом выражений; результат, которому не указан получатель, отбрасывается. Анонимная структура с несколькими полями, в том числе с Frame и безголовыми выражениями, сохраняет порядок исполнения всех полей; ограниченная и соответствующая вертикальная запись не выбирает разные операции. Голое `f` читает разрешённое значение либо ссылку на Structure или метод без вызова. Явное `f()` либо `f: ()` передаёт пустую структуру аргументов разрешённой голове: у метода это нульарный вызов по его контракту, у обычной Structure — структурное объявление или присваивание; её исполнение записывается `call: f`. В позиции аргумента также действует контракт получателя (§10, выше), но одно лишь наличие имени нигде не запускает вызов. Литерал `2` не объявляет тип для `f: 2`. Пустая `()` допустима как присутствующая пустая Structure без внутренних выражений. Ни форма скобок, ни факт отбрасывания результата не обходят обычное разрешение, admission или диагностику неизвестного имени.

Именованные результаты `fm` — поля уже существующей структуры результата. `return` завершает их обновление и передаёт эту структуру; сам переход управления не выделяет и не копирует её. Несколько значений в хвосте `return` заполняют предусмотренные сигнатурой поля той же структуры. Точные поверхностные формы распаковки требуют отдельного правила профиля.

Сокращённая запись с присваиванием имени функции, например `square: x * x` внутри `square`, допустима только если принимающий `fn` определяет одноимённую локальную ячейку результата. Она не заменяет постоянную ссылку на вызываемое выражение. Без такого контракта форма отвергается. Структурное закрытие `end: f` не добавляет неявный возврат значения; основной вариант — явный `return: value`.

Возвращаемая ссылка сохраняет точную идентичность цели. Построение результата, если нужно, принадлежит вычислению возвращаемого выражения, а не операции перехода. Возврат вложенной функции завершает её активацию, а не автоматически весь актор. Порядок публикации и очистки задан в [выходах](#exits).
[EN]
<a id="declaration-visibility"></a>
Names of methods created by `fn`, `fm`, and `sub` are visible in both directions within their lexical block. An ordinary named Structure and a reference to a method are visible only forward and down from their declaration site; a nested declaration may shadow an outer one, while a repeated declaring form at the same level assigns to the existing field after admission ([§4](#fields)). [Head resolution](#resolved-head-consumption) uses visibility at the current position. Parentheses, tail shape, and a trailer do not change it.

The files of a program form no categories of a main file and parts: a message is a Structure, and any file attached by any means is embedded into the program graph. Visibility of declarations across files follows the resulting graph and these same visibility rules -- forward and down from the declaration site, in both directions within their block for the callables `fn`, `fm`, `sub`; comparing positions in different documents does not define visibility.

A signature describes inputs and the result; it is not an executable body. A formal's spelling does not execute the call, declaration, or assignment that the same spelling might denote in a body. Synonymy between two descriptions in a signature concerns the parameter contract and does not extend to executable occurrences of those spellings. Supplying an actual argument performs the contract's conversions and admission, but does not execute the formal description as a body operator. Uses of the resulting parameter in the body are resolved by its contract and the general expression rules, not by executing the signature text.

<a id="method-parts"></a>
### Parts of a callable Structure

A called `fn`, `fm`, `sub`, or `catch` is one complete Structure with addressable `args`, a `return` description where applicable, `var`, and `body` parts. `var` is a separate receiver argument before the body and after the result description for `fn`/`fm`. Explicit `var` fields and own fields found in `body` determine the field set before the occurrence is allocated; fields absent from the explicit part are added to `var`, while initializers remain at the source-defined place and time. Determining fields in advance neither executes `body`, moves its operators, nor creates a second graph. An explicit `var` field is visible from the start of the body; a field added from `body` retains its source declaration point and is visible forward and down from there. Allocating its slot in advance does not make the name visible backward or promise zero for a value without an initializer. The parts are fields of one Structure, including the path `func\var`; the size of an already built `Lmx` does not change.

An ordinary Structure executes through the explicit `call` receiver. `call: code data` receives two Structures: `code` supplies the executable body and `data` the explicitly supplied data. Before execution, fields required by the code must exist in `data` and pass admission; a missing field causes refusal instead of being added invisibly. Formals, dynamic inputs, and `node` do not become `data` fields by name coincidence. Code→data address correspondence is prepared before execution, without a runtime name table.

An executable body is a structural expression; declaring a named Structure or method does not execute it. The bare name of an ordinary Structure denotes a reference to it; explicit receiver `call: A` executes it without arguments or result, whereas `A()` / `A: ()` remain structural declaration or assignment forms. `fn` declares one result, `sub` returns no value, and `fm` returns one Structure with several named fields. A signature specifies arguments, result, and `throws` but does not itself execute.

Bare `return` exits without a value; `return: value` is admitted only where a result is declared. At the opening level, `return` may also be a trailer for any callable Structure under the general grammar rule; it is not a closer for a non-callable Structure. Explicit `end: Name` is optional, and reaching the end of a body without `return` does not synthesize a return node.

A path through a Structure reads a field without invoking it. A method's own field physically belongs to the `var` part of that same callable Structure; its `body` operator addresses that place without creating another cell. Composition of place and value is defined under [construction](#construction).

A callable occurrence has its own structural identity and a `parent` link into its above-method lexical space. Multiple occurrences can reference one immutable method. Graph copying neither creates another method implementation nor changes its signature; state belongs to particular structural occurrences and activations. A nested definition does not capture a caller frame in a hidden environment.

Entering a method neither copies its callable occurrence nor creates another graph. Native and interpreted execution use the callable's complete Structure; source order of `body` operators is preserved. Each activation has a machine frame for formal and hidden inputs, the result, and working values of `var` fields. Changed working values are published in `var` fields under [§12](#dynamic); operators and literals are not rewritten. Recursion executes the same Structure with a separate frame. `merge` may supply a formal's default without binding it. A free name uses an eligible dynamic input first, then a lexical source; temporary frame values add no graph nodes.

The `args`, `return`, `var`, and `body` parts belong to one Structure; `var` is neither another value graph nor a hidden call environment. A program may also explicitly separate data and code through `call: code data` without creating implicit fields.

A named Structure has no explicit arguments, but it still receives hidden inputs. When it executes, a free name follows the same rule as in any called procedure: the current caller first, then an eligible lexical source ([§12](#dynamic)). The value is local to the activation; assigning to the bare name does not write back to its source. Named Structures have no separate free-name resolution mode.

The distinction also holds within one Structure: `a: int()` creates a typed place, while a later `a: get_a()` computes and stores a new value when reached. On method construction the place is determined in `var`; accounting for it in advance does not execute the `body` operator. Keeping these parts in one graph does not make them interchangeable.

Callable selection starts from an explicit reference, structural path or textual path with an explicitly supplied root. Selecting an implementation and providing its arguments are distinct actions. The selected candidate undergoes [admission](#admission); the call must then receive every signature input. A suitable method field does not by itself supply its dynamic inputs. Transporting a method as data is not invoking it.

Positional actual arguments precede named ones. After the first named argument, subsequent arguments must also be named. An unknown name, duplicate assignment to one argument, missing required argument or ordering violation is an error. A named argument's body is supplied as a structural value when that is the receiving expression's specified mode; it does not become an arbitrary sequence of immediate calls. In argument position a bare callable name denotes a reference to its occurrence, not its execution result. If the receiver requires a result, the actual argument must contain an explicit call of a value-returning callable (`f()` or `f: ()` for a nullary method), followed by ordinary conversion and admission; demanding a result does not itself invoke bare `f`. A callable without a result, including `sub`, can be passed by reference to an appropriate place but cannot supply a result value. Bare `return` means only exit and does not make a callable value-returning. A bodyless `fn` remains an interface descriptor and may be passed by reference, but direct execution gains no invented body.

A formal parameter with a provided default value remains part of the full accepted interface. When no argument is supplied explicitly, that value is used; when one is supplied explicitly, the supplied argument is used after the ordinary conversions and admission. Having a default neither removes the formal nor turns it into a free dynamic input: a same-named value in the caller's context does not become a supplied argument -- supplying it takes an ordinary call with the argument. These rules do not depend on whether the parameter's data came through `merge` ([§20](#composition)): the same meaning results from writing such an argument directly and from ordinary composition of its data. A value that does not fit the contract is not equated with an absent argument and is not replaced by the default silently; zero is a supplied value too. The source of the default and the argument value of the current activation are distinct: supplying `y: 25` for one call does not change later calls, and a value left in a working cell by a previous execution does not become a default by itself -- only an ordinary explicit operation on the state the default is taken from changes it. Neither an argument nor an admissible default -- the ordinary call refusal.

The syntactic boundaries of the function name, `args`, result description, `var`, and `body` are defined in the [grammar](LMX_grammar.en.md). An empty Frame Structure-body has zero fields; bare `f:` without an argument or explicit closure is invalid. Descriptions and signatures create no implicit call, currying, or closure.

In an executable body, a headless form is an ordinary expression, neither an error nor a special call form. This covers lone `2`, bare `f`, the sequence `2 + 2`, anonymous Structures `(f)` and `(2 + 2)`, and empty `()`. Their fields are resolved and evaluated in lexical order by the same expression mechanism; a result without a destination is discarded. An anonymous Structure containing several fields, including Frames and headless expressions, retains the execution order of all fields; bounded and corresponding vertical spellings do not select different operations. Bare `f` reads the resolved value or a reference to a Structure or method without calling it. Explicit `f()` or `f: ()` supplies an empty argument Structure to the resolved head: for a method this is a nullary call under its contract, for an ordinary Structure it is a structural declaration or assignment; executing that Structure is written `call: f`. The receiver's contract still applies in argument position (§10, above), but the mere presence of a name never starts a call. Literal `2` does not declare a type for `f: 2`. Empty `()` is a valid present empty Structure with no inner expressions. Neither parentheses nor discarding a result bypasses ordinary resolution, admission, or unknown-name diagnostics.

Named `fm` results are fields of an already existing result Structure. `return` completes their updates and forwards that Structure; the control transfer itself neither allocates nor copies it. Multiple values in the `return` tail populate signature-defined fields of the same Structure. Exact surface unpacking forms require a separate profile rule.

Function-name assignment shorthand, such as `square: x * x` inside `square`, is admitted only if the receiving `fn` defines a same-named local result slot. It does not replace the persistent callable reference. Without that contract the form is rejected. Structural closing with `end: f` adds no implicit value return; explicit `return: value` is the core form.

A returned reference preserves its exact target identity. Constructing a result, if necessary, belongs to evaluation of the returned expression, not the transfer operation. Returning from a nested function ends its activation, not automatically the entire actor. Publication and cleanup ordering is defined under [exits](#exits).

@@ dynamic | Динамические входы и рабочее состояние | Dynamic inputs and working state | 7.3.1–7.4.3; 21.1–21.8; 21.10–21.12
[RU]
Следует различать хранилище объявленного значения в полной Structure, рабочее значение текущей активации, явный формальный аргумент и динамический вход. Эти значения имеют разные правила изменения; рабочая копия не создаёт второго постоянного графа. Обычная передача изменяемого примитива копирует значение, структуры и массива — ссылку; особая идентичность неизменяемого значения сохраняется согласно [квалификации](#qualification).

Для свободного имени вызываемое выражение получает текущее значение из доступного контекста вызывающего выражения; при его отсутствии используется допустимый лексический поиск по `node`. Внутренние собственные объявления и формальные параметры имеют свои разрешённые места, а не ищутся в глобальном реестре. Список необходимых сквозных имён входит в сигнатуру: добавление свободного имени меняет интерфейс. При отсутствии необходимого входа вызов недопустим; молчаливое создание нуля или нового поля запрещено. Формал вызываемого — не свободное имя его тела: он получает поданный аргумент или своё значение по умолчанию ([§11](#callables)), и приоритет источников ниже на пропущенный формал не распространяется.

Приоритет источников свободного имени: ближайшая текущая локальная привязка вызывающего выражения, затем уже унаследованный им динамический вход, затем лексический поиск вызываемого выражения. Локальная привязка включает используемое собственное поле, формальный аргумент, результат или иное локальное значение, определённое принимающим выражением. Требования статически известных вызовов распространяются до неподвижной точки, в том числе через взаимную рекурсию. Имя, нужное только следующему вызову, также должно сохраняться и передаваться; само по себе это не создаёт поле графа. Отсюда следует: метод, который сам потребляет имя, формирует значение своей активации из этих же источников, включая собственный лексический поиск, и это сформированное значение входит в его доступный контекст: вызываемое им получает его, каким бы источником оно ни было дано. Метод, который имя только пересылает, ничего не формирует: вход, пришедший отсутствующим, идёт дальше отсутствующим, и конечный потребитель использует собственный лексический поиск. Присваивание имени меняет только значение этой активации, а явное чтение `node\x` привязки не создаёт.

Если имя потребляется данной активацией, в том числе в аргументе явного `throw`, выбранное значение удерживается при входе в неё, до того как операторы тела или входная загрузка собственных полей смогут изменить источник. Более позднее изменение источника через явный путь не обновляет значение голого входа. Это действует и при выборе лексического запасного источника вызываемого; имя, лишь передаваемое следующему вызову, заранее не читается и локального значения не получает. Объявление вложенного вызываемого не исполняется при входе во внешнюю активацию: его свободные входы формируются лишь при его собственном вызове.

Лексический поиск следует реальным связям Structure до нулевого родителя и выбирает единственное поле нужного имени на соответствующем уровне ([имена](#fields)). `independent` отсекает внешний лексический запасной путь. Явные `node\x`, `reference\x` и `array[index]` обращаются к графу, не подменяясь динамическим `x`; контекст, скопированный `merge`, участвует лишь как запасной путь ([композиция](#composition)).

Рабочее значение собственного поля загружается для активации из `var` вызываемого вхождения. Присваивание такому имени меняет рабочее значение и отмечает его `dirty`; контрольная точка публикует его в том же поле `var`. Загрузка и чтение сами ничего не помечают. При входе загружаются только поля, действительно используемые телом голыми именами: явная запись по пути меняет ячейку графа, а голое имя продолжает читать рабочее значение до собственной записи. Явная запись через ссылку наблюдаема через другие ссылки. Формальный или скрытый аргумент остаётся значением активации, а не полем `var`, и запись в него не возвращается вызывающему.

Присваивание обновляет уже разрешённое место; оно не создаёт поле во время исполнения. Вычисляемая инициализация записывается отдельно: `i: int()` задаёт место без придуманного значения, `i: findValue()` присваивает результат при достижении строки. Оба оператора остаются в графе; вызов не исполняется при построении. Известное значение `i: int: 5` заполняет поле при создании вхождения, в том числе невызванного метода, но не исполняет `body`. Предварительная компоновка `var` учитывает собственные поля тела, не перемещая инициализаторы; уже созданная Structure не получает новые слоты при исполнении.

Локальность и длительность хранения различаются. Поле `var` вызываемого вхождения хранит опубликованное значение после активации; рабочее значение активации снаружи не видно. Путь `M\var\x` адресует опубликованную ячейку, не меняя поле над-методного пространства или аргумент вызывающего. Внешнее поле меняется только явной записью через `node\x`, где `node` — лексическое пространство над методом.

Ссылочная глубина задаётся общим ресивером `@` внутри значения места: `ptr: @: Model: 0` создаёт типизированную нулевую ссылку, а `ptr: Model` использует адрес уже известной Structure. Для ссылки без требования Structure сохраняется void-тип; последующая запись адреса не выполняет структурный `implements`, поскольку требование отсутствует, но проверяет представление и глубину. Для типизированной ссылки другой референт проходит обычный допуск. Голые `Model` и `Other` обозначают разрешённые ссылки, не скрытые вызовы; ссылочное значение не копирует референт, а `merge` перенаправляет внутренние ссылки общей картой.


Structure хранится по ссылке. Если `x` — графовое объявление LMX Structure, её дескриптор `D` хранится как значение ссылочного слота `S` (`void *`) в графе: `x` читает `D` из `S`, а `@x` адресует сам `S` (концептуально `Lmx **`, физически `void **`), не копируя дескриптор. При сохранении `@x` в явной ссылочной привязке отдельная типизированная ячейка `P` пула ссылок хранит адрес `S`; `P`, `S` и `D` не отождествляются. Следование этой ссылке достигает того же референта `D`, но `x` и `@x` имеют разную адресную глубину: запись нового допущенного референта через `@x` меняет `S` и последующее чтение `x`, не содержимое прежнего `D`. Буквальное `@x\field` по нынешнему приоритету означает `@(x\field)`; способ написать проход через `@x` к полю определяется правилами путей, а не этим равенством адресов. Для формала Structure адресуется его собственная ячейка активации, не графовый слот. Для Array, также хранимого ссылкой на дескриптор, действует тот же принцип. Для примитива `@` адресует его типизированную ячейку; для элемента массива — ячейку элемента, включая ссылочную. Глубина не схлопывается; адресуется реальное стабильное хранилище, не временная копия, кеш или ABI-буфер. Проекция и сроки жизни описаны в [L2 §18](L2_spec_ru.md#lowlevel-address).

Передача и return значения переносят это значение; @x явно передаёт адрес его хранилища. Непримитивы не становятся C-valued. L3 не предоставляет числового адреса, машинного cast, сырой памяти или адресной арифметики. Ссылки на ссылочные ячейки допустимы как переносимые ссылки, но не продлевают время жизни своих целей.

Перед передачей управления другому вызываемому выражению публикуются только собственные рабочие поля с активной отметкой `dirty`. После публикации отметки очищаются. Граница публикации — вызов, который может опубликовать или выпустить состояние, вызвать пользовательский код, войти в Message повторно или передать управление за пределы активации; неопределённый внешний вызов считается границей консервативно; приватный не-выпускающий помощник, служащий только обходу текущей активации, классификации адреса или явной графовой операции, — не граница, даже если он читает или пишет граф (источник 21.6). Так же публикуют все выходы — сквозной конец тела, `return`, `throw`, неуспешный `assert`, остановка и отмена — и приостановка `yield`. Неизменённое кэшированное поле без такой отметки не записывается обратно: вложенный вызов мог уже изменить его через явную ссылку. После возврата вызывающая активация не перечитывает свои рабочие значения из графа. Невозможность разрешить или записать связанное поле — диагностический `assert`; предназначенный внешний вызов после этого не выполняется. Общей транзакции с откатом предыдущих записей нет.

`dirty` определяется выполненной записью, не сравнением значений и не наличием возможного присваивания в исходном тексте; это семантическое состояние рабочих значений, а не обязательное физическое поле-флаг у каждой переменной: нативный транслятор может знать статически, что кэшированный локал изменён, и эмитировать запись на контрольной точке, интерпретатор — держать бит или битовую карту. Публикация следует прямому порядку полей; успешная запись очищает отметку соответствующего поля. Публикация нужна также перед внешней границей, способной вызвать LMX обратно или раскрыть состояние графа.

Следовательно, после вложенного изменения `node\x` рабочее голое `x` вызывающего выражения может сохранять прежнее значение, тогда как явный путь видит новое. Позднейшее присваивание голому собственному `x` намеренно создаёт новую запись и опубликует её на следующей границе. Отсутствие автоматического перечитывания — часть семантики, а не разрешение терять отмеченные изменения.

<a id="activation-history"></a>
### Стек активаций, рекурсия и явная история

Стек активаций является единственной неявной историей вызовов. Нативное исполнение использует обычный стек вызовов C; интерпретатор — эквивалентный управляющий стек. Прямая, взаимная и callback-рекурсия создаёт отдельную активацию с собственными формальными и динамическими значениями, рабочими локальными значениями, результатом и отметками `dirty`. Повторный вход в то же вызываемое вхождение исполняет ту же Structure: объявленные ячейки остаются на своих местах, отдельный экземпляр полей не создаётся. Скрытый узел активации, окружение замыкания или глобальная запись активного аргумента не создаются.

Вызываемое вхождение хранит опубликованное состояние объявленных полей, но не журнал вызовов. Активации одного вхождения имеют отдельные рабочие значения над теми же ячейками: приостановленная внешняя активация не перечитывается и сохраняет свои рабочие значения; после возврата её чистое own-поле не публикуется без нового реального изменения. Другое, явно созданное вызываемое вхождение того же метода имеет свои поля. Итог определяет последовательный порядок публикаций только `dirty`-полей, а не восстановление снимка.

При повторном входе в то же вхождение S обе активации используют одни объявленные ячейки, но разные рабочие значения. Если внешняя активация опубликовала `x = 2` перед внутренним вызовом, а внутренняя затем опубликовала `x = 9`, внешняя после возврата всё ещё читает своё рабочее 2; её чистый кэш не перезаписывает опубликованное 9. Только новая запись внешней активации отметит её `x` как `dirty` и опубликует новое значение. `@x` обеих активаций адресует одну реальную ячейку объявления, а динамический аргумент остаётся локальным значением активации.

Фактические аргументы вызова вычисляются в значения до публикации `dirty`-полей на границе вызова. Поэтому аргумент, прочитанный по явному пути из графа, может получить ещё прежнее опубликованное значение, а аргумент, прочитанный голым именем, — новое рабочее; последующая публикация не меняет уже вычисленные аргументы.

Одна логическая последовательная полоса исполнения каждого Message делает эту модель безопасной без блокировок и барьеров памяти внутри такта. Приостановленные активации не участвуют в гонке; другие Message работают со своими аренами. Интерпретатор реализует ту же семантику управляющим стеком возвратов, аргументов, локалов и рабочих значений; полное состояние метода при вызове или повторном входе не копируется. Создаётся обычный кадр активации, и только используемые own-поля загружаются в его рабочие значения; дополнительный экземпляр прототипа или графа не создаётся.

Тело, переданное принимающему выражению как структура, и аргументы исполняемого вызова также не становятся общим скрытым окружением.

Публикация обязательна на границах вызова, возврата, `throw`, диагностического прекращения и `yield`. Выход с `finally` имеет две публикации, описанные в [выходах](#exits). `retry` и локальный переход цикла сами по себе не создают новую активацию и не перечитывают поля. Сигнатуры и граф сохраняют требования этой модели независимо от того, исполняется ли граф интерпретатором или транслируется.
[EN]
Value storage at a declaration in the complete Structure, a working value of the current activation, an explicit formal argument and a dynamic input must be distinguished. They have distinct mutation rules; a working copy does not create a second persistent graph. Ordinary passing copies a mutable primitive's value and a Structure or Array's reference; the special identity of an immutable value is retained under [qualification](#qualification).

For a free name, the called expression receives the current value from the caller's available context; if unavailable, permitted lexical lookup follows `node`. Own declarations and formal parameters have their respective resolved locations rather than being searched in a global registry. Required through-names are part of the signature: adding a free name changes the interface. A missing required input makes the call inadmissible; silently creating zero or a new field is prohibited. A callable's formal is not a free name of its body: it receives the supplied argument or its default value ([§11](#callables)), and the source priority below does not extend to an omitted formal.

A free name's sources have this priority: the caller's nearest current local binding, then its already inherited dynamic input, then the callee's lexical lookup. A local binding includes a used own field, formal argument, result or another receiver-defined local value. Statically known call requirements propagate to a fixed point, including through mutual recursion. A name needed only by the next call must still be retained and forwarded; forwarding alone creates no graph field. It follows that a method which itself consumes the name forms its activation's value of it from these same sources, its own lexical lookup included, and that formed value belongs to its available context: what it calls receives it, whichever source gave it. A method that only forwards the name forms nothing: an entry that arrived absent travels on absent, and the eventual consumer uses its own lexical lookup. Assigning the name changes that activation's value only, and an explicit `node\x` read forms no binding.

For a name consumed by this activation, including in an explicit throw's payload, the selected value is held at activation entry, before its body's statements or own-field entry load can change the source. A later explicit path mutation of the source does not refresh the bare input. This also applies when the selected source is the callee's lexical fallback; a name merely forwarded to another call is not eagerly read or given a local value. A nested callable's definition is not an executed step of the enclosing activation: its free inputs are formed at its own call, not when the enclosing body is entered.

Lexical lookup follows real Structure links to a zero parent and selects the sole field of the required name at the relevant level ([names](#fields)). `independent` cuts the external lexical fallback. Explicit `node\x`, `reference\x` and `array[index]` address the graph rather than being replaced by a dynamic `x`; a context copied by `merge` participates only as fallback ([composition](#composition)).

An own field's working value is loaded for the activation from the callable occurrence's `var`. Assigning that name changes the working value and marks it `dirty`; a checkpoint publishes it to that same `var` field. Loading and reading do not themselves mark it. Only fields actually used by bare names in the body are loaded on entry: an explicit path write changes the graph cell, while the bare name keeps reading its working value until its own write. An explicit reference write is observable through other references. A formal or hidden argument remains an activation value, not a `var` field, and writing it does not copy back to the caller.

Assignment updates an already resolved place; it creates no field during execution. Computed initialization is written separately: `i: int()` establishes a place without an invented value, and `i: findValue()` assigns the result when that statement executes. Both operators remain in the graph; construction does not run the call. A known value, `i: int: 5`, fills the field when the occurrence is created, including an uncalled method, but does not execute its `body`. Preliminary `var` assembly includes the body's own fields without moving initializers; an already constructed Structure gains no slots during execution.

Locality and storage duration differ. A callable occurrence's `var` field retains its published value after activation; the activation's working value is not visible outside. `M\var\x` addresses the published cell without mutating the above-method field or the caller's argument. Only an explicit `node\x` path changes that outer field, where `node` is the space above the method.

Reference depth is supplied by the common `@` receiver inside a place's value: `ptr: @: Model: 0` creates a typed null reference, whereas `ptr: Model` uses an already known Structure's address. A reference with no Structure requirement remains void-typed; writing an address to it later performs no structural `implements` check because it has no such requirement, but still checks representation and depth. A typed reference admits another referent by the ordinary rule. Bare `Model` and `Other` denote resolved references, not hidden calls; a reference value does not copy its referent, and `merge` redirects internal references through the shared map.


A Structure is stored by reference. If `x` is a graph-declared LMX Structure, its descriptor `D` is held as the value of a graph reference slot `S` (`void *`): `x` reads `D` from `S`, while `@x` addresses `S` itself (conceptually `Lmx **`, physically `void **`) without copying the descriptor. When `@x` is retained in an explicit reference binding, a separate typed pointer-pool cell `P` holds the address `S`; `P`, `S` and `D` are distinct. Following that reference reaches the same referent `D`, yet `x` and `@x` have different address depths: writing a newly admitted referent through `@x` changes `S` and subsequent reads of `x`, not the former `D`. Under the present precedence, literal `@x\field` means `@(x\field)`; spelling the route through `@x` to a field is governed by path rules, not by equating these addresses. A Structure formal instead addresses its own activation cell, not a graph slot. The same rule applies to an Array held by descriptor reference. For a primitive, `@` addresses its typed cell; for an Array element, its element cell, including a reference cell. Depth is not collapsed: the target is real stable storage, not a temporary copy, cache or ABI buffer. Projection and lifetimes are defined in [L2 §18](L2_spec_en.md#lowlevel-address).

Passing or returning a value transports that value; @x explicitly transports its storage address. Nonprimitives do not become C-valued. L3 exposes no numeric address, machine cast, raw memory or address arithmetic. References to reference cells are admissible portable references but do not extend their targets' lifetimes.

Before control passes to another callable expression, only own working fields with an active `dirty` mark are published. Marks are cleared after publication. A publication boundary is a call that may publish or escape state, invoke user code, re-enter the Message or transfer control outside the activation; every uncertain external call is treated conservatively as one; a private, non-escaping helper used only for the current activation's own traversal, address classification or explicit graph operation is not a boundary, even if it reads or writes the graph (origin 21.6). Every exit -- fallthrough of the body, `return`, `throw`, a failing `assert`, stop and cancellation -- and `yield` suspension publish the same way. A cached field without such a mark must not be written back: a nested call may already have changed it through an explicit reference. After return, the caller activation does not reload its working values from the graph. Failure to resolve or store into a bound field uses diagnostic `assert`; the intended outbound call is not executed afterward. There is no general transaction rolling back earlier writes.

Dirty state follows an executed write, not value comparison or the presence of a possible assignment in source; it is semantic working-state information, not a mandatory physical flag field per variable: a native translator may statically know that a cached local was modified and emit the store at the checkpoint, while an interpreter may keep a bit or a bitmap. Publication follows forward field order; a successful write clears the corresponding mark. Publication is also required before a foreign boundary capable of calling back into LMX or exposing graph state.

Consequently, after a nested modification of `node\x`, the caller's bare working `x` can retain its earlier value while an explicit path observes the new value. A later assignment to bare own `x` deliberately creates a new write and publishes it at the next boundary. No automatic reload is part of the semantics, not permission to lose dirty changes.

<a id="activation-history"></a>
### Activation stack, recursion and explicit history

The activation stack is the sole implicit call history. Native execution uses the ordinary C call stack; the interpreter uses an equivalent control stack. Direct, mutual and callback recursion creates a distinct activation with its own formal and dynamic values, working locals, result and `dirty` marks. Re-entry into the same callable occurrence executes the same Structure: declared cells remain at their declaration sites, with no separate instance of the fields. No hidden activation node, closure environment or global active-argument record is created.

The callable occurrence holds the published state of its declared fields, not a call journal. Activations of one occurrence have separate working values over the same cells: a suspended outer activation is not reloaded and keeps its working values; after the inner return its clean own field is not published without a new real change. Another explicitly constructed callable occurrence of the same method has its own fields. The result is determined by the sequential order of publications of `dirty` fields only, not by restoring a snapshot.

On re-entry into the same occurrence S, both activations use the same declared cells but distinct working values. If the outer activation published `x = 2` before an inner call and the inner one later published `x = 9`, the resumed outer activation still reads its working 2; its clean cache does not overwrite the published 9. Only a new outer write marks its `x` dirty and publishes another value. `@x` in both activations addresses the same real declaration cell, whereas a dynamic argument remains activation-local.

Actual call arguments are evaluated into values before dirty-field publication at the call boundary. An argument read through an explicit graph path may therefore receive an earlier published value while one read through a bare name receives the new working value; later publication does not change arguments already evaluated.

One logical serial execution lane per Message makes this model safe without locks or memory barriers within a turn. Suspended activations take no part in a race; other Messages work in their own arenas. The interpreter implements the same semantics with a control stack of returns, arguments, locals and working values; the method's full state is not copied on a call or re-entry. An ordinary activation frame is created and only the used own fields are loaded into its working values; no additional prototype or graph instance is created.

A body supplied to a receiving expression as a Structure and an executable call's arguments likewise do not become one hidden environment.

Publication is required at call, return, `throw`, diagnostic termination and `yield` boundaries. An exit with `finally` has the two publications specified under [exits](#exits). `retry` and local loop transfers do not by themselves create a new activation or reload fields. Signatures and the graph retain this model's requirements whether the graph is interpreted or translated.

@@ branches | Ветвления и циклы | Branches and loops | 10; 19.1–19.9; 19.14; 19.16
[RU]
Управляющие принимающие выражения определяют способ потребления своих структурных тел. Принадлежность к телу не означает обязательное немедленное выполнение всех его полей. Метки управления обозначают видимые цели перехода; упоминание метки само по себе не вызывает тело и не является неявным `goto`.

`if` вычисляет условие один раз и исполняет тело при истинном результате. Непосредственно следующий `else` на том же уровне исполняется только при ложном результате. Вставка другого оператора между ними нарушает пару. Профильный `branch` с именованными ветвями может существовать отдельно и не заменяет этот контракт.

`match` выбирает подходящую ветвь по выраженным шаблонам. Ветви могут задаваться парами «шаблон — тело» или явными структурами согласно профилю; `default` является определённым профилем шаблоном, а не универсальным эффектом произвольного имени. Объединение шаблонов и требование исчерпывающего покрытия задаются контрактом. Автоматического проваливания в следующую ветвь нет, если оно явно не определено.

`while` проверяет условие перед каждой итерацией и может ни разу не выполнить тело. Закрывающий `until` задаёт проверку после тела: тело выполняется хотя бы один раз, затем повторяется, пока условие ложно. Анонимное тело с `until` — такой цикл в текущей активации, как всякое управляющее тело; именованная Structure, закрытая `until`, — обычная именованная Structure, чьё исполняемое тело — этот цикл: её объявление цикл не исполняет, исполняет явный вызов. Основной `for` содержит инициализацию, условие, шаг и тело; инициализация выполняется один раз, затем проверка, тело и шаг. Сокращения диапазонов требуют отдельного явно выбранного профиля и не изменяют эту основную форму.

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

`while` checks its condition before each iteration and can execute its body zero times. Closing `until` establishes a postcondition: the body executes at least once and repeats while the condition is false. An anonymous body closed by `until` is such a loop in the current activation, as any control body; a named Structure closed by `until` is an ordinary named Structure whose executable body is that loop: declaring it does not run the loop, an explicit call does. Core `for` contains initialization, condition, step and body; initialization runs once, followed by condition, body and step. Range shorthands require a separately selected profile and do not alter this core form.

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

`catch` — точка приёма в блоке вызывающего выражения, не обычный вложенный `sub`. При первом прямом проходе её тело пропускается. После доставки соответствующего отказа тело выполняется, затем исполнение продолжается с операторов после этого `catch`. Поэтому обработчик, поставленный до вызова, повторно вводит выполнение в последующий участок; обработчик после вызова продолжает за собой. Участок ограничен следующим `catch` того же блока или концом блока. Обработчик действует на все вызовы своего блока, включая вызовы из вложенных в него операторных блоков (`if`, `while`, `for`, анонимный `---`): обработчик, как callable, созданные ресиверами `fn`, `fm`, `sub`, виден во всём своём блоке в обе стороны. Блок-сосед им не покрывается. Это сравнение не распространяет видимость назад на обычные именованные Structure; область правила задана в [видимости объявлений](#declaration-visibility).

Два одноимённых обработчика в одном блоке запрещены; отдельные вложенные блоки могут иметь каждый свой. Доставка выбирает обработчик по блоку вызова, не одноимённый обработчик соседнего блока. Повторный `throw` того же имени внутри обработчика не входит в этот обработчик заново: это отказ во внешнем вызывающем контексте. Необработанное имя распространяется только через соответствующие объявления `throws`.

Операторы языка, у которых программист не видит явного перечисления `throws` (например, `merge`), тоже бросают именованный отказ, но отлавливать его не обязательно: обработчик `catch: merge` — до вызова, после него или в отдельном вложенном блоке — обрабатывает его стандартно, и никуда он не улетает; неотловленный неявный отказ улетает в корень исполняющегося Message, и поток останавливается (`running = 0`). Единственное ограничение размещения — то же, что и для объявленных имён: два одноимённых `catch` не могут спорить на одном уровне.

Если интерпретатор при исполнении корректно построенного графа обнаруживает ошибку самой выполняемой операции, он создаёт обычный неявный отказ с единым именем `interpreter`. Его принимает `catch: interpreter ()` по тем же правилам области действия и распространения, что и другие неявные отказы; отдельного канала исключений интерпретатора нет. Ошибка построения исходного графа при трансляции, повреждённая форма графа и нарушение инварианта ядра не являются таким отказом: это диагностика соответствующей стадии, которую `catch` исполняемой программы не перехватывает.

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

`assert` проверяет диагностический инвариант. Ложное условие порождает `AssertionViolation`, а не восстанавливаемый `throw`; его нельзя поймать обычным `catch`, и оно не входит в `throws`. В акторном профиле диагностическое прекращение выполняет правила публикации рабочих полей и очистки активации из [выходов](#exits) до передачи диагностики корню исполняющегося Message. Message прекращает исполнение и больше не получает тактов. Это не делает неуспешный такт успешным и не разрешает публикацию его ожидающих исходящих писем: они по-прежнему подчиняются [доставке](#delivery). Это не обязательное завершение рабочего потока ОС; остановка исполнения и уничтожение объекта различаются.

Ожидаемые ошибки входных данных обрабатываются явным условием и объявленным отказом, а не диагностической аварией. `log` и `error` записывают наблюдения через выбранный профиль. Само `error` не означает `throw`, `assert`, возврат или остановку. Нелитеральный аргумент разрешается как обычное значение; неизвестное имя не превращается автоматически в строку журнала.
[EN]
`throws` lists names of an expression's possible recoverable exits, not exception types. The caller must provide a `catch` for each name or include it in its own `throws`. A call without either treatment is rejected. Failure detection uses ordinary `if`; module `guard` is not a failure-handling operator.

`throw: Name(arguments)` evaluates an explicit payload and leaves the current activation under the [exit rules](#exits), without returning its declared result. The selected `catch: Name (...)` parameters receive the payload. A handler's repeat call begins a new activation from the start and does not resume the abandoned frame.

`catch` is a landing pad in the caller's block, not an ordinary nested `sub`. Its body is skipped on the initial straight-line pass. When the corresponding failure arrives, its body runs and execution continues with the statements after that `catch`. Consequently, a handler before a call re-enters the following region; a handler after the call continues past itself. The region ends at the next `catch` in the same block or the block's end. The handler covers every call of its block, including calls made from statement blocks nested inside it (`if`, `while`, `for`, an anonymous `---`): a handler, like callables created by the receivers `fn`, `fm`, `sub`, is visible throughout its block in both directions. A sibling block is not covered. This comparison does not extend backward visibility to ordinary named Structures; the rule's scope is defined under [declaration visibility](#declaration-visibility).

Two same-named handlers in one block are prohibited; separate nested blocks can each have one. Delivery selects the handler by the calling block, not a same-named handler in a sibling block. Throwing the same name inside a handler does not re-enter it: this is a failure in the enclosing calling context. An unhandled name propagates only through matching `throws` declarations.

Language operators whose `throws` list the programmer does not see written out (for example `merge`) also throw a named failure, but catching it is optional: a `catch: merge` handler -- before the call, after it, or in a separate nested block -- handles it in the ordinary way and nothing flies anywhere; an uncaught implicit failure flies to the root of the executing Message and the Thread stops (`running = 0`). The only placement constraint is the one declared names have: two same-named `catch` handlers cannot compete at one level.

If the interpreter detects an error in an operation while executing a correctly constructed graph, it raises an ordinary implicit failure with the single name `interpreter`. `catch: interpreter ()` receives it under the same scope and propagation rules as other implicit failures; there is no separate interpreter-exception channel. An error while constructing the source graph during translation, a malformed graph, or a violated kernel invariant is not such a failure: it is a diagnostic of the corresponding stage, which the executing program's `catch` cannot intercept.

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

`assert` checks a diagnostic invariant. A false condition produces `AssertionViolation`, not a recoverable `throw`; ordinary `catch` cannot handle it and it is not part of `throws`. In the actor profile, diagnostic termination follows the activation's working-field publication and cleanup rules in [exits](#exits) before the diagnostic is delivered to the executing Message's diagnostic root. That Message stops executing and receives no further turns. This does not make the failed turn successful or authorize publication of its pending outgoing Messages; those remain governed by [delivery](#delivery). This need not terminate the OS worker; stopping execution and destroying the object remain distinct.

Expected input errors use an explicit condition and declared failure rather than a diagnostic abort. `log` and `error` record observations through the selected profile. `error` alone does not imply `throw`, `assert`, return or termination. A non-literal argument resolves as an ordinary value; an unknown name does not automatically become a log string.

@@ suspension | Повторный запуск и приостановка | Restart and suspension | 7.3; 19.12; 19.15; 21.10
[RU]
`retryable` задаёт повторяемую область. `retry` без имени повторяет ближайшую активную такую область; `retry: label` — указанную. Перед повтором выполняются очистки покидаемой попытки. Переход не откатывает внешние эффекты, изменения графа, уже опубликованные поля или сообщения. Транзакционный откат возможен только как отдельно выраженный протокол над данными.

Сам `retry` — локальный переход текущей активации, не новый вызов и не восстановление скрытого окружения. Текущие рабочие значения продолжают существовать, дополнительной публикации только из-за перехода нет. Если повтор достигает вызова или выхода, действует соответствующая обычная граница. Нагрузка пойманного отказа остаётся явными аргументами обработчика.

`yield` передаёт произведённое значение и приостанавливает активацию. Изменённые (`dirty`) own-поля публикуются перед приостановкой. Явные аргументы, динамические входы, рабочие значения и их последующее состояние сохраняются для возобновления; они не превращаются в поля тела или публичное скрытое окружение. Возобновление не перечитывает их из Structure метода.

Входы производителя фиксируются при начале его активации. Следующий вызывающий `next` не заменяет их своим динамическим окружением. Если `next` реализован отдельным выражением-обёрткой, его входы относятся к его активации, пока явная операция не изменит сохранённое состояние производителя. Представление продолжения и результата итератора не наблюдаемо, если сохраняется описанная семантика.
[EN]
`retryable` defines a restartable region. Unlabelled `retry` repeats the nearest active such region; `retry: label` repeats the named one. Abandoned-attempt cleanups run before restarting. The transfer does not roll back external effects, graph mutations, already published fields or Messages. Transactional rollback requires an explicitly represented data protocol.

`retry` itself is a local transfer in the current activation, not a new call or restoration of a hidden environment. Current working values continue to exist, with no additional publication merely because of the transfer. If repeated execution reaches a call or exit, that boundary's ordinary rules apply. A caught failure's payload remains the handler's explicit arguments.

`yield` transfers a produced value and suspends the activation. Dirty own fields are published before suspension. Explicit arguments, dynamic inputs, working values and their subsequent state are retained for resumption; they do not become body fields or a public hidden environment. Resumption does not reload them from the method Structure.

Producer inputs are fixed when its activation begins. A later `next` caller does not replace them with its own dynamic context. If `next` is a separate wrapper expression, its inputs belong to its activation unless an explicit operation changes the producer's saved state. The continuation and iterator-result representation is not observable when it preserves these semantics.

@@ arrays | Массивы и хранилище | Arrays and backing | 6.1–6.5.5; 12–13; 19.29.3
[RU]
Обычный Array — типизированное значение с устойчивой ссылочной идентичностью. Конструктор `[]` создаёт его при достижении места построения. Поле структуры, хранящее ссылку на массив, не является самим массивом. Передача ссылки не копирует элементы; изменение элемента наблюдаемо через другие ссылки, перепривязка локальной ссылки — нет.

Владеющий массив имеет единый непрерывный прямоугольный блок элементов. Вложенные размерности не означают отдельно выделенные строки. Для формы `[d0, …, dN−1]` число элементов равно произведению размерностей, последний индекс меняется быстрее остальных. Массив ссылок на другие массивы — другое значение, не замена прямоугольного многомерного массива. Примитивные элементы не приобретают лексических родителей.

Общий физический дескриптор Array — `VoidArray {size_t size, void *data}`. В `Lmx {VoidArray array, Lmx *parent, LmxEntry native}` тот же дескриптор вложен по значению первым полем и является самим массивом дочерних физических ссылок; его backing зарегистрирован как адресный диапазон арены, но запись диапазона не является самим `VoidArray`. Отдельный псевдоним `LmxArrayDesc` не нужен. У самостоятельного Array `size` — логическое число элементов, backing содержит ровно столько ячеек. У базового Array нет `capacity`, и он не растёт, не делает resize/append и не переключает backing. Динамическое членство, ёмкость и рост принадлежат только отдельным динамическим дескрипторам вида `{<T>Array array; size_t capacity}`, где `<T>Array` — уже существующий фиксированный дескриптор реального типа элемента T (void — лишь один из типов: `VoidArray` — дескриптор для элементов `void *`; массив int — `{size_t len; int *data}`, без void-дескриптора и без приведений). List (`KIND_LIST`) — публичный такой DynamicArray над элементами `void *`, без скрытого префикса capacity в backing. Физические адреса объектов-ссылок от роста List не зависят; адрес ячейки закрытого backing List не сохраняется через его замену.

`length(array)` читает число элементов из дескриптора Array (`len` у типизированного дескриптора, `size` у `VoidArray`); для прямоугольного массива это общее число, не первая размерность. Дескриптор не хранит размерности и не позволяет восстановить их из общего числа элементов. Число полей содержащей структуры, длина массива и размер служебного пула дескрипторов различаются.

Встроенные машинные типы элементов сохраняют [смысл типов целевого профиля C99](L2_spec_ru.md#lowlevel-scope), включая знаковость обычного `char`; дескриптор не переопределяет их. L3 добавляет проверяемый доступ, а не другое представление примитивов.

Полный индекс N-мерного прямоугольного массива содержит N целочисленных координат. Для прямоугольного массива координаты сводятся к одному линейному индексу элемента, последний индекс меняется быстрее: `k = (...((i0 * d1 + i1) * d2 + i2)...)`. L3 проверяет только итоговый элемент относительно общей длины в дескрипторе: `0 <= k < length(array)`. Каждая координата отдельно с размерностью не сверяется, вектор длин размерностей ради этих проверок не хранится. Например, в прямоугольнике `[2,3]` координаты `[0,3]` дают линейный индекс 3 и выбирают тот же элемент, что `[1,0]`; линейный индекс 6 вызывает неявный `throw: interpreter`, а не возвращает `None`. Вычисление индекса не должно превращать математически выходящий за границы результат в допустимый элемент через машинное переполнение. Массив ссылок на массивы отличается: каждый шаг обращается к другому действительному Array со своим дескриптором.

Соседние индексы `matrix[i][j]` адресуют один ровный массив по известным из описания ша́гам, а `a[i]\[j]` после `\` адресует значение, полученное предыдущим выбором ([пути](#fields)). Дескриптор не восстанавливает размерности и неполная запись индексов сама по себе не создаёт отдельный Array строки или скрытый view-дескриптор. Эти проверки доступа принадлежат только L3, как нативному, так и интерпретируемому: [доступ L2](L2_spec_ru.md#lowlevel-address), включая получение адреса элемента графового массива, работает без них. Проверки операции не являются отдельным механизмом допуска кандидата вместо [анализа и юнит-тестов](#admission).

Копия массива имеет отдельное хранилище; передача ссылки сама по себе его не создаёт. Возврат ссылки не должен скрыто копировать данные для исправления времени жизни. Совместное хранилище сохраняет обычные границы владельца Message.

[EN]
An ordinary Array is a typed value with stable reference identity. Constructor `[]` creates it when execution reaches the construction site. A Structure field holding its reference is not the Array itself. Passing a reference does not copy elements; an element mutation is visible through other references, whereas rebinding a local reference is not.

An owning Array has one contiguous rectangular block of elements. Nested dimensions do not mean separately allocated rows. For shape `[d0, …, dN−1]`, element count is the product of dimensions, with the last index varying fastest. An Array of references to other Arrays is a different value, not a replacement for a rectangular multidimensional Array. Primitive elements acquire no lexical parents.

The common physical Array descriptor is `VoidArray {size_t size, void *data}`. In `Lmx {VoidArray array, Lmx *parent, LmxEntry native}`, the same descriptor is embedded by value as the first member and is the actual array of physical child references; its backing is registered as an arena address range, but the range entry is not the `VoidArray` itself. A separate `LmxArrayDesc` alias is unnecessary. For a standalone Array, `size` is its logical element count and the backing has exactly that many cells. Base Array has no `capacity` and does not grow, resize, append, or switch backing. Dynamic membership, capacity, and growth belong only to separate dynamic descriptors of the form `{<T>Array array; size_t capacity}`, where `<T>Array` is the already existing fixed descriptor of the real element type T (void is only one element type: `VoidArray` is the descriptor for `void *` elements; an int array is `{size_t len; int *data}`, never the void descriptor with casts). List (`KIND_LIST`) is a public such DynamicArray over `void *` elements, with no hidden capacity prefix in the backing. Physical addresses stored as referent values are unaffected by List growth; a List backing-slot address does not survive private-backing replacement.

`length(array)` reads the element count from the Array descriptor (`len` in a typed descriptor, `size` in `VoidArray`); for a rectangular Array this is the total count, not its first dimension. The descriptor does not store dimensions and cannot reconstruct them from the total element count. The containing Structure's field count, Array length and service descriptor-pool size are distinct.

Built-in machine element types retain their [C99 target-profile meaning](L2_spec_en.md#lowlevel-scope), including plain `char` signedness; a descriptor does not redefine them. L3 adds checked access, not a different primitive representation.

A full N-dimensional rectangular Array index contains N integer coordinates. For a rectangular Array, coordinates are reduced to one linear element index in row-major order: `k = (...((i0 * d1 + i1) * d2 + i2)...)`. L3 checks only the final element against the descriptor's total length: `0 <= k < length(array)`. It does not check each coordinate against its dimension or store a vector of dimension lengths for those checks. For example, in a `[2,3]` rectangle, `[0,3]` has linear index 3 and selects the same element as `[1,0]`; linear index 6 raises implicit `throw: interpreter` rather than returning `None`. Computing the index must not wrap an out-of-range mathematical result into a valid element. An Array of references to Arrays is different: each step accesses another actual Array with its own descriptor.

Adjacent indices `matrix[i][j]` address one flat Array using strides known from its description, whereas `a[i]\[j]` addresses the previously selected value after `\` ([paths](#fields)). The descriptor does not recover dimensions, and an incomplete index spelling does not by itself construct a separate row Array or hidden view descriptor. These access checks belong only to L3, whether executed natively or interpreted: [L2 access](L2_spec_en.md#lowlevel-address), including obtaining a graph-backed element's address, works without them. Operation checks do not constitute a separate candidate-admission mechanism in place of [analysis and unit tests](#admission).

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

Копируется полный используемый граф с необходимыми ссылками и лексическими цепочками до нулевого родителя. Одна карта «источник — копия» используется для всех операндов: общие цели остаются общими, циклы сохраняются, ссылки и `parent` явно переписываются. Корни операндов и необходимые лексические предки не добавляются лишними видимыми полями результата. Родительские связи переписываются внутри копии на соответствующие копии исходных узлов; место исполнения `merge` не задаёт нового лексического родителя и не переразрешает имена тела. Для обычных копируемых целей сохранение связей означает, что ссылки результата указывают на соответствующие копии, а не на исходный граф; удержание исходных целей ограничено ссылками на переиспользуемую нативную реализацию и допущенной ветвью `independent: immutable` (ниже), с необязательным `const`. Это правило универсально для любого `merge`, а не частный случай создания дочернего Message, и неявного исключения «общие изменяемые данные» у него нет: раздельные изменяемые экземпляры получают из шаблона-прототипа, инициализируя конкретный экземпляр аргументами; общие неизменяемые значения — ветвь `independent: immutable`; намеренно общее хранилище — Message ([доставка](#delivery)). Поле-ссылка `@: T` — ячейка-указатель, и она копируется вместе со своим указуемым через ту же карту. Сохранение связей внутри копии не связывает аргументы и не меняет приоритет динамических входов.

Ссылка внутри копируемого графа не создаёт отдельного экземпляра своего указуемого. Она переводится через ту же карту на экземпляр, уже полученный копированием и композицией. Например, при `Holder: p: Model` и `R: merge: Model Holder` новый экземпляр первого операнда `Model` составляет результат `R`; скопированная `p` указывает на этот экземпляр, а не создаёт третью копию `Model` и не остаётся ссылкой в исходную арену. Если цель ссылки является другим копируемым узлом, выбирается уже созданная копия именно этого узла. Необходимые лексические предки копируются по тому же правилу: их `parent` и внутренние ссылки переводятся через общую карту, а не через отдельный механизм видимости. Типизированное чтение через переписанную ссылку использует доказанное адресное соответствие, без поиска имён при исполнении.

Обход полного используемого графа сам по себе не даёт доступа к защищённой ветви или полномочия экспортировать её содержимое. Композиция сохраняет [выбранный контракт защиты объекта](#protected-structures); `merge` не является обходным способом открыть защищённый контекст.

Ссылка на переиспользуемую нативную реализацию метода — терминал своего контракта: реализация получает граф, с которым исполняется, и её адрес не есть идентичность этого графа или его лексического окружения; общей ссылкой на изменяемое вызываемое вхождение или его лексический контекст она не является. Когда `merge` встречает [вечную ветвь](#eternal) `independent: immutable` (в том числе с дополнительным `const`), он обязан **не копировать** её, а поместить в результат исходную физическую ссылку — это явное, единственное исключение из общего правила копирования для ветви графа: у её корня нет внешнего лексического родителя, а весь выбранный граф, включая сохранённые ссылки, прошёл проверку неизменяемости до публикации. Если эту гарантию установить нельзя, построение/квалификация получает отказ; одной метки недостаточно, а копирование не является запасным вариантом при неуспешной квалификации. Право на исключение даёт сочетание `independent` с `immutable`; дополнительный `const` действует по своему контракту, но не является условием удержания. Одна `independent`, один нулевой родитель или одна `immutable` права на удержание не дают. Действуют существующие контракты квалификации и срока жизни, нового флага, ресивера или реестра нет. Физическая идентичность сохраняется, владельцем остаётся исходный модуль. Реализация и вечная ветвь — разные виды удерживаемого материала, даже когда оба называются терминалами. Видимость и учёт индекса диапазонов выполняются внутри merge/классификатора; это не отдельная видимая операция и не альтернатива `merge`. Остальное изменяемое использованное состояние получает отдельное хранилище. Алгоритм не оставляет ссылки на изменяемую чужую арену.

### Слоты модели, совпадение и порядок полей

Первый операнд — модель результата. Поле более позднего операнда или дописанного тела, совпадающее с полем модели (совпадение известно при трансляции — имя и тип; допуск как при присваивании), записывается **в слот модели**, а не добавляется рядом; поле без соответствия дописывается в конец в порядке операндов. Результат имеет раскладку модели, за которой следуют новые поля, поэтому номера полей модели не сдвигаются, и никакого скрытого смещения у методов нет. Операнд вида `имя: значение`, как `v: 9` в `merge(Model; v: 9)`, — именованный аргумент по общей модели «голова и аргументы»: он записывается в слот модели `v` типом этого слота; это не определение Structure `v` и не примитив с типом, выведенным из значения.

### Композиция структурных частей

Structure вызываемого `fn`, `fm`, `sub` или `catch` содержит адресуемые части `args`, `return` там, где результат предусмотрен, `var` и `body` ([§11](#method-parts)). Обычная Structure участвует как одно структурное значение; `merge` компонирует соответствующие части рекурсивно по общему правилу слотов модели. Поля `var` остаются данными того же вызываемого вхождения, а операторы `body` — его кодом: безымянные операторы не сопоставляются с полями по имени и не склеивают два машинных тела в одну функцию. Новый набор полей результата рассчитывается до выделения его фиксированного `Lmx`. Вложенный метод остаётся полем внешней Structure и сам собой не исполняется; свободный вход соблюдает приоритет [§12](#dynamic).

### Явное описание вызываемого

Объявленный заголовок вызываемого задаёт требование принимающего места, а не дополнительный операнд `merge`. Результат `merge` проходит обычные преобразования и [допуск](#admission). Более короткое описание места не удаляет формалы кандидата и не меняет ABI его тела. Значение `y: 5`, явно добавленное к `args` методом `merge`, становится значением формала `y` по умолчанию: `y` можно опустить или передать явно, в том числе как `0`; одноимённое значение вызывающего не подставляется вместо отсутствующего формала. Свободные имена тела разрешаются по [§12](#dynamic). Подробный [разбор примера](LMX_semantics_guide.ru.md#callable-description) вынесен из спецификации.

### Нативная реализация и копия вызываемого вхождения

`native` относится к выбранному исполняемому телу, а не к операции `merge`. Неизменный текст `body` сам по себе не разрешает переиспользовать старую реализацию: должны быть доказаны совместимость используемых адресов и типов полей, карта code→data, сигнатура, результат и выходы. При таком доказательстве реализация получает граф новой копии; иначе выбирается реализация нового тела либо интерпретатор, если оно принадлежит L3. Реализации методов не склеиваются. Вложенное вызываемое вхождение копируется как Structure по общему правилу (кроме [вечной ветви](#eternal)); общий адрес реализации не означает общего изменяемого графа.

Различие физических позиций полей не отменяет выбранную нативную реализацию: таблица успешного `implements` переводит адреса полей принимающего описания в адреса полей кандидата. При последовательных композициях соответствия составляются. Таблица не является отдельным графом, не ищет имена во время исполнения и сама не выбирает исполняемое тело.

### Возвращаемый вложенный метод

Возвращаемый вложенный метод строится тем же `merge`: данные активации входят в новую копию, а реализация неизменённого кода переносится только после проверки её адресного контракта выше. Объявленное описание результата проверяет готовое вызываемое вхождение обычным [допуском](#admission), не становится третьим операндом. Скопированное значение свободного имени даёт лексический запасной путь, а значение формала — умолчание; приоритет [§12](#dynamic) не меняется. Скрытого окружения замыкания или частичного применения нет.

<a id="factory-reference-result"></a>

Ресивер `@:` может вычислить вызов фабрики и сохранить ссылку на возвращённый метод; определение именованного тела само фабрику не исполняет. Сохранённый указатель `add5` вызывают как `add5(1)` или `(\add5)(1)`; `\add5(1)` разыменовывает уже возвращённый результат. Перед результатом не добавляют унарное `@`: оно обозначает адрес хранимой ссылки. [Развёрнутый пример](LMX_semantics_guide.ru.md#factory-result) находится рядом.

### Динамические источники и лексический запасной путь

`merge` не связывает аргументы и не меняет приоритет [динамических входов](#dynamic): свободное имя берётся от вызывающего прежде скопированного лексического запасного пути. Явный `node\…` обращается к лексическому контексту непосредственно. Это действует и для независимой или вечной ветви. [Пример разрешения](LMX_semantics_guide.ru.md#dynamic-fallback) вынесен отдельно.

Неуспех — throw с именем `merge` (как у любого оператора, в котором программист не видит явного перечисления `throws`): отлавливать его не обязательно; неотловленный улетает в корень, и поток останавливается (`running = 0`); найденная точка обработки `catch: merge` — до вызова, после него или в отдельном вложенном блоке, по правилам [объявленных отказов](#exceptions) — обрабатывает его стандартно, и никуда он не улетает. Отдельного протокола частичного результата нет. Это не обещание отката побочных эффектов вычисления операндов. Правила освобождения временного хранилища принадлежат владельцу Message. Точный низкоуровневый механизм — [L2](L2_spec_ru.md#copy-merge).

Описание типа, схема, данные модуля или таблица являются обычными данными: применение к ним `merge` не выбирает особый алгоритм композиции дескрипторов. `table` материализует явно выбранное табличное представление; `join` создаёт новый табличный граф, не меняя операнды. Политики строк, ключей, конфликтов и приоритета задаёт табличная операция, не структурное правило поиска поля.

Передача владения уже существующим хранилищем при доставке Message — [другая операция](#delivery), без копирования и без переподчинения структурного `parent`. Сочетание политик допуска — также не `merge`: оно выбирает и проверяет явно переданные данные, не строит структурную копию по умолчанию.
[EN]
`merge` is an executable operation over live structural operands. It is neither a preprocessor include, C-type composition nor mutation of source values. Operands are evaluated once left-to-right; a fresh root is then built with direct fields in operand and appended-body order. A previous `merge` result can itself be an operand.

The complete used graph is copied with required references and lexical chains to a zero parent. One source-to-copy map spans all operands: shared targets remain shared, cycles are preserved, and references and `parent` links are explicitly rewritten. Operand roots and necessary lexical ancestors do not become extra visible result fields. Parent links are rewritten inside the copy to the corresponding copies of the source nodes; the place that executes `merge` neither supplies a new lexical parent nor re-resolves the body's names. For ordinary copied targets, preservation of relationships means that the result's links refer to the corresponding copied objects, not to the original graph; retention of original targets is limited to reusable native implementation references and the admitted `independent: immutable` branch (below), with optional `const`. The rule is universal for every `merge`, not a special case of child Message creation, and it has no implicit shared-mutable exception: separate mutable instances come from a prototype template, initializing the concrete instance through arguments; shared immutable values are an `independent: immutable` branch; deliberately shared storage is a Message ([delivery](#delivery)). A reference field `@: T` is a pointer cell, and it is copied together with its pointee through the same map. Preserving relationships inside a copy does not bind arguments or change dynamic-input precedence.

A reference inside the copied graph does not create an extra instance of its pointee. The same map redirects it to the instance already produced by copying and composition. For example, with `Holder: p: Model` and `R: merge: Model Holder`, the new instance of the first operand `Model` forms the result `R`; copied `p` points to that instance, neither creating a third copy of `Model` nor retaining an address into the original arena. If a reference targets another copied node, it selects that node's already-created copy. Required lexical ancestors follow the same rule: their `parent` links and internal references are redirected through the common map, not through a separate visibility mechanism. Typed access through the redirected reference uses proved address correspondence, with no runtime name lookup.

Traversal of the complete used graph does not itself grant access to a protected branch or authority to export its contents. Composition preserves the [selected object-protection contract](#protected-structures); `merge` is not an alternative route for opening a protected context.

A reference to a method's reusable native implementation is a terminal under its contract: the implementation receives the graph with which it executes, and its address is not the identity of that graph or of its lexical environment; it is not a shared reference to a mutable callable occurrence or to its lexical context. When `merge` encounters an [eternal branch](#eternal) qualified `independent: immutable` (including one additionally qualified `const`), it MUST **not copy** it and MUST place the original physical value reference directly into the result -- the explicit, single exception to the general copying rule for a graph branch: its root has no external lexical parent and its entire selected graph, including stored references, has passed the immutable preflight before publication. If that guarantee cannot be established, construction/qualification is refused; a merely labelled branch is not retained and copying it is not a fallback for failed qualification. The combination of `independent` and `immutable` grants the exception; `const` has its own contract but is not required for retention. Neither `independent` alone, a null parent alone, nor `immutable` alone grants retention. The existing qualification and lifetime contracts apply, and there is no new flag, receiver or registry. Physical identity is preserved and the source module remains the owner. An implementation and an eternal branch are different kinds of retained material, even where both are called terminals. Range-index visibility and bookkeeping occur inside merge/classification; they are neither a separate visible operation nor an alternative to `merge`. Other used mutable state receives distinct storage, and the algorithm leaves no references into another mutable arena.

### Model slots, field matching and ordering

The first operand is the result's model. A field of a later operand or of the appended body that matches a model field (the match is known at translation: name and type; admission as for assignment) is written **into the model's slot**, not added beside it; a field with no counterpart is appended at the end in operand order. The result has the model's layout followed by the new fields, so the model's field indices never move and methods carry no hidden offset. An operand of the form `name: value`, as `v: 9` in `merge(Model; v: 9)`, is the named argument under the common head/argument model: it is written into the model's slot `v` with that slot's type; it is neither a definition of a Structure `v` nor a primitive whose type is inferred from the value.

### Composition of structural parts

A callable `fn`, `fm`, `sub`, or `catch` Structure contains addressable `args`, `return` where a result is specified, `var`, and `body` parts ([§11](#method-parts)). An ordinary Structure participates as one structural value; `merge` recursively composes corresponding parts under the common model-slot rule. `var` fields remain the same callable occurrence's data, while `body` statements remain its code: nameless statements are not matched to fields by name and do not splice two machine bodies into one function. The result's new field set is determined before allocating its fixed-size `Lmx`. A nested method remains a field of its enclosing Structure and does not execute by itself; a free input retains [§12](#dynamic) priority.

### Explicit callable descriptions

A declared callable header constrains the receiving place; it is not another `merge` operand. The `merge` result undergoes ordinary conversions and [admission](#admission). A shorter place description neither removes the candidate's formals nor changes its body's ABI. A value `y: 5` explicitly added to `args` by `merge` becomes formal `y`'s default: `y` may be omitted or explicitly supplied, including as `0`; a same-named caller value is not substituted for an omitted formal. The body's free names follow [§12](#dynamic). A detailed [walkthrough](LMX_semantics_guide.en.md#callable-description) is kept outside the specification.

### Native implementation reuse and copied callable occurrences

`native` belongs to the selected executable body, not to the `merge` operation. Unchanged `body` text alone does not authorize reuse of an old implementation: compatibility of used field addresses and types, the code→data map, signature, result, and exits must be proved. With that proof the implementation receives the new copy's graph; otherwise a matching implementation of the new body or, for L3, the interpreter is selected. Method implementations are not spliced together. A nested callable occurrence is copied as a Structure under the common rule (except an [eternal branch](#eternal)); sharing an implementation address does not share mutable graph storage.

Different physical field positions do not by themselves invalidate the selected native implementation: a successful `implements` table maps receiving-description field addresses to candidate field addresses. Correspondences compose across successive compositions. The table is not another graph, performs no runtime name lookup, and does not itself select the executable body.

### Returned nested methods

A returned nested method is built by the same `merge`: activation data enters a new copy, while unchanged code retains its implementation only after the address-contract proof above. The declared result description checks the completed callable by ordinary [admission](#admission); it is not a third operand. A copied free-name value provides lexical fallback, whereas a copied formal value provides a default; the priority of [§12](#dynamic) is unchanged. There is no hidden closure environment or partial application.

<a id="factory-reference-result"></a>

The `@:` receiver can evaluate a factory call and retain a reference to the returned method; defining a named body does not itself execute the factory. The stored pointer `add5` is called as `add5(1)` or `(\add5)(1)`; `\add5(1)` dereferences the returned result instead. Unary `@` is not added before the result: that would address the stored reference. A [worked example](LMX_semantics_guide.en.md#factory-result) is separate.

### Dynamic sources and the lexical fallback

`merge` does not bind arguments or change [dynamic-input](#dynamic) priority: a free name comes from the caller before the copied lexical fallback. Explicit `node\…` selects the lexical context directly. The same rule applies to independent and eternal branches. A [worked example](LMX_semantics_guide.en.md#dynamic-fallback) is separate.

Failure is a throw named `merge` (as for every operator whose `throws` list the programmer does not see written out): catching it is optional; an uncaught one flies to the root and the Thread stops (`running = 0`); a handling point `catch: merge` -- before the call, after it, or in a separate nested block, under the rules of [declared failures](#exceptions) -- handles it in the ordinary way and nothing flies anywhere. There is no separate partial-result protocol. This does not promise rollback of operand-evaluation effects. Temporary-storage release follows the owning Message's rules. The exact low-level mechanism is in [L2](L2_spec_en.md#copy-merge).

A type description, schema, module data or Table is ordinary data: applying `merge` does not select a special descriptor-composition algorithm. `table` materializes an explicitly selected table representation; `join` creates a new table graph without mutating operands. Row, key, conflict and priority policies belong to the table operation, not structural field lookup.

Ownership transfer of existing storage during Message delivery is a [different operation](#delivery), without copying or changing the structural `parent`. Admission-policy combination is likewise not `merge`: it selects and checks explicit data without default structural copying.

@@ registries | Таблицы, запросы, связывание и провайдеры | Tables, queries, linking and providers | 19.18; 19.21–19.27; 19.30
[RU]
Registry, Table, RegistryView, схема и политика — роли обычных значений, не дополнительные категории или пространства имён. Операция получает корень реестра явно либо по выраженной ссылке. Наличие таблицы или строки с ключом `class`, `type`, `provides`, `satisfies` само по себе не запускает поиск и не меняет язык.

В табличном профиле первый столбец — ключ строки; `columns` задаёт имена и явные метаданные. Число ячеек плотных строк кратно числу столбцов, отсутствующая ячейка выражается явно; выравнивание текста полей не добавляет. Необязательное `source` запрашивает проекцию профиля транслятора, а не объявляет runtime-имена из ячеек. Ячейка может ссылаться на данные, ключ, описание, политику, диагностику, свидетельство, провайдера или вызываемое выражение.

Текстовый динамический запрос начинает с переданного корня и имён его упорядоченных детей; он не заменяет уже разрешённые структурные ссылки. Правила запроса, переменные, унификация, продолжения, приоритеты и конфликты принадлежат явно выбранным данным и политике потребителя, не общему правилу поиска поля Structure. Сохранённый результат проверки содержит явные зависимости и не даёт бессрочного разрешения будущим вызовам. Выбор кандидата проходит [общий допуск](#admission); ранжирование и публикация результата — отдельные явные действия.

Связывание модуля разрешает только явно выбранные операции и рецепты построения в физические ссылки. Провайдер, кодек и правило понижения выбираются выраженной ссылкой, конфигурацией либо переданной Table; план удерживает выбранную ссылку. Смена провайдера явна. Автоматического сканирования каталогов, процесс-глобального поиска, публикации новых имён запросом или отдельной операции импорта нет; графовую композицию выполняет `merge`. Формат хранения таблиц и ранжирование неоднозначных запросов требуют выбранного профиля. [Примеры таблиц и провайдеров](LMX_semantics_guide.ru.md#tables-and-registries) находятся рядом.

<a id="source-codec"></a>
### Восстановление исходного кода: toLmx

`toLmx` восстанавливает исходный код из [интерпретируемого дерева](L2_spec_ru.md#interpretable-tree), отдельной [таблицы имён](#fields) и сохранённых комментариев. Для дерева, построенного из исходника, отличие результата — только каноническое форматирование эквивалентных форм грамматики. Состав, вложенность и порядок конструкций, полный текст и структурное положение комментариев сохраняются. Поля `var`, добавленные предварительной компоновкой, не превращаются в выдуманные исходные объявления: источник и вычисленные места различаются по происхождению, без имён в runtime-графе. Имена извлекаются из таблицы; комментарии не исполняются. Нативное тело не разрешает сокращать представление: пересказ, список лишь данных и декомпиляция машинного кода не заменяют `toLmx`.

`fromLmx` разбирает текст по общим правилам языка. Переносимое сохранение передаёт содержимое и идентичности, но не образ памяти с нативными адресами, состоянием аллокатора и внешними дескрипторами. Для них требуются отдельные политики ресурсов без потери исходных конструкций, имён и комментариев.
[EN]
Registry, Table, RegistryView, schema, and policy are roles of ordinary values, not additional categories or namespaces. An operation obtains a registry root explicitly or through an expressed reference. Merely having a Table or a row keyed `class`, `type`, `provides`, or `satisfies` triggers no lookup and changes no language rule.

In the table profile, the first column is the row key; `columns` supplies names and explicit metadata. Dense-row cell counts are divisible by column count, absent cells are expressed explicitly, and text alignment adds no fields. Optional `source` requests a translator-profile projection rather than declaring runtime names from cells. A cell may refer to data, a key, description, policy, diagnostic, evidence, provider, or callable expression.

A dynamic textual query begins at its supplied root and its ordered children's names; it does not replace already resolved structural references. Query rules, variables, unification, continuations, priorities, and conflicts belong to explicitly selected data and the consumer's policy, not to the general Structure-field rule. A saved check result carries explicit dependencies and grants no indefinite permission for future calls. Candidate selection uses [ordinary admission](#admission); ranking and publishing a result are separate explicit actions.

Module linking resolves only explicitly selected operations and construction recipes to physical references. A provider, codec, or lowering rule is selected by an expressed reference, configuration, or supplied Table; a plan retains the selected reference. Changing providers is explicit. There is no automatic directory scan, process-global search, implicit publication of new names by a query, or separate import operation; `merge` alone composes graphs. Table-storage format and ambiguous-query ranking require a selected profile. [Table and provider examples](LMX_semantics_guide.en.md#tables-and-registries) are adjacent.

<a id="source-codec"></a>
### Source-code reconstruction: toLmx

`toLmx` reconstructs source from the [interpretable tree](L2_spec_en.md#interpretable-tree), separate [name table](#fields), and retained comments. For a source-built tree, the only difference is canonical formatting of equivalent grammar forms. Construct composition, nesting, order, and the full text and structural placement of comments are preserved. `var` fields added by preliminary assembly do not become invented source declarations: source constructs and computed places retain distinct provenance, with no names in the runtime graph. Names come from the table; comments do not execute. Native code cannot abbreviate its representation: a summary, data-only list, or machine-code decompilation does not replace `toLmx`.

`fromLmx` parses text under the ordinary language rules. Portable persistence conveys content and identities, not a memory image of native addresses, allocator state, and foreign descriptors. Those require separate resource policies without losing source constructs, names, or comments.

@@ memory | Владение, достижимость и срок жизни | Ownership, reachability and lifetime | 19.29.0–19.29.5; 19.29.8–19.29.14
[RU]
Каждый Message, исполняющийся или нет, владеет одной логической ареной изменяемых данных. Арена может включать несколько непересекающихся областей; это не дополнительные арены исходного языка. Вызов, блок, обработчик, ветвление и повторная попытка не создают своих семантических арен. L3 не выбирает арену аргументом операции.

Лексическая вложенность, владение памятью и достижимость — разные отношения. В одной арене может быть несколько лексических деревьев. При передаче владения блоками их адреса и `parent` сохраняются; новый владелец не становится автоматически лексическим родителем и не получает неявную прикладную ссылку на каждый принятый объект.

Живость определяется достижимостью, не членством в списке блоков. Корни включают корень Message, активные структурные аргументы, удерживаемые собственные поля, результаты, ссылки формальных и динамических входов, продолжения и явно сохранённые прикладные/служебные ссылки. Обход следует типизированным рёбрам графа, необходимым родителям, связи массива с backing и ссылочным элементам. Вспомогательный индекс имён не является корнем.

Живые узлы и дескрипторы не перемещаются. Рост добавляет хранилище, не инвалидируя опубликованные ссылки. Лексический выход не уничтожает достижимый возвращённый объект; возврат не требует скрытого копирования или «продвижения» дерева. Стабильный адрес, однако, не гарантирует вечную жизнь недостижимого объекта.

В конце каждого такта выполняется один локальный проход сбора: определить исход такта, опубликовать успешные исходящие сообщения либо отбросить неуспешную подготовку, отпустить завершённые входные/временные корни, собрать арену владельца. Обычный возврат, `break`, `continue`, `retry`, `redo` и пойманный `throw` не являются отдельными точками сбора. Сохранившееся приостановленное продолжение удерживает свои ссылки.

Принятый граф, на который приложение не сохранило ссылок, после снятия временных корней может быть собран уже в конце такта, кроме лексически объявленных ветвей `independent: immutable` (с `const` или без него): их владелец сохраняет до удаления всей арены (§23). Передача арены не превращает прочий граф в вечный корень. Удерживаемая история отказа живёт по своей явной политике. Уничтожение Message в итоге освобождает его оставшееся хранилище; сбор не обходит чужую изменяемую арену и не требует глобальной блокировки.

Внешний ресурс имеет отдельный контракт владения, удержания, освобождения и передачи. `copy`, сериализация и `merge` не придумывают дублирование нативного ресурса. Неизменяемость его идентификатора не продлевает жизнь ресурса. Физический сборщик, типизированные пулы и регистрация областей описаны в [L2](L2_spec_ru.md#arena) и [L1](L1_spec_ru.md#arena).
[EN]
Every Message, executing or not, owns one logical arena of mutable data. It can contain multiple disjoint regions; these are not additional source-level arenas. Calls, blocks, handlers, branches and retries do not create their own semantic arenas. L3 does not select an arena through an operation argument.

Lexical nesting, storage ownership and reachability are distinct relationships. One arena may contain multiple lexical trees. Transferring block ownership preserves addresses and `parent`; the new owner neither becomes the lexical parent automatically nor gains an implicit application reference to every adopted object.

Liveness follows reachability, not block-list membership. Roots include the Message root, active structural arguments, retained own fields, results, formal/dynamic input references, continuations and explicitly retained application/service references. Tracing follows typed graph edges, necessary parents, Array-to-backing links and reference-valued elements. The auxiliary name index is not a root.

Live nodes and descriptors do not move. Growth adds storage without invalidating published references. Lexical exit does not destroy a reachable returned object; return requires no hidden copy or tree promotion. A stable address, however, does not guarantee indefinite life for an unreachable object.

One local collection pass runs at each end-of-turn: determine the outcome, publish successful outgoing Messages or discard failed staging, release completed input/temporary roots, and collect the owner's arena. Ordinary return, `break`, `continue`, `retry`, `redo` and caught `throw` are not separate collection points. A surviving suspended continuation retains its references.

An adopted graph with no application-retained references can be collected at end-of-turn once temporary roots are released, except for lexically declared `independent: immutable` branches (with or without `const`): their owner retains them until the entire arena is destroyed (§23). Arena transfer does not make other graphs permanent roots. Retained failure history lives under its explicit policy. Destroying a Message ultimately releases its remaining storage; collection neither scans another mutable arena nor requires a global lock.

A foreign resource has a separate ownership, retention, release and transfer contract. `copy`, serialization and `merge` do not invent native-resource duplication. Immutability of its identifier does not extend resource lifetime. The physical collector, typed pools and region registration are described in [L2](L2_spec_en.md#arena) and [L1](L1_spec_en.md#arena).

@@ eternal | Вечные ветви и общие методы | Eternal branches and shared methods | 9.1.4; 19.29.6; 19.29.9
[RU]
Совместная квалификация `independent: immutable` задаёт запечатанную неизменяемую независимую ветвь: у её корня `parent = 0`, содержимое и защищённые привязки неизменяемы. `const` можно добавить, но для сохранения адреса при `merge` и срока жизни до удаления арены он не требуется. Такая ветвь может быть лексически объявлена и внутри обычного тела, не только в корне Message. Владелец удерживает каждое её созданное вхождение до уничтожения всей своей арены, даже если обычный окружающий граф позже перестал на него ссылаться. Для начального лексически известного модуля владение ареной R0 даёт срок хранения до завершения процесса. Сама квалификация не выбирает глобального владельца и не определяет выгрузку будущего модуля. Ни одна из двух квалификаций отдельно не даёт этого контракта общего использования.

Начальная сборка процесса может создать известный трансляции неизменяемый типизированный массив физических ссылок на такие ветви и явно передать его корневому Message. Этот массив служит доступу и передаче известных ссылок, а не является условием удержания всех лексически объявленных ветвей в их арене. `merge` и создание Message не пополняют и не наследуют этот массив автоматически. Размещение ссылки в массиве не переподчиняет лексическое дерево ветви. Допустимая инициализация значениями времени выполнения происходит до публикации и не увеличивает множество записей.

Начальная сборка может разместить опубликованные ветви и удерживающие их запечатанные типизированные диапазоны в арене Root Thread (`R0`) тем же способом, которым типизированные массивы создаются в арене любого L3 Thread. Срок процесса получается из явного владения и удержания R0, а не из скрытой таблицы, особого класса хранилища или способности, доступной только корню. Сборщик не освобождает эти явно удерживаемые начальные диапазоны; ссылка на ветвь в другом Message является внешним терминалом для его сборщика и не переносит владение.

Принадлежность значения типу вечной ветви устанавливается тем же индексом типизированных диапазонов адресов, что и принадлежность другим физическим типам. Её запечатанный диапазон остаётся в обычной арене явного владельца; срок жизни задают удержание владельцем до уничтожения арены и запрет преждевременного сбора, а не отдельное постоянное хранилище. Перед переносом Message к новому надзирающему родителю проверяется иерархия Message: владелец каждой ветви `independent: immutable`, используемой переносимым Message или его потомками, должен остаться соответствующим Message либо одним из его новых Message-предков. Если владелец выпадет из этой цепи, перенос отказывается **до** изменения членства и ссылки на родителя: прежняя цепочка взаимного контроля больше не гарантировала бы существование арены владельца на протяжении жизни перенесённого Message. Перенос, сохраняющий это условие, не запрещается лишь из-за существования ветви. Здесь речь о надзирающем `Thread.parent` и сроке жизни арен, а не о структурном `Lmx.parent`, языковом `node` или лексической видимости имён. Эти правила не заменяют классификацию по диапазону и не являются флагом отдельной ветви.

Переподчинение имеет явную форму `adopt: msg newParent`: `msg` — переносимый Message с исполняющим Thread, `newParent` — новый надзирающий Message с Thread. Оно не копирует ветви и не маскирует отказ. Если предварительная проверка владельцев не проходит, операция даёт обычный неявный отказ `adopt`, который принимает `catch: adopt ()`; до отказа ни членство в `Thread.children`, ни `Thread.parent` не меняются. Подготовка `independent: msg newParent` — отдельная явная операция: она копирует в арену `msg` только те фактически используемые им или его потомками вечные ветви, владельцы которых не остались бы в новой цепи предков, и перенаправляет соответствующие ссылки на копии. Она не переподчиняет Message. Копии сохраняют свойства `independent: immutable`, а общие ссылки и циклы сохраняются одной картой исходных адресов к копиям; частичная публикация при ошибке запрещена. Ветви, не мешающие именно этому переносу, остаются по прежним адресам. После подготовки `adopt: msg newParent` проходит обычную предварительную проверку заново. При неудаче подготовки действует обычный неявный отказ `independent`, без изменения опубликованного графа.

Известные записи методов — переиспользуемые нативные реализации, не вызываемые вхождения — также могут быть явно собраны в неизменяемый типизированный массив той же арены и переданы через физические ссылки. Дополнительный индекс вместе со ссылкой не образует идентичность записи. Метод не хранит лексического родителя; его конкретное вызываемое вхождение предоставляет собственную структуру. Разделяемые записи остаются живы после завершения заимствующего дочернего Message, только если их явный владелец продолжает их удерживать. Скрытого глобального или корневого реестра методов нет.

R0 удерживает неизменяемые независимые ветви начального модуля только потому, что владеет этим лексически фиксированным модулем, порождает начальных детей и может явно передать им заранее известные физические ссылки. Позднее подключённый DLL-подобный модуль имеет собственные запечатанные типизированные диапазоны у своего владельца и в своей арене. Когда `merge` встречает его `independent: immutable` ветвь, с `const` или без него, потребитель получает в результате исходную физическую ссылку, а модуль остаётся владельцем. Это не превращает R0 в глобальное хранилище. Выгрузка такого модуля и срок жизни его диапазонов здесь не определены.

`merge` и создание Message сохраняют явно переданные ссылки на допущенные вечные ветви — по исключению квалифицированной ветви ([композиция](#composition)) — и на переиспользуемые нативные реализации методов как терминалы; обычное изменяемое вызываемое вхождение и его лексический контекст этим не разделяются, а копируются. Получение одной ветви не раскрывает массив удержания, настройки корня или остальные ветви. Изменяемое состояние по-прежнему копируется отдельно. Все ссылки внутри опубликованной вечной ветви должны иметь достаточный срок жизни; квалификация не делает случайную ссылку на освобождаемую память вечной.

Например, A и созданный из его шаблона B могут иметь один адрес вечной E и разные ячейки изменяемого x — это задуманное исключение для вечной ветви, а не ошибка псевдонимов. Завершение A и B не освобождает E. Одинаковое содержимое двух отдельно построенных ветвей не означает их автоматического интернирования. При переносе в другой процесс нативный адрес не становится сетевой идентичностью: нужен явный кодек.
[EN]
Combined qualification `independent: immutable` establishes a sealed immutable independent branch: its root has `parent = 0`, and its contents and protected bindings are immutable. `const` may be added but is not required for address retention by `merge` or lifetime until arena destruction. Such a branch may be lexically declared inside an ordinary body, not only at a Message root. Its owner retains every created occurrence until the entire owning arena is destroyed, even if the ordinary surrounding graph later ceases to reference it. For the initial lexically known module, R0's ownership of that arena gives process-long storage. The qualification itself neither selects a global owner nor defines unloading of a future module. Neither of the two qualifications alone establishes this sharing contract.

Process bootstrap may construct a translation-known immutable typed Array of physical references to such branches and explicitly supply it to the root Message. This Array provides access to and transfer of known references; inclusion in it is not required for retention of every lexically declared branch in its arena. `merge` and Message creation neither append to nor inherit this Array automatically. Placement in the Array does not reparent a branch's lexical tree. Permitted runtime-value initialization occurs before publication without increasing the entry set.

Bootstrap may place the published branches and their retaining sealed typed ranges in the Root Thread's (`R0`) arena through the same mechanism that creates typed Arrays in any L3 Thread arena. Process lifetime follows from explicit ownership and retention by R0, not from a hidden table, special storage class, or root-only capability. Collection does not release these explicitly retained initial ranges; a reference to a branch in another Message is an external terminal for that Message's collector and does not transfer ownership.

Membership in the eternal-branch type is established by the same typed-address-range index used for all other physical types. Its sealed range remains in the explicit owner's ordinary arena; retention until arena destruction and exclusion from premature collection determine its lifetime, not a separate permanent store. Before moving a Message under a new supervising parent, check the Message hierarchy: the owner of every `independent: immutable` branch used by the moved Message or its descendants must remain the corresponding Message itself or one of its new Message ancestors. If an owner would leave that chain, refuse the move **before** changing membership or the parent reference: the former chain of mutual control would no longer guarantee the owner's arena throughout the moved Message's lifetime. A move preserving this condition is not forbidden merely because such a branch exists. This concerns supervising `Thread.parent` and arena lifetime, not structural `Lmx.parent`, the language's `node`, or lexical name visibility. These rules neither replace range classification nor become a flag on each branch.

Reparenting has the explicit form `adopt: msg newParent`: `msg` is the moved Message with an executing Thread, and `newParent` is the new supervising Message with a Thread. It copies no branches and does not mask refusal. If the owner preflight fails, the operation raises the ordinary implicit failure `adopt`, handled by `catch: adopt ()`; neither `Thread.children` membership nor `Thread.parent` changes before that refusal. `independent: msg newParent` is a separate, explicit preparation: it copies into `msg`'s arena only the eternal branches actually used by it or its descendants whose owners would leave the new ancestor chain, and redirects the corresponding references to the copies. It does not reparent the Message. The copies retain `independent: immutable` properties, shared references and cycles follow one source-to-copy map, and partial publication on failure is forbidden. Branches that do not obstruct this particular move retain their old addresses. After preparation, `adopt: msg newParent` performs its ordinary preflight anew. Preparation failure raises the ordinary implicit failure `independent` without changing the published graph.

Known method records -- reusable native implementations, not callable occurrences -- may likewise be assembled explicitly into an immutable typed Array in the same arena and supplied through physical references. A supplementary index alongside the reference does not form record identity. A method stores no lexical parent; its concrete callable occurrence supplies its own Structure. Shared records remain live after a borrowing child Message terminates only while their explicit owner retains them. There is no hidden global or root method registry.

R0 retains immutable independent branches of the initial module only because it owns that lexically fixed module, spawns the initial children, and can explicitly pass their translation-known physical references. A DLL-like module loaded later has its own sealed typed ranges under its own owner and in its own arena. When `merge` encounters its `independent: immutable` branch, with or without `const`, the consumer receives the original physical reference in the result and the module remains the owner. This does not make R0 global storage. This specification does not yet define that module's unload operation or the lifetime of those ranges.

`merge` and Message creation retain explicitly supplied references to admitted eternal branches -- under the qualified-branch exception ([composition](#composition)) -- and to reusable native method implementations as terminals; an ordinary mutable callable occurrence and its lexical context are not shared this way but copied. Receiving one branch does not expose its retention Array, root settings or unrelated branches. Mutable state is still copied separately. Every reference within a published eternal branch must have sufficient lifetime; qualification does not make an arbitrary reference to reclaimable storage eternal.

For example, A and B constructed from A's template can have the same eternal E address and distinct mutable x cells -- the intended eternal-branch exception, not an aliasing defect. Finishing A and B does not release E. Equal contents of separately constructed branches do not imply automatic interning. Across processes a native address is not wire identity: an explicit codec is required.

@@ messages | Message, актор и последовательный такт | Message, actor and serial turn | 19.28.R2.1–19.28.R2.3; 19.29.6
[RU]
Message — изолированный граф с собственным владением. Обычный шаблон или письмо не исполняется и может существовать как самостоятельный минимальный `LmxMsg`. Исполняемый объект, напротив, изначально строится как L3 Thread. Его `LmxMsg message` является первым членом по значению, поэтому Thread и его Message-префикс имеют один физический адрес. Этот общий префикс предоставляет только идентичность и операции Message: он не превращает каждый Message в Thread и не помещает почту, планирование, режим хода либо другие механизмы Thread в `LmxMsg`. Самостоятельный Message нельзя позднее преобразовать на месте в Thread. Точная классификация по диапазонам адресов по-прежнему различает отдельное хранилище Message и хранилище Thread: общий вид Message допускает оба, а доступ к хвосту Thread требует точного типа Thread. Получение письма не создаёт автоматически новый поток или актор. Для запуска отдельного ребёнка нужна явная операция.

При создании `lmx_message` или `lmx_thread` в его собственную арену попадают только данные и физические ссылки, явно переданные создающей операцией. Состояние родителя, таблицы начальной сборки, массивы методов, вечные ветви и ссылки на сервисы не копируются и не наследуются неявно. Обычный L3 Thread может хранить и использовать всё доступное R0, если эти значения переданы ему явно.

Исполняющийся Message имеет FIFO-почту и не более одного активного такта одновременно. За такт потребляется не более одного допущенного входа. Между разными Message возможна параллельность. Пустой ящик не означает завершение фоновой задачи: механизм продолжает проверять почту согласно своему режиму исполнения до условия остановки.

Во время такта один L3 Message исполняется ровно одним потоком ОС; передача другому рабочему потоку возможна только между тактами. У L3 Thread нет режима исполнения: путь каждого вызова определяет дескриптор вызываемого вхождения — с нативным адресом вызов исполняется нативно, без адреса тело (op-дерево графа) исполняет интерпретатор; интерпретироваться может только L3, L2-операции — нет. Один вызов не запускает оба пути для одного Message: диспетчер не повторяет вызов другим путём после ошибки и не подменяет путь, заданный дескриптором, ни по телу, ни по результату предыдущей диспетчеризации. Выбор пути не создаёт копию метода или второй параллельный исполнитель; `implements` и другие принимающие выражения диспетчер сам не запускает.

Одна арена имеет одну полосу записи. Обработчик, локальное управление, планировщик и служебные данные Message изменяются на его полосе. Чужой отправитель не дописывает себя в ready-list владельца и не меняет его прикладные данные. Исключение приёма почты и специальные одноячеечные протоколы управления относятся к механизму Message, не дают общего доступа к чужой памяти.

Родитель управляет только своими непосредственными детьми. Единственный состав этих детей — List (`KIND_LIST`) физических ссылок, удерживаемый непосредственно существующим полем `Thread.children` в арене родителя; планировщик родителя обходит именно его ([L2 §8](L2_spec_ru.md#thread)). Это runtime-членство не дописывает полей в исходную Structure. Цепочка семейных записей, очередь членства менеджера, фиксированный набор слотов или иной параллельный реестр детей запрещены. Локальная политика порядка обхода принадлежит родителю, но не создаёт второй источник членства. Ребёнок аналогично управляет своими детьми. Нет отдельного глобального планировщика языка, общего изменяемого реестра Message или глобальной блокировки управления. Маршрутизатор, если нужен, сам является Message с собственным состоянием.

R0 является обычным L3 Thread в этом дереве и по умолчанию не имеет функций, которых нет у другого L3 Thread. Его родитель-каркас представляет верхний элемент будущего WorldWideMix и связывается с R0 обычным механизмом родителя; это надзор Message, а не лексическая связь `node`. Только сам верхний каркас не имеет родителя, но дополнительных функций от этого не получает. Внешний host-watchdog, а не каркас или R0, задаёт общий срок ожидания закрытия поддерева и завершает процесс ОС, если обычный каскад не достиг безопасной границы. Особого массива детей, иной схемы планирования или числовой идентичности для R0 нет.

L3 Thread — логическая последовательная полоса, не обещание отдельного потока ОС. Возможны собственный поток и выполнение тактов родителем/платформенным адаптером. API и политика отображения задаются реализацией L2; это не разрешает одновременно выполнять два такта одного владельца. Опрос жизнеспособности родителя и собственное обслуживание нужны и актору без детей.

Первоначальный граф процесса принадлежит корневому Message. Служебные данные запуска и начальные настройки удерживаются уже определённым родителем-заглушкой R0; ссылки на настройки и пользовательский ввод передаются явно при входе, без добавления неявных полей в исходный граф программы; последующая координация выполняется сообщениями. Группировка ролей Mix, курсоров, страниц и уведомлений по Message остаётся выбором проектирования: не требуется ни один актор на весь документ, ни отдельный актор на каждую ячейку.
[EN]
A Message is an isolated graph with its own ownership. A plain template or letter is non-executable and may exist as a standalone minimal `LmxMsg`. An executable object is instead constructed as an L3 Thread from the beginning. Its `LmxMsg message` is the first member by value, so the Thread and its Message prefix have the same physical address. This common prefix supplies Message identity and operations only; it does not turn every Message into a Thread or put mail, scheduling, turn mode, or other Thread mechanisms into `LmxMsg`. A standalone Message cannot later be upgraded in place to a Thread. Exact address-range classification still distinguishes standalone Message storage from Thread storage: the generic Message kind admits both, whereas access to the Thread-only tail requires the exact Thread type. Receiving a letter does not automatically create a thread or actor. Launching a separate child requires an explicit operation.

Creating an `lmx_message` or `lmx_thread` places in its own arena only the data and physical references explicitly supplied by the creating operation. Parent state, bootstrap tables, method Arrays, eternal branches, and service references are neither copied nor inherited implicitly. An ordinary L3 Thread can retain and use everything available to R0 when those values are supplied explicitly.

An executing Message has FIFO mail and at most one active turn at a time. A turn consumes at most one admitted input. Different Messages may execute concurrently. An empty mailbox does not finish a background task: its mechanism keeps checking mail according to its execution mode until a stopping condition.

During a turn, one L3 Message executes on exactly one OS thread; transfer to another worker is allowed only between turns. An L3 Thread has no execution mode: each call's path is set by the callable occurrence's descriptor -- with a native address the call executes natively, without one the body (the graph's op tree) is executed by the interpreter; only L3 can be interpreted, L2 operations cannot. One call never runs both paths for one Message: the dispatcher does not retry a call through the other path after a failure and does not override the path set by the descriptor from the body or from a previous dispatch result. Choosing the path neither copies the method nor creates a second concurrent executor; the dispatcher never runs `implements` or other receiving expressions on its own.

One arena has one writing lane. A Message's handler, local management, scheduler and service state are mutated on its own lane. A foreign sender neither appends itself to the owner's ready list nor modifies its application data. Mail admission and designated single-cell control protocols belong to the Message mechanism and grant no general access to foreign memory.

A parent manages only its direct children. Sole membership of those children is a List (`KIND_LIST`) of physical references held directly by the existing `Thread.children` field in the parent's arena, and the parent's scheduler traverses that exact List ([L2 §8](L2_spec_en.md#thread)). This runtime membership does not append fields to the source Structure. A family-record chain, manager membership queue, fixed group of slots, or any other parallel child registry is forbidden. Local traversal-order policy belongs to the parent but does not become a second membership source. Each child likewise manages its own children. There is no separate global language scheduler, shared mutable Message registry, or global management lock. A router, if needed, is itself a Message with private state.

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

Ребёнок проверяет жизнеспособность родителя и после длительного отсутствия ответа начинает собственное упорядоченное закрытие. Принудительное закрытие сверху — аварийный второй путь. Родитель обслуживает физических адресатов из единственного List (`KIND_LIST`) своих прямых детей, удерживаемого `Thread.children` и не выполняет произвольное управление внуками. Каждый ребёнок повторяет каскад для собственного List; закрытие распространяется по семейству, а не сохраняет навсегда освобождённую ветвь.

Работающий ребёнок может пережить закрытие родителя только при явной передаче надзора другому живому родителю с подходящим полномочием. Он сохраняет свою арену, почту и такт; меняется надзор и место в планировании. Это не усыновление памяти. При передаче памяти неисполняющийся источник прекращает отдельную жизнь; новые дети из принятого содержимого принадлежат уже получателю.

Неуспешное остановленное состояние может быть передано родителю без копии и удержано как граф истории отказа; успешная история по умолчанию освобождается. Передача требует остановленного, безопасного для передачи состояния и отсутствия нативных пользователей. Необходимо сохранять различие запроса остановки, фактического выхода, безопасной передачи и освобождения; конкретные флаги и их размещение относятся к [ядру L2](L2_spec_ru.md#message).

Оставшийся без родителя участник закрывается по политике сирот: успешное завершение освобождает его, неуспешная история может сохраняться до явно заданного срока. Эта политика не создаёт второй глобальный реестр или отдельного бессрочного владельца вне Message.
[EN]
An executing Message's `success` is set only by user code: the system never resets it to 0, not even on failure, and never sets it to 1 itself; `success = 1` is a sufficient condition for stopping the Thread at end turn. The system sets `success = 1` only for a plain letter, at its delivery. An empty mailbox is not success. Once `success` is set, the Message's main algorithm receives no next turn; finishing local child maintenance depends on implementation. `running = 0` during execution may be a stop request: physical storage-handoff safety is established by a separate protocol, not inferred from one flag.

A child checks parent liveness and begins its own orderly close after sustained lack of response. Forced closure from above is the second, emergency path. A parent services physical addressees from the sole List (`KIND_LIST`) of its direct children held by `Thread.children` rather than arbitrarily managing grandchildren. Each child repeats the cascade for its own List; closing propagates through the family instead of retaining a released branch forever.

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

Форма `timeout: ms: time: int: 500` использует общую композицию: `time` — место, `int` проверяет значение, а путь данных — `timeout\ms\time`, без поля `int`. Входящий формал с тем же структурным требованием проходит обычные `implements` и связывание аргументов для любой глубины вложенности, местно и через `post`. Значение `time`, переданное обработчику, отличается от настроенного `timeout\ms\time`; отдельной системы типов длительностей нет.

`post`, `sendMessage` и `receiveMessage` опираются на один ящик, одни правила публикации/владения и одну машину вызова. Публичные формы `sendMessage`/`receiveMessage`, отбор по адресу, получение всей доступной почты и `0` как конец итератора сохраняются. Одно письмо не потребляется дважды ручным и протокольным путём; получение письма как данных само не вызывает его содержимое. Исполнение входящего вызова идёт на полосе адресата, а `answer` и обработчики исхода — на полосе отправителя. Сохраняются оба режима Thread (с потоком ОС и без), обычный жизненный цикл до пользовательского `success: 1`, публикация последнего исходящего письма и существующие надзор/остановка; отдельный цикл входа, ящик или таймерный поток для `post` не вводятся.

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

`timeout: ms: time: int: 500` uses the common composition: `time` is the place, `int` checks its value, and the data path is `timeout\ms\time`, with no `int` field. An incoming formal with the same structural requirement uses ordinary `implements` and argument binding at any nesting depth, locally and through `post`. Handler-supplied `time` differs from the configured `timeout\ms\time`; there is no separate duration type system.

`post`, `sendMessage`, and `receiveMessage` use one inbox, one set of publication/ownership rules, and one call engine. The public `sendMessage`/`receiveMessage` forms, address-filtered iterator, all-available-mail option, and `0` end marker remain. One letter cannot be consumed twice by manual and protocol paths; receiving a letter as data does not itself execute its contents. An incoming call runs on the recipient's lane, while `answer` and outcome handlers run on the sender's lane. Both Thread modes (with and without an OS thread), the ordinary lifecycle up to user `success: 1`, final outbound publication, and existing supervision/stopping remain; `post` adds no second entry loop, inbox, or timer thread.

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
