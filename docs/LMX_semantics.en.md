**Lingvamyxa (hereafter LMX) is a language in which a program is a lexical forest of primitive arrays connected into a dynamic graph.** This organization repeats self-similarly at the level of local actors with physical memory addressing and further at the level of remote intermachine messages with composite addressing.

**Both data and executable bodies are arrays**, represented by the same simple universal structures; every executable body is a complete abstract expression.

**Typing is analytical, at the level of lexical branches.** Admitting any candidate as an argument to any expression first checks used fields and their interfaces for actual Consumer calls; the additional analytical part (`test`) is explicitly specified by the programmer in the receiving expression. Tested candidates and checking expressions are uniquely identified by their physical addresses.

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

Static compilation may provide a native implementation for an executable Structure body, including the file root. For a Structure containing only field fillings, with no executable call or L2 operation, investigate the early optimization of omitting `native`; this does not change its graph semantics. The root has no separate generation or call rule: dispatch between native entry and interpreter depends only on whether the callable Structure occurrence has a native implementation. A Structure constructed at run time without one remains interpretable if its body belongs to L3.

LMX represents data, executable expressions, models, queries and messages. Source notation constructs Structures; a receiving expression assigns their meaning. Records, trees, configurations, schemas, tables and program bodies share the same structural basis. Registries, services, tables and Mix are families of data and receivers, not additional language levels.

Every language rule is universal within its declared domain and applies uniformly to every matching construct. A name, type, source spelling, nesting level, lowering path, or implementation convenience creates no implicit exception. If an implementation appears to require an exception, or investigation finds a contradiction between rules, the affected decision is suspended for explicit discussion; translator, interpreter, and runtime must not invent workaround semantics.

L3 retains graph mutation, structural calls, tables, messages and local actors. Low-level address operations, raw memory access, raw machine interfaces and explicit low-level synchronization belong to [L2](L2_spec_en.md). The level distinction does not by itself establish computational purity, user authority or a separate security system.

