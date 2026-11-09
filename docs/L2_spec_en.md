# L2 Specification

1. **GROSS ERROR IN THE PREVIOUS REVISION — REQUIREMENT TO FIX P0 CODE.** The rule that P0 removes a sole anonymous Structure and substitutes its fields was wrong. P0 must preserve every explicitly written anonymous container, including an empty container, in every context. Generic flattening damages non-call Structures as well as calls. Remove any implementation that unwraps a sole anonymous Structure during parsing or syntactic normalization. Preserve the container, its children, delimiter kind, and source span. Unwrapping is permitted only by function/method invocation semantics after P0; it must not mutate the retained source tree. In particular, `f()` and `f: ()` are different syntax trees: the first has no argument fields, and the second has one empty Structure field. Only invocation semantics can obtain the same empty actual-argument sequence from them.

2. **REQUIREMENT TO REMOVE TWO-ARGUMENT RECEIVER FORMS FROM CODE.** Remove the two-argument forms of built-in data/type receivers from semantic validation, dispatch, implementation, examples, and any backward-compatible fallback. The removed forms include `int: i 5`, `@: ptr 0`, `@: ptr Model`, `@: ptr Model: Other`, and `int(v, j)`; they must not remain accepted as legacy alternatives. Put the declared or assigned place outside the receiver's operand, for example `i{ int: 5}`, `i: int: 5`, `ptr: @: 0`, and `ptr: @: Model`. Unary `int: x` and `@: ptr` remain admitted. This requirement does not ban multiple arguments of arbitrary functions, `merge`, `fn`, `print`, `if`, or message operations. P0 still parses their common structural form without receiver-name-based arity inference; the removed built-in interpretations must be rejected by their semantic consumer.

