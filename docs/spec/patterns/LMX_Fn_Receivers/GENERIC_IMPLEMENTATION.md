# Architecture of the general receiver implementations

## Generality

The implementations derive finite input count and complete type requirements from the existing signature analyzer. They are not binary-int adapters. Inputs and results can be primitives, dense Arrays, Structure/@[], callable models or void where admitted by the ordinary contract. There is no fixed arity table.

A Structure already is an array of references to value records. Algorithms use it directly, without an items wrapper. Dense Arrays use their real type and stride. A transport @ points to the actual typed record; it does not coerce every semantic type to @ or add a mandatory second box around a referenced Structure.

Postfix type constructors return canonical TypeRef references to complete normalized type descriptions. Normalization accepts these system descriptions directly and retains the established uninitialized declaration TYPE form without reading absent payload. An arbitrary initialized int is not a type-id or pointer. Source prototypes still using int-code records require the documented ABI migration; no second box or independent registry is introduced.

## Source layers

| Source | Role |
| --- | --- |
| [kernel_contracts.lmx](src/kernel_contracts.lmx) | Thin existing analyzer/builder/call hooks and five phase hooks for ordinary invocation |
| [fn_operand.lmx](src/fn_operand.lmx) | Existing `->` operand with explicitly composed left/right, mode and priority |
| [generic_functions.lmx](src/generic_functions.lmx) | Exact signature construction, prefix admission, partial/curry/flip/uncurry |
| [adapter_frames.lmx](src/adapter_frames.lmx) | Real source input policies, projection entries, one-place reads, observation and snapshots |
| [generic_runtime.lmx](src/generic_runtime.lmx) | Ready-actual apply and wrapper entry without eager argument capture |
| [generic_combinators.lmx](src/generic_combinators.lmx) | Composition, permutation, memoization, fix, before/after adaptation and predicates |
| [generic_wrappers.lmx](src/generic_wrappers.lmx) | First-success caching, retry, resource bracket, recovery and trace |
| [reflection_bridges.lmx](src/reflection_bridges.lmx) | Semantic signature and existing owning-field names |
| [collections.lmx](src/collections.lmx) | General collection algorithms through the shared typed sequence access |
| [containers.lmx](src/containers.lmx) | Maybe/Result/List/Bounce algorithms |
| [structures.lmx](src/structures.lmx) | Ordinary structural selection/composition operations |
| [coreGenericOperations.lmx](src/coreGenericOperations.lmx) | Shared projection/equality, value pipeline and result-based retry; exact public builders |
| [monadic_forms.lmx](src/monadic_forms.lmx), [operation_forms.lmx](src/operation_forms.lmx) | Whole-value constructors, typed container families and role-preserving representations |
| [sequence_profiles.lmx](src/sequence_profiles.lmx) | Explicit range/codec profiles and exact text defaults without a second algorithm |
| [public_families.lmx](src/public_families.lmx), [public.lmx](src/public.lmx), [public_operands.lmx](src/public_operands.lmx) | Complete semantic families, receiver projection and VALUE operand construction |

All receivers already enter Expression through P0. The translator supplies their existing semantic action under the original roles. Exact quoted names and ordinary spellings share identity; quoting does not select semantics. Built-in PLACE/control/type operations use the same role-aware path rather than the eager VALUE adapter. See [operation forms](../../OPERATION_FORMS.md) and [publication](PUBLICATION_CONTRACT.md).

