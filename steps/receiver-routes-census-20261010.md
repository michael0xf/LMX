# Receiver-routes census — `critical_general_receiver_routes_bug`, step 1 (`fable_pc`, 2026-10-10)

Reading only, on `3b4ffe68` (every line number below is of that commit); no gate was run for this
census and nothing in the translator changed. Ticket:
[critical_general_receiver_routes_bug](tickets/critical_general_receiver_routes_bug.md);
its sibling [critical_qualifier_receivers_bug](tickets/critical_qualifier_receivers_bug.md).
The author's two sentences (verbatim in [`LMX_blog/2026-10-10.md`](../LMX_blog/2026-10-10.md#qualifier-receivers-20261010)
and the section beside the second ticket): the three qualifiers are three receivers consuming any
Structure; an unknown name accepts a Structure, and `merge` in that position is no special case.

The rule the census is read against: P0 forms the whole pair "head and arguments" from the
source tree; one resolver (`l2_head_absent`, `l2_head_resolve`) says what the head is; the
receiver's contract takes the arguments afterwards. A receiver written inside the tail
(`merge`, `int`, `[]`, `independent`, ...) never decides the outer head's role by its spelling.

## Cluster 1 — `merge` in the tail decides the outer head's role

| site | what it reads | decided by the tail's word? | verdict |
|---|---|---|---|
| `l2_merge_construction` 4921 | the first item of a frame's body is `merge`'s application | yes: a spelling test | the test itself may stay as a reader of merge's application; every ROLE use of it goes |
| `l2_unit_role` 5235 (root items) | absent head with a retained body is a named Structure (5), unless the tail begins with `merge` (then a statement of E, 0) | yes | REMOVE the exception: the head's role is the resolver's; the tail is read after |
| `l2_local_absent_def` 12703 (a method's statements) | the same exception for the definition route | yes | REMOVE, same |
| `l2_ns_nested_def` 23656 (a named Structure's body) | the same exception for a nested definition | yes | REMOVE, same; the statement route it falls to is the right one: a named Structure's body is a procedure's body (Q45), and `box: merge: Host\inner` there declares the procedure's own row (`unit_merge_parent_named`, `unit_ns2_copy_field`), not a field read from outside |
| `l2_unit_value_above` 5125 | an item `a: merge ...` above binds `a` as a Structure value (so `b: a` below is a binding) | yes, as one of three spellings | GENERALIZE: a head declared above binds its name whatever its tail is; no spelling list |
| own schema 12767 | an own row whose declaration's application is `merge` has the merge record as its schema | yes, re-recognized from the spelling | KEEP the schema; read it from what the row recorded when it was declared, not from the spelling again |
| check pass 29685 | `x: merge` with no operand is refused at the merge ("merge needs at least one operand") | reached only through the construction test | KEEP as merge's contract, entered once `merge` is resolved as the receiver |
| `l2_merge_frame` 51053, `l2_merge_declaration`, `l2_merge_body` | the outer statement's body is one or two items, the first a `merge` frame, the second a Structure (the result body) | yes, plus `l2_is_asgn` and the own-row / colon-bound tests | the SHAPE part goes to the resolver; the contract part stays as merge's reader of its own application |
| callers of `l2_merge_frame`: 13833 (collection: own row `l2_graph_own`), 14798 (scan of operands), 19483 (`l2_src_merge`, the root's walked step), 29741 (operand check), 41196 (native emission), 45716 (walker root step), 51071/51083 (arity), 51965 (a merge throws `merge`), 52070/52147/52202 (use records, result schema), 52705–52763 (walker PRIM) | merge's own contract: operands, result body, schema, emission, throws | no (they read merge's application) | KEEP in substance; they are entered from the declared head's content, not from a role gate |

Fixture rows pinning the cluster (`tools/l2_harness.ps1`, names matching `k03_merge|merge_decl|merge_op|merge_body|mres`):
42, of which 28 positive and 14 refusals. The refusals by their diagnostic:
- merge's contract, to keep on the same bytes: "a merge operand is not a Structure"
  (`unit_k03_merge_op_expr_refused`, `unit_k03_merge_op_name_number_refused`, with `_walk`),
  "unhandled throw: Oops" (`unit_k03_merge_op_call_throw_refused`, `_walk`);
- limits of the structural operand route, to lower (cluster 5): "this merge operand form is not
  lowered yet" (`unit_k03_merge_op_group_two_refused`, `unit_k03_merge_op_t7_anon_refused`,
  `unit_k03_merge_op_bare_field_limit`, with `_walk`; the last is the author's named argument,
  plan step MERGE-NAMED-ARGUMENT-OPERAND);
- a value-position limit: "merge expression is not lowered in this receiving context" (27769;
  `unit_k03_merge_app_operand_refused`, `_walk`: `w: merge(Model) + 1` in an int expression). Under
  the rule merge's contract yields a Structure there and `+` refuses it by type; the diagnostic
  moves from "not lowered" to the operand's type contract, on the same bytes.
Known red positives of the cluster (red in `codex_interpreter_throw_full_02` and in every run since,
details unchanged): `unit_k03_merge_op_anon_typed` and `_walk`, `unit_capture_struct_merge_two`,
`unit_t7_host_nested_return`, `unit_copy_call_addressed`, `unit_copy_call_from_method`,
`unit_copy_call_other_owner`.

## Cluster 2 — the qualifiers are one static chain at one place

| site | what it reads | verdict |
|---|---|---|
| `l2_unit_role` 5205 | a root item whose application head is `independent` is role 2 | REMOVE the role: `independent` is a receiver applied to its argument, resolved as every head is |
| `l2_take_eternal` 27049 (caller 5964) | exactly `independent → const → immutable → ()` with a name and a Structure body, at the unit root; diagnostics "independent takes one qualified construction", "independent branch requires const", "independent branch requires immutable", "independent qualifies Structure construction", "eternal branch takes a name and a body", "eternal branch needs a name", "eternal branch takes a body block" | REMOVE as a shape; what it registers (the branch, its entries `l2_ns_eternal`, `l2_ebr_*`) becomes the effect of the combined qualification over a parentless Structure value, wherever the source writes it |

What each receiver's own contract is (book: [qualification](../docs/LMX_semantics.en.md#qualification),
[composition](../docs/LMX_semantics.en.md#composition), [eternal](../docs/LMX_semantics.en.md#eternal)):
`const` protects the binding, `immutable` the value through every alias, `independent` the
ownership of a value with no external lexical parent; only the combined qualification makes the
eternal branch that `merge` retains by its exact physical profile. The copier keeps that identity by
`lmx_copy_retained_profiles` (COPIER-FULL-COPY, 2026-10-10): a value qualified at run time must own
its profile before publication, or a later merge copies it. This is the one place where this ticket
and the full-copy rule have to agree; a conflict goes to the author as the smallest witness.

Fixture rows (names matching `qualified|eternal|independent|s2_vis_branch`): 59, of which 34
positive, 8 graph-x1, 1 library, 16 refusals. Refusals that are each receiver's contract and stay
on the same bytes: "an eternal branch field cannot be updated" (three rows), "call would initialize
an immutable field" (two), "an eternal branch cannot reference mutable storage" (`unit_ns2_eternal_mutable_refused`,
`_walk`), "the address of an eternal branch field cannot be taken" (two), "merge is a word of the
language: a program cannot bind it" (`unit_rn_eternal_merge_refused`, `_walk`), "unbound dynamic
input cfg" (`unit_s2_vis_branch_refused`, `_walk`). Refusals that pin the SHAPE and will change
their diagnostic or become acceptances: "independent takes one qualified construction"
(`unit_k03_unit_bare_independent_refused`, `_walk`: `independent` written bare stays a refusal, by
the receiver's arity, not by the chain), "independent branch requires const"
(`unit_eternal_profile_partial_refused`: `independent` alone over a Structure is that receiver's
application; whether it is accepted follows its own contract, and the eternal exception is not
granted without the other two). The author's example of the ticket
(`return: independent: const: immutable: merge(Integer  int: value newValue)` in a method) reaches
no acceptance today: the only route is the root-level `(): Name` chain.

Slice RR2c-2a (`fable_pc`, 2026-10-10; record in
[qualifier-receivers-20261010.md](qualifier-receivers-20261010.md)): the chain is accepted in a
declaration's tail, in a method and at the root, in the order and part the source writes, each word its
own contract. Slice RR2c-3 (`fable_pc`, 2026-10-10): the return position too -- the author's example
as written is accepted, the returned merge a hidden declaration the method returns (`unit_rr2_return_merge`).
Slice RR2c-2b (`fable_pc`, 2026-10-10): `immutable` without `independent` -- the value sealed under its
ordinary lexical parent (the root's `parent` a structural link, Q2 resolved from the book) -- and a qualified
result holding a callable (the occurrence a leaf, kept by address); a later merge over a parented qualified
value copies it (`unit_rr2_qualified_merge_immutable`, `unit_rr2_qualified_merge_callable`). Slice RR2d-1
(`fable_pc`, 2026-10-11): the qualified merge and the returned merge walk -- a PRIM entry of their own with the
qualifier trailer, the hidden row written then returned -- at the root and in methods under `--walk-methods`
(`unit_rr2_qualified_merge_root`, `unit_rr2_return_merge_plain`). Slice RR2d-2 (`fable_pc`, 2026-10-11): the typed
operand walks too -- the field PRIM builds the anonymous one-field Structure of the declaration's kind -- so the
author's example as written walks (`unit_rr2_merge_op_typed_root`; the `_walk` twins of the typed-operand witnesses).
Slice RR2e (`fable_pc`, 2026-10-11): the chain over an existing named Structure is refused by name at the chain -- an
operation of RuntimeImmutable, not built; `const` alone a binding not built -- in place of the generic "unsupported
body" (`unit_rr2_qualified_existing_refused`, `_root_refused`, `unit_rr2_const_existing_refused`); the chain over an
anonymous Structure is a located limit of its own (`unit_rr2_qualified_anon_limit`); the typed operand written
without a value declares its cell and writes nothing, natively and walked (`unit_rr2_merge_op_typed_novalue`).
Slice RR2f-2 (`fable_pc`, 2026-10-11): the chain over an anonymous construction -- the receiver's actuals its typed
fields -- is built through the qualified-merge route, one operand per field, at the walked root and in methods
(`unit_rr2_qualified_anon`, `unit_rr2_qualified_anon_method`; the write and const refusals); a repeated field name, a
nested group, a literal and a construction of other items are located limits of their own names; the chain over an
existing value stays RR2e's limit until Q3 (two-stage) is answered.
The run-time value owns its profile
before publication, so a later merge retains it (the cluster's agreement with the full-copy rule
holds); the kernel's coverage proof had refused every fresh qualified composition until the copier
stopped allocating the composition's discarded intermediate roots under the destination profile.

## Cluster 3 — `[]: []:` is a fixed two-level shape

| site | what it reads | verdict |
|---|---|---|
| `l2_ns_arrarr_field` 23512 (caller 24082) | exactly `int`/`char` → `[]` → `[]` → name, one field each | REMOVE the fixed depth: `[]` is a receiver applied to an element description, nested as written |
| `l2_arr_operand` 26803 (callers 26964, 28939, 35057), `l2_emit_arr_operand` 26891, `l2_arr_len_shape` 26940 (callers 11887, 27976, 33919) | an indexed path with at most two literal indices `i0/i1`, a declared depth, `length` from the shape | REMOVE the cap; `length` is the selected descriptor's; computed and literal indices through the same route |

Already registered: [defects.md#array-composition-depth](defects.md#array-composition-depth). Fixture
rows (names matching `arrarr|arr_arr|array_array|arr2|matrix`): 18, 15 positive; the three
refusals are not of the array route ("unsupported body", "incompatible entry signature", "more
arguments than bar has formals").

## Cluster 4 — the merge result body accepts one field form

`l2_rw_merge` 41196 (native) and the walker PRIM emitter 52705 take, in the appended body of
`R: merge: A B` + body, only `size_t: name <decimal literal>` (41357, 52729: "unsupported merge
result body field", "a merge result body field needs a literal"). Verdict: the body's items are the
ordinary field declarations and statements of a Structure body (`l2_take_ns_body`'s model); an
unsupported semantics gets its exact diagnostic, never a field-shape filter.

## Cluster 5 — the structural merge operand

`l2_merge_decl_operand` 51174 and `l2_merge_operand_limit` 51129 accept a name, a path to a
Structure and a call with a named result; they refuse "this merge operand form is not lowered yet"
for an anonymous typed Structure `(int: v 9)` (`unit_k03_merge_op_anon_typed`, a red positive), a
group of two, a T7 anonymous operand and the bare field `v: 9` (the author: a named argument).
The author's `merge(Integer  int: value newValue)` is the typed-declaration operand: first show its
P0 grouping with the general parser, then lower both structural operand forms through one route; do
not rewrite the example into `value: newValue`.

Slice RR2c-1 (`fable_pc`, 2026-10-10; record in
[qualifier-receivers-20261010.md](qualifier-receivers-20261010.md)): the typed-declaration form is
lowered through one route for both spellings -- the P0 grouping measured first: `merge(Integer  int:
value newValue)` is two actuals (an atom, then the Frame), `(int: v 9)` a group holding the Frame, and
`(int: v 9  int: w 2)` ONE Frame whose candidate is two values (P0 hangs a following Frame on the
preceding one), refused by the declaration rule. `unit_k03_merge_op_anon_typed` is green. The bare
field `v: 9`, the group of two and the T7 anonymous operand keep their limits.

## Classifiers read and kept as the resolver (no spelling of a nested receiver decides them)

- `l2_head_absent` 4891: no method (visible both ways), no field of the unit, no C door or declared
  function, no primitive type word, no word of the language, no earlier frame headed by the name
  above the item, no `@: t f(a)` receiver above; read in source order before registration. This is
  the "absent" answer of the single resolver; its one general clause "an earlier frame headed t binds
  t, whatever its tail is" is the rule cluster 1's `l2_unit_value_above` should reduce to.
- `l2_head_resolve` 7781: 1 a word of the language, 2 a method, 3 a held callable, 4 a value, 5 a
  named Structure, 6 the C door or a declared function, 7 a define; with the outside flag for a
  binding that is not the activation's own.
- `l2_ns_body_stmt` 23885: in a named Structure's body a method's call or a word's application is a
  statement; a declaration, a nested definition or a binding is a field. Keep; its merge clause goes
  with cluster 1.
- `l2_ns_field_word`: the words that declare a field (`size_t`, `int`, `unsigned`, `ulong`, `char`,
  `[]`, `()`, `fn`). Keep: these are receivers that declare.
- `l2_empty_call_shape` 12404, `l2_empty_struct_assign_shape` 12416, `l2_empty_struct_decl_shape`
  12450: `t()`, `t: ()` and the closed empty vertical form are one P0 Frame; whether it calls a bound
  Structure or declares an absent one is the head's resolution, and a word of the language is never
  an absent head. Keep.
- `l2_declaration` 8719: the receiving contract of a Frame (type word, name, candidate); a Frame
  resolved as a call declares nothing; `b: A` through `l2_rb_declaration`. Keep.

## Slice RR1 — the role gate of cluster 1 (`fable_pc`, 2026-10-10)

Code: `l2_merge_construction` (the spelling test that decided the OUTER head's role in `l2_unit_role`,
`l2_local_absent_def` and `l2_ns_nested_def`, and was re-read in `l2_unit_value_above`, at the own
schema site and at the arity check) is gone. `l2_value_receiver` names the receivers whose
application yields a Structure value an absent head accepts (`merge`; the qualifiers join it with
R4), and `l2_decl_content` reads an absent head's tail AFTER the resolver has made the head a
declaration: 3 a VALUE (a statement of the enclosing procedure -- E's, a method's, a named
Structure's -- declaring the head's own row), 1 a BODY (a named Structure). The six sites read the
content kind, and `l2_merge_declaration` -- the reader the collection, scan, check, throws and walker
passes ask before any other route -- asks the content kind first and merge's own application reader
(`l2_merge_frame`) after it, so no pass routes a statement by the word before the head's content is
read; merge's contract (arity at the word, operands, result body, schema, emission) is unchanged and
is entered from it. Behaviour is unchanged by design (the storage of a value
declaration stays the procedure's own row, the unit's child indexes do not move). A first draft of
the slice also made `x: merge: Model` in a unit Structure's body a FIELD of the Structure (the kind-3
slot); `unit_merge_parent_named` showed the established reading -- the body is a procedure's body
and `box: merge: Host\inner` declares the procedure's row, read inside the body -- and the draft was
withdrawn before any commit; the book's construction sentence now says so in both languages.

Evidence: focused harness `build/l2_harness/fable_rr1_focus_02` (148 targets, 11 failed, all eleven pre-existing reds with unchanged details -- `unit_ns2_ref_arg`, `unit_ns2_ref_return`, `unit_ns2_ref_admit`, `unit_ns2_ref_capture` and their `_walk` twins, `unit_k03_merge_op_anon_typed` and `_walk`, `unit_held_definition_free_name`; against `codex_interpreter_throw_full_02` FAIL->OK 0, OK->FAIL 0; the same set in the two earlier runs of the slice, `fable_rr1_focus_01` and `_02`); L3 `build/l3/fable_rr1_l3_01`
(all 11 suites ok, type budget ok); mutant on isolated bytes (`scratchpad/mutant_rr1`): `l2_value_receiver` answering 0 --
the real translator and the mutant translate `unit_merge_parent_named` (a named body), `unit_mres_ref_field_path` and `unit_root_merge_body` (the root), `unit_k03_merge_op_path_roots` and `unit_merge_in_method` (a method) differently, the mutant refusing each (a merge operand read as the content of a definition, a field path through a vanished row, an end target of a Structure R that is now a named one); the no-operand refusal `unit_k03_ns_bare_merge_refused` keeps identical diagnostics under the mutant, as the contract of merge should. `python tools/check_docs.py` and `git diff --check` clean.

## Slice R6 -- the merge result body is an ordinary Structure body (`fable_pc`, 2026-10-11)

Cluster 4, rule R6. Measured first: on the translator before the change (582b84b5) the typed witness was refused at the READ of its int field -- unit_merge_body_typed.lm2:15:8: the program has no method lm_stg_convert_size_t_int, the receiver of this conversion -- the body field having been typed size_t whatever the source wrote, and each of the three refusal witnesses was refused at the MERGE STATEMENT with the one filter message "unsupported merge result body field" (7:1 / 7:1 / 6:1), not at the item. Built: a body item is a typed field declaration of an own
numeric type -- `int`, `char`, `size_t`, `unsigned`, `ulong` -- with a literal; it joins the result schema with
ITS kind and type word (`l2_mrs_build`, `l2_own_nsf_kind`), and is built as a cell of that type in the walked
PRIM record (`l2_rw_merge_prim`: `lmx_walk_store_<T>`) and natively (`l2_emit_stmts`: `lmx_<T>_new_owned`,
`lmx_<T>_store_known`), so `R\w` reads back as the type the source declared (`l2_merge_body_ty`,
`l2_merge_body_field`, `l2_merge_body_store_walk`, `l2_merge_body_store_native`). What the cut does not build is
said exactly where the item stands, never by a field-shape filter: "a merge result body statement is not built
yet", "a merge result body field of this type is not built yet" (a reference, a Structure), "a merge result body
field without a value is not built yet", "a merge result body field with an initializer expression is not built
yet". The kernel is unchanged: the merge consumes the body as another operand and copies its cells by their type.
Witnesses: `unit_merge_body_typed` (Model's size_t x plus the body's int w, char c and unsigned u, each read back
as declared, the int one in int arithmetic: exit 7; natively and with the root walked) and the three refusals
`unit_merge_body_stmt_refused`, `unit_merge_body_expr_refused`, `unit_merge_body_type_refused`, each located at
its item. The old rows (`unit_root_merge_body`, `unit_merge_body_repeat` and the 42 merge rows) unchanged.
Evidence: kernel `fable_r6_kernel_01` (GREEN: 300 targets, no failures); focused harness `fable_r6_focus_01a` (610 targets, 16 failed), `fable_r6_focus_01b` (609 targets, 19 failed; all 35 pre-existing with unchanged details against the full baseline with the later focused runs superseding their rows; FAIL->OK 0, OK->FAIL 0, the five new rows added, all OK); L3
`fable_r6_l3_01` (all 11 suites ok, type budget ok); mutants on the staged translator: the body field's own kind dropped from the result schema -> the typed witness is refused at the read of its int field, "the program has no method lm_stg_convert_size_t_int, the receiver of this conversion" (15:8), where the real one exits 7; the int head read as size_t -> the same refusal, natively and with the root walked; the located refusals collapsed to one filter message -> the statement witness says "unsupported merge result body field" where the real one names the statement, so its Needle goes red. Still open in this cluster
(Codex, CORRECTION CODEX-R6-SCOPE-20261011-102505: this is a bounded numeric-literal slice, R6-1, not the rule):
statements, reference and nested-Structure fields, fields without an initializer and initializer expressions must go
through the common body construction path (`l2_take_ns_body`'s model) rather than the merge-only typed-literal
helpers; each is a temporary located limit by its own message, and rule R6 / cluster 4 stay OPEN until R6-2 (the
tasks and witnesses: next_core_tasks_v2.md, the CRITICAL / OPEN paragraph).

## Slice R6-2 (1) -- the merge result body read by the common body construction (`fable_pc`, 2026-10-11)

Cluster 4, rule R6: the first R6-2 task (Codex, CORRECTION CODEX-R6-SCOPE-20261011-102505), task (2) falling out of it.
Measured first, on `3e1ea995` with a probe translator: the common body construction (`l2_take_ns_body`) admits what the
merge-only reader did not -- a nested Structure, an Array, a typed reference, a binding -- and classifies `int: w 2 + 2`
as a computed declaration, a statement of the body (K03 RECEIVE-OUTPUT); it refuses `int: w` at the Structure's line
as "a named Structure field needs a name", refuses `@: p Model` at the item as "unknown type", takes `char: c 65` as
no char literal ("a char field needs a quoted single character"), and accepts `@: Model p Model` yet drops the value:
p holds nothing ([defects](defects.md#ns-ref-field-value-dropped), NS-REF-FIELD-VALUE-DROPPED). Built: the result body
is a named-Structure entry the translator synthesizes (`l2_merge_body_entry`, once per result, found again by
`l2_mres_body_ns`; a synthesized entry as a letter model is, `l2_ns_synthesized`: a unit child of the tail, named
" merge body N" as `l2_letter_synth_name` names a letter), its items read by `l2_take_ns_body` where the merge's method
stands (`l2_ns_take_mi`), its fields joined to the result schema as any named operand's are (`l2_mrs_take_entry`,
operand n), its instance built by the unit's construction with every field kind the common path has
(`l2_emit_ns_cells`, `l2_emit_ns_refs`), and handed to the merge as a named operand is -- natively the unit child
(`lmx_arena_ref_struct`), walked the builder's node stored into the PRIM with its use noted (`l2_use_unit_child`) --
which the merge copies as it copies every operand; the kernel is unchanged. The merge-only helpers `l2_merge_body_ty`,
`l2_merge_body_cell_word`, `l2_merge_body_field`, `l2_merge_body_store_walk`, `l2_merge_body_store_native` are deleted.
What the common path reads but no merge carries yet is said where the item stands, a temporary located limit: a
statement of the body (a computed declaration among them), "a merge result body statement is not built yet"; a
callable field; a reference field with a value (R6-2 task 4: formed where the merge stands); retained content; the
binding `b: A` meets the common path's own limit for a body read where a method stands ("a reference binding in a
method's named Structure is not built yet", at the target). Witnesses: `unit_merge_body_typed` (its char field now the
common path's `'A'`; natively and with the root walked), `unit_merge_body_nested` (a nested Structure `Inner` with v,
an Array xs of two ints and the typed w beside Model's x, each read back through the result -- `R\Inner\v`,
`length(R\xs)`; natively and with the root walked), `unit_merge_body_ref_null` (the body's `@: Model p` in a method's
merge: the result's p holds nothing and `R\p\v` is the implicit interpreter throw, taken by the catch; natively and
with the methods walked), the refusals `unit_merge_body_stmt_refused` (9:5, unchanged), `unit_merge_body_expr_refused`
(8:5, now the statement message), `unit_merge_body_type_refused` (7:5, "unknown type"),
`unit_merge_body_callable_refused` (12:5), `unit_merge_body_ref_value_refused` (8:5), `unit_merge_body_bind_refused`
(9:8, the common message); the old rows (`unit_root_merge_body`, `unit_merge_body_repeat`, `unit_merge_in_method`, the
merge, letter and null-reference rows) unchanged on the same bytes. Open in R6-2: (3) a field without an initializer
(the common path refuses `int: w` at the Structure's line by a misnamed message; by the author's rule a cell holding an
unknown value), (4) initializer expressions formed where the merge stands (the reference field's value with them), (5)
the body's statements as the result's procedure; the callable field and retained content wait with them. Evidence:
kernel `fable_r6_2_kernel_01` (GREEN: 300 targets, no failures); the focused harness over the 1687 rows in two halves, `fable_r6_2_focus_01a` (847 targets, 21 failed) and `fable_r6_2_focus_01b` (846 targets, 22 failed), compared by fixture identity and outcome with chain 04 on `3e1ea995` (compare_summary.py over the merged halves): 7 rows added, all OK; 0 removed; 0 FAIL->OK; 2 OK->FAIL -- `unit_merge_body_expr_refused` and `unit_merge_body_type_refused`, whose header comments had grown by one line in this cut and moved the pinned items off 8:5 and 7:5; the headers were restored to their line counts (comment text only; the translator bytes unchanged) and the two rows re-run in `fable_r6_2_focus_01c` (5 targets, 0 failed: refused as expected at 8:5 and 7:5), so the 41 remaining failures are the pre-existing ones; `fable_r6_2_l3_01` (all 11 suites ok, type budget ok); the gated translator bytes are the live sandbox bytes in all three runs (sha256 b05682efa16614a8...). Mutants: on the staged translator of `fable_r6_2_focus_01a` (mutant_r6_2.sh): M1, the body entry's fields are not joined to the result schema -> `unit_merge_body_typed` and `unit_merge_body_nested` are refused at the read of the body's field, 'unresolved name' (16:10, 17:10); M2, natively the body handed to the merge is 0 -> `unit_merge_body_typed` aborts natively, 'lmx: invariant: a field path met no Structure' (exit 3), while its root-walked twin stands; M3, the walked PRIM stores no body -> the root-walked twin fails, 'lmx: walk error: INVALID' (exit 3), while the native row stands; M4, a body statement is not refused -> `unit_merge_body_stmt_refused` and `unit_merge_body_expr_refused` translate (their rows expect the refusal).

## Slice R5 -- design before code (`fable_pc`, 2026-10-11)

Cluster 3, rule R5. The census of the cluster on `d70a72ce`, the general rule to meet (R5-G1..G4) and the cut
plan (R5-1 declarations by the contract at any depth, R5-3 the unnamed index step of the path, R5-2 the author's
staged bindings, R5-4 general indices with the two-index route deleted) are in
[array-receiver-20261011.md](array-receiver-20261011.md). R5-1 is built (the next section); R5-3 is next.

## Slice R5-1 -- declarations by the contract, any depth, every element the kernel has an Array of (`fable_pc`, 2026-10-11)

Cluster 3, rule R5-G1, the first cut of [array-receiver-20261011.md](array-receiver-20261011.md). Measured first
(a probe translator from `1c63351c`): every nested or non-int/char Array field was refused at the Structure's line, not at the field, by a form message -- `[]: size_t xs 3` "an array field element is int or char", `int: []: []: []: deep` and `ulong: []: []: rows` "a named Structure field needs a name", `[]: xs 3` "an array field needs a type, a name and a count" -- and `int: []: []: m` in a method "unsupported body". Built (translator only, `l2trans.lm1`): one reader,
`l2_ns_array_field`, derives a named Structure's Array field from its declaration's contract tree
(`l2_declaration`): `[]: T name count` is kind 5 with the element's own numeric code (int 0, char 1, size_t 2,
ulong 36) and a count that is a literal or a define, as an own Array's (`l2_own_array_count`); `T: []: ... []: name`
at any depth of two or more is kind 6 with the depth in `l2_nsf_val`, the declared field the outer Array of
descriptors constructed empty (Q15). `l2_ns_arrarr_field` (the fixed two-level int/char shape) and the int/char-only
`[]` branch of `l2_take_ns_body` are deleted. The three construction sites emit the kernel Array type by one table
(`l2_nsf_array_type`: `LMX_TYPE_ARRAY_OF_INT`/`CHAR`/`SIZE_T`/`ULONG`); the indexed route learns the field's levels
(`l2_path_arr_leaf`, `l2_arr_operand`, `l2_arr_len_shape`, `l2_rw_index_ty`) and spells the element by
`l2_prim_code_name`; `l2_mrs_join` holds two nested fields of one name to one depth. One correction during the cut,
measured: the body passes (`l2_collect_decls`, `l2_check_body`) read a named Structure's body as its procedure's, so
the first placement of the own-nested check refused `unit_arrarr_field`'s field (7:5); the check skips a node that
is the source of a field row (`l2_nsf_source`), and the mutant without the skip reproduces the refusal. What is not
built is said at the item, a temporary limit: "an unsigned Array element has no kernel Array type yet" (there is no
`LMX_TYPE_ARRAY_OF_UNSIGNED`), "an Array of Structure references as a named Structure field is not built yet", "an
Array of references as a named Structure field is not built yet", "a qualified Array element is not built yet", "an
index below the second Array level is not built yet" (the two-literal-index route stays until R5-3/R5-4), and "a
nested own Array declaration is not built yet" -- the own-field side of R5-G1 at depth two or more (an own code for
an Array of descriptors) moves to R5-3, where its first consumer, the index step `a[i]\[j]`, is built. The kernel
is unchanged. Witnesses: `unit_array_field_sizet` (size_t and ulong Array fields, the count of one a define,
written and read back as declared, exit 7 natively and with the root walked), `unit_arrarr_field_depth3` (a
three-level int field and a two-level ulong field constructed empty and merged, `length` 0 after the merge;
natively and walked), and the refusals `unit_array_field_count_refused`, `unit_array_field_no_type_refused`,
`unit_array_field_unsigned_refused`, `unit_array_field_struct_refused`, `unit_own_array_nested_refused`,
`unit_arrarr_field_depth3_index_refused`, `unit_arrarr_field_depth3_length_refused`,
`unit_arrarr_field_depth_merge_refused`, each located at its item. Old rows unchanged on the same bytes:
`unit_arrarr_field`, `unit_array_field`, `graph_shape_method_arrarr`, `unit_named_struct_exec_array`, the
`unit_arr_path_*`, own-array and letter rows; `unit_arr_path_three_refused`, `unit_arr_path_inner_value_refused`
and `unit_arr_path_variable_index_refused` are pre-existing reds of the full run (`codex_interpreter_throw_full_02`)
with the same message under the previous translator and this one. Evidence: kernel `fable_r5_1_kernel_01` (GREEN: 300 targets, no failures);
focused harness `fable_r5_1_focus_01a` (821 targets, 27 failed, all pre-existing), `fable_r5_1_focus_01b` (820 targets, 20 failed, all pre-existing: the 47 reds of both halves are the 35 reds of the previous focus with unchanged details (compare_summary over the merged halves: OK->FAIL 0, FAIL->OK 0, detail changes 0) and 12 cluster rows added to the focus that are red in the full run codex_interpreter_throw_full_02 with the same messages -- entry_arg_len, entry_index, entry_parse_min, entry_strcmp, unit_arr_path_inner_value_refused, unit_arr_path_three_refused, unit_arr_path_variable_index_refused, unit_letter_alias_before, unit_output_receive_address_method and its walk twin, unit_path_structure_transport_nested and its walk twin; the 12 new rows OK); L3 `fable_r5_1_l3_01` (all 11 suites ok; type budget ok (4 units)); mutants on the staged
translator: T1 (the contract walk reads one `[]` level only): unit_arrarr_field and unit_arrarr_field_depth3 refused "a qualified Array element is not built yet"; T2 (the element table drops size_t): unit_array_field_sizet refused "an array field element names no type"; T3 (a size_t element gets the int kernel type): the Debt pin `LMX_TYPE_ARRAY_OF_SIZE_T` is gone from the L1 and the walked root faults (`lmx: walk error: INVALID`, driver exit 3) -- the native program still exits 7, so the native row holds by its Debt pin only; T4 (a nested field stores no depth): unit_arrarr_field_depth3_length_refused says "length requires one known primitive own array" instead of its Needle -- no green row indexes a kind-6 field twice through a typed root (every such read is a letter's, a pre-existing red), so the levels are pinned by the refusal rows; T5 (the kind-6 depth check of l2_mrs_join dropped): unit_arrarr_field_depth_merge_refused translates; T6 (the field-row skip of l2_nested_own_array dropped): unit_arrarr_field refused "a nested own Array declaration is not built yet", the defect measured during the cut. Scripts mutant_r5_1.sh and mutant_r5_1_extra.sh (the scratchpad).

## Slice R5-3a -- the levels of a nested Array are made and filled by the source (`fable_pc`, 2026-10-11)

Cluster 3, rule R5-G1, the re-cut of R5-3 ([array-receiver-20261011.md](array-receiver-20261011.md), "R5-3, re-cut
after R5-1"). Measured first (on `2f6e30fe`): `int: []: []: a` as an own field was "unsupported body" (the collect pass took no own row for a `[]` contract without a count); `[]: []: int a 3` as an own field was "a nested own Array declaration is not built yet" (R5-1's located limit) and as a named-Structure field "an array field needs a type, a name and a count" (the form check saw one operand); nothing in the source could fill a nested Array -- the only filled Array of Arrays is the host's letter, whose reading rows are pre-existing reds; `a[2][1]` on a typed root was "root operation not walkable yet: a field path" and stays so. Built (translator only, `l2trans.lm1`): an own Array of
descriptors is one own code (`l2_oc_darray`; `l2_contract_own` gives it for `[]` over `[]`), constructed by
`lmx_array_ref_new_profiled(LMX_TYPE_ARRAY_OF_DESC, count)` -- `int: []: []: a` empty (an own declaration although
it carries no count, `l2_own_decl_ty`), `[]: []: int a 2` with its count; the layout and the walked builder place an
own Array row by its row, whatever its head word. The same counted form is a named-Structure field (`l2_ns_array_field`:
kind 6, the count in `l2_nsf_val`, 0 for the uncounted form; the three construction sites take it); the levels of a
kind-6 row are read from its contract (`l2_nsf_levels`) by the indexed route, the walked index type and `l2_mrs_join`.
The element description of an Array level is the Array descriptor reference (`l2_contract_element_ty`, used by the
Array place, the indexed operand and the walked element type): `a[i]` reads as an Array value, `a[i]: row` stores one
(natively a descriptor into a `@@: VoidArray` backing, `l2_emit_array_ptr` / `l2_emit_array_load_at`; walked, ELEMPUT of a
reference into a descriptor-typed place, which the kernel already took), `length(a[i])` reads the selected Array's
length (`l2_length_indexed`: the check passes, `l2_emit_indexed_length`, LENGTH over the element in `l2_rw_length_of`).
The R5-1 refusal of the nested own declaration is gone with its row and fixture. The kernel is unchanged. Not built,
each said where it stands: a two-index read of a nested field through a typed root -- the walked path reader refuses
it ("root operation not walkable yet: a field path"; in a method "mixed numeric types (a conversion)"), as it did
before this cut for the letter rows, which stay the pre-existing reds; it is the step list's (R5-3b/R5-4). Witnesses:
`unit_own_array_nested` (an own two-level Array of two cells, a row made and stored into a cell, read back by
reference identity through `@: c.VoidArray` and by `length(a[1])`; an uncounted nested own Array of length 0; exit 7
natively and with the methods walked), `unit_arrarr_field_counted` (a counted nested field, merged with its count,
the root's own row stored into a cell and seen there by its length; natively and with the root walked),
`unit_array_field_nested_value_refused` (a value on a nested field, at the field), `unit_arrarr_field_inner_null`
(an element of a nested field is an Array value: an empty cell of a counted field compares equal to 0, a filled one
does not; natively and with the root walked); `unit_arrarr_field_depth3_index_refused` rewritten to pin the walked
reader's message, its own root `return: 1` having fired first once the two-index read passed the check. Old rows
unchanged on the same bytes: the R5-1 rows, `unit_arrarr_field`, `graph_shape_method_arrarr`, `unit_named_struct_exec_array`, the own-array
and `unit_arr_path_*` rows. Evidence: kernel `fable_r5_3a_kernel_01` (GREEN: 300 targets, no failures); focused harness `fable_r5_3a_focus_01a` (823 targets, 28 failed),
`fable_r5_3a_focus_01b` (822 targets, 20 failed: the 48 reds of both halves are the 47 pre-existing reds of the R5-1 focus with unchanged details (compare_summary over the merged halves: FAIL->OK 0, detail changes 0) and one OK->FAIL, unit_arrarr_field_depth3_index_refused, whose pinned message changed because its two-index read now passes the check as an inner Array value and its own root `return: 1` fired first; the fixture was rewritten to pin the walked reader's message ("root operation not walkable yet: a field path", 7:5) and re-run green in fable_r5_3a_focus_03 (4 targets, 0 failed); the new rows and the inner-null witness ran in fable_r5_3a_focus_02 (11 targets, 1 failed -- that row before its Needle was corrected); the five new rows OK; unit_own_array_nested_refused removed); L3 `fable_r5_3a_l3_01` (all 11 suites ok; type budget ok (4 units)); mutants on the staged translator: M1 (an Array level's element is no descriptor reference): `a[1]: row` refused "unsupported indexed Array operand contract"; M2 (`[]` over `[]` is no own code): `[]: []: int a 2` refused "unsupported own array declaration"; M3 (the entry unit builds the counted kind-6 cell without its count -- as first written a format mismatch whose garbage count failed the build; cleanly, M3b, a size_t zero): unit_arrarr_field_counted dies at the store into the empty outer Array (exit 139; L2 indexing has C99 access semantics, Q55) instead of exiting 7; M4 (the count rule gates the uncounted Array of descriptors again): `int: []: []: empty` "unsupported body"; M5 (the native element of an Array of descriptors read as int again): the native program dies (exit 139) while the walked twin still exits 7, so the two rows together pin the spelling; M6 (every kind-6 field has two levels): unit_arrarr_field_depth_merge_refused translates and unit_arrarr_field_depth3_length_refused says "length requires one known primitive own array" instead of its Needle. Scripts mutant_r5_3a.sh, mutant_r5_3a_m3.sh (the scratchpad).

## Slice R5-2 -- the author's staged Array bindings (`fable_pc`, 2026-10-11)

Cluster 3, rule R5-G2 ([array-receiver-20261011.md](array-receiver-20261011.md), "R5-2, design before code"). Measured
first (on `d71ed045`): `[]: b a[1]`, `[]: []: b a` and `[]: c: a[1]` were refused "unsupported own array declaration" (a `[]` declaration without a count); `@: c.VoidArray got a[1]` was the one binding to a selected Array (a pointer cell holding the descriptor reference, natively and walked); `length(got)` was refused ("length requires one known primitive own array") and `got[0]: 5` took the raw-pointer index route, untyped. Built (translator only, `l2trans.lm1`): a `[]` chain with no element description
and a value -- `[]: b value`, `[]: []: b value`, and `[]: c: value`, the absent-head binding `c: value` as the one
argument of the `[]` receiver (`l2_binding_frame`) -- is a binding to the Array its value selects. `l2_declaration`
reads it as the declaration of a descriptor reference cell (`@: c.VoidArray name value`, the one word `l2_desc_word`;
an outer level unwraps the inner level's rewritten chain, so the chain rewrites once, at the top), and every pass
treats the cell as a reference declaration (the machine local, the own pointer row, the walked OWN cell); a chain with
a count stays the constructor of R5-1/R5-3a (`l2_array_binding_stmt` tells them apart in the two `[]` count rules).
The collection (`l2_ab_collect`) finds the value's Array -- an own Array or binding named bare, or one of them indexed
once (`l2_indexed_operand`) -- and carries its contract after the index in the registry `l2_ab_at`/`l2_ab_contract`;
the chain's written levels (`l2_chain_levels`) must equal the carried ones (`l2_contract_levels`). Access through a
binding resolves on the carried contract: the Array code of a row is its own code or the carried contract's
(`l2_array_code`, read by the element readers, the raw-index gate, the literal and dynamic index readers, the backing
and element spelling, the length), `l2_binding_contract` and the walked element type `l2_rw_elem_ty` read the carried
contract, and the descriptor is the reference the cell holds (`l2_emit_array_desc`: natively the cell's pointer with
the path's null bail; walked, the OWN cell). A named Structure's field is no binding: the reference-field reader leaves
a binding chain to the Array field reader (`l2_ns_take_reference`), whose messages stand. Said at the binding: a value
that is no Array (a number, a call) -- "an Array binding needs an Array value"; a level mismatch -- "a binding's levels
are not the value's"; a binding to an Array of an imported type -- not built yet. The kernel is unchanged. Three
corrections during the cut, measured: `[]: []: b a` was refused because the inner level's reading had already
rewritten the chain; `[]: xs 3` as a named Structure's field was taken as a reference field by `l2_ns_take_reference`
and the collect pass spoke first (the reader leaves a binding chain alone); and the first gate caught `int: []: []: a 3`
(`unit_array_field_nested_value_refused`) saying "a named Structure field needs a name" instead of its field message --
the type word had supplied its leaf into the rewritten cell. Hence the one rule: under any declaring head (one more
`[]`, a type word, an address depth, a qualifier) an inner binding cell is the bare chain again, and only the top of
a `[]` statement rewrites. Where it
stands, not this cut's: a binding to an empty cell (`[]: g: a[0]`, no row stored) read by `length` meets, natively,
the shared null bail of the field route (an invariant abort whose text names a field path, exit 3) and, walked, a stop
(an uncaught throw) -- the divergence the field route has; registered in the ledger
([defects.md](defects.md#null-array-reference-read-diverges)), no row pins it. Witnesses: `unit_array_binding_staged`
(`[]: []: b a`, `[]: c: a[1]`, `[]: d a[1]`, `[]: e: b[1]`, `[]: []: f b`: the lengths of the held Arrays, element
writes through c and e seen through the row and through d -- one Array, several references; exit 7 natively and with
the methods walked, the walked twin pinning that `work` is not native), `unit_array_binding_root` (a binding at the
root, a write through it seen through the Array; natively and with the root walked), `unit_array_binding_levels_refused`
(`[]: b a` over a two-level a, at the binding), `unit_array_binding_value_refused` (`[]: b x` over an int, at the
binding). Old rows unchanged on the same bytes: `unit_array_field_no_type_refused` (its message kept by the reference
reader's rule), the R5-1 and R5-3a rows, `unit_arrarr_field`, `graph_shape_method_arrarr`,
`unit_named_struct_exec_array`, the `unit_arr_path_*` rows. Evidence: kernel `fable_r5_2_kernel_02` (GREEN: 300 targets, no failures; the first chain, fable_r5_2_kernel_01, GREEN too); focused harness
`fable_r5_2_focus_02a` (826 targets, 27 failed), `fable_r5_2_focus_02b` (825 targets, 20 failed: the 47 reds of both halves are the 47 pre-existing reds of the R5-3a focus with unchanged details (compare_summary over the merged halves: OK->FAIL 0, detail changes 0; FAIL->OK 1, unit_arrarr_field_depth3_index_refused, whose rewrite was gated in fable_r5_3a_focus_03); the six new rows OK. The first chain on the bytes before part e -- fable_r5_2_focus_01a (826 targets, 28 failed), fable_r5_2_focus_01b (825 targets, 20 failed) -- had one OK->FAIL, unit_array_field_nested_value_refused ("a named Structure field needs a name" instead of its field message), repaired by part e; the whole chain was run again on the final bytes); L3 `fable_r5_2_l3_02` (all 11 suites ok; type budget ok (4 units)); mutants on the staged translator: M1 (the level check gone, l2_ab_collect): unit_array_binding_levels_refused translates and runs instead of being refused; M2 (a bare chain is no binding, l2_declaration): the positive is "unsupported own array declaration" at `[]: []: b a` (11:5) and the levels refusal says the same instead of its Needle; M3 (the Array code of a row ignores the carried contract, l2_array_code): the positive is refused "an Array binding needs an Array value" at `[]: e: b[1]` (20:5) -- the collection no longer sees the binding b as an Array; M4 (the element type of a binding row ignores the carried contract, l2_rw_elem_ty): the same refusal at 20:5 in both modes -- that element type is read by the typing of the indexed operand, which both modes share, so the mutant is not walk-only; M5 (a declaring head no longer unwraps the rewritten inner chain, part e): the positive is "unsupported own array declaration" at `[]: []: b a` and unit_array_field_nested_value_refused says "a named Structure field needs a name" (1:1) instead of its Needle -- the finding of the first gate reproduced; M6 (`[]: c: value` is no binding frame, l2_binding_frame): the positive is "unsupported own array declaration" at `[]: c: a[1]` (12:5); M7 (the reference-field reader takes a binding chain again, part d): unit_array_field_no_type_refused says "an Array binding needs an Array value" instead of its Needle; M8 (the descriptor of a binding is not read from its cell, l2_emit_array_desc): the native positive fails to translate (exit 3, "internal: a refusal said nothing" -- the own-Array descriptor path has no slot for a pointer row). Scripts mutant_r5_2.sh (M1-M4; its M5/M8 echo lines were mis-quoted on the first run) and mutant_r5_2_tail.sh (M5-M8), outputs mutant_r5_2.out and mutant_r5_2_tail.out (the scratchpad).

## Slice R5-3b -- the step list (`fable_pc`, 2026-10-11)

Cluster 3, rules R5-G3 and R5-G4 ([array-receiver-20261011.md](array-receiver-20261011.md), "R5-3b/R5-4, design before
code"; this cut holds R5-4's witnesses too). Measured first (on `cc3ccf44`, the design's list): `a[1]\[0]: 5` and the flat
`a[1][0]: 5` were refused "own array index requires a supported integer expression" and the reads were not walkable
("root operation not walkable yet: this expression"); `h\a[2]\[1]: 7` was "unsupported index" and `h\a[2][1]` "root
operation not walkable yet: a field path"; `length(t[1]\[0])` "length requires one known primitive own array"; `x[0]: 2`
"unsupported index", not at the step. P0 (printTree on a probe unit) splits a body's brackets into atoms and keeps a
frame's head as one text: the text readers of an indexed path served heads only. Built (translator `l2trans.lm1` and its
header records `l2_application.h.lm1`; the kernel unchanged): the Array place -- a prefix path and one index group, the
route that already served one-index reads, writes and `length(a[i])` natively and walked -- is the step list.
`L2ArrayPlace` and the head cache `L2HeadExpression` carry the step count; the steps after the first are read from the
source after the previous group (`l2_place_more_steps`: `[expr]`, or `\ [expr]` continuing from the selected level; a
group followed by a name is an occurrence selector of a field step and `\ name` a field step -- both end the steps, the
second refused at the field) and iterated by one function (`l2_place_step`), never copied into a list, no cap. The
resolver (`l2_array_place_contract`) walks the base's contract level by level: each further index continues from the
Array description the previous one selected; the result is the last level's element (`l2_contract_element_ty`) or, with
no step, the Array value itself; an index on a numeric value -- `x[0]`, a third index on a two-level Array -- is "an
index needs an Array value" at the step, while a pointer or a raw C value keeps the machine index and a Structure its
path route. The operand reader (`l2_array_span_mode`) counts the fields it took; the head re-parse reads the further
steps. The check passes read each step as a received size_t (`l2_check_place_steps`): the conversion edge of every
received value, so an int index is "the program has no method `lm_stg_convert_int_size_t`, the receiver of this
conversion", as `entry_dyn_array_index_int_refused` pins for an own Array. The native emitter (`l2_emit_array_place_operand`)
per step: the level's backing cast by its element (the descriptor reference above the last level, the place's type at
it), the index in a size_t temporary, the element `data[index]`; a selected level is the next step's descriptor and a
null one the implicit `interpreter` throw (N1, `l2_emit_null_use`); the first step keeps the names `l2_aiN_data`/`_index`
(`unit_arr_path_bounds_refused`'s pattern). A body or a trailer with an index step below the first level marks its method
for the status channel (`l2_has_nested_index`: the head text, the fields, nested frames). The walked builder
(`l2_rw_array_place_operand`) chains one ELEM frame per step, ELEMPUT at a store, LENGTH over the place; the walked path
spanner (`l2_rw_path_run_mode`) reads `\[expr]` as an index step and needs a name after a group for an occurrence
selector. `length` over a place is one route for paths and steps (`l2_length_place`, `l2_emit_place_length`, the walked
`l2_rw_length_of`): a path to an Array field with no index is the field's own descriptor (X1 on a null, the
construction's promise), a selected level the N1 test. Deleted: `l2_arr_operand`, `l2_emit_arr_operand`,
`l2_arr_len_shape`, `l2_path_arr_leaf`, the three callers saying "an index below the second Array level is not built
yet" and the messages "an indexed field path needs ...", "an inner Array is a value only inside length()";
`l2_length_indexed`, `l2_emit_indexed_length`; `l2_rw_index_ty`, `l2_rw_indexed_path` and the text branch of
`l2_rw_length_of`. Kept for the next cut, dead by the gate's measure first: the head text own-index readers
(`l2_own_index_head`, `l2_dyn_own_index` -- every head tries the place first) and the one-index own route
(`l2_indexed_*`: the `@` address forms, the typing fallbacks). Two sentences of the design corrected by measurement: an
int index is the conversion edge above, not "mixed numeric types" (the own route's wording); a field after an index in a
store's HEAD (`a[0]\f: 1`) keeps the generic refusal -- the head re-parse engages on a head ending with `]` -- and the
operand form is the located witness. Witnesses: `unit_steps_own_nested` (`a[1]\[0]: 5`, `a[1][2]: 6`, read back both
ways, `length(a[1])`; natively and with the methods walked), `unit_steps_field_nested` (`h\a[2]\[1]: 7` at the root,
`h\a[2][k]` in a method with a formal root and a formal index, `length(h\a[2])`; natively, with the root walked, with
the methods walked), `unit_steps_three_levels` (`t[1]\[0]\[2]: 9`, `length(t[1]\[0])`), `unit_steps_computed_index`
(`a[k]\[j]` with size_t names at both levels, `h\buf[k]` as before), `unit_steps_null_level_catch` (a read and a store
through an empty level under `catch: interpreter ()`, 7 in both modes) and `_uncaught` (R0 stopped in both modes),
`unit_steps_bounds_walk` (`a[5]` on a 3-cell Array under the catch, the methods walked: the ELEM's throw; natively Q55,
no row), `unit_steps_index_not_array_refused` (`x[0]: 2`, at the step), `unit_steps_field_after_index_refused`
(`a[0]\f`, at the field), `unit_arrarr_field_depth3_steps` (a counted three-level field through three steps; natively
and with the root walked) replacing `unit_arrarr_field_depth3_index_refused` and `_length_refused` (removed: the step
list reaches every level). Rows moved with their diagnostics: `unit_arr_path_three_refused` (the third index on the
two-level letter field, at the step; the fixture declares `@: MainLetter m`), `unit_arr_path_variable_index_refused`
(the conversion receiver), `unit_arr_path_untyped_refused` ("unresolved name" at the field of the untyped root),
`unit_arr_path_inner_value_refused` renamed `unit_arr_path_inner_value` (an inner Array is a value, its null test
legal; translation-only), `unit_array_index_scalar_shadow_refused` and `_dynamic_scalar_shadow_refused` (the shadowing
int is the step's operand, at the step). Three of the letter rows were among the pre-existing reds before this cut
(their old Needles had stopped matching): `unit_arr_path_three_refused` and `unit_arr_path_variable_index_refused` are
green on their new Needles, `unit_arr_path_inner_value_refused` is the renamed positive; and `entry_arg_len`
(`length(m\mainArgs[1])`, `m\mainArgs[1][0]` through a declared `@: MainLetter m`) is green now -- the step list
greened it; `entry_parse_min` translates now (`@ m\mainArgs[1][0]`, the address of a two-step element) and runs to exit 1
instead of producing no L1: still red, the letter class. One text for one situation (the D-40 precedent): the second
emitter of the number-index refusal in `l2_check_fields` ("an index on a number: only an Array field is indexed", after a
name bound to a number -- false now that own Arrays and nested levels are indexed) is deleted with its previous-operand
bookkeeping, and the place's base reads a formal's declaration contract too (`l2_binding_contract`), so a number formal
indexed (`q[0]`) is said at the step by the one route; `unit_index_num_refused`, `unit_index_num_return_refused` and
`unit_send_site_kinds_refused` move to it (the index node, one column right of the bracket). Old rows unchanged on the
same bytes: the R5-1, R5-3a, R5-2 and N1 rows, `unit_arr_path_read`, `unit_arr_path_merge_result`,
`unit_arr_path_bounds_refused`, `entry_dyn_array_index`, the `unit_k03_*length*` refusals. Left in the bytes: the local
`nty` of `l2_check_fields`, unused since its rule went (an edit anchored on the prototype entry missed it after the gate
had started; removed in the next cut, which touches that function). **Corrected the same day** (Codex
CODEX-ARRAY-GROUPS-20261011-184637; the ledger, FLAT-INDEX-READ-AS-NESTED): this cut read adjacent `a[i][j]` as the nested
steps `a[i]\[j]` -- against the book (semantics 116/1030, L2 spec 284, CORE 5.2): adjacent groups are the flat rectangular
index of ONE Array by source-known strides, which no declaration builds yet. Now a step is `\ [expr]` only; an adjacent group
is a located refusal at its second group on an Array base ("the flat index [i][j] addresses one rectangular Array, not built
yet; [i]\[j] indexes the selected Array"), a raw pointer keeps C's `p[i][j]`; the marking scanner marks only `]\[`; an
occurrence selector is glued to its `]` (P0 drops the comma between C-door actuals, so `\[0], n` was read as `\[0]n`), which
lets `entry_index` and `entry_strcmp` translate. Witnesses `unit_steps_flat_refused` (+ walk twin), `unit_steps_flat_store_refused`;
the nested positives and the letter rows spell `\[`. The rectangular positive is the OPEN required witness of its stage (the
plan, "Corrected"); R5-3b/R5-4 and the ticket are not closed. Evidence of the corrected bytes: kernel build/l2src/fable_r5_3b_kernel_03 (GREEN: 300 targets, no failures); focused harness build/l2_harness/fable_r5_3b_focus_03a (843 targets, 21 failed) and build/l2_harness/fable_r5_3b_focus_03b (843 targets, 20 failed): compare_summary over the merged halves against the second chain of 355626ae (43 reds): OK->FAIL 0; FAIL->OK 2 (entry_index, entry_strcmp -- red without L1 before, the glued selector reads their C-door actuals right); added 3 rows, all OK (unit_steps_flat_refused, its walk twin, unit_steps_flat_store_refused); the migrated nested positives and letter rows kept their outcomes; the 41 reds are the 43 minus those two, no detail changed; the gated staging bytes equal the live sandbox (l2trans 801501471f4c); L3 build/l3/fable_r5_3b_l3_03 (all 11 suites ok; type budget ok (4 units)). Mutants: M1-M8 as for 355626ae (the nested witnesses spell `\[` now), each reddening its witness again on the corrected staged translator: M1 (the walked spanner reads no `\[expr]` step) -- the positive is not walkable in either mode; M2 (an inner level cast by the place's type) -- R0 stopped natively; M3 (the ELEM chain's indices swapped) -- the walked twin stops R0, the native row exits 7; M4 (the null test of a selected level on the X1 route) -- the native catch witness aborts (exit 3), the walked twin exits 7; M5 (every step uses the first index) -- the native positive fails its exit check; M6 (no step after the first) -- the positive is refused "own array index requires a supported integer expression"; M7 (the marking rule gone) -- the uncaught witness fails to compile natively (l2_out_throw undeclared); M8 (the level check gone) -- unit_arr_path_three_refused says "the Array element has no supported value contract" instead of its Needle. New: M9 (an adjacent bracket group is read as a step again, the conflation) -- unit_steps_flat_refused loses its located message in both modes (the iterator, which requires the slash between steps, cannot read the admitted step: "internal: an index step of a place cannot be read" at 10:5), so the flat form neither selects the inner Array nor says the rule; M10 (the glued-selector rule gone: every name after a group is an occurrence selector) -- entry_index is refused "a field after an index needs an Array of Structure references" at its C-door actual `\[0], n` (19:45) instead of translating. Script mutant_r5_3b_b.sh on fable_r5_3b_focus_03a, output mutant_r5_3b_b.out (the scratchpad). Evidence of the first cut, before the correction: kernel build/l2src/fable_r5_3b_kernel_02 (GREEN: 300 targets, no failures; the first chain, fable_r5_3b_kernel_01, GREEN too); focused harness build/l2_harness/fable_r5_3b_focus_02a (842 targets, 23 failed) and build/l2_harness/fable_r5_3b_focus_02b (841 targets, 20 failed): compare_summary over the merged halves against the N2 run (n2c, 47 reds): OK->FAIL 0; FAIL->OK 3 (entry_arg_len, unit_arr_path_three_refused, unit_arr_path_variable_index_refused); removed 3 (the two depth-3 refusals, OK before, and unit_arr_path_inner_value_refused, red before); added 19 rows, all OK (the step witnesses, unit_arrarr_field_depth3_steps and its walkroot twin, unit_arr_path_inner_value); the 43 reds are the N2 reds minus those four, one detail changed (entry_parse_min: no L1 before, exit 1 under the driver now). The first chain (fable_r5_3b_focus_01a 840 targets 24 failed, _01b 840 targets 20 failed) had one OK->FAIL, unit_index_num_refused, whose row the second emitter still served -- the one-text edit above repaired it and the whole chain ran again on the final bytes (l2trans f4478b5ce143, the header 4b5ee6777fa1, equal to the gated staging); L3 build/l3/fable_r5_3b_l3_02 (all 11 suites ok; type budget ok (4 units)). Mutants: M1 (the walked path spanner no longer reads `\[expr]` as an index step): unit_steps_own_nested is not walkable in either mode (the count pass runs for every program) -- "root operation not walkable yet" at the read; M2 (an inner level cast by the place's element type): the native positive stops R0 (the misread level fails its null test); M3 (the ELEM chain takes the indices in the wrong order): the walked twin stops R0 (a[0] through [1], an empty level) while the native row still exits 7; M4 (the null test of a selected level takes the X1 route again): unit_steps_null_level_catch aborts natively (exit 3, the invariant) while its walked twin exits 7; M5 (every step uses the first index): the native positive reads a[1][1] for a[1]\[0] and fails its exit check; M6 (no step after the first, the one-index cap again): the positive is refused "own array index requires a supported integer expression" in both modes; M7 (a body with an index step below the first level is no longer marked): the uncaught witness fails to compile natively (l2_out_throw undeclared); M8 (the resolver no longer checks the level a further index continues from): unit_arr_path_three_refused says "the Array element has no supported value contract" instead of its Needle. Run twice -- on the first chain's staged translator and on the final one (fable_r5_3b_focus_02a), identical results; script mutant_r5_3b.sh, outputs mutant_r5_3b.out and mutant_r5_3b_02.out (the scratchpad).

## Slice R5-4 -- the dead routes of the one-index forms (`fable_pc`, 2026-10-11)

Cluster 3; the deletions the design owed ([array-receiver-20261011.md](array-receiver-20261011.md), "Deleted in the same
cut": the head text readers; "the one-index own readers ... become the one-step case"). Measured first, on `1d8ffe4d`: P0
splits a body's brackets into atoms and keeps a frame's head as one text (printTree), and every statement head tries the
Array place first (`l2_array_place`, in the check pass, the native statement and the walked statement), so the head text
own-index readers were reached only where the place had declined -- an own Array without a declaration contract, which no
registered fixture has. Deleted (translator `l2trans.lm1` only; the kernel unchanged): `l2_own_index_head`, `l2_dyn_own_index`,
`l2_own_array_root_span` (always -1 since FABLE-SONNET-NODE-ROOT-20260923-121), `l2_rw_elem_of`, `l2_rw_elem`, `l2_rw_elemput`
(the walked own element by head text), `l2_emit_own_index` (the native store fallback), `l2_indexed_atom` (the atom branch
of the one-index own route), and the fallback blocks that called them: the check pass's statement head and primary atom,
the native operand's atom and statement head, the walked operand, statement head and typing. Their messages "own array
index requires a supported integer expression" and "an own array index could not be emitted" are gone; no row pinned them.
The one rule kept, re-expressed: the walked layout's recognition of an element write (`l2_src_elemput`: the statement is
one step of the walked root) reads the Array place -- an own Array of the body being built, seen and placed -- instead of
the head text, so the index is any size_t value the walked builder takes. The one-index own route proper (`l2_indexed_*`:
the `@` address forms, `l2_ptr_arith_ty`, the typing fallbacks, the actuals' first consult) stays: it is live, and its fold
into the place route is a cut of its own after the rectangular stage. Not rows: the unregistered legacy fixtures
`unit_own_array_index`, `_size_index`, `_char_index`, `_int`, `_length` (octal-spelled counts `003`, indices `000`) were served
by the deleted readers and now refuse at their declaration -- ungated fixtures, not coverage. Rows unchanged on the same
bytes: every Array row of the cluster, the walked twins included. Evidence: kernel `fable_r5_3b_kernel_04` (GREEN: 300 targets, no failures); the focused harness over the 1680 rows in two halves, `fable_r5_3b_focus_04a` (843 targets, 21 failed) and `fable_r5_3b_focus_04b` (843 targets, 20 failed), compared by fixture identity and outcome with chain 03 on `1d8ffe4d` (compare_summary.py over the merged halves): 0 added, 0 removed, 0 FAIL->OK, 0 OK->FAIL, 0 detail changes, the 41 failures the pre-existing ones; `fable_r5_3b_l3_04` (all 11 suites ok, type budget ok); the gated translator bytes are the live sandbox bytes (sha256 f5e261648811...). Mutant: M1, the layout recognizes no element write (`l2_src_elemput` step 1 -> 0, mutant_r5_4.sh): on the three first witnesses (unit_arrarr_field_counted native and root-walked, unit_array_binding_root root-walked) the generated L1 is byte-identical and the runs pass -- a trace variant shows they never reach the recognition (trace_elemput.sh over the 2457 fixtures, plain and methods-walked: 330 calls, 290 recognized in 29 fixtures, 40 declined in 16); on fixtures that reach it (mutant_r5_4_b.sh: unit_array_index_shadow native and root-walked, graph_shape_nested_array with its shape paths native and root-walked, unit_array_binding_staged methods-walked) the mutant's generated L1 differs -- 1384, 96 and 59 lines, the method keeping the packed prefix and its graph places moving -- while every row still passes: the recognition decides the layout mode, which no row observes. The recognition is live and kept; its effect is in the program text, not in a row's outcome.

## The general rule the implementation has to meet (read from the author's sentences and the book)

R1. The outer head's role is the resolver's alone: an absent head with a retained body is a
declaration in the root, in a method and in a nested body alike; no exception for a tail that begins
with `merge`, and no root role for a tail that begins with `independent`.

R2. What the declared head holds is read from its tail after R1: one application of a receiver whose
contract yields a value (`merge`; a qualifier over a value) makes the declaration a statement of the
enclosing procedure (E's at the root, a method's, a named Structure's) declaring the head's own row,
which holds the value (today's merge-result own row and schema, produced by merge's contract); an
atom naming a Structure visible at the place is the binding (K03 NS-ROLES-1); a literal or an atom
that names nothing callable is retained content; anything else is the head's body, a procedure
(Q45). Current semantics are preserved: `b: merge: A C` still evaluates the merge once where it
stands and `b` holds the result; it does not become an inert declaration, and in a named Structure's
body it is not a field of the Structure (the probe `rr_merge_nested_root`, which read `Outer\x\v`
from outside, expected a field: its expectation was wrong, the translator's "unknown field path
segment" right).

R3. merge's contract is unchanged in substance (operands, result body, schema, throws, native and
walker emission) and is entered from R2, never from a role gate; its own refusals keep their bytes.

R4. `independent`, `const`, `immutable` are three receivers over a Structure value with their own
contracts, composable in the order and nesting the source writes, at any place a value is received;
the combined qualification of a parentless value makes the eternal branch (profile retained by every
later copy); the root-level `(): Name` chain is one case of it, not the definition.

R5. `[]` is a receiver over an explicit element description, nested as written, with no depth cap;
`length` is the selected descriptor's.

R6. A merge result body is an ordinary Structure body.

Order of the slices: R1+R2+R3 (clusters 1 and 5) → R4 (cluster 2) → R6 (cluster 4) → R5 (cluster 3).
Each slice: the old rows of its cluster stay green or move with an explained diagnostic on the same
bytes; new minimal witnesses, native and walked, with a mutant per rule; kernel, L3 and the focused
harness of the cluster before the commit; the full harness replay when the user allows a full run.

Witnesses of R1–R3 (slice RR1, `fable_pc`, 2026-10-10): the content-kind reading (`l2_value_receiver`,
`l2_decl_content`) replaced the six role uses of `l2_merge_construction`; behaviour is unchanged by
design, so the witnesses are the existing rows kept green on the same bytes -- the 42 merge rows,
`unit_merge_parent_named` and `unit_ns2_copy_field` (merge as a named body's statement),
`unit_k03_ns_bare_merge_refused` and `unit_k03_ns_merge_app_refused` (no operand, refused at the
word in a named body), the K03 S5 definition-tail rows -- and a mutant: `l2_value_receiver` answering 0
makes every `R: merge: A` a named Structure R with merge as its body's statement, which the rows see.
Probes of the slice on the translator before it (`scratchpad/rr_probes`): `x: merge: Model` in a
unit Structure's body read from outside as `Outer\x\v` -- "unknown field path segment" (x is the
procedure's row, not a field; correct); the same in a method's named Structure -- the same; a known
head `a: merge: Other` after `a: merge: Model` -- "more arguments than a has formals" (the book's
call classification of a known head, out of this ticket); `a: merge: Model` with the body `int: w 6` --
"mixed numeric types" at `a\v + a\w` (cluster 4: the body field is typed `size_t` whatever the
source wrote). For R4: the author's example natively and walked; the chain over a known named Structure,
an anonymous Structure and a method's result; each receiver alone with its own contract; the eternal
branch's identity kept through a later `merge` (the copier's retained profile); the existing write and
address refusals unchanged.
