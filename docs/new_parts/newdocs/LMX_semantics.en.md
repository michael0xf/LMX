# LMX semantics

**Normative edition: 21 November 2026.** This standalone specification incorporates the supplied requirements for [binding and named signatures](TZ/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), [declaration arguments and import](TZ/LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md), [blank-line termination](TZ/LMX_Fable_TZ_Blank_Line_Block_Terminator_2026-11-20.md), [operands and expressions](TZ/to_fable_operands_arguments_priorities.md), and [import/copy/merge field streams](TZ/LMX_Fable_TZ_Import_Copy_Merge_Field_Streams_2026-11-21.md). The latest [author clarification on the complete graph, zero-payload uninit and graph assignment](TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md) supersedes older physical-record and graph-editing prose. The latest requirements prevail where they revise an earlier rule. Earlier accepted corrections remain applicable where unchanged. Examples specify required behavior; this documentation revision makes no claim that a runtime implements them or that execution tests have passed.

**Lingvamyxa (hereafter LMX) is a language in which a program is a lexical forest of primitive arrays connected into a dynamic graph.** This organization repeats self-similarly at the level of local actors with physical memory addressing and further at the level of remote intermachine messages with composite addressing.

**Both data and executable bodies are arrays**, represented by the same simple universal structures; every executable body is a complete abstract expression.

**Typing is analytical, at the level of lexical branches.** The common admission mechanism checks a concrete Consumer's used interfaces, the whole tree of an explicitly selected structural template, or the ordered input/result types of a named `fn` requirement, as applicable. Additional behavioral checks (`test`) are explicitly stated by the receiving expression. Candidate values and checking expressions have their ordinary physical identities.

LMX is also a grammar capable of representing both data in a complex, uniquely structured hierarchical and tabular form with intersecting sets and, in principle, any language. See the [complete grammar specification](LMX_grammar.en.md).

**Language levels.**

- **L0** is native code: microprocessor instructions or virtual-machine instructions. For a microprocessor, the translation chain is **L3 → L2 → L1 → C99 → L0**; for a virtual machine, it is **L3 → L0** directly. Arrows denote translation stages.
- **L1** is the intermediate language lowered to C99. This archive states its relevant boundaries through the [L2 specification](L2_spec_en.md) and [implementation design](kernel-implementation.en.md).
- **L2** is LMX itself with low-level operations, described in the [L2 specification](L2_spec_en.md).
- **L3** is pure, hermetic LMX. Its semantics are the subject of this main specification.

<!-- semantics-toc -->

