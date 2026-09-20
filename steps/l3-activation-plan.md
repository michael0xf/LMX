# Immutable activation plan — binary ABI (L3 / L2 sandbox)

Status: **design checkpoint** for request `LMX-ACTIVATION-PLAN-DESIGN-20260920-27G`.
Owned file: this document only. Implementation code is out of scope until a later owned set.

Normative direction already accepted in [l3-receiver.md](l3-receiver.md) (§ «Производительность входа и activation plan», commits `ddf1586`, `cd0b5e2`): the list of used own-fields is an **immutable activation plan** of the callable descriptor; exact binary layout, copy/share rules and builder ABI are a **receiver/translator** concern and are **not** chosen inside `lmx_walk`.

This file **chooses** that layout and the prepare/validate/resolve API.

## 1. Evidence cited (HEAD at design time)

| Fact | Where |
| --- | --- |
| `LmxCallable { method; header }` in physical child[0] of M; copies **share** the descriptor; body is M after slot 0 | [lmx.h.lm1](../dev/l2src_sandbox/lmx.h.lm1) (`struct: LmxCallable`) |
| `header` of `LmxCallable` is **not read** by the walk today; entry discovers owns by scanning the body | [lmx_walk.h.lm1](../dev/l2src_sandbox/lmx_walk.h.lm1) (limits of the slice), [lmx_walk.lm1](../dev/l2src_sandbox/lmx_walk.lm1) (`lmx_walk_enter` → `lmx_walk_scan` / `lmx_walk_order`) |
| Lexical own slots on M: slot 0 = shared method/callable descriptor; unhosted owns start at 1 (`l2_own_mslot`); nested owns via control-body children (`l2_layout_owns`) | [l2trans.lm1](../dev/l2src_sandbox/l2trans.lm1) (`l2_own_mslot`, `l2_layout_owns`, `l2_m_kids`) |
| Live walk uses scratch + **physical** role refs; numeric-only impostor ops refused | commit `17a6b18`, [lmx_walk.h.lm1](../dev/l2src_sandbox/lmx_walk.h.lm1) |
| **Producer does not exist yet:** `l2trans` still emits `LmxMethod` into slot 0 (`lmx_method_new_owned`, `rec\addr`) and emits **no** L3 body-frame nodes | [l2trans.lm1](../dev/l2src_sandbox/l2trans.lm1) (~14274–14433) |

Do not claim a translator producer, a walk consumer of `header`, or a gate that requires a plan until those land in owned commits.

## 2. Fixed decisions (author / Codex 27G)

1. `LmxCallable.header` points to an **immutable ordinary Structure** — the **plan root**.
2. Plan-root `child[0]` and each entry `child[0]` identify their roles by **physical references** to **shared role records** (same rule as body roles in `17a6b18`).
3. No runtime text; no **semantic** numeric opcode as permanent identity of a plan role.
4. Entries at plan-root slots `[1..N]` are in **lexical own-field order** (the order of `LmxWalkOwn` / checkpoints / `l2_layout_owns` unhosted+hosted discovery).
5. Each entry carries **only** a sequence of `size_t` **child indices** from callable M through lexical child Structures to the final field slot. Numbers are allowed **here** because a shared descriptor cannot hold an occurrence-specific physical pointer.
6. Store **no** M/body/value pointers, mutable activation values, dirty state, names, or interpreter state in the plan.
7. A copied M **shares** `LmxCallable` / `header`; relative paths must resolve in the **isomorphic** copy (graph-copy remaps Structure addresses; indices stay).
8. **Presence** of a valid plan means the **whole** body graph was prepared/validated. Absent / stale / inconsistent plan ⇒ explicit `UNSUPPORTED` / `INVALID`, **never** native `METHOD.addr` fallback.
9. Dynamically built graphs use the **same** prepare/validate ABI before execution.

## 3. Shared role records (plan namespace)

A program that uses plans opens one Structure `plan_roles` (distinct from walk body `roles` of `lmx_walk_roles_open`, which indexes `LMX_WALK_OP_*`).

| Slot in `plan_roles` | Shared record | Meaning |
| --- | --- | --- |
| 0 | `ROLE_PLAN_ROOT` | child[0] of the plan root must be this address |
| 1 | `ROLE_PLAN_ENTRY` | child[0] of each path entry must be this address |
| 2 | `ROLE_PLAN_INDEX` | optional: child[0] of a size_t index cell wrapper if index cells are Structures; **v1 uses bare size_t cells** (arena domain), so this role is reserved and unused |

Recognition: `head == plan_roles[k]` by address. A private `LmxOp` (or any other cell) carrying a number is **not** that role (same impostor rule as walk).

Constructor (receiver / tests):

```text
Lmx *lmx_plan_roles_open(LmxArena *arena);
```

Returns the `plan_roles` Structure with slots 0..1 filled with dedicated owned records (empty payloads; identity is the address). Lifetime: immortal for the program graph that shares descriptors; freed only with that arena.

