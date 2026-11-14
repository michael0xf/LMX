# L2 Specification

L2 defines the kernel mechanisms and machine operations. L3 semantics are in the [LMX specification](LMX_semantics.en.md), syntax in the [grammar](LMX_grammar.en.md), and C99 lowering in [L1](L1_spec_en.md). This document does not restate head resolution, declaration, or call rules. Implementation status belongs to the [notes](implementation-notes.en.md).

<a id="scope"></a>
## 1. Scope

The target chain is L3 with L2 insertions → generated L1 → C99. L1 is an intermediate language. The interpreter executes the stored L3 graph; L2 operations require native lowering.

<a id="lmx"></a>
## 2. `Lmx` Structure

Graph objects share a flat `Lmx` with fields ordered `parent`, `native`, `length`, `storage`: `@: parent Lmx`, `LmxEntry: native`, `size_t: length`, `@: storage void`. `length` is the element count and `storage` the address of their storage; the target record has no intermediate `array: VoidArray` field. A language Array retains this base, structural parent/native and fixed typed storage. A numeric Array stores T-elements directly at storage; an ordinary Structure and Array<@> store `void *` elements. The header's address range supplies the type, not the spelling `void *storage`. A reference points to the beginning of Lmx. This is the approved target of 2026-11-13; the generator's current nested record and the remaining migration are recorded in [implementation status](implementation-notes.en.md#l2-status).

An ordinary Structure and an untyped-pointer Array<@> are fully interchangeable for the same contents: index, length, named access when names exist, admission, copying, execution, `typeof` and descriptor access follow the same rules. Equal C layout without those operations is insufficient. Numeric Arrays retain T-storage, and growable List remains separate. The header is not part of the element sequence: `S[i]` selects from storage and `length(S)` reads length.

`parent` describes structural nesting, not Message parentage. For an Array created at an `arr` field, its parent is the graph occurrence representing that field; for a Structure constructed as an owned Array element, its parent is the Array. Storing a reference to an existing Structure in an element does not reparent that referent. Likewise a mention of the name of a known Structure is not expanded -- neither by the parser nor when the clean graph is built: the tree holds an atom, a pointer to that Structure, while that Structure's `parent`, that is its place in the tree, does not change, and no subtree arises under the Structure that mentions it (the author's answers of 2026-11-11, [journal](../LMX_blog/2026-11-11.md#known-name-not-expanded), [L3](LMX_semantics.en.md#colon-declares)). Lexical visibility follows the place of construction in the tree -- the structural `parent` -- not the position of the declaring line: visibility in data runs in both directions ([L3](LMX_semantics.en.md#declaration-visibility)); no additional hidden context is created. `native` selects a native entry; zero walks the stored body. A graph object has no stored name, model tag, or extra execution-state fields. Structure field count and Array element count are fixed at construction; addressable cells do not move. Primitive elements remain typed cells and need no individual `parent` field.

<a id="interpretable-tree"></a>
### 2.1. Interpretable tree

A resolved receiver selects the typed pool when its result is constructed; similarity to fields already declared in `data` does not turn their owner into that receiver's result. In particular, only a Structure produced by executing `fn` enters the pool of `fn` results, not an arbitrary Structure with similar parts in `data`.

The stored graph is the program: declarations, values, operators, and nested bodies initially follow source order; later writes change this same graph. Native lowering does not replace it with a second AST or data graph. A primitive already has a typed arena cell; it needs no redundant `leaf` or Structure wrapper. Atoms still part of the current program are retained.

The walker executes the current suitable tree, including one constructed or modified at runtime: editing data later supplied as `code` is code construction. This requires no prior translation, stored translator-prepared result, hidden source copy, or prepared flag. Traversing the current graph and ordinarily resolving its operations is execution, not prohibited reparsing of source text. Common receiver, admission, and address-map rules remain; they allow different working-frame forms over one stored graph. This is the rule, not a claim that the current kernel fully supports runtime code construction. [Author clarification, 2026-10-23](../LMX_blog/2026-10-23.md).

Entity names live only in an external table. The walker may obtain the written head's name by its address to determine the head's role; this is not textual variable lookup for field access. The translator consumes the same constructed Lmx graph, while completed `native` needs no name for invocation. Comments play no dispatch role. `toLmx` emits the current graph composition and order: an overwritten operator is not reconstructed from source or a hidden copy. Launch data, call status, and Thread membership are not appended to the program graph.

References stored as data form a graph and may produce cycles. Structural `parent` forms a tree. Address classification determines a value's kind; the slot address and address stored in that slot are distinct.

<a id="get-descriptor"></a>
### 2.2. descriptor and actual header fields

The receiver has variants with S and with no argument: `descriptor()` / `descriptor:` equal
`descriptor(data)` for the current launch's data, including inside nested control bodies.
Code requires an explicit argument. Both variants return the selected Structure's field addresses;
a same-headed data form remains an ordinary Structure.

`descriptor: S` is an ordinary receiver. Its result d is an ordinary Structure with four named fields holding the addresses of the fields of live S:

```text
(
    @@: parent Lmx
    @: native LmxEntry
    @: length size_t
    @@: storage void
)
```

The machine types of the values are `Lmx **`, `LmxEntry *`, `size_t *` and `void **`, respectively. LmxEntry is already a function pointer; its cell's address keeps the real type without casting to `void **`. `\(d\native) := 0` addresses S.native; after standard publication of zero the next call selects the walker. `d\native := 0` changes only the ordinary pointer field in d. Reading an earlier address observes S's current field; obtaining another descriptor reaches the same physical cells. There is no header copy, write-back, proxy or separate registry.

Pointer depth is any finite depth: taking an address adds one level, dereferencing removes one. Pointer depth and finite Array rank are independent and use general mechanisms. S.parent's address can numerically equal S: typed dereferencing of Lmx ** accesses the actual field rather than classifying it as a second independent Lmx. Qualification, explicit writes and lifetime retain their ordinary rules; obtaining a descriptor does not extend S's life. Ordinary `S\parent`/`S\native`/`S\length`/`S\storage` paths select user fields, with no header exception. [Author decision](../LMX_blog/2026-11-13-get-descriptor.md), [open M13 implementation](../next_core_tasks_v3.md#flat-lmx-descriptor).

<a id="header-receivers"></a>
### 2.3. Reading the header through receivers

`parent(S)`, `native(S)`, `length(S)` and `storage(S)` return the values of S.parent (`Lmx *`),
S.native (`LmxEntry`), S.length (`size_t`) and S.storage (`void *`), respectively. `parent()`, `native()`, `length()` and `storage()`
select the current launch's `data`, equivalent to the explicit argument `data`. Selecting `code`
requires an explicit argument. A root's parent is 0. Length counts elements, excluding header fields.
`native(S)` returns 0 when no native entry exists; reading the entry does not invoke it.

These are ordinary non-declaring receivers: they execute in `code`, while a same-headed form in
`data` remains a user Structure reached by ordinary paths and occurrence indices. A bare atom
does not invoke a receiver. Parsing is shared; reading a value neither constructs descriptor
nor allocates an object. Separately, `descriptor` returns addresses of the
`parent/native/length/storage` cells for explicit writes.

Renaming physical fields `size` → `length`, `data` → `storage` does not change the Structure arguments
`data` and `code` of a `call` launch. `node` keeps the current activation's existing contract and ABI;
there is no new `node(S)` or hidden Lmx field. [Semantics and forms](LMX_semantics.en.md#header-receivers),
[open implementation M13](../next_core_tasks_v3.md#flat-lmx-descriptor).

<a id="type-by-range"></a>
## 3. Type by address range

Derived graph objects preserve the common `Lmx` contract. The pool and range identify the physical kind selected at construction and, for an Array, its element type. This classifies an address; it is not a stored name or opcode in the graph, nor a separate user-defined type for every Structure model. The old layout in which `Lmx` contains `VoidArray` remains transitional, not the template for the new Array variants.

An arena classifies an address through a registered half-open `LmxRange` interval and its owning pool. A cell has no in-band type tag. Ordinary Structures and graph Arrays share the `Lmx` base while ranges distinguish storage shape and element type; user models do not generate one C type or pool apiece. Primitive, reference, graph-object, and backing pools differ by physical access contract. Typed arena arrays are storage, not separate language Arrays. Ordinary and `immutable` Structures are allocated in separate pools; an already published ordinary Structure cannot become `immutable` in place. `implements`, not physical type, establishes model compatibility.

Every primitive type T has a distinct type “T without initialization”, identified by its address region.
A declaration without an initializer has its own pre-existing cell of T and an internal pointer to that cell:

| Declaration | How the Structure field reaches the value |
|---|---|
| `int: x` | Field → internal `uninit:int` pointer → the `int` cell of `x` |
| `int: x 0` | Field → the `int` cell of `x`, initially 0 |

Here a Structure field is an address-holding cell, called a “slot” in the kernel specification.
Assignment changes only the value in the existing cell of T. Even on the first write, neither the field nor
its internal pointer is replaced or redirected; the cell's address and physical type remain unchanged too.
For `int: x`, the indirect path is the same before and after `x := 5`, and a previously taken `@x` addresses
that same cell. Internal storage does not make `x` a language pointer: its language type remains `int`.

`uninit:T` describes a declaration without an initializer, not a “never written yet” flag.
The earlier explanation about redirecting the field on its first write was superseded by the
[author's later clarification of 2026-11-08](../LMX_blog/2026-11-08.md#uninit-pointer-preserved).
See [kernel specification §3.2](kernel-implementation.en.md#primitive-storage) for the representation.

<a id="pool"></a>
## 4. Typed pool

A pool issues fixed-stride cells and grows by adding chunks, without `realloc` of live cells. Each chunk registers an interval of the same type. An issued address stays stable until its ownership is released. The arena manages the range index.

In a graph Array, `void *storage` holds the backing address of the selected typed pool; it does not make the elements untyped. L2 obtains a pointer to the actual element type from that address for loads and stores; the arena range confirms that type, cell stride, and alignment. A pre-existing pool of `void *` slots cannot be read as an arbitrary `T` array merely by casting its pointer. Addressable graph-reference slots retain their own `void **` and stored-value conversion contract.

<a id="method-array"></a>
## 5. Native entry and Array

`LmxEntry` is the native-entry word, not a second method object. A graph Array carries the common `Lmx` base and exactly its fixed count of typed elements. It has no dynamic reserve and does not move published addressable cells. With `[]: arr (...)`, the Array value retains its graph position; a later form of data `MyLmxStructFromArray: arr` neither constructs another object nor reconstructs a Structure from bytes: under the general rule it declares a Structure `MyLmxStructFromArray` with the one atom `arr` -- a pointer to that same Array, immutable by name, and the `parent` of that Array does not change ([§2](#lmx), [L3](LMX_semantics.en.md#colon-declares)). A pointer variable to that same Array is declared by `@: p arr`; in code the form `MyLmxStructFromArray: arr` is a call of its head, not a declaration. A dynamic List is a separate type and contract; its movable backing is not used for addressable Structure or Array slots.

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

Execution uses the complete stored Structure. Native code and the walker must agree on working-field reads, writes, `dirty` state, and publication under [L3 §12](LMX_semantics.en.md#dynamic). A declared field has a graph storage place; assignment does not add a slot to an existing `Lmx`. Pointers to graph slots must remain valid. The `args/return/data/code` method layout is an approved v3 migration target; its physical ABI is not described here as already implemented.

<a id="call"></a>
## 11. Call

The selected code's `Lmx.native` chooses native entry or walker. A call receives `data` -- supplied explicitly, or `code` itself in the one-argument form -- the selected `code`, the actual arena, `node` as the callable occurrence's lexical parent, and prepared arguments. In a split call, `data` supplies state and `code` supplies the executable body. These roles neither prove code stability nor qualify the whole Structure as `immutable`. No prediction of write paths or aliases is performed; an actual code-place change clears its `native` through the shared write path. Unary `call: code` executes the code over itself as `data` (the author's decision of 2026-11-11, [the receivers `call` and `fncall`](LMX_semantics.en.md#call-receivers)); formerly it selected the code's child data block, and now it does not select it: the data is passed explicitly. The two-argument launch is written `call: data code` -- the data stands before the code everywhere (the author's answer of 2026-11-11, [journal](../LMX_blog/2026-11-11.md#data-before-code)); formerly it was written `call: code data`. In all receivers the arguments are named and are supplied by position or by name (with the operator `:=`): `call(data := D; code := C)`, `fncall(args := A; data := D; return := int; code := C)` (the executor's reading of the author's correction of 2026-11-11, [journal](../LMX_blog/2026-11-11.md#structure-call-by-name)). The role gives the reading of a written form too (the author's decision of 2026-11-11, [the roles `data` and `code`](LMX_semantics.en.md#data-code-roles)): in data a structural form declares a Structure and the declarations by receivers of places act, while assignments and code are not executed; in code every form is a call, and no Structure is declared there. In code a form whose head is an ordinary Structure launches it (before the decision of 2026-11-11 such a form was refused in code, and an ordinary Structure was executed only by the receiver `call`): `S()` is the same as `call(S, S)` (the Structure over itself), `S(D)` is the same as `call(D, S)` (the Structure over the given data); the argument is one and is named `data` -- the name by which code refers to the data of its own launch; `S(D)` and `S(data := D)` are one form; so are the short form `S: D` and the block form. It is a launch form of its own, not a form of a receiver: the receivers `call` and `fncall` remain the general mechanism. It is an error when the head names neither a callable nor a Structure (the author's decision of 2026-11-11, [journal](../LMX_blog/2026-11-11.md#structure-call-by-name); the executor's reading -- [answers](../LMX_blog/q/fable-self-answers-20261110.md), Р21). In data `S()` still declares an empty Structure `S`, and `S(D)` a Structure `S` with an atom `D`; nothing is called. An unnamed Structure in code is not a call: `(a b c) := myFn()` is a group assignment ([L3](LMX_semantics.en.md#data-code-roles), [journal](../LMX_blog/2026-11-11.md#unnamed-structure-not-call)). The special name of the explicit reference to the data of a launch, the part of a callable of the same name and the data block are called `data`, and the part with the executable forms and the argument of the receivers `fn`, `sub`, `catch` of the same name are called `code` (`var` and `body` until the decision of 2026-11-11); the admission `implements` is performed once, when the clean graph is built ([§14](#implements)). The translators execute these rules only in part: the clean graph reads the names `data` and `code` and the order `call: data code` since slice 354, executes sub-step 5а since slice 355 and, since slice 356, the launch of a Structure by name in the code of a method and in code over given data -- `S()`, `S(D)`, `S(data := D)` -- and a form whose head is a place holding a reference to an ordinary Structure everywhere, the root of a unit included, as well as the named supply of the arguments of `call` and `fncall`; in the root of a unit and in a Structure over itself it does not yet execute the role of code of a form with an ordinary Structure as its head by name (sub-step 5г); the rest -- sub-step 5в and the remainders of sub-steps 5б, 5д and 5е -- is not executed yet either, while the working frontend still reads the former names and order and does not execute the launch by name (step 8) ([plan](../next_core_tasks_v3.md#m11)). Explicit `call: code code` is the same form: the value is supplied as `data` under the general rule and tests Structure universality and code mutation for future on-the-fly compilation, rather than defining a special execution path. A Structure launched over itself -- `call: code`, the same as `call: code code`, and the root of a unit -- has no rules of its own: each of its forms is read in both roles by the general rules, and where they give no definite result it is an error (the author's answer of 2026-11-11, [journal](../LMX_blog/2026-11-11.md#self-launch-no-own-rules)). Therefore a form `S()` there is at once a declaration of one more `S` and a call: with `S` declared in the same Structure the name has two occurrences, does not answer without an index, and the call is refused, while with `S` declared outside, the form declares an empty `S` of its own, and that one is launched, not the outer one; there is no special rule, and the same Structure is launched by the receiver `call` (the executor's reading -- [answers](../LMX_blog/q/fable-self-answers-20261110.md), Р21). The receivers `fncall` and `call` receive the parts of a launch -- arguments, data, the description of the result, code -- explicitly; this is an addition to declarations and the ordinary call, and the interpreter launches `fn`, `sub` and `catch` through the same mechanism. The clean graph executes these forms since slice 353 (except `catch`, which it does not execute yet: that is the state of the implementation, not the norm), the working frontend not yet ([plan](../next_core_tasks_v3.md#m10)). For **any** admitted pair of Structures, field access and publication of already computed `dirty` values use one proven `implements` address map; equal ordinal positions are not assumed. A checkpoint stores the ready value into the selected `data` slot without re-evaluating the expression or repeating admission.

Entering `call`, including `call: code code`, does not invalidate `native`. Standard publication of an already admitted write clears `native` of code places linked to the changed cell. An explicit path, alias or dereference selects the address; the write updates the direct-access cache shared by all calls within one execution; frame-local working values and their dirty state remain separate. The physical slot write and removal of changed-code entries are atomic for the next or a recursive dispatch. A working value before publication, a refused write, and a call that does not change the graph leave `native` intact; an ordinary data-value change preserves the entry. The code-place link may belong to an enclosing Structure, not just the Structure containing the written slot. If an L2 body becomes incompatible with its old entry, a matching native implementation or refusal is required **before** publishing the change: the L3 walker does not execute L2. Do not retry a call on another engine after effects.

A declaration by a receiver of a place in `code`, including one written inside inline `if`/`for`, is a call of the receiver: a type check with an assignment into the prepared same-named place in the selected `data`; a repetition of such a declaration is the same check with an assignment and yields no second field, while a value without a declaration is written by `name := value` ([§21](#lowlevel-expression)). The declaration creates no new field in `code`. A structural form in `code`, including `name: ... end: name`, is a call of its head, neither a declaration nor a write into `data`; declarations of Structures are written in data, while the declarations `fn`, `sub`, `catch` stay in code too and keep their own receiver contracts (the author's decision of 2026-11-11, [the roles `data` and `code`](LMX_semantics.en.md#data-code-roles)). The `data` map considers root-level heads but not heads inside their initializers; the forms of calls and of control receivers in data are Structures too, named by their heads: paths such as `data\if` lead to them and `data\if\if` to nested ones, with an index when there are several. One source occurrence of a head permits `data\field`; two or more require zero-based `data\[N]field`: a repeated declaration in data is one more occurrence of the name, it neither replaces the former one nor writes into it, the first occurrence is not chosen automatically, and an access without an index is an error (the author's clarification of 2026-11-11, [journal](../LMX_blog/2026-11-11.md#repeat-is-check-and-assignment)). Nesting in `code` does not select another place. Arbitrary `data` is not auto-completed at a call: if a required place is absent or bare access is ambiguous, the admission of the call refuses ([§14](#implements)); the source form itself is not a translation error. Preparation of a method's `data` part allocates its fields in advance and is separate from this rule. Only an explicit `call`, the launch of a Structure by name (the same action) or a callable invocation, including `fn`, starts a new binding scope, where an own field may shadow an outer one. There is no shadowing within one callable; inline `if`/`for` are operators within the same activation, not new scopes, despite being Structures.

A null argument transport-cell address denotes absence; a present argument holding a null reference is still present. A number travels in storage of its declared width, an object reference through a canonical pointer-value cell. Callback status and returned value differ; the result contract distinguishes `void` from a present null reference.

<a id="native-structures"></a>
### 11.1. Ordinary Structure and common native code

A Structure C available to the translator and used as code receives native through the same body emitter
and frame entry/exit as methods. One C.native works with any admitted D through `call(D C)`, including different
field order; C need not be named, declared by fn/sub or used with data = code. Using S only as data
does not require its own native entry. Receiver native(S) reads an entry and does not compile S.

At launch, existing admission, the place map and the frame bind data; resolved addresses and typed
working values are reused. Dirty data and code are published at standard boundaries, after actual-argument
evaluation before control transfer, on specified exits and at yield.
Code publication removes affected entries before a new/recursive dispatch; an ordinary data write keeps them.
Clearing native neither replaces instructions of an active entry nor repeats effects. The walker uses
a prepared frame with equivalent continuation, including after publication and a nested call.
No artificial method, whole-graph copy, permanent versions or hot-patch/deoptimization is required.
A dynamically selected compiled C uses native; a suitable runtime body without an entry uses the walker.
This is the rule; implementation remains **OPEN** in [M14](../next_core_tasks_v3.md#native-structures).

One publication semantics does not require a universal assignment journal. Native determines writes
and their publication conditions statically where possible, without a lookup or allocation on every write
or a mandatory dynamic dirty flag. Dynamic places need only necessary local-change tracking in the frame
and direct-change tracking in the cache shared within one execution.
Optimization preserves computations, checks, effects, alias reads and the moment publication becomes observable.

<a id="direct-access-cache"></a>
A local working value belongs to its activation and is not automatically reloaded after a nested call.
The direct-access cache is shared by all calls within one execution, including native/walker transitions, and is transparent:
paths, indices and dereferences of one physical cell see its current shared value, including pending direct writes.
Local dirty publication also updates that state. The cache does not persist across independent executions.
Base p in p\x can be a local pointer; changing an intermediate reference requires establishing the final address
again instead of reusing a stale path. [Rule](LMX_semantics.en.md#direct-access-cache).

Ordinary non-declaring receiver `flush()`, with no arguments or result, first publishes the current frame's dirty
own local values into shared state in forward field order, then stores pending shared-cache writes into the graph
and continues execution. Other frames' locals are not affected.
It uses standard publication and code invalidation without a new
frame, exit, yield or Message publication. Nested if/loop bodies use that same frame. Successful publication
clears the corresponding dirty marks; repeating flush without changes writes nothing, reevaluates no
expressions/admission and reloads no local values. The shared cache is reconciled with published cells.
Bare atom does not invoke it; in data, `flush()` is an ordinary Structure.
Form `flush:` has the same contract. [Rule](LMX_semantics.en.md#flush-receiver-contract); M14 code remains OPEN.

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

The proven mapping from used fields of the receiving model to physical fields of the candidate for an admitted pair of Structures is data of the reception or traversal that established it (the author's decision of 2026-11-08 on service traversal tables, confirmed by Codex; [implementation specification §5.2](kernel-implementation.en.md#tables)): a reception holds its map for the duration of the operations it needs -- reads, writes, address taking, and direct publication of ready `dirty` values, including differing field order -- and the next traversal rebuilds it from the graph; the arena keeps no persistent store of mappings, and there is no separate map for `call` or `data`. The interface-checking part of `implements` is performed once for each candidate: at clean-graph construction if the candidate is known, or at run time if selected dynamically ([cases](../steps/implements-runtime-cases-20261111.md)). Graph construction does not execute `test`; for a dynamic candidate it is the second admission step ([the author's clarification of 2026-11-13](../LMX_blog/2026-11-13.md#implements-and-test-phases)). An assignment of primitives is not checked for admissibility at run time (the author's decision of 2026-11-11, [L3](LMX_semantics.en.md#data-code-roles); the rule speaks of the admission `implements`, not of conversion: the range check on receiving a number of another type, `u16(256)` into `u8`, remains at run time); the translators do not execute this rule yet ([plan](../next_core_tasks_v3.md#m11)). In data every declaring form is an occurrence of the name: a sole occurrence is addressed `s\field`, with two or more the name is addressed only with the index of an occurrence -- a repeated declaration neither replaces the former one nor writes into it ([L3](LMX_semantics.en.md#fields)); `s\[N]field` with zero-based `N` addresses the Nth occurrence of the name -- a form of the data that declares that name -- not an Array element. The map does not look up runtime names, copy the candidate, or waive a new Consumer's checks. Admission semantics and explicit tests are in [L3 §7](LMX_semantics.en.md#admission).

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

Field addresses returned by [descriptor](#get-descriptor) are actual typed places:
`Lmx **`, `LmxEntry *`, `size_t *`, `void **`. This differs from an ordinary graph-slot
address `void **`: it cannot arbitrarily be read as `Lmx **`, whereas S.parent itself
really has type `Lmx *`. Even if S.parent and S share a numeric address, an explicit
dereference reads the field by its type. Loading and writing are general for any finite
pointer depth, including references and function pointers. Explicit `S\field := value`
and dereferenced writes are not assignment through a bare Structure or function name
and are not prohibited by that rule.

M3 orders flat declarations as name followed by requirement/value. A place is declared by the `@:` form enumerating its arguments: `@: p 0`, `@: p Model`, `@: p Model 0`, `@: p Model Other`; the form with the place in the outer head (`ptr: @: Model: 0`), which N1–N6 admitted, is withdrawn by the author's decision of 2026-11-10 ([semantics](LMX_semantics.en.md#receiver-args-only)). The first field is the place-name atom and is not invoked; the other fields are consumed under the ordinary expression rule: the arguments of a receiver are read by the one general algorithm, as code. A requirement with a candidate is written flat, in three fields: `@: p Model Other`, and a null address `@: p Model 0`. The nested form `@: p Model: Other` does not write a requirement with a candidate: `Model: Other` among the arguments of a receiver is a call of `Model` (a consequence of the author's decision of 2026-11-11 on the reading of arguments, [the roles `data` and `code`](LMX_semantics.en.md#data-code-roles); the executor's reading -- [answers](../LMX_blog/q/fable-self-answers-20261110.md), О4); a launch form of a Structure at a place where a value is needed (an operand of an expression, an actual argument of a call, an initial value, an operand of `merge`) is an error: a launch has no result (the executor's reading, Р22, item 3; Р25, item 4). P0 does not single out these forms: parsing is common, while the `@:` contract assigns field roles. Initial `@: p` or `@: p 0` creates a void reference; a later address write does not retroactively add a requirement. Pointer depth `@ⁿ:` has no arbitrary numerical cap.

In `@: ptr method`, the `@` receiver comes first, while `ptr` and `method` are bare atoms: an atom is not a call. The form therefore assigns a reference to `ptr` under the `@` contract even when `ptr` already contains a callable; `ptr(args)` invokes it. Unary `@ptr` separately takes the reference cell's address. The detailed rules of the special name `data` and of these forms are in [L3](LMX_semantics.en.md#ordinary-var) and [method-reference assignment](LMX_semantics.en.md#method-reference-assignment).

Unary `@x` addresses the real value cell: for a graph Structure/Array, the `void *` slot holding a descriptor reference; for a primitive, its typed cell; for a formal or a hidden input from dynamic or lexical visibility, its own local activation cell. Bare `x` and `@x` refer to the same local variable; writing does not change the binding's source. The address of an external field is explicit, for example `@(node\x)`. Slot, slot address, and referent differ. Native access to a graph reference slot uses `void **` with conversion of its stored `void *`; dereferencing it as `Lmx **` violates C99. Do not take the address of a temporary cache or ABI carrier. By precedence, `@x\field` means `@(x\field)`.

Prefix `\p` follows a reference; `p\field` accesses either a graph field or an explicitly imported machine ABI according to `p`'s category. `@array[i]` addresses the actual backing element. L2 adds no automatic bounds check; checked access belongs to L3. Address operations neither bypass `const`/`immutable` nor extend target lifetime.

<a id="lowlevel-array"></a>
## 19. Raw C storage

A `c.*` token is an explicit C door. A language Array remains an `Lmx`-based graph object with typed elements; it does not become a raw C array. Conversion between them requires an explicit operation accounting for shape and lifetime. Typed arena arrays are internal storage, not another kind of language Array. L2 introduces no special `c.array` entity.

<a id="lowlevel-abi"></a>
## 20. External types and ABI

`cast: (T) value` is a machine cast, not a checked L3 conversion or proof of range, alignment, or lifetime. `c.name` selects a foreign C symbol; its adapter defines arguments, result, and ownership. `c.sizeof` means C `sizeof`, not Array length or Structure field count. `include` and `os` select explicit dependencies and a platform branch, not runtime module discovery.

`os` selects a target-platform branch but introduces no separate comparison of branches for equal method sets, signatures, or serialized contracts. Differences between branches are not errors in themselves. Selected declarations and bodies use the ordinary L2 mechanisms; wherever a receiving site requires compatibility, the ordinary `implements` admission and its address map apply, as outside `os`. Selecting a branch creates neither an additional common interface nor a private `os` admission mechanism. [Author clarification, 2026-10-23](../LMX_blog/2026-10-23.md).

The existing `os` receiver selects a branch for the target platform before its contents are semantically processed; no separate new operator is needed. Common structural parsing identifies the branches, but unselected declarations and bodies undergo no name resolution, type or contract checking, dependency collection, or code generation. Their `include`/`define`/`predef` do not add dependencies or declarations to the selected variant. Selected contents pass through the same common L2 pipeline as outside `os`, including ordinary native and walker execution for supported bodies, without a private parser, interpreter, or fallback native route. The target platform is consistent across translation stages, not accidentally determined by the translator host. This is the approved implementation direction, not a claim of completed support. [Author clarification, 2026-10-23](../LMX_blog/2026-10-23.md).

Platform headers and names occurring only in an unselected branch are not required for the selected variant. Its ordinary code may call a method declared only in the selected branch, without a counterpart declaration in the others. Translating every alternative into L1/C and then hiding the unselected ones with C `#ifdef` does not satisfy this rule; their dependencies, declarations, and bodies are not generated. Common structural parsing of the source does not imply semantic translation of an unselected branch. [Author clarification, 2026-10-23](../LMX_blog/2026-10-23.md).

This exclusion of branches is a translation obligation. It does not require storing the result of translation-time selection or preparation as a prerequisite for the walker: the walker executes the current graph under [§2.1](#interpretable-tree), not a mandatory translator record of the selected body.

`implements` remains the ordinary admission of the selected contents, not a static comparison of alternative platform implementations or a mechanism for suppressing their translation: it is performed once, when the clean graph is built, and at run time only where the candidate is selected while the program runs (the author's decision of 2026-11-11, [§14](#implements)). If another language facility is needed later, its general design is discussed with the author; the stated selection by the existing `os` does not require another approval of a new operator.

In an evaluated call through the C door, C functions and macros receive already evaluated L2 values, not substituted L2 expression text. L2 arguments are evaluated once in the ordinary lexical order and under the ordinary exit rules before being passed to the foreign call; macro expansion neither repeats nor cancels that evaluation. Thus, with `#define BYTES(x) sizeof(x)`, `c.BYTES(touch())` first executes `touch()` once and passes its value to the macro, although C does not evaluate the operand of the resulting `sizeof`. This also applies to a macro that uses its parameter several times or does not use it.

Literal `c.sizeof` has the role of a C operator, not a C-function call: after common preparation its operand follows C99 `sizeof` rules, not the prior evaluation of a foreign-call argument. Expanding an arbitrary macro into `sizeof` does not give it this role. The distinction is a semantic role after common parsing, without C-name registration or a second parser. For an ordinary non-variably-modified type, `c.sizeof(touch())` does not execute `touch()`; this does not override C99 rules for variably modified types. [Author clarification, 2026-10-22](../LMX_blog/2026-10-22.md).

The C door also has the opposite direction: a machine L2 function may be exported with a direct C-compatible entry. C code calls it with the function's explicit arguments, without an `Lmx` instance, root, Message or prepared graph; the state and memory it needs come through its ordinary explicit contract, not through a hidden shared unit, arena or singleton. The function remains the same L2: the existing generator translates it by the common structural parsing, expression resolution and checks, without a separate C-like language, a second parser or resolver, or a route private to List or libraries. Ordinary graph calls of L2/L3 keep their common mechanism; the export does not remove semantics from an arbitrary `fn`. Maintained sources stay L2/L3 and their L1/C is generated; a ported body replaces the old one without a permanent fallback. This is the approved implementation direction, not a claim of completed support. [Author clarification, 2026-10-23](../LMX_blog/2026-10-23.md).

<a id="lowlevel-expression"></a>
## 21. Machine expressions

The machine profile includes grouping, arithmetic, comparisons, logic, bitwise operations, `++/--`, indexing, and ordinary control flow. `=` in an expression compares; a write is `target := value`. The earlier form `target: value` no longer serves as an assignment in translation (author's decision of 2026-11-10, [L3](LMX_semantics.en.md#forms-declare-or-call), [journal](../LMX_blog/2026-11-10.md#forms-declare-or-call)); receiver forms that enumerate their arguments, `int: i 5` and `@: p q`, act as before. The project's sources write `target := value`; the translator refuses the earlier form, and the message names `:=` ([plan](../next_core_tasks_v3.md#m7)). Overflow and raw indexing follow the machine contract, not L3 guarantees. `a[i][j]` addresses a rectangular multidimensional Array; `a[i]\[j]` follows a reference to a separate Array. `s\[N]field` in a Structure used as data selects a source occurrence, not a machine Array element.

<a id="lowlevel-sync"></a>
## 22. synchronized

`synchronized: lock code` defines a structured exclusion region, not an open lock/unlock pair. Exiting releases the monitor. The mail monitor is one concrete reentrant use without `wait`/`notify`; pure L3 has no raw locks.
