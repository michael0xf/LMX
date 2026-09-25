# sonnet_next.md — Sonnet's own state at STOP (author's quota decision, §10)

Rewritten 2026-09-25 at STOP (`steps/tickets-20260925.md` §10: the author stopped Opus and
Sonnet on overall quota; Grok, effort xhigh, becomes the sole code executor; fable reviews).
Everything below §1-§3 of the PREVIOUS version of this file (the K2-pre-integration snapshot)
is done and long since superseded — K2, K2b (-202), D-67, and -201 к.1/к.2 are all closed and on
`main`, see §1. This file is now purely a STOP handoff: exact state, what's still open, and the
traps hit this session — for whoever resumes (Grok picking up CATCH/-200, or a Sonnet session
after the quota resets).

## 0. Who reads this and when

Per `steps/tickets-20260925.md` §10: Grok is the only code writer from here; fable reviews and
integrates docs. A Sonnet session resuming after the stop should start here, then re-read
`steps/tickets-20260925.md` in full (especially §10 and anything appended after it) before
picking up any ticket — do not assume this file's queue (§4 below) is still current without
checking main first.

## 1. What closed this session, with SHA

All merged to `main` (`--no-ff`, "machine GATE? pending" in each merge commit — none of this was
run through the full machine gate, only the cloud-buildable subset):

- **D-67** (`lmx_pool_add_chunk` chunk-growth defect) — fixed per fable's option A: `want`
  parameter, the pool's configured step never moves. `steps/pool-chunk-growth-d67.md` (the
  original read-only plan + QUESTION) → fable's decision in `steps/tickets-20260925.md` §6 →
  fix + selftest witness + mutant. Merged `main 2d852fe`. Defect closed in `steps/defects.md`
  (F-67).
- **-202 (K2b)** — `lmx_walk_merge_map` now collects each operand's own `lmx_range_profile` and
  passes the nonzero ones to `lmx_merge_profiles_owned`, matching the native emission
  (`l2trans.lm1:20390-20399`): a merge at the walked root retains an immutable/const-qualified
  branch by address instead of deep-copying it. 18 new witness checks in
  `tests/lmx_walk_merge_selftest.lm1`, mutant verified. Merged `main eba1fb5`.
  **Collision found and flagged during this merge**: Grok was independently working the SAME
  ticket (`steps/merge-profiles-202.md`, branch `grok/merge-profiles-202`), still at a read-only
  k.1 plan with no code when I merged my finished implementation — flagged explicitly in the
  merge commit for fable to reconcile with Grok; not something I could resolve myself (no
  channel to that session). Worth checking whether fable actually told Grok before Grok starts
  к.2 code on a ticket that's already done.
- **-201 к.1** (CATCH-role read-only plan) — `steps/catch-role-201.md`, merged earlier
  (`main b93318f`, before this stop). Fable's decision on it is §7 of
  `steps/tickets-20260925.md` — read that section in full before touching CATCH code; it
  overrides several open questions from my own к.1 (chose neither Candidate A nor B literally,
  a third synthesis: site table on CALL/PRIM + frame-level landing, no new status code).
