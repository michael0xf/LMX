# A one-off large growth permanently inflates a shared pool's chunk size (D-67)

FABLE-SONNET-POOL-CHUNK-GROWTH-20260925-D67 (Sonnet; base origin/main 2b0a594, cloud session,
no local gate access -- see §4). Read-only investigation and proposed fix per the ticket
protocol (`fable_next.md` §4 к.1); no kernel code changed by this commit.

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

## 4. Why this is a plan, not a patch

- Per `next_core_tasks.md` §0 doctrine (no special cases, no "transitional" patches) and fable's
  own rule (`fable_next.md` §4: "Пробел контракта → вопрос автору, не заплатка"), changing a
  shared allocation contract needs a stated design, not a local tweak.
- This cloud session has no way to run the gate: `tools/build_l2src.ps1` requires PowerShell
  (absent here) and the pinned translator `bin/l1trans.exe` is a Windows PE binary (no `wine`
  available in this container). Per `fable_next.md` §5 the gate now runs on the author's machine
  via Grok CLI. A kernel-code change from here could not be build-checked, harness-checked, or
  mutation-tested before commit, which every prior ticket on this branch required
  (`sonnet_next.md` §4, §5). So this ticket stops at the read-only plan; the code change below is
  a proposal for whoever lands it with gate access (fable/Grok CLI, or a future Sonnet session
  that has it).

## 5. Proposed fix

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

### Touch list for the eventual commit

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

- `lmx_scratch.lm1` itself needs no change: it already forwards its own request size to
  `lmx_pool_take_n`; the fix belongs entirely in the pool layer it calls.
- No change to `chunk_capacity`'s role as the pool's configured default step.
- D-60/D-62/D-12/the `Lmx` layout migration (the other items under "Ядро (Sonnet)" in
  `fable_next.md` §3.5) are separate tickets, not touched here.

## 7. Question for fable/author

None blocking: the fix in §5 is a mechanical decoupling of an existing implicit contract
(`chunk_capacity` conflating "this chunk's size" and "the pool's step"), not a new design
decision. Flagging only for confirmation before someone with gate access lands it, since it
touches a shared allocator used by every pool in the kernel.
