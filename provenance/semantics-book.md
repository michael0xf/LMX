@@ scope | Предмет языка и способы исполнения | Language scope and execution modes | 0; 0.0; 0.0.1; 0.0.3; 0.1.1; 1; 1.7
[RU]
LMX одновременно представляет данные, исполняемые выражения, модели, запросы и сообщения. Исходная запись строит структуры; принимающее выражение задаёт их смысл. Записи, деревья, конфигурации, схемы, таблицы и программные тела используют одну структурную основу. Реестр, сервис, таблица и Mix — семейства данных и принимающих выражений, а не дополнительные уровни языка.

L3 сохраняет изменение графа, структурные вызовы, таблицы, сообщения и локальные акторы. Низкоуровневые адресные операции, необработанный доступ к памяти, вызовы сырых машинных интерфейсов и явная низкоуровневая синхронизация относятся к [L2](L2_spec_ru.md). Различие уровней не устанавливает само по себе чистоту вычисления, полномочия пользователя или отдельную систему безопасности.

Расширение файла выбирает внешний профиль: `.lm1` — прямое понижение L1, `.lm2` — L2, `.lm3` — L3. `.lm4` и `.lm5` не задают действующих профилей. В обычном скриптовом профиле L3 исполняется корневое тело файла; наличие функции `main` не обязательно. Профиль сервиса может выбрать явную функцию, `start`, обработчик или отправку сообщения. Точка входа получает управление после подготовки окружения и графа исполнения.

