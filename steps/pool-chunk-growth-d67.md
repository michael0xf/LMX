# A one-off large growth permanently inflates a shared pool's chunk size (D-67)

D-67 (Sonnet; base origin/main 83c6820 merged into `claude/continue-sonnet-next-doc-aaz95e`,
cloud session). Per `steps/tickets-20260925.md` §5, D-67 is a "fix now" defect ticket with
selftest + mutant, verifiable in-cloud (`python tools/build_l2src.py --only lmx_pool` -- lmx_pool
does not pull `<windows.h>`, confirmed GREEN baseline including `selftest:lmx_pool_selftest ran,
exit 0`). This report starts as that read-only measurement and ends in a QUESTION instead of a
commit that touches `lmx_pool.lm1`: §4 below found the pool's own header already documents the
behavior D-67 calls a defect as a deliberate trade-off, two days before D-67 was filed. Per
`steps/tickets-20260925.md` §5 ("Если правка не мелкая — QUESTION") and the project's own
no-special-case doctrine ("Пробел контракта → вопрос автору, не заплатка"), a change that reverses
documented, reasoned intent is not the "мелкая правка" this ticket expected -- it is asked below,
not applied.

## 1. Where D-67 lives

`steps/defects.md` D-67 (2026-09-26, Sonnet -192 к.2, OPEN, explicitly deferred by fable to its
own ticket): `lmx_pool_add_chunk` (`dev/l2src_sandbox/lmx_pool.lm1:108`,
`bytes: pool\chunk_capacity * pool\stride`) grows LATER chunks of a shared pool by the pool's
`chunk_capacity` fixed at first allocation, not by the caller's request for this specific growth
-- an oversized chunk when different-size requests share one pool.

## 2. Exact mechanism (`dev/l2src_sandbox/lmx_pool.lm1`)

`LmxPool\chunk_capacity` is a single pool-wide scalar. Three places touch it:

- `lmx_pool_open_profiled` (`:200`) sets it once, at pool creation, to the caller's
  `chunk_capacity` argument -- the pool's normal per-chunk step.
- `lmx_pool_add_chunk` (`:108`) always sizes every NEW chunk at the CURRENT
  `pool\chunk_capacity * pool\stride` (`calloc(pool\chunk_capacity, pool\stride)`, `:109`). It
  takes no per-call size; it only ever reads the pool's one stored step.
- `lmx_pool_take_n` (`:261-329`), the only caller that grows a pool on demand, raises
  `pool\chunk_capacity` BEFORE calling `lmx_pool_add_chunk` when the request is wider than the
  step (`:318-320`: `old_capacity: pool\chunk_capacity` / `if: count > pool\chunk_capacity` /
  `pool\chunk_capacity: count`), restoring `old_capacity` only on allocation FAILURE (`:322-324`).
  On success the raised value is never lowered back.

So a raise is permanent: once one caller's request is wider than the pool's step, every later
chunk of that SAME pool -- however small the request that triggers it -- is allocated at the
raised width, because `lmx_pool_add_chunk` has no notion of "this chunk's own size" separate from
"the pool's steady-state step."

## 3. Confirmed shared-pool scenario

`lmx_scratch.lm1` is exactly the shared-pool caller the D-67 entry describes: one `LmxPool` of
word-sized cells (`stride = c.sizeof(@: void)`, opened with a fixed `chunk_cells` step,
`lmx_scratch_open:15`) backs EVERY `lmx_scratch_take` request in one arena, whatever each
request's own size. `lmx_scratch_take`'s cold path (`:77-85`) calls
`lmx_pool_take_n(s\arena, s\cells, cells)` with the CALLER's own cell count -- so a 256-cell
interned-char-table request and an unrelated 8-cell `out` request, if they land in the same
scratch pool, go through the same `pool\chunk_capacity` raise-and-never-lower path. Whichever
request is served first and is wider than the configured step permanently sets the floor for
every later chunk this pool ever allocates, including requests that arrive after the wide one is
long done with its cells.

