# L1 Specification

L1 is the generated intermediate representation used to lower the kernel to C99. Graph-language rules belong to [L3](LMX_semantics.en.md) and [L2](L2_spec_en.md); only the C projection remains here. Current translator status and transitional hand-written L1 belong to the [implementation notes](implementation-notes.en.md).

<a id="scope"></a>
## 1. Scope

`l1trans` lowers `.lm1` to one C99 translation unit. L1 itself does not define arenas, `implements`, or graph visibility as language operations. The kernel library implements them explicitly. The self-build target is L3 with L2 insertions; L1 remains intermediate.

<a id="translator"></a>
## 2. Translator

L1 resolves its C-like declarations and expressions. Prefix `@x` takes the address of C cell `x`, prefix `\p` loads through a pointer, and `p\field` accesses a field through a pointer. Declarative `@ⁿ:` sets the corresponding C pointer depth. The historical argument order for pointer declarations in hand-written L1 is not a permanent exception: target intermediate L1 must follow the shared L2/L3 order “name, requirement, value.” Foreign C symbols use explicit `c.name`.

<a id="lmx"></a>
## 3. Lmx in L1

The target C projection of [L2 §2](L2_spec_en.md#lmx) is a flat `Lmx` header with fields `parent`, `length`, `storage` in precisely this order, without an embedded `VoidArray`. A Structure or Array reference points to the start of the header. An ordinary Structure and `Array<@>` hold `void *` elements in `storage` and are interchangeable in common operations; a numeric `Array<T>` stores T elements directly. Typed storage and common resizing apply to all Arrays; capacity resides in the arena table. This layout is approved; migrating the current generator remains open: [implementation status](implementation-notes.en.md#l2-status), [M13](../next_core_tasks_v3.md#flat-lmx-descriptor). Graph records gain no name, model tag, or hidden execution fields. Thread's dynamic child List remains separate.

Lowering ordinary receiver [`sys\descriptor`](L2_spec_en.md#get-descriptor) returns a Structure of addresses of the three actual header fields: `Lmx **`, `size_t *`, `void **`. A dereferenced write directly addresses and changes the original field; writing a field of the returned Structure changes its pointer. There is no proxy, delayed writeback, or new opcode. Arbitrary finite pointer depth and Array rank use the common typed path; L1 retains its own “type — name” declaration order.

Lowering parent/length/sys\storage reads header fields; sys\native obtains the native descriptor from
call tables and sys\capacity reads the arena capacity table. No argument selects current data.
None of these queries builds an auxiliary descriptor. Data/code and node retain their roles.
sys\resize/sys\reserve use common variable-size Arrays. Lmx contains neither native nor capacity.

`sys\descriptor` likewise accepts an explicit S or defaults to the current data:
`sys\descriptor() = sys\descriptor(data)`. This choice also applies inside nested control bodies;
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

`LmxRange` and the arena index classify physical addresses rather than reading in-band cell tags. User models do not create one C type per Structure. Ordinary and `immutable` Structures have separate pools while retaining a compatible physical record. See [L2 §3](L2_spec_en.md#type-by-range).

<a id="pool"></a>
## 5. Pool

`LmxPool` and `LmxChunk` allocate fixed cells. Growth adds a chunk instead of moving live cells through `realloc`. Pool and range belong to the arena. See [L2 §4](L2_spec_en.md#pool).

During incremental self-build, the translator emits C99 access to a graph Array's `void *storage` through a pointer `T *` of the actual element type selected by the L2 pool type. That pool allocates and accesses cells of that very type with suitable alignment: a cast does not redefine the effective type of existing backing. Graph-reference slots retain their separate `void **` contract, not an incompatible `T **` access. Thus one common Array Structure lowers to different typed arrays without a new language object for every `T`.

<a id="method-array"></a>
## 6. Native entry and Array

Native descriptors are ordinary Structures in call tables in the Thread's arena, with signature variants, binary-module/entry names, and L1/C paths. Translation adds a missing ordinary native reference field to fn/sub/catch, not to other Structures. Arrays use the common Lmx and variable-size typed storage; separate List growth and embedded capacity are removed. See [L2](L2_spec_en.md#method-array).

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

R0 and the upper host scaffold use the common Thread mechanism. Launch data belong to the scaffold rather than hidden R0 graph fields. Shutdown cascades through the sole child List; a host watchdog enforces the whole subtree timeout. See [L2 §8.1](L2_spec_en.md#root-close).

<a id="mailbox"></a>
## 10. Mailbox

`LmxPost` holds `staged`, `outbox`, and FIFO `inbox`. An incoming slot is the pair `[target, source_arena]`; the recipient owner attaches the donor before releasing the target. The inbox ring uses a common variable-size Array with external capacity, movable storage, and a mailbox monitor. See [L2 §9](L2_spec_en.md#mailbox).

<a id="own"></a>
## 11. Local call frame

<a id="call-frame-20261115"></a>
Every call, including `call(D,C)`, creates its own namespace. For fn/sub/catch, args/data
are unified into one input data; short headers remain. An actual replaces the corresponding
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
order of a bare name. Earlier reading through a path does not suppress the RHS when its code statement is reached.

Bare x and @x refer to the frame place, independently of source-field replacement immediately at entry,
even before the first read: the selected value or computed description is retained.
The rule is the same for explicit data, lexical binding, and dynamic binding. It does not deep-copy
referenced objects. `x := 0` changes the namespace; `data\x := 0` changes the source graph.
For computed input `int: x next()`, @x obtains the value and the local cell's address.
With `@(data\field)` and source `int: field getValue()`, the addressed value is getValue()'s result;
the examined native path already has l2_tN, so &l2_tN requires no additional allocation.
A ready place is addressed directly; reading the result does not replace the source declaration.
Lifetime remains ordinary. @f() was a research example, not a separate support or prohibition task.

Copying code to equalize edit-application timing is cancelled. Native and the walker may apply an edit
at different times before endturn; namespace independence remains. Bindings use hidden arguments without
an environment copy. Graph edits neither clear native nor start checking/compilation.
Methods and ordinary Structures share compilation without data=code; different actuals yield different
C signatures, and a header without code describes a call.

Local frames are not published. Load-dirty, the shared direct-access cache, and flush() are cancelled;
explicit writes are observed through actual aliases in execution order.
[Agreed norm](LMX_semantics.en.md#call-frame-20261115),
[single M14 task](../next_core_tasks_v3.md#native-structures).

<a id="call"></a>
## 12. Calls and explicit compilation

Known native calls the known variant directly in C using the selected actual signature and necessary
hidden arguments. Arranging this call needs no graph, call-table lookup, universal actual packaging,
or trampoline. Dynamic calls select variants in call tables; their internal ABI is not mandatory
packaging for all static calls.

sys\compile(S) explicitly performs clean-graph construction/checking → L1 → C → machine compilation
and entry registration; sys\translate returns only L1 and diagnostics. Graph writes are not tracked
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

<a id="implements"></a>
## 15. implements

The `LmxImplEntry` table stores a proven address mapping between candidate fields and the receiving description for any admitted pair of Structures. Different field order cannot be reduced to identity ordinals; reading, address-taking, and explicit writes to the original graph follow that same correspondence. Call-local places are not published back into the graph. In data every declaring form is an occurrence of the name: a repeated declaration neither replaces the former one nor writes into it, and a name with two or more occurrences is addressed only with the index of an occurrence (the author's decision of 2026-11-11, [L3](LMX_semantics.en.md#fields)); “last occurrence” selection is not part of the new contract. `s\[N]field` with zero-based `N` addresses the Nth occurrence of the name -- a form of the data that declares that name -- not an Array element. The map holds no runtime names and does not itself keep the graph alive. See [L2 §14](L2_spec_en.md#implements).

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
| `@: p int` | `int *p` |
| `@@: pp char` | `char **pp` |
| `p: @x` | `p = &x` |
| `\p` | `*p` |
| `\p: value` | `(*p) = value` |
| `p\field` | `p->field` |
| `a[i]: value` | `a[i] = value` |

The table states the target unified spelling; transitional hand-written L1 may still need declaration-order migration. An addressable target needs valid C storage. `value\field` is a pointer step; by-value C aggregate access needs an explicit C form. `const: @(char p)` lowers to `const char *p` and protects the characters, not the pointer cell. This is not L3 deep immutability.

L2 indexing, including `array[-1]` and any finite adjacent-index chain, lowers to an offset calculation
without length/sign/arena checks. L3 uses its own Array-descriptor-reference type with index and one
final-element check; that reference stores no storage address. L3 primitive pointers also have a separate
type using the common typed-reference foundations.

<a id="lowlevel-array"></a>
## 20. Array and raw C arrays

Ordinary `[]:` in L1 as well as L2/L3 denotes a language Array: a graph Structure on the shared `Lmx` base with typed elements, structural `parent`, and `native`. Only the explicit `c.array:` door selects a raw contiguous C array without graph `Lmx`, arena, or hidden bounds checks. A rectangular raw array does not become an array of separately allocated rows. Automatic C-array lifetime follows C99; it is not identified with a graph Array. The former lowering of bare L1 `[]:` directly to a C array is an implementation state to remove.

<a id="lowlevel-abi"></a>
## 21. Casts and C ABI

`cast: (T) expression` emits an explicit C cast, not an L3 checked conversion. `c.name` is an explicit foreign C symbol. `foreign: Name` requires a type definition in an included C header; `external` and `prototype` describe export and declaration, while `include` and `predef` select explicit dependencies. Header source `name.h.lm1` emits `name.lm1.h` and permits declarations without executable bodies. A by-value field needs a complete C type; a pointer permits a forward declaration.

<a id="lowlevel-expression"></a>
## 22. Expressions and control

L1 lowers C arithmetic, logic, bitwise operations, `++/--`, and ordinary control flow. Source `=` in a comparison becomes `==`; `target: expression` is assignment. `switch` permits C fallthrough, unlike L3 `match`. L1 `throw/catch/finally` with a machine service payload does not define typed L2/L3 failures.

<a id="lowlevel-sync"></a>
## 23. Synchronization

L1 does not define the structural `synchronized` receiver. The kernel uses explicit machine and foreign atomic operations; `volatile` is not atomicity. The `synchronized` contract belongs to [L2](L2_spec_en.md#lowlevel-sync).
