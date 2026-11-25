# Apply: usage and implementation are separate

Edition: 2026-11-23. Client: [H01](../haskell_comparision/source/lmx/H01.lm3), [scenario](../../LMX_examples_and_analogies.ru.md#h01).

## Contract

The full typed actual vector uses real record types; failures keep their names and payload inside FxCallFailure. Haskell uses native curried function application; its generic a/b implementation is not a reflection API.

LMX public names: `apply`. These names belong to the proposed core; no user library import is needed.

**Foreign usage client:** Ordinary Haskell application, with no custom apply import. The implementation below is for comparison only. It is not on the client's module search path, and [Analogies.hs](../haskell_comparision/Analogies.hs) does not import it.

## LMX implementation

Complete entry definitions, with no omitted branch:

```lmx
FxApply:
    private:
        @: operation
        @: args
    return: @
    apply:
        throws: copy(FxThrows\call)
        private: @: outcome FxTry\attempt(operation := operation; args := args)
        if: outcome\ok = 0
            throw: FxCallFailure(outcome)
        return: outcome\value
```

Complete canonical source files for the entry and its LMX dependencies:

- [failures.lmx](../../LMX_Fn_Receivers/src/failures.lmx)
- [generic_runtime.lmx](../../LMX_Fn_Receivers/src/generic_runtime.lmx)

The reachable roots are: `FxThrows`, `FxTry`, `FxApply`.
These shared definitions are kept once in the canonical source package rather than copied into every comparison. Their full bodies remain available by the links above and in [LMX_Receivers.lmx](../../LMX_Fn_Receivers/LMX_Receivers.lmx).

The kernel-provider boundary is explicit in [KERNEL_REQUIREMENTS.md](../../LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md). The declaration/body bridge and ownership contract are detailed in [CORE_EXAMPLE_HELPERS.md](../../LMX_Fn_Receivers/CORE_EXAMPLE_HELPERS.md). A linked integration requirement is not a claim that its native implementation has already run.

## Haskell comparison implementation

[Exact standalone module](../libraries/haskell/IntApply.hs):

```haskell
module IntApply (apply) where

apply :: (a -> b) -> a -> b
apply operation value = operation value
```

## Size boundaries

| Source boundary | Nonwhitespace characters | Nonblank lines | UTF-8 bytes |
| --- | ---: | ---: | ---: |
| LMX entry definitions shown above | 199 | 11 | 299 |
| All reachable LMX source roots, counted once | 2083 | 167 | 3493 |
| Complete Haskell comparison module | 79 | 3 | 99 |

Every declaration, complete Throws list and copy reference is included in the full source size. Shared definitions are counted once in the declared complete dependency boundary.

На мой взгляд, явные Throws — преимущество LMX: предельно ясно, какие ошибки может породить метод. Общий список и `throws: copy(Throws)` сохраняют этот контракт. Сокращать такие записи ради размера не хочется.

These are implementation sizes, separate from client sizes. They do not compare runtime internals or claim the same type-system representation. A language's built-in function machinery need not be reproduced as a second interpreter just to match LMX's graph representation.

## Ownership and async scope

The reusable helpers here are synchronous computations on their owner. To run an LMX owner operation asynchronously, use existing Message `post`; it already provides delivery and reply handling, including the documented HTTP transport. No cross-Message mutable cache, hidden global scheduler, cancellation guarantee or extra worker pool is claimed. In the Haskell comparison Lazy explicitly checks its owning thread and masks the bookkeeping around an interruptible action.

**Verification:** reproducible source/metric checks only; neither LMX runtime nor GHC execution is claimed. The client dependency list is [lmx-examples.cabal](../haskell_comparision/lmx-examples.cabal).
