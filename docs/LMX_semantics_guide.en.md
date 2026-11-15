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

A callable has one input data part instead of former args and data. It is not completed with body fields:
code locals belong to the call namespace. The old three add5 examples with separate args/data therefore
no longer state the current norm. merge still explicitly constructs a new graph; it is not hidden call
initialization. A signature without code describes a call; C parameters derive from actual argument sets.
[Exact task and remaining syntax migration](../next_core_tasks_v3.md#native-structures).

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
## Reading a Structure's header

`parent(S)` gives the structural parent, `sys\native(S)` the native entry or 0,
`length(S)` the element count, and `sys\storage(S)` the pointer to element storage.
All four read values; `sys\native(S)` does not invoke the entry it obtains.

| Without an argument | Equivalent explicit argument |
| --- | --- |
| `parent()` | `parent(data)` |
| `sys\native()` | `sys\native(data)` |
| `length()` | `length(data)` |
| `sys\storage()` | `sys\storage(data)` |

In `call(D C)` this is data D; to select C, write, for example, `length(code)`.
An inline `if` body does not switch launch data. A bare receiver name does not invoke it.
The data form `length: 7` remains an ordinary Structure named `length`: with one occurrence,
`data\length` selects it, while `length()` reads the length of the data itself. The same
applies to parent/native/storage records; there are no special paths to the header.

The physical header fields are now named parent/native/length/storage.
`data` and `code` remain the Structure arguments of a launch; `node` keeps its existing
meaning as the activation context. Reading these four values needs no descriptor;
it returns addresses for writing, as shown below. [Contract](LMX_semantics.en.md#header-receivers),
[open implementation M13](../next_core_tasks_v3.md#flat-lmx-descriptor).

<a id="get-descriptor"></a>
## Header-field addresses through descriptor

`sys\descriptor(S)` selects S; with no argument, `sys\descriptor()` selects the current data, as `sys\descriptor(data)`.
This rule also applies inside nested control bodies. Code requires an explicit argument.
Forms `sys\descriptor: S` and `sys\descriptor:` have the same contracts; in data, the form remains ordinary data.

Let d be the result of the ordinary call `sys\descriptor: S`. It is a Structure
of addresses of fields `parent`, `native`, `length`, `storage` of S's flat header.
For example, `\(d\native) := 0` writes zero to the actual S.native:
the next call of S uses the walker. Writing `d\native := 0` changes
only the pointer inside d. There is no snapshot or later synchronization.

An explicit field path or typed dereference allows an ordinary write,
including references and function pointers; the restriction on changing a bare
Structure name does not prohibit this path. Pointer depth and Array rank are
independent and have no fixed numeric limit. The address has S's ordinary
lifetime bounds. The contract is approved; implementation is still pending:
[`sys\descriptor`](LMX_semantics.en.md#get-descriptor),
[M13](../next_core_tasks_v3.md#flat-lmx-descriptor).

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

Entry selects a snapshot of only the code that compilation puts into the corresponding C function.
This is not the entire lexical tree. Bindings are passed as hidden arguments; the lexical environment
and other functions' code are not copied for the snapshot. Function-code selection is shared.
Changing source code clears native for the next call;
an active frame continues its selected snapshot. Methods and ordinary Structures share compilation
without data=code. Different actual argument sets produce different C signatures;
a header without code describes a call.

Local frames are not published. Load-dirty, the shared direct-access cache, and flush() are cancelled;
explicit writes are observed through actual aliases in execution order.
[Agreed norm](LMX_semantics.en.md#call-frame-20261115),
[single M14 task](../next_core_tasks_v3.md#native-structures).

<a id="flush-receiver-contract"></a>
<a id="direct-access-cache"></a>
The old flush() and shared-cache examples are withdrawn: only explicit operations change the source graph;
local variables are never written back.

<a id="native-merge"></a>
## Native code in a copy

A copy has its own mutable graph; sharing a machine implementation address
does not share that graph. If merge selects a different body, the old native
entry no longer describes the selected code. With the same implementation,
the copy's graph can be passed as data only when the used layout and address
map remain compatible; without a suitable native entry, the completed graph
runs in the interpreter. An `implements` map aligns physical fields but
neither selects code nor stores runtime names. The `call: data code` split
and addressable method parts are an [approved coding target](../next_core_tasks_v3.md);
the compatible ABI is not fully implemented yet.

<a id="factory-result"></a>
## A returned method

In code, the statement `@: add5 makeAdder(5)` **calls** the factory and stores the returned
method. `add5(1)` then calls it through the stored pointer. A data form
`add5: makeAdder 5` merely declares a Structure `add5` and does not run the factory;
among executed forms the same form is a call of its head `add5`: a callable (a
method or a pointer to one) is called, while an ordinary Structure is launched
over the data after the colon; the form has one argument, `data`, so for a
Structure `add5` the two fields `makeAdder` and `5` are an error
([journal](../LMX_blog/2026-11-11.md#structure-call-by-name); the executor's
reading in [answers](../LMX_blog/q/fable-self-answers-20261110.md), Р21,
items 4 and 6). If the returned
method reads free `n`, the caller's dynamic input takes precedence over a copied
lexical fallback.

<a id="dynamic-fallback"></a>
## Dynamic and lexical sources

This is not LMX syntax: a copied lexical context has `x = 10` and the
caller supplies `x = 25`. Free `x` reads 25; explicit `node\x` reads 10.
On a later call with `x = 40`, free `x` reads 40. With no dynamic source,
it reads the lexical 10.

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
