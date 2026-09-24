# FABLE-SONNET-NATIVE-WORD-20260926-191 c.1 (read-only): the kernel side of `Lmx.native`

Base: origin/main `44b0d03` (grok_bot's -187 c4: L3 interpreter own path retired, `lmx_own`
module/header/selftest deleted). Branch `sonnet/native-191`, no code, no gates.

Scope: the KERNEL side only (`dev/l2src_sandbox/lmx_*.lm1`, `lmx_*.h.lm1`, the ~86
`tests/lmx_*_selftest.lm1` fixtures). The translator side is Opus's own
`steps/code-data-split-189.md` "c4 plan"/"c4 decisions" sections (`:853-1006`), already written
and NOT duplicated here — Form A is fable's decision (`args`@0, `return`@1, own fields/bodies
from 2, no carrier word, no "has parts" marker, positions only in the translator). This document
assumes Form A throughout and calls out every place it changes a kernel-side number.

Norm read in full for this ticket: `next_core_tasks.md` §3 points 1-9 (`:321-341`, current
numbering) — point 8 (`:333`) is the `Lmx.native` amendment itself, point 9 (`:334`, new since
`-190`) is "code is built at runtime, the translator is a service" and constrains k.4 to require
nothing beyond the data prototype itself at walker entry (no descriptor, no plan outside the
prototype) — noted as a forward-looking constraint on lmx_plan's redesign below, not something
this commit must satisfy yet. `docs/L2_spec_ru.md` §2/§5/§10/§11, `CORE.md` §2/§3 (English,
already updated 2026-09-25 to the accepted `{array, parent, native}` layout) — quoted inline
below where a kernel site needs to match spec wording exactly. `steps/selftests-187.md` §4 gives
the file:line inventory this section 4/5 verifies against actual source. `steps/code-data-split-188.md`
is Grok's own k.2/k.3 landing note; nothing in it touches k.4 directly beyond confirming order
(k.3 -> -186 -> -187 -> -170c2 -> k.4).

## 0. What the norm fixes, verbatim anchors

- `Lmx` becomes `{array, parent, native}`; `array` is a by-value `VoidArray {size, data}` first
  member (CORE §2 `:67`, L2_spec_ru §2 `:21`); `&node->array == (void*)node`.
- Dispatch: `native` non-null -> native entry `(node, self, ...)`; null -> walker over the body
  operators. No third state, no mode (CORE §3 `:183-184`; L2 §11 `:112`).
- Signature is an ordinary lexical graph field (Form A: `args`@0/`return`@1) — not decoded here,
  not a `sig` word.
- Copier carries `native` verbatim, does not descend into it, does not rewrite it (CORE §2 `:83`,
  L2_spec_ru §2 `:24`, §13 `:122`: "нативный вход не сливается").
- Merge result: `native` of the last operand with a body (§3 point 8; §13 `:122`); empty otherwise.
- `lmx.h.lm1:59-70`'s "a fourth field here is a DEFECT" comment is the author's own OLD instruction
  and is explicitly lifted by the 2026-09-25 decision — this commit's job includes rewording it,
  not preserving it.

## 1. The `Lmx` layout change: every counting / copying / allocating site

### 1.1 The layout itself (`lmx.h.lm1:66-70`)

