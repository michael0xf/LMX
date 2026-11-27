# Lazy and evaluation modes: usage and implementation are separate

Edition: 2026-11-27. Client: [H07](../haskell_comparision/source/lmx/H07.lm3), [scenario](../../LMX_examples_and_analogies.ru.md#h07).

## Contract

lazy accepts a zero-input thunk; partial may bind all arguments first. once retains its general input contract. The first successful result is cached; failure permits retry, recursive forcing fails. LMX state belongs to one Message, Haskell Lazy.hs enforces one owning ThreadId. This does not replace the separate raw-occurrence test.

LMX public names: `lazy`, `once`. These names belong to the proposed core; no user library import is needed.

**Foreign usage client:** Native let / do and Control.Monad.replicateM. The implementation below is for comparison only. It is not on the client's module search path, and [Analogies.hs](../haskell_comparision/Analogies.hs) does not import it.

## LMX implementation

Complete entry definitions, with no omitted branch:

```lmx
FxLazyState:
    @: operation 0
    int: status 0
    @: value 0

FxLazyEngine:
    private:
        @: state
        @: frame
    return: @
    run:
        throws: FxCallFailure FxKernelFailure FxLazyCycle FxTypeToken
        if: state\status = 2
            return: state\value
        if: state\status = 1
            throw: FxLazyCycle()
        private: int: completed 0
        finally:
            if: completed = 0
                state\status := 0
        ---
        state\status := 1
        private: @: result FxFrameApply\apply(frame)
        state\value := result
        state\status := 2
        completed := 1
        return: result

FxOnce:
    private: @: operation
    return: @
    once:
        throws: copy(FxThrows\adapter)
        private: @: info FxKernel\signature(subject := operation)
        private: @: contract FxSignatures\make(info\inputTypes; info\resultType)
        private: @: state (copy(FxLazyState))
        state\operation := operation
        private: @: failures FxFailures\union(info\throws; ("FxLazyCycle"))
        return: FxWrap\make(contract; FxLazyEngine\run; state; failures; FxFullPolicy\make(operation))

FxLazy:
    private: @: operation
    return: @
    lazy:
        throws: copy(FxThrows\adapter)
        private: @: info FxKernel\signature(subject := operation)
        if: length(info\inputTypes) != 0
            throw: FxArity()
        return: FxOnce\once(operation := operation)
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
- [generic_wrappers.lmx](../../LMX_Fn_Receivers/src/generic_wrappers.lmx)
- [sequences.lmx](../../LMX_Fn_Receivers/src/sequences.lmx)
- [sequences_core.lmx](../../LMX_Fn_Receivers/src/sequences_core.lmx)

The reachable roots are: `FxLazyState`, `FxThrows`, `FxFrameAttempt`, `FxFrameApply`, `FxLazyEngine`, `FxSeqInfo`, `FxSeqAllocate`, `FxSeqRead`, `FxSeqSize`, `FxSeqConcat`, `FxAppend`, `FxFailures`, `FxIndices`, `FxInputPolicy`, `FxSeqBounds`, `FxSeqSlice`, `FxSlice`, `FxSourcePolicy`, `FxFullPolicy`, `FxConcat`, `FxSeqReverse`, `FxFormat`, `FxDecimal`, `FxLabels`, `FxSignatures`, `FxOwnPolicy`, `FxBuild`, `FxEngineState`, `FxTry`, `FxApply`, `FxEqualityTypes`, `FxBooleanToken`, `FxPreparedOperands`, `FxRecordOperands`, `FxPredicateEngine`, `FxPredicateState`, `FxPredicate`, `FxSeqPredicate`, `FxTwo`, `FxValueSame`, `FxSequenceDifference`, `FxEqualFields`, `FxFailureFilter`, `FxStageFailures`, `FxWrap`, `FxOnce`, `FxLazy`.
These shared definitions are kept once in the canonical source package rather than copied into every comparison. Their full bodies remain available by the links above and in [LMX_Receivers.lmx](../../LMX_Fn_Receivers/LMX_Receivers.lmx).

The kernel-provider boundary is explicit in [KERNEL_REQUIREMENTS.md](../../LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md). The declaration/body bridge and ownership contract are detailed in [CORE_EXAMPLE_HELPERS.md](../../LMX_Fn_Receivers/CORE_EXAMPLE_HELPERS.md). A linked integration requirement is not a claim that its native implementation has already run.

## Haskell comparison implementation

[Exact standalone module](../libraries/haskell/Lazy.hs):

```haskell
-- Comparison implementation only: one owning thread, like one LMX Message.
module Lazy (lazyIO, onceIO, LazyFailure(..)) where

import Control.Concurrent (myThreadId)
import Control.Exception (Exception, evaluate, mask, onException, throwIO)
import Data.IORef (newIORef, readIORef, writeIORef)

data LazyFailure = LazyCycle | LazyForeignOwner deriving (Eq, Show)
instance Exception LazyFailure

data LazyState a = Cold | Busy | Ready a

-- Cache the first successful result, independently of later input values.
-- input can be any product/record/argument-vector type; output is unrestricted.
-- A failed call leaves the cache Cold, so a later call may use different input.
-- The action and result are evaluated only on a cache miss, to ordinary WHNF.
onceIO :: (input -> IO a) -> IO (input -> IO a)
onceIO action = do
  owner <- myThreadId
  cell <- newIORef Cold
  pure $ \input -> mask $ \restore -> do
    caller <- myThreadId
    if caller /= owner then throwIO LazyForeignOwner else pure ()
    state <- readIORef cell
    case state of
      Ready value -> pure value
      Busy -> throwIO LazyCycle
      Cold -> do
        writeIORef cell Busy
        value <- restore (action input >>= evaluate) `onException` writeIORef cell Cold
        writeIORef cell (Ready value)
        pure value

-- Allocation does not run the action. Ordinary async exceptions are masked
-- during the state bookkeeping and restored during the action; a failure resets
-- Cold and escapes unchanged. Foreign owners must send a request to this owner.
lazyIO :: IO a -> IO (IO a)
lazyIO action = do
  cached <- onceIO (const action)
  pure (cached ())
```

## Separate prepared/raw test fixture

These test operands deliberately use numeric addition; they test evaluation count, not a second lazy library.

```lmx
PreparedOps:
    copy: sys\OPERANDS_TEMPLATE
    return: int
    twice:
        return: \left + \left

RawOps:
    merge: sys\OPERANDS_TEMPLATE (const: int: PASS_ARGS_AS_IS 1)
    return: int
    twice:
        return: sys\eval(left) + sys\eval(left)
```

```haskell
-- Comparison fixtures for evaluation count; clients use native do / replicateM.
module EvaluationModes (preparedTwice, rawTwice) where

preparedTwice :: Num a => a -> a
preparedTwice value = value + value

rawTwice :: (Monad m, Num a) => m a -> m a
rawTwice action = do
  first <- action
  second <- action
  pure (first + second)
```

## Completeness review: lazy and once

The compared reusable API is first-success caching within one owner. LMX `lazy`
restricts the target to zero inputs; `once` retains the target's complete input
contract. Haskell `lazyIO` uses the zero-input IO action, and `onceIO` accepts any
input product/record/vector type. Later successful-cache calls may pass different
inputs but return the first successful result; this is not per-key memoization.

| Event | LMX source behavior | Haskell source behavior |
| --- | --- | --- |
| Construct wrapper | Fresh state 0; target not executed | Fresh Cold cell; action not executed |
| First force/call | Set state 1; enter the already prepared target frame once | Set Busy; run the supplied action once |
| Successful result | Store the actual value record; publish state 2 | Store Ready value after evaluating its outer form |
| Cache hit | Return the stored record; do not enter the target | Return the stored value; do not run the action |
| Reentrant force | State 1 throws FxLazyCycle before installing an inner reset guard | Busy throws LazyCycle before installing an inner reset handler |
| Target failure | finally resets to state 0 while completed is 0; the failure continues outward | onException resets Cold and rethrows the same exception |
| Retry after failure | A later call can execute again, with its own ordinary actuals | A later call can execute again, with its own input |
| Foreign owner | Message ownership prevents sharing the mutable state across arenas; use post to its owner | Explicit ThreadId check throws LazyForeignOwner; the cell is unchanged |

The cleanup guard is registered before setting Busy. Cache-hit and reentrant-busy checks occur before this guard; therefore an inner recursive attempt cannot reset the outer running computation.

LMX's finite engine exits are `FxCallFailure FxKernelFailure FxLazyCycle FxTypeToken`.
`FxOnce` combines the target's finite exits with FxLazyCycle; `FxWrap` removes the
internal call envelope and uses the declared original name/payload on the public
callable path. The reset is a finally action, not a wildcard catch that consumes
unknown errors. Implicit failures retain normal Message behavior.

The ordinary call preparation policy still applies on cache hits; caching skips
the target body, not all caller expression evaluation or receiving admission.
Haskell similarly retains its ordinary argument/effect sequencing. Neither
implementation promises exactly-once external effects when an earlier attempt
performed effects and then failed.

The interruption mechanisms are different. Haskell masks cache bookkeeping and
restores the caller's masking state around the action. LMX uses one Message owner
lane and registered cleanup on ordinary unwinding; it has no newly invented
Haskell-style asynchronous exception injection or mask operator. Existing `post`
provides asynchronous invocation, not a shared-memory cache or forced cancellation.
Abrupt process termination is outside both successful-cleanup contracts.

Haskell evaluate forces only the outer result form (WHNF), not all referenced data;
LMX retains the returned typed record, including void and references, without
recursively forcing graph contents. [GHC's specified evaluate/mask/onException
contracts](https://downloads.haskell.org/ghc/9.6.7.20250131/docs/libraries/base-4.18.3.0/Control-Exception.html)
explain the foreign exception boundary.

[Prepared completeness cases](../validation/lazy_completeness_20261123.json)
include retry, recursive forcing, void, mixed input, owner rejection and the
separate interruption models. All runtime statuses remain NOT_RUN.

## Size boundaries

| Source boundary | Nonwhitespace characters | Nonblank lines | UTF-8 bytes |
| --- | ---: | ---: | ---: |
| LMX entry definitions shown above | 999 | 46 | 1444 |
| All reachable LMX source roots, counted once | 14601 | 771 | 22349 |
| Complete Haskell comparison module | 1309 | 35 | 1639 |

Every declaration, complete Throws list and copy reference is included in the full source size. Shared definitions are counted once in the declared complete dependency boundary.

На мой взгляд, явные Throws — преимущество LMX: предельно ясно, какие ошибки может породить метод. Общий список и `throws: copy(Throws)` сохраняют этот контракт. Сокращать такие записи ради размера не хочется.

These are implementation sizes, separate from client sizes. They do not compare runtime internals or claim the same type-system representation. A language's built-in function machinery need not be reproduced as a second interpreter just to match LMX's graph representation.

## Ownership and async scope

The reusable helpers here are synchronous computations on their owner. To run an LMX owner operation asynchronously, use existing Message `post`; it already provides delivery and reply handling, including the documented HTTP transport. No cross-Message mutable cache, hidden global scheduler, cancellation guarantee or extra worker pool is claimed. In the Haskell comparison Lazy explicitly checks its owning thread and masks the bookkeeping around an interruptible action.

**Verification:** reproducible source/metric checks only; neither LMX runtime nor GHC execution is claimed. The client dependency list is [lmx-examples.cabal](../haskell_comparision/lmx-examples.cabal).
