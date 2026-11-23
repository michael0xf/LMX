# Implementation comparisons, not client libraries

These files are reference implementations for comparison with LMX core sources.
The Haskell usage executable has its own Cabal component and **does not** include
this directory on `hs-source-dirs`. Do not add `-ilibraries/haskell` to usage tests.

| Reference implementation | LMX counterpart / comparison | Foreign client uses |
| --- | --- | --- |
| IntApply.apply | [apply](../library_comparisons/h01_apply_comparision.md) | Native application |
| Partial.partial and CurryInt.capture | [partial / closure](../library_comparisons/h03_capture_comparision.md) | Native curried application |
| IntPipe pure/effectful, pair/list functions | [pipe / compose](../library_comparisons/h06_pipe_comparision.md) | (.), foldl', foldM |
| Lazy.lazyIO / onceIO | [lazy / once](../library_comparisons/h07_evaluation_modes_comparision.md) | Native shared prepared value in the usage fixture |
| EvaluationModes.preparedTwice/rawTwice | [evaluation fixture](../library_comparisons/h07_evaluation_modes_comparision.md) | do and replicateM |
| StepIterator.iterateUntilStop/whileJust | [iterateUntilStop](../library_comparisons/h09_iterator_comparision.md) | monad-loops whileJust_ |
| CharacterRange.between | [between](../library_comparisons/v02_character_range_comparision.md) | Data.Ix.inRange |

All polymorphic helpers preserve their actual value types. The numbers in usage
scenarios are test inputs, not type/arity caps in the core. Partial uses a typed
heterogeneous prefix of arbitrary length; CurryInt is the retained native-curried
representation (the legacy module name does not restrict its type variables).

The LMX `Application`, `ProceduralCapture` and `EvaluationModes` files preserve
explicit scenario mechanisms and evaluation fixtures. Generic core implementations
are linked by the comparison documents; Cycles preserves the complete short loop used by H09; CharacterRange points
to its canonical core definition. The envelope-based iterateUntilStop adapter
is explicitly a separate failure contract, not a requirement of H09. The per-scenario fixture type (such as Int for arithmetic) does not limit
the generic apply, partial or lazy receiver.

`Lazy.hs` implements zero-input lazyIO and generic onceIO with arbitrary input/result types. It includes owner checking, cycle detection and async-exception-safe state
reset. Its scope is one owner; it does not silently claim a shared-memory cache.
LMX uses one owning Message, with existing post for asynchronous requests.

Sources for client interfaces:

- [Haskell 2010, expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html).
- [Control.Monad](https://downloads.haskell.org/ghc/9.6.7.20250131/docs/libraries/base-4.18.3.0/Control-Monad.html).
- [Data.Ix](https://hackage-content.haskell.org/package/base-4.20.2.0/docs/Data-Ix.html).
- [monad-loops 0.4.3](https://hackage-content.haskell.org/package/monad-loops-0.4.3/docs/Control-Monad-Loops.html).

Sources are cited for the contracts. The reference algorithms are independent
comparison code, not copied complete library sources. Runtime verification remains
pending where the corresponding compiler/runtime is unavailable.