Today:
```
struct: Lmx
    @: Lmx parent
    int: len
    @: void data
end: Lmx
```
Target (CORE §2 `:67`, L2_spec_ru §2 `:21`):
```
struct: Lmx
    VoidArray: array
    @: Lmx parent
    LmxEntry: native
end: Lmx
```
`VoidArray` does not exist yet in `lmx.h.lm1` (it is named only in
`LMX_ARRAY_OWNED.txt`, per -189's own measurement at base `2f8d475`, unchanged at `44b0d03` --
confirmed by grep, zero hits for `struct: VoidArray` under `dev/l2src_sandbox`). It must be
declared before `struct: Lmx` (2 fields, `size_t size; void *data;`, no `parent`, matching
`LmxArrayDesc`'s own shape byte-for-byte but a distinct type name — L2_spec_ru §5 `:45` keeps
`LmxArrayDesc` as the *standalone* Array descriptor type, separate from `Lmx.array`'s embedded
one, even though "the physical type is the same" (CORE §2.2 `:158-159`).

**Precedent for the embedded-first-member idiom, already in this codebase**
(`lmx_pool.lm1:35-42`, `lmx.h.lm1:217-220` `LmxArrayDynamicArray {LmxArrayDesc array; size_t capacity}`,
comment "`offsetof(array) == 0` so a DynamicArray* may be read as LmxArrayDesc* for len/data"):
L1 has **no transparent field promotion** through a by-value embedded first member. Every site
that needs `.size`/`.data` on such a record casts the outer pointer to the embedded type and reads
through the cast, e.g. `lmx_pool.lm1:40-42`:
```
cells: @ chunk\cells
base: (cast: (@: LmxCharArray) cells)
return: base\len / stride
```
This is the concrete answer to what would otherwise be an open question ("does L1 promote
embedded-struct fields"): it does not, and the kernel's own idiom for "same address, different
declared type" is the cast-and-read pattern above. **Recommendation for k.4**: every kernel site
that today reads `node\len` / `node\data` on an `@: Lmx` reads `(cast: (@: VoidArray) node)\size` /
`\data` instead (or, more likely, a small helper `lmx_children(node)`/`lmx_child_count(node)` pair
introduced once and used everywhere, mirroring `lmx_arena_ref_value`'s own role as the one place
that indexes into a node's children — **OPEN for fable/Opus**: whether to add such a helper pair
or leave every site doing the cast inline. A helper pair touches fewer lines per future change and
gives one place to keep the `int`->`size_t` width change (below) correct, but is a new API surface
this plan does not assume without a decision).

**Width change riding along**: `Lmx.len` is `int` today; `VoidArray.size` (matching
`LmxArrayDesc.len`, `size_t`) makes it `size_t`. CORE §2.2 `:161-162` already flags this exact
discrepancy ("The current code still uses `size_t len` for `LmxArrayDesc` and `int len` for
`Lmx`"). Numerous existing call sites already cast `node\len` to `size_t` at the point of use
(e.g. `lmx_fresh.lm1:269` `n: (cast: (size_t) proto\len)`, `lmx_walk.lm1:1802`
`while: i < (cast: (size_t) node\len)`) — these casts become plain reads once the field is
`size_t` natively; sites that compare `< 1`/`< 0` against a negative-checked `int` (none found:
`lmx_call.lm1:92` `if: callable\len < 1` still holds under `size_t`, since `< 1` on an unsigned
type is `== 0`) are unaffected in behavior.

### 1.2 Construction — the one kernel constructor

`lmx_value_owned.lm1:24-31`, `lmx_node_new_profiled`:
```
fn: lmx_node_new_profiled (@: LmxArena arena; @: Lmx profile) @: Lmx
    @: Lmx value (cast: (@: Lmx) lmx_arena_take_profiled(arena, c.sizeof(c.Lmx), c.LMX_KIND_STRUCT, c.LMX_TYPE_STRUCT, profile))
    if: value != 0
        value\parent: 0
        value\len: 0
        value\data: 0
    ---
    return: value
```
This is the **sole** site in the kernel that fills a fresh `Lmx`'s fields directly (grep for
`\len:`/`\data:`/`\parent:` on `@: Lmx`-typed locals across `dev/l2src_sandbox/*.lm1`, excluding
`tests/`, confirms every other `\parent:` write is either re-parenting an *existing* node
(`lmx_root.lm1:63/123/165/181/573`, `lmx_thread.lm1:101/344/361`, `lmx_fresh.lm1:268`,
`lmx_graph_copy_owned.lm1:803/814/817`, `lmx_merge_owned.lm1:336`) or belongs to an unrelated
`LmxArrayDesc`/`LmxCharArray`/`VoidArray`-shaped record (`lmx_arena.lm1`, `lmx_array_owned.lm1`,
`lmx_pool.lm1`, `lmx_post.lm1`, `lmx_service.lm1`, `lmx_ref.lm1`, `lmx_arena_refs.lm1` — none of
these are `Lmx` itself). Becomes:
```
    if: value != 0
        value\array.size: 0    # or the cast-helper form, per the 1.1 OPEN question
        value\array.data: 0
        value\parent: 0
        value\native: 0
    ---
```
`c.sizeof(c.Lmx)` grows by `c.sizeof(c.VoidArray) - c.sizeof(c.int)` (roughly one pointer, given
alignment) plus `c.sizeof(c.LmxEntry)` (one function-pointer width) minus the removed
`int len`/`void *data` pair's old width — net effect is an ABI-visible size bump on `Lmx`. Every
`tests/*_selftest.lm1` fixture that hand-allocates via `calloc(1U, c.sizeof(c.Lmx))`
(`lmx_ref_selftest.lm1:26-27`) or passes `c.sizeof(c.Lmx)` to `make_block` as a size witness
(`lmx_arena_blocks_selftest.lm1:82-83/109/119/165-167`) keeps working unchanged — they only use
the symbolic `sizeof`, never a literal byte count, so this is not itself a selftest break; flagged
here only because -187 §4's inventory did not name these two files and they ARE `Lmx`-layout-sized
sites, for completeness of "every site."

No second constructor exists: `lmx_struct_new_owned` (`lmx_value_owned.lm1:33-41`) and
`lmx_fresh_struct` (`lmx_fresh.lm1:264-268`) both call `lmx_node_new_owned` ->
`lmx_node_new_profiled` and only set `\parent` afterward, so they need no change beyond what 1.2
already covers.

### 1.3 The child-array itself: `lmx_arena_refs_open_owned` / `lmx_arena_ref_value` / `lmx_arena_ref_store`

Not read in full this pass (out of the explicit read list for k.1, and -187 §4 does not name
`lmx_arena_refs.h.lm1`/`.lm1` as a k.4 site) but flagged as an **OPEN verification item for the
coding commit**: these are the primitives that presumably read/write `node->array.size` /
`node->array.data` (today `node->len`/`node->data`) to open and index the child-reference range.
`lmx_arena_refs.lm1:39-40` (seen in the grep above) writes `parent\data`/`parent\len` on what its
own local is typed as — worth a direct read before coding to confirm it takes an `@: Lmx` versus
an `@: LmxArrayDesc`-shaped local, since the two are about to diverge in field spelling.

### 1.4 Copying/merging: no separate constructor, but every reader of `.len`/`.data` on an `Lmx` moves

`lmx_graph_copy_owned.lm1` builds destination Structures via `lmx_node_new_owned` (already covered
by 1.2) and reads a source's child count/backing through `lmx_arena_ref_value`/arena accessors, not
through `.len`/`.data` directly in the excerpts read (`:360-518`) — so the copier's own body needs
no `.len`/`.data` rename beyond whatever `lmx_arena_refs`'s primitives absorb internally (1.3).

## 2. The dispatcher rewrite by `Lmx.native`

Three call paths dispatch on "is this a callable occurrence" today, all through the same
child[0]-classification idiom (`lmx_call_ready`, `lmx_walk_is_callable`,
`lmx_copy_is_callable_occurrence` — three independent re-implementations of the same question,
per `lmx_call.lm1:86-101`, `lmx_walk.lm1:26-41`, `lmx_graph_copy_owned.lm1:443-454`). Under k.4
this collapses to one question with no arena round-trip: `node\native != 0`.

- **`lmx_call0`** (`lmx_call.lm1:128-176`): drop `lmx_call_ready` gate (a Structure in head
  position is always executable — L2_spec_ru §11 `:112` "нет проверки сигнатуры... любая
  Structure"), drop the `target`/`info`/`addr` extraction through child[0], read `callable\native`
  directly. `addr = 0` -> same walk-hook fallback as today (`lmx_call_walk_fn`). The
  `c.fprintf/c.abort` invariant-trap branch (`:161-164`, dead code today since `addr` is always
  either 0 or a real value by construction) stays as a defensive trap on `native` too, unchanged
  in spirit.
- **`lmx_call_prim`** (`lmx_call.lm1:177-218`): same shape, dispatch on `code\native`, call
  `entry((cast: (@: void) data), refs, nargs, dest, out)` directly — no `info\method\addr`
  indirection, no `LmxCallable` cast. The `out = 0 || data = 0 || <not callable>` guard becomes
  `out = 0 || data = 0 || code = 0 || lmx_range_classify(arena, code) != c.LMX_KIND_STRUCT` (or
  simply "not a Structure" — the norm removes the separate "callable" predicate entirely: "любая
  Structure в позиции головы исполняется, отказ — дело транслятора," §3 point 8).
- **`lmx_walk_callable_addr`** (`lmx_walk.lm1:45-56`) becomes a one-line `return: node\native`
  (no `lmx_walk_is_callable` gate, no `lmx_arena_ref_value(node, 0U)`, no `LmxCallable` cast). Its
  caller `lmx_walk_callable_result_type` (`lmx_walk.lm1:911-930`) currently reads
  `info\method\sig` for the `LMX_WALK_RESULT_SIG_MARK` bit; under Form A this becomes a read of
  the callee's `return` part's cell type (slot 1) instead of a sig bit — this is the walker-side
  half of Opus's Form A decision (translator emits the typed CALL destination; -189 c4 decisions
  `:1001` "the result class comes from the CALL's typed destination, which the translator emits") —
  **so this function likely goes away entirely**, replaced by whatever the translator already
  passes at the CALL site, not recomputed by the walker. Flagged as a **coordination point with
  Opus**, not resolved here.
- **`lmx_walk_is_callable`** (`lmx_walk.lm1:26-41`) and **`lmx_call_ready`**
  (`lmx_call.lm1:86-101`) both go: "is this callable" stops being a question ("no test for
  callable at all" per §3 point 8's last sentence). Every caller of either (grep count: `call_ready`
  used at `lmx_call.lm1:106/121/137/186`, `lmx_call0`'s walk-hook fallback branch reads
  `lmx_call_walk_fn` directly and does not need the callable gate at all once dispatch is by
  `native`) drops the call and reads `\native` in its place.
- **`lmx_walk_descriptor`** (`lmx_walk.lm1:1780-1796`) — "asking the arena EXACTLY TWICE: is M a
  Structure, is its child[0] an LmxCallable" — goes entirely. Its one caller,
  **`lmx_walk_enter`** (`lmx_walk.lm1:1824-1874`), currently gets `info`/`plan` from it
  (`info: lmx_walk_descriptor(...)`, `plan: info\header`); this is the crux of section 4 below
  (where the plan lives once there is no descriptor to hold `header`).

## 3. Deletion list

Confirmed dead once k.4 lands (cross-checked against the actual grep-count files, not assumed from
-187's prose alone):

- **`LmxCallable {method, header}`** (`lmx.h.lm1:193-196`) and its constructor
  `lmx_callable_new_owned` (`lmx_value_owned.lm1:53-59`, `.h.lm1:15-16`) — the plan (§4) needs a
  new home for `header`'s role (the shared activation plan) before this can go; the *type* itself
  goes regardless.
- **`LmxMethod {addr, sig}`** (`lmx.h.lm1:180-183`) and `lmx_method_new_owned`
  (`lmx_value_owned.lm1:45-51`) — `addr` becomes `Lmx.native` directly (no boxing record);
  `sig` goes with Form A (signature is graph fields, not an encoded word).
- **`lmx_method_intern`** (`lmx_pool.lm1:500-509`) — the sole `LmxMethod`-in-a-pool constructor;
  no longer needed once `native` is a direct field, not a pool-interned shared record. Its own
  comment ("the encoding of sig is not settled") already marks it as provisional.
- **`ARRAY_OF_METHOD`** — not directly grepped this pass (translator-side symbol per -189's own
  `l2_methods` array, `l2trans.lm1:21481/:21702`); kernel side is `LMX_TYPE_METHOD`/`LMX_KIND_METHOD`
  range registration wherever `lmx_method_new_owned`'s pool is opened — needs a direct read of
  `lmx_pool_open`'s call sites for `LMX_KIND_METHOD` before deletion (not located this pass;
  **OPEN verification item**, likely in `lmx_root.lm1`'s or the generated program's arena-setup
  code, since pools are opened once per arena on first use per `lmx_pool.lm1`'s own comment `:10-11`).
- **`lmx_call_ready`, `lmx_walk_is_callable`, `lmx_walk_descriptor`, `lmx_walk_callable_addr`'s
  present body, `lmx_copy_is_callable_occurrence`** — superseded by direct `\native` reads (§2);
  the *names* may be worth keeping as one-line wrappers around `node\native != 0` for callers that
  read better as a predicate (`lmx_call0`'s and `lmx_call_prim`'s abort-message branches quote
  "not a callable occurrence" in their diagnostic text, which stays true in spirit) — **OPEN
  style question, not a correctness one**: keep thin predicate wrappers, or inline `!= 0` checks
  everywhere. No functional difference; recommend keeping `lmx_call_ready`-shaped wrappers purely
  for diagnostic-message continuity and to avoid a second `!= 0` idiom spreading through the
  selftests that already call these names directly (`lmx_call_selftest.lm1`, 29 hits).
- **`lmx_walk_callable_result_type`'s sig-bit body** — see §2, superseded by the CALL's typed
  destination once Opus's translator side lands; the function may stay as a thinner
  "read the `return` part's declared type" helper or vanish into the translator's own emission —
  **coordination point with Opus**, not decided here.
- **The `sig` word everywhere it appears as a value**: `LMX_WALK_RESULT_SIG_MARK`,
  `l2_method_sig_text` (translator, -189's own list), `lmx_implements_signature`'s `\sig` compares
  (`lmx_implements.lm1:95-104`) — `implements`'s callable-signature check (§14, L2_spec_ru `:127`)
  moves to an args/return comparison by position under Form A, per -189 c4 decisions `:1002`
  ("implements works from a comparison plan by positions"). `lmx_implements_walk`
  (`lmx_implements.lm1:106-...`)'s `kindC = c.LMX_DOMAIN_KIND_CALLABLE` branch
  (`:157-167`, `ca\method`/`cb\method`/`cc\method` extraction) goes with `LmxCallable` itself; what
  replaces it (comparing `args`/`return` parts as ordinary Structure fields, which the existing
  `kindC = c.LMX_KIND_STRUCT` branch already does recursively) needs no new code — Form A's whole
  point is that the signature becomes ordinary graph fields `implements` already knows how to walk.

## 4. Site-by-site disposition: `lmx_walk` / `lmx_fresh` / copier / `implements` / interpreter / `lmx_call0` / `lmx_root`

### 4.1 `lmx_walk.lm1` / `lmx_walk.h.lm1`

- `lmx_walk_is_callable` (`:26-41`), `lmx_walk_callable_addr` (`:45-56`) — rewritten to direct
  `\native` reads, per §2.
- `lmx_walk_callable_result_type` (`:911-930`) — coordination point with Opus (§2/§3).
- `lmx_walk_descriptor` (`:1780-1796`) — **deleted**. Its two callers:
  - `lmx_walk_enter` (`:1824-1874`): today `info: lmx_walk_descriptor(...)`, `plan: info\header`.
    Becomes: read `node\native` (for the cold/no-body-steps branch's "callable descriptor present"
    test, `:1849-1852`, which becomes "is `node` a Structure with declared body steps at all" —
    the NOT_CALLABLE/NO_GRAPH distinction on a body with zero steps no longer depends on whether a
    descriptor exists, since every Structure is walkable in principle now); then resolve `plan`
    from wherever §4.4 below puts it (keyed by `node`'s own address, not by a descriptor's).
  - `lmx_walk_prepare` (`:1941-1980`): today `info: lmx_walk_descriptor(...)`, checks
    `info\header != 0` to skip re-preparation, and calls `lmx_plan_home(context\arena,
    (cast: (@: void) info))` to find the plan's true owner arena. Once there is no `info`, the
    "true owner" question is asked of `node` directly: `lmx_plan_home(context\arena, (cast:
    (@: void) node))`. This is a direct, mechanical substitution IF `lmx_plan_home` (= `lmx_range_home`,
    per `lmx_plan.h.lm1:93-96`) can classify an ordinary occurrence node the same way it classifies
    a `LmxCallable` descriptor today — which it can, since `lmx_range_home` works off the arena's
    address-range index and an occurrence `node` is registered in exactly one arena's index the
    same way a descriptor is. No new mechanism needed here, only a different address passed to an
    existing one.
- `lmx_walk_prepare`'s `info\header != 0` re-preparation guard (`:1962-1963`, "a descriptor that
  already has a plan is left alone") — becomes a lookup of "does a plan already exist for `node`"
  in whatever registry replaces `info\header` (§4.4).
- `lmx_walk_plan_check` (`:1986-...`) — same `lmx_walk_descriptor` dependency, same substitution.
- `lmx_walk_steps`/`lmx_walk_scan`/`lmx_walk_body`/`lmx_walk_survey` (`:1798-1807`, `:881-905`,
  `:1740-1776`, `:1881-1924`) start their loop index at `1` today (skipping physical child[0], the
  descriptor slot): `size_t: i 1U` at `lmx_walk_steps` (`:1801`) is the clearest single-line
  example. Under k.4, `native` is no longer a graph slot at all (it moved out of the child array
  entirely, into its own `Lmx` member per §1.1) — so the body's own fields start at slot **0**,
  not 1, for E and named Structures (L2_spec_ru §10 `:107`/-189 c4 plan `:931-933`: "E loses child
  0... its own fields start at slot 0, or 2 under form A"). Every `i: 1U` / `> 1` / `- 1` here that
  exists **because of** the descriptor-in-slot-0 convention needs to become `0U`/`> 0`/unchanged —
  this is the numbering-shift half of -189's own translator-side note (`:885-893`,
  "`l2_own_mslot` starts at 1... becomes... `l2_m_kids(idx) > 1`... becomes `> 0`"), mirrored on
  the walker's reading side. Under Form A specifically (a method occurrence, not E/named-Structure),
  own fields/bodies start at slot **2** (`args`@0, `return`@1) — so the walker's own-field loops
  need to know whether `node` is "E/named-Structure" (start 0) or "a method occurrence with a
  header" (start 2), which the translator communicates the same way it already tells the walker
  anything else positional: **this is a place where the walker cannot make the choice itself
  (§3 point 8's own text: "имён в языке нет... роль — по месту исполнения")** — flagged as a
  coordination point, not resolved here: either the translator always emits E/named-Structure
  bodies with an empty `args`/`return` pair at slots 0/1 too (uniform start-at-2, simplest for the
  walker, costs two always-empty slots per E/named-Structure body), or the walker is told which
  shape it is looking at some other way. **Recommendation: uniform start-at-2** (empty `args`/
  `return` Structures for E and named Structures) — it removes exactly the branch this paragraph
  describes, at the cost of two cheap empty allocations per non-method callable, and keeps "own
  fields start at a fixed offset" true everywhere rather than true only for methods with a header.
  This is a plan recommendation for fable/Opus to confirm, not a decision this ticket makes.
- `lmx_fresh` hook: `lmx_walk_fresh` (prototyped `lmx_walk.h.lm1:20`, not read in full this pass)
  — presumably the walker's CALL-time FRESH-role handling from -188 k.3c; a direct read is needed
  before coding, flagged as an **OPEN verification item**.
- `lmx_walk_data_holder` (prototyped `:21`) — per -189 c4 plan `:944`, "the child-0 comparison
  goes, since data and code are already separate operands" (post -188 k.3c CALL shape
  `[call, code, data, args…]`). Not read in full; **OPEN verification item**.

### 4.2 `lmx_fresh.lm1`

- `lmx_fresh_struct`'s `keep_slot0` parameter (`:251-293`) — the whole reason it exists is "Top-
  level Model child 0 kept by address until k.4 (callable)" (its own comment, `:277-278`). Once
  `native` is a separate `Lmx` member rather than a child-array slot, there is **no slot 0 to keep
  by address at all** — every child of a code occurrence is now an ordinary declared own field
  (Form A's `args`/`return` are themselves ordinary Structures at slots 0/1, freshened the same
  way as any other nested field-only Structure). So `keep_slot0` does not become "always 0"; it
  is **deleted as a parameter entirely**, and `lmx_fresh`'s own call `lmx_fresh_struct(arena, code,
  code\parent, 1)` (`:302`) drops the trailing `1`. `lmx_fresh_child`'s two `if: proto != 0 &&
  ... proto\len > 0U / head: lmx_arena_ref_value(proto, 0U) ...` guards (`:64-73`, `:85-93`,
  distinguishing an OP/ROLE frame's operand-child-kept-by-address case from an ordinary own field)
  read `proto`'s child 0 for a **different** reason (OP-tree frame detection inside a body, not
  the top-level callable descriptor) and are unaffected by k.4 — this is a body-node question,
  not a callable-occurrence question, and stays exactly as written.
  `native` itself is copied verbatim onto the fresh instance (`out\native: proto\native` — a new
  one-line addition to `lmx_fresh_struct`, since `lmx_node_new_owned` zeroes it and nothing else
  currently sets it there).

### 4.3 `lmx_graph_copy_owned.lm1`

- `lmx_copy_is_callable_occurrence` (`:443-454`) and its one call site inside `lmx_copy_value`
  (`:501-511`, the Q22=II shared-method-reference terminal test) — the *test* ("is `v` a callable
  occurrence whose parent lies outside the copied subtree") no longer asks "is child[0] an
  LmxCallable"; it asks "does `v\native != 0` OR does `v` have declared body steps" — actually,
  re-reading the norm: Q22=II's terminal is about **a reference to a method occurrence held
  elsewhere** (`A: fn: M`, a *field pointing at* an occurrence, not the occurrence's own shape) —
  under k.4 this is still "is the referenced Structure a callable occurrence," now answered by
  `\native != 0 || <has body steps>` rather than child[0]'s classification. Since a plain data
  Structure with no code role never has `native` set and never has op-tree body steps, and a code
  occurrence always has one or the other, this substitution is direct.
  `native` itself: copied verbatim (`dst\native: src\native`), never traversed, never remapped —
  the copier's existing `lmx_copy_is_terminal_profiles` machinery (`:364-393`, METHOD/CALLABLE/OP/
  ROLE/PRIMITIVE-record/MSG-record all "terminal, keep by address") gains no new case for `native`
  because `native` is not a *child slot* the generic child-copy loop ever visits — it is a sibling
  `Lmx` member, copied once per node exactly where `parent` is copied (`lmx_copy_ensure_struct`'s
  `dst: lmx_node_new_owned(dst_arena)` at `:422`, plus a new `dst\native: src\native` line right
  there, mirroring how `dst\parent` is fixed up later at `:803-817`).
- `LmxMethod`'s current terminal status (`kind = c.LMX_KIND_METHOD -> return: 1` at `:498-500`
  inside `lmx_copy_value`, and `:372` inside `lmx_copy_is_terminal_profiles`) — goes with the type.

### 4.4 `lmx_plan.h.lm1` / `lmx_plan.lm1` — the open design question

This is the one place k.4 needs a real decision, not a mechanical rename. Today (`lmx_plan.h.lm1`
`:42-56`): the plan lives at `LmxCallable.header`, "trusted for as long as the occurrence keeps
that descriptor in child[0]: the executable shape of an occurrence is immutable under its
descriptor, only data values change. An act that changes the shape of ONE occurrence first puts a
fresh `LmxCallable {method, header = 0}` into that occurrence's child[0]." The descriptor's whole
job is to be a **swappable indirection cell**: same occurrence address, different descriptor
address, when the occurrence's shape changes — so the plan is safely keyed to the descriptor, not
the occurrence, and a shape change invalidates the plan by construction (new descriptor, `header`
starts at 0 again).

Once `native` is a direct `Lmx` member, there is no descriptor to swap. Two ways to keep "a plan
is trusted only while the shape it was built from is still current":

- **(a) Key the plan directly to the occurrence's own address** (`node`, not `info`). This is
  sound **if and only if** an occurrence's *code* identity (the `Lmx` node carrying `native` and
  the body) never changes shape in place once built — which is exactly what §3 point 2 of the norm
  says ("код неизменяем... исполнение никогда не пишет в узлы операторов, литералы и слово
  `native`") and what CORE §3 restates ("Code is immutable during execution"). Under the accepted
  model there is no operation left that "changes the shape of one occurrence" the way the old
  COW-descriptor dance (`-153`'s `LmxCallable.offset` + COW clone, already reverted per
  `next_core_tasks.md:360`) used to need to handle — a code occurrence's shape is fixed forever
  once built, so keying the plan to `node`'s own address needs no invalidation path at all, which
  is *simpler* than today's descriptor-swap scheme, not just a rename of the key. `lmx_plan_home`/
  `lmx_plan_publish`'s existing "true owner of `p`" machinery (`lmx_range_home`) works unchanged
  on `node`'s address instead of `info`'s.
- **(b) A side table** (occurrence address -> plan) owned by `lmx_plan` itself, avoiding any
  assumption baked into (a). Strictly more machinery for no benefit under the immutable-code
  premise; only worth it if (a)'s premise turns out to be wrong somewhere this plan has not found.

**Recommendation: (a)** — key the plan to `node` directly, drop `LmxCallable.header` along with
the rest of `LmxCallable`, and reword `lmx_plan.h.lm1:42-56`'s "HOME"/"Trust" paragraphs to say
"the occurrence's own address" wherever they currently say "the descriptor." This is a real
design change to `lmx_plan.h.lm1`'s contract text, not just a mechanical find-replace, so it is
flagged here as the one item in this whole plan that most needs fable's / the author's explicit
sign-off before coding, rather than being treated as an obvious consequence of Form A the way
sections 1-3 are.

`lmx_plan_validate_shape`/`lmx_plan_publish`'s own "child[0] of M must be an LmxCallable" gate
(`lmx_plan.h.lm1:87-91`) drops the LmxCallable classification and instead just requires `node` be
a Structure (already true by construction wherever these are called).

Point 9 of the norm (`:334`, "code is built at runtime, the translator is a service" — walker
entry must need nothing beyond the data prototype itself) is a forward constraint this
recommendation already satisfies: under (a), a freshly-built-at-runtime Structure with `native = 0`
needs nothing but itself and an arena to be prepared and walked — no separate descriptor to
construct first.

### 4.5 `lmx_implements.lm1`

Covered in §3's deletion list. The `LMX_DOMAIN_KIND_CALLABLE` branch of `lmx_implements_walk`
(`:106-...`, specifically `:156-167`) is removed; what remains is the existing
`kindC = c.LMX_KIND_STRUCT` recursive branch (visible at `:168-169`'s `else:` in the excerpt read),
which already walks a Structure's fields positionally — exactly what `args`/`return` need, with no
new code. `lmx_implements_signature` (`:95-104`) is deleted with `LmxMethod`.

### 4.6 `lmx_interp.lm1`

- `lmx_interp_callable` (`:10-11`) — thin wrapper over `lmx_call_ready`; becomes a thin wrapper
  over `node\native != 0 || <has body steps>` or is inlined at its one caller.
- `lmx_interp_apply_value` (`:26-55`): `info: lmx_call_callable(...)` (`:44`) and
  `home: lmx_plan_home(context\arena, (cast: (@: void) info))` (`:49`) — both drop the `info`
  indirection per §4.4(a): `home: lmx_plan_home(context\arena, (cast: (@: void) node))` directly.
  This function's own comment (`:47-48`, "Walk builds the plan in the descriptor's home... the
  LmxCallable may live in the bound store") gets reworded to "in the occurrence's home."

### 4.7 `lmx_call0` call sites (not the kernel dispatcher itself, already covered in §2)

`lmx_root.lm1:553` (`st: lmx_call0(arena, graph)`, inside the L2-root-walk dispatch path around
`:541-553`) — a plain call to the kernel's `lmx_call0`, unaffected by the dispatcher's internal
rewrite (its signature `(arena, callable) -> int` does not change). No edit needed here beyond
whatever the dispatcher itself needs (§2).

### 4.8 `lmx_root.lm1`'s slot-0 sites

-187 §4 names `lmx_root.lm1:158,1084,1088,1162` as slot-0 sites to check. Read this pass:
- `:158` — `lmx_arena_ref_store(parent_graph, 0U, parent_children)` / `(graph, 0U, children)`:
  the R0/host graph's slot 0 holding its **List of children** (Thread supervision), unrelated to
  any callable descriptor.
- `:1084`/`:1088` — the `mainArgs` letter's payload slot 0 (`main_args`, the argv Array) and the
  letter Structure's own slot 0 (the sender pointer cell, built by `-172` c4's own authorized
  edit). Mail-letter shape, not a callable occurrence.
- `:1162` — the R0 result model's slot 0 (`code`, an int cell), part of the `exit(...)` model
  Structure, again not a callable occurrence.
All four are confirmed, by direct reading (not by trusting -187's prose alone), to be **unrelated
to the child[0]-descriptor convention** — `lmx_root.lm1` needs **no changes for k.4** beyond
whatever `lmx_call0` at `:553` inherits automatically from the dispatcher rewrite (§4.7). This
matches -187 §4's own parenthetical ("not descriptor ABI").

## 5. The ~40 selftests: keep / rewrite / delete, file-by-file

Full current inventory (86 `tests/lmx_*_selftest.lm1` files, confirmed by directory listing; the
two DELETE-family files -187 §1 named, `lmx_dirty_selftest.lm1` and the sandbox-root
`lmx_own_selftest.lm1`, are **already gone** — grok_bot's -187 c4, the tip of the current base
`44b0d03`, deleted them as part of retiring the L3 interpreter's own working-copy path. Not this
ticket's doing; noted so the REWRITE count below is against the current 86, not -187's original
count against its own base).

A direct grep for the child[0]/LmxCallable/LmxMethod/`\method`/`\header`/`\sig`/`lmx_plan_`/
`keep_slot0` family across all 86 files found 56 with at least one hit — wider than -187's ~40,
because `arena_ref_value(x, 0U)` alone (part of the search pattern) also matches unrelated
slot-0 reads (list children, letter fields, R0 result model — exactly the §4.8 pattern). -187's
own manual audit is the more precise source for REWRITE; cross-checked below against the actual
file list (every family name -187 gives resolves to real files, confirming the audit was done
against real content, not guessed) rather than re-deriving from the noisy grep.

**REWRITE** (child[0]/LmxCallable fixture-construction -> `Lmx.native` fixture-construction; same
test *intent*, different graph-building calls):

Core (5): `lmx_call_selftest.lm1` (29 hits — heaviest user: builds `LmxCallable`/`LmxMethod` by
hand throughout, e.g. `:171-172` `parent\parent: outer` / `callable\parent: parent` style
fixtures), `lmx_callable_selftest.lm1` (8), `lmx_shared_method_selftest.lm1` (8, tests Q22=II's
shared-method-reference terminal — §4.3), `lmx_plan_selftest.lm1` (44 — heaviest single file;
tests `lmx_plan_home`/`lmx_plan_publish`/`lmx_plan_validate_shape` against hand-built
`LmxCallable` descriptors, every one of which becomes a hand-built plain occurrence with `\native`
set directly), `lmx_walk_selftest.lm1` (43, plus its own "dirty published before a call" comment
already noted stale by -187).

Walk ops (15, confirmed exact match against the directory listing): `lmx_walk_admit_selftest.lm1`,
`lmx_walk_admit_throw_selftest.lm1`, `lmx_walk_arith_mul_selftest.lm1`,
`lmx_walk_call_dest_selftest.lm1`, `lmx_walk_deref_selftest.lm1`,
`lmx_walk_fresh_call_selftest.lm1`, `lmx_walk_lt_signed_selftest.lm1`,
`lmx_walk_merge_model_selftest.lm1`, `lmx_walk_off_instance_selftest.lm1` (carries the mutant
comment "working-copy-only" -187 flagged — that mutant's *assertion* needs re-reading once own
writes go direct, not just its fixture construction), `lmx_walk_put_of_selftest.lm1`,
`lmx_walk_put_ref_selftest.lm1`, `lmx_walk_receive_if_selftest.lm1`,
`lmx_walk_receive_take_selftest.lm1`, `lmx_walk_ref_put_selftest.lm1`,
`lmx_walk_typed_selftest.lm1`.

Other kernel-descriptor-shaped fixtures (confirmed present): `lmx_interp_walk_selftest.lm1` (6),
`lmx_runtime_implements_selftest.lm1` (6, `implements`'s callable-signature path — §4.5),
`lmx_fresh_selftest.lm1` (3, `keep_slot0` parameter removal — §4.2 changes its call shape
directly), `lmx_root_host_selftest.lm1` (9), `lmx_root_before_turn_selftest.lm1` (5),
`lmx_thread_turn_selftest.lm1` (15 — heaviest of this group; "path of each call" dispatch shape).

`lmx_app_*` group (10 files, -187's own count was uncertain — "9?"; the actual directory has 10:
`lmx_app_chain_settle_selftest.lm1`, `lmx_app_lanes_mail_selftest.lm1`,
`lmx_app_many_turns_selftest.lm1`, `lmx_app_min_selftest.lm1`, `lmx_app_poll_stale_selftest.lm1`,
`lmx_app_reroot_forbidden_selftest.lm1`, `lmx_app_root_stub_selftest.lm1`,
`lmx_app_running_lane_selftest.lm1`, `lmx_app_silent_parent_selftest.lm1`,
`lmx_app_two_live_selftest.lm1` — each end-to-end-runs a small program through `lmx_root_launch`,
which dispatches R0's body via the same `lmx_call0` path §4.7 covers; REWRITE here likely means
"no source change, only a harness/build re-gate" rather than hand-edited graph construction, since
these build their programs through the ordinary translator+generated-C path, not raw `LmxCallable`
literals — **flagged as probably lighter-weight than the "Core"/"walk ops" groups**, worth
confirming with a direct read before the coding commit, not assumed here).

Close/orphan/manager/schedule/argv/arena_attach/merge fixtures with hand-built callable shapes
(present, non-zero hits, named by -187): `lmx_close_chain_selftest.lm1`,
`lmx_close_three_level_selftest.lm1`, `lmx_close_watchdog_running_selftest.lm1` (8),
`lmx_close_watchdog_stepped_selftest.lm1` (8), `lmx_orphan_selftest.lm1`,
`lmx_orphan_drain_selftest.lm1`, `lmx_orphan_mail_close_refusal_selftest.lm1`,
`lmx_manager_running_selftest.lm1` (4), `lmx_schedule_band_selftest.lm1` (4),
`lmx_argv_letter_selftest.lm1` — **confirmed by direct read** (`:175-191`), not a false positive:
`al_make`'s own body constructs a real `@: LmxMethod method` / `@: LmxCallable info` pair via
`lmx_pool_make(arena, 2U * c.sizeof(c.LmxMethod), c.sizeof(c.LmxMethod), c.LMX_KIND_METHOD,
c.LMX_TYPE_METHOD)` and `info\method: method` (`:181/:191`) as part of building its test letter's
payload model — a genuine `LmxMethod`/`LmxCallable` construction, REWRITE confirmed.
`lmx_arena_attach_selftest.lm1` — **confirmed by direct read** (`:43`, `@: LmxMethod method 0`):
a declared local of type `LmxMethod`, used as a generic fixed-size pool-record exemplar for an
arena-attach/pool-interval test, not to exercise callable dispatch semantics at all. REWRITE here
means only "substitute some other fixed-size record type once `LmxMethod` is deleted (§3)," not
"touch this test's actual assertions" — a lighter edit than the other files in this list.
`lmx_merge_selftest.lm1` (3), `lmx_multi_profile_merge_selftest.lm1`.

`lmx_merge_override_selftest.lm1` — **confirmed by direct read: zero hits** against the precise
callable/plan pattern (its earlier appearance in the broad grep was `keep_slot0`/`arena_ref_value
(x, 0U)` noise, the same class of false positive as §4.8's `lmx_root.lm1` sites). Moved to KEEP.

REWRITE total by this accounting: 5 + 15 + 6 + 10 + 12 = **48 files**, wider than -187's "~40"
estimate mainly because of the `lmx_app_*` group (10, uncertain in -187's own count). One
false-positive (`lmx_merge_override_selftest.lm1`) is now resolved by direct read rather than left
open; the `lmx_primitive_selftest.lm1` and `lmx_close_chain_selftest.lm1` ambiguities below are
not yet resolved the same way and remain the coding commit's first sub-step.

**KEEP** (per -187 §1, confirmed no k.4-relevant hits or explicitly documents unrelated behavior):
`lmx_turn_selftest.lm1`, `lmx_deliver_selftest.lm1`, `lmx_post_*_selftest.lm1` (cursor/mpsc/sweep/
take_refusal), `lmx_settle*_selftest.lm1`, `lmx_service_selftest.lm1`, `lmx_child_selftest.lm1`
(4 hits in my grep, but per direct content — `a\parent: (cast:...)` — these are Thread-parent
reparenting, not `Lmx.native`-relevant; false positive, KEEP confirmed), `lmx_close_chain_selftest.lm1`
is listed by -187 as KEEP in one place and implied REWRITE in another ("close/orphan/manager/
schedule" family) — **contradiction in -187's own text, not resolved here**, flagged for the
coding commit to settle by direct read, `lmx_gc_selftest.lm1`, `lmx_runtime_selftest.lm1`,
`lmx_arena_table_selftest.lm1`, `lmx_mail_cascade_selftest.lm1` (dirty named only in a stale
comment), `lmx_primitive_thread_selftest.lm1` (documents Thread-mode *removal*, unrelated),
`lmx_merge_override_selftest.lm1` (moved here, confirmed above), and the ~29 remaining files with
zero hits in the k.4-relevant grep: all `lmx_arena_*` besides `_attach`/`_blocks`, `lmx_copy_*`,
`lmx_dynarray_layout_selftest.lm1`, `lmx_gc_selftest.lm1`,
`lmx_kind_collision_selftest.lm1`, `lmx_list_grow_selftest.lm1`, `lmx_poll_selftest.lm1`,
`lmx_primitive_selftest.lm1` (7 hits but per -187 KEEP-adjacent "primitive callable fixtures" —
needs the same direct-read triage as `lmx_close_chain_selftest.lm1` below, not yet done this
pass), `lmx_qualified_range_selftest.lm1`,
`lmx_range_cell_selftest.lm1`, `lmx_root_poison_selftest.lm1`, `lmx_root_selftest.lm1` (1 hit,
likely false positive), `lmx_scratch_selftest.lm1`, `lmx_success_rule_selftest.lm1`,
`lmx_thread_children_selftest.lm1` (1 hit, `a\parent` reparenting — false positive, KEEP),
`lmx_thread_graph_root_selftest.lm1`, `lmx_thread_prefix_selftest.lm1`.

**DELETE**: none remaining — both of -187's DELETE candidates are already gone at base `44b0d03`
(see above). No new deletion candidates found this pass.

## 6. Commit plan, gates, and coordination with Opus's c4

Dependency chain, matching -189 c4 decisions' own stated order (`:1005-1006`, "Order: grok_bot's
-187 к.4 (L3's own working copies retired, lmx_own deleted) [DONE, base of this ticket], then
-170 к.2, then his -186/c4 к.4 branch. My c4 commit goes on top of it, then the per-row check and
one gate") — note that text's "-186/c4 к.4 branch" refers to grok_bot picking up kernel k.4, which
fable's -191 ticket now reassigns to me directly (grok_bot receives no further tickets per the
author's word). So the chain becomes:

1. **This ticket's coding commit** (kernel k.4, mine): the layout change (§1), the dispatcher
   rewrite (§2), the deletions (§3), the `lmx_plan` redesign (§4.4, pending fable/author sign-off
   on the (a)/(b) choice above), and the selftest triage+rewrite (§5) — landed and gated ALONE
   first, with the translator still emitting the OLD `child[0]`/`LmxCallable` shape. This requires
   the kernel to accept BOTH shapes transiently (dispatch tries `\native` first, falls back to the
   child[0] classification if `\native = 0` AND child[0] classifies as `LmxCallable`) — **OPEN
   sequencing question for fable**: is a transitional dual-dispatch kernel acceptable for one
   commit, mirroring how `lmx_call.h.lm1`'s own comment already tolerates "a direct METHOD in
   child[0]... an older ABI" as a standing transitional case (`:187-188`), or must the kernel
   commit and Opus's translator commit land as a single joint gate with no intermediate state (as
   `-189`'s own text says for the ORIGINAL grok_bot-does-kernel plan: "his k.4 branch, my commit on
   top, per-row check, one gate")? This plan recommends the joint-gate, no-transitional-state
   approach (my kernel branch, Opus's translator commit on top of it, one gate) as the SAFER
   default, since a dual-dispatch kernel is exactly the kind of "two paths, pick one silently"
   shape the norm explicitly forbids elsewhere (L2_spec_ru §8 `:84`, "Диспетчер не выводит путь...
   и не переключается на другой путь после ошибки" — a Thread-call dispatch rule, but the same
   spirit applies to a callable-occurrence dispatch rule). Final call is fable's/the author's, not
   mine.
2. **Opus's translator commit** (his own -189 c4, `:853-1006`, already fully planned) lands on top
   of my branch: emits `native` directly, emits Form A's `args`@0/`return`@1, updates the harness
   pins his own plan already lists (`:950-958`).
3. **Per-row harness check** (his term, `-189:977`): every changed `Says`/Debt row re-verified by
   running the fixture, not assumed from the pin's old text — same discipline this session has
   used throughout (`-172` c4's 132/354 regression, its four kernel-selftest sites).
4. **One shared gate**: `build_l2src -Run`, harness, L3 selftests, `check_docs`, `diff --check`,
   the mutation witnesses this plan's §2/§4.2/§4.4 changes call for (fresh-instance-vs-shared
   `native` copy, dispatcher `native != 0` mutant, plan-keyed-to-`node` mutant: revert to keying by
   a stray address and confirm a cross-occurrence plan collision goes RED).

Nothing in this document is code; the coding commit starts only after fable's go, per this
ticket's own read-only constraint.

## Questions for Opus (sent directly, not through fable)

1. Confirm Form A's own-field start offset for E/named-Structure bodies: uniform start-at-2 (empty
   `args`/`return` pair even where there is no header), or does the translator distinguish "has a
   header" from "is pure body" some other way the walker must also read (§4.1)?
2. Confirm whether `lmx_walk_callable_result_type` (`lmx_walk.lm1:911-930`) is fully superseded by
   the CALL's typed destination on the translator side, or whether the walker still needs to read
   the callee's `return`-part cell type itself for some path (e.g. a dynamically-dispatched call
   where the translator cannot know the callee statically) (§2/§3).
3. Confirm `lmx_walk_data_holder`'s and `lmx_walk_fresh`'s exact post-k.3c shape (not read this
   pass) so §4.1's two OPEN verification items can be closed before the coding commit.

See [[lmx-coordination-state]] for the running session index.
