# LMX semantics: worked explanations

These are short non-normative examples. The [semantics](LMX_semantics.en.md)
and [grammar](LMX_grammar.en.md) govern if they differ.

<a id="callable-description"></a>
## Explicit method-body composition

```lmx
fn: add (int: x; int: y) int
    return: x + y
end: add

fn: add5 (int: x) int
    merge(y: 5; add\body)
end: add5
```

`add` stores `args` with formals `x` and `y`, `return`, `var`, and `body`
with the `return: x + y` statement as separate parts. The `add\body` path
selects the body itself. `merge` builds an `add5` body containing `y: 5`
and that statement; `add5(1)` gives 6. The `add5` header declares only
formal `x`: the field `y` in its new body becomes neither a formal nor a
formal default. `merge(add; y: 5)` is not equivalent: the outer `add`
method Structure has `args`, `return`, `var`, and `body` parts, but no
immediate `y` field.

The `merge` result separately undergoes [admission](LMX_semantics.en.md#admission);
the body's free names follow [dynamic resolution](LMX_semantics.en.md#dynamic).

<a id="callable-admission"></a>
## What the callable interface check proves

Methods with formals `(x; y = 5)` and `(x)` both accept `f(1)`, but a
Consumer's written call `f(1; y: 25)` accepts only the former. Admission
checks required explicitly used accesses, not equality of formal lists or
predicted body behavior. User-authored behavioral tests are a separate stage.

<a id="method-pointer"></a>
## A method name and a pointer to it

`myFunc()` directly calls a declared method. After `@: ptr myFunc`,
`ptr()` calls through the pointer; repeated `@: ptr otherFunc` assigns
another compatible method to that same cell. Bare `myFunc` or `ptr` only
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
neither selects code nor stores runtime names. The `call: code data` split
and addressable method parts are an [approved coding target](../next_core_tasks_v3.md);
the compatible ABI is not fully implemented yet.

<a id="factory-result"></a>
## A returned method

`@: add5 makeAdder(5)` **calls** the factory and stores the returned
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
and T01–T26 matrix are in the [semantics](LMX_semantics.en.md#thread-message-api)
and [mail plan](../next_core_tasks_v3.md).

<a id="tables-and-registries"></a>
## Tables and providers as data

An explicit Table can provide a spelling `u8 → "uint8_t"` or an
implementation key `plus[decimal][int] → decimal_int_add`. It does not
declare types, create a runtime namespace, or search providers automatically.
Source precedence, conflict resolution, and a missing-cell marker belong to
the profile selected by the Table's consumer, not a universal hidden registry.
