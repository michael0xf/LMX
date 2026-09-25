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
