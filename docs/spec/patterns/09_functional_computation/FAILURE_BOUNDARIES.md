# Functional operations: failure, cleanup and Message boundaries

This edition compares procedural and functional LMX clients for the same observable scenarios, alongside the unchanged real Haskell and Scala library clients. The separate implementation comparisons remain independent programs. In particular, `Around` names the comparison implementation; it is not the module imported by the Haskell or Scala usage client.

<a id="trampoline"></a>
## 083: trampoline and ordinary failures

The [functional LMX client](examples/lmx/083_trampoline.lm3) declares its finite failure list once in `Steps\Throws`; the shared step, two entry methods and `Example\run` reuse it with `copy`. `trampoline` is an ordinary core receiver. Prefix `\` in `\trampoline(...)` reads its returned value record; it is not part of the receiver's name.

`throws` describes exits propagated by this callable. Its caller must handle or redeclare those names under [the ordinary LMX rule](../../LMX_semantics.en.md#exceptions). Haskell and Scala parity functions are likewise callable components, not complete applications. No silently swallowed error or invented successful parity value is added to make them shorter.

The former full-file variant that merely added an outer `catch` duplicated the whole step algorithm. It has been removed. If an application wants a Result boundary, the only relevant additional handler is `catch: FxCallFailure (@: outcome)` followed by `return: err(outcome)`; the adaptive constructor captures the failure record as a value without reading or comparing its contents. Other declared failures still need that application's policy. This is a description of the local change, not a second standalone listing.

`done`, `more`, and `trampoline` implement stack control within one call; they are not futures. For asynchronous use, send the entire trampoline invocation through `post` to its owner Message. The existing transport carries the final result/failure. A thunk and the state it references remain in the receiving owner's arena. No second asynchronous trampoline runtime is needed, and timeout alone does not cancel the operation.

The [procedural parity client](examples/lmx/procedural/083_trampoline.lm3) uses an explicit loop for the same finite nonnegative inputs0/1/100001. It is a comparison of this client scenario, not a replacement for the arbitrary-payload Bounce implementation in092.

<a id="execute-around"></a>
## 084: complete local Around and shared bracket

The [functional LMX client](examples/lmx/084_execute_around.lm3) calls `bracket`. The [procedural LMX client](examples/lmx/procedural/084_execute_around.lm3) includes the complete local `Around` helper with ordinary `finally` and the original named `ResourceFailure` handler. Both are compared in full; neither style is excluded by shortest-source selection. Both reuse one Trace\eval and one Trace\code. The shared kernel implementation remains one separate body in098.

Both LMX styles and the two unchanged foreign clients preserve the resource field `value = 42`, acquire/action/release callbacks, and trace. Their common observations remain:

| Mode | Outcome | Trace | Encoded result |
| ---: | --- | ---: | ---: |
| 0 | Successful action and cleanup | 123 | 42123 |
| 1 | Action fails, cleanup runs | 123 | −123 |
| 2 | Acquisition fails; there is no acquired resource to release | 1 | −1 |

Haskell imports `Control.Exception.bracket` and uses `try` to inspect the application failure. Scala imports `scala.util.Using` and invokes `Using.resource` with an explicit `Releasable[Resource]`. Neither client imports the comparison module `Around`.

LMX's general record API carries an admitted callback failure in `FxCallFailure`. In this closed example acquire/action declare only ResourceFailure and release declares none. The functional handler can therefore return the negative trace without comparing failure-name text; infrastructure exits remain separate. The procedural style catches the original ResourceFailure directly. See [the exact boundary](review/084_failure_boundary.md). This envelope is a contract of the generic API, not a new rule for every ordinary LMX call.

## 098: full single-resource implementations

The scope is one acquired resource, one action and one release operation, with an arbitrary result, including void/Unit. It does not claim to implement every method of Haskell's exception package or the multi-resource `Using.Manager` API. Nested resource management uses nested ordinary calls; the implementations must not discard the inner cleanup obligation.

### LMX

[FxAround](../LMX_Fn_Receivers/src/generic_wrappers.lmx) allocates the one-cell cleanup argument vector **before acquisition**. It stores the successful `FxApply` result directly in that existing `[]@` cell, then registers `finally` before constructing the action argument vector. No second allocation, type admission or duplicate acquired/ok state is introduced between the acquisition result and handler registration. Failed acquisition exits before the handler is registered. Failure while constructing the later action arguments runs cleanup with the recorded resource. The runtime must preserve the returned typed record and ordinary orderly-exit semantics across this source-level store/registration sequence; the listing does not claim Haskell asynchronous masking or native atomicity.

Acquisition failure does not run release. A normal result is retained before cleanup, and the resource is released once when the activation exits. A declared failure from the action triggers the same cleanup. Cleanup failure follows [ordinary LMX finally semantics](../../LMX_semantics.en.md#exits); this component does not invent an exception-suppression table. The runtime must retain the ordinary cleanup obligations of outer scopes.

This arrangement does not invent an atomic instruction or Haskell-style masking. Transfer of a successful acquired resource through `FxKernel\attempt` into the receiving outcome is still the provider's ordinary ownership/lifetime integration contract; the wrapper does not prove correctness inside that native boundary. A stop request cannot be treated as permission to drop a successfully transferred outcome or bypass its already registered cleanup.

Calling release still needs ordinary call preparation. A fatal runtime/allocator failure in that preparation cannot honestly be reported as successful external resource release. Likewise, abrupt process termination can prevent language-level cleanup. These are runtime boundaries, not successful-path simulations hidden in the implementation.

The [Message model](../../LMX_semantics.en.md#thread-message-api) already supplies asynchronous delivery: post the **whole owner operation** that acquires, uses and releases the resource. Resource state stays in that Message's arena, and completion is returned through the ordinary prepared reply path. This bracket remains one ordinary activation on one owner lane. It neither shares a raw resource with another Message nor invents a second scheduler.

If action only posts another request and immediately returns, the bracket lifetime ends at that return; it does not wait for the later request. Such a different lifetime requires an owner protocol that explicitly retains the resource until its own completion path. The current single-call bracket does not pretend to provide that protocol. `unanswered`/timeout alone does not cancel work or authorize early release. Ordinary orderly stop/cancellation runs registered cleanups; LMX does not inject Haskell-style asynchronous exceptions between arbitrary expressions.

### Haskell

The [comparison implementation](examples/haskell/098_execute_around_implementation.hs) uses `mask`, restores the caller's masking state while running action, captures its `SomeException`, then releases and propagates the saved outcome. Acquisition and cleanup remain in the masked region. Acquisition failure skips release. Cleanup is attempted once; if both action and release fail, release's failure escapes, matching the chosen `bracket` contract. A saved successful result is not forced more deeply than the action requires.

`mask` is interruptible at designated blocking operations. The implementation does not replace it with `uninterruptibleMask`, and does not promise that an arbitrarily blocking release cannot be interrupted. See [GHC Control.Exception](https://downloads.haskell.org/ghc/9.6.7.20250131/docs/libraries/base-4.18.3.0/Control-Exception.html).

### Scala

The [comparison implementation](examples/scala/098_execute_around_implementation.scala) releases once after successful acquisition. When both action and cleanup throw, it retains the primary exception and attaches the other as suppressed, using the documented `Using` severity order; identical exception objects are not self-suppressed. A `ControlThrowable` or another Throwable with suppression disabled retains its own JVM behavior.

This is the full declared single-resource callback API with `Using`-style dual-failure policy, not an implementation of `Using.Manager`. JVM interruption follows ordinary thrown exceptions; there is no claim of Haskell masking. The actual client uses standard `Using.resource`. See [Scala Using](https://www.scala-lang.org/api/2.13.16/scala/util/Using$.html).

## 091, 092, 099: generic values and arity

The complete Maybe constructor/bind and Bounce constructor/runner APIs retain arbitrary payload types. Absence is distinct from a present zero, empty string, reference or callable value. A final callable value is returned by `done`, not invoked merely because it is callable. `more` stores a nullary callable; use full-prefix `partial` to construct one where necessary.

Partial application in [099](099_integer_partial_application_implementation_comparision.md) now has arbitrary typed input vectors in all three implementations. Haskell uses `Args` with a type-level list and `Callable`; Scala uses `Tuple` and `Tuple.Concat`. Empty and full prefixes do not execute the target during construction. A full prefix returns a nullary callable (`Nil`/`EmptyTuple` in the foreign comparison API). `Unit`/`()`, reference values, mixed types and independent captures are supported. There is no fixed binary or integer-only implementation.

LMX additionally preserves its existing DATA declarations, deferred defaults and dynamic-binding rules through its ordinary adapter hooks. The typed Haskell/Scala components reject incompatible prefix shapes statically; they do not claim to emulate every LMX namespace rule. These differences remain explicit in the comparison.

## Validation

[Prepared acceptance cases](acceptance_cases.json) cover payload presence, thunk/result distinction, acquisition/action/release failure, dual failure, interruption, mixed prefixes, empty/full binding, void and independence. All runtime statuses are **NOT_RUN**. The archive provides source implementations and static publication checks, not an executed LMX kernel or foreign compiler result.