## 4. Binary shapes

### 4.1 Plan root (`LmxCallable.header`)

Ordinary Structure `P`:

| Child | Content |
| --- | --- |
| 0 | physical ref → `ROLE_PLAN_ROOT` |
| 1 .. N | physical refs → entry Structures `E_1 .. E_N` in **lexical own order** |
| (no other children) | |

`N = 0` is a valid prepared plan for a body that uses **no** own fields (still proves the body was validated).

`LmxCallable.header == 0` means **absent plan** (unprepared).

### 4.2 Path entry `E_i`

Ordinary Structure:

| Child | Content |
| --- | --- |
| 0 | physical ref → `ROLE_PLAN_ENTRY` |
| 1 .. L | `size_t` cells — path indices `p[0] .. p[L-1]` |

Path semantics on occurrence `M`:

```text
cur = M
for j in 0 .. L-2:
    cur = (Lmx*) child(cur, p[j])     # must be a Structure
field_slot = p[L-1]
cell = child(cur, field_slot)        # the own field cell (publication target)
```

Constraints (validator):

- `L >= 1`.
- Every intermediate `p[j]` (`j < L-1`) selects a Structure child of `cur` that is **lexically inside** `M` (a body Structure under M’s tree after slot 0, or a nested holder the layout placed there).
- Final `p[L-1]` selects a **non-Structure** own cell (v1: int cell domain), or a typed own cell the prepare pass classified as own.
- Paths are **unique** by final cell identity under this `M` at prepare time; duplicate finals ⇒ `INVALID`.
- Order of entries = lexical order of those finals under a deterministic walk of M’s own tree (same order `lmx_walk_order` would emit).

### 4.3 Example paths (aligned with `l2_own_mslot` / `l2_layout_owns`)

| Own kind | Path |
| --- | --- |
| Unhosted own of M at method slot `k` (`k = l2_own_mslot(oi) >= 1`) | `[k]` |
| Own hosted in control-body Structure that is child `b` of M, field child `f` of that body | `[b, f]` |
| Deeper nesting body→body→field | `[b0, b1, ..., f]` |

Slot 0 of M is never an own-field endpoint (reserved for `LmxCallable`).

## 5. Status codes

```text
LMX_PLAN_OK           0
LMX_PLAN_INVALID      1   /* malformed shape, bad role ref, duplicate path, non-isomorphic resolve */
LMX_PLAN_UNSUPPORTED  2   /* plan required but header==0, or stale vs body digest policy below */
LMX_PLAN_NOMEM        3
```

Walk mapping (when plan is required for graph execution):

| Plan status | Walk / call behaviour |
| --- | --- |
| OK | enter may load owns from plan |
| UNSUPPORTED (absent) | `LMX_WALK_UNSUPPORTED` (or call-site equivalent) — **not** `METHOD.addr` |
| INVALID | `LMX_WALK_INVALID` |
| NOMEM | `LMX_WALK_NOMEM` |

Native-only callables with **no** body nodes remain `LMX_WALK_NO_GRAPH` as today; a plan is not required for pure-native entry. A callable that **has** body nodes **must** have a valid plan before graph walk (once the consumer is wired). Until the consumer is wired, today’s scan-based enter remains transitional and must not be documented as the permanent contract.

## 6. API signatures (builder / validator / resolve)

All arena arguments are the Message arena that owns the graph cells. Plans are allocated in that arena (immutable after prepare). Scratch is **not** used for the plan itself.

```text
/* Open shared plan role records (once per program). */
Lmx *lmx_plan_roles_open(LmxArena *arena);

/* Build plan for occurrence M into a fresh Structure; does not store into LmxCallable. */
int lmx_plan_build(LmxArena *arena, Lmx *plan_roles, Lmx *M, Lmx **out_plan);

/* Validate existing plan root P against occurrence M (shape + resolve all paths). */
int lmx_plan_validate(LmxArena *arena, Lmx *plan_roles, Lmx *M, Lmx *P);

/*
 * Prepare: build+validate, then store P into LmxCallable.header of M's child[0].
 * Fails if child[0] is still a bare LmxMethod (no LmxCallable) — INVALID.
 * Replaces a previous header pointer (old plan left unreachable; no mutate-in-place).
 */
int lmx_plan_prepare(LmxArena *arena, Lmx *plan_roles, Lmx *M);

/* Read-only accessors */
size_t lmx_plan_entry_count(Lmx *P);
int lmx_plan_entry_len(Lmx *P, size_t entry_index, size_t *out_L);
int lmx_plan_entry_index(Lmx *P, size_t entry_index, size_t path_j, size_t *out_idx);

/*
 * Resolve entry i on this occurrence M → address of the own cell (publication target).
 * No caching inside the plan; activation scratch may cache the LmxWalkOwn row.
 */
int lmx_plan_resolve(LmxArena *arena, Lmx *M, Lmx *P, size_t entry_index, void **out_cell);
```

Build algorithm (normative intent, not code):

