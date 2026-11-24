# LMX: Functional computation

Haskell is a natural control for Maybe/Monad and currying. Scala combines functional constructs with JVM execution, explicit trampolines and ordinary resource handling. The selection follows mechanisms rather than a universal brevity ranking.

Four tasks have complete procedural and functional LMX variants. Existing Haskell and Scala controls are unchanged. Four implementation comparisons each retain one common canonical LMX body.

## Каталог / Catalog

### [082. Monad](082_monad_comparision.md)

Maybe: explicit intermediate branching and a compact bind chain.

Evaluate some(x) bind half bind half. The payload keeps its actual type and half receives it through ordinary admission. None skips subsequent continuations. The probes include 8, 6, 3 and 0.

8 yields present 2; 6 yields absence after the second half; 3 yields absence after the first half and skips the second. A prepared reference to half is not itself a call.

### [091. Maybe container and bind implementation](091_maybe_container_and_bind_implementation_comparision.md)

Generic Maybe separates presence from zero, null, void and physical uninit; bind may change the payload type.

Implement some(record), none() and bind(input,next). The payload is a typed value record; only the present tag determines absence. For presence, next is called exactly once with the payload.

some of zero remains present zero; some of null remains present null. none does not read value and bind(none,next) does not call next. The next result may carry a different type.

### [083. Trampoline](083_trampoline_comparision.md)

Parity: an explicit loop and a functional trampoline for finite nonnegative n.

For nonnegative n, compute parity. An unfinished step returns more(partial(otherStep; (n−1))) without invoking the other step. trampoline invokes one retained thunk at a time until done.

0 yields true, 1 false and 100001 false; LMX returns 1, 0, 0. Every step returns control to the driver; no nested even/odd call chain accumulates.

### [092. Trampoline container and runner implementation](092_trampoline_container_and_runner_implementation_comparision.md)

Generic Bounce holds an arbitrary result record or a nullary thunk; the runner does not know the result type or the original step arity.

Implement done(record), more(thunk) and trampoline(bounce). more stores the function without calling it; the runner calls it exactly once per iteration and returns the done result. Argument binding belongs to generic partial.

trampoline(done(record)) returns that result record without invoking a continuation. Each more invokes the retained thunk once. Parity yields 1,0,0 in LMX and true,false,false in the controls without accumulating a recursive step stack.

### [084. Execute Around](084_execute_around_comparision.md)

The complete local Around and functional bracket preserve one resource lifecycle.

The resource holds42. acquire/action/release append1/2/3 to the trace. Both complete LMX styles preserve success, action failure and acquisition failure; only an acquired resource is released.

run(0) yields 42123: result 42 and log 123. run(1) yields −123: body failure reaches the client after release. run(2) yields −1: acquisition failed and no release ran. The resource is not used after cleanup.

### [098. Execute Around implementation](098_execute_around_implementation_comparision.md)

Generic acquire/action/release: the resource, payload result and extra arguments are not tied to int.

Implement the complete single-resource bracket contract: acquire once; action once; release once after successful acquisition on success, declared failure or supported orderly interruption; preserve arbitrary result/void. LMX preallocates cleanup actuals, stores the successful acquisition in the ready cell and registers finally before preparing the action. Haskell uses mask/restore; Scala preserves dual failures using Using-style severity and suppression.

Success: log 123 and the action result. Body failure: log 123 and propagation. Acquisition failure: log 1 and no release. The adjacent client encodes these cases as 42123, −123 and −1.

### [085. Currying](085_currying_comparision.md)

Independent captured prefixes: direct environments and the common curry operation.

Declare addition and create independent prefixes 5 and 100 through staged curry or partial. Reuse add5 twice and immediately call the one-use 100 branch. Native Haskell application and Scala Function2.curried provide the control clients; the result is 6101006.

6, 101, 6; demo returns 6101006. The returned function has exactly one explicit int input. The LMX library prototype is unchanged and the two created functions are independent.

### [099. General partial-application implementation](099_integer_partial_application_implementation_comparision.md)

General partial(F;prefix): an arbitrary heterogeneous signature, 0≤k≤N, exact residual contract and original return.

Implement arbitrary typed prefix binding with no int-only values or fixed binary arity. Capture k of N inputs in order and return an ordinary callable for N-k inputs without calling the target. Haskell Args/Callable and Scala Tuple/Callable encode input vectors explicitly; LMX reflects existing callable DATA and preserves its richer defaults/binding contract.

The general case retains input order/types, exact R and declared failures. The addition client yields 6,101,6. N=0 produces a nullary callable; k>N fails before publishing a result.

## Методика / Method

Two complete LMX style clients are compared for082–085; neither is removed by a shortest-source selection. All declarations and Throws count in full. Shared implementation records091/092/098/099 retain one canonical LMX body; foreign clients retain their observable contract; 085 removes the same unused and single-use locals in Haskell and Scala.

[Comparison](LMX_Comparison_09_functional_computation.md) · [Excel](LMX_Comparison_09_functional_computation.xlsx) · [PDF](LMX_Comparison_09_functional_computation.pdf) · [CSV](LMX_Comparison_09_functional_computation.csv)

Runtime LMX: NOT_RUN.
