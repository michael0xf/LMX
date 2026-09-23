# FABLE-GROKBOT-DYNARRAY-DESC-20260923-134 — Inventory (1)

Base: `a225cd118cd587b424ce43738a4ef817af943e70` (worktree `%TEMP%\lmx-fable134`, branch `fable/grokbot-dynarray-134`).
Author Q18 + refinements (blog 2026-09-23, plan §1 :64–:72; tip refinements a3a8e92 / d3a59e3 folded by steering):

- Base fixed descriptor: `{size_t len; T *data}` — no capacity.
- Dynamic: `{ <T>Array array; size_t capacity }` where `<T>Array` is the **already existing** fixed descriptor of that element type (never a parallel fixed twin).
- If no fixed descriptor for `T` exists, declare it **once** and use it for fixed arrays of `T` as well.
- `void` is one element type only: the void descriptor is today's `LmxArrayDesc {size_t len; void *data}` (the type Lmx will embed). Do not rename it in this ticket. Never use a void descriptor with casts for `int` / other concrete `T`.
- Grep-before-add: reuse; no two descriptor types share an element type.
- Measure whether same-typed descriptors live in an arena typed array — name absences; do not silently fix.
- Out of scope (report only): `l2trans.lm1` (~107), `l1src` `lm_own_*`, `dev/l3_interp`; do not touch `lmx_walk.lm1` / `struct: Lmx`.

## Existing fixed descriptors at a225cd1 (grep)

| Type | Element | Notes |
|------|---------|-------|
| `LmxArrayDesc` | `void *` (opaque / pointer cells; also historically used for ALL array element types via pool `type` field) | Sole exported fixed array descriptor. List public shape is cast-as-`LmxArrayDesc`; capacity hidden in backing prefix. |
| *(none)* | `LmxRange` | No `LmxRangeArray` yet — index is bare `LmxRange *` + count/capacity. |
| *(none)* | `LmxServiceEntry` | No `LmxServiceEntryArray` — service is bare `entries` + count/capacity. |
| *(none)* | inbox slot pair | Inbox is `void *inbox_slots` + `inbox_capacity`; backing is `size_t[2*cap]` pairs. |
| *(none typed)* | chunk cells | `LmxChunk {base; capacity; count; next; mark}` — capacity on chunk itself, not a DynamicArray. |
| *(none)* | copy map/stack | `LmxCopyMap {keys; vals; cap; n}`, `LmxCopyStack {items; cap; n}` via malloc. |

**Finding (global, not silently fixed):** today one C type `LmxArrayDesc` backs every Array element domain (int/char/refs/…) with discrimination in `LmxPool.kind/type`. Author d3a59e3 requires concrete `T` descriptors (e.g. `{len; int *data}`) when those arrays are typed — that full migration of all fixed Arrays is **beyond the six capacity sites**; this ticket only introduces fixed+dynamic pairs for element types **required by the six sites**, and reuses `LmxArrayDesc` for `void *`.

## Six capacity sites (measure at a225cd1)

### (1) L1 List — `dev/l2src_sandbox/lmx_list_owned.lm1` (+ `.h.lm1`)

- **Fields today:** public cell cast `LmxArrayDesc {len; data}`; capacity in backing prefix `size_t` before pointer cells (`lmx_list_cap` / `lmx_list_data` skip prefix). **No exported `LmxListDesc`.**
- **Element type:** `void *` (pointer cells).
- **Storage:** descriptor via `lmx_arena_take(..., sizeof(LmxArrayDesc), LMX_KIND_LIST, type)` — **YES, same-typed descriptors in arena pool** (shared size with Array, distinguished by kind). Backing via `lmx_arena_take_n` (arena), prefix holds cap.
- **Readers/writers:** `lmx_list_{len,cap,data,grow,new,append,remove,value}`; consumers cast list as `LmxArrayDesc` (graph_copy, tests, thread children, …).
- **Target:** public `LmxArrayDynamicArray` (name TBD, embeds `LmxArrayDesc`) instead of hidden prefix; backing = plain `void *` cells; pool stride = `sizeof(DynamicArray)`.
- **Arena-typed-descriptor:** YES for the list descriptor cell.

