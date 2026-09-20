# Immutable activation plan — binary ABI (revised)

Status: **revised design** for `LMX-ACTIVATION-PLAN-REVISION-20260920-29G`.
Owned file: this document only. No code edits in this checkpoint.

Base: committed ABI at `4f8f52b`. Revision incorporates the **confirmed Fable read-only audit** (consumer owner, gaps 1–4 and lexical-order correction) as relayed through Codex / `lmx_uds`. At revision time, a completed OpenRouter reply for `LMX-ACTIVATION-PLAN-ABI-AUDIT-20260920-28` was **not** available via `lmx_uds` / `chat_status` — this document does **not** invent one.

Normative direction remains [l3-receiver.md](l3-receiver.md) (§ activation plan): the used-own list is an immutable plan of the callable descriptor; layout and builder ABI are receiver/translator concerns, not invented inside `lmx_walk`.

## 1. Evidence (unchanged facts)

| Fact | Where |
| --- | --- |
| `LmxCallable { method; header }` in M child[0]; copies share the descriptor | [lmx.h.lm1](../dev/l2src_sandbox/lmx.h.lm1) |
| Walk entry today: four passes (count scan, load scan, order, nowns==nfound); `header` unread | [lmx_walk.lm1](../dev/l2src_sandbox/lmx_walk.lm1) `lmx_walk_enter` |
| Body role recognition by physical address; operand layouts only in `lmx_walk_scan_node` | [lmx_walk.lm1](../dev/l2src_sandbox/lmx_walk.lm1) |
| `l2_layout_owns` / `l2_own_mslot` group unhosted owns before body hosts — **not** source lexical order (`own a; while { own t }; own b` → native a,b,t vs lexical a,t,b) | [l2trans.lm1](../dev/l2src_sandbox/l2trans.lm1) ~7793–7832 |
| Highest domain/kind today: `LMX_DOMAIN_SCRATCH` 32 / `LMX_DOMAIN_KIND_SCRATCH` 18 | [lmx_implements.h.lm1](../dev/l2src_sandbox/lmx_implements.h.lm1) |
| `l2trans` still emits bare `LmxMethod` in slot 0; no L3 body nodes yet | [l2trans.lm1](../dev/l2src_sandbox/l2trans.lm1) ~14274–14433 |

## 2. Split: generic plan module vs receiver-owned body scanning

### 2.1 Generic module (no body-role knowledge)

Knows only plan shapes, plan role records, publication into `LmxCallable.header`, and fast slot resolution. **Must not** import walk body roles, must not predef `lmx_walk`, must not duplicate `lmx_walk_scan_node` operand layouts (`if`/`while` body slots, `own` holder/slot, etc.).

### 2.2 Receiver / walk owner populates the plan

`lmx_walk_prepare` (name indicative; owned with walk/receiver) runs **once** before execution:

1. Scan the body with existing walk knowledge (one prepare-time scan, same refusal rules as today’s entry scan).
2. Emit own finals in **actual lexical own-occurrence order** (section 6).
3. Call the generic builder to allocate `P` and entries and publish `header`.

Generic API never receives a body-role table for discovery. Passing only `body_roles` without operand layouts is **rejected** as insufficient (Fable gap 1 widened).

## 3. Structural immutability (no digest / no hot-path freshness)

**Removed** from `4f8f52b`: digest/version fields, “stale vs digest”, and any rule that `lmx_plan_validate` runs on the walk hot path for freshness.

Exact rule:

- While an occurrence’s slot 0 points at a given `LmxCallable` record, that occurrence’s **executable shape** (body Structure tree shape and which cells are own endpoints) is **immutable**.
- **Data values** in own cells, and rebinding a slot to another cell of the **same data kind**, may change freely and do **not** invalidate the plan.
- A **structural** mutation (change which Structures/ops exist, change path endpoints’ kinds, replace the body shape) must install a **fresh** `LmxCallable { method, header = 0 }` into **that occurrence’s slot 0 only**, before the new shape is visible to execution. Never clear or rewrite `header` on a **shared** descriptor that other unchanged occurrences still use.
- `lmx_plan_validate` is **preparation / test-only** (rebuild-and-compare or shape checks offline). Walk must **not** call it per activation.

## 4. Physical role records — domain pair

Plan role records are free cells with **address identity** and a meaningless payload (non-zero stride required: `lmx_arena_take` refuses stride 0).

