# FABLE-SONNET-CATCH-20260925-201, к.2 — node-layout plan (walker side)

Plan only, per the author's stop (`steps/tickets-20260925.md` §10): no code in this commit. Base:
`origin/main` at the point this was written (`lmx_walk.lm1`/`lmx_walk.h.lm1` line numbers below
confirmed unchanged from к.1's read against current main — `LMX_WALK_OP_COUNT` still 28,
`lmx_walk_call`/`lmx_walk_prim`/`lmx_walk_body` at the same lines). Builds directly on fable's §7
decision (`steps/tickets-20260925.md`) and Opus's emitter list (`steps/catch-emitters-201.md`).
Code lands after this plan, on Grok's queue (§10 п.4) once `-203` (also touching `lmx_walk.lm1`)
is landed.

## 0. What fable already decided (§7, restated precisely, not re-litigated here)

- Per-site table, on CALL/PRIM at a **fixed position**, not the tail: `[call, code, data, rtype,
  catch, args…]`, `[prim, rec, catch, ops…]`. `catch = 0` at a site no pad covers.
- Landing via a **frame-level reference**, no new status code: `f\landing`/`f\payload`.
- PAD is a **new `LmxWalkOp` role**, `LMX_WALK_OP_PAD = 28`, `LMX_WALK_OP_COUNT` 28→29 (fable
  assigned this number directly in §7; no further coordination needed).
- Blocks stay `IF(LIT 1, body)`; no SEQ role. "Block-owner" = the body `lmx_walk_body` is
  currently iterating; `pad\parent` is exactly that body.
- Scope: numeric + Structure-reference payload only; no `break`/`continue`-in-pad; no bare root
  `throw:` without catch.

## 1. `LmxWalkFrame` — two new fields

`lmx_walk.h.lm1:294-314`. Add after `result` (last field today):

```c
struct: LmxWalkFrame
    ...(unchanged: context, arena, roles, code, node, args, nargs, dest, returned, valued, result)
    @: void landing      # 0 = no pending catch; a PAD node's address once a covered throw hits
    @: void payload       # the thrown record, valid only while landing != 0
end: LmxWalkFrame
```

No change needed to `lmx_walk_frame_open` (`lmx_walk.lm1:1759-1768`): it already
`memset`s the whole frame to 0 before setting specific fields, so `landing`/`payload` start at 0
for free, exactly like `dest`/`returned`/`valued`/`result` do today.

## 2. PAD's own node shape

Per fable: "точную раскладку предложи; ссылки прежде чисел; количество параметров — из раскладки,
не отдельный маркер." Proposed:

```
[pad, param_ref_0, param_ref_1, ..., param_ref_(P-1), body]
```

