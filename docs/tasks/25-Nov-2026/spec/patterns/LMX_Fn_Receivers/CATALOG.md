# Canonical library operations and their two forms

215 canonical names. Every input export is accounted for in [the migration inventory](CANONICAL_MIGRATION.json). Former names are not callable aliases.

Both forms use the same algorithms and real owner DATA. Complete family/role binding, adaptive capture and exact result projection are defined in [PUBLICATION_CONTRACT.md](PUBLICATION_CONTRACT.md). Runtime execution is **NOT_RUN**.

| Name | Ordinary form | Implementations and operand form |
| --- | --- | --- |
| `types` | `types(source)` | **default** [`RxTypes\types`](src/reflection.lmx) → `StandardOperands\types` (asOperand) |
| `names` | `names(source)` | **default** [`RxNames\names`](src/reflection_bridges.lmx) → `StandardOperands\names` (asOperand) |
| `signature` | `signature(operation)` | **default** [`RxSignature\signature`](src/reflection_bridges.lmx) → `StandardOperands\signature` (asOperand) |
| `->` | `` `->`(inputTypes...; resultType) `` | **default** [`` FxToTokens\`->` ``](src/fn_operand.lmx) → `` FxToOperand\`->` `` (existing-operand) |
| `curry` | `curry(operation)` | **default** [`FxLambda\lambda`](src/generic_functions.lmx) → `StandardOperands\curry` (asOperand) |
| `apply` | `apply(operation; args)` | **default** [`FxApply\apply`](src/generic_runtime.lmx) → `StandardOperands\apply` (asOperand) |
| `partial` | `partial(operation; prefix)` | **default** [`FxPartial\partial`](src/generic_functions.lmx) → `StandardOperands\partial` (asOperand) |
| `uncurry` | `uncurry(operation; contract; failures)` | **default** [`FxUncurry\uncurry`](src/generic_functions.lmx) → `FxUncurry\uncurry` (role-aware-translator) |
| `flip` | `flip(operation)` | **default** [`FxFlip\flip`](src/generic_functions.lmx) → `StandardOperands\flip` (asOperand) |
| `compose` | `compose(outer; inner)` | **default** [`FxCompose\compose`](src/generic_combinators.lmx) → `StandardOperands\compose` (asOperand) |
| `identity` | `identity(typeToken)` | **default** [`FxIdentity\identity`](src/generic_combinators.lmx) → `FxIdentity\identity` (role-aware-translator) |
| `map` | `map(items; transform)` | **default** [`FxMap\map`](src/collections.lmx) → `StandardOperands\map` (asOperand) |
| `filter` | `filter(items; accepts)` | **default** [`FxFilter\filter`](src/collections.lmx) → `StandardOperands\filter` (asOperand) |
| `foldl` | `foldl(items; seed; step)` | **default** [`FxFold\fold`](src/collections.lmx) → `StandardOperands\foldl` (asOperand) |
| `zip` | `zip(first; second)` | **default** [`FxZip\zip`](src/collections.lmx) → `StandardOperands\zip` (asOperand) |
| `zipWith` | `zipWith(first; second; combine)` | **default** [`FxZipWith\zipWith`](src/collections.lmx) → `StandardOperands\zipWith` (asOperand) |
| `scanl` | `scanl(items; seed; step)` | **default** [`FxScan\scan`](src/collections.lmx) → `StandardOperands\scanl` (asOperand) |
| `bind` | `bind(input; next)` | **Maybe** [`FxBind\bind`](src/containers.lmx) → `FxMaybeBindOperand\bind` (existing-operand); **Result** [`FxBindResult\bind`](src/containers.lmx) → `FxResultBindOperand\bind` (existing-operand); **Array** [`FxListBind\bind`](src/containers.lmx) → `ArrayBinding\bind` (existing-operand) |
| `traverse` | `traverse(items; next)` | **default** [`FxTraverse\traverse`](src/collections.lmx) → `StandardOperands\traverse` (asOperand) |
| `memoize` | `memoize(operation; sameKey=0)` | **default** [`FxMemo\memo`](src/generic_combinators.lmx) → `StandardOperands\memoize` (asOperand) |
| `fix` | `fix(operation)` | **default** [`FxFix\fix`](src/generic_combinators.lmx) → `StandardOperands\fix` (asOperand) |
| `select` | `select(source; indices)` | **default** [`RxSelect\select`](src/structures.lmx) → `StandardOperands\select` (asOperand) |
| `omit` | `omit(source; indices)` | **default** [`RxOmit\omit`](src/structures.lmx) → `StandardOperands\omit` (asOperand) |
| `rename` | `rename(source; indices; labels)` | **default** [`RxRename\rename`](src/reflection_bridges.lmx) → `StandardOperands\rename` (asOperand) |
| `reorder` | `reorder(source; permutation)` | **default** [`RxReorder\reorder`](src/structures.lmx) → `StandardOperands\reorder` (asOperand) |
| `project` | `project(source; indices)` | **default** [`RxProject\project`](src/structures.lmx) → `StandardOperands\project` (asOperand) |
| `defaults` | `defaults(source; fallback)` | **default** [`RxDefaults\defaults`](src/structures.lmx) → `StandardOperands\defaults` (asOperand) |
| `diff` | `diff(before; after)` | **default** [`RxDiff\diff`](src/structures.lmx) → `StandardOperands\diff` (asOperand) |
| `patch` | `patch(source; change)` | **default** [`RxPatch\patch`](src/structures.lmx) → `StandardOperands\patch` (asOperand) |
| `bindFields` | `bindFields(operation; bindings)` | **default** [`RxBindFields\bindFields`](src/structures.lmx) → `StandardOperands\bindFields` (asOperand) |
| `derive` | `derive(base; extension)` | **default** [`RxDerive\derive`](src/structures.lmx) → `StandardOperands\derive` (asOperand) |
| `transpose` | `transpose(rows)` | **default** [`FxTranspose\transpose`](src/collections.lmx) → `StandardOperands\transpose` (asOperand) |
| `groupBy` | `groupBy(items; keyOf=0; sameKey=0)` | **default** [`FxGroupBy\groupBy`](src/collections.lmx) → `StandardOperands\groupBy` (asOperand) |
| `lazy` | `lazy(operation)` | **default** [`FxLazy\lazy`](src/generic_wrappers.lmx) → `StandardOperands\lazy` (asOperand) |
| `force` | `force(thunk)` | **default** [`FxForce\force`](src/generic_wrappers.lmx) → `StandardOperands\force` (asOperand) |
| `once` | `once(operation)` | **default** [`FxOnce\once`](src/generic_wrappers.lmx) → `StandardOperands\once` (asOperand) |
| `repeat` | `repeat(operation; count; args=())` | **default** [`FxRepeat\repeat`](src/generic_wrappers.lmx) → `StandardOperands\repeat` (asOperand) |
| `runUntil` | `runUntil(step; finished; initial)` | **default** [`FxUntil\runUntil`](src/generic_wrappers.lmx) → `StandardOperands\runUntil` (asOperand) |
| `retryCall` | `retryCall(operation; attempts; args=())` | **default** [`FxRetry\retryCall`](src/generic_wrappers.lmx) → `StandardOperands\retryCall` (asOperand) |
| `bracket` | `bracket(acquire; release; action; arguments=())` | **default** [`FxAround\around`](src/generic_wrappers.lmx) → `StandardOperands\bracket` (asOperand) |
| `recover` | `recover(operation; handler)` | **default** [`FxRecover\recover`](src/generic_wrappers.lmx) → `StandardOperands\recover` (asOperand) |
| `adapter` | `adapter(operation; before; after; contract)` | **default** [`FxAdapter\adapter`](src/generic_combinators.lmx) → `StandardOperands\adapter` (asOperand) |
| `permute` | `permute(operation; permutation)` | **default** [`FxPermute\permute`](src/generic_combinators.lmx) → `StandardOperands\permute` (asOperand) |
| `overload` | `overload(candidates; accepts; contract)` | **default** [`FxOverload\overload`](src/generic_combinators.lmx) → `StandardOperands\overload` (asOperand) |
| `predicate` | `predicate(operation)` | **default** [`FxPredicate\predicate`](src/generic_combinators.lmx) → `StandardOperands\predicate` (asOperand) |
| `guard` | `guard(operation; accepts)` | **default** [`FxGuard\guard`](src/generic_combinators.lmx) → `StandardOperands\guard` (asOperand) |
| `trace` | `trace(operation; sink)` | **default** [`FxTrace\trace`](src/generic_wrappers.lmx) → `StandardOperands\trace` (asOperand) |
| `contract` | `contract(operation; pre; post)` | **default** [`FxContract\contract`](src/generic_combinators.lmx) → `StandardOperands\contract` (asOperand) |
| `composeData` | `composeData(code; overlay)` | **default** [`RxComposeData\composeData`](src/structures.lmx) → `StandardOperands\composeData` (asOperand) |
| `record` | `record(left; right=())` | **default** [`FxRecordOperands\record`](src/generic_functions.lmx) → `FxRecordOperands\record` (role-aware-translator) |
| `some` | `some(value)` | **default** [`FxSome\some`](src/containers.lmx) → `StandardOperands\some` (asOperand) |
| `none` | `none()` | **default** [`FxNone\none`](src/containers.lmx) → `StandardOperands\none` (asOperand) |
| `ok` | `ok(value)` | **default** [`FxOk\ok`](src/containers.lmx) → `StandardOperands\ok` (asOperand) |
| `err` | `err(reason)` | **default** [`FxErr\err`](src/containers.lmx) → `StandardOperands\err` (asOperand) |
| `list` | `list(values)` | **default** [`FxList\list`](src/containers.lmx) → `StandardOperands\list` (asOperand) |
| `done` | `done(value)` | **default** [`FxDone\done`](src/containers.lmx) → `StandardOperands\done` (asOperand) |
| `more` | `more(thunk)` | **default** [`FxMore\more`](src/containers.lmx) → `StandardOperands\more` (asOperand) |
| `trampoline` | `trampoline(current)` | **default** [`FxTrampoline\trampoline`](src/containers.lmx) → `StandardOperands\trampoline` (asOperand) |
| `range` | `range(start; stop; step=1) / range(start; stop; step; profile)` | **default** [`FxSeqRange\range`](src/sequences.lmx) → `StandardOperands\range_default` (asOperand); **profile** [`FxProfileRange\range`](src/sequence_profiles.lmx) → `StandardOperands\range_profile` (asOperand) |
| `slice` | `slice(source; begin; end)` | **default** [`FxSeqSlice\slice`](src/sequences.lmx) → `StandardOperands\slice` (asOperand) |
| `reverse` | `reverse(source)` | **default** [`FxSeqReverse\reverse`](src/sequences.lmx) → `StandardOperands\reverse` (asOperand) |
| `concat` | `concat(parts)` | **default** [`FxSeqConcat\concat`](src/sequences.lmx) → `StandardOperands\concat` (asOperand) |
| `compress` | `compress(source; mask)` | **default** [`FxSeqCompress\compress`](src/sequences.lmx) → `StandardOperands\compress` (asOperand) |
| `any` | `any(items; accepts)` | **default** [`FxSeqAny\any`](src/sequences.lmx) → `StandardOperands\any` (asOperand) |
| `all` | `all(items; accepts)` | **default** [`FxSeqAll\all`](src/sequences.lmx) → `StandardOperands\all` (asOperand) |
| `index` | `index(items; accepts)` | **default** [`FxSeqIndex\index`](src/sequences.lmx) → `StandardOperands\index` (asOperand) |
| `count` | `count(items; accepts)` | **default** [`FxSeqCount\count`](src/sequences.lmx) → `StandardOperands\count` (asOperand) |
| `replaceRange` | `replaceRange(target; begin; end; values)` | **default** [`FxSeqReplaceRange\replaceRange`](src/sequences_mutation.lmx) → `StandardOperands\replaceRange` (asOperand) |
| `splice` | `splice(target; begin; end; values)` | **default** [`FxSeqSplice\splice`](src/sequences_mutation.lmx) → `StandardOperands\splice` (asOperand) |
| `append` | `append(target; values)` | **default** [`FxSeqAppend\append`](src/sequences_mutation.lmx) → `StandardOperands\append` (asOperand) |
| `insert` | `insert(target; position; values)` | **default** [`FxSeqInsert\insert`](src/sequences_mutation.lmx) → `StandardOperands\insert` (asOperand) |
| `deleteAt` | `deleteAt(target; begin; end)` | **default** [`FxSeqDeleteAt\deleteAt`](src/sequences_mutation.lmx) → `StandardOperands\deleteAt` (asOperand) |
| `literal` | `literal(value)` | **default** [`RxLiteral\literal`](src/regex/primitives.lmx) → `StandardOperands\literal` (asOperand) |
| `oneOf` | `oneOf(values)` | **default** [`RxMembers\oneOf`](src/regex/primitives.lmx) → `StandardOperands\oneOf` (asOperand) |
| `noneOf` | `noneOf(values)` | **default** [`RxMembers\noneOf`](src/regex/primitives.lmx) → `StandardOperands\noneOf` (asOperand) |
| `within` | `within(first; last; order=0)` | **default** [`RxWithin\within`](src/regex/primitives.lmx) → `StandardOperands\within` (asOperand) |
| `satisfy` | `satisfy(predicate)` | **default** [`RxSatisfy\satisfy`](src/regex/primitives.lmx) → `StandardOperands\satisfy` (asOperand) |
| `boundaryOf` | `boundaryOf(predicate)` | **default** [`RxBoundaryOf\boundaryOf`](src/regex/primitives.lmx) → `StandardOperands\boundaryOf` (asOperand) |
| `sameAs` | `sameAs(name)` | **default** [`RxSameAs\sameAs`](src/regex/primitives.lmx) → `StandardOperands\sameAs` (asOperand) |
| `then` | `then(patterns...)` | **Pattern** [`RxSequence\then`](src/regex/combinators.lmx) → `RxThenOperand\then` (existing-operand) |
| `choice` | `choice(patterns)` | **default** [`RxChoice\choice`](src/regex/combinators.lmx) → `StandardOperands\choice` (asOperand) |
| `repeated` | `repeated(pattern; minimum=0; maximum=unbounded; order=extendFirst)` | **default** [`RxRepeated\repeated`](src/regex/combinators.lmx) → `StandardOperands\repeated` (asOperand) |
| `atomic` | `atomic(pattern)` | **default** [`RxAtomic\atomic`](src/regex/combinators.lmx) → `StandardOperands\atomic` (asOperand) |
| `capture` | `capture(name; pattern)` | **default** [`RxCapture\capture`](src/regex/combinators.lmx) → `StandardOperands\capture` (asOperand) |
| `ahead` | `ahead(pattern)` | **default** [`RxAhead\ahead`](src/regex/combinators.lmx) → `StandardOperands\ahead` (asOperand) |
| `notAhead` | `notAhead(pattern)` | **default** [`RxNotAhead\notAhead`](src/regex/combinators.lmx) → `StandardOperands\notAhead` (asOperand) |
| `behind` | `behind(pattern)` | **default** [`RxBehind\behind`](src/regex/combinators.lmx) → `StandardOperands\behind` (asOperand) |
| `notBehind` | `notBehind(pattern)` | **default** [`RxNotBehind\notBehind`](src/regex/combinators.lmx) → `StandardOperands\notBehind` (asOperand) |
| `utf8Text` | `utf8Text(source)` | **default** [`RxUtf8Text\utf8Text`](src/regex/text.lmx) → `StandardOperands\utf8Text` (asOperand) |
| `byteText` | `byteText(source)` | **default** [`RxByteText\byteText`](src/regex/text.lmx) → `StandardOperands\byteText` (asOperand) |
| `matchAt` | `matchAt(source; pattern; position)` | **default** [`RxMatchAt\matchAt`](src/regex/operations.lmx) → `StandardOperands\matchAt` (asOperand) |
| `wholeMatch` | `wholeMatch(source; pattern)` | **default** [`RxWholeMatch\wholeMatch`](src/regex/operations.lmx) → `StandardOperands\wholeMatch` (asOperand) |
| `find` | `find(source; pattern)` | **default** [`RxFind\find`](src/regex/operations.lmx) → `StandardOperands\find` (asOperand) |
| `eachMatch` | `eachMatch(source; pattern)` | **default** [`RxEachMatch\eachMatch`](src/regex/operations.lmx) → `StandardOperands\eachMatch` (asOperand) |
| `contains` | `contains(source; pattern)` | **default** [`RxContains\contains`](src/regex/operations.lmx) → `StandardOperands\contains` (asOperand) |
| `hasPrefix` | `hasPrefix(source; pattern)` | **default** [`RxHasPrefix\hasPrefix`](src/regex/operations.lmx) → `StandardOperands\hasPrefix` (asOperand) |
| `hasSuffix` | `hasSuffix(source; pattern)` | **default** [`RxHasSuffix\hasSuffix`](src/regex/operations.lmx) → `StandardOperands\hasSuffix` (asOperand) |
| `matches` | `matches(source; pattern)` | **default** [`RxMatches\matches`](src/regex/operations.lmx) → `StandardOperands\matches` (asOperand) |
| `matchedSpan` | `matchedSpan(result)` | **default** [`RxMatchedSpan\matchedSpan`](src/regex/operations.lmx) → `StandardOperands\matchedSpan` (asOperand) |
| `matchedValue` | `matchedValue(result)` | **default** [`RxMatchedValue\matchedValue`](src/regex/operations.lmx) → `StandardOperands\matchedValue` (asOperand) |
| `captureSpans` | `captureSpans(result; name)` | **default** [`RxCaptureSpans\captureSpans`](src/regex/operations.lmx) → `StandardOperands\captureSpans` (asOperand) |
| `lastCapture` | `lastCapture(result; name)` | **default** [`RxLastCapture\lastCapture`](src/regex/operations.lmx) → `StandardOperands\lastCapture` (asOperand) |
| `captureValue` | `captureValue(result; name)` | **default** [`RxCaptureValue\captureValue`](src/regex/operations.lmx) → `StandardOperands\captureValue` (asOperand) |
| `captureValues` | `captureValues(result; name)` | **default** [`RxCaptureValues\captureValues`](src/regex/operations.lmx) → `StandardOperands\captureValues` (asOperand) |
| `replaceFirst` | `replaceFirst(source; pattern; replacement)` | **default** [`RxReplaceFirst\replaceFirst`](src/regex/operations.lmx) → `RxReplaceFirst\replaceFirst` (role-aware-translator) |
| `replace` | `replace(source; pattern; replacement)` | **default** [`RxReplace\replace`](src/regex/operations.lmx) → `RxReplace\replace` (role-aware-translator) |
| `split` | `split(source; pattern)` | **default** [`RxSplit\split`](src/regex/operations.lmx) → `StandardOperands\split` (asOperand) |
| `times` | `times(left; right)` | **default** [`RxRepeatOperands\times`](src/regex/operands.lmx) → `RxRepeatOperands\times` (role-aware-translator) |
| `atLeast` | `atLeast(left; right)` | **default** [`RxRepeatOperands\atLeast`](src/regex/operands.lmx) → `RxRepeatOperands\atLeast` (role-aware-translator) |
| `atMost` | `atMost(left; right)` | **default** [`RxRepeatOperands\atMost`](src/regex/operands.lmx) → `RxRepeatOperands\atMost` (role-aware-translator) |
| `optional` | `optional(left; right)` | **default** [`RxRepeatOperands\optional`](src/regex/operands.lmx) → `RxRepeatOperands\optional` (role-aware-translator) |
| `findFirst` | `findFirst(items; accepts)` | **default** [`FxFindFirst\findFirst`](src/coreComparisonGroups.lmx) → `StandardOperands\findFirst` (asOperand) |
| `allOf` | `allOf(predicates; contract=0)` | **default** [`FxAllOf\allOf`](src/coreComparisonGroups.lmx) → `StandardOperands\allOf` (asOperand) |
| `equalFields` | `equalFields(first; second; same=0)` | **default** [`FxEqualFields\equalFields`](src/coreComparisonGroups.lmx) → `StandardOperands\equalFields` (asOperand) |
| `retryPost` | `retryPost(request; retryOn; attempts; delay; firstDelay; maxDelay; timeoutMs; complete)` | **default** [`FxRetryPost\retryPost`](src/coreComparisonGroups.lmx) → `StandardOperands\retryPost` (asOperand) |
| `between` | `between(left; right)` | **default** [`FxBetween\between`](src/coreComparisonExamples.lmx) → `FxBetween\between` (role-aware-translator) |
| `iterateUntilStop` | `iterateUntilStop(iteration; body)` | **default** [`FxIterateUntilStop\iterateUntilStop`](src/coreComparisonExamples.lmx) → `FxIterateUntilStop\iterateUntilStop` (role-aware-translator) |
| `sort` | `sort(items; compare)` | **default** [`FxSort\sort`](src/corePerlExamples.lmx) → `StandardOperands\sort` (asOperand) |
| `unique` | `unique(items; same=0)` | **default** [`FxUnique\unique`](src/corePerlExamples.lmx) → `StandardOperands\unique` (asOperand) |
| `take` | `take(items; count)` | **default** [`FxStdCut\take`](src/coreStandardFunctional.lmx) → `StandardOperands\take` (asOperand) |
| `drop` | `drop(items; count)` | **default** [`FxStdCut\drop`](src/coreStandardFunctional.lmx) → `StandardOperands\drop` (asOperand) |
| `splitAt` | `splitAt(items; count)` | **default** [`FxStdCut\splitAt`](src/coreStandardFunctional.lmx) → `StandardOperands\splitAt` (asOperand) |
| `takeWhile` | `takeWhile(items; accepts)` | **default** [`FxStdPrefix\takeWhile`](src/coreStandardFunctional.lmx) → `StandardOperands\takeWhile` (asOperand) |
| `dropWhile` | `dropWhile(items; accepts)` | **default** [`FxStdPrefix\dropWhile`](src/coreStandardFunctional.lmx) → `StandardOperands\dropWhile` (asOperand) |
| `span` | `span(items; accepts)` | **default** [`FxStdPrefix\span`](src/coreStandardFunctional.lmx) → `StandardOperands\span` (asOperand) |
| `partition` | `partition(items; accepts)` | **default** [`FxStdPartition\partition`](src/coreStandardFunctional.lmx) → `StandardOperands\partition` (asOperand) |
| `enumerate` | `enumerate(items; start=0)` | **default** [`FxStdEnumerate\enumerate`](src/coreStandardFunctional.lmx) → `StandardOperands\enumerate` (asOperand) |
| `windows` | `windows(items; width=2; step=1; partial=0)` | **default** [`FxStdWindows\windows`](src/coreStandardFunctional.lmx) → `StandardOperands\windows` (asOperand) |
| `chunks` | `chunks(items; size; strict=0)` | **default** [`FxStdChunks\chunks`](src/coreStandardFunctional.lmx) → `StandardOperands\chunks` (asOperand) |
| `intersperse` | `intersperse(items; separatorRecord)` | **default** [`FxStdIntersperse\intersperse`](src/coreStandardFunctional.lmx) → `StandardOperands\intersperse` (asOperand) |
| `join` | `join(parts; separator)` | **Array** [`FxStdJoin\join`](src/coreStandardFunctional.lmx) → `StandardOperands\join_Array` (asOperand); **text** [`FxTextJoin\join`](src/sequence_profiles.lmx) → `StandardOperands\join_text` (asOperand) |
| `unzip` | `unzip(pairs)` | **default** [`FxStdUnzip\unzip`](src/coreStandardFunctional.lmx) → `StandardOperands\unzip` (asOperand) |
| `foldr` | `foldr(items; seedRecord; step)` | **default** [`FxStdRightFold\foldr`](src/coreStandardFunctional.lmx) → `StandardOperands\foldr` (asOperand) |
| `scanr` | `scanr(items; seedRecord; step)` | **default** [`FxStdRightFold\scanr`](src/coreStandardFunctional.lmx) → `StandardOperands\scanr` (asOperand) |
| `filterMap` | `filterMap(items; transform)` | **default** [`FxStdMaybeMap\filterMap`](src/coreStandardFunctional.lmx) → `StandardOperands\filterMap` (asOperand) |
| `mapWhile` | `mapWhile(items; transform)` | **default** [`FxStdMaybeMap\mapWhile`](src/coreStandardFunctional.lmx) → `StandardOperands\mapWhile` (asOperand) |
| `findMap` | `findMap(items; transform)` | **default** [`FxStdMaybeMap\findMap`](src/coreStandardFunctional.lmx) → `StandardOperands\findMap` (asOperand) |
| `mapAccumL` | `mapAccumL(items; seedRecord; step)` | **default** [`FxStdMapAccum\mapAccumL`](src/coreStandardFunctional.lmx) → `StandardOperands\mapAccumL` (asOperand) |
| `mapAccumR` | `mapAccumR(items; seedRecord; step)` | **default** [`FxStdMapAccum\mapAccumR`](src/coreStandardFunctional.lmx) → `StandardOperands\mapAccumR` (asOperand) |
| `groupAdjacent` | `groupAdjacent(items; keyOf=0; sameKey=0)` | **default** [`FxStdGroupAdjacent\groupAdjacent`](src/coreStandardFunctional.lmx) → `StandardOperands\groupAdjacent` (asOperand) |
| `replicate` | `replicate(valueRecord; count)` | **default** [`FxStdReplicate\replicate`](src/coreStandardFunctional.lmx) → `StandardOperands\replicate` (asOperand) |
| `cycle` | `cycle(items; count; rejectNegative=0)` | **default** [`FxStdCycle\cycle`](src/coreStandardFunctional.lmx) → `StandardOperands\cycle_default` (asOperand); **text** [`FxTextCycle\cycle`](src/sequence_profiles.lmx) → `StandardOperands\cycle_text` (asOperand) |
| `starmap` | `starmap(rows; operation)` | **default** [`FxStdStarMap\starmap`](src/coreStandardFunctional.lmx) → `StandardOperands\starmap` (asOperand) |
| `zipLongest` | `zipLongest(first; second; fillRecord)` | **default** [`FxStdZipLongest\zipLongest`](src/coreStandardFunctional.lmx) → `StandardOperands\zipLongest` (asOperand) |
| `collect` | `collect(next; limit=-1)` | **default** [`FxStdCollect\collect`](src/coreStandardFunctional.lmx) → `StandardOperands\collect` (asOperand) |
| `includes` | `includes(items; valueRecord; same=0)` | **default** [`FxStdMembership\includes`](src/coreStandardFunctional.lmx) → `StandardOperands\includes` (asOperand) |
| `adjoin` | `adjoin(items; valueRecord; same=0)` | **default** [`FxStdAdjoin\adjoin`](src/coreStandardFunctional.lmx) → `StandardOperands\adjoin` (asOperand) |
| `union` | `union(first; second; same=0)` | **default** [`FxStdSets\union`](src/coreStandardFunctional.lmx) → `StandardOperands\union` (asOperand) |
| `intersection` | `intersection(first; second; same=0)` | **default** [`FxStdSets\intersection`](src/coreStandardFunctional.lmx) → `StandardOperands\intersection` (asOperand) |
| `difference` | `difference(first; second; same=0)` | **default** [`FxStdSets\difference`](src/coreStandardFunctional.lmx) → `StandardOperands\difference` (asOperand) |
| `symmetricDifference` | `symmetricDifference(first; second; same=0)` | **default** [`FxStdSets\symmetricDifference`](src/coreStandardFunctional.lmx) → `StandardOperands\symmetricDifference` (asOperand) |
| `isSubset` | `isSubset(first; second; same=0)` | **default** [`FxStdSubset\isSubset`](src/coreStandardFunctional.lmx) → `StandardOperands\isSubset` (asOperand) |
| `mapOption` | `mapOption(input; transform)` | **default** [`FxMapOption\mapOption`](src/coreStandardObjects.lmx) → `StandardOperands\mapOption` (asOperand) |
| `filterOption` | `filterOption(input; accepts)` | **default** [`FxFilterOption\filterOption`](src/coreStandardObjects.lmx) → `StandardOperands\filterOption` (asOperand) |
| `orElse` | `orElse(input; fallback)` | **default** [`FxOrElse\orElse`](src/coreStandardObjects.lmx) → `StandardOperands\orElse` (asOperand) |
| `orElseGet` | `orElseGet(input; fallback)` | **default** [`FxOrElseGet\orElseGet`](src/coreStandardObjects.lmx) → `StandardOperands\orElseGet` (asOperand) |
| `orElseOption` | `orElseOption(input; fallback)` | **default** [`FxOrElseOption\orElseOption`](src/coreStandardObjects.lmx) → `StandardOperands\orElseOption` (asOperand) |
| `foldOption` | `foldOption(input; whenEmpty; whenPresent)` | **default** [`FxFoldOption\foldOption`](src/coreStandardObjects.lmx) → `StandardOperands\foldOption` (asOperand) |
| `flattenOption` | `flattenOption(input)` | **default** [`FxFlattenOption\flattenOption`](src/coreStandardObjects.lmx) → `StandardOperands\flattenOption` (asOperand) |
| `mapResult` | `mapResult(input; transform)` | **default** [`FxMapResult\mapResult`](src/coreStandardObjects.lmx) → `StandardOperands\mapResult` (asOperand) |
| `mapErr` | `mapErr(input; transform)` | **default** [`FxMapErr\mapErr`](src/coreStandardObjects.lmx) → `StandardOperands\mapErr` (asOperand) |
| `orElseResult` | `orElseResult(input; fallback)` | **default** [`FxOrElseResult\orElseResult`](src/coreStandardObjects.lmx) → `StandardOperands\orElseResult` (asOperand) |
| `foldResult` | `foldResult(input; onError; onSuccess)` | **default** [`FxFoldResult\foldResult`](src/coreStandardObjects.lmx) → `StandardOperands\foldResult` (asOperand) |
| `attempt` | `attempt(operation; args=())` | **default** [`FxAttemptResult\attempt`](src/coreStandardObjects.lmx) → `StandardOperands\attempt` (asOperand) |
| `tap` | `tap(value; action)` | **default** [`FxTap\tap`](src/coreStandardObjects.lmx) → `StandardOperands\tap` (asOperand) |
| `findField` | `findField(source; label; occurrence)` | **default** [`FxFindField\findField`](src/coreStandardObjects.lmx) → `StandardOperands\findField` (asOperand) |
| `hasField` | `hasField(source; label; occurrence)` | **default** [`FxHasField\hasField`](src/coreStandardObjects.lmx) → `StandardOperands\hasField` (asOperand) |
| `getField` | `getField(source; label; occurrence)` | **default** [`FxGetField\getField`](src/coreStandardObjects.lmx) → `StandardOperands\getField` (asOperand) |
| `assoc` | `assoc(rows; key; same=0; keyIndex=0)` | **default** [`FxAssoc\assoc`](src/coreStandardLisp.lmx) → `StandardOperands\assoc` (asOperand) |
| `pairlis` | `pairlis(keys; values; tail=())` | **default** [`FxPairlis\pairlis`](src/coreStandardLisp.lmx) → `StandardOperands\pairlis` (asOperand) |
| `getProperty` | `getProperty(properties; key; same=0)` | **default** [`FxGetProperty\getProperty`](src/coreStandardLisp.lmx) → `StandardOperands\getProperty` (asOperand) |
| `setProperty` | `setProperty(properties; key; value; same=0)` | **default** [`FxSetProperty\setProperty`](src/coreStandardLisp.lmx) → `StandardOperands\setProperty` (asOperand) |
| `removeProperty` | `removeProperty(properties; key; same=0)` | **default** [`FxRemoveProperty\removeProperty`](src/coreStandardLisp.lmx) → `StandardOperands\removeProperty` (asOperand) |
| `getProperties` | `getProperties(properties; indicators; same=0)` | **default** [`FxGetProperties\getProperties`](src/coreStandardLisp.lmx) → `StandardOperands\getProperties` (asOperand) |
| `asOperand` | `asOperand(operation; priority)` | **default** [`FxAsOperand\asOperand`](src/coreStandardLisp.lmx) → `StandardOperands\asOperand` (asOperand) |
| `mismatch` | `mismatch(first; second; same=0)` | **default** [`FxMismatch\mismatch`](src/coreStandardLisp.lmx) → `StandardOperands\mismatch` (asOperand) |
| `searchSequence` | `searchSequence(items; pattern; same=0; start=0)` | **default** [`FxSearchSequence\searchSequence`](src/coreStandardLisp.lmx) → `StandardOperands\searchSequence` (asOperand) |
| `substitute` | `substitute(items; oldValue; newValue; same=0)` | **default** [`FxSubstitute\substitute`](src/coreStandardLisp.lmx) → `StandardOperands\substitute` (asOperand) |
| `indexOf` | `indexOf(text; part; start=0; same=0)` | **default** [`FxIndexOf\indexOf`](src/coreStandardText.lmx) → `StandardOperands\indexOf` (asOperand) |
| `lastIndexOf` | `lastIndexOf(text; part; start=length(text); same=0)` | **default** [`FxLastIndexOf\lastIndexOf`](src/coreStandardText.lmx) → `StandardOperands\lastIndexOf` (asOperand) |
| `compare` | `compare(first; second; order=0)` | **default** [`FxCompare\compare`](src/coreStandardText.lmx) → `StandardOperands\compare` (asOperand) |
| `trim` | `trim(text; chars; predicate=0; same=0) / text profile supplies whitespace` | **default** [`FxTrim\trim`](src/coreStandardText.lmx) → `StandardOperands\trim_default` (asOperand); **text** [`FxTextTrim\trim`](src/sequence_profiles.lmx) → `StandardOperands\trim_text` (asOperand) |
| `trimStart` | `trimStart(text; chars; predicate=0; same=0) / text profile supplies whitespace` | **default** [`FxTrimStart\trim`](src/coreStandardText.lmx) → `StandardOperands\trimStart_default` (asOperand); **text** [`FxTextTrim\trimStart`](src/sequence_profiles.lmx) → `StandardOperands\trimStart_text` (asOperand) |
| `trimEnd` | `trimEnd(text; chars; predicate=0; same=0) / text profile supplies whitespace` | **default** [`FxTrimEnd\trim`](src/coreStandardText.lmx) → `StandardOperands\trimEnd_default` (asOperand); **text** [`FxTextTrim\trimEnd`](src/sequence_profiles.lmx) → `StandardOperands\trimEnd_text` (asOperand) |
| `padLeft` | `padLeft(text; width; fill) / text profile supplies space` | **default** [`FxPadLeft\pad`](src/coreStandardText.lmx) → `StandardOperands\padLeft_default` (asOperand); **text** [`FxTextPad\padLeft`](src/sequence_profiles.lmx) → `StandardOperands\padLeft_text` (asOperand) |
| `padRight` | `padRight(text; width; fill) / text profile supplies space` | **default** [`FxPadRight\pad`](src/coreStandardText.lmx) → `StandardOperands\padRight_default` (asOperand); **text** [`FxTextPad\padRight`](src/sequence_profiles.lmx) → `StandardOperands\padRight_text` (asOperand) |
| `translate` | `translate(text; from; to; same=0)` | **default** [`FxTranslate\translate`](src/coreStandardText.lmx) → `StandardOperands\translate` (asOperand) |
| `format` | `format(value; base=10) / format(value; profile; arguments=())` | **default** [`FxFormat\format`](src/coreStandardText.lmx) → `StandardOperands\format_default` (asOperand); **profile** [`FxProfileFormat\format`](src/sequence_profiles.lmx) → `StandardOperands\format_profile` (asOperand) |
| `parse` | `parse(text; base=10) / parse(source; profile; arguments=())` | **default** [`FxParse\parse`](src/coreStandardText.lmx) → `StandardOperands\parse_default` (asOperand); **profile** [`FxProfileParse\parse`](src/sequence_profiles.lmx) → `StandardOperands\parse_profile` (asOperand) |
| `removePrefix` | `removePrefix(text; affix; same=0)` | **default** [`FxRemovePrefix\remove`](src/coreStandardText.lmx) → `StandardOperands\removePrefix` (asOperand) |
| `removeSuffix` | `removeSuffix(text; affix; same=0)` | **default** [`FxRemoveSuffix\remove`](src/coreStandardText.lmx) → `StandardOperands\removeSuffix` (asOperand) |
| `sum` | `sum(items; initial=(0 record))` | **default** [`FxSum\sum`](src/coreStandardNumeric.lmx) → `StandardOperands\sum` (asOperand) |
| `product` | `product(items; initial=(1 record))` | **default** [`FxProduct\product`](src/coreStandardNumeric.lmx) → `StandardOperands\product` (asOperand) |
| `minimum` | `minimum(items)` | **default** [`FxMinimum\minimum`](src/coreStandardNumeric.lmx) → `StandardOperands\minimum` (asOperand) |
| `maximum` | `maximum(items)` | **default** [`FxMaximum\maximum`](src/coreStandardNumeric.lmx) → `StandardOperands\maximum` (asOperand) |
| `argMin` | `argMin(items)` | **default** [`FxArgMin\argMin`](src/coreStandardNumeric.lmx) → `StandardOperands\argMin` (asOperand) |
| `argMax` | `argMax(items)` | **default** [`FxArgMax\argMax`](src/coreStandardNumeric.lmx) → `StandardOperands\argMax` (asOperand) |
| `extrema` | `extrema(items)` | **default** [`FxExtrema\extrema`](src/coreStandardNumeric.lmx) → `StandardOperands\extrema` (asOperand) |
| `min` | `min(first; second)` | **default** [`FxMin\min`](src/coreStandardNumeric.lmx) → `StandardOperands\min` (asOperand) |
| `max` | `max(first; second)` | **default** [`FxMax\max`](src/coreStandardNumeric.lmx) → `StandardOperands\max` (asOperand) |
| `minMax` | `minMax(first; second)` | **default** [`FxMinMax\minMax`](src/coreStandardNumeric.lmx) → `StandardOperands\minMax` (asOperand) |
| `clamp` | `clamp(value; lower; upper)` | **default** [`FxClamp\clamp`](src/coreStandardNumeric.lmx) → `StandardOperands\clamp` (asOperand) |
| `sign` | `sign(value)` | **default** [`FxSign\sign`](src/coreStandardNumeric.lmx) → `StandardOperands\sign` (asOperand) |
| `gcd` | `gcd(first; second)` | **default** [`FxGcd\gcd`](src/coreStandardNumeric.lmx) → `StandardOperands\gcd` (asOperand) |
| `lcm` | `lcm(first; second)` | **default** [`FxLcm\lcm`](src/coreStandardNumeric.lmx) → `StandardOperands\lcm` (asOperand) |
| `divMod` | `divMod(dividend; divisor)` | **default** [`FxDivMod\divMod`](src/coreStandardNumeric.lmx) → `StandardOperands\divMod` (asOperand) |
| `type` | `type(value)` | **default** [`FxValueType\type`](src/operation_forms.lmx) → `FxTypeOperand\type` (existing-operand) |
| `arrayView` | `arrayView(items)` | **default** [`RxArrayView\arrayView`](src/regex/source.lmx) → `StandardOperands\arrayView` (asOperand) |
| `element` | `element(value)` | **default** [`RxElement\element`](src/regex/primitives.lmx) → `StandardOperands\element` (asOperand) |
| `equals` | `equals(first; second; projection=0; same=0)` | **default** [`FxEquals\equals`](src/coreGenericOperations.lmx) → `StandardOperands\equals` (asOperand) |
| `pipe` | `pipe(value; stages)` | **default** [`FxPipe\pipe`](src/coreGenericOperations.lmx) → `FxPipeBuild\make` (adaptive-exact-operand) |
| `retry` | `retry(operation; retryOn; limit; delay=0; arguments=())` | **default** [`FxRetryValue\retry`](src/coreGenericOperations.lmx) → `FxRetryBuild\make` (adaptive-exact-operand) |
| `fill` | `fill(target; valueRecord)` | **default** [`FxArrayFill\fill`](src/fill.lmx) → `StandardOperands\fill` (asOperand) |
| `lowerBound` | `lowerBound(items; needleRecord; less)` | **default** [`FxLowerBound\lowerBound`](src/lowerBound.lmx) → `StandardOperands\lowerBound` (asOperand) |
| `last` | `last(items; count)` | **default** [`FxSeqLast\last`](src/last.lmx) → `StandardOperands\last` (asOperand) |

