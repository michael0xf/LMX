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

The normal source-selection root is the tracked [selfbuild package](selfbuild/README.md).
The existing language manifest/stage-copy route preserves its src/tools/tests
layout before generation; older sandbox snapshots and six-list preparation
are historical evidence, not an active header/body fallback. Publishing a
source package and accepting its components does not itself close FULL, clean/native,
admission, clean-clone G0, or mail requirements.

A receiver and its argument Structure are formed by one algorithm before
the form is read. What the form is follows from the role of its Structure
in the launch, not from a classification of its head: in data it declares,
in code it is a call of its head (§9). One
expression resolver applies in every consuming position. A consumer checks
the resulting value; it does not secretly suppress or introduce a call.
There is one namespace. The walker uses the existing address-to-name table
to recognize a graph head; the translator sees the parser tree and generated
`native` does not need names for dispatch. This table is not a runtime
variable-binding map. A contradictory rule or need for a spelling-specific
branch is an author question, not a license for a shim.

## 2. Physical graph and identity

The target graph has a common `Lmx` Structure identity. A graph Array is
an `Lmx` Structure with fixed, typed element storage, not an unrelated
`VoidArray` record used as the base of `Lmx`. Both ordinary Structures and
graph Arrays have structural `parent` and `native`; their element/field
storage has a fixed size after construction. The approved target header is
flat `parent/native/length/storage`, in that order, without `Lmx.array: VoidArray`.
Numeric Arrays keep actual T-elements; Structure and Array<@> use pointer elements.
The current nested layout and the remaining migration are recorded in the
[implementation notes](docs/implementation-notes.en.md#l2-status).

Structure and Array<@> are fully interchangeable for equivalent contents in
indexing, length, naming, admission, copying, execution, typeof and descriptor
access. The header does not add elements. `descriptor(S)` returns an ordinary
Structure holding the four actual field addresses (`Lmx **`, `LmxEntry *`,
`size_t *`, `void **`). Explicit `\(d\native) := 0` writes S.native; assigning
`d\native` changes d's pointer field. Ordinary paths keep selecting user fields.
There is no header snapshot, write-back or reflection infrastructure. General
typed pointers and Array rank have no fixed numerical ceiling. This target is
[M13](next_core_tasks_v3.md#flat-lmx-descriptor), not completed implementation.

`descriptor()` also defaults to the current launch's data: it equals `descriptor(data)`,
including inside nested control bodies. An explicit argument selects S, including code.
Both variants return the selected Structure's actual field addresses through the same mechanism.

Ordinary non-declaring receivers `parent(S)`, `native(S)`, `length(S)` and `storage(S)` read the
corresponding header values. With no argument, `parent()`, `native()`, `length()` and `storage()`
use the current launch's data; code requires an explicit argument. Reading a value
does not construct a descriptor. Same-headed forms in data remain ordinary Structures,
selected by paths and occurrence indices; there are no header pseudo-fields.
The old physical names size/data become length/storage. Execution's data/code remain
the Structure arguments of call, and node keeps its existing activation contract.
See [receiver semantics](docs/LMX_semantics.en.md#header-receivers).

A graph reference slot's address, its stored pointer, and its referent are
distinct. `Lmx.parent` is the structural parent, not `Thread.parent`.
`Lmx.native` is a direct native-body entry or zero for walking the stored
L3 body; it is neither a field nor a method descriptor.
The one source graph retains declarations, values, operators, and nesting.
Execution changes declared values but does not replace the program with
a second data graph or AST.

Physical kind comes from arena ranges; model suitability comes from
`implements`. Ordinary and immutable Structures use distinct pools.
An already-created ordinary Structure cannot become immutable in place.
Primitive cells, reference cells, graph-object headers, and typed backing
each have their physical access contract. Raw typed arena storage is not a
second kind of language-level graph Array. Models do not
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

An ordinary graph Array has exactly its fixed element count and no
reserve/resize contract. A Structure constructed as an owned element is
structurally parented to that Array; storing a reference to an existing
Structure does not reparent its referent. The Array's own parent is its
containing source occurrence, so lexical visibility comes from the graph
position; a second name-based context is not invented. Growable
`List`/`DynamicArray` is separate; its backing can move and therefore
cannot store addressable `Lmx` field slots. Adjacent `a[i][j]` indexes a
rectangular Array; `a[i]\[j]` follows a reference to another
Array. `s\[N]field` is a different selector: it addresses the Nth
occurrence of the name `field` at the root level of a Structure used as
`data` -- an occurrence is a form of the data that declares that name, be
it a declaration by a receiver of a place or a structural form with that
head --, not an Array element or a second data-field namespace.

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

One immediately enclosing Structure has one namespace, and what a
declaration does follows from the role of its Structure in the launch
([the roles `data` and `code`](docs/LMX_semantics.en.md#data-code-roles)).
In code a declaration of a place by a receiver is a type check with an
assignment into the place of the selected `data`; a repeated one
(`int: i 6` on a known `i`) is an out-of-turn type check with an assignment
and creates no second field. In data every declaring form is an occurrence
of its name: a repeated declaration is one more occurrence, which neither
replaces the former one nor writes into it, and after it the name is
addressed only with the index of an occurrence. A Structure that is its own
data first initializes the variables of its root level; this prepares the
places only: a computed initial value is computed when execution reaches the
line of its declaration, and the data part of a method executes its own
initial values on entry. In data
`Struct1: Struct2` declares the Structure `Struct1` with the one atom
`Struct2`, a pointer to the Structure `Struct2`: a mention of a known
Structure is not expanded, and only that atom stands in the tree under
`Struct1`; in code the same form is a call of `Struct1`. The names of
Structures and functions are not assigned: `Struct1 := Struct2`, which the
decision of 2026-11-10 called the assignment, was withdrawn by the author
on 2026-11-11 -- pointer variables are assigned
([semantics](docs/LMX_semantics.en.md#colon-declares)).
Assignment never appends a slot. An explicit `call`, the launch of a Structure
by its name (§9) or a callable invocation (including `fn`) starts
its own binding scope; its own field may shadow an outer one. There is no
shadowing within one callable. Inline `if`/`for` are operators of that
activation, not scopes, even though represented as Structures. A
declaration by a receiver written under them likewise writes into the
selected `data`, not declaring a new field in `code`. A structural form in
executable code, `name: ... end: name` included, is a call of its head,
neither such a write nor a declaration; the declarations of `fn`, `sub` and
`catch` retain their own contracts. The registry of the forms of `data` is
built over its root level: a nested form belongs to its own Structure, does
not become a root-level form and is reached by a path through the enclosing
one, `data\if\y`.
One occurrence allows `data\field`; two or more require `data\[N]field`
with zero-based `N`, never automatic first-occurrence selection. Arbitrary
`data` is not auto-completed: data that lacks a place the code uses is
refused by admission. Interface checking is performed once per candidate:
at construction when known, otherwise on actual reception. Explicit `test`
checks are the second step at run time and stop on the first `0` (§4). The v3 migration must reconcile
parser, translator, native path, walker, and tests.

`@x` addresses the real stored cell, not an evaluation temporary or ABI
box: for a Structure/Array reference, the graph's `void *` slot; for a
primitive, its typed cell. Pointer depth is preserved. Native access to a
graph slot follows its actual C99 `void *` storage, not aliasing through
`Lmx **`. The general `\` operator and expression precedence are not
specialized for function pointers. See [L2 §18](docs/L2_spec_en.md#lowlevel-address).

## 4. Declaration, assignment, call, and admission

In accepted v3 rules a bare resolved atom reads a value/address, not a
nullary call. A method or method pointer uses an explicit call form. An
ordinary Structure executes through `call: A` or, in code, by the form `A()`
(the author's decision of 2026-11-11,
[journal](LMX_blog/2026-11-11.md#structure-call-by-name)). In data `A()` and
`A:` declare an empty Structure `A`, and a repeated such form is one more
occurrence of the name; nothing is called. In code the same form is a call
of the head `A`: with `A` a callable it calls it, with `A` an ordinary
Structure it launches it, `A()` as `call(A, A)` and `A(D)` as
`call(D, A)` (§9); it is an error when the head names neither a callable
nor a Structure. Do not reclassify a failed call as another operation.

M3 first normalizes legacy flat declarations to name-first order. A place
is declared only by a receiver form enumerating its arguments (the author's
decision of 2026-11-10, [semantics](docs/LMX_semantics.en.md#receiver-args-only)):
`int: i 5`, `@: ptr 0`, `@: ptr Model`, and `@: ptr Model 0`. The first
field names the place without invoking it; the second supplies a value or
requirement under the receiver's contract. The arguments of a receiver are
read as any arguments are -- as code (the author's decision of 2026-11-11,
[semantics](docs/LMX_semantics.en.md#data-code-roles)): the nested form
`Model: Other` in `@: ptr Model: Other` is a call of `Model`, not a
requirement with a candidate. The requirement and the candidate are written
flat, in three fields: `@: ptr Model Other`, and `@: ptr Model 0` for a
null address. A launch form of a Structure at a place where a value is
needed (an operand of an expression, an actual argument of a call, an
initial value, an operand of `merge`) is an error: a launch has no result (the
executor's reading -- [answers](LMX_blog/q/fable-self-answers-20261110.md),
Р22, item 3; Р25, item 4). The composed form with the
place in the outer head (`i: int: 5`, `i: int()`, `ptr: @()`, `ptr: @: 0`,
`ptr: @: Model: 0`), which N1–N6 retained, is withdrawn: `ms: int: time` in
data is a Structure `ms` with a field `time`, not a place `ms`. No translation path
reads the composed form as a declaration of a place any more, and the
project's sources and fixtures do not write it
([plan M9](next_core_tasks_v3.md#m9)).
`int: i` declares an int place without an initial value; `int: i 5`
supplies 5. Likewise, `@: ptr` declares a void reference without an initial
address, while `@: ptr 0` explicitly supplies null. A later write into
a void reference does not retroactively make its declaration
Model-constrained. Initializers, assignments, calls, and reference depth
use the general receiver–arguments model, not a special parse for `@`,
`int`, or a method name; each receiver still owns its argument contract.
Method-created callables and ordinary named
Structures retain their different contracts. Generated L1 is migrated
after L2/L3; see [v3 M1–M4 and N1–N6](next_core_tasks_v3.md).

The `fn` receiver distinguishes three source shapes after common P0:
`name args return` is a bodyless interface descriptor;
`name args return code` is executable and creates an addressable empty
`data` part; `name args return data code` supplies that part explicitly.
The descriptor gains no invented body, and existing short definitions
need no mass insertion of `()`.

`implements` checks the actual Consumer's explicitly required accesses;
without a Consumer, full suitability is checked. It is performed once, when
the clean graph is built; after that it is needed only where the candidate
is selected while the program runs
([cases](steps/implements-runtime-cases-20261111.md)), and an assignment of
primitives is not checked for admissibility at run time (the author's
decision of 2026-11-11; the rule speaks of the admission `implements`, not
of conversion: the range check on receiving a number of another type,
`u16(256)` into `u8`, remains at run time). The accepted address map
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

Each Thread has one `LmxPost`. `post`, `send`, and
`receive` must converge on this transport, not create a second
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

The maintained source package is `selfbuild/` with the relative
`src/l2src/`, `tools/` and `tests/` layout recorded in
[selfbuild/README.md](selfbuild/README.md). Candidates remain in the named
private stages listed by the current handoff. Translation checks correct C
emission and explicit throws/catch obligations. Interface checking through
`implements` is performed once per candidate: at construction when known,
otherwise on actual reception. Construction does not execute `test`; actual
run-time admission performs this second step and stops on the first `0`.
A direct data pass executes only root-level declaration receivers; these may
reach code supplied to them through ordinary execution. The translators
still repeat admission when the call or assignment is reached
([plan](next_core_tasks_v3.md#m11), step 7). The shared collector and
three-pass integration remain implementation work, not a completed guarantee.
Parser normalization does not itself prove
head resolution. Expected rejection, link, reached execution, and
self-build generation are distinct evidence classes.

The [v3 plan](next_core_tasks_v3.md) orders the general migrations,
accepted code/data work, complete kernel gate, L3+L2 self-build, and
then unified mail. Tests must record
actual source bytes and reached result, not only zero exit. The goal is
two genuine self-replacements from supported L3/L2 sources with L1 only
generated between them and C99. The published package has real whole G1/G2 quick generations; the final
normative acceptance still requires the open plan items and final FULL.

## 9. Known incomplete boundaries (at this snapshot)

The active dependencies are in [v3](next_core_tasks_v3.md); historical
tests and debt records remain in [pinned v2](https://github.com/michael0xf/LMX/blob/0e0a2978eb237e145e54715de805a88e65264ba4/next_core_tasks_v2.md) and
[defects](steps/defects.md). Same-name assignment, explicit calls,
pointer/address parity, cross-arena copy, admission maps,
immutable-owner checks, native/walker parity, and both self-build
generations need end-to-end evidence. Do not infer completion here.

The next-generation method layout and explicit `call: data code` are
**accepted implementation work**, not merely research. The target method
Structure has addressable `args`, result description, `data`, and `code`;
`data` is a separate argument before `code` and after the result type
where present. Its explicit fields and eligible missing body fields are
settled before constructing the Structure, without executing `data` or
`code`. The method's `data` is read in the role of data: the declarations
by receivers of places act in it, while assignments and all other code in
it are not executed. At method entry the computed initial values of those
declarations are evaluated -- this is the contract of the method itself; in data
supplied to a launch separately a computed declaration is not executed (the
executor's reading, answers Р12 and Р14, item В9). Publication writes a result into the slot of its declaration
and may replace the stored initializer; the next entry sees the current graph,
not an initializer already removed from it. This automatic layout
belongs to that method's specific body and `data`, not to arbitrary call
data. An ordinary Structure receives no automatic fields from the body: its
data is passed to the launch explicitly. A child block `data:` inside an
executed Structure is in code a form with the head `data`, a launch of the
data of the current launch with the block in the place of the argument, and as
a rule it is refused (see the launch by name below); the data
and the code of such a pair are written apart -- as two Structures of data
or as the parts `data` and `code` of a method, `call(m\data m\code)` (the
executor's reading -- [answers](LMX_blog/q/fable-self-answers-20261110.md),
part Р). The general `call: data code` receives
two Structures and admits fields required by `code` against the supplied
`data` before execution. Declarations by receivers under inline control flow
use that same prepared map of the root level of `data`; a form nested in
the data is not a root-level form, and a name with several occurrences
requires an index. They
do not append slots to `data`. Method
`data` fields are preallocated from its particular body, whereas arbitrary
selected `data` must already contain every required place. Thus
`call(m\data m\code)` passes the declared data through a prepared
code-to-data address map. Unary `call: code` executes the code over itself
as data (the author's decision of 2026-11-11,
[the receivers `call` and `fncall`](docs/LMX_semantics.en.md#call-receivers));
it selects no child `data` block, and the data is passed explicitly. It
fabricates no data: a place the code requires and does not hold itself is
not found, and the call refuses. Explicit
`call: code code` is the same form, under the general admission,
graph-write, and `native`-validity rules; it is a universality test for
Structures. The receivers `fncall(args data return code)`,
`fncall(data return code)`, `fncall(return code)`, `call(args data code)`,
`call(data code)` and `call(code)` receive the parts of a launch explicitly:
an addition to the existing mechanisms, neither a declaration nor the
ordinary call -- `fn`, `sub` and `catch` are declared and called as before,
and the interpreter launches them through this same open mechanism (the clean
graph does not execute `catch` yet: that is the present state of the
implementation, not the norm), which can call any composition of Structures.
In every receiver the arguments are named and are supplied by position or by
name with the operator `:=` (the executor's reading of the author's correction
of 2026-11-11, [journal](LMX_blog/2026-11-11.md#structure-call-by-name)):
`call(data := D; code := C)`,
`fncall(args := A; data := D; return := int; code := C)`, the parts of `fn`
and `sub`. In code an ordinary Structure is also launched by a form with its
name as the head, `A()` as `call(A, A)` and `A(D)` as `call(D, A)`: a
launch form of its own, not a form of a receiver (see the launch by name
below).
`fn`, `sub` and `catch` differ from
an ordinary Structure in completing their `data` when the graph is built;
data is read as a whole, so a name used above the line of its declaration
reads the same place. The clean graph -- its interpreter and the `native` it
emits -- executes these receivers since slice 353; the working frontend does
not yet ([plan](next_core_tasks_v3.md#m10)). The data stands before the
code in every form (the author's answer of 2026-11-11): the two-argument
launch is `call: data code`; the clean graph reads it since slice 354 and no
longer accepts the former `call: code data` (step 4 of
[plan section M11](next_core_tasks_v3.md#m11)), while the working frontend and
its fixtures still read the former order (step 8).

The author's decision of 2026-11-11 on the roles `data` and `code`
([the roles `data` and `code`](docs/LMX_semantics.en.md#data-code-roles))
narrows the rules above; it changes and extends none of them (except the
change of the spellings `var` → `data` and `body` → `code`, of the order
`call: data code` and of the moment of the admission `implements`;
[journal](LMX_blog/2026-11-11.md#data-code-roles),
[order](LMX_blog/2026-11-11.md#data-before-code)). A Structure
takes part in a launch as data or as code -- the launch gives the role, not
the Structure itself --, and a written form is read by
that role. In data a structural form declares a Structure, whatever its
head -- a written call and the control receivers are Structures there,
addressed `data\if`, `data\if\if`, with an index when several --, the
declarations by receivers of places act, and assignments and all other code
are not executed: an assignment there is just a field that an index
reaches. A repeated declaration in data is one more occurrence of the name;
it neither replaces the former one nor writes into it, and after it the name
is addressed only with the index of an occurrence, `data\[N]name`. In code
every form is a call: a declaration by a receiver
is a type check with an assignment, `Model: KnownStruct` is a call of
`Model` and an error when `Model` names neither a callable nor a Structure;
code declares no Structure, while the declarations of `fn`, `sub` and `catch`
stay, a callable declared in data is called directly by its name, and an
ordinary Structure of the data is launched by a form with its name as the
head (see the launch by name below). An unnamed Structure
in code is not a call: `(a b c) := myFn()` is a group assignment
([book](docs/LMX_semantics.en.md#data-code-roles),
[journal](LMX_blog/2026-11-11.md#unnamed-structure-not-call)). Only values are
assigned -- primitives and pointers to Structures and to functions:
`Model := KnownStruct3` is an error, a pointer variable is declared by
`@: ptr KnownStruct`. Arguments of calls and of receivers are read by one
general algorithm, as code: `f(arg: v)` is a call of `arg`, only
`f(arg := v)` is a named argument, and a requirement with a candidate is
written flat, `@: ptr Model Other`; formals are declared by receivers
(`int: arg default`, `@: arg Template`), a structural form among the
formals is forbidden, and declarations of Structures are written in the
data block -- `sub: proc () (struct1: Template1; struct2: Template2)`.
This record is a header without code: `sub` has three fields in the
record -- `name args code` -- or four -- `name args data code` (the last
field is the code, `data` is an optional part before it), so the group
after the arguments is `data` when code follows it (in body lines or in
one more group), while a record with a single group after the arguments
is the short form `name args code`; a method without executable forms
writes the empty code part explicitly, `( … ) ()` (the executor's
reading -- [answers](LMX_blog/q/fable-self-answers-20261110.md), Р26,
item 1). A
launch form of a Structure at a place where a value is needed (an operand
of an expression, an actual argument of a call, an initial value, an
operand of `merge`) is an error: a launch has no result (the executor's
reading -- [answers](LMX_blog/q/fable-self-answers-20261110.md), Р22,
item 3; Р25, item 4). The
special name of the explicit reference to the data of a launch, the part of
a callable of the same name and the data block are called `data` --
formerly `var` --, and the part with the executable forms, like the
argument of the receivers `fn`, `sub`, `catch` of the same name, is called
`code`, formerly `body`; the parts of a callable are `args`, `return`,
`data`, `code`. The clean graph reads these names since slice 354 and no
longer accepts the former ones (step 4 of
[plan section M11](next_core_tasks_v3.md#m11)); the working frontend, with its
fixtures and the project's sources, still uses `var` and `body` until step 8.
`implements` is performed once, when the
clean graph is built; the cases in which it is still needed at run time are
collected in
[steps/implements-runtime-cases-20261111.md](steps/implements-runtime-cases-20261111.md).
The translators no longer have to find out where a call, a declaration of a
Structure and an assignment stand -- the role says it --, and the branches
that made this choice are to be removed. Apart from the names and the order
of the parts, the clean graph executes sub-step 5а since slice 355 and the
first part of sub-step 5б since slice 356 ([plan](next_core_tasks_v3.md#m11));
the rest -- sub-step 5в and the remainders of sub-steps 5б, 5г, 5д and 5е --
it does not execute yet, and the working frontend executes none of these
rules until step 8.

The author's answers of 2026-11-11 to that decision
([declaring by a colon form](docs/LMX_semantics.en.md#colon-declares),
[visibility](docs/LMX_semantics.en.md#declaration-visibility)). A mention of
the name of a known Structure is expanded nowhere -- neither by the parser
nor when the clean graph is built: in `Model: knownModel` the Structure
`Model` has the one atom `knownModel`, a pointer to the Structure
`knownModel`, immutable by name; it begins to refer to it at interpretation
and translation, and a path through it continues into its fields
(`Model\knownModel\a` is the field `a` of `knownModel` itself), but no
subtree arises under `Model`, and the `parent` of
`knownModel` -- its place in the tree -- does not change. The slot of the
atom may be rewritten by index (`Model[0] := …`); a mutable reference is
declared by `Model: @: ptr knownModel`. Visibility in data runs in both
directions: a name declared by a form of the data is available both to the
code over that data and to the other forms of the same data, above and
below the declaration; the order in which statements are executed stays,
and a name being available does not mean its value is already computed.
References by name that close into a cycle (`A: B` and `B: A`) are no
error; the arguments of calls name Structures the same way, by name and
without expansion. A Structure launched over itself -- `call(code)`, the same as
`call(code code)`, and the root of a unit -- has no rules of its own: its
forms are read in both roles by the general rules, no declaration "of its
own" is skipped, and an uncertainty is an error
([journal](LMX_blog/2026-11-11.md#self-launch-no-own-rules)). The executor's
reading from that ([answers](LMX_blog/q/fable-self-answers-20261110.md),
part Р): a declaration of a Structure among the executed forms is still, as a
rule, an error, but for another reason (answer Р21): in code the form by which
the same data declares an ordinary Structure launches that Structure, and its
own tail stands in the place of the argument -- two or more fields in the tail
are not a defined number of arguments, one field is the data of the launch and
must give a Structure; only the degenerate forms do not refuse: an empty tail,
a single atom that names a Structure, a single unnamed Structure in
parentheses. So an executed Structure (the root of a unit, the body of a
method, a Structure launched by `call` or by name) holds no declarations of
Structures; they are written in data -- in the `data` part of a method, in a
Structure the launch receives as data, in a written Structure in a value
position.

A Structure is launched in code by its name (the author's decision of
2026-11-11, [journal](LMX_blog/2026-11-11.md#structure-call-by-name); the
executor's reading -- [answers](LMX_blog/q/fable-self-answers-20261110.md),
answer Р21). In code a form whose head is an ordinary Structure launches it
(before the decision of 2026-11-11 such a form was refused in code, and an
ordinary Structure was executed only by the receiver `call`): `S()` is the
same as `call(S, S)` (the Structure over itself), `S(D)` is the same as
`call(D, S)` (the Structure over the given data); so are the short form
`S: D` and the block form. It is a launch form of its own, not a form of a
receiver: the receivers `call` and `fncall` remain the general mechanism
([the receivers `call` and `fncall`](docs/LMX_semantics.en.md#call-receivers)),
and the formals are supplied by `call(args data code)` -- there is no launch
form with the argument `args`. The argument is one and is named `data`, the
name by which executed code refers to the data of its own launch
([the special name `data`](docs/LMX_semantics.en.md#ordinary-var)): `S(D)` and
`S(data := D)` are one form. It must give a Structure (a name, a path, a place
with a reference, an unnamed Structure written in parentheses), otherwise it
is an error; so are an argument of another name and two or more positional
arguments. The head is a place with a reference: what the reference points to
is called -- a callable (a call through a pointer) or a Structure (launched by
the same forms); a place of a number, an empty reference and an unknown name
are errors, as is a head that names neither a callable nor a Structure.
`data()` in code launches the data of the current launch over itself. In
data nothing changes: `S()` still declares an empty Structure `S`, and `S(D)`
a Structure `S` with an atom `D`; nothing is called (for `S()` confirmed by the
author, [journal](LMX_blog/2026-11-11.md#structure-head-call-refuses-in-code);
for `S(D)` the executor's reading, answer Р21, item 2). In a
Structure launched over itself and in the root of a unit each form is read in
both roles, so the form `S()` there is at once a declaration of one more `S`
and a call: if `S` is declared in the same Structure, the name has two
occurrences, without an index it does not answer, and the call is refused; if
`S` is declared outside, the form declares its own empty `S`, and that one is
launched, not the outer one. There is no rule of its own, and the same
Structure is launched there by the receiver `call`; the call of a method or of
a receiver is not affected. Since slice 356 the clean graph executes the
launch of a Structure by name in the code of a method and in code over given
data -- `S()`, `S(D)`, `S(data := D)` -- and a form whose head is a place
holding a reference to an ordinary Structure everywhere, the root of a unit
included, as well as the named supply of the arguments of `call` and `fncall`;
in the root of a unit and in a Structure over itself it does not yet execute
the role of code of a form with an ordinary Structure as its head by name
(sub-step 5г of the [plan](next_core_tasks_v3.md#m11)). The working frontend
reads the former names and order and does not execute the launch by name
(step 8).

The existing place map and frame also serve ordinary Structure native bodies:
one C.native executes with any admitted D, including reordered fields, through
the same body emitter and entry/exit mechanism as methods. Neither fn/sub nor
data = code is required. Data-only use does not require S.native. A dynamically
selected compiled C uses its entry; suitable uncompiled runtime code uses the walker.
Dirty data and code share publication checkpoints. Clearing native affects a new
dispatch, not machine instructions already running; the walker must retain equivalent
prepared-frame continuation after publication and nested calls. No artificial method,
whole-graph copy or permanent version registry is introduced. Implementation is open in
[M14](next_core_tasks_v3.md#native-structures).

The publication contract does not require a universal assignment journal. Native determines
needed stores and conditions statically where possible; dynamic places use only necessary frame
change tracking. Computations, checks, effects, alias reads and publication timing are preserved.
Ordinary non-declaring `flush()` takes no arguments and returns no value: it publishes ready dirty
changes of the current frame and continues execution, with no new activation, yield, exit or Message
publication. Successful publication clears dirty state; another flush without new changes writes nothing
and repeats no evaluation/admission or cache load. Same-headed data remains ordinary data.
The language receiver is an open M14 task; the existing internal publication helper is not its implementation.

The `implements` field-address
map is general for any admitted pair of Structures. At publication, already
computed `dirty` values go directly to their selected physical `data` slots
through that map if necessary: no expression evaluation, repeated admission,
or copy of the full Structure. The normal split gives the compiler and walker
an execution-source role for `code` and a writable-state role for `data`:
those roles do not establish code stability by predicting writes or aliases.
This is not an `immutable` qualification of the whole `code` Structure.
`call: code code` deliberately removes that separation to exercise general
code mutation and `native` invalidation, including eventual on-the-fly
recompilation; it does not require a special executor. All Structures follow the same representation
and mutation rules, subject to their qualifications: a `data` part does not make the rest of its
Structure untouchable. A general graph-write mechanism
must distinguish a data-value update from a change to the executable body
and invalidate an incompatible `native` when that body changes, including
publication within `data` or through a code/data alias. Do not add a special
execution path or hidden copy for this form. Entry into `call(code code)`
alone does not invalidate anything. A working `dirty` value has not changed
the graph until publication; explicit paths, aliases and dereferences select actual
places and use that same frame dirty state and the standard publication checkpoints. With the place and value admitted, follow the actual cell-to-code links, including enclosing code; commit the slot
and clear the affected code entries as one observable operation before another or
recursive dispatch. A failed write
or a compatible data-value update preserves the entry. L2 code needs a
matching native replacement or refusal before publishing an incompatible
mutation: the L3 walker cannot serve as its fallback. Because `code` may be a reference to any
suitable Structure, `call`
never adds fields to `data`. External values resolve
during execution and do not populate namesake data fields by coincidence;
an activation may change its working `k` without creating `code\k`.
External fields change only through an explicit path such as `node\k`.
No additional runtime variable-binding table or second graph is introduced;
the walker uses the existing address-to-name table to recognize Frame heads.

This is a target contract, **not** a claim that the current translator,
walker, or physical method ABI already implements it. `Lmx` slots stay
fixed: determine all slots before allocation; a different `merge` result
gets a new allocation, not an in-place extension. Native reuse requires
proof of the used address/type and code→data contract, not only unchanged
body text. Remaining details are worked out in the accepted stage using
[the design record](steps/next_generation_model_20261014.md) -- written
before the decisions of 2026-11-10 and 2026-11-11 and in the former
spellings; where it differs, those decisions prevail -- and
[v3](next_core_tasks_v3.md), with contradictions returned to the author
before a one-off implementation. No second data graph is introduced.

## 10. Source map

| Concern | Maintained entry points |
| --- | --- |
| Graph, pools, arena | [lmx_pool.lm2](selfbuild/src/l2src/lmx_pool.lm2), [lmx_range.lm2](selfbuild/src/l2src/lmx_range.lm2), [build.lm2](selfbuild/tools/build.lm2) |
| Call and walker | [lmx_call.lm2](selfbuild/src/l2src/lmx_call.lm2), [lmx_walk_values.lm2](selfbuild/src/l2src/lmx_walk_values.lm2) |
| Thread, turn, root | [lmx_thread.lm2](selfbuild/src/l2src/lmx_thread.lm2), [lmx_turn.lm2](selfbuild/src/l2src/lmx_turn.lm2), [lmx_root.lm2](selfbuild/src/l2src/lmx_root.lm2) |
| Mail, children, collection | [lmx_post.lm2](selfbuild/src/l2src/lmx_post.lm2), [lmx_child.lm2](selfbuild/src/l2src/lmx_child.lm2), [lmx_gc_graph.lm2](selfbuild/src/l2src/lmx_gc_graph.lm2) |
| Copy, merge, admission | [lmx_graph_copy_owned.lm2](selfbuild/src/l2src/lmx_graph_copy_owned.lm2), [lmx_merge_owned.lm2](selfbuild/src/l2src/lmx_merge_owned.lm2), [lmx_implements.lm2](selfbuild/src/l2src/lmx_implements.lm2) |
| Frontend and backend | [l2_frontend_core.lm2](selfbuild/src/l2src/l2_frontend_core.lm2), [l2_frontend_emit.lm2](selfbuild/src/l2src/l2_frontend_emit.lm2), [build.lm2](selfbuild/tools/build.lm2) |
| Build, docs, receipts | [build.lm2](selfbuild/tools/build.lm2), [docs_check.lm2](selfbuild/tools/docs_check.lm2), [README.md](selfbuild/README.md) |

This map locates a mechanism; it grants no write ownership. Check
`OWNED_BY`/`LOCKED` markers and the active writer before editing code.