- [1. Language scope and execution modes](#scope)
- [2. Values, Structures and Arrays](#values)
- [3. Identity and lexical trees](#identity)
- [4. Names and paths](#fields)
- [5. Explicit value descriptions and conversions](#descriptions)
- [6. Message-local type bindings and conversion context](#conversion-context)
- [7. Used interface checking and test](#admission)
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
[author clarification](TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

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

<a id="values"></a>
## 2. Values, Structures and Arrays

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

<a id="identity"></a>
## 3. Identity and lexical trees

Live Structures, including Arrays, and local Messages retain their physical addresses. A record's physical address is the Message's in-process identity; local identity is not supplemented by a parent index. Storage grows by adding new regions; existing objects do not move. Equal contents do not imply object identity. Explicit copying creates new identities and preserves relationships under the [copying rules](#composition). Hierarchical index chains belong only to [WorldWideMix](#worldwide).

A lexical parent determines a Structure's position in its tree; a root has no parent. Storage ownership and lexical ancestry are independent. Attaching another Message's storage preserves existing lexical links, does not itself add a reference from the recipient's root and does not make the adopted root a lexical child of the recipient.

The [independent qualifier](#qualification) cuts the external lexical parent at construction; obtaining inputs from the caller follows [dynamic visibility](#dynamic). Neither mechanism changes storage ownership or object identity.

<a id="references"></a>
<a id="fields"></a>
## 4. Names and paths

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

<a id="descriptions"></a>
## 5. Explicit value descriptions and conversions

A value description is an ordinary explicitly accessible Structure. A receiving expression obtains it through an argument or reference. It is not secretly attached to every primitive and is unnecessary for determining a physical type: the code in the value's record gives it. Names such as `class` and `class.range` denote a particular profile's data, not mandatory global language entities.

The conversion table defines relations between primitive values and their descriptions, not between every pair of Structures or their names. Distinct Structures `A` and `B` share the physical `Lmx` representation -- a record with a type code ([L2 §3](L2_spec_en.md#value-record)); a name or field composition creates neither a separate physical type nor a one-element array. Whether `B` satisfies requirement `A` is determined by `implements` relative to the Consumer, not by a `B → A` conversion row. Obtaining or transferring a Structure reference likewise requires no converter for each model. Shared physical representation does not remove structural admission, qualifications, or the distinction between a Structure reference and a reference to a reference cell.

A description separates its semantic contract from architecture binding. The contract defines meaning: count, integer, rational, profile-precision number, complex value, atom, address, opaque resource or absence of content. The binding defines width, signedness, range and target spelling. Equal representation does not imply equal contracts: `Boolean` and `int8` may share storage while admitting different values.

Ordinary description fields include `cell`, `semantic`, flags such as `numeric`/`integer`/`floating`/`reference`/`opaque`, `width`, `signed`, `range`, `spelling` and `convert` keys. The profile chooses field names. A range declaration is contract data; satisfaction is established through the [single admission mechanism](#admission), not by the field's presence alone.

The numeric contract chain is flag → nonnegative integer → integer → rational → profile-precision number → complex number. Nonnegative integers include zero. Machine `double` is not the set of all real numbers. Atoms, addresses and opaque resources are separate contracts, not rungs of this numeric chain. `unit` is an empty Structure; `void` denotes no cell content.

Descriptions are composed with ordinary `merge` under the common [occurrence-order rule](#fields). Fields such as `width`, `range` or `spelling` do not automatically create arithmetic methods. Such operations are callable expressions. For example, `u32` combines a nonnegative integer contract, 32-bit representation and range 0…4294967295; `FILE` describes opaque resource identity. A `FILE` word alone does not establish that reading or closing is valid: such requirements are expressed through paths of a `File` Structure.

A converter is an explicitly selected receiving expression. Its key comes from explicit descriptions and their composition; there is no hidden search over pairs. Suitability checking does not run the converter; an action requiring conversion performs the selected call. A repeated declaration of a key in one Structure is read by the role ([the roles `data` and `code`](#data-code-roles)): in data it is one more occurrence of the name -- it neither replaces the former one nor writes into it, and after it the key is addressed only with the index of an occurrence ([names and paths](#fields)); in code a repeated declaration by a receiver writes into the already declared place after the type check and creates no second field. Composition writes a later operand's same-name key into the model's slot. If a table has several rows with one key, the table operation's own policy selects the row ([tables](#registries)).

Numeric conversion preserves the destination-range contract: `u16(255) → u8` is admitted when the converter exists, while `u16(256) → u8` produces a range error, not zero. Rounding `1.5 → i32` and in-range precision loss require explicit numeric-profile rules. Proven range inclusion may eliminate a redundant machine operation while preserving the semantic requirement. Format, range and converter-behavior failures are not replaced by a positive `implements` result.

<a id="conversion-context"></a>
## 6. Message-local type bindings and conversion context

Each executing Message has one context of type descriptions, symbolic bindings, and conversions. It consists of ordinary Structures and references explicitly supplied when the Message is built or reachable from them. Message creation, sending, and parenthood do not implicitly pass the parent's context. There is no built-in process-global registry, implicit type environment, or hidden converter search. The table of conversions that `implements` uses can be changed when a new L1 Thread is created (the author's words of 2026-11-18).

### Stable bindings and structural genericity

A symbolic type name is bound once for a Message and resolves consistently at every use, including arguments and results; each call does not instantiate it anew. Another Message may bind the same name differently. This is a relation within the context, not another runtime name space.

Structural genericity is the ordinary case of [admission](#admission): a Consumer requires only the paths, operations, and contracts it uses. It needs no separate generic template. A symbolic binding is needed when multiple positions must share one stable type relation, not merely to declare genericity.

### Conversion at consumption

The reachable conversion table concerns primitive descriptions, including explicitly supplied semantic quantities and units; it is not a Structure-compatibility catalog. Another primitive description is admissible only through a conversion available in this Message and allowed by the Consumer's contract. The first part of admission, suitability checking, does not execute a converter. At actual consumption it executes as an ordinary callable with checks for range, representation, precision, and semantic conditions. Structural success does not permit reinterpretation of primitive storage without such a conversion.

Before a call, each converted actual argument must satisfy the selected callable's actual descriptor; afterward its result is converted separately to the Consumer's requirement. A converter absent from the reachable context is not replaced by a hidden chain or process-wide search. An implementation may cache resolved bindings and routes only while preserving the result of explicit resolution.

Expanded [Message-context examples](LMX_semantics_guide.en.md#message-conversion-context) are kept outside the normative text.

<a id="admission"></a>
## 7. Used interface checking and test

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

<a id="admission-recipes"></a>
## 8. Obtaining a required guarantee: fourteen practical cases

These cases apply [unified admission](#admission); they are not fourteen separate type systems.

<a id="admission-case-1"></a>
### 1. One receiving expression for multiple data shapes

Consumer requires the paths it uses, not a nominal type for the entire Structure.

<a id="admission-case-2"></a>
### 2. Knowing what a particular site checks

The first part checks structural suitability for actual Consumer accesses; the second, analytical part `test`, checks the stated behavior. Unknown coverage is not proof.

<a id="admission-case-3"></a>
### 3. Distinguishing meanings with the same representation

Express a semantic distinction through a used path and, where leaf values matter, a test; a type name alone proves no equality of values.

<a id="admission-case-4"></a>
### 4. Constraining a scalar leaf

A `width` field does not establish `width = 32`; Consumer's test states the check of the concrete number.

<a id="admission-case-5"></a>
### 5. Making a change visible to other reference holders

An explicit path write changes the addressed shared referent; assignment to an argument or another own local variable changes only the current activation's place, without write-back; a name bound as the caller's place denotes the caller's place, and a write into it takes effect at once ([own place and caller's place](#binding-places)). [Call frame](#call-frame-20261115).

<a id="admission-case-6"></a>
### 6. Independence from another holder's mutation

Ordinary Structure or Array passing transports a reference. Explicit copying creates an independent mutable copy; immutability prohibits mutation of the protected value.

<a id="admission-case-7"></a>
### 7. Establishing that a call can proceed

Besides a suitable callable interface, the call needs a source for each of its free (dynamic) inputs. Ordinary declared inputs are optional unless input `required` or another applicable contract rules out omission: an input without a value, to which no value is supplied, does not make the call refuse: [autofill](#binding-autofill) fills it, and where that is inapplicable it holds "T without initialization" (the author's decision of 2026-11-16); the receiver [`required`](#required-receiver) checks that a field is initialized.

<a id="admission-case-8"></a>
### 8. Checking a transported callable

Transporting a callable neither executes it nor proves suitability for every future call; each concrete call has its own admission.

<a id="admission-case-9"></a>
### 9. Changing a method body without breaking calls

A new free dynamic input changes the method interface and requires affected calls to be checked; an unchanged signature alone does not guarantee unchanged behavior.

<a id="admission-case-10"></a>
### 10. Selecting the intended part of a composition

`merge` composes only its explicit sources: a compatible later field replaces the corresponding first-source model slot, and a new field appends. It emits the resulting fields as a stream; grouping obtains one Structure. The destination is not an implicit model.

<a id="admission-case-11"></a>
### 11. Changing an existing Structure

A Structure uses common variable-array resizing: sys\resize changes length and, when necessary, storage; the descriptor address stays stable. Raw addresses into old storage are not repaired automatically; an L3 element reference holds the descriptor and index.

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

Two-field `int: x 5` declares place `x` with an `int` requirement and value `5`: in data it creates the place, in code it is a call of the receiver -- a check of the type with an assignment to the local namespace place `x` ([the roles `data` and `code`](#data-code-roles)). Unary `int: x` describes place `x` with an `int` requirement and no invented initial value: a first definition creates the place; with an already known `x` the same form in code checks its compatibility by ordinary admission without a new write or second field, and in data it stays one more occurrence of the name, which is addressed only with the index of an occurrence after that. An uninitialized graph place contains only the distinct type code `uninit:int`, with `sizeof(value) = 0`, not a reserved int cell, numeric zero or an external initialization mark; every primitive has such a type, alike in code, data and a signature, where it distinguishes a formal without a default `int: q` from the default `int: q 0`: such a formal is not mandatory -- an input without a value, to which no value is supplied, does not make the call refuse: it is filled by [autofill](#binding-autofill), and where that is inapplicable it holds this type (the author's decision of 2026-11-16), and the receiver [`required`](#required-receiver) checks that a given field is initialized; the latest [author clarification](TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md) specifies that explicit graph assignment (`D\a := 5`) replaces the fragment at that structural place: `{uninit_int}` becomes `{int 5}`. It does not retag a preallocated T cell, require in-place expansion, or preserve a raw payload address across replacement ([L2 §3.1](L2_spec_en.md#uninit-record-control)). An assignment to a local of the call -- `a := 5` for a formal that received no value -- writes into the place of the call: the graph does not change and the data are not published. The absence of a value is written as a value of that separate type: `nil: T` (`nil: int`; any other primitive type in place of `int`), and simply `nil` where possible. `int: var` declares a variable without initialization, and a separate type exists for that; it was introduced for passing arguments and stays needed with `required`. A variable can be compared with `nil` by its absence state; no numeric sentinel or imaginary value bytes are introduced. The graph holds nothing but Structures and primitives: a primitive is the declaration of its type with a value or with the absence of a value, and everything else is written as Structures. The null pointer stays `0` where that is possible; a pointer declared without a value (`@: ptr`) is not zero and is written with the same `nil` (the author's decision of 2026-11-17). Every receiver that used to be written without arguments in the place of a type has a one-argument form: `int: i` is written instead of `i: int` (the author's decision of 2026-11-10). With `i` already declared, `int: i` in code is not an error but a check that the type conforms: repeated declarations are allowed. The one-argument form given the primitive itself instead of a name, `int: 54554878477838734`, returns the number in an expression or throws a failure that `catch` receives. In a signature these forms describe a formal, and a written value supplies a default when an actual argument is absent; describing a formal does not execute it as a body. This is one mechanism for primitives, references, Structures, and callables, with no parser branch for a receiver's name. The constructed source graph fixes its physical slots until an explicit graph operation changes them. Logical namespace places and bare-name visibility follow sequential declarations, lexical scopes and explicit receiver-stream consumption; reaching a branch does not append a hidden slot to the source `Lmx`.

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
[author clarification](TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

<a id="compound-assign"></a>
#### Compound assignments and the power

The compound assignments `+=`, `-=`, `*=`, `/=`, `%=`, `<<=`, `>>=`, `&=`, `^=`, `|=`, `**=` and the power operator `**` for expressions join `:=`. A compound assignment writes a place already known with the result of the operation over its current value and the right operand: `a += b` corresponds to `a := (a + b)`, `a -= b` to `a := (a - b)`, `a *= b` to `a := (a * b)`, `a /= b` to `a := (a / b)`, `a %= b` to `a := (a % b)`, `a <<= b` to `a := (a << b)`, `a >>= b` to `a := (a >> b)`, `a &= b` to `a := (a & b)`, `a ^= b` to `a := (a ^ b)`, `a |= b` to `a := (a | b)`, `a **= b` to `a := (a ** b)`; the author's spelling of these equivalences with a C-like `=` is kept in the journal, and in LMX `=` stays a comparison. The left side is a place already known under every rule of `:=`, the `implements` admission and the error of an unknown left side included; `:=` keeps its general narrow meaning of writing a known place, method references and the named supply included, and is not narrowed to numbers. `**` is the power; `^` stays the bitwise exclusive or. The associativity and precedence of `**` are Python's (the author's clarification of 2026-11-07): `**` groups to the right -- `a ** b ** c` is `a ** (b ** c)`; it binds tighter than `*`, `/`, `%`, `+` and `-`; a call, an index and a field access form the operand before `**`; on its left `**` binds tighter than the unary `+`, `-`, `~`, on its right a unary operand is admitted -- `-2 ** 2` is `-(2 ** 2)`, `(-2) ** 2` keeps its parentheses, `2 ** -2` is `2 ** (-2)`, `2 * 3 ** 2` is `2 * (3 ** 2)`; the right side of `**=` groups the same way. Grouping and execution are distinct: reached effects follow the common LMX demand and written-order rules, not C's unspecified operand order. A compound assignment evaluates its destination once and obtains the operation result before the write; the equivalences are not textual macros that repeat destination effects. Numeric types and conversions of `**` and `**=`, negative or fractional exponents, `0 ** 0`, numeric failures and atomicity follow the selected numeric and write contracts. Only power grouping is taken from Python; no other Python numeric policy is implied. Implementation must preserve these results on each supported execution path; this specification is not an implementation report.

<a id="group-assign"></a>
#### Group positional assignment

Author's decisions of 2026-11-10. The left side of the `:=` operator may be an unnamed Structure of places: `(a b c) := (c, a, b)` assigns by position — the first value to the first place, the second to the second, the third to the third. The author first wrote this form with a colon, `(a b c): c, a, b`; after the rule that structural forms do not assign ([structural forms](#forms-declare-or-call)) it is written with `:=`, and a Structure as the head of a Frame before a colon is not introduced. All right-hand values are computed before the first write, so this statement rotates the three values. Each position is written by the rules of `:=`: the place must be available at the assignment site under the [common visibility rule](#declaration-visibility). Variables and `const` are visible sequentially; grouping does not change that rule. An explicit path selects a field under the ordinary path rules; this does not make its bare name visible before declaration. For name-based access, an unknown name, the name of a Structure or a function name on the left is an error, and each value passes the ordinary admission of its place. When the right side is one call whose result is a Structure, the places receive its fields by position, and the names of the result's fields are not compared: `(a, b, c) := myFn()` ([Structure result](#structure-result)). This is an assignment between unnamed Structures, the general case of assignment and not a special form (the author's decision of 2026-11-16). A different number of places and values is a refusal: at translation when the number is known, otherwise at execution before the first write. A Structure on the left holds at least one place; the head `()` with empty parentheses remains the earlier separate form ([grammar](LMX_grammar.en.md#bounded)). The same mechanism consumes field streams, for example `(a b) := copy(Pair)`, assigning the two resulting fields by position. In `(c b d a) := a b c d`, starting from a=1, b=2, c=3, d=4, the final values are c=1, b=2, d=3, a=4. All RHS values precede the first write; this promises no rollback of effects already produced while computing them.

<a id="qualification"></a>
## 10. const, immutable and independent

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

<a id="execution"></a>
<a id="callables"></a>
## 11. Callable expressions and their interfaces

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
A call's result may be a Structure with several fields, described by a nested return block in its DATA, for example return with `int: x`, `int: y`, and `int: z`. Return describes no shared mutable result cell. The general group assignment `(a b c) := myFn()` receives the resulting fields by position, ignoring their names and requiring the matching count before the first write. Result-expression construction and ordinary receiving places follow their existing contract; transfer by return itself neither copies a returned reference nor creates a second container. A return tail `return: 1 2 3` supplies the described result fields in order. No separate `fm` receiver is introduced. An explicitly grouped copy result uses `return: (copy(A))` when one Structure is required.

The shorthand with the callable's name to the left of `:=`, such as `square := x * x` inside `square`, is rejected: nothing is assigned to the name of a callable -- the names of Structures are not assigned ([the roles `data` and `code`](#data-code-roles)). The former condition of its admissibility -- the receiving `fn` defines a same-named local result cell -- is never fulfilled under the norm of 2026-11-19: there is no executable `fn`, and the `return` field in data describes the result and is not a cell named as the callable (a consequence of the norm, the executor's reading). Structural closing with `end: f` adds no implicit value return; the result is passed by explicit `return: value`.

A returned reference preserves its exact target identity. Constructing a result, if necessary, belongs to evaluation of the returned expression, not the transfer operation. Returning from a nested function ends its activation, not automatically the entire actor. Exit and cleanup ordering is defined under [exits](#exits).

<a id="publication"></a>
<a id="dynamic"></a>
## 12. Dynamic inputs and working state

Value storage at a declaration in the complete Structure, a working value of the current activation, an explicit formal argument, a dynamic input and the caller's place must be distinguished. They have distinct mutation rules; a working copy does not create a second persistent graph. Ordinary passing copies a mutable primitive's value and a Structure or Array's reference; the special identity of an immutable value is retained under [qualification](#qualification).

<a id="binding-places"></a>
### Own place and caller's place

The norm of 2026-11-19 ([the requirements](TZ/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), R01–R07). Name resolution in a call determines the source and the logical place. There are two kinds of places. Own place: a supplied actual argument, autofill or the former binding gives a value or a description into the place of the current activation. Caller's place: the name denotes an already existing local variable of the caller, with no intermediate working copy. In both cases the variable `x` has its ordinary type `T`; reading `x`, writing `x := value`, expressions with `x` and `@x` act on the selected logical place. The hidden pointer by which native passes the caller's place is a way of implementation: the type of `x` does not become a pointer, and writing `\x` instead of `x` is not required. For a reference variable its ordinary type remains its reference type; the additional level of the address of its cell is transport-only and is not added to the type.

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

Dynamic binding supplies a used external name from the permitted calling context instead of its lexical fallback. The common binding rules distinguish a transparent immediate-caller place from an own value supplied by the retained fallback. Explicit lexical paths such as `node\x` still select the graph directly; they are not dynamic substitution. The visible lexical declaration matters to the two-way `private` filter below, while an unmarked free name remains eligible for dynamic binding. This preserves explicit lexical access from the author's definition of 2026-11-17 under the revised binding order of 2026-11-19. Receiver `private:` forbids the implicit dynamic participation of the marked declaration and of the place corresponding to it in both directions (the norm of 2026-11-19, [the requirements](TZ/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), R05 and R06). The source side: a marked place of the caller automatically supplies neither its value nor its mutable place. The receiver side: a really visible marked declaration of the lexical context of the callee is not shadowed by a value or a place from the dynamic context, and a marked receiving place is not autofilled. The rule applies to [autofill](#binding-autofill), the [transparent caller place](#binding-caller-place) and the dynamic part of the [former binding](#binding-fallback). Therefore, before an external dynamic binding is accepted, it is established which lexical declaration is really visible and whether it is marked: checking only the source is not enough. This is a property of a particular declaration and its corresponding binding, not a ban on the name's spelling. A marked source is skipped, and the search continues in the ordinary order: a more distant permitted source of the same name remains available. The receiver-side protection concerns the selected visible declaration: a marked `x` of a distant ancestor does not close a new inner unmarked `x`. Before 2026-11-19 the rule was one-sided -- `private:` merely excluded a field from the sources; that wording is withdrawn.

The field remains directly visible from anywhere: an explicit path, `node` and ordinary lexical lookup remain available, and nested lexical code sees the field. Receivers are not executed in the graph, and the `private:` record lies there as it is written, so the path to the field goes through it: `S\private\field` (the author's clarification of 2026-11-18); binding does not straighten this record into `S\field`. The receiver introduces no access boundary, does not change sequential visibility, does not replace `const` and `immutable`, and prohibits neither explicitly passing the marked value as an argument nor explicitly filling a marked receiving place with a permitted actual argument. An explicitly passed value does not carry the history of the marked source onto its copies, and an unmarked place of the recipient does not become marked from this. A new inner declaration shadows an outer marked one in the ordinary lexical way ([declaration levels](#shadowing-levels)). Resolving the field through ordinary lexical lookup is not dynamic binding. Neither is a code's reading of a field of its own call data: with `D: private: int: x 5` the code `C` with the data `D` reads `x` as its own input place and gets 5, while what `C` calls does not get its `x` from that place by any of the implicit ways -- `private` forbids only dynamic binding (the author's clarification of 2026-11-17; in the clarification the data were given by the former form `call(D C)`, now the data are `parent(C)`).

The rule is identical for calling a Structure by name and both forms of `call`, in the interpreter and native execution. The existing common binding mechanism applies it when selecting a binding; it requires no separate name-denial tables, protected value type, or checks on every direct read.

The record of the receiver `private:` lies in the clean graph like the other written receivers. The walker recognizes and consumes that original record; the translator reads the same record and reflects its binding rule in generated method instructions and hidden arguments. Neither builds another graph containing private marks, access flags or a replica of the source tree in the binary. The ordinary generated binding logic is sufficient. A regression must preserve `S\private\field`, verify the same private behavior across native/walker calls, and reject a second marked graph even if its outputs happen to match. This incorporates the latest [author example](TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md#private-without-marked-graph).


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

The author's rule (author decision; [the requirements](TZ/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), R16): a declaration at a nested level shadows an outer declaration of the same name; at one level there is nothing to shadow -- the parent one is used. The rule is applied through the owner of the declaration and the lexical scope: an available outer binding and an own declaration of the current level do not become one place merely because the names coincide.

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

The caller of `Worker\work()` has no local x. The inner `int: x` creates a distinct place and shadows the outer x=5. It has no actual, ready value or initializer. Autofill takes its source from the immediate caller's permitted local context; entering an inline `if` does not create a new caller, so the enclosing local x=5 is not that source. The inner place therefore remains `uninit:int`, and the reached `required: x` refuses initialization. The outer place remains 5. This is the consequence of the supplied [Binding and Callables §§6.1, 7.2 and 7.4](TZ/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), not a separate rule that copies outer locals or eagerly executes defaults. With an explicit inner initializer, `int: x 9`, the check passes and the outer place still remains 5. These are required outcomes, not a report of executed tests.

<a id="required-receiver"></a>
### Receiver required: checking that a field is initialized

`required` checks initialization, not the truthiness of a value. `uninit:T` fails; zero can satisfy it. On an input declaration it constrains call selection: the candidate needs an explicit actual or its own applicable initializer/default, and hidden autofill cannot supply a missing required input during that selection. In reached CODE it checks the actual place at that point, including any allowed autofill or prior assignment. This is one initialization requirement in different consuming positions, not a separate mandatory-argument type.

`required` may be written anywhere: all Structures are interchangeable, and it is not known in advance which one ends up in which role (the author's answer of 2026-11-16). There is no restriction on which declaration it stands in -- just as `private:` has none ([receiver private:](#private-binding)): `required: int: a` is the ordinary composition of declaration receivers that marks the declared field `a`; when a call executes it, no field named `required` arises, while in the graph the record lies as it is written. The check of an already visible field may also be written as a separate line -- `required: a`. There may be several arguments -- `required: a b c`, `required: int: a; int: b`, `required(int: a; int: b)`: the action needs one argument, and the receiver applies it to each in turn, in the written order (the author's clarification of 2026-11-18). All combinations are possible -- in `data` and in `code`, as a mark of a declaration and as a line with the name of a field -- and so is any number of checks of one variable: in `code` each runs on its own line and does not interfere with the others. These are different paths to one check, and neither needs a separate pass: on entry to a callable there are no initialization passes besides the supply of arguments, and the rest is executed when reached ([call frame](#call-frame-20261115)).

`required` in the input data of a call is checked when the arguments are supplied -- the one action of the entry that passes over the input places anyway: if the place received neither a value of its declaration nor a supplied actual, it is an error, and no record of `code` is executed. [Autofill](#binding-autofill) does not make such an input pass the check: `required` in the input description takes part in [declaration selection](#declaration-selection), and implicit binding does not take part in selection (the norm of 2026-11-19, [the requirements](TZ/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), §9.7). A `required` form in `code` -- a marked declaration or the line `required: a` -- is checked on that same line, when execution reaches it: for a declaration after its ordinary action, the check of the type with an assignment, for the line with a name by the field found at that place under the general [visibility](#declaration-visibility) rules; the actual state of the place is checked, including after a permitted autofill.

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

The norm is one for the interpreter and native ([the requirements](TZ/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), §11–§12). A direct native → native call is kept where the selected implementation, types and binding are known. An autofilled value is lowered by the same parameter `T` as an explicit actual argument; the [transparent caller place](#binding-caller-place) -- by the hidden address of its cell; the [former binding](#binding-fallback) still gives an own place. A common C body may be shared between modes through adapters, but an adapter keeps the owner of the record and the behaviour of `@`. With identical explicit actuals the mode of the hidden input may differ because of the caller's context and `private`: a native entry conforms to the real contract or receives a description of the place; new user pointer types are not introduced.

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

<a id="branches"></a>
## 13. Branches and loops

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

<a id="exits"></a>
## 14. Exits and finally

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

<a id="exceptions"></a>
## 15. Declared failures and diagnostics

`throws` lists names of an expression's possible recoverable exits, not exception types. The caller must provide a `catch` for each name or include it in its own `throws`. A call without either treatment is rejected. Failure detection uses ordinary `if`; module `guard` is not a failure-handling operator.

`throw: Name(arguments)` evaluates an explicit payload and leaves the current activation under the [exit rules](#exits), without returning its declared result. The selected `catch: Name (...)` parameters receive the payload. A handler's repeat call begins a new activation from the start and does not resume the abandoned frame.

`catch` is a landing pad in the caller's block, not an ordinary nested callable Structure ([`catch` in the common model](#catch-common-model)). Its body is skipped on the initial straight-line pass. When the corresponding failure arrives, its body runs and execution continues with the statements after that `catch`. Consequently, a handler before a call re-enters the following region; a handler after the call continues past itself. The region ends at the next `catch` in the same block or the block's end. The handler covers every call of its block, including calls made from statement blocks nested inside it (`if`, `while`, `for`, an anonymous `---`): a handler, like named Structures and callables, is visible throughout its block in both directions. A sibling block is not covered. This is bidirectional visibility of a callable name, not of all data places. Variables, including `const` and variables holding method pointers, are visible sequentially; names of named Structures and callables are visible in both directions under the [common visibility rule](#declaration-visibility).

Two same-named handlers in one block are prohibited; separate nested blocks can each have one. Delivery selects the handler by the calling block, not a same-named handler in a sibling block. Throwing the same name inside a handler does not re-enter it: this is a failure in the enclosing calling context. An unhandled name propagates only through matching `throws` declarations.

Language operators whose `throws` list the programmer does not see written out (for example `merge`) also throw a named failure, but catching it is optional: a `catch: merge` handler -- before the call, after it, or in a separate nested block -- handles it in the ordinary way and nothing flies anywhere; an uncaught implicit failure flies to the root of the executing Message and the Thread stops (`running = 0`). The only placement constraint is the one declared names have: two same-named `catch` handlers cannot compete at one level.

If the interpreter detects an error in an operation while executing a correctly constructed graph, it raises an ordinary implicit failure with the single name `interpreter`. `catch: interpreter ()` receives it under the same scope and propagation rules as other implicit failures; there is no separate interpreter-exception channel. An error while constructing the source graph during translation, a malformed graph, or a violated kernel invariant is not such a failure: it is a diagnostic of the corresponding stage, which the executing program's `catch` cannot intercept.

<a id="catch-common-model"></a>
### `catch` in the common model of data and call

The norm of 2026-11-19 ([the requirements](TZ/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), R17). The handler `catch` is described by the common model of inputs and the actual link: the code of the handler is read in the role of code, and its role of data is played by its `parent`, as for any executable code ([structural call](#call-receivers)). The payload `throw: Name(arguments)` is the explicitly supplied values; the handler's parameters accept them under the general rules of actual arguments. The other dependencies of the handler -- the names it uses but does not receive as payload -- are subject to the ordinary [binding](#binding-places) and [two-way `private`](#private-binding).

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

<a id="suspension"></a>
## 16. Restart and suspension

`retryable` defines a restartable region. Unlabelled `retry` repeats the nearest active such region; `retry: label` repeats the named one. Abandoned-attempt cleanups run before restarting. The transfer does not roll back external effects, graph mutations or published Messages. Transactional rollback requires an explicitly represented data protocol.

`retry` itself is a local transfer in the current activation, not a new call or restoration of a hidden environment. Current working values continue to exist, with no additional publication merely because of the transfer. If repeated execution reaches a call or exit, that boundary's ordinary rules apply. A caught failure's payload remains the handler's explicit arguments.

`yield` transfers a produced value and suspends the activation. Its local inputs, namespace, and working values remain for resumption; they are not published into the graph or reloaded from the source Structure on resumption.

Producer inputs are fixed when its activation begins. A later `next` caller does not replace them with its own dynamic context. If `next` is a separate wrapper expression, its inputs belong to its activation unless an explicit operation changes the producer's saved state. The continuation and iterator-result representation is not observable when it preserves these semantics.

<a id="arrays"></a>
## 17. Arrays and backing

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

<a id="array-operations"></a>
## 18. Array operations

Array arithmetic and comparisons are elementwise by default. Element operations follow their numeric domain and explicitly selected context. `*` means elementwise multiplication, not matrix multiplication. `matmul`, `dot`, `contract` and `outer` are separate explicit operations; a profile-specific matrix symbol must not make ordinary `*` ambiguous.

`reduce` collapses elements with an associative or explicitly ordered operation. The contract defines an identity where needed, element operation, result type and ordering. Reproducible real/decimal computations must not depend on an incidental backend choice of order.

`scan` is a prefix reduction: inclusive sum of `[1,2,3,4]` gives `[1,3,6,10]`. Inclusive or exclusive behavior is explicitly selected. `map` applies an expression to elements; a pure variant permits vectorization and parallel evaluation preserving the result. Effects need explicit ordering; the default profile expects pure mapping.

`filter` selects elements by a Boolean predicate and normally materializes a new Array. Copies, materialization and all results retain Message ownership boundaries.

<a id="mathematics"></a>
## 19. Numeric operations, purity and contexts

Numeric names and operators resolve to available constructors, explicit descriptions and callable operations. Families include machine integers/floats, `bigint`, `real`, `decimal`; these are not a mandatory closed language type list. GMP, MPFR and decNumber are possible implementations, not L3 source ontology. Conversions specify range, precision and rounding under the [description contract](#descriptions).

A selected pure expression profile admits only operations with declared pure contracts; the general expression mechanism also supports the reached assignments and effectful calls described in §9. `sqrt`, `sin`, `cos`, `pow`, `abs`, `gcd`, rounding and arithmetic may have such wrappers. Effectful operations remain valid high-level receivers but do not become pure by being written in an expression. L3 does not prohibit effects generally or derive authority solely from a level number.

A low-level function with raw pointers has no direct L3 call. A high-level wrapper defines ownership, borrow duration, null policy, bounds, element type, mutation, failures and result. Without it only the machine side of [L2](L2_spec_en.md#lowlevel-abi) is available. Numeric-backend initialization and release normally belong to the provider; user numeric code should not manually reproduce its internal storage management.

A `real` context may define precision, rounding, status, traps and exactness requirements; `decimal` additionally includes exponent limits and quantization. Context is explicitly reachable data or fixed profile configuration, not hidden global state. Exact context receiver names remain profile-specific. A deterministic profile must exclude dependence on unspecified platform settings.

Arrays use the same scalar operations and contexts. Vectorization, reduction and tensor operations do not create a different meaning of addition. The minimal mathematics profile includes basic arithmetic, Boolean operations, comparisons, construction/arithmetic for the three extended numeric families, explicit conversions, selected pure functions and numeric-Array operations. It does not imply exposure of the entire C library.

<a id="composition"></a>
## 20. Composition and graph copying

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

### Returned nested methods

A result that needs one copied Structure uses an explicit group, such as `return: (copy(Product))`; one-source `merge(Product)` is no longer the copying form. Multiple sources use `return: (merge(Model Values))`. The result description admits the constructed value and is not another source. Any needed activation values must enter through explicit source material or ordinary explicit operations; copy/merge do not silently capture a stack frame or give stored stack addresses longer life. A copied formal value can serve as a default and a copied free-name value as lexical fallback, under the ordinary call rules.

<a id="factory-reference-result"></a>
A reference receiver can retain a factory result, for example `@: product Factory\create()`, and later call a selected nested method. It adds no prefix `@` to obtain an ordinary Structure reference. `add5(1)` or `(\add5)(1)` calls a stored method reference; `\add5(1)` dereferences the call's result according to precedence. See the [factory example](LMX_semantics_guide.en.md#factory-result).

### Binding, failures and other consumers

Copy/merge do not override [binding priorities](#binding-places). The private filter and transparent caller-place rule apply first where relevant; retained fallback still consults permitted dynamic sources before lexical ones. Explicit `node\...` selects the established lexical context. No result stream establishes a hidden closure or partial application.

Each receiver reports failure under its own contract: `copy` and `import` must not accidentally report `merge` merely because a low-level helper is shared. As with other implicit operator failures, an applicable ordinary catch handles the named failure; an uncaught failure stops the executing Thread under [§15](#exceptions). No partial-result publication or rollback of already completed source-expression effects is promised. Temporary storage follows the owning Message's lifetime rules; [L2 copying](L2_spec_en.md#copy-merge) specifies mechanisms.

Schemas, type descriptions and tables use the same structural operation. Table row/key/conflict policies belong to their selected table consumer and do not alter model-slot or DATA repetition rules. Message storage transfer is a [different operation](#delivery): it transfers ownership without copying or lexical reparenting. The governing stream clarification is [the supplied 21 November TZ](TZ/LMX_Fable_TZ_Import_Copy_Merge_Field_Streams_2026-11-21.md).

<a id="registries"></a>
## 21. Tables, queries, linking and providers

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

<a id="memory"></a>
## 22. Ownership, reachability and lifetime

Every Message, executing or not, owns one logical arena of mutable data. It can contain multiple disjoint regions; these are not additional source-level arenas. Calls, blocks, handlers, branches and retries do not create their own semantic arenas. L3 does not select an arena through an operation argument.

Lexical nesting, storage ownership and reachability are distinct relationships. One arena may contain multiple lexical trees. Transferring block ownership preserves addresses and `parent`; the new owner neither becomes the lexical parent automatically nor gains an implicit application reference to every adopted object.

Liveness follows reachability, not block-list membership. Roots include the Message root, active structural arguments, retained own fields, results, formal/dynamic input references, continuations and explicitly retained application/service references. Tracing follows typed graph edges, necessary parents, Array-to-backing links and reference-valued elements. The auxiliary name index is not a root.

Live nodes and descriptors do not move merely because storage grows. Explicit graph assignment can replace the fragment selected by a structural cell; an old reference to the displaced fragment is not automatically a reference to its replacement. Descriptor stability and L3 descriptor-plus-index Array references retain their own contracts. Lexical exit does not destroy a reachable returned object; return requires no hidden copy or tree promotion. A stable address, however, does not guarantee indefinite life for an unreachable object.

One local collection pass runs at each end-of-turn: determine the outcome, publish successful outgoing Messages or discard failed staging, release completed input/temporary roots, and collect the owner's arena. Ordinary return, `break`, `continue`, `retry`, `redo` and caught `throw` are not separate collection points. A surviving suspended continuation retains its references.

An adopted graph with no application-retained references can be collected at end-of-turn once temporary roots are released, except for lexically declared `independent: immutable` branches (with or without `const`): their owner retains them until the entire arena is destroyed (§23). Arena transfer does not make other graphs permanent roots. Retained failure history lives under its explicit policy. Destroying a Message ultimately releases its remaining storage; collection neither scans another mutable arena nor requires a global lock.

A foreign resource has a separate ownership, retention, release and transfer contract. `copy`, serialization and `merge` do not invent native-resource duplication. Immutability of its identifier does not extend resource lifetime. The physical collector and the allocation of an arena's records are described in [L2](L2_spec_en.md#arena).

<a id="eternal"></a>
## 23. Eternal branches and shared methods

Combined qualification `independent: immutable` establishes a sealed immutable independent branch: its root has `parent = 0`, and its contents and protected bindings are immutable. `const` may be added but is not required for address retention by `merge` or lifetime until arena destruction. Such a branch may be lexically declared inside an ordinary body, not only at a Message root. Its owner retains every created occurrence until the entire owning arena is destroyed, even if the ordinary surrounding graph later ceases to reference it. For the initial lexically known module, R0's ownership of that arena gives process-long storage. The qualification itself neither selects a global owner nor defines unloading of a future module. Neither of the two qualifications alone establishes this sharing contract.

Process bootstrap may construct a translation-known immutable typed Array of physical references to such branches and explicitly supply it to the root Message. This Array provides access to and transfer of known references; inclusion in it is not required for retention of every lexically declared branch in its arena. `merge` and Message creation neither append to nor inherit this Array automatically. Placement in the Array does not reparent a branch's lexical tree. Permitted runtime-value initialization occurs before publication without increasing the entry set.

Bootstrap may place the published branches and their sealed records in the Root Thread's (`R0`) arena through the same mechanism that creates typed Arrays in any L3 Thread arena. Process lifetime follows from explicit ownership and retention by R0, not from a hidden table, special storage class, or root-only capability. Collection does not release these explicitly retained initial ranges; a reference to a branch in another Message is an external terminal for that Message's collector and does not transfer ownership.

Membership in the eternal-branch type is established as for all other physical types: by the code in the value's record. Its sealed range remains in the explicit owner's ordinary arena; retention until arena destruction and exclusion from premature collection determine its lifetime, not a separate permanent store. Before moving a Message under a new supervising parent, check the Message hierarchy: the owner of every `independent: immutable` branch used by the moved Message or its descendants must remain the corresponding Message itself or one of its new Message ancestors. If an owner would leave that chain, refuse the move **before** changing membership or the parent reference: the former chain of mutual control would no longer guarantee the owner's arena throughout the moved Message's lifetime. A move preserving this condition is not forbidden merely because such a branch exists. This concerns supervising `Thread.parent` and arena lifetime, not structural `Lmx.parent`, the language's `node`, or lexical name visibility. These rules neither replace the type code of the record nor become a flag on each branch.

Reparenting has the explicit form `adopt: msg newParent`: `msg` is the moved Message with an executing Thread, and `newParent` is the new supervising Message with a Thread. It copies no branches and does not mask refusal. If the owner preflight fails, the operation raises the ordinary implicit failure `adopt`, handled by `catch: adopt ()`; neither `Thread.children` membership nor `Thread.parent` changes before that refusal. `independent: msg newParent` is a separate, explicit preparation: it copies into `msg`'s arena only the eternal branches actually used by it or its descendants whose owners would leave the new ancestor chain, and redirects the corresponding references to the copies. It does not reparent the Message. The copies retain `independent: immutable` properties, shared references and cycles follow one source-to-copy map, and partial publication on failure is forbidden. Branches that do not obstruct this particular move retain their old addresses. After preparation, `adopt: msg newParent` performs its ordinary preflight anew. Preparation failure raises the ordinary implicit failure `independent` without changing the published graph.

Known method records -- reusable native implementations, not callable occurrences -- may likewise be assembled explicitly into an immutable typed Array in the same arena and supplied through physical references. A supplementary index alongside the reference does not form record identity. A method stores no lexical parent; its concrete callable occurrence supplies its own Structure. Shared records remain live after a borrowing child Message terminates only while their explicit owner retains them. There is no hidden global or root method registry.

R0 retains immutable independent branches of the initial module only because it owns that lexically fixed module, spawns the initial children, and can explicitly pass their translation-known physical references. A DLL-like module loaded later has its own sealed records under its own owner and in its own arena. When `merge` encounters its `independent: immutable` branch, with or without `const`, the consumer receives the original physical reference in the result and the module remains the owner. This does not make R0 global storage. This specification does not yet define that module's unload operation or the lifetime of those ranges.

`merge` and Message creation retain explicitly supplied references to admitted eternal branches -- under the qualified-branch exception ([composition](#composition)) -- and to reusable native method implementations as terminals; an ordinary mutable callable occurrence and its lexical context are not shared this way but copied. Receiving one branch does not expose its retention Array, root settings or unrelated branches. Mutable state is still copied separately. Every reference within a published eternal branch must have sufficient lifetime; qualification does not make an arbitrary reference to reclaimable storage eternal.

For example, A and B constructed from A's template can have the same eternal E address and distinct mutable x cells -- the intended eternal-branch exception, not an aliasing defect. Finishing A and B does not release E. Equal contents of separately constructed branches do not imply automatic interning. Across processes a native address is not wire identity: an explicit codec is required.

<a id="messages"></a>
## 24. Message, actor and serial turn

A Message is an isolated graph with its own ownership. A plain template or letter is non-executable and may exist as a standalone minimal `LmxMsg`. An executable object is instead constructed as an L3 Thread from the beginning. Its `LmxMsg message` is the first member by value, so the Thread and its Message prefix have the same physical address. This common prefix supplies Message identity and operations only; it does not turn every Message into a Thread or put mail, scheduling, turn mode, or other Thread mechanisms into `LmxMsg`. A standalone Message cannot later be upgraded in place to a Thread. The type code of the record distinguishes standalone Message storage from Thread storage: the generic Message kind admits both, whereas access to the Thread-only tail requires the exact Thread type. Receiving a letter does not automatically create a thread or actor. Launching a separate child requires an explicit operation.

Creating an `lmx_message` or `lmx_thread` places in its own arena only the data and physical references explicitly supplied by the creating operation. Parent state, bootstrap tables, method Arrays, eternal branches, and service references are neither copied nor inherited implicitly. An ordinary L3 Thread can retain and use everything available to R0 when those values are supplied explicitly.

An executing Message has FIFO mail and at most one active turn at a time. A turn consumes at most one admitted input. Different Messages may execute concurrently. An empty mailbox does not finish a background task: its mechanism keeps checking mail according to its execution mode until a stopping condition.

During a turn, one L3 Message executes on exactly one OS thread; transfer to another worker is allowed only between turns. An L3 Thread has no execution mode: each call's path is set by the callable occurrence's descriptor -- with a native address the call executes natively, without one the body (the graph's op tree) is executed by the interpreter -- L2 code with the same checks as L3 code ([§1](#scope)). One call never runs both paths for one Message: the dispatcher does not retry a call through the other path after a failure and does not override the path set by the descriptor from the body or from a previous dispatch result. Choosing the path neither copies the method nor creates a second concurrent executor; the dispatcher never runs `implements` or other receiving expressions on its own.

One arena has one writing lane. A Message's handler, local management, scheduler and service state are mutated on its own lane. A foreign sender neither appends itself to the owner's ready list nor modifies its application data. Mail admission and designated single-cell control protocols belong to the Message mechanism and grant no general access to foreign memory.

A parent manages only its direct children. Sole membership is the ordinary variable-length reference Array held by `Thread.children` in the parent's arena, and the parent's scheduler traverses that exact Array ([L2 §8](L2_spec_en.md#thread)). This runtime membership does not append fields to the source Structure. A family-record chain, manager membership queue, fixed group of slots, or any other parallel child registry is forbidden. Local traversal-order policy belongs to the parent but does not become a second membership source. Each child likewise manages its own children. There is no separate global language scheduler, shared mutable Message registry, or global management lock. A router, if needed, is itself a Message with private state.

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

A child checks parent liveness and begins its own orderly close after sustained lack of response. Forced closure from above is the second, emergency path. A parent services physical addressees from the sole reference Array of its direct children held by `Thread.children` rather than arbitrarily managing grandchildren. Each child repeats the cascade for its own child Array; closing propagates through the family instead of retaining a released branch forever.

A running child can survive parent closure only through explicit supervision handoff to another live parent with suitable authority. It retains its arena, mail and turn; supervision and scheduling placement change. This is not storage adoption. Storage transfer ends the non-executing source's separate life; new children created from adopted content belong to the receiver.

Stopped failed state may be transferred to the parent without copying and retained as failure-history graph; successful history is reclaimed by default. Transfer requires a stopped, handoff-safe source with no native users. Stop request, actual exit, safe transfer and release must remain distinct; concrete flags and placement belong to the [L2 kernel](L2_spec_en.md#message).

A participant that loses its parent closes under an orphan policy: successful completion releases it, while failure history may remain until an explicit deadline. This policy creates neither a second global registry nor an indefinite owner outside Messages.

<a id="pipeline"></a>
## 27. Incoming-message admission and execution

Incoming data pass through an explicit decoder to become a Message graph. The destination, route and receiving expression are then selected through supplied references or lookup from a supplied root. Neither Message text nor a Table reference installs a hidden environment or grants automatic trust.

Candidate admission follows the [unified mechanism](#admission): checking structural suitability for actual Consumer calls, followed by the receiving expression's required analytical checks, `test`. This incoming-admission stage operates on the constructed graph through the common execution mechanism. Interpreter-led validation does not force every checking-expression, candidate or helper call onto the walker: each reached call retains ordinary native/walker dispatch and the same binding, reception and failure contracts. Text decoding constructs the input graph before this stage; admission does not interpret source text instead of the graph.

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

In data the form `timeout: ms: int: time 500` declares a Structure `timeout`, in it a Structure `ms`, in it a field `time` with requirement `int` and value 500 ([declaring a place](#receiver-args-only)); the data path is `timeout\ms\time`, with no `int` field; in code the same form is a call of `timeout` ([the roles `data` and `code`](#data-code-roles)). An incoming formal with the same structural requirement uses ordinary `implements` and argument binding at any nesting depth, locally and through `post`. Handler-supplied `time` differs from the configured `timeout\ms\time`; there is no separate duration type system.

`post`, `send`, and `receive` use one inbox, one set of publication/ownership rules, and one call engine. The public `send`/`receive` forms (`sendMessage`/`receiveMessage` before the renaming of 2026-11-10), address-filtered iterator, all-available-mail option, and `0` end marker remain. One letter cannot be consumed twice by manual and protocol paths; receiving a letter as data does not itself execute its contents. An incoming call runs on the recipient's lane, while `answer` and outcome handlers run on the sender's lane. Both Thread modes (with and without an OS thread), the ordinary lifecycle up to user `success := 1`, final outbound publication, and existing supervision/stopping remain; `post` adds no second entry loop, inbox, or timer thread.

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

The Mix overlay places intersecting marks, cursors, attributes and intervals on the same positions. Page-value composition follows the general [contract of `merge`](#composition); it does not override neighbouring cell addresses. Disk exhaustion does not authorize automatically spilling data to an arbitrary neighbour: refusal, compaction or an explicitly authorized mirror belongs to storage policy.

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
