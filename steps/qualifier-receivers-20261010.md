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

RR2d (walker): the merge PRIM carries the profile and the independent flag as two more inputs
(`lmx_walk_merge_map`), parity with native on every witness.

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
