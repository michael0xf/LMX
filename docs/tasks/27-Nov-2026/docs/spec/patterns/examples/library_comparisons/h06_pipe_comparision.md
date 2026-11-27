# Composition: usage and implementation are separate

Edition: 2026-11-27. Client: [H06](../haskell_comparision/source/lmx/H06.lm3), [scenario](../../LMX_examples_and_analogies.ru.md#h06).

## Contract

Construction does not execute stages. The stored callable preserves the first input policy and receives the exact final result. Pure and effectful Haskell variants are separate contracts; all effectful stages execute in order.

LMX public names: `compose`. These names belong to the proposed core; no user library import is needed.

**Foreign usage client:** Native (.) for composition; Data.List.foldl' / Control.Monad.foldM for stage lists. The implementation below is for comparison only. It is not on the client's module search path, and [Analogies.hs](../haskell_comparision/Analogies.hs) does not import it.

## LMX implementation

Complete entry definitions, with no omitted branch:

```lmx
FxCompose:
    private:
        @: outer
        @: inner
    return: @
    compose:
        throws: copy(FxThrows\adapter)
        private: @: a FxKernel\signature(subject := outer)
        private: @: b FxKernel\signature(subject := inner)
        if: length(a\inputTypes) != 1 || b\hasResult = 0
            throw: FxArity()
        private: @: contract FxSignatures\make(b\inputTypes; a\resultType)
        private: @: state (copy(FxCompositionState))
        state\outer := outer
        state\inner := inner
        private: @: failures FxFailures\union(a\throws; b\throws)
        return: FxWrap\make(contract; FxCompositionEngine\run; state; failures; FxFullPolicy\make(inner))
```

Complete canonical source files for the entry and its LMX dependencies:

- [adapter_frames.lmx](../../LMX_Fn_Receivers/src/adapter_frames.lmx)
- [coreComparisonGroups.lmx](../../LMX_Fn_Receivers/src/coreComparisonGroups.lmx)
- [coreStandardLisp.lmx](../../LMX_Fn_Receivers/src/coreStandardLisp.lmx)
- [coreStandardText.lmx](../../LMX_Fn_Receivers/src/coreStandardText.lmx)
- [failures.lmx](../../LMX_Fn_Receivers/src/failures.lmx)
- [generic_combinators.lmx](../../LMX_Fn_Receivers/src/generic_combinators.lmx)
- [generic_functions.lmx](../../LMX_Fn_Receivers/src/generic_functions.lmx)
- [generic_runtime.lmx](../../LMX_Fn_Receivers/src/generic_runtime.lmx)
- [sequences.lmx](../../LMX_Fn_Receivers/src/sequences.lmx)
- [sequences_core.lmx](../../LMX_Fn_Receivers/src/sequences_core.lmx)

The reachable roots are: `FxThrows`, `FxTry`, `FxApply`, `FxFrameAttempt`, `FxFrameApply`, `FxOne`, `FxCompositionEngine`, `FxCompositionState`, `FxSeqInfo`, `FxSeqAllocate`, `FxSeqRead`, `FxSeqSize`, `FxSeqConcat`, `FxAppend`, `FxFailures`, `FxIndices`, `FxInputPolicy`, `FxSeqBounds`, `FxSeqSlice`, `FxSlice`, `FxSourcePolicy`, `FxFullPolicy`, `FxConcat`, `FxSeqReverse`, `FxFormat`, `FxDecimal`, `FxLabels`, `FxSignatures`, `FxOwnPolicy`, `FxBuild`, `FxEngineState`, `FxEqualityTypes`, `FxBooleanToken`, `FxPreparedOperands`, `FxRecordOperands`, `FxPredicateEngine`, `FxPredicateState`, `FxPredicate`, `FxSeqPredicate`, `FxTwo`, `FxValueSame`, `FxSequenceDifference`, `FxEqualFields`, `FxFailureFilter`, `FxStageFailures`, `FxWrap`, `FxCompose`.
These shared definitions are kept once in the canonical source package rather than copied into every comparison. Their full bodies remain available by the links above and in [LMX_Receivers.lmx](../../LMX_Fn_Receivers/LMX_Receivers.lmx).

The kernel-provider boundary is explicit in [KERNEL_REQUIREMENTS.md](../../LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md). The declaration/body bridge and ownership contract are detailed in [CORE_EXAMPLE_HELPERS.md](../../LMX_Fn_Receivers/CORE_EXAMPLE_HELPERS.md). A linked integration requirement is not a claim that its native implementation has already run.

## Haskell comparison implementation

[Exact standalone module](../libraries/haskell/IntPipe.hs):

```haskell
module IntPipe (pipe, pipeIO, pipe2, pipeIO2) where

pipe :: a -> [a -> a] -> a
pipe value [] = value
pipe value (stage : rest) =
  let next = stage value
  in next `seq` pipe next rest

pipeIO :: a -> [a -> IO a] -> IO a
pipeIO value [] = pure value
pipeIO value (stage : rest) = do
  next <- stage value
  next `seq` pipeIO next rest

pipe2 :: (a -> b) -> (b -> c) -> a -> c
pipe2 first second = second . first

pipeIO2 :: (a -> IO b) -> (b -> IO c) -> a -> IO c
pipeIO2 first second input = first input >>= second
```

## Size boundaries

| Source boundary | Nonwhitespace characters | Nonblank lines | UTF-8 bytes |
| --- | ---: | ---: | ---: |
| LMX entry definitions shown above | 507 | 17 | 686 |
| All reachable LMX source roots, counted once | 14414 | 762 | 22046 |
| Complete Haskell comparison module | 389 | 15 | 517 |

Every declaration, complete Throws list and copy reference is included in the full source size. Shared definitions are counted once in the declared complete dependency boundary.

На мой взгляд, явные Throws — преимущество LMX: предельно ясно, какие ошибки может породить метод. Общий список и `throws: copy(Throws)` сохраняют этот контракт. Сокращать такие записи ради размера не хочется.

These are implementation sizes, separate from client sizes. They do not compare runtime internals or claim the same type-system representation. A language's built-in function machinery need not be reproduced as a second interpreter just to match LMX's graph representation.

## Ownership and async scope

The reusable helpers here are synchronous computations on their owner. To run an LMX owner operation asynchronously, use existing Message `post`; it already provides delivery and reply handling, including the documented HTTP transport. No cross-Message mutable cache, hidden global scheduler, cancellation guarantee or extra worker pool is claimed. In the Haskell comparison Lazy explicitly checks its owning thread and masks the bookkeeping around an interruptible action.

**Verification:** reproducible source/metric checks only; neither LMX runtime nor GHC execution is claimed. The client dependency list is [lmx-examples.cabal](../haskell_comparision/lmx-examples.cabal).
