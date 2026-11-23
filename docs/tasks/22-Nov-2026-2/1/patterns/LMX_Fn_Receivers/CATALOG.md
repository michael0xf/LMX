# Прямые публичные ресиверы и Expression-операнды

Редакция 2026-11-22. Сохранены все 61 операции текущего загруженного комплекта; имена согласованы с новой редакцией; добавлены 14 последовательностных и 40 текстовых/Pattern-операций. Всего 115 уникальных вызовных имён.

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
