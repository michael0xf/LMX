# LMX: Functional computation

Haskell is a natural control for Maybe/Monad and currying. Scala combines functional constructs with JVM execution, explicit trampolines and ordinary resource handling. The selection follows mechanisms rather than a universal brevity ranking.

The archive defines one current LMX core. Its operations are called directly; no selectable Maybe/Curry/Bounce library editions are supplied. Primary code is the shortest correct current-contract algorithm at the same comparison boundary. Ready components are available to clients in all three languages; implementation rows show actual bodies and shared infrastructure is counted separately. Former specialized listings remain adjacent as explanation and are excluded from the current count; they do not replace generic containers or callables with int restrictions.

## Files

- [Markdown](LMX_Comparison_09_functional_computation.md)
- [Excel](LMX_Comparison_09_functional_computation.xlsx)
- [PDF](LMX_Comparison_09_functional_computation.pdf)
- [CSV](LMX_Comparison_09_functional_computation.csv)
- [Current core dependencies and implementation cost](IMPLEMENTATION_DEPENDENCIES.md)
- [Validation](VALIDATION_2026-11-22.md)
- [Receiver API](../LMX_Fn_Receivers/API.md)

## Catalog

### [082. Monad](082_monad_comparision.md)

Two bind operations over generic Maybe; the application half still checks an integer for evenness.

**Companion implementation:** [091. Maybe container and bind implementation](091_maybe_container_and_bind_implementation_comparision.md)

**Primary variants:** LMX: core, Haskell: generic, Scala: generic.

**Scenario:** Apply half twice through bind. some retains a value record with its own type; next receives the payload through ordinary call admission. Absence skips the continuation. The probes remain 8, 6 and 3.

**Observation:** 8 yields present 2; 6 yields absence after the second half; 3 yields absence after the first half and skips the second. A prepared reference to half is not itself a call.

### [091. Maybe container and bind implementation](091_maybe_container_and_bind_implementation_comparision.md)

Generic Maybe separates presence from zero, null, void and physical uninit; bind may change the payload type.

**Usage examples:** [082. Monad](082_monad_comparision.md)

**Primary variants:** LMX: core, Haskell: generic, Scala: generic.

**Scenario:** Implement some(record), none() and bind(input,next). The payload is a typed value record; only the present tag determines absence. For presence, next is called exactly once with the payload.

**Observation:** some of zero remains present zero; some of null remains present null. none does not read value and bind(none,next) does not call next. The next result may carry a different type.

### [083. Trampoline](083_trampoline_comparision.md)

Mutual even/odd steps use generic Bounce with a nullary continuation created by partial.

**Companion implementation:** [092. Trampoline container and runner implementation](092_trampoline_container_and_runner_implementation_comparision.md), [099. General partial-application implementation](099_integer_partial_application_implementation_comparision.md)

**Primary variants:** LMX: core, Haskell: generic, Scala: generic.

**Scenario:** For nonnegative n, compute parity. An unfinished step returns more(partial(otherStep; (n−1))) without invoking the other step. trampoline invokes one retained thunk at a time until done.

**Observation:** 0 yields true, 1 false and 100001 false; LMX returns 1, 0, 0. Every step returns control to the driver; no nested even/odd call chain accumulates.

### [092. Trampoline container and runner implementation](092_trampoline_container_and_runner_implementation_comparision.md)

Generic Bounce holds an arbitrary result record or a nullary thunk; the runner does not know the result type or the original step arity.

**Usage examples:** [083. Trampoline](083_trampoline_comparision.md)

**Primary variants:** LMX: core, Haskell: generic, Scala: generic.

**Scenario:** Implement done(record), more(thunk) and trampoline(bounce). more stores the function without calling it; the runner calls it exactly once per iteration and returns the done result. Argument binding belongs to generic partial.

**Observation:** trampoline(done(record)) returns that result record without invoking a continuation. Each more invokes the retained thunk once. Parity yields 1,0,0 in LMX and true,false,false in the controls without accumulating a recursive step stack.

### [084. Execute Around](084_execute_around_comparision.md)

The client calls direct bracket; acquire/action/release and the observable log remain application code.

**Companion implementation:** [098. Execute Around implementation](098_execute_around_implementation_comparision.md)

**Primary variants:** LMX: core, Haskell: generic, Scala: generic.

**Scenario:** The resource contains 42. acquire appends 1 to a log, action 2 and release 3. Mode 0 succeeds, mode 1 fails in action and mode 2 in acquisition. The client uses the same ready bracket abstraction in all three languages and catches the failure only to observe the log.

**Observation:** run(0) yields 42123: result 42 and log 123. run(1) yields −123: body failure reaches the client after release. run(2) yields −1: acquisition failed and no release ran. The resource is not used after cleanup.

### [098. Execute Around implementation](098_execute_around_implementation_comparision.md)

Generic acquire/action/release: the resource, payload result and extra arguments are not tied to int.

**Usage examples:** [084. Execute Around](084_execute_around_comparision.md)

**Primary variants:** LMX: core, Haskell: generic, Scala: generic.

**Scenario:** After successful acquire, register release(resource), then invoke action(resource; additionalArgs...). Retain a typed result record or void. Acquisition failure does not call release; after successful acquisition release runs exactly once on ordinary exit.

**Observation:** Success: log 123 and the action result. Body failure: log 123 and propagation. Acquisition failure: log 1 and no release. The adjacent client encodes these cases as 42123, −123 and −1.

### [085. Currying](085_currying_comparision.md)

Direct partial builds add5 and add100 from an ordinary function; environment copying belongs to the generic implementation.

**Companion implementation:** [099. General partial-application implementation](099_integer_partial_application_implementation_comparision.md)

**Primary variants:** LMX: core, Haskell: generic, Scala: generic.

**Scenario:** Declare addition and call partial(add;(5)) and partial(add;(100)). Obtain 6,101,6 after the factory completes. Local saved=1000 does not change retained values. The prefix is a Structure of records, not a hidden int-only list.

**Observation:** 6, 101, 6; demo returns 6101006. The returned function has exactly one explicit int input. The LMX library prototype is unchanged and the two created functions are independent.

### [099. General partial-application implementation](099_integer_partial_application_implementation_comparision.md)

General partial(F;prefix): an arbitrary heterogeneous signature, 0≤k≤N, exact residual contract and original return.

**Usage examples:** [085. Currying](085_currying_comparision.md), [083. Trampoline](083_trampoline_comparision.md)

**Primary variants:** LMX: core, Haskell: generic, Scala: generic.

**Scenario:** Reflect F, admit and retain k input records, then build a callable for the remaining N−k positions. Captured primitives are snapshots; references retain target identity. k=0 and k=N are valid and F is not invoked early.

**Observation:** The general case retains input order/types, exact R and declared failures. The addition client yields 6,101,6. N=0 produces a nullary callable; k>N fails before publishing a result.

## Counting boundary

Only primary listings are measured; each is the shortest eligible current-contract algorithm in its language. Historical LMX source remains beside current code. Current core dependencies and shared infrastructure are accounted separately. No runtime execution is implied.
