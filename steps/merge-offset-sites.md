# Merge offset: the translator's lexical-parent sites (Opus, FABLE-OPUS-MERGE-ADDRESSING-20260924-154)

Read-only inventory for -154 commit 1 (the hidden `offset`), held until the author answers Q22
(`q22.md`) and Grok's -153 puts `offset` into `LmxCallable`. Counted on `l2trans.lm1` of
`opus/merge2` (base `f667cc8` plus commit 2).

## One choke point

Every address the translator emits for a field of a method's lexical parent goes through one
variable, `l2_unit_ref`. It is set per emitted function: `"node"` in a method, `"self"` in E (E has no
parent; its occurrence is the unit). Every such address is `(l2_unit_ref, J)` with `J` known at
translation time.

- 29 emission lines name `l2_unit_ref` as a container:
  - `l2_emit_stmts`: 17 (merge operands, merge-shape checks, result stores, named-Structure
    stores);
  - `l2_emit_path_to`: 5 (path roots: named Structure, eternal branch, method occurrence, merge
    result, `node`);
  - `l2_type_inst`: 2;
  - `l2_tok_method_occ`, `l2_prep`, `l2_own_ctr`, `l2_mrs_occ_read`, `l2_emit_call`: 1 each.
- `l2_own_ctr` returns `l2_unit_ref` in 4 cases. It is the container of an own field that belongs
  to E (a unit field) or to another method's occurrence. The caller adds the cell index; the
  offset belongs on that index when the container is `node`.
- The `node\x` root (-121): `l2_pst: node` (:11594). Its first hop is written by the hop loop
  (`i = 1 && root = 0 - 2`, :11622; `l2_emit_path_to`'s `ref_struct/ref_cell(l2_pst, slot)`), and
  the offset belongs on that first slot only.

So commit 1 is one helper: the index text of a unit child, `l2_moff + JU` in a method and `JU` in E.
It replaces the `%uU` of those sites, plus the first-hop slot of a `node` root. The prologue reads
`l2_moff` from `self`'s child 0 through -153's accessor.

## Which reading the sites serve (q22.md)

- **Reading I, as the -154 spec is written:** every site above takes `offset + J`, where `J` is the
  index in the method's lexical parent. That is the unit for every method today: `A: fn: M` is a
  reference to the unit-level `M`. It is correct only while the operand region of a merge result
  repeats the unit's layout. q22.md has the minimal program where it does not (an X1 abort).
- **Reading II, recommended by the coordinator:** a copied callable-field occurrence keeps its
  lexical parent, so `node` stays the unit, no site changes, and `R\M()` reads the unit's field.
  `offset` then serves only methods declared inside a Structure body. There the same helper is
  exact by construction, because `J` is the index in that Structure's own layout.

## Commit 2, done separately (it needs neither -153 nor Q22)

`merged\x` is the last occurrence of `x` in a bound merge result:
- `l2_mrs_slot_named` returns its last match; it used to refuse the name as "ambiguous field path
  segment";
- `merged\[N]x` counts occurrences in operand order (`l2_mrs_slot_nth`, `l2_mrs_occ_read`);
- the flat-token form matches Sonnet's `test\[N]name`.
