# L2 Specification

L2 defines the kernel mechanisms and machine operations. L3 semantics are in the [LMX specification](LMX_semantics.en.md), syntax in the [grammar](LMX_grammar.en.md), and C99 lowering in [L1](L1_spec_en.md). This document does not restate head resolution, declaration, or call rules. Implementation status belongs to the [notes](implementation-notes.en.md).

<a id="scope"></a>
## 1. Scope

The target chain is L3 with L2 insertions → generated L1 → C99. L1 is an intermediate language. The interpreter executes the stored L3 graph; L2 operations require native lowering.

<a id="lmx"></a>
## 2. `Lmx` Structure

Physical record:

```c
typedef struct { size_t size; void *data; } VoidArray;
typedef struct Lmx { VoidArray array; struct Lmx *parent; LmxEntry native; } Lmx;
```

`array` is the first member of `Lmx` and the array of its immediate `void *` child slots. `array.size` is the number of slots and `array.data` points to their backing; slots are neither added nor moved after construction. `parent` is the lexical Structure parent, not the Message parent. `native` selects the native entry; zero means walking the stored body. The record has no name, model tag, or extra execution-state fields. The address of embedded `array` equals the `Lmx` address, but classification distinguishes a Structure from a standalone Array.

<a id="interpretable-tree"></a>
### 2.1. Interpretable tree

The stored graph is the program: declarations, values, operators, and nested bodies initially follow source order; later writes change this same graph. Native lowering does not replace it with a second AST or data graph. A primitive already has a typed arena cell; it needs no redundant `leaf` or Structure wrapper. Atoms still part of the current program are retained.

Entity names live only in an external table for translation and `toLmx`; execution never looks them up as strings. Comments play no dispatch role. `toLmx` emits the current graph composition and order: an overwritten operator is not reconstructed from source or a hidden copy. Launch data, call status, and Thread membership are not appended to the program graph.

References stored as data form a graph and may produce cycles. Structural `parent` forms a tree. Address classification determines a value's kind; the slot address and address stored in that slot are distinct.

<a id="type-by-range"></a>
## 3. Type by address range

An arena classifies an address through a registered half-open `LmxRange` interval and its owning pool. A cell has no in-band type tag. All ordinary Structures share the physical `Lmx` type; user models do not generate one C type or pool apiece. Primitive, reference, descriptor, backing, and Structure pools differ by physical access contract. Ordinary and `immutable` Structures are allocated in separate pools; an already published ordinary Structure cannot become `immutable` in place. `implements`, not physical type, establishes model compatibility.

<a id="pool"></a>
## 4. Typed pool

A pool issues fixed-stride cells and grows by adding chunks, without `realloc` of live cells. Each chunk registers an interval of the same type. An issued address stays stable until its ownership is released. The arena manages the range index.

<a id="method-array"></a>
## 5. Native entry and Array

`LmxEntry` is the native-entry word, not a second method object. A standalone `VoidArray {size, data}` describes exactly `size` elements; its base descriptor has no `capacity` and does not change backing. A dynamic List is a separate type and contract; its movable backing is not used for addressable Structure slots.

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

An ordinary executable named form in `code`, including `name: ... end: name` and forms inside inline `if`/`for`, assigns its value to the first same-name occurrence in the selected `data` in the full graph's structural order. It does not declare a new field in `code`; declarations through `fn`/`fm`/`sub` keep their own receiver contracts. Nesting in either `code` or `data` does not select another place: admission checks the first occurrence rather than skipping to a later compatible one. Arbitrary `data` is not auto-completed at a call: if a required place is absent, the call fails during execution/admission, not because the source form itself is a translation error. Method `var` preparation allocates its fields in advance and is separate from this rule. Only an explicit `call` or callable invocation, including `fn`, starts a new binding scope, where an own field may shadow an outer one. There is no shadowing within one callable; inline `if`/`for` are operators within the same activation, not new scopes, despite being Structures.

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

L2 stores a proven mapping from used fields of the receiving model to physical fields of the candidate for any admitted pair of Structures. It serves reads, writes, address taking, and direct publication of ready `dirty` values, including differing field order; there is no separate map for `call` or `var`. At one structural level, one name denotes one field; the old multiple-same-name `[N]name` mapping is not normative. The map does not look up runtime names, copy the candidate, or waive a new Consumer's checks. Admission semantics and explicit tests are in [L3 §7](LMX_semantics.en.md#admission).

<a id="gc"></a>
## 15. Collection

GC belongs to the arena. Roots include Message, live graph, mail, execution state, and `Thread.children`; Thread state retains that List independently of source fields. The owner retains constructed `independent: immutable` branches until its arena is destroyed. Simple mode does not collect. Unloading a later module needs a separate contract and is not invented here.

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

A `c.*` token is an explicit C door. An ordinary Array remains a `VoidArray {size, data}` descriptor with typed backing; it does not become a raw C array. Conversion between them requires an explicit operation accounting for shape and lifetime. L2 introduces no special `c.array` entity.

<a id="lowlevel-abi"></a>
## 20. External types and ABI

`cast: (T) value` is a machine cast, not a checked L3 conversion or proof of range, alignment, or lifetime. `c.name` selects a foreign C symbol; its adapter defines arguments, result, and ownership. `c.sizeof` means C `sizeof`, not Array length or Structure field count. `include` and `os` select explicit dependencies and a platform branch, not runtime module discovery.

<a id="lowlevel-expression"></a>
## 21. Machine expressions

The machine profile includes grouping, arithmetic, comparisons, logic, bitwise operations, `++/--`, indexing, and ordinary control flow. `=` in an expression compares; `target: value` writes. Overflow and raw indexing follow the machine contract, not L3 guarantees. `a[i][j]` addresses a rectangular multidimensional Array; `a[i]\[j]` follows a reference to a separate Array. Named index selector `a\[i]field` is unsupported.

<a id="lowlevel-sync"></a>
## 22. synchronized

`synchronized: lock body` defines a structured exclusion region, not an open lock/unlock pair. Exiting releases the monitor. The mail monitor is one concrete reentrant use without `wait`/`notify`; pure L3 has no raw locks.
