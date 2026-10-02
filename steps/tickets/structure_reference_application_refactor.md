# Structure/reference application and explicit reassignment

Date: 2026-10-02. Status: **OPEN / PLANNED**. Owner: unclaimed.
Dependency: close critical_graph_bug, then critical_pointer_to_struct_bug.
This is the author's new language refactoring, not a claim that code supports it.

## Accepted rules

```text
b: A       # b absent: equivalent to @: b A
@: b A     # explicit reference assignment
b: args    # ordinary application of the selected Structure
@: b B     # explicit reference reassignment
```

Use the author's [exact clarification](../../LMX_blog/2026-10-02.md#structure-reference-application)
and [construction](../../docs/LMX_semantics.en.md#construction).
There is no extra nominal `Type` category: primitives and ordinary Structures
describe requirements; implements remains Consumer-relative.

Do not infer from physical reference storage that `b: A` loses its written
body or that distinct source occurrences are the same object. The author
explicitly rejected that inference. Preserve general source construction,
parentage and the structural-recovery gate. Repeated declarations remain
distinct occurrences; updating a selected reference cell is not declaration.

Application checks the selected callable's real contract. Ordinary named
Structures remain argumentless; fn/fm/sub retain their signatures. The symbolic
`args` above is not permission to add formals to an ordinary Structure.
Failed application never falls back to reference assignment. Value/argument
positions do not invoke every transported callable indiscriminately.

Unary `@A` retains the preceding pointer fix: address of the reference cell,
not descriptor load. Do not use conversion/admission to erase its added level.
The `@:` receiver and unary `@` are not interchangeable operators.

## Implementation slices

1. Inventory all reference-head/definition/declaration recognizers, primitive
   pointer receivers, signature descriptions, existing `@: A p [candidate]`
   consumers and tests. Separate source notation from L1/C ABI syntax.
2. Resolve declaration/assignment/application once, with an explicit selected
   destination/place and candidate. Both engines consume that shared act.
3. Implement absent-b synonymy and explicit `@:` reassignment. Admission and
   permitted primitive conversion precede storage; evaluate candidates once.
4. Enable ordinary invocation through a held Structure reference. Use the
   selected occurrence's native word or retained body, signature and hidden
   inputs, never the initial reference value or model's implementation address.
5. Migrate old explicit-dereference-only call and bare-reference-assignment
   expectations. Remove superseded branches, not keep permissive fallbacks.
6. Migrate examples and ported sources through the common receiver rules;
   preserve unbounded composition, Array behavior and all source occurrences.

If the inventory exposes an unresolved role collision (for example old receiver
operand ordering versus the accepted destination/value form), show the exact
minimal source and ask the author in Russian. Do not guess from identifier
spelling, add a nominal type registry, or reverse source operands silently.

## Acceptance

- [ ] Unknown-b forms have the same retained source semantics and result.
- [ ] Known-b application invokes the actual selected Structure; bad arity,
  missing actual, null/unimplemented target and admission failure are calls'
  own outcomes, never an assignment fallback.
- [ ] `@: b B` is reference reassignment with admission, not invocation of B.
- [ ] Repeated declarations retain ordered occurrences; assignment does not
  erase earlier declarations or synthesize new ones.
- [ ] Native/walker, root/method/hosted body, path/own/formal/hidden input,
  and equivalent completed surface forms follow one resolution rule.
- [ ] Exact address depth, reference-cell identity, lifetime, C99 storage,
  graph fidelity, merge and ownership pass their preceding gates unchanged.
- [ ] Existing unknown-head body construction, Q58 and argumentless ordinary
  named Structures remain covered explicitly, not silently reinterpreted.

Use the full sequential gate commands in
[the preceding ticket](critical_pointer_to_struct_bug.md#6-gates-and-closure),
with new evidence directories for this stage. Record focused positive/negative
tests, mutation controls, full-baseline identities and exact pushed commit.
Add TAKEN on ownership and DONE only on demonstrated acceptance.

Дальше — продолжать `next_core_tasks.md` (активная очередь — `next_core_tasks_v2.md`).
