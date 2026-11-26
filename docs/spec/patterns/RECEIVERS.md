# Общие ресиверы и контейнеры LMX

Редакция: **23 ноября 2026 года**. Все перечисленные операции и контейнеры входят в единое текущее ядро и доступны по прямым именам. Клиентский import не требуется. `fun\const` — внутренний источник постоянных экспортов; исходный владелец метода и его DATA сохраняются. Разных подключаемых версий библиотек нет.

В каталоге нет ограничения пользовательских значений типом int или произвольной фиксированной арностью. Используются полные типовые требования и ссылки на записи `{type value}`. Любая структура уже является массивом @ и служит последовательностью без обязательной обёртки items. Индексы, длины и логические флаги сохраняют служебный int по смыслу языка. TYPE — прямая ссылка на канонический системный дескриптор; `types` возвращает []@ таких ссылок. Числовые TYPE-интерфейсы в прежних отдельных исходниках подлежат миграции по [новому ABI](../../TYPE_REFERENCES_CHANGE.md).

## Документы и реализация

- [Интеграция общих ресиверов в ядро](../kernel-implementation.en.md#receiver-kernel-integration).
- [Нормативное описание всех ресиверов](../LMX_semantics.en.md#functional-receivers).
- [Взаимозаменяемость форм сигнатуры с сохранённой связью именованной сигнатуры и call](../LMX_semantics.en.md#fn-forms-equivalent).
- [API с аргументами](LMX_Fn_Receivers/API.md) и [единая сборка исходников](LMX_Fn_Receivers/LMX_Receivers.lmx).
- [Минимальные входы ядра](LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md) и [проверки](LMX_Fn_Receivers/tests/ACCEPTANCE.md).
- [Реализация callable-адаптеров](LMX_Fn_Receivers/ADAPTER_IMPLEMENTATION.md), [общие последовательности](LMX_Fn_Receivers/SEQUENCES_IMPLEMENTATION.md) и [общие Patterns](LMX_Fn_Receivers/REGEX_IMPLEMENTATION.md).

## Полный каталог

Каталог содержит **215** канонических имён и **227** вариантов по типам. У каждого имени есть обычная ресиверная и общая операндная форма. Обе формы используют одно тело, те же роли аргументов и исходный контекст связывания. Вариант выбирается по типам; имя не создаёт отдельного алгоритма.

P0 уже принимает все ресиверы в Expression. Поддержка конкретной операции и ролей находится в трансляторе. Обычная и заключённая в обратные кавычки запись одного идентификатора обозначают одно имя. Символические операции сохраняют точное имя, а четыре прижатые формы `++var`, `var++`, `--var`, `var--` получают отдельные канонические шаблоны с одним аргументом PLACE. [Полный договор форм](../OPERATION_FORMS.md).

| Имя | Обычная форма | Варианты и исходники |
| --- | --- | --- |
| `types` | `types(source)` | default: [RxTypes\types](LMX_Fn_Receivers/src/reflection.lmx) |
| `names` | `names(source)` | default: [RxNames\names](LMX_Fn_Receivers/src/reflection_bridges.lmx) |
| `signature` | `signature(operation)` | default: [RxSignature\signature](LMX_Fn_Receivers/src/reflection_bridges.lmx) |
| `->` | `` `->`(inputTypes...; resultType) `` | default: [FxToTokens\`->`](LMX_Fn_Receivers/src/fn_operand.lmx) |
| `curry` | `curry(operation)` | default: [FxLambda\lambda](LMX_Fn_Receivers/src/generic_functions.lmx) |
| `apply` | `apply(operation; args)` | default: [FxApply\apply](LMX_Fn_Receivers/src/generic_runtime.lmx) |
| `partial` | `partial(operation; prefix)` | default: [FxPartial\partial](LMX_Fn_Receivers/src/generic_functions.lmx) |
| `uncurry` | `uncurry(operation; contract; failures)` | default: [FxUncurry\uncurry](LMX_Fn_Receivers/src/generic_functions.lmx) |
| `flip` | `flip(operation)` | default: [FxFlip\flip](LMX_Fn_Receivers/src/generic_functions.lmx) |
| `compose` | `compose(outer; inner)` | default: [FxCompose\compose](LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `identity` | `identity(typeToken)` | default: [FxIdentity\identity](LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `map` | `map(items; transform)` | default: [FxMap\map](LMX_Fn_Receivers/src/collections.lmx) |
| `filter` | `filter(items; accepts)` | default: [FxFilter\filter](LMX_Fn_Receivers/src/collections.lmx) |
| `foldl` | `foldl(items; seed; step)` | default: [FxFold\fold](LMX_Fn_Receivers/src/collections.lmx) |
| `zip` | `zip(first; second)` | default: [FxZip\zip](LMX_Fn_Receivers/src/collections.lmx) |
| `zipWith` | `zipWith(first; second; combine)` | default: [FxZipWith\zipWith](LMX_Fn_Receivers/src/collections.lmx) |
| `scanl` | `scanl(items; seed; step)` | default: [FxScan\scan](LMX_Fn_Receivers/src/collections.lmx) |
| `bind` | `bind(input; next)` | Maybe: [FxBind\bind](LMX_Fn_Receivers/src/containers.lmx); Result: [FxBindResult\bind](LMX_Fn_Receivers/src/containers.lmx); Array: [FxListBind\bind](LMX_Fn_Receivers/src/containers.lmx) |
| `traverse` | `traverse(items; next)` | default: [FxTraverse\traverse](LMX_Fn_Receivers/src/collections.lmx) |
| `memoize` | `memoize(operation; sameKey=0)` | default: [FxMemo\memo](LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `fix` | `fix(operation)` | default: [FxFix\fix](LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `select` | `select(source; indices)` | default: [RxSelect\select](LMX_Fn_Receivers/src/structures.lmx) |
| `omit` | `omit(source; indices)` | default: [RxOmit\omit](LMX_Fn_Receivers/src/structures.lmx) |
| `rename` | `rename(source; indices; labels)` | default: [RxRename\rename](LMX_Fn_Receivers/src/reflection_bridges.lmx) |
| `reorder` | `reorder(source; permutation)` | default: [RxReorder\reorder](LMX_Fn_Receivers/src/structures.lmx) |
| `project` | `project(source; indices)` | default: [RxProject\project](LMX_Fn_Receivers/src/structures.lmx) |
| `defaults` | `defaults(source; fallback)` | default: [RxDefaults\defaults](LMX_Fn_Receivers/src/structures.lmx) |
| `diff` | `diff(before; after)` | default: [RxDiff\diff](LMX_Fn_Receivers/src/structures.lmx) |
| `patch` | `patch(source; change)` | default: [RxPatch\patch](LMX_Fn_Receivers/src/structures.lmx) |
| `bindFields` | `bindFields(operation; bindings)` | default: [RxBindFields\bindFields](LMX_Fn_Receivers/src/structures.lmx) |
| `derive` | `derive(base; extension)` | default: [RxDerive\derive](LMX_Fn_Receivers/src/structures.lmx) |
| `transpose` | `transpose(rows)` | default: [FxTranspose\transpose](LMX_Fn_Receivers/src/collections.lmx) |
| `groupBy` | `groupBy(items; keyOf=0; sameKey=0)` | default: [FxGroupBy\groupBy](LMX_Fn_Receivers/src/collections.lmx) |
| `lazy` | `lazy(operation)` | default: [FxLazy\lazy](LMX_Fn_Receivers/src/generic_wrappers.lmx) |
| `force` | `force(thunk)` | default: [FxForce\force](LMX_Fn_Receivers/src/generic_wrappers.lmx) |
| `once` | `once(operation)` | default: [FxOnce\once](LMX_Fn_Receivers/src/generic_wrappers.lmx) |
| `repeat` | `repeat(operation; count; args=())` | default: [FxRepeat\repeat](LMX_Fn_Receivers/src/generic_wrappers.lmx) |
| `runUntil` | `runUntil(step; finished; initial)` | default: [FxUntil\runUntil](LMX_Fn_Receivers/src/generic_wrappers.lmx) |
| `retryCall` | `retryCall(operation; attempts; args=())` | default: [FxRetry\retryCall](LMX_Fn_Receivers/src/generic_wrappers.lmx) |
| `bracket` | `bracket(acquire; release; action; arguments=())` | default: [FxAround\around](LMX_Fn_Receivers/src/generic_wrappers.lmx) |
| `recover` | `recover(operation; handler)` | default: [FxRecover\recover](LMX_Fn_Receivers/src/generic_wrappers.lmx) |
| `adapter` | `adapter(operation; before; after; contract)` | default: [FxAdapter\adapter](LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `permute` | `permute(operation; permutation)` | default: [FxPermute\permute](LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `overload` | `overload(candidates; accepts; contract)` | default: [FxOverload\overload](LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `predicate` | `predicate(operation)` | default: [FxPredicate\predicate](LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `guard` | `guard(operation; accepts)` | default: [FxGuard\guard](LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `trace` | `trace(operation; sink)` | default: [FxTrace\trace](LMX_Fn_Receivers/src/generic_wrappers.lmx) |
| `contract` | `contract(operation; pre; post)` | default: [FxContract\contract](LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `composeData` | `composeData(code; overlay)` | default: [RxComposeData\composeData](LMX_Fn_Receivers/src/structures.lmx) |
| `record` | `record(left; right=())` | default: [FxRecordOperands\record](LMX_Fn_Receivers/src/generic_functions.lmx) |
| `some` | `some(value)` | default: [FxSome\some](LMX_Fn_Receivers/src/containers.lmx) |
| `none` | `none()` | default: [FxNone\none](LMX_Fn_Receivers/src/containers.lmx) |
| `ok` | `ok(value)` | default: [FxOk\ok](LMX_Fn_Receivers/src/containers.lmx) |
| `err` | `err(reason)` | default: [FxErr\err](LMX_Fn_Receivers/src/containers.lmx) |
| `list` | `list(values)` | default: [FxList\list](LMX_Fn_Receivers/src/containers.lmx) |
| `done` | `done(value)` | default: [FxDone\done](LMX_Fn_Receivers/src/containers.lmx) |
| `more` | `more(thunk)` | default: [FxMore\more](LMX_Fn_Receivers/src/containers.lmx) |
| `trampoline` | `trampoline(current)` | default: [FxTrampoline\trampoline](LMX_Fn_Receivers/src/containers.lmx) |
| `range` | `range(start; stop; step=1) / range(start; stop; step; profile)` | default: [FxSeqRange\range](LMX_Fn_Receivers/src/sequences.lmx); profile: [FxProfileRange\range](LMX_Fn_Receivers/src/sequence_profiles.lmx) |
| `slice` | `slice(source; begin; end)` | default: [FxSeqSlice\slice](LMX_Fn_Receivers/src/sequences.lmx) |
| `reverse` | `reverse(source)` | default: [FxSeqReverse\reverse](LMX_Fn_Receivers/src/sequences.lmx) |
| `concat` | `concat(parts)` | default: [FxSeqConcat\concat](LMX_Fn_Receivers/src/sequences.lmx) |
| `compress` | `compress(source; mask)` | default: [FxSeqCompress\compress](LMX_Fn_Receivers/src/sequences.lmx) |
| `any` | `any(items; accepts)` | default: [FxSeqAny\any](LMX_Fn_Receivers/src/sequences.lmx) |
| `all` | `all(items; accepts)` | default: [FxSeqAll\all](LMX_Fn_Receivers/src/sequences.lmx) |
| `index` | `index(items; accepts)` | default: [FxSeqIndex\index](LMX_Fn_Receivers/src/sequences.lmx) |
| `count` | `count(items; accepts)` | default: [FxSeqCount\count](LMX_Fn_Receivers/src/sequences.lmx) |
| `replaceRange` | `replaceRange(target; begin; end; values)` | default: [FxSeqReplaceRange\replaceRange](LMX_Fn_Receivers/src/sequences_mutation.lmx) |
| `splice` | `splice(target; begin; end; values)` | default: [FxSeqSplice\splice](LMX_Fn_Receivers/src/sequences_mutation.lmx) |
| `append` | `append(target; values)` | default: [FxSeqAppend\append](LMX_Fn_Receivers/src/sequences_mutation.lmx) |
| `insert` | `insert(target; position; values)` | default: [FxSeqInsert\insert](LMX_Fn_Receivers/src/sequences_mutation.lmx) |
| `deleteAt` | `deleteAt(target; begin; end)` | default: [FxSeqDeleteAt\deleteAt](LMX_Fn_Receivers/src/sequences_mutation.lmx) |
| `literal` | `literal(value)` | default: [RxLiteral\literal](LMX_Fn_Receivers/src/regex/primitives.lmx) |
| `oneOf` | `oneOf(values)` | default: [RxMembers\oneOf](LMX_Fn_Receivers/src/regex/primitives.lmx) |
| `noneOf` | `noneOf(values)` | default: [RxMembers\noneOf](LMX_Fn_Receivers/src/regex/primitives.lmx) |
| `within` | `within(first; last; order=0)` | default: [RxWithin\within](LMX_Fn_Receivers/src/regex/primitives.lmx) |
| `satisfy` | `satisfy(predicate)` | default: [RxSatisfy\satisfy](LMX_Fn_Receivers/src/regex/primitives.lmx) |
| `boundaryOf` | `boundaryOf(predicate)` | default: [RxBoundaryOf\boundaryOf](LMX_Fn_Receivers/src/regex/primitives.lmx) |
| `sameAs` | `sameAs(name)` | default: [RxSameAs\sameAs](LMX_Fn_Receivers/src/regex/primitives.lmx) |
| `then` | `then(patterns...)` | Pattern: [RxSequence\then](LMX_Fn_Receivers/src/regex/combinators.lmx) |
| `choice` | `choice(patterns)` | default: [RxChoice\choice](LMX_Fn_Receivers/src/regex/combinators.lmx) |
| `repeated` | `repeated(pattern; minimum=0; maximum=unbounded; order=extendFirst)` | default: [RxRepeated\repeated](LMX_Fn_Receivers/src/regex/combinators.lmx) |
| `atomic` | `atomic(pattern)` | default: [RxAtomic\atomic](LMX_Fn_Receivers/src/regex/combinators.lmx) |
| `capture` | `capture(name; pattern)` | default: [RxCapture\capture](LMX_Fn_Receivers/src/regex/combinators.lmx) |
| `ahead` | `ahead(pattern)` | default: [RxAhead\ahead](LMX_Fn_Receivers/src/regex/combinators.lmx) |
| `notAhead` | `notAhead(pattern)` | default: [RxNotAhead\notAhead](LMX_Fn_Receivers/src/regex/combinators.lmx) |
| `behind` | `behind(pattern)` | default: [RxBehind\behind](LMX_Fn_Receivers/src/regex/combinators.lmx) |
| `notBehind` | `notBehind(pattern)` | default: [RxNotBehind\notBehind](LMX_Fn_Receivers/src/regex/combinators.lmx) |
| `utf8Text` | `utf8Text(source)` | default: [RxUtf8Text\utf8Text](LMX_Fn_Receivers/src/regex/text.lmx) |
| `byteText` | `byteText(source)` | default: [RxByteText\byteText](LMX_Fn_Receivers/src/regex/text.lmx) |
| `matchAt` | `matchAt(source; pattern; position)` | default: [RxMatchAt\matchAt](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `wholeMatch` | `wholeMatch(source; pattern)` | default: [RxWholeMatch\wholeMatch](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `find` | `find(source; pattern)` | default: [RxFind\find](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `eachMatch` | `eachMatch(source; pattern)` | default: [RxEachMatch\eachMatch](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `contains` | `contains(source; pattern)` | default: [RxContains\contains](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `hasPrefix` | `hasPrefix(source; pattern)` | default: [RxHasPrefix\hasPrefix](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `hasSuffix` | `hasSuffix(source; pattern)` | default: [RxHasSuffix\hasSuffix](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `matches` | `matches(source; pattern)` | default: [RxMatches\matches](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `matchedSpan` | `matchedSpan(result)` | default: [RxMatchedSpan\matchedSpan](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `matchedValue` | `matchedValue(result)` | default: [RxMatchedValue\matchedValue](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `captureSpans` | `captureSpans(result; name)` | default: [RxCaptureSpans\captureSpans](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `lastCapture` | `lastCapture(result; name)` | default: [RxLastCapture\lastCapture](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `captureValue` | `captureValue(result; name)` | default: [RxCaptureValue\captureValue](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `captureValues` | `captureValues(result; name)` | default: [RxCaptureValues\captureValues](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `replaceFirst` | `replaceFirst(source; pattern; replacement)` | default: [RxReplaceFirst\replaceFirst](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `replace` | `replace(source; pattern; replacement)` | default: [RxReplace\replace](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `split` | `split(source; pattern)` | default: [RxSplit\split](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `times` | `times(left; right)` | default: [RxRepeatOperands\times](LMX_Fn_Receivers/src/regex/operands.lmx) |
| `atLeast` | `atLeast(left; right)` | default: [RxRepeatOperands\atLeast](LMX_Fn_Receivers/src/regex/operands.lmx) |
| `atMost` | `atMost(left; right)` | default: [RxRepeatOperands\atMost](LMX_Fn_Receivers/src/regex/operands.lmx) |
| `optional` | `optional(left; right)` | default: [RxRepeatOperands\optional](LMX_Fn_Receivers/src/regex/operands.lmx) |
| `findFirst` | `findFirst(items; accepts)` | default: [FxFindFirst\findFirst](LMX_Fn_Receivers/src/coreComparisonGroups.lmx) |
| `allOf` | `allOf(predicates; contract=0)` | default: [FxAllOf\allOf](LMX_Fn_Receivers/src/coreComparisonGroups.lmx) |
| `equalFields` | `equalFields(first; second; same=0)` | default: [FxEqualFields\equalFields](LMX_Fn_Receivers/src/coreComparisonGroups.lmx) |
| `retryPost` | `retryPost(request; retryOn; attempts; delay; firstDelay; maxDelay; timeoutMs; complete)` | default: [FxRetryPost\retryPost](LMX_Fn_Receivers/src/coreComparisonGroups.lmx) |
| `between` | `between(left; right)` | default: [FxBetween\between](LMX_Fn_Receivers/src/coreComparisonExamples.lmx) |
| `iterateUntilStop` | `iterateUntilStop(iteration; body)` | default: [FxIterateUntilStop\iterateUntilStop](LMX_Fn_Receivers/src/coreComparisonExamples.lmx) |
| `sort` | `sort(items; compare)` | default: [FxSort\sort](LMX_Fn_Receivers/src/corePerlExamples.lmx) |
| `unique` | `unique(items; same=0)` | default: [FxUnique\unique](LMX_Fn_Receivers/src/corePerlExamples.lmx) |
| `take` | `take(items; count)` | default: [FxStdCut\take](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `drop` | `drop(items; count)` | default: [FxStdCut\drop](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `splitAt` | `splitAt(items; count)` | default: [FxStdCut\splitAt](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `takeWhile` | `takeWhile(items; accepts)` | default: [FxStdPrefix\takeWhile](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `dropWhile` | `dropWhile(items; accepts)` | default: [FxStdPrefix\dropWhile](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `span` | `span(items; accepts)` | default: [FxStdPrefix\span](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `partition` | `partition(items; accepts)` | default: [FxStdPartition\partition](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `enumerate` | `enumerate(items; start=0)` | default: [FxStdEnumerate\enumerate](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `windows` | `windows(items; width=2; step=1; partial=0)` | default: [FxStdWindows\windows](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `chunks` | `chunks(items; size; strict=0)` | default: [FxStdChunks\chunks](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `intersperse` | `intersperse(items; separatorRecord)` | default: [FxStdIntersperse\intersperse](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `join` | `join(parts; separator)` | Array: [FxStdJoin\join](LMX_Fn_Receivers/src/coreStandardFunctional.lmx); text: [FxTextJoin\join](LMX_Fn_Receivers/src/sequence_profiles.lmx) |
| `unzip` | `unzip(pairs)` | default: [FxStdUnzip\unzip](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `foldr` | `foldr(items; seedRecord; step)` | default: [FxStdRightFold\foldr](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `scanr` | `scanr(items; seedRecord; step)` | default: [FxStdRightFold\scanr](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `filterMap` | `filterMap(items; transform)` | default: [FxStdMaybeMap\filterMap](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `mapWhile` | `mapWhile(items; transform)` | default: [FxStdMaybeMap\mapWhile](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `findMap` | `findMap(items; transform)` | default: [FxStdMaybeMap\findMap](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `mapAccumL` | `mapAccumL(items; seedRecord; step)` | default: [FxStdMapAccum\mapAccumL](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `mapAccumR` | `mapAccumR(items; seedRecord; step)` | default: [FxStdMapAccum\mapAccumR](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `groupAdjacent` | `groupAdjacent(items; keyOf=0; sameKey=0)` | default: [FxStdGroupAdjacent\groupAdjacent](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `replicate` | `replicate(valueRecord; count)` | default: [FxStdReplicate\replicate](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `cycle` | `cycle(items; count; rejectNegative=0)` | default: [FxStdCycle\cycle](LMX_Fn_Receivers/src/coreStandardFunctional.lmx); text: [FxTextCycle\cycle](LMX_Fn_Receivers/src/sequence_profiles.lmx) |
| `starmap` | `starmap(rows; operation)` | default: [FxStdStarMap\starmap](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `zipLongest` | `zipLongest(first; second; fillRecord)` | default: [FxStdZipLongest\zipLongest](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `collect` | `collect(next; limit=-1)` | default: [FxStdCollect\collect](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `includes` | `includes(items; valueRecord; same=0)` | default: [FxStdMembership\includes](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `adjoin` | `adjoin(items; valueRecord; same=0)` | default: [FxStdAdjoin\adjoin](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `union` | `union(first; second; same=0)` | default: [FxStdSets\union](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `intersection` | `intersection(first; second; same=0)` | default: [FxStdSets\intersection](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `difference` | `difference(first; second; same=0)` | default: [FxStdSets\difference](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `symmetricDifference` | `symmetricDifference(first; second; same=0)` | default: [FxStdSets\symmetricDifference](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `isSubset` | `isSubset(first; second; same=0)` | default: [FxStdSubset\isSubset](LMX_Fn_Receivers/src/coreStandardFunctional.lmx) |
| `mapOption` | `mapOption(input; transform)` | default: [FxMapOption\mapOption](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `filterOption` | `filterOption(input; accepts)` | default: [FxFilterOption\filterOption](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `orElse` | `orElse(input; fallback)` | default: [FxOrElse\orElse](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `orElseGet` | `orElseGet(input; fallback)` | default: [FxOrElseGet\orElseGet](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `orElseOption` | `orElseOption(input; fallback)` | default: [FxOrElseOption\orElseOption](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `foldOption` | `foldOption(input; whenEmpty; whenPresent)` | default: [FxFoldOption\foldOption](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `flattenOption` | `flattenOption(input)` | default: [FxFlattenOption\flattenOption](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `mapResult` | `mapResult(input; transform)` | default: [FxMapResult\mapResult](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `mapErr` | `mapErr(input; transform)` | default: [FxMapErr\mapErr](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `orElseResult` | `orElseResult(input; fallback)` | default: [FxOrElseResult\orElseResult](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `foldResult` | `foldResult(input; onError; onSuccess)` | default: [FxFoldResult\foldResult](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `attempt` | `attempt(operation; args=())` | default: [FxAttemptResult\attempt](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `tap` | `tap(value; action)` | default: [FxTap\tap](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `findField` | `findField(source; label; occurrence)` | default: [FxFindField\findField](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `hasField` | `hasField(source; label; occurrence)` | default: [FxHasField\hasField](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `getField` | `getField(source; label; occurrence)` | default: [FxGetField\getField](LMX_Fn_Receivers/src/coreStandardObjects.lmx) |
| `assoc` | `assoc(rows; key; same=0; keyIndex=0)` | default: [FxAssoc\assoc](LMX_Fn_Receivers/src/coreStandardLisp.lmx) |
| `pairlis` | `pairlis(keys; values; tail=())` | default: [FxPairlis\pairlis](LMX_Fn_Receivers/src/coreStandardLisp.lmx) |
| `getProperty` | `getProperty(properties; key; same=0)` | default: [FxGetProperty\getProperty](LMX_Fn_Receivers/src/coreStandardLisp.lmx) |
| `setProperty` | `setProperty(properties; key; value; same=0)` | default: [FxSetProperty\setProperty](LMX_Fn_Receivers/src/coreStandardLisp.lmx) |
| `removeProperty` | `removeProperty(properties; key; same=0)` | default: [FxRemoveProperty\removeProperty](LMX_Fn_Receivers/src/coreStandardLisp.lmx) |
| `getProperties` | `getProperties(properties; indicators; same=0)` | default: [FxGetProperties\getProperties](LMX_Fn_Receivers/src/coreStandardLisp.lmx) |
| `asOperand` | `asOperand(operation; priority)` | default: [FxAsOperand\asOperand](LMX_Fn_Receivers/src/coreStandardLisp.lmx) |
| `mismatch` | `mismatch(first; second; same=0)` | default: [FxMismatch\mismatch](LMX_Fn_Receivers/src/coreStandardLisp.lmx) |
| `searchSequence` | `searchSequence(items; pattern; same=0; start=0)` | default: [FxSearchSequence\searchSequence](LMX_Fn_Receivers/src/coreStandardLisp.lmx) |
| `substitute` | `substitute(items; oldValue; newValue; same=0)` | default: [FxSubstitute\substitute](LMX_Fn_Receivers/src/coreStandardLisp.lmx) |
| `indexOf` | `indexOf(text; part; start=0; same=0)` | default: [FxIndexOf\indexOf](LMX_Fn_Receivers/src/coreStandardText.lmx) |
| `lastIndexOf` | `lastIndexOf(text; part; start=length(text); same=0)` | default: [FxLastIndexOf\lastIndexOf](LMX_Fn_Receivers/src/coreStandardText.lmx) |
| `compare` | `compare(first; second; order=0)` | default: [FxCompare\compare](LMX_Fn_Receivers/src/coreStandardText.lmx) |
| `trim` | `trim(text; chars; predicate=0; same=0) / text profile supplies whitespace` | default: [FxTrim\trim](LMX_Fn_Receivers/src/coreStandardText.lmx); text: [FxTextTrim\trim](LMX_Fn_Receivers/src/sequence_profiles.lmx) |
| `trimStart` | `trimStart(text; chars; predicate=0; same=0) / text profile supplies whitespace` | default: [FxTrimStart\trim](LMX_Fn_Receivers/src/coreStandardText.lmx); text: [FxTextTrim\trimStart](LMX_Fn_Receivers/src/sequence_profiles.lmx) |
| `trimEnd` | `trimEnd(text; chars; predicate=0; same=0) / text profile supplies whitespace` | default: [FxTrimEnd\trim](LMX_Fn_Receivers/src/coreStandardText.lmx); text: [FxTextTrim\trimEnd](LMX_Fn_Receivers/src/sequence_profiles.lmx) |
| `padLeft` | `padLeft(text; width; fill) / text profile supplies space` | default: [FxPadLeft\pad](LMX_Fn_Receivers/src/coreStandardText.lmx); text: [FxTextPad\padLeft](LMX_Fn_Receivers/src/sequence_profiles.lmx) |
| `padRight` | `padRight(text; width; fill) / text profile supplies space` | default: [FxPadRight\pad](LMX_Fn_Receivers/src/coreStandardText.lmx); text: [FxTextPad\padRight](LMX_Fn_Receivers/src/sequence_profiles.lmx) |
| `translate` | `translate(text; from; to; same=0)` | default: [FxTranslate\translate](LMX_Fn_Receivers/src/coreStandardText.lmx) |
| `format` | `format(value; base=10) / format(value; profile; arguments=())` | default: [FxFormat\format](LMX_Fn_Receivers/src/coreStandardText.lmx); profile: [FxProfileFormat\format](LMX_Fn_Receivers/src/sequence_profiles.lmx) |
| `parse` | `parse(text; base=10) / parse(source; profile; arguments=())` | default: [FxParse\parse](LMX_Fn_Receivers/src/coreStandardText.lmx); profile: [FxProfileParse\parse](LMX_Fn_Receivers/src/sequence_profiles.lmx) |
| `removePrefix` | `removePrefix(text; affix; same=0)` | default: [FxRemovePrefix\remove](LMX_Fn_Receivers/src/coreStandardText.lmx) |
| `removeSuffix` | `removeSuffix(text; affix; same=0)` | default: [FxRemoveSuffix\remove](LMX_Fn_Receivers/src/coreStandardText.lmx) |
| `sum` | `sum(items; initial=(0 record))` | default: [FxSum\sum](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |
| `product` | `product(items; initial=(1 record))` | default: [FxProduct\product](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |
| `minimum` | `minimum(items)` | default: [FxMinimum\minimum](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |
| `maximum` | `maximum(items)` | default: [FxMaximum\maximum](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |
| `argMin` | `argMin(items)` | default: [FxArgMin\argMin](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |
| `argMax` | `argMax(items)` | default: [FxArgMax\argMax](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |
| `extrema` | `extrema(items)` | default: [FxExtrema\extrema](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |
| `min` | `min(first; second)` | default: [FxMin\min](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |
| `max` | `max(first; second)` | default: [FxMax\max](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |
| `minMax` | `minMax(first; second)` | default: [FxMinMax\minMax](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |
| `clamp` | `clamp(value; lower; upper)` | default: [FxClamp\clamp](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |
| `sign` | `sign(value)` | default: [FxSign\sign](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |
| `gcd` | `gcd(first; second)` | default: [FxGcd\gcd](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |
| `lcm` | `lcm(first; second)` | default: [FxLcm\lcm](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |
| `divMod` | `divMod(dividend; divisor)` | default: [FxDivMod\divMod](LMX_Fn_Receivers/src/coreStandardNumeric.lmx) |
| `type` | `type(value)` | default: [FxValueType\type](LMX_Fn_Receivers/src/operation_forms.lmx) |
| `arrayView` | `arrayView(items)` | default: [RxArrayView\arrayView](LMX_Fn_Receivers/src/regex/source.lmx) |
| `element` | `element(value)` | default: [RxElement\element](LMX_Fn_Receivers/src/regex/primitives.lmx) |
| `equals` | `equals(first; second; projection=0; same=0)` | default: [FxEquals\equals](LMX_Fn_Receivers/src/coreGenericOperations.lmx) |
| `pipe` | `pipe(value; stages)` | default: [FxPipe\pipe](LMX_Fn_Receivers/src/coreGenericOperations.lmx) |
| `retry` | `retry(operation; retryOn; limit; delay=0; arguments=())` | default: [FxRetryValue\retry](LMX_Fn_Receivers/src/coreGenericOperations.lmx) |
| `fill` | `fill(target; valueRecord)` | default: [FxArrayFill\fill](LMX_Fn_Receivers/src/fill.lmx) |
| `lowerBound` | `lowerBound(items; needleRecord; less)` | default: [FxLowerBound\lowerBound](LMX_Fn_Receivers/src/lowerBound.lmx) |
| `last` | `last(items; count)` | default: [FxSeqLast\last](LMX_Fn_Receivers/src/last.lmx) |

## Общие договоры

`bind` объединяет Maybe, Result и Array по типам. Он заменяет отдельные названия той же операции; some(x), ok(x), err(x) и done(x) сами захватывают типизированную запись значения. Пользовательский клиент может писать `some(x) bind half bind half`; обычная форма bind сохраняется. [Монадические операции](../MONADIC_OPERATIONS.md).

`unique(items)` использует общее равенство и оставляет первое появление. Явный `same` заменяет равенство всего элемента. Вложенные конечные ациклические Arrays сравниваются структурно; типовые токены, скаляры, текст и ссылки следуют своему действительному договору. `equalFields` и `unique` используют общий поиск первого различия, без второго текстового сравнения. [Общее равенство](../GENERIC_EQUALITY.md).

`then` соединяет общие Patterns. `arrayView`, `element`, `literal`, `within`, `oneOf`, `noneOf`, `anyElement`, `start`, `end`, `matchedValue`, `captureValue` и `captureValues` работают в выбранном профиле последовательности. `utf8Text` и `byteText` остаются явно текстовыми конструкторами профиля. [Общие операции](../GENERIC_OPERATIONS.md).

`compose(outer; inner)` строит callable и не исполняет стадии при построении. `pipe(value; stages)` применяет стадии к принятому значению по порядку; его фактический тип может меняться. `equals` принимает явную проекцию, `findFirst` — предикат, `allOf` — совместимые предикаты произвольной сигнатуры, `retry` — operation/retryOn/limit/delay. Прикладные профили Money и Http503 задают данные и политики, общий алгоритм остаётся в ядре. [Примеры и зависимости](UNIFIED_OPERATIONS.md).

`type` выражает требование типа без конфликта с объявлением `int: x`. `->` получает входные TYPE и последний TYPE результата: `A0 -> A1 R`. Обозначения TYPE/RAW/PLACE/LAZY_NODE сохраняют роль и не вычисляются как обычное значение только из-за выбора формы вызова.

`retryPost` использует настоящие Message/post, сохраняет конечный результат и учитывает поздние ответы. Таймаут или отмена дальнейших повторов не означают принудительного завершения удалённого вызова. `iterateUntilStop` использует принятую декларацию и живые места принимающего исполнения; нижний мост attemptAccepted явно описан как граница интеграции.

## Значение, запись и созданная функция

`(value record)` даёт ссылку на типизированную запись. Это удобно для неоднородной структуры аргументов, Maybe/Result и коллекций. Обычное разыменование читает значение по его реальному типу. Контейнер не требует предварительно превращать любое значение в int или дополнительную одноэлементную структуру.

`apply` переносит результат как такую запись. Фабрики `curry`, `partial`, `flip` и композиции создают обычные callable с точными типами входов и результата. Возвращаемый фабрикой @ означает ссылку на созданный callable, а не изменение его результата на @. Void сохраняет отдельное значение отсутствия результата.

Maybe имеет present и ссылку value; Result — ok и ссылку value/reason; List — сама структура; Bounce — done/result либо нульарное продолжение. `more` не вызывает продолжение, а `trampoline` запускает их по одному. Эти формы используют существующую память LMX и не добавляют класс, scheduler или новую разновидность арены.

## Названия

Имена согласованы с [канонической миграцией](LMX_Fn_Receivers/CANONICAL_MIGRATION.json). Прежние callable aliases не сохраняются. Исторические карты переименований описывают происхождение, а действующий [catalog.json](LMX_Fn_Receivers/catalog.json) задаёт публичные имена, типовые варианты и маршруты обеих форм. Имена контрольных языков в их исходниках остаются родными.

Каррирование называется `curry`, левая свёртка — `foldl`, её префиксы с seed — `scanl`, мемоизация — `memoize`, acquire/release/action — `bracket`. Именованные сигнатуры записываются `Name :: DATA`; построение из TYPE доступно как `->` с типом результата последним. `index` возвращает Maybe индекса, `deleteAt` удаляет полуоткрытый диапазон. Смена формы вызова не меняет ни один из этих договоров.

## Примеры и метрика

[Функциональная группа](09_functional_computation/README.md) и [корневые примеры](examples/README.ru.md) используют этот API. Для 109 клиентских договоров опубликованы полные процедурная и функциональная LMX-формы: 96 сценариев четырёх наборов examples, четыре клиента 082–085 и девять сценариев групп 10–11. Самостоятельные реализации на контрольных языках сравниваются с LMX отдельно, а клиенты используют настоящие библиотеки или средства языка. Функциональные LMX-клиенты используют прямые имена ядра; процедурные показывают явные алгоритмы. Общие библиотечные тела и зависимости хранятся и учитываются один раз.

Это исходная реализация и контракт интеграции. Часть входов ядра требует реализации по [интеграции в ядро](../kernel-implementation.en.md#receiver-kernel-integration). Статический отчёт не заменяет запуск parser/transpiler или native/interpreter.

## Как сравниваются полные варианты

Обе LMX-формы одного договора участвуют в сравнении своими полными размерами.
Все объявления, вспомогательные методы, обработчики и Throws, включая полные
ссылки на договоры фактически выбранных методов, входят в подсчёт. Никакие
аргументы Throws не удаляются статистически. Обоснованное совпадение минимальной
формы означает один исходник и две равные записи метрик. В PDF/XLSX зелёным шрифтом
и подчёркнутым числом выделяются все равные минимумы сопоставимой строки;
неполная аналогия победителя не получает.

Включение helper в ядро само по себе не позволяет скрыть его работу: библиотечный вызов
LMX сопоставляется с библиотекой или оператором контрольного языка, выполняющим
сопоставимую работу. Если контроль раскрывает предметный алгоритм, его реализация
показывается и учитывается также на стороне LMX либо сравнение помечается отдельным
уровнем использования. Общие определения считаются один раз.

Архитектурные преимущества языка сохраняются: обычные copy/merge, динамическая
структура и связывание не заменяются искусственной имитацией классов или
статических generic-конструкций. Сравниваются задача и поведение, а не форма
алгоритмов. Поля, идентичность, порядок эффектов, состояния, ошибки и проверяемый
результат нельзя удалять ради сокращения; в Flyweight поле width остаётся во всех
реализациях. Исторический некорректный листинг может быть пояснением, но не
участником сравнения текущих полных вариантов.

## Операнды и скобки

`::` использует expression LMX и общие правила операндов. `Name :: A B` передаёт
два правых аргумента, `Name :: (A B)` — один аргумент-структуру.
Единственное общее раскрытие возможно, когда left — безымянная структура,
right содержит ровно один аргумент и этот аргумент тоже безымянная структура.
Тогда снимается один внешний уровень только в right; left остаётся целым.
Операция не повторяется рекурсивно и никогда не выполняется P0. Для левого
идентификатора Name это исключение не действует. [Полная матрица случаев](../LMX_semantics.en.md#operand-right-only-opening).
