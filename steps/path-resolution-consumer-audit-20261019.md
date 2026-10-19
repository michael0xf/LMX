# Path result consumers: remaining common-cause work

Status: OPEN implementation audit, 2026-10-19. Source inspected: working R2/M1
frontend SHA256 ea5457d8bdc3bd1587e766a8e1e7625f511ca15c1c5d797dfb9fb1a8cb1750d0,
canonical blob afe025054992260ecf6aa5cc251b1e3e60672817, over main 4f4216b4.
This is not a specification or a claim that the path algorithm is unified.
The [author's requirement](../READ.ME) and [v3 plan](../next_core_tasks_v3.md)
remain unchanged. Fable is stopped; Codex is sole writer/build.

## Confirmed call-site rereads

- l2_rw_callable_actual classifies with l2_cf_actual, which releases a resolved
  path; then l2_rw_path_reference or its span wrapper resolves it again.
  Existing l2_cf_actual_rec can transfer that record, and l2_rw_path_value_rec
  already consumes it. Native actual emission uses this transfer.
- Path-headed calls have the same broader boundary: l2_head_resolve calls
  l2_head_method, whose path contract lookup releases its result; walker
  l2_rw_call_at subsequently reaches l2_rw_call_path and resolves that head
  again. Fixing only the callable-actual wrapper does not close these calls.
- l2_check_fields and l2_emit_fields first try l2_array_span, then
  l2_indexed_operand, then prepare/walk the names prefix again. A non-index
  path is parsed and dropped by the Array view before the later route uses it;
  the old indexed-operand branch also reparses a run of one index on an own
  array. Shape/classification, refusal and success all need to be retained by
  one per-operand result, including the explicit C ABI boundary.

L2HeadExpression is only the cached P0 tree for a compact indexed head. It is
not a resolved binding result. Sharing that tree, or a parser helper, does not
prove that the consumers use one resolution with types and maps.

## A supported typed element followed by a field is still rejected

The existing deep/permuted value witnesses end at an index. They do exercise
references and a nonidentity admission map before the index; they do not
exercise a field or another independently mapped value after that index.
The earlier note in current.md records that a named Structure's Array of
Structure references is not built yet. That construction limit does not
explain every index/field case: an own Array with an explicit reference
element contract passes construction and reaches the path rejection.

Measured private positive, build/codex_index_then_field_probe.lm2:

```yaml
Item:
    int: v 7
end: Item
fn: work () int
    []: (@: Item) values 2
    values[0]: Item
    int: got values[0]\v
    return: got
end: work
sendMessage: exit(exit_code: work(); stdout: ""; stderr: "")
return
```

With the EA frontend and D4 staged convert/primitive parts, translation refuses
at8:24: `a field after an index needs an Array of Structure references`.
Expected positive result is7. No runtime is reached; this is not an observed
wrong runtime value. The legitimate no-Structure/int-element refusal in
unit_steps_field_after_index_refused must remain a negative control.

The general causes are visible in the consumers, not just that diagnostic:

- l2_array_place_view:36348-36365 refuses a name after the first index even
  when l2_path_walk already resolved it. Removing this guard alone is not a fix.
- l2_emit_array_place_operand emits a names base followed only by index levels;
  l2_rw_array_place_operand constructs the corresponding ELEM-only suffix.
  Neither consumes an arbitrary ordered name/index suffix.
- l2_rw_path_records flattens only the names prefix; l2_emit_path_resolved
  consumes that prefix too. Passing a mixed record into either unchanged
  cannot make the full route work.
- l2_path_walk_steps sets an index's element model, then resets view_model
  before the next name, with a comment asserting there is no map. An admitted
  reference element must retain its receiving model and the map's context;
  a type name alone does not prove physical field order. This is a static
  missing-proof finding, not yet a measured permuted-element runtime failure.

## One ordered result, not another case guard

The next common lowering must consume every L2PathStep in source order. A
name step carries the selected field, holder/coordinate origin, type and map;
an index step carries the original index expression and the selected element's
contract/model/context. Evaluate the index once. A subsequent name reads the
actual selected value through its admitted model, not a presumed layout.

Read, write and address must select the same final place. Native and walker
may represent that place differently, but must not find its fields or models
again. The Array representation is still transitional; that does not license
a second language-level path grammar. The wider Array-as-Lmx migration stays
a dependent requirement, not something proved by this audit.

Use this same result for ordinary/formal/capture/node/copy roots, called heads,
actuals, effect/admission checks and both backends. Keep a failed LMX lookup
terminal; a C ABI root is classified explicitly, not discovered by retrying a
failed graph path. Retain positive tests for real read/write/address values,
different neighbours, independently permuted nested/element layouts and
runtime-current graph copies, including forced methods and cleared roots.

## Mutators inspected

All writes to L2Path step counts are localized in init/release, text/all/run
adapters and l2_path_names_only. The two current names_only callers are the
check/emission operand loops, both on a freshly prepared, not-yet-walked run;
no current stale-leaf bug is established merely because that helper does not
clear resolved leaf metadata. Preserve the prepared-view contract or replace
it with a consistent common view operation; do not claim this audit measured
a mutation defect that it did not.

Release clears n/names/indexed/run_count/names_run/flat and storage ownership,
leaving diagnostic scalars for located refusals. Names-only cuts n,
run_count/length, indexed and flat together. Future views must keep counters,
types, maps and coordinate origins consistent, and every consumer must read
the resulting view rather than an earlier scalar count.

## Other open dependencies

Ancestor coordinate owner (the preserved node-field positive returns2 rather
than3), independently mapped nested values, split local-model holder, raw
four-part own hop, the 990 local-root encoding bound, current-graph executable
copy evidence, A/B/C, M1-M4/N4 and the complete clean-kernel/self-build/mail
goal remain OPEN. The [R2 value-actual manifest](r2-value-actual-migration-20261019.md)
records the current checked scope; it must not be used as all-consumer proof.