A file extension selects its outer profile: `.lm1` selects direct L1 lowering, `.lm2` L2, and `.lm3` L3. L2 code is written under the receiver `L2:`; its record lies in the graph as written, and by it the translator and the interpreter learn the level of the code. An `.lm2` file by itself is as if wrapped in this receiver (the author's decision of 2026-11-17, [journal](../LMX_blog/2026-11-17.md#lm2-file-wrapped-in-l2)). `.lm4` and `.lm5` do not select current profiles. The file is itself a Structure: its root body is an L3 Structure executed from the start in every profile, including `.lm2`, where that body is the record `L2:` with the contents of the file; there is no `main` function. L3 is compiled into native code as L2 is, and a constructed graph of either level may be executed by the interpreter. The interpreter executes L2 code with the same checks as L3 code; an address operation that L3 does not have at all it executes with checks of its own; native L2 code is compiled without these checks (the author's decision of 2026-11-18, [journal](../LMX_blog/2026-11-18.md#interpreter-runs-l2)). That is not the only difference of the levels: L3 has data types of its own, without external address arithmetic. Access to an element of an array is checked against the current length ([index](#structure-index)); pointers to Structures and to methods do not change their numeric value arbitrarily -- they are assigned only to one another and nulled; pointers to data are wrappers (the author's clarification of 2026-11-17, [journal](../LMX_blog/2026-11-17.md#l3-own-types)). A suitable entry in call tables selects native execution; in its absence the interpreter executes the body. The rule that native execution is enabled only inside methods is withdrawn. A Thread has no "interpreted / native" modes -- the registered native variant for the particular call or the walker is selected; known native calls lower directly to C. The value of executing a file (its exit code) is the value of the root body's last evaluated expression; the root, like every callable Structure, declares no result, and `return` in it is bare only. A service profile may select an explicit function, `start`, a handler or a message send. The entry point receives control after its environment and runtime graph are prepared.

The model supports interpretation of the constructed graph and translation preserving the same semantics. The interpreter executes the constructed graph, not source text and not L1. The interpreter's implementation does not expand the language of the interpreted program. L2 defines machine mechanisms, L3 defines high-level programs, and L1 is an intermediate lowering stage toward C99. The parser, graph interpreter and translator serve different purposes. Grammatical forms, body boundaries, literals, comments and normalization are defined in the [grammar specification](LMX_grammar.en.md).

The levels relate as sets: L3 is a subset of L2. A named Structure and an anonymous Structure always belong to level L3; L3 has no L2 operations requiring a machine address, address arithmetic, raw memory or `c.*`: code with them is written under the receiver `L2:`. The `@` spelling of any depth is admissible in L3 both as a reference-declaration receiver and as an operation obtaining a reference to a resolved value, provided it neither computes nor changes a machine address. Machine operations on addresses remain in L2. A Structure graph built from any profile is admissible to the interpreter.

<a id="l3-receiver"></a>
### L3 receiving expression

The L3 receiving expression defines the contract for consuming a constructed graph as an L3 program. It determines the supported subset and the selected profile's entry point; the mere presence of a syntax tree does not establish program admissibility. An unsupported operation does not become admissible because a machine implementation address exists. A restricted execution profile must explicitly report an unsupported construct rather than silently skip it or execute it as L2. This profile restriction does not replace the [single candidate-admission mechanism](#admission).

The walker executes the current binary graph rather than source text. The head of a written Frame is a word primitive: a cell with the pointer to the single reused string of its spelling; the walker recognizes the receiver by comparing the address of that string with the address of a language word's string (the author's decisions of 2026-11-08, which replaced the spelling codes of 2026-11-07; [journal](../LMX_blog/2026-11-08.md)) -- without a separate opcode in the graph, without numeric codes and without reading the bytes of spellings. Once the head is recognized, operands and data places are found by name through the service tables of the current traversal and then by graph addresses; those tables are kept nowhere outside a traversal. The translator consumes the same built graph and resolves the same head when generating code; completed `native` needs no name when invoked, as specified under [names and paths](#fields). A high-level operation may have an explicitly selected machine implementation with an L3 contract, as described at the [numeric/machine-operation boundary](#mathematics); this does not authorize arbitrary `c.*` calls from the interpreted program.

The head's name is not stored inside a Structure as a tag: the head is a field of the Lmx referring to a word primitive with the address of the single string of its spelling; the walker recognizes the receiver by that address and applies its contract to the argument Structure. The address of the spelling's string is the head's name itself, shared by all its uses; service operators and receivers (`for`, `=`, `**`, `fn`, `merge`) have no separate codes -- the same string addresses (the author's decision of 2026-11-08). A separate numeric operation code neither replaces this head nor establishes execution semantics; subsequent links remain physical. Compilation may use numeric codes as its own internal lowering labels, but they are not a required part of the L3 graph or another way to determine a receiver's meaning.

A function's name follows the same rule as every other name: the external namespace keys it by the address of an existing owning field, while the written `fn` receiver is keyed by the method occurrence's own address. Neither is stored as an Lmx field. When constructing a result in L2, the resolved receiver selects the corresponding typed arena pool; this creates no second graph and does not replace classification of the written head. The pool of `fn` results receives precisely the Structure produced by executing the receiver. Merely declaring a similar record inside `data` does not place it in the `fn` pool; data is not classified by its field names or apparent shape. Likewise, a graph Array remains a Structure with the common `Lmx` base, while its pool determines the Array variant and element type. Field access after head recognition uses addresses, without another lookup of field names.

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
`sys\capacity`, `sys\resize`, `sys\reserve`, `sys\typeof`, `sys\toLmx`, `sys\fromLmx`, `sys\assert`.
`length` stays globally available by the author's decision; `parent` remains ordinary structural navigation.
Lmx header fields are parent/length/storage; neither native nor capacity is in the header.

Checks return diagnostics and use the working builder's code. They execute neither the inspected program,
initializers, nor user test. `sys\translate(S)` lowers a Structure to **L1 text**, returning an ordinary
Structure with `l1` and `errors`; on errors there is no completed L1 result. This is not LMX output:
`sys\toLmx` serializes current graph state and `sys\fromLmx` parses LMX. Translate neither installs native
nor executes S; it performs necessary checks through shared code without a required separate check call.
The builder is the initial implementation; needed parts move into runtime for these concrete operations,
without another builder, universal wrappers, or extra states.
This is an [M14 implementation task](../next_core_tasks_v3.md#graph-tools), not a claim of availability.

Compilation is the entire explicitly requested chain: clean-graph construction and checking, lowering to L1
and C, machine compilation, and registration of resulting entries. `sys\compile(S)` applies it to selected
root S and returns the result and diagnostics through the common mechanism; failure installs no new native.
It does not execute S or run automatically on a write. `sys\translate` still returns only L1.
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

[Sol task](../next_core_tasks_v3.md#graph-tools).

### Receivers parent, length, sys\native, sys\storage

These ordinary non-declaring receivers accept one Structure S, including an Array, or operate without an argument:

| Call | Result | Without an argument |
| --- | --- | --- |
| `parent(S)` | S's structural parent, the value of header field `parent`; 0 at a root | `parent()` — `parent(data)` |
| `sys\native(S)` | S's native descriptor from call tables, including signature variants; 0 when absent; reading does not invoke it | `sys\native()` — `sys\native(data)` |
| `length(S)` | The number of immediate Structure fields or Array elements, the value of `length` | `length()` — `length(data)` |
| `sys\storage(S)` | The pointer to element storage, the value of `storage` | `sys\storage()` — `sys\storage(data)` |
| `sys\capacity(S)` | Capacity in elements from the arena table keyed by S's address | `sys\capacity()` — `sys\capacity(data)` |

Here `data` is the current launch's data. An inline control receiver's body does not change it; an independent `call(D C)` supplies data D and code C. `parent(code)`, `sys\native(code)`, `length(code)` and `sys\storage(code)` select the code explicitly. The colon form has the same contract, for example `parent: S`; a bare atom `parent`, `native`, `length` or `storage` does not invoke a receiver.

In the role of `code` the receiver executes; in the role of `data` a same-headed structural form remains data. With one occurrence, `data\parent`, `data\native`, `data\length` and `data\storage` select the written Structures just as `data\for` does; repeated names require the ordinary occurrence index. Paths gain no header pseudo-fields. A direct data pass executes only root-level declaration receivers; code passed to such a receiver may execute under its general contract ([rule](#data-root-declaration-execution)).

In Lmx's physical header the former `size` and `data` are renamed to `length` and `storage`; the final order is `parent/length/storage`. Native descriptors reside in call tables in the Thread's arena; capacity resides in another table of the same arena. During execution `data` and `code` remain accessible as the Structure fields/arguments of a `call` launch, under the existing visibility rules. Their meaning is separate from the storage pointer. `node` keeps its existing contract as the reserved activation context, unchanged throughout nested bodies; no `node(S)` receiver is introduced.

Reading parent/length/storage accesses its header field directly; native/capacity use their corresponding tables. None of these queries constructs an auxiliary descriptor. `sys\descriptor` below returns addresses of actual fields for explicit writes. [Author's decision](../LMX_blog/2026-11-15-explicit-compilation.md#arrays-native-proposal); implementation remains open in [M13](../next_core_tasks_v3.md#flat-lmx-descriptor).

<a id="get-descriptor"></a>
`sys\descriptor(S)` and `sys\descriptor: S` select an explicitly supplied Structure. With no argument, `sys\descriptor()` and `sys\descriptor:` equal `sys\descriptor(data)` for the current launch's data, including inside nested control bodies; code requires an explicit argument. In data, a same-headed form remains an ordinary Structure. Both variants return the selected Structure's field addresses under the same contract. [Author's decision](../LMX_blog/2026-11-13-get-descriptor.md#descriptor-current-data).

Ordinary receiver `sys\descriptor: S` returns a Structure d containing addresses of S's three actual header fields: `parent`, `length`, `storage`, in that order, without nested VoidArray. Address types are `Lmx **`, `size_t *`, `void **`. `\(d\length) := n` directly changes S.length; `d\length := p` changes only the pointer inside d. These are live field addresses, not a copy or proxy. A direct length write does not allocate storage; `sys\resize` performs coordinated resizing. The descriptor neither extends S's lifetime nor transfers ownership. Native and capacity are not its fields; `S\native` selects an ordinary field if present. [L2 contract](L2_spec_en.md#get-descriptor), [M13](../next_core_tasks_v3.md#flat-lmx-descriptor).

Pointer depth and Array rank are independent arbitrary finite quantities; the language has no fixed limit. Taking an address adds a pointer level and dereferencing removes one. An explicit write through `S\field` or a typed dereference follows the place's general requirement, including references and function pointers. Restrictions on assignment through a bare Structure or function name and on implicit external lookup do not prohibit such explicit writes.

An Array is an ordinary graph Structure with its own structural `parent`; receiver `[]` supplies its elements and their storage type rather than creating a separate family of language objects. An Array contains elements of one type. Its length counts Array elements, while the containing Structure's field count counts its direct fields. An Array of references to Arrays differs from a rectangular multidimensional Array. Nesting `a: b: c: d: ...` is the general form of receiving-expression application and has no fixed depth limit. `[]: []:` applies the ordinary Array receiver through that general form; it is not a separate construct or a special array-of-arrays type. An Array element may be a primitive or a reference to a nonprimitive value under the ordinary storage rules; each independent Array has its own length. The C-like head `[][][]` denotes a flat rectangular multidimensional Array and is unrelated to composing separate `[]:` receivers. Dimensionality is not recovered from physical storage. An intermediate Array can be bound to a name through ordinary typed binding: for `[]: []: []: a`, the steps `[]: []: b a[i]` and `[]: c b[j]` each index one independent Array without copying a nonprimitive value. Direct access through multiple Arrays uses the ordinary path `a[i]\[j]\[k]` ([paths](#fields)), not adjacent indices of a flat Array. For example, `char: []: []: mainArgs` uses the same general nesting for an Array of strings: each string is an independent `char` Array of exact length `len` without a trailing NUL (`LmxCharArray`, [L2 §5](L2_spec_en.md#method-array)); NUL belongs to the `c.*` door representation, not the graph value. Representation and address-range cell classification are specified in [L2](L2_spec_en.md#type-by-range).

An empty Structure is a present value with zero fields. It differs from an absent field, numeric zero, and `void`, which denotes no primitive-cell content. A Frame's argument list is itself a Structure; an anonymous Structure in it remains a distinct value also when it alone occupies the entire list: P0 does not unwrap it, whether it is empty or not (author's decision of 2026-11-10, [journal](../LMX_blog/2026-11-10.md#p0-no-unwrap)). Thus in the parse tree `f()`, `f:`, and an explicitly closed empty vertical body are one tree with an empty body, `f: ()` and `f(())` are one tree with one field, an empty Structure; `f(a b)` and `f: a b` are one tree with two fields, `f((a b))` and `f: (a b)` one tree with one Structure field. This is said of the tree only; in the clean graph the form lies as it is written, too. What a form does is determined in translation and interpretation -- by the role of the form ([the roles `data` and `code`](#data-code-roles)) and by the kind of the receiver ([two kinds of receivers](#two-kinds-of-receivers)). In a call of a callable and of a receiver that takes its arguments as `code`, the four forms `f: a b`, `f(a b)`, `f: (a b)` and `f((a b))` are one and the same call: the sole Structure among the arguments is unwrapped, once and only when the call is processed ([whole argument Structure](#whole-arguments)). A receiver that takes its arguments as `data` receives exactly what is written; in the role of `data` the forms do not change either, and nothing is unwrapped: `f: (a b)` declares `f` with one anonymous Structure inside it, while `f(a b)` and `f: a b` declare a Structure with the fields `a` and `b` (the author's clarification of 2026-11-18, [journal](../LMX_blog/2026-11-18.md#tree-is-not-the-call)). In M8, slice 366, the unwrapping postpass and the rejection of bare `f:` are removed; prepared consumers read the retained group by contract. Acceptance and the remaining M11 limits are in the [witness](../steps/witnesses/m8-preserved-groups-20261113/notes.md); see [empty bodies](LMX_grammar.en.md#empty-colon).

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

Source entity names are not stored inside graph cells. A primitive or Lmx name comes from the address → name table; name is the address of the one canonical string for that spelling in the typed arena. Identifiers, service operators and receivers are compared by those string addresses, without separate numeric codes. Atom is a parser term; the physical exception to Lmx is a primitive. The walker recognizes a written head by its canonical pointer, while the translator consumes the same clean graph and emits native. The name table stores neither variable resolution nor prior traversal state: each traversal creates and discards its own namespace. Graph copying transfers names for copied addresses, interning spellings at the receiving boundary. Anonymous and positional values need no synthetic names. The physical model is specified in the [implementation specification](kernel-implementation.en.md); current-graph serialization is defined by the [sys\toLmx contract](#source-codec).

The author's decision of 2026-11-07 on a numeric code of a spelling ("every identifier is represented by the code of its spelling; the same spelling anywhere has one and the same code; a new spelling receives the next code by a plain increment; native code and the interpreter match identifiers by code only; there are only two tables, code → name and name → code") is **superseded** by his decisions of 2026-11-08 ([journal](../LMX_blog/2026-11-08.md)); its implementation by slice 302 (codes in the registration of occurrence names, the place tables, the activation bindings, the binder of named actuals, the path selectors and the throw keys) is a landed intermediate result, and slice 308 was stopped before landing. The current norm: one spelling is one reused string with a stable address in the arena; identifiers -- heads and receivers, fields, formals and arguments, free and hidden inputs, paths, throws, service operators and language words included (`for`, `=`, `**` are the same string addresses, with no separate codes) -- are compared by both executors by the string's address, not by bytes, a hash or an incremental code; every verification goes by addresses in the arena, and addresses do not change. The name of a primitive or a Structure is read from the address → name table; a spelling is turned into a string address only at the input boundary (parsing, unit loading, `sys\fromLmx`, attaching a foreign region). The service traversal tables of the translator and the interpreter are left to the implementers, but they are kept nowhere outside a traversal -- every traversal starts clean; the built graph holds nothing but Lmx and primitives (the only non-Structure is the primitive: a typed cell whose address gives its type, name and value; the term "atom" stays with the parser); user string values are not identifiers. The design is the [kernel implementation specification](../docs/kernel-implementation.en.md); the transition is not complete.

A structural path `object\field\nested` selects graph fields in sequence. Each step's presence and validity are determined by the selected object. A computed path is not replaced by an invented statically known name. Reserved `node` denotes the lexical space above the method and stays fixed throughout that method activation; `node\field` starts explicit traversal in that space. A bare `field` obtained by lexical fallback is supplied as a hidden argument of the current activation and is not identical to the explicit `node\field` path.

A path may contain an unnamed index step `a\[i]` selecting a typed Array element. `a[i][j]` addresses a rectangular multidimensional Array, whereas `a[i]\[j]` indexes a separate Array obtained through the value of `a[i]`; `a[i]\[j]\[k]` follows further references. Index steps may be mixed with Structure fields to any finite depth. In a Structure used as `data`, `s\[N]field` with zero-based `N` selects the Nth occurrence of the name `field` at its root level: an occurrence is a form of the data that declares that name, be it a declaration by a receiver of a place or a structural form with that head; nested forms belong to their own Structures. This is not an Array step. With one occurrence, `s\field` is allowed; with two or more it is ambiguous and an index is required: a repeated declaration in data neither replaces the former one nor writes into it -- nothing is executed in data -- and stays one more occurrence (the author's decisions of 2026-11-11, [the roles `data` and `code`](#data-code-roles)). The first occurrence is not selected automatically.

The registry of the forms of `data` is built over its root level: a root-level `if:` is itself one form `if`, addressed `data\if`, and a `y:` inside it does not become a root-level form `y` -- a nested form is reached by a path through the enclosing one, `data\if\y`, `data\if\if`. The same rule applies to the other control receivers and to the forms of calls: in data they are Structures named by their heads.

`node` is a reserved language word. It cannot be declared, shadowed, rebound or dynamically supplied as a same-named value, including by quoted identifier spelling. In lowering it is literally the mandatory first `Lmx *node` parameter (`@: Lmx node` in L1): the physical reference to the lexical space above the selected method. No wrapper, closure or namespace object is inserted between source `node` and that address. In the working graph every callable occurrence, `if` body, loop and other nested Structure separately holds an ordinary `parent` link to its immediately enclosing Structure. For a callable occurrence that link supplies the above-method space passed as `node`; nested bodies may have an arbitrary internal `parent` chain, but that chain never rebinds the activation's `node` parameter. `parent` is neither a reserved language word nor a pseudo-field: ordinary receiver `parent(S)`, or `parent()` on the current `data`, reads the structural link ([contract](#header-receivers)); lexical and dynamic visibility continue to use structural links. A bare `field` supplied as a hidden argument is local with respect to the caller and the above-method space. Assigning that name (`field := value`) updates this local value and creates no field, neither during execution nor by the translator preallocating one; nothing is written into the hidden argument's source, and no method state arises from it ([working state](#dynamic)). A declaration in data defines a graph field; a declaration in code defines a call-namespace local place without write-back. Mutating the above-method graph requires explicit `node\field := value`.

| Name | Where it exists | Meaning |
| --- | --- | --- |
| `node` | reserved L3 word and first method ABI parameter | space above the method; fixed for the whole activation, including nested bodies |
| `data` (`var` until 2026-11-11) | reserved name of an explicit reference to the data of a launch | defaults to the data of the launch; permits ordinary declaration in data and the assignment of a pointer ([rule](#ordinary-var)) |
| `code` | the code Structure accessible during execution, a launch argument | the code selected by the launch; not a physical Lmx header field |
| `parent` | a physical field of each Lmx, read through an ordinary receiver | the immediately enclosing Structure; `parent()` selects the current data, `parent(S)` an explicit S; ordinary paths select user fields |
| `self` | hidden ABI context only | the active Structure of this call; not a language word |

Execution retains the physical reference to the active Structure (§12). This is hidden ABI context, not a new source name `self`, a second data graph or a replacement for reserved `node`.

Graph-field names and call-namespace variables are distinct. All same-named data declarations remain; ambiguous names require an occurrence index. The call namespace is prepared from root declarations in `data` and `code` without visiting nested branches or graph references. A new branch-local name is visible at its own level and in descendants, not outside. Re-declaring an already visible name in code uses its existing local cell; the call and assignment in `int: x bump()` remain. See [call frames](#call-frame-20261115).

For example, `int: y give()` declares the named place `y`, a graph field in data and a local in code: computing its initializer when the source act executes does not turn `y` into a separate output place. A receiver form is read by the role: in data it declares the place, in code it checks the type and assigns on its own line ([the roles `data` and `code`](#data-code-roles); the executor's reading -- [answers](../LMX_blog/q/fable-self-answers-20261110.md), Р12 and Р15). A later `int: y 7` in code writes the same local cell; `int: y` with no value only checks its contract and performs no write.

A call creates a new namespace. Nested control bodies in that call do not create an activation, but new local names belong to their lexical branch. Re-declaring an already visible variable creates no second C variable. This does not collapse repeated declarations in the source graph. Root preparation neither lifts branch declarations nor completes `data` with `code` fields.

A Structure's initial field count and order follow construction and lexical order; native-emission order does not authorize rearrangement. Updating an existing field replaces its stored reference without appending an occurrence. Structure and Array<@> share explicit resizing through sys\resize and sys\reserve; length changes only through an explicit size operation or explicit header write, not implicitly on an element store. See [variable Arrays](#array-capacity).

<a id="descriptions"></a>
## 5. Explicit value descriptions and conversions

A value description is an ordinary explicitly accessible Structure. A receiving expression obtains it through an argument or reference. It is not secretly attached to every primitive and is unnecessary for determining a physical type from an address. Names such as `class` and `class.range` denote a particular profile's data, not mandatory global language entities.

The conversion table defines relations between primitive values and their descriptions, not between every pair of Structures or their names. Distinct Structures `A` and `B` share the physical `Lmx` representation in the arena's typed arrays ([L2 §3](L2_spec_en.md#type-by-range)); a name or field composition creates neither a separate physical type nor a one-element array. Whether `B` satisfies requirement `A` is determined by `implements` relative to the Consumer, not by a `B → A` conversion row. Obtaining or transferring a Structure reference likewise requires no converter for each model. Shared physical representation does not remove structural admission, qualifications, or the distinction between a Structure reference and a reference to a reference cell.

A description separates its semantic contract from architecture binding. The contract defines meaning: count, integer, rational, profile-precision number, complex value, atom, address, opaque resource or absence of content. The binding defines width, signedness, range and target spelling. Equal representation does not imply equal contracts: `Boolean` and `int8` may share storage while admitting different values.

Ordinary description fields include `cell`, `semantic`, flags such as `numeric`/`integer`/`floating`/`reference`/`opaque`, `width`, `signed`, `range`, `spelling` and `convert` keys. The profile chooses field names. A range declaration is contract data; satisfaction is established through the [single admission mechanism](#admission), not by the field's presence alone.

The numeric contract chain is flag → nonnegative integer → integer → rational → profile-precision number → complex number. Nonnegative integers include zero. Machine `double` is not the set of all real numbers. Atoms, addresses and opaque resources are separate contracts, not rungs of this numeric chain. `unit` is an empty Structure; `void` denotes no cell content.

Descriptions are composed with ordinary `merge` under the common [occurrence-order rule](#fields). Fields such as `width`, `range` or `spelling` do not automatically create arithmetic methods. Such operations are callable expressions. For example, `u32` combines a nonnegative integer contract, 32-bit representation and range 0…4294967295; `FILE` describes opaque resource identity. A `FILE` word alone does not establish that reading or closing is valid: such requirements are expressed through paths of a `File` Structure.

A converter is an explicitly selected receiving expression. Its key comes from explicit descriptions and their composition; there is no hidden search over pairs. Suitability checking does not run the converter; an action requiring conversion performs the selected call. A repeated declaration of a key in one Structure is read by the role ([the roles `data` and `code`](#data-code-roles)): in data it is one more occurrence of the name -- it neither replaces the former one nor writes into it, and after it the key is addressed only with the index of an occurrence ([names and paths](#fields)); in code a repeated declaration by a receiver writes into the already declared place after the type check and creates no second field. Composition writes a later operand's same-name key into the model's slot. If a table has several rows with one key, the table operation's own policy selects the row ([tables](#registries)).

Numeric conversion preserves the destination-range contract: `u16(255) → u8` is admitted when the converter exists, while `u16(256) → u8` produces a range error, not zero. Rounding `1.5 → i32` and in-range precision loss require explicit numeric-profile rules. Proven range inclusion may eliminate a redundant machine operation while preserving the semantic requirement. Format, range and converter-behavior failures are not replaced by a positive `implements` result.

<a id="conversion-context"></a>
## 6. Message-local type bindings and conversion context

Each executing Message has one context of type descriptions, symbolic bindings, and conversions. It consists of ordinary Structures and references explicitly supplied when the Message is built or reachable from them. Message creation, sending, and parenthood do not implicitly pass the parent's context. There is no built-in process-global registry, implicit type environment, or hidden converter search.

### Stable bindings and structural genericity

A symbolic type name is bound once for a Message and resolves consistently at every use, including arguments and results; each call does not instantiate it anew. Another Message may bind the same name differently. This is a relation within the context, not another runtime name space.

Structural genericity is the ordinary case of [admission](#admission): a Consumer requires only the paths, operations, and contracts it uses. It needs no separate generic template. A symbolic binding is needed when multiple positions must share one stable type relation, not merely to declare genericity.

### Conversion at consumption

The reachable conversion table concerns primitive descriptions, including explicitly supplied semantic quantities and units; it is not a Structure-compatibility catalog. Another primitive description is admissible only through a conversion available in this Message and allowed by the Consumer's contract. The first part of admission, suitability checking, does not execute a converter. At actual consumption it executes as an ordinary callable with checks for range, representation, precision, and semantic conditions. Structural success does not permit reinterpretation of primitive storage without such a conversion.

Before a call, each converted actual argument must satisfy the selected callable's actual descriptor; afterward its result is converted separately to the Consumer's requirement. A converter absent from the reachable context is not replaced by a hidden chain or process-wide search. An implementation may cache resolved bindings and routes only while preserving the result of explicit resolution.

Expanded [Message-context examples](LMX_semantics_guide.en.md#message-conversion-context) are kept outside the normative text.

<a id="admission"></a>
## 7. Used interface checking and test

Candidate admission has two parts: checking used fields and their interfaces for actual Consumer calls through directional `implements`, and executing the receiving expression's explicitly specified checks against the constructed graph. The first part does not require full interface conformance; all additional analysis is chosen by the programmer in `test` ([author clarifications](../LMX_blog/2026-10-26.md)). No implicit checks of future values or behavior are added "just in case". Address classification identifies a value's physical representation but does not replace admission.

The first, interface-checking part of `implements` is performed once for each candidate: when the clean graph is built if the candidate is then known, or at run time if the candidate is selected dynamically. Graph construction performs only this first part; it does not execute `test`. For a dynamic candidate, `test` is the second admission step (the author's clarification of 2026-11-13, [journal](../LMX_blog/2026-11-13.md#implements-and-test-phases)). Cases of run-time candidate selection are collected in a [separate document](../steps/implements-runtime-cases-20261111.md); this clarifies the decision of 2026-11-11 on [the roles `data` and `code`](#data-code-roles).

<a id="analytical-tree"></a>
### Used interface checking

<a id="three-argument-implements"></a>
#### `implements(aVar, bVar, Consumer)`

`aVar` is the candidate, `bVar` describes the required role, and `Consumer` is the concrete receiving expression. With Consumer, its known accesses to `bVar` in every visible branch are considered; unused fields of `bVar` are not compared. Without Consumer, the explicitly stated requirements of `bVar` are checked, not an empty access set. Narrowing the search through required fields and requirements may proceed to any necessary depth. An unknown computed path is not reported as checked, but uncertainty alone is not grounds for prohibition: an incompatibility error is issued only for a requirement that is guaranteed to be unsatisfiable.

A used path requires a corresponding candidate field and interface compatibility with its actual consumption. If Consumer explicitly invokes a field, only the written calls are checked: actual and named arguments, defaults and available conversions must fit the selected interface and the implementation's actual descriptor; the declared result and declared exits must meet Consumer's requirement. This checks interface compatibility, not a future result's value. Opaque transport of a callable does not check future calls. Merely transporting a primitive leaf proves nothing about its value; explicit tests check substantive properties.

Used interface checking executes none of the candidate, Consumer, method or converter and adds no analysis of future behavior. It establishes compatibility for this Consumer, not equality of Structures or suitability for every future consumer. A positive result maps each used model field to a physical candidate field, possibly at another position. This is a **general** map for any admitted pair of Structures, not a table specific to methods, `data`, or `call`. Explicit structural reading, writing and taking addresses through the admitted correspondence use these physical places; access to those mapped fields performs no further name lookup ([L2 §14](L2_spec_en.md#implements), [L1 §15](L1_spec_en.md#implements)).

<a id="correspondence-stability"></a>
#### Preservation of established correspondence

Named receiving places use the ordinary admission contract. For `S\x := value` and `S\[n]x := value`, the field requirement is checked during clean-graph construction where it and the candidate are known. `S[n] := p` is a `void*` array write, identical for a Structure and `Array<@>`. It inherits no name, type, or requirement from the previous content and performs no field admission. Subsequent structural access interprets current graph content. No table of former physical-slot requirements is needed for this write; the slice380 restriction is superseded by the [2026-11-15 decision](../LMX_blog/2026-11-15.md). Admission still applies where a value is actually received against a description.

<a id="argument-compatibility-stage"></a>
Translation checks only requirements needed to generate correct C and obligations imposed by explicitly written throws/catch. Language compatibility of actual arguments and receiving places is checked by the shared implements admission: once when the clean graph is built -- where the candidate is known at construction -- and at the reached call or pointer assignment -- where the candidate is selected while the program runs (the author's decision of 2026-11-11, the paragraph on admission above); an assignment of primitives is not checked for admissibility at run time (the rule speaks of the admission `implements`, not of conversion: the range check on receiving a number of another type, `u16(256)` into `u8`, remains at run time; see the [admission recipes](#admission-recipes)). A known method name does not prove the type of the current binding. An established address map persists under the rule above; this neither removes reception of a new actual value nor reruns every test on each write. Conversion and its checks apply to the particular received value. For call: data code (as for the by-name form `S(D)`, which acts as `call(D, S)`), required places in the actually selected data are checked at admission of that call -- under the same rule, when the clean graph is built or at the reached call; an absent place is an error of that admission, not a source-translation error. The interpreter invokes the same mechanism: it does not repeat the admission performed when the clean graph was built, and when an operation is reached it admits only a candidate selected while the program runs, without analyzing future bodies or branches. See the author clarification of [November 1](../LMX_blog/2026-11-01.md).

<a id="graph-tests"></a>
### Analytical part test

When a candidate is actually admitted at run time, the second step executes the receiving expression's explicitly specified checks against the constructed graph. A candidate known at construction has no separate `test` mode: only interface checking was done in advance, and that part need not be repeated ([the author's answer and its reading](../LMX_blog/2026-11-13.md#runtime-candidate-admission)). Graph construction does not execute `test` ([the author's clarification of 2026-11-13](../LMX_blog/2026-11-13.md#implements-and-test-phases)). If no `test` is specified, no additional analysis is imposed; an empty test set is not successful behavioral validation. Without explicit Consumer, checks specified in the receiving description `bVar` are used, not tests owned by candidate `aVar`. The first result of `0` immediately stops admission; remaining checks are not executed. Successful admission requires every specified check to succeed ([the author's answer](../LMX_blog/2026-11-13.md#test-first-failure)). Declared failures use ordinary `throw`/`catch`. Checks are an admission stage, not a watcher on every graph write.

<a id="test-receiver-contract"></a>
#### The `test:` receiver

When executed inside a Structure, `test: op checkIncrement` associates receiving place `op` with ordinary checking expression `checkIncrement`. Both names resolve as receiver arguments, not implicit calls. The name `test` is reserved; an ordinary user method may be called `mytest`. The association belongs to Consumer, not the candidate; multiple `test:` forms require multiple checks. A nested Consumer's checks are not automatically promoted to its outer Consumer.

A `test` form follows the general [rules for execution through receivers](#data-root-declaration-execution). A direct pass over `data` executes only declaration receivers at its root level; other forms, including a `test:` form among the data, do not run merely by being present. An executing receiver may reach code supplied to it, and that code may reach `test`. There is no separate pass that finds and executes `test` in nested data ([the author's clarification](../LMX_blog/2026-11-13.md#data-root-receiver-execution)).

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

An explicit path write changes the addressed shared referent; assignment to an argument or another local variable changes only the current activation's place, without write-back. [Call frame](#call-frame-20261115).

<a id="admission-case-6"></a>
### 6. Independence from another holder's mutation

Ordinary Structure or Array passing transports a reference. Explicit copying creates an independent mutable copy; immutability prohibits mutation of the protected value.

<a id="admission-case-7"></a>
### 7. Establishing that a call can proceed

Besides a suitable callable interface, the call needs a source for each of its free (dynamic) inputs. The declared input places of `data` are optional: an input without a value, to which no value is supplied, does not make the call refuse and holds "T without initialization" (the author's decision of 2026-11-16, [journal](../LMX_blog/2026-11-16.md#optional-inputs-required)); the receiver [`required`](#required-receiver) checks that a field is initialized.

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

Source notation constructs the complete Structure graph: values, declarations and executable expressions remain in the same graph. A block is closed by indentation, as in Python, in every block, inside brackets included; a closing word is needed only for a jump of more than one level ([grammar, §15](LMX_grammar.en.md#levels)). Constructing a body description does not execute that body. A named Structure is declared by a form of data and is not executed on declaration; the same form among executed ones is a call of its head ([the roles `data` and `code`](#data-code-roles)). An anonymous body in execution position runs under its receiving expression's contract. No separate data graph, hidden wrapper procedure or persistent auxiliary context is created. The declaration site determines the lexical parent; an independent root has none (parent = 0). The binary representation retains comment text; occurrence names are recorded in the address → name table as addresses of canonical strings under the [name rules](#fields). Comments do not execute; the walker recognizes a Frame head by the address of the canonical string for its name, after which the graph and resolved addresses apply. Generated `native` does not need the name when invoked.

### Head resolution and the role of the tail

A receiver applies its contract to its arguments: for example, it declares a place or constructs a callable expression. Its execution follows the general `data`/`code` role; the word “receiver” does not restrict the action to translation. They share the Frame syntax "the head consumes the tail", not a semantic role. General resolution and the receiving head's contract determine the head's role and the meaning of its arguments. A name in a receiver's arguments does not thereby become another call: `catch: merge ()` supplies catch with the failure name and parameter description, just as `fn: mytest ()` supplies fn with the name and signature description. These are consequences of the common rule, not exceptions for those receivers or names.

<a id="resolved-head-consumption"></a>
#### One model, one resolution, one consumption

First, the complete written structural head/arguments model is formed in translator memory, without knowing what the head denotes. Neither its name, signature, nor entity category determines that model's boundaries or permits collecting additional arguments. Only after the model has been formed is the form read -- by the role of the Structure in the launch ([the roles `data` and `code`](#data-code-roles)): in data it declares -- a place when its head is a receiver of a place, otherwise a Structure; in code it is a call, and the common resolution algorithm in the single namespace finds its head -- a receiver, a callable or a Structure. Such a form does not write a value into a known place ([structural forms](#forms-declare-or-call)). One common consumption mechanism applies the resolved entity's contract; differing contracts do not create separate parsers, namespaces, or resolution routes.

<a id="data-code-roles"></a>
### The roles `data` and `code`

The author's decision of 2026-11-11 ([journal](../LMX_blog/2026-11-11.md#data-code-roles)). A Structure takes part in a launch in one of two roles -- data (`data`) or code (`code`) -- and one and the same written form is read by the role. The launch gives the role, not the Structure itself: `call` and `fncall` receive the data and the code as separate arguments; for `fn`, `sub` and `catch` the data is the part `data` and the code is the part `code`; `call(code)` runs a Structure that is its own data ([the receivers `call` and `fncall`](#call-receivers)); in code an ordinary Structure is also launched by a form with its name as the head (the author's decision of 2026-11-11, [journal](../LMX_blog/2026-11-11.md#structure-call-by-name); more below): `S(D)` is the same as `call(D, S)`, with the data `D` and the code `S`; `S()` is the same as `call(S, S)`, the Structure over itself.

In the role `data` a structural form declares a Structure -- whatever its head is. A written call and the control receivers (`if`, `for` and the others) are Structures in data too, named by their heads, and are addressed by the general rules of paths: `data\if`, nested ones `data\if\if`, with the index of an occurrence when several bear one name. Declarations by the receivers of places -- `int`, `@` and the rest -- act as well: `int: x 5` declares a variable, `@: ptr KnownStruct` a pointer variable. Assignments `:=` and all other code are not executed in data; an assignment stays a field that an index reaches. A repeated declaration in data is one more occurrence of the same name, not a replacement of the former one and not a write into it: after `Model: KnownStruct` and `Model: KnownStruct2` the name `Model` is addressed only with the index of an occurrence, `data\[index]Model`, and an access without the index is an error ([names and paths](#fields)).

<a id="data-root-declaration-execution"></a>
#### Direct data traversal and receiver execution

Clean-graph construction folds declarations with ready values through the common mechanism, without program calls. Call-namespace preparation notices declarations only at the roots of `data` and `code`; it does not execute computed declaration code early. The receivers `private`, `required`, `const`, `immutable` and `independent` execute here, and the variables passed to them count as root-level ones -- in any combination of these receivers (the author's clarification of 2026-11-18, [journal](../LMX_blog/2026-11-18.md#marking-receivers-execute)). It traverses neither lexical branches nor graph reference edges. A reached receiver may execute code passed to it under its ordinary execution contract; this is not direct execution of nested Structures from `data`. See [call frames](#call-frame-20261115).

Executing a receiver opens the ordinary path to executing code supplied to it. The receiver's contract determines how it consumes its arguments; placing the receiver form in `data` does not prohibit this path. Thus, “other code is not launched directly from data” does not mean “no code can run while a declaration receiver is executing”. This is general behavior, including a `test` reached this way, not an exception for a name or location ([the author's clarification of 2026-11-13](../LMX_blog/2026-11-13.md#data-root-receiver-execution); [example](LMX_semantics_guide.en.md#data-receiver-execution)).

#### Forms in the code role

In the role `code` every written form is a call. A declaration by a receiver is a call of the receiver: `int: i 6` checks the type and assigns the local place `i` in the call namespace ([structural forms](#forms-declare-or-call)). A structural form is a call of its head: `Model: KnownStruct` in code calls `Model`: a callable is called, and an ordinary Structure is launched over `KnownStruct` as data, `call(KnownStruct, Model)`; if `Model` names neither a callable nor a Structure, it is an error; a second such form is one more call. There are no declarations of Structures in code: code uses the names of the Structures of the data. The declarations of callables -- `fn`, `sub`, `catch` -- stay in code too: they are calls of receivers that declare. A callable declared in data is called directly, by its name, and binds its free names by the general rules -- the dynamic input first, then the lexical source ([§12](#dynamic)). In code a form whose head is an ordinary Structure launches it: `S()` is the same as `call(S, S)` (the Structure over itself), `S(D)` is the same as `call(D, S)` (the Structure over the given data `D`); so are the short form `S: D` and the block form (the author's decision of 2026-11-11, [journal](../LMX_blog/2026-11-11.md#structure-call-by-name); the executor's reading -- [answers](../LMX_blog/q/fable-self-answers-20261110.md), Р21; before this decision such a form was refused in code, and an ordinary Structure was executed only by the receiver `call`). There is one argument, and it is named `data` -- by the same name by which executable code names the data of its launch ([the special name `data`](#ordinary-var)): `S(D)` and `S(data := D)` are one form. It must give a Structure (a name, a path, a place with a reference, an unnamed Structure written in parentheses), anything else is an error; so is any other name of the argument, and so are two or more positional arguments. It is a launch form of its own, not a form of a receiver: the receivers `call` and `fncall` remain the general mechanism ([the receivers `call` and `fncall`](#call-receivers)), and actual values are supplied through the `args` of `call`, while `data` describes the formals. In data `S()` still declares an empty Structure `S`, and `S(D)` a Structure `S` with an atom `D`; nothing is called (the author's answer of 2026-11-11, [journal](../LMX_blog/2026-11-11.md#structure-head-call-refuses-in-code)). The control receivers written at the root of data cannot be named by a bare name -- the receiver itself holds it -- so they are reached by the path `data\if` or by an index. An unnamed Structure in code is not counted as a call with arguments (the author's clarification of 2026-11-11, [journal](../LMX_blog/2026-11-11.md#unnamed-structure-not-call)): a form in parentheses has no head, there is nothing to call, and it is no error. But its records are executed in place, in the current activation (the author's decision of 2026-11-16, [journal](../LMX_blog/2026-11-16.md#unnamed-structure-executes)); an example follows. To the left of `:=` it is a Structure of places: `(a b c) := myFn()` is an assignment between unnamed Structures, the general case of assignment and not a special form ([group assignment](#group-assign)); in the position of a value or of an argument it is a written Structure. The rule "an error when the head names neither a callable nor a Structure" concerns a form with a head.

```text
@: ptr KnownStruct
Model: KnownStruct
Model: KnownStruct2
ptrToModel := ptrToKnownStruct
```

The first line is a declaration by a receiver of the pointer variable `ptr` to `KnownStruct`: in data it declares the place, in code it is a call of the receiver `@` -- a check of the type with an assignment. The second and the third are two declarations of `Model` in data and two calls of `Model` in code; if `Model` is a Structure, they are its launches over `KnownStruct` and over `KnownStruct2` as data. The fourth assigns a pointer to a pointer in code and is not executed in data.

An unnamed Structure in code is executed in place (the author's decision of 2026-11-16, [journal](../LMX_blog/2026-11-16.md#unnamed-structure-executes)): in `anon` its records `int: q 4` and `r := q` run in the activation of `anon`, so `anon()` returns 4, not 0 -- the earlier reading, under which such a form was not executed, is cancelled.

```text
fn: anon () int
    int: r 0
    ---
        int: q 4
        r := q
    ---
    return: r
end: anon
```

Execution does not turn an unnamed Structure into a call of a head: it has no head and receives no arguments. An assignment between unnamed Structures, such as `(a b c) := myFn()`, is the same general case of assignment and not a special form of the language ([group assignment](#group-assign)).

An assignment acts between values: primitives, pointers to Structures and pointers to functions. The names of Structures and functions are not assigned to each other: `Model := KnownStruct3` is an error; the left side of `:=` is a place of a primitive or a pointer variable. The name of a Structure or of a function where the value of a pointer stands gives a pointer to it without writing `@Struct` ([writing a known place](#assign-known)).

The structure of the arguments of a call -- of an ordinary callable and of a receiver alike -- is built and read by the one general algorithm, as code. In `f(arg: Struct)` the form `arg: Struct` is a call of `arg`, with no other reading; if `arg` names no callable -- a launch form of a Structure at a place where a value is needed (an operand of an expression, an actual argument of a call, an initial value, an operand of `merge`) is an error: a launch has no result, and no declaration can stand there (the executor's reading -- [answers](../LMX_blog/q/fable-self-answers-20261110.md), Р22, item 3; Р25, item 4). Only `:=` gives a named argument: `f(arg := Struct)` ([named arguments](#named-actuals)). The arguments of receivers are named too, and are given by position or by name: `call(data := D; code := C)` (the executor's reading of the author's words of 2026-11-11 -- [journal](../LMX_blog/2026-11-11.md#structure-call-by-name)). Input places are described by receiver declarations, such as `int: arg default` and `@: arg Template`. A callable has one input description, `data`; the explicit launch receiver's `args` contains supplied values, and a supplied actual completely replaces its corresponding default. Final abbreviated `fn/sub/catch` headers belong to [call-frame migration](#call-frame-20261115). A place `@: arg Template` receives a Structure reference: `proc(arg := Struct)` supplies its pointer.

Names. The special name of the explicit reference to the data of a launch, the part of a callable Structure of the same name and the data block are called `data` -- formerly `var`; the part with the executable forms and the argument of the receivers `fn`, `sub`, `catch` of the same name are called `code`, formerly `body`. Since 2026-11-15 inputs are merged into one `data`; `return` where provided and `code` remain. A callable has no separate `args` declaration part; launch receivers use `args` for actual values; final header abbreviations belong to [call-frame migration](#call-frame-20261115). In the source texts of the project steps of the [plan](../next_core_tasks_v3.md#m11) replace the former spellings. Since slice 354 the clean graph reads `data`, `code` and the order `call: data code` and does not accept the former names or order; the working frontend and its fixtures still read the former names and the former order.

The interface-checking part of `implements` is performed once for each candidate: at clean-graph construction for a known candidate, or at run time for a dynamically selected one ([used interface checking](#admission)). Construction performs only the first part, without `test`; for a dynamic candidate, `test` is the second admission step ([the author's clarification of 2026-11-13](../LMX_blog/2026-11-13.md#implements-and-test-phases)). Cases of run-time candidate selection are collected in a [separate document](../steps/implements-runtime-cases-20261111.md). An assignment of primitives is not checked for admissibility at run time: the rule speaks of the admission `implements`, not of conversion, and the range check on receiving a number of another type (`u16(256)` into `u8`) remains at run time ([admission recipes](#admission-recipes)).

The decision on the roles narrows the former rules of this chapter and of the chapter on callables (except the change of the spellings `var` → `data` and `body` → `code`, of the order `call: data code` and of the moment of the admission `implements`; [journal](../LMX_blog/2026-11-11.md#data-code-roles), [order](../LMX_blog/2026-11-11.md#data-before-code)): it withdraws readings they admitted and introduces no new one; everything it does not forbid stays as it was (the author's words are in the journal). The rule "a form with an unknown head declares a Structure" acts only in data. The assignment of the names of Structures, `Struct1 := Struct2`, is withdrawn. There is no executed repeated declaration of a Structure any more: in code a second such form is one more call, in data it is one more occurrence of the name. A formal with a Structure requirement is written `@: p Point`. A name holding the result of `merge` is declared by `@: R merge(A; B)`. A Structure declared by a composition in data is named by the form `S: merge: A B` ([the two records of `merge`](#merge-two-forms)). The nested form of a requirement in the arguments of a receiver, `@: ptr Model: Other`, is a call of `Model`; if `Model` is a Structure, this is a launch form at a place where a value is needed (an operand of an expression, an actual argument of a call, an initial value, an operand of `merge`), and it is an error: a launch has no result (Р22, item 3; Р25, item 4); the requirement and the candidate are written flat, `@: ptr Model Other`. A Structure launched over itself -- `call(code)`, the same as `call(code code)`, and the root of a unit -- has no rules of its own (the author's answer of 2026-11-11, [journal](../LMX_blog/2026-11-11.md#self-launch-no-own-rules)): each of its forms is read in both roles by the general rules, and where they give no definite result it is an error. So a form `S()` in such a Structure is at once a declaration of one more `S` and a call: if `S` is declared in the same Structure, the name has two occurrences, without an index it does not answer, and the call is refused; if `S` is declared outside, the form declares its own empty `S`, and that one is launched, not the outer one. A Structure is launched by name from code written apart from the data that declare it; at the root of a unit and in a Structure over itself the same Structure is launched by the receiver `call`, whose form is not a declaration of `S`; the call of a method and of a receiver is not affected. A declaration of a Structure among the executed forms is still, as a rule, an error, but for another reason: in code such a form is a call of the declared Structure with its own tail in the place of the argument -- two or more fields in the tail are a number of arguments that the launch form does not define (the argument is one, `data`), one field is the data of the launch, and it must give a Structure. Degenerate forms are not refused: an empty tail, a single atom that names a Structure, a single unnamed Structure in parentheses. Hence declarations of Structures are written in data -- in the `data` part of a method, in a Structure the launch receives as data, in a written Structure in a value position -- and not among the executed forms (the executor's reading -- [answers](../LMX_blog/q/fable-self-answers-20261110.md), Р21). The clean graph executes these rules in part: sub-step 5а since slice 355, the first part of sub-step 5б since slice 356; the rest -- sub-step 5в and the remainders of sub-steps 5б, 5г, 5д and 5е -- not yet ([plan](../next_core_tasks_v3.md#m11)). Since slice 356 it executes the launch of a Structure by name in the code of a method and in code over given data -- `S()`, `S(D)`, `S(data := D)` -- and a form whose head is a place holding a reference to an ordinary Structure everywhere, the root of a unit included, as well as the named supply of the arguments of `call` and `fncall`; in the root of a unit and in a Structure over itself it does not yet execute the role of code of a form with an ordinary Structure as its head by name (sub-step 5г). The working frontend does not execute the launch by name (step 8).

<a id="receiver-args-only"></a>
### Declaring a place: a receiver and its arguments

The author's decision of 2026-11-10 ([journal](../LMX_blog/2026-11-10.md#receiver-args-only)). A place with a requirement is declared only by a receiver form enumerating its arguments, `receiver: arguments`: `int: i 5`, `int: x`, `@: ptr 0`, `@: ptr Model`. The composed form `name: receiver: value`, in which the outer head named the receiving place and a nested receiver built or checked its value — `i: int: 5`, `new_var: int()`, `ptr: @: 0`, `ptr: @: Model: 0` — is withdrawn: it cannot be told apart from a declaration of a Structure whose body begins with a field declaration, and it mixed with calls. `timeout: ms: int: time` would read both as a place `ms` with requirement `int` and value `time` and as a Structure `ms` with a field `time`; the second reading holds. A Structure is declared another way, without a receiver: the name, then the content. So in data `timeout: ms: int: time 500` declares a Structure `timeout`, in it a Structure `ms`, in it a field `time` with requirement `int` and value 500; in code the same form is a call of `timeout` ([the roles `data` and `code`](#data-code-roles)). The form `name: receiver: value` itself stays admissible, but it does not declare a variable with a value: in data `i: int: 5` with an unknown `i` declares a Structure `i` that has the receiver call `int: 5` inside it, by the common rule of [declaring a Structure](#colon-declares); in code it is a call of its head: a callable is called, an ordinary Structure is launched, and with a known place of a number or a null reference as its head ([structural forms](#forms-declare-or-call)), or when the head names neither a callable nor a Structure, the form is an error. The mistake of the composed form is that it replaced the meaning of structural notation: a Structure `i` with a field `int: 5` was read as "make an `int` variable out of `i`", and likewise `struct: int: time` yielded a variable `struct` instead of a Structure with a field `time`, in a description of arguments too; the rest of the semantics rests on structural notation. A receiver acts within its own arguments and does not put itself in place of its parent: a one-argument receiver of a primitive value given a name declares a variable without initialization (`int: time`), and given a value it checks that value (`int: 342348523485629384569384`). P0 does not change: it builds the same nested Frames. The project's sources and fixtures do not write the composed form. The working frontend reads it by the common rule of its head: with an unknown head it declares a Structure with the receiver's field inside (`ms: int: time`), with a known place it refuses; a Structure with a receiver call inside (`i: int: 5`, `ptr: @: 0`) is not lowered yet and is refused at the call, while the clean graph executes that one too ([plan](../next_core_tasks_v3.md#m9)).

A bare atom does not add an unwritten receiver or callable invocation. If the resolved field contains a computed declaration, an explicit path reads the record of the declaration and executes nothing ([explicit path](#path-reads-no-execution)); the written expression is evaluated by a call when it reads its local place by a bare name, and that does not call the returned callable with no arguments. The expression is formed and evaluated the same way whether its result is consumed or not; a write into a place is an effect of an unconsumed declaring form, not a special parse of the right operand. Thus `Model: 0` consumed by another expression does not change `Model`: in arguments it is a call of `Model` -- formerly it yielded a candidate under the requirement `Model`, now the requirement and the candidate are written flat, `@: ptr Model 0` ([the roles `data` and `code`](#data-code-roles)); if `Model` is a Structure, this is a launch form at a place where a value is needed (an operand of an expression, an actual argument of a call, an initial value, an operand of `merge`), and it is an error: a launch has no result (the executor's reading -- [answers](../LMX_blog/q/fable-self-answers-20261110.md), Р22, item 3; Р25, item 4); as a statement of its own on an already known place `Model`, `Model: 0` does not assign and is an error ([structural forms](#forms-declare-or-call)).

Two-field `int: x 5` declares place `x` with an `int` requirement and value `5`: in data it creates the place, in code it is a call of the receiver -- a check of the type with an assignment to the local namespace place `x` ([the roles `data` and `code`](#data-code-roles)). Unary `int: x` describes place `x` with an `int` requirement and no invented initial value: a first definition creates the place; with an already known `x` the same form in code checks its compatibility by ordinary admission without a new write or second field, and in data it stays one more occurrence of the name, which is addressed only with the index of an occurrence after that. A place without an initial value holds a value of the distinct type "int without initialization" -- not zero and not a mark outside the graph; every primitive has such a type, alike in code, data and a signature, where it distinguishes a formal without a default `int: q` from the default `int: q 0`: such a formal is not mandatory -- an input without a value, to which no value is supplied, does not make the call refuse and holds this type (the author's decision of 2026-11-16, [journal](../LMX_blog/2026-11-16.md#optional-inputs-required)), and the receiver [`required`](#required-receiver) checks that a given field is initialized; a value record is a type and a value: an assignment into such a place of the graph (`data\a := 5`) writes the value and changes the type of the record to `int`, while the address of the value stays the same (the author's decision of 2026-11-17, [journal](../LMX_blog/2026-11-17.md#assignment-changes-type); the rule of 2026-11-08 that the type of the place does not change is withdrawn; the representation is [implementation specification §3.2](../docs/kernel-implementation.en.md#lmx)). An assignment to a local of the call -- `a := 5` for a formal that received no value -- writes into the place of the call: the graph does not change and the data are not published. The absence of a value is written as a value of that separate type: `nil: T` (`nil: int`; any other primitive type in place of `int`), and simply `nil` where possible. `int: var` declares a variable without initialization, and a separate type exists for that; it was introduced for passing arguments and stays needed with `required`. A variable can be compared with `nil`: under the type there is a pointer anyway, and no separate number `nil` is introduced for it ([journal](../LMX_blog/2026-11-17.md#nil-comparison)). The graph holds nothing but Structures and primitives: a primitive is the declaration of its type with a value or with the absence of a value, and everything else is written as Structures. The null pointer stays `0` where that is possible; a pointer declared without a value (`@: ptr`) is not zero and is written with the same `nil` (the author's decision of 2026-11-17, [journal](../LMX_blog/2026-11-17.md#typed-nil)). Every receiver that used to be written without arguments in the place of a type has a one-argument form: `int: i` is written instead of `i: int` (the author's decision of 2026-11-10, [journal](../LMX_blog/2026-11-10.md#one-argument-receivers)). With `i` already declared, `int: i` in code is not an error but a check that the type conforms: repeated declarations are allowed. The one-argument form given the primitive itself instead of a name, `int: 54554878477838734`, returns the number in an expression or throws a failure that `catch` receives. In a signature these forms describe a formal, and a written value supplies a default when an actual argument is absent; describing a formal does not execute it as a body. This is one mechanism for primitives, references, Structures, and callables, with no parser branch for a receiver's name. Places and visibility are fixed before body execution; whichever branch happens to execute first cannot add a slot to an already constructed `Lmx`.

The declaring contract of built-in value/type receivers, including `int` and `@`, is `R: name value`: the first field is an atom naming the receiving place, and the second is a value or requirement expression, while `@` with a requirement has an optional third field, the candidate (`@: ptr Model Other`); without the second field the place is declared with no initial value. The resolved receiver's contract determines arity and field roles after P0; the parser neither singles out this class nor changes the tree, and other receivers retain their own argument contracts. The name atom is neither called nor evaluated as a value: the place is resolved in the same namespace as a Frame head. The candidate is evaluated once before any write, undergoes ordinary admission, and then the place is first defined or, when it is already known, receives the value in code as a repeated declaration: enumerating a receiver's arguments remains that receiver's business and can always be a declaration — `@: ptr1 ptr2` may declare `ptr1` (author's clarification of 2026-11-10, [structural forms](#forms-declare-or-call)); in data a repeated declaration does not write into the former place and stays one more occurrence of the name ([the roles `data` and `code`](#data-code-roles)). Consumption of the entire form by another expression does not itself publish a field or perform a write. `@: new_field Model` binds the reference to `Model` without adding the address depth of the `@Model` cell.

A requirement and a candidate are written flat: in `@: ptr Model Other`, `@` has three fields -- the place atom `ptr`, the requirement `Model` and the candidate `Other`; `@: ptr Model 0` gives a null address. The nested form `@: ptr Model: Other` does not serve for that: the arguments of a receiver are read as code, and `Model: Other` in them is a call of `Model` (the decision of 2026-11-11, [the roles `data` and `code`](#data-code-roles)); if `Model` is a Structure, this is a launch form at a place where a value is needed (an operand of an expression, an actual argument of a call, an initial value, an operand of `merge`), and it is an error: a launch has no result (the executor's reading -- [answers](../LMX_blog/q/fable-self-answers-20261110.md), Р22, item 3; Р25, item 4); formerly a consumed `Model: Other` yielded candidate `Other` under requirement `Model`. Admitting the candidate neither writes to `Model` nor creates an addressable temporary cell. After admission, the form builds a reference value and binds `ptr` by the common rule; the candidate is evaluated once before the write. If `ptr` is callable, the form of the receiver `@` designates `ptr` as a binding place subject to its write constraints, while `ptr: @: Model Other` in code is a call of `ptr` with an argument.

In evaluation position, a bare identifier enters the same resolution flow but does not itself form a call or supply an empty argument list. It denotes the resolved value, a reference to a Structure or callable, or a receiver name according to the receiving position's contract; bare `merge` and `int` likewise do not execute. If that position requires a value the named entity does not provide, this is an error, not a hidden nullary call or free input. Applying a resolved head requires an explicit Frame with `()` or `:` and a structural tail, possibly empty; that head's contract still determines the Frame's role. An ordinary named Structure is launched through the receiver `call: A` or, in code, by a form with its name as the head, `A()` or `A(D)` ([the roles `data` and `code`](#data-code-roles)). Neighboring atoms are not captured. In `if: p`, bare `p` is only read: even if it points to a method, that method is not called. This rule does not decide whether the value of `p` is admissible as a condition.


<a id="colon-declares"></a>
In data a form `Name: tail` whose head is no receiver of a place is a declaration of a Structure, not an assignment (the author's decision of 2026-11-10, [journal](../LMX_blog/2026-11-10.md#colon-declares-not-assigns)); in code it is a call of its head ([the roles `data` and `code`](#data-code-roles)). `Struct1: Struct2` in data declares a Structure `Struct1` with the one atom `Struct2`; the form does not make the two names equal and does not make the place `Struct1` a reference to `Struct2`. The names of Structures are not assigned: the form `Struct1 := Struct2`, which the decision of 2026-11-10 called the assignment, was withdrawn by the author on 2026-11-11 -- pointer variables are assigned. The author withdrew the earlier reading under which an atom to the right of a colon assigned. A mention of the name of a known Structure is not expanded -- neither by the parser nor when the clean graph is built (the author's answers of 2026-11-11, [journal](../LMX_blog/2026-11-11.md#known-name-not-expanded)): in the tree under `Struct1` stands one node, the atom `Struct2`, and no subtree with the fields of `Struct2` is there. That atom is a pointer (`void *`) to the Structure `Struct2`; it begins to refer to it at interpretation and translation, and a path through it continues into its fields: after `Struct2: a b c` and `Struct1: Struct2` the path `Struct1\Struct2\a` leads to the field `a` of `Struct2` itself. No new tree arises by that: the place of a Structure in the tree is given by its `parent`, and that of `Struct2` does not change -- the data still holds two Structures, and what they have inside does not change the content of the data. By name such a reference is immutable; the slot of the atom is addressed by index, and an assignment by index -- `Struct1[0] := …`, likewise `data[index] := …` -- may write anything into it; a mutable reference is declared by a receiver -- in `Model: @: ptr knownModel` the name `ptr` is a pointer variable inside `Model`. In the form `Struct1: (Struct2 a b c)` there is one anonymous Structure with four atoms inside `Struct1`: `Struct1[0]\Struct2\a` is the field `a` of the Structure `Struct2`, `Struct1[0]\a` is the own atom of the anonymous Structure, and these are two different `a`. References by name may close into a cycle (`A: B` and `B: A`) -- that causes no error: there is nothing to expand; the arguments of calls name Structures the same way, by name and without expansion. An atom that names nothing stays a word. The second form `Struct1:` in data is a repeated declaration, one more occurrence of the name: it does not replace the former one and does not write into it, and after it `Struct1` is addressed only with the index of an occurrence. The book used to read the author's example of 2026-11-10 (`Struct2: a b c`, `Struct1: q w e r t`, `Struct1: Struct2`) so that the repetition replaces the content of `Struct1` and `Struct2` itself is put inside; both readings of the executor are withdrawn. Since slice 355 (sub-step 5а of the [plan](../next_core_tasks_v3.md#m11)) the clean graph no longer binds an atom of the tail when the declaration is executed, no longer replaces the content on a repetition and prints the atom in the dump instead of the referent as a nested Structure. The form `ptr: Model` in data declares a Structure `ptr` with the atom `Model` -- a reference immutable by name; a pointer variable is declared by `@: ptr Model`, and `ptr := Model` writes a value into an already known pointer. When a null address is needed, the flat form `@: ptr Model 0` gives it. Admitting another candidate to `Model` uses ordinary `implements`, with no second rule for the name `Model`. If both names already exist in the same Structure, `Model: ptr` in data is a repeated declaration of `Model` with the atom `ptr`, not a write into `Model`; there is no write into the name of a Structure at all, and `Model := ptr` is an error. An unknown head `Model` with a lone atom in its tail declares in data a Structure `Model` with one atom and does not declare a reference `ptr`. The former transitional form — a known ordinary Structure `Model` and a new name `ptr` written `Model: ptr` as one new reference field to that same instance — is withdrawn by the decision of 2026-11-11: a pointer variable to `Model` is declared by `@: ptr Model`, as a field and as a formal alike. Calls of `fn`/`sub` are checked against their signatures, and an ordinary Structure executes through `call: A` or, in code, by the form `A()`. Receiver nesting does not turn an application chain into one argument list.

In data a structural form declares a Structure, and its tail is the content: `A(int: x 1)` and `A: int: x 1` declare `A` with a field `x`. Empty `A()` and `A:` declare a Structure without fields. `A: ()` declares `A` with one empty anonymous Structure inside it, and `A: (int: x 1)` declares `A` with an anonymous Structure inside it that has the field `x`: P0 does not unwrap a sole Structure in a tail ([values](#values)). Bare `A` reads a reference to an already selected ordinary Structure. If `A` is already declared at this level, a repeated structural form, including an empty one, is a repeated declaration, not an assignment: one more occurrence of the name `A`, which is addressed only with the index of an occurrence after that; in data no call of the former `A` results. Executable code has no description of a Structure -- such a form there is a call of its head; a distinct scope arises on a launch of a Structure -- by an explicit `call` or by a form `A()` -- and on a method invocation. Inline `if`/`for` operators remain in the same activation. Named Structures and callables are visible in both directions; variables, including const, are visible sequentially from their initial declaration in their scope and below. Root data inputs are available to executing code; namespace preparation neither exposes future code locals nor evaluates initializers ([visibility](#declaration-visibility), [call frames](#call-frame-20261115)). A form with a path in its head, `Outer\Model()` or `Outer\Model:`, is in code a call of what stands at that path; bare `Outer\Model` reads its reference without calling. To execute the selected ordinary Structure, use `call: Outer\Model` or, in code, the form `Outer\Model()`.

<a id="ordinary-var"></a>
### The special name `data`

`data` is the reserved name of an explicit reference to the data of the current launch; until the decision of 2026-11-11 it was called `var` ([the roles `data` and `code`](#data-code-roles)). Its default value is the data of the launch: `data\x` is the path to the place `x` of that data, `data\[N]x` to the Nth occurrence of the name, `data\if` to the form of a control receiver ([names and paths](#fields)). The binding is changed by the assignment of a pointer, `data := ptr`. A Structure is not itself a call. A structural form with the head `data` is read by the role, as any other -- it declares in data and calls in code:

| Where the form `data(...)` stands | Action |
| --- | --- |
| In data, the name not yet declared | Declare an ordinary Structure `data` with the written content. |
| In data, the name already declared | A repeated declaration: one more occurrence of the name, which is addressed with the index of an occurrence after that; this is neither a replacement nor an assignment. |
| In code | A call of the head: `data` names the data of the current launch, and the form `data()` launches that data over itself, under the general rule of launching a Structure. |

Formerly a repeated declaration `var(...)` in code replaced the binding. This is how the author's October 15 example was read: in `call: code code` the initial `var` referred to `code`, the reached form `var: (i: int: 5)` declared `var` again, and the next `var\i` accessed its `i`. The decisions of 2026-11-10 and 2026-11-11 withdrew three things in that example: the composed form of the field `i: int: 5` -- the field is declared by `int: i 5`; the unwrapping of a sole Structure in parentheses -- the form `data: (int: i 5)` declares `data` with one anonymous Structure inside it, the path `data\i` is an error for it because `data` has no `i`, and `data[0]\i` leads to the field; and the declaration of a Structure in code itself -- there such a form is a call, and the binding is changed by the assignment of a pointer. The path `data[0]\int\i` is wrong: a declaration of a primitive by a receiver is not placed into the graph as a form of the receiver -- it is the place `i` itself --, while the forms of the other receivers are placed into the clean graph directly (the author's answer of 2026-11-11, [journal](../LMX_blog/2026-11-11.md#single-structure-index-path)). The binding `data := ptr` changes the current call's explicit reference without publishing local values; no separate execution of the content or hidden data graph is introduced for it. The explicit path `data\data` addresses an actual field `data` of the selected data. [Primary example and reconciliation](https://github.com/michael0xf/LMX/blob/495e8435ede179ed6e6dd1c4a95d4f7445718317/LMX_blog/2026-11-03.md#ordinary-var-assignment-20261015).

In data the sequence `data(int: x 2); data(int: x 5)` is two declarations: two occurrences of the name `data`, each with its own content; the second neither replaces the first nor writes into it. A declaration, first or repeated, does not by itself execute the content of a Structure: its execution is given by a launch -- an explicit `call` or, in code, a form with the name of that Structure as the head, `A()` or `A(D)`. In executable `code` the name `data` follows the common rules of places and of the selected data, with no separate algorithm.

Distinguish this name from the `data` part of a `fn`/`sub`/`catch` definition and from the data a `call` receives. A method's `data` part describes its inputs; a call creates a local namespace without appending code places to the source graph. `call: data code` receives its data explicitly -- it stands before the code -- and `call: code` executes the code over itself as the data ([the receivers `call` and `fncall`](#call-receivers)); as with any receiver, its arguments are supplied by position or by name: `call(data := D; code := C)`. In code an ordinary Structure is launched also by a form with its name as the head -- `A()` over itself, `A(D)` over the data `D`; this is a form of its own, not a form of a receiver, and its single argument is named `data` -- by the same name by which code calls the data of its launch: `A(D)` and `A(data := D)` are one form ([structural forms](#forms-declare-or-call)). A form `data(...)` in data declares a Structure under the same rules as any other declaration; this does not launch the Structure's content. Bare `data` only denotes the data of the launch and invokes nothing, including when a method reference stands in its place.

If put is already defined as callable, the following declaration of Batch, written in data, retains a body with the statement `put: 7` without executing it:

```text
fn: put (int: n) int
return: n
Batch(put: 7)
```

This is an ordinary operator in the complete binary tree, not a separate “saved call” value, hidden closure or second graph. When execution of Batch reaches the put operator, the ordinary call rules apply. An available native implementation of Batch is selected; otherwise its retained body is walked in the admissible profile. Absence of a native implementation alone does not mean the tree is lost or unexecutable.



A later read does not retroactively change the role of an already written head. In the following example, `f` has no formal, visible outer value or previously established free input `x`: the form `x: j` stands in code, so it is a call of `x`, neither an assignment of a primitive nor a declaration of a Structure; the head `x` names neither a callable nor a Structure, and the form is an error ([the roles `data` and `code`](#data-code-roles)). Formerly it defined a named Structure, and `return: x` was the error. A caller's same-named value does not change this classification.

```text
fn: f () int
    int: j 3
    x: j
    return: x
```

A free input is a free value used by a callable without being declared as its explicit formal; establishing it and selecting its source follow [§12](#dynamic). This term denotes neither an additional Structure, a separate context graph nor name lookup during execution.

<a id="explicit-copy"></a>
### Explicit copying and pointer variables

The pointer receiver uses the same shapes as `int`. `@: ptr` first defines a void-reference place with no promised initial address; `@: ptr 0` supplies an explicit null address. `@: ptr Model` retains a reference to the existing `Model`, while `@: ptr Model Other` admits `Other` against requirement `Model`: the requirement and the candidate are written flat, and the nested form `@: ptr Model: Other` in the arguments of a receiver is a call of `Model` ([the roles `data` and `code`](#data-code-roles)); if `Model` is a Structure, this is a launch form at a place where a value is needed (an operand of an expression, an actual argument of a call, an initial value, an operand of `merge`), and it is an error: a launch has no result (the executor's reading -- [answers](../LMX_blog/q/fable-self-answers-20261110.md), Р22, item 3; Р25, item 4). The composed forms with the place in the outer head — `ptr: @()`, `ptr: @: 0`, `ptr: @: Model`, `ptr: @: Model: Other` — are withdrawn ([declaring a place](#receiver-args-only)). In code a repeated one-field form without a candidate checks an existing place's compatibility but neither clears its value nor changes its requirement; an actual write undergoes ordinary admission. Writing an address does not retroactively type an already declared void reference. These are receiver contracts after common P0, not separate expression parsers.

Explicit [merge](#composition) clones or composes existing Structures. A pointer variable holds the result: in `@: b merge(A; C)` the operands are A and C and the place `b` receives the result; the destination name is not the first merge operand. The former form `b: merge(A C)`, in which the outer name received the result, is withdrawn by the decision of 2026-11-11: in code it is a call of `b`, in data a declaration of a Structure `b` that has an unexecuted call of `merge` written inside it ([the roles `data` and `code`](#data-code-roles)). Application with operands uses an ordinary Frame under the [general grammar rule](LMX_grammar.en.md#no-inference): an atom `merge` does not capture subsequent fields as arguments, and `b: merge A C` does not spell that application. An unknown argument does not trigger implicit cloning. Formation of a returned nested callable with data from the finishing activation is governed separately by that composition section and is not removed by declaration rules.

The `@:` receiver takes the place name as its first field; both a new place and a write to an existing one use the same resolver and ordinary [admission](#admission). In a signature the same receiver describes an input requirement. The candidate's place is determined by common resolution; after admission, accesses use the resulting addresses and maps without repeating textual name lookup. A known method pointer `b` is invoked as `b: args`, `b(args)` or `(\b)(args)`; `\b(args)` dereferences the call result under ordinary precedence. Unary `@b` separately addresses the reference cell.

<a id="method-reference-assignment"></a>
A method reference is assigned through `@`, which comes first: `@: ptr method`. The first argument `ptr` is a place-name atom; the second, `method`, is an atom denoting the method value. **A bare atom is not a call**, so neither `ptr` nor `method` is invoked here. The `@` receiver consumes these arguments under its two-field contract: the first definition creates a reference place; on an already declared place, in code a new value is assigned to that same place after admission, while in data a repeated declaration stays one more occurrence of the name ([names and paths](#fields)). Likewise, `@: ptr 0` supplies an explicit null candidate. In contrast, `ptr(args)` or `ptr: args` explicitly applies a callable to arguments; if `ptr` holds a reference to an ordinary Structure, the same forms launch it by the launch forms of a Structure ([structural forms](#forms-declare-or-call)). The form `ptr: @: method` is not an assignment, whatever `ptr` is: in code it is a call of `ptr`, in data a declaration of a Structure `ptr` ([the roles `data` and `code`](#data-code-roles)); an `@` in the nested argument does not change that, and assignment uses `@: ptr method`.

Unary `@ptr` addresses the cell `ptr` and adds an address level; it is not the assignment `@: ptr method` and does not replace the stored method reference with its cell address. Explicit and hidden arguments from dynamic or lexical visibility have their own local activation cells: `@x` addresses the same local variable that bare `x` reads and writes. After a local `x := 9`, reading `\(@x)` yields `9`; writing through that address changes the local cell, not the binding's source. An external place is addressed explicitly, for example `@(node\x)`. Taking an address does not extend cell lifetime; an object reference and the variable cell holding it are distinct.

Candidate conversion precedes implements against the Consumer's requirement; reference storage changes after admission succeeds. An ordinary Structure value already travels by reference. @A addresses its cell and is not conversion of a Structure to its ordinary reference: A and @A have different depths. Assigning a Structure name to a reference place reads the already held reference and uses the destination cell's address to store its new value; conceptual `Lmx *` values and `Lmx **` cell addresses do not become the same expression type merely because C lowering uses both. If the assignment itself requires conversion of a primitive pointer value, its direction, depth and admissibility are supplied by the ordinary Message-local primitive conversion context, not a special table of user-Structure pairs; an absent rule does not silently remove an `@` level. implements establishes the referent's suitability for a structural requirement; the physical Lmx range is common, not separate for each model.

### A signature is not executed

A signature describes inputs rather than executing its forms as a method body. Declarations by receivers act in it; a structural form in the description of the formals is forbidden ([the roles `data` and `code`](#data-code-roles)). For nonprimitive `A`, a formal requiring `A` is written `@: p A`, admits a candidate through `implements(c, A, Consumer)` and transports its descriptor reference without copying or implicit `merge`. Value and reference requirements are written with the same receiver forms as in a body, but describing a formal does not assign a place while the method is built. A value written in the signature is a default, not a result of executing the body.

For structural `c`, `mytest(c)` and `mytest(@c)` have different depths: a Structure reference and a reference to the cell holding it. No extra level is removed to fit a formal. This applies equally to a Structure, a pointer variable and a nonprimitive formal; the target is its own language storage, not a transport-ABI box. A primitive value and a reference to its cell are not synonyms either. Passing and returning nonprimitives never use C by-value aggregates.

### Assignment and declaration sites

In code, re-declaring an already visible variable retains its type check, RHS computation, and assignment, but creates no second C variable. Executing `int: i 5; int: i 6` uses one local place. Both written forms remain in the source graph; local execution does not overwrite them. In data, a repeated declaration remains a separate named occurrence selected by index. New branch names are visible inside that branch and below; a repeated form uses an existing enclosing binding. A structural `name: ...` form in code calls its head; `:=` assigns without declaring.


Inputs and code's own variables are activation-local places; assignment writes back neither to the caller nor to the source graph. The declaration operator remains in code. A header describes call inputs and does not execute computed initializers during graph construction. See [frames](#call-frame-20261115).

<a id="forms-declare-or-call"></a>
#### Structural forms declare or call

Author's decision of 2026-11-10 ([journal](../LMX_blog/2026-11-10.md#forms-declare-or-call)). Every structural form — the compact one with parentheses `head(args)`, the short one `head: args` and the block one — either declares or calls something: it declares a place, a Structure or a callable under the earlier rules, or applies a receiver, a callable or a Structure to its tail. Which of the two is given by the role: in data the form declares, in code it calls (the decision of 2026-11-11, [the roles `data` and `code`](#data-code-roles)). A structural form does not assign. `i: 6` on a known place `i` is an error in code: a colon form no longer serves as a write of a value, and such a form cannot be a declaration of `i` — a declaration of a place has a requirement and a form of its own, `int: i 6` ([declaring a place](#receiver-args-only)); the place must be available at the point of use under the [common visibility rule](#declaration-visibility); root `data` inputs are available to `code`, while `code` variables and `const` are visible sequentially. A value is written into a known place only by the `:=` operator and the compound assignments ([writing a known place](#assign-known)) or by a repeated declaration by a receiver in code: `i := 6` or `int: i 6`. The decision itself writes the repeated declaration in the composed form `i: int: 6`, which the author withdrew later the same day. The rule concerns translation and interpretation; P0 does not change and builds the same Frame: it is read by the role of the Structure in the launch, and in code the common resolution finds its head.

In code a form whose head is an ordinary Structure launches it (the author's decision of 2026-11-11, [journal](../LMX_blog/2026-11-11.md#structure-call-by-name); the executor's reading -- [answers](../LMX_blog/q/fable-self-answers-20261110.md), Р21): `A()` is the same as `call(A, A)` (the Structure over itself), `A(D)` is the same as `call(D, A)` (the Structure over the given data `D`); so are the short form `A: D` and the block form. It is a launch form of its own, not a form of a receiver: the receivers `call` and `fncall` remain the general mechanism of launch ([the receivers `call` and `fncall`](#call-receivers)). The argument of the form is one and is named `data` -- by the same name by which executable code calls the data of its launch ([the special name `data`](#ordinary-var)); like the arguments of receivers, it is supplied by position or by name: `A(D)` and `A(data := D)` are one form; the form has no argument `args`; actual values are supplied through the `args` of `call`, while `data` describes the formals. Another argument name and two or more positional arguments are an error; the argument must give a Structure: a name, a path, a place holding a reference or an unnamed Structure written in parentheses. It is also an error when the head names neither a callable nor a Structure. In data nothing changes: `A()` still declares an empty Structure `A`, and `A(D)` a Structure `A` with an atom `D`; nothing is called (before the decision of 2026-11-11 such a form was refused in code, and an ordinary Structure was executed only by the receiver `call`).

Repeated declarations remain allowed. Executing a repeated variable receiver retains its actions, including `bump()` in `int: x bump()`. Same-named graph-field declarations do not merge. In data, `Struct1: Struct2` declares a Structure containing a reference atom to Struct2, not a copy of its fields; in code it calls Struct1. `b(args)` calls b's referent when it is callable or a Structure. A number or null reference is not callable. Colon does not replace `:=`. Source data/code are not auto-filled: new code places live in the call namespace under the [common rule](#call-frame-20261115).

<a id="assign-known"></a>
#### Writing a known place: `:=`

The author's decision of 2026-11-07 ([journal](../LMX_blog/2026-11-07.md)). Every earlier call form stays as it is, receiver calls included. `name: value` with an unknown left side still defines a new Structure -- in data; in code it is a call. Redefining a place already known stays permitted; at every redefinition the general `implements` admission, with its conversion table, checks that the new value fits the place. The author's decision of 2026-11-10 narrowed the second sentence: only a declaring form or `:=` redefines a known place, while a colon form with a value tail no longer writes it ([structural forms](#forms-declare-or-call)). The decision of 2026-11-11 narrowed it once more ([the roles `data` and `code`](#data-code-roles)): a known place is redefined only in code -- by a declaration by a receiver or by `:=`; in data a repeated declaration is one more occurrence of the name and writes into no place, and a `:=` form is not executed and stays a field that an index reaches. By the same decision the admission `implements` is performed once -- when the clean graph is built; after the construction it is needed only where the candidate is selected while the program runs, and an assignment of primitives is not checked for admissibility at run time (the rule speaks of the admission `implements`, not of conversion: the range check on receiving a number of another type, `u16(256)` into `u8`, remains at run time). The additional operator `left := right` is a general operator with the narrow function of assigning to the known: it writes only a place already known, and an unknown left side is an error, not a definition (the author's clarifications of 2026-11-07). It is not merely an additional form but a narrower one: an executable `:=` form moved or copied into a context that lacks such a place cannot be read as a declaration -- in code it gets the same error and creates no field, and in data it is not executed and declares nothing, so the intent to assign survives when code is handled as data. For a known left side it attempts to redefine the value that side holds, a method reference included: a method reference does not differ from a reference to the method's Structure. The decision of 2026-11-11 narrowed the left side too: it is a place of a primitive or a pointer variable -- to a Structure or to a function; the name of a Structure and the name of a function do not stand to the left of `:=`. For a method reference `ptr` already known, `ptr := other_method` thus redefines it after admission; the bare atom on the right denotes the reference, not a call. The right side is evaluated in the ordinary way. Used in the argument Structure of a callable, `:=` supplies a named argument ([callables](#named-actuals)). The decision defines neither the precedence or associativity of `:=` among other operations, nor a value of the written form as an expression, nor any removal of `@` levels.

<a id="compound-assign"></a>
#### Compound assignments and the power

The author's directive of 2026-11-07 ([journal](../LMX_blog/2026-11-07.md)): the compound assignments `+=`, `-=`, `*=`, `/=`, `%=`, `<<=`, `>>=`, `&=`, `^=`, `|=`, `**=` and the power operator `**` for expressions join `:=`. A compound assignment writes a place already known with the result of the operation over its current value and the right operand: `a += b` corresponds to `a := (a + b)`, `a -= b` to `a := (a - b)`, `a *= b` to `a := (a * b)`, `a /= b` to `a := (a / b)`, `a %= b` to `a := (a % b)`, `a <<= b` to `a := (a << b)`, `a >>= b` to `a := (a >> b)`, `a &= b` to `a := (a & b)`, `a ^= b` to `a := (a ^ b)`, `a |= b` to `a := (a | b)`, `a **= b` to `a := (a ** b)`; the author's spelling of these equivalences with a C-like `=` is kept in the journal, and in LMX `=` stays a comparison. The left side is a place already known under every rule of `:=`, the `implements` admission and the error of an unknown left side included; `:=` keeps its general narrow meaning of writing a known place, method references and the named supply included, and is not narrowed to numbers. `**` is the power; `^` stays the bitwise exclusive or. The associativity and precedence of `**` are Python's (the author's clarification of 2026-11-07): `**` groups to the right -- `a ** b ** c` is `a ** (b ** c)`; it binds tighter than `*`, `/`, `%`, `+` and `-`; a call, an index and a field access form the operand before `**`; on its left `**` binds tighter than the unary `+`, `-`, `~`, on its right a unary operand is admitted -- `-2 ** 2` is `-(2 ** 2)`, `(-2) ** 2` keeps its parentheses, `2 ** -2` is `2 ** (-2)`, `2 * 3 ** 2` is `2 * (3 ** 2)`; the right side of `**=` groups the same way. The grouping fixes no order of evaluating effectful operands. The equivalences describe the result, not a macro substitution with repeated effects of the left side: evaluating a left place with effects once, the numeric types and conversions of `**` and `**=`, a negative or fractional exponent, `0 ** 0`, evaluation errors and atomicity are not defined by this decision and are clarified before the implementation; the earlier rules of numeric operations and admission stay, and nothing of Python beyond the grouping of `**` is carried over. Neither native code nor the walker implements these yet ([plan](../next_core_tasks_v3.md)).

<a id="group-assign"></a>
#### Group positional assignment

Author's decisions of 2026-11-10 ([journal](../LMX_blog/2026-11-10.md#no-structure-head)). The left side of the `:=` operator may be an unnamed Structure of places: `(a b c) := c, a, b` assigns by position — the first value to the first place, the second to the second, the third to the third. The author first wrote this form with a colon, `(a b c): c, a, b`; after the rule that structural forms do not assign ([structural forms](#forms-declare-or-call)) it is written with `:=`, and a Structure as the head of a Frame before a colon is not introduced. All right-hand values are computed before the first write, so this statement rotates the three values. Each position is written by the rules of `:=`: the place must be available at the assignment site under the [common visibility rule](#declaration-visibility). Variables and `const` are visible sequentially; grouping does not change that rule. An explicit path selects a field under the ordinary path rules; this does not make its bare name visible before declaration. For name-based access, an unknown name, the name of a Structure or a function name on the left is an error, and each value passes the ordinary admission of its place. When the right side is one call whose result is a Structure, the places receive its fields by position, and the names of the result's fields are not compared: `(a, b, c) := myFn()` ([Structure result](#structure-result)). This is an assignment between unnamed Structures, the general case of assignment and not a special form (the author's decision of 2026-11-16, [journal](../LMX_blog/2026-11-16.md#unnamed-structure-executes)). A different number of places and values is a refusal: at translation when the number is known, otherwise at execution before the first write. A Structure on the left holds at least one place; the head `()` with empty parentheses remains the earlier separate form ([grammar](LMX_grammar.en.md#bounded)). Neither native code nor the walker implements this yet ([plan](../next_core_tasks_v3.md#m6)).

<a id="qualification"></a>
## 10. const, immutable and independent

`const` protects a binding: it cannot be assigned, rebound or replaced. The value behind a protected reference may remain mutable. `immutable` protects the value itself for its entire life through every alias; a variable holding its reference may remain rebindable. `const: immutable` combines both guarantees. They are independent qualifications, not degrees of one scale.

Immutability applies to a primitive, a Structure and its selected tree, or an Array with its descriptor and elements. It covers every field and explicitly included descriptions, not just Consumer's paths. Passing, returning and storing an immutable value preserve its identity; qualification requires no copy, including for a primitive. It does not freeze a foreign resource denoted by an immutable identifier.

`immutable` gives a new value its supertype during construction, before publication: cells are allocated from pools of the corresponding immutable types. An ordinary Structure already built in the mutable-Structure pool is not retroactively converted; `immutable: Existing` on that value refuses at consumption. This supersedes the earlier promise that `RuntimeImmutable` would requalify an existing tree without changing its identity. An already immutable value can pass as a value of its type without requalification. Argument admission remains [unified](#admission), as for every receiving expression.

The whole selected tree is examined before the new immutable value is published. A contained Structure is a tree branch only when its ordinary structural `parent` field points to the parent being examined. An outside reference **already stored as a data value** is permitted only to an already immutable object; it is terminal, and its target is neither traversed nor requalified. The root's own `parent` is a structural lexical link to a node outside the selected tree, not such a stored reference: `immutable` without `independent` constructs the value under its ordinary parent, which it neither freezes nor requires to be immutable; `independent` is the one receiver that touches that link. An operand of stored executable code is not such a value before that code runs (see below). The pre-publication state is checked: processing an earlier field cannot justify an invalid outside data reference in a later field. If a source `immutable` declaration violates this condition, the translator refuses construction; even under interpretation the graph is built first, so this refusal is not an exception thrown by the executable body. If an executed operation on an already existing tree encounters an error, the interpreter uses the ordinary `throw` caught by the ordinary `catch`, with no special `immutable` channel. Neither case becomes an `sys\assert`.

Qualification checks values and references already stored in the tree. Ready declarations fold during clean-graph construction without program execution; a computed initializer is not an already stored result. Qualification does not execute it. Its result is checked when actually obtained and consumed under the ordinary contract, without predicting future body behavior. This is the same for data and code. An immutable Structure can hold code that later reads mutable data without freezing that data.

Primitives and methods are leaves, not lexical-tree branches. This describes the `parent` topology, not an exemption for mutable storage physically retained by the qualified graph: a saved method's code record and already stored data must satisfy the immutable construction contract. Its deferred operands are code, not their possible future values, and cells of a later activation are not frozen by this check. An Array reference likewise establishes no `parent` branch: a tree operation does not implicitly freeze an outside Array's mutable backing. An immutable Array is constructed under its own contract. A cell's membership in a service pool does not permit traversal or qualification of the entire pool.

Construction of an immutable value completes only after successful full preflight. Failure leaves no partially published immutable tree or successful result; silently skipping a branch, copying an already existing ordinary object merely to change its type, or retargeting links is prohibited. An already immutable value needs no requalification. This rule does not roll back earlier initializers, argument evaluation or explicit graph writes; it establishes no graph transaction.

Protection applies to actual writes to protected values; local frames are never published into the graph. The immutable receiver checks the constructed value and stored references under the rules above; it neither predicts writes by future execution of the saved body nor requires proof of their absence. Such analysis is not performed outside an explicitly written test. If a reached write targets a protected place, the shared runtime mechanism refuses before changing that place. This applies both to its own saved body and to external code. Calling a method does not remove protection. Changing a local argument copy or rebinding a local reference does not change the protected value. Constructing a new value, including merge, does not thaw the original. See the author clarification of [November 1](../LMX_blog/2026-11-01.md).

Construction-time `independent` sets the root's `parent = 0`; that is exactly the absence of an external lexical parent. Internal tree `parent` links and own fields remain. The qualification neither retroactively clears existing objects' `parent` links nor prohibits explicitly supplied references, current-caller dynamic arguments, Messages or selection of a callable by a compatible signature. It does not require purity or an interface closed over explicit arguments alone.

`const`, `immutable` and `independent` are receiving expressions; their composition establishes the result's qualified type. The action of each needs one argument, so several arguments may be written and the action applies to each in turn, in the written order: in `const: int: a 1; int: b 2`, in `const(int: a 1; int: b 2)` and in a block under `const:` with two declarations there are two arguments, and that is the same as two forms with one argument each. How many arguments are passed and what they are is determined by the form under the general rules of parsing, not by the presence of parentheses. [`private`](#private-binding) and [`required`](#required-receiver) are written the same way (the author's clarifications of 2026-11-18, [journal](../LMX_blog/2026-11-18.md#many-arguments-all-marks), [journal](../LMX_blog/2026-11-18.md#no-group-form-for-modifiers)). These receivers take their arguments as `data`, so an argument that is itself a Structure is not unwrapped: in `const: (int: a 1; int: b 2)` and in a block under `const:` where one anonymous Structure with these declarations is written there is one argument -- that Structure ([two kinds of receivers](#two-kinds-of-receivers); the author's clarification of 2026-11-18, [journal](../LMX_blog/2026-11-18.md#arguments-by-number-and-form)). `immutable` is a supertype determined when the value is built. Each base type has storage for its corresponding immutable type; all immutable Structures, regardless of their field models, use a shared pool of that type, distinct from the ordinary Structure pool. Qualifying one Structure does not affect unrelated values; every alias of a constructed immutable value sees the same supertype by address. The common address-classification mechanism is described in [L2](L2_spec_en.md#type-by-range); this does not introduce a new type for every Structure model or an additional qualifier-specific name-binding table. A zero root `parent` remains the structural consequence of `independent`, not a replacement for type classification. As receiving expressions they stand wherever a Structure value is received -- a declaration's tail, a method's `return:`, a `merge` operand -- composed in the order and part the source writes, each with its own contract; the root-level chain over a named Structure is one case of that reading, not its definition.

For example, a method inside independent Structure S can use S's field through its internal lexical link. Required `x` can come from the current caller. If `x` exists only in S's former textual surroundings, implicit external access is unavailable. An explicitly passed large Array neither shrinks nor gets copied because of `independent`. The special lifetime of the three qualifications together is described under [eternal branches](#eternal).

<a id="execution"></a>
<a id="callables"></a>
## 11. Callable expressions and their interfaces

<a id="declaration-visibility"></a>
**Implementation, slice383.** Consuming a reached raw `fn`/`sub` declaration that has no F for that scope/source yet prepares the reached block through the existing common declaration mechanism. Pure classification and consuming reads use one search; only a read permits preparation, and a constructor failure is passed as a local status rather than replaced by a missing name. This checks the existing distinction between a copied declaration and a held value: an ordinary copy of F does not become a function, source Space bindings are not transferred, and a new explicit application of `fn` creates a new F and own data. The copier, copy map and own-data constructor are unchanged by this slice; full M11, external/computed CodeBody and M13/M14 remain OPEN.

**Implementation, slices381–382.** The clean graph uses `lexical_scope` in the existing frame as a cursor for the physical selected CodeBody, preserving the identities of `code`, `body` and `data`. Written `fn`/`sub` are prepared when their block is actually entered; a computed declaration creates F when execution reaches its producer. An inline name is not promoted into the shared free-input row, and leaving the body restores the cursor. Slice382 gives common consumers a borrowed `body/from/to` view: at the boundary receiving the whole `else`/`finally` tail, a sole written anonymous group is selected once as the body; standalone groups inside an already selected body remain data values. This implements the existing body contract without changing the tree or physical parents and completes neither external or computed CodeBody support, all M11 nor the full cycle of copying and applying `fn` anew; M13/M14 remain OPEN. Fields of a retained written Structure in a data context remain data; explicit `merge` is a constructor and executes its fields' computed initializers.

Variables, including `const`, are visible from their initial declaration onward at their lexical level and in nested scopes. Before that declaration, this local name does not participate in lookup; available outer and dynamic names follow the common rules. Names of named Structures and callables remain visible in both directions. A variable containing a callable pointer remains a variable. The rule governs head resolution and other name uses alike; brackets and trailers do not change it. [The author's clarification](../LMX_blog/2026-11-15.md#m14-const-sequential).

Sequential visibility of a bare name does not restrict explicit selection of a field in a constructed graph: `data\field`, `S[n]`, and `S\[n]field` use ordinary addressing. A field's presence in the graph does not mean that its computed value has already been obtained.

A call creates a new namespace. Preparation collects only data/code root declarations, without executing initializers or lifting nested declarations into the root. Data input places are available to the executing code as this call's inputs; collecting the code root does not make its future variables visible before their declarations. A new branch name is visible at its level and below, not outside. Re-declaring an already visible name uses its existing local place; a supplied RHS retains evaluation, admission, and assignment.

A callable description is data with the common visibility and occurrence-selection rules. The position of its data/return/code parts creates no separate early-evaluation rule. Inputs map to the call namespace without executing computed declarations. The common parser does not classify a field's role through a special case for its name.

Program files form no categories of a main file and parts: a message is a Structure, and included files join the program graph. Declaration order for variables and `const`, and bidirectional visibility for named Structures and callables, follow the resulting lexical tree. Comparing line offsets in separate source documents does not define visibility.

A signature describes inputs and the result; it is not an executable body. A formal's spelling does not execute the call, declaration, or assignment that the same spelling might denote in a body. The formals are declared by receivers -- `int: arg default`, `@: arg Template`; a structural form in the description of the formals is forbidden: it would be a declaration of a Structure, not a variable, and the former synonymy of the two descriptions of a formal in a signature -- by a structural form and by a receiver -- is withdrawn ([the roles `data` and `code`](#data-code-roles)). Supplying an actual argument performs the contract's conversions and admission, but does not execute the formal description as a body operator. Uses of the resulting parameter in the body are resolved by its contract and the general expression rules, not by executing the signature text.

<a id="method-parts"></a>
### Parts of a callable Structure

For `fn`, `sub`, and `catch`, unified `data` describes input places, requirements, and defaults; there is no separate `args` declaration part. The `return` description where applicable and `code` remain. The `args` of `call`/`fncall` is a Structure of actual supplied values, not another input description. A header without `code` describes a call signature, not a complete particular function. Different actual argument sets produce different C signatures. Existing short headers remain with unified data. This is one representation and consumer change, without a second set of parser rules. See [frames](#call-frame-20261115) and [all launch forms](#call-receivers).

General occurrence selection also applies to the one-argument `call: code` and to the equal form `code()`, which execute the code over itself ([the receivers `call` and `fncall`](#call-receivers)): with multiple source root-level declarations of one variable in such code, it may not silently choose the first. An access from the code to that variable without the index of an occurrence is an error; this form selects no child `data` block by itself — the data is passed explicitly. This is not a second name lookup for `call`.

A receiver `fn`, `sub` or `catch`, when executed, itself creates the callable — a complete Structure — and the name of the callable names strictly the created Structure, not the declaration form with its written receiver head and arguments (the author's clarification of 2026-11-16, [journal](../LMX_blog/2026-11-16.md#receiver-creates-structure)). Heads resolve through canonical strings; no separate opcode is needed. Parts of the created Structure are accessible by ordinary paths, including `func\data` and `func\code`; the parentheses of the declaration form do not determine its layout. Clean-graph construction normalizes ready declarations without executing the program. Each call prepares a local namespace from root declarations in input `data` and `code`; graph `data` is neither completed from the body nor written back from computed locals. A reached receiver executes its code under ordinary rules.

An ordinary Structure executes through `call` or a by-name form in code: `S()` equals `call(S,S)`, and `S(D)` equals `call(D,S)`. Data and code need not coincide. Explicit paths retain the source graph; root declarations prepare local namespace places without completing graph data. Free external names use ordinary dynamic/lexical lookup and do not become data fields by name coincidence. `node` retains its existing meaning. Repeated occurrences, data/code roles, and admission also follow ordinary rules when launching over self; there is no special executor. See [call frames](#call-frame-20261115).

A callable is just a Structure: the launch receiver does not select a part inside the Structure it is given, `call(D s)` executes `s` itself, and the body of `s` over other data is written `call(D s\code)` (the author's decision of 2026-11-16, [journal](../LMX_blog/2026-11-16.md#callable-is-structure); details -- [the `call` and `fncall` receivers](#call-receivers)). All declared input places of `data` are optional: an input without a value, to which no value is supplied, does not make the call refuse and holds "T without initialization"; the receiver [`required`](#required-receiver) checks that a given field is initialized (the author's decision of 2026-11-16, [journal](../LMX_blog/2026-11-16.md#optional-inputs-required)).

A structural form in executable code, including name: ... end: name, calls its head; it neither declares nor assigns source data ([roles](#data-code-roles)). A data: block in executing code therefore also launches its head with its own tail as the argument: an ordinary Structure accepts one data argument or an empty tail. Data and code are described separately, for example call(m\data m\code); a named definition does not itself execute its contents.

A variable-declaration receiver in code works with the call-local namespace: its initial declaration introduces a place, while repeating an already visible name preserves the RHS, admission and assignment to that place. Nested if/for stays in the same activation; a new branch name is visible there and below, not outside. Neither nesting depth nor a missing same-named data field requires adding a graph field: code locals need not correspond to source data. Preparation considers only data/code roots, without running initializers or exposing future locals. Repeated physical data fields remain distinct occurrences selected explicitly by data\[N]y; data\y is ambiguous when repeated. The contracts of fn/sub and ordinary admission of supplied inputs remain; this is not a requirement for D to contain all code locals. See [frames](#call-frame-20261115).

Ordinary `call(D, C)` uses the same fresh-namespace model. D's root declarations provide inputs; C's root declarations provide the remaining locals. Preparation neither changes D or C nor executes computed declarations early. Paths `data\` and `code\` retain the original D and C.

Neither call entry, code/data coincidence, nor a graph write clears native. A local write changes only the namespace; an explicit write changes the source graph. Updating machine execution requires [explicit compilation](#explicit-compilation); endturn alone does not perform it.

An executable body is a structural expression; declaring a named Structure or method does not execute it. The bare name of an ordinary Structure denotes a reference to it; explicit receiver `call: A` or, in code, the form `A()` executes it without arguments or result. The forms `A()` and `A: ()` are read by the role: in data they are structural forms of a declaration of `A`, first or repeated, and call nothing (the author's answer of 2026-11-11, [journal](../LMX_blog/2026-11-11.md#structure-head-call-refuses-in-code)), while in code each is a call of `A`: if `A` is an ordinary Structure, `A()` launches it over itself, the same as `call(A, A)` (the author's decision of 2026-11-11, [journal](../LMX_blog/2026-11-11.md#structure-call-by-name); before this decision such a form was refused in code, and an ordinary Structure was executed only by the receiver `call`). It is an error when the head names neither a callable nor a Structure. `fn` declares one result, which may be a Structure with several fields ([Structure result](#structure-result)); `sub` returns no value. A signature specifies arguments, result, and `throws` but does not itself execute.

Bare `return` exits without a value; `return: value` is admitted only where a result is declared. At the opening level, `return` may also be a trailer for any callable Structure under the general grammar rule; it is not a closer for a non-callable Structure. Explicit `end: Name` is optional, and reaching the end of a body without `return` does not synthesize a return node.

A path through a Structure reads a field without adding an invocation of the selected Structure or callable. A computed declaration is not executed by a path either: the path reads its record ([explicit path](#path-reads-no-execution)). `M\data\x` addresses the source graph; bare `x` and `@x` in a call address the local namespace cell. They are different places even when their initial values match.

A callable occurrence has its own structural identity and a `parent` link into its above-method lexical space. Multiple occurrences can reference one immutable method. Graph copying neither creates another method implementation nor changes its signature; state belongs to particular structural occurrences and activations. A nested definition does not capture a caller frame in a hidden environment.

Entry creates a local frame without write-back. A mandatory executable-code copy is cancelled: edit-application timing before endturn is unspecified, while native updates require explicit compilation. Other execution rules remain shared by native and the walker. Bindings use hidden arguments without a lexical-environment copy; see the [boundary](#explicit-compilation).

Source `data`, `return`, and `code` belong to the callable Structure; the local namespace belongs to the activation. Re-declaring a variable in code retains its type contract, computation, and assignment; only the repeated C declaration is omitted.

A named Structure has no explicit arguments, but values used by its body still need to be resolved. Its explicitly constructed fields remain in the Structure itself; `call` does not create further fields from mentions of external names. Root input-data places are available to code as call inputs; preparation does not cancel sequential variable/const visibility in the executable lexical tree. A receiver declaration in code with no corresponding input-data place defines a call-local place, without extending source data. Namespace preparation visits the roots of data and code and does not execute a computed RHS. A future local's bare name is not yet visible; an early read through an explicit path does not suppress execution of its declaration statement when reached ([agreed clarifications](#activation-history)). For a genuinely free name, the value source is selected during execution by the ordinary rule: the caller's available context, then an eligible lexical source ([§12](#dynamic)). Thus `named_called_struct` can read an externally bound `k` and locally change the working value of `k` in its own activation, but no `named_called_struct\k` field exists unless explicitly declared inside that Structure. Changing the local value does not rewrite the external source; an external field changes only through an explicitly written path. Named Structures have no separate free-name resolution mode.

The distinction also holds within one Structure: `int: a` creates a typed place (in data a receiver form declares the place, in code it checks the type on its own line and, when a value is written, assigns -- [the roles `data` and `code`](#data-code-roles)), while a later `a := get_a()` computes and stores a new value when reached. A code declaration defines a call-local place, without extending source `data`; namespace preparation does not execute a computed operator early. Keeping these parts in one graph does not make them interchangeable.

Callable selection starts from an explicit reference, structural path or textual path with an explicitly supplied root. Selecting an implementation and providing its arguments are distinct actions. The selected candidate undergoes [admission](#admission); the call then receives the signature inputs: the declared input places of `data` are optional ([the `call` and `fncall` receivers](#call-receivers)), while each free (dynamic) input must have a source. A suitable method field does not by itself supply its dynamic inputs. Transporting a method as data is not invoking it.

<a id="call-receivers"></a>
### The `call` and `fncall` receivers

| Form | Supplied values `args` | Input `data` | Result |
|---|---|---|---|
| `call(args data code)` | `args` | `data` | none |
| `call(data code)` | not supplied | `data` | none |
| `call(code)` | not supplied | `code` | none |
| `fncall(args data return code)` | `args` | `data` | according to `return` |
| `fncall(data return code)` | not supplied | `data` | according to `return` |
| `fncall(return code)` | not supplied | `code` | according to `return` |

`args` is the Structure of actual supplied values, exactly the argument Structure
of an ordinary `call`. It is not formal declarations, a signature, or a separate
callable part. `data` describes input places, requirements, and defaults.
`return` describes the result; `code` is the executable Structure. `call` returns
no value; `fncall` returns a result according to `return`.

Forms without `args` supply no additional actual values. Omitted `data` means `code`
itself: `call(C)` equals `call(C C)`, and `fncall(R C)` equals `fncall(C R C)`.
A child `data` field inside `code` is not selected automatically. These are
abbreviations of one operation, without requiring an empty Structure allocation
or a new service object for omitted `args`.

`args` follows the ordinary positional and named argument rules, evaluation order,
call-shape checks, admission, and whole-Structure argument passing. Values already
obtained are not evaluated again or reinterpreted as declarations. A supplied
actual replaces the corresponding place description in a fresh namespace;
source data/code are unchanged, and entry executes no initializers.

For an ordinary `f(...)` `call`, its supplied-value Structure is `args`; `data`, `return`
when present, and `code` are selected from f. With the same actuals A, a function
launch is `fncall(A f\data f\return f\code)`, while a sub/catch launch is
`call(A f\data f\code)`. The interpreter sends ordinary calls, calls through
pointers, Structure launches, and all six explicit forms through one mechanism
for binding, admission, frames, execution, and result transfer. Only selection
of the launch parts differs; methods, catch, and explicit receivers have no
separate execution path. Reached calls from test and converters use that path too.

The receivers' own named arguments are ordinary arguments as well:
`call(args := A; data := D; code := C)` and
`fncall(args := A; data := D; return := R; code := C)`.
Names inside `args` select inputs described by D, not receiver parts.

In `code`, `S()` still equals `call(S S)`, and `S(D)` equals `call(D S)`.
In the `data` role the forms do not launch execution themselves; repeated names
follow ordinary occurrence selection. Unified `data` for fn/sub/catch remains:
they have no separate `args` declaration part. The `args` parameter of call/fncall
supplies values and does not contradict that rule.
[The author's clarification of 2026-11-15](../LMX_blog/2026-11-15.md#call-actual-values).

A callable is just a Structure (the author's decision of 2026-11-16, [journal](../LMX_blog/2026-11-16.md#callable-is-structure)). The launch receiver has no special rule for a callable: it does not select a part inside the Structure it is given -- neither the child `data` nor the part `code`. `call(D s)` executes `s` itself, not its body, whether `s` was declared with `sub` or written as an ordinary Structure; the body of `s` over other data is written `call(D s\code)`. An ordinary call is expressed as before by `call(A s\data s\code)`, and for a function by `fncall(A s\data s\return s\code)`.

```text
D:
    int: x 10

sub: s (int: x 5) (Counter\steps := Counter\steps + x)

call(D s)
call(D s\code)
```

The first form executes `s` itself over `D`, the second the body of `s` over `D` (`Counter` is a Structure with a counter `steps`). Any Structure may be given to `call`, including the whole Structure created by `sub` or `fn` (the author's clarification of 2026-11-16, [journal](../LMX_blog/2026-11-16.md#receiver-creates-structure)): the given object — the Structure the receiver created — is executed by its actual fields under the general rules; there is no prohibition, no automatic selection of the body and no special order for a callable, and what is observed is a consequence of the general mechanisms, not fixed as a separate norm.

All inputs are optional (the author's decision of 2026-11-16, [journal](../LMX_blog/2026-11-16.md#optional-inputs-required)). A declared input place of `data` that is given no value and has no value in its declaration does not make the call refuse: the place holds "T without initialization", and the call executes.

```text
E:
    int: x

call(E Step)

C:
    int: i
    i := 5
    Counter\steps := Counter\steps + i

call(C)
```

Both launches execute (`Step` is some callable Structure); so does `f()` for `fn: f (int: a)`. The receiver [`required`](#required-receiver) checks that a given field is initialized: in the `data` of a launch when the arguments are supplied, in `code` on its own line; it checks exactly initialization and does not declare the argument mandatory. The rule concerns the declared inputs of `data`: a free name that has no source, neither along the chain of activations nor lexically, still makes the call inadmissible ([§12](#dynamic)); this is how the author's word "all" is read (the executor's reading -- [answers](../LMX_blog/q/fable-self-answers-20261110.md), Р30).

<a id="named-actuals"></a>
A named actual argument is written `a := value`: the left side selects the formal `a` of the callable the call selected, and the right side is evaluated in the ordinary way, so `f(a := a(5))` supplies the formal `a` with the result of an ordinary call of the callable `a` (the author's decision of 2026-11-07, [writing a known place](#assign-known)). The forms `a: 5` and `a(5)` among the arguments do not become a named supply because their head matches a formal's name: each is a call of `a`, whose result is a positional actual argument; if the head `a` names no callable, the form is an error: a launch of a Structure has no result (the executor's reading -- [answers](../LMX_blog/q/fable-self-answers-20261110.md), Р22, item 3), and no declaration can stand among the arguments (the decision of 2026-11-11, [the roles `data` and `code`](#data-code-roles)). Positional actual arguments precede named ones. After the first named argument, subsequent arguments must also be named. An unknown name, duplicate assignment to one argument or ordering violation is an error; the absence of a value for a declared input is not an error: all inputs are optional (the author's decision of 2026-11-16, [journal](../LMX_blog/2026-11-16.md#optional-inputs-required)). A named argument's right side is supplied as a structural value when that is the receiving expression's specified mode; it does not become an arbitrary sequence of immediate calls. In argument position a bare callable name denotes a reference to its occurrence, not its execution result. If the receiver requires a result, the actual argument must contain an explicit call of a value-returning callable (`f()` or `f: ()` for a nullary method), followed by ordinary conversion and admission; demanding a result does not itself invoke bare `f`. A callable without a result, including `sub`, can be passed by reference to an appropriate place but cannot supply a result value. Bare `return` means only exit and does not make a callable value-returning. A bodyless `fn` remains an interface descriptor and may be passed by reference, but direct execution gains no invented body.

The names and the form of a call are checked against the selected callable before any argument is evaluated: the correspondence of names and positions and a formal given twice; the presence of values for declared inputs is not checked -- all inputs are optional ([the `call` and `fncall` receivers](#call-receivers)); a mismatch is the implicit `call` with no effect of the arguments, so `f(x := touch())` at a selected callable without a formal `x` does not run `touch()`. The arguments are then evaluated in written order, and each is received at once by the selected callable's formal, with that reception's ordinary conversion, before the next one is evaluated; when an argument's evaluation or reception fails, the later arguments stay unevaluated and the callee's body does not start (the author's decision of 2026-11-07). The rule is one for an ordinary call and for a call through a mutable callable place. The callable is selected once, before the arguments; this is a check of the call itself, not an analysis of future bodies. The compatibility of actual arguments and receiving places is checked by the shared admission `implements`: once when the clean graph is built -- where the candidate is known at construction -- and at the reached call -- where the candidate is selected while the program runs (the author's decision of 2026-11-11, [used interface checking](#admission)).

A formal parameter with a default remains part of the full accepted interface, not a free dynamic input. After ordinary admission, a supplied argument replaces its source declaration in this call's namespace; that place's source initializer is not executed at all. Zero is a supplied value too; an incompatible argument is not silently replaced by the default. An omitted argument uses the selected source description, obtained directly or through ordinary data composition. A computed default executes neither during clean-graph construction nor at call entry. An unused field is not evaluated; the value is obtained by the call when it reads that place of its namespace by a bare name. There is no pre-body default-evaluation pass or ordering for such a pass. If neither an argument nor a valid default is available, ordinary call refusal applies. A local assignment does not change later calls' defaults; only an explicit operation changes their source graph. The source belongs to the selected callable. [The M14 clarification](#call-frame-20261115) replaces the old pre-body default evaluation.

<a id="native-structures"></a>
### Ordinary Structure native code and frames

An ordinary Structure C and a method share body and frame compilation. `call(D, C)` requires neither `data = code`, a named C, nor an artificial `fn`. Entries and C signatures derive from actual calls rather than the complete input model. Different argument sets give different signatures; this does not justify a speculative version registry or universal adapter.

`sys\native(C)` obtains the native descriptor from call tables without executing it. Writes are not tracked for native and do not clear entries; explicit compilation performs updates. Known native calls go directly to known C functions; dynamic calls select a suitable table variant. Locals are not published and explicit writes change the graph. [Complete contract](#explicit-compilation), [M14](../next_core_tasks_v3.md#native-structures).

<a id="whole-arguments"></a>
A call with a single Structure argument does not differ from a call with the chain of its fields -- for a callable and for a receiver that takes its arguments as `code`. The general case is one Structure among arguments that count as `code`: whether it is written in place in parentheses or prepared beforehand and passed by reference makes no difference; given `Struct: arg0 arg1 arg2`, the five forms -- `f: Struct`, `f: (arg0 arg1 arg2)`, `f(arg0 arg1 arg2)`, `f: arg0 arg1 arg2` and the same form written vertically, `f:` with the arguments on the lines under it -- are one and the same call (the author's clarification of 2026-11-18, [journal](../LMX_blog/2026-11-18.md#one-unnamed-structure-for-receivers)). The Structure is unwrapped once, by one level, and only when the call is processed -- anew each time; in the clean graph the form lies as it is written, and no unwrapping is seen there ([journal](../LMX_blog/2026-11-18.md#unwrap-once-at-call)). To pass the Structure itself as one argument, an assignment to the argument is written: `f(arg0 := Struct)`.

<a id="two-kinds-of-receivers"></a>
Receivers are of two kinds (the author's decision of 2026-11-18, [journal](../LMX_blog/2026-11-18.md#two-kinds-of-receivers)). A receiver that takes its arguments as `code` treats them as a callable does: a sole Structure is unwrapped. A receiver that takes its arguments as `data` does not unwrap a sole Structure argument and receives exactly what is written: these are the level records `L1`, `L2`, `L3`, the modifiers `required`, `private`, `const`, `immutable`, `independent`, and the form `: merge` in the role of `data`. `merge` is the only receiver that behaves differently depending on where it stands and where it returns its result: in a `data` block and after a colon it takes its arguments as `data`, in `code` as `code` ([two forms of merge](#merge-two-forms)). The other receivers of the language -- `call`, `fncall`, `length`, `typeof`, `parent`, `return` among them -- take their arguments as `code`. An atom has no call role: the name of a Structure in an argument is always a reference to it, in the role of `code` and in the role of `data` alike (the author's clarification of 2026-11-18, [journal](../LMX_blog/2026-11-18.md#atom-has-no-call-role)).

This is a rule of call binding, not of the parser: P0 does not unwrap an anonymous Structure written in the call (author's decision of 2026-11-10, [grammar](LMX_grammar.en.md#empty-colon)), and a callable receives it just as the computed result of `merge` given as the only argument: the result's fields become the whole argument Structure (the author's clarification of 2026-11-07, [journal](../LMX_blog/2026-11-07.md)). The author's example; the name `test` is a word of the language, hence `mytest` here, and the field of the second operand, which the author wrote in the former form `a: int: 5`, is written `int: a 5` here ([declaring a place](#receiver-args-only)):

```text
fn: mytest (int: c 3; int: a) int
    return: c * 10 + a
int: r mytest(merge(mytest\data; (int: a 5)))
```

`mytest\data` is the unified input description: c defaults to 3 and a has no value. merge explicitly constructs the whole argument Structure with c=3 and a=5. This does not auto-fill the source graph on a call.

Structure and argument boundaries use the common parser in the [grammar](LMX_grammar.en.md); new header syntax after merging args/data requires agreement, not a separate parser. An empty Frame has zero fields; bare f: without an argument is its short form. A signature without code describes a call and is not an executable body.

In an executable body, a directly written expression is evaluated by the general rules: a lone number yields its value, a bare name reads its resolved value or reference without calling it, `2 + 2` and `tick() + 1` evaluate their operands, and `x := value` performs assignment; a result without a destination is discarded. An anonymous Structure written in parentheses as a standalone statement is not a call with arguments — it has no head — but its written forms are executed in place, in the current activation (the author's decision of 2026-11-16, [journal](../LMX_blog/2026-11-16.md#unnamed-structure-executes); [the roles `data` and `code`](#data-code-roles)): `(tick())` calls `tick`, `(2 + 2)` evaluates the expression and discards the result, `(a b c)` reads three names without calling them, and `()` does nothing; names declared inside it follow the general [visibility](#declaration-visibility). At a place of a value or an argument the same written form remains a written Structure, and its receiving expression determines how it is used: a numeric formal reads it under its expression contract, a data consumer reads it as data, and a launch or control receiver explicitly accepting it as a code body executes the written forms of the selected body. Explicit `f()` and `f:` in code apply the resolved head with an empty argument Structure: a method is called under its contract, and an ordinary Structure is launched over itself, as `call(f, f)`; a head naming neither a callable nor a Structure is refused. With groups preserved by P0, `f: ()` contains one field — an empty anonymous Structure read under the head's contract ([values](#values)); it is not an empty Frame body. Name resolution, evaluation and admission take place where a value is actually consumed under the corresponding contract.

<a id="structure-result"></a>
The result of `fn` may be a Structure with several fields; it is described in the result position: `fn: myFn () (int: x; int: y; int: z)`. The result's fields are fields of an already existing Structure: in the call `(a, b, c) := myFn()` it consists of the caller's places written as a Structure to the left of `:=` ([group assignment](#group-assign)), and the function fills them by position; this is an assignment between unnamed Structures, the general case of assignment and not a special form (the author's decision of 2026-11-16, [journal](../LMX_blog/2026-11-16.md#unnamed-structure-executes)). `return` completes their updates and forwards that Structure; the control transfer itself neither allocates nor copies it. Multiple values in the `return` tail populate the signature-defined fields of the same Structure in order: `return: 1 2 3`. There is no separate receiver `fm` for such a result (author's decision of 2026-11-10, [journal](../LMX_blog/2026-11-10.md)). This is not implemented yet: until the step of the [plan](../next_core_tasks_v3.md#m6) the word `fm` stays in the code of the translator and the interpreter.

The shorthand with the function's name to the left of `:=`, such as `square := x * x` inside `square`, is admitted only if the receiving `fn` defines a same-named local result slot: the value is written into that slot, and nothing is assigned to the name of the function -- the names of functions are not assigned ([the roles `data` and `code`](#data-code-roles)). It does not replace the persistent callable reference. Without that contract the form is rejected. Structural closing with `end: f` adds no implicit value return; explicit `return: value` is the core form.

A returned reference preserves its exact target identity. Constructing a result, if necessary, belongs to evaluation of the returned expression, not the transfer operation. Returning from a nested function ends its activation, not automatically the entire actor. Exit and cleanup ordering is defined under [exits](#exits).

<a id="publication"></a>
<a id="dynamic"></a>
## 12. Dynamic inputs and working state

Value storage at a declaration in the complete Structure, a working value of the current activation, an explicit formal argument and a dynamic input must be distinguished. They have distinct mutation rules; a working copy does not create a second persistent graph. Ordinary passing copies a mutable primitive's value and a Structure or Array's reference; the special identity of an immutable value is retained under [qualification](#qualification).

For a free name, the called expression receives the current value from the caller's available context; if unavailable, permitted lexical lookup follows `node`. Own declarations and formal parameters have their respective resolved locations rather than being searched in a global registry. The called expression's own free names are part of its interface: adding a free name to its body changes that expression's interface. Names needed only by the expressions it calls are not part of its interface and do not accumulate along call chains (there is no transitive closure; the author's clarification of 2026-11-01): a forwarding expression declares and passes nothing. A free name with no source -- no binding along the chain of activations and no lexical source -- makes the call inadmissible; silently creating zero or a new field during execution is prohibited. This is a rule about a free name, not about a declared input place of `data`: a declared input without a value does not make the call refuse (the author's decision of 2026-11-16, [journal](../LMX_blog/2026-11-16.md#optional-inputs-required)). An existing `data` field and a free input's value are distinct places; matching names do not copy the value. A callable's formal is not a free name of its body: it receives the supplied argument or its default value ([§11](#callables)), and without them it stays "T without initialization" and does not make the call refuse ([the `call` and `fncall` receivers](#call-receivers)); the source priority below does not extend to an omitted formal. A free name's type is the type of the value of the selected binding, known when the value is used, not a static closure over the callers: one and the same called expression accepts bindings of different types. The receiving place -- a declared local or field, a result, a formal argument, a write through the name itself -- admits that value by the executor's one admission by the place's type; a literal beside such a value takes its type; a type mismatch in an operation or at a reception is the implicit `convert` throw ([exits](#exits)), never a silent conversion.

A free name's sources have this priority: the caller's nearest current local binding eligible for dynamic binding, then its already inherited dynamic input, then the callee's lexical lookup. Fields marked `private:` are excluded only from dynamic selection ([below](#private-binding)). A local binding includes a used own field, formal argument, result or another receiver-defined local value. The sources are consulted along the chain of activations when the called expression is entered: its own free names, and only those, are resolved through the activation records of its callers, nearest binding first; no static closure of requirements along call chains, mutual recursion included, is computed (the translator does not analyse code for its execution; the author's clarification of 2026-11-01). A name needed only by the next call requires neither forwarding nor a local value; by itself it creates no graph field. It follows that a method which itself consumes the name forms its activation's value of it from these same sources, its own lexical lookup included, and that formed value belongs to its available context subject to `private:`: when dynamic binding is permitted, what it calls receives it, whichever source gave it. A method that only forwards the name forms nothing: an entry that arrived absent travels on absent, and the eventual consumer uses its own lexical lookup. Assigning the name changes that activation's value only, and an explicit `node\x` read forms no binding.

For a name consumed by this activation, including in an explicit throw's payload, its binding is selected at entry from the context available at the call site. The selected value or computed description is held independently of later replacement of the source field; this does not execute a computed declaration at entry. The rule is the same for explicit data, a dynamic input, and a lexical fallback source. An unused computed input is not executed. A name merely forwarded to the next call is not read early and receives no local value. Declaring a nested callable does not execute its body; its free inputs bind when it is called.

Lexical lookup follows real Structure links to a zero parent and selects the sole field of the required name at the relevant level ([names](#fields)). `independent` cuts the external lexical fallback. Explicit `node\x`, `reference\x` and `array[index]` address the graph rather than being replaced by a dynamic `x`; a context copied by `merge` participates only as fallback ([composition](#composition)).

<a id="private-binding"></a>
### Receiver private: and dynamic binding

Dynamic binding is when the callee sees the fields of the caller instead of the fields of its own `node`: it concerns that part of the hidden arguments which the caller supplies with its own fields because the callee expected them without listing them in its `data` and without taking them from `node`; lexical binding exists as well, so lexical fields cannot be hidden by anything, and reading a field out of a Structure by a path is no binding at all: everything is always visible there (the author's definition of 2026-11-17, [journal](../LMX_blog/2026-11-17.md#dynamic-binding-definition)). Receiver `private:` excludes the marked field from the sources of dynamic binding for calls. This is a property of that particular field and its corresponding binding, not a ban on the name's spelling. Dynamic-input lookup skips that field; further selection follows the ordinary source order.

The field remains directly visible from anywhere: explicit paths such as `S\field` and ordinary lexical lookup remain available. The receiver introduces no access boundary, does not change sequential visibility, and does not prohibit explicitly passing the value as an argument. Resolving the field through ordinary lexical lookup is not dynamic binding. Neither is a code's reading of a field of its own launch data: in `call(D C)` with `D: private: int: x 5` the code `C` reads `x` as its own input place and gets 5, while what `C` calls does not get its free `x` from that field -- `private` forbids only dynamic binding (the author's clarification of 2026-11-17, [journal](../LMX_blog/2026-11-17.md#private-only-dynamic)).

The rule is identical for ordinary calls, Structure launches and all `call`/`fncall` forms, in the interpreter and native execution. The existing common binding mechanism applies it when selecting a binding; it requires no separate name-denial tables, protected value type, or checks on every direct read.

The record of the receiver `private:` lies in the clean graph like the records of the other receivers; the graph holds no signs of places and no other hidden data: the walker executes the receiver from the graph, and the translator decides from the same graph which hidden arguments to insert (the author's decision of 2026-11-17, [journal](../LMX_blog/2026-11-17.md#no-place-signs)).

[Author's words](../LMX_blog/2026-11-15.md#private-binding).

<a id="private-examples"></a>
#### Examples of private: in data and code

These examples show the specified semantics; implementing private remains an [M14 task](../next_core_tasks_v3.md#private-binding-plan). They use ordinary receiver composition: `private: int: x 10` marks the declared field x. The receiver's action needs one argument, so several arguments may be passed and the action applies to each in turn: `private: int: x 10; int: y 20`, `private(int: x 10; int: y 20)` and a block under `private:` with two declarations mark x and y, as two forms with one argument each do (the author's clarifications of 2026-11-18, [journal](../LMX_blog/2026-11-18.md#private-required-many-arguments), [journal](../LMX_blog/2026-11-18.md#no-group-form-for-modifiers)). `private` takes its arguments as `data` and does not unwrap an argument that is itself a Structure ([two kinds of receivers](#two-kinds-of-receivers)): in `private: (int: x 10)` the argument is an anonymous Structure with the field x, not a declaration of the field x; as a declaration argument it is written in `private: int: x 10` and in `private(int: x 10)` (the author's clarification of 2026-11-18, [journal](../LMX_blog/2026-11-18.md#arguments-by-number-and-form)). When a call executes the declaration, no field named private arises: x is declared. In the graph every receiver lies exactly as it is written -- the graph is already what the paths `data\...` read (the author's clarification of 2026-11-17, [journal](../LMX_blog/2026-11-17.md#graph-is-data)).

In the data role:

~~~lmx
Library:
    private: int: x 10
    fn: read () int (return: x)
~~~

Field Library\x holds 10. If Library\read() has no other eligible dynamic x, its free name x is found in its lexical parent Library, and the result is 10. Private does not prevent this: the field was selected lexically.

In the code role:

~~~lmx
fn: run () int
    private: int: x 20
    x := 21
    return: Library\read()
~~~

Bare x inside run is available after its declaration; assignment changes its local cell to 21. This value is excluded from the next call's dynamic sources, so, with no other dynamic x, Library\read() uses lexical Library\x and returns 10. Removing private only from the declaration inside run changes the result to 21: the ordinary dynamic source precedes the lexical source. Private on Library\x does not prohibit selecting a different, unmarked dynamic source.

Direct access in code remains:

~~~lmx
Library\x := 30
int: observed Library\x
~~~

`observed` receives 30 regardless of same-named dynamic variables. A later run() returns 30 through lexical lookup under the same conditions. Private does not make the field const. The value may also be passed explicitly: f(Library\x) follows f's ordinary contract.

In run, bare x and source run\code\x remain distinct places under the [frame rule](#call-frame-20261115): after local x := 21, the source declaration still holds 20. Private introduces neither write-back nor a restriction on direct access.

<a id="required-receiver"></a>
### Receiver required: checking that a field is initialized

The receiver `required` checks that a field is initialized. It checks exactly initialization -- the presence of a value given by the declaration, by a supplied actual or by an assignment -- and does not declare the argument mandatory: all declared input places of `data` are optional, and an input without a value does not make the call refuse ([the `call` and `fncall` receivers](#call-receivers)). A place that holds "T without initialization" does not pass the check.

`required` may be written anywhere: all Structures are interchangeable, and it is not known in advance which one ends up in which role (the author's answer of 2026-11-16, [journal](../LMX_blog/2026-11-16.md#required-anywhere)). There is no restriction on which declaration it stands in -- just as `private:` has none ([receiver private:](#private-binding)): `required: int: a` is the ordinary composition of declaration receivers that marks the declared field `a`; when a call executes it, no field named `required` arises, while in the graph the record lies as it is written ([journal](../LMX_blog/2026-11-17.md#graph-is-data)). The check of an already visible field may also be written as a separate line -- `required: a`. There may be several arguments -- `required: a b c`, `required: int: a; int: b`, `required(int: a; int: b)`: the action needs one argument, and the receiver applies it to each in turn, in the written order (the author's clarification of 2026-11-18, [journal](../LMX_blog/2026-11-18.md#private-required-many-arguments)). All combinations are possible -- in `data` and in `code`, as a mark of a declaration and as a line with the name of a field -- and so is any number of checks of one variable: in `code` each runs on its own line and does not interfere with the others. These are different paths to one check, and neither needs a separate pass: on entry to a callable there are no initialization passes besides the supply of arguments, and the rest is executed when reached ([call frame](#call-frame-20261115)).

`required` in the input `data` of a launch is checked when the arguments are supplied -- the one action of the entry that passes over the input places anyway: if the place received neither a value of its declaration nor a supplied actual, it is an error, and no record of `code` is executed. A `required` form in `code` -- a marked declaration or the line `required: a` -- is checked on that same line, when execution reaches it: for a declaration after its ordinary action, the check of the type with an assignment, for the line with a name by the field found at that place under the general [visibility](#declaration-visibility) rules.

`required` does not change the visibility rules, and from this follows where it does not act (the executor's conclusion at the author's request -- [answers](../LMX_blog/q/fable-self-answers-20261110.md), Р29). The mark belongs to its declaration and fires only where that declaration itself acts -- as an input place of a launch or as a reached record of code. It adds no condition to binding: the marked field remains visible and accessible under the general rules -- lexically, dynamically and by an explicit path -- and a callable that received it as a free name is not checked by this mark. The line `required: a` does not see a variable declared below it, nor a name of a branch after the branch is left: such a name is looked up in the ordinary way among the available outer and dynamic bindings. The check runs once; it does not affect later writes into the field.

```text
fn: f (required: int: a) int
    return: a
end: f

fn: g (int: a) int
    required: a
    return: a
end: g

f(7)
f()
g(7)
g()
```

`f(7)` and `g(7)` return 7: the field `a` is initialized by the supplied actual. `f()` gives an error when the arguments are supplied, before the first record of `code`: the marked input `a` received neither a value of its declaration nor a supplied actual. `g()` refuses on the first line of `code`, without executing the other records. A value in the declaration -- `required: int: a 5` for `f`, `int: a 5` for `g` -- makes the field initialized: `f()` and `g()` return 5.

The kind of the `required` refusal is the refusal of input admission for a marked declaration of `data` and the refusal of a reached form in `code` (the executor's reading -- [answers](../LMX_blog/q/fable-self-answers-20261110.md), Р31); its exact form is settled at implementation ([plan](../next_core_tasks_v3.md#m10)). The rule is the same for an ordinary call, a Structure launch and all forms of `call`/`fncall`, in the interpreter and in native code. It is not implemented yet.

[The author's words](../LMX_blog/2026-11-16.md#optional-inputs-required), [the answer on where it is written](../LMX_blog/2026-11-16.md#required-anywhere).

<a id="call-frame-20261115"></a>
### Call frames without write-back — decision of 2026-11-15

For `fn`, `sub`, and `catch`, there is one input `data`; the `args` of `call`/`fncall` supplies actual values under the [common launch contract](#call-receivers). Every call, including ordinary `call(D, C)`, creates its own namespace and local places. Positional and named actuals map to the input description. A supplied actual replaces the corresponding source declaration in the frame: its source initializer is not executed at all. Call entry does not execute initializers of omitted fields.

Namespace preparation collects only declarations at the roots of `data` and `code`, without executing their computed parts. It visits neither lexical branches nor graph reference edges. Code's own places absent from the input data belong to this call and are not appended to source data. Collecting places does not override sequential visibility of variables and `const`. Nothing is auto-filled in the graph.

Ready data receives its ordinary initialization during clean-graph construction without program calls: for example, `int: i 5` folds into a named int cell through the existing mechanism. A computed declaration retains its written code. There is no separate entry phase that executes it: in `mark(); int: y makeValue()`, makeValue() runs when the declaration is reached, after mark(). An unused computed input-data field is not executed. Types without a value (`uninit:T`) remain; an absent initializer is not replaced by a random ordinary T.

Bare `x` and `@x` refer to this call's local place. After entry it is independent of later replacement of `data\x` or another source field, equally for explicit data, lexical binding, and dynamic binding. The value or computed description selected at entry is held without executing the RHS at entry. This does not deep-copy all referenced objects: explicitly passed references retain target identity. Local assignment does not write back. `data\x` and `code\x` access the source graph; explicit writes are observed through its actual aliases in execution order. For `p\x`, the current local value of p selects the referent.

Reading a computed place by a bare name is the work of the call: it executes the declaration's already written expression rather than inventing a nullary call on the resulting reference. The explicit path `data\field` executes nothing and reads the record of the declaration ([explicit path](#path-reads-no-execution)). Given source `@: fptr getFuncPtr()`, `fptr("hello world")` first runs getFuncPtr(), then calls the obtained function. `fptr := 0` changes only the namespace; `data\fptr := 0` changes the source field so that it reads as `@: fptr 0`. Changing that source field before the first bare fptr read does not change the frame description selected at entry.

<a id="path-reads-no-execution"></a>
#### An explicit path executes nothing

The author's decision of 2026-11-17 ([journal](../LMX_blog/2026-11-17.md#path-reads-no-execution)); it withdraws the former rule under which reading a computed declaration by a path executed it. An explicit path -- `struct\field`, `data\field` -- reads what is written in the graph and makes no call. If the field is declared with a ready value, `int: field 5`, the path gives that value, the number 5 of type `int`. If the declaration is computed, `int: field f()`, the path gives the record of the declaration itself -- the Structure of the receiver with the name and the written call; `f()` is not executed. An expression is no different from a call: for `int: field 5 * 2` the path returns not 10 but the full Structure that begins with `int:` (the author's clarification, [journal](../LMX_blog/2026-11-17.md#path-returns-record-not-value)). Likewise `data\S` for the record `S: merge: A B` executes no `merge` and gives the record.

A computed declaration is executed by a call, and by it alone: a call prepares its namespace from the root declarations of its data and executes the written expression when it refers to its local place by a bare name ([call frame](#call-frame-20261115)). That work of the call stays as it was: there is no general initialization, a call prepares a place on a concrete access (the author's confirmation, [journal](../LMX_blog/2026-11-17.md#call-prepares-as-before)). It has nothing to do with a read by an explicit path. Therefore `sys\toLmx` prints the records as they are written, and a write by an explicit path changes the graph itself -- with no hidden calls and no cache of results. The print of a graph comes down to the print of Structures and of primitive values already recorded in the arena with their type: by a path the receivers come back as Structures.

<a id="computed-field-address"></a>
Taking the address of a local place also obtains a computed value: for input `int: x next()`, `@x` runs next() and gives the ordinary local int cell's address. `@(data\field)` with source `int: field getValue()` addresses the record of the declaration, not the result of getValue(): an explicit path executes nothing (the author's decision of 2026-11-17, [explicit path](#path-reads-no-execution); it withdraws the former rule of 2026-11-15 under which the result was addressed). A ready place is addressed directly; place lifetime remains ordinary. `@f()` was a research example, not a separate implementation task or a request for a C-like prohibition. [The author's clarifications](../LMX_blog/2026-11-15.md#m14-address-scope).

Re-declaring an already visible name introduces no additional C variable but retains the other actions: `int: x bump()` evaluates bump(), performs ordinary admission, and assigns the existing x. A new branch name is visible from its declaration at its level and below, not outside. Two declarations in data remain two physical occurrences, `S\[0]x` and `S\[1]x`; `S\x` is ambiguous. Sequential visibility of variables and const removes the old early bare-name access to a future local. Reading a written computed declaration through an explicit path does not execute it; the RHS is executed when its code statement is reached. There are no separate exceptions or hidden computation cache.

Execution of mutable code follows [explicit compilation and the endturn boundary](#explicit-compilation). A mandatory code snapshot at entry is cancelled; selected local namespace values/descriptions remain independent. There is still no initializer-execution phase at entry.

C signatures are derived from actual calls. Different supplied argument sets yield different signatures; the full `data` description does not itself become every C entry's parameter list. A signature without `code` describes that call, not an entire particular `fn` or `sub`. Ordinary Structures and methods share body and frame compilation; `data = code` is not required.

<a id="explicit-compilation"></a>
### Explicit compilation, native, and endturn

Compilation of an explicitly selected root includes clean-graph construction and checking without program
calls, lowering to L1 and C, machine compilation, and entry registration in `call` tables.
`sys\compile(S)` invokes this shared chain; `sys\translate(S)` stops at L1 text.
Failure returns diagnostics and provides no new native entry. Complete the builder implementation first;
runtime reuses its required parts for this concrete operation, without a second compiler.

Native is an explicit descriptor: an ordinary Structure with machine-entry variants and their signatures,
references to the binary module and its entries, and L1/C source paths. Its primary storage is the `call`
tables shared by methods and ordinary Structures. Translation of fn/sub/catch adds a missing ordinary
`native` field to the clean graph, referring to that same descriptor. Other Structures receive no automatic
field. Lmx has no native header field. `sys\native(S)` obtains the descriptor through the tables;
dynamic call selects by target Structure and actual signature. Without a suitable native entry,
admissible L3 executes through the walker.

A known native-to-native call lowers directly to the selected C function: ordinary parameters and necessary
hidden binding arguments, without graph traversal, call-table lookup, universal actual packaging, or a graph
frame just to arrange the call. Explicit program accesses to data/code remain. This is the primary generation
route, not a deferred optimization.

A write immediately changes the addressed graph and is not tracked for native. It neither clears entries
nor starts checking or compilation, and maintains no reverse machine-code dependencies. Remove those
traversals, tables, transfers, and generator branches together with the checks. Ordinary memory/reference
duties remain; they are not native-freshness tracking. Without explicit compilation a graph edit promises
neither updated machine code nor automatic program repair.

Before the turn ends, the time an edit affects execution is unspecified: the walker may see it before native.
Copying code to equalize this timing is unnecessary, including the former per-C-function code snapshot.
Selected namespace places remain independent of source data; bindings use hidden arguments and the lexical
environment is not copied. After successful explicit compilation and endturn, the next entry uses the
prepared update. Endturn alone neither detects edits nor checks or compiles the graph.

A direct C call A→B belongs to compiled A. Recompiling only B does not rewrite old A: updating that chain
requires explicitly compiling a common unit containing the needed callers and targets. This is compilation
work, without observing assignments or looking up native before each direct call. Old active machine frames,
including finally, must finish before their machine code is released.
[Author's decisions](../LMX_blog/2026-11-15-explicit-compilation.md).


<a id="direct-access-cache"></a>
### Direct access without a separate language cache

The proposed direct-access cache shared across calls is cancelled together with load-dirty. A direct access reads or writes the addressed cell; aliases observe sequential writes. A local variable remains a separate place in its current frame. Ordinary compiler optimizations may preserve these rules but introduce no language states, coherence tables, or mandatory checkpoints.

<a id="flush-receiver-contract"></a>
### Removal of local-frame publication and flush()

Neither the `data` nor the `code` frame is published into the graph. Remove load-dirty, write-back at calls and exits, the shared direct-access cache, and the proposed `flush()` receiver. Earlier examples of an outer published `x = 2` and an inner published `x = 9` describe the superseded model. These are now independent local places; only explicit operations change the original graph. Message publication and exposing a construction result are different operations and are not cancelled.

<a id="activation-history"></a>
### Activations and agreed boundaries

The call stack remains the sole implicit activation history: the ordinary C stack for native and the corresponding control stack for the interpreter. Recursive and nested calls have different local cells, including different `@x` addresses. Return, `throw`, `finally`, `retry`, and `yield` introduce no write-back of these cells. Explicitly passed references preserve their targets' identity.

The earlier M14 questions are resolved: entry executes no initializers; variables and const have sequential visibility; a computed declaration is executed when its statement is reached and when the call reads its local place, and an explicit path does not execute it; the mandatory code snapshot is replaced by explicit compilation and the endturn boundary; short fn/sub/catch headers remain with unified data. Frame-place independence and the address by a path to a computed declaration are also specified above. This is agreed semantics, not a claim of completed implementation. [The author's answers](../LMX_blog/2026-11-15.md), [later clarification](../LMX_blog/2026-11-15-explicit-compilation.md), [single implementation plan](../next_core_tasks_v3.md#native-structures).

<a id="branches"></a>
## 13. Branches and loops

Control receivers determine how their structural bodies are consumed. Membership in a body does not require immediate execution of all its fields. Control labels denote visible transfer targets; mentioning a label neither invokes its body nor constitutes an implicit `goto`. The chapter describes how control receivers act in the role of code. In data a form of a control receiver -- `if`, `for` and the others -- is a Structure named by its head: it is not executed, and it is reached by a path through its head -- `data\if`, a nested one by `data\if\if`, with the index of an occurrence when several bear one name ([the roles `data` and `code`](#data-code-roles)).

`if` evaluates its condition once and executes its body when true. An immediately following sibling `else` executes only when false. Another statement between them breaks the pair. A profile-specific `branch` with named branches may exist separately and does not replace this contract.

`match` selects a suitable branch using expressed patterns. Branches can be pattern/body pairs or explicit Structures according to the profile; `default` is a profile-defined pattern, not a universal effect of an arbitrary name. Pattern union and exhaustive-coverage requirements belong to the contract. There is no automatic fallthrough unless explicitly defined.

`while` checks its condition before each iteration and can execute its body zero times. Closing `until` establishes a postcondition: the body executes at least once and repeats while the condition is false. An anonymous body closed by `until` is such a loop in the current activation, as any control body; a named Structure closed by `until` is an ordinary named Structure whose executable body is that loop: a form of data declares it, and declaring it does not run the loop -- a launch does (by the receiver `call` or by a form launching it by name in code: `S()`, `S(D)`; see [the receivers `call` and `fncall`](#call-receivers)); in code the same form is a call of its head, not a declaration, and it is an error when the head names neither a callable nor a Structure, and also when the head is a Structure and two or more fields follow it in the form (such a form has one argument, `data`) ([the roles `data` and `code`](#data-code-roles)). Core `for` contains initialization, condition, step and body; initialization runs once, followed by condition, body and step. Range shorthands require a separately selected profile and do not alter this core form.

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

`catch` is a landing pad in the caller's block, not an ordinary nested `sub`. Its body is skipped on the initial straight-line pass. When the corresponding failure arrives, its body runs and execution continues with the statements after that `catch`. Consequently, a handler before a call re-enters the following region; a handler after the call continues past itself. The region ends at the next `catch` in the same block or the block's end. The handler covers every call of its block, including calls made from statement blocks nested inside it (`if`, `while`, `for`, an anonymous `---`): a handler, like callables created by the receivers `fn`, `sub`, is visible throughout its block in both directions. A sibling block is not covered. This is bidirectional visibility of a callable name, not of all data places. Variables, including `const` and variables holding method pointers, are visible sequentially; names of named Structures and callables are visible in both directions under the [common visibility rule](#declaration-visibility).

Two same-named handlers in one block are prohibited; separate nested blocks can each have one. Delivery selects the handler by the calling block, not a same-named handler in a sibling block. Throwing the same name inside a handler does not re-enter it: this is a failure in the enclosing calling context. An unhandled name propagates only through matching `throws` declarations.

Language operators whose `throws` list the programmer does not see written out (for example `merge`) also throw a named failure, but catching it is optional: a `catch: merge` handler -- before the call, after it, or in a separate nested block -- handles it in the ordinary way and nothing flies anywhere; an uncaught implicit failure flies to the root of the executing Message and the Thread stops (`running = 0`). The only placement constraint is the one declared names have: two same-named `catch` handlers cannot compete at one level.

If the interpreter detects an error in an operation while executing a correctly constructed graph, it raises an ordinary implicit failure with the single name `interpreter`. `catch: interpreter ()` receives it under the same scope and propagation rules as other implicit failures; there is no separate interpreter-exception channel. An error while constructing the source graph during translation, a malformed graph, or a violated kernel invariant is not such a failure: it is a diagnostic of the corresponding stage, which the executing program's `catch` cannot intercept.

Worked example from the older specification (`lingvamyxa_prev/tests/t2.lmx`): handlers before the call in separate anonymous blocks, and a handler after the blocks. Each `checkedGreeting(...)` call stands at its `catch`'s level, after the handler; the older specification's rendering put it inside the handler body by an indentation slip, so the example here follows the original (tab = 8). Only the notation of the formal `cfg` is changed: a formal that receives a reference to a Structure is declared by the receiver `@`, `@: cfg HelloConfig` -- the original has `HelloConfig(cfg)`, and a structural form is forbidden in the description of the formals ([the roles `data` and `code`](#data-code-roles)). The formal `Text: badText` is unchanged: its head `Text` is a primitive, a receiver of a place, not a Structure.

```text
fn: checkedGreeting (@: cfg HelloConfig) (Text)
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

`checkedGreeting` may leave by `return: cfg\greeting` or by `throw`. The empty `GreetingRetry ()` catch parameters mean this landing pad takes no payload fields; it mutates the outer `cfg` or `emptyCfg`. `GreetingSkip` binds `cfg\greeting` from `throw: GreetingSkip(cfg\greeting)` to `badText`. Each anonymous `---` block owns one `GreetingRetry` catch and one call, so the two `GreetingRetry` names are not duplicates; the repeat call from the handler is a new activation. `GreetingSkip` sits in `helloMain` after those blocks, so a skip continues at the statements after that `catch`. The example shows the placement of `catch`; the rest of it is left in the notation of the original. In `helloMain` the lines `HelloConfig: cfg` and `HelloConfig: emptyCfg` with the fields `greeting`, `maxI`, `maxJ` are, by the meaning of the example, forms of data, they declare Structures; its other lines -- the `---` blocks with a `catch` and a call and the last `catch` -- are forms of code. There are no declarations of Structures in code: in the notation of the original these lines stand among the executed forms of the method, and `HelloConfig: cfg` there is not a declaration but a launch of the Structure `HelloConfig` with its own tail in the place of the argument; the form has one argument, `data`, and a tail of two fields -- the atom `cfg` and the unnamed Structure of the block, which holds `greeting`, `maxI`, `maxJ` -- is not one argument, so the form is an error (the author's decision of 2026-11-11, [journal](../LMX_blog/2026-11-11.md#structure-call-by-name); the executor's reading -- [answers](../LMX_blog/q/fable-self-answers-20261110.md), Р21; Р25, item 7). So under the present rules such declarations are written in data -- in the `data` part of the method ([the roles `data` and `code`](#data-code-roles)).

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

An ordinary Structure and a reference Array `Array<@>` are fully interchangeable: indexing, named paths where names exist, `length`, admission, copying, execution, `sys\typeof` and `sys\descriptor` use the common contract. An ARRAY/STRUCT category alone is no reason for refusal. `length` reads the header field `length`; `parent/length/storage` are not counted as elements. A numeric `Array<T>` stores T directly. Structures, Arrays, and service lists share length and capacity management. Finite rectangular Array rank has no fixed limit and is independent of pointer depth. [Approved layout](L2_spec_en.md#lmx) and [open M13 implementation](../next_core_tasks_v3.md#flat-lmx-descriptor).

An ordinary Array is a typed graph Structure with stable reference identity. Constructor `[]` creates it when execution reaches the construction site. In `[]: arr ( ... )`, binding occurrence `arr` belongs to the current Structure, the Array's structural parent is that `arr` occurrence, and structural elements materialized from the arguments have the Array as their parent. Parentheses around the arguments create no extra anonymous wrapper in the Array: P0 does not unwrap them, but the receiver `[]` reads the Structure written in them by its own contract, as the list of its arguments ([general rule](#values)). In data `MyLmxStructFromArray: arr` declares a Structure `MyLmxStructFromArray` with the one atom `arr`; that atom is a pointer to **that same Array**, a reference immutable by name: in the tree under `MyLmxStructFromArray` stands only the atom, the Array is neither reconstructed nor copied, and its `parent` does not change ([declaring a Structure](#colon-declares)); a pointer variable to that same Array is declared by `@: p arr`, and in code the form `MyLmxStructFromArray: arr` is a call of its head. A Structure field holding an Array reference is not the Array itself. Passing a reference does not copy elements; an element mutation is visible through other references, whereas rebinding a local reference is not.

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
A Structure and `Array<@>` are addressed identically. `S[i]` reads a `void*` from physical `storage`; `S[i] := p` stores another `void*` there. This operation neither checks nor transfers a former field's requirement, name, or cell kind: it is simply a write of a value into the array, without checks (the author's clarification of 2026-11-17, [journal](../LMX_blog/2026-11-17.md#index-write-plain)). Slot count and addresses do not change. Names and types are interpreted from current content when subsequently needed; the write itself does not assign a name to the slot. `S\[N]field` and `voidarray\[N]field` structurally select the Nth occurrence under the named field contract. An ordinary typed `Array<T>` retains its element representation. `length(S)` reads the element count. Remove former `slot_prepare`/`slot_admit` and frozen-slot-fact copying for index writes with their supporting tables and generator branches ([plan](../next_core_tasks_v3.md#call-frame-20261115)).

<a id="get-type"></a>
The receiver `sys\typeof(arg)` returns the code of the type of the arena region that holds the address `arg`: `sys\typeof(S[i])` is the type of the cell of a field's value, `sys\typeof(@i)` the type of the cell of `i`, `sys\typeof(S)` the type of a Structure's header. The argument is an address or a reference; a value that is not an address, such as an `int`, is an error. For zero and for an address outside the Message's arena the result is the "no type" code, not an error. The codes are the kernel's inventory of region types ([implementation specification](../docs/kernel-implementation.en.md#arena)): a program compares the result with its named constants, reachable through the door (`c.LMX_TYPE_INT` and others); their numeric values are not fixed by the norm and change with the arena's design. The receiver acts the same in the interpreter and in `native` (author's decision of 2026-11-10, [journal](../LMX_blog/2026-11-10.md)). It is implemented in the clean graph — in its interpreter and in the `native` code it emits; the door's constants are not reachable in the clean graph yet, and the earlier lowering path does not know the receiver ([plan](../next_core_tasks_v3.md#m6)). Before the renaming of 2026-11-10 the receiver was called `getType` ([journal](../LMX_blog/2026-11-10.md#renames)).

Built-in machine element types retain their [C99 target-profile meaning](L2_spec_en.md#lowlevel-scope), including plain `char` signedness; a descriptor does not redefine them. L3 adds checked access, not a different primitive representation.

A full N-dimensional rectangular Array index contains N integer coordinates. For a rectangular Array, coordinates are reduced to one linear element index in row-major order: `k = (...((i0 * d1 + i1) * d2 + i2)...)`. L3 checks only the final element against the descriptor's total length: `0 <= k < length(array)`. It does not check each coordinate against its dimension or store a vector of dimension lengths for those checks. For example, in a `[2,3]` rectangle, `[0,3]` has linear index 3 and selects the same element as `[1,0]`; linear index 6 raises implicit `throw: interpreter` rather than returning `None`. Computing the index must not wrap an out-of-range mathematical result into a valid element. An Array of references to Arrays is different: each step accesses another actual Array with its own descriptor.

Adjacent indices `matrix[i][j]` address one flat Array using strides known from its description, whereas `a[i]\[j]` addresses the previously selected value after `` ([paths](#fields)). The descriptor does not recover dimensions, and an incomplete index spelling does not by itself construct a separate row Array or hidden view descriptor. These access checks are made by L3, whether executed natively or interpreted, and by the interpreter when it executes L2 code; native [L2 access](L2_spec_en.md#lowlevel-address), including obtaining a graph-backed element's address, works without them (the author's decision of 2026-11-18, [journal](../LMX_blog/2026-11-18.md#interpreter-runs-l2)). Operation checks do not constitute a separate candidate-admission mechanism in place of [analysis and unit tests](#admission).

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

The default expression profile is pure: it admits only operations with declared pure contracts. `sqrt`, `sin`, `cos`, `pow`, `abs`, `gcd`, rounding and arithmetic may have such wrappers. Effectful operations remain valid high-level receivers but do not become pure by being written in an expression. L3 does not prohibit effects generally or derive authority solely from a level number.

A low-level function with raw pointers has no direct L3 call. A high-level wrapper defines ownership, borrow duration, null policy, bounds, element type, mutation, failures and result. Without it only the machine side of [L2](L2_spec_en.md#lowlevel-abi) is available. Numeric-backend initialization and release normally belong to the provider; user numeric code should not manually reproduce its internal storage management.

A `real` context may define precision, rounding, status, traps and exactness requirements; `decimal` additionally includes exponent limits and quantization. Context is explicitly reachable data or fixed profile configuration, not hidden global state. Exact context receiver names remain profile-specific. A deterministic profile must exclude dependence on unspecified platform settings.

Arrays use the same scalar operations and contexts. Vectorization, reduction and tensor operations do not create a different meaning of addition. The minimal mathematics profile includes basic arithmetic, Boolean operations, comparisons, construction/arithmetic for the three extended numeric families, explicit conversions, selected pure functions and numeric-Array operations. It does not imply exposure of the entire C library.

<a id="composition"></a>
## 20. Composition and graph copying

`merge` is an executable operation over live structural operands. It is neither a preprocessor include, C-type composition nor mutation of source values. Operands are evaluated once left-to-right; a fresh root is then built with direct fields in operand and appended-body order. A previous `merge` result can itself be an operand.

The complete used graph is copied with required references and lexical chains to a zero parent. One source-to-copy map spans all operands: shared targets remain shared, cycles are preserved, and references and `parent` links are explicitly rewritten. Operand roots and necessary lexical ancestors do not become extra visible result fields. Parent links are rewritten inside the copy to the corresponding copies of the source nodes; the place that executes `merge` neither supplies a new lexical parent nor re-resolves the body's names. For ordinary copied targets, preservation of relationships means that the result's links refer to the corresponding copied objects, not to the original graph; retention of original targets is limited to reusable native implementation references and the admitted `independent: immutable` branch (below), with optional `const`. The rule is universal for every `merge`, not a special case of child Message creation, and it has no implicit shared-mutable exception: separate mutable instances come from a prototype template, initializing the concrete instance through arguments; shared immutable values are an `independent: immutable` branch; deliberately shared storage is a Message ([delivery](#delivery)). A reference field `@: p T` is a pointer cell, and it is copied together with its pointee through the same map. Preserving relationships inside a copy does not bind arguments or change dynamic-input precedence.

A reference inside the copied graph does not create an extra instance of its pointee. The same map redirects it to the instance already produced by copying and composition. For example, let data declare `Holder: @: p Model` -- a Structure `Holder` with the pointer variable `p` to `Model` -- and let the form `@: R merge(Model; Holder)` declare the pointer variable `R` in data and assign the result to it in code: the new instance of the first operand `Model` forms that result; copied `p` points to that instance, neither creating a third copy of `Model` nor retaining an address into the original arena. If a reference targets another copied node, it selects that node's already-created copy. Required lexical ancestors follow the same rule: their `parent` links and internal references are redirected through the common map, not through a separate visibility mechanism. Typed access through the redirected reference uses proved address correspondence, through the prepared physical map rather than a new name lookup. A mention of a known Structure in a form of data (`Struct1: Struct2`) is not expanded: in the tree under `Struct1` stands one atom, a pointer to `Struct2` ([declaring a Structure](#colon-declares)); in copying and traversals it behaves as a reference, not as a field with a subtree (the executor's reading -- [answers](../LMX_blog/q/fable-self-answers-20261110.md), Р3).

Traversal of the complete used graph does not itself grant access to a protected branch or authority to export its contents. Composition preserves the [selected object-protection contract](#protected-structures); `merge` is not an alternative route for opening a protected context.

A reference to a method's reusable native implementation is a terminal under its contract: the implementation receives the graph with which it executes, and its address is not the identity of that graph or of its lexical environment; it is not a shared reference to a mutable callable occurrence or to its lexical context. When `merge` encounters an [eternal branch](#eternal) qualified `independent: immutable` (including one additionally qualified `const`), it MUST **not copy** it and MUST place the original physical value reference directly into the result -- the explicit, single exception to the general copying rule for a graph branch: its root has no external lexical parent and its entire selected graph, including stored references, has passed the immutable preflight before publication. If that guarantee cannot be established, construction/qualification is refused; a merely labelled branch is not retained and copying it is not a fallback for failed qualification. The combination of `independent` and `immutable` grants the exception; `const` has its own contract but is not required for retention. Neither `independent` alone, a null parent alone, nor `immutable` alone grants retention. The existing qualification and lifetime contracts apply, and there is no new flag, receiver or registry. Physical identity is preserved and the source module remains the owner. An implementation and an eternal branch are different kinds of retained material, even where both are called terminals. Range-index visibility and bookkeeping occur inside merge/classification; they are neither a separate visible operation nor an alternative to `merge`. Other used mutable state receives distinct storage, and the algorithm leaves no references into another mutable arena.

<a id="merge-two-forms"></a>
### The two records of `merge`: a receiver in code and a declaration form in data

The author's decision of 2026-11-17 ([journal](../LMX_blog/2026-11-17.md#merge-two-forms), [answer](../LMX_blog/2026-11-17.md#merge-data-form-no-calls)). A record of `merge` is read by its role, and it has two roles with different records.

In the role of code `merge` is a receiver whose arguments behave as code, with an assignment on the left and without one. `T := merge(A; B())` executes the composition over the live operands and assigns the result to the pointer variable `T`; `merge(A; B())` in the place of a value gives the result to the expression; `B()` among the arguments is a call. In data the record with an assignment is not executed, as every assignment ([the roles `data` and `code`](#data-code-roles)).

In the role of data the composition is declared by the named form: the declared Structure is named, as usual, through a colon -- `S: merge: A B()` -- and inside such a `merge` there are no calls, only declarations of Structures. The operand word `A` names a known Structure; the operand form `B()` declares the Structure `B` by the general rule of data, as every structural record in this role does; nothing is executed. In code the same record is a call of `S` with the argument that `merge` returned: the arguments of `merge` are read as code there too, so `S: merge: A() B()` executes two calls, while in data the same line is declarations only and the declared Structures go into `merge` without calls ([structural forms](#forms-declare-or-call); the author's confirmation -- [journal](../LMX_blog/2026-11-17.md#merge-forms-confirmed)).

The record `@: R merge(A; B)` remains the declaration of a pointer variable: the candidate is an argument of the receiver `@:`, it is read as code and executed when a call reads that place by a bare name. The record of the data form stays in the clean graph as written and is not expanded at construction: "the other receivers are placed in the clean graph directly" ([journal](../LMX_blog/2026-11-11.md#single-structure-index-path)). The explicit path `data\S` executes no `merge` and reads the record; the composition is prepared by the call for which `S` is a root declaration of its data, when it refers to `S` by a bare name, and nothing inside it is executed ([explicit path](#path-reads-no-execution)). `sys\toLmx` prints the record ([the print of the current graph](#memory); the executor's reading -- [answers](../LMX_blog/q/fable-self-answers-20261110.md), Р43 and Р45).

This keeps the data uniform (the author's clarification of 2026-11-17, [journal](../LMX_blog/2026-11-17.md#nested-receivers-not-executed)): in data only the root declaration receivers are executed, the nested ones are not -- neither the operands of the form `merge` nor the declaration receivers inside them ([the direct pass over data](#data-root-declaration-execution)). The form differs from `int: a 1` in that `merge` returns a Structure, not a variable, and is therefore allowed in the record `Name: merge: operands`; the record `a: int: 1` as a declaration of the primitive `a` does not exist: in data it is the Structure `a`, in code a call of `a` with the argument 1 checked as `int`.

### Model slots, field matching and ordering

The first operand is the result's model. A field of a later operand or of the appended body that matches a model field (the match is known at translation: name and type; admission as for assignment) is written **into the model's slot**, not added beside it; a field with no counterpart is appended at the end in operand order. The result has the model's layout followed by the new fields, so the model's field indices never move and methods carry no hidden offset. A Frame operand `name: value` or `name(value)` is one built structure; in the arguments of `merge`, as in all arguments, it is read as code and is therefore a call of its head, which the general resolution finds ([the roles `data` and `code`](#data-code-roles)): when the head is a function, `f(3)` and `f: 3` call it once and the resulting Structure is passed to `merge`; a model field of the same name does not intercept the call (the author's clarification of 2026-11-08, [journal](../LMX_blog/2026-11-08.md)). When the head is an ordinary Structure, the same form is its launch (`f(D)` and `f: D` are in effect the same as `call(D, f)`), and a launch of a Structure has no result, as `call` has none: there is nothing to pass to `merge`, so in the place of an operand such a form is an error (the author's decision of 2026-11-11, [journal](../LMX_blog/2026-11-11.md#structure-call-by-name); the executor's reading -- [answers](../LMX_blog/q/fable-self-answers-20261110.md), Р21 and Р22, item 3); the clean graph has executed this rule since slice 356; the working frontend does not execute the launch by name ([plan M11](../next_core_tasks_v3.md#m11), step 8). A head that names neither a callable, nor a receiver, nor a Structure does not turn the Frame into a supply of a model slot: such a form is an error -- no declaration can stand among the arguments (the author's decision of 2026-11-11 on the roles); formerly, under the same clarification of 2026-11-08, such a Frame was read as a description of a structure (an expression is a Structure of the tree too) and was consumed by the general rules. A model slot is written by a field of a Structure operand, for example `(int: v 9)` in `merge(Model; (int: v 9))`: a Structure written in parentheses in the position of one value is read as data (the executor's reading -- [answers](../LMX_blog/q/fable-self-answers-20261110.md), О6) -- in it a receiver form declares the operand's field ([declaring a place](#receiver-args-only)), while `(v: 9)` declares a Structure `v` in the operand and is not an `int` place ([declaring a Structure](#colon-declares)). The clean graph reads it so: a field of the operand is declared by the receiver forms `(int: v 9)` and `(@: p int @x)`, and an operand written `(v: 9)` is a description of a structure it does not execute yet ([plan M7](../next_core_tasks_v3.md#m7)).

### Composition of structural parts

A callable Structure contains input data, return where a result is present, and code. These are ordinary addressable parts in composition; merge neither adds a separate args part nor auto-fills data from code. An ordinary Structure and an @ array use the same composition mechanism over actual fields.

### Explicit callable-body composition

A header describes inputs and the result but is not an additional merge operand and moves no fields between data and code. Input and body composition is explicit; [former separate args/data examples are withdrawn](LMX_semantics_guide.en.md#callable-description).

### Native implementation reuse and copied callable occurrences

Native descriptors belong to call's tables in the arena; an ordinary fn/sub/catch native field references such a descriptor. Copy/merge preserve these links by ordinary graph rules, but neither compile new code nor register a new native entry for their result. Explicit compilation or restoration binds the new graph to suitable machine variants. Actual-input admission keeps its ordinary contract; it is neither an edit-tracking service nor a code-identity check on every dispatch. Method implementations are not spliced together. A nested callable is copied as a Structure (except an [eternal branch](#eternal)); shared machine code does not imply a shared mutable graph.

Different physical field positions do not by themselves invalidate the selected native implementation: a successful `implements` table maps receiving-description field addresses to candidate field addresses. Correspondences compose across successive compositions. The table is not another graph, performs no repeated field-name lookup, and does not itself select the executable body.

### Returned nested methods

A returned nested method is built by the same `merge`: activation data enters a new copy, while unchanged code retains its implementation only while preserving the current address contract described above. The declared result description checks the completed callable by ordinary [admission](#admission); it is not a third operand. A copied free-name value provides lexical fallback, whereas a copied formal value provides a default; the priority of [§12](#dynamic) is unchanged. There is no hidden closure environment or partial application.

<a id="factory-reference-result"></a>

The `@:` receiver can evaluate a factory call and retain a reference to the returned method; declaring a named Structure by a form of data does not itself execute the factory, and among the executed forms the same form is a call of its head ([the roles `data` and `code`](#data-code-roles)). The stored pointer `add5` is called as `add5(1)` or `(\add5)(1)`; `\add5(1)` dereferences the returned result instead. Unary `@` is not added before the result: that would address the stored reference. A [worked example](LMX_semantics_guide.en.md#factory-result) is separate.

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
### Current-graph serialization: sys\toLmx

`sys\toLmx` emits LMX text of the current graph with canonical names and retained comments. An explicitly overwritten construct is emitted in its current form; neither history nor native reconstructs earlier source. Local execution does not publish its frame or replace the initializer in source data. This serialization differs from `sys\translate`, which returns L1 text for subsequent compilation and lowering errors.

The argument of `sys\toLmx(S)` selects the saved Structure. For an L3 Thread it also saves all tables of that Thread's arena, including call tables and native descriptors. The arena owns these tables; they are not fields of R0, and R0 is not the only eligible Thread. External arena tables are not silently attached to an arbitrary S. Preserve order and empty positions, shared references, cycles, names, and typed values: this is a reconstructable current graph, not merely source-like output. The clean graph holds no hidden data: all data lie in the `void *` storage of its Structures and are mapped by `toLmx` in an elementary way, while `length` and `parent` are derived from the text it forms (the author's decision of 2026-11-17, [journal](../LMX_blog/2026-11-17.md#clean-graph-only-data)). The table of names is restored by `fromLmx` from the text; it and the other tables of the kernel are data of the kernel itself, which builds itself and is written in L2 and L3 -- that is, the same Structures of the clean graph, not hidden data beside it ([journal](../LMX_blog/2026-11-17.md#kernel-tables-are-kernel-data)). Everything, these tables included, lies in the clean graph in LMX; on any platform there is either a compiled binary or a portable C print of the kernel itself, and hence the execution of pure LMX ([journal](../LMX_blog/2026-11-17.md#everything-is-lmx)). The C print itself is made by the translator along the path L3/L2 -> L1 -> C before the binary is compiled; the translator is written in L2 and L3, and the L1 inserts are removed in the end too ([journal](../LMX_blog/2026-11-17.md#c-print-by-translator)).

`sys\fromLmx` parses the saved graph through shared construction code and interns names in the receiving arena. Restoring a clean graph after restart on the same platform does not require retranslating the whole program. Saved native descriptors bind to ready binary modules and entry names for the corresponding ABI; old machine addresses are not copied. L1/C paths remain ordinary data but do not replace a binary-module and entry reference. The capacity table is rebuilt from allocated storage, for example capacity = length; prior reserve need not be saved. This is an implementation requirement, not a claim that the present graph dumper is complete.

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

During a turn, one L3 Message executes on exactly one OS thread; transfer to another worker is allowed only between turns. An L3 Thread has no execution mode: each call's path is set by the callable occurrence's descriptor -- with a native address the call executes natively, without one the body (the graph's op tree) is executed by the interpreter -- L2 code with the same checks as L3 code ([§1](#scope)). One call never runs both paths for one Message: the dispatcher does not retry a call through the other path after a failure and does not override the path set by the descriptor from the body or from a previous dispatch result. Choosing the path neither copies the method nor creates a second concurrent executor; the dispatcher never runs `implements` or other receiving expressions on its own.

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

Candidate admission follows the [unified mechanism](#admission): checking structural suitability for actual Consumer calls, followed by the analytical part `test`, the receiving-expression unit tests executed by the graph interpreter. Text decoding constructs the input graph before this stage; the test interpreter does not interpret source text instead of the graph.

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

`post`, `send`, and `receive` use one inbox, one set of publication/ownership rules, and one call engine. The public `send`/`receive` forms (`sendMessage`/`receiveMessage` before the renaming of 2026-11-10, [journal](../LMX_blog/2026-11-10.md#renames)), address-filtered iterator, all-available-mail option, and `0` end marker remain. One letter cannot be consumed twice by manual and protocol paths; receiving a letter as data does not itself execute its contents. An incoming call runs on the recipient's lane, while `answer` and outcome handlers run on the sender's lane. Both Thread modes (with and without an OS thread), the ordinary lifecycle up to user `success := 1`, final outbound publication, and existing supervision/stopping remain; `post` adds no second entry loop, inbox, or timer thread.

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