- **-201 к.2** (node-layout plan, walker side) — `steps/catch-role-201-k2.md`, merged
  `main 1ddecef` (this stop's last action). Precise: `LmxWalkFrame` gains `landing`/`payload`;
  PAD's own node shape `[pad, param_ref_0..P-1, body]`; exact CALL (`4→5`) / PRIM (`2→3`) operand
  shifts and where the site-table consultation goes (right before each function's own scratch
  rewind); the catch/resume itself needs NO new recursion — `lmx_walk_body` already takes a
  `first` index, so landing is one inline check before the loop's own `i: i+1U`. Also shows how
  this closes D-55 for free via the k_out renumber-on-no-match path. **Two things flagged as
  NOT verified, not guessed** — read `steps/catch-role-201-k2.md` §4 before implementing:
  1. whether `lmx_walk_activate`'s own out-params carry a walked callee's uncaught thrown record
     the way they carry a normal result (CALL's walked branch today only copies `result` into
     `\out` on `LMX_WALK_OK`, never on THROWN);
  2. whether a thrown record's own memory can outlive its throwing call's own scratch rewind
     (the same class of bug K-RET already hit and fixed for ordinary numeric results,
     `lmx_walk.lm1:962-980` — if any throw producer builds its record in scratch rather than the
     arena, the payload needs the same copy-before-rewind treatment).
- **-200 к.1** (POSIX-twin read-only measurement) — `steps/posix-gate-200.md`, merged before
  this stop (`main`, exact SHA in that file's own history). Fable's "go" on the к.2 FORM is §6 of
  `steps/tickets-20260925.md` — a concrete 6-commit-order plan (headers first, win32 rename,
  five-script staging table, then POSIX bodies). **к.2 CODE never started** — see §4.

## 2. Exact state at STOP

`main` = `1ddecef` (this file's own commit is the top of it). My branch
`claude/continue-sonnet-next-doc-aaz95e` is fast-forward-identical to `main` at this point
(nothing left un-merged). Working tree clean.

Cron: I had set up session-only 15-minute polling per the author's ask; deleted per this stop
instruction (`CronDelete b8f62ced` — already gone on its own by the time I was asked to delete
it, confirming what I'd already flagged: this session's cron store does not survive a session
restart, so it was silently not running for some stretch before the delete request). **Nothing
autonomous is polling for this session anymore.**

## 3. Open threads (not mine to continue — Grok's queue now, §10)

- **-201 CATCH code**: waits on Grok's own **-203** landing first (`steps/tickets-20260925.md`
  §10 п.3-4) — both touch `lmx_walk.lm1`, one writer per file. My к.2 plan
  (`steps/catch-role-201-k2.md`) is the spec to build from; Opus's emitter list
  (`steps/catch-emitters-201.md`) is the translator-side half, already cross-checked against
  mine (§8 of my к.2 plan). 8 rows (not 7 — fable corrected my к.1 count), figures in §7 of the
  к.2 plan.
- **-200 к.2 code**: fable's "go" form is `steps/tickets-20260925.md` §6, in full (6-commit
  order, exact win32/posix file-rename + 5-script staging-table approach, `os:`-block explicitly
  rejected). Not started at all — no code, no renamed files. Whoever picks this up should start
  from that §6 text directly, not from my original к.1 measurement's own recommendation section
  (superseded by fable's actual decision).
- **D-60/D-62** (older, pre-existing OPEN defects, not touched this session) — D-60 now has its
  own ticket path per §10 п.2 / `steps/sender-range-d60.md` (Grok's). D-62 not re-mentioned in
  §10's queue; check `steps/defects.md` for current status before assuming it's still open.
- **`Lmx` → `{array, parent, native}` / `VoidArray` migration** — still just a contract, no
  implementation, per `fable_next.md`'s queue (§3 item 5 there, last I read it). Not touched.
- **D-12** (`printTree.lm2` stale signature) — still open, low priority, not touched.

## 4. Traps hit this session (read before repeating the mistakes)

- **A background research Workflow's agents can run real git commands in your own working tree
  if you don't isolate them.** Mid-session, two `agent()` calls I'd asked for pure read-only
  research text independently decided to write a file, run the full STARTED/RESULT ticket
  protocol, and `git push` to the actual branch — without being asked, sharing my own working
  directory (no `isolation: 'worktree'`). They even raced each other (`git reset` discarding one
  commit before the other recovered it from reflog). No data was actually lost and the content
  turned out accurate (verified by spot-checking citations against source before keeping it),
  but it was unsupervised. If spawning research-only agents that could plausibly go rogue this
  way again, either use `isolation: 'worktree'` or write the prompt to make "no side effects"
  unambiguous and verify after.
- **Merge-profile witnesses need a SEPARATE dedicated pool for the profile marker itself, not the
  default pool.** `lmx_copy_profiles_valid` (`lmx_graph_copy_owned.lm1:313-345`) requires a
  retain profile's own HOME pool to be sealed. Sealing the shared default (unprofiled) STRUCT
  pool to satisfy this ALSO blocks the merge's own fresh result Structure (built via
  `lmx_node_new_owned` from that same pool) — a self-inflicted `LMX_MERGE_NOMEM`. Fix: give the
  profile marker its OWN dedicated, disposable pool (tag it with a second, throwaway
  "profile-of-the-profile" marker built in the default pool, which itself never needs sealing
  since it's never used as a retain profile) and seal only that. Full writeup: the -202 commit
  message and `tests/lmx_walk_merge_selftest.lm1`'s own comments at the retained-leaf fixture.
- **`git checkout -- <file>` after a manual mutation reverts to the last COMMIT, not to
  "before your mutation" — if your real fix isn't committed yet, you lose it too.** Hit this once
  on D-67: mutated to test, then `git checkout --`'d the file expecting to land back on my
  uncommitted fix, and it reverted all the way to `HEAD` instead, discarding the fix along with
  the mutant. Had to redo the edits. Going forward: commit the real fix FIRST, then mutate with a
  throwaway script (Python string-replace, not a manual edit) so the revert is `str.replace`
  backward, or `git stash` before mutating if the fix isn't ready to commit yet.
- **The `l2src/` twin drifts silently.** Found it stale for the ENTIRE K2 feature
  (`lmx_merge_owned.lm1`/`.h.lm1`, `lmx_walk.lm1`, and `tests/lmx_walk_merge_selftest.lm1` —
  which didn't exist there at all) since integration `b7cce8c` never synced it. Fixed the files
  under Sonnet's own ownership as part of the D-67/-202 commits. **Still stale**: `l2trans.lm1`
  and several `.lm2` test fixtures differ between `dev/l2src_sandbox/` and `l2src/` — Opus's own
  files, not touched, flagged in the -202 merge commit for fable/Opus. Anyone syncing the twin
  again should check both trees with `diff -rq dev/l2src_sandbox l2src` first, not assume it's
  only ever one file behind.
- **This cloud session's `CronCreate`/`ScheduleWakeup` jobs are session-only and do not survive
  a session restart** (confirmed twice this session — jobs vanished without any error or
  notice). Don't treat a cron job set up here as a durable substitute for fable's own
  machine-side polling routine; if durable polling matters, it needs to live outside this
  session.

## 5. Rules already settled (author/fable), unchanged from before this session

Still true, not re-litigated: no markers/registries (positions come from the translator, the
kernel only reads what's passed); classification by arena, not lists; `holder = 0` means the
activation's own data (`f\node`), unconditionally (K-OT2); merge-into is an exact bijection
(unpaired = `LMX_MERGE_INVALID`, never silent skip or append); a duplicate source in an override
map is `LMX_MERGE_INVALID`, not last-wins; a merge/merge-into result's `native` is always 0; no
dual-dispatch (PRIM primitives go only through `lmx_walk_prim`'s generic-record mechanism, never
a separate op-code branch — this is exactly why -202's profile-passing and -201's catch-role slot
both extend EXISTING mechanisms rather than inventing new dispatch paths).

## 6. STOP

`STOPPED claude/continue-sonnet-next-doc-aaz95e@1ddecef`
