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

Исполнение следует разрешённым ссылкам и позициям бинарного графа, а не исходным именам; диагностическая таблица адресов и имён не участвует в выполнении, см. [имена и пути](#fields). Высокоуровневая операция может иметь явно выбранную машинную реализацию с L3-контрактом, как описано в [границе числовых и машинных операций](#mathematics); это не разрешает произвольный вызов `c.*` из интерпретируемой программы.

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

Execution follows resolved references and positions in the binary graph, not source names; the diagnostic address-to-name table does not participate in execution, as specified under [names and paths](#fields). A high-level operation may have an explicitly selected machine implementation with an L3 contract, as described at the [numeric/machine-operation boundary](#mathematics); this does not authorize arbitrary `c.*` calls from the interpreted program.

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
@@ fields | Имена, пути и повторные вхождения | Names, paths and repeated occurrences | 2.3; 13.1; 14.1; 21.1-2; 21.11
[RU]
Имена разрешают исходные обращения; исполнение следует полученным ссылкам и позициям. Диагностическое соответствие «адрес → короткое исходное имя» не является таблицей связывания переменных, типом или идентификатором исполнения. Конструирование, копирование и вызов не требуют регистрации исходного имени. Анонимные и позиционные значения не нуждаются в синтетических именах.

Структурный путь `object\field\nested` последовательно выбирает поля графа. Наличие каждого перехода и его допустимость определяются выбранным объектом. Вычисляемый путь не заменяется выдуманным статически известным именем. Зарезервированный `node` обозначает лексическое пространство над методом и остаётся одним и тем же во всей его активации; `node\field` начинает явный обход из этого пространства. Голое `field`, полученное по лексическому fallback, передаётся как скрытый аргумент текущей активации и не тождественно явному пути `node\field`.

Путь может содержать безымянный индексный шаг: `a\[i]` выбирает элемент типизированного массива `a`, а `a[i]\[j]\[k]` после каждого `\` обращается к значению, выбранному предыдущим шагом. Поэтому `a[i][j]` — ровная Си-подобная многомерная адресация исходного массива, а `a[i]\[j]` — индексирование массива, полученного как `a[i]`. В шаге `s\[i]name` имя присутствует и индекс выбирает одноимённое вхождение поля Structure; в `a\[i]` имени нет и индекс выбирает элемент Array. Это общий типизированный путь, не отдельная операция «массив массивов». Цепочка может иметь произвольную конечную длину и сочетать поля Structure с индексами Array. Получение элемента примитивного массива даёт примитив, а элемента массива ссылок — соответствующую ссылку. Объект следующего шага задаётся путём, а не угадыванием прямоугольности или восстановлением размерностей.

`node` — зарезервированное слово языка. Его нельзя объявить, затенить, перепривязать или передать как динамическое одноимённое значение, в том числе посредством цитированного написания имени. При понижении это буквально обязательный первый параметр `Lmx *node` (на L1 — `@: Lmx node`): физическая ссылка на лексическое пространство над выбранным методом. Wrapper, closure или объект namespace между исходным `node` и этим адресом не вставляется. В рабочем графе каждое вызываемое вхождение, тело `if`, цикл и другая вложенная Structure отдельно хранит обычную ссылку `parent` на непосредственно объемлющую Structure. Для вызываемого вхождения эта ссылка задаёт над-методное пространство, передаваемое как `node`; ссылки `parent` вложенных тел могут вести по произвольной внутренней цепочке, но не меняют параметр `node` текущей активации. `parent` не является зарезервированным словом или доступным программе псевдонимом: это поле реализации, по которому работают лексическая и динамическая видимость. Голый `field`, пришедший скрытым аргументом, локален по отношению к вызывающему выражению и над-методному пространству. Присваивание `field: value` такому имени обновляет это локальное значение и поля не создаёт — ни при исполнении, ни заранее транслятором; в источник скрытого аргумента запись не идёт, и состояния метода из этого не возникает ([рабочее состояние](#dynamic)). Поле есть только там, где его ставит объявление; объявленное own-поле идёт через рабочую копию и публикацию. Для явного изменения над-методного графа программа пишет `node\field: value`.

| Имя | Где существует | Значение |
| --- | --- | --- |
| `node` | зарезервированное слово L3 и первый ABI-параметр метода | пространство над методом; неизменно для всей активации, включая вложенные тела |
| `parent` | обычное поле каждой `Lmx` Structure рабочего графа | непосредственно объемлющая Structure; различается у метода, `if`, цикла и других вложенных тел |
| `self` | только скрытый ABI-контекст | активная Structure текущего вызова; не слово языка |

Исполнение удерживает физическую ссылку на активную Structure (§12). Это скрытый ABI-контекст, а не новое исходное имя `self`, не второй граф данных и не замена зарезервированного `node`.

Повторные исходные имена сохраняются. Неуточнённое `name` выбирает **последнее** вхождение имени, то есть эквивалентно `[lastIndex]name`; явный селектор `[N]name` нумерует вхождения в лексическом порядке: `[0]name` — первое, `[1]name` — второе. Номер вхождения имени отличается от физического номера поля среди всех полей. `merge` повторных имён не создаёт: одноимённое поле операнда записывается в слот модели (см. [композицию](#composition)). Изменение порядка различных имён не меняет именованный путь; изменение порядка одноимённых вхождений меняет выбранное значение. Вхождение создаёт только объявление: повторное голое присваивание тому же имени пишет в ту же ячейку и вхождением не является.

Число и расположение полей структуры фиксируются при создании. Порядок полей графа строго лексический; порядок выдачи нативного кода не разрешает переставлять поля самого графа. Обновление существующего поля заменяет содержащуюся в нём ссылку; оно не добавляет новое вхождение. Для иного набора полей создаётся новая структура. Операции над массивом следуют собственному контракту и не изменяют это правило структуры.
[EN]
Names resolve source-level accesses; execution follows the resulting references and positions. A diagnostic mapping from address to short source name is not a variable-binding table, a type or an execution identifier. Construction, copying and calls do not require source-name registration. Anonymous and positional values need no synthetic names.

A structural path `object\field\nested` selects graph fields in sequence. Each step's presence and validity are determined by the selected object. A computed path is not replaced by an invented statically known name. Reserved `node` denotes the lexical space above the method and stays fixed throughout that method activation; `node\field` starts explicit traversal in that space. A bare `field` obtained by lexical fallback is supplied as a hidden argument of the current activation and is not identical to the explicit `node\field` path.

A path may contain an unnamed index step: `a\[i]` selects an element of the typed Array `a`, and `a[i]\[j]\[k]` addresses the value selected by the previous step after each `\`. Thus `a[i][j]` is flat C-like multidimensional addressing of the original Array, whereas `a[i]\[j]` indexes the Array obtained as `a[i]`. In `s\[i]name`, a name is present and the index selects a same-name Structure field occurrence; in `a\[i]`, there is no name and the index selects an Array element. This is an ordinary typed path, not a separate array-of-arrays operation. A chain may have any finite length and mix Structure fields with Array indices. Selecting a primitive Array element yields the primitive; selecting a reference Array element yields the corresponding reference. The path determines the next step's target, without guessing rectangularity or recovering dimensions.

`node` is a reserved language word. It cannot be declared, shadowed, rebound or dynamically supplied as a same-named value, including by quoted identifier spelling. In lowering it is literally the mandatory first `Lmx *node` parameter (`@: Lmx node` in L1): the physical reference to the lexical space above the selected method. No wrapper, closure or namespace object is inserted between source `node` and that address. In the working graph every callable occurrence, `if` body, loop and other nested Structure separately holds an ordinary `parent` link to its immediately enclosing Structure. For a callable occurrence that link supplies the above-method space passed as `node`; nested bodies may have an arbitrary internal `parent` chain, but that chain never rebinds the activation's `node` parameter. `parent` is neither a reserved language word nor a program-visible alias: it is an implementation field traversed by lexical and dynamic visibility. A bare `field` supplied as a hidden argument is local with respect to the caller and the above-method space. Assigning that name (`field: value`) updates this local value and creates no field, neither during execution nor by the translator preallocating one; nothing is written into the hidden argument's source, and no method state arises from it ([working state](#dynamic)). A field exists only where a declaration puts it; a declared own field goes through the working copy and publication. Mutating the above-method graph requires explicit `node\field: value`.

| Name | Where it exists | Meaning |
| --- | --- | --- |
| `node` | reserved L3 word and first method ABI parameter | space above the method; fixed for the whole activation, including nested bodies |
| `parent` | ordinary field of every working-graph `Lmx` Structure | immediately enclosing Structure; differs for a method, `if`, loop and other nested bodies |
| `self` | hidden ABI context only | the active Structure of this call; not a language word |

Repeated source names are retained. An unqualified `name` selects the **last** occurrence of the name, i.e. it is equivalent to `[lastIndex]name`; the explicit selector `[N]name` numbers occurrences in lexical order: `[0]name` is the first, `[1]name` the second. A name's occurrence number differs from the physical field index among all fields. `merge` creates no repeated names: an operand's same-name field is written into the model's slot (see [composition](#composition)). Reordering distinct names does not change a named path; reordering same-name occurrences changes the selected value. Only a declaration creates an occurrence: a repeated bare assignment to the same name writes into the same cell and is not an occurrence.

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

Преобразователь — явно выбранное принимающее выражение. Ключ преобразования поступает из явных описаний и их композиции; скрытого перебора всех пар типов нет. Аналитическая проверка не исполняет преобразователь. Если операция требует преобразования, выполняется выбранный вызов; отсутствие ключа не порождает несуществующий преобразователь. Одноимённые ключи подчиняются общим правилам имён: неуточнённое имя выбирает последнее вхождение, `[N]` — другое, а композиция записывает поздний одноимённый ключ в слот модели; какую из нескольких строк с одним ключом выбирает табличная операция — её собственная политика ([таблицы](#registries)).

Численное преобразование сохраняет контракт диапазона назначения: `u16(255) → u8` допустимо при наличии преобразователя, `u16(256) → u8` даёт ошибку диапазона, а не ноль. Округление `1.5 → i32` и потеря точности внутри диапазона требуют отдельного правила численного профиля. Доказанная включённость диапазонов может исключать избыточную машинную операцию, сохраняя семантическое требование. Ошибки формата, диапазона и поведения преобразователя не заменяются положительным ответом `implements`.
[EN]
A value description is an ordinary explicitly accessible Structure. A receiving expression obtains it through an argument or reference. It is not secretly attached to every primitive and is unnecessary for determining a physical type from an address. Names such as `class` and `class.range` denote a particular profile's data, not mandatory global language entities.

The conversion table defines relations between primitive values and their descriptions, not between every pair of Structures or their names. Distinct Structures `A` and `B` share the physical `Lmx` representation in the arena's typed arrays ([L2 §3](L2_spec_en.md#type-by-range)); a name or field composition creates neither a separate physical type nor a one-element array. Whether `B` satisfies requirement `A` is determined by `implements` relative to the Consumer, not by a `B → A` conversion row. Obtaining or transferring a Structure reference likewise requires no converter for each model. Shared physical representation does not remove structural admission, qualifications, or the distinction between a Structure reference and a reference to a reference cell.

A description separates its semantic contract from architecture binding. The contract defines meaning: count, integer, rational, profile-precision number, complex value, atom, address, opaque resource or absence of content. The binding defines width, signedness, range and target spelling. Equal representation does not imply equal contracts: `Boolean` and `int8` may share storage while admitting different values.

Ordinary description fields include `cell`, `semantic`, flags such as `numeric`/`integer`/`floating`/`reference`/`opaque`, `width`, `signed`, `range`, `spelling` and `convert` keys. The profile chooses field names. A range declaration is contract data; satisfaction is established through the [single admission mechanism](#admission), not by the field's presence alone.

The numeric contract chain is flag → nonnegative integer → integer → rational → profile-precision number → complex number. Nonnegative integers include zero. Machine `double` is not the set of all real numbers. Atoms, addresses and opaque resources are separate contracts, not rungs of this numeric chain. `unit` is an empty Structure; `void` denotes no cell content.

Descriptions are composed with ordinary `merge` under the common [occurrence-order rule](#fields). Fields such as `width`, `range` or `spelling` do not automatically create arithmetic methods. Such operations are callable expressions. For example, `u32` combines a nonnegative integer contract, 32-bit representation and range 0…4294967295; `FILE` describes opaque resource identity. A `FILE` word alone does not establish that reading or closing is valid: such requirements are expressed through paths of a `File` Structure.

A converter is an explicitly selected receiving expression. Conversion keys come from explicit descriptions and their composition; there is no hidden search across all type pairs. Analytical checking does not execute a converter. When an operation requires conversion, the selected call is executed; a missing key does not create a nonexistent converter. Same-name keys follow the general rules of names: an unqualified name selects the last occurrence and `[N]` another, and composition writes a later same-name description into the model's slot; which of several rows with one key a table operation selects is that operation's own policy ([tables](#registries)).

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

Таблица преобразований примитивных значений ([§5](#descriptions)), используемая Message, — такие же явные локальные для Message данные. Она не является каталогом совместимости отдельных структур.

Это не скрытый глобальный реестр, и она не разделяется неявно всеми Message.

Концептуально:

```text
Message M
    type bindings:
        a -> int
        b -> String

    conversions:
        int -> double
        double -> int
        Meter -> Foot
        Foot -> Meter
        ...
```

Фактическое представление остаётся обычными Structure, описаниями, отношениями, Table и вызываемыми выражениями LMX. Эта запись лишь иллюстрирует их роль.

Преобразование доступно операции, только когда конкретный Message может достичь соответствующего явно переданного описания/отношения/конвертера по обычным правилам графа.

Отсутствие преобразования в контексте Message не запускает поиск по всему процессу и не заставляет runtime его выдумывать.

### Преобразование и потребление кандидата

Когда Consumer требует примитивное значение описания T, кандидат не обязан исходно иметь тождественное примитивное или семантическое описание, если локальный для Message контекст преобразований явно предоставляет допустимый путь, принимаемый правилами Consumer.

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
double -> double
```

если этот Message явно предоставляет и допускает:

```text
int -> double
double -> int
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

The primitive-value conversion table ([§5](#descriptions)) used by a Message is likewise explicit Message-local data. It is not a compatibility catalogue of individual Structures.

It is not a hidden global registry and is not implicitly shared by all Messages.

Conceptually:

```text
Message M
    type bindings:
        a -> int
        b -> String

    conversions:
        int -> double
        double -> int
        Meter -> Foot
        Foot -> Meter
        ...
```

The actual representation remains ordinary LMX Structures, descriptions, relations, Tables, and callable expressions. This notation only illustrates their role.

A conversion is available to an operation only when the concrete Message can reach the corresponding explicitly supplied description/relation/converter under the ordinary graph rules.

Absence of a conversion from the Message context does not trigger a process-wide search and does not cause the runtime to invent one.

### Conversion and candidate consumption

When a Consumer requires a primitive value of description T, a candidate need not originate with an identical primitive or semantic description if the Message-local conversion context explicitly provides a valid path accepted by the Consumer's rules.

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
double -> double
```

if this Message explicitly provides and admits:

```text
int -> double
double -> int
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
            ∀ u ∈ calls(Consumer, p):
                accepts(iface(aVar.p), supplied(u))
                ∧ formed(aVar.p, supplied(u)) ⊨ descriptor(aVar.p)
                ∧ result_exits_modes(aVar.p) ⊨ expects(Consumer, u)
          )

admitted(aVar, bVar, Consumer) ⇔
    implements(aVar, bVar, Consumer)
    ∧ unit_tests(Consumer) ≠ ∅
    ∧ ∀ t ∈ unit_tests(Consumer):
        run_graph_test(t, aVar, bVar, Consumer) = PASS
```

Полная сигнатура вызываемого листа включает объявленные и динамические входы, их канонические имена, порядок и способы передачи, результат, выбрасываемые значения и целевой ABI. Различаются три понятия: принимаемый интерфейс — всё, что вызываемое способно принять, включая формал с предусмотренным значением по умолчанию ([§11](#callables)); обязательная подача — входы, которые конкретный вызов обязан предоставить; сформированные входы — то, что выбранная реализация фактически получает после явных аргументов, значений по умолчанию и допустимых преобразований. Проверка относительна к Consumer: реальное использование вызываемого `p` в Consumer задаёт аргументы и требования этого использования; принимаемый интерфейс кандидата обязан их принять; недостающие входы кандидата могут быть сформированы его обычными значениями по умолчанию и допустимыми преобразованиями; сформированный вызов должен удовлетворять действительному описанию выбранного вызываемого; результат, выходы и способы передачи должны удовлетворять Consumer. Поэтому равенства одного лишь множества обязательных аргументов недостаточно: `A` с формалами `x` и `y = 5` и `B` с одним `x` оба допускают `f(1)`, но `f(1; y: 25)` принимает только `A`; и обратно, необязательный формал кандидата не обязан входить в ожидаемое описание вызова каждого Consumer только потому, что он входит в принимаемый интерфейс. В формуле (автор, Q49, 2026-09-28): `calls(Consumer, p)` — видимые в дереве Consumer использования `p` как вызова, каждое отдельно, без сведения к одной арности; `supplied(u)` — фактические этого использования, позиционные и именованные, включая явно поданные необязательные; `iface(aVar.p)` — принимаемый интерфейс кандидата; `formed` — сформированные входы после дефолтов пропущенных формалов, допустимых преобразований и обычных источников свободных имён; `descriptor` — действительное описание выбранного вызываемого (имена, порядок, способы передачи, ABI); `expects(Consumer, u)` — результат, выходы и способы передачи, которых требует это использование. Образец `bVar` в проверке вызываемого листа не участвует: его роль — сбор `uses`. Равенство полных неподготовленных сигнатур не требуется и не объявляется: точное удовлетворение описанию после формирования — не разрешение считать различные исходные интерфейсы равными. Необязательный формал не удаляется ни из принимаемого интерфейса, ни из требований тела или ABI реализации — нужное значение получается обычным механизмом вызова до входа. Адреса реализаций могут различаться. Если вызываемое значение только переносится как непрозрачное значение и здесь не вызывается, этот перенос не требует знания его будущих вызовов. Для примитивного листа простое чтение, передача, хранение или возврат являются тонким потреблением; следование по явным полям описания продолжает толстый путь и делает эти поля требованиями.

Неиспользуемые поля и методы `bVar`, значения за неиспользуемыми именами, порядок различно названных полей, невыбранные повторные вхождения, неиспользуемое вложенное содержимое, владение, изменяемость, эффекты и раскладка целевого языка не сравниваются. Пустое `uses(Consumer, bVar)` означает лишь отсутствие структурных требований аналитической части. Неизвестный вычисляемый путь не считается ни доказанным, ни заведомо тонким: он отдельно отмечается как непокрытый анализом.

Сам аналитический предикат не исполняет `aVar`, `bVar`, Consumer, вызываемые методы или преобразователи и не выбирает лучший кандидат среди прошедших. Положительный результат является только первым обязательным этапом. Окончательный допуск `aVar` требует вслед за ним успешного исполнения **всех** юнит-тестов, заданных этим Consumer, интерпретатором уже построенного графа; отсутствие набора тестов не считается успешной runtime-валидацией. В исполнении участвуют физические ссылки на кандидата и проверяющее выражение; исходный текст и runtime-имена не являются входом проверки. Отрицательный аналитический результат означает отсутствие допуска.

Проверка не подменяется сравнением одинаковых физических позиций. Перестановка различно названных полей при сохранении путей не меняет результат. Для повторных имён действует [выбор вхождения](#fields).

Сбор `uses` не расширяет тела всех вызываемых функций, не исполняет вычисляемые имена и не выполняет полный анализ псевдонимов и потока данных кучи.

Диагностика должна различать действительно тонкое использование и невозможность установить используемые пути. Она может показать, какая одноимённая ветвь выбрана после композиции (последняя по общему правилу или явно выбранное вхождение), какие описательные поля не используются и какие требования остались неустановленными. Диагностика не вводит глобальный «строгий режим» и не меняет правила выбора поля.

На реально исполняемом вызове должны быть предоставлены все требуемые входы выбранного выражения. Успешная направленная проверка делает вызов допустимым, но не доказывает одинакового поведения реализаций.

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
            ∀ u ∈ calls(Consumer, p):
                accepts(iface(aVar.p), supplied(u))
                ∧ formed(aVar.p, supplied(u)) ⊨ descriptor(aVar.p)
                ∧ result_exits_modes(aVar.p) ⊨ expects(Consumer, u)
          )

admitted(aVar, bVar, Consumer) ⇔
    implements(aVar, bVar, Consumer)
    ∧ unit_tests(Consumer) ≠ ∅
    ∧ ∀ t ∈ unit_tests(Consumer):
        run_graph_test(t, aVar, bVar, Consumer) = PASS
```

The complete callable-leaf signature includes declared and dynamic inputs, their canonical names, order and passing modes, result, thrown values, and target ABI. Three notions are distinct: the accepted interface -- everything the callable is able to accept, including a formal with a provided default value ([§11](#callables)); the mandatory supply -- the inputs a particular call must provide; the formed inputs -- what the selected implementation actually receives after explicit arguments, defaults and permitted conversions have been processed. The check is Consumer-relative: the Consumer's actual use of the callable `p` imposes the arguments and requirements of that use; the candidate's accepted interface must accept them; missing candidate inputs may be formed by its ordinary defaults and permitted conversions; the formed call must satisfy the selected callable's actual descriptor; the result, exits and passing modes must satisfy the Consumer. Equality of only the mandatory argument set is therefore not sufficient: `A` with the formals `x` and `y = 5` and `B` with `x` alone both permit `f(1)`, but only `A` accepts `f(1; y: 25)`; conversely, a candidate's optional formal need not occur in every Consumer's expected call descriptor merely because it belongs to the accepted interface. In the formula (the author, Q49, 2026-09-28): `calls(Consumer, p)` are the uses of `p` as a call visible in the Consumer's tree, each checked separately, never collapsed to one arity; `supplied(u)` the actuals of that use, positional and named, including explicitly supplied optional ones; `iface(aVar.p)` the candidate's accepted interface; `formed` the inputs after the defaults of omitted formals, permitted conversions and the ordinary sources of free names; `descriptor` the selected callable's actual descriptor (names, order, passing modes, ABI); `expects(Consumer, u)` the result, exits and passing modes that use requires. The exemplar `bVar` takes no part in the callable-leaf check: its role is the collection of `uses`. Equality of complete unprepared signatures is neither required nor declared: exact descriptor satisfaction after formation is not permission to declare distinct original interfaces equal. An optional formal is removed neither from the accepted interface nor from the requirements of the body or the implementation's ABI -- the required value is obtained by the ordinary call mechanism before entry. Implementation addresses may differ. If a callable value is merely transported as opaque data and is not invoked here, that transport does not require knowledge of its future calls. At a primitive leaf, plain reading, passing, storing, or returning is thin consumption; following explicit description fields continues a thick path and makes those fields requirements.

Unused fields and methods of `bVar`, values behind unused names, the order of differently named fields, unselected repeated occurrences, unused nested contents, ownership, mutability, effects, and target-language layout are not compared. Empty `uses(Consumer, bVar)` means only that the analytical stage has no structural requirements. An unknown computed path is neither certified nor classified as known-thin; it is reported separately as outside analytical coverage.

The analytical predicate itself executes none of `aVar`, `bVar`, Consumer, callable methods, or converters, and it does not rank the candidates that pass. A positive result is only the first mandatory stage. Final admission of `aVar` additionally requires the graph interpreter to execute successfully **all** unit tests defined by this Consumer against the already constructed graph; absence of a test set is not successful runtime validation. Execution receives physical references to the candidate and checking expression; source text and runtime names are not validation inputs. A negative analytical result means that admission fails.

Checking is not replaced by matching physical field positions. Reordering differently named fields while preserving paths does not change the result. Repeated names follow [occurrence selection](#fields).

Collection of `uses` does not expand every callee, execute computed names, or perform whole-heap alias and dataflow analysis.

Diagnostics should distinguish genuinely thin consumption from inability to establish used paths. They may show which same-name branch composition selects (the last by the general rule, or the explicitly selected occurrence), which descriptive fields are unused and which requirements remain unresolved. Diagnostics do not introduce a global strict mode or change field-selection rules.

An executed call must receive every input required by the selected expression. A passed directed check makes the call admissible but does not prove equal implementation behavior.

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

Принимающее выражение записывается относительно путей, которые ему действительно нужны. Подходит любая структура, предоставляющая эти пути, допустимые листья и реально вызываемые выражения, проходящие направленную проверку [§7](#admission). Структуры одновременно являются обычными данными, материалом явных описаний и результатами композиции, поэтому контрактом служит используемое дерево. Отдельного объявления параметров обобщённого типа и отдельной операции инстанцирования нет. Проверка используемого дерева является механизмом структурного обобщения LMX, но не обещает всех свойств параметрического полиморфизма.

### 2. Понимание того, что проверяется в данном месте

Consumer определяет область аналитической проверки; неизвестное покрытие отличается от заведомо тонкого потребления. После анализа интерпретатор графа исполняет юнит-тесты того же принимающего выражения. Каждый реальный вызов дополнительно должен получить все требуемые сигнатурой входы. Эти этапы не поглощают друг друга: у них разные входы и область покрытия. Успех не замораживает кандидата или Consumer и не подтверждает будущие способы использования после их изменения.

### 3. Различение смыслов одинаково представимых значений

Различие кодируется именем пути, который действительно использует принимающее выражение. Для `Distance: Meter: 1` обращение `d\Meter` требует именно этого пути; структура только с `Foot` его не предоставляет. Одного внешнего имени `Meter`, поля `unit: "meter"` или квалификатора `const` недостаточно: наличие пути не сравнивает значение его листа. Если значение доступно и неизменно при сборке, анализ может заранее доказать точное равенство, но обязательные тесты остаются частью единого допуска; в остальных случаях содержательное ограничение проверяет тест принимающего выражения.

### 4. Ограничение скалярного листа

Ограничение формулируется явно и включается в тесты. Наличие `x\width` не доказывает `width = 32`: обход описания требует использованных путей, но терминальный скаляр может оставаться тонко потреблённым. Доступные при сборке неизменяемые данные можно предварительно анализировать и сравнивать точно, однако такое доказательство не объявляется альтернативным механизмом runtime-валидации.

### 5. Изменение, видимое другим держателям ссылки

Чтобы изменение увидели другие держатели значения, запись выполняется через явный путь: `p\x: value` или `a[i]: value` меняет выбранный референт. Разрешённое голое `x: value`, направленное в явный либо скрытый аргумент, обновляет локальное значение активации; поля оно не готовит и ничего не публикует. Такая запись остаётся локальной по отношению к источнику: она не меняет аргумент вызывающего выражения и родительский граф. Состояние метода даёт только объявленное поле (`int: x …` в теле), и запись в него идёт через рабочую копию и публикацию. L3-ссылка объявляется отдельным принимающим выражением `@: Type var` и не является взятием адреса локальной переменной; полное правило находится в [рабочем состоянии](#dynamic). Поле не добавляется во время исполнения: состав графа уже зафиксирован транслятором.

### 6. Независимость от изменения другим держателем

`copy:` создаёт независимое изменяемое значение только в пределах собственного контракта копирования; настоящая неизменяемость запрещает изменение защищённого значения. Обычная передача структуры или массива копирует ссылку, не референт, поэтому внутри Message другой псевдоним может изменить общий изменяемый объект. Неизменяемость идентификатора внешнего ресурса не делает неизменяемым сам внешний ресурс.

### 7. Гарантия возможности вызова

Нужны оба условия: совместимость используемых путей и направленная проверка вызываемого выражения по его использованию ([§7](#admission)), а также наличие всех его динамических входов среди локальных значений вызывающего выражения, уже унаследованных входов или непосредственного `node\x` вызываемого вхождения. Пусть A и B предоставляют одинаковый `m`, тело которого использует голое `x`, а Consumer лишь вызывает `m`: проверка используемого вызываемого пути может пройти, но допуск вызова всё равно отвергнет отсутствие `x`. Известный случай отвергается при трансляции, динамически выбранная цель требует соответствующей runtime-границы. Это правило не добавляет разворачивание тела вызываемого выражения в `uses`.

### 8. Проверка передаваемого вызываемого значения

Передача вызываемого значения не является его исполнением и не требует знания всех требований будущего вызова. Проверка выполняется на реальном вызове: выбранное выражение должно пройти направленную проверку [§7](#admission) после обычного формирования входов (необязательные формалы готовятся значениями по умолчанию), получить все динамические входы и пройти применимый допуск, даже если прежняя частичная проверка его не исследовала. Пройденная проверка не означает одинакового поведения.

### 9. Изменение тела метода без нарушения вызовов

Свободные динамические имена тела входят в его интерфейс. Формал с предусмотренным значением по умолчанию — не свободное имя: в `DynRequired` он не входит и остаётся частью принимаемого интерфейса. Добавление нового свободного динамического имени в тело меняет `DynRequired` и соответствующие требования вызова; известные вызывающие выражения требуется проверить заново, динамически выбранные остаются под допуском фактического вызова. Неизменяемость записи метода не делает неизменяемым каждое ссылающееся на неё вхождение и не запрещает явную замену ссылки на совместимое вызываемое значение. Изменение поведения при прежней сигнатуре остаётся вопросом тестов и правильности программы.

### 10. Выбор нужной части композиции

Нужное поле выбирается явно либо строится нужный набор полей. `merge` создаёт новое дерево и не меняет операнды; одноимённое поле более позднего операнда переопределяет слот модели на месте (специализация), новых вхождений того же имени не возникает. Если модель A содержит `read`, а B — тоже `read` совместимого типа, `result\read` — слот A со значением из B; `read` без соответствия в модели дописывается в конец. Аналитическая диагностика может обнаружить непреднамеренный неквалифицированный выбор после изменения импорта или композиции. Исходные части не обязаны быть соседними или статически доступными.

### 11. Изменение существующей структуры

Число полей и их слоты фиксированы. Обычные полевые операции могут заменять содержащиеся в них ссылки `void *`; изменение фактического типа цели подчиняется обычным правилам таких обновлений и последующего потребления. Иное число полей требует новой структуры, например результата `merge`. Не вводится политика разрешения конфликтов для несуществующих операций «удалить или переместить активное поле».

### 12. Надёжное численное преобразование

Используется доступный преобразователь по явному ключу с контрактом диапазона назначения: `u16(255) → u8` допустимо, `u16(256) → u8` — ошибка диапазона, а не ноль. Округление и потеря точности внутри диапазона задаются отдельной политикой численного профиля. Прохождение аналитической проверки не даёт разрешения молча обернуть значение по модулю. Отказ преобразователя на ребре — обычный отказ приёмника; наружу он выходит как неявный именованный отказ этого ребра (`convert`) в методе, которому ребро принадлежит: собственные объявленные имена преобразователя (например `range`) вызывающий не объявляет, обработчик `catch: convert ()` обрабатывает такой отказ, как любой неявный, а неотловленный улетает в корень исполняющегося Message.

### 13. Значение широкой таблицы преобразователей

Дополнительные явные ключи расширяют только набор допустимых преобразований листьев. Они не меняют требуемые структурные пути и точные сигнатуры вызываемых выражений; профиль не обязан предоставлять все пары. Ни аналитическая часть, ни тест выбора пути не исполняют преобразователь и не ищут скрытую цепочку преобразований.

### 14. Корректность внешнего ресурса

Для внешнего дескриптора нужны проверяемая высокоуровневая обёртка и явный контракт ресурса и очистки. Тонкий лист наподобие `FILE` не доказывает действительность ресурса, полномочия или однократность закрытия. Юнит-тесты принимающего выражения проверяют заявленные свойства в пределах своего контракта; неизменяемые биты дескриптора не удерживают ресурс живым. В L3 нет обычных машинных `own:`/`borrow:`/`move:`, а `copy:` не изобретает способ дублирования внешнего ресурса.
[EN]
Most questions about guarantees reduce to a practical choice: where must a distinction be placed so that the required property is actually checked? A guarantee does not arise from a global strict mode; it arises from the part of a Structure that Consumer must traverse and from the tests defined by the receiving expression. Just as a C `typedef` merely names an alias while a wrapping `struct` creates a separately enforced boundary, LMX relies on the expressed path and its consumption contract.

The following fourteen cases are recipes: what to express, what that expression does not establish, and where the governing rule lives. They apply the [single admission mechanism](#admission): its analytical stage checks used paths, then the graph interpreter must execute the receiving expression's unit tests.

### 1. One receiving expression for multiple data shapes

Write the receiving expression against the paths it actually needs. Any Structure providing those paths, admitted leaves and actually invoked expressions that pass the directed check of [§7](#admission) can qualify. Structures are ordinary data, material for explicit descriptions and results of composition, so the used tree is the contract. There is no separate generic type-parameter declaration or instantiation operation. Used-tree checking is LMX's structural-generalization mechanism, not a promise of every property of parametric polymorphism.

### 2. Knowing what a particular site checks

Consumer determines analytical coverage; unknown coverage is distinguished from known thin consumption. Analysis is followed by the graph interpreter executing that same receiving expression's unit tests. Every actual call must additionally receive all inputs required by its signature. These stages do not subsume one another: they have different inputs and coverage. Success neither freezes candidate or Consumer nor certifies future uses after either changes.

### 3. Distinguishing meanings with the same representation

Encode the distinction in a path the receiving expression actually uses. With `Distance: Meter: 1`, access through `d\Meter` requires that path; a Structure exposing only `Foot` does not provide it. An outer name `Meter`, a field `unit: "meter"` or `const` alone is insufficient: path presence does not compare the value at its leaf. Immutable build-time data may permit preliminary proof of exact equality, but mandatory tests remain part of unified admission; otherwise a receiving-expression test checks the substantive constraint.

### 4. Constraining a scalar leaf

State the constraint explicitly and include it in tests. Presence of `x\width` does not establish `width = 32`: traversing a description requires its used paths, but a terminal scalar may remain thinly consumed. Immutable build-time data may undergo preliminary analysis and exact comparison, but such a proof is not an alternative runtime-validation mechanism.

### 5. Making a change visible to other reference holders

To make a change visible to other holders, write through an explicit path: `p\x: value` or `a[i]: value` changes the selected referent. A resolved bare `x: value` targeting an explicit or hidden argument updates the activation-local value; it prepares no field and publishes nothing. The write remains local with respect to its source: it changes neither the caller's argument nor the parent graph. Only a declared field (`int: x …` in the body) makes method state, and a write into it goes through the working copy and publication. An L3 reference is declared by the distinct receiver `@: Type var`, not by taking the address of a local variable; the complete rule is under [working state](#dynamic). Execution does not append the field: translation has already fixed the graph layout.

### 6. Independence from another holder's mutation

`copy:` creates an independent mutable value only within its copying contract; genuine immutability prohibits mutation of the protected value. Ordinary Structure or Array passing copies the reference, not the referent. Another alias within the Message can therefore change the shared mutable object. An immutable foreign-resource identifier does not make the foreign resource immutable.

### 7. Establishing that a call can proceed

Both conditions must hold: compatibility covers used paths and the directed check of the callable against its use ([§7](#admission)), and every dynamic input must be available from caller locals, inherited inputs or that callable occurrence's immediate `node\x`. Suppose A and B expose the same `m`, whose body uses bare `x`, while Consumer only invokes `m`: the used-callable check can pass while call admission still rejects a missing `x`. A known case is rejected during translation; a runtime-selected target requires the corresponding runtime boundary. This rule does not add callee-body expansion to `uses`.

### 8. Checking a transported callable

Transporting a callable neither executes it nor requires knowledge of every future call contract. Checking occurs at the actual call: the selected expression must pass the directed check of [§7](#admission) after ordinary input formation (optional formals are prepared with their default values), receive every dynamic input and satisfy applicable admission, even if an earlier partial check never inspected it. A passed check does not imply equal behavior.

### 9. Changing a method body without breaking calls

The body's free dynamic names are part of its interface. A formal with a provided default value is not a free name: it is not in `DynRequired` and remains part of the accepted interface. Adding a new free dynamic name to the body changes `DynRequired` and the corresponding call requirements; known callers require rechecking, while runtime-selected callables remain subject to actual-call admission. An immutable method record neither makes every occurrence referring to it immutable nor prohibits explicit replacement of a reference with a compatible callable. Behavioral change under the same signature remains a matter for tests and program correctness.

### 10. Selecting the intended part of a composition

Select the field explicitly or construct the intended fields. `merge` builds a new tree and does not mutate its operands; a later operand's same-name field overrides the model's slot in place (specialization), and no new occurrence of that name arises. If model A has `read` and B has a `read` of a compatible type, `result\read` is A's slot holding B's value; a `read` with no counterpart in the model is appended at the end. Analytical diagnostics may expose an unintended unqualified selection after an import or composition changes. Source parts need not be adjacent or statically available.

### 11. Changing an existing Structure

Field count and slots are fixed. Ordinary field operations may replace the `void *` child references stored in existing fields; a change in the target's actual type follows the ordinary rules for such updates and later consumption. A different field count requires a new Structure, such as a `merge` result. No conflict policy is introduced for nonexistent operations that remove or move an active field.

### 12. Reliable numeric conversion

Use an available explicitly keyed converter with a destination-range contract: `u16(255) → u8` is admitted, while `u16(256) → u8` is a range error, not zero. In-range rounding and precision loss are a separate numeric-profile policy. Successful analytical checking does not permit silent modular wrapping. A converter's refusal at the edge is an ordinary receiver refusal; it leaves as the implicit named failure of that edge (`convert`) in the method that owns the edge: the caller does not declare the converter's own names (for example `range`), a `catch: convert ()` handler handles such a refusal like any implicit one, and an uncaught one flies to the root of the executing Message.

### 13. What a broad converter table provides

Additional explicit keys widen only the available leaf conversions. They do not alter required structural paths or exact callable signatures, and a profile need not provide every pair. Neither analytical checking nor path-selection tests execute a converter or search for a hidden conversion chain.

### 14. Foreign-resource validity

A foreign handle requires a checked high-level wrapper and explicit resource and cleanup contracts. A thin `FILE`-like leaf does not establish validity, authority or single close. The receiving expression's unit tests check declared properties within their contract; immutable handle bits do not keep a resource alive. L3 has no ordinary machine-level `own:`/`borrow:`/`move:`, and `copy:` does not invent a foreign resource's duplication policy.

@@ construction | Построение значений | Value construction | 9.1–9.2; 19.20
[RU]
Исходная запись строит полный граф Structure: значения, объявления и исполняемые выражения остаются в том же графе. Построить описание тела не означает исполнить это тело. Именованная Structure не исполняется при объявлении; безымянное тело в позиции исполнения выполняется по контракту принимающего выражения. Не создаются отдельный граф данных, скрытая процедура-обёртка или постоянный вспомогательный контекст. Лексический родитель определяется местом объявления; у корня independent он отсутствует (parent = 0).

### Разрешение головы и роль хвоста

Блочная, короткая и скобочная записи выражают одно применение «голова принимает хвост». Сначала определяется роль головы в данном контексте. Зарезервированный receiver-оператор применяет собственный общий контракт и не затеняется пользовательским именем. Для существующего callable, включая обычную именованную Structure, применение является вызовом; неизвестный фактический аргумент или отказ admission — ошибка вызова, без перехода к объявлению. Для существующей примитивной либо явно ссылочной non-callable привязки действует присваивание. Неизвестная голова в позиции определения объявляет именованную Structure с записанным содержимым; свободные имена этого содержимого не обязаны быть разрешены при определении.

Неизвестное имя аргумента не превращает существующую Structure-голову в ресивер объявления по модели. При существующем A запись A: b в исполняемом теле вызывает A; неизвестный фактический b не объявляется и не клонируется. Неявного merge(A, empty) здесь нет. Ресивер примитивного типа int, напротив, объявляет по своему контракту: int: i 5 передаёт ему имя i и значение 5. Произвольная вложенность ресиверов не означает равенства цепочки применений списку аргументов; каждую вложенную форму потребляет её принимающее выражение.

При неизвестном C запись C: makeA() объявляет C, в которую входит именованная пустая Structure makeA. Здесь не вычисляется результат makeA и не сохраняется вызов makeA для последующего исполнения. Скобки не являются признаком вызова. Записанное содержимое определения не следует заранее выполнять как выражение-инициализатор только из-за его внешнего сходства с вызовом.

```text
C: makeA()
```

f(), f: () и явно закрытая пустая вертикальная форма задают одно представление. При неизвестном f в позиции определения это пустая именованная Structure; при существующем callable f в позиции исполнения — нульарный вызов. Голый f в позиции исполнения вычисляется по обычным правилам выражения. Наличие трейлера, return или особая поверхностная форма не выбирают объявление вместо вызова. Неизвестное A в A: b объявляет Structure A, а не переменную выведенного из b примитивного типа: в языке нет var.

### Явное копирование и ссылочные переменные

Для клонирования либо композиции уже существующих структур используется явный [merge](#composition). В b: merge A C операнды — A и C, внешний b получает результат; имя результата не является первым операндом merge. Неявное клонирование по факту неизвестного аргумента не выполняется. Формирование возвращаемого вложенного callable с данными завершающейся активации регулируется отдельно тем же разделом композиции и не отменяется правилами объявления.

Для явной изменяемой ссылочной привязки служит @: Type var с необязательным третьим аргументом-кандидатом; подробный контракт и глубина описаны в [§12](#dynamic). Такая привязка сама не становится callable. var: value присваивает ей ссылку; для вызова референта используется явное разыменование \var. Объявление ссылки выделяет место для ссылочного значения, а не экземпляр Type; отсутствие инициализатора задаёт нулевое ссылочное значение.

Если кандидат — Structure, а цель — типизированная ссылка, допустимое преобразование сначала получает ссылку на кандидата, затем implements проверяет референт относительно требования и Consumer, и только после успеха записывается ссылка. Поэтому ptr: A и ptr: @A могут предоставлять один кандидат через общий конвертер. Указатель является примитивным значением; таблица преобразований относится к представлениям примитивов, а не к каждой паре пользовательских структур. Соответствие конкретных структур устанавливает implements. Все обычные Lmx-вхождения используют общий типизированный диапазон, а не отдельный одноэлементный массив для каждой модели.

### Сигнатура не исполняется

Сигнатура описывает входы, а не исполняет записанные в ней формы как тело метода. Для непримитивного A формалы (A: b) и (@: A b) описывают одну ссылочную передачу с допуском кандидата к A. В test(c) существующий кандидат проходит implements(c, A, Consumer); передаётся ссылка на его дескриптор, без копирования непримитивного значения и без неявного merge. Это не делает A: b в исполняемом теле объявлением формала или ссылочной переменной.

```text
sub: test (A: b)
sub: test (@: A b)
```

Для структурного c передачи test(c) и test(@c) имеют одинаковую ссылочную глубину. Уже объявленная ссылочная переменная p передаёт своё ссылочное значение; @p адресует её ячейку и добавляет уровень, поэтому не подставляется в тот же одноуровневый формал снятием лишней глубины. Примитивные формалы (int: b) и (@: int b) не являются синонимами. Передача и обычный возврат непримитивного значения не используют C by-value aggregate; способ машинного хранения дескриптора не меняет эту семантику.

### Присваивание и места объявления

Присваивание обновляет существующую non-callable привязку после полного admission. Кешированные проверенные адреса и оптимизированное локальное хранение не отменяют implements. Неуспех не меняет ни цель, ни её dirty и не стирает ранее допущенное, ещё не опубликованное значение. Примитив получает значение; явно ссылочная переменная — ссылку без копирования референта, переподчинения parent или переноса владения.

Присваивание явному либо скрытому аргументу обновляет локальное значение активации и не создаёт поля графа, не пишет обратно вызывающему. Объявленное own-поле сохраняет своё место в полном графе; его присваивание меняет рабочее значение по общему правилу публикации. Наличие записи в теле не служит основанием для дополнительного объявления. Неизвестная голова с литералом задаёт структурное содержимое, а не неявно типизированный примитив: для примитивной переменной требуется ресивер её типа.

Прямое применение callable-поля — вызов, не перепривязка callable. Замена выполняется общими структурными механизмами: merge с более поздним одноимённым полем и admission, динамической перегрузкой из вызывающего контекста либо явной передачей callable-аргумента. Изменяемая ссылка на callable объявляется явно и следует обычному контракту ссылочной переменной.

Все объявления и операторы сохраняются в лексическом порядке полного графа. Повторные поля не склеиваются по имени. Вхождения выбираются общим [правилом структурных путей](#fields), независимо от порядка рабочего кэша активации.

```text
result:
    int: count 3
    int: count 4
end: result
```

Здесь result\[0]count даёт 3, result\[1]count даёт 4. Именование не добавляет отдельный класс или особую раскладку. Ссылочное поле может хранить уже существующий объект без копирования и без смены его лексического родителя. Правила копирования, переназначения внутренних ссылок и сохранения нативной реализации находятся в [композиции](#composition).
[EN]
Source notation constructs the complete Structure graph: values, declarations and executable expressions remain in the same graph. Constructing a body description does not execute that body. A named Structure is not executed on declaration; an anonymous body in execution position runs under its receiving expression's contract. No separate data graph, hidden wrapper procedure or persistent auxiliary context is created. The declaration site determines the lexical parent; an independent root has none (parent = 0).

### Head resolution and the role of the tail

Block, short and parenthesized spellings express one application, “the head consumes the tail.” First determine the head's role in the given context. A reserved receiver-operator applies its own general contract and cannot be shadowed by a user name. Applying an existing callable, including an ordinary named Structure, is a call; an unknown actual argument or admission failure is a call error, without falling back to declaration. An existing primitive or explicitly referenced non-callable binding selects assignment. An unknown head in definition position declares a named Structure with the written contents; free names in those contents need not resolve at definition time.

An unknown argument name does not turn an existing Structure head into a model-declaration receiver. With existing A, A: b in an executable body invokes A; an unknown actual b is neither declared nor cloned. There is no implicit merge(A, empty). A primitive type receiver such as int instead declares under its own contract: int: i 5 supplies the name i and value 5. Arbitrary receiver nesting does not equate an application chain with an argument list; each nested form is consumed by its receiving expression.

With unknown C, C: makeA() declares C containing a named empty Structure makeA. It neither evaluates a makeA result nor stores a makeA call for later execution. Parentheses are not a call marker. The written contents of a definition must not be pre-executed as an initializer merely because they resemble a call.

```text
C: makeA()
```

f(), f: () and an explicitly closed empty vertical form have one representation. For unknown f in definition position this is an empty named Structure; for existing callable f in execution position it is a nullary call. Bare f in execution position is evaluated under ordinary expression rules. A trailer, return or particular surface spelling does not select declaration instead of call. Unknown A in A: b declares Structure A, not a primitive variable whose type is inferred from b: the language has no var.

### Explicit copying and reference variables

Explicit [merge](#composition) clones or composes existing Structures. In b: merge A C the operands are A and C and outer b receives the result; the destination name is not the first merge operand. An unknown argument does not trigger implicit cloning. Formation of a returned nested callable with data from the finishing activation is governed separately by that composition section and is not removed by declaration rules.

An explicit mutable reference binding uses @: Type var with an optional third candidate argument; its detailed contract and depth are defined in [§12](#dynamic). The binding does not itself become callable. var: value assigns a reference; invoking its referent uses explicit dereferencing \var. A reference declaration allocates reference-value storage, not a Type instance; omitting the initializer gives a null reference value.

When the candidate is a Structure and the destination a typed reference, an admissible conversion first obtains the candidate reference, then implements checks the referent against the requirement and Consumer, and the reference is stored only after success. Thus ptr: A and ptr: @A can supply the same candidate through a general converter. A pointer is a primitive value; conversion tables describe primitive representations, not every pair of user Structures. implements establishes suitability of particular Structures. Ordinary Lmx occurrences use a common typed range, not a separate single-element array for each model.

### A signature is not executed

A signature describes inputs rather than executing its forms as a method body. For nonprimitive A, formals (A: b) and (@: A b) describe the same reference transport with candidate admission to A. In test(c) an existing candidate passes implements(c, A, Consumer); its descriptor reference is passed without copying the nonprimitive value or performing implicit merge. This does not turn A: b in an executable body into a formal or reference-variable declaration.

```text
sub: test (A: b)
sub: test (@: A b)
```

For structural c, test(c) and test(@c) supply the same reference depth. An already declared reference variable p passes its reference value; @p addresses its cell and adds a level, so the same single-level formal cannot accept it by silently stripping that depth. Primitive formals (int: b) and (@: int b) are not synonyms. Passing and ordinarily returning a nonprimitive value never use a C by-value aggregate; the descriptor's machine storage does not change this semantics.

### Assignment and declaration sites

Assignment updates an existing non-callable binding after full admission. Cached checked addresses and optimized local storage do not remove implements. Failure changes neither the destination nor its dirty state and does not erase an earlier admitted value awaiting publication. A primitive receives a value; an explicitly referenced variable receives a reference without copying the referent, reparenting it or transferring ownership.

Assignment to an explicit or hidden argument updates the activation-local value, creates no graph field and does not write back to the caller. A declared own-field retains its place in the complete graph; assignment changes its working value under ordinary publication rules. A write in a body is not grounds for another declaration. An unknown head with a literal supplies structural contents, not an implicitly typed primitive: a primitive variable requires its type receiver.

Direct application of a callable field is invocation, not callable rebinding. Replacement uses general structural mechanisms: merge with a later same-named field and admission, dynamic override from the caller, or explicit callable-argument transport. A mutable reference to a callable is declared explicitly and follows the ordinary reference-variable contract.

All declarations and operators remain in the complete graph's lexical order. Repeated fields are not coalesced by name. Occurrences are selected by the common [structural-path rule](#fields), independently of an activation's working-cache order.

```text
result:
    int: count 3
    int: count 4
end: result
```

Here result\[0]count gives 3 and result\[1]count gives 4. Naming adds no separate class or special layout. A reference field can retain an existing object without copying or changing its lexical parent. Copying, internal-reference relocation and native-implementation retention are defined in [composition](#composition).

@@ qualification | const, immutable и independent | const, immutable and independent | 2.5.3; 9.1.2–9.1.3
[RU]
`const` защищает привязку: её нельзя присвоить, перепривязать или заменить. Значение за защищённой ссылкой может оставаться изменяемым. `immutable` защищает само значение на протяжении всей его жизни, через любые псевдонимы; переменная, содержащая ссылку на него, может оставаться перепривязываемой. `const: immutable` объединяет обе гарантии. Это независимые квалификации, а не ступени одной шкалы.

Неизменяемость применима к примитиву, структуре и выбранному дереву, массиву с дескриптором и элементами. Она охватывает позиционные поля, все одноимённые вхождения и явно включённые описания, а не только пути Consumer или первое вхождение. Передача, возврат и сохранение неизменяемого значения сохраняют его идентичность; квалификация не требует копии, в том числе для примитива. Она не замораживает внешний ресурс, обозначенный неизменяемым идентификатором.

`immutable` при построении квалифицирует новое значение до публикации. `RuntimeImmutable` квалифицирует уже существующее дерево с сохранением его идентичности. Название второй операции не обозначает второй механизм допуска аргументов: её собственный операционный контракт — изменение квалификации. Её аргументы проходят [единый допуск](#admission), как аргументы любого принимающего выражения.

Перед изменением квалификации исследуется всё выбранное дерево. Вложенная структура является ветвью дерева только тогда, когда её обычное структурное поле `parent` указывает на рассматриваемого родителя. Внешняя ссылка допустима только на уже неизменяемый объект; она терминальна, её цель не обходится и не переквалифицируется. Проверяется состояние до начала изменения: результат обработки раннего поля не может оправдать недопустимую внешнюю ссылку в позднем. Некорректная вложенность или изменяемая внешняя цель приводят к объявленному `throw`, а не к `assert`.

Примитивы и методы — листья, не ветви лексического дерева. Ссылка на массив также не создаёт ветвь `parent`: операция над деревом не замораживает неявно изменяемое хранилище внешнего массива. Неизменяемый массив строится по собственному контракту. Принадлежность ячейки служебному пулу не даёт права обходить или квалифицировать весь пул.

Квалификация применяется только после успешной полной предварительной проверки. При неудаче нет частично замороженного дерева и опубликованного успешного результата; запрещено молча пропускать ветвь, копировать её или перенаправлять ссылки. Повторная квалификация уже подходящего дерева ничего не меняет. Правило не откатывает ранее выполненные инициализаторы, вычисление аргументов или предвызовную публикацию рабочих полей; транзакция графа не возникает.

Защита обязательна для записей через любой путь и для публикации рабочих полей. Заведомо недопустимая запись отвергается до исполнения, динамически выбранная — проверяется при исполнении. Вызов метода разрешён, но не снимает защиты. Изменение локальной копии аргумента или перепривязка локальной ссылки не меняют защищённое значение. Построение нового значения, в том числе `merge`, не размораживает исходное.

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

Protection applies to writes through every path and to publication of working fields. A known-invalid write is rejected before execution; a dynamically selected write is checked during execution. Calling a method is allowed but does not remove protection. Changing a local argument copy or rebinding a local reference does not modify the protected value. Constructing a new value, including through `merge`, does not thaw the source.

Construction-time `independent` sets the root's `parent = 0`; that is exactly the absence of an external lexical parent. Internal tree `parent` links and own fields remain. The qualification neither retroactively clears existing objects' `parent` links nor prohibits explicitly supplied references, current-caller dynamic arguments, Messages or selection of a callable by a compatible signature. It does not require purity or an interface closed over explicit arguments alone.

`const`, `immutable` and `independent` are receiving expressions; their composition establishes the result's qualified type. The physical representation of that type is determined by the common typed-address-range membership mechanism described in [L2](L2_spec_en.md#type-by-range), rather than by per-value flags or a special classifier for one particular qualifier chain. The range's own identity is the type domain; qualifier compositions do not each introduce a new enumeration code. A zero root `parent` remains the structural consequence of `independent`, not a replacement for type classification.

For example, a method inside independent Structure S can use S's field through its internal lexical link. Required `x` can come from the current caller. If `x` exists only in S's former textual surroundings, implicit external access is unavailable. An explicitly passed large Array neither shrinks nor gets copied because of `independent`. The special lifetime of the three qualifications together is described under [eternal branches](#eternal).

@@ callables | Вызываемые выражения и их интерфейсы | Callable expressions and their interfaces | 7–7.3; 7.5.1; 8.5–8.8; 19.21; 21.9
[RU]
Сигнатура описывает входы и результат; она не является исполняемым телом. Запись формала не выполняет вызов, объявление или присваивание, которое та же запись могла бы означать в теле. Синонимия двух описаний в сигнатуре относится к контракту параметра и не переносится на исполняемые записи. Подача фактического аргумента выполняет предусмотренные контрактом преобразования и допуск, но не исполняет описание формала как оператор тела. Использование полученного параметра в теле разрешается по его контракту и общим правилам выражений, а не исполнением текста сигнатуры.

Исполняемое тело — структурное выражение. Всякая именованная Structure может исполняться голым атомом имени, но её объявление и построение сами по себе тело не исполняют. `fn` определяет выражение с одним логическим результатом; `sub` — выполнение без возвращаемого значения; `fm` — один результат-структуру, поля которой образуют поверхность множественного возврата. Сигнатура задаёт явные аргументы, требуемые динамические и лексические входы, способ передачи каждого значения, результат и объявленные выходы `throws`. Голый `return` завершает исполнение без значения; `return: value` передаёт значение в допускающем результат теле. Обычная именованная Structure — callable без результата: в ней допустим только голый `return`, а `return: value` отвергается; `sub` также допускает голый `return`, но не приобретает от него результат. На уровне открытия `return` — голый, а в допускающем результат теле и со значением — может также закрывать любую callable Structure (метод или именованную Structure) как trailer по общему правилу грамматики; не-callable Structure `return` не закрывает. Замыкатель не обязателен ни одной конструкции: `end: Name`, голый `return` и `until:` — границы записи, а не условие объявления; именованная Structure, закрытая одним срезом уровня, объявляется так же — общим разрешением ([§9](#construction)), — а конец её тела, как и тела `sub`, завершает исполнение без результата, и узел возврата там не синтезируется. Структурный путь через Structure читает её поле и не исполняет её; объявление в исполняемом теле — локальная переменная этого тела: видна вперёд и вниз (во вложенные тела), лежит в Structure там, где написана, — рядом с ней нет ни отдельного поля, ни контейнера данных, а остальной граф (операторы) хранится там же и в том же порядке для интерпретатора ([§12](#dynamic)); именованная Structure — та же вызываемая процедура без результата; голое имя не передаёт аргумент, а `Model: Other` при существующих именах передаёт `Other` по общему контракту вызова; путь `M\i` снаружи открывает место объявления — объявление в любом случае заводит там значение, — но не рабочую переменную активации и не узел инициализатора.

Вызываемое вхождение имеет собственную структурную идентичность и поле `parent`, указывающее в его над-методное лексическое пространство. Несколько вхождений могут ссылаться на один неизменяемый метод. Копирование графа не создаёт новую реализацию метода и не меняет его сигнатуру; состояние принадлежит конкретным структурным вхождениям и активациям. Вложенное определение не захватывает кадр вызывающего выражения в скрытое окружение.

Вход в метод не копирует его вызываемое вхождение, тело или другую часть графа. Нативное и интерпретируемое исполнение работают с полной Structure вызываемого: объявления, значения и операторы сохраняют исходный порядок. Каждая активация получает обычный машинный кадр для формальных и скрытых входов, результата и рабочих значений используемых own-полей. Изменённые рабочие значения публикуются в местах объявлений по правилам [§12](#dynamic); операторы и литералы не переписываются. Аргумент сам по себе поля не создаёт. Рекурсивный вызов исполняет ту же Structure с отдельным машинным кадром, не создавая постоянный структурный двойник; объявленные данные остаются в местах объявления, а результат через вызываемое вхождение не читается. Композиция через `merge` даёт формалу значение по умолчанию, но не связывает его и не устраняет требование обычной передачи аргумента. Свободное имя выбирает динамический вход по общему правилу, затем допустимый лексический источник; оно не становится постоянной ссылкой на поле вызывающего. Временные рабочие значения кадра не добавляют узлов в граф.

Программа может сама разместить объявления и исполняемые тела раздельно, используя общие конструкции языка. Это выбор исходного представления, а не обязательная внутренняя пара или дополнительный граф при вызове.

Отсутствие явных аргументов у именованной Structure не отменяет скрытых аргументов. При её исполнении свободные имена получают значения по единому правилу вызываемой процедуры: сначала из текущего вызывающего выражения, затем из допустимого лексического источника ([§12](#dynamic)). Полученное значение локально для активации; присваивание голому имени не пишет обратно в источник. Отдельного режима разрешения свободных имён для именованной Structure нет.

Различие сохраняется и внутри одной Structure: объявление создаёт типизированное место значения, а исполняемый оператор определяет, когда вычислить и записать новое значение. Например, `int: a` объявляет место, а последующее `a: get_a()` выполняется при достижении оператора. Совместное хранение этих узлов в графе не делает их взаимозаменяемыми.

Выбор вызова начинается с явной ссылки, структурного пути либо текстового пути с явно переданным корнем. Выбор реализации и подача её аргументов — разные действия. Обнаруженный кандидат проходит [допуск](#admission); затем вызов должен получить все входы сигнатуры. Наличие подходящего поля с методом ещё не обеспечивает его динамические входы. Передача метода как данных не равна его вызову.

Позиционные фактические аргументы предшествуют именованным. После первого именованного аргумента последующие также именованные. Неизвестное имя, повторное присваивание одного аргумента, недостающий обязательный аргумент или нарушение порядка — ошибка. Тело именованного аргумента передаётся как структурное значение, если именно такой режим задаёт принимающее выражение; оно не становится произвольной последовательностью немедленных вызовов. В позиции аргумента принимающий контракт выбирает результат или саму ссылку: явно объявленный callable-формал получает ссылку на callable-вхождение, а не результат его исполнения; если принимается результат, исполняется callable с возвращаемым значением; не возвращающее значения callable, включая `sub`, передаётся ссылкой. Голый `return` означает только выход и не делает callable возвращающим значение. Объявленный без тела `fn` остаётся дескриптором интерфейса и может передаваться ссылкой, но прямое исполнение не получает вымышленного тела.

Формальный параметр с предусмотренным значением по умолчанию остаётся частью полного принимаемого интерфейса. При отсутствии явно поданного аргумента используется это значение; при явной подаче используется поданный аргумент, прошедший обычные преобразования и допуск. Наличие дефолта не удаляет формал и не превращает его в свободный динамический вход: одноимённое значение в контексте вызывающего не становится поданным аргументом — для его подачи есть обычный вызов с аргументом. Эти правила не зависят от того, были ли данные параметра получены через `merge` ([§20](#composition)): один и тот же смысл получается при непосредственном задании такого аргумента и при обычной композиции его данных. Значение, неподходящее по контракту, не приравнивается к отсутствующему аргументу и не заменяется дефолтом молча; ноль — тоже поданное значение. Источник дефолта и значение аргумента текущей активации различаются: подача `y: 25` для одного вызова не меняет последующие вызовы, и значение, оставшееся в рабочей ячейке после прежнего исполнения, само по себе дефолтом не становится — изменить состояние, из которого берётся дефолт, может только обычная явная операция над ним. Нет ни аргумента, ни допустимого дефолта — обычный отказ вызова.

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
A signature describes inputs and the result; it is not an executable body. A formal's spelling does not execute the call, declaration, or assignment that the same spelling might denote in a body. Synonymy between two descriptions in a signature concerns the parameter contract and does not extend to executable occurrences of those spellings. Supplying an actual argument performs the contract's conversions and admission, but does not execute the formal description as a body operator. Uses of the resulting parameter in the body are resolved by its contract and the general expression rules, not by executing the signature text.

An executable body is a structural expression. Every named Structure may be executed through the bare atom of its name, but declaring or constructing it does not itself execute its body. `fn` defines an expression with one logical result; `sub` performs execution without a returned value; `fm` has one result Structure whose fields provide a multiple-return surface. The signature defines explicit arguments, required dynamic and lexical inputs, each value's pass mode, the result and declared `throws` exits. Bare `return` exits without a value; `return: value` supplies a value in a body admitting a result. An ordinary named Structure is a callable without a result: only bare `return` is admitted in it, and `return: value` is rejected; `sub` likewise admits bare `return` but does not acquire a result from it. At the opening level `return` -- bare, or with a value in a body admitting a result -- may also close any callable Structure (a method or a named Structure) as a trailer under the general grammar rule; `return` does not close a non-callable Structure. No construct requires a closer: `end: Name`, bare `return` and `until:` are boundaries of the notation, not a condition of declaration; a named Structure closed by a level cut alone is declared the same way -- by general resolution ([§9](#construction)) -- and reaching the end of its body, as of a `sub` body, completes the execution without a result, and no return node is synthesized there. A structural path through a Structure reads its field and does not execute it; a declaration in an executable body is a local variable of that body: visible forward and down (into nested bodies), lying in the Structure where it is written -- with no separate field or data container beside it, while the rest of the graph (the statements) is kept in the same place and order for the interpreter ([§12](#dynamic)); a named Structure is the same callable procedure without a result; a bare name passes no argument, whereas `Model: Other` with existing names passes `Other` under the general call contract; the path `M\i` from outside opens the place of declaration -- a declaration always establishes a value there -- but never the activation's working variable or the initializer node.

A callable occurrence has its own structural identity and a `parent` link into its above-method lexical space. Multiple occurrences can reference one immutable method. Graph copying neither creates another method implementation nor changes its signature; state belongs to particular structural occurrences and activations. A nested definition does not capture a caller frame in a hidden environment.

Entering a method copies neither its callable occurrence nor its body or any other part of the graph. Native and interpreted execution use the callable's complete Structure: declarations, values and operators retain source order. Each activation has an ordinary machine frame for formal and hidden inputs, the result, and working values of the own fields it uses. Changed working values are published at declaration sites under [§12](#dynamic); operators and literals are not rewritten. An argument alone creates no field. A recursive call executes the same Structure with a separate machine frame, not a permanent structural companion; declared data remain at their declaration sites, and the result is not read through the callable occurrence. Composition through `merge` supplies a formal's default without binding the formal or removing ordinary argument passing. A free name follows the general dynamic-input rule and then an eligible lexical source; it does not become a permanent reference to a caller's field. Temporary working values in the frame add no graph nodes.

A program may itself arrange declarations and executable bodies separately using ordinary language constructs. That is a source-level choice, not a mandatory internal pair or an additional graph on invocation.

A named Structure has no explicit arguments, but it still receives hidden inputs. When it executes, a free name follows the same rule as in any called procedure: the current caller first, then an eligible lexical source ([§12](#dynamic)). The value is local to the activation; assigning to the bare name does not write back to its source. Named Structures have no separate free-name resolution mode.

The distinction also holds within one Structure: a declaration establishes typed value storage, while an executable operator determines when a new value is computed and assigned. For example, `int: a` declares storage, and a later `a: get_a()` executes when reached. Keeping both nodes in one graph does not make them interchangeable.

Callable selection starts from an explicit reference, structural path or textual path with an explicitly supplied root. Selecting an implementation and providing its arguments are distinct actions. The selected candidate undergoes [admission](#admission); the call must then receive every signature input. A suitable method field does not by itself supply its dynamic inputs. Transporting a method as data is not invoking it.

Positional actual arguments precede named ones. After the first named argument, subsequent arguments must also be named. An unknown name, duplicate assignment to one argument, missing required argument or ordering violation is an error. A named argument's body is supplied as a structural value when that is the receiving expression's specified mode; it does not become an arbitrary sequence of immediate calls. In argument position the receiving contract selects a result or the reference itself: an explicitly declared callable formal receives a reference to the callable occurrence, not the result of executing it; when a result is received, a value-returning callable is executed; a callable with no returned value, including `sub`, is passed by reference. Bare `return` means only exit and does not make a callable value-returning. A bodyless `fn` remains an interface descriptor and may be passed by reference, but direct execution gains no invented body.

A formal parameter with a provided default value remains part of the full accepted interface. When no argument is supplied explicitly, that value is used; when one is supplied explicitly, the supplied argument is used after the ordinary conversions and admission. Having a default neither removes the formal nor turns it into a free dynamic input: a same-named value in the caller's context does not become a supplied argument -- supplying it takes an ordinary call with the argument. These rules do not depend on whether the parameter's data came through `merge` ([§20](#composition)): the same meaning results from writing such an argument directly and from ordinary composition of its data. A value that does not fit the contract is not equated with an absent argument and is not replaced by the default silently; zero is a supplied value too. The source of the default and the argument value of the current activation are distinct: supplying `y: 25` for one call does not change later calls, and a value left in a working cell by a previous execution does not become a default by itself -- only an ordinary explicit operation on the state the default is taken from changes it. Neither an argument nor an admissible default -- the ordinary call refusal.

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
Следует различать хранилище объявленного значения в полной Structure, рабочее значение текущей активации, явный формальный аргумент и динамический вход. Эти значения имеют разные правила изменения; рабочая копия не создаёт второго постоянного графа. Обычная передача изменяемого примитива копирует значение, структуры и массива — ссылку; особая идентичность неизменяемого значения сохраняется согласно [квалификации](#qualification).

Для свободного имени вызываемое выражение получает текущее значение из доступного контекста вызывающего выражения; при его отсутствии используется допустимый лексический поиск по `node`. Внутренние собственные объявления и формальные параметры имеют свои разрешённые места, а не ищутся в глобальном реестре. Список необходимых сквозных имён входит в сигнатуру: добавление свободного имени меняет интерфейс. При отсутствии необходимого входа вызов недопустим; молчаливое создание нуля или нового поля запрещено. Формал вызываемого — не свободное имя его тела: он получает поданный аргумент или своё значение по умолчанию ([§11](#callables)), и приоритет источников ниже на пропущенный формал не распространяется.

Приоритет источников свободного имени: ближайшая текущая локальная привязка вызывающего выражения, затем уже унаследованный им динамический вход, затем лексический поиск вызываемого выражения. Локальная привязка включает используемое собственное поле, формальный аргумент, результат или иное локальное значение, определённое принимающим выражением. Требования статически известных вызовов распространяются до неподвижной точки, в том числе через взаимную рекурсию. Имя, нужное только следующему вызову, также должно сохраняться и передаваться; само по себе это не создаёт поле графа.

Лексический поиск использует реальные связи структуры, заканчивается на нулевом родителе и выбирает на соответствующем шаге последнее одноимённое вхождение, как всякое неуточнённое имя ([имена](#fields)); явный селектор `[N]name` выбирает другое. `independent` отсекает только внешний лексический запасной путь. Явное обращение `node\x`, `reference\x` или `array[index]` обращается к графу, а не подменяется динамическим `x` текущего вызова. Лексический контекст, скопированный `merge`, входит в этот порядок только как запасной путь ([композиция](#composition)).

Рабочее значение собственного поля загружается для активации из графа: собственное поле текущей активации — поле самого вызываемого вхождения (или его экземпляра при повторном входе), а присваивание такому имени меняет рабочее значение и отмечает его как изменённое (`dirty`); опубликует его контрольная точка. Загрузка и чтение сами по себе ничего не помечают `dirty`. Загрузка происходит при входе в активацию и только для тех own-полей, которые тело реально использует голыми именами (источник 21.5): явная запись по пути после входа меняет ячейку графа, а голое имя продолжает читать значение входа до собственной записи. Явная запись через ссылку меняет выбранный объект непосредственно и наблюдаема через другие ссылки на него. Явный или скрытый аргумент — значение машинной активации: полем он не становится — поле есть только по объявлению, — его присваивание обновляет это локальное значение, и обратной записи вызывающему выражению нет.

Присваивание обновляет уже разрешённую привязку. Оно не создаёт дополнительного поля данных — ни при исполнении, ни тем, что транслятор заранее его заводит. Инициализация вычислением — два обычных оператора рядом: `int: i` объявляет, `i: findValue` присваивает результат вызова по обычным правилам, когда управление доходит до этой строки; особого приёмника-инициализатора, фазы построения и скрытой однократной инициализации нет, а само чтение сохранённой программы вызов не исполняет. После исполнения полная Structure по-прежнему содержит и объявление, и присваивание с вызовом: присваивание меняет рабочее значение переменной, а не вызов, его операнды или сам оператор; контрольная точка пишет изменённое значение только в хранилище значения, никогда — в исполняемое представление инициализатора. Простые литеральные объявления вроде `int: i 5` этим не запрещены. Явный или скрытый аргумент остаётся локальным значением активации, пока явное объявление не установит поле с графовым хранилищем. Присваивание аргументу не пишет обратно вызывающему выражению и не создаёт молча постоянного состояния метода. Тело здесь — вызываемое выражение (метод), а не вложенное тело `if`/`while`/блока: поле метода даёт объявление в его теле, а голое присваивание внутри вложенного тела полей этому вложенному телу не заводит и пишет в объявленное поле вызываемого; вложенная Structure тела держит только поля, объявленные в ней (`fn: keep (int: n) int` с телом `int: n` / `if: 1` / `n: n + 1` / `return: n` даёт `keep(3) = 4` — поле `n` есть по объявлению `int: n`). См. L2 §10. После выбора роли присваивания `value` должно быть разрешено как допустимый типизированный кандидат; неизвестное значение или отказ допуска являются ошибкой присваивания, без выбора другой роли двоеточия. Трансляция уже зафиксировала раскладку прототипа, поэтому исполнение не меняет число полей; публикация объявленного own-значения идёт в хранилище его объявления в активной Structure, никогда — в источник аргумента вызывающего выражения или в родительский граф.

Локальность и длительность хранения здесь являются разными свойствами. Место объявления переменной вызываемого вхождения хранит опубликованное значение после активации в полной Structure — там, где объявление написано, без отдельного поля рядом; рабочая переменная активации снаружи не видна, а путь `M\x` снаружи открывает место объявления, поскольку объявление в любом случае заводит значение; запись в него не является изменением внешней привязки: ячейка аргумента вызывающего выражения и поле над-методного пространства остаются неизменными. Это внешнее поле меняется только явной записью через путь `node\x`, где `node` — данные лексического родителя.

В L3 @ сохраняет ссылочный смысл: объявление ссылки, получение ссылки на разрешённое значение, передача, перепривязка и разыменование допустимы без машинной адресной арифметики. @: Type var объявляет типизированную ссылочную переменную; третий аргумент @: Type var candidate задаёт начальный кандидат. Без третьего аргумента записывается нулевое ссылочное значение, а не создаётся экземпляр Type. Ноль не является пустой Structure; разыменование несвязанной ссылки не даёт значения. Type и var — отдельные аргументы принимающего выражения, а не неявная цепочка вызовов.

```text
@: A ptr_a A
@: A ptr_b B
ptr_b: @A
ptr_b: A
```

В этих формах A и B — существующие структуры. Преобразование кандидата в ссылку предшествует implements(B, A, Consumer); сохраняется только допущенное ссылочное значение. Преобразование описывается общей таблицей примитивных представлений, поскольку указатель — примитив. Таблица не перечисляет пары пользовательских моделей; пригодность структурного референта устанавливает implements. Ссылочная переменная не становится callable от того, что её референт исполняем: ptr_b: A — присваивание; для вызова референта служит явное \ptr_b.

| Форма | Смысл в L3 |
| --- | --- |
| @: var | Объявление ссылки без заданного требования к типу референта (void-ссылка), начальное значение 0 |
| @: Type var | Объявление типизированной ссылки var с начальным значением 0 |
| @: Type var candidate | Объявление и инициализация ссылки после преобразования и admission кандидата |
| @: Type: var | Вложенная форма @(Type(var)); не автоматический синоним двух отдельных аргументов Type и var |
| @x, return: @x, передача @x аргументом | Получение и перенос ссылки на реальное типизированное значение без машинной адресной арифметики |
| @@: Type var, @@@: Type var и далее | Объявление ссылок большей глубины; искусственного предела глубины нет |
| \var | Разыменование ссылки; дальнейшая операция определяется полученным значением |

Адресуется реальное значение, а не служебный слот, которым граф хранит ссылку на него. Для обычной Structure x ссылка @x указывает на её типизированный дескриптор Lmx, а не на внутреннюю ячейку void* дочерних ссылок; в C-проекции это Lmx*, не автоматически Lmx**. Для явно ссылочной переменной p операция @p адресует саму ячейку её ссылочного значения и добавляет один уровень; обычное чтение p возвращает хранимую ссылку. Для примитива или элемента массива адресуется соответствующая типизированная ячейка. Уточнения машинной проекции и времени жизни приведены в [L2 §18](L2_spec_ru.md#lowlevel-address).

Передача и return ссылочной переменной переносят её значение, не адрес переменной. Новой Structure требуется явное определение либо merge; объявление @ не клонирует референт. L3 не предоставляет числового адреса, машинного cast, произвольного доступа к сырой памяти или изменения адреса арифметикой. Переносимая ссылка, включая получение @x и разыменование, не запрещается из-за машинного способа реализации L2; допустимость определяется операцией, а не наличием символа @.

Каждое тело, которое принимающее выражение исполняет по операторам, — структура графа и владелец непосредственно объявленных в нём полей. Тела `if` и `else`, циклов и других принимающих выражений образуют вложенную иерархию, не плоский список полей метода. Невыполненная ветвь не производит присваиваний. Обычный вложенный блок не создаёт новую активацию метода или границу динамических входов. Условие, аргумент вызова и аргумент `return` сами по себе не являются исполняемыми телами: их роль задаёт принимающее выражение, а не наличие вложенной структуры в последней синтаксической позиции.

```text
fn: remember (int: x) int
    x: 7
    return: x
end: remember
```

Здесь `x: 7` обновляет локальный аргумент `x`, и `remember(3)` возвращает 7; поля у `remember` от этого не появляется, переменная вызывающего выражения не меняется, и состояния `remember` не хранит. Поле есть только там, где его ставит объявление: `int: x 3` в теле объявило бы его, и тогда голое имя читает и пишет это поле через рабочую копию. Кэшируются только собственные поля, реально используемые голым именем либо для передачи динамического входа дальше; явный путь читает граф и сам по себе не создаёт own-кэш; поле не исчезает из графа оттого, что голое имя его не использует.

Перед передачей управления другому вызываемому выражению публикуются только собственные рабочие поля с активной отметкой `dirty`. После публикации отметки очищаются. Граница публикации — вызов, который может опубликовать или выпустить состояние, вызвать пользовательский код, войти в Message повторно или передать управление за пределы активации; неопределённый внешний вызов считается границей консервативно; приватный не-выпускающий помощник, служащий только обходу текущей активации, классификации адреса или явной графовой операции, — не граница, даже если он читает или пишет граф (источник 21.6). Так же публикуют все выходы — сквозной конец тела, `return`, `throw`, неуспешный `assert`, остановка и отмена — и приостановка `yield`. Неизменённое кэшированное поле без такой отметки не записывается обратно: вложенный вызов мог уже изменить его через явную ссылку. После возврата вызывающая активация не перечитывает свои рабочие значения из графа. Невозможность разрешить или записать связанное поле — диагностический `assert`; предназначенный внешний вызов после этого не выполняется. Общей транзакции с откатом предыдущих записей нет.

`dirty` определяется выполненной записью, не сравнением значений и не наличием возможного присваивания в исходном тексте; это семантическое состояние рабочих значений, а не обязательное физическое поле-флаг у каждой переменной: нативный транслятор может знать статически, что кэшированный локал изменён, и эмитировать запись на контрольной точке, интерпретатор — держать бит или битовую карту. Публикация следует прямому порядку полей; успешная запись очищает отметку соответствующего поля. Публикация нужна также перед внешней границей, способной вызвать LMX обратно или раскрыть состояние графа.

Следовательно, после вложенного изменения `node\x` рабочее голое `x` вызывающего выражения может сохранять прежнее значение, тогда как явный путь видит новое. Позднейшее присваивание голому собственному `x` намеренно создаёт новую запись и опубликует её на следующей границе. Отсутствие автоматического перечитывания — часть семантики, а не разрешение терять отмеченные изменения.

<a id="activation-history"></a>
### Стек активаций, рекурсия и явная история

Стек активаций является единственной неявной историей вызовов. Нативное исполнение использует обычный стек вызовов C; интерпретатор — эквивалентный управляющий стек. Прямая, взаимная и callback-рекурсия создаёт отдельную активацию с собственными формальными и динамическими значениями, рабочими локальными значениями, результатом и отметками `dirty`; повторный вход получает свой экземпляр объявленных полей. Скрытый узел активации, окружение замыкания или глобальная запись активного аргумента не создаются.

Вызываемое вхождение хранит опубликованное состояние своей последней активации над собственным графом, но не журнал вызовов: повторный вход получает свой экземпляр, а приостановленная внешняя активация не перечитывается и сохраняет свои рабочие значения; позже её own-поле публикуется только после нового реального изменения. Другое вызываемое вхождение того же метода имеет свои поля. Итог определяет последовательный порядок публикаций только `dirty`-полей, а не восстановление снимка.

Трасса рекурсивного примера ниже не вводит новый синтаксис. Метод M имеет вызываемое вхождение S с полем `x`, начальное значение по объявлению 1; внешняя активация работает над S, повторный вход получает свежий экземпляр I2, а `n` является частным объявленным аргументом каждой активации; столбцы — рабочее значение каждой активации и опубликованное `S\x`.

| Шаг | Рабочее `x` внешней активации (объявлено в S) | Рабочее `x` экземпляра I2 | Опубликованное значение в месте объявления `x` в S (его читает `S\x` снаружи) |
| --- | --- | --- | --- |
| Внешний вход над S | 1, clean | — | 1 |
| Внешний вызов присваивает `x: 2` | 2, dirty | — | 1 |
| Публикация перед вызовом; вход `M(0)` создаёт экземпляр I2 | 2, clean | 1, clean | 2 |
| Внутренний вызов присваивает `x: 9` | 2, clean | 9, dirty | 2 |
| Внутренний возврат публикует в I2 | 2, clean | 9, активация завершена | 2 |
| Внешний вызов продолжается | 2, clean | — | 2 |
| Внешний вызов возвращается | 2, clean, активация завершена | — | 2 |

После возврата внутреннего вызова голое `x` внешней активации читает 2 — своё рабочее значение; опубликованное значение в месте объявления `x` в S тоже 2, и `S\x` снаружи читает 2: экземпляр повторного входа снаружи не виден. Если внешняя активация затем выполняет `x: x + 1`, её рабочее значение становится 3 и получает `dirty`; следующая граница публикует 3 в хранилище S. Это новая запись внешней активации, не восстановление её прежнего снимка. Динамически переданный `x` остаётся локальным аргументом и тогда, когда тело ему присваивает: присваивание обновляет это локальное значение, а поле есть только по объявлению — скрытый аргумент здесь ничем не отличается от явного.

Тем самым объявленное поле сочетает постоянство поля экземпляра с рабочей локальностью стековой переменной: использованное own-поле загружается в типизированное рабочее значение и записывается обратно только после изменения. Граф хранит опубликованное состояние, поля и экземпляры повторного входа; стек — историю активаций, локалы и результаты. Неявного захвата кадра вызывающего выражения нет, поэтому кадры не приходится размещать в куче или связывать скрытой цепочкой замыканий для решения upward-funarg-проблемы.

Следующий пример вызова показывает порядок между кэшем, явным чтением графа и фактическими аргументами; это трасса установленной формы `for:`, не новое правило грамматики. `j` объявлено во вложенном теле `for`: как рабочая переменная оно видно только вперёд и вниз, а путь `for\j` из объемлющего метода после `end: for` открывает его место объявления — объявление в любом случае заводит там значение (ответ автора, Q51); пример показывает порядок кэша, явного чтения и фактических аргументов; ячейка `j` в примере начинается с 0 — это условие примера, не общее правило инициализации `int`. `print` здесь — высокоуровневое вызываемое выражение профиля, не операция `c.*`.

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

После цикла рабочее `acc` равно 9. `end: for` не является контрольной точкой, как и само явное чтение пути. Перед вызовом объявленные фактические аргументы вычисляются в типизированные временные значения: `acc` даёт 9 из кэша, а `for\j` читает прежнее опубликованное значение графа 0. Затем публикация записывает 9 в граф, но вызов получает уже выбранные временные значения и печатает `9 0`. Последующее явное чтение `for\j` в другом операторе видит 9. Публикация не меняет задним числом уже вычисленные фактические аргументы; запись `for\j: 42` в той же активации меняет ячейку графа, не кэш.

Одна логическая последовательная полоса исполнения каждого Message делает эту модель безопасной без блокировок и барьеров памяти внутри такта. Приостановленные активации не участвуют в гонке; другие Message работают со своими аренами. Интерпретатор реализует ту же семантику управляющим стеком возвратов, аргументов, локалов и рабочих значений; полное состояние метода при вызове не копируется — загружаются только используемые own-поля, а экземпляр прототипа создаётся только при повторном входе.

Тело, переданное принимающему выражению как структура, и аргументы исполняемого вызова также не становятся общим скрытым окружением.

Публикация обязательна на границах вызова, возврата, `throw`, диагностического прекращения и `yield`. Выход с `finally` имеет две публикации, описанные в [выходах](#exits). `retry` и локальный переход цикла сами по себе не создают новую активацию и не перечитывают поля. Сигнатуры и граф сохраняют требования этой модели независимо от того, исполняется ли граф интерпретатором или транслируется.
[EN]
Value storage at a declaration in the complete Structure, a working value of the current activation, an explicit formal argument and a dynamic input must be distinguished. They have distinct mutation rules; a working copy does not create a second persistent graph. Ordinary passing copies a mutable primitive's value and a Structure or Array's reference; the special identity of an immutable value is retained under [qualification](#qualification).

For a free name, the called expression receives the current value from the caller's available context; if unavailable, permitted lexical lookup follows `node`. Own declarations and formal parameters have their respective resolved locations rather than being searched in a global registry. Required through-names are part of the signature: adding a free name changes the interface. A missing required input makes the call inadmissible; silently creating zero or a new field is prohibited. A callable's formal is not a free name of its body: it receives the supplied argument or its default value ([§11](#callables)), and the source priority below does not extend to an omitted formal.

A free name's sources have this priority: the caller's nearest current local binding, then its already inherited dynamic input, then the callee's lexical lookup. A local binding includes a used own field, formal argument, result or another receiver-defined local value. Statically known call requirements propagate to a fixed point, including through mutual recursion. A name needed only by the next call must still be retained and forwarded; forwarding alone creates no graph field.

Lexical lookup uses real Structure links, stops at a zero parent and selects, at the relevant step, the last same-named occurrence, as every unqualified name does ([names](#fields)); the explicit selector `[N]name` picks another. `independent` cuts only the external lexical fallback. Explicit access through `node\x`, `reference\x` or `array[index]` addresses the graph rather than being replaced by the current call's dynamic `x`. A lexical context copied by `merge` enters this order only as the fallback ([composition](#composition)).

An own field's working value is loaded for the activation from the graph: an own field of the current activation is a field of the callable occurrence itself (or of its instance under re-entry), and assigning that name changes the working value and marks it `dirty`; a checkpoint publishes it. Loading or reading a value does not itself mark it `dirty`. The load happens at activation entry and only for the own fields the body actually uses through bare names (origin 21.5): an explicit path written after entry changes the graph cell, while the bare name keeps reading the entry value until its own write. An explicit reference write changes the selected object directly and is observable through other references to it. An explicit or hidden argument is a value of the machine activation: it never becomes a field -- a field exists only by declaration -- its assignment updates that local value, and there is no copy-back to the caller.

Assignment updates an already resolved binding. It does not create an additional data field, either during execution or by causing the translator to preallocate one. Computed initialization is two ordinary adjacent statements: `int: i` declares, `i: findValue` assigns the call's result under the normal call rules when control flow reaches that line; there is no special initializer receiver, no construction phase and no hidden once-only initialization, and merely inspecting the stored program does not execute the call. After execution the complete Structure still contains both the declaration and the assignment calling `findValue`: the assignment changes the variable's working value, not the call, its operands or the instruction itself; a checkpoint writes a changed value only to its value storage, never into an initializer's executable representation. Simple literal declarations such as `int: i 5` are not banned by this. An explicit or hidden argument remains an activation-local value unless an explicit declaration establishes a graph-backed field. Assignment to the argument does not write back to its caller or silently create persistent method state. The body here is the callable expression (the method), not a nested `if`/`while`/block body: a declaration in the method's body gives the method its field, while a bare assignment inside a nested body creates no field of that nested body and writes into the declared field of the callable; a nested body's Structure holds only the fields declared in it (`fn: keep (int: n) int` with the body `int: n` / `if: 1` / `n: n + 1` / `return: n` gives `keep(3) = 4` -- the field `n` exists by the declaration `int: n`). See L2 §10. After assignment has been selected, `value` must resolve as an admissible typed candidate; an unknown value or admission failure is an assignment error, with no switch to another colon role. Translation has already fixed the prototype's layout, so execution changes no field count; publication of a declared own value targets storage at its declaration in the active Structure, never the caller's argument source or the parent graph.

Locality and storage duration are separate properties here. The place of declaration of a callable occurrence's variable retains the published value after the activation in the complete Structure -- where the declaration is written, with no separate field beside it; the activation's working variable is not visible from outside, while the path `M\x` from outside opens the place of declaration, since a declaration always establishes a value; a write into it is not a mutation of an outer binding: the caller's argument cell and the above-method space's field remain unchanged. Only an explicit `node\x` path write mutates that outer field, where `node` is the lexical parent's data.

In L3 @ retains reference semantics: reference declaration, acquisition from a resolved value, passing, rebinding and dereferencing are admissible without machine address arithmetic. @: Type var declares a typed reference variable; a third argument in @: Type var candidate supplies its initial candidate. Omitting it stores a null reference value rather than constructing a Type instance. Null is not an empty Structure; dereferencing an unbound reference yields no value. Type and var are separate receiver arguments, not an implicit chain of calls.

```text
@: A ptr_a A
@: A ptr_b B
ptr_b: @A
ptr_b: A
```

Here A and B are existing Structures. Candidate-to-reference conversion precedes implements(B, A, Consumer); only the admitted reference value is stored. Conversion belongs to the general table of primitive representations because a pointer is a primitive. That table does not enumerate pairs of user models; implements determines structural referent suitability. A reference variable does not become callable merely because its referent is executable: ptr_b: A assigns; explicit \ptr_b is used to invoke the referent.

| Form | L3 meaning |
| --- | --- |
| @: var | Declare a reference without a referent-type requirement (void reference), initially 0 |
| @: Type var | Declare typed reference var, initially 0 |
| @: Type var candidate | Declare and initialize a reference after candidate conversion and admission |
| @: Type: var | Nested @(Type(var)) form; not an automatic synonym for separate arguments Type and var |
| @x, return: @x, passing @x as an argument | Obtain and transport a reference to the actual typed value without machine address arithmetic |
| @@: Type var, @@@: Type var and beyond | Declare deeper references with no artificial depth bound |
| \var | Dereference the reference; the resulting value determines the subsequent operation |

The target is the actual value, not the service slot by which the graph stores its reference. For ordinary Structure x, @x refers to its typed Lmx descriptor, not an internal void* child-reference cell; the C projection is Lmx*, not automatically Lmx**. For explicitly referenced variable p, @p addresses its reference-value cell and adds one level; ordinary p reads the stored reference. For a primitive or an Array element the target is its corresponding typed cell. Machine projection and lifetime details are defined in [L2 §18](L2_spec_en.md#lowlevel-address).

Passing or returning a reference variable transports its value, not the variable's address. A new Structure requires an explicit definition or merge; @ declaration does not clone a referent. L3 exposes no numeric address, machine cast, arbitrary raw memory access or arithmetic address modification. Portable references, including @x acquisition and dereferencing, are not prohibited because of L2's machine implementation: admissibility is determined by the operation, not the presence of @.

Every body that a receiving expression executes statement by statement is a graph Structure hosting its directly declared fields. Bodies of `if`, `else`, loops and other receivers form a containment hierarchy, not a flat method-field list. An untaken branch performs no assignments. An ordinary nested block creates neither another method activation nor a dynamic-input boundary. Conditions, call arguments and `return` arguments are not executable bodies merely by being arguments: their receiving expression determines the role, not a Structure in the last syntactic position.

```text
fn: remember (int: x) int
    x: 7
    return: x
end: remember
```

Here `x: 7` updates the local argument `x`, and `remember(3)` returns 7; no field of `remember` arises from it, the caller's variable is unchanged, and `remember` keeps no state. A field exists only where a declaration puts it: `int: x 3` in the body would declare one, and then the bare name reads and writes that field through the working copy. Only own fields actually used by a bare name or to forward a dynamic input are cached; an explicit path reads the graph and alone creates no own cache; a field does not vanish from the graph because no bare name uses it.

Before control passes to another callable expression, only own working fields with an active `dirty` mark are published. Marks are cleared after publication. A publication boundary is a call that may publish or escape state, invoke user code, re-enter the Message or transfer control outside the activation; every uncertain external call is treated conservatively as one; a private, non-escaping helper used only for the current activation's own traversal, address classification or explicit graph operation is not a boundary, even if it reads or writes the graph (origin 21.6). Every exit -- fallthrough of the body, `return`, `throw`, a failing `assert`, stop and cancellation -- and `yield` suspension publish the same way. A cached field without such a mark must not be written back: a nested call may already have changed it through an explicit reference. After return, the caller activation does not reload its working values from the graph. Failure to resolve or store into a bound field uses diagnostic `assert`; the intended outbound call is not executed afterward. There is no general transaction rolling back earlier writes.

Dirty state follows an executed write, not value comparison or the presence of a possible assignment in source; it is semantic working-state information, not a mandatory physical flag field per variable: a native translator may statically know that a cached local was modified and emit the store at the checkpoint, while an interpreter may keep a bit or a bitmap. Publication follows forward field order; a successful write clears the corresponding mark. Publication is also required before a foreign boundary capable of calling back into LMX or exposing graph state.

Consequently, after a nested modification of `node\x`, the caller's bare working `x` can retain its earlier value while an explicit path observes the new value. A later assignment to bare own `x` deliberately creates a new write and publishes it at the next boundary. No automatic reload is part of the semantics, not permission to lose dirty changes.

<a id="activation-history"></a>
### Activation stack, recursion and explicit history

The activation stack is the sole implicit call history. Native execution uses the ordinary C call stack; the interpreter uses an equivalent control stack. Direct, mutual and callback recursion creates a distinct activation with its own formal and dynamic values, working locals, result and `dirty` marks; a re-entrant activation receives its own instance of the declared fields. No hidden activation node, closure environment or global active-argument record is created.

The callable occurrence holds the published state of its latest activation over its own graph, but it is not a call journal: a re-entrant activation receives its own instance, while a suspended outer activation is not reloaded and keeps its working values; later its own field is published only after a new real change. Another callable occurrence of the same method has its own fields. The result is determined by the sequential order of publications of `dirty` fields only, not by restoring a snapshot.

The following recursive trace introduces no new syntax. Method M has callable occurrence S with field `x`, initial value 1 by declaration; the outer activation works over S, the re-entrant call receives a fresh instance I2, and `n` is a private declared argument in each activation; the columns are each activation's working value and the published `S\x`.

| Step | Outer activation's working `x` (declared in S) | Instance I2's working `x` | Published value at the place of declaration of `x` in S (what `S\x` from outside reads) |
| --- | --- | --- | --- |
| Outer entry over S | 1, clean | — | 1 |
| Outer call assigns `x: 2` | 2, dirty | — | 1 |
| Pre-call publication; `M(0)` entry creates instance I2 | 2, clean | 1, clean | 2 |
| Inner call assigns `x: 9` | 2, clean | 9, dirty | 2 |
| Inner return publishes into I2 | 2, clean | 9, activation ended | 2 |
| Outer call resumes | 2, clean | — | 2 |
| Outer call returns | 2, clean, activation ended | — | 2 |

After the inner return, the outer activation's bare `x` reads 2, its own working value; the published value at the place of declaration of `x` in S is 2 as well, and `S\x` from outside reads 2: the re-entrant instance is not visible from outside. If the outer activation then executes `x: x + 1`, its working value becomes 3 and is marked `dirty`; the next boundary publishes 3 into S's storage. This is a new outer-activation write, not restoration of its previous snapshot. A dynamically supplied `x` remains a local argument even when the body assigns it: the assignment updates that local value, and a field exists only by declaration -- a hidden argument differs in nothing from an explicit one here.

A declared field therefore combines the persistence of an instance field with the working locality of a stack variable: a used own field is loaded into a typed working value and written back only after a change. The graph stores published state, fields and re-entrant instances; the stack stores activation history, locals and results. There is no implicit caller-frame capture, so frames need not be heapified or connected by a hidden closure chain to avoid the upward-funarg problem.

The following call example shows the order among cache, explicit graph read and actual arguments; it is a trace using the established `for:` form, not a new grammar rule. `j` is declared in the nested `for` body: as a working variable it is visible only forward and down, while the path `for\j` from the enclosing method after `end: for` opens its place of declaration -- a declaration always establishes a value there (the author's answer, Q51); the example shows the order of cache, explicit read and actual arguments; the cell of `j` starts at 0 in this example, which is an example condition, not a general initialization rule for `int`. Here `print` is a high-level profile callable, not a `c.*` operation.

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

After the loop, working `acc` is 9. `end: for` is not a checkpoint, and neither is an explicit path read by itself. Before the call, declared actual arguments are evaluated into typed temporaries: `acc` contributes 9 from the cache, while `for\j` reads the previously published graph value 0. Publication then writes 9 into the graph, but the call receives the already selected temporaries and prints `9 0`. A later explicit `for\j` read in another statement sees 9. Publication cannot retroactively change actual arguments already evaluated; a same-activation `for\j: 42` writes the graph cell, not the cache.

One logical serial execution lane per Message makes this model safe without locks or memory barriers within a turn. Suspended activations take no part in a race; other Messages work in their own arenas. The interpreter implements the same semantics with a control stack of returns, arguments, locals and working values; the method's full state is not copied on a call -- only the used own fields are loaded, and a prototype instance is created only on re-entry.

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

`catch` — точка приёма в блоке вызывающего выражения, не обычный вложенный `sub`. При первом прямом проходе её тело пропускается. После доставки соответствующего отказа тело выполняется, затем исполнение продолжается с операторов после этого `catch`. Поэтому обработчик, поставленный до вызова, повторно вводит выполнение в последующий участок; обработчик после вызова продолжает за собой. Участок ограничен следующим `catch` того же блока или концом блока. Обработчик действует на все вызовы своего блока, включая вызовы из вложенных в него операторных блоков (`if`, `while`, `for`, анонимный `---`): это не особое правило `catch`, а общее свойство видимости callable — обработчик, как и метод, виден во всём своём блоке в обе стороны. Блок-сосед им не покрывается.

Два одноимённых обработчика в одном блоке запрещены; отдельные вложенные блоки могут иметь каждый свой. Доставка выбирает обработчик по блоку вызова, не одноимённый обработчик соседнего блока. Повторный `throw` того же имени внутри обработчика не входит в этот обработчик заново: это отказ во внешнем вызывающем контексте. Необработанное имя распространяется только через соответствующие объявления `throws`.

Операторы языка, у которых программист не видит явного перечисления `throws` (например, `merge`), тоже бросают именованный отказ, но отлавливать его не обязательно: обработчик `catch: merge` — до вызова, после него или в отдельном вложенном блоке — обрабатывает его стандартно, и никуда он не улетает; неотловленный неявный отказ улетает в корень исполняющегося Message, и поток останавливается (`running = 0`). Единственное ограничение размещения — то же, что и для объявленных имён: два одноимённых `catch` не могут спорить на одном уровне.

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

`catch` is a landing pad in the caller's block, not an ordinary nested `sub`. Its body is skipped on the initial straight-line pass. When the corresponding failure arrives, its body runs and execution continues with the statements after that `catch`. Consequently, a handler before a call re-enters the following region; a handler after the call continues past itself. The region ends at the next `catch` in the same block or the block's end. The handler covers every call of its block, including calls made from statement blocks nested inside it (`if`, `while`, `for`, an anonymous `---`): this is not a special `catch` rule but the general visibility property of callables -- a handler, like a method, is visible throughout its block in both directions. A sibling block is not covered.

Two same-named handlers in one block are prohibited; separate nested blocks can each have one. Delivery selects the handler by the calling block, not a same-named handler in a sibling block. Throwing the same name inside a handler does not re-enter it: this is a failure in the enclosing calling context. An unhandled name propagates only through matching `throws` declarations.

Language operators whose `throws` list the programmer does not see written out (for example `merge`) also throw a named failure, but catching it is optional: a `catch: merge` handler -- before the call, after it, or in a separate nested block -- handles it in the ordinary way and nothing flies anywhere; an uncaught implicit failure flies to the root of the executing Message and the Thread stops (`running = 0`). The only placement constraint is the one declared names have: two same-named `catch` handlers cannot compete at one level.

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

Общий физический дескриптор Array — `VoidArray {size_t size, void *data}`. В `Lmx {VoidArray array, Lmx *parent}` тот же дескриптор вложен по значению первым полем и является самим массивом дочерних физических ссылок; его backing зарегистрирован как адресный диапазон арены, но запись диапазона не является самим `VoidArray`. Отдельный псевдоним `LmxArrayDesc` не нужен. У самостоятельного Array `size` — логическое число элементов, backing содержит ровно столько ячеек. У базового Array нет `capacity`, и он не растёт, не делает resize/append и не переключает backing. Динамическое членство, ёмкость и рост принадлежат только отдельным динамическим дескрипторам вида `{<T>Array array; size_t capacity}`, где `<T>Array` — уже существующий фиксированный дескриптор реального типа элемента T (void — лишь один из типов: сегодня `LmxArrayDesc` только для элементов `void *`; массив int — `{size_t len; int *data}`, без void-дескриптора и без приведений). List (`KIND_LIST`) — публичный такой DynamicArray над элементами `void *`, без скрытого префикса capacity в backing. Физические адреса объектов-ссылок от роста List не зависят; адрес ячейки закрытого backing List не сохраняется через его замену.

`length(array)` читает число элементов из дескриптора Array (`len` у типизированного дескриптора, `size` у `VoidArray`); для прямоугольного массива это общее число, не первая размерность. Дескриптор не хранит размерности и не позволяет восстановить их из общего числа элементов. Число полей содержащей структуры, длина массива и размер служебного пула дескрипторов различаются.

Встроенные машинные типы элементов сохраняют [смысл типов целевого профиля C99](L2_spec_ru.md#lowlevel-scope), включая знаковость обычного `char`; дескриптор не переопределяет их. L3 добавляет проверяемый доступ, а не другое представление примитивов.

Полный индекс N-мерного прямоугольного массива содержит N целочисленных координат. Для прямоугольного массива координаты сводятся к одному линейному индексу элемента, последний индекс меняется быстрее: `k = (...((i0 * d1 + i1) * d2 + i2)...)`. L3 проверяет только итоговый элемент относительно общей длины в дескрипторе: `0 <= k < length(array)`. Каждая координата отдельно с размерностью не сверяется, вектор длин размерностей ради этих проверок не хранится. Например, в прямоугольнике `[2,3]` координаты `[0,3]` дают линейный индекс 3 и выбирают тот же элемент, что `[1,0]`; линейный индекс 6 даёт отказ `Bounds`, не `None`. Вычисление индекса не должно превращать математически выходящий за границы результат в допустимый элемент через машинное переполнение. Массив ссылок на массивы отличается: каждый шаг обращается к другому действительному Array со своим дескриптором.

Частичный индекс может дать представление (*view*), например первая строка `matrix[0]`; полный `matrix[0, 2]` выбирает элемент. Конкретная запись координат задаётся [грамматикой](LMX_grammar.ru.md). Эти проверки доступа принадлежат только L3, как нативному, так и интерпретируемому: [доступ L2](L2_spec_ru.md#lowlevel-address), включая получение адреса элемента графового массива, работает без них. Проверки операции не являются отдельным механизмом допуска кандидата вместо [анализа и юнит-тестов](#admission).

Копия массива имеет отдельное хранилище; передача ссылки сама по себе его не создаёт. Возврат ссылки не должен скрыто копировать данные для исправления времени жизни. Совместное хранилище сохраняет обычные границы владельца Message.

[EN]
An ordinary Array is a typed value with stable reference identity. Constructor `[]` creates it when execution reaches the construction site. A Structure field holding its reference is not the Array itself. Passing a reference does not copy elements; an element mutation is visible through other references, whereas rebinding a local reference is not.

An owning Array has one contiguous rectangular block of elements. Nested dimensions do not mean separately allocated rows. For shape `[d0, …, dN−1]`, element count is the product of dimensions, with the last index varying fastest. An Array of references to other Arrays is a different value, not a replacement for a rectangular multidimensional Array. Primitive elements acquire no lexical parents.

The common physical Array descriptor is `VoidArray {size_t size, void *data}`. In `Lmx {VoidArray array, Lmx *parent}`, the same descriptor is embedded by value as the first member and is the actual array of physical child references; its backing is registered as an arena address range, but the range entry is not the `VoidArray` itself. A separate `LmxArrayDesc` alias is unnecessary. For a standalone Array, `size` is its logical element count and the backing has exactly that many cells. Base Array has no `capacity` and does not grow, resize, append, or switch backing. Dynamic membership, capacity, and growth belong only to separate dynamic descriptors of the form `{<T>Array array; size_t capacity}`, where `<T>Array` is the already existing fixed descriptor of the real element type T (void is only one element type: today `LmxArrayDesc` solely for `void *` elements; an int array is `{size_t len; int *data}`, never the void descriptor with casts). List (`KIND_LIST`) is a public such DynamicArray over `void *` elements, with no hidden capacity prefix in the backing. Physical addresses stored as referent values are unaffected by List growth; a List backing-slot address does not survive private-backing replacement.

`length(array)` reads the element count from the Array descriptor (`len` in a typed descriptor, `size` in `VoidArray`); for a rectangular Array this is the total count, not its first dimension. The descriptor does not store dimensions and cannot reconstruct them from the total element count. The containing Structure's field count, Array length and service descriptor-pool size are distinct.

Built-in machine element types retain their [C99 target-profile meaning](L2_spec_en.md#lowlevel-scope), including plain `char` signedness; a descriptor does not redefine them. L3 adds checked access, not a different primitive representation.

A full N-dimensional rectangular Array index contains N integer coordinates. For a rectangular Array, coordinates are reduced to one linear element index in row-major order: `k = (...((i0 * d1 + i1) * d2 + i2)...)`. L3 checks only the final element against the descriptor's total length: `0 <= k < length(array)`. It does not check each coordinate against its dimension or store a vector of dimension lengths for those checks. For example, in a `[2,3]` rectangle, `[0,3]` has linear index 3 and selects the same element as `[1,0]`; linear index 6 fails with `Bounds`, not `None`. Computing the index must not wrap an out-of-range mathematical result into a valid element. An Array of references to Arrays is different: each step accesses another actual Array with its own descriptor.

A partial index may produce a view, such as first row `matrix[0]`; full `matrix[0, 2]` selects an element. Coordinate spelling belongs to the [grammar](LMX_grammar.en.md). These access checks belong only to L3, whether executed natively or interpreted: [L2 access](L2_spec_en.md#lowlevel-address), including obtaining a graph-backed element's address, works without them. Operation checks do not constitute a separate candidate-admission mechanism in place of [analysis and unit tests](#admission).

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

Копируется полный используемый граф с необходимыми ссылками и лексическими цепочками до нулевого родителя. Одна карта «источник — копия» используется для всех операндов: общие цели остаются общими, циклы сохраняются, ссылки и `parent` явно переписываются. Корни операндов и необходимые лексические предки не добавляются лишними видимыми полями результата. Лексический родитель нового корня определяется местом выражения `merge`. Для обычных копируемых целей сохранение связей означает, что ссылки результата указывают на соответствующие копии, а не на исходный граф; удержание исходных целей ограничено ссылками на переиспользуемую нативную реализацию и допущенной ветвью `independent: const: immutable` (ниже). Сохранение связей внутри копии не связывает аргументы и не меняет приоритет динамических входов.

Обход полного используемого графа сам по себе не даёт доступа к защищённой ветви или полномочия экспортировать её содержимое. Композиция сохраняет [выбранный контракт защиты объекта](#protected-structures); `merge` не является обходным способом открыть защищённый контекст.

Ссылка на переиспользуемую нативную реализацию метода — терминал своего контракта: реализация получает граф, с которым исполняется, и её адрес не есть идентичность этого графа или его лексического окружения; общей ссылкой на изменяемое вызываемое вхождение или его лексический контекст она не является. Когда `merge` встречает [вечную ветвь](#eternal) `independent: const: immutable`, он обязан **не копировать** её, а поместить в результат исходную физическую ссылку — это явное, единственное исключение из общего правила копирования, исключение для квалифицированной ветви графа: у её корня нет внешнего лексического родителя, а квалифицированное содержимое неизменяемо, поэтому копия ничего не даёт. Право на исключение даёт только совместная квалификация — не одна `independent`, не один нулевой родитель и не одна `immutable`; действуют существующие контракты квалификации и срока жизни, нового флага, ресивера или реестра нет. Физическая идентичность сохраняется, владельцем остаётся исходный модуль. Реализация и вечная ветвь — разные виды удерживаемого материала, даже когда оба называются терминалами. Видимость и учёт индекса диапазонов выполняются внутри merge/классификатора; это не отдельная видимая операция и не альтернатива `merge`. Остальное изменяемое использованное состояние получает отдельное хранилище. Алгоритм не оставляет ссылки на изменяемую чужую арену.

### Слоты модели, совпадение и порядок полей

Первый операнд — модель результата. Поле более позднего операнда или дописанного тела, совпадающее с полем модели (совпадение известно при трансляции — имя и тип; допуск как при присваивании), записывается **в слот модели**, а не добавляется рядом; поле без соответствия дописывается в конец в порядке операндов. Результат имеет раскладку модели, за которой следуют новые поля, поэтому номера полей модели не сдвигаются, и никакого скрытого смещения у методов нет.

### Композиция структурных частей

Вызываемая Structure состоит из именованных частей `args`, `return` и `body`; любая другая Structure, именованная или безымянная, — это одна часть `body`; отсутствующая часть участвует в `merge` как пустая Structure того же смысла. `merge` идёт попарно по частям и рекурсивно — `args` с `args`, `return` с `return`, `body` с `body` — на каждом уровне по правилу выше: одноимённое поле операнда записывается в слот модели, новое дописывается. Модель остаётся внешней рамкой, каждый следующий операнд сливается внутрь неё, как содержимое каталога в каталог: `merge(add; y: 5)` кладёт поле `y` в `body` метода `add` (специализация: для формала `y` метода `add` этот датум — его значение по умолчанию, ниже), а `merge((n: 5); addN)` кладёт метод `addN` внутрь Structure с полем `n` как вложенное поле — такая Structure сама не вызываема (в её поле 0 стоит `n`), вызов пишется `w\addN(…)`; `n` в теле `addN`, если его не дал ни один обычный динамический источник, разрешается лексическим запасным путём в поле объемлющей Structure — приоритет [§12](#dynamic) не меняется. Безымянные операторы `body` слотов не имеют: операторы операнда заменяют операторы модели, если у операнда они есть, — это выбор целого тела на соответствующем уровне композиции; машинные тела не склеиваются в новую составную машинную функцию, а обычные вложенные методы, вызовы и структура программы этим правилом не отменяются.

### Явное описание вызываемого

Там, где объявлен вызываемый тип — заголовок `fn: add5 (int: x) int merge(add; y: 5)`, результат `fn` у `fn: makeAdder (int: n) fn`, вызываемый формал или цель присваивания, — объявленный заголовок есть тип принимающего места, а не дополнительный операнд композиции: результат `merge` допускается в него обычным допуском ([§7](#admission), `implements`) с применимыми общими преобразованиями и обычной подготовкой входов, включая значения по умолчанию. Автоматического второго `merge` с заголовком (`merge(add; {y: 5}; объявленный заголовок)`) нет, как нет и неявной полной замены описания аргументов более коротким заголовком: объявленный тип места с одним требуемым аргументом не вырезает поля кандидата и не меняет ABI его машинного тела; если программа сама явно компонует Structure описаний, действует обычная композиция полей, и отсутствие `y` в дополняющей `args = [x]` — не команда удалить `y` из модели `args = [x, y]`. В `add5` формал `y` остаётся формалом, у которого теперь есть значение по умолчанию 5 ([§11](#callables)): уменьшается набор аргументов, которые необходимо предоставить явно, а формалы и остальные требования выбранного тела не исчезают — «сигнатура `add` пропадает» сказано неточно. `merge` не связывает формалы: `y` можно не подавать, но можно и подать явно, и в свободный динамический вход он не превращается — одноимённое значение вызывающего, не поданное аргументом, `add5` не получает; свободные имена тела разрешаются по приоритету [§12](#dynamic), как и прежде. Семантическая иллюстрация, не новый синтаксис:

```text
add5: the formal y of add has the default value 5; x is required
add5(1)                        -> 6
add5(1; y: 25)                 -> 26    (y stays an explicitly passable formal)
add5(1; y: 0)                  -> 1     (zero is a supplied value, not an absent one)
caller holds its own y = 25, passes no y:  add5(1) -> 6   (a formal is not a free input)
add5(1; y: 25), then add5(1)   -> 26, then 6   (one call's argument is not a new default)
```

### Нативная реализация и копия вызываемого вхождения

Результат `merge` исполняет выбранное тело, и слово `native` результата относится к этому телу, а не к факту композиции. Если тело копии не изменилось — скопировано существующее вызываемое, или изменены и дополнены только данные, — сохраняются код модели и его нативная реализация, когда она есть: она получает нужный граф скрытыми аргументами и работает с предоставленными данными; другой адрес экземпляра, копирование его лексического состояния или другие значения данных сами по себе не требуют другой машинной функции, и `merge` не есть команда «перевести результат в интерпретируемый режим». Если телом целиком выбран код другого операнда, у которого есть своя нативная реализация, выбираются этот код и его `native`, а не адрес прежнего тела модели. Если получено изменённое тело, для которого соответствующей нативной реализации нет, прежний адрес использовать нельзя: слово `native` результата пусто, и он исполняется интерпретатором в рамках обычного контракта L3 — к этому случаю относится подтверждение автора от 2026-09-25 «результат интерпретируемый», а не к неизменённому коду над другими данными. «Тело изменилось» здесь значит изменение исполняемого кода, а не изменение данных в части с именем `body`. Нет ни правила «после любого `merge` `native` пусто», ни правила «старый `native` годится после любой замены кода»: адрес относится к конкретной исполняемой реализации. Перенумерация операций — не обязательный эффект копирования или изменения данных: когда меняются только данные, сохраняется раскладка, которую потребляет выбранный код, — слоты модели на своих местах, новые поля дописаны по общему правилу; переписывание графовых ссылок в копии не есть переписывание алгоритма. Вложенные методы переносятся целиком и сохраняют свои слова `native`. Нативная реализация метода никогда не сливается. Поле другой Structure, ссылающееся на метод (`A: fn: M`), сохраняет при `merge` общую ссылку на его нативную реализацию: нативная реализация получает узел графа, поэтому ссылку на неё можно сохранить; к Structure это отношения не имеет, и уровень объявления метода (файл, тело операнда) ничем не отличается от других уровней (автор, Q44, 2026-09-28). Вхождение метода, как любая достигнутая Structure, копируется по общему правилу — с единственным исключением квалифицированной вечной ветви выше — и сохраняет свои номера полей; уровень объявления сам по себе не даёт права удержать исходное вхождение. Сохранение нативной реализации не есть сохранение исходного изменяемого вызываемого вхождения вместе с его состоянием: обычные используемые Structure и лексические связи копируются, копия не подписана на дальнейшие изменения оригинала, и ссылки на исходные изменяемые данные ради `native` не удерживаются — именно передача графа скрытыми аргументами позволяет одной реализации работать с разными копиями.

### Возвращаемый вложенный метод

Так же строится возвращаемый вложенный метод: активация компонует реально используемые ею значения в данные вложенного вызываемого вхождения тем же `merge` — код `addN` остаётся неизменённым (и его нативная реализация, если она есть), данные результата — данные `addN` с дописанным значением активации (`n: значение активации`); объявленный тип результата (`fn` у `makeAdder`) проверяет получившийся callable обычным способом и третьим неявным операндом не становится. Скрытого окружения замыкания не возникает, а копирование не есть частичное применение и не замораживает вход вызова: свободное имя `n` тела `addN` (не его формал) остаётся свободным именем — скопированное значение есть лексический запасной путь, приоритет [§12](#dynamic) сохраняется, а явный `node\n` читает соответствующее лексическое состояние; лишь когда `n` — формал выбранного метода, скопированное значение — его значение по умолчанию (выше). Успешная композиция публикует полностью инициализированный результат, не требует регистрации коротких имён и не меняет источники.

### Динамические источники и лексический запасной путь

Копирование локально используемого лексического дерева не меняет разрешение динамических входов. При последующем вызове голое имя входа — свободное имя тела, не его формал ([§11](#callables)) — по-прежнему берётся из обычных динамических источников вызывающего до лексического запасного пути; скопированный лексический контекст даёт запасные данные, а не захват, переопределяющий вызывающего. Явный путь `node\…` выбирает этот лексический контекст непосредственно. `merge` не вводит операции связывания аргументов. То же правило действует после композиции и внутри независимых ветвей: отсечение внешнего лексического родителя не запрещает динамические входы от текущего вызывающего, и переиспользование вечной ветви не превращает её допустимые входы в константы. Семантическая иллюстрация, не новый синтаксис:

```text
copied lexical context:  x = 10      (x is a free name of the body, not its formal)
caller supplies:         x = 25
read x       -> 25
read node\x  -> 10
next call, caller supplies x = 40:  read x -> 40
no dynamic x from any source:       read x -> 10   (the permitted lexical fallback)
no admissible source at all:        ordinary missing-input diagnostic
```

Неуспех — throw с именем `merge` (как у любого оператора, в котором программист не видит явного перечисления `throws`): отлавливать его не обязательно; неотловленный улетает в корень, и поток останавливается (`running = 0`); найденная точка обработки `catch: merge` — до вызова, после него или в отдельном вложенном блоке, по правилам [объявленных отказов](#exceptions) — обрабатывает его стандартно, и никуда он не улетает. Отдельного протокола частичного результата нет. Это не обещание отката побочных эффектов вычисления операндов. Правила освобождения временного хранилища принадлежат владельцу Message. Точный низкоуровневый механизм — [L2](L2_spec_ru.md#copy-merge).

Описание типа, схема, данные модуля или таблица являются обычными данными: применение к ним `merge` не выбирает особый алгоритм композиции дескрипторов. `table` материализует явно выбранное табличное представление; `join` создаёт новый табличный граф, не меняя операнды. Политики строк, ключей, конфликтов и приоритета задаёт табличная операция, не структурное правило поиска поля.

Передача владения уже существующим хранилищем при доставке Message — [другая операция](#delivery), без копирования и без переподчинения структурного `parent`. Сочетание политик допуска — также не `merge`: оно выбирает и проверяет явно переданные данные, не строит структурную копию по умолчанию.
[EN]
`merge` is an executable operation over live structural operands. It is neither a preprocessor include, C-type composition nor mutation of source values. Operands are evaluated once left-to-right; a fresh root is then built with direct fields in operand and appended-body order. A previous `merge` result can itself be an operand.

The complete used graph is copied with required references and lexical chains to a zero parent. One source-to-copy map spans all operands: shared targets remain shared, cycles are preserved, and references and `parent` links are explicitly rewritten. Operand roots and necessary lexical ancestors do not become extra visible result fields. The new root's lexical parent follows the `merge` expression's location. For ordinary copied targets, preservation of relationships means that the result's links refer to the corresponding copied objects, not to the original graph; retention of original targets is limited to reusable native implementation references and the admitted `independent: const: immutable` branch (below). Preserving relationships inside a copy does not bind arguments or change dynamic-input precedence.

Traversal of the complete used graph does not itself grant access to a protected branch or authority to export its contents. Composition preserves the [selected object-protection contract](#protected-structures); `merge` is not an alternative route for opening a protected context.

A reference to a method's reusable native implementation is a terminal under its contract: the implementation receives the graph with which it executes, and its address is not the identity of that graph or of its lexical environment; it is not a shared reference to a mutable callable occurrence or to its lexical context. When `merge` encounters an [eternal branch](#eternal) qualified `independent: const: immutable`, it MUST **not copy** it and MUST place the original physical value reference directly into the result -- the explicit, single exception to the general copying rule, an exception for a qualified branch of the graph: its root has no external lexical parent and its qualified contents cannot change, so a copy would gain nothing. Only the combined qualification grants the exception -- not `independent` alone, not a null parent alone, not `immutable` alone; the existing qualification and lifetime contracts apply, and there is no new flag, receiver or registry. Physical identity is preserved and the source module remains the owner. An implementation and an eternal branch are different kinds of retained material, even where both are called terminals. Range-index visibility and bookkeeping occur inside merge/classification; they are neither a separate visible operation nor an alternative to `merge`. Other used mutable state receives distinct storage, and the algorithm leaves no references into another mutable arena.

### Model slots, field matching and ordering

The first operand is the result's model. A field of a later operand or of the appended body that matches a model field (the match is known at translation: name and type; admission as for assignment) is written **into the model's slot**, not added beside it; a field with no counterpart is appended at the end in operand order. The result has the model's layout followed by the new fields, so the model's field indices never move and methods carry no hidden offset.

### Composition of structural parts

A callable Structure consists of the named parts `args`, `return` and `body`; every other Structure, named or anonymous, is one `body` part; a missing part takes part in `merge` as an empty Structure of the same meaning. `merge` proceeds part by part and recursively -- `args` with `args`, `return` with `return`, `body` with `body` -- under the rule above at every level: an operand's same-name field is written into the model's slot, a new one is appended. The model stays the outer frame and each later operand merges inward, as a directory's contents into a directory: `merge(add; y: 5)` puts the field `y` into the `body` of the method `add` (specialization: for the formal `y` of `add` that datum is its default value, below), while `merge((n: 5); addN)` puts the method `addN` inside the Structure holding `n` as a nested field -- such a Structure is not itself callable (its field 0 is `n`), the call is written `w\addN(...)`; `n` in the body of `addN`, when no ordinary dynamic source supplies it, resolves by the lexical fallback to the enclosing Structure's field -- the priority of [§12](#dynamic) is unchanged. Nameless `body` statements have no slots: the operand's statements replace the model's when the operand has any -- a selection of a whole body at the relevant composition level; machine bodies are never glued into a new composite machine function, and ordinary nested methods, calls and program structure are not cancelled by this rule.

### Explicit callable descriptions

Wherever a callable type is declared -- the header `fn: add5 (int: x) int merge(add; y: 5)`, the result `fn` of `fn: makeAdder (int: n) fn`, a callable formal or an assignment target -- the declared header is the type of the receiving place, not an additional operand of the composition: the `merge` result is admitted into it by ordinary admission ([§7](#admission), `implements`) with the applicable general conversions and the ordinary preparation of inputs, including default values. There is no automatic second `merge` with the header (`merge(add; {y: 5}; the declared header)`), and no implicit whole replacement of the argument description by a shorter header: a declared place type with one required argument neither cuts the candidate's fields nor changes the ABI of its machine body; when the program itself explicitly composes description Structures, ordinary field composition applies, and the absence of `y` in a complementing `args = [x]` is not a command to delete `y` from the model's `args = [x, y]`. In `add5` the formal `y` remains a formal that now has the default value 5 ([§11](#callables)): the set of arguments that must be supplied explicitly shrinks, while the formals and the other requirements of the selected body do not disappear -- "the signature of `add` disappears" is said imprecisely. `merge` binds no formal: `y` may be left unsupplied, but it may also be supplied explicitly, and it does not turn into a free dynamic input -- a same-named value of the caller that is not passed as an argument does not reach `add5`; the body's free names resolve by the priority of [§12](#dynamic), as before. A semantic illustration, not a new syntax:

```text
add5: the formal y of add has the default value 5; x is required
add5(1)                        -> 6
add5(1; y: 25)                 -> 26    (y stays an explicitly passable formal)
add5(1; y: 0)                  -> 1     (zero is a supplied value, not an absent one)
caller holds its own y = 25, passes no y:  add5(1) -> 6   (a formal is not a free input)
add5(1; y: 25), then add5(1)   -> 26, then 6   (one call's argument is not a new default)
```

### Native implementation reuse and copied callable occurrences

A `merge` result executes the selected body, and the result's `native` word belongs to that body, not to the fact of composition. When the copy's body is unchanged -- an existing callable was copied, or only data was changed or added -- the model's code and its native implementation, when it has one, are kept: the implementation receives the required graph through hidden arguments and works with the supplied data; another instance address, a copy of its lexical state or other data values do not by themselves require another machine function, and `merge` is not a command "switch the result to the interpreted mode". When another operand's code, which has its own native implementation, is selected as the whole body, that code and its `native` are selected, not the address of the model's former body. When a changed body is obtained for which no corresponding native implementation exists, the former address cannot be used: the result's `native` word is empty and it executes through the interpreter under the ordinary L3 contract -- the author's confirmation of 2026-09-25 "the result is interpreted" refers to this case, not to unchanged code over other data. "The body changed" here means a change of the executed code, not a change of the data in the part named `body`. There is neither a rule "after any `merge` `native` is empty" nor a rule "the old `native` fits after any code replacement": the address belongs to a particular executable implementation. Renumbering of operations is not a mandatory effect of copying or of changing data: when only data changes, the layout consumed by the selected code is kept -- the model's slots stay in place, new fields are appended by the general rule; rewriting graph references in a copy is not rewriting the algorithm. Nested methods are carried over whole and keep their `native` words. A method's native implementation is never merged. A field of another Structure that references a method (`A: fn: M`) keeps, under `merge`, a shared reference to the method's native implementation: the native implementation receives the graph node, so the reference to it can be kept; this has nothing to do with Structures, and the level a method is declared at (the file, an operand's body) differs in nothing from any other level (the author, Q44, 2026-09-28). A method's occurrence, like any reached Structure, is copied by the general rule -- with the single exception of the qualified eternal branch above -- and keeps its field indices; the declaration level by itself grants no right to retain the original occurrence. Keeping the native implementation is not keeping the original mutable callable occurrence together with its state: the ordinary used Structures and lexical links are copied, the copy is not subscribed to later changes of the original, and no references to the original mutable data are retained for the sake of `native` -- it is precisely passing the graph through hidden arguments that lets one implementation work with different copies.

### Returned nested methods

A returned nested method is built the same way: the activation composes the values it actually uses into the data of the nested callable occurrence by the same `merge` -- the code of `addN` stays unchanged (and so does its native implementation, when it has one), the result's data is the data of `addN` with the activation's value appended (`n: the activation's value`); the declared result type (`fn` of `makeAdder`) checks the resulting callable in the ordinary way and does not become a third implicit operand. No hidden closure environment arises, and the copy is neither partial application nor a freeze of a call-time input: the free name `n` of the body of `addN` (not its formal) remains a free name -- the copied value is the lexical fallback, the priority of [§12](#dynamic) is kept, and an explicit `node\n` reads the corresponding lexical state; only when `n` is a formal of the selected method is the copied value its default value (above). Successful composition publishes a fully initialized result, requires no short-name registration and leaves sources unchanged.

### Dynamic sources and the lexical fallback

Copying the locally used lexical tree does not change dynamic-input resolution. On a later call, a bare input name -- a free name of the body, not its formal ([§11](#callables)) -- continues to use the ordinary caller-provided dynamic sources before the lexical fallback; the copied lexical context supplies fallback data, not a capture that overrides the caller. An explicit `node\…` path selects that lexical context directly. `merge` introduces no argument-binding operation. The same rule applies after composition and inside independent branches: cutting the external lexical parent does not prohibit dynamic inputs from the current caller, and reusing an eternal branch does not turn its permissible caller-supplied inputs into constants. A semantic illustration, not a new syntax:

```text
copied lexical context:  x = 10      (x is a free name of the body, not its formal)
caller supplies:         x = 25
read x       -> 25
read node\x  -> 10
next call, caller supplies x = 40:  read x -> 40
no dynamic x from any source:       read x -> 10   (the permitted lexical fallback)
no admissible source at all:        ordinary missing-input diagnostic
```

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

Известные записи методов — переиспользуемые нативные реализации, не вызываемые вхождения — также могут быть явно собраны в неизменяемый типизированный массив той же арены и переданы через физические ссылки. Дополнительный индекс вместе со ссылкой не образует идентичность записи. Метод не хранит лексического родителя; его конкретное вызываемое вхождение предоставляет собственную структуру. Разделяемые записи остаются живы после завершения заимствующего дочернего Message, только если их явный владелец продолжает их удерживать. Скрытого глобального или корневого реестра методов нет.

R0 удерживает неизменяемые независимые ветви начального модуля только потому, что владеет этим лексически фиксированным модулем, порождает начальных детей и может явно передать им заранее известные физические ссылки. Позднее подключённый DLL-подобный модуль имеет собственные запечатанные типизированные диапазоны у своего владельца и в своей арене. Когда `merge` встречает его `independent: const: immutable` ветвь, потребитель получает в результате исходную физическую ссылку, а модуль остаётся владельцем. Это не превращает R0 в глобальное хранилище. Выгрузка такого модуля и срок жизни его диапазонов здесь не определены.

`merge` и создание Message сохраняют явно переданные ссылки на допущенные вечные ветви — по исключению квалифицированной ветви ([композиция](#composition)) — и на переиспользуемые нативные реализации методов как терминалы; обычное изменяемое вызываемое вхождение и его лексический контекст этим не разделяются, а копируются. Получение одной ветви не раскрывает массив удержания, настройки корня или остальные ветви. Изменяемое состояние по-прежнему копируется отдельно. Все ссылки внутри опубликованной вечной ветви должны иметь достаточный срок жизни; квалификация не делает случайную ссылку на освобождаемую память вечной.

Например, A и созданный из его шаблона B могут иметь один адрес вечной E и разные ячейки изменяемого x — это задуманное исключение для вечной ветви, а не ошибка псевдонимов. Завершение A и B не освобождает E. Одинаковое содержимое двух отдельно построенных ветвей не означает их автоматического интернирования. При переносе в другой процесс нативный адрес не становится сетевой идентичностью: нужен явный кодек.
[EN]
Combined qualification `independent: const: immutable` establishes a sealed immutable independent branch: its root has `parent = 0`, and its contents and protected bindings are immutable. For the initial lexically known module, explicit retention by owner R0 gives process-long storage. The qualification itself neither selects a global owner nor defines unloading of a future module. Any one qualification alone does not establish this sharing contract.

Process bootstrap may construct a translation-known immutable typed Array of physical references to such branches and explicitly supply it to the root Message. `merge` and Message creation neither append to nor inherit this Array automatically. Placement in the Array does not reparent a branch's lexical tree. Permitted runtime-value initialization occurs before publication without increasing the entry set.

Bootstrap may place the published branches and their retaining sealed typed ranges in the Root Thread's (`R0`) arena through the same mechanism that creates typed Arrays in any L3 Thread arena. Process lifetime follows from explicit ownership and retention by R0, not from a hidden table, special storage class, or root-only capability. Collection does not release these explicitly retained initial ranges; a reference to a branch in another Message is an external terminal for that Message's collector and does not transfer ownership.

Membership in the eternal-branch type is established by the same typed-address-range index used for all other physical types. Its sealed range remains in the explicit owner's ordinary arena; explicit owner retention and exclusion of that range from collection determine its lifetime, not a separate permanent store. These rules neither replace range classification nor become a flag on each branch.

Known method records -- reusable native implementations, not callable occurrences -- may likewise be assembled explicitly into an immutable typed Array in the same arena and supplied through physical references. A supplementary index alongside the reference does not form record identity. A method stores no lexical parent; its concrete callable occurrence supplies its own Structure. Shared records remain live after a borrowing child Message terminates only while their explicit owner retains them. There is no hidden global or root method registry.

R0 retains immutable independent branches of the initial module only because it owns that lexically fixed module, spawns the initial children, and can explicitly pass their translation-known physical references. A DLL-like module loaded later has its own sealed typed ranges under its own owner and in its own arena. When `merge` encounters its `independent: const: immutable` branch, the consumer receives the original physical reference in the result and the module remains the owner. This does not make R0 global storage. This specification does not yet define that module's unload operation or the lifetime of those ranges.

`merge` and Message creation retain explicitly supplied references to admitted eternal branches -- under the qualified-branch exception ([composition](#composition)) -- and to reusable native method implementations as terminals; an ordinary mutable callable occurrence and its lexical context are not shared this way but copied. Receiving one branch does not expose its retention Array, root settings or unrelated branches. Mutable state is still copied separately. Every reference within a published eternal branch must have sufficient lifetime; qualification does not make an arbitrary reference to reclaimable storage eternal.

For example, A and B constructed from A's template can have the same eternal E address and distinct mutable x cells -- the intended eternal-branch exception, not an aliasing defect. Finishing A and B does not release E. Equal contents of separately constructed branches do not imply automatic interning. Across processes a native address is not wire identity: an explicit codec is required.

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

@@ thread-message-api | Обычные вызовы LMX через Message-транспорт: `post` и ожидания ответов | Ordinary LMX calls over Message transport: `post` and reply waits | docs/new_parts; author 2026-09-26
[RU]
## 0. Требуется: заменить прежний проект внешнего API

Эта редакция заменяет предыдущие задания. Она описывает требуемую работу, а не утверждает, что живая реализация уже её выполняет. Окончательное уточнение автора отменяет промежуточные предложения о массивах API, словарях сигнатур и множественном выборе методов.

**В LMX уже есть Structure. Её вызов через другой Thread должен использовать ровно те же обычные правила вызова LMX, что и внутри Thread. Меняется только транспорт. Не определять и не реализовывать атомарный вызов заново внутри этого протокола.**

**`answer` заполняет отдельную принадлежащую отправителю таблицу ожиданий ответов и их назначений. Он не заполняет, не расширяет и не сужает публичный API методов.**

**Множественность `ask` и `answer` относится к транспорту и создаёт основу для bulk-операций. Она не означает, что один запрос исполняет все методы, которым случайно подошла сигнатура.**

Сохранить существующий синтаксис `post`, корреляцию по исходному сообщению, распределение ответов, доступ к состоянию доставки, вызовы по тайм-ауту, объявленные `throws`/`catch`, явные конверсии и вложенные описания входящих аргументов. Отменённые правила внешней диспетчеризации убрать из реализации, документации и тестов.

В частности, убрать из этого задания:

- Пользовательский граф-массив как отдельный экспортируемый API и производный от него словарь.
- Заменяющую его служебную таблицу, сначала содержащую сигнатуру самого Message, а затем пополняемую через `answer`.
- Особый почтовый поиск сигнатур, правила перегрузки по результату, запреты одинаковых сигнатур и фильтрацию по составу API.
- Автоматическое перечисление или возврат всех `sub` в ответ на письмо без тела.
- Автоматическое исполнение всех подходящих методов адресата и предложенные для него номера ответов и общее число ответов.
- Новый обход API-массива с исполнением его элементов на `endturn`.

Эта отмена относится к прежнему проекту протокола. Она не отменяет обычные Structures, массивы, callable и механизмы, уже используемые нормальным исполнением LMX.

**Входящие описания аргументов вида `ms: int: time` ОБЯЗАТЕЛЬНО поддержать обычными LMX `implements` и связыванием аргументов. Это остаётся общим требованием языка, а не специальной возможностью тайм-аутов.** См. §8.

## 1. Требуется: разделить три ответственности

| Ответственность | Источник её правил |
| --- | --- |
| Вызов адресованной Structure | Существующая семантика обычного вызова LMX и её существующая реализация. |
| Отправка запросов, доставка результатов и распределение результата по явным назначениям | Существующий почтовый транспорт, дополненный описанием `post` там, где это требуется. |
| Связь ожидаемых ответов с назначениями и обработчиками исходов | Отдельная таблица ожиданий у отправителя, связанная с идентичностью исходного сообщения. |

Внешний вызывающий обращается к Structure через доступный Message-транспорт. Транспорт не создаёт пространство имён экспортируемых методов, не обращается к другому словарю сигнатур и не переинтерпретирует Structure как список альтернативных сервисов.

Разрешение вызова, потребление структуры его аргументов, приём результата и обработка объявленных выходов остаются работой обычных механизмов языка. Использовать их. Это задание отдельно не определяет, какие перегрузки допустимы и участвует ли возвращаемый тип в обычном выборе. Любое такое правило — то же самое правило, что для локального вызова, а не его почтовый вариант.

То же относится к пустым вызовам и вызовам без тела: использовать обычный смысл и диагностику LMX. Не добавлять автоматический просмотр API, перечисление или исполнение посторонних дочерних методов.

Здесь «атомарный вызов» означает один обычный вызов, переносимый транспортом. Термин не обещает транзакционность исполнения и не обозначает машинную атомарную инструкцию.

## 2. Требуется: сохранить `post` как обычный ресивер протокола

`post` потребляет обычную Structure с описанием обмена:

| Ветвь | Роль |
| --- | --- |
| `ask` | Один или несколько явно указанных вызовов для отправки через транспорт. |
| `answer` | Одно или несколько назначений для результатов этих вызовов; они заполняют ожидания ответов, а не публичный API. |
| `timeout` | Типизированная настройка предела ожидания исходных отправок, вне списков их аргументов. |
| `undelivered` | Принимающее описание и тело для исходного запроса, который не был доставлен. |
| `unanswered` | Принимающее описание и тело, вызываемое при достижении настроенного тайм-аута ожидания ответа. |
| `catch` | Обычный обработчик, требуемый явным `throws` вызываемого callable. |

Например, `getPixel: x y` использует явно доступный адрес/ссылку. Транспорт переносит вызов; `getPixel` не является зашитой операцией ядра или новой схемой имён экспортируемых методов. То же верно для `setRed`, `setGreen`, `setYellow` и `print`.

Внешний `post` задаёт область запросов, назначений ответов, настройки и обработчиков исходов. `ask` и `answer` остаются множественными. Связь между ними выражается структурой протокола, а не пользовательскими идентификаторами запросов.

Вызов без результата по-прежнему может записываться так:

```text
post:
. ask:
. . print: "hello world"
```

В этом примере `print` — предоставленный адрес Message, обычный вызов которого потребляет текст и не возвращает значения. Не создавать синтетический ответ или подтверждение успешной доставки только потому, что вызов прошёл через транспорт.

При подготовке `post` всё описание потребляется до выпуска запросов: последующие `answer`, `timeout` и обработчики уже должны быть связаны с отправками. Это не слепое исполнение каждой ветви сверху вниз. Использовать обычное формирование аргументов и существующую границу публикации.

Протокол не вводит синхронное ожидание, позиционное сопоставление строк, join-барьер, транзакцию для всех отправок или автоматический повтор. Каждый явно указанный исходный вызов — обычный вызов; группировка и распределение результатов — работа транспорта.

## 3. Требуется: `answer` обслуживает только ожидания ответов

### 3.1 Отдельная таблица, а не API callable

При подготовке `answer` отправитель записывает ожидание результата соответствующего исходного запроса и назначения, по которым почта должна его распределить. Это принадлежащая отправителю таблица ожиданий. Она отделена от адресованной Structure, её обычного представления callable и очереди почтового ящика.

Не инициализировать эту таблицу собственной сигнатурой Thread. Не помещать записи ожиданий в его публичные методы и не делать их обычными доступными извне элементами вызова. И наоборот: не искать в таблице ожиданий реализацию нового, не связанного с ними входящего вызова.

Таблица сохраняет связи, уже требуемые протоколом: идентичность исходного сообщения, подготовленные назначения результата и применимые настройки/обработчики. Исходные сформированные аргументы и сведения о времени/состоянии остаются доступны через исходное сообщение и существующие почтовые данные. Здесь перечислены необходимые связи, а не предписано новое физическое расположение полей записи.

Несколько подготовленных экземпляров одного исходного `post` имеют разные связи обмена. Они не должны перезаписывать друг друга через глобальный слот, заданный только именем в исходнике, типом результата или адресатом.

### 3.2 Изменения у владельца и существующее время жизни

Отправитель добавляет и обслуживает ожидания на своей единственной полосе исполнения. При получении ответа соответствующее ожидание определяется по исходному сообщению; затем транспорт использует подготовленные назначения. Обычное завершение и освобождение используют существующие механизмы почты и времени жизни.

Для такого однопоточного учёта не нужны дополнительные подтверждения регистрации, локи, протоколы межпоточной видимости или пользовательский вызов `registerListener`. Межпоточная доставка по-прежнему использует уже реализованную синхронизацию ящика; её не заменять и не удалять.

Ожидающий обработчик и данные его обмена должны сохранять действительность по обычным правилам построения, композиции и владения LMX. Не оставлять ссылки на завершившийся стековый кадр и не вводить отдельное скрытое окружение только ради `post`.

Сам по себе тайм-аут не удаляет ожидание или его маршруты. Дальнейшие действия остаются пользовательской политикой по §6. Обработчик, который только журналирует, не снимает свои назначения `answer` неявно.

## 4. Требуется: множественные вызовы и размножение результата — операции транспорта

### 4.1 Один исходный вызов, один результат, три назначения

Ниже показаны ветви `ask`/`answer` внутри `post`:

```text
ask:
. getPixel: x y
answer:
. setRed: uint32: rgb
. setGreen: uint32: rgb
. setYellow: uint32: rgb
```

В этом тесте обычный `getPixel` исполняется один раз и возвращает один цвет. Почта распределяет уже вычисленный результат по трём явно указанным назначениям:

```text
Q1 -> ordinary getPixel call / обычный вызов getPixel -> R1
                               -> setRed
                               -> setGreen
                               -> setYellow
```

Одно исходное вычисление и один исходный ответ, затем три доставки. Каждый адресат выполняет свой обычный вызов LMX при потреблении доставленного значения. Запрошенный метод не исполняется повторно и не реализует размножение самостоятельно.

### 4.2 Три исходных вызова, три результата, девять доставок

```text
ask:
. getPixel: x y
. getPixel: x + 1, y + 1
. getPixel: x + 2, y + 2
answer:
. setRed: uint32: rgb
. setGreen: uint32: rgb
. setYellow: uint32: rgb
```

```text
Q1 -> R1 -> setRed, setGreen, setYellow
Q2 -> R2 -> setRed, setGreen, setYellow
Q3 -> R3 -> setRed, setGreen, setYellow
```

**Три явных исходных вызова; три исходных исполнения; три исходных ответа; девять транспортных доставок и последующих вызовов адресатов.** Это не девять исполнений `getPixel`; один исходный вызов не ищет несколько методов у получателя.

Q1/Q2/Q3 и R1/R2/R3 — поясняющие обозначения, а не дополнительные пользовательские идентификаторы. Почта сохраняет адрес/идентичность исходного сообщения. Ответы могут приходить в другом порядке без изменения их связей. Строки `answer` не сопоставляются позиционно со строками `ask`: каждый результат в этом примере поступает во все три указанных места.

Эти количества описывают прикладную работу примера отдельно от возможных исполнений в обязательных тестах допуска. Копирование/разделение физического хранения ответов подчиняется существующим правилам владения; задание не требует ни общей изменяемой памяти между Messages, ни копирования исполняемого кода.

### 4.3 Основа для bulk, а не другая семантика вызова

Явная множественная форма создаёт основу для последующего bulk-транспорта. Реализация транспорта может группировать работу своими установленными механизмами; каждый элемент сохраняет обычное поведение вызова, сформированные аргументы, связь с исходным сообщением, назначения результата и применимую обработку ошибок/тайм-аута.

Не превращать группу в барьер и не объединять её результаты в новый обязательный тип результата. Не требовать порядкового номера ответа, общего числа внутренне выбранных методов или счётчика завершения всех методов. Это требовалось только отменённому предложению об автоматическом множественном выборе методов.

Исходная программа может явно строить последующие множественные обмены. Это обычная композиция программы/транспорта, а не основание добавлять скрытую множественность одному адресованному вызову.

## 5. Требуется: использовать обычные проверки, не создавать почтовую систему типов

Контракт атомарного вызова намеренно не переписывается здесь. Подключить подготовку и исполнение транспорта к тем же существующим операциям LMX, что используются локальным вызовом. Обычные формирование аргументов, `implements`, потребление результата, объявленные ошибки и обязательные тесты получателя остаются источником правил.

Сохранить уже согласованное правило конверсии аргументов. Транспорт не должен восстанавливать предварительный отказ по буквальному равенству Си-сигнатур или вводить ранжирование конверсий, выбор первого совпадения, политику всех совпадений либо дополнительный запрет одинаковых сигнатур. Любое правило допустимости/выбора приходит из обычного LMX одинаково для обоих транспортов.

Описания и контекст конверсий — обычные данные, явно предоставленные конкретному Message, в том числе из root. Это не глобальный реестр процесса и не автоматически наследуемое окружение.

### 5.1 Направления результата готовятся на стороне отправителя

При подготовке `post` обычным механизмом `implements`/потребления устанавливается, что каждый адресат `answer` способен принять запрошенный результат:

```text
result of getPixel / результат getPixel -> value consumed by setRed / значение, потребляемое setRed
result of getPixel / результат getPixel -> value consumed by setGreen / значение, потребляемое setGreen
result of getPixel / результат getPixel -> value consumed by setYellow / значение, потребляемое setYellow
```

`uint32: rgb` описывает принимаемый результат. Это не требование вернуть `uint32` из `setRed`: `setRed` может потребить цвет и ничего не возвращать.

После подготовки корреляция выбирает существующее ожидание и уже подготовленные маршруты. Не выполнять второй почтовый поиск совместимых слушателей при приходе результата. Это не отменяет исполнения выбранных конверсий, зависящих от значения проверок диапазона/формата и других существующих обязательств обычного вызова.

Если общая реализация неполна, исправить её один раз для локального и транспортируемого вызовов. Не вводить разовые правила приёма для примера с `getPixel`.

### 5.2 Объявленные `throws` сохраняются

Явный `throws` запрошенного callable покрывается обычным соответствующим `catch` или уже разрешённым правилом распространения. Граница Message не отменяет эту обязанность. Сохранить объявленное имя выхода и payload.

Несовместимость до исполнения — не `axisOutOfBound`, выброшенный ещё не исполнявшимся методом. Сохранить обычное различие между диагностикой вызова, реальной недоставкой и объявленной ошибкой во время исполнения. Протокол не вводит новое сведение всех ошибок к одному обработчику.

## 6. Требуется: сохранить границы доставки, тайм-аута и пользовательской политики

| Событие | Поведение со стороны транспорта |
| --- | --- |
| Исходный запрос не доставлен | Вызвать связанный `undelivered` с исходным адресатом и уже сформированными аргументами. |
| Запрошенный вызов вернул обычный результат | Связать его с исходным запросом и распределить по подготовленным маршрутам `answer`. |
| Запрошенный вызов вышел через объявленный `throw` | Передать объявленный выход и payload связанному обычному `catch`. |
| Ожидание ответа достигло тайм-аута | Вызвать связанный `unanswered` с данными исходного запроса и времени; дальнейшее действие определяет пользовательский код. |
| Принимающий исполнитель завис | Продолжают действовать существующие надзор за Thread, взаимные опросы и механизмы остановки. |

Таблица описывает события и маршрутизацию, а не новый автомат взаимоисключающих конечных состояний.

Почта не посылает прикладному коду ACK успешной доставки. Пользователь, которому нужно состояние доставки, смотрит существующие флаги через API своей почты. Вызов, намеренно не возвращающий значения, не должен принуждаться к прикладному ответу или считаться неответившим только из-за отсутствия контракта результата.

`timeout` — отдельная ветвь `post`; он отсчитывается **от отправки исходного сообщения** по существующей отметке времени отправки. Не от объявления, подготовки аргументов, приёма адресатом, входа в метод или события отображения. Размножение результата по трём адресатам не создаёт трёх ожиданий исходного вычисления.

Истечение обеспечивает вызов `unanswered`, а не автоматическую отмену или другое навязанное прикладное решение. Пользовательский код может проверить исходное сообщение, сформированные аргументы, настройки и флаги доставки/состояния. Протокол не должен автоматически повторять, отменять, подавлять поздний результат или объявленную ошибку, удалять назначения результата, освобождать живую арену либо устанавливать флаг завершения другого Thread.

В частности, если `unanswered` только журналирует, поздний ответ продолжает обрабатываться по существующим маршрутам и правилам почты. Не возвращать отменённую политику первого результата/всех выбранных методов или счётчик множества ответов на один обычный запрос.

Диагностика использует сохранённые сформированные аргументы исходной отправки. Повторное вычисление `x + 1` после изменения `x` описало бы уже другой запрос.

Отказ доставки уже вычисленного результата одному из назначений `answer` обрабатывается существующими правилами почты для этой доставки. Он не превращает исходный успешный `getPixel` в недоставленный исходный запрос. Задание не вводит заменяющего протокола ошибок транспорта.

## 7. Требуется: использовать существующее исполнение Thread и почтовый ящик

Очередь, `sendMessage`, `receiveMessage`, `endturn`, публикация, владение, удержание ссылок и освобождение уже имеют согласованные контракты. Задание подключает к ним `post` и ожидания ответов, а не переоткрывает их устройство.

Входящее исполнение и работа, связанная с ответами, выполняются на полосе принимающего владельца в существующих точках обработки. Подготовка `answer` — локальная работа с таблицей ожиданий. Не добавлять прежний обход массива API или автоматический вызов каждого дочернего элемента без аргументов/результата. Обработчик запускается по связанному событию, а не просто из-за своей арности.

Сохранить существующий жизненный цикл Thread, включая повторное исполнение до пользовательского `success: 1` и применимые правила остановки, ошибок и надзора. Последнее исходящее письмо перед завершением проходит обычную публикацию успешного хода. Протокол не вводит второй цикл входа и не меняет момент безопасного освобождения состояния.

Прямой доступ к существующему почтовому API оставить. Сохранить согласованный итератор с отбором по адресу, вариант получения всей доступной почты и `0` как конец итератора/null. Использовать их действительные написание и смысл отбора; не выводить новые аргументы `receiveMessage` из этого документа.

Ручное потребление и обработка протокола используют один существующий ящик. Они не должны независимо потреблять одно и то же письмо из очереди дважды. Это не обещание глобальной сетевой доставки exactly-once.

Сохранить оба существующих варианта исполнения: Thread без собственного потока ОС и Thread с потоком ОС. Переключатель режима, специальная пара входов UI, глобальный планировщик или новый слой синхронизации в задание не входят. Прежняя история экрана/отрисовщика — мотивация, а не обязательная схема регистрации.

## 8. ОБЯЗАТЕЛЬНАЯ ОБЩАЯ ПОДДЕРЖКА: `ms: int: time`

### 8.1 `int` — ресивер, а не узел пути данных

Настройка:

```text
timeout: ms: int: time 500
```

`int` потребляет объявление, создаёт и инициализирует типизированную привязку `time`. Получившиеся данные настройки адресуются так:

```text
timeout
  ms
    time -> integer value 500 / целое значение 500
```

```text
timeout\ms\time
```

Не создавать дополнительное поле данных `int` и не использовать `timeout\ms\int\time`. Исходное представление применения ресивера и результирующая структура данных имеют разные роли. Не восстанавливать устаревшее написание `ms: int: 500`, в котором пропущено имя объявляемой привязки.

### 8.2 Входящее описание — обычная структурная типизация

Полное описание формальных аргументов `unanswered`:

```text
(ms: int: time; getPixel: method; int: x; int: y)
```

**Поддержать `ms: int: time` во входящих описаниях аргументов стандартным LMX `implements` и обычным связыванием аргументов.** Ветка `ms` остаётся частью требуемой структуры; `int` задаёт ресивер/контракт листа; принятое значение становится формальным `time` обработчика.

Не сворачивать требование до голого целого перед проверкой структуры. Не решать задачу отдельным парсером длительностей, классом `Duration`, обязательным тегом `unit`, новым примитивом или проверкой типов только для тайм-аутов.

У входящего формального описания нет инициализатора: значение поступает с вызовом. Его привязка — не поиск свободного имени в настройке тайм-аута. Применять обычные правила LMX для формальных имён; второй политики сопоставления имён это задание не вводит.

Та же поддержка должна работать с другими именами ветвей, ресиверами листьев и глубинами вложенности — **как при локальном вызове, так и при вызове через post**. Другая смысловая ветка не становится `ms` лишь потому, что оба листа целые. Разрешённое преобразование смысловой структуры приходит из явно предоставленного контекста конверсий Message, а не из специальных знаний почты.

### 8.3 Различать аргумент обработчика и настройку

Внутри `unanswered`:

```text
time                  # timing value supplied to this handler / значение времени, предоставленное обработчику
timeout\ms\time       # configured limit for this particular post / настроенный предел именно этого post
```

Это разные привязки. Механизм времени предоставляет значение, относящееся к исходной отправке. В примере ниже используется прошедшее время `512` мс от отправки при пределе `500` мс. Не читать настройку вместо аргумента обработчика и не брать настройки другого обмена.

Поддержка относится к общему пути ресиверов/аргументов/`implements`, даже если первым обнаружившим пробел тестом оказался обработчик тайм-аута.

## 9. Обязательный опорный пример и полный разбор

Сохранить последнюю исходную форму автора. Английский документ переводит только комментарий о `throws`; исполняемая запись, пути и текст журналирования совпадают с русской версией.

```text
post:
. ask:
. . getPixel: x y
. . getPixel: x + 1, y + 1
. . getPixel: x + 2, y + 2
. answer:
. . setRed: uint32: rgb
. . setGreen: uint32: rgb
. . setYellow: uint32: rgb
. timeout: ms: int: time 500
. undelivered: (getPixel: method; int: x; int: y)
. . log\error: "undelivered: " method "( x: " x " y: " y " )"
. unanswered: (ms: int: time; getPixel: method; int: x; int: y)
. . log\error:
. . . "unanswered after " time " ms "
. . . method "( x: " x " y: " y " ) timeout: " timeout\ms\time
. . end: error
. catch: axisOutOfBound (int: value; int: number) # required by explicit throws in getPixel / требуется явным throws в getPixel
. . println: "axis: " number " value: " value
```

Ведущие точки и `end: error` сохраняют обычный грамматический смысл. Ни пример, ни протокол не требуют отдельного парсера-исключения.

### 9.1 Подготовка и отправки

Окружающий Message явно предоставляет адресуемые Structures, `x`, `y`, logger/printer, описания ресиверов и контекст конверсий. В этом тесте `getPixel` нормально возвращает значение, потребляемое как `uint32`, и объявляет `axisOutOfBound` в `throws`.

Подготовка `post` устанавливает обычную совместимость вызовов и три направления результата, создаёт типизированную настройку тайм-аута и добавляет соответствующие записи в **таблицу ожиданий ответов**. Она не изменяет callable-API Thread.

Для иллюстрации, при `x = 10` и `y = 20` получаются:

| Исходное сообщение | Адресуемый вызов | Сформированные аргументы |
| --- | --- | --- |
| Q1 | `getPixel` | `10, 20` |
| Q2 | `getPixel` | `11, 21` |
| Q3 | `getPixel` | `12, 22` |

Каждый вызов использует обычное поведение LMX. Транспорт сохраняет связь с исходным сообщением и отсчитывает его настроенное ожидание от времени этой отправки. Обозначения Q в объяснении не вводят ID в исходный код.

### 9.2 Все вызовы вернули результаты вовремя

Три обычных исполнения `getPixel` дают три исходных цветовых результата. Почта кладёт каждый в `setRed`, `setGreen`, `setYellow`: девять доставок и последующих вызовов адресатов. Записи ожиданий обслуживаются существующим механизмом ответов; число методов получателя нигде не запрашивается. Показанные обработчики ошибок не вызываются.

### 9.3 Q2 не доставлен

`undelivered` получает исходного адресата Q2 в `method` и сохранённые сформированные аргументы `x = 11`, `y = 21`. Журналируется именно этот запрос. Если Q1 и Q3 успешны, они по-прежнему дают два исходных ответа и шесть доставок результата. Весь `post` не откатывается.

### 9.4 Q2 достиг тайм-аута

`unanswered` получает адресата Q2, сохранённые координаты и вложенный аргумент времени, связанный с локальным `time`. Журнал отдельно читает `timeout\ms\time`, равный `500`.

Если механизм почты/времени передаёт прошедшее `time = 512`, запись различает «unanswered after 512 ms» и «timeout: 500». Начало отсчёта — отправка. Этот обработчик только журналирует. Он не отменяет Q2, не удаляет его назначения и не подавляет поздний результат. Пользовательский код сохраняет доступ к флагам доставки и решает дальнейшие действия через существующий API.

### 9.5 Q2 вызывает `axisOutOfBound`

Связанный `catch` получает `value` и `number` из объявленного payload ошибки. Их смысл задаёт контракт `getPixel`; это не переименованные координаты запроса. Обычного цветового результата для распределения у этого вызова нет. Остальные независимые запросы продолжают обрабатываться каждый своим образом.

Такой же объявленный выход существует при обычном локальном вызове. Транспорт переносит его и сохраняет связь с отправкой, а не определяет второй механизм выбора исключений.

### 9.6 Содержимое адресованного графа не создаёт скрытой множественности

Другие callable-поля внутри адресованной Structure не требуют перечислить их или исполнить все совместимые. Что делает обычный вызов LMX, то делает и этот атомарный вызов через транспорт. Все девять последующих доставок в тесте появляются из явно записанной транспортной схемы «три на три».

## 10. Требуемые работы и приёмочные тесты

### 10.1 Порядок работ

Сначала изучить живую реализацию и применимые тесты обычных вызовов/почты. Затем:

1. Убрать отменённые предположения о внешнем API из кода и документов этого протокола. Не удалять обычные механизмы языка, нужные в других местах.
2. Подключить переносимые вызовы к существующему пути обычного вызова/`implements`. При необходимости исправить общую поддержку вложенных формальных аргументов в нём, с локальными и почтовыми регрессиями.
3. Реализовать подготовку `post` и принадлежащую отправителю таблицу ожиданий; не менять публичный API при добавлении `answer`.
4. Реализовать явные множественные запросы и распределение результатов через существующий транспорт и идентичность исходных сообщений. Оставить основу для последующей bulk-группировки, не придумывая сейчас отдельную семантику bulk-вызова.
5. Подключить `undelivered`, отсчитываемый от отправки тайм-аут `unanswered` и обычный объявленный `catch` к существующему механизму почты/времени. Сохранить пользовательскую политику и прямой доступ к почте.
6. Совместно обновить применимые спецификации и заметки реализации. Сохранять согласованность обеих языковых версий этого задания.

### 10.2 Наблюдаемые приёмочные тесты

| ID | Проверка | Требуемое наблюдение |
| --- | --- | --- |
| T01 | Эквивалентные локальный и почтовый вызовы при эквивалентном предоставленном контексте | Тот же обычный результат/изменение состояния либо объявленный выход; почтовый путь добавляет транспорт, а не другой механизм разрешения вызова. |
| T02 | Существующие случаи выбора по аргументам/результату, включая различия по результату, допускаемые обычным LMX | Одни и те же случаи принимаются или отклоняются локально и через post. Новых почтовых правил уникальности, возвращаемого типа и ранжирования конверсий нет. |
| T03 | Пустой вызов/вызов без тела | Тот же обычный смысл и диагностика; нет автоматической выдачи или исполнения всех `sub`. |
| T04 | Подготовка `answer` | Заполняется только отдельное состояние ожиданий; экспортируемые методы или словарь API не добавляются. |
| T05 | Два живых экземпляра одного исходного `post` | Исходные запросы, маршруты результатов и настройки не смешиваются между экземплярами. |
| T06 | Добавление и завершение ожиданий | Используются существующие механизмы владельца и времени жизни; нет нового рукопожатия регистрации или однопоточного лока, нет старой связи с переиспользованным сообщением. |
| T07 | Адресованная Structure также содержит посторонние совместимые callable | Нет перечисления или исполнения всех совпадений на уровне протокола; поведение совпадает с обычным вызовом. |
| T08 | Несовместимое объявленное назначение `answer` | Обычная подготовка у отправителя сообщает несовместимость; последующего поиска замещающих слушателей нет. |
| T09 | Разрешённая конверсия и зависящая от значения ошибка формата/диапазона | Сохраняется обычная конверсия/проверка; почтовой переинтерпретации или обхода нет. |
| T10 | Один запрос `getPixel` и три назначения ответа | Одно исходное исполнение, один исходный ответ, три доставки результата. |
| T11 | Три запроса `getPixel` и три назначения | Три исходных исполнения, три исходных ответа, девять доставок результата. |
| T12 | Ответы приходят в другом порядке | Корреляция по исходному сообщению сохраняет правильные ожидания/маршруты без пользовательских ID и полей номера/общего числа ответов. |
| T13 | Q2 не доставлен, отправитель позднее изменил `x/y` | Обработчик получает уже сформированные исходные аргументы Q2. |
| T14 | Объявленный `axisOutOfBound` | Обычный соответствующий `catch` получает объявленный payload; вместо него не создаётся цветовой результат или выдуманная ошибка доставки. |
| T15 | `timeout: ms: int: time 500` | Настройка читается как `timeout\ms\time`; `int` — ресивер, а не дополнительный узел данных. |
| T16 | Входящий `(ms: int: time)` при локальном и почтовом вызове | Обычная структурная проверка сохраняет `ms` и связывает принятое значение с локальным `time`. |
| T17 | Другие имена ветвей, ресиверы листьев и большая вложенность | Работает тот же общий механизм аргументов без зашитых случаев тайм-аута/единиц. |
| T18 | Отсутствующая/другая смысловая ветвь | Обычный отказ, если явно предоставленный контекст конверсий не допускает нужное структурное преобразование. |
| T19 | `time` обработчика отличается от настроенного тайм-аута | Оба источника остаются различными и относятся к правильному обмену. |
| T20 | Тайм-аут от отправки; обработчик журналирует; результат приходит позже | `unanswered` видит исходные данные/состояние. Одно журналирование не отменяет вызов и не подавляет поздний результат. |
| T21 | Прямой приём и обработка протокола | Существующие правила очереди/публикации/времени жизни сохранены; одно письмо не потребляется независимо дважды. |
| T22 | У ожидающего обработчика нет обычных аргументов/результата | Его запускает событие обмена, а не обход безаргументных методов API или посторонний ход. |
| T23 | Последняя отправка перед `success: 1` | Сохраняются существующие публикация успешного хода и правила завершения. |
| T24 | Поддерживаемые живым деревом нативные/интерпретируемые и пошаговые/поточные исполнения | Одинаковая наблюдаемая семантика вызова и почты; нет нового режима или специальной пары входов GUI. |
| T25 | Явный множественный транспорт; сравнение группировки с отдельными отправками, где группировка уже есть | Те же вызовы, связи и назначения; нет неявного барьера, перечисления методов или изменения начала тайм-аута. Будущая bulk-оптимизация не требуется для прохождения примера с явно сгруппированными отправками. |
| T26 | Обычный `sub`, намеренно не возвращающий значения | Транспорт не вводит синтетического ответа/ACK или ложного требования отсутствующего результата. |

Отдельно измерять исходные исполнения, исходные ответы, доставки результатов и изменения таблицы ожиданий. Успех парсера, компоновки или один код выхода сами по себе не доказывают эти наблюдения.

## 11. Отменённые проекты: не возвращать их

| Прежнее предложение | Правило этой редакции |
| --- | --- |
| Тело/массив Thread превращается в экспортируемый словарь API | Отдельного внешнего API нет; существующая Structure вызывается обычным образом. |
| Служебная таблица начинается с сигнатуры Message | Новой входной таблицы сигнатур/сервисов нет. |
| `answer` добавляет/удаляет элементы callable-API | `answer` обслуживает только собственные ожидания ответов и маршруты. |
| Входная фильтрация зависит от наличия обычных тел, `sub` или `fn` в API-массиве | Особой таблицы фильтрации протокола нет; используются обычный вызов/допуск и существующие правила почты. |
| Письмо без тела возвращает все `sub` | Автоматического просмотра API нет; обычная семантика пустого вызова. |
| Исполняются все методы получателя с подходящими сигнатурами | Скрытой множественности у адресата нет; есть только явное транспортное размножение/группировка. |
| Перегрузки только по результату запрещаются или разрешаются новым почтовым правилом | Решает только обычный LMX; задание не дублирует ни одну из этих политик. |
| Ответы нумеруются, заранее считается число отвечающих методов | Удалено вместе с автоматическим множественным выбором методов. |
| На каждом `endturn` обходится API-массив | Используется существующий контракт исполнения Thread и обработки почты. |

Флаги успешной доставки отделены от пользовательских результатов. Тайм-аут остаётся событием для пользовательского кода, а не автоматической отменой. Контекст конверсий Message передаётся явно. Не заменять общие механизмы языка новым RPC-фреймворком, подсистемой promise/future, глобальным реестром слушателей, подсистемой типов единиц или реализацией под конкретное имя в исходнике.

## 12. Требуемые результаты и приоритет источников

Предоставить патч живой реализации, согласованные изменения спецификаций, исполняемые положительные/отрицательные и регрессионные тесты, а также отчёт: точная ревизия/дерево, команды, наблюдаемые эффекты и оставшиеся пробелы реализации.

Приоритет источников для этого задания:

1. Окончательное решение автора: обычный вызов через другой транспорт; отдельная таблица ожиданий; множественность только в явных транспортных операциях.
2. Сохранённые решения прежнего задания: ветви и опорный пример `post`, проверка маршрутов у отправителя, корреляция по исходному сообщению, тайм-аут от отправки с пользовательской реакцией и стандартная поддержка вложенного `implements`.
3. Существующие спецификации/реализация обычного LMX и почты для механизмов, которые задание использует повторно.

Фоновые документы — `CORE(1).md` §3 и §§5–6, а также `LMX_semantics.en.md` §§5–6 и §14. В них есть переходный текст; применять позднее принятые правила ядра, а не восстанавливать старое поведение дескрипторов или сигнатур. Задание не утверждает, что живой код уже проверен или этот пример сейчас компилируется.

Прежний список открытых вопросов не возвращается. Порядок очереди, публикация, начало отсчёта и однопоточное добавление ожиданий не являются новым проектированием. Настоящее противоречие, найденное в живой реализации, надо показать как противоречие с минимальным примером, а не молча разрешать изобретением семантики внешнего вызова.

**Критерий приёмки: `post` переносит обычные вызовы LMX, учитывает ожидания и распределяет результаты. Он не становится вторым языком вызова Structures.**
## 13. Привязка к ядру и доктрине (fable, 2026-09-26)

Раздел добавлен ревью по редакции v2 и ответам автора (`LMX_blog/2026-09-26.md`, «`post` (глава 28, редакция v2): четыре вопроса fable»). Он не меняет требований §§0–12, а связывает их с существующими контрактами ядра и доктриной `next_core_tasks.md` §0.

1. **Таблица ожиданий — данные Thread-отправителя, не третий граф.** Автор: место не нормируется, это деталь механизмов Thread, который принимает и сортирует вызовы в своём потоке. Доктрина §0 п.6 сужает форму: ожидания хранятся как данные Thread (поле его ядерной записи рядом с `LmxPost` из L2 §9 либо обычная объявленная Structure), не как скрытое состояние активации и не как отдельный «граф контекста». Запись ожидания ссылается на исходное письмо той же парой `[target, source_arena]`, которой оперирует кольцо inbox; пользовательских идентификаторов, нумерации ответов и «общего числа ответов» нет (§4, §11).
2. **Идентичность и контекст исходного письма — как при `merge`.** Весь используемый контекст переносится тем же механизмом, что у внутренних вызовов, «как будто есть ссылка на другой граф», с соблюдением существующих правил `independent` и [выбранного контракта защиты объекта](#protected-structures). Разрешение вызвать предоставленную обычную Structure само по себе не разрешает перенос защищённых ветвей, credentials или ключевого материала. Эти ограничения используют общий механизм защиты, а не почтовое правило копирования контекста. Транспорт не заводит собственного контракта идентичности; корреляция ответа с запросом — это ссылка на исходное письмо, а не ключ во втором словаре.
3. **Транспорт — три полосы L2 §9.** `ask` — обычная admission письма в inbox адресата (staged → outbox на успешном конце хода отправителя, L2 §9); ответ — обычное письмо обратно; назначения `answer`, `undelivered`, `unanswered`, `catch` исполняются на полосе отправителя на его ходе (§7, T22) и никогда на полосе адресата. Второго ящика, второго цикла входа и ACK доставки нет (§6, §7).
4. **Часы — существующие.** Отметка времени — момент начала отправки (автор). Источник — существующий контракт часов `lmx_clock_now`/`lmx_deadline_passed` (сегодня L1-источники `lmx_clock.h.lm1`, `lmx_clock_posix.lm1`/`_win32.lm1`; после переноса уровней §8 — тот же контракт на L3/L2: ядра на L1 не будет, автор 2026-09-26); дедлайн ожидания = отметка отправки + `timeout\ms\time`; проверяется на точках обработки отправителя, второго таймера или потока на каждый `post` нет; истечение — вызов пользовательского `unanswered` (§6).
5. **`ms: int: time` — правило двоеточия и D-79.** `int` — ресивер: объявление заводит привязку `time` (`CORE.md` §3: поле заводит только объявление), данные лежат по `timeout\ms\time` (§8.1). Входящее описание `(ms: int: time; …)` — обычная структура формалов, которую проверяет тот же `implements` с Consumer из прочитанных путей (порт §7: `l2_descriptor_used`, вложенные сегменты и вид листа) — отдельного разбора длительностей нет (§8.2).
6. **Конверсии назначений — контекст конверсий Message.** `uint32: rgb` и любой ресивер назначения проходят ту же таблицу преобразований, что локальный вызов (глава 6, §12 книги; `convert.lm2` — данные, читаемые транслятором, тикет 20260926-05); отсутствие строки — отказ при подготовке (T08); выход из диапазона — отказ приёмника, не ноль (T09, §12 книги). `uint32` в примере — иллюстрация, не спецификация примитивных имён (автор).
7. **Место в очереди и свидетели.** Реализация — `next_core_tasks.md` §8a, после самосборки §8 и до `myxa_manager`; до зачёта §8 не начинать. Тело `post`, как и любого ресивера, — L3 со вставками L2; деления «нативно в ядре / библиотека на L2» нет (автор, 2026-09-26). Строки harness измеряют раздельно исполнения, исходные ответы, доставки и изменения таблицы ожиданий (T10: 1/1/3, T11: 3/3/9); мутанты «второе исполнение `getPixel`», «`answer` публикует метод», «дедлайн от подготовки, а не от отправки» — RED. Открытые вопросы к автору — в §8a, не здесь.

## 14. Миграция `sendMessage`/`receiveMessage` на общее основание (автор, 2026-09-26)

Текст автора — `docs/new_parts/threadMessageAPI_migration.en.md` (RU-пара — `threadMessageAPI_migration.ru.md`). Решение: `sendMessage` и `receiveMessage` **остаются** для пользовательского кода с прежними аргументами, статусами, итератором с отбором по адресу, вариантом «вся доступная почта» и `0` как концом; меняется только реализация — оба ресивера и `post` опираются на одни нижележащие операции почты (существующие очередь, владение, публикация, состояние доставки) и на одну обычную машину вызова. Направление зависимостей — вниз: нет цепочки `sendMessage → post → sendMessage`, второй очереди внутри `post`, второго резолвера вызова внутри `receiveMessage`. `answer` не заменяет `receiveMessage`: первое описывает, что делать с результатом ранее отправленного запроса, второе выдаёт свою почту по прежнему контракту; письмо, взятое одним путём, не потребляется вторым. Приём письма как данных сам по себе не вызывает его содержимое и не заводит ожидание ответа. Удаляются только дублирующие пути реализации и снятые особые случаи, не рабочие примитивы и не публичные функции из-за старости имён. Свидетельства миграции перечислены в §7 документа; критерий приёмки — «`sendMessage` и `receiveMessage` остаются пригодны, `post` даёт структурированный протокол, все три стоят на одном основании почты и одной обычной реализации вызова».
[EN]
## 0. Required: replace the previous external-API design

This revision replaces the previous task documents. It describes the required work, not a claim that the live implementation already implements it. The author's final clarification supersedes the intermediate proposals about API arrays, signature dictionaries, and multiple method selection.

**There is already an LMX Structure. Calling it through another Thread must use exactly the ordinary LMX call rules used inside a Thread. Only the transport changes. Do not define or implement the elementary call again in this protocol.**

**`answer` populates a separate sender-owned table of pending replies and their destinations. It does not populate, extend, or shrink a public method API.**

**The multiplicity of `ask` and `answer` belongs to transport and provides the basis for bulk operations. It does not mean that one request executes every method whose signature happens to match.**

Retain the existing `post` syntax, original-message correlation, reply distribution, delivery-state access, timeout callbacks, declared `throws`/`catch`, explicit conversions, and nested incoming argument descriptions. Remove the superseded external-dispatch rules throughout the implementation, documentation, and tests.

In particular, remove from this task:

- A user-graph array treated as a separate exported API and a dictionary derived from it.
- A replacement service table initially populated with the Message's own signature and later extended by `answer`.
- Special postal signature lookup, return-type overload rules, duplicate-signature prohibitions, and API-content-based filtering.
- A bodyless request that automatically enumerates or returns all `sub` entries.
- Automatic execution of all matching recipient methods and the proposed reply-number/total-count mechanism for that execution.
- A new `endturn` scan that executes an invented API array.

These removals concern the abandoned protocol design. They do not remove ordinary Structures, arrays, callables, or any mechanisms already used by normal LMX execution.

**Incoming argument descriptions such as `ms: int: time` MUST be supported by ordinary LMX `implements` and argument binding. This remains a general language requirement, not a timeout-specific feature.** See §8.

## 1. Required: keep three responsibilities separate

| Responsibility | Source of its rules |
| --- | --- |
| Calling the addressed Structure | Existing ordinary LMX call semantics and their existing implementation. |
| Sending requests, delivering results, and distributing a result to explicit destinations | Existing mail transport, extended by the `post` description where needed. |
| Associating expected replies with their destinations and outcome handlers | The sender's separate pending-reply table, associated with original-message identity. |

An external caller addresses the Structure through the available Message transport. The transport must not manufacture an exported-method namespace, inspect a different signature dictionary, or reinterpret the Structure as a list of alternative services.

The ordinary language mechanisms remain responsible for resolving a call, consuming its argument Structure, processing its result, and handling its declared exits. Reuse them. This task does not independently specify which overloads can exist or whether a result type participates in ordinary selection. Any such rule is the same rule as for a local call, not a postal variant.

The same applies to empty/bodyless calls: use ordinary LMX meaning and diagnostics. Do not add automatic API discovery, enumeration, or execution of unrelated child methods.

Here “elementary call” means one ordinary call carried by the transport. It does not promise transactional execution or describe a machine-level atomic instruction.

## 2. Required: `post` remains an ordinary protocol receiver

`post` consumes an ordinary Structure containing the exchange description:

| Branch | Role |
| --- | --- |
| `ask` | One or more explicit calls to send through the transport. |
| `answer` | One or more destinations for the results of those calls; these populate pending-reply state, not a public API. |
| `timeout` | Typed waiting-limit configuration for original sends, outside their argument lists. |
| `undelivered` | Receiving description and body for an original request that was not delivered. |
| `unanswered` | Receiving description and body invoked when the reply wait reaches its configured timeout. |
| `catch` | The ordinary handler required by a queried callable's explicit `throws`. |

For example, `getPixel: x y` uses an explicitly available destination/reference. The transport carries the call; `getPixel` is not a hardcoded kernel operation or a new exported-method name scheme. The same is true of `setRed`, `setGreen`, `setYellow`, and `print`.

The enclosing `post` scopes its requests, answer destinations, configuration, and outcome handlers. `ask` and `answer` remain plural. Their association is expressed by the protocol Structure, not by user-managed request identifiers.

A no-result call can still be written as:

```text
post:
. ask:
. . print: "hello world"
```

In this example `print` is a supplied Message destination whose ordinary call consumes the text and returns no value. Do not synthesize a reply or a successful-delivery acknowledgment merely because the call used the transport.

Preparing a `post` consumes the whole description before releasing its requests: the following `answer`, `timeout`, and handlers must already be associated with the sends. This does not mean blindly executing each branch top to bottom. Reuse normal argument preparation and the existing publication boundary.

The protocol does not introduce a synchronous wait, positional pairing of rows, a join barrier, a transaction across all sends, or automatic retry. Each explicit source call is an ordinary call; grouping and result distribution are transport work.

## 3. Required: `answer` maintains only pending-reply state

### 3.1 A separate table, not a callable API

When the sender prepares `answer`, it records the wait for the corresponding original request and the destinations to which mail must distribute its result. This is a sender-owned waiting table. It is separate from the addressed Structure, its normal callable representation, and the mailbox queue.

Do not initialize that table with the Thread's own signature. Do not insert waiting entries into its public methods or make them discoverable as ordinary externally callable entries. Conversely, do not search the waiting table to resolve a new, unrelated incoming call.

The table must retain the relationships already required by this protocol: the original message's identity, the prepared result destinations, and the applicable settings/handlers. The original formed arguments and timing/status information remain accessible through the original message and existing mail data. This is a statement of required associations, not a prescribed new physical record layout.

Preparing several instances of the same source `post` creates distinct exchange associations. They must not overwrite one another through a global slot keyed only by source name, result type, or destination.

### 3.2 Owner-local updates and existing lifetime rules

The sender adds and services waiting entries on its own single execution lane. Receiving a reply identifies the corresponding wait through the original message, then the transport uses the prepared destinations. Normal completion and release use the existing mail/lifetime mechanisms.

No extra registration acknowledgment, lock, inter-thread visibility protocol, or user `registerListener` call is required for this same-thread bookkeeping. Cross-thread delivery still uses the already implemented mailbox synchronization; do not replace or remove it.

An outstanding handler and its exchange data must remain valid under ordinary LMX construction, composition, and ownership rules. Do not retain a dead stack-local reference or invent a separate closure environment solely for `post`.

Timeout alone does not erase a wait or its routes. Further actions remain user policy, as specified in §6. A handler that only logs does not implicitly withdraw its `answer` destinations.

## 4. Required: plural calls and result fan-out are transport operations

### 4.1 One source call, one result, three destinations

The following illustrates the `ask`/`answer` branches within `post`:

```text
ask:
. getPixel: x y
answer:
. setRed: uint32: rgb
. setGreen: uint32: rgb
. setYellow: uint32: rgb
```

In this fixture, the ordinary `getPixel` call executes once and returns one color. Mail distributes that already computed result to three explicit destinations:

```text
Q1 -> ordinary getPixel call / обычный вызов getPixel -> R1
                               -> setRed
                               -> setGreen
                               -> setYellow
```

There is one source computation and one original reply, followed by three deliveries. Each destination performs its ordinary LMX call when it consumes the delivered value. The queried method does not rerun and does not implement the fan-out itself.

### 4.2 Three source calls, three results, nine deliveries

```text
ask:
. getPixel: x y
. getPixel: x + 1, y + 1
. getPixel: x + 2, y + 2
answer:
. setRed: uint32: rgb
. setGreen: uint32: rgb
. setYellow: uint32: rgb
```

```text
Q1 -> R1 -> setRed, setGreen, setYellow
Q2 -> R2 -> setRed, setGreen, setYellow
Q3 -> R3 -> setRed, setGreen, setYellow
```

**Three explicit source calls; three source executions; three original replies; nine transport deliveries and consequent destination calls.** There are not nine executions of `getPixel`, and one source call does not scan for several recipient methods.

Q1/Q2/Q3 and R1/R2/R3 are explanatory labels, not additional user-visible identifiers. The mail subsystem keeps the original message address/identity. Replies may arrive in a different order without changing their associations. Answer rows are not zipped with ask rows; every result in this example is sent to the three stated places.

These counts describe the example's application work, separately from any execution performed by existing mandatory admission tests. Copying/sharing of physical reply storage remains subject to existing ownership rules; this task prescribes neither shared mutable state across Messages nor duplication of executable code.

### 4.3 Basis for bulk, not another call semantics

The explicit plural form is the basis for subsequent bulk transport. A transport implementation may group work according to its established mechanisms, while each member retains ordinary call behavior, formed arguments, original-message association, result destinations, and applicable failure/timeout handling.

Do not make the group a barrier or combine its results into a new mandatory result type. Do not require reply ordinals, a total number of internally selected methods, or an all-methods-completed counter. Those were needed only by the abandoned automatic multi-method dispatch proposal.

A source program can explicitly construct further plural exchanges. That is ordinary program/transport composition, not a reason for a single addressed call to acquire hidden multiplicity.

## 5. Required: reuse ordinary validation; do not create a postal type system

The elementary call contract is intentionally not rewritten here. Connect transport preparation and execution to the same existing LMX operations used for local calls. Normal argument formation, `implements`, result consumption, declared failures, and mandatory receiver tests remain the source of truth.

Preserve the already agreed argument-conversion rule. The transport must not reintroduce literal C-signature equality as a preliminary exclusion or invent conversion ranking, a first-match shortcut, an all-matches policy, or an additional duplicate-signature rule. Any validity/selection rule comes from ordinary LMX, identically for both transports.

The descriptions and conversion context are ordinary data explicitly supplied to a concrete Message, including from root. They are not a process-global registry or automatically inherited environment.

### 5.1 Prepare the result routes on the sender side

During `post` preparation, use the normal `implements`/consumption mechanism to establish that each `answer` destination can receive the queried result:

```text
result of getPixel / результат getPixel -> value consumed by setRed / значение, потребляемое setRed
result of getPixel / результат getPixel -> value consumed by setGreen / значение, потребляемое setGreen
result of getPixel / результат getPixel -> value consumed by setYellow / значение, потребляемое setYellow
```

`uint32: rgb` describes the result being received. It is not a demand that `setRed` return `uint32`; `setRed` may consume the color and return no value.

After preparation, correlation selects the existing wait and its already prepared routes. Do not perform a second postal search for compatible listeners when the result arrives. This does not remove execution of selected conversions, value-dependent range/format checks, or other existing ordinary call obligations.

If the shared implementation is incomplete, repair it once for both local and transported calls. Do not implement one-off acceptance rules for the `getPixel` example.

### 5.2 Preserve declared `throws`

The queried callable's explicit `throws` must be handled by its normal matching `catch` or an already permitted propagation rule. The Message boundary does not erase this obligation. Preserve the declared exit name and payload.

A pre-execution incompatibility is not an `axisOutOfBound` raised by an unexecuted method. Retain the ordinary distinction between call diagnostics, actual nondelivery, and a declared failure during execution. This protocol does not invent a new mapping of all errors to one handler.

## 6. Required: preserve delivery, timeout, and user-policy boundaries

| Event | Transport-facing behavior |
| --- | --- |
| An original request is not delivered | Invoke its associated `undelivered` with the original destination and already formed arguments. |
| A queried call returns a normal result | Associate it with the original request and distribute it through the prepared `answer` routes. |
| A queried call exits through a declared `throw` | Carry the declared exit and payload to the associated ordinary `catch`. |
| The reply wait reaches its timeout | Invoke the associated `unanswered` with the original-request and timing data; user code decides what to do. |
| A receiving executor hangs | Existing Thread supervision, mutual polling, and stopping mechanisms continue to apply. |

The table describes events and routing; it is not a new mutually exclusive terminal-state machine.

Mail sends no successful-delivery ACK to application code. A user that needs delivery state examines the existing delivery flags through its own mail API. A deliberately no-result call must not be forced to produce an application result or treated as unanswered merely because it has no result contract.

`timeout` is a separate branch of `post` and is counted **from sending the original message**, using the existing send timestamp. It is not counted from declaration, argument preparation, receiver admission, method entry, or a display event. A result copied to three destinations does not create three waits for the original computation.

Expiry provides an invocation of `unanswered`, not automatic cancellation or another imposed application decision. User code can inspect the original message, its formed arguments, settings, and delivery/status flags. The protocol must not automatically retry, cancel, suppress a late result or declared failure, remove the result destinations, free a live arena, or set another Thread's completion flag.

In particular, when `unanswered` only logs, a later reply still follows the existing route and mail rules. Do not restore the abandoned first-result/all-selected-methods policy or multiple-reply counting for one ordinary request.

Diagnostics must use the saved, formed arguments of the original send. Re-evaluating `x + 1` after `x` changed would report a different request.

Failure to deliver an already computed result to one `answer` destination is handled under the existing mail rules for that delivery. It does not make the original successful `getPixel` call an undelivered source request. This task introduces no replacement transport-failure protocol.

## 7. Required: reuse Thread execution and the existing mailbox

The queue, `sendMessage`, `receiveMessage`, `endturn`, publication, ownership, reference retention, and cleanup already have agreed contracts. This task connects `post` and pending replies to them; it does not reopen their design.

Incoming execution and reply-associated work run on the receiving owner's lane at the existing processing boundaries. Preparing `answer` is local waiting-table work. Do not add the old scan of an API array or an automatic call of every no-argument/no-result child. A handler runs for its associated event, not merely because it has a particular arity.

Preserve the existing Thread lifecycle, including repeated execution until the user sets `success: 1` and the applicable stop/failure/supervision rules. A final outgoing letter before completion follows the normal successful-turn publication rules. This protocol neither introduces a second entry loop nor changes when state may be safely reclaimed.

Keep direct access to the existing mail API. Preserve the currently agreed iterator selected by address, the variant consuming all available mail, and `0` as the iterator end/null value. Use their actual spelling and selector meaning; do not infer new arguments for `receiveMessage` from this document.

Manual consumption and protocol processing share the same existing mailbox. They must not independently consume the same queued letter twice. This is not a promise of global exactly-once network delivery.

Keep both existing execution arrangements: a Thread serviced without its own OS thread and a Thread with an OS thread. No mode switch, UI-specific entry pair, global scheduler, or new synchronization layer is part of this assignment. The earlier screen/renderer story is motivation, not a mandatory registration framework.

## 8. REQUIRED GENERAL SUPPORT: `ms: int: time`

### 8.1 `int` is a receiver, not a data-path node

The setting is:

```text
timeout: ms: int: time 500
```

`int` consumes the declaration and creates/initializes the typed binding `time`. The resulting setting data is addressed as:

```text
timeout
  ms
    time -> integer value 500 / целое значение 500
```

```text
timeout\ms\time
```

Do not create an extra `int` data field or use `timeout\ms\int\time`. The source representation of the receiver application and the resulting data structure have different roles. Do not restore the obsolete spelling `ms: int: 500`, which omits the declared binding name.

### 8.2 The incoming description is ordinary structural typing

The full `unanswered` formal description is:

```text
(ms: int: time; getPixel: method; int: x; int: y)
```

**Support `ms: int: time` in incoming argument descriptions through the standard LMX `implements` and normal argument binding.** The `ms` branch remains part of the required structure; `int` supplies the leaf receiver/contract; the received value becomes the handler's formal `time`.

Do not flatten the requirement to a bare integer before matching its structure. Do not solve it with a dedicated duration parser, `Duration` class, mandatory `unit` tag, new primitive, or timeout-only type checker.

An incoming formal has no initializer because its value is supplied by the call. Its binding is not a free-name lookup of the timeout configuration. Apply ordinary LMX formal-name rules; this task introduces no second name-matching policy.

The same support must work for other branch names, leaf receivers, and nesting depths, **both in local calls and in calls delivered by post**. A different semantic branch does not become `ms` merely because both leaves are integers. Any allowed conversion of semantic structure comes from the Message's explicitly supplied conversion context, not from special postal knowledge.

### 8.3 Distinguish the handler argument from the setting

Inside `unanswered`:

```text
time                  # timing value supplied to this handler / значение времени, предоставленное обработчику
timeout\ms\time       # configured limit for this particular post / настроенный предел именно этого post
```

These are distinct bindings. The timing mechanism supplies the value associated with the original send. The elapsed-time example below uses `512` ms from sending while the limit is `500` ms. Do not silently read the setting in place of the handler argument or fetch a different exchange's settings.

This support belongs in the common receiver/argument/`implements` path even if the first regression that exposes it is a timeout handler.

## 9. Required reference example and complete walkthrough

Keep the author's final source form. The English document translates only the `throws` comment; executable notation, paths, and log text match the Russian version.

```text
post:
. ask:
. . getPixel: x y
. . getPixel: x + 1, y + 1
. . getPixel: x + 2, y + 2
. answer:
. . setRed: uint32: rgb
. . setGreen: uint32: rgb
. . setYellow: uint32: rgb
. timeout: ms: int: time 500
. undelivered: (getPixel: method; int: x; int: y)
. . log\error: "undelivered: " method "( x: " x " y: " y " )"
. unanswered: (ms: int: time; getPixel: method; int: x; int: y)
. . log\error:
. . . "unanswered after " time " ms "
. . . method "( x: " x " y: " y " ) timeout: " timeout\ms\time
. . end: error
. catch: axisOutOfBound (int: value; int: number) # required by explicit throws in getPixel / требуется явным throws в getPixel
. . println: "axis: " number " value: " value
```

Leading dots and `end: error` retain their ordinary grammar meaning. Neither the example nor this protocol requires a special-case parser.

### 9.1 Preparation and sends

The surrounding Message supplies the addressed Structures, `x`, `y`, the logger/printer, receiver descriptions, and conversion context explicitly. For this fixture, `getPixel` normally returns a value consumable as `uint32` and declares `axisOutOfBound` in `throws`.

Preparing `post` establishes normal call compatibility and the three result routes, constructs its typed timeout data, and installs the corresponding entries in the **pending-reply table**. It does not modify a Thread's callable API.

For illustration, `x = 10` and `y = 20` produce:

| Original message | Addressed call | Formed arguments |
| --- | --- | --- |
| Q1 | `getPixel` | `10, 20` |
| Q2 | `getPixel` | `11, 21` |
| Q3 | `getPixel` | `12, 22` |

Each call uses ordinary LMX behavior. The transport stores its original-message association and starts its configured wait from that message's send time. The explanation's Q labels introduce no source-level IDs.

### 9.2 All calls return in time

Three ordinary `getPixel` executions produce three original color results. Mail places each result at `setRed`, `setGreen`, and `setYellow`: nine deliveries and subsequent destination calls. The waiting records are serviced by the existing reply mechanism; no recipient-method count is requested. The displayed failure handlers do not run.

### 9.3 Q2 is undelivered

`undelivered` receives Q2's original destination as `method` and its saved formed arguments `x = 11`, `y = 21`. It logs that specific request. If Q1 and Q3 succeed, they still produce two original replies and six result deliveries. There is no rollback of the entire `post`.

### 9.4 Q2 reaches the timeout

`unanswered` receives Q2's destination, its saved coordinates, and the nested timing argument bound to local `time`. The log separately reads `timeout\ms\time`, which is `500`.

If the mail/timing mechanism supplies elapsed `time = 512`, the message distinguishes “unanswered after 512 ms” from “timeout: 500”. The origin is sending. This handler only logs. It does not cancel Q2, retire its destinations, or suppress a later result. User code retains access to delivery flags and decides further action through the existing API.

### 9.5 Q2 raises `axisOutOfBound`

The associated `catch` receives `value` and `number` from the declared failure payload. Their meaning comes from `getPixel`'s contract; they are not renamed request coordinates. There is no normal color result from this invocation to distribute. The other independent requests retain their own processing.

The same declared failure exists for an ordinary local call. Transport carries it and preserves its association; it does not define a second exception-selection mechanism.

### 9.6 Nothing inside the addressed graph adds implicit multiplicity

Other callable fields inside an addressed Structure are not an invitation to enumerate them or execute all compatible ones. Whatever the ordinary LMX call does is what this elementary transported call does. In this fixture, all nine downstream deliveries come from the written three-by-three transport arrangement.

## 10. Required implementation work and acceptance tests

### 10.1 Work order

Inspect the live implementation and applicable ordinary-call/mail tests first. Then:

1. Remove the superseded external-API assumptions from this protocol's code and documentation. Do not remove ordinary language machinery needed elsewhere.
2. Connect transported calls to the existing ordinary call/`implements` path. Repair general nested formal support there if needed, with local and postal regressions.
3. Prepare `post` and maintain its sender-owned pending-reply table; do not mutate a public API when adding `answer`.
4. Implement the explicit plural request/result-distribution behavior through the existing transport and original-message identities. Leave it suitable for later bulk grouping without inventing bulk call semantics now.
5. Connect `undelivered`, timeout-from-send `unanswered`, and ordinary declared `catch` to the existing mail/timing mechanism. Preserve user policy and direct mail access.
6. Update the relevant specifications and implementation notes together. Keep both language versions of this assignment aligned.

### 10.2 Observable acceptance tests

| ID | Fixture | Required observation |
| --- | --- | --- |
| T01 | Equivalent local and transported call, with equivalent supplied context | Same ordinary result/state effect or declared exit; the postal path adds transport, not another call resolver. |
| T02 | Existing argument/result selection cases, including any result-type distinction permitted by ordinary LMX | The same cases pass or fail locally and through post. No new postal uniqueness, return-type, or conversion-ranking rule. |
| T03 | Empty/bodyless call | Same ordinary meaning and diagnostics; no automatic listing or execution of all `sub` entries. |
| T04 | Preparing an `answer` | Only the separate waiting state is populated; no exported methods or API dictionary are added. |
| T05 | Two live instances of the same source `post` | Original requests, result routes, and settings do not cross between instances. |
| T06 | Adding and completing waits | Existing owner-local/lifetime mechanisms are used; no new registration handshake or same-thread lock, no stale association to a reused message. |
| T07 | An addressed Structure also contains unrelated compatible callables | No protocol-level enumeration or all-matches execution; behavior agrees with the ordinary call. |
| T08 | Incompatible declared `answer` destination | Ordinary sender-side preparation reports incompatibility; no later search for substitute listeners. |
| T09 | Allowed conversion and a value-dependent format/range failure | Normal conversion/check behavior is preserved; no postal reinterpretation or bypass. |
| T10 | One `getPixel` request and three answer destinations | One source execution, one original reply, three result deliveries. |
| T11 | Three `getPixel` requests and three destinations | Three source executions, three original replies, nine result deliveries. |
| T12 | Replies arrive out of order | Original-message correlation preserves the correct waits/routes without user IDs or reply ordinal/total fields. |
| T13 | Q2 is undelivered and the sender later changes `x/y` | The handler receives Q2's already formed original arguments. |
| T14 | Declared `axisOutOfBound` | Ordinary matching `catch` receives the declared payload; no normal color or fabricated delivery failure replaces it. |
| T15 | `timeout: ms: int: time 500` | Setting is readable as `timeout\ms\time`; `int` is a receiver, not an extra data node. |
| T16 | Incoming `(ms: int: time)` in local and postal calls | Ordinary structural checking preserves `ms` and binds the received value to local `time`. |
| T17 | Different branch names, leaf receivers, and greater nesting | The same general argument mechanism works without hardcoded timeout/unit cases. |
| T18 | Missing/different semantic branch | Ordinary rejection unless the explicitly supplied conversion context admits the necessary structural conversion. |
| T19 | Handler `time` differs from the configured timeout | Both sources remain distinct and refer to the correct exchange. |
| T20 | Timeout from sending; handler logs; result arrives later | `unanswered` sees original data/status. Logging alone neither cancels the call nor suppresses its later result. |
| T21 | Direct receive and protocol processing | Existing queue/publication/lifetime rules are preserved; the same queued letter is not consumed independently twice. |
| T22 | A waiting handler has no ordinary arguments/result | It is triggered by its exchange event, not by a scan of nullary API methods or an unrelated turn. |
| T23 | A final send followed by `success: 1` | Existing successful-turn publication and completion rules are preserved. |
| T24 | Native/interpreted and stepped/dedicated-thread paths supported by the live tree | Same observable call and mail semantics; no new mode or special GUI entry pair. |
| T25 | Explicit plural transport; compare grouping with elementary sends where grouping exists | The same calls, associations, and destinations; no implicit barrier, target enumeration, or change in timeout origin. Future bulk optimization is not required to pass the elementary grouped-source example. |
| T26 | An ordinary deliberately no-result `sub` | No synthetic reply/ACK or spurious missing-result requirement is introduced by the transport. |

Measure source executions, original replies, result deliveries, and waiting-table changes separately. Parser success, successful linking, or an exit code alone does not establish these observations.

## 11. Superseded designs: do not reintroduce them

| Earlier proposal | Rule for this revision |
| --- | --- |
| Thread body/array becomes an exported API dictionary | No separate external API; call the existing Structure normally. |
| Service table starts with the Message signature | No new inbound signature/service table. |
| `answer` adds/removes callable API entries | `answer` maintains only its own pending-reply state and routes. |
| Incoming filtering depends on the presence of plain bodies, `sub`, or `fn` in the API array | No protocol-specific filtering table; reuse ordinary call/admission and existing mail rules. |
| Bodyless request returns every `sub` | No automatic discovery; ordinary empty-call semantics. |
| All signature-compatible recipient methods execute | No hidden target multiplicity; only explicit transport fan-out/grouping. |
| Disallow or allow result-only overloads by a new postal rule | Ordinary LMX alone decides; this task duplicates neither policy. |
| Number replies and precompute how many matched methods will answer | Removed with automatic multi-method dispatch. |
| Scan an API array at every `endturn` | Use the existing Thread execution and mail processing contract. |

Keep successful-delivery flags separate from user results. Keep timeout as an event available to user code, not automatic cancellation. Keep Message-local conversion data explicit. Do not replace the shared language mechanisms with a new RPC framework, promise/future subsystem, global listener registry, unit-type subsystem, or source-name-specific implementation.

## 12. Required deliverables and source priority

Deliver the live implementation patch, aligned specification updates, runnable positive/negative and regression tests, and an execution report stating the exact revision/tree, commands, observed effects, and remaining implementation gaps.

The source order for this assignment is:

1. The author's final decision: ordinary call through another transport; a separate reply-wait table; multiplicity only in explicit transport operations.
2. Retained decisions from the earlier task: `post` branches and reference example, sender-side route checks, original-message correlation, timeout from sending with user-controlled reaction, and standard nested `implements` support.
3. Existing ordinary LMX and mail specifications/implementation for the mechanisms this task reuses.

Background references are `CORE(1).md` §3 and §§5–6, and `LMX_semantics.en.md` §§5–6 and §14. They contain transitional text; apply later accepted core rules rather than reinstating obsolete descriptor or signature behavior. This task does not assert that the live code has been inspected or that this example currently compiles.

The former open-questions list is not restored. Queue order, publication, timing origin, and same-thread waiting-table insertion are not a new design exercise. A genuine contradiction found in the live implementation must be reported as such, with a minimal example, rather than silently resolved by inventing external-call semantics.

**Acceptance criterion: `post` transports ordinary LMX calls, records waits, and distributes results. It does not become a second language for calling Structures.**
## 13. Binding to the kernel and the doctrine (fable, 2026-09-26)

This section was added by review of the v2 text and the author's answers (`LMX_blog/2026-09-26.md`, "`post` (chapter 28, v2): fable's four questions"). It changes no requirement of §§0–12; it ties them to the existing kernel contracts and to the doctrine of `next_core_tasks.md` §0.

1. **The pending-reply table is data of the sending Thread, not a third graph.** Author: its place is not normed; it is a detail of the Thread mechanisms, since the Thread accepts and sorts calls on its own lane. Doctrine §0 item 6 narrows the form: waits are stored as Thread data (a field of its kernel record next to `LmxPost` of L2 §9, or an ordinary declared Structure), not as hidden activation state and not as a separate "context graph". A wait entry refers to the source message by the same `[target, source_arena]` pair the inbox ring works with; there are no user identifiers, no reply numbering and no "total replies" (§4, §11).
2. **Identity and context of the source message: as with `merge`.** The whole used context travels by the same mechanism as internal calls, "as if we had a reference to another graph", subject to the existing `independent` rules and the [selected object-protection contract](#protected-structures). Permission to invoke an exposed ordinary Structure does not by itself authorize transfer of protected branches, credentials or key material. These restrictions use the shared protection mechanism, not a postal context-copying rule. The transport defines no identity contract of its own; correlating a reply with its request is a reference to the source message, not a key in a second dictionary.
3. **Transport is the three lanes of L2 §9.** `ask` is ordinary admission of a letter into the addressee's inbox (staged → outbox at the sender's successful end of turn, L2 §9); the reply is an ordinary letter back; `answer`, `undelivered`, `unanswered` and `catch` destinations run on the sender's lane at its turn (§7, T22), never on the addressee's lane. No second mailbox, no second entry loop, no delivery ACK (§6, §7).
4. **The clock is the existing one.** The timestamp is the moment the send starts (author). The source is the existing clock contract `lmx_clock_now`/`lmx_deadline_passed` (today the L1 sources `lmx_clock.h.lm1`, `lmx_clock_posix.lm1`/`_win32.lm1`; after the level transfer of §8 the same contract in L3/L2: there will be no kernel written in L1, author 2026-09-26); the wait deadline is the send timestamp plus `timeout\ms\time`; it is checked at the sender's processing points, with no second timer or thread per `post`; expiry calls the user's `unanswered` (§6).
5. **`ms: int: time` is the colon rule and D-79.** `int` is a receiver: the declaration creates the binding `time` (`CORE.md` §3: only a declaration creates a field); the data lives at `timeout\ms\time` (§8.1). The incoming description `(ms: int: time; …)` is an ordinary formal structure checked by the same `implements` with the used-path Consumer (§7 port: `l2_descriptor_used`, nested segments and leaf kind); there is no separate duration parser (§8.2).
6. **Destination conversions go through the Message conversion context.** `uint32: rgb` and any destination receiver pass the same conversion table as a local call (chapter 6, book §12; `convert.lm2` as data read by the translator, ticket 20260926-05); a missing row refuses at preparation (T08); a range failure is a receiver refusal, not zero (T09, book §12). `uint32` in the example is illustrative, not a specification of primitive names (author).
7. **Place in the queue and witnesses.** Implementation is `next_core_tasks.md` §8a, after the §8 self-build and before `myxa_manager`; nothing starts before §8 is counted. The body of `post`, like that of any receiver, is L3 with L2 inserts; there is no "native in the kernel / L2 library" split (author, 2026-09-26). Harness rows measure executions, source replies, deliveries and wait-table changes separately (T10: 1/1/3, T11: 3/3/9); mutants "second execution of `getPixel`", "`answer` publishes a method", "deadline from preparation instead of send" are RED. Open questions to the author live in §8a, not here.

## 14. Migrating `sendMessage`/`receiveMessage` onto the shared foundation (author, 2026-09-26)

The author's text is `docs/new_parts/threadMessageAPI_migration.en.md` (RU pair `threadMessageAPI_migration.ru.md`). Decision: `sendMessage` and `receiveMessage` **stay** for user code with their established arguments, status behavior, address-selected iterator, all-available-mail variant and `0` as the end; only the implementation changes: both receivers and `post` rest on the same lower-level mail operations (the existing queue, ownership, publication and delivery state) and on one ordinary call machinery. Dependencies point downward only: no `sendMessage → post → sendMessage` chain, no second queue inside `post`, no second call resolver inside `receiveMessage`. `answer` does not replace `receiveMessage`: the former says what to do with the result of an earlier send, the latter exposes the caller's own mail under its established contract; a letter taken through one path is not consumed again through the other. Receiving a message as data does not by itself invoke its payload or allocate a reply wait. Only duplicated implementation paths and superseded special cases are removed, not working primitives or public functionality merely because their names are old. The migration evidence is listed in §7 of the document; the acceptance criterion: "`sendMessage` and `receiveMessage` remain usable, `post` provides the structured protocol, and all three rely on one shared Message foundation and one ordinary LMX call implementation."

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
