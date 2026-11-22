# LMX core architecture

> **Repository note.** This file is the edition of 2026-11-21, transferred verbatim from the author's
> documentation packet (it lay in `docs/new_parts/newdocs/` and was removed there as a duplicate on the author's
> order of 2026-11-21); only link targets were adapted to repository paths.
> The implementation state of this repository is recorded in [READ.ME](READ.ME), the
> [plan](next_core_tasks_v3.md) and the [current pipeline](steps/current.md), not in this map.

This is the architecture map for the standalone English documentation packet. The
[L2 specification](docs/L2_spec_en.md), [L3 semantics](docs/LMX_semantics.en.md),
[grammar](docs/LMX_grammar.en.md), and [kernel implementation contract](docs/kernel-implementation.en.md)
define the detailed contracts. The accepted requirements and supplements are
integrated into these documents.

This map describes the required architecture. Repository checkpoints, binary hashes,
and old PASS/OPEN receipts are not evidence of the implementation state of this
packet. Acceptance of the rewritten documentation and acceptance of a runtime
implementation are recorded separately in [REVIEW_NOTES.md](docs/REVIEW_NOTES.md).

## 1. Engineering boundary

L3 is the graph-level language. L2 adds machine operations and C99 interoperability.
An L3 graph can be interpreted or translated through the L2 implementation path.
A machine-only L2 operation does not become interpretable L3 merely because its
native address is available.

The hosted implementation materializes LMX machinery through the selected L1/C99
substrate. The source graph, namespace rules, and LMX contracts determine the
language. Generated L1/C is an implementation artifact; it is not a second
source implementation or the semantic definition of L3.

The program consists of the complete Lmx graph and a binary containing its
compiled native methods. There is no additional persistent program part holding
a second DATA image, callable graph, or expanded source. R0's compiled form is
an ordinary C method with a local pointer to the R0 graph. Interpreter execution
also uses this binary R0; it is not a separate graph-only launch without a binary
entry. Ordinary activation, arena, scheduling, name, and call-table state remain
runtime mechanisms rather than another representation of the program.

One parser builds the complete written receiver–arguments structure. Interpretation
and translation then apply the consumer's role and contract. A bare reference, a
call Frame, a declaration receiver, and an operator position are distinguished by
that common model. There is no parser branch for each receiver name and no
independent expression parser.

The walker recognizes a written head through its canonical name and the existing
address-to-name information. After resolution, accesses use graph addresses and
admitted correspondences. The name table is not a permanent map of runtime
variable bindings. Prepared native dispatch does not repeat source-name lookup
merely to make a known direct call.

## 2. Physical graph and identity

### 2.1 Source graph and namespace

**Every receiver remains in the source graph as written. All semantic computation
and transformation takes place in namespace. Terminal primitive declarations are
also in the graph, represented directly as `{type value}`.**

This is a complete literal source graph. Terminal primitive representation is
part of that completeness, with the Structure cell pointing at the represented
leaf. `for`, `if`, `merge`, `copy`, `import`, and every other receiver remain
written structures. Ordinary explicit graph assignment can replace them; the
existing compile/endturn restart mechanism handles executable changes where
recompilation is needed.

P0 preserves Frames, grouping, argument order, and lexical nesting. Binding,
expression evaluation, argument expansion, import, copying, and composition do
not replace source receiver records with their computed results. A computed RHS
remains a written form. Serialization reconstructs a terminal primitive declaration
from its value record and name; it preserves other written receiver records.

