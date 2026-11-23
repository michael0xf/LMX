# Direct functions for the current LMX core

Edition: **23 November 2026**, based on the newly uploaded `spec.tar.gz`.

This is the common integration inventory of **123 public callable/operand names**. It is generated from the same [catalog](patterns/LMX_Fn_Receivers/catalog.json) as [the constant exports](patterns/LMX_Fn_Receivers/src/public.lmx). All belong to the current kernel. Clients call them directly; there is no optional LMX library import or parallel version of these facilities.

Public names use **lowerCamelCase**. Existing single-word identifiers remain lowercase. Implementation groups, types, named failures, ready Pattern values and symbolic language operators are separate categories; they are not extra functions in this count.

Each linked source contains the LMX algorithm. `BODY_WITH_BRIDGE` means that the algorithm uses the documented common kernel interfaces; it does not mean a native implementation has been supplied or executed. The archive contains no runnable LMX kernel. [Kernel requirements](patterns/LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md) identify the exact remaining integration boundaries. All runtime acceptance cases remain NOT_RUN.

## Use and implementation are separate comparisons

LMX examples use these core functions. Control-language usage examples use real language facilities or named established libraries. Our independently written foreign implementations are retained beside LMX implementations for comparison; they are not dependencies of those foreign clients. See the [comparison revision](patterns/CORE_COMPARISONS_2026-11-23.md) for client-to-implementation links, external packages and completeness boundaries.

A complete implementation here means the stated operation contract: arbitrary admitted payload types and finite sizes where applicable, empty inputs, failure propagation, ordering and lifecycle behavior. It does not claim to reproduce every unrelated API of a larger package such as `scala.util.Using` or a retry framework. Application fixtures (for example, integer halving or a Money record) do not specialize the core helper.

## Message and asynchronous execution

