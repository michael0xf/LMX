# Merge kernel, after T1: k.1, read-only (-194)

FABLE-SONNET-MERGE-KERNEL-20260926-194 (Sonnet), k.1.  Base: main b84bb0d (T1 landed, -192
landed).  No code changes.  Covers merge-parts-193.md §2 (1) 1a-1g and §6 K-OT1/K-OT2/G-call,
under fable's rulings: Q1 (part recursion is the translator's -- one flat "merge into target"
primitive, no sub-map, the same shape Q26.1 needs), Q2 (an operand body part's OP frames replace
the model's; holder-less own-field frames are "this activation's data"), Q5 (holder 0 = f\data,
one node kind).

## 1. K1 (1a-1d): the kernel's own merge, `lmx_merge_owned.lm1`, measured

`lmx_merge_profiles_owned` (l38) already carries the T1 map (`LmxMergePair {model_slot, operand,
field}`, h.lm1 l60-64) and the two-path width/slot-fill logic (`use_map` at l63-136,
l224-337 for slot fill).

### a. Body as a pair source -- confirmed, not yet possible

- Width: `use_map = 1` totals `model_w` (operand 0's width) plus every LATER operand's
  unmatched fields (l110-132), then `body`'s own full width unconditionally (l133-136) --
  body is never subtracted for a match.
- Slot fill: the body block (l319-337) is a bare loop over `lmx_merge_width(body)`, storing
  every field of the copied body at the next free `at` -- zero calls into the override map.
- The override validation (l99-108) refuses `overrides[p]\operand >= count`, so a pair can
  today only name one of the OPERANDS array, never the body (body is a separate parameter,
  outside `operands[]`/`count`).
- Proposed, matching merge-parts-193.md's own proposal: body is operand `count` in the map (so
  `overrides[p]\operand = count` means "the body's field `field`"), and the slot-fill body block
  gains the same paired/unpaired split the operand loop already has (l286-317) -- paired fields
  overwrite the named model (or earlier-operand) slot instead of appending.

### b. A pair's target: today model slots only

- l104-105: `if: overrides[p]\model_slot >= model_w -> INVALID`. A pair's `model_slot` must be
  `< model_w` -- the ORIGINAL model's own width, before any later-operand or body field is
  appended.  There is no way today to target a slot an EARLIER operand just appended (`merge: A
  B C` where C's `z` should land in the `z` B already added, not the model's own slots).
- Proposed: widen the target check from `< model_w` to `< model_w + (appended so far when this
  pair is applied)` -- i.e. a pair may target any slot the result already has BEFORE this pair's
  own operand is reached, model or appended.  Since pairs are applied in operand order today
  (see c below), "before this pair's operand" is well-defined as "model width + every earlier
  operand's own appended count," computable in the same pre-scan that validates the map.

### c. Map validity -- duplicate TARGET is now legal (T1), duplicate SOURCE is still unchecked

