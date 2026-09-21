# L2 specification

L2 is LMX with special low-level operations. This specification defines those operations and the kernel model. Pure hermetic LMX (L3) semantics are in the [main specification](LMX_semantics.en.md); grammar is in the [grammar specification](LMX_grammar.en.md); lowering of the same mechanisms through L1 and C99 is in the [L1 specification](L1_spec_en.md). Implementation state, source snapshots, and migration work are kept in the [implementation notes](implementation-notes.en.md).

Both descriptions define one mechanism at their respective levels; the primary definition is here or in L1 and the paired document links it.

<a id="scope"></a>
## 1. Scope

L2 is the language of kernel mechanisms: `Lmx` structures, the arena's typed arrays, Message, mail, an L3 Thread turn, graph copy, and call. Its lowering chain is L2 → L1 → C99, as defined in [semantics](LMX_semantics.en.md#scope).

L2 defines machine mechanisms and L3 defines high-level programs. Generated intermediate L1 is a lowering stage, not the program's source graph. The interpreter consumes only the [L3 graph](LMX_semantics.en.md#l3-receiver), not L2 operations.

<a id="lmx"></a>
## 2. `Lmx` structure

Primary definition of the node record: `l2src/lmx.h.lm1`, `struct: Lmx`. Three fields, order normative:

| field | type | meaning |
| --- | --- | --- |
| `node` | `@: Lmx` | lexical parent; null at a root |
| `len` | `int` | number of immediate children, not bytes and not Array length |
| `data` | `@: void` | address of a cell in a typed array; the cell holds a value or a descriptor according to that array |

A child has no type tag. The type of a value is the address range that contains the **stored child value**, not the slot address. Slots are not added or removed after construction. A callable is an ordinary Structure: physical `child[0]` points at a METHOD record, later slots hold that occurrence's own fields; `M.node` is its lexical parent. The reserved `node` argument of a call is the selected `M` itself. L1 implementation: [L1](L1_spec_en.md#lmx).

<a id="type-by-range"></a>
## 3. Type by address range