This matches the D-67 wording precisely ("интернированная char-таблица (256 ячеек) первой claims
пул... любой позже растущий в том же пуле запрос... получает лишний... чанк"). It is a
memory-efficiency defect (an oversized but otherwise valid chunk), not a correctness one: nothing
reads past what it is given, and `lmx_chunk_room`/`lmx_chunk_cells` still account the true
capacity and usage of the resulting chunk correctly.

## 4. The pool's OWN header already documents this as intentional

`dev/l2src_sandbox/lmx_pool.h.lm1:42-54` (the `lmx_pool_take_n` doc-comment), unchanged since
commit `d193093` ("-188: revise к.3 plan for Q28/Q29", 2026-09-24 -- two days BEFORE D-67 was
measured on 2026-09-26), reads in full:

> `` `count` consecutive cells of one array, in one chunk.  The array grows when the
> last chunk cannot seat them all, and growth ADDS a chunk (never reallocates), so an
> address handed out earlier never moves.  A request larger than the array's own
> chunk makes that one chunk that big -- AND RAISES THE POOL'S GROWTH STEP: the
> capacity a chunk is allocated at is the pool's, so after one successful oversized
> request every LATER chunk is allocated at that size too, for the array's lifetime
> (measured: a step of 8 climbed to 36 through SUCCESSFUL requests, not through
> failures).  A FAILED growth leaves the step untouched -- it is restored -- so a
> refusal cannot poison later, smaller requests.  The cost is memory on a reused
> array whose frames differ in size; the gain is that a big frame is not grown
> twice. ``

This is the EXACT mechanism §2-§3 trace (`lmx_pool_take_n:318-324` raising `pool\chunk_capacity`
on a successful oversized request, never lowering it), described here as a considered trade-off
with a named benefit ("a big frame is not grown twice"), not an oversight. D-67's own framing
("растит ПОЗДНИЕ чанки общего пула по `chunk_capacity` ПУЛА... а не по запросу ВЫЗЫВАЮЩЕГО") is
the same fact read as a cost with no offsetting benefit stated.

Both readings are correct for DIFFERENT usage shapes of the SAME shared mechanism, because
`lmx_pool_add_chunk`/`take_n` cannot see which shape a given `LmxPool` is being used as:

- **A pool dedicated to one logical growing collection** (the header's own scenario: one array
  whose own requests climb 8→36 as it grows) benefits from the remembered step exactly as
  documented: fewer, larger chunks over that one collection's lifetime instead of one add_chunk
  call per growth.
- **A pool SHARED as a general-purpose bump allocator across many logically UNRELATED requests**
  (§3's confirmed case: `lmx_scratch`, one pool backing every `lmx_scratch_take` call in an
  arena) turns the same remembered step into pure waste for every later request that has nothing
  to do with whichever request happened to be widest so far.

`lmx_pool_take_n` cannot distinguish the two callers -- both call the identical function on an
`LmxPool*` with no marker for "this pool is dedicated" vs "this pool is shared." So a fix that
only reads §2-§3 (stop remembering the raise) would silently remove the documented benefit for
the FIRST shape while fixing the SECOND -- which is a real behavior change with a real cost on
one side, not a bug-with-no-downside. That is the "правка не мелкая" this ticket already
anticipates.

## 5. Three candidate resolutions (none applied -- see §7)

### Option A -- decouple "this chunk's size" from "the pool's step"

Decouple "how big this one new chunk must be" from "the pool's configured step," instead of
mutating the pool-wide step to remember a one-off request:

- Give `lmx_pool_add_chunk` a `size_t: want` parameter: allocate this chunk at
  `(want > pool\chunk_capacity) ? want : pool\chunk_capacity` cells, WITHOUT writing
  `pool\chunk_capacity` at all. The pool's configured step stays exactly what
  `lmx_pool_open_profiled`/`lmx_pool_make_profiled` set it to, for every chunk after this one.
- `lmx_pool_take_n`'s growth path (`:303-326`) passes its own `count` as `want` and drops the
  save/restore of `pool\chunk_capacity` entirely (`:318-320`, `:323` become unnecessary -- the
  comment at `:304-317` documenting the old failure-path bug also becomes obsolete and should be
  replaced, not left stale).
- The two unconditional first-chunk callers (`lmx_pool_open_profiled:208`,
  `lmx_pool_take_n:283`) pass `pool\chunk_capacity` itself as `want` (i.e. "no override": the
  first chunk is always exactly the configured step, as today).
- `lmx_pool_make_profiled` and `lmx_pool_over` build their single chunk directly (not through
  `lmx_pool_add_chunk`) and are unaffected.

Net effect: a wide one-off request still gets a chunk big enough to seat it (no behavior change
for that caller), but the pool's step for every UNRELATED later growth stays at its configured
size instead of being inflated by whichever request happened to be widest so far. This is a
general per-call sizing parameter, not a name/type/site special case, so it does not need an
exception carve-out under the no-special-cases doctrine.

**Cost:** removes the §4-documented benefit for a pool genuinely dedicated to one growing
collection (a `count` climbing 8→36 across that collection's own successive growths would, under
Option A, add a chunk at each step's own size instead of reusing headroom from the previous
raise -- more `lmx_pool_add_chunk` calls over that collection's lifetime, each with its own
`LmxChunk`/`LmxArenaBlock` bookkeeping, in exchange for not over-allocating on unrelated shared
requests). Whether any LIVE caller actually relies on the climbing-step benefit today is not
measured here (see §7 Q2).

### Option B -- this is not a defect; close D-67 as intended behavior

The header comment (§4) already states the trade-off and names its cost ("memory on a reused
array whose frames differ in size") as accepted. Under this reading, D-67 is the SAME fact the
header already prices in, re-discovered from a different caller's vantage point
(`lmx_scratch`'s interned char table vs `out`) without weighing the documented benefit. Closing
D-67 as working-as-intended would need the author/fable to confirm that a shared bump pool
paying this memory cost is acceptable for `lmx_scratch`'s specific usage (arena-lifetime scratch
cells, not long-lived storage -- see `lmx_scratch.h.lm1` if the cost is bounded by turn/arena
lifetime rather than accumulating without bound).

### Option C -- keep the pool-level contract, change the caller instead

If the climbing-step benefit (Option B) is worth keeping for genuinely-dedicated pools, but
`lmx_scratch`'s SHARING of one such pool across unrelated request sizes is itself the actual
design mismatch, the fix could move to `lmx_scratch.lm1`: give it more than one backing `LmxPool`
(e.g. size-classed sub-pools, or a dedicated small pool for the common small/hot requests and a
separate one for rare large ones) so a single wide request no longer shares a step with unrelated
small ones. This leaves `lmx_pool.lm1`'s documented contract untouched but is a larger, more
structural change to `lmx_scratch` (which today deliberately treats its ONE pool as a single
growing bump allocator with a warm/cold path, `lmx_scratch.lm1:26-85`) than Option A's local
decoupling.

### Touch list if Option A is chosen

- `dev/l2src_sandbox/lmx_pool.lm1`: `lmx_pool_add_chunk` signature + body (`:84-186`),
  `lmx_pool_open_profiled` call site (`:208`), `lmx_pool_take_n` call sites (`:283`, `:322`) and
  the now-obsolete comment (`:304-317`).
- `dev/l2src_sandbox/lmx_pool.h.lm1`: the declaration.
- `l2src/` twin (`opus_next.md` -198: exact copy of the sandbox) needs the same edit once landed,
  per the twin's own contract.
- New selftest row(s) in `lmx_pool_selftest.lm1`: open a pool with a small step, force one
  request wider than the step (as `lmx_scratch`'s cold path does), then force a SECOND, smaller
  growth in the same pool and assert the second chunk's capacity equals the pool's original step,
  not the first (wide) request's size -- this is the row that would have caught D-67 and must
  fail RED on the current code before the fix and pass GREEN after (mutation: reverting the
  `want` plumbing back to reading only `pool\chunk_capacity` must turn it RED again).

## 6. Not in scope here

- Whichever option is chosen, D-60/D-62/D-12/the `Lmx` layout migration (the other items under
  "Ядро (Sonnet)" in `fable_next.md` §3.5) are separate tickets, not touched here.
- No change proposed to `lmx_chunk_cells`/`lmx_chunk_room`/`lmx_chunk_set_used`/
  `lmx_chunk_set_room` (§2's helper pair) -- all three options only touch how big a NEW chunk is
  allocated, not how usage/room within an existing chunk is accounted.

## 7. Questions for fable/author

**QUESTION D-67:** `lmx_pool_add_chunk`'s current behavior (climbing `pool\chunk_capacity`
permanently on a successful oversized `lmx_pool_take_n` request, `lmx_pool.lm1:318-320`) is
documented as an intentional trade-off in its own header
(`lmx_pool.h.lm1:42-54`, quoted in full in §4), written 2026-09-24, two days before D-67 measured
the SAME fact as a defect on 2026-09-26 via `lmx_scratch`'s shared pool (interned char table vs
`out`, §3). Minimal example: `lmx_pool_open(arena, p, stride, 8, ...)`, then one
`lmx_pool_take_n(arena, p, 40)` (oversized, climbs the step to 40), then a later, unrelated
`lmx_pool_take_n(arena, p, 8)` that needs a new chunk -- under current code the second chunk is
allocated at 40 cells, not 8.

1. Which of §5's three options should land: **A** (decouple per-call chunk size from the pool's
   remembered step -- fixes the shared case, costs the dedicated-growth case its
   fewer-larger-chunks benefit), **B** (close D-67 as intended; the header's trade-off already
   prices this in), or **C** (leave `lmx_pool` as documented; restructure `lmx_scratch` to stop
   sharing one growing pool across unrelated request sizes)?
2. If A: is there a LIVE caller today (besides the header's own hypothetical) whose `LmxPool` is
   genuinely dedicated to one repeatedly-growing collection and would measurably lose the
   climbing-step benefit? Partial answer from this pass: `lmx_post.lm1:298`
   (`lmx_pool_open(arena, @ box\nodes, c.sizeof(c.LmxPostLink), c.LMX_POST_NODE_CHUNK, ...)`) IS
   such a dedicated pool -- one mailbox's own link-node chain, not shared with any other
   mailbox or purpose -- but whether its `lmx_pool_take_n` calls ever request `count` wide enough
   to trigger a climb (vs. always one node at a time) was not traced in this pass. Every OTHER
   production (non-selftest) `lmx_pool_open*` call site besides `lmx_scratch.lm1:15` and
   `lmx_post.lm1:298` is worth the same check before deciding between A and B/C.

Not blocking other work: continuing with -200 к.1 and -201 к.1 in the same push while this
question is open, per `steps/cloud-protocol.md` §5 ("не ждать ответа молча").
