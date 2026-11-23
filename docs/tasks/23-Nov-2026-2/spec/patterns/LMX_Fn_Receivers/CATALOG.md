# Прямые публичные ресиверы и Expression-операнды

Редакция 2026-11-23. Сохранены все 123 вызовных имён загруженного комплекта 23-Nov и добавлены 89 функций по сопоставлению операторов и стандартных библиотек, включая случаи вне примеров. Всего 212 уникальных публичных имён lowerCamelCase.

Все имена входят в единое ядро и доступны напрямую; собственные DATA и фактический parent каждого метода сохраняются. Клиентский import не требуется.
`BODY` — LMX-алгоритм; `BODY_WITH_BRIDGE` — LMX-алгоритм с явно указанным интерфейсом ядра. Это не отметка запуска.

`replaceRange` меняет диапазон и возвращает target; `splice` возвращает удалённые элементы в отдельном контейнере. Текстовый `replace` возвращает новый текст. `hasPrefix` и `hasSuffix` проверяют соответствующую границу и возвращают int 1/0.

| № | Имя | Прежнее имя | Вызов | Исходник | Статус |
|---|---|---|---|---|---|
| 1 | `types` | types | `types(source)` | [src/reflection.lmx](src/reflection.lmx) | BODY |
| 2 | `names` | names | `names(source)` | [src/reflection_bridges.lmx](src/reflection_bridges.lmx) | BODY_WITH_BRIDGE |
| 3 | `signature` | signature | `signature(operation)` | [src/reflection_bridges.lmx](src/reflection_bridges.lmx) | BODY_WITH_BRIDGE |
| 4 | `signatureTypes` | fn | `R signatureTypes T0 ... TN; explicit fun\const\signatureTypes(left := R; right := types)` | [src/fn_operand.lmx](src/fn_operand.lmx) | BODY_WITH_BRIDGE |
| 5 | `curry` | lambda | `curry(operation)` | [src/generic_functions.lmx](src/generic_functions.lmx) | BODY_WITH_BRIDGE |
| 6 | `apply` | apply | `apply(operation; args)` | [src/generic_runtime.lmx](src/generic_runtime.lmx) | BODY_WITH_BRIDGE |
| 7 | `partial` | partial | `partial(operation; prefix)` | [src/generic_functions.lmx](src/generic_functions.lmx) | BODY_WITH_BRIDGE |
| 8 | `uncurry` | uncurry | `uncurry(operation; contract; failures)` | [src/generic_functions.lmx](src/generic_functions.lmx) | BODY_WITH_BRIDGE |
| 9 | `flip` | flip | `flip(operation)` | [src/generic_functions.lmx](src/generic_functions.lmx) | BODY_WITH_BRIDGE |
| 10 | `compose` | compose | `compose(outer; inner)` | [src/generic_combinators.lmx](src/generic_combinators.lmx) | BODY_WITH_BRIDGE |
| 11 | `pipe` | pipe | `pipe(first; second)` | [src/generic_combinators.lmx](src/generic_combinators.lmx) | BODY_WITH_BRIDGE |
| 12 | `identity` | identity | `identity(typeToken)` | [src/generic_combinators.lmx](src/generic_combinators.lmx) | BODY_WITH_BRIDGE |
| 13 | `map` | map | `map(items; transform)` | [src/collections.lmx](src/collections.lmx) | BODY_WITH_BRIDGE |
| 14 | `filter` | filter | `filter(items; accepts)` | [src/collections.lmx](src/collections.lmx) | BODY_WITH_BRIDGE |
| 15 | `foldl` | fold | `foldl(items; seed; step)` | [src/collections.lmx](src/collections.lmx) | BODY_WITH_BRIDGE |
| 16 | `zip` | zip | `zip(first; second)` | [src/collections.lmx](src/collections.lmx) | BODY_WITH_BRIDGE |
| 17 | `zipWith` | zipWith | `zipWith(first; second; combine)` | [src/collections.lmx](src/collections.lmx) | BODY_WITH_BRIDGE |
| 18 | `scanl` | scan | `scanl(items; seed; step)` | [src/collections.lmx](src/collections.lmx) | BODY_WITH_BRIDGE |
| 19 | `bind` | bind | `bind(input; next)` | [src/containers.lmx](src/containers.lmx) | BODY_WITH_BRIDGE |
| 20 | `traverse` | traverse | `traverse(items; next)` | [src/collections.lmx](src/collections.lmx) | BODY_WITH_BRIDGE |
| 21 | `memoize` | memo | `memoize(operation; sameKey)` | [src/generic_combinators.lmx](src/generic_combinators.lmx) | BODY_WITH_BRIDGE |
| 22 | `fix` | fix | `fix(operation)` | [src/generic_combinators.lmx](src/generic_combinators.lmx) | BODY_WITH_BRIDGE |
| 23 | `select` | select | `select(source; indices)` | [src/structures.lmx](src/structures.lmx) | BODY |
| 24 | `omit` | omit | `omit(source; indices)` | [src/structures.lmx](src/structures.lmx) | BODY |
| 25 | `rename` | rename | `rename(source; indices; labels)` | [src/reflection_bridges.lmx](src/reflection_bridges.lmx) | BODY_WITH_BRIDGE |
| 26 | `reorder` | reorder | `reorder(source; permutation)` | [src/structures.lmx](src/structures.lmx) | BODY |
| 27 | `project` | project | `project(source; indices)` | [src/structures.lmx](src/structures.lmx) | BODY |
| 28 | `defaults` | defaults | `defaults(source; fallback)` | [src/structures.lmx](src/structures.lmx) | BODY |
| 29 | `diff` | diff | `diff(before; after)` | [src/structures.lmx](src/structures.lmx) | BODY |
| 30 | `patch` | patch | `patch(source; change)` | [src/structures.lmx](src/structures.lmx) | BODY |
| 31 | `bindFields` | bindFields | `bindFields(operation; bindings)` | [src/structures.lmx](src/structures.lmx) | BODY |
| 32 | `derive` | derive | `derive(base; extension)` | [src/structures.lmx](src/structures.lmx) | BODY |
| 33 | `transpose` | transpose | `transpose(rows)` | [src/collections.lmx](src/collections.lmx) | BODY_WITH_BRIDGE |
| 34 | `groupBy` | groupby | `groupBy(items; keyOf; sameKey)` | [src/collections.lmx](src/collections.lmx) | BODY_WITH_BRIDGE |
| 35 | `lazy` | lazy | `lazy(operation)` | [src/generic_wrappers.lmx](src/generic_wrappers.lmx) | BODY_WITH_BRIDGE |
| 36 | `force` | force | `force(thunk)` | [src/generic_wrappers.lmx](src/generic_wrappers.lmx) | BODY_WITH_BRIDGE |
| 37 | `once` | once | `once(operation)` | [src/generic_wrappers.lmx](src/generic_wrappers.lmx) | BODY_WITH_BRIDGE |
| 38 | `repeat` | repeat | `repeat(operation; count; args=())` | [src/generic_wrappers.lmx](src/generic_wrappers.lmx) | BODY_WITH_BRIDGE |
| 39 | `runUntil` | until | `runUntil(step; finished; initial)` | [src/generic_wrappers.lmx](src/generic_wrappers.lmx) | BODY_WITH_BRIDGE |
| 40 | `retryCall` | retry | `retryCall(operation; attempts; args=())` | [src/generic_wrappers.lmx](src/generic_wrappers.lmx) | BODY_WITH_BRIDGE |
| 41 | `bracket` | around | `bracket(acquire; release; action; arguments=())` | [src/generic_wrappers.lmx](src/generic_wrappers.lmx) | BODY_WITH_BRIDGE |
| 42 | `recover` | recover | `recover(operation; handler)` | [src/generic_wrappers.lmx](src/generic_wrappers.lmx) | BODY_WITH_BRIDGE |
| 43 | `adapter` | adapter | `adapter(operation; before; after; contract)` | [src/generic_combinators.lmx](src/generic_combinators.lmx) | BODY_WITH_BRIDGE |
| 44 | `permute` | permute | `permute(operation; permutation)` | [src/generic_combinators.lmx](src/generic_combinators.lmx) | BODY_WITH_BRIDGE |
| 45 | `overload` | overload | `overload(candidates; accepts; contract)` | [src/generic_combinators.lmx](src/generic_combinators.lmx) | BODY_WITH_BRIDGE |
| 46 | `predicate` | predicate | `predicate(operation)` | [src/generic_combinators.lmx](src/generic_combinators.lmx) | BODY_WITH_BRIDGE |
| 47 | `guard` | guard | `guard(operation; accepts)` | [src/generic_combinators.lmx](src/generic_combinators.lmx) | BODY_WITH_BRIDGE |
| 48 | `trace` | trace | `trace(operation; sink)` | [src/generic_wrappers.lmx](src/generic_wrappers.lmx) | BODY_WITH_BRIDGE |
| 49 | `contract` | contract | `contract(operation; pre; post)` | [src/generic_combinators.lmx](src/generic_combinators.lmx) | BODY_WITH_BRIDGE |
| 50 | `composeData` | composeData | `composeData(code; overlay)` | [src/structures.lmx](src/structures.lmx) | BODY |
| 51 | `record` | record | `record(left; right=())` | [src/generic_functions.lmx](src/generic_functions.lmx) | BODY |
| 52 | `some` | some | `some(value)` | [src/containers.lmx](src/containers.lmx) | BODY |
| 53 | `none` | none | `none()` | [src/containers.lmx](src/containers.lmx) | BODY |
| 54 | `ok` | ok | `ok(value)` | [src/containers.lmx](src/containers.lmx) | BODY |
| 55 | `err` | err | `err(reason)` | [src/containers.lmx](src/containers.lmx) | BODY |
| 56 | `bindResult` | bindResult | `bindResult(input; next)` | [src/containers.lmx](src/containers.lmx) | BODY_WITH_BRIDGE |
| 57 | `list` | list | `list(values)` | [src/containers.lmx](src/containers.lmx) | BODY |
| 58 | `flatMap` | flatmap | `flatMap(items; next)` | [src/containers.lmx](src/containers.lmx) | BODY_WITH_BRIDGE |
| 59 | `done` | done | `done(value)` | [src/containers.lmx](src/containers.lmx) | BODY |
| 60 | `more` | more | `more(thunk)` | [src/containers.lmx](src/containers.lmx) | BODY_WITH_BRIDGE |
| 61 | `trampoline` | trampoline | `trampoline(current)` | [src/containers.lmx](src/containers.lmx) | BODY_WITH_BRIDGE |
| 62 | `range` | новое | `range(start; stop; step=1)` | [src/sequences.lmx](src/sequences.lmx) | BODY_WITH_BRIDGE |
| 63 | `slice` | новое | `slice(source; begin; end)` | [src/sequences.lmx](src/sequences.lmx) | BODY_WITH_BRIDGE |
| 64 | `reverse` | reversed | `reverse(source)` | [src/sequences.lmx](src/sequences.lmx) | BODY_WITH_BRIDGE |
| 65 | `concat` | новое | `concat(parts)` | [src/sequences.lmx](src/sequences.lmx) | BODY_WITH_BRIDGE |
| 66 | `compress` | selectMask | `compress(source; mask)` | [src/sequences.lmx](src/sequences.lmx) | BODY_WITH_BRIDGE |
| 67 | `any` | anyMatch | `any(items; accepts)` | [src/sequences.lmx](src/sequences.lmx) | BODY_WITH_BRIDGE |
| 68 | `all` | allMatch | `all(items; accepts)` | [src/sequences.lmx](src/sequences.lmx) | BODY_WITH_BRIDGE |
| 69 | `index` | findIndex | `index(items; accepts)` | [src/sequences.lmx](src/sequences.lmx) | BODY_WITH_BRIDGE |
| 70 | `count` | countWhere | `count(items; accepts)` | [src/sequences.lmx](src/sequences.lmx) | BODY_WITH_BRIDGE |
| 71 | `replaceRange` | splice | `replaceRange(target; begin; end; values)` | [src/sequences_mutation.lmx](src/sequences_mutation.lmx) | BODY_WITH_BRIDGE |
| 72 | `splice` | новое | `splice(target; begin; end; values)` | [src/sequences_mutation.lmx](src/sequences_mutation.lmx) | BODY_WITH_BRIDGE |
| 73 | `append` | appendTo | `append(target; values)` | [src/sequences_mutation.lmx](src/sequences_mutation.lmx) | BODY_WITH_BRIDGE |
| 74 | `insert` | insertInto | `insert(target; position; values)` | [src/sequences_mutation.lmx](src/sequences_mutation.lmx) | BODY_WITH_BRIDGE |
| 75 | `deleteAt` | deleteat | `deleteAt(target; begin; end)` | [src/sequences_mutation.lmx](src/sequences_mutation.lmx) | BODY_WITH_BRIDGE |
| 76 | `literal` | новое | `literal(text)` | [src/regex/primitives.lmx](src/regex/primitives.lmx) | BODY_WITH_BRIDGE |
| 77 | `oneOf` | oneof | `oneOf(text)` | [src/regex/primitives.lmx](src/regex/primitives.lmx) | BODY_WITH_BRIDGE |
| 78 | `noneOf` | noneof | `noneOf(text)` | [src/regex/primitives.lmx](src/regex/primitives.lmx) | BODY_WITH_BRIDGE |
| 79 | `charRange` | новое | `charRange(first; last)` | [src/regex/primitives.lmx](src/regex/primitives.lmx) | BODY_WITH_BRIDGE |
| 80 | `satisfy` | charWhere | `satisfy(predicate)` | [src/regex/primitives.lmx](src/regex/primitives.lmx) | BODY_WITH_BRIDGE |
| 81 | `boundaryOf` | новое | `boundaryOf(predicate)` | [src/regex/primitives.lmx](src/regex/primitives.lmx) | BODY_WITH_BRIDGE |
| 82 | `sameAs` | backref | `sameAs(name)` | [src/regex/primitives.lmx](src/regex/primitives.lmx) | BODY_WITH_BRIDGE |
| 83 | `sequence` | новое | `sequence(patterns)` | [src/regex/combinators.lmx](src/regex/combinators.lmx) | BODY_WITH_BRIDGE |
| 84 | `choice` | новое | `choice(patterns)` | [src/regex/combinators.lmx](src/regex/combinators.lmx) | BODY_WITH_BRIDGE |
| 85 | `repeated` | новое | `repeated(pattern; minimum=0; maximum=unbounded; order=extendFirst)` | [src/regex/combinators.lmx](src/regex/combinators.lmx) | BODY_WITH_BRIDGE |
| 86 | `atomic` | новое | `atomic(pattern)` | [src/regex/combinators.lmx](src/regex/combinators.lmx) | BODY_WITH_BRIDGE |
| 87 | `capture` | новое | `capture(name; pattern)` | [src/regex/combinators.lmx](src/regex/combinators.lmx) | BODY_WITH_BRIDGE |
| 88 | `ahead` | lookahead | `ahead(pattern)` | [src/regex/combinators.lmx](src/regex/combinators.lmx) | BODY_WITH_BRIDGE |
| 89 | `notAhead` | negative_lookahead | `notAhead(pattern)` | [src/regex/combinators.lmx](src/regex/combinators.lmx) | BODY_WITH_BRIDGE |
| 90 | `behind` | lookbehind | `behind(pattern)` | [src/regex/combinators.lmx](src/regex/combinators.lmx) | BODY_WITH_BRIDGE |
| 91 | `notBehind` | negative_lookbehind | `notBehind(pattern)` | [src/regex/combinators.lmx](src/regex/combinators.lmx) | BODY_WITH_BRIDGE |
| 92 | `utf8Text` | новое | `utf8Text(source)` | [src/regex/text.lmx](src/regex/text.lmx) | BODY_WITH_BRIDGE |
| 93 | `byteText` | новое | `byteText(source)` | [src/regex/text.lmx](src/regex/text.lmx) | BODY_WITH_BRIDGE |
| 94 | `matchAt` | новое | `matchAt(source; pattern; position)` | [src/regex/operations.lmx](src/regex/operations.lmx) | BODY_WITH_BRIDGE |
| 95 | `wholeMatch` | fullmatch | `wholeMatch(source; pattern)` | [src/regex/operations.lmx](src/regex/operations.lmx) | BODY_WITH_BRIDGE |
| 96 | `find` | новое | `find(source; pattern)` | [src/regex/operations.lmx](src/regex/operations.lmx) | BODY_WITH_BRIDGE |
| 97 | `eachMatch` | eachmatch | `eachMatch(source; pattern)` | [src/regex/operations.lmx](src/regex/operations.lmx) | BODY_WITH_BRIDGE |
| 98 | `contains` | новое | `contains(source; pattern)` | [src/regex/operations.lmx](src/regex/operations.lmx) | BODY_WITH_BRIDGE |
| 99 | `hasPrefix` | новое | `hasPrefix(source; pattern)` | [src/regex/operations.lmx](src/regex/operations.lmx) | BODY_WITH_BRIDGE |
| 100 | `hasSuffix` | новое | `hasSuffix(source; pattern)` | [src/regex/operations.lmx](src/regex/operations.lmx) | BODY_WITH_BRIDGE |
| 101 | `matches` | новое | `matches(source; pattern)` | [src/regex/operations.lmx](src/regex/operations.lmx) | BODY_WITH_BRIDGE |
| 102 | `matchedSpan` | новое | `matchedSpan(result)` | [src/regex/operations.lmx](src/regex/operations.lmx) | BODY_WITH_BRIDGE |
| 103 | `matchedText` | новое | `matchedText(result)` | [src/regex/operations.lmx](src/regex/operations.lmx) | BODY_WITH_BRIDGE |
| 104 | `captureSpans` | новое | `captureSpans(result; name)` | [src/regex/operations.lmx](src/regex/operations.lmx) | BODY_WITH_BRIDGE |
| 105 | `lastCapture` | новое | `lastCapture(result; name)` | [src/regex/operations.lmx](src/regex/operations.lmx) | BODY_WITH_BRIDGE |
| 106 | `captureText` | новое | `captureText(result; name)` | [src/regex/operations.lmx](src/regex/operations.lmx) | BODY_WITH_BRIDGE |
| 107 | `captureTexts` | новое | `captureTexts(result; name)` | [src/regex/operations.lmx](src/regex/operations.lmx) | BODY_WITH_BRIDGE |
| 108 | `replaceFirst` | новое | `replaceFirst(source; pattern; replacement)` | [src/regex/operations.lmx](src/regex/operations.lmx) | BODY_WITH_BRIDGE |
| 109 | `replace` | replaceAll | `replace(source; pattern; replacement)` | [src/regex/operations.lmx](src/regex/operations.lmx) | BODY_WITH_BRIDGE |
| 110 | `split` | splitBy | `split(source; pattern)` | [src/regex/operations.lmx](src/regex/operations.lmx) | BODY_WITH_BRIDGE |
| 111 | `then` | новое | `then(left; right)` | [src/regex/operands.lmx](src/regex/operands.lmx) | BODY_WITH_BRIDGE |
| 112 | `times` | новое | `times(left; right)` | [src/regex/operands.lmx](src/regex/operands.lmx) | BODY_WITH_BRIDGE |
| 113 | `atLeast` | новое | `atLeast(left; right)` | [src/regex/operands.lmx](src/regex/operands.lmx) | BODY_WITH_BRIDGE |
| 114 | `atMost` | новое | `atMost(left; right)` | [src/regex/operands.lmx](src/regex/operands.lmx) | BODY_WITH_BRIDGE |
| 115 | `optional` | новое | `optional(left; right)` | [src/regex/operands.lmx](src/regex/operands.lmx) | BODY_WITH_BRIDGE |
| 116 | `findFirst` | новое | `findFirst(items; accepts)` | [src/coreComparisonGroups.lmx](src/coreComparisonGroups.lmx) | BODY_WITH_BRIDGE |
| 117 | `allOf` | новое | `allOf(predicates; contract=0)` | [src/coreComparisonGroups.lmx](src/coreComparisonGroups.lmx) | BODY_WITH_BRIDGE |
| 118 | `equalFields` | новое | `equalFields(first; second; same)` | [src/coreComparisonGroups.lmx](src/coreComparisonGroups.lmx) | BODY_WITH_BRIDGE |
| 119 | `retryPost` | новое | `retryPost(request; retryOn; attempts; delay; firstDelay; maxDelay; timeoutMs; complete)` | [src/coreComparisonGroups.lmx](src/coreComparisonGroups.lmx) | BODY_WITH_BRIDGE |
| 120 | `between` | новое | `between(left; right)` | [src/coreComparisonExamples.lmx](src/coreComparisonExamples.lmx) | BODY |
| 121 | `iterateUntilStop` | новое | `iterateUntilStop(iteration; body)` | [src/coreComparisonExamples.lmx](src/coreComparisonExamples.lmx) | BODY_WITH_BRIDGE |
| 122 | `sort` | новое | `sort(items; compare)` | [src/corePerlExamples.lmx](src/corePerlExamples.lmx) | BODY_WITH_BRIDGE |
| 123 | `unique` | новое | `unique(items; same)` | [src/corePerlExamples.lmx](src/corePerlExamples.lmx) | BODY_WITH_BRIDGE |
| 124 | `take` | новое | `take(items; count)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 125 | `drop` | новое | `drop(items; count)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 126 | `splitAt` | новое | `splitAt(items; count)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 127 | `takeWhile` | новое | `takeWhile(items; accepts)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 128 | `dropWhile` | новое | `dropWhile(items; accepts)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 129 | `span` | новое | `span(items; accepts)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 130 | `partition` | новое | `partition(items; accepts)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 131 | `enumerate` | новое | `enumerate(items; start=0)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 132 | `windows` | новое | `windows(items; width=2; step=1; partial=0)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 133 | `chunks` | новое | `chunks(items; size; strict=0)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 134 | `intersperse` | новое | `intersperse(items; separatorRecord)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 135 | `intercalate` | новое | `intercalate(parts; separator)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 136 | `unzip` | новое | `unzip(pairs)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 137 | `foldr` | новое | `foldr(items; seedRecord; step)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 138 | `scanr` | новое | `scanr(items; seedRecord; step)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 139 | `filterMap` | новое | `filterMap(items; transform)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 140 | `mapWhile` | новое | `mapWhile(items; transform)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 141 | `findMap` | новое | `findMap(items; transform)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 142 | `mapAccumL` | новое | `mapAccumL(items; seedRecord; step)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 143 | `mapAccumR` | новое | `mapAccumR(items; seedRecord; step)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 144 | `groupAdjacent` | новое | `groupAdjacent(items; keyOf; sameKey)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 145 | `replicate` | новое | `replicate(valueRecord; count)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 146 | `cycle` | новое | `cycle(items; count)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 147 | `starmap` | новое | `starmap(rows; operation)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 148 | `zipLongest` | новое | `zipLongest(first; second; fillRecord)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 149 | `collect` | новое | `collect(next; limit=-1)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 150 | `includes` | новое | `includes(items; valueRecord; same)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 151 | `adjoin` | новое | `adjoin(items; valueRecord; same)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 152 | `union` | новое | `union(first; second; same)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 153 | `intersection` | новое | `intersection(first; second; same)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 154 | `difference` | новое | `difference(first; second; same)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 155 | `symmetricDifference` | новое | `symmetricDifference(first; second; same)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 156 | `isSubset` | новое | `isSubset(first; second; same)` | [src/coreStandardFunctional.lmx](src/coreStandardFunctional.lmx) | BODY_WITH_BRIDGE |
| 157 | `mapOption` | новое | `mapOption(input; transform)` | [src/coreStandardObjects.lmx](src/coreStandardObjects.lmx) | BODY_WITH_BRIDGE |
| 158 | `filterOption` | новое | `filterOption(input; accepts)` | [src/coreStandardObjects.lmx](src/coreStandardObjects.lmx) | BODY_WITH_BRIDGE |
| 159 | `orElse` | новое | `orElse(input; fallback)` | [src/coreStandardObjects.lmx](src/coreStandardObjects.lmx) | BODY_WITH_BRIDGE |
| 160 | `orElseGet` | новое | `orElseGet(input; fallback)` | [src/coreStandardObjects.lmx](src/coreStandardObjects.lmx) | BODY_WITH_BRIDGE |
| 161 | `orElseOption` | новое | `orElseOption(input; fallback)` | [src/coreStandardObjects.lmx](src/coreStandardObjects.lmx) | BODY_WITH_BRIDGE |
| 162 | `foldOption` | новое | `foldOption(input; whenEmpty; whenPresent)` | [src/coreStandardObjects.lmx](src/coreStandardObjects.lmx) | BODY_WITH_BRIDGE |
| 163 | `flattenOption` | новое | `flattenOption(input)` | [src/coreStandardObjects.lmx](src/coreStandardObjects.lmx) | BODY_WITH_BRIDGE |
| 164 | `mapResult` | новое | `mapResult(input; transform)` | [src/coreStandardObjects.lmx](src/coreStandardObjects.lmx) | BODY_WITH_BRIDGE |
| 165 | `mapErr` | новое | `mapErr(input; transform)` | [src/coreStandardObjects.lmx](src/coreStandardObjects.lmx) | BODY_WITH_BRIDGE |
| 166 | `orElseResult` | новое | `orElseResult(input; fallback)` | [src/coreStandardObjects.lmx](src/coreStandardObjects.lmx) | BODY_WITH_BRIDGE |
| 167 | `foldResult` | новое | `foldResult(input; onError; onSuccess)` | [src/coreStandardObjects.lmx](src/coreStandardObjects.lmx) | BODY_WITH_BRIDGE |
| 168 | `attempt` | новое | `attempt(operation; args=())` | [src/coreStandardObjects.lmx](src/coreStandardObjects.lmx) | BODY_WITH_BRIDGE |
| 169 | `tap` | новое | `tap(value; action)` | [src/coreStandardObjects.lmx](src/coreStandardObjects.lmx) | BODY_WITH_BRIDGE |
| 170 | `findField` | новое | `findField(source; label; occurrence)` | [src/coreStandardObjects.lmx](src/coreStandardObjects.lmx) | BODY_WITH_BRIDGE |
| 171 | `hasField` | новое | `hasField(source; label; occurrence)` | [src/coreStandardObjects.lmx](src/coreStandardObjects.lmx) | BODY_WITH_BRIDGE |
| 172 | `getField` | новое | `getField(source; label; occurrence)` | [src/coreStandardObjects.lmx](src/coreStandardObjects.lmx) | BODY_WITH_BRIDGE |
| 173 | `assoc` | новое | `assoc(rows; key; same; keyIndex=0)` | [src/coreStandardLisp.lmx](src/coreStandardLisp.lmx) | BODY_WITH_BRIDGE |
| 174 | `pairlis` | новое | `pairlis(keys; values; tail=())` | [src/coreStandardLisp.lmx](src/coreStandardLisp.lmx) | BODY_WITH_BRIDGE |
| 175 | `getProperty` | новое | `getProperty(properties; key; same)` | [src/coreStandardLisp.lmx](src/coreStandardLisp.lmx) | BODY_WITH_BRIDGE |
| 176 | `setProperty` | новое | `setProperty(properties; key; value; same)` | [src/coreStandardLisp.lmx](src/coreStandardLisp.lmx) | BODY_WITH_BRIDGE |
| 177 | `removeProperty` | новое | `removeProperty(properties; key; same)` | [src/coreStandardLisp.lmx](src/coreStandardLisp.lmx) | BODY_WITH_BRIDGE |
| 178 | `getProperties` | новое | `getProperties(properties; indicators; same)` | [src/coreStandardLisp.lmx](src/coreStandardLisp.lmx) | BODY_WITH_BRIDGE |
| 179 | `asOperand` | новое | `asOperand(operation; priority)` | [src/coreStandardLisp.lmx](src/coreStandardLisp.lmx) | BODY_WITH_BRIDGE |
| 180 | `mismatch` | новое | `mismatch(first; second; same)` | [src/coreStandardLisp.lmx](src/coreStandardLisp.lmx) | BODY_WITH_BRIDGE |
| 181 | `searchSequence` | новое | `searchSequence(items; pattern; same; start=0)` | [src/coreStandardLisp.lmx](src/coreStandardLisp.lmx) | BODY_WITH_BRIDGE |
| 182 | `substitute` | новое | `substitute(items; oldValue; newValue; same)` | [src/coreStandardLisp.lmx](src/coreStandardLisp.lmx) | BODY_WITH_BRIDGE |
| 183 | `indexOf` | новое | `indexOf(text; part; start=0)` | [src/coreStandardText.lmx](src/coreStandardText.lmx) | BODY |
| 184 | `lastIndexOf` | новое | `lastIndexOf(text; part; start=length(text))` | [src/coreStandardText.lmx](src/coreStandardText.lmx) | BODY |
| 185 | `compareText` | новое | `compareText(first; second)` | [src/coreStandardText.lmx](src/coreStandardText.lmx) | BODY_WITH_BRIDGE |
| 186 | `trim` | новое | `trim(text; chars=" \t\r\n\v\f")` | [src/coreStandardText.lmx](src/coreStandardText.lmx) | BODY_WITH_BRIDGE |
| 187 | `trimStart` | новое | `trimStart(text; chars=" \t\r\n\v\f")` | [src/coreStandardText.lmx](src/coreStandardText.lmx) | BODY_WITH_BRIDGE |
| 188 | `trimEnd` | новое | `trimEnd(text; chars=" \t\r\n\v\f")` | [src/coreStandardText.lmx](src/coreStandardText.lmx) | BODY_WITH_BRIDGE |
| 189 | `repeatText` | новое | `repeatText(text; count)` | [src/coreStandardText.lmx](src/coreStandardText.lmx) | BODY_WITH_BRIDGE |
| 190 | `padLeft` | новое | `padLeft(text; width; fill=" ")` | [src/coreStandardText.lmx](src/coreStandardText.lmx) | BODY_WITH_BRIDGE |
| 191 | `padRight` | новое | `padRight(text; width; fill=" ")` | [src/coreStandardText.lmx](src/coreStandardText.lmx) | BODY_WITH_BRIDGE |
| 192 | `translate` | новое | `translate(text; from; to)` | [src/coreStandardText.lmx](src/coreStandardText.lmx) | BODY_WITH_BRIDGE |
| 193 | `join` | новое | `join(parts; separator="")` | [src/coreStandardText.lmx](src/coreStandardText.lmx) | BODY_WITH_BRIDGE |
| 194 | `formatInt` | новое | `formatInt(value; base=10)` | [src/coreStandardText.lmx](src/coreStandardText.lmx) | BODY_WITH_BRIDGE |
| 195 | `parseInt` | новое | `parseInt(text; base=10)` | [src/coreStandardText.lmx](src/coreStandardText.lmx) | BODY |
| 196 | `removePrefix` | новое | `removePrefix(text; affix)` | [src/coreStandardText.lmx](src/coreStandardText.lmx) | BODY_WITH_BRIDGE |
| 197 | `removeSuffix` | новое | `removeSuffix(text; affix)` | [src/coreStandardText.lmx](src/coreStandardText.lmx) | BODY_WITH_BRIDGE |
| 198 | `sum` | новое | `sum(items; initial=(0 record))` | [src/coreStandardNumeric.lmx](src/coreStandardNumeric.lmx) | BODY |
| 199 | `product` | новое | `product(items; initial=(1 record))` | [src/coreStandardNumeric.lmx](src/coreStandardNumeric.lmx) | BODY |
| 200 | `minimum` | новое | `minimum(items)` | [src/coreStandardNumeric.lmx](src/coreStandardNumeric.lmx) | BODY_WITH_BRIDGE |
| 201 | `maximum` | новое | `maximum(items)` | [src/coreStandardNumeric.lmx](src/coreStandardNumeric.lmx) | BODY_WITH_BRIDGE |
| 202 | `argMin` | новое | `argMin(items)` | [src/coreStandardNumeric.lmx](src/coreStandardNumeric.lmx) | BODY_WITH_BRIDGE |
| 203 | `argMax` | новое | `argMax(items)` | [src/coreStandardNumeric.lmx](src/coreStandardNumeric.lmx) | BODY_WITH_BRIDGE |
| 204 | `extrema` | новое | `extrema(items)` | [src/coreStandardNumeric.lmx](src/coreStandardNumeric.lmx) | BODY_WITH_BRIDGE |
| 205 | `min` | новое | `min(first; second)` | [src/coreStandardNumeric.lmx](src/coreStandardNumeric.lmx) | BODY |
| 206 | `max` | новое | `max(first; second)` | [src/coreStandardNumeric.lmx](src/coreStandardNumeric.lmx) | BODY |
| 207 | `minMax` | новое | `minMax(first; second)` | [src/coreStandardNumeric.lmx](src/coreStandardNumeric.lmx) | BODY |
| 208 | `clamp` | новое | `clamp(value; lower; upper)` | [src/coreStandardNumeric.lmx](src/coreStandardNumeric.lmx) | BODY |
| 209 | `sign` | новое | `sign(value)` | [src/coreStandardNumeric.lmx](src/coreStandardNumeric.lmx) | BODY |
| 210 | `gcd` | новое | `gcd(first; second)` | [src/coreStandardNumeric.lmx](src/coreStandardNumeric.lmx) | BODY |
| 211 | `lcm` | новое | `lcm(first; second)` | [src/coreStandardNumeric.lmx](src/coreStandardNumeric.lmx) | BODY |
| 212 | `divMod` | новое | `divMod(dividend; divisor)` | [src/coreStandardNumeric.lmx](src/coreStandardNumeric.lmx) | BODY |

## Области применения

- **types** — physical field type codes; int[] by language contract.
- **names** — physical canonical names; anonymous entries retain typed absence.
- **signature** — ordinary positional signature description.
- **signatureTypes** — same signature kind: result type token left, all ordered input tokens right.
- **curry** — arbitrary finite arity, exact stage input type and terminal result.
- **apply** — arbitrary actual record vector; result record including explicit void.
- **partial** — prefix 0..N; exact residual signature, complete prefix yields thunk.
- **uncurry** — explicit full target contract and stage failures, callable result preserved.
- **flip** — swap first two positions of N>=2 with full input types.
- **compose** — inner arbitrary arity; outer consumes its one result; exact final R.
- **pipe** — compose(second; first), exact callable signature.
- **identity** — typed T -> T for any valid value type.
- **map** — universal sequence, ordinary callback admission/defaults, result reference vector.
- **filter** — universal sequence; stable storage-preserving selection and int predicate.
- **foldl** — left fold over any accumulator/item/result records.
- **zip** — pairs of typed records, min length.
- **zipWith** — arbitrary binary callback types, result records.
- **scanl** — seeded scan, n+1 records; accumulator type not hardwired.
- **bind** — Maybe of any typed record; next gets actual payload value.
- **traverse** — Maybe of direct Structure record vector; stop at first absence.
- **memoize** — any arity/R; explicit key-vector equality, Message-local linear cache.
- **fix** — F(self;T0..Tn)->R becomes T0..Tn->R.
- **select** — actual-type selection preserving dense/reference profile.
- **omit** — actual-type omissions preserving dense/reference profile.
- **rename** — one graph copy then canonical field names updated.
- **reorder** — full checked permutation, any field value types.
- **project** — one shared graph copy of selected fields.
- **defaults** — merge(fallback; source), existing presence including uninit wins.
- **diff** — identity-vector patch, not deep payload equality.
- **patch** — prevalidated identity-vector patch in fresh container.
- **bindFields** — DATA defaults through merge; residual input positions not removed.
- **derive** — ordinary merge composition.
- **transpose** — rectangular Structure of row values; no fixed dimensions.
- **groupBy** — typed keys and explicit equality, stable group/member order.
- **lazy** — typed nullary thunk, first successful result cached.
- **force** — nullary call returning typed result record; direct thunk() keeps R.
- **once** — any arity/R; first success reused, failure permits retry.
- **repeat** — count calls with arbitrary typed actual vector; result records.
- **runUntil** — record state; step then predicate, no fixed payload type.
- **retryCall** — finite attempts, declared failures retained in FxCallFailure envelope.
- **bracket** — any resource/result; finally release; arbitrary extra action inputs.
- **recover** — exact signature; handler(name,payload,actualVector) -> R.
- **adapter** — arbitrary external/internal arity, explicit new exact contract.
- **permute** — arbitrary N, reorder interface and actuals together.
- **overload** — explicit pure predicates, exactly one branch, full external signature.
- **predicate** — same arbitrary inputs; normalize ordinary int Boolean output.
- **guard** — same exact signature with precondition over all actuals.
- **trace** — arbitrary signature, events retain typed args/result/void distinction.
- **contract** — same signature, pre(args), post(args,result) or post(args) for void.
- **composeData** — merge actual parent DATA with explicit data overlay.
- **record** — prepared postfix capture; pointer to typed record, no value dereference.
- **some** — Maybe present with any typed value record, including null.
- **none** — Maybe absence, distinct from present empty/null value.
- **ok** — Result success carrying any typed value record.
- **err** — Result failure carrying any typed reason record.
- **bindResult** — typed Result success chain, failure kept.
- **list** — universal sequence input, shallow copied reference vector.
- **flatMap** — universal sequence bind, no artificial list.items box.
- **done** — terminal Bounce with result record.
- **more** — suspended nullary callable, arbitrary captures via partial.
- **trampoline** — iterate Bounce until done, never execute callable final result.
- **range** — dense int range, stop excluded, checked extent.
- **slice** — validated half-open selection preserving actual storage profile.
- **reverse** — new reverse container, reference targets retained.
- **concat** — one-level concatenation; same dense T or ordinary reference array.
- **compress** — same-length int truth mask; stable profile-preserving selection.
- **any** — ordered predicate calls, stop at first true.
- **all** — ordered predicate calls, stop at first false.
- **index** — Maybe of first int index, none when absent.
- **count** — count accepted items in source order.
- **replaceRange** — preflight then overlap-safe replacement, same target descriptor.
- **splice** — same replacement; return a fresh shallow snapshot of removed elements, preserving dense/reference profile.
- **append** — same target, source values fixed before writes.
- **insert** — replaceRange at one position.
- **deleteAt** — replaceRange with no inserted values.
- **literal** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md.
- **oneOf** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md.
- **noneOf** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md.
- **charRange** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md.
- **satisfy** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md.
- **boundaryOf** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md.
- **sameAs** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md.
- **sequence** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md.
- **choice** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md.
- **repeated** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md.
- **atomic** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md.
- **capture** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md.
- **ahead** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md.
- **notAhead** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md.
- **behind** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md.
- **notBehind** — ordinary text-pattern builder; see REGEX_IMPLEMENTATION.md.
- **utf8Text** — ordinary text-pattern text_profile; see REGEX_IMPLEMENTATION.md.
- **byteText** — ordinary text-pattern text_profile; see REGEX_IMPLEMENTATION.md.
- **matchAt** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md.
- **wholeMatch** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md.
- **find** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md.
- **eachMatch** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md.
- **contains** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md.
- **hasPrefix** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md.
- **hasSuffix** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md.
- **matches** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md.
- **matchedSpan** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md.
- **matchedText** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md.
- **captureSpans** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md.
- **lastCapture** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md.
- **captureText** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md.
- **captureTexts** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md.
- **replaceFirst** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md.
- **replace** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md.
- **split** — ordinary text-pattern receiver; see REGEX_IMPLEMENTATION.md.
- **then** — ordinary Pattern operand with common left/right ABI.
- **times** — ordinary Pattern operand with common left/right ABI.
- **atLeast** — ordinary Pattern operand with common left/right ABI.
- **atMost** — ordinary Pattern operand with common left/right ABI.
- **optional** — ordinary Pattern operand with common left/right ABI.
- **findFirst** — first accepted typed element as some(record), none for absence; ordered short-circuit over dense Arrays and Structures.
- **allOf** — arbitrary finite predicate composition with a shared ordered signature, preserved input places and short-circuit; empty set requires an explicit contract.
- **equalFields** — ordered sequence/field equality with explicit typed comparator; unequal lengths are false, empty equal lengths are true; no implicit deep graph equality.
- **retryPost** — Message-owned bounded retry with saturated backoff, transport timeout and policy cancellation; persistent terminal result and late-reply draining.
- **between** — prepared operand for inclusive ordered bounds; exactly two right values, ordinary actual comparison types and the priority of <=.
- **iterateUntilStop** — execute accepted declaration DATA and associated body in their receiving activation; source Stop terminates, other declared exits retain name/payload in FxCallFailure; requires AE01.
- **sort** — stable nonmutating generic merge sort; three-way int comparator; fresh outer array preserving source profile and element identity; empty/singleton supported; callback failure does not modify input.
- **unique** — stable first-occurrence uniqueness with explicit typed equality predicate; fresh outer array preserving source profile and element identity; empty/singleton supported; callback failure does not modify input.
- **take** — Fresh prefix; count is clamped to 0..length..
- **drop** — Fresh suffix after a clamped count..
- **splitAt** — Both slices use one clamped cut; source remains unchanged..
- **takeWhile** — Longest true prefix; predicate runs once per visited item, including first rejection..
- **dropWhile** — Suffix begins with first rejected item; no later predicates are evaluated..
- **span** — One prefix scan supplies both parts, without reevaluating an effectful predicate..
- **partition** — Stable two-way partition with exactly one predicate call per item..
- **enumerate** — Indices are admitted to the current int type from exact arithmetic; no wrapping index is accepted..
- **windows** — Positive width/step; full windows by default. partial permits one last nonempty short window. No suffix after a window reaches the end..
- **chunks** — Nonoverlapping chunks, final short chunk permitted unless strict; invalid size fails before iteration..
- **intersperse** — Insert an admitted separator between items; empty and singleton inputs do not admit an unused separator..
- **intercalate** — Separate sequence parts and concatenate; empty parts returns a fresh empty sequence of separator profile..
- **unzip** — Reverse the existing zip FxPair protocol; empty input returns two fresh empty record Arrays..
- **foldr** — Strict finite right fold; step(item,accumulator), right-to-left callback order..
- **scanr** — Right scan includes the seed at the final position; right-to-left callbacks..
- **filterMap** — Map to Maybe and keep present values, preserving zero/empty/reference values..
- **mapWhile** — Map to Maybe; stop at first none, without calling later items..
- **findMap** — Return the first present callback result; return none when all are absent..
- **mapAccumL** — step(state,item) returns FxPair(next state,output); callbacks left-to-right..
- **mapAccumR** — Same stateful transform, callbacks right-to-left, outputs at original positions..
- **groupAdjacent** — Consecutive equal-key runs; keyOf once per item and sameKey once per adjacent pair..
- **replicate** — Finite copies of one ready value record; negative count gives empty; reference values retain one target..
- **cycle** — Required finite repetition count; nonpositive count gives empty; preflight result size..
- **starmap** — Each ready row becomes one actual vector; one typed callback result per row. No source graph field is executed while reading it..
- **zipLongest** — Two sequences padded to the longer length with the explicit complete fill value record..
- **collect** — Nullary producer through the existing call bridge until its Stop(), or finite limit; other declared failures retain their name and payload inside FxCallFailure..
- **includes** — Ordered short-circuit membership with explicit typed equality; no conflict with regex contains..
- **adjoin** — Return original source if already present; otherwise return a fresh same-profile Array with the new value prepended..
- **union** — Unique first occurrences from first then second; pure equivalence relation required..
- **intersection** — Unique first-source values present in second, preserving first-source order..
- **difference** — Unique first-source values absent from second; set difference, not Haskell list multiset subtraction..
- **symmetricDifference** — First-only values then second-only values, each once; use existing difference and concat..
- **isSubset** — Every equivalence class from first appears in second; multiplicity is ignored..
- **mapOption** — Map one present payload to a new Maybe; absent input skips transform; Some(null) stays present..
- **filterOption** — Retain the same present container when an int predicate accepts its payload; absent or rejected input yields absence..
- **orElse** — Return the existing payload record or an already evaluated fallback record; result is not a Maybe..
- **orElseGet** — Return the payload record; invoke a nullary fallback only when absent..
- **orElseOption** — Return the original present Maybe, or call the nullary fallback once and return its Maybe unchanged..
- **foldOption** — Invoke exactly one branch, a nullary absent branch or unary payload branch; return its typed result record..
- **flattenOption** — Flatten one Maybe-of-Maybe level, retaining the nested container identity; absent outer input skips payload access..
- **mapResult** — Map only success payload into a fresh ok result; retain the existing error container without invoking transform..
- **mapErr** — Map only error payload into a fresh err result; retain the existing success container without invoking transform..
- **orElseResult** — Invoke one error-to-Result continuation only on err; return its Result without nesting; success identity retained..
- **foldResult** — Invoke exactly one unary branch with the corresponding typed payload; return its result record..
- **attempt** — Invoke through existing FxTry; return ok(result record) or err(typed reference record to full original FxOutcome); kernel/admission failures propagate..
- **tap** — Call one effect with the actual typed payload and return the exact original value record; no deep copying or swallowing failure..
- **findField** — Maybe of the selected physical field record; required zero-based occurrence counts equal ready names only; no payload evaluation..
- **hasField** — Whether that physical named occurrence exists; named uninitialized payloads count as present; no payload evaluation..
- **getField** — Return the existing selected field record; missing or negative occurrence raises FxIndex; no payload evaluation..
- **assoc** — First matching row as Maybe; keyIndex=1 covers reverse association with the same search; empty rows skipped..
- **pairlis** — Fresh forward-ordered key/value rows then shallow tail rows; equal lengths required..
- **getProperty** — Maybe of the first matching flat property value; present zero/null differs from absent..
- **setProperty** — Update first matching value, otherwise append a key/value pair; return same target Array..
- **removeProperty** — Remove first matching key/value pair; return int 1 if found, otherwise 0..
- **getProperties** — First property whose key matches any indicator; Maybe of key/value/index; Array index is explicit, not a Lisp cons tail..
- **asOperand** — Construct one ordinary OPERANDS_TEMPLATE-compatible prepared operand; present left then right actuals, exact source R/void and named failures. No new syntax mode..
- **mismatch** — Maybe of first differing index, or shared-prefix length when only lengths differ; no difference yields none..
- **searchSequence** — Maybe of first full subsequence start at or after start; empty pattern matches start; explicit equality..
- **substitute** — Fresh same-profile Array, replacing every equivalent element; source unchanged and referenced targets shared..
- **indexOf** — First literal byte-substring index at or after clamped start; -1 absent. Empty part matches the chosen valid boundary..
- **lastIndexOf** — Last literal byte-substring index at or before clamped start; overlapping candidates are tested, -1 absent..
- **compareText** — Unsigned-octet lexicographic order -1/0/1; exact case-sensitive content, length breaks an equal-prefix tie..
- **trim** — Fresh byte slice after removing any chosen boundary characters on both sides; default is six ASCII whitespace characters..
- **trimStart** — The same shared trim algorithm at the start only..
- **trimEnd** — The same shared trim algorithm at the end only..
- **repeatText** — Fresh repeated char[] through the shared generic cycle algorithm; negative count is SequenceSize..
- **padLeft** — Fresh byte string of at least width units; repeat then truncate fill at the left, preserve text when already long enough..
- **padRight** — The same shared padding algorithm with padding on the right..
- **translate** — Simultaneous literal byte substitution, equal-size alphabets, first duplicate source entry wins, unknown bytes retained..
- **join** — Join already rendered char[] parts through shared intercalate; no hidden printer or implicit coercion..
- **formatInt** — Exact signed bigint to lowercase digits in radix 2..36; shared with the internal nonnegative decimal name builder..
- **parseInt** — Strict whole-input signed bigint parse in radix 2..36; optional sign, ASCII digits case-insensitive, no whitespace/prefix/trailing text..
- **removePrefix** — Remove one exact leading affix when present; fresh slice either way..
- **removeSuffix** — The same affix-removal algorithm at the end..
- **sum** — Common (+ initial copy(items)) Expression over actual ready numeric fields; empty input returns the initial value record..
- **product** — Common (* initial copy(items)) Expression over actual ready numeric fields; empty input returns the initial value record..
- **minimum** — First least ordered numeric value as its original typed record; empty input raises SequenceSize..
- **maximum** — First greatest ordered numeric value as its original typed record; empty input raises SequenceSize..
- **argMin** — Zero-based first index of the least ordered numeric value, using the same extremum loop..
- **argMax** — Zero-based first index of the greatest ordered numeric value, using the same extremum loop..
- **extrema** — Pair of original minimum and maximum records; delegates to the two existing extremum directions..
- **min** — Choose the lesser of two typed ordered numeric value records; first identity wins ties..
- **max** — Choose the greater of two typed ordered numeric value records; first identity wins ties..
- **minMax** — Both original records in nondecreasing order; ties preserve input order and both identities..
- **clamp** — Closed ordered interval through shared min/max; reversed bounds raise NumericDomain..
- **sign** — Int -1/0/1 for ordered numeric values; no IEEE NaN or complex sign contract is claimed..
- **gcd** — Exact nonnegative bigint Euclidean GCD, including gcd(0;0)=0..
- **lcm** — Exact nonnegative bigint LCM through gcd; any zero input yields zero..
- **divMod** — Exact bigint floor quotient and remainder with divisor sign; zero divisor raises NumericDomain..

