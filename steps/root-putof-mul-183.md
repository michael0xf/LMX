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

### Its first consumer: q26's merge in place

The author's q26 (Q21 = A): `o\inner: a`, into an own Structure field, merges a's same-name fields
into inner's slots and appends the new ones.
- inner keeps its identity, and later writes to a are not seen through o\inner.
- That is a two-operand merge with the target as the model: the override map (LmxMergePair) pairs a's
  fields with inner's slots.
- The open point for Grok: lmx_merge_profiles_owned with an override map keeps the model's LAYOUT
  but writes into a fresh `result` (lmx_merge_owned.lm1 ~:290).  It does not merge in place.
  «inner keeps its identity» needs an «into» form: the result is the model itself, grown when a
  brings new fields.
  - Or the author rules that a fresh result stored in the slot is enough.
- So the primitive gets either an override span and an «into» flag, or a sibling
  `lmx_walk_merge_into [prim, record, target, op]`.
- Natively, the l2_emit_admit / merge sites stay as they are.

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
  Structure or a cell.  Whether the arena's table classifies such an interior address is not
  measured.  If it does not, it is KIND_NONE for the copier, as D-60 is.
