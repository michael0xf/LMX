# Iteration until Stop: usage and implementation are separate

Edition: 2026-11-23. Client: [H09](../lmx/H09.lm3), [scenario](../../LMX_examples_and_analogies.ru.md#h09).

## Contract

The accepted declaration remains DATA until execution. Its established item and caller total stay live in the receiving activation. The primary H09 loop uses ordinary iteration()/body() and catches only source Stop. A Stop raised by the body and all other failures retain their original names. This is the authored declaration/body contract in LMX_semantics.en.md, with no string comparison or failure envelope. Haskell passes each yielded value explicitly and propagates exceptions normally. The separately retained core adapter deliberately has a different FxCallFailure API; it is not a semantic substitute for this short primary loop.

Primary H09 uses the local `Cycles\iterate` shown in full below. The optional `iterateUntilStop` adapter remains in the proposed core with its separate error-envelope contract.

**Foreign usage client:** Control.Monad.Loops.whileJust_ from the actual monad-loops package. The implementation below is for comparison only. It is not on the client's module search path, and [Analogies.hs](../haskell/Analogies.hs) does not import it.

## Primary ordinary LMX implementation

The complete helper below is also included in [H09.lm3](../lmx/H09.lm3), so its cost is part of the full scenario. It is the original short implementation restored from 22-Nov, directly covered by the [current declaration/body specification](../../../LMX_semantics.en.md#declaration-arguments).

```lmx
Cycles:
    @: iteration
    @: body
    iterate:
        while: 1
            iteration()
            catch: Stop ()
                break
            body()
```

The catch belongs to `iteration()` alone. `body()` is outside that catch: if it raises Stop, Stop propagates. A source failure other than Stop also propagates unchanged. Reusing an ordinary named catch avoids dispatching on the characters of an error-name string. No extra receiver, raw execution mode or adapter kernel is needed for this mechanism.

## Separate core adapter with an error envelope

The following retained adapter converts failures to FxCallFailure records and uses an accepted-code bridge. That is an additional API boundary. Its entry and reachable-source sizes are reported separately and are not used as the primary equivalent-loop size.

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
                if: FxEqualFields\equalFields(step\failure; "Stop")
                    break
                throw: FxCallFailure(step)
            private: @: result FxKernel\attemptAccepted(body)
            if: result\ok = 0
                throw: FxCallFailure(result)
```

Complete canonical source files for the entry and its LMX dependencies:

- [adapter_frames.lmx](../../LMX_Fn_Receivers/src/adapter_frames.lmx)
- [coreComparisonExamples.lmx](../../LMX_Fn_Receivers/src/coreComparisonExamples.lmx)
- [coreComparisonGroups.lmx](../../LMX_Fn_Receivers/src/coreComparisonGroups.lmx)
- [coreStandardLisp.lmx](../../LMX_Fn_Receivers/src/coreStandardLisp.lmx)
- [coreStandardText.lmx](../../LMX_Fn_Receivers/src/coreStandardText.lmx)
- [failures.lmx](../../LMX_Fn_Receivers/src/failures.lmx)
- [generic_combinators.lmx](../../LMX_Fn_Receivers/src/generic_combinators.lmx)
- [generic_functions.lmx](../../LMX_Fn_Receivers/src/generic_functions.lmx)
- [generic_runtime.lmx](../../LMX_Fn_Receivers/src/generic_runtime.lmx)
- [sequences.lmx](../../LMX_Fn_Receivers/src/sequences.lmx)
- [sequences_core.lmx](../../LMX_Fn_Receivers/src/sequences_core.lmx)

The reachable roots are: `FxThrows`, `FxSeqInfo`, `FxSeqRead`, `FxTry`, `FxApply`, `FxEqualityTypes`, `FxBooleanToken`, `FxIndices`, `FxInputPolicy`, `FxSeqAllocate`, `FxSeqBounds`, `FxSeqSlice`, `FxSlice`, `FxSourcePolicy`, `FxFullPolicy`, `FxFrameAttempt`, `FxFrameApply`, `FxPreparedOperands`, `FxRecordOperands`, `FxPredicateEngine`, `FxPredicateState`, `FxSeqSize`, `FxSeqConcat`, `FxConcat`, `FxSeqReverse`, `FxFormat`, `FxDecimal`, `FxLabels`, `FxSignatures`, `FxOwnPolicy`, `FxBuild`, `FxEngineState`, `FxFailureFilter`, `FxAppend`, `FxFailures`, `FxStageFailures`, `FxWrap`, `FxPredicate`, `FxSeqPredicate`, `FxTwo`, `FxValueSame`, `FxSequenceDifference`, `FxEqualFields`, `FxIterateUntilStop`.
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
| Primary complete Cycles helper | 73 | 9 | 159 |
| Optional adapter entry | 313 | 14 | 491 |
| Optional adapter and all reachable LMX roots | 13904 | 739 | 21388 |
| Complete Haskell comparison module | 644 | 19 | 830 |

Every declaration, complete Throws list and copy reference is included in the full source size. Shared definitions are counted once in the declared complete dependency boundary.

На мой взгляд, явные Throws — преимущество LMX: предельно ясно, какие ошибки может породить метод. Общий список и `throws: copy(Throws)` сохраняют этот контракт. Сокращать такие записи ради размера не хочется.

These are implementation sizes, separate from client sizes. They do not compare runtime internals or claim the same type-system representation. A language's built-in function machinery need not be reproduced as a second interpreter just to match LMX's graph representation.

## Ownership and async scope

The reusable helpers here are synchronous computations on their owner. To run an LMX owner operation asynchronously, use existing Message `post`; it already provides delivery and reply handling, including the documented HTTP transport. No cross-Message mutable cache, hidden global scheduler, cancellation guarantee or extra worker pool is claimed. In the Haskell comparison Lazy explicitly checks its owning thread and masks the bookkeeping around an interruptible action.

**Verification:** reproducible source/metric checks only; neither LMX runtime nor GHC execution is claimed. The client dependency list is [lmx-examples.cabal](../haskell/lmx-examples.cabal).
