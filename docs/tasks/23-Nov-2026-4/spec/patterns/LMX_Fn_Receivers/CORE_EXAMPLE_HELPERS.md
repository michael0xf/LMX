# Core helpers extracted from the example comparisons

## `between`

The ordinary prepared operand accepts one value on the left and exactly two
bounds on the right. It uses the existing comparison operations on their actual
types: inclusive `lower <= value && value <= upper`. A reversed interval is false.
No conversion to int or char is introduced. Unordered floating values follow the
existing comparison contract. Incompatible types fail by ordinary admission;
`RangeArity` is the declared exit for any right length other than two.

The complete source is [coreComparisonExamples.lmx](src/coreComparisonExamples.lmx).
The common operand template comes first. `PRIORITY` is the existing priority of
`<=`, explicitly replacing the template default. The ordinary one-level operand
opening rule is unchanged; no special flattening, evaluation or parser is added.
The foreign usage client uses `Data.Ix.inRange`; the standalone comparison uses
an `Ord a` implementation and makes that broader domain explicit.

## `iterateUntilStop`

Inputs are the accepted iteration declaration and associated body. The declaration
is DATA at reception; its initializer is not run just to pass it. Each iteration
executes that form once in the receiving activation and then its body once using
the established live places. There is no element-type, element-count or array-size
cap. A zero yielded value is ordinary data. Only a `Stop` from the iteration form
ends the loop; an unrelated step failure or any body failure, including body Stop,
leaves as `FxCallFailure` with its original name and typed payload. The finite
public exit set is `FxCallFailure FxKernelFailure FxTypeToken`.

### Required integration gate AE01: `FxKernel\attemptAccepted(form)`

This is one explicit additional provider, declared by `FxKernelAttemptAcceptedAPI`.
It is not supplied by the LMX source package and cannot be replaced by the generic
callable `apply` operation without proving the receiving-context contract.

1. The provider operates only in the immediate LMX receiving activation that made
   this core call. It accepts no arbitrary frame or namespace handle.
2. Resolve the already accepted actual occurrence associated with the provider's
   supplied input place in that immediate receiving activation. A graph address
   alone is insufficient: equal pointers at two accepted positions can have
   different provenance. Retain ordinary currentCall/frameSlot/actual metadata
   during this narrow provider call; do not reselect by pointer equality or the
   declaration's internal name. Reject a form that was not accepted there or whose
   occurrence provenance is unavailable. No extra public frame handle is exposed.
   Preserve the already selected declaration/body form, declaration provenance,
   lexical source node, destination places and live caller bindings. No new
   ordinary callable activation is inserted around the form.
3. Determine the finite admitted declared exits from the reached form through the
   existing compiler/interpreter effect model. This observation executes neither
   the initializer nor the body and grants no wildcard `throws` permission.
4. Execute the accepted form exactly once in that receiving activation. Return the
   existing `FxOutcome` shape `{ok, value, failure, payload}`. Declared exits use
   their canonical names and live typed payload records. Implicit failures,
   Message stop/abort and invariant failures retain their normal runtime paths.
5. A declaration's selected place remains the same place seen by its associated
   body and the surrounding receiver invocation. The operation does not copy
   `total` into a fresh closure, run a declaration to fit an int argument, or expose
   native stack addresses.
6. No service frame escapes the provider; all returned records obey the existing
   arena lifetime contract.

This gate is **NOT_RUN**. The full LMX loop and finite outward error handling are
written; executing it requires this exact bridge. It must pass all four
interpreter/native caller-callee combinations, not only a text check.

Acceptance: empty source gives 1 step/0 bodies; `1,2,3,Stop` gives 4/3 and total 12;
`-2,0,4,Stop` with the documented body gives total 22; body sees updates to `item`;
caller `total` changes live; step failure retains name/payload; body Stop propagates;
implicit failure is never an end marker; initializer is not run on transmission;
the same graph form accepted at two positions retains distinct occurrence
provenance; a reused declaration through a nested ordinary call binds only to
that call's receiving activation, not an older or factory namespace.

## Ownership and asynchronous requests

Neither helper is a scheduler. `between` has no mutable state. The loop and lazy
cache run on their owning Message and use only that Message's arena. To execute
the owner method asynchronously, use ordinary `post`; reply waiting, ordering,
transport failure and HTTP transport remain the existing Message facilities.
No second task/future layer or foreign mutable pointer is needed. The helpers do
not promise that an owner can process another event while a synchronous body is
running, nor do they add forced interruption or cancellation guarantees.

Haskell comparison implementations use ordinary monadic sequencing; the usage
client imports real `monad-loops` `whileJust_`. `Lazy.hs` enforces one owning thread,
rejects foreign use, detects recursion, caches the first success and restores its
cold state under synchronous/asynchronous failure. It is not advertised as a
shared concurrent cache. The LMX equivalent relies on existing Message ownership
rather than duplicating that ownership check in each cache operation.
