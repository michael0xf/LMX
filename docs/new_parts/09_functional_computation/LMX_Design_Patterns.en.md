# LMX: Functional computation

Haskell is a natural control for Maybe/Monad and currying. Scala combines functional constructs with JVM execution, explicit trampolines and ordinary resource handling. The selection follows mechanisms rather than a universal brevity ranking.

All four original patterns 82–85 remain as clients of ready components. Each is paired with complete custom implementations of the same library in all three languages: Maybe/bind, Bounce/runner, synchronous around and first-int capture. Client and implementation sizes are counted separately and may be summed for a standalone example. bind uses prepared-value operand notation; the other helpers keep ordinary calls where OPERANDS_TEMPLATE would add only a wrapper.

## Files

- [Markdown](LMX_Comparison_09_functional_computation.md)
- [Excel](LMX_Comparison_09_functional_computation.xlsx)
- [PDF](LMX_Comparison_09_functional_computation.pdf)
- [CSV](LMX_Comparison_09_functional_computation.csv)
- [Methodology](../COMPARISON_METHODOLOGY.en.md)
- [All 90 patterns](../PATTERN_CATALOG_90.en.md)
- [Validation status](../VALIDATION.md)
- [Message and existing HTTP transport profile](../MESSAGE_HTTP_PROFILE.md)
- [Operands and libraries: edition rules](../OPERAND_USAGE_PROFILE.md)
- [Review of all 90 examples](../OPERAND_LIBRARY_REVIEW.md)

## Catalog

### 082. [Monad](082_monad_comparision.md)

Using a ready Maybe<int> library and its bind: absence skips the continuation.

**Implementation of the supplied component:** [091. Maybe container and bind implementation](091_maybe_container_and_bind_implementation_comparision.md)

**Scenario:** The client defines half: an even number yields a present half and an odd number yields none. Two binds apply half to 8, 6 and 3. Constructors, the container and bind are supplied by the adjacent implementation comparison.

**Observation:** 8 yields present 2; 6 yields absence after the second half; 3 yields absence after the first half and skips the second. A prepared reference to half is not itself a call.

All three clients use ready libraries whose custom implementations are shown alongside. Library code is excluded from every client count; calls and imports are included. Haskell imports MaybeInt and Scala imports MaybeInt rather than relying on Prelude Maybe or Option.

### 091. [Maybe container and bind implementation](091_maybe_container_and_bind_implementation_comparision.md)

A custom Maybe<int> library: present/absent constructors and binary bind in all three languages.

**Usage examples:** [082. Monad](082_monad_comparision.md)

**Scenario:** Implement unit(int), none and bind(Maybe<int>, int→Maybe<int>). For absence, bind returns absence without reading a payload or calling the continuation; for presence it calls the continuation once with the number. The Monad client uses these exact implementations.

**Observation:** unit(0) remains a present zero and differs from none. bind(none, next) does not call next; bind(unit(8), half) yields present 4. Pure total continuations satisfy left identity, right identity and associativity by observable value.

All three listings show the custom type, constructors and complete bind logic. Haskell does not use Prelude Maybe/Monad; Scala does not use Option/flatMap. The complete shown library is counted; primitive types, ordinary calls and the kernel structural header remain language infrastructure.

### 083. [Trampoline](083_trampoline_comparision.md)

Application even/odd steps using a ready Bounce and runner.

**Implementation of the supplied component:** [092. Trampoline container and runner implementation](092_trampoline_container_and_runner_implementation_comparision.md)

**Scenario:** Determine parity for nonnegative n using mutual even/odd steps. Every unfinished step returns More with the other step and n−1; it does not invoke that step. Run 0, 1 and 100001 through the library runner fully shown alongside.

**Observation:** 0 yields true, 1 false and 100001 false; LMX returns 1, 0, 0. Every step returns control to the driver; no nested even/odd call chain accumulates.

The same explicitly defined container and runner are excluded from every client count. The adjacent block implements and counts them in each language. Haskell and Scala also import custom BounceBool rather than ready TailCalls.

### 092. [Trampoline container and runner implementation](092_trampoline_container_and_runner_implementation_comparision.md)

A custom Bounce for a Boolean result or a deferred call with one integer argument, with complete runners in all three languages.

**Usage examples:** [083. Trampoline](083_trampoline_comparision.md)

