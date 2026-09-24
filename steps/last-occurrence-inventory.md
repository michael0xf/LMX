# FABLE-SONNET-LAST-OCCURRENCE-20260924-164 commit 1: measure-first

Author rule (Q22.2 = A, LMX_blog/2026-09-24.md, book §fields, CORE §3.1): an unqualified name
selects the LAST occurrence of a repeated name, including repeated declarations of one name in a
method body. `[N]` stays the explicit lexical occurrence index, unaffected. Merge is out of scope
(Q21 = A) -- a different array, not a contradiction; see below.

## The two general own-field lookups already exist

`l2_own_find(mi, name)` (`:3411`) is the FIRST-match two-phase scan (method/body-scoped first,
then `l2_own_unit_seen` unit-field fallback). `l2_own_find_last(mi, name)` (`:3463`) is the SAME
two-phase structure -- mirrored on purpose (D-10/F-17, -141) so the unit-fallback phase is
identical -- differing ONLY in returning the LAST match instead of the first (no early `return:`,
just keeps overwriting `hit`). `l2_own_find_decl(mi, name, at)` (`:3433`) is a third, different
lookup: the row whose `l2_own_decl[i] = at` exactly -- registration-time self-identity, not a
first/last choice at all. `l2_own_find_occ(mi, name, occ)` (`:3446`) is the explicit `[N]` lookup,
unchanged by this ticket. Nothing new needs to be written for the resolvers themselves; commit 2 is
routing call sites to the right one of these four, already-existing, functions.

## D-10 leftover retry: confirmed fully gone

Both originally-cited sites (`l2_check_sizeof` `:14688`, `l2_prep` `:14859`) call their own-find
function exactly ONCE (no dual first-then-last retry), each with an in-source comment citing D-10
by name. No other call site in the file has the double-attempt shape either (F-17, `14cb573`,
confirmed by exhaustive read of every `l2_own_find(`/`l2_own_find_last(` call site).

## `l2_path_root` and `l2_own_from_expr`

`l2_path_root` (`:11445`) has its OWN independent, hand-rolled resolution for a Structure-typed own
field used as the ROOT of a longer nested path (`:11460-11463`, plus its unit-field fallback
`:11474-11480`) -- neither loop returns early on a match; both scan the full `l2_own_n` table and
keep overwriting `\out_oi`, so both are ALREADY last-occurrence today, structurally identical to
`l2_own_find_last`'s own pattern, independent of `l2_own_find`/`l2_own_find_last` as functions.
`l2_path_root`'s METHOD-NAME-as-root branch (`:11494-11501`, e.g. `test`'s `test\arg`) resolves
only the ROOT segment (to a method index); the trailing FIELD segment is resolved elsewhere (see
"the hardcoded-occurrence-0 site" below). `l2_own_from_expr` (`:6118`) is NOT a resolver: it takes
an already-resolved own-row index `oi` as its only identifying input and just formats the C cell
address from it -- no name lookup, no first/last decision, fully inherits whatever its caller
already resolved.

## Merge is a different array, not a contradiction with "merge creates no repeats"

`FABLE-OPUS-MERGE-ADDRESSING-20260924-154` commit 2 (`7f0d9f4`, already on main) already
implements "unqualified = last occurrence, `[N]` = operand order" for a bound merge result's
fields (`R\x` for `R: merge: Model Over` where both operands have `x`). Out of scope for this
ticket, and not a contradiction: merge-descended fields never become `l2_own_*` rows at all. They
live in a disjoint array (`l2_mrs_*`, "merge result slot") with its OWN resolver
(`l2_mrs_slot_named`/`l2_mrs_slot_nth`/`l2_mrs_occ_read`), reached only when `l2_own_find(mi,
name) < 0` (confirmed at the `l2_check_fields`/`l2_emit_fields` merge-root branches, `:13421`,
`:15471`). "Merge creates no repeats" means: none IN THE OWN-FIELD ARRAY this ticket's resolver
touches -- the merge-side repeats are already handled, correctly, by -154, elsewhere. Useful prior
art for the witness/mutant shape; its own code is untouched by commit 2 here.

## The hardcoded-occurrence-0 site: `method\field` unqualified (NOT found by the l2_own_find grep)