1. Require `lmx_call_ready(arena, M) == LMX_CALL_OK` and `lmx_call_callable(arena, M) != 0`.
2. Enumerate own finals in lexical order by the **same** rules as walk’s counting pass over body nodes (roles by physical ref). Refuse unsupported body nodes ⇒ do not publish a plan (`UNSUPPORTED`/`INVALID` as appropriate).
3. For each final, emit the relative index path from M (using layout facts equivalent to `l2_own_mslot` / hosted body slots when the producer is l2trans; for hand-built graphs, paths are explicit from the Structure tree).
4. Allocate `P` and entries; store role refs; store index cells; set `out_plan`.

Validate:

1. `P[0] == ROLE_PLAN_ROOT`; each `E[0] == ROLE_PLAN_ENTRY`.
2. `N` matches rebuild-from-body count; each path resolves; finals unique; lexical order matches rebuild order.
3. Optional future: body fingerprint in a side table — **v1 has no fingerprint field** (keeps plan free of interpreter state). Stale detection = validate fails against current body.

## 7. Ownership, lifetime, copy / share / invalidation

| Object | Owner | Lifetime |
| --- | --- | --- |
| `plan_roles` records | program arena | until arena teardown |
| Plan root `P` and entries | program arena (Message graph) | immortal while any shared `LmxCallable` references `P` |
| `LmxCallable` | shared descriptor (slot 0 of every occurrence of that callable) | shared across `lmx_graph_copy_owned` |
| Activation working values / dirty | scratch / `LmxWalkOwn` | one activation only — **not** in the plan |

**Share:** graph copy shares the `LmxCallable` pointer in slot 0 (existing rule in `lmx.h.lm1`). Therefore it shares `header` / `P`. Relative paths are evaluated on the **destination** occurrence’s Structures.

**Invalidation:** never mutate `P` in place. To change a body, allocate a new plan and swing `LmxCallable.header` (or replace the whole `LmxCallable`). Concurrent readers of the old header see a still-valid immutable plan for the old body shape; callers that require freshness call `lmx_plan_validate` on the occurrence they execute.

**Absent plan:** `header == 0`. Not the same as `N == 0` (empty but prepared).

## 8. Producer insertion points

| Producer | When | What it must do |
| --- | --- | --- |
| **Receiver / tests (now)** | Hand-built L3 graphs in `lmx_walk` / receiver fixtures | After the body tree and `LmxCallable` exist, call `lmx_plan_prepare` (or build+assign) before `lmx_walk_run` |
| **`l2trans` (later)** | Only **after** it emits L3 body-frame nodes and stores `LmxCallable` (not bare `LmxMethod`) in M slot 0 | Same prepare at unit emission time, using `l2_layout_owns` / `l2_own_mslot` as the path authority for unhosted/hosted owns |

Current `l2trans` still writes `LmxMethod` into slot 0 and does not emit L3 body nodes — **no producer there yet**. Claiming otherwise is false.

`lmx_walk` must **not** invent layout; it may only **consume** a prepared plan (future owned change). Until then, scan-based enter is explicitly transitional.

## 9. Acceptance tests (design-level)

Minimum suite once code exists (names are targets, not present files):

1. **Shape:** prepare on M with two unhosted owns → `N=2`, paths `[1]`, `[2]` (or actual mslot indices); roles are physical; no text fields.
2. **Lexical order:** owns mentioned in body order B,A still appear in lexical field order A,B in the plan.
3. **Nested path:** own inside a body Structure → multi-index path; resolve returns the same cell as a direct child walk.
4. **Share across copy:** `lmx_graph_copy_owned`; both occurrences resolve through the **same** `P`; cells differ by address, paths identical.
5. **Absent:** `header==0` + body present → walk/graph entry returns UNSUPPORTED/INVALID, not native success.
6. **Impostor role:** entry child[0] is a private op with a code → validate INVALID.
7. **Bare METHOD:** slot 0 is `LmxMethod` only → prepare INVALID.
8. **Empty owns:** body with ops but no owns → prepared `N=0`, still OK.
9. **Dynamic graph:** build body at runtime, prepare, run; skip prepare → refused.

Evidence hooks for implementers: reuse `tools/run_walk_selftest.py` patterns; add focused plan selftest when owned.

## 10. What this document deliberately does not do

- Does not edit `lmx_walk`, `lmx.h`, or `l2trans`.
- Does not assign numeric ISA meanings to plan roles (addresses only).
- Does not put dirty/flags/values in the plan.
- Does not claim `l2trans` already produces plans or L3 bodies.

## 11. First implementation slice (suggested ownership split)

1. Receiver: `lmx_plan_*.lm1` + roles open + prepare/validate/resolve + tests (items 1–8 above).
2. Walk consumer (separate owned commit): `lmx_walk_enter` loads owns via `lmx_plan_resolve` when `header != 0`; refuses body without plan.
3. `l2trans`: only after LmxCallable + L3 body emission exists.

End of design checkpoint.