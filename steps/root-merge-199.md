# Merge at the walked root (-199, T3 over Sonnet's K2)

FABLE-OPUS-ROOT-MERGE-20260925-199 (Opus).  Ticket: `steps/tickets-20260925.md` §1.  Branch
`claude/continue-opus-next-doc-rvjocj`, base main `83c6820`.

## k.1 The plan

K2 on main, read before the code:
- `lmx_walk_merge_map` (`lmx_merge_owned.lm1` :709): `refs = [op0 .. opN-1, body | 0, pairs | 0]`,
  nargs = N + 2; the model's parent is the container; status 2 is the implicit throw `merge`.
- `lmx_walk_prim` (`lmx_walk.lm1` :1054-:1066): a null argument slot is not evaluated, `refs[i]`
  stays 0 -- the zero-slot rule agreed on 2026-09-26 is in.  No divergence, no QUESTION.
- `lmx_walk_merge_pairs_decode` (:660): one plain Structure of 3·P size cells (model_slot, operand,
  field), P = len / 3.

Sites in `l2trans.lm1`:
- `l2_rw_stmt`: a statement `R: merge: A B ... [body]` whose name is a merge result (`l2_mres_find`)
  is the root's step `l2_rw_merge`, before the refusal «a Structure value».  A method's merge stays
  native: its method throws `merge`, outside the walkable subset (T4a).
- `l2_rw_merge`: PUT_REF(0, `l2_mres_base + res`, PRIM [prim, rec(lmx_walk_merge_map), ops, body | 0,
  pairs | 0]).  An operand is the named Structure itself (`l2_nsp`), or AT(0, the slot) of an earlier
  result, read when the step runs.  The body is a plain Structure of the declared fields' size cells;
  the pairs are `l2_mrs_build`'s own map (`l2_msrc_*`, operand n = the body, T2).  Both are made once,
  with the graph, like `l2_nsp`.
- `l2_rw_path` / `l2_rw_path_value`: a merge result as a path root (kind 5), its fields from the
  result-slot map (`l2_mrs_slot_named`), `merged\x` the one slot; it exists only in R0's turn, so a
  write goes through PUT_OF.
- The program build keeps native merge locals only for its own merges (kind-3 fields of named
  Structures).

The 9 root-pending rows «a Structure value» (`steps/next-phase-195.md` §4), by what stops them:
- `unit_arrarr_field`, `unit_struct_int_field`, `unit_struct_num_fields`: flip to eternal-runs,
  Entry 7 (the tails migrated to the exit letter where they were `return: V`).
- `unit_throwing_callable`: past the merge it stops at its own int/size_t mix (`fn: M () int` into
  `size_t: a1`); see D-75 below.
- `unit_eternal_shape`, `unit_array_empty`, `unit_array_field`, `unit_merge_site`,
  `unit_eternal_multi_profile_merge_refused`: their operands are qualified branches, which the native
  merge retains by profile (`lmx_merge_profiles_owned`); the walker's primitive passes none.  They
  stay root-pending with their own needle until the kernel retains profiles (QUESTION below).

## RESULT

Code: `85adb1a` (on top of STARTED `2c499ba`), base main `83c6820`.

### l2trans.lm1

- `l2_rw_merge` (new): the root's step for `R: merge: A B ... [body]`:
  `PUT_REF(0, l2_mres_base + res, PRIM [prim, rec(lmx_walk_merge_map), op0 .. opN-1, body | 0, pairs | 0])`.
  - holder 0: the root's own data, (R0, R0) -- the same slot the native emission writes;
  - an operand: the named Structure itself (`l2_nsp[ni]`), or `AT(0, l2_mres_base + sl)` for an
    earlier result, read when the step runs;
  - the body: `lmx_walk_plain(prim, bn)` with one size cell per declared field (the native emission's
    own restriction: `size_t` with a literal, the same two located refusals);
  - the pairs: `lmx_walk_plain(prim, 3·P)`, cells (model_slot, operand, field) from `l2_msrc_*`, the
    map `l2_mrs_build` already makes for the native merge (operand n = the body, T2);
  - a qualified-branch operand (`l2_ebr_find` ≥ 0): located refusal «root operation not walkable yet:
    a merge of a qualified branch» (see the question below).
- `l2_rw_stmt`: the merge step is taken only for the root (`l2_rw_mi = l2_e`); a method with a merge
  throws `merge` and is outside the walkable subset (T4a), so nothing changes for `--walk-methods`.
