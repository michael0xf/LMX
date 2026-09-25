# The LMX L2 kernel: technical architecture and current implementation

This document describes the **L2 kernel**, not the whole LMX language and not an
alternative specification. It is an implementation map for contributors who need
to understand what the kernel stores, who owns it, how one turn proceeds, and
where the current implementation is incomplete. The normative language
contracts are [L2](docs/L2_spec_en.md), [L3](docs/LMX_semantics.en.md), the
[grammar](docs/LMX_grammar.en.md), and the paired [L1 lowering contract](docs/L1_spec_en.md).
The current repair and migration order is [next_core_tasks.md](next_core_tasks.md);
its [dictionary](next_core_tasks_dictionary.md) defines the disputed terms.

The implementation observations below refer to the live development tree at
`744f759` (22 September 2026). The tree changes rapidly: a green fixture or an
existing code path is evidence of that version, **not** proof that the intended
contract is complete. Check the current source and tests before reusing any
line-specific conclusion. This document introduces no new language rules.

## 1. Engineering boundary

L2 is LMX plus the machine operations required by the kernel. L3 is the
hermetic graph-level language and a subset of L2: a named or anonymous
Structure is always L3, L2 operations are available only inside method
bodies, and `@` of any depth in L3 is a reference-declaration receiver only.
L1 is a technical
lowering intermediate, and C99 is its current machine target. The **present** build paths are:

```text
live kernel .lm1 ───────────────→ L1 translator ─→ C99 runtime
L2 .lm2 unit ─→ L2 translator ─→ generated L1 ───→ C99 program
L3 .lm3 unit ─→ L2 translator (same rules) ─→ generated L1 ─→ C99 program
L3 graph (constructed) ─────────→ graph interpreter as well (L3 only)
```

L3 is compiled by the same rules as L2; the one difference is that a
constructed L3 graph *may* also run in the graph interpreter, while L2
operations may not. The current toolchain runs a file's root body through the
interpreter and method bodies natively: an implementation default, not a
language rule. The L2 runtime presently contains mostly `.lm1`
units. Porting this code to
`.lm2` and attaining **full L2 self-build** are future milestones, not current
facts. `myxa_manager` is an application above the kernel, not a reason to put
application-specific state in the kernel's universal records.

The project has two similarly named source trees. `dev/l2src_sandbox/` is the
active development implementation and fixture corpus. Root `l2src/` is a copy
of it kept in the old place: nothing is built or tested there, and it may lag
the sandbox between refreshes (author, 2026-09-26; the former frozen twin is
the tag `l2src-twin-20260926`). When the development sandbox exists,
[`tools/build_l2src.ps1`](tools/build_l2src.ps1) and
[`tools/l2_harness.ps1`](tools/l2_harness.ps1) stage that live tree for their
builds. Verify which tree a reported result actually exercised.

Core rule for all work: find one general mechanism for each semantic role.
Never make a special rule for one source spelling, C name, fixture, backend,
root node, or convenient code path. A proposed exception or a conflict between
rules is a question for the author, with a minimal program and both possible
readings. This is a language kernel; keep the algorithm simple and test it
thoroughly. Do not add speculative defensive layers, fallback paths, hidden
registries, or fields to closed base records. Real invalid programs and
external failures still require precise diagnostics.

## 2. Physical graph and identity

The accepted target physical layout for the universal Structure is:

```c
typedef struct { size_t size; void *data; } VoidArray;
typedef struct Lmx { VoidArray array; struct Lmx *parent; LmxEntry native; } Lmx;
```

The current [`lmx.h.lm1`](dev/l2src_sandbox/lmx.h.lm1) still has the old flat
`{parent, int len, void *data}` layout; the migration is pending. In the target,
`array` is the first member and the actual by-value child-reference array
descriptor, not a C-only wrapper: `array.size` is the number of immediate child slots, not bytes or
capacity, and `array.data` addresses their ordered `void *` backing. That
backing is registered as a `CHILDREN`/`REFS` address range in the arena;
`VoidArray` is not the `LmxRange` index entry. `&node->array` and `node` have
the same address, while the arena still classifies the `Lmx` allocation as a
Structure rather than a standalone Array descriptor. `parent` is the immediate
*structural* parent in the working graph. `native` (accepted 2026-09-25) is
the direct reference to the native implementation of this Structure's body:
the C entry, or null when there is none. It is not a lexical element and not a
graph field, so it sits in the record after `parent` rather than among the
child slots; graph copy carries the word verbatim (landed 2026-09-26).
The slots are fixed in number when the Structure is constructed; their stored references may
change. The header has no name, type tag, method pointer, vtable, list capacity,
dirty flag, or Message state. In particular, an empty Structure remains an
ordinary two-direct-member Structure with zero child slots.

