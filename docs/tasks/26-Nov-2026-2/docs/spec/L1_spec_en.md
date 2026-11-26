# L1 Specification

**Current extension:** [types, universal sequences, generic patterns, and callable adapters](CORE_SEQUENCES_REGEX.en.md). The root specifications of this uploaded archive govern this edition; old contradictory spellings are superseded.

L1 is the generated intermediate representation used to lower the kernel to C99. Graph-language rules belong to [L3](LMX_semantics.en.md) and [L2](L2_spec_en.md); only the C projection remains here. Current translator status and transitional hand-written L1 belong to the [implementation notes](implementation-notes.en.md).

<a id="scope"></a>
## 1. Scope

`l1trans` lowers `.lm1` to one C99 translation unit. L1 itself does not define arenas, `satisfies`, or graph visibility as language operations. The kernel library implements them explicitly. The self-build target is L3 with L2 insertions; L1 remains intermediate.

<a id="translator"></a>
## 2. Translator

L1 resolves its C-like declarations and expressions. Prefix `@x` takes the address of C cell `x`, prefix `\p` loads through a pointer, and `p\field` accesses a field through a pointer. Declarative `@ⁿ:` sets the corresponding C pointer depth. The historical argument order for pointer declarations in hand-written L1 is not a permanent exception: target intermediate L1 must follow the shared L2/L3 order “name, requirement, value.” Foreign C symbols use explicit `c.name`.

<a id="lmx"></a>
## 3. Lmx in L1

