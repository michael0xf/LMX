**Lingvamyxa (hereafter LMX) is a language in which a program is a lexical forest of primitive arrays connected into a dynamic graph.** This organization repeats self-similarly at the level of local actors with physical memory addressing and further at the level of remote intermachine messages with composite addressing.

**Both data and executable bodies are arrays**, represented by the same simple universal structures; every executable body is a complete abstract expression.

**Typing is analytical, at the level of lexical branches.** Admitting any candidate as an argument to any expression requires analytical compatibility checking and mandatory runtime validation by unit tests specified by the receiving expression. Tested candidates and checking expressions are uniquely identified by their physical addresses.

LMX is also a grammar capable of representing both data in a complex, uniquely structured hierarchical and tabular form with intersecting sets and, in principle, any language. See the [complete grammar specification](LMX_grammar.en.md).

**Language levels.**

- **L0** is native code: microprocessor instructions or virtual-machine instructions. For a microprocessor, the translation chain is **L3 → L2 → L1 → C99 → L0**; for a virtual machine, it is **L3 → L0** directly. Arrows denote translation stages.
- **L1** is the level of the L1 language and C99, described in [L1_spec_en.md](L1_spec_en.md) and [L1_spec_ru.md](L1_spec_ru.md).
- **L2** is LMX itself with low-level operations, described in the [L2 specification](L2_spec_en.md).
- **L3** is pure, hermetic LMX. Its semantics are the subject of this main specification.

<!-- semantics-toc -->