- Child 0: auto role marker (`LMX_WALK_OP_PAD`), same convention as every other frame node.
- Children 1..P: **references**, one per pad parameter, each pointing directly at the CELL
  (within the enclosing block's own data, holder 0 — `f\node` per K-OT2) that parameter binds
  to. Not indices: a reference is stored via the same `lmx_arena_ref_store` mechanism used
  everywhere else a slot is addressed (matches "references before numbers").
- Child P+1 (last): a reference to the handler body Structure, walked via `lmx_walk_body` exactly
  like IF/WHILE already walk their own referenced body (no new body-walking mechanism).
- **Parameter count `P` = `pad\len - 2`** (total children, minus the auto role slot, minus the
  body reference) — reading the layout itself, no separate count marker, per fable's instruction.
- `pad\parent` **must** be set by the translator to the enclosing block Structure, the same
  convention every other nested Structure already follows (selftests building nested Structures
  by hand already have to do this — a known, already-documented pitfall, `sonnet_next.md` §5's
  "`lmx_walk_plain` requires a nonzero `parent`" note is the same family of requirement). This is
  the field the catch-match test reads (§4 below): `f\landing\parent = body`.

## 3. CALL / PRIM: the `catch` operand and the site-table format

Both node shapes gain one fixed-position child, per fable (§7.2), matching
`steps/catch-emitters-201.md`'s table exactly:

- CALL: `code\len < 4U` refusal (`lmx_walk_call:880-881`) becomes `< 5U`; `n: code\len - 4U`
  (`:888`) becomes `code\len - 5U`; the args loop's `i + 4U` (`:936`) becomes `i + 5U`; **new**:
  `catch_ref: lmx_arena_ref_value(code, 4U)` read once, before the args loop (cheap, always
  read, since args now start one slot later regardless of whether `catch_ref` is 0).
- PRIM: `code\len < 2` refusal (`lmx_walk_prim:1022`) becomes `< 3`; `n: code\len - 2U` (`:1042`)
  becomes `code\len - 3U`; the args loop's `i + 2U` (`:1061`) becomes `i + 3U`; **new**:
  `catch_ref: lmx_arena_ref_value(code, 2U)` read once, before the args loop.

**Site table format** (fable §7.1): a plain Structure of triples `(k_in, pad, k_out)`, one triple
per covered `k`. This is the SAME encoding convention K2's merge already uses for pair maps
(`lmx_walk_merge_pairs_decode`, `lmx_merge_owned.h.lm1:87` area — 3 direct `size_t`-shaped
children per row: there `model_slot, operand, field`; here `k_in, pad, k_out`), so the decode
helper should mirror `lmx_walk_merge_pairs_decode`'s exact shape, not invent a new one:

```
fn: lmx_walk_catch_table_decode (@: LmxArena arena; @: Lmx table_s;
                                   @@@: LmxCatchRow out_rows; @: size_t out_count) int
```

producing an array of `{size_t k_in; @: void pad; size_t k_out;}` rows (a new small struct,
`LmxCatchRow`, same shape-family as `LmxMergePair`), freed the same way
(`lmx_walk_merge_pairs_free`'s twin, `lmx_walk_catch_table_free`). `k_in`/`k_out` are `size_t`
(the throw-number space, S1.1: declared 1..d, implicit d+g); `pad` is 0 for "not caught here,
just renumber."

**Decode cost**: only paid when `catch_ref != 0` **and** the call/prim actually throws — gate
the decode on `if: catch_ref != 0 && status >= c.LMX_WALK_THROWN` (see §4), never on the
ordinary success path. The overwhelming majority of call/prim sites have `catch_ref = 0`
(uncovered) and pay nothing beyond reading one already-fetched-as-part-of-the-shift operand.

## 4. Consulting the table: exact insertion points

**CALL** (`lmx_walk_call`): both branches (native `addr != 0`, walked `addr = 0`) already
converge before the scratch rewind. Insert the table consultation **between the end of the
`else:` block (`:1001`, walked branch) and the scratch rewind (`:1003`)** — i.e. one shared
block covering whichever branch ran:

```
if: status >= c.LMX_WALK_THROWN && catch_ref != 0
    (decode catch_ref via lmx_walk_catch_table_decode, scan for row.k_in = status - c.LMX_WALK_THROWN)
    if: row found && row.pad != 0
        f\landing: row.pad
        if: addr != 0
            f\payload: \out          # native: entry() already wrote the thrown record into *out
        else:
            f\payload: (cast: (@: void) result)   # walked: see the open question below
        ---
        # status returned AS-IS (still THROWN + k_in) -- lmx_walk_body reads f\landing, not
        # a new status code, per fable's "no new status" decision.
    else:
        if: row found && row.pad = 0
            status: c.LMX_WALK_THROWN + row.k_out   # renumber for further propagation (D-55, §6)
        ---
        # row NOT found (this site's table doesn't name this k at all): status unchanged,
        # propagates exactly as an uncaught throw does today.
    ---
    (free the decoded rows)
---
```

**PRIM** (`lmx_walk_prim`): same shape, inserted **between the `said`→`status` mapping block
(`:1071-1085`) and the scratch rewind (`:1087`)**. `f\payload: \out` unconditionally here (PRIM
has only one dispatch path, `record\fn(..., out)` already writes the thrown record into `*out`
on any `said != PRIMITIVE_OK`, exactly like CALL's native branch).

**Open question, not resolved in this plan (flagging honestly rather than guessing):** for
CALL's **walked** branch, does `lmx_walk_activate`'s own `result`/`present` out-params actually
carry a callee's own uncaught thrown record the same way they carry a normal return value
(`:985`, `:987-999` only copies `result` into `\out` when `status = LMX_WALK_OK`, never on a
THROWN status)? If yes, `f\payload: (cast: (@: void) result)` above is correct. If
`lmx_walk_activate` does NOT populate `result` on a THROWN return, the payload needs sourcing
from wherever `lmx_walk_activate` actually does put it (its own out-param contract needs a
one-function read before landing on this). **Verify `lmx_walk_activate`'s THROWN contract before
implementing this half.**

**Second open question, also flagged rather than guessed:** does a thrown record's own memory
survive the throwing call's own scratch rewind (CALL `:1003`, PRIM `:1087`)? K-RET already hit
this exact class of bug for ordinary numeric results (`:962-980`'s comment: a second call
reusing/overwriting an unread earlier result) and fixed it by copying the VALUE out before the
rewind. If any throw producer (today: `lmx_walk_merge_map`'s `THROW_MERGE`/an admission's
`THROW_IMPLEMENTS`; later: a user `throw:` primitive) can build its thrown record in SCRATCH
rather than the arena, `f\payload` would dangle after the rewind runs, and the payload needs the
same copy-before-rewind treatment K-RET got. **Check each throw producer's own allocation before
landing** — not verified here.

## 5. The catch itself: inside `lmx_walk_body`, one loop, no new recursion for the resume

`lmx_walk_body` (`lmx_walk.lm1:1726-1757`) **already takes a `first` index** — the resume
mechanism this ticket needs already exists structurally; it does not need a new primitive, only
a caller that sets `i` mid-loop instead of always starting a fresh call at `first`.

Insert, right after the existing `status: lmx_walk_eval(f, child, step_dest, @ dropped)`
(`:1747`) and its "activation value" bookkeeping (`:1748-1753`), a new check, **before** the
loop's own `i: i + 1U` (`:1755`):

```
if: status != c.LMX_WALK_OK && f\landing != 0 && f\landing\parent = body
    # THIS body owns the pad the throw landed on (O(1), by address -- fable §7.1's
    # "block-owner" test). Bind, run the pad's own body, clear, and resume in place --
    # NOT a recursive re-entry into lmx_walk_body, just adjusting this same loop's `i`.
    (bind f\payload's fields, by position, into the pad's own P parameter cells --
     reuse the standard holder=0 typed-write path PUT_REF's value-store already uses,
     lmx_walk.lm1:1248-1281; a Structure-typed parameter binds by reference, a type
     mismatch is the `implements` path per fable §7.1's "несоответствие типа")
    status: lmx_walk_body(f, (cast: (@: Lmx) f\landing), 0U)   # runs the pad's own handler body
    (scan body's own children for the index j where lmx_arena_ref_value(body, j) = f\landing;
     this is a plain linear scan, only ever run on the landing path -- set i: j)
    f\landing: 0
    f\payload: 0
    if: status = c.LMX_WALK_OK
        status: c.LMX_WALK_OK   # explicit: the throw that got here is fully absorbed
    ---
---
```

Then the loop's existing `i: i + 1U` runs as normal, landing on `pad_index + 1` — resuming with
the statement **after** the pad, exactly as fable specifies ("продолжает свой цикл со statement
после PAD"). No other change to `lmx_walk_body`'s loop condition or structure: a throw whose
`f\landing` is 0 (a hard walker error) or belongs to an OUTER block (`f\landing\parent != body`)
falls through unchanged — the `while` condition (`status = OK && ...`) already stops the loop and
returns `status`, propagating to whichever CALLER of `lmx_walk_body` is next up the C stack
(IF's own arm, WHILE's own loop, or an outer `lmx_walk_body` for the enclosing block) with **zero
new code** at any of those sites — they already do "stop and return" for any non-OK status today.

**"Own handler excluded"** (fable §7.1: a throw from inside a pad's own handler body must not be
caught by that same pad): this needs no runtime check at all. It falls out of the STATIC site
tables: the CALL/PRIM sites inside a pad's handler body are translator-emitted with their own
`catch` tables pointing at whatever pad covers the HANDLER's own enclosing scope (the pad
covering the pad, if any) — never at the pad whose body they are inside. The walker doesn't know
or need to know this rule; it is purely a translator-side static-resolution property (§7.1: "the
translator resolves it statically... the nearest covering pad").

**PAD's own dispatch arm** in `lmx_walk_eval`'s if-chain (append after LENGTH's arm, `:1712`,
before the terminal `return: c.LMX_WALK_INVALID` at `:1713`): on the ORDINARY linear pass (not
via the landing branch above, which never calls `lmx_walk_eval` on the pad node itself — it
calls `lmx_walk_body` directly on it), a PAD reached by `lmx_walk_body`'s normal per-statement
loop must be a pure no-op: `return: c.LMX_WALK_OK` with `\out: 0`, no side effects — "skipped
when reached in order" (fable §7.3 / the source plan §2). **Also**: `lmx_walk_body`'s
"activation value" exclusion list (`:1750`, the `step_op != SET && ... != WHILE` chain) needs
`&& step_op != c.LMX_WALK_OP_PAD` appended — a skipped pad must not overwrite `f\result`/
`f\valued`, the same reason IF/WHILE/SET are already excluded there.

## 6. D-55, closed for free by the renumber path

Fable §7.1: "Это же закрывает D-55." `unit_s1_merge_uncaught_entry` currently gets
`LMX_WALK_PRIMITIVE` (X1) instead of a caller-numbered `THROWN+k` for an uncaught merge failure
(`steps/next-phase-195.md:126-127`, D-55's own entry). With the site table in place, the merge
PRIM's own site carries a row `(k_in=1, pad=0, k_out=d_caller+1)` even when nothing catches it
locally: §4's "row found && row.pad = 0" branch renumbers `THROWN+1` (the fixed, translator-wide
MERGE code) to `THROWN + d_caller+1` (the CALLING activation's own throw numbering, S1.1: d
declared + this implicit slot) — so an outer catch further up, written in the CALLER's own
throw-name numbering, can match it. No separate fix needed once §4/§5 land; the witness is
`unit_s1_merge_uncaught_entry` flipping from X1 to a properly-numbered THROWN status (fable §7.5:
"Thrown 1 / Stopped").

## 7. The 8 rows and their witnesses (fable §7.6, restated with the exact figures)

`needle "throw and catch"` on main today is **8**, not 7 (fable corrected my к.1 count):
`unit_s1_catch_declared_vs_merge`, `_declared_vs_merge_ok`, `_t2`, `_sibling`, `_rethrow`,
`_nested_while`, `_publish`, `_implements`. The "2 loop rows" from `next-phase-195.md` §4 are the
`while` loops INSIDE `_nested_while`/`_t2` — no separate rows exist for them. `unit_s1_catch_user_break`
is its own class ("break and continue"), explicitly out of this ticket.

Entry facts (native rows of the same fixtures, fable §7.6): `_t2` = 103, `_sibling` = 3,
`_rethrow` = 1011, `_nested_while` = 122, `_publish` = 7, `_declared_vs_merge` = 27 (with
`mergefail` 1) / 8 (without), `_implements` = 42.

Witnesses per fable §7.5, sketched (mutants alongside each, per the "witness cannot be silent"
rule, `steps/current.md`):

- **Two-parameter pad, positional binding** — mutant: bind by name or reversed order → RED.
  Needed because none of the 8 named rows above is independently confirmed to exercise a
  2+-parameter pad in this plan; worth a dedicated small fixture alongside the 8.
- **k_out renumbering across a walked-method boundary** — a walked method inside a walked root
  whose OWN implicit throw gets renumbered `d_callee+g → d_caller+g` at the call site; mutant:
  skip the renumber → RED (catches at the wrong number, or not at all).
- **D-55**: `unit_s1_merge_uncaught_entry` — Entry becomes `Thrown 1` where it used to be
  `Stopped` (X1); mutant: revert the renumber-on-no-match branch → RED (X1 again).
- The 8 rows themselves, run through `python tools/build_l2src.py --only lmx_walk` in the cloud
  for compile+kernel-selftest coverage; eternal-runs facts (the harness Entry/Says numbers above)
  are machine-gate only, per fable §7.5.

## 8. Emitter change (Opus's own half, already listed — not this file's job to plan further)

`steps/catch-emitters-201.md` already names the six `l2_rw_*` sites and the exact operand-base
shift for each, matching §3 above one-for-one (CALL 4→5, PRIM 2→3 uniformly). No new information
to add here; Opus's list and this plan describe the same six/two node shapes from the two sides
of the same contract, cross-checked and consistent.

## 9. Not in this plan (fable §7.5's scope line, restated)

Char/text payload (S1.5); `break`/`continue` inside a pad (own class); bare root `throw:` with no
catch. `LmxCatchRow`/`lmx_walk_catch_table_decode`/`_free` are new small struct + two functions,
same shape-family as `LmxMergePair`/`lmx_walk_merge_pairs_decode`/`_free` — not a new mechanism
under the no-special-case doctrine, a second instance of an already-accepted one (K2's own pair
decode, `steps/tickets-20260925.md` never objected to that shape, and fable's §7.1 explicitly
says the site table is "как в... нативном понижении").