The target C projection of [L2 §2](L2_spec_en.md#lmx) is a flat `Lmx` header with fields `parent`, `length`, `storage` in precisely this order, without an embedded `VoidArray`. A Structure or Array reference points to the start of the header. An ordinary Structure and `Array<@>` hold `void *` elements in `storage` and are interchangeable in common operations; a numeric `Array<T>` stores T elements directly. Typed storage and common resizing apply to all Arrays; capacity resides in the arena table. This layout is approved; migrating the current generator remains open: [implementation status](implementation-notes.en.md#l2-status), [current implementation contract](kernel-implementation.en.md). Graph records gain no name, model tag, or hidden execution fields. Thread's dynamic child List remains separate.

Lowering ordinary receiver [`sys\descriptor`](L2_spec_en.md#get-descriptor) returns a Structure of addresses of the three actual header fields: `Lmx **`, `size_t *`, `void **`. A dereferenced write directly addresses and changes the original field; writing a field of the returned Structure changes its pointer. There is no proxy, delayed writeback, or new opcode. Arbitrary finite pointer depth and Array rank use the common typed path; L1 retains its own “type — name” declaration order.

Lowering parent/length/sys\storage reads header fields; sys\native obtains the native descriptor from call tables and
sys\capacity reads the arena capacity table. Every zero-argument form selects current data; code requires an explicit
argument. None of these queries builds an auxiliary descriptor. Data (the parent of the selected Structure), code and
node retain their roles. sys\resize/sys\reserve use common variable-size Arrays. Lmx contains neither native nor
capacity.

`sys\descriptor` likewise accepts an explicit S or defaults to the current data
(the parent of the executed Structure); the former spelling `sys\descriptor() = sys\descriptor(data)` through the special name `data`
is removed ([what is removed](LMX_semantics.en.md#removed-builtins)). This choice also applies inside nested control bodies;
lowering either variant returns the selected Structure's field addresses under one contract.

<a id="interpretable-tree"></a>
### 3.1. Tree projection

Lowering preserves the full graph for the walker and `sys\toLmx`; later mutation changes that same graph. It allocates no `leaf` wrapper for an already typed primitive cell and stores no names in graph records. The name table and comments serve text output of the current graph, not execution. The full contract is [L2 §2.1](L2_spec_en.md#interpretable-tree).

Lowering `sys\indexof(field parent)` finds the unique reference occurrence and returns its physical
index; absence or ambiguity is an error. `sys\indexof(field index parent)` selects occurrence index,
counted from zero, and returns its physical position; a missing occurrence is an error.
Use common Structure/Array<@> addressing without an additional index table.
[L2 contract](L2_spec_en.md#system-indexof).

<a id="type-by-range"></a>
## 4. Type by range

The norm (the author's decision of 2026-11-16, [L2 §3](L2_spec_en.md#value-record)): the physical type of a value is the code in its record, standing immediately before the value; an arena has one stream of records, and no type is learned from an address. User models do not create one C type per Structure. An ordinary and an `immutable` Structure differ by the code of the record while retaining a compatible physical record. Today's code still classifies addresses through `LmxRange` and the arena index and keeps separate pools; that is the former scheme, removed by [current implementation contract](kernel-implementation.en.md).

<a id="pool"></a>
## 5. Pool

Records are issued one after another from the chunks of the arena. Growth adds a chunk instead of moving live records through `realloc`. Chunks belong to the arena. Today's `LmxPool` and `LmxChunk`, which allocate cells of one type, are the former scheme. See [L2 §4](L2_spec_en.md#pool).

During incremental self-build, the translator emits C99 access to a graph Array's `void *storage` through a pointer `T *` of the actual element type selected by the code of the Array's record. The storage is allocated for elements of that very type with suitable alignment: a cast does not redefine the effective type of existing backing. Graph-reference slots retain their separate `void **` contract, not an incompatible `T **` access. Thus one common Array Structure lowers to different typed arrays without a new language object for every `T`.

<a id="method-array"></a>
## 6. Native entry and Array

Native descriptors are ordinary Structures in call tables in the Thread's arena, with signature variants,
binary-module/entry names, and L1/C paths. Compilation does not add a synthetic native field to an executable Structure
or `catch` ([L2 §2](L2_spec_en.md#lmx)). Arrays use the common
Lmx and variable-size typed storage; separate List growth and embedded capacity are removed. See
[L2](L2_spec_en.md#method-array).

<a id="arena"></a>
## 7. Arena

`LmxArena` owns blocks, pools, and the range index. `attach` transfers ownership without moving addresses; `mark/revert` serve atomic construction. Simple mode does not perform GC. See [L2 §6](L2_spec_en.md#arena).

<a id="message"></a>
## 8. Message

`LmxMsg` lowers to exactly four fields: `running`, `success`, `handoff_ready`, and `graph`. Its identity is its record address; there is no numeric index field. Mail and family links are not added to the Message prefix. See [L2 §7](L2_spec_en.md#message).

<a id="thread"></a>
## 9. L3 Thread

`LmxThread` contains `LmxMsg` as its first member by value, so the Thread address equals the Message-prefix address. Tail access requires exact Thread classification. `Thread.children` holds one List of direct children outside the source graph. See [L2 §8](L2_spec_en.md#thread).

<a id="root-close"></a>
### 9.1. R0

Program startup always starts R0 as an ordinary L3 Thread beneath the stub parent
and executes its CODE from the beginning. R0 has no DATA or user actuals; there
is no artificial `data = code`, empty service DATA Structure, or field `data`.
Internal Thread launch parameters are not user actuals or hidden source fields,
and the Thread's stub parent does not become a source-graph DATA parent.

The common activation mechanism skips only the absent input pass. R0 retains
ordinary CODE-local declarations, calls, dispatch, and exits. A named case or
handler is invoked normally after startup; neither a `Main` name nor a
host-selected service function replaces the root. The stub parent may deliver
its own arguments by an ordinary message to the running root. Shutdown cascades
through the sole child List; a host watchdog enforces the whole subtree timeout.
See [L2 §8.1](L2_spec_en.md#root-close) and the
[implementation sketch](kernel-implementation.en.md#root-activation).

<a id="mailbox"></a>
## 10. Mailbox

`LmxPost` holds `staged`, `outbox`, and FIFO `inbox`. An incoming slot is the pair `[target, source_arena]`; the recipient owner attaches the donor before releasing the target. The inbox ring uses a common variable-size Array with external capacity, movable storage, and a mailbox monitor. See [L2 §9](L2_spec_en.md#mailbox).

<a id="own"></a>
## 11. Local call frame

The norm of 2026-11-19 (binding and callables) was accepted by the author (the [decisions R01–R19](LMX_semantics.en.md#binding-decisions)) and is in force in the edition of 2026-11-21; its
application is recorded in the [current implementation contract](kernel-implementation.en.md). This section states the new norm in the
same words as [L2 §11](L2_spec_en.md#call).

<a id="call-receivers"></a>
<a id="structural-call"></a>
### Structural call and the `call` receiver

The selected Structure `C` is executed: it is read in the code role, and its data role is performed by its actual parent `D = parent(C)`. The forms after an unambiguous selection:

| Form | Executed Structure | Actuals | Data |
|---|---|---|---|
| `call(C)` | `C` | not supplied | `parent(C)` |
| `call(A C)` | `C` | Structure `A` | `parent(C)` |
| `C()` | `C` | empty tail | `parent(C)` |
| `C(args)` | `C` | written actuals under the common algorithm | `parent(C)` |

The parameters of `call` are named `args` and `code`. `args` is the Structure of actual supplied values, exactly
the argument Structure of an ordinary call. It is not formal declarations, a signature, or a separate
callable part. The input places, requirements, and defaults are described by the data `D`.
`call` executes the selected `C` itself; a child field `code` is not looked up automatically.
The one-argument form requires `code`, the two-argument form requires `args` and `code`, so `call(code := C)`
does not suit the two-argument form: this is the ordinary distinction between declarations ([declaration selection](L2_spec_en.md#declaration-selection)),
without an exception for the built-in `call`. A whole `C` may suit one form of `call` while its fields suit the other:
then `call(C)` is an ambiguity error, while `call(code := C)` passes `C` explicitly as `code` and excludes
the expansion of that actual. `C(A)` may take `A` whole or pass its fields;
declaration selection decides.

A call itself cannot substitute other data. For another combination the needed structural link is created first
(a declaration, a copy, `merge` -- under their rules about `parent`), and then the selected occurrence of `C` is called.
`NewContainer: ExistingCode` holds a reference to `ExistingCode` and does not change its `parent` ([`colon-declares`](LMX_semantics.en.md#colon-declares)).
The former `call(D C)` and `C(D)` no longer substitute data: the first argument of the two-argument form is now `args`.
Different occurrences of code may use one native implementation while keeping their own data: neither the address of a shared
C function nor the path by which a reference was found replaces the `parent` of the selected `C`. The former equality
`call(C)` = `call(C C)` (“a Structure is its own data”) is removed.

`node` remains the reserved lexical operation for the selected source occurrence. Its lexical source and necessary
native context follow the preserved binding rules. It is not a synonym for `parent(C)`, the current DATA consumer, or
the receiver of a field stream. An explicit path `D\x` uses the named Structure D; `node\x` is appropriate only when the
lexical `node` rules actually select that source. Moving an existing reference or importing a method does not reparent
it.

A structural form and ordinary Structure calls share one interpreter path: resolve the callee name and visible
declarations → select by explicit material → prepare the selected namespace's necessary receiving places → evaluate and
receive actuals once in written order through common admission → apply permitted implicit binding → execute and transfer
the result. Necessary receiving places exist before an actual expression writes them. Namespace preparation and actual
reception neither change source data nor run an entry-wide initializer pass; an explicit stream source call runs only
when the receiver's ordinary contract demands it. Calls from test and converters use the same mechanism. Known
native-to-native calls may still go directly through C without graph packaging.
[Full contract and named arguments](LMX_semantics.en.md#call-receivers).

The result (`return` in data), the named signature, declaration selection, binding (autofill, the transparent caller
place, the former binding) and `catch` are defined in L2 §11: [`return` in data](L2_spec_en.md#return-in-data),
[the named signature](L2_spec_en.md#fn-signature), [declaration selection](L2_spec_en.md#declaration-selection),
[binding](L2_spec_en.md#binding-places), [`catch`](L2_spec_en.md#catch-common-model).
L1 repeats only what the C projection needs.

<a id="private-binding"></a>
### Receiver private: two-way `private`

`private:` marks a specific declaration and the corresponding place and excludes them from all implicit dynamic binding
in both directions. (Source) A `private` place of the caller is not implicitly offered -- neither as a value nor as a
place. (Receiver) A really visible `private` declaration in the callee's lexical context is not overridden by a value or
a place from the dynamic context. The rule applies to autofill, the transparent caller place and the dynamic part of the
former binding, alike for every form of `call`, `C(args)`, ordinary calls, the interpreter and native execution.
Therefore, before an external dynamic binding is accepted, it is determined which lexical declaration is really visible
and whether it is protected by `private`; checking the source alone is not enough. `private` is a filter of a specific
place, not a name barrier and not access protection: a `private` source is skipped and the permitted lookup goes on, and
a `private x` of an ancestor does not close a new inner unmarked `x`. Not forbidden: explicit passing (including one's
own `private` value), explicitly filling a receiving `private` place with an actual, nested lexical visibility, explicit
paths and `node`, and shadowing an outer `private` by a new inner declaration. `private` does not replace write
restrictions (`const`, `immutable`). An explicitly passed value does not carry the `private` history to its copies; the
graph record `S\private\field` is not flattened into `S\field`. Use the common binder without a separate registry or
checks on direct reads. The walker reads the original `private` receiver in the clean graph; the compiler emits the
appropriate binding/hidden-argument logic from that same source. A second graph of private marks or access flags in the
binary is forbidden, including one presented as a prepared runtime representation.
[Full contract](LMX_semantics.en.md#private-binding).

<a id="call-frame-20261115"></a>
### Call frame

Each independent call has its own namespace. The inputs are described by the data of the selected Structure
(`parent(C)`); `args` in `call` contains the explicit supplied material. Preparation collects the relevant roots without
executing initializers, visiting unreachable branches, or writing bindings into source data. An explicit value replaces
its default source in the namespace, so that default does not execute. Ready terminal declarations use their stored
values; a computed initializer remains a description until its contract requires it. Reading an own computed input
obtains its value through the common mechanism. Explicit source-graph paths remain different: `D\field` reads the
written record and does not execute its RHS. Given `@: fptr getFuncPtr()`, consuming the local `fptr` obtains that
initializer's reference; `fptr("hello world")` then invokes the resulting callable, without treating a bare reference as
an implicit call.

Variables and const are visible from their initial declaration onward in their scope and below.
Names of Structures and callables retain bidirectional visibility; a function-pointer variable does not.
A new branch name does not escape its branch.

<a id="shadowing-levels"></a>
A declaration at a nested level shadows an outer declaration of the same name: an inner `Text x` shadows an outer `int x`
without writing `Text` into the outer `int` cell. At the same level there is nothing to shadow, and the already existing
place is used: a repeated `int: x bump()` retains evaluation, admission, and assignment to the existing x under the receiver contract --
the new right part is evaluated and assigned, the absence of a right part does not zero the value, and there is no second cell;
only the repeated C declaration is omitted. After exit from the inner scope the outer declaration is visible again, with its place,
write mode and `private`. A use before a later own declaration is resolved in the ordinary way
through the accessible outer context: the future declaration does not block the whole body. Physical repeated
fields remain and are selected by `S\[n]x`. An explicit path is not restricted by the declaration
order of a bare name. A read through a path executes nothing; the RHS is executed when its code statement is reached.

<a id="inline-declaration-control"></a>
One case remains with the executor's reading ([the control example](LMX_semantics.en.md#inline-declaration-control),
Р106 (historical repository reference `../../LMX_blog/q/fable-self-answers-20261110.md`)): a new `int: x` without a right part in a nested inline scope
where there is no new call of a callee, with an outer `x = 5`, remains `uninit:int`, because autofill is defined
between the caller's local context and the callee's place at the call, while an inline scope stays within the same
activation; the value 5 would need a new rule, and the binding rules introduce none. This is not an author's decision.
[Control example](LMX_semantics.en.md#inline-declaration-control).

Bare x and @x refer to the selected place. The own place of the frame does not depend on source-field replacement immediately
at entry, even before the first read: the selected value or computed description is retained; the rule is the same
for explicit data, lexical binding, and the former dynamic binding, and it does not deep-copy
referenced objects. The transparent caller place is the caller's place itself ([L2 §11](L2_spec_en.md#binding-caller-place)).
`x := 0` changes the selected place: the own place of the frame writes neither to the graph nor to the caller, the transparent caller
place writes to it at once; `D\x := 0` changes the source graph of the data.
For computed input `int: x next()`, @x obtains the value and the local cell's address.
With `(@D\field)` and source `int: field getValue()`, the record of the declaration is addressed, not
getValue()'s result: an explicit path executes nothing (the author's decision of 2026-11-17; the former rule is withdrawn).
A ready place is addressed directly.
Lifetime remains ordinary. @f() was a research example, not a separate support or prohibition task.

Copying code to equalize edit-application timing is cancelled. Native and the walker may apply an edit
at different times before endturn; namespace independence remains. Bindings use hidden arguments ([executors](#binding-executors)) without
an environment copy. Graph edits neither clear native nor start checking/compilation.
Methods and ordinary Structures share compilation without data=code: the data of the selected occurrence is its `parent`;
different actuals and different modes of hidden inputs yield different
C signatures, and a header without code describes a call.

Local frames are not published. Load-dirty, the shared direct-access cache, and flush() are cancelled; explicit writes
are observed through actual aliases in execution order. [Agreed norm](LMX_semantics.en.md#call-frame-20261115).

<a id="binding-executors"></a>
### Native code, the walker and the bridge

A direct native-to-native call is kept wherever the selected implementation, types and binding are known. Autofill is
lowered as a parameter of the same `T` as an explicit actual; the transparent caller place, as a hidden address of the
caller's cell; the former binding (fallback) gives an own place. A common C body may be shared between modes through
adapters, and an adapter must preserve the owner of the record and the behaviour of `@`. With identical explicit actuals
the mode of a particular hidden input may differ because of the caller's context and `private`: an existing native entry
must match the real contract or receive a correct description of the place. One code may have several actual signatures,
including a single explicit contract with different place modes (own copy, caller's place). The adapter uses the
existing ABI and place descriptors to preserve that distinction; no new user pointer types are introduced. Service C
functions, the bridge and the `call` dispatcher do not replace the caller's context with their own service locals: the
language's sources are determined by the program location of the call.

An ordinary native local has no arena header `[type][value]` ([L2 §3](L2_spec_en.md#value-record)): its type cannot be read
from the four bytes before its address. The type, the access mode, the initialization state and the applicable restrictions of the place follow
the common place representation and the call contract. The four combinations -- native to native, native to walker,
walker to native, walker to walker -- give one observable behaviour: `x` has one logical type `T`, and a permitted
write changes the same logical place. For a run-time target unknown at translation the existing
mechanism of access to the permitted local contexts is kept; the raw C stack is not explored as a dictionary of LMX names,
and there is no static transitive closure of requirements.

Load-dirty, flush, publication of local frames and copy-back on exits are not brought back. A read through an
alias is not turned into a snapshot without proof that the observable behaviour under nested calls is kept.
Explicit compilation, the existing native/walker choice and the endturn boundary are kept; the absence of a suitable
native entry does not start hidden compilation; there are no permanent caches of all environments and no automatic
graph invalidation. `restrict` is not applied merely because a pointer is passed hidden or because of `private`: such a C contract needs
a separate proof that no forbidden overlaps exist.

A transparent link does not extend lifetime; the address of a temporary C local does not become a portable structural reference,
and the rules of Message and arenas do not change. At `yield` the selected binding is not rebound to a same-named local of the new
caller: resumption uses the state of the saved activation and the ordinary lifetime restrictions.
[Norm](LMX_semantics.en.md#binding-executors).

<a id="call"></a>
## 12. Calls and explicit compilation

Known native calls the known variant directly in C using the selected actual signature and necessary
hidden arguments. Arranging this call needs no graph, call-table lookup, universal actual packaging,
or trampoline. Dynamic calls select variants in call tables; their internal ABI is not mandatory
packaging for all static calls.

sys\compile(S) explicitly performs clean-graph construction/checking → L1 → C → the required build/test phase (interpreted) → machine compilation,
only if the tests passed, and entry registration; sys\translate returns only L1 and diagnostics. Graph writes are not tracked
for native: no automatic reset, reverse invalidation, or rebuild. For a direct A→B chain, updating A
requires compiling the unit with A and the needed B, not merely replacing B's table record.
The maintained compiler source remains L2/L3; L1/C are generated artifacts.

sys\endturn() lowers through the common system-exit mechanism with finally to the turn boundary.
Ordinary catch does not intercept it; the call does not return or retain a stack continuation.
The receiver itself changes neither running nor success. After successful explicit compilation and
endturn, the next entry uses the prepared update; without compilation endturn detects and repairs
no edits. It is neither flush nor local publication. See [L2](L2_spec_en.md#explicit-compilation).

<a id="child"></a>
## 13. Child

A child is built in its own arena. Publication adds its reference to `Thread.children` without appending a field to the source Structure. See [L2 §12](L2_spec_en.md#child).

<a id="copy-merge"></a>
## 14. Copy and merge

`lmx_graph_copy_owned` and `lmx_merge_owned` use a common source→copy map for fields, internal references, and parent. Native descriptors and ordinary native fields follow ordinary graph-copy rules; copying does not prove machine-entry suitability for a new Structure or register it automatically. Explicit compilation or restoration of saved tables for the selected root establishes entry bindings. See [L2](L2_spec_en.md#copy-merge).

sys\toLmx of a selected L3 Thread saves all tables of its arena, including call/native, not merely
R0's fields. sys\fromLmx restores the clean graph and ready ABI-compatible binary bindings after
a same-platform restart by module/entry name, without retranslating.
External tables are not automatically attached to an arbitrary S.

<a id="satisfies"></a>
## 15. satisfies

An established correspondence maps required model fields to the candidate's actual physical fields, including differing
field order. It belongs to the reception or traversal that obtained it and is retained for those reads, address-taking
operations and explicit graph writes. The arena has no persistent store of these concrete field/namespace maps
and no separate map for `call` or DATA; call-local places are not published. The common kernel's required
table of completed directed TYPE-pair checks is separate metadata: stable complete requirements reuse a
result under the applicable type/conversion context without retaining a concrete reception map.
Different field order cannot be reduced to identity ordinals; reading,
address-taking, and explicit writes to the original graph follow that same correspondence.
In data every declaring form is an occurrence of the name: a repeated declaration neither
replaces the former one nor writes into it, and a name with two or more occurrences is addressed only with the index of
an occurrence (the author's decision of 2026-11-11, [L3](LMX_semantics.en.md#fields)); “last occurrence” selection is
not part of the new contract. `s\[N]field` with zero-based `N` addresses the Nth occurrence of the name -- a form of the
data that declares that name -- not an Array element. The map holds no runtime names and does not itself keep the graph
alive. See [L2 §14](L2_spec_en.md#satisfies).

<a id="gc"></a>
## 16. Collection

`lmx_gc_collect` implements collection from arena roots including Message, graph, mail, and `Thread.children`. Simple arena mode does not collect. See [L2 §15](L2_spec_en.md#gc).

<a id="c99"></a>
## 17. C99 output

One translator invocation emits one `.c`. Strict compilation uses `-std=c99 -Wall -Wextra -Wpedantic` and diagnostics for incompatible pointers, discarded qualifiers, and implicit declarations. `struct:`, `enum:`, `fnptr:`, and `type:` lower to C declarations. This does not alter the arena memory model.

<a id="lowlevel-scope"></a>
## 18. Machine surface

L1 retains the target platform's C99 representation and numeric semantics. An L1 variable or C aggregate field is not automatically an Lmx graph cell; graph access goes through the kernel library. Identical spellings in L1 and L2 need not denote the same semantic operation.

<a id="lowlevel-address"></a>
## 19. Pointers and fields

| L1 | C99 |
| --- | --- |
| `int@: p` | `int *p` |
| `char@@: pp` | `char **pp` |
| `p := @x` | `p = &x` |
| `\p` | `*p` |
| `\p := value` | `(*p) = value` |
| `p\field` | `p->field` |
| `a[i] := value` | `a[i] = value` |

The table states the target unified spelling; transitional hand-written L1 may still need declaration-order migration. An addressable target needs valid C storage. `value\field` is a pointer step; by-value C aggregate access needs an explicit C form. `const: char@: p` lowers to `const char *p` and protects the characters, not the pointer cell. This is not L3 deep immutability.

Ordinary Array indexing has no from-end interpretation: `array[-1]` is not a valid way to select the last element. Negative relative offsets should be expressed through a suitable pointer, for example `\(p - 1)`, under its ordinary lifetime/allocation contract. L3 and interpreted L2 apply the existing final-element bounds check. Native L2 omits those automatic checks; their absence does not make an invalid Array access valid. A statically known invalid Array index may be diagnosed during preparation, without adding a native runtime sign/bounds check. A negative slice bound is different: `array[-1:]` selects the last element through the [slice contract](TERNARY_AND_SLICES.en.md#negative-index). Reads, writes and address-taking retain one common address calculation; no per-coordinate bounds checks or hidden row descriptors are added.

<a id="lowlevel-array"></a>
## 20. Array and raw C arrays

Ordinary `[]:` in L1 as well as L2/L3 denotes a language Array: a graph Structure on the shared `Lmx` base with typed
elements and structural `parent`. Only the explicit `c.array:` door selects a raw contiguous C array without graph
`Lmx`, arena, or hidden bounds checks. A rectangular raw array does not become an array of separately allocated rows.
Automatic C-array lifetime follows C99; it is not identified with a graph Array. The former lowering of bare L1 `[]:`
directly to a C array is an implementation state to remove.

<a id="lowlevel-abi"></a>
## 21. Casts and C ABI

`cast: (T) expression` emits an explicit C cast, not an L3 checked conversion. `c.name` is an explicit foreign C symbol. `foreign: Name` requires a type definition in an included C header; `external` and `prototype` describe export and declaration, while `include` and `predef` select explicit dependencies. Header source `name.h.lm1` emits `name.lm1.h` and permits declarations without executable bodies. A by-value field needs a complete C type; a pointer permits a forward declaration.

<a id="lowlevel-expression"></a>
## 22. Expressions and control

L1 lowers C arithmetic, logic, bitwise operations, `++/--`, and ordinary control flow. Source `=` in a comparison becomes `==`; `target: expression` is assignment. `switch` permits C fallthrough, unlike L3 `match`. L1 `throw/catch/finally` with a machine service payload does not define typed L2/L3 failures.

<a id="lowlevel-sync"></a>
## 23. Synchronization

L1 does not define the structural `synchronized` receiver. The kernel uses explicit machine and foreign atomic operations; `volatile` is not atomicity. The `synchronized` contract belongs to [L2](L2_spec_en.md#lowlevel-sync).

<!-- receiver-integration-2026-11-22 -->
<a id="receiver-library-l1-boundary"></a>
## Boundary for the new L3 receiver library

The new functional receivers remain L3/library algorithms over ordinary graph
records and calls. Their L1 lowering does not introduce special lambda,
container or curry opcodes, a second program graph or native program fields.
Where explicitly compiled, generated callables lower to real methods with
their established typed ABI. `satisfies` is the current name of the admission
mechanism. See [L2 integration](L2_spec_en.md#functional-receiver-abi) and the
[kernel integration](kernel-implementation.en.md#receiver-kernel-integration).

<a id="unified-20261122"></a>
## Lowering of current derived types

Lowering consumes the complete head and resolved full type from the same common path as interpretation. It may specialize actual dense layouts or direct calls when proven, while preserving dynamic admission, missing actuals, computed defaults, declared exits, and the source graph. T[] and T@ are int-valued type constructors, not alternate prefixes. No payload is read from uninit:T, and an accepted array requirement does not change its actual stride. See [the current unified contract](CORE_SEQUENCES_REGEX.en.md).
