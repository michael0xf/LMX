# L2/L3 developer instruction

> **Repository note.** This file is the edition of 2026-11-21, transferred verbatim from the author's
> documentation packet (it lay in `docs/new_parts/newdocs/` and was removed there as a duplicate on the author's
> order of 2026-11-21); only link targets were adapted to repository paths.
> The mandatory build order of this repository is [to_fable2_fast_build.md](to_fable2_fast_build.md); the
> implementation state is recorded in [READ.ME](READ.ME), the [plan](next_core_tasks_v3.md) and the
> [current pipeline](steps/current.md).

This instruction accompanies the standalone English documentation packet. It
applies the [semantics](docs/LMX_semantics.en.md), [grammar](docs/LMX_grammar.en.md),
[L2 contract](docs/L2_spec_en.md), and [kernel implementation contract](docs/kernel-implementation.en.md).
The author's requirements and accepted supplements are part of that model: the
[index](docs/README.md#subjects) names the place of each subject in the documents.

The files in this archive are the review surface. Their relative links and
examples can be checked without running a repository documentation generator,
rebuilding a Russian counterpart, or performing a bootstrap. Runtime acceptance
requires its own measured evidence; this document does not report such a run.

## 1. Work from the accepted contract

Before an implementation change, identify the exact affected source, the current
contract, the existing shared worker, and the observable result to establish.
Determine which requirements the current implementation already satisfies.
An old checkpoint or a statement about a former implementation is not evidence
about today's working tree.

Use one writer for overlapping runtime paths and coordinate ownership of builds.
Independent document work and read-only reviews can proceed separately. Keep
unrelated work outside the change.

When two applicable requirements genuinely conflict, record the smallest example,
the two rules, and the differing outcomes. Continue independent work while that
specific decision is resolved. Do not hide a new language rule in an implementation
exception or make a test pass by silently changing its intended observation.

The two inherited review cases are derived from the common rules in
[REVIEW_NOTES.md](docs/REVIEW_NOTES.md#open-questions). Implement those consequences;
do not turn a resolved example or an unspecified host fixture profile into another
language-approval gate. Ask the author only when applicable current requirements
actually contradict one another, with both clauses and the distinguishing case.

## 2. One source graph and one parser

**All receiver records remain in the source graph as written. Computations and
semantic transformations take place exclusively in namespace. Terminal primitive
declarations remain in the graph as direct `{type value}` records.**

The graph is the complete literal source, including those primitive leaves at
the addresses held by Structure cells. All receiver structures—including `for`,
`if`, `merge`, `copy`, and `import`—remain available as written and can be replaced
by ordinary explicit graph assignment. Do not introduce an uneditable executable
representation or a special mutation protocol. Apply the existing explicit
compile/endturn restart mechanism when an executable change needs recompilation.

The whole program is that complete graph plus a binary containing compiled
native methods. `parent` and `length` are logically determined from source
structure; the other contents lie in the Lmx pointer array and its referenced
records. Keep the ordinary stored-header contracts: this does not require
reconstructing them from text on every access.

R0 lowers to an ordinary C method with a local pointer to the R0 graph. The
interpreter also uses a binary R0. Do not replace that local pointer by a hidden
global program instance, or add a static DATA replica, materialized namespace
graph, copied executable body, or expanded program for the walker. Frame values,
source references, selected binding maps, and temporary compiler analysis serve
their specific operations; they do not form a second runtime program graph.

P0 builds the written receiver–arguments model, retaining every Frame, boundary,
and explicit group. It does not execute defaults, import names, expand composition
results, or delete a sole anonymous group. Semantic role, resolution, precedence,
and admission are applied after that structural parse.

Use the same expression mechanism in an actual, initializer, return, field, and
nested receiver. A consumer's contract determines what it requires; it does not
supply a second parser for a familiar receiver spelling.

The existing canonical-name/address information identifies a written receiver.
Prepared native calls use the admitted addresses and machine contracts. Do not
replace these with an independent opcode graph, a second source AST, or a
persistent global variable-binding registry.

Allocating a computed value or a copied graph result does not authorize rewriting
the source receiver that produced it. Explicit program writes keep their own
graph-memory contract. Namespace values and source records must remain
distinguishable in diagnostics and serialization.

### 2.1 Block boundaries

A one-level dedent closes the ordinary open level. An explicit permitted marker
can close the larger boundary described by the grammar.

A physical blank line outside protected literal/comment content completes the
whole current syntactic block through the root boundary. This is the common
level-completion mechanism, corresponding to the conceptual `-1` boundary
where a source `---` cannot itself be written. Several consecutive blank lines
are harmless.

Apply the exact rule and the [observations of blank-line closure](docs/LMX_grammar.en.md#levels)
of the [grammar](docs/LMX_grammar.en.md), including paired delimiters, Mix documents,
EOF, and protected text. A blank line does not invent a matching closing bracket
or silently repair malformed bounded syntax.

Verify an existing implementation before changing it. The requirement is not
grounds for a separate blank-line parser or a mandatory rewrite of an already
conforming common scanner.

In LMX examples, do not insert decorative blank lines inside a vertical block
that is meant to remain open. A blank line between completed top-level Structures
is an intentional boundary. Avoid redundant `end:` or `---` markers when a
normal single-level dedent or a permitted terminal return already expresses the
intended close.

`end: name` has its own purpose (the author's clarification of 2026-11-23,
[journal](LMX_blog/2026-11-23.md#end-purpose)): it closes a long function that
does not end with `return` and, where it helps the reader, a long nested
function even when its last statement is `return`. After a short function, or
after a top-level function that ends with `return`, it is redundant.

## 3. Declarations, calls, and writable places

A bare atom reads a value/reference and does not invoke it. A method pointer or
ordinary Structure is invoked by an explicit CODE Frame. Dereferencing a reference
does not itself execute the referent.

The same structural form is interpreted by role:

| Form | DATA reading | CODE reading |
| --- | --- | --- |
| `A()` | Empty Structure declaration | Invoke A with an empty actual tail |
| `A: ()` | A with one empty anonymous Structure | Invoke A with the written structural actual |
| `A: B` | A containing a reference to B | Invoke A with actual B |
| `int: i 5` | A primitive declaration | Declare/update the corresponding execution place |
| `i := value` | A retained written form unless consumed by its declared contract | Write an already known writable place |

A place is declared by its receiver: `int: i 5`, `@: ptr`,
`@: ptr Model`, or `@: ptr Model candidate`. The first argument identifies the
place. Nested `Model: Other` remains a Frame; it is not an alternative spelling
of two flat requirement/candidate arguments.

`i: int: 5` does not declare the primitive i. A structural declaration's name
does not become assignable merely because an expression appears after its colon.
Use a declared reference variable when the stored reference must change.

Repeated CODE declarations retain initializer evaluation, admission, and writing
to the existing same-level place; they do not require another C declaration.
A repeat without a new RHS preserves the current value. Repeated DATA declarations
remain separate occurrences under the normal DATA namespace contract.

`S\[N]field` selects a same-name DATA occurrence. `a[i][j]` and `a[i]\[j]`
have their distinct rectangular-index and reference-following meanings. Do not
repair one operation by changing the syntax or storage meaning of another.

## 4. Structural call, DATA, and return

For a selected executable Structure C, DATA is `parent(C)`:

| Form | Actuals |
| --- | --- |
| `call(C)` | None |
| `call(A C)` | A |
| `C()` | Empty written tail |
| `C(args)` | Written actuals admitted by the common algorithm |

`call` has parameters `args` and `code`. The one-argument form requires code;
the two-argument form requires both. `call(code := C)` fixes its single actual
without an E reading. `call` executes C itself and does not search for a child
named code.

The separate DATA argument, the builtin `data` name, `fncall`, and executable
`fn`/`sub` definitions are removed. Ordinary user names follow their current
resolution contract. `node` remains the explicit lexical operation, fixed for
the current method activation; it is not a synonym for every nested Structure's
immediate parent.

To combine different data and code, establish the structural relationship before
calling. Merely placing a reference under a new container does not reparent it.
The call site, native implementation address, or service dispatcher does not
replace the selected occurrence's lexical context.

R0 has no DATA and no user actual arguments. Do not synthesize self-DATA, an empty
DATA Structure, or an artificial data field. Host/runtime launch parameters are
not user signature arguments. Its native C method holds the R0 graph pointer
locally, including when the invoked program operations use the interpreter.

`return` in DATA describes a result and assigns nothing. In CODE it is the return
receiver. Ordinary Structure calls and explicit `call` may return that described
value. End of code does not synthesize a return.

### 4.1 One invocation mechanism

Ordinary calls, reference calls, handlers, and structural execution use shared
selection, binding, admission, namespace, and result workers. Known native calls
remain direct C calls when the prepared contract permits them.

The dispatcher must retain the language caller's context. Its own service locals
must not become the source of autofill or transparent binding.

`catch` retains its handler rules: matching by failure name/scope, no execution
during the initial direct pass, normal payload actuals, cleanup and continuation,
and the established distinctions between nested and neighboring handlers.
Moving it to the common call model does not turn it into an ordinary function.

## 5. Named fn and implements

Write a named signature with two DATA-role arguments:

~~~lmx
fn: SumSignature (int: left; int: right; return: int)
~~~

The name is a constant signature declaration. The template uses the ordinary
DATA notation. A result field makes a value signature; its absence makes a
procedural signature. It creates no executable method.

An ordinary structural template checks every part of its explicitly required
tree. If the template contains a method subtree, that subtree is part of the
requirement. Use a minimal template when only a minimal structural interface
is intended.

The fn branch of the same `implements` compares the count and ordered types
of explicit parameters and the presence/type of result. Parameter names,
initializer values, and implementation trees are not fn identity keys.
No separate signature-validator subsystem is introduced.

A call through a fn-constrained reference uses the public signature names to
select argument positions. Those positions map to the candidate's corresponding
parameters even if its names differ. Evaluation order remains the written order;
matching does not rename the candidate or reorder effects.

Defaults, requiredness, throws, and hidden binding use the actual candidate's
contracts and names. A default in a requirement is not copied into the candidate
merely by checking it. `return` is not an input.

## 6. Selection before implicit binding

A candidate consists of a visible declaration, an admitted reading of explicit
actuals, and their map to formals.

- W reads the supplied actual whole.
- E, where admitted, reads the immediate fields of a single Structure argument
  once, one level deep.
- `f(arg := S)` supplies an explicit named actual without E.
- The readings have equal standing. No candidate means refusal, one means a
  selected call, and more than one means ambiguity.

There is no preference for one arity, the whole Structure, or the first inspected
declaration. Two valid readings of the same declaration remain two candidates.
The selected map is used without repeating expansion during execution.

Check candidates without speculative execution of RHS effects, defaults, or
behavioral tests. Reuse an already computed argument rather than evaluating it
again for E. Run statically available shape checks before effects as required
by the ordinary call contract.

Hidden caller values do not become explicit actuals, satisfy a missing required
input during selection, rescue a rejected candidate, or restart the choice.

A named actual at the next position of its own formal counts as positional.
An out-of-position named actual disables positional counting; following actuals
must then be named. The cursor does not restart later.

## 7. Passed declaration receivers

A declaration receiver passed as an actual in CODE is read as DATA. Retain the
form rather than executing its initializer just to pass a value.

| Situation | Required handling |
| --- | --- |
| The declaration's name matches an input in DATA | Replace the selected declaration description in this call's namespace |
| The inner declared name is absent from DATA | Pass the entire form in its current position as one Structure |
| An outer `name := ...` names the actual | Use that outer destination; retain the form's own inner name |

The inner name in `int: item numbers\next()` is not automatically an unknown
named actual when the receiving inputs are iteration and body.

The passed root declaration logically supplements the executing code's root
namespace. Physical source parents are not rewritten; no fields are inserted
into source code. Each reached invocation of the retained declaration executes
it again. The first creates the receiving local, and later executions update
the same place by the normal repeated-declaration rule.

The associated body uses that receiving place. Entering the body must not
construct another independent item or evaluate the iterator initializer again.
Real nested scopes inside the supplied form retain their normal shadowing.

Do not extend this rule to every ordinary call-shaped Frame or every Structure
reference. `Producer()` in CODE remains a call of Producer. Resolution of the
head's declaration contract supplies the distinction; no hardcoded list of
`iterate`, `iteration`, `item`, or primitive receiver names is needed.

The complete examples and named-order cases are in the
[declaration arguments](docs/LMX_semantics.en.md#declaration-arguments) and the
[required observations](docs/LMX_semantics.en.md#declaration-observations).

## 8. Binding places and two-way private

For an own declared place, use the order: explicit actual; its own ready value
or initializer description; allowed same-name caller autofill; ordinary
uninitialized state and requiredness.

Autofill gives an own place. Writing that own copy does not write the caller.
A supplied zero is supplied material, not an omitted argument.

For a used external name without an active own declaration, protect any really
visible private lexical declaration from dynamic replacement. Otherwise select
the permitted caller-local place transparently; if it is unavailable, retain
the former binding as lower-priority fallback with its own working
value/description.

A transparent place uses the caller's actual cell. Writes are immediate and
update its initialization state where applicable. It is not copy-in/copy-out.
The fallback is an own copy and is not changed into an alias.

A hidden native pointer does not change the LMX variable type. Plain reads,
assignments, and `@x` act on the selected logical place. For a reference variable,
the native transport address does not add a visible source-level reference depth.

`private` applies in both directions on all implicit dynamic routes. Private
caller places are not offered; private visible lexical recipients are not
overridden. Explicit passing, explicit paths, nested lexical access, and node
remain possible under normal const/immutable restrictions.

Read the existing `private` receiver from the same clean graph. Do not serialize
a second privacy/initialization-marked graph into the binary or materialize one
in the namespace. Generated methods reflect the binding decision; ordinary
temporary facts and frame values do not justify a second program representation.

Filter concrete places, not all uses of a spelling. A skipped private source
does not hide every other admissible source of that name. New inner declarations
can shadow outer ones under the ordinary scope rule.

Reachability through A → B → C is preserved without static accumulation of all
transitive requirements. Forwarding a B-owned copy gives B's place; forwarding
an existing transparent link retains its original target. A suspended producer
does not rebind its captured places to a later next-caller.

## 9. Visibility and evaluation timing

Variables and const declarations are visible sequentially; named Structures and
callables are visible in both directions. Namespace preparation does not expose
future CODE locals or walk unentered branches.

A nested declaration shadows the outer same-name declaration and may have a
different type. A same-level repeat uses the existing place. Leaving the nested
scope restores the earlier visible binding and its write/private properties.

Before an own declaration begins, a use can resolve by the ordinary outer path.
Do not pre-scan the entire body and suppress that use because a later declaration
shares its name.

Own frame values/descriptions are independent of their source under the accepted
activation contract. References retain their referenced targets. Unused computed
inputs do not run. Once an own input is demanded and initialized, later reads of
that activation place reuse its current value; removing dirty publication does
not mean reevaluating its initializer on every read. Reaching a repeated CODE
declaration still runs its RHS and updates the same place. Separate calls and
separate dynamic expression evaluations retain their own ordinary state.

For the [no-RHS inline case](docs/LMX_semantics.en.md#inline-declaration-control), the new inner place is `uninit:int`:
the inline scope is not a new caller, and the stated actual caller has no x.
The existing outer x = 5 remains unchanged. A reached required reception refuses
the absent value. This is a consequence of ordinary caller autofill and distinct
inner declaration identity, not an outer-local copying rule. Retain that explicit
oracle in the [derived review case](docs/REVIEW_NOTES.md#open-questions).

## 10. Operands, priorities, and effect ordering

A user operand is an ordinary method resolved in the current namespace.
Its DATA is checked against the structural operand header. Mandatory fields are
`left`, `right`, `PASS_ARGS_AS_IS`, and `PRIORITY`. Missing properties are not
filled by merely checking the template.

`left` is one reference input. `right` is an Array of references in source
occurrence order. A container remains one operand; no general Array spreading
is introduced. An operand has one opening of its own: when its `left` is an
unnamed Structure and its single `right` argument is an unnamed Structure too,
the parentheses on the right are opened and `right` receives all their content;
a Structure returned from a function is not opened (author's decisions,
2026-11-21 and 2026-11-22). Prefix forms can omit the written left actual under normal
method admission.

`PASS_ARGS_AS_IS 0` supplies prepared values. `PASS_ARGS_AS_IS 1` supplies
original occurrences without their effects. The priority is an independent
constant property. The method returns its ordinary declared type, not a universal
record pointer that expression automatically dereferences.

`sys\eval(fragment)` evaluates a raw occurrence through the same evaluator and
its original context. Two explicit calls mean two evaluations. The context
association survives helper calls for its admitted lifetime but does not make
a completed activation immortal. Ordinary dereference does not evaluate source.

Use `sys\name(identifier)` for the written spelling without resolving the
identifier's value. `sys\priority(name)` queries the same operand properties
used for expression analysis. Separate `sys\operand` registration is removed.

Normal reference passing remains `@: ptr Struct`. Prefix `@Struct` explicitly
obtains a numeric address. Machine-address operations retain the existing
memory/profile restrictions; no automatic address-taking is added to pass
methods or Structures.

Supported arithmetic precedence follows C; `=` is equality and `:=` is
assignment. `**` keeps the explicitly documented Python-like asymmetric
binding. Assignment remains low-priority and right-associative.

An operation obtains required values on demand, once per occurrence in a
particular evaluation. This does not change precedence or shorten an
assignment's RHS. `f(1 + v := 2 + 3)` obtains 5 from the assignment and passes
one actual 6; a standalone named actual is a different structural position.

Preserve short-circuiting and repeated loop-condition evaluation. A skipped
operand has no effects. A new iteration, call, or explicit eval is a new
evaluation; no permanent cache is written into the clean graph.

When emitting C, sequence effects to implement the LMX contract. Do not rely
on an unspecified C evaluation order to reproduce the chosen LMX order.

## 11. Import, copy, and merge

| Receiver | Argument role in every placement | Admitted sources |
| --- | --- | --- |
| `import` | CODE | One or more |
| `copy` | CODE | Exactly one |
| `merge` | CODE | Two or more |

All three receivers use the standard CODE argument algorithm in the translator
and interpreter, even when their records are written inside DATA. There is no
separate DATA-argument form or role-dependent source-processing branch.

Bare Structure references and anonymous Structure values are not calls:

~~~lmx
merge(A B)
merge((int: x 1) (int: y 2))
~~~

An explicit `Producer()` source is evaluated once when the receiver consumes it,
in ordinary order. This rule also applies to a receiver written in DATA; it does
not execute the record at P0 or replace it in the source graph.

Anonymous Structures can contain explicit calls and computed declarations. Apply
their normal contracts: the container is not itself an invocation, but grouping
is not a special quote that suppresses nested calls. Nor does it force every
initializer to execute eagerly.

Both copy and merge issue a field stream. Import issues eligible declarations
by reference. A standalone import contributes to the current namespace; a
nested import supplies its surrounding consumer without an additional hidden
import into the caller.

The import filter remains root const declarations as defined by ordinary DATA
reading. User Structure declarations are constant without explicit const.
A constant name created by fn can qualify; the receiver spelling fn is not the
imported declaration. Existing variable fields and separately nested descendants
do not become root imports.

Merge's first explicit source is its model. Overlay and slot preservation apply
only within that invocation. The receiving DATA context is never added as a
source or model. Separate operations supply separate streams, received under
ordinary declaration rules.

`f(copy(A))` supplies a stream. `f((copy(A)))` groups one structural result
before normal W/E. `struct := (copy(A))` assigns one structural result to an
admitting reference variable. Do not globally require or remove the extra group:
the consumer's intended material determines it.

Arity concerns admitted sources, not output fields. All three receivers retain
ordinary CODE-argument W/E in every placement, so a single written Structure may
supply several sources through E. The surrounding DATA context does not disable
that algorithm. Other receivers, such as fn and modifiers, retain their own
DATA-argument contracts.

One source-to-copy map spans each copy/merge operation. Preserve sharing, cycles,
references and required lexical chains through that map. Do not copy every
emitted field independently. Keep the admitted native and independent-immutable
terminal exceptions. A stream consumer is not a new lexical parent.

Copying nodes is distinct from rewriting the source receiver record. All output
reception and semantic transformation remains in namespace. The graph retains
the written import/copy/merge Frames.

## 12. Memory, explicit editing, and native code

Read a value's physical kind from its code, not from its address interval. The
interval structure is for ownership. A distinct physical kind uses a distinct
type code under the L2 enumeration; do not introduce ad hoc flag bits or
per-model type identities.

Structures and reference Arrays share the descriptor and variable-size storage
contract. Use descriptor/index element references where required for movable
backing. A numeric Array is not an Array of pointers to tagged values.

Own local assignments do not publish to the source graph. A transparent caller
place changes the selected caller execution place, and an explicit graph
assignment replaces the fragment at its selected structural place. These are separate admitted destinations, not stages of a
load-dirty publication protocol.

Do not restore load-dirty, work-flush tables, copy-back, automatic executable-graph copies,
edit watchers, automatic native invalidation, or hidden compilation. Keep the
physical storage and ordinary copy/collection machinery that the current
contracts still require.

Implement the [zero-payload `uninit` rule](docs/LMX_semantics.en.md#uninit-zero-payload):
`uninit:T` is its code only, with zero payload. No T cell or complete inner T
record is preallocated. `struct\novalue := 5` replaces `{uninit:int}` by `{int 5}`
at the addressed graph field. Remove tests that require in-place tag changes or
a stable raw payload address across this replacement. Assignment in the execution
frame remains independent of the clean source graph. P01 is closed; stable
Structure descriptors and descriptor/index Array-element references keep their
separate contracts.

Known native→native calls remain direct C calls. Hidden autofill values can be
ordinary parameters; transparent places carry the required cell address; the
retained fallback gives an own place. Native locals do not require artificial
arena record headers.

`sys\check` and `sys\checkL3` return diagnostics. `sys\translate` returns L1 and
errors. These operations do not run the application or `test`. `sys\compile`
performs clean-graph preparation, the required build/test phase, and the selected
translation/compile/registration operation. Build tests run through the ordinary
receiving contracts after the clean graph and before C generation; they may call
checkers/candidates but do not launch the graph's application entry or recursively
discover all nested DATA tests.

Keep admission stages distinct. Construction establishes known interface facts
without speculative user/default/test execution. Reached interpreter calls use
standard `implements`, with admission facts scoped to their operation/reception; prepared native calls have
no automatic runtime `implements`. Explicit `implements` is executed in either
path. Required checks at an actual reception and actual-value conversion checks
remain in force, without a blanket rerun after every write.

`sys\endturn` reaches the normal turn boundary through finally blocks, without
ordinary catch interception or returning to the call site; it does not compile,
check, or publish an edit itself.

Keep explicit helper operations in `sys`. `parent` and `length` retain their
ordinary public contracts. `sys\indexof` uses the common immediate-element
access for Structure/Array<@>; do not add a permanent reverse-index table just
to answer it.

## 13. Integration and focused acceptance

Use dependency-closed changes. Establish the physical/address contract needed
by the semantic change, implement the shared worker, and align interpretation
and translation before treating individual examples as proof of the whole
feature. Avoid a temporary compatibility behavior becoming an undocumented norm.

Migration of legacy source forms is semantic:

- An old separate DATA argument is not mechanically renamed to args.
- An executable fn/sub definition becomes an ordinary Structure arrangement;
  a fn requirement becomes `fn: name data`.
- A merge with only one admitted source becomes copy; do not rewrite a single
  written `merge(S)` before W/E.
- A result intended as one Structure is explicitly grouped.
- Multiple DATA merges remain separate operations.
- Declaration actuals remain executable descriptions, not eager initializer values.
- Import retains its root-const filter and uses CODE arguments in every placement.
- Operator implementations adopt left/right and explicit properties.

A minimal acceptance set covers:

| Area | Observations |
| --- | --- |
| Parser | Written groups, blank-line/root closure, paired delimiters, preserved source forms |
| Selection | W/E ambiguity, named cursor, no speculative effects, no hidden-input selection |
| Binding | Own values, transparent cells, fallback copies, both sides of private, lifetimes |
| Declaration actuals | Positional unknown inner names, named replacement, repeated step, body sees same local |
| Signatures | Positional types, public fn names, candidate names/defaults, whole-tree templates |
| Streams | Input count versus output count, grouping, empty output, no destination model |
| Graph copying | Aliases, cycles, parents, per-operation maps, admitted retained branches |
| Expressions | Prepared/raw modes, short-circuiting, demand order, repeated eval, numeric result type |
| Native/walker | Value, type, selected address and write destination across the applicable four combinations |
| Thread/mail | One transport, ownership attachment, publication boundary, supervision distinct from lexical parent |

Reuse the detailed acceptance tables of the primary documents: the observations of
[binding](docs/LMX_semantics.en.md#binding-observations), [callables](docs/LMX_semantics.en.md#callable-observations), [operands](docs/LMX_semantics.en.md#operand-observations),
[declaration arguments](docs/LMX_semantics.en.md#declaration-observations), [field streams](docs/LMX_semantics.en.md#field-stream-observations),
[Thread/Message](docs/LMX_semantics.en.md#thread-message-observations) and [blank-line closure](docs/LMX_grammar.en.md#levels). Record expected refusal, actual source inputs, reached values,
effect counts, diagnostics, and relevant addresses; a zero process exit is not
a substitute for those observations.

Use focused component checks for an isolated change. A full self-build or a full
suite has its own stage-boundary, ABI, format, or dependency justification; it is
not automatically required for every documentation edit or commit.

The maintained self-hosting kernel and its tests/build helpers are L2/L3 sources;
generated L1/C and the external C compiler/linker remain implementation artifacts
and host tools. Migration preserves assertions and actual native/walker
observations rather than wrapping an old helper in a new launcher.

For a genuine self-build acceptance, record two actual replacements G0→G1→G2,
the exact sources, toolchain and resulting artifacts. Do not infer it from one
successful translation or a binary comparison.

For this documentation packet, acceptance consists of integrated normative text,
consistent examples, current accepted supplements, and working archive-relative
links. It neither requires a repository render pipeline nor reports a runtime
gate as passed.

## 14. Handoff

Describe the concrete changes, their governing requirements, and the evidence
actually obtained. Keep implementation observations separate from intended
semantics. Do not alter an expected result solely to make a changed implementation
green.

The English packet is the current review edition. The accidentally supplied
Russian grammar is excluded at the author's request; a complete Russian edition
can follow after the English review. The author's requirements and supplements
are carried into the documentation in full; the documentation alone is the norm.