## Roles, results and failures

- **types** — physical field type codes; int[] by language contract. Roles: DECLARED_INPUT_ROLES.
- **names** — physical canonical names; anonymous entries retain typed absence. Roles: DECLARED_INPUT_ROLES.
- **signature** — ordinary positional signature description. Roles: DECLARED_INPUT_ROLES.
- **->** — ordered TYPE tokens, result last; one result TYPE constructs a nullary signature. Roles: TYPE....
- **curry** — arbitrary finite arity, exact stage input type and terminal result. Roles: CALLABLE.
- **apply** — arbitrary actual record vector; result record including explicit void. Roles: DECLARED_INPUT_ROLES.
- **partial** — prefix 0..N; exact residual signature, complete prefix yields thunk. Roles: CALLABLE, ACTUAL_RECORDS.
- **uncurry** — explicit full target contract and stage failures, callable result preserved. Roles: CALLABLE, TYPE, FAILURE_NAMES.
- **flip** — swap first two positions of N>=2 with full input types. Roles: DECLARED_INPUT_ROLES.
- **compose** — inner arbitrary arity; outer consumes its one result; exact final R. Roles: DECLARED_INPUT_ROLES.
- **identity** — typed T -> T for any valid value type. Roles: TYPE.
- **map** — universal sequence, ordinary callback admission/defaults, result reference vector. Roles: DECLARED_INPUT_ROLES.
- **filter** — universal sequence; stable storage-preserving selection and int predicate. Roles: DECLARED_INPUT_ROLES.
- **foldl** — left fold over any accumulator/item/result records. Roles: DECLARED_INPUT_ROLES.
- **zip** — pairs of typed records, min length. Roles: DECLARED_INPUT_ROLES.
- **zipWith** — arbitrary binary callback types, result records. Roles: DECLARED_INPUT_ROLES.
- **scanl** — seeded scan, n+1 records; accumulator type not hardwired. Roles: DECLARED_INPUT_ROLES.
- **bind** — Maybe of any typed record; next gets actual payload value. Roles: FAMILY_VALUE, CALLABLE.
- **traverse** — Maybe of direct Structure record vector; stop at first absence. Roles: DECLARED_INPUT_ROLES.
- **memoize** — Memoize accepted snapshots using shared ordinary/deep Array equality or an explicit comparator. Roles: DECLARED_INPUT_ROLES.
- **fix** — F(self;T0..Tn)->R becomes T0..Tn->R. Roles: DECLARED_INPUT_ROLES.
- **select** — actual-type selection preserving dense/reference profile. Roles: DECLARED_INPUT_ROLES.
- **omit** — actual-type omissions preserving dense/reference profile. Roles: DECLARED_INPUT_ROLES.
- **rename** — one graph copy then canonical field names updated. Roles: DECLARED_INPUT_ROLES.
- **reorder** — full checked permutation, any field value types. Roles: DECLARED_INPUT_ROLES.
- **project** — one shared graph copy of selected fields. Roles: DECLARED_INPUT_ROLES.
- **defaults** — merge(fallback; source), existing presence including uninit wins. Roles: DECLARED_INPUT_ROLES.
- **diff** — identity-vector patch, not deep payload equality. Roles: DECLARED_INPUT_ROLES.
- **patch** — prevalidated identity-vector patch in fresh container. Roles: DECLARED_INPUT_ROLES.
- **bindFields** — DATA defaults through merge; residual input positions not removed. Roles: DECLARED_INPUT_ROLES.
- **derive** — ordinary merge composition. Roles: DECLARED_INPUT_ROLES.
- **transpose** — rectangular Structure of row values; no fixed dimensions. Roles: DECLARED_INPUT_ROLES.
- **groupBy** — stable grouping; optional identity projection and shared equality, each key computed once. Roles: DECLARED_INPUT_ROLES.
- **lazy** — typed nullary thunk, first successful result cached. Roles: DECLARED_INPUT_ROLES.
- **force** — nullary call returning typed result record; direct thunk() keeps R. Roles: DECLARED_INPUT_ROLES.
- **once** — any arity/R; first success reused, failure permits retry. Roles: DECLARED_INPUT_ROLES.
- **repeat** — count calls with arbitrary typed actual vector; result records. Roles: DECLARED_INPUT_ROLES.
- **runUntil** — record state; step then predicate, no fixed payload type. Roles: DECLARED_INPUT_ROLES.
- **retryCall** — finite attempts, declared failures retained in FxCallFailure envelope. Roles: DECLARED_INPUT_ROLES.
- **bracket** — any resource/result; finally release; arbitrary extra action inputs. Roles: CALLABLE, CALLABLE, CALLABLE, ACTUALS?.
- **recover** — exact signature; handler(name,payload,actualVector) -> R. Roles: DECLARED_INPUT_ROLES.
- **adapter** — arbitrary external/internal arity, explicit new exact contract. Roles: DECLARED_INPUT_ROLES.
- **permute** — arbitrary N, reorder interface and actuals together. Roles: DECLARED_INPUT_ROLES.
- **overload** — explicit pure predicates, exactly one branch, full external signature. Roles: DECLARED_INPUT_ROLES.
- **predicate** — same arbitrary inputs; normalize ordinary int Boolean output. Roles: DECLARED_INPUT_ROLES.
- **guard** — same exact signature with precondition over all actuals. Roles: DECLARED_INPUT_ROLES.
- **trace** — arbitrary signature, events retain typed args/result/void distinction. Roles: DECLARED_INPUT_ROLES.
- **contract** — same signature, pre(args), post(args,result) or post(args) for void. Roles: DECLARED_INPUT_ROLES.
- **composeData** — merge actual parent DATA with explicit data overlay. Roles: DECLARED_INPUT_ROLES.
- **record** — prepared postfix capture; pointer to typed record, no value dereference. Roles: VALUE_WHOLE.
- **some** — Maybe present with any typed value record, including null. Roles: VALUE_WHOLE.
- **none** — Maybe absence, distinct from present empty/null value. Roles: DECLARED_INPUT_ROLES.
- **ok** — Result success carrying any typed value record. Roles: VALUE_WHOLE.
- **err** — Result failure carrying any typed reason record. Roles: VALUE_WHOLE.
- **list** — universal sequence input, shallow copied reference vector. Roles: DECLARED_INPUT_ROLES.
- **done** — terminal Bounce with result record. Roles: VALUE_WHOLE.
- **more** — suspended nullary callable, arbitrary captures via partial. Roles: DECLARED_INPUT_ROLES.
- **trampoline** — iterate Bounce until done, never execute callable final result. Roles: DECLARED_INPUT_ROLES.
- **range** — dense int range, stop excluded, checked extent. Roles: DECLARED_INPUT_ROLES.
- **slice** — validated half-open selection preserving actual storage profile. Roles: DECLARED_INPUT_ROLES.
- **reverse** — new reverse container, reference targets retained. Roles: DECLARED_INPUT_ROLES.
- **concat** — one-level concatenation; same dense T or ordinary reference array. Roles: DECLARED_INPUT_ROLES.
- **compress** — same-length int truth mask; stable profile-preserving selection. Roles: DECLARED_INPUT_ROLES.
- **any** — ordered predicate calls, stop at first true. Roles: DECLARED_INPUT_ROLES.
- **all** — ordered predicate calls, stop at first false. Roles: DECLARED_INPUT_ROLES.
- **index** — Maybe of first int index, none when absent. Roles: DECLARED_INPUT_ROLES.
- **count** — count accepted items in source order. Roles: DECLARED_INPUT_ROLES.
- **replaceRange** — preflight then overlap-safe replacement, same target descriptor. Roles: DECLARED_INPUT_ROLES.
- **splice** — same replacement; return a fresh shallow snapshot of removed elements, preserving dense/reference profile. Roles: DECLARED_INPUT_ROLES.
- **append** — same target, source values fixed before writes. Roles: DECLARED_INPUT_ROLES.
- **insert** — replaceRange at one position. Roles: DECLARED_INPUT_ROLES.
- **deleteAt** — replaceRange with no inserted values. Roles: DECLARED_INPUT_ROLES.
- **literal** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md. Roles: VALUE_WHOLE_SEQUENCE.
- **oneOf** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md. Roles: VALUE_WHOLE_SEQUENCE.
- **noneOf** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md. Roles: VALUE_WHOLE_SEQUENCE.
- **within** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md. Roles: VALUE_WHOLE, VALUE_WHOLE, CALLABLE?.
- **satisfy** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md. Roles: DECLARED_INPUT_ROLES.
- **boundaryOf** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md. Roles: DECLARED_INPUT_ROLES.
- **sameAs** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md. Roles: DECLARED_INPUT_ROLES.
- **then** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md. Roles: PATTERN_OR_LITERAL....
- **choice** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md. Roles: DECLARED_INPUT_ROLES.
- **repeated** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md. Roles: DECLARED_INPUT_ROLES.
- **atomic** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md. Roles: DECLARED_INPUT_ROLES.
- **capture** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md. Roles: DECLARED_INPUT_ROLES.
- **ahead** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md. Roles: DECLARED_INPUT_ROLES.
- **notAhead** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md. Roles: DECLARED_INPUT_ROLES.
- **behind** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md. Roles: DECLARED_INPUT_ROLES.
- **notBehind** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md. Roles: DECLARED_INPUT_ROLES.
- **utf8Text** — ordinary text-pattern text_profile; see REGEX_IMPLEMENTATION.md. Roles: DECLARED_INPUT_ROLES.
- **byteText** — ordinary text-pattern text_profile; see REGEX_IMPLEMENTATION.md. Roles: DECLARED_INPUT_ROLES.
- **matchAt** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md. Roles: DECLARED_INPUT_ROLES.
- **wholeMatch** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md. Roles: DECLARED_INPUT_ROLES.
- **find** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md. Roles: DECLARED_INPUT_ROLES.
- **eachMatch** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md. Roles: DECLARED_INPUT_ROLES.
- **contains** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md. Roles: DECLARED_INPUT_ROLES.
- **hasPrefix** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md. Roles: DECLARED_INPUT_ROLES.
- **hasSuffix** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md. Roles: DECLARED_INPUT_ROLES.
- **matches** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md. Roles: DECLARED_INPUT_ROLES.
- **matchedSpan** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md. Roles: DECLARED_INPUT_ROLES.
- **matchedValue** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md. Roles: DECLARED_INPUT_ROLES.
- **captureSpans** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md. Roles: DECLARED_INPUT_ROLES.
- **lastCapture** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md. Roles: DECLARED_INPUT_ROLES.
- **captureValue** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md. Roles: DECLARED_INPUT_ROLES.
- **captureValues** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md. Roles: DECLARED_INPUT_ROLES.
- **replaceFirst** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md. Roles: SOURCE_VIEW, PATTERN_OR_LITERAL, REPLACEMENT_ROLE.
- **replace** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md. Roles: SOURCE_VIEW, PATTERN_OR_LITERAL, REPLACEMENT_ROLE.
- **split** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md. Roles: DECLARED_INPUT_ROLES.
- **times** — ordinary Pattern operand with common left/right ABI. Roles: DECLARED_INPUT_ROLES.
- **atLeast** — ordinary Pattern operand with common left/right ABI. Roles: DECLARED_INPUT_ROLES.
- **atMost** — ordinary Pattern operand with common left/right ABI. Roles: DECLARED_INPUT_ROLES.
- **optional** — ordinary Pattern operand with common left/right ABI. Roles: DECLARED_INPUT_ROLES.
- **findFirst** — first accepted typed element as some(record), none for absence; ordered short-circuit over dense Arrays and Structures. Roles: DECLARED_INPUT_ROLES.
- **allOf** — arbitrary finite predicate composition with a shared ordered signature, preserved input places and short-circuit; empty set requires an explicit contract. Roles: DECLARED_INPUT_ROLES.
- **equalFields** — ordered recursive equality through one shared range comparison; optional whole-element comparator. Roles: DECLARED_INPUT_ROLES.
- **retryPost** — Message-owned bounded retry with saturated backoff, transport timeout and policy cancellation; persistent terminal result and late-reply draining. Roles: DECLARED_INPUT_ROLES.
- **between** — prepared operand for inclusive ordered bounds; exactly two right values, ordinary actual comparison types and the priority of <=. Roles: DECLARED_INPUT_ROLES.
- **iterateUntilStop** — execute accepted declaration DATA and associated body in their receiving activation; source Stop terminates, other declared exits retain name/payload in FxCallFailure; requires AE01. Roles: RAW_ITERATION, RAW_BODY.
- **sort** — stable nonmutating generic merge sort; three-way int comparator; fresh outer array preserving source profile and element identity; empty/singleton supported; callback failure does not modify input. Roles: DECLARED_INPUT_ROLES.
- **unique** — stable storage-preserving distinct values; optional shared equality; finite acyclic sequence recursion. Roles: DECLARED_INPUT_ROLES.
- **take** — Fresh prefix; count is clamped to 0..length.. Roles: DECLARED_INPUT_ROLES.
- **drop** — Fresh suffix after a clamped count.. Roles: DECLARED_INPUT_ROLES.
- **splitAt** — Both slices use one clamped cut; source remains unchanged.. Roles: DECLARED_INPUT_ROLES.
- **takeWhile** — Longest true prefix; predicate runs once per visited item, including first rejection.. Roles: DECLARED_INPUT_ROLES.
- **dropWhile** — Suffix begins with first rejected item; no later predicates are evaluated.. Roles: DECLARED_INPUT_ROLES.
- **span** — One prefix scan supplies both parts, without reevaluating an effectful predicate.. Roles: DECLARED_INPUT_ROLES.
- **partition** — Stable two-way partition with exactly one predicate call per item.. Roles: DECLARED_INPUT_ROLES.
- **enumerate** — Indices are admitted to the current int type from exact arithmetic; no wrapping index is accepted.. Roles: DECLARED_INPUT_ROLES.
- **windows** — Positive width/step; full windows by default. partial permits one last nonempty short window. No suffix after a window reaches the end.. Roles: DECLARED_INPUT_ROLES.
- **chunks** — Nonoverlapping chunks, final short chunk permitted unless strict; invalid size fails before iteration.. Roles: DECLARED_INPUT_ROLES.
- **intersperse** — Insert an admitted separator between items; empty and singleton inputs do not admit an unused separator.. Roles: DECLARED_INPUT_ROLES.
- **join** — Separate sequence parts and concatenate; empty parts returns a fresh empty sequence of separator profile.. Roles: DECLARED_INPUT_ROLES.
- **unzip** — Reverse the existing zip FxPair protocol; empty input returns two fresh empty record Arrays.. Roles: DECLARED_INPUT_ROLES.
- **foldr** — Strict finite right fold; step(item,accumulator), right-to-left callback order.. Roles: DECLARED_INPUT_ROLES.
- **scanr** — Right scan includes the seed at the final position; right-to-left callbacks.. Roles: DECLARED_INPUT_ROLES.
- **filterMap** — Map to Maybe and keep present values, preserving zero/empty/reference values.. Roles: DECLARED_INPUT_ROLES.
- **mapWhile** — Map to Maybe; stop at first none, without calling later items.. Roles: DECLARED_INPUT_ROLES.
- **findMap** — Return the first present callback result; return none when all are absent.. Roles: DECLARED_INPUT_ROLES.
- **mapAccumL** — step(state,item) returns FxPair(next state,output); callbacks left-to-right.. Roles: DECLARED_INPUT_ROLES.
- **mapAccumR** — Same stateful transform, callbacks right-to-left, outputs at original positions.. Roles: DECLARED_INPUT_ROLES.
- **groupAdjacent** — stable grouping; optional identity projection and shared equality, each key computed once. Roles: DECLARED_INPUT_ROLES.
- **replicate** — Finite copies of one ready value record; negative count gives empty; reference values retain one target.. Roles: DECLARED_INPUT_ROLES.
- **cycle** — Required finite repetition count; nonpositive count gives empty; preflight result size.. Roles: DECLARED_INPUT_ROLES.
- **starmap** — Each ready row becomes one actual vector; one typed callback result per row. No source graph field is executed while reading it.. Roles: DECLARED_INPUT_ROLES.
- **zipLongest** — Two sequences padded to the longer length with the explicit complete fill value record.. Roles: DECLARED_INPUT_ROLES.
- **collect** — Nullary producer through the existing call bridge until its Stop(), or finite limit; other declared failures retain their name and payload inside FxCallFailure.. Roles: DECLARED_INPUT_ROLES.
- **includes** — Ordered short-circuit membership with explicit typed equality; no conflict with regex contains.. Roles: DECLARED_INPUT_ROLES.
- **adjoin** — Return original source if already present; otherwise return a fresh same-profile Array with the new value prepended.. Roles: DECLARED_INPUT_ROLES.
- **union** — Unique first occurrences from first then second; pure equivalence relation required.. Roles: DECLARED_INPUT_ROLES.
- **intersection** — Unique first-source values present in second, preserving first-source order.. Roles: DECLARED_INPUT_ROLES.
- **difference** — Unique first-source values absent from second; set difference, not Haskell list multiset subtraction.. Roles: DECLARED_INPUT_ROLES.
- **symmetricDifference** — First-only values then second-only values, each once; use existing difference and concat.. Roles: DECLARED_INPUT_ROLES.
- **isSubset** — Every equivalence class from first appears in second; multiplicity is ignored.. Roles: DECLARED_INPUT_ROLES.
- **mapOption** — Map one present payload to a new Maybe; absent input skips transform; Some(null) stays present.. Roles: DECLARED_INPUT_ROLES.
- **filterOption** — Retain the same present container when an int predicate accepts its payload; absent or rejected input yields absence.. Roles: DECLARED_INPUT_ROLES.
- **orElse** — Return the existing payload record or an already evaluated fallback record; result is not a Maybe.. Roles: DECLARED_INPUT_ROLES.
- **orElseGet** — Return the payload record; invoke a nullary fallback only when absent.. Roles: DECLARED_INPUT_ROLES.
- **orElseOption** — Return the original present Maybe, or call the nullary fallback once and return its Maybe unchanged.. Roles: DECLARED_INPUT_ROLES.
- **foldOption** — Invoke exactly one branch, a nullary absent branch or unary payload branch; return its typed result record.. Roles: DECLARED_INPUT_ROLES.
- **flattenOption** — Flatten one Maybe-of-Maybe level, retaining the nested container identity; absent outer input skips payload access.. Roles: DECLARED_INPUT_ROLES.
- **mapResult** — Map only success payload into a fresh ok result; retain the existing error container without invoking transform.. Roles: DECLARED_INPUT_ROLES.
- **mapErr** — Map only error payload into a fresh err result; retain the existing success container without invoking transform.. Roles: DECLARED_INPUT_ROLES.
- **orElseResult** — Invoke one error-to-Result continuation only on err; return its Result without nesting; success identity retained.. Roles: DECLARED_INPUT_ROLES.
- **foldResult** — Invoke exactly one unary branch with the corresponding typed payload; return its result record.. Roles: DECLARED_INPUT_ROLES.
- **attempt** — Invoke through existing FxTry; return ok(result record) or err(typed reference record to full original FxOutcome); kernel/admission failures propagate.. Roles: DECLARED_INPUT_ROLES.
- **tap** — Call one effect with the actual typed payload and return the exact original value record; no deep copying or swallowing failure.. Roles: DECLARED_INPUT_ROLES.
- **findField** — Maybe of the selected physical field record; required zero-based occurrence counts equal ready names only; no payload evaluation.. Roles: DECLARED_INPUT_ROLES.
- **hasField** — Whether that physical named occurrence exists; named uninitialized payloads count as present; no payload evaluation.. Roles: DECLARED_INPUT_ROLES.
- **getField** — Return the existing selected field record; missing or negative occurrence raises FxIndex; no payload evaluation.. Roles: DECLARED_INPUT_ROLES.
- **assoc** — First matching row as Maybe; keyIndex=1 covers reverse association with the same search; empty rows skipped.. Roles: DECLARED_INPUT_ROLES.
- **pairlis** — Fresh forward-ordered key/value rows then shallow tail rows; equal lengths required.. Roles: DECLARED_INPUT_ROLES.
- **getProperty** — Maybe of the first matching flat property value; present zero/null differs from absent.. Roles: DECLARED_INPUT_ROLES.
- **setProperty** — Update first matching value, otherwise append a key/value pair; return same target Array.. Roles: DECLARED_INPUT_ROLES.
- **removeProperty** — Remove first matching key/value pair; return int 1 if found, otherwise 0.. Roles: DECLARED_INPUT_ROLES.
- **getProperties** — First property whose key matches any indicator; Maybe of key/value/index; Array index is explicit, not a Lisp cons tail.. Roles: DECLARED_INPUT_ROLES.
- **asOperand** — Construct one ordinary OPERANDS_TEMPLATE-compatible prepared operand; present left then right actuals, exact source R/void and named failures. No new syntax mode.. Roles: DECLARED_INPUT_ROLES.
- **mismatch** — Maybe of first differing index, or shared-prefix length when only lengths differ; no difference yields none.. Roles: DECLARED_INPUT_ROLES.
- **searchSequence** — Maybe of first full subsequence start at or after start; empty pattern matches start; explicit equality.. Roles: DECLARED_INPUT_ROLES.
- **substitute** — Fresh same-profile Array, replacing every equivalent element; source unchanged and referenced targets shared.. Roles: DECLARED_INPUT_ROLES.
- **indexOf** — First literal byte-substring index at or after clamped start; -1 absent. Empty part matches the chosen valid boundary.. Roles: DECLARED_INPUT_ROLES.
- **lastIndexOf** — Last literal byte-substring index at or before clamped start; overlapping candidates are tested, -1 absent.. Roles: DECLARED_INPUT_ROLES.
- **compare** — Unsigned-octet lexicographic order -1/0/1; exact case-sensitive content, length breaks an equal-prefix tie.. Roles: DECLARED_INPUT_ROLES.
- **trim** — Fresh byte slice after removing any chosen boundary characters on both sides; default is six ASCII whitespace characters.. Roles: DECLARED_INPUT_ROLES.
- **trimStart** — The same shared trim algorithm at the start only.. Roles: DECLARED_INPUT_ROLES.
- **trimEnd** — The same shared trim algorithm at the end only.. Roles: DECLARED_INPUT_ROLES.
- **padLeft** — Fresh byte string of at least width units; repeat then truncate fill at the left, preserve text when already long enough.. Roles: DECLARED_INPUT_ROLES.
- **padRight** — The same shared padding algorithm with padding on the right.. Roles: DECLARED_INPUT_ROLES.
- **translate** — Simultaneous literal byte substitution, equal-size alphabets, first duplicate source entry wins, unknown bytes retained.. Roles: DECLARED_INPUT_ROLES.
- **format** — Exact signed bigint to lowercase digits in radix 2..36; shared with the internal nonnegative decimal name builder.. Roles: DECLARED_INPUT_ROLES.
- **parse** — Strict whole-input signed bigint parse in radix 2..36; optional sign, ASCII digits case-insensitive, no whitespace/prefix/trailing text.. Roles: DECLARED_INPUT_ROLES.
- **removePrefix** — Remove one exact leading affix when present; fresh slice either way.. Roles: DECLARED_INPUT_ROLES.
- **removeSuffix** — The same affix-removal algorithm at the end.. Roles: DECLARED_INPUT_ROLES.
- **sum** — Common (+ initial copy(items)) Expression over actual ready numeric fields; empty input returns the initial value record.. Roles: DECLARED_INPUT_ROLES.
- **product** — Common (* initial copy(items)) Expression over actual ready numeric fields; empty input returns the initial value record.. Roles: DECLARED_INPUT_ROLES.
- **minimum** — First least ordered numeric value as its original typed record; empty input raises SequenceSize.. Roles: DECLARED_INPUT_ROLES.
- **maximum** — First greatest ordered numeric value as its original typed record; empty input raises SequenceSize.. Roles: DECLARED_INPUT_ROLES.
- **argMin** — Zero-based first index of the least ordered numeric value, using the same extremum loop.. Roles: DECLARED_INPUT_ROLES.
- **argMax** — Zero-based first index of the greatest ordered numeric value, using the same extremum loop.. Roles: DECLARED_INPUT_ROLES.
- **extrema** — Pair of original minimum and maximum records; delegates to the two existing extremum directions.. Roles: DECLARED_INPUT_ROLES.
- **min** — Choose the lesser of two typed ordered numeric value records; first identity wins ties.. Roles: DECLARED_INPUT_ROLES.
- **max** — Choose the greater of two typed ordered numeric value records; first identity wins ties.. Roles: DECLARED_INPUT_ROLES.
- **minMax** — Both original records in nondecreasing order; ties preserve input order and both identities.. Roles: DECLARED_INPUT_ROLES.
- **clamp** — Closed ordered interval through shared min/max; reversed bounds raise NumericDomain.. Roles: DECLARED_INPUT_ROLES.
- **sign** — Int -1/0/1 for ordered numeric values; no IEEE NaN or complex sign contract is claimed.. Roles: DECLARED_INPUT_ROLES.
- **gcd** — Exact nonnegative bigint Euclidean GCD, including gcd(0;0)=0.. Roles: DECLARED_INPUT_ROLES.
- **lcm** — Exact nonnegative bigint LCM through gcd; any zero input yields zero.. Roles: DECLARED_INPUT_ROLES.
- **divMod** — Exact bigint floor quotient and remainder with divisor sign; zero divisor raises NumericDomain.. Roles: DECLARED_INPUT_ROLES.
- **type** — actual physical type code of one captured whole value. Roles: VALUE_WHOLE.
- **arrayView** — finite typed Array source without copying element records. Roles: VALUE_WHOLE_ARRAY.
- **element** — one whole typed source element. Roles: VALUE_WHOLE.
- **equals** — one projection per value followed by the shared equality. Roles: DECLARED_INPUT_ROLES.
- **pipe** — apply value stages in order; exact final R through FxPipeBuild. Roles: VALUE_WHOLE, CALLABLE_SEQUENCE.
- **retry** — retry ordinary results by predicate/limit/delay; exact request R through FxRetryBuild. Roles: DECLARED_INPUT_ROLES.
- **fill** — Replace every reached element of the existing Array with one ready value through ordinary admission. Keep target identity and length; shallow references retain one target; empty Arrays perform no admission or write.. Roles: DECLARED_INPUT_ROLES.
- **lowerBound** — Binary search for the first false position in a stable true-prefix/false-suffix partition under less(element, needle); return length for all true. Generic value records and callback types; no mutation; empty input performs no callback.. Roles: DECLARED_INPUT_ROLES.
- **last** — Fresh outer Array containing the last min(count,length) elements in original order, preserving the physical source profile and shallow references. Negative count raises SequenceSize; count zero returns an empty Array. This Array operation does not infer Unicode grapheme or codepoint boundaries.. Roles: DECLARED_INPUT_ROLES.

Every variant retains its actual result, void/field-stream/control role, context and finite failures. Quoting does not select a different implementation. See [forms](../../OPERATION_FORMS.md), [generic operations](../../GENERIC_OPERATIONS.md), [monads](../../MONADIC_OPERATIONS.md) and [equality](../../GENERIC_EQUALITY.md).
