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
