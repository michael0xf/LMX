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
- [4. Names, paths and repeated occurrences](#fields)
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
- [17. Arrays, shape and shared backing](#arrays)
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
- [28. Mix: active marks and intervals](#mix)
- [29. WorldWideMix: addresses, cells and navigation](#worldwide)
- [30. Prefix coordination and mirrors](#mix-coordination)
- [31. HTTP and service boundaries](#transport)
- [32. Authentication, authority and evidence](#authentication)
- [33. Cryptographic values and providers](#crypto-values)
- [34. Cryptographic operation contracts](#crypto-operations)

<a id="scope"></a>
## 1. Language scope and execution modes

LMX represents data, executable expressions, models, queries and messages. Source notation constructs Structures; a receiving expression assigns their meaning. Records, trees, configurations, schemas, tables and program bodies share the same structural basis. Registries, services, tables and Mix are families of data and receivers, not additional language levels.

Every language rule is universal within its declared domain and applies uniformly to every matching construct. A name, type, source spelling, nesting level, lowering path, or implementation convenience creates no implicit exception. If an implementation appears to require an exception, or investigation finds a contradiction between rules, the affected decision is suspended for explicit discussion; translator, interpreter, and runtime must not invent workaround semantics.

L3 retains graph mutation, structural calls, tables, messages and local actors. Low-level address operations, raw memory access, raw machine interfaces and explicit low-level synchronization belong to [L2](L2_spec_en.md). The level distinction does not by itself establish computational purity, user authority or a separate security system.

A file extension selects its outer profile: `.lm1` selects direct L1 lowering, `.lm2` L2, and `.lm3` L3. `.lm4` and `.lm5` do not select current profiles. The file is itself a Structure: its root body is an L3 Structure executed from the start in every profile, including `.lm2` -- there L2 is available only inside method bodies; there is no `main` function. L3 is compiled by the same rules as L2; the one difference: a constructed L3 graph *may* be executed by the interpreter, L2 operations may not. Native execution is enabled only inside methods; the current toolchain runs the root body through the graph interpreter -- an implementation default, not a language rule. A Thread has no "interpreted / native" modes -- the only switch is the callable occurrence's descriptor: with a native address it executes natively, without one it is interpreted. The value of executing a file (its exit code) is the value of the root body's last evaluated expression; the root, like every callable Structure, declares no result, and `return` in it is bare only. A service profile may select an explicit function, `start`, a handler or a message send. The entry point receives control after its environment and runtime graph are prepared.

The model supports interpretation of the constructed L3 graph and translation preserving the same semantics. The interpreter executes L3 only: not source text, L1/L2 or `c.*` operations. The interpreter's implementation does not expand the language of the interpreted program. L2 defines machine mechanisms, L3 defines high-level programs, and L1 is an intermediate lowering stage toward C99. The parser, graph interpreter and translator serve different purposes. Grammatical forms, body boundaries, literals, comments and normalization are defined in the [grammar specification](LMX_grammar.en.md).

The levels relate as sets: L3 is a subset of L2. A named Structure and an anonymous Structure always belong to level L3; L2 operations -- address, machine, `c.*` -- are available only inside method bodies (`fn`, `sub`, `fm`). The `@` spelling of any depth (`@:`, `@@:`, `@@@:` ...) in L3 is a reference-declaration receiver only; its other uses are L2 operations and are prohibited in L3. Hence a Structure graph built from any profile is admissible to the L3 interpreter, while a method body may require native lowering.

<a id="l3-receiver"></a>
### L3 receiving expression

The L3 receiving expression defines the contract for consuming a constructed graph as an L3 program. It determines the supported subset and the selected profile's entry point; the mere presence of a syntax tree does not establish program admissibility. An unsupported operation does not become admissible because a machine implementation address exists. A restricted execution profile must explicitly report an unsupported construct rather than silently skip it or execute it as L2. This profile restriction does not replace the [single candidate-admission mechanism](#admission).

Execution follows resolved references and positions in the binary graph, not source names; the diagnostic address-to-name table does not participate in execution, as specified under [names and paths](#fields). A high-level operation may have an explicitly selected machine implementation with an L3 contract, as described at the [numeric/machine-operation boundary](#mathematics); this does not authorize arbitrary `c.*` calls from the interpreted program.

The executable graph representation uses physical references wherever possible. A numeric code is used only where a physical reference cannot be retained or transported; after such a code is resolved, subsequent execution again follows the resulting reference. Textual names do not participate in operation recognition, receiving-expression selection, or dispatch. An internal numeric implementation tag may be used as a local interpreter optimization, but it does not by itself establish the meaning of an L3 node.

The simplest script-profile program is:

```text
print: "Hello World"
```

<a id="values"></a>
## 2. Values, Structures and Arrays

A Structure is an ordered collection of direct fields. Fields hold references to values: primitive cells, other Structures, Arrays and method records. Lexical nesting forms a forest; additional references connect it into a graph containing shared objects and cycles. A primitive cell does not acquire a Structure wrapper merely because a field references it.

An Array contains elements of one type. Its length counts Array elements, while a Structure's field count counts its direct fields. An Array of references to Arrays differs from a rectangular multidimensional Array. The declaration spelling tells them apart: `T: [][]: x` is one rectangular multidimensional Array, flat and indistinguishable from the one-dimensional Array containing it (as in C); `T: []: []: x` applies `[]:` twice and creates two levels of independent one-dimensional Arrays: the outer one holds references to the descriptors of the inner `T` Arrays, each with its own length. A one-dimensional Array of one-dimensional Arrays is not a two-dimensional Array. The rule is general for any `T`; for example the field `char: []: []: mainArgs` is an Array of strings, each string its own `char` Array with the terminating NUL. Representation details and address-range classification of cells are defined in [L2](L2_spec_en.md#type-by-range).

An empty Structure is a present value with zero fields. It differs from an absent field, numeric zero, and `void`, which denotes no primitive-cell content. A Frame's argument list is itself a Structure; the sole anonymous Structure occupying the entire list is transparent already in P0 normalization: its fields become the list's fields, independently of the head and whether it is empty. Thus `f()`, `f: ()`, and an explicitly closed empty vertical body yield one tree with an empty body; `f(a b)` and `f: (a b)` yield one list as well. An anonymous Structure among other fields or in a named position remains a distinct value. Passing an empty Structure as one value requires such a nontransparent position; see [empty bodies](LMX_grammar.en.md#empty-colon).

`None` is contextual: its representation is defined by the type expected by the receiving expression. There is no encoding shared by all types; a type without a corresponding definition of `None` does not accept it. The numeral `0` remains zero and means false in logical operations; it is not a universal absence marker. The earlier `Boolean` profile uses the range −1…1: `None = −1`, false is 0 and true is 1. This is a particular profile definition, not the universal encoding of missing values.

Text, images, decimal notation and machine words are substrate storage before recognition by a receiving expression. After parsing or decoding, they are values of the same graph. Format and numeric-library names do not introduce additional fundamental value kinds.

<a id="identity"></a>
## 3. Identity and lexical trees

Live Structures, Array records, and local Messages retain their physical addresses. A record's physical address is the Message's in-process identity; local identity is not supplemented by a parent index. Storage grows by adding new regions; existing objects do not move. Equal contents do not imply object identity. Explicit copying creates new identities and preserves relationships under the [copying rules](#composition). Hierarchical index chains belong only to [WorldWideMix](#worldwide).

A lexical parent determines a Structure's position in its tree; a root has no parent. Storage ownership and lexical ancestry are independent. Attaching another Message's storage preserves existing lexical links, does not itself add a reference from the recipient's root and does not make the adopted root a lexical child of the recipient.

The [independent qualifier](#qualification) cuts the external lexical parent at construction; obtaining inputs from the caller follows [dynamic visibility](#dynamic). Neither mechanism changes storage ownership or object identity.

<a id="references"></a>
<a id="fields"></a>
## 4. Names, paths and repeated occurrences

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

<a id="descriptions"></a>
## 5. Explicit value descriptions and conversions

A value description is an ordinary explicitly accessible Structure. A receiving expression obtains it through an argument or reference. It is not secretly attached to every primitive and is unnecessary for determining a physical type from an address. Names such as `class` and `class.range` denote a particular profile's data, not mandatory global language entities.

A description separates its semantic contract from architecture binding. The contract defines meaning: count, integer, rational, profile-precision number, complex value, atom, address, opaque resource or absence of content. The binding defines width, signedness, range and target spelling. Equal representation does not imply equal contracts: `Boolean` and `int8` may share storage while admitting different values.

Ordinary description fields include `cell`, `semantic`, flags such as `numeric`/`integer`/`floating`/`reference`/`opaque`, `width`, `signed`, `range`, `spelling` and `convert` keys. The profile chooses field names. A range declaration is contract data; satisfaction is established through the [single admission mechanism](#admission), not by the field's presence alone.

The numeric contract chain is flag → nonnegative integer → integer → rational → profile-precision number → complex number. Nonnegative integers include zero. Machine `double` is not the set of all real numbers. Atoms, addresses and opaque resources are separate contracts, not rungs of this numeric chain. `unit` is an empty Structure; `void` denotes no cell content.

Descriptions are composed with ordinary `merge` under the common [occurrence-order rule](#fields). Fields such as `width`, `range` or `spelling` do not automatically create arithmetic methods. Such operations are callable expressions. For example, `u32` combines a nonnegative integer contract, 32-bit representation and range 0…4294967295; `FILE` describes opaque resource identity. A `FILE` word alone does not establish that reading or closing is valid: such requirements are expressed through paths of a `File` Structure.

A converter is an explicitly selected receiving expression. Conversion keys come from explicit descriptions and their composition; there is no hidden search across all type pairs. Analytical checking does not execute a converter. When an operation requires conversion, the selected call is executed; a missing key does not create a nonexistent converter. A later same-name key does not displace the first without explicit occurrence selection.

Numeric conversion preserves the destination-range contract: `u16(255) → u8` is admitted when the converter exists, while `u16(256) → u8` produces a range error, not zero. Rounding `1.5 → i32` and in-range precision loss require explicit numeric-profile rules. Proven range inclusion may eliminate a redundant machine operation while preserving the semantic requirement. Format, range and converter-behavior failures are not replaced by a positive `implements` result.

<a id="conversion-context"></a>
## 6. Message-local type bindings and conversion context

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

<a id="admission"></a>
## 7. Analytical checking and candidate validation

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

<a id="admission-recipes"></a>
## 8. Obtaining a required guarantee: fourteen practical cases

Most questions about guarantees reduce to a practical choice: where must a distinction be placed so that the required property is actually checked? A guarantee does not arise from a global strict mode; it arises from the part of a Structure that Consumer must traverse and from the tests defined by the receiving expression. Just as a C `typedef` merely names an alias while a wrapping `struct` creates a separately enforced boundary, LMX relies on the expressed path and its consumption contract.

The following fourteen cases are recipes: what to express, what that expression does not establish, and where the governing rule lives. They apply the [single admission mechanism](#admission): its analytical stage checks used paths, then the graph interpreter must execute the receiving expression's unit tests.

<a id="admission-case-1"></a>
### 1. One receiving expression for multiple data shapes

Write the receiving expression against the paths it actually needs. Any Structure providing those paths, admitted leaves and the exact signatures of expressions actually invoked can qualify. Structures are ordinary data, material for explicit descriptions and results of composition, so the used tree is the contract. There is no separate generic type-parameter declaration or instantiation operation. Used-tree checking is LMX's structural-generalization mechanism, not a promise of every property of parametric polymorphism.

<a id="admission-case-2"></a>
### 2. Knowing what a particular site checks

Consumer determines analytical coverage; unknown coverage is distinguished from known thin consumption. Analysis is followed by the graph interpreter executing that same receiving expression's unit tests. Every actual call must additionally receive all inputs required by its signature. These stages do not subsume one another: they have different inputs and coverage. Success neither freezes candidate or Consumer nor certifies future uses after either changes.

<a id="admission-case-3"></a>
### 3. Distinguishing meanings with the same representation

Encode the distinction in a path the receiving expression actually uses. With `Distance: Meter: 1`, access through `d\Meter` requires that path; a Structure exposing only `Foot` does not provide it. An outer name `Meter`, a field `unit: "meter"` or `const` alone is insufficient: path presence does not compare the value at its leaf. Immutable build-time data may permit preliminary proof of exact equality, but mandatory tests remain part of unified admission; otherwise a receiving-expression test checks the substantive constraint.

<a id="admission-case-4"></a>
### 4. Constraining a scalar leaf

State the constraint explicitly and include it in tests. Presence of `x\width` does not establish `width = 32`: traversing a description requires its used paths, but a terminal scalar may remain thinly consumed. Immutable build-time data may undergo preliminary analysis and exact comparison, but such a proof is not an alternative runtime-validation mechanism.

<a id="admission-case-5"></a>
### 5. Making a change visible to other reference holders

To make a change visible to other holders, write through an explicit path: `p\x: value` or `a[i]: value` changes the selected referent. A resolved bare `x: value` targeting an already typed explicit or hidden argument makes the translator prepare a same-name own field of the current body; when executed, the statement binds the local cache to that field, marks it `dirty`, and publishes specifically into the body's field at the next checkpoint. The write remains local with respect to its source: it changes neither the caller's argument nor the parent graph. An L3 reference is declared by the distinct receiver `@: Type var`, not by taking the address of a local variable; the complete rule is under [working state](#dynamic). Execution does not append the field: translation has already fixed the graph layout.

<a id="admission-case-6"></a>
### 6. Independence from another holder's mutation

`copy:` creates an independent mutable value only within its copying contract; genuine immutability prohibits mutation of the protected value. Ordinary Structure or Array passing copies the reference, not the referent. Another alias within the Message can therefore change the shared mutable object. An immutable foreign-resource identifier does not make the foreign resource immutable.

<a id="admission-case-7"></a>
### 7. Establishing that a call can proceed

Both conditions must hold: compatibility covers used paths and the callable's exact signature, and every dynamic input must be available from caller locals, inherited inputs or that callable occurrence's immediate `node\x`. Suppose A and B expose the same `m`, whose body uses bare `x`, while Consumer only invokes `m`: the used-callable check can pass while call admission still rejects a missing `x`. A known case is rejected during translation; a runtime-selected target requires the corresponding runtime boundary. This rule does not add callee-body expansion to `uses`.

<a id="admission-case-8"></a>
### 8. Checking a transported callable

Transporting a callable neither executes it nor requires knowledge of every future call contract. Checking occurs at the actual call: the selected expression must have the exact signature, receive every dynamic input and satisfy applicable admission, even if an earlier partial check never inspected it. Equal signatures do not imply equal behavior.

<a id="admission-case-9"></a>
### 9. Changing a method body without breaking calls

The body's free dynamic names are part of its interface. Adding one changes `DynRequired` and therefore `sig`; known callers require rechecking, while runtime-selected callables remain subject to actual-call admission. An immutable method record neither makes every occurrence referring to it immutable nor prohibits explicit replacement of a reference with a compatible callable. Behavioral change under the same signature remains a matter for tests and program correctness.

<a id="admission-case-10"></a>
### 10. Selecting the intended part of a composition

Select the field explicitly or construct the intended fields. `merge` builds a new tree and does not mutate its operands; a later operand's same-name field overrides the model's slot in place (specialization), and no new occurrence of that name arises. If model A has `read` and B has a `read` of a compatible type, `result\read` is A's slot holding B's value; a `read` with no counterpart in the model is appended at the end. Analytical diagnostics may expose an unintended unqualified selection after an import or composition changes. Source parts need not be adjacent or statically available.

<a id="admission-case-11"></a>
### 11. Changing an existing Structure

Field count and slots are fixed. Ordinary field operations may replace the `void *` child references stored in existing fields; a change in the target's actual type follows the ordinary rules for such updates and later consumption. A different field count requires a new Structure, such as a `merge` result. No conflict policy is introduced for nonexistent operations that remove or move an active field.

<a id="admission-case-12"></a>
### 12. Reliable numeric conversion

Use an available explicitly keyed converter with a destination-range contract: `u16(255) → u8` is admitted, while `u16(256) → u8` is a range error, not zero. In-range rounding and precision loss are a separate numeric-profile policy. Successful analytical checking does not permit silent modular wrapping.

<a id="admission-case-13"></a>
### 13. What a broad converter table provides

Additional explicit keys widen only the available leaf conversions. They do not alter required structural paths or exact callable signatures, and a profile need not provide every pair. Neither analytical checking nor path-selection tests execute a converter or search for a hidden conversion chain.

<a id="admission-case-14"></a>
### 14. Foreign-resource validity

A foreign handle requires a checked high-level wrapper and explicit resource and cleanup contracts. A thin `FILE`-like leaf does not establish validity, authority or single close. The receiving expression's unit tests check declared properties within their contract; immutable handle bits do not keep a resource alive. L3 has no ordinary machine-level `own:`/`borrow:`/`move:`, and `copy:` does not invent a foreign resource's duplication policy.

<a id="construction"></a>
## 9. Value construction

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

<a id="qualification"></a>
## 10. const, immutable and independent

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

<a id="execution"></a>
<a id="callables"></a>
## 11. Callable expressions and their interfaces

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

<a id="publication"></a>
<a id="dynamic"></a>
## 12. Dynamic inputs and working state

A persistent graph field, a field of the current activation's data instance, an explicit formal argument and a dynamic input must be distinguished. They are separate storage locations with separate mutation rules. Ordinary passing copies a mutable primitive's value and a Structure or Array's reference; the special identity of an immutable value is retained under [qualification](#qualification).

For a free name, the called expression receives the current value from the caller's available context; if unavailable, permitted lexical lookup follows `node`. Own declarations and formal parameters have their respective resolved locations rather than being searched in a global registry. Required through-names are part of the signature: adding a free name changes the interface. A missing required input makes the call inadmissible; silently creating zero or a new field is prohibited.

A free name's sources have this priority: the caller's nearest current local binding, then its already inherited dynamic input, then the callee's lexical lookup. A local binding includes a used own field, formal argument, result or another receiver-defined local value. Statically known call requirements propagate to a fixed point, including through mutual recursion. A name needed only by the next call must still be retained and forwarded; forwarding alone creates no graph field.

Lexical lookup uses real Structure links, stops at a zero parent and selects the direct first same-named occurrence at the relevant step. `independent` cuts only the external lexical fallback. Explicit access through `node\x`, `reference\x` or `array[index]` addresses the graph rather than being replaced by the current call's dynamic `x`.

An own field of the current activation is a field of the callable occurrence itself (or of its instance under re-entry); assigning that name writes into this field directly, with no working copies and no modification mark. An explicit reference write changes the selected object directly and is observable through other references to it. An explicit or hidden argument is a value of the machine activation; it becomes a field of the instance only when a bare assignment targets it (below), and without such an assignment it remains an ordinary input value with no copy-back to the caller.

The presence in a source body of a resolved bare assignment `x: value`, where `x` is an already typed mutable explicit or hidden argument, makes `x` a field of that body's data prototype. For the assignment role, `value` must also resolve as an existing typed value or intrinsically as a literal; otherwise this rule creates no field, and translation selects another already defined contextual colon role or reports an error. Executing the statement writes the value into that field; an untaken branch writes nothing, and the field keeps its previous value. Translation has already fixed the prototype's layout, so execution changes no field count. The write lands in this body's data instance, never in the caller's argument source or the parent graph.

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

<a id="branches"></a>
## 13. Branches and loops

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

<a id="suspension"></a>
## 16. Restart and suspension

`retryable` defines a restartable region. Unlabelled `retry` repeats the nearest active such region; `retry: label` repeats the named one. Abandoned-attempt cleanups run before restarting. The transfer does not roll back external effects, graph mutations, already published fields or Messages. Transactional rollback requires an explicitly represented data protocol.

`retry` itself is a local transfer in the current activation, not a new call or restoration of a hidden environment. Current working values continue to exist, with no additional publication merely because of the transfer. If repeated execution reaches a call or exit, that boundary's ordinary rules apply. A caught failure's payload remains the handler's explicit arguments.

`yield` transfers a produced value and suspends the activation. There is no publication before suspension: the data instance's fields are already current. Explicit arguments, dynamic inputs, locals and their subsequent state are retained for resumption; they do not become body fields or a public hidden environment. Resumption keeps working with the same data instance.

Producer inputs are fixed when its activation begins. A later `next` caller does not replace them with its own dynamic context. If `next` is a separate wrapper expression, its inputs belong to its activation unless an explicit operation changes the producer's saved state. The continuation and iterator-result representation is not observable when it preserves these semantics.

<a id="arrays"></a>
## 17. Arrays, shape and shared backing

An ordinary Array is a typed value with stable reference identity. Constructor `[]` creates it when execution reaches the construction site. A Structure field holding its reference is not the Array itself. Passing a reference does not copy elements; an element mutation is visible through other references, whereas rebinding a local reference is not.

An owning Array has one contiguous rectangular block of elements. Nested dimensions do not mean separately allocated rows. For shape `[d0, …, dN−1]`, element count is the product of dimensions, with the last index varying fastest. An Array of references to other Arrays is a different value, not a replacement for a rectangular multidimensional Array. Primitive elements acquire no lexical parents.

The common physical Array descriptor is `VoidArray {size_t size, void *data}`. In `Lmx {VoidArray array, Lmx *parent}`, the same descriptor is embedded by value as the first member and is the actual array of physical child references; its backing is registered as an arena address range, but the range entry is not the `VoidArray` itself. A separate `LmxArrayDesc` alias is unnecessary. For a standalone Array, `size` is its logical element count and the backing has exactly that many cells. Base Array has no `capacity` and does not grow, resize, append, or switch backing. Dynamic membership, capacity, and growth belong only to separate dynamic descriptors of the form `{<T>Array array; size_t capacity}`, where `<T>Array` is the already existing fixed descriptor of the real element type T (void is only one element type: today `LmxArrayDesc` solely for `void *` elements; an int array is `{size_t len; int *data}`, never the void descriptor with casts). List (`KIND_LIST`) is a public such DynamicArray over `void *` elements, with no hidden capacity prefix in the backing. Physical addresses stored as referent values are unaffected by List growth; a List backing-slot address does not survive private-backing replacement.

`shape(array)` returns dimensions as a rank-one integer Array or shape Structure; `rank` returns their count; `length` for positive rank returns the first dimension; `size` returns total element count. The containing Structure's field count, Array length and service descriptor-pool size are distinct.

A full rank-N index contains N integer coordinates. L3 access checks the Array descriptor and index bounds; an out-of-bounds access produces a `Bounds` failure, not `None`. A partial index may produce a view, such as first row `matrix[0]`; full `matrix[0, 2]` selects an element. Coordinate spelling belongs to the [grammar](LMX_grammar.en.md), not C machine indexing. These checks belong only to L3: [L2 access](L2_spec_en.md#lowlevel-address), including obtaining a graph-backed element's address, works without them. Operation checks do not constitute a separate candidate-admission mechanism in place of [analysis and unit tests](#admission).

A view can share backing within one Message; a copy has separate backing. `slice`, compatible `reshape`, `transpose`, `permute`, `broadcast` and partial indexing may create views; `copy`/`clone`, materialization and ordinary elementwise arithmetic results create copies unless an existing output buffer is selected. View representation is internal, but it must retain the backing for the view's whole lifetime and explicitly define mutable sharing. Returning a reference must not hide copying to repair lifetime.

`reshape` preserves values and total element count; changing the count requires an explicit fill/truncate/copy contract. Compatible storage permits a view; otherwise explicitly defined materialization is necessary. `transpose` exchanges the last two axes for rank at least two or follows the selected matrix profile. `permute(array, axes)` specifies an axis permutation. An operation's logical stride data need not add fields to every universal descriptor.

<a id="array-operations"></a>
## 18. Array operations

Array arithmetic and comparisons are elementwise by default. Element operations follow their numeric domain and explicitly selected context. `*` means elementwise multiplication, not matrix multiplication. `matmul`, `dot`, `contract` and `outer` are separate explicit operations; a profile-specific matrix symbol must not make ordinary `*` ambiguous.

Broadcasting aligns positive extents from the right. A pair is admitted if equal, if one equals 1, or if one side is absent and treated as 1; the result uses the maximum. Examples: `[3]` and a scalar give `[3]`; `[2,3]` with `[3]` is treated as `[2,3]` with `[1,3]`; `[2,3]` with `[2,1]` gives `[2,3]`. A repeatedly read scalar is not expanded into another Array. Internal zero stride can represent repeated reads of one element. Zero extents are not defined by this rule.

`reduce` collapses elements with an associative or explicitly ordered operation. With no axis it returns a primitive by default; a profile may explicitly request a rank-zero Array. With an axis, only that axis is collapsed. The contract defines an identity where needed, element operation, result type and ordering. Reproducible real/decimal computations must not depend on an incidental backend choice of order.

`scan` is a prefix reduction: inclusive sum of `[1,2,3,4]` gives `[1,3,6,10]`. Inclusive or exclusive behavior is explicitly selected. `map` applies an expression to elements; a pure variant permits vectorization and parallel evaluation preserving the result. Effects need explicit ordering; the default profile expects pure mapping.

`filter` selects elements by a Boolean predicate and normally materializes a new Array: selected positions need not form a regular view. `concat` joins along the selected axis; other dimensions must match. Its result is normally a new Array with rectangular backing. Copies, materialization and all results retain Message ownership boundaries.

The minimal numeric profile defined here covers ranks 1/2, contiguous storage, checked indexing, shape, copying, elementwise `+ - * /`, scalar broadcasting, equal-shape operations and whole-array reduction. Other numeric profiles may add operations through separate contracts.

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

The complete used graph is copied with required references and lexical chains to a zero parent. One source-to-copy map spans all operands: shared targets remain shared, cycles are preserved, and references and `parent` links are explicitly rewritten. Operand roots and necessary lexical ancestors do not become extra visible result fields. The new root's lexical parent follows the `merge` expression's location.

Shared method references are terminals under their contracts. When `merge` encounters an [eternal branch](#eternal) qualified `independent: const: immutable`, it MUST **not copy** it and MUST place the original physical value reference directly into the result. Physical identity is preserved and the source module remains the owner. Range-index visibility and bookkeeping occur inside merge/classification; they are neither a separate visible operation nor an alternative to `merge`. Other used mutable state receives distinct storage, and the algorithm leaves no references into another mutable arena.

The first operand is the result's model. A field of a later operand or of the appended body that matches a model field (the match is known at translation: name and type; admission as for assignment) is written **into the model's slot**, not added beside it; a field with no counterpart is appended at the end in operand order. The result has the model's layout followed by the new fields, so the model's field indices never move and methods carry no hidden offset. A callable Structure consists of the named parts `args`, `return` and `body`; every other Structure, named or anonymous, is one `body` part; a missing part takes part in `merge` as an empty Structure of the same meaning. `merge` proceeds part by part and recursively -- `args` with `args`, `return` with `return`, `body` with `body` -- under the rule above at every level: an operand's same-name field is written into the model's slot, a new one is appended. The model stays the outer frame and each later operand merges inward, as a directory's contents into a directory: `merge(add; y: 5)` puts the field `y` into the `body` of the method `add` (specialization), while `merge((n: 5); addN)` puts the method `addN` inside the Structure holding `n` as a nested field -- such a Structure is not itself callable (its field 0 is `n`), the call is written `w\addN(...)`; `n` in the body of `addN` resolves to the enclosing Structure's field. Nameless `body` statements have no slots: the operand's statements replace the model's when the operand has any. Wherever a callable type is declared -- the header `fn: add5 (int: x) int merge(y: 5; add)`, the result `fn` of `fn: makeAdder (int: n) fn`, a callable formal or an assignment target -- a Structure holding a callable occurrence is converted to it by one more `merge` with the method as the model: `merge(add; {y: 5}; the declared header)` -- the method's formals absent from the declared signature are bound to same-name fields (name and type checked as in every conversion), the declared header overrides `args` and `return` (the signature of `add` disappears). Returning a nested method is one such `merge` with three operands: the method, the Structure of the activation's actually used values, the declared header; `add5: 1` gives 6. The result's `native` word is empty, so it executes through the interpreter; operations address fields by their slot in `node` and are renumbered by the position map. Nested methods are carried over whole and keep their `native` words. A method's native implementation is never merged. The file is itself a Structure, so a method declared at file level is declared inside it and its fields are the method's lexical parent; a field of another Structure that references such a method (`A: fn: M`) stays, under `merge`, a shared reference to the same occurrence: it is not copied and the method's `node` does not change. A method declared inside an operand's body is copied with the operand and keeps its field indices. A returned nested method is built the same way: the activation assembles a Structure from the values actually used and copies the nested callable occurrence into it by the same `merge`; no hidden closure environment arises. Successful composition publishes a fully initialized result, requires no short-name registration and leaves sources unchanged.

Failure is a throw named `merge` (as for every operator whose `throws` list the programmer does not see written out): catching it is optional; an uncaught one flies to the root and the Thread stops (`running = 0`); a handling point `catch: merge` -- before the call, after it, or in a separate nested block, under the rules of [declared failures](#exceptions) -- handles it in the ordinary way and nothing flies anywhere. There is no separate partial-result protocol. This does not promise rollback of operand-evaluation effects. Temporary-storage release follows the owning Message's rules. The exact low-level mechanism is in [L2](L2_spec_en.md#copy-merge).

A type description, schema, module data or Table is ordinary data: applying `merge` does not select a special descriptor-composition algorithm. `table` materializes an explicitly selected table representation; `join` creates a new table graph without mutating operands. Row, key, conflict and priority policies belong to the table operation, not structural field lookup.

Ownership transfer of existing storage during Message delivery is a [different operation](#delivery), without copying or changing the structural `parent`. Admission-policy combination is likewise not `merge`: it selects and checks explicit data without default structural copying.

<a id="registries"></a>
## 21. Tables, queries, linking and providers

Registry, Table, RegistryView, schema and policy are roles of ordinary values, not additional categories or hidden namespaces. Each operation receives a registry root explicitly or reaches it through an expressed reference. Merely having a Table does not trigger lookup; a row keyed `class`, `type`, `provides` or `satisfies` does not change language meaning.

In the table profile the first column provides the row key. `columns` contains names and optional explicit metadata; the cell count of dense rows must be divisible by column count, with missing cells represented explicitly. Text alignment adds no fields. Optional `source` requests a translator-profile projection rather than declaring cell contents as runtime bindings.

A cell can reference data, another key, a description, policy, diagnostic, evidence, provider or callable expression. Dynamic textual lookup starts from a supplied root and uses its ordered children's names. It neither replaces resolved structural references nor makes the Table a global runtime environment. A saved check result remains data with explicit dependencies, not indefinite permission for future calls.

Procedural consumption invokes a selected expression; object/event consumption supplies an explicit target and state; functional consumption follows operation references; logical consumption constructs results and Messages from explicit inputs. Rules, query variables, unification and continuations are data in their respective graph. A query result does not implicitly publish new names for other expressions.

A reactive update may produce events, which are Messages. An agent can propose a row or Message; every candidate undergoes [unified admission](#admission). An explicit policy ranks admitted candidates, and a separate operation publishes the selected result. Neither a successful test nor selection of the best candidate updates the Registry by itself.

Module linking only resolves explicitly selected operations and construction recipes to physical references. It neither scans arbitrary directories, constructs every instance nor copies a runtime namespace. Providers, codecs and lowering rules are selected by an explicit reference, configuration or supplied Table. An execution plan retains the chosen reference; changing providers is explicit, not the result of hidden global lookup. There is no separate semantic import operation: only `merge` performs graph composition.

`toLmx`/`fromLmx`, when provided by a profile, specify codec operations with explicit policy. Portable persistence represents content and identities under the codec, not a memory image of native addresses, allocator state and foreign descriptors. The latter require separate external-resource policies.

### Keys and cells

The following source examples describe an optional table profile. Keys `Circle` and `int` in the first Table are data, not declarations. String values in the second describe target spellings; obtaining `"uint8_t"` through `u8` and `spelling` does not change the source type's semantics.

```text
    table:
        name: classes
        columns: key kind
        rows:
            Circle layout
            int    primitive
    end: classes
```

```text
    table:
        name: `translator type-->spelling`
        columns: class (spelling char)
        rows:
            u8  "uint8_t"
            u16 "uint16_t"
            u32 "uint32_t"
    end: `translator type-->spelling`
```

An operator cell can directly hold an implementation key. For example, the following Table selects `u32_eq` for the corresponding pair; `None` is this profile's missing-cell marker, not numeric 0.

```text
    table:
        name: `equals.data`
        columns: class (u32 char) (decimal char)
        rows:
            u32     u32_eq None
            decimal None decimal_eq
    end: `equals.data`
```

### Relations, linking and queries

One relation can be represented as a matrix of type pairs or organized around one operand. These are different views of explicit data, not hidden overload registration. Sparse-cell notation belongs to the selected table profile.

```text
    table `equals.relations`

              decimal          real             int
    decimal   decimal_eq       decimal_real_eq  decimal_int_eq
    real      real_decimal_eq  real_eq          real_int_eq
    int       int_decimal_eq   int_real_eq      int_eq
```

```text
    table `decimal.relations`

              decimal          real             int
    plus      decimal_plus     decimal_real_add decimal_int_add
    minus     decimal_minus    decimal_real_sub -
    equals    decimal_eq       decimal_real_eq  decimal_int_eq
```

A table consumer may define linked-source order and numeric priorities. Conflicting-row policy belongs to that consumer and does not override first-occurrence structural lookup. Registry construction and querying remain separate operations.

```text
    table:
        source
        name: appEquals
        import:
            numericEquals
            textEquals
        priority:
            numericEquals: 20
            textEquals: 10
        String:
            String: string_eq
    end: appEquals
```

```text
    table:
        name: equalsData
        columns: left right implementation
        rows:
            decimal int decimal_int_eq
            int     int int_eq
    end: equalsData

    Registry: numericRegistry equalsData

    query: numericRegistry equalsData decimal int
```

### Linked result, effect and implementation tables

A selected cell need not repeat its lookup keys. Here `plus[decimal][int] = decimal_int_add` explains a selection result, not assignment syntax. Separate Tables use that key to describe result, effect, target level, lowering and cost. A `pure` row remains a declared property: its presence does not prove the selected expression's purity.

```text
    table:
        name: plus
        columns: class (int char) (u32 char)
        rows:
            decimal decimal_int_add None
            u32     None            plus_u32_u32_l2
    end: plus

    table:
        name: `plus cell-->result`
        columns: class (result char)
        rows:
            decimal_int_add decimal
            plus_u32_u32_l2 u32
    end: `plus cell-->result`

    table:
        name: effects
        columns: class (effect char)
        rows:
            decimal_int_add pure
            plus_u32_u32_l2 pure
    end: effects

    table:
        name: level
        columns: class (level char)
        rows:
            decimal_int_add L2
            plus_u32_u32_l2 L2
    end: level

    table:
        name: `implementation-->L2 lowering`
        columns: class (symbol char)
        rows:
            plus_u32_u32_l2 "+"
    end: `implementation-->L2 lowering`

    table:
        name: cost
        columns: class (cost serial)
        rows:
            decimal_int_add 10
            plus_u32_u32_l2 1
    end: cost
```

A diagnostic result can also be an ordinary cell value. For a higher-arity relation, an explicit query can follow an intermediate key; the arrows below explain this selection sequence.

```text
    table:
        source
        name: plus
        decimal:
            String:
                diagnostic:
                    code: incompatibleOperands
                    message: "plus(decimal, String) is not defined"
                end: diagnostic
    end: plus
```

```text
    multiply[Matrix][Matrix] -> MatrixMultiplySignature
    MatrixMultiplySignature[leftCols][rightRows] -> matrix_mul_impl
```

### Provider selection

`sqrt.dispatch` selects a result and implementation key; two linked Tables describe lowering and provider. MPFR, ANA_SQRT and CPU_C_Libm are concrete example data, not mandatory built-ins. The selected expression undergoes [ordinary admission](#admission), and the execution plan retains its reference. Physical table storage, hash/SQLite backends, ambiguous-query ranking and a common diagnostic format require a separate profile.

```text
    table:
        name: `sqrt.dispatch`
        columns: class (result char) (implementation char)
        rows:
            BigFloat BigFloat sqrt_mpfr
            fixedQ16 fixedQ16 sqrt_ana
            f64      f64      sqrt_ansi_c
    end: `sqrt.dispatch`

    table:
        name: `implementation-->L2 lowering`
        columns: class (symbol char)
        rows:
            sqrt_mpfr   "mpfr_sqrt"
            sqrt_ana    "ana_sqrt"
            sqrt_ansi_c "sqrt"
    end: `implementation-->L2 lowering`

    table:
        name: providerOf
        columns: class (provider char)
        rows:
            sqrt_mpfr MPFR
            sqrt_ana ANA_SQRT
            sqrt_ansi_c CPU_C_Libm
    end: providerOf
```

<a id="memory"></a>
## 22. Ownership, reachability and lifetime

Every Message, executing or not, owns one logical arena of mutable data. It can contain multiple disjoint regions; these are not additional source-level arenas. Calls, blocks, handlers, branches and retries do not create their own semantic arenas. L3 does not select an arena through an operation argument.

Lexical nesting, storage ownership and reachability are distinct relationships. One arena may contain multiple lexical trees. Transferring block ownership preserves addresses and `parent`; the new owner neither becomes the lexical parent automatically nor gains an implicit application reference to every adopted object.

Liveness follows reachability, not block-list membership. Roots include the Message root, active structural arguments, retained own fields, results, formal/dynamic input references, continuations and explicitly retained application/service references. Tracing follows typed graph edges, necessary parents, Array-to-backing links and reference-valued elements. The auxiliary name index is not a root.

Live nodes and descriptors do not move. Growth adds storage without invalidating published references. Lexical exit does not destroy a reachable returned object; return requires no hidden copy or tree promotion. A stable address, however, does not guarantee indefinite life for an unreachable object.

One local collection pass runs at each end-of-turn: determine the outcome, publish successful outgoing Messages or discard failed staging, release completed input/temporary roots, and collect the owner's arena. Ordinary return, `break`, `continue`, `retry`, `redo` and caught `throw` are not separate collection points. A surviving suspended continuation retains its references.

An adopted graph with no application-retained references can be collected at end-of-turn once temporary roots are released. Arena transfer does not make it a permanent root. Retained failure history lives under its explicit policy. Destroying a Message ultimately releases its remaining storage; collection neither scans another mutable arena nor requires a global lock.

A foreign resource has a separate ownership, retention, release and transfer contract. `copy`, serialization and `merge` do not invent native-resource duplication. Immutability of its identifier does not extend resource lifetime. The physical collector, typed pools and region registration are described in [L2](L2_spec_en.md#arena) and [L1](L1_spec_en.md#arena).

<a id="eternal"></a>
## 23. Eternal branches and shared methods

Combined qualification `independent: const: immutable` establishes a sealed immutable independent branch: its root has `parent = 0`, and its contents and protected bindings are immutable. For the initial lexically known module, explicit retention by owner R0 gives process-long storage. The qualification itself neither selects a global owner nor defines unloading of a future module. Any one qualification alone does not establish this sharing contract.

Process bootstrap may construct a translation-known immutable typed Array of physical references to such branches and explicitly supply it to the root Message. `merge` and Message creation neither append to nor inherit this Array automatically. Placement in the Array does not reparent a branch's lexical tree. Permitted runtime-value initialization occurs before publication without increasing the entry set.

Bootstrap may place the published branches and their retaining sealed typed ranges in the Root Thread's (`R0`) arena through the same mechanism that creates typed Arrays in any L3 Thread arena. Process lifetime follows from explicit ownership and retention by R0, not from a hidden table, special storage class, or root-only capability. Collection does not release these explicitly retained initial ranges; a reference to a branch in another Message is an external terminal for that Message's collector and does not transfer ownership.

Membership in the eternal-branch type is established by the same typed-address-range index used for all other physical types. Its sealed range remains in the explicit owner's ordinary arena; explicit owner retention and exclusion of that range from collection determine its lifetime, not a separate permanent store. These rules neither replace range classification nor become a flag on each branch.

Known method records may likewise be assembled explicitly into an immutable typed Array in the same arena and supplied through physical references. A supplementary index alongside the reference does not form record identity. A method stores no lexical parent; its concrete callable occurrence supplies its own Structure. Shared records remain live after a borrowing child Message terminates only while their explicit owner retains them. There is no hidden global or root method registry.

R0 retains immutable independent branches of the initial module only because it owns that lexically fixed module, spawns the initial children, and can explicitly pass their translation-known physical references. A DLL-like module loaded later has its own sealed typed ranges under its own owner and in its own arena. When `merge` encounters its `independent: const: immutable` branch, the consumer receives the original physical reference in the result and the module remains the owner. This does not make R0 global storage. This specification does not yet define that module's unload operation or the lifetime of those ranges.

`merge` and Message creation retain explicitly supplied references to admitted eternal branches and method records as terminals. Receiving one branch does not expose its retention Array, root settings or unrelated branches. Mutable state is still copied separately. Every reference within a published eternal branch must have sufficient lifetime; qualification does not make an arbitrary reference to reclaimable storage eternal.

For example, A and B constructed from A's template can have the same eternal E address and distinct mutable x cells. Finishing A and B does not release E. Equal contents of separately constructed branches do not imply automatic interning. Across processes a native address is not wire identity: an explicit codec is required.

<a id="messages"></a>
## 24. Message, actor and serial turn

A Message is an isolated graph with its own ownership. A plain template or letter is non-executable and may exist as a standalone minimal `LmxMsg`. An executable object is instead constructed as an L3 Thread from the beginning. Its `LmxMsg message` is the first member by value, so the Thread and its Message prefix have the same physical address. This common prefix supplies Message identity and operations only; it does not turn every Message into a Thread or put mail, scheduling, turn mode, or other Thread mechanisms into `LmxMsg`. A standalone Message cannot later be upgraded in place to a Thread. Exact address-range classification still distinguishes standalone Message storage from Thread storage: the generic Message kind admits both, whereas access to the Thread-only tail requires the exact Thread type. Receiving a letter does not automatically create a thread or actor. Launching a separate child requires an explicit operation.

Creating an `lmx_message` or `lmx_thread` places in its own arena only the data and physical references explicitly supplied by the creating operation. Parent state, bootstrap tables, method Arrays, eternal branches, and service references are neither copied nor inherited implicitly. An ordinary L3 Thread can retain and use everything available to R0 when those values are supplied explicitly.

An executing Message has FIFO mail and at most one active turn at a time. A turn consumes at most one admitted input. Different Messages may execute concurrently. An empty mailbox does not finish a background task: its mechanism keeps checking mail according to its execution mode until a stopping condition.

During a turn, one L3 Message executes on exactly one OS thread; transfer to another worker is allowed only between turns. An L3 Thread has no execution mode: each call's path is set by the callable occurrence's descriptor -- with a native address the call executes natively, without one the body (the graph's op tree) is executed by the interpreter; only L3 can be interpreted, L2 operations cannot. One call never runs both paths for one Message: the dispatcher does not retry a call through the other path after a failure and does not override the path set by the descriptor from the body or from a previous dispatch result. Choosing the path neither copies the method nor creates a second concurrent executor; the dispatcher never runs `implements` or other receiving expressions on its own.

One arena has one writing lane. A Message's handler, local management, scheduler and service state are mutated on its own lane. A foreign sender neither appends itself to the owner's ready list nor modifies its application data. Mail admission and designated single-cell control protocols belong to the Message mechanism and grant no general access to foreign memory.

A parent manages only its direct children. Sole membership of those children is a List (`KIND_LIST`) of physical references in the parent's graph, and the parent's scheduler traverses that exact List. A family-record chain, manager membership queue, fixed group of slots, or any other parallel child registry is forbidden. Local traversal-order policy belongs to the parent but does not become a second membership source. Each child likewise manages its own children. There is no separate global language scheduler, shared mutable Message registry, or global management lock. A router, if needed, is itself a Message with private state.

R0 is an ordinary L3 Thread in this tree and has no functions unavailable to another L3 Thread by default. Its parent frame represents the upper element of the future WorldWideMix and connects to R0 through the ordinary parent mechanism; this is Message supervision, not a lexical `node` link. Only the upper frame itself has no parent, but that grants it no additional functions. An external host watchdog, not the frame or R0, applies the overall subtree-close deadline and terminates the OS process if the ordinary cascade cannot reach a safe boundary. R0 has no special child Array, alternate scheduling scheme, or numeric identity.

An L3 Thread is a logical serial lane, not a promise of a dedicated OS thread. Both a dedicated thread and parent/platform-driven turns are possible. L2 implementation defines the API and mapping policy; this does not permit two simultaneous turns of one owner. Parent-liveness polling and self-maintenance are needed even by a childless actor.

The process's initial graph belongs to the root Message. Initial settings and user input arrive at entry; subsequent coordination uses Messages. Grouping Mix roles, cursors, pages and notifications into Messages remains a design choice: neither one actor for the whole document nor a separate actor for every cell is required.

<a id="addressing"></a>
<a id="delivery"></a>
## 25. Delivery, ownership and mutation order

The local intermediate organization level addresses participants by physical memory addresses within admitted Message-mechanism operations. Hierarchical index chains belong to [WorldWideMix](#worldwide), starting at the third organization scale, not to every local letter. Organization scale must not be confused with language profile L3. A native address is not serialized as a portable address on another machine.

Each L3 Thread owns its mailbox and mail API. A delivery service explicitly supplied by the parent resolves an address and delivers a letter to the destination mailbox's admission operation; it neither observes nor reads mailbox contents. The delivery service does not execute the recipient, schedule its turns, or maintain a child-membership registry.

Delivery of an existing non-executing Message can transfer its storage ownership to the receiver without moving data. Blocks and region classification join the receiver's single arena; the former owner no longer releases them. Lexical links remain unchanged; application attachment of the received root is explicit. Storage transfer is not copying and does not retain the sent object as a second independent owner.

Creating a new executing Message from a template uses [graph copying](#composition) and a separate arena. Ordinary settings are copied; admitted eternal references are retained. Creation does not implicitly import the parent's entire live context. Handing off supervision of a running child, transferring stopped storage and serializing a remote Message are three different contracts.

Concurrent arrivals have no predetermined relative order. Mailbox admission establishes FIFO order, preserved by consumption. Neither random shuffling nor sender-clock order is required. Empty-check/wait coordinates with admission: an accepted letter must not disappear as the receiver begins waiting. Capacity, backpressure and redelivery are explicit implementation/protocol policies.

Multiple senders mutate one object by sending its owner a complete operation. For example, `add(2)` and `add(5)` from initial 0 produce 7 in either admission order. Separate `read` and `write` requests are not one protected operation: two senders may both read 10 and write 11. Serial turns prevent overlapping execution but establish neither transaction rollback nor protection for a split protocol.

Delivery success means admission, not application of a requested change. A result requires protocol-defined reply correlation. The core does not automatically retain per-sender last identifiers or suppress duplicates. Deduplication, retry, batching and sorting requirements belong to explicit protocols without changing base FIFO.

Current-turn outgoing letters are staged separately from the published queue. A successful boundary publishes them in staging order; failure discards unpublished staging. This does not undo graph mutations already performed. The [collection boundary](#memory) follows outcome and temporary-root processing.

<a id="lifecycle"></a>
## 26. Completion, children and retained failure state

An executing Message's `success` is set only by user code: the system never resets it to 0, not even on failure, and never sets it to 1 itself; `success = 1` is a sufficient condition for stopping the Thread at end turn. The system sets `success = 1` only for a plain letter, at its delivery. An empty mailbox is not success. Once `success` is set, the Message's main algorithm receives no next turn; finishing local child maintenance depends on implementation. `running = 0` during execution may be a stop request: physical storage-handoff safety is established by a separate protocol, not inferred from one flag.

A child checks parent liveness and begins its own orderly close after sustained lack of response. Forced closure from above is the second, emergency path. A parent services physical addressees from the sole graph List (`KIND_LIST`) of its direct children rather than arbitrarily managing grandchildren. Each child repeats the cascade for its own List; closing propagates through the family instead of retaining a released branch forever.

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

<a id="mix"></a>
## 28. Mix: active marks and intervals

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
## 29. WorldWideMix: addresses, cells and navigation

WorldWideMix defines a placement tree: where a cell is situated. The LMX graph defines a value: its fields and what an expression consumes. These trees meet in a cell but are not identical: address `3.17.4` is not field path `file\close`, and `implements` does not number Mix neighbours.

An address is a sequence of nonnegative integers from root to cell. Neither an individual branch's depth nor index magnitude has a language-defined finite ceiling; implementations must check actual resource limits rather than overflow their representation. Leading textual zeros do not change meaning: `03.17` equals `3.17`. A prefix addresses a subtree; shortening the path reaches an ancestor.

The numbers count neighbouring positions, not bytes. A cell may hold a word, buffer or value reference. Varints, mixed-width fields and other codecs store the same integers rather than defining different address types. Changing storage from 5 to 12 bits does not rename `3.17`. Examples of tens of RAM neighbours and larger disk-sector occupancy illustrate carriers, not address-model limits.

Branches may have different depths. For prefix P, `bunch(P)` contains only occupied direct indices. If `{0,4,5}` are occupied, `P.4` is followed by `P.5` and preceded by `P.0`. `next`/`prev` neither descend, ascend nor traverse every document worldwide. `down`/`up` change depth; `next`/`prev` change the last index within one bunch.

A cursor is a path plus a buffer-cell position when needed. Insertion/deletion affects the relevant sibling level rather than readdressing every subsequent file byte. A document is a root, placement tree and mark overlay; a file is one way to serialize pages. Human names, realms, volumes and chapters are attributes/profile conventions, not DNS or a fixed number of levels.

Carriers can be RAM, disk, wire, radio or removable storage; Internet and HTTP are optional. A Message may carry a short address, authority and consumer information instead of an entire large body. The consumer reads needed parts by cursor. Content typing follows the LMX value and [admission](#admission), not its Mix address, MIME or filename extension.

Sorting services are placed outside an individual application, at WorldWideMix nodes corresponding to the placement tree and the routes between its parts. They may accumulate, batch and distribute letters by destination where carrier latency makes that processing useful. This is not a second local-mail circuit and is not a mandatory intermediary between L3 Threads in one process: the local mail collection retains its base FIFO contract. A sorter's buffer capacity, overflow policy and direct-send policy belong to a particular transport profile rather than to L3 semantics.

The Mix overlay places intersecting marks, cursors, attributes and intervals on the same positions. Page-value composition uses ordinary [merge](#composition) with first `[0]` occurrence, not neighbour-address overriding. Disk exhaustion does not authorize automatically spilling data to an arbitrary neighbour: refusal, compaction or an explicitly authorized mirror belongs to storage policy.

<a id="mix-coordination"></a>
## 30. Prefix coordination and mirrors

Mutable Mix state belongs to a Message. A change request addresses its owner and executes in that owner's serial turn. Concurrent senders to one owner need only FIFO; concurrency alone does not require an extra lock-grant step.

Logical prefix exclusion is a separately selected Message protocol, not a native cross-machine mutex or mandatory part of every operation. Reserving P covers all of subtree P, including deeper bunches. A common-prefix coordinator reconciles affected owners but neither writes directly into their arenas nor arbitrarily schedules descendants.

A reservation on `34.3.7` leaves independent `34.3.1` work alone; one on `34.3` must account for conflicts in both branches. The protocol must define when exclusion takes effect, treatment of already admitted commands and protection against late commands under revoked grants. Authority to request a change and a current reservation are different facts. A coordinator record alone does not enforce every write path.

Prefix exclusion implies neither distributed transaction, common rollback nor physically simultaneous mutation. An effective time T requires rules for clock uncertainty, lateness, nondelivery and partial failure. A timeout does not prove the former participant stopped. Grant/token formats, generations, retries and recovery remain explicit protocol choices, not implicit obligations of every Message.

A mirror is another prefix with corresponding content for a particular consumer, not a new fundamental document kind. Writes go to the primary owner; changes reach the mirror as Messages. A reader may tolerate lag; writing through a stale mirror is not automatically safe. A mirror's name is an attribute, while its address is its own path.

Equivalence of primary and mirrored values is relative to the receiving expression's used tree and tests. It does not mean perpetual byte equality. A last-wins projection is permitted for a selected renderer but does not destroy the complete occurrence chain. History and undo may consume Mix changes; a new whole-document version on every edit is not a core rule.

<a id="transport"></a>
## 31. HTTP and service boundaries

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
## 32. Authentication, authority and evidence

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

<a id="crypto-values"></a>
## 33. Cryptographic values and providers

L3 expresses cryptographic intent, key relationships, policy and protocol state. A provider implements primitives, secure storage and platform interfaces. The names below denote semantic contract roles; a concrete profile binds them to receivers and a type structure. Providers are explicitly selected by profile, reference, capability, configuration or service.

AlgorithmId contains family, algorithm, version/profile and relevant parameters. Parameters affecting interoperable protocol bytes are explicit or fixed by a named profile. Algorithm substitution and silent downgrade are prohibited. Missing statically required providers fail build/link; unsupported dynamic selection fails explicitly at the operation.

PublicKey is ordinary non-secret data with algorithm, format and key bytes, optionally id/metadata. It may be copied, stored and transmitted. Raw, SPKI, JWK and other encodings are explicit choices; a provider's internal object is not a wire format.

KeyRef is an opaque secret-key capability with a contract covering owning provider, operations, lifetime and export. It is neither a raw L2 address nor necessarily an Array of secret bytes. KeyPair combines PublicKey and private KeyRef. Generation does not automatically publish private material into the graph; non-extractable keys are valid implementations.

A Verifier explicitly identifies algorithm, format/version, salt and verification parameters: memory cost, time/iteration cost, parallelism and result or canonical encoding. KeyPolicy may define uses, expiry, rotation, revocation, versions, object association, export and recipients; the selected profile defines its exact Structure.

Passing KeyRef, returning it, storing it in a field, composition and provider changes do not export the secret. Its contract defines local multi-Message use, retain/transfer and serializability. The portable default is provider/runtime locality without wire serialization. Sending a secret to another machine requires explicit permitted export/import or a protected envelope.

Secure memory is a set of distinct capabilities: controlled secret storage, erasure, page locking, guard pages, non-extractability and hardware protection. One does not imply the others. Erasing copies outside provider control in UI, VM or host cannot be promised. Direct calls, service Messages and asynchronous adapters may implement one contract without introducing a new common scheduler or an already defined language `await`.

<a id="crypto-operations"></a>
## 34. Cryptographic operation contracts

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
