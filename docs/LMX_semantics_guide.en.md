# LMX semantics: worked explanations

These are short non-normative examples. The [semantics](LMX_semantics.en.md)
and [grammar](LMX_grammar.en.md) govern if they differ.

<a id="data-receiver-execution"></a>
## What runs during a data pass

Data does not become a program body. A direct pass executes only root-level declaration receivers;
executing such a receiver may call code supplied to it in the ordinary way.

A data fragment, with `makeValue` declared separately as a method:

```lmx
Values:
    int: x makeValue()
    Nested:
        int: y makeValue()
end: Values
```

During a pass over the data of `Values`, the `int` receiver declares `x` and receives its value through
`makeValue()`. The `Nested` form declares a nested Structure. Its `int: y ...` is not executed by this
pass: it belongs to another data level. If execution of `makeValue` reaches `test`, it follows the
ordinary rules; no separate traversal needs to search data for `test`.

Here `end: Values` closes two levels. One level needs only a dedent; `return` may be the trailer of an
executable definition. This is [formatting](../LMX_blog/2026-11-13.md#one-level-formatting), not a new parser
restriction. See [data traversal](LMX_semantics.en.md#data-root-declaration-execution) for the rule.

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
## Explicit method-body composition

```lmx
fn: add (int: x; int: y) int ()
return: x + y

fn: add5 (int: x) int ()
    merge((int: y 5); add\code)
```

`add` stores `args` with formals `x` and `y`, `return`, `data`, and `code`
with the `return: x + y` statement as separate parts. The `add\code` path
selects the `code` part itself. `merge` builds an `add5` body containing `int: y 5`
and that statement; `add5(1)` gives 6. The operand `(int: y 5)` is written in
parentheses: the list of arguments is read as code, and a bare `int: y 5` in it
would be a call of the receiver, not a field of the operand. The `add5` header
declares only formal `x`: the field `y` in its new body becomes neither a
formal nor a formal default. `merge(add; (int: y 5))` is not equivalent: the outer `add`
method Structure has `args`, `return`, `data`, and `code` parts, but no
immediate `y` field.

An alternative `add5` puts the initializer in explicit `data` and keeps
`add`'s body:

```lmx
fn: add5 (int: x) int (int: y 5)
    add\code
```

A third, alternative definition changes `args` instead: here `y` is a
formal with default 5, not a body or `data` field:

```lmx
fn: add5 merge(add\args; (int: y 5)) int ()
    add\code
```

These are three mutually exclusive definitions of `add5`, not three
consecutive declarations in one scope. The full `fn` form explicitly
supplies `data` after the result description; the short source form omits
that argument but produces the same addressable empty `data` part.
Unary `int: x` describes a typed place without an initial value and,
in a signature, a formal without a default.

The `merge` result separately undergoes [admission](LMX_semantics.en.md#admission);
the body's free names follow [dynamic resolution](LMX_semantics.en.md#dynamic).

The header `fn: add (int: x; int: y) int` **without a body** is the third
form: an interface descriptor that can be passed by reference but cannot
be invoked directly as an executable `add` body. With a body after that
header it is the short executable definition with an addressable empty
`data`. The full form with `()` after the result supplies `data` explicitly.

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

`@: add5 makeAdder(5)` **calls** the factory and stores the returned
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
