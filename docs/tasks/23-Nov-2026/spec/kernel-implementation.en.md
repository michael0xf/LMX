# LMX kernel implementation specification: graph, namespace, storage, and execution

**Current extension:** [types, universal sequences, text patterns, and callable adapters](CORE_SEQUENCES_REGEX.en.md). The root specifications of this uploaded archive govern this edition; old contradictory spellings are superseded.

This is the implementation target for the standalone Fable acceptance package, reconciled through
2026-11-21. It describes required observable behavior and preserves the established machine,
arena, ABI, ownership, and explicit-compilation contracts. It is not a report that a particular
repository build implements or has passed these requirements. Dated implementation receipts are
kept separately in [implementation notes](implementation-notes.en.md).

The language contracts are the [semantics](LMX_semantics.en.md), [grammar](LMX_grammar.en.md),
and [L2 specification](L2_spec_en.md). They have priority for complete source representation, the graph-plus-method-binary program model,
R0, zero-payload uninit, and ordinary graph-fragment replacement.
The 2026-11-21 field-stream rules, with the latest author correction that import/copy/merge
always take ordinary CODE arguments, control conflicting earlier composition examples and
role-dependent source rules.
Accepted earlier contracts are retained except where these rules explicitly change them.

<a id="binding-callables-20261119"></a>
## Current call and graph baseline

A callable is an ordinary selected executable Structure C. Its actual parent performs the DATA
role. `call(code)` and `call(args code)`, as well as ordinary `C()` and `C(args)`, use the common
selection, reception, binding, execution, and result mechanism. R0 is a procedural entry without
DATA or user arguments. `name :: data` declares a named positional signature, not an executable
implementation. The special data name, separate data call parameter, `fncall`, and `sub` are
removed; `node` remains lexical.

**The clean graph is the full literal source, including terminal primitive leaves. All receivers
remain as written; computations and transformations are performed in the namespace.** Terminal
primitive declarations are stored directly as `{type value}` at the address held by their
Structure cell. This is their source representation, not an omission from the graph. It does
not authorize evaluation of arbitrary RHS expressions during parsing or graph construction.
Import, copying, merging, argument binding, and expression planning do not rewrite their source
receiver records. Ordinary explicit graph assignment can replace any receiver structure,
including `for`, `if`, `merge`, `copy`, and `import`; required recompilation uses the existing
explicit compile/endturn restart boundary rather than a separate graph-editing protocol.

The program has two parts: this complete Lmx graph and a binary containing compiled native
methods. It has no further persistent DATA copy, callable graph, or expanded program store.
`parent` and `length` in the clean graph are logically determined from the source; the remaining
contents occupy the Structure's pointer array. This does not remove the ordinary descriptor
fields or require source-text recomputation at every access.

R0 is compiled as an ordinary C method with a local pointer to its R0 graph. The interpreter
also runs with that binary R0: walking a method without a suitable native variant does not imply
a binary-free R0 or another program representation. Runtime frames, arenas, call/name tables,
mail, and scheduling remain the existing execution mechanisms, not additional program parts.

<a id="principles"></a>
## 1. Principles

1. **One source graph.** Lmx Structures and primitives represent source forms, values, expressions,
   methods, and containers. There is no second executable AST, hidden transformed program, or
   permanent resolved graph. Working activation values belong to the namespace and are not
   automatically published into source data.
2. **Record identity and record type are distinct.** An arena address identifies an object; its
   physical type is read from its record. Address ranges establish ownership, not type. A model's
   compatibility is established by `satisfies`, not by inventing one physical type per model.
3. **Stable values and canonical names.** Issued record addresses and canonical identifier strings
   do not move. A spelling has one process-local canonical string address; resolved identifiers
   compare those pointers. A native local may use ordinary machine storage and is not thereby a
   graph record.
4. **Uninitialized means no payload.** `uninit:T` is only its type code: `sizeof(value) = 0`.
   It contains neither a reserved T cell nor an inner T record. Frame assignment changes the
   selected execution place without changing source; graph assignment replaces a fragment at
   the selected structural place. Its receiving type remains T, and absence does not mean zero.
5. **Scoped service tables.** Name resolution, selected actual maps, expression results, and copy
   maps live for the traversal, call, or operation that needs them and are released on its exits.
   They are not mandatory persisted preparation. Existing arena ownership, name, capacity, and
   call/native tables retain their own distinct lifetimes.
6. **One binding mechanism with different place ownership.** Explicit actuals and autofill fill
   own places; transparent caller access denotes the caller's place; the retained fallback makes
   an own value or description. These modes are not interchangeable merely because a read agrees.
7. **One source-to-graph boundary and two consumers.** The interpreter and translator consume the
   same clean graph. P0 and temporary construction data are not retained as a hidden fallback.
   Generated loading code initializes that same graph through common constructors.
8. **Role-directed consumption.** DATA and CODE are roles assigned by ordinary receiver contracts,
   not alternate memory kinds or parsers. `import`, `copy`, and `merge` always consume ordinary
   CODE arguments and supply fields through the surrounding namespace consumer. Their placement
   inside DATA does not change their argument role or create another argument algorithm.
9. **Explicit native updates.** Graph edits do not invalidate native or trigger compilation.
   Successful explicit compilation followed by the endturn boundary makes the prepared update
   effective at the next entry. Known native calls may remain direct C calls.