- [1. Language scope and execution modes](#scope)
- [2. Values, Structures and Arrays](#values)
- [3. Identity and lexical trees](#identity)
- [4. Names and paths](#fields)
- [5. Explicit value descriptions and conversions](#descriptions)
- [6. Message-local type bindings and conversion context](#conversion-context)
- [7. Analytical checking and candidate validation](#admission)
- [8. Obtaining a required guarantee: fourteen practical cases](#admission-recipes)
- [9. Value construction](#construction)
- [10. const, immutable and independent](#qualification)
- [11. Callable expressions and their interfaces](#callables)
- [12. Dynamic inputs and working state](#dynamic)
- [13. Branches and loops](#branches)
- [14. Exits and finally](#exits)
- [15. Declared failures and diagnostics](#exceptions)
- [16. Restart and suspension](#suspension)
- [17. Arrays and backing](#arrays)
- [18. Array operations](#array-operations)
- [19. Numeric operations, purity and contexts](#mathematics)
- [20. Composition and graph copying](#composition)
- [21. Tables, queries, linking and providers](#registries)
- [22. Ownership, reachability and lifetime](#memory)
- [23. Eternal branches and shared methods](#eternal)
- [24. Message, actor and serial turn](#messages)
- [25. Delivery, ownership and mutation order](#delivery)
- [26. Completion, children and retained failure state](#lifecycle)
- [27. Incoming-message admission and execution](#pipeline)
- [28. Ordinary LMX calls over Message transport: `post` and reply waits](#thread-message-api)
- [29. Mix: active marks and intervals](#mix)
- [30. WorldWideMix: addresses, cells and navigation](#worldwide)
- [31. Prefix coordination and mirrors](#mix-coordination)
- [32. HTTP and service boundaries](#transport)
- [33. Authentication, authority and evidence](#authentication)
- [34. Cryptographic values and providers](#crypto-values)
- [35. Cryptographic operation contracts](#crypto-operations)

<a id="scope"></a>
## 1. Language scope and execution modes

Static compilation may provide a native implementation for an executable Structure body, including the file root. For a Structure containing only field fillings, with no executable call or L2 operation, investigate the early optimization of omitting `native`; this does not change its graph semantics. The root has no separate generation or call rule: dispatch between native entry and interpreter depends only on whether the callable Structure occurrence has a native implementation. A Structure constructed at run time without one remains interpretable if its body belongs to L3.

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

<a id="values"></a>
## 2. Values, Structures and Arrays

A Structure is an ordered collection of direct fields. Fields hold references to values: primitive cells, other Structures (including Arrays) and method records. Lexical nesting forms a forest; additional references connect it into a graph containing shared objects and cycles. A primitive cell does not acquire a Structure wrapper merely because a field references it.

An Array is an ordinary graph Structure with its own structural `parent`; receiver `[]` supplies its elements and their storage type rather than creating a separate family of language objects. An Array contains elements of one type. Its length counts Array elements, while the containing Structure's field count counts its direct fields. An Array of references to Arrays differs from a rectangular multidimensional Array. Nesting `a: b: c: d: ...` is the general form of receiving-expression application and has no fixed depth limit. `[]: []:` applies the ordinary Array receiver through that general form; it is not a separate construct or a special array-of-arrays type. An Array element may be a primitive or a reference to a nonprimitive value under the ordinary storage rules; each independent Array has its own length. The C-like head `[][][]` denotes a flat rectangular multidimensional Array and is unrelated to composing separate `[]:` receivers. Dimensionality is not recovered from physical storage. An intermediate Array can be bound to a name through ordinary typed binding: for `[]: []: []: a`, the steps `[]: []: b a[i]` and `[]: c: b[j]` each index one independent Array without copying a nonprimitive value. Direct access through multiple Arrays uses the ordinary path `a[i]\[j]\[k]` ([paths](#fields)), not adjacent indices of a flat Array. For example, `char: []: []: mainArgs` uses the same general nesting for an Array of strings: each string is an independent `char` Array of exact length `len` without a trailing NUL (`LmxCharArray`, [L2 §5](L2_spec_en.md#method-array)); NUL belongs to the `c.*` door representation, not the graph value. Representation and address-range cell classification are specified in [L2](L2_spec_en.md#type-by-range).

An empty Structure is a present value with zero fields. It differs from an absent field, numeric zero, and `void`, which denotes no primitive-cell content. A Frame's argument list is itself a Structure; the sole anonymous Structure occupying the entire list is transparent already in P0 normalization: its fields become the list's fields, independently of the head and whether it is empty. Thus `f()`, `f: ()`, and an explicitly closed empty vertical body yield one tree with an empty body; `f(a b)` and `f: (a b)` yield one list as well. An anonymous Structure among other fields or in a named position remains a distinct value. Passing an empty Structure as one value requires such a nontransparent position; see [empty bodies](LMX_grammar.en.md#empty-colon).

`None` is contextual: its representation is defined by the type expected by the receiving expression. There is no encoding shared by all types; a type without a corresponding definition of `None` does not accept it. The numeral `0` remains zero and means false in logical operations; it is not a universal absence marker. The earlier `Boolean` profile uses the range −1…1: `None = −1`, false is 0 and true is 1. This is a particular profile definition, not the universal encoding of missing values.

Text, images, decimal notation and machine words are substrate storage before recognition by a receiving expression. After parsing or decoding, they are values of the same graph. Format and numeric-library names do not introduce additional fundamental value kinds.

<a id="identity"></a>
## 3. Identity and lexical trees

Live Structures, including Arrays, and local Messages retain their physical addresses. A record's physical address is the Message's in-process identity; local identity is not supplemented by a parent index. Storage grows by adding new regions; existing objects do not move. Equal contents do not imply object identity. Explicit copying creates new identities and preserves relationships under the [copying rules](#composition). Hierarchical index chains belong only to [WorldWideMix](#worldwide).

A lexical parent determines a Structure's position in its tree; a root has no parent. Storage ownership and lexical ancestry are independent. Attaching another Message's storage preserves existing lexical links, does not itself add a reference from the recipient's root and does not make the adopted root a lexical child of the recipient.

The [independent qualifier](#qualification) cuts the external lexical parent at construction; obtaining inputs from the caller follows [dynamic visibility](#dynamic). Neither mechanism changes storage ownership or object identity.

<a id="references"></a>
<a id="fields"></a>
## 4. Names and paths

Names resolve source-level accesses; execution follows the resulting references and positions. Source-entity names are not stored anywhere in the graph: not on atoms, Structures, fields, methods or applications. A separate address-to-source-name table supplies names when serializing the current graph and for inspection; it is not a variable-binding table, a type or an execution identifier. It serves translation and `toLmx` only; execution never consults it, under any conditions: construction, copying and calls, including the formation of a call's inputs, follow the references, addresses and positions resolved at translation. Anonymous and positional values need no synthetic names. Physical tree storage is defined in [L2 §2.1](L2_spec_en.md#interpretable-tree); current-graph serialization is defined by the [toLmx contract](#source-codec).

A structural path `object\field\nested` selects graph fields in sequence. Each step's presence and validity are determined by the selected object. A computed path is not replaced by an invented statically known name. Reserved `node` denotes the lexical space above the method and stays fixed throughout that method activation; `node\field` starts explicit traversal in that space. A bare `field` obtained by lexical fallback is supplied as a hidden argument of the current activation and is not identical to the explicit `node\field` path.

A path may contain an unnamed index step `a\[i]` selecting a typed Array element. `a[i][j]` addresses a rectangular multidimensional Array, whereas `a[i]\[j]` indexes a separate Array obtained through the value of `a[i]`; `a[i]\[j]\[k]` follows further references. Index steps may be mixed with Structure fields to any finite depth. In a Structure used as `data`, `s\[N]field` with zero-based `N` selects the Nth source occurrence of a root-level `field:` head; nested heads belong to their initializers. This is neither the Nth same-named data field nor an Array step. With one occurrence, `s\field` is allowed; with two or more it is ambiguous and an index is required. Multiple same-named data fields remain forbidden, and the first source occurrence is not selected automatically.

The `data` scanner sees only direct root heads: a root-level `if:` is itself one `if` head, but a `y:` inside its body does not become a root-level `y` head. The same rule applies to the other inline operators.

`node` is a reserved language word. It cannot be declared, shadowed, rebound or dynamically supplied as a same-named value, including by quoted identifier spelling. In lowering it is literally the mandatory first `Lmx *node` parameter (`@: Lmx node` in L1): the physical reference to the lexical space above the selected method. No wrapper, closure or namespace object is inserted between source `node` and that address. In the working graph every callable occurrence, `if` body, loop and other nested Structure separately holds an ordinary `parent` link to its immediately enclosing Structure. For a callable occurrence that link supplies the above-method space passed as `node`; nested bodies may have an arbitrary internal `parent` chain, but that chain never rebinds the activation's `node` parameter. `parent` is neither a reserved language word nor a program-visible alias: it is an implementation field traversed by lexical and dynamic visibility. A bare `field` supplied as a hidden argument is local with respect to the caller and the above-method space. Assigning that name (`field: value`) updates this local value and creates no field, neither during execution nor by the translator preallocating one; nothing is written into the hidden argument's source, and no method state arises from it ([working state](#dynamic)). A field exists only where a declaration puts it; a declared own field goes through the working copy and publication. Mutating the above-method graph requires explicit `node\field: value`.

| Name | Where it exists | Meaning |
| --- | --- | --- |
| `node` | reserved L3 word and first method ABI parameter | space above the method; fixed for the whole activation, including nested bodies |
| `parent` | ordinary field of every working-graph `Lmx` Structure | immediately enclosing Structure; differs for a method, `if`, loop and other nested bodies |
| `self` | hidden ABI context only | the active Structure of this call; not a language word |

One immediately enclosing Structure has one namespace and one field per name. The first definition of a place creates its field; a later use of the same place assigns after contract checking instead of creating a second same-named field. This general rule applies to primitives, references, and ordinary Structures; the place's head and value receiver compose under the [single model](#resolved-head-consumption). Within one callable activation, source nesting depth does not create shadowing: an explicit `call` or method invocation (`fn` and other callables) establishes a different activation, while mere Structure nesting and inline `if`/`for` operators do not. Method fields reside in its explicit `var` part under the [callable rule](#method-parts). `merge` of fields with the same name in different operands writes into the model's slot under the [composition rule](#composition). A named path selects the sole field at that level, including through an [admitted reference](#admission); its physical position may differ between model and candidate.

Shadowing belongs to a distinct binding scope: on `call` (as on a method invocation), the called occurrence's own place may hide a same-named outer place. Nested `if`, `for`, and other inline Structures are operators of that same activation, not new declarations or binding scopes, despite physically being Structures. An executable `name: ... end: name` form or analogous write in that body assigns to the prepared same-named place in the selected data Structure regardless of source depth in `code`; an inline operator has no separate local data place. The `data` map considers its root-level heads but does not lift nested heads out of initializers. Multiple source occurrences of one head are not disambiguated by choosing the first: explicit access requires an index. The correspondence is prepared at call admission and held as addresses, without runtime name lookup.

A Structure's field count and positions are fixed at construction. Graph fields follow strictly lexical order; native-code emission order does not authorize rearranging the graph's fields. Updating an existing field replaces its stored reference; it does not append an occurrence. A different set of fields requires a new Structure. Array operations follow their own contracts and do not change this Structure rule.

Execution retains the physical reference to the active Structure (§12). This is hidden ABI context, not a new source name `self`, a second data graph or a replacement for reserved `node`.

<a id="descriptions"></a>
## 5. Explicit value descriptions and conversions

A value description is an ordinary explicitly accessible Structure. A receiving expression obtains it through an argument or reference. It is not secretly attached to every primitive and is unnecessary for determining a physical type from an address. Names such as `class` and `class.range` denote a particular profile's data, not mandatory global language entities.

The conversion table defines relations between primitive values and their descriptions, not between every pair of Structures or their names. Distinct Structures `A` and `B` share the physical `Lmx` representation in the arena's typed arrays ([L2 §3](L2_spec_en.md#type-by-range)); a name or field composition creates neither a separate physical type nor a one-element array. Whether `B` satisfies requirement `A` is determined by `implements` relative to the Consumer, not by a `B → A` conversion row. Obtaining or transferring a Structure reference likewise requires no converter for each model. Shared physical representation does not remove structural admission, qualifications, or the distinction between a Structure reference and a reference to a reference cell.

A description separates its semantic contract from architecture binding. The contract defines meaning: count, integer, rational, profile-precision number, complex value, atom, address, opaque resource or absence of content. The binding defines width, signedness, range and target spelling. Equal representation does not imply equal contracts: `Boolean` and `int8` may share storage while admitting different values.

Ordinary description fields include `cell`, `semantic`, flags such as `numeric`/`integer`/`floating`/`reference`/`opaque`, `width`, `signed`, `range`, `spelling` and `convert` keys. The profile chooses field names. A range declaration is contract data; satisfaction is established through the [single admission mechanism](#admission), not by the field's presence alone.

The numeric contract chain is flag → nonnegative integer → integer → rational → profile-precision number → complex number. Nonnegative integers include zero. Machine `double` is not the set of all real numbers. Atoms, addresses and opaque resources are separate contracts, not rungs of this numeric chain. `unit` is an empty Structure; `void` denotes no cell content.

Descriptions are composed with ordinary `merge` under the common [occurrence-order rule](#fields). Fields such as `width`, `range` or `spelling` do not automatically create arithmetic methods. Such operations are callable expressions. For example, `u32` combines a nonnegative integer contract, 32-bit representation and range 0…4294967295; `FILE` describes opaque resource identity. A `FILE` word alone does not establish that reading or closing is valid: such requirements are expressed through paths of a `File` Structure.

A converter is an explicitly selected receiving expression. Its key comes from explicit descriptions and their composition; there is no hidden search over pairs. Analytical checking does not run the converter; an action requiring conversion performs the selected call. A repeated key form in one Structure assigns to its existing field after contract checking without creating a second field; composition likewise writes a later operand's same-name key into the model's slot. If a table has several rows with one key, the table operation's own policy selects the row ([tables](#registries)).

Numeric conversion preserves the destination-range contract: `u16(255) → u8` is admitted when the converter exists, while `u16(256) → u8` produces a range error, not zero. Rounding `1.5 → i32` and in-range precision loss require explicit numeric-profile rules. Proven range inclusion may eliminate a redundant machine operation while preserving the semantic requirement. Format, range and converter-behavior failures are not replaced by a positive `implements` result.

<a id="conversion-context"></a>
## 6. Message-local type bindings and conversion context

Each executing Message has one context of type descriptions, symbolic bindings, and conversions. It consists of ordinary Structures and references explicitly supplied when the Message is built or reachable from them. Message creation, sending, and parenthood do not implicitly pass the parent's context. There is no built-in process-global registry, implicit type environment, or hidden converter search.

### Stable bindings and structural genericity

A symbolic type name is bound once for a Message and resolves consistently at every use, including arguments and results; each call does not instantiate it anew. Another Message may bind the same name differently. This is a relation within the context, not another runtime name space.

Structural genericity is the ordinary case of [admission](#admission): a Consumer requires only the paths, operations, and contracts it uses. It needs no separate generic template. A symbolic binding is needed when multiple positions must share one stable type relation, not merely to declare genericity.

### Conversion at consumption

The reachable conversion table concerns primitive descriptions, including explicitly supplied semantic quantities and units; it is not a Structure-compatibility catalog. Another primitive description is admissible only through a conversion available in this Message and allowed by the Consumer's contract. Analytical admission does not execute a converter. At actual consumption it executes as an ordinary callable with checks for range, representation, precision, and semantic conditions. Structural success does not permit unchecked reinterpretation of primitive storage.

Before a call, each converted actual argument must satisfy the selected callable's actual descriptor; afterward its result is converted separately to the Consumer's requirement. A converter absent from the reachable context is not replaced by a hidden chain or process-wide search. An implementation may cache resolved bindings and routes only while preserving the result of explicit resolution.

Expanded [Message-context examples](LMX_semantics_guide.en.md#message-conversion-context) are kept outside the normative text.

<a id="admission"></a>
## 7. Analytical checking and candidate validation

Candidate admission has two stages: directional analytical `implements` and execution of the receiving expression's explicitly specified checks against the constructed graph. Address classification identifies a value's physical representation but does not replace admission.

<a id="analytical-tree"></a>
### Analytical stage

<a id="three-argument-implements"></a>
#### `implements(aVar, bVar, Consumer)`

`aVar` is the candidate, `bVar` describes the required role, and `Consumer` is the concrete receiving expression. With Consumer, analysis covers its known accesses to `bVar` in every visible branch; unused fields of `bVar` are not compared. Without Consumer, full structural suitability against `bVar` is checked, not an empty access set. An unknown computed path is not reported as checked.

A used path requires a corresponding candidate field and admissibility of its actual consumption. If Consumer explicitly invokes a field, only the written calls are checked: actual and named arguments, defaults and available conversions must fit the selected interface and the implementation's actual descriptor; results and declared exits must meet Consumer's requirement. Opaque transport of a callable does not check future calls. Merely transporting a primitive leaf proves nothing about its value; explicit tests check substantive properties.

Analysis executes none of the candidate, Consumer, method or converter, and does not expand every callee body. It establishes suitability for this Consumer, not equality of Structures or suitability for every future consumer. A positive result maps each used model field to a physical candidate field, possibly at another position. This is a **general** map for any admitted pair of Structures, not a table specific to methods, `var`, or `call`. Reads, writes, address-taking, and `dirty`-field publication through the admitted correspondence use these physical places; runtime performs no name lookup ([L2 §14](L2_spec_en.md#implements), [L1 §15](L1_spec_en.md#implements)).

<a id="correspondence-stability"></a>
#### Preservation of established correspondence

An established correspondence persists as values change. Branch replacement admits the new candidate to the same receiving place before storing it; refusal preserves the old value. Mutation neither reruns all tests nor invalidates the established map. Another Consumer or new requirements undergo their own admission.

<a id="argument-compatibility-stage"></a>
Known-call argument compatibility is checked during translation; dynamically selected callables are admitted to that call when selected. A compiled call under unchanged requirements does not recheck types on every execution. Running a converter and its concrete-value checks is separate from repeating signature compatibility checking. Signature checking does not establish the required fields in the actually selected `data` for `call: code data`: an absent place is a call-admission/execution error, not an error translating the source `call`.

<a id="graph-tests"></a>
### Test execution

After successful analysis the interpreter executes **all** required tests of the receiving expression against the already constructed graph. An empty test set is not successful behavioral validation. Without explicit Consumer, checks specified in the receiving description `bVar` are used, not tests owned by candidate `aVar`. A failed test rejects admission; declared failures use ordinary `throw`/`catch`. Checks are an admission stage, not a watcher on every graph write.

<a id="test-receiver-contract"></a>
#### The `test:` receiver

Inside any Structure, `test: op checkIncrement` associates receiving place `op` with ordinary checking expression `checkIncrement`. Both names resolve as receiver arguments, not implicit calls. The name `test` is reserved; an ordinary user method may be called `mytest`. The association belongs to Consumer, not the candidate; multiple `test:` forms require multiple checks. A nested Consumer's checks are not automatically promoted to its outer Consumer.

The actual candidate is supplied to the checker as an ordinary argument. The checker's own accesses undergo analytical checking before execution; no `@` is added merely to transport a Structure, which already travels by reference. A checker returns an ordinary `int`: 1 for success, 0 for failure. An expected failure uses ordinary `catch`; an arbitrary `throw` is not success.

Running a check completes admission already in progress rather than starting that same admission over again. A cycle of unfinished checks is not success. The written association and checking body reside in the same graph for `toLmx`, copying and execution until changed by an explicit write; there is no separate test catalogue, auxiliary graph, runtime name table or hidden typing-disabled mode. Test calls use ordinary native/walker dispatch and do not force every call to be walked.

<a id="admission-recipes"></a>
## 8. Obtaining a required guarantee: fourteen practical cases

These cases apply [unified admission](#admission); they are not fourteen separate type systems.

<a id="admission-case-1"></a>
### 1. One receiving expression for multiple data shapes

Consumer requires the paths it uses, not a nominal type for the entire Structure.

<a id="admission-case-2"></a>
### 2. Knowing what a particular site checks

The analytical stage checks Consumer's known accesses; its explicit tests check the stated behavior. Unknown coverage is not proof.

<a id="admission-case-3"></a>
### 3. Distinguishing meanings with the same representation

Express a semantic distinction through a used path and, where leaf values matter, a test; a type name alone proves no equality of values.

<a id="admission-case-4"></a>
### 4. Constraining a scalar leaf

A `width` field does not establish `width = 32`; Consumer's test states the check of the concrete number.

<a id="admission-case-5"></a>
### 5. Making a change visible to other reference holders

An explicit path write changes the shared referent; assignment to an argument changes an activation-local value. Own-field publication follows §12.

<a id="admission-case-6"></a>
### 6. Independence from another holder's mutation

Ordinary Structure or Array passing transports a reference. Explicit copying creates an independent mutable copy; immutability prohibits mutation of the protected value.

<a id="admission-case-7"></a>
### 7. Establishing that a call can proceed

Besides a suitable callable interface, the call needs all mandatory formals and dynamic inputs.

<a id="admission-case-8"></a>
### 8. Checking a transported callable

Transporting a callable neither executes it nor proves suitability for every future call; each concrete call has its own admission.

<a id="admission-case-9"></a>
### 9. Changing a method body without breaking calls

A new free dynamic input changes the method interface and requires affected calls to be checked; an unchanged signature alone does not guarantee unchanged behavior.

<a id="admission-case-10"></a>
### 10. Selecting the intended part of a composition

`merge` builds a new tree: a compatible same-name field of a later operand replaces the model slot's value, and a new field is appended.

<a id="admission-case-11"></a>
### 11. Changing an existing Structure

A created Structure has fixed field count and slot addresses; a different field count requires another Structure.

<a id="admission-case-12"></a>
### 12. Reliable numeric conversion

A converter respects the destination range: `u16(256) → u8` is no silent wraparound. Refusal follows ordinary failure handling.

<a id="admission-case-13"></a>
### 13. What a broad converter table provides

Additional converters extend available explicit leaf conversions but do not change required paths or callable interfaces.

<a id="admission-case-14"></a>
### 14. Foreign-resource validity

A thin handle does not prove resource validity or authority; its wrapper contract and Consumer checks state those properties.

<a id="construction"></a>
## 9. Value construction

Source notation constructs the complete Structure graph: values, declarations and executable expressions remain in the same graph. Constructing a body description does not execute that body. A named Structure is not executed on declaration; an anonymous body in execution position runs under its receiving expression's contract. No separate data graph, hidden wrapper procedure or persistent auxiliary context is created. The declaration site determines the lexical parent; an independent root has none (parent = 0). The binary representation retains comment text; names remain available through the table described under [name rules](#fields). Comments and the name table do not replace resolved references or participate in dispatch.

### Head resolution and the role of the tail

A receiver is an instruction to the translator; a callable call is a runtime action. They share the Frame syntax "the head consumes the tail", not a semantic role. General resolution and the receiving head's contract determine the head's role and the meaning of its arguments. A name in a receiver's arguments does not thereby become another call: `catch: merge ()` supplies catch with the failure name and parameter description, just as `fn: mytest ()` supplies fn with the name and signature description. These are consequences of the common rule, not exceptions for those receivers or names.

<a id="resolved-head-consumption"></a>
#### One model, one resolution, one consumption

First, the complete written structural head/arguments model is formed in translator memory, without knowing what the head denotes. Neither its name, signature, nor entity category determines that model's boundaries or permits collecting additional arguments. Only after the model has been formed does the common resolution algorithm in the single namespace determine the head's role: receiver, callable, assignment value, or Structure definition. One common consumption mechanism applies the resolved entity's contract; differing contracts do not create separate parsers, namespaces, or resolution routes.

### Composition of place and value

In the composed one-argument form, the outer head selects the receiving place; a nested receiver builds or checks the value supplied to it. `i: int: 5`, `ptr: Model`, and `ptr: @: Model: 0` use one Frame composition: the type receiver `int` or `Model` checks the value, and `@` establishes reference depth; in this form the nested receiver does not itself declare a separately named field. A bare atom does not invoke a receiver. The expression is formed and evaluated the same way whether its result is consumed or not; for an already resolved head, assignment is an effect of an unconsumed result, not a special parse of the right operand. Thus `Model: 0` need not change `Model` when another expression consumes its result.

`new_var: int()` explicitly creates a cell requiring `int` without an invented initial value; `new_var: int: 5` creates it with value `5`. In a signature the same form describes a formal, and a written value supplies a default when an actual argument is absent; describing a formal does not execute it as a body. This is one mechanism for primitives, references, Structures, and callables, with no branch for a receiver's name. Places and visibility are fixed before body execution; whichever branch happens to execute first cannot add a slot to an already constructed `Lmx`.

Some built-in value/type receivers, including `int` and `@`, also have a two-field contract `R: name value`: the first field is an atom naming the receiving place, and the second is a value or requirement expression. The resolved receiver's contract determines arity and field roles after P0; the parser neither singles out this class nor changes the tree, and other receivers retain their own argument contracts. The name atom is neither called nor evaluated as a value: the place is resolved in the same namespace as an outer place head in the composed form. The candidate is evaluated once before any write, undergoes ordinary admission, and then the place is first defined or assigned under the common rule. Consumption of the entire form by another expression does not itself publish a field or perform a write. For an unknown or noncallable name, `int: i 5` and `i: int: 5`, as well as `@: ptr 0` and `ptr: @: 0`, yield the same binding. This is not a mechanical permutation of every operand: `@: new_field Model` binds the reference to `Model`, as `new_field: Model` does, without adding the address depth of the `@Model` cell.

In `@: ptr Model: Other`, `@` has exactly two fields: the place atom `ptr` and the nested Frame `Model: Other`. Consumed `Model: Other` yields candidate `Other` under requirement `Model`; it neither writes to `Model` nor creates an addressable temporary cell. After admission, the two-field form builds a reference value and binds `ptr` by the common rule. If `ptr` is unknown or noncallable, the result agrees with `ptr: @: Model: Other` provided the same place is resolved and the candidate is evaluated once before the write. If `ptr` is callable, the outer-place form calls it with an argument, while the two-field form designates `ptr` as a binding place subject to its write constraints; the forms are not unconditional synonyms.

In evaluation position, a bare identifier enters the same resolution flow but does not itself form a call or supply an empty argument list. It denotes the resolved value, a reference to a Structure or callable, or a receiver name according to the receiving position's contract; bare `merge` and `int` likewise do not execute. If that position requires a value the named entity does not provide, this is an error, not a hidden nullary call or free input. Applying a resolved head requires an explicit Frame with `()` or `:` and a structural tail, possibly empty; that head's contract still determines the Frame's role. An ordinary named Structure is invoked through receiver `call: A`, not by using its name as the head. Neighboring atoms are not captured. In `if: p`, bare `p` is only read: even if it points to a method, that method is not called. This rule does not decide whether the value of `p` is admissible as a condition.


In `ptr: Model`, `ptr` selects the place and the known Structure `Model` supplies its requirement and reference; when a null address is needed, `ptr: @: Model: 0` builds the corresponding reference value. Admitting another candidate to `Model` uses ordinary `implements`, with no second rule for the name `Model`. In the transitional form, a known ordinary Structure `Model` and a new name `ptr` admit `Model: ptr`: it creates one reference field to that same occurrence, as `@: ptr Model` does. If both names already exist in the same Structure, `Model: ptr` assigns the value of `ptr` to the existing `Model` place after ordinary admission; it neither creates a second field nor writes to `ptr`. An unknown head `Model` with a lone atom in its tail does not declare a reference. Calls of `fn`/`fm`/`sub` are checked against their signatures, and an ordinary Structure executes only through `call`. Receiver nesting does not turn an application chain into one argument list.

A structural tail such as `A: (x: int: 1)` supplies the value for a new place `A`. Empty `A()` and `A: ()` supply one empty structural value, while bare `A` reads a reference to an already selected ordinary Structure. If `A` is already declared at this level, the unconsumed result of a repeated structural form, including an empty one, is assigned to its existing place after admission: neither a second field nor a call of the former `A` results. Merely nesting a Structure description inside executable code does not shadow an outer `A`: a distinct scope arises on an explicit `call` or method invocation. Inline `if`/`for` operators remain in the same activation. An ordinary field is visible forward and down from its declaration, unlike `fn`/`fm`/`sub` and `catch`; the same rule applies in the file's root Structure. A slot allocated in advance does not make the name visible to an earlier statement. A path `Outer\Model()` or `Outer\Model: ()` addresses that field and supplies an empty Structure under the same general unconsumed-result rule; bare `Outer\Model` reads its reference without calling. To execute the selected ordinary Structure, use `call: Outer\Model`.

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

The one-argument `@:` receiver builds or checks a reference value for an outer receiving place; its two-field contract takes the place name as its first field. Both a new place and a write to an existing one use the same resolver and ordinary [admission](#admission). In a signature the same receiver describes an input requirement. A candidate name resolves to an address at translation, never by runtime name lookup. A known method pointer `b` is invoked as `b: args`, `b(args)` or `(\b)(args)`; `\b(args)` dereferences the call result under ordinary precedence. Unary `@b` separately addresses the reference cell.

Candidate conversion precedes implements against the Consumer's requirement; reference storage changes after admission succeeds. An ordinary Structure value already travels by reference. @A addresses its cell and is not conversion of a Structure to its ordinary reference: A and @A have different depths. Assigning a Structure name to a reference place reads the already held reference and uses the destination cell's address to store its new value; conceptual `Lmx *` values and `Lmx **` cell addresses do not become the same expression type merely because C lowering uses both. If the assignment itself requires conversion of a primitive pointer value, its direction, depth and admissibility are supplied by the ordinary Message-local primitive conversion context, not a special table of user-Structure pairs; an absent rule does not silently remove an `@` level. implements establishes the referent's suitability for a structural requirement; the physical Lmx range is common, not separate for each model.

### A signature is not executed

A signature describes inputs rather than executing its forms as a method body. For nonprimitive `A`, a formal requiring `A` admits a candidate through `implements(c, A, Consumer)` and transports its descriptor reference without copying or implicit `merge`. Value and reference requirements use the same composition as in a body, but describing a formal does not assign a place while the method is built. A value written in the signature is a default, not a result of executing the body.

For structural `c`, `mytest(c)` and `mytest(@c)` have different depths: a Structure reference and a reference to the cell holding it. No extra level is removed to fit a formal. This applies equally to a Structure, a reference variable and a nonprimitive formal; the target is its own language storage, not a transport-ABI box. A primitive value and a reference to its cell are not synonyms either. Passing and returning nonprimitives never use C by-value aggregates.

### Assignment and declaration sites

At one structural level, another use of a known place assigns to it instead of adding a second field. In executable code, source nesting depth, including within `if`/`for` and a structural `name: ... end: name` form, creates no shadowing; a distinct binding scope arises on an explicit `call` or method invocation. For example, `i: int: 5; i: int: 6` leaves one `i` cell. Assignment occurs after admission; refusal preserves the old value and `dirty` state. Both written forms are represented in the one graph at construction; later publication or an explicit write may replace the first slot's contents, including within executable `var`.


An explicit or hidden argument remains an activation-local value: assigning it does not write back to the caller. A method's own field has physical storage in `var` and is published under [§12](#dynamic); its operator in `body` is not another field. A signature describes a formal and does not execute as this operation.

<a id="qualification"></a>
## 10. const, immutable and independent

`const` protects a binding: it cannot be assigned, rebound or replaced. The value behind a protected reference may remain mutable. `immutable` protects the value itself for its entire life through every alias; a variable holding its reference may remain rebindable. `const: immutable` combines both guarantees. They are independent qualifications, not degrees of one scale.

Immutability applies to a primitive, a Structure and its selected tree, or an Array with its descriptor and elements. It covers every field and explicitly included descriptions, not just Consumer's paths. Passing, returning and storing an immutable value preserve its identity; qualification requires no copy, including for a primitive. It does not freeze a foreign resource denoted by an immutable identifier.

`immutable` gives a new value its supertype during construction, before publication: cells are allocated from pools of the corresponding immutable types. An ordinary Structure already built in the mutable-Structure pool is not retroactively converted; `immutable: Existing` on that value refuses at consumption. This supersedes the earlier promise that `RuntimeImmutable` would requalify an existing tree without changing its identity. An already immutable value can pass as a value of its type without requalification. Argument admission remains [unified](#admission), as for every receiving expression.

The whole selected tree is examined before the new immutable value is published. A contained Structure is a tree branch only when its ordinary structural `parent` field points to the parent being examined. An outside reference **already stored as a data value** is permitted only to an already immutable object; it is terminal, and its target is neither traversed nor requalified. The root's own `parent` is a structural lexical link to a node outside the selected tree, not such a stored reference: `immutable` without `independent` constructs the value under its ordinary parent, which it neither freezes nor requires to be immutable; `independent` is the one receiver that touches that link. An operand of stored executable code is not such a value before that code runs (see below). The pre-publication state is checked: processing an earlier field cannot justify an invalid outside data reference in a later field. If a source `immutable` declaration violates this condition, the translator refuses construction; even under interpretation the graph is built first, so this refusal is not an exception thrown by the executable body. If an executed operation on an already existing tree encounters an error, the interpreter uses the ordinary `throw` caught by the ordinary `catch`, with no special `immutable` channel. Neither case becomes an `assert`.

The check concerns values and references already stored in that tree. In a declaration being constructed now **outside executable `var`**, a known admitted Structure used as a reference candidate is stored in the cell at construction, even if the enclosing named Structure or method body is never called. An initializer inside `var` remains stored code until `var` executes at method entry; its future result is not a reference already stored in the cell. An executable expression is not run during qualification; a deferred read or call is not rejected merely because it could return a mutable object: its result is checked when actually received, assigned or otherwise consumed under the ordinary contract. Stored code is separately checked for a forbidden write into the protected graph under the rule below. An immutable Structure may therefore contain code that later reads mutable data without freezing those data. The representation may place code and data in the same graph; that does not turn an operation's address operand into the result of the operation.

Primitives and methods are leaves, not lexical-tree branches. This describes the `parent` topology, not an exemption for mutable storage physically retained by the qualified graph: a saved method's code record and already stored data must satisfy the immutable construction contract. Its deferred operands are code, not their possible future values, and cells of a later activation are not frozen by this check. An Array reference likewise establishes no `parent` branch: a tree operation does not implicitly freeze an outside Array's mutable backing. An immutable Array is constructed under its own contract. A cell's membership in a service pool does not permit traversal or qualification of the entire pool.

Construction of an immutable value completes only after successful full preflight. Failure leaves no partially published immutable tree or successful result; silently skipping a branch, copying an already existing ordinary object merely to change its type, or retargeting links is prohibited. An already immutable value needs no requalification. This rule does not roll back earlier initializers, argument evaluation or pre-call publication of working fields; it establishes no graph transaction.

Protection applies to writes through every path and to publication of working fields. When the `immutable` receiver consumes a Structure, it must establish that the saved body cannot write into the protected cells; a known-invalid write or inability to prove safety refuses **that consumption**, before call code is generated or executed, rather than at a later working-field publication. For example, a saved method `x: int: 0; x: x + 1; return: x` writes a field of the graph being protected; consuming its containing Structure with `immutable` is refused. A write into a known immutable cell cannot be compiled. Dynamic write checks remain for external code addressing an already protected value; they do not replace proof when the saved body is consumed. Calling a method alone does not remove protection. Changing a local argument copy or rebinding a local reference does not modify the protected value. Constructing a new value, including through `merge`, does not thaw the source.

Construction-time `independent` sets the root's `parent = 0`; that is exactly the absence of an external lexical parent. Internal tree `parent` links and own fields remain. The qualification neither retroactively clears existing objects' `parent` links nor prohibits explicitly supplied references, current-caller dynamic arguments, Messages or selection of a callable by a compatible signature. It does not require purity or an interface closed over explicit arguments alone.

`const`, `immutable` and `independent` are receiving expressions; their composition establishes the result's qualified type. `immutable` is a supertype determined when the value is built. Each base type has storage for its corresponding immutable type; all immutable Structures, regardless of their field models, use a shared pool of that type, distinct from the ordinary Structure pool. Qualifying one Structure does not affect unrelated values; every alias of a constructed immutable value sees the same supertype by address. The common address-classification mechanism is described in [L2](L2_spec_en.md#type-by-range); this does not introduce a new type for every Structure model or a runtime name table. A zero root `parent` remains the structural consequence of `independent`, not a replacement for type classification. As receiving expressions they stand wherever a Structure value is received -- a declaration's tail, a method's `return:`, a `merge` operand -- composed in the order and part the source writes, each with its own contract; the root-level chain over a named Structure is one case of that reading, not its definition.

For example, a method inside independent Structure S can use S's field through its internal lexical link. Required `x` can come from the current caller. If `x` exists only in S's former textual surroundings, implicit external access is unavailable. An explicitly passed large Array neither shrinks nor gets copied because of `independent`. The special lifetime of the three qualifications together is described under [eternal branches](#eternal).

<a id="execution"></a>
<a id="callables"></a>
## 11. Callable expressions and their interfaces

<a id="declaration-visibility"></a>
Names of methods created by `fn`, `fm`, and `sub` are visible in both directions within their lexical block. An ordinary named Structure and a reference to a method are visible only forward and down from their declaration site. Within one activation, nested forms do not shadow an outer name: an executable declaring form assigns to the corresponding place in the selected `data`; another own place may hide an outer one only on an explicit `call` or method invocation. This does not alter the separate receiver contracts of `fn`/`fm`/`sub` declarations or their signatures ([§4](#fields)). An ordinary Structure's explicit `var` is part of its `call` contract: its fields are prepared for the entire body regardless of where `var` occurs among the fields, but this does not make other later declarations visible backward. [Head resolution](#resolved-head-consumption) uses visibility at the current position. Parentheses, tail shape, and a trailer do not change it.

A `call` or method invocation establishes the called occurrence's binding scope, where its own name may shadow an outer one. Within that same activation, `if`, `for`, and other nested executable operators create no additional scope: writes in them use the selected `data`'s prepared same-named place and then check its admission. An ambiguous bare path with two or more source occurrences requires an index rather than selection of the first. Source position still determines when a name becomes available; physical preparation of `data` does not expose it earlier.

The files of a program form no categories of a main file and parts: a message is a Structure, and any file attached by any means is embedded into the program graph. Visibility of declarations across files follows the resulting graph and these same visibility rules -- forward and down from the declaration site, in both directions within their block for the callables `fn`, `fm`, `sub`; comparing positions in different documents does not define visibility.

A signature describes inputs and the result; it is not an executable body. A formal's spelling does not execute the call, declaration, or assignment that the same spelling might denote in a body. Synonymy between two descriptions in a signature concerns the parameter contract and does not extend to executable occurrences of those spellings. Supplying an actual argument performs the contract's conversions and admission, but does not execute the formal description as a body operator. Uses of the resulting parameter in the body are resolved by its contract and the general expression rules, not by executing the signature text.

<a id="method-parts"></a>
### Parts of a callable Structure

General occurrence selection also applies to shorthand `call: code`: with multiple source root-level `var:` heads in the actual `code`, it may not silently choose the first. Until the required occurrence is selected explicitly, the shorthand refuses; full `call: code data` needs no such selection. This is not a second name lookup for `call`.

A called `fn`, `fm`, `sub`, or `catch` is one complete Structure with addressable `args`, a `return` description where applicable, `var`, and `body` parts. `var` is a separate receiver argument before the body and after the result description for `fn`/`fm`. Explicit `var` fields and own fields found in `body` determine the field set before the occurrence is allocated; fields absent from the explicit part are added to `var`. Determining fields in advance executes neither `var` nor `body`, moves neither part's operators, and creates no second graph. At method entry, the stored contents of `var` execute through the same general code/data mechanism as any Structure. A `var` initializer may be evaluated; publication writes its result into the first-declaration slot, replacing the initializer representation stored there. The next entry sees the current contents of `var`, rather than re-running an expression that has disappeared. Initialization written in `body` stays there and executes when that statement is reached. An explicit `var` field is visible from the start of the body; a field added from `body` retains its source declaration point and is visible forward and down from there. Allocating its slot in advance does not make the name visible backward or promise zero for a value without an initializer. The parts are fields of one Structure, including the path `func\var`; the size of an already built `Lmx` does not change. Automatic completion belongs only to a method's specific body and its `var`. An ordinary Structure may also contain an explicitly written `var` field, but its `var` is not completed from the body.

An ordinary Structure executes through the explicit `call` receiver. The general `call: code data` form receives two Structures: `code` supplies the executable body and `data` the explicitly supplied data; implement and test this form first. An ordinary Structure may explicitly declare a child `var` with data fields anywhere among its fields. In its data role for this call, `var` is an explicit child Structure of the source graph, not a hidden Structure; the name `var` creates no special kind of Structure and does not freeze the rest of the graph. Its fields are known to the entire corresponding body at preparation regardless of `var`'s position. Uses in the body of fields declared in `code\var` are requirements on the selected `data`, not free inputs: given `named\var\i`, `call: named named\var` binds a use of `i` in `named` to field `i` of the supplied `data`. Unary `call: code` selects the actual `code`'s `var` as `data` wherever that `var` occurs. With no `var`, it does **not** substitute `code` itself or create a hidden Structure: an attempt to write local data fields refuses; writing a free input only in the activation's working frame is not covered by that refusal. Explicit `call: code code` supplies `code` itself as `data` without selecting `var` and uses general admission, writes, and `native`-validity checks; this tests Structure universality rather than implementing the shorthand form. `var` does not make the rest of the graph immutable: the general write mechanism detects a change to the executable body and invalidates an incompatible `native` through any write path, including publication inside `var` or a `code=data` alias, without a hidden copy or special execution path. None of these forms creates a second graph. `code` may be a reference to any suitable Structure, so `call` never automatically completes `data` fields, either while preparing the call or during execution. At admission of the actually selected call, the required `data` places must exist and be compatible; a missing place is a call-admission/execution error, not a source-translation error. A free external name not declared as a data field does not become a `data`-field requirement merely because the names match: its value is resolved during execution and is not written into `data` automatically. An external field changes only through explicit addressing, such as a valid `node\k` path. Formals, dynamic inputs, and `node` do not become `data` fields merely because their names match. Code→data address correspondence is prepared at admission of the selected call before its body executes, without a runtime name table.

An ordinary named-Structure form in executable `code`, including `name: ... end: name`, writes the selected `data`; it neither declares a field in `code` nor creates a field based on nesting depth. In particular, `y: int: 2` written inside an `if`/`for` stores into the prepared same-named `data` place when executed; the inline operator has no separate local `y` data field. The `data` field map uses its root-level heads: a nested `T\y` does not replace a root-level `y`. With two or more source occurrences of a root-level head, bare `data\y` does not select the first and requires an indexed `data\[N]y`; this does not create multiple same-named data fields. A method prepares the required places in its `var` in advance without executing that operator; arbitrarily supplied `data` must already have the place. Admission of the actually selected call checks all required places before starting the body, including writes in conditional branches; a missing or ambiguous place is a call-execution error, not a source-translation error. This does not alter the separate receiver contracts of `fn`/`fm`/`sub` declarations or their signatures. The same rule applies to Structures: if `S` executes a `T:` form with a new body followed by `call: T`, while `D` initially holds another body in its sole `T` place, then `call: S D` first stores the constructed value in that `T` place of `D`; `call: T` reads the updated place and executes the new body from `S`. Source nesting depth does not select another `data` slot or introduce shadowing.

In ordinary `call: code var`, the explicitly supplied `var` is a data Structure like any other `data`; its name creates no special publication path. The separate roles tell the compiler and interpreter the expected case: the used executable part of `code` remains unchanged while `data` may change. This does not qualify the whole Structure as `immutable`: stability of the executable part requires checking write paths and aliases, and the `var` part inside `code` may itself change. With `call: code code`, the roles alias, so their independence cannot be assumed. That limiting case remains a test of general code-mutation and `native`-validity machinery, including future compilation of changed code on the fly; it has no separate call path. At a checkpoint, already computed working values of only `dirty` fields are stored directly into the corresponding physical `var` slots, following the general `implements` map when needed. The checkpoint does not re-evaluate source expressions, rerun admission, or copy the entire Structure. Executing stored `var` contents at method entry and publishing values already obtained are distinct operations.

Coincidence of `code` and `data` does not itself clear `native`; entering `call` is not a write either. A change to an activation's working value before `dirty` publication has not yet changed the graph. Once admission has determined the place and new value, the general write operation checks every `native` whose proved dependencies the change would affect, including that of an enclosing Structure when its used nested part changes. For a direct path or reference this occurs at the write; for a working `dirty` value, at its publication checkpoint. The physical slot write and removal of incompatible entries form one observable operation: another or recursive dispatch must not see the changed graph with an old incompatible `native`. A compatible implementation survives an ordinary data update; a refusal before the write changes neither the graph nor `native`. The entry already selected by the current invocation is not selected again after effects. If the changed executable body contains L2 operations, an empty `native` does not authorize handing it to the L3 walker: a matching native implementation or explicit refusal of the operation is required before publishing an incompatible change. This is one write rule for separate or coincident `code`/`data`, not a special `call: code code` path.

An executable body is a structural expression; declaring a named Structure or method does not execute it. The bare name of an ordinary Structure denotes a reference to it; explicit receiver `call: A` executes it without arguments or result, whereas `A()` / `A: ()` remain structural declaration or assignment forms. `fn` declares one result, `sub` returns no value, and `fm` returns one Structure with several named fields. A signature specifies arguments, result, and `throws` but does not itself execute.

Bare `return` exits without a value; `return: value` is admitted only where a result is declared. At the opening level, `return` may also be a trailer for any callable Structure under the general grammar rule; it is not a closer for a non-callable Structure. Explicit `end: Name` is optional, and reaching the end of a body without `return` does not synthesize a return node.

A path through a Structure reads a field without invoking it. A method's own field physically belongs to the `var` part of that same callable Structure; its `body` operator addresses that place without creating another cell. Composition of place and value is defined under [construction](#construction).

A callable occurrence has its own structural identity and a `parent` link into its above-method lexical space. Multiple occurrences can reference one immutable method. Graph copying neither creates another method implementation nor changes its signature; state belongs to particular structural occurrences and activations. A nested definition does not capture a caller frame in a hidden environment.

Entering a method neither copies its callable occurrence nor creates another graph. Native and interpreted execution use the callable's complete Structure; source order of `body` operators is preserved. Each activation has a machine frame for formal and hidden inputs, the result, and working values of `var` fields. Changed working values are published to the first-declaration slots in `var` under [§12](#dynamic); publication may replace an initializer stored in such a slot. If the write changes the executable graph, an incompatible `native` is invalidated under the general rule before the next dispatch. Recursion executes the same Structure with a separate frame. `merge` may supply a formal's default without binding it. A free name uses an eligible dynamic input first, then a lexical source; temporary frame values add no graph nodes.

The `args`, `return`, `var`, and `body` parts belong to one Structure; `var` is neither another value graph nor a hidden call environment. A program may also explicitly separate data and code through `call: code data`, without automatically completing `data` fields.

A named Structure has no explicit arguments, but values used by its body still need to be resolved. Its explicitly constructed fields remain in the Structure itself; `call` does not create further fields from mentions of external names. A field explicitly declared in its `var` binds to the corresponding field of the selected `data` regardless of `var`'s position. Another own declaration in the body does not retroactively bind an earlier use; without another eligible source of the name, the call is refused. For a genuinely free name, the value source is selected during execution by the ordinary rule: the caller's available context, then an eligible lexical source ([§12](#dynamic)). Thus `named_called_struct` can read an externally bound `k` and change its working value locally in the activation, but no `named_called_struct\k` field exists unless explicitly declared inside that Structure. Changing the local value does not rewrite the external source; an external field changes only through an explicitly written path. Named Structures have no separate free-name resolution mode.

The distinction also holds within one Structure: `a: int()` creates a typed place, while a later `a: get_a()` computes and stores a new value when reached. On method construction the place is determined in `var`; accounting for it in advance does not execute the `body` operator. Keeping these parts in one graph does not make them interchangeable.

Callable selection starts from an explicit reference, structural path or textual path with an explicitly supplied root. Selecting an implementation and providing its arguments are distinct actions. The selected candidate undergoes [admission](#admission); the call must then receive every signature input. A suitable method field does not by itself supply its dynamic inputs. Transporting a method as data is not invoking it.

Positional actual arguments precede named ones. After the first named argument, subsequent arguments must also be named. An unknown name, duplicate assignment to one argument, missing required argument or ordering violation is an error. A named argument's body is supplied as a structural value when that is the receiving expression's specified mode; it does not become an arbitrary sequence of immediate calls. In argument position a bare callable name denotes a reference to its occurrence, not its execution result. If the receiver requires a result, the actual argument must contain an explicit call of a value-returning callable (`f()` or `f: ()` for a nullary method), followed by ordinary conversion and admission; demanding a result does not itself invoke bare `f`. A callable without a result, including `sub`, can be passed by reference to an appropriate place but cannot supply a result value. Bare `return` means only exit and does not make a callable value-returning. A bodyless `fn` remains an interface descriptor and may be passed by reference, but direct execution gains no invented body.

A formal parameter with a provided default value remains part of the full accepted interface. When no argument is supplied explicitly, that value is used; when one is supplied explicitly, the supplied argument is used after the ordinary conversions and admission. Having a default neither removes the formal nor turns it into a free dynamic input: a same-named value in the caller's context does not become a supplied argument -- supplying it takes an ordinary call with the argument. These rules do not depend on whether the parameter's data came through `merge` ([§20](#composition)): the same meaning results from writing such an argument directly and from ordinary composition of its data. A value that does not fit the contract is not equated with an absent argument and is not replaced by the default silently; zero is a supplied value too. The source of the default and the argument value of the current activation are distinct: supplying `y: 25` for one call does not change later calls, and a value left in a working cell by a previous execution does not become a default by itself -- only an ordinary explicit operation on the state the default is taken from changes it. Neither an argument nor an admissible default -- the ordinary call refusal.

The syntactic boundaries of the function name, `args`, result description, `var`, and `body` are defined in the [grammar](LMX_grammar.en.md). An empty Frame Structure-body has zero fields; bare `f:` without an argument or explicit closure is invalid. Descriptions and signatures create no implicit call, currying, or closure.

In an executable body, a headless form is an ordinary expression, neither an error nor a special call form. This covers lone `2`, bare `f`, the sequence `2 + 2`, anonymous Structures `(f)` and `(2 + 2)`, and empty `()`. Their fields are resolved and evaluated in lexical order by the same expression mechanism; a result without a destination is discarded. An anonymous Structure containing several fields, including Frames and headless expressions, retains the execution order of all fields; bounded and corresponding vertical spellings do not select different operations. Bare `f` reads the resolved value or a reference to a Structure or method without calling it. Explicit `f()` or `f: ()` supplies an empty argument Structure to the resolved head: for a method this is a nullary call under its contract, for an ordinary Structure it is a structural declaration or assignment; executing that Structure is written `call: f`. The receiver's contract still applies in argument position (§10, above), but the mere presence of a name never starts a call. Literal `2` does not declare a type for `f: 2`. Empty `()` is a valid present empty Structure with no inner expressions. Neither parentheses nor discarding a result bypasses ordinary resolution, admission, or unknown-name diagnostics.

Named `fm` results are fields of an already existing result Structure. `return` completes their updates and forwards that Structure; the control transfer itself neither allocates nor copies it. Multiple values in the `return` tail populate signature-defined fields of the same Structure. Exact surface unpacking forms require a separate profile rule.

Function-name assignment shorthand, such as `square: x * x` inside `square`, is admitted only if the receiving `fn` defines a same-named local result slot. It does not replace the persistent callable reference. Without that contract the form is rejected. Structural closing with `end: f` adds no implicit value return; explicit `return: value` is the core form.

A returned reference preserves its exact target identity. Constructing a result, if necessary, belongs to evaluation of the returned expression, not the transfer operation. Returning from a nested function ends its activation, not automatically the entire actor. Publication and cleanup ordering is defined under [exits](#exits).

<a id="publication"></a>
<a id="dynamic"></a>
## 12. Dynamic inputs and working state

Value storage at a declaration in the complete Structure, a working value of the current activation, an explicit formal argument and a dynamic input must be distinguished. They have distinct mutation rules; a working copy does not create a second persistent graph. Ordinary passing copies a mutable primitive's value and a Structure or Array's reference; the special identity of an immutable value is retained under [qualification](#qualification).

For a free name, the called expression receives the current value from the caller's available context; if unavailable, permitted lexical lookup follows `node`. Own declarations and formal parameters have their respective resolved locations rather than being searched in a global registry. Required through-names are part of the signature: adding a free name changes the interface. A missing required input makes the call inadmissible; silently creating zero or a new field during execution is prohibited. An existing `data` field and a free input's value are distinct places; matching names do not copy the value. A callable's formal is not a free name of its body: it receives the supplied argument or its default value ([§11](#callables)), and the source priority below does not extend to an omitted formal.

A free name's sources have this priority: the caller's nearest current local binding, then its already inherited dynamic input, then the callee's lexical lookup. A local binding includes a used own field, formal argument, result or another receiver-defined local value. Statically known call requirements propagate to a fixed point, including through mutual recursion. A name needed only by the next call must still be retained and forwarded; forwarding alone creates no graph field. It follows that a method which itself consumes the name forms its activation's value of it from these same sources, its own lexical lookup included, and that formed value belongs to its available context: what it calls receives it, whichever source gave it. A method that only forwards the name forms nothing: an entry that arrived absent travels on absent, and the eventual consumer uses its own lexical lookup. Assigning the name changes that activation's value only, and an explicit `node\x` read forms no binding.

For a name consumed by this activation, including in an explicit throw's payload, the selected value is held at activation entry, before its body's statements or own-field entry load can change the source. A later explicit path mutation of the source does not refresh the bare input. This also applies when the selected source is the callee's lexical fallback; a name merely forwarded to another call is not eagerly read or given a local value. A nested callable's definition is not an executed step of the enclosing activation: its free inputs are formed at its own call, not when the enclosing body is entered.

Lexical lookup follows real Structure links to a zero parent and selects the sole field of the required name at the relevant level ([names](#fields)). `independent` cuts the external lexical fallback. Explicit `node\x`, `reference\x` and `array[index]` address the graph rather than being replaced by a dynamic `x`; a context copied by `merge` participates only as fallback ([composition](#composition)).

An own field's working value is loaded for the activation from the corresponding physical slot of the selected `data` (from `var` for a method with ordinary `var`). Assigning that name changes the working value and marks it `dirty`; a checkpoint stores the already computed value directly into that same `data` slot, following the general `implements` field map when needed. Publication neither re-evaluates the expression nor repeats admission. Loading and reading do not themselves mark it. Only fields actually used by bare names in the body are loaded on entry: an explicit path write changes the graph cell, while the bare name keeps reading its working value until its own write. An explicit reference write is observable through other references. A formal or hidden argument remains an activation value, not a `data` field, and writing it does not copy back to the caller.

For executable own writes, the selected `data` field map is built from its root-level source heads; nested heads belong to initializers and are not fields of that level. A bare path is possible with one occurrence of a name; two or more require `data\[N]field`, without automatic selection of the first. This does not create multiple same-named data fields. Nesting of the operator in `code` (`if`, `for`, and so on) does not change the selected place. Admission of the actually selected call prepares a physical map for reads, writes, `@`, and publication before its body starts; execution does not look up names. Mere Structure nesting creates no shadowing within an activation; a distinct scope requires an explicit invocation.

Assignment updates an already resolved place; it creates no field during execution. In `body`, computed initialization is written separately: `i: int()` establishes a place without an invented value, and `i: findValue()` assigns the result when that statement executes. Preliminary `var` assembly neither moves those operators nor executes a call from `body` during construction. A known value in a declaration outside executable `var` may fill a place when the occurrence is constructed, but this does not execute `body`. An initializer written in `var` is processed when `var` itself executes; publication into the first-declaration slot may replace its representation, so the original operator is not guaranteed to remain in that slot. An already constructed Structure gains no slots during execution.

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

The selected `data` holds the published field state, not a call journal; for an ordinary method this is its `var`. Activations of one `code` using the same `data` have separate working values over the same cells: a suspended outer activation is not reloaded and keeps its working values; after the inner return its clean own field is not published without a new real change. Different explicitly supplied `data` gives different cells through the same general `implements` map. The result is determined by the sequential order of publications of `dirty` fields only, not by restoring a snapshot.

On re-entry into the same occurrence S **with the same `data`**, both activations use the same declared cells but distinct working values. If the outer activation published `x = 2` before an inner call and the inner one later published `x = 9`, the resumed outer activation still reads its working 2; its clean cache does not overwrite the published 9. Only a new outer write marks its `x` dirty and publishes another value. `@x` in both activations addresses the same real declaration cell, whereas a dynamic argument remains activation-local.

Actual call arguments are evaluated into values before dirty-field publication at the call boundary. An argument read through an explicit graph path may therefore receive an earlier published value while one read through a bare name receives the new working value; later publication does not change arguments already evaluated.

One logical serial execution lane per Message makes this model safe without locks or memory barriers within a turn. Suspended activations take no part in a race; other Messages work in their own arenas. The interpreter implements the same semantics with a control stack of returns, arguments, locals and working values; the method's full state is not copied on a call or re-entry. An ordinary activation frame is created and only the used own fields are loaded into its working values; no additional prototype or graph instance is created.

A body supplied to a receiving expression as a Structure and an executable call's arguments likewise do not become one hidden environment.

Publication is required at call, return, `throw`, diagnostic termination and `yield` boundaries. An exit with `finally` has the two publications specified under [exits](#exits). `retry` and local loop transfers do not by themselves create a new activation or reload fields. Signatures and the graph retain this model's requirements whether the graph is interpreted or translated.

<a id="branches"></a>
## 13. Branches and loops

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

<a id="exits"></a>
## 14. Exits and finally

`finally` registers cleanup in the current scope without executing it at registration. Registered cleanups run in reverse order when that scope is exited. This applies to normal completion, `return`, `throw`, transfers out of a loop scope, `redo`, `retry`, diagnostic termination and other profile exits. It is neither a `try` construct nor an exception-only handler.

An exit that destroys an activation follows this order: evaluate and retain the result or exit payload once; publish dirty own working fields; perform applicable cleanups; publish own fields dirtied by cleanup; transfer the result or control and finish the activation. If no new changes occur, the second publication is empty, but it cannot be ruled out in advance.

Dynamic inputs are not copied back, clean cached fields are not published, and the caller activation is not reloaded. Every activation crossed by propagation performs its own required actions. Return preserves the result's reference identity and does not itself trigger actor end-of-turn collection.

An exit within an already running cleanup does not re-enter that cleanup. Remaining applicable outer cleanups retain their obligations. Calls within cleanup have ordinary publication boundaries. Removing an activation through stopping or cancellation does not permit these rules to be bypassed.

<a id="exceptions"></a>
## 15. Declared failures and diagnostics

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

<a id="suspension"></a>
## 16. Restart and suspension

`retryable` defines a restartable region. Unlabelled `retry` repeats the nearest active such region; `retry: label` repeats the named one. Abandoned-attempt cleanups run before restarting. The transfer does not roll back external effects, graph mutations, already published fields or Messages. Transactional rollback requires an explicitly represented data protocol.

`retry` itself is a local transfer in the current activation, not a new call or restoration of a hidden environment. Current working values continue to exist, with no additional publication merely because of the transfer. If repeated execution reaches a call or exit, that boundary's ordinary rules apply. A caught failure's payload remains the handler's explicit arguments.

`yield` transfers a produced value and suspends the activation. Dirty own fields are published before suspension. Explicit arguments, dynamic inputs, working values and their subsequent state are retained for resumption; they do not become body fields or a public hidden environment. Resumption does not reload them from the method Structure.

Producer inputs are fixed when its activation begins. A later `next` caller does not replace them with its own dynamic context. If `next` is a separate wrapper expression, its inputs belong to its activation unless an explicit operation changes the producer's saved state. The continuation and iterator-result representation is not observable when it preserves these semantics.

<a id="arrays"></a>
## 17. Arrays and backing

An ordinary Array is a typed graph Structure with stable reference identity. Constructor `[]` creates it when execution reaches the construction site. In `arr: []: ( ... )`, binding occurrence `arr` belongs to the current Structure, the Array's structural parent is that `arr` occurrence, and structural elements materialized from the arguments have the Array as their parent. Parenthesis normalization under the [general rule](#values) creates no extra anonymous wrapper. `MyLmxStructFromArray: arr` binds an ordinary reference to **that same Array**; it does not reconstruct or copy another Structure. A Structure field holding an Array reference is not the Array itself. Passing a reference does not copy elements; an element mutation is visible through other references, whereas rebinding a local reference is not.

An owning Array has one contiguous rectangular block of elements. Nested dimensions do not mean separately allocated rows. For shape `[d0, …, dN−1]`, element count is the product of dimensions, with the last index varying fastest. An Array of references to other Arrays is a different value, not a replacement for a rectangular multidimensional Array. A structural element is nested under the Array; a primitive element occupies its storage but acquires no separate `parent` field.

A graph Array has the common `Lmx` base with its own `parent` and `native`; its typed element backing is not a separate graph Array value. The L1 physical hierarchy must change accordingly: Array is built on `Lmx`, rather than `Lmx` being built on a standalone Array descriptor. The exact layout belongs to [L2](L2_spec_en.md#lmx), but the common structural parent and reference identity do not depend on the element type. A base Array has a fixed element count: it does not grow, resize, append, or switch backing. Dynamic membership, capacity and growth belong to a separate List (`KIND_LIST`); a cell address in its replaceable backing does not survive growth.

`length(array)` reads the Array's element count; for a rectangular Array this is the total count, not its first dimension. Physical backing need not retain dimensions and cannot reconstruct them from the total element count. The containing Structure's field count, Array length and service-pool size are distinct.

Built-in machine element types retain their [C99 target-profile meaning](L2_spec_en.md#lowlevel-scope), including plain `char` signedness; a descriptor does not redefine them. L3 adds checked access, not a different primitive representation.

A full N-dimensional rectangular Array index contains N integer coordinates. For a rectangular Array, coordinates are reduced to one linear element index in row-major order: `k = (...((i0 * d1 + i1) * d2 + i2)...)`. L3 checks only the final element against the descriptor's total length: `0 <= k < length(array)`. It does not check each coordinate against its dimension or store a vector of dimension lengths for those checks. For example, in a `[2,3]` rectangle, `[0,3]` has linear index 3 and selects the same element as `[1,0]`; linear index 6 raises implicit `throw: interpreter` rather than returning `None`. Computing the index must not wrap an out-of-range mathematical result into a valid element. An Array of references to Arrays is different: each step accesses another actual Array with its own descriptor.

Adjacent indices `matrix[i][j]` address one flat Array using strides known from its description, whereas `a[i]\[j]` addresses the previously selected value after `\` ([paths](#fields)). The descriptor does not recover dimensions, and an incomplete index spelling does not by itself construct a separate row Array or hidden view descriptor. These access checks belong only to L3, whether executed natively or interpreted: [L2 access](L2_spec_en.md#lowlevel-address), including obtaining a graph-backed element's address, works without them. Operation checks do not constitute a separate candidate-admission mechanism in place of [analysis and unit tests](#admission).

An Array copy has separate backing; passing a reference does not itself create it. Returning a reference must not hide copying to repair lifetime. Shared backing retains ordinary Message ownership boundaries.

<a id="array-operations"></a>
## 18. Array operations

Array arithmetic and comparisons are elementwise by default. Element operations follow their numeric domain and explicitly selected context. `*` means elementwise multiplication, not matrix multiplication. `matmul`, `dot`, `contract` and `outer` are separate explicit operations; a profile-specific matrix symbol must not make ordinary `*` ambiguous.

`reduce` collapses elements with an associative or explicitly ordered operation. The contract defines an identity where needed, element operation, result type and ordering. Reproducible real/decimal computations must not depend on an incidental backend choice of order.

`scan` is a prefix reduction: inclusive sum of `[1,2,3,4]` gives `[1,3,6,10]`. Inclusive or exclusive behavior is explicitly selected. `map` applies an expression to elements; a pure variant permits vectorization and parallel evaluation preserving the result. Effects need explicit ordering; the default profile expects pure mapping.

`filter` selects elements by a Boolean predicate and normally materializes a new Array. Copies, materialization and all results retain Message ownership boundaries.

<a id="mathematics"></a>
## 19. Numeric operations, purity and contexts

Numeric names and operators resolve to available constructors, explicit descriptions and callable operations. Families include machine integers/floats, `bigint`, `real`, `decimal`; these are not a mandatory closed language type list. GMP, MPFR and decNumber are possible implementations, not L3 source ontology. Conversions specify range, precision and rounding under the [description contract](#descriptions).

The default expression profile is pure: it admits only operations with declared pure contracts. `sqrt`, `sin`, `cos`, `pow`, `abs`, `gcd`, rounding and arithmetic may have such wrappers. Effectful operations remain valid high-level receivers but do not become pure by being written in an expression. L3 does not prohibit effects generally or derive authority solely from a level number.

A low-level function with raw pointers has no direct L3 call. A high-level wrapper defines ownership, borrow duration, null policy, bounds, element type, mutation, failures and result. Without it only the machine side of [L2](L2_spec_en.md#lowlevel-abi) is available. Numeric-backend initialization and release normally belong to the provider; user numeric code should not manually reproduce its internal storage management.

A `real` context may define precision, rounding, status, traps and exactness requirements; `decimal` additionally includes exponent limits and quantization. Context is explicitly reachable data or fixed profile configuration, not hidden global state. Exact context receiver names remain profile-specific. A deterministic profile must exclude dependence on unspecified platform settings.

Arrays use the same scalar operations and contexts. Vectorization, reduction and tensor operations do not create a different meaning of addition. The minimal mathematics profile includes basic arithmetic, Boolean operations, comparisons, construction/arithmetic for the three extended numeric families, explicit conversions, selected pure functions and numeric-Array operations. It does not imply exposure of the entire C library.

<a id="composition"></a>
## 20. Composition and graph copying

`merge` is an executable operation over live structural operands. It is neither a preprocessor include, C-type composition nor mutation of source values. Operands are evaluated once left-to-right; a fresh root is then built with direct fields in operand and appended-body order. A previous `merge` result can itself be an operand.

The complete used graph is copied with required references and lexical chains to a zero parent. One source-to-copy map spans all operands: shared targets remain shared, cycles are preserved, and references and `parent` links are explicitly rewritten. Operand roots and necessary lexical ancestors do not become extra visible result fields. Parent links are rewritten inside the copy to the corresponding copies of the source nodes; the place that executes `merge` neither supplies a new lexical parent nor re-resolves the body's names. For ordinary copied targets, preservation of relationships means that the result's links refer to the corresponding copied objects, not to the original graph; retention of original targets is limited to reusable native implementation references and the admitted `independent: immutable` branch (below), with optional `const`. The rule is universal for every `merge`, not a special case of child Message creation, and it has no implicit shared-mutable exception: separate mutable instances come from a prototype template, initializing the concrete instance through arguments; shared immutable values are an `independent: immutable` branch; deliberately shared storage is a Message ([delivery](#delivery)). A reference field `@: T` is a pointer cell, and it is copied together with its pointee through the same map. Preserving relationships inside a copy does not bind arguments or change dynamic-input precedence.

A reference inside the copied graph does not create an extra instance of its pointee. The same map redirects it to the instance already produced by copying and composition. For example, with `Holder: p: Model` and `R: merge: Model Holder`, the new instance of the first operand `Model` forms the result `R`; copied `p` points to that instance, neither creating a third copy of `Model` nor retaining an address into the original arena. If a reference targets another copied node, it selects that node's already-created copy. Required lexical ancestors follow the same rule: their `parent` links and internal references are redirected through the common map, not through a separate visibility mechanism. Typed access through the redirected reference uses proved address correspondence, with no runtime name lookup.

Traversal of the complete used graph does not itself grant access to a protected branch or authority to export its contents. Composition preserves the [selected object-protection contract](#protected-structures); `merge` is not an alternative route for opening a protected context.

A reference to a method's reusable native implementation is a terminal under its contract: the implementation receives the graph with which it executes, and its address is not the identity of that graph or of its lexical environment; it is not a shared reference to a mutable callable occurrence or to its lexical context. When `merge` encounters an [eternal branch](#eternal) qualified `independent: immutable` (including one additionally qualified `const`), it MUST **not copy** it and MUST place the original physical value reference directly into the result -- the explicit, single exception to the general copying rule for a graph branch: its root has no external lexical parent and its entire selected graph, including stored references, has passed the immutable preflight before publication. If that guarantee cannot be established, construction/qualification is refused; a merely labelled branch is not retained and copying it is not a fallback for failed qualification. The combination of `independent` and `immutable` grants the exception; `const` has its own contract but is not required for retention. Neither `independent` alone, a null parent alone, nor `immutable` alone grants retention. The existing qualification and lifetime contracts apply, and there is no new flag, receiver or registry. Physical identity is preserved and the source module remains the owner. An implementation and an eternal branch are different kinds of retained material, even where both are called terminals. Range-index visibility and bookkeeping occur inside merge/classification; they are neither a separate visible operation nor an alternative to `merge`. Other used mutable state receives distinct storage, and the algorithm leaves no references into another mutable arena.

### Model slots, field matching and ordering

The first operand is the result's model. A field of a later operand or of the appended body that matches a model field (the match is known at translation: name and type; admission as for assignment) is written **into the model's slot**, not added beside it; a field with no counterpart is appended at the end in operand order. The result has the model's layout followed by the new fields, so the model's field indices never move and methods carry no hidden offset. An operand of the form `name: value`, as `v: 9` in `merge(Model; v: 9)`, is the named argument under the common head/argument model: it is written into the model's slot `v` with that slot's type; it is neither a definition of a Structure `v` nor a primitive whose type is inferred from the value.

### Composition of structural parts

A callable `fn`, `fm`, `sub`, or `catch` Structure contains addressable `args`, `return` where a result is specified, `var`, and `body` parts ([§11](#method-parts)). An ordinary Structure participates as one structural value; `merge` recursively composes corresponding parts under the common model-slot rule. `var` fields remain the same callable occurrence's data, while `body` statements remain its code: nameless statements are not matched to fields by name and do not splice two machine bodies into one function. The result's new field set is determined before allocating its fixed-size `Lmx`. A nested method remains a field of its enclosing Structure and does not execute by itself; a free input retains [§12](#dynamic) priority.

### Explicit callable-body composition

A callable header describes its arguments and result, but is not another `merge` operand and does not move fields between structural parts. In the [example](LMX_semantics_guide.en.md#callable-description), `fn: add5 (int: x) int` has `merge(y: 5; add\body)` in its body position: the path selects `add`'s `body`, and `y: 5` becomes a field of that body's merged result. `add5` still has only formal `x`; its body field `y` is neither added to `args` nor made a formal default. `merge(add; y: 5)` is not equivalent: the outer `add` method Structure contains `args`, `return`, `var`, and `body` parts, but no immediate `y` slot. The completed result undergoes ordinary conversions and [admission](#admission); the body's free names follow [§12](#dynamic).

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

<a id="registries"></a>
## 21. Tables, queries, linking and providers

Registry, Table, RegistryView, schema, and policy are roles of ordinary values, not additional categories or namespaces. An operation obtains a registry root explicitly or through an expressed reference. Merely having a Table or a row keyed `class`, `type`, `provides`, or `satisfies` triggers no lookup and changes no language rule.

In the table profile, the first column is the row key; `columns` supplies names and explicit metadata. Dense-row cell counts are divisible by column count, absent cells are expressed explicitly, and text alignment adds no fields. Optional `source` requests a translator-profile projection rather than declaring runtime names from cells. A cell may refer to data, a key, description, policy, diagnostic, evidence, provider, or callable expression.

A dynamic textual query begins at its supplied root and its ordered children's names; it does not replace already resolved structural references. Query rules, variables, unification, continuations, priorities, and conflicts belong to explicitly selected data and the consumer's policy, not to the general Structure-field rule. A saved check result carries explicit dependencies and grants no indefinite permission for future calls. Candidate selection uses [ordinary admission](#admission); ranking and publishing a result are separate explicit actions.

Module linking resolves only explicitly selected operations and construction recipes to physical references. A provider, codec, or lowering rule is selected by an expressed reference, configuration, or supplied Table; a plan retains the selected reference. Changing providers is explicit. There is no automatic directory scan, process-global search, implicit publication of new names by a query, or separate import operation; `merge` alone composes graphs. Table-storage format and ambiguous-query ranking require a selected profile. [Table and provider examples](LMX_semantics_guide.en.md#tables-and-registries) are adjacent.

<a id="source-codec"></a>
### Current-graph serialization: toLmx

`toLmx` emits LMX text for the **current** [interpretable tree](L2_spec_en.md#interpretable-tree), using the separate [name table](#fields) and retained comments for constructs that still exist. It does not promise to recover the original source text: if publication in `var` replaced an initializer operator with a value, the value is emitted, and the removed operator is not reconstructed from history, `native`, or a hidden graph. Fields added during preliminary assembly are emitted according to the graph's actual state, not as a reconstruction of what was supposedly written. Names come from the table; comments do not execute. Native code cannot abbreviate its representation: a summary, data-only list, or machine-code decompilation does not replace `toLmx`.

`fromLmx` parses text under the ordinary language rules. Portable persistence conveys current content and identities, not a memory image of native addresses, allocator state, and foreign descriptors. Those require separate resource policies without losing the current constructs, names, or comments being preserved.

<a id="memory"></a>
## 22. Ownership, reachability and lifetime

Every Message, executing or not, owns one logical arena of mutable data. It can contain multiple disjoint regions; these are not additional source-level arenas. Calls, blocks, handlers, branches and retries do not create their own semantic arenas. L3 does not select an arena through an operation argument.

Lexical nesting, storage ownership and reachability are distinct relationships. One arena may contain multiple lexical trees. Transferring block ownership preserves addresses and `parent`; the new owner neither becomes the lexical parent automatically nor gains an implicit application reference to every adopted object.

Liveness follows reachability, not block-list membership. Roots include the Message root, active structural arguments, retained own fields, results, formal/dynamic input references, continuations and explicitly retained application/service references. Tracing follows typed graph edges, necessary parents, Array-to-backing links and reference-valued elements. The auxiliary name index is not a root.

Live nodes and descriptors do not move. Growth adds storage without invalidating published references. Lexical exit does not destroy a reachable returned object; return requires no hidden copy or tree promotion. A stable address, however, does not guarantee indefinite life for an unreachable object.

One local collection pass runs at each end-of-turn: determine the outcome, publish successful outgoing Messages or discard failed staging, release completed input/temporary roots, and collect the owner's arena. Ordinary return, `break`, `continue`, `retry`, `redo` and caught `throw` are not separate collection points. A surviving suspended continuation retains its references.

An adopted graph with no application-retained references can be collected at end-of-turn once temporary roots are released, except for lexically declared `independent: immutable` branches (with or without `const`): their owner retains them until the entire arena is destroyed (§23). Arena transfer does not make other graphs permanent roots. Retained failure history lives under its explicit policy. Destroying a Message ultimately releases its remaining storage; collection neither scans another mutable arena nor requires a global lock.

A foreign resource has a separate ownership, retention, release and transfer contract. `copy`, serialization and `merge` do not invent native-resource duplication. Immutability of its identifier does not extend resource lifetime. The physical collector, typed pools and region registration are described in [L2](L2_spec_en.md#arena) and [L1](L1_spec_en.md#arena).

<a id="eternal"></a>
## 23. Eternal branches and shared methods

Combined qualification `independent: immutable` establishes a sealed immutable independent branch: its root has `parent = 0`, and its contents and protected bindings are immutable. `const` may be added but is not required for address retention by `merge` or lifetime until arena destruction. Such a branch may be lexically declared inside an ordinary body, not only at a Message root. Its owner retains every created occurrence until the entire owning arena is destroyed, even if the ordinary surrounding graph later ceases to reference it. For the initial lexically known module, R0's ownership of that arena gives process-long storage. The qualification itself neither selects a global owner nor defines unloading of a future module. Neither of the two qualifications alone establishes this sharing contract.

Process bootstrap may construct a translation-known immutable typed Array of physical references to such branches and explicitly supply it to the root Message. This Array provides access to and transfer of known references; inclusion in it is not required for retention of every lexically declared branch in its arena. `merge` and Message creation neither append to nor inherit this Array automatically. Placement in the Array does not reparent a branch's lexical tree. Permitted runtime-value initialization occurs before publication without increasing the entry set.

Bootstrap may place the published branches and their retaining sealed typed ranges in the Root Thread's (`R0`) arena through the same mechanism that creates typed Arrays in any L3 Thread arena. Process lifetime follows from explicit ownership and retention by R0, not from a hidden table, special storage class, or root-only capability. Collection does not release these explicitly retained initial ranges; a reference to a branch in another Message is an external terminal for that Message's collector and does not transfer ownership.

Membership in the eternal-branch type is established by the same typed-address-range index used for all other physical types. Its sealed range remains in the explicit owner's ordinary arena; retention until arena destruction and exclusion from premature collection determine its lifetime, not a separate permanent store. Before moving a Message under a new supervising parent, check the Message hierarchy: the owner of every `independent: immutable` branch used by the moved Message or its descendants must remain the corresponding Message itself or one of its new Message ancestors. If an owner would leave that chain, refuse the move **before** changing membership or the parent reference: the former chain of mutual control would no longer guarantee the owner's arena throughout the moved Message's lifetime. A move preserving this condition is not forbidden merely because such a branch exists. This concerns supervising `Thread.parent` and arena lifetime, not structural `Lmx.parent`, the language's `node`, or lexical name visibility. These rules neither replace range classification nor become a flag on each branch.

Reparenting has the explicit form `adopt: msg newParent`: `msg` is the moved Message with an executing Thread, and `newParent` is the new supervising Message with a Thread. It copies no branches and does not mask refusal. If the owner preflight fails, the operation raises the ordinary implicit failure `adopt`, handled by `catch: adopt ()`; neither `Thread.children` membership nor `Thread.parent` changes before that refusal. `independent: msg newParent` is a separate, explicit preparation: it copies into `msg`'s arena only the eternal branches actually used by it or its descendants whose owners would leave the new ancestor chain, and redirects the corresponding references to the copies. It does not reparent the Message. The copies retain `independent: immutable` properties, shared references and cycles follow one source-to-copy map, and partial publication on failure is forbidden. Branches that do not obstruct this particular move retain their old addresses. After preparation, `adopt: msg newParent` performs its ordinary preflight anew. Preparation failure raises the ordinary implicit failure `independent` without changing the published graph.

Known method records -- reusable native implementations, not callable occurrences -- may likewise be assembled explicitly into an immutable typed Array in the same arena and supplied through physical references. A supplementary index alongside the reference does not form record identity. A method stores no lexical parent; its concrete callable occurrence supplies its own Structure. Shared records remain live after a borrowing child Message terminates only while their explicit owner retains them. There is no hidden global or root method registry.

R0 retains immutable independent branches of the initial module only because it owns that lexically fixed module, spawns the initial children, and can explicitly pass their translation-known physical references. A DLL-like module loaded later has its own sealed typed ranges under its own owner and in its own arena. When `merge` encounters its `independent: immutable` branch, with or without `const`, the consumer receives the original physical reference in the result and the module remains the owner. This does not make R0 global storage. This specification does not yet define that module's unload operation or the lifetime of those ranges.

`merge` and Message creation retain explicitly supplied references to admitted eternal branches -- under the qualified-branch exception ([composition](#composition)) -- and to reusable native method implementations as terminals; an ordinary mutable callable occurrence and its lexical context are not shared this way but copied. Receiving one branch does not expose its retention Array, root settings or unrelated branches. Mutable state is still copied separately. Every reference within a published eternal branch must have sufficient lifetime; qualification does not make an arbitrary reference to reclaimable storage eternal.

For example, A and B constructed from A's template can have the same eternal E address and distinct mutable x cells -- the intended eternal-branch exception, not an aliasing defect. Finishing A and B does not release E. Equal contents of separately constructed branches do not imply automatic interning. Across processes a native address is not wire identity: an explicit codec is required.

<a id="messages"></a>
## 24. Message, actor and serial turn

A Message is an isolated graph with its own ownership. A plain template or letter is non-executable and may exist as a standalone minimal `LmxMsg`. An executable object is instead constructed as an L3 Thread from the beginning. Its `LmxMsg message` is the first member by value, so the Thread and its Message prefix have the same physical address. This common prefix supplies Message identity and operations only; it does not turn every Message into a Thread or put mail, scheduling, turn mode, or other Thread mechanisms into `LmxMsg`. A standalone Message cannot later be upgraded in place to a Thread. Exact address-range classification still distinguishes standalone Message storage from Thread storage: the generic Message kind admits both, whereas access to the Thread-only tail requires the exact Thread type. Receiving a letter does not automatically create a thread or actor. Launching a separate child requires an explicit operation.

Creating an `lmx_message` or `lmx_thread` places in its own arena only the data and physical references explicitly supplied by the creating operation. Parent state, bootstrap tables, method Arrays, eternal branches, and service references are neither copied nor inherited implicitly. An ordinary L3 Thread can retain and use everything available to R0 when those values are supplied explicitly.

An executing Message has FIFO mail and at most one active turn at a time. A turn consumes at most one admitted input. Different Messages may execute concurrently. An empty mailbox does not finish a background task: its mechanism keeps checking mail according to its execution mode until a stopping condition.

During a turn, one L3 Message executes on exactly one OS thread; transfer to another worker is allowed only between turns. An L3 Thread has no execution mode: each call's path is set by the callable occurrence's descriptor -- with a native address the call executes natively, without one the body (the graph's op tree) is executed by the interpreter; only L3 can be interpreted, L2 operations cannot. One call never runs both paths for one Message: the dispatcher does not retry a call through the other path after a failure and does not override the path set by the descriptor from the body or from a previous dispatch result. Choosing the path neither copies the method nor creates a second concurrent executor; the dispatcher never runs `implements` or other receiving expressions on its own.

One arena has one writing lane. A Message's handler, local management, scheduler and service state are mutated on its own lane. A foreign sender neither appends itself to the owner's ready list nor modifies its application data. Mail admission and designated single-cell control protocols belong to the Message mechanism and grant no general access to foreign memory.

A parent manages only its direct children. Sole membership of those children is a List (`KIND_LIST`) of physical references held directly by the existing `Thread.children` field in the parent's arena, and the parent's scheduler traverses that exact List ([L2 §8](L2_spec_en.md#thread)). This runtime membership does not append fields to the source Structure. A family-record chain, manager membership queue, fixed group of slots, or any other parallel child registry is forbidden. Local traversal-order policy belongs to the parent but does not become a second membership source. Each child likewise manages its own children. There is no separate global language scheduler, shared mutable Message registry, or global management lock. A router, if needed, is itself a Message with private state.

R0 is an ordinary L3 Thread in this tree and has no functions unavailable to another L3 Thread by default. Its parent frame represents the upper element of the future WorldWideMix and connects to R0 through the ordinary parent mechanism; this is Message supervision, not a lexical `node` link. Only the upper frame itself has no parent, but that grants it no additional functions. An external host watchdog, not the frame or R0, applies the overall subtree-close deadline and terminates the OS process if the ordinary cascade cannot reach a safe boundary. R0 has no special child Array, alternate scheduling scheme, or numeric identity.

An L3 Thread is a logical serial lane, not a promise of a dedicated OS thread. Both a dedicated thread and parent/platform-driven turns are possible. L2 implementation defines the API and mapping policy; this does not permit two simultaneous turns of one owner. Parent-liveness polling and self-maintenance are needed even by a childless actor.

The process's initial graph belongs to the root Message. Launch service data and initial settings are held by the already defined R0 parent stub; settings references and user input are passed explicitly at entry, without adding implicit fields to the program's source graph; subsequent coordination uses Messages. Grouping Mix roles, cursors, pages and notifications into Messages remains a design choice: neither one actor for the whole document nor a separate actor for every cell is required.

<a id="addressing"></a>
<a id="delivery"></a>
## 25. Delivery, ownership and mutation order

The local intermediate organization level addresses participants by physical memory addresses within admitted Message-mechanism operations. Hierarchical index chains belong to [WorldWideMix](#worldwide), starting at the third organization scale, not to every local letter. Organization scale must not be confused with language profile L3. A native address is not serialized as a portable address on another machine.

Each L3 Thread owns its mailbox and mail API. A delivery service explicitly supplied by the parent resolves an address and delivers a letter to the destination mailbox's admission operation; it neither observes nor reads mailbox contents. The delivery service does not execute the recipient, schedule its turns, or maintain a child-membership registry.

Delivery of an existing non-executing Message can transfer its storage ownership to the receiver without moving data. Blocks and region classification join the receiver's single arena; the former owner no longer releases them. Lexical links remain unchanged; application attachment of the received root is explicit. Storage transfer is not copying and does not retain the sent object as a second independent owner.

Creating a new executing Message from a template uses [graph copying](#composition) and a separate arena. Ordinary settings are copied; admitted eternal references are retained -- under the same qualified-branch exception as in [`merge`](#composition); there is no second, Message-specific copying policy. Creation does not implicitly import the parent's entire live context. Handing off supervision of a running child, transferring stopped storage and serializing a remote Message are three different contracts.

Concurrent arrivals have no predetermined relative order. Mailbox admission establishes FIFO order, preserved by consumption. Neither random shuffling nor sender-clock order is required. Empty-check/wait coordinates with admission: an accepted letter must not disappear as the receiver begins waiting. Capacity, backpressure and redelivery are explicit implementation/protocol policies.

Multiple senders mutate one object by sending its owner a complete operation. For example, `add(2)` and `add(5)` from initial 0 produce 7 in either admission order. Separate `read` and `write` requests are not one protected operation: two senders may both read 10 and write 11. Serial turns prevent overlapping execution but establish neither transaction rollback nor protection for a split protocol.

Delivery success means admission, not application of a requested change. A result requires protocol-defined reply correlation. The core does not automatically retain per-sender last identifiers or suppress duplicates. Deduplication, retry, batching and sorting requirements belong to explicit protocols without changing base FIFO.

Current-turn outgoing letters are staged separately from the published queue. A successful boundary publishes them in staging order; failure discards unpublished staging. This does not undo graph mutations already performed. The [collection boundary](#memory) follows outcome and temporary-root processing.

<a id="lifecycle"></a>
## 26. Completion, children and retained failure state

An executing Message's `success` is set only by user code: the system never resets it to 0, not even on failure, and never sets it to 1 itself; `success = 1` is a sufficient condition for stopping the Thread at end turn. The system sets `success = 1` only for a plain letter, at its delivery. An empty mailbox is not success. Once `success` is set, the Message's main algorithm receives no next turn; finishing local child maintenance depends on implementation. `running = 0` during execution may be a stop request: physical storage-handoff safety is established by a separate protocol, not inferred from one flag.

A child checks parent liveness and begins its own orderly close after sustained lack of response. Forced closure from above is the second, emergency path. A parent services physical addressees from the sole List (`KIND_LIST`) of its direct children held by `Thread.children` rather than arbitrarily managing grandchildren. Each child repeats the cascade for its own List; closing propagates through the family instead of retaining a released branch forever.

A running child can survive parent closure only through explicit supervision handoff to another live parent with suitable authority. It retains its arena, mail and turn; supervision and scheduling placement change. This is not storage adoption. Storage transfer ends the non-executing source's separate life; new children created from adopted content belong to the receiver.

Stopped failed state may be transferred to the parent without copying and retained as failure-history graph; successful history is reclaimed by default. Transfer requires a stopped, handoff-safe source with no native users. Stop request, actual exit, safe transfer and release must remain distinct; concrete flags and placement belong to the [L2 kernel](L2_spec_en.md#message).

A participant that loses its parent closes under an orphan policy: successful completion releases it, while failure history may remain until an explicit deadline. This policy creates neither a second global registry nor an indefinite owner outside Messages.

<a id="pipeline"></a>
## 27. Incoming-message admission and execution

Incoming data pass through an explicit decoder to become a Message graph. The destination, route and receiving expression are then selected through supplied references or lookup from a supplied root. Neither Message text nor a Table reference installs a hidden environment or grants automatic trust.

Candidate admission follows the [unified mechanism](#admission): analytical traversal of the used tree, followed by receiving-expression unit tests executed by the graph interpreter. Text decoding constructs the input graph before this stage; the test interpreter does not interpret source text instead of the graph.

Routes, authority, lifetime and permitted effects are explicit contract data. Candidate-property checks belong to receiving-expression tests; cryptographic operations may supply verifiable facts. Evidence references exact data, policy and authenticated ingress facts. A result may be reused only under the explicit applicability contract in [candidate validation](#graph-tests).

After admission, an explicit implementation/provider reference is selected and an execution plan is built with arguments, results and required policies. Planning does not execute the chosen application operation, although admission already executed its tests. The executor follows the retained reference. A result or declared failure becomes input to the next explicit consumer.

A logical generator may construct zero or more proposed Messages. Each re-enters the same path; generator origin confers no trust. Received text does not transfer another actor's running frame. Work executes in the receiver's serial turn unless a separate child launch is explicit.

<a id="thread-message-api"></a>
## 28. Ordinary LMX calls over Message transport: `post` and reply waits

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

<a id="mix"></a>
## 29. Mix: active marks and intervals

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

<a id="worldwide"></a>
## 30. WorldWideMix: addresses, cells and navigation

WorldWideMix defines a placement tree: where a cell is situated. The LMX graph defines a value: its fields and what an expression consumes. These trees meet in a cell but are not identical: address `3.17.4` is not field path `file\close`, and `implements` does not number Mix neighbours.

An address is a sequence of nonnegative integers from root to cell. Neither an individual branch's depth nor index magnitude has a language-defined finite ceiling; implementations must check actual resource limits rather than overflow their representation. Leading textual zeros do not change meaning: `03.17` equals `3.17`. A prefix addresses a subtree; shortening the path reaches an ancestor.

The numbers count neighbouring positions, not bytes. A cell may hold a word, buffer or value reference. Varints, mixed-width fields and other codecs store the same integers rather than defining different address types. Changing storage from 5 to 12 bits does not rename `3.17`. Examples of tens of RAM neighbours and larger disk-sector occupancy illustrate carriers, not address-model limits.

Branches may have different depths. For prefix P, `bunch(P)` contains only occupied direct indices. If `{0,4,5}` are occupied, `P.4` is followed by `P.5` and preceded by `P.0`. `next`/`prev` neither descend, ascend nor traverse every document worldwide. `down`/`up` change depth; `next`/`prev` change the last index within one bunch.

A cursor is a path plus a buffer-cell position when needed. Insertion/deletion affects the relevant sibling level rather than readdressing every subsequent file byte. A document is a root, placement tree and mark overlay; a file is one way to serialize pages. Human names, realms, volumes and chapters are attributes/profile conventions, not DNS or a fixed number of levels.

Carriers can be RAM, disk, wire, radio or removable storage; Internet and HTTP are optional. A Message may carry a short address, authority and consumer information instead of an entire large body. The consumer reads needed parts by cursor. Content typing follows the LMX value and [admission](#admission), not its Mix address, MIME or filename extension.

Sorting services are placed outside an individual application, at WorldWideMix nodes corresponding to the placement tree and the routes between its parts. They may accumulate, batch and distribute letters by destination where carrier latency makes that processing useful. This is not a second local-mail circuit and is not a mandatory intermediary between L3 Threads in one process: the local mail collection retains its base FIFO contract. A sorter's buffer capacity, overflow policy and direct-send policy belong to a particular transport profile rather than to L3 semantics.

The Mix overlay places intersecting marks, cursors, attributes and intervals on the same positions. Page-value composition uses ordinary [merge](#composition) with first `[0]` occurrence, not neighbour-address overriding. Disk exhaustion does not authorize automatically spilling data to an arbitrary neighbour: refusal, compaction or an explicitly authorized mirror belongs to storage policy.

<a id="mix-coordination"></a>
## 31. Prefix coordination and mirrors

Mutable Mix state belongs to a Message. A change request addresses its owner and executes in that owner's serial turn. Concurrent senders to one owner need only FIFO; concurrency alone does not require an extra lock-grant step.

Logical prefix exclusion is a separately selected Message protocol, not a native cross-machine mutex or mandatory part of every operation. Reserving P covers all of subtree P, including deeper bunches. A common-prefix coordinator reconciles affected owners but neither writes directly into their arenas nor arbitrarily schedules descendants.

A reservation on `34.3.7` leaves independent `34.3.1` work alone; one on `34.3` must account for conflicts in both branches. The protocol must define when exclusion takes effect, treatment of already admitted commands and protection against late commands under revoked grants. Authority to request a change and a current reservation are different facts. A coordinator record alone does not enforce every write path.

Prefix exclusion implies neither distributed transaction, common rollback nor physically simultaneous mutation. An effective time T requires rules for clock uncertainty, lateness, nondelivery and partial failure. A timeout does not prove the former participant stopped. Grant/token formats, generations, retries and recovery remain explicit protocol choices, not implicit obligations of every Message.

A mirror is another prefix with corresponding content for a particular consumer, not a new fundamental document kind. Writes go to the primary owner; changes reach the mirror as Messages. A reader may tolerate lag; writing through a stale mirror is not automatically safe. A mirror's name is an attribute, while its address is its own path.

Equivalence of primary and mirrored values is relative to the receiving expression's used tree and tests. It does not mean perpetual byte equality. A last-wins projection is permitted for a selected renderer but does not destroy the complete occurrence chain. History and undo may consume Mix changes; a new whole-document version on every edit is not a core rule.

<a id="transport"></a>
## 32. HTTP and service boundaries

HTTP/REST LMX is a transport profile, not the execution core or WorldWideMix. A service is a set of cooperating Messages, not a shared mutable heap. An external request becomes a Message, then undergoes [intake and admission](#pipeline), execution and result-to-transport mapping.

An HTTP target combines normalized endpoint and route. Example: endpoint `https://archive.example.org` with route `/inbox/save`. The receiver resolves the local route in an explicit Table. A route neither names an OS worker, exposes a raw Thread handle nor grants authority by itself.

The original profile posts a complete LMX document with `application/lmx`. A provider receives the URI and exact bytes, returning transport failure or admission status. Substituting a test provider, WinHTTP, libcurl or another adapter does not change Message semantics. No universal process-wide HTTP singleton follows.

A synchronous profile may return the semantic reply in the HTTP response; an asynchronous one may acknowledge admission and later send a Message to `replyTo`. The semantic reply carries `correlation` matching request `id`. Admission, execution and application success remain distinct events.

Instead of a large body, an explicit cursor with range and reading mode may be supplied. Its address, authority and lifetime belong to the receiving expression's contract. Reading compressed content, decryption and format migration are explicit operations; a supplied `targetDescriptor` remains ordinary data rather than a hidden descriptor on every value.

The source external-body example supplies a segment reference, range and reading mode. Cursor authority and lifetime are checked by the receiving expression's unit tests; a short envelope does not waive admission of the data subsequently read.

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

The declarative routing rule below is profile data. A separate receiving expression executes it by interpreting the condition and constructing the delivered Message; the rule record itself does not execute a nested `send`.

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
## 33. Authentication, authority and evidence

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

<a id="crypto-values"></a>
## 34. Cryptographic values and providers

L3 expresses cryptographic intent, key relationships, policy and protocol state. A provider implements primitives, secure storage and platform interfaces. The names below denote semantic contract roles; a concrete profile binds them to receivers and a type structure. Providers are explicitly selected by profile, reference, capability, configuration or service.

AlgorithmId contains family, algorithm, version/profile and relevant parameters. Parameters affecting interoperable protocol bytes are explicit or fixed by a named profile. Algorithm substitution and silent downgrade are prohibited. Missing statically required providers fail build/link; unsupported dynamic selection fails explicitly at the operation.

PublicKey is ordinary non-secret data with algorithm, format and key bytes, optionally id/metadata. It may be copied, stored and transmitted. Raw, SPKI, JWK and other encodings are explicit choices; a provider's internal object is not a wire format.

KeyRef is an opaque secret-key capability with a contract covering owning provider, operations, lifetime and export. It is neither a raw L2 address nor necessarily an Array of secret bytes. KeyPair combines PublicKey and private KeyRef. Generation does not automatically publish private material into the graph; non-extractable keys are valid implementations.

A Verifier explicitly identifies algorithm, format/version, salt and verification parameters: memory cost, time/iteration cost, parallelism and result or canonical encoding. KeyPolicy may define uses, expiry, rotation, revocation, versions, object association, export and recipients; the selected profile defines its exact Structure.

Passing KeyRef, returning it, storing it in a field, composition and provider changes do not export the secret. Its contract defines local multi-Message use, retain/transfer and serializability. The portable default is provider/runtime locality without wire serialization. Sending a secret to another machine requires explicit permitted export/import or a protected envelope.

For a cryptographically protected graph branch, the encrypted stored or transported form and any decrypted working representation are separate cases of the same protection contract. The selected owner/provider and profile must control the plaintext, credentials and keys used by an authorized operation and explicitly govern their lifetime and any permitted exposure. Decryption for use does not automatically publish a plaintext graph to every holder of the ordinary public interface. A provider must not claim confidentiality during use when it cannot enforce the declared boundary; encryption of storage, an omitted source name or a qualifier alone does not establish that guarantee. This requirement prescribes no mandatory provider, algorithm or new graph representation and does not enlarge the secure-memory guarantees below.

Secure memory is a set of distinct capabilities: controlled secret storage, erasure, page locking, guard pages, non-extractability and hardware protection. One does not imply the others. Erasing copies outside provider control in UI, VM or host cannot be promised. Direct calls, service Messages and asynchronous adapters may implement one contract without introducing a new common scheduler or an already defined language `await`.

<a id="crypto-operations"></a>
## 35. Cryptographic operation contracts

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
