# Partial application: usage and implementation are separate

Edition: 2026-11-23. Client: [H03](../lmx/H03.lm3), [scenario](../../LMX_examples_and_analogies.ru.md#h03).

## Contract

LMX captures any finite prefix, preserving value/reference rules, remaining input policies and the original result. The Haskell comparison uses a heterogeneous typed argument representation; no Int or binary arity cap is intended.

LMX public names: `partial`. These names belong to the proposed core; no user library import is needed.

**Foreign usage client:** Native Haskell application: makeAdder n = (+) n. The implementation below is for comparison only. It is not on the client's module search path, and [Analogies.hs](../haskell/Analogies.hs) does not import it.

## LMX implementation

Complete entry definitions, with no omitted branch:

```lmx
FxPartial:
    private:
        @: operation
        @: prefix
    return: @
    partial:
        throws: copy(FxThrows\capture)
        private: @: info FxKernel\signature(subject := operation)
        private: int: n length(info\inputTypes)
        private: int: k length(prefix)
        if: k > n
            throw: FxArity()
        private: @: captured FxCapturePrefix\capture(info\inputTypes; prefix)
        private: @: remaining FxSlice\slice(info\inputTypes; k; n - k)
        private: @: contract FxSignatures\make(remaining; info\resultType)
        private: @: policy FxPrefixPolicy\make(operation; captured)
        return: FxWrap\make(contract; FxForwardEngine\run; (copy(())); info\throws; policy)
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

The reachable roots are: `FxIndices`, `FxInputPolicy`, `FxOwnPolicy`, `FxBuild`, `FxCaptureFailures`, `FxThrows`, `FxSeqInfo`, `FxSeqAllocate`, `FxSeqRead`, `FxSeqSize`, `FxSeqConcat`, `FxAppend`, `FxFailures`, `FxConcat`, `FxSeqReverse`, `FxFormat`, `FxDecimal`, `FxLabels`, `FxOne`, `FxRecordConstructor`, `FxRecordAdapterState`, `FxPreparedOperands`, `FxRecordOperands`, `FxTypeTokens`, `FxRecordAdapter`, `FxCaptureOne`, `FxCapturePrefix`, `FxFrameAttempt`, `FxFrameApply`, `FxForwardEngine`, `FxSeqBounds`, `FxSeqSlice`, `FxSlice`, `FxSourcePolicy`, `FxPrefixPolicy`, `FxSignatures`, `FxEngineState`, `FxTry`, `FxApply`, `FxEqualityTypes`, `FxBooleanToken`, `FxFullPolicy`, `FxPredicateEngine`, `FxPredicateState`, `FxPredicate`, `FxSeqPredicate`, `FxTwo`, `FxValueSame`, `FxSequenceDifference`, `FxEqualFields`, `FxFailureFilter`, `FxStageFailures`, `FxWrap`, `FxPartial`.
These shared definitions are kept once in the canonical source package rather than copied into every comparison. Their full bodies remain available by the links above and in [LMX_Receivers.lmx](../../LMX_Fn_Receivers/LMX_Receivers.lmx).

The kernel-provider boundary is explicit in [KERNEL_REQUIREMENTS.md](../../LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md). The declaration/body bridge and ownership contract are detailed in [CORE_EXAMPLE_HELPERS.md](../../LMX_Fn_Receivers/CORE_EXAMPLE_HELPERS.md). A linked integration requirement is not a claim that its native implementation has already run.

## Haskell comparison implementation

[Exact standalone module](../libraries/haskell/Partial.hs):

```haskell
{-# LANGUAGE DataKinds, GADTs, KindSignatures, TypeFamilies, TypeOperators #-}
module Partial (Args(..), Callable(..), Append, appendArgs, partial) where
import Data.Kind (Type)

data Args (types :: [Type]) where
  Nil :: Args '[]
  (:&) :: value -> Args rest -> Args (value ': rest)
infixr 5 :&

type family Append prefix rest where
  Append '[] rest = rest
  Append (value ': prefix) rest = value ': Append prefix rest

appendArgs :: Args prefix -> Args rest -> Args (Append prefix rest)
appendArgs Nil rest = rest
appendArgs (value :& prefix) rest = value :& appendArgs prefix rest

newtype Callable inputs result = Callable { invoke :: Args inputs -> result }

partial :: Callable (Append prefix rest) result -> Args prefix -> Callable rest result
partial (Callable operation) prefix =
  Callable (\rest -> operation (appendArgs prefix rest))
```

## Native curried implementation approach

The earlier capture helper uses the host curried function representation. Its result may itself be a function, so the type variables do not impose a numerical or final-result specialization. It is a different representation from the explicit heterogeneous vector above. Clients use native application directly.

```haskell
module CurryInt (capture) where

capture :: (a -> b -> c) -> a -> b -> c
capture binary first = \second -> binary first second
```

## Size boundaries

| Source boundary | Nonwhitespace characters | Nonblank lines | UTF-8 bytes |
| --- | ---: | ---: | ---: |
| LMX entry definitions shown above | 533 | 17 | 713 |
| All reachable LMX source roots, counted once | 16390 | 843 | 24834 |
| Complete Haskell comparison module | 699 | 17 | 847 |

Every declaration, complete Throws list and copy reference is included in the full source size. Shared definitions are counted once in the declared complete dependency boundary.

На мой взгляд, явные Throws — преимущество LMX: предельно ясно, какие ошибки может породить метод. Общий список и `throws: copy(Throws)` сохраняют этот контракт. Сокращать такие записи ради размера не хочется.

These are implementation sizes, separate from client sizes. They do not compare runtime internals or claim the same type-system representation. A language's built-in function machinery need not be reproduced as a second interpreter just to match LMX's graph representation.

## Ownership and async scope

The reusable helpers here are synchronous computations on their owner. To run an LMX owner operation asynchronously, use existing Message `post`; it already provides delivery and reply handling, including the documented HTTP transport. No cross-Message mutable cache, hidden global scheduler, cancellation guarantee or extra worker pool is claimed. In the Haskell comparison Lazy explicitly checks its owning thread and masks the bookkeeping around an interruptible action.

**Verification:** reproducible source/metric checks only; neither LMX runtime nor GHC execution is claimed. The client dependency list is [lmx-examples.cabal](../haskell/lmx-examples.cabal).
