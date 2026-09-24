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
| two eternal operands | unit_eternal_multi_profile_merge_refused (`FrozenA FrozenB`) | the same primitive with two profiles in its span |

- Correction (commit 2): unit_eternal_multi_profile_merge_refused is not a refusal.  Its harness
  comment reads: «Filename says refused: the merge result is an ordinary Structure».  Natively the
  merge succeeds, with both profiles retained.

So 3 rows move with the translator alone.  The other 6 need Grok's n-operand merge primitive.

## Commit 2: `* / %` (MUL, DIV, MOD)

Base: origin/main e0b07cb (Grok -181).  Commit 1 was rebased onto it: 1c6cc8e, the same content as
c553720.

### What is built

- l2_rw_bin at rank 6 (l2_rw_prec) emits LMX_WALK_OP_MUL / DIV / MOD (-170 c1), with the same typed
  emission as + and −.
  - Both operands take the expression's one type.
  - Mixed types stay «mixed numeric types (a conversion)».
  - A reference operand is «arithmetic on a reference».
- An int divides as C does: −7 / 2 is −3.  An unsigned or size_t divides unsigned.  Both are the
  walker's (-170 c1, D-50).
- The divisor of `/` or `%` that is a single literal 0 (`7 / 0`, `s % 0U`) is refused at translation:
  «a division by zero».  `* 0` is not a division.
- A computed 0 divisor is the walker's X1 in R0's turn.  It was measured on a probe (`int: z 0`,
  `r: 7 / z`): exit 3, «lmx: walk error: INVALID».  No row pins it; the row pins the translation
  refusal.

### Rows

| row | now |
|---|---|
| unit_bare_in_method, unit_bare_own_stmt, unit_discard_codex | eternal-runs |
| unit_value_call_result | root-pending «&& and \|\| (a short-circuit the walker has no role for)» |
| unit_discard_calls | root-pending «a call whose result is not a number» |

New rows:
- unit_root_mul (Entry 15).  It checks 2 + 3 * 4 = 14 (bit 1), a size_t %: 17U % 5U = 2U (bit 2), an
  int / with a negative operand: −7 / 2 = −3 (bit 4), and left to right: 3 * 5 % 4 = 3 (bit 8).  It
  pins the three frames.
- unit_root_div_zero_refused (l2trans-refuses «a division by zero»).

unit_admit_letter_formal stays translates-with-debt: the take-then-merge probe still throws `merge`
after -181.  That is D-60 (steps/defects.md), and the row's comment now says D-60.

### Witness

- M1, `*` built as ADD: unit_root_mul exits 6, not 15.  Bits 1 and 8 are lost (2 + 3 + 4 = 9;
  (3 + 5) % 4 = 0).
- M2, the precedence flipped: l2_rw_prec's ranks 5 and 6 are swapped, and the MUL/DIV/MOD emission is
  opened to both ranks, so the order is the only change.  unit_root_mul exits 14: bit 1 is lost,
  (2 + 3) * 4 = 20.
- A rank-only swap is RED by a refusal at 8:11, not by a value, because the emission is gated on rank
  6.  So M2 is built as above.

## The n-operand merge primitive (for Grok; the shape)

`lmx_walk_merge`, next to lmx_walk_merge_model in lmx_merge_owned.lm1, declared in lmx_walk.h.lm1 and
lmx_merge_owned.h.lm1.

`PRIM [prim, record, container, body, op1, ..., opn]`: nargs = n + 2, n ≥ 1.  The owner is the
program's arena, as for lmx_walk_merge_model.

- container: the Structure the result belongs to (`result\parent`): at the root, the unit, placed
  by the translator as a plain Structure child (a Structure is its own value, -174 c2).
  - It is explicit because an operand's parent is not always the unit: an eternal operand (`E` in
    `R: merge: E Holder`) lives in its own profiled pool.
  - lmx_walk_merge_model's `model\parent` convention holds only for a named Structure of the unit.
- body: -180's value convention.  It is a Structure (the `... end: merge` fields, appended last), or
  a pointer cell: its held reference, 0 = no body.
- op1 ... opn: each a Structure, or a pointer cell holding one (an own reference field such as a
  merge result R in `S: merge: R`).
  - Textual order is kept.  The last occurrence wins by position (Q22.2): the kernel appends; the
    translator resolves R's paths through the result's field table.
