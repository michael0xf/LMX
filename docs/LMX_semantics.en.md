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

<a id="values"></a>
## 2. Values, Structures and Arrays

A Structure is an ordered collection of direct fields. Fields hold references to values: primitive cells, other Structures, Arrays and method records. Lexical nesting forms a forest; additional references connect it into a graph containing shared objects and cycles. A primitive cell does not acquire a Structure wrapper merely because a field references it.

An Array contains elements of one type. Its length counts Array elements, while a Structure's field count counts its direct fields. An Array of references to Arrays differs from a rectangular multidimensional Array. Nesting `a: b: c: d: ...` is the general form of receiving-expression application and has no fixed depth limit. `[]: []:` applies the ordinary Array receiver through that general form; it is not a separate construct or a special array-of-arrays type. An Array element may be a primitive or a reference to a nonprimitive value under the ordinary storage rules; each independent Array has its own descriptor and length. The C-like head `[][][]` denotes a flat rectangular multidimensional Array and is unrelated to composing separate `[]:` receivers. Dimensionality is not recovered from the descriptor. An intermediate Array can be bound to a name through ordinary typed binding: for `[]: []: []: a`, the steps `[]: []: b a[i]` and `[]: c: b[j]` each index one independent Array without copying a nonprimitive value. Direct access through multiple descriptors uses the ordinary path `a[i]\[j]\[k]` ([paths](#fields)), not adjacent indices of a flat Array. For example, `char: []: []: mainArgs` uses the same general nesting for an Array of strings: each string is an independent `char` Array of exact length `len` without a trailing NUL (`LmxCharArray`, [L2 §5](L2_spec_en.md#method-array)); NUL belongs to the `c.*` door representation, not the graph value. Representation and address-range cell classification are specified in [L2](L2_spec_en.md#type-by-range).

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
## 4. Names and paths

Names resolve source-level accesses; execution follows the resulting references and positions. Source-entity names are not stored anywhere in the graph: not on atoms, Structures, fields, methods or applications. A separate address-to-source-name table reconstructs names for source output and inspection; it is not a variable-binding table, a type or an execution identifier. It serves translation and `toLmx` only; execution never consults it, under any conditions: construction, copying and calls, including the formation of a call's inputs, follow the references, addresses and positions resolved at translation. Anonymous and positional values need no synthetic names. Physical tree storage is defined in [L2 §2.1](L2_spec_en.md#interpretable-tree); source reconstruction is defined by the [toLmx contract](#source-codec).

A structural path `object\field\nested` selects graph fields in sequence. Each step's presence and validity are determined by the selected object. A computed path is not replaced by an invented statically known name. Reserved `node` denotes the lexical space above the method and stays fixed throughout that method activation; `node\field` starts explicit traversal in that space. A bare `field` obtained by lexical fallback is supplied as a hidden argument of the current activation and is not identical to the explicit `node\field` path.

A path may contain an unnamed index step `a\[i]` selecting a typed Array element. `a[i][j]` addresses a rectangular multidimensional Array, whereas `a[i]\[j]` indexes a separate Array obtained through the value of `a[i]`; `a[i]\[j]\[k]` follows further references. Index steps may be mixed with Structure fields to any finite depth. A named occurrence selector such as `node\[N]field` does not exist: a structural level has no repeated declarations of one name.

