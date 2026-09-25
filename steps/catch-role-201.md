# FABLE-SONNET-CATCH-20260925-201, к.1 — read-only CATCH-role plan

Base: `claude/continue-sonnet-next-doc-aaz95e`, no code in this commit. Per
`steps/tickets-20260925.md` §4: plan the walker's CATCH role (PAD + per-site table + landing)
against `lmx_walk.lm1` on the current branch tip, say what the translator (Opus) needs, name the
9 rows this flips, sketch witnesses and mutants. Code lands only after fable's "go".

## 0. What was read

`dev/l2src_sandbox/lmx_walk.lm1` (1960 lines) and `dev/l2src_sandbox/lmx_walk.h.lm1` in full;
`steps/root-walk-blocks-arrays.md` in full (the existing grok_bot sketch, attributed via
`fable_next.md`/`sonnet_next.md`, no in-file byline); `steps/next-phase-195.md` in full (row
counts). No kernel file was edited.

## 1. What the walker has today, exactly (no throw/catch/PAD/landing exists yet)

- **Roles are physical addresses, not a switch on an int.** `lmx_walk_roles_open`
  (`lmx_walk.lm1:49-66`) builds one shared record per role, sized by `LMX_WALK_OP_COUNT`
  (`lmx_walk.h.lm1:260`, currently 28, roles 0-27: `NONE..LENGTH`, see the full table pulled
  during research). Dispatch in `lmx_walk_eval` is a **flat sequential if-chain**
  (`op: lmx_walk_node(f, node)` at `:1118` through the final `return: c.LMX_WALK_INVALID` at
  `:1713`), not a jump table — adding a role means appending one more `if: op = c.LMX_WALK_OP_X`
  arm to that chain, nothing else structural.
- **`LmxWalkFrame` has no parent/caller link** (`lmx_walk.h.lm1:294-314`): nesting is genuine C
  recursion (`lmx_walk_activate`, fresh `LmxWalkFrame frame` at `lmx_walk.lm1:1788` per call),
  not a walked frame chain. All nested activations of one `lmx_walk_run` tree share **one**
  `LmxWalkContext` (arena/scratch/roles/…) — that shared context is the only thing spanning
  frames today; it carries no control-flow state.