Модель допускает интерпретацию построенного графа L3 и трансляцию с сохранением той же семантики. Интерпретатор исполняет только L3: не исходный текст, не L1/L2 и не операции `c.*`. Реализация самого интерпретатора не расширяет язык интерпретируемой программы. Целевые поддерживаемые исходники разделяются на L2 и L3; имеющиеся `.lm1` постепенно переписываются на L2. L1 остаётся промежуточной стадией трансляции, а не исходным носителем исполняемого графа; состояние перехода отделяется от этой цели в [спецификации L2](L2_spec_ru.md#scope). Парсер, интерпретатор графа и транслятор имеют разные задачи. Грамматические формы, границы тел, литералы, комментарии и нормализация определены в [спецификации грамматики](LMX_grammar.ru.md).

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

L3 retains graph mutation, structural calls, tables, messages and local actors. Low-level address operations, raw memory access, raw machine interfaces and explicit low-level synchronization belong to [L2](L2_spec_en.md). The level distinction does not by itself establish computational purity, user authority or a separate security system.

A file extension selects its outer profile: `.lm1` selects direct L1 lowering, `.lm2` L2, and `.lm3` L3. `.lm4` and `.lm5` do not select current profiles. The ordinary L3 script profile executes the file's root body; a `main` function is not required. A service profile may select an explicit function, `start`, a handler or a message send. The entry point receives control after its environment and runtime graph are prepared.

The model supports interpretation of the constructed L3 graph and translation preserving the same semantics. The interpreter executes L3 only: not source text, L1/L2 or `c.*` operations. The interpreter's implementation does not expand the language of the interpreted program. The target maintained sources are divided into L2 and L3; existing `.lm1` units are gradually rewritten in L2. L1 remains an intermediate translation stage, not the source carrier of the executable graph; the migration's current state is distinguished from this target in the [L2 specification](L2_spec_en.md#scope). The parser, graph interpreter and translator serve different purposes. Grammatical forms, body boundaries, literals, comments and normalization are defined in the [grammar specification](LMX_grammar.en.md).

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

Массив содержит элементы одного типа. Его длина относится к элементам массива, а число полей структуры — к непосредственным полям структуры. Массив ссылок на массивы и прямоугольный многомерный массив — разные значения. Детали представления и классификации ячеек по диапазонам адресов определены в [L2](L2_spec_ru.md#type-by-range).

Пустая структура — присутствующее значение с нулём полей. Она отличается от отсутствующего аргумента, числового нуля и `void`, означающего отсутствие содержимого примитивной ячейки. Явное пустое вертикальное тело передаёт такой же аргумент, как `()`; см. [пустое тело](LMX_grammar.ru.md#empty-colon).

`None` — контекстное значение: его представление задаёт ожидаемый тип принимающего выражения. Единого кодирования для всех типов нет; тип без соответствующего определения `None` его не принимает. Число `0` остаётся нулём, в логических операциях — ложью, и не является общим признаком отсутствия. В прежнем профиле `Boolean` использует диапазон −1…1: `None = −1`, ложь — 0, истина — 1. Это конкретное определение профиля, а не универсальное кодирование всех отсутствующих значений.

Текст, изображение, десятичная запись и машинное слово до распознавания принимающим выражением являются исходным хранилищем данных. После разбора или декодирования они представлены значениями того же графа. Имена форматов и численных библиотек не вводят дополнительные фундаментальные виды значений.
[EN]
A Structure is an ordered collection of direct fields. Fields hold references to values: primitive cells, other Structures, Arrays and method records. Lexical nesting forms a forest; additional references connect it into a graph containing shared objects and cycles. A primitive cell does not acquire a Structure wrapper merely because a field references it.

An Array contains elements of one type. Its length counts Array elements, while a Structure's field count counts its direct fields. An Array of references to Arrays differs from a rectangular multidimensional Array. Representation details and address-range classification of cells are defined in [L2](L2_spec_en.md#type-by-range).

An empty Structure is a present value with zero fields. It differs from an absent argument, numeric zero and `void`, which denotes no primitive-cell content. An explicit empty vertical body supplies the same argument as `()`; see [empty bodies](LMX_grammar.en.md#empty-colon).

`None` is contextual: its representation is defined by the type expected by the receiving expression. There is no encoding shared by all types; a type without a corresponding definition of `None` does not accept it. The numeral `0` remains zero and means false in logical operations; it is not a universal absence marker. The earlier `Boolean` profile uses the range −1…1: `None = −1`, false is 0 and true is 1. This is a particular profile definition, not the universal encoding of missing values.

Text, images, decimal notation and machine words are substrate storage before recognition by a receiving expression. After parsing or decoding, they are values of the same graph. Format and numeric-library names do not introduce additional fundamental value kinds.
@@ identity | Идентичность и лексическое дерево | Identity and lexical trees | 2; 9.1.3; 19.29.1-2
[RU]
Живые структуры и записи массивов сохраняют физические адреса. Рост хранилища добавляет новые участки; существующие объекты не перемещаются. Равенство содержимого не означает тождества объектов. Явное копирование создаёт новые идентичности и сохраняет связи между ними по правилам [копирования](#composition).

Лексический родитель определяет положение структуры в дереве; у корня родителя нет. Владение памятью и лексическое родство независимы. Присоединение хранилища другого Message сохраняет существующие лексические ссылки, не добавляет само по себе ссылку из корня получателя и не превращает присоединённый корень в лексического ребёнка получателя.

Отсечение внешнего лексического родителя при построении задаёт [квалификатор independent](#qualification); получение входов от вызывающего выражения подчиняется [динамической видимости](#dynamic). Эти механизмы не меняют отношения владения и тождества объектов.
[EN]
Live Structures and Array records retain their physical addresses. Storage grows by adding new regions; existing objects do not move. Equal contents do not imply object identity. Explicit copying creates new identities and preserves relationships under the [copying rules](#composition).

A lexical parent determines a Structure's position in its tree; a root has no parent. Storage ownership and lexical ancestry are independent. Attaching another Message's storage preserves existing lexical links, does not itself add a reference from the recipient's root and does not make the adopted root a lexical child of the recipient.

The [independent qualifier](#qualification) cuts the external lexical parent at construction; obtaining inputs from the caller follows [dynamic visibility](#dynamic). Neither mechanism changes storage ownership or object identity.
@@ fields | Имена, пути и повторные вхождения | Names, paths and repeated occurrences | 2.3; 13.1; 14.1; 21.1-2; 21.11
[RU]
Имена разрешают исходные обращения; исполнение следует полученным ссылкам и позициям. Диагностическое соответствие «адрес → короткое исходное имя» не является таблицей связывания переменных, типом или идентификатором исполнения. Конструирование, копирование и вызов не требуют регистрации исходного имени. Анонимные и позиционные значения не нуждаются в синтетических именах.

Структурный путь `object\field\nested` последовательно выбирает поля графа. Наличие каждого перехода и его допустимость определяются выбранным объектом. Вычисляемый путь не заменяется выдуманным статически известным именем. Для прямого обращения к собственному графу вызываемого тела используется зарезервированный `node`; сам `node` обозначает вызываемую структуру, а её лексический родитель — другое значение.

`node` нельзя объявить, затенить, перепривязать или передать как динамическое одноимённое значение, в том числе посредством цитированного написания имени. Вызывающее выражение выбирает структурное вхождение, но не заменяет его `node` значением своего контекста. `node\field` выбирает непосредственное поле этого вхождения без дополнительного перехода к его родителю; дальнейший переход должен быть выражен явно.

Повторные исходные имена сохраняются. `name` эквивалентно `[0]name`, то есть выбирает первое вхождение; `[1]name` — второе. Номер вхождения имени отличается от физического номера поля среди всех полей. Поздняя часть `merge` не переопределяет раннюю автоматически. Изменение порядка различных имён не меняет именованный путь; изменение порядка одноимённых вхождений может изменить выбранное значение.

Число и расположение полей структуры фиксируются при создании. Порядок полей графа строго лексический; порядок выдачи нативного кода не разрешает переставлять поля самого графа. Обновление существующего поля заменяет содержащуюся в нём ссылку; оно не добавляет новое вхождение. Для иного набора полей создаётся новая структура. Операции над массивом следуют собственному контракту и не изменяют это правило структуры.
[EN]
Names resolve source-level accesses; execution follows the resulting references and positions. A diagnostic mapping from address to short source name is not a variable-binding table, a type or an execution identifier. Construction, copying and calls do not require source-name registration. Anonymous and positional values need no synthetic names.

A structural path `object\field\nested` selects graph fields in sequence. Each step's presence and validity are determined by the selected object. A computed path is not replaced by an invented statically known name. Direct access to an invoked body's own graph uses reserved `node`; `node` denotes the callable Structure itself, while its lexical parent is a different value.

`node` cannot be declared, shadowed, rebound or dynamically supplied as a same-named value, including by quoted identifier spelling. The caller selects the structural occurrence but cannot substitute a value from its own context for that occurrence's `node`. `node\field` selects the occurrence's direct field without an additional hop to its parent; further traversal must be explicit.

Repeated source names are retained. `name` is equivalent to `[0]name`, selecting the first occurrence; `[1]name` selects the second. A name's occurrence number differs from the physical field index among all fields. A later `merge` part does not automatically override an earlier one. Reordering distinct names does not change a named path; reordering same-name occurrences may change the selected value.

A Structure's field count and positions are fixed at construction. Graph fields follow strictly lexical order; native-code emission order does not authorize rearranging the graph's fields. Updating an existing field replaces its stored reference; it does not append an occurrence. A different set of fields requires a new Structure. Array operations follow their own contracts and do not change this Structure rule.
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
@@ admission | Аналитическая проверка и валидация кандидата | Analytical checking and candidate validation | 2.1; 2.1.1-3; 2.5.1-3; 2.5.5-6; 19.21.3; 19.22; author 2026-09-20
[RU]
Единственный механизм допуска кандидата состоит из аналитического `implements` по дереву принимающего выражения и выполнения заданных этим выражением юнит-тестов через интерпретатор графа. Классификация адресов арены обслуживает представление значений; она не является альтернативной валидацией. Совпадение сигнатуры, наличие описания или положительный аналитический ответ не заменяют исполнение требуемых тестов.

<a id="analytical-tree"></a>
### Аналитическая часть

`implements(A B Consumer)` проверяет кандидата A относительно используемых Consumer путей образца B. Consumer — известное дерево принимающего выражения. Требуются используемые именованные пути, включая вложенные, и условия потребления их листьев. Неиспользуемые поля B не становятся требованиями. Без принимающего выражения контекст проверки не определён; двухаргументная форма не задаёт эту модель.

Использование определяется видимыми обращениями в дереве, в том числе в альтернативных ветвях, а не трассой одного запуска. Проверка не подменяется сравнением одинаковых физических позиций. Перестановка различно названных полей при сохранении путей не меняет результат. Для повторных имён действует [выбор вхождения](#fields).

Направление существенно: пригодность A вместо B для одного Consumer не означает обратной пригодности или пригодности для другого Consumer. Пустое множество используемых путей означает отсутствие структурных требований этой части анализа; обязательность юнит-тестов сохраняется. Наличие имени `validate` не создаёт специального неявного обработчика.

«Тонкое» потребление останавливается на листе: передача или хранение слова не доказывает единицы измерения, диапазон или корректность внешнего ресурса. «Толстое» потребление проходит по явным путям описания или поведения. Анализ не расширяет тела всех вызываемых функций, не исполняет вычисляемые имена и не выполняет полный анализ псевдонимов и потока данных кучи. Неизвестное покрытие остаётся неизвестным; оно не называется успешной проверкой неизвестных свойств.

Диагностика должна различать действительно тонкое использование и невозможность установить используемые пути. Она может показать, какая первая одноимённая ветвь выбрана после композиции, какие описательные поля не используются и какие требования остались неустановленными. Диагностика не вводит глобальный «строгий режим» и не меняет правила выбора поля.

Если принимающее выражение вызывает путь, контракт этого вызова включает объявленные и динамические входы, результат и выбрасываемые значения. Передача вызываемого значения без вызова не требует знания всех его будущих применений. На реально исполняемом вызове должны выполняться требования выбранного выражения; равная сигнатура не доказывает одинакового поведения.

<a id="graph-tests"></a>
### Исполнение тестов

Интерпретатор получает уже построенный граф исполняемых структур и связей. Разбор исходного текста предшествует этому этапу и не выполняет роль интерпретации. Принимающее выражение задаёт юнит-тесты, которые интерпретатор исполняет над кандидатом. Эти тесты выполняют содержательную runtime-валидацию: наличие поля с названием `range` или `unit` само по себе не доказывает соблюдение записанного ограничения.

Кандидат и проверяющее выражение имеют физическую идентичность. Успешная проверка не замораживает их состояние. Изменяемость, внешние эффекты и изменение использованных описаний должны учитываться условиями применения результата проверки. Способ повторного использования результатов, изоляция тестового исполнения и представление набора тестов требуют явного контракта; автоматическое разрешение этих вопросов из совпадения адресов не следует.

Обычные значения могут хранить результаты и свидетельства выполнения тестов, если это явно делает программа. Такие данные не создают второй предикат допуска и не подтверждают новые или изменившиеся условия автоматически. Отдельный прежний `RuntimeImplements` по доступному графу не входит в новую модель валидации.

Статически установленное нарушение сообщается при анализе. В прежней модели отказ runtime-проверки типа выражался `throw: Type` с данными кандидата, требуемой роли и Consumer. Точное оформление неуспеха нового набора юнит-тестов остаётся согласуемой частью интерфейса; общий порядок обработки объявленного `throw` описан в [исключениях](#exceptions). Ни проверка, ни освобождение памяти не означают отката уже опубликованных сообщений или внешних эффектов.
[EN]
The single candidate-admission mechanism consists of analytical tree-based `implements` for the receiving expression and execution of that expression's unit tests by the graph interpreter. Arena address classification supports value representation; it is not alternative validation. A matching signature, an attached explicit description or a positive analytical answer does not replace execution of the required tests.

<a id="analytical-tree"></a>
### Analytical stage

`implements(A B Consumer)` checks candidate A against the paths of reference value B used by Consumer. Consumer is the known receiving-expression tree. Used named paths, including nested paths, and their leaf-consumption requirements must be satisfied. Unused fields of B do not become requirements. Without a receiving expression, the checking context is undefined; a two-argument form does not specify this model.

Use is determined by visible accesses in the tree, including alternative branches, not the trace of one execution. Checking is not replaced by matching physical field positions. Reordering differently named fields while preserving paths does not change the result. Repeated names follow [occurrence selection](#fields).

Direction matters: suitability of A in place of B for one Consumer implies neither reverse suitability nor suitability for another Consumer. An empty used-path set means this part of analysis has no structural requirements; unit tests remain mandatory. A field named `validate` does not create a special implicit hook.

Thin consumption stops at a leaf: passing or storing a word does not prove units, ranges or foreign-resource validity. Thick consumption follows explicit descriptive or behavioral paths. Analysis does not expand all callees, execute computed names or perform whole-heap alias and dataflow analysis. Unknown coverage remains unknown; it is not reported as successful verification of unknown properties.

Diagnostics should distinguish genuinely thin consumption from inability to establish used paths. They may show which first same-name branch composition selects, which descriptive fields are unused and which requirements remain unresolved. Diagnostics do not introduce a global strict mode or change field-selection rules.

When a receiving expression invokes a path, that call's contract includes declared and dynamic inputs, results and thrown values. Transporting a callable without invoking it does not require knowledge of every future use. An executed call must satisfy the selected expression's requirements; equal signatures do not prove equal behavior.

<a id="graph-tests"></a>
### Test execution

The interpreter receives an already constructed graph of executable Structures and links. Parsing source text precedes this stage and does not serve as interpretation. The receiving expression defines unit tests for the interpreter to execute against the candidate. These tests provide substantive runtime validation: a field named `range` or `unit` does not by its presence prove that the stated constraint holds.

The candidate and checking expression have physical identities. Successful checking does not freeze their state. Mutation, external effects and changes to consulted descriptions must be accounted for by the conditions under which a result applies. Result reuse, isolation of test execution and representation of the test set require explicit contracts; matching addresses alone do not resolve them.

Ordinary values may store test results and evidence when the program explicitly does so. Such data do not create a second admission predicate or automatically certify new or changed conditions. The former separate available-graph `RuntimeImplements` is not part of the new validation model.

A statically established violation is reported during analysis. In the earlier model, runtime type-check rejection used `throw: Type` carrying the candidate, required role and Consumer. The exact failure interface of the new unit-test set remains to be settled; handling of declared `throw` is described in [exceptions](#exceptions). Neither validation nor memory reclamation rolls back already published messages or external effects.
@@ admission-recipes | Четырнадцать практических случаев типизации | Fourteen practical typing cases | 2.5.4; 2.5.3; author 2026-09-20
[RU]
Эти случаи раскрывают применение [единого механизма допуска](#admission). Аналитическая часть проверяет используемые пути; содержательные ограничения входят в юнит-тесты принимающего выражения. Примеры обозначают требуемое поведение, а не подтверждённую полноту нынешнего транслятора.

### 1. Одно принимающее выражение для разных форм данных

Выражение обращается только к нужным ему путям. Кандидат предоставляет эти пути, допустимые листья и требуемые контракты реально вызываемых выражений. Отдельное объявление параметров обобщённого типа для этого не требуется. Такая проверка используемого дерева обеспечивает структурное обобщение, но не обещает всех свойств параметрического полиморфизма.

### 2. Понимание того, что проверяется в данном месте

Consumer определяет область аналитической проверки. Доступные исходные обращения и неизвестное покрытие различаются явно. После анализа выполняются его юнит-тесты через интерпретатор графа. Успех не делает операнды неизменяемыми и не подтверждает все будущие способы использования. Требуемые фактическим вызовом входы должны быть доступны на этом вызове.

### 3. Различение смыслов одинаково представимых значений

Различие выражается путём, который действительно использует принимающее выражение. Для `Distance: Meter: 1` обращение `d\Meter` требует именно этого пути; структура только с `Foot` его не предоставляет. Одного внешнего имени `Meter`, поля `unit: "meter"` или квалификатора `const` недостаточно. Если важен смысл значения поля, его проверяет тест принимающего выражения.

### 4. Ограничение скалярного листа

Ограничение формулируется явно и включается в тесты. Наличие `x\width` не доказывает `width = 32`; даже при наличии описания скалярный лист может использоваться тонко. Доступные при сборке неизменяемые данные можно предварительно анализировать, но такое доказательство не объявляется альтернативным механизмом runtime-валидации.

### 5. Изменение, видимое другим держателям ссылки

Запись `p\x: value` или `a[i]: value` меняет выбранный объект. Голое `x: value` изменяет рабочее значение текущего вызова: собственное поле становится dirty и публикуется на границе, а обычная формальная, результатная или динамическая копия остаётся локальной. Исключение привязки входа к собственному полю и момент её активации определены в [рабочем состоянии](#dynamic). Ни одна из этих записей не добавляет одноимённое вхождение неявно.

### 6. Независимость от изменения другим держателем

Явное копирование создаёт независимые изменяемые значения по своему контракту; настоящая неизменяемость запрещает изменение защищённого значения. Обычная передача структуры или массива копирует ссылку. Поэтому внутри Message другой псевдоним может изменить общий изменяемый объект. Неизменяемость идентификатора внешнего ресурса не делает неизменяемым сам внешний ресурс.

### 7. Гарантия возможности вызова

Нужны используемые пути и контракт вызываемого выражения, а также все его динамические входы. Пусть A и B предоставляют одинаковый `m`, тело которого использует голое `x`, а Consumer лишь вызывает `m`. Проверка пути `m` не создаёт `x`: его должен предоставить текущий вызывающий контекст либо разрешённый лексический поиск. Анализ не подменяется разворачиванием всех тел вызываемых выражений.

### 8. Проверка передаваемого вызываемого значения

Передача вызываемого значения не является его исполнением и не требует знания всех будущих контрактов. Проверяются требования текущего принимающего выражения. Когда значение реально вызывается, выбранное выражение должно получить нужные входы и пройти применимый допуск. Одинаковые сигнатуры не означают одинакового алгоритма.

### 9. Изменение тела метода без нарушения вызовов

Свободные динамические имена тела входят в его интерфейс. Добавление такого имени меняет `DynRequired` и сигнатуру; известные вызывающие выражения требуется проверить заново. Неизменяемость записи метода не запрещает явную замену ссылки на совместимое вызываемое значение. Изменение поведения при прежней сигнатуре относится к тестам и правильности программы.

### 10. Выбор нужной части композиции

Нужное вхождение выбирается явно либо строится нужный набор полей. `merge` сохраняет прямой порядок и не реализует наследование с правилом «последний победил». Если результат содержит `read` из A, затем из B, `result\read` и `result\[0]read` выбирают A; `result\[1]read` выбирает B. Аналитическая диагностика может обнаружить непреднамеренный выбор после изменения импорта или композиции.

### 11. Изменение существующей структуры

Поля и их число фиксированы. Можно заменять ссылки в существующих полях, соблюдая требования их использования. Иное число полей требует новой структуры, например результата `merge`. Не вводится политика разрешения конфликтов для несуществующих операций «удалить или переместить активное поле».

### 12. Надёжное численное преобразование

Используется доступный явно выбранный преобразователь с контрактом диапазона назначения: `u16(255) → u8` допустимо, `u16(256) → u8` — ошибка диапазона. Округление и потеря точности внутри диапазона задаются отдельно. Прохождение аналитической проверки не даёт разрешения молча обернуть значение по модулю.

### 13. Значение широкой таблицы преобразователей

Дополнительные явные ключи расширяют набор доступных преобразований листьев. Они не меняют требуемые пути дерева и контракт вызываемых выражений. Профиль не обязан предоставлять все пары; отсутствующий преобразователь остаётся отсутствующим. Аналитическая проверка не исполняет преобразователи и не ищет скрытую цепочку преобразований.

### 14. Корректность внешнего ресурса

Для внешнего дескриптора нужны явная высокоуровневая обёртка и контракт владения, использования и освобождения. Тонкий лист наподобие `FILE` не доказывает действительность ресурса, полномочия или однократность закрытия. Юнит-тесты принимающего выражения проверяют заявленные свойства в пределах своего контракта; неизменяемые биты дескриптора не удерживают ресурс живым. В L3 нет обычных машинных `own:`/`borrow:`/`move:`, а `copy:` не изобретает способ дублирования внешнего ресурса.
[EN]
These cases explain the [single admission mechanism](#admission). Its analytical stage checks used paths; substantive constraints belong to the receiving expression's unit tests. The examples specify required behavior, not verified completeness of the current translator.

### 1. One receiving expression for multiple data shapes

The expression accesses only the paths it needs. A candidate provides those paths, admitted leaves and the required contracts of expressions actually invoked. No separate generic type-parameter declaration is required. This used-tree check provides structural generality without promising every property of parametric polymorphism.

### 2. Knowing what a particular site checks

Consumer determines analytical coverage. Available source accesses and unknown coverage are distinguished explicitly. Analysis is followed by its unit tests through the graph interpreter. Success does not freeze operands or certify every future use. Inputs required by an actual invocation must be available at that invocation.

### 3. Distinguishing meanings with the same representation

Encode the distinction in a path the receiving expression actually uses. With `Distance: Meter: 1`, access through `d\Meter` requires that path; a Structure exposing only `Foot` does not provide it. An outer name `Meter`, a field `unit: "meter"` or `const` alone is insufficient. When a field value's meaning matters, a receiving-expression test checks it.

### 4. Constraining a scalar leaf

State the constraint explicitly and include it in tests. Presence of `x\width` does not establish `width = 32`; a scalar leaf may remain thinly consumed even when a description exists. Immutable build-time data can undergo preliminary analysis, but such a proof is not an alternative runtime-validation mechanism.

### 5. Making a change visible to other reference holders

Writing `p\x: value` or `a[i]: value` changes the selected object. Bare `x: value` changes the current call's working value: an own field becomes dirty and is published at a boundary, while an ordinary formal, result or dynamic copy remains local. The input-to-own-field binding exception and its activation point are defined under [working state](#dynamic). Neither write implicitly appends a same-name occurrence.

### 6. Independence from another holder's mutation

Explicit copying creates independent mutable values under its contract; genuine immutability prohibits mutation of the protected value. Ordinary Structure or Array passing copies a reference. Another alias within the Message can therefore change the shared mutable object. An immutable foreign-resource identifier does not make the foreign resource immutable.

### 7. Establishing that a call can proceed

The used paths and callable contract must hold, and all dynamic inputs must be supplied. Suppose A and B expose the same `m`, whose body uses bare `x`, while Consumer only invokes `m`. Checking path `m` does not create `x`: the current calling context or permitted lexical fallback must provide it. Analysis is not replaced by expansion of every callee body.

### 8. Checking a transported callable

Transporting a callable does not execute it or require knowledge of every future contract. The current receiving expression's requirements are checked. At actual invocation, the selected expression must receive its required inputs and satisfy the applicable admission requirements. Equal signatures do not imply equal algorithms.

### 9. Changing a method body without breaking calls

The body's free dynamic names are part of its interface. Adding one changes `DynRequired` and the signature; known callers require rechecking. An immutable method record does not prohibit explicit replacement of a reference with a compatible callable. Behavioral change under the same signature is a matter for tests and program correctness.

### 10. Selecting the intended part of a composition

Select the occurrence explicitly or construct the intended fields. `merge` preserves forward order and does not implement last-wins inheritance. If the result contains A's `read` followed by B's, `result\read` and `result\[0]read` select A; `result\[1]read` selects B. Analytical diagnostics may expose unintended selection after an import or composition changes.

### 11. Changing an existing Structure

Fields and their count are fixed. References in existing fields may be replaced subject to their use requirements. A different field count requires a new Structure, such as a `merge` result. No conflict policy is introduced for nonexistent operations that remove or move an active field.

### 12. Reliable numeric conversion

Use an available explicitly selected converter with a destination-range contract: `u16(255) → u8` is admitted, while `u16(256) → u8` is a range error. In-range rounding and precision loss are specified separately. Successful analytical checking does not permit silent modular wrapping.

### 13. What a broad converter table provides

Additional explicit keys widen the available leaf conversions. They do not alter required tree paths or callable contracts. A profile need not provide every pair; a missing converter remains missing. Analytical checking does not execute converters or search for a hidden conversion chain.

### 14. Foreign-resource validity

A foreign handle requires an explicit high-level wrapper and contracts for ownership, use and release. A thin `FILE`-like leaf does not establish validity, authority or single close. The receiving expression's unit tests check declared properties within their contract; immutable handle bits do not keep a resource alive. L3 has no ordinary machine-level `own:`/`borrow:`/`move:`, and `copy:` does not invent a foreign resource's duplication policy.

@@ construction | Построение значений | Value construction | 9.1–9.2; 19.20
[RU]
Структурное выражение строит значение, когда исполнение достигает этого выражения. Объявление имени, импорт или наличие описания не создаёт заранее все экземпляры. Для именованных и анонимных структур действует один механизм: определить лексического родителя, создать поля с устойчивой идентичностью, вычислить инициализаторы в исходном порядке, установить ссылки и опубликовать успешно инициализированный результат. У корня `independent` внешний лексический родитель отсутствует.

В объявлении `u32: id`, `Text: crop`, `f64: harvest 0.0` операция-конструктор принимает следующий идентификатор как предлагаемое имя, а не вычисляет прежнее значение этого имени. Форма `PlantBed: bed` требует доступной операции построения `PlantBed`: одноимённое описание само по себе конструктором не становится. Повторное объявление существующего поля подчиняется требованиям оставшихся принимающих выражений; оно не создаёт новый тип или скрытую таблицу имён.

Двоеточие строит вложенную форму применения. В `const: char: []: s "hello" "world!"` операции квалификации, выбора элемента и построения массива имеют собственные контракты. `char` задаёт примитивный элемент, `String` — высокоуровневое неизменяемое текстовое значение; `String` не является другим написанием машинного `char *`. `String: ()` строит структуру ссылок, а `String: []` — массив ссылок согласно соответствующим конструкторам.

Поле может удерживать ссылку на уже существующий объект. Это не копирование и не переподчинение его лексического родителя. Пустая структура существует как значение и не равна отсутствующему аргументу. В следующем построении два поля `count` сохраняются: `result\count` выбирает 3, `result\[1]count` — 4.

```text
(): result
    int: count 3
    String: text "hello"
    int: count 4
end: result
```

Именование не добавляет к объекту дескриптор, класс или специальную раскладку. Построение отличается от [композиции](#composition): оно создаёт выраженный граф, тогда как `merge` копирует граф своих операндов. Политика повторного вычисления и повторного использования значения верхнеуровневого именованного построения ещё требует определения; предварительное создание всех значений при трансляции из этого не следует.
[EN]
A structural expression constructs a value when execution reaches it. Declaring a name, importing a unit or providing a description does not eagerly create every instance. Named and anonymous Structures share one mechanism: determine the lexical parent, create fields with stable identity, evaluate initializers in source order, establish links and publish the successfully initialized result. An `independent` root has no external lexical parent.

In declarations `u32: id`, `Text: crop`, `f64: harvest 0.0`, the constructor operation consumes the following identifier as a proposed name rather than evaluating its previous value. `PlantBed: bed` requires an available `PlantBed` construction operation: a same-named description does not become a constructor by itself. Redeclaration of an existing field is subject to the remaining receiving expressions' requirements; it creates neither a new type nor a hidden name table.

The colon builds a nested application form. In `const: char: []: s "hello" "world!"`, qualification, element selection and Array construction have their respective contracts. `char` selects a primitive element; `String` denotes a higher-level immutable text value, not another spelling of machine `char *`. `String: ()` constructs a Structure of references, whereas `String: []` constructs an Array of references under the respective constructors.

A field can retain a reference to an existing object. This neither copies it nor reparents its lexical parent. An empty Structure is a present value, not an absent argument. In the following construction both `count` fields remain: `result\count` selects 3 and `result\[1]count` selects 4.

```text
(): result
    int: count 3
    String: text "hello"
    int: count 4
end: result
```

Naming does not add a descriptor, class or special layout to the object. Construction differs from [composition](#composition): it creates the expressed graph, whereas `merge` copies its operands' graph. The evaluation/reuse policy of a top-level named construction still requires definition; eager materialization of every value during translation does not follow from it.

@@ qualification | const, immutable и independent | const, immutable and independent | 2.5.3; 9.1.2–9.1.3
[RU]
`const` защищает привязку: её нельзя присвоить, перепривязать или заменить. Значение за защищённой ссылкой может оставаться изменяемым. `immutable` защищает само значение на протяжении всей его жизни, через любые псевдонимы; переменная, содержащая ссылку на него, может оставаться перепривязываемой. `const: immutable` объединяет обе гарантии. Это независимые квалификации, а не ступени одной шкалы.

Неизменяемость применима к примитиву, структуре и выбранному дереву, массиву с дескриптором и элементами. Она охватывает позиционные поля, все одноимённые вхождения и явно включённые описания, а не только пути Consumer или первое вхождение. Передача, возврат и сохранение неизменяемого значения сохраняют его идентичность; квалификация не требует копии, в том числе для примитива. Она не замораживает внешний ресурс, обозначенный неизменяемым идентификатором.

`immutable` при построении квалифицирует новое значение до публикации. `RuntimeImmutable` квалифицирует уже существующее дерево с сохранением его идентичности. Название второй операции не обозначает второй механизм допуска аргументов: её собственный операционный контракт — изменение квалификации. Её аргументы проходят [единый допуск](#admission), как аргументы любого принимающего выражения.

Перед изменением квалификации исследуется всё выбранное дерево. Вложенная структура является ветвью дерева только тогда, когда её `node` указывает на рассматриваемого родителя. Внешняя ссылка допустима только на уже неизменяемый объект; она терминальна, её цель не обходится и не переквалифицируется. Проверяется состояние до начала изменения: результат обработки раннего поля не может оправдать недопустимую внешнюю ссылку в позднем. Некорректная вложенность или изменяемая внешняя цель приводят к объявленному `throw`, а не к `assert`.

Примитивы и методы — листья, не ветви лексического дерева. Ссылка на массив также не создаёт ветвь `node`: операция над деревом не замораживает неявно изменяемое хранилище внешнего массива. Неизменяемый массив строится по собственному контракту. Принадлежность ячейки служебному пулу не даёт права обходить или квалифицировать весь пул.

Квалификация применяется только после успешной полной предварительной проверки. При неудаче нет частично замороженного дерева и опубликованного успешного результата; запрещено молча пропускать ветвь, копировать её или перенаправлять ссылки. Повторная квалификация уже подходящего дерева ничего не меняет. Правило не откатывает ранее выполненные инициализаторы, вычисление аргументов или публикацию рабочих полей перед вызовом; транзакция графа не возникает.

Защита обязательна для записей через любой путь и для публикации рабочих полей. Заведомо недопустимая запись отвергается до исполнения, динамически выбранная — проверяется при исполнении. Вызов метода разрешён, но не снимает защиты. Изменение локальной копии аргумента или перепривязка локальной ссылки не меняют защищённое значение. Построение нового значения, в том числе `merge`, не размораживает исходное.

`independent` при построении устанавливает отсутствие внешнего лексического родителя. Внутренние связи дерева и собственные поля сохраняются. Квалификация не очищает `node` существующих объектов и не запрещает явно переданные ссылки, динамические аргументы текущего вызывающего выражения, сообщения или выбор вызываемого выражения по совместимой сигнатуре. Это не требование чистоты и не закрытый интерфейс только из явных аргументов.

Например, метод внутри независимой структуры S может использовать поле S через внутреннюю лексическую связь. Требуемое `x` может прийти из текущего вызывающего выражения. Если `x` находится только в прежнем текстовом окружении S, внешнего неявного доступа к нему нет. Явно переданный большой массив не становится меньше и не копируется из-за `independent`. Особый срок жизни сочетания трёх квалификаций описан в [вечных ветвях](#eternal).
[EN]
`const` protects a binding: it cannot be assigned, rebound or replaced. The value behind a protected reference may remain mutable. `immutable` protects the value itself for its entire life through every alias; a variable holding its reference may remain rebindable. `const: immutable` combines both guarantees. They are independent qualifications, not degrees of one scale.

Immutability applies to a primitive, a Structure and its selected tree, or an Array with its descriptor and elements. It covers positional fields, every repeated occurrence and explicitly included descriptions, not just Consumer's paths or the first occurrence. Passing, returning and storing an immutable value preserve its identity; qualification requires no copy, including for a primitive. It does not freeze a foreign resource denoted by an immutable identifier.

Construction-time `immutable` qualifies the new value before publication. `RuntimeImmutable` qualifies an existing tree while retaining its identity. The second operation's name does not denote a second argument-admission mechanism: changing qualification is its operational contract. Its arguments undergo [unified admission](#admission), like those of every receiving expression.

The whole selected tree is examined before qualification changes. A contained Structure is a tree branch only when its `node` points to the parent being examined. An outside reference is permitted only to an already immutable object; it is terminal, and its target is neither traversed nor requalified. The pre-change state is checked: processing an earlier field cannot justify an invalid outside reference in a later field. Malformed containment or a mutable outside target follows a declared `throw`, not `assert`.

Primitives and methods are leaves, not lexical-tree branches. An Array reference likewise establishes no `node` branch: a tree operation does not implicitly freeze an outside Array's mutable backing. An immutable Array is constructed under its own contract. A cell's membership in a service pool does not permit traversal or qualification of the entire pool.

Qualification is applied only after successful complete preflight. Failure leaves no partially frozen tree or published successful result; silently skipping a branch, copying it or retargeting links is prohibited. Requalifying an already suitable tree changes nothing. This rule does not roll back earlier initializers, argument evaluation or pre-call publication of working fields; it establishes no graph transaction.

Protection applies to writes through every path and to publication of working fields. A known-invalid write is rejected before execution; a dynamically selected write is checked during execution. Calling a method is allowed but does not remove protection. Changing a local argument copy or rebinding a local reference does not modify the protected value. Constructing a new value, including through `merge`, does not thaw the source.

Construction-time `independent` establishes the absence of an external lexical parent. Internal tree links and own fields remain. The qualification neither clears existing objects' `node` links nor prohibits explicitly supplied references, current-caller dynamic arguments, Messages or selection of a callable by a compatible signature. It does not require purity or an interface closed over explicit arguments alone.

For example, a method inside independent Structure S can use S's field through its internal lexical link. Required `x` can come from the current caller. If `x` exists only in S's former textual surroundings, implicit external access is unavailable. An explicitly passed large Array neither shrinks nor gets copied because of `independent`. The special lifetime of the three qualifications together is described under [eternal branches](#eternal).

@@ callables | Вызываемые выражения и их интерфейсы | Callable expressions and their interfaces | 7–7.3; 7.5.1; 8.5–8.8; 19.21; 21.9
[RU]
Исполняемое тело — структурное выражение. `fn` определяет выражение с одним логическим результатом; `sub` — выполнение без возвращаемого значения; `fm` — один результат-структуру, поля которой образуют поверхность множественного возврата. Сигнатура задаёт явные аргументы, требуемые динамические и лексические входы, способ передачи каждого значения, результат и объявленные выходы `throws`. Сам факт наличия структуры, метки или имени не выполняет её тело.

Вызываемое вхождение имеет собственную структурную идентичность и связь с лексическим родителем. Несколько вхождений могут ссылаться на один неизменяемый метод. Копирование графа не создаёт новую реализацию метода и не меняет его сигнатуру; состояние принадлежит конкретным структурным вхождениям и активациям. Вложенное определение не захватывает кадр вызывающего выражения в скрытое окружение.

Выбор вызова начинается с явной ссылки, структурного пути либо текстового пути с явно переданным корнем. Выбор реализации и подача её аргументов — разные действия. Обнаруженный кандидат проходит [допуск](#admission); затем вызов должен получить все входы сигнатуры. Наличие подходящего поля с методом ещё не обеспечивает его динамические входы. Передача метода как данных не равна его вызову.

Позиционные фактические аргументы предшествуют именованным. После первого именованного аргумента последующие также именованные. Неизвестное имя, повторное присваивание одного аргумента, недостающий обязательный аргумент или нарушение порядка — ошибка. Тело именованного аргумента передаётся как структурное значение, если именно такой режим задаёт принимающее выражение; оно не становится произвольной последовательностью немедленных вызовов.

Синтаксические границы имени функции, списка аргументов, описания результата и тела определены в [грамматике](LMX_grammar.ru.md). Пустой список аргументов является присутствующим пустым значением. Описания и подписи не создают неявный вызов. Формы объявления без тела и связывания части аргументов пока не устанавливают общего механизма автоматического каррирования или создания замыканий.

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
An executable body is a structural expression. `fn` defines an expression with one logical result; `sub` performs execution without a returned value; `fm` has one result Structure whose fields provide a multiple-return surface. The signature defines explicit arguments, required dynamic and lexical inputs, each value's pass mode, the result and declared `throws` exits. Merely having a Structure, label or name does not execute its body.

A callable occurrence has its own structural identity and lexical-parent link. Multiple occurrences can reference one immutable method. Graph copying neither creates another method implementation nor changes its signature; state belongs to particular structural occurrences and activations. A nested definition does not capture a caller frame in a hidden environment.

Callable selection starts from an explicit reference, structural path or textual path with an explicitly supplied root. Selecting an implementation and providing its arguments are distinct actions. The selected candidate undergoes [admission](#admission); the call must then receive every signature input. A suitable method field does not by itself supply its dynamic inputs. Transporting a method as data is not invoking it.

Positional actual arguments precede named ones. After the first named argument, subsequent arguments must also be named. An unknown name, duplicate assignment to one argument, missing required argument or ordering violation is an error. A named argument's body is supplied as a structural value when that is the receiving expression's specified mode; it does not become an arbitrary sequence of immediate calls.

The syntactic boundaries of the function name, argument list, result description and body are defined in the [grammar](LMX_grammar.en.md). An empty argument list is a present empty value. Descriptions and signatures do not create implicit calls. Bodyless declarations and partial-argument binding forms do not yet establish general automatic currying or closure construction.

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
Следует различать постоянное поле графа, рабочее значение собственного поля текущей активации, явный формальный аргумент и динамический вход. Это разные места хранения с разными правилами изменения. Обычная передача изменяемого примитива копирует значение, структуры и массива — ссылку; особая идентичность неизменяемого значения сохраняется согласно [квалификации](#qualification).

Для свободного имени вызываемое выражение получает текущее значение из доступного контекста вызывающего выражения; при его отсутствии используется допустимый лексический поиск по `node`. Внутренние собственные объявления и формальные параметры имеют свои разрешённые места, а не ищутся в глобальном реестре. Список необходимых сквозных имён входит в сигнатуру: добавление свободного имени меняет интерфейс. При отсутствии необходимого входа вызов недопустим; молчаливое создание нуля или нового поля запрещено.

Приоритет источников свободного имени: ближайшая текущая локальная привязка вызывающего выражения, затем уже унаследованный им динамический вход, затем лексический поиск вызываемого выражения. Локальная привязка включает используемое собственное поле, формальный аргумент, результат или иное локальное значение, определённое принимающим выражением. Требования статически известных вызовов распространяются до неподвижной точки, в том числе через взаимную рекурсию. Имя, нужное только следующему вызову, также должно сохраняться и передаваться; само по себе это не создаёт поле графа.

Лексический поиск использует реальные связи структуры, заканчивается на нулевом родителе и выбирает прямое первое одноимённое вхождение на соответствующем шаге. `independent` отсекает только внешний лексический запасной путь. Явное обращение `node\x`, `reference\x` или `array[index]` обращается к графу, а не подменяется динамическим `x` текущего вызова.

Рабочее значение собственного поля загружается для активации. Присваивание такому имени меняет рабочее значение и отмечает его как изменённое. Присваивание формальному или динамическому входу меняет только его локальную копию, без автоматической обратной записи вызывающему выражению. Явная запись через ссылку меняет выбранный объект непосредственно и наблюдаема через другие ссылки на него.

Исключение для одноимённой привязки: исполнившееся объявление собственного поля либо присваивание-объявление может связать вход с полем текущего тела. С этой строки то же рабочее значение становится own-кэшем этого поля; прежнее значение графа не загружается поверх входа. Более ранние изменения входа не публикуются. Подготовленный заранее слот не делает привязку активной до исполнения её строки и не меняет число полей. Публикация идёт в собственное поле тела, никогда в источник аргумента у вызывающего выражения.

Каждое тело, которое принимающее выражение исполняет по операторам, — структура графа и владелец непосредственно объявленных в нём полей. Тела `if` и `else`, циклов и других принимающих выражений образуют вложенную иерархию, не плоский список полей метода. Невыполненная ветвь не производит присваиваний. Обычный вложенный блок не создаёт новую активацию метода или границу динамических входов. Условие, аргумент вызова и аргумент `return` сами по себе не являются исполняемыми телами: их роль задаёт принимающее выражение, а не наличие вложенной структуры в последней синтаксической позиции.

```text
fn: remember (int: x) int
    x: 7
    return: x
end: remember
```

Здесь входной `x` становится собственным полем тела при исполнении `x: 7`. Меняется состояние `remember`, а не переменная вызывающего выражения. Кэшируются только собственные поля, реально используемые голым именем либо для передачи динамического входа дальше; явный путь сам по себе не создаёт own-кэш. Существующее поле не исчезает из графа из-за отсутствия кэширования.

Перед передачей управления другому вызываемому выражению публикуются только собственные рабочие поля, записанные после последней успешной публикации. После публикации их отметки очищаются. Неизменённое кэшированное поле не записывается обратно: вложенный вызов мог уже изменить его через явную ссылку. После возврата вызывающая активация не перечитывает свои рабочие значения из графа.

Dirty определяется выполненной записью, не сравнением значений и не наличием возможного присваивания в исходном тексте. Публикация следует прямому порядку полей; успешная запись очищает отметку соответствующего поля. Невозможность разрешить уже связанный слот или записать его — диагностический `assert`; предназначенный внешний вызов после этого не выполняется. Общей транзакции с откатом предыдущих записей нет. Публикация нужна также перед внешней границей, способной вызвать LMX обратно или раскрыть состояние графа.

Следовательно, после вложенного изменения `node\x` рабочее голое `x` вызывающего выражения может сохранять прежнее значение, тогда как явный путь видит новое. Позднейшее присваивание голому собственному `x` намеренно создаёт новую запись и опубликует её на следующей границе. Отсутствие автоматического перечитывания — часть семантики, а не разрешение терять отмеченные изменения.

Рекурсивные вызовы получают отдельные рабочие значения и отдельные отметки изменений, даже если используют одно структурное вхождение метода. Публикация одной активации не превращает рабочие значения другой в ссылки на её стек. Тело, переданное принимающему выражению как структура, и аргументы исполняемого вызова также не становятся общим скрытым окружением.

Публикация обязательна на границах вызова, возврата, `throw`, диагностического прекращения и `yield`. Выход с `finally` имеет две публикации, описанные в [выходах](#exits). `retry` и локальный переход цикла сами по себе не создают новую активацию и не перечитывают поля. Сигнатуры и граф сохраняют требования этой модели независимо от того, исполняется ли граф интерпретатором или транслируется.
[EN]
A persistent graph field, the current activation's working value of an own field, an explicit formal argument and a dynamic input must be distinguished. They are separate storage locations with separate mutation rules. Ordinary passing copies a mutable primitive's value and a Structure or Array's reference; the special identity of an immutable value is retained under [qualification](#qualification).

For a free name, the called expression receives the current value from the caller's available context; if unavailable, permitted lexical lookup follows `node`. Own declarations and formal parameters have their respective resolved locations rather than being searched in a global registry. Required through-names are part of the signature: adding a free name changes the interface. A missing required input makes the call inadmissible; silently creating zero or a new field is prohibited.

A free name's sources have this priority: the caller's nearest current local binding, then its already inherited dynamic input, then the callee's lexical lookup. A local binding includes a used own field, formal argument, result or another receiver-defined local value. Statically known call requirements propagate to a fixed point, including through mutual recursion. A name needed only by the next call must still be retained and forwarded; forwarding alone creates no graph field.

Lexical lookup uses real Structure links, stops at a zero parent and selects the direct first same-named occurrence at the relevant step. `independent` cuts only the external lexical fallback. Explicit access through `node\x`, `reference\x` or `array[index]` addresses the graph rather than being replaced by the current call's dynamic `x`.

An own field's working value is loaded for the activation. Assigning that name changes the working value and marks it dirty. Assigning a formal or dynamic input changes only its local copy, without automatic copy-back to the caller. An explicit reference write changes the selected object directly and is observable through other references to it.

Same-name binding is the exception: an executed own-field declaration or assignment-as-declaration can bind an input to the current body's field. From that line the same working value becomes that field's own cache; no previous graph value is loaded over the input. Earlier input changes are not published. A preallocated slot neither activates the binding before its statement executes nor changes the field count. Publication targets the body's own field, never the caller's argument source.

Every body that a receiving expression executes statement by statement is a graph Structure hosting its directly declared fields. Bodies of `if`, `else`, loops and other receivers form a containment hierarchy, not a flat method-field list. An untaken branch performs no assignments. An ordinary nested block creates neither another method activation nor a dynamic-input boundary. Conditions, call arguments and `return` arguments are not executable bodies merely by being arguments: their receiving expression determines the role, not a Structure in the last syntactic position.

```text
fn: remember (int: x) int
    x: 7
    return: x
end: remember
```

Here input `x` becomes the body's own field when `x: 7` executes. This changes `remember` state, not the caller's variable. Only own fields actually used by a bare name or to forward a dynamic input are cached; an explicit path alone creates no own cache. Lack of caching does not remove an existing field from the graph.

Before control passes to another callable expression, only own working fields written since their latest successful publication are published. Their dirty marks are then cleared. A clean cached field must not be written back: a nested call may already have changed it through an explicit reference. After return, the caller activation does not reload its working values from the graph.

Dirty state follows an executed write, not value comparison or the presence of a possible assignment in source. Publication follows forward field order; a successful write clears the corresponding dirty mark. Failure to resolve an already bound slot or store into it uses diagnostic `assert`; the intended outbound call is not executed afterward. There is no general transaction rolling back earlier writes. Publication is also required before a foreign boundary capable of calling back into LMX or exposing graph state.

Consequently, after a nested modification of `node\x`, the caller's bare working `x` can retain its earlier value while an explicit path observes the new value. A later assignment to bare own `x` deliberately creates a new write and publishes it at the next boundary. No automatic reload is part of the semantics, not permission to lose dirty changes.

Recursive calls have separate working values and dirty marks even when using the same callable structural occurrence. One activation's publication does not turn another's working values into references to its stack. A body supplied to a receiving expression as a Structure and an executable call's arguments likewise do not become one hidden environment.

Publication is required at call, return, `throw`, diagnostic termination and `yield` boundaries. An exit with `finally` has the two publications specified under [exits](#exits). `retry` and local loop transfers do not by themselves create a new activation or reload fields. Signatures and the graph retain this model's requirements whether the graph is interpreted or translated.

@@ branches | Ветвления и циклы | Branches and loops | 10; 19.1–19.9; 19.14; 19.16
[RU]
Управляющие принимающие выражения определяют способ потребления своих структурных тел. Принадлежность к телу не означает обязательное немедленное выполнение всех его полей. Метки управления обозначают видимые цели перехода; упоминание метки само по себе не вызывает тело и не является неявным `goto`.

`if` вычисляет условие один раз и исполняет тело при истинном результате. Непосредственно следующий `else` на том же уровне исполняется только при ложном результате. Вставка другого оператора между ними нарушает пару. Профильный `branch` с именованными ветвями может существовать отдельно и не заменяет этот контракт.

`match` выбирает подходящую ветвь по выраженным шаблонам. Ветви могут задаваться парами «шаблон — тело» или явными структурами согласно профилю; `default` является определённым профилем шаблоном, а не универсальным эффектом произвольного имени. Объединение шаблонов и требование исчерпывающего покрытия задаются контрактом. Автоматического проваливания в следующую ветвь нет, если оно явно не определено.

`while` проверяет условие перед каждой итерацией и может ни разу не выполнить тело. Закрывающий `until` задаёт проверку после тела: тело выполняется хотя бы один раз, затем повторяется, пока условие ложно. Основной `for` содержит инициализацию, условие, шаг и тело; инициализация выполняется один раз, затем проверка, тело и шаг. Единая семантика всех сокращений диапазонов пока не установлена.

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

`while` checks its condition before each iteration and can execute its body zero times. Closing `until` establishes a postcondition: the body executes at least once and repeats while the condition is false. Core `for` contains initialization, condition, step and body; initialization runs once, followed by condition, body and step. Unified semantics for all range shorthands are not yet established.

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

`catch` — точка приёма в блоке вызывающего выражения, не обычный вложенный `sub`. При первом прямом проходе её тело пропускается. После доставки соответствующего отказа тело выполняется, затем исполнение продолжается с операторов после этого `catch`. Поэтому обработчик, поставленный до вызова, повторно вводит выполнение в последующий участок; обработчик после вызова продолжает за собой. Участок ограничен следующим `catch` того же блока или концом блока.

Два одноимённых обработчика в одном блоке запрещены; отдельные вложенные блоки могут иметь каждый свой. Доставка выбирает обработчик по блоку вызова, не одноимённый обработчик соседнего блока. Повторный `throw` того же имени внутри обработчика не входит в этот обработчик заново: это отказ во внешнем вызывающем контексте. Необработанное имя распространяется только через соответствующие объявления `throws`.

Исторический контракт отказа проверки совместимости использует `Type` и нагрузку `(varA, varB, Consumer)`. В новой модели он относится к [единому допуску](#admission); отдельный путь `RuntimeImplements` не вводится. Детальный интерфейс результатов и отказов юнит-тестов требует согласования, а не произвольного отождествления с любым старым валидатором.

`assert` проверяет диагностический инвариант. Ложное условие порождает `AssertionViolation`, а не восстанавливаемый `throw`; его нельзя поймать обычным `catch`, и оно не входит в `throws`. В акторном профиле после публикации и очисток диагностика передаётся корню исполняющегося Message, Message прекращает исполнение и больше не получает тактов. Это не обязательное завершение рабочего потока ОС; остановка и уничтожение объекта различаются.

Ожидаемые ошибки входных данных обрабатываются явным условием и объявленным отказом, а не диагностической аварией. `log` и `error` записывают наблюдения через выбранный профиль. Само `error` не означает `throw`, `assert`, возврат или остановку. Нелитеральный аргумент разрешается как обычное значение; неизвестное имя не превращается автоматически в строку журнала.
[EN]
`throws` lists names of an expression's possible recoverable exits, not exception types. The caller must provide a `catch` for each name or include it in its own `throws`. A call without either treatment is rejected. Failure detection uses ordinary `if`; module `guard` is not a failure-handling operator.

`throw: Name(arguments)` evaluates an explicit payload and leaves the current activation under the [exit rules](#exits), without returning its declared result. The selected `catch: Name (...)` parameters receive the payload. A handler's repeat call begins a new activation from the start and does not resume the abandoned frame.

`catch` is a landing pad in the caller's block, not an ordinary nested `sub`. Its body is skipped on the initial straight-line pass. When the corresponding failure arrives, its body runs and execution continues with the statements after that `catch`. Consequently, a handler before a call re-enters the following region; a handler after the call continues past itself. The region ends at the next `catch` in the same block or the block's end.

Two same-named handlers in one block are prohibited; separate nested blocks can each have one. Delivery selects the handler by the calling block, not a same-named handler in a sibling block. Throwing the same name inside a handler does not re-enter it: this is a failure in the enclosing calling context. An unhandled name propagates only through matching `throws` declarations.

The historical compatibility-failure contract uses `Type` with payload `(varA, varB, Consumer)`. In the new model it belongs to [unified admission](#admission); no separate `RuntimeImplements` path is introduced. The detailed unit-test result/failure interface requires agreement rather than arbitrary identification with an old validator.

`assert` checks a diagnostic invariant. A false condition produces `AssertionViolation`, not a recoverable `throw`; ordinary `catch` cannot handle it and it is not part of `throws`. In the actor profile, publication and cleanup precede delivery to the executing Message's diagnostic root; that Message stops executing and receives no further turns. This need not terminate the OS worker; stopping execution and destroying the object are distinct.

Expected input errors use an explicit condition and declared failure rather than a diagnostic abort. `log` and `error` record observations through the selected profile. `error` alone does not imply `throw`, `assert`, return or termination. A non-literal argument resolves as an ordinary value; an unknown name does not automatically become a log string.

@@ suspension | Повторный запуск и приостановка | Restart and suspension | 7.3; 19.12; 19.15; 21.10
[RU]
`retryable` задаёт повторяемую область. `retry` без имени повторяет ближайшую активную такую область; `retry: label` — указанную. Перед повтором выполняются очистки покидаемой попытки. Переход не откатывает внешние эффекты, изменения графа, уже опубликованные поля или сообщения. Транзакционный откат возможен только как отдельно выраженный протокол над данными.

Сам `retry` — локальный переход текущей активации, не новый вызов и не восстановление скрытого окружения. Текущие рабочие значения продолжают существовать, дополнительной публикации только из-за перехода нет. Если повтор достигает вызова или выхода, действует соответствующая обычная граница. Нагрузка пойманного отказа остаётся явными аргументами обработчика.

`yield` передаёт произведённое значение и приостанавливает активацию. Перед приостановкой публикуются изменённые собственные поля. Явные аргументы, динамические входы, рабочие значения и их последующее состояние сохраняются для возобновления; они не превращаются в поля тела или публичное скрытое окружение. Возобновление не перечитывает их из структуры метода.

Входы производителя фиксируются при начале его активации. Следующий вызывающий `next` не заменяет их своим динамическим окружением. Если `next` реализован отдельным выражением-обёрткой, его входы относятся к его активации, пока явная операция не изменит сохранённое состояние производителя. Представление продолжения и результата итератора ещё не закреплено; сохранение описанной семантики обязательно для любого представления.
[EN]
`retryable` defines a restartable region. Unlabelled `retry` repeats the nearest active such region; `retry: label` repeats the named one. Abandoned-attempt cleanups run before restarting. The transfer does not roll back external effects, graph mutations, already published fields or Messages. Transactional rollback requires an explicitly represented data protocol.

`retry` itself is a local transfer in the current activation, not a new call or restoration of a hidden environment. Current working values continue to exist, with no additional publication merely because of the transfer. If repeated execution reaches a call or exit, that boundary's ordinary rules apply. A caught failure's payload remains the handler's explicit arguments.

`yield` transfers a produced value and suspends the activation. Dirty own fields are published before suspension. Explicit arguments, dynamic inputs, working values and their subsequent state are retained for resumption; they do not become body fields or a public hidden environment. Resumption does not reload them from the method Structure.

Producer inputs are fixed when its activation begins. A later `next` caller does not replace them with its own dynamic context. If `next` is a separate wrapper expression, its inputs belong to its activation unless an explicit operation changes the producer's saved state. The continuation and iterator-result representation remains unsettled; every representation must preserve these semantics.

@@ arrays | Массивы, форма и совместное хранилище | Arrays, shape and shared backing | 6.1–6.5.5; 12–13; 19.29.3
[RU]
Обычный Array — типизированное значение с устойчивой ссылочной идентичностью. Конструктор `[]` создаёт его при достижении места построения. Поле структуры, хранящее ссылку на массив, не является самим массивом. Передача ссылки не копирует элементы; изменение элемента наблюдаемо через другие ссылки, перепривязка локальной ссылки — нет.

Владеющий массив имеет единый непрерывный прямоугольный блок элементов. Вложенные размерности не означают отдельно выделенные строки. Для формы `[d0, …, dN−1]` число элементов равно произведению размерностей, последний индекс меняется быстрее остальных. Массив ссылок на другие массивы — другое значение, не замена прямоугольного многомерного массива. Примитивные элементы не приобретают лексических родителей.

`shape(array)` возвращает размерности как целочисленный массив ранга 1 или структуру формы; `rank` — число размерностей; `length` при положительном ранге — первую размерность; `size` — общее число элементов. Число полей содержащей структуры, длина массива и размер служебного пула дескрипторов различаются.

Полный индекс массива ранга N содержит N целочисленных координат. В L3 доступ проверяет дескриптор массива и границы индекса; нарушение границ выражается отказом `Bounds`, а не значением `None`. Частичный индекс может дать представление (*view*), например первая строка `matrix[0]`; полный `matrix[0, 2]` выбирает элемент. Конкретная запись координат задаётся [грамматикой](LMX_grammar.ru.md), а не машинной индексацией C. Эти проверки принадлежат только L3: [доступ L2](L2_spec_ru.md#lowlevel-address), включая получение адреса элемента графового массива, работает без них. Проверки операции не являются отдельным механизмом допуска кандидата вместо [анализа и юнит-тестов](#admission).

View может разделять хранилище в пределах одного Message; копия имеет отдельное хранилище. `slice`, совместимый `reshape`, `transpose`, `permute`, `broadcast` и частичная индексация могут создавать view; `copy`/`clone`, материализация и обычный результат поэлементной арифметики создают копию, если не задан существующий выходной буфер. Конкретные представление view, удержание backing и правила изменяемого совместного доступа ещё не закреплены. Возврат ссылки не должен скрыто копировать данные для исправления времени жизни.

`reshape` сохраняет значения и общее число элементов; изменение числа требует явного контракта заполнения/усечения/копирования. Совместимое хранилище позволяет view, иначе необходима явно определённая материализация. `transpose` переставляет последние две оси при ранге не меньше двух либо следует выбранному матричному профилю. `permute(array, axes)` задаёт перестановку осей. Логические stride-данные операции не требуют дополнительных полей у каждого универсального дескриптора.
[EN]
An ordinary Array is a typed value with stable reference identity. Constructor `[]` creates it when execution reaches the construction site. A Structure field holding its reference is not the Array itself. Passing a reference does not copy elements; an element mutation is visible through other references, whereas rebinding a local reference is not.

An owning Array has one contiguous rectangular block of elements. Nested dimensions do not mean separately allocated rows. For shape `[d0, …, dN−1]`, element count is the product of dimensions, with the last index varying fastest. An Array of references to other Arrays is a different value, not a replacement for a rectangular multidimensional Array. Primitive elements acquire no lexical parents.

`shape(array)` returns dimensions as a rank-one integer Array or shape Structure; `rank` returns their count; `length` for positive rank returns the first dimension; `size` returns total element count. The containing Structure's field count, Array length and service descriptor-pool size are distinct.

A full rank-N index contains N integer coordinates. L3 access checks the Array descriptor and index bounds; an out-of-bounds access produces a `Bounds` failure, not `None`. A partial index may produce a view, such as first row `matrix[0]`; full `matrix[0, 2]` selects an element. Coordinate spelling belongs to the [grammar](LMX_grammar.en.md), not C machine indexing. These checks belong only to L3: [L2 access](L2_spec_en.md#lowlevel-address), including obtaining a graph-backed element's address, works without them. Operation checks do not constitute a separate candidate-admission mechanism in place of [analysis and unit tests](#admission).

A view can share backing within one Message; a copy has separate backing. `slice`, compatible `reshape`, `transpose`, `permute`, `broadcast` and partial indexing may create views; `copy`/`clone`, materialization and ordinary elementwise arithmetic results create copies unless an existing output buffer is selected. Concrete view representation, backing retention and mutable sharing rules remain unsettled. Returning a reference must not hide copying to repair lifetime.

`reshape` preserves values and total element count; changing the count requires an explicit fill/truncate/copy contract. Compatible storage permits a view; otherwise explicitly defined materialization is necessary. `transpose` exchanges the last two axes for rank at least two or follows the selected matrix profile. `permute(array, axes)` specifies an axis permutation. An operation's logical stride data need not add fields to every universal descriptor.

@@ array-operations | Операции над массивами | Array operations | 6.5.6–6.5.15
[RU]
Арифметика и сравнения массивов по умолчанию поэлементные. Операция над элементом определяется его числовым доменом и явно выбранным контекстом. `*` означает поэлементное умножение, не матричное. `matmul`, `dot`, `contract` и `outer` — отдельные выраженные операции; профильный символ матричного умножения не должен делать обычное `*` двусмысленным.

Broadcasting сопоставляет размерности справа. Пара допустима, если размеры равны, один равен 1 или одна сторона отсутствует и считается 1; результат по старому правилу берёт максимум. Примеры: `[3]` и скаляр дают `[3]`; `[2,3]` с `[3]` рассматривается как `[2,3]` с `[1,3]`; `[2,3]` с `[2,1]` дают `[2,3]`. Повторно читаемый скаляр не размножается в отдельный массив. Внутренний нулевой stride может выражать повторное чтение одного элемента. Случай нулевой размерности требует уточнения: буквальное правило максимума не определяет безопасное чтение из пустого входа.

`reduce` сворачивает элементы ассоциативной либо явно упорядоченной операцией. Без оси по умолчанию получается примитив; профиль может явно запросить массив ранга 0. С осью сворачивается только она. Контракт задаёт нейтральное значение, когда оно нужно, операцию элемента, тип результата и порядок. Для воспроизводимых вещественных/десятичных вычислений порядок не должен зависеть от случайного выбора backend.

`scan` — префиксная свёртка: включающий вариант суммы для `[1,2,3,4]` даёт `[1,3,6,10]`. Включающий или исключающий вариант выбирается явно. `map` применяет выражение к элементам; чистый вариант допускает векторизацию и параллельное вычисление с сохранением результата. Для эффектов необходим явный порядок; основной профиль предполагает чистое отображение.

`filter` отбирает элементы по логическому предикату и обычно материализует новый массив: выбранные позиции не обязаны образовывать регулярный view. `concat` соединяет по выбранной оси; остальные размерности должны совпадать. Его результат обычно новый массив с прямоугольным backing. Копирование, материализация и все результаты сохраняют границы владельца Message.

Минимальный исходный числовой профиль охватывает ранги 1/2, непрерывное хранилище, проверяемый индекс, форму, копирование, поэлементные `+ - * /`, broadcasting скаляра, операции равной формы и полную свёртку. Это минимальная реализационная цель, не отмена остальных контрактов. Точная поддержка текущего фронтенда проверяется в [L2](L2_spec_ru.md#lowlevel-array).
[EN]
Array arithmetic and comparisons are elementwise by default. Element operations follow their numeric domain and explicitly selected context. `*` means elementwise multiplication, not matrix multiplication. `matmul`, `dot`, `contract` and `outer` are separate explicit operations; a profile-specific matrix symbol must not make ordinary `*` ambiguous.

Broadcasting aligns dimensions from the right. A pair is admitted if equal, if one equals 1, or if one side is absent and treated as 1; the former rule chooses the maximum for the result. Examples: `[3]` and a scalar give `[3]`; `[2,3]` with `[3]` is treated as `[2,3]` with `[1,3]`; `[2,3]` with `[2,1]` gives `[2,3]`. A repeatedly read scalar is not expanded into another Array. Internal zero stride can represent repeated reads of one element. Zero extents require clarification: literal maximum does not define safe reads from an empty input.

`reduce` collapses elements with an associative or explicitly ordered operation. With no axis it returns a primitive by default; a profile may explicitly request a rank-zero Array. With an axis, only that axis is collapsed. The contract defines an identity where needed, element operation, result type and ordering. Reproducible real/decimal computations must not depend on an incidental backend choice of order.

`scan` is a prefix reduction: inclusive sum of `[1,2,3,4]` gives `[1,3,6,10]`. Inclusive or exclusive behavior is explicitly selected. `map` applies an expression to elements; a pure variant permits vectorization and parallel evaluation preserving the result. Effects need explicit ordering; the default profile expects pure mapping.

`filter` selects elements by a Boolean predicate and normally materializes a new Array: selected positions need not form a regular view. `concat` joins along the selected axis; other dimensions must match. Its result is normally a new Array with rectangular backing. Copies, materialization and all results retain Message ownership boundaries.

The original minimal numeric profile covers ranks 1/2, contiguous storage, checked indexing, shape, copying, elementwise `+ - * /`, scalar broadcasting, equal-shape operations and whole-array reduction. This is a minimal implementation target, not withdrawal of other contracts. Actual frontend coverage is checked in [L2](L2_spec_en.md#lowlevel-array).

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

Копируется полный используемый граф с необходимыми ссылками и лексическими цепочками до нулевого родителя. Одна карта «источник — копия» используется для всех операндов: общие цели остаются общими, циклы сохраняются, ссылки и `node` явно переписываются. Корни операндов и необходимые лексические предки не добавляются лишними видимыми полями результата. Лексический родитель нового корня определяется местом выражения `merge`.

Ссылки на общие методы и допущенные [вечные ветви](#eternal) являются терминалами соответствующих контрактов: они сохраняют адрес и не копируют код или содержимое ветви. Остальное изменяемое использованное состояние получает отдельное хранилище. Алгоритм не ограничивается копией указателей прямых полей и не оставляет ссылки на изменяемую чужую арену.

Одноимённые поля сохраняют прямой порядок: первая `read` остаётся `read`/`[0]read`, следующая — `[1]read`. Более поздний операнд не переопределяет первый автоматически. Для другого выбора нужно явно выбрать вхождение или построить нужный результат. Успешная композиция публикует полностью инициализированный результат, не требует регистрации коротких имён и не меняет источники.

Неуспех использует объявленный путь `throws merge(args)`, а не отдельный придуманный протокол частичного результата. Это не обещание отката побочных эффектов вычисления операндов. Правила освобождения временного хранилища принадлежат владельцу Message. Точный низкоуровневый механизм — [L2](L2_spec_ru.md#copy-merge).

Описание типа, схема, импортные данные или таблица являются обычными данными: применение к ним `merge` не выбирает особый алгоритм композиции дескрипторов. `table` материализует явно выбранное табличное представление; `join` создаёт новый табличный граф, не меняя операнды. Политики строк, ключей, конфликтов и приоритета задаёт табличная операция, не структурное правило поиска поля.

Передача владения уже существующим хранилищем при доставке Message — [другая операция](#delivery), без копирования и без переподчинения `node`. Сочетание политик допуска — также не `merge`: оно выбирает и проверяет явно переданные данные, не строит структурную копию по умолчанию.
[EN]
`merge` is an executable operation over live structural operands. It is neither a preprocessor include, C-type composition nor mutation of source values. Operands are evaluated once left-to-right; a fresh root is then built with direct fields in operand and appended-body order. A previous `merge` result can itself be an operand.

The complete used graph is copied with required references and lexical chains to a zero parent. One source-to-copy map spans all operands: shared targets remain shared, cycles are preserved, and references and `node` links are explicitly rewritten. Operand roots and necessary lexical ancestors do not become extra visible result fields. The new root's lexical parent follows the `merge` expression's location.

Shared methods and admitted [eternal branches](#eternal) are terminals under their respective contracts: they retain their addresses without copying code or branch contents. Other used mutable state receives distinct storage. The algorithm is not merely a direct-field pointer copy and does not leave references into another mutable arena.

Repeated fields retain forward order: the first `read` remains `read`/`[0]read`, the next is `[1]read`. A later operand does not automatically override the first. Different selection requires choosing an occurrence explicitly or constructing the intended result. Successful composition publishes a fully initialized result, requires no short-name registration and leaves sources unchanged.

Failure follows declared `throws merge(args)`, not an invented partial-result protocol. This does not promise rollback of operand-evaluation effects. Temporary-storage release follows the owning Message's rules. The exact low-level mechanism is in [L2](L2_spec_en.md#copy-merge).

A type description, schema, import data or Table is ordinary data: applying `merge` does not select a special descriptor-composition algorithm. `table` materializes an explicitly selected table representation; `join` creates a new table graph without mutating operands. Row, key, conflict and priority policies belong to the table operation, not structural field lookup.

Ownership transfer of existing storage during Message delivery is a [different operation](#delivery), without copying or reparenting `node`. Admission-policy combination is likewise not `merge`: it selects and checks explicit data without default structural copying.

@@ registries | Таблицы, запросы, импорт и провайдеры | Tables, queries, imports and providers | 19.18; 19.21–19.27; 19.30
[RU]
Registry, Table, RegistryView, схема и политика — роли обычных значений, не дополнительные категории и не скрытые пространства имён. Каждая операция получает корень реестра явно либо достигает его по выраженной ссылке. Само существование таблицы не включает поиск в ней; строка с ключом `class`, `type`, `provides` или `satisfies` не меняет смысл языка.

В табличном профиле первый столбец задаёт ключ строки. `columns` содержит имена и при необходимости выраженные метаданные; число ячеек плотного набора строк должно делиться на число столбцов, отсутствующие ячейки выражаются явно. Выравнивание текста не добавляет полей. Необязательное `source` обозначает запрос проекции профиля транслятора, не объявляет имена из ячеек как runtime-привязки.

Ячейка может ссылаться на данные, другой ключ, описание, политику, диагностику, свидетельство, провайдер или вызываемое выражение. Текстовый динамический поиск начинается с переданного корня и использует имена его упорядоченных детей. Он не заменяет разрешённые структурные ссылки и не делает таблицу глобальной средой выполнения. Сохранённый результат проверки остаётся данными с явными зависимостями, не бессрочным разрешением будущих вызовов.

Процедурное потребление вызывает выбранное выражение; объектное/событийное передаёт явную цель и состояние; функциональное следует ссылкам операций; логическое строит результаты и сообщения из явных входов. Правила, переменные запроса, унификация и продолжения представлены данными соответствующего графа. Результат запроса не публикует неявно новые имена для других выражений.

Реактивное обновление может создавать события, которые являются сообщениями. Агент может предложить строку или Message; каждый кандидат проходит [единый допуск](#admission). Явная политика ранжирует допущенные варианты, а отдельная операция публикует выбранный результат. Ни успешный тест, ни выбор лучшего варианта сами по себе не обновляют реестр.

Импорт связывает явно выбранные операции и рецепты построения. Он не сканирует произвольный каталог, не создаёт все экземпляры и не копирует runtime-namespace. Провайдер, кодек и правило понижения выбираются через импорт, ссылку, конфигурацию либо переданную таблицу. План исполнения удерживает выбранную ссылку; смена провайдера — явное действие, не последствие скрытого глобального поиска.

`toLmx`/`fromLmx`, если предоставлены профилем, задают операции кодека с явной политикой. Переносимое сохранение выражает содержимое и идентичности согласно кодеку, не образ памяти с нативными адресами, состоянием аллокатора и внешними дескрипторами. Последние требуют отдельных политик внешних ресурсов.

### Ключи и ячейки

Следующие исходные примеры описывают необязательный табличный профиль. Ключи `Circle` и `int` в первой таблице — данные, не объявления. Во второй таблице строковые значения описывают целевое написание; получение `"uint8_t"` по ключам `u8` и `spelling` не меняет семантику исходного типа.

{{l1:11281-11287}}

{{l1:11302-11309}}

Операторная ячейка может прямо содержать ключ реализации. Например, из следующей таблицы выбирается `u32_eq` для соответствующей пары; `None` — установленный этим профилем маркер отсутствия ячейки, не числовой 0.

{{l1:11251-11257}}

### Отношения, импорт и запрос

Одно отношение можно представить матрицей пар типов или сгруппировать вокруг одного операнда. Это разные представления явных данных, не скрытая регистрация перегрузок. Условные обозначения разреженных ячеек принадлежат выбранному табличному профилю.

{{l1:11322-11327}}

{{l1:11331-11336}}

Потребитель таблицы может задать порядок импорта и численные приоритеты. Политика конфликтующих строк относится к этому потребителю, не переопределяет правило первого структурного вхождения. Построение реестра и запрос остаются отдельными операциями.

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

Import links explicitly selected operations and construction recipes. It neither scans arbitrary directories, constructs every instance nor copies a runtime namespace. Providers, codecs and lowering rules are selected through imports, references, configuration or supplied Tables. An execution plan retains the chosen reference; changing providers is explicit, not the result of hidden global lookup.

`toLmx`/`fromLmx`, when provided by a profile, specify codec operations with explicit policy. Portable persistence represents content and identities under the codec, not a memory image of native addresses, allocator state and foreign descriptors. The latter require separate external-resource policies.

### Keys and cells

The following source examples describe an optional table profile. Keys `Circle` and `int` in the first Table are data, not declarations. String values in the second describe target spellings; obtaining `"uint8_t"` through `u8` and `spelling` does not change the source type's semantics.

{{l1:11281-11287}}

{{l1:11302-11309}}

An operator cell can directly hold an implementation key. For example, the following Table selects `u32_eq` for the corresponding pair; `None` is this profile's missing-cell marker, not numeric 0.

{{l1:11251-11257}}

### Relations, import and queries

One relation can be represented as a matrix of type pairs or organized around one operand. These are different views of explicit data, not hidden overload registration. Sparse-cell notation belongs to the selected table profile.

{{l1:11322-11327}}

{{l1:11331-11336}}

A table consumer may define import order and numeric priorities. Conflicting-row policy belongs to that consumer and does not override first-occurrence structural lookup. Registry construction and querying remain separate operations.

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

Лексическая вложенность, владение памятью и достижимость — разные отношения. В одной арене может быть несколько лексических деревьев. При передаче владения блоками их адреса и `node` сохраняются; новый владелец не становится автоматически лексическим родителем и не получает неявную прикладную ссылку на каждый принятый объект.

Живость определяется достижимостью, не членством в списке блоков. Корни включают корень Message, активные структурные аргументы, удерживаемые собственные поля, результаты, ссылки формальных и динамических входов, продолжения и явно сохранённые прикладные/служебные ссылки. Обход следует типизированным рёбрам графа, необходимым родителям, связи массива с backing и ссылочным элементам. Вспомогательный индекс имён не является корнем.

Живые узлы и дескрипторы не перемещаются. Рост добавляет хранилище, не инвалидируя опубликованные ссылки. Лексический выход не уничтожает достижимый возвращённый объект; возврат не требует скрытого копирования или «продвижения» дерева. Стабильный адрес, однако, не гарантирует вечную жизнь недостижимого объекта.

В конце каждого такта выполняется один локальный проход сбора: определить исход такта, опубликовать успешные исходящие сообщения либо отбросить неуспешную подготовку, отпустить завершённые входные/временные корни, собрать арену владельца. Обычный возврат, `break`, `continue`, `retry`, `redo` и пойманный `throw` не являются отдельными точками сбора. Сохранившееся приостановленное продолжение удерживает свои ссылки.

Принятый граф, на который приложение не сохранило ссылок, после снятия временных корней может быть собран уже в конце такта. Передача арены не превращает его в вечный корень. Удерживаемая история отказа живёт по своей явной политике. Уничтожение Message в итоге освобождает его оставшееся хранилище; сбор не обходит чужую изменяемую арену и не требует глобальной блокировки.

Внешний ресурс имеет отдельный контракт владения, удержания, освобождения и передачи. `copy`, сериализация и `merge` не придумывают дублирование нативного ресурса. Неизменяемость его идентификатора не продлевает жизнь ресурса. Физический сборщик, типизированные пулы и регистрация областей описаны в [L2](L2_spec_ru.md#arena) и [L1](L1_spec_ru.md#arena).
[EN]
Every Message, executing or not, owns one logical arena of mutable data. It can contain multiple disjoint regions; these are not additional source-level arenas. Calls, blocks, handlers, branches and retries do not create their own semantic arenas. L3 does not select an arena through an operation argument.

Lexical nesting, storage ownership and reachability are distinct relationships. One arena may contain multiple lexical trees. Transferring block ownership preserves addresses and `node`; the new owner neither becomes the lexical parent automatically nor gains an implicit application reference to every adopted object.

Liveness follows reachability, not block-list membership. Roots include the Message root, active structural arguments, retained own fields, results, formal/dynamic input references, continuations and explicitly retained application/service references. Tracing follows typed graph edges, necessary parents, Array-to-backing links and reference-valued elements. The auxiliary name index is not a root.

Live nodes and descriptors do not move. Growth adds storage without invalidating published references. Lexical exit does not destroy a reachable returned object; return requires no hidden copy or tree promotion. A stable address, however, does not guarantee indefinite life for an unreachable object.

One local collection pass runs at each end-of-turn: determine the outcome, publish successful outgoing Messages or discard failed staging, release completed input/temporary roots, and collect the owner's arena. Ordinary return, `break`, `continue`, `retry`, `redo` and caught `throw` are not separate collection points. A surviving suspended continuation retains its references.

An adopted graph with no application-retained references can be collected at end-of-turn once temporary roots are released. Arena transfer does not make it a permanent root. Retained failure history lives under its explicit policy. Destroying a Message ultimately releases its remaining storage; collection neither scans another mutable arena nor requires a global lock.

A foreign resource has a separate ownership, retention, release and transfer contract. `copy`, serialization and `merge` do not invent native-resource duplication. Immutability of its identifier does not extend resource lifetime. The physical collector, typed pools and region registration are described in [L2](L2_spec_en.md#arena) and [L1](L1_spec_en.md#arena).

@@ eternal | Вечные ветви и общие методы | Eternal branches and shared methods | 9.1.4; 19.29.6; 19.29.9
[RU]
Совместная квалификация `independent: const: immutable` задаёт вечную ветвь: её корень не имеет внешнего лексического родителя, содержимое и защищённые привязки неизменяемы, срок хранения — до завершения процесса. Одна из квалификаций отдельно не даёт этого контракта общего использования.

Первый, корневой Message процесса удерживает все такие ветви всех Message в фиксированном неизменяемом массиве ссылок. Множество ветвей известно трансляции; массив не пополняется при каждом `merge` или создании Message. Размещение ссылки в этом массиве не переподчиняет лексическое дерево ветви. Допустимая инициализация значениями времени выполнения происходит до публикации и не увеличивает множество записей.

Второй отдельный фиксированный массив того же владельца содержит известные записи методов. Метод не хранит лексического родителя; его конкретное вызываемое вхождение предоставляет собственную структуру. Разделяемые записи остаются живы после завершения заимствующего дочернего Message. Это хранилище корневого Message, не бесхозный глобальный реестр.

`merge` и создание Message сохраняют явно переданные ссылки на допущенные вечные ветви и записи методов как терминалы. Получение одной ветви не раскрывает массив удержания, настройки корня или остальные ветви. Изменяемое состояние по-прежнему копируется отдельно. Все ссылки внутри опубликованной вечной ветви должны иметь достаточный срок жизни; квалификация не делает случайную ссылку на освобождаемую память вечной.

Например, A и созданный из его шаблона B могут иметь один адрес вечной E и разные ячейки изменяемого x. Завершение A и B не освобождает E. Одинаковое содержимое двух отдельно построенных ветвей не означает их автоматического интернирования. При переносе в другой процесс нативный адрес не становится сетевой идентичностью: нужен явный кодек.
[EN]
Combined qualification `independent: const: immutable` establishes an eternal branch: its root has no external lexical parent, contents and protected bindings are immutable, and storage lasts until process termination. Any one qualification alone does not establish this sharing contract.

The process's first, root Message retains all such branches from all Messages in a fixed immutable reference Array. The branch set is translation-known; `merge` and Message creation do not append entries. Placement in the retention Array does not reparent a branch's lexical tree. Permitted runtime-value initialization occurs before publication without increasing the entry set.

A second separate fixed Array owned by the same Message contains known method records. A method stores no lexical parent; its concrete callable occurrence supplies its own Structure. Shared records remain live after a borrowing child Message terminates. This is root-Message-owned storage, not an ownerless global registry.

`merge` and Message creation retain explicitly supplied references to admitted eternal branches and method records as terminals. Receiving one branch does not expose its retention Array, root settings or unrelated branches. Mutable state is still copied separately. Every reference within a published eternal branch must have sufficient lifetime; qualification does not make an arbitrary reference to reclaimable storage eternal.

For example, A and B constructed from A's template can have the same eternal E address and distinct mutable x cells. Finishing A and B does not release E. Equal contents of separately constructed branches do not imply automatic interning. Across processes a native address is not wire identity: an explicit codec is required.

@@ messages | Message, актор и последовательный такт | Message, actor and serial turn | 19.28.R2.1–19.28.R2.3; 19.29.6
[RU]
Message — изолированный граф с собственным владением. Шаблон и письмо не обязаны исполняться. L3 Thread — Message с механизмом исполнения тактов и приёма других Message; каждый L3 Thread является Message, но не наоборот. Получение письма не создаёт автоматически новый поток или актор. Для запуска отдельного ребёнка нужна явная операция.

Исполняющийся Message имеет FIFO-почту и не более одного активного такта одновременно. За такт потребляется не более одного допущенного входа. Между разными Message возможна параллельность. Пустой ящик не означает завершение фоновой задачи: механизм продолжает проверять почту согласно своему режиму исполнения до условия остановки.

Одна арена имеет одну полосу записи. Обработчик, локальное управление, планировщик и служебные данные Message изменяются на его полосе. Чужой отправитель не дописывает себя в ready-list владельца и не меняет его прикладные данные. Исключение приёма почты и специальные одноячеечные протоколы управления относятся к механизму Message, не дают общего доступа к чужой памяти.

Родитель управляет только своими непосредственными детьми и хранит их список и политику планирования у себя. Ребёнок аналогично управляет своими детьми. Нет отдельного глобального планировщика языка, общего изменяемого реестра Message или глобальной блокировки управления. Маршрутизатор, если нужен, сам является Message с собственным состоянием.

L3 Thread — логическая последовательная полоса, не обещание отдельного потока ОС. Возможны собственный поток и выполнение тактов родителем/платформенным адаптером. API и политика отображения задаются реализацией L2; это не разрешает одновременно выполнять два такта одного владельца. Опрос жизнеспособности родителя и собственное обслуживание нужны и актору без детей.

Первоначальный граф процесса принадлежит корневому Message. Начальные настройки и пользовательский ввод поступают при входе, последующая координация выполняется сообщениями. Группировка ролей Mix, курсоров, страниц и уведомлений по Message остаётся выбором проектирования: не требуется ни один актор на весь документ, ни отдельный актор на каждую ячейку.
[EN]
A Message is an isolated graph with its own ownership. A template or letter need not execute. An L3 Thread is a Message with turn execution and reception of other Messages; every L3 Thread is a Message, but not conversely. Receiving a letter does not automatically create a thread or actor. Launching a separate child requires an explicit operation.

An executing Message has FIFO mail and at most one active turn at a time. A turn consumes at most one admitted input. Different Messages may execute concurrently. An empty mailbox does not finish a background task: its mechanism keeps checking mail according to its execution mode until a stopping condition.

One arena has one writing lane. A Message's handler, local management, scheduler and service state are mutated on its own lane. A foreign sender neither appends itself to the owner's ready list nor modifies its application data. Mail admission and designated single-cell control protocols belong to the Message mechanism and grant no general access to foreign memory.

A parent manages only its direct children, retaining their list and scheduling policy locally. Each child likewise manages its own children. There is no separate global language scheduler, shared mutable Message registry or global management lock. A router, if needed, is itself a Message with private state.

An L3 Thread is a logical serial lane, not a promise of a dedicated OS thread. Both a dedicated thread and parent/platform-driven turns are possible. L2 implementation defines the API and mapping policy; this does not permit two simultaneous turns of one owner. Parent-liveness polling and self-maintenance are needed even by a childless actor.

The process's initial graph belongs to the root Message. Initial settings and user input arrive at entry; subsequent coordination uses Messages. Grouping Mix roles, cursors, pages and notifications into Messages remains a design choice: neither one actor for the whole document nor a separate actor for every cell is required.

@@ delivery | Доставка, владение и порядок изменений | Delivery, ownership and mutation order | 19.19; 19.28.R2.4–19.28.R2.5; 19.29.6–19.29.7
[RU]
Локальный промежуточный уровень адресует участников физическими адресами памяти в рамках допускаемых операций механизма Message. Иерархическая цепочка индексов относится к [WorldWideMix](#worldwide), начиная с третьего масштаба организации, а не к каждому локальному письму. Масштаб организации не следует смешивать с профилем языка L3. Нативный адрес не сериализуется как переносимый адрес другой машины.

Доставка существующего неисполняющегося Message может передавать владение его хранилищем получателю без перемещения данных. Блоки и классификация областей переходят в единую арену получателя, бывший владелец больше не освобождает их. Лексические связи остаются прежними; прикладное включение принятого корня выполняется явно. Передача хранилища не равна созданию копии и не сохраняет отправленный объект как второго независимого владельца.

Создание нового исполняющегося Message из шаблона использует [копирование графа](#composition) и его отдельную арену. Обычные настройки копируются, допущенные вечные ссылки сохраняются. Создание не импортирует неявно всё живое окружение родителя. Передача надзора над работающим ребёнком, передача остановленного хранилища и сериализация удалённого сообщения — три разных контракта.

Одновременные поступления не имеют заранее заданного относительного порядка. Приём в ящик устанавливает FIFO-порядок, который сохраняется при потреблении. Ни случайное перемешивание, ни порядок по часам отправителей не являются правилом. Проверка пустоты и ожидание согласованы с приёмом: уже принятое письмо не должно потеряться при переходе получателя в ожидание. Вместимость, обратное давление и повторная доставка — явные политики реализации/протокола.

Несколько отправителей изменяют один объект, посылая полную операцию владельцу. Например, `add(2)` и `add(5)` при начальном 0 дают 7 в любом из двух порядков приёма. Раздельные `read` и `write` не образуют одной защищённой операции: два отправителя могут прочесть 10 и оба записать 11. Последовательные такты предотвращают перекрытие исполнения, не создают транзакционный откат или защиту разорванного протокола.

Успех доставки означает принятие, не выполнение прикладного изменения. Для результата нужна предусмотренная протоколом корреляция ответа. Ядро не добавляет автоматически историю последних идентификаторов и подавление повторов каждого отправителя. Требования дедупликации, повторов, пакетирования и сортировки выражаются отдельным протоколом, не меняющим базовый FIFO.

Исходящие письма текущего такта подготавливаются отдельно от опубликованной очереди. Успешная граница публикует их в порядке подготовки; неуспешная отбрасывает неопубликованное. Уже выполненные изменения графа этим не откатываются. Граница [сбора](#memory) наступает после обработки результата и временных корней.
[EN]
The local intermediate organization level addresses participants by physical memory addresses within admitted Message-mechanism operations. Hierarchical index chains belong to [WorldWideMix](#worldwide), starting at the third organization scale, not to every local letter. Organization scale must not be confused with language profile L3. A native address is not serialized as a portable address on another machine.

Delivery of an existing non-executing Message can transfer its storage ownership to the receiver without moving data. Blocks and region classification join the receiver's single arena; the former owner no longer releases them. Lexical links remain unchanged; application attachment of the received root is explicit. Storage transfer is not copying and does not retain the sent object as a second independent owner.

Creating a new executing Message from a template uses [graph copying](#composition) and a separate arena. Ordinary settings are copied; admitted eternal references are retained. Creation does not implicitly import the parent's entire live context. Handing off supervision of a running child, transferring stopped storage and serializing a remote Message are three different contracts.

Concurrent arrivals have no predetermined relative order. Mailbox admission establishes FIFO order, preserved by consumption. Neither random shuffling nor sender-clock order is required. Empty-check/wait coordinates with admission: an accepted letter must not disappear as the receiver begins waiting. Capacity, backpressure and redelivery are explicit implementation/protocol policies.

Multiple senders mutate one object by sending its owner a complete operation. For example, `add(2)` and `add(5)` from initial 0 produce 7 in either admission order. Separate `read` and `write` requests are not one protected operation: two senders may both read 10 and write 11. Serial turns prevent overlapping execution but establish neither transaction rollback nor protection for a split protocol.

Delivery success means admission, not application of a requested change. A result requires protocol-defined reply correlation. The core does not automatically retain per-sender last identifiers or suppress duplicates. Deduplication, retry, batching and sorting requirements belong to explicit protocols without changing base FIFO.

Current-turn outgoing letters are staged separately from the published queue. A successful boundary publishes them in staging order; failure discards unpublished staging. This does not undo graph mutations already performed. The [collection boundary](#memory) follows outcome and temporary-root processing.

@@ lifecycle | Завершение, дети и сохранение результата отказа | Completion, children and retained failure state | 19.28.R2.2–3; 19.29.6–19.29.8
[RU]
`success` означает фактическое завершение назначенной работы, не пустой ящик и не успешную доставку отдельного письма. После его установки основной алгоритм Message не получает следующий такт; завершение локального обслуживания детей зависит от реализации. `running = 0` во время работы может быть запросом остановки: физическая безопасность передачи хранилища устанавливается отдельным протоколом, не угадывается по одному флагу.

Ребёнок проверяет жизнеспособность родителя и после длительного отсутствия ответа начинает собственное упорядоченное закрытие. Принудительное закрытие сверху — аварийный второй путь. Родитель обслуживает своих прямых детей, не выполняет произвольное управление внуками. Закрытие распространяется по семейству, а не сохраняет навсегда освобождённую ветвь.

Работающий ребёнок может пережить закрытие родителя только при явной передаче надзора другому живому родителю с подходящим полномочием. Он сохраняет свою арену, почту и такт; меняется надзор и место в планировании. Это не усыновление памяти. При передаче памяти неисполняющийся источник прекращает отдельную жизнь; новые дети из принятого содержимого принадлежат уже получателю.

Неуспешное остановленное состояние может быть передано родителю без копии и удержано как граф истории отказа; успешная история по умолчанию освобождается. Передача требует остановленного, безопасного для передачи состояния и отсутствия нативных пользователей. Необходимо сохранять различие запроса остановки, фактического выхода, безопасной передачи и освобождения; конкретные флаги и их размещение относятся к [ядру L2](L2_spec_ru.md#message).

Оставшийся без родителя участник закрывается по политике сирот: успешное завершение освобождает его, неуспешная история может сохраняться до явно заданного срока. Прежняя реализация содержит подробности промежуточного host/root-перехода; они не устанавливают второй глобальный реестр или отдельного бессрочного владельца вне Message. Детальные состояния и нынешние ограничения переноса фиксируются в [описании потока](L2_spec_ru.md#thread), не подменяют изоляцию L3.
[EN]
`success` means actual completion of assigned work, not an empty mailbox or delivery of one letter. Once set, the Message's main algorithm receives no next turn; finishing local child maintenance depends on implementation. `running = 0` during execution may be a stop request: physical storage-handoff safety is established by a separate protocol, not inferred from one flag.

A child checks parent liveness and begins its own orderly close after sustained lack of response. Forced closure from above is the second, emergency path. A parent services its direct children rather than arbitrarily managing grandchildren. Closing propagates through the family instead of retaining a released branch forever.

A running child can survive parent closure only through explicit supervision handoff to another live parent with suitable authority. It retains its arena, mail and turn; supervision and scheduling placement change. This is not storage adoption. Storage transfer ends the non-executing source's separate life; new children created from adopted content belong to the receiver.

Stopped failed state may be transferred to the parent without copying and retained as failure-history graph; successful history is reclaimed by default. Transfer requires a stopped, handoff-safe source with no native users. Stop request, actual exit, safe transfer and release must remain distinct; concrete flags and placement belong to the [L2 kernel](L2_spec_en.md#message).

A participant that loses its parent closes under an orphan policy: successful completion releases it, while failure history may remain until an explicit deadline. The old implementation includes intermediate host/root-transition details; these establish neither a second global registry nor an indefinite owner outside Messages. Detailed states and current migration limits belong in the [thread description](L2_spec_en.md#thread), without replacing L3 isolation.

@@ pipeline | Допуск и исполнение входящего сообщения | Incoming-message admission and execution | 19.19; 19.22; 19.28.R2.4; 19.31
[RU]
Входящие данные проходят явный декодер и становятся графом Message. Затем выбираются адресат, маршрут и принимающее выражение через заданные ссылки или поиск от заданного корня. Ни текст сообщения, ни ссылка на таблицу не устанавливают скрытое окружение и не дают автоматического доверия.

Допуск кандидата имеет только [единый механизм](#admission): аналитический обход используемого дерева, затем юнит-тесты принимающего выражения, исполняемые интерпретатором графа. Декодирование текста строит входной граф до этого этапа; интерпретатор тестов не интерпретирует исходный текст вместо графа. Прежние отдельные валидаторы, `RuntimeImplements` и свидетельства не являются альтернативными путями допуска.

Маршрут, полномочия, срок жизни и допустимые эффекты представлены явными данными контракта. Проверки свойств кандидата включаются в тесты принимающего выражения; криптографические операции могут предоставить проверяемые факты. Свидетельство хранит ссылку на конкретные данные, политику и установленные на входе факты, но не становится обходом обязательной проверки. Правила повторного использования результатов ещё не установлены.

После допуска выбирается явная ссылка на реализацию/провайдер и строится план исполнения с аргументами, результатами и необходимыми политиками. Формирование плана не исполняет выбранную прикладную операцию, хотя этап допуска уже исполнял её тесты. Исполнитель следует зафиксированной ссылке. Результат или объявленный отказ становится входом следующего явного потребителя.

Логический генератор может построить ноль или несколько предложенных Message. Каждый снова проходит тот же путь; происхождение от генератора не даёт доверия. Полученный текст не переносит работающий кадр чужого актора. Работа выполняется в последовательном такте получателя, если отдельный запуск ребёнка не указан явно.
[EN]
Incoming data pass through an explicit decoder to become a Message graph. The destination, route and receiving expression are then selected through supplied references or lookup from a supplied root. Neither Message text nor a Table reference installs a hidden environment or grants automatic trust.

Candidate admission uses only the [unified mechanism](#admission): analytical traversal of the used tree, followed by receiving-expression unit tests executed by the graph interpreter. Text decoding constructs the input graph before this stage; the test interpreter does not interpret source text instead of the graph. Former independent validators, `RuntimeImplements` and evidence are not alternative admission routes.

Routes, authority, lifetime and permitted effects are explicit contract data. Candidate-property checks belong to receiving-expression tests; cryptographic operations may supply verifiable facts. Evidence references exact data, policy and authenticated ingress facts, but does not bypass mandatory checking. Result-reuse rules remain unsettled.

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

Три роли Mix различаются: слой исходных меток, дерево размещения документа и исполнение взаимодействующих Message. Интервал, ячейка размещения и Message не соответствуют друг другу один к одному. Изменение документа, уведомления и курсоры должны соблюдать владельцев и FIFO, а не наследовать блокировки и callbacks прежней Java-реализации как норму L3.
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

Mix has three distinct roles: source-mark overlay, document placement tree and cooperating-Message execution. An interval, placement cell and Message do not correspond one-to-one. Document updates, notifications and cursors must follow ownership and FIFO rather than inherit the former Java implementation's locks and callbacks as L3 rules.

@@ worldwide | WorldWideMix: адреса, ячейки и навигация | WorldWideMix: addresses, cells and navigation | 19.28.10.1–19.28.10.10; 19.28.10.13–15
[RU]
WorldWideMix задаёт дерево размещения: где находится ячейка. Граф LMX задаёт значение: какие поля оно имеет и что потребляет выражение. Эти деревья встречаются в ячейке, но не совпадают: адрес `3.17.4` не является полевым путём `file\close`, а `implements` не нумерует соседей Mix.

Адрес — последовательность неотрицательных целых от корня до ячейки. Глубина отдельной ветви и величина индекса не имеют установленного языком конечного потолка; реализация обязана проверять реальные ресурсные пределы, не переполнять представление. Ведущие нули текстовой формы значения не меняют: `03.17` и `3.17` равны. Префикс адресует поддерево, сокращение пути ведёт к предку.

Числа считают соседние позиции, не байты. Размер ячейки может соответствовать слову, буферу или ссылке на значение. Varint, цепочка полей разной ширины и другие кодеки — способы хранения одних чисел, не различные типы адреса. Переход с 5 на 12 бит не переименовывает `3.17`. Примеры десятков соседей в памяти и большего числа в секторе диска иллюстрируют носитель, не ограничивают адресную модель.

Ветви могут иметь разную глубину. Для префикса P группа `bunch(P)` содержит только занятые непосредственные индексы. Если заняты `{0,4,5}`, то после `P.4` идёт `P.5`, перед ним — `P.0`. `next`/`prev` не спускаются в детей, не поднимаются к родителю и не обходят все документы мира. `down`/`up` меняют глубину; `next`/`prev` меняют последний индекс внутри одной группы.

Курсор — путь плюс позиция внутри буферной ячейки, если она нужна. Вставка/удаление затрагивает соответствующий уровень соседей, не переадресует «все последующие байты файла». Документ — корень, дерево размещения и слой меток; файл является одним способом сериализации страниц. Человеческое имя, realm, том и глава — атрибуты и соглашения профиля, не DNS и не фиксированное число уровней.

Носителем может быть память, диск, провод, радио или переносимое хранилище; Интернет и HTTP не обязательны. Сообщение может передать короткий адрес, полномочие и сведения о потребителе вместо полного большого тела. Потребитель читает нужные части курсором. Тип содержимого устанавливается по значению LMX и [допуску](#admission), не по Mix-адресу, MIME или расширению файла.

Mix-слой размещает на тех же позициях пересекающиеся метки, курсоры, атрибуты и интервалы. Составление значения страницы использует обычный [merge](#composition) с первым `[0]`-вхождением, не переопределение соседних адресов. Заполнение диска не даёт права автоматически вытеснить данные к произвольному соседу: отказ, уплотнение или явно разрешённое зеркало задаются профилем хранения.
[EN]
WorldWideMix defines a placement tree: where a cell is situated. The LMX graph defines a value: its fields and what an expression consumes. These trees meet in a cell but are not identical: address `3.17.4` is not field path `file\close`, and `implements` does not number Mix neighbours.

An address is a sequence of nonnegative integers from root to cell. Neither an individual branch's depth nor index magnitude has a language-defined finite ceiling; implementations must check actual resource limits rather than overflow their representation. Leading textual zeros do not change meaning: `03.17` equals `3.17`. A prefix addresses a subtree; shortening the path reaches an ancestor.

The numbers count neighbouring positions, not bytes. A cell may hold a word, buffer or value reference. Varints, mixed-width fields and other codecs store the same integers rather than defining different address types. Changing storage from 5 to 12 bits does not rename `3.17`. Examples of tens of RAM neighbours and larger disk-sector occupancy illustrate carriers, not address-model limits.

Branches may have different depths. For prefix P, `bunch(P)` contains only occupied direct indices. If `{0,4,5}` are occupied, `P.4` is followed by `P.5` and preceded by `P.0`. `next`/`prev` neither descend, ascend nor traverse every document worldwide. `down`/`up` change depth; `next`/`prev` change the last index within one bunch.

A cursor is a path plus a buffer-cell position when needed. Insertion/deletion affects the relevant sibling level rather than readdressing every subsequent file byte. A document is a root, placement tree and mark overlay; a file is one way to serialize pages. Human names, realms, volumes and chapters are attributes/profile conventions, not DNS or a fixed number of levels.

Carriers can be RAM, disk, wire, radio or removable storage; Internet and HTTP are optional. A Message may carry a short address, authority and consumer information instead of an entire large body. The consumer reads needed parts by cursor. Content typing follows the LMX value and [admission](#admission), not its Mix address, MIME or filename extension.

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

Декларативное правило маршрутизации ниже является данными профиля, не обещанием реализации такого вложенного `send` оператором L2. Отдельное принимающее выражение должно интерпретировать условие и создать доставляемое сообщение.

{{l1:11263-11270}}
[EN]
HTTP/REST LMX is a transport profile, not the execution core or WorldWideMix. A service is a set of cooperating Messages, not a shared mutable heap. An external request becomes a Message, then undergoes [intake and admission](#pipeline), execution and result-to-transport mapping.

An HTTP target combines normalized endpoint and route. Example: endpoint `https://archive.example.org` with route `/inbox/save`. The receiver resolves the local route in an explicit Table. A route neither names an OS worker, exposes a raw Thread handle nor grants authority by itself.

The original profile posts a complete LMX document with `application/lmx`. A provider receives the URI and exact bytes, returning transport failure or admission status. Substituting a test provider, WinHTTP, libcurl or another adapter does not change Message semantics. No universal process-wide HTTP singleton follows.

A synchronous profile may return the semantic reply in the HTTP response; an asynchronous one may acknowledge admission and later send a Message to `replyTo`. The semantic reply carries `correlation` matching request `id`. Admission, execution and application success remain distinct events.

Instead of a large body, an explicit cursor with range and reading mode may be supplied. Its address, authority and lifetime belong to the receiving expression's contract. Reading compressed content, decryption and format migration are explicit operations; a supplied `targetDescriptor` remains ordinary data rather than a hidden descriptor on every value.

The source external-body example supplies a segment reference, range and reading mode. Cursor authority and lifetime are checked by the receiving expression's unit tests; a short envelope does not waive admission of the data subsequently read.

{{l1:11469-11483}}

The declarative routing rule below is profile data, not a promise that the L2 statement implements this nested `send` form. A separate receiving expression must interpret the condition and construct the delivered Message.

{{l1:11263-11270}}

@@ authentication | Идентификация, полномочия и свидетельства | Authentication, authority and evidence | 19.32.1–19.32.9; 19.32.18
[RU]
Учётные данные, verifier, полномочия и свидетельства — явные значения в потоке сообщений, не глобальная иерархия ролей. Защищённый verifier позволяет проверить первичный credential без хранения его исходного секрета. Результат криптографической операции — факт для политики, не автоматическое право на все действия.

Модуль, сервис, архив, каталог или административная операция могут иметь отдельную область verifier. Контракт может требовать один verifier, несколько для одного пользователя либо кворум пользователей/сессий. Родство создателя и ребёнка задаёт управление жизнью, не право чтения содержимого. Сброс verifier доступа не восстанавливает содержимое, зашифрованное ключом от прежнего credential.

Первоначальные имя пользователя и пустой пароль, допускавшиеся старым установочным профилем, — явное состояние установки, не общая политика безопасности и не разрешение внешнему входу обходить допуск. Пользователь или администратор может заменить verifier. Конкретная политика первого запуска должна быть выражена отдельно.

После установленного подтверждения первичного credential политика может выдать делегированный ticket для модуля/сервиса с операциями и сроком действия. Изменение или сброс исходного verifier инвалидирует зависимые tickets согласно выраженной политике. OAuth и вход ОС — подключаемые модули; они не заменяют автоматически выбранный verifier и не получают власть из номера уровня L2/L3.

AuthEvidence может явно содержать пользователя, область verifier, ticket, разрешённые действия и факт кворума. Это данные с зависимостями и временем действия. Принимающее выражение проверяет необходимые свойства в своих юнит-тестах по [единому механизму](#admission); самостоятельный старый слой валидаторов не сохраняется. Совпадение пароля или корректная подпись не создают неявных ролей, привязок имён или бессрочного допуска.
[EN]
Credentials, verifiers, authority and evidence are explicit values in Message flow, not a global role hierarchy. A protected verifier checks a primary credential without retaining its original secret. A cryptographic result is a fact for policy, not automatic authority for every action.

A module, service, archive, directory or administrative operation may have its own verifier realm. A contract may require one verifier, several for one user, or a user/session quorum. Creator/child relationships establish lifecycle management, not content-reading rights. Resetting an access verifier does not recover content encrypted using a key derived from the former credential.

The initial username and empty password permitted by an earlier installation profile are explicit installation state, not universal security policy or permission for external input to bypass admission. A user or administrator may replace the verifier. A concrete first-run policy must be represented separately.

After primary-credential confirmation, policy may issue a delegated module/service ticket with permitted operations and expiry. Changing/resetting the primary verifier invalidates dependent tickets under explicit policy. OAuth and OS login are pluggable modules; they neither automatically replace the chosen verifier nor gain authority from language level L2/L3.

AuthEvidence may explicitly contain user, verifier realm, ticket, permitted actions and quorum satisfaction. It is data with dependencies and lifetime. The receiving expression checks required properties in its unit tests under [unified admission](#admission); the former independent validator layer is not retained. A password match or valid signature creates no implicit roles, name bindings or indefinite admission.

@@ crypto-values | Криптографические значения и провайдеры | Cryptographic values and providers | 19.32.10–19.32.12; 19.32.14–19.32.17
[RU]
L3 выражает криптографическое намерение, связи ключей, политику и состояние протокола. Провайдер реализует примитивы, защищённое хранение и платформенный интерфейс. Приведённые названия обозначают контракты, не окончательные parser-keywords или обязательную иерархию типов. Провайдер выбирается явно по профилю, ссылке, capability, конфигурации или сервису.

AlgorithmId содержит семейство, алгоритм, версию/профиль и существенные параметры. Параметры, влияющие на совместимость байтов протокола, явно заданы либо фиксированы именованным профилем. Подмена алгоритма и скрытый downgrade запрещены. Отсутствующий статически обязательный провайдер вызывает ошибку сборки/связывания; неподдержанный динамический выбор — явный отказ операции.

PublicKey — обычные несекретные данные с алгоритмом, форматом и байтами ключа, необязательными id/метаданными. Их можно копировать, хранить и передавать. Raw, SPKI, JWK и иные кодирования являются явным выбором; внутренний объект провайдера не является форматом обмена.

KeyRef — непрозрачное полномочие на секретный ключ с контрактом владельца-провайдера, операций, срока жизни и экспорта. Это не сырой L2-адрес и не обязательный массив секретных байтов. KeyPair объединяет PublicKey и private KeyRef. Генерация не публикует приватный материал в граф автоматически; неэкспортируемый ключ — допустимая реализация.

Verifier явно обозначает алгоритм, формат/версию, salt и параметры проверки: стоимость памяти, времени/итераций и параллелизма, а также результат или каноническое кодирование. KeyPolicy может задавать использование, сроки, ротацию, отзыв, версии, связь с объектом, экспорт и получателей; универсальная обязательная структура политики не установлена.

Передача KeyRef, возврат, сохранение в поле, композиция и смена провайдера не экспортируют секрет. Контракт определяет локальное использование разными Message, retain/transfer и допустимость сериализации. Переносимый исходный вариант — локальность провайдеру/runtime и отсутствие wire-сериализации. Передача секрета на другую машину требует явного разрешённого export/import или защищённого конверта.

Защищённая память — набор отдельных возможностей: контролируемое секретное хранилище, очистка, page locking, guard pages, неэкспортируемость, аппаратная защита. Одна не подразумевает остальные. Нельзя обещать удаление копий, которыми провайдер не владеет, в UI, VM или host. Синхронный вызов, сервисное сообщение и асинхронный адаптер могут реализовать один контракт, не вводя нового общего планировщика или готового `await` языка.
[EN]
L3 expresses cryptographic intent, key relationships, policy and protocol state. A provider implements primitives, secure storage and platform interfaces. The names below denote contracts, not final parser keywords or a mandatory type hierarchy. Providers are explicitly selected by profile, reference, capability, configuration or service.

AlgorithmId contains family, algorithm, version/profile and relevant parameters. Parameters affecting interoperable protocol bytes are explicit or fixed by a named profile. Algorithm substitution and silent downgrade are prohibited. Missing statically required providers fail build/link; unsupported dynamic selection fails explicitly at the operation.

PublicKey is ordinary non-secret data with algorithm, format and key bytes, optionally id/metadata. It may be copied, stored and transmitted. Raw, SPKI, JWK and other encodings are explicit choices; a provider's internal object is not a wire format.

KeyRef is an opaque secret-key capability with a contract covering owning provider, operations, lifetime and export. It is neither a raw L2 address nor necessarily an Array of secret bytes. KeyPair combines PublicKey and private KeyRef. Generation does not automatically publish private material into the graph; non-extractable keys are valid implementations.

A Verifier explicitly identifies algorithm, format/version, salt and verification parameters: memory cost, time/iteration cost, parallelism and result or canonical encoding. KeyPolicy may define uses, expiry, rotation, revocation, versions, object association, export and recipients; no universal mandatory policy Structure is fixed.

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

Открыты окончательные имена receiver, нормализованные структуры AlgorithmId/Verifier/Policy, обязательный начальный набор профилей, точные поддеревья ошибок и регистрация провайдеров. Streaming, secret streams, HSM/TPM, KEM/PQC, удалённые ключевые сервисы и формат защищённого конверта — отдельные будущие профили, не уже доступная семантика реализации.
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

Final receiver names, normalized AlgorithmId/Verifier/Policy Structures, mandatory initial profiles, exact error subtrees and provider registration remain open. Streaming, secret streams, HSM/TPM, KEM/PQC, remote key services and protected-envelope formats are separate future profiles, not already available implementation semantics.