The ordinary `FxPreparedOperands` fragment supplies private `left/right` and
ready prepared-value mode. Its consumers explicitly supply their own ready
priority, input requiredness and result. No system template object or implicit
priority is assumed; see [the exact declarations and priority table](PUBLICATION_CONTRACT.md#prepared-operand-data).

## Callable construction and call preservation

`FxBuild` parses generated CODE once with the existing `sys\fromLmx` and calls the ordinary graph builder. Actual parent links are real. Explicit state is an ordinary private graph structure. No foreign native entry is reused and compilation remains explicit.

A type signature is not a substitute for a source declaration's call policy. `FxInputPolicy` keeps the actual source, public-to-source positions, captured ready values and future curry positions. Exact type identity still ignores names/defaults/required/private/throws. Own interfaces without a source use expressly chosen ordinary declarations.

`FxWrap` obtains the invocation's already prepared call frame and passes that borrowed handle to the selected engine. It never reads every pN into a vector. The engine can enter the selected source call, demand one input, create internal `place` transport entries for a predicate, or observe ready-state metadata. Place entries are distinct from explicit `actual` occurrences; their required demanded-read provider remains pending integration. Source defaults keep their original DATA/node and access to captured prefix places. Private service locals are never used as accidental target autofill.

The source call's binding point is preparation of the generated callable from its current caller. An engine's later predicate/sink/handler/outer/stage calls remain ordinary additional calls, with the normal forwarding/private rules. This does not skip arbitrary A→B→C chains or collect descendants' free names.

Full algorithms and the exact frame lifecycle are in [ADAPTER_IMPLEMENTATION.md](ADAPTER_IMPLEMENTATION.md); the narrow provider obligations are in [KERNEL_REQUIREMENTS.md](KERNEL_REQUIREMENTS.md).

## Whole-value construction, bind and value pipelines

`FxRecordAdapter` is the single input capture algorithm. It accepts the actual complete T once and passes its record to one constructor position. `some/ok/err/done` retain exact reference results; `type` shares capture and returns its actual canonical TypeRef. Internal ready-record calls do not apply capture again. Dynamic binding and copy preserve their ordinary roles.

`bind` publishes distinct Maybe, Result and Array requirements under one name. The ordinary and operand paths share each family's existing body. Maybe and Result short-circuit; Array bind concatenates one level into the declared reference-record Array. No field-count test or speculative callback chooses a family. `then` belongs to generic Pattern composition.

`compose` constructs a callable; `pipe(value; stages)` immediately applies stages. The internal engine returns a result record, while `FxPipeBuild` publishes exact T → R through `FxWrap`. `FxRetryBuild` similarly publishes the request's exact R for result-based `retry`. Preparation and execution retain separate finite failure contracts. `retryCall` repeats declared failures; `retryPost` owns its asynchronous Message state. See [PUBLICATION_CONTRACT.md](PUBLICATION_CONTRACT.md).

## Partial and curry

A written prefix is admitted under its real Ti before publication. Dense and reference-array inputs use typed access. Primitives are captured by value; targets of reference values retain identity and normal lifetime. The residual source namespace still contains captured positions, so dependent defaults work in the original context.

Partial with an empty prefix, `partial(F; prefix := ())`, keeps the ordinary mapped input behavior. A full prefix returns a nullary callable and does not invoke F immediately. Flip/permute move source policies with positions.

Curry keeps its stagewise meaning: a non-final stage consumes and captures its one current accepted input, then constructs a persistent next-stage graph. It keeps no expired frame. Future positions are not forced merely to return the next stage. Its own reference-valued middle-stage protocol does not become a restriction on independently supplied uncurry chains.

## Uncurry

The explicit flat contract supplies N and final R/void. At each reached step the loop obtains the actual current callable's complete description and uses the ordinary preparation/entry path. No forced Ti→@ table is constructed. A supplied outer occurrence is forwarded once with its original form; an omitted position stays omitted so the reached stage keeps its own default/required policy. Named signature-template defaults are not assigned to unrelated stages. A returned typed record retains its actual Structure/callable model.

N>0 invokes exactly N unary stages; N=0 invokes one nullary stage. The final callable value is returned without another call. Result presence and ordinary final receiving R remain checked. An incompatible intermediate result fails only at its reached next call; later bodies do not run. No factory probes occur.

Explicit outer actuals retain ordinary flat-call evaluation order. Prepared-value stage equivalence does not claim equivalence with an effectful nested source expression that evaluates later arguments at different times.

## Operation-specific observation

Once checks its successful cache before input demand. A hit still follows normal explicit-actual preparation but forces no unused default.

Guard/contract pass internal `kind=place` entries referring to already selected source places by destination position and `(frame, sourcePosition)`. The required provider must let a predicate demand one input without forcing its untouched neighbor, while preserving receiving admission and own-versus-transparent place semantics. This is [pending integration gate PA01](tests/ADAPTER_ACCEPTANCE.md#place-actual-integration), not an application of declaration-actual substitution. A `kind=actual` containing a declaration remains an ordinary DATA Structure at its selected positional/outer-label destination; its internal name is not searched and transfer executes no initializer. No structural actual gains a bypass into a primitive formal. The same prepared source activation is later entered, and postconditions consume its input observation and genuine result. Already received primitive actuals retain their original values despite assignments to F's own formals; shared reference targets retain normal mutation behavior.

Trace and recover create ordinary observation structures. Their argument metadata distinguishes supplied/ready/declaration/default/autofill/uninit; only ready values are included. No event keeps a live frame. Passive observation performs no initializer or converter.

Memoization explicitly snapshots all accepted inputs for its key before lookup and body execution. This is the documented value-key policy, not generic wrapper behavior. Omission is resolved under actual source policy before equality; no false hit follows solely from two absent actual lists. Stable key equality/reference targets remain the caller's contract, and failed calls are not cached.

## Failures and effects

Ready calls and frame entry return `FxOutcome` with the true result record or the original declared failure name/payload. Only known admitted declared names are caught. Implicit failures remain implicit.

The generic LMX layer transports a declared failure through `FxCallFailure`. Generated CODE catches that envelope and re-raises the original name within its computed finite outcome set. No `throws:*` or arbitrary root context is invented. A throwing logger or cleanup routine follows normal language exit precedence.

A sequence callback receives its stated number of actuals; additional optional formals follow its own real defaults/private/required rules. Apply does not force a full-width vector. Repeat/retry snapshot only supplied ready actuals, preserving omitted tail positions on each call.

## Ownership, native execution and current status

Factory state and caches are ordinary Message-local structures. The design does not share them secretly between Threads. A frame reference is borrowed service state, cannot be serialized or retained, and does not prolong a local lifetime. Native results use valid arena records or the normal direct ABI, never pointers into finished C stack slots.

Known prepared native paths can use existing metadata and direct arguments. The general implementation does not demand boxing every native primitive, reparsing text per call or rebuilding the whole signature at each step. Plain graph editing and subsequent interpretation use the current graph without compile/endturn. Explicit compilation and the turn boundary govern replacement of the machine implementation; editing the graph alone neither recompiles it nor patches old native callers.

The current archive supplies source-level algorithms and concrete fixtures. The real kernel provider and runtime executions are not present. No A/B case is marked runtime PASS. The current sources and fixtures are self-contained; they do not depend on absent historical snapshots. The permanent [generic operation contracts](../../GENERIC_OPERATIONS.md), [monadic contracts](../../MONADIC_OPERATIONS.md) and [operation forms](../../OPERATION_FORMS.md) contain the complete algorithms, names and acceptance requirements.
