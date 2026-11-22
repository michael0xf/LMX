# Прямые публичные ресиверы

Редакция 2026-11-22. Все прежние 50 позиций сохранены; 11 контейнерных/служебных операций добавлены.

Все имена входят в единое ядро и доступны напрямую; собственные DATA и фактический parent каждого метода сохраняются. Клиентский import не требуется.
`BODY` — LMX-алгоритм; `BODY_WITH_BRIDGE` — LMX-алгоритм с явно указанным интерфейсом ядра. Это не отметка запуска.

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
| 34 | `groupBy` | groupBy | `groupBy(items; keyOf; sameKey)` | [src/collections.lmx](src/collections.lmx) | BODY_WITH_BRIDGE |
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
| 51 | `record` | новое | `record(left; right=())` | [src/generic_functions.lmx](src/generic_functions.lmx) | BODY |
| 52 | `some` | новое | `some(value)` | [src/containers.lmx](src/containers.lmx) | BODY |
| 53 | `none` | новое | `none()` | [src/containers.lmx](src/containers.lmx) | BODY |
| 54 | `ok` | новое | `ok(value)` | [src/containers.lmx](src/containers.lmx) | BODY |
| 55 | `err` | новое | `err(reason)` | [src/containers.lmx](src/containers.lmx) | BODY |
| 56 | `bindResult` | новое | `bindResult(input; next)` | [src/containers.lmx](src/containers.lmx) | BODY_WITH_BRIDGE |
| 57 | `list` | новое | `list(values)` | [src/containers.lmx](src/containers.lmx) | BODY |
| 58 | `flatMap` | новое | `flatMap(items; next)` | [src/containers.lmx](src/containers.lmx) | BODY_WITH_BRIDGE |
| 59 | `done` | новое | `done(value)` | [src/containers.lmx](src/containers.lmx) | BODY |
| 60 | `more` | новое | `more(thunk)` | [src/containers.lmx](src/containers.lmx) | BODY_WITH_BRIDGE |
| 61 | `trampoline` | новое | `trampoline(current)` | [src/containers.lmx](src/containers.lmx) | BODY_WITH_BRIDGE |

## Области применения

- **types** — physical field type codes; []:int by language contract.
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
- **map** — each record admitted as actual callback type, result record vector.
- **filter** — typed values; ordinary int truth predicate.
- **foldl** — left fold over any accumulator/item/result records.
- **zip** — pairs of typed records, min length.
- **zipWith** — arbitrary binary callback types, result records.
- **scanl** — seeded scan, n+1 records; accumulator type not hardwired.
- **bind** — Maybe of any typed record; next gets actual payload value.
- **traverse** — Maybe of direct Structure record vector; stop at first absence.
- **memoize** — any arity/R; explicit key-vector equality, Message-local linear cache.
- **fix** — F(self;T0..Tn)->R becomes T0..Tn->R.
- **select** — physical selection in direct Structure/Array<@>.
- **omit** — physical omissions in direct Structure/Array<@>.
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
- **list** — bare Structure/Array<@>, shallow copied record vector.
- **flatMap** — List bind, no artificial list.items box.
- **done** — terminal Bounce with result record.
- **more** — suspended nullary callable, arbitrary captures via partial.
- **trampoline** — iterate Bounce until done, never execute callable final result.
