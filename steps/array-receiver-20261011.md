# R5 -- `[]` is a receiver over an element description: census, rule and cut plan

Date: 2026-10-11. Owner: `fable_pc` (the single writer/build slot). Status: **design, before code**.
Rule R5 of the receiver-routes census ([receiver-routes-census-20261010.md](receiver-routes-census-20261010.md),
cluster 3): `[]` is a receiver over an explicit element description, nested as written, with no depth cap;
`length` is the selected descriptor's. Norm Q56 and the registered defect
[ARRAY-COMPOSITION-DEPTH](defects.md#array-composition-depth); the replacement path
[receiver-resolution-20260930.md](receiver-resolution-20260930.md) (required result, replacement boundary,
staged access). The ticket: [critical_general_receiver_routes_bug](tickets/critical_general_receiver_routes_bug.md).

## What the code does today (read on `d70a72ce`)

1. **The contract tree is already general.** `l2_contract_type` (l2trans.lm1 ~8701) resolves a type operand
   recursively: kind 1 is `[]`, kind 2 an address depth, 3 `const`, 4 `immutable`, 5 `independent`, and the
   operand is the element description -- `[]: []: int` is kind 1 over kind 1 over the word `int`. Nothing in
   the contract caps the depth.
2. **Its consumers are not.**
   - `l2_contract_own` (~17200): kind 1 over a numeric word gives the own array codes 4 (int), 5 (char),
     7 (size_t), 37 (ulong) -- `unsigned` has no array code; kind 1 over kind 2 gives an Array of pointers
     (`l2_oc_parray`); kind 1 over kind 1 gives 0, and the declaration is refused as "unsupported own array
     declaration" (14316, 29860), which also demands a count literal (`l2_own_array_count`).
   - Named-Structure fields (`l2_take_ns_body`): `l2_ns_arrarr_field` (23606) recognises exactly
     `T: []: []: name` for T int or char and registers kind 6 -- an outer Array of descriptors
     (`LMX_TYPE_ARRAY_OF_DESC`) constructed EMPTY (23502), the author's Q15 "two levels of independent
     one-dimensional Arrays"; `[]: <int|char> name count` (24205) registers kind 5 and refuses size_t,
     unsigned and ulong elements ("an array field element is int or char").
   - The walk side reads one contract level (`l2_rw_elem_ty`, 41881) and the own-array declaration frame
     needs a body of three (45938).
   - Indexed access is one route of its own: `l2_arr_operand` (26898) takes one field path with at most TWO
     decimal-literal indices on kinds 5 and 6, `l2_emit_arr_operand` (26986) emits the one- or two-level
     read (`l2_cpN[i0]`, `l2_asN[i0]` then `l2_cpN[i1]`), `l2_arr_len_shape` (27035) answers
     `length(P)` and `length(P[k])`. A computed index, a third index or an index on anything but these two
     kinds leaves the route ("unsupported" at the operand).
   - The kernel needs nothing new for depth: Arrays are typed descriptors (`lmx_array_new_owned(type,
     count)`: `LMX_TYPE_ARRAY_OF_CHAR` 5, `_INT` 6, `_SIZE_T` 16, `_ULONG` 20; `lmx_array_ref_new_owned`:
     `_LMX` 10, `_DESC` 11), a descriptor cell is `LMX_TYPE_DESC` 9, and the walker's ELEM/ELEMPUT/LENGTH
     frames already select an element of an Array of descriptors as a place of type DESC (`lmx_walk_place`).
     There is no Array of `unsigned` element type in the kernel (`LMX_TYPE_ARRAY_OF_UNSIGNED_CHAR` 18 is the
     char one).
3. **Rows today:** twenty own-array fixtures (`unit_addr_own_array_*`, `unit_arr_path_*`, `unit_array_*`),
   `unit_arrarr_field` (the Q15 two-level field, constructed empty and merged), and the seventeen
   `unit_matrix_*` rows (callable matrices; not this cluster's depth).
4. **The author's forms** (the replacement path, "Staged access"): `[]: []: []: a` / `[]: []: b a[i]` /
   `[]: c: b[j]` -- ordinary bindings to the selected Array values, observing reference identity, values and
   lengths, with actual typed values for a, i and j -- and the direct access `a[i]\[j]\[k]`, where each `\`
   continues from the selected value; `[i]name` stays the same-name occurrence selector and adjacent
   `a[i][j][k]` stays the flat C-like form. No inference of rectangularity, no Array-path resolver of its
   own, no index-count cap, no dimension recovery.

## The general rule the implementation has to meet

R5-G1. A declaration's element description is its contract tree, and ONE function derives from it, at every
consumer (own fields, named-Structure fields, formals, the native and the walked emission), what the receiver
builds: a numeric D is a typed Array of `count` cells; `[]: D'` is an Array of descriptors of `count` cells,
each to hold an Array of D' made where the source makes it (a declared field with no count is constructed
empty, as Q15 says); `@: ...` is an Array of pointers (today's parray); a Structure name is an Array of
references (later, by the same function). The depth is the contract's.

R5-G2. A name bound to an Array value -- `[]: D name value` -- is a binding of a descriptor-typed cell
(`LMX_TYPE_DESC`) to the selected Array; D is checked against the value's descriptor type; `length(name)` reads
that descriptor; writes through the name are seen through the value it was selected from (reference
identity).

R5-G3. Access resolves each path step against its current typed operand and hands the typed result to the
next: `name[i]` on an Array of descriptors is the inner Array (a DESC value), on a typed Array an element
lvalue; `\` continues from the selected value; an index is an ordinary expression evaluated once. No
literal-only indices, no two-index cap, no separate Array-path algorithm: Structure-field and Array-element
steps differ in storage projection only.

R5-G4. Native and walker consume the same resolved declaration and the same resolved steps; `length` uses
the step's result.

## Cuts, in dependency order

Each cut: minimal witnesses native and walked (the root walked where the fixture is root-level), a mutant per
rule it introduces, the kernel gate, L3 and the focused harness of the cluster before the commit; the old
rows of the cluster stay green on the same bytes or move with an explained diagnostic; the located limits that
remain are said by their own message at the item, as temporary limits, never as completion.

- **R5-1 -- declarations by the contract, any depth, all representable element types.** Replace
  `l2_ns_arrarr_field` and the int/char-only reader of `[]: T name count` by one contract-derived reader for
  named-Structure fields and own fields: `[]: T name count` for every numeric T the kernel has an Array of
  (int, char, size_t, ulong; `unsigned` is a located limit until the kernel has its element type), and
  `T: []: ... []: name` at any depth of two or more (every outer level an Array of descriptors, the
  declared field constructed empty as today's kind 6). Delete the fixed recognizer in the same cut. Witnesses:
  a three-level declared field constructed empty and merged (`length` 0 after the merge), a size_t Array
  field with a count written and read natively and walked, the refusals of a non-literal count and of an
  element description that names no type. Old rows: `unit_arrarr_field`, `unit_array_field`, the own-array
  rows unchanged.
- **R5-3 -- `a[i]\[j]\[k]`: the unnamed index step of the path.** An unnamed `[i]` step in a field path
  indexes the current typed operand (an Array of descriptors gives the inner Array, a typed Array an element
  lvalue), `\` continues from the selected value, each index expression evaluated once; the native path
  emitter and the walker's ELEM frames chain per step. Witnesses: a two-level own Array filled through
  `a[i]\[j]` and read back natively and walked; `length(a[i])`; a refusal of an index on a non-Array
  value, located at the step.
- **R5-2 -- the author's staged bindings.** `[]: []: b a[i]` and `[]: c: b[j]`: a descriptor-typed binding to
  the selected Array (R5-G2), `length(b)` and `length(c)`, a write through c seen through a (reference
  identity). The witness is the author's, with actual typed values for a, i and j. The binding's own
  representation (a descriptor cell among the own codes) is this cut's design choice, probed first.
- **R5-4 -- general indices; the two-index route deleted.** `l2_arr_operand`, `l2_emit_arr_operand` and
  `l2_arr_len_shape` go; one-level reads, writes and `length` use the step resolver of R5-3 with any index
  expression. Witnesses: a computed index natively and walked, a three-index read on a three-level Array, the
  bounds fault as the ordinary `interpreter` throw where the walker already has it.

## What this design does not decide

Whether a declared inner level may carry a count of its own (`[]: 3 []: 4 int m`) is not the author's form
and is not built: the inner Arrays are made where the source makes them (R5-G1). The flat C-like `a[i][j][k]`
form is retained as it is (the replacement path). A question to Codex arises only if a cut meets a concrete
contradiction with the book or these sentences.