- profiles: for each operand, `lmx_range_profile(arena, op)`.  A nonzero profile goes into a
  call-local span, duplicates kept, as natively (l2trans ~:19900).
  - With no profile: `lmx_merge_owned(ops, n, body, container, 0, arena, arena, 0, 0U, @ result)`.
  - Otherwise: `lmx_merge_profiles_owned(..., profiles, ep, 0, 0U, @ result)`.
  - The primitive decides per operand from the arena's own table.  The translator passes no flag.
- the spans (n operands, up to n profiles) are call-local.  lmx_walk_prim's scratch is not in the
  prim ABI, so where they live is Grok's choice; refs[2..] could be resolved in place.
- status:
  - 0 = OK, with the result Structure in `\out`.
  - 1 = a bad call: nargs < 3, a null owner or out.
  - 2 = THROW_MERGE: a non-Structure operand, body or container, or a merge that fails.  At the
    root that is THROWN+1, the implicit `merge` throw, as natively.
- the rows it serves: unit_merge_site (with a body), unit_merge_last_occurrence, unit_eternal_shape,
  unit_array_empty, unit_array_field, unit_eternal_multi_profile_merge_refused (two profiles).
- a suggested selftest:
  - two operands give the sum of widths, in order;
  - an eternal operand is retained by address and the result is fresh;
  - a pointer-cell body holding 0 is no body;
  - mutants: drop the profiles span (the eternal operand is copied, its address differs); reverse
    the operand order.

### The «into» form: q26's own-field write (Q26.1, answered)

The author (Q26.1, verbatim in the blog): «куда вы положите эти операции для интерпретатора? Они как
if или for, и они, конечно, не новый occurrence inner».
- `o\inner: a` on an own Structure field is a body operation that writes INTO the same Structure.
  - a's same-name fields go into inner's slots, and new ones are appended (Q21 = A).
  - inner keeps its identity, so references taken earlier see the new values.
- New occurrences come only from declarations (Q24).

So there are two records, not one PRIM with a null or non-null target.  The operands mean
different things (container and body vs target and pairs), and one record would carry two
contracts.
- `lmx_walk_merge [prim, record, container, body, op1, ..., opn]`: a FRESH result, as above.  It is
  for the 6 rows, `R: merge: A B ...`, and `\out` is the result.  One operand is
  lmx_walk_merge_model's case (c4).
