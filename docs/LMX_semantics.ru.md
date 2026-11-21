**Lingvamyxa (далее LMX) — язык, в котором программа — лексический лес примитивных массивов, связанный в динамический граф.** Эта организация самоподобно повторяется на уровне локальных акторов с физической адресацией в памяти и далее — на уровне дальних межмашинных сообщений с комплексной адресацией.

**И данные, и исполняемые тела являются массивами**, представленными одними и теми же простыми универсальными структурами; каждое исполняемое тело — полноценное абстрактное выражение.

**Типизация аналитическая, на уровне лексических ветвей.** Допуск любого кандидата в аргументы любого выражения сначала проверяет используемые поля и их интерфейсы для реальных Consumer-вызовов; дополнительную аналитическую часть (`test`) программист явно задаёт в принимающем выражении. Протестированные кандидаты и проверяющие выражения однозначно идентифицируются своими физическими адресами.

**Нормативная редакция: 21 ноября 2026 года.** Эта самостоятельная спецификация включает предоставленные требования о [связывании и именованных сигнатурах](TZ/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), [аргументах-объявлениях и import](TZ/LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md), [завершении блока пустой строкой](TZ/LMX_Fable_TZ_Blank_Line_Block_Terminator_2026-11-20.md), [операндах и выражениях](TZ/to_fable_operands_arguments_priorities.md) и [потоках полей import/copy/merge](TZ/LMX_Fable_TZ_Import_Copy_Merge_Field_Streams_2026-11-21.md). Последнее [уточнение автора о полном графе, uninit без полезной нагрузки и присваивании графу](TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md) заменяет прежнюю прозу о физической записи и редактировании графа. Последние требования имеют приоритет там, где пересматривают прежнее правило. Прежние принятые поправки остаются в силе там, где не изменены. Примеры задают требуемое поведение; эта редакция документации не утверждает, что среда исполнения их реализует или что тесты исполнения пройдены.

Русский текст — перевод английской редакции от 21 ноября 2026 года; при расхождении действует английский текст. Абзацы, оставшиеся на английском, ждут перевода. Третий абзац вступления в английской редакции уточнён: **Типизация аналитическая, на уровне лексических ветвей.** Общий механизм допуска проверяет используемые интерфейсы конкретного Consumer, всё дерево явно выбранного структурного шаблона либо упорядоченные типы входов и результата именованного требования `fn` — в зависимости от случая. Дополнительные поведенческие проверки (`test`) явно задаёт принимающее выражение. Значения-кандидаты и проверяющие выражения имеют свои обычные физические идентичности.

LMX — также грамматика, способная представлять как данные в сложной, уникально структурированной иерархично-табличной форме с пересекающимися множествами, так и, в принципе, любой язык. См. [полную спецификацию грамматики](LMX_grammar.ru.md).

**Уровни языка.**

- **L0** — нативный код: инструкции микропроцессора либо виртуальной машины. Для микропроцессора цепочка трансляции — **L3 → L2 → L1 → C99 → L0**; для виртуальной машины — **L3 → L0** напрямую. Стрелки обозначают стадии трансляции.
- **L1** — промежуточный язык, понижаемый до C99. Этот архив излагает его существенные границы через [спецификацию L2](L2_spec_ru.md) и [проект реализации](kernel-implementation.ru.md).
- **L2** — сам LMX с операциями низкого уровня, описанными в [спецификации L2](L2_spec_ru.md).
- **L3** — чистый герметичный LMX. Его семантика является предметом настоящей основной спецификации.

<!-- semantics-toc -->

