# L2 specification

L2 is LMX with special low-level operations. This specification defines those operations and the kernel model. Pure hermetic LMX (L3) semantics are in the [main specification](LMX_semantics.en.md); grammar is in the [grammar specification](LMX_grammar.en.md); lowering of the same mechanisms through L1 and C99 is in the [L1 specification](L1_spec_en.md). Implementation state, source snapshots, and migration work are kept in the [implementation notes](implementation-notes.en.md).

Both descriptions define one mechanism at their respective levels; the primary definition is here or in L1 and the paired document links it.

<a id="scope"></a>
## 1. Scope

L2 is the language of kernel mechanisms: `Lmx` structures, the arena's typed arrays, Message, mail, an L3 Thread turn, graph copy, and call. Its lowering chain is L2 → L1 → C99, as defined in [semantics](LMX_semantics.en.md#scope).

L2 defines machine mechanisms and L3 defines high-level programs. Generated intermediate L1 is a lowering stage, not the program's source graph. The interpreter consumes only the [L3 graph](LMX_semantics.en.md#l3-receiver), not L2 operations. L3 is compiled by the same rules as L2; a constructed L3 graph *may* be executed by the interpreter, L2 operations may not. The root body of a `.lm2` file is an L3 Structure; only method bodies execute natively, and the current toolchain runs the root body through the interpreter (an implementation default, not a language rule); a Thread has no mode -- dispatch follows the descriptor (`METHOD.addr != 0` is a native entry through the prim ABI, `addr = 0` walks the occurrence's body); the value of an activation/file is its last evaluated expression. L3 is a subset of L2: a named and an anonymous Structure always belong to level L3, L2 operations are available only inside method bodies (`fn`, `sub`, `fm`), and `@` of any depth in L3 is a reference-declaration receiver only ([semantics](LMX_semantics.en.md#scope)).

<a id="lmx"></a>
## 2. `Lmx` structure

The normative physical node record and its array of child references are:

```c
typedef struct { size_t size; void *data; } VoidArray;
typedef struct Lmx { VoidArray array; struct Lmx *parent; LmxEntry native; } Lmx;
```

`array` is first and embedded by value: `&node->array` has the same address as `node`, but range classification still treats the `Lmx` allocation as a Structure (`LMX_KIND_STRUCT`), not a standalone Array descriptor (`LMX_KIND_ARRAY`). It is the node's **actual array of immediate physical child references**, not an auxiliary C wrapper. `array.size` counts its `void *` slots, not bytes or capacity; `array.data` points to their backing. The arena registers that backing as a child-reference storage range (`LMX_KIND_CHILDREN`), not another Array descriptor. `VoidArray` itself does not replace an `LmxRange` index entry: the index classifies backing addresses and their stored referent values separately. `parent` is the immediately enclosing working-graph Structure, null at a root. `native` is the direct reference to the native implementation of this Structure's body (the C entry), null when there is none; it is not a lexical element and not a graph field, so it lies in the record after `parent`, not among the child slots, and graph copy carries the word verbatim. `Lmx` has three direct C members, with no tag or growth field. The L1 projection is defined in [L1 §3](L1_spec_en.md#lmx).

A child has no type tag. The type of a value is the address range that contains the **stored child value**, not the slot address. Slots of an ordinary Structure are not added or removed after construction; the dynamic membership of direct child Messages is a separate List (`KIND_LIST`) value in the graph, not a base Array and not a preallocated group of Structure slots. A Structure in code position is an ordinary Structure with no special slot: its signature is an ordinary lexical graph field, and its native implementation is the `native` word, which selects execution (non-null enters C, null runs the walker over the body operators, [§10](#own)); `M.parent` points into the lexical space above the method. The transitional implementation keeps a METHOD or Callable record in physical `child[0]`, with later slots holding that occurrence's own fields. At entry the reserved language argument `node` is `M.parent`, not `M` itself, and stays fixed throughout the activation. Every `if` body, loop and other nested Structure has its own immediate `parent`, but that internal chain does not rebind `node`. `parent` is not a reserved language word. The Callable ABI additionally passes hidden `self`, the activation's data instance ([§10](#own)); this is neither a source name nor a second form of `node`. In the transitional implementation the METHOD ABI and the Callable ABI are selected by classifying the address range of the stored `child[0]` value, without textual or numeric dispatch; in the target form the dispatcher is the `native` word. L1 implementation: [L1](L1_spec_en.md#lmx).

<a id="type-by-range"></a>
## 3. Type by address range

Coarse kinds are `enum: LmxKind` (`NONE`, `PRIMITIVE`, `METHOD`, `ARRAY`, `CHILDREN`, `REF`, `STRUCT`). Concrete machine representation types are `enum: LmxType` (primitives, Array descriptors, METHOD, Structure, pointers, arrays of pointers; bases `LMX_TYPE_POINTER_BASE` and `LMX_TYPE_ARRAY_OF_POINTER_BASE`). One half-open interval is `struct: LmxRange` (`lo`, `hi`, `array`), where `array` references an `LmxPool`; `stride`, `kind`, and `type` belong to that Array descriptor rather than being duplicated in every range. Address classification is the arena index: `lmx_range_classify`, `lmx_range_type_of`, `lmx_range_pool` in `lmx_arena.h.lm1`. Nothing is stored on a cell to “say what it is”. Qualified types, including the result of composing the `independent: const: immutable` receiving expressions, are recognized by the same typed-address-range membership mechanism. Range/address-domain identity carries the qualified type, while `kind`/`type` describe its physical representation; the chain gets no separate value flag, classifier, `LmxType` or `LMX_DOMAIN_KIND_*`. A sealed range remains in its explicit owner's ordinary arena; explicit retention and exclusion of that range from collection determine its lifetime, not a separate permanent store, and do not replace its type. L1: [L1](L1_spec_en.md#type-by-range).

Core mechanisms absent from closed `lmx.h` register **domains** as separate constants in `lmx_implements.h.lm1` (`LMX_DOMAIN_MSG_RECORD` … `LMX_DOMAIN_POST_RING`) without extending the Message record.

<a id="pool"></a>
## 4. Typed service array

`struct: LmxChunk` / `struct: LmxPool` in `lmx.h.lm1`; operations in `lmx_pool.h.lm1`. An array hands out cells of one `stride` and grows by **adding a chunk**, not `realloc`: live addresses never move. Each chunk is registered in the arena index as another interval of the same `(kind, type)`. Cells are not returned one by one; reuse is the owner's free list (as mail does). Interned immutable atoms (for example 256 character cells) need not grow. L1: [L1](L1_spec_en.md#pool).

<a id="method-array"></a>
## 5. METHOD and Array

Target form: there is no separate METHOD record — the C entry lies in the `Lmx.native` word ([§2](#lmx)), the signature is an ordinary graph field, and the `sig` word goes away with the record; graph copy carries `native` verbatim. Transitional implementation: `struct: LmxMethod` is `{addr, sig}`; `addr` is the C entry, `sig` is a dispatch contract, not a call contract at this stage. The record stores neither `parent` nor reserved source `node`; the concrete callable occurrence supplies the above-method reference. Graph copy keeps the METHOD pointer.

A standalone Array descriptor has type `VoidArray {size_t size, void *data}` without `parent`; the embedded `Lmx.array` has the same physical type. A separate `LmxArrayDesc` alias is unnecessary in the target ABI. For a standalone Array, `size` counts its elements and its backing contains exactly that many cells; for `Lmx.array` it counts child slots. The standalone Array descriptor and a Structure header occupy different typed arena ranges even though the embedded array has the same layout. Base Array has no `capacity`, `reserve`, `resize`, `append`, or grow, and does not switch or compact backing. Dynamic membership, capacity, and growth belong only to `Lmx<T>DynamicArray { Lmx<T>Array array; size_t capacity }` reusing the existing fixed descriptor of the real element type T (void/`LmxArrayDesc` only for `void *`; int uses `{len; int *data}`; char uses `LmxCharArray {size_t len; char *data}` — the string-literal descriptor with exact `len` and no NUL, also the chunk-cell descriptor; dynamic form `LmxCharDynamicArray`). List (`KIND_LIST`) is that public dynamic descriptor over `void *` — not capacity on the base descriptor and not a hidden backing prefix. Length belongs to array elements, not Structure fields ([semantics](LMX_semantics.en.md#values)). L1: [L1](L1_spec_en.md#method-array).

<a id="arena"></a>
## 6. Arena

`struct: LmxArena` in `lmx_arena.h.lm1`: owned block list, N arrays, address→descriptor index, GC generation, `simple` flag. The arena manager is the sole writer of the index. After type is determined once, cells are written directly: a cell address never changes. Every L3 Thread arena can contain typed Arrays by the same mechanism. When a Message or L3 Thread is created, its arena contains only data and physical references explicitly supplied by the creating operation. Process bootstrap may use the same ordinary mechanism to place permanent Arrays of immutable independent branches and METHOD records of the initial lexically fixed module in R0's arena and explicitly pass their references to its children. This is convenient because R0 owns the initial module and spawns them, not because a hidden root table, R0-only storage class, or automatically inherited environment exists. A later DLL-like module owns its own sealed typed ranges in its own arena; when `merge` encounters its `independent: const: immutable` value, it places the original physical reference in the result without copying it or changing its owner. Its unload operation and range lifetime are not yet defined. The common range index determines type; range-visibility bookkeeping remains internal to merge/classification rather than a separate semantic operation. There are no special numbered slots or supplementary identity indexes.

Principal operations: `lmx_arena_open` / `lmx_arena_open_simple`, `lmx_arena_take` / `take_n`, `lmx_arena_span`, `lmx_arena_attach` (join another arena without moving addresses), `lmx_arena_mark` / `lmx_arena_revert` (all-or-nothing for merge/copy), `lmx_arena_release`. Simple mode (`simple`): same index and address stability, no GC pass and no multi-chunk growth. Blocks are `LmxArenaBlock` in `lmx_arena_blocks.h.lm1`. Structure-slot references are `lmx_arena_refs`. L1: [L1](L1_spec_en.md#arena).

<a id="message"></a>
## 7. Message record

Closed record `struct: LmxMsg` contains exactly four fields:

| field | meaning |
| --- | --- |
| `running` | permission to continue; 0 inside a turn is a stop request, not completion |
| `success` | set by user code; `success = 1` is a sufficient condition for stopping the Thread at end turn; never reset to 0 by the system; set to 1 by the system only for a plain letter at its delivery |
| `handoff_ready` | mark that storage may be transferred without a copy |
| `graph` | C projection of the language root |

A Message's local identity is the physical address of its record. There is no parent-index field in Message; hierarchical index chains exist only at the WorldWideMix level and do not supplement a local physical reference. Flag type is `uint_fast8_t` (`type: LmxFlag`). Mail, scheduler, deadlines and family links are **not** fields of this record. The letter envelope is this record, not a wrapper around it. L1: [L1](L1_spec_en.md#message).

<a id="thread"></a>
## 8. L3 Thread

Not every Message is executed by an L3 Thread: a plain letter has no turn. An executable object is allocated as `LmxThread` from the beginning, and its first field is the closed Message record **by value**. The normal L2 layout is:

```yaml
struct: LmxThread
    LmxMsg: message
    @: LmxPost mail
    @: LmxSchedule slot
    ...
end: LmxThread
```

The addresses of the complete Thread and this first member are therefore physically equal (`@: thread == @: thread\message`). The equality establishes only the common Message prefix; it neither adds Thread fields to `LmxMsg` nor permits Thread-tail access through a standalone Message. Mail, turn state, local scheduling policy, execution mode, and the separate APIs remain Thread-only mechanisms. A standalone plain Message is an independent `LmxMsg` allocation and cannot be upgraded in place to a Thread.

Address-range classification remains exact and non-overlapping. A standalone record belongs to the exact Message range; a constructed Thread belongs to the exact Thread range. The generic semantic kind “Message” admits both a standalone Message and the Message prefix of a Thread, while an operation requiring Thread must establish the exact Thread type/range before accessing the tail. No second range is registered over the Thread prefix merely to repeat its Message kind. One active Thread executes its embedded Message; competing executors for one identity are forbidden. The parent's sole direct-child membership is a List (KIND_LIST) of physical references held in its graph. The parent's scheduler traverses that List; a separate `LmxLink` chain, manager membership queue, or other child registry is forbidden. Two separate APIs are used: `LmxThreadApi` and `LmxThreadMailApi`, not one merged heap. A whole turn is `lmx_thread_turn`. A Thread has no mode: each call's path is set by the callable occurrence's descriptor (`addr != 0` is a native entry, `addr = 0` runs the body's op tree through the interpreter; only L3 is interpreted). The dispatcher does not infer a path from an entry, METHOD, or body and does not switch to the other path after a failure. One call never runs both paths; during a turn a Message belongs to one OS thread, although it may move to another worker between turns. Interpreter entry does not copy the method or graph; its auxiliary frame may use reusable storage provided that entry cost remains comparable to native execution. L1: [L1](L1_spec_en.md#thread).

<a id="root-close"></a>
### 8.1. R0, its parent frame, and close cascade

R0 is an ordinary L3 Thread: every L3 Thread can perform the same operations by default, and R0 has no additional API, tables, scheduler, or child mechanism. R0 has a parent: the local frame above it occupies the place of one future parent element of WorldWideMix and is connected to R0 by the ordinary parent mechanism. This is a Message supervision relationship, not a lexical `Lmx.parent` link. The upper frame itself has no parent but gains no additional functions from that fact. On close, each level ordinarily requests stop only from its direct children in the sole graph List and waits for their safe completion; every child performs the same operation for the next level. A parent does not walk grandchildren, and no repeated external call is required to continue the cascade.

R0's parent, the host root, is built with the same mechanisms as every Thread (arena, `LmxPost`, turn, close); it is a "frame" only in that it has no parent -- its parent is a foreigner, the OS. The difference: R0 is the user's code with all its content, the host is the one that launches: all launch code (C `main`, the `mainArgs` letter, R0's turn, the close) lives in it, and R0 is created by the host as a child Thread through the ordinary child mechanism ([§12](#child)) with a result cell in the host's graph. At creation the host hands R0 its eternal `independent: const: immutable` profile (platform settings -- e.g. the process working directory as an `LmxCharArray`) by shared physical reference under the eternal-branch rule ([§13](#copy-merge)); R0 itself is platform-independent. The process exit code comes from the host: if R0 sent the letter `exit(exit_code; stdout; stderr)` (admitted against the model by position), the host returns its code and texts; otherwise the host reads R0's `success` flag and returns the OS mapping (1 -> 0, 0 -> 1), writing the reasons to stdout/stderr; with `success = 0` the host prints to stderr the failed R0's graph from the retained result cell and the adopted arenas. The root's last-expression value is an internal activation value, not the exit code.

A separate host watchdog observes an overall timeout for completion of the entire subtree. It is neither a function nor state of the upper frame, not R0's liveness deadline, and not a replacement for descendants' individual deadlines. If the ordinary cascade has not returned by that deadline, a partially closed runtime is not a normal result: the host terminates the OS process, after which the OS reclaims process resources. The existing Java WorldWideMix model is not ported as a parallel host model; its later port must be rewritten through the Message mechanism. L1: [L1](L1_spec_en.md#root-close).

<a id="mailbox"></a>
## 9. Mailbox

Each L3 Thread owns its `LmxPost` and mail API. The language mail wrapper (the first wrapper over the kernel; the Erlang analogue): `sendMessage: X` sends the letter `X` to the current Message's parent, `sendMessage: Ref X` to the Message referenced by `Ref` (told apart by the field's type); the letter is an anonymous Structure `(sender; X)`: the wrapper puts a reference to the sending Message first and the payload Structure second; `receiveMessage: m` takes the first letter in admission order (the former `nextMessage`), `receiveMessage: m Model` iterates the mailbox and takes the first letter whose payload passes `implements(Model)`, leaving the others in order. Transport: a letter goes to `staged`, is published to `outbox` at a successful turn boundary and moved into the addressee's `inbox` (the outbox item carries the addressee's mailbox); a failed turn sends nothing. A delivery/address service explicitly supplied by the parent only resolves a target and hands a letter to the destination mailbox's admission operation: it neither observes nor reads the mailbox, schedules recipient turns, nor maintains its membership registry.

The core's only synchronized collection is the mailbox `inbox` (`lmx_post.h.lm1`). One simplified Java-style monitor belongs to `LmxPost` itself and covers admission, take, and count on the incoming queue. The monitor permits same-OS-thread re-entry and provides enter/leave only: there is no wait set, `wait`, or `notify`. The lock does not escape into the address service, scheduler, graph, arena, or turn; `outbox` and `staged` remain owner-local. It also does not cover the Message-inherited `running`, `success`, and `handoff_ready` flags: their atomic operations and permitted writers are unchanged by mail synchronization.

Three lanes: `inbox` (admitted, not yet taken), `outbox` (published by a successful end-turn), `staged` (current turn's preparation; others must not see it). Inbox is a **ring** held as a DynamicArray of its pair-record element type plus `head`/`tail`. Capacity lives only on that `*DynamicArray` field — never on base Array / `LmxArrayDesc`, and the mailbox does not treat capacity as a base-Array property. Initial capacity is two entries; when full, it grows by approximately `3/2` (`2, 3, 4, 6, 9, …`). Each incoming entry is the inseparable pair `[target, source_arena]`. A producer publishes that pair under the mailbox monitor without mutating the receiver arena. The receiver owner attaches `source_arena` before exposing `target`; refusal leaves the exact pair queued. Growth copies unread pairs in FIFO order, then replaces the private backing. The backing address is not a graph value, is never published, and is not classified as an LMX type. GC obtains a monitor-consistent snapshot of unread targets through the mail module and never reads the backing directly. Allocation refusal or size overflow answers `LMX_POST_FULL` without damaging the old ring. Capacity check, growth, slot reservation, publication, take, and count update are serialized critical sections, so two producers cannot receive the same `inbox_tail`. The current collection deliberately uses simple `synchronized`; a lock-free MPSC ring belongs to a separate future mail implementation. `init` and `close` require quiescence: no OS thread is in `accept`/`take`/`count` or starts one before the operation completes. Close releases pending donor arenas one by one and fails closed before losing an entry it cannot release. During child settlement, mailbox close precedes route unregistration, removal from the parent's children List, and arena release or attachment; refusal therefore leaves membership and ownership reachable for retry. Outgoing and staged are lists of `LmxPostLink` (target address + next) from the box's pool. `LmxPostLink` is not an envelope. FIFO is admission order under the monitor. L1: [L1](L1_spec_en.md#mailbox).

<a id="own"></a>
## 10. Execution pair: code and data

An execution consists of exactly two Structure roots: the Structure placed in the position of the executable graph (code) and the Structure supplied to it as the data graph. `code` and `data` are roles in one execution, not kinds, qualifiers, storage classes, or persistent properties of a Structure: in `f(a b)` `f` is code and `(a b)` is data; the same `f` in `merge: f other` or `send: f` is data. The language has no words for the roles: computed code is first bound (`someCode: selectCode(…)`), then `someCode(someData)` resolves by the general [call](#call) rule; no separate `execute` receiver is introduced. Code is immutable during execution: the descriptor `child[0]`, the argument and result parts, the body of operators with literals at the leaves. Data is an ordinary Structure: the declared fields of the body in lexical order, nested bodies as nested field-only Structures (`M\for\y` is the same path), data holds no operators; formal arguments, locals, and the returned value belong to the ordinary machine activation, and an argument becomes a data field only by the assignment rule ([L3 §12](LMX_semantics.en.md#dynamic)) or by binding through merge. A body declaration `int: i 5` is field `i` of the data prototype plus a code operator writing 5 into slot `i` of the passed data; a repeated declaration of a name is the next field, while a repeated bare assignment to the same name writes into the same cell and is not an occurrence. Execution writes only into the passed data, never into code. One graph may stand in both positions: an ordinary call runs the callable occurrence over its own fields (M, M), and the file root runs the same way; execution never writes operator nodes, literals, or the `native` word, only declared fields. Activation: a call passes the actual arguments to the machine activation (a bound formal takes its value from data) and runs the code over the data; a fresh instance of the data prototype is created only on re-entry (recursion, a dynamic call) or when data is passed explicitly, lives in the frame, and is not visible from outside; `Model: fresh` is such a prototype instance. `node` is the parent's data: `node\x = data\parent\x`, a static chain along the `parent` links of the data graph; there is no third environment graph. The parent's slot holds `M` itself: the path `M\x` from outside reads the fields of the latest activation over its own graph; re-entrant instances are not visible through the slot, and results are not read through it; one Structure passed to two activations is shared by them. There are no working copies, no `dirty`, no load on entry, and no publication at a checkpoint: where a write lands is determined by the Structure that was passed. Arguments, locals, and the activation result belong to the ordinary machine activation: `fn` returns a value, `fm` a reference to its result Structure; `return` is a code operator, and data has no result field. The L2 expression `@x` for a data field yields the address of its cell in the instance; the cell is stable for the instance's lifetime, with no sticky marks and no retargeting. Merging a callable: the signature is derived (a bound formal leaves it), bound fields merge pairwise into the model's data slots ([§13](#copy-merge)), and the machine body is one, the code of the last operand with a body. This is an L2 machine rule; the same-spelled L3 reference-declaration receiver is defined separately in [L3 §11](LMX_semantics.en.md#dynamic). L1: [L1](L1_spec_en.md#own) — the transitional implementation (`lmx_own`, `lmx_dirty`).

<a id="call"></a>
## 11. Call

`lmx_call.h.lm1`: in the target form the execution of a Structure in head position is selected by the `Lmx.native` word ([§2](#lmx)): non-null enters the native entry, null runs the walker; in the transitional implementation callability is determined by the address range of the stored `child[0]` value. The new Callable path passes two physical references of the execution pair ([§10](#own)) to a native entry: reserved `node`, the lexical parent's data (`data\parent`, the above-method space), and hidden `self`, this activation's data instance; `self` is not a language word. Transitional direct METHOD keeps the old one-argument entry only for legacy low-level targets. This stage performs **no** signature check (as in C; full typing is separate), and `sig` is not decoded. L1: [L1](L1_spec_en.md#call).

<a id="child"></a>
## 12. Child reservation

A child is built in **its own** arena; publication appends its physical reference to the direct-child List (`KIND_LIST`) in the parent's graph **at the end of the parent's turn**. There is no fixed position or predetermined membership size. Until publication, nobody else executes inbound work. Parent failure drops reservations without rolling back graph writes already done. A reservation lives in the parent's arena. Storage handoff attaches the child's arena to the parent only when `handoff_ready`. L1: [L1](L1_spec_en.md#child).

<a id="copy-merge"></a>
## 13. Graph copy and merge

Modules `lmx_graph_copy_owned` and `lmx_merge_owned`. Traversal matches Message creation: the complete used closure is copied, while `parent` and other references are rewritten through one source-to-copy map; METHOD pointers are retained. The first operand is the model: a field of a later operand/body that matches a model field (the match and admission are resolved by the translator; the kernel receives position pairs) is written into the model's slot, the rest are appended at the end; the model's layout does not shift and methods carry no hidden offset ([semantics](LMX_semantics.en.md#composition)). Merging callables proceeds part by part over `args`/`return`/`body` (every Structure is a `body`; a missing part is empty), recursively, later operands merging inward (a method into a Structure becomes a nested field; a Structure into a method becomes fields of its body); the operand's nameless body statements replace the model's; converting a Structure to a declared callable type is one more merge with the method as the model (`merge(m; fields; header)`; returning a nested method is one such merge with three operands); the result's `child[0]` is a new `LmxCallable` with `addr = 0` (the walker runs the op tree), the operand's ops are renumbered by the position map, a native entry is never merged. A reference to a method occurrence of an enclosing Structure is a shared terminal (not copied, `parent` not rewritten); an occurrence declared inside an operand's body is copied with it and keeps its field indices. When `merge` encounters an `independent: const: immutable` value, it **does not copy** the branch: it places the original physical reference in the result, preserving identity and the source module as owner. This is a terminal of the common traversal, not another construction mechanism.

The contextual `left: right` rule is defined in [L3 §8](LMX_semantics.en.md#construction). If `right` does not exist, `left` must be a type/model operation: `right` is declared and its value is created by a full `merge(left, empty)`. An unqualified `left` is selected dynamically before lexical fallback; when a particular lexical object is required, the program writes `node\left`, where reserved `node` is literally the supplied `Lmx *node`. The result has the composition of a copy of `left` because the second operand is empty, but the full traversal is not shortened to pointer copying. If `right` exists, it is the candidate for an already typed mutable target `left`. For the assignment role, translation must resolve `left`'s mutable type from an explicit or hidden argument/binding and resolve the RHS as a typed value or literal; otherwise it creates no target own field and selects another already defined colon role or reports an error. Full `implements(right, left, Consumer)`, including the receiving expression's mandatory tests, runs first; only success permits assigning the `right` reference to `left`. This assignment is not `merge`, does not copy the branch, and does not change ownership. An absent/untyped target, `const left`, an unknown RHS, or failed admission leaves both the target and its `dirty` state unchanged. Resolution needs no runtime name table. Failure of `merge` itself reverts through an arena mark ([§6](#arena)) without publishing a partial graph. L1 receives already resolved, unambiguous operations: [L1](L1_spec_en.md#copy-merge).

<a id="implements"></a>
## 14. `implements`

L2 supports the [L3 admission mechanism](LMX_semantics.en.md#admission): analytical checking of the tree's used named paths and execution of the receiving expression's unit tests by the graph interpreter. Physical address classification remains a separate value-representation operation.

<a id="gc"></a>
## 15. Collection

`lmx_gc.h.lm1` / `lmx_gc.lm1`. Generation on the arena; a chunk is marked by generation compare. Roots are the Message record, object, mail and its nodes/ring, current scheduling state, and the live graph including the sole direct-child List. There is no separate child chain or membership queue among the roots. Explicitly retained initial typed ranges in R0's arena have process lifetime because R0 owns the initial module, without an R0-only capability. Collection or unload rules for a later module's ranges are not yet defined. Simple arena mode refuses collection. L1: [L1](L1_spec_en.md#gc).

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
| raw index / C storage | Machine access through the `c.*` door | [Arrays](#lowlevel-array) | [Emitter](L1_spec_en.md#lowlevel-array) |
| `cast`, `c.*` | C cast; raw C (including C `sizeof` / `c.name`) | [ABI](#lowlevel-abi) | [C99](L1_spec_en.md#lowlevel-abi) |
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

The already-reference-valued nature of a nonprimitive value is essential. `Model: fresh` constructs a new Structure, but binding `fresh` contains the physical reference to its descriptor/occurrence; Structure assignment, argument passing, and return copy that reference rather than passing the Structure by value. Thus `@: Model slot` means the address of a machine slot that stores a `Model` reference, not “a reference to a Structure instead of constructing it.” In a C99 projection ordinary `fresh` is already conceptually `Lmx *`, while `@fresh` is `Lmx **`. A new Structure uses full construction; ordinary assignment to an already typed target rebinds its Structure reference after admission; `@` adds one machine address level and substitutes for neither operation.

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

An argument has a distinct same-name own-binding rule: a resolved bare assignment to an already typed explicit or hidden argument makes translation prepare the current body's field. Executing that statement associates the same local variable with the field for subsequent dirty publication. Its address and lifetime remain those of the parameter; the previous graph value is not loaded over the input, while the argument source and parent remain unchanged. Evaluating the L2 expression `@x` for any addressable activation-local unconditionally makes that local sticky through activation end, whether before the first occurrence binding, between occurrence bindings, or after the current binding. `@x` returns the stable canonical physical local cell and never retargets; `p` always addresses canonical. Address-taking invents no graph field: without an executed occurrence there is no publication destination and no graph dirty state. Once an active target exists, a checkpoint snapshots canonical into the current occurrence and never clears sticky. Address-taking after binding is sticky. The canonical cell, the active publication target, and graph field-follow `test\arg` / `[0]arg` are distinct. The rule is identical for every type with valid assignment and does not apply to explicit graph paths, array elements, or taking the address of a graph field's classified payload. This permits neither addressing a temporary copy nor retaining an activation-local address after exit. Body hierarchy and execution of the binding assignment are specified in [L3](LMX_semantics.en.md#dynamic), but address-of and sticky remain L2 mechanisms.

`\p` loads through a typed address; `\p: value` stores there when permitted. `p\field` follows either an explicitly imported machine ABI field or an ordinary structural path, depending on p's category. These cannot be conflated as universal `->`: a Structure uses the graph, while raw ABI access uses known layout. L2 indexing checks no bounds, for either raw addresses or graph-backed Arrays. Array index and descriptor validation belong to L3. Reading a descriptor to obtain backing is not descriptor validation. Field and index chains bind more tightly than prefix `@` and `\`.

`*` is not source dereference, `&` is not address-of, `^` is not field-follow, and `.`/`->` are not ordinary L2 field access. `*`, `&`, `^` may have distinct arithmetic/bitwise roles. By-value C aggregate access uses an explicit C form such as `c.value.field`, not a redefinition of graph paths.

Writing through an address neither removes `const`/`immutable`, admits a dangling address nor establishes automatic ownership. Receiving-expression admission uses the [unified mechanism](#implements); physical classification uses the [arena index](#type-by-range).

<a id="lowlevel-array"></a>
## 19. Raw C storage

The `c.*` prefix is the raw door into C, and classification is by token: every token spelled `c.*` is a raw C name, while every non-`c.*` argument inside the construct remains an ordinary L2 expression. No concrete C name has meaning to L2. L2 does not define a separate language entity `c.array`: rectangular machine storage and raw index, when needed, are expressed through that door and L1 C99 lowering.

Ordinary L2 Array remains a descriptor reference `VoidArray {size, data}` with graph backing; its length is `size` / length operations, not a machine C size. Mapping raw C storage to an ordinary Array requires an explicit operation over backing address, shape and lifetime.

Index expressions and the absence of L2 bounds checks for machine access remain in [§18](#lowlevel-address) and [§21](#lowlevel-expression).

<a id="lowlevel-abi"></a>
## 20. Foreign types, conversions and calls

`cast: (T) value` is a machine cast, not an [L3 numeric converter](LMX_semantics.en.md#descriptions) or proof of range/lifetime safety. Machine type/object size, when needed as raw C, is expressed through the `c.*` door (for example `c.sizeof(...)`) and means C `sizeof`, not a Structure field count and not Array length. An opaque type can be stored and passed without exposing its fields; raw access requires a known ABI.

The `c.` prefix is the raw door into C: explicit access to a C symbol. The door does not maintain a declaration registry of C names as language norm and does not declare a foreign-entity-kind behind the door.

`c.name` selects a foreign C symbol. An ordinary L2 function requires no `c.`. Parameters, result, ownership and resource release belong to the adapter contract. Permitting a C call does not wrap its result in a graph or make a pointer a portable Message. In the descriptive contract, `external` wraps one `fn`/`sub` and requests a foreign entry; the adapter preserves the source method contract.

`include` supplies explicit headers, retaining specified `<…>`/quotes; an undelimited path becomes local. `os` selects a written platform branch without changing repeated graph-field order. At unit level, the `predef`/"import" form only resolves explicitly selected dependencies to physical references, without directory scans or eager construction of every Structure. It is not a separate runtime composition semantic: graph construction follows `merge` rules, including the conceptually equivalent constructor lowering in [§13](#copy-merge).

<a id="lowlevel-expression"></a>
## 21. Machine expressions and updates

The minimal profile includes grouping; prefix `@`, `\`, `++`, `--`, `+`, `-`, `!`, `~`; postfix `++`/`--`; arithmetic `+ - * / %`; comparisons `= != < <= > >=`; logical `&& ||`; and bitwise `& | ^`. Here `=` compares, while `target: value` writes. Overflow, shifts, division, rounding and conversions depend on the selected machine profile; unconditional checked L3 arithmetic must not be attributed to them.

`target[index]` consumes an index expression. It is not a repeated-field qualifier `target\[index]field` or the constructor head `[]:`. Target category determines how data are located without adding L2 bounds checks. Checked Array operations belong to L3; L2 provides machine access to the selected cell. Assignment neither appends a repeated field nor creates a namespace.

In an executable body, headless `2`, `f`, `2 + 2`, `(f)`, `(2 + 2)`, and empty `()` are valid ordinary expressions or anonymous Structures. A bounded anonymous Structure and the corresponding vertical body are consumed in field order by one mechanism; named Frames and headless expressions within them are not lost. An expression without a destination is evaluated and its result discarded. Bare `f` invokes nullarily only if it resolves to a callable; a non-callable value is evaluated without invocation. No spelling infers a type from a literal or changes the general declaration, assignment, call, or admission rules.

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