| Symbol | Value |
| --- | --- |
| `LMX_DOMAIN_ROLE` | **33** (next free after SCRATCH 32) |
| `LMX_DOMAIN_KIND_ROLE` | **19** (next free after KIND_SCRATCH 18) |
| stride | `sizeof(@: void)` |
| payload | unused; may be null |
| identity | address of the record |
| graph copy | **terminal** — add `KIND_ROLE` to `lmx_copy_is_terminal` (same class as METHOD / CALLABLE / OP) |

Shared table `plan_roles` (Structure of refs):

| Slot | Record |
| --- | --- |
| 0 | `ROLE_PLAN_ROOT` |
| 1 | `ROLE_PLAN_ENTRY` |

Recognition: `child[0] == plan_roles[k]` by address. A private `LmxOp` or other typed cell is never that role (impostor rule). No text; no semantic numeric opcode as permanent identity.

## 5. One-arena allocation and publication

All of the following live in the **same arena as the `LmxCallable` descriptor** whose `header` is published:

- plan root `P`
- path entry Structures
- `size_t` index cells
- `plan_roles` records used by that descriptor

That arena **outlives** every sharing occurrence (copies share the descriptor by address; they do not re-allocate the plan).

**Checked publication:** refuse to publish when the callable record is not `LMX_DOMAIN_KIND_CALLABLE` **in that arena** (`lmx_domain_kind` / range classify). Do **not** allocate the plan in a copied Message’s arena and then hang it from a descriptor classified only in another arena.

## 6. Lexical own order (reject `l2_layout_owns` as authority)

Plan entries store `N` and slot paths in **actual lexical own-occurrence order** — the order owns appear when walking the **source/body lexical tree** (and the order walk checkpoints must use).

**Explicitly rejected** as lexical authority: `l2_layout_owns` / `l2_own_mslot` grouping (unhosted fields first, control-body hosts after). Counterexample:

```text
own a;
while { own t };
own b;
```

| Authority | Order |
| --- | --- |
| Lexical (required for the plan) | **a, t, b** |
| `l2_layout_owns` native grouping | a, b, t |

Paths remain sequences of `size_t` child indices from M through lexical child Structures to the final field slot (numbers allowed only as occurrence-relative indices). Producer (walk prepare / future l2trans L3 emission) must emit **lexical** order, not native layout order.

## 7. Binary shapes (unchanged skeleton, clarified)

### Plan root `P` (`LmxCallable.header`)

| Child | Content |
| --- | --- |
| 0 | physical ref → `ROLE_PLAN_ROOT` |
| 1 .. N | refs → entry Structures in **lexical** own order |

`header == 0` ⇒ absent plan. `N == 0` ⇒ prepared empty own set (body validated, no owns).

### Entry `E_i`

| Child | Content |
| --- | --- |
| 0 | physical ref → `ROLE_PLAN_ENTRY` |
| 1 .. L | `size_t` cells `p[0] .. p[L-1]` |

Resolve on occurrence `M` (producer precondition: intermediates are Structures):

```text
cur = M
for j in 0 .. L-2:  cur = child_struct_known(cur, p[j])
return address_of_slot(cur, p[L-1])   /* slot address, not loaded value */
```

## 8. Generic API (revised signatures)

```text
/* Domain pair — registered when roles are opened in the callable's arena. */
/* LMX_DOMAIN_ROLE 33 / LMX_DOMAIN_KIND_ROLE 19 / stride sizeof(void*) */

Lmx *lmx_plan_roles_open(LmxArena *arena);   /* same arena as target LmxCallable */

/*
 * Generic construction from an already-enumerated path list.
 * paths[i] is length lens[i] of size_t indices; order is caller's (must be lexical).
 * No body-role parameters. No walk predef.
 */
int lmx_plan_build_from_paths(
    LmxArena *arena,
    Lmx *plan_roles,
    const size_t **paths,
    const size_t *lens,
    size_t N,
    Lmx **out_P);

/* Preparation/test only — not for walk hot path. */
int lmx_plan_validate_shape(LmxArena *arena, Lmx *plan_roles, Lmx *P);

/*
 * Publish P into callable->header. callable must be KIND_CALLABLE in arena.
 * Does not scan a body. Replaces previous header pointer (old P left immutable).
 */
int lmx_plan_publish(LmxArena *arena, LmxCallable *callable, Lmx *P);

/*
 * Fast resolver: ADDRESS OF THE SLOT in current occurrence M.
 * No arena argument, no classification, no allocation.
 * Prepared paths use known child access; intermediate Structure shape is a
 * producer precondition checked only at preparation.
 */
void **lmx_plan_slot_known(Lmx *M, Lmx *P, size_t entry_index);

size_t lmx_plan_entry_count(Lmx *P);
```