Coarse kinds are `enum: LmxKind` (`NONE`, `PRIMITIVE`, `METHOD`, `ARRAY`, `CHILDREN`, `REF`, `STRUCT`). Concrete machine representation types are `enum: LmxType` (primitives, Array descriptors, METHOD, Structure, pointers, arrays of pointers; bases `LMX_TYPE_POINTER_BASE` and `LMX_TYPE_ARRAY_OF_POINTER_BASE`). One half-open interval is `struct: LmxRange` (`lo`, `hi`, `stride`, `kind`, `type`). Address classification is the arena index: `lmx_range_classify`, `lmx_range_type_of`, `lmx_range_pool` in `lmx_arena.h.lm1`. Nothing is stored on a cell to “say what it is”. Qualified types, including the result of composing the `independent: const: immutable` receiving expressions, are recognized by the same typed-address-range membership mechanism. Range/address-domain identity carries the qualified type, while `kind`/`type` describe its physical representation; the chain gets no separate value flag, classifier, `LmxType` or `LMX_DOMAIN_KIND_*`. The permanent-store role determines the lifetime of its ranges but does not replace their type. L1: [L1](L1_spec_en.md#type-by-range).

Core mechanisms absent from closed `lmx.h` register **domains** as separate constants in `lmx_implements.h.lm1` (`LMX_DOMAIN_MSG_RECORD` … `LMX_DOMAIN_POST_RING`) without extending the Message record.

<a id="pool"></a>
## 4. Typed service array

`struct: LmxChunk` / `struct: LmxPool` in `lmx.h.lm1`; operations in `lmx_pool.h.lm1`. An array hands out cells of one `stride` and grows by **adding a chunk**, not `realloc`: live addresses never move. Each chunk is registered in the arena index as another interval of the same `(kind, type)`. Cells are not returned one by one; reuse is the owner's free list (as mail does). Interned immutable atoms (for example 256 character cells) need not grow. L1: [L1](L1_spec_en.md#pool).

<a id="method-array"></a>
## 5. METHOD and Array

`struct: LmxMethod` is `{addr, sig}`; `addr` is the C entry, `sig` is a dispatch contract, not a call contract at this stage. The record stores no `node`. Graph copy keeps the METHOD pointer.

`struct: LmxArrayDesc` is `{len, data}` with no `Lmx` node. Length belongs to array elements, not Structure fields ([semantics](LMX_semantics.en.md#values)). L1: [L1](L1_spec_en.md#method-array).

<a id="arena"></a>
## 6. Arena

`struct: LmxArena` in `lmx_arena.h.lm1`: owned block list, N arrays, address→descriptor index, GC generation, `simple` flag. The arena manager is the sole writer of the index. After type is determined once, cells are written directly: a cell address never changes.

Principal operations: `lmx_arena_open` / `lmx_arena_open_simple`, `lmx_arena_take` / `take_n`, `lmx_arena_span`, `lmx_arena_attach` (join another arena without moving addresses), `lmx_arena_mark` / `lmx_arena_revert` (all-or-nothing for merge/copy), `lmx_arena_release`. Simple mode (`simple`): same index and address stability, no GC pass and no multi-chunk growth. Blocks are `LmxArenaBlock` in `lmx_arena_blocks.h.lm1`. Structure-slot references are `lmx_arena_refs`. L1: [L1](L1_spec_en.md#arena).

<a id="message"></a>
## 7. Message record

Closed record `struct: LmxMsg` in `lmx_message.h.lm1`. Exactly five fields, order as in the source:

| field | meaning |
| --- | --- |
| `running` | permission to continue; 0 inside a turn is a stop request, not completion |
| `success` | only actual completion of the assigned work |
| `handoff_ready` | mark that storage may be transferred without a copy |
| `graph` | C projection of the language root |
| `index` | index at the parent; 1 at the root |

Flag type is `uint_fast8_t` (`type: LmxFlag`). Mail, queues, scheduler, deadlines and family links are **not** fields of this record. The letter envelope is this record, not a wrapper around it. L1: [L1](L1_spec_en.md#message).

<a id="thread"></a>
## 8. L3 Thread

Not every Message is an L3 Thread. A letter has no turn. Object `struct: LmxThread` in `lmx_thread.h.lm1` **points at** the Message (the reverse field is forbidden by the closed record). It has mail, a scheduler, turn state, a list of reserved children, and a chain of live children in the **parent's arena** (`struct: LmxLink`: `alive` is the one sanctioned cross-lane handshake cell). Two separate APIs: `LmxThreadApi` and `LmxThreadMailApi`, not one merged heap. A whole turn is `lmx_thread_turn`. Its body executes in one of two mutually exclusive L3 Thread modes: native or through the graph interpreter. A separate operation explicitly requests the next turn's mode and the `endturn` boundary commits that request only after a successful turn. On a failed turn the request is cancelled: the current mode is preserved, the requested mode is reset to it, and a later switch requires a new explicit request. The dispatcher does not infer a mode from an entry, METHOD, or body and does not switch after a path fails. One Message never runs both paths and belongs to one OS thread during a turn, although it may move to another worker between turns. Interpreter entry does not copy the method or graph; its auxiliary frame may use reusable storage provided that entry cost remains comparable to native execution. L1: [L1](L1_spec_en.md#thread).

<a id="mailbox"></a>
## 9. Mailbox

The core's only synchronized collection is the mailbox `inbox` (`lmx_post.h.lm1`). One simplified Java-style monitor belongs to `LmxPost` itself and covers admission, take, and count on the incoming queue. The monitor permits same-OS-thread re-entry and provides enter/leave only: there is no wait set, `wait`, or `notify`. The lock does not escape into the address service, scheduler, graph, arena, or turn; `outbox` and `staged` remain owner-local.

Three lanes: `inbox` (admitted, not yet taken), `outbox` (published by a successful end-turn), `staged` (current turn's preparation; others must not see it). Inbox is a **ring in an ordinary dynamic array**. Initial capacity is two addresses; when full, it grows by approximately `3/2` (`2, 3, 4, 6, 9, …`). Growth runs under the same mailbox monitor: unread addresses are copied in FIFO order, then the private backing is replaced. The backing address is not a graph value, is never published, and is not classified as an LMX type. GC obtains a monitor-consistent snapshot of unread addresses through the mail module and never reads the backing directly. Allocation refusal or size overflow answers `LMX_POST_FULL` without damaging the old ring. Capacity check, growth, slot reservation, publication, take, and count update are serialized critical sections, so two producers cannot receive the same `inbox_tail`. The current collection deliberately uses simple `synchronized`; a lock-free MPSC ring belongs to a separate future mail implementation. `init` and `close` require quiescence: no OS thread is in `accept`/`take`/`count` or starts one before the operation completes. Outgoing and staged are lists of `LmxPostLink` (target address + next) from the box's pool. `LmxPostLink` is not an envelope. FIFO is admission order under the monitor. L1: [L1](L1_spec_en.md#mailbox).

<a id="own"></a>
## 10. Own locals and dirty

`struct: LmxOwnLocal` in `lmx_own.h.lm1`: `from` is the slot address `&children[i]`, plus `value` and `dirty`. Entry loads only unqualified fields the body uses. `dirty` is set only by an executed assignment (`lmx_own_write`), not by comparison with the graph and not by write capability. A checkpoint publishes only dirty locals and clears its own flag (`lmx_own_checkpoint`). An explicit `node\field` write does not go through the cache. L1: [L1](L1_spec_en.md#own).

<a id="call"></a>
## 11. Call

`lmx_call.h.lm1`: callability means `child[0]` falls in the METHOD domain. This stage performs **no** signature check (as in C; full typing is separate). The zero-argument form `lmx_call0` passes the reserved node — the occurrence itself. `sig` is not decoded. L1: [L1](L1_spec_en.md#call).

<a id="child"></a>
## 12. Child reservation

`lmx_child.h.lm1`: a child is built in **its own** arena; publication is one store into the parent's slot **at the end of the parent's turn**. Until publication, nobody else executes inbound work. Parent failure drops reservations without rolling back graph writes already done. `struct: LmxReservation` lives in the parent's arena. `lmx_child_handoff` attaches the child's arena to the parent only when `handoff_ready`. L1: [L1](L1_spec_en.md#child).

<a id="copy-merge"></a>
## 13. Graph copy and merge

Modules `lmx_graph_copy_owned` and `lmx_merge_owned`. Traversal matches Message creation: `node` links are rewritten through a source→copy map; METHOD pointers and eternal terminals are kept. Failure reverts via an arena mark ([§6](#arena)), not a partial graph. L1: [L1](L1_spec_en.md#copy-merge).

<a id="implements"></a>
## 14. `implements`

L2 supports the [L3 admission mechanism](LMX_semantics.en.md#admission): analytical checking of the tree's used named paths and execution of the receiving expression's unit tests by the graph interpreter. Physical address classification remains a separate value-representation operation.

<a id="gc"></a>
## 15. Collection

`lmx_gc.h.lm1` / `lmx_gc.lm1`. Generation on the arena; a chunk is marked by generation compare. Roots: Message record, object, mail and its nodes/ring, schedule, live graph, child chain. Simple arena mode refuses collection. L1: [L1](L1_spec_en.md#gc).

<a id="special"></a>
## 16. Special L2 operations

Low-level operations include address classification, taking an arena cell, arena attach/revert, mail enqueueing, `lmx_thread_turn`, `lmx_call0`, child reserve/publish, copy/merge, and collection. Semantic admission is defined in [§14](#implements).

<a id="lowlevel-scope"></a>
## 17. Machine operations: level boundary

The following sections define L2 machine contracts separately from pure L3. L1 is a different profile with direct C semantics; the comparison is in [L1](L1_spec_en.md#lowlevel-scope).

An ordinary Structure remains an `Lmx` graph, an Array a descriptor reference with backing, and a primitive a value in its domain. Machine addresses, raw C storage and foreign ABI do not replace these categories. L3 does not acquire machine operations merely because its reference implementation uses a pointer.

| Family | Purpose | L2 contract | L1 lowering |
| --- | --- | --- | --- |
| `@ⁿ:`, `@`, prefix `\` | Address slot, address and load | [Addresses](#lowlevel-address) | [Lowering](L1_spec_en.md#lowlevel-address) |
| `c.array`, raw index | Rectangular machine storage | [Arrays](#lowlevel-array) | [Emitter](L1_spec_en.md#lowlevel-array) |
| `cast`, `c.sizeof`, `c.name` | C cast, size, foreign call | [ABI](#lowlevel-abi) | [C99](L1_spec_en.md#lowlevel-abi) |
| Arithmetic and update | Machine-profile operations | [Expressions](#lowlevel-expression) | [C expressions](L1_spec_en.md#lowlevel-expression) |
| `synchronized` | Synchronization region | [Synchronization](#lowlevel-sync) | [L1 profile](L1_spec_en.md#lowlevel-sync) |

<a id="lowlevel-address"></a>
## 18. Typed addresses, loads and stores

### 18.1. Declaration and depth

`@: T p`, `@@: T pp`, `@@@: T ppp` declare machine address slots of depths 1, 2 and 3. The family of `@` heads is reserved for these operations; depth belongs to address slots, not ordinary structural references. Prefix expression `@x` takes one address. The next level addresses an already declared slot:

```text
int: x 5
@: int p
@@: int pp
@@@: int ppp
p: @x
pp: @p
ppp: @pp
```

`@:` is not an ordinary Array constructor. Low-level string `@: char "hello"` is an address primitive pointing to a C string; it does not automatically acquire a length descriptor. Ordinary Structure `User` and opaque primitive `FILE` do not become the same value kind because their C representations use pointers. An address primitive need not be a source integer: its target type is defined by the machine profile.

### 18.2. What @x addresses

The operation's common meaning is to obtain the selected data's address, not a temporary copy's. An L2 field's data reside in a typed arena array; different placement does not introduce a second meaning of address-of. The addressable target must separately be identified: field payload, parameter or pointer-holding slot.

| Category of x | Result | Effect of writing through the result |
| --- | --- | --- |
| Own graph field | Typed address of its classified payload | Changes the graph; neither assigns nor dirties the working copy |
| Explicit formal argument | Address of the current activation's parameter | Changes the parameter without copy-back |
| Dynamic input | Address of the current activation's through-parameter | Changes the local parameter, not the caller's source binding |
| Machine address slot | Address of the slot itself | Changes the address stored in it |

For an own field this is neither the `void *` slot address, `Lmx.data`, nor the own-cache address. For an Array value it addresses the descriptor rather than backing; the separate `@array[i]` form below addresses the selected backing element. A callable Structure is addressed as a Structure; obtaining its METHOD and executable entry are separate actions. Address-taking alone neither extends lifetime nor constitutes a write.

A local machine slot's address is needed, for example, for an output parameter: [printTree.lm2](../l2src/printTree.lm2) passes `@document` to `lm_p0_parse_file` so the function can store its result pointer. This addresses the pointer variable, not the document. [library_struct_local_forms.lm2](../l2src/tests/library_struct_local_forms.lm2) addresses a local imported C-ABI record. A temporary copy's address does not correctly implement addressing the selected data.

`@array[i]` is a valid L2 expression. It obtains the actual element's address in graph storage; no separate adapter or prior index check is required. Subsequent loads, stores and address arithmetic follow the C machine contract. Address-taking must not be implemented by reading the element into a temporary and then addressing that copy.

Starting with graph and working `x = 5`, `p: @x` followed by `\p: 9` leaves bare working `x` at 5 while an explicit graph read sees 9. If working `x` was not assigned, exit does not republish the old 5. A later assignment to working `x` creates a dirty write published under the ordinary rule. A parameter address exists only for the activation's lifetime; storing it in the graph does not extend that lifetime.

### 18.3. Loads, paths and restrictions

An argument has a distinct same-name own-binding rule: an executed declaration or assignment-as-declaration associates the same local variable with the body's field for subsequent dirty publication. Its address and lifetime remain those of the parameter; the previous graph value is not loaded over the input, and writes before the binding line are not published. This does not permit addressing a temporary copy of an ordinary graph field or Array element. Binding activation and body hosting are specified in [L3](LMX_semantics.en.md#dynamic).

`\p` loads through a typed address; `\p: value` stores there when permitted. `p\field` follows either an explicitly imported machine ABI field or an ordinary structural path, depending on p's category. These cannot be conflated as universal `->`: a Structure uses the graph, while raw ABI access uses known layout. L2 indexing checks no bounds, for either raw addresses or graph-backed Arrays. Array index and descriptor validation belong to L3. Reading a descriptor to obtain backing is not descriptor validation. Field and index chains bind more tightly than prefix `@` and `\`.

`*` is not source dereference, `&` is not address-of, `^` is not field-follow, and `.`/`->` are not ordinary L2 field access. `*`, `&`, `^` may have distinct arithmetic/bitwise roles. By-value C aggregate access uses an explicit C form such as `c.value.field`, not a redefinition of graph paths.

Writing through an address neither removes `const`/`immutable`, admits a dangling address nor establishes automatic ownership. Receiving-expression admission uses the [unified mechanism](#implements); physical classification uses the [arena index](#type-by-range).

<a id="lowlevel-array"></a>
## 19. Raw c.array storage

### 19.1. Input and result

`c.array` consumes exactly one declaration whose head contains one or more bracket groups, optionally inside a single `const`. Unrelated children and extra declarations are outside the minimal contract. Examples: `c.array: [3]: int: values 2 4 6`, `c.array: []: char buffer 256`.

A nonempty group `[rows]` contains its extent. Empty `[]` consumes one extent after the type and name, in dimension order; remaining fields are initializers. A missing extent is an error, not a request to infer it from an initializer. A compound extent belongs inside a nonempty group. The contract admits mixed groups.

The result is a C-storage designator, not an Array value or graph node. It creates no arena, owner, `len`, shape/stride metadata or bounds checks. Conversion to an ordinary Array requires an explicit operation specifying backing address, shape and lifetime.

### 19.2. Indexing, rank and lifetime

Each `[i]` suffix consumes one dimension: two-dimensional C storage uses `a[i][j]`. Partial indexing denotes the remaining subarray; full indexing denotes an element lvalue. This is not a view. Decay of a rank-one remainder follows the C profile; a higher-rank remainder is not flattened into an arbitrary `T **`.

The address of an entire array or subarray is a pointer-to-array, not an ordinary increment of element-pointer depth. The minimal contract defined here provides no such declarator and requires an unsupported form to be rejected rather than mistyped. A fully selected element may be addressed. `const` qualifies the base element; for pointer arrays it does not automatically make pointer slots const.

Block storage has C automatic lifetime; a runtime extent follows C99 VLA rules and admits no initializer. In the hosted profile, top-level storage has internal linkage, constant extents and static initialization. Without an initializer, automatic elements are indeterminate and static elements are zero. Initialization zero-fills omitted elements and diagnoses excess or incompatible ones. The conservative multidimensional profile requires explicit nested groups rather than flat brace elision; a top-level address initializer requires its target declaration to have been emitted.

Retaining a local array's address does not extend its lifetime. Escape beyond raw storage lifetime requires an explicit adapter/contract; it must not silently become a live Array. Raw indices are not automatically checked. Statically detectable danger and invalid static initializers belong to machine-profile diagnostics.

<a id="lowlevel-abi"></a>
## 20. Foreign types, conversions and calls

`cast: (T) value` is a machine cast, not an [L3 numeric converter](LMX_semantics.en.md#descriptions) or proof of range/lifetime safety. `c.sizeof` requests a machine type/object size, not a Structure field count or Array length. An opaque type can be stored and passed without exposing its fields; raw access requires a known ABI.

`c.name` selects a foreign C symbol. An ordinary L2 function requires no `c.`. Parameters, result, ownership and resource release belong to the adapter contract. Permitting a C call does not wrap its result in a graph or make a pointer a portable Message. In the descriptive contract, `external` wraps one `fn`/`sub` and requests a foreign entry; the adapter preserves the source method contract.

`include` supplies explicit headers, retaining specified `<…>`/quotes; an undelimited path becomes local. `os` selects a written platform branch without changing repeated graph-field order. `predef`/import link selected dependencies without permitting directory scans or eager construction of every Structure.

<a id="lowlevel-expression"></a>
## 21. Machine expressions and updates

The minimal profile includes grouping; prefix `@`, `\`, `++`, `--`, `+`, `-`, `!`, `~`; postfix `++`/`--`; arithmetic `+ - * / %`; comparisons `= != < <= > >=`; logical `&& ||`; and bitwise `& | ^`. Here `=` compares, while `target: value` writes. Overflow, shifts, division, rounding and conversions depend on the selected machine profile; unconditional checked L3 arithmetic must not be attributed to them.

`target[index]` consumes an index expression. It is not a repeated-field qualifier `target\[index]field` or the constructor head `[]:`. Target category determines how data are located without adding L2 bounds checks. Checked Array operations belong to L3; L2 provides machine access to the selected cell. Assignment neither appends a repeated field nor creates a namespace.

Control forms are `if`/`else`, `while`, `until`, `for(init, condition, step)`, `return`, `break`, `continue`, and [synchronized](#lowlevel-sync). Shared branch and loop rules are in [L3](LMX_semantics.en.md#branches); `match`, `each`, `retry`, and `yield` require separate L2 operations or a profile. Lowering to [L1](L1_spec_en.md#lowlevel-expression) preserves the distinction between graph updates and raw stores.

<a id="lowlevel-sync"></a>
## 22. synchronized and synchronization boundaries

`synchronized` remains a general low-level L2 capability. Restricting kernel synchronization to the postal mechanism does not remove the language operation. Pure L3 has no raw locks. The contract consumes an object/address expression and structural body rather than an exposed lock/unlock pair.

```text
synchronized: @object
    updateObject: object
```

A nested body is a separate structural argument field. `synchronized: @lock (break)` states it explicitly; `synchronized: @lock break` leaves `break` in the inline sequence and does not allow the parser to silently reinterpret it as the body.

The monitor profile defines entry/exit and, where required, same-thread re-entry. The minimal profile used by the postal collection (§9) is reentrant and has no `wait`/`notify`; it is mutual exclusion, not a condition queue. The region is released on normal completion and exiting `return`, `break`, `continue`; the general cleanup protocol governs other exits. A result is retained before release. Calls inside preserve ordinary argument-evaluation and dirty-publication ordering.
