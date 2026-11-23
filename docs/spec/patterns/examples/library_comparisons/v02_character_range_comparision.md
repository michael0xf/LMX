# Inclusive range: usage and implementation are separate

Edition: 2026-11-23. Client: [V02](../lmx/V02.lm3), [scenario](../../LMX_examples_and_analogies.ru.md#v02).

## Contract

Two inclusive bounds, original ordered types, no int conversion, reversed interval false. The LMX operand checks exactly two right values and uses comparison priority. Haskell fixes two bounds by a pair and requires Ord. Neither helper is a regular-expression matcher.

LMX public names: `between`. These names belong to the proposed core; no user library import is needed.

**Foreign usage client:** Data.Ix.inRange from base. The implementation below is for comparison only. It is not on the client's module search path, and [Analogies.hs](../haskell/Analogies.hs) does not import it.

## LMX implementation

Complete entry definitions, with no omitted branch:

```lmx
FxBetween:
    copy: sys\OPERANDS_TEMPLATE
    const: int: PRIORITY sys\priority("<=")
    return: int
    between:
        throws: RangeArity
        if: length(right) != 2
            throw: RangeArity()
        return: \right[0] <= \left && \left <= \right[1]
```

Complete canonical source files for the entry and its LMX dependencies:

- [coreComparisonExamples.lmx](../../LMX_Fn_Receivers/src/coreComparisonExamples.lmx)

The reachable roots are: `FxBetween`.
These shared definitions are kept once in the canonical source package rather than copied into every comparison. Their full bodies remain available by the links above and in [LMX_Receivers.lmx](../../LMX_Fn_Receivers/LMX_Receivers.lmx).

The kernel-provider boundary is explicit in [KERNEL_REQUIREMENTS.md](../../LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md). The declaration/body bridge and ownership contract are detailed in [CORE_EXAMPLE_HELPERS.md](../../LMX_Fn_Receivers/CORE_EXAMPLE_HELPERS.md). A linked integration requirement is not a claim that its native implementation has already run.

## Haskell comparison implementation

[Exact standalone module](../libraries/haskell/CharacterRange.hs):

```haskell
-- Comparison implementation only. Clients import Data.Ix.inRange.
module CharacterRange (between) where

-- Inclusive endpoints; reversed intervals and unordered floating values are false.
-- A lawful Ord instance supplies the ordering; neither endpoint is converted.
between :: Ord a => a -> (a, a) -> Bool
between value (lower, upper) = lower <= value && value <= upper
```

## Size boundaries

| Source boundary | Nonwhitespace characters | Nonblank lines | UTF-8 bytes |
| --- | ---: | ---: | ---: |
| LMX entry definitions shown above | 185 | 9 | 263 |
| All reachable LMX source roots, counted once | 185 | 9 | 263 |
| Complete Haskell comparison module | 315 | 6 | 373 |

These are implementation sizes, separate from client sizes. They do not compare runtime internals or claim the same type-system representation. A language's built-in function machinery need not be reproduced as a second interpreter just to match LMX's graph representation.

## Ownership and async scope

The reusable helpers here are synchronous computations on their owner. To run an LMX owner operation asynchronously, use existing Message `post`; it already provides delivery and reply handling, including the documented HTTP transport. No cross-Message mutable cache, hidden global scheduler, cancellation guarantee or extra worker pool is claimed. In the Haskell comparison Lazy explicitly checks its owning thread and masks the bookkeeping around an interruptible action.

**Verification:** reproducible source/metric checks only; neither LMX runtime nor GHC execution is claimed. The client dependency list is [lmx-examples.cabal](../haskell/lmx-examples.cabal).
