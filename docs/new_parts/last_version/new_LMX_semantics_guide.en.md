# LMX semantics: worked explanations

<a id="p0-container-correction"></a>
## 1. The empty Structure and the sole container in P0

Removing the sole non-empty anonymous container in P0 is not an error: the
former requirement to fix it in the P0 code is withdrawn on the author's
direct instruction ([the author's clarification of 2026-11-10](../LMX_blog/2026-11-10.md)).
Supplying a sole argument Structure as the entire actual-argument Structure
is a rule of the semantics of an already resolved function or method call,
at argument preparation, not of P0.

Expanding an empty Structure in P0 is not an error either ([the author's
clarifications of 2026-11-09](../LMX_blog/2026-11-09.md)). Three forms with
the same meaning, an empty Structure, yield one P0 tree: `A{}`, the short
form `A: {}`, and the block record of `A` with an empty body. The block
closes under the general boundary rules, for example:

```lmx
A{}
A: {}
A:
---
A:
end: A
```

The short form `A: {}` equals `A{}` only when it ends with a line break
and a return to the previous level. This follows from the general rules of
levels and of how short and block forms end, not from a parser exception:
when the close of block `A` follows `A: {}`, the record is a block, and the
empty Structure is its only field.

```lmx
A: {}
end: A    # A{{}}, not an empty A
```

The expansion does not erase the distinction between the call form and a
non-call record: P0 marks `A()` as a call. A call is written `A(args)` or
`A()`; `A(): args` and the block `A():` are a rarely needed additional
layout of the same call ([below](#call-forms)). Curly braces are never a
call, neither is a standalone `(...)` (the short `A: ()` is the same empty
Structure as `A: {}`), and the colon Frame `A: args` is not a call.

<a id="data-receiver-correction"></a>
## 2. Removal of two-argument data and type receiver forms

**CODE REQUIREMENT. Remove support for every two-argument form of data
and type receivers, including `int`, `@`, and their analogues.** An object's
name and its value may no longer be passed as two neighboring arguments
to such a receiver. Removed forms must be rejected by semantic admission;
there is no compatible legacy alternative or implicit rewrite to the new
form. P0 preserves the common Frame structure and does not parse receivers
by their names.

When supplying a value or candidate, the object's name belongs to the
enclosing description, and the receiver takes one operand:

```lmx
i{ int: 5}
i: int: 5
ptr: @: 0
ptr: @: Model
ptr: @: myFunc
add5: @: makeAdder(5)
```

These are alternative examples, not consecutive declarations of one
object. **Removed and rejected forms** appear only for migration:

| Removed form — reject | Current form |
| --- | --- |
| `int: i 5` | `i{ int: 5}` or `i: int: 5` |
| `@: ptr 0` | `ptr: @: 0` |
| `@: ptr Model` | `ptr: @: Model` |
| `@: ptr myFunc` | `ptr: @: myFunc` |
| `@: add5 makeAdder(5)` | `add5: @: makeAdder(5)` |

Unary `int: x` and `@: ptr`, which describe a place without an initial
value, remain valid. Empty forms `int()` and `@()` also remain valid.
The removal concerns two arguments of data and type receivers; it does
not limit the argument count of ordinary methods, `merge`, `print`, `fn`,
`post`, or other independent receivers.

**Revision 4: 2026-11-09.**

These two requirements and the sections “New syntax”, “Bidirectional
visibility and accumulated changes”, “Direct index and numbered named
occurrence”, “An expression is a Structure”, “Structure through Array @”,
and “typeof: type from the pointed object's arena” record the adopted changes;
the updated [grammar](new_LMX_grammar.en.md) reflects them. Earlier versions of
[L3](new_LMX_semantics.en.md) do not override these changes and must be aligned
with them. The remaining sections are short non-normative examples: for
unaffected rules, the semantics and updated grammar govern.

<a id="new-syntax"></a>
## New syntax

Curly brackets describe an ordinary Structure and provide non-call
expression grouping; `name{...}` is a named description. Square brackets
bound Mix: `[color: red]`. Round brackets remain around calls and their
actual-argument Structures, and continue to denote array allocation and
array indexing.

```lmx
{i: int: 1}           # Structure description with an initial value
{i: int}              # Structure description without an initial value

f(1)                  # method call with a positional argument
f(i: 1)               # method call with a named argument

arr: (): int          # allocate an int array
arr(1)                # array element
arr(2)                # next array element

x: 5                  # write to the known place x
x +: 1                # compound assignment
x = 5                 # comparison
```

The forms `(1)` and `(i: 1)` are actual-argument Structures of a call.
The previous `:=` operator is replaced by `:`; compound assignments
replace `=` with `:`: `+:`, `-:`, `*:`, `/:`, `%:`, `<<:`, `>>:`, `&:`,
`^:`, `|:`, `**:`. Comparison operators retain their meaning. The colon
also continues to separate a Frame head from its argument Structure;
the resolved head determines its particular meaning, not the sign alone.

An ordinary Structure has no formal parameters. `s()` executes it without
an explicitly supplied separate data Structure; `s(data)` executes the
code `s` on the supplied Structure `data`. The `call` operator is removed.
Data selection for `s()` follows the general execution rules. A method
retains calls with actual arguments: `f(1)` calls the method rather than
indexing its fields. Direct positional access to a Structure is written
`s\(index)`. Without `\`, `s(1)` does not acquire an indexing meaning for
a Structure. Access through assignment to an Array `@` also remains available.

<a id="name-visibility"></a>
## Bidirectional visibility and accumulated changes

**Names are visible in both directions within their admitted binding scope.**
This applies to a method, an ordinary Structure, and a reference or
primitive place alike. The latest applicable preceding definition or
already accumulated update takes precedence: look backward and use the
latest. Applicability concerns the name and binding scope, not successful
admission: the selected value is checked under its ordinary contract,
and incompatibility does not authorize using an earlier value. If there
is no preceding source, the name and prepared place may be found ahead.
There is no selection by proximity: within a code scope a name has one
prepared place whose value the writes change in sequence; a data field is
found unambiguously, and several same-named occurrences without an index
are an ambiguity error ([the author's clarification of
2026-11-09](../LMX_blog/2026-11-09.md)).

### A reached write determines the next read

```lmx
x: int: 1
print(x)
x: int: 2
print(x)
x: int: 3
```

The first `print` receives 1 and the second receives 2. The last line
has not executed at either read and does not substitute 3 into them.
All three writes address one place `x`; they do not create three
same-named data fields. The walker accumulates reached changes. Native
code must preserve the same order of writes and reads instead of
unconditionally selecting the final write in the entire source.

### A method and an ordinary Structure may be described later

```lmx
read_later: fn: int () {}
    return: Later\value + later()

Later{ value: int: 5}

later: fn: int () {}
    return: 2

read_later()
```

The body of `read_later` can refer both to the later ordinary Structure
name `Later` and to the later method name `later`. A bare name and a path
read the selected values; `later()` explicitly calls the method. In this
example, `read_later()` occurs after both targets have been constructed.
Visibility does not execute their declarations, initializers, or future
writes in advance. If a program accesses a prepared place before it is
filled, visibility alone supplies neither zero nor any other invented
value; the existing contract for that place applies.

### Field preparation and the rule's boundaries

Automatic population of `var` prepares the complete set of a method's
own fields. Bidirectional visibility is now a general language rule,
not an exception limited to those fields. Preparing the complete set of
places neither evaluates body initializers nor moves future effects to
method entry. Native lowering must first establish the complete field
layout and address maps, then preserve semantic execution order.

P0 still retains every source occurrence, its order, and its containers;
it neither selects a winning definition nor collapses repeated writes.
Binding scopes and the precedence of a dynamic source over a lexical
source do not expand. The meanings of `parent`, `node`, and `independent`
do not change. An ambiguous explicit `data\field` still requires an
occurrence number, `data\(N)field`; backward-latest lookup does not
automatically select one of those fields. The overall index `data\(N)`
and Mix also retain their contracts. Normative rules are in the
[semantics](new_LMX_semantics.en.md#fields) and
[grammar](new_LMX_grammar.en.md#name-visibility); code changes are in the
[fix list](new_bugs_for_fixing.md).

<a id="structure-index"></a>
## Direct index and numbered named occurrence

`struct\(index)` without a following name selects an immediate Structure
element by its overall position. Indexing starts at zero; a nested
Structure remains one immediate element rather than expanding into its
parent's fields. This path applies to any Structure, including a method.

The existing `struct\(index)field` form remains: it selects an occurrence
of the particular root-level head `field:` in a Structure used as data.
Counting also starts at zero, but only among occurrences of the selected
name, rather than among all elements.

Function `f` has its parts ordered as `{return args var body}` (return
first everywhere, [the author's clarification of 2026-11-09](../LMX_blog/2026-11-09.md));
`sub` and `catch` have no result, and their parts are `{args var body}`:

```lmx
f\(0)                # element at overall position 0: return
f\(0)return          # occurrence 0 of the name return
f\return             # the sole occurrence of the name return
f(1)                 # method call with argument 1
```

The first three accesses select the `return` part through different paths;
`f\(1)` selects `args`. `f\(1)return` would require a second occurrence of
the name `return`, which this function Structure does not have; it is not another spelling of
`f\(1)`. Bare `struct\field` still requires a sole occurrence of that name.

The numbered named path addresses source heads in a Structure used as data.
It does not permit duplicate materialized data fields. The direct
positional path does not change that restriction either.

<a id="expression-structure"></a>
## An expression is a Structure

**An expression is a Structure.** In `{a + b}`, the expression's fields,
their order, and nesting are retained; the description of an expression
is not its evaluated result. Curly braces explicitly bound this Structure.

```lmx
{a + b} * c
```

In an evaluation context, the expression consumer uses the value of the
inner `a + b` as the operand multiplied by `c`. P0 retains the inner
Structure and its fields; it neither replaces it with the result nor
strips its container. The presence of the description `{a + b}` alone
does not imply immediate evaluation: the semantic expression consumer
determines its role and evaluation.

The same general `\(index)` path applies to an expression Structure.
It selects immediate elements of the retained structure; this introduces
neither a numeric operator layout nor a separate expression ABI.

<a id="structure-array"></a>
## Structure through Array @

In addition to the direct `f\(index)` path, a Structure can be represented
as an array of void references `@`, then accessed by indexing that array.
Explicitly declare a reference array, then assign the Structure to it:

```lmx
arr{ (): @}; arr: f; arr(0)
```

`arr{ (): @}` is a named descriptor declaring an Array `@`.
`arr: f` assigns the representation of function `f`'s Structure to the
array; the bare name `f` reads the function without executing it. `arr(0)`
returns function `f`'s `return` Structure, accessible through the
corresponding array reference.

The function-part order is `{return args var body}`, indexed from zero:

| Direct path | Through Array `@` | Part of function `f` |
| --- | --- | --- |
| `f\(0)` | `arr(0)` | `return` |
| `f\(1)` | `arr(1)` | `args` |
| `f\(2)` | `arr(2)` | `var` |
| `f\(3)` | `arr(3)` | `body` |

Array `@` is an additional access route; direct `f\(index)` requires no
array declaration. The named paths `f\args`, `f\return`, `f\var`, and
`f\body` retain the corresponding parts.

<a id="arena-typeof"></a>
## typeof: type from the pointed object's arena

`typeof(p)` accepts a pointer and returns the type code of the arena to
which the pointed object belongs. For the reference array in the previous
section:

```lmx
typeof(arr(0))
```

The argument is a reference to function `f`'s `return` Structure. The result
is that Structure's arena type code, not the pointer's own static type
`@` or the type of the value returned by calling `f`. Determining a type
from an arena assumes its code unambiguously identifies the type of
objects stored there; no concrete numeric codes are assigned here.

An arena type code does not itself replace full Structure-interface
checking. If different structures share an arena type, the code does not
distinguish their fields, formals, or admission requirements. For an
ordinary `int` array, its element's value must not silently be treated as
a pointer: the `typeof` contract specifically requires a reference to the
object being inspected.

<a id="fn-declaration"></a>
## Declaring fn

The function name stands outside, and the parts of the `fn` receiver come
in the order `return args var body`. The arguments are conveniently
described by an anonymous round Structure; all parts may be written on one
line (the author's example):

```lmx
f: fn: int (arg: int) {variable: int} {body: int}
```

Here `int` is `return`, `(arg: int)` is `args`, `{variable: int}` is
`var`, and `{body: int}` is `body`. Parentheses after a space with no head
are an anonymous Structure, not a call. Without `var` this is the short
form; without a body it is an interface descriptor.

As in Python, levels need not be closed: an ordinary level decrease ends a
block. Only closing several levels needs the general means -- `end: name`
or a terminal `return`, which keeps its action and most often serves as the
trailer ([the author's reminder of 2026-11-09](../LMX_blog/2026-11-09.md)).

<a id="call-forms"></a>
## Writing a call and three ways to shorten arguments

The main call form is `f(args)`, and a nullary call is `f()`. Inside the
parentheses everything admitted inside `{}` is admitted, blocks included,
so a large argument is written in `f(args)` as well. `f: args` is not a
call: the colon serves naming, assignment, and receivers ([the author's
clarifications of 2026-11-09](../LMX_blog/2026-11-09.md)). The call rule
does not apply to receivers and operators: `fn:`, `int:`, and other
receivers have no dilemma between a call and an assignment, and their
forms and contracts do not change. Parentheses are admitted for receivers too and change nothing: `int(5)` and `int: 5` are the same.

Explicitly written arguments can be shortened in three ways.

**1. A nested method -- lexical binding.** A method inside another reads
the names of the enclosing scope:

```lmx
area: fn: int (w: int; h: int)
    doubled: fn: int ()
        return: w * h * 2
    return: doubled()
```

`area(3, 4)` gives 24; `doubled()` is called without arguments.

**2. Priority dynamic binding.** A callee's free name receives the
caller's nearest binding, ahead of lexical lookup:

```lmx
greet: sub: ()
    print(prefix + name)

welcome: sub: (name: Text)
    prefix: Text: "Hello, "
    greet()
```

`welcome("Ann")` prints `Hello, Ann`: `prefix` and `name` in `greet` come
from the activation of `welcome`. Without such an input and without a
lexical source, the call `greet()` is invalid.

**3. A sole Structure as the argument list** -- just as mathematics
substitutes a point into `f(x)`:

```lmx
sum: fn: int (x: int; y: int)
    return: x + y

p: {x: int: 3; y: int: 4}
r: int: sum(p)       # 7, as sum(3, 4) and sum(x: 3; y: 4)
```

The fields of `p` are matched against the formals at the invocation stage;
P0 does not expand the Structure ([semantics](new_LMX_semantics.en.md#whole-arguments)).

The same call may be written through `f():` -- the short `f(): args` or a
block:

```lmx
f():
. 3
end: f
```

This is an additional layout of the same call, with no separate `data`
selection, execution, or binding; ordinary code hardly ever needs it (the
author's example is an extremely long `print`).

Nested anonymous brackets read better when they alternate: start with
curly ones, use curly ones next to the parentheses of a call too, and round
ones inside curly ones: `{a * (b + {c - d})}`, `f({a b})` ([the author's
wishes of 2026-11-09](../LMX_blog/2026-11-09.md)). This is style, not a
parsing rule: no container is added or removed for appearance.

<a id="callable-description"></a>
## Explicit method-body composition

```lmx
add: fn: int (int: x; int: y) {}
    return: x + y

add5: fn: int (int: x) {}
    merge(y: int: 5; add\body)
```

`add` stores `return`, `args` with formals `x` and `y`, `var`, and `body`
with the `return: x + y` statement as separate parts. The `add\body` path
selects the body itself. `merge` builds an `add5` body containing `y: int: 5`
and that statement; `add5(1)` gives 6. The `add5` header declares only
formal `x`: the field `y` in its new body becomes neither a formal nor a
formal default. `merge(add; y: int: 5)` is not equivalent: the outer `add`
method Structure has `return`, `args`, `var`, and `body` parts, but no
immediate `y` field.

An alternative `add5` puts the initializer in explicit `var` and keeps
`add`'s body:

```lmx
add5: fn: int (int: x) {y: int: 5}
    add\body
```

A third, alternative definition changes `args` instead: here `y` is a
formal with default 5, not a body or `var` field:

```lmx
add5: fn: int merge(add\args; y: int: 5) {}
    add\body
```

These are three mutually exclusive definitions of `add5`, not three
consecutive declarations in one scope. The function name stands outside,
and the parts of the `fn` receiver come in the order `return args var body`.
The full `fn` form explicitly supplies `var` after `args`; the short source
form omits that argument but produces the same addressable empty `var` part.
Unary `int: x` describes a typed place without an initial value and,
in a signature, a formal without a default.

The `merge` result separately undergoes [admission](new_LMX_semantics.en.md#admission);
the body's free names follow [dynamic resolution](new_LMX_semantics.en.md#dynamic).

The header `add: fn: int (int: x; int: y)` **without a body** is the third
form: an interface descriptor that can be passed by reference but cannot
be invoked directly as an executable `add` body. With a body after that
header it is the short executable definition with an addressable empty
`var`. The full form with `{}` after `args` supplies `var` explicitly.

<a id="receiver-arities"></a>
## Places and values: separate names and type receivers

These are alternative spellings, not consecutive statements in one program:

```lmx
x: int()       # int place without an initial value
int: x         # the same place
x: int: 5      # int with value 5
x{ int: 5}     # the same value: name in the enclosing description

ptr: @()       # void reference without an initial address
@: ptr         # the same place
ptr: @: 0      # void reference with an explicit null address
ptr{ @: 0}     # the same value: name in the enclosing description
```

In `x{ int: 5}` and `x: int: 5`, the `int` receiver takes one operand `5`;
the name `x` belongs to the enclosing description. For a reference to an
existing Structure, `ptr: @: Model` and `ptr{ @: Model}` form another pair;
this is not an empty void pointer. A first definition allocates the place,
a repeated form with a candidate writes after admission, and a repeated
form without a candidate only checks the requirement.

<a id="callable-admission"></a>
## What the callable interface check proves

Methods with formals `{int: x; y: int: 5}` and `{int: x}` both accept `f(1)`, but a
Consumer's written call `f(1; y: 25)` accepts only the former. Admission
checks required explicitly used accesses, not equality of formal lists or
predicted body behavior. User-authored behavioral tests are a separate stage.

<a id="method-pointer"></a>
## A method name and a pointer to it

`myFunc()` directly calls a declared method. After `ptr: @: myFunc`,
`ptr()` calls through the pointer; repeated `ptr: @: otherFunc` assigns
another compatible method to that same cell. Bare `myFunc` or `ptr` only
reads a value. `{\ptr}()` calls after explicit dereference; `\ptr()`
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
neither selects code nor stores runtime names. The code/data split in `code(data)`
and addressable method parts are an [approved coding target](../next_core_tasks_v3.md);
the compatible ABI is not fully implemented yet.

<a id="factory-result"></a>
## A returned method

`add5: @: makeAdder(5)` **calls** the factory and stores the returned
method. `add5(1)` then calls it through the stored pointer. Merely defining
`add5: makeAdder 5` does not run the factory. If the returned method reads
free `n`, the caller's dynamic input takes precedence over a copied lexical
fallback.

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
and T01–T26 matrix are in the [semantics](new_LMX_semantics.en.md#thread-message-api)
and [mail plan](../next_core_tasks_v3.md).

<a id="tables-and-registries"></a>
## Tables and providers as data

An explicit Table can provide a spelling `u8 → "uint8_t"` or an
implementation key `plus(decimal)(int) → decimal_int_add`. It does not
declare types, create a runtime namespace, or search providers automatically.
Source precedence, conflict resolution, and a missing-cell marker belong to
the profile selected by the Table's consumer, not a universal hidden registry.
