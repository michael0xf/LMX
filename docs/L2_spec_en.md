# L2 specification

L2 is LMX with special low-level operations. This specification describes those operations and the core **from the examined source snapshot** in `l2src/` (copy of `L1/dev/l2src_sandbox/l2src` at L1 commit `b2a7c98aa59aaf9654f2180e6f2a149e58aa48ee`). Semantics of pure hermetic LMX (L3) are in the [main specification](LMX_semantics.en.md); grammar is in the [grammar specification](LMX_grammar.en.md). The same mechanisms in L1 and C99 are in the [L1 specification](L1_spec_en.md). Snapshot, tree divergence and open questions are in the [migration log](../steps/l1-l2-migration.md).

Both descriptions define one mechanism at their levels. Shared facts are not repeated: the primary definition lives here or in L1; the paired document links to the anchor.

<a id="scope"></a>
## 1. Scope

L2 is the language of the core mechanisms: `Lmx` structures, the arena's typed arrays, Message, mail, an L3 Thread turn, graph copy and call. Core sources in this snapshot are written in L1 (`.lm1`; some `.lm2` are frontend input). The translation chain is L2 → L1 → C99, as in [semantics](LMX_semantics.en.md#scope). A complete L2→L1 translator is not claimed: the tree contains `l2trans.lm1` with a bounded input (see `l2src/README.txt`).

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

Coarse kinds are `enum: LmxKind` (`NONE`, `PRIMITIVE`, `METHOD`, `ARRAY`, `CHILDREN`, `REF`, `STRUCT`). Concrete types are `enum: LmxType` (primitives, Array descriptors, METHOD, Structure, pointers, arrays of pointers; bases `LMX_TYPE_POINTER_BASE` and `LMX_TYPE_ARRAY_OF_POINTER_BASE`). One half-open interval is `struct: LmxRange` (`lo`, `hi`, `stride`, `kind`, `type`). Address classification is the arena index: `lmx_range_classify`, `lmx_range_type_of`, `lmx_range_pool` in `lmx_arena.h.lm1`. Nothing is stored on a cell to “say what it is”. L1: [L1](L1_spec_en.md#type-by-range).

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

Flag type is `uint_fast8_t` (`type: LmxFlag`). Mail, queues, scheduler, deadlines and family links are **not** fields of this record. The letter envelope is this record, not a wrapper around it. L1: [L1](L1_spec_en.md#message). Divergence from the author's intent about where atomic handshake flags live is in the [log](../steps/l1-l2-migration.md#handshake-flags); it is not resolved here.

<a id="thread"></a>
## 8. L3 Thread

Not every Message is an L3 Thread. A letter has no turn. Object `struct: LmxThread` in `lmx_thread.h.lm1` **points at** the Message (the reverse field is forbidden by the closed record). It has mail, a scheduler, turn state, a list of reserved children, and a chain of live children in the **parent's arena** (`struct: LmxLink`: `alive` is the one sanctioned cross-lane handshake cell). Two separate APIs: `LmxThreadApi` and `LmxThreadMailApi`, not one merged heap. A whole turn is `lmx_thread_turn`. The body is a graph callable or a host handler. An OS thread is not promised. L1: [L1](L1_spec_en.md#thread).

<a id="mailbox"></a>
## 9. Mailbox

The only synchronized point in the core is mailbox **admission** (`lmx_post.h.lm1`). The module introduces no mutex or semaphore.

Three lanes: `inbox` (admitted, not yet taken), `outbox` (published by a successful end-turn), `staged` (current turn's preparation; others must not see it). Inbox is a **ring** of fixed capacity `LMX_POST_INBOX_SLOTS` (256): slots are taken by the owner in its own arena at open; a full box answers `LMX_POST_FULL` and does not grow. Counters `inbox_head` / `inbox_tail` are atomic release/acquire. Outgoing and staged are lists of `LmxPostLink` (target address + next) from the box's pool. `LmxPostLink` is not an envelope. FIFO is admission order. L1: [L1](L1_spec_en.md#mailbox).

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

L2 supports the [single L3 admission mechanism](LMX_semantics.en.md#admission): analytical checking of the tree's used named paths and execution of the receiving expression's unit tests by the graph interpreter. Matching field positions, address kinds or signatures does not constitute an alternative validation mechanism. The current positional `lmx_runtime_implements` does not conform to this model and must be completely replaced; its defect and the infrastructure functions in use are described in [L1 §15](L1_spec_en.md#implements). This snapshot does not implement the test interpreter as part of admission.

<a id="gc"></a>
## 15. Collection

`lmx_gc.h.lm1` / `lmx_gc.lm1`. Generation on the arena; a chunk is marked by generation compare. Roots: Message record, object, mail and its nodes/ring, schedule, live graph, child chain. Simple arena mode refuses collection. L1: [L1](L1_spec_en.md#gc).

<a id="special"></a>
## 16. Special L2 operations

Low-level operations in this snapshot include: address classification, taking an arena cell, arena attach/revert, mail enqueueing, `lmx_thread_turn`, `lmx_call0`, child reserve/publish, copy/merge, collection. Semantic admission is defined in [§14](#implements). The door to C is `c.` calls in the L1 sources that implement the core; that is not a separate bytecode. The bounded frontend `l2trans.lm1` accepts a narrow `.lm2` subset (see `l2src/README.txt`) and does not replace this core specification.

<a id="unresolved"></a>
## 17. Unresolved in this snapshot

Do not invent missing mechanisms. Measured and reported by deepseek, not closed by the author here:

- two diverged `l2src` copies (L1 root vs sandbox); LMX holds the sandbox;
- placement of atomic handshake flags relative to parent/child arenas;
- implementation of the single [admission mechanism](LMX_semantics.en.md#admission): analytical `implements` requires rewriting, followed by unit tests through the graph interpreter;
- a complete L2→L1 translator.

File evidence is in the [log](../steps/l1-l2-migration.md).