- `l2_rw_path` / `l2_rw_path_value`: root kind 5, a merge result: its first name from the result-slot
  map (`l2_mrs_slot_named`, `merged\x` the one slot), the rest through the named Structures as
  before; its value is `AT(unit, l2_mres_base + res)`, and a write is PUT_OF (`path[5]` = 1: the
  result exists only in R0's turn, as through a reference).
- `l2_program_build`: the native merge locals are emitted only for the build's own merges, the kind-3
  fields of named Structures (`l2_merge_build`), as `[1]` operands with no pairs.  For every other
  unit with a merge they were dead declarations (the root has been walked only since -159).
- Prototype `l2_rw_plain` (build_l2src.py's `-Werror=implicit-function-declaration` caught its
  forward use; the harness compiles l2trans without that flag).
- D-75 fix-forward (below): `l2_rw_opty` types a call through a path.

### D-75 (found here, fixed here)

`A\M()` at the walked root had no static type: `l2_rw_opty` knew only a method head, so `fn: M () int`
into `size_t: a1` translated and R0's turn aborted with `lmx: walk error: INVALID` (main `83c6820`,
measured with main's l2trans).  Now the path call is typed by the method `l2_path_kind` resolves it
to, as `l2_rw_operand` builds it: the located refusal «mixed numeric types (a conversion)», as for
`a1: M()`.  Row in `steps/defects.md`.

### Harness rows (tools/l2_harness.ps1)

| Row | Before | Now |
|---|---|---|
| `unit_arrarr_field` | root-pending «a Structure value» | eternal-runs, Entry 7; Absent `l2_mops`; Debt + `\fn: lmx_walk_merge_map` |
| `unit_struct_int_field` | root-pending «a Structure value» (Entry 7 unchecked) | eternal-runs, Entry 7; 4 stale pins of the native E body dropped (own field without a cell, control body, both checkpoint invariants: the root has no native body) |
| `unit_struct_num_fields` | root-pending «a Structure value» | eternal-runs, Entry 7; pins unchanged (all present) |
| `unit_throwing_callable` | root-pending «a Structure value» | root-pending «mixed numeric types (a conversion)» -- its own `fn: M () int` into `size_t` |
| `unit_eternal_shape`, `unit_array_empty`, `unit_array_field`, `unit_merge_site`, `unit_eternal_multi_profile_merge_refused` | root-pending «a Structure value» | root-pending «a merge of a qualified branch» |
| `unit_root_merge_three_operands` (new) | -- | eternal-runs, Entry 7: two pairs on Model's x (C's last), B's z appended, `R\x: 6U` through the result (PUT_OF), `S: merge: R` with a body field reads 6 and 4; the operands keep 1 and 5.  Absent `l2_mops`, `lmx_merge_owned(`; Debt `\fn: lmx_walk_merge_map`, PUT_REF, PRIM 7U / 5U, PUT_OF |
| `unit_root_merge_body` (new) | -- | eternal-runs, Entry 7: the body as the map's operand n (R's x into Model's x, S's z into B's appended z, S's w new) |
| `unit_root_path_call_type` (new, D-75) | -- (main: translates, aborts) | root-pending «mixed numeric types (a conversion)» |
| `unit_root_path_call_typed` (new, D-75) | -- | eternal-runs, Entry 7 |

Fixture tails migrated from the root `return: V` (never run: the rows were root-pending) to
`sendMessage: exit(exit_code: V; ...)` + `return`, failures keeping their numbers and the success
0 → 7: `unit_arrarr_field`, `unit_struct_num_fields`, `unit_throwing_callable`.

Inverted check: every eternal-runs row above run with `entry 0` is red (`l2_eternal_driver: exit 7,
expected 0`).

### Mutants (private variants of l2trans.lm1, each built and run on the rows)

| Mutant | What is mutated | Red rows |
|---|---|---|
| M1 | no pairs Structure (the map dropped) | `unit_root_merge_three_operands` exit 81, `unit_root_merge_body` exit 81 |
| M2 | no body Structure | three_operands: walk INVALID (abort); body: R0 stopped (the pair on operand n meets no body: throw `merge`) |
| M3 | an earlier result read at the slot of the result being made | three_operands: walk PRIMITIVE (abort) |
| M4 | a merge-result path root one slot off | three_operands, body: walk INVALID; `unit_struct_int_field` exit 83; `unit_struct_num_fields` exit 89 |
| M5 | D-75 typing removed | `unit_root_path_call_type` translates (the row expects the refusal) and aborts: walk INVALID |
| M6 | each pair's operand + 1 | three_operands, body: R0 stopped (the kernel refuses the map: throw `merge`) |

The rows without pairs (`unit_arrarr_field`, `unit_struct_*`) stay green under M1/M3, as they must:
one operand, no earlier result.

### Numbers (cloud, this branch at `85adb1a`)

