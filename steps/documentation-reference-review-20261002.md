# Second-pass documentation review: Structure addresses and reference application

Date: 2026-10-02. Baseline: `6566b9da`. Scope: documentation only.

## Authority and order

The author's [address correction](../LMX_blog/2026-10-02.md#structure-reference-address)
and [application clarification](../LMX_blog/2026-10-02.md#structure-reference-application)
are the authority. Implementation order remains
[critical_graph_bug](tickets/critical_graph_bug.md) →
[critical_pointer_to_struct_bug](tickets/critical_pointer_to_struct_bug.md) →
[reference-application refactoring](tickets/structure_reference_application_refactor.md)
→ the remaining [v2 queue](../next_core_tasks_v2.md).

## Corrections made in the second pass

- Removed contradictory active definitions and unchecked acceptance items in
  the old plan/dictionary: unary `@Structure` must address the reference cell,
  not return the descriptor. One rule covers Array, formal and explicit
  reference storage; primitive address-taking still addresses primitive data.
- Removed the old instruction that a Structure reference cannot be ordinarily
  applied. Explicit `@:` selects reference reassignment; ordinary application
  uses the selected callable's contract. No arguments or signature were added
  to an ordinary named Structure, and a failed call cannot become assignment.
- Corrected the book's reference-mutation recipe and regenerated both languages.
  An explicit field/index path does not bypass ordinary operation resolution.
  The recipe no longer presents `Type` as another language entity.
- Qualified the coding guide's overbroad prohibition on addressing a child slot:
  a primitive's reference slot and its data cell differ, whereas a reference-held
  value's own address is precisely the address of its real reference cell.
- Corrected Fable's handoff and the active K03/diagnostic-migration/witness
  instructions. Preserved old measurements and quotations, with explicit
  supersession notices; old `A`/`@A` synonym tests are not new acceptance.
- Tracked the previously untracked DeepSeek/Fable handoffs as historical
  records, preserving their text and marking placeholders as unverified.
- Made the new pointer ticket's evidence paths absolute: the harness changes
  working directories. No runtime gate was launched in this documentation pass.

## Checks and limits

Reviewed the relevant clauses and examples across the paired L1/L2 specs,
generated semantics and grammar, their sources, both core maps, coding guide,
both plan/dictionary generations, related new-parts notes and active acceptance
documents. Checked remaining legacy phrases against their context rather than
rewriting verbatim imports, author quotations or historical measured results.

`python tools/build_semantics.py`, `python tools/check_docs.py` and
`git diff --check` pass. The documentation checker validates paired structure,
links and preserved source material; it is not a proof of runtime semantics.
The new critical tickets remain open. Existing receiver operand-role collisions
are explicitly assigned to the refactoring inventory, not resolved by invented
syntax or a name heuristic. Source graph bodies and repeated occurrences remain
required, not replaced with an inferred same-object alias rule.

The concurrent graph writer's code, tests and uncommitted acceptance checkbox
are outside this documentation checkpoint. No kernel, native/walker or self-build
completion is claimed by this review.
