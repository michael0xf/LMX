# Iteration until Stop: usage and implementation are separate

Edition: 2026-11-23. Client: [H09](../lmx/H09.lm3), [scenario](../../LMX_examples_and_analogies.ru.md#h09).

## Contract

The accepted declaration remains DATA until execution. Its established item and caller total stay live in the receiving activation. Only source Stop terminates; body Stop and other failures propagate in FxCallFailure. The Haskell loop passes values explicitly. AE01 is a concrete pending kernel integration boundary; see CORE_EXAMPLE_HELPERS.md.

LMX public names: `iterateUntilStop`. These names belong to the proposed core; no user library import is needed.

**Foreign usage client:** Control.Monad.Loops.whileJust_ from the actual monad-loops package. The implementation below is for comparison only. It is not on the client's module search path, and [Analogies.hs](../haskell/Analogies.hs) does not import it.

## LMX implementation

Complete entry definitions, with no omitted branch:

```lmx
FxIterateUntilStop:
    @: iteration
    @: body
    iterateUntilStop:
        throws: copy(FxThrows\call)
        while: 1
            private: @: step FxKernel\attemptAccepted(iteration)
            if: step\ok = 0
                if: FxSameText\same(step\failure; "Stop")
                    break
                throw: FxCallFailure(step)
            private: @: result FxKernel\attemptAccepted(body)
            if: result\ok = 0
                throw: FxCallFailure(result)
```

Complete canonical source files for the entry and its LMX dependencies:

- [coreComparisonExamples.lmx](../../LMX_Fn_Receivers/src/coreComparisonExamples.lmx)
- [failures.lmx](../../LMX_Fn_Receivers/src/failures.lmx)
- [generic_runtime.lmx](../../LMX_Fn_Receivers/src/generic_runtime.lmx)

The reachable roots are: `FxSameText`, `FxThrows`, `FxIterateUntilStop`.
These shared definitions are kept once in the canonical source package rather than copied into every comparison. Their full bodies remain available by the links above and in [LMX_Receivers.lmx](../../LMX_Fn_Receivers/LMX_Receivers.lmx).

The kernel-provider boundary is explicit in [KERNEL_REQUIREMENTS.md](../../LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md). The declaration/body bridge and ownership contract are detailed in [CORE_EXAMPLE_HELPERS.md](../../LMX_Fn_Receivers/CORE_EXAMPLE_HELPERS.md). A linked integration requirement is not a claim that its native implementation has already run.

## Haskell comparison implementation

[Exact standalone module](../libraries/haskell/StepIterator.hs):

```haskell
-- Comparison implementation only; usage clients import monad-loops whileJust_.
module StepIterator (Step(..), iterateUntilStop, whileJust) where

data Step a = Yield a | Stop

-- This loop is polymorphic in both the yielded value and the effect carrier.
-- Stop ends only the source; exceptions from source/body propagate unchanged.
iterateUntilStop :: Monad m => m (Step a) -> (a -> m b) -> m ()
iterateUntilStop next body = go
  where
    go = do
      step <- next
      case step of
        Stop -> pure ()
        Yield value -> body value >> go

-- Same loop with the real library's Maybe protocol, shown for direct comparison.
whileJust :: Monad m => m (Maybe a) -> (a -> m b) -> m ()
whileJust next body = iterateUntilStop (convert <$> next) body
  where
    convert Nothing = Stop
    convert (Just value) = Yield value
```

## Size boundaries

| Source boundary | Nonwhitespace characters | Nonblank lines | UTF-8 bytes |
| --- | ---: | ---: | ---: |
| LMX entry definitions shown above | 303 | 14 | 481 |
| All reachable LMX source roots, counted once | 2008 | 160 | 3438 |
| Complete Haskell comparison module | 644 | 19 | 830 |

These are implementation sizes, separate from client sizes. They do not compare runtime internals or claim the same type-system representation. A language's built-in function machinery need not be reproduced as a second interpreter just to match LMX's graph representation.

## Ownership and async scope

The reusable helpers here are synchronous computations on their owner. To run an LMX owner operation asynchronously, use existing Message `post`; it already provides delivery and reply handling, including the documented HTTP transport. No cross-Message mutable cache, hidden global scheduler, cancellation guarantee or extra worker pool is claimed. In the Haskell comparison Lazy explicitly checks its owning thread and masks the bookkeeping around an interruptible action.

**Verification:** reproducible source/metric checks only; neither LMX runtime nor GHC execution is claimed. The client dependency list is [lmx-examples.cabal](../haskell/lmx-examples.cabal).
