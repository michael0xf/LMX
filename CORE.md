# LMX core architecture

This is a compact kernel map, not a second language specification or a
checkpoint diary. Normative sources are the paired
[L2 specification](docs/L2_spec_en.md), [L3 semantics](docs/LMX_semantics.en.md),
[grammar](docs/LMX_grammar.en.md), and
[L1 contract](docs/L1_spec_en.md). The active migration order is
[next_core_tasks_v3.md](next_core_tasks_v3.md); older dependency evidence
remains in the [pinned v2 snapshot](https://github.com/michael0xf/LMX/blob/0e0a2978eb237e145e54715de805a88e65264ba4/next_core_tasks_v2.md). An intended invariant below
does not claim every current implementation path already satisfies it.

## 1. Engineering boundary

L3 is the graph-level language. L2 adds machine operations and C99
interoperability. L3 compiles by the same L2 path and its constructed graph
can also be interpreted; L2 machine operations cannot be interpreted as L3.
L1 is generated intermediate code before C99, not the language of the
target self-build. The goal is L3 self-build with explicit L2 insertions,
then unified Message mail; see [v3 §§3, 8, 8a](next_core_tasks_v3.md).

A receiver and its argument Structure are formed by one algorithm before
classifying the head as declaration, assignment, call, or operation. One
expression resolver applies in every consuming position. A consumer checks
the resulting value; it does not secretly suppress or introduce a call.
There is one namespace and no runtime name table. Names are used for
translation and `toLmx`. A contradictory rule or need for a spelling-specific
branch is an author question, not a license for a shim.

## 2. Physical graph and identity

The universal Structure record has a fixed number of slots after construction:

```c
typedef struct { size_t size; void *data; } VoidArray;
typedef struct Lmx { VoidArray array; struct Lmx *parent; LmxEntry native; } Lmx;
```

`array` holds ordered `void *` child slots; `array.size` is their count,
not growable capacity. A slot's address, its stored pointer, and its
referent are distinct. `Lmx.parent` is the structural parent, not
`Thread.parent`. `Lmx.native` is a direct native-body entry or zero for
walking the stored L3 body; it is neither a field nor a method descriptor.
The one source graph retains declarations, values, operators, and nesting.
Execution changes declared values but does not replace the program with
a second data graph or AST.

Physical kind comes from arena ranges; model suitability comes from
`implements`. Ordinary and immutable Structures use distinct pools.
An already-created ordinary Structure cannot become immutable in place.
Primitive cells, reference cells, Array descriptors, child backing, and
Structure headers each have their physical access contract. Models do not
create per-model C types or per-cell runtime tags.

### 2.1 Address ranges and typed service arrays

The arena indexes stable half-open ranges with a pool supplying exact type,
stride, storage policy, and owner. Pools add chunks without moving cells.
Classification is not `implements`. `mark/revert` supports all-or-nothing
construction; `attach` transfers ownership without changing addresses.
A Message owns an arena. Another arena may explicitly import a retained
range but may not silently extend a reference's lifetime.
See [L2 §§3–6](docs/L2_spec_en.md#type-by-range).

### 2.2 The base Array and the separate List

`VoidArray` has exactly `size` elements and no reserve/resize contract.
Growable `List`/`DynamicArray` is separate; its backing can move and
therefore cannot store addressable `Lmx` field slots. Adjacent `a[i][j]`
indexes a rectangular Array; `a[i]\[j]` follows a reference to another
Array. The old `node\[N]field` selector is removed, not a second field
namespace.

## 3. Callable graph representation and activation

An executable method is an ordinary Structure occurrence: its signature
and body remain in the graph, without a permanent companion data graph.
Execution selects code and data positions and uses a machine activation
for arguments, locals, and return. Roles are positional, not intrinsic
Structure labels. The selected occurrence's `native` word chooses native
entry or L3 walker. Both paths must implement the same operation. If code
and data layouts differ, a prepared `implements` address map governs used
fields; equal slot numbers are not assumed.

`node` names the lexical parent and `self` the active Structure under the
call ABI. Transport distinguishes absent arguments from present null
references. The actual selected body determines hidden inputs and
`throws`; a slot model or `native != 0` cannot substitute for that
preparation. See [L2 §§10–11](docs/L2_spec_en.md#own) and
[v3 M2](next_core_tasks_v3.md).

### 3.1 Body fields, occurrences, and own-state

A name has one physical place in a containing Structure. Its first
declaration establishes the place; repeating a declaration-form assigns
rather than making another same-name occurrence. Assignment never appends
a slot. A nested Structure may have a field of the same name according
to lexical resolution. The v3 migration must reconcile parser, translator,
native path, walker, and tests. Old `[N]field` fixtures do not authorize
duplicate slots.

`@x` addresses the real stored cell, not an evaluation temporary or ABI
box: for a Structure/Array reference, the graph's `void *` slot; for a
primitive, its typed cell. Pointer depth is preserved. Native access to a
graph slot follows its actual C99 `void *` storage, not aliasing through
`Lmx **`. The general `\` operator and expression precedence are not
specialized for function pointers. See [L2 §18](docs/L2_spec_en.md#lowlevel-address).

## 4. Declaration, assignment, call, and admission

In accepted v3 rules a bare resolved atom reads a value/address, not a
nullary call. A method or method pointer uses an explicit call form. An
ordinary Structure executes through `call: A`; `A()` and `A: ()` use
the empty-Structure declaration/assignment route. Do not reclassify a
failed call as another operation.

M3 first normalizes legacy flat declarations to name-first order. N1–N6
retain the composed form with the place in the outer head (`i: int: 5`,
`ptr: @: Model: 0`) and also admit a two-field form for selected value/type
receivers: `int: i 5`, `@: ptr 0`, `@: ptr Model`, and
`@: ptr Model: 0`. In that form the first field names the place without
invoking it; the second supplies a value or requirement under the receiver's
contract. `@: ptr Model: Other` has two fields, not a special parse of
`Model: Other`: the nested expression is consumed without thereby writing
to `Model`. Existing three-field `@: ptr Model 0` is tracked separately by
M3; adding the two-field form does not by itself remove it. Initial `@: ptr` or `@: ptr 0` creates a void
reference; a later write does not retroactively make its declaration
Model-constrained. Initializers, assignments, calls, and reference depth
use the general receiver–arguments model, not a special parse for `@`,
`int`, or a method name; each receiver still owns its argument contract.
Method-created callables and ordinary named
Structures retain their different contracts. Generated L1 is migrated
after L2/L3; see [v3 M1–M4 and N1–N6](next_core_tasks_v3.md).

`implements` checks the actual Consumer's explicitly required accesses;
without a Consumer, full suitability is checked. The accepted address map
must apply to reads, writes, captures, and merge. User-authored behavioral
tests are separate; no system re-runs every possible test after each
mutation. Failed admission must not partly write the destination. See
[L3 semantics](docs/LMX_semantics.en.md#descriptions) and
[v3 K01–K12](next_core_tasks_v3.md).

## 5. Message, Thread, and one turn

`LmxMsg` is the closed record `{running, success, handoff_ready, graph}`.
Its `graph` is the language root, not scheduler settings, mailbox state,
or children. An executable `Thread` begins with this Message record and
owns mail, scheduling, and the sole `Thread.children` List. The equal
address of Thread and its Message prefix does not turn a standalone
Message into a Thread.

One executor runs a turn for a Message identity. Successful end-turn
publishes prepared mail and children; failed end-turn discards unpublished
work, not earlier graph mutations. `running = 0` requests stop;
`success = 1` suffices for stop at the boundary. Dispatch is per selected
Structure's `native` word, not a Thread-wide mode.

### 5.1 Child identity and supervision

`Thread.parent` and `Thread.children` define Message supervision, not
`Lmx.parent`. R0 is an ordinary Thread under a host scaffold: launch data
and settings belong to the scaffold and are passed explicitly rather than
added to R0's source graph. Child reservations become visible at the
parent's successful boundary. A parent settles direct children and each
child propagates the same rule.

## 6. Mail, ownership transfer, and collection

Each Thread has one `LmxPost`. `post`, `sendMessage`, and
`receiveMessage` must converge on this transport, not create a second
mailbox. The inbox FIFO holds an inseparable target/donor-arena pair.
The receiver attaches the donor on take; a refused attach preserves the
pair. Owner-local staging/outbox and the publication boundary remain
distinct from the inbox monitor. The unified language API is post-self-build
[v3 §8a](next_core_tasks_v3.md).

Collection follows live Message/Thread state, graph, mail targets, and
the one children List. Its ownership unit is an arena chunk.
An `independent: immutable` branch retained by another Message stays in
its owner's arena until that arena is destroyed, even without `const`.
Before `adopt: msg newParent` changes Message parent, owners of used
retained branches must remain on the new ancestor chain; refusal preserves
the hierarchy. Separate `independent: msg newParent` prepares this
particular adoption by copying only obstructing branches into `msg`'s
arena without adopting. These concern Message ancestry, not lexical
parents.

## 7. Copy and merge

`merge` constructs a new self-contained used graph closure in the
destination arena. One source→copy map preserves sharing and cycles,
redirects internal references and structural parents, and copies executable
operation records. A reference is like a directory link: redirect it to
the corresponding new target, do not manufacture a third instance.
Only qualified `independent: immutable` branches may retain old
address and owner, subject to §6. A dangling source-arena address is a
defect, not a merge mode.

An unchanged `native` entry is reusable only when its body and used
address/type contract still apply. Different layouts need the accepted
`implements` map or a native form for the result. Copy, merge, and
Message construction share ownership rules.
See [L2 §13](docs/L2_spec_en.md#copy-merge).

## 8. Translation and verification surfaces

The active development tree is `dev/l2src_sandbox/`. The L2 translator
forms the common expression/receiver model, resolves it, checks admission,
then emits generated L1. Parser normalization does not itself prove
head resolution. Expected rejection, link, reached execution, and
self-build generation are distinct evidence classes.

The [v3 plan](next_core_tasks_v3.md) orders the general migrations,
accepted code/data work, complete kernel gate, L3+L2 self-build, and
then unified mail. Tests must record
actual source bytes and reached result, not only zero exit. The goal is
two genuine self-replacements from supported L3/L2 sources with L1 only
generated between them and C99. Current L1 self-build does not suffice.

## 9. Known incomplete boundaries (at this snapshot)

The active dependencies are in [v3](next_core_tasks_v3.md); historical
tests and debt records remain in [pinned v2](https://github.com/michael0xf/LMX/blob/0e0a2978eb237e145e54715de805a88e65264ba4/next_core_tasks_v2.md) and
[defects](steps/defects.md). Same-name assignment, explicit calls,
pointer/address parity, cross-arena copy, admission maps,
immutable-owner checks, native/walker parity, and both self-build
generations need end-to-end evidence. Do not infer completion here.

The next-generation method layout and explicit `call: code data` are
**accepted implementation work**, not merely research. The target method
Structure has addressable `args`, result description, `var`, and `body`;
`var` is a separate argument before the body and after the result type
where present. Its explicit fields and eligible missing body fields are
settled before constructing the Structure, without executing the body or
changing the established initialization moment. This automatic layout
belongs to that method's specific body and `var`, not to arbitrary call
data. An ordinary named Structure may instead declare an explicit `var`
child anywhere among its fields; unlike method `var`, it receives no
automatic fields from the body. The general `call: code data` receives
two Structures and admits fields required by `code` against the supplied
`data` before execution. Thus `call: named named\var` passes the declared
data through a prepared code-to-data address map. Only after this general
path is implemented does unary `call: code` select the actual code's `var`
as data. With no `var`, it may pass code itself as data if the body does
not write local data fields; otherwise it refuses. Activation-only writes
to free inputs do not trigger that refusal. Explicit `call: code code`
passes code itself without looking for `var` and remains allowed but less
clear. Because `code` may be a reference to any suitable Structure, `call`
never adds fields to `data`. External values resolve
during execution and do not populate namesake data fields by coincidence;
an activation may change its working `k` without creating `code\k`.
External fields change only through an explicit path such as `node\k`.
No runtime name table or second graph is introduced.

This is a target contract, **not** a claim that the current translator,
walker, or physical method ABI already implements it. `Lmx` slots stay
fixed: determine all slots before allocation; a different `merge` result
gets a new allocation, not an in-place extension. Native reuse requires
proof of the used address/type and code→data contract, not only unchanged
body text. Remaining details are worked out in the accepted stage using
[the design record](steps/next_generation_model_20261014.md) and
[v3](next_core_tasks_v3.md), with contradictions returned to the author
before a one-off implementation. No second data graph is introduced.

## 10. Source map

| Concern | Live entry points |
| --- | --- |
| Graph, pools, arena | [`lmx.h.lm1`](dev/l2src_sandbox/lmx.h.lm1), [`lmx_pool.h.lm1`](dev/l2src_sandbox/lmx_pool.h.lm1), [`lmx_arena.h.lm1`](dev/l2src_sandbox/lmx_arena.h.lm1) |
| Call and walker | [`lmx_call.h.lm1`](dev/l2src_sandbox/lmx_call.h.lm1), [`lmx_walk.h.lm1`](dev/l2src_sandbox/lmx_walk.h.lm1) |
| Message, Thread, turn, root | [`lmx_message.h.lm1`](dev/l2src_sandbox/lmx_message.h.lm1), [`lmx_thread.h.lm1`](dev/l2src_sandbox/lmx_thread.h.lm1), [`lmx_turn.lm1`](dev/l2src_sandbox/lmx_turn.lm1), [`lmx_root.h.lm1`](dev/l2src_sandbox/lmx_root.h.lm1) |
| Mail, children, collection | [`lmx_post.h.lm1`](dev/l2src_sandbox/lmx_post.h.lm1), [`lmx_child.h.lm1`](dev/l2src_sandbox/lmx_child.h.lm1), [`lmx_gc.h.lm1`](dev/l2src_sandbox/lmx_gc.h.lm1) |
| Copy, merge, admission | [`lmx_graph_copy_owned.h.lm1`](dev/l2src_sandbox/lmx_graph_copy_owned.h.lm1), [`lmx_merge_owned.h.lm1`](dev/l2src_sandbox/lmx_merge_owned.h.lm1), [`lmx_implements.h.lm1`](dev/l2src_sandbox/lmx_implements.h.lm1) |
| Translator and gates | [`l2trans.lm1`](dev/l2src_sandbox/l2trans.lm1), [`build_l2src.ps1`](tools/build_l2src.ps1), [`l2_harness.ps1`](tools/l2_harness.ps1), [`run_l3_selftest.py`](tools/run_l3_selftest.py) |

This map locates a mechanism; it grants no write ownership. Check
`OWNED_BY`/`LOCKED` markers and the active writer before editing code.