**Revision 4: 2026-11-09.** This specification applies the adopted syntax and structural rules of the current [LMX grammar](LMX_grammar.en.md) and [semantics guide](LMX_semantics_guide.en.md). These explicit amendments take precedence over older conflicting text and linked implementation documents. The remaining L2 machine, memory, and execution contracts are retained. Revision 4 clarifies common name visibility, accumulation of changes, and matching native lowering. Implementation requirements and field unambiguity instead of selection by proximity ([the author's clarification of 2026-11-09](../LMX_blog/2026-11-09.md)) are recorded in [bugs to fix](bugs_for_fixing.md).

L2 defines the kernel mechanisms and machine operations. L3 semantics are in the [LMX specification](LMX_semantics.en.md), syntax in the [grammar](LMX_grammar.en.md), and C99 lowering in [L1](L1_spec_en.md). Head resolution, declaration, and invocation use those common rules; the sections below specify their L2 consequences without retaining removed surface forms. Implementation status belongs to the [notes](implementation-notes.en.md).

<a id="scope"></a>
## 1. Scope

The target chain is L3 with L2 insertions → generated L1 → C99. L1 is an intermediate language. The interpreter executes the stored L3 graph; L2 operations require native lowering.

The common source forms are `{...}` for a Structure, including expression grouping, `name{...}` for a bounded named description, `[...]` for Mix, and `(...)` for calls, actual-argument Structures, Array allocation, and Array indexing. Mix retains its local level-0 parsing context; its opening column is not an indentation base. P0 preserves every written container, including a sole or empty one. Only resolved function/method invocation semantics may expand a supplied whole actual-argument Structure, without rewriting the source tree. Raw C99 source, C type notation, regular expressions, and mathematical metanotation retain their own syntax.

<a id="lmx"></a>
## 2. `Lmx` Structure

The target physical model has a common `Lmx` base for graph objects. A language Array is an `Lmx` Structure with fixed, typed element storage, not a separate `VoidArray` record serving as the base of `Lmx`. Both ordinary Structures and Arrays have structural `parent` and `native`; the exact C99 layout of the shared base and Array specialization remains a migration decision. The current inverted C layout is recorded only in the [implementation notes](implementation-notes.en.md#l2-status), not prescribed as the target.

`parent` describes structural nesting, not Message parentage. For an Array created at an `arr` field, its parent is the graph occurrence representing that field; for a Structure constructed as an owned Array element, its parent is the Array. Storing a reference to an existing Structure in an element does not reparent that referent. Lexical visibility follows the construction position, without an additional hidden context. `native` selects a native entry; zero walks the stored body. A graph object has no stored name, model tag, or extra execution-state fields. Structure field count and Array element count are fixed at construction; addressable cells do not move. Primitive elements remain typed cells and need no individual `parent` field.

<a id="interpretable-tree"></a>
### 2.1. Interpretable tree

A resolved receiver selects the typed pool when its result is constructed; similarity to fields already declared in `data` does not turn their owner into that receiver's result. In particular, only a Structure produced by executing `fn` enters the pool of `fn` results, not an arbitrary Structure with similar parts in `data`.

The stored graph is the program: declarations, values, operators, and nested bodies initially follow source order; later writes change this same graph. Native lowering does not replace it with a second AST or data graph. A primitive already has a typed arena cell; it needs no redundant `leaf` or Structure wrapper. Atoms still part of the current program are retained.

An expression is a Structure with ordered fields, including its written operators, operands, and nested Structures. `{a + b}` explicitly bounds that expression Structure. P0 preserves its fields and container; it neither evaluates the expression nor replaces its container with the contained fields. The expression consumer later determines operator roles, precedence, and evaluation. This introduces no additional expression wrapper, fixed operator-slot layout, or automatic execution merely from storing or selecting an expression. The general `struct\(index)` path applies to its immediate fields as to any Structure.


The walker executes the current suitable tree, including one constructed or modified at runtime: editing data later supplied as `code` is code construction. This requires no prior translation, stored translator-prepared result, hidden source copy, or prepared flag. Traversing the current graph and ordinarily resolving its operations is execution, not prohibited reparsing of source text. Common receiver, admission, and address-map rules remain; they do not require one stored representation for native and the walker. This is the rule, not a claim that the current kernel fully supports runtime code construction. [Author clarification, 2026-10-23](../LMX_blog/2026-10-23.md).

Entity names live only in an external table. The walker may obtain the written head's name by its address to determine the head's role; this is not textual variable lookup for field access. The translator reads the unit's graph built by the common builder, not the parser tree: the parse tree is destroyed with the construction ([implementation specification §11 item 3](kernel-implementation.en.md#transition)); completed `native` needs no name for invocation. Comments play no dispatch role. `toLmx` emits the current graph composition and order: an overwritten operator is not reconstructed from source or a hidden copy. Launch data, call status, and Thread membership are not appended to the program graph.

References stored as data form a graph and may produce cycles. Structural `parent` forms a tree. Address classification determines a value's kind; the slot address and address stored in that slot are distinct.

All names and prepared places of the applicable scope are visible in both directions: the rule includes ordinary Structures, primitive fields, and references, not only `fn`, `fm`, `sub`, or `catch`. The most recent preceding, already accumulated binding of the given name in the relevant scope has priority. This selects by name and scope, not by searching for the “last compatible” candidate through types or tests; the selected value undergoes ordinary admission, and refusal does not resume the search at an older value. With no preceding binding, an available future definition is not excluded merely because it is written later. There is no selection by proximity among several candidates: within a code scope a name has one place prepared through `var`, and the executed writes change its value in sequence; an access to data must find its field unambiguously -- several same-named occurrences without an index are an ambiguity error, also when code is passed to itself as data ([the author's clarification of 2026-11-09](../LMX_blog/2026-11-09.md), [requirements](bugs_for_fixing.md#forward-candidates)).

Preliminary discovery of names and places belongs to semantic preparation of the current graph. The walker can perform it without mandatory prior translation, but it does not execute future initializers or assignments merely to resolve a name. Place availability does not imply an already computed value and does not promise zero for an uninitialized primitive. P0 preserves the written form and order without selecting runtime bindings.

Scope boundaries remain shared with L3: this rule does not merge sibling or nested scopes, change `node` as the executable occurrence's lexical parent, or bypass `independent`. The existing order of dynamic lookup and lexical fallback remains; visibility in both directions applies within the relevant permitted scope. No new namespace, persistent global runtime-binding table, opcode, or hidden environment is introduced.

<a id="type-by-range"></a>
## 3. Type by address range

Derived graph objects preserve the common `Lmx` contract. The pool and range identify the physical kind selected at construction and, for an Array, its element type. This classifies an address; it is not a stored name or opcode in the graph, nor a separate user-defined type for every Structure model. The old layout in which `Lmx` contains `VoidArray` remains transitional, not the template for the new Array variants.

An arena classifies an address through a registered half-open `LmxRange` interval and its owning pool. A cell has no in-band type tag. Ordinary Structures and graph Arrays share the `Lmx` base while ranges distinguish storage shape and element type; user models do not generate one C type or pool apiece. Primitive, reference, graph-object, and backing pools differ by physical access contract. Typed arena arrays are storage, not separate language Arrays. Ordinary and `immutable` Structures are allocated in separate pools; an already published ordinary Structure cannot become `immutable` in place. `implements`, not physical type, establishes model compatibility. For every primitive type T there is a distinct type "T without initialization", told apart in the same way -- by the region of the cell's address (the author's decision of 2026-11-08): for a place `int: x` without a value the field refers to a pointer primitive "int without initialization" pointing at the pre-existing `int` cell of that place, for `x: int: 0` to the `int` cell directly; the first assignment and every later write go into that same cell; the field is not rebound -- the slot, the cell's type and its address do not change ([implementation specification §3.2](kernel-implementation.en.md#lmx)).

`typeof(p)` accepts a pointer and returns the arena type code of its target object. L2 obtains that type classification from the target address's registered typed range and owning pool; it is not the identity of the enclosing Message's logical arena, which may contain several types. The result is neither the static carrier type `@` nor the type of a value that executing a selected method might return. Concrete code values are not assigned here. An arena type code does not replace full Structure admission or create one type per user model. The slot address and the address stored in a reference slot remain distinct inputs: `typeof(arr(index))` for an Array `@` inspects the object referenced by the selected element, not merely the Array's reference-slot type. An ordinary numeric Array element must not be silently treated as a pointer.

<a id="pool"></a>
## 4. Typed pool

A pool issues fixed-stride cells and grows by adding chunks, without `realloc` of live cells. Each chunk registers an interval of the same type. An issued address stays stable until its ownership is released. The arena manages the range index.

In a graph Array, `void *data` holds the backing address of the selected typed pool; it does not make the elements untyped. L2 obtains a pointer to the actual element type from that address for loads and stores; the arena range confirms that type, cell stride, and alignment. A pre-existing pool of `void *` slots cannot be read as an arbitrary `T` array merely by casting its pointer. Addressable graph-reference slots retain their own `void **` and stored-value conversion contract.

<a id="method-array"></a>
## 5. Native entry and Array

`LmxEntry` is the native-entry word, not a second method object. A graph Array carries the common `Lmx` base and exactly its fixed count of typed elements. It has no dynamic reserve and does not move published addressable cells. With an Array declaration such as `arr: (): int`, the Array value retains its graph position; a later `MyLmxStructFromArray: arr` binds another name by reference to that same Array under the general rule, rather than constructing another object or reconstructing a Structure from bytes. A dynamic List is a separate type and contract; its movable backing is not used for addressable Structure or Array slots.

A Structure also admits direct element selection by `struct\(index)`, counting all immediate fields from zero. Its representation as an Array of `@` remains another route:

```lmx
arr{ (): @}; arr: f; arr(1)
```

For method `f`, the parts are ordered `{args return var body}`. Both `f\(1)` and the final `arr(1)` select its `return` Structure; the latter reaches it through the corresponding reference-array element. `f\(0)return` selects the first occurrence of the named head `return:` and `f\return` selects its sole occurrence. The direct and named-occurrence indices count different sequences. The Array-representation rule does not prescribe a byte reinterpretation, an alias/copy choice, a new ownership rule, or an additional physical method object. The fixed-storage and stable-address requirements above still apply to published addressable cells.

<a id="arena"></a>
## 6. Arena

Each Message owns one logical arena, which may contain multiple chunks and ranges. `lmx_arena_attach` transfers ownership without moving addresses. `mark/revert` rolls back a failed copy or `merge` construction. Simple mode retains classification and address stability but does not run GC. An independent immutable branch may remain in its owner's arena under the [L3 contract](LMX_semantics.en.md#eternal); a separate pool alone grants no such right.

<a id="message"></a>
## 7. Message record

The closed `LmxMsg` record has exactly `running`, `success`, `handoff_ready`, and `graph`. Its local identity is the record address. Mail, scheduling, and Thread parent are not its fields. Writing zero to `running` during a turn requests stopping; user code sets `success` to one, which suffices to stop a Thread at the turn boundary; the system does not reset `success` to zero. `handoff_ready` permits storage handoff. `graph` refers to the language root.

<a id="thread"></a>
## 8. L3 Thread

Not every Message runs. A running Thread is allocated from the outset as `LmxThread` with `LmxMsg` as its first member by value. The Thread address equals this prefix address; tail access requires exact Thread classification. A standalone `LmxMsg` cannot become a Thread in place.

Direct children live in the sole List held by `Thread.children`. This is Thread state, not a `message.graph` field. `Thread.parent` belongs to the Message hierarchy and does not modify `Lmx.parent`. Competing workers may not execute one Thread identity.

<a id="root-close"></a>
### 8.1. R0 and shutdown

R0 is an ordinary child Thread of the top host scaffold. Launch data and settings belong to the scaffold and are passed to R0 explicitly; they are not added to R0's source graph. The top scaffold has no parent but gains no special API. Shutdown cascades through each Thread's sole direct-child List. A host watchdog controls the whole subtree's timeout; expiry terminates the process rather than declaring partial shutdown successful.

<a id="mailbox"></a>
## 9. Mailbox

Each Thread owns an `LmxPost`. `staged` prepares the current turn's messages, a successful boundary publishes them to `outbox`, and `inbox` holds admitted but untaken messages. An `inbox` element is an inseparable pair consisting of `target` and `source_arena`: the producer does not mutate the recipient arena; its owner attaches the donor before releasing the target. Failure retains the pair. Admission order is FIFO.

`inbox` is a ring over a separate DynamicArray; its backing may move but is not an addressable graph slot. One reentrant monitor owned by `LmxPost` covers admission, take, and count. `outbox` and `staged` remain owner-local. `post` uses this same mailbox for an ordinary LMX call, not another transport. The language API is specified in [L3](LMX_semantics.en.md#thread-message-api).

<a id="own"></a>
## 10. Structure execution

Execution uses the complete stored Structure. Native code and the walker must agree on working-field reads, writes, `dirty` state, and publication under [L3 §12](LMX_semantics.en.md#dynamic). A declared field has a graph storage place; assignment does not add a slot to an existing `Lmx`. Pointers to graph slots must remain valid. The logical method-part order is `{args return var body}`; `f\(1)` selects the `return` part. This approved revision-3 migration target, retained in revision 4, does not claim that its physical ABI has already been implemented. The order of logical fields does not supply a numeric ABI layout for arbitrary expressions.

Before `var` is allocated, the complete method own-place set is determined: explicit `var` fields and own fields found in the corresponding `body` that are absent from the explicit set. Automatic completion does not depend on whether a use appears above or below the written field. All prepared places are available from the start of the scope; a repeated write of one name uses the same place rather than adding a field. First-slot order, physical addresses, and the proven code→data map are preserved. Automatic completion neither extends an arbitrary supplied `data` Structure nor grows an already built `Lmx`.

Place preparation is separate from value evaluation. Initialization in `var` follows the existing method-entry contract; initialization in `body` runs when execution reaches its line. Full name availability neither moves these evaluations nor executes the body early or reconstructs an already replaced initializer from a hidden copy.

The walker accumulates admitted changes to current places in sequence, and native code must produce the same results at the same points. It must not substitute a statically selected last definition of the entire block for each reference: a later write does not retroactively change an earlier resolution or read. Working values, `dirty` marks, publication checkpoints, and `native` invalidation retain their existing rules; preliminary name discovery is neither a write nor publication.

<a id="call"></a>
## 11. Call

The removed `call` operator is replaced by explicit application. An ordinary Structure has no formal parameter list: `code()` executes it without an explicitly supplied separate data Structure, and `code(data)` executes it using the supplied Structure `data` as state. A method retains formal-argument calls such as `f(1)`; an ordinary `s(1)` is not positional Structure selection and does not satisfy the Structure-data requirement. Supplying `data` is not the function/method operation that expands a whole actual-argument Structure. P0 keeps the source trees of `f()` and `f: ()` distinct; only invocation semantics can prepare the same empty actual list from them.

The selected code's `Lmx.native` chooses native entry or walker. Execution receives selected `code` and `data` selected explicitly or by the shorthand, the actual arena, `node` as the executable occurrence's lexical parent, and prepared actual arguments for a method invocation. In split execution, `code` supplies the executable body and `data` supplies state. These roles neither prove code stability nor qualify the whole Structure as `immutable`. No prediction of write paths or aliases is performed; an actual code-place change clears its `native` through the shared write path. The existing L2 shorthand contract is retained with the new spelling: `code()` selects `code\var`; absent `var` does not imply using `code` itself as `data`, and a local data-field write then refuses. Explicit `code(code)` supplies that same Structure value as `data` under the general rule and tests Structure universality and code mutation for future on-the-fly compilation, rather than defining a special execution path. For **any** admitted pair of Structures, field access and publication of already computed `dirty` values use one proven `implements` address map; equal ordinal positions are not assumed. A checkpoint stores the ready value into the selected `data` slot without re-evaluating the expression or repeating admission.

Entering execution, including `code(code)`, does not invalidate `native`. With the place and new value determined and admitted, the general write path clears `native` of code places linked to the changed cell: a direct path at the write, a working `dirty` value at its publication checkpoint. The physical slot write and removal of changed-code entries are atomic for the next or a recursive dispatch. A working value before publication, a refused write, and a call that does not change the graph leave `native` intact; an ordinary data-value change preserves the entry. The code-place link may belong to an enclosing Structure, not just the Structure containing the written slot. If an L2 body becomes incompatible with its old entry, a matching native implementation or refusal is required **before** publishing the change: the L3 walker does not execute L2. Do not retry a call on another engine after effects.

An ordinary executable named form in `code`, including `name: ... end: name` and forms inside inline `if`/`for`, assigns its value to the prepared same-named place in the selected `data`. It does not declare a new field in `code`; declarations through `fn`/`fm`/`sub` keep their own receiver contracts. The `data` map considers root-level heads but not heads inside their initializers. One source occurrence permits `data\field`; two or more require `data\(N)field` with zero-based `N`. The first occurrence is not chosen automatically, and this does not create multiple same-named data fields. Without a name, `data\(N)` instead selects the immediate field at overall position N; it does not silently select the Nth occurrence of some inferred name. Nesting in `code` does not select another place. Arbitrary `data` is not auto-completed at a call: if a required place is absent or bare access is ambiguous, the call fails during execution/admission, not because the source form itself is a translation error. Method `var` preparation allocates its complete field set in advance under §10 and is separate from this rule. The most-recent-preceding-binding rule does not remove ambiguity from the explicit path `data\field` or replace numbered source-occurrence selection. Repeated assignments to the same place accumulate its state rather than creating new same-named fields. Only explicit Structure execution through `code()`/`code(data)` or a callable invocation, including `fn`, starts a new binding scope, where an own field may shadow an outer one. There is no shadowing within one callable; inline `if`/`for` are operators within the same activation, not new scopes, despite being Structures.

A null argument transport-cell address denotes absence; a present argument holding a null reference is still present. A number travels in storage of its declared width, an object reference through a canonical pointer-value cell. Callback status and returned value differ; the result contract distinguishes `void` from a present null reference.

A call through a mutable method-reference cell uses its current bound value at the call boundary. The target is selected once before actual arguments are evaluated; changing the cell during their evaluation does not redirect the call already under way. Native code and the walker follow the same rule. A retained target from an earlier call and the last definition of the entire block do not replace the current selection; refusal of ordinary admission for the selected target does not switch the call to an older binding. These rules add no new callback or dispatch mechanism.

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

The proven mapping from used fields of the receiving model to physical fields of the candidate for an admitted pair of Structures is data of the reception or traversal that established it (the author's decision of 2026-11-08 on service traversal tables, confirmed by Codex; [implementation specification §5.2](kernel-implementation.en.md#tables)): a reception holds its map for the duration of the operations it needs -- reads, writes, address taking, and direct publication of ready `dirty` values, including differing field order -- and the next traversal rebuilds it from the graph; the arena keeps no persistent store of mappings, and there is no separate map for Structure invocation or `var`. At one structural level, one name denotes one field; `s\(N)field` selects a source head occurrence, not the Nth data field. In contrast, `s\(N)` directly selects the immediate field at overall position N. Both counts start at zero, and neither path creates duplicate materialized data fields. The map does not look up runtime names, copy the candidate, or waive a new Consumer's checks. Admission semantics and explicit tests are in [L3 §7](LMX_semantics.en.md#admission).

Semantic selection of the current binding and subsequent access through proven addresses are separate steps. The `implements` map does not resolve the name again, apply the most-recent-preceding rule to ordinal positions, or fall back to an older value on admission refusal. Repeated changes to one place preserve its cell; source occurrences and the `s\(N)field`/`s\(N)` paths remain distinct under their existing rules.

<a id="gc"></a>
## 15. Collection

GC belongs to the arena. Roots include Message, live graph, mail, execution state, and `Thread.children`; Thread state retains that List independently of source fields. From a live value, collection also follows an established `implements` correspondence to its required Structure: replacing a graph field does not release the model while that value still needs its admission. This rule does not retain a transient admitting frame; retirement of the frame removes a record that depends on it. These are address-proof dependencies, not hidden graph fields. The owner retains constructed `independent: immutable` branches until its arena is destroyed. Simple mode does not collect. Unloading a later module needs a separate contract and is not invented here.

<a id="special"></a>
## 16. Special L2 operations

The kernel provides address classification, `typeof(pointer)`, cell allocation, arena attach/revert, mail, Thread turns, calls, child reservation, copying/merge, and collection. These operations do not create another namespace or auxiliary execution graph.

<a id="lowlevel-scope"></a>
## 17. Machine profile

L2 machine types retain the representation and numeric semantics of corresponding target-platform C99 types, including the signedness of plain `char`. L3 does not gain raw memory access merely because its graph uses pointers internally. L1 has a separate C-like surface.

<a id="lowlevel-address"></a>
## 18. Addresses, loading, and writing

M3 orders flat declarations as name followed by requirement/value. The N1–N6 receiver contracts use an outer place name and a single requirement/value operand: `ptr: @: Model: 0`, `p: @: 0`, `p: @: Model`, `p: @: Model: 0`, and `p: @: Model: Other`. The bounded named form is also available, for example `p{ @: 0}`. In `p: @: Model: Other`, `p` is the outer place name and the receiver's one operand is the nested Frame `Model: Other`; that operand is consumed under the ordinary expression rule. Its consumption alone does not write to `Model`. P0 retains the common Frame structure rather than parsing these forms by receiver name. The former name-first two-field and three-field pointer-receiver alternatives are not retained as compatible spellings; their described candidate is nested inside the receiver and the place is outside it. The two-argument implementation branch must be removed, not silently reached through a fallback. Unary `@: p` and empty `@()` remain admitted. Initial `@: p` or `p: @: 0` creates a void reference; a later address write does not retroactively add a requirement. Pointer depth `@ⁿ:` has no arbitrary numerical cap.

In `ptr: @: method`, the outer name `ptr` identifies the place and the receiver `@` has the one operand `method`. Bare `method` reads the method reference without calling it. This writes an admitted reference to the same place even when `ptr` already contains a callable; `ptr(args)` selects the cell’s current value once before evaluating arguments and invokes that method under §11. Rewriting `ptr` neither creates another slot nor permits native code to retain the previous target for the next call. Unary `@ptr` separately takes the reference cell's address. The detailed ordinary-`var` and reference rules are in [L3](LMX_semantics.en.md#ordinary-var) and [method-reference assignment](LMX_semantics.en.md#method-reference-assignment), subject to the explicit syntax amendments in this revision.

Unary `@x` addresses the real value cell: for a graph Structure/Array, the `void *` slot holding a descriptor reference; for a primitive, its typed cell; for a formal or a hidden input from dynamic or lexical visibility, its own local activation cell. Bare `x` and `@x` refer to the same local variable; writing does not change the binding's source. The address of an external field is explicit, for example `@{node\x}`. Slot, slot address, and referent differ. Native access to a graph reference slot uses `void **` with conversion of its stored `void *`; dereferencing it as `Lmx **` violates C99. Do not take the address of a temporary cache or ABI carrier. By precedence, `@x\field` means `@{x\field}`.

Prefix `\p` follows a reference; `p\field` accesses either a graph field or an explicitly imported machine ABI according to `p`'s category. `@array(i)` addresses the actual backing element. Direct `struct\(index)` selects an immediate Structure field, while `struct\(index)field` selects a named source occurrence as specified in §21; these paths preserve the distinction between slot, its address, and its referent. L2 adds no automatic bounds check; checked access belongs to L3. Address operations neither bypass `const`/`immutable` nor extend target lifetime.

<a id="lowlevel-array"></a>
## 19. Raw C storage

A `c.*` token is an explicit C door. A language Array remains an `Lmx`-based graph object with typed elements; it does not become a raw C array. Conversion between them requires an explicit operation accounting for shape and lifetime. Typed arena arrays are internal storage, not another kind of language Array. L2 introduces no special `c.array` entity.

<a id="lowlevel-abi"></a>
## 20. External types and ABI

`cast: {T} value` is a machine cast, not a checked L3 conversion or proof of range, alignment, or lifetime. `c.name` selects a foreign C symbol; its adapter defines arguments, result, and ownership. `c.sizeof` means C `sizeof`, not Array length or Structure field count. `include` and `os` select explicit dependencies and a platform branch, not runtime module discovery.

`os` selects a target-platform branch but introduces no separate comparison of branches for equal method sets, signatures, or serialized contracts. Differences between branches are not errors in themselves. Selected declarations and bodies use the ordinary L2 mechanisms; wherever a receiving site requires compatibility, the ordinary `implements` admission and its address map apply, as outside `os`. Selecting a branch creates neither an additional common interface nor a private `os` admission mechanism. [Author clarification, 2026-10-23](../LMX_blog/2026-10-23.md).

The existing `os` receiver selects a branch for the target platform before its contents are semantically processed; no separate new operator is needed. Common structural parsing identifies the branches, but unselected declarations and bodies undergo no name resolution, type or contract checking, dependency collection, or code generation. Their `include`/`define`/`predef` do not add dependencies or declarations to the selected variant. Selected contents pass through the same common L2 pipeline as outside `os`, including ordinary native and walker execution for supported bodies, without a private parser, interpreter, or fallback native route. The target platform is consistent across translation stages, not accidentally determined by the translator host. This is the approved implementation direction, not a claim of completed support. [Author clarification, 2026-10-23](../LMX_blog/2026-10-23.md).

Platform headers and names occurring only in an unselected branch are not required for the selected variant. Its ordinary code may call a method declared only in the selected branch, without a counterpart declaration in the others. Translating every alternative into L1/C and then hiding the unselected ones with C `#ifdef` does not satisfy this rule; their dependencies, declarations, and bodies are not generated. Common structural parsing of the source does not imply semantic translation of an unselected branch. [Author clarification, 2026-10-23](../LMX_blog/2026-10-23.md).

This exclusion of branches is a translation obligation. It does not require storing the result of translation-time selection or preparation as a prerequisite for the walker: the walker executes the current graph under [§2.1](#interpretable-tree), not a mandatory translator record of the selected body.

`implements` remains a runtime operation, not a static comparison of alternative platform implementations or a mechanism for suppressing their translation. If another language facility is needed later, its general design is discussed with the author; the stated selection by the existing `os` does not require another approval of a new operator.

In an evaluated call through the C door, C functions and macros receive already evaluated L2 values, not substituted L2 expression text. L2 arguments are evaluated once in the ordinary lexical order and under the ordinary exit rules before being passed to the foreign call; macro expansion neither repeats nor cancels that evaluation. Thus, with `#define BYTES(x) sizeof(x)`, `c.BYTES(touch())` first executes `touch()` once and passes its value to the macro, although C does not evaluate the operand of the resulting `sizeof`. This also applies to a macro that uses its parameter several times or does not use it.

Literal `c.sizeof` has the role of a C operator, not a C-function call: after common preparation its operand follows C99 `sizeof` rules, not the prior evaluation of a foreign-call argument. Expanding an arbitrary macro into `sizeof` does not give it this role. The distinction is a semantic role after common parsing, without C-name registration or a second parser. For an ordinary non-variably-modified type, `c.sizeof(touch())` does not execute `touch()`; this does not override C99 rules for variably modified types. [Author clarification, 2026-10-22](../LMX_blog/2026-10-22.md).

The C door also has the opposite direction: a machine L2 function may be exported with a direct C-compatible entry. C code calls it with the function's explicit arguments, without an `Lmx` instance, root, Message or prepared graph; the state and memory it needs come through its ordinary explicit contract, not through a hidden shared unit, arena or singleton. The function remains the same L2: the existing generator translates it by the common structural parsing, expression resolution and checks, without a separate C-like language, a second parser or resolver, or a route private to List or libraries. Ordinary graph calls of L2/L3 keep their common mechanism; the export does not remove semantics from an arbitrary `fn`. Maintained sources stay L2/L3 and their L1/C is generated; a ported body replaces the old one without a permanent fallback. This is the approved implementation direction, not a claim of completed support. [Author clarification, 2026-10-23](../LMX_blog/2026-10-23.md).

Native lowering of common name visibility determines the required C places, declarations, prototypes, and type dependencies in advance; the generator emits them before uses wherever C99 requires it. This prepares layout and declarations rather than executing initializers early or reordering writes, calls, and other effects. A mutable method reference is read at its call boundary under §11; a fixed direct entry must not hide an admitted change to the selected cell. Actual slot addresses, value representations, the code→data map, and `dirty`/publication rules are preserved. Preparation covers only the selected `os` branch and does not restore semantic processing of excluded branches. No new ABI, global runtime names, or additional opcode is required; concrete corrections are listed in [bugs to fix](bugs_for_fixing.md).

<a id="lowlevel-expression"></a>
## 21. Machine expressions

An expression is a Structure with ordered fields and nested Structures, not a separate non-Structure expression object. `{a + b}` explicitly bounds one such Structure. P0 retains its fields and containers; expression semantics determines operator roles, precedence, and evaluation after parsing. Grouping does not authorize P0 to unwrap the Structure or replace it with an evaluated value. The same direct `\(index)` path applies to an expression's immediate elements without introducing fixed numeric operator slots or a separate expression ABI.

The machine profile includes brace grouping, arithmetic, comparisons, logic, bitwise operations, `++/--`, Array indexing, Structure paths, and ordinary control flow. `=` in an expression compares; `target: value` writes or binds according to its admitted context. The former `:=` operator is removed. Compound assignments use `+:`, `-:`, `*:`, `/:`, `%:`, `<<:`, `>>:`, `&:`, `^:`, `|:`, and `**:`; each is one token. Comparisons `=`, `!=`, `<=`, and `>=` retain their comparison meaning. The grammar defines the power operator and expression priorities; this revision does not invent extra conversion, overflow, or failure guarantees. Overflow and raw indexing follow the machine contract, not L3 guarantees.

`a(i)(j)` addresses a rectangular multidimensional Array; `a(i)\(j)` follows a reference to a separate Array. These LMX forms do not rewrite literal C99 array syntax. `struct\(index)` selects the zero-based overall position among immediate Structure fields; a nested Structure remains one field. `struct\(index)field` selects the zero-based source occurrence of the specified root-level head `field:` instead. Bare `struct\field` still requires a single occurrence. The optional path name follows existing path boundaries; P0 does not infer it from a signature or capture an independent following argument.

```lmx
f\(1)                # overall position 1: return
f\(0)return          # first occurrence of the name return
f\return             # sole occurrence of the name return
f(1)                 # method call with actual argument 1
arr(1)               # Array element 1
```

For method `f`, the parts are ordered `{args return var body}`, so the first three paths select its `return` Structure. `f\(1)return` would request a second occurrence of the named head `return:`, not overall field 1. An ordinary Structure still executes through `s()` or `s(data)`; plain `s(1)` is not reinterpreted as an index. Direct selection does not require an Array declaration, while the Array `@` representation in §5 remains available.

`typeof(arr(1))` in that representation returns the arena type code of the selected `return` description Structure, not the type of the value returned by executing `f`. Address classification and pointer requirements are specified in §3; machine `c.sizeof` retains its separate C99 contract.

<a id="lowlevel-sync"></a>
## 22. synchronized

`synchronized: lock body` defines a structured exclusion region, not an open lock/unlock pair. Exiting releases the monitor. The mail monitor is one concrete reentrant use without `wait`/`notify`; pure L3 has no raw locks.
