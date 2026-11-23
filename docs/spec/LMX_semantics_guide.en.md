# LMX semantics: worked explanations

**Current extension:** [types, universal sequences, text patterns, and callable adapters](CORE_SEQUENCES_REGEX.en.md). The root specifications of this uploaded archive govern this edition; old contradictory spellings are superseded.

These worked explanations consolidate the accepted requirements through 2026-11-21. The
[semantics](LMX_semantics.en.md) and [grammar](LMX_grammar.en.md) define the language contracts.
Example results are required behavior, not claims of implementation tests.

<a id="data-receiver-execution"></a>
## Preparation does not execute the program

All receivers remain as written in the clean source graph. Computations, transformations, and acceptance of
receiver results happen exclusively in the namespace. Terminal primitive declarations use the direct
`{type value}` representation; this does not allow an arbitrary initializer to run during parsing or graph building.
Those leaves are part of the complete literal source graph, at the addresses referenced by Structure cells.
`for`, `if`, `merge`, `copy`, and `import` remain written structures just like other receivers. Ordinary explicit
graph assignment can replace them; when executable edits need recompilation, the existing compile/endturn
restart boundary applies. There is no separate uneditable executable graph.

The complete program is this graph plus a binary of compiled native methods. In the clean graph, `parent` and
`length` follow logically from the written source relationships, and the rest is in the Lmx pointer array and its
referenced records. The normal stored header remains; no per-read source reconstruction is implied. R0 is an
ordinary compiled C method with a local pointer to its R0 graph. The interpreter also uses that binary R0.

A call's namespace holds its ordinary local values, descriptions/references, and selected places; it is not a
materialized copy of the source program. Neither entering a call nor taking the interpreted path creates a
working graph under another name. Explicit user `copy`/`merge` results remain ordinary program-requested values,
distinct from an automatic shadow representation of every execution.
Root declaration discovery uses the ordinary DATA/CODE and modifier contracts without scanning arbitrary nested branches or following arbitrary graph references. When the consumer needs fields supplied by `import`, `copy`, or `merge`, it processes that receiver's explicit CODE sources through the common namespace algorithm. Such specified consumption can execute a written source call; it does not become a general pass executing the DATA body or expanding receivers in P0.

~~~lmx
mark()
int: y makeValue()
~~~