- `python tools/build_l2src.py`: 174/230 -- as main; red only the `<windows.h>` closure.
- `python tools/check_docs.py`: OK.  `git diff --check`: clean.
- Corpus: the 644 tracked `.lm2` of the sandbox through main's l2trans and this one.  Outcome changes:
  6, exactly the flipped and new rows (5 refused → translated, `unit_root_path_call_type` translated →
  refused).  Output changes: 55 more, each only the removed dead merge locals of `l2_program_build`.
- ALSO RUN IN THE CLOUD, beyond `steps/cloud-protocol.md` §4, under a PRIVATE shim that is not in the
  repository (a `windows.h` mapping `GetTickCount64`/`Sleep`/`CreateThread`/`WaitForSingleObject`/
  events onto POSIX, on `CPATH`; PowerShell 7 for the `.ps1`): `tools/l2_harness.ps1` **394/394
  GREEN**, `python tools/run_l3_selftest.py` 11/11.  This is evidence, not the gate: the machine gate
  stays the authority (GATE? below).

### Generated L1 (unit_root_merge_three_operands)

`R: merge: Model B C` -- the step (unit slot 18) and its pair map (two pairs on model slot 0):

```text
        @: Lmx l2_rw0 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_entry_unit, c.LMX_WALK_OP_PUT_REF, 4U)
        @: Lmx l2_rw1 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_rw0, c.LMX_WALK_OP_PRIM, 7U)
        if: lmx_walk_store_size(l2_program_arena, l2_rw0, 2U, 11U) != c.LMX_WALK_OK
        @: LmxPrimitive l2_rwp1 (cast: (@: LmxPrimitive) lmx_arena_take(l2_program_arena, c.sizeof(c.LmxPrimitive), c.LMX_DOMAIN_KIND_PRIMITIVE, c.LMX_DOMAIN_PRIMITIVE))
        l2_rwp1\fn: lmx_walk_merge_map
        l2_rwp1\signature: 0
        l2_rwp1\owner: (cast: (@: Lmx) l2_program_arena)
        if: lmx_arena_ref_store(l2_rw1, 1U, (cast: (@: void) l2_rwp1)) != 0
        if: lmx_arena_ref_store(l2_rw1, 2U, (cast: (@: void) l2_nsp[0])) != 0
        if: lmx_arena_ref_store(l2_rw1, 3U, (cast: (@: void) l2_nsp[1])) != 0
        if: lmx_arena_ref_store(l2_rw1, 4U, (cast: (@: void) l2_nsp[2])) != 0
        @: Lmx l2_rw2 lmx_walk_plain(l2_program_arena, l2_rw1, 6U)
        if: lmx_arena_ref_store(l2_rw1, 6U, (cast: (@: void) l2_rw2)) != 0
        if: lmx_walk_store_size(l2_program_arena, l2_rw2, 0U, 0U) != c.LMX_WALK_OK || lmx_walk_store_size(l2_program_arena, l2_rw2, 1U, 1U) != c.LMX_WALK_OK || lmx_walk_store_size(l2_program_arena, l2_rw2, 2U, 0U) != c.LMX_WALK_OK
        if: lmx_walk_store_size(l2_program_arena, l2_rw2, 3U, 0U) != c.LMX_WALK_OK || lmx_walk_store_size(l2_program_arena, l2_rw2, 4U, 2U) != c.LMX_WALK_OK || lmx_walk_store_size(l2_program_arena, l2_rw2, 5U, 0U) != c.LMX_WALK_OK
        if: lmx_arena_ref_store(l2_rw0, 3U, (cast: (@: void) l2_rw1)) != 0
        if: lmx_arena_ref_store(l2_entry_unit, 18U, (cast: (@: void) l2_rw0)) != 0
```

(the `if: … = 0` / `return: 1` lines are cut).  Slot 5, the body, is 0: no body.  `R\x: 6U`:

```text
        @: Lmx l2_rw45 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_entry_unit, c.LMX_WALK_OP_PUT_OF, 4U)
        @: Lmx l2_rw46 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_rw45, c.LMX_WALK_OP_AT, 3U)
        if: lmx_arena_ref_store(l2_rw46, 1U, (cast: (@: void) l2_entry_unit)) != 0 || lmx_walk_store_size(l2_program_arena, l2_rw46, 2U, 11U) != c.LMX_WALK_OK
```

`S: merge: R` with the body `size_t: w 4U` -- the earlier result read in the turn, the body a plain
Structure of one cell:

```text
        @: Lmx l2_rw49 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_rw48, c.LMX_WALK_OP_PRIM, 5U)
        if: lmx_walk_store_size(l2_program_arena, l2_rw48, 2U, 12U) != c.LMX_WALK_OK
        l2_rwp49\fn: lmx_walk_merge_map
        @: Lmx l2_rw50 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_rw49, c.LMX_WALK_OP_AT, 3U)
        if: lmx_walk_store_size(l2_program_arena, l2_rw50, 2U, 11U) != c.LMX_WALK_OK
        @: Lmx l2_rw51 lmx_walk_plain(l2_program_arena, l2_rw49, 1U)
        if: lmx_walk_store_size(l2_program_arena, l2_rw51, 0U, 4U) != c.LMX_WALK_OK
```

