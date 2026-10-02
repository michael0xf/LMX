# L2/L3 kernel: current technical map, implementation boundaries, and evidence

<a id="status-and-provenance"></a>
## 1. Status, provenance, and how to read this document

This is a technical map of the kernel that actually exists, not a replacement language specification, a new architecture proposal, or a declaration that the self-build goal has been achieved. It separates four kinds of statement:

| Label | Meaning |
| --- | --- |
| **Norm** | An accepted language or kernel requirement in the current specifications and author decisions. It remains required even where implementation is incomplete. |
| **Implementation** | A mechanism present in the inspected source. Presence in source alone does not prove that every source-language route reaches it. |
| **Verification** | A particular source snapshot and a particular executed witness or gate. Its scope does not silently extend to another interpreter, another native-word configuration, another fixture, or a later source edit. |
| **Debt** | A measured defect, missing route, unverified requirement, or remaining implementation restriction. Debt is not a new language restriction. |

The inspected development source is `build/opus_wt/dev/l2src_sandbox/`, with the L3 adapters in `build/opus_wt/dev/l3_interp/`. The exact source checkpoint is now landed in main as **`8359a59f67b87382c55eb402e9f09f9a4b1ce954`**. Repository-relative source links below use its canonical destinations under `dev/`; do not substitute an older main checkout or root `l2src/` copy.

The document was started on **2026-10-01** against main documentation commit `f980dce9bbcc9959d47cde85cb79a186277ad1ba` and completed against the released merge-result source freeze:

```text
l2trans.lm1 SHA-256
25BEE8EB02491BD3934BBC923F0C51FE57069AA86E4A2D729B8187085B80048E

owned source set
build/l2_harness/merge_value_final_focus_20261001_02/start_owned_manifest.json
25 paths, including translator, runtime, fixtures, observer, and harness
```

The focused and final restored gates are each terminal **48/48**; the preceding repair gate is **47/47**, and six direct manual dependency-closure preflights execute **174 checks**. The full generated gate is terminal **1110 targets / 1062 OK / 48 FAIL**; an independent comparison of summary rows confirms the same 48 baseline failures, ten new green rows, and no regressions, removals or duplicates. Fresh kernel **286/286** and L3 **11 suites / 295 checks plus four inventories** are terminal, and their retained transcripts were read. The combined manifest was independently rehashed as described in §15. The source writer has released the slice, and main contains the exact 25-path source checkpoint above. No claim of completed overall self-build follows from this release.

The authoritative language references are the [English semantics book](docs/LMX_semantics.en.md), its [source](provenance/semantics-book.md), [L2 specification](docs/L2_spec_en.md), [L1 specification](docs/L1_spec_en.md), and their Russian counterparts. [READ.ME](READ.ME) governs source ownership and self-build acceptance. [CORE.md](CORE.md) is an older architectural overview; it is useful context, not a substitute for checking the current implementation. The replacement planning documents are [next_core_tasks_v2.md](next_core_tasks_v2.md) and its [dictionary](next_core_tasks_dictionary_v2.md); older chronology remains in [next_core_tasks.md](next_core_tasks.md), [the implementation log](steps/native-selfbuild-20260930.md), and [defects](steps/defects.md). The plans describe acceptance/debt, not authority to continue coding after the current stop instruction.

This map does not resume application development. In particular, no application-specific state or `myxa_manager` objective is introduced into the kernel.

<a id="levels-and-build-target"></a>
## 2. Language levels and the actual build state

### 2.1 The intended division

**Norm.** L3 supplies portable structures, references, calls, admission, control flow, ownership and message behavior. L2 adds explicit machine operations and external ABI access. L1 is a syntax-directed lowering stage to C99; it is not the semantic owner of Structures, `implements`, graph identity, or Message arenas. C99 compilation produces the native binary.

```text
source with L3 semantics + explicit L2 inserts
                  |
          L2 checking/lowering
                  |
          generated L1 source
                  |
            L1 translator
                  |
                 C99
                  |
          platform toolchain
                  |
            native program

the retained portable graph ------------------> L3 graph execution
```

L3 does not become a separate native-code semantics. A portable callable can have native code, and its actual occurrence can instead be walked when its native word is absent. L2-only machine operations do not become portable interpreter operations merely because a generated test can call a native adapter for them.

### 2.2 What is present now

**Implementation.** Most runtime modules and `l2trans` are still handwritten `.lm1` in `dev/l2src_sandbox/`. L2 source fixtures are `.lm2`; L3 adapter and manual runtime suites also contain handwritten `.lm1`. The present development chain therefore still uses the existing L1 translator and host build scripts. `l1src/l1trans.lm1` understands C-layout records, prototypes, imports, expressions and machine declarations, not the full L2 graph ontology.

The fact that a runtime module is written in L1 must not be restated as permission to keep a handwritten-L1 final kernel. The accepted target is **L3 source with L2 inserts**, with L1 generated as an intermediate. The current `.lm1` code is transitional implementation material.

The active and historical source trees are distinct:

| Tree | Role |
| --- | --- |
| `dev/l2src_sandbox/` | Active runtime, translator, and generated-fixture source. |
| `dev/l3_interp/` | L3 receiver/interpreter/admission adapters and their manual suites. |
| `l1src/` | L1 lowering implementation and bootstrap-related source. |
| root `l2src/` | Older copied location; it can lag the development source. A result must state which tree was staged. |
| `build/.../src/` | A gate's copied inputs. These are evidence for that gate, not another editable source of truth. |

### 2.3 Self-build is a separate acceptance claim

**Norm.** The final language binary must build its own source, run the required tests, replace the working binary, and then the new binary must repeat the build and tests: two successful generations. A comparison of deterministic output can strengthen that evidence but is not a substitute for the two executed generations. PowerShell or Python may currently orchestrate development; they cannot be the indispensable carrier of the final self-build. A C seed is a platform bootstrap mechanism, not the final implementation language.

**Debt.** The kernel gates described below establish many concrete runtime and lowering properties. They do not establish completed §§8/8a, elimination of handwritten L1, a full source-complete graph for every accepted program, or the two-generation self-build. This distinction is essential when reporting progress.

<a id="one-graph"></a>
## 3. One program graph, containment, and executable trees

### 3.1 The semantic object is not a flat array of data fields

**Norm.** A Structure retains its source declarations, nested Structures/Frames, executable operators, and source order. A callable is not a separate METHOD descriptor pointing at an unrelated data record. A function signature, where the language supplies one, is an ordinary part of the callable Structure. A file root or ordinary named Structure does not acquire a universal implicit signature in `child[0]`.

Binary expression structure matters. A binary operator has ordered operand subexpressions; a nested receiving body has its own containment identity. Flattening a method to a bag of primitive fields loses lexical visibility, operator order, parentage, and physical address semantics. Retaining a C function and a few output fields is not equivalent to retaining the complete source graph.

**Implementation.** `Lmx` uses an ordered array of untagged references as its immediate physical field sequence. This is a representation of a graph node's edges, not a claim that the program is a flat C array. Operator Frames use `LmxOp` values and graph children. A body walks ordered children; binary and control operators recursively consume their operand/body children. Declaration cells and nested hosted-body Structures remain addressable graph objects. The typed walker recognizes these operator Frames by classified operator cells, not by parsing runtime text names.