## Готовые значения, требования и исходы

Эти имена читаются как значения/описания. Они не являются неявными nullary-вызовами и не входят в число вызовных имён выше.

| Имя | Роль | Исходник |
| --- | --- | --- |
| `emptyPattern` | ready_pattern | [src/regex/values.lmx](src/regex/values.lmx) |
| `neverPattern` | ready_pattern | [src/regex/values.lmx](src/regex/values.lmx) |
| `anyChar` | ready_pattern | [src/regex/values.lmx](src/regex/values.lmx) |
| `lineChar` | ready_pattern | [src/regex/values.lmx](src/regex/values.lmx) |
| `lineBreak` | ready_pattern | [src/regex/values.lmx](src/regex/values.lmx) |
| `textStart` | ready_pattern | [src/regex/values.lmx](src/regex/values.lmx) |
| `textEnd` | ready_pattern | [src/regex/values.lmx](src/regex/values.lmx) |
| `lineStart` | ready_pattern | [src/regex/values.lmx](src/regex/values.lmx) |
| `lineEnd` | ready_pattern | [src/regex/values.lmx](src/regex/values.lmx) |
| `asciiDigit` | ready_pattern | [src/regex/values.lmx](src/regex/values.lmx) |
| `asciiLetter` | ready_pattern | [src/regex/values.lmx](src/regex/values.lmx) |
| `asciiWord` | ready_pattern | [src/regex/values.lmx](src/regex/values.lmx) |
| `asciiSpace` | ready_pattern | [src/regex/values.lmx](src/regex/values.lmx) |
| `wordBoundary` | ready_pattern | [src/regex/values.lmx](src/regex/values.lmx) |
| `extendFirst` | configuration_value | [src/regex/support.lmx](src/regex/support.lmx) |
| `stopFirst` | configuration_value | [src/regex/support.lmx](src/regex/support.lmx) |
| `unbounded` | configuration_value | [src/regex/support.lmx](src/regex/support.lmx) |
| `Pattern` | ordinary_structural_requirement | [src/regex/support.lmx](src/regex/support.lmx) |
| `TextView` | ordinary_structural_requirement | [src/regex/support.lmx](src/regex/support.lmx) |
| `Match` | ordinary_structural_requirement | [src/regex/support.lmx](src/regex/support.lmx) |
| `Span` | ordinary_structural_requirement | [src/regex/support.lmx](src/regex/support.lmx) |
| `PatternArgument` | declared_failure | [src/regex/support.lmx](src/regex/support.lmx) |
| `PatternEncoding` | declared_failure | [src/regex/support.lmx](src/regex/support.lmx) |
| `PatternPosition` | declared_failure | [src/regex/support.lmx](src/regex/support.lmx) |

Существующий `|` дополнен веткой [RxAlternativeDispatch\probe](src/regex/operands.lmx), без замены прежнего numeric/Array-пути. Постфиксы T[]/T@ подключаются в существующем общем resolver ядра, а не как новые дублирующие имена.

[Последовательности](SEQUENCES_IMPLEMENTATION.md) · [Patterns и текст](REGEX_IMPLEMENTATION.md) · [Адаптеры](ADAPTER_IMPLEMENTATION.md).
