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
## Header and service tables

Lmx's flat header contains parent/length/storage. `parent(S)`, `length(S)`, and `sys\storage(S)`
load these fields directly. `sys\native(S)` returns the native descriptor of variants from call's tables,
or 0; `sys\capacity(S)` returns reserved capacity from the arena table. All five no-argument forms
select current data; code requires an explicit argument. Reading neither compiles nor invokes native.

These receivers execute only in code; same-headed data forms remain ordinary data.
For example, data\length selects a user field while length() reads launch data's length.
data/code remain call arguments; node keeps its existing meaning.

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
Lmx **, size_t *, void **. Omitting the argument selects current data, including inside control bodies.
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

<a id="call-receivers"></a>
### The `call` and `fncall` receivers

| Form | Supplied values `args` | Input `data` | Result |
|---|---|---|---|
| `call(args data code)` | `args` | `data` | none |
| `call(data code)` | not supplied | `data` | none |
| `call(code)` | not supplied | `code` | none |
| `fncall(args data return code)` | `args` | `data` | according to `return` |
| `fncall(data return code)` | not supplied | `data` | according to `return` |
| `fncall(return code)` | not supplied | `code` | according to `return` |

`args` is the Structure of actual supplied values, exactly the argument Structure
of an ordinary `call`. It is not formal declarations, a signature, or a separate
callable part. `data` describes input places, requirements, and defaults.
`return` describes the result; `code` is the executable Structure. `call` returns
no value; `fncall` returns a result according to `return`.

Forms without `args` supply no additional actual values. Omitted `data` means `code`
itself: `call(C)` equals `call(C C)`, and `fncall(R C)` equals `fncall(C R C)`.
A child `data` field inside `code` is not selected automatically. These are
abbreviations of one operation, without requiring an empty Structure allocation
or a new service object for omitted `args`.

All forms and ordinary method/Structure calls share one interpreter path:
select parts → bind actuals to data → common admission → fresh namespace → execution and result.
Receiving actuals neither changes source data nor runs entry initializers.
Calls from test and converters use the same mechanism. Known native-to-native calls
may still go directly through C without graph packaging.
[Full contract and named arguments](LMX_semantics.en.md#call-receivers).

<a id="private-binding"></a>
### Receiver private:

`private:` excludes the marked field and its corresponding binding from a call's dynamic
sources. Direct visibility from anywhere, explicit paths, and ordinary lexical lookup remain;
sequential visibility and explicit argument passing do not change.
Skipping the field follows the common binding order for every call/fncall form, ordinary call,
interpreter and native execution. This is a field property, not a global name ban or access
protection. Use the common binder without a separate registry or checks on direct reads.
[Full contract](LMX_semantics.en.md#private-binding).

<a id="call-frame-20261115"></a>
Every call creates its own namespace. For fn/sub/catch, unified data describes the inputs;
args in call/fncall contains actual values. Short headers remain. An actual replaces the corresponding
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
order of a bare name. A read through a path executes nothing; the RHS is executed when its code statement is reached.

Bare x and @x refer to the frame place, independently of source-field replacement immediately at entry,
even before the first read: the selected value or computed description is retained.
The rule is the same for explicit data, lexical binding, and dynamic binding. It does not deep-copy
referenced objects. `x := 0` changes the namespace; `data\x := 0` changes the source graph.
For computed input `int: x next()`, @x obtains the value and the local cell's address.
With `@(data\field)` and source `int: field getValue()`, the record of the declaration is addressed, not
getValue()'s result: an explicit path executes nothing (the author's decision of 2026-11-17; the former rule is withdrawn).
A ready place is addressed directly.
Lifetime remains ordinary. @f() was a research example, not a separate support or prohibition task.

Mandatory copying of executable code at entry is withdrawn, including the former copy of only
the corresponding C function's code. Selected local values/descriptions remain independent;
binding uses hidden arguments without an environment copy. Methods and ordinary Structures share
compilation without data=code; distinct actual supplies produce distinct C signatures.
Known native calls known native directly in C. Graph writes do not clear native: updating it requires
explicit compilation and an endturn boundary. Before that boundary the time at which
executable graph changes take effect is unspecified.

Local frames are not published. Load-dirty, the shared direct-access cache, and flush() are cancelled;
explicit writes are observed through actual aliases in execution order.
[Agreed norm](LMX_semantics.en.md#call-frame-20261115),
[single M14 task](../next_core_tasks_v3.md#native-structures).

<a id="flush-receiver-contract"></a>
<a id="direct-access-cache"></a>
The old flush() and shared-cache examples are withdrawn: only explicit operations change the source graph;
local variables are never written back.

<a id="native-merge"></a>
## Compilation, mutation, and the next turn

Native descriptors of all Structures belong to call's tables in the arena. Only fn/sub/catch receive
an ordinary native field referencing the same descriptor. Known native calls inside native go
directly to C with necessary hidden arguments. Copy/merge neither compile a new body nor install
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