`node` is a reserved language word. It cannot be declared, shadowed, rebound or dynamically supplied as a same-named value, including by quoted identifier spelling. In lowering it is literally the mandatory first `Lmx *node` parameter (`@: Lmx node` in L1): the physical reference to the lexical space above the selected method. No wrapper, closure or namespace object is inserted between source `node` and that address. In the working graph every callable occurrence, `if` body, loop and other nested Structure separately holds an ordinary `parent` link to its immediately enclosing Structure. For a callable occurrence that link supplies the above-method space passed as `node`; nested bodies may have an arbitrary internal `parent` chain, but that chain never rebinds the activation's `node` parameter. `parent` is neither a reserved language word nor a program-visible alias: it is an implementation field traversed by lexical and dynamic visibility. A bare `field` supplied as a hidden argument is local with respect to the caller and the above-method space. Assigning that name (`field: value`) updates this local value and creates no field, neither during execution nor by the translator preallocating one; nothing is written into the hidden argument's source, and no method state arises from it ([working state](#dynamic)). A field exists only where a declaration puts it; a declared own field goes through the working copy and publication. Mutating the above-method graph requires explicit `node\field: value`.

| Name | Where it exists | Meaning |
| --- | --- | --- |
| `node` | reserved L3 word and first method ABI parameter | space above the method; fixed for the whole activation, including nested bodies |
| `parent` | ordinary field of every working-graph `Lmx` Structure | immediately enclosing Structure; differs for a method, `if`, loop and other nested bodies |
| `self` | hidden ABI context only | the active Structure of this call; not a language word |

One immediately enclosing Structure has one namespace: a second declaration of the same name is forbidden regardless of field kind. A declaration in a nested Structure may shadow an outer one. Assigning to an existing field updates its cell but creates no second occurrence; the written operation remains at its source-graph position. `merge` of fields with the same name in different operands writes into the model's slot under the [composition rule](#composition), rather than declaring a duplicate field. A named path selects the sole field at that level, including through an [admitted reference](#admission); its physical position may differ between model and candidate.

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

A converter is an explicitly selected receiving expression. Its key comes from explicit descriptions and their composition; there is no hidden search over pairs. Analytical checking does not run the converter; an action requiring conversion performs the selected call. Redeclaring a key in one Structure is forbidden; composition writes a later operand's same-name key into the model's slot. If a table has several rows with one key, the table operation's own policy selects the row ([tables](#registries)).

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

The single candidate-admission mechanism consists of analytical tree-based `implements` for the receiving expression and execution of that expression's unit tests by the graph interpreter. Arena address classification supports value representation; it is not alternative validation. A matching signature, an attached explicit description or a positive analytical answer does not replace execution of the required tests.

<a id="analytical-tree"></a>
### Analytical stage

<a id="three-argument-implements"></a>
#### `implements(aVar, bVar, Consumer)`

`aVar` is the proposed candidate, `bVar` is the exemplar of the required role, and `Consumer` is the concrete receiving expression for which substitution is checked. The predicate is directional: it answers whether `aVar` may be supplied in place of `bVar` to this particular Consumer. It is not nominal type membership, equality of whole Structures, or a promise of suitability for another or every future consumer. If Consumer is not supplied, the candidate's full structural suitability is checked against the requirements of `bVar`, not an empty use set. The formula below describes checking with a supplied Consumer.

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

For each explicitly invoked field, the Consumer checks its presence and admissibility of the calls actually written: actual arguments, including named ones, must fit the candidate's accepted interface; inputs formed after defaults and available conversions must satisfy the selected implementation's actual descriptor (names, order, passing modes, and ABI), and results and declared exits must meet the Consumer's requirement. A formal with a default remains in the interface and may be supplied explicitly. Equality of original signatures or implementation addresses is not required. Opaque transport of a callable does not check unwritten future calls. Merely passing, reading, storing, or returning a primitive leaf is thin consumption; following fields of its description adds their requirements. An adjacent [example](LMX_semantics_guide.en.md#callable-admission) illustrates the distinction.

Unused fields and methods of `bVar`, values behind unused names, the order of differently named fields, unused nested contents, ownership, mutability, effects, and target-language layout are not compared. Empty `uses(Consumer, bVar)` means only that the analytical stage has no structural requirements. An unknown computed path is reported separately as outside analytical coverage.

For a Consumer that explicitly calls a field like `Object getObject()`, this stage establishes the presence of that field and that its callable interface admits the written call and expected result. It does not predict, follow, or qualify the particular object that a later execution will return. Behavioral checks are the receiving expression's explicitly written tests, not checks invented by `implements` or rerun after every mutation.

The analytical predicate itself executes none of `aVar`, `bVar`, Consumer, callable methods, or converters, and it does not rank the candidates that pass. A positive result is only the first mandatory stage. Final admission of `aVar` additionally requires the graph interpreter to execute successfully **all** unit tests defined by this Consumer against the already constructed graph; absence of a test set is not successful runtime validation. Execution receives physical references to the candidate and checking expression; source text and runtime names are not validation inputs. A negative analytical result means that admission fails.

Checking is not replaced by matching physical field positions. Reordering differently named fields while preserving paths does not change the result.

Admitting a value to a named model establishes a **physical-field correspondence**: each used model field maps to a candidate field, possibly at another position. Reading, writing and taking an address through the admitted reference follow that correspondence. It carries an admission already made; it neither copies the value, creates another Structure nor looks up names at runtime. Analytical checking of required accesses and explicitly provided checks of the receiving expression decide admission; the address map only directs later accesses ([L2 §14](L2_spec_en.md#implements), [L1 §15](L1_spec_en.md#implements)).

Collection of `uses` does not expand every callee, execute computed names, or perform whole-heap alias and dataflow analysis.

<a id="correspondence-stability"></a>
#### Preservation of established correspondence

An established `implements` correspondence persists: changes to the candidate's or checking expression's values neither invalidate it nor require its reconstruction. The graph's structure cannot change so as to break admission already passed: every branch assignment first checks through `implements` that the alternative branch fits the receiving place, then stores it; refusal preserves the previous value. That check covers the supplied Consumer's used requirements or full structural suitability in its absence, as defined above. A new candidate or different receiving requirements need their own admission, but this is not mutation-triggered invalidation of an established correspondence.

<a id="argument-compatibility-stage"></a>
Compatibility of actual arguments with the signature is established during translation when the callable and argument types are known. If the necessary information becomes available only through dynamic selection, compatibility is established at ordinary admission of the selected callable or supplied value to this call's requirements. Established compatibility is reused; changing a primitive value does not change its type or require repeating the check.

Analysis or admission being performed by a running interpreter does not imply checking on every execution of the resulting compiled code. An already checked compiled call under unchanged requirements does not require another type check at each argument transfer. This rule introduces no checks on every primitive change, read, or other use and does not replace the receiving expression's separately specified mandatory tests.

Executing the selected [converter](#descriptions), including its specified checks of the particular value, is a separate action, not repeated signature compatibility checking. Analytical admission neither executes the converter nor cancels its contract.

Diagnostics distinguish thin consumption from inability to establish required paths. They may show the field selected after composition, unused description fields and unresolved requirements; there is no separate global strict mode.

An executed call must receive every input required by the selected expression. A passed directed check makes the call admissible but does not prove equal implementation behavior.

<a id="graph-tests"></a>
### Test execution

The interpreter receives an already constructed graph of executable Structures and links. Parsing source text precedes this stage and does not serve as interpretation. The receiving expression defines unit tests for the interpreter to execute against the candidate. These tests provide substantive runtime validation: a field named `range` or `unit` does not by its presence prove that the stated constraint holds.

Execution of mandatory unit tests is an admission stage, not a handler for every graph change. Changing values does not automatically rerun all tests; structural correspondence persists under the [rule above](#correspondence-stability).

Ordinary values may store test results when the program explicitly does so. A result refers to the candidate, Consumer, and test set for which it was obtained; storing it introduces neither mutation tracking nor rechecking after every store.

A statically established violation is reported during analysis. Failure of any mandatory unit test makes `admitted(aVar, bVar, Consumer)` false; declared failures follow the [exception rules](#exceptions). Neither validation nor memory reclamation rolls back already published messages or external effects.

<a id="test-receiver-contract"></a>
#### The test receiver: associating a receiving place with a check

The test receiver is available inside any Structure and explicitly associates a receiving place with an ordinary checking expression. It specifies checks for the admission stage rather than executing them during ordinary body traversal, and creates neither global registration nor a hidden test environment. The name test is reserved and unshadowable under the general single-namespace rule; ordinary user methods and bindings use another name, such as mytest.

##### Association and ownership

Spelling:

```text
test: op checkIncrement
```

op describes the receiving place checked for a particular Consumer; checkIncrement is an ordinary LMX checking expression. The instruction's arguments describe the place and refer to the checker; they are not implicit nullary invocations of those names. The complete head/arguments model is formed first, then the ordinary receiver contract applies. Availability is not restricted by a Structure's kind, name or nesting.

The association belongs to the receiving Structure: candidate-owned tests do not replace unit_tests(Consumer). A nested Consumer owns its associations; tests in every nested method must not be recursively promoted into requirements of the outer Consumer. A checking function can be explicitly reused. Multiple applications test: op checkZero, test: op checkPositive, test: op checkNegative specify multiple mandatory checks, not repeated field declarations reduced to the last occurrence.

##### Ordinary checking code

Example:

```text
fn: applyStep (op(fn: (int: x) int); int: value) int
    fn: checkIncrement (candidate(fn: (int: x) int)) int
        return: (candidate(0) = 1) && (candidate(5) = 6)
    end: checkIncrement
    test: op checkIncrement
    return: op(value)
end: applyStep
```

At admission the actual candidate for op, not the exemplar or a same-name function, is passed to checkIncrement as an ordinary argument. The callable formal receives the complete callable occurrence under its ordinary signature. Nonprimitives travel by their ordinary held reference; adding @candidate merely "to pass a reference" changes indirection depth. The main Consumer body uses op(value) after admission completes.

The checking definition may appear directly in the instruction's arguments without a test-specific language or special mixed-form parser. A fully vertical spelling of the same association:

```text
test:
    op
    fn: checkIncrement (candidate(fn: (int: x) int)) int
        return: (candidate(0) = 1) && (candidate(5) = 6)
    end: checkIncrement
end: test
```

Data preparation, calls, comparisons, branches and failure handling remain ordinary LMX code. No separate suite, case, fixture, expect, beforeEach, fundamental TestResult, or hidden test-state object is needed.

##### Results, failures and the admission stage

Checker result: ordinary int, 1 for success and 0 for failure. A suitable logical description may be explicitly provided by a profile. Ordinary return: candidate(5) = 6 is not assert: a false assertion retains [its diagnostic consequences](LMX_semantics.en.md#exceptions), rather than becoming an ordinary negative result only inside tests.

An expected failure is checked using ordinary catch inside the checking expression: catching the expected failure returns success; its absence returns failure. An arbitrary throw is not automatically a successful negative test. Uncaught failures and diagnostic violations retain the general rules; the precise failure representation for the whole test set remains an open decision.

Sequence: analytical suitability of the main use and necessary test accesses → preparation of the ordinary checker call with the actual candidate → execution of checks → success of all mandatory checks → completed admission → ordinary use. The analytical predicate itself executes neither tests nor converters. There is no temporary replacement of a live Consumer field followed by restoration.

The checker also consumes the candidate and needs ordinary analytical suitability for its own accesses. If the body calls op(1) but a test calls op(1; y: 25), the candidate must admit the explicitly supplied y for that use too. The test gains no right to require every unused exemplar field and is not exempt from typing.

##### Graph, execution and no hidden registration

The full source graph retains the written association: receiving place and checking expression. The resolved place reference identifies the receiving-input description, not a guessed address of a future machine argument; the actual candidate is supplied to the checker's ordinary activation at admission. It creates no new base Lmx fields, extra graph, variable passport, test catalogue, or TestEnvironment. Names resolve during translation; runtime uses physical references rather than searching for text "test" or consulting the name table.

The checking body remains an ordinary graph part available to toLmx, copying and composition. Its full representation and source order are not replaced by a comment "tests were here" or a separate service copy. Ordinary Consumer execution neither registers associations again nor reruns the tests.

The admission executor traverses the explicitly given graph scenario; checker and candidate calls follow ordinary dispatch according to native. It must not obligatorily clear native, damage the selected implementation, or introduce an exception "inside tests always walk." A developer test runner receives an explicit root and does not change the receiver's meaning.

Test-state preparation is explicit. Any needed copy is made by ordinary merge; test resources or a separate Message are explicitly created or supplied. There is no hidden cloning or rollback of messages or external effects. A report may be an ordinary Structure holding references to Consumer, place, candidate, check and result; this is an output, not a mandatory hidden object attached to every value.

A successful comparison describes the value when the test ran, not every future value. It establishes no everlasting numerical invariant, mutation monitor, or automatic all-tests rerun. If an operation checks the current value under its explicitly defined contract, that is the operation's action, not repeated checking of established [signature compatibility](LMX_semantics.en.md#argument-compatibility-stage).

##### Full validation without an explicit Consumer

Without an explicit Consumer, full validation uses checks explicitly specified by the receiving description bVar, not tests of the candidate aVar. Analytical implements without Consumer still checks full structural suitability relative to bVar; the source of behavioral checks does not replace that analytical scope. Absence of the mandatory set does not become successful validation.

##### Completing admission already in progress

Executing a check completes admission already in progress rather than starting that same admission again. Analytical suitability of the necessary checking accesses is established before execution; a successful behavioral result exists only after the check completes. Already checked operations remain checked; new dependencies require their own checks. A cycle of unfinished checks is not success; a global typing-disabled mode and hidden skip_tests are forbidden. This is the ordering of one admission mechanism, not an exception for test calls.

<a id="admission-recipes"></a>
## 8. Obtaining a required guarantee: fourteen practical cases

Most questions about guarantees reduce to a practical choice: where must a distinction be placed so that the required property is actually checked? A guarantee does not arise from a global strict mode; it arises from the part of a Structure that Consumer must traverse and from the tests defined by the receiving expression. Just as a C `typedef` merely names an alias while a wrapping `struct` creates a separately enforced boundary, LMX relies on the expressed path and its consumption contract.

The following fourteen cases are recipes: what to express, what that expression does not establish, and where the governing rule lives. They apply the [single admission mechanism](#admission): its analytical stage checks used paths, then the graph interpreter must execute the receiving expression's unit tests.

<a id="admission-case-1"></a>
### 1. One receiving expression for multiple data shapes

Write the receiving expression against the paths it actually needs. Any Structure providing those paths, admitted leaves and actually invoked expressions that pass the directed check of [§7](#admission) can qualify. Structures are ordinary data, material for explicit descriptions and results of composition, so the used tree is the contract. There is no separate generic type-parameter declaration or instantiation operation. Used-tree checking is LMX's structural-generalization mechanism, not a promise of every property of parametric polymorphism.

<a id="admission-case-2"></a>
### 2. Knowing what a particular site checks

Consumer determines analytical coverage; unknown coverage is distinguished from known thin consumption. Analysis is followed by the graph interpreter executing that same receiving expression's user-written unit tests. Every actual call must additionally receive all inputs required by its signature. These stages do not subsume one another: they have different inputs and coverage. Admission covers this Consumer's established uses. Ordinary changes of candidate or Consumer values neither invalidate the established correspondence nor rerun tests. A replacement branch admits its new candidate before storage; a different Consumer or a new use requirement needs its own admission.

<a id="admission-case-3"></a>
### 3. Distinguishing meanings with the same representation

Encode the distinction in a path the receiving expression actually uses. With `Distance: Meter: 1`, access through `d\Meter` requires that path; a Structure exposing only `Foot` does not provide it. An outer name `Meter`, a field `unit: "meter"` or `const` alone is insufficient: path presence does not compare the value at its leaf. `implements` does not infer semantic equality; user-written receiving-expression tests check the substantive constraint.

<a id="admission-case-4"></a>
### 4. Constraining a scalar leaf

State the constraint explicitly and include it in the receiving expression's user-written tests. Presence of `x\width` does not establish `width = 32`: traversing a description requires its used paths, but a terminal scalar may remain thinly consumed. `implements` does not compare that leaf's semantic value.

<a id="admission-case-5"></a>
### 5. Making a change visible to other reference holders

To make a change visible to other holders, write through an explicit path to the shared value, such as `p\x: value` or `a[i]: value`. Assigning an existing reference updates its selected cell after admission without creating a second field. `@: b A` with a new `b` declares and initializes a reference; unary `@x` addresses storage of an already selected value. Assignment to an argument changes only an activation-local value; a declared own-field is published under [§12](#dynamic).

<a id="admission-case-6"></a>
### 6. Independence from another holder's mutation

`copy:` creates an independent mutable value only within its copying contract; genuine immutability prohibits mutation of the protected value. Ordinary Structure or Array passing copies the reference, not the referent. Another alias within the Message can therefore change the shared mutable object. An immutable foreign-resource identifier does not make the foreign resource immutable.

<a id="admission-case-7"></a>
### 7. Establishing that a call can proceed

Both conditions must hold: compatibility covers used paths and the directed check of the callable against its use ([§7](#admission)), and every dynamic input must be available from caller locals, inherited inputs or that callable occurrence's immediate `node\x`. Suppose A and B expose the same `m`, whose body uses bare `x`, while Consumer only invokes `m`: the used-callable check can pass while call admission still rejects a missing `x`. A known case is rejected during translation; a runtime-selected target requires the corresponding runtime boundary. This rule does not add callee-body expansion to `uses`.

<a id="admission-case-8"></a>
### 8. Checking a transported callable

Transporting a callable neither executes it nor requires knowledge of every future call contract. Checking occurs at the actual call: the selected expression must pass the directed check of [§7](#admission) after ordinary input formation (optional formals are prepared with their default values), receive every dynamic input and satisfy applicable admission, even if an earlier partial check never inspected it. A passed check does not imply equal behavior.

<a id="admission-case-9"></a>
### 9. Changing a method body without breaking calls

The body's free dynamic names are part of its interface. A formal with a provided default value is not a free name: it is not in `DynRequired` and remains part of the accepted interface. Adding a new free dynamic name to the body changes `DynRequired` and the corresponding call requirements; known callers require rechecking, while runtime-selected callables remain subject to actual-call admission. An immutable method record neither makes every occurrence referring to it immutable nor prohibits explicit replacement of a reference with a compatible callable. Behavioral change under the same signature remains a matter for tests and program correctness.

<a id="admission-case-10"></a>
### 10. Selecting the intended part of a composition

Select the field explicitly or construct the intended fields. `merge` builds a new tree and does not mutate its operands; a later operand's same-name field overrides the model's slot in place (specialization), and no new occurrence of that name arises. If model A has `read` and B has a `read` of a compatible type, `result\read` is A's slot holding B's value; a `read` with no counterpart in the model is appended at the end. Analytical diagnostics may expose an unintended unqualified selection after an import or composition changes. Source parts need not be adjacent or statically available.

<a id="admission-case-11"></a>
### 11. Changing an existing Structure

Field count and slots are fixed. Ordinary field operations may replace the `void *` child references stored in existing fields; a change in the target's actual type follows the ordinary rules for such updates and later consumption. A different field count requires a new Structure, such as a `merge` result. No conflict policy is introduced for nonexistent operations that remove or move an active field.

<a id="admission-case-12"></a>
### 12. Reliable numeric conversion

Use an available explicitly keyed converter with a destination-range contract: `u16(255) → u8` is admitted, while `u16(256) → u8` is a range error, not zero. In-range rounding and precision loss are a separate numeric-profile policy. Successful analytical checking does not permit silent modular wrapping. A converter's refusal at the edge is an ordinary receiver refusal; it leaves as the implicit named failure of that edge (`convert`) in the method that owns the edge: the caller does not declare the converter's own names (for example `range`), a `catch: convert ()` handler handles such a refusal like any implicit one, and an uncaught one flies to the root of the executing Message.

<a id="admission-case-13"></a>
### 13. What a broad converter table provides

Additional explicit keys widen only the available leaf conversions. They do not alter required structural paths or exact callable signatures, and a profile need not provide every pair. Neither analytical checking nor path-selection tests execute a converter or search for a hidden conversion chain.

<a id="admission-case-14"></a>
### 14. Foreign-resource validity

A foreign handle requires a checked high-level wrapper and explicit resource and cleanup contracts. A thin `FILE`-like leaf does not establish validity, authority or single close. The receiving expression's unit tests check declared properties within their contract; immutable handle bits do not keep a resource alive. L3 has no ordinary machine-level `own:`/`borrow:`/`move:`, and `copy:` does not invent a foreign resource's duplication policy.

<a id="construction"></a>
## 9. Value construction

Source notation constructs the complete Structure graph: values, declarations and executable expressions remain in the same graph. Constructing a body description does not execute that body. A named Structure is not executed on declaration; an anonymous body in execution position runs under its receiving expression's contract. No separate data graph, hidden wrapper procedure or persistent auxiliary context is created. The declaration site determines the lexical parent; an independent root has none (parent = 0). The binary representation retains comment text; names remain available through the table described under [name rules](#fields). Comments and the name table do not replace resolved references or participate in dispatch.

### Head resolution and the role of the tail

A receiver is an instruction to the translator; a callable call is a runtime action. They share the Frame syntax "the head consumes the tail", not a semantic role. General resolution and the receiving head's contract determine the head's role and the meaning of its arguments. A name in a receiver's arguments does not thereby become another call: `catch: merge ()` supplies catch with the failure name and parameter description, just as `fn: mytest ()` supplies fn with the name and signature description. These are consequences of the common rule, not exceptions for those receivers or names.

<a id="resolved-head-consumption"></a>
#### One model, one resolution, one consumption

First, the complete written structural head/arguments model is formed in translator memory, without knowing what the head denotes. Neither its name, signature, nor entity category determines that model's boundaries or permits collecting additional arguments. Only after the model has been formed does the common resolution algorithm in the single namespace determine the head's role: receiver, callable, assignment value, or Structure definition. One common consumption mechanism applies the resolved entity's contract; differing contracts do not create separate parsers, namespaces, or resolution routes.

In evaluation position, a bare identifier enters that same flow. A resolved callable is invoked without arguments; a resolved receiver receives an empty argument list and checks it under its ordinary contract. If the contract requires arguments, their absence is diagnosed at the source occurrence; a known entity does not become a free variable or hidden input. Bare `merge` and `int` follow this same rule, not separate handlers. A non-callable value is read without invocation. Neighboring atoms are not captured. If the receiving contract requires a name or description rather than an evaluated expression, knowledge of the written name does not turn that position into a call.

Block, short and parenthesized spellings build the same head/tail model; after name resolution, the selected receiver, callable or value applies its contract. An ordinary named Structure executes through its bare name without arguments. An unknown head with a structural tail declares a Structure without executing its body; with a sole atom, `A: b` is a translation error regardless of whether `b` is known: an atom is not a structural body. When Structure `A` is known and `b` is absent, `A: b`, `b: A` and `@: b A` declare a reference `b` initially pointing to `A`; there is no implicit `merge`. An already known name resolves to an existing receiving place, not a reason to create another same-named field.

If `A` is a known ordinary Structure and `b` is absent, `A: b` and `@: b A` declare one reference cell `b` requiring `A` and initially holding that very `A` instance's address; `@: b A 0` instead supplies the null address, while `@: b A Other` receives `Other` after `implements(A, Other)`. If both names are already known, `A: b` attempts to assign `b`'s value to existing `A`; `b: A` attempts to assign `A`'s value to existing `b`. Neither is an ordinary-Structure call with arguments. Calls of `fn`/`fm`/`sub` methods are checked against their signatures. Receiver nesting does not turn an application chain into one argument list.

A structural tail such as `A: (int: x 1)` declares `A` in the current container. Empty `A()` and `A: ()` denote one empty declaration, while bare `A` executes an already selected ordinary Structure. A second declaration of any field name in the same container is forbidden; a nested declaration may shadow an outer one. An ordinary field is visible forward and down from its declaration, unlike the visibility rules for `fn`/`fm`/`sub` and `catch`. A path `Outer\Model()` or `Outer\Model: ()` addresses an existing field and attempts to assign it an empty Structure; it declares no new field. `Outer\Model` executes the selected Structure without arguments.

A nested head follows the same resolution algorithm in its own context. An outer receiver may consume an entire nested form as a description under its contract; defining the containing Structure does not execute its body. Parenthesized, short or block spelling alone does not change the selected role.

If put is already defined as callable, the following definition of Batch retains the structural body `(put: 7)` without executing it:

```text
fn: put (int: n) int
return: n
Batch: (put: 7)
```

This is an ordinary operator in the complete binary tree, not a separate “saved call” value, hidden closure or second graph. When execution of Batch reaches the put operator, the ordinary call rules apply. An available native implementation of Batch is selected; otherwise its retained body is walked in the admissible profile. Absence of a native implementation alone does not mean the tree is lost or unexecutable.

If both C and the nested name makeA are unknown, C: makeA() declares C with a named empty Structure makeA. Parentheses alone are not a call marker; the definition does not compute a makeA result.

```text
C: makeA()
```

`f()`, `f: ()` and an explicitly closed empty vertical form are equivalent. In definition position this is an empty Structure; redeclaring `f` at the same level is forbidden, while a nested declaration may shadow the outer one. If `f` was declared as `fn`/`fm`/`sub`, its empty application is a call with no actual arguments. A trailer and `return` do not themselves turn a declaration into a call. Unknown `A` in `A: b` does not infer a type from atom `b`: this is an immediate translation error, not a free name.

A later read does not retroactively change the role of an already written unknown head. In the following example, `f` has no formal, visible outer value or previously established free input `x`: `x: j` defines a named Structure rather than assigning a primitive. `return: x` does not provide the declared `int` result and is erroneous under the general result checking and conversion rule. A caller's same-named value does not change this classification.

```text
fn: f () int
    int: j 3
    x: j
    return: x
```

A free input is a free value used by a callable without being declared as its explicit formal; establishing it and selecting its source follow [§12](#dynamic). This term denotes neither an additional Structure, a separate context graph nor name lookup during execution.

### Explicit copying and reference variables

Explicit [merge](#composition) clones or composes existing Structures. In `b: merge: A C` or `b: merge(A C)` the operands are A and C and outer b receives the result; the destination name is not the first merge operand. This holds wherever b stands: at the root, in a method or in a named Structure's body (the body is a procedure's body, and b there is a row of that procedure, as in a method); b's role is decided by the resolution of its name, not by the word `merge` in the tail, which does not single b out among the other unknown names that accept a Structure. Application with operands uses an ordinary Frame under the [general grammar rule](LMX_grammar.en.md#no-inference): an atom `merge` does not capture subsequent fields as arguments, and `b: merge A C` does not spell that application. An unknown argument does not trigger implicit cloning. Formation of a returned nested callable with data from the finishing activation is governed separately by that composition section and is not removed by declaration rules.

The `@:` receiver declares a new reference field and may fill it with an admitted candidate ([§12](#dynamic)); in a signature the same form only describes an input, which a call may fill with another Structure after `implements`. A candidate name resolves to an address at translation, never by runtime name lookup. Applying an already stored pointer as `b: args` attempts assignment, whereas calling a method by its address requires `\b: args`. This does not change ordinary direct method calls or equate the `@:` receiver with unary `@b`, which addresses the reference cell.

Candidate conversion precedes implements against the Consumer's requirement; reference storage changes after admission succeeds. An ordinary Structure value already travels by reference. @A addresses its cell and is not conversion of a Structure to its ordinary reference: A and @A have different depths. Assigning a Structure name to a reference place reads the already held reference and uses the destination cell's address to store its new value; conceptual `Lmx *` values and `Lmx **` cell addresses do not become the same expression type merely because C lowering uses both. If the assignment itself requires conversion of a primitive pointer value, its direction, depth and admissibility are supplied by the ordinary Message-local primitive conversion context, not a special table of user-Structure pairs; an absent rule does not silently remove an `@` level. implements establishes the referent's suitability for a structural requirement; the physical Lmx range is common, not separate for each model.

### A signature is not executed

A signature describes inputs rather than executing its forms as a method body. For nonprimitive A, formals (A: b) and (@: A: b) describe the same reference transport with candidate admission to A. In mytest(c) an existing candidate passes implements(c, A, Consumer); its descriptor reference is passed without copying the nonprimitive value or performing implicit merge. Such a formal description does not execute `A: b`; separately, in an executable body, a known ordinary Structure `A` with a name-atom tail `b` declares a new reference occurrence `b` pointing to `A`.

```text
sub: mytest (A: b)
sub: mytest (@: A: b)
```

For structural c, mytest(c) and mytest(@c) have different depths: a Structure reference and a reference to the cell holding it. No extra level is removed to fit a formal. This applies equally to a Structure, a reference variable and a nonprimitive formal; the target is its own language storage, not a transport-ABI box. Primitive formals (int: b) and (@: int: b) are not synonyms. Passing and returning nonprimitives never use C by-value aggregates.

### Assignment and declaration sites

A second declaration of a name at the same structural level is forbidden; a nested declaration may shadow an outer one. After admission, assignment changes an already selected place without adding a field. Refusal preserves the old value and `dirty` state. Both declarations and assignment statements remain at their source positions in the complete graph.

An unknown head with a structural body declares an ordinary Structure, as in `Model: ()`. A lone atom after an unknown head, as in `Model: ptr`, is not a structural body and fails translation. If `Model` is already known as an ordinary Structure but `ptr` is still unknown, `Model: ptr` and `@: ptr Model` declare a new reference field `ptr` initialized with `Model`'s address. When both names are known, `Model: ptr` attempts to assign `ptr` to the `Model` place, while `ptr: Model` assigns `Model` to `ptr`; ordinary conversions and admission apply. A known method head follows its own call rule, not this Structure-declaration rule.

The name of a declared method and a pointer to it have different roles: `myFunc()` calls the method directly; `@: ptr myFunc` declares a pointer; `ptr()` = `ptr: ()` attempts to assign an empty Structure to it, just as `ptr: a` attempts to assign `a`. Only `\ptr()` calls the method through the pointer. Failed assignment admission does not reinterpret the statement as a call.

An explicit or hidden argument remains an activation-local value: assigning it does not write back to the caller. A declared own-field keeps its value at its place in the complete graph and is published under [§12](#dynamic). A signature declaration only describes a formal and does not execute as this operation.

<a id="qualification"></a>
## 10. const, immutable and independent

`const` protects a binding: it cannot be assigned, rebound or replaced. The value behind a protected reference may remain mutable. `immutable` protects the value itself for its entire life through every alias; a variable holding its reference may remain rebindable. `const: immutable` combines both guarantees. They are independent qualifications, not degrees of one scale.

Immutability applies to a primitive, a Structure and its selected tree, or an Array with its descriptor and elements. It covers every field and explicitly included descriptions, not just Consumer's paths. Passing, returning and storing an immutable value preserve its identity; qualification requires no copy, including for a primitive. It does not freeze a foreign resource denoted by an immutable identifier.

`immutable` gives a new value its supertype during construction, before publication: cells are allocated from pools of the corresponding immutable types. An ordinary Structure already built in the mutable-Structure pool is not retroactively converted; `immutable: Existing` on that value refuses at consumption. This supersedes the earlier promise that `RuntimeImmutable` would requalify an existing tree without changing its identity. An already immutable value can pass as a value of its type without requalification. Argument admission remains [unified](#admission), as for every receiving expression.

The whole selected tree is examined before the new immutable value is published. A contained Structure is a tree branch only when its ordinary structural `parent` field points to the parent being examined. An outside reference **already stored as a data value** is permitted only to an already immutable object; it is terminal, and its target is neither traversed nor requalified. The root's own `parent` is a structural lexical link to a node outside the selected tree, not such a stored reference: `immutable` without `independent` constructs the value under its ordinary parent, which it neither freezes nor requires to be immutable; `independent` is the one receiver that touches that link. An operand of stored executable code is not such a value before that code runs (see below). The pre-publication state is checked: processing an earlier field cannot justify an invalid outside data reference in a later field. If a source `immutable` declaration violates this condition, the translator refuses construction; even under interpretation the graph is built first, so this refusal is not an exception thrown by the executable body. If an executed operation on an already existing tree encounters an error, the interpreter uses the ordinary `throw` caught by the ordinary `catch`, with no special `immutable` channel. Neither case becomes an `assert`.

The check concerns values and references already stored in that tree. A known admitted Structure used as a reference declaration's candidate is stored in the cell at construction, even if the named Structure or method body is never called; declaration does not execute that body. An executable expression stored as code is not executed by qualification, and its possible future result is not a presently stored reference. In particular, a deferred read or call is not rejected merely because it could return a mutable object; its result is checked when it is actually received, assigned or otherwise consumed under the ordinary contract. An immutable Structure may therefore contain code that later reads mutable data without freezing those data. The representation may place code and data in the same graph; that does not turn an operation's address operand into the result of the operation.

Primitives and methods are leaves, not lexical-tree branches. This describes the `parent` topology, not an exemption for mutable storage physically retained by the qualified graph: a saved method's code record and already stored data must satisfy the immutable construction contract. Its deferred operands are code, not their possible future values, and cells of a later activation are not frozen by this check. An Array reference likewise establishes no `parent` branch: a tree operation does not implicitly freeze an outside Array's mutable backing. An immutable Array is constructed under its own contract. A cell's membership in a service pool does not permit traversal or qualification of the entire pool.

Construction of an immutable value completes only after successful full preflight. Failure leaves no partially published immutable tree or successful result; silently skipping a branch, copying an already existing ordinary object merely to change its type, or retargeting links is prohibited. An already immutable value needs no requalification. This rule does not roll back earlier initializers, argument evaluation or pre-call publication of working fields; it establishes no graph transaction.

Protection applies to writes through every path and to publication of working fields. When the `immutable` receiver consumes a Structure, it must establish that the saved body cannot write into the protected cells; a known-invalid write or inability to prove safety refuses **that consumption**, before call code is generated or executed, rather than at a later working-field publication. For example, a saved method `int: x 0; x: x + 1; return: x` writes a field of the graph being protected; consuming its containing Structure with `immutable` is refused. A write into a known immutable cell cannot be compiled. Dynamic write checks remain for external code addressing an already protected value; they do not replace proof when the saved body is consumed. Calling a method alone does not remove protection. Changing a local argument copy or rebinding a local reference does not modify the protected value. Constructing a new value, including through `merge`, does not thaw the source.

Construction-time `independent` sets the root's `parent = 0`; that is exactly the absence of an external lexical parent. Internal tree `parent` links and own fields remain. The qualification neither retroactively clears existing objects' `parent` links nor prohibits explicitly supplied references, current-caller dynamic arguments, Messages or selection of a callable by a compatible signature. It does not require purity or an interface closed over explicit arguments alone.

`const`, `immutable` and `independent` are receiving expressions; their composition establishes the result's qualified type. `immutable` is a supertype determined when the value is built. Each base type has storage for its corresponding immutable type; all immutable Structures, regardless of their field models, use a shared pool of that type, distinct from the ordinary Structure pool. Qualifying one Structure does not affect unrelated values; every alias of a constructed immutable value sees the same supertype by address. The common address-classification mechanism is described in [L2](L2_spec_en.md#type-by-range); this does not introduce a new type for every Structure model or a runtime name table. A zero root `parent` remains the structural consequence of `independent`, not a replacement for type classification. As receiving expressions they stand wherever a Structure value is received -- a declaration's tail, a method's `return:`, a `merge` operand -- composed in the order and part the source writes, each with its own contract; the root-level chain over a named Structure is one case of that reading, not its definition.

For example, a method inside independent Structure S can use S's field through its internal lexical link. Required `x` can come from the current caller. If `x` exists only in S's former textual surroundings, implicit external access is unavailable. An explicitly passed large Array neither shrinks nor gets copied because of `independent`. The special lifetime of the three qualifications together is described under [eternal branches](#eternal).

<a id="execution"></a>
<a id="callables"></a>
## 11. Callable expressions and their interfaces

<a id="declaration-visibility"></a>
Names of methods created by `fn`, `fm`, and `sub` are visible in both directions within their lexical block. An ordinary named Structure and a reference to a method are visible only forward and down from their declaration site; a nested declaration may shadow an outer one, but a duplicate at the same level is forbidden ([§4](#fields)). [Head resolution](#resolved-head-consumption) uses visibility at the current position. Parentheses, tail shape, and a trailer do not change it.

The files of a program form no categories of a main file and parts: a message is a Structure, and any file attached by any means is embedded into the program graph. Visibility of declarations across files follows the resulting graph and these same visibility rules -- forward and down from the declaration site, in both directions within their block for the callables `fn`, `fm`, `sub`; comparing positions in different documents does not define visibility.

A signature describes inputs and the result; it is not an executable body. A formal's spelling does not execute the call, declaration, or assignment that the same spelling might denote in a body. Synonymy between two descriptions in a signature concerns the parameter contract and does not extend to executable occurrences of those spellings. Supplying an actual argument performs the contract's conversions and admission, but does not execute the formal description as a body operator. Uses of the resulting parameter in the body are resolved by its contract and the general expression rules, not by executing the signature text.

An executable body is a structural expression; declaring a named Structure or method does not execute it. The bare name of an ordinary Structure executes it without arguments or result; parentheses are not used for that invocation. `fn` declares one result, `sub` returns no value, and `fm` returns one Structure with several named fields. A signature specifies arguments, result, and `throws` but does not itself execute.

Bare `return` exits without a value; `return: value` is admitted only where a result is declared. At the opening level, `return` may also be a trailer for any callable Structure under the general grammar rule; it is not a closer for a non-callable Structure. Explicit `end: Name` is optional, and reaching the end of a body without `return` does not synthesize a return node.

A path through a Structure reads a field without invoking it. A local declaration in an executable body resides in that same Structure and is visible forward and down; there is no separate “method data Structure” or second value field. The choice between reference declaration and assignment for `Model: Other` is defined in [§9](#construction).

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

<a id="publication"></a>
<a id="dynamic"></a>
## 12. Dynamic inputs and working state

Value storage at a declaration in the complete Structure, a working value of the current activation, an explicit formal argument and a dynamic input must be distinguished. They have distinct mutation rules; a working copy does not create a second persistent graph. Ordinary passing copies a mutable primitive's value and a Structure or Array's reference; the special identity of an immutable value is retained under [qualification](#qualification).

For a free name, the called expression receives the current value from the caller's available context; if unavailable, permitted lexical lookup follows `node`. Own declarations and formal parameters have their respective resolved locations rather than being searched in a global registry. Required through-names are part of the signature: adding a free name changes the interface. A missing required input makes the call inadmissible; silently creating zero or a new field is prohibited. A callable's formal is not a free name of its body: it receives the supplied argument or its default value ([§11](#callables)), and the source priority below does not extend to an omitted formal.

A free name's sources have this priority: the caller's nearest current local binding, then its already inherited dynamic input, then the callee's lexical lookup. A local binding includes a used own field, formal argument, result or another receiver-defined local value. Statically known call requirements propagate to a fixed point, including through mutual recursion. A name needed only by the next call must still be retained and forwarded; forwarding alone creates no graph field. It follows that a method which itself consumes the name forms its activation's value of it from these same sources, its own lexical lookup included, and that formed value belongs to its available context: what it calls receives it, whichever source gave it. A method that only forwards the name forms nothing: an entry that arrived absent travels on absent, and the eventual consumer uses its own lexical lookup. Assigning the name changes that activation's value only, and an explicit `node\x` read forms no binding.

For a name consumed by this activation, including in an explicit throw's payload, the selected value is held at activation entry, before its body's statements or own-field entry load can change the source. A later explicit path mutation of the source does not refresh the bare input. This also applies when the selected source is the callee's lexical fallback; a name merely forwarded to another call is not eagerly read or given a local value. A nested callable's definition is not an executed step of the enclosing activation: its free inputs are formed at its own call, not when the enclosing body is entered.

Lexical lookup follows real Structure links to a zero parent and selects the sole field of the required name at the relevant level ([names](#fields)). `independent` cuts the external lexical fallback. Explicit `node\x`, `reference\x` and `array[index]` address the graph rather than being replaced by a dynamic `x`; a context copied by `merge` participates only as fallback ([composition](#composition)).

An own field's working value is loaded for the activation from the graph: an own field of the current activation is a field of the callable occurrence itself, and assigning that name changes the working value and marks it `dirty`; a checkpoint publishes it. Loading or reading a value does not itself mark it `dirty`. The load happens at activation entry and only for the own fields the body actually uses through bare names (origin 21.5): an explicit path written after entry changes the graph cell, while the bare name keeps reading the entry value until its own write. An explicit reference write changes the selected object directly and is observable through other references to it. An explicit or hidden argument is a value of the machine activation: it never becomes a field -- a field exists only by declaration -- its assignment updates that local value, and there is no copy-back to the caller.

Assignment updates an already resolved binding. It does not create an additional data field, either during execution or by causing the translator to preallocate one. Computed initialization is two ordinary adjacent statements: `int: i` declares, `i: findValue` assigns the call's result under the normal call rules when control flow reaches that line; a computed expression is not secretly executed while building the graph, and merely inspecting the stored program does not execute the call. After execution the complete Structure still contains both the declaration and the assignment calling `findValue`: the assignment changes the variable's working value, not the call, its operands or the instruction itself; a checkpoint writes a changed value only to its value storage, never into an initializer's executable representation. A declaration with a known initial value, such as `int: i 5`, fills its published field when the occurrence is created, including a field of an uncalled method; the written operation remains in the graph and acts again on a later call. This does not run the method body. An explicit or hidden argument remains an activation-local value unless an explicit declaration establishes a graph-backed field. Assignment to the argument does not write back to its caller or silently create persistent method state. The body here is the callable expression (the method), not a nested `if`/`while`/block body: a declaration in the method's body gives the method its field, while a bare assignment inside a nested body creates no field of that nested body and writes into the declared field of the callable; a nested body's Structure holds only the fields declared in it (`fn: keep (int: n) int` with the body `int: n` / `if: 1` / `n: n + 1` / `return: n` gives `keep(3) = 4` -- the field `n` exists by the declaration `int: n`). See L2 §10. After assignment has been selected, `value` must resolve as an admissible typed candidate; an unknown value or admission failure is an assignment error, with no switch to another colon role. Translation has already fixed the prototype's layout, so execution changes no field count; publication of a declared own value targets storage at its declaration in the active Structure, never the caller's argument source or the parent graph.

Locality and storage duration are separate properties here. The place of declaration of a callable occurrence's variable retains the published value after the activation in the complete Structure -- where the declaration is written, with no separate field beside it; the activation's working variable is not visible from outside, while the path `M\x` from outside opens the place of declaration, since a declaration always establishes a value; a write into it is not a mutation of an outer binding: the caller's argument cell and the above-method space's field remain unchanged. Only an explicit `node\x` path write mutates that outer field, where `node` is the lexical parent's data.

In L3 `@:` declares a new reference field: the name comes first, followed by its requirement and optional initial value, as with other receivers. `@: p` declares a reference with no stated requirement (void); `@: p Model` and `Model: p` with absent `p` declare a reference to known Structure `Model`, already holding its address. `@: p Model 0` holds the null address, while `@: p Model Other` holds `Other`'s address after `implements(Model, Other)`. `@: Model: p` is a nested spelling of the same declaration; `@: int: p` similarly describes a pointer to a primitive. These declarations neither copy the referent nor execute a body; the shared `merge` map redirects references to copied nodes. Redeclaring `p` at the same level is forbidden.

With both `Model` and `p` known, `Model: p` attempts to assign `p`'s value to `Model`, whereas `p: Model` attempts to assign `Model`'s value to `p`; ordinary conversion and admission apply, and failure preserves the destination. Writing through `@` to an existing reference field is a separate operation from these declarations. Requirements are primitives and Structures, not a separate nominal “Type”.

A declared `fn`/`fm`/`sub` and a pointer to it are distinct places. `myFunc()` invokes the declared method itself; `@: ptr myFunc` creates a pointer to it. For the pointer, `ptr()` is syntactically `ptr: ()`: an attempt to assign an empty Structure, just as `ptr: a` attempts to assign `a`; ordinary admission decides whether the value fits. Invocation by address is `\ptr()` or `\ptr: args` and checks the method signature. `catch` keeps its [handling contract](#exceptions), although its head and arguments are built by the common algorithm. Unary `@x` addresses `x`'s storage; `\` follows a reference without collapsing address depth.

A Structure is stored by reference. If `x` is a graph-declared LMX Structure, its descriptor `D` is held as the value of a graph reference slot `S` (`void *`): `x` reads `D` from `S`, while `@x` addresses `S` itself (conceptually `Lmx **`, physically `void **`) without copying the descriptor. When `@x` is retained in an explicit reference binding, a separate typed pointer-pool cell `P` holds the address `S`; `P`, `S` and `D` are distinct. Following that reference reaches the same referent `D`, yet `x` and `@x` have different address depths: writing a newly admitted referent through `@x` changes `S` and subsequent reads of `x`, not the former `D`. Under the present precedence, literal `@x\field` means `@(x\field)`; spelling the route through `@x` to a field is governed by path rules, not by equating these addresses. A Structure formal instead addresses its own activation cell, not a graph slot. The same rule applies to an Array held by descriptor reference. For a primitive, `@` addresses its typed cell; for an Array element, its element cell, including a reference cell. Depth is not collapsed: the target is real stable storage, not a temporary copy, cache or ABI buffer. Projection and lifetimes are defined in [L2 §18](L2_spec_en.md#lowlevel-address).

Passing or returning a value transports that value; @x explicitly transports its storage address. Nonprimitives do not become C-valued. L3 exposes no numeric address, machine cast, raw memory or address arithmetic. References to reference cells are admissible portable references but do not extend their targets' lifetimes.

Before control passes to another callable expression, only own working fields with an active `dirty` mark are published. Marks are cleared after publication. A publication boundary is a call that may publish or escape state, invoke user code, re-enter the Message or transfer control outside the activation; every uncertain external call is treated conservatively as one; a private, non-escaping helper used only for the current activation's own traversal, address classification or explicit graph operation is not a boundary, even if it reads or writes the graph (origin 21.6). Every exit -- fallthrough of the body, `return`, `throw`, a failing `assert`, stop and cancellation -- and `yield` suspension publish the same way. A cached field without such a mark must not be written back: a nested call may already have changed it through an explicit reference. After return, the caller activation does not reload its working values from the graph. Failure to resolve or store into a bound field uses diagnostic `assert`; the intended outbound call is not executed afterward. There is no general transaction rolling back earlier writes.

Dirty state follows an executed write, not value comparison or the presence of a possible assignment in source; it is semantic working-state information, not a mandatory physical flag field per variable: a native translator may statically know that a cached local was modified and emit the store at the checkpoint, while an interpreter may keep a bit or a bitmap. Publication follows forward field order; a successful write clears the corresponding mark. Publication is also required before a foreign boundary capable of calling back into LMX or exposing graph state.

Consequently, after a nested modification of `node\x`, the caller's bare working `x` can retain its earlier value while an explicit path observes the new value. A later assignment to bare own `x` deliberately creates a new write and publishes it at the next boundary. No automatic reload is part of the semantics, not permission to lose dirty changes.

<a id="activation-history"></a>
### Activation stack, recursion and explicit history

The activation stack is the sole implicit call history. Native execution uses the ordinary C call stack; the interpreter uses an equivalent control stack. Direct, mutual and callback recursion creates a distinct activation with its own formal and dynamic values, working locals, result and `dirty` marks. Re-entry into the same callable occurrence executes the same Structure: declared cells remain at their declaration sites, with no separate instance of the fields. No hidden activation node, closure environment or global active-argument record is created.

The callable occurrence holds the published state of its declared fields, not a call journal. Activations of one occurrence have separate working values over the same cells: a suspended outer activation is not reloaded and keeps its working values; after the inner return its clean own field is not published without a new real change. Another explicitly constructed callable occurrence of the same method has its own fields. The result is determined by the sequential order of publications of `dirty` fields only, not by restoring a snapshot.

The following recursive trace introduces no new syntax. Method M has callable occurrence S with declared field `x`, whose value before the trace is 1. Both activations work over S; `n` is a private formal argument in each activation. The table lists writes and publication boundaries, with no additional initialization between them; its columns are each activation's working value and the published `S\x`.

| Step | Outer activation's working `x` | Inner activation's working `x` | Published value at the place of declaration of `x` in S (what `S\x` from outside reads) |
| --- | --- | --- | --- |
| Outer entry over S | 1, clean | — | 1 |
| Outer call assigns `x: 2` | 2, dirty | — | 1 |
| Pre-call publication; `M(0)` re-enters S | 2, clean | 2, clean | 2 |
| Inner call assigns `x: 9` | 2, clean | 9, dirty | 2 |
| Inner return publishes into S | 2, clean | 9, activation ended | 9 |
| Outer call resumes | 2, clean | — | 9 |
| Outer call returns | 2, clean, activation ended | — | 9 |

After the inner return, the outer activation's bare `x` reads 2, its own working value, while explicit path `S\x` reads the published 9. The outer return does not overwrite 9 with a clean cache. If the outer activation executes `x: x + 1` before returning, its working value becomes 3 and is marked `dirty`; the next boundary publishes 3 into the same cell in S. This is a new outer-activation write, not restoration of its previous snapshot. For this declared field, `@x` in either activation designates the same actual typed cell, not a working copy or a re-entry instance. A dynamically supplied `x` remains a local argument even when the body assigns it: the assignment updates that local value, and a field exists only by declaration -- a hidden argument differs in nothing from an explicit one here.

A declared field therefore combines the persistence of an occurrence's cell with the working locality of a stack variable: a used own field is loaded into a typed working value and written back only after a change. The complete graph stores declarations, their published values and executable operators; the stack stores activation history, locals and results. Re-entry adds no instances of fields to the graph. There is no implicit caller-frame capture, so frames need not be heapified or connected by a hidden closure chain to avoid the upward-funarg problem.

The following call example shows the order among cache, explicit graph read and actual arguments; it is a trace using the established `for:` form, not a new grammar rule. `j` is declared in the nested `for` body: as a working variable it is visible only forward and down, while the path `for\j` from the enclosing method after `end: for` opens its place of declaration -- a declaration always establishes a value there (the author's answer, Q51); the example shows the order of cache, explicit read and actual arguments; the cell of `j` starts at 0 in this example, which is an example condition, not a general initialization rule for `int`. Here `print` is a high-level profile callable, not a `c.*` operation.

```text
fn: mytest () int
    int: acc
    acc: 0
    for: int(i, 0) (i < 10) i++
        int: j i
        acc: j
    end: for
    print: acc for\j
    return: 0
end: mytest
```

After the loop, working `acc` is 9. `end: for` is not a checkpoint, and neither is an explicit path read by itself. Before the call, declared actual arguments are evaluated into typed temporaries: `acc` contributes 9 from the cache, while `for\j` reads the previously published graph value 0. Publication then writes 9 into the graph, but the call receives the already selected temporaries and prints `9 0`. A later explicit `for\j` read in another statement sees 9. Publication cannot retroactively change actual arguments already evaluated; a same-activation `for\j: 42` writes the graph cell, not the cache.

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

An ordinary Array is a typed value with stable reference identity. Constructor `[]` creates it when execution reaches the construction site. A Structure field holding its reference is not the Array itself. Passing a reference does not copy elements; an element mutation is visible through other references, whereas rebinding a local reference is not.

An owning Array has one contiguous rectangular block of elements. Nested dimensions do not mean separately allocated rows. For shape `[d0, …, dN−1]`, element count is the product of dimensions, with the last index varying fastest. An Array of references to other Arrays is a different value, not a replacement for a rectangular multidimensional Array. Primitive elements acquire no lexical parents.

The common physical Array descriptor is `VoidArray {size_t size, void *data}`. In `Lmx {VoidArray array, Lmx *parent, LmxEntry native}`, the same descriptor is embedded by value as the first member and is the actual array of physical child references; its backing is registered as an arena address range, but the range entry is not the `VoidArray` itself. A separate `LmxArrayDesc` alias is unnecessary. For a standalone Array, `size` is its logical element count and the backing has exactly that many cells. Base Array has no `capacity` and does not grow, resize, append, or switch backing. Dynamic membership, capacity, and growth belong only to separate dynamic descriptors of the form `{<T>Array array; size_t capacity}`, where `<T>Array` is the already existing fixed descriptor of the real element type T (void is only one element type: `VoidArray` is the descriptor for `void *` elements; an int array is `{size_t len; int *data}`, never the void descriptor with casts). List (`KIND_LIST`) is a public such DynamicArray over `void *` elements, with no hidden capacity prefix in the backing. Physical addresses stored as referent values are unaffected by List growth; a List backing-slot address does not survive private-backing replacement.

`length(array)` reads the element count from the Array descriptor (`len` in a typed descriptor, `size` in `VoidArray`); for a rectangular Array this is the total count, not its first dimension. The descriptor does not store dimensions and cannot reconstruct them from the total element count. The containing Structure's field count, Array length and service descriptor-pool size are distinct.

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

A `fn`, `fm` or `sub` method Structure contains the named parts `args`, `return` and `body`; an ordinary Structure, named or anonymous, participates as one `body` part; a missing part takes part in `merge` as an empty Structure of the same meaning. `merge` proceeds part by part and recursively -- `args` with `args`, `return` with `return`, `body` with `body` -- under the rule above at every level: an operand's same-name field is written into the model's slot, a new one is appended. The model stays the outer frame and each later operand merges inward, as a directory's contents into a directory: `merge(add; y: 5)` puts the field `y` into the `body` of the method `add` (specialization: for the formal `y` of `add` that datum is its default value, below), while `merge((n: 5); addN)` puts the method `addN` inside the Structure holding `n` as a nested field -- the nested method is called as `w\addN(...)`, which differs from calling `w` itself. Whether `w` is callable is not determined by the contents of field 0; calling it does not automatically execute the method declared inside it; `n` in the body of `addN`, when no ordinary dynamic source supplies it, resolves by the lexical fallback to the enclosing Structure's field -- the priority of [§12](#dynamic) is unchanged. Nameless `body` statements do not participate in field replacement by name: the operand's statements replace the model's when the operand has any -- a selection of a whole body at the relevant composition level; machine bodies are never glued into a new composite machine function, and ordinary nested methods, calls and program structure are not cancelled by this rule.

### Explicit callable descriptions

A declared callable header constrains the receiving place; it is not another `merge` operand. The `merge` result undergoes ordinary conversions and [admission](#admission). A shorter place description neither removes the candidate's formals nor changes its body's ABI. A value `y: 5` explicitly added to `args` by `merge` becomes formal `y`'s default: `y` may be omitted or explicitly supplied, including as `0`; a same-named caller value is not substituted for an omitted formal. The body's free names follow [§12](#dynamic). A detailed [walkthrough](LMX_semantics_guide.en.md#callable-description) is kept outside the specification.

### Native implementation reuse and copied callable occurrences

`native` belongs to the selected executable body, not to the `merge` operation. If the body's code is unchanged and only data changes, its native implementation is retained and receives the new copy's graph. If another complete body is selected, its implementation is used; if the selected body has no matching native implementation, the interpreter executes it. Native method implementations are not merged. A nested callable occurrence is copied as an ordinary Structure (except an [eternal branch](#eternal)); sharing its native implementation address does not share its mutable graph. A longer [explanation](LMX_semantics_guide.en.md#native-merge) is separate.

Different physical field positions do not by themselves invalidate the selected native implementation: a successful `implements` table maps receiving-description field addresses to candidate field addresses. Correspondences compose across successive compositions. The table is not another graph, performs no runtime name lookup, and does not itself select the executable body.

### Returned nested methods

A returned nested method is built by the same `merge`: activation data enters a new copy, while unchanged method code keeps its implementation. The declared result description checks the completed callable by ordinary [admission](#admission); it is not a third operand. A copied free-name value provides lexical fallback, whereas a copied formal value provides a default; the priority of [§12](#dynamic) is unchanged. No hidden closure environment or partial application is created.

<a id="factory-reference-result"></a>

The `@:` receiver can evaluate a factory call and retain a reference to the returned method; defining a named body does not itself execute the factory. Invocation through a stored reference uses `\`, for example `\add5(1)`. Unary `@` is not added before the result: that would address the stored reference. A [worked example](LMX_semantics_guide.en.md#factory-result) is separate.

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
### Source-code reconstruction: toLmx

`toLmx` reconstructs source from the [interpretable tree](L2_spec_en.md#interpretable-tree), separate [name table](#fields), and retained comments. For a source-built tree, the only difference is canonical formatting of equivalent grammar forms. Construct composition, nesting, order, and the full text and structural placement of comments are preserved. Names come from the table, not graph fields; comments do not execute. Native code cannot abbreviate its representation: a summary, data-only list, or machine-code decompilation does not replace `toLmx`.

`fromLmx` parses text under the ordinary language rules. Portable persistence conveys content and identities, not a memory image of native addresses, allocator state, and foreign descriptors. Those require separate resource policies without losing source constructs, names, or comments.

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

`timeout: ms: int: time 500` uses the general receiver parser: `int` declares and initializes `time`, and the data path is `timeout\ms\time`, with no `int` field. An incoming formal `(ms: int: time; getPixel: method; int: x; int: y)` uses ordinary `implements` and argument binding at arbitrary names and nesting depths, locally and through `post`. Handler-supplied `time` differs from the configured `timeout\ms\time`; there is no separate duration type system.

`post`, `sendMessage`, and `receiveMessage` use one inbox, one set of publication/ownership rules, and one call engine. The public `sendMessage`/`receiveMessage` forms, address-filtered iterator, all-available-mail option, and `0` end marker remain. One letter cannot be consumed twice by manual and protocol paths; receiving a letter as data does not itself execute its contents. An incoming call runs on the recipient's lane, while `answer` and outcome handlers run on the sender's lane. Both Thread modes (with and without an OS thread), the ordinary lifecycle up to user `success: 1`, final outbound publication, and existing supervision/stopping remain; `post` adds no second entry loop, inbox, or timer thread.

A [complete exchange example and outcome walkthrough](LMX_semantics_guide.en.md#post-transport) is adjacent to this specification and adds no new rules.

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
