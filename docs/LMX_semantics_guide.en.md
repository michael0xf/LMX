# LMX semantics: worked explanations

These examples are non-normative explanations. Language rules are in the [semantics specification](LMX_semantics.en.md), which governs if the two differ. Longer derivations belong here rather than in the normative text.

<a id="callable-description"></a>
## Callable descriptions in `merge`

In `fn: add5 (int: x) int merge(add; y: 5)`, the `add5` header describes the receiving place. It is not a third `merge` operand. A header with only one required argument does not remove the selected body `add`'s other formals or change its machine ABI.

The added `y: 5` gives formal `y` a default. It neither takes a same-named value from the caller nor removes `y` from the signature. This is a semantic illustration, not new syntax:

```text
add5: the formal y of add has the default value 5; x is required
add5(1)                        -> 6
add5(1; y: 25)                 -> 26    (y stays an explicitly passable formal)
add5(1; y: 0)                  -> 1     (zero is a supplied value, not an absent one)
caller holds its own y = 25, passes no y:  add5(1) -> 6   (a formal is not a free input)
add5(1; y: 25), then add5(1)   -> 26, then 6   (one call's argument is not a new default)
```

If the program explicitly composes description Structures, the ordinary `merge` field rule applies. For instance, omitting `y` from a complement `args = [x]` does not delete `y` from the source `args = [x, y]`. The result still undergoes [admission](LMX_semantics.en.md#admission), while the body's free names follow ordinary [dynamic resolution](LMX_semantics.en.md#dynamic).

<a id="callable-admission"></a>
## What the callable interface check proves

A method with formals `x` and `y = 5` and one with only `x` both accept `f(1)`. But only the former accepts the Consumer's written call `f(1; y: 25)`. Each actual use is checked, not equality of original formal lists or predicted body behavior. Merely transporting a method reference does not make unknown future calls into uses already written. Behavioral checks are the receiving expression's separate user-authored tests.

<a id="method-pointer"></a>
## A method name and a pointer to it

```text
fn: myFunc () int
    return: 7
@: ptr myFunc

myFunc()    # direct call of the declared method
\ptr()     # call through the pointer
ptr()      # same as ptr: (); attempt to assign an empty Structure
ptr: a     # attempt to assign value a to the pointer
```

The common surface form “head with arguments” does not turn a reference field into a method. Assignment admission for `ptr()` may fail; that does not license executing the method instead.

<a id="native-merge"></a>
## Native code in a copy

It helps to distinguish instance data from executable code. A method copied with different data can use the same native implementation: the implementation receives the copy's graph. If `merge` selects another operand's code, the old implementation address no longer describes the selected code; the selected code's implementation is used if one exists. Otherwise the completed graph runs in the interpreter. A change of values in a structural part called `body` does not by itself prove that the algorithm changed.

Nested methods remain full copies of their occurrences. The machine implementation address may be shared; the mutable instance and its lexical state are not. Different physical field positions are reconciled by the address map of a successful `implements`, and maps may compose across successive compositions. A map neither chooses code nor acts as a runtime name table.

<a id="factory-result"></a>
## A returned method

Here `makeAdder(5)` actually runs while initializing the reference, and `\add5(1)` later invokes the returned method by address:

```text
fn: makeAdder (int: n) fn: (int: x) int
    fn: addN (int: x) int
        return: n + x
    return: addN

@: add5 makeAdder(5)
@: add100 makeAdder(100)

[\add5(1); \add100(1); \add5(1)]
```

Without caller-supplied dynamic `n`, the expected result is `[6 101 6]`. Defining the unknown head `add5: makeAdder 5` would not evaluate the factory. The value `n` in the copied lexical tree remains the fallback source for a free name, not a hidden closure overriding the caller's dynamic input.

<a id="dynamic-fallback"></a>
## Dynamic and lexical sources

This table illustrates resolution of a free `x`, not a method formal; it is not LMX syntax:

```text
copied lexical context:  x = 10
caller supplies:         x = 25
read x       -> 25
read node\x  -> 10
next call, caller supplies x = 40:  read x -> 40
no dynamic x from any source:       read x -> 10
no admissible source at all:        ordinary missing-input diagnostic
```

<a id="message-conversion-context"></a>
## Message conversion context

`a → int`, `Foot → Meter`, and the arrows below illustrate relations; they are not LMX syntax or another runtime name table. Descriptions, relations, and converters travel as ordinary graph values.

```text
Message A:  a → int;     String → int
Message B:  a → String;  no String → int
```

Both Messages may use the same `fn: identity (a: x) a`: every use of `a` inside A is consistent with `int`, while inside B it is consistent with `String`. B does not inherit A's conversion merely because of parenthood or delivery. This does not instantiate a fresh generic parameter on each call.

For primitive semantic values, `Foot → Meter` is an ordinary explicitly available conversion. Its presence does not mean an arbitrary Structure `Foot` fits a Structure `Meter`; that is a separate `implements` question. Analytical admission does not run the converter; actual consumption checks its result against its contract, including range and precision.

A call may require two distinct successive conversions: an actual `int` to the selected method's required `double`, then its returned `double` to the Consumer's expected `int`. Both routes must be available in this Message's context.
<a id="post-transport"></a>
## `post`: one call, multiple deliveries

Q1–Q3 and R1–R3 below are explanatory labels, not LMX fields. Every `answer` branch is prepared before the `ask` requests are sent.

```text
post:
. ask:
. . getPixel: x y
. . getPixel: x + 1, y + 1
. . getPixel: x + 2, y + 2
. answer:
. . setRed: uint32: rgb
. . setGreen: uint32: rgb
. . setYellow: uint32: rgb
. timeout: ms: int: time 500
. undelivered: (getPixel: method; int: x; int: y)
. . log\error: "undelivered: " method "( x: " x " y: " y " )"
. unanswered: (ms: int: time; getPixel: method; int: x; int: y)
. . log\error:
. . . "unanswered after " time " ms "
. . . method "( x: " x " y: " y " ) timeout: " timeout\ms\time
. . end: error
. catch: axisOutOfBound (int: value; int: number)
. . println: "axis: " number " value: " value
```

If every call returns, three `getPixel` executions produce three results, each sent to three destinations: nine subsequent deliveries, not nine `getPixel` executions. Reply arrival order does not change correlation with source letters. No `answer` row is paired by position with an `ask` row.

If Q2 is undelivered, `undelivered` receives Q2's original recipient and already formed arguments, such as `11, 21` when the source had `x = 10` and `y = 20`. Q1 and Q3 continue. If Q2 raises its declared `axisOutOfBound`, `catch` receives that payload; mail does not derive it from request coordinates. Q2 then has no result for `answer`.

If Q2 waits beyond `500` ms, `unanswered` receives timing relative to the source send. It might be `512` while `timeout\ms\time` remains `500`. Logging does not cancel the request or remove routes: a late reply still follows them unless user code explicitly chooses another policy. Failure to deliver an already computed result to one of `setRed`/`setGreen`/`setYellow` does not relabel a successful Q2 as “source request undelivered.”

Older proposals in which a bodyless letter invokes every method, `answer` fills a public API, internal answers are numbered, or mail maintains a separate signature table are superseded. The [normative contract](LMX_semantics.en.md#thread-message-api) does not depend on those designs.

<a id="tables-and-registries"></a>
## Tables and providers as data

In an optional table profile, a row keyed `u8` with `spelling = "uint8_t"` lets an explicit query obtain a target C spelling. This does not declare a new LMX type or turn the Table into a global runtime namespace. A row `plus[decimal][int] → decimal_int_add` can similarly provide an implementation key; linked Tables separately give result, effect, lowering, and provider. A `pure` cell remains a description's claim, not automatic proof of purity.

Representing pairs as a matrix or grouped by operand, source order, numeric priority, and conflicts are explicit policies of the table consumer. A profile may use `None` as its missing-cell marker; that is not a universal numeric zero. Concrete expanded Tables and source excerpts remain in the [L1 specification](L1_spec_en.md); they illustrate data rather than additional Structure-lookup rules.