10. **Observable behavior controls optimization.** Types, selected places, initialization state,
    effects, lexical links, privacy, and lifetime must agree across native/walker combinations.
    The [zero-payload `uninit` rule](LMX_semantics.en.md#uninit-zero-payload)
    resolves P01 and supersedes the former reserved-cell and first-write retagging descriptions.

<a id="contract"></a>
## 1a. The builder and the two consumers

| Stage | Responsibility | What survives the stage |
|---|---|---|
| P0 and graph construction | Preserve written Frames, groups, order, source positions, and lexical links; construct terminal primitive records; intern names | The clean Lmx graph, typed records, ordinary address-to-name rows |
| Interpreter | Use the binary R0 entry and read the graph under current roles/namespace; execute reached operations | Program-authorized graph changes and ordinary live execution state |
| Translator | Analyze the same graph and emit L1/C/native; use common admission and expression rules | Generated code and successful explicit call/native installations |
| Generated loader | Allocate records and restore the same links/names through common constructors; restore native bindings in existing call tables | The restored clean graph and legitimate arena tables |

The loader does not need to embed P0 or keep source text as an execution reserve. A generated
initialization method constructs or restores the graph through the common mechanisms; it does
not leave a static DATA replica or a second prepared program alongside that graph. Construction
from text, `sys\fromLmx`, copy/merge results, child reservation, and mail uses the common graph
allocation and ownership mechanisms. It does not execute arbitrary initializers or `test` to
prepare future calls. Constant property acquisition, admission, or DATA consumption uses its own
ordinary namespace operation; its results do not replace source receivers.

The common P0 closing mechanism recognizes a blank physical line outside escaped content as a
complete close to the current document root, at virtual level −1. It closes open vertical and
short forms immediately, resets continuation to that root, and creates no field, call, or return.
A whitespace-only line has the same effect regardless of indentation; a comment-only line is
not reclassified as physically empty. Repeated complete closes are idempotent. LF, CRLF, and
standalone CR retain their original byte widths in diagnostics. A missing internal `)`, `]`, or
`}` is not synthesized. Mix is a separate document with a local root; a blank line there does
not close the outer document or replace the Mix terminator. EOF retains ordinary final closing.
This is a check of the shared level/closure contract, not a new parser subsystem. Serialization
and source formatting must not insert blank lines inside a block intended to continue.

<a id="arena"></a>
## 2. The arena

<a id="value-record"></a>
### 2.0. Value records

A graph value record has a four-byte physical-type code and the payload required by that type:
a number, word, reference, or the flat `parent/length/storage` descriptor. For an initialized
value, an ordinary graph reference points to its value bytes and the type code is immediately
before that address. `uninit:T` has zero payload: its record is the type code alone. It must not
be accessed as though a T cell or complete inner T record followed it. The logical record size
is the type-code size plus the actual payload size; it reserves neither space for the largest
value nor a future T value and is not laid out as a C union.

The value is aligned as required by its type, and at least to four bytes. Padding lies between
records rather than between tag and value. Typed aligned accesses read the code and value;
descriptor fields retain their natural alignment. With eight-byte pointers, an int record occupies
8 bytes, a double/size_t/reference record 12 bytes with an aligned step of 16, and a three-field
Lmx descriptor record 28 bytes with an aligned step of 32.

For an initialized value-record reference p:

| Address | Meaning |
|---|---|
| p − 4 | Physical type code |
| p | Value bytes or descriptor |
| `descriptor.storage` | Dense elements/slots, outside the descriptor record |

For `uninit:T`, the payload contributes zero bytes; only the physical type code is present.
Inspecting that code is sufficient to observe absence. No raw T-value address can be retained
from nonexistent payload storage for use after a future graph replacement.

Type-sensitive readers, `sys\typeof`, indexing, dereference, admission, copying, and GC obtain
type and size from the record. Earlier helpers named `lmx_range_classify`, `lmx_range_type_of`,
`lmx_range_stride`, `lmx_domain_kind`, and `lmx_domain_type` cannot continue determining type by
address interval; their consumers use the record contract. A null or outside-arena address has
no graph-record type under the ordinary ownership checks. This does not license reading a tag
before arbitrary foreign pointers, native locals, or dense numeric Array elements.

A type-code word contains a code, without hidden flag bits or masks. Physical distinctions such
as immutable or uninitialized variants use their ordinary type codes. User models and individual
Structures do not each receive a new physical code. Native locals and temporaries keep their
machine representation; bridge code obtains their type from the call/place contract.

### 2.1. Chunks, ownership, and attachment

Each Message owns one logical arena with a single stream of records across its chunks. Chunks
are not grouped by value type and are never reallocated. Growth adds chunks while already issued
record addresses remain stable. The interval index identifies which arena and chunk own an
address, for lifetime, attachment, collection, and finding the owner of a name. It is not a type
index and supplies no semantic declaration role.

`lmx_arena_attach` transfers donor chunks to the receiving arena without moving records or
re-registering their types. One arena is not accessed concurrently by several threads. The
Message/Thread/mail contracts continue to govern ownership transfer; no cross-thread graph
mutation is introduced. `mark`/`revert` rolls back failed copy/merge construction by releasing
new chunks and restoring existing allocation positions, without undoing unrelated prior program
effects. Simple mode keeps stable addresses and does not collect.

### 2.2. Physical types and service storage

| Category | Physical payload and interpretation |
|---|---|
| Number primitive | The corresponding target-machine T value; exact scalar layout and numeric semantics follow the machine profile |
| `uninit:T` | Its physical type code only; zero payload, no reserved T cell and no inner T record (§3.2) |
| Word | A pointer to the canonical identifier string; operators and receiver words use this same representation |
| Reference | A typed reference cell containing an address, or zero under its ordinary contract |
| Ordinary/immutable Structure | One flat Lmx descriptor with the corresponding physical code |
| Array of T | The same Lmx descriptor; its record code supplies T; numeric storage is dense T and reference storage is `void *` |
| Text and canonical strings | Character storage under the existing ownership and string rules |
| Address-to-name rows, capacity, call/native tables, ownership indexes | Existing service data, not hidden user fields or alternative program representations |

There is no physical executable-fn/sub category. `Name :: DATA` creates a named signature requirement interpreted by
the common requirement mechanism, while executable C remains an ordinary selected Structure.
Source roles are not inferred from a special code-memory region or from a resemblance of fields.
An already published ordinary Structure cannot become immutable in place merely by relabeling it.

### 2.3. Allocation and variable-sized storage

When the graph is known, emitted construction may size the needed records and backing blocks
exactly and initialize them directly. Runtime construction obtains records from the same arena
stream. A primitive declaration without a value contributes only its uninit:T code; construction
does not reserve storage for a future T value. An explicit graph assignment supplies a new
fragment under the existing allocation and ownership rules and replaces the selected field's
fragment. Copying or parsing does not create an Array for every standalone primitive.

Lmx descriptor addresses remain stable while backing storage may move. The arena's existing
“descriptor address → capacity” table records capacity in elements. All variable-sized Arrays,
Structure slot storage, and service arrays use the common allocation/resizing mechanism; there
is no separate fixed-Array contract or List/DynamicArray family introduced only for growth.
`sys\resize` coordinates length and storage; `sys\reserve` changes reserve without changing
length. Ordinary indexed access does not consult capacity. Restoration may start with
capacity equal to length.

### 2.4. Collection

GC follows reachability from the live graph, Message/Thread state, mail, and live execution roots,
including call-local places, pending actuals/results, and the state needed by active cleanups or
continuations. It reads graph record types rather than classifying addresses by type. It follows
Structure/reference-Array slots, reference cells, parent links, and necessary ordinary metadata.
Dense numeric Array payloads are not scanned as pointers. A transient mark bitmap belongs to the
collection pass; it is not an initialization-state bitmap for language places.

Address-to-name rows survive for live named records and are removed for dead ones. Code-only
uninit records have no payload to scan. Graph-field replacement follows ordinary reachability;
an old fragment is not retained or transformed merely because it previously occupied that field.
Required model dependencies of an admitted live value
remain live for the operations needing that correspondence, without retaining an expired admitting
frame. Typed scalar metadata and source/profile dependencies remain live where their physical
objects require them. An `independent: immutable` branch is retained by its owner under the ordinary
contract until that ownership ends; a separate allocation pool alone grants no retention right.

Collection does not compact live records. Chunks with no live records may be released; reuse of
free storage must preserve every still-live address. Temporary borrowed spans detach before their
owning scratch storage is rewound or freed; scratch words are not assumed to be graph edges.
Unloading a module with externally retained branches needs its own existing ownership contract,
not an invented global store.

<a id="lmx"></a>
## 3. The Lmx graph

### 3.1. The flat descriptor

| Field, in order | L2 type | Meaning |
|---|---|---|
| `parent` | `Lmx@: parent` | Actual structural parent, zero at a graph root |
| `length` | `size_t: length` | Structure field count or Array element count |
| `storage` | `@: storage` | Address of element storage |

There is no embedded VoidArray, native field, or capacity in the header. A reference points to the
header start, preceded by the record's type code. Structure and Array<@> store `void *` slots and
are interchangeable in common indexing, named paths where names exist, admission, copying, and
execution. A category label alone is not grounds for refusal. Numeric Array<T> stores T densely;
a block of `void *` slots cannot be reinterpreted as an arbitrary numeric Array by casting it.

An L2 slot/element address is `void **`/`T *` and remains valid only while its backing storage is
not relocated. L2 indexing of any finite rank computes offsets without automatic length, sign,
arena, or former-field checks; negative indexes are not rejected merely for their sign. L3 reduces
adjacent indexes to one linear index and checks it against current length. An L3 Array-element
reference holds the descriptor and index, never a stale storage pointer. The distinct L3
primitive-pointer type uses the common typed-reference/uninitialized foundation. Arbitrary finite
pointer depth and Array rank do not require separate algorithms for each depth or rank.

<a id="get-descriptor"></a>
### 3.1.1. Actual header addresses

`sys\descriptor(S)` returns an ordinary Structure containing the three live field addresses:
`Lmx **` for parent, `size_t *` for length, and `void **` for storage. With no explicit S it selects
the current launch's DATA under the ordinary default-argument contract, including inside inline
control bodies; code must be selected explicitly. R0's lack of DATA is not repaired with a
synthetic self binding or empty Structure.

Dereferencing a returned address writes S's actual field; assigning a field of the returned
Structure changes that result's pointer. There is no proxy, copy-back, or duplicate descriptor.
Writing length alone allocates nothing; coordinated resizing uses the existing sys operations.
The result has no native/capacity fields. The address of S.parent may numerically equal S, but a
`Lmx **` access still addresses that field, not another standalone Lmx. Taking an address neither
extends lifetime nor transfers ownership.

`@x` addresses the selected logical place: the current activation's own cell or a transparent
caller place. `(@D\x)` addresses an explicitly selected ready graph field. If that source field
contains computed declaration `int: x getValue()`, the path addresses the declaration record and
does not execute getValue. By contrast, addressing an own computed input obtains the value under
its normal consumption rule and uses its local result cell. `node` is the lexical operation; it
is not a substitute spelling for every explicit DATA path. [L2 addresses](L2_spec_en.md#lowlevel-address).

<a id="header-receivers"></a>
### 3.1.2. Header and service queries

`parent(S)`, `length(S)`, and `sys\storage(S)` directly read the three fields. `sys\native(S)`
queries the existing call tables for the ordinary descriptor of native variants, or zero when
absent. `sys\capacity(S)` queries the arena's reserved capacity. These queries execute no target
code and create no auxiliary descriptor. Their zero-argument forms select current DATA by the
ordinary contract; they do not give R0 artificial DATA.

`sys\resize(S,n)` changes length and provides storage; `sys\reserve(S,n)` ensures reserve only.
Ordinary source paths `S\parent`, `S\length`, `S\storage`, and `S\native` select written fields;
there are no pseudo-fields. Renaming a header's size/data to length/storage does not rename every
unrelated technical structure. Call takes args/code, and `node` retains its lexical context.

<a id="system-indexof"></a>
### 3.1.3. A field's physical index

`sys\indexof(field parent)` returns the physical index of the unique reference occurrence among
parent's immediate elements. Absence or multiple occurrences fails under the ordinary failure
rules. `sys\indexof(field index parent)` selects zero-based occurrence index of that same
reference and returns its physical index. If the reference occurs at positions 2 and 5,
occurrence 1 returns 5. Both forms require parent explicitly; neither has a zero-argument form.

Lookup compares field identity, not an equal name or primitive value, and follows no nested
Structure or graph reference. Structure and Array<@> share immediate-element access. This needs
no reverse-index registry or per-write maintenance.

<a id="primitive-storage"></a>
### 3.2. Primitive places and exact scalar ABI

A terminal `int: x 10` inside S is an int record with value 10; S's slot points at the value and
its address-to-name row names x. It is not a receiver Frame with an extra int child. Thus its
path is `S\x`. A nonterminal declaration with a computed RHS retains its written receiver record
in the source graph; ordinary namespace consumption obtains its result separately. Modifier and other receiver records are
never flattened just because they contain a primitive declaration.

**P01 — resolved by the author, 2026-11-21.** `uninit:T` is its type code alone:
`sizeof(value) = 0`. There is no inner T record, preallocated T cell, unwritten T payload, or
extra pointer to such a cell. The logical receiving type remains T, and absence is distinct
from an initialized T value.

The clean graph is the complete literal source representation, including terminal primitive
leaves represented directly as `{type value}`. An assignment in an execution frame changes the selected
namespace place and leaves this source graph unchanged. In contrast, explicit graph assignment
replaces graph material at its addressed structural place. For source `int: novalue`, the write
`struct\novalue := 5` replaces the selected `{uninit:int}` fragment with `{int 5}`. It is not a
retag of a preallocated same-address T cell, and it promises no stable raw payload address across
the replacement. A later lookup of that field observes the new fragment and its `int` type.

This follows the [semantics](LMX_semantics.en.md#uninit-zero-payload)
and [L2 representation](L2_spec_en.md#uninit-record-control). The old question's
[anchor](implementation-notes.en.md#uninit-layout-conflict) is retained as a resolved decision.
Stable Structure descriptors and descriptor/index Array-element references are independent
contracts; they do not turn an absent primitive into allocated payload storage.

The ordinary typed-absence value is `nil: T`, or `nil` where inferred; nil/required checks observe the
place's real initialization state. No initial zero, random value, or special blanket error is
invented, and no nonexistent payload is read merely to inspect absence.
An omitted input is not automatically required solely because its description has no default:
requiredness is the receiving declaration's ordinary contract.

An assignment to an own call-local place does not write the source graph. An assignment through
a transparent caller place updates the caller's selected execution place and initialization state immediately.
`D\x := value` replaces the fragment at the explicitly selected graph place. None of these is copy-out on return.
Signature descriptions themselves are not mutated when a call fills its own actual places.

The existing exact scalar carrier `LmxScalarABI {size, init, copy}` describes access to a C
scalar object. Generated type aliases and typed init/copy callbacks come from the primitive
source description. Equal C spellings may share access callbacks while retaining distinct LMX
source requirements. None/void has no cell; an opaque FILE is not assigned a guessed scalar ABI.
ABI size and callbacks are representation data, not an LMX model or a substitute for source type.

Preserve the separation of `scalar_abi`, `physical_profile`, and `source_type` from ordinary
model/reference/referent information in the existing value transport. A typed machine object
must have a known lifetime and owner when retained; an automatic C local's address cannot be
made persistent merely by storing it in a reference. A suitable immutable cell can keep its
identity, while a copied scalar requires the correct destination ABI and protection checks before
typed copy. An absent value is transported by its code without reading or reserving payload bytes. A source fact
or equal C spelling alone does not prove physical storage compatibility, and an ABI match is not
semantic conversion. Ordinary graph slots remain `void *`; aliasing them through `Lmx **` does
not change the actual stored representation.

### 3.3. Source expressions and operation results

For `x + 1`, the ordinary structural representation retains the written name x, operator word +,
and primitive value 1. Heads and path/name components retain canonical word strings; no numeric
opcode, `LmxOp`, or special code-memory type is introduced. Written Frames, groups, and their
parent/order/length relationships survive parsing. A path-head call and a path assignment are
distinguished through the common structural form and consuming role, not a private parser.

After P0, common expression analysis determines grouping, priorities, and value dependencies in
the namespace. Supported operators follow C relative precedence/associativity; `**` groups to the
right and has the accepted asymmetric relation to unary operations. Assignment has low priority
and associates right. When a consumer needs the result of an embedded assignment, the assignment
executes with its full grouped RHS before the consumer, without being given higher priority.

`f(10 * v := 2 + 3)` therefore writes 5 to the receiving call's v and supplies one positional
actual 50. `f(1 + (v := 2) + 3)` writes 2 and supplies one actual 6. A standalone named actual
occupies its own position; an embedded assignment does not. Available destination/shape checks
precede effects, and needed places exist when actual expressions access them. Effects occur once
per operation occurrence in that dynamic evaluation; the result is retained for its consumer,
not replaced by a later read of a mutable destination. `v := v + 1` reads the old right-hand v
normally and does not recursively demand the assignment itself.

Short-circuit consumers request only their reached operands. There is no eager pass over all
groups or assignments. A new invocation, iteration, condition check, or `sys\eval` performs a
new evaluation. These temporary results are not cached as fields of the source graph. Native
emission uses this same analysis and may order statically known dependencies directly.

<a id="operand-contract"></a>
### 3.3.1. Ordinary methods used as operands

A method's own resolved name is its operator name. Its actual parent DATA must satisfy the
ordinary structural header with named fields `left` (reference), `right` (Array of references),
`PASS_ARGS_AS_IS` (ready constant int 0 or 1), and `PRIORITY` (ready constant integer). All four
must exist; checking a template does not add a missing field or copy a template default into the
candidate. Mode and priority are independent. The minimal header does not impose one result type;
the method declares its ordinary result and the expression consumer checks it. A procedure
without a result cannot supply an expression value merely by matching that header.

There is no `sys\operand` registration, separate name registry, universal operand fn-signature,
or different dispatch path. Import, references, shadowing, two-way private, and ordinary admission
apply. A description-derived index within current analysis is permissible; a hidden persistent
registry is not. Ambiguous priority/mode must be resolved or diagnosed before user argument
execution. Matching `fn` input positions under different names does not satisfy this explicitly
name-sensitive operand header.

Mode 0 prepares the needed values once: left is a reference to the left value, right is an Array
of references to right values in source order. `(1 foo 2 3 4)` has one left and three right values;
`(foo 1 2 3 4)` omits left and has four right values. The ordinary call contract decides whether
that omission is allowed. A container is one operand except for the conditional rule below; a dense numeric Array is never cast to Array<@>. Prefix application does not shift the first right value into left or add a has-left flag.

An operand opens a group only when all three conditions hold: `left` is a written unnamed Structure, `length(right) = 1`, and `right[0]` is a written unnamed Structure. Only the one outer group on the RIGHT is removed, once for this operand application; its immediate fields become `right`. LEFT remains the same whole Structure and merely supplies the condition. Nested groups are not opened again, and a Structure returned by a function is not automatically opened. P0 never performs this transformation. Ordinary callable W/E selection is a separate rule, not an additional operand-opening pass. A named declaration such as `Name :: (A B)` has a name on the left, so its single right-hand Structure remains whole; `Name :: A B` instead has two right arguments.

Operand references point to genuine typed values/descriptors, with the tag immediately before
the value. Untagged native temporaries use the ordinary result/storage bridge when a typed record
reference is required; suitable existing storage is reused. This does not require a union,
mandatory argument copies, or universal value wrappers. An ordinary `return: int` returns int;
`return: @` returns a reference, equally for ordinary and operator calls. Expression does not
universally dereference every operand result into another logical type.

Mode 1 passes the source argument occurrences without execution. A raw handler uses suitable
reference requirements; “reference to int” does not mean “arbitrary unevaluated code returning
int”. `sys\eval(fragment)` invokes the one evaluator in that occurrence's original active
context and returns its ordinary value. Calling eval twice repeats effects, while not calling it
causes no argument effects. `\fragment` only dereferences. A bare callable remains a reference
unless the source form calls it. Forwarding a fragment to a helper retains the original context,
including receiving-DATA assignment rules and private visibility. A graph address alone does not
identify an activation; use the existing frame/hidden-argument transport. This retains neither an
ended frame nor a permanent result cache and creates no new lifetime extension.

`@: ptr Struct` stores an ordinary reference; `@Struct` in an address expression explicitly
produces its numeric address, as in `int: value 1 + @Struct`. `@x` still addresses the actual
selected logical place. `sys\name(identificator)` consumes a written identifier without resolving
its value or requiring a declaration, and returns the canonical spelling as an ordinary
variable-length Lmx char Array, without a trailing NUL. Exact quoting and doubled backticks follow
the normal parser rule. `sys\priority(name)` resolves the string's content under the same
visibility and operand description as expression analysis, and returns its ordinary int priority
without running the body. Equal contents work at different string addresses; unknown/ambiguous
operands fail normally. `sys\priority("+")` denotes addition's priority, not an arbitrary unary
role. The descriptive contract is `PrioritySignature :: (char[]: name; return: int)`.

### 3.4. Callables and namespace

<a id="call-receivers"></a>
### Structural call

| Form after unique selection | Executed C | Explicit material | DATA |
|---|---|---|---|
| `call(C)` | C | Not supplied | Actual parent(C) |
| `call(A C)` | C | Structure A | Actual parent(C) |
| `C()` | C | Empty tail | Actual parent(C) |
| `C(args)` | C | Written actuals under the common algorithm | Actual parent(C) |

Call's one-argument declaration requires code; its two-argument declaration requires args and
code. `call(code := C)` therefore cannot gain a second candidate through an implicit args source.
Call executes C itself without looking for a child code field. The call site cannot substitute
DATA. A different combination requires an ordinary structural relation produced beforehand under
its own declaration/copy/merge contract. `NewContainer: ExistingCode` contains a reference and
does not reparent ExistingCode. Shared native machine code does not replace each selected
occurrence's actual parent. `node` retains the selected occurrence's lexical source, separately
from parent(C), and is never redirected to a stream consumer.

The data field `return` describes a result without assigning a shared recursive result cell.
CODE `return: value` supplies an admissible result; bare return retains its procedural exit
contract. Fallthrough does not synthesize return. Ordinary Structure calls and call may return
values; there is no fncall or separate result channel in the call surface.

<a id="fn-signature"></a>
### Named positional signatures

`name :: data` is an ordinary expression-operand application with a left declaration identifier and one complete right DATA template. The name becomes a constant signature name;
the data template supplies the ordered explicit input types and optional result description.
Return is not an input, an Array is one input, and a nested user Structure is not automatically a
formal. The declaration produces no body or native implementation and does not use ordinary-call CODE W/E expansion. Inspecting the fields of its one right template is not operand unwrapping; its left identifier does not satisfy the unnamed-Structure condition.

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

`sumPtr(a := 2; b := 3)` supplies positions 1 and 2 to first and second. A direct
`SumContext\sum(first := 2; second := 3)` uses the candidate's own names. The common satisfies
engine compares fn requirements by ordered LMX input count/types and result presence/type,
using the selected candidate's parent contract. It does not compare names, defaults, or body
trees, and does not reorder differently typed candidate positions to make names agree. Hidden
native parameters and code locals are not explicit signature positions; optional inputs remain
positions.

A fn-constrained reference matches explicit actual labels against fn's public names, maps them
to positions, and supplies the candidate at the same indexes. The candidate's own names are not
extra public aliases. Actual evaluation remains in written order; defaults, requiredness,
throws, and hidden binding use the candidate's real declarations and names. Values in the fn
template do not overlay parent(C). A two-argument `@: p Model` initially refers to Model itself;
separating requirement and implementation uses the typed head in `Requirement@: p Candidate`.

An ordinary explicit structural model instead requires its entire specified tree, including
written method subtrees; additional candidate fields are allowed under the common rules.
Neither the name “Signature” nor a return field silently changes that rule into fn matching.
These are two requirement rules inside one satisfies mechanism, not separate parsers/validators.

<a id="declaration-selection"></a>
### Explicit-only selection and actual effects

Resolve the callable and its visible declarations first. A candidate consists of the declaration,
a reading of explicit actuals, and its actual-to-formal map. W keeps actuals as written. E is an
additional one-level reading when exactly one supplied actual is a Structure/reference and is
not assigned explicitly to a formal. Named fields retain their names. `f(arg := S)` offers only W.
W and E have equal priority: zero applicable candidates refuses, exactly one is retained, more
than one is ambiguity even for two readings of the same declaration. Never select W first,
prefer an arity, or re-expand the chosen actuals during execution.

Ordinary name/position matching, duplicates, excess inputs, own defaults, requiredness, and
applicable satisfies checks determine admission. Required inputs cannot be rescued by hidden
caller values during selection. Optional inputs of the selected call may later autofill. Naming
the current positional formal keeps the counter enabled; naming another position disables it,
after which all further actuals must be named. No speculative assignments/defaults/test are
executed for each candidate. Reuse an already obtained actual value for different readings;
perform available shape checks before its effects.

Required receiving places exist when an actual expression needs them. Computed actuals execute
once, in written order, each received before the next. A failed evaluation or reception stops
later actuals and the body. Service dispatchers or bridges do not become the language caller's
local context. Actual reception neither writes source DATA nor starts an eager initializer pass.

<a id="private-binding"></a>
### Two-way private and place ownership

For an own active declaration, the source order is explicit actual, own ready value or initializer
description, then permitted autofill from a same-named caller local, otherwise ordinary uninit
and required checks. Actual presence is not truthiness: zero and explicit nil are supplied values.
A computed initializer is not absent simply because it has not run. Autofill fills an own cell;
writing it does not write the caller. The retained free-name fallback is not extended to omitted
formals merely because it has lowest priority.

For an external used name with no active own declaration, first protect the really visible
lexical declaration if it is private. Otherwise a suitable caller local may be a transparent
place. If that new source is unavailable, retain the prior lexical/dynamic fallback with its
own value or description in this activation. A bare write to a fallback copy changes the copy,
not its source; a reference value copies the reference, not the referenced object.

Private filters both directions of every implicit dynamic mechanism: a private caller place is
not offered as value or place, and a visible private receiving/lexical declaration is not
replaced from dynamic context. Check the actually visible receiver declaration, not any same
spelling somewhere in an ancestor. A private source can be skipped in favor of a farther
permitted source; private is not a name barrier. Explicit passing, filling a private formal,
nested lexical visibility, explicit paths/node, and ordinary inner shadowing remain allowed.
Const/immutable and type restrictions still govern writes. A copied explicitly supplied value
does not carry a private history into an unmarked new declaration. Modifier records stay in the
graph, for example `S\private\field` rather than an automatic flattening to `S\field`.

Recognize `private` from that ordinary receiver in the same clean graph. The native methods
reflect the resulting binding rule; they do not need a second marked graph in the binary with
privacy, initialization, or other per-node flags. Temporary resolution facts and actual frame
values must not be turned into a persistent annotated program under a different name.

A transparent name has ordinary LMX type T. Reads, writes, and address-taking use the caller's
actual place, including its initialization state. A hidden native T* transports that place; it
does not change the language type or require writing `\x`. For a reference variable the cell's
address, not merely its pointee, is needed to reassign it. Writes take effect immediately, without
copy-out. The fallback copy cannot be optimized into that alias, nor the alias into a snapshot
with return-time write-back. The binding stays selected within its ordinary scope.

The chain A → B → C still reaches allowed sources even when B does not consume the name. It
requires neither a dummy local nor a static transitive list of descendant requirements. If B
has its own copy, C can address B's place without reaching back to A's original. If B already
denotes A's place transparently, the same address propagates. A copy's origin is not unwound into
an alias.

<a id="call-frame-20261115"></a>
### Call-local declarations and passed forms

Independent calls have independent namespaces. Preparation reads relevant data/code roots
without scanning future branches or graph references, executing unused initializers, or
exposing a future local early. Variables/const become visible from their initial declaration;
Structure/callable names retain bidirectional visibility. A reference variable holding a callable
retains variable visibility. Before an inner declaration is active, ordinary outer resolution
applies. A genuinely nested declaration creates a distinct place and shadows the outer one;
same-level redeclaration uses the existing place, reevaluates a written RHS, and does not zero
an existing value when RHS is absent. Leaving the inner scope restores the outer binding.

<a id="declaration-arguments"></a>
A place-declaration receiver supplied in CODE arguments is read as DATA and preserves the form,
not as a call to execute while passing the argument. The declaration is an ordinary Structure
actual, not its initializer's computed value. Without an outer named assignment it is supplied
at the current positional input under ordinary admission. An outer `formal := declaration`
selects that formal and supplies the same whole form. The internal declared name is never
looked up among receiving inputs, even if it matches one, and does not redirect positional
supply or replace another input's description by name. Only the written outer actual label uses
the public-name/position map through fn interfaces. Interpreter reception and native lowering
have no found-name/absent-name branch for the declaration's internal name. Ordinary W/E selection
and the common parser are unchanged; passing the DATA form executes no initializer.

Executing the accepted form logically supplements the receiving execution's root namespace. Its
first reached execution establishes its typed place; subsequent executions reevaluate its RHS
and update that same root place. The stored form stays callable again. An associated body from
the same original argument Structure uses the established place rather than creating a computed
copy or evaluating its initializer merely on entry/read. The body's physical parent remains the
source argument Structure, not the library method. Truly nested scopes still shadow normally,
and independent receiving calls do not share mutable locals through the source graph. The
associated body also retains its original active source-context places: in a demo that accumulates
`total += item`, `item` is the established receiving-root place and `total` is the live place of
that demo. The body does not replace total with a generic fallback copy or a new closure; the
existing associated-body context and its lifetime rules carry these two bindings.

This rule is determined by the resolved declaring head. Ordinary `Producer()` and
`Producer: argument` remain CODE calls when Producer is not a place-declaration receiver.
Ordinary Structure/reference values do not automatically publish all their fields into the root.
For the exact inline-shadowing case of the [control example](LMX_semantics.en.md#inline-declaration-control), the inner no-RHS place is `uninit:int`:
an inline lexical scope adds no callable caller, and the stated actual caller has no x.
A reached required check refuses the absent value; the distinct outer x remains 5. This is
derived in the [notes](implementation-notes.en.md#inline-declaration-control), without a new
initialization source or global outer-local copying rule.

### 3.5. Names, receiving views, and source facts

Word occurrences in heads, paths, expressions, and actual labels remain words in the source graph; a composed head retains its complete written structure. The
consumer resolves them through its current namespace and lexical/dynamic contracts. The builder
does not bake a hidden future binding into a word or expand a mention of a known Structure.
`Struct1: Struct2` contains its written mention/reference rather than copied fields; Struct2's
parent does not change. Ordinary explicit graph reference values remain legitimate graph edges.
Recursive activations read their own selected working places, not a shared mutable formal default.

Borrowed receiving views may use the existing `declaration_parts` interface to retain the source
root, leaf/model/candidate, presence, and known-role information. They must preserve qualifier
order, group boundaries, and the complete receiving description. A DATA logical name is established
by the resolved declaring contract, not by a head whitelist or the number of arguments. Model and
default descriptions are not evaluated merely to classify them. A raw declaration form is not
misrepresented as its ready result, and a named signature is not misclassified as an implementation.

The existing operation-local source reader can provide names and requirement facts to common
satisfies traversal. Keep source interface identity distinct from physical type/cell/ABI. Equal
C spellings or sizes do not unify language requirements; unproved evidence stays unproved rather
than turning into a positive result. C-door source spelling is one role projection of an actual
C declaration, not proof inferred from an arbitrary `c.` prefix. Querying a candidate does not
run it, a converter, or test; a subsequent actual admission retains its ordinary checks. No
persistent name/type permission table is created beside the graph.

<a id="names"></a>
## 4. Identifier strings

One identifier spelling has one stable canonical string address per process. The existing
process-owned string table and its byte lookup index serve input boundaries: parsing, unit
loading, `sys\fromLmx`, and restoration from another process. The translator's pointer is not a
pointer valid in a later process, so a loaded unit normalizes spellings once to the new process's
canonical addresses. After that, identifier comparisons use pointers; no numeric spelling codes
or string comparisons are inserted into normal resolved-name execution.

A bare/exact identifier of equal decoded spelling uses the same canonical name. User string
values are ordinary char Arrays and are not universally interned. The explicit `sys\priority`
string-to-name boundary resolves equal contents through the existing mechanism; it does not
require pointer identity from a caller's arbitrary string. `sys\name` uses existing canonical
name storage and service names to return ordinary string content; it creates no new name table.
Language operator and receiver words use these same canonical strings and ordinary word records.

<a id="tables"></a>
## 5. Tables and correspondences

### 5.1. Address to name

Each arena has rows `{address, name}`. Address is that of the named primitive or Lmx itself;
name is the canonical string pointer. It is not a separate occurrence-plus-port identity, owner
and ordinal key, or incremental code. A code-only uninitialized declaration is still named;
it does not need a nonexistent T cell to carry the name correspondence. Replacing a graph
fragment preserves the selected declared name through the ordinary construction/name mechanism,
without promising that the old record address or its name-table row stays the same. Copying a
named record creates its corresponding row with the same canonical string. Collection removes
rows for dead records.

Named field lookup walks the relevant physical fields and their actual names under the ordinary
DATA rules. A single occurrence is accessible by name. With multiple DATA declarations of that
name, a bare path is ambiguous and `S\[N]field` selects its zero-based occurrence in field order.
DATA repetition neither overwrites the earlier declaration nor assigns into it. A CODE repeat
uses the selected same-level place and does not add a graph field. Namespace stream consumption
follows those same DATA occurrence rules; it does not rewrite physical source receivers to make
its logical names look like immediate physical children.

### 5.2. Service tables for concrete work

Namespace mappings and local places belong to the actual traversal/call. Construction, expression,
copy, and concrete traversal-correspondence tables live for the operation that needs them and are
destroyed on its exits. Concrete field maps and value-dependent admission facts owned by
`satisfies` remain scoped to the established operation or reception. Separately, the common kernel
maintains the required table of completed directed TYPE-pair checks. Stable full requirements
reuse their completed result under the applicable type/conversion context, including between
calls. An in-progress recursive pair is not a completed positive result. This type metadata is
not a permanent namespace, all-environments admission cache, or arena resolution registry.
The selected W/E map remains until the chosen call is executed; it is not recomputed with another
reading. An satisfies correspondence maps required model fields to physical candidate fields,
including reordered layouts, for the reads, addresses, and explicit writes it serves. The next
independent traversal rebuilds its correspondence from the graph. An ordinary explicit model
uses its full described tree; a fn requirement uses the positional rule of §3.4.

The correspondence neither copies the candidate, publishes locals, nor waives a new receiving
site's checks. No persistent arena store of all resolutions/admissions, automatic invalidation,
or separate map for a removed data call parameter is introduced. The arena's name, capacity,
call/native, and ownership tables retain their distinct required purposes. Physical slot writes
through `S[n]` store the actual slot representation; they do not preserve a frozen historical
field requirement merely because that slot once contained a different value.

`sys\check`, `sys\checkL3`, and `sys\translate` reuse the necessary common builder/checker parts.
Checking executes neither arbitrary user initializers nor `test`. Construction establishes known
candidate interface facts; reached interpreter calls invoke standard `satisfies`, including the
required receiving checks and its scoped correspondence. Prepared native calls do not automatically invoke
runtime `satisfies`; an explicitly written `satisfies` executes in either path. Actual-value
conversion/range checks remain in force. A separate post-clean-graph, pre-C build/test phase runs
checks reached through ordinary build/test receiver contracts, without a recursive DATA-test scan.
Neither phase introduces blanket rechecking after every primitive write or graph mutation.

<a id="interpreter"></a>
## 6. The interpreter

<a id="direct-access-cache"></a>
The interpreter walks the same source graph consumed by translation. Call-local own places and
transparent caller places have the distinct ownership of §3.4. Direct graph paths and dereferences
use actual addressed places. There is no shared direct-access cache, load-dirty coherence, flush,
or automatic publication/reload of suspended callers' locals.

### 6.1. Traversal and control

Reached CODE forms execute in written order under their resolved head contracts. Bare atoms do
not implicitly call methods. An applied ordinary Structure or reference to it uses the common
call path; an unresolved/inapplicable head fails when its contract requires resolution. A colon
form does not assign a known value place. Standalone anonymous CODE blocks execute in place in
the current activation under their ordinary block contract. Control-body selection preserves
written groups, source parents, and the enclosing activation; it does not recursively unwrap
all single-field groups or flatten nested scopes.

R0 has no DATA or user actuals and is never launched over itself as artificial DATA. Its runtime
scaffold and graph access remain implementation launch concerns. Its reached executable declarations
and resolved receivers use ordinary CODE roles; DATA arguments still use their receiving contracts.
An entry/source profile identifies what is launched and does not turn absent DATA into an implicit
self-call or automatic invocation of every declared Structure. The
[notes](implementation-notes.en.md#root-role-control) state this fixture boundary.

If/else, while, for, until, and the ordinary nearest/named control transfers retain their language
contracts. Inline loop conditions and bodies use the appropriate enclosing places. A while
condition `((c := read()) != EOF)` performs one read and one write each time the condition is
reached, including its final false result; it adds no named actual c. Continue/redo and post-loop
conditions retain their accepted order. Return holds its result before cleanup. Reached finally
registrations run once in reverse order on the scopes actually exited, including ordinary returns,
transfers, failures, and system exits under their respective contracts.

Catch retains handler selection by failure name and scope, skips its body on the initial direct
pass, distinguishes nested and neighboring scopes, and permits no competing same-named catch at
one level. Payload values use ordinary explicit reception with the handler code's actual DATA
relation. Other dependencies use the same binding/private rules. Continuation, repeated handler
call, throws, and cleanup semantics remain; removal of sub/fncall does not remove catch or turn
it into an unrestricted ordinary function. Tests and converters use common call/admission paths.

### 6.2. Roles by canonical pointers

The kernel may intern its recognized language words first and keep their canonical pointers as
constants, for example `lmx_word_if`. These are the same identifier strings used by every other
word; they are not opcodes or a special representation. The active contracts include call, the expression operand `::` for named signatures, import, copy, merge, declarations, modifiers, control, and sys operations. There is no public `fn` receiver or compatible alias.
There is no special data name, executable fn/sub family, fncall, or operand-registration word.
Ordinary user names allowed by general rules do not regain an obsolete built-in meaning.

User names resolve under §3.4's own/transparent/fallback order, including the visible private
receiver check. This retains the previous dynamic and lexical mechanism as the final source,
not as a replacement for the new paths. No raw C stack is searched as a dictionary of names.

### 6.3. Activation, addresses, and native crossings

An activation retains its namespace, selected values/descriptions or places, and ordinary
control state. Ready own values use ordinary value/reference copying; computed descriptions
remain deferred until demanded. Once a place is initialized, later reads reuse its current value;
they do not call that initializer again. A newly reached repeated declaration or a new dynamic
expression evaluation performs its own required computation. There is no eager pass over defaults,
automatic executable-graph copy, permanent source-result cache, or copied environment. Ordinary activation
values and selected bindings are not a materialized namespace/program graph. Local declarations are sequential; source-path access remains explicit
and does not execute a computed declaration. Passed declaration forms and their associated body
use the receiving root place as specified in §3.4, without a separate fresh item for every step.

For a native-to-native call, known own actual/autofill inputs may be ordinary T parameters and a
transparent caller place a hidden address of its cell. The fallback still gives an own place.
Existing adapters must preserve the selected place's owner, type, initialization state,
restrictions, address behavior, and immediate visibility of writes. A raw native local has no
four-byte tag before it; its type and state follow the call/place contract. The language type
stays T for native→native, native→walker, walker→native, and walker→walker.

The language call-site context survives service dispatch/bridge functions and raw-fragment
forwarding. Dynamic targets use the existing allowed local-context access, without static
transitive accumulation of all descendants' needs. Different hidden place modes may require
different prepared variants or a correct existing adapter; an explicit signature alone does
not prove that a particular native entry is suitable. Missing native code follows the ordinary
supported walker/native choice and does not trigger hidden compilation.

Addresses follow ordinary lifetime: a transparent binding or raw fragment does not retain an
ended caller. At yield, the chosen binding remains part of the saved activation and is not
rebound to a same-named local of a later caller of next. Ordinary continuation/Message rules
still apply. Do not infer a C `restrict` guarantee merely from a hidden pointer or private.

### 6.4. Import, copy, merge, and attachment

| Receiver | Argument role in every placement | Admitted source count | Output |
|---|---|---|---|
| import | Ordinary CODE arguments | One or more | Selected root constant declarations by reference |
| copy | Ordinary CODE arguments | Exactly one | Fields of the copied source |
| merge | Ordinary CODE arguments | Two or more | Fields of the composed sources |

The operation uses only its explicit admitted sources. The receiving Structure is never an
implicit source or model. All three always use the same ordinary CODE argument algorithm,
including when the receiver is written inside DATA. Obtain needed sources left to right, once.
Bare Structure references and anonymous Structures supplied as values are not themselves calls.
An anonymous container can contain calls and initializers, whose execution follows the ordinary
contracts of its contents and consumer. Grouping is neither quotation of every field nor a mandate
to eagerly run every initializer. An explicit `Producer()` source does execute
when that receiver is consumed, even within `Struct: merge(A Producer())`. The common
place-declaration-argument rule still preserves a declaration form as DATA material according to
its resolved head's contract; it is not a separate DATA-argument mode for these three receivers.
P0 only preserves the written forms, and receiver consumption never rewrites those source records.
General source admission, including Structure/reference-Array interchangeability where applicable,
is retained.

Import selects const declarations considered roots by the source's ordinary DATA rules.
User Structure declarations are constant without an explicit const; root constant signature names
created by the `::` declaration are eligible. Ordinary mutable places are excluded. Nested fields do not separately
rise to the receiving root, and modifier forms do not impose an extra immediate-parent filter.
The declared name is imported, not the receiver name that declares it. Contents, identity, and
original parent are preserved. Duplicate imported names use ordinary redeclaration, not merge
slot overlay or a last-source-wins policy.

A standalone import supplies the current namespace. A nested `f(import(A B))` supplies only f's
surrounding argument consumer; it does not also import into the caller namespace. Copy and merge
supply their fields to the same ordinary consumer but retain mutable fields admitted by their
own contracts. They do not inherit import's const filter.

`Struct: merge(A B)` is an ordinary DATA declaration of Struct containing the written merge.
The namespace reads the merge output there; no special “declaration through merge” form exists.
Several separate merge/copy operations inside one DATA body are processed in written order with
separate maps. Inside one merge, the first source fixes model-slot order, later matching fields
replace admitted model-slot values, and new fields append. Across independent streams, ordinary
DATA occurrences apply. A prior field of Struct is not an additional model slot of that merge.

Outputs are streams, not automatically one outer container. `f(copy(A))` and `f(merge(A B))`
supply fields; `f((copy(A)))` and `f((merge(A B)))` use an explicit group to construct one
structural actual. An existing reference variable can receive `p := (copy(A))`; one copied return
is `return: (copy(A))`; a reference to a composition is `@: result (merge(A B))`.
Ungrouped `p := copy(A)` remains a stream judged by the ordinary assignment consumer, not an
implicit container or unconditional syntax error. `copy(Empty)` gives no fields, while
`(copy(Empty))` gives one empty Structure. Written empty/singleton groups stay in the source graph.

Grouping does not disable ordinary W/E at the outer CODE consumer. To pass the whole grouped
Structure without E, explicitly assign it to a real formal: `f(arg0 := (copy(A)))`. Source arity
is checked after common CODE selection in every placement, including inside DATA. A single written `merge(S)` may obtain two or more
sources through E and cannot be rejected merely by written count; if only one source is admitted,
copy is the appropriate operation and merge refuses. W and E retain equal priority for all three
receivers, including import. Missing sources are not supplied by hidden binding. Output field
count is separate from input count, and the chosen map is never expanded again.

One source-to-copy map covers all sources of one copy/merge operation. Allocate the necessary
result records through the ordinary arena stream, preserving typed values/absence, word strings,
names, shared targets, and cycles. Map matching later fields to the retained model slots before
copying references to those fields, so field order does not break internal identity. Recursive
composition follows the existing field-admission/model-slot rules; it is not a special merge of
functions. Repeated supply is processed in source order rather than suppressed because a source
address was seen before.

Ordinary references and parent links are rewritten through that same map. Necessary lexical
ancestors are copied under the established reachable-closure contract, including their links
and cycles rather than trimming them to guessed free names. This is not copying the whole arena.
Reusable native implementation references and properly qualified independent immutable branches
retain their existing exceptions. Copying preserves applicable native links without compiling or
registering an implementation. The result must not depend on mutable addresses in an arena that
can be released. Attaching same-process chunks moves ownership, not cell addresses or names;
restoring from another process goes through the normal interning/link-restoration boundary.

An explicit grouping wrapper is a distinct Lmx container with its own cells. Those cells are
distinct from the copied lexical owner's cells even when they refer to the same copied records.
Grouping does not independently deep-copy the emitted graph or redirect it back to source data.
Replacing a wrapper slot changes that slot; following a shared reference into a nested Structure
can still reach the same nested slot through either route. Stream reception does not rebind
copied methods or redefine node as the receiver. Import performs no graph copy and preserves
original declaration/owner identity; copy and merge deeply copy the used graph and select the
corresponding copied owners through their operation map. Every source import/copy/merge receiver remains
in place; direct source-path reads and serialization expose that written record, not its result.

For group assignment, `(a b) := (copy(Pair))` consumes result fields positionally: the right side is one
unnamed Structure in parentheses, the form `() := ()`. Only that outer RHS group is opened once; the LHS group stays whole and its fields are read as targets by assignment itself. Nested RHS groups remain nested. Several values without the group are an error, the stream is
written inside the group, the bare stream `(a b) := copy(Pair)` is an error, and a Structure
returned from a function is not opened (author's decision, 2026-11-21). Obtain all RHS
values before the first target write; detect count mismatch before that write. RHS names do not
reorder targets, and completed RHS effects are not transactionally rolled back. For initial
`a=1, b=2, c=3, d=4`, `(c b d a) := (a b c d)` gives `c=1, b=2, d=3, a=4`.

### 6.5. Explicit compilation and turn boundaries

Graph writes take effect on their addressed data and do not invalidate native. The former
change-tracking-only checks, reverse links, `code_uses`, reset generation, and invalidation
transfers have no role. Keep common references, typed storage, and GC for independent purposes;
do not replace invalidation with dirty journals, version tracking, endturn hashing, or hidden
compilation. An arbitrarily broken graph has no automatic repair guarantee.

`sys\compile(S)` explicitly checks/builds the clean graph, performs its required build/test phase
before C generation, translates through L1 and C, compiles and links, and registers successful
variants in the existing call tables. The check phase can execute checkers and their candidate
calls through ordinary receiving contracts, without launching S's application entry or scanning
all nested DATA for tests. Failure installs no new entry. `sys\translate(S)` returns L1 text and
diagnostics, not LMX or installed native; it and `sys\check`/`sys\checkL3` do not execute application
code or `test`. Reuse common working builder components for the requested operation; no second
infrastructure is required to maintain hypothetical future execution.

<a id="endturn-receiver"></a>
`sys\endturn()` exits through registered finally cleanups in reverse order to the ordinary turn
boundary. Catch does not intercept this system exit; it neither returns to its call site nor
retains that stack continuation. The receiver itself changes neither running nor success and
does not complete a Message. A later scheduled turn starts at its ordinary entry.

Before the boundary, executable-edit timing may differ between interpreter and native. Successful
explicit compilation followed by endturn guarantees the prepared update at the next entry.
Endturn alone detects no changes, checks no graph, compiles nothing, and publishes no locals.
Old native frames and their cleanups finish before their machine code is released.

<a id="flush-receiver-contract"></a>
### 6.6. No local-frame publication

The flush receiver, load-dirty, shared direct-access coherence cache, and return-time copy-back
are absent. A graph assignment replaces the selected fragment, visible through subsequent access
to that structural place; it does not automatically retarget every reference to the previous
fragment. Transparent execution-place writes remain immediately visible through bindings to
that place. Message/mail publication and releasing a completed construction result retain their
separate contracts; they are not frame write-back.

<a id="native"></a>
## 7. Native and the C boundary

A native descriptor is an ordinary Structure containing prepared signature variants,
binary-module/entry identifiers, and L1/C source paths. Existing call tables store its binding
to the selected executable occurrence; Lmx has no native header field. Explicit compilation
registers that binding without injecting a `native` field into the source Structure or catch.
An explicitly written ordinary user field named native retains only its ordinary field meaning;
`sys\native(S)` queries the service table. A named signature requirement creates no implementation
entry. Machine addresses are bindings of the current process, not portable saved addresses.

A known native-to-native call may be emitted directly in C with actual values and necessary
hidden place/context arguments. It need not package a graph, allocate universal Value wrappers,
look up call tables, or use a universal trampoline. Dynamic selection uses the existing tables
and the actual selected contract, including hidden place modes. Direct C variants and bridges
must retain the common semantics of §6.3. The fn public-label-to-position map can be resolved
before emission without searching names at every native call or reordering actual effects.

Typed result locals already used by `emit_call_result_value` and `emit_dyn_tail_value` remain
ordinary result places. Reuse that result when taking its address rather than calling again or
allocating a second cell just for @. If an operand consumer needs a graph-typed record reference,
the normal storage bridge must supply one; the raw C temporary itself has no preceding type tag.
A structural/reference result retains its ordinary logical type and lifetime.

If native A calls native B directly, recompiling B alone does not patch A. Explicit compilation of
a common unit containing the necessary callers and targets updates that chain. There is no
reverse-dependency scanner for graph edits. ABI-compatible ready binaries can bind to a restored
graph without retranslating it.

The machine C door keeps its existing explicit contract: foreign functions/macros receive L2
arguments evaluated once in written order, not substituted source expressions. A macro expanding
to sizeof does not suppress an argument effect already required by the foreign-call contract.
Literal `c.sizeof` retains the C operator role and its C99 evaluation rules, including applicable
variably modified types. Target `os` selection occurs before semantic processing of unselected
branches; those branches contribute no name resolution, dependencies, checks, or generated code.
It does not require equal branch interfaces or a second satisfies mechanism.

An eligible machine L2 function may expose its direct C-compatible entry with explicit arguments,
without an Lmx root, Message, prepared graph, hidden shared unit, or singleton. This uses the same
L2 parser/resolver/generator and does not strip arbitrary Structure calls of their semantics.
Maintained sources remain L2/L3 with generated L1/C; there is no permanent alternate implementation.
[L2 machine and ABI contracts](L2_spec_en.md#lowlevel-abi).

<a id="codec"></a>
## 8. Graph serialization and restoration

`sys\toLmx(S)` saves S's current graph: field order, null slots, shared links, cycles, names,
parent relationships, typed contents/absence, written receiver records, and written groups.
A terminal primitive record serializes as its ordinary declaration. Computed receiver results
are not silently substituted for the source record, and earlier source is not reconstructed after
explicit graph mutations. A path to a receiver is not a request to execute it before saving.

Saving a Thread also includes its arena's legitimate tables, including call/native descriptors.
The arena owns them, not R0's fields. They are not automatically added to every arbitrary saved S.
Namespace/traversal maps, native stack addresses, and cached expression results are not portable
source graph values. `sys\fromLmx` uses the common parser/builder, canonical strings, and link
restoration. Module/entry identifiers and source paths persist rather than old-process machine
addresses. On the same platform, ready ABI-compatible binaries can be rebound without translation.
Capacity may restore as length. A diagnostic dump that loses null slots or unnamed cycles is not
accepted as this codec merely because its text is readable.

<a id="audit"></a>
## 9. Legacy representation audit

This table records what an implementation must reconcile if those older carriers still exist.
It does not assert that the standalone packet inspected a current checkout. Existing storage
or metadata with another required purpose must be retained for that purpose.

| Legacy carrier or mechanism | Required replacement or retained boundary |
|---|---|
| Numeric identifier codes, `lmx_ids`, `l2_ids`, `LMX_ID_*` as semantic identity | Canonical string pointers and input-boundary interning (§4) |
| `LmxSourceName` occurrence/port codes and static place tables | Actual record-address names and operation-local namespace maps (§5) |
| `LmxActivationBinding` based on numeric name codes | Existing activation/place transport preserving own versus caller place (§3.4, §6.3) |
| `LmxOp`, `LMX_WALK_OP_*`, generated numeric operation/selectors as a second program | Walk the common source Lmx graph; temporary expression analysis is scoped (§3.3) |
| Type-by-address ranges, typed pool classification, per-type chunks | Type from record code; intervals only for ownership; one arena record stream (§2) |
| Embedded VoidArray, inline capacity, header native | Flat header, common dynamic storage, existing capacity and call tables (§3.1) |
| Persistent concrete field/namespace admission and resolution maps | Concrete correspondence remains reception/traversal-local; completed stable directed TYPE pairs use the required common table (§5.2) |
| `LmxCodeLink`, reset-only `lmx_code_*`, `reset_gen`, `code_uses`, invalidation | Explicit compilation and endturn (§6.5); keep unrelated GC references |
| Loaded/dirty frame rows, flush, automatic copy-back | Own places or immediate transparent caller aliases, with no graph publication (§6.3–6.6) |
| Executable fn/sub object constructors, fncall, separate data parameter | Ordinary selected Structure, actual parent DATA, named positional signature requirement (§3.4) |
| Operand registration, old single args-array operand ABI, universal reference result | Structural method header, left/right, explicit mode/priority, ordinary result (§3.3.1) |
| One-source merge and automatic outer result container | Copy for one admitted source; stream outputs and explicit grouping (§6.4) |
| Expansion of DATA source receivers into stored fields | Namespace-only consumption, with every written receiver preserved (§1a, §6.4) |
| P0 tree retained as a second translator input or execution reserve | Common clean graph for both consumers; construction work released (§1a) |

What remains is the flat Lmx graph, typed records, ordinary local state, canonical names, existing
call/capacity tables, arena ownership/chunks, Message/Thread/mail, common admission, graph copying
through one map, collection, and the existing native ABI/bridge mechanisms needed for those tasks.

<a id="example"></a>
## 10. Worked places and stream examples

Let D contain `int: x 1`, and let selected body C have actual parent D. C executes `x := 2` and
then `D\x := 9`. The declared input x gives the call an own place:

| Point | Call-local x | Source D\x |
|---|---:|---:|
| After ready input reception | 1 | 1 |
| After `x := 2` | 2 | 1 |
| After `D\x := 9` | 2 | 9 |
| After return | Activation ended | 9 |

`@x` addresses the local column; `(@D\x)` the source column. Return does not copy 2 into D.
The explicit D\x assignment replaces that field's graph fragment; the table records the value found by
each subsequent lookup, not a promise that a raw pointer to the previous fragment now denotes the replacement.
The same observed starting number can arise through different binding modes:

| Source of callee x, initially 5 | After callee `x := 9` | Addressed place |
|---|---|---|
| Declared empty input autofilled from caller | Own x becomes 9; caller stays 5 | Own activation cell |
| External name transparently denoting caller | Caller x becomes 9 immediately | Caller cell |
| Retained fallback copy | Copy becomes 9; source stays 5 | Own activation cell |

All three have language type T. Explicit paths do not need a special “foreign caller” access
check, but retain type/const/immutable/lifetime requirements. Physical `D[n] := p` stores the
slot's actual reference representation and does not preserve a former x requirement as a frozen
slot fact.

For receiving inputs iteration/body, the accepted form
`iterate(int: item numbers\next(); (item *= 2))` transfers two Structures. At transfer, next
has not run. Each reached iteration() executes the saved declaration, and body() changes that
same receiving-root item. If next returns 10, 20, then Stop, there are three next calls, two body
executions, and no extra next call merely from reading item or entering body. Catch/break uses
its ordinary scope; the source declaration and both original parents remain intact.

For DATA `Struct: merge(A B)`, the source Struct retains that merge record. A namespace read
receives only A/B's merged fields; an existing Struct field is not an implicit model slot. A second
`merge(C D)` is another operation with another map. `(copy(A))` explicitly collects one copied
Structure; copy(A) alone supplies its fields. The different wrapper and source counts must remain
visible to the common parser, selector, serializer, and admission rules.

<a id="transition"></a>
## 11. Acceptance and implementation integration

Acceptance of this documentation means the common model and the following distinguishing cases
are unambiguous. It does not require or claim a repository rebuild. When implementing it, use the
one existing L2/L3 → L1 → C pipeline, carry changes through its shared mechanisms, and report
only checks actually run. Historical receipts do not prove this edition's behavior.

| Area | Evidence an implementation must eventually provide |
|---|---|
| Records and storage | Initialized value layout and alignment; code-only uninit with zero payload; explicit graph-fragment replacement; no stable raw payload promise across replacement; no type-by-range lookup; dense numeric Array and native-local distinctions |
| Source graph | Full source including primitive leaves and every receiver/group; namespace processing preserves it; ordinary explicit graph assignment can replace receiver fragments; native (machine-code) updates use the existing compile/endturn boundary |
| Parser closure | Empty/whitespace-only physical lines close to local root; comments/literals/Mix/pairs/EOF/source coordinates retain their contracts |
| Calls and signatures | Actual parent, no-data R0, no executable fn/sub/fncall; `Name :: DATA` has one left declaration identifier and one intact right template; positional type comparison remains distinct from full structural models |
| Selection | All applicable W/E pairs counted; no hidden rescue of required inputs; selected map reused; named-position counter and once-only actual effects |
| Binding/private | Own autofill, caller alias, fallback copy, source/receiver private, A→B→C transit, shadowing, immediate initialization-state writes |
| Declaration arguments | DATA form retained without execution; positional supply regardless of internal-name coincidence; outer named supply; ordinary admission; repeated root execution; body using the established item and its live source-context total |
| Import/copy/merge | Ordinary CODE arguments everywhere, admitted arities, constant-root import, stream/group distinction, no implicit destination source, independent maps, shared targets/cycles/lexical links |
| Operands | Structural discovery, mandatory constant properties, left/right transport, normal results, raw-context eval, no hidden call on dereference |
| Expression effects | Demand dependencies, low-priority assignment, C-relative precedence and asymmetric power, short-circuit skipping, one effect per occurrence/evaluation |
| Native and lifetime | All four native/walker crossings preserve selected places and types; correct typed-result storage; no raw-stack name search or lifetime extension |
| Codec and explicit compilation | Round-trip source forms and graph identity; process-local rebinding; no automatic native invalidation; compile/endturn and cleanup boundary |

Implementation acceptance should exercise the changed common mechanisms with the relevant
native, interpreted, and forced paths, plus source-graph observations rather than return values
alone. Rebuild affected components and dependencies for code changes; broaden bootstrap/fixedpoint
or regression coverage when shared ABI, export, graph/image, or build-chain changes justify it.
A clean traversal test starts a second traversal with no previous namespace tables or P0 tree,
observes the changed graph's expected result, restores it into a second simultaneously live arena,
and observes that same intended state there. Native update tests respect explicit compilation and
the endturn boundary instead of expecting automatic refresh after a graph write.

The observation tables of the primary documents provide the detailed distinguishing-case matrices. The inherited inline-local
case is derived from the caller-source rules, and entry fixtures state their selected source
role in the [implementation notes](implementation-notes.en.md#open-design). Neither requires a
new language rule. P01 is now resolved by the author's zero-payload and graph-replacement rule;
implementation checks must use that rule rather than the superseded reserved-cell oracle.
Report an author question only for a genuine
contradiction between applicable current requirements, with the conflicting clauses and a
minimal distinguishing case.

<!-- receiver-integration-2026-11-22 -->
<a id="receiver-kernel-integration"></a>
## General receiver integration, 23 November 2026

This section integrates
the rename to satisfies and the [general receiver sources](patterns/LMX_Fn_Receivers/LMX_Receivers.lmx).
High-level algorithms remain LMX. The provider interfaces are a narrow entry to
shared mechanisms, not one native primitive per higher-order operation.

The [common function inventory](CORE_FUNCTIONS.md) is the complete integration
list, including helpers extracted from usage comparisons. Preserve their public
lowerCamelCase names. Include their ordinary LMX bodies in the current kernel;
do not make a client load an optional companion library. Control-language
implementation examples are comparison material only. The accompanying
[merge packet](../fable_merge/README.md) carries the exact uploaded preimages,
file hashes and source/generated patches for merging into `docs/spec`.

The rename concerns the common mechanism of admitting a candidate by its
requirements. The direction candidate → requirement, `Consumer`, the composition
of the checked tree, the positional branch for checking signatures, the
construction of the field correspondence and the lifetime of that correspondence
are kept. Update the name resolution of the receiver, its export, declarations
and calls in kernel sources, diagnostics, generated fixtures, specifications,
anchors and links; where the actual internal kernel symbols keep the old stem of
the name, bring them to the new name or explicitly limit the old stem to the
internal ABI of the migration. The ordinary English word `implements` and the
Java/TypeScript keyword are not the name of an LMX receiver and are not renamed.
Documentation uses `satisfies(aVar, bVar, Consumer)` and keeps the earlier
possibility of a call described by the contract without `Consumer`. The rename
adds no arbitrary new return type, no accidental boolean result and no runtime
trial call of the candidate, and does not change the existing behavior of
refusal. No second checking engine, no new global table of correspondences and
no extra checks at every prepared native access are added. The previous spelling
is not declared a second permanent public name; if the real migration of sources
needs temporary compatibility, it is formalized explicitly as a transitional
entry to the same receiver and afterwards the absence of old calls is verified;
this is not a reason to keep two semantics.

Use the common signature extractor and descriptor builder for both `Name :: DATA`
and the type-token constructor `signatureTypes`. Skip formal variable labels for compatibility; retain full
nested type requirements, semantic order and exact result/void. Preserve the
current named-signature/call relationship. All other operations must accept either
description, including storage, argument transport, admission and adapters.

The source provider contracts cover signature extraction, type normalization,
DATA construction, ordinary callable construction, call outcome capture,
rethrow of an allowed exit, canonical field-name reading and writing. Locate
and reuse the existing algorithms before adding a public entry. Do not invent a
second name table, persistent arena-wide cache of concrete field/namespace admissions, or hidden
target execution while extracting metadata. The required completed TYPE-pair table retains its
separate metadata contract (§5.2).

Construct real owner/DATA/CODE links, required/private generated inputs and
private captured state. The initial target retains its original owner and
dynamic binding contract. Captured primitive records survive the creating
activation; captured references preserve identity. The vector of records is
already a Structure/Array<@>, with no compulsory wrapper or second vector.

The absence of a documented public entry does not prove that the repository
lacks an internal algorithm: find the existing working mechanisms and give them
a minimal interface. `map`, `curry`, `memoize`, Maybe and the other supplied
algorithms enter the kernel exactly as the shown general LMX implementations;
the narrow integration entries must not hide these algorithms behind an opaque
stub or replace the dynamic contract by static specialization. A generated
callable has a real owner → DATA → CODE chain and correct private references to
its state, uses ordinary admission, conversions and call rules, and never takes
a native entry from an incompatible prototype. Native compilation is explicit; a
ready typed function may become a real native method without a compulsory
universal array at every following direct call.

The generated inputs of an adapter follow the target contract of [Behavior of
adapters and callable factories](LMX_semantics.en.md#adapter-behavior): where
the original callable exists, its own defaults, `required`/`private` and
autofill are kept, and `uncurry` takes the exact description of every stage. The
present generation of `required`/`private` inputs and of intermediate results
`Ti → @` is a limit of the present adapters, not a rule of the language; until
the observations A01–A20 and B01–B11 are executed on the kernel, the
preservation of every aspect of the interface is not declared.

Generic record APIs expose FxCallFailure with the target's original declared
failure and payload. Exact-signature generated wrappers may restore that exit
only where their generated throws contract includes it. Do not catch internal
provider failures as user data, fabricate a wildcard throws rule or silently
erase a procedure into an @-returning function.

Optimize repeated construction only after preserving observation: share
compatible immutable shapes, avoid reparsing identical text where a standard
graph constructor suffices, preserve copy maps and actual parents, and keep
per-instance state independent. Compilation stays explicit. The interpreter,
native path and both transitions must pass the same acceptance cases.

The [source acceptance matrix](patterns/LMX_Fn_Receivers/tests/ACCEPTANCE.md)
includes mixed payload types, arbitrary finite arity, void, nullary functions,
full/empty partial prefixes, callable final results, field-name edge cases and
both directions of fn equivalence. Static publication checks are separate from
running those cases on the kernel.

<a id="unified-20261122"></a>
## Common implementation points

Implement postfix type construction, declaration-head resolution, normalization, type-code allocation, checked type pairs, and array/ref admission in the existing common kernel paths. A head can be a retained composed source form; only a literal word head is identified directly by its canonical spelling pointer. Resolve NAME/TYPE/VALUE roles before premature lookup or index attachment. Metadata must survive attach and must not reference rolled-back or freed temporary descriptions. No local per-receiver type registry is acceptable. Dense read/admit/write, safe extent calculation, and access to existing selected call phases are the narrow integration boundaries of the supplied LMX algorithms. Pattern backtracking, sequence loops, adapter projection, and memoization are LMX bodies, not opaque kernel substitutes. See [current contracts](CORE_SEQUENCES_REGEX.en.md) and [the bridge inventory](patterns/LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md).