**Scenario:** Implement Done(answer) and More(next, argument). done creates completion; more stores a step reference and its integer argument without invoking it. run repeatedly invokes one stored step and receives the next Bounce until Done. The complete container and driver are shown; even/odd belong to the client.

**Observation:** run(done(true)) returns true immediately. Each More invokes the stored next exactly once with its stored argument. The client for 0, 1, 100001 yields true, false, false (LMX: 1, 0, 0); nested step-call depth does not grow with n.

All languages use the same deferred-call model: an Int→Bounce function plus an already stored int. No ready Trampoline/TailCalls, monadic bind, CPS transformer or scheduler is hidden behind the interface. Haskell uses a tail driver, Scala a checked @tailrec function and LMX a while loop.

### 084. [Execute Around](084_execute_around_comparision.md)

A client supplies the resource, action and log to ready around; normal exit and two failures test release.

**Implementation of the supplied component:** [098. Execute Around implementation](098_execute_around_implementation_comparision.md)

**Scenario:** The resource contains 42. acquire appends 1 to a log, action 2 and release 3. Mode 0 succeeds, mode 1 fails in action and mode 2 in acquisition. The client uses the same ready Around abstraction in all three languages and catches the failure only to observe the log.

**Observation:** run(0) yields 42123: result 42 and log 123. run(1) yields −123: body failure reaches the client after release. run(2) yields −1: acquisition failed and no release ran. The resource is not used after cleanup.

All three clients use a custom ready around whose implementation appears alongside. Library code is excluded symmetrically; imports, application callbacks and observation of all three outcomes are counted. Haskell no longer gets standard bracket free while a complete LMX implementation is charged to its client.

### 098. [Execute Around implementation](098_execute_around_implementation_comparision.md)

The complete reusable acquire/action/release mechanism for synchronous failures, without ready bracket/Using.

**Usage examples:** [084. Execute Around](084_execute_around_comparision.md)

**Scenario:** Accept acquire()→resource, release(resource)→procedure and action(resource)→int. After successful acquisition, release exactly once on normal exit or a ResourceFailure from the body. Failed acquisition must not release. The resource, log and application failure rules remain in Execute Around.

**Observation:** Success: log 123 and the action result. Body failure: log 123 and propagation. Acquisition failure: log 1 and no release. The adjacent client encodes these cases as 42123, −123 and −1.

Every language shows its own around. Haskell uses ordinary catch/throwIO, Scala try/finally and LMX finally. No ready bracket, Using or hidden resource helper is called. Application callbacks remain in the client.

### 085. [Currying](085_currying_comparision.md)

A client of ready capture partially applies its own addition and uses the resulting functions after factory return.

**Implementation of the supplied component:** [099. Integer partial-application implementation](099_integer_partial_application_implementation_comparision.md)

**Scenario:** Declare the application binary addition. Use the same ready capture abstraction to create add5 and add100, then obtain add5(1), add100(1), add5(1). A same-named LMX caller local saved=1000 does not change retained values.

**Observation:** 6, 101, 6; demo returns 6101006. The returned function has exactly one explicit int input. The LMX library prototype is unchanged and the two created functions are independent.

All three clients use ready capture with complete custom implementations alongside. Application addition remains in every listing. Haskell/Scala are not forced to recreate the LMX graph; their helpers use natural lambdas and that difference stays visible in the implementation comparison.

### 099. [Integer partial-application implementation](099_integer_partial_application_implementation_comparision.md)

Reusable capture(binary, first): retain a function and first int, returning a callable of one int.

**Usage examples:** [085. Currying](085_currying_comparision.md)

**Scenario:** Given binary:(int,int)→int and first:int, build an independent retained computation second→binary(first,second). Finish the factory, build another function and call the first again. Addition is not built into the helper; the Currying client defines it.

**Observation:** capture(add,5)(1)=6, capture(add,100)(1)=101 and calling the first again yields 6. A different binary function likewise receives the retained first and explicit second argument. Caller saved=1000 does not replace the capture; the LMX prototype is unchanged.

LMX shows the complete graph-based capture implementation; Haskell and Scala show custom lambda wrappers. Ready Scala .curried is not used. The mechanism cost difference remains visible here, while the client does not pay it at every use.

## Boundaries

Sizes are computed from each comparison’s three listings. Paired cases count ready-component use separately from the component implementation, with the same boundary in all three languages. Runtime, HTTP hosts and databases are not hidden behind a new import. IDs 1–85 retain the supplied list, 86–90 are added patterns, and IDs above 90 identify separate library-component implementations.