### (2) Arena index — `lmx_arena.h.lm1` :19–:24 + `lmx_range.lm1`

- **Fields:** `LmxArena { …; LmxRange *index; size_t count; size_t capacity; … }` (triple, not one descriptor).
- **Element type:** `LmxRange` (`{lo; hi; array; owner}`).
- **Storage:** `realloc`/`free` of `index` in `lmx_range_reserve` / arena release — **malloc, NOT arena typed array of descriptors**.
- **Readers/writers:** `lmx_range_reserve/join/drop/classify/...`; `lmx_arena_attach/release`; every classify path.
- **Target:** one `LmxRangeDynamicArray` field (needs new fixed `LmxRangeArray {len; LmxRange *data}` once).
- **Arena-typed-descriptor:** **NO** — index entries live in a movable malloc buffer owned by the arena record. Named; not silently moved into a typed pool.

### (3) Service — `lmx_service.h.lm1` :57–:61 + `lmx_service.lm1`

- **Fields:** `LmxService { LmxServiceEntry *entries; size_t count; size_t capacity }`.
- **Element type:** `LmxServiceEntry`.
- **Storage:** `realloc`/`free` — **malloc, NOT arena**.
- **Readers/writers:** `lmx_service_{open,register,find,post,unregister,close,...}`.
- **Target:** one `LmxServiceEntryDynamicArray` (declare `LmxServiceEntryArray` once).
- **Arena-typed-descriptor:** **NO** — registry table is intentionally movable malloc (comments: entries move, records never do).

### (4) Thread inbox ring — `lmx_post.h.lm1` :127–:131 + `lmx_post.lm1`

- **Fields:** `inbox_slots` (`void *`), `inbox_capacity`, `inbox_head`, `inbox_tail` (+ `inbox_count`). Ring of pairs `[target, source_arena]` as `size_t` words, `2*capacity` cells.
- **Element type (logical):** inbox slot pair (target + source arena). Physical: `size_t`.
- **Storage:** `calloc`/`free` under mailbox monitor — **malloc, movable by design** (not graph / not address-classified).
- **Readers/writers:** `lmx_post_inbox_grow`, accept/transfer/take/snapshot/close.
- **Target:** `DynamicArray` of a once-declared slot/pair (or `size_t`) fixed descriptor + keep `head`/`tail`.
- **Arena-typed-descriptor:** **NO** — private mailbox metadata.

### (5) Pool chunk — `lmx.h.lm1` :260–:266 + `lmx_pool.lm1`

- **Fields:** `LmxChunk { void *base; size_t capacity; size_t count; LmxChunk *next; unsigned mark }`. Also `LmxPool.chunk_capacity` (growth step, not a descriptor field of an array of chunks).
- **Element type of chunk payload:** opaque cells of `pool->stride` (void-ish). Descriptor reshape uses `LmxArrayDesc` (`data=base`, `len=count`) + `capacity`.
- **Storage of chunk record:** `calloc(sizeof(LmxChunk))` (+ arena block bookkeeping) or embedded after `LmxPool` in `lmx_pool_make` — **NOT** an arena typed array of `LmxChunk` descriptors. Payload block is arena-indexed.
- **Readers/writers:** `lmx_pool_add_chunk/take_n/release/chunk_at/drop`, GC mark walk, chars open checks.
- **Target:** `LmxChunk { LmxArrayDynamicArray cells; LmxChunk *next; unsigned mark }` (`offsetof(cells.array)==0` within the dynamic field; chunk itself still has next/mark). Reuse void fixed `LmxArrayDesc` inside the dynamic type — **no new void fixed twin**.
- **Arena-typed-descriptor:** **NO** for chunk *records* (individual calloc / embed). Payload ranges **are** in the arena index.

