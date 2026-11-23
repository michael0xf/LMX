# Callable adapters: implementation proposal against the current specification

**Status, 2026-11-22:** concrete LMX algorithms are supplied; the five call-phase hooks must be connected to the real kernel. No LMX kernel was included or executed. This is an implementation attempt, not a claim that the runtime acceptance matrix passes.

The authoritative contract is the uploaded [semantics, adapter behavior](../../LMX_semantics.en.md#adapter-behavior), [wrapper behavior](../../LMX_semantics.en.md#adapter-wrappers), [uncurry](../../LMX_semantics.en.md#uncurry-contract), and the current Array/Sequence tasks included with this archive. The separately supplied priority task is reference material: its older names never override the current archive. The implementation uses the current uploaded sources. The exact previous bodies are preserved in [reference/pre_adapter_fix_2026-11-22](reference/pre_adapter_fix_2026-11-22/README.md); they are not assembled or counted as current code.

## What changed

| Earlier mechanism | Current source mechanism |
| --- | --- |
| Rebuild all inputs from their types and mark every input required/private | Keep a type shape and a separate source policy referencing actual declarations, position maps and captured values |
| Generate an explicit `pN := pN` actual for every target position | Select the source namespace through the mapping; an omitted actual stays absent |
| Read every public input before entering an engine | Pass a borrowed ordinary call frame; read only the position demanded by an algorithm |
| Copy a residual initializer without its removed dependencies | Keep the complete source DATA namespace, including captured prefix places and initializer provenance |
| Force all trace arguments | Observe supplied/ready/declaration/state flags without reading a default |
| Compare memo keys made only from explicit input presence | Explicitly snapshot all accepted input values before key comparison and body execution |
| Build every intermediate uncurry stage as `Ti → @` | Inspect and invoke the actual reached callable, retaining its full requirement; stop after the contract's N calls |

All original public receiver names remain. No new parser, public function kind, user-facing frame API or optional library version is introduced. `record` and `signatureTypes` keep their existing `OPERANDS_TEMPLATE` contracts. Ordinary `map`, `apply`, `compose` and the adapters remain ordinary callable operations.

## Source layout

| File | Implemented work |
| --- | --- |
| [adapter_frames.lmx](src/adapter_frames.lmx) | Source/own policy construction, position coverage checks, ready/deferred actual entries, selected-place reads, observation, explicit memo snapshots and forwarding |
| [generic_functions.lmx](src/generic_functions.lmx) | Prefix admission, general partial/curry/flip, N-stage uncurry and ordinary callable building |
| [generic_runtime.lmx](src/generic_runtime.lmx) | Ready-actual apply, common wrapper without eager capture, declared-failure transport |
| [generic_combinators.lmx](src/generic_combinators.lmx) | Composition, permutation, memoization, fix, before/after adaptation, predicates, contracts and overload |
| [generic_wrappers.lmx](src/generic_wrappers.lmx) | Once/lazy cache branches, retries, recovery and non-forcing trace |
| [kernel_contracts.lmx](src/kernel_contracts.lmx) | Existing kernel bridge declarations plus five ordinary call-phase hooks |

The high-level algorithms are present in LMX. The hook provider does not implement partial, curry, uncurry, cache lookup, key construction, trace event assembly, permutation, overload selection or callback loops.

## 1. Type identity and source policy are separate

`FxSignatures\make` creates the usual ordered type description. The normalizer returns an internal reference to an ordinary canonical **int type-code record**; the code refers to the existing full type/model description. `typeof(code)` remains `int`. A full Structure/callable model is not replaced by the coarse code of `@`, and no public boxed Type object is added. The `inputTypes` sequence can therefore store references to code records while preserving all underlying requirements.

The ordinary `FxInputPolicy` structure contains:

| Field | Meaning |
| --- | --- |
| `source` | The actual source callable, or the expressly chosen DATA contract of a genuinely new function |
| `positions` | Public input index → source formal index |
| `boundPositions`, `boundValues` | Already captured ready values at source positions; primitives by value, reference targets retained |
| `pendingPositions` | Future curry positions, not inputs of the current stage |
| `sourcePolicy` | Select source declaration policies, or use the explicitly given own declarations |

`FxSourcePolicy\make` checks ranges, duplicates and total coverage in LMX. Public labels remain `p0…` for generated type shapes; explicit names map to positions before source selection. Autofill uses the real candidate's own names and private marks. No policy is inferred from a signature merely because its type shape matches.

Only service dependencies are uniformly private. Source inputs retain their actual private/required status. A new types-only interface has ordinary uninitialized declarations; it receives no invented defaults or universal required/private flags.

## 2. The binding point and the real source namespace

A source-preserving adapter has one explicit binding point: preparation of its generated ordinary callable from the current caller. The builder's source map selects the corresponding real source declarations and ordinary places at that point. The chosen target call is prepared there and entered later by the engine; engine temporaries are not a new source for its autofill.

This is a split of the **same selected call**, not a new search that jumps over arbitrary callers. Calls which an engine subsequently makes to a predicate, sink, handler, outer function or reached uncurry stage are additional ordinary calls. They use their actual reached call chain, with service inputs private. A pre-existing A → B → C forwarding chain remains a chain; the adapter does not collect all descendants' free names, turn fallback copies into aliases or recover an outer place through private boundaries.

The full target namespace retains captured inputs even when they disappear from the public residual signature. For `F(x; y := expression depending on x)` and a captured `x = 5`, a demanded `y` is evaluated in that target activation with that `x`. Its lexical `node`, physical source links and declaration-form provenance remain original. A new invocation gets new own places; writing them changes neither the source default nor future invocations.

The builder must reuse ordinary call preparation, not create a second expanded executable graph. The generated owner/DATA/CODE is real graph data for the new callable. Policy contains graph references and explicit captured values and is retained in the generated owner's ordinary `private\inputPolicy` field. It is not hidden in a native field. The pending activation contains ordinary places, bindings and call transport, not a copied program graph or global closure environment.

## 3. Five narrow phase hooks

The original signature, graph-building, ready-call and named-failure bridges remain. The added hooks expose phases already needed by ordinary calls:

| Hook | Responsibility | Explicitly does not do |
| --- | --- | --- |
| `currentCall(owner)` | Obtain the current generated invocation's already selected frame view | Read an input, search a factory environment or enter target CODE |
| `frameSlot(frame,index,demand)` | Observe one selected place, or perform its ordinary demanded read | Read the other inputs or invent values for omissions |
| `prepare(operation,entries)` | Perform the reached ordinary call's shape checks, admission and namespace preparation | Execute target CODE, retry W/E, evaluate declaration initializers eagerly |
| `enter(frame,failures)` | Resume the selected call once through the ordinary native/interpreted dispatcher | Re-select actuals, rebind in engine locals, interpret a separate instruction language |
| `releaseCall(frame)` | End a frame owned by `prepare` on every path | Extend a local's lifetime or destroy returned live arena values |

The builder receives the policy and connects it to its ordinary preparation entry. This is the material integration work still required in the kernel. Merely installing empty methods with these names does not implement the package. The smallest useful implementation can retain the existing preparation result and selected namespace, expose their input-place access, and invoke the existing body-entry continuation. The same entry serves known native call sites directly; it need not allocate generic entry structures when ordinary lowering already has registers/slots.

`currentCall` is only valid for the owner of the active generated invocation. A caller cannot submit an arbitrary context. Frames are borrowed Message-local service records. They cannot be copied, serialized, transferred to another Message, used after release or entered twice. The ordinary wrapper exit releases its own frame even on a cache hit; `FxInvokeEntries` uses `finally` to release frames it prepares.

## 4. Actual forms, demand and predicates

The source-preserving wrapper never turns omission into an actual. Explicit values remain explicit, including 0, nil, null references, empty structures and admissible uninitialized records. A declaration actual remains a complete DATA Structure at its selected positional or explicitly outer-named destination. Its internal name does not select another input; the transport neither executes its initializer nor replaces the form by that result.

A predicate needs to be able to read one accepted target input without forcing its neighbor. `FxFrameEntries` constructs **internal `kind=place` entries** referencing those already selected places by destination position and `(frame, sourcePosition)`. These are distinct from `kind=actual`, which retains an explicit source occurrence and its selected mapping. A place entry is not a source declaration actual and is not implemented by matching a declaration's internal name or substituting that form for a primitive formal's description.

The kernel provider must support the place entry through its existing preparation mechanism, preserving demanded reads, ordinary receiving admission, selected place ownership, omission and lifetime. This remains [pending integration gate PA01](tests/ADAPTER_ACCEPTANCE.md#place-actual-integration), not a behavior established by these LMX records. No new public operation or lazy Array type is introduced. A source or actual containing a declaration Structure keeps that structural value and the accepted-form/body execution contract; it does not bypass admission to a primitive input by executing its initializer.

The callee still has its own places and admission. Under the required provider contract, a demanded place read may compute the target default once, while an ignored place entry does not compute it. A predicate's assignment to its own formal does not automatically become a write to the source input; shared reference targets and explicitly chosen transparent bindings keep their normal rules.

`guard` and `contract` therefore share one prepared source call with pre/body/post observation. A rejected precondition never enters the source body. A successful precondition can demand an input; the body later sees that same selected input state. Postconditions run after the body and receive its real result as one additional ready actual, if the source has a result. Previously ready primitive actuals retain their received values for pre/post observation, as in the earlier vector implementation; a private assignment to F's own formal does not rewrite that input record. Reference targets remain shared. For a newly supported omitted/deferred input, ordinary demand occurs through its selected source declaration; the wrapper does not compute a hypothetical initial value before a body assignment merely to manufacture an old snapshot.

## 5. Partial, permutation, curry and fix

`partial` first admits each written ready prefix element under its real Ti. It accepts dense Arrays and Structure/@[] input through normal typed element access; a dense backing is never cast to pointer storage. The residual policy maps the remaining positions, and the engine enters the selected full source call. Empty partial preserves the ordinary mapped call; a full prefix still returns a delayed nullary callable. Neither invokes F during construction.

`flip` constructs the complete permutation and uses `permute`. `permute` moves requirements and source declaration policy together. It does not materialize all actuals simply to reorder them.

`curry` retains its own stagewise meaning. Only the current stage's declaration is selected as a public input. Bound earlier positions remain available to its default; future positions retain source descriptions but are not required inputs of this current unary stage. A non-final stage **does demand and capture its current accepted value** to return a persistent next stage; that demand is part of currying, not a side effect of common transport. It does not capture a live frame. If that current initializer itself demands an as-yet-unbound future place, the usual source declaration/default/uninit behavior applies; it does not silently synthesize a future argument. The final stage enters the full source call. Independent stage branches have independent prefix containers with retained value references.

`fix` reserves the bound self position, builds the ordinary result callable, then fills that explicit graph edge before publishing it. The placeholder is never passed in a call. Builder validation must permit this ordinary two-step graph wiring, while entry validates the completed bound record. No factory stack address is retained.

## 6. Uncurry uses reached contracts

`FxUncurryEngine` is an ordinary LMX loop. It starts at the supplied operation, reads that reached callable's existing signature metadata, checks the unary/nullary shape, supplies the corresponding already selected explicit outer actual/form if one was supplied, and invokes the ordinary call. If that outer position was omitted, the reached unary stage receives no explicit actual: its own required/default/binding rules apply. A fake explicit uninit or deferred place must not suppress its default. The returned typed record is retained in full as the next callable. A record reference `@` is transport, not a declaration that the stage returns `@`.

The explicit outer contract determines N and final R, not defaults for arbitrary actual stages. A fresh type-only flat shape keeps the established generated public pN labels; a named template's initializers are not imported. Explicit outer values are admitted normally and preserved declaration forms are forwarded without re-evaluation. N = 0 performs one nullary call; N > 0 performs exactly N unary calls. The final callable or Structure R is returned without being invoked. An unusable intermediate value fails at the reached next call. A stage's named failure preserves its name/payload; implicit failures are not converted into a Result. Final reception is the wrapper's exact R/void, including the ordinary result-presence check.

There is no factory probe, table of coerced Ti → @ requirements or "while callable" stopping rule. The outer explicit argument expressions have the ordinary flat-call effect order. This does not promise the effect order of a separately written nested expression.

Signature access may reuse the existing prepared call/type metadata. It does not mandate a fresh full signature walk on every known native step. Generated wrapper text is parsed once at construction, not on each invocation.

## 7. Once, trace, recover and memoize

`once` branches on its cache before any input read. Explicit actual expressions were already prepared by the ordinary incoming call. A hit enters no F and reads no unused omitted default. A failed miss clears the in-progress marker; only a successful result is retained. This remains first-success caching, not an external exactly-once protocol.

`trace` events retain `phase`, `args`, `value`, `hasValue`. Each `args[i]` is now an ordinary observation structure with `position`, `supplied`, `ready`, `declaration`, `state`, `requirement`, `ownPlace`, `transparentPlace`, and `value` only when ready. For fully prepared values the same real value is available through `args[i]\value`. States distinguish supplied value, preserved declaration, default, autofill, uninit and future pending place. The enter/return/failure snapshots can differ as deferred values become available. Ready received primitive actual records remain stable; shared reference targets follow their ordinary identity and mutation rules.

Events expose no live frame/cell capability, so retaining a passive event cannot trigger an initializer or read an expired frame later. Primitive ready observations use an ordinary stable value record; reference targets keep their existing lifetime, without a deep copy. Deliberately calling a stored user callable remains the sink's own action. A throwing sink still can replace an earlier failure under the documented normal cleanup rules.

`recover` passes its handler `(name; payload; originalArgs)` with `originalArgs` in the same observation format. A failure does not force untouched inputs merely to construct the handler's metadata. This is a documented shape change from the earlier always-ready-vector assumption.

`memoize` uses an explicit **value key policy**: before comparison or F's body, read every exposed accepted input in position order and capture a primitive-by-value/reference-by-target snapshot. Defaults and autofill are therefore resolved for the key; this is the operation's own observation. Omission with a default of 0 can compare equal to explicit 0 if `sameKey` says their accepted values are equal, but omission alone never gives a hit. Different autofill values produce different key values. A required failure occurs at selection; an uninitialized value demanded by key construction has its ordinary failure. Keys are fixed before body writes. A failed body is not inserted. Equality and reachable reference data must remain stable for the chosen key contract; hidden mutable dependencies of F are not automatically memoized.

## 8. Shared algorithms and other clients

The former independent `FxConcat`, `FxAppend` and `FxSlice` loops now delegate to the common sequence algorithms. `FxConcat` retains two char[] inputs and a char[] result; `FxAppend` retains a fresh reference-array result by supplying an explicit empty @[] part to generic concat; `FxSlice` retains its reference-vector start/count contract and checked conversion to public slice's begin/end. This unifies implementation without mechanically renaming the private helpers or changing public slice. Their old bodies remain in the historical snapshot.

### Other clients and bounds

`compose/pipe` preserve the inner function's input policy and then call the outer function normally. `predicate` preserves source inputs and only changes the result to boolean. `adapter` takes its external input policy from its actual `before` callable; the explicit contract supplies the intended outer type shape and result. Its mapped ready actuals and `after` call remain ordinary calls. `overload` has its expressly supplied own outer DATA policy; it does not steal defaults from its first candidate. Its tests and chosen branch consume selected outer places through the internal `place` transport, subject to the same pending PA01 provider requirement.

`apply` accepts a ready finite Array of actual values, including a dense Array. A callback may have additional optional formals; its own rules govern missing positions. `repeat` and `retryCall` snapshot only the supplied ready actuals. Omitted tail inputs remain omitted on each fresh attempt and keep their source defaults. The snapshot does not become an eager execution of every possible target default.

Compilation remains explicit. Newly built owner/DATA/CODE does not borrow an old incompatible native entry. Permitted graph edits and the existing `endturn`/native validity rules remain the authority. The proposal neither adds dirty-bit recompilation nor claims old call metadata stays valid across an inadmissible edit.

## 9. Verification and remaining integration

[ADAPTER_ACCEPTANCE.md](tests/ADAPTER_ACCEPTANCE.md) links the current specification's A01–A20/B01–B11 observations to the supplied fixture source and future kernel runs. [adapter_acceptance.json](tests/adapter_acceptance.json) records every case as **not run** in I→I, I→N, N→I and N→N. [adapter_semantics.lmx](tests/adapter_semantics.lmx) supplies concrete probes for defaults, demand, dependent prefix, private/autofill, once/trace/guard, exact stage models, final callable and effect order.

The remaining work is to connect and test the five phase hooks, generated input-policy preparation, the PA01 distinction between internal places and actual declaration Structures, result lifetime and native lowering against the real kernel. Text checks and finite effect bookkeeping do not establish those properties. The current sources remove the earlier eager vector and coerced-stage algorithms; only real execution can establish that their integration satisfies all required observations.
