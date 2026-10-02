# L2 specification

L2 is LMX with special low-level operations. This specification defines those operations and the kernel model. Pure hermetic LMX (L3) semantics are in the [main specification](LMX_semantics.en.md); grammar is in the [grammar specification](LMX_grammar.en.md); lowering of the same mechanisms through L1 and C99 is in the [L1 specification](L1_spec_en.md). Implementation state, source snapshots, and migration work are kept in the [implementation notes](implementation-notes.en.md).

Both descriptions define one mechanism at their respective levels; the primary definition is here or in L1 and the paired document links it.

<a id="scope"></a>
## 1. Scope

L2 is the language of kernel mechanisms: `Lmx` structures, the arena's typed arrays, Message, mail, an L3 Thread turn, graph copy, and call. Its lowering chain is L2 → L1 → C99, as defined in [semantics](LMX_semantics.en.md#scope).

L2 defines machine mechanisms and L3 defines high-level programs. Generated intermediate L1 is a lowering stage, not the program's source graph. The interpreter consumes only the [L3 graph](LMX_semantics.en.md#l3-receiver), not L2 operations. L3 is compiled by the same rules as L2; a constructed L3 graph *may* be executed by the interpreter, L2 operations may not. The root body of a `.lm2` file is an L3 Structure; a body with an empty `native` word is interpreted, and the interpreter executes only L3, so an L2 operation is absent there; any Structure may have a native implementation; a Thread has no execution mode -- dispatch follows the Structure's `Lmx.native` word (non-null enters native code, null walks the retained operator body); the value of an activation/file is its last evaluated expression. L3 is a subset of L2: a named and an anonymous Structure always belong to level L3, L2 operations are absent from an interpreted body because the interpreter executes only L3; a compiled body may contain them, and `@` in L3 also obtains a reference to resolved value data without machine address arithmetic ([semantics](LMX_semantics.en.md#scope)).

<a id="lmx"></a>
## 2. `Lmx` structure

The normative physical node record and its array of child references are:

```c
typedef struct { size_t size; void *data; } VoidArray;
typedef struct Lmx { VoidArray array; struct Lmx *parent; LmxEntry native; } Lmx;
```

`array` is first and embedded by value: `&node->array` has the same address as `node`, but range classification still treats the `Lmx` allocation as a Structure (`LMX_KIND_STRUCT`), not a standalone Array descriptor (`LMX_KIND_ARRAY`). It is the node's **actual array of immediate physical child references**, not an auxiliary C wrapper. `array.size` counts its `void *` slots, not bytes or capacity; `array.data` points to their backing. The arena registers that backing as a child-reference storage range (`LMX_KIND_CHILDREN`), not another Array descriptor. `VoidArray` itself does not replace an `LmxRange` index entry: the index classifies backing addresses and their stored referent values separately. `parent` is the immediately enclosing working-graph Structure, null at a root. `native` is the direct reference to the native implementation of this Structure's body (the C entry), null when there is none; it is not a lexical element and not a graph field, so it lies in the record after `parent`, not among the child slots, and graph copy carries the word verbatim. `Lmx` has three direct C members, with no tag or growth field. The L1 projection is defined in [L1 §3](L1_spec_en.md#lmx).

Containment is a tree: every node but the root has one `parent`, following `parent` reaches one root and never forms a cycle. References stored as data may point outside the subtree, so memory as a whole is a graph with shared referents and cycles ([L3 §2](LMX_semantics.en.md#values)); those edges do not change the `parent` relation. An Array is not this graph: a descriptor plus a rectangle of elements. A child has no type tag. The type of a value is the address range that contains the **stored child value**, not the slot address. Slots of an ordinary Structure are not added or removed after construction; the dynamic membership of direct child Messages is a separate List (`KIND_LIST`) value in the graph, not a base Array and not a preallocated group of Structure slots. A Structure in code position is an ordinary Structure with no special slot: its signature is an ordinary lexical graph field, and its native implementation is the `native` word, which selects execution (non-null enters C, null runs the walker over the body operators, [§10](#own)); `M.parent` points into the lexical space above the method. At entry the reserved language argument `node` is `M.parent`, not `M` itself, and stays fixed throughout the activation. Every `if` body, loop and other nested Structure has its own immediate `parent`, but that internal chain does not rebind `node`. `parent` is not a reserved language word. The Callable ABI additionally passes hidden `self`, the executing Structure occurrence ([§10](#own)); this is neither a source name nor a second form of `node`. The native-entry word is the only native-versus-interpreted dispatch selector. L1 implementation: [L1](L1_spec_en.md#lmx).

<a id="interpretable-tree"></a>
### 2.1. Storage of the interpretable tree

The interpretable tree is the program graph itself, not a separate copy encoded as instructions. Source determines containment, field composition and order: declarations, values, applications, expressions and nested bodies retain their positions. Native lowering may optimize execution but must not remove or reorder the contents of this tree. Building the tree does not execute its described actions. There is no separate persistent data graph or auxiliary execution graph.

A uniform graph model does not require every element to have the same physical representation. A Structure stores an ordered array of physical references; an atom is represented by its existing typed arena cell. Its address identifies the cell, and the [address range](#type-by-range) establishes its type. Referencing that cell does not require a leaf object, a Structure wrapper, a value copy or a record repeating its address, type and name. Several uses of one cell may occupy distinct child-array positions referring to the same cell: the positions preserve occurrences without allocating an object for each use. This neither merges distinct declarations nor changes occurrence selection.

**Source-entity names are not stored anywhere in the graph**: not on atoms, Structures, fields, methods or applications. They are reconstructed from the separate address-to-source-name table defined in [L3 §4](LMX_semantics.en.md#fields). The table supports source reconstruction and inspection; execution follows resolved references and positions rather than looking up values by name strings. No name or spell member is added to base records or occurrences. Anonymous elements receive no invented names.

Comments are retained in full, together with their placement in the source structure. They carry independent content and are not executable operations: ordinary execution neither parses nor processes their text. Retaining comments does not put comment processing on the value-access or call-dispatch path. Native compilation neither abbreviates nor removes them.

`toLmx` reconstructs source code from the retained tree, name table and comments. For a tree constructed from source, the returned notation differs only in canonical formatting under the grammar's equivalent forms. Source constructs and their order, names and full comment text are not replaced with a summary, decompilation of machine code or walker protocol records. The name table does not replace the tree; a saved source string or second AST does not replace the graph. The general textual representation contract is [L3 §21](LMX_semantics.en.md#source-codec).

Working values and formal bindings belong to the [current activation](#own). If execution uses a working copy of a value, the activation mechanism resolves the correspondence between the existing address and that working value; this does not justify a persistent description of each atom use in the graph. The actual cell address, the address of a slot holding a reference and the working value are not identified with one another. The L1 storage projection is [L1 §3](L1_spec_en.md#interpretable-tree).

<a id="type-by-range"></a>
## 3. Type by address range

All ordinary Structure records have one physical type, `Lmx`, and are allocated from the arena's typed service array of that type. Chunks and arenas may provide several physical intervals of the same type; these are not distinct types named after each model. No dedicated typed array of length 1 is created for each Structure. Its child-reference backing is separate storage and does not change the type of the `Lmx` record itself. Differences between the composition of `A` and `B` are checked by structural `implements`, while the conversion table relates primitive values ([L3 §5](LMX_semantics.en.md#descriptions)). The shared physical type does not remove separately defined qualified domains.

Coarse kinds are `enum: LmxKind` (`NONE`, `PRIMITIVE`, `ARRAY`, `CHILDREN`, `REF`, `STRUCT`, `LIST`). Concrete machine representation types are `enum: LmxType` (primitives, Array descriptors, Structure, pointers, arrays of pointers; bases `LMX_TYPE_POINTER_BASE` and `LMX_TYPE_ARRAY_OF_POINTER_BASE`). One half-open interval is `struct: LmxRange` (`lo`, `hi`, `array`, `owner`), where `array` references an `LmxPool` and `owner` identifies the storage-owning arena; `stride`, `kind`, and `type` belong to that Array descriptor rather than being duplicated in every range. Address classification is the arena index: `lmx_range_classify`, `lmx_range_type_of`, `lmx_range_pool` in `lmx_arena.h.lm1`. Nothing is stored on a cell to “say what it is”. Qualified types, including the result of composing the `independent: const: immutable` receiving expressions, are recognized by the same typed-address-range membership mechanism. Range/address-domain identity carries the qualified type, while `kind`/`type` describe its physical representation; the chain gets no separate value flag, classifier, `LmxType` or `LMX_DOMAIN_KIND_*`. A sealed range remains in its explicit owner's ordinary arena; explicit retention and exclusion of that range from collection determine its lifetime, not a separate permanent store, and do not replace its type. L1: [L1](L1_spec_en.md#type-by-range).

Core mechanisms absent from closed `lmx.h` register **domains** as separate constants in `lmx_implements.h.lm1` (`LMX_DOMAIN_MSG_RECORD` … `LMX_DOMAIN_POST_RING`) without extending the Message record.

<a id="pool"></a>
## 4. Typed service array

`struct: LmxChunk` / `struct: LmxPool` in `lmx.h.lm1`; operations in `lmx_pool.h.lm1`. An array hands out cells of one `stride` and grows by **adding a chunk**, not `realloc`: live addresses never move. Each chunk is registered in the arena index as another interval of the same `(kind, type)`. Cells are not returned one by one; reuse is the owner's free list (as mail does). Interned immutable atoms (for example 256 character cells) need not grow. L1: [L1](L1_spec_en.md#pool).

<a id="method-array"></a>
## 5. Native entry and Array

There is no separate METHOD record: the native entry lies in `Lmx.native` ([§2](#lmx)), and a method's args and return parts are ordinary graph fields. There is no separate `sig` word or method-descriptor address domain. The concrete callable occurrence supplies its lexical parent and active `self`; graph copy carries its `native` word verbatim.

A standalone Array descriptor has type `VoidArray {size_t size, void *data}` without `parent`; the embedded `Lmx.array` has the same physical type. The ABI has no separate `LmxArrayDesc` alias. For a standalone Array, `size` counts its elements and its backing contains exactly that many cells; for `Lmx.array` it counts child slots. The standalone Array descriptor and a Structure header occupy different typed arena ranges even though the embedded array has the same layout. Base Array has no `capacity`, `reserve`, `resize`, `append`, or grow, and does not switch or compact backing. Dynamic membership, capacity, and growth belong only to `Lmx<T>DynamicArray { Lmx<T>Array array; size_t capacity }` reusing the existing fixed descriptor of the real element type T (void/`VoidArray` only for `void *`; int uses `{len; int *data}`; char uses `LmxCharArray {size_t len; char *data}` — the string-literal descriptor with exact `len` and no NUL, also the chunk-cell descriptor; dynamic form `LmxCharDynamicArray`). List (`KIND_LIST`) is that public dynamic descriptor over `void *` — not capacity on the base descriptor and not a hidden backing prefix. Length belongs to array elements, not Structure fields ([semantics](LMX_semantics.en.md#values)). L1: [L1](L1_spec_en.md#method-array).

`[]:` participates in general receiving-expression nesting `a: b: c: ...`, without its own Array-chain parser or a fixed depth limit ([values](LMX_semantics.en.md#values)). An Array may hold references to other independent Arrays; this does not constitute a special Array kind. `length` takes an Array value and reads its descriptor, independently of the element type and the operand's expression shape. Access through several Arrays uses ordinary intermediate bindings: `[]: []: b a[i]`, then `[]: c: b[j]`. C-like `[][][]` for a flat rectangular Array is a different construct, not this composition; no extra dimension table is added to the descriptor.

<a id="arena"></a>
## 6. Arena

`struct: LmxArena` in `lmx_arena.h.lm1`: owned block list, N arrays, address→descriptor index, GC generation, `simple` flag. The arena manager is the sole writer of the index. After type is determined once, cells are written directly: a cell address never changes. Every L3 Thread arena can contain typed Arrays by the same mechanism. When a Message or L3 Thread is created, its arena contains only data and physical references explicitly supplied by the creating operation. Process bootstrap may use the same ordinary mechanism to place permanent Arrays of immutable independent branches of the initial lexically fixed module in R0's arena and explicitly pass their references to its children. This is convenient because R0 owns the initial module and spawns them, not because a hidden root table, R0-only storage class, or automatically inherited environment exists. A later DLL-like module owns its own sealed typed ranges in its own arena; when `merge` encounters its `independent: const: immutable` value, it places the original physical reference in the result without copying it or changing its owner. Its unload operation and range lifetime are not yet defined. The common range index determines type; range-visibility bookkeeping remains internal to merge/classification rather than a separate semantic operation. There are no special numbered slots or supplementary identity indexes.

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

The addresses of the complete Thread and this first member are therefore physically equal. The equality establishes only the common Message prefix; it neither adds Thread fields to `LmxMsg` nor permits Thread-tail access through a standalone Message. Mail, turn state, local scheduling policy and the separate APIs remain Thread-only mechanisms. A standalone plain Message is an independent `LmxMsg` allocation and cannot be upgraded in place to a Thread.

Address-range classification remains exact and non-overlapping. A standalone record belongs to the exact Message range; a constructed Thread belongs to the exact Thread range. The generic semantic kind “Message” admits both a standalone Message and the Message prefix of a Thread, while an operation requiring Thread must establish the exact Thread type/range before accessing the tail. No second range is registered over the Thread prefix merely to repeat its Message kind. One active Thread executes its embedded Message; competing executors for one identity are forbidden. The parent's sole direct-child membership is a List (KIND_LIST) of physical references held in its graph. The parent's scheduler traverses that List; a separate `LmxLink` chain, manager membership queue, or other child registry is forbidden. Two separate APIs are used: `LmxThreadApi` and `LmxThreadMailApi`, not one merged heap. A whole turn is `lmx_thread_turn`. A Thread has no mode: each call's path is set by the callable occurrence's `Lmx.native` word (`native != 0` is a native entry, `native = 0` runs the body's op tree through the interpreter; only L3 is interpreted). The dispatcher does not infer a path from a source name, position, or body shape and does not switch to the other path after a failure. One call never runs both paths; during a turn a Message belongs to one OS thread, although it may move to another worker between turns. Interpreter entry does not copy the method or graph; its auxiliary frame may use reusable storage provided that entry cost remains comparable to native execution. L1: [L1](L1_spec_en.md#thread).

<a id="root-close"></a>
### 8.1. R0, its parent frame, and close cascade

R0 is an ordinary L3 Thread: every L3 Thread can perform the same operations by default, and R0 has no additional API, tables, scheduler, or child mechanism. R0 has a parent: the local frame above it occupies the place of one future parent element of WorldWideMix and is connected to R0 by the ordinary parent mechanism. This is a Message supervision relationship, not a lexical `Lmx.parent` link. The upper frame itself has no parent but gains no additional functions from that fact. On close, each level ordinarily requests stop only from its direct children in the sole graph List and waits for their safe completion; every child performs the same operation for the next level. A parent does not walk grandchildren, and no repeated external call is required to continue the cascade.

R0's parent, the host root, is built with the same mechanisms as every Thread (arena, `LmxPost`, turn, close); it is a "frame" only in that it has no parent -- its parent is a foreigner, the OS. The difference: R0 is the user's code with all its content, the host is the one that launches: all launch code (C `main`, the `mainArgs` letter, R0's turn, the close) lives in it, and R0 is created by the host as a child Thread through the ordinary child mechanism ([§12](#child)) with a result cell in the host's graph. At creation the host hands R0 its eternal `independent: const: immutable` profile (platform settings -- e.g. the process working directory as an `LmxCharArray`) by shared physical reference under the eternal-branch rule ([§13](#copy-merge)); R0 itself is platform-independent. The process exit code comes from the host: if R0 sent the letter `exit(exit_code; stdout; stderr)` (admitted against the model by position), the host returns its code and texts; otherwise the host reads R0's `success` flag and returns the OS mapping (1 -> 0, 0 -> 1), writing the reasons to stdout/stderr; with `success = 0` the host prints to stderr the failed R0's graph from the retained result cell and the adopted arenas. The root's last-expression value is an internal activation value, not the exit code.

A separate host watchdog observes an overall timeout for completion of the entire subtree. It is neither a function nor state of the upper frame, not R0's liveness deadline, and not a replacement for descendants' individual deadlines. If the ordinary cascade has not returned by that deadline, a partially closed runtime is not a normal result: the host terminates the OS process, after which the OS reclaims process resources. The existing Java WorldWideMix model is not ported as a parallel host model; its later port must be rewritten through the Message mechanism. L1: [L1](L1_spec_en.md#root-close).

<a id="mailbox"></a>
## 9. Mailbox

Each L3 Thread owns its `LmxPost` and mail API. The language mail wrapper (the first wrapper over the kernel; the Erlang analogue): `sendMessage: X` sends the letter `X` to the current Message's parent, `sendMessage: Ref X` to the Message referenced by `Ref` (told apart by the field's type); the letter is an anonymous Structure `(sender; X)`: the wrapper puts a reference to the sending Message first and the payload Structure second; `receiveMessage: m` takes the first letter in admission order (the former `nextMessage`), `receiveMessage: m Model` iterates the mailbox and takes the first letter whose payload passes `implements(Model)`, leaving the others in order. Transport: a letter goes to `staged`, is published to `outbox` at a successful turn boundary and moved into the addressee's `inbox` (the outbox item carries the addressee's mailbox); a failed turn sends nothing. A delivery/address service explicitly supplied by the parent only resolves a target and hands a letter to the destination mailbox's admission operation: it neither observes nor reads the mailbox, schedules recipient turns, nor maintains its membership registry.

`post` carries an ordinary LMX call over this same mail. Only the transport changes: call resolution, `implements`, and the result stay ordinary. `answer` fills the sender's pending-reply table and does not publish methods. The Thread graph does not become an exported-method dictionary. The norm is [L3 §28](LMX_semantics.en.md#thread-message-api).

The core's only synchronized collection is the mailbox `inbox` (`lmx_post.h.lm1`). One simplified Java-style monitor belongs to `LmxPost` itself and covers admission, take, and count on the incoming queue. The monitor permits same-OS-thread re-entry and provides enter/leave only: there is no wait set, `wait`, or `notify`. The lock does not escape into the address service, scheduler, graph, arena, or turn; `outbox` and `staged` remain owner-local. It also does not cover the Message-inherited `running`, `success`, and `handoff_ready` flags: their atomic operations and permitted writers are unchanged by mail synchronization.

Three lanes: `inbox` (admitted, not yet taken), `outbox` (published by a successful end-turn), `staged` (current turn's preparation; others must not see it). Inbox is a **ring** held as a DynamicArray of its pair-record element type plus `head`/`tail`. Capacity lives only on that `*DynamicArray` field — never on base Array / `VoidArray`, and the mailbox does not treat capacity as a base-Array property. Initial capacity is two entries; when full, it grows by approximately `3/2` (`2, 3, 4, 6, 9, …`). Each incoming entry is the inseparable pair `[target, source_arena]`. A producer publishes that pair under the mailbox monitor without mutating the receiver arena. The receiver owner attaches `source_arena` before exposing `target`; refusal leaves the exact pair queued. Growth copies unread pairs in FIFO order, then replaces the private backing. The backing address is not a graph value, is never published, and is not classified as an LMX type. GC obtains a monitor-consistent snapshot of unread targets through the mail module and never reads the backing directly. Allocation refusal or size overflow answers `LMX_POST_FULL` without damaging the old ring. Capacity check, growth, slot reservation, publication, take, and count update are serialized critical sections, so two producers cannot receive the same `inbox_tail`. The current collection deliberately uses simple `synchronized`; a lock-free MPSC ring belongs to a separate future mail implementation. `init` and `close` require quiescence: no OS thread is in `accept`/`take`/`count` or starts one before the operation completes. Close releases pending donor arenas one by one and fails closed before losing an entry it cannot release. During child settlement, mailbox close precedes route unregistration, removal from the parent's children List, and arena release or attachment; refusal therefore leaves membership and ownership reachable for retry. Outgoing and staged are lists of `LmxPostLink` (target address + next) from the box's pool. `LmxPostLink` is not an envelope. FIFO is admission order under the monitor. L1: [L1](L1_spec_en.md#mailbox).

<a id="own"></a>
## 10. Execution of a Structure

Execution runs the callable's complete Structure. An ordinary named Structure is callable too, but it has only a body: it has no formal arguments or result, and only a nullary call is valid. An application such as `Model: Other` is resolved as a call when `Model` is known; `Other` is then an unexpected actual and the general call check reports an arity error. This is not a syntax-specific prohibition or a fallback to declaration or assignment. `fn`, `fm` and `sub` define their own formal signatures and results. A Structure used as a value in `merge` or `send` is not executed by that use. A computed callable reference is invoked by the general [call](#call) rule. The complete Structure retains declarations and executable operators in source order, including nested bodies as nested Structures (`M\for\y` is the same path). Execution preserves operator nodes, their literals and the `native` word; declared value storage may change at its declaration site. Formal arguments and the returned value have activation-local working values, and an argument never becomes a graph field by assignment -- only a declaration establishes value storage ([L3 §12](LMX_semantics.en.md#dynamic)); composition through `merge` gives a formal its default value ([L3 §11](LMX_semantics.en.md#callables)) and binds nothing. The own fields an activation uses are loaded into activation-local working storage, a modified value is `dirty`, and the required dirty own fields are published at the checkpoints [L3 §12](LMX_semantics.en.md#dynamic) defines; the physical form of `dirty` is the backend's (static knowledge in the native translator, a bit or a bitmap in the interpreter). A body declaration `int: i 5` establishes value storage at that declaration in the complete Structure; executable initialization remains at its own source position. A repeated declaration of a name is the next occurrence, while a repeated bare assignment resolves the existing binding and is not a new occurrence. Only a declaration makes a field: a bare assignment inside a nested body (`if`, `while`, a block) creates no field of that body and updates the resolved declaration of the callable (`fn: keep (int: n) int` with the body `int: n` / `if: 1` / `n: n + 1` / `return: n` gives `keep(3) = 4`). The assignment remains an operator node in the complete Structure, as `else` does. An explicit path reads or writes the selected declaration's value storage; it does not replace the initializer or assignment operator. The graph is stored as it is, with its whole contents; that is why any Structure may be placed as code or as data. The body is retained as a binary tree, not text to parse again. Comment text is preserved, and names remain available through the address-to-name table. These data do not replace resolved references or participate in dispatch. Body operators such as `if` and `for` remain in the graph for the interpreter; native execution leaves those operator nodes intact. Execution changes only selected declared value storage, even when code and data are the same Structure. An ordinary call runs the callable occurrence over its declared values, and the file root runs the same way; execution never writes operator nodes, literals, or the `native` word, only storage established by declarations. Activation: a call of `fn`, `fm` or `sub` passes its checked actual arguments to the machine activation. An ordinary named Structure has no explicit argument list or declared result and is invoked nullarily; its ordinary hidden inputs remain governed by the common call rules. Re-entry executes the same Structure with a separate machine frame and its working values; declared values remain at their declaration sites. Named-Structure definition and explicit construction follow [§13](#copy-merge); calling an existing model does not implicitly clone it. `node` denotes the lexical parent Structure; an explicit `node\x` follows its `parent` link. The parent's slot holds `M` itself: a declaration in M's executable body is a local of that body, visible forward and down, lying in M where it is written with no field or container beside it -- the latest activation's published values stay at the places of declaration in M, and the path `M\x` from outside reads such a place, since a declaration always establishes a value there ([L3 §11](LMX_semantics.en.md#callables)); results are not read through the slot; one Structure passed to two activations is shared by them. Formal arguments, locals' working values, and the activation result belong to the ordinary machine activation: `fn` returns a value, `fm` a reference to its result Structure; `return` is a code operator, and data has no result field. The L2 expression `@x` selects the actual value storage under [§18.2](#lowlevel-address), including the reference-holding cell for Structure/Array, not a working copy; taking the address alone neither marks the working value `dirty` nor changes the addressed object. Callable composition and retention of the selected body's native implementation follow [§13](#copy-merge). Portable reference operations, including `@`, retain the L3 contract in [L3 §12](LMX_semantics.en.md#dynamic); machine address arithmetic and raw access remain L2. L1 lowering: [L1 §11](L1_spec_en.md#own).

<a id="call"></a>
## 11. Call

A statically compiled executable body of any Structure, including the file root, receives a native implementation; there is no special interpreter-only root. At a call, only the concrete occurrence's native entry determines dispatch, not its name, nesting or source position.

Execution of a Structure in head position is selected by `Lmx.native` ([§2](#lmx)): non-null enters native code, null runs the walker over the same body. The call ABI supplies reserved `node`, the lexical parent, and hidden `self`, the active Structure of this invocation ([§10](#own)), along with the resolved arguments. `self` is not a language word, and these references do not create separate code and data objects. Call-argument checking and admission use the common language contract; native dispatch is not a second admission algorithm. The method's args/return parts describe its inputs and result without a separate METHOD record or `sig` word. L1: [L1](L1_spec_en.md#call).

Internal call transport preserves both the resolved value type and whether an input is present. A zero argument-storage address denotes absence; a nonzero address may hold a present null reference. Numeric values use storage of their declared machine width. Object references use a canonical pointer-value transport cell and are loaded exactly once; this cell is not the language storage addressed by `@`. Neither a descriptor nor its graph is copied by value for transport. Addressable formals retain their own activation storage, while nonprimitive descriptor formals retain the descriptor-reference meaning of [§13](#copy-merge).

The physical call contract consists of ordered input type witnesses and a result part: empty for no result, otherwise containing the result witness. This contract comes from the resolved callee interface, including prepared hidden inputs, not from the actual values supplied or the inputs used by the body. An ordinary root or named Structure does not acquire a source-level signature prefix from this transport metadata. Callback status is separate from the returned value. In particular, a successful reference result is present even when null; null cannot stand in for the absence of a result.

<a id="child"></a>
## 12. Child reservation

A child is built in **its own** arena; publication appends its physical reference to the direct-child List (`KIND_LIST`) in the parent's graph **at the end of the parent's turn**. There is no fixed position or predetermined membership size. Until publication, nobody else executes inbound work. Parent failure drops reservations without rolling back graph writes already done. A reservation lives in the parent's arena. Storage handoff attaches the child's arena to the parent only when `handoff_ready`. L1: [L1](L1_spec_en.md#child).

<a id="copy-merge"></a>
## 13. Graph copy and merge

Graph copying and explicit `merge` follow [L3 §20](LMX_semantics.en.md#composition). One source-to-copy map covers the complete used closure, preserving shared targets and cycles while rewriting references and `parent` links to the corresponding copies. The first operand supplies the model's field positions; admitted matching fields replace those positions and unmatched fields are appended. A copied callable occurrence is distinct from its reusable native implementation: the selected body's implementation is retained when applicable, under the same composition rule. An admitted `independent: const: immutable` branch is retained by its original physical reference. The kernel receives already resolved field-position correspondences, not source names or a table of model-pair conversions. L1 lowering: [L1 §14](L1_spec_en.md#copy-merge). A declared callable header constrains admission of the composed result; it is not an additional `merge` operand. Composition needed to retain the used values of a completed activation when returning a nested callable remains governed by [L3 §20](LMX_semantics.en.md#composition), independently of executable declarations.

The declaration, assignment and call rules are defined in [L3 §9](LMX_semantics.en.md#construction). An unknown head defines a named Structure without executing its body: with both `C` and nested `makeA` unknown, `C: makeA()` defines `C` containing the named empty Structure `makeA`. A known nested callable remains an ordinary application in the complete retained tree, not a separate saved-call object; defining the containing Structure does not execute it. An existing Structure in head position is called. An ordinary named Structure has no arguments, so supplying any actual is a general arity error; `fn`, `fm` and `sub` instead use their declared signatures. A failed known call does not clone the head or declare the actual. There is no implicit `Model: fresh` → `fresh: merge(Model, empty)` construction in executable declarations. The explicit expression `b: merge A C` retains its ordinary meaning: evaluate the merge of operands `A` and `C` and deliver the result to outer destination `b`. Removing implicit declaration cloning does not change the separately defined composition of a returned nested callable.

The `@:` receiver selects explicit reference assignment: for absent `b`, `b: A` and `@: b A` are equivalent; after binding, `b: args` applies the selected Structure and `@: b B` reassigns the reference. Repeated declarations remain distinct occurrences. Conversion and `implements` against the Consumer precede storage; failure preserves the destination and dirty state. Reference assignment does not clone, reparent or transfer ownership. It does not create a nominal type system: requirements are primitives or ordinary Structures. Unary `@A` is a different operation and adds a reference level; it is not a synonym of ordinary `A`.

A signature describes inputs, not executable declarations. Nonprimitive inputs transmit their existing Structure/Array references without C by-value copies. The descriptive forms `(A: b)` and `(@: A b)` retain their signature contract; that does not erase a unary address operation on an actual. `test(b)` passes the held reference; `test(@b)` passes the address of its cell, one level deeper. The receiving formal must admit that exact depth; no descriptor-specific stripping is permitted. Primitive `(int: b)` and `(@: int b)` remain different. Calls and candidate admission follow the general [callable contract](LMX_semantics.en.md#callables).

<a id="implements"></a>
## 14. `implements`

L2 supports the [L3 admission mechanism](LMX_semantics.en.md#admission): analytical checking of the tree's used named paths and execution of the receiving expression's unit tests by the graph interpreter. Physical address classification remains a separate value-representation operation.

A field correspondence relates a particular admitted value to a receiving model: model positions map to physical positions in that value -- a permutation where the order of fields differs, not a coincidence of indices. Reading, writing and taking a field's address through a typed reference use the same correspondence, and each access reaches the field its own spelling names: an unqualified name reaches the value's last occurrence of that name and `[N]name` its occurrence N in the value, so two accesses that name one model field may reach different positions of the value and the correspondence carries a target for each used access. This applies at every such reference crossing in a structural path, not only its first segment. Other segments remain ordinary structural paths; the correspondence table is not another name lookup.

The declared receiving model and the value's physical layout are distinct information. Equal maps into one model, including identity maps, do not establish equal source layouts. When its provenance is known, the existing correspondence entry retains that witness separately; unknown provenance is not replaced with the receiving model. For a compiler-known schema, the witness is associated with the source declaration and remains the same across repeated constructions, rather than being each instance's address. This is field-correspondence information, not a new value type: all ordinary Structures still have the same physical type `Lmx`. Subsequent reception uses the actual transmitted value, not a rescan of the reference binding's original initializer.

A cached map does not replace the current Consumer's requirements and mandatory checks. A field not carried because the previous Consumer did not use it does not become available to the next Consumer through the earlier positive answer. Failed reception publishes neither a new correspondence nor layout evidence and leaves the receiving binding unchanged. Graph copying creates a fresh value and does not transfer the source value's admission entries to it. Entry representation and lifetime: [L1 §15](L1_spec_en.md#implements).

<a id="gc"></a>
## 15. Collection

`lmx_gc.h.lm1` / `lmx_gc.lm1`. Generation on the arena; a chunk is marked by generation compare. Roots are the Message record, object, mail and its nodes/ring, current scheduling state, and the live graph including the sole direct-child List. There is no separate child chain or membership queue among the roots. Explicitly retained initial typed ranges in R0's arena have process lifetime because R0 owns the initial module, without an R0-only capability. Collection or unload rules for a later module's ranges are not yet defined. Simple arena mode refuses collection. L1: [L1](L1_spec_en.md#gc).

<a id="special"></a>
## 16. Special L2 operations

Low-level operations include address classification, taking an arena cell, arena attach/revert, mail enqueueing, `lmx_thread_turn`, `lmx_call0`, child reserve/publish, copy/merge, and collection. Semantic admission is defined in [§14](#implements).

<a id="lowlevel-scope"></a>
## 17. Machine operations: level boundary

Built-in machine types have exactly their C99 target-platform meaning: representation, width, signedness, numeric range, promotions and machine operations. In particular, plain `char` follows C `char`; it is not implicitly `unsigned char` or a platform-independent 0–255 integer. A typed arena cell, graph reference or Array descriptor does not change the element type's numeric meaning. LMX defines its own types separately; native and interpreted execution preserve the same meaning of a given type.

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

The `@:` receiver selects explicit reference assignment: for absent `b`, `b: A` and `@: b A` are equivalent; after binding, `b: args` applies the selected Structure and `@: b B` reassigns the reference. Repeated declarations remain distinct occurrences. Conversion and `implements` against the Consumer precede storage; failure preserves the destination and dirty state. Reference assignment does not clone, reparent or transfer ownership. It does not create a nominal type system: requirements are primitives or ordinary Structures. Unary `@A` is a different operation and adds a reference level; it is not a synonym of ordinary `A`. Primitive pointer declarations such as `@: int p`, `@@: int pp`, and arbitrary further depths retain their declared representation. `@: p` declares a void reference initially zero; no raw-memory permission follows in L3.

A Structure value is stored and transported by reference, conceptually `Lmx *`; unary `@A` addresses the cell holding that reference, conceptually `Lmx **`. The extra level is not removed for a Structure, Array, formal, field or callable. Ordinary `A` reads the stored reference. `@` must use real stable value storage, not a temporary, working cache, transport-ABI box or the pointee descriptor. Array descriptor references obey the same rule; primitive `@x` addresses the primitive cell. Source model names denote ordinary Structures used by admission, not separate nominal or C aggregate types.

```text
int: x 5
@: int p
@@: int pp
@@@: int ppp
p: @x
pp: @p
ppp: @pp
```

`A` and `@A` are different values and depths; neither conversion nor argument matching may erase the distinction. Receiver notation `@:` and unary address-taking `@A` are separate operations. Structural requirements and signature descriptions do not execute their bodies.

The portable reference operations, including declaration, obtaining a reference to resolved data, passing it, rebinding a reference and following it, retain their [L3 contract](LMX_semantics.en.md#dynamic). Machine address arithmetic, numeric address manipulation and raw-memory access are L2 operations. Shared spelling does not turn a graph reference into a numeric machine address.

`@:` is not an ordinary Array constructor. Low-level string `@: char "hello"` is an address primitive pointing to a C string; it does not automatically acquire a length descriptor. Ordinary Structure `User` and opaque primitive `FILE` do not become the same value kind because their C representations use pointers. The pointer itself is a primitive value; its referent's structural compatibility is checked separately after reference conversion.

### 18.2. What @x addresses

Unary `@` addresses the resolved value's storage. For a reference-held value, that storage is the reference cell, not its pointee; for a primitive it is the primitive cell. Native and interpreted execution must select the same language place.

| Category of x | Result | Effect of writing through the result |
| --- | --- | --- |
| Declared primitive graph field | Typed address of its classified cell | Changes the graph cell; neither assigns nor dirties the activation's working copy |
| Structure/Array graph field | Address of its actual reference-holding cell, one level deeper | Changes the held reference under admission; not the pointee descriptor |
| Explicit pointer/reference binding | Address of its pointer-value cell, adding one level | Changes the stored pointer, subject to the binding's admission and publication rules |
| Primitive formal argument or primitive dynamic input | Address of the activation's parameter value | Changes the local parameter without copy-back |

A Structure/Array formal owns an activation-local reference value. `@formal` addresses that value's stable cell, not the caller's variable, shared descriptor or temporary ABI carrier. Address-taking neither adds a persistent graph field nor extends activation lifetime.

The address of a graph-held Structure reference is the address of its real reference place. It is not `Lmx.array.data`, the descriptor's `native` word, element backing or a copied pointer. An addressed declaration and its occurrence are retained in the graph. Physical untagged child storage does not permit pretending all pointer-to-pointer C types are interchangeable; native emission must respect exact storage/effective types.

A local machine slot's address is needed, for example, for an output parameter: [printTree.lm2](../l2src/printTree.lm2) reads the path from the `mainArgs` letter and, in a method, passes `@document` to `lm_p0_parse_file` so the function can store its result pointer. This addresses the pointer variable, not the document. [library_struct_local_forms.lm2](../l2src/tests/library_struct_local_forms.lm2) addresses a local imported C-ABI record.

`@array[i]` is a valid L2 expression. It obtains the actual element's address in graph storage; no separate adapter or prior index check is required. Subsequent loads, stores and address arithmetic follow the C machine contract. Address-taking must not be implemented by reading the element into a temporary and then addressing that copy.

Starting with graph and working `x = 5`, `p: @x` followed by `\p: 9` leaves bare working `x` at 5 while an explicit graph read sees 9. If working `x` was not assigned, exit does not republish the old 5. A later assignment to working `x` creates a dirty write published under the ordinary rule ([L3 §12](LMX_semantics.en.md#dynamic)). The address of an activation-local parameter or pointer cell exists only for that activation; storing it in the graph does not extend its lifetime. A Structure/Array passed by reference remains the same existing object, with its own lifetime.

### 18.3. Loads, paths and restrictions

An argument has no own-binding rule: bare assignment to an explicit or hidden argument updates the activation-local value; no field is prepared and nothing is published ([L3 §12](LMX_semantics.en.md#dynamic)). The argument source and parent remain unchanged. Taking the address of an activation-local primitive or pointer cell returns that cell's stable address for the activation's lifetime and invents no graph field or publication destination. An ordinary nonprimitive argument reads its held descriptor reference; `@argument` addresses its own stable reference cell, never a temporary transport parameter. Declared graph fields use their actual classified data as described in §18.2, not their working copies.

`\p` follows a typed reference; `\p: value` applies the ordinary operation to its referent when permitted. Portable graph-reference following is not a raw-memory operation merely because the C implementation uses a pointer. Raw loads and stores through machine addresses use the L2 machine contract. `p\field` follows either an explicitly imported machine ABI field or an ordinary structural path, depending on p's category. These cannot be conflated as universal `->`: a Structure uses the graph, while raw ABI access uses known layout. L2 indexing checks no bounds, for either raw addresses or graph-backed Arrays. Array index and descriptor validation belong to L3. Reading a descriptor to obtain backing is not descriptor validation. Field and index chains bind more tightly than prefix `@` and `\`.

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

`target[index]` consumes an index expression. An unnamed step `target\[index]` indexes a typed Array; `target\[index]field` selects a same-name Structure field occurrence. `a[i]\[j]` addresses the Array selected as `a[i]`, while adjacent `[i][j]` address the original flat multidimensional Array ([general paths](LMX_semantics.en.md#fields)). Any finite chain uses one algorithm for resolving the next typed value; the element type does not introduce a special Array path. Target category determines how data are located without adding L2 bounds checks. Checked Array operations belong to L3: for the adjacent flat rectangular form they check the final row-major linear index against the descriptor's total element count, rather than recovering dimensions or adding per-coordinate checks. L2 provides unchecked machine access to the selected cell. Assignment neither appends a repeated field nor creates a namespace.

In an executable body, headless `2`, `f`, `2 + 2`, `(f)`, `(2 + 2)`, and empty `()` are valid ordinary expressions or anonymous Structures. A bounded anonymous Structure and the corresponding vertical body are consumed in field order by one mechanism; named Frames and headless expressions within them are not lost. An expression without a destination is evaluated and its result discarded. Bare `f` invokes nullarily only if it resolves to a callable; a non-callable value is evaluated without invocation. No spelling infers a type from a literal or changes the general declaration, assignment, call, or admission rules.

Control forms are `if`/`else`, `while`, `until`, `for(init, condition, step)`, `return`, `break`, `continue`, and [synchronized](#lowlevel-sync). A closing `until:` makes the body it closes a postcondition loop — the body, then the condition, ending when the condition holds: an anonymous body is that loop in the current activation, a named Structure closed by `until:` is an ordinary named Structure whose body is the loop, run only by an explicit call. No form requires a trailer: `end:`, a bare `return` and `until:` are P0 boundaries; an absent head with a Structure value declares a named Structure however it is closed ([L3 §9](LMX_semantics.en.md#construction)), and neither it nor `sub` needs a `return`. Shared branch and loop rules are in [L3](LMX_semantics.en.md#branches); `match`, `each`, `retry`, and `yield` require separate L2 operations or a profile. Lowering to [L1](L1_spec_en.md#lowlevel-expression) preserves the distinction between graph updates and raw stores.

<a id="lowlevel-sync"></a>
## 22. synchronized and synchronization boundaries

`synchronized` remains a general low-level L2 capability. Restricting kernel synchronization to the postal mechanism does not remove the language operation. Pure L3 has no raw locks. The contract consumes an object/address expression and structural body rather than an exposed lock/unlock pair.

```text
synchronized: @object
    updateObject: object
```

A nested body is a separate structural argument field. `synchronized: @lock (break)` states it explicitly; `synchronized: @lock break` leaves `break` in the inline sequence and does not allow the parser to silently reinterpret it as the body.

The monitor profile defines entry/exit and, where required, same-thread re-entry. The minimal profile used by the postal collection (§9) is reentrant and has no `wait`/`notify`; it is mutual exclusion, not a condition queue. The region is released on normal completion and exiting `return`, `break`, `continue`; the general cleanup protocol governs other exits. A result is retained before release. Calls inside preserve ordinary argument-evaluation and dirty-publication ordering.