### (6) Graph copier — `lmx_graph_copy_owned.lm1` :7–:150 + `.h.lm1`

- **Fields:** `LmxCopyMap { void **keys; void **vals; size_t cap; size_t n }`; `LmxCopyStack { Lmx **items; size_t cap; size_t n }`.
- **Element types:** map keys/vals `void *`; stack `Lmx *`.
- **Storage:** `malloc`/`free` — operation-local, **NOT arena**.
- **Readers/writers:** map init/dispose/get/put/grow; stack push/pop/dispose; `lmx_graph_copy_many_*`.
- **Target:** same rule — e.g. map holds two `LmxArrayDynamicArray` (void*) or one dynamic of pairs + occupancy; stack `LmxPtrDynamicArray` needing fixed `LmxPtrArray {len; Lmx **data}` or `{len; Lmx *data}` once. Reuse `LmxArrayDesc` for `void *` sides.
- **Arena-typed-descriptor:** **NO**.

## `rg capacity|cap\b|grow` in `dev/l2src_sandbox` `lmx*.lm1` / `*.h.lm1`

Primary hits (active kernel, excluding comments-only noise): the six sites above; `LmxPool.chunk_capacity`; list grow/cap; post inbox grow; range reserve; service grow; copy map/stack; retired `lmx_array_grow_owned`; selftests; plus **out-of-scope** `l1src/p0.h.lm1` capacities and (outside this glob detail) translator. Full line dump archived in `%TEMP%\fable134_rg_capacity.txt` at inventory time.

## Every reader of `LmxArrayDesc` (sandbox)

Definition: `lmx.h.lm1`. Constructors: `lmx_array_owned`, `lmx_array_ref_owned`, `lmx_pool` `lmx_array_desc_new`. Dynamic misuse: `lmx_list_owned` (cast). Copy: `lmx_graph_copy_owned`. GC/root/ref/thread/tests/harness/eternal driver — see `rg -l LmxArrayDesc` (~40 files under sandbox). Stable `l2src` mirrors exist; this ticket edits sandbox (+ docs) as sole kernel writer.

## Proposed descriptor set after code (compositional; no element-type twins)

| Fixed (reuse or declare once) | Element | Dynamic | Sites |
|-------------------------------|---------|---------|-------|
| `LmxArrayDesc` (existing) | `void *` | `LmxArrayDynamicArray` `{ LmxArrayDesc array; size_t capacity }` | List; chunk cells; copy map keys/vals (void*) |
| `LmxRangeArray` (new once) | `LmxRange` | `LmxRangeDynamicArray` | Arena index |
| `LmxServiceEntryArray` (new once) | `LmxServiceEntry` | `LmxServiceEntryDynamicArray` | Service |
| `LmxPostInboxSlotArray` (new once; or `size_t` array if pair inlined) | inbox slot | `…DynamicArray` | Post inbox (+ head/tail) |
| `LmxPtrArray` (new once) `{len; Lmx *data}` | `Lmx *` | `LmxPtrDynamicArray` | Copy stack |

Invariant: **no two types share an element type.** Void fixed remains exactly `LmxArrayDesc`.

## Logical conflicts / BLOCKER criteria

- Reshape of triples → one DynamicArray field does **not** by itself force ownership into typed arena pools; sites (2)(3)(4)(6) stay malloc unless author orders otherwise — measured absences only.
- List stride change (`sizeof(LmxArrayDesc)` → `sizeof(LmxArrayDynamicArray)`) is required by public DynamicArray; still arena-pooled — not a conflict.
- **No BLOCKER found** that "descriptor cannot sit in typed arena array without changing ownership" for a site that author required to be in-arena: List already is; others are documented malloc.

## Out of scope (report only)

- `l2trans.lm1` capacity/_cap (~107)
- `l1src` `lm_own_*`
- `dev/l3_interp`
- `struct: Lmx` / VoidArray embed rename (separate ticket)
- `lmx_walk.lm1`