Two call sites use `l2_own_find_occ`, not `l2_own_find`, for the UNQUALIFIED case of a
method-name-rooted 2-segment path (`test\arg`, no `[N]`) -- found by direct read of
`l2_check_fields`/`l2_emit_fields`'s method-occurrence branches, not by grepping for
`l2_own_find(`:

- `l2_check_fields` `:13467`: `po: l2_own_find_occ(l2_find_method(f\value\as\atom),
  p2\value\as\atom, 0)` -- hardcoded occurrence **0**.
- `l2_emit_fields` `:15536`: the same call, same hardcoded `0`, emission-side twin.

The in-source comment directly above `:13467` (`:13439-13448`, my own -146 wording) says so
explicitly: *"`test\[N]name` picks occurrence N; unqualified `test\arg` is occurrence 0
(FABLE-SONNET-OCC-ROOT-20260924-146)."* This is the FIRST-occurrence choice the new rule reverses.
Fix: replace `l2_own_find_occ(l2_find_method(...), name, 0)` with `l2_own_find_last(l2_find_method(...),
name)` at both sites (`l2_own_find_last` takes no occurrence argument -- it already walks to the
last match).

No existing fixture currently exercises this site with a plain (non-argument-bound) repeated own
field, which is why this hardcoded-0 bug has sat unexercised: `unit_occ_self_field.lm2`'s `probe\v`
has only one occurrence (first=last=only), and `unit_occ_root_named.lm2`'s `test\arg` is
argument-bound, whose value is overridden at checkpoint-publish time regardless of which row the
lookup picks (see fixture survey below) -- both happen to be rule-invariant by accident, not
because this site was already correct. Fable's own ticket example (`fn: test () int` / `int: arg
1` / `int: arg 2`, plain own-declared, non-argument-bound) is exactly the shape that will finally
exercise this site and distinguish first from last.

## Full `l2_own_find(` call-site catalog (research fork, cross-checked)

36 call sites, classified. **Category A -- genuine unqualified-reference resolution, move to
`l2_own_find_last`:**

| line | fn | what it resolves |
|---|---|---|
| 5628 | `l2_colon_bound_ty` | type of a bound name, colon assignment-compatibility check |
| 6686 | `l2_scan_ident` | bare identifier -> own row, marks `l2_m_uses`/`l2_m_pre` |
| 6724 | `l2_scan_node` (`@: name`) | same usage-marking, address-of shape |
| 7118 | `l2_dyn_step` | caller-side dynamic-input source binding |
| 7835 | `l2_own_index_tail` | bare own-array field being indexed |
| 7890 | `l2_array_length_own` | bare `length(name)` operand's own-array field |
| 9891 | `l2_graph_nsty` | graph-valued name -> declared Structure type |
| 13136 | expression/primary atom branch | expression-position bare-name resolution |
| 13718 | own-array-use guard | refuses bare array use |
| 14177 | `l2_hidden_from` (caller side) | resolves `nm` against caller's own table |
| 14201 | `l2_hidden_from` (callee side) | resolves `nm` against callee's own table -- must track whatever the callee body itself resolves to |
| 14281 | `l2_check_addr` | `@name` address-of target, checking side |
| 14353 | `l2_prep_addr` | `@name` address-of target, emission side -- must match 14281 |
| 16598 | `l2_ccall_box_int` | raw-C-call argument name -> type (boxing) |
| 17876 | `l2_emit_body` field-path assignment | write-destination identity -- see live inconsistency below |
| 18010 | `l2_emit_body` (C-style `for` init) | loop counter's own row, emission |
| 18046 | `l2_emit_body` (C-style `for` step) | same counter, emission |
| 18179 | `l2_emit_body` (`nextMessage:`) | own row for emission |
| 18216 | `l2_emit_body` (`Model: fresh`) | own row for emission |
| 18245 | `l2_emit_body` (empty-struct decl) | own row for emission -- pairs with 5871 |

Plus, found separately (not `l2_own_find`, `l2_own_find_occ` with hardcoded `0`): `l2_check_fields`
`:13467`, `l2_emit_fields` `:15536` (above).

**Category B -- existence-only (index only ever tested `>=0`/`<0`); switching is cosmetic, zero
behavior change, not worth touching (matches D-10's own precedent of leaving existence-only sites
alone):** `:7836`, `:7891`, `:10320`, `:11901`, `:13421`, `:13972`, `:13982`, `:15471`, `:14688`
(D-10-documented).

**Category C -- declaration/self-identity, NOT a first/last choice at all; the correct fix is
`l2_own_find_decl(mi, name, at)` (exact declaration-node match), not `l2_own_find_last`:**

| line | fn | why `_decl`, not `_last` |
|---|---|---|
| 5853 | `l2_empty_struct_assign_shape` | tests `l2_own_decl[oi] != stmt` -- wants "is the row I find NOT this statement's own row"; its own in-source comment (`:5827-5836`) already states the intended semantics ("l2_own_find(mi, fr\head) finds THAT row" -- the row `l2_own_add` just appended for `stmt` itself). `l2_own_find_decl(mi, fr\head, stmt)` finds that exact row directly, correctly, regardless of how many other same-named rows exist; plain `l2_own_find` (first) only works today by accident, when the name has no other occurrence |
| 5871 | `l2_empty_struct_decl_shape` | identical pattern, identical fix |
| 6956 | `l2_scan_body` (`for`-init `seen[oi]` mark) | wants "the row for THIS declaration line," by node identity, not by name match at all; `l2_own_find_decl(mi, name, last\value)` |
| 6998 | `l2_scan_body` (decl-line `seen[oi]` mark) | same pattern; `l2_own_find_decl(mi, fa, stmt)` |
| 18310 | `l2_emit_body` (own-decl-line liveness/bind-mark) | emission twin of 6998; must resolve identically -- same fix |

Note: unlike `l2_own_find_last`, `l2_own_find_decl` is not guaranteed to find a match by name
alone if declarations are pre-registered out of the order this scan visits them; but that is
exactly the point -- these five sites need "my own row," which `_decl` gives unconditionally,
where `_last` would only give the right answer when the scan visits declarations in the same order
`l2_own_add` appended them (true for a simple forward pass, not a safe assumption to rely on
implicitly when an exact-match primitive already exists for this).

## Two live first/last inconsistencies already in the codebase today (pre-existing, not new)

1. **`:6984` vs `:18373`**: both implement the identical logic -- "is this statement its own
   declaration (exact node match via `l2_own_find_decl`), else resolve as a write to an existing
   field" -- but `:18373` (emission) already falls back to `l2_own_find_last`, while `:6984`
   (`l2_scan_body`, the earlier scan pass over the same statement shape) still falls back to plain
   `l2_own_find` (first). For a repeated name, these two passes over the SAME statement can
   already disagree today about which row is "the" existing field. Fix: `:6984`'s fallback moves
   to `l2_own_find_last`, matching `:18373`'s already-established pattern.
2. **`:17870`/`:17876` vs `l2_path_root`'s internal resolution**: `l2_path_root`, called at
   `:17870`, computes its own field-path-root candidate (`l2_poi`) using LAST-occurrence semantics
   internally (see above) -- but that value is discarded for identity purposes; `:17876`
   immediately re-resolves the SAME root via plain `l2_own_find` (first) into `l2_pown`, which is
   what actually drives the type check and the emitted `l2_q%d` token. For a repeated name,
   `l2_poi` (last) and `l2_pown` (first) can already disagree today, and the wrong (first) one
   wins. Fix: `:17876` moves to `l2_own_find_last` (simplest local fix, consistent with every
   other Category-A site; reusing `l2_poi` directly would also work but touches more of the
   surrounding branch than necessary for this ticket).

Both are pre-existing latent bugs for a repeated name that -164 incidentally fixes as a side
effect of routing every genuine-reference site through one resolver, not effects of the rule
change itself -- worth citing as such, not only as "sites to switch."

## Fixture survey: which fixtures pin `[0]`/unqualified-first behavior today

- **`unit_occ_root_named.lm2`** (`test\[0]arg`/`test\[1]arg`/`test\arg`, all asserted `= 2` today,
  gated `Expect = eternal-runs, Exit = 0` via its own internal `if: ... return: 8N`): **not
  affected.** `arg` is ARGUMENT-BOUND (a formal). `l2_emit_checkpoint` publishes every occurrence
  row of an argument-aliased field from the ONE canonical parameter cell (the argument
  same-name-binding rule, L2 spec 18.3), never from that row's own snapshot -- an override at
  checkpoint-PUBLISH time, after whichever row the lookup picks. All three keep reading 2 under
  the new rule too, for a reason independent of first-vs-last. (This fixture is also the one that
  happens to make `:13467`/`:15536`'s hardcoded-0 bug unobservable today, per above.)
- **`unit_occ_arg_slots.lm2`**, **`unit_occ_snapshot_selector.lm2`**: assert `\[0]`/`\[1]`
  exclusively, no unqualified read. **Not affected** ([N] unchanged).
- **`unit_occ_self_field.lm2`**, **`unit_occ_root_field.lm2`**: no repeated declaration of the
  same name at all. **Not applicable.**
- **`unit_occ_sticky_selector.lm2`**: `before`/`after`/`none` each re-declare their formal's name
  as a later local (`fn: before (int: ba) int` ... a later `int: ba`, same spelling) -- a genuine
  non-argument-bound repeat, read/written unqualified via `before\ba`/`after\af`/`none\nn`. Gated
  `Expect = eternal-runs, Exit = 0, Needle = ''` with NO internal assertion (`return: 0`
  unconditional) -- **not currently pinned** (nothing breaks today if the printed values change),
  but its printed output will likely change once the resolver is unified; worth a manual
  post-fix re-check of its actual stdout, not a required gate-row edit.
- **`unit_merge_last_occurrence.lm2`**, **`unit_merge_occurrence_range_refused.lm2`**: merge-root,
  `l2_mrs_*`, out of scope (see above). **Not affected.**

No other fixture in the corpus has a repeated same-name own/local declaration combined with an
unqualified occurrence-path read/write and an internal pinned assertion.

## Commit 2 done -- and a bigger, load-bearing discovery along the way

Landed exactly per the plan above: Category-A (20 sites) + `:13467`/`:15536` (hardcoded `0` ->
`l2_own_find_last`, both the check-time and emit-time twins) moved to `l2_own_find_last`; the two
live inconsistencies (`:6984`'s fallback, `:17876`) moved to match their already-correct siblings
(`:18373`, `l2_path_root`'s `l2_poi`). Category B left alone (cosmetic). Category C's 5
self-identity sites were **not** moved to `l2_own_find_decl` after all -- see below; left as
plain `l2_own_find`, documented as an explicit, deliberate non-change (out of this ticket's scope,
not an oversight).

**The planned witness (fable's own literal example) does not translate.** `int: arg 1` / `int:
arg 2` (two TYPED declarations of the same name) hits `l2_own_add`'s pre-existing, deliberate
"duplicate declaration" refusal (`:3554`, "one name, one cell per scope") -- unrelated to this
ticket, not relaxed here. Measured directly. The rule's own repeat mechanism, confirmed against
`unit_occ_arg_slots.lm2`'s header comment ("Two assignment occurrences of arg are two physical own
slots"), is: one typed declaration, then a PLAIN (untyped) reassignment -- but this ALSO measured
false for a plain (non-formal) field: `fn: test () int / int: arg 1 / arg: 2` then
`test\[1]arg` -> "own occurrence index out of range". **A repeated own-field occurrence, in the
corpus's current legal syntax, can only be created via the argument same-name-binding rule (L2
spec 18.3) -- the name must be a formal, reassigned by name.** Plain (non-argument) own fields are
capped at exactly one occurrence today; D-27 (steps/defects.md, OPEN, `\[N]x` on a non-parameter
own-local crashing without a located diagnostic) is the closest existing echo of this same
boundary, not a counterexample to it.

**This makes most of commit 2's routing observationally inert today, and explains why.** Every
consumer this ticket touches checks `l2_param_find(mi, name)` (is this name a formal of the
CURRENT method) before ever reaching `l2_own_find`/`l2_own_find_last` -- confirmed directly at
every site read in this investigation (`l2_check_addr`/`l2_prep_addr` :14282/:14354,
`l2_hidden_from` caller/callee :14178/:14202, and the pattern recurs structurally everywhere a
formal and an own field can share a name). Since a repeated own row can only exist for a name that
IS a formal, and the formal fast path always wins first, `l2_own_find` vs `l2_own_find_last` never
actually gets to choose between two DIFFERENT rows for any program this corpus can express today.
The routing change is still correct, still closes two real cross-path disagreements (worth having
fixed regardless, as defense against the day the duplicate-declaration or plain-reassignment
restriction relaxes), and the full harness stays GREEN (334/334, zero regressions) -- but it is not
demonstrably load-bearing today, and this note says so plainly rather than claiming a witness that
does not exist.

**The actually-live mechanism for fable's example (a method-rooted 2-segment path, `test\arg`,
`test\[N]arg`) is a third function neither this ticket's own commit-1 catalog nor the research
fork named: `l2_own_seg_scan` (`:11589`), reached through `l2_path_root`'s method-name-root branch
(`root <= -1000`) via `l2_path_kind`/`l2_emit_path_to` (`:11719`, `:11840`) -- NOT through
`l2_check_fields`/`l2_emit_fields`'s flat-token branches (those exist for the bracketed `[N]` form
specifically, per their own comment: `l2_join_path` cannot carry a bracket segment; the plain,
unbracketed `test\arg` is already a normal multi-segment path `l2_path_root` parses directly, so
the flat-token branch at `:13467`/`:15536` this commit "fixed" is dead code for this exact shape --
harmless, still correct, just not reachable here). `l2_own_seg_scan`'s own scan loop never returns
early and keeps overwriting `hit`, exactly `l2_own_find_last`'s pattern -- so it SHOULD be
last-occurrence by construction, same as `l2_path_root`'s own hand-rolled loops (`:11460`-`:11480`,
noted in commit 1 above).

**Measured directly, it is NOT consistently last -- a genuine, newly-found, NOT-yet-fixed defect,
filed as D-47.** A probe fixture (`fn: test (int: arg) int / arg: 1 / arg: 2 / return: 0`, called
and read via `test\[0]arg`/`test\[1]arg`/`test\arg` from INSIDE a second method, `check()`) gives
`test\arg` = occurrence 1 (last, correct). The SAME shape read from ROOT LEVEL instead -- exactly
`unit_occ_root_named.lm2`'s existing, tracked, gated fixture -- gives `test\arg` = occurrence 0
(first, wrong per the new rule): confirmed by direct inspection of its generated C/L1
(`l2_xp: lmx_arena_ref_cell(lmx_arena_ref_struct(self,5U), 1U)` for BOTH `test\[0]arg` and
unqualified `test\arg`, cell 1 = occurrence 0's own slot, not occurrence 1's cell 2).
`unit_occ_root_named.lm2`'s own assertions (`test\[0]arg = 2`, `test\arg = 2`) do not catch this,
for the SAME reason documented above in commit 1: `arg` there is argument-bound, and occurrence 0's
checkpoint-publish re-syncs from the live formal cell, which happens to equal 2 (the last plain
assignment's value) regardless of which row is nominally "occurrence 0" -- masking a first-vs-last
bug that is real and would be visible with a non-monotonic value sequence (confirmed with the
`unit_own_last_occurrence.lm2` poke9 probe below, which DOES distinguish them, but only tests the
method-body-read case, where the bug does not reproduce).

Root cause not yet isolated within this ticket's remaining budget: `l2_own_seg_scan`'s host
parameter is a literal `0` at both its `root <= -1000` call sites (`:11719`, `:11840`), matched
against `l2_own_host[i]`, set at registration time to `l2_scope_host()` (`:3594`) -- a simple
scope-depth flag (0 outside any nested if/while/for), which SHOULD be 0 for both of `test`'s
top-level assignment statements regardless of who later reads `test\arg`. Something about
ROOT-level translation specifically (the entry/E method's own special-cased handling, pervasive
elsewhere in this file -- `l2_e`, `l2_e_own_seg`, etc.) changes which row `l2_own_seg_scan` lands
on when the CALLER of the read is root rather than an ordinary method; the read side calls
`l2_own_seg_scan` with the exact same literal arguments either way, so the divergence must be in
what got REGISTERED for `test`'s two `arg` rows, or in `l2_own_n`'s ordering, by the time root-level
code runs versus by the time a same-shaped method's body runs -- not yet traced further. Recommend
a focused follow-up (D-47) rather than a rushed fix to a mechanism not yet fully understood.

## D-47 retracted -- FABLE-SONNET-SEG-SCAN-ROOT-20260924-165, root-caused, NOT a real defect

Investigated as its own ticket (base `f4ac8e5`, the integrated -164 tree). **The "root gives
first" reading above was a testing artifact of mine, not a property of the translator.** What
actually happened: the generated C/L1 I inspected for `unit_occ_root_named.lm2` (cell 1 for
`test\arg`, quoted above) was read from `build/harness_164_mutant` -- the build directory where I
had DELIBERATELY reverted the two hardcoded-occurrence-0 sites (`l2_check_fields`/`l2_emit_fields`'s
flat-token branches, `:13467`/`:15536` pre-renumbering) back to `l2_own_find_occ(..., 0)` to build
a mutation witness for -164's OWN fix. I never re-checked that specific fixture's generated code
against a CLEAN (non-mutant) build before writing it up. The mutant naturally reproduced
first-occurrence behavior there -- because `unit_occ_root_named.lm2`'s `test\arg` goes through
THAT flat-token branch, not `l2_own_seg_scan` at all (see below) -- and I misread "the mutant's own
deliberate revert doing exactly what it was built to do" as "a newly discovered root-level bug in
a different function." Confirmed directly (`grep -n "l2_xp: lmx_arena_ref_cell(...self, 5U)"` on
the CLEAN, real-fix build's generated `unit_occ_root_named.lm1`, no mutant applied): `test\arg`
resolves to **cell 2** (occurrence 1, correct/last), not cell 1. The fixture has been giving the
right answer since -164 commit 2 landed; nothing here needs fixing.

While re-establishing this, direct instrumentation (temporary `c.fprintf` probes in
`l2_own_seg_scan` and in `l2_path_root`'s method-root branch and in `l2_check_fields`'s flat-token
branch, rebuilt and run through the harness, then fully reverted -- no trace left in the tree)
settled the real shape of the two mechanisms, which commit 1/2's own writeup above did not have
quite right either:

- **Which of the two resolvers fires is decided by STATEMENT SHAPE, not by root-vs-method
  context.** A method-rooted path used as an `if:` condition operand (`if: test\[0]arg != 2`, `if:
  test\arg != 2` -- `unit_occ_root_named.lm2`'s own shape) goes through
  `l2_check_fields`/`l2_emit_fields`'s flat-token branches (both the bracketed AND the unqualified
  form) -- confirmed firing 1:1 with each such read, in EITHER a root-level `if:` or a method-level
  `if:` (built and ran both; identical mechanism, identical correct result in both). The flat-token
  branch is very much alive for this shape -- the "dead code" claim above (`:230`) was wrong; it
  was dead only for the plain-assignment shape I had tested it with, not for `if:`-condition
  operands. A method-rooted path used as a PLAIN colon-assignment RHS (`x: test\arg`) instead goes
  through `l2_field_path_check`/`l2_field_path_read` -> `l2_path_root` -> `l2_own_seg_scan` --
  confirmed firing for that shape and NOT for the `if:`-condition shape, in both a method body
  (`unit_own_last_occurrence.lm2`'s own check()) and, newly tested here, at ROOT level too (`int:
  last` / `test(0)` / `last: test\arg` at root, no method) -- both gave the correct last-occurrence
  value (2), both went through `l2_own_seg_scan`, no root-vs-method divergence found anywhere.
- Both mechanisms are already last-occurrence-correct, in both syntactic positions, in both
  root-level and method-level translation contexts, on the current tree. No further fix needed for
  D-47/last-occurrence beyond what -164 commit 2 already landed.

D-47 closed as NOT REPRODUCIBLE (own testing artifact); see `steps/defects.md`. Lesson for next
time, recorded plainly: when a mutant build and a "clean" build share a directory-naming
convention this close, re-verify which one is loaded before citing its generated code as evidence
of anything -- a diff against the pre-mutant backup, or a fresh non-mutant rebuild, would have
caught this in minutes instead of costing a whole follow-up ticket.

**Witness landed this commit**: `unit_own_last_occurrence.lm2` (poke9 probe, reads via `check()`,
not root) -- pins that the method-context case is already correct, both read and write
(`test\[0]arg=9`, `test\[1]arg=2`, `test\arg=2`, then `test\arg: 5` lands in occurrence 1 leaving
occurrence 0 at 9). Documented in its own header as NOT a mutation witness for this commit's
routing changes (per the inert-routing finding above) -- a regression/behavior-pin test, not
evidence the diff did anything. No fixture in this commit exercises D-47 (root-level); doing so
safely needs `unit_occ_root_named.lm2` itself to gain new, currently-masked assertions, which is
D-47's own fix, not this commit's.

Gates: build_l2src 252/252, l2_harness 334/334 GREEN (333 base + 1 new row), L3 11/11 + type
budget, check_docs OK, git diff --check clean -- all green with the routing change in place, no
regressions.