For a slot `i`, `((void **)s->array.data)[i]` is a **physical reference value**. Its
type comes from the registered address range containing that value, not from
the address of the slot. The latter belongs to the `REFS`/children-storage
range. A primitive child points to a primitive cell; a Structure child points
to an `Lmx` header; an Array child points to its descriptor; a method child
points to its method record. `void *` does not mean that all referents have the
same representation. It means the graph stores heterogeneous physical
references and classification is external to the node.

There are three different relationships that must not be merged:

| Relationship | Physical source | Meaning |
| --- | --- | --- |
| `Lmx.parent` | Structure header | Immediate structural enclosing node. |
| `Lmx.native` | Structure header | Direct reference to the native body implementation; null when no native form exists (any Structure can be interpreted). Not a graph field. |
| Method `node` | `M.parent` at entry | Reserved lexical space above callable occurrence `M`; fixed for that activation. |
| `LmxThread.parent` | Thread state | Supervision/postal route to the parent Thread; not lexical graph parent. |

Nested `if`, `while`, `for`, and other executable bodies may be separate graph
Structures, each with its own `Lmx.parent`. The native emitter may flatten
their execution into one C function. Structural representation and generated
control flow are different questions; the internal Structures do **not**
rebind a method's reserved `node` argument. `self` is another, hidden physical
parameter: the specific callable occurrence whose own fields and dirty state
this activation uses. It is not a source-language name.

### 2.1 Address ranges and typed service arrays

