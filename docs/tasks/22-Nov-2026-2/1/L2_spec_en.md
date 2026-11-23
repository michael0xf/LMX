# L2 Specification

**Current extension:** [types, universal sequences, text patterns, and callable adapters](CORE_SEQUENCES_REGEX.en.md). The root specifications of this uploaded archive govern this edition; old contradictory spellings are superseded.

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
`uninit:T` has a type code and zero payload, graph assignment replaces fragments, and the full literal
source graph includes both all written receivers and direct primitive leaves. Replacing `uninit:T` with `{T value}` cannot preserve a preexisting T-cell address, because `uninit:T` has zero payload.

<a id="scope"></a>
## 1. Scope

The target chain is L3 with L2 insertions → generated L1 → C99. L1 is an intermediate language. The interpreter executes the stored graph: L2 code with the same checks as L3 code, and an address operation that L3 does not have at all with checks of its own. Native L2 code is compiled without these checks ([semantics, §1](LMX_semantics.en.md#scope)).

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

Structures and Arrays share a flat `parent/length/storage` header, without native, capacity,
or an embedded VoidArray. In L2 order: `Lmx@: parent`, `size_t: length`, `@: storage`.
These are `Lmx *`, `size_t`, and `void *`; the typed requirement is in the head,
not an initializer naming a type.
A reference points to the header's start; the code of the record's type stands in the four bytes
before it ([§3](#value-record)). Structure and Array<@> store void* elements and are fully
interchangeable in indexing, named paths, admission, copying, and execution.
Numeric Array<T> stores T itself; the code of the Array's record tells the element type.

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
An uninitialized leaf has only its type code and zero value bytes. A form whose RHS still requires
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
### 2.2. descriptor and actual header fields

`sys\descriptor(S)` returns an ordinary Structure of S's live field addresses. Without an argument it
selects the current launch's data (the parent of the executed Structure), including inside nested control bodies. Code is explicit.

```text
(
    Lmx@@: parent
    size_t@: length
    @@: storage
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
code requires an explicit argument. R0 has no artificial DATA for these queries. A same-headed data form remains an ordinary Structure, like the path `D\for` to a field of the data `D`.
Ordinary paths S\parent, S\length, S\storage, and S\native select written fields without pseudo-fields.

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

**Physical record contract.** Type and value are stored in one record and obtained from that
record. Arena address ranges establish ownership; they do not determine a value's type.

A value that a Structure or `Array<@>` slot, a reference or `parent` refers to is a **record**: `int type`, the code of its physical type, followed by exactly the payload size defined for that type. A payload may be a number, a reference, or the `parent/length/storage` descriptor of a Structure or an Array. It may also have size zero: `uninit:T` is a type code with no value bytes and no reserved T storage ([§3.1](#uninit-record-control)). The elements of an Array and the slots of a Structure lie in the storage that the descriptor names, not in the record. The size of a record is `sizeof(int) + size(type)`; for `uninit:T`, `size(type) = 0`. No record reserves room for the largest kind of value, and the layout does not follow the rules of a C `union`.

The terminal declaration `int: x 10` is fully present in the graph as the Structure element's record «type `int`, value 10», with the name `x` held by the ordinary «address -> name» row. This is the declaration's direct physical encoding, not its deletion from the source graph. The declaration is recovered unambiguously from the type, the value and the name, so a path to such a field has no step for the receiver: `S\x`, not `S\int\x` ([semantics](LMX_semantics.en.md#primitive-declaration-is-the-element)).

For a record with a value payload, the ordinary graph pointer addresses that value and its type code lies in the four bytes immediately before it. Reading an unknown physical type obtains its code and then follows that type's payload size. An `uninit:T` record has the code alone: there is no T cell to load, store or dereference, and no stable payload-start address is promised for its later replacement. This does not introduce a wrapper or a new public absent-value pointer ABI. The following address example concerns a record that has value bytes:

```text
p = storage[index]     # the slot: the address of the value
code at p - 4          # the code of the physical type
value at p             # the payload bytes of this initialized record
```

**No operation learns a type or reads a value by classifying an address.** Reading and writing a slot, loading a value of a type unknown at translation, `sys\typeof`, indexing, dereferencing, admission by `satisfies`, copying, `merge` and collection take the kind and the size of a value from the code in its record. The arena's index of address intervals stays only for ownership: which arena and which chunk an address belongs to.

**Alignment** (the author left the choice to the implementation: optimal and universal, not by `union` rules). A value stands at an address aligned as its type requires, but not less than four; the code occupies the four bytes immediately before it; padding, where needed, lies between records. So the code and the value are read and written by ordinary typed, aligned accesses on every platform, not by copying bytes, and the descriptor fields keep their natural alignment. With eight-byte pointers a record of `int` takes 8 bytes, a record of `double`, `size_t` or a reference 12 bytes and a step of 16, a descriptor 28 bytes and a step of 32. An `uninit:T` record contains only its four-byte type code; allocator alignment padding is not a T payload or a promise of room for a future value.

The physical inventory includes number primitives, the word, references, “T without
initialization”, ordinary and immutable Structures, and Arrays with their element types
([kernel specification §2.2](kernel-implementation.en.md#arena)). A user model produces no physical
type code of its own: `satisfies` establishes model compatibility. Ordinary and immutable
Structures differ by code; an already published ordinary Structure cannot become immutable in
place. There is no executable-fn result category or separate sub kind. A named positional signature requirement
is interpreted by the common requirement mechanism, not inferred from a similar-looking body.
The flat Lmx descriptor is common to Structure and Array; there is no embedded VoidArray.

A numeric `Array<T>` stores T itself, densely and without codes; the code of the Array's record tells the element type. The address of such an element is a raw L2 address, not a pointer to a record. A typed native local or a temporary result is an ordinary machine value and is not packed into a record.

For every primitive type T, an omitted initializer has the distinct type code `uninit:T`;
the language-level place still has its declared T requirement. The record contains that code alone,
with `sizeof(value) = 0`. Absence is written `nil: T`, or `nil` where its type is known;
initialization is distinct from truthiness and from the input `required` selection rule.

<a id="uninit-record-control"></a>
### 3.1. P01 resolved — a type code without a value

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
| Source declaration `int: novalue` inside S | `{uninit_int}`: the code only, no value bytes |
| A call's local `novalue := 5` | Source stays `{uninit_int}`; the frame holds the assigned value |
| Explicit graph write `S\novalue := 5` | The structural place now holds the fragment `{int 5}` |

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

Every arena has one stream of records “type code, value”: records are issued successively from
its chunks so a Structure's descriptor, slots, and fields can be placed together. A chunk is never
reallocated; growth adds a chunk, and issued record addresses remain stable until their ownership
is released. There are no chunks by type and no typing by address. An interval index remains only
for ownership, attachment, and collection. Earlier typed-pool transition steps are historical
implementation provenance, not an alternative layout contract.

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
Existing payload cells and canonical strings do not move merely because an Array grows; this requires no separate Array per cell. Explicit graph-fragment replacement is a different operation and promises no raw value-address equality with the displaced fragment.
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

Direct children live in the sole child collection held by `Thread.children`, using the common
variable-sized Array storage mechanism. This is Thread state, not a `message.graph` field. `Thread.parent` belongs to the Message hierarchy and does not modify `Lmx.parent`. Competing workers may not execute one Thread identity.

<a id="root-close"></a>
### 8.1. R0 and shutdown

R0 is an ordinary child Thread of the top host scaffold. Its executable entry is an ordinary C method with a local pointer to the R0 graph, including for interpreter execution. This creates no persistent global root pointer or hidden graph-data repository. R0 has no data: it is a procedural entry without user arguments. There is no artificial self-binding of data to code (`data = code`), no empty service Structure and no artificial field `data` for it; R0 may have its own executable declarations and ordinary accessible references ([norm](LMX_semantics.en.md#root-entry)). Runtime launch parameters and settings belong to the scaffold and are passed to R0 explicitly; they are not added to R0's source graph and are not user actuals. The absence of DATA changes input binding, not the common DATA/CODE role rules: reached declaration receivers and calls use their normal contracts, including explicit DATA-consuming arguments. It requires no root-specific parser or implicit self-call. The top scaffold has no parent but gains no special API. Shutdown cascades through each Thread's sole direct-child List. A host watchdog controls the whole subtree's timeout; expiry terminates the process rather than declaring partial shutdown successful.

<a id="mailbox"></a>
## 9. Mailbox

Each Thread owns an `LmxPost`. `staged` prepares the current turn's messages, a successful boundary publishes them to `outbox`, and `inbox` holds admitted but untaken messages. An `inbox` element is the inseparable pair `[target, source_arena]`: the producer does not mutate the recipient arena; its owner attaches the donor before releasing the target. Failure retains the pair. Admission order is FIFO.

`inbox` is a ring over a common variable-size Array with external capacity. One reentrant LmxPost monitor covers admission, take, and count; outbox/staged remain owner-local. Post uses the same mailbox; see the [language API](LMX_semantics.en.md#thread-message-api).

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

`name :: data` supplies a declaration identifier on the left and an ordinary
DATA Structure on the right. The identifier is declared, not read from an
existing variable. The Structure describes the explicit input places
in declaration order and the optional result field `return`. The declared name is constant and can
be imported under the ordinary root-constant rule. The declaration creates a signature description, neither an
executable body nor a native entry. Without `return` the signature is procedural. A structural
result is a nested description inside `return`; `return` is not an input position. The common
parser is used; the right side remains a DATA description without CODE W/E. The former named-declaration receiver is removed, while the named signature/call relationship is unchanged.

```lmx
SumSignature :: (int: a; int: b; return: int)

SumContext:
    int: first
    int: second
    return: int
    sum:
        return: first + second

SumSignature@: sumPtr SumContext\sum
```

The head `SumSignature@` supplies the named requirement; its two arguments are the
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
material is its written declaration, not the result of evaluating its initializer. This distinction
follows the resolved head's declaring contract, not a list of names or a second parser.

| Supplied form | Matching and namespace effect |
|---|---|
| Its declared name is an input name in the receiving data | Match under the ordinary name/position rules; replace that input's description in this call namespace with the supplied declaration. |
| Its internal declared name is absent from the receiving data | Supply the whole declaration as one Structure at the current position; the internal name is not an unknown named actual. |
| An outer `name := declaration` names the actual | The outer assignment chooses the receiving formal; the declaration retains its own internal name. |

Naming the formal at its current position keeps the positional counter active. Naming another
position disables it, after which every later actual must be named. The same rule applies through
a signature interface's public-name-to-position map; that map does not rewrite a declaration's internal
name or execute its initializer.

For example, with receiving inputs `iteration` and `body`,
`iterate(int: item numbers\next(); (item *= 2))` supplies the declaration to `iteration` and the
body Structure to `body`. If the receiving data instead has an input named `b`,
`g(int: b producer())` selects that input by the ordinary matching rule rather than unconditionally
selecting the first position. Neither transfer runs `next()` or `producer()`.

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

`sys\compile(S)` includes clean-graph construction/checking, L1/C generation, the required build
tests on the clean graph before final C compilation, machine compilation, and registration of
resulting variants in call tables. Construction/checking executes no program, initializer or test;
the separate test phase executes only the checks reached through ordinary build/receiver contracts,
with normal dispatch for their candidate/helper calls. Compilation does not launch S's application
entry. Reuse working builder code;
runtime receives only the parts needed for this concrete operation. sys\translate returns L1 and errors,
not LMX or installed native. Failed compilation installs no new entry.

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
compilation of a common unit containing the needed callers and targets. This is builder work,
not a check at every call. Ready binaries of the corresponding ABI can bind to a restored clean
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

Field streams also use ordinary group assignment through an explicit group:
`(a b) := (copy(Pair))` assigns two resulting fields positionally; the bare stream
`(a b) := copy(Pair)` is an error (author's decision, 2026-11-21). All RHS values are obtained before the first write, and a count mismatch is
reported before that write. RHS field names do not reorder targets; already completed RHS effects
are not rolled back.

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
- After clean-graph construction, required build tests run through ordinary build/receiver contracts
  before final C compilation. Required runtime tests run at their reached admission sites. Test,
  candidate and helper calls keep ordinary native/walker dispatch. Merely storing a `test` form
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

GC belongs to the arena. The kind and the size of every traced value come from the code of its record ([§3](#value-record)). Roots include Message, live graph, mail, execution state, and `Thread.children`; Thread state retains that List independently of source fields. From a live value, collection also follows an established `satisfies` correspondence to its required Structure: replacing a graph field does not release the model while that value still needs its admission. This rule does not retain a transient admitting frame; retirement of the frame removes a record that depends on it. These are address-proof dependencies, not hidden graph fields. The owner retains constructed `independent: immutable` branches until its arena is destroyed. Simple mode does not collect. Unloading a later module needs a separate contract and is not invented here.

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
`@: p 0`, `@: p Model`, `Model@: p 0`, or `Model@: p Other`. The first argument is a
place-name atom and is not invoked; a supplied initializer uses the resolved receiver's ordinary
contract. A two-argument `@: p Model` initially refers to Model itself. A full requirement
belongs in the typed head `Model@`; `Model@: p Other` supplies its candidate and
`Model@: p 0` supplies an initialized null. The former three-argument requirement/candidate
form is withdrawn.

A nested `@: p Model: Other` is not the typed declaration `Model@: p Other`. In a CODE-consuming
position, `Model: Other` is an ordinary call if Model resolves to a callable; it is not an
alternate notation for requirement plus candidate. Anonymous Structure values and bare references
are not calls. A place-declaration receiver supplied as a CODE argument is preserved as DATA
material under §11, without executing its initializer. These distinctions follow one P0 parser
and the resolved head's contract.

Initial `@: p` declares an absent reference with the corresponding uninitialized type code and
no value payload; `@: p 0` instead supplies an initialized null reference. A later address write
does not retroactively impose a model requirement. Pointer depth `@ⁿ:`
has no arbitrary numerical cap. An ordinary Structure call used as an expression may return the
value described by `return` in its actual parent DATA; neither fncall nor separate substituted
DATA is required. Structural declaration names themselves are not mutable reference variables.

In `@: ptr method`, the `@` receiver comes first, while `ptr` and `method` are bare atoms: an atom is not a call. The form therefore assigns a reference to `ptr` under the `@` contract even when `ptr` already contains a callable; `ptr(args)` invokes it. Unary `@ptr` separately obtains the reference cell's numeric address; it does not return its stored method reference or change ptr's declared reference type. Numeric address use and dereferencing follow the selected level's machine-address contract. The detailed rules of these forms are in [L3](LMX_semantics.en.md#ordinary-var) and [method-reference assignment](LMX_semantics.en.md#method-reference-assignment); the special name `data` is removed ([what is removed](LMX_semantics.en.md#removed-builtins)).

For a namespace variable, unary `@x` addresses the selected logical place: the current call's real local cell or, for the transparent caller place, the caller's real place ([§11](#binding-caller-place)); taking the address is not a write and does not extend lifetime. For computed input `int: x next()`, `@x` obtains its value and the address of its ordinary local int cell. When `D\x` selects a ready source-graph place, `(@D\x)` retains that place's own address. When the data retains computed declaration `int: field getValue()`, `(@D\field)` addresses the record of the declaration and getValue() is not executed: an explicit path executes nothing (the author's decision of 2026-11-17). Explicit `D\field := ...` changes the source field. No automatic transfer connects the local place and the graph. [Common rule](LMX_semantics.en.md#computed-field-address).

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
    @[]: right
    const: int: PASS_ARGS_AS_IS
    const: int: PRIORITY
```

All four fields must actually exist. `PASS_ARGS_AS_IS` must be a ready constant int 0 or 1;
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
or implicit shift of the first right value is added. An Array or Structure remains one operand
container except for the conditional operand rule below; dense numeric Array storage is not reinterpreted as `Array<@>`.

An operand opens a group only when all three conditions hold: `left` is a written unnamed Structure, `length(right) = 1`, and `right[0]` is a written unnamed Structure. Only the one outer group on the RIGHT is removed, once for this operand application; its immediate fields become `right`. LEFT remains the same whole Structure and merely supplies the condition. Nested groups are not opened again, and a Structure returned by a function is not automatically opened. P0 never performs this transformation. Ordinary callable W/E selection is a separate rule, not an additional operand-opening pass. A named declaration such as `Name :: (A B)` has a name on the left, so its single right-hand Structure remains whole; `Name :: A B` instead has two right arguments.

These references address values in genuine typed records: value at p, four-byte code at p − 4.
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
and two invocations repeat the effects. Dereferencing the fragment is not evaluation. A bare
callable reference remains a reference unless the source form calls it.

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
signature is `PrioritySignature :: (char[]: name; return: int)`. It uses the same visibility and
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

Public type tokens remain int. The common normalizer and type context retain complete array/pointer requirements, arbitrary finite pointer depth, and the distinction between initialized null/empty values and zero-payload uninit:T. Type interning and the table of completed directed satisfies-pair results are required service metadata. Stable pairs reuse their completed result under the applicable type/conversion context, including between calls; concrete field maps and value-dependent checks retain their ordinary reception scope. Attach preserves old code meaning and record addresses; restoration resolves compatible type descriptions. A successful A[] satisfies B[] does not alter actual A stride or authorize an invalid store. Universal sequence access reads actual dense storage or direct @[] references and prepares a value record only as required by ordinary consumption. This creates no mandatory element tags in dense storage and no second graph. See [the unified type contract](CORE_SEQUENCES_REGEX.en.md#types).
