# Каталог функций ядра

**Дополнение 2026-11-26:** [матричные и поэлементные формы, `.:`, `.=`, `fuse`, условие и срезы](ARRAY_EXPRESSIONS.md) включены в отдельную опись профилей; исходные 215 имён / 227 вариантов сохранены. LMX-циклы и модели проверки приложены, production-интеграция не объявляется выполненной.

Исходная опись — [inventory.lmx](inventory.lmx); [JSON-проекция](inventory.json) удобна для инструментария и не вводит JSON в runtime языка.

В исходном каноническом каталоге **215 имён и 227 семантических вариантов**. Предложенная группировка сохраняет все тела, роли аргументов, сигнатуры и declared failures. Самосборщик не использовался как замена действующей спецификации.

| Пакет | Канонических имён в пакете |
|---|---:|
| `call` | 36 |
| `graph` | 26 |
| `math` | 15 |
| `maybe` | 10 |
| `message` | 1 |
| `pattern` | 41 |
| `result` | 8 |
| `seq` | 69 |
| `text` | 15 |

Сумма по пакетам может превышать 215: варианты одного имени (`bind`, `join`, `cycle`) имеют разные семантические семейства. Это не дублирование реализации.

[publication.lmx](publication.lmx) содержит ссылки на исходные CODE-occurrences и operand-формы. Он требует штатной публикации семейств из [PUBLICATION_CONTRACT](../../spec/patterns/LMX_Fn_Receivers/PUBLICATION_CONTRACT.md), не вызывает тела и не меняет их `parent`.

Отдельные реестры:

- [values.lmx](values.lmx): 24 значения, требования и именованных исхода; они не прибавляются к количеству функций.
- [kernel_bridges.lmx](kernel_bridges.lmx): 19 требуемых внутренних интерфейсов ядра; объявления не считаются реализованными C-функциями.
- [system_receivers.lmx](system_receivers.lmx): системные и базовые языковые receiver-контракты, сохраняющие текущие роли.
- [language_forms.lmx](language_forms.lmx): полная матрица классов ресиверов/операндов из OPERATION_FORMS; управляющие формы и объявления не превращены в обычные VALUE-callables.
- [profile_roles.lmx](profile_roles.lmx): математические, тензорные, криптографические и отладочные контракты спецификации вне каталога 215 имён; семантическая роль отделена от будущего точного имени и ABI.
- [selfbuild_index.lmx](selfbuild_index.lmx): все найденные `fn/sub/fm`-объявления в исходниках и инструментах старого selfbuild, без тестовых файлов. Это индекс исторической реализации, не дополнительный публичный L3 API.

## Карта операций