- [1. Предмет языка и способы исполнения](#scope)
- [2. Значения, структуры и массивы](#values)
- [3. Идентичность и лексическое дерево](#identity)
- [4. Имена и пути](#fields)
- [5. Явные описания значений и преобразования](#descriptions)
- [6. Привязки типов и контекст преобразований на уровне Message](#conversion-context)
- [7. Проверка используемого интерфейса и test](#admission)
- [8. Как получить требуемую гарантию: четырнадцать практических случаев](#admission-recipes)
- [9. Построение значений](#construction)
- [10. const, immutable и independent](#qualification)
- [11. Вызываемые выражения и их интерфейсы](#callables)
- [12. Динамические входы и рабочее состояние](#dynamic)
- [13. Ветвления и циклы](#branches)
- [14. Выходы и finally](#exits)
- [15. Объявленные отказы и диагностика](#exceptions)
- [16. Повторный запуск и приостановка](#suspension)
- [17. Массивы и хранилище](#arrays)
- [18. Операции над массивами](#array-operations)
- [19. Числовые операции, чистота и контексты](#mathematics)
- [20. Композиция и копирование графа](#composition)
- [21. Таблицы, запросы, связывание и провайдеры](#registries)
- [22. Владение, достижимость и срок жизни](#memory)
- [23. Вечные ветви и общие методы](#eternal)
- [24. Message, актор и последовательный такт](#messages)
- [25. Доставка, владение и порядок изменений](#delivery)
- [26. Завершение, дети и сохранение результата отказа](#lifecycle)
- [27. Допуск и исполнение входящего сообщения](#pipeline)
- [28. Обычные вызовы LMX через Message-транспорт: `post` и ожидания ответов](#thread-message-api)
- [29. Mix: активные метки и интервалы](#mix)
- [30. WorldWideMix: адреса, ячейки и навигация](#worldwide)
- [31. Координация префиксов и зеркала](#mix-coordination)
- [32. HTTP и границы сервиса](#transport)
- [33. Идентификация, полномочия и свидетельства](#authentication)
- [34. Криптографические значения и провайдеры](#crypto-values)
- [35. Контракты криптографических операций](#crypto-operations)

<a id="scope"></a>
## 1. Предмет языка и способы исполнения

R0 is an ordinary compiled C method with a local pointer to the R0 graph, including when the program uses the interpreter. It remains a procedural entry without DATA or user actuals ([root entry](#root-entry)). Other selected executable bodies use a suitable native implementation when available; otherwise the compiled interpreter methods execute those bodies from the same complete graph. A body with only field fillings may omit its own separate native implementation when that preserves its semantics. Interpretation does not remove the binary R0 or create another program representation.

LMX одновременно представляет данные, исполняемые выражения, модели, запросы и сообщения. Исходная запись строит структуры; принимающее выражение задаёт их смысл. Записи, деревья, конфигурации, схемы, таблицы и программные тела используют одну структурную основу. Реестр, сервис, таблица и Mix — семейства данных и принимающих выражений, а не дополнительные уровни языка.

Every language rule is universal within its declared domain and applies uniformly to every matching construct. A name, type, source spelling, nesting level, lowering path, or implementation convenience creates no implicit exception. Apply the current requirements by their specific subject and revision, and correct superseded documentation directly. Only an explicit contradiction remaining between current governing requirements is referred to the author, with the conflicting provisions and a minimal example whose outcomes differ. Ordinary derivation from the shared rules is not a separate approval gate; translator, interpreter, and runtime must not invent workaround semantics.

L3 сохраняет изменение графа, структурные вызовы, таблицы, сообщения и локальные акторы. Низкоуровневые адресные операции, необработанный доступ к памяти, вызовы сырых машинных интерфейсов и явная низкоуровневая синхронизация относятся к [L2](L2_spec_ru.md). Различие уровней не устанавливает само по себе чистоту вычисления, полномочия пользователя или отдельную систему безопасности.

The current source profiles are `.lm2` for L2 and `.lm3` for L3; L1 is the generated intermediate stage before C99. Historical wrapperless `.lm1` input belongs to a separately selected former profile, not a required current source path. L2 code is written under the receiver `L2:`; its record lies in the graph as written, and by it the translator and the interpreter learn the level of the code. The spellings `L1` and `L3` do not themselves select a profile and remain ordinary names. An `.lm2` file by itself is as if wrapped in this receiver (the author's decision of 2026-11-17). `.lm4` and `.lm5` do not select current profiles. The file is itself a Structure: its root body is an L3 Structure executed from the start in every profile, including `.lm2`, where that body is the record `L2:` with the contents of the file; there is no `main` function. L3 is compiled into native code as L2 is, and a constructed graph of either level may be executed by the interpreter. The interpreter executes L2 code with the same checks as L3 code; an address operation that L3 does not have at all it executes with checks of its own; native L2 code is compiled without these checks (the author's decision of 2026-11-18). That is not the only difference of the levels: L3 has data types of its own, without external address arithmetic. Access to an element of an array is checked against the current length ([index](#structure-index)); pointers to Structures and to methods do not change their numeric value arbitrarily -- they are assigned only to one another and nulled; pointers to data are wrappers (the author's clarification of 2026-11-17). A suitable entry in call tables selects native execution; in its absence the interpreter executes the body. The rule that native execution is enabled only inside methods is withdrawn. A Thread has no "interpreted / native" modes -- the registered native variant for the particular call or the walker is selected; known native calls lower directly to C. The value of executing a file (its exit code) is the value of the root body's last evaluated expression; the root is an entry without data ([R0](#root-entry)), declares no result, and `return` in it is bare only. A service profile may select an explicit function, `start`, a handler or a message send. The entry point receives control after its environment and runtime graph are prepared.

Модель допускает интерпретацию построенного графа и трансляцию с сохранением той же семантики. Интерпретатор исполняет построенный граф, а не исходный текст и не L1. Реализация самого интерпретатора не расширяет язык интерпретируемой программы. L2 задаёт машинные механизмы, L3 — высокоуровневые программы, а L1 служит промежуточной стадией понижения к C99. Парсер, интерпретатор графа и транслятор имеют разные задачи. Грамматические формы, границы тел, литералы, комментарии и нормализация определены в [спецификации грамматики](LMX_grammar.ru.md).

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
[author clarification](TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

<a id="l3-receiver"></a>
### Принимающее выражение L3

Принимающее выражение L3 задаёт контракт потребления построенного графа как программы L3. Оно определяет поддерживаемое подмножество и точку входа выбранного профиля; наличие синтаксического дерева само по себе не устанавливает допустимость программы. Неподдерживаемая операция не становится допустимой из-за наличия машинного адреса реализации. Ограниченный профиль исполнения должен явно сообщать о неподдерживаемой конструкции, а не молча пропускать её или исполнять как L2. Это ограничение профиля не отменяет [единого механизма допуска кандидатов](#admission).

The walker executes the current binary graph rather than source text. The head of a written Frame is a word primitive: a cell with the pointer to the single reused string of its spelling; the walker recognizes the receiver by comparing the address of that string with the address of a language word's string (the author's decisions of 2026-11-08, which replaced the spelling codes of 2026-11-07) -- without a separate opcode in the graph, without numeric codes and without reading the bytes of spellings. Once the head is recognized, operands and data places are found by name through the service tables of the current traversal and then by graph addresses; those tables are kept nowhere outside a traversal. The translator consumes the same built graph and resolves the same head when generating code; completed `native` needs no name when invoked, as specified under [names and paths](#fields). A high-level operation may have an explicitly selected machine implementation with an L3 contract, as described at the [numeric/machine-operation boundary](#mathematics); this does not authorize arbitrary `c.*` calls from the interpreted program.

Имя головы хранится не внутри Structure как тег: голова — поле Lmx, ссылающееся на примитив-слово с адресом единственной строки написания; обходчик распознаёт по этому адресу ресивер и применяет его контракт к аргументной Structure. Адрес строки написания и есть имя головы, общее для всех её употреблений; служебные операторы и ресиверы (`for`, `=`, `**`, `fn`, `merge`) отдельных кодов не имеют — те же адреса строк (решение автора 2026-11-08). Отдельный числовой код операции не заменяет голову и не является семантическим основанием исполнения; после распознавания остальные связи остаются физическими. Компиляция может пользоваться числовыми кодами как собственными внутренними метками понижения, но они не становятся обязательной частью L3-графа или дополнительным способом определить смысл ресивера.

The name of a callable Structure follows the same rule as every other name: the external namespace keys it by the address of an existing owning field, and it is not stored as an Lmx field. When constructing a result in L2, the resolved receiver gives the record the corresponding type code; this creates no second graph and does not replace classification of the written head. There is no executable `fn`: `fn` describes a signature and does not create a callable ([`fn` signature](#fn-signature), [what is withdrawn](#removed-builtins)); a record declared inside `data` remains an ordinary Structure, and data is not classified by its field names or apparent shape. Likewise, a graph Array remains a Structure with the common `Lmx` base, while the type code in its value record determines the Array variant and element type; arena ranges determine ownership, not type. Field access after head recognition uses addresses, without another lookup of field names.

Простейшая программа скриптового профиля:

```text
print: "Hello World"
```

<a id="values"></a>
## 2. Значения, структуры и массивы

Структура — упорядоченная совокупность непосредственных полей. Поля содержат ссылки на значения: примитивные ячейки, другие структуры (в том числе Array) и записи методов. Лексическая вложенность образует лес; дополнительные ссылки соединяют его в граф с общими объектами и циклами. Примитивная ячейка не получает отдельную структуру-обёртку только потому, что на неё ссылается поле.

<a id="header-receivers"></a>
<a id="system-receivers"></a>
### Вспомогательные ресиверы sys

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


### Receivers parent, length, sys\native, sys\storage

Обычные не объявляющие ресиверы принимают одну Structure S, включая Array, либо работают без аргумента:

| Вызов | Результат | Без аргумента |
| --- | --- | --- |
| `parent(S)` | Структурный родитель S, значение поля заголовка `parent`; 0 у корня | `parent()` — `parent(D)` |
| `sys\native(S)` | Native-дескриптор S из таблиц call, включая варианты сигнатур; 0 при отсутствии; чтение не вызывает его | `sys\native()` — `sys\native(D)` |
| `length(S)` | Число непосредственных полей Structure или элементов Array, значение `length` | `length()` — `length(D)` |
| `sys\storage(S)` | Указатель на хранилище элементов, значение `storage` | `sys\storage()` — `sys\storage(D)` |
| `sys\capacity(S)` | Вместимость в элементах из таблицы арены по адресу S | `sys\capacity()` — `sys\capacity(D)` |

Here `D` is the DATA of the current call, where it exists: for executable `C` it is actual `parent(C)`. An inline body does not substitute another DATA. `call(A C)` supplies actuals A and does not replace D. R0 has no fabricated default D. Explicit arguments select other Structures, including the selected code itself. Colon and parenthesized receiver forms have the same contract; a bare name invokes nothing. The reserved lexical `node` is a different operation and is not a zero-argument parent query.

In the role of `code` the receiver executes; in the role of `data` a same-headed structural form remains data. With one occurrence, `D\parent`, `D\native`, `D\length` and `D\storage` select the written Structures just as `D\for` does; repeated names require the ordinary occurrence index. Paths gain no header pseudo-fields. The DATA namespace pass interprets root declarations and consumes explicitly specified `import`, `copy` and `merge` where their contracts require it; those three use standard CODE source arguments. It does not execute arbitrary DATA bodies. Code explicitly consumed by a receiver follows that receiver's contract ([rule](#data-root-declaration-execution)).

В физическом заголовке Lmx прежние `size` и `data` переименованы в `length` и `storage`; итоговый порядок — `parent/length/storage`. Native-дескрипторы находятся в таблицах call; вместимость — в таблице арены. `data` и `code` — названия ролей ([роли `data` и `code`](#data-code-roles)); особого имени `data` нет ([имя `data`](#ordinary-var)), а `code` — имя параметра ресивера `call` для исполняемой Structure ([структурный вызов](#call-receivers)). Их смысл не связан с указателем на хранилище. `node` сохраняет действующий контракт зарезервированного контекста активации, неизменного во вложенных телах; ресивер `node(S)` не вводится.

Reading parent/length/storage accesses its header field directly; native/capacity use their corresponding arena tables. These queries construct no auxiliary descriptor. `sys\descriptor` returns addresses of actual fields for explicit writes under the [L2 descriptor contract](L2_spec_ru.md#get-descriptor).

<a id="get-descriptor"></a>
`sys\descriptor(S)` and `sys\descriptor: S` select an explicitly supplied Structure. With no argument, `sys\descriptor()` and `sys\descriptor:` equal `sys\descriptor(D)` for the data `D` of the current launch (for an executable `C` it is `parent(C)`, [structural call](#call-receivers)), including inside nested control bodies; code requires an explicit argument. In data, a same-headed form remains an ordinary Structure. Both variants return the selected Structure's field addresses under the same contract. Author's decision.

Ordinary receiver `sys\descriptor: S` returns a Structure d containing addresses of S's three actual header fields: `parent`, `length`, `storage`, in that order, without nested VoidArray. Address types are `Lmx **`, `size_t *`, `void **`. `\(d\length) := n` directly changes S.length; `d\length := p` changes only the pointer inside d. These are live field addresses, not a copy or proxy. A direct length write does not allocate storage; `sys\resize` performs coordinated resizing. The descriptor neither extends S's lifetime nor transfers ownership. Native and capacity are not its fields; `S\native` selects an ordinary field if present. [L2 contract](L2_spec_ru.md#get-descriptor).

Pointer depth and Array rank are independent arbitrary finite quantities; the language has no fixed limit. A typed reference's indirection level is distinct from prefix `@`, which explicitly obtains a numeric address under the selected level's address contract; ordinary Structure and method references need no prefix `@`. Dereferencing follows the reference or admitted address contract without calling its target. An explicit write through `S\field` or a typed dereference follows the place's general requirement, including references and function pointers. Restrictions on assignment through a bare Structure or function name and on implicit external lookup do not prohibit such explicit writes.

An Array is an ordinary graph Structure with its own structural `parent`; receiver `[]` supplies its elements and their storage type rather than creating a separate family of language objects. An Array contains elements of one type. Its length counts Array elements, while the containing Structure's field count counts its direct fields. An Array of references to Arrays differs from a rectangular multidimensional Array. Nesting `a: b: c: d:...` is the general form of receiving-expression application and has no fixed depth limit. `[]: []:` applies the ordinary Array receiver through that general form; it is not a separate construct or a special array-of-arrays type. An Array element may be a primitive or a reference to a nonprimitive value under the ordinary storage rules; each independent Array has its own length. The C-like head `[][][]` denotes a flat rectangular multidimensional Array and is unrelated to composing separate `[]:` receivers. Dimensionality is not recovered from physical storage. An intermediate Array can be bound to a name through ordinary typed binding: for `[]: []: []: a`, the steps `[]: []: b a[i]` and `[]: c b[j]` each index one independent Array without copying a nonprimitive value. Direct access through multiple Arrays uses the ordinary path `a[i]\[j]\[k]` ([paths](#fields)), not adjacent indices of a flat Array. For example, `char: []: []: mainArgs` uses the same general nesting for an Array of strings: each string is an independent `char` Array of exact length `len` without a trailing NUL (`LmxCharArray`, [L2 §5](L2_spec_ru.md#method-array)); NUL belongs to the `c.*` door representation, not the graph value. Representation and the value record -- a type code immediately followed by the value -- are specified in [L2](L2_spec_ru.md#value-record).

An empty Structure is a present value with zero fields. It differs from an absent field, numeric zero, and `void`, which denotes no primitive-cell content. A Frame's argument list is itself a Structure; an anonymous Structure in it remains a distinct value also when it alone occupies the entire list: P0 does not unwrap it, whether it is empty or not (author's decision of 2026-11-10). Thus in the parse tree `f()`, `f:`, and an explicitly closed empty vertical body are one tree with an empty body, `f: ()` and `f(())` are one tree with one field, an empty Structure; `f(a b)` and `f: a b` are one tree with two fields, `f((a b))` and `f: (a b)` one tree with one Structure field. This is said of the tree only; in the clean graph the form lies as it is written, too. What a form does is determined in translation and interpretation -- by the role of the form ([the roles `data` and `code`](#data-code-roles)) and by the kind of the receiver ([two kinds of receivers](#two-kinds-of-receivers)). In a call of a callable and of a receiver that takes its arguments as `code`, the four forms `f: a b`, `f(a b)`, `f: (a b)` and `f((a b))` are one and the same call when reading E is selected: the sole Structure among the arguments is expanded into the chain of its fields, once and only when the call is processed; reading W accepts it as a whole, and the two readings are equal ([choosing the declaration by the call](#declaration-selection), [the whole argument structure](#whole-arguments)). A receiver that takes its arguments as `data` receives exactly what is written; in the role of `data` the forms do not change either, and nothing is unwrapped: `f: (a b)` declares `f` with one anonymous Structure inside it, while `f(a b)` and `f: a b` declare a Structure with the fields `a` and `b` (the author's clarification of 2026-11-18). See [empty bodies](LMX_grammar.ru.md#empty-colon).

`None` — контекстное значение: его представление задаёт ожидаемый тип принимающего выражения. Единого кодирования для всех типов нет; тип без соответствующего определения `None` его не принимает. Число `0` остаётся нулём, в логических операциях — ложью, и не является общим признаком отсутствия. В прежнем профиле `Boolean` использует диапазон −1…1: `None = −1`, ложь — 0, истина — 1. Это конкретное определение профиля, а не универсальное кодирование всех отсутствующих значений.

Текст, изображение, десятичная запись и машинное слово до распознавания принимающим выражением являются исходным хранилищем данных. После разбора или декодирования они представлены значениями того же графа. Имена форматов и численных библиотек не вводят дополнительные фундаментальные виды значений.

<a id="identity"></a>
## 3. Идентичность и лексическое дерево

Живые структуры, включая Array, и локальные Message сохраняют физические адреса. Физический адрес записи является идентичностью Message внутри процесса; локальная идентичность не дополняется индексом родителя. Рост хранилища добавляет новые участки; существующие объекты не перемещаются. Равенство содержимого не означает тождества объектов. Явное копирование создаёт новые идентичности и сохраняет связи между ними по правилам [копирования](#composition). Иерархические цепочки индексов принадлежат только [WorldWideMix](#worldwide).

Лексический родитель определяет положение структуры в дереве; у корня родителя нет. Владение памятью и лексическое родство независимы. Присоединение хранилища другого Message сохраняет существующие лексические ссылки, не добавляет само по себе ссылку из корня получателя и не превращает присоединённый корень в лексического ребёнка получателя.

Отсечение внешнего лексического родителя при построении задаёт [квалификатор independent](#qualification); получение входов от вызывающего выражения подчиняется [динамической видимости](#dynamic). Эти механизмы не меняют отношения владения и тождества объектов.

<a id="references"></a>
<a id="fields"></a>
## 4. Имена и пути

Source entity names are not stored inside graph cells. A primitive or Lmx name comes from the address → name table; name is the address of the one canonical string for that spelling in the typed arena. Identifiers, service operators and receivers are compared by those string addresses, without separate numeric codes. Atom is a parser term; physical graph elements include both Lmx Structures and directly encoded primitives. The walker recognizes a written head by its canonical pointer, while the translator consumes the same clean graph and emits native. The name table stores neither variable resolution nor prior traversal state: each traversal creates and discards its own namespace. Graph copying transfers names for copied addresses, interning spellings at the receiving boundary. Anonymous and positional values need no synthetic names. The physical model is specified in the [implementation specification](kernel-implementation.ru.md); current-graph serialization is defined by the [sys\toLmx contract](#source-codec).

One spelling has one canonical string with a stable address in the typed arena. Heads, fields, formals, actual names, paths, failure names and service operators use that same representation; there are no separate incremental identifier or operator codes. A spelling is interned at input boundaries such as parsing, loading, `sys\fromLmx`, and attachment of foreign regions. Traversal-specific name resolution is temporary and starts clean. User character Arrays are ordinary string values, not canonical identifiers. The [physical representation](kernel-implementation.ru.md) and [explicit string-name queries](#string-identifier) preserve this distinction.

Структурный путь `object\field\nested` последовательно выбирает поля графа. Наличие каждого перехода и его допустимость определяются выбранным объектом. Вычисляемый путь не заменяется выдуманным статически известным именем. Зарезервированный `node` обозначает лексическое пространство над методом и остаётся одним и тем же во всей его активации; `node\field` начинает явный обход из этого пространства. Голое `field`, полученное по лексическому fallback, передаётся как скрытый аргумент текущей активации и не тождественно явному пути `node\field`.

A path may contain an unnamed index step `a\[i]` selecting a typed Array element. `a[i][j]` addresses a rectangular multidimensional Array, whereas `a[i]\[j]` indexes a separate Array obtained through the value of `a[i]`; `a[i]\[j]\[k]` follows further references. Index steps may be mixed with Structure fields to any finite depth. In a Structure used as `data`, `s\[N]field` with zero-based `N` selects the Nth occurrence of the name `field` at its root level: an occurrence is a form of the data that declares that name, be it a declaration by a receiver of a place or a structural form with that head; nested forms belong to their own Structures. This is not an Array step. With one occurrence, `s\field` is allowed; with two or more it is ambiguous and an index is required: a repeated declaration in data neither replaces the former one nor writes into it and remains one more occurrence (the author's decisions of 2026-11-11, [the roles `data` and `code`](#data-code-roles)). The first occurrence is not selected automatically.

The source forms of a DATA Structure D retain their written nesting: a root `if:` is a form addressed as `D\if`, while a y declaration inside it is reached through that enclosing form, not promoted to root `D\y`. Other control and ordinary call forms follow the same rule. Semantic root declarations under modifiers and stream receivers participate in the namespace under their contracts; this does not flatten the source graph. An explicit path starts from the named Structure selected by the program. There is no special `data` reference, and `node` remains an explicit lexical operation rather than a generic synonym for that Structure.

<a id="primitive-declaration-is-the-element"></a>
A path has no step for a receiver that declares a primitive: with `S: int: x 10` the field is read by the path `S\x`, not `S\int\x`. This is not a special rule of paths but the way the memory of a Structure is arranged. A Structure keeps its elements as an array, and each element refers to a value record: a type and, right after it, a value ([L2, section 3](L2_spec_ru.md#value-record)); the name of the element is held by an «address -> name» row. The complete terminal declaration `int: x 10` is therefore present as that element's record «type `int`, value 10» with the name `x`. This is its direct physical encoding, not removal of the declaration from the graph. Nothing is lost: the text of the declaration is recovered unambiguously from the type, the value and the name, and that is how `sys\toLmx` prints it. A declaration without a value contains only the type code `uninit:T`, with zero value bytes and no reserved T cell, and is recovered as `int: x` in the same way. This compact typed-leaf representation is part of the full literal source graph, not an omission from it. The record of a modifier, of a control receiver or of a call cannot be recovered from a type and a value, so it lies in the graph as it is written -- a Structure named by its head -- and the path goes through it: `S\private\x`, `D\if\y`. A computed declaration `int: x f()` is not a ready value either: the path `S\x` gives its record ([explicit path](#path-reads-no-execution)) (the author's clarifications of 2026-11-11; 2026-11-17; 2026-11-18).

`node` is reserved and cannot be declared, shadowed, rebound or dynamically supplied, including through exact-identifier spelling. It denotes the established lexical space above the selected method and remains fixed during that activation, including nested control bodies. It is **not** a generic query for the immediate parent of the currently visited form or for the current stream recipient. Lowering carries the corresponding physical lexical reference as the required `Lmx *node` parameter; no new user closure or namespace object is inserted. Ordinary structural parent links retain the source nesting and the copying contract, but an inline body's parent chain does not rebind node. The DATA relation `D = parent(C)` and the lexical node operation keep their respective contracts.

`parent(S)` is an ordinary receiver that reads a structural link, not a reserved name or path pseudo-field. A hidden bare field uses the place selected by binding: explicit actuals, autofill and retained fallback have their own working places; a transparent caller binding denotes the caller's real place. Assigning that name creates neither a source field nor persistent method state. Reached CODE declarations work in the namespace, while explicit paths address the graph. The graph fully reflects the written source: every receiver remains as written, and terminal primitive leaves are present in their own `{type value}` representation at the address held by the Lmx cell. An uninitialized leaf has its type code only and a zero-size value.

| Имя | Где существует | Значение |
| --- | --- | --- |
| `node` | зарезервированное слово L3 и первый ABI-параметр метода | пространство над методом; неизменно для всей активации, включая вложенные тела |
| `data` (до 2026-11-11 — `var`) | не зарезервировано с 2026-11-19: название роли и обычное пользовательское имя | особого смысла нет; данные исполняемой Structure — её `parent` ([правило](#ordinary-var)) |
| `code` | доступная при исполнении Structure кода, аргумент запуска | код, выбранный запуском; не физическое поле заголовка Lmx |
| `parent` | физическое поле каждой Lmx, читаемое обычным ресивером | непосредственно объемлющая Structure; `parent()` берёт данные текущего запуска, `parent(S)` — явную S; обычный путь выбирает пользовательское поле |
| `self` | только скрытый ABI-контекст | активная Structure текущего вызова; не слово языка |

Исполнение удерживает физическую ссылку на активную Structure (§12). Это скрытый ABI-контекст, а не новое исходное имя `self`, не второй граф данных и не замена зарезервированного `node`.

Graph-field names and call-namespace variables are distinct. All same-named data declarations remain; ambiguous names require an occurrence index. The call namespace is prepared from root declarations in `data` and `code`, including declarations supplied by the explicit stream contracts, without a general walk of nested branches or graph references ([namespace consumption](#data-root-declaration-execution)). A new branch-local name is visible at its own level and in descendants, not outside. A name already declared on the same level, when re-declared in code, denotes the existing local cell, while a declaration on a nested level shadows the outer one of the same name ([levels of declarations](#shadowing-levels)); the call and assignment in `int: x bump()` remain. See [call frames](#call-frame-20261115).

For example, `int: y give()` describes the named place y and retains its computed declaration in the graph. Its initializer runs when the declaring action is reached or its permitted computed namespace value is demanded, not by inspecting the source path. In CODE a subsequent same-level `int: y 7` performs type checking and writes the same logical place; `int: y` with no new RHS neither resets it nor adds a second C variable. In DATA repeated declarations remain distinct written occurrences. A passed declaration instead preserves its form under [declaration arguments](#declaration-arguments).

An independent callable invocation creates a new namespace; [accepted declaration forms](#declaration-arguments) and their associated bodies share the receiving execution's established places under their specific contract. Nested control bodies in a call do not create an activation, but new local names belong to their lexical branch. Re-declaring a variable already declared on the same level creates no second C variable; a declaration on a nested level creates its own place and shadows the outer one of the same name ([levels of declarations](#shadowing-levels)). This does not collapse repeated declarations in the source graph. Root preparation neither lifts branch declarations nor completes `data` with `code` fields.

Начальные число и порядок полей Structure задаются построением и лексическим порядком; порядок выдачи native не разрешает переставлять поля графа. Обновление существующего поля заменяет содержащуюся в нём ссылку, не добавляя вхождение. Structure и Array<@> используют общее явное изменение размера через sys\resize и sys\reserve; length меняется только явной операцией размера или записью заголовка, не автоматически при записи элемента. См. [переменные массивы](#array-capacity).

<a id="descriptions"></a>
## 5. Явные описания значений и преобразования

Описание значения — обычная явно доступная структура. Принимающее выражение получает его через аргумент или ссылку. Описание не прикрепляется скрыто к каждому примитиву и не нужно для определения физического типа: его даёт код в записи значения. Названия `class`, `class.range` и подобных таблиц обозначают данные конкретного профиля, а не обязательные глобальные сущности языка.

Таблица преобразований задаёт соответствия примитивных значений и их описаний, а не всех пар Structure или их имён. Разные структуры `A` и `B` имеют общее физическое представление `Lmx` — запись с кодом типа ([L2 §3](L2_spec_ru.md#value-record)); имя и состав полей не создают отдельный физический тип или массив из одного элемента. Структурная пригодность `B` требованию `A` определяется `implements` относительно Consumer, не строкой конверсии `B → A`. Получение или перенос ссылки на Structure также не требует отдельного конвертера для каждой модели. Общность физического представления не отменяет структурный допуск, квалификации и различие ссылки на Structure со ссылкой на ссылочную ячейку.

Описание разделяет семантический контракт и архитектурное представление. Контракт задаёт смысл: счётное число, целое, рациональное, число с выбранной точностью, комплексное, атом, адрес, непрозрачный ресурс или отсутствие содержимого. Представление задаёт ширину, знаковость, диапазон и обозначение целевого типа. Одинаковое представление не делает контракты одинаковыми: `Boolean` и `int8` могут храниться одинаково, но иметь разные допустимые значения.

Обычные поля описания включают `cell`, `semantic`, признаки `numeric`/`integer`/`floating`/`reference`/`opaque`, `width`, `signed`, `range`, `spelling` и ключи преобразований `convert`. Имена полей выбирает профиль. Указание диапазона является данными контракта; его выполнение проверяется [единым механизмом допуска](#admission), а не самим наличием поля.

Численная цепочка контрактов: флаг → неотрицательное целое → целое → рациональное → число с точностью профиля → комплексное. Неотрицательные целые включают ноль. Машинное `double` не является множеством всех вещественных чисел. Атомы, адреса и непрозрачные ресурсы — отдельные контракты, не ступени этой численной цепочки. `unit` — пустая структура; `void` — отсутствие содержимого ячейки.

Описания составляются обычным `merge` с общим правилом [порядка вхождений](#fields). Поля `width`, `range` или `spelling` не создают автоматически арифметические методы. Такие операции задаются вызываемыми выражениями. Пример `u32` сочетает неотрицательный целочисленный контракт, 32-битное представление и диапазон 0…4294967295; `FILE` описывает непрозрачную идентичность ресурса. Слово `FILE` само по себе не доказывает возможность чтения или закрытия: такие требования выражаются путями структуры `File`.

Преобразователь — явно выбранное принимающее выражение. Его ключ поступает из явных описаний и их композиции; скрытого перебора пар нет. Проверка пригодности не исполняет преобразователь, а требующее преобразования действие выполняет выбранный вызов. Повторное объявление ключа в одной Structure читается по роли ([роли `data` и `code`](#data-code-roles)): в данных это ещё одно вхождение имени — прежнего оно не заменяет и в него не пишет, и ключ после него адресуется только с индексом вхождения ([имена и пути](#fields)); в коде повторное объявление ресивером записывает в уже объявленное место после проверки типа, не создавая второго поля. Композиция записывает одноимённый ключ позднего операнда в слот модели. Если таблица содержит несколько строк с одним ключом, выбор строки задаёт её собственная политика ([таблицы](#registries)).

Численное преобразование сохраняет контракт диапазона назначения: `u16(255) → u8` допустимо при наличии преобразователя, `u16(256) → u8` даёт ошибку диапазона, а не ноль. Округление `1.5 → i32` и потеря точности внутри диапазона требуют отдельного правила численного профиля. Доказанная включённость диапазонов может исключать избыточную машинную операцию, сохраняя семантическое требование. Ошибки формата, диапазона и поведения преобразователя не заменяются положительным ответом `implements`.

<a id="conversion-context"></a>
## 6. Привязки типов и контекст преобразований на уровне Message

Each executing Message has one context of type descriptions, symbolic bindings, and conversions. It consists of ordinary Structures and references explicitly supplied when the Message is built or reachable from them. Message creation, sending, and parenthood do not implicitly pass the parent's context. There is no built-in process-global registry, implicit type environment, or hidden converter search. The table of conversions that `implements` uses can be changed when a new L1 Thread is created (the author's words of 2026-11-18).

### Устойчивые привязки и структурная общность

Символическое имя типа связывается один раз для Message и одинаково разрешается во всех его употреблениях, включая аргументы и результаты; каждый вызов не инстанцирует его заново. Другой Message может связать то же имя иначе. Это отношение внутри контекста, а не дополнительное пространство runtime-имён.

Структурная обобщённость — обычный случай [допуска](#admission): Consumer требует только используемые пути, операции и контракты. Отдельный generic-шаблон не нужен. Символическая привязка требуется, когда несколько позиций должны разделять одно устойчивое отношение типов, а не для объявления обобщённости как таковой.

### Преобразования при потреблении

Достижимая таблица преобразований касается примитивных описаний, включая явно заданные семантические величины и единицы; это не каталог совместимости Structure. Иное примитивное описание допустимо только через доступное в данном Message преобразование, разрешённое контрактом Consumer. Первая часть допуска — проверка пригодности — не исполняет преобразователь. При действительном потреблении он исполняется как обычное вызываемое выражение с проверками диапазона, представления, точности и семантических условий. Успех структурной проверки не разрешает переинтерпретировать примитивное хранилище без такого преобразования.

Перед вызовом преобразованный фактический аргумент должен удовлетворять действительному дескриптору выбранного вызываемого выражения; после вызова результат отдельно приводится к требованию его Consumer. Отсутствующий в достижимом контексте преобразователь не заменяется скрытой цепочкой или поиском по процессу. Реализация вправе кэшировать разрешённые привязки и маршруты, только сохраняя результат явного разрешения.

Развёрнутые [примеры контекста Message](LMX_semantics_guide.ru.md#message-conversion-context) вынесены из нормативного текста.

<a id="admission"></a>
## 7. Проверка используемого интерфейса и test

Candidate admission uses one mechanism: interface checking by directional `implements`, then the explicitly specified analytical checks (`test`) of the receiving expression where that admission contract requires them. Physical type codes identify representation but do not replace admission. Ordinary used-interface checking examines a concrete Consumer's actual demands; an explicit structural template requires its whole stated tree, and a named fn description selects the [positional signature rule](#fn-signature). These are branches of the same mechanism, not alternative type systems.

Clean-graph construction checks statically known candidates without running their bodies or computed initializers. Prepared native execution does not add automatic runtime `implements`; an explicit `implements` written in the program still executes. The interpreter uses the standard `implements` automatically at reached calls, not an independent validator, and does not pre-walk unexecuted branches. A reception retains its established correspondence for that reception's operations; a later traversal obtains its own information from the graph. Neither mechanism adds a persistent admission cache or automatic graph-write tracking. Prepared machine entries change only through [explicit compilation](#explicit-compilation).

After the clean graph is constructed, the interpreter executes the build's required `test` receivers before the final C compilation step. The ordinary build and receiver contracts reach these tests; this is not a search that executes arbitrary `test` forms in nested DATA merely because they exist. A failed test prevents acceptance and compilation of that build. This test phase is distinct from constructing the graph and from speculatively executing argument/default/test code while enumerating call candidates. Dynamic reception and explicitly requested checks retain their ordinary reached-execution behavior. The checking expression and the candidate/helper calls it makes use ordinary dispatch; interpreter-led testing does not force every nested call onto the walker. No unspecified analysis of future values or behavior is added.

<a id="analytical-tree"></a>
### Проверка используемого интерфейса

<a id="three-argument-implements"></a>
#### `implements(aVar, bVar, Consumer)`

`aVar` is the candidate, `bVar` the required role, and `Consumer` the concrete receiving expression. For a Consumer-derived used interface, its known accesses in visible branches determine the demanded paths; unused incidental fields are not promoted into that requirement. When an ordinary Structure is explicitly selected as a structural template, all of its stated tree is required, including explicitly included methods and their subtrees; a Consumer's immediate use does not erase them. Without Consumer, the stated requirements of `bVar` are checked rather than an empty access set. Extra candidate fields are allowed. A `fn` requirement instead uses the ordered type/result comparison described in [§11](#fn-signature). An unknown computed path is not reported as checked, and uncertainty alone does not establish an incompatibility; an error requires a guaranteed unsatisfiable requirement.

Для использованного пути необходимы соответствующее поле кандидата и совместимость интерфейса его фактического потребления. Если Consumer явно вызывает поле, проверяются только записанные вызовы: фактические и именованные аргументы, умолчания и доступные преобразования должны удовлетворять выбранному интерфейсу и действительному дескриптору реализации; объявленный результат и объявленные выходы — требованию Consumer. Это проверка совместимости интерфейсов, не предсказание будущего результата. Непрозрачная передача callable не проверяет будущих вызовов. Простая передача примитивного листа не доказывает его значение; содержательные свойства проверяют явные тесты.

Used interface checking executes none of the candidate, Consumer, method or converter and adds no analysis of future behavior. It establishes compatibility for this Consumer, not equality of Structures or suitability for every future consumer. A positive result maps each used model field to a physical candidate field, possibly at another position. This is a **general** map for any admitted pair of Structures, not a table specific to methods, `data`, or `call`. Explicit structural reading, writing and taking addresses through the admitted correspondence use these physical places; access to those mapped fields performs no further name lookup ([L2 §14](L2_spec_ru.md#implements), [L2 mechanisms](L2_spec_ru.md)).

<a id="correspondence-stability"></a>
#### Сохранение установленного соответствия

Named receiving places use the ordinary admission contract. For `S\x := value` and `S\[n]x := value`, the field requirement is checked during clean-graph construction where it and the candidate are known. `S[n] := p` is a `void*` array write, identical for a Structure and `Array<@>`. It inherits no name, type, or requirement from the previous content and performs no field admission. Subsequent structural access interprets current graph content. No table of former physical-slot requirements is needed for this write. Admission still applies where a value is actually received against a description.

<a id="argument-compatibility-stage"></a>
Translation checks the signatures, argument assignments and obligations needed for correct generated code, including written throws/catch. It uses the same admission rules as other consumers. A known method name alone does not prove the current type of a mutable binding. Calls use the selected declaration and actual-to-formal map; their input requirement is obtained from actual `parent(C)`, and a fn-constrained reference also applies its public-label/position map. The interpreter checks through the standard mechanism at reached operations; prepared native code does not add an automatic runtime admission layer.

Conversion is distinct from interface checking. Receiving a numeric value still obeys destination-range rules, so an admitted conversion of `u16(256)` to `u8` can fail for range rather than silently wrap. An established structural address map neither removes reception of a new actual nor reruns every user test on every write. Ordinary selected callables, converters and tests share execution and failure handling; future bodies are not speculatively run to decide a call.

<a id="graph-tests"></a>
### Аналитическая часть test

Where the admission contract requires analytical checks, it executes the receiving expression's explicitly stated checks against the constructed graph. Interface matching itself runs none of those checks or candidate bodies. Graph construction performs no `test` execution; the separate pre-C build-test phase and reached runtime checks use the common executor. Without explicit Consumer, checks belong to the receiving description `bVar`, not to candidate `aVar`. No specified tests means no additional analysis, not proof of behavior. The first result 0 stops admission; remaining checks do not execute, and success requires all specified checks to succeed. Declared failures use ordinary throw/catch. Checks are not watchers on every graph write.

<a id="test-receiver-contract"></a>
#### Ресивер `test:`

При исполнении внутри Structure запись `test: op checkIncrement` связывает принимаемое место `op` с обычным проверяющим выражением `checkIncrement`. Оба имени разрешаются как аргументы ресивера, а не вызываются неявно. Имя `test` зарезервировано; пользовательское имя для обычного метода может быть `mytest`. Связь принадлежит Consumer, не кандидату; несколько `test:` задают несколько обязательных проверок. Проверки вложенного Consumer не становятся автоматически проверками внешнего.

A `test` form follows the general [rules for execution through receivers](#data-root-declaration-execution). The DATA namespace pass interprets root declarations and, when reached or required, consumes explicitly specified `import`, `copy` and `merge` using their standard CODE source arguments. It is not an arbitrary DATA-body execution pass: a `test:` form among the data does not run merely by being present. An executing receiver may reach code supplied to it, and that code may reach `test`. There is no separate pass that finds and executes `test` in nested data (the author's clarification).

Проверяющему выражению передаётся фактический кандидат обычным аргументом. Пригодность структуры для его собственных обращений проверяется до исполнения; `@` не добавляется ради передачи Structure, уже передаваемой ссылкой. Проверка возвращает обычный `int`: 1 — успех, 0 — неуспех. Ожидаемый отказ проверяется обычным `catch`, а произвольный `throw` не считается успехом.

Исполнение проверки завершает уже начатый допуск, не начинает тот же допуск заново. Цикл незавершённых проверок не является успехом. Написанная связь и тело проверки находятся в том же графе для `sys\toLmx`, копирования и исполнения, пока не изменены явной записью; отдельного каталога тестов, вспомогательного графа, дополнительной runtime-таблицы связывания имён и скрытого отключения типизации нет. Тесты вызывают методы через обычную диспетчеризацию native/обходчика и не принуждают всё исполнение к обходу.

<a id="admission-recipes"></a>
## 8. Как получить требуемую гарантию: четырнадцать практических случаев

Эти случаи применяют [единый допуск](#admission), а не вводят четырнадцать разновидностей типизации.

<a id="admission-case-1"></a>
### 1. Одно принимающее выражение для разных форм данных

Consumer требует используемые им пути, а не номинальный тип всей Structure.

<a id="admission-case-2"></a>
### 2. Понимание того, что проверяется в данном месте

Первая часть проверяет пригодность структуры для реальных обращений Consumer; вторая, аналитическая часть `test`, проверяет заявленное поведение. Неизвестное покрытие не считается доказательством.

<a id="admission-case-3"></a>
### 3. Различение смыслов одинаково представимых значений

Смысловое различие выражают используемым путём и, когда важны значения листьев, тестом; одно имя типа не доказывает равенства значений.

<a id="admission-case-4"></a>
### 4. Ограничение скалярного листа

Наличие поля `width` не доказывает `width = 32`; проверку конкретного числа задаёт тест Consumer.

<a id="admission-case-5"></a>
### 5. Изменение, видимое другим держателям ссылки

Запись через явный путь меняет адресованный общий референт; присваивание аргументу или другой собственной локальной переменной меняет только место текущей активации, без обратной публикации; имя, связанное как место вызывающего, обозначает место вызывающего, и запись в него действует сразу ([собственное место и место вызывающего](#binding-places)). [Кадр вызова](#call-frame-20261115).

<a id="admission-case-6"></a>
### 6. Независимость от изменения другим держателем

Обычная передача Structure или Array переносит ссылку. Независимую изменяемую копию даёт явное копирование, неизменяемость запрещает изменение защищённого значения.

<a id="admission-case-7"></a>
### 7. Гарантия возможности вызова

Besides a suitable callable interface, the call needs a source for each of its free (dynamic) inputs. Ordinary declared inputs are optional unless input `required` or another applicable contract rules out omission: an input without a value, to which no value is supplied, does not make the call refuse: [autofill](#binding-autofill) fills it, and where that is inapplicable it holds "T without initialization" (the author's decision of 2026-11-16); the receiver [`required`](#required-receiver) checks that a field is initialized.

<a id="admission-case-8"></a>
### 8. Проверка передаваемого вызываемого значения

Передача callable не исполняет его и не доказывает пригодность для каждого будущего вызова; конкретный вызов проходит собственный допуск.

<a id="admission-case-9"></a>
### 9. Изменение тела метода без нарушения вызовов

Новый свободный динамический вход меняет интерфейс метода и требует проверки затронутых вызовов; неизменная сигнатура сама не гарантирует прежнее поведение.

<a id="admission-case-10"></a>
### 10. Выбор нужной части композиции

`merge` composes only its explicit sources: a compatible later field replaces the corresponding first-source model slot, and a new field appends. It emits the resulting fields as a stream; grouping obtains one Structure. The destination is not an implicit model.

<a id="admission-case-11"></a>
### 11. Изменение существующей структуры

Structure использует общий механизм переменных массивов: sys\resize меняет length и при необходимости storage; адрес дескриптора сохраняется. Сырые адреса прежнего storage автоматически не исправляются; L3-ссылка на элемент хранит дескриптор и index.

<a id="admission-case-12"></a>
### 12. Надёжное численное преобразование

Преобразователь соблюдает диапазон назначения: `u16(256) → u8` не означает молчаливое обёртывание. Отказ обрабатывается обычным механизмом отказов.

<a id="admission-case-13"></a>
### 13. Значение широкой таблицы преобразователей

Дополнительные преобразователи расширяют доступные явные преобразования листьев, но не меняют требуемые пути и интерфейсы callable.

<a id="admission-case-14"></a>
### 14. Корректность внешнего ресурса

Тонкий дескриптор не доказывает действительность ресурса и право доступа; эти свойства задаются контрактом обёртки и проверками Consumer.

<a id="construction"></a>
## 9. Построение значений

Source notation constructs the complete graph of written forms: declarations, values and executable expressions remain together. **All receivers remain as written. All computation and transformation take place in the namespace.** Terminal primitive declarations are included in that complete reflection in their direct `{type value}` form, with names in the ordinary name table. An uninitialized primitive contains its `uninit:T` code and zero value bytes; no T cell is reserved. A computed RHS is not terminal and is not folded by running the program. A modifier, call, `import`, `copy` or `merge` record is not replaced in the source graph by its result. Copying may construct new result nodes under the [graph-copying contract](#composition), and explicit program writes retain their own graph-mutation contract.

Ordinary indentation and explicit trailers close forms according to the [grammar](LMX_grammar.ru.md#levels). A blank physical line outside escaped content closes **all** open vertical and short forms to the current document root, as a terminator at virtual level −1. Its indentation is irrelevant; a single newline between nonblank lines is not this event. The root survives and subsequent forms begin there. A blank line creates no field, empty Structure, executable instruction or return; it does not synthesize missing paired delimiters. Within Mix it closes the local Mix document's block, not the surrounding document or its `}`. EOF still closes a completed ordinary block. Generated source must put blank lines only at intended full boundaries.

Constructing a body description does not execute it. A named Structure is declared in a data context; a headed form in code calls its resolved head. An anonymous body executes only under its receiving contract. Lexical parenthood follows written structure and the explicit copying/qualification rules, independently of storage ownership. No hidden procedure, second authoritative graph or persistent namespace is created. Names and retained comments follow [§4](#fields); comments do not execute.

### Разрешение головы и роль хвоста

A receiver applies its declared contract to the written tail: it may declare a place, describe a signature, consume a code body, or produce a value or field stream. Frame syntax alone does not determine those roles. A name consumed as a name is not called: `catch: merge ()` supplies a failure name and parameter description, and `fn: SumSignature (int: a; int: b; return: int)` supplies a signature name and data template. Both use the common parser and resolution mechanism.

<a id="resolved-head-consumption"></a>
#### Одна модель, одно разрешение, одно потребление

First, the complete written structural head/arguments model is formed in translator memory, without knowing what the head denotes. Neither its name, signature, nor entity category determines that model's boundaries or permits collecting additional arguments. Only after the model has been formed is the form read by the role of the Structure in the launch ([the roles `data` and `code`](#data-code-roles)) and the resolved receiver contract. An ordinary DATA form declares a Structure; a place-declaration receiver declares a place. A CODE headed form is a call. Receivers such as `import`, `copy` and `merge` retain their own argument and field-stream contracts when their written records occur in DATA. In every case, the common resolution algorithm in the single namespace finds the head: a receiver, a callable or a Structure. Such a form does not write a value into a known place ([structural forms](#forms-declare-or-call)). One common consumption mechanism applies the resolved entity's contract; differing contracts do not create separate parsers, namespaces, or resolution routes.

<a id="data-code-roles"></a>
### Роли `data` и `code`

DATA and CODE name semantic roles, not new keywords or permanent kinds of Structure. For a selected executable Structure `C`, CODE is `C` and DATA is its actual `parent(C)`, where present. `call(C)` and `C()` execute that occurrence without explicit actuals; `call(A C)` and a by-name call with the same selected actuals execute it with arguments `A`. A call cannot substitute another DATA. R0 is an entry without DATA or user actuals ([structural call](#call-receivers), [root entry](#root-entry)).

In DATA, an ordinary headed structural form declares a Structure with its written content. Thus `S()` declares an empty `S`, `S(D)` contains the reference atom `D`, and an `if:` record remains a Structure addressed through its head. Place-declaration receivers such as `int` and `@` instead declare their respective places through the namespace. An assignment `:=` is retained source material and is not executed merely because it occurs in DATA. Repeated DATA declarations remain separate occurrences; ordinary repeated-declaration and occurrence-selection rules apply.

In CODE, a headed form applies its resolved head. `S(args)`, `S: args` and its vertical form execute `S` with the selected actuals; they do not assign to `S` or declare a new Structure. A declaration receiver such as `int: i 6` establishes or updates its logical place under the receiver's contract. A numeric or null head is not callable. A call used for its value must have an admitted result described by `return` in its actual DATA. Bare `S` is a reference and does not call it.

These role rules are applied by the resolved receiving contract. In particular, a [place-declaration receiver supplied as a CODE argument](#declaration-arguments) is read as DATA and preserves its form. This does not change an ordinary `Producer()` or `Producer: tail` into a declaration: its head is an ordinary callable, so it remains a CODE call.

`import`, `copy` and `merge` always consume standard CODE arguments through the common translator algorithm, whether their receiver records occur in DATA or CODE. Ordinary W/E selection applies wherever these arguments are consumed. A bare Structure reference or an anonymous Structure supplied as a source is not itself a call. Its contents may contain calls or initializers governed by their ordinary consuming contracts; the group neither quotes them nor forces them all early. An explicit `Producer()` is a call when that receiver is consumed. Their selected or computed fields are consumed through the namespace; the source forms remain intact. For example, DATA `Struct: merge(A B)` is an ordinary declaration of `Struct` containing a receiver record; `merge` supplies a field stream for that DATA reading. The declaration is made by `Struct:`, not by a special merge-declaration syntax. Multiple such operations are independent, and `Struct` is never an implicit merge source or model ([composition](#composition), [import](#import-receiver)).

<a id="data-root-declaration-execution"></a>
#### Прямой проход по данным и выполнение ресивера

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
### Объявление места: ресивер и его аргументы

A place with a requirement is declared by the receiver's own argument form: `int: i 5`, `int: x`, `@: ptr 0`, `@: ptr Model`. Its first argument names the place; a primitive receiver without a value declares typed absence, while the corresponding value-check form can check a primitive literal. P0 builds the same ordinary Frames; arity and field roles come from the resolved receiver.

The composed form `name: receiver: value` does not declare a variable named by the outer head. In DATA, `timeout: ms: int: time 500` declares timeout containing ms containing the primitive time; its path is `timeout\ms\time`. In CODE the same outer form calls timeout. Likewise `i: int: 5` in DATA is a Structure i containing the receiver form, not an int variable i; in CODE it applies i and is invalid if i is a noncallable numeric place. Declaring a primitive or reference is done with its receiver, not by replacing that receiver's parent. `:=` assigns an existing place; it does not declare one.

A bare atom does not add an unwritten receiver or callable invocation. If the resolved field contains a computed declaration, an explicit path reads the record of the declaration and executes nothing ([explicit path](#path-reads-no-execution)); the written expression is evaluated by a call when it reads its local place by a bare name, and that does not call the returned callable with no arguments. The expression is formed and evaluated the same way whether its result is consumed or not; a write into a place is an effect of an unconsumed declaring form, not a special parse of the right operand. Thus `Model: 0` consumed by another expression does not change `Model`: in arguments it is a call of `Model` -- formerly it yielded a candidate under the requirement `Model`, now the requirement and the candidate are written flat, `@: ptr Model 0` ([the roles `data` and `code`](#data-code-roles)); if `Model` is a Structure, this is its call with the argument `0`, and at a place where a value is needed (an operand of an expression, an actual argument of a call, an initial value, an operand of `merge`) it yields a value only if the data of `Model` describe a result by the field `return` ([`return` in DATA](#return-in-data)); as a statement of its own, `Model: 0` still calls the selected Structure under its ordinary argument contract and discards any unconsumed result. If `Model` is instead a noncallable primitive place, the form is an error; in neither case does the colon assign ([structural forms](#forms-declare-or-call)).

Two-field `int: x 5` declares place `x` with an `int` requirement and value `5`: in data it creates the place, in code it is a call of the receiver -- a check of the type with an assignment to the local namespace place `x` ([the roles `data` and `code`](#data-code-roles)). Unary `int: x` describes place `x` with an `int` requirement and no invented initial value: a first definition creates the place; with an already known `x` the same form in code checks its compatibility by ordinary admission without a new write or second field, and in data it stays one more occurrence of the name, which is addressed only with the index of an occurrence after that. An uninitialized graph place contains only the distinct type code `uninit:int`, with `sizeof(value) = 0`, not a reserved int cell, numeric zero or an external initialization mark; every primitive has such a type, alike in code, data and a signature, where it distinguishes a formal without a default `int: q` from the default `int: q 0`: such a formal is not mandatory -- an input without a value, to which no value is supplied, does not make the call refuse: it is filled by [autofill](#binding-autofill), and where that is inapplicable it holds this type (the author's decision of 2026-11-16), and the receiver [`required`](#required-receiver) checks that a given field is initialized; the latest [author clarification](TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md) specifies that explicit graph assignment (`D\a := 5`) replaces the fragment at that structural place: `{uninit_int}` becomes `{int 5}`. It does not retag a preallocated T cell, require in-place expansion, or preserve a raw payload address across replacement ([L2 §3.1](L2_spec_ru.md#uninit-record-control)). An assignment to a local of the call -- `a := 5` for a formal that received no value -- writes into the place of the call: the graph does not change and the data are not published. The absence of a value is written as a value of that separate type: `nil: T` (`nil: int`; any other primitive type in place of `int`), and simply `nil` where possible. `int: var` declares a variable without initialization, and a separate type exists for that; it was introduced for passing arguments and stays needed with `required`. A variable can be compared with `nil` by its absence state; no numeric sentinel or imaginary value bytes are introduced. The graph holds nothing but Structures and primitives: a primitive is the declaration of its type with a value or with the absence of a value, and everything else is written as Structures. The null pointer stays `0` where that is possible; a pointer declared without a value (`@: ptr`) is not zero and is written with the same `nil` (the author's decision of 2026-11-17). Every receiver that used to be written without arguments in the place of a type has a one-argument form: `int: i` is written instead of `i: int` (the author's decision of 2026-11-10). With `i` already declared, `int: i` in code is not an error but a check that the type conforms: repeated declarations are allowed. The one-argument form given the primitive itself instead of a name, `int: 54554878477838734`, returns the number in an expression or throws a failure that `catch` receives. In a signature these forms describe a formal, and a written value supplies a default when an actual argument is absent; describing a formal does not execute it as a body. This is one mechanism for primitives, references, Structures, and callables, with no parser branch for a receiver's name. The constructed source graph fixes its physical slots until an explicit graph operation changes them. Logical namespace places and bare-name visibility follow sequential declarations, lexical scopes and explicit receiver-stream consumption; reaching a branch does not append a hidden slot to the source `Lmx`.

The declaring contract of built-in value/type receivers, including `int` and `@`, is `R: name value`: the first field is an atom naming the receiving place, and the second is a value or requirement expression, while `@` with a requirement has an optional third field, the candidate (`@: ptr Model Other`); without the second field the place is declared with no initial value. The resolved receiver's contract determines arity and field roles after P0; the parser neither singles out this class nor changes the tree, and other receivers retain their own argument contracts. The name atom is neither called nor evaluated as a value: the place is resolved in the same namespace as a Frame head. The candidate is evaluated once before any write, undergoes ordinary admission, and then the place is first defined or, when it is already known, receives the value in code as a repeated declaration: enumerating a receiver's arguments remains that receiver's business and can always be a declaration — `@: ptr1 ptr2` may declare `ptr1` (author's clarification of 2026-11-10, [structural forms](#forms-declare-or-call)); in data a repeated declaration does not write into the former place and stays one more occurrence of the name ([the roles `data` and `code`](#data-code-roles)). Consumption of the entire form by another expression does not itself publish a field or perform a write. `@: new_field Model` binds the reference to `Model` without requiring prefix address-taking.

Требование и кандидат записываются плоско: в `@: ptr Model Other` у `@` три поля — атом места `ptr`, требование `Model` и кандидат `Other`; нулевой адрес даёт `@: ptr Model 0`. Вложенная форма `@: ptr Model: Other` для этого не служит: аргументы ресивера читаются как код, и `Model: Other` в них — вызов `Model` с аргументом `Other` (решение 2026-11-11, [роли `data` и `code`](#data-code-roles)), а не требование с кандидатом; прежде потреблённый `Model: Other` давал кандидата `Other` с требованием `Model`. Допуск кандидата не записывает в `Model` и не создаёт адресуемой временной ячейки. После допуска форма строит ссылочное значение и связывает `ptr` по общему правилу; кандидат вычисляется один раз до записи. Если `ptr` callable, форма ресивера `@` обозначает место связывания `ptr` и подчиняется ограничениям записи в него, а запись `ptr: @: Model Other` в коде — вызов `ptr` с аргументом.

В позиции вычисления голый идентификатор проходит тот же поток разрешения, но сам не образует вызов и не передаёт пустой список аргументов. Он обозначает разрешённое значение, ссылку на Structure или callable либо имя ресивера по контракту принимающей позиции; голые `merge` и `int` также не исполняются. Если позиция требует значения, которого обозначенная сущность не предоставляет, это ошибка, а не скрытый нульарный вызов или свободный вход. Для применения разрешённой головы нужен явный Frame с `()` либо `:` и структурным хвостом, в том числе пустым; роль этого Frame по-прежнему определяет контракт головы. Исполнение именованной Structure записывается ресивером `call: A` или, в коде, записью с её именем в голове, `A()` или `A(args)` ([роли `data` и `code`](#data-code-roles)). Соседние атомы не захватываются. В `if: p` голое `p` только читается: даже если оно указывает на метод, метод не вызывается. Допустимость самого значения `p` как условия этим правилом не определяется.


<a id="colon-declares"></a>
In DATA, an ordinary `Name: tail` declares a Structure whose content is that tail. `Struct1: Struct2` contains one reference atom to the existing Struct2: it neither makes the two names equal nor copies or expands Struct2's fields. Its parent is unchanged, so a path such as `Struct1\Struct2\a` reaches the original target. In `Struct1: (Struct2 a b c)` the written group remains one anonymous Structure; its own a and the a reached through Struct2 are different fields. Cyclic references such as `A: B` and `B: A` are not infinitely expanded. An unresolved atom remains a word.

A structural name is a constant binding. `Struct1 := Struct2` does not reassign it. A mutable reference is instead declared by `@: ptr Model`, may explicitly receive null by `@: ptr Model 0`, and is later updated by `ptr := Other`. The atom's physical slot remains accessible by ordinary indexed graph operations; that does not make its bare name an assignable variable. Repeating a DATA declaration preserves another occurrence and requires ordinary occurrence selection. In CODE the corresponding `Name: tail` or `Name(args)` is a call, not a declaration or assignment. Reference passing does not reparent its target or capture its caller.

В данных структурная форма объявляет Structure, хвост — её содержимое: `A(int: x 1)` и `A: int: x 1` объявляют `A` с полем `x`. Пустые `A()` и `A:` объявляют Structure без полей. `A: ()` объявляет `A`, внутри которой одна пустая безымянная Structure, а `A: (int: x 1)` — `A`, внутри которой безымянная Structure с полем `x`: единственную Structure в хвосте P0 не раскрывает ([значения](#values)). Голое `A` читает ссылку на уже выбранную обычную Structure. Если `A` уже объявлена на этом уровне, повторная структурная форма, включая пустую, — повторное объявление, а не присваивание: ещё одно вхождение имени `A`, которое после этого адресуется только с индексом вхождения; в данных вызова прежней `A` нет. В исполняемом коде описания Structure нет — такая запись там вызов своей головы; собственная область возникает при вызове Structure — явным `call` или записью `A()`. Inline-операторы `if`/`for` остаются в той же активации. Именованные Structure и callable видны в обе стороны; переменные, включая const, — последовательно от первоначального объявления в своём блоке и ниже. Корневые входы data доступны исполняемому code; подготовка namespace не открывает будущие локалы code и не вычисляет инициализаторы ([видимость](#declaration-visibility), [кадры вызова](#call-frame-20261115)). Форма с путём в голове, `Outer\Model()` или `Outer\Model:`, в коде — вызов того, что стоит по этому пути; голый `Outer\Model` читает ссылку без вызова. Для исполнения выбранной обычной Structure служит `call: Outer\Model` или, в коде, запись `Outer\Model()`.

<a id="ordinary-var"></a>
### Имя `data`

The name `data` is an ordinary user name and the descriptive name of a semantic role. It is not an implicit reference to a call's DATA and cannot rebind that DATA. The selected code C uses actual `parent(C)`; an explicit path `D\x` addresses that known Structure, while `node\x` explicitly selects the established lexical context. These expressions are not interchangeable merely because a receiver is currently reading DATA. If a variable named data is declared, `data := ptr` has only its ordinary assignment meaning. A headed `data(...)` form follows the same role rules as any other user head:

| Где стоит запись `data(...)` | Действие |
| --- | --- |
| В данных, имя ещё не объявлено | Объявить обычную Structure `data` с записанным содержимым. |
| В данных, имя уже объявлено | Повторное объявление: ещё одно вхождение имени, которое после этого адресуется с индексом вхождения; это не замена и не присваивание. |
| В коде | Вызов головы по общим правилам ([структурный вызов](#call-receivers)): если `data` называет Structure, она исполняется; если голова ничего не называет, запись ошибочна. |

Historical note: earlier specifications used a reserved data reference and allowed a separate DATA argument on call. Both are withdrawn. Migration must choose the actual structural occurrence and its parent; it cannot restore the former behavior by renaming a variable.

В данных последовательность `data(int: x 2); data(int: x 5)` — два объявления: два вхождения имени `data`, каждое со своим содержимым; второе первого не заменяет и в него не пишет. Объявление, первое или повторное, само по себе не исполняет содержимое Structure: её исполнение задаёт запуск — явный `call` или, в коде, запись с именем этой Structure в голове, `A()` либо `A(args)`. В исполняемом `code` имя `data` пользуется общими правилами имён и мест, без особого алгоритма.

In this chapter DATA names the role of actual `parent(C)`, while a user name `data` follows ordinary resolution. `call` has no separate data argument: `call(C)` and `call(A C)` execute the selected `C` over `parent(C)`, and `A` is its actual arguments ([structural call](#call-receivers)). A call creates a local namespace without appending code places to the source graph. An ordinary Structure in code is launched also by a form with its name as the head -- `A()` and `A(args)`; this is a form of its own, not a form of a receiver, and its arguments are supplied by the general rules ([structural forms](#forms-declare-or-call)). A form `data(...)` in data declares a Structure under the same rules as any other declaration; this does not launch the Structure's content. Bare atom `data`, like any bare atom, only names what stands under that name and invokes nothing, including when a method reference stands in its place.

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
### Явное копирование и указатели-переменные

The reference receiver uses ordinary declaring forms. `@: ptr` creates an uninitialized reference place; `@: ptr 0` supplies null. `@: ptr Model` retains a reference to Model, and `@: ptr Model Other` explicitly supplies a requirement and a candidate. Requirement and candidate are flat arguments. In a CODE-reading position, nested `Model: Other` is an ordinary call, which must produce an admitted result if a value is demanded; it is not an alternative requirement/candidate notation. DATA-reading and passed-declaration positions retain their own contracts.

A repeated declaration at the same CODE level with no new candidate checks the existing place without clearing its value. A supplied candidate follows ordinary conversion/admission before the write. Address assignment does not retroactively type an already declared void-reference place. The outer form `ptr: @: Model` instead declares a Structure in DATA or calls ptr in CODE; it is not a reference-variable declaration. These are resolved receiver contracts after the common parser.

Explicit [copy and merge](#composition) produce field streams. `copy(A)` has one admitted source; `merge(A C)` has at least two. To retain one structural value in a reference variable, write `@: b (copy(A))` or `@: b (merge(A C))`; assignment to an existing reference likewise uses `b := (merge(A C))`. The destination is never a source or model. Without the group, the RHS remains a stream and its admissibility follows the receiving contract; it is neither automatically one container nor universally a syntax error.

In DATA, `b: merge(A C)` ordinarily declares `b`, and the enclosed receiver supplies fields through that DATA namespace. In CODE the same outer form calls `b` with the stream supplied by `merge`. A bare atom `merge` captures no neighboring fields: `b: merge A C` is not the same application. Ordinary references and unknown names do not trigger implicit copying. A grouped result retains its written boundary, although a subsequent CODE call may still consider W and E under [ordinary selection](#declaration-selection).

Ресивер `@:` принимает имя места своим первым полем; новое место и запись в уже существующее проходят один resolver и обычный [допуск](#admission). В сигнатуре тот же ресивер описывает требование к входу. Место кандидата определяется общим разрешением; после допуска обращения используют полученные адреса и карты, без повторного поиска имени по тексту. Известный указатель на метод `b` вызывается записью `b: args`, `b(args)` или `(\b)(args)`; `\b(args)` разыменовывает результат вызова по общему приоритету. Унарное `@b` отдельно адресует ячейку ссылки.

<a id="method-reference-assignment"></a>
Ссылка на метод присваивается через `@`, который стоит первым: `@: ptr method`. Первый аргумент `ptr` — атом имени места; второй, `method`, — атом, обозначающий значение метода. **Голый атом не является вызовом**, поэтому ни `ptr`, ни `method` здесь не вызываются. Ресивер `@` получает эти аргументы по своему двухполевому контракту: при первом определении создаётся ссылочное место, при уже объявленном — в коде после допуска присваивается новое значение в то же место, а в данных повторное объявление остаётся ещё одним вхождением имени ([имена и пути](#fields)). `@: ptr 0` аналогично передаёт явный нулевой кандидат. У `ptr(args)` или `ptr: args`, напротив, есть явное применение callable к аргументам; если `ptr` держит ссылку на обычную Structure, те же записи запускают её по формам запуска Structure ([структурные формы](#forms-declare-or-call)). Запись `ptr: @: method` присваиванием не является, каким бы ни был `ptr`: в коде она — вызов `ptr`, в данных — объявление Structure `ptr` ([роли `data` и `code`](#data-code-roles)); `@` во вложенном аргументе этого не меняет, и для присваивания служит форма `@: ptr method`.

Unary `@ptr` selects the address of the variable cell ptr, distinct from its stored target reference; it is not the assignment `@: ptr method` and does not replace the stored method reference with its cell address. An explicitly supplied argument, an autofilled value and a value of the former binding (the fallback) have their own local activation cells: `@x` addresses the same local variable that bare `x` reads and writes. Where the selected level admits dereferencing this numeric address, after a local `x := 9`, reading `\(@x)` yields `9`; writing through that address changes its own cell, not the binding's source ([own place](#binding-places), [autofill](#binding-autofill), [former binding](#binding-fallback)). If the name is bound as a transparent caller place ([caller's place](#binding-caller-place)), then `x`, `x := 9` and `@x` act on that place at once: `@x` is the address of the caller's place, and the write is visible to the caller without copying back. An external place is addressed explicitly, for example `@(node\x)`. Taking an address does not extend cell lifetime; an object reference and the variable cell holding it are distinct.

Candidate conversion and admission follow the receiving contract; reference storage changes only after successful reception. Ordinary Structure and method values already travel by reference: `@: ptr Struct` retains that ordinary reference without invoking `Struct`. Prefix `@Struct` explicitly obtains its numeric address, as in `int: value 1 + @Struct` where numeric addresses are admitted by the profile; it is not required to pass `Struct` and does not suppress an operator role. Prefix `@x` on a variable selects the real logical variable cell chosen by binding, including the caller's cell for a transparent binding. It must not accidentally address only the object stored in a reference variable or an ABI transport box. Machine-address operations retain the applicable [L2 contract](L2_spec_ru.md#lowlevel-address). Taking an address extends no lifetime, and dereference `\` follows an admitted address/reference without executing code.

### Сигнатура не исполняется

A named `fn: name data` signature describes ordered input types and, where there is a result, the field `return`; the forms written in it are not executed as the body of a callable. Both arguments of `fn` are read in the data role, and its nested records only describe ([`fn` signature](#fn-signature)); the description of inputs in the data of a called Structure is arranged the same way ([structural call](#call-receivers)). Input places are described by declarations by receivers. For nonprimitive `A`, a formal requiring `A` is written `@: p A`, admits a candidate through `implements(c, A, Consumer)` and transports its descriptor reference without copying or implicit `merge`. Value and reference requirements are written with the same receiver forms as in a body, but describing a formal does not assign a place while the callable is built. A value written in the description is a default, not a result of executing the body.

For structural `c`, `mytest(c)` passes its ordinary reference, while `mytest(@c)` explicitly obtains an address under the prefix-@ contract; these are not interchangeable arguments. No extra level is removed to fit a formal. This applies equally to a Structure, a pointer variable and a nonprimitive formal; the target is its own language storage, not a transport-ABI box. A primitive value and a reference to its cell are not synonyms either. Passing and returning nonprimitives never use C by-value aggregates.

### Присваивание и места объявления

In code, re-declaring a variable already declared at the same level retains its type check, RHS computation, and assignment, but creates no second C variable. Executing `int: i 5; int: i 6` uses one local place. Both written forms remain in the source graph; local execution does not overwrite them. In data, a repeated declaration remains a separate named occurrence selected by index. New branch names are visible inside that branch and below; a repeated form at the same level uses the existing place, while a declaration at a nested level shadows the outer one of the same name ([declaration levels](#shadowing-levels)). A structural `name:...` form in code calls its head; `:=` assigns without declaring.


Входы вызываемой Structure — объявленные места её данных — и собственные переменные code — локальные места активации: присваивание им не пишет в исходный граф и не пишет вызывающему — ни явно поданное значение, ни автозаполненное, ни копия прежнего связывания не являются псевдонимом источника ([собственное место](#binding-places), [прежнее связывание](#binding-fallback)). Иначе у внешнего имени без собственного объявления: если оно связано как прозрачное место вызывающего, присваивание действует на место вызывающего сразу, без копирования обратно ([место вызывающего](#binding-caller-place)). Оператор объявления остаётся в code. Описание входов в данных не исполняет их вычисляемые инициализаторы при построении графа. См. [кадры](#call-frame-20261115).

<a id="forms-declare-or-call"></a>
#### Структурные формы объявляют или вызывают

A headed structural form—parenthesized, short, or vertical—applies the same resolved contract. Ordinary DATA forms declare Structures; CODE forms call their heads; declaration receivers declare or update their places. A structural form is not an assignment merely because its head names an existing place: `i: 6` cannot update a numeric i. Use `i := 6` or a reached same-level receiver declaration such as `int: i 6`. The latter retains type checking, RHS computation and assignment while creating no second logical place.

Root DATA inputs are available to the selected CODE; CODE variables and constants retain sequential visibility. True nested declarations shadow outer places. The source graph retains both written receiver occurrences, and CODE locals do not become source DATA fields. P0 does not classify a head or invent a different tree to implement these rules.

In CODE, `A()`, `A(args)`, `A: args` and a corresponding vertical form launch the resolved Structure A. They use actual `parent(A)` as DATA and the ordinary selection of explicit actuals. An unknown, numeric or null head cannot be used as an ordinary callable. `call(A)` and `call(X A)` are the explicit receiver forms with the same selected actuals; the receiver does not choose a child body automatically. In DATA, `A()` declares empty A and `A(args)` declares its written content without invoking a prior A. A single written Structure actual may have W and E readings only under the [CODE call-selection contract](#declaration-selection).

Повторные объявления разрешены. Исполнение повторного ресивера переменной сохраняет его действия, включая `bump()` в `int: x bump()`. Графовые объявления одноимённых полей не сливаются. Запись `Struct1: Struct2` в данных объявляет Structure с атомом-ссылкой на Struct2, а не копирует её поля; в коде вызывает голову Struct1. Форма `b(args)` вызывает то, на что указывает b, если это вызываемое или Structure. Число или пустая ссылка не становятся вызываемыми. Двоеточие не заменяет `:=`. Вызов не дописывает места в исходные данные и код: новые места code существуют в namespace вызова по [общему правилу](#call-frame-20261115).

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

Each written container is one operand: `(foo A)` with an Array `A` gives one reference in `right`, and `(A foo B C)` gives one left and two right references. No general Array/string expansion is introduced. The ordinary single-Structure W/E rule keeps its defined call-selection scope. `a foo b` cannot be textually replaced by `foo(a; b)`, because the second operator input is an Array of references.

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

These expression rules are specified in full by the supplied [operand requirements](TZ/to_fable_operands_arguments_priorities.md).

<a id="assign-known"></a>
#### Запись в известное место: `:=`

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
[author clarification](TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

<a id="compound-assign"></a>
#### Составные присваивания и степень

The compound assignments `+=`, `-=`, `*=`, `/=`, `%=`, `<<=`, `>>=`, `&=`, `^=`, `|=`, `**=` and the power operator `**` for expressions join `:=`. A compound assignment writes a place already known with the result of the operation over its current value and the right operand: `a += b` corresponds to `a := (a + b)`, `a -= b` to `a := (a - b)`, `a *= b` to `a := (a * b)`, `a /= b` to `a := (a / b)`, `a %= b` to `a := (a % b)`, `a <<= b` to `a := (a << b)`, `a >>= b` to `a := (a >> b)`, `a &= b` to `a := (a & b)`, `a ^= b` to `a := (a ^ b)`, `a |= b` to `a := (a | b)`, `a **= b` to `a := (a ** b)`; the author's spelling of these equivalences with a C-like `=` is kept in the journal, and in LMX `=` stays a comparison. The left side is a place already known under every rule of `:=`, the `implements` admission and the error of an unknown left side included; `:=` keeps its general narrow meaning of writing a known place, method references and the named supply included, and is not narrowed to numbers. `**` is the power; `^` stays the bitwise exclusive or. The associativity and precedence of `**` are Python's (the author's clarification of 2026-11-07): `**` groups to the right -- `a ** b ** c` is `a ** (b ** c)`; it binds tighter than `*`, `/`, `%`, `+` and `-`; a call, an index and a field access form the operand before `**`; on its left `**` binds tighter than the unary `+`, `-`, `~`, on its right a unary operand is admitted -- `-2 ** 2` is `-(2 ** 2)`, `(-2) ** 2` keeps its parentheses, `2 ** -2` is `2 ** (-2)`, `2 * 3 ** 2` is `2 * (3 ** 2)`; the right side of `**=` groups the same way. Grouping and execution are distinct: reached effects follow the common LMX demand and written-order rules, not C's unspecified operand order. A compound assignment evaluates its destination once and obtains the operation result before the write; the equivalences are not textual macros that repeat destination effects. Numeric types and conversions of `**` and `**=`, negative or fractional exponents, `0 ** 0`, numeric failures and atomicity follow the selected numeric and write contracts. Only power grouping is taken from Python; no other Python numeric policy is implied. Implementation must preserve these results on each supported execution path; this specification is not an implementation report.

<a id="group-assign"></a>
#### Групповое позиционное присваивание

Author's decisions of 2026-11-10. The left side of the `:=` operator may be an unnamed Structure of places: `(a b c) := (c, a, b)` assigns by position — the first value to the first place, the second to the second, the third to the third. The author first wrote this form with a colon, `(a b c): c, a, b`; after the rule that structural forms do not assign ([structural forms](#forms-declare-or-call)) it is written with `:=`, and a Structure as the head of a Frame before a colon is not introduced. All right-hand values are computed before the first write, so this statement rotates the three values. Each position is written by the rules of `:=`: the place must be available at the assignment site under the [common visibility rule](#declaration-visibility). Variables and `const` are visible sequentially; grouping does not change that rule. An explicit path selects a field under the ordinary path rules; this does not make its bare name visible before declaration. For name-based access, an unknown name, the name of a Structure or a function name on the left is an error, and each value passes the ordinary admission of its place. When the right side is one call whose result is a Structure, the places receive its fields by position, and the names of the result's fields are not compared: `(a, b, c) := myFn()` ([Structure result](#structure-result)). This is an assignment between unnamed Structures, the general case of assignment and not a special form (the author's decision of 2026-11-16). A different number of places and values is a refusal: at translation when the number is known, otherwise at execution before the first write. A Structure on the left holds at least one place; the head `()` with empty parentheses remains the earlier separate form ([grammar](LMX_grammar.ru.md#bounded)). The same mechanism consumes field streams, for example `(a b) := copy(Pair)`, assigning the two resulting fields by position. In `(c b d a) := a b c d`, starting from a=1, b=2, c=3, d=4, the final values are c=1, b=2, d=3, a=4. All RHS values precede the first write; this promises no rollback of effects already produced while computing them.

<a id="qualification"></a>
## 10. const, immutable и independent

`const` защищает привязку: её нельзя присвоить, перепривязать или заменить. Значение за защищённой ссылкой может оставаться изменяемым. `immutable` защищает само значение на протяжении всей его жизни, через любые псевдонимы; переменная, содержащая ссылку на него, может оставаться перепривязываемой. `const: immutable` объединяет обе гарантии. Это независимые квалификации, а не ступени одной шкалы.

Неизменяемость применима к примитиву, Structure и выбранному дереву, Array с дескриптором и элементами. Она охватывает все поля и явно включённые описания, а не только пути Consumer. Передача, возврат и сохранение неизменяемого значения сохраняют его идентичность; квалификация не требует копии, в том числе для примитива. Она не замораживает внешний ресурс, обозначенный неизменяемым идентификатором.

`immutable` задаёт надтип нового значения при построении до публикации: записи получают коды соответствующих immutable-типов. Обычная уже построенная Structure, запись которой держит код изменяемой Structure, не переводится задним числом в immutable-тип: попытка `immutable: Existing` с таким значением получает отказ при потреблении. Это снимает прежнее обещание `RuntimeImmutable` переквалифицировать существующее дерево без смены адреса. Уже immutable-значение может проходить как значение своего типа без повторной переквалификации. Допуск аргумента остаётся [единым](#admission), как у прочих принимающих выражений.

Перед публикацией нового immutable-значения исследуется всё выбранное дерево. Вложенная структура является ветвью дерева только тогда, когда её обычное структурное поле `parent` указывает на рассматриваемого родителя. Внешняя ссылка, **уже сохранённая как значение данных**, допустима только на уже неизменяемый объект; она терминальна, её цель не обходится и не переквалифицируется. Собственный `parent` корня — структурная лексическая связь с узлом вне выбранного дерева, а не такая сохранённая ссылка: `immutable` без `independent` строит значение под его обычным родителем, которого не замораживает и неизменяемости которого не требует; `independent` — единственный ресивер, касающийся этой связи. Операнд сохранённого исполняемого кода до его выполнения ещё не является таким значением (см. ниже). Проверяется состояние до публикации: результат обработки раннего поля не может оправдать недопустимую внешнюю ссылку в позднем. Если исходное объявление `immutable` нарушает это условие, транслятор отказывает в построении; даже при интерпретации граф сначала строится, и такой отказ не является исключением исполняемого тела. Если же ошибка обнаружена при исполняемой операции над уже существующим деревом, интерпретатор передаёт её обычным `throw`, который обрабатывается обычным `catch`, без особого канала для `immutable`. Ни один из этих случаев не превращается в `sys\assert`.

Qualification checks values and references already stored in the tree. Ready terminal declarations are represented directly during clean-graph construction without program execution; a computed initializer is not an already stored result. Qualification does not execute it. Its result is checked when actually obtained and consumed under the ordinary contract, without predicting future body behavior. This is the same for data and code. An immutable Structure can hold code that later reads mutable data without freezing that data.

Примитивы и методы — листья, не ветви лексического дерева. Это правило описывает топологию `parent`, а не освобождает от проверки изменяемое хранилище, физически удерживаемое квалифицированным графом: сохранённая запись кода метода и уже сохранённые данные должны удовлетворять контракту неизменяемого построения. Отложенные операнды являются кодом, а не своими возможными будущими значениями; ячейки последующей активации эта проверка не замораживает. Ссылка на массив также не создаёт ветвь `parent`: операция над деревом не замораживает неявно изменяемое хранилище внешнего массива. Неизменяемый массив строится по собственному контракту. Принадлежность ячейки служебному пулу не даёт права обходить или квалифицировать весь пул.

Квалификация нового значения завершается только после успешной полной предварительной проверки. При неудаче нет частично опубликованного immutable-дерева или успешного результата; запрещено молча пропускать ветвь, копировать уже существующий обычный объект ради смены его типа или перенаправлять ссылки. Уже immutable-значение не нуждается в повторной квалификации. Правило не откатывает ранее выполненные инициализаторы, вычисление аргументов или явные записи в граф; транзакция графа не возникает.

Protection applies to actual writes to protected values; local frames are never published into the graph. The immutable receiver checks the constructed value and stored references under the rules above; it neither predicts writes by future execution of the saved body nor requires proof of their absence. Such analysis is not performed outside an explicitly written test. If a reached write targets a protected place, the shared runtime mechanism refuses before changing that place. This applies both to its own saved body and to external code. Calling a method does not remove protection. Changing a local argument copy or rebinding a local reference does not change the protected value. Constructing a new value, including merge, does not thaw the original. See the author clarification of November 1.

`independent` при построении устанавливает у корня `parent = 0`; это и есть отсутствие внешнего лексического родителя. Внутренние связи `parent` дерева и собственные поля сохраняются. Квалификация не обнуляет задним числом `parent` уже существующих объектов и не запрещает явно переданные ссылки, динамические аргументы текущего вызывающего выражения, сообщения или выбор вызываемого выражения по совместимой сигнатуре. Это не требование чистоты и не закрытый интерфейс только из явных аргументов.

`const`, `immutable` and `independent` are receiving expressions; their composition establishes the result's qualified type. The action of each needs one argument, so several arguments may be written and the action applies to each in turn, in the written order: in `const: int: a 1; int: b 2`, in `const(int: a 1; int: b 2)` and in a block under `const:` with two declarations there are two arguments, and that is the same as two forms with one argument each. How many arguments are passed and what they are is determined by the form under the general rules of parsing, not by the presence of parentheses. [`private`](#private-binding) and [`required`](#required-receiver) are written the same way (the author's clarifications of 2026-11-18). These receivers take their arguments as `data`, so an argument that is itself a Structure is not unwrapped: in `const: (int: a 1; int: b 2)` and in a block under `const:` where one anonymous Structure with these declarations is written there is one argument -- that Structure ([two kinds of receivers](#two-kinds-of-receivers); the author's clarification of 2026-11-18). `immutable` is a supertype determined when the value is built. Each base type has a corresponding immutable type code. Ordinary and immutable records are allocated by the same arena record-stream mechanism; immutable Structures do not require a separate pool, and user field models do not create new physical types. Qualifying one Structure does not affect unrelated values; every alias of a constructed immutable value sees the same supertype: the code in the value's record holds it. The value record is described in [L2](L2_spec_ru.md#value-record); this does not introduce a new type for every Structure model or an additional qualifier-specific name-binding table. A zero root `parent` remains the structural consequence of `independent`, not a replacement for type classification. As receiving expressions they stand wherever a Structure value is received -- a declaration's tail, a method's `return:`, a `merge` operand -- composed in the order and part the source writes, each with its own contract; the root-level chain over a named Structure is one case of that reading, not its definition.

Например, метод внутри независимой структуры S может использовать поле S через внутреннюю лексическую связь. Требуемое `x` может прийти из текущего вызывающего выражения. Если `x` находится только в прежнем текстовом окружении S, внешнего неявного доступа к нему нет. Явно переданный большой массив не становится меньше и не копируется из-за `independent`. Особый срок жизни сочетания трёх квалификаций описан в [вечных ветвях](#eternal).

<a id="execution"></a>
<a id="callables"></a>
## 11. Вызываемые выражения и их интерфейсы

<a id="declaration-visibility"></a>
### Declaration visibility

Variables, including `const`, are visible from their initial declaration onward at their lexical level and in nested scopes. Before that declaration, this local name does not participate in lookup; available outer and dynamic names follow the common rules. Names of named Structures and callables remain visible in both directions. A variable containing a callable pointer remains a variable. The rule governs head resolution and other name uses alike; brackets and trailers do not change it. The author's clarification.

Последовательная видимость голого имени не ограничивает явный выбор поля построенного графа: `D\field` (путь от Structure данных `D`), `S[n]` и `S\[n]field` используют обычную адресацию. Наличие поля в графе не означает, что его вычисляемое значение уже получено.

A call creates a new namespace. Preparation collects data and code root declarations: the data is `parent(C)` and the code is the executed `C` ([structural call](#call-receivers)). This includes explicit stream consumption under [the common namespace contract](#data-root-declaration-execution); it does not eagerly run computed place initializers or lift arbitrary nested declarations into the root. Data input places are available to the executing code as this call's inputs; collecting the code root does not make its future variables visible before their declarations. A new branch name is visible at its level and below, not outside. Re-declaring a name at the same level uses its existing local place; a supplied RHS retains evaluation, admission, and assignment. A declaration at a nested level creates its own place and shadows the outer one of the same name ([declaration levels](#shadowing-levels)).

Описание вызываемого — данные с общими правилами видимости и выбора повторных вхождений. Положение описания входов, поля `return` и кода не создаёт отдельного правила раннего вычисления. Входы сопоставляются namespace вызова без исполнения вычисляемых объявлений. Общий разбор не размечает роль поля по частному имени.

Файлы программы не образуют категорий «основной» и «часть»: message — Structure, подключённые файлы встраиваются в граф программы. Порядок объявления переменных и `const`, как и двусторонняя видимость именованных Structure и callable, определяется получившимся лексическим деревом. Сравнение смещений строк разных исходных документов видимость не определяет.

Сигнатура описывает входы и результат; она не является исполняемым телом ([сигнатура `fn`](#fn-signature)). Запись формала не выполняет вызов, объявление или присваивание, которое та же запись могла бы означать в теле. Формалы объявляются ресиверами — `int: arg default`, `@: arg Template`; структурная запись формал-переменную не объявляет: в роли данных она — объявление Structure (так записывается, например, структурный результат в поле `return`), и прежняя синонимия двух описаний формала в сигнатуре — структурной записью и ресивером — снята ([роли `data` и `code`](#data-code-roles)). Подача фактического аргумента выполняет предусмотренные контрактом преобразования и допуск, но не исполняет описание формала как оператор тела. Использование полученного параметра в теле разрешается по его контракту и общим правилам выражений, а не исполнением текста сигнатуры.

<a id="method-parts"></a>
### Части вызываемой Structure

The input places, requirements and defaults of executable C belong to actual `parent(C)`; its return description is the `return` field of that DATA. C itself is the code. `args` on call is actual supplied material, not a separate part of a function. `fn: name data` creates a named positional requirement and no implementation. Different supplied argument sets can produce different native signatures, while hidden service parameters do not become fn input positions. Catch retains its handler role with the same general input and actual-parent representation ([catch](#catch-common-model)).

Repeated physical DATA declarations retain distinct occurrences and may require indexed selection. Reached CODE receiver declarations at one level instead update the existing logical place. `call(C)` chooses C itself: it selects neither a child code field nor a child data field. These distinctions follow ordinary role and namespace rules rather than a separate call lookup.

A callable is an ordinary Structure selected for execution. Its DATA is its actual parent; a named signature is a separate requirement. Heads resolve through canonical names, and call preparation reads root declarations into a local namespace under [the common receiver contracts](#data-root-declaration-execution), including explicit field streams, without eagerly executing computed place initializers or completing the source graph with body locals. All receiver forms are retained, with terminal primitive declarations included in their direct typed-leaf representation; execution changes namespace places or explicitly addressed program data, not an implicit replacement graph.

Любая Structure исполняется в роли кода ресивером `call` или записью по имени в коде: `S()` равнозначно `call(S)`, `S(args)` — `call(A S)` при тех же выбранных фактических аргументах `A`; данными в обоих случаях служит `parent(S)` ([структурный вызов](#call-receivers)). Явные пути сохраняют исходный граф; локальные места подготавливаются в namespace по корневым объявлениям без дополнения графа. Внешние имена связываются по общему порядку ([связывание](#binding-places)) и не становятся полями данных по совпадению имени. `node` сохраняет прежний смысл. Общие правила повторных вхождений, ролей данных и кода и допуска действуют для всех форм; отдельного исполнительного пути нет. Подробнее — [кадр вызова](#call-frame-20261115).

A callable is just a Structure: the launch receiver does not select a part inside the Structure it is given -- `call(A s)` executes `s` itself, and the child `code` field is not searched for automatically (the author's decision of 2026-11-16; details -- [structural call](#call-receivers)). An ordinary declared input is optional unless constrained by input `required`: an input without a value, to which no value is supplied, does not make the call refuse; [autofill](#binding-autofill) fills it, and where that is inapplicable the input holds "T without initialization"; the receiver [`required`](#required-receiver) checks that a given field is initialized (the author's decision of 2026-11-16).

A structural form in executable code, including name:... end: name, calls its head; it neither declares nor assigns source data ([roles](#data-code-roles)). A data: block in executing code therefore also launches its head with its own tail in the place of the arguments; the name `data` has no special meaning ([what is withdrawn](#removed-builtins)). Data and code are described structurally: the code is written as a nested Structure inside its data, and the call selects that occurrence; a named definition does not itself execute its contents.

A variable-declaration receiver in code works with the call-local namespace: its initial declaration introduces a place, repeating the name at the same level preserves the RHS, admission and assignment to that place, and a declaration at a nested level creates its own place ([declaration levels](#shadowing-levels)). Nested if/for stays in the same activation; a new branch name is visible there and below, not outside. Neither nesting depth nor a missing same-named data field requires adding a graph field: code locals need not correspond to source data. Preparation considers data and code roots and their explicit stream contracts, without eagerly running computed place initializers or exposing future locals. Repeated physical data fields remain distinct occurrences selected explicitly by D\[N]y; D\y is ambiguous when repeated. The call contracts and ordinary admission of supplied inputs remain; this is not a requirement for D to contain all code locals. See [frames](#call-frame-20261115).

An explicit `call` uses the same fresh-namespace model. The root declarations of the data `D = parent(C)` provide inputs; the root declarations of `C` provide the remaining locals. Preparation uses [the common namespace and explicit stream contracts](#data-root-declaration-execution); it neither changes `D` or `C` nor executes computed place declarations early. Explicit paths from `D` and the path `code\` retain the original `D` and `C`.

Ни вход в вызов, ни запись в граф не обнуляют native. Локальная запись меняет только namespace, явная запись — исходный граф. Обновление машинного исполнения требует [явной компиляции](#explicit-compilation); один endturn его не выполняет.

An executable body is a structural expression. A declaration does not run it; a bare name denotes its reference; `A()` or `call(A)` explicitly executes it, subject to the common argument selection. `A()` has no written actual, whereas `A: ()` contains one empty Structure and follows the receiving contract. A result is described by the parent's `return` field; without that description the call supplies no result value. Declared throws and other call restrictions remain those of the candidate, not policies transferred from a fn template.

Голый `return` завершает исполнение без значения; `return: value` допустим лишь там, где результат описан полем `return` данных ([`return` в данных](#return-in-data)). На уровне открытия `return` также может быть trailer любой callable-Structure по общему правилу грамматики; для невызываемой Structure это не закрыватель. Явный `end: Name` не обязателен, а завершение тела без `return` не создаёт узел возврата.

Путь через Structure читает поле и не добавляет вызова выбранной Structure или callable. Вычисляемое объявление путь тоже не исполняет: он читает его запись ([явный путь](#path-reads-no-execution)). Путь от данных — `D\x` при `D = parent(M)` — адресует исходный граф; голое `x` и `@x` в вызове адресуют логическое место, выбранное связыванием ([связывание](#binding-places)). Собственное место вызова и поле графа — разные места даже при одинаковом начальном значении.

A callable occurrence retains its own structural identity, actual parent and established lexical context. DATA follows the actual parent of the selected executable C; node preserves the selected occurrence's lexical operation and is not rebound by the path used to find C, the address of a shared C function, or a stream recipient. Different code occurrences may share a compatible native implementation while retaining their own data and links. Graph copying preserves or redirects those links through its map. A nested declaration does not capture a caller frame in a hidden environment.

Вход создаёт локальный кадр без обратной публикации. Обязательная копия исполняемого code отменена: для правок кода до endturn момент применения не гарантируется, а обновление native требует явной компиляции. Остальные правила исполнения общие для native и обходчика. Связывание передаётся скрытыми аргументами без копии лексического окружения — значением для собственного места, адресом ячейки для места вызывающего ([исполнители](#binding-executors)); [граница](#explicit-compilation).

Исходные данные с полем `return` и код принадлежат графу — данным `parent(C)` и самой `C`; локальный namespace принадлежит активации. Повторное объявление переменной в коде на том же уровне сохраняет проверку типа, вычисление и присваивание; только повторная C-декларация не выпускается.

A named Structure can receive explicit actuals through the input declarations of its actual parent, and its body's other used values still need resolution. Its explicitly constructed fields remain in the Structure itself; `call` does not create further fields from mentions of external names. Root data places are available to code as call inputs; preparation does not cancel sequential variable/const visibility in the executable lexical tree. A receiver declaration in code with no corresponding place in the data defines a call-local place, without extending source data. Namespace preparation uses the roots of data and code and their explicit stream contracts; it does not eagerly execute a computed place RHS. A future local's bare name is not yet visible; an early read through an explicit path does not suppress execution of its declaration statement when reached ([agreed clarifications](#activation-history)). For an external name without its own declaration, the place is selected during execution by the common order: a lexical source marked `private:`, the transparent caller place, the former binding ([binding](#binding-places)). Thus `named_called_struct` can read and assign the external `k`, but no `named_called_struct\k` field exists unless explicitly declared inside that Structure. Where a write lands is determined by the selected path: through the transparent caller place it immediately changes the caller's local variable, through the former binding it changes the own working copy and does not rewrite the source; a graph field changes only through an explicitly written path. A named Structure has no separate external-name resolution mode.

Различие сохраняется и внутри одной Structure: `int: a` создаёт типизированное место (в данных запись ресивера объявляет место, в коде она на своей строке проверяет тип и, если записано значение, присваивает — [роли `data` и `code`](#data-code-roles)), а последующий оператор `a := get_a()` вычисляет и записывает новое значение при достижении этой строки. Объявление code определяет локальное место вызова, а не дополнение исходных данных; подготовка namespace не исполняет вычисляемый оператор заранее. Совместное хранение частей в графе не делает их взаимозаменяемыми.

Callable selection starts from an explicit reference, structural path or textual path with an explicitly supplied root. Selecting an implementation and providing its arguments are distinct actions. The selected candidate undergoes [admission](#admission); the call then receives the signature inputs: declared inputs follow their ordinary optional/required contract ([structural call](#call-receivers)), while each external (dynamic) input must have a source. A suitable method field does not by itself supply its dynamic inputs. Transporting a method as data is not invoking it.

<a id="call-receivers"></a>
<a id="structural-call"></a>
### Структурный вызов

The selected Structure C is executed in CODE; its actual parent supplies DATA. A call cannot supply a replacement parent or automatically select an inner body. These forms use the common selection, namespace, binding, admission and return mechanisms.

| Форма после однозначного выбора | Исполняемый объект | Явные фактические аргументы | Данные |
|---|---|---|---|
| `call(C)` | `C` | не поданы | `parent(C)` |
| `call(A C)` | `C` | Structure `A` | `parent(C)` |
| `C()` | `C` | пустой хвост | `parent(C)` |
| `C(args)` | `C` | написанные фактические аргументы по общему алгоритму | `parent(C)` |

`args` — Structure фактически передаваемых значений, ровно та, которая является структурой аргументов обычного вызова. Это не объявления формалов, не сигнатура и не отдельная часть callable. Входные места, требования и умолчания описывают данные `parent(C)`; там же полем `return` описан результат ([`return` в данных](#return-in-data)). `code` — исполняемая Structure: `call` исполняет саму выбранную `C`, дочернее поле `code` автоматически не ищется.

У `call` две формы — два отдельных объявления: `call(code)` и `call(args code)`. Параметры называются `args` и `code` и обязательны, `required`: у одноаргументной формы — `code`, у двухаргументной — `args` и `code`; поэтому отсутствие `args` не делает двухаргументную форму подходящей для `call(code := C)`. Объявление выбирается по вызову общим алгоритмом, без исключения для встроенного `call` ([выбор объявления по вызову](#declaration-selection)): если целая `C` подходит форме `call(code)`, а её поля — форме `call(args code)`, запись `call(C)` — ошибка неоднозначности; `call(code := C)` явно подаёт `C` как `code` и раскрытие этого аргумента исключает. Именованные аргументы самого ресивера обычные: `call(args := A; code := C)`; имена членов `A` обозначают входы из данных, а не части ресивера.

Таблица не отменяет выбор чтения единственного структурного фактического аргумента: `C(A)` может принять `A` целиком или выбрать передачу её полей — это определяет [выбор объявления](#declaration-selection). Равенство эффекта разных записей проверяется при одинаковых выбранных фактических аргументах, а не произвольной текстовой подстановкой: при одних и тех же выбранных `A` запись по имени и `call(A C)` — один вызов.

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

Объявления записаны в данных, три записи вызова — в коде. Во всех трёх исполняется `add`, а её данные — `Step`: `x` — собственное объявленное место вызова, описанное данными. Первая и третья записи фактических аргументов не подают, и `x` берёт своё значение 5; вторая подаёт 2. После трёх вызовов `Counter\steps` равно 12. Запись `Step()` исполняла бы саму `Step` — другую Structure; `add` она автоматически не ищет.

Подставить другие данные самим вызовом нельзя: для другой комбинации данных и кода сначала создаётся нужная структурная связь — объявлением, копией или `merge` по их правилам о `parent`, — затем вызывается выбранное вхождение `C`. Запись `NewContainer: ExistingCode` хранит ссылку на `ExistingCode` и его `parent` не меняет ([двоеточие объявляет](#colon-declares)), поэтому прежний `call(NewData ExistingCode)` она сама не заменяет. Копирование и `merge` сохраняют или перенаправляют `parent` по действующим правилам копирования. `node` и его явный лексический доступ сохраняются для фактически выбранного вхождения.

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
#### R0: вход без данных

R0 is an ordinary C method with a local pointer to the R0 graph. The interpreter also runs on the compiled binary and has this binary R0. At the language boundary R0 starts as a procedure without DATA and without user actuals. No artificial D=C relation, empty service DATA Structure or synthetic data field compensates for its absence. R0 may contain executable declarations and use ordinary accessible references; internal runtime launch parameters and native-root graph access do not become user arguments. The absence of DATA affects input binding, not the common classification of written forms: executable declaration receivers and calls follow their ordinary CODE contracts, and a form received as DATA follows that receiver's DATA contract. No root-specific parser, implicit self-call or replacement DATA object is introduced.

<a id="removed-builtins"></a>
#### Что снято нормой 2026-11-19

Сняты (ТЗ 2026-11-19, §4.4): особый смысл имени `data` — зарезервированное имя явной ссылки на данные запуска, путь `data\…` и запись `data := …`; отдельный параметр данных у `call`; встроенные `fncall` и `sub`; исполняемая форма `fn`. Слово «data» остаётся названием роли и обычным пользовательским именем по общим правилам; для `data`, `sub` и `fncall` различаются снятый встроенный смысл и явно объявленное обычное пользовательское имя. `node` остаётся зарезервированной операцией.

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
#### `return` в данных

Результат вызова описывает поле `return` данных (ТЗ 2026-11-19, решение R11): `return: int` либо вложенный блок для [результата-Structure](#structure-result). Объявление `return` в данных ничего не присваивает и не становится общей изменяемой ячейкой рекурсивных активаций. В коде `return` — ресивер возврата: голый `return` сохраняет выход без значения, `return: value` передаёт допустимый результат туда, где он описан, а достижение конца тела `return` не создаёт. Правила структурного результата, принимающих мест и очистки сохраняются ([выходы](#exits)). И `call`, и вызов Structure по имени возвращают значение по этому контракту; прежний безусловный запрет результата у запуска обычной Structure и у `call` снят вместе с `fncall`.

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
### Native обычной Structure и кадр

Любая Structure `C` компилируется общим механизмом тела и кадра. Вызов не требует именованности `C` или искусственного объявления `fn`; данными служит `parent(C)` ([структурный вызов](#call-receivers)). Входы и C-сигнатуры формируются из реальных вызовов, а не полной входной модели. Разные наборы аргументов дают разные сигнатуры; это не основание заранее строить реестр версий или универсальный адаптер.

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
### Выбор объявления по вызову

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
A call's result may be a Structure with several fields, described by a nested return block in its DATA, for example return with `int: x`, `int: y`, and `int: z`. Return describes no shared mutable result cell. The general group assignment `(a b c) := myFn()` receives the resulting fields by position, ignoring their names and requiring the matching count before the first write. Result-expression construction and ordinary receiving places follow their existing contract; transfer by return itself neither copies a returned reference nor creates a second container. A return tail `return: 1 2 3` supplies the described result fields in order. No separate `fm` receiver is introduced. An explicitly grouped copy result uses `return: (copy(A))` when one Structure is required.

Сокращённая запись, в которой слева от `:=` стоит имя вызываемого, например `square := x * x` внутри `square`, отвергается: имени вызываемого ничего не присваивается — имена Structure не присваиваются ([роли `data` и `code`](#data-code-roles)). Прежнее условие её допустимости — принимающий `fn` определяет одноимённую локальную ячейку результата — нормой 2026-11-19 не выполняется никогда: исполняемого `fn` нет, а поле `return` в данных описывает результат и ячейкой с именем вызываемого не является (следствие нормы, чтение исполнителя). Структурное закрытие `end: f` не добавляет неявный возврат значения; результат передаёт явный `return: value`.

Возвращаемая ссылка сохраняет точную идентичность цели. Построение результата, если нужно, принадлежит вычислению возвращаемого выражения, а не операции перехода. Возврат вложенной функции завершает её активацию, а не автоматически весь актор. Порядок выхода и очистки задан в [выходах](#exits).

<a id="publication"></a>
<a id="dynamic"></a>
## 12. Динамические входы и рабочее состояние

Следует различать хранилище объявленного значения в полной Structure, рабочее значение текущей активации, явный формальный аргумент, динамический вход и место вызывающего. Эти значения имеют разные правила изменения; рабочая копия не создаёт второго постоянного графа. Обычная передача изменяемого примитива копирует значение, структуры и массива — ссылку; особая идентичность неизменяемого значения сохраняется согласно [квалификации](#qualification).

<a id="binding-places"></a>
### Собственное место и место вызывающего

Норма 2026-11-19 ([ТЗ](TZ/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), R01–R07). Разрешение имени в вызове определяет источник и логическое место. Мест два вида. Собственное место: поданный фактический аргумент, автозаполнение или прежнее связывание дают значение либо описание в место текущей активации. Место вызывающего: имя обозначает уже существующую локальную переменную вызывающего, без промежуточной рабочей копии. В обоих случаях переменная `x` имеет свой обычный тип `T`; чтение `x`, запись `x := value`, выражения с `x` и `@x` действуют на выбранное логическое место. Скрытый указатель, которым native передаёт место вызывающего, — способ реализации: тип `x` указателем не становится, и писать `\x` вместо `x` не требуется. У переменной-ссылки обычным типом остаётся её тип ссылки; дополнительный уровень адреса её ячейки — транспортный и к типу не добавляется.

There are three implicit ways, and they differ by the place of the write. [Autofill](#binding-autofill) gives a place of the callee declared without a value the value of the same-named local variable of the caller -- into its own place. The [transparent caller place](#binding-caller-place) binds a used external name that has no own declaration in force to the caller's local place. The [former binding](#binding-fallback) is kept in full, has the lowest priority relative to the two new ways and, as before, gives an own working value or description. Whether a name has an own declaration in force is decided by [declaration levels](#shadowing-levels); [two-way `private`](#private-binding) applies to all three ways. Implicit binding is applied after [declaration selection](#declaration-selection): it does not create a variant of selection, does not rescue a rejected one and does not restart the selection.

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

For a free name, the called expression receives the current value from the caller's available context; if unavailable, permitted lexical lookup follows `node`. Own declarations and formal parameters have their respective resolved locations rather than being searched in a global registry. The called expression's own free names are part of its interface: adding a free name to its body changes that expression's interface. Names needed only by the expressions it calls are not part of its interface and do not accumulate along call chains (there is no transitive closure; the author's clarification of 2026-11-01): a forwarding expression declares and passes nothing. A free name with no source -- no binding along the chain of activations and no lexical source -- makes the call inadmissible; silently creating zero or a new field during execution is prohibited. This is a rule about a free name, not about a declared input place of the data: a declared input without a value does not make the call refuse (the author's decision of 2026-11-16). An existing data field and a free input's value are distinct places; matching names do not copy the value itself. A callable's formal is not a free name of its body: it receives the supplied argument or its default value ([§11](#callables)), without them -- [autofill](#binding-autofill), and where it is inapplicable it stays "T without initialization" and does not make the call refuse ([structural call](#call-receivers)); the source priority below does not extend to an omitted formal. A free name's type is the type of the value of the selected binding, known when the value is used, not a static closure over the callers: one and the same called expression accepts bindings of different types. The receiving place -- a declared local or field, a result, a formal argument, a write through the name itself -- admits that value by the executor's one admission by the place's type; a literal beside such a value takes its type; a type mismatch in an operation or at a reception is the implicit `convert` throw ([exits](#exits)), never a silent conversion.

A free name's sources have this priority: the caller's nearest current local binding eligible for dynamic binding, then its already inherited dynamic input, then the callee's lexical lookup. Places marked `private:` are excluded from dynamic selection, and a really visible marked lexical declaration is not shadowed by a dynamic source ([two-way `private`](#private-binding)). A local binding includes a used own field, formal argument, result or another receiver-defined local value. The sources are available along the chain of activations: its own free names, and only those, are resolved through the activation records of its callers, nearest binding first; no static closure of requirements along call chains, mutual recursion included, is computed (the translator does not analyse code for its execution; the author's clarification of 2026-11-01). A name needed only by the next call requires neither forwarding nor a local value; by itself it creates no graph field. It follows that a method which itself consumes the name forms its activation's value of it from these same sources, its own lexical lookup included, and that formed value belongs to its available context subject to `private:`: when dynamic binding is permitted, what it calls receives it, whichever source gave it. A method that only forwards the name forms nothing: an entry that arrived absent travels on absent, and the eventual consumer uses its own lexical lookup. Assigning the name changes that activation's value only, and an explicit `node\x` read forms no binding.

A consumed free name, including one used in a throw payload, obtains its binding from the permitted context of the language call site. Once selected, fallback holds its own value or computed description independently of later source replacement; this does not execute a computed RHS merely to select it. A forwarded but unconsumed name gains no dummy local copy. Declaring nested code does not run that code or bind all its future free names.

The interpreter does not pre-walk the body on entry. Opening a namespace scans only the relevant level needed for bidirectionally visible Structure/callable declarations and ordinary root preparation; it does not scan unexecuted branches or future locals. A missing free name is therefore refused when its use is reached, not merely because an unreachable branch mentions it. A binding selected at that reached use is retained for its scope. Known native code receives its selected hidden bindings at the call under the same source and place contracts. Neither execution path statically accumulates all descendants' free-name requirements or invents source-graph snapshots to equalize unspecified pre-endturn edit timing.

Лексический поиск следует реальным связям Structure до нулевого родителя и выбирает единственное поле нужного имени на соответствующем уровне ([имена](#fields)). `independent` отсекает внешний лексический запасной путь. Явные `node\x`, `reference\x` и `array[index]` обращаются к графу, не подменяясь динамическим `x`; контекст, скопированный `merge`, участвует лишь как запасной путь ([композиция](#composition)). Для явных путей и `node` отдельной проверки «поле принадлежит чужому вызывающему» нет; ограничения записи, типы, `const`, `immutable` и правила допустимости адреса действуют как обычно.

<a id="binding-chain"></a>
#### Цепочка вызовов

Для цепочки A → B → C, где у A есть `x`, B сам `x` не потребляет, а C потребляет, прежняя достижимость сохраняется (R07): B не обязан вводить явный аргумент, фиктивную локальную переменную или транзитивный перечень потребностей вызываемых. Если при этом сработало прежнее связывание, C получает собственное значение, и запись C в место A не идёт. Если у B есть собственная копия `x`, полученная от A, то C, получивший место `B.x`, меняет `B.x`, а исходное `A.x` сохраняется: происхождение копии не раскручивается обратно в алиас. Если у B — прозрачная связь с `A.x`, передача места `B.x` сохраняет адрес `A.x` без промежуточной копии. Запрет статического транзитивного накопления скрытых требований сохраняется: собственные непосредственно используемые входы выбранного тела не объединяются с входами всех его возможных вызываемых.

<a id="private-binding"></a>
### Ресивер private: и динамическое связывание

Dynamic binding supplies a used external name from the permitted calling context instead of its lexical fallback. The common binding rules distinguish a transparent immediate-caller place from an own value supplied by the retained fallback. Explicit lexical paths such as `node\x` still select the graph directly; they are not dynamic substitution. The visible lexical declaration matters to the two-way `private` filter below, while an unmarked free name remains eligible for dynamic binding. This preserves explicit lexical access from the author's definition of 2026-11-17 under the revised binding order of 2026-11-19. Receiver `private:` forbids the implicit dynamic participation of the marked declaration and of the place corresponding to it in both directions (the norm of 2026-11-19, [the requirements](TZ/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), R05 and R06). The source side: a marked place of the caller automatically supplies neither its value nor its mutable place. The receiver side: a really visible marked declaration of the lexical context of the callee is not shadowed by a value or a place from the dynamic context, and a marked receiving place is not autofilled. The rule applies to [autofill](#binding-autofill), the [transparent caller place](#binding-caller-place) and the dynamic part of the [former binding](#binding-fallback). Therefore, before an external dynamic binding is accepted, it is established which lexical declaration is really visible and whether it is marked: checking only the source is not enough. This is a property of a particular declaration and its corresponding binding, not a ban on the name's spelling. A marked source is skipped, and the search continues in the ordinary order: a more distant permitted source of the same name remains available. The receiver-side protection concerns the selected visible declaration: a marked `x` of a distant ancestor does not close a new inner unmarked `x`. Before 2026-11-19 the rule was one-sided -- `private:` merely excluded a field from the sources; that wording is withdrawn.

The field remains directly visible from anywhere: an explicit path, `node` and ordinary lexical lookup remain available, and nested lexical code sees the field. Receivers are not executed in the graph, and the `private:` record lies there as it is written, so the path to the field goes through it: `S\private\field` (the author's clarification of 2026-11-18); binding does not straighten this record into `S\field`. The receiver introduces no access boundary, does not change sequential visibility, does not replace `const` and `immutable`, and prohibits neither explicitly passing the marked value as an argument nor explicitly filling a marked receiving place with a permitted actual argument. An explicitly passed value does not carry the history of the marked source onto its copies, and an unmarked place of the recipient does not become marked from this. A new inner declaration shadows an outer marked one in the ordinary lexical way ([declaration levels](#shadowing-levels)). Resolving the field through ordinary lexical lookup is not dynamic binding. Neither is a code's reading of a field of its own call data: with `D: private: int: x 5` the code `C` with the data `D` reads `x` as its own input place and gets 5, while what `C` calls does not get its `x` from that place by any of the implicit ways -- `private` forbids only dynamic binding (the author's clarification of 2026-11-17; in the clarification the data were given by the former form `call(D C)`, now the data are `parent(C)`).

Правило одинаково для вызова Structure по имени и обеих форм `call`, в интерпретаторе и native. Оно применяется при выборе связи существующим общим механизмом; отдельные таблицы запретов по именам, защищённый тип значения и проверки каждого прямого чтения не требуются.

The record of the receiver `private:` lies in the clean graph like the other written receivers. The walker recognizes and consumes that original record; the translator reads the same record and reflects its binding rule in generated method instructions and hidden arguments. Neither builds another graph containing private marks, access flags or a replica of the source tree in the binary. The ordinary generated binding logic is sufficient. A regression must preserve `S\private\field`, verify the same private behavior across native/walker calls, and reject a second marked graph even if its outputs happen to match. This incorporates the latest [author example](TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md#private-without-marked-graph).


<a id="private-examples"></a>
#### Examples of private: in data and code

These examples specify both directions of private; they are not implementation receipts. They use ordinary receiver composition: `private: int: x 10` marks the declared field x. The receiver's action needs one argument, so several arguments may be passed and the action applies to each in turn: `private: int: x 10; int: y 20`, `private(int: x 10; int: y 20)` and a block under `private:` with two declarations mark x and y, as two forms with one argument each do (the author's clarifications of 2026-11-18). `private` takes its arguments as `data` and does not unwrap an argument that is itself a Structure ([two kinds of receivers](#two-kinds-of-receivers)): in `private: (int: x 10)` the argument is an anonymous Structure with the field x, not a declaration of the field x; as a declaration argument it is written in `private: int: x 10` and in `private(int: x 10)` (the author's clarification of 2026-11-18). When a call executes the declaration, no field named private arises: x is declared. In the graph every receiver lies exactly as it is written -- the graph is already what the explicit paths read (the author's clarification of 2026-11-17).

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

The author's rule (author decision; [the requirements](TZ/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), R16): a declaration at a nested level shadows an outer declaration of the same name; at one level there is nothing to shadow -- the parent one is used. The rule is applied through the owner of the declaration and the lexical scope: an available outer binding and an own declaration of the current level do not become one place merely because the names coincide.

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

The caller of `Worker\work()` has no local x. The inner `int: x` creates a distinct place and shadows the outer x=5. It has no actual, ready value or initializer. Autofill takes its source from the immediate caller's permitted local context; entering an inline `if` does not create a new caller, so the enclosing local x=5 is not that source. The inner place therefore remains `uninit:int`, and the reached `required: x` refuses initialization. The outer place remains 5. This is the consequence of the supplied [Binding and Callables §§6.1, 7.2 and 7.4](TZ/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), not a separate rule that copies outer locals or eagerly executes defaults. With an explicit inner initializer, `int: x 9`, the check passes and the outer place still remains 5. These are required outcomes, not a report of executed tests.

<a id="required-receiver"></a>
### Ресивер required: проверка инициализации поля

`required` checks initialization, not the truthiness of a value. `uninit:T` fails; zero can satisfy it. On an input declaration it constrains call selection: the candidate needs an explicit actual or its own applicable initializer/default, and hidden autofill cannot supply a missing required input during that selection. In reached CODE it checks the actual place at that point, including any allowed autofill or prior assignment. This is one initialization requirement in different consuming positions, not a separate mandatory-argument type.

`required` may be written anywhere: all Structures are interchangeable, and it is not known in advance which one ends up in which role (the author's answer of 2026-11-16). There is no restriction on which declaration it stands in -- just as `private:` has none ([receiver private:](#private-binding)): `required: int: a` is the ordinary composition of declaration receivers that marks the declared field `a`; when a call executes it, no field named `required` arises, while in the graph the record lies as it is written. The check of an already visible field may also be written as a separate line -- `required: a`. There may be several arguments -- `required: a b c`, `required: int: a; int: b`, `required(int: a; int: b)`: the action needs one argument, and the receiver applies it to each in turn, in the written order (the author's clarification of 2026-11-18). All combinations are possible -- in `data` and in `code`, as a mark of a declaration and as a line with the name of a field -- and so is any number of checks of one variable: in `code` each runs on its own line and does not interfere with the others. These are different paths to one check, and neither needs a separate pass: on entry to a callable there are no initialization passes besides the supply of arguments, and the rest is executed when reached ([call frame](#call-frame-20261115)).

`required` во входных данных вызова проверяется при подаче аргументов — том действии входа, которое и так проходит по входным местам: если месту не досталось ни значения объявления, ни поданного actual, это ошибка, и ни одна запись `code` не исполняется. [Автозаполнение](#binding-autofill) за такой вход проверку не проходит: `required` во входном описании участвует в [выборе объявления](#declaration-selection), а неявное связывание в выборе не участвует (норма 2026-11-19, [ТЗ](TZ/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), §9.7). Запись `required` в `code` — помеченное объявление или строка `required: a` — проверяется на той же строке, когда до неё доходит исполнение: у объявления после его обычного действия, проверки типа с присваиванием, у строки с именем — по полю, найденному в этом месте по общим правилам [видимости](#declaration-visibility); проверяется фактическое состояние места, в том числе после разрешённого автозаполнения.

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

`F\f(7)` и `G\g(7)` возвращают 7: поле `a` инициализировано поданным actual. `F\f()` даёт ошибку при подаче аргументов, до первой записи `code`: помеченному входу `a` не досталось ни значения объявления, ни поданного actual, и одноимённое локальное место вызывающего его не спасает. `G\g()` отказывает на первой строке `code`, не исполняя остальных записей, когда у вызывающего нет доступного локального `a`; при таком `a` автозаполнение заполняет объявленное без значения место, и проверка проходит. Значение в объявлении — `required: int: a 5` у `F`, `int: a 5` у `G` — делает поле инициализированным: `F\f()` и `G\g()` возвращают 5. Пример записан формами нормы 2026-11-19: входы и поле `return` описаны данными, код — вложенная Structure ([структурный вызов](#call-receivers)).

Failure of input requiredness is a call-admission refusal; failure of a reached CODE required is a failure at that reached form. It uses ordinary diagnostics and failure handling. The distinction is common to by-name calls, explicit call, the interpreter and prepared native execution; it does not introduce another channel or imply runtime implementation status.


<a id="call-frame-20261115"></a>
### Call frames without write-back — decision of 2026-11-15

The input places of a call are described by the data -- `parent(C)` of the executed Structure `C`; `args` in `call` and the tail of the form `C(args)` supply actual values to them under the [common call contract](#call-receivers). In the decision of 2026-11-15 this is written for `fn`, `sub` and `catch` with one input `data` and for `call(D, C)`; these forms are withdrawn by the norm of 2026-11-19 ([what is withdrawn](#removed-builtins)), the frame rules are kept. Every independent callable invocation creates its own namespace and local places. Executing an accepted declaration form and its associated body uses the established places of that receiving execution under [§11](#declaration-arguments); it does not create a fresh isolated item or rerun an initializer at every body entry. Positional and named actuals map to the input description. A supplied actual replaces the corresponding namespace description and suppresses that original initializer. A declaration-form actual preserves the replacement form itself; executing that accepted form later follows its own reached-execution contract. Call entry does not execute initializers of omitted fields.

Namespace preparation collects declarations at the roots of `data` and `code`, including the fields supplied by explicit `import`, `copy` and `merge` when their contracts require consumption. These receivers always consume standard CODE source arguments; this is separate from eager execution of computed place initializers, which preparation does not perform. There is no general traversal of lexical branches or graph reference edges. Code's own places absent from the input data belong to this call and are not appended to source data. Collecting places does not override sequential visibility of variables and `const`. Nothing is auto-filled in the graph: [autofill](#binding-autofill) fills the own place of the frame and does not write into the graph.

Ready data receives its ordinary initialization during clean-graph construction without program calls: for example, `int: i 5` is present as its named `{int 5}` leaf through the existing mechanism. A computed declaration retains its written code. There is no separate entry phase that executes it: in `mark(); int: y makeValue()`, makeValue() runs when the declaration is reached, after mark(). An unused computed input-data field is not executed. Types without a value (`uninit:T`) remain; an absent initializer is not replaced by a random ordinary T.

Bare `x` and `@x` refer to the logical place selected by [binding](#binding-places). The own place of the current call after entry is independent of later replacement of the source field -- equally for a supplied actual, autofill, and a lexical and a dynamic source of the former binding. The selected value or computed description is held as values or references to the already existing descriptions, without an execution-graph copy or entry-wide RHS execution pass; a reached free-name binding follows the interpreter/native timing stated in [fallback](#binding-fallback). This does not deep-copy all referenced objects: explicitly passed references retain target identity. A local assignment to an own place does not write back. A name bound to the [transparent caller place](#binding-caller-place) denotes that place itself: a write changes it at once, `@x` addresses it. An explicit path from the Structure of the data `D\x` and `code\x` access the source graph; explicit writes are observed through its actual aliases in execution order (the former form of the first path, `data\x`, is withdrawn together with the special name `data`, [what is withdrawn](#removed-builtins)). For `p\x`, the current local value of p selects the referent.

Чтение вычисляемого места по голому имени — работа вызова: исполняется уже написанное выражение объявления, а не придумывается нульарный вызов полученной ссылки. Явный путь `D\field` ничего не исполняет и читает запись объявления ([явный путь](#path-reads-no-execution)). При исходном `@: fptr getFuncPtr()` запись `fptr("hello world")` сначала выполняет getFuncPtr(), затем вызывает полученную функцию. `fptr := 0` меняет только namespace; `D\fptr := 0` меняет исходное поле так, чтобы оно читалось как `@: fptr 0`. Если исходное поле изменено до первого чтения голого fptr, выбранное при входе описание кадра от этого не меняется.

<a id="path-reads-no-execution"></a>
#### Явный путь ничего не исполняет

Reading a computed declaration by an explicit path executes nothing. This supersedes the earlier path-evaluation rule. An explicit path -- `struct\field` -- reads what is written in the graph and makes no call; the decision also names the path `data\field` -- the special name `data` is withdrawn by the norm of 2026-11-19 ([what is withdrawn](#removed-builtins)), and the path to a field of the data of a call leads from the Structure of the data itself, `D\field`. If the field is declared with a ready value, `int: field 5`, the path gives that value, the number 5 of type `int`. If the declaration is computed, `int: field f()`, the path gives the record of the declaration itself -- the Structure of the receiver with the name and the written call; `f()` is not executed. An expression is no different from a call: for `int: field 5 * 2` the path returns not 10 but the full Structure that begins with `int:` (the author's clarification). Likewise `D\S` for the record `S: merge: A B` in the data `D` executes no `merge` and gives the record.

A computed declaration is executed by a call, and by it alone: a call prepares its namespace from the root declarations of its data and executes the written expression when it refers to its local place by a bare name ([call frame](#call-frame-20261115)). That work of the call stays as it was: there is no general initialization, a call prepares a place on a concrete access (the author's confirmation). It has nothing to do with a read by an explicit path. Therefore `sys\toLmx` prints the records as they are written, and a write by an explicit path changes the graph itself -- with no hidden calls and no cache of results. The print of a graph comes down to the print of Structures and of primitive values already recorded in the arena with their type: by a path the receivers come back as Structures.

<a id="computed-field-address"></a>
Taking the address of a local place also obtains a computed value: for input `int: x next()`, `@x` runs next() and gives the ordinary local int cell's address. `@(D\field)`, where `int: field getValue()` is written in the data `D`, addresses the record of the declaration, not the result of getValue(): an explicit path executes nothing (the author's decision of 2026-11-17, [explicit path](#path-reads-no-execution); it withdraws the former rule of 2026-11-15 under which the result was addressed). A ready place is addressed directly; place lifetime remains ordinary. `@f()` was a research example, not a separate implementation task or a request for a C-like prohibition. The author's clarifications.

Повторное объявление имени на том же уровне не вводит ещё одну C-переменную, но сохраняет остальные действия: `int: x bump()` вычисляет bump(), выполняет общий допуск и присваивает существующей x. Объявление того же имени на вложенном уровне создаёт своё место и затеняет внешнее ([уровни объявлений](#shadowing-levels); прежняя формулировка — любое повторное объявление уже видимого имени пишет в прежнюю ячейку — нормой 2026-11-19 сужена до одного уровня). Новое имя ветви видно с объявления на её уровне и ниже, не снаружи. Два объявления в данных остаются двумя физическими вхождениями: `S\[0]x` и `S\[1]x`; `S\x` неоднозначно. Последовательная видимость переменных и const снимает прежнее раннее обращение к будущему локалу по голому имени. Чтение написанного вычисляемого объявления через явный путь его не исполняет; RHS исполняет достижение его строки в code. Отдельных исключений и скрытого кеша вычислений нет.

Для исполнения изменяемого code действует [явная компиляция и граница endturn](#explicit-compilation). Обязательный снимок code при входе отменён; неизменность выбранных локальных значений/описаний namespace этим не отменяется. Фазы исполнения инициализаторов на входе по-прежнему нет.

C-сигнатуры выводятся из реальных вызовов. Разные наборы поданных аргументов дают разные сигнатуры; полное описание данных само по себе не становится списком параметров каждого C-входа. [Сигнатура `fn`](#fn-signature) описывает контракт вызова, а не исполняемую реализацию. Обычная Structure и метод используют общий механизм компиляции тела и кадра; данные вызова — `parent` исполняемой Structure ([структурный вызов](#call-receivers)), а у корневого входа R0 данных нет ([R0](#root-entry)).

<a id="binding-executors"></a>
### Связывание у исполнителей

Норма одна для интерпретатора и native ([ТЗ](TZ/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), §11–§12). Прямой вызов native → native сохраняется там, где выбранные реализация, типы и связывание известны. Автозаполненное значение понижается тем же параметром `T`, что и явный фактический аргумент; [прозрачное место вызывающего](#binding-caller-place) — скрытым адресом его ячейки; [прежнее связывание](#binding-fallback) по-прежнему даёт собственное место. Общее C-тело может разделяться между режимами через адаптеры, но адаптер сохраняет владельца записи и поведение `@`. При одинаковых явных фактических режим скрытого входа может различаться из-за контекста вызывающего и `private`: нативный вход соответствует действительному контракту либо получает описание места; новые пользовательские типы указателей не вводятся.

У обычной нативной локальной переменной нет заголовка арены «тип, значение»: её тип нельзя прочитать из четырёх байтов перед адресом. Тип, способ доступа, состояние инициализации и применимые ограничения следуют из общего представления места и контракта вызова. Сочетаний исполнителей четыре — native → native, native → интерпретатор, интерпретатор → native, интерпретатор → интерпретатор, — и во всех `x` имеет один логический тип `T`, а допустимая запись меняет одно и то же логическое место. Для цели, известной только при исполнении, действует существующий доступ к разрешённым локальным контекстам: сырой C-стек словарём имён не служит, статическое транзитивное замыкание требований не вводится. Служебные C-функции, мост и диспетчер `call` не подменяют контекст вызывающего своими служебными локальными переменными: источники определяет программное место вызова.

Boundaries. Load-dirty, `flush`, publication of local frames and copying back at exit do not return ([withdrawal of publication](#flush-receiver-contract)). A read through the caller's place is not replaced by a snapshot without proof that the observable behaviour under nested calls is preserved. The absence of a suitable native entry does not start hidden compilation ([explicit compilation](#explicit-compilation)); persistent environment caches and automatic graph invalidation are not added; `restrict` is not applied merely because of hidden passing of a pointer or `private`. Binding adds no fields to the source data and code and does not change their structure; the service information of the namespace is neither a second graph nor a persistent store of name resolutions, and native descriptors remain in the `call` tables. A transparent link does not extend the lifetime of the local place; preserving the graph does not make the address of a temporary C variable a portable reference; at `yield` the selected binding is not rebound to the same-named local variable of the new caller of `next`.

<a id="explicit-compilation"></a>
### Явная компиляция, native и endturn

Compilation of an explicitly selected root includes clean-graph construction and checking without program
calls, the separate required build-test phase on that clean graph, lowering to L1 and C, machine compilation,
and entry registration in `call` tables. The tests use their ordinary receiver and call contracts; the
application entry is not launched merely to compile it.
`sys\compile(S)` invokes this shared chain; `sys\translate(S)` stops at L1 text.
Failure returns diagnostics and provides no new native entry. The runtime operation reuses the
required parts of the same builder chain, without a second compiler.

Native is an explicit descriptor: an ordinary Structure containing machine-entry variants and signatures, binary-module/entry references, and available L1/C source paths. Its primary storage is the arena's call tables shared by methods and ordinary executable Structures. `sys\native(S)` queries those tables without running S. The Lmx header has parent/length/storage and no native field.

The source graph is not supplemented with synthetic native fields as a side effect of translation or fn-description creation. Any explicitly present ordinary field named native remains ordinary graph material; it is not a header pseudo-field. Source forms remain as written, and service/native descriptors stay in the established tables. Dynamic calls select suitable variants for the actual target and call; otherwise an admissible body uses the walker. Compilation and registration are explicit, not hidden consequences of call entry, copying or graph edits.

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
### Прямой доступ без отдельного кеша языка

The proposed direct-access cache shared across calls is cancelled together with load-dirty. Aliases of the same runtime local place observe its sequential writes. Paths that select the same structural graph cell observe the fragment currently held by that cell, including an explicit replacement. Two different graph cells that previously held references to one primitive fragment do not become one writable place merely because those references matched; replacing one cell does not promise to retarget the other. A local variable remains an own place of the current frame, separate from the source record of the graph; a name bound as the caller's place denotes the caller's place ([own place and caller's place](#binding-places)). Ordinary compiler optimizations preserve these rules without new coherence tables or mandatory checkpoints.

<a id="flush-receiver-contract"></a>
### Отмена публикации локальных кадров и flush()

Кадры `data` и `code` не публикуются в граф. Удаляются load-dirty, обратная запись на вызове и выходе, общий кеш прямого доступа и запланированный ресивер `flush()`. Прежние примеры с публикацией внешнего `x = 2` и вложенного `x = 9` описывали отменённую модель. Теперь это независимые локальные места; исходный граф меняют только явные операции. Запись через [прозрачное место вызывающего](#binding-caller-place) публикацией не является: она сразу меняет локальное место вызывающего, а копирования при выходе нет. Публикация Message и выдача результата построения — другие операции, этим решением они не отменяются.

<a id="activation-history"></a>
### Активации и согласованные границы

Стек вызовов остаётся единственной неявной историей активаций: обычный C-стек у native и соответствующий управляющий стек у интерпретатора. Рекурсивные и вложенные вызовы получают разные собственные локальные ячейки, в том числе разные `@x`. Возврат, `throw`, `finally`, `retry` и `yield` не создают обратной публикации этих ячеек. Имя, связанное с [прозрачным местом вызывающего](#binding-caller-place), собственной ячейки не получает: оно обозначает место вызывающего, запись меняет его сразу, и `@x` адресует его. Явно переданные ссылки сохраняют идентичность своих целей.

The established activation boundaries are: no entry-wide initializer pass; sequential variables/const; reached computation and demand through the logical namespace; explicit paths that do not execute source records; and explicit compilation plus endturn for guaranteed native updates. Own places remain independent of source records, while transparent caller bindings denote their real source cells. The old load-dirty, flush and executable fn/sub models are withdrawn. Catch follows its preserved [handler contract](#catch-common-model). These are semantic requirements, not implementation or test results.

<a id="branches"></a>
## 13. Ветвления и циклы

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

<a id="exits"></a>
## 14. Выходы и finally

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

<a id="exceptions"></a>
## 15. Объявленные отказы и диагностика

`throws` перечисляет имена возможных восстанавливаемых выходов выражения, а не типы исключений. Вызывающее выражение должно предоставить `catch` для каждого такого имени либо объявить его в собственном `throws`. Вызов без одного из этих способов обработки отвергается. Условие обнаружения отказа задаётся обычным `if`; модульный `guard` не является оператором обработки отказов.

`throw: Name(arguments)` вычисляет явную полезную нагрузку и покидает текущую активацию по правилам [выходов](#exits), не возвращая объявленный результат. Параметры выбранного `catch: Name (...)` принимают нагрузку. Повторный вызов из обработчика начинает новую активацию сначала и не возобновляет брошенный кадр.

`catch` — точка приёма в блоке вызывающего выражения, не обычная вложенная вызываемая Structure ([`catch` в общей модели](#catch-common-model)). При первом прямом проходе её тело пропускается. После доставки соответствующего отказа тело выполняется, затем исполнение продолжается с операторов после этого `catch`. Поэтому обработчик, поставленный до вызова, повторно вводит выполнение в последующий участок; обработчик после вызова продолжает за собой. Участок ограничен следующим `catch` того же блока или концом блока. Обработчик действует на все вызовы своего блока, включая вызовы из вложенных в него операторных блоков (`if`, `while`, `for`, анонимный `---`): обработчик, как именованные Structure и вызываемые, виден во всём своём блоке в обе стороны. Блок-сосед им не покрывается. Это двусторонняя видимость имени callable, а не всех мест данных. Переменные, включая `const` и переменные с указателем на метод, видны последовательно; имена именованных Structure и callable — в обе стороны по [общему правилу видимости](#declaration-visibility).

Два одноимённых обработчика в одном блоке запрещены; отдельные вложенные блоки могут иметь каждый свой. Доставка выбирает обработчик по блоку вызова, не одноимённый обработчик соседнего блока. Повторный `throw` того же имени внутри обработчика не входит в этот обработчик заново: это отказ во внешнем вызывающем контексте. Необработанное имя распространяется только через соответствующие объявления `throws`.

Операторы языка, у которых программист не видит явного перечисления `throws` (например, `merge`), тоже бросают именованный отказ, но отлавливать его не обязательно: обработчик `catch: merge` — до вызова, после него или в отдельном вложенном блоке — обрабатывает его стандартно, и никуда он не улетает; неотловленный неявный отказ улетает в корень исполняющегося Message, и поток останавливается (`running = 0`). Единственное ограничение размещения — то же, что и для объявленных имён: два одноимённых `catch` не могут спорить на одном уровне.

Если интерпретатор при исполнении корректно построенного графа обнаруживает ошибку самой выполняемой операции, он создаёт обычный неявный отказ с единым именем `interpreter`. Его принимает `catch: interpreter ()` по тем же правилам области действия и распространения, что и другие неявные отказы; отдельного канала исключений интерпретатора нет. Ошибка построения исходного графа при трансляции, повреждённая форма графа и нарушение инварианта ядра не являются таким отказом: это диагностика соответствующей стадии, которую `catch` исполняемой программы не перехватывает.

<a id="catch-common-model"></a>
### `catch` в общей модели данных и вызова

Норма 2026-11-19 ([ТЗ](TZ/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), R17). Обработчик `catch` описывается общей моделью входов и фактической связью: код обработчика читается в роли кода, а роль данных у него исполняет его `parent`, как у всякого исполняемого кода ([структурный вызов](#call-receivers)). Полезная нагрузка `throw: Name(arguments)` — явно поданные значения; параметры обработчика принимают их по общим правилам фактических аргументов. На остальные зависимости обработчика — имена, которые он использует, но не получает нагрузкой, — действуют обычное [связывание](#binding-places) и [двусторонний `private`](#private-binding).

Семантика обработчика при этом сохранена целиком: обработчик выбирается по имени отказа и своей области; его тело не исполняется при первом прямом проходе; вложенные и соседние области различаются; двух спорящих одноимённых `catch` на одном уровне нет; продолжение после обработчика, повторный вызов, `throws` и очистка действуют так, как описано в этой главе. `catch` не исчезает вместе со снятым `sub` и не превращается в обычную функцию от того, что представление входов стало единым. От снятых форм — исполняемых `fn` и `sub`, `fncall` и отдельной подстановки данных ([что снято](#removed-builtins)) — обработчик не зависит. Роли его частей следуют контракту обработчика: то, что `fn` вошёл в группу ресиверов [роли данных](#whole-arguments), само `catch` не переопределяет. Запись заголовка `catch: Name (параметры)` этой нормой не менялась.

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

`sys\assert` проверяет диагностический инвариант. Ложное условие порождает `AssertionViolation`, а не восстанавливаемый `throw`; его нельзя поймать обычным `catch`, и оно не входит в `throws`. В акторном профиле диагностическое прекращение выполняет правила выхода и очистки активации из [выходов](#exits) до передачи диагностики корню исполняющегося Message. Message прекращает исполнение и больше не получает тактов. Это не делает неуспешный такт успешным и не разрешает публикацию его ожидающих исходящих писем: они по-прежнему подчиняются [доставке](#delivery). Это не обязательное завершение рабочего потока ОС; остановка исполнения и уничтожение объекта различаются.

Ожидаемые ошибки входных данных обрабатываются явным условием и объявленным отказом, а не диагностической аварией. `log` и `error` записывают наблюдения через выбранный профиль. Само `error` не означает `throw`, `sys\assert`, возврат или остановку. Нелитеральный аргумент разрешается как обычное значение; неизвестное имя не превращается автоматически в строку журнала.

<a id="suspension"></a>
## 16. Повторный запуск и приостановка

`retryable` задаёт повторяемую область. `retry` без имени повторяет ближайшую активную такую область; `retry: label` — указанную. Перед повтором выполняются очистки покидаемой попытки. Переход не откатывает внешние эффекты, изменения графа или опубликованные сообщения. Транзакционный откат возможен только как отдельно выраженный протокол над данными.

Сам `retry` — локальный переход текущей активации, не новый вызов и не восстановление скрытого окружения. Текущие рабочие значения продолжают существовать, дополнительной публикации только из-за перехода нет. Если повтор достигает вызова или выхода, действует соответствующая обычная граница. Нагрузка пойманного отказа остаётся явными аргументами обработчика.

`yield` передаёт произведённое значение и приостанавливает активацию. Её локальные входы, namespace и рабочие значения сохраняются для возобновления; в граф они не публикуются и при возобновлении из исходной Structure не перечитываются.

Входы производителя фиксируются при начале его активации. Следующий вызывающий `next` не заменяет их своим динамическим окружением. Если `next` реализован отдельным выражением-обёрткой, его входы относятся к его активации, пока явная операция не изменит сохранённое состояние производителя. Представление продолжения и результата итератора не наблюдаемо, если сохраняется описанная семантика.

<a id="arrays"></a>
## 17. Массивы и хранилище

An ordinary Structure and a reference Array `Array<@>` are fully interchangeable: indexing, named paths where names exist, `length`, admission, copying, execution, `sys\typeof` and `sys\descriptor` use the common contract. An ARRAY/STRUCT category alone is no reason for refusal. `length` reads the header field `length`; `parent/length/storage` are not counted as elements. A numeric `Array<T>` stores T directly. Structures, Arrays, and service lists share length and capacity management. Finite rectangular Array rank has no fixed limit and is independent of pointer depth. [Layout](L2_spec_ru.md#lmx).

An ordinary Array is a typed graph Structure with stable reference identity. Constructor `[]` creates it when execution reaches the construction site. In `[]: arr (... )`, binding occurrence `arr` belongs to the current Structure, the Array's structural parent is that `arr` occurrence, and structural elements materialized from the arguments have the Array as their parent. Parentheses around the arguments create no extra anonymous wrapper in the Array: P0 does not unwrap them, but the receiver `[]` reads the Structure written in them by its own contract, as the list of its arguments ([general rule](#values)). In data `MyLmxStructFromArray: arr` declares a Structure `MyLmxStructFromArray` with the one atom `arr`; that atom is a pointer to **that same Array**, a reference immutable by name: in the tree under `MyLmxStructFromArray` stands only the atom, the Array is neither reconstructed nor copied, and its `parent` does not change ([declaring a Structure](#colon-declares)); a pointer variable to that same Array is declared by `@: p arr`, and in code the form `MyLmxStructFromArray: arr` is a call of its head. A Structure field holding an Array reference is not the Array itself. Passing a reference does not copy elements; an element mutation is visible through other references, whereas rebinding a local reference is not.

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
A Structure and `Array<@>` are addressed identically. `S[i]` reads a `void*` from physical `storage`; `S[i] := p` stores another `void*` there. This operation neither checks nor transfers a former field's requirement, name, or cell kind: it is simply a write of a value into the array, without checks (the author's clarification of 2026-11-17). Slot count and addresses do not change. Names and types are interpreted from current content when subsequently needed; the write itself does not assign a name to the slot. `S\[N]field` and `voidarray\[N]field` structurally select the Nth occurrence under the named field contract. An ordinary typed `Array<T>` retains its element representation. `length(S)` reads the element count. Index writes require no former-slot requirement table or associated publication/checking mechanism.

<a id="get-type"></a>
`sys\typeof(arg)` returns the type code of the selected typed record; an `uninit:T` record supplies its code without any value read. After graph-fragment replacement, a fresh lookup through the structural place selects the replacement record, without a promise about an old raw address: `sys\typeof(S[i])` identifies the selected field value, `sys\typeof(@i)` the addressed cell of i, and `sys\typeof(S)` the Structure descriptor. It consumes an address or reference, not an arbitrary scalar pretending to be one. Zero or an address outside the Message's arena gives the no-type code under this receiver's contract. Codes come from the kernel's named region-type constants; numeric code values are not fixed by this specification. The interpreter and native execution use the same result contract. Ordinary native locals have no arena prefix: their logical place/type metadata cannot be obtained by blindly reading before a C address ([binding executors](#binding-executors)).

Встроенные машинные типы элементов сохраняют [смысл типов целевого профиля C99](L2_spec_ru.md#lowlevel-scope), включая знаковость обычного `char`; дескриптор не переопределяет их. L3 добавляет проверяемый доступ, а не другое представление примитивов.

Полный индекс N-мерного прямоугольного массива содержит N целочисленных координат. Для прямоугольного массива координаты сводятся к одному линейному индексу элемента, последний индекс меняется быстрее: `k = (...((i0 * d1 + i1) * d2 + i2)...)`. L3 проверяет только итоговый элемент относительно общей длины в дескрипторе: `0 <= k < length(array)`. Каждая координата отдельно с размерностью не сверяется, вектор длин размерностей ради этих проверок не хранится. Например, в прямоугольнике `[2,3]` координаты `[0,3]` дают линейный индекс 3 и выбирают тот же элемент, что `[1,0]`; линейный индекс 6 вызывает неявный `throw: interpreter`, а не возвращает `None`. Вычисление индекса не должно превращать математически выходящий за границы результат в допустимый элемент через машинное переполнение. Массив ссылок на массивы отличается: каждый шаг обращается к другому действительному Array со своим дескриптором.

Adjacent indices `matrix[i][j]` address one flat Array using strides known from its description, whereas `a[i]\[j]` addresses the previously selected reference value through the path separator ([paths](#fields)). The descriptor does not recover dimensions, and an incomplete index spelling does not by itself construct a separate row Array or hidden view descriptor. These access checks are made by L3, whether executed natively or interpreted, and by the interpreter when it executes L2 code; native [L2 access](L2_spec_ru.md#lowlevel-address), including obtaining a graph-backed element's address, works without them (the author's decision of 2026-11-18). Operation checks do not constitute a separate candidate-admission mechanism in place of [analysis and unit tests](#admission).

L2-индексация любой конечной мерности, включая `array[-1]`, — вычисление смещения и обычный доступ. Не порождать проверки length, знака индекса, принадлежности арене или требования бывшего поля. Знаковое смещение не превращать в ранний отказ через приём в size_t. Чтение, запись и взятие адреса используют один расчёт; L3 добавляет одну проверку итогового элемента, а не проверки каждой скобки.

Копия массива имеет отдельное хранилище; передача ссылки сама по себе его не создаёт. Возврат ссылки не должен скрыто копировать данные для исправления времени жизни. Совместное хранилище сохраняет обычные границы владельца Message.

<a id="array-operations"></a>
## 18. Операции над массивами

Арифметика и сравнения массивов по умолчанию поэлементные. Операция над элементом определяется его числовым доменом и явно выбранным контекстом. `*` означает поэлементное умножение, не матричное. `matmul`, `dot`, `contract` и `outer` — отдельные выраженные операции; профильный символ матричного умножения не должен делать обычное `*` двусмысленным.

`reduce` сворачивает элементы ассоциативной либо явно упорядоченной операцией. Контракт задаёт нейтральное значение, когда оно нужно, операцию элемента, тип результата и порядок. Для воспроизводимых вещественных/десятичных вычислений порядок не должен зависеть от случайного выбора backend.

`scan` — префиксная свёртка: включающий вариант суммы для `[1,2,3,4]` даёт `[1,3,6,10]`. Включающий или исключающий вариант выбирается явно. `map` применяет выражение к элементам; чистый вариант допускает векторизацию и параллельное вычисление с сохранением результата. Для эффектов необходим явный порядок; основной профиль предполагает чистое отображение.

`filter` отбирает элементы по логическому предикату и обычно материализует новый массив. Копирование, материализация и все результаты сохраняют границы владельца Message.

<a id="mathematics"></a>
## 19. Числовые операции, чистота и контексты

Числовые имена и операторы разрешаются в доступные конструкторы, явные описания и вызываемые операции. Семейства включают машинные целые и вещественные, `bigint`, `real`, `decimal`; это не обязательный закрытый список типов языка. GMP, MPFR и decNumber — возможные реализации, не исходная онтология L3. Преобразования задают диапазон, точность и округление по [контракту описаний](#descriptions).

A selected pure expression profile admits only operations with declared pure contracts; the general expression mechanism also supports the reached assignments and effectful calls described in §9. `sqrt`, `sin`, `cos`, `pow`, `abs`, `gcd`, rounding and arithmetic may have such wrappers. Effectful operations remain valid high-level receivers but do not become pure by being written in an expression. L3 does not prohibit effects generally or derive authority solely from a level number.

У низкоуровневой функции с сырыми указателями нет прямого L3-вызова. Высокоуровневая обёртка определяет владение, срок заимствования, политику нуля, границы, тип элементов, изменения, отказы и результат. Без неё доступна только машинная сторона [L2](L2_spec_ru.md#lowlevel-abi). Инициализация и освобождение числового backend обычно являются обязанностью провайдера; пользовательский числовой код не должен вручную имитировать его внутреннее хранение.

Контекст `real` может задавать точность, округление, статусы, traps и требования точности результата; `decimal` — также пределы экспоненты и квантование. Контекст является явно достижимыми данными или фиксированной конфигурацией профиля, не скрытым глобальным состоянием. Конкретные имена принимающих выражений контекста остаются профильными. Детерминированный профиль обязан исключать зависимость результата от неоговорённых платформенных настроек.

Массивы используют те же скалярные операции и контексты. Векторизация, свёртка и тензорная операция не создают другого смысла сложения. Минимальный профиль математики предусматривает базовую арифметику, логические операции, сравнения, конструирование и арифметику трёх расширенных числовых семейств, явные преобразования, выбранные чистые функции и операции числовых массивов. Доступность всей C-библиотеки из этого не следует.

<a id="composition"></a>
## 20. Композиция и копирование графа

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
| Consume two fields positionally | `(a b) := copy(Pair)` |

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

### Возвращаемый вложенный метод

A result that needs one copied Structure uses an explicit group, such as `return: (copy(Product))`; one-source `merge(Product)` is no longer the copying form. Multiple sources use `return: (merge(Model Values))`. The result description admits the constructed value and is not another source. Any needed activation values must enter through explicit source material or ordinary explicit operations; copy/merge do not silently capture a stack frame or give stored stack addresses longer life. A copied formal value can serve as a default and a copied free-name value as lexical fallback, under the ordinary call rules.

<a id="factory-reference-result"></a>
A reference receiver can retain a factory result, for example `@: product Factory\create()`, and later call a selected nested method. It adds no prefix `@` to obtain an ordinary Structure reference. `add5(1)` or `(\add5)(1)` calls a stored method reference; `\add5(1)` dereferences the call's result according to precedence. See the [factory example](LMX_semantics_guide.ru.md#factory-result).

### Binding, failures and other consumers

Copy/merge do not override [binding priorities](#binding-places). The private filter and transparent caller-place rule apply first where relevant; retained fallback still consults permitted dynamic sources before lexical ones. Explicit `node\...` selects the established lexical context. No result stream establishes a hidden closure or partial application.

Each receiver reports failure under its own contract: `copy` and `import` must not accidentally report `merge` merely because a low-level helper is shared. As with other implicit operator failures, an applicable ordinary catch handles the named failure; an uncaught failure stops the executing Thread under [§15](#exceptions). No partial-result publication or rollback of already completed source-expression effects is promised. Temporary storage follows the owning Message's lifetime rules; [L2 copying](L2_spec_ru.md#copy-merge) specifies mechanisms.

Schemas, type descriptions and tables use the same structural operation. Table row/key/conflict policies belong to their selected table consumer and do not alter model-slot or DATA repetition rules. Message storage transfer is a [different operation](#delivery): it transfers ownership without copying or lexical reparenting. The governing stream clarification is [the supplied 21 November TZ](TZ/LMX_Fable_TZ_Import_Copy_Merge_Field_Streams_2026-11-21.md).

<a id="registries"></a>
## 21. Таблицы, запросы, связывание и провайдеры

Registry, Table, RegistryView, схема и политика — роли обычных значений, не дополнительные категории или пространства имён. Операция получает корень реестра явно либо по выраженной ссылке. Наличие таблицы или строки с ключом `class`, `type`, `provides`, `satisfies` само по себе не запускает поиск и не меняет язык.

В табличном профиле первый столбец — ключ строки; `columns` задаёт имена и явные метаданные. Число ячеек плотных строк кратно числу столбцов, отсутствующая ячейка выражается явно; выравнивание текста полей не добавляет. Необязательное `source` запрашивает проекцию профиля транслятора, а не объявляет runtime-имена из ячеек. Ячейка может ссылаться на данные, ключ, описание, политику, диагностику, свидетельство, провайдера или вызываемое выражение.

Текстовый динамический запрос начинает с переданного корня и имён его упорядоченных детей; он не заменяет уже разрешённые структурные ссылки. Правила запроса, переменные, унификация, продолжения, приоритеты и конфликты принадлежат явно выбранным данным и политике потребителя, не общему правилу поиска поля Structure. Сохранённый результат проверки содержит явные зависимости и не даёт бессрочного разрешения будущим вызовам. Выбор кандидата проходит [общий допуск](#admission); ранжирование и публикация результата — отдельные явные действия.

Module linking resolves explicitly selected operations and construction recipes to physical references. A provider, codec or lowering rule is selected by an expressed reference, configuration or supplied Table; changing it is explicit. There is no automatic directory scan, process-global search, or implicit publication of names by a query. `import` exposes eligible constant declarations by reference through the current namespace; `copy` and `merge` copy or compose explicit sources. Table-storage and ambiguous-query ranking remain selected-profile policies. [Table and provider examples](LMX_semantics_guide.ru.md#tables-and-registries) give applications.

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
### Вывод текущего графа: sys\toLmx

`sys\toLmx` emits LMX text of the current graph with canonical names and retained comments. All receiver records and written grouping boundaries are preserved; namespace stream expansion does not replace source import/copy/merge records. Terminal primitive declarations are reconstructed from type, value and name. Formatting inserts blank lines only at intended full document-root boundaries so reparsing retains structure. An explicitly overwritten construct is emitted in its current form; neither history nor native reconstructs earlier source. Local execution does not publish its frame or replace the initializer in source data. This serialization differs from `sys\translate`, which returns L1 text for subsequent compilation and lowering errors.

The argument of `sys\toLmx(S)` selects the saved Structure. For an L3 Thread it also saves all tables of that Thread's arena, including call tables and native descriptors. The arena owns these tables; they are not fields of R0, and R0 is not the only eligible Thread. External arena tables are not silently attached to an arbitrary S. Preserve order and empty positions, shared references, cycles, names, and typed values: this is a reconstructable current graph, not merely source-like output. The clean graph holds no hidden data: all data lie in the `void *` storage of its Structures and are mapped by `toLmx` in an elementary way, while `length` and `parent` are derived from the text it forms (the author's decision of 2026-11-17). The table of names is restored by `fromLmx` from the text; it and the other tables of the kernel are data of the kernel itself, which builds itself and is written in L2 and L3 -- that is, the same Structures of the clean graph, not hidden data beside it. All program material, these tables included, lies in the clean LMX graph. The separate binary contains the compiled methods, including R0 and the interpreter; R0 accesses its graph through a local pointer. Portable C is generated for those method implementations along L3/L2 -> L1 -> C and does not supply a hidden static-data mirror of the graph. The translator is written in L2 and L3, and the L1 inserts are removed in the end too.

`sys\fromLmx` разбирает сохранённый граф общим кодом построения и интернирует имена в принимающей арене. Восстановление чистого графа после перезапуска на той же платформе не требует заново транслировать всю программу. Сохранённые native-дескрипторы связываются с готовым бинарным модулем и именами входов соответствующего ABI; прежние машинные адреса не копируются. Пути к L1/C сохраняются как данные, но не заменяют ссылку на бинарник и вход. Таблица capacity восстанавливается по выделенному storage, например с capacity = length; прежний резерв сохранять не требуется. Это задача реализации, а не утверждение готовности нынешнего графового dumper.

<a id="memory"></a>
## 22. Владение, достижимость и срок жизни

Каждый Message, исполняющийся или нет, владеет одной логической ареной изменяемых данных. Арена может включать несколько непересекающихся областей; это не дополнительные арены исходного языка. Вызов, блок, обработчик, ветвление и повторная попытка не создают своих семантических арен. L3 не выбирает арену аргументом операции.

Лексическая вложенность, владение памятью и достижимость — разные отношения. В одной арене может быть несколько лексических деревьев. При передаче владения блоками их адреса и `parent` сохраняются; новый владелец не становится автоматически лексическим родителем и не получает неявную прикладную ссылку на каждый принятый объект.

Живость определяется достижимостью, не членством в списке блоков. Корни включают корень Message, активные структурные аргументы, удерживаемые собственные поля, результаты, ссылки формальных и динамических входов, продолжения и явно сохранённые прикладные/служебные ссылки. Обход следует типизированным рёбрам графа, необходимым родителям, связи массива с backing и ссылочным элементам. Вспомогательный индекс имён не является корнем.

Live nodes and descriptors do not move merely because storage grows. Explicit graph assignment can replace the fragment selected by a structural cell; an old reference to the displaced fragment is not automatically a reference to its replacement. Descriptor stability and L3 descriptor-plus-index Array references retain their own contracts. Lexical exit does not destroy a reachable returned object; return requires no hidden copy or tree promotion. A stable address, however, does not guarantee indefinite life for an unreachable object.

В конце каждого такта выполняется один локальный проход сбора: определить исход такта, опубликовать успешные исходящие сообщения либо отбросить неуспешную подготовку, отпустить завершённые входные/временные корни, собрать арену владельца. Обычный возврат, `break`, `continue`, `retry`, `redo` и пойманный `throw` не являются отдельными точками сбора. Сохранившееся приостановленное продолжение удерживает свои ссылки.

Принятый граф, на который приложение не сохранило ссылок, после снятия временных корней может быть собран уже в конце такта, кроме лексически объявленных ветвей `independent: immutable` (с `const` или без него): их владелец сохраняет до удаления всей арены (§23). Передача арены не превращает прочий граф в вечный корень. Удерживаемая история отказа живёт по своей явной политике. Уничтожение Message в итоге освобождает его оставшееся хранилище; сбор не обходит чужую изменяемую арену и не требует глобальной блокировки.

A foreign resource has a separate ownership, retention, release and transfer contract. `copy`, serialization and `merge` do not invent native-resource duplication. Immutability of its identifier does not extend resource lifetime. The physical collector and the allocation of an arena's records are described in [L2](L2_spec_ru.md#arena).

<a id="eternal"></a>
## 23. Вечные ветви и общие методы

Совместная квалификация `independent: immutable` задаёт запечатанную неизменяемую независимую ветвь: у её корня `parent = 0`, содержимое и защищённые привязки неизменяемы. `const` можно добавить, но для сохранения адреса при `merge` и срока жизни до удаления арены он не требуется. Такая ветвь может быть лексически объявлена и внутри обычного тела, не только в корне Message. Владелец удерживает каждое её созданное вхождение до уничтожения всей своей арены, даже если обычный окружающий граф позже перестал на него ссылаться. Для начального лексически известного модуля владение ареной R0 даёт срок хранения до завершения процесса. Сама квалификация не выбирает глобального владельца и не определяет выгрузку будущего модуля. Ни одна из двух квалификаций отдельно не даёт этого контракта общего использования.

Начальная сборка процесса может создать известный трансляции неизменяемый типизированный массив физических ссылок на такие ветви и явно передать его корневому Message. Этот массив служит доступу и передаче известных ссылок, а не является условием удержания всех лексически объявленных ветвей в их арене. `merge` и создание Message не пополняют и не наследуют этот массив автоматически. Размещение ссылки в массиве не переподчиняет лексическое дерево ветви. Допустимая инициализация значениями времени выполнения происходит до публикации и не увеличивает множество записей.

Начальная сборка может разместить опубликованные ветви и их запечатанные записи в арене Root Thread (`R0`) тем же способом, которым типизированные массивы создаются в арене любого L3 Thread. Срок процесса получается из явного владения и удержания R0, а не из скрытой таблицы, особого класса хранилища или способности, доступной только корню. Сборщик не освобождает эти явно удерживаемые начальные диапазоны; ссылка на ветвь в другом Message является внешним терминалом для его сборщика и не переносит владение.

Принадлежность значения типу вечной ветви устанавливается так же, как принадлежность другим физическим типам: кодом в записи значения. Её запечатанный диапазон остаётся в обычной арене явного владельца; срок жизни задают удержание владельцем до уничтожения арены и запрет преждевременного сбора, а не отдельное постоянное хранилище. Перед переносом Message к новому надзирающему родителю проверяется иерархия Message: владелец каждой ветви `independent: immutable`, используемой переносимым Message или его потомками, должен остаться соответствующим Message либо одним из его новых Message-предков. Если владелец выпадет из этой цепи, перенос отказывается **до** изменения членства и ссылки на родителя: прежняя цепочка взаимного контроля больше не гарантировала бы существование арены владельца на протяжении жизни перенесённого Message. Перенос, сохраняющий это условие, не запрещается лишь из-за существования ветви. Здесь речь о надзирающем `Thread.parent` и сроке жизни арен, а не о структурном `Lmx.parent`, языковом `node` или лексической видимости имён. Эти правила не заменяют код типа в записи и не являются флагом отдельной ветви.

Переподчинение имеет явную форму `adopt: msg newParent`: `msg` — переносимый Message с исполняющим Thread, `newParent` — новый надзирающий Message с Thread. Оно не копирует ветви и не маскирует отказ. Если предварительная проверка владельцев не проходит, операция даёт обычный неявный отказ `adopt`, который принимает `catch: adopt ()`; до отказа ни членство в `Thread.children`, ни `Thread.parent` не меняются. Подготовка `independent: msg newParent` — отдельная явная операция: она копирует в арену `msg` только те фактически используемые им или его потомками вечные ветви, владельцы которых не остались бы в новой цепи предков, и перенаправляет соответствующие ссылки на копии. Она не переподчиняет Message. Копии сохраняют свойства `independent: immutable`, а общие ссылки и циклы сохраняются одной картой исходных адресов к копиям; частичная публикация при ошибке запрещена. Ветви, не мешающие именно этому переносу, остаются по прежним адресам. После подготовки `adopt: msg newParent` проходит обычную предварительную проверку заново. При неудаче подготовки действует обычный неявный отказ `independent`, без изменения опубликованного графа.

Известные записи методов — переиспользуемые нативные реализации, не вызываемые вхождения — также могут быть явно собраны в неизменяемый типизированный массив той же арены и переданы через физические ссылки. Дополнительный индекс вместе со ссылкой не образует идентичность записи. Метод не хранит лексического родителя; его конкретное вызываемое вхождение предоставляет собственную структуру. Разделяемые записи остаются живы после завершения заимствующего дочернего Message, только если их явный владелец продолжает их удерживать. Скрытого глобального или корневого реестра методов нет.

R0 удерживает неизменяемые независимые ветви начального модуля только потому, что владеет этим лексически фиксированным модулем, порождает начальных детей и может явно передать им заранее известные физические ссылки. Позднее подключённый DLL-подобный модуль имеет собственные запечатанные записи у своего владельца и в своей арене. Когда `merge` встречает его `independent: immutable` ветвь, с `const` или без него, потребитель получает в результате исходную физическую ссылку, а модуль остаётся владельцем. Это не превращает R0 в глобальное хранилище. Выгрузка такого модуля и срок жизни его диапазонов здесь не определены.

`merge` и создание Message сохраняют явно переданные ссылки на допущенные вечные ветви — по исключению квалифицированной ветви ([композиция](#composition)) — и на переиспользуемые нативные реализации методов как терминалы; обычное изменяемое вызываемое вхождение и его лексический контекст этим не разделяются, а копируются. Получение одной ветви не раскрывает массив удержания, настройки корня или остальные ветви. Изменяемое состояние по-прежнему копируется отдельно. Все ссылки внутри опубликованной вечной ветви должны иметь достаточный срок жизни; квалификация не делает случайную ссылку на освобождаемую память вечной.

Например, A и созданный из его шаблона B могут иметь один адрес вечной E и разные ячейки изменяемого x — это задуманное исключение для вечной ветви, а не ошибка псевдонимов. Завершение A и B не освобождает E. Одинаковое содержимое двух отдельно построенных ветвей не означает их автоматического интернирования. При переносе в другой процесс нативный адрес не становится сетевой идентичностью: нужен явный кодек.

<a id="messages"></a>
## 24. Message, актор и последовательный такт

A Message is an isolated graph with its own ownership. A plain template or letter is non-executable and may exist as a standalone minimal `LmxMsg`. An executable object is instead constructed as an L3 Thread from the beginning. Its `LmxMsg message` is the first member by value, so the Thread and its Message prefix have the same physical address. This common prefix supplies Message identity and operations only; it does not turn every Message into a Thread or put mail, scheduling, turn mode, or other Thread mechanisms into `LmxMsg`. A standalone Message cannot later be upgraded in place to a Thread. The type code of the record distinguishes standalone Message storage from Thread storage: the generic Message kind admits both, whereas access to the Thread-only tail requires the exact Thread type. Receiving a letter does not automatically create a thread or actor. Launching a separate child requires an explicit operation.

При создании `lmx_message` или `lmx_thread` в его собственную арену попадают только данные и физические ссылки, явно переданные создающей операцией. Состояние родителя, таблицы начальной сборки, массивы методов, вечные ветви и ссылки на сервисы не копируются и не наследуются неявно. Обычный L3 Thread может хранить и использовать всё доступное R0, если эти значения переданы ему явно.

Исполняющийся Message имеет FIFO-почту и не более одного активного такта одновременно. За такт потребляется не более одного допущенного входа. Между разными Message возможна параллельность. Пустой ящик не означает завершение фоновой задачи: механизм продолжает проверять почту согласно своему режиму исполнения до условия остановки.

Во время такта один L3 Message исполняется ровно одним потоком ОС; передача другому рабочему потоку возможна только между тактами. У L3 Thread нет режима исполнения: путь каждого вызова определяет дескриптор вызываемого вхождения — с нативным адресом вызов исполняется нативно, без адреса тело (op-дерево графа) исполняет интерпретатор — код L2 с теми же проверками, что и код L3 ([§1](#scope)). Один вызов не запускает оба пути для одного Message: диспетчер не повторяет вызов другим путём после ошибки и не подменяет путь, заданный дескриптором, ни по телу, ни по результату предыдущей диспетчеризации. Выбор пути не создаёт копию метода или второй параллельный исполнитель; `implements` и другие принимающие выражения диспетчер сам не запускает.

Одна арена имеет одну полосу записи. Обработчик, локальное управление, планировщик и служебные данные Message изменяются на его полосе. Чужой отправитель не дописывает себя в ready-list владельца и не меняет его прикладные данные. Исключение приёма почты и специальные одноячеечные протоколы управления относятся к механизму Message, не дают общего доступа к чужой памяти.

A parent manages only its direct children. Sole membership is the ordinary variable-length reference Array held by `Thread.children` in the parent's arena, and the parent's scheduler traverses that exact Array ([L2 §8](L2_spec_ru.md#thread)). This runtime membership does not append fields to the source Structure. A family-record chain, manager membership queue, fixed group of slots, or any other parallel child registry is forbidden. Local traversal-order policy belongs to the parent but does not become a second membership source. Each child likewise manages its own children. There is no separate global language scheduler, shared mutable Message registry, or global management lock. A router, if needed, is itself a Message with private state.

R0 является обычным L3 Thread в этом дереве и по умолчанию не имеет функций, которых нет у другого L3 Thread. Его родитель-каркас представляет верхний элемент будущего WorldWideMix и связывается с R0 обычным механизмом родителя; это надзор Message, а не лексическая связь `node`. Только сам верхний каркас не имеет родителя, но дополнительных функций от этого не получает. Внешний host-watchdog, а не каркас или R0, задаёт общий срок ожидания закрытия поддерева и завершает процесс ОС, если обычный каскад не достиг безопасной границы. Особого массива детей, иной схемы планирования или числовой идентичности для R0 нет.

L3 Thread — логическая последовательная полоса, не обещание отдельного потока ОС. Возможны собственный поток и выполнение тактов родителем/платформенным адаптером. API и политика отображения задаются реализацией L2; это не разрешает одновременно выполнять два такта одного владельца. Опрос жизнеспособности родителя и собственное обслуживание нужны и актору без детей.

Первоначальный граф процесса принадлежит корневому Message. Служебные данные запуска и начальные настройки удерживаются уже определённым родителем-заглушкой R0; ссылки на настройки и пользовательский ввод передаются явно при входе, без добавления неявных полей в исходный граф программы; последующая координация выполняется сообщениями. Группировка ролей Mix, курсоров, страниц и уведомлений по Message остаётся выбором проектирования: не требуется ни один актор на весь документ, ни отдельный актор на каждую ячейку.

<a id="addressing"></a>
<a id="delivery"></a>
## 25. Доставка, владение и порядок изменений

Локальный промежуточный уровень адресует участников физическими адресами памяти в рамках допускаемых операций механизма Message. Иерархическая цепочка индексов относится к [WorldWideMix](#worldwide), начиная с третьего масштаба организации, а не к каждому локальному письму. Масштаб организации не следует смешивать с профилем языка L3. Нативный адрес не сериализуется как переносимый адрес другой машины.

Каждый L3 Thread владеет собственным почтовым ящиком и его API. Явно переданный родителем сервис доставки разрешает адрес и доставляет письмо к операции приёма целевого ящика; он не смотрит и не читает содержимое ящика. Сервис доставки не исполняет получателя, не планирует его такты и не ведёт реестр членства детей.

Доставка существующего неисполняющегося Message может передавать владение его хранилищем получателю без перемещения данных. Блоки и классификация областей переходят в единую арену получателя, бывший владелец больше не освобождает их. Лексические связи остаются прежними; прикладное включение принятого корня выполняется явно. Передача хранилища не равна созданию копии и не сохраняет отправленный объект как второго независимого владельца.

Создание нового исполняющегося Message из шаблона использует [копирование графа](#composition) и его отдельную арену. Обычные настройки копируются, допущенные вечные ссылки сохраняются — по тому же исключению квалифицированной ветви, что у [`merge`](#composition); отдельной политики копирования для Message нет. Создание не импортирует неявно всё живое окружение родителя. Передача надзора над работающим ребёнком, передача остановленного хранилища и сериализация удалённого сообщения — три разных контракта.

Одновременные поступления не имеют заранее заданного относительного порядка. Приём в ящик устанавливает FIFO-порядок, который сохраняется при потреблении. Ни случайное перемешивание, ни порядок по часам отправителей не являются правилом. Проверка пустоты и ожидание согласованы с приёмом: уже принятое письмо не должно потеряться при переходе получателя в ожидание. Вместимость, обратное давление и повторная доставка — явные политики реализации/протокола.

Несколько отправителей изменяют один объект, посылая полную операцию владельцу. Например, `add(2)` и `add(5)` при начальном 0 дают 7 в любом из двух порядков приёма. Раздельные `read` и `write` не образуют одной защищённой операции: два отправителя могут прочесть 10 и оба записать 11. Последовательные такты предотвращают перекрытие исполнения, не создают транзакционный откат или защиту разорванного протокола.

Успех доставки означает принятие, не выполнение прикладного изменения. Для результата нужна предусмотренная протоколом корреляция ответа. Ядро не добавляет автоматически историю последних идентификаторов и подавление повторов каждого отправителя. Требования дедупликации, повторов, пакетирования и сортировки выражаются отдельным протоколом, не меняющим базовый FIFO.

Исходящие письма текущего такта подготавливаются отдельно от опубликованной очереди. Успешная граница публикует их в порядке подготовки; неуспешная отбрасывает неопубликованное. Уже выполненные изменения графа этим не откатываются. Граница [сбора](#memory) наступает после обработки результата и временных корней.

<a id="lifecycle"></a>
## 26. Завершение, дети и сохранение результата отказа

`success` исполняемого Message ставит только пользовательский код: система никогда не сбрасывает его в 0, даже при ошибке, и не ставит 1 сама; `success = 1` — достаточное условие остановки Thread на end turn. Система ставит `success = 1` только простому письму при его доставке. Пустой ящик успехом не является. После установки `success` основной алгоритм Message не получает следующий такт; завершение локального обслуживания детей зависит от реализации. `running = 0` во время работы может быть запросом остановки: физическая безопасность передачи хранилища устанавливается отдельным протоколом, не угадывается по одному флагу.

A child checks parent liveness and begins its own orderly close after sustained lack of response. Forced closure from above is the second, emergency path. A parent services physical addressees from the sole reference Array of its direct children held by `Thread.children` rather than arbitrarily managing grandchildren. Each child repeats the cascade for its own child Array; closing propagates through the family instead of retaining a released branch forever.

Работающий ребёнок может пережить закрытие родителя только при явной передаче надзора другому живому родителю с подходящим полномочием. Он сохраняет свою арену, почту и такт; меняется надзор и место в планировании. Это не усыновление памяти. При передаче памяти неисполняющийся источник прекращает отдельную жизнь; новые дети из принятого содержимого принадлежат уже получателю.

Неуспешное остановленное состояние может быть передано родителю без копии и удержано как граф истории отказа; успешная история по умолчанию освобождается. Передача требует остановленного, безопасного для передачи состояния и отсутствия нативных пользователей. Необходимо сохранять различие запроса остановки, фактического выхода, безопасной передачи и освобождения; конкретные флаги и их размещение относятся к [ядру L2](L2_spec_ru.md#message).

Оставшийся без родителя участник закрывается по политике сирот: успешное завершение освобождает его, неуспешная история может сохраняться до явно заданного срока. Эта политика не создаёт второй глобальный реестр или отдельного бессрочного владельца вне Message.

<a id="pipeline"></a>
## 27. Допуск и исполнение входящего сообщения

Входящие данные проходят явный декодер и становятся графом Message. Затем выбираются адресат, маршрут и принимающее выражение через заданные ссылки или поиск от заданного корня. Ни текст сообщения, ни ссылка на таблицу не устанавливают скрытое окружение и не дают автоматического доверия.

Candidate admission follows the [unified mechanism](#admission): checking structural suitability for actual Consumer calls, followed by the receiving expression's required analytical checks, `test`. This incoming-admission stage operates on the constructed graph through the common execution mechanism. Interpreter-led validation does not force every checking-expression, candidate or helper call onto the walker: each reached call retains ordinary native/walker dispatch and the same binding, reception and failure contracts. Text decoding constructs the input graph before this stage; admission does not interpret source text instead of the graph.

Маршрут, полномочия, срок жизни и допустимые эффекты представлены явными данными контракта. Проверки свойств кандидата включаются в тесты принимающего выражения; криптографические операции могут предоставить проверяемые факты. Свидетельство хранит ссылку на конкретные данные, политику и установленные на входе факты. Повторное использование результата допустимо только по явному контракту применимости из [валидации кандидата](#graph-tests).

После допуска выбирается явная ссылка на реализацию/провайдер и строится план исполнения с аргументами, результатами и необходимыми политиками. Формирование плана не исполняет выбранную прикладную операцию, хотя этап допуска уже исполнял её тесты. Исполнитель следует зафиксированной ссылке. Результат или объявленный отказ становится входом следующего явного потребителя.

Логический генератор может построить ноль или несколько предложенных Message. Каждый снова проходит тот же путь; происхождение от генератора не даёт доверия. Полученный текст не переносит работающий кадр чужого актора. Работа выполняется в последовательном такте получателя, если отдельный запуск ребёнка не указан явно.

<a id="thread-message-api"></a>
## 28. Обычные вызовы LMX через Message-транспорт: `post` и ожидания ответов

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

`post`, `send`, and `receive` use one inbox, one set of publication/ownership rules, and one call engine. The public `send`/`receive` forms (`sendMessage`/`receiveMessage` before the renaming of 2026-11-10), address-filtered iterator, all-available-mail option, and `0` end marker remain. One letter cannot be consumed twice by manual and protocol paths; receiving a letter as data does not itself execute its contents. An incoming call runs on the recipient's lane, while `answer` and outcome handlers run on the sender's lane. Both Thread modes (with and without an OS thread), the ordinary lifecycle up to user `success := 1`, final outbound publication, and existing supervision/stopping remain; `post` adds no second entry loop, inbox, or timer thread.

[Пояснение исходов обмена](LMX_semantics_guide.ru.md#post-transport) находится рядом со спецификацией и не добавляет новых правил.

<a id="mix"></a>
## 29. Mix: активные метки и интервалы

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

<a id="worldwide"></a>
## 30. WorldWideMix: адреса, ячейки и навигация

WorldWideMix задаёт дерево размещения: где находится ячейка. Граф LMX задаёт значение: какие поля оно имеет и что потребляет выражение. Эти деревья встречаются в ячейке, но не совпадают: адрес `3.17.4` не является полевым путём `file\close`, а `implements` не нумерует соседей Mix.

Адрес — последовательность неотрицательных целых от корня до ячейки. Глубина отдельной ветви и величина индекса не имеют установленного языком конечного потолка; реализация обязана проверять реальные ресурсные пределы, не переполнять представление. Ведущие нули текстовой формы значения не меняют: `03.17` и `3.17` равны. Префикс адресует поддерево, сокращение пути ведёт к предку.

Числа считают соседние позиции, не байты. Размер ячейки может соответствовать слову, буферу или ссылке на значение. Varint, цепочка полей разной ширины и другие кодеки — способы хранения одних чисел, не различные типы адреса. Переход с 5 на 12 бит не переименовывает `3.17`. Примеры десятков соседей в памяти и большего числа в секторе диска иллюстрируют носитель, не ограничивают адресную модель.

Ветви могут иметь разную глубину. Для префикса P группа `bunch(P)` содержит только занятые непосредственные индексы. Если заняты `{0,4,5}`, то после `P.4` идёт `P.5`, перед ним — `P.0`. `next`/`prev` не спускаются в детей, не поднимаются к родителю и не обходят все документы мира. `down`/`up` меняют глубину; `next`/`prev` меняют последний индекс внутри одной группы.

Курсор — путь плюс позиция внутри буферной ячейки, если она нужна. Вставка/удаление затрагивает соответствующий уровень соседей, не переадресует «все последующие байты файла». Документ — корень, дерево размещения и слой меток; файл является одним способом сериализации страниц. Человеческое имя, realm, том и глава — атрибуты и соглашения профиля, не DNS и не фиксированное число уровней.

Носителем может быть память, диск, провод, радио или переносимое хранилище; Интернет и HTTP не обязательны. Сообщение может передать короткий адрес, полномочие и сведения о потребителе вместо полного большого тела. Потребитель читает нужные части курсором. Тип содержимого устанавливается по значению LMX и [допуску](#admission), не по Mix-адресу, MIME или расширению файла.

Сортировочные сервисы размещаются за границей отдельного приложения, на узлах WorldWideMix, соответствующих дереву размещения и маршрутам между его частями. Они могут накапливать, группировать и раскладывать письма по адресатам там, где задержки носителя делают такую обработку полезной. Это не второй круг локальной почты и не обязательный посредник между L3 Thread одного процесса: локальная почтовая коллекция сохраняет свой базовый FIFO-контракт. Ёмкость буфера сортировщика, политика его переполнения и прямой отправки задаются конкретным транспортным профилем, а не семантикой L3.

Mix-слой размещает на тех же позициях пересекающиеся метки, курсоры, атрибуты и интервалы. Составление значения страницы следует общему [контракту `merge`](#composition); адреса соседних ячеек при этом не переопределяются. Заполнение диска не даёт права автоматически вытеснить данные к произвольному соседу: отказ, уплотнение или явно разрешённое зеркало задаются профилем хранения.

<a id="mix-coordination"></a>
## 31. Координация префиксов и зеркала

Изменяемым состоянием Mix владеет Message. Запрос изменения адресуется владельцу и выполняется в его последовательном такте. Конкурирующим отправителям одного владельца достаточно FIFO; дополнительное получение разрешения-блокировки не требуется только из-за одновременности отправителей.

Логическое исключение изменений по префиксу — отдельно выбираемый протокол Message, не нативный межмашинный mutex и не обязательная часть каждой операции. Резервация P охватывает всё поддерево P, включая более глубокие группы. Координатор общего префикса согласует затронутых владельцев, но не записывает напрямую в их арены и не планирует произвольно их потомков.

Резервация `34.3.7` не мешает независимой `34.3.1`; резервация `34.3` должна учитывать конфликты обеих ветвей. Протокол обязан определить момент действия исключения, судьбу уже принятых команд и защиту от поздней команды по отозванному разрешению. Полномочие запросить изменение и действующая резервация — разные факты. Наличие записи у координатора само по себе ещё не обеспечивает соблюдение всеми путями записи.

Исключение по префиксу не означает распределённую транзакцию, общий откат или физически одновременное изменение. Для времени действия T нужны правила неопределённости часов, опоздания, недоставки и частичного отказа. Тайм-аут не доказывает, что прежний участник остановился. Форматы grant/token, поколения, повторов и восстановления остаются явными решениями протокола, а не неявными обязательствами каждого Message.

Зеркало — другой префикс с соответствующим содержимым для конкретного потребителя, не отдельный фундаментальный вид документа. Записи идут первичному владельцу, изменения доставляются зеркалу сообщениями. Читатель может допускать отставание; запись по устаревшему зеркалу не становится безопасной автоматически. Имя зеркала — атрибут, адрес — его собственный путь.

Эквивалентность первичного значения и зеркала относительна к используемому дереву и тестам принимающего выражения. Она не означает вечное равенство байтов. Проекция «последнее значение побеждает» допустима для выбранного renderer, но не уничтожает полную цепочку вхождений. История и undo могут быть потребителями изменений Mix; новая версия всего документа после каждой правки не является правилом ядра.

<a id="transport"></a>
## 32. HTTP и границы сервиса

HTTP/REST LMX — транспортный профиль, не ядро исполнения и не WorldWideMix. Сервис представляет собой взаимодействующие Message, не общую изменяемую кучу. Внешний запрос преобразуется в Message, затем проходит [приём и допуск](#pipeline), исполнение и отображение результата в транспортный ответ.

Цель HTTP-запроса складывается из нормализованных endpoint и route. Пример: endpoint `https://archive.example.org` и route `/inbox/save`. Получатель разрешает локальный маршрут в явно заданной таблице. Маршрут не именует поток ОС, не раскрывает сырой дескриптор Thread и сам по себе не даёт полномочий.

Исходный профиль отправляет полный документ LMX методом POST с `application/lmx`. Провайдер получает URI и точную последовательность байтов, возвращая транспортный отказ или статус приёма. Замена провайдера тестовым, WinHTTP, libcurl или другим адаптером не меняет Message-семантику. Универсальный процессный HTTP singleton из этого не следует.

Синхронный профиль может вернуть семантический ответ в HTTP-ответе; асинхронный — подтвердить приём и позднее доставить Message на `replyTo`. Семантический ответ содержит `correlation`, соответствующую `id` запроса. Приём, исполнение и прикладной успех остаются различными событиями.

Вместо большого тела допускается явно переданный курсор с диапазоном и режимом чтения. Его адрес, права и срок жизни входят в контракт принимающего выражения. Чтение сжатой части, расшифрование и миграция формата — явные операции; переданный `targetDescriptor` остаётся обычными данными, не скрытым дескриптором каждого значения.

Исходный пример внешнего тела передаёт ссылку на сегмент, диапазон и режим чтения. Полномочия и срок жизни курсора проверяются в составе юнит-тестов принимающего выражения; короткий конверт не отменяет допуска данных, которые затем будут прочитаны.

```text
    message:
        id: "report-42"
        to:
            route: "/reports/process"
        end: to
        expression:
            process:
                body:
                    cursor: reportStore\flightLog\segment42
                    range: current
                    mode: readStream
                end: body
            end: process
        end: expression
    end: message
```

Декларативное правило маршрутизации ниже является данными профиля. Оно исполняется отдельным принимающим выражением, которое интерпретирует условие и создаёт доставляемое сообщение; сама запись правила не выполняет вложенный `send`.

```text
    route:
        when:
            `equals.data`[userRole][admin]: true
        send:
            to: AdminService
            expression:
                openPanel
    end: route
```

<a id="authentication"></a>
## 33. Идентификация, полномочия и свидетельства

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

<a id="crypto-values"></a>
## 34. Криптографические значения и провайдеры

L3 выражает криптографическое намерение, связи ключей, политику и состояние протокола. Провайдер реализует примитивы, защищённое хранение и платформенный интерфейс. Приведённые названия обозначают семантические роли контрактов; конкретный профиль связывает их с receiver и структурой типов. Провайдер выбирается явно по профилю, ссылке, capability, конфигурации или сервису.

AlgorithmId содержит семейство, алгоритм, версию/профиль и существенные параметры. Параметры, влияющие на совместимость байтов протокола, явно заданы либо фиксированы именованным профилем. Подмена алгоритма и скрытый downgrade запрещены. Отсутствующий статически обязательный провайдер вызывает ошибку сборки/связывания; неподдержанный динамический выбор — явный отказ операции.

PublicKey — обычные несекретные данные с алгоритмом, форматом и байтами ключа, необязательными id/метаданными. Их можно копировать, хранить и передавать. Raw, SPKI, JWK и иные кодирования являются явным выбором; внутренний объект провайдера не является форматом обмена.

KeyRef — непрозрачное полномочие на секретный ключ с контрактом владельца-провайдера, операций, срока жизни и экспорта. Это не сырой L2-адрес и не обязательный массив секретных байтов. KeyPair объединяет PublicKey и private KeyRef. Генерация не публикует приватный материал в граф автоматически; неэкспортируемый ключ — допустимая реализация.

Verifier явно обозначает алгоритм, формат/версию, salt и параметры проверки: стоимость памяти, времени/итераций и параллелизма, а также результат или каноническое кодирование. KeyPolicy может задавать использование, сроки, ротацию, отзыв, версии, связь с объектом, экспорт и получателей; точную структуру политики определяет выбранный профиль.

Передача KeyRef, возврат, сохранение в поле, композиция и смена провайдера не экспортируют секрет. Контракт определяет локальное использование разными Message, retain/transfer и допустимость сериализации. Переносимый исходный вариант — локальность провайдеру/runtime и отсутствие wire-сериализации. Передача секрета на другую машину требует явного разрешённого export/import или защищённого конверта.

Для криптографически защищённой ветви графа зашифрованная форма хранения или передачи и расшифрованное рабочее представление — разные случаи одного контракта защиты. Выбранные владелец/провайдер и профиль должны контролировать расшифрованные данные, credentials и ключи, используемые допущенной операцией, и явно определять их время жизни и разрешённое раскрытие. Расшифрование для использования не публикует автоматически открытый граф каждому держателю обычного доступного интерфейса. Провайдер не вправе обещать конфиденциальность во время использования, если не обеспечивает заявленную границу; одного шифрования хранилища, отсутствующего исходного имени или квалификатора для такой гарантии недостаточно. Это требование не предписывает обязательного провайдера, алгоритма или нового представления графа и не расширяет перечисленные ниже гарантии защищённой памяти.

Защищённая память — набор отдельных возможностей: контролируемое секретное хранилище, очистка, page locking, guard pages, неэкспортируемость, аппаратная защита. Одна не подразумевает остальные. Нельзя обещать удаление копий, которыми провайдер не владеет, в UI, VM или host. Синхронный вызов, сервисное сообщение и асинхронный адаптер могут реализовать один контракт, не вводя нового общего планировщика или готового `await` языка.

<a id="crypto-operations"></a>
## 35. Контракты криптографических операций

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
