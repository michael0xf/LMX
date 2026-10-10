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

RR2b (kernel, the readers): `lmx_walk_immutable` and `lmx_copy_retained_profiles` read the mark by
classification (profile ≠ 0, sealed; for retention also root `parent = 0`) beside the lists; the
static fixtures are the witness that nothing moves; then the lists are removed in a separate commit.
The retention half waits for the author's answer to Q1 below; the immutability half does not.

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
