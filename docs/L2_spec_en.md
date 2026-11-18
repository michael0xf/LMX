# L2 Specification

L2 defines the kernel mechanisms and machine operations. L3 semantics are in the [LMX specification](LMX_semantics.en.md), syntax in the [grammar](LMX_grammar.en.md), and C99 lowering in [L1](L1_spec_en.md). This document does not restate head resolution, declaration, or call rules. Implementation status belongs to the [notes](implementation-notes.en.md).

**Implementation status, 2026-11-14, slice392:** bounded code gates for the common borrowed receiving/name reader passed;
G2 render35/14, both snapshots and docs-check01/final index02 PASS; generated semantics/grammar unchanged. Commit/push follow.
Model/default remain source descriptions, and `c_names` is a role projection only; this establishes neither typed storage/admission
nor alias unification. Full M11/M13/M14 remain OPEN. [Contract and checks392](kernel-implementation.en.md).

<a id="scope"></a>
## 1. Scope

The target chain is L3 with L2 insertions → generated L1 → C99. L1 is an intermediate language. The interpreter executes the stored graph: L2 code with the same checks as L3 code, and an address operation that L3 does not have at all with checks of its own. Native L2 code is compiled without these checks ([semantics, §1](LMX_semantics.en.md#scope)).

<a id="lmx"></a>
## 2. The `Lmx` structure

Structures and Arrays share a flat `parent/length/storage` header, without native, capacity,
or an embedded VoidArray. In L2 order: `@: parent Lmx`, `size_t: length`, `@: storage void`.
A reference points to the header's start; the code of the record's type stands in the four bytes
before it ([§3](#value-record)). Structure and Array<@> store void* elements and are fully
interchangeable in indexing, named paths, admission, copying, and execution.
Numeric Array<T> stores T itself; the code of the Array's record tells the element type.

Parent is the structural parent. Passing an existing value's reference neither changes parent nor
expands it into the tree. An Array descriptor retains its address; length and storage use common size
management. Separate fixed-Array and specially growing List contracts are cancelled.
Native descriptors reside in call tables; fn/sub/catch have an ordinary native reference field added
during translation if absent. Other Structures receive no automatic field.
[Norm](LMX_semantics.en.md#explicit-compilation), [open M13 migration](../next_core_tasks_v3.md#flat-lmx-descriptor).

<a id="interpretable-tree"></a>
### 2.1. Interpretable tree

The clean graph retains written declarations, operators, values, and nested bodies; C emission does
not rearrange them. A primitive cell needs no extra leaf wrapper. Names reside in the common canonical
string-address table, not in Lmx. A launch supplies the data/code roles.
A direct data pass executes only root-level declaration receivers under their general rules.

Ordinary operations can construct and change a graph. Writes are not tracked for native, do not check
future executability, and do not start compilation. The builder and explicitly invoked sys tools check
a clean graph. The walker executes admissible L3; explicit compilation updates machine execution.
`sys\toLmx(S)` saves selected S in its current form, without reconstructing earlier source.
See [semantics](LMX_semantics.en.md#source-codec).

<a id="get-descriptor"></a>
### 2.2. descriptor and actual header fields

`sys\descriptor(S)` returns an ordinary Structure of S's live field addresses. Without an argument it
selects the current launch's data, including inside nested control bodies. Code is explicit.

```text
(
    @@: parent Lmx
    @: length size_t
    @@: storage void
)
```

Machine types are Lmx**, size_t*, void**. `\(d\length) := n` changes S.length;
`d\length := p` changes only the pointer in d. This is neither a copy, proxy, nor write-back.
Writing length itself allocates no storage; sys\resize performs coordinated resizing.
Native and capacity are absent from the result because they are not header fields. Obtaining descriptor
does not extend S's lifetime. The first field's address may equal S, but typed dereferencing does not
classify it as another standalone Lmx. Pointer depth is arbitrary and finite.

<a id="header-receivers"></a>
### 2.3. Reading the header and service tables

parent(S), length(S), sys\storage(S) directly read parent, length, storage.
sys\native(S) returns the ordinary native descriptor from call tables, including signature variants,
or 0 when absent. sys\capacity(S) reads capacity in elements from the arena table.
These queries construct no auxiliary descriptor. Every zero-argument form selects current data;
code requires an explicit argument. A same-headed data form remains an ordinary Structure like data\for.
Ordinary paths S\parent, S\length, S\storage, and S\native select written fields without pseudo-fields.

Data/code remain launch arguments and node the existing activation context.
sys\resize(S, n) changes length and provides storage; sys\reserve(S, n) ensures capacity without changing
length. All auxiliary operations belong to sys and reserve no global member names.

<a id="system-indexof"></a>
### 2.4. A field's index

`sys\indexof(field parent)` returns the physical index of the unique occurrence of `field` among
the immediate elements of Structure `parent`. An absent field or multiple occurrences of the same
reference produce an error under the ordinary failure rules.

`sys\indexof(field index parent)` selects occurrence `index` of that same reference, counted from zero,
and returns its physical index in `parent`. A missing selected occurrence is an error.
The occurrence number and returned index differ: when a reference occurs at positions 2 and 5,
`index = 1` returns 5. Both forms receive `parent` explicitly; there is no zero-argument form.

Lookup uses the field's identity/reference, not an equal name or primitive value. It follows neither
nested Structures nor graph references. Structure and Array<@> use one mechanism for reading immediate
elements. Reuse existing addressing; no reverse-index table or per-write maintenance is needed.

<a id="type-by-range"></a>
<a id="value-record"></a>
## 3. Value record: the type beside the value

**Author's decision of 2026-11-16** ([journal](../LMX_blog/2026-11-16.md#typed-value-raw-layout)): the physical type and the value are stored in one record, and both are obtained from the record itself. The earlier scheme of this section -- a cell without a type tag, whose type the arena learnt by classifying its address through registered ranges -- is superseded. The code still executes the earlier scheme; the transition is [M15](../next_core_tasks_v3.md#typed-value-records).

A value that a Structure or `Array<@>` slot, a reference or `parent` refers to is a **record**: `int type`, the code of its physical type, and immediately after it, without a gap, exactly as many raw bytes as a value of that type occupies -- a number, a reference, or the `parent/length/storage` descriptor of a Structure or an Array. The elements of an Array and the slots of a Structure lie in the storage that the descriptor names, not in the record. The size of a record is `sizeof(int) + size(type)`: no record reserves room for the largest kind of value, and the layout does not follow the rules of a C `union`.

Every slot, and every other reference of the graph, holds one pointer: the address of the value. The code of its type stands in the four bytes right before that address (the author's answer of 2026-11-16, [journal](../LMX_blog/2026-11-16.md#typed-value-reference-answer)). So an address keeps the meaning it has always had -- the address of an `int` cell, the address of a header -- and `@x`, `parent`, the name table and the C door use it unchanged. A read of a known type takes the value at the pointer; a read of a type unknown at translation reads the code four bytes before it and then the value:

```text
p = storage[index]     # the slot: the address of the value
code at p - 4          # the code of the physical type
value at p             # the raw bytes of that type
```

**No operation learns a type or reads a value by classifying an address.** Reading and writing a slot, loading a value of a type unknown at translation, `sys\typeof`, indexing, dereferencing, admission by `implements`, copying, `merge` and collection take the kind and the size of a value from the code in its record. The arena's index of address intervals stays only for ownership: which arena and which chunk an address belongs to.

**Alignment** (the author left the choice to the implementation: optimal and universal, not by `union` rules). A value stands at an address aligned as its type requires, but not less than four; the code occupies the four bytes immediately before it; padding, where needed, lies between records. So the code and the value are read and written by ordinary typed, aligned accesses on every platform, not by copying bytes, and the descriptor fields keep their natural alignment. With eight-byte pointers a record of `int` takes 8 bytes, a record of `double`, `size_t` or a reference 12 bytes and a step of 16, a descriptor 28 bytes and a step of 32. The measured grounds are in the [research record](../steps/witnesses/typed-value-research-20261116/notes.md): for an eight-byte field inside the cache a typed access to an aligned value costs 0.97 ns and copying its bytes 2.20 ns.

The inventory of physical types is the former inventory of region types ([kernel specification §2.2](kernel-implementation.en.md#arena)): number primitives, the word, the reference, “T without initialization”, the ordinary, immutable and `fn`-result Structure, an Array with its element type. A user model produces no code of its own: `implements`, not the physical type, establishes model compatibility. An ordinary and an `immutable` Structure differ by the code; an already published ordinary Structure cannot become `immutable` in place. The old layout in which `Lmx` contains `VoidArray` remains transitional, not the template for the new Array variants.

A numeric `Array<T>` stores T itself, densely and without codes; the code of the Array's record tells the element type. The address of such an element is a raw L2 address, not a pointer to a record. A typed native local or a temporary result is an ordinary machine value and is not packed into a record.

For every primitive type T there is a distinct type “T without initialization”. A declaration without an initializer has one record: the code `uninit:T` and, right after it, a complete record of T -- the code of T and the cell of T:

| Declaration | How the Structure field reaches the value |
|---|---|
| `int: x` | Field → record `uninit:int`, whose value is the record `int` of `x` |
| `int: x 0` | Field → record `int` of `x`, initially 0 |

Here a Structure field is an address-holding cell, called a “slot” in the kernel specification.
A value record is a type and a value. An assignment into a place of the graph (`data\x := 5`) writes the value, and if
the type of the record is another one -- “T without initialization” -- changes it too: after that the place holds an
ordinary T (the author's decision of 2026-11-17, [journal](../LMX_blog/2026-11-17.md#assignment-changes-type)). The rule of 2026-11-08
that the type of the place does not change on the first assignment is withdrawn. The address of the value stays the
same: a previously taken `@x` addresses that same cell. `sys\typeof` of the place answers `uninit:int` before the write
and `int` after it; the language type of `x` is `int` in both cases.
An assignment to a local of the call (`a := 5` for a formal that received no value) writes into the place of the call:
the graph does not change and the data are not published.
The absence of a value is written `nil: T`, and simply `nil` where possible; a variable can be compared with `nil`
(the author's decision of 2026-11-17, [journal](../LMX_blog/2026-11-17.md#typed-nil)).
Today's code still leaves the `uninit:T` record after an assignment; a separate slice brings it to the norm
([plan](../next_core_tasks_v3.md#typed-nil-plan)).
See [kernel specification §3.2](kernel-implementation.en.md#primitive-storage) for the representation.

<a id="pool"></a>
## 4. Allocation of records

Records are issued from the chunks of the arena. A chunk is never reallocated: growth adds a chunk, and an issued address stays stable until its ownership is released. How the arena divides its memory into chunks is the allocator's matter, not a contract: a chunk may hold records of one type and one step, as the present pools do, or records of several types one after another. Nothing reads a type from a chunk or from an address. The transition has two stages by the author's order of 2026-11-16 ([journal](../LMX_blog/2026-11-16.md#typed-value-two-stages)). First the records live inside the present typed chunks: a cell of a pool becomes a record with the step of that pool, which gives the alignment of [§3](#value-record) by itself. Then the chunks by type are removed and the records of an arena go in one stream, where the descriptor, the slots and the fields of one Structure lie side by side.

In a graph Array, `void *storage` holds the address of the element storage. For a numeric `Array<T>` it is a dense block of T; L2 obtains a pointer to the actual element type from the code of the Array's record, not by classifying the storage address. A pre-existing block of `void *` slots cannot be read as an arbitrary `T` array merely by casting its pointer. Addressable graph-reference slots retain their own `void **` and stored-value conversion contract.

<a id="method-array"></a>
## 5. Native entry and Array

Native is an ordinary descriptor in call tables containing entry variants, signatures, binary-module/entry names, and L1/C paths. Machine addresses are bindings of the current process, not persistent addresses for another run. A language Array has the common Lmx base and variable length/capacity; typed storage may move. Strings remain exact-length char Arrays without trailing NUL; NUL belongs to the C door.

<a id="arena"></a>
## 6. Arena

Each Message owns one logical arena, which may contain multiple chunks. `lmx_arena_attach` transfers ownership without moving addresses: the chunks of the attached arena become chunks of the receiver, their records keep their addresses and codes, and nothing is registered anew to tell their types. One arena is never accessed from several threads, so the codes and the allocation need no synchronization. `mark/revert` rolls back a failed copy or `merge` construction. Simple mode retains address stability but does not run GC. An independent immutable branch may remain in its owner's arena under the [L3 contract](LMX_semantics.en.md#eternal); a separate pool alone grants no such right.


<a id="array-capacity"></a>
### 6.1. Common variable-size Arrays and capacity

Allocation and resizing use the common dynamic-array mechanism, including service arrays.
The arena stores “descriptor address → capacity” in elements. Neither Lmx nor a hidden prefix contains
capacity; remove a separate VoidDynamicArray family introduced merely for growth.
Maintain the table on allocation/resizing/release, not on every indexed access.
Stable standalone cells and canonical strings do not move; this requires no separate Array per cell.
Restoration may begin with capacity = length.

An L3 Array-element pointer has its own type with an Array-descriptor reference and explicit index.
It stores no storage address: access derives the element address from the current header and final offset.
Moving storage needs no pointer traversal. L3 primitive pointers also have their own type;
reuse typed-reference and uninit:T foundations while retaining the distinction between a reference and absence.
An L2 pointer remains a raw address. Arbitrary finite pointer depth and Array rank share general mechanisms.

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

`inbox` is a ring over a common variable-size Array with external capacity. One reentrant LmxPost monitor covers admission, take, and count; outbox/staged remain owner-local. Post uses the same mailbox; see the [language API](LMX_semantics.en.md#thread-message-api).

<a id="own"></a>
## 10. Structure execution

Execution uses the source Structure and a local namespace under the [norm](LMX_semantics.en.md#call-frame-20261115). Locals are not published and element assignment does not change length. Explicit common operations change size. Edit-application timing for executable code follows the [endturn boundary](LMX_semantics.en.md#explicit-compilation).

<a id="call"></a>
## 11. Call

<a id="call-receivers"></a>
### The `call` and `fncall` receivers

| Form | Supplied values `args` | Input `data` | Result |
|---|---|---|---|
| `call(args data code)` | `args` | `data` | none |
| `call(data code)` | not supplied | `data` | none |
| `call(code)` | not supplied | `code` | none |
| `fncall(args data return code)` | `args` | `data` | according to `return` |
| `fncall(data return code)` | not supplied | `data` | according to `return` |
| `fncall(return code)` | not supplied | `code` | according to `return` |

`args` is the Structure of actual supplied values, exactly the argument Structure
of an ordinary `call`. It is not formal declarations, a signature, or a separate
callable part. `data` describes input places, requirements, and defaults.
`return` describes the result; `code` is the executable Structure. `call` returns
no value; `fncall` returns a result according to `return`.

Forms without `args` supply no additional actual values. Omitted `data` means `code`
itself: `call(C)` equals `call(C C)`, and `fncall(R C)` equals `fncall(C R C)`.
A child `data` field inside `code` is not selected automatically. These are
abbreviations of one operation, without requiring an empty Structure allocation
or a new service object for omitted `args`.

All forms and ordinary method/Structure calls share one interpreter path:
select parts → bind actuals to data → common admission → fresh namespace → execution and result.
Receiving actuals neither changes source data nor runs entry initializers.
Calls from test and converters use the same mechanism. Known native-to-native calls
may still go directly through C without graph packaging.
[Full contract and named arguments](LMX_semantics.en.md#call-receivers).

<a id="private-binding"></a>
### Receiver private:

`private:` excludes the marked field and its corresponding binding from a call's dynamic
sources. Direct visibility from anywhere, explicit paths, and ordinary lexical lookup remain;
sequential visibility and explicit argument passing do not change.
Skipping the field follows the common binding order for every call/fncall form, ordinary call,
interpreter and native execution. This is a field property, not a global name ban or access
protection. Use the common binder without a separate registry or checks on direct reads.
[Full contract](LMX_semantics.en.md#private-binding).

<a id="call-frame-20261115"></a>
Every call creates its own namespace. For fn/sub/catch, unified data describes the inputs;
args in call/fncall contains actual values. Short headers remain. An actual replaces the corresponding
source declaration in the frame, and its initializer does not execute. Preparation collects only
data/code roots, without visiting branches or graph references or auto-filling source data.

Entry has no initializer-execution phase. Ready declarations fold during clean-graph construction
without program calls; uninit:T remains. An unused computed data field is not executed.
Reading obtains its value through the common mechanism, as with `data\field`: the written RHS
executes, not an implicit call on the obtained reference. Given `@: fptr getFuncPtr()`,
`fptr("hello world")` first obtains the pointer, then calls the resulting function.

Variables and const are visible from their initial declaration onward in their scope and below.
Names of Structures and callables retain bidirectional visibility; a function-pointer variable does not.
A new branch name does not escape its branch. Repeated `int: x bump()` retains evaluation,
admission, and assignment to existing x; only the repeated C declaration is omitted. Physical repeated
fields remain and are selected by `S\[n]x`. An explicit path is not restricted by the declaration
order of a bare name. A read through a path executes nothing; the RHS is executed when its code statement is reached.

Bare x and @x refer to the frame place, independently of source-field replacement immediately at entry,
even before the first read: the selected value or computed description is retained.
The rule is the same for explicit data, lexical binding, and dynamic binding. It does not deep-copy
referenced objects. `x := 0` changes the namespace; `data\x := 0` changes the source graph.
For computed input `int: x next()`, @x obtains the value and the local cell's address.
With `@(data\field)` and source `int: field getValue()`, the record of the declaration is addressed, not
getValue()'s result: an explicit path executes nothing (the author's decision of 2026-11-17; the former rule is withdrawn).
A ready place is addressed directly.
Lifetime remains ordinary. @f() was a research example, not a separate support or prohibition task.

A mandatory executable-code snapshot at entry is cancelled. Edit-application timing before endturn
is unspecified. Selected namespace values/descriptions remain independent of source data;
bindings use hidden arguments and the environment is not copied. Methods and ordinary Structures
share compilation without data=code; different actuals yield different C signatures.
Graph writes do not clear native: updates require explicit compilation.

Local frames are not published. Load-dirty, the shared direct-access cache, and flush() are cancelled;
explicit writes are observed through actual aliases in execution order.
[Agreed norm](LMX_semantics.en.md#call-frame-20261115),
[single M14 task](../next_core_tasks_v3.md#native-structures).

<a id="native-structures"></a>
<a id="direct-access-cache"></a>
<a id="explicit-compilation"></a>
### 11.1. Explicit compilation and direct native calls

`sys\compile(S)` means clean-graph construction/checking → L1 → C → machine compilation →
registration of resulting variants in call tables. Reuse working builder code;
runtime receives only the parts needed for this concrete operation. sys\translate returns L1 and errors,
not LMX or installed native. Failed compilation installs no new entry.

Known native code calls the known variant directly in C with actual and hidden arguments.
That call needs no graph packaging, call-table lookup, or universal trampoline.
Dynamic selection uses call tables. One code may have multiple actual signatures.
Explicit program data/code accesses and necessary reference passing remain.

Graph edits are not tracked for native. Remove automatic clearing, dependency scans, reverse
invalidation tables and maintenance, transfers, and generation. Do not replace them with dirty,
versions, per-endturn hashing, or a universal journal. Ordinary memory mechanisms remain only
for their actual purposes. Without explicit compilation machine code need not refresh.

For a direct A→B link, compiling only B does not rewrite old A. Updating that chain requires explicit
compilation of a common unit containing the needed callers and targets. This is builder work,
not a check at every call. Ready binaries of the corresponding ABI can bind to a restored clean
graph without retranslating it. ToLmx saves the selected Structure; for an L3 Thread this includes
all tables of its arena, including call/native. The arena owns them, not R0's fields;
external tables are not automatically attached to arbitrary S.

<a id="endturn-receiver"></a>
### 11.2. sys\endturn

sys\endturn() ends the current turn through the common exit mechanism. Registered finally cleanups
of exited scopes run in reverse order; ordinary catch does not intercept this system exit.
It neither returns to its call site nor retains a stack continuation.
Ordinary turn-boundary processing follows cleanup. The receiver itself changes neither running nor
success and does not complete the Message; a subsequent turn starts at its ordinary entry.
Before the boundary, edit-application timing may differ between walker and native.
After successful explicit compilation and endturn the next entry uses the prepared update.
Endturn alone detects no changes, compiles nothing, and publishes no locals; it is not flush.
Old machine code is not released while its frames and finally cleanups are still executing.
[Norm](LMX_semantics.en.md#endturn-receiver), [source](../LMX_blog/2026-11-15-explicit-compilation.md).

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

The proven mapping from used fields of the receiving model to physical fields of the candidate for an admitted pair of Structures is data of the reception or traversal that established it (the author's decision of 2026-11-08 on service traversal tables, confirmed by Codex; [implementation specification §5.2](kernel-implementation.en.md#tables)): a reception holds its map for the duration of the operations it needs -- reads, address taking, and explicit writes to the original graph, including differing field order -- and the next traversal rebuilds it from the graph; the arena keeps no persistent store of mappings, and there is no separate map for `call` or `data`. Call-local places are not published back into the graph. The interface-checking part of `implements` is performed once for each candidate: at clean-graph construction if the candidate is known, or at run time if selected dynamically ([cases](../steps/implements-runtime-cases-20261111.md)). Graph construction does not execute `test`; for a dynamic candidate it is the second admission step ([the author's clarification of 2026-11-13](../LMX_blog/2026-11-13.md#implements-and-test-phases)). An assignment of primitives is not checked for admissibility at run time (the author's decision of 2026-11-11, [L3](LMX_semantics.en.md#data-code-roles); the rule speaks of the admission `implements`, not of conversion: the range check on receiving a number of another type, `u16(256)` into `u8`, remains at run time); the translators do not execute this rule yet ([plan](../next_core_tasks_v3.md#m11)). In data every declaring form is an occurrence of the name: a sole occurrence is addressed `s\field`, with two or more the name is addressed only with the index of an occurrence -- a repeated declaration neither replaces the former one nor writes into it ([L3](LMX_semantics.en.md#fields)); `s\[N]field` with zero-based `N` addresses the Nth occurrence of the name -- a form of the data that declares that name -- not an Array element. The map does not look up runtime names, copy the candidate, or waive a new Consumer's checks. Admission semantics and explicit tests are in [L3 §7](LMX_semantics.en.md#admission).

<a id="gc"></a>
## 15. Collection

GC belongs to the arena. The kind and the size of every traced value come from the code of its record ([§3](#value-record)). Roots include Message, live graph, mail, execution state, and `Thread.children`; Thread state retains that List independently of source fields. From a live value, collection also follows an established `implements` correspondence to its required Structure: replacing a graph field does not release the model while that value still needs its admission. This rule does not retain a transient admitting frame; retirement of the frame removes a record that depends on it. These are address-proof dependencies, not hidden graph fields. The owner retains constructed `independent: immutable` branches until its arena is destroyed. Simple mode does not collect. Unloading a later module needs a separate contract and is not invented here.

<a id="special"></a>
## 16. Special L2 operations

The kernel provides record allocation, the reading of a record's type, arena attach/revert, mail, Thread turns, calls, child reservation, copying/merge, and collection. These operations do not create another namespace or auxiliary execution graph.

<a id="lowlevel-scope"></a>
## 17. Machine profile

L2 machine types retain the representation and numeric semantics of corresponding target-platform C99 types, including the signedness of plain `char`. L3 does not gain raw memory access merely because its graph uses pointers internally. L1 has a separate C-like surface.

<a id="lowlevel-address"></a>
## 18. Addresses, loading, and writing

Field addresses returned by [descriptor](#get-descriptor) are actual typed places:
`Lmx **`, `size_t *`, `void **`. This differs from an ordinary graph-slot
address `void **`: it cannot arbitrarily be read as `Lmx **`, whereas S.parent itself
really has type `Lmx *`. Even if S.parent and S share a numeric address, an explicit
dereference reads the field by its type. Loading and writing are general for any finite
pointer depth, including references and function pointers. Explicit `S\field := value`
and dereferenced writes are not assignment through a bare Structure or function name
and are not prohibited by that rule.

M3 orders flat declarations as name followed by requirement/value. A place is declared by the `@:` form enumerating its arguments: `@: p 0`, `@: p Model`, `@: p Model 0`, `@: p Model Other`; the form with the place in the outer head (`ptr: @: Model: 0`), which N1–N6 admitted, is withdrawn by the author's decision of 2026-11-10 ([semantics](LMX_semantics.en.md#receiver-args-only)). The first field is the place-name atom and is not invoked; the other fields are consumed under the ordinary expression rule: the arguments of a receiver are read by the one general algorithm, as code. A requirement with a candidate is written flat, in three fields: `@: p Model Other`, and a null address `@: p Model 0`. The nested form `@: p Model: Other` does not write a requirement with a candidate: `Model: Other` among the arguments of a receiver is a call of `Model` (a consequence of the author's decision of 2026-11-11 on the reading of arguments, [the roles `data` and `code`](LMX_semantics.en.md#data-code-roles); the executor's reading -- [answers](../LMX_blog/q/fable-self-answers-20261110.md), О4); a launch form of a Structure at a place where a value is needed (an operand of an expression, an actual argument of a call, an initial value, an operand of `merge`) is an error: a launch has no result (the executor's reading, Р22, item 3; Р25, item 4). P0 does not single out these forms: parsing is common, while the `@:` contract assigns field roles. Initial `@: p` or `@: p 0` creates a void reference; a later address write does not retroactively add a requirement. Pointer depth `@ⁿ:` has no arbitrary numerical cap.

In `@: ptr method`, the `@` receiver comes first, while `ptr` and `method` are bare atoms: an atom is not a call. The form therefore assigns a reference to `ptr` under the `@` contract even when `ptr` already contains a callable; `ptr(args)` invokes it. Unary `@ptr` separately takes the reference cell's address. The detailed rules of the special name `data` and of these forms are in [L3](LMX_semantics.en.md#ordinary-var) and [method-reference assignment](LMX_semantics.en.md#method-reference-assignment).

For a namespace variable, unary `@x` addresses the current call's real local cell. For computed input `int: x next()`, `@x` obtains its value and the address of its ordinary local int cell. When `data\x` selects a ready source-graph place, `@(data\x)` retains that place's own address. When data retains computed declaration `int: field getValue()`, `@(data\field)` addresses the record of the declaration and getValue() is not executed: an explicit path executes nothing (the author's decision of 2026-11-17). Explicit `data\field := ...` changes the source field. No automatic transfer connects the local place and the graph. [Common rule](LMX_semantics.en.md#computed-field-address).

In the existing native path, `emit_call_result_value` declares typed `l2_tN`, and `emit_dyn_tail_value` passes `&l2_tN` as the result destination. Reuse this place when taking the address, without another call, a second cell, or a special allocation for `@`. The walker uses the ordinary addressable result cell. The existing place's ordinary lifetime rules apply.

A reference field retains its exact pointer type; a primitive uses its typed cell. An ordinary graph slot physically holds void*; an alias through Lmx** does not replace that representation. Pointer depth is unrestricted; an evaluation temporary's address does not replace a ready place's own address.

Prefix `\p` follows a reference; `p\field` accesses either a graph field or an explicitly imported machine ABI according to `p`'s category. `@array[i]` addresses the actual backing element. Native L2 code adds no automatic bounds check; checked access belongs to L3, and the interpreter executes L2 code with the same checks. Address operations neither bypass `const`/`immutable` nor extend target lifetime.

L2 indexing `[]`, `[][]`, `[][][]` of arbitrary finite rank, including `array[-1]`, computes an offset
without length, sign, arena, or former-field checks. Reads, writes, and address-taking share one path.
In L3 adjacent indices reduce to one linear index and one check against current length;
per-coordinate checks, temporary rows, and intermediate descriptors are unnecessary.

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