| Путь | Семейство | Сигнатура | Исходное тело |
|---|---|---|---|
| `graph\types` | `default` | `types(source)` | [RxTypes\types](../../../docs/spec/patterns/LMX_Fn_Receivers/src/reflection.lmx), строка 34 |
| `graph\names` | `default` | `names(source)` | [RxNames\names](../../../docs/spec/patterns/LMX_Fn_Receivers/src/reflection_bridges.lmx), строка 19 |
| `graph\signature` | `default` | `signature(operation)` | [RxSignature\signature](../../../docs/spec/patterns/LMX_Fn_Receivers/src/reflection_bridges.lmx), строка 8 |
| `call\->` | `default` | ``->`(inputTypes...; resultType)` | [FxToTokens\`->`](../../../docs/spec/patterns/LMX_Fn_Receivers/src/fn_operand.lmx), строка 45 |
| `call\curry` | `default` | `curry(operation)` | [FxLambda\lambda](../../../docs/spec/patterns/LMX_Fn_Receivers/src/generic_functions.lmx), строка 350 |
| `call\apply` | `default` | `apply(operation; args)` | [FxApply\apply](../../../docs/spec/patterns/LMX_Fn_Receivers/src/generic_runtime.lmx), строка 70 |
| `call\partial` | `default` | `partial(operation; prefix)` | [FxPartial\partial](../../../docs/spec/patterns/LMX_Fn_Receivers/src/generic_functions.lmx), строка 275 |
| `call\uncurry` | `default` | `uncurry(operation; contract; failures)` | [FxUncurry\uncurry](../../../docs/spec/patterns/LMX_Fn_Receivers/src/generic_functions.lmx), строка 426 |
| `call\flip` | `default` | `flip(operation)` | [FxFlip\flip](../../../docs/spec/patterns/LMX_Fn_Receivers/src/generic_functions.lmx), строка 358 |
| `call\compose` | `default` | `compose(outer; inner)` | [FxCompose\compose](../../../docs/spec/patterns/LMX_Fn_Receivers/src/generic_combinators.lmx), строка 24 |
| `call\identity` | `default` | `identity(typeToken)` | [FxIdentity\identity](../../../docs/spec/patterns/LMX_Fn_Receivers/src/generic_combinators.lmx), строка 40 |
| `seq\map` | `default` | `map(items; transform)` | [FxMap\map](../../../docs/spec/patterns/LMX_Fn_Receivers/src/collections.lmx), строка 15 |
| `seq\filter` | `default` | `filter(items; accepts)` | [FxFilter\filter](../../../docs/spec/patterns/LMX_Fn_Receivers/src/collections.lmx), строка 33 |
| `seq\foldl` | `default` | `foldl(items; seed; step)` | [FxFold\fold](../../../docs/spec/patterns/LMX_Fn_Receivers/src/collections.lmx), строка 59 |
| `seq\zip` | `default` | `zip(first; second)` | [FxZip\zip](../../../docs/spec/patterns/LMX_Fn_Receivers/src/collections.lmx), строка 81 |
| `seq\zipWith` | `default` | `zipWith(first; second; combine)` | [FxZipWith\zipWith](../../../docs/spec/patterns/LMX_Fn_Receivers/src/collections.lmx), строка 105 |
| `seq\scanl` | `default` | `scanl(items; seed; step)` | [FxScan\scan](../../../docs/spec/patterns/LMX_Fn_Receivers/src/collections.lmx), строка 128 |
| `maybe\bind` | `Maybe` | `bind(input; next)` | [FxBind\bind](../../../docs/spec/patterns/LMX_Fn_Receivers/src/containers.lmx), строка 31 |
| `result\bind` | `Result` | `bind(input; next)` | [FxBindResult\bind](../../../docs/spec/patterns/LMX_Fn_Receivers/src/containers.lmx), строка 72 |
| `seq\bind` | `Array` | `bind(input; next)` | [FxListBind\bind](../../../docs/spec/patterns/LMX_Fn_Receivers/src/containers.lmx), строка 102 |
| `seq\traverse` | `default` | `traverse(items; next)` | [FxTraverse\traverse](../../../docs/spec/patterns/LMX_Fn_Receivers/src/collections.lmx), строка 152 |
| `call\memoize` | `default` | `memoize(operation; sameKey=0)` | [FxMemo\memo](../../../docs/spec/patterns/LMX_Fn_Receivers/src/generic_combinators.lmx), строка 122 |
| `call\fix` | `default` | `fix(operation)` | [FxFix\fix](../../../docs/spec/patterns/LMX_Fn_Receivers/src/generic_combinators.lmx), строка 154 |
| `graph\select` | `default` | `select(source; indices)` | [RxSelect\select](../../../docs/spec/patterns/LMX_Fn_Receivers/src/structures.lmx), строка 11 |
| `graph\omit` | `default` | `omit(source; indices)` | [RxOmit\omit](../../../docs/spec/patterns/LMX_Fn_Receivers/src/structures.lmx), строка 21 |
| `graph\rename` | `default` | `rename(source; indices; labels)` | [RxRename\rename](../../../docs/spec/patterns/LMX_Fn_Receivers/src/reflection_bridges.lmx), строка 32 |
| `graph\reorder` | `default` | `reorder(source; permutation)` | [RxReorder\reorder](../../../docs/spec/patterns/LMX_Fn_Receivers/src/structures.lmx), строка 31 |
| `graph\project` | `default` | `project(source; indices)` | [RxProject\project](../../../docs/spec/patterns/LMX_Fn_Receivers/src/structures.lmx), строка 41 |
| `graph\defaults` | `default` | `defaults(source; fallback)` | [RxDefaults\defaults](../../../docs/spec/patterns/LMX_Fn_Receivers/src/structures.lmx), строка 52 |
| `graph\diff` | `default` | `diff(before; after)` | [RxDiff\diff](../../../docs/spec/patterns/LMX_Fn_Receivers/src/structures.lmx), строка 86 |
| `graph\patch` | `default` | `patch(source; change)` | [RxPatch\patch](../../../docs/spec/patterns/LMX_Fn_Receivers/src/structures.lmx), строка 133 |
| `graph\bindFields` | `default` | `bindFields(operation; bindings)` | [RxBindFields\bindFields](../../../docs/spec/patterns/LMX_Fn_Receivers/src/structures.lmx), строка 220 |
| `graph\derive` | `default` | `derive(base; extension)` | [RxDerive\derive](../../../docs/spec/patterns/LMX_Fn_Receivers/src/structures.lmx), строка 63 |
| `seq\transpose` | `default` | `transpose(rows)` | [FxTranspose\transpose](../../../docs/spec/patterns/LMX_Fn_Receivers/src/collections.lmx), строка 174 |
| `seq\groupBy` | `default` | `groupBy(items; keyOf=0; sameKey=0)` | [FxGroupBy\groupBy](../../../docs/spec/patterns/LMX_Fn_Receivers/src/collections.lmx), строка 217 |
| `call\lazy` | `default` | `lazy(operation)` | [FxLazy\lazy](../../../docs/spec/patterns/LMX_Fn_Receivers/src/generic_wrappers.lmx), строка 53 |
| `call\force` | `default` | `force(thunk)` | [FxForce\force](../../../docs/spec/patterns/LMX_Fn_Receivers/src/generic_wrappers.lmx), строка 63 |
| `call\once` | `default` | `once(operation)` | [FxOnce\once](../../../docs/spec/patterns/LMX_Fn_Receivers/src/generic_wrappers.lmx), строка 40 |
| `call\repeat` | `default` | `repeat(operation; count; args=())` | [FxRepeat\repeat](../../../docs/spec/patterns/LMX_Fn_Receivers/src/generic_wrappers.lmx), строка 73 |
| `call\runUntil` | `default` | `runUntil(step; finished; initial)` | [FxUntil\runUntil](../../../docs/spec/patterns/LMX_Fn_Receivers/src/generic_wrappers.lmx), строка 92 |
| `call\retryCall` | `default` | `retryCall(operation; attempts; args=())` | [FxRetry\retryCall](../../../docs/spec/patterns/LMX_Fn_Receivers/src/generic_wrappers.lmx), строка 111 |
| `call\bracket` | `default` | `bracket(acquire; release; action; arguments=())` | [FxAround\around](../../../docs/spec/patterns/LMX_Fn_Receivers/src/generic_wrappers.lmx), строка 146 |
| `call\recover` | `default` | `recover(operation; handler)` | [FxRecover\recover](../../../docs/spec/patterns/LMX_Fn_Receivers/src/generic_wrappers.lmx), строка 184 |
| `call\adapter` | `default` | `adapter(operation; before; after; contract)` | [FxAdapter\adapter](../../../docs/spec/patterns/LMX_Fn_Receivers/src/generic_combinators.lmx), строка 201 |
| `call\permute` | `default` | `permute(operation; permutation)` | [FxPermute\permute](../../../docs/spec/patterns/LMX_Fn_Receivers/src/generic_combinators.lmx), строка 66 |
| `call\overload` | `default` | `overload(candidates; accepts; contract)` | [FxOverload\overload](../../../docs/spec/patterns/LMX_Fn_Receivers/src/generic_combinators.lmx), строка 339 |
| `call\predicate` | `default` | `predicate(operation)` | [FxPredicate\predicate](../../../docs/spec/patterns/LMX_Fn_Receivers/src/generic_combinators.lmx), строка 233 |
| `call\guard` | `default` | `guard(operation; accepts)` | [FxGuard\guard](../../../docs/spec/patterns/LMX_Fn_Receivers/src/generic_combinators.lmx), строка 301 |
| `call\trace` | `default` | `trace(operation; sink)` | [FxTrace\trace](../../../docs/spec/patterns/LMX_Fn_Receivers/src/generic_wrappers.lmx), строка 246 |
| `call\contract` | `default` | `contract(operation; pre; post)` | [FxContract\contract](../../../docs/spec/patterns/LMX_Fn_Receivers/src/generic_combinators.lmx), строка 279 |
| `graph\composeData` | `default` | `composeData(code; overlay)` | [RxComposeData\composeData](../../../docs/spec/patterns/LMX_Fn_Receivers/src/structures.lmx), строка 202 |
| `call\record` | `default` | `record(left; right=())` | [FxRecordOperands\record](../../../docs/spec/patterns/LMX_Fn_Receivers/src/generic_functions.lmx), строка 51 |
| `maybe\some` | `default` | `some(value)` | [FxSome\some](../../../docs/spec/patterns/LMX_Fn_Receivers/src/containers.lmx), строка 14 |
| `maybe\none` | `default` | `none()` | [FxNone\none](../../../docs/spec/patterns/LMX_Fn_Receivers/src/containers.lmx), строка 22 |
| `result\ok` | `default` | `ok(value)` | [FxOk\ok](../../../docs/spec/patterns/LMX_Fn_Receivers/src/containers.lmx), строка 51 |
| `result\err` | `default` | `err(reason)` | [FxErr\err](../../../docs/spec/patterns/LMX_Fn_Receivers/src/containers.lmx), строка 61 |
| `seq\list` | `default` | `list(values)` | [FxList\list](../../../docs/spec/patterns/LMX_Fn_Receivers/src/containers.lmx), строка 92 |
| `call\done` | `default` | `done(value)` | [FxDone\done](../../../docs/spec/patterns/LMX_Fn_Receivers/src/containers.lmx), строка 122 |
| `call\more` | `default` | `more(thunk)` | [FxMore\more](../../../docs/spec/patterns/LMX_Fn_Receivers/src/containers.lmx), строка 131 |
| `call\trampoline` | `default` | `trampoline(current)` | [FxTrampoline\trampoline](../../../docs/spec/patterns/LMX_Fn_Receivers/src/containers.lmx), строка 143 |
| `seq\range` | `default` | `range(start; stop; step=1) / range(start; stop; step; profile)` | [FxSeqRange\range](../../../docs/spec/patterns/LMX_Fn_Receivers/src/sequences.lmx), строка 11 |
| `seq\range` | `profile` | `range(start; stop; step=1) / range(start; stop; step; profile)` | [FxProfileRange\range](../../../docs/spec/patterns/LMX_Fn_Receivers/src/sequence_profiles.lmx), строка 19 |
| `seq\slice` | `default` | `slice(source; begin; end)` | [FxSeqSlice\slice](../../../docs/spec/patterns/LMX_Fn_Receivers/src/sequences.lmx), строка 54 |
| `seq\reverse` | `default` | `reverse(source)` | [FxSeqReverse\reverse](../../../docs/spec/patterns/LMX_Fn_Receivers/src/sequences.lmx), строка 70 |
| `seq\concat` | `default` | `concat(parts)` | [FxSeqConcat\concat](../../../docs/spec/patterns/LMX_Fn_Receivers/src/sequences.lmx), строка 86 |
| `seq\compress` | `default` | `compress(source; mask)` | [FxSeqCompress\compress](../../../docs/spec/patterns/LMX_Fn_Receivers/src/sequences.lmx), строка 136 |
| `seq\any` | `default` | `any(items; accepts)` | [FxSeqAny\any](../../../docs/spec/patterns/LMX_Fn_Receivers/src/sequences.lmx), строка 171 |
| `seq\all` | `default` | `all(items; accepts)` | [FxSeqAll\all](../../../docs/spec/patterns/LMX_Fn_Receivers/src/sequences.lmx), строка 190 |
| `seq\index` | `default` | `index(items; accepts)` | [FxSeqIndex\index](../../../docs/spec/patterns/LMX_Fn_Receivers/src/sequences.lmx), строка 209 |
| `seq\count` | `default` | `count(items; accepts)` | [FxSeqCount\count](../../../docs/spec/patterns/LMX_Fn_Receivers/src/sequences.lmx), строка 228 |
| `seq\replaceRange` | `default` | `replaceRange(target; begin; end; values)` | [FxSeqReplaceRange\replaceRange](../../../docs/spec/patterns/LMX_Fn_Receivers/src/sequences_mutation.lmx), строка 14 |
| `seq\splice` | `default` | `splice(target; begin; end; values)` | [FxSeqSplice\splice](../../../docs/spec/patterns/LMX_Fn_Receivers/src/sequences_mutation.lmx), строка 73 |
| `seq\append` | `default` | `append(target; values)` | [FxSeqAppend\append](../../../docs/spec/patterns/LMX_Fn_Receivers/src/sequences_mutation.lmx), строка 91 |
| `seq\insert` | `default` | `insert(target; position; values)` | [FxSeqInsert\insert](../../../docs/spec/patterns/LMX_Fn_Receivers/src/sequences_mutation.lmx), строка 104 |
| `seq\deleteAt` | `default` | `deleteAt(target; begin; end)` | [FxSeqDeleteAt\deleteAt](../../../docs/spec/patterns/LMX_Fn_Receivers/src/sequences_mutation.lmx), строка 115 |
| `pattern\literal` | `default` | `literal(value)` | [RxLiteral\literal](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/primitives.lmx), строка 61 |
| `pattern\oneOf` | `default` | `oneOf(values)` | [RxMembers\oneOf](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/primitives.lmx), строка 102 |
| `pattern\noneOf` | `default` | `noneOf(values)` | [RxMembers\noneOf](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/primitives.lmx), строка 104 |
| `pattern\within` | `default` | `within(first; last; order=0)` | [RxWithin\within](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/primitives.lmx), строка 138 |
| `pattern\satisfy` | `default` | `satisfy(predicate)` | [RxSatisfy\satisfy](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/primitives.lmx), строка 173 |
| `pattern\boundaryOf` | `default` | `boundaryOf(predicate)` | [RxBoundaryOf\boundaryOf](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/primitives.lmx), строка 201 |
| `pattern\sameAs` | `default` | `sameAs(name)` | [RxSameAs\sameAs](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/primitives.lmx), строка 231 |
| `pattern\then` | `Pattern` | `then(patterns...)` | [RxSequence\then](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/combinators.lmx), строка 30 |
| `pattern\choice` | `default` | `choice(patterns)` | [RxChoice\choice](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/combinators.lmx), строка 43 |
| `pattern\repeated` | `default` | `repeated(pattern; minimum=0; maximum=unbounded; order=extendFirst)` | [RxRepeated\repeated](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/combinators.lmx), строка 162 |
| `pattern\atomic` | `default` | `atomic(pattern)` | [RxAtomic\atomic](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/combinators.lmx), строка 266 |
| `pattern\capture` | `default` | `capture(name; pattern)` | [RxCapture\capture](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/combinators.lmx), строка 308 |
| `pattern\ahead` | `default` | `ahead(pattern)` | [RxAhead\ahead](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/combinators.lmx), строка 388 |
| `pattern\notAhead` | `default` | `notAhead(pattern)` | [RxNotAhead\notAhead](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/combinators.lmx), строка 400 |
| `pattern\behind` | `default` | `behind(pattern)` | [RxBehind\behind](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/combinators.lmx), строка 412 |
| `pattern\notBehind` | `default` | `notBehind(pattern)` | [RxNotBehind\notBehind](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/combinators.lmx), строка 424 |
| `pattern\utf8Text` | `default` | `utf8Text(source)` | [RxUtf8Text\utf8Text](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/text.lmx), строка 125 |
| `pattern\byteText` | `default` | `byteText(source)` | [RxByteText\byteText](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/text.lmx), строка 132 |
| `pattern\matchAt` | `default` | `matchAt(source; pattern; position)` | [RxMatchAt\matchAt](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/operations.lmx), строка 35 |
| `pattern\wholeMatch` | `default` | `wholeMatch(source; pattern)` | [RxWholeMatch\wholeMatch](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/operations.lmx), строка 47 |
| `pattern\find` | `default` | `find(source; pattern)` | [RxFind\find](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/operations.lmx), строка 106 |
| `pattern\eachMatch` | `default` | `eachMatch(source; pattern)` | [RxEachMatch\eachMatch](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/operations.lmx), строка 133 |
| `pattern\contains` | `default` | `contains(source; pattern)` | [RxContains\contains](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/operations.lmx), строка 147 |
| `pattern\hasPrefix` | `default` | `hasPrefix(source; pattern)` | [RxHasPrefix\hasPrefix](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/operations.lmx), строка 158 |
| `pattern\hasSuffix` | `default` | `hasSuffix(source; pattern)` | [RxHasSuffix\hasSuffix](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/operations.lmx), строка 169 |
| `pattern\matches` | `default` | `matches(source; pattern)` | [RxMatches\matches](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/operations.lmx), строка 192 |
| `pattern\matchedSpan` | `default` | `matchedSpan(result)` | [RxMatchedSpan\matchedSpan](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/operations.lmx), строка 201 |
| `pattern\matchedValue` | `default` | `matchedValue(result)` | [RxMatchedValue\matchedValue](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/operations.lmx), строка 208 |
| `pattern\captureSpans` | `default` | `captureSpans(result; name)` | [RxCaptureSpans\captureSpans](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/operations.lmx), строка 217 |
| `pattern\lastCapture` | `default` | `lastCapture(result; name)` | [RxLastCapture\lastCapture](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/operations.lmx), строка 240 |
| `pattern\captureValue` | `default` | `captureValue(result; name)` | [RxCaptureValue\captureValue](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/operations.lmx), строка 253 |
| `pattern\captureValues` | `default` | `captureValues(result; name)` | [RxCaptureValues\captureValues](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/operations.lmx), строка 267 |
| `pattern\replaceFirst` | `default` | `replaceFirst(source; pattern; replacement)` | [RxReplaceFirst\replaceFirst](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/operations.lmx), строка 286 |
| `pattern\replace` | `default` | `replace(source; pattern; replacement)` | [RxReplace\replace](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/operations.lmx), строка 310 |
| `pattern\split` | `default` | `split(source; pattern)` | [RxSplit\split](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/operations.lmx), строка 336 |
| `pattern\times` | `default` | `times(left; right)` | [RxRepeatOperands\times](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/operands.lmx), строка 54 |
| `pattern\atLeast` | `default` | `atLeast(left; right)` | [RxRepeatOperands\atLeast](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/operands.lmx), строка 61 |
| `pattern\atMost` | `default` | `atMost(left; right)` | [RxRepeatOperands\atMost](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/operands.lmx), строка 68 |
| `pattern\optional` | `default` | `optional(left; right)` | [RxRepeatOperands\optional](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/operands.lmx), строка 77 |
| `seq\findFirst` | `default` | `findFirst(items; accepts)` | [FxFindFirst\findFirst](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreComparisonGroups.lmx), строка 11 |
| `call\allOf` | `default` | `allOf(predicates; contract=0)` | [FxAllOf\allOf](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreComparisonGroups.lmx), строка 83 |
| `graph\equalFields` | `default` | `equalFields(first; second; same=0)` | [FxEqualFields\equalFields](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreComparisonGroups.lmx), строка 35 |
| `message\retryPost` | `default` | `retryPost(request; retryOn; attempts; delay; firstDelay; maxDelay; timeoutMs; complete)` | [FxRetryPost\retryPost](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreComparisonGroups.lmx), строка 337 |
| `call\between` | `default` | `between(left; right)` | [FxBetween\between](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreComparisonExamples.lmx), строка 10 |
| `call\iterateUntilStop` | `default` | `iterateUntilStop(iteration; body)` | [FxIterateUntilStop\iterateUntilStop](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreComparisonExamples.lmx), строка 25 |
| `seq\sort` | `default` | `sort(items; compare)` | [FxSort\sort](../../../docs/spec/patterns/LMX_Fn_Receivers/src/corePerlExamples.lmx), строка 17 |
| `seq\unique` | `default` | `unique(items; same=0)` | [FxUnique\unique](../../../docs/spec/patterns/LMX_Fn_Receivers/src/corePerlExamples.lmx), строка 80 |
| `seq\take` | `default` | `take(items; count)` | [FxStdCut\take](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 42 |
| `seq\drop` | `default` | `drop(items; count)` | [FxStdCut\drop](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 45 |
| `seq\splitAt` | `default` | `splitAt(items; count)` | [FxStdCut\splitAt](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 48 |
| `seq\takeWhile` | `default` | `takeWhile(items; accepts)` | [FxStdPrefix\takeWhile](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 77 |
| `seq\dropWhile` | `default` | `dropWhile(items; accepts)` | [FxStdPrefix\dropWhile](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 80 |
| `seq\span` | `default` | `span(items; accepts)` | [FxStdPrefix\span](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 83 |
| `seq\partition` | `default` | `partition(items; accepts)` | [FxStdPartition\partition](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 93 |
| `seq\enumerate` | `default` | `enumerate(items; start=0)` | [FxStdEnumerate\enumerate](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 114 |
| `seq\windows` | `default` | `windows(items; width=2; step=1; partial=0)` | [FxStdWindows\windows](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 140 |
| `seq\chunks` | `default` | `chunks(items; size; strict=0)` | [FxStdChunks\chunks](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 168 |
| `seq\intersperse` | `default` | `intersperse(items; separatorRecord)` | [FxStdIntersperse\intersperse](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 183 |
| `seq\join` | `Array` | `join(parts; separator)` | [FxStdJoin\join](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 212 |
| `text\join` | `text` | `join(parts; separator)` | [FxTextJoin\join](../../../docs/spec/patterns/LMX_Fn_Receivers/src/sequence_profiles.lmx), строка 111 |
| `seq\unzip` | `default` | `unzip(pairs)` | [FxStdUnzip\unzip](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 225 |
| `seq\foldr` | `default` | `foldr(items; seedRecord; step)` | [FxStdRightFold\foldr](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 247 |
| `seq\scanr` | `default` | `scanr(items; seedRecord; step)` | [FxStdRightFold\scanr](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 250 |
| `seq\filterMap` | `default` | `filterMap(items; transform)` | [FxStdMaybeMap\filterMap](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 292 |
| `seq\mapWhile` | `default` | `mapWhile(items; transform)` | [FxStdMaybeMap\mapWhile](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 295 |
| `seq\findMap` | `default` | `findMap(items; transform)` | [FxStdMaybeMap\findMap](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 298 |
| `seq\mapAccumL` | `default` | `mapAccumL(items; seedRecord; step)` | [FxStdMapAccum\mapAccumL](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 337 |
| `seq\mapAccumR` | `default` | `mapAccumR(items; seedRecord; step)` | [FxStdMapAccum\mapAccumR](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 340 |
| `seq\groupAdjacent` | `default` | `groupAdjacent(items; keyOf=0; sameKey=0)` | [FxStdGroupAdjacent\groupAdjacent](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 353 |
| `seq\replicate` | `default` | `replicate(valueRecord; count)` | [FxStdReplicate\replicate](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 385 |
| `seq\cycle` | `default` | `cycle(items; count; rejectNegative=0)` | [FxStdCycle\cycle](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 404 |
| `text\cycle` | `text` | `cycle(items; count; rejectNegative=0)` | [FxTextCycle\cycle](../../../docs/spec/patterns/LMX_Fn_Receivers/src/sequence_profiles.lmx), строка 122 |
| `seq\starmap` | `default` | `starmap(rows; operation)` | [FxStdStarMap\starmap](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 421 |
| `seq\zipLongest` | `default` | `zipLongest(first; second; fillRecord)` | [FxStdZipLongest\zipLongest](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 439 |
| `seq\collect` | `default` | `collect(next; limit=-1)` | [FxStdCollect\collect](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 468 |
| `seq\includes` | `default` | `includes(items; valueRecord; same=0)` | [FxStdMembership\includes](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 491 |
| `seq\adjoin` | `default` | `adjoin(items; valueRecord; same=0)` | [FxStdAdjoin\adjoin](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 502 |
| `seq\union` | `default` | `union(first; second; same=0)` | [FxStdSets\union](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 538 |
| `seq\intersection` | `default` | `intersection(first; second; same=0)` | [FxStdSets\intersection](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 541 |
| `seq\difference` | `default` | `difference(first; second; same=0)` | [FxStdSets\difference](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 544 |
| `seq\symmetricDifference` | `default` | `symmetricDifference(first; second; same=0)` | [FxStdSets\symmetricDifference](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 547 |
| `seq\isSubset` | `default` | `isSubset(first; second; same=0)` | [FxStdSubset\isSubset](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx), строка 558 |
| `maybe\mapOption` | `default` | `mapOption(input; transform)` | [FxMapOption\mapOption](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardObjects.lmx), строка 13 |
| `maybe\filterOption` | `default` | `filterOption(input; accepts)` | [FxFilterOption\filterOption](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardObjects.lmx), строка 26 |
| `maybe\orElse` | `default` | `orElse(input; fallback)` | [FxOrElse\orElse](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardObjects.lmx), строка 43 |
| `maybe\orElseGet` | `default` | `orElseGet(input; fallback)` | [FxOrElseGet\orElseGet](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardObjects.lmx), строка 54 |
| `maybe\orElseOption` | `default` | `orElseOption(input; fallback)` | [FxOrElseOption\orElseOption](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardObjects.lmx), строка 68 |
| `maybe\foldOption` | `default` | `foldOption(input; whenEmpty; whenPresent)` | [FxFoldOption\foldOption](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardObjects.lmx), строка 85 |
| `maybe\flattenOption` | `default` | `flattenOption(input)` | [FxFlattenOption\flattenOption](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardObjects.lmx), строка 94 |
| `result\mapResult` | `default` | `mapResult(input; transform)` | [FxMapResult\mapResult](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardObjects.lmx), строка 106 |
| `result\mapErr` | `default` | `mapErr(input; transform)` | [FxMapErr\mapErr](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardObjects.lmx), строка 119 |
| `result\orElseResult` | `default` | `orElseResult(input; fallback)` | [FxOrElseResult\orElseResult](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardObjects.lmx), строка 134 |
| `result\foldResult` | `default` | `foldResult(input; onError; onSuccess)` | [FxFoldResult\foldResult](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardObjects.lmx), строка 149 |
| `result\attempt` | `default` | `attempt(operation; args=())` | [FxAttemptResult\attempt](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardObjects.lmx), строка 171 |
| `call\tap` | `default` | `tap(value; action)` | [FxTap\tap](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardObjects.lmx), строка 187 |
| `seq\findField` | `default` | `findField(source; label; occurrence)` | [FxFindField\findField](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardObjects.lmx), строка 205 |
| `seq\hasField` | `default` | `hasField(source; label; occurrence)` | [FxHasField\hasField](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardObjects.lmx), строка 226 |
| `seq\getField` | `default` | `getField(source; label; occurrence)` | [FxGetField\getField](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardObjects.lmx), строка 234 |
| `graph\assoc` | `default` | `assoc(rows; key; same=0; keyIndex=0)` | [FxAssoc\assoc](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardLisp.lmx), строка 63 |
| `graph\pairlis` | `default` | `pairlis(keys; values; tail=())` | [FxPairlis\pairlis](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardLisp.lmx), строка 79 |
| `graph\getProperty` | `default` | `getProperty(properties; key; same=0)` | [FxGetProperty\getProperty](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardLisp.lmx), строка 94 |
| `graph\setProperty` | `default` | `setProperty(properties; key; value; same=0)` | [FxSetProperty\setProperty](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardLisp.lmx), строка 109 |
| `graph\removeProperty` | `default` | `removeProperty(properties; key; same=0)` | [FxRemoveProperty\removeProperty](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardLisp.lmx), строка 124 |
| `graph\getProperties` | `default` | `getProperties(properties; indicators; same=0)` | [FxGetProperties\getProperties](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardLisp.lmx), строка 144 |
| `graph\asOperand` | `default` | `asOperand(operation; priority)` | [FxAsOperand\asOperand](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardLisp.lmx), строка 294 |
| `graph\mismatch` | `default` | `mismatch(first; second; same=0)` | [FxMismatch\mismatch](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardLisp.lmx), строка 200 |
| `graph\searchSequence` | `default` | `searchSequence(items; pattern; same=0; start=0)` | [FxSearchSequence\searchSequence](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardLisp.lmx), строка 222 |
| `graph\substitute` | `default` | `substitute(items; oldValue; newValue; same=0)` | [FxSubstitute\substitute](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardLisp.lmx), строка 241 |
| `text\indexOf` | `default` | `indexOf(text; part; start=0; same=0)` | [FxIndexOf\indexOf](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardText.lmx), строка 51 |
| `text\lastIndexOf` | `default` | `lastIndexOf(text; part; start=length(text); same=0)` | [FxLastIndexOf\lastIndexOf](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardText.lmx), строка 63 |
| `text\compare` | `default` | `compare(first; second; order=0)` | [FxCompare\compare](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardText.lmx), строка 104 |
| `text\trim` | `default` | `trim(text; chars; predicate=0; same=0) / text profile supplies whitespace` | [FxTrim\trim](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardText.lmx), строка 173 |
| `text\trim` | `text` | `trim(text; chars; predicate=0; same=0) / text profile supplies whitespace` | [FxTextTrim\trim](../../../docs/spec/patterns/LMX_Fn_Receivers/src/sequence_profiles.lmx), строка 81 |
| `text\trimStart` | `default` | `trimStart(text; chars; predicate=0; same=0) / text profile supplies whitespace` | [FxTrimStart\trim](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardText.lmx), строка 179 |
| `text\trimStart` | `text` | `trimStart(text; chars; predicate=0; same=0) / text profile supplies whitespace` | [FxTextTrim\trimStart](../../../docs/spec/patterns/LMX_Fn_Receivers/src/sequence_profiles.lmx), строка 84 |
| `text\trimEnd` | `default` | `trimEnd(text; chars; predicate=0; same=0) / text profile supplies whitespace` | [FxTrimEnd\trim](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardText.lmx), строка 185 |
| `text\trimEnd` | `text` | `trimEnd(text; chars; predicate=0; same=0) / text profile supplies whitespace` | [FxTextTrim\trimEnd](../../../docs/spec/patterns/LMX_Fn_Receivers/src/sequence_profiles.lmx), строка 87 |
| `text\padLeft` | `default` | `padLeft(text; width; fill) / text profile supplies space` | [FxPadLeft\pad](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardText.lmx), строка 225 |
| `text\padLeft` | `text` | `padLeft(text; width; fill) / text profile supplies space` | [FxTextPad\padLeft](../../../docs/spec/patterns/LMX_Fn_Receivers/src/sequence_profiles.lmx), строка 98 |
| `text\padRight` | `default` | `padRight(text; width; fill) / text profile supplies space` | [FxPadRight\pad](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardText.lmx), строка 231 |
| `text\padRight` | `text` | `padRight(text; width; fill) / text profile supplies space` | [FxTextPad\padRight](../../../docs/spec/patterns/LMX_Fn_Receivers/src/sequence_profiles.lmx), строка 101 |
| `text\translate` | `default` | `translate(text; from; to; same=0)` | [FxTranslate\translate](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardText.lmx), строка 243 |
| `text\format` | `default` | `format(value; base=10) / format(value; profile; arguments=())` | [FxFormat\format](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardText.lmx), строка 312 |
| `seq\format` | `profile` | `format(value; base=10) / format(value; profile; arguments=())` | [FxProfileFormat\format](../../../docs/spec/patterns/LMX_Fn_Receivers/src/sequence_profiles.lmx), строка 56 |
| `text\parse` | `default` | `parse(text; base=10) / parse(source; profile; arguments=())` | [FxParse\parse](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardText.lmx), строка 341 |
| `seq\parse` | `profile` | `parse(text; base=10) / parse(source; profile; arguments=())` | [FxProfileParse\parse](../../../docs/spec/patterns/LMX_Fn_Receivers/src/sequence_profiles.lmx), строка 67 |
| `text\removePrefix` | `default` | `removePrefix(text; affix; same=0)` | [FxRemovePrefix\remove](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardText.lmx), строка 295 |
| `text\removeSuffix` | `default` | `removeSuffix(text; affix; same=0)` | [FxRemoveSuffix\remove](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardText.lmx), строка 301 |
| `math\sum` | `default` | `sum(items; initial=(0 record))` | [FxSum\sum](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardNumeric.lmx), строка 14 |
| `math\product` | `default` | `product(items; initial=(1 record))` | [FxProduct\product](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardNumeric.lmx), строка 23 |
| `math\minimum` | `default` | `minimum(items)` | [FxMinimum\minimum](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardNumeric.lmx), строка 52 |
| `math\maximum` | `default` | `maximum(items)` | [FxMaximum\maximum](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardNumeric.lmx), строка 60 |
| `math\argMin` | `default` | `argMin(items)` | [FxArgMin\argMin](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardNumeric.lmx), строка 68 |
| `math\argMax` | `default` | `argMax(items)` | [FxArgMax\argMax](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardNumeric.lmx), строка 76 |
| `math\extrema` | `default` | `extrema(items)` | [FxExtrema\extrema](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardNumeric.lmx), строка 84 |
| `math\min` | `default` | `min(first; second)` | [FxMin\min](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardNumeric.lmx), строка 105 |
| `math\max` | `default` | `max(first; second)` | [FxMax\max](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardNumeric.lmx), строка 113 |
| `math\minMax` | `default` | `minMax(first; second)` | [FxMinMax\minMax](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardNumeric.lmx), строка 121 |
| `math\clamp` | `default` | `clamp(value; lower; upper)` | [FxClamp\clamp](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardNumeric.lmx), строка 132 |
| `math\sign` | `default` | `sign(value)` | [FxSign\sign](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardNumeric.lmx), строка 141 |
| `math\gcd` | `default` | `gcd(first; second)` | [FxGcd\gcd](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardNumeric.lmx), строка 151 |
| `math\lcm` | `default` | `lcm(first; second)` | [FxLcm\lcm](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardNumeric.lmx), строка 167 |
| `math\divMod` | `default` | `divMod(dividend; divisor)` | [FxDivMod\divMod](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreStandardNumeric.lmx), строка 181 |
| `graph\type` | `default` | `type(value)` | [FxValueType\type](../../../docs/spec/patterns/LMX_Fn_Receivers/src/operation_forms.lmx), строка 25 |
| `pattern\arrayView` | `default` | `arrayView(items)` | [RxArrayView\arrayView](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/source.lmx), строка 24 |
| `pattern\element` | `default` | `element(value)` | [RxElement\element](../../../docs/spec/patterns/LMX_Fn_Receivers/src/regex/primitives.lmx), строка 427 |
| `call\equals` | `default` | `equals(first; second; projection=0; same=0)` | [FxEquals\equals](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreGenericOperations.lmx), строка 25 |
| `call\pipe` | `default` | `pipe(value; stages)` | [FxPipe\pipe](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreGenericOperations.lmx), строка 37 |
| `call\retry` | `default` | `retry(operation; retryOn; limit; delay=0; arguments=())` | [FxRetryValue\retry](../../../docs/spec/patterns/LMX_Fn_Receivers/src/coreGenericOperations.lmx), строка 100 |
| `seq\fill` | `default` | `fill(target; valueRecord)` | [FxArrayFill\fill](../../../docs/spec/patterns/LMX_Fn_Receivers/src/fill.lmx), строка 7 |
| `seq\lowerBound` | `default` | `lowerBound(items; needleRecord; less)` | [FxLowerBound\lowerBound](../../../docs/spec/patterns/LMX_Fn_Receivers/src/lowerBound.lmx), строка 8 |
| `seq\last` | `default` | `last(items; count)` | [FxSeqLast\last](../../../docs/spec/patterns/LMX_Fn_Receivers/src/last.lmx), строка 7 |
