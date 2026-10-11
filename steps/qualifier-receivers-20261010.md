# Qualifier receivers — design of slice RR2 (`critical_qualifier_receivers_bug`; `fable_pc`, 2026-10-10)

Design only, read on `511c9ae4`; no code changed by this file. Ticket:
[critical_qualifier_receivers_bug](tickets/critical_qualifier_receivers_bug.md); the census that
placed it: [receiver-routes-census-20261010.md](receiver-routes-census-20261010.md), cluster 2 and R4.

## The norm

- The author (2026-10-10, verbatim in [`LMX_blog/2026-10-10.md#qualifier-receivers-20261010`](../LMX_blog/2026-10-10.md#qualifier-receivers-20261010)):
  three receivers consuming any Structure; his example, kept with its second operand as written:
  `return: independent: const: immutable: merge(Integer  int: value newValue)` in a method.
- The book, [qualification](../docs/LMX_semantics.en.md#qualification): `const` protects a binding;
  `immutable` protects the value through every alias; construction-time `immutable` qualifies the new
  value before publication, `RuntimeImmutable` requalifies an existing tree keeping its identity, and
  the two are different operations; `independent` is the ownership of a value with no external
  lexical parent. [Eternal branches](../docs/LMX_semantics.en.md#eternal): the combined qualification
  makes a sealed immutable independent branch whose root has `parent = 0`; "permitted runtime-value
  initialization occurs before publication without increasing the entry set"; membership is
  established by the typed-address-range index, "neither ... a flag on each branch" nor a registry.
- [Composition](../docs/LMX_semantics.en.md#composition): `merge` retains by its exact physical
  profile only the `independent: const: immutable` branch; everything else is copied (the author's
  full-copy rule of 2026-10-10).

## What exists today

The translator accepts the chain only at the unit root and only as `independent → const → immutable →
(): Name` with a Structure body (`l2_unit_role` 2 → `l2_take_eternal`). For each such branch k the
prologue makes a profile node `l2_eprofile<k>` (`lmx_node_new_profiled(arena, unit)`), allocates the
branch's nodes and cells under that profile (`lmx_node_new_profiled`, `lmx_arena_refs_open_profiled`,
the typed constructors `*_new_profiled`), publishes the root into its unit slot with `parent = 0`,
and after construction runs `lmx_qualify_tree_preflight_full` and seals the profile's pools. Three
consumers then read the qualification from LISTS of the static branches (`l2_program_qualified_at`,
`l2_program_qualified_roots`): the walker's write check `lmx_walk_immutable` (the frame context's
`immutable_profile` / `immutable_roots`), the native write checks (`lmx_range_has_root_profile`,
`lmx_range_write_overlaps_profile` against `l2_program_qualified_roots`), and merge's retention
(`l2_emit_keep` fills the retained-profile span the copier tests in `lmx_copy_retained_profiles`).

A value qualified at run time (the author's example) would be in none of those lists: the walker
would let a write through, native code would too, and a later merge would copy it. So the shape
refusals of `l2_take_eternal` are not the whole defect: the lists are the second half.

## The physical mark

A qualified value is a tree allocated under its own profile, the profile's pools sealed after the
preflight; `independent` adds `parent = 0` at the root. `const` leaves no mark in the value: it
protects the binding, which is the translator's knowledge about a name, not a property the range
index can see. The MSG pool sealed for import carries profile 0, so "profile ≠ 0 and sealed" names
exactly the qualified values and nothing else.

Rule to build (the book: the admitted range is the metadata): every consumer reads the mark from the
range index -- immutable when the cell's range has a profile whose pools are sealed; the eternal
branch merge retains when, in addition, the profile's root has `parent = 0`. The static branches
satisfy the same test, so the lists become redundant and go once every static row passes under the
classification alone.

## Sub-steps

RR2a (kernel, the copier and merge): a destination profile. The ten destination allocation sites of
`lmx_graph_copy_owned.lm1` (`lmx_copy_ensure_struct` 1228, the cell constructors 1297–1344,
`lmx_copy_part` 1550, the two `lmx_arena_refs_open_owned` 1556/1598) take the profile (0 = today) and
call the profiled constructors; the merge entries gain a qualified variant (profile, independent) that
copies under the profile, sets the root's `parent` to 0 when independent -- a result whose copied
code reads its lexical context (use records present) cannot be independent and is refused with its
own status --, runs `lmx_qualify_tree_preflight_full` and seals the profile's pools before the result
is published. Self-tests: every reachable cell of the result answers the profile; preflight OK; after
sealing a write is refused by the classification test (RR2b); a later merge of a holder retains the
independent result by address and copies a non-independent one; `independent` over a result with use
records is refused. Mutants: no seal (a write passes), no `parent = 0` (retained wrongly), profile
only on the root (a child cell answers 0).

RR2a is built (`fable_pc`, 2026-10-10): `lmx_copy_run` and its five helpers carry `dst_profile`; the
seventeen destination allocations call the profiled constructors; `lmx_list_new_profiled` and a list
growing in its header's profile; `lmx_arena_seal_profile`; the merge worker
`lmx_merge_used_profiled_owned` with `lmx_merge_qualified_owned` as its qualified entry
(`lmx_merge_used_owned` and the harness tap unchanged); `tests/lmx_copy_profile_selftest.lm1`: every
cell of a copy and of a fresh merge answers the profile, the ordinary copy answers 0 in other pools,
sealing P leaves the unprofiled and Q pools open and refuses a new cell under P. Gates: kernel
`fable_rr2a_kernel_03` (GREEN, 299 targets, 0 failed; lmx_copy_profile_selftest 28 checks, 0 failures (gate 01 failed to compile on a copier helper without the new parameter, gate 02 on two dotted paths inside call arguments of the self-test; both fixed before gate 03)); L3 `fable_rr2a_l3_01` (all 11 suites ok, type budget ok); focused harness `fable_rr2a_focus_01` (148 targets, 11 failed, the same eleven pre-existing reds as fable_rr1_focus_03 with unchanged details; FAIL->OK 0, OK->FAIL 0 against codex_interpreter_throw_full_02);
mutants on the gate's staged source (`scratchpad/mutant_rr2a`): an int cell allocated with profile 0 at one copier site -> 3 of 28 checks red (the int cell under P, the merge result int cell under Q, the int pool of P sealed); lmx_arena_seal_profile sealing nothing -> 3 red (the Structure and int pools of P sealed, a sealed profile takes no new cell); exit 1 both; `check_docs` and
`diff --check` clean. Independence (`parent = 0`) and the refusal of a result with
use records stay with RR2c, where the translator knows the chain.

RR2b (kernel, the readers): `lmx_walk_immutable` and `lmx_copy_retained_profiles` read the mark by
classification (profile ≠ 0, sealed; for retention also root `parent = 0`) beside the lists; the
static fixtures are the witness that nothing moves; then the lists are removed in a separate commit.
The retention half waits for the author's answer to Q1 below; the immutability half does not.

RR2b, the immutability half, is built (`fable_pc`, 2026-10-10): `lmx_range_sealed_profile` answers the
profile of a cell whose array carries a nonzero profile and is sealed (0 for an unsealed profile, an
unprofiled cell, no cell; an imported view answers as its owner's array); `lmx_walk_immutable` asks it
before the frame context's exact profile and roots lists; `lmx_range_write_overlaps_profile` selects a
sealed profiled interval with no exact profile and no roots given. `tests/lmx_sealed_profile_selftest.lm1`
(the mark appears on every cell of P after sealing and on nothing else; the barrier selects a sealed P int
and a byte inside it, not an unsealed Q int or an unprofiled int; the imported view answers in the
importer, an unsealed profile is not imported). Not in this step: the native write guards the translator
emits (`l2_emit_write_guard`, `l2_emit_lvalue_write_guard`) still test the roots list only and are emitted
only when the program has a static branch; they learn the mark in RR2c, where a program first holds a
run-time branch and the witness exists; the retention half (`lmx_copy_retained_profiles`) waits for Q1.
Gates: kernel `fable_rr2b_kernel_01` (GREEN, 300 targets, 0 failed; lmx_sealed_profile_selftest 25 checks, 0 failures); L3 `fable_rr2b_l3_01` (all 11 suites ok, type budget ok); focused harness `fable_rr2b_focus_01` (259 targets, 7 failed, all pre-existing with unchanged details (unit_qualified_source_call and _walk, unit_eternal_xref and _walk, unit_k03_merge_op_anon_typed and _walk, unit_t7_host_nested_return); FAIL->OK 0, OK->FAIL 0 against codex_interpreter_throw_full_02);
mutants on the gate's staged source: lmx_range_sealed_profile answering 0 -> 4 of 25 checks red (root, int cell, children range, imported view); the barrier without the sealed clause -> 2 red (a sealed P int and a byte inside it); exit 1 both.

RR2c (translator, native): the three receivers in value positions -- a method's `return:`, a
declaration's tail, a merge operand -- each with its own contract: over a construction (a `merge`, a
constructor) `immutable` makes a construction-time qualification (RR2a's variant), `independent`
sets the root free of a lexical parent (refused when the result's code reads its context), `const`
makes the receiving binding unassignable (a translation check, no physical mark); over an EXISTING
value `immutable` and `independent` are `RuntimeImmutable`'s operation, which this slice does not
widen (the ticket): a located refusal naming the operation. The root-level `(): Name` chain becomes
one case of the same reading (`l2_take_eternal` goes; its registrations stay as the effect of the
combined qualification over a parentless named Structure).

RR2c-1, the structural operand (census cluster 5), is built (`fable_pc`, 2026-10-10): a merge operand
written as a TYPED DECLARATION -- the author's `merge(Integer  int: value newValue)`, where P0 gives the
atom and the Frame as two actuals, and `merge(Model; (int: v 9))`, a group holding the declaration --
is an anonymous Structure of that one field (`l2_merge_typed_decl`: a number or char declaration, bare
or the sole content of a group; form 3 of `l2_merge_decl_operand`). The pre-scan joins its name and
kind to the result-slot map as a named Structure's field (`l2_mrs_join`: into the placed slot of its
name when the kinds agree, else a slot of its own; a kind clash is said at the declaration); the scan
reads only its candidate (`l2_scan_merge_operands`); the check pass checks the candidate as a
declaration's (`l2_check_merge_typed`: one value, its names, a literal of the kind, the conversion
edge); native emission makes a fresh Structure of one cell of the kind where the merge runs, in operand
order, evaluates the candidate (the conversion edge, else the ordinary expression) and stores it
(`l2_emit_merge_typed_operand`); the merge copies it as any operand (the full-copy rule), and it
supplies no profile. The walker has no step for it yet: in a method the retained body stays
native-only, as for a retained machine operation (under `--walk-methods` the method keeps its native
word); at the root the statement is refused where it stands ("root operation not walkable yet: an
anonymous Structure merge operand"), a located limit until RR2d. Witnesses: `unit_k03_merge_op_anon_typed`
and its walked twin, red since 2026-10-07, are green; `unit_rr2_merge_op_typed_bare` (+`_walk`: the
author's spelling with a formal, an expression, a literal and fields of earlier results as candidates;
the typed operand first, as the model, its slot taken by a later operand's same-name field),
`unit_rr2_merge_op_typed_append` (+`_walk`: fields no earlier operand placed, bare and in a group, int
and size_t, a merge result as an earlier operand), `unit_rr2_merge_op_typed_clash_refused` (+`_walk`:
`size_t: v` against `int: v`, said at the declaration), `unit_rr2_merge_op_typed_root_limit` (the
root's located limit). A group of two declarations on one line is one declaration whose candidate is
two values (P0 hangs the second Frame on the first): refused by the declaration rule, "a declaration
takes one value"; several fields are written as several operands. The bare field `v: 9` stays the
located limit it was (MERGE-NAMED-ARGUMENT-OPERAND, the author's answer pending). Not in this step: the
qualifier chain over a merge (RR2c-2, RR2c-3). Gates: focused harness `fable_rr2c1_focus_01` (155 targets, 9 failed, all nine pre-existing with unchanged details (unit_ns2_ref_arg, _return, _admit, _capture and their walked twins, unit_held_definition_free_name); FAIL->OK 2 (unit_k03_merge_op_anon_typed and its walked twin), OK->FAIL 0, 7 rows added, all OK, against fable_rr1_focus_03); L3
`fable_rr2c1_l3_02` (all 11 suites ok, type budget ok; fable_rr2c1_l3_01 failed in every suite only because the runner was given a relative --output, which its subprocesses resolve against the unit root); mutants on the run's staged source: the typed field joined with kind 0 whatever its declaration says -> the three positives refuse at translation (two as the kind clash at the declaration, the append fixture as mixed numeric types at the read); the candidate evaluated but never stored -> the program exits 81 (A's v is not 9) under the run's driver where the real one exits 7; `check_docs` and `diff --check`
clean. The kernel is untouched (no kernel gate).

RR2c-2a, the chain in a declaration's tail, is built (`fable_pc`, 2026-10-10): `a: independent: const:
immutable: merge(Integer  int: value 7)` -- the author's chain over a value made at run time, in a method
and at the root -- is one declaration whose content is the merge's value (`l2_decl_content` 3 through
`l2_qual_value_app`; the merge readers see through the chain, `l2_merge_host`), with the three contracts
read from the chain (`l2_merge_qualifiers`: 1 independent, 2 const, 4 immutable, in the order and part
the source writes; `l2_merge_chain_check`: one item per qualifier frame, no word twice). Native emission:
the merge is the ordinary one; then, before publication, `independent` frees the fresh root of its
lexical parent (`parent: 0`), `immutable` copies the completed result under a fresh profile node
(`lmx_graph_copy_qualified_owned`, RR2a; the merge's retained profiles retained again) and that copy is
the value published (`l2_emit_qualify_copy`); its layout is proved as every merge result's is; then
the full preflight runs on it, with the merge's retained profiles as the prior ones and the program's
opaque pointer types, and the profile is sealed (`l2_emit_qualify_result`, `lmx_arena_seal_profile`); a
failed copy, proof or seal is INVALID (X1), as a write into a qualified value is. The profile node itself
lives in a sealed pool, as the kernel requires of a retained profile (`lmx_copy_profiles_valid`: a sealed
live Structure -- the static branches' profile nodes live in the unit's sealed pools): it is made under a
fresh holder node whose pools are sealed with the branch's (measured: with the profile node in the
unprofiled pool, a later merge over the qualified value threw, the copier refusing the retained
profile). The copy rather than a
merge made under the profile: a merge with pairs leaves the paired-over copies of the model's fields in
the profile's pools, and the coverage proof (every issued cell of the profile is in the published
tree) refused every such merge (measured: the positive fixture was INVALID under
`lmx_merge_qualified_owned`, and passed under the narrow preflight); the copy of a completed tree is
exactly that tree.
`const` is the binding's contract: an assignment to the binding is refused at translation ("a const
binding cannot be assigned", said before the arity reading a head holding a Structure gets). `immutable`
is also said at translation for a write through the binding's own name ("an immutable value cannot be
written"); every other write meets the run-time guards, which now test the physical mark
(`lmx_range_sealed_profile`) beside the static roots and are emitted whenever the program has a static
branch or a merge qualified at run time (`l2_qmerge_n`). `independent` over a result whose copied code
reads its lexical context is refused ("an independent merge result cannot read its lexical context").
Kernel (this slice's finding): the copier allocated a composition's discarded intermediate roots -- the
copied operand roots the result absorbs -- under the destination profile, so no fresh qualified
composition covered its profile; `lmx_copy_run` now seeds those roots outside the profile (`absorb`
given), and a Structure's children array follows its node's own profile (`lmx_copy_part`,
`lmx_copy_process`); `tests/lmx_copy_profile_selftest.lm1` Case C2 (a composition of two operands under S
covers S). `lmx_merge_qualified_owned` is sound for a composition without pairs; with pairs the
paired-over copies remain, which is why the translator qualifies the completed result by a copy. The walker
has no inputs for the profile and the independence yet (RR2d): in a method the retained body stays
native-only (under `--walk-methods` the method keeps its native word), at the root the statement is
refused where it stands ("root operation not walkable yet: a qualified merge"). Limits of this slice,
said at the statement: `immutable` without `independent` ("a merge qualified immutable without independent
is not built yet" -- the preflight proves a parentless root; a fresh immutable value under its lexical
parent needs the preflight's construction-time mode, RR2c-2b), and a qualified result holding a callable
("a qualified merge result holding a callable is not built yet" -- the preflight's method leaves,
RR2c-2b). Retention: a later merge over a run-time qualified result retains it by its profile, as it
retains a static branch (`l2_emit_merge_profile` reads the operand's profile); `independent: immutable`
without `const` is physically the same and is retained too -- Q1 decides whether that is the rule. Witnesses:
`unit_rr2_qualified_merge_decl` (+`_walk`: the full chain in a method, read; a later merge over it reads
through; `const` alone; `independent` alone), `unit_rr2_qualified_merge_const_refused` (+`_walk`),
`unit_rr2_qualified_merge_write_refused` (+`_walk`), `unit_rr2_qualified_merge_alias_write` (+`_walk`: the
write through a formal is INVALID at run time), `unit_rr2_qualified_merge_root_limit`,
`unit_rr2_qualified_merge_immutable_limit`. Gates: kernel `fable_rr2c2a_kernel_01` (GREEN, 300 targets, 0 failed; lmx_copy_profile_selftest 33 checks, 0 failures); focused harness `fable_rr2c2a_focus_02`
(303 targets, 14 failed, all fourteen pre-existing with unchanged details (unit_qualified_source_call and _walk, unit_eternal_xref and _walk, unit_t7_host_nested_return, unit_ns2_ref_arg, _return, _admit, _capture and their walked twins, unit_held_definition_free_name); against fable_rr2b_focus_01: FAIL->OK 2 (unit_k03_merge_op_anon_typed and its twin, RR2c-1), OK->FAIL 0, the ten RR2c-2a rows added, all OK; the first run, fable_rr2c2a_focus_01, before the two fixes, had the positive pair INVALID); L3 `fable_rr2c2a_l3_01` (all 11 suites ok, type budget ok); mutants on the gates' staged sources: kernel, the composition's roots seeded under the profile again -> the self-test's coverage check red (1 of 33); translator, the two seals dropped -> the alias write passes and the program exits 81 where the real one is INVALID; the root's parent left as the copier gave it -> the positive fixture is INVALID (the preflight refuses a root under its lexical parent) where the real one exits 7; `check_docs` and
`diff --check` clean.

RR2c-3, the return position, is built (`fable_pc`, 2026-10-10): the author's example as written --
`return: independent: const: immutable: merge(Integer  int: value newValue)` in `fn: getInteger (int:
newValue) Integer` -- and the bare `return: merge(...)`. A `return:` whose one value is a merge
application, bare or under the chain, in a method with a Structure result, is a merge declaration of a
hidden own row named by the statement's own word `return` (`l2_return_merge`; `l2_merge_declaration`
accepts it; `l2_own_add` admits the word for a return frame, since no program binds a word of the
language and so no written name reaches the row), so the whole merge contract applies -- operands,
result-slot map, typed operand, the chain with its three contracts, the qualified copy, proof and seal
-- and the row's value leaves the method as `return: name` would: the row's place reaches the result by a
D-105 edge whose check admits the row's schema, the merge record, to the result model (the one emitter:
an admission said at the statement as well was its duplicate -- the first T2 mutant showed it and it went),
then published, polled, returned (`l2_emit_return_merge`). The check pass refuses a merge returned by a
method with a number result ("return value has incompatible type"); a merge of another model is refused
by the edge's check ("implements is false in return value", the admission's own words). Not at the root (a
return with a value there is refused where it stands), not in a callable-merge host (T6/T7) and not a
callable merge, whatever hosts it -- an operand names a method, in any position, as the callable-merge
route reads its operands (`l2_merge_names_method`); that merge keeps its own route and its own refusal
(`unit_t7_from_int` pins it: the first focused run took the return route for it and said the operand
refusal instead of the pinned one). The walker builds the merge into the hidden row and keeps the
body native-only (the return of that row is RR2d's). Witnesses: `unit_rr2_return_merge` (+`_walk`: the
author's method, a bare returned merge, `independent` over a group-typed operand; the caller reads the
field through a reference binding), `unit_rr2_return_merge_int_refused` (+`_walk`),
`unit_rr2_return_merge_model_refused` (+`_walk`). The book (provenance, both languages, regenerated):
the paragraph that calls the three qualifiers receiving expressions now says where they stand -- wherever a
Structure value is received: a declaration's tail, a method's `return:`, a merge operand -- composed in
the order and part the source writes, each with its own contract, the root-level chain one case of that
reading (the author, 2026-10-10). Gates: focused harness `fable_rr2c3_focus_03` (313 targets, 14 failed, all fourteen pre-existing with unchanged details (unit_qualified_source_call and _walk, unit_eternal_xref and _walk, unit_t7_host_nested_return, unit_ns2_ref_arg, _return, _admit, _capture and their walked twins, unit_held_definition_free_name); against fable_rr2c2a_focus_02: FAIL->OK 0, OK->FAIL 0, ten rows added, all OK -- the six RR2c-3 rows and four precedents put into the focus list (unit_make_adder, unit_d101_struct_result_value, unit_d105r_formal, unit_d105r_chain); the first run, fable_rr2c3_focus_01, had unit_t7_from_int OK->FAIL, the return route having taken the callable merge, fixed by l2_merge_names_method; the second, fable_rr2c3_focus_02, was clean and gated the translator before the duplicate admission went; a replay of its 311 recorded translations with the final translator gave identical exits, diagnostics and L1 bytes for every row (a diagnostic, not gate evidence), and fable_rr2c3_focus_03 gates the committed bytes); L3
`fable_rr2c3_l3_01` (all 11 suites ok, type budget ok; the translator is not among its inputs); mutants on the run's staged source: the return line of the hidden row's value dropped (l2_emit_return_merge) -> the positive program exits 1 where the real one exits 7; the D-105 pass's admission of a type carried to the result position disabled, the edge kept -> unit_rr2_return_merge_model_refused translates where the real translator refuses it at 10:5, the positive fixture still translating (a first T2, the admission at the statement skipped, did not reach: the pass said the same refusal, which is why that admission went as its duplicate; a T2 that dropped the edge changed the output otherwise: without the edge the emission has no pair map and every returned merge, the positive ones too, ends in an internal error); `check_docs` and `diff --check`
clean. The kernel is untouched.

RR2c-2b is built (`fable_pc`, 2026-10-10), after Codex resolved Q2 from the book
([LMX_blog/q/immutable-root-parent.md](../LMX_blog/q/immutable-root-parent.md)): the root's own `parent` is a
structural lexical link outside the selected tree, not a reference stored as a data value. Kernel: the
preflight validates a nonzero root parent as a live Structure header and nothing more
(`lmx_qualify_tree_preflight`; a reference stored INSIDE the tree meets the data rule as before); the
qualified copy is a SUBTREE copy (`lmx_copy_run` with `chain` 0 behind `lmx_graph_copy_qualified_owned`):
no lexical chain is copied and the copy keeps the source's own parent as an outside structural link
(the copier's parent fixup, which refused an uncopied parent before); the method occurrences a result
holds are the copy's LEAVES (`lmx_graph_copy_qualified_leaves_owned`, `leaves` threaded through the
copier): kept by address, their cells unprofiled and writable, their lexical parents their own, and the
preflight accepts a named leaf held in a slot without traversing it (book: primitives and methods are
leaves). Retention has one reading for the native emission and the walk PRIM
(`lmx_merge_retain_profile`): an operand is retained by its profile when it lies in a qualified tree
whose root has no lexical parent -- a qualified value under a lexical parent (`immutable` alone) is
copied as any value is; `const` does not enter (Q1 decides whether it should). Translator: the chain
check's two limits go; `l2_emit_merge_profile` reads the helper; the result's callable fields (kind 4
rows of the result-slot map) are named as leaves by slot from the completed result before the copy and
given to the preflight after it (`l2_emit_qualify_leaves`; `l2_mqleaves` in the prologue, sized by the
method's widest such result). Witnesses: `unit_rr2_qualified_merge_immutable` (+`_walk`: `immutable`
alone and `const: immutable`, read; a later merge over the value copies it -- the copy written, the
value unchanged), `unit_rr2_qualified_merge_immutable_write_refused` (+`_walk`),
`unit_rr2_qualified_merge_immutable_alias_write` (+`_walk`: INVALID through the formal),
`unit_rr2_qualified_merge_callable` (+`_walk`: the data field read and the callable called through the
sealed value); the located limit `unit_rr2_qualified_merge_immutable_limit` goes with its row; kernel
self-test cases E (a root under an ordinary parent passes; retention is the parentless tree's), E2 (the
subtree copy keeps the parent), F (an outside data reference stored in the tree is refused), H (a named
leaf is kept by address and accepted; unnamed, it is that outside reference); `lmx_qualify_preflight_selftest`
pinned the overturned rule ("mutable parent outside selected root" INVALID) and now pins the resolved one (OK,
and a parent that is no Structure header refused). The book (provenance, RU
and EN, regenerated): the qualification paragraph now says the root's own `parent` is a structural
link, not a stored reference, and what `immutable` without `independent` therefore seals. Gates: kernel
`fable_rr2c2b_kernel_02` (GREEN, 300 targets, 0 failed; lmx_copy_profile_selftest 53 checks and lmx_qualify_preflight_selftest 33 checks, 0 failures; the first run, fable_rr2c2b_kernel_01, had the preflight self-test red on the overturned expectation); focused harness `fable_rr2c2b_focus_01` (704 targets, 19 failed, all nineteen pre-existing with unchanged details -- the fourteen of the RR2c-3 list (unit_qualified_source_call and _walk, unit_eternal_xref and _walk, unit_t7_host_nested_return, unit_ns2_ref_arg, _return, _admit, _capture and their walked twins, unit_held_definition_free_name) and five among the 393 rows this list adds (unit_capture_struct_whole, unit_capture_struct_merge_two, unit_held_actual_among_methods, unit_held_actual_two_models, unit_held_call_free_name_two_types: located root-walk and callable-formal refusals and an entry signature); against fable_rr2c3_focus_03: FAIL->OK 0, OK->FAIL 0, the eight RR2c-2b rows added, all OK; against today's full run codex_interpreter_throw_full_02 (2894 targets, 78 failed, 14:34): OK->FAIL 0, FAIL->OK 11 (the two unit_k03_merge_op_anon_typed rows of RR2c-1 and nine graph_shape rows of intervening commits), the 19 still-FAIL rows with unchanged details); L3 `fable_rr2c2b_l3_01` (all 11 suites ok, type budget ok); mutants on the
gates' staged sources: kernel, the root rule requiring a prior profile again -> self-test cases E and E2 red (2 of 53) and unit_rr2_qualified_merge_immutable INVALID where the real one exits 7; kernel, a named leaf copied instead of kept -> case H red (2 of 53) and unit_rr2_qualified_merge_callable INVALID where the real one exits 7; translator, retention reading the raw profile (lmx_range_profile) -> the later merge retains the immutable value and the copy's write lands in it: unit_rr2_qualified_merge_immutable INVALID where the real one exits 7; `check_docs` and `diff --check` clean. Open here: the walk of a
qualified merge (RR2d) and Q1.

RR2d (walker): the qualified merge walked, parity with native on every witness.

RR2d-1 is built (`fable_pc`, 2026-10-11): a qualified merge walks through a PRIM entry OF ITS OWN
(`lmx_walk_merge_qualified_map`, bound by the merge's PRIM record), so an unqualified merge keeps its exact
inputs and graph shape; after the ordinary inputs the record carries a trailer -- the result's leaf slots
(its callable fields), the opaque pointer type ids, the program's roles, then the two counts and the
qualifier bits -- every count checked against the input count before it is read. The kernel entry decodes
the trailer and runs the merge (`lmx_walk_merge_run`, the former body of `lmx_walk_merge_map`) with the
native emission's steps in its order: `independent` frees the fresh root of its lexical parent; `immutable`
copies the completed result's subtree under a fresh profile made under a holder node, the callable fields
its leaves kept by address, the copy the value whose layout is proved, then the full preflight proves the
tree and the profile's pools and the holder's are sealed, all before publication; a failed qualification is
a failed primitive. The translator (`l2_rw_merge_prim`, the PRIM builder split out of the own-row write
`l2_rw_merge`) emits the trailer (`l2_rw_merge_qualify_trailer`) and its witnesses; the located refusal at
the root and the native-only method of RR2c-2a go. The returned merge of RR2c-3 walks too: the statement
makes two nodes, as an `if` with an `else` does -- the merge's own node writes the hidden row (its producer,
which the source-order machinery requires) and `[ret, V]` returns it, V the row's schema admitted to the
method's result model (`l2_rw_admit_project` with the row's source: its schema, the method, its D-105
place) and the row's own read the admitted value (`l2_rw_ret_own`). Still native-only, RR2d-2: a method
with a typed merge operand (the walk has no step that builds the anonymous Structure), the typed operand
at the root refused where it stands (`unit_rr2_merge_op_typed_root_limit`). Witnesses:
`unit_rr2_qualified_merge_root` (the chain, `immutable` alone and `const` alone at the walked root; a later
merge retains the independent branch and copies the parented value; replaces the located limit
`unit_rr2_qualified_merge_root_limit`), `unit_rr2_qualified_merge_root_alias_write` (the write through a formal
into a value qualified at the walked root is INVALID: the PRIM's seal reaches the alias), `unit_rr2_return_merge_plain` (+`_walk`: returned merges whose
operands the walk builds -- bare, the chain, `immutable` alone -- so the methods walk under
`--walk-methods`); every `_walk` twin of the RR2 witnesses now walks its methods (the walked L1 binds the
qualified entry) with the same exits, refusals and X1 as native. Gates: kernel `fable_rr2d1_kernel_01` (GREEN, 300 targets, 0 failed);
focused harness `fable_rr2d1_focus_01` (706 targets, 19 failed, all nineteen pre-existing with unchanged details, the same as fable_rr2c2b_focus_01's; against that run: FAIL->OK 0, OK->FAIL 0, the rows unit_rr2_qualified_merge_root, unit_rr2_return_merge_plain and its _walk twin added, all OK, the limit row unit_rr2_qualified_merge_root_limit removed; all 32 RR2 rows OK, every _walk twin walking its methods; the row added after that run, unit_rr2_qualified_merge_root_alias_write, gated in fable_rr2d1_focus_02 (9 targets, 0 failed: the six RR2d rows and their shared targets) on the same staged sources); L3 `fable_rr2d1_l3_01` (all 11 suites ok, type budget ok); mutants on the gates' staged sources:
kernel, the walked qualified merge's proof and seals dropped -> the write through a formal into the value qualified at the walked root lands and the program exits 81 where the real one is INVALID (unit_rr2_qualified_merge_root_alias_write; a method with a typed operand stays native, so the method-level alias twin does not reach this mutant); translator, the walked return's admitted value put at the wrong slot -> unit_rr2_return_merge_plain walked is INVALID where the real one exits 7, the native row untouched; translator, a qualified merge binding the unqualified PRIM entry while emitting the trailer -> the kernel's decode is off and unit_rr2_qualified_merge_root ends in a PRIMITIVE walk error where the real one exits 7; `check_docs` and `diff --check` clean.

RR2d-2 is built (`fable_pc`, 2026-10-11): the merge operand written as a typed declaration walks. The
walk's field PRIM (`lmx_walk_field_map`, bound by the operand's own PRIM record under the merge PRIM) takes
[kind, value] -- the kind the declaration's own type code (int, char, size_t, unsigned, ulong), the value the
declaration's candidate walked as a value of that type (`l2_rw_texpr`; a declaration written without a
value holds the kind's zero, an int literal, the other kinds a located limit) -- and makes a fresh Structure
of one cell of that kind holding the value, what the native emission makes (`l2_emit_merge_typed_operand`);
the merge PRIM reads it as any walked operand and copies it. The translator's form-3 branch
(`l2_rw_merge_typed_operand`) replaces RR2c-1's native-only method and the root's located refusal, so the
author's example as written -- `return: independent: const: immutable: merge(Integer  int: value
newValue)` -- walks under `--walk-methods` (the walked L1 of `unit_rr2_return_merge` binds the field PRIM
three times), and every RR2 witness with a typed operand walks its methods. Witnesses:
`unit_rr2_merge_op_typed_root` (the group and bare forms, a computed value and the operand under the
chain at the walked root; replaces the located limit `unit_rr2_merge_op_typed_root_limit`); the `_walk`
twins of `unit_rr2_return_merge`, `unit_rr2_merge_op_typed_bare`, `_append`, `_clash_refused`,
`unit_k03_merge_op_anon_typed`, `unit_rr2_qualified_merge_decl`, `_alias_write` and the others now walk
with native's exits, refusals and X1. Gates: kernel `fable_rr2d2_kernel_01` (GREEN, 300 targets, 0 failed); focused harness `fable_rr2d2_focus_01`
(707 targets, 19 failed, all nineteen pre-existing with unchanged details, the same as fable_rr2d1_focus_01's; against that run: FAIL->OK 0, OK->FAIL 0, the row unit_rr2_merge_op_typed_root added OK, the limit row unit_rr2_merge_op_typed_root_limit removed; every typed-operand row and its _walk twin OK); L3 `fable_rr2d2_l3_01` (all 11 suites ok, type budget ok); mutants on the gates' staged sources: kernel, the field PRIM storing the kind's zero instead of the walked value -> the walked root fixture reads 0 and exits 81 where the real one exits 7; translator, the value node put at the kind's slot -> the PRIM has one input, INVALID where the real one exits 7; a control: the typed operand marking the method native again while the PRIM is still built -> the walked author example exits 7 either way, as a walk twin can natively -- the walked L1 of the real translation binds the field PRIM three times; `check_docs` and
`diff --check` clean. RR2d is complete: the three qualifiers over a merge, the typed operand and the
returned merge walk at the root and in methods.

RR2e (witnesses and documents): the author's example natively and walked; the chain over a known
named Structure, over an anonymous Structure and over a merge result; each receiver alone with its
own contract and diagnostics; the write, address and mutable-reference refusals of the eternal rows
unchanged on their bytes; the eternal branch's identity kept through a later merge; `catch: merge ()`
and `fn: test ()` untouched. Book RU/EN where a sentence changes; census, ticket, defects.

## Open question to the author (Q1)

`independent: immutable: X` without `const` is physically the same value as the full chain: `const`
protects the binding and leaves no mark in the value. The book grants the eternal exception (merge
retains by reference) only to the combined qualification. Does merge retain such a value by
reference, or copy it? Filed as
[LMX_blog/q/current/eternal-without-const.md](../LMX_blog/q/current/eternal-without-const.md); the
proposed reading is that the physical mark decides retention and `const` decides the binding's
rebinding only. RR2a and the immutability half of RR2b do not depend on the answer; the retention
half does, so it waits.
