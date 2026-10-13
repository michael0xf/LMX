# Structure/reference declaration and application

Date: 2026-10-02; revised under the author's 2026-10-13 receiver rule. Status: **OPEN / PLANNED**. Owner: unclaimed.
Dependency: close critical_graph_bug, then critical_pointer_to_struct_bug.
This is the author's new language refactoring, not a claim that code supports it.

## Accepted rules

```text
b: A        # b absent: equivalent to @: b A
@: b A      # explicit reference declaration initialized from A
b: args     # ordinary application of the selected Structure
@: b B      # a new same-named reference occurrence, not reassignment
@: Model: p # nested receiver application initializing p from Model
Model: p    # when Model is known ordinary Structure: same new reference p
@: box Model 0     # third operand initializes the reference to address zero
@: box Model Other # same requirement; initialize from Other's admitted address
```

Use the author's [exact clarification](../../LMX_blog/2026-10-02.md#structure-reference-application)
and [construction](../../docs/LMX_semantics.en.md#construction).
There is no extra nominal `Type` category: primitives and ordinary Structures
describe requirements; implements remains Consumer-relative.

Do not infer from physical reference storage that `b: A` loses its written
body or that distinct source occurrences are the same object. The author
explicitly rejected that inference. Preserve general source construction,
parentage and the structural-recovery gate. Repeated declarations remain
distinct occurrences; updating a selected reference cell is not declaration
and has no syntax inferred by this ticket.

Application checks the selected callable's real contract. Ordinary named
Structures remain argumentless; fn/fm/sub retain their signatures. The symbolic
`args` above applies only when the selected referent is actually callable; a
known ordinary `Model: p` with one name atom declares p instead of invoking
Model. It initializes p with the same Model instance, even when an older p
exists. No clone or implicit merge occurs. Unknown Model and unknown atomic p
in `Model: p` fail translation immediately; no free name is deferred. In a
signature `(Model: p)` is only a nonexecuting formal description.
Failed actual application never falls back to reference assignment. Value/argument
positions do not invoke every transported callable indiscriminately.

In `@: box Model initial`, `box` is the new occurrence, `Model` its receiving
requirement, and `initial` its initial reference value. A Structure candidate
such as `Other` is admitted against `Model` through `implements` before its
address is stored; literal `0` is address zero, not a special name. Omitting
the third operand uses Model's own address. Resolve source names to addressable
places at translation; construction reads the current referent address. No
runtime name lookup, merge or clone. Literal zero stores a null address without
trying to run `implements` on a nonexistent Structure.
The nested `@: Model: box` and flat `@: box Model` share this contract.

Unary `@A` retains the preceding pointer fix: address of the reference cell,
not descriptor load. Do not use conversion/admission to erase its added level.
The `@:` receiver and unary `@` are not interchangeable operators.

## Implementation slices

1. Inventory all reference-head/definition/declaration recognizers, primitive
   pointer receivers, signature descriptions, legacy `@: A p [candidate]`
   consumers and tests. A 2026-10-13 read-only census found 366 Structure-like,
   245 primitive and 3,000 `c.Type` standalone type-first candidate lines in
   L2 fixtures (3,611 total in 350 files), plus
   `dev/l2src_sandbox/printTree.lm2:19`; the old 296-row census is stale.
   Classify each before migration: an old typed-null Structure form needs an
   explicit `0`, not `@: Model: box` (which initializes to Model). Do not
   rewrite signature descriptions, L1 declarations, C ABI forms or arbitrary
   pointer depths by regex. Separate source notation from L1/C ABI syntax.
2. Resolve declaration/initialization/application once, with an explicit selected
   destination/place and candidate. Both engines consume that shared act.
3. Implement absent-b synonymy, nested `@:` receiver chains, and repeatable
   same-name declarations. Admission and permitted primitive conversion precede
   initial storage; evaluate candidates once.
4. Enable ordinary invocation through a held callable Structure reference.
   Use the selected occurrence's native word or retained body, signature and
   hidden inputs, never the initial reference value or model's implementation
   address. A held ordinary Structure with a sole name-atom tail follows the
   same new-reference rule, not a fabricated method signature.
5. Migrate old explicit-dereference-only call and bare-reference-assignment
   expectations. Remove superseded branches, not keep permissive fallbacks.
6. Migrate examples and ported sources through the common receiver rules;
   preserve unbounded composition, Array behavior and all source occurrences.

If the inventory exposes an unresolved role collision beyond the author's
2026-10-13 first-argument-name rule, show the exact minimal source and ask the
author in Russian. Do not guess from identifier spelling, add a nominal type
registry, or reverse source operands silently.

## Acceptance

- [ ] Unknown-b forms have the same retained source semantics and result.
- [ ] Known callable-b application invokes the actual selected fn/fm/sub;
  bad arity, missing actual, null/unimplemented target and admission failure
  are calls' own outcomes, never an assignment fallback. Known ordinary
  `Model: b` is a fresh initialized reference, not a call.
- [ ] `@: b B` introduces a distinct same-named reference occurrence without
  rewriting an earlier `b`; it is not invocation of `B`.
- [ ] `@: box Model`, `@: Model: box`, `@: box Model 0` and
  `@: box Model Other` use one declaration/initialization path; explicit zero
  stores address zero, while a Structure candidate stores its admitted address
  without runtime name resolution. Null needs no Structure admission; a missing
  third operand uses Model itself. Confirm both native and walker lowering.
- [ ] Repeated declarations retain ordered occurrences; initialization does not
  erase earlier declarations or coalesce them.
- [ ] Native/walker, root/method/hosted body, path/own/formal/hidden input,
  and equivalent completed surface forms follow one resolution rule.
- [ ] Exact address depth, reference-cell identity, lifetime, C99 storage,
  graph fidelity, merge and ownership pass their preceding gates unchanged.
- [ ] Unknown-head construction rejects an unknown sole atom immediately but
  retains valid nested Structure bodies; Q58 and argumentless ordinary named
  Structures remain covered explicitly, not silently reinterpreted.

Use the full sequential gate commands in
[the preceding ticket](critical_pointer_to_struct_bug.md#6-gates-and-closure),
with new evidence directories for this stage. Record focused positive/negative
tests, mutation controls, full-baseline identities and exact pushed commit.
Add TAKEN on ownership and DONE only on demonstrated acceptance.

Дальше — продолжать `next_core_tasks.md` (активная очередь — `next_core_tasks_v2.md`).
