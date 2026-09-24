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

## Commit 2 plan (for the next commit in this ticket)

1. Move every Category-A site (20) plus `:13467`/`:15536` (hardcoded `0` -> `l2_own_find_last`) to
   `l2_own_find_last`. Leave Category B (existence-only, 9 incl. `:14688`) untouched.
2. Move the 5 Category-C self-identity sites (`5853`, `5871`, `6956`, `6998`, `18310`) to
   `l2_own_find_decl(mi, name, at)`.
3. Fix the two live inconsistencies: `:6984`'s fallback -> `l2_own_find_last` (matching `:18373`);
   `:17876` -> `l2_own_find_last` (matching `l2_path_root`'s already-last `l2_poi`).
4. New witness: the ticket's own example (`fn: test () int` / `int: arg 1` / `int: arg 2`,
   plain own field, non-argument-bound) -- `test\arg = 2`, `test\[0]arg = 1`, entry built to 7
   (per the ticket text); a write `test\arg: 5` landing in the last occurrence (`test\[1]arg` reads
   5 back, `test\[0]arg` still reads 1).
5. Mutant: revert the resolver choice at the new fixture's site back to first -> RED.
6. Gates: build_l2src 252, harness base 333 (+1 new row), L3 11/11, check_docs, git diff --check.
