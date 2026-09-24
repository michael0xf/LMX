# Merge by the author's rule, after k.4: k.1, read-only (-193)

FABLE-OPUS-MERGE-PARTS-20260926-193 (Opus), k.1.  Base: main a39fe1b (k.4 and c4 landed).  No code
changes.

The norm is plan §4 «Merge: правило автора» (next_core_tasks.md :358, the author's text of
2026-09-24/25) and §7 «return вложенного callable через merge» (:420).
- The first operand is the model.  A later operand's or body's field that matches a model field
  (same name and type, known to the translator; admission as for an assignment) is written INTO the
  model's slot.  The other fields are appended.
- The result's layout is the model's layout plus the new fields: no model slot moves, and there is
  no hidden offset.
- merge makes no repeated names: `merged\x` is the one slot.
- A callable has the parts `args`/`return`/`body`, and any other Structure is a `body`.  merge goes
  pairwise by parts, recursively, with later operands merged INTO the model.  The unnamed operators
  of an operand's body REPLACE the model's.
- A conversion to a declared callable type is one more merge, `merge(m; fields; header)`.
- A returned nested method is one merge with three operands, `merge(addN; {used values}; header)`.
- A native implementation is not merged.  The result's `native` is 0, so it is walked.  Until method
  bodies have op-trees, a callable merge is a located refusal.

## 1. Already in place after k.4 (measured at a39fe1b)

- `LmxCallable.offset` and the descriptor's COW clone are gone with `LmxCallable` (k.4).
- The `A: fn: M` terminal is the copier's.
  - lmx_graph_copy_owned.lm1 :482-:500: any Structure whose parent lies outside the copied operand
    is kept by address, with its parent unchanged.  This is Q22 = II, generalised.
  - `native` is copied verbatim (:790-:793).
- A merge result's `native` is 0: `lmx_node_new_owned` zeroes it (lmx_merge_owned.lm1 :202-:209).
- The signature is the `args`/`return` parts: c4, form A, in which a method with a header has args@0
  and return@1.
- The kernel has a position map already: `LmxMergePair {model_slot, operand, field}`
  (lmx_merge_owned.h.lm1 :56-:64), used when `overrides != 0`.
  - It is covered by lmx_merge_override_selftest: model {1,2} + {99} with the pair (0 ← 1.0) gives
    len 2 with slot 0 = 99.
  - The translator never passes one: all four call sites (l2trans.lm1 :19937, :19939, :20522,
    :21662) pass `0, 0U`.
- The two witnesses already give the norm's value natively.  Measured inside a method, on a driver
  built from main:
  - q22.md: `R: merge: A` with `A: fn: M` reading `node\tag` gives R\M() = **3** (was 90);
  - q20-next.md §2: A\M(), R\M(), Q\M() all 3 gives **5**.
  - At the walked root both are root-pending («a Structure value»): a merge statement is not walkable
    at the root yet.  See (2d).

## 2. What remains

### (1) The kernel (lmx_merge_owned, a walker primitive)

a. The body as a pair source.  Today `operand >= count` is INVALID and the body is always appended
   (lm1 :99-:108, :319-:337).  A body field that matches a model field must go to the model's slot.
   Proposed: the body is operand `count` in the map.
b. A pair's target is any result slot placed before it: the model's slots, and a field an EARLIER
   operand appended.  «No repeated names» holds across later operands too (`merge: A B C`, B and C
   both new `z`).  Today `model_slot < model_w` only.
c. Map validity.  Two pairs with the same source, or the same target twice, are INVALID; today the
   later one wins silently.  Kind and type are the translator's, which knows them statically.  A
   Structure-typed pair is admitted as an assignment is (implements).
d. The parent of nested Structures.  The copier parents a copied child to the copy of its source
   parent, the operand-root copy.  merge re-points only `result\parent` (lm1 :341).  So a nested
   Structure of the result has an orphan copy as its parent, and a later merge of that result would
   share it rather than copy it (read from the code, not run).  Proposed: re-parent the result's
   children whose parent is an operand-root copy to the result, with a selftest and a mutant.
e. Parts, recursively (callables).  A pair must be able to say «merge this operand part INTO the
   model's part» (args ← args, return ← return, body ← body; in form A the parts are slots 0/1 and
   the rest), not only «store».
   - Proposed: a pair kind «merge into» carrying a sub-map, applied recursively.  That is the same
     operation as Q26.1's `o\inner: a` (merge into the same Structure).
   - Alternative: the translator emits one merge per part and assembles them.  It is more emission
     for the same result.
f. Operators replace.  When an operand's body part has operators (OP frames among its children),
   they replace the model's operators.  Otherwise the model's stay.  This only matters for walked
   bodies.
g. The walked root.  A merge statement at the root needs a walker primitive that takes the operands
   and the map (today only `Model: m` has one, `lmx_walk_merge_model`, with a null map).

### (2) The translator