Receiver-owned (not in the generic module):

```text
/* Scans body once; builds paths in lexical own order; build_from_paths + publish. */
int lmx_walk_prepare(LmxWalkContext *context, Lmx *M);
```

### Status codes

```text
LMX_PLAN_OK           0
LMX_PLAN_INVALID      1
LMX_PLAN_UNSUPPORTED  2   /* absent plan where required; not "stale digest" */
LMX_PLAN_NOMEM        3
```

## 9. Walk consumer contract

When `LmxCallable.header != 0`:

- `lmx_walk_enter` **removes all four** entry passes (count scan, load scan, order, nowns==nfound check).
- Loads owns by `lmx_plan_slot_known` for `i in 0 .. N-1` into scratch `LmxWalkOwn` rows (still scratch-local dirty/value).
- Eval remains: holder physical ref + slot → slot address → **linear** lookup in the activation’s own table (no reclassify).

When `header == 0` (cold):

- Refusal may distinguish `LMX_WALK_NO_GRAPH` (no body frame nodes) vs `LMX_WALK_UNSUPPORTED` (body present but unprepared). **Never** fall back to native `METHOD.addr` for a body that should be walked.

## 10. Copy / share / one-occurrence invalidation

- Copies **share** `LmxCallable` / `header` / `P` (descriptor terminal).
- `lmx_plan_slot_known` on each occurrence returns **different slot addresses** for the isomorphic paths.
- Invalidation of one occurrence: write a **new** `LmxCallable { method, header=0 }` into **that** M’s slot 0 only. Sibling occurrences that still point at the old shared descriptor keep the old plan.
- Data writes into own cells do **not** invalidate.

## 11. Producer insertion points

| Producer | Duty |
| --- | --- |
| `lmx_walk_prepare` / receiver tests **now** | Body scan + `build_from_paths` + `publish` in the callable’s arena |
| `l2trans` **later** | Only after it emits `LmxCallable` + L3 body nodes; must emit **lexical** own order, not `l2_layout_owns` order |

## 12. Acceptance tests A–I

| ID | Requirement |
| --- | --- |
| **A** | Generic plan module builds/publishes/resolves **without** any `lmx_walk` predef |
| **B** | Lexical order `own a; while { own t }; own b` → plan entries **a, t, b** (not a,b,t) |
| **C** | Original and graph-copy share the same `P`; `lmx_plan_slot_known` returns **different** slot addresses |
| **D** | Publish refused when callable is not `KIND_CALLABLE` in the plan’s arena (wrong-arena / wrong-kind) |
| **E** | One-occurrence invalidation: replace that M’s slot 0 with fresh callable `header=0`; other sharers unchanged |
| **F** | Data writes into own cells do **not** require a new plan / do not clear header |
| **G** | Missing or extra own relative to prepared paths → preparation/validate-shape **INVALID** (test-only path) |
| **H** | Classification count on resolve path: **≤ 5** total around a prepared enter, and **zero inside** `lmx_plan_slot_known` |
| **I** | After warm-up, prepared enter + resolve adds **no** arena/scratch block allocation beyond the activation’s marked scratch slice |

## 13. Fixed decisions (summary)

1. Generic storage/check/fast resolve ≠ body scanning (walk prepare owns the scan).
2. No digest; structural immutability while slot 0 holds that callable; validate is prep/test-only.
3. Role domain 33 / kind 19; stride `sizeof(void*)`; copy terminal.
4. One arena with the published callable; checked publish; never plan-in-copy-arena.
5. Fast API is `lmx_plan_slot_known(M, P, i)` → slot address; no arena/classify/alloc.
6. Lexical own order; reject `l2_layout_owns` as lexical authority.
7. `header != 0` drops four walk entry passes; `header == 0` cold NO_GRAPH/UNSUPPORTED; eval = holder+slot → slot address → linear own lookup.
8. Tests A–I as above.

## 14. Out of scope here

- Implementing modules, registering domain 33/19, or editing `lmx_walk` / `l2trans`.
- Claiming an OpenRouter audit reply (unavailable at revision time).

End of revision.
