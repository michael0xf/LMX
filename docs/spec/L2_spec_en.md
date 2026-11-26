# L2 Specification

**Current extension:** [types, universal sequences, generic patterns, and callable adapters](CORE_SEQUENCES_REGEX.en.md). The root specifications of this uploaded archive govern this edition; old contradictory spellings are superseded.

L2 defines the kernel mechanisms and machine operations. L3 semantics are in the
[LMX specification](LMX_semantics.en.md), syntax in the [grammar](LMX_grammar.en.md),
and the common implementation model in the [kernel specification](kernel-implementation.en.md).
L1 is the generated intermediate stage before C99. This standalone specification describes the
desired model for Fable acceptance; it makes no claim about an unexamined repository build.
Historical implementation receipts and derived acceptance controls are separated in the
[implementation notes](implementation-notes.en.md). Superseded lower-priority wording is corrected
from the current requirements; only an explicit conflict between current governing requirements
is referred to the author with the competing rules and a minimal differing example.

**Normative baseline, 2026-11-21, including the latest author correction.** Import, copy, and
merge always consume ordinary CODE arguments, including when written inside DATA; their common
W/E argument algorithm applies everywhere. This supersedes the earlier role-dependent source
reading. The field-stream rules control any conflicting earlier composition example. [P01](#uninit-record-control) is resolved:
`uninit:T` has a TypeRef and zero payload, graph assignment replaces fragments, and the full literal
source graph includes both all written receivers and direct primitive leaves. Replacing `uninit:T` with `{T value}` cannot preserve a preexisting T-cell address, because `uninit:T` has zero payload.

<a id="scope"></a>
## 1. Scope

Both operation forms use the same typed-record, actual-place and call
boundaries. An exact identifier is decoded only by the base name mechanism;
translation does not re-open its content as operators. VALUE/NAME/TYPE/DATA,
RAW/BODY and PLACE keep their receiving roles. Native code and the walker must
agree on the four one-PLACE update variants, including one destination
evaluation and the returned old/new typed value. See
[operation forms](OPERATION_FORMS.md) for the full lowering contract.

The target chain is L3 with L2 insertions → generated L1 → C99. L1 is an intermediate language. The interpreter executes the stored graph: L2 code with the same checks as L3 code, through the same wrappers of the low-level operations — L3 lacks only `c.*`. Native L3 code calls the wrappers; native L2 code is compiled without these checks ([semantics, §1](LMX_semantics.en.md#scope)).

The program representation is the complete LMX graph plus the binary of compiled methods.
The binary contains methods, including R0 and the interpreter implementation; it does not contain
an additional program-data repository or static C mirror of the graph. R0 is an ordinary C method
with a local pointer to its R0 graph, also when the program is interpreted. There is no working
graph, hidden execution copy, expanded callable/data graph, or materialized namespace version.
Transient frame/register values and ordinary traversal maps remain execution state and do not
form another program graph. Explicit copy/merge results are normal requested values.
[Complete graph and binary](LMX_semantics.en.md#program-representation).

<a id="lmx"></a>
## 2. The `Lmx` structure

Every initialized Array has one mandatory primary `Lmx` descriptor. Structures
and Arrays share its flat `parent/length/storage` header, without native,
capacity, rank/extents, or an embedded VoidArray. The canonical type description
contains exactly the normalized complete LEFT requirement; it does not acquire
extra axes or sizes from an initializer. Only a reserve beyond length needs a
compact capacity entry. Capacity equal to length means no secondary descriptor,
including for nD Arrays ([§6.1](#array-capacity)).
In L2 order the primary fields remain `@Lmx: parent`, `size_t: length`, `@: storage`.
These are `Lmx *`, `size_t`, and `void *`; the typed requirement is in the head,
not an initializer naming a type. A reference points to the header's start.
Immediately before it is a TypeRef: the direct address of the canonical system
Structure describing the complete type ([§3](#value-record)). This representation
applies to every type, including primitives, references and Arrays.
Structure and Array<@> store `void *` elements and are interchangeable in indexing,
named paths, admission, copying and execution. Numeric Array<T> stores T densely;
its descriptor's TypeRef supplies the actual element requirement and storage layout.

The source shape logically determines parent and length; the remaining written program material
is represented through the Lmx pointer array and the typed records it references. This is compatible
with the physical header below and does not require on-demand-only header computation.

Parent is the structural parent. Passing an existing value's reference neither changes parent nor
expands it into the tree. For a Structure `C` executed in the code role, the data role is performed by its
actual parent ([§11](#call-receivers)). An Array descriptor retains its address; length and storage use common size
management. Separate fixed-Array and specially growing List contracts are cancelled.
Native descriptors reside in the existing call tables. Compilation does not add a synthetic native
field to an executable Structure or `catch`. An explicitly written user field named `native` remains
ordinary source material and is not a header pseudo-field or the call-table entry.
A signature declared with `::` has no executable body or native entry; Structures receive no automatic
field merely by being present in DATA. [Compilation contract](LMX_semantics.en.md#explicit-compilation).

<a id="interpretable-tree"></a>
### 2.1. Interpretable tree

The source graph retains **all receivers as written**, including declarations, modifiers, operators,
`import`, `copy`, `merge`, and nested bodies. All evaluation and transformation take place in the
namespace; neither preparation nor C emission replaces a receiver with its computed result.
Terminal primitive declarations are included in this full literal source reflection in their own
`{type value}` form at the address held by the Lmx cell, with names in the ordinary name table.
An uninitialized leaf has only its TypeRef and zero value bytes. A form whose RHS still requires
evaluation retains its written form; typed-leaf representation does not authorize evaluating it away.
A primitive cell needs no extra leaf wrapper. Names reside in the common canonical
string-address table, not in Lmx. The selected Structure performs the code role, and its actual parent performs the data role ([§11](#call-receivers)).
A direct DATA pass obtains root declarations under their ordinary receiver contracts. The modifiers
`private`, `required`, `const`, `immutable`, and `independent` act in that pass, and their declared
variables count as root-level ones. Explicit import/copy/merge operations supply additional fields
through the same namespace consumer as described below; this does not make every nested receiver
or arbitrary DATA field executable ([semantics](LMX_semantics.en.md#data-root-declaration-execution)).

When `import`, `copy`, or `merge` is consumed inside DATA, it supplies its output fields to
that same namespace consumer (§13), while its own arguments retain their ordinary CODE role.
The written receiver records remain in the source graph. Reading an explicit
source path to one of those records does not itself execute it or substitute its expanded result.
Copying may construct necessary result nodes under the ordinary copying contract; this is not a
rewrite of the source receiver.

A blank physical line outside escaped lexical content closes the current syntactic block completely
to the document root, as a cutter at virtual level −1. It creates no graph field or instruction and
does not synthesize a missing paired delimiter. Mix has its own local document root; its closing
`}` is still required. The parser preserves byte coordinates and the serializer inserts blank lines
only at valid complete-block boundaries. The full rule, including comments and EOF, is in the
[grammar](LMX_grammar.en.md).

Ordinary explicit graph operations can replace any selected source fragment, including a primitive,
receiver, control body or complete executable Structure, with new graph material. The full representation
adds no permanently nonreplaceable code category or special mutation-only API. Frame assignment remains
local. Explicit qualification/protection contracts are separate from representation. Graph writes are not
tracked for native, do not check future executability, and do not start compilation automatically. The builder and explicitly invoked sys tools check
a clean graph. The walker executes admissible L3; explicit compilation updates machine execution.
`sys\toLmx(S)` saves selected S in its current form, without reconstructing earlier source.
See [semantics](LMX_semantics.en.md#source-codec).

<a id="get-descriptor"></a>
### 2.2. descriptor: value fields and system type descriptions

`sys\descriptor(S)` with an ordinary Structure/Array value returns an ordinary Structure of S's three live primary field addresses. Without an argument it
selects the current launch's data (the parent of the executed Structure), including inside nested control bodies. Code is explicit.

```text
(
    @@Lmx: parent
    @size_t: length
    @@: storage
)
```

Machine types are Lmx**, size_t*, void**. `\(d\length) := n` changes S.length;
`d\length := p` changes only the pointer in d. This is neither a copy, proxy, nor write-back.
Writing length itself allocates no storage; sys\resize performs coordinated resizing.
Native, capacity, and rank/extents are absent from the result because they are not header fields. Obtaining descriptor
does not extend S's lifetime. The first field's address may equal S, but typed dereferencing does not
classify it as another standalone Lmx. Pointer depth is arbitrary and finite.

The more specific canonical system-TYPE contract accepts a TypeRef:

```lmx
@: description sys\descriptor(sys\typeof(obj))
```

`sys\typeof(obj)` already returns the direct reference to the canonical immutable
system Structure describing the complete type. `sys\descriptor` returns that
**same Structure**, without another lookup by integer, a copy, an address tuple
for obj or a per-Array allocation. The same contract serves all primitive,
reference, Array and callable type descriptions, including dynamically resolved
requirements. It takes precedence when the argument is such a canonical TYPE
description. An ordinary user Structure with similar fields or a matching name
is not reclassified as a system type, and an arbitrary integer is not an address.
The ordinary object overload still returns the three live primary-field addresses.
The no-argument form retains its current-DATA/object contract.

The description exposes the complete normalized LEFT requirement, its storage
contract, declared rank and explicit axis constraints, derivation rules and
compatibility. It contains no initializer-specific dimensions or reserve amount.
For `[]int`, a current extent comes from the object's length. For `[][3]int`, one
missing extent can be derived from length and 3 when the quotient is integral.
For `[][]int`, two missing extents stay unknown even if row syntax was used to
initialize the value. Reading a description does not invent zeros or factors.

`sys\capacity(obj)` reports the actual instance capacity through the common
optional association or length; the type description states that common policy.
Capacity equal to length requires no second descriptor even after this query.
A saved TypeRef remains the same immutable description; reserve/resize do not
change it. Querying a pointer/place retains its ordinary argument meaning and
adds no recursive dereference. Type descriptions themselves use a finite
bootstrapped meta-description, with ordinary graph cycles where needed:
`sys\typeof(sys\typeof(obj))` does not allocate an infinite chain.
[Canonical TYPE contract](ARRAY_STORAGE.en.md#type-descriptor).
The TypeRef migration is **DOC_SPEC_ADDITION_ONLY**; production acceptance **NOT_RUN**.

<a id="header-receivers"></a>
### 2.3. Reading the header and service tables

parent(S), length(S), sys\storage(S) directly read parent, length, storage.
sys\native(S) returns the ordinary native descriptor from call tables, including signature variants,
or 0 when absent. sys\capacity(S) consults the existing optional capacity
association: it reads that entry when present and otherwise returns length.
The query allocates no descriptor or table row and does not select a new type.
These queries construct no auxiliary descriptor. Every zero-argument form selects current data;
code requires an explicit argument. R0 has no artificial DATA for these queries. Resolved system queries retain their contracts in DATA as well. A path such as `D\for` selects an actually stored field; path lookup does not execute its source or reclassify a receiver application as a declaration.
Ordinary paths S\parent, S\length, S\storage, and S\native select written fields without pseudo-fields. `S\rank` and `S\shape` likewise gain no service meaning.

The selected Structure performs CODE and its actual parent performs DATA ([§11](#call-receivers));
`node` is the reserved lexical operation and retains the context needed for that access.
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

**Physical record contract.** Every graph value record has the form
`{TypeRef value}`. TypeRef is the direct reference/address of the canonical
immutable system Structure describing its complete type. It is not an integer
counter, registry index or encoded tag. Arena intervals establish ownership;
they do not determine type. Primitive, reference, Structure, Array and callable
requirements all use this same type-description mechanism.

A payload is exactly the storage required by its described type: for example a
number, a reference or a Structure/Array's three-field Lmx. Elements and slots
remain in the separate backing named by Lmx.storage. The logical record size is
`sizeof(TypeRef) + payload_size(type)`; it is neither a largest-value reservation
nor a C union. `uninit:T` contains only its TypeRef to the absence description:
zero payload bytes and no reserved future T cell ([§3.1](#uninit-record-control)).

The terminal declaration `int: x 10` remains directly represented by the record
«TypeRef for int, value 10», with x in the ordinary address-to-name table. A path
selects `S\x`, not `S\int\x`; this is the declaration's physical encoding, not
deletion of its source ([semantics](LMX_semantics.en.md#primitive-declaration-is-the-element)).

For a genuine initialized record, p points to its first payload byte. The prefix
cell is at `byteAddress(p) - sizeof(TypeRef)`; loading that cell once yields the
address of the system type Structure. The following is explanatory C/ABI notation,
not an additional LMX type spelling:

```c
typedef const Lmx *TypeRef;
TypeRef type = *(TypeRef const *)
    ((unsigned char const *)p - sizeof(TypeRef));
```

Subtract the size of the actual stored pointer type, not a fixed four bytes.
`sizeof(size_t)` is interchangeable only where the target ABI proves equal widths.
The prefix-cell address and the descriptor address loaded from it are different.
A bare field expression is not guaranteed to be an address: `(@S\field)` explicitly
addresses a ready graph place. Computed declaration paths, reference-variable
cells and ordinary native locals keep their separate address contracts (§17).
The formula must not be applied to a native local or a dense Array<T> element:
neither has its own graph-record prefix. An uninitialized record has no p naming
a T payload; inspecting its TypeRef does not license reading nonexistent T bytes.

**Alignment.** Align the payload for both its actual type and TypeRef, so that
both the immediately preceding pointer and payload support ordinary typed aligned
accesses. Padding goes before the prefix, between records, never between TypeRef
and payload. On a target with eight-byte TypeRef, four-byte int and eight-byte
reference/double/size_t, an int record has 12 logical bytes (typically a 16-byte
step), a reference/double record has 16, and a 24-byte Lmx record has 32. An
uninit record has only eight logical bytes. Actual allocation steps obey the next
record's alignment; allocator padding is not payload or future initialized storage.

`sys\typeof`, indexing, dereference, admission, copying, merge and collection
obtain complete type and payload layout from the record's TypeRef. Dense numeric
storage remains untagged T; native locals use their call/place type contract.
The canonical description includes qualifications and uninitialized distinctions.
A named model or a similar field layout does not by itself change an object's type:
a complete TYPE requirement is normalized and interned when consumed, and a ready
value is admitted by directed `satisfies` without retagging. Ordinary/immutable
Structure requirements have distinct descriptions; an already published ordinary
Structure cannot become immutable by relabeling. There is no separate executable-fn
or sub storage category, nor an embedded VoidArray.

The normalized complete LEFT determines TypeRef. Equivalent `[][]int` and
`[](2)int` share it; `[]int` arrays of lengths 2 and 3 share it; `[2][3]int` and
`[3][2]int` do not. Names, initializer rows, actual length and reserve are not
interning parameters. Explicit `[N]int` evaluates N once and reuses the canonical
description for the resolved requirement. Type descriptions have a finite
bootstrapped meta-description; their own type references may form ordinary graph
cycles. Stable references remain valid while any live record, saved TYPE value
or native binding needs them. No bit flags or second type interner are introduced.

For every primitive T, omitted initialization retains the language place's T
requirement while the graph record refers to `uninit:T`. Absence is `nil: T`, or
`nil` where T is known; it is distinct from truthiness and input `required` selection.
The [migration guide](../TYPE_REFERENCES_CHANGE.md) identifies old int-code sources
and integration gates. Their existing receipts do not validate this new ABI;
production implementation and parser/runtime acceptance remain **NOT_RUN**.

<a id="uninit-record-control"></a>
### 3.1. P01 resolved — a TypeRef without a value

**P01 resolved.** An uninitialized record has no value payload and reserves no
T cell. The former nested outer/inner record, preallocated T storage and stable value-cell retagging
requirements are superseded. The clean graph fully and literally represents the written source,
including terminal primitives in their own `{type value}` encoding; for an uninitialized leaf that
value has size zero. All receivers, including `for`, `if`, `merge`, `copy` and `import`, remain as written.

Assignment in an execution frame changes the selected local place, including a permitted transparent
caller place. It does not modify the source graph. Explicit assignment to a graph place replaces
the graph fragment held there. For example:

| Operation or state | Graph fragment at `S\novalue` |
|---|---|
| Source declaration `int: novalue` inside S | `{TypeRef(uninit:int)}`: the type reference only, no value bytes |
| A call's local `novalue := 5` | Source stays `{TypeRef(uninit:int)}`; the frame holds the assigned value |
| Explicit graph write `S\novalue := 5` | The structural place now holds the fragment `{TypeRef(int) 5}` |

A fresh structural access after the explicit write observes the replacement. This is not an update
of a nonexistent T payload and does not promise that a previously obtained raw address follows the
replacement or remains its value address. The language requires neither in-place enlargement nor
persistent indirection to simulate it. Copying, `sys\typeof`, serialization and collection use the
record's actual type and payload size; none may read or copy imaginary T bytes from an `uninit:T` record.

The existing stability of Structure/Array descriptors and the descriptor-plus-index contract of L3
Array-element references concern those objects. They do not impose address equality between an old
zero-payload fragment and its replacement. Ordinary target lifetime and explicit graph ownership
rules remain applicable.

[The resolved P01 record](implementation-notes.en.md#uninit-layout-conflict) and
[kernel §3.2](kernel-implementation.en.md#primitive-storage) state this same author decision.
The anchor is retained for existing links; no author question remains here.

<a id="pool"></a>
## 4. Allocation of records

Every arena has one stream of records “TypeRef, value”: records are issued successively from
its chunks so a Structure's descriptor, slots, and fields can be placed together. A chunk is never
reallocated; growth adds a chunk, and issued record addresses remain stable until their ownership
is released. There are no chunks by type and no typing by address. An interval index remains only
for ownership, attachment, and collection. Earlier typed-pool transition steps are historical
implementation provenance, not an alternative layout contract.

In a graph Array, `void *storage` holds the address of the element storage. For a numeric `Array<T>` it is a dense block of T; L2 obtains a pointer to the actual element type from the TypeRef of the Array's record, not by classifying the storage address. A pre-existing block of `void *` slots cannot be read as an arbitrary `T` array merely by casting its pointer. Addressable graph-reference slots retain their own `void **` and stored-value conversion contract.

<a id="method-array"></a>
## 5. Native entry and Array

Native is an ordinary descriptor in call tables containing entry variants, signatures, binary-module/entry names, and L1/C paths. Machine addresses are bindings of the current process, not persistent addresses for another run. A language Array has the common Lmx base and variable length/capacity; typed storage may move. Strings remain exact-length char Arrays without trailing NUL; NUL belongs to the C door.

<a id="arena"></a>
## 6. Arena

Each Message owns one logical arena, which may contain multiple chunks.
Within a common canonical type context, `lmx_arena_attach` transfers donor chunks
without moving record addresses or TypeRefs. It retains the metadata ownership
needed by those references after the donor is released and transfers any optional
capacity association. There is no type registration by address ranges. A different
context or process must intern full descriptions and relocate type references as
part of restoration, not retain stale numerical addresses. One arena is not accessed
concurrently by several threads. `mark/revert` rolls back failed copy/merge
construction; simple mode retains stable addresses without GC. Independent immutable
branches follow the [ordinary ownership contract](LMX_semantics.en.md#eternal).
Type metadata must outlive every dependent record, retained token and native binding.

<a id="array-capacity"></a>
### 6.1. Array requirements and optional reserve information

Every initialized Array has one mandatory primary Lmx(parent/length/storage).
Its payload size, alignment, identity and element stride do not change for reserve
management. The TypeRef describes exactly the complete normalized requirement used
by its constructor. Neither capacity nor initializer-specific shape selects another
type. The existing primary has no new field, hidden prefix or shape pointer.

| Storage state | Capacity source | Per-Array secondary descriptor |
| --- | --- | --- |
| `capacity = length` | Current length | None, including no hidden shape entry. |
| `capacity > length` | Existing optional capacity association | Compact capacity-only entry. |

**Capacity equal to length means no secondary descriptor.** This applies to empty,
1D and nD Arrays, ordinary Structure/reference Arrays and service arrays. Capacity
below length is invalid. `sys\capacity` consults the optional association or returns
length without allocation; all Array types use this common policy. Reserve changes
neither TypeRef nor its immutable description. There is no reserve-specific type.

TYPE metadata contains declared rank and explicitly specified dimensions only.
Equal complete requirements share one description: `[][]int` equals `[](2)int`,
but `[2][3]int` differs from `[3][2]int` and `[][3]int` differs from `[][]int`.
All use one flat C backing. `[]int` gets its current extent from length; one missing
axis can be derived from length divided by a positive product of known extents
when exact. Multiple missing axes stay unknown. A full zero shape such as
`[2][0][3]int` is retained by its written TYPE; length zero cannot recreate it.
`[0][]int: []` and `[][0]int: []` are valid with incomplete shape, while
`[2][0]int: []` has fully known dimensions. No source rows or per-object shape
record fill the missing dimensions after construction.

Explicit initializer rows are checked for rectangularity, then flattened in order.
`[][]int: [1 2 3; 4 5 6]` validates two rows of three but retains TYPE `[][]int`,
with two unknown extents. `[][]int: [1 2 3 4 5 6]` is also valid flat storage.
`[][3]int: [1 2 3 4 5 6]` has different TYPE information: its missing extent is
uniquely 2. These values may contain the same ordered data without having the same
type. `[][3]int: [1 2 3 4 5]` is invalid. Contradictory explicit rows, negative or
noninteger size expressions and impossible length/products are errors. Missing
shape is an error only at an operation needing information that TYPE plus length
cannot determine; ordinary flat operations remain available.

The common parser handles every full `[sizeExpression]`; the TYPE consumer obtains
it once in lexical order. `[](N)T` repeats unspecified axes, and `@(N)T` repeats
pointer levels. A declaration without an initializer stays uninit and allocates no
Array or capacity entry. VALUE/PLACE indexing and indexed callable receiver heads
retain their roles: `Struct[2]:= [a b]` is assignment, not a declaration colon.
[Complete sized-axis and derivation contract](ARRAY_STORAGE.en.md#sized-postfix).

Compatibility is directed admission between complete descriptions, with declared
rank/size constraints and value-dependent checks where applicable. A general flat
consumer can accept compatible dimensions without erasing the actual TypeRef.
Ready-value admission does not copy or retag an Array to the receiving requirement.
Pointer equality means the same canonical type, not every permitted admission.
A proof concerning mutable length is not a permanent result of a type-pair check.

`sys\reserve` preserves length. It creates a capacity entry only when capacity
exceeds length; returning to capacity=length removes that entry. Resize respects
all fixed TYPE constraints and updates length/storage and optional reserve coherently.
A shrink keeping a larger backing has reserve; trim to length has none. These changes
never alter TypeRef solely because length, reserve or initializer knowledge changed.
A direct raw header write must preserve the same invariants. Existing effects and
resource failures do not acquire a new general rollback guarantee.

Copy preserves the normalized type, values and aliases under its usual graph rules.
Restoration interns the same complete description in its destination context and
relocates TypeRefs; numerical addresses need not match another context/process.
Reserve may be discarded without changing the normalized type. Attach within the
common context preserves addresses and transfers an existing capacity entry.
Release removes that entry before identity reuse. A cached native storage pointer
or length-dependent fact still needs a valid lifetime/proof after mutation, although
the canonical TypeRef itself is unchanged. No global invalidation is introduced.

`sys\descriptor(TypeRef)` returns the same canonical description;
`sys\descriptor(ordinary Array/Structure)` returns three primary field addresses
([§2.2](#get-descriptor)). Neither exposes or creates an instance capacity record.
One `arr[k]` is flat access. Complete `arr[i][j][k]` coordinates require enough
TYPE/length information to obtain the offset in that same block. Ordinary paths
`struct\struct2\field` and `struct[i]\[j]`, or `struct\struct2\field[k]` and
`struct[i]\[j]\[k]`, select the same fields when the indices match. They introduce
no array-of-arrays kind. [Operation depth](OPERATOR_DEPTH.en.md#evaluation) consumes
the dimensions actually determined by TYPE and length.

This representation and the TypeRef migration are **DOC_SPEC_ADDITION_ONLY**;
production P0/translator/runtime acceptance is **NOT_RUN**. Historical code and
host-model receipts are not evidence for the new pointer-width prefix.
[Migration and remaining source work](../TYPE_REFERENCES_CHANGE.md).

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

Direct children live in the sole child collection held by `Thread.children`, using the common
variable-sized Array storage mechanism. This is Thread state, not a `message.graph` field. `Thread.parent` belongs to the Message hierarchy and does not modify `Lmx.parent`. Competing workers may not execute one Thread identity.

<a id="root-close"></a>
### 8.1. R0 and shutdown

Program startup always starts R0 as an ordinary child L3 Thread of the top stub
parent and executes its CODE from the beginning. Its executable entry is an
ordinary C method with a local pointer to the R0 graph, including for interpreter
execution. This creates no persistent global root pointer or hidden graph-data
repository. R0 has no DATA and no user actuals: no artificial `data = code`, empty
service DATA Structure, or field `data` is supplied. The stub Thread parent is not a source-graph DATA parent, and no Thread has another Thread as a lexical C parent: Threads are independent in the lexical C sense and in memory even when assembled together ([Thread independence](LMX_semantics.en.md#thread-independence)). Internal Thread launch parameters and settings
belong to runtime preparation; they are neither source fields nor user formals.

The common activation mechanism accepts the selected CODE's optional actual DATA
parent and skips only the input pass when that DATA is absent. R0 retains
ordinary CODE namespace preparation, local declarations, arbitrary calls,
dispatch, cleanup, and exits. Reached forms follow their ordinary contracts,
including DATA-consuming arguments of ordinary calls ([norm](LMX_semantics.en.md#root-entry)).
No root-specific parser, registry, synthetic DATA, `Main` discovery, or selected
service function replaces root startup. A named test invocation is an ordinary
call after startup. If the stub parent has arguments to deliver, it sends an
ordinary message to the running root; it does not invoke R0 with user actuals.
See the [common activation sketch](kernel-implementation.en.md#root-activation).

The top scaffold has no parent but gains no special API. Shutdown cascades
through each Thread's sole direct-child List. A host watchdog controls the whole
subtree's timeout; expiry terminates the process rather than declaring partial
shutdown successful.

<a id="mailbox"></a>
## 9. Mailbox

Each Thread owns an `LmxPost`. `staged` prepares the current turn's messages, a successful boundary publishes them to `outbox`, and `inbox` holds admitted but untaken messages. An `inbox` element is the inseparable pair `[target, source_arena]`: the producer does not mutate the recipient arena; its owner attaches the donor before releasing the target. Failure retains the pair. Admission order is FIFO.

`inbox` is a ring over a common variable-size Array with the ordinary compact/reserved capacity contract; no auxiliary exists when capacity equals length. One reentrant LmxPost monitor covers admission, take, and count; outbox/staged remain owner-local. Post uses the same mailbox; see the [language API](LMX_semantics.en.md#thread-message-api).

<a id="own"></a>
## 10. Structure execution

Execution uses the selected source Structure `C` in the code role (its data is `parent(C)`; R0 has no data) and a local namespace under the [norm](LMX_semantics.en.md#call-frame-20261115). Locals are not published and element assignment does not change length. Explicit common operations change size. Edit-application timing for executable code follows the [endturn boundary](LMX_semantics.en.md#explicit-compilation).

<a id="call"></a>
## 11. Call

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
does not suit the two-argument form: this is the ordinary distinction between declarations ([declaration selection](#declaration-selection)),
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

`node` remains the reserved lexical operation for the selected source occurrence. Its lexical
source and necessary native context follow the preserved binding rules. It is not a synonym for
`parent(C)`, the current DATA consumer, or the receiver of a field stream. An explicit path `D\x`
uses the named Structure D; `node\x` is appropriate only when the lexical `node` rules actually
select that source. Moving an existing reference or importing a method does not reparent it.

A structural form and ordinary Structure calls share one interpreter path: resolve the callee name
and visible declarations → select by explicit material → prepare the selected namespace's necessary
receiving places → evaluate and receive actuals once in written order through common admission →
apply permitted implicit binding → execute and transfer the result. Necessary receiving places exist
before an actual expression writes them. Namespace preparation and actual reception neither change
source data nor run an entry-wide initializer pass; an explicit stream source call runs only when
the receiver's ordinary contract demands it.
Calls from test and converters use the same mechanism. Known native-to-native calls
may still go directly through C without graph packaging.
[Full contract and named arguments](LMX_semantics.en.md#call-receivers).

<a id="return-in-data"></a>
### Result: `return` in data

A result is described by the field `return` in the data: `return: int` or a nested block. Such a declaration assigns nothing
and is not a shared mutable cell of recursive activations. In code, `return` is the return receiver:
a bare `return` is kept, `return: value` passes a permitted result to where it is described,
and reaching the end of the code does not create a `return`. The rules of a structural result, of the receiving places and of cleanup
are kept. Both `call` and an ordinary call of a Structure may return a value under this contract; the former
unconditional ban “a launch of a Structure has no result” is removed together with `fncall`.
[Norm](LMX_semantics.en.md#return-in-data).

<a id="fn-signature"></a>
### The named signature

A receiving declaration-list contract uses the [common immediate-field mechanism](LMX_semantics.en.md#receiver-structure-sequences); this internal DATA opening does not change outer actuals or ordinary CODE W/E.

In its DATA-template form, `name :: data` supplies a declaration identifier
on the left and an ordinary DATA Structure on the right. The identifier is declared, not read from an
existing variable. The Structure describes the explicit input places
in declaration order and the optional result field `return`. The declared name is constant and can
be imported under the ordinary root-constant rule. The declaration creates a signature description, neither an
executable body nor a native entry. Without `return` the signature is procedural. A structural
result is a nested description inside `return`; `return` is not an input position. The common
parser is used; this template remains a DATA description without CODE W/E. The former named-declaration receiver is removed, while the named signature/call relationship is unchanged.

All `::` arguments, including its declaration identifier, are DATA.
A ready signature is an ordinary Structure consumed by its existing positional
profile, not by reinterpreting service fields. Common Expression preparation
and priorities account for `f :: (int -> int int)` and `f :: int -> int int`
yielding the same description: `::` at `sys\priority(":=")` binds more weakly
than `->` at `sys\priority("+")`. The receiver itself has no DATA/value selector
or RHS evaluator. Modifiers always consume DATA, while each receiver retains
its own semantics ([context rule](LMX_semantics.en.md#receiver-context-invariance)).
Anonymous Structures execute in place in CODE/Expression and are never called
as callables. Source inspection does not eagerly execute initializers or bodies.
These are normative targets; parser/translator/runtime execution is **NOT_RUN**.

```lmx
SumSignature :: (int: a; int: b; return: int)

SumContext:
    int: first
    int: second
    return: int
    sum:
        return: first + second

@SumSignature: sumPtr SumContext\sum
```

The head `@SumSignature` supplies the named requirement; its two arguments are the
reference name and the candidate.
`@: p Model` retains its ordinary two-argument meaning: it initially refers to Model itself; it
does not choose a separate implementation. `sumPtr(a := 2; b := 3)` supplies 2 and 3 to the first
and second input positions of `SumContext\sum`. A direct call uses the candidate's own names,
`SumContext\sum(first := 2; second := 3)`. Both produce 5; `SumContext()` executes the different
Structure SumContext and does not search automatically for `sum`.

The common `satisfies` has a distinct rule for a resolved signature requirement: compare the number
and ordered LMX types of explicit inputs, and the presence and type of the result, against the
candidate's contract derived from its actual `parent(C)`. Parameter names, default values, and the
body tree are not comparison keys. Optional inputs still occupy positions; hidden native parameters,
code locals, and dynamically bound external names do not add explicit positions. Equal C sizes or
raw reference tags are not a substitute for LMX type compatibility.

A call through a signature-constrained reference matches explicit names against the public names of the
signature, then sends each actual to the candidate input of that same index. Candidate names are
not fallback aliases, and matching names never reorder the candidate's signature types. Actual
expressions still execute once in written order. Defaults, requiredness, `throws`, and hidden
binding belong to the actual candidate, using its real names; the signature does not overlay its
values or rules on the candidate's parent. A positive signature match does not make every future
omission admissible. The separate signature rule is part of the common `satisfies`, not a second
parser or admission engine.

An ordinary Structure supplied as a structural model retains a different meaning: all of its
explicitly specified tree is required, including any written method subtree. Extra fields in the
candidate are allowed by the ordinary model rules. Merely containing `return` or being named
“Signature” does not turn a Structure into a signature requirement.
[Norm](LMX_semantics.en.md#fn-signature).

<a id="declaration-selection"></a>
### Declaration selection

First, the callee name and the set of its visible declarations are resolved by the ordinary rules; then a declaration
is selected only by the explicitly supplied material; then the selected variant is executed and implicit
binding is applied. The unit of selection is a candidate (a visible declaration, a reading of the explicit actuals, a map
actual → formal). There are two readings and they are equal: reading W (as written) and reading E (the single
Structure expanded) -- when exactly one actual is supplied, it is a Structure or a reference to one, and it is not
given by an assignment to a formal; its immediate fields form the sequence of actuals,
the expansion is single and one level deep, and the graph does not change; `f(arg := S)` creates no reading E. There is no preference for
the whole Structure, for arity or for the first declaration found, and E is not tried only after W fails. No
candidates is a refusal; exactly one is executed without re-expansion; more than one is an
ambiguity error. Candidate matching does not speculatively execute assignments, defaults, converters, or `test`
for each alternative. An already computed structural actual is reused for W and E; it is not
computed again for another reading. Available shape and destination checks precede actual effects.
Implicit binding -- autofill, the caller's place, the former binding -- takes no part in selection: it
creates no candidate, does not rescue a rejected one and does not restart selection. This replaces the rule of 2026-11-18
“expansion is an attempt to find other signatures; a one-argument signature expands nothing”.
[Declaration selection](LMX_semantics.en.md#declaration-selection),
[the table of mandatory examples](LMX_semantics.en.md#selection-examples).

<a id="binding-places"></a>
### Binding: own place and caller's place

The result of name resolution determines the source and the logical place. **Own place:** an explicit actual,
autofill or the former binding puts a value or a description into the place of the current activation.
**Caller's place:** the name denotes an already existing local variable of the caller, without an intermediate
working copy. In both cases the variable `x` remains in the language an ordinary variable of its type `T`: a native
`T*` is an implementation detail ([§11, executors](#binding-executors)); it does not make `x` a pointer and does not require
writing `\x` instead of `x`. Ordinary `x`, `x := value`, expressions with `x` and `@x` act on the selected logical
place. For a used external name without an own active declaration: if the really visible lexical
source is `private`, the lexical link applies; otherwise the transparent caller place; otherwise the former
binding. The former binding (fallback) is kept together with `node` and its context of lexical
and dynamic lookup and ranks below the two new paths (decisions [R01 and R08](LMX_semantics.en.md#binding-decisions)).

<a id="binding-autofill"></a>
**An own declared place and autofill.** A value reaches the own place in this order:
an explicit actual (determined by the fact of supply, not by the value: `0` is not an omission; the absence of an argument
and an explicit `nil` differ; `private` does not cancel an explicit pass) → the own ready value or the description of
the initializer (a ready value is not automatically replaced by a same-named local; a computed initializer
is not considered absent merely because it has not run yet) → **autofill**, that is, the value of the
same-named local place of the caller (an own cell, not an alias: with `x = 5` in the caller
and a write `x := 9` in the callee, the caller keeps 5; forbidden when the receiving place is `private` or the selected
automatic source is `private`) → the ordinary uninitialized `uninit:T`, without an implicit `0`, and the existing
`required` checks. Autofill takes no part in declaration selection ([selection](#declaration-selection)).
Keeping the former binding at the lowest priority does not extend it to omitted formal inputs.

<a id="binding-caller-place"></a>
**The transparent caller place.** A used external name without an own active declaration: if the really
visible lexical source is `private`, there is no dynamic substitution and the lexical link applies; otherwise a
suitable accessible local place of the caller becomes transparent. A read gives its value,
a permitted write `x := v` changes it, and `@x` addresses the caller's real place. The write is immediate, without a copy
“on exit”; taking the address is not a write and does not extend lifetime. If the caller's place was `uninit:T`,
the write changes its initialization state too, observable through the ordinary `nil` and `required` checks. For a
reference variable the ordinary type remains its reference type: reassigning a reference needs the address of its cell,
not only a pointer to the shared object, but this transport level is not added to the language type. Write restrictions
(`const`, `immutable`, types) act under the contract of the real target.

<a id="binding-fallback"></a>
**The former binding (fallback).** It keeps its former semantics of an own value or description
in the frame (variant A): the callee has its own working copy, a bare assignment changes it and not the source
place; for a reference value the reference is copied, not the object, and operations through it follow the ordinary rules.
The copy never becomes an alias of the source. Two substitutions are forbidden: the transparent caller place may not be
replaced by a temporary copy with copy-out on exit, and the fallback copy may not be replaced by the address of the source under the pretext of
optimization; the number read may coincide, but the place of writing would differ. A selected binding is held within its ordinary
scope: a new read does not choose another source because values around have changed. The start of a nested declaration is
a separate shadowing event, not a new attempt to find the source of the former binding.

<a id="binding-chain"></a>
**The chain A → B → C.** If A has `x`, B does not use `x` itself and C does, reachability is kept:
B need not introduce an explicit argument, a dummy local or a transitive list of its descendants' needs,
and there is no static transitive accumulation of hidden requirements. If the former binding applied, C gets
an own value, not an alias. If B has its own copy of `x`, the place `B.x` passed to C changes `B.x` but not the
original `A.x`; if B has a transparent link to `A.x`, passing the place `B.x` keeps the address `A.x`. The origin of a
copy cannot be “unwound” back into the original alias.

<a id="private-binding"></a>
### Receiver private: two-way `private`

`private:` marks a specific declaration and the corresponding place and excludes them from all implicit
dynamic binding in both directions. (Source) A `private` place of the caller is not implicitly offered --
neither as a value nor as a place. (Receiver) A really visible `private` declaration in the callee's lexical context
is not overridden by a value or a place from the dynamic context. The rule applies to autofill,
the transparent caller place and the dynamic part of the former binding, alike for every form of `call`,
`C(args)`, ordinary calls, the interpreter and native execution. Therefore, before an external dynamic binding is accepted,
it is determined which lexical declaration is really visible and whether it is protected by `private`; checking
the source alone is not enough. `private` is a filter of a specific place, not a name barrier and not access protection:
a `private` source is skipped and the permitted lookup goes on, and a `private x` of an ancestor does not close a new
inner unmarked `x`. Not forbidden: explicit passing (including one's own `private` value),
explicitly filling a receiving `private` place with an actual, nested lexical visibility, explicit
paths and `node`, and shadowing an outer `private` by a new inner declaration. `private` does not replace
write restrictions (`const`, `immutable`). An explicitly passed value does not carry the `private` history to its copies;
the graph record `S\private\field` is not flattened into `S\field`. Use the common binder without a separate registry
or checks on direct reads. The walker reads the original `private` receiver in the clean graph;
the compiler emits the appropriate binding/hidden-argument logic from that same source. A second
graph of private marks or access flags in the binary is forbidden, including one presented as a
prepared runtime representation. [Full contract](LMX_semantics.en.md#private-binding).

<a id="call-frame-20261115"></a>
### Call frame

Each independent call has its own namespace. The inputs are described by the data of the selected
Structure (`parent(C)`); `args` in `call` contains the explicit supplied material. Preparation
collects the relevant roots without executing initializers, visiting unreachable branches, or
writing bindings into source data. An explicit value replaces its default source in the namespace,
so that default does not execute. Ready terminal declarations use their stored values; a computed
initializer remains a description until its contract requires it. Reading an own computed input
obtains its value through the common mechanism. Explicit source-graph paths remain different:
`D\field` reads the written record and does not execute its RHS. Given `@: fptr getFuncPtr()`,
consuming the local `fptr` obtains that initializer's reference; `fptr("hello world")` then invokes
the resulting callable, without treating a bare reference as an implicit call.

<a id="declaration-arguments"></a>
### Declaration receivers supplied as arguments

A place-declaration receiver supplied in a CODE argument context is read as DATA. The received
material is its written declaration as an ordinary Structure, not a call executed during passing
or the result of evaluating its initializer. This distinction follows the resolved head's declaring
contract, not a list of names or a second parser.

| Supplied form | Destination and retained material |
|---|---|
| No outer named assignment | Supply the declaration Structure at the current positional input under ordinary admission, regardless of its internal name. |
| An outer `name := declaration` names the actual | The outer assignment chooses the receiving formal; supply the declaration Structure under that formal's ordinary admission and retain its own internal name. |

No receiving input is selected by looking up the declaration's internal name, including when it
coincides with an input name. Native lowering and interpreter reception have no found-name/absent-name
branch for that name. An explicit outer label naming the formal at its current position keeps the
positional counter active. Naming another position disables it, after which every later actual
must be named. Only that outer label uses a signature interface's public-name-to-position map;
the declaration's internal name is neither rewritten nor used as an actual label. The ordinary
W/E algorithm is unchanged; this rule adds no unwrapping or initializer execution.

For example, with receiving inputs `iteration` and `body`,
`iterate(int: item numbers\next(); (item *= 2))` supplies the declaration to `iteration` and the
body Structure to `body`. If the receiving data instead has an input named `b`,
that coincidence does not select it. For example, with reference inputs `a`, then `b`,
`g(int: b producer(); ())` supplies the declaration to `a` and the empty Structure to `b`.
`g(b := int: a producer())` explicitly supplies the declaration to `b`, retaining its internal
name `a`. Neither transfer runs `next()` or `producer()`.

Executing the accepted declaration form extends the root namespace of the receiving execution.
The first reached execution establishes its typed place; later executions update that same place
under ordinary same-level redeclaration rules and reevaluate the RHS. The binding holding the
accepted form is not replaced by the value it produced. In the iteration example, `body()` reads
and writes the established `item` directly; entering the body or reading `item` does not call
`numbers\next()` again. The body retains its physical parent in the original argument Structure,
not the library method's parent. The namespace relationship neither reparents the supplied forms
nor copies their fields into the source code. Truly nested scopes keep ordinary shadowing, and a
new independent receiving call has its own context. There is no frame publication, copy-out, or
implicit lifetime extension.

The associated body's other source-context places remain live. In an accumulating `demo`,
`total += item` writes the existing `demo` place `total` and reads the receiving execution's
established `item`. This uses the existing associated-body context, not a fresh fallback copy
of total or a new closure representation.

Ordinary `Producer()` or `Producer: argument` remains a CODE call when Producer is not a
place-declaration receiver. Receiving an ordinary reference to a Structure does not publish all
its fields into the root namespace. These restrictions preserve ordinary independent call frames
while supporting the accepted declaration/body relationship.

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
The common algorithm settles the inline control case: a new nested `int: x` without RHS/default
shadows outer `x = 5`, and this activation's immediate caller has no x. The inner place has no actual
or initializer; an inline scope creates no new caller, so the enclosing local is not an autofill
source. It remains `uninit:int`, and a reached `required: x` refuses; the outer place remains 5.
An explicit inner initializer 9 instead satisfies the check without changing the outer place.
This derives from the rules of [autofill](LMX_semantics.en.md#binding-autofill) and [declaration levels](LMX_semantics.en.md#shadowing-levels), introduces no universal outer-local copying or
eager initializer pass, and makes no claim of an executed test. See the
[control example](LMX_semantics.en.md#inline-declaration-control).

Bare x and @x refer to the selected place. The own place of the frame does not depend on source-field replacement immediately
at entry, even before the first read: the selected value or computed description is retained; the rule is the same
for explicit data, lexical binding, and the former dynamic binding, and it does not deep-copy
referenced objects. The transparent caller place is the caller's place itself ([§11](#binding-caller-place)).
`x := 0` changes the selected place: the own place of the frame writes neither to the graph nor to the caller, the transparent caller
place writes to it at once; `D\x := 0` changes the source graph of the data.
For computed input `int: x next()`, @x obtains the value and the local cell's address.
With `(@D\field)` and source `int: field getValue()`, the record of the declaration is addressed, not
getValue()'s result: an explicit path executes nothing (the author's decision of 2026-11-17; the former rule is withdrawn).
A ready place is addressed directly.
Lifetime remains ordinary. @f() was a research example, not a separate support or prohibition task.

A mandatory executable-code snapshot at entry is cancelled. Edit-application timing before endturn
is unspecified. Selected values/descriptions of own places remain independent of source data;
bindings use hidden arguments ([§11](#binding-executors)) and the environment is not copied. Methods and ordinary Structures
share compilation without data=code: the data of the selected occurrence is its `parent`; different actuals
and different modes of hidden inputs yield different C signatures.
Graph writes do not clear native: updates require explicit compilation.

Local frames are not published. Load-dirty, the shared direct-access cache, and flush() are cancelled;
explicit writes are observed through actual aliases in execution order.
[Agreed norm](LMX_semantics.en.md#call-frame-20261115).

<a id="binding-executors"></a>
### Native code, the walker and the bridge

A direct native-to-native call is kept wherever the selected implementation, types and binding are known.
Autofill is lowered as a parameter of the same `T` as an explicit actual; the transparent caller place,
as a hidden address of the caller's cell; the former binding (fallback) gives an own place.
A common C body may be shared between modes through adapters, and an adapter must preserve the owner of the record
and the behaviour of `@`. With identical explicit actuals the mode of a particular hidden input may differ
because of the caller's context and `private`: an existing native entry must match the real contract
or receive a correct description of the place. One code may have several actual signatures, including a single
explicit contract with different place modes (own copy, caller's place). The adapter uses the existing ABI and place descriptors to preserve that distinction; no new user
pointer types are introduced. Service C functions, the bridge and the `call` dispatcher do not replace the caller's context with their own
service locals: the language's sources are determined by the program location of the call.

An ordinary native local has no arena header `[type][value]` ([§3](#value-record)): its type cannot be read
from a TypeRef prefix before its address. The type, the access mode, the initialization state and the applicable restrictions of the place follow
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

<a id="catch-common-model"></a>
### `catch` in the common model

`catch` is brought to the common model of data and call while keeping the semantics of the handler. The payload is the explicitly
supplied values, accepted under the common rules; the handler's other permitted dependencies follow binding
and `private`; the inputs are described by the data, taking into account the actual `parent` link of the handler code with its data.
Kept: the choice of the handler by the name of the failure and the scope, non-execution of its body on the initial direct pass,
the distinction between nested and neighbouring scopes, no two competing same-named `catch` at one level,
continuation after the handler, a repeated call, `throws` and cleanup. `catch` does not disappear together with `sub`
and does not become an ordinary function; its dependence on the cancelled executable `fn`/`sub`, on `fncall`
and on a separate substitution of data is removed. [Norm](LMX_semantics.en.md#catch-common-model).

<a id="native-structures"></a>
<a id="direct-access-cache"></a>
<a id="explicit-compilation"></a>
### 11.1. Explicit compilation and direct native calls

`sys\compile(S)` includes clean-graph construction/checking (from sources only when they are given; an already built runtime or clean graph is used as it is), L1/C generation, the required build tests, which run in interpretation mode on the graph being accepted, and only after they pass machine compilation and registration of resulting variants in call tables. Construction/checking executes no program, initializer or test; the separate test phase interprets the graph being accepted and executes only the checks reached through ordinary build/receiver contracts; the candidate and helper calls of a check follow ordinary dispatch inside that interpreted run, which is not a bypass of the interpreted mode. Compilation does not launch S's application entry. The build chain reuses working builder code; at run time the translation and machine compilation are planned to be done by the separate SLJIT module ([runtime backend](kernel-implementation.en.md#runtime-backend)). sys\translate returns L1 and errors, not LMX or installed native. Failed compilation, including a failed test, installs no new entry and does not undo the effects of the code already executed; no candidate copy, snapshot or rollback of the graph is made, and a test copies explicitly when it needs isolation ([acceptance boundary](kernel-implementation.en.md#acceptance-boundary)).

Known native code calls the known variant directly in C with actual and hidden arguments.
That call needs no graph packaging, call-table lookup, or universal trampoline.
Dynamic selection uses call tables. One code may have multiple actual signatures,
including those caused by different modes of hidden inputs ([executors](#binding-executors)).
Explicit paths, `node` and the necessary passing of their references remain.

Graph edits are not tracked for native. Remove automatic clearing, dependency scans, reverse
invalidation tables and maintenance, transfers, and generation. Do not replace them with dirty,
versions, per-endturn hashing, or a universal journal. Ordinary memory mechanisms remain only
for their actual purposes. Without explicit compilation machine code need not refresh.

For a direct A→B link, compiling only B does not rewrite old A. Updating that chain requires explicit
compilation of a common unit containing the needed callers and targets. This is builder work, not a check at every call. Code that the planned SLJIT module produces at run time follows the same rule: it is published only by explicit compilation and endturn, without automatic tracking of callers and without reverse tables. Ready binaries of the corresponding ABI can bind to a restored clean
graph without retranslating it. ToLmx saves the selected Structure; for an L3 Thread this includes
all tables of its arena, including call/native. The arena owns them, not R0's fields
(R0 has no data and no artificial fields, [§8.1](#root-close)); external tables are not automatically attached to arbitrary S.

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
[Norm](LMX_semantics.en.md#endturn-receiver), source (repository provenance: `../LMX_blog/2026-11-15-explicit-compilation.md`).

<a id="child"></a>
## 12. Child reservation

A child is built in its own arena. It is absent from `Thread.children` until successful publication; publication at turn end adds its physical reference to that List without changing the source graph. Failure cancels the reservation but does not roll back arbitrary prior graph writes.

Adoption checks whether owners of `independent: immutable` branches used by the child remain on its new Message-ancestor chain. Failure leaves membership and `Thread.parent` unchanged. `adopt: msg newParent` performs adoption; `independent: msg newParent` separately prepares this particular adoption by copying only obstructing branches into `msg`'s arena, without changing the parent. These operate on the Message hierarchy, not `Lmx.parent`.

<a id="copy-merge"></a>
## 13. Import, copy, merge, and namespace field streams

These receivers process their explicit sources and pass resulting fields to the ordinary namespace
consumer. The receiving Structure is never an implicit source or model. Their written records and
groups stay in the source graph.

| Receiver | Argument role in every placement | Admitted sources | Output |
|---|---|---|---|
| `import` | Ordinary CODE arguments | One or more | Eligible root constant declarations, by reference |
| `copy` | Ordinary CODE arguments | Exactly one | Fields of the copied source |
| `merge` | Ordinary CODE arguments | Two or more | Fields composed from its sources |

All three use the same ordinary argument algorithm of the translator/executor wherever they
occur, including inside an enclosing DATA Structure. Sources are obtained in written order,
once each. A bare Structure name/reference and an anonymous Structure supplied as a value are not
themselves calls. An anonymous container can nevertheless contain calls and initializers; its
contents follow their ordinary contracts. Grouping neither quotes all content nor requires eager
execution of every initializer. An explicit source call such as `Producer()` is a call when the
receiver is consumed, including in
`Struct: merge(A Producer())` or an import written inside DATA. This is semantic namespace
consumption, not execution by P0 or substitution of a computed result into the source graph.
The ordinary declaration-argument rule still preserves a place-declaration form as DATA material
when that is the resolved head's contract. General source admission, including interchangeability
of Structure and reference Array where applicable, is retained. Error diagnostics identify the
receiving contract even when a low-level copying helper is shared.

`import` selects only declarations treated as root declarations by the source's ordinary DATA
rules and constant under those rules. All user Structure declarations are constant without an
explicit `const`; a root constant signature name created by `name :: signature` is eligible too. The declaration
operator is not itself imported. Ordinary mutable variables are excluded, and nested fields are
not separately raised to the root. Modifier records do not impose an extra immediate-physical-
parent test. Imported declarations retain identity, contents, and original parent links. Name
collisions use ordinary redeclaration rules, not merge overlay or a last-source-wins policy.

A standalone import supplies the current namespace. A nested `f(import(A B))` supplies f's
argument consumer only, with no additional hidden import into the caller. Copy and merge use
the same ordinary stream-consumption boundary but do not inherit import's constant filter.

`Struct: merge(A B)` and its vertical spelling declare Struct by the outer ordinary DATA form;
merge supplies only the composition of A and B. Several operations in one DATA Structure remain
independent and are consumed in written order:

```lmx
Struct:
    merge(A B)
    merge(C D)
    copy(E)
```

Each merge uses its first admitted source as its own model. Later compatible matching fields
replace the corresponding model-slot values; new fields append in source order. These overlay
rules apply only inside that operation. The receiving Struct's prior fields are not model slots;
collisions between a written field and a stream, or between independent streams, follow ordinary
DATA repeated-occurrence rules. The operations do not share an implicit combined copy map.

The result is a field stream, not an automatically wrapped outer Structure. An explicitly written
group collects it into one Structure under the common grouping rules:

| Intended consumption | Form |
|---|---|
| Supply copied fields to a call | `f(copy(A))` |
| Supply merged fields to a call | `f(merge(A B))` |
| Construct one structural actual | `f((copy(A)))` or `f((merge(A B)))` |
| Force that whole Structure into a named formal without E | `f(arg0 := (copy(A)))` |
| Assign one copied/merged Structure to an existing reference variable | `p := (copy(A))` or `p := (merge(A B))` |
| Return one copied Structure | `return: (copy(A))` |
| Declare a reference to one composition | `@: result (merge(A B))` |

The formal name `arg0` must really exist. Grouping preserves one written Structure but does not
itself disable W/E at the surrounding CODE receiver. An ungrouped RHS `p := copy(A)` remains a
stream and is judged by the ordinary assignment consumer; it is neither implicitly a container
nor categorically a syntax error. `copy(Empty)` produces zero fields; `(copy(Empty))` produces one
empty Structure. An empty source differs from a missing source.

In every placement, arity is checked after ordinary CODE W/E selection. A single written `merge(S)` can admit two
or more sources through E; it must not be rejected by P0 solely for its written count. If only one
source is admitted, merge refuses and the operation needed is copy. W and E remain equal,
including for import; multiple applicable readings are an ambiguity. Hidden binding cannot
supply an absent source. Output field count does not change input arity, and selected fields are
not expanded a second time.

Graph copying keeps one source-to-copy address map per copy or merge operation. It preserves
shared targets and cycles, rewrites ordinary references and parent links through the same map,
and copies required lexical ancestor chains under the established graph-copying contract.
The exceptions for reusable native implementation references and qualified
`independent: immutable` branches remain. The written group collecting a stream does not make a
second independent copy or restore links into a mutable source graph. It is a distinct container;
its cells are distinct from the copied lexical owner's cells. Explicit replacement targets the selected structural place,
so a write intended for a copied method's state follows its actual DATA/lexical-owner links. Names and physical type
records follow the ordinary copy rules. Copying preserves permitted native links without
compiling or registering a new implementation. Arena ownership and lifetime must remain valid;
retaining addresses into an arena that can be released is not a valid partial copy.

Import performs no graph copy: it retains the original eligible declarations and their original
owners. Copy and merge perform deep graph copying and redirect relationships to corresponding
copied owners through their common map. Explicit grouping in either case introduces its own
receiving slots; those slots refer to the emitted original or copied material without becoming
the owner's slots. Distinct outer slots can still refer to one shared nested Structure, so paths
through them may reach that nested Structure's same cell. The lexical operator `node` is never redirected to the
namespace receiving a stream; copied and imported methods retain their correct lexical and
DATA/parent relationships. Serialization preserves the written receiver, not an implicit
expanded replacement. [Composition contract](LMX_semantics.en.md#composition).

For [group positional assignment](LMX_semantics.en.md#group-assign), `(a b) .: copy(Pair)` and `(a b) .: (copy(Pair))` consume the same two emitted fields when the source and targets satisfy the contract. The collector is optional for this sequence consumer. The grouper preserves current-level items; application adaptation packages the left PLACE sequence as one actual. Three sibling RHS groups remain three Structure values, not a recursively flattened stream. Obtain and retain all RHS values and check their count before the first target write; RHS names do not reorder targets and previous RHS effects are not rolled back. A function-returned Structure reaches the method as one Array value; the `.:` consumer reads its immediate elements when it is the sole RHS Array. Ordinary assignment validates the shape and all target admissions before storing. Scalar `ptr := (copy(Pair))` still receives one collected Structure.

<a id="satisfies"></a>
## 14. satisfies

An established correspondence maps required model fields to the candidate's actual physical fields,
including differing field order. It belongs to the reception or traversal that obtained it and is
retained for those reads, address-taking operations and explicit graph writes. The next traversal
builds its information from the graph. The arena has no persistent map store and no separate map
for `call` or DATA; call-local places are not published. The map does not copy the candidate or
waive another Consumer's checks.

Admission follows the same stages as [L3 §7](LMX_semantics.en.md#admission):

- Clean-graph construction checks statically known interfaces without executing candidate bodies,
  computed initializers or `test`.
- Prepared native calls add no automatic runtime `satisfies`. An explicitly written `satisfies`
  remains an ordinary reached operation.
- The interpreter uses the standard `satisfies` automatically at reached calls. It neither runs
  a second validator nor pre-walks unused branches. Dynamic reception uses this same admission
  contract rather than a permanent certificate for all future calls.
- After clean-graph construction and L1/C generation, required build tests run in interpretation mode on the graph being accepted through ordinary build/receiver contracts, before machine compilation. Required runtime tests run at their reached admission sites. Test, candidate and helper calls made inside that interpreted run follow ordinary dispatch; it is not a bypass of the interpreted mode. Merely storing a `test` form
  in nested DATA does not execute it or add a discovery pass.

Interface selection does not run defaults, converters or tests speculatively for every W/E or
callable alternative. Receiving a selected actual still applies the required conversion at actual
consumption: `u16(256)` into `u8` can fail its range check. A primitive write does not acquire an
extra automatic `satisfies` call or rerun all user tests merely because it changes a value.

DATA declarations with the same name retain separate occurrences. `s\field` selects a sole
occurrence; `s\[N]field` selects its zero-based Nth occurrence. This is not Array indexing and does
not overlay the former declaration. Physical `S[n] := p` remains the ordinary `void*` slot write;
it inherits no requirement from the displaced content. Later structural reception uses the
current graph and its ordinary contract. These rules do not maintain per-write native freshness
or a second graph.

An ordinary explicitly supplied structural model requires its entire described tree, including any
method subtree; the candidate may have additional fields. A resolved signature requirement selects the
separate positional-signature rule inside this same `satisfies`: ordered input count/types and
result presence/type, with the candidate contract obtained from its actual parent. It does not
compare parameter names, defaults, or the body tree. The public-name-to-position mapping used by
calls through a signature-constrained reference is retained without reordering actual effects. This is one admission
engine with two requirement rules; existing boundaries between interface checks, conversion,
`test`, and prepared native execution remain ([the named signature](#fn-signature)).

<a id="gc"></a>
## 15. Collection

GC belongs to the arena. The kind and the size of every traced value come from the TypeRef of its record ([§3](#value-record)). Roots include Message, live graph, mail, execution state, and `Thread.children`; Thread state retains that List independently of source fields. From a live value, collection also follows an established `satisfies` correspondence to its required Structure: replacing a graph field does not release the model while that value still needs its admission. This rule does not retain a transient admitting frame; retirement of the frame removes a record that depends on it. These are address-proof dependencies, not hidden graph fields. The owner retains constructed `independent: immutable` branches until its arena is destroyed. Simple mode does not collect. Unloading a later module needs a separate contract and is not invented here.

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

A reference place is declared with the name first among the receiver's arguments:
`@: p 0`, `@: p Model`, `@Model: p 0`, or `@Model: p Other`. The first argument is a
place-name atom and is not invoked; a supplied initializer uses the resolved receiver's ordinary
contract. A two-argument `@: p Model` initially refers to Model itself. A full requirement
belongs in the typed head `@Model`; `@Model: p Other` supplies its candidate and
`@Model: p 0` supplies an initialized null. The former three-argument requirement/candidate
form is withdrawn.

A nested `@: p Model: Other` is not the typed declaration `@Model: p Other`. In a CODE-consuming
position, `Model: Other` is an ordinary call if Model resolves to a callable; it is not an
alternate notation for requirement plus candidate. Anonymous Structure values and bare references
are not calls. A place-declaration receiver supplied as a CODE argument is preserved as DATA
material under §11, without executing its initializer. These distinctions follow one P0 parser
and the resolved head's contract.

Initial `@: p` declares an absent reference with the corresponding uninitialized TypeRef and
no value payload; `@: p 0` instead supplies an initialized null reference. A later address write
does not retroactively impose a model requirement. Pointer depth `@ⁿ:`
has no arbitrary numerical cap. An ordinary Structure call used as an expression may return the
value described by `return` in its actual parent DATA; neither fncall nor separate substituted
DATA is required. Structural declaration names themselves are not mutable reference variables.

In `@: ptr method`, the `@` receiver comes first, while `ptr` and `method` are bare atoms: an atom is not a call. The form therefore assigns a reference to `ptr` under the `@` contract even when `ptr` already contains a callable; `ptr(args)` invokes it. Unary `@ptr` separately obtains the reference cell's numeric address; it does not return its stored method reference or change ptr's declared reference type. Numeric address use and dereferencing follow the selected level's machine-address contract. The detailed rules of these forms are in [L3](LMX_semantics.en.md#ordinary-var) and [method-reference assignment](LMX_semantics.en.md#method-reference-assignment); the special name `data` is removed ([what is removed](LMX_semantics.en.md#removed-builtins)).

For a namespace variable, unary `@x` addresses the selected logical place: the current call's real local cell or, for the transparent caller place, the caller's real place ([§11](#binding-caller-place)); taking the address is not a write and does not extend lifetime. For computed input `int: x next()`, `@x` obtains its value and the address of its ordinary local int cell. When `D\x` selects a ready source-graph place, `(@D\x)` retains that place's own address. When the data retains computed declaration `int: field getValue()`, `(@D\field)` addresses the record of the declaration and getValue() is not executed: an explicit path executes nothing (the author's decision of 2026-11-17). Explicit `D\field := ...` changes the source field. No automatic transfer connects the local place and the graph. [Common rule](LMX_semantics.en.md#computed-field-address).

In the existing native path, `emit_call_result_value` declares typed `l2_tN`, and `emit_dyn_tail_value` passes `&l2_tN` as the result destination. Reuse this place when taking the address, without another call, a second cell, or a special allocation for `@`. The walker uses the ordinary addressable result cell. The existing place's ordinary lifetime rules apply.

A reference field retains its exact pointer type; a primitive uses its typed cell. An ordinary graph slot physically holds void*; an alias through Lmx** does not replace that representation. Pointer depth is unrestricted; an evaluation temporary's address does not replace a ready place's own address.

Prefix `\p` follows a reference; `p\field` accesses either a graph field or an explicitly imported machine ABI according to `p`'s category. `@array[i]` addresses the actual backing element. Native L2 code adds no automatic bounds check; checked access belongs to L3, and the interpreter executes L2 code with the same checks. Address operations neither bypass `const`/`immutable` nor extend target lifetime. A write to a protected place that the translator sees is refused at translation time; at run time native L2 code does not check it, and the result of such a write is undefined.

Ordinary Array indexing has no from-end interpretation: `array[-1]` is not a valid way to select the last element. Negative relative offsets should be expressed through a suitable pointer, for example `\(p - 1)`, under its ordinary lifetime/allocation contract. L3 and interpreted L2 apply the existing final-element bounds check. Native L2 omits those automatic checks; their absence does not make an invalid Array access valid. A statically known invalid Array index may be diagnosed during preparation, without adding a native runtime sign/bounds check. A negative slice bound is different: `array[-1:]` selects the last element through the [slice contract](TERNARY_AND_SLICES.en.md#negative-index). Reads, writes and address-taking retain one common address calculation; no per-coordinate bounds checks or hidden row descriptors are added.

<a id="lowlevel-array"></a>
## 19. Raw C storage

A `c.*` token is an explicit C door. A language Array remains an `Lmx`-based graph object with typed elements; it does not become a raw C array. Conversion between them requires an explicit operation accounting for shape and lifetime. Typed arena arrays are internal storage, not another kind of language Array. L2 introduces no special `c.array` entity.

<a id="lowlevel-abi"></a>
## 20. External types and ABI

`cast: (T) value` is a machine cast, not a checked L3 conversion or proof of range, alignment, or lifetime. `c.name` selects a foreign C symbol; its adapter defines arguments, result, and ownership. `c.sizeof` means C `sizeof`, not Array length or Structure field count. `include` and `os` select explicit dependencies and a platform branch, not runtime module discovery. The action of `include:` and `predef:` needs one argument, the name of a dependency, so several arguments may be written and each is taken in turn, in the written order, as with the receivers of [qualification](LMX_semantics.en.md#qualification).

`os` selects a target-platform branch but introduces no separate comparison of branches for equal method sets, signatures, or serialized contracts. Differences between branches are not errors in themselves. Selected declarations and bodies use the ordinary L2 mechanisms; wherever a receiving site requires compatibility, the ordinary `satisfies` admission and its address map apply, as outside `os`. Selecting a branch creates neither an additional common interface nor a private `os` admission mechanism. Author clarification, 2026-10-23 (repository provenance: `../LMX_blog/2026-10-23.md`).

The existing `os` receiver selects a branch for the target platform before its contents are semantically processed; no separate new operator is needed. Common structural parsing identifies the branches, but unselected declarations and bodies undergo no name resolution, type or contract checking, dependency collection, or code generation. Their `include`/`define`/`predef` do not add dependencies or declarations to the selected variant. Selected contents pass through the same common L2 pipeline as outside `os`, including ordinary native and walker execution for supported bodies, without a private parser, interpreter, or fallback native route. The target platform is consistent across translation stages, not accidentally determined by the translator host. This is the required translation contract. Author clarification, 2026-10-23 (repository provenance: `../LMX_blog/2026-10-23.md`).

Platform headers and names occurring only in an unselected branch are not required for the selected variant. Its ordinary code may call a method declared only in the selected branch, without a counterpart declaration in the others. Translating every alternative into L1/C and then hiding the unselected ones with C `#ifdef` does not satisfy this rule; their dependencies, declarations, and bodies are not generated. Common structural parsing of the source does not imply semantic translation of an unselected branch. Author clarification, 2026-10-23 (repository provenance: `../LMX_blog/2026-10-23.md`).

This exclusion of branches is a translation obligation. It does not require storing the result of translation-time selection or preparation as a prerequisite for the walker: the walker executes the current graph under [§2.1](#interpretable-tree), not a mandatory translator record of the selected body.

`satisfies` remains the ordinary admission of selected contents, not a static comparison of alternative platform implementations or a mechanism for suppressing their translation. Statically known interfaces are checked during construction; prepared native code adds no automatic runtime `satisfies`, while the interpreter uses that standard mechanism at reached calls. Explicit checks and required behavioral tests keep the common [§14 phases](#satisfies). The existing `os` contract requires neither a second admission engine nor approval of a new operator.

In an evaluated call through the C door, C functions and macros receive already evaluated L2 values, not substituted L2 expression text. L2 arguments are evaluated once in the ordinary lexical order and under the ordinary exit rules before being passed to the foreign call; macro expansion neither repeats nor cancels that evaluation. Thus, with `#define BYTES(x) sizeof(x)`, `c.BYTES(touch())` first executes `touch()` once and passes its value to the macro, although C does not evaluate the operand of the resulting `sizeof`. This also applies to a macro that uses its parameter several times or does not use it.

Literal `c.sizeof` has the role of a C operator, not a C-function call: after common preparation its operand follows C99 `sizeof` rules, not the prior evaluation of a foreign-call argument. Expanding an arbitrary macro into `sizeof` does not give it this role. The distinction is a semantic role after common parsing, without C-name registration or a second parser. For an ordinary non-variably-modified type, `c.sizeof(touch())` does not execute `touch()`; this does not override C99 rules for variably modified types. Author clarification, 2026-10-22 (repository provenance: `../LMX_blog/2026-10-22.md`).

The C door also has the opposite direction: a machine L2 function may be exported with a direct C-compatible entry. C code calls it with the function's explicit arguments, without an `Lmx` instance, root, Message or prepared graph; the state and memory it needs come through its ordinary explicit contract, not through a hidden shared unit, arena or singleton. The function remains the same L2: the existing generator translates it by the common structural parsing, expression resolution and checks, without a separate C-like language, a second parser or resolver, or a route private to List or libraries. Ordinary graph calls of L2/L3 keep their common mechanism; the export does not remove semantics from an arbitrary executable Structure and introduces no new user pointer types: the hidden address of the caller's place is a detail of the native implementation, with the language type `T` unchanged ([executors](#binding-executors)). Maintained sources stay L2/L3 and their L1/C is generated; a ported body replaces the old one without a permanent fallback. This is the required translation contract. Author clarification, 2026-10-23 (repository provenance: `../LMX_blog/2026-10-23.md`).

<a id="lowlevel-expression"></a>
## 21. Machine expressions and ordinary operand methods

Expression grouping uses C's relative priorities and associativity for supported operations;
`**` retains Python-like right grouping and the asymmetric unary relationship:
`-2 ** 2` means `-(2 ** 2)`, `2 ** -2` means `2 ** (-2)`, and `2 ** 3 ** 2` means
`2 ** (3 ** 2)`. Assignment and compound assignment have the lowest priority and associate to
the right. The source graph retains the written chain; backend emission consumes the common
expression analysis rather than passing a textual replacement of `:=` to a C compiler.

Required values are obtained on demand. A consumer may require the result of a lower-priority
operation without changing that operation's grouping or truncating its RHS. In
`f(10 * v := 2 + 3)`, with a distinct first formal x and another input place v, the linked
assignment computes 5, writes the receiving call's v, and provides 5 to multiplication; f receives
one positional actual 50. An old value of v does not replace the result of this particular
assignment. In `f(1 + (v := 2) + 3)`, the explicit group instead writes v = 2 and supplies 6.
A standalone `f(v := 2 + 3; 6)` contains two actuals; it may continue positionally only when v
occupies that current first position. The embedded assignment itself never creates another actual.

One dynamic evaluation executes a required operation occurrence once. Later traversal of that
occurrence reuses its result, not a new read of a mutable destination. A new call, loop iteration,
condition check, or explicit `sys\eval` starts a new evaluation. Short-circuit `&&` and `||` do
not execute unused groups or assignments; there is no eager pass over all parentheses. Compound
assignment evaluates its destination once under the common write contract. While-condition
assignments use the enclosing callable's DATA places and run once per reached condition check.

<a id="operand-contract"></a>
### Operand discovery and typed transport

A user operand is an ordinary method resolved by its own name in the current namespace. Its DATA
is the selected method's actual parent, checked against an ordinary structural header:

```lmx
operand_template:
    @: left
    int: depth
    []@: right
    const: int: PASS_ARGS_AS_IS
    const: int: PRIORITY
```

All five fields must actually exist. `PASS_ARGS_AS_IS` must be a ready constant int 0 or 1;
`PRIORITY` must be a ready constant integer on the common expression scale. Neither missing field
receives an implicit default from the template or from `satisfies`. Mode and priority are
independent. The method declares its ordinary result, for example `return: int` or `return: @`;
the minimal header does not require one fixed result type and does not allow a procedure without
a result to supply an expression value. A complete specialized model can impose input and result
types through the usual structural requirements.

There is no `sys\operand` registration, separate operator-name table, universal `OperandSignature`,
or alternate dispatcher. Discovery, application, and `sys\priority` use the same resolved method
and description. Ambiguous mode or priority is diagnosed before user argument effects. A positional signature
requirement remains useful independently, but positional signature compatibility alone does not satisfy
this name-sensitive structural header.

With mode 0, `left` receives a reference to the prepared left value and `right` an Array of
references to prepared right values in source order. `(1 foo 2 3 4)` supplies one left value and
three right values. In prefix `(foo 1 2 3 4)` no left actual is written; all four are on the right,
and ordinary defaults/requiredness determine whether omission is admissible. No `has_left` marker
or implicit shift of the first right value is added. An Array or Structure in a whole-value position remains one item under the receiving contract; dense numeric Array storage is not reinterpreted as `Array<@>`.

Expression is the ordinary Structure graph interpreted with a [structural grouper](LMX_semantics.en.md#expression-structural-grouping): it determines priorities, complete expression units and streams at the current tree level, independently of source spelling. A separate Expression application adapter packages left as one actual/reference bundle and right as an Array of references. `arg0 operand arg1 arg2 arg3` is the general form; a binary contract uses one right item, with no automatic fold or movement of the first right item into an absent left. The receiving contract selects whole-value or current-level sequence consumption. `(a b c) .: (a c b)` therefore has one left bundle and three right values; three sibling RHS groups remain three Structure items. There is no extra conditional unwrapping pass after grouping. The grouper reads the clean graph. In Expression, a graph reference atom to a Structure forms a group only outside the operand role. Translation rejects ambiguous interpretations before effects. Other reached Structures follow the name/actual-parent rule. Reference resolution preserves the actual parent. Whole VALUE/TYPE/DATA material is not automatically reclassified as CODE. `1 + ((2))` is 3; field collectors such as `(copy(Model))` remain containers for zero, one or many fields. `::` and modifiers keep DATA consumption and the common immediate-field reader; they gain no RHS evaluator. P0, ordinary callable W/E and the existing lifetime/effect rules remain intact. See [architecture and acceptance](EXPRESSION_GROUPING.md); execution is **NOT_RUN**.

These references address values in genuine typed records: value at p, with its TypeRef cell at byteAddress(p) − sizeof(TypeRef).
A container reference addresses its typed descriptor. An untagged C temporary is not such a
record; when a downstream operand needs addressable typed storage, the ordinary expression-result
mechanism provides it with the proper lifetime. Existing suitable storage is reused. No universal
union, mandatory per-value wrapper, or copy of every argument is introduced. Ordinary native
locals retain their machine representation and known type.

The method returns its ordinary declared logical type. An int result is int in both an ordinary
call and operator use; an @ result remains a reference in both. Expression does not universally
remove a reference layer to reinterpret the target as an arbitrary result. `@: ptr Struct` stores
an ordinary reference, whereas `int: value 1 + @Struct` explicitly uses the numerical address.
Prefix `\ptr` only dereferences; it does not execute code. `@x` continues to address the selected
logical place under §18 and never adds lifetime.

<a id="raw-operand-context"></a>
### Raw arguments and the shared evaluator

With `PASS_ARGS_AS_IS 1`, `left/right` hold references to the original argument occurrences,
without executing their literals, names, calls, assignments, or groups. Grouping still follows the
same priorities. A raw handler uses reference requirements appropriate to those source forms;
a requirement for an addressed int does not mean “unevaluated code that may return int”.

`sys\eval(fragment)` explicitly invokes the same expression evaluator on one occurrence and
returns its ordinary value. Each invocation is a fresh evaluation; omission causes no effects,
and two invocations repeat the effects. Dereferencing the fragment is not evaluation. A callable received as a whole value remains a reference. A Structure reached in CODE/Expression follows the [name/parent guard](LMX_semantics.en.md#expression-structure-parent-guard).

Transport retains the occurrence's original active context through existing frames and hidden
parameters, including when a helper receives it. Names in the operand implementation cannot
capture names of the source expression. Embedded writes retain the original receiving-DATA rule,
and `private` retains its ordinary source-context effect; the operator does not gain unrestricted
implicit access. A source-graph address alone cannot identify different activations. This transport
neither extends an activation's lifetime nor revives an ended call; it creates no permanent
context registry or cached result in the source graph. Known fragments may use prepared native
execution through the same mechanism.

<a id="name-priority"></a>
### Name strings and priority queries

`sys\name(identificator)` consumes one written identifier, not its value. It uses the existing
canonical name and name table to return an ordinary variable-length Lmx char Array, without a
trailing NUL or a required per-call allocation. The identifier need not be declared. Exact-name
quoting is removed and doubled backticks become one; the empty exact name gives length zero.
`sys\name(ptr)` gives the spelling “ptr”, not a pointee's name. It executes neither a method
nor a computed initializer, and does not stringify arbitrary expressions. The resulting string
remains one Array in a call.

`sys\priority(name)` consumes a character Array's content and returns the selected available
operand's ordinary int priority, without executing its body or operand arguments. Its descriptive
signature is `PrioritySignature :: ([]char: name; return: int)`. It uses the same visibility and
properties as expression analysis, rather than restricting lookup to fields of sys. Equal string
contents give equal lookup behavior even at different addresses; canonical identifier comparisons
remain pointer comparisons after this explicit name-resolution boundary. Unknown or ambiguous
operands produce ordinary resolution errors, never an invented priority. For `"+"`/`"-"` this
query describes addition/subtraction, for `"*"` multiplication; contextual unary roles do not
silently change that named query. `sys\priority(sys\name(foo))` performs both operations
without calling foo.

The machine profile retains grouping, arithmetic, comparisons, logic, bitwise operations,
`++/--`, indexing, and ordinary control flow. `=` compares and `:=` writes an already known place;
a colon form declares or calls under its role. Overflow and raw indexing follow the machine
contract, not L3 guarantees. `a[i][j]` addresses a rectangular multidimensional Array;
`a[i]\[j]` follows a reference to a separate Array, while `s\[N]field` selects a source name
occurrence. [Expressions, assignment and demand](LMX_semantics.en.md#assignment-inside-expression).

<a id="lowlevel-sync"></a>
## 22. synchronized

`synchronized: lock code` defines a structured exclusion region, not an open lock/unlock pair. Exiting releases the monitor. The mail monitor is one concrete reentrant use without `wait`/`notify`; pure L3 has no raw locks.

<!-- receiver-integration-2026-11-22 -->
<a id="functional-receiver-abi"></a>
## Functional receiver integration and typed-record transport

The [L3 receiver library](LMX_semantics.en.md#functional-receivers) uses the
existing records and Structure storage. Every Structure is directly an Array
of record references; no new list-object ABI or per-payload int box is added.
A generic record reference identifies the code followed by the existing value
or descriptor. Capture materializes a value only where lifetime requires it;
reference identity and the normal arena ownership rules are preserved.
Zero-payload uninit has no storage bytes to read, and void is not a null @.

Generated typed callables use ordinary owner/DATA/CODE and the precise input
and return ABI. The native translator may compile a prepared callable to a real
method; a factory's @ result does not require erasing each later direct native
call into an all-@ ABI. Native entries remain bound through explicit compilation.
Array<primitive> is not reinterpreted as Array<@>.

Both signature-construction forms share the existing ordered full-requirement
description. Variable names do not enter positional signature compatibility.
Preserve the named-signature relationship with `call`; accept both descriptions in all
other supported positions. The generic-call result/failure bridge must retain
ordinary admission and declared exits, and name reflection uses the existing
canonical table. Detailed provider interfaces are in the
[kernel requirements](patterns/LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md).

<a id="unified-20261122"></a>
## Derived types and actual storage

Public TYPE values are ordinary TypeRefs to canonical immutable system descriptions.
The common normalizer preserves complete Array/pointer/callable/model requirements,
explicit dimensions, arbitrary finite pointer depth and zero-payload uninit:T.
Only the normalized LEFT determines type identity; length and reserve do not.
Interning and completed directed satisfies-pair checks remain common service metadata;
value-dependent bounds/size admission and concrete field maps retain their ordinary
scope. Same-context attach retains valid references and ownership; restoration interns
full descriptions and relocates them. An admitted Array<A> keeps actual A storage and
stride. Dense access prepares a value record only when ordinary consumption requires
one; dense elements gain no mandatory tags or second graph.
See [the unified type contract](CORE_SEQUENCES_REGEX.en.md#types) and the
[TypeRef migration](../TYPE_REFERENCES_CHANGE.md).

<a id="array-expression-forms"></a>
### Array expression forms and evaluation

The [common Array expression contract](ARRAY_EXPRESSIONS.en.md) applies to L2 as well: actual Array operands select the admitted matrix/array profile, `.*` means componentwise multiplication, `.=` compares components, and `.:` assigns components. A Structure is the freely typed Array `[]@`. Dotted forms share the scalar form's precedence; the lazy conditional `? :` sits below logical OR and above assignment and associates right. [Slices](TERNARY_AND_SLICES.en.md) and [fuse](FUSION.en.md) use the same source graph and namespace. Native lowering does not introduce a second program graph or bypass scalar admission contracts by silently switching to `int`.

<a id="operand-depth"></a>
### Operand depth in interpretation and native calls

The [common depth input](OPERATOR_DEPTH.en.md) occupies the second operand input: left/depth/right, frame slots 0/1/2. Undotted/single-dot forms supply 0/1; `.(expression)` uses the general parsed graph expression and is obtained once on demand. Only one dot is a modifier. Structural receiver calls use the base canonical name with named `depth`. The default assignment family is `:=` at depth 0, `.:` at depth 1 and `.(expression):` explicitly.

Native and interpreted entry preserve the same input ordering, actual full types, RAW/PLACE roles, and missing-left distinction. The number is not inserted into logical right arguments. VALUE lifting shares the recursive executor and chooses its complete result requirement from the actual depth and shapes; scalar R must not describe an Array result, and void is not Array<void>. The source graph and parent relationships are unchanged. A whole-only semantic profile reports unsupported nonzero depth as a translator/interpreter diagnostic. [Publication requirements](patterns/LMX_Fn_Receivers/PUBLICATION_CONTRACT.md) identify the dependent-result integration boundary.
