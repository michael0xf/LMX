# Writes through a reference, `* / %`, and the merge census at the walked root (-183)

FABLE-OPUS-ROOT-PUTOF-MUL-20260925-183 (Opus; base origin/main eb77c1c).  These are the translator
halves of two walker pieces already on main: PUT_OF (-177 c4) and MUL/DIV/MOD (-170 c1).  Last comes
a read-only census of the rows pending on «a Structure value».

## Commit 1: a write through a reference (PUT_OF)

### What is built

- `m\f: v` and `m\a\b: v` into a NUMBER field: when the way goes through a reference (an own root
  field of a Structure type, or a reference field, kind 3), the write is
  PUT_OF [put_of, holder, slot, value].
  - The holder is the way to the Structure holding the last field (l2_rw_path_value one level up),
    evaluated in R0's turn, DEREF opening each reference.
  - The slot is the last field's.
  - The value is typed by the field (l2_rw_texpr).
- A way fixed when the graph is built (a named Structure and its inline nested ones) keeps PUT
  with the builder's node (l2_nsp).
- A whole Structure assigned through a path to a Structure-typed field (`o\inner: a`) stays a
  located refusal: «a Structure assigned through a path».
  - That is fable's interim fail-closed ruling, pinned by unit_matrix_path_struct_rebind_refused and
    unit_field_path_struct_rebind_refused.
  - Both rows are l2trans-refuses now.  The author is asked in q26: merge in place / rebind /
    refusal.
  - Another non-number last field: «a field path».

### Rows (the 7 at «a field write through a reference»)

| row | now |
|---|---|
| unit_matrix_path_prim | eternal-runs |
| unit_field_path_unit_colon | eternal-runs (tails: 2 returns) |
| unit_matrix_path_struct_rebind_refused, unit_field_path_struct_rebind_refused | l2trans-refuses «a Structure assigned through a path» (q26) |
| unit_struct_int_field | root-pending «a Structure value» (`copy: merge: Model`) |
| unit_field_path_formal_value | root-pending «mixed numeric types (a conversion)» (`exit_code: get(a)`, get returns a size_t) |
| unit_s1_catch_t2 | root-pending «throw and catch» |

New row: unit_root_putof (Entry 7).
- `m\value: 42U` is written through m.
- It is read back through m (bit 1) and through a method's formal, the same Structure by reference
  (bit 2).
- Model itself keeps its 1U (bit 4).
- It pins the PUT_OF.

### Witness

- Mutant P1, the write built as PUT with the evaluated holder's node in PUT's child 1:
  unit_root_putof, unit_matrix_path_prim and unit_field_path_unit_colon abort, «lmx: walk error:
  INVALID» (exit 3): -177 c4's lmx_walk_slot refuses an OP-node holder.
- The mutant «the write lands in the node» cannot be built any more.  That is P1's case, and -177
  c4's guard is what refuses it.

## The census: 9 rows at «a Structure value» (read)

The kernel's merge is `lmx_merge_owned(operands, count, body, container, ..., overrides, ...)`,
and `lmx_merge_profiles_owned` for qualified (eternal) operands.  The walker's one merge primitive,
lmx_walk_merge_model (-174 c3), passes ONE operand: merge(Model, empty).

| form | rows | what the root needs |
|---|---|---|
| `R: merge: X`, one operand, a named Structure | unit_arrarr_field (`R: merge: Holder`), unit_throwing_callable (`R: merge: A`), unit_struct_num_fields (`c: merge: Counts`) | translator only: PUT(R, merge_model(X)); then R's paths resolve through the merge result's field table (l2_mrs_slot_named), not l2_ns |
| `R: merge: A B ...`, several operands | unit_merge_site (`A B C`), unit_merge_last_occurrence (`Model Over`: the last occurrence wins, Q22.2), unit_eternal_shape, unit_array_empty and unit_array_field (`E Holder`, E eternal) | a kernel n-operand primitive, lmx_walk_merge [prim, record, op1 ... opn] over lmx_merge_owned, and its profiles variant for an eternal operand |
| `S: merge: R` with a body (`... end: merge`) | unit_merge_site | the body as one more operand of that primitive |
| a refusal row | unit_eternal_multi_profile_merge_refused (`FrozenA FrozenB`) | its native refusal, reached once the multi-operand form is built |

So 3 rows move with the translator alone.  The other 6 need Grok's n-operand merge primitive.