merge-parts-193.md's own §2(1)c text ("same target twice, are INVALID") is superseded by fable's
T1 ruling (§4, "T1 landed, main a952dd5: ordered duplicate targets are legal; K1 records «pairs
apply in operand order, duplicate targets allowed»").  Measured against a952dd5's code:

- The override-application loop for later operands (l286-317) walks `i` from 1 to `count`, `j`
  over each operand's own width, and for each UNPAIRED `(i, j)` appends; for each PAIRED one it is
  simply skipped in THIS loop (the write itself happens in the earlier pass at l267-285, in
  OPERAND ORDER, `p` from 0 to `override_count`).  So today's code already applies pairs in
  operand-then-pair order with no distinctness check on `model_slot` at all -- unit_merge_three_
  operands (B's x and C's x both into Model's x) already exercises this and is GREEN.  T1's own
  ruling matches the code as it stands; no change needed here.
- What is NOT checked, and matches §2(1)c's remaining half: two pairs with the SAME SOURCE
  (`operand`, `field`) both present in the map.  Nothing in l99-108's validation, or in the
  application loops, refuses this -- the second write into whatever target it names would simply
  happen after the first, silently.  This can only arise from a translator defect (each source
  field should appear in the map at most once, matched to its unique named target), so it is a
  cheap O(P^2) guard to add alongside the existing per-pair bounds checks: a source `(operand,
  field)` seen twice among the map's `P` entries is `LMX_MERGE_INVALID`.
- Kind/type: unchanged from -193's read -- the translator decides admissibility statically before
  ever building a pair; the kernel pairs by position (`model_slot`, `operand`, `field`) alone and
  trusts the translator's map. No kernel-side kind/type check is proposed or needed.

### d. Nested Structure parent -- confirmed, reproduced by direct trace

- The copier's own parent-fixup (`lmx_copy_process`, l779-808 of lmx_graph_copy_owned.lm1) sets
  each copied Structure's `\parent` to the COPY of its SOURCE parent (`lmx_copy_map_get(map,
  src\parent)`, l807).  For a nested own-Structure field of operand A, the source parent is A
  itself, so the copy's `\parent` becomes `copies[i]` (A's own copy-root, built by
  `lmx_graph_copy_many_profiles_owned` at l184) -- a Structure address that is NOT `result`
  (`result` is built afterwards, at l209, strictly after the copy phase finishes).
- `lmx_merge_owned`'s own slot-fill (l224-337, both paths) copies the VALUE at each source slot
  into `result`'s own slot verbatim (`value: \slot; lmx_arena_ref_store(result, ..., value)`) --
  it never touches `\parent`.  So `result`'s slot ends up holding a reference to a Structure whose
  `\parent` is `copies[i]`, an object nothing else in the finished merge result reaches (`copies`
  itself, the C array of pointers, is `free()`'d at l351-352, but that frees only the array, not
  the LMX Structures it pointed at -- `copies[i]` stays a live, address-reachable node in
  `dst_arena`, just unreachable from `result`'s own tree except backward, through this one child's
  `\parent`).
- Consequence, confirmed by reading (not run, per the ticket's own note) against the copier's own
  own-vs-terminal test (l494-496 of lmx_graph_copy_owned.lm1: `occ\parent = 0 || inside = 0 ||
  not-in-inside -> terminal, keep by address`): a LATER merge/copy of `result` enqueues `result`
  itself as "inside," but never `copies[i]` (nothing reaches it going forward) -- so the nested
  child's `occ\parent` (`copies[i]`) is never found in that later copy's `inside` map, and the
  child is treated as a SHARED TERMINAL (kept by address) instead of being deep-copied as
  `result`'s own child.  Exactly as merge-parts-193.md predicted.
- Proposed fix, matching the ticket's own proposal: after filling `result`'s slots (both the
  flat-append and the map path), walk `result`'s DIRECT children once; for each that classifies
  STRUCT (`lmx_range_classify(dst_arena, v) = LMX_KIND_STRUCT`) and whose `\parent` equals one of
  `copies[0..nroots-1]` (an operand-root copy, held until the `free()` at the end -- the fixup
  must run BEFORE that free), rewrite `\parent` to `result`.  A shared/terminal nested Structure
  (kept by address, per Q22 = II -- its `\parent` lies OUTSIDE the copied subtree to begin with)
  never matches any `copies[]` entry and is untouched, so this fixup cannot accidentally re-parent
  a genuinely shared reference.

## 2. "Merge into" as a primitive -- does not exist yet (correction to the ticket's framing)

The ticket text (and merge-parts-193.md §2(1)e / the author's Q26.1 answer) refers to
`lmx_walk_merge_into` as something to compare against `lmx_merge_owned` for what to factor out.
Measured: `grep -rn "merge_into" dev/` (source tree, all `.lm1`/`.h.lm1`) returns **zero matches**.
The only place this name exists is prose design in `steps/root-putof-mul-183.md`'s "The «into»
form: q26's own-field write" section (l160-206) and `steps/put-ref-186.md`'s two references (l42,
l108) -- both read-only design notes, never landed.  `o\inner: a` (an own Structure field
written from another Structure) is STILL a located refusal today, confirmed at both ends:
- Root/translator: `l2_rw_path_write` (l2trans.lm1 l17312-17325) refuses "a Structure assigned
  through a path" whenever the path's terminal kind is 2 or 3 (an own Structure slot or a
  reference), unconditionally -- there is no emission of any merge-into form yet.
- Kernel: no `lmx_merge_into_owned` or `lmx_walk_merge_into` C function exists to emit into.

So (2) is not "what's common between two existing things" -- it is "build the one primitive
-183 already designed, in the shape Q1 now fixes: no sub-map, no recursion inside the kernel."

### The shape (per -183's design, confirmed still fit under Q1/Q2)

`lmx_walk_merge_into [prim, record, target, pairs, op]`, a walker PRIM parallel to today's
`lmx_walk_merge_model` (lmx_merge_owned.lm1 l371-394, itself a thin PRIM wrapper: classify,
call the kernel merge function, publish `\out`):
- `target`: the own Structure written into (`o\inner`, or -- for K3's later use, Q1's "translator
  emits nested merge-into calls" -- one part of a callable, e.g. the model's `body` slot).
- `op`: the source Structure (`a`, or the operand's corresponding part).
- `pairs`: an `LmxMergePair` array/count, THE SAME TYPE `lmx_merge_owned.h.lm1` already declares
  (h.lm1 l56-64) -- `model_slot` here means "target's slot," `operand`/`field` collapse to just
  `field` since there is exactly one source (`op`), not an array of operands. Reusing the exact
  struct (with `operand` always 0, or a narrower two-field struct) is a kernel-shape choice, not a
  new concept -- either way it is the position map the translator already knows how to build
  (`l2_mrs_build`/`l2_mrs_join`, T1's own emission).
- No recursion, no sub-map: Q1 stands on the code as read -- the kernel function pairs `op`'s
  fields into `target`'s slots and stops.  A caller (T5, later) wanting "args into args, return
  into return, body into body" emits THREE separate `lmx_walk_merge_into` PRIM calls (or three
  native `lmx_merge_into_owned` calls), one per part, each with its own `pairs`.  The kernel never
  sees "parts" as a concept.
- \out is 0 (Q26.1: an own-field write is a STATEMENT, per -183's own read) -- callers that need
  a value (K3's part-merge, if it ever needs one) read `target` itself afterward, unchanged in
  identity.
- What's genuinely shared with `lmx_merge_owned`/`lmx_merge_profiles_owned`, confirmed by re-
  reading both designs side by side: the PAIR APPLICATION LOOP itself (copy each paired source
  field's value into a destination slot, append or refuse the rest) is the same shape T1 already
  built for the FRESH-result path (l249-317).  The one structural difference is the destination:
  `lmx_merge_owned` writes into a FRESH `result` (`lmx_node_new_owned`, l209) that starts empty
  and gets EVERY slot filled by the map/append logic; `lmx_merge_into_owned` writes into an
  EXISTING `target` whose slots the pairs at most OVERWRITE (append only for the one case -183
  flags as untested by any row: an unpaired op field growing `target`'s own field array in place,
  which needs `target`'s `LmxArenaRefs` to grow after construction -- not needed by q26's own two
  rows, both full pairings; K1 should NOT build growable in-place append speculatively, and should
  flag it as a located refusal if `op` has an unpaired field, same as today's map validity refusals).
- Proposed factoring: extract the "apply one pair's value onto one destination slot" step (l260-
  264's own body: `slot: lmx_arena_ref_cell(copied, field); value: \slot;
  lmx_arena_ref_store(dest, target_slot, value)`) as a small shared helper
  (`lmx_merge_apply_pair` or similar) called from both `lmx_merge_profiles_owned`'s map path and
  the new `lmx_merge_into_owned` -- one helper, two callers, no behavior change to T1's own tests.

## 3. K-OT1: OP frames are not kept by address today, in EITHER the copier or `lmx_fresh`

merge-parts-193.md §6's own correction ("only the role RECORDS, LMX_DOMAIN_KIND_OP, are terminals
for the copier and for lmx_fresh... an OP FRAME is an ordinary Structure") is confirmed exactly by
reading both consumers.

### The copier

`lmx_copy_is_terminal_profiles` (lmx_graph_copy_owned.lm1, read around l363-390) classifies the
VALUE's OWN kind directly (`LMX_DOMAIN_KIND_OP`, `_ROLE`, `_PRIMITIVE`, `_MSG_RECORD` -> terminal).
An OP FRAME (e.g. an `[own, holder, idx]` Structure T4 would emit as one of M's direct children)
classifies as plain `LMX_KIND_STRUCT` -- its role record lives INSIDE it, at its own child[0], not
as the frame's own kind.  So `lmx_copy_is_terminal_profiles` returns 0 for a frame, and
`lmx_copy_value`'s STRUCT branch (l482-500) decides its fate by the OWN-CHILD rule instead:
`occ\parent = 0 || not-inside -> terminal` (l495-496).  A frame's `\parent` is M itself, and
merging/copying M means M is "inside" the copied subtree from the start -- so every one of M's own
OP-frame children is found "inside" too, and gets deep-copied as a fresh subtree
(`lmx_copy_ensure_struct(..., content=1)`, l498), recursing into the frame's own operands.  "Any
merge that copies M copies them too," exactly as predicted.

### `lmx_fresh`

`lmx_fresh_child` (lmx_fresh.lm1 l18-90) has the identical shape, one file over: the STRUCT branch
(`kind = LMX_KIND_STRUCT`, l47-73) checks `nested\parent = proto -> recurse via lmx_fresh_struct`
(l50-56) BEFORE any "is this child itself an op/role frame" test.  The ONLY existing "keep an
operand of an op/role frame by address" check (l58-72) looks at `proto`'s OWN head (is the
STRUCTURE BEING RECURSED INTO itself an op/role frame, so ITS children are frame operands to
keep) -- it never asks whether `nested` (the child about to be recursed into) is ITSELF a frame.
So a re-entry (`lmx_fresh_struct` on M, e.g. FRESH on recursion) walks M's own children, finds each
OP-frame child classifies STRUCT with `parent = M`, and deep-copies it as a brand new Structure --
"frames whose parent is M are deep-copied by lmx_fresh on every re-entry," confirmed.

### The fix (same shape, both files)

Both `lmx_copy_value`'s STRUCT branch and `lmx_fresh_child`'s STRUCT branch already contain the
right IDIOM one level down (check whether SOME Structure's own child[0] classifies as
`DOMAIN_KIND_OP`/`_ROLE`) -- lmx_fresh.lm1 l60-66 is a literal template:
```
head: lmx_arena_ref_value(proto, 0U)
hk: lmx_range_classify(arena, head)
if: hk = c.LMX_DOMAIN_KIND_OP || hk = c.LMX_DOMAIN_KIND_ROLE
    \out: child   # or: return v, in the copier
```
The fix hoists this same check to run on `nested`/`v` ITSELF (not `proto`), before the
`parent = proto` / `inside` test: if `v`'s own child[0] classifies OP or ROLE, `v` is a frame --
keep it by address, terminal, in both `lmx_fresh_child` and `lmx_copy_value`.  A mutant that drops
either new check (leaves the old parent-based recursion as the only path) should go RED on a
selftest that re-enters (or merges) a method carrying at least one OP frame and asserts the
frame's address is unchanged across the re-entry/merge.

## 4. K-OT2: `lmx_walk_data_holder`'s physical-identity test, and the `holder = 0` collision

Confirmed mechanism, per merge-parts-193.md §6(4): `lmx_walk_data_holder` (lmx_walk.lm1 l479-486)
compares a frame-embedded holder VALUE against `f\code` by raw address equality (`holder !=
f\code -> unchanged; else -> f\node`).  T4 would emit that holder as a literal reference to M
(baked in at EMIT time, per §6(2): "holder = M's occurrence ... instead of the unit").  When a
merge result R (native 0, sharing M's OP frames once K-OT1 lands) is what's actually CALLED (CALL
dispatches `lmx_walk_activate(code=R, data=R, ...)`, so the new frame's `f\code = R`), the
embedded holder still literally equals M, never R -- `M != R` is true, so `lmx_walk_data_holder`
returns the holder UNCHANGED (M itself), and the OWN/SET/PUT read or write lands on M's data, not
R's.  Confirmed exactly as described.

### The `holder = 0` sentinel collides with TWO existing null guards, not one

Fable's Q5 ruling (holder 0 = "this activation's data," one node kind, no separate holder-less
form) answers the ticket's own open question, but the CURRENT code treats a null holder as
"nothing here" at BOTH of `lmx_walk_data_holder`'s two call sites, in a way that must be
restructured, not merely extended:
- `lmx_walk_slot` (l450-474, used by OWN/SET/PUT via l458-459): reads `holder:
  lmx_arena_ref_value(code, first)` and, at l456-457, returns 0 (a refusal) IMMEDIATELY if
  `holder = 0` -- BEFORE `lmx_walk_data_holder` is ever called.  A literal `holder = 0` slot in the
  frame never reaches the resolver at all today.
- `lmx_walk_data_holder` itself (l480): `if: f = 0 || holder = 0 || f\code = 0 || f\node = 0 ->
  return: holder` -- a SECOND, independent null guard, which for `holder = 0` returns 0 right back
  (not `f\node`).
- PUT_REF (l1006-1019) repeats the same two-guard pattern independently: `other: lmx_arena_ref_
  value(code, 1U); if: other = 0 -> INVALID` (l1013-1015, before the call), then `other:
  lmx_walk_data_holder(f, other); if: other = 0 || ... -> INVALID` (l1017-1019, after).

So implementing Q5 literally as "holder slot value 0 means f\node" needs THREE edits, not one:
`lmx_walk_slot`'s own pre-check (l456-457) must let `holder = 0` THROUGH to the resolver instead
of refusing early; `lmx_walk_data_holder` itself (l480) must special-case `holder = 0` to return
`f\node` rather than folding it into the same "return holder unchanged" branch as every other
early-out; and PUT_REF's own pre-check (l1013-1015) needs the identical change `lmx_walk_slot`
gets.  Doing only one of the three leaves `holder = 0` silently broken on whichever path was
missed (RED on a targeted selftest, but a real correctness gap if shipped half-done -- this is a
three-site coordinated change, worth calling out explicitly in the commit's own selftest: one row
per site, not one row that only happens to exercise `lmx_walk_slot`).

A genuinely malformed/never-set holder slot (an emission bug, not an intentional sentinel) would,
after this change, ALSO read as `0` and ALSO silently resolve to `f\node` -- the same collision
merge-parts-193.md's own text doesn't flag.  Worth a one-line note for the design (not blocking):
today a null holder is unambiguously a translator bug (frames always name a holder); after this
change it is ambiguous between "T4 intentionally emitted no holder" and "T4 forgot to." Since T4
is the only future emitter of holder-less frames and T4 controls both cases, this is contained --
but a mutant that always emits `holder = 0` (never a real holder reference) should be added
alongside the intentional-sentinel selftest, to make sure the two cases are not silently
conflated in a body that legitimately mixes M-rooted fields (T4's existing form, if it is kept
for anything) with holder-less ones.

## 5. G-call: `lmx_call_prim`'s walked branch reuses `lmx_call0`'s narrow hook

Confirmed exactly as merge-parts-193.md §6(4) describes, with the precise mechanism:
- `lmx_call_prim` (lmx_call.lm1 l136-170) already has the FULLY GENERAL signature needed
  (`arena, code, data, refs, nargs, dest, out`) and already forwards all of it correctly on the
  NATIVE path (`addr != 0`, l148-153: `entry(data, refs, nargs, dest, out)`).
- The WALKED path (`addr = 0`, l154-164) does not use this signature at all: it requires
  `nargs = 0U` outright (`if: lmx_call_walk_fn = 0 || nargs != 0U -> abort`, l156-158), calls
  `walk(arena, code)` (l161) -- `LmxCallWalkFn`'s own type, `fnptr (@: LmxArena arena; @: Lmx
  callable) int` (lmx_call.h.lm1 l39) -- which has NO parameter for `data`, `refs`, or `dest` at
  all, and finally forces the result through `lmx_int_store_known(dest, value)` (l166-168),
  assuming an int destination unconditionally.
- The installed function, `lmx_walk_call0_dispatch` (lmx_walk.lm1 l82-132), matches that narrow
  type exactly: it opens its OWN ephemeral scratch pool (`sa`/`cells`/`scratch`, l100-109) but
  correctly threads the REAL passed-in `arena` into `ctx.arena` (l111) -- so graph data is NOT
  isolated from the caller, only the scratch/temporaries pool is ephemeral (which matches how a
  fresh top-level activation is expected to work) -- then calls `lmx_walk_run(@ctx, callable, 0,
  0U, @wv)` (l114) with `args`/`nargs` hardcoded to nothing, and converts the resulting
  `LmxWalkValue` down to a bare `int` (l122-131) by hand.
- `lmx_walk_activate` (l1436-1471) is ALREADY the general entry point this needs: `(context, code,
  data, args, nargs, dest, result, present)`, and it is exactly what CALL's own native-0 dispatch
  uses internally (per §6's own "Facts": "When native is 0 it calls
  lmx_walk_activate(code, data, refs, n)").  Nothing about it is nullary- or int-only.

### The fix

Do NOT widen `LmxCallWalkFn` itself -- `lmx_call0`'s own two call sites (l108-110, l117-122) both
genuinely need the narrow nullary-int contract (a non-Structure value's "activation," or a
bodiless descriptor's dispatch; neither ever has args or a typed dest) and reusing the same
function pointer type for both would force every existing caller to pass placeholder
args/dest/nargs it doesn't have.  Instead: a second, parallel hook (a new `LmxCallPrimWalkFn` type
and `lmx_call_install_prim_walk`/global, mirroring `lmx_call_install_walk`'s own two-line pattern
at lmx_call.lm1 l67-72) with the FULL shape `(arena, code, data, refs, nargs, dest, out) -> int`,
matching `lmx_call_prim`'s own signature exactly.  `lmx_call_prim`'s `addr = 0` branch (l154-164)
calls THIS hook instead of `lmx_call_walk_fn`.  The installed function is a new sibling of
`lmx_walk_call0_dispatch` (same file, same ephemeral-scratch-but-real-arena shape at l100-113) that
calls `lmx_walk_activate(@ctx, code, data, refs, nargs, dest, &result, &present)` directly instead
of `lmx_walk_run`'s narrower `(ctx, callable, 0, 0U, &wv)`, and returns `lmx_walk_activate`'s own
status verbatim (no int-narrowing: `dest` already carries the right destination cell, typed by the
caller, same as the native path does today).  `lmx_walk_program_bind`/`lmx_walk_roles_open`
(l55-74) install BOTH hooks at their existing two call sites, one line added each.

## 6. Selftests, mutants, commit order

Per §3's own commit table (K1 depends on nothing; K2+T3 and T2 depend on K1; K3+T5 depend on K1
and T4) and this ticket's re-scoping (K-OT1/K-OT2/G-call brought forward, read-only, alongside K1,
so kernel commits are ready once Opus's T4a needs them):

1. **K1** (1a, 1b, 1d; 1c's source-duplicate guard): no dependency, lands first.
   - Selftests: unit_merge_body_pair (a body field matching the model's name lands in the model's
     slot, not appended -- 1a); unit_merge_chain_pair (C's field targets a slot B just appended,
     not the model's own width -- 1b); unit_merge_duplicate_source_refused (the same `(operand,
     field)` twice in the map -- 1c); unit_merge_nested_reparent (a nested own-Structure field of
     the model, read after the merge via the RESULT's own path, then the result merged AGAIN and
     the nested field's identity checked -- proves 1d's fix, since without it the second merge
     would keep the old orphan-parented copy's address, not deep-copy it as the second result's
     own child).
   - Mutants: drop the body-pair map lookup (falls back to append) RED on 1a's row; keep
     `model_slot < model_w` only (no earlier-operand-slot target) RED on 1b's row; drop the
     source-duplicate guard RED on 1c's row; skip the post-fill re-parent pass RED on 1d's row
     (second merge's nested child address unchanged instead of freshly copied).
2. **The flat "merge into" primitive** (§2): can land right after K1, reusing K1's own pair-
   application helper if that factoring is done; no dependency on K-OT1/K-OT2/G-call, and unblocks
   Q26.1's own-field write natively/at the root independently of the callable-merge line.  A first
   selftest is q26's own row (`o\inner: a`, own-Structure-in-Structure, full pairing, no append).
3. **K-OT1**: depends on nothing new (OP frames exist today, independent of T4) -- but has no
   OBSERVABLE selftest until either T4 emits a real frame to re-enter/merge, or a synthetic
   selftest builds a minimal op-frame Structure by hand (two or three role-record children,
   parented under a scratch M) and drives `lmx_fresh`/the copier directly, the way -188's own
   K-OT-adjacent selftests already do for other walker primitives.  Given T4a is Opus's, land
   K-OT1 with a synthetic kernel-only selftest now rather than waiting on T4a's real frames.
4. **K-OT2**: depends on K-OT1 only for its full story (frames must survive a merge/re-entry by
   address before "which data they read" matters) but the holder-resolution change itself can be
   tested synthetically too (a hand-built OWN frame with holder = 0, run under two different
   `f\code` identities, asserting both read/write `f\node` in each case) -- lands with or right
   after K-OT1.
5. **G-call**: independent of K-OT1/K-OT2 (it is about the CALLER's plumbing into
   `lmx_walk_activate`, not about how the CALLEE's own frames resolve their holder) -- can land in
   parallel with K-OT1/K-OT2.  Selftest: a native trampoline-style caller (a hand-built kernel
   selftest playing the caller, not a real translator-emitted trampoline, since T4a has not landed)
   calling `lmx_call_prim` on a walked (`native = 0`) callee that takes one ARG and returns a typed
   (non-int) dest, asserting the value round-trips; mutant: keep the old `lmx_call_walk_fn` narrow
   hook wired to the new call site (nargs != 0U aborts) RED.
6. What lands WITH Opus's T2/T4a, not before: (1e)/(1f)'s FULL "parts, recursively" and "operators
   replace" semantics (K3, per §3's own table: depends on K1 AND T4) -- T2 needs K1's four items
   only (body/earlier-slot/duplicate-source/re-parent), not merge-into or K-OT1/2/G-call; T4a
   (op-trees for method bodies) needs K-OT1 landed so re-entry/merge do not silently corrupt the
   very op-trees it starts emitting, but does not itself need K-OT2 or G-call (nothing calls a
   walked method dynamically until T5).  So the order that keeps every commit's own selftest
   meaningful without a placeholder is: K1 -> merge-into (unblocks q26 independently) -> K-OT1 (so
   T4a's frames are copy/fresh-safe from the moment they exist) -> K-OT2 + G-call (either order,
   both prerequisites of K3/T5, neither exercised for real until then).

Open, for fable: none of Q1/Q2/Q5 are open any more (this ticket's assignment message answers
them).  One new small question worth a one-line ruling before K1's commit: for (1c)'s
source-duplicate guard, is a translator that emits two pairs from the SAME source field a defect
worth a located kernel refusal (this report's proposal), or should the kernel stay silent-trusting
here too (mirroring how it already trusts kind/type without checking them) since T1's own map-
building (`l2_mrs_join`) should structurally never produce one? I recommend the refusal -- cheap,
and every other map-validity case (l99-108) already refuses rather than trusts.