- **Status codes**: `LMX_WALK_OK=0` .. `LMX_WALK_NOT_CALLABLE=7`, then `LMX_WALK_THROWN=8`
  additive — an admitted throw rides as `THROWN + k` (`lmx_walk.h.lm1:207-209`, "so throw 1 is
  never LMX_WALK_INVALID; walker errors stay 1..7"). **Nothing anywhere in `lmx_walk.lm1` tests
  `status >= LMX_WALK_THROWN`** — every site (`lmx_walk_body`'s loop condition `:1736`, `IF`
  `:1491-1503`, `WHILE`'s loop `:1504-1524`/`:1519`) treats ANY non-OK status identically: stop
  and propagate. A THROWN status today is indistinguishable at every consumer site from a hard
  walker error. That blanket-stop predicate is exactly what CATCH has to turn into "stop, unless
  a pad here wants it."
- **Two live throw producers today**, both already mapping into `THROWN+k`:
  - `lmx_walk_call`'s native branch: `if: said != 0: status: c.LMX_WALK_THROWN + said` (`:958-960`).
  - `lmx_walk_prim`'s post-loop mapping (`:1074-1082`):
    `LMX_PRIMITIVE_THROW_MERGE → THROWN+1`, `LMX_PRIMITIVE_THROW_IMPLEMENTS → THROWN+2`, else
    non-OK `said → LMX_WALK_PRIMITIVE` (X1, not a throw). This is the existing precedent for
    "map an ABI-level failure code to a walker throw number" — a new declared-`throw:` producer
    would extend the same `if/else` chain with its own `LMX_PRIMITIVE_THROW_*` arm, not invent a
    new mechanism.
- **Scratch is already unwind-safe today, for free.** Every nested CALL/PRIM/`lmx_walk_activate`
  site takes a scratch mark before its work and unconditionally rewinds it on the way out,
  regardless of status (CALL `:901-904`/`:1003-1004`; PRIM `:1043-1046`/`:1087-1088`; activate
  `:1800-1804`/`:1819-1820`). So a THROWN status bubbling up through several C-stack levels
  already leaves scratch correctly unwound at each level before CATCH exists — landing does not
  need to invent its own scratch bookkeeping, only the interception/resume logic.
- **`lmx_walk_data_holder`'s `holder=0` rule** (`:528-544`, K-OT2) is unconditional and already
  covers "this activation's own data" for any new op that needs to read/write own fields (a
  pad's parameter cells, hosted in its enclosing block, read this same way).
- **Template for adding a role end-to-end**: PUT_REF/ELEM/ELEMPUT/LENGTH (roles 24-27,
  `:1248-1281`, `:1603-1640`, `:1641-1704`, `:1705-1712`) are the precedent. Common shape: guard
  on `code\len`, resolve operand(s) via existing generic helpers (`lmx_walk_data_holder`,
  `lmx_walk_array_desc`, recursive `lmx_walk_eval` for value operands), enforce the immutability
  check on writes, `\out: …; return: LMX_WALK_OK` or a status on refusal, one `# Mutant: …`
  comment per arm. **CATCH does not fit this template** — it is structurally an `IF`/`WHILE`
  analog (wraps a nested `lmx_walk_body` call and inspects the resulting status/`f\returned`,
  `:1491-1524`), not a single-shot value op, and it additionally needs a "resume mid-block after
  an inner failure" capability that `lmx_walk_body`'s loop (`:1726-1757`) has no notion of today.
- **Number coordination flag**: a comment directly above ELEM (`lmx_walk.h.lm1:253-254`) says
  "Sonnet MERGE prim takes 28+ (OP_COUNT coord via `lmx_uds` 2026-09-25)". Tracing K2 on main:
  merge landed as an `LmxPrimitive` PRIM record (`lmx_walk_merge_map`/`lmx_walk_merge_into_map`),
  **not** a new `LmxWalkOp` — so it likely did not actually consume an `LMX_WALK_OP_COUNT` slot,
  and `LMX_WALK_OP_COUNT` is still 28 today. Whether PAD needs a genuinely new `LmxWalkOp` role
  (bumping `COUNT` to 29) or can also ride as a PRIM-style record is an open design choice (§3);
  either way, any number PAD does claim needs the same `lmx_uds` coordination this comment
  describes, not a silent pick.

## 2. The existing plan (`steps/root-walk-blocks-arrays.md:46-80`, quoted in full for reference)

The design vocabulary — PAD, per-site table, landing — already exists there, distilled:

1. **PAD step**: skipped when reached on the ordinary linear walk of its block. Holds its own
   parameter cells, **hosted in its enclosing block** (not a separate arena of its own — the
   block Structure that already carries other own-fields carries the pad's params too), and its
   handler body.
2. **Per-site table, `k -> pad`, on the CALL node**: for a given call site, each of the callee's
   throw numbers (declared 1..d, implicit d+g per S1.1) maps to the NEAREST covering pad among
   the enclosing blocks of the same activation, or to nothing (uncaught) — **resolved statically
   by the translator**, one table per CALL, attached by reference. No runtime search through
   enclosing scopes is implied: the translator already knows, at each call site, which pad (if
   any) is nearest, because block nesting is static.
3. **Landing, when a CALL yields `THROWN + k`**: no pad for `k` → stop exactly as today
   (unchanged, uncaught case costs nothing extra); a pad exists → unwind the nested bodies up to
   the pad's block, bind the thrown record's fields to the pad's parameter cells BY POSITION
   (`out` is the thrown record), run the pad's body, then resume with the statement AFTER the pad
   in that block — "non-local control inside one activation, like a `break` that also lands."
4. **Coverage rule**: a pad covers every call in its own block and in blocks nested inside it
   (`if`/`while`/`for`/`---`), never a sibling block; two same-named pads cannot compete at one
   level (stated as a rule in the plan, not tied to any specific translator check yet).
5. Bare `throw:` at the root with no catch involved is explicitly OUT of this ticket's scope
   ("no row needs it yet").

**What the plan leaves open** (confirmed absent from that file; not filled in unilaterally here,
per §3): the exact node shape for PAD, exactly how the per-site table attaches to a CALL node,
and under what condition a block needs its own SEQ node vs reusing `IF(LIT 1, body)`. No mutants,
no `lmx_walk.lm1` line citations, no node-shape spec exist in that source document — it is a
vocabulary/behavior sketch, not an implementation spec. Producing that spec is this ticket.

## 3. Where the plan's "landing" meets the walker's actual control flow — the real design gap

The plan's step 3 ("unwind the nested bodies... up to the pad's block... resume with the step
after the pad") requires something `lmx_walk_body`'s loop does not have today: a way to resume
iteration at an arbitrary point instead of always starting a block from its first statement. Two
sub-problems, kept separate because they have different natural owners:

**(i) How does a THROWN status reach the right pad without a runtime scope search?** Since the
per-site table is resolved statically per call site (§2.2), the natural place to consult it is
at the CALL's own throw site (`lmx_walk_call:958-960`, `lmx_walk_prim:1074-1082`) — but the pad
named by that table may be in an OUTER block than the one directly containing the call (e.g. the
call is inside a nested `if`/`while` inside the pad's own block). A lookup done only at the
throw site cannot by itself "jump" past the intervening `if`/`while`'s own `lmx_walk_body` calls
on the C stack — those still have to return normally (propagating the THROWN status) before
control is back at the level that can resume the pad's block. So the CALL's per-site table
cannot by itself perform the resume; it can only decide WHETHER this throw is destined for a pad
reachable from here, and if so, the enclosing `lmx_walk_body` calls between here and there need
to let it through unmodified — which is exactly what today's blanket "any non-OK status stops
the loop" already does, for free, with no new code. The one thing genuinely missing is step (ii).

**(ii) Where does the resume actually happen?** It has to happen in the `lmx_walk_body` call that
represents the pad's OWN block — that loop must, on seeing a THROWN status from one of its
direct statements, recognize "this k is mine to catch" (rather than just propagating), then
re-enter its own loop starting after the pad instead of returning. `lmx_walk_body`'s loop
(`:1726-1757`) today has no per-block "list of my pads and what they catch" to check against, and
no notion of "resume at index N instead of 0."

## 4. Two candidate resolutions for (ii) — neither applied, for fable/Opus to pick

**Candidate A — the pad list lives on the block node itself, consulted by `lmx_walk_body`.**
Every block that contains at least one PAD carries, alongside its ops, a small side-table `[k,
pad_index]*` built by the translator (this is the "per-site table," but attached to the *block*
that owns the pads rather than duplicated onto every covered CALL). When `lmx_walk_body`'s loop
gets a non-OK status back from evaluating one of its own statements, before propagating it checks
"is `status - LMX_WALK_THROWN` in my own pad table?" — if yes, it binds the payload, runs that
PAD's body (a nested `lmx_walk_body` call over the pad's own op list, same frame `f`, holder=0
per K-OT2), then continues its OWN loop from the statement after the PAD's op index, with status
reset to OK; if no, it propagates exactly as today (zero behavior change for the uncovered case).
This means the "per-site table, k -> pad" from §2 is really "per-*block*, k -> local pad index,"
and a CALL node needs no new operand at all — **CALL's shape and arity are untouched**, so every
existing test/fixture that does not involve throw/catch is provably unaffected by construction
(no new operand to thread through, no arity change to re-verify). The cost: `lmx_walk_body`'s
loop gains one more check per non-OK status (cheap, only taken on the already-rare failure path)
and needs the block node to physically carry that small pad-table alongside its op list — a new
piece of node shape, but confined to blocks that actually declare a `catch:`, not every block.

**Candidate B — the per-site table lives on the CALL node as the plan states literally**, and the
walked-body loop delegates: when a CALL throws `THROWN+k`, it consults its OWN table; if the
table says "caught, land at pad P," the CALL itself performs the unwind-to-P by returning a new,
distinct status (e.g. a would-be `LMX_WALK_CAUGHT` carrying `P` and the payload out-parameter)
that every intermediate `lmx_walk_body`/`IF`/`WHILE` propagates UNCHANGED (same "stop the loop,
return" behavior they already have for any non-OK status — no new per-level check needed there),
until it reaches the `lmx_walk_body` call that IS block P's own body, which is the one call site
taught to recognize `LMX_WALK_CAUGHT` specifically and resume inside itself. This keeps the
per-site table exactly where the prose plan puts it (on CALL) at the cost of CALL's node shape
gaining a new operand (arity change, translator + kernel both touch every CALL emission path,
wider blast radius per §1's own note that arity is currently load-bearing at `code\len - 4U`),
and needs a NEW status code (`LMX_WALK_CAUGHT`) threaded through the same places `THROWN` is
today, plus a way for the one recognizing `lmx_walk_body` call to identify "is P’s block ME?"
(the block's own physical node address, compared against what's inside the caught status --
straightforward, but is itself a new piece of plumbing not present today).

**This ticket's recommendation, not a decision**: Candidate A costs less blast radius (CALL's
node shape and arity are the single most load-bearing, most-tested-against invariant in the
whole walker per §1) and needs no new status code, at the cost of the pad table living on the
block instead of literally on "the CALL node" as the prose plan's wording states. Candidate B
matches the prose plan's literal wording more closely but touches CALL's arity, which every one
of CALL's current callers/emitters would need re-verified against. Recommend A; flagging both
because choosing between them is a real design decision (first instance of non-local control
transfer in this walker), not a "mechanical decoupling" this ticket should pick alone.

## 5. What the translator (Opus) would need, once a candidate is chosen

- Emit blocks as `IF(LIT 1, body)` (already landed, -169) or a new SEQ role, per
  `steps/root-walk-blocks-arrays.md:43-44/78` — **not decided in that file either**; whichever
  candidate above is picked may make this choice for it (Candidate A needs the block node to
  physically carry a pad table, which may be easier on a dedicated SEQ than by extending the
  existing `IF(LIT 1, body)` shape reused for plain blocks).
- Build, per block that declares a `catch:`, the pad's own op-list body and (Candidate A) the
  block's local `k -> pad` table, or (Candidate B) the per-CALL `k -> pad` table for every call
  site the pad covers, resolved by nearest-enclosing-pad-per-activation static analysis (§2.2) —
  this static analysis itself is pure translator work either way.
- Enforce "two same-named pads cannot compete at one level" as a translator-time refusal (stated
  as a rule in the source plan, §2.4, with no refusal text or code site yet — needs its own
  location and located-refusal wording, translator-side).
- Coordinate whichever new role/status number(s) this claims (§1's `lmx_uds` note) before
  landing, the same way MERGE's PRIM numbering was coordinated for K2.

## 6. The 9 rows this ticket flips (steps/next-phase-195.md §4, verbatim figures)

`next-phase-195.md`'s root-pending table (§4) aggregates by CLASS, not by individually-named
fixture, so exact per-row fixture IDs beyond what's named below are not in that file:

| class | rows | example statement (verbatim) | what flips it (verbatim) |
|---|---|---|---|
| throw and catch | **7** | `catch: Oops (int: x)` at the root | "A walker CATCH role (PAD + a per-site k→pad table + landing; steps/root-walk-blocks-arrays.md), then the translator; its own ticket" |
| a loop | **2 of 3** | `while: k < 10` inside "S1 catch rows" | "the catch role" (the 3rd loop row, `while: m != 0 && n < 5` at top level, needs the separate `&&`→IF translator lowering instead — NOT this ticket) |

7 + 2 = 9, confirmed self-consistent against the file's own ticket-order table (`next-phase-195.md:227`: "7 rows (+2 loop rows)") and its running total (`:155-156`: "9 + 10 + 7 = 26 rows ride on
three kernel tickets" — the 7 throw/catch rows are the ones counted into that 26; the loop rows
are additive on top, matching "+2" exactly).

From `steps/root-walk-blocks-arrays.md:32-41`, the individually-named fixtures behind the "7"
figure (S1's family, cross-referenced against `next-phase-195.md`'s class count rather than
asserted independently):

| row | what it needs, per the source plan |
|---|---|
| `unit_s1_catch_declared_vs_merge` | catch in both blocks (Oops and merge) |
| `unit_s1_catch_declared_vs_merge_ok` | catch in both blocks |
| `unit_s1_catch_sibling` | catch in a block and at the root |
| `unit_s1_catch_rethrow` | catch in a block and at the root, `*` |
| `unit_s1_catch_nested_while` | a loop, catch in the block, `*` |
| `unit_s1_catch_publish` | catch at the root body itself (root-pending "throw and catch" since commit 3) |

That is 6 explicitly named rows against a stated class count of 7 — the 7th is not named in
either source file read for this ticket; worth confirming against `next-phase-195.md`'s own
Section 3 (`translates`/K5 rows) or with fable before RESULT of the coding ticket, not asserted
here.

## 7. Witnesses and mutants (sketch, per `steps/current.md`'s "a witness cannot be silent" rule)

Every witness must have a positive, non-zero, non-silent observable (`steps/current.md`
2026-09-24 rule) — none of these may rely on a bare `return: 0` reading as success:

- **Basic catch fires**: a pad whose body does `return: 7` (or similar nonzero Entry) when its
  covered call throws; inverted check first (comment out the throw or the pad match) must go RED
  before the row is registered GREEN.
- **Uncaught propagates unchanged**: a throw with NO covering pad must still stop the walk
  exactly as today (same status, same abort behavior) — this is the regression guard that proves
  the "no pad → unchanged" half of landing did not silently change behavior for existing
  throwing fixtures (`unit_s1_merge_uncaught` and friends, already passing today via the existing
  `THROWN+1`/`THROWN+2` mapping in `lmx_walk_prim`, §1).
- **Sibling block not covered**: a pad in a sibling block must NOT catch a throw in another
  block at the same level (`unit_s1_catch_sibling`) — a positive witness that the OTHER
  (non-matching) pad's body never runs, e.g. by having it set an out-value that the true
  catching pad would overwrite, and asserting the final value came from the right one.
- **Resume-after-pad, not restart-of-block**: a statement placed after the pad in its block must
  run exactly once post-landing, and statements BEFORE the pad in that same block must not
  re-run — needs a counter/accumulator witness, not just "did the pad body run."
- **Nested unwind**: `unit_s1_catch_nested_while` — a throw from inside a `while` nested in the
  pad's block must still land, proving the unwind crosses at least one level of C-stack
  recursion (`lmx_walk_body` called from `WHILE`'s own loop, `:1504-1524`) correctly, using the
  scratch-rewind-is-already-safe fact from §1 rather than reinventing it.
- **Rethrow**: `unit_s1_catch_rethrow` — a pad body that itself throws must propagate to an OUTER
  pad (or uncaught), not be caught by itself or re-triggered infinitely.
- **Root-body-as-block**: `unit_s1_catch_publish` — the unit's own root body must be treated as
  just another block-with-pads (§2.3's "the root body is a block with pads"), not a special case
  in the walker — the witness here is specifically that NO new root-only code path is needed;
  reusing the same block/pad machinery at the root is itself the thing under test.

Candidate mutants (Candidate A shape, adjust if B is chosen): flip the pad-table lookup to always
report "not found" (must send every currently-caught row RED, proving the lookup is load-bearing);
flip the resume index to always restart the block from 0 (must make the "resume-after-pad, not
restart" witness RED); flip the payload-binding to bind by NAME instead of the specified
BY-POSITION order (§2.3) when a pad has >1 parameter (needs a 2+-parameter witness to catch this
at all — not yet in the 6 named rows above, worth adding one).

## 8. Not in scope here

- Bare root `throw:` with no catch (explicitly deferred by the source plan itself).
- The 3rd loop row (needs `&&`→IF lowering, a different translator-only ticket).
- D-09 ("library/throw-channel ABI", OPEN, "not re-measured", sequenced after T4 in
  `next-phase-195.md:196`) and D-55 (`unit_s1_merge_uncaught_entry`, a kernel primitive's failure
  surfacing as `LMX_WALK_PRIMITIVE`/X1 instead of `THROWN+k`, `next-phase-195.md:126-127`) are
  adjacent, already-tracked defects, not folded into this plan.

## 9. Open questions for fable (not blocking -- continuing other tickets per cloud-protocol.md §5)

1. Candidate A vs Candidate B (§4) — which node-shape approach to build the coding ticket on.
2. Whether PAD needs a genuine new `LmxWalkOp` (`LMX_WALK_OP_COUNT` 28→29) or can ride as a
   PRIM-style record the way merge (K2) did — affects the `lmx_uds` number-coordination step.
3. The 7th throw/catch fixture name (§6) — only 6 are named in the source plan against a stated
   class count of 7.