a. Data merges (`R: merge: A B [body]`, `Model: m`, the unit's typed-occurrence copies):
   - `l2_mrs_build` builds the MERGED layout instead of the flat one.
     - The model's rows come first.
     - Each later operand's and body's field whose name matches a placed row maps to that slot, if
       its type is assignable to the row's type; a type that is not is a located refusal.
     - A new name is appended.
   - The site emits a static `LmxMergePair` array and passes it.
   - `merged\x` is the one slot (`l2_mrs_slot_named` today returns the LAST occurrence).
   - `merged\[N]x` exists only for the model's own repeats (Q24's repeated typed declarations), so
     `l2_mrs_slot_nth` counts over the model's rows only.
   - The checks 71-74, 80, 90, 91 are re-derived from the map: the width is model + appended, and
     the first and last values follow from it.
b. Rows:
   - unit_merge_last_occurrence is rewritten to the override rule: R\x = 7 in the model's slot,
     R\y = 2, and `R\[1]x` is refused «merge occurrence index out of range».
   - unit_merge_occurrence_range_refused: `[1]` is now the one out of range.
   - FrozenA/FrozenB (unit_s1_merge_profiles_uncaught, unit_eternal_multi_profile_merge_refused)
     share `size_t: value`, so the width is 1 and the pinned call carries a map.
   - unit_merged_callable (Q22's hit counter) gets its missing harness row.
   - New rows: q22 → 3 and q20-next §2 → 5, inside a method.  Both are green today.
c. Pieces of the kernel list above: body pairs (1a) and earlier-slot pairs (1b) are needed only when
   a later operand or the body repeats a name the model lacks, or the body overrides the model.
   Everything else is expressible with today's kernel, so (2a) can land first on model-slot pairs.
d. Merge at the walked root, root-pending today (the K3 class, 7 rows of the coverage survey): a
   PRIM step with the map (1g).
e. Callable merge needs walked method bodies.
   - The norm: native bodies do not merge; the result is walked.
   - Today the translator emits an op-tree for the root only.
   - Prerequisite T-OT: every method whose body lies in the walkable subset (L3: numbers, fields,
     calls, if/while, return) also gets its body as an op-tree.  It lives in the occurrence after
     the fields, as code: OP frames are copier terminals, shared by address.
   - The native word stays for direct calls.  A merge result has `native` 0 and walks the copied
     tree over its own data.
   - A body outside the subset is a located refusal at the merge.
f. PAP (the author's example, LMX_blog 2026-09-25 :76, plan :331):
   - Source: `fn: add5 (int: x) int merge(y: 5; add)` over `fn: add (int: x; int: y) int return:
     x + y`.
   - add5 = merge(add; {y: 5}; the header of add5): args from the header (x), and y, a formal
     outside the declared signature, bound to the same-name field 5.  The body operators are add's.
   - Its native is 0, so a call of add5 goes through `lmx_call_prim` (dispatch by `native`), not the
     static symbol.  `add5: 1` → 6.
   - Parser/translator: the declaration form `fn: name (sig) ret merge(...)`.
g. makeAdder (§7, plan :696):
   - At `return: addN` in makeAdder, the translator knows addN's free names from the enclosing
     activation (n).  It emits a runtime Structure {n: <current value>} and the three-operand merge
     (addN; {n}; the header).
   - Each call returns a new callable with n as its own field.
   - `[add5: 1; add100: 1; add5: 1]` → `[6 101 6]`.

### (3) The converter (§7): a Structure holding a callable occurrence → a callable

- It is one more merge, at a conversion point: an assignment, argument or result whose target has a
  callable type.
- Source `{n: 5; addN}` (from `merge((n: 5); addN)`, which is not itself callable) against the header
  `fn: (int: x) int` gives merge(addN; {n: 5}; header).
- A source with no callable occurrence, or more than one, is a located refusal, and so is a header
  the occurrence cannot fit.  The translator decides statically, from the declared types.

## 3. Commit plan (kernel ↔ translator)

| # | Who | What | Depends on |
|---|---|---|---|
| K1 | kernel (Sonnet, after -192) | 1a–1d: body pairs, earlier-slot pairs, map validity, nested re-parenting; selftests and mutants | — |
| T1 | translator (Opus) | 2a–2b on model-slot pairs; rows rewritten, witnesses q22/q20 | — (lands before K1) |
| T2 | translator | 2a for body and earlier-slot pairs | K1 |
| K2 + T3 | walker prim + translator | merge at the walked root (1g, 2d) | K1 |
| T4 | translator | T-OT: op-trees for walkable method bodies | — |
| K3 + T5 | kernel + translator | callable merge by parts, operators replace (1e, 1f); PAP (2f) | K1, T4 |
| T6 | translator | makeAdder (2g) | T5 |
| T7 | translator | the converter (3) | T5 |

Open, for fable and the author:
- Q1.  The carrier of part recursion: a «merge into» pair kind with a sub-map in the kernel (1e,
  proposed), or per-part merges emitted by the translator.
- Q2.  Which operators replace: the OP frames among the body part's children (proposed).  A body
  with no operators leaves the model's.
- Q3.  T4 widens the walkable subset from the root to method bodies.  It is the prerequisite of
  everything callable here; is that the intended order, or does the author want the callable
  merges refused until the full L2 body port?

## 4. T1: data merge on model-slot pairs (branch opus/merge-193-t1, base 1889ca1)

fable: «GO T1» with Q1 = no new pair kind (one «merge into» primitive; the translator emits the
parts), Q2 = yes (the operand body's OP frames replace the model's, fields pair up), Q3 = T4 first,
and until then a callable merge is a located refusal.

The translator (l2trans.lm1) builds the MERGED layout in the pre-scan and hands the kernel a pair map:
- `l2_mrs_build` → `l2_mrs_join`, field by field:
  - the model's fields (operand 0) are the first rows, its own repeats included;
  - a later operand's field whose name a model row carries goes INTO that row (the last such row, the
    one `merged\x` names) when its type is the row's: same kind, and the same entry for kinds 2–6
    (nested, reference, callable, arrays).  It becomes a pair (model slot, operand, field) in the
    new source table `l2_msrc_*`, and it takes over the row's known value;
  - any other later field is a row of its own; the body fields come last.
- Refused, located (they need K1, or they are not an override):
  - a later field repeating a name an EARLIER operand added: «a merge operand field repeats a field
    an earlier operand added»;
  - a body field repeating an operand's field: «a merge result body field repeats a field of the
    operands»;
  - a same-name field of another type: «a merge operand field has another type than the model field
    of its name».
- The width is the map's (`l2_mres_width` is set in the pre-scan).  `l2_mres_first/last/fok/lok` are
  gone: each row carries the value the translator knows it holds (`l2_mrs_vk/val`).
- Emission: `c.array: [P]: LmxMergePair l2_mpv` and `c.array: [P]: @: LmxMergePair l2_mpp` beside
  `l2_mops` (P = the most pairs one merge passes, `l2_merge_pmax`).  At a merge with pairs:
  `l2_mpp[k]: @ l2_mpv[k]`, the three fields, and `…, l2_mpp, <P>U, @ l2_mresult)` in place of
  `0, 0U`.  A merge with no pairs keeps `0, 0U` (the kernel's layouts agree then).
- Checks.
  - 71: the width is the map's.
  - 74/75/77/79/80/90/91: each operand field is checked at the slot the map gave it, and only if it
    SURVIVED there (`l2_msrc_at`: no later operand wrote that slot again).
  - 72/73: the first and last slot's known values, from the rows.
- `merged\x` is the one slot.  `merged\[N]x` past 0 exists only for the model's own repeats, since
  the rows have no other repeats (`l2_mrs_slot_nth` unchanged).
- The other merge sites (`Model: m`, the unit's typed-occurrence copies) have one operand, so no
  pairs.

Rows (tools/l2_harness.ps1):
- unit_merge_last_occurrence: rewritten to the override rule and moved into a method (it was
  root-pending, so it never ran): R = {x, y}, `R\x` = `R\[0]x` = 7, the write lands in slot 0, and
  the operands keep 1 and 7.  eternal-runs, Entry 7, with the pair and the call pinned.
- unit_merge_occurrence_range_refused: `R\[1]x` is now the one out of range.
- New:
  - unit_merge_three_operands (B's x and C's x both into Model's x, C's last; B's z added; {3, 2, 9});
  - unit_merge_eternal_pair (FrozenB's value into FrozenA's slot: one slot, FrozenB's retained cell,
    2);
  - the three refusals above, and unit_merge_field_entry_refused (both `at` fields are
    references, to Point and to Size).
- FrozenA/FrozenB: unit_s1_merge_profiles_uncaught pins `…, l2_mprofiles, 2U, l2_mpp, 1U, @
  l2_mresult)`.  unit_eternal_multi_profile_merge_refused (root-pending, Debt not checked) gets the
  same pin.
- unit_merged_callable: moved into a method (it was root-level, root-pending «a Structure value»),
  its BOM dropped, and given its row (Entry 5; checks 77/79 pinned).
- q22 and q20-next §2 inside a method: unit_q22_merge_in_method (3) and unit_q20_merge_in_method (5).

Mutants (private variants, each against unit_merge_last_occurrence unless named):
- no pair found (flat layout): exit 82, and unit_merge_occurrence_range_refused translates;
- checking a field a later operand overwrote: X1 check 74;
- a pair that leaves the model's known value on the row: X1 check 72;
- no kind check: unit_merge_field_type_refused translates;
- no entry check: unit_merge_field_entry_refused translates.

For K1 (the kernel's map validity, 1c): with today's kernel an unpaired later field is APPENDED, so
two later operands carrying the model's name must both be pairs on the same model slot, applied in
operand order (unit_merge_three_operands).  «The same target twice is INVALID» would refuse this.
Either keep taking duplicate targets in order, or give the map a way to say «dropped».
