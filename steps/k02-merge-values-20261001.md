# K02 — ordinary merge values (next_core_tasks_v2.md, §2)

Status 2026-10-01: **OPEN**; first slice K02a implemented on the K01 release (`65e4cf4`). This
note records reproductions before repairs, as the plan's §1 asks.

## 1. K02a — the merge projects the ACTUAL operand, not the declared model

**Reproduction.** `unit_merge_actual_operand.lm2`:

```
A: (size_t: x 1U)
B: (size_t: pad 9U; size_t: x 2U)
C: (size_t: x 3U)
fn: m () int
    @: A p B
    R: merge: p C
    size_t: pad
    pad: R\pad
    ...
```

On the K01 bytes this is refused:

```
unit_merge_actual_operand.lm2:24:12: unresolved name
l2trans detail: atom=pad
```

`p` is a reference binding whose declared model is `A`; its referent is a `B`. The merge's
result schema came from the **declared** model, so `R` had no `pad` — the field the actual
operand really has. That is the plan's first bullet verbatim ("reference-to-A holding B must
copy/project B's real fields").

**Where it comes from.** `l2_mrs_build` (the pre-scan that builds the result's slot map, because
a method lowered before the entry may already read a field of the result) classifies an operand
through `l2_resolved_own` and, for an own field, takes `l2_own_nsty_get(own)` — the DECLARED
named model. The candidate is not in the own-field record, but it is in the declaration itself:
P0 gives `@: A p B` as the frame `head="@"` with body `[A, p, B]` (dumped with
`build/fable127_part1b/printTree.exe`), so the third atom is the model of the value the binding
holds.

**Repair.** New `l2_own_ref_candidate(own)`: the `@` frame's third active atom, resolved with
`l2_ns_find` — -1 when the binding names no candidate, or names something other than a unit
Structure. `l2_mrs_build` now takes that model for the operand's entry when it is ≥ 0, keeping
the declared model as the fallback. One model, one place: nothing is added to the own-field
record, no registry and no hidden Structure is introduced.

**Witness.** `unit_merge_actual_operand.lm2` is an `eternal-runs` row (WalkRoot, Entry 7):
`R\pad` = 9 and `R\x` = 3 (C's later `x` goes INTO the model's `x` slot, merge making no repeated
names), and the fixture exits 7. The other merge rows (`unit_merge_live_source`,
`unit_merge_added_repeat`, `unit_merge_body_repeat`, `unit_merge_eternal_pair`,
`unit_merge_last_occurrence`, `unit_merge_value_*`, `unit_merge_in_method`,
`unit_merge_path_expr`) stay green in the same focused run.