### Not done in this ticket

- merge-into (`o\inner: a`, `lmx_walk_merge_into_map`) at the root: no root-pending row reaches it
  (`o\inner: a` on a Structure-typed own field is refused earlier, «a Structure assigned through a
  path», the ruling pinned by `unit_*_struct_rebind_refused`).  It needs its own rows.
- The five qualified-operand rows: the question below.

## Вопросы fable

QUESTION FABLE-OPUS-ROOT-MERGE-20260925-199: qualified-branch operands at the walked root need the
kernel to retain their profiles -- a K2b for Sonnet?

- Minimal example (`unit_merge_site.lm2`): `R: merge: A B C` where A, B, C are
  `independent: const: immutable:` branches.
- Native (`l2trans.lm1` :20243-:20252): each qualified operand contributes
  `lmx_range_profile(l2_program_arena, op)` and the call is `lmx_merge_profiles_owned(…, l2_mprofiles,
  ep, …)`; the copier then keeps a value of a retained profile BY ADDRESS
  (`lmx_graph_copy_owned.lm1` :462-:470), so the result's slots share the branch's own cells.
- `lmx_walk_merge_map` (`lmx_merge_owned.lm1` :747) calls `lmx_merge_owned` with no profiles, so
  the same merge walked would COPY those cells: a silent change of the merge's meaning, hence the
  located refusal in T3.
- Measured privately (a copy of this branch, not committed): `lmx_walk_merge_map` taking, for each
  operand, `lmx_range_profile(arena, operands[i])` when it is not 0 -- by the arena, no translator
  numbers -- and calling `lmx_merge_profiles_owned` with them; the refusal removed and the operand
  stored as `lmx_arena_ref_struct(l2_entry_unit, l2_unit_base + l2_occ_n() + oi)`.  All five rows run
  (Entry 7 / 0 after their tails' migration) and the harness is 394/394.
- But the SAME five rows are also green with the kernel unpatched: no row tells a retained cell from a
  copied one.  So K2b needs a witness of retention (for instance a write through the result into a
  slot that came from an immutable branch, refused when it is the branch's own cell, or an identity
  check of a nested member), which is the kernel owner's to write.
- Recommendation: a small Sonnet ticket K2b (the profile derivation in `lmx_walk_merge_map`, a
  selftest that tells retention from copy, a mutant), then my one-line un-refusal and the five rows
  flip in the same landing.

GATE? claude/continue-opus-next-doc-rvjocj -- after this RESULT commit.

## RESULT 2: the qualified-branch operands, landed with -202 (K2b)

Base main `eba1fb5` (Sonnet's -202: `lmx_walk_merge_map` collects each operand's own profile and retains
the branch instead of copying it; the selftest tells retention from copy).

- `l2_rw_merge`: the refusal «a merge of a qualified branch» is gone; a qualified-branch operand is the
  branch itself, `lmx_arena_ref_struct(l2_entry_unit, l2_unit_base + l2_occ_n() + oi)` stored in its
  operand slot (the private measurement of RESULT 1, now against the landed kernel).
- Rows flipped to eternal-runs, Entry 7: `unit_eternal_shape`, `unit_array_empty`, `unit_array_field`,
  `unit_merge_site`, `unit_eternal_multi_profile_merge_refused`.  Tails migrated to the exit letter
  (`unit_eternal_shape`, `unit_array_field`, `unit_merge_site`: success 0 → 7); `unit_array_empty` and
  `unit_eternal_multi_profile_merge_refused` had success 0 (empty witnesses) → 7.  Their driver facts
  (roots, profiles, survival after collection) are the rows' own and unchanged.
- Pins: `lmx_merge_profiles_owned` (the native root merge, gone) → `\fn: lmx_walk_merge_map` in
  `unit_merge_site` and `unit_eternal_multi_profile_merge_refused`.
- Retention itself is witnessed by Sonnet's selftest (`lmx_walk_merge_selftest`, -202); no root row
  can observe a cell's identity.
- Mutant Q1 (a branch operand one unit slot off): the three rows run red, walk PRIMITIVE (abort).
  Inverted check (`entry 0`): red.
- Cloud: `build_l2src.py` 174/230, check_docs OK; private shim: harness 397/397.  Root-pending «a
  Structure value» is now 0 rows: 9 of 9 answered (8 run, `unit_throwing_callable` stops at its own
  int/size_t mix).
