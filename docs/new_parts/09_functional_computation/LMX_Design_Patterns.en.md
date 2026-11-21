# LMX: Functional computation

Haskell is a natural control for Maybe/Monad and currying. Scala combines functional constructs with JVM execution, explicit trampolines and ordinary resource handling. The selection follows mechanisms rather than a universal brevity ranking.

All four original entries 82–85 remain separate. The cases compare absence propagation, next-step execution, resource release and retained partial application. LMX uses ordinary structures and methods; controls may use their standard functional libraries.

## Files

- [Markdown](LMX_Comparison_09_functional_computation.md)
- [Excel](LMX_Comparison_09_functional_computation.xlsx)
- [PDF](LMX_Comparison_09_functional_computation.pdf)
- [CSV](LMX_Comparison_09_functional_computation.csv)
- [Methodology](../COMPARISON_METHODOLOGY.en.md)
- [All 90 patterns](../PATTERN_CATALOG_90.en.md)
- [Validation status](../VALIDATION.md)
- [Message and existing HTTP transport profile](../MESSAGE_HTTP_PROFILE.md)

## Catalog

### 082. [Monad](082_monad_comparision.md)

Context-preserving composition, illustrated by Maybe: absence skips subsequent steps.

**Scenario:** Halve an integer twice, accepting only even inputs at each step. Run 8 and 6; the latter fails at the second step. A continuation following absence must not run.

**Observation:** 8 produces present=1, value=2 (Just 2 / Some(2)); 6 produces absence (Nothing / None). Bind does not read an absent payload. Unit/bind laws are observational, not container-address equality.

Haskell uses standard Maybe and >>=; Scala uses Option.flatMap. Their brevity includes an existing library abstraction. LMX spells out the int instance. This does not introduce a universal polymorphic Monad interface or prove laws for arbitrary effects.

### 083. [Trampoline](083_trampoline_comparision.md)

An executor repeatedly obtains the next computation step instead of nesting calls.

**Scenario:** Mutual even/odd steps test a nonnegative n. Check 0, 1 and 100001. Each step returns to the driver; the LMX version never calls the other step recursively.

**Observation:** 0 yields true/1; 1 and 100001 yield false/0. The base-case check makes n+1 steps. The LMX driver retains one next step instead of n activation records.

Scala uses the existing TailCalls library; Haskell explicitly defines Bounce and its tail driver. LMX uses ordinary method references and state in the live driver. This is a specialized synchronous algorithm, not a universal CPS library or async scheduler.

### 084. [Execute Around](084_execute_around_comparision.md)

Resource acquisition and release surround a supplied user action.

**Scenario:** Supply acquire, action and release. Action returns 42 or fails; release records cleanup. Check success, body failure and acquisition failure.

**Observation:** Success: acquire, action, release, result 42. Action failure still runs release and propagates the error. Acquisition failure does not call release because no resource was acquired.

LMX uses finally, Haskell bracket and Scala try/finally. Haskell bracket additionally handles asynchronous-exception concerns; the shared scenario covers normal exit and body failure. The same supplied acquire/release/action boundaries apply to all three.

### 085. [Currying](085_currying_comparision.md)

Transform binary addition into obtaining a function and then supplying its remaining argument.

**Scenario:** Build add5 and add100, finish both factory activations, then call add5(1), add100(1), add5(1). A same-named caller local must not replace the retained value.

**Observation:** The values are 6, 101 and 6; demo returns the encoding 6101006. The prototype retains saved=0. Each returned function has one explicit input x.

Haskell functions are curried; Scala uses Function2.curried. LMX implements the same two-stage observation through a returned method and explicit retained environment. This is longer than built-in currying. Merely changing a default would leave another input and possible override, changing the contract.

## Boundaries

Sizes are computed from each pattern’s three listings. They exclude implementations of supplied libraries, runtime, HTTP hosts and databases. Read each case’s individual limits. IDs retain the original list; 86–90 are explicit additions.
