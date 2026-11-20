# LMX semantics: worked explanations

These are short non-normative examples. The [semantics](LMX_semantics.en.md)
and [grammar](LMX_grammar.en.md) govern if they differ.

<a id="data-receiver-execution"></a>
## Preparation does not execute the program

The builder folds ready declarations without calls. Namespace preparation considers only data/code
root declarations, visiting neither nested branches nor graph references. In

```lmx
mark()
int: y makeValue()
```

preparation does not move makeValue() before mark(). Executing a reached receiver remains an ordinary
call and may execute code passed to it; this does not permit eager execution of all data initializers.
A supplied actual suppresses its corresponding initializer. [Norm](LMX_semantics.en.md#call-frame-20261115).

<a id="admission-stages"></a>
## Two admission steps

| When | What happens |
|---|---|
| Graph construction, known candidate | The used interface is checked. `test` is not executed. |
| Actual admission at run time | A completed first step is not repeated. Specified `test` checks then execute. |
| First check returns `0` | Admission stops immediately; remaining checks do not execute. |

Knowing a candidate at construction does not remove the second step at actual admission. A value
change alone does not rerun all checks. See [admission and test](LMX_semantics.en.md#admission).

<a id="callable-description"></a>
## Input description and composition

A callable has one input data part: the data role is executed by the actual `parent` of the selected Structure
([structural call](#call-receivers)), and the actual values are passed by a separate `args`. The data is not
completed with body fields: code locals belong to the call namespace. The old three add5 examples with separate
args/data therefore no longer state the current norm. merge still explicitly constructs a new graph; it is not
hidden call initialization. A signature without executable code is described by `fn` with the same data template
([`fn` signature](#fn-signature)); C parameters derive from actual argument sets.
[Exact task and remaining syntax migration](../next_core_tasks_v3.md#native-structures);
[plan of the 2026-11-19 norm](../next_core_tasks_v3.md#binding-callables-20261119).

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

A first definition allocates the place; in code a repeated form with a
candidate writes after admission, and a repeated form without a candidate
only checks the requirement (in data a repeated form is one more occurrence
of the name, [names and paths](LMX_semantics.en.md#fields)). The composed forms with the place in the outer head —
`x: int()`, `x: int: 5`, `ptr: @()`, `ptr: @: 0`, `ptr: @: Model` — are
withdrawn by the author's decision of 2026-11-10
([semantics](LMX_semantics.en.md#receiver-args-only)): in data `ms: int: time`
declares a Structure `ms` with a field `time`, not a place `ms`.

<a id="header-receivers"></a>
## Header and service tables

Lmx's flat header contains parent/length/storage. `parent(S)`, `length(S)`, and `sys\storage(S)`
load these fields directly. `sys\native(S)` returns the native descriptor of variants from call's tables,
or 0; `sys\capacity(S)` returns reserved capacity from the arena table. All five no-argument forms
select the data of the current call; code requires an explicit argument. Reading neither compiles nor invokes native.

These receivers execute only in code; same-headed data forms remain ordinary data.
For example, the path `D\length` (`D` is the data Structure) selects a user field while length() reads the length
of the call's data. The parameters of `call` are named `args` and `code`; node keeps its existing meaning.

Structure and Array<@> are interchangeable; numeric Array<T> stores T elements. All arrays have variable
length and a common allocation mechanism. sys\resize(S,n) changes length; sys\reserve(S,n) changes reserve only.
Capacity belongs to an arena table, not the header. The descriptor address stays stable; storage may move.
In L2 an index, including a negative one, only computes an offset. In L3 adjacent [i][j] yield one linear
index and one length check; an L3 element reference contains the Array descriptor reference and index,
not storage. A raw L2 address is not repaired when storage moves.
[Contract](LMX_semantics.en.md#array-capacity), [implementation OPEN](../next_core_tasks_v3.md#flat-lmx-descriptor).

<a id="get-descriptor"></a>
## Header-field addresses through descriptor

`sys\descriptor(S)` returns an ordinary Structure of three actual parent/length/storage field addresses:
Lmx **, size_t *, void **. Omitting the argument selects the data of the current call, including inside control bodies.
The result contains neither native nor capacity.

With d = sys\descriptor(S), `\(d\length) := n` directly changes S's length; `d\length := p` changes
the pointer in d itself. The first example does not allocate storage; sys\resize performs a consistent
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
nested Structures nor graph references. Structure and Array<@> use one mechanism for reading immediate
elements. Reuse existing addressing; no reverse-index table or per-write maintenance is needed.

<a id="callable-admission"></a>
## What the callable interface check proves

Methods with formals `(int: x; int: y 5)` and `(int: x)` both accept `f(1)`, but a
Consumer's written call `f(1; y := 25)` accepts only the former. Admission
checks required explicitly used accesses, not equality of formal lists or
predicted body behavior. User-authored behavioral tests are a separate stage.

<a id="method-pointer"></a>
## A method name and a pointer to it

`myFunc()` directly calls a declared method. After `@: ptr myFunc`,
`ptr()` calls through the pointer; repeated `@: ptr otherFunc` in code
assigns another compatible method to that same cell (in data a repeated
form is one more occurrence of the name). Bare `myFunc` or `ptr` only
reads a value. `(\ptr)()` calls after explicit dereference; `\ptr()`
applies `\` to the **result** of the call under ordinary precedence,
not through a special pointer-call rule.

<a id="native-structures"></a>
## Native and interpreter frames

The 2026-11-19 norm ("binding and callables") was accepted by the author in the
[task](new_parts/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md); the translator, the clean-graph interpreter,
the kernel, examples, and tests do not execute it yet: [plan](../next_core_tasks_v3.md#binding-callables-20261119).
The rules and examples of this section follow the new norm.

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
R0 is a procedural entry without data and without user arguments: it has no artificial `D = C`, no empty service
Structure, and no field `data`. R0 may have its own executable declarations and ordinary accessible references;
runtime launch parameters are not user actual arguments. In which role the records of the unit root are read when R0
has no data is not yet defined: [open question](../LMX_blog/q/current/unit-root-roles-20261119.md).
[R0 without data](LMX_semantics.en.md#root-entry).

<a id="removed-builtins"></a>
Removed: the special meaning of the name `data` (a special word, the path `data\…`, the assignment `data := …`), the
separate data parameter of `call`, the built-in `fncall` and `sub`, the executable form of `fn`. The word "data" as
the name of a role and as an ordinary user name remains. The former path `data\x` is now written as `node\x` or as an
ordinary path from the name of the data Structure (`D\x`): this is the executor's reading (Р107,
[answers](../LMX_blog/q/fable-self-answers-20261110.md)), under which `node\x` addresses a field of the call's data.
[What is removed](LMX_semantics.en.md#removed-builtins).

<a id="fn-signature"></a>
### The `fn` signature and `return` in data

`fn` is only a signature: a template of input places in the form of data (requirements, defaults, modifiers) together
with the field `return`. With `return` it is a value contract, without it a procedural contract; `sub` is not needed.
`fn` executes nothing and creates neither a body nor a native entry; the result does not stand in a separate position
after the list of inputs and does not become an actual argument.

```lmx
fn:
    int: a
    int: b
    return: int
```

The compact form is `fn(int: a; int: b; return: int)`. A structural result is a nested block inside `return`.
All arguments of `fn` are read in the data role: a nested Structure there is a description, not a launch. `fn` belongs
to the group of receivers whose arguments are in the data role, and the readings W/E of
[declaration selection](#declaration-selection) do not apply to them
([two kinds of receivers](LMX_semantics.en.md#whole-arguments)). There is no separate grammar of signatures: the
parsing is one.

A complete example — the data context `SumContext` and the nested code Structure `sum`:

```lmx
SumContext:
    int: a
    int: b
    return: int
    sum:
        return: a + b
```

```lmx
SumContext\sum(a := 2; b := 3)
@: sumPtr fn(int: a; int: b; return: int) SumContext\sum
sumPtr(a := 2; b := 3)
```

The first line executes `sum` over the data `SumContext`; `SumContext()` would execute a different Structure, not the
found field `sum`. In the second, `@` has three arguments: the name `sumPtr`, the required signature `fn(...)`, and
the candidate `SumContext\sum`. The requirement is checked by the common `implements` against the call contract of the
candidate, taking its `parent` into account: the input fields and `return` need not lie inside the body of `sum`. The
third line is the same call through the pointer. No executable `fn`/`sub` is needed for `SumContext` or `sum`.

<a id="return-in-data"></a>
The result is described by the field `return` in data: `return: int` or a nested block. This declaration assigns
nothing and is not a shared mutable cell of recursive activations. In code `return` is the return receiver: `return`
without a value is preserved, `return: value` passes the result to where it is described, and reaching the end of the
code does not create a `return`. Both `call` and an ordinary Structure call may return a value; the former ban "a
Structure launch has no result" is lifted together with `fncall`. `catch` is brought to the same model of data and
call while keeping the semantics of the handler: it does not disappear together with `sub` and does not become an
ordinary function.
[`fn` signature](LMX_semantics.en.md#fn-signature), [`return` in data](LMX_semantics.en.md#return-in-data),
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
| `fn` contains a nested Structure | `fn(...)` | data role; W/E of code-role calls do not apply |

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
`lexicalPrivate` the nested `code` reads the `private` field `Outer\x` lexically and there is no dynamic substitution:
`r` is 7, not 11; an explicit path reads the same `Outer\x`. Without `private` on `Outer\x` the free `x` would be bound
by the general order, to the caller's place. [Examples in the semantics](LMX_semantics.en.md#private-examples).

<a id="shadowing-levels"></a>
### Shadowing of levels

The author's rule (task §7.1; the Russian original, then a translation):

> «объявление на вложенном уровне затеняет внешнее одноименное объявление. На одном уровне затенять нечего, используется родительское».
> (A declaration at a nested level shadows the outer declaration of the same name. At one level there is nothing to
> shadow; the parent one is used.)

The rule is applied through the owner of the declaration and the lexical scope, not through a coincidence of a string
anywhere in the body. An inner `Text x` shadows an outer `int x`: this is not a write of `Text` into the outer `int`
cell, and after leaving the inner scope the outer one is visible again with its own place, write mode, and `private`.
At the same level there is nothing to shadow: repeating a declaration works with the already existing place under the
receiver contract — a new right-hand side is evaluated and assigned, the absence of a right-hand side does not zero
the value, and there is no second cell. Sequential visibility is preserved: a use of `x` before a later own
declaration is resolved in the ordinary way through the outer context.
[Shadowing of levels](LMX_semantics.en.md#shadowing-levels).

<a id="inline-declaration-control"></a>
A control example (task §7.4): in the current frame the outer `x = 5`; in a nested inline block, without a new call
of a callee, there is a new `int: x` with no right-hand side and no default, and then the inner `x` is read; the caller
of this frame has no same-named `x`. The shadowing and the separateness of the inner place are defined; only the
initial value is in question. **The executor's reading** (not the author's decision; Р106,
[answers](../LMX_blog/q/fable-self-answers-20261110.md)): the place stays `uninit:int`, not 5. Autofill is defined
between the caller's local context and the callee's place at a call, while an inline scope stays in the same
activation; the value 5 would need a new rule "the enclosing inline scope is a source of autofill", which the task
forbids introducing. [Control example](LMX_semantics.en.md#inline-declaration-control).

<a id="call-frame-20261115"></a>
### The call frame

Every call creates its own namespace. The inputs are described by the call's data (the `parent` of the selected
Structure; for `fn` only a signature, for `catch` the common model of data and call); `args` in `call` contains actual
values. Short headers remain. An actual replaces the corresponding source declaration in the frame, and its
initializer does not execute. Preparation collects only data/code roots, without visiting branches or graph
references; binding adds no fields to the source data/code, and the graph remains a graph of source forms.

Entry has no initializer-execution phase. Ready declarations fold during clean-graph construction
without program calls; uninit:T remains. An unused computed data field is not executed.
Reading obtains its value through the common mechanism, as with `D\field`: the written RHS
executes, not an implicit call on the obtained reference. Given `@: fptr getFuncPtr()`,
`fptr("hello world")` first obtains the pointer, then calls the resulting function.

Variables and const are visible from their initial declaration onward in their scope and below.
Names of Structures and callables retain bidirectional visibility; a function-pointer variable does not.
A new branch name does not escape its branch. Repeated `int: x bump()` retains evaluation,
admission, and assignment to existing x; only the repeated C declaration is omitted. Physical repeated
fields remain and are selected by `S\[n]x`. An explicit path is not restricted by the declaration
order of a bare name. A read through a path executes nothing; the RHS is executed when its code statement is reached.

For an own place (an explicit actual, autofill, the former binding), bare x and @x refer to the frame place,
independently of source-field replacement immediately at entry, even before the first read: the selected value or
computed description is retained. It does not deep-copy referenced objects. `x := 0` changes the selected place:
the call's namespace or, with a transparent place, the caller's place
([binding](#binding-caller-place)); `D\x := 0` changes the source graph (`D` is the data Structure).
For computed input `int: x next()`, @x obtains the value and the local cell's address.
With `@(D\field)` and source `int: field getValue()`, the record of the declaration is addressed, not
getValue()'s result: an explicit path executes nothing (the author's decision of 2026-11-17; the former rule is withdrawn).
A ready place is addressed directly.
Lifetime remains ordinary. @f() was a research example, not a separate support or prohibition task.

<a id="binding-executors"></a>
Mandatory copying of executable code at entry is withdrawn, including the former copy of only
the corresponding C function's code. Selected local values/descriptions remain independent, and there is no
environment copy. The four combinations native → native, native → interpreter, interpreter → native, and
interpreter → interpreter give one observable behavior: autofill is lowered as a parameter `T`, the transparent
caller place as the hidden address of the cell, and the fallback gives an own place; a native local place has no
arena header `[type][value]`. Methods and ordinary Structures share compilation; distinct actual supplies produce
distinct C signatures. Known native calls known native directly in C. Graph writes do not clear native: updating it
requires explicit compilation and an endturn boundary. Before that boundary the time at which executable graph
changes take effect is unspecified. There is no hidden compilation, no persistent caches, and no copy-out on exit;
a transparent link does not extend lifetime, and at `yield` the selected link is not rebound to the same-named place
of a new caller.

Local frames are not published. Load-dirty, the shared direct-access cache, and flush() are cancelled;
explicit writes are observed through actual aliases in execution order.
[Agreed norm](LMX_semantics.en.md#call-frame-20261115),
[executors](LMX_semantics.en.md#binding-executors),
[single M14 task](../next_core_tasks_v3.md#native-structures),
[plan of the 2026-11-19 norm](../next_core_tasks_v3.md#binding-callables-20261119).

<a id="flush-receiver-contract"></a>
<a id="direct-access-cache"></a>
The old flush() and shared-cache examples are withdrawn: only explicit operations change the source graph;
local variables are never written back.

<a id="native-merge"></a>
## Compilation, mutation, and the next turn

Native descriptors of all Structures belong to call's tables in the arena. The former wording "only
fn/sub/catch receive an ordinary native field referencing the same descriptor" describes the implementation of
the former norm (before 2026-11-19); the current norm is [what is removed](LMX_semantics.en.md#removed-builtins)
and the [`fn` signature](LMX_semantics.en.md#fn-signature) (there is no executable `fn`/`sub`, and `fn` creates no
native entry); the replacement is the [plan](../next_core_tasks_v3.md#binding-callables-20261119). Known native
calls inside native go directly to C; autofill and the transparent place are passed as a parameter `T` and as a cell
address ([executors](#binding-executors)). Copy/merge neither compile a new body nor install
its call-table binding; explicit compilation or restoration establishes that binding.

`sys\compile(S)` builds/checks a clean graph without running the program, translates to L1/C,
compiles/links machine code, and registers a successful result; diagnostics are returned.
Graph writes neither clear native nor trigger change tracking. If A directly calls B, changing that
call requires compiling the unit containing A and B, not B alone.

`sys\endturn()` exits to the ordinary turn boundary through all registered finally blocks.
Catch does not intercept it and control does not return to its call site; it does not itself stop
a Thread/Message. Before the boundary, executable graph edits take effect at an unspecified time.
Successful explicit compilation followed by the boundary guarantees the update at the next entry.
Endturn alone compiles/checks nothing and publishes no locals.
[Full contract](LMX_semantics.en.md#explicit-compilation).

`sys\toLmx(Thread)` saves the selected Thread and serializable contents of all tables in its arena,
including call/native tables. After a same-platform restart, ready binaries are used through
module/entry identifiers without retranslating. External tables are not silently added to an
arbitrary S; R0 is a particular Thread, not the only root capable of this persistence.

<a id="factory-result"></a>
## A returned method

In code, the statement `@: add5 makeAdder(5)` **calls** the factory and stores the returned
method. `add5(1)` then calls it through the stored pointer. A data form
`add5: makeAdder 5` merely declares a Structure `add5` and does not run the factory;
among executed forms the same form is a call of its head `add5`: a callable (a
method or a pointer to one) is called, while an ordinary Structure is executed
in the code role ([structural call](#call-receivers)). The former statement "an
ordinary Structure is launched over the data after the colon; the form has one
argument, `data`, so for a Structure `add5` the two fields `makeAdder` and `5`
are an error"
([journal](../LMX_blog/2026-11-11.md#structure-call-by-name); the executor's
reading in [answers](../LMX_blog/q/fable-self-answers-20261110.md), Р21,
items 4 and 6) describes the former norm (before 2026-11-19); the current norm is
the [structural call](LMX_semantics.en.md#call-receivers); the replacement is the
[plan](../next_core_tasks_v3.md#binding-callables-20261119). If the returned
method reads free `n`, the source is chosen by the [binding order](#binding-places): a lexical
`private` source, otherwise the caller's place, otherwise the former binding.

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
A primitive `Foot → Meter` conversion does not establish `implements`
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
a declared failure goes to `catch`. Timeout starts at actual dispatch:
a 500 ms threshold may yield an observed 512 ms while its threshold field
remains 500. A late reply is not automatically discarded. The full contract
and T01–T26 matrix are in the [semantics](LMX_semantics.en.md#thread-message-api)
and [mail plan](../next_core_tasks_v3.md).

<a id="tables-and-registries"></a>
## Tables and providers as data

An explicit Table can provide a spelling `u8 → "uint8_t"` or an
implementation key `plus[decimal][int] → decimal_int_add`. It does not
declare types, create a runtime namespace, or search providers automatically.
Source precedence, conflict resolution, and a missing-cell marker belong to
the profile selected by the Table's consumer, not a universal hidden registry.

## Priorities, evaluation on demand and an explicit group in an expression

The priorities and the associativity of operations are those of C; assignment has the lowest priority, and its
right part is the whole expression to its right up to the end of the group. Values are evaluated on demand: if
a receiver needs the result of another receiver, that one is executed first, whatever its priority, and it is
executed once. The clean graph does not change.

```text
f(1 + v := 2 + 3)
→ f(1 + (v := 5))    # v = 5
→ f(6)

f(1 + (v := 2) + 3)
→ f(1 + 2 + 3)    # v = 2
→ f(6)

f(v := 2 + 3; 6)
→ f(v := 5; 6)
```

The first two records supply one argument 6 and differ in the value of `v` in the data of `f`: parentheses set
a boundary of evaluation. The third record supplies two arguments: an assignment at an argument position of its
own is a named argument. An embedded assignment does not become a separate argument, and the caller's variable
of the same name does not change. Short circuit stays: in `0 && (x := 1)` and `1 || (x := 1)` the variable `x`
does not change. `while ((c := getchar()) != EOF)` at every check reads one character, writes it into `c` and
compares. `sys\name(foo)` gives the name of the identifier as the string `"foo"` and does not read the
value of `foo`. A user operand is registered with a function of implementation and a priority: after
`sys\operand: foo new_op p` the record `(foo 1 2 3 4)` calls `new_op` with one array of four
references to the values; `sys\priority("+")` gives the priority of an existing operand. The norm
is [the book](LMX_semantics.en.md#assignment-inside-expression).