Preparation does not move `makeValue()` before `mark()`. The declaration executes when reached in CODE, or obtains
its value when the DATA contract demands it. A supplied ordinary actual suppresses the corresponding initializer;
a supplied declaration form preserves the form under the separate contract explained
[below](#declaration-arguments). See [call frames](LMX_semantics.en.md#call-frame-20261115).

<a id="blank-line-blocks"></a>
## Blank lines are full block boundaries

A blank physical line outside shielded content completes the current syntax block to the current document root,
using the same P0 completion mechanism as other admitted closers. It acts at virtual level −1; its indentation is
irrelevant. It creates no field, anonymous Structure, executable instruction, or return.

~~~lmx
First:
    Child:
        int: value 1

Second:
    int: value 2
~~~

First and Second are siblings. Within either continuing block, use consecutive nonblank lines; an indented line
after a blank cannot resume the closed body. A line containing a comment or level dots is not blank. Blank lines
inside a permitted literal or raw comment remain its contents. An unmatched internal paired delimiter causes an
error at the boundary; a blank line cannot supply its missing closer. Inside Mix, this closes only the local
document block and does not replace the enclosing Mix brace. EOF closes the last ordinary block without an extra
trailer. These are recognition/round-trip expectations, not a claim that a parser rewrite or runtime test has
already been performed. See [grammar §15](LMX_grammar.en.md#levels).

<a id="admission-stages"></a>
## Admission and build checks

| Stage or execution path | What happens |
|---|---|
| Graph construction, known candidate | Applicable interface requirements are checked without executing the candidate body, initializers, or `test`. |
| Build/test phase, after the clean graph and before C | Checks reached through the ordinary build/test receiver contracts execute; their checkers may call candidates. This is not recursive discovery of every nested DATA test. |
| Reached interpreted call | The interpreter invokes standard `satisfies` for admission, including the checks required at that receiving site. Concrete field maps and value-dependent admission facts remain scoped to their operation/reception. |
| Prepared native call | The prepared contract is used without an automatic runtime `satisfies` call. Required actual-value conversion checks retain their contract. |
| Explicit `satisfies` | The written operation executes in both native and interpreted code. |
| First required check returns `0` | That admission stops immediately; its remaining checks do not execute. |

Known interface facts do not waive checks required at an actual receiving site. They also do not imply that
every native store or graph edit reruns all tests. `sys\check`, `sys\checkL3`, and `sys\translate` do not execute
application code or tests; `sys\compile` includes its explicit build/test phase without launching the graph's
application entry. See [admission and test](LMX_semantics.en.md#admission).

The common kernel maintains a separate table of completed directed TYPE-pair checks. Stable full
requirements reuse their completed result under the applicable type/conversion context, including
between calls. This does not preserve a concrete field/namespace map or replace value-dependent,
range, lifetime, or access checks. An in-progress recursive pair is not a completed positive result.

<a id="callable-description"></a>
## Input description and composition

For a selected executable Structure C, the actual `parent(C)` supplies DATA. Explicit actuals are separate material;
`call(A C)` passes A as arguments and executes C itself. Code locals belong to the activation namespace.
A reference to C stored in another container does not reparent C.

copy and merge explicitly copy graph material and emit field streams. The receiving DATA context accepts these
through its namespace; it is neither an implicit source nor an extra model. The source receiver remains in the
graph. A named signature is declared as `name :: data` and checked by ordered input types and result, while an
ordinary structural template requires its entire explicitly described tree. See
[signatures](#fn-signature), [field streams](#field-streams), and [structural calls](#call-receivers).

<a id="receiver-arities"></a>
## Place and value with `int` and `@`

A place is declared by a receiver form enumerating its arguments. These are
separate examples, not consecutive statements in one program:

```lmx
int: x         # int place without an initial value
int: x 5       # int with value 5

@: ptr         # void reference without an initial address
@: ptr 0       # void reference with an explicit null address
@: ptr Model   # a reference to an existing Structure, no longer an empty void pointer
```

A first definition establishes the place; in code a repeated form with a
candidate writes after admission, and a repeated form without a candidate
only checks the requirement (in data a repeated form is one more occurrence
of the name, [names and paths](LMX_semantics.en.md#fields)). The composed forms with the place in the outer head —
`x: int()`, `x: int: 5`, `ptr: @()`, `ptr: @: 0`, `ptr: @: Model` — are
withdrawn by the author's decision of 2026-11-10
([semantics](LMX_semantics.en.md#receiver-args-only)): in data `ms: int: time`
declares a Structure `ms` with a field `time`, not a place `ms`.

For `int: x` without a value, the graph leaf is only the `uninit:int` code:
`sizeof(value) = 0`. There is no hidden int cell, inner int record, or reserved
payload waiting for its first assignment. The executing call can initialize its
own local x without changing that source leaf. An explicit graph assignment
`S\x := 5` instead replaces the selected `{uninit:int}` fragment by `{int 5}`.
This replacement does not promise an unchanged raw payload address. The same
distinction applies to other T; absence is not a zero value. [Semantics: zero-payload `uninit`](LMX_semantics.en.md#uninit-zero-payload).

<a id="header-receivers"></a>
## Header and service tables

Lmx's flat header contains parent/length/storage. `parent(S)`, `length(S)`, and `sys\storage(S)`
load these fields directly. `sys\native(S)` returns the native descriptor of variants from call's tables,
or 0; `sys\capacity(S)` returns reserved capacity from the arena table. All five no-argument forms
select the data of the current call; code requires an explicit argument. Reading neither compiles nor invokes native.

These receivers execute only in code; same-headed data forms remain ordinary data.
For example, the path `D\length` (`D` is the data Structure) selects a user field while `length()` reads the length
of the call's data. The parameters of `call` are named `args` and `code`; node keeps its existing meaning.

Structure and `Array<@>` are interchangeable; numeric `Array<T>` stores T elements. All arrays have variable
length and a common allocation mechanism. `sys\resize(S,n)` changes length; `sys\reserve(S,n)` changes reserve only.
Capacity belongs to an arena table, not the header. The descriptor address stays stable; storage may move.
In L2 an index, including a negative one, only computes an offset. In L3 adjacent [i][j] yield one linear
index and one length check; an L3 element reference contains the Array descriptor reference and index,
not storage. A raw L2 address is not repaired when storage moves.
[Contract](LMX_semantics.en.md#array-capacity).

<a id="get-descriptor"></a>
## Header-field addresses through descriptor

`sys\descriptor(S)` returns an ordinary Structure of three actual parent/length/storage field addresses:
Lmx **, size_t *, void **. Omitting the argument selects the data of the current call, including inside control bodies.
The result contains neither native nor capacity.

With d = `sys\descriptor(S)`, `\(d\length) := n` directly changes S's length; `d\length := p` changes
the pointer in d itself. The first example does not allocate storage; `sys\resize` performs a consistent
resize. There is no header copy, proxy, write-back, or special assignment.

Ordinary typed dereferences and paths permit reference/function-pointer writes; restricting changes
to a bare Structure name does not restrict a path. Pointer depth and array rank are arbitrary finite
values; address lifetime remains ordinary. [Exact form](L2_spec_en.md#get-descriptor).

<a id="system-indexof"></a>
## A field's index

`sys\indexof(field parent)` returns the physical index of the unique occurrence of `field` among
the immediate elements of Structure `parent`. An absent field or multiple occurrences of the same
reference produce an error under the ordinary failure rules.

`sys\indexof(field index parent)` selects occurrence `index` of that same reference, counted from zero,
and returns its physical index in `parent`. A missing selected occurrence is an error.
The occurrence number and returned index differ: when a reference occurs at positions 2 and 5,
`index = 1` returns 5. Both forms receive `parent` explicitly; there is no zero-argument form.

Lookup uses the field's identity/reference, not an equal name or primitive value. It follows neither
nested Structures nor graph references. Structure and `Array<@>` use one mechanism for reading immediate
elements. Reuse existing addressing; no reverse-index table or per-write maintenance is needed.

<a id="callable-admission"></a>
## What the callable interface check proves

An ordinary structural model requires every field and subtree explicitly written in that model. Additional fields
in the candidate are allowed under ordinary satisfies; they do not become extra model requirements. A model
that explicitly contains a lookup method requires that branch too. A minimal model containing only an input and
return does not invent a lookup requirement.

A named fn requirement instead compares the number and ordered LMX types of the callable's explicit inputs and its
result description. Parameter names, initializer values, and method-body trees are not comparison keys. Defaults,
required inputs, and throws still belong to the actual candidate and govern each concrete call.

For a used call interface, contracts with inputs (int: x; int: y 5) and (int: x) both permit `f(1)`, but the written
call `f(1; y := 25)` requires the former. This call-use check does not replace full-tree checking when a structural
model is explicitly supplied. User behavioral tests remain a separate admission stage.
See [admission](LMX_semantics.en.md#admission) and [named signatures](#fn-signature).

<a id="method-pointer"></a>
## A method name and a pointer to it

`myFunc()` directly calls a declared method. After `@: ptr myFunc`,
`ptr()` calls through the pointer; repeated `@: ptr otherFunc` in code
assigns another compatible method to that same execution place (in data a repeated
form is one more occurrence of the name). Bare `myFunc` or `ptr` only
reads a value. `(\ptr)()` calls after explicit dereference; `\ptr()`
applies `\` to the **result** of the call under ordinary precedence,
not through a special pointer-call rule.

<a id="native-structures"></a>
## Native and interpreter frames

The rules below consolidate the [binding and callable norm](LMX_semantics.en.md#binding-places),
including the named positional fn clarification. The interpreter, native paths, and their bridges must preserve the
same logical places and effects. Documentation examples specify acceptance behavior; they do not establish which
parts a particular repository build already implements.

<a id="call-receivers"></a>
<a id="structural-call"></a>
### Structural call: `call`, `C()` and `C(args)`

The selected Structure `C` is executed: it is read in the code role, and its data role is executed by its actual
parent `parent(C)`. There is no special word for data, no separate data parameter of `call`, and no substitution of
data by the call itself.

| Form | Executed | Actual arguments | Data |
|---|---|---|---|
| `call(C)` | `C` | not supplied | `parent(C)` |
| `call(A C)` | `C` | Structure `A` | `parent(C)` |
| `C()` | `C` | empty tail | `parent(C)` |
| `C(args)` | `C` | the written `args` | `parent(C)` |

The parameters of `call` are named `args` and `code`: the one-argument form requires `code`, the two-argument form
requires `args` and `code`, so `call(code := C)` does not fit the two-argument form. `call` executes the selected `C`
itself; a child field `code` is not searched for automatically. `args` is the Structure of actual supplied values,
exactly the argument Structure of an ordinary call: it is not formal declarations and not a signature. Input
places, requirements, and defaults are described by the data, that is, `parent(C)`.

Other data cannot be substituted by the call itself. To execute code over other data, first create a structural
link — a declaration, a copy, merge, under their rules about `parent` — and then call the selected occurrence.
`NewContainer: ExistingCode` stores a reference and does not change `parent`. The former `call(D C)` and `C(D)` no
longer substitute data: the first argument of the two-argument form is now `args`.

Every call — `call`, `C()`, `C(args)`, a call through a pointer — follows one interpreter path:
declaration selection → binding actuals to data → common admission → fresh namespace → execution and result.
Receiving actuals neither changes source data nor runs entry initializers. Calls from test and converters use the
same mechanism. Known native-to-native calls may still go directly through C without graph packaging.
[Full contract and named arguments](LMX_semantics.en.md#call-receivers),
[structural call](LMX_semantics.en.md#structural-call).

<a id="root-entry"></a>
R0 is a procedural entry without DATA and without user arguments. It receives no artificial D = C binding,
empty service Structure, or special field data. Its executable declarations and ordinary accessible references
remain available; runtime launch parameters are not user actuals.
See [R0](LMX_semantics.en.md#root-entry).

<a id="removed-builtins"></a>
Removed built-in meanings are the special data name, a separate call-DATA parameter, fncall, sub, and executable
fn. The former named signature receiver is also removed: `Name :: DATA` replaces it without a public `fn` alias. The word data can still be an ordinary user name or a role description. Reserved node remains the lexical
operator: `node\x` starts in the lexical space above the selected method and stays fixed throughout its activation,
including nested control bodies. It is not a general synonym for `parent(C)`, the current namespace, or the recipient
of a copied field stream. Use an ordinary explicit path such as `D\x` when that is the intended graph source.
See [names and paths](LMX_semantics.en.md#fields).

<a id="fn-signature"></a>
### Named fn signatures and ordinary templates

`Name :: DATA` is an ordinary expression-operand application. Its left occurrence is the declaration identifier, consumed without reading an existing value; its defined single-template form has one complete right DATA Structure. The declaration inspects that template's fields to describe the signature, without unwrapping the operand argument vector or executing nested forms.

`Name :: A B` has two right arguments; `Name :: (A B)` has one whole right Structure. The declaration identifier on the left is not an unnamed Structure, so the [conditional RIGHT-only opening](LMX_semantics.en.md#operand-right-only-opening) does not apply. `::` opens no extra Frame and creates no automatic `end: Name` target. It introduces a constant signature name and creates no executable body or native entry. `return` describes the result and is not an input; omitting it describes a procedure. The term fn-match below retains its positional compatibility meaning, not a public receiver named `fn`.

~~~lmx
SumSignature :: (int: a; int: b; return: int)

SumContext:
    int: lhs
    int: rhs
    return: int
    sum:
        return: lhs + rhs

SumSignature@: sumPtr SumContext\sum
~~~

The typed head `SumSignature@` supplies the requirement; its two fields are the reference name
and actual candidate. The ordinary universal-reference initializer `@: p Model` instead
initially refers to Model itself; it does not select a separate implementation.

The candidate's DATA is still SumContext. Fn-match compares two int input positions and an int result, so lhs/rhs
may differ from the signature's a/b. A call through the typed reference uses its public labels:

~~~lmx
sumPtr(b := 3; a := 2)
SumContext\sum(rhs := 3; lhs := 2)
~~~

Both return 5. The first maps b → position 2 → rhs and a → position 1 → lhs. Each RHS is evaluated once in written
order, so a call that supplies effectful b before a keeps that effect order. Naming at the current formal position
keeps the positional counter enabled; naming out of position disables it, after which all actuals must be named.
The map does not rename the candidate or give its own formal names a second public alias.

For mixed types, order matters:

~~~lmx
SelectSignature :: (int: count; char[]: text; return: int)
~~~

A candidate with inputs int then `Array<char>` can match even with different names. A candidate with `Array<char>`
then int fails fn-match even if its names match count/text and a direct named call could supply them in reverse.
Optional inputs still occupy signature positions. Hidden native arguments, free dynamic names, and code locals do
not. Candidate defaults, required, throws, and hidden binding use the candidate's real declarations and names;
defaults written in a fn template are neither compared as values nor copied into the candidate.

The contrast with an ordinary minimal model is explicit:

~~~lmx
PrioritiesTemplate:
    char[]: name
    return: int

PrioritySignature :: PrioritiesTemplate

PriorityProvider:
    char[]: query
    return: int
    lookup:
        return: sys\priority(query)

PrioritySignature@: priorityCall PriorityProvider\lookup
~~~

PrioritySignature accepts lookup by its one `Array<char>` input and int result. In executable context,
`priorityCall(name := "+")` maps name to the candidate's query. Ordinary satisfies with PrioritiesTemplate instead
checks all of that model's named fields. If lookup and a subtree were explicitly added to the model, they would
also be required; fn comparison does not silently erase them. The shown `PriorityProvider` has `query` rather than `name`, so a structural requirement for `name` is not satisfied merely by a positive fn-match. The template is never substituted for the selected method's parent.

A structural result is described normally inside return, for example:

~~~lmx
PairData:
    int: count
    return:
        int: x
        int: y

PairSignature :: PairData
~~~

In `PairSignature :: PairData`, the left occurrence is the declaration identifier and the single right occurrence is the whole DATA template. Reading its input/result fields is not argument unwrapping. Ordinary-call CODE W/E does not expand that template or execute its nested forms.
[Full contract](LMX_semantics.en.md#fn-signature).

<a id="return-in-data"></a>
The result is described by the field `return` in data: `return: int` or a nested block. This declaration assigns
nothing and is not a shared mutable cell of recursive activations. In code `return` is the return receiver: `return`
without a value is preserved, `return: value` passes the result to where it is described, and reaching the end of the
code does not create a `return`. Both `call` and an ordinary Structure call may return a value; the former ban "a
Structure launch has no result" is lifted together with `fncall`. `catch` is brought to the same model of data and
call while keeping the semantics of the handler: it does not disappear together with `sub` and does not become an
ordinary function.
[named signature](LMX_semantics.en.md#fn-signature), [`return` in data](LMX_semantics.en.md#return-in-data),
[`catch`](LMX_semantics.en.md#catch-common-model).

<a id="declaration-selection"></a>
### Declaration selection: readings W and E

First the ordinary rules resolve the name of the callee and the set of its visible declarations; then a declaration
is selected only from the explicitly supplied material; then the selected variant is executed and implicit binding is
applied. The unit of selection is (a visible declaration, a reading of the explicit actuals, a map actual → formal).
There are two readings, and they are equal:

- W — "as written": the explicit actuals are matched to formals in the supplied form.
- E — "the single Structure expanded": exactly one actual is supplied, it is a Structure or a reference to one, and
  it is not supplied by an assignment to a formal; its immediate fields form the sequence of actuals. The expansion
  is performed once, one level deep, and the graph does not change. `f(arg := S)` creates no reading E.

There is no preference for a whole Structure, for arity, or for the first declaration found; E is not tried after W
fails. No candidates — a refusal; exactly one — it is executed without a second expansion; more than one — an
ambiguity error. Selection executes nothing: no assignments, no defaults, no `test`. Autofill, the caller's place, and
the former binding do not take part in selection, do not rescue a rejected candidate, and do not restart selection.
This replaces the rule of 2026-11-18 "expansion is an attempt to find other signatures; a signature with one argument
expands nothing".
[Full contract](LMX_semantics.en.md#declaration-selection).

<a id="selection-examples"></a>
The contract notation in the table is analytic: it is not a new grammar for declaring overloads.

| Conditions | Call | Result |
|---|---|---|
| `f(int a)` and `f(int a; int b)`, `b` optional | `f(5)` | two variants, an error |
| `f(int a)` and `f(int a; required int b)`; the caller's `b` exists | `f(5)` | the first; the caller's `b` does not rescue the second |
| the same contracts | `f(5; 6)` | the second |
| only `f(required int b)` without a default; the caller's `b` exists | `f()` | no variant |
| only `f(required int b = 9)` | `f()` | the own default is admissible |
| only `f(int a; int b)`; the caller has `b = 6` | `f(5)` | selection without `b`; then an admissible autofill may fill `b` |
| `S` as a whole fits one formal; E does not fit | `f(S)` | W; `S` is passed as a whole |
| `h(int x)`; `Arg` contains `int: x 9`, whole `Arg` does not fit | `h(Arg)` | E with one field; `h` receives 9 |
| the fields of `S` fit two formals; whole `S` does not fit | `f(S)` | E; the selected fields are passed |
| W and E fit one declaration | `f(S)` | two resulting variants, an error |
| W fits one declaration, E another | `f(S)` | an error, no priority between them |
| `S` is explicitly assigned to a formal | `f(a := S)` | W only, no E |
| whole `C` fits `call(code)`, the fields of `C` fit `call(args code)` | `call(C)` | an ambiguity error |
| the same `C` is explicitly supplied as `code` | `call(code := C)` | no expansion; hidden `args` creates no second form |
| A named signature uses a nested data template | `SignatureName :: DataTemplate` | Left declaration identifier and one whole right DATA template; field inspection is not operand unwrapping, and CODE W/E does not apply |

[The table in the semantics](LMX_semantics.en.md#selection-examples).

<a id="binding-places"></a>
### Binding: own place and the caller's place

An own declared place of the callee receives its value in this order: an explicit actual → its own ready value or the
description of its initializer → [autofill](#binding-autofill) with the value of the caller's same-named local place →
the ordinary uninitialized state and the existing `required` checks. Autofill is forbidden if the receiving place is
`private` or the selected source is `private`; a ready initializer is not replaced automatically by a same-named
local, and an explicitly supplied `0` is not an omission.

A used external name without an own active declaration is bound as follows: if the really visible lexical source is
`private`, the lexical link applies and there is no dynamic substitution; otherwise — the
[transparent caller place](#binding-caller-place); otherwise — the [former binding](#binding-fallback) (fallback).
In every case `x` in the language is an ordinary variable of its own type `T`; the hidden address is a detail of
the native implementation, and `x` does not become `@T`.

Four cases on the same values: the caller's `x` is 5, and the callee writes `x := 9`. `Ctx` has an own declaration of
`x`; `Free` has none.

```lmx
Ctx:
    int: x
    code:
        x := 9

Top:
    explicit:
        int: x 5
        Ctx\code(x)
    autofill:
        int: x 5
        Ctx\code()
```

```lmx
Free:
    code:
        x := 9

Mid:
    run:
        Free\code()

Caller:
    transparent:
        int: x 5
        Free\code()
    chain:
        int: x 5
        Mid\run()
```

| Case | Call | `x` in the callee on entry | the caller's `x` after `x := 9` | `@x` addresses |
|---|---|---|---|---|
| explicit actual | `Ctx\code(x)` | 5 | 5 | the callee's own place |
| autofill | `Ctx\code()` | 5 | 5 | the callee's own place |
| former binding (fallback) | `Free\code()` from `Mid\run()` | 5 | 5 | the own working copy in the callee's frame |
| transparent caller place | `Free\code()` from `Caller\transparent` | 5 | 9 | the caller's place of `x` |

In all four rows `x` has one type `int`; the transport pointer is not visible in the language.

<a id="binding-autofill"></a>
**Autofill.** The receiving place is declared but not filled, and there is no actual: it receives the value of the
caller's same-named local place. This is its own cell, not an alias, so the write `x := 9` is not visible to the
caller.

<a id="binding-caller-place"></a>
**Transparent caller place.** There is no own declaration and the visible lexical source is not `private`: reading,
`x := v`, and `@x` act on the caller's place. The write is immediate, with no copy "on exit"; if the caller's place
was `uninit:int`, its initialization state changes too. The link does not extend lifetime.

<a id="binding-fallback"></a>
**Former binding (fallback).** If there is no new source, the former sources apply and the value goes into an own
working copy in the callee's frame: a write changes the copy, not the original place, and the copy is never an alias.
For a reference, the reference is copied, not the object. Two substitutions are forbidden: the transparent place must
not be replaced by a temporary copy with copy-out on exit, and the fallback copy must not be replaced by the address of
the source. The number read may coincide; the place written does not.

<a id="binding-chain"></a>
**The chain A → B → C.** `A` has `x`, `B` does not use it, `C` does: reachability is preserved, `B` needs neither an
explicit argument nor a dummy local, and there is no static transitive accumulation of hidden requirements. If the
fallback applied, `C` receives its own value, as in the third row of the table. If `B` has its own copy of `x`, a
write by `C` to the place `B.x` changes `B.x` but not `A.x`; if `B` has a transparent link to `A.x`, passing the place
`B.x` preserves the address of `A.x`.
[Binding order](LMX_semantics.en.md#binding-places), [autofill](LMX_semantics.en.md#binding-autofill),
[caller's place](LMX_semantics.en.md#binding-caller-place), [fallback](LMX_semantics.en.md#binding-fallback),
[chain](LMX_semantics.en.md#binding-chain).

<a id="private-binding"></a>
### Receiver private: in both directions

`private` is an ordinary receiver already present in the clean graph. Recognizing it does not require another
annotated graph in the binary. Compiled methods reflect the binding rule; a copied program carrying privacy or
initialization flags would restore the removed working graph, not implement a necessary local variable.

Two-way `private:` forbids the implicit dynamic participation of a specific declaration in both directions — for autofill, the
transparent caller place, and the preserved dynamic part of the former binding:

- source: a `private` place of the caller is not implicitly offered — neither as a value nor as a place;
- receiver: a really visible `private` declaration of the callee's lexical context is not overridden by a value or a
  place from the dynamic context.

Checking only the `private` of the source is not enough: before accepting an external dynamic binding, one must
establish which lexical declaration is really visible and whether it is protected. Not forbidden: explicit passing,
explicit filling of a receiving `private` place with an actual, nested lexical visibility, explicit paths and `node`,
a new inner declaration shadowing an outer `private`. `private` does not replace `const`/`immutable`: whether a write
is admissible is decided by the contract of the real target. It is a filter of a specific place, not a barrier of the
name and not an access check on every explicit path: a `private` source is skipped and the search goes on, and the
`private` of an outer declaration does not close a new public inner `x`. The graph record `S\private\field` is not
flattened.
[Full contract](LMX_semantics.en.md#private-binding).

<a id="private-examples"></a>
Source; the callee `Ctx` is the same as above:

```lmx
Top:
    hidden:
        private: int: x 5
        Ctx\code()
    given:
        private: int: x 5
        Ctx\code(x)
```

In `hidden` the `private` value is not offered: `x` of `Ctx` stays in the ordinary state without a value on entry. In
`given` explicit passing is allowed: `x` of `Ctx` is 5 on entry.

Receiver; the caller has a public `x = 11`:

```lmx
Closed:
    private: int: x
    return: int
    code:
        return: x

Outer:
    private: int: x 7
    Ctx:
        return: int
        code:
            return: x

Top:
    ownPrivate:
        int: x 11
        int: r Closed\code(x := 20)
    lexicalPrivate:
        int: x 11
        int: r Outer\Ctx\code()
```

In `ownPrivate` an explicit actual is allowed: `r` is 20; without it autofill with the value 11 is forbidden. In
`lexicalPrivate` the nested `code` reads the private declaration of `x` in `Outer` lexically and there is no dynamic substitution:
`r` is 7, not 11; an explicit path `Outer\private\x` reads the same graph field. Without `private` on that declaration the free `x` would be bound
by the general order, to the caller's place. [Examples in the semantics](LMX_semantics.en.md#private-examples).

<a id="shadowing-levels"></a>
### Shadowing of levels

The author's rule in the section on [declaration levels](LMX_semantics.en.md#shadowing-levels) is:

> A declaration at a nested level shadows the outer declaration of the same name. At one level there is nothing to
> shadow; the parent one is used.

The rule is applied through the owner of the declaration and the lexical scope, not through a coincidence of a string
anywhere in the body. An inner `Text x` shadows an outer `int x`: this is not a write of `Text` into the outer `int`
cell, and after leaving the inner scope the outer one is visible again with its own place, write mode, and `private`.
At the same level there is nothing to shadow: repeating a declaration works with the already existing place under the
receiver contract — a new right-hand side is evaluated and assigned, the absence of a right-hand side does not zero
the value, and there is no second cell. Sequential visibility is preserved: a use of `x` before a later own
declaration is resolved in the ordinary way through the outer context.
[Shadowing of levels](LMX_semantics.en.md#shadowing-levels).

<a id="inline-declaration-control"></a>
The [control example](LMX_semantics.en.md#inline-declaration-control) asks for this derivation:
the current frame has outer x = 5; a nested inline block declares a new int: x with no RHS/default; there is no
new callable invocation and the actual caller has no x. The new inner place is `uninit:int`. A lexical inline
scope does not become a new caller for autofill, so the outer local 5 is not implicitly copied into the new
declaration. A reached required check refuses the absent value; declaration alone supplies no zero. After
leaving the inner scope, the original outer x is still 5. This follows from the common caller-source and
shadowing rules, without an added initialization pass or another author decision.

<a id="call-frame-20261115"></a>
### The call frame

A normal independent call has a fresh namespace. Its input descriptions come from the actual parent of the selected
code Structure; actuals and code locals are accepted by the common mechanism. Root declaration discovery uses the ordinary DATA/CODE and modifier rules and adds no fields to the source graph. Required `import`, `copy`, and `merge` contributions are consumed through their ordinary CODE-argument algorithm in the namespace; this explicit source processing is not arbitrary traversal or eager execution of all DATA contents. An ordinary actual fills
the corresponding logical place and suppresses its initializer. A declaration-receiver actual instead preserves its declaration form and supplies it as one Structure, as described [below](#declaration-arguments).

There is no eager initializer pass. An unused computed DATA input does not run. When its selected namespace place
is first needed, the common mechanism evaluates the stored initializer and retains the value in that activation's
place. Later reads use that place's current value rather than invoking the initializer again; an executed repeated
declaration can explicitly obtain and assign a new value. A resulting reference does not automatically call its referent. For @: fptr `getFuncPtr()`, the explicit call `fptr("hello world")` first obtains the pointer as
needed and then calls the selected function. A direct source path `D\field` only inspects the written source record;
it neither obtains a transformed namespace result nor runs a receiver.

Variables and const become visible sequentially in their scopes. Structure/callable declarations retain
bidirectional visibility; a function-pointer variable does not. A new branch local does not escape the branch.
In CODE, a reached same-level declaration int: x `bump()` evaluates/adopts the new RHS and updates the same place.
In DATA, repeated physical declarations remain separate occurrences addressed with `S\[n]x`.

Bare x and `@x` select the place established by binding: an own place for an ordinary actual, autofill, or preserved
fallback, or the caller's real place for transparent binding. Own selected values/descriptions remain independent
of later source-field replacement without deep-copying referenced objects. A write to an own local has no copy-out;
a write through transparent binding changes the caller's place immediately. Explicit `D\x` := value replaces
the fragment at the addressed graph place under the normal type and write restrictions. Subsequent access to
that structural field sees the new fragment; a reference to the previous fragment is not automatically retargeted.

For a computed namespace input int: x `next()`, `@x` obtains its value and the local cell's address. By contrast,
`@D\field` with source int: field `getValue()` addresses the original declaration record, not the result of
`getValue()`. Terminal primitive places are already direct typed values. Address-taking never extends lifetime.

<a id="declaration-arguments"></a>
### Passing a declaration form for repeated execution

A place-declaration receiver supplied in a CODE argument context is read as DATA. Passing it preserves the written
form without running its initializer. The only special part of the rule is that a supplied declaration is a DATA Structure and is not executed as a call; everything else is the ordinary supply of an actual. It is distinct from an ordinary `Producer()` or Producer: tail call, whose head
is not a place-declaration receiver and which remains a call in CODE.

| Supplied form | Matching rule | Accepted material |
|---|---|---|
| A declaration written as a positional actual | One Structure at the current position, whatever name it declares | The whole form, with its internal name unchanged |
| An outer name := form is present | Outer name selects the formal | The form on the RHS keeps its own internal name |

For inputs a then b, `g(int: b producer())` supplies the declaration to a, the first position; the name b inside it does not address the input b,
and producer is not evaluated during supply. For inputs iteration then body, the first argument below is one Structure for iteration whether or
not an input item exists; item is not an unknown named actual and does not disable the positional counter.

~~~lmx
cycles:
    @: iteration
    @: body
    iterate:
        while: 1
            iteration()
            catch: Stop ()
                break
            body()

use:
    import: cycles
    run:
        iterate: int: item numbers\next()
            item *= 2

use\run()
~~~

Here numbers is an available external iterator whose `next()` returns an integer or throws Stop. Its position lives
in that iterator. Import exposes constant iterate, an intrinsically constant user Structure; the mutable
iteration/body inputs stay in its original parent cycles.

iteration retains the accepted declaration form. Each reached `iteration()` executes it again. The first execution
establishes item at the root of the receiving execution; later executions update that same place by ordinary
same-level redeclaration. This logically supplements the receiving CODE root in its namespace; it does not add
fields to that source CODE, reparent the form, or replace the stored form with the last value.

The supplied body physically belongs to the original argument Structure containing the item declaration, not to
the library definition. `body()` reads and changes the established receiving item without a new isolated item or
an extra `next()` call. True nested scopes inside either form still shadow normally. Independent receiving
executions have their own contexts, and saving a form does not extend an expired activation's lifetime.

| Iteration | Step | Body |
|---|---|---|
| First | `next()` returns 10; item becomes 10 | Same item becomes 20 |
| Second | `next()` returns 20; same item becomes 20 | Same item becomes 40 |
| End | `next()` throws Stop | Body is skipped |

There are three next calls and two body calls. The catch scope covers the whole loop iteration, including body,
under the existing handler rules.

The equivalent named supply, in CODE with iterate available, is:

~~~lmx
iterate(body := (item *= 2); iteration := int(item numbers\next()))
~~~

It supplies body first but does not execute it before the step; iterate controls subsequent execution.
Both actuals are named after the first out-of-position name disables the counter.
`iterate(iteration := int(item numbers\next()); (item *= 2))` keeps the counter enabled after the on-position name.
A first body := ... followed by an unnamed actual is rejected. A present empty body () is one Structure, not a skip.

Through a fn-typed reference the same public-name → position → candidate-place map applies. It selects the
receiving place without changing the declaration's internal name or prematurely evaluating its RHS.
[Declaration arguments](LMX_semantics.en.md#declaration-arguments).

<a id="binding-executors"></a>
Mandatory copying of executable code at entry is withdrawn, including the former copy of only
the corresponding C function's code. Selected local values/descriptions remain independent, and there is no
environment copy. The four combinations native → native, native → interpreter, interpreter → native, and
interpreter → interpreter give one observable behavior: autofill is lowered as a parameter `T`, the transparent
caller place as the hidden address of the cell, and the fallback gives an own place; a native local place has no
arena header `[type][value]`. Methods and ordinary Structures share compilation; distinct actual supplies produce
distinct C signatures. Known native calls known native directly in C. Graph writes do not clear native: updating it
requires explicit compilation and an endturn boundary. Before that boundary the time at which executable graph
changes take effect is unspecified. There is no hidden compilation, permanent cache of source-expression results,
shared local-publication cache, or copy-out on exit. Ordinary activation values and scoped admission correspondences
retain their separate contracts. A transparent link does not extend lifetime, and at `yield` the selected link
is not rebound to the same-named place of a new caller.

Local frames are not published. Load-dirty, the shared direct-access cache, and `flush()` are cancelled;
explicit writes are observed through actual aliases in execution order.
[Agreed norm](LMX_semantics.en.md#call-frame-20261115),
[executors](LMX_semantics.en.md#binding-executors),
[binding decisions](LMX_semantics.en.md#binding-decisions).

<a id="flush-receiver-contract"></a>
<a id="direct-access-cache"></a>
The old `flush()` and shared-cache examples are withdrawn: only explicit operations change the source graph;
local variables are never written back.

<a id="native-merge"></a>
## Compilation, mutation, and the next turn

Native descriptors for executable Structures belong to call tables in the arena. A named fn description creates
no native entry. Known native calls may remain direct C calls with appropriate value/place parameters.
Copying a method occurrence and reusing a compatible machine implementation are distinct operations.

copy and merge retain permitted reusable native implementation references under the existing contract. They do
not implicitly compile a new implementation or register a call-table binding; explicit compilation or restoration
establishes the binding. A common implementation address does not replace the selected occurrence's lexical links.

`sys\compile(S)` builds/checks the clean graph, runs the required build/test phase before C generation, translates
to L1/C, compiles/links machine code, registers a successful result, and returns diagnostics. That test phase may
execute checkers and their candidate calls; it does not launch S's application entry or scan all nested DATA for
tests. `sys\check`, `sys\checkL3`, and `sys\translate` execute neither application code nor `test`.
Graph writes neither clear native nor trigger hidden change tracking.
If A directly calls B, updating that call requires compilation of the unit containing the relevant caller/callee
code, rather than assuming that recompiling B alone changes A's direct call.

`sys\endturn()` exits through registered finally blocks to the normal turn boundary. Catch does not intercept it;
control does not return to its call site, and it does not itself terminate a Thread/Message.
Before the boundary, the time at which executable graph edits become effective is unspecified.
Successful explicit compilation followed by the boundary guarantees the update at the next entry.
Endturn alone compiles nothing and publishes no locals.
[Compilation contract](LMX_semantics.en.md#explicit-compilation).

`sys\toLmx(Thread)` saves the selected Thread and serializable contents of its arena tables, including native/call
tables. After a same-platform restart, module/entry identifiers allow ready binaries to be reused without
retranslation. Tables are not silently added to arbitrary S; R0 is one particular Thread, not the only persistent
root.

<a id="field-streams"></a>
## Import, copy, and merge supply fields through the namespace

These receivers process only their explicit admitted sources. All three always use the ordinary CODE argument algorithm, independent of whether their result is consumed in DATA or CODE. A DATA placement does not make their source arguments DATA.

| Receiver | Argument role in every placement | Number of admitted sources | Output |
|---|---|---|---|
| `import` | CODE | One or more | Selected root constant declarations by original reference |
| `copy` | CODE | Exactly one | Copied fields |
| `merge` | CODE | Two or more | Composed fields |

The source record remains intact. DATA acceptance uses the namespace and does not replace an import/copy/merge
Frame with physical output fields in the clean graph. A terminal primitive declaration is represented there
as `{type value}`; it remains part of the full source. An unevaluated RHS remains its written form.

~~~lmx
Struct:
    merge(A B)
    merge(C D)
    copy(E)
~~~

Struct is an ordinary DATA declaration. The first merge composes A and B using A as its model; the second
independently composes C and D using C as its model; copy has only E. Their streams are accepted in source order.
Struct is not an implicit source or model, and the three operations do not share one hidden copy map. Their bare A/B/C/D/E references are source values, not implicit calls. Anonymous Structures work through that same algorithm:

~~~lmx
Struct:
    merge((int: x 1) (int: y 2))
~~~

The two groups are structural values, not calls merely because they are anonymous containers. Their contents can still contain explicit calls and computed initializers, processed under the ordinary contracts when needed. Grouping is not a special quotation mechanism that suppresses those calls, and CODE argument processing is not a blanket eager-initializer pass. These receivers use the same common algorithm without a DATA-argument variant.

Inside one merge, compatible overlapping fields replace values in the first source's model slots, preserving
their indices; new fields append. Across independently supplied streams, collisions use ordinary DATA
redeclaration/occurrence rules, not merge overlay. For example, an already written `int: x 1` in `Struct` does not
become a model slot of `merge(A B)`.

The short form `Struct: merge(A B)` has the same meaning as its vertical form. It does not introduce a special
“declaration by merge” syntax. `Struct: Existing` keeps its ordinary reference field and does not assign or expand
Existing.

<a id="stream-grouping"></a>
### A field stream and one explicitly grouped Structure

~~~lmx
f(copy(A))
f((copy(A)))
f(arg0 := (copy(A)))
~~~

The first supplies the copied fields to f's argument consumer. The second uses a written group to collect one
Structure; f then still applies ordinary W/E selection. The third supplies that whole Structure to actual formal
arg0, suppressing E. Groups survive even when empty or single-field: `copy(Empty)` gives zero fields, whereas
`(copy(Empty))` gives one empty Structure.

For an already declared compatible reference variable:

~~~lmx
struct := (copy(A))
struct := (merge(A B))
~~~

The grouping expresses one structural result. Ungrouped `struct := copy(A)` remains a stream consumed by ordinary
assignment rules; it is neither automatically the former single-container assignment nor automatically a syntax
error. A Structure declaration's name does not become assignable.

Ordinary CODE W/E applies to the source arguments of all three receivers in every placement, including inside DATA. Arity is checked after ordinary selection:
`merge(S)` is not forbidden by P0 merely because one source is written, since E may supply two or more admitted
sources. If W and E both fit, the result is the usual ambiguity error; import has no hidden preference for W.
The ordinary named-signature expression `Name :: DATA` separately reads its one right template in the DATA role. This declaration contract does not turn the source arguments of import, copy or merge into DATA arguments merely because their output is accepted in a DATA context.

~~~lmx
(a b) := (copy(Pair))
(c b d a) := (a b c d)
~~~

Group assignment is positional. Its right side is one unnamed Structure in parentheses, the form `() := ()`:
several values without the group are an error. A field stream is written inside the group; the bare stream
`(a b) := copy(Pair)` is an error, and a Structure returned from a function is not opened (author's decision,
2026-11-21). All RHS values are obtained before the first write, and a count mismatch is
reported before any LHS write. With initial a=1, b=2, c=3, d=4, the second line gives c=1, b=2, d=3, a=4.
This read-before-write rule does not promise rollback of already performed RHS effects.

<a id="import-selection"></a>
### Import keeps original identities and parents

~~~lmx
Library:
    const: int: limit 10
    int: counter 0
    Settings:
        int: width 2
    PrioritySignature :: (char[]: name; return: int)

Other:
    Tool:
        int: value 3

Use:
    import: Library Other
~~~

Use's namespace receives limit, Settings, PrioritySignature, and Tool. User Structure declarations are
intrinsically constant without an explicit const. `Name :: DATA` declares a constant signature name under the same rule.
The mutable counter is not imported, and nested width/value are not lifted to the root. Root status follows the
ordinary DATA rules, including modifiers; it is not restricted to direct physical children.

Import preserves declaration identity, contents, original references, and parent. An imported method keeps its
original DATA parent. A constant Structure name does not make all its fields immutable. Repeated imported names
use ordinary redeclaration, not a special last-source-wins or merge rule.

`import(A Producer())` uses CODE arguments in every placement. A is a bare reference value; the explicitly written `Producer()` is called once when the source argument is consumed, and the returned source is filtered by the same constant-declaration rule. This also applies inside `Use: import(A Producer())`: parsing and source-graph construction do not eagerly execute the call or replace its receiver. Multiple computed sources keep left-to-right evaluation with no rerun during selection. `copy` and `merge` use this same ordinary argument algorithm.

A standalone import supplies its declarations to the current namespace. In `f(import(A B))`, the surrounding
argument consumer receives the stream; the caller namespace gets no second hidden import.
`f((import(A B)))` explicitly groups it, with ordinary W/E at f.

<a id="copy-relations"></a>
### Copy maps preserve graph relationships

Each copy/merge operation has one source-to-copy map spanning all its sources. Shared targets stay shared and
cycles stay cycles. Ordinary references and parent links are redirected to the corresponding copied nodes,
including necessary lexical chains. Fields are not copied as unrelated little graphs merely because output is a
stream. Grouping that stream neither starts a second copy nor redirects references back into the source graph.

The existing source domain includes admitted reference Arrays as well as Structures. Mutable fields are copied;
they do not disappear under import's const-only filter. Qualified independent: immutable branches and reusable
native implementation references retain their established exceptions. Access, ownership, and lifetime remain
ordinary. Separate receiver applications have separate maps.

Accepting copied fields does not redefine node as the stream recipient. Copied methods retain the lexical
relationships established through the copy map, and dynamic/lexical binding order stays unchanged.
The grouping container is a different Structure with its own slots, distinct from the copied lexical owner's
slots. Corresponding slots can refer to the same copied fragment without becoming one assignment destination.
Replacing the group's slot does not replace the owner's slot. To change the DATA or lexical state used by a
copied method, address its actual owner and intended field. When two routes follow a shared reference into
the same nested Structure, they can still reach that nested Structure's same slot.

Import supplies the original eligible declarations and preserves their original owners. Copy and merge
deeply copy the used graph and preserve the corresponding copied owners through one operation map.
Grouping either stream supplies a distinct container with its own cells; it neither performs another deep
copy nor becomes the lexical owner of the received methods.
[Composition](LMX_semantics.en.md#composition),
[field-stream observations](LMX_semantics.en.md#field-stream-observations).

<a id="factory-result"></a>
## A returned method and a copied product

In CODE, `@: add5 makeAdder(5)` explicitly calls the factory and stores its returned method;
`add5(1)` then calls through that reference. In DATA, `add5: makeAdder 5` is an ordinary Structure declaration and does
not run makeAdder. A returned method's free names use the general [binding order](#binding-places);
explicit node paths retain lexical meaning.

The following complete factory example uses copy for its one source and a written group for one returned product.
Blank lines close the three root declarations; none occurs within a continuing declaration.

~~~lmx
Product:
    int: payload
    return: int
    read:
        return: payload
    create:
        return: Product
        small:
            node\payload := 10
            return: (copy(Product))
        large:
            node\payload := 20
            return: (copy(Product))

add1:
    @: product Product
    return: int
    execute:
        return: product\read() + 1

Demo:
    return: int
    run:
        import: Product add1
        int: first execute(create\small())
        int: second execute(create\large())
        return: first + second
~~~

If the call `Demo\run()` is written in the same source right after `Demo`, a blank line separates it from the declaration. In executable context, `Demo\run()` is expected to return 32. A product retained after small reads 10; one retained
after large reads 20. These are acceptance expectations, not reported runtime results. The group collects the
copied field stream as one returned Structure under return's ordinary contract. The copy map preserves methods,
their lexical data, and shared internal references. The original Product graph still holds the written receivers;
explicit `node\payload` writes have their normal graph-write contract. The stream recipient does not become node.

<a id="dynamic-fallback"></a>
## Dynamic and lexical sources

This is not LMX syntax: a copied lexical context has `x = 10` and the
caller supplies `x = 25`. Free `x` reads 25; explicit `node\x` reads 10.
On a later call with `x = 40`, free `x` reads 40. With no dynamic source,
it reads the lexical 10. This is the general [binding order](#binding-places): a free `x` without an own
declaration takes the caller's place (a write to it changes the caller's `x` at once), and without such a source the
former binding gives an own copy.

<a id="message-conversion-context"></a>
## Message conversion context

The scheme `a → int` in Message A and `a → String` in Message B is not
LMX syntax. One method requiring `a` receives meaning from the current
Message; B does not inherit A's conversions merely through delivery.
A primitive `Foot → Meter` conversion does not establish `satisfies`
for two arbitrary Structures. A call may need distinct routes for its
`int → double` argument and `double → int` result, both available in that
Message's context.

<a id="post-transport"></a>
## post: one call, multiple deliveries

Three `getPixel` requests execute three times. If each result has three
`answer` destinations, that is three original replies and nine deliveries,
not nine executions. The source Message, not a branch position or new numeric
ID, correlates reply and request. Prepare `answer` before sending `ask`;
one undelivered request does not stop the others.

`undelivered` receives the source request's already formed arguments;
a declared failure goes to `catch`. Timeout starts at the original send:
a 500 ms threshold may yield an observed 512 ms while its threshold field
remains 500. A late reply is not automatically discarded. The full contract
and the [T01–T26 matrix](LMX_semantics.en.md#thread-message-observations) are in the
[semantics](LMX_semantics.en.md#thread-message-api).

<a id="tables-and-registries"></a>
## Tables and providers as data

An explicit Table can provide a spelling `u8 → "uint8_t"` or an
implementation key `plus[decimal][int] → decimal_int_add`. It does not
declare types, create a runtime namespace, or search providers automatically.
Source precedence, conflict resolution, and a missing-cell marker belong to
the profile selected by the Table's consumer, not a universal hidden registry.

<a id="expression-priority"></a>
## Priorities, value dependencies, and assignment effects

The common expression mechanism uses C-like relative priorities, with right-associative assignment at the lowest
level. Power has the existing Python-like asymmetric grouping: -2 ** 2 is -(2 ** 2), 2 ** -2 groups its unary right
operand, and 2 ** 3 ** 2 is 2 ** (3 ** 2). Priority and value dependency are different questions: a receiver first
obtains any needed result, even from an operation of lower priority, while that operation keeps its entire RHS.

~~~text
f(1 + v := 2 + 3)       → v = 5; one argument 6
f(10 * v := 2 + 3)      → v = 5; one argument 50
f(1 + (v := 2) + 3)     → v = 2; one argument 6
f(v := 2 + 3; 6)        → two arguments: named v = 5, then positional 6
~~~

In the first two cases, the particular v occurrence supplies the result of that particular assignment; an old v=100
does not substitute for it. The assignment affects f's receiving activation-local input place described by its
DATA; it neither overwrites the source DATA declaration nor targets a same-named caller local. The outer expression is one actual. The last line is admissible with v first in the formal order, because
naming on the current position retains positional mode; an out-of-position v would require the next actual to
be named too.

Ordinary `v := v + 1` reads the old v on its RHS and writes one increment. Mere adjacency does not create a value
dependency: `10 * 2 + 3` remains 23. Assignment-result consumption uses the value assigned by that occurrence,
not a later reread of a mutable place.

Within one dynamic evaluation an occurrence executes once. With `read_once()` returning 4,
`f(1 + v := read_once() + 3)` performs one read, writes v=7, and passes one argument 8. A subsequent call or loop
check starts a new evaluation; there is no persistent result cache in the source graph.

Short circuit remains demand-driven: `0 && (x := 1)` and `1 || (x := 1)` skip the assignment. No preliminary pass
executes every bracketed form. `while ((c := getchar()) != EOF)` uses the selected c place in the enclosing
activation and does one read per check. For A, B, EOF there are three reads and two body executions; c finally contains EOF.
`while(c := getchar() != EOF)` is different: the RHS comparison produces the assigned Boolean, and the standalone
named actual must also satisfy while's contract. See [expression semantics](LMX_semantics.en.md#assignment-inside-expression).

<a id="operand-templates"></a>
## A user operand is an ordinary method

Operand discovery has no `sys\operand` registration or separate operand-name registry. Normal resolution finds a method whose
DATA matches the explicit structural header:

~~~lmx
operand_template:
    @: left
    @[]: right
    const: int: PASS_ARGS_AS_IS
    const: int: PRIORITY
~~~

All four named fields are required. The actual method must have ready constant integer `PASS_ARGS_AS_IS` equal to
0 or 1 and a ready integer `PRIORITY` on the common scale before operator grouping. Missing properties acquire
no defaults. The mode and priority are independent; a special numeric priority does not encode raw mode.

The general template does not prescribe a result type. An expression consumer still requires an ordinary
compatible method result; a procedure cannot supply a value merely by matching this header.
A numeric specialization can require int targets and an int result:

~~~lmx
int_operand_template:
    int@: left
    int@[]: right
    const: int: PASS_ARGS_AS_IS
    const: int: PRIORITY
    return: int
~~~

An ordinary satisfies check tests the written template; it does not add missing fields or install defaults.
Explicit composition can build a descriptor first, for example a DATA structure with `merge(Base Additional)`,
but that is a separate field-stream operation. Any method body explicitly included in a model is part of that
model's requirement; extra implementation fields absent from the model are not.

Fn remains a distinct positional contract. For example,
`PairSignature :: (@: first; @[]: rest; return: int)`
can match inputs named lhs/rhs by position. It does not establish operand discovery, for which the names left,
right, `PASS_ARGS_AS_IS`, and `PRIORITY` are significant. Through such a fn reference, public labels map to positions;
hidden binding still uses the real candidate's names and DATA.

<a id="operand-values"></a>
### Prepared-value mode: PASS_ARGS_AS_IS 0

An operator application supplies a reference to its left value and an Array of references to its right values.
Containers remain whole:

| Expression | left | right |
|---|---|---|
| `(1 foo 2 3 4)` | Reference to 1 | Three references: 2, 3, 4 |
| `(foo 1 2 3 4)` | Not supplied by this spelling | Four references: 1, 2, 3, 4 |
| `(foo A)`, with A an Array | Not supplied | One reference to A |
| `(A foo B C)`, with container values | One reference to A | References to B and C |

A missing left actual uses the ordinary optional/default/required/binding contract. It is not filled by moving the
first right value to the left. An explicitly supplied empty right Array and an omitted actual remain different.
Ordinary call W/E stays in its own scope; this packaging does not generally expand Arrays or strings.

The complete prepared-value example is:

~~~lmx
operands:
    int@: left
    int@[]: right
    const: int: PASS_ARGS_AS_IS 0
    const: int: PRIORITY sys\priority("+")
    return: int
    add:
        return: \left + \right[0]

Example:
    int: n
    return: int
    calculate:
        import: operands
        return: (n add 3) add n
    demo:
        return: calculate(2) + calculate(5)
~~~

| Call | Expression | Expected result |
|---|---|---:|
| `Example\calculate(2)` | (2 + 3) + 2 | 7 |
| `Example\calculate(5)` | (5 + 3) + 5 | 13 |
| `Example\demo()` | 7 + 13 | 20 |

The outer add receives a reference to the prepared result of the inner add. Reading left again does not rerun the
inner expression. This example consumes one right value; a reusable binary method validates its right length
under the existing contract, while a variadic implementation must process every element itself.

The body returns an ordinary int, both for operator application and explicit call. A return of reference type
would instead return a reference with no hidden extra dereference. The logical result is not universally @.

<a id="operand-raw"></a>
### Original-occurrence mode: PASS_ARGS_AS_IS 1

Raw mode uses the same grouping rules but supplies original occurrences without evaluating them. They may be
names, literals, calls, assignments, or groups. General raw code therefore uses unconstrained references, not
`int@: left` as a promise that an unevaluated Structure will eventually become int.

~~~lmx
raw_operands:
    @: left
    @[]: right
    const: int: PASS_ARGS_AS_IS 1
    const: int: PRIORITY sys\priority("+")
    return: int
    add:
        int: a sys\eval(left)
        int: b sys\eval(right[0])
        return: a + b

RawExample:
    int: n
    return: int
    calculate:
        import: raw_operands
        return: (n add 3) add n
    demo:
        return: calculate(2) + calculate(5)
~~~

`RawExample\calculate(2)`, `RawExample\calculate(5)`, and `RawExample\demo()` have expected results 7, 13, and 20.
The outer add receives original group (n add 3) on the left and original n on the right.
Its `sys\eval(left)` executes the group, including the inner raw add; its second eval obtains the right n.

`sys\eval(fragment)` enters the same value-evaluation mechanism. Each explicit invocation is a new evaluation;
two evals of an effectful occurrence produce two executions, each obeying once-per-evaluation rules. An occurrence
that the method never evaluates has no effects. A plain reference or dereference does not execute it.

The occurrence retains its original active context, including the relevant DATA for embedded assignment, binding,
and private. Passing it to a helper preserves this origin; the helper's own same-named n cannot capture the
argument's n. That context does not grant the operand itself implicit access to another activation's private
fields, and retaining a reference does not extend or restore an expired activation. A persistent computation
must use the ordinary callable/DATA and explicit copy/merge contracts. No second parser, VM, or permanent graph
cache is introduced.

<a id="operand-references"></a>
### References, storage, and explicit addresses

A bare method name is a reference; `add()` is an explicit call; `a add b` is operator use after normal resolution.
Taking `@add` produces a numeric address. Prefix `\` follows a reference and never means `sys\eval`.

~~~lmx
@: ptr SomeStructure
int: address 1 + @SomeStructure
~~~

The first line uses the ordinary reference contract; the second explicitly performs address arithmetic.
An ordinary storage reference points to the value, whose type code lies immediately before it under the
[L2 record contract](L2_spec_en.md#value-record). A reference to a container points to its typed descriptor.
A packed `Array<int>` is not an Array of references. Native temporaries that need a storage reference use the
common typed-value representation; a raw machine address is not passed off as a tagged record.
Neither mandatory copies of all values nor a new per-value wrapper type follows.

<a id="operand-name-priority"></a>
### Name strings and priorities

`sys\name(foo)` returns the ordinary LMX char Array "foo", even if foo is undeclared, a variable holding 42, or a
method with an effectful body. It consumes the written identifier, not its value or target. Exact identifiers use
their normal unescaped content; an empty exact identifier yields an empty Array. A string stays one argument in
`f(sys\name(foo))` or `f(a := sys\name(foo))`. No trailing NUL is part of the LMX string.

`sys\priority("+")` and `sys\priority(sys\name(foo))` resolve the named accessible operand and read its ready `PRIORITY`.
They do not invoke its body or register its name. Equal string contents give equal lookup behavior without
requiring canonical-string address identity. The "+" query selects the addition priority, not a contextually
guessed unary priority. Missing or ambiguous operands cause ordinary resolution errors, rather than a fictitious
priority. The named signature is `PrioritySignature :: (char[]: name; return: int)`, distinct from the ordinary
PrioritiesTemplate explained [above](#fn-signature).

The [operand observations](LMX_semantics.en.md#operand-observations) give the full acceptance matrix for these
templates, argument modes, effects, priorities, strings, and signatures.

<!-- receiver-integration-2026-11-22 -->
<a id="general-receiver-guide"></a>
## General receivers: values, records and callable factories

The [receiver chapter](LMX_semantics.en.md#functional-receivers) and
[public API](patterns/LMX_Fn_Receivers/API.md) describe the complete library.
One ordinary `fun` module exposes direct names through `import: fun`; the
method still receives its actual parent's DATA.

For an ordinary Structure S, `length(S)` and `S[i]` already provide the
reference-sequence interface. A captured argument prefix and a List can be S
itself. Creating an `items` field only to wrap this sequence is unnecessary.
Dense primitive Arrays retain their physical representation and are not
reinterpreted as pointer arrays.

There are two useful result contracts. `apply` transports a typed value-record
reference, and the caller reads that record according to its actual type.
`partial`, `curry`, `flip` and composition factories return references to
ordinary callable Structures whose result remains the precise R in their
generated DATA. Returning a reference to a function does not turn that
function's return requirement into `@`.

The examples in [functional computation](patterns/09_functional_computation/README.md)
show Maybe/bind, a trampoline, bracket and partial application. Each changed
example retains the old procedural LMX alongside the current primary listing;
its archived code is excluded from the primary character count. General library
dependencies are reported separately, so an import does not make their
implementation cost disappear.

The new name `satisfies` retains admission's previous direction and phases.
`Name :: DATA` and `signatureTypes` construct signature descriptions with the same positional compatibility rule: input
labels may differ, but count, order, complete requirements and the result must
fit. The existing named-signature relationship with `call` is deliberately unchanged;
all other uses accept either signature description. See [the equivalence rule](LMX_semantics.en.md#fn-forms-equivalent).

The supplied source bodies require the explicitly listed kernel integration
interfaces. Their acceptance cases are prepared tests, not a claim that LMX
execution was performed during this documentation revision.

<a id="unified-20261122"></a>
## Current worked forms

```lmx
int[]: values [1 2 3]
@: selected compress(source := values; mask := values > 1)
@: joined concat(parts := (values; values))
@: found index(items := values; accepts := Positive\run)
```

Here Positive\run is an ordinary predicate declared by the example's caller. Found is Maybe, not an index sentinel. Values has dense int storage; selection retains that storage profile. `[]: pending` is uninitialized, while `int[]: []` is a ready empty value. `int@[]` and `int[]@` differ. Use `@node\x`, not the compact declaration `@(node\x)`, for the address of a graph field. [Full examples and contracts](CORE_SEQUENCES_REGEX.en.md).

```lmx
matches(utf8Text("AB-09"); (then (charRange("A"; "Z") times 2) "-" (asciiDigit times 2)))
```

The Pattern is assembled by ordinary operands. The text is literal, the view explicitly chooses UTF-8 scalar positions, and matches tests the whole input. Builder evaluation is distinct from matching; no regex-string parser is implied.
