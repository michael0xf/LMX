# L2 Specification

L2 defines the kernel mechanisms and machine operations. L3 semantics are in the [LMX specification](LMX_semantics.en.md), syntax in the [grammar](LMX_grammar.en.md), and C99 lowering in [L1](L1_spec_en.md). This document does not restate head resolution, declaration, or call rules. Implementation status belongs to the [notes](implementation-notes.en.md).

<a id="scope"></a>
## 1. Scope

The target chain is L3 with L2 insertions → generated L1 → C99. L1 is an intermediate language. The interpreter executes the stored L3 graph; L2 operations require native lowering.

<a id="lmx"></a>
## 2. `Lmx` Structure

The target physical model has a common `Lmx` base for graph objects. A language Array is an `Lmx` Structure with fixed, typed element storage, not a separate `VoidArray` record serving as the base of `Lmx`. Both ordinary Structures and Arrays have structural `parent` and `native`; the exact C99 layout of the shared base and Array specialization remains a migration decision. The current inverted C layout is recorded only in the [implementation notes](implementation-notes.en.md#l2-status), not prescribed as the target.

`parent` describes structural nesting, not Message parentage. For an Array created at an `arr` field, its parent is the graph occurrence representing that field; for a Structure constructed as an owned Array element, its parent is the Array. Storing a reference to an existing Structure in an element does not reparent that referent. Lexical visibility follows the construction position, without an additional hidden context. `native` selects a native entry; zero walks the stored body. A graph object has no stored name, model tag, or extra execution-state fields. Structure field count and Array element count are fixed at construction; addressable cells do not move. Primitive elements remain typed cells and need no individual `parent` field.

<a id="interpretable-tree"></a>
### 2.1. Interpretable tree

A resolved receiver selects the typed pool when its result is constructed; similarity to fields already declared in `data` does not turn their owner into that receiver's result. In particular, only a Structure produced by executing `fn` enters the pool of `fn` results, not an arbitrary Structure with similar parts in `data`.

The stored graph is the program: declarations, values, operators, and nested bodies initially follow source order; later writes change this same graph. Native lowering does not replace it with a second AST or data graph. A primitive already has a typed arena cell; it needs no redundant `leaf` or Structure wrapper. Atoms still part of the current program are retained.

Entity names live only in an external table. The walker may obtain the written head's name by its address to determine the head's role; this is not textual variable lookup for field access. The translator sees the parser tree, while completed `native` needs no name for invocation. Comments play no dispatch role. `toLmx` emits the current graph composition and order: an overwritten operator is not reconstructed from source or a hidden copy. Launch data, call status, and Thread membership are not appended to the program graph.

References stored as data form a graph and may produce cycles. Structural `parent` forms a tree. Address classification determines a value's kind; the slot address and address stored in that slot are distinct.

<a id="type-by-range"></a>
## 3. Type by address range

Derived graph objects preserve the common `Lmx` contract. The pool and range identify the physical kind selected at construction and, for an Array, its element type. This classifies an address; it is not a stored name or opcode in the graph, nor a separate user-defined type for every Structure model. The old layout in which `Lmx` contains `VoidArray` remains transitional, not the template for the new Array variants.

An arena classifies an address through a registered half-open `LmxRange` interval and its owning pool. A cell has no in-band type tag. Ordinary Structures and graph Arrays share the `Lmx` base while ranges distinguish storage shape and element type; user models do not generate one C type or pool apiece. Primitive, reference, graph-object, and backing pools differ by physical access contract. Typed arena arrays are storage, not separate language Arrays. Ordinary and `immutable` Structures are allocated in separate pools; an already published ordinary Structure cannot become `immutable` in place. `implements`, not physical type, establishes model compatibility.

<a id="pool"></a>
## 4. Typed pool

A pool issues fixed-stride cells and grows by adding chunks, without `realloc` of live cells. Each chunk registers an interval of the same type. An issued address stays stable until its ownership is released. The arena manages the range index.

In a graph Array, `void *data` holds the backing address of the selected typed pool; it does not make the elements untyped. L2 obtains a pointer to the actual element type from that address for loads and stores; the arena range confirms that type, cell stride, and alignment. A pre-existing pool of `void *` slots cannot be read as an arbitrary `T` array merely by casting its pointer. Addressable graph-reference slots retain their own `void **` and stored-value conversion contract.

<a id="method-array"></a>
## 5. Native entry and Array

`LmxEntry` is the native-entry word, not a second method object. A graph Array carries the common `Lmx` base and exactly its fixed count of typed elements. It has no dynamic reserve and does not move published addressable cells. With `arr: []: (...)`, the Array value retains its graph position; a later `MyLmxStructFromArray: arr` binds another name by reference to that same Array under the general rule, rather than constructing another object or reconstructing a Structure from bytes. A dynamic List is a separate type and contract; its movable backing is not used for addressable Structure or Array slots.

<a id="arena"></a>
## 6. Arena

Each Message owns one logical arena, which may contain multiple chunks and ranges. `lmx_arena_attach` transfers ownership without moving addresses. `mark/revert` rolls back a failed copy or `merge` construction. Simple mode retains classification and address stability but does not run GC. An independent immutable branch may remain in its owner's arena under the [L3 contract](LMX_semantics.en.md#eternal); a separate pool alone grants no such right.

<a id="message"></a>
## 7. Message record

The closed `LmxMsg` record has exactly `running`, `success`, `handoff_ready`, and `graph`. Its local identity is the record address. Mail, scheduling, and Thread parent are not its fields. `running = 0` during a turn requests stopping; user code sets `success = 1`, which suffices to stop a Thread at the turn boundary; the system does not reset `success` to zero. `handoff_ready` permits storage handoff. `graph` refers to the language root.

<a id="thread"></a>
## 8. L3 Thread

Not every Message runs. A running Thread is allocated from the outset as `LmxThread` with `LmxMsg` as its first member by value. The Thread address equals this prefix address; tail access requires exact Thread classification. A standalone `LmxMsg` cannot become a Thread in place.

Direct children live in the sole List held by `Thread.children`. This is Thread state, not a `message.graph` field. `Thread.parent` belongs to the Message hierarchy and does not modify `Lmx.parent`. Competing workers may not execute one Thread identity.

<a id="root-close"></a>
### 8.1. R0 and shutdown

R0 is an ordinary child Thread of the top host scaffold. Launch data and settings belong to the scaffold and are passed to R0 explicitly; they are not added to R0's source graph. The top scaffold has no parent but gains no special API. Shutdown cascades through each Thread's sole direct-child List. A host watchdog controls the whole subtree's timeout; expiry terminates the process rather than declaring partial shutdown successful.

<a id="mailbox"></a>
## 9. Mailbox

Each Thread owns an `LmxPost`. `staged` prepares the current turn's messages, a successful boundary publishes them to `outbox`, and `inbox` holds admitted but untaken messages. An `inbox` element is the inseparable pair `[target, source_arena]`: the producer does not mutate the recipient arena; its owner attaches the donor before releasing the target. Failure retains the pair. Admission order is FIFO.

`inbox` is a ring over a separate DynamicArray; its backing may move but is not an addressable graph slot. One reentrant monitor owned by `LmxPost` covers admission, take, and count. `outbox` and `staged` remain owner-local. `post` uses this same mailbox for an ordinary LMX call, not another transport. The language API is specified in [L3](LMX_semantics.en.md#thread-message-api).

<a id="own"></a>
## 10. Structure execution

Execution uses the complete stored Structure. Native code and the walker must agree on working-field reads, writes, `dirty` state, and publication under [L3 §12](LMX_semantics.en.md#dynamic). A declared field has a graph storage place; assignment does not add a slot to an existing `Lmx`. Pointers to graph slots must remain valid. The `args/return/var/body` method layout is an approved v3 migration target; its physical ABI is not described here as already implemented.

<a id="call"></a>
## 11. Call

The selected code's `Lmx.native` chooses native entry or walker. A call receives selected `code` and `data` selected explicitly or by the shorthand, the actual arena, `node` as the callable occurrence's lexical parent, and prepared arguments. In the normal split call, the used executable part of `code` is stable when write paths and aliases prove it, while `data` changes; these are call roles, not an `immutable` qualification of the whole Structure. Unary `call: code` selects its `var`; absent `var` does not imply `data = code`, and a local data-field write then refuses. Explicit `call: code code` supplies that value as `data` under the general rule and tests Structure universality and code mutation for future on-the-fly compilation, rather than defining a special execution path. For **any** admitted pair of Structures, field access and publication of already computed `dirty` values use one proven `implements` address map; equal ordinal positions are not assumed. A checkpoint stores the ready value into the selected `data` slot without re-evaluating the expression or repeating admission.

Entering `call`, including `call: code code`, does not invalidate `native`. With the place and new value determined and admitted, the general write path checks native-implementation dependencies: a direct path at the write, a working `dirty` value at its publication checkpoint. The physical slot write and removal of incompatible entries are atomic for the next or a recursive dispatch. A working value before publication, a refused write, and a call that does not change the graph leave `native` intact; a compatible entry survives an ordinary data-value change. The dependency may belong to enclosing code, not just the Structure containing the written slot. If an L2 body becomes incompatible with its old entry, a matching native implementation or refusal is required **before** publishing the change: the L3 walker does not execute L2. Do not retry a call on another engine after effects.

An ordinary executable named form in `code`, including `name: ... end: name` and forms inside inline `if`/`for`, assigns its value to the prepared same-named place in the selected `data`. It does not declare a new field in `code`; declarations through `fn`/`fm`/`sub` keep their own receiver contracts. The `data` map considers root-level heads but not heads inside their initializers. One source occurrence permits `data\field`; two or more require zero-based `data\[N]field`. The first occurrence is not chosen automatically, and this does not create multiple same-named data fields. Nesting in `code` does not select another place. Arbitrary `data` is not auto-completed at a call: if a required place is absent or bare access is ambiguous, the call fails during execution/admission, not because the source form itself is a translation error. Method `var` preparation allocates its fields in advance and is separate from this rule. Only an explicit `call` or callable invocation, including `fn`, starts a new binding scope, where an own field may shadow an outer one. There is no shadowing within one callable; inline `if`/`for` are operators within the same activation, not new scopes, despite being Structures.

A null argument transport-cell address denotes absence; a present argument holding a null reference is still present. A number travels in storage of its declared width, an object reference through a canonical pointer-value cell. Callback status and returned value differ; the result contract distinguishes `void` from a present null reference.

<a id="child"></a>
## 12. Child reservation

A child is built in its own arena. It is absent from `Thread.children` until successful publication; publication at turn end adds its physical reference to that List without changing the source graph. Failure cancels the reservation but does not roll back arbitrary prior graph writes.

Adoption checks whether owners of `independent: immutable` branches used by the child remain on its new Message-ancestor chain. Failure leaves membership and `Thread.parent` unchanged. `adopt: msg newParent` performs adoption; `independent: msg newParent` separately prepares this particular adoption by copying only obstructing branches into `msg`'s arena, without changing the parent. These operate on the Message hierarchy, not `Lmx.parent`.

<a id="copy-merge"></a>
## 13. Graph copying and merge

`merge` creates a new graph using one source→copy address map. The map preserves shared targets and cycles, rewrites internal references and `parent` to copies, and creates no separate instance for each `lnk`. The complete used graph, including executable operation records, is copied; the exception is qualified `independent: immutable` branches explicitly retained by their owner. An unchanged applicable native implementation may be reused only if the address and type contract of its used fields also holds. A partial copy retaining addresses in a releasable source arena is invalid.

The first operand fixes model slot order; a matching field of a later operand replaces that slot's value after admission, while a new field is appended in the new result. Source operands remain unchanged. Body and argument selection semantics are in [L3 §20](LMX_semantics.en.md#composition).

<a id="implements"></a>
## 14. implements

L2 stores a proven mapping from used fields of the receiving model to physical fields of the candidate for any admitted pair of Structures. It serves reads, writes, address taking, and direct publication of ready `dirty` values, including differing field order; there is no separate map for `call` or `var`. At one structural level, one name denotes one field; `s\[N]field` selects a source head occurrence, not the Nth data field. The map does not look up runtime names, copy the candidate, or waive a new Consumer's checks. Admission semantics and explicit tests are in [L3 §7](LMX_semantics.en.md#admission).

<a id="gc"></a>
## 15. Collection

GC belongs to the arena. Roots include Message, live graph, mail, execution state, and `Thread.children`; Thread state retains that List independently of source fields. From a live value, collection also follows an established `implements` correspondence to its required Structure: replacing a graph field does not release the model while that value still needs its admission. This rule does not retain a transient admitting frame; retirement of the frame removes a record that depends on it. These are address-proof dependencies, not hidden graph fields. The owner retains constructed `independent: immutable` branches until its arena is destroyed. Simple mode does not collect. Unloading a later module needs a separate contract and is not invented here.

<a id="special"></a>
## 16. Special L2 operations

The kernel provides address classification, cell allocation, arena attach/revert, mail, Thread turns, calls, child reservation, copying/merge, and collection. These operations do not create another namespace or auxiliary execution graph.

<a id="lowlevel-scope"></a>
## 17. Machine profile

L2 machine types retain the representation and numeric semantics of corresponding target-platform C99 types, including the signedness of plain `char`. L3 does not gain raw memory access merely because its graph uses pointers internally. L1 has a separate C-like surface.

<a id="lowlevel-address"></a>
## 18. Addresses, loading, and writing

M3 orders flat declarations as name followed by requirement/value. N1–N6 admit both an outer-head place (`ptr: @: Model: 0`) and an additional two-field `@:` form: `@: p 0`, `@: p Model`, `@: p Model: 0`, `@: p Model: Other`. The first field is the place-name atom and is not invoked; the second field, including the nested Frame `Model: Other`, is consumed under the ordinary expression rule. Its consumption alone does not write to `Model`. P0 does not single out these forms: parsing is common, while the `@:` contract assigns field roles. Existing three-field `@: p Model 0` and `@: p Model Other` are tracked separately in M3; adding the two-field form does not itself remove them. Initial `@: p` or `@: p 0` creates a void reference; a later address write does not retroactively add a requirement. Pointer depth `@ⁿ:` has no arbitrary numerical cap.

Unary `@x` addresses the real value cell: for a graph Structure/Array, the `void *` slot holding a descriptor reference; for a primitive, its typed cell; for a formal, its activation cell. Slot, slot address, and referent differ. Native access to a graph reference slot uses `void **` with conversion of its stored `void *`; dereferencing it as `Lmx **` violates C99. Do not take the address of a temporary cache or ABI carrier. By precedence, `@x\field` means `@(x\field)`.

Prefix `\p` follows a reference; `p\field` accesses either a graph field or an explicitly imported machine ABI according to `p`'s category. `@array[i]` addresses the actual backing element. L2 adds no automatic bounds check; checked access belongs to L3. Address operations neither bypass `const`/`immutable` nor extend target lifetime.

<a id="lowlevel-array"></a>
## 19. Raw C storage

A `c.*` token is an explicit C door. A language Array remains an `Lmx`-based graph object with typed elements; it does not become a raw C array. Conversion between them requires an explicit operation accounting for shape and lifetime. Typed arena arrays are internal storage, not another kind of language Array. L2 introduces no special `c.array` entity.

<a id="lowlevel-abi"></a>
## 20. External types and ABI

`cast: (T) value` is a machine cast, not a checked L3 conversion or proof of range, alignment, or lifetime. `c.name` selects a foreign C symbol; its adapter defines arguments, result, and ownership. `c.sizeof` means C `sizeof`, not Array length or Structure field count. `include` and `os` select explicit dependencies and a platform branch, not runtime module discovery.

`os` selects a target-platform branch but introduces no separate comparison of branches for equal method sets, signatures, or serialized contracts. Differences between branches are not errors in themselves. Selected declarations and bodies use the ordinary L2 mechanisms; wherever a receiving site requires compatibility, the ordinary `implements` admission and its address map apply, as outside `os`. Selecting a branch creates neither an additional common interface nor a private `os` admission mechanism. [Author clarification, 2026-10-23](../LMX_blog/2026-10-23.md).

The existing `os` receiver selects a branch for the target platform before its contents are semantically processed; no separate new operator is needed. Common structural parsing identifies the branches, but unselected declarations and bodies undergo no name resolution, type or contract checking, dependency collection, or code generation. Their `include`/`define`/`predef` do not add dependencies or declarations to the selected variant. Selected contents pass through the same common L2 pipeline as outside `os`, including ordinary native and walker execution for supported bodies, without a private parser, interpreter, or fallback native route. The target platform is consistent across translation stages, not accidentally determined by the translator host. This is the approved implementation direction, not a claim of completed support. [Author clarification, 2026-10-23](../LMX_blog/2026-10-23.md).

`implements` remains a runtime operation, not a static comparison of alternative platform implementations or a mechanism for suppressing their translation. If another language facility is needed later, its general design is discussed with the author; the stated selection by the existing `os` does not require another approval of a new operator.

In an evaluated call through the C door, C functions and macros receive already evaluated L2 values, not substituted L2 expression text. L2 arguments are evaluated once in the ordinary lexical order and under the ordinary exit rules before being passed to the foreign call; macro expansion neither repeats nor cancels that evaluation. Thus, with `#define BYTES(x) sizeof(x)`, `c.BYTES(touch())` first executes `touch()` once and passes its value to the macro, although C does not evaluate the operand of the resulting `sizeof`. This also applies to a macro that uses its parameter several times or does not use it.

Literal `c.sizeof` has the role of a C operator, not a C-function call: after common preparation its operand follows C99 `sizeof` rules, not the prior evaluation of a foreign-call argument. Expanding an arbitrary macro into `sizeof` does not give it this role. The distinction is a semantic role after common parsing, without C-name registration or a second parser. For an ordinary non-variably-modified type, `c.sizeof(touch())` does not execute `touch()`; this does not override C99 rules for variably modified types. [Author clarification, 2026-10-22](../LMX_blog/2026-10-22.md).

<a id="lowlevel-expression"></a>
## 21. Machine expressions

The machine profile includes grouping, arithmetic, comparisons, logic, bitwise operations, `++/--`, indexing, and ordinary control flow. `=` in an expression compares; `target: value` writes. Overflow and raw indexing follow the machine contract, not L3 guarantees. `a[i][j]` addresses a rectangular multidimensional Array; `a[i]\[j]` follows a reference to a separate Array. `s\[N]field` in a Structure used as data selects a source occurrence, not a machine Array element.

<a id="lowlevel-sync"></a>
## 22. synchronized

`synchronized: lock body` defines a structured exclusion region, not an open lock/unlock pair. Exiting releases the monitor. The mail monitor is one concrete reentrant use without `wait`/`notify`; pure L3 has no raw locks.