The current graph representation includes protocol-shaped nodes such as CALL and ADMIT_AS. Their child layouts describe implementation state, not permission to substitute protocol fields for source structure; [critical_graph_bug](steps/tickets/critical_graph_bug.md) audits that distinction. A raw `void *` child carries no per-slot tag; the referenced address and its storage range establish its physical category. The normative [tree-storage architecture](docs/L2_spec_en.md#interpretable-tree) does not require an additional leaf/use record for a reference to an existing typed cell.

### 3.2 Three different relations must not be collapsed

```text
structural containment:  parent <- child Structure/body
data/reference edges:   any graph value -> referenced value (sharing/cycles allowed)
execution activation:   C/control stack + typed arguments/work/result
```

Containment determines the structural parent relation. Data references may form shared subgraphs and cycles without making containment itself a cyclic parent chain. An activation is not inserted as another persistent Structure. Re-entry executes the same callable occurrence with another activation-local work set.

The important identities are:

| Identity | Meaning |
| --- | --- |
| Callable occurrence / `self` | The actual Structure selected for this invocation, including a copied occurrence when applicable. |
| Code Structure | The Structure whose executable graph/native entry is used. The generic walker API can receive distinct code and data arguments; it must not substitute the original code object for the actual data occurrence. |
| `node` | The callable's fixed lexical/structural parent, not the dynamic caller and not a mutable global current object. |
| `parent` field | Physical structural-containment link in `Lmx`; not a language-level substitute for all lexical/dynamic resolution. |
| Thread parent | Supervision/ownership relation between executable Message identities. It is not `Lmx.parent`. |

`lmx_walk` now has separate `NODE` and `SELF` leaves. The released merge slice adds **SELF = 43**, taking the current executing occurrence; NODE is unchanged. This matters when the same code walks original data A and copied data R. A merge performed inside R must parent its fresh result to R, not to A or to a constant unit descriptor. Explicit hosted bodies select their actual hosted occurrence through the normal graph path.

### 3.3 Names, comments, and complete-source retention

**Norm.** The primary specification is [L2 §2.1, storage of the interpretable tree](docs/L2_spec_en.md#interpretable-tree), with the [L1 projection](docs/L1_spec_en.md#interpretable-tree), [name rules](docs/LMX_semantics.en.md#fields) and [toLmx contract](docs/LMX_semantics.en.md#source-codec). Source names are absent from the graph as a whole, not merely from atoms: Structures, methods, fields and applications do not store their names either. The separate address-to-name table reconstructs them for source output and inspection, never for execution dispatch.

A primitive materialized by a receiver, such as i in `int: i 5`, already has its typed arena cell and address; it needs no additional leaf wrapper to describe that storage. This is not a blanket prohibition on source leaves. With unknown A, `A: b` retains a named Structure whose body contains source leaf b, not an assumed evaluated cell. With known callable A, b belongs to the application argument Structure under [general container transparency](docs/LMX_semantics.en.md#values); a named argument retains a sole Structure as one argument. The actual callable signature still determines admission. Several references may share a cell without duplicating it, but source-node roles are not erased. Existing activation machinery resolves working values and formals. This neither equates a reference-slot address with its referent nor merges separate declarations, and it does not select a new physical leaf ABI.

Comments are retained in full with their structural placement. They carry independent content and are not processed on the execution path. For a source-constructed tree, `toLmx` reconstructs the original source content, including names and comments, with canonical formatting as the only difference. The name table and comments are retained information, not an alternate syntax tree or textual program to execute.

**Implementation boundary.** The translator retains P0 nodes, interned text, declaration-name identity, namespace/own rows and borrowed spans while translating. The generated executable retains operator/data graphs for supported lowering paths. These are two different lifetimes. This audit has not established a general final-program address-to-source-name/comment facility covering every accepted source. It also has not established that every source role emits a complete portable graph. Historical quiet graph refusal and native-only bodies are explicit evidence boundaries, not an alternate architecture.

See [one complete lexical graph](steps/native-selfbuild-20260930.md#one-complete-lexical-graph). A native test can pass while its root graph is empty; graph attachment and actual walked dispatch need independent witnesses.

<a id="physical-records"></a>
## 4. Physical records and type-by-range storage

### 4.1 The small universal records

The central definitions are in [lmx.h.lm1](dev/l2src_sandbox/lmx.h.lm1). In C-layout terms:

```text
VoidArray
    size_t size
    void *data

Lmx
    VoidArray array       // embedded by value, first member
    Lmx *parent
    LmxEntry native       // generic function-pointer word

LmxOp
    int code

VoidDynamicArray
    VoidArray array
    size_t capacity
```

`VoidArray` is the common two-word fixed descriptor. `Lmx` embeds it; it does not point at an extra array descriptor. The first-member C layout does not turn every Array into a Structure or permit reading `parent/native` after an arbitrary Array descriptor. The exact range kind, type and stride decide which physical record is present.

`native` is a function pointer, not a `void *` data pointer and not a numeric address. The runtime's declared function-pointer cast is the adapter boundary. Ordinary Structure references are `Lmx *`; their model names do not generate one C record type per model.

A Structure's `array.data` addresses its ordered physical child references. A language Structure value is held by reference; unary `@A` addresses that held reference's actual cell (conceptually `Lmx **`), not the `Lmx *` pointee. The same rule applies to Array descriptor references. Exact language place, pointer depth and C99 storage type must survive lowering; an arbitrary `void **` cast is not a storage proof.

### 4.2 Physical kind, exact type, and language requirement are distinct

The range layer can answer which storage kind and exact representation contain an address. Examples include primitive cells, Structure descriptors, Array descriptors, child-reference storage, Lists, operator/service records and Message/Thread records. Primitive type codes distinguish `char`, `int`, `size_t`, `unsigned`, `unsigned char`, `unsigned long`, and closed pointer representations. Array domain codes distinguish their element-storage representation.

These codes are **not a catalogue of language model compatibility**. A `Model` and an `Other` Structure have the same physical `Lmx` representation and may or may not satisfy a particular receiver. That is admission and correspondence, not a different allocator type for every model.

The current code contains legacy and newer code spaces. In particular, `LMX_TYPE_CHAR_PTR` is a concrete older physical constant, whereas compiler formal/return codes and modern `LMX_TYPE_POINTER_BASE + closed_type` encodings are separate conventions. Do not insert a formal type integer where a runtime witness cell is expected, or assume a numerical coincidence proves identical representation. `l2_contract_formal`, own-storage projection and witness construction are the explicit adapters between these spaces.

### 4.3 Pools, chunks, ranges, and arenas

The storage map is:

```text
LmxArena
  blocks             allocation/lifetime units
  arrays -> LmxPool  one physical storage class/profile per pool
              |
              +-> LmxChunk -> LmxChunk -> ...
                   cells: byte backing + capacity, next, mark
  index              dynamic array of [lo,hi) range records
  implements table   weak correspondence records, not graph fields
```

`LmxPool` records head/tail, cell stride, chunk capacity, physical kind/type, profile, sealed state and its arena list link. `LmxRange` records `lo`, `hi`, the owning storage-array/pool metadata and owner. Pool growth adds chunks; it does not move already published cells. The range index itself is service storage that may grow. Its movement does not move graph values.

See [lmx_pool](dev/l2src_sandbox/lmx_pool.lm1), [lmx_arena](dev/l2src_sandbox/lmx_arena.lm1), the `lmx_domain_*` adapters in [lmx_implements](dev/l2src_sandbox/lmx_implements.lm1), and [lmx_range](dev/l2src_sandbox/lmx_range.lm1). Range classification is used before following descriptors where the kernel requires a classified graph value. A machine external pointer is not automatically an arena graph value.

Arena operations include allocate/take, range registration/import, mark/revert, attach, release, and correspondence pruning. Attach transfers existing ownership/storage without copying its cells; imported qualified ranges remain non-owning views. Revert/release/sweep must not leave a correspondence whose value, required graph or borrowed map frame has disappeared. An arena address index is an allocator/type mechanism, not a hidden dynamic-variable environment.

### 4.4 Qualification and lifetime

**Norm.** `const`, `immutable`, `independent` and lifetime profiles describe different properties. A binding's constness is not automatically deep immutability of its referent. Qualification is not a clone. A retained independent immutable branch preserves its physical identity and original owner; it must remain classifiable where used. Independent construction changes the appropriate parent relation, rather than adding an execution mode.

**Implementation.** Pool/range profiles and sealing represent qualified storage. The copier accepts explicit profiles identifying branches to retain. Runtime service objects use their own typed domains. There is no new base-Lmx field for every qualifier, no `Array.capacity` added to support mutable services, and no per-model allocation pool.

**Debt.** Module unload and the lifetime of references into unloaded qualified modules are not established by the current module-lifetime model. A stable module token is not permission to unload its storage while admission entries still refer to it.

<a id="arrays"></a>
## 5. Array descriptors, backing storage, DynamicArray, and List

### 5.1 Fixed Array is a descriptor value

**Norm.** An ordinary Array is a reference to a descriptor with a length and backing storage. It is not the raw C backing pointer, and it does not decay implicitly to that pointer. An empty Array still has a descriptor identity; length zero does not make the Array value null. The base descriptor has no capacity word and no invented per-value element-model pointer.

**Implementation.** `VoidArray {size,data}` is the erased descriptor layout; typed wrappers such as `LmxCharArray {len,data}` expose the same role for their actual element representation. The range/pool type and the compiler's closed element contract establish the supported storage type. A plain descriptor reference and a pointer to its first element are different values.

| Expression role | Required projection |
| --- | --- |
| Ordinary Array value, including an initializer, assignment, return or ordinary actual | Descriptor reference. |
| `@array` | Address of the cell holding the descriptor reference, one level deeper; not descriptor backing or another read of the descriptor. |
| `array[i]` | The selected element value. |
| `@array[i]` | Address of the actual element cell, one pointer level beyond the closed element type. |
| Length | Descriptor length, not C `sizeof`. |
| Explicit raw-C access | The expressly selected backing/element address and C ABI, not an implicit graph conversion. |

`l2_value_ft_of_own`, `l2_emit_array_desc`, `L2IndexedOperand`, the common address contract, and `lmx_walk`'s Array place/value operations implement this distinction in the covered source paths. Pointer-element addressing now derives the exact declared element contract and applies the common address-depth transformation, rather than a short list of four element kinds. This does not imply that every imported C scalar or arbitrary foreign aggregate Array has a portable walker implementation.

### 5.2 Nested and multidimensional forms

**Norm.** Nested receiver application resolves one expression at a time. `[i][j]` rectangular addressing and `a[i]\[j]` following an Array-valued element are not interchangeable. Structure selector `[N]field` counts occurrences of that field name; it is not Array indexing. Element type does not license a separate Array-only name resolver, and there is no language maximum nesting depth.

**Implementation.** The source compiler has shared bounded indexed operands and borrowed expression spans. It selects the nearest lexical binding before deciding whether it is an Array, raw pointer or incompatible scalar. It must not skip a nearer scalar/formal and silently find an outer Array. Index expression evaluation is single-use, respects short-circuit control dependence, and cannot consume the next actual argument outside its supplied span.

**Debt.** This is not a declaration that all nested Array signatures, hidden Array inputs, imported element types, or all general receiver chains are implemented. The explicit ordinary-descriptor and indexed-expression checkpoints certify their named fixtures. Current base `VoidArray` has not been extended with speculative element-type graph metadata.

### 5.3 Dynamic services remain separate

`VoidDynamicArray` and typed DynamicArray wrappers add capacity outside the base fixed descriptor. Mail queues, metadata arrays and resizable service buffers may use them. Their backing can move while the descriptor remains the service's handle; this property must not be projected onto stable arena cells.

List is a distinct graph/container category, used for the single direct-child membership structure. A List is not a second shadow linked membership registry layered over another authoritative collection. The scheduler and child protocol use the actual List.

### 5.4 Character data is not a single representation

There are three materially different cases:

1. A mutable declared `char` cell: separately allocated typed storage, updated in place.
2. A literal/temporary character value: it can use the immutable 256-character intern table.
3. A character Array or low-level C-string pointer: the former is a descriptor plus backing; the latter is a machine reference with its own NUL/lifetime contract.

The CHAR identity repair introduced `lmx_char_new_owned` and `lmx_char_store_known` through the existing primitive allocator. Equal-valued declarations are distinct cells; saving `@a` remains valid across assignment to `a`. Copier CHAR handling uses the ordinary allocate-and-map route, preserving source aliases without collapsing distinct equal-valued cells. It does not mutate the literal intern table. The first fresh-char allocation must still establish the pool's original intern-table layout before later literal lookup or char-Array operations.

The now-unused public `dst_chars` threading and `lmx_char_rebind_known` have been removed; no compatibility shim or second copying policy should be inferred from older headers. See [the CHAR checkpoint](steps/native-selfbuild-20260930.md#char-declared-cell-identity-verified-wip).

<a id="values-places-and-references"></a>
## 6. Typed values, physical places, and portable references

### 6.1 One recursive result, not a raw-pointer convention

The current typed walker records in [lmx_walk.h.lm1](dev/l2src_sandbox/lmx_walk.h.lm1) separate value presence and category:

```text
LmxWalkValue
    present
    kind                    NUMBER or REFERENCE
    exact type
    ref                     opaque held reference value
    number / wide / natural / longnum / byte
                            actual-width scalar storage

LmxWalkPlace
    address                 physical cell or descriptor address
    exact type
    descriptor              descriptor-value versus ordinary cell category
```

`ref == 0` is a valid present null reference. It is not the same as `present == 0`. A numeric result is not discovered by testing whether a returned address happens to belong to an INT pool, and a reference is not recognized by inspecting which opcode produced a raw `void *`. The typed result propagates through recursive evaluation, calls, control flow, body-last result, return, admission and equality.

The shared place resolver covers the existing AT/OF/ARG/DEREF/ELEM/address routes. Loads and stores consume the resolved place and its type, rather than repeating an address-form heuristic in every opcode. The physical store encoding is `PUT(place-expression, value)`; old fixed holder/index PUT encoding is not a parallel fallback. Working-cache SET/SET_OF and graph-reference-slot PUT_REF remain different operations.

### 6.2 What `@` addresses

**Norm.** Portable reference acquisition, declaration and dereference are allowed in L3. Numeric address inspection, arbitrary pointer arithmetic, raw machine access and C casts belong to L2. The presence of `@` alone does not classify a program as L2.

| Source category | `@x` denotes | What it does not denote |
| --- | --- | --- |
| Ordinary Structure value | Actual reference-value cell; conceptually `Lmx **` | Pointee descriptor; temporary/cache/transport box. |
| Ordinary Array value | Actual cell holding its descriptor reference | Descriptor itself, backing or first element. |
| Declared primitive field | Actual typed arena cell at the declaration | Working cached scalar. |
| Explicit pointer binding `p` | The pointer-value cell, adding one depth level | Its already-held pointee value. |
| Primitive formal/local | Stable activation-owned typed cell | Caller's variable or a shared global argument slot. |
| Ordinary nonprimitive signature formal | Stable activation-owned reference cell | Caller storage; shared descriptor; ABI transport box. |

The distinctions remain meaningful after conversion to a common receiver such as `void *`: `p` and `@p` are still different source values. A receiving type cannot recover a source distinction that an earlier untyped evaluator discarded.

**Norm.** For absent `b`, `b: A` and `@: b A` are equivalent assignment forms. Ordinary `b: args` applies the bound Structure; `@: b B` explicitly reassigns the reference after conversion and admission. Repeated declarations retain separate occurrences. Do not infer that source-defined bodies disappear or distinct occurrences become one object from reference storage alone. The old non-callable-reference shortcut is implementation debt, not another language contract.

Signatures are nonexecuting. `A: b` and `@: A b` are synonymous reference transmission forms for ordinary nonprimitive signature values; this is not a universal synonym for primitive declarations or an authorization for executable implicit cloning.

### 6.3 Typed argument transport is not language address identity

The common native callback ABI is:

```c
int entry(void *owner, void **refs, size_t nargs, void *dest, void **out);
```

Each nonzero `refs[k]` addresses value storage according to the declared physical input contract. Numeric and supported foreign by-value actuals use their exact C types. Reference actuals use a canonical `void *` payload box; a nonnull box containing null means a **present null** input. A zero `refs[k]` means absent input, so the callee may use the appropriate lexical/default route. These are not interchangeable.

The callee owns the storage of its addressable formals. The caller's transport box is only a synchronous ABI carrier. Taking `@formal` must not expose that box as the language cell. The direct manual ABI tests therefore use explicit canonical `void *` boxes for reference inputs, rather than treating `Lmx **` as if it were `void **`.

**Debt: real pointer-cell C99 storage.** Canonical transport boxes are not the whole pointer-storage problem. Some real language pointer cells are physically allocated/accessed through generic `void **` helpers, while a generated typed address can be used as `int **` or another typed pointer-cell lvalue. Equal object-pointer size on a tested target is not an ISO C99 effective-type or representation proof. This separate boundary is recorded in [C99 pointer-cell storage](steps/native-selfbuild-20260930.md#c99-pointer-cell-storage). No `-fno-strict-aliasing` workaround, pointer-type registry, or blanket portable representation claim is introduced here.

<a id="own-state"></a>
## 7. Declared fields, activation work, dirty state, and checkpoints

### 7.1 Graph state and working state

**Norm.** A field exists because a declaration creates its place in the containing Structure. Assignment does not create another field. A method activation loads the own values actually used by bare name or dynamic forwarding into its working state. Explicit structural paths access the graph directly. Arguments and hidden inputs remain local values unless an explicit declaration materializes a field.

`LmxWalkWork` records holder, physical index/slot, typed working value, dirty state and its work-list link. Native lowering emits equivalent typed locals and publication logic. Neither representation is an extra language object or a persistent activation graph.

The basic sequence is:

```text
entry             graph cell -> working value (clean)
bare assignment   working value changes; dirty becomes true
checkpoint        dirty working value -> actual graph cell; dirty clears
direct path write actual graph cell changes; clean working value stays unchanged
return            publish dirty values only; do not restore a clean snapshot
```

Dirty is about an executed assignment, not unequal bits and not the static presence of a possible write in the body. A later assignment to a bare variable deliberately creates a new dirty write even if an explicit path changed the same graph cell in between.

### 7.2 Re-entry does not suppress publication

Each activation has its own local/formal/work/result state, but re-entry into the same occurrence uses the same declared graph cells. There is no active-depth counter suppressing a nested publication, no thread-local re-entry snapshot, and no restore-on-return copy of the fields.

If the outer activation publishes 2 before a recursive call, the inner activation publishes 9 on return, and the outer activation makes no further assignment, the final graph value is 9. The outer clean working value may still be 2. If it assigns 3, that is a new dirty write and the later checkpoint publishes 3. Both activations' `@x` point to the same physical declaration cell.

This also explains why a pointer write can be overwritten legitimately: a still-dirty working value is later published. Tests that want to prove a clean cache does not overwrite a physical write must first clear dirty state at an ordinary checkpoint. Conversely, tests of publication must inspect the physical value before a helper call can accidentally repair it.

### 7.3 Publication boundaries

**Norm.** Publish dirty own state before a call that may invoke user code, expose state, re-enter a Message or escape the activation; uncertain external calls are conservative boundaries. Publish on ordinary return, fallthrough, throw, failing assertion, stop/cancellation and suspension. A private non-escaping traversal/classification helper is not automatically a language checkpoint solely because it is a C call. Publication follows forward field order; each successful store clears its mark.

**Implementation.** Native publication, typed walker `lmx_walk_publish`, call boundaries and unwind cleanup implement the covered cases. The runtime uses scratch marks to return activation storage after unwind. Stop propagation is not implemented by polling before and after every literal or arithmetic operation. Calls/external returns and the established body/loop boundaries are the relevant observation points.

### 7.4 Lexical bodies and occurrence identity

An `if`, `else`, `while`, `for`, `until` or catch body that is executed as a body hosts its declared fields in its own graph Structure. It is not a new callable activation just because it is nested. Conditions, call actuals and result arguments are not automatically bodies. Native and walker paths must select the same hosted occurrence, including after copy.

The compiler's source-site selection respects declaration order, active host scopes, initializer exclusion and formal-to-own transition. A nearer scalar/formal must not be bypassed to find an outer same-name Array or model. Structural path lookup is a different role: it can open a declared place through an explicit path rather than pretending that the place is a currently visible bare variable.

<a id="call-and-stop"></a>
## 8. Calls, actual native selection, typed results, and stopping

### 8.1 The selector is the actual occurrence

**Norm.** A callable occurrence with a nonzero native word calls that entry; otherwise its portable executable tree is walked. The choice is not a Thread mode, an E/root exception, a compile-time prediction that a known method must be native, or a retry policy after failure. Native and walked execution operate on the same occurrence's fields.

**Implementation.** [lmx_call.lm1](dev/l2src_sandbox/lmx_call.lm1), principally `lmx_call_prim`, validates the code occurrence, initializes `out` to absent, reads `code.native`, and calls either its adapter or the installed typed walker entry. The `owner` supplied to the adapter is the selected data occurrence. There is no fallback from a failed native call into the walker. The released uniform-dispatch slice routes supported static, path, held, captured and dynamic selectors through this common path rather than directly calling a predicted `l2_mN` body.

A generated adapter may directly invoke its own typed C body after the runtime selected that adapter. That is not the old caller-side bypass. A test of dispatch must inspect the selected descriptor's native word or replace/clear it and observe the changed route; matching a C symbol name is insufficient.

`lmx_call0` remains a host/nullary integer-result interface. It must not be described as the general typed result ABI or used to infer support for arbitrary foreign result types.

### 8.2 Physical contracts

CALL and PRIM carry an ordinary physical input/result contract: ordered input witness cells and an empty or one-result part. The contract comes from the resolved callee or declared primitive interface, not the number of ARG nodes the body happened to use and not the number of actuals a particular caller supplied. Unused trailing formals still belong to the ABI.

`LmxPrimitive {fn, signature, owner}` is a typed service record. The callback address does not identify its argument types. ARG and SET_ARG carry declared witnesses for named/root bodies that do not have a function signature prefix. There is no fabricated universal `child[0]` header and no result-type inference from an arena address domain.

Scalar and char actuals use exact-width automatic storage in the common generated call route; they no longer require a fresh arena allocation on every synchronous native call. Reference transport remains canonical `void *` boxes. Foreign by-value actual/result storage uses the exact declared C type, not a cast through an Lmx pointer or an int-sized scratch cell.

### 8.3 Result, status, and stop are separate

The callback's C `int` is control/status, not the language's numeric return value. Numeric or foreign by-value results use `dest` and the out protocol; reference results preserve the held pointer value; void results do not acquire a made-up numeric payload. Throwing adapters must not publish a successful result on a thrown status.

For a real Message stop, result consumption must cease even if the low-level callback returned its ordinary success status. Current native adapters follow the shared order:

```text
invoke typed body -> observe stop -> publish result only on normal completion
```

The common caller observes stop before decoding the result or evaluating later actuals/receiver stores. `lmx_call_prim` clears stopped `out`. It does not fabricate a default aggregate or let an uninitialized typed local become a result.

The typed walker propagates internal **STOPPED = -4** through recursive evaluation, Array resolution, calls, control flow and cleanup. Catch replay applies to thrown status only, not STOPPED. Activation exit publishes ordinary dirty work and rewinds scratch, then the public run/call boundary normalizes stop to its public absent-result protocol. BREAK and CONTINUE are separate internal statuses, not errors or exceptions.

**Verification.** The released dispatch checkpoint includes real-current-Thread stop probes with exact saved native adapter types, nonzero sentinels, no later actual/receiver/store execution, and a 37-check direct walker stop fixture. Native and caller-walk modes are distinguished. A mutation yielding public INVALID is a status-propagation failure, not an assertion-count witness, and is reported separately.

**Debt.** The independently reproduced **nonthrowing foreign-aggregate C-return stop boundary** remains separate from the supported throwing/exact-destination route. See [the recorded boundary](steps/defects.md#nonthrow-aggregate-stop-abi). A foreign enum/alias scalar is not a genuine aggregate test, and a root-only walk with native foreign bodies is not foreign-aggregate graph interpretation.

<a id="admission"></a>
## 9. Conversion, admission, correspondence, and provenance

### 9.1 The order is conversion, then admission, then binding

**Norm.** A directed conversion table is about value-type conversions. It is not a table enumerating every pair of Structure models. For a receiving reference, convert the candidate first; then run the applicable `implements(candidate, requirement, Consumer)` and receiver tests; store only on success. A candidate expression is evaluated once. A failed admission does not mutate the destination or its dirty state, although earlier effects of evaluating the candidate are not rolled back.

The current compiler projects the same receiving contract for initialization, rebinding, ordinary reference return and supported physical-path stores. A named model used as a descriptor candidate is not executed just to obtain the descriptor. A value-producing callable in candidate position remains a call according to its resolved contract; it cannot be commandeered into a model-reference shortcut.

### 9.2 Correspondence is physical and Consumer-dependent

Requirements may use named fields, nested paths and selected occurrences. A compatible actual can have another physical field order. The correspondence must therefore be applied consistently to reads, writes and address acquisition, including typed-reference own fields, hidden inputs and crossings through hosted bodies.

The runtime's existing arena table stores:

```text
LmxImplEntry
    value, req             weak graph references
    layout                 nullable opaque physical-origin token
    frame, at              borrowed inline-map location, when present
    map, n                 static map or map extent
    holes                  recorded absent/unused positions
```

It is not a new language graph or a runtime name registry. A map records correspondence; it does not prove that every later Consumer can use every field. `SIZE_MAX` holes can be valid for a Consumer proven not to use those fields and invalid for a full receiving requirement or a later Consumer that needs them.

`lmx_implements_walk_view` can check against pending mapped views before publication. The operation-local iterative `LmxImplementsFrame` traversal carries both provider views and visited triples. It preserves cycle handling, shared subgraph behavior and NO/UNKNOWN classification without the former depth-32 cutoff. A revisited cycle is not permission to ignore a mismatching sibling, and an unsuccessful registration must not create a cached success.

### 9.3 Full receivers and proven-used receivers

**Implementation.** The compiler/runtime explicitly distinguish an ordinary full reference/return receiver from a call formation with compiler-proven used fields. In the selected-map full case, the pending view is fully checked before registration. A cached exact target map is not accepted unconditionally as a proof for a new Consumer. A cached hole-bearing value that was sufficient earlier can still be rejected by a full receiver, without changing the entry or fabricating absent fields.

This distinction preserves reached timing. A function producing a value must run before an ordinary runtime receiver throws `implements`; a premature compile-time refusal based on a conservative full map is not equivalent execution. Conversely, turning missing required slots into unused holes and registering YES is not an admissible repair.

### 9.4 Layout tokens solve origin ambiguity, not type semantics

Two actual layouts can have the same map for an intermediate requirement yet require different maps for a later one. Therefore map equality cannot identify the physical origin. The source-site/provenance repair uses nullable **opaque module-lifetime tokens** for existing declaration schemas. `LmxImplEntry.layout` is `void *`, not an Lmx graph reference. It is never traversed, dereferenced as a Structure, or mistaken for a required model.

The compiler emits stable token storage keyed by its existing declaration/schema identity. In library mode, the `l2_layout_tokens` symbol follows the existing module-hash suffix convention (`l2_u..._layout_tokens`), rather than intentionally sharing one array between generated modules. This is the present emitter mechanism, not a proof of a complete dynamic-library unload contract. ADMIT_AS transports tokens through ordinary boxed pointer metadata. Known-origin alternatives are selected by token identity, not source-map equality. Unknown origin remains unknown. A receiving model, a formal's required model, or an identity map is not itself proof of origin.

Only a genuine producer may establish origin: direct construction, a successful fresh copy/merge with known result schema, or a separately evidenced existing source. Later use of a declaration whose value can be replaced must consult the actual value's entry. It must not restamp the declaration's original layout onto a newly received unknown Message value. The constructor-reception witness specifically distinguishes the original tagged copy from a later replacement whose layout remains zero.

Across the table, conflicting nonnull tokens for the same physical value are refused before mutation. Known-to-unknown registration preserves known evidence; unknown-to-known may enrich only from genuine producer evidence. Copying a graph does not copy the source's admission entries. Attach/revert/GC prune lifetime-dependent graph references and borrowed map frames; tokens themselves are module-lifetime non-graph payloads.

### 9.5 Current flat ADMIT_AS layout

The inspected implementation has one flat encoding, not an old/new fallback decoder:

```text
0   operator
1   boxed declared-source token
2   catch count
3   candidate expression
4   actual target-model descriptor
5   alternative count
6   default-map count
7   boxed genuine direct-source token
8   full-receiver flag
9.. default map
    repeated (boxed origin token, target-width map)
    catch operands
```

Token boxes use the declared pointer witness; they are metadata operands, not source-model bodies to execute during preload. The candidate is evaluated once. Null is handled before correspondence lookup. Default-map count zero is the compact identity representation where justified, not a proof that an unknown value implements every requirement. Frame-backed maps borrow the instruction's ordinary graph storage and obey its lifetime/copy rules.

### 9.6 Remaining admission boundaries

**Debt.** Complete transitive `uses`/capture analysis and every directed conversion are not certified. A source capture whose body indirectly invokes a consumer of `y` may need `y` in its captured closure; it is wrong to encode an incomplete syntactic scanner as a normative expected refusal. A deliberately partial runtime value sent to a new consumer requiring missing `y` is a different, legitimate negative.

**Debt.** Cross-count repeated-field selection remains a measured design boundary: if a requirement has two `x` occurrences and an actual has three, bare-last and explicit `[1]x` can collapse to the same requirement slot while needing different actual slots. One `(value, required-model) -> slot map` is not automatically a complete Consumer-use correspondence for both selectors. This is not solved by positional zipping or forbidding the valid program. See [selector collapse](steps/defects.md#admission-occurrence-selector-collapse).

<a id="copy-and-merge"></a>
## 10. Copy, merge, retained branches, and ordinary result storage

### 10.1 The copier preserves topology

`lmx_graph_copy_owned` uses a source-address-to-copy map. It allocates and records a destination before processing its outgoing edges, so sharing and cycles are preserved. It remaps parent/child references according to the copied closure and explicit retention policy. Fresh primitive cells, including mutable CHAR, participate in the same map.

A callable Structure is not a copy terminal: its graph and native word travel with the copied occurrence. Service operator/role/primitive records and certain external Message/Thread or qualified branches have explicit terminal/retention rules in `lmx_copy_is_terminal_profiles`. Do not generalize “qualification traversal treats methods as leaves” into “graph copy never copies methods”; those are different operations.

Explicit pointer-cell pointee policy is separate from graph-owned Structure traversal. Copying the pointer value does not imply cloning arbitrary external storage. The CHAR identity work did not change that policy.

### 10.2 Merge composition

**Norm.** Merge copies/composes the used graph closure, retains the first operand's ordering, applies matching overrides and appends unmatched content according to the construction contract. Signature/header material constrains admission; it is not a gratuitous extra `merge(...; header)` operand. Existing aliases and cycles must remain coherent, and the constructed result's parent is the actual construction host.

Independent/const/immutable profile retention can return the same physical operand rather than a fresh descriptor. The caller must therefore observe whether the result is actually retained before assigning origin, parent or allocation expectations. “Merge was called” does not by itself imply a new identity.

### 10.3 Released ordinary merge-result slice

**Implementation, checkpoint `8359a59`.** The slice removes the old fixed unit-only merge-result storage route. A receiving declaration gets an ordinary own row and a compiler schema projection; root, method and hosted bodies store the result at the normal declaration place. Tagged merge-result schemas are centralized translation metadata, not extra runtime Structures. The path projection follows full schema fields and does not substitute the operand's backing or a guessed namespace.

The callback's current operand contract is:

```text
[ P, actual parent, boxed fresh-result token, boxed direct-source token,
  merge operands..., construction body, profile triples... ]
```

`P` and the profile triples describe the existing retained-profile protocol. Both native and walker producers use the real host. A plain executing body supplies SELF; a hosted body resolves its actual graph occurrence. The callback performs merge, then `lmx_merge_result_layout`, then exposes the successful result for the ordinary store. It does not publish a new graph result on failure or stop.

`lmx_merge_result_layout` distinguishes:

| Actual result | Origin treatment |
| --- | --- |
| Fresh descriptor | Register its own correspondence and fresh merge-schema token. |
| Exactly one of the operand identities | Preserve that actual value's existing origin; use a genuine direct producer token only where available. |
| Retained value with unknown origin | Keep unknown; never stamp the merge declaration or receiving model as origin. |

The registration occurs only after successful construction and before the normal result store. A failed registration must not turn a partial result into a successful visible binding. Earlier effects are not a general transaction rollback; allocator mark/revert and graph publication have their own exact boundaries.

### 10.4 Copy/re-entry witnesses and their limits

The current fixture set distinguishes fresh values on repeated reach, held aliases, retained profile identity, full field schema, root/method/hosted parents, explicit physical paths, native and genuinely walked bodies, and refusal before destination mutation. The direct merge walker selftest uses code A over copied data R and checks different correct parents. The profile-aware named-copy observer captures the actual successful constructor return, including the profiled constructor; an observer intercepting only the obsolete unprofiled symbol would otherwise report zero calls without proving a production defect.

**Verification limit.** Rich native variants must use the exact same final fixture bytes. An earlier native pass on a fixture later corrected from an unlawful same-name hosted head to `innerCopy` is not final-byte native coverage. The writer's final artifacts include that corrected native rerun under `merge_value_native_host_20261001_02`, plus independent native parent taps; earlier `_01` artifacts must not be substituted for it.

### 10.5 Open source routes are not hidden by the repaired storage

The documented `copy: merge Model` form still has a located common receiver-resolution gap: in the measured source it did not enter the merge parser. The established nested-Frame probes `copy: merge: Model` reached the repaired path. This is not a language declaration that the documented form is invalid.

A held operand whose actual layout differs from its declared view still exposes a complete-schema projection gap. Same-schema retained-alias tests do not close it. Formal merge operands and certain hidden-input/scanner routes remain separately located. General source invocation of a stored merged callable (`R()`/bare `R`) has also had distinct resolution gaps; invoking the actual result through a test-only existing runtime call interface certifies runtime identity, not that source syntax.

See [merge-result projection](steps/defects.md#merge-result-value-projection), [held operand layout](steps/defects.md#merge-held-operand-layout), and [hidden-input projection](steps/defects.md#merge-hidden-input-projection). The T7 `return: merge(y:k; add)` row currently records a receiver-lowering debt, not a successful primitive-conversion test. A separate valid merge-result-to-int negative preserves the actual incompatible receiving-type assertion.

<a id="message-thread-mail"></a>
## 11. Message, Thread, mail, scheduling, and the host boundary

### 11.1 Closed Message and Thread-only state

The current [LmxMsg](dev/l2src_sandbox/lmx_message.h.lm1) is exactly:

```text
running, success, handoff_ready, graph
```

The flag fields use the defined small atomic-access representation; `graph` is the Message graph root. Running zero is a stop request/permission boundary, not proof that all work and descendants are already closed. Success is set by user behavior and not reset by the system on failure; plain-letter delivery has its specified success action. Handoff-ready marks a safe ownership transfer point.

[LmxThread](dev/l2src_sandbox/lmx_thread.h.lm1) embeds Message **by value as its first member**, followed by mail, scheduling slot, turn/state, prepared children, supervision parent, service link, the direct-children List, liveness/close/orphan fields, result, manager, and Thread/mail API tables. There are no current/requested execution-mode fields. There is no Thread mode commit at end turn.

The Thread address equals the address of its Message prefix under C first-member layout. That does not license reading the Thread tail of a standalone Message. L3 binding checks the exact range kind/type/stride and owner before accessing that tail.

### 11.2 One turn

`lmx_thread_turn` and `lmx_turn` operate one execution lane for a Message identity. Ordinary per-call native selection occurs inside the turn; the turn itself does not select a global native/interpreter mode.

```text
enter turn / boundary
    execute current graph
    publish own dirty state at its ordinary language checkpoints
leave turn
    success -> publish staged outgoing mail and prepared children
    failure -> discard unpublished outgoing mail and child reservations
    handle liveness, stop cascade, child answers and applicable collection
```

Turn failure does not roll back graph writes already performed. The outbox/prepared-child publication transaction is narrower than arbitrary language mutation. Internal stop propagation must reach this boundary without converting “no normal result” into a successful receiving store.

### 11.3 Mail ownership and queue representation

`lmx_post` owns the mailbox synchronization. Outbound preparation stages work, successful publication moves it onward, and the receiver attaches the donor arena at the ownership boundary. Target reference and donor ownership are not interchangeable concepts. The mailbox inbox is a monitor-protected dynamic ring of the defined entries, not a second semantic graph of variables.

The queue grows by the specified non-constant schedule and closes before membership disappears, so late senders fail closed. Copying an envelope is not copying the sender or its entire Thread. Mail routing uses admitted graph references and ownership, not a global runtime name lookup. The public language `post`/`answer` semantics must be distinguished from whichever subset of adapters the present test suites construct.

### 11.4 Children and scheduling

Direct children have one authoritative graph List, allocated in the parent's ownership context. Child preparation, publication, supervision and the scheduler use that membership; no removed `LmxLink` chain should reappear as a parallel source of truth. `lmx_child`, `lmx_schedule`, `lmx_manager` and `lmx_thread` divide preparation, scheduling and execution responsibilities.

The scheduling slot supplies the executable arena relationship; a Thread does not need a duplicate arena field merely to cache it. Parent operations serialize the structural membership changes; the mailbox monitor is not repurposed into a universal runtime lock. Native and interpreter adapters must obey the same owner binding and Message identity checks.

### 11.5 R0 and WorldWideMix host

**Norm.** R0 is an ordinary executable child of an outer host frame; it is not a special root-only language object. Only the uppermost frame lacks a parent. Program arguments and settings arrive through ordinary Message construction. The normal shutdown waits for the entire descendant subtree; an external total watchdog bounds that operation independently of individual liveness deadlines.

**Implementation.** `lmx_root_launch_tapped` opens the host graph, creates/publishes R0, sends the argument/settings letter, schedules the child, lets the host receive the exit result, chooses the exit Message or success fallback, writes the report and closes the tree. The host's internal field constants are this builder's layout, not universal language-reserved Structure slots. Root's last expression is not automatically an OS exit code.

The tapped launch seam permits test-only observations before teardown without adding a public language API. A teardown-safe nonzero success marker and graph assertions are stronger evidence than a wrapper process returning zero.

<a id="garbage-collection"></a>
## 12. Garbage collection and weak service metadata

**Implementation.** [lmx_gc](dev/l2src_sandbox/lmx_gc.lm1) uses arena generations and per-chunk mark stamps. It starts from the current Thread/Message, Message graph, scheduling/mail state, queued targets and the authoritative child List. Inbox traversal obtains a monitor-consistent snapshot from the post API; it does not inspect a moving ring backing without that protocol.

The collector distinguishes recognized scalar cells from pointer-bearing graph records. Structure traversal follows parent and child backing; Array traversal follows backing. Other service-record scanning includes conservative pointer-word treatment, which can retain extra storage. Marking and sweeping are chunk-granular, not a precise per-language-value reference count. Qualified sealed/imported storage has explicit ownership handling and is not adopted or freed accidentally.

Sweep unlinks storage from indexes before release and prunes `implements` entries so freed value addresses are not reused with stale correspondences. Entry `layout` tokens are non-graph module addresses and are not traced as Lmx; value, requirement and frame-backed map lifetime remain the relevant weak graph dependencies.

A simple letter-scale arena skips generation/sweep in the implementation. If marking is incomplete, collection returns PARTIAL and does not perform a potentially unsafe partial sweep. This failure policy does not make an arbitrary traversal limit a valid language restriction.

**Debt.** `LMX_GC_DEPTH` is still **64** in `lmx_gc.h.lm1`, checked by recursive `lmx_gc_mark_value`. The older L3 receiver also has a depth-64 limit. These remain artificial limits against the accepted uncapped-traversal direction. Removing the implements depth cap and holder-parent count cap did not remove all caps in the system. Native stack exhaustion, allocation failure and checked `size_t` overflow are real implementation resource failures; they must be distinguished from a hard-coded language depth/count ceiling.

<a id="compiler"></a>
## 13. Translator pipeline, declaration roles, and source-site identity

### 13.1 Translation-only records

The common records in [l2_application.h.lm1](dev/l2src_sandbox/l2_application.h.lm1) make the relevant source information explicit:

| Record | Role |
| --- | --- |
| `L2TypeContract` | Resolved contract kind, depth, type word and operand. |
| `L2Declaration` | Exact source declaration, name, candidate start/count and extent. |
| `L2Address` | Resolved address category, row, descriptor/model/type, bounded target span and immutability. |
| `L2IndexedOperand` | Resolved own, element/address type, dynamic/literal index and bounded after-position. |
| `L2ValueSpan` | Borrowed first/count/node span; no cloned source AST. |
| `L2SourceSite` | Method/source-method/current-method, source node, visibility cutoff, active host scopes, initializer exclusion and deferred-check role. |
| `L2ReferenceSource` | Declared schema, genuine/direct origin evidence or dynamic source key/place. |
| `L2SchemaField` | Compiler projection of a schema field's name, type and nested model. |

These are compiler work records, not hidden runtime graph companions or a second language binding table. Borrowed text/node identity has a translation lifetime; it must not escape as a dangling runtime schema pointer. Module-lifetime tokens are emitted separately where runtime provenance needs them.

### 13.2 Main checking order

The exact implementation is larger than a single pass. Important phases in `l2_parse_unit` and `l2_emit_unit` include:

1. Bind actuals to the resolved callable formals before treating named actual syntax as another call.
2. Collect declarations, callable/signature metadata, named/local Structure layouts and ordinary merge-result bindings.
3. Scan local/free uses and establish hidden-input dependencies.
4. Collect throws and prepare partial/captured callable information.
5. Check bodies under their actual method/source/host context; build or rebuild machine-local metadata where needed.
6. Close throws and hidden inputs across call sites, then replay deferred checks with the saved SourceSite.
7. Reject unresolved root inputs; intern/prove physical call signatures.
8. Build correspondence/source catalogs and graph counts, then emit matching graph initialization and native bodies/adapters.
9. Lower emitted L1 through the separate L1 translator and compile C99.

This list is an implementation orientation, not a new language execution order. Compile-time collection does not execute an executable declaration or make a later own field lexically visible at an earlier source use.

### 13.3 Visibility is site-aware, not method-wide name search

The common selector must consider exact method/source-part identity, active structural hosts, source position and an excluded initializer row. A formal remains selected until a visible declaration creates its own row. Different declarations of the same name retain occurrence identity. Deferred checking must restore precisely this context and restore the previous context on both success and error.

Dynamic input closure records each call site; a single method edge cannot erase different caller scopes. A type learned from one valid caller does not make another invalid caller legal. Eligible callee lexical fallback remains distinct from caller visibility: a parent declaration preceding the callee's lexical definition can be eligible even when the first dynamic call occurs earlier, while a future own declaration inside the callee is not an automatic fallback.

`l2_scan_bound` recognizes actual declaration/reception binding, preventing later scans from misclassifying a bound name as an unknown callable. Exact own declaration-name identity maps repeated part/named-body occurrences to physical slots; it does not replace structural selector semantics with a universal latest-name table.

### 13.4 Model/type projection must consume resolved metadata

`l2_type_model` distinguishes a genuine constructed local model from an arbitrary reference binding that happens to have a model requirement. It uses the source site and exact own layout, without altering the global namespace finder into a fallback that skips shadows. Pointer type spelling and required-model projection share this resolved contract.

Header collection saves/restores SourceSite and uses the header's lexical context. Re-parsing `Model: Model` under the later body, where the formal or own field shadows the model name, is wrong. The repaired category and rebinding consumers use stored `l2_input_model` information for explicit formals. Hidden-input model metadata and provenance use the shared input/source projection, not an explicit-formal-only array index.

### 13.5 Expressions use bounded spans and shared categories

The compiler no longer needs a separate synthetic atom/token clone for an indexed or prefix operand in the typed graph route. Bounded source spans identify a complete expression and its end. Address, indirect, indexed and ordinary receiving checks share resolution/type information, and count/emission must traverse the same source under the same context.

This prevents three distinct errors: reading into the next actual, evaluating an index twice, and converting `@Data\field` into the address of a generated temporary instead of the physical field. Logical splitting respects precedence and control dependence even for pure memory loads; the absence of a call is not permission to hoist a load from a short-circuited branch.

`sizeof` has an operand-role classifier independent of successful type resolution. A syntactically type-position operand such as an unsupported pointer type must be diagnosed as a type, not manufactured into a hidden value input. `sizeof(value)` uses the same source-site binding and correctly closed hidden formal lookup. Current native sizeof bodies with a walked root establish transport/lookup, not a portable L3 sizeof operation.

### 13.6 Construction and calls: accepted rule versus legacy code

**Norm.** An absent head in a declaration defines a named Structure; declaration does not execute it. Under Q57, unknown `C` in `C: makeA()` creates the named Structure `C` containing a named empty Structure `makeA`; it is neither an immediate call nor a saved invocation. The author's explicit 2026-10-01 clarification is that an **ordinary named Structure has no arguments, only a body**. Its nullary invocation is valid; applying an existing ordinary `A` as `A: B` is a **call error**, whether or not `B` exists. There is no assignment or declaration fallback. The declared formal arguments of `fn`, `fm` and `sub` are unaffected. Unknown actual arguments to those contracts remain errors, not silently created placeholders. Explicit expression merge is the construction mechanism; implicit `Model: fresh` cloning in executable declarations is not the accepted rule.

**Implementation/debt.** The translator still contains legacy no-candidate clone paths in `l2_colon_decl_shape` and associated fixture setups. The provenance repair correctly stamps the actual successful legacy copy producer rather than later uses, because accepted replacement paths can change the stored value. This preserves implementation integrity while the obsolete spelling remains; it does not bless that spelling as current norm. The general known-head/declaration/body-role cleanup is separate and must not be silently decided by a test fixture.

Nonexecuting signatures and pointer declaration rules remain as described above. The ordinary named-Structure argument question is settled by that clarification, not left open here. Its implementation cleanup must use the common resolved role, not a special case for a model name, E/root, Array chain, test name or C symbol.

<a id="interpreter-surfaces"></a>
## 14. The current interpreter surfaces are not one undifferentiated feature

### 14.1 Typed generated-graph walker

`dev/l2src_sandbox/lmx_walk.lm1` executes the current typed operator graph. `lmx_interp.lm1` supplies the public L3-facing wrapper/status mapping. `lmx_interp_apply_value` carries `LmxWalkValue`; the wrappers do not authorize raw L2 operations as portable graph semantics.

The typed walker includes working caches/publication, exact argument presence, physical places, ordinary control flow, Array operations, calls/primitive contracts, admission, and stop cleanup for the covered graph constructors. It uses reusable scratch/activation storage rather than persistent per-call graph clones.

### 14.2 L3 profile/thread adapter

`dev/l3_interp/l3_thread.lm1` constructs/seals the runtime profile, ordinary role and primitive registries, and physical primitive signatures. `l3_thread_dispatch` verifies/binds the actual Thread context, creates the walker scratch context and invokes `lmx_interp_apply`. It is this typed walker path, not a call to the older `l3_exec` evaluator.

The mail primitives use declared contracts and canonical reference value storage. Owner guards matter: a callback bound to another Thread's owner is not a legitimate operation merely because its pointer shape is compatible. The tests cover this through real failed-turn and no-publication observations.

### 14.3 Older small L3 receiver/executor

`l3_recv.lm1`, `l3_exec.lm1`, `l3_path.lm1` and `l3_admit.lm1` also remain in the tree and are exercised by specific suites. `l3_recv` supports a small value subset and contains `L3_DEPTH_MAX = 64`. `l3_exec` has its own `L3Frame`, limited int-oriented operations and explicitly immediate field assignment rather than the current own-cache/checkpoint mechanism. Several operations return UNSUPPORTED.

These files are real implementation surfaces, but their presence and tests do not establish parity with the typed generated walker. Their historical README contains obsolete METHOD/slot/budget language and is not used here as a statement of current record layout. A future consolidation must preserve demonstrated behavior while satisfying the common semantics; this document does not invent a replacement interpreter.

### 14.4 Current typed operator inventory

The following groups cover the current `LMX_WALK_OP_*` constants. Numbers identify the inspected implementation encoding, not a promise that user programs may manufacture arbitrary frames or that every source spelling lowers to every operator.

| Family | Operators in this snapshot | Main distinction |
| --- | --- | --- |
| No operation / literal / construction | NONE 0, LIT 3, EMPTY 23 | LIT produces a typed value; EMPTY constructs a fresh empty Structure, not an absent/null value; malformed/unknown is not a literal. |
| Return and call | RET 1, CALL 2, EXEC 35 | Return carries typed state; EXEC evaluates a selected occurrence expression once before ordinary dispatch. |
| Activation working state | OWN 4, SET 8, OWN_OF 31, SET_OF 32 | Read/update own work rows and dirty state, not direct physical stores. |
| Formal/local input | ARG 5, SET_ARG 34 | Declared witness, stable callee-owned value/place, present-null distinct from absence. |
| Physical graph places | AT 6, OF 15, PUT 7, PUT_OF 19, PUT_REF 24 | Typed cell/place access versus replacing a graph reference slot; correspondence applies where required. |
| Reference projection | DEREF 18, ADDRESS 42 | Follow one resolved value/place level versus acquire its physical address; no implicit recursive unwrap. |
| Actual and lexical identity | NODE 36, SELF 43 | Fixed lexical parent versus current executing data occurrence. |
| Arithmetic/comparison | ADD 9, SUB 10, LT 11, EQ 12, MUL 20, DIV 21, MOD 22 | Exact supported scalar contract; EQ uses typed reference values where applicable, not numeric-address guessing. |
| Logical/control | IF 13, WHILE 14, AND 38, OR 39, FOR 40, UNTIL 41, BREAK 29, CONTINUE 30 | Reached evaluation and control-dependent branches; internal control statuses propagate through cleanup. |
| Array | ELEM 25, ELEMPUT 26, LENGTH 27 | Descriptor/backing/place distinction and typed bounds/operation contract. |
| Catch landing | PAD 28 | Catch parameter references followed by the handler body; not an Array padding operation. |
| Native service calls | PRIM 16, PRIM_PUB 33 | Physical primitive signature; PRIM_PUB includes the required working-state publication boundary. |
| Admission/testing | EXPECT_INT 17, ADMIT_AS 37 | Receiver/testing operations and the single current flat mapped-admission encoding. |

COUNT is 44; UNKNOWN is -1. Internal STOPPED is a control status, not another graph opcode. The inventory documents what exists, not new L2/L3 syntax or a blanket guarantee that the older `l3_exec` accepts this encoding.

<a id="verification-ledger"></a>
## 15. Verification ledger and how to interpret gates

### 15.1 Released baseline and current checkpoint

| Evidence | What it establishes | Boundary |
| --- | --- | --- |
| Uniform native dispatch source checkpoint `621e8af` | General supported selector routing, exact transport/results, real stop boundary and its associated source/runtime tests. | Baseline before the merge-result slice. |
| `build/l2_harness/uniform_dispatch_full_20261001_02` | **1100 targets: 1052 OK / 48 FAIL**, with identity comparison and exact source manifests. | The 48 retained failures remain failures, not waived completeness. |
| `build/l2src/uniform_dispatch_kernel_20261001_03` | **286/286** kernel targets, including persistent stop selftest **37/0**. | Does not certify later runtime edits. |
| `build/l3_interp/uniform_dispatch_final_20261001_01` | **11 suites / 295 checks**, plus separately persisted inventory checks. | Distinguish each suite's actual execution surface. |
| `build/l3_interp/uniform_dispatch_budget_20261001_01.log` | Four measured inventory controls: **74/128 type names**, **1056/8192 name bytes**. | Inventory headroom is not a language-level capacity rule or semantic coverage. |
| `merge_value_final_focus_20261001_02` and final restored rerun | **48/48** each on the translator hash in §1. | Restored final source, not an unreverted mutation. |
| `build/l2_harness/merge_value_full_20261001_02` | **1110 targets / 1062 OK / 48 FAIL**; independently recomputed exact same 48 baseline failure identities, ten added green fixtures, no regressions/removals/duplicates. | Exact source released as `8359a59`; the retained failures remain open. |
| `build/l2src/merge_value_closure_preflight_20261001_02` | Six actual translate/compile/link/run closures, **174 checks**. | Not a replacement for the final full kernel gate. |
| `build/l2src/merge_value_kernel_20261001_02` | **286/286**; persistent `run_selftest_lmx_walk_merge_selftest.log` reports **54 checks, 0 failed**. | Exact current runtime freeze, not a claim that all generated-language gaps are closed. |
| `build/l3_interp/merge_value_final_20261001_02/runner.log` | **11 suites / 295 checks**, four successful **74/128 names, 1056/8192 bytes** inventories. | Actual suite dispatch surfaces remain as described in §14. |

The intermediate merge full01 was **1108 / 1056 OK / 52 FAIL**: the released 48 failures plus three self-path rows and a T7 diagnostic mismatch. Two named-copy failures came from an observer that intercepted only the old unprofiled constructor; the actual walked self-path failure came from lost method context during graph count/emission. These are different causes. The targeted repair restores the common context and updates the observer to the actual constructor return. T7 remains an explicitly labeled receiver-lowering debt; separate negatives preserve actual receiving-type and known-head assertions.

Independent read-only recomputation of `merge_value_full_20261001_02/final_verification.json` checked **25 live owned files**, **91 staged owned copies**, **100 start-manifest entries across four gates**, **1218 live/staged source pairs**, and **44 L3 source pairs**: zero hash mismatches. These counts are file comparisons, not semantic tests. The 41 original artifact references in `mutant_verification.json` also match their recorded hashes. Mutation groups deliberately distinguish observer-only, source-checker/translation-only, positive instrumentation/control, and executed runtime mechanisms; no aggregate “all are runtime tests” claim is made. `commit_verification.json` identifies the exact 25-path commit `8359a59f67b87382c55eb402e9f09f9a4b1ce954`; the final restored focus is 48/48.

### 15.2 What must accompany a new release claim

A trustworthy checkpoint includes all of the following, not just a total count:

- Exact live, start, staged and final hashes for the owned files and relevant staged fixtures/headers.
- Fixture-identity comparison against the prior full gate: retained failures, fixed failures, additions, removals, duplicates and formerly green regressions.
- Terminal compile/link/run results; a stopped build or a parser setup failure is not a semantic mutation detection.
- Nonzero intended success values where possible, actual result/field/identity observations and call counts preventing absent work from passing.
- Actual native-word configuration and actual dispatch path. Clearing root alone does not prove every callee walked; native-only foreign helper bodies must be stated.
- Mutations tied to the missing property: wrong parent, code instead of data SELF, retained identity misclassified as fresh, skipped admission, lost publication, wrong index, or eager load. Assertion inversions test the oracle and are reported separately from mechanism mutations.
- Exact restoration before final positive gates. Artifacts from an earlier source are not silently promoted to proof for changed code.

Kernel suite totals and generated fixture counts use different units. A gate may include bootstrap or inventory targets in addition to fixture rows. Report the tool's terminology, and do not add unlike totals to create an inflated coverage count.

### 15.3 Build ownership and closure

The present workflow has one source writer/build owner. Frozen gates stage source before compiling; no other agent edits that source during a running gate. Reviewers inspect staged files and logs without polling another owner's process or launching competing compilers. After an intentional source mutation, the owner restores exact bytes and reruns the relevant positive gate.

`predef` selects an explicit source/header closure. Adding a real dependency such as `lmx_msg_poll_escape` requires the actual Thread provider, and that provider can require the actual schedule implementation. A linker that chooses a broad object with embedded duplicate definitions is not evidence that a stub, ignored duplicate or fallback implementation is acceptable. Current manual suites explicitly import the real provider closure; their compile/link/run evidence is separate from textual source presence.

The primary development carriers are [build_l2src.ps1](tools/build_l2src.ps1), [l2_harness.ps1](tools/l2_harness.ps1), [run_l3_selftest.py](tools/run_l3_selftest.py) and [l3_type_budget.py](tools/l3_type_budget.py). Exact command lines and output directories belong to each release report. These tools are the current verification machinery, not the final self-hosting architecture.

<a id="source-index"></a>
## 16. Source map by responsibility

| Responsibility | Principal files and symbols |
| --- | --- |
| Universal records and physical kinds | [lmx.h.lm1](dev/l2src_sandbox/lmx.h.lm1): `VoidArray`, `Lmx`, `LmxOp`, `LmxPool`, `LmxRange`, `LmxChunk`. |
| Pools, stable cells, ranges | [lmx_pool.lm1](dev/l2src_sandbox/lmx_pool.lm1), [lmx_arena.lm1](dev/l2src_sandbox/lmx_arena.lm1), `lmx_domain_*` in [lmx_implements.lm1](dev/l2src_sandbox/lmx_implements.lm1), [lmx_range.lm1](dev/l2src_sandbox/lmx_range.lm1). |
| Primitive/CHAR/reference cells | [lmx_value_owned.lm1](dev/l2src_sandbox/lmx_value_owned.lm1), [lmx_chars.lm1](dev/l2src_sandbox/lmx_chars.lm1): allocate/store/load, fresh CHAR versus intern table. |
| Array allocation/storage | [lmx_array_owned.lm1](dev/l2src_sandbox/lmx_array_owned.lm1), typed descriptors in `lmx.h.lm1`. |
| Structural refs and allocation | [lmx_arena_refs.lm1](dev/l2src_sandbox/lmx_arena_refs.lm1): ordinary child slots and Structure allocation. |
| Copy | [lmx_graph_copy_owned.lm1](dev/l2src_sandbox/lmx_graph_copy_owned.lm1): `lmx_copy_is_terminal_profiles`, allocate/map/process traversal. |
| Merge | [lmx_merge_owned.lm1](dev/l2src_sandbox/lmx_merge_owned.lm1): profiled constructors, callback, `lmx_merge_result_layout`. |
| Admission | [lmx_implements.lm1](dev/l2src_sandbox/lmx_implements.lm1): `lmx_implements_walk_view`, register/find/layout/slot APIs; `LmxImplEntry` in arena header. |
| Call selection | [lmx_call.lm1](dev/l2src_sandbox/lmx_call.lm1): `lmx_call_prim`, installed walk adapters, distinct `lmx_call0`. |
| Typed execution | [lmx_walk.lm1](dev/l2src_sandbox/lmx_walk.lm1): `lmx_walk_eval`, place/value/store helpers, `lmx_walk_array_from`, `lmx_walk_activate`, publication/cleanup. |
| Public interpreter adapter | [lmx_interp.lm1](dev/l2src_sandbox/lmx_interp.lm1): `lmx_interp_apply`, `lmx_interp_apply_value`, status mapping. |
| Primitive contracts | [lmx_primitive.h.lm1](dev/l2src_sandbox/lmx_primitive.h.lm1), [lmx_primitive.lm1](dev/l2src_sandbox/lmx_primitive.lm1). |
| Scratch activation storage | [lmx_scratch.lm1](dev/l2src_sandbox/lmx_scratch.lm1): take/mark/rewind, reused typed temporary storage. |
| Message and Thread | [lmx_message.h.lm1](dev/l2src_sandbox/lmx_message.h.lm1), [lmx_thread.lm1](dev/l2src_sandbox/lmx_thread.lm1): `lmx_msg_poll_escape`, current/bound owner and turn. |
| Turn publication | [lmx_turn.lm1](dev/l2src_sandbox/lmx_turn.lm1): outcome, post/child publish/discard, boundary work. |
| Mail and children | [lmx_post.lm1](dev/l2src_sandbox/lmx_post.lm1), [lmx_child.lm1](dev/l2src_sandbox/lmx_child.lm1), [lmx_list_owned.lm1](dev/l2src_sandbox/lmx_list_owned.lm1). |
| Scheduling/supervision | [lmx_schedule.lm1](dev/l2src_sandbox/lmx_schedule.lm1), [lmx_manager.lm1](dev/l2src_sandbox/lmx_manager.lm1), [lmx_root.lm1](dev/l2src_sandbox/lmx_root.lm1). |
| Collection | [lmx_gc.lm1](dev/l2src_sandbox/lmx_gc.lm1): `lmx_gc_mark_value`, `lmx_gc_mark`, `lmx_gc_sweep`, `lmx_gc_collect`; `lmx_arena_impl_prune`. |
| L3 profile and old subset surfaces | [l3_thread.lm1](dev/l3_interp/l3_thread.lm1), [l3_recv.lm1](dev/l3_interp/l3_recv.lm1), [l3_exec.lm1](dev/l3_interp/l3_exec.lm1), [l3_admit.lm1](dev/l3_interp/l3_admit.lm1), [l3_path.lm1](dev/l3_interp/l3_path.lm1). |
| Common source records | [l2_application.h.lm1](dev/l2src_sandbox/l2_application.h.lm1). |
| Translator resolution | [l2trans.lm1](dev/l2src_sandbox/l2trans.lm1): `l2_declaration`, `l2_resolved_own`, `l2_own_visible`, `l2_scan_bound`, `l2_type_model`, `l2_collect_method`, `l2_parse_unit`. |
| Translator call/value emission | Same file: `l2_emit_call_ref`, shared value/address/index/indirect projection, typed adapters, ordinary publication. |
| Translator graph and admission | Same file: `l2_d105_close`, `l2_rw_admit_source`, `l2_rw_admit_project`, `l2_rw_methods_count`, `l2_rw_methods_emit`, `l2_emit_unit`. |
| Ordinary merge projection | Same file: `l2_merge_declaration`, schema/own projection, `l2_mres_of_own`, actual-parent and result stores. |

Symbol names are more durable anchors than line numbers in the large active translator. The source hash and frozen path in §1 identify the reviewed version; future line movement is not evidence that the mechanism changed.

<a id="debt-map"></a>
## 17. Explicit debt and non-claims

The following is a boundary map, not authorization for another coding phase:

| Boundary | Current status and what must not be claimed |
| --- | --- |
| Full self-build / §§8 and 8a | Not complete. Current handwritten L1 and host carriers remain; two successful self-building generations are not established. |
| Complete lexical/binary graph and source metadata | Required. Native success and some attached graph edges do not certify complete retention of every declaration/operator/name/comment. |
| General receiver/known-head classification | Still contains legacy construction and unsupported source routes. The accepted ordinary named-Structure rule is nullary-only; its implementation cleanup must not add a fallback or confuse it with `fn`/`fm`/`sub` formal contracts. |
| Documented merge expression spelling | Located receiver gap separate from ordinary merge-result storage. Nested-Frame test success does not close it. |
| Held/formal/hidden merge schema | Specific incomplete projections remain; a known required view is not the actual complete operand layout. |
| Cross-count repeated selectors | Consumer bare-last versus explicit ordinal can require distinct correspondence despite the same required slot. Current map form is not a proof of full support. |
| Complete transitive capture/uses | Runtime hole controls are meaningful, but an incomplete syntactic capture scan is not a normative unused-field proof. |
| Arbitrary Array formals/nested/imported categories | Current descriptor/element paths have bounded verified coverage; no new metadata field or universal support is inferred. |
| Foreign by-value and aggregates | Supported exact native transport is real; arbitrary foreign graph execution, field projection and nonthrow aggregate stop returns remain separately bounded. |
| C99 real pointer-cell effective type | Canonical ABI boxes are fixed; language-real typed cell representation still needs its own closure. No target-size fact is promoted to ISO portability. |
| GC/legacy traversal limits | GC64 and legacy receiver64 remain. Removed implements/holder caps do not imply uncapped all-kernel execution. |
| Compiler metadata/path caps | Some fixed capacities remain despite removed 64-token expression limits and checked dynamic path buffers; see [compiler metadata caps](steps/defects.md#compiler-metadata-caps). |
| Module unload | No complete unload/lifetime protocol for token/qualified references is certified. |
| Separately compiled library lifetime and instances | Existing link/symbol witnesses do not prove a live independent unit. Singleton arena/unit globals and temporary-root lifetime require repair; see the [proposed owner-supplied construction route](steps/native-selfbuild-20260930.md#proposed-owner-supplied-library-construction). This is a proposal to validate, not accepted new module semantics or a proved 41/42 runtime result. |
| Older L3 executor | Separate immediate-write subset, not evidence of typed walker's dirty semantics or universal interpreter consolidation. |
| Current merge release | Released as `8359a59`: final/restored focus 48/48 each, full/kernel/L3 gates terminal, exact combined hashes retained. This checkpoint does not close the separately listed debts or overall self-build. |

<a id="documentation-audit"></a>
## 18. Documentation consistency audit accompanying this map

The audit read both English and Russian L1/L2 specifications and relevant `CORE.md` sections against the accepted reference, construction, signature, execution and storage rules. Historical authored quotes and frozen source/log snapshots were not rewritten into new norms.

### 18.1 Corrections applied in the owned documentation slice

The following line references identify the pre-edit statements inspected for this document; stable section links are supplied for later readers:

| Location | Inconsistency | Correction in this documentation slice |
| --- | --- | --- |
| `docs/L1_spec_en.md:10`, `docs/L1_spec_ru.md:10`, §1 | “The core may be written in L1” read as a normative target option. | State generated L1 target and transitional handwritten implementation; link READ.ME self-build requirement. |
| Both L1 specs, pre-edit line 154, [raw arrays](docs/L1_spec_en.md#lowlevel-array) | Referred to an L2 `c.array` contract as a distinct entity. | Refer to the L2 raw-C storage boundary, which does not introduce a separate L2 entity named `c.array`. L1's own lowering family is unchanged. |
| `CORE.md`, pre-edit lines 479–493, §5 | Thread state list included current/requested mode and interpreter dispatcher; removal was described as future work beside a no-mode statement. | Remove obsolete fields and mark mode/request commit already removed. Actual per-occurrence dispatch remains. |
| `CORE.md`, pre-edit lines 505–514, §5 | Turn finalized a mode request; ignored native status presented as current. | Describe actual turn; mark superseded adapter observation historical and retain scoped aggregate/verification boundary. |
| `CORE.md`, pre-edit line 588, §7 | Method records described as copy terminals. | Callable Structures use common copy mapping/native-word preservation; terminal service/profile rules remain explicit. |
| `CORE.md`, pre-edit lines 600–602, §7 | Old merge70 wrapper-status loss stated without historical qualification. | Retain it as historical evidence, not current adapter behavior or retroactive validation of old green rows. |
| `CORE.md` §3.1 | Normative complete-source/comment retention read as implemented completeness. | Explicitly separate requirement from unaudited generated runtime name/comment retention. |

These are corrections of stale descriptions, not new execution rules. No L2 specification was edited by this slice.

### 18.2 Current consistent reference rules

The address contract is corrected on 2026-10-02: a Structure/Array value is held by descriptor reference, while unary @ addresses its real reference-value cell and adds depth. Primitive/formal/reference cells and portable L3 references remain distinct from raw L2 operations and ABI boxes. The current descriptor-level exemption in compiler and walker is the open critical_pointer_to_struct_bug, not a released correct mechanism. The subsequent reference-application refactoring separately enables ordinary calls through Structure references and explicit @: reassignment. Earlier gates cited in this map do not certify either repair.

### 18.3 Residues outside the owned correction set

The `dev/l3_interp/README.md` proposal/history still names METHOD descriptors, a universal signature slot and obsolete type-budget numbers. The actual source and fresh inventory evidence take precedence for implementation reporting; the proposal is not silently promoted to a current specification. Broader active-document cleanup is owned separately.

Where the normative L2 text describes the complete graph, all finite reference depths, full receiver application or general Array semantics, an implementation gap is recorded as debt above rather than “correcting” the norm downward. During this audit the author explicitly clarified Q59: an ordinary named Structure has no arguments, while `A: B` remains a general application checked against the resolved A's contract. That answer is incorporated, not treated as permission to add explicit parameters. Any other unresolved normative conflict must be reported rather than guessed into code.

<a id="handoff"></a>
## 19. Handoff boundary

This document records the current kernel and its evidence boundary. It does not schedule further implementation, authorize another compiler slice, or declare the overall goal complete. The current merge release is landed as `8359a59`. After this documentation handoff, subsequent coding is stopped under the user's latest instruction. The replacement plan and dictionary preserve future acceptance/debt for a later explicit instruction; they do not resume that work automatically. Any future evidence update must preserve retained failures and residual limitations rather than rewriting the checkpoint as complete self-build.
