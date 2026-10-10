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