- `lmx_walk_merge_into [prim, record, target, pairs, op]`: INTO target, for q26.
  - target: the own Structure written, `o\inner`.  The translator gives it as an evaluated value
    (the way to it, as PUT_OF's holder), so a Structure reached through a reference is a target
    too.
  - op: the source Structure (a), or a pointer cell holding one (-180's rule).
  - pairs: which slot of target each field of op writes into.
    - The graph has no names, so the translator pairs by name when the program is translated
      (l2_ns_slot_named on both types).
    - The builder makes them a plain Structure of size_t cells, two per pair (the target slot, the
      op field), as LmxMergePair's (model_slot, field) with operand 1.
  - Each paired field's VALUE is written into target's slot: a number's value into target's
    cell, a char as its interned cell.
  - An unpaired field of op is appended to target, which needs target's field array to grow in
    place while the node keeps its address.
    - No row needs that: in both q26 rows a is a Model and inner is a Model, so every field
      pairs.
    - So the first build may refuse an append (THROW_MERGE, or a translation refusal when the
      layouts show it).
    - How a Structure's refs array grows in place is Grok's call.
  - A Structure-typed field of op (a nested merge into) is not needed by the rows either.
  - \out is 0: a statement.
  - Status 2 (THROW_MERGE, the root's THROWN+1) for a target or op that is not a Structure, or for
    a pair out of range.
- Under both, the kernel's C function `lmx_merge_into_owned(target, op, pairs, npairs, src_arena,
  dst_arena, ...)`.
  - The native own-field write `o\inner: a` emits it at its site.
  - Today that site is refused: at the root «a Structure assigned through a path»
    (l2_rw_path_write), and natively the -92/-131 located refusal.
- The lmx_merge_profiles_owned override map (~:100-:130, ~:280-:310) already pairs op fields to
  model slots and appends the unpaired ones.  What it lacks is the target itself: it writes a
  fresh `result`.  The into form is that same pairing, written into the model in place.

## q26 follow-up: how lingvamyxa_prev handled a reference to a Structure (read)

C:\Nyasha_Planet\lingvamyxa_prev, HEAD 98b66a75a8f0e83f84a56b67e634e386d609a666.  Each place below was
read at the line cited.

| what | prev | file:line |
|---|---|---|
| the type | A named Structure carries one IMPLICIT C address level: `Inner` is `LmLmxStructure *`, `@: Inner` is `LmLmxStructure **`.  The double level lives in the translation only; the code writes one `@`. | lm2/trans_l1_expr.lm2:1566-1589 (lm_trans_layout_type_implicit_address_depth, lm_trans_effective_address_depth), :1694-1702 (the type printer adds one `*` per level) |
| `@x` | C `&` of the BINDING.  If x already holds an address, it is address-of-address. | lm2/trans_registry.lm2:1014; Lingvamyxa_spec.txt:7184-7192 («`@: User slot` is an L2 address of a machine slot that stores that Lmx reference»), :7226-7228, :7272-7278 |
| a path hop `o\inner\value` | One dereference per field: `(*((T *)lm_lmx_structure_field_cell((LmLmxStructure *)(...), i)))`.  The next hop casts the held value to `LmLmxStructure *`, with NO extra dereference for a field declared `@: Inner`. | lm2/trans_l1_expr.lm2:5655-5708; the field class lookup ignores the address depth, :3313-3342 |
| `o\inner: a`, an own Structure field | A plain pointer store: `target = expr;`.  That shares, it does not merge. | lm2/trans_l1_statement.lm2:11308 (the lvalue), :11757-11765 (the store); tests/trans_structure_graph_nested.lm2:63-66 (`a\child\x: 7` changes `p\x`) |
| an `@: User` slot | Written THROUGH explicitly: `return_source[0]: user`, filled by `@ returnSource`.  In that fixture the level is visible in the code. | tests/trans_inferred_class_return_pointer.lm2:46, :50, :72 |
| the refactoring note | «`@: LmHashArray` then `array\hash` emitted `LmHashArray **`» was a workaround: «`@ⁿ` is an L2 address slot, not "Structure starts at C depth 1"». | struct_refactoring.txt:243-248; «A StructureReference slot is a pointer to another such chunk», :315-319 |

What follows from it:
- prev resolved the TYPE level: one `@` in the code, two levels in C.
- prev's `@ a` is the address of a's binding.  That is what D-53 records as the native behavior
  today (`@mo` gives the pointer cell's address), so under prev's rule D-53 is the specified
  behavior, not a defect.
- prev never built the read through a reference field (the second dereference).  No prev fixture
  reads `o\inner\value` through `@: Inner inner`.
- prev's own-field assignment shares.  The author's q26 answer, merge in place with identity kept,
  replaces that.

The open choice, for `@: Inner inner` and `o\inner: @ a` (sent to fable):
- (A) prev's rule: the slot holds the address of a's binding, and a read through it is two
  dereferences, absorbed by the translator.
- (B) The slot holds the Structure reference a holds, and a read is one DEREF.  `@` of a
  Structure-typed binding gives the held reference, which is D-53's fix.
- The difference shows only when a is itself rebindable (a reference, `@: Inner a` then
  `a: @ b`).  For an own a, the merge in place keeps a's identity, so (A) and (B) read the same.
- Under (A), the graph would hold the address of a slot inside a Structure's field array, not a
  Structure or a cell.  The probe below measures what the arena and the copier do with it.

### Probe: (A)'s addresses in the program's arena and the copier (measured, fable's q26.2 ask)

A scratch kernel probe, not in the tree.  It uses the worktree's kernel at 1a9a2ad, staged like
build_l2src.  a is a Structure {int 5}, bound in the unit's slot 0 through a pointer cell: the
native shape of an own Structure-typed field.  Each value is held in a slot of a fresh holder, which
is then copied with lmx_graph_copy_owned into a second arena.

| value | lmx_range_classify (program arena) | the copier |
|---|---|---|
| a's Structure | 6 STRUCT | 0 OK: a fresh copy, (B)'s case |
| a's pointer cell (a's binding as a cell) | 1 PRIMITIVE | 0 OK, but the cell is COPIED: a fresh cell holding a fresh copy of a.  The copy no longer tracks a's binding. |
| the interior slot `lmx_arena_ref_cell(unit, 0U)` | 4 CHILDREN (not NONE) | 1 INVALID: «CHILDREN slot storage or a REF backing cell is never a valid child value», lmx_graph_copy_owned.lm1:668-670 |
| a pointer cell → the interior slot (the field (A) would build) | – | 1 INVALID: the pointee is followed (:567-571) and refused as above |
| a pointer cell → a's pointer cell | – | 0 OK: both cells copied, so a's binding is not shared by the copy |

- The raw lmx_pointer_store_known accepts either address (0).  The walker's PUT into a pointer
  cell refuses any value that is not a Structure (lmx_walk.lm1 PUT: «value != 0 && kind !=
  STRUCT → INVALID»), so (A) needs a new store as well.
- So under (A), the interior-slot form is refused by every merge or copy that reaches it.  The
  pointer-cell form survives a copy only by duplicating the binding, which loses (A)'s one
  observable difference in any copied graph.  (B) is the copier's ordinary case.

### The ruling: Q26.2 = (B) (the author, via fable, 2026-09-25)

The author, verbatim: «ну самой конечно структуры, а чего ещё?» (the Structure itself, what else).
- `@` of any Structure binding is the address of the Structure.
- A reference field `@: Inner inner` holds that address.  A read through it is one DEREF.
- prev's address-of-binding rule is not carried over.

Correction, the same day (the author, verbatim in the blog): «you cannot put a direct reference to a
Structure into data*void -- it would count as a Structure [a child].  You can put a reference to a
reference.  But after reading it is just a reference to the Structure.»
- An OWN Structure binding is a direct slot: the copier descends into it as a child, and admission
  sees a Structure.  It is written by PUT_REF (Grok -186).  This covers `Inner: inner`, `Model: m`,
  the root's Structure fields, the take's m, and a merge result (c4 is unaffected).
- A REFERENCE is a pointer cell: the graph's marker that this is a reference, not a child.
  - This covers a field `@: Inner inner` and a letter's `sender` (slot 0, `@: LmxMsg`; the author:
    «разумеется, в L2 -- так»).
  - The copier does not descend into the pointee, which stays shared.
  - The program sees a plain Structure reference after a read: `o\inner\value` is one hop, and
    `@ inner` is the Structure's address, never the cell's.  D-53 is exactly that read defect, on
    the translator's side.
- So `o\inner: @ a` is a PUT of a's Structure reference into the field's pointer cell, as -174
  c2's reference PUT does.  It is not PUT_REF.
- Q26.2 = (B) stands for what the program sees.  The cell is representation only.

The build that follows, after Sonnet's c4 (the letter's sender and the kind 10/11 prototype
fields as pointer cells), so the cell shape is the same on both sides:
- The reference-field rebind `o\inner: @ a`, at the root and natively.
- D-53: `@` of a Structure-typed own field or local gives the Structure's reference, not the
  pointer cell's address.  D-53 closes with that commit.
- The two `*_struct_rebind_refused` rows are rewritten to the rebind form, with running facts
  (renamed if the name lies).
- The own-field form `o\inner: a`: Q26.1 is answered.  It is a write INTO the same Structure
  (merge in place, identity kept), so it goes with lmx_walk_merge_into (the shape above), not with
  the rebind.
- q26 is closed.  Own: merge in place.  Reference: rebind via `@`.  Q26.1: into the same
  Structure.  Q26.2: `@` is the Structure; an own binding is a direct slot, and a reference is a
  pointer cell read through.

## One shape for a Structure bound at run time: the measured cost (open, next_core_tasks.md §3)

The rule, after the author's correction above:
- An OWN Structure binding is a direct slot, written by PUT_REF (Grok -186).
- A REFERENCE is a pointer cell whose read is absorbed.  So is a cell that is itself the value
  (`@: int p`).
- Today's shapes:
  - Direct slots: a merge result (`R: merge: X`, -183 c4).
  - Direct slots, which revert to cells (Sonnet): a named Structure's reference fields (kinds
    10/11, -172 c2) and the letter's raw sender in slot 0 (-173).
  - Pointer cells that should be own direct slots, written by PUT and opened by DEREF on a path:
    an own Structure-typed field (`Model: m`, the root's own Structure fields, -178 c2) and the
    take's `m` (`receiveMessage: m`, -179).
- The copier today copies a pointer cell TOGETHER WITH its pointee (the q26.2 probe above).
  - That is right for today's own cells, and wrong for a reference, whose pointee stays shared.
  - So the own bindings move to direct slots first; only then can the copier stop descending into
    a cell's pointee, because until then it cannot tell the two apart.
- The own bindings move in a later ticket, after the current queue.  This is the cost, measured on
  l2trans at -183 c4's WIP d9623b6 (n159/sites.py, n159/shape_rows.py).

Translator sites:
- `l2_own_nsty_get`, a Structure-typed own field: 24 uses in 18 functions.
  - The root: l2_rw_model, l2_rw_path (2), l2_rw_take, l2_rw_admit_assign (2), l2_rw_struct_arg (2),
    l2_rw_stmt.
  - Native: l2_emit_path_to, l2_path_kind, l2_emit_stmts (2), l2_check_body (2), l2_emit_handler,
    l2_arr_operand, l2_index_chain, l2_path_arr_leaf, l2_own_seg_scan (2), l2_collect_asgn_body,
    l2_graph_nsty, and one global.
- `l2_colon_graph_ty()`, the reference-to-Structure own type: 18 uses in 11 functions.
  - l2_check_body (3), l2_scan_body (2), l2_collect_asgn_body (2), l2_typed_formal (2),
    l2_throw_arg_ty (2), l2_check_catch (2), l2_catch_param_own, l2_collect_catch, l2_dyn_step,
    l2_hidden_from, l2_ret_type_word.
- DEREF at the root: 3 (l2_rw_path_value 2, l2_rw_struct_arg 1).  Each loses one level.
- The builder: `lmx_pointer_new_owned(c.LMX_TYPE_POINTER_BASE + ty - 1000)` for every pointer own
  field (l2trans ~:21514, ~:21585).
  - The Structure-typed ones get an empty direct slot instead.
  - `@: T p` of a non-Structure keeps its cell.
- Native own-field reads and writes go through the working copy and the checkpoint (21.6), with a
  pointer load and store of the cell.  A direct slot is lmx_arena_ref_struct and
  lmx_arena_ref_store instead.

The walker:
- LmxWalkOwn records hold a CELL (`o\from`).
- A Structure-typed own field in a direct slot is no longer an own record (as a named Structure is
  not), so SET does not apply to it.
- A method's activation needs PUT_REF too.  How the per-activation copy (21.5) treats such a slot is
  the ticket's first question.

Rows that re-gate: an upper bound.  These rows' translation builds a pointer cell of the
Structure-reference type (`LMX_TYPE_POINTER_BASE + 100`).  Any `@: Lmx` pointer and any
reference field shares it, and those stay cells.
- 44 rows: 42 eternal-runs, 2 translates-with-debt.
- 10 of them walk a DEREF at the root: unit_admit_letter_typed, unit_arrarr_field, unit_charpp_return,
  unit_root_model_field, unit_root_putof, unit_field_path_unit_colon,
  unit_field_path_terminal_checklist, unit_struct_int_field, unit_matrix_callable_struct_identity,
  unit_matrix_path_prim.
- The other 34: unit_next_message_twice, unit_root_take_letter, unit_root_take_empty,
  unit_next_message_in_method, unit_receive_letter_model, unit_native_typed_receive,
  unit_admit_letter_formal, unit_admit_letter_not_model, unit_admit_formal_refused,
  unit_admit_rebind_refused, unit_admit_letter_extra_field, unit_admit_letter_coarse, entry_argc,
  unit_formal_shadows_struct, unit_s1_merge_uncaught_entry, unit_s1_implements_uncaught,
  unit_call_args_refuse_struct, unit_colon_model_decl, unit_empty_struct_decl,
  unit_typed_decl_vertical, unit_colon_method_lexical_model, unit_colon_method_dynamic_precedence,
  unit_colon_method_fresh_per_activation, unit_field_path_own_write, unit_field_path_formal,
  unit_field_path_nested, unit_field_path_nested_two, unit_struct_return, unit_c_member_struct_control,
  unit_raw_root_model_compound, unit_raw_root_formal_compound, unit_local_model_arg,
  unit_model_fresh_synonyms, unit_matrix_absent_struct_decl.
- The 10 DEREF rows are measured with c4's two flips (unit_arrarr_field, unit_struct_int_field)
  included.