A runtime operation can allocate the values and graph nodes required for its
result. This does not replace its source record. An explicit permitted graph
assignment replaces the graph fragment at its selected structural place; an
assignment to an activation's own local does not publish that local into the
source graph. The semantics states this distinction in [graph assignment](docs/LMX_semantics.en.md#graph-fragment-assignment).

A Structure is an ordered collection of fields holding references to values.
Lexical nesting forms a forest, while stored references may add sharing and cycles.
Placing a reference in another container does not reparent its target. Names
belong to the existing address-to-name representation; they are not extra
fields inserted into every value.

### 2.2 Value records and the arena

An arena contains a stream of typed records. For an initialized value, its type
code immediately precedes its payload; the code occupies four bytes in the
documented format. `uninit:T` consists of the code alone: `sizeof(value) = 0`,
without a reserved T cell or inner T record. Physical kind is read from the
record. Address-range information identifies ownership and does not infer type.

[P01 is resolved by the author](docs/implementation-notes.en.md#uninit-layout-conflict).
Assigning 5 to an explicit graph field holding `{uninit:int}` replaces that
fragment with `{int 5}`. This is not in-place retagging of reserved payload and
does not preserve a raw value-cell address across the replacement. Frame-local
initialization still changes only the selected execution place.

Chunks can be added without moving value records. The arena's mark/revert and
ownership-attachment operations retain their [L2 contracts](docs/L2_spec_en.md#value-record).
One Message owns one logical arena, which may consist of several chunks. An
ordinary reference does not acquire a longer lifetime merely because another
namespace can see it.

A model is checked through `implements`. A user model does not create a new
per-model C layout, physical kind code, or hidden runtime tag. Primitive cells,
reference cells, descriptors, and typed backing each retain their own access
contract.

### 2.3 Structures and variable-length Arrays

The common `Lmx` descriptor contains `parent`, `length`, and `storage`.
In the clean graph, `parent` and `length` are logically determined from the
written source relationships; the remaining contents are represented through
the Structure's array of pointers. This explains their origin, not a rule that
header fields have no storage or must be recomputed from source text on every access.
Native descriptors and capacity belong to arena tables, not additional header
fields. Structure and `Array<@>` are interchangeable under their common
field/index contract. A numeric `Array<T>` holds actual T elements.

Arrays and service arrays use the common variable-length allocation and capacity
mechanism. The obsolete fixed-Array/separate-growable-List distinction does not
define a second active container model. Descriptor addresses stay stable while
backing storage may move.

L2 indexing is the machine profile's raw offset operation. L3 combines adjacent
dimensions into one linear index and performs the common bounds check. An L3
Array-element reference uses the descriptor and index under its existing
contract, rather than retaining a stale backing-storage address. An L2 pointer
remains a raw address under its existing lifetime and memory contract.

`a[i][j]` indexes a rectangular Array. `a[i]\[j]` follows a reference to another
Array. `S\[N]field` selects the Nth occurrence of a declared name in DATA; it is
a different operation from either Array-index form.

`sys\descriptor` returns the actual header-field addresses. Writing a length
field does not allocate backing. `sys\resize`, `sys\reserve`, and `sys\capacity`
perform their documented storage operations. `parent`, `length`, and
`sys\storage` read their corresponding values; `sys\native` queries the call
tables. No-argument forms use the current data role where that role exists.

## 3. Callable graph representation and activation

### 3.1 Structural call and lexical context

A callable is an ordinary Structure `C` selected for execution as CODE. Its
DATA is its actual `parent(C)`. The call forms are:

| Form | Executed Structure | Explicit actuals |
| --- | --- | --- |
| `call(C)` | C | None |
| `call(A C)` | C | The supplied actual-argument Structure A |
| `C()` | C | Empty written tail |
| `C(args)` | C | Written actuals admitted by the common algorithm |

The parameters of `call` are `args` and `code`. Its one-argument form requires
`code`; its two-argument form requires both. `call` executes the selected
Structure itself and does not search for a child named `code`.

A call does not substitute a separate DATA object. To obtain another combination
of data and code, construct the required structural relationship first under the
normal declaration/copy/composition rules. `NewContainer: ExistingCode` merely
stores a reference and leaves the referent's `parent` unchanged.

`node` is the existing lexical operation for the selected method occurrence.
It is fixed during that activation; entering a nested control body does not
rebind it to that body's immediate parent. Neither a dispatcher nor a stream
consumer substitutes its service context for the program's lexical context.

The special builtin name `data`, a separate DATA argument of `call`, `fncall`,
and executable `sub`/`fn` definitions are withdrawn. `data` remains the name of
a semantic role and may be an ordinary user name.

### 3.2 R0 and return

R0 is a procedural entry without DATA and without user actual arguments.
It receives no artificial `D = C`, empty DATA Structure, or synthetic `data`
field. Host launch parameters and internal access to the graph remain runtime
details, not user signature inputs.

The selected entry's source records retain their ordinary roles. In R0's executed
CODE, reached executable declarations and resolved receivers use the common CODE
rules; a form supplied as DATA is read under that receiving contract. The absence
of DATA removes an input source, not this classification mechanism. A source-file
or host entry profile must state which entry it selects; it does not implicitly
call every declared Structure or turn R0 into its own DATA. See the
[derived review cases](docs/REVIEW_NOTES.md#open-questions).

A result is described by `return` in DATA. This declaration assigns no result
and creates no shared mutable result cell for recursive calls. In CODE,
`return` is the return receiver. Reaching the end of code does not synthesize
a return. A structural call can supply a value when its DATA describes the
result.

### 3.3 Namespace and places

Each invocation has a fresh namespace prepared from the relevant root
declarations of DATA and CODE. Arbitrary branches and graph references are not
walked as an entry-time initialization pass. Actuals suppress the defaults
they replace. Unused computed inputs do not execute.

The binder resolves a name to a logical place:

| Case | Meaning of the place | Effect of an allowed write |
| --- | --- | --- |
| Explicit actual, own initializer, autofill | Own activation place | Changes that place |
| Transparent caller binding | The caller's existing local place | Changes the caller's place immediately |
| Retained fallback, variant A | Own working value/description | Changes the fallback copy |

For an own declared place, the order is explicit actual, own ready value or
initializer description, permitted same-name caller autofill, then the normal
uninitialized state and requiredness checks.

For a used external name without an active own declaration, a visible lexical
`private` declaration first prevents dynamic replacement. Otherwise a permitted
caller-local place supplies the transparent binding; the retained former
binding remains the lower-priority fallback. That fallback keeps an own copy
rather than becoming a hidden alias.

`x` retains its LMX type T on every path. A hidden native `T*` used to transport
a caller place does not require `\x` in source code or add a pointer level to
the user variable. `x`, `x := value`, and `@x` act on the selected logical
place. A temporary plus copy-out is not an implementation of the transparent
place contract.

Reachability through A → B → C remains available even if B does not consume
the name. If B owns a copy, C can receive B's place; if B already denotes A's
place, forwarding preserves that selected place. A new caller at `yield`
resumption does not rebind the suspended invocation's dependencies.

### 3.4 Two-way private and visibility

`private` filters both sides of every implicit dynamic-binding path. A private
caller place is not offered implicitly by value or by place. A really visible
private lexical declaration in the callee is not dynamically overridden.

The ordinary `private` receiver remains in the clean graph and supplies this
fact directly. Generated methods implement the binding rule; there is no marked
copy of the program in the binary containing privacy or initialization flags.

Explicit passing, explicitly filling a private receiving place, nested lexical
visibility, explicit paths, and `node` remain available under the normal write
restrictions. `private` is a filter on a selected place, not a permanent ban
on a spelling or a new protection check on every explicit path.

Variables and const declarations become visible sequentially. Named Structures
and callables retain their bidirectional visibility. A nested declaration
shadows the outer same-name declaration. A repeated declaration at the same
level uses the existing place: a reached RHS is still evaluated and admitted,
and an absent RHS does not clear the value.

An early use before a later own declaration can resolve through the ordinary
outer context. A pre-scan of future declarations must not suppress that use.
After the inner scope ends, the previous outer binding is visible again.

For Binding TZ §7.4's exact case, a new no-RHS inner local is `uninit:int`:
an inline scope creates a distinct declared place but no new callable caller.
The current activation's outer x = 5 is therefore not a new autofill source,
and the stated actual caller has no x. A reached required check refuses this
absence; merely declaring the place does not synthesize 0 or copy 5. The outer
place remains unchanged. See [the derivation](docs/REVIEW_NOTES.md#open-questions).

## 4. Declaration, assignment, call, and admission

### 4.1 Source forms

A bare atom reads a value or reference. It does not invoke a method. An explicit
Frame invokes its resolved head in CODE; the corresponding structural form
declares in DATA. A failed call is not reclassified as an assignment.

A place declaration is written by its receiver, for example `int: i 5`,
`@: ptr`, `@: ptr Model`, or `@: ptr Model candidate`. The outer-head form
`i: int: 5` does not declare the primitive place i. Ordinary structural
declarations do not become assignments to their names.

Known writable places use `:=`. A reference variable may be assigned a new
reference; an intrinsically constant structural declaration is not made into
a variable by this syntax. Repeated DATA declarations remain separate
occurrences, whereas a repeated CODE declaration uses the corresponding
activation place and retains its RHS/admission/write behavior.

### 4.2 Named fn signatures and structural templates

`fn: name data` has two DATA-role arguments. It creates a constant name for a
positional call-signature description, not an executable method. For example:

~~~lmx
fn: SumSignature (int: first; int: second; return: int)

SumContext:
    int: a
    int: b
    return: int
    sum:
        return: a + b

@: sumPtr SumSignature SumContext\sum
~~~

A subsequent `sumPtr(first := 2; second := 3)` maps the public signature names
to positions and then to the candidate's `a` and `b`. Named passing does not
rename the candidate or change RHS effect order.

The common `implements` has two distinct requirements:

| Requirement | Compared material |
| --- | --- |
| Ordinary structural template | The whole tree explicitly required by that template |
| Named fn signature | Number and ordered types of explicit inputs, plus presence/type of result |

Input names, initializers, method-body trees, and other non-input DATA do not
become fn-signature identity keys. Defaults, requiredness, throws, and hidden
binding retain the actual candidate's contracts. A template does not supply
missing fields by merely being checked.

### 4.3 Declaration-form actuals

A receiver declaration passed as an actual is read as DATA and retained as a
form, according to the [declaration-argument supplement](docs/tasks/LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md).
It is not eagerly reduced to its initializer value.

If its name matches an input declaration, it replaces the selected declaration
description in the receiving namespace. If its inner name is absent from DATA,
the whole form occupies the current positional argument. An outer named actual
selects its destination without renaming the declaration inside the supplied form.

Its root-level contributions participate through the ordinary namespace mechanism
without changing physical source parents or copying fields into the written graph.
Executing the supplied form creates or updates its declared local place. Repeated
execution repeats its initializer as specified, enabling the user `iterate`
example. The associated body uses that same place and does not execute the
iterator initializer a second time merely by being entered.

An ordinary structural Frame in CODE remains a call. The exception for a passed
declaration receiver is not a blanket rule turning calls into unevaluated DATA.

### 4.4 Selection and reception

Resolve the callee and its visible declarations, select using only explicit
actuals, then execute the selected variant and apply permitted implicit binding.

A candidate consists of the declaration, the argument reading, and the
actual-to-formal map. W reads the supplied form whole. E expands the immediate
fields of a single Structure argument once, when the normal conditions hold.
The readings are equal; neither has a hidden preference. Named assignment to
a formal, `f(arg := S)`, excludes E for that actual.

No admitted candidate is refusal; exactly one is selected; multiple candidates,
including two readings of one declaration, are ambiguity. Candidate checking
does not speculatively run defaults, user effects, or `test`. Already computed
actuals are not recomputed for E. The selected map is executed without a second
expansion.

The positional cursor follows the accepted rule: a named actual at its own
next position remains positional; an out-of-position named actual ends positional
counting, after which only named actuals are allowed.

The common `implements` supplies structural/signature admission and the required
behavioral checks. Construction checks a known candidate's interface without
running its body, initializers, or `test`. The interpreter invokes standard
`implements` at reached call admissions; prepared native calls use their prepared
contracts without an automatic runtime `implements` call. An explicitly written
`implements` runs in either path. Reused admission facts belong to `implements`
within the established operation/reception scope, not to a new persistent
namespace or resolution store.

The build/test phase after clean-graph construction and before C generation runs
the checks reached through the ordinary build/test receiver contracts. It does
not recursively discover every nested `test` in DATA. A reached actual admission
performs its required receiving checks; a false check stops later checks. This is
not a blanket rerun on every graph mutation or native primitive store. Actual-value
conversion/range checks retain their own contract.

## 5. Expressions and ordinary operand methods

An operand name resolves to an ordinary method. Its DATA supplies the structural
input contract and constant properties:

~~~lmx
operand_template:
    @: left
    []: @ right
    const: int: PASS_ARGS_AS_IS
    const: int: PRIORITY
~~~

Both constant properties are mandatory. `PASS_ARGS_AS_IS` is 0 or 1; `PRIORITY`
is an independently defined constant priority. Checking the template does not
fill missing properties. The generic template does not force `return: @`:
the method returns its ordinary declared result type.

In prepared mode 0, `left` receives a reference to the required left value and
`right` an Array of references to required right values in occurrence order.
A container remains one operand. An operand has one opening of its own: when its
`left` is an unnamed Structure and its single `right` argument is an unnamed
Structure too, the parentheses on the right are opened and `right` receives all
their content; a Structure returned from a function is not opened (author's
decisions, 2026-11-21 and 2026-11-22). A missing actual differs from an explicitly
empty Array and follows ordinary method admission.

In raw mode 1, the same expression analysis determines the boundaries, but the
method receives original occurrences without their effects. `sys\eval(fragment)`
uses the common evaluator in the occurrence's original context. Each explicit
eval starts a new evaluation; dereference alone does not execute a fragment.
The context association lasts under the ordinary activation lifetime rules.

The method's ordinary return value is the operator result. Expression storage
adapts that value to a typed record if a later consumer requires an address;
a bare machine temporary is not misrepresented as a tagged value record.

`@: ptr Struct` passes the ordinary reference. `@Struct` explicitly requests a
numeric address, as in `int: value 1 + @Struct`. Reference passing adds no
automatic `@`. `@x` still selects the addressed logical place by its ordinary
variable and memory contract.

Priorities and associativity follow the supported C-profile ordering; `=` is
equality and `:=` assignment. Exponentiation retains its documented asymmetric
Python-like binding. Assignment has low priority. A value dependency can demand
an assignment result before a higher-priority consumer without changing that
priority or shortening its RHS.

For example, `f(1 + v := 2 + 3)` writes 5 into the selected receiving place and
supplies one actual, 6. A standalone `f(v := 2 + 3; 6)` instead supplies a
named actual and a following actual under the positional-counter rule. A
specific occurrence executes once within one evaluation; a later evaluation or
an explicit second `sys\eval` can execute it again. Short-circuited operands
have no effects.

`sys\name(identifier)` returns the written identifier as an ordinary LMX
character Array without resolving its value. `sys\priority(name)` reads the
available operand's priority through the same resolution and properties used
for expression analysis. There is no separate `sys\operand` registration step.

## 6. Import, copy, merge, and graph relationships

All three receivers always consume ordinary CODE arguments, including when
their own written records occur in DATA. The translator and interpreter use the
same argument algorithm in every placement.

Bare source names are references; anonymous Structures are structural values.
Neither is a call. `Producer()` is an explicit call when the receiver consumes
that source, including in a DATA namespace pass. P0 still only preserves the
written record.

An anonymous Structure can itself contain explicit calls or computed declarations.
Their normal consumption contracts still apply. Grouping does not quote away
nested effects or demand early execution of every initializer; the receiver uses
the common CODE-argument algorithm.

| Receiver | Admitted sources | Result material |
| --- | --- | --- |
| `import` | One or more | References to eligible root const declarations |
| `copy` | Exactly one | A copied field stream |
| `merge` | Two or more | A composed field stream |

The destination DATA context is never an implicit source or model. The first
explicit source models only that merge invocation. Matching later fields
replace its compatible model slots; new fields append in source order.
The ordinary namespace consumer receives the completed stream. Separate merge
invocations do not overlay each other by that internal rule.

~~~lmx
Combined:
    merge(A B)
    merge(C D)
    copy(E)
~~~

The source graph retains these three receiver records. Their namespace effects
are independent operations in written order. Normal repeated DATA-declaration
rules govern coincident output names.

`import` selects only declarations that count as root const declarations in
DATA. An ordinary user Structure is constant without explicit `const`, so its
declaration qualifies. Variable fields do not qualify merely because they share
a source with a method. Source identities and parents remain unchanged.

Standalone import contributes to the current namespace. In a nested receiving
position, its stream belongs to that consumer; it does not also inject a second
copy of the imports into the caller's namespace.

A stream is not automatically wrapped in one Structure:

~~~lmx
f(copy(A))
f((copy(A)))
struct := (merge(A B))
~~~

The second form explicitly groups one structural result. Its caller still applies
ordinary W/E; grouping does not secretly force a unary signature. Arity concerns
admitted input sources, not output fields or a premature count of P0 nodes.

Copy/merge retain one source-to-copy map per operation. The complete used graph,
required lexical chains, aliases, and cycles follow that map; fields are not
copied independently. Original mutable source references are redirected to
copies. Reusable native implementation references and qualified
`independent: immutable` branches retain their existing terminal exceptions.

The consuming namespace does not redefine `node` or reparent source referents.
Packing the stream does not copy the completed fields a second time.
The explicit grouping container has its own cells, distinct from the copied
lexical owner's cells. Replacing its slot does not replace the owner's slot;
references in either container can still lead to one shared nested Structure.
Import retains original declaration and owner identity. Copy and merge deeply
copy the used graph and preserve corresponding copied owners through their map.
The graph-copy traversal does not bind or execute a copied callable merely
because it is copied, compile new code, or register a new native entry. Source
expressions still use the ordinary CODE-argument algorithm.

## 7. Message, Thread, mail, and ownership

`LmxMsg` is the closed record `{running, success, handoff_ready, graph}`.
Its graph is the language root, not a container for scheduler settings, mailboxes,
or children. `Thread` starts with the Message prefix and owns mail, scheduling,
and its single children collection. Equal prefix addresses do not turn an
ordinary Message into an executable Thread.

One executor runs a turn for a Message identity. Successful finalization publishes
prepared mail and child reservations; failure discards unpublished work without
rolling back earlier explicit graph changes. Stop requests, success, cleanup,
waiting, delivery, and entry counts remain distinct under the
[Thread/Message API](docs/LMX_semantics.en.md#thread-message-api).

`Thread.parent` and `Thread.children` define supervision. They are not
`Lmx.parent` and do not create lexical visibility. A parent settles direct
children, each of which follows the same rule for its own children.

`post`, `send`, and `receive` share one transport. An inbox item carries its
target and donor arena together. Taking it attaches the donor under the existing
ownership contract; refusal preserves the pair. Owner-local staging/outbox and
the successful publication boundary remain distinct from the inbox monitor.

Collection follows the live graph, Message/Thread state, mail targets, and the
single children collection. Its ownership unit is an arena chunk. Retained
`independent: immutable` branches stay in their owner's arena. Adoption must
preserve the required ownership ancestry; a refused adoption preserves the
hierarchy. The explicit preparation operation for an adoption copies obstructing
branches into the adopting Message's arena without itself changing supervision.

## 8. Native execution, editing, and explicit compilation

Methods and ordinary Structures use the same execution machinery. Known
native-to-native calls remain direct machine calls with the required explicit
and hidden parameters. An activation's native locals need not carry arena
value-record headers. Hidden caller-place transport preserves the observable
LMX type and write destination.

There is no load-dirty publication cycle, flush receiver, copy-back of own
locals, automatic executable-tree copy, automatic graph-edit invalidation,
or implicit compilation on a failed native lookup. The current
[call-frame contract](docs/LMX_semantics.en.md#call-frame-20261115) and
[editing API](docs/LMX_semantics.en.md#edit-api) define the detailed boundary.

`sys\compile` explicitly checks/prepares the selected graph, runs its required
build/test phase, translates through L1/C, invokes the host toolchain, and installs
successful native descriptors in the call tables. That check phase may execute
checkers and their candidate calls; compile does not launch the selected graph's
application entry. `sys\translate` produces L1 text and diagnostics, and
`sys\check`/`sys\checkL3` return diagnostics; these check/translate operations
do not execute application code or `test` merely to obtain a source representation.

A successful compile does not rewrite already compiled direct callers. Compile
the required unit when those call sites must change. `sys\endturn` unwinds
registered finally blocks to the ordinary turn boundary; catch does not intercept
it, it does not return to its call site, and it does not itself compile, detect,
or publish edits. The documented compile-plus-endturn boundary controls when
the update is guaranteed for the next entry.

Serialization of a selected Thread includes the needed arena/call-table state.
Same-platform native restoration uses module/entry identity under the existing
serialization contract rather than serializing raw host code addresses as
portable program semantics.

## 9. Translation and acceptance surfaces

This archive is accepted as documentation using its own relative links and
normative examples. It does not require the repository's document generator,
a paired Russian render, or a compiler bootstrap just to inspect the contracts.

Implementation acceptance applies focused cases to the relevant parser, namespace,
copying, calling, and native/walker paths. A successful translation is distinct
from linking, reached execution, expected refusal, or actual self-replacement.
Record the observation that a test establishes.

For binding changes, exercise native→native, native→walker, walker→native, and
walker→walker where applicable. Check values, types, addresses, initialization
state, and write destinations. A check of one returned integer cannot by itself
establish all of those contracts.

For field streams, check source preservation, separate input/output counts,
ordinary W/E, empty output, explicit grouping, per-operation sharing, and the
absence of destination-as-model behavior. For declaration actuals, check retained
forms, repeated execution, namespace contribution, and body access to the created
local.

A full self-build remains a separate implementation acceptance: supported
L3/L2 sources produce G1, then G1 produces G2, with actual source/toolchain/
artifact evidence. The documentation rewrite makes no claim that such a run
was performed.

## 10. Document map

| Concern | Primary document |
| --- | --- |
| Physical records, descriptors, arenas and ABI | [L2_spec_en.md](docs/L2_spec_en.md) |
| Parser, Frames, levels and grouping | [LMX_grammar.en.md](docs/LMX_grammar.en.md) |
| Roles, namespaces, calls, admission and runtime semantics | [LMX_semantics.en.md](docs/LMX_semantics.en.md) |
| Shared runtime implementation algorithms | [kernel-implementation.en.md](docs/kernel-implementation.en.md) |
| Worked examples | [LMX_semantics_guide.en.md](docs/LMX_semantics_guide.en.md) |
| Developer work and focused acceptance | [L2_L3_CODING_INSTRUCTION.md](L2_L3_CODING_INSTRUCTION.md) |
| Implementation provenance and historical distinctions | [implementation-notes.en.md](docs/implementation-notes.en.md) |
| Requirements and acceptance notes | [README.md](docs/README.md), [REVIEW_NOTES.md](docs/REVIEW_NOTES.md) |