An [`LmxArena`](dev/l2src_sandbox/lmx_arena.h.lm1) maintains a sorted index
of half-open address intervals. A live
[`LmxRange`](dev/l2src_sandbox/lmx.h.lm1) currently contains `lo`, `hi`,
`array`, and `owner`. `array` refers to the typed service pool describing the
cells in that interval. `owner` identifies the arena that owns the storage;
an explicitly imported view can be visible through another arena's index
without adopting its allocation. The current [L2 specification §3](docs/L2_spec_en.md#type-by-range)
still abbreviates the range as three fields. That documentary/ABI difference
must be reconciled; do not silently delete `owner` or claim the descriptions
already agree.

[`LmxPool`](dev/l2src_sandbox/lmx.h.lm1) is the descriptor of one typed
service array: stride, coarse `kind`, exact `type`, optional physical profile,
sealed storage policy, and a chain of chunks. A full pool acquires another
stable [`LmxChunk`](dev/l2src_sandbox/lmx.h.lm1); it never `realloc`s live
cells. Each chunk contributes a range to the same arena index. A classified
address therefore gives an exact representation without a per-cell tag. The
range classifier accepts starts of allocated cells, not arbitrary interior
bytes or unused pool capacity. The `profile` is a physical receiver-expression
identity, separate from the coarse kind and representation type; `sealed` is
a storage/collection property, not a language qualifier by itself.

Representative kinds are primitive cell, METHOD record, Array descriptor,
Structure child-slot storage, reference cell, Structure header, and separate
List. Exact `LmxType` domains distinguish, for example, `int` from `char`, an
Array-of-int descriptor from an Array-of-Structure-reference descriptor,
`@T` from `@@T`, and a standalone Message record from a Thread record. The
range index is a type/ownership mechanism; it is **not** admission by
`implements`.

The main arena operations are open, typed `take`/`take_n`, range registration
and classification, `mark`/`revert`, arena `attach`, and `release`. Mark/revert
supports all-or-nothing construction such as copy or merge. Attach transfers
ownership of already allocated storage without changing physical addresses.
The simple-arena profile keeps the address index but has no collection pass or
multi-chunk growth. Owned blocks are managed by `lmx_arena_blocks`; child-slot
storage by `lmx_arena_refs`; typed pools by `lmx_pool`.

### 2.2 The base Array and the separate List

The accepted base Array type is `VoidArray`, exactly
`{size_t size, void *data}`; a separate `LmxArrayDesc` alias is unnecessary.
Standalone Array backing has exactly `size` elements; embedded
`Lmx.array.size` counts child-reference slots. The current
code still uses `size_t len` for `LmxArrayDesc` and `int len` for `Lmx`.
The base Array has no `capacity`, reserve, resize, append, backing switch, or
implicit growth. Changing its ABI to serve one dynamic consumer is a kernel
defect.

A dynamic container is a separate implementation:
[`lmx_list_owned`](dev/l2src_sandbox/lmx_list_owned.h.lm1) uses `KIND_LIST`
and exposes list operations while keeping growth state in its own backing.
The parent's dynamic children collection is one such List, held as an ordinary
field in the parent's graph and cached as the **same physical reference** by
its Thread. A mailbox ring is also private, growable storage, not a changed
base Array. Its current `LmxPost` record has its own `inbox_capacity`; this
is not an Array descriptor field. The [L2 specification §9](docs/L2_spec_en.md#mailbox)
describes capacity in a private backing prefix, whereas the current mail
record exposes `inbox_capacity`: a second precise spec/implementation
discrepancy, not permission to put capacity into `LmxArrayDesc`.

## 3. Callable graph representation and activation

An executable method occurrence `M` is an ordinary Structure with no special
slot. In the accepted form (2026-09-25) its signature is an ordinary graph field
and its native implementation, if any, is the `Lmx.native` word (§2); execution
dispatches on that word: non-null enters native code, null runs the walker over
the body operators. Graph copy carries the word verbatim while remapping copied
graph Structures. This form is landed (2026-09-26): there is no descriptor,
no `LmxCallable`/`LmxMethod` record, no `sig` word and no `lmx_plan`; a
method's children are its `args` and `return` parts followed by its fields,
while the file root and a named Structure hold their fields from slot 0.

[`lmx_call`](dev/l2src_sandbox/lmx_call.h.lm1) reads `Lmx.native`. The native
entry is entered with
`(node, self, ...)`, where `node = M.parent` and `self = M`. The transitional
direct-METHOD ABI enters with `(node, ...)`. The `sig` word currently selects
a dispatch contract; `lmx_call0` is not the full semantic signature checker.
Static checking, admission, and generated typed calls belong in the translator
and broader language model, not in a fabricated per-node tag.

**Execution pair.** An execution consists of exactly two Structure roots: the
Structure selected as the code graph and the Structure supplied as its data
graph. `code` and `data` name roles in one execution, not kinds, qualifiers,
storage classes, or persistent properties of a Structure: in `f(a b)` the head
`f` is code and `(a b)` is data, while the same `f` in `merge: f other` or
`send: f` is data. Code is immutable during execution and holds the descriptor,
the argument and return parts, and the body operators with literals at the
leaves. Data is an ordinary Structure holding the declared fields of the body in
lexical order, nested bodies as nested field-only Structures (`M\for\y` keeps
its path); a body declaration such as `int: i 5` names a slot of the data
prototype and, as an operator, writes into the passed data. Formal arguments,
locals, and the returned value belong to the ordinary machine activation; an
argument becomes a data field only by the assignment rule of L3 §12 or by
binding through merge.
One graph may stand in both positions: an ordinary call runs `M` over its own
fields, and the host runs the file root the same way; execution never writes
operator nodes, literals, or the `native` word, only declared fields. A bare assignment does not open a data slot; it remains a child of the code Structure, as `else` does. A read and a write through `data\x` use that same declared cell. The graph holds no further Structure: what the interpreter needs beyond that code tree and the declared data lives in the activation frame and is not written into the graph. A fresh
instance of the data prototype is created only on re-entry (recursion in the
static call graph, a dynamic call) or when data is passed explicitly; it lives
in the activation frame and is not visible from outside. Hence `node` is the
parent's data and `node\x` follows the parent chain only; there is no third
context graph. `M\x` from outside reads the fields of `M` itself; results are
not read through them. Arguments, locals, and the activation result
live in the ordinary machine activation: `fn` returns a value, `fm` a reference
to its result Structure. The native entry `(node, self)` therefore means
`(data.parent, data)`.
Merging callables follows the accepted rule: the signature is derived (a bound
formal leaves it), bound fields merge pairwise into the model's data slots, the
last operand's body operators replace the model's, the result's `native` word
is empty (interpreted), and nested methods keep their words. The representation described
in this section and in §3.1 (descriptor, body, and own fields in one Structure;
activation-local cells, dirty flags, checkpoints) is the transitional
implementation of this pair; see §9.

[`lmx_plan`](dev/l2src_sandbox/lmx_plan.h.lm1) records positional paths to
own fields. Its producer scans the body in lexical order; a plan entry is a
path of child indexes **relative to an occurrence**, never an address into
the original occurrence. This permits copied occurrences to share one plan.
Preparation validates paths and publishes the plan at the same true owner as
the descriptor; activation uses trusted positional paths without repeated
arena classification. The plan's two role identities are physical role-record
addresses, not text names or numeric role tags. Changing one occurrence's
executable shape requires a fresh descriptor/plan relationship rather than
mutating the shared one.

[`lmx_walk`](dev/l2src_sandbox/lmx_walk.h.lm1) supplies the interpreter-side
body traversal and Stage-C preparation. Its operator nodes are identified by
typed addresses (`LmxOp` records), not by source spellings. The separate
[`lmx_interp`](dev/l2src_sandbox/lmx_interp.h.lm1) and
[`dev/l3_interp`](dev/l3_interp/) units run a graph interpretation path.
The interpreter does not execute L2 source text; it consumes graph bodies.
Native lowering and graph interpretation must agree on the same resulting
language operations, but a green test in one is not evidence for the other.

### 3.1 Body fields, occurrences, and own-state

A callable's body after `child[0]` preserves lexical fields and nested Frame
Structures. Repeated declarations are distinct occurrences, not one name-keyed
runtime slot; a repeated bare assignment writes the same declared cell and is
not an occurrence. The intended path selector `[N]field` identifies an occurrence;
an unqualified path selects the last occurrence (`[lastIndex]`); `merge`
creates no repeats, it overrides the model's slot in place. A current translator path can still
collapse repeated same-name fields into one own slot and does not completely
lower the selector. This is an [open core task](next_core_tasks.md),
not a license to add a second runtime name table or journal.

An activation-local variable has one stable canonical physical cell. In the
accepted address rule, **every executed `@local` makes that logical local
sticky until activation end** and returns the real address of that same cell.
The active occurrence is only the current publication destination; changing
it does not retarget an already issued pointer. Before switching from one
occurrence to another, a pending snapshot must be refreshed from the canonical
cell. Graph publication happens at a checkpoint, not at every machine write.
Sticky state makes later checkpoints conservative; it does not invent an
occurrence before the corresponding binding executes. The current `lmx_own`
and `lmx_dirty` implementation is a partial precursor to this full rule, so
do not describe repeated-occurrence/sticky behavior as fully landed. Under the
accepted execution pair (§3) working copies, dirty flags, and checkpoints are
replaced by direct writes into the declared fields of the executed Structure; a
fresh instance exists only on re-entry or with explicitly passed data, lives in
the activation frame and is not visible from outside; the canonical-cell
mechanism is transitional.

`@x`, `\p`, and `\p: value` in L2 are machine address, load, and store
operations. For a Structure binding, `@fresh` is the address of the Structure
itself (Q26.2), not of the slot holding its reference and not of a copy; a
reference field `@: Model slot` is a pointer cell whose extra indirection is
absorbed on read, so `@ slot` is again the Structure's address. Machine addresses do not extend the
lifetime of activation locals. The same `@` spelling in L3 is a separate
reference-declaration receiver with its own restricted contract; L2 pointer
operations must not leak into pure L3.

## 4. Declaration, assignment, call, and admission

These are distinct semantic operations even when surface syntax looks similar.
The accepted resolution order is: a resolved callable head is a **call**;
otherwise an existing typed mutable target is an **assignment**; otherwise
an explicit type/model construction may **declare** a new value; otherwise the
program is erroneous. A failed callable argument/signature/admission check is
an error in the call, not a fall-through to assignment. Direct assignment to
a callable field is not a separate source operation; replacement can arise
through the general merge/overload/argument mechanisms.

For example, `ping: 7` calls an existing callable `ping`, assigns to an
existing non-callable typed `ping` (subject to admission), or is an error if
`ping` is absent and no type/model declaration is present. Literal `7` does
**not** infer a new variable's type. `Model: fresh`, where `Model` is a
non-callable type/model and `fresh` is absent, constructs a new Structure
through the full `merge(Model, empty)` path; it is not reference rebinding.
If `fresh` already exists, an applicable assignment rule is evaluated instead.
Nonprimitive Structure values are physically passed and returned by reference
to their descriptors, but new construction remains real allocation/copy.

The parser's parenthesized, short-colon, and vertical forms must already
produce the same normalized Frame/body, before semantic consumption. `f()`,
`f: ()`, and an explicitly closed empty vertical `f:` followed by `---` have
an empty body; a dangling `f:` alone is rejected. This is the general
single-anonymous-argument-container rule of old §4.0.1, including nonempty
`f(a b)` / `f: (a b)`: the one wrapper occupying the whole positional
sequence is transparent once, while a Structure among other fields or in a
named position remains a field. A bare `f` is an expression statement: a
callable expression is invoked nullarily and a data expression is evaluated
and discarded. The result can use a typed dead temporary; no special
bare-name call rule is needed. Source-form flags are not semantic inputs.
The same executable-body consumer accepts lone `2`, atom/operator spans such
as `2 + 2`, bounded anonymous Structures `(f)` and `(2 + 2)`, empty `()`, and
their corresponding anonymous vertical form. It visits mixed Frame and
headless fields in lexical order, including `( f: 1 / . f: 2 / . 2 * 2 / . f )`
(slashes here denote line breaks; `f` must already have an explicit type).
There is no form-specific call or discard branch: the existing typed generated
`l2_tN` is the destination for an unused non-void result and is dead after the
complete expression. This describes the required route, not a claim that the
current translator already lowers every case.
The current P0 goldens and native/interpreter CALL-only unwrapping conflict
with this rule; see `next_parser_fix.md`. Structural declaration such as
`mystruct: ()` must use the same normalized body as `mystruct()` and the
general declaration rule, not recover a discarded wrapper.

`implements` is the receiving/admission operation for known assignments and
other accepted value transfers, including cases where the target address or
identity is cached. Address-range classification proves physical
representation, **not** that a value satisfies a receiving expression. The
complete intended mechanism combines analytical `uses(Consumer, bVar)` with
runtime validation of the receiving expression and directed primitive
conversions. The current
[`lmx_implements`](dev/l2src_sandbox/lmx_implements.h.lm1) exposes a coarse
physical compatibility path; its runtime walk is not yet the complete
Consumer/uses model. The prior project's full conversion table and L2 table
construction mechanism are to be ported only after the urgent kernel fixes
and their checkpoint, as [planned](next_core_tasks.md).

The `c.*` prefix is one raw door to C. A token spelled `c.name` is a raw C
name; other arguments in the same construct remain ordinary L2 expressions.
No L2 whitelist, header-scanned dictionary, or name-specific semantics for
`c.puts`, `c.array`, or `c.sizeof` belong in the language. Existing special
paths and scanner remnants are cleanup debt. A future ordinary `sizeof:`
receiver-operator is planned for Lmx-side size operations; it is not yet a
landed requirement. Raw `c.sizeof(...)` remains C `sizeof` through the same
door, with unevaluated behavior supplied by C rather than a special L2
`sizeof` parser branch.

## 5. Message, Thread, and one turn

The closed [`LmxMsg`](dev/l2src_sandbox/lmx_message.h.lm1) record is exactly
`{running, success, handoff_ready, graph}`. The first three fields use
`uint_fast8_t`; `graph` is the Message's graph root. `running` is permission
to continue; zero read during a turn is a stop request, not proof that the
work has finished. `success` is set by user code; `success = 1` is a sufficient condition
for stopping the Thread at end turn; the system never resets it to 0,
not even on failure, and sets it to 1 itself only for a plain letter at its
delivery. `handoff_ready`
marks a safe ownership-transfer boundary. The record has no mailbox, route,
parent, child list, schedule, deadline, or arbitrary application payload
field. A plain letter can be a standalone Message with no execution turn.

An executable [`LmxThread`](dev/l2src_sandbox/lmx_thread.h.lm1) starts with
`LmxMsg message` **by value**, so the addresses of a Thread and its Message
prefix are equal. The exact Thread range, however, is distinct from a
standalone Message range: prefix address equality never licenses reading a
Thread tail from a plain Message. Thread-only state includes mail, schedule,
turn number/state, current/requested mode, interpreter dispatcher, prepared
children, supervision up-link, route-service link, cached reference to the
single graph children List, liveness/close/orphan data, result cell, manager,
and separate `LmxThreadApi` and `LmxThreadMailApi` tables. These fields are
not candidates for inclusion in `LmxMsg`.

There is one active executor per Message identity. A Thread may be stepped or
run on an OS thread, but one turn belongs to one execution lane. A Thread has no
execution mode (author, 2026-09-24): each call's path follows the callable
occurrence's descriptor -- a native address is a native entry, none means the
body's op tree is walked by the interpreter (L3 only); the dispatcher never
infers a path from the body or retries through the other path on failure. The
kernel's `request_mode` field and its end-boundary commit are scheduled for
removal (plan §3).

The turn has a simple causal order:

```text
enter boundary → native or interpreted body → leave/end boundary
                                                ├─ success: publish outbox and prepared children
                                                └─ failure: discard them (prior graph writes remain)
```

[`lmx_turn`](dev/l2src_sandbox/lmx_turn.lm1) reads the turn outcome once at
the end, runs the corresponding post/child action, performs liveness and
stop-cascade work, collects the owning band when applicable, and finalizes
the mode request. Child preparation is not visible to ordinary incoming
execution before publication. A failed turn is not a rollback of graph
mutations already made; it specifically drops unpublished outgoing mail and
child reservations. The code has a known observability gap: the native
external-entry adapter can ignore the entry's return status, so a process
exit of zero or a green generated harness row does **not** necessarily prove
the body succeeded. This must be closed before treating such rows as runtime
evidence.

### 5.1 Child identity and supervision

[`lmx_child`](dev/l2src_sandbox/lmx_child.h.lm1) creates a child in its own
arena and records a parent-turn reservation. At a successful end boundary,
the child's physical Thread reference joins the parent's **single** dynamic
children List in the graph; an optional application result cell may receive
the Message address. At a failed boundary, the unpublished reservation and
child arena are dropped, leaving that optional cell untouched. The parent
up-link is written on the parent's lane when the child is published. Neither
an integer child slot nor a manager-side membership queue is an independent
source of family composition.

The parent normally stops and settles direct children only. Each child
propagates the same rule to its own children; a parent does not scan all
descendants. A finished child's arena can be attached to the parent only
when its Message is handoff-safe and no native user retains it. Physical
references remain stable across attach. The service registry is a route
index for finding destinations; it is **not** an alternative children
collection. A scheduler traverses the graph's one children List rather than
constructing a second family tree.

R0 is an ordinary Thread beneath a local stub parent that stands in for a
future WorldWideMix parent. That supervision edge is not `Lmx.parent`.
[`lmx_root`](dev/l2src_sandbox/lmx_root.h.lm1) opens R0, advances its turn
and stepped cycles, creates top-level children through R0, and closes its
owned runtime. The host has an overall close watchdog; partial close is not
an ordinary successful result. The intended close cascade remains the
ordinary direct-child protocol, not a special R0 graph algorithm.

## 6. Mail, ownership transfer, and collection

Each Thread owns an [`LmxPost`](dev/l2src_sandbox/lmx_post.h.lm1). It has
three roles: owner-local `staged` entries prepared during the turn;
owner-local published `outbox`; and synchronized `inbox` awaiting the
receiver. The one simplified monitor protects admission, take, and count on
the incoming queue only. It is reentrant for the same OS thread and provides
no wait/notify condition queue. It does not widen into graph, arena,
scheduler, or Message-flag synchronization.

Inbox is a growable FIFO ring, initially two entries. A producer admits the
inseparable pair `[target, source_arena]` without attaching the donor arena
to the receiver. The receiver owner performs attach at `take`; if that
operation refuses, the **same pair** stays queued. Ring growth preserves
unread FIFO order; its private capacity/growth has no effect on base Array
semantics. `staged` and `outbox` use owner-local links, not a second Message
envelope. GC obtains a monitor-consistent unread-target snapshot through
mail's API rather than peeking into ring backing.

Closing a child must close its mailbox before unregistration from the route
service, removal from the parent's List, or arena attach/release. That order
keeps a refused donor attach or close reachable for retry. Transfer of a
completed child arena and receipt of a transferred letter are related uses
of `lmx_arena_attach`, but they have different publication boundaries; do
not replace either with a speculative second ownership registry.

[`lmx_gc`](dev/l2src_sandbox/lmx_gc.h.lm1) uses an arena generation and
per-chunk mark stamps. It traverses Message/Thread state, graph roots,
mail-visible targets, and the single graph children List, then sweeps
unreached chunks. The granularity is the storage chunk, not a per-value
refcount. Sealed retained ranges are excluded from normal sweep by their
explicit storage policy. A simple arena refuses collection. Later module
unload rules remain unresolved; a permanent global store should not be
inferred from that gap.

## 7. Copy and merge

[`lmx_graph_copy_owned`](dev/l2src_sandbox/lmx_graph_copy_owned.h.lm1)
copies the used graph closure into a destination arena. One source-to-copy
map preserves sharing and remaps structural parents and internal references;
method records and immutable shared descriptors remain physical terminals.
[`lmx_merge_owned`](dev/l2src_sandbox/lmx_merge_owned.h.lm1) composes
operands through the same ownership discipline and can use arena mark/revert
to avoid leaving a half-built result. An `independent: const: immutable`
branch is retained as the same physical reference with its original owner,
not copied into an unrelated arena. That branch's profile and range owner
must remain classifiable wherever the value is used.

Copy/merge is also the construction route for a new typed Structure, not a
mere pointer assignment. Conversely, assigning an already constructed
Structure reference to an already typed variable rebinds a physical
reference after admission; it does not allocate a C by-value Structure.
Do not infer merge success from a wrapper's process exit alone: a generated
program path has been observed to return merge status `70` while its outer
native entry discards that status and the harness still records exit zero.

## 8. Translation and verification surfaces

The live [`l2trans.lm1`](dev/l2src_sandbox/l2trans.lm1) parses a unit, resolves
heads/types/calls, checks the body, then emits L1. Relevant semantic sites
include `l2_parse_unit`, `l2_check_primary`, `l2_check_body`,
`l2_head_is_call`, `l2_actual_count`, `l2_admit_implements`,
`l2_admit_consumer_uses`, `l2_emit_body`, and `l2_emit_unit`. Surface-form
normalization (`l2_colon_*`) belongs to the live development translator. A method-call correction
must reach argument count, check/admission, and emission through one common
argument sequence, not one more form-specific branch. A general
expression-statement result can use a typed discard destination (`l2_tN`).

The parser emits graph-like syntax nodes, including anonymous argument
containers and headless expression nodes. It is not permitted to choose
different semantics merely because the user wrote parentheses, a short
colon, or a vertical body. Source-level `()` is not automatically an
existing empty Structure variable: head resolution and semantic role still
matter. Receiver-operators such as `fn:` are language operators, not user
callables. Operator names are reserved; a user method named `length` cannot
shadow the `length` receiver. `sizeof:` is a proposed operator in that
class, not a currently implemented arbitrary method or a special `c.sizeof`
entity.

[`tools/build_l2src.ps1`](tools/build_l2src.ps1) uses the pinned L1
translator to generate and compile the live runtime units, then executes
their selftests. [`tools/l2_harness.ps1`](tools/l2_harness.ps1) builds the
development L2 translator and exercises fixtures through L2 → L1 → C99;
its rows include **expected translator refusals**, library-link checks,
and program runs. These categories cannot be reported as equivalent runtime
proof. [`tools/run_l3_selftest.py`](tools/run_l3_selftest.py) checks the L3
interpreter path. [`tools/run_self_build.ps1`](tools/run_self_build.ps1)
currently supplies an L1 self-build witness, not full L2 self-build.
[`tools/check_docs.py`](tools/check_docs.py) and `git diff --check` check
documentation invariants and patch hygiene; neither proves semantics.

Every kernel change should report the exact HEAD, source tree, owned files,
test command, test class, process status, observed graph/result, and any
remaining mismatch. A generated C call line is useful evidence for a
lowering claim but cannot substitute for execution. A successful compile or
link cannot substitute for a function actually being called. Distinguish
an implementation's current behavior, an accepted rule, and a planned fix.

## 9. Known incomplete boundaries (at this snapshot)

| Boundary | Current evidence / consequence | Owner of the next decision |
| --- | --- | --- |
| P0 argument-container normal form | P0 goldens distinguish `f()` from `f: ()`; native/interpreter add CALL-only unwrapping, leaving other roles inconsistent. | Normalize the sole whole-sequence anonymous Structure once in P0 (empty and nonempty), then remove redundant consumer unwrapping; see `next_parser_fix.md`. |
| Structural declaration | `mystruct: ()` may fail native lowering although the universal absent-target/Structure rule requires declaration. | Resolve declaration from the same normalized P0 Structure-body as `mystruct()`; no declaration-only wrapper restoration. |
| Repeated fields and sticky addresses | Current own-slot paths do not fully preserve `[N]field`, selector publication, and universal sticky `@local`. | One occurrence-to-physical-path algorithm shared by native and interpreter. |
| Admission | Coarse address compatibility and some fast paths are not the complete Consumer/uses plus runtime-test model or full directed conversion table. | Urgent kernel fixes first; then bounded port from the prior implementation. |
| Raw C door | Name-specific `c.puts`/`c.array`/`c.sizeof` handling and header-derived C-name machinery remain cleanup debt. | One raw `c.*` door; separately introduce ordinary `sizeof:` if needed. |
| Native entry result | The adapter can lose a failing entry return and produce false-green program exits. | Make the body result observable before relying on generated runtime rows. |
| Range/mail documentation | `LmxRange.owner` and current `LmxPost.inbox_capacity` are more specific than the corresponding brief specification descriptions. | Reconcile the paired L1/L2 specifications with the accepted ABI. |
| Full self-build | Live runtime largely `.lm1`, partial `.lm2` ports, L1 self-build only; L2 library-link rows are not execution proof. | Close the clean-kernel gate, port supported L1 to L2, then prove L2 and L3+L2 self-build. |

The roadmap is deliberately ordered: stabilize the universal semantics and
clean the kernel, make a precise green checkpoint, migrate the supported L1
implementation to L2, establish full L2 self-build, then progress mainly in
L3 with explicit remaining L2 insertions. Only after the kernel and
self-build evidence are trustworthy should `myxa_manager` be assembled as a
reproducible application with one entrypoint. The detailed ticket order and
acceptance checks remain in [next_core_tasks.md](next_core_tasks.md), not in
this architectural description.

## 10. Source map

| Concern | Primary live files |
| --- | --- |
| Physical graph, ranges, pools, Array/METHOD/callable records | [`lmx.h.lm1`](dev/l2src_sandbox/lmx.h.lm1), [`lmx_pool.h.lm1`](dev/l2src_sandbox/lmx_pool.h.lm1) |
| Arena, blocks, reference slots, collection | [`lmx_arena.h.lm1`](dev/l2src_sandbox/lmx_arena.h.lm1), [`lmx_arena_blocks.h.lm1`](dev/l2src_sandbox/lmx_arena_blocks.h.lm1), [`lmx_arena_refs.h.lm1`](dev/l2src_sandbox/lmx_arena_refs.h.lm1), [`lmx_gc.h.lm1`](dev/l2src_sandbox/lmx_gc.h.lm1) |
| Call and activation | [`lmx_call.h.lm1`](dev/l2src_sandbox/lmx_call.h.lm1), [`lmx_plan.h.lm1`](dev/l2src_sandbox/lmx_plan.h.lm1), [`lmx_own.h.lm1`](dev/l2src_sandbox/lmx_own.h.lm1), [`lmx_dirty.h.lm1`](dev/l2src_sandbox/lmx_dirty.h.lm1), [`lmx_walk.h.lm1`](dev/l2src_sandbox/lmx_walk.h.lm1) |
| Message, Thread, turn and root | [`lmx_message.h.lm1`](dev/l2src_sandbox/lmx_message.h.lm1), [`lmx_thread.h.lm1`](dev/l2src_sandbox/lmx_thread.h.lm1), [`lmx_turn.lm1`](dev/l2src_sandbox/lmx_turn.lm1), [`lmx_root.h.lm1`](dev/l2src_sandbox/lmx_root.h.lm1) |
| Mail, children, scheduling, route | [`lmx_post.h.lm1`](dev/l2src_sandbox/lmx_post.h.lm1), [`lmx_child.h.lm1`](dev/l2src_sandbox/lmx_child.h.lm1), [`lmx_list_owned.h.lm1`](dev/l2src_sandbox/lmx_list_owned.h.lm1), [`lmx_manager.h.lm1`](dev/l2src_sandbox/lmx_manager.h.lm1), [`lmx_service.h.lm1`](dev/l2src_sandbox/lmx_service.h.lm1) |
| Copy, merge, admission | [`lmx_graph_copy_owned.h.lm1`](dev/l2src_sandbox/lmx_graph_copy_owned.h.lm1), [`lmx_merge_owned.h.lm1`](dev/l2src_sandbox/lmx_merge_owned.h.lm1), [`lmx_implements.h.lm1`](dev/l2src_sandbox/lmx_implements.h.lm1) |
| L2 compiler and cross-level tests | [`l2trans.lm1`](dev/l2src_sandbox/l2trans.lm1), [`tools/l2_harness.ps1`](tools/l2_harness.ps1), [`tools/build_l2src.ps1`](tools/build_l2src.ps1), [`tools/run_l3_selftest.py`](tools/run_l3_selftest.py) |

Use the source map to locate a mechanism, not as an ownership grant. Check
`OWNED_BY`/`LOCKED` markers and other agents' in-flight work before editing
any shared implementation file.