A mutable asynchronous algorithm runs in its owning `Message` and uses the existing [post/reply transport](LMX_semantics.en.md#thread-message-api), including the HTTP profile. Callbacks, declaration places and mutable state do not become shared references across arenas. Posting the entire owning method is sufficient for synchronous combinators such as `trampoline` or `bracket`; a second scheduler inside them would duplicate transport. Their source comments state that boundary explicitly.

`bracket` protects acquisition/action/release in one owning activation. If its action posts unrelated work and returns immediately, that work does not extend the resource lifetime. A timeout is notification under the transport contract; it does not cancel an in-flight operation, discard its later reply or permit reclaiming a live Message arena. Stateful retry policy is specified separately from synchronous declared-failure `retryCall`.

## Function inventory

### Reflection and structure composition

| Function / operand | Contract | LMX source |
| --- | --- | --- |
| `types(source)` | physical field type codes; int[] by language contract | [reflection.lmx](patterns/LMX_Fn_Receivers/src/reflection.lmx) |
| `names(source)` | physical canonical names; anonymous entries retain typed absence | [reflection_bridges.lmx](patterns/LMX_Fn_Receivers/src/reflection_bridges.lmx) |
| `signature(operation)` | ordinary positional signature description | [reflection_bridges.lmx](patterns/LMX_Fn_Receivers/src/reflection_bridges.lmx) |
| `select(source; indices)` | actual-type selection preserving dense/reference profile | [structures.lmx](patterns/LMX_Fn_Receivers/src/structures.lmx) |
| `omit(source; indices)` | actual-type omissions preserving dense/reference profile | [structures.lmx](patterns/LMX_Fn_Receivers/src/structures.lmx) |
| `rename(source; indices; labels)` | one graph copy then canonical field names updated | [reflection_bridges.lmx](patterns/LMX_Fn_Receivers/src/reflection_bridges.lmx) |
| `reorder(source; permutation)` | full checked permutation, any field value types | [structures.lmx](patterns/LMX_Fn_Receivers/src/structures.lmx) |
| `project(source; indices)` | one shared graph copy of selected fields | [structures.lmx](patterns/LMX_Fn_Receivers/src/structures.lmx) |
| `defaults(source; fallback)` | merge(fallback; source), existing presence including uninit wins | [structures.lmx](patterns/LMX_Fn_Receivers/src/structures.lmx) |
| `diff(before; after)` | identity-vector patch, not deep payload equality | [structures.lmx](patterns/LMX_Fn_Receivers/src/structures.lmx) |
| `patch(source; change)` | prevalidated identity-vector patch in fresh container | [structures.lmx](patterns/LMX_Fn_Receivers/src/structures.lmx) |
| `bindFields(operation; bindings)` | DATA defaults through merge; residual input positions not removed | [structures.lmx](patterns/LMX_Fn_Receivers/src/structures.lmx) |
| `derive(base; extension)` | ordinary merge composition | [structures.lmx](patterns/LMX_Fn_Receivers/src/structures.lmx) |
| `composeData(code; overlay)` | merge actual parent DATA with explicit data overlay | [structures.lmx](patterns/LMX_Fn_Receivers/src/structures.lmx) |

### Callable construction, composition and lifetime

| Function / operand | Contract | LMX source |
| --- | --- | --- |
| `R signatureTypes T0 ... TN; explicit fun\const\signatureTypes(left := R; right := types)` | same signature kind: result type token left, all ordered input tokens right | [fn_operand.lmx](patterns/LMX_Fn_Receivers/src/fn_operand.lmx) |
| `curry(operation)` | arbitrary finite arity, exact stage input type and terminal result | [generic_functions.lmx](patterns/LMX_Fn_Receivers/src/generic_functions.lmx) |
| `apply(operation; args)` | arbitrary actual record vector; result record including explicit void | [generic_runtime.lmx](patterns/LMX_Fn_Receivers/src/generic_runtime.lmx) |
| `partial(operation; prefix)` | prefix 0..N; exact residual signature, complete prefix yields thunk | [generic_functions.lmx](patterns/LMX_Fn_Receivers/src/generic_functions.lmx) |
| `uncurry(operation; contract; failures)` | explicit full target contract and stage failures, callable result preserved | [generic_functions.lmx](patterns/LMX_Fn_Receivers/src/generic_functions.lmx) |
| `flip(operation)` | swap first two positions of N>=2 with full input types | [generic_functions.lmx](patterns/LMX_Fn_Receivers/src/generic_functions.lmx) |
| `compose(outer; inner)` | inner arbitrary arity; outer consumes its one result; exact final R | [generic_combinators.lmx](patterns/LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `pipe(first; second)` | compose(second; first), exact callable signature | [generic_combinators.lmx](patterns/LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `identity(typeToken)` | typed T -> T for any valid value type | [generic_combinators.lmx](patterns/LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `memoize(operation; sameKey)` | any arity/R; explicit key-vector equality, Message-local linear cache | [generic_combinators.lmx](patterns/LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `fix(operation)` | F(self;T0..Tn)->R becomes T0..Tn->R | [generic_combinators.lmx](patterns/LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `lazy(operation)` | typed nullary thunk, first successful result cached | [generic_wrappers.lmx](patterns/LMX_Fn_Receivers/src/generic_wrappers.lmx) |
| `force(thunk)` | nullary call returning typed result record; direct thunk() keeps R | [generic_wrappers.lmx](patterns/LMX_Fn_Receivers/src/generic_wrappers.lmx) |
| `once(operation)` | any arity/R; first success reused, failure permits retry | [generic_wrappers.lmx](patterns/LMX_Fn_Receivers/src/generic_wrappers.lmx) |
| `repeat(operation; count; args=())` | count calls with arbitrary typed actual vector; result records | [generic_wrappers.lmx](patterns/LMX_Fn_Receivers/src/generic_wrappers.lmx) |
| `runUntil(step; finished; initial)` | record state; step then predicate, no fixed payload type | [generic_wrappers.lmx](patterns/LMX_Fn_Receivers/src/generic_wrappers.lmx) |
| `retryCall(operation; attempts; args=())` | finite attempts, declared failures retained in FxCallFailure envelope | [generic_wrappers.lmx](patterns/LMX_Fn_Receivers/src/generic_wrappers.lmx) |
| `bracket(acquire; release; action; arguments=())` | any resource/result; finally release; arbitrary extra action inputs | [generic_wrappers.lmx](patterns/LMX_Fn_Receivers/src/generic_wrappers.lmx) |
| `recover(operation; handler)` | exact signature; handler(name,payload,actualVector) -> R | [generic_wrappers.lmx](patterns/LMX_Fn_Receivers/src/generic_wrappers.lmx) |
| `adapter(operation; before; after; contract)` | arbitrary external/internal arity, explicit new exact contract | [generic_combinators.lmx](patterns/LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `permute(operation; permutation)` | arbitrary N, reorder interface and actuals together | [generic_combinators.lmx](patterns/LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `overload(candidates; accepts; contract)` | explicit pure predicates, exactly one branch, full external signature | [generic_combinators.lmx](patterns/LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `predicate(operation)` | same arbitrary inputs; normalize ordinary int Boolean output | [generic_combinators.lmx](patterns/LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `guard(operation; accepts)` | same exact signature with precondition over all actuals | [generic_combinators.lmx](patterns/LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `trace(operation; sink)` | arbitrary signature, events retain typed args/result/void distinction | [generic_wrappers.lmx](patterns/LMX_Fn_Receivers/src/generic_wrappers.lmx) |
| `contract(operation; pre; post)` | same signature, pre(args), post(args,result) or post(args) for void | [generic_combinators.lmx](patterns/LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `record(left; right=())` | prepared postfix capture; pointer to typed record, no value dereference | [generic_functions.lmx](patterns/LMX_Fn_Receivers/src/generic_functions.lmx) |

### Universal sequences

| Function / operand | Contract | LMX source |
| --- | --- | --- |
| `map(items; transform)` | universal sequence, ordinary callback admission/defaults, result reference vector | [collections.lmx](patterns/LMX_Fn_Receivers/src/collections.lmx) |
| `filter(items; accepts)` | universal sequence; stable storage-preserving selection and int predicate | [collections.lmx](patterns/LMX_Fn_Receivers/src/collections.lmx) |
| `foldl(items; seed; step)` | left fold over any accumulator/item/result records | [collections.lmx](patterns/LMX_Fn_Receivers/src/collections.lmx) |
| `zip(first; second)` | pairs of typed records, min length | [collections.lmx](patterns/LMX_Fn_Receivers/src/collections.lmx) |
| `zipWith(first; second; combine)` | arbitrary binary callback types, result records | [collections.lmx](patterns/LMX_Fn_Receivers/src/collections.lmx) |
| `scanl(items; seed; step)` | seeded scan, n+1 records; accumulator type not hardwired | [collections.lmx](patterns/LMX_Fn_Receivers/src/collections.lmx) |
| `traverse(items; next)` | Maybe of direct Structure record vector; stop at first absence | [collections.lmx](patterns/LMX_Fn_Receivers/src/collections.lmx) |
| `transpose(rows)` | rectangular Structure of row values; no fixed dimensions | [collections.lmx](patterns/LMX_Fn_Receivers/src/collections.lmx) |
| `groupBy(items; keyOf; sameKey)` | typed keys and explicit equality, stable group/member order | [collections.lmx](patterns/LMX_Fn_Receivers/src/collections.lmx) |
| `range(start; stop; step=1)` | dense int range, stop excluded, checked extent | [sequences.lmx](patterns/LMX_Fn_Receivers/src/sequences.lmx) |
| `slice(source; begin; end)` | validated half-open selection preserving actual storage profile | [sequences.lmx](patterns/LMX_Fn_Receivers/src/sequences.lmx) |
| `reverse(source)` | new reverse container, reference targets retained | [sequences.lmx](patterns/LMX_Fn_Receivers/src/sequences.lmx) |
| `concat(parts)` | one-level concatenation; same dense T or ordinary reference array | [sequences.lmx](patterns/LMX_Fn_Receivers/src/sequences.lmx) |
| `compress(source; mask)` | same-length int truth mask; stable profile-preserving selection | [sequences.lmx](patterns/LMX_Fn_Receivers/src/sequences.lmx) |
| `any(items; accepts)` | ordered predicate calls, stop at first true | [sequences.lmx](patterns/LMX_Fn_Receivers/src/sequences.lmx) |
| `all(items; accepts)` | ordered predicate calls, stop at first false | [sequences.lmx](patterns/LMX_Fn_Receivers/src/sequences.lmx) |
| `index(items; accepts)` | Maybe of first int index, none when absent | [sequences.lmx](patterns/LMX_Fn_Receivers/src/sequences.lmx) |
| `count(items; accepts)` | count accepted items in source order | [sequences.lmx](patterns/LMX_Fn_Receivers/src/sequences.lmx) |
| `replaceRange(target; begin; end; values)` | preflight then overlap-safe replacement, same target descriptor | [sequences_mutation.lmx](patterns/LMX_Fn_Receivers/src/sequences_mutation.lmx) |
| `splice(target; begin; end; values)` | same replacement; return a fresh shallow snapshot of removed elements, preserving dense/reference profile | [sequences_mutation.lmx](patterns/LMX_Fn_Receivers/src/sequences_mutation.lmx) |
| `append(target; values)` | same target, source values fixed before writes | [sequences_mutation.lmx](patterns/LMX_Fn_Receivers/src/sequences_mutation.lmx) |
| `insert(target; position; values)` | replaceRange at one position | [sequences_mutation.lmx](patterns/LMX_Fn_Receivers/src/sequences_mutation.lmx) |
| `deleteAt(target; begin; end)` | replaceRange with no inserted values | [sequences_mutation.lmx](patterns/LMX_Fn_Receivers/src/sequences_mutation.lmx) |

### Value containers and trampoline

| Function / operand | Contract | LMX source |
| --- | --- | --- |
| `bind(input; next)` | Maybe of any typed record; next gets actual payload value | [containers.lmx](patterns/LMX_Fn_Receivers/src/containers.lmx) |
| `some(value)` | Maybe present with any typed value record, including null | [containers.lmx](patterns/LMX_Fn_Receivers/src/containers.lmx) |
| `none()` | Maybe absence, distinct from present empty/null value | [containers.lmx](patterns/LMX_Fn_Receivers/src/containers.lmx) |
| `ok(value)` | Result success carrying any typed value record | [containers.lmx](patterns/LMX_Fn_Receivers/src/containers.lmx) |
| `err(reason)` | Result failure carrying any typed reason record | [containers.lmx](patterns/LMX_Fn_Receivers/src/containers.lmx) |
| `bindResult(input; next)` | typed Result success chain, failure kept | [containers.lmx](patterns/LMX_Fn_Receivers/src/containers.lmx) |
| `list(values)` | universal sequence input, shallow copied reference vector | [containers.lmx](patterns/LMX_Fn_Receivers/src/containers.lmx) |
| `flatMap(items; next)` | universal sequence bind, no artificial list.items box | [containers.lmx](patterns/LMX_Fn_Receivers/src/containers.lmx) |
| `done(value)` | terminal Bounce with result record | [containers.lmx](patterns/LMX_Fn_Receivers/src/containers.lmx) |
| `more(thunk)` | suspended nullary callable, arbitrary captures via partial | [containers.lmx](patterns/LMX_Fn_Receivers/src/containers.lmx) |
| `trampoline(current)` | iterate Bounce until done, never execute callable final result | [containers.lmx](patterns/LMX_Fn_Receivers/src/containers.lmx) |

### Text patterns and matching

| Function / operand | Contract | LMX source |
| --- | --- | --- |
| `literal(text)` | ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md | [primitives.lmx](patterns/LMX_Fn_Receivers/src/regex/primitives.lmx) |
| `oneOf(text)` | ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md | [primitives.lmx](patterns/LMX_Fn_Receivers/src/regex/primitives.lmx) |
| `noneOf(text)` | ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md | [primitives.lmx](patterns/LMX_Fn_Receivers/src/regex/primitives.lmx) |
| `charRange(first; last)` | ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md | [primitives.lmx](patterns/LMX_Fn_Receivers/src/regex/primitives.lmx) |
| `satisfy(predicate)` | ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md | [primitives.lmx](patterns/LMX_Fn_Receivers/src/regex/primitives.lmx) |
| `boundaryOf(predicate)` | ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md | [primitives.lmx](patterns/LMX_Fn_Receivers/src/regex/primitives.lmx) |
| `sameAs(name)` | ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md | [primitives.lmx](patterns/LMX_Fn_Receivers/src/regex/primitives.lmx) |
| `sequence(patterns)` | ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md | [combinators.lmx](patterns/LMX_Fn_Receivers/src/regex/combinators.lmx) |
| `choice(patterns)` | ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md | [combinators.lmx](patterns/LMX_Fn_Receivers/src/regex/combinators.lmx) |
| `repeated(pattern; minimum=0; maximum=unbounded; order=extendFirst)` | ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md | [combinators.lmx](patterns/LMX_Fn_Receivers/src/regex/combinators.lmx) |
| `atomic(pattern)` | ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md | [combinators.lmx](patterns/LMX_Fn_Receivers/src/regex/combinators.lmx) |
| `capture(name; pattern)` | ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md | [combinators.lmx](patterns/LMX_Fn_Receivers/src/regex/combinators.lmx) |
| `ahead(pattern)` | ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md | [combinators.lmx](patterns/LMX_Fn_Receivers/src/regex/combinators.lmx) |
| `notAhead(pattern)` | ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md | [combinators.lmx](patterns/LMX_Fn_Receivers/src/regex/combinators.lmx) |
| `behind(pattern)` | ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md | [combinators.lmx](patterns/LMX_Fn_Receivers/src/regex/combinators.lmx) |
| `notBehind(pattern)` | ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md | [combinators.lmx](patterns/LMX_Fn_Receivers/src/regex/combinators.lmx) |
| `utf8Text(source)` | ordinary text-pattern text_profile; see REGEX_IMPLEMENTATION.md | [text.lmx](patterns/LMX_Fn_Receivers/src/regex/text.lmx) |
| `byteText(source)` | ordinary text-pattern text_profile; see REGEX_IMPLEMENTATION.md | [text.lmx](patterns/LMX_Fn_Receivers/src/regex/text.lmx) |
| `matchAt(source; pattern; position)` | ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md | [operations.lmx](patterns/LMX_Fn_Receivers/src/regex/operations.lmx) |
| `wholeMatch(source; pattern)` | ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md | [operations.lmx](patterns/LMX_Fn_Receivers/src/regex/operations.lmx) |
| `find(source; pattern)` | ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md | [operations.lmx](patterns/LMX_Fn_Receivers/src/regex/operations.lmx) |
| `eachMatch(source; pattern)` | ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md | [operations.lmx](patterns/LMX_Fn_Receivers/src/regex/operations.lmx) |
| `contains(source; pattern)` | ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md | [operations.lmx](patterns/LMX_Fn_Receivers/src/regex/operations.lmx) |
| `hasPrefix(source; pattern)` | ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md | [operations.lmx](patterns/LMX_Fn_Receivers/src/regex/operations.lmx) |
| `hasSuffix(source; pattern)` | ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md | [operations.lmx](patterns/LMX_Fn_Receivers/src/regex/operations.lmx) |
| `matches(source; pattern)` | ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md | [operations.lmx](patterns/LMX_Fn_Receivers/src/regex/operations.lmx) |
| `matchedSpan(result)` | ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md | [operations.lmx](patterns/LMX_Fn_Receivers/src/regex/operations.lmx) |
| `matchedText(result)` | ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md | [operations.lmx](patterns/LMX_Fn_Receivers/src/regex/operations.lmx) |
| `captureSpans(result; name)` | ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md | [operations.lmx](patterns/LMX_Fn_Receivers/src/regex/operations.lmx) |
| `lastCapture(result; name)` | ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md | [operations.lmx](patterns/LMX_Fn_Receivers/src/regex/operations.lmx) |
| `captureText(result; name)` | ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md | [operations.lmx](patterns/LMX_Fn_Receivers/src/regex/operations.lmx) |
| `captureTexts(result; name)` | ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md | [operations.lmx](patterns/LMX_Fn_Receivers/src/regex/operations.lmx) |
| `replaceFirst(source; pattern; replacement)` | ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md | [operations.lmx](patterns/LMX_Fn_Receivers/src/regex/operations.lmx) |
| `replace(source; pattern; replacement)` | ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md | [operations.lmx](patterns/LMX_Fn_Receivers/src/regex/operations.lmx) |
| `split(source; pattern)` | ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md | [operations.lmx](patterns/LMX_Fn_Receivers/src/regex/operations.lmx) |
| `then(left; right)` | ordinary Pattern operand with common left/right ABI | [operands.lmx](patterns/LMX_Fn_Receivers/src/regex/operands.lmx) |
| `times(left; right)` | ordinary Pattern operand with common left/right ABI | [operands.lmx](patterns/LMX_Fn_Receivers/src/regex/operands.lmx) |
| `atLeast(left; right)` | ordinary Pattern operand with common left/right ABI | [operands.lmx](patterns/LMX_Fn_Receivers/src/regex/operands.lmx) |
| `atMost(left; right)` | ordinary Pattern operand with common left/right ABI | [operands.lmx](patterns/LMX_Fn_Receivers/src/regex/operands.lmx) |
| `optional(left; right)` | ordinary Pattern operand with common left/right ABI | [operands.lmx](patterns/LMX_Fn_Receivers/src/regex/operands.lmx) |

### Selection, predicates, equality and Message retry

| Function / operand | Contract | LMX source |
| --- | --- | --- |
| `findFirst(items; accepts)` | first accepted typed element as some(record), none for absence; ordered short-circuit over dense Arrays and Structures | [coreComparisonGroups.lmx](patterns/LMX_Fn_Receivers/src/coreComparisonGroups.lmx) |
| `allOf(predicates; contract=0)` | arbitrary finite predicate composition with a shared ordered signature, preserved input places and short-circuit; empty set requires an explicit contract | [coreComparisonGroups.lmx](patterns/LMX_Fn_Receivers/src/coreComparisonGroups.lmx) |
| `equalFields(first; second; same)` | ordered sequence/field equality with explicit typed comparator; unequal lengths are false, empty equal lengths are true; no implicit deep graph equality | [coreComparisonGroups.lmx](patterns/LMX_Fn_Receivers/src/coreComparisonGroups.lmx) |
| `retryPost(request; retryOn; attempts; delay; firstDelay; maxDelay; timeoutMs; complete)` | Message-owned bounded retry with saturated backoff, transport timeout and policy cancellation; persistent terminal result and late-reply draining | [coreComparisonGroups.lmx](patterns/LMX_Fn_Receivers/src/coreComparisonGroups.lmx) |

### Declared-form iteration and ordered ranges

| Function / operand | Contract | LMX source |
| --- | --- | --- |
| `between(left; right)` | prepared operand for inclusive ordered bounds; exactly two right values, ordinary actual comparison types and the priority of <= | [coreComparisonExamples.lmx](patterns/LMX_Fn_Receivers/src/coreComparisonExamples.lmx) |
| `iterateUntilStop(iteration; body)` | execute accepted declaration DATA and associated body in their receiving activation; source Stop terminates, other declared exits retain name/payload in FxCallFailure; requires AE01 | [coreComparisonExamples.lmx](patterns/LMX_Fn_Receivers/src/coreComparisonExamples.lmx) |

### Stable ordering and distinct values

| Function / operand | Contract | LMX source |
| --- | --- | --- |
| `sort(items; compare)` | stable nonmutating generic merge sort; three-way int comparator; fresh outer array preserving source profile and element identity; empty/singleton supported; callback failure does not modify input | [corePerlExamples.lmx](patterns/LMX_Fn_Receivers/src/corePerlExamples.lmx) |
| `unique(items; same)` | stable first-occurrence uniqueness with explicit typed equality predicate; fresh outer array preserving source profile and element identity; empty/singleton supported; callback failure does not modify input | [corePerlExamples.lmx](patterns/LMX_Fn_Receivers/src/corePerlExamples.lmx) |

## Integration and acceptance

1. Preserve the existing complete graph, DATA ownership, declaration-argument behavior and ordinary interpreter/native dispatch. Do not introduce a second callable representation.
2. Bind the narrow interfaces listed in the kernel requirements to existing kernel algorithms. An algorithm body is not replaced by a new opaque primitive with the same name.
3. Include all catalog exports, operand metadata/priorities and named failures. Keep `replaceRange`, `splice` and text `replace` distinct; retain the exact existing `Name :: DATA` operand contract.
4. Run the package acceptance cases and the comparison-specific cases on interpreter/native paths. A source-consistency check is not a runtime PASS.
5. Use the [Fable merge packet](../fable_merge/README.md) to review against the exact uploaded preimages. Source changes and generated statistics are separate patches.

Regeneration: `python3 patterns/LMX_Fn_Receivers/tools/rebuild_catalog.py`, then `python3 patterns/LMX_Fn_Receivers/tools/rebuild_core_inventory.py`. The kernel exports, inventory and examples must use the same public names.
