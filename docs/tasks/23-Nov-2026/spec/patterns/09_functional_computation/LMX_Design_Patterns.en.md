# LMX: Functional computation

Haskell is a natural control for Maybe/Monad and currying. Scala combines functional constructs with JVM execution, explicit trampolines and ordinary resource handling. The selection follows mechanisms rather than a universal brevity ranking.

Four usage scenarios call the LMX core and actual Haskell/Scala facilities. Four adjacent comparisons implement the corresponding components independently; clients do not import them. Only approach-level alternatives remain.

## Files

[Comparison](LMX_Comparison_09_functional_computation.md) · [Excel](LMX_Comparison_09_functional_computation.xlsx) · [PDF](LMX_Comparison_09_functional_computation.pdf) · [CSV](LMX_Comparison_09_functional_computation.csv) · [Implementations](IMPLEMENTATION_DEPENDENCIES.md)

## Catalog

### [082. Monad](082_monad_comparision.md)

Two bind operations over generic Maybe; the application half still checks an integer for evenness.

Apply half twice through bind. some retains a value record with its own type; next receives the payload through ordinary call admission. Absence skips the continuation. The probes remain 8, 6 and 3.

8 yields present 2; 6 yields absence after the second half; 3 yields absence after the first half and skips the second. A prepared reference to half is not itself a call.

### [091. Maybe container and bind implementation](091_maybe_container_and_bind_implementation_comparision.md)

Generic Maybe separates presence from zero, null, void and physical uninit; bind may change the payload type.

Implement some(record), none() and bind(input,next). The payload is a typed value record; only the present tag determines absence. For presence, next is called exactly once with the payload.

some of zero remains present zero; some of null remains present null. none does not read value and bind(none,next) does not call next. The next result may carry a different type.

### [083. Trampoline](083_trampoline_comparision.md)

Mutual even/odd steps use generic Bounce with a nullary continuation created by partial.

For nonnegative n, compute parity. An unfinished step returns more(partial(otherStep; (n−1))) without invoking the other step. trampoline invokes one retained thunk at a time until done.

0 yields true, 1 false and 100001 false; LMX returns 1, 0, 0. Every step returns control to the driver; no nested even/odd call chain accumulates.

### [092. Trampoline container and runner implementation](092_trampoline_container_and_runner_implementation_comparision.md)

Generic Bounce holds an arbitrary result record or a nullary thunk; the runner does not know the result type or the original step arity.

Implement done(record), more(thunk) and trampoline(bounce). more stores the function without calling it; the runner calls it exactly once per iteration and returns the done result. Argument binding belongs to generic partial.

trampoline(done(record)) returns that result record without invoking a continuation. Each more invokes the retained thunk once. Parity yields 1,0,0 in LMX and true,false,false in the controls without accumulating a recursive step stack.

### [084. Execute Around](084_execute_around_comparision.md)

Supplied acquire/action/release callbacks surround protected resource use. The shortest LMX includes its local helper in full; generic bracket remains a current alternative.

The resource contains 42. acquire appends 1 to a log, action 2 and release 3. Mode 0 succeeds, mode 1 fails in action and mode 2 in acquisition. Use core bracket, Haskell Control.Exception.bracket, or Scala Using.resource; each releases only an acquired resource and the client observes the failure and log.

run(0) yields 42123: result 42 and log 123. run(1) yields −123: body failure reaches the client after release. run(2) yields −1: acquisition failed and no release ran. The resource is not used after cleanup.

### [098. Execute Around implementation](098_execute_around_implementation_comparision.md)

Generic acquire/action/release: the resource, payload result and extra arguments are not tied to int.

Implement the complete single-resource bracket contract: acquire once; action once; release once after successful acquisition on success, declared failure or supported orderly interruption; preserve arbitrary result/void. LMX preallocates cleanup actuals and registers outcome-guarded finally before acquiring, Haskell uses mask/restore, Scala preserves dual failures using Using-style severity and suppression.

Success: log 123 and the action result. Body failure: log 123 and propagation. Acquisition failure: log 1 and no release. The adjacent client encodes these cases as 42123, −123 and −1.

### [085. Currying](085_currying_comparision.md)

Direct partial builds add5 and add100 from an ordinary function; environment copying belongs to the generic implementation.

Declare addition and create two independent bindings add5/add100 through staged curry or partial. Native Haskell application and Scala Function2.curried provide the control clients. Keep saved=1000 and the repeated add5(1); the result is 6101006.

6, 101, 6; demo returns 6101006. The returned function has exactly one explicit int input. The LMX library prototype is unchanged and the two created functions are independent.

### [099. General partial-application implementation](099_integer_partial_application_implementation_comparision.md)

General partial(F;prefix): an arbitrary heterogeneous signature, 0≤k≤N, exact residual contract and original return.

Implement arbitrary typed prefix binding with no int-only values or fixed binary arity. Capture k of N inputs in order and return an ordinary callable for N-k inputs without calling the target. Haskell Args/Callable and Scala Tuple/Callable encode input vectors explicitly; LMX reflects existing callable DATA and preserves its richer defaults/binding contract.

The general case retains input order/types, exact R and declared failures. The addition client yields 6,101,6. N=0 produces a nullary callable; k>N fails before publishing a result.

## Counting boundary

For each comparable usage layer choose the shortest eligible core/real-library client. Implementation comparisons use full scoped APIs separately. Keep only genuinely different approaches; one-line or type-only alternatives are notes. The source upload is the merge baseline.

Runtime status: LMX, Haskell and Scala NOT_RUN. Prepared edge cases are in [acceptance_cases.json](acceptance_cases.json).
