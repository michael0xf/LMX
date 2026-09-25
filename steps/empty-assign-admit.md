# Empty Structure admission at the walked root

Base: main `3f68f41`. Branch `grok/empty-assign-admit`. Kernel unchanged.

## What

`f()` / `S()` when the name already binds an ordinary Structure (`l2_empty_struct_assign_shape`) assigns a fresh empty Structure and admits it to the declared type. The native emitter does this with `lmx_node_new_owned` and `l2_emit_admit`. The walked root mirrors it through `l2_rw_admit` (`lmx_walk_admit`).

- Shape 1 (`fresh()`): `PUT`/`PUT_REF` of the own field, value `admit(FRESH(empty), T)`.
- Shape 2 (`S()`): `PUT_REF` of the named Structure's unit child (`l2_ns_base + rank`), the same slot `S\v` reads, value `admit(FRESH(empty), S)`.
- `FRESH` of a 0-child Structure allocates one empty node each time the step runs (`lmx_fresh`), not one node built with the graph.
- Admission NO is the implicit throw `implements` (catch slot already on the primitive). The store is the parent `PUT`/`PUT_REF`, which does not run when the value throws, so the previous binding stays.
- No declared type (`E()`, `m()`) stays refused: «a reference assignment». Not this step.

## Rows

- `unit_empty_assign_admit` — Entry 421. The root exit is `sendMessage: exit`, because a valued `return` is refused at the root. The number is unchanged.
- `unit_empty_assign_named` — Entry 74.
- `unit_empty_assign_untyped` — still root-pending, «a reference assignment».

## Mutants (measured, then reverted)

| What changed | Result |
| --- | --- |
| The store takes `FRESH` itself, not the admit primitive | both rows `lmx: walk error: INVALID`, exit 3, not 421 / 74 |
| The admit model is the empty node, not `l2_nsp[T]` | both rows the same INVALID, exit 3 |
| Both reverted | admit exit 0 entry 421; named exit 0 entry 74; untyped still refuses «a reference assignment» |

## RESULT

Branch `grok/empty-assign-admit`, base main `3f68f41`. Kernel unchanged. Twin `l2src/l2trans.lm1` is the sandbox copy.

Gate: build 280/280 (`build/l2src/20260925_161945`), harness 401/401 (`build/l2_harness/empty_admit_gate`), L3 11/11, names 69/128, check_docs OK. `git diff --check` clean.
