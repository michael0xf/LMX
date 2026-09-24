# FABLE-GROKBOT-PUT-REF-20260925-186 -- Commit 1 (read-only measure)

Base: `origin/main` **039bf22** (joint -188 k.3b/k.3c + Opus c3a).  
Author: Grok_bot. **No kernel/translator code in this commit.**  
Translator slot form: owned by **Opus c3b-3**; proposed below, pending his agreement before Commit 2.

Normative: plan par.3 "Two forms" (Q26.2); -183 measure (`steps/root-putof-mul-183.md`); CORE reference-field note; defect path after own bindings move (copier must stop descending into pointer-cell pointees).

---

## 1. What changed under (M,M) / lmx_fresh / Q29 since the old -186 sketch

The old -186 sketch (PUT_REF = direct-slot store; selftest `lmx_walk_put_ref_selftest.lm1`) assumed own Structure bindings were still pointer cells opened by DEREF, and that activation was a single occurrence M. After -188 + Opus c3a on 039bf22:

| Topic | Then (pre -188) | Now (039bf22) | Effect on -186 |
|-------|-----------------|---------------|----------------|
| **(M,M) / CALL** | Walked CALL `[call, M, args…]`; activation node = M | CALL `[call, code, data, args…]`; in-place `data == code`; re-entry `data = FRESH(code)`; `activate(node=data)`; native `entry(owner=data)` | PUT_REF / own Structure slots must target **data** (activation instance), not only the code occurrence. Hand fixtures that name the code Structure as holder already remap via `lmx_walk_data_holder` for OWN/SET/PUT; PUT_REF must follow the same holder rule. |
| **lmx_fresh** | Not a walker op | `LMX_WALK_OP_FRESH=23`; `lmx_fresh` zeroes Model **data** fields (incl. pointer cells → null); keeps child0 callable by address; **preserves** primitives under OP/ROLE frames (k.3c-fix2) | A fresh instance's Structure-typed own slots, once they are direct, start empty (0) until PUT_REF / builder fill. Today's fresh of a pointer-own `Model: m` still allocates a **null pointer cell** (data-field zeroing). After -186 that field becomes an empty direct slot instead. |
| **Q29** | One cell per declaration (plan); emitter still mid-flight (Opus c3b-2 numeric, c3b-3 pointer) | Same rule; c3a landed; c3b-2 (Opus, now) removes working copies for numeric formals; **c3b-3** is the pointer / Structure-own wave that must agree the slot form with this ticket | First bare assignment / declaration line is the bind of the direct slot (PUT_REF or builder store). Later assignments write the **same** slot (Q29), not a new occurrence cell. |

Also: Opus c3a removed `l2_new`; static calls pass data over M itself; re-entry / dynamic use `lmx_fresh` instances. Kernel PUT_REF does not depend on `l2_new`, but harness rows that still build pointer cells for `Model: m` / received `m` re-gate with Opus c3b-3.

---

## 2. Two forms (plan par.3) -- what becomes a direct slot vs what stays a pointer cell

### Become **direct slots** (own Structure bindings; admission sees a Structure; copier descends as a child)

Written by **PUT_REF** `[put_ref, holder, slot, value]` → `lmx_arena_ref_store(holder, slot, value)` (value = Structure address or null as admitted). No instance pointer cell.

- `Model: m` (and other Structure-typed **own** fields of a Model / unit)
- Root Structure-typed fields (walked / native root)
- Merge result (`R: merge: X` -- already direct after -183 c4; PUT_REF stays the write shape if rebound)
- Received `m` (`receiveMessage: m` / take payload binding)

### Stay **pointer cells** (reference representation; copier must **not** descend into pointee once own bindings have moved)

- Reference fields `@: T` (e.g. `@: Inner inner`, `@: LmxMsg sender`)
- Non-Structure `@: int p` / scalar pointer cells (value is the cell itself)
- Letter sender slot 0 as already cell-shaped (Sonnet -173)

Program-visible rule (Q26.2): `@` of a Structure binding is the **Structure's address**. Reading a reference field absorbs one DEREF so the program still sees a Structure. `o\inner: @ a` remains ordinary **PUT** into the pointer cell (not PUT_REF). `o\inner: a` (own) is merge-in-place (Q26.1), not PUT_REF.

---

## 3. Kernel sites to change (Grok .lm1 only; Commit 2+)

Measured on 039bf22 under `dev/l2src_sandbox/`.

### 3.1 Walker -- new role PUT_REF

- `lmx_walk.h.lm1`: add `LMX_WALK_OP_PUT_REF` (next free after FRESH=23 → **24**), bump `LMX_WALK_OP_COUNT` **24 → 25**.
- `lmx_walk.lm1`:
  - **Eval**: `[put_ref, holder, slot, value]` -- resolve holder (same `lmx_walk_slot` / `lmx_walk_data_holder` path as PUT for fixed holders, or eval holder if we mirror PUT_OF; prefer fixed holder+slot like PUT for the first cut), eval value as Structure (or null if admitted), then `lmx_arena_ref_store` into that slot. Mutant: use `lmx_pointer_store_known` → RED (that is PUT).
  - **Scan / prepare**: arity and child scan like PUT (value at last child; plain Structure value is data, not a body node).
  - **LmxWalkOwn**: Structure-typed own fields in direct slots are **not** own records (`o\from` is a CELL today). SET must not apply to them; PUT_REF is the write. Confirm plan survey does not register direct Structure slots as OWN cells.
  - Activation (21.5): when data is a FRESH / in-place instance, PUT_REF into data's direct slots; holder remap via `lmx_walk_data_holder` when fixtures still name the code occurrence.

### 3.2 PUT (stay) vs PUT_REF (new)

Today `LMX_WALK_OP_PUT` (`lmx_walk.lm1` ~1290): if slot holds a pointer cell → `lmx_pointer_store_known`; else numeric store. That pointer branch is exactly **`o\inner: @ a`** and any remaining pointer-own shapes.

After -186: Structure-typed **own** slots are no longer pointer cells, so PUT's pointer branch no longer binds `Model: m`. PUT_REF owns that bind. PUT keeps reference-field and scalar-pointer writes.

### 3.3 DEREF

Today `LMX_WALK_OP_DEREF` (~1262): open a pointer cell to the held Structure for OF / path. After own→direct:

- Paths to own Structure fields lose one DEREF (slot already holds the Structure).
- Reference fields keep DEREF.
- Mutant: DEREF a direct Structure slot → INVALID / wrong (no pointer cell).

### 3.4 Copier (`lmx_graph_copy_owned.lm1`)

Today (~557–574): for `vtype >= LMX_TYPE_POINTER_BASE`, copy allocates a new pointer cell and **`lmx_copy_value` on the pointee** (descends). That is right while own Structure bindings are still cells (pointee is the owned child graph), and **wrong** for reference fields (pointee must stay shared).

Order (from -183): **move own bindings to direct slots first**, then change the copier so pointer cells **stop descending** (keep / map the cell; store the same pointee address, or copy only the cell shell). Until own bindings move, the copier cannot tell the two apart.

### 3.5 `lmx_fresh` pointer-cell rule (`lmx_fresh.lm1`)

Today: Model data pointer fields → new cell with null (or preserved value only under OP/ROLE parents). After own Structure fields are direct slots:

- Direct Structure own slots: store **0** (empty child), not `lmx_pointer_new_owned`.
- Reference `@: T` fields: keep allocating a null pointer cell (data zeroing).
- Do not start descending into pointees from fresh (fresh is not the copier).

### 3.6 Selftest (kernel)

New `tests/lmx_walk_put_ref_selftest.lm1` (Commit 2+):

- PUT_REF into a direct slot; OF / AT see Structure without DEREF.
- Mutant: PUT_REF via pointer_store path → RED; PUT into direct Structure slot without PUT_REF → RED or defined refusal.
- Interaction with FRESH / data_holder: CALL data=FRESH, PUT_REF into instance slot; code occurrence's slot unchanged.
- Null / empty take policy: align with PUT's null-letter rule only if plan says so for own slots (measure in Commit 2).

---

## 4. Proposed translator slot form (Opus **c3b-3** owns this; pending agreement)

Not Grok code. Coordinate before Commit 2.

**Proposal (aligns with -183 translator site list and Opus c3b-3 "pointer own fields"):**

1. **Builder** (`l2_rw_model` / own-field init ~pointer_new for Structure-typed owns): emit an **empty direct slot** (refs entry 0 / no `lmx_pointer_new_owned`) for Structure-typed own fields (`Model: m`, root Structure fields, received `m`). Keep `lmx_pointer_new_owned` only for `@: T` and non-Structure pointers.
2. **Reads** of Structure-typed own fields: `lmx_arena_ref_value` / `lmx_arena_ref_struct` -- **no** `LMX_WALK_OP_DEREF` / no `lmx_pointer_value_known` at the root path. Drop the DEREF layer counted in -183 (3 root DEREF sites).
3. **Writes** that bind/replace the own Structure in the slot: walk frame **PUT_REF** (or native `lmx_arena_ref_store`). Do **not** emit PUT+pointer_store for these fields.
4. **Reference assign** `o\inner: @ a`: unchanged PUT into the pointer cell.
5. **Own assign** `o\inner: a` (Q26.1): merge-in-place (`lmx_walk_merge_into`), not PUT_REF.
6. **Harness**: rows that today build `LMX_TYPE_POINTER_BASE+…` for Structure owns (~44 upper bound in -183) re-gate with c3b-3; `@: Lmx` reference fields stay cells and must not be collapsed into PUT_REF.
7. **Order vs c3b-2**: c3b-2 (numeric formal-bound, no working copy) can land without PUT_REF. c3b-3 (pointer / Structure-own) should land **with or after** kernel PUT_REF so emitted graphs match the walker.

**Ask Opus:** confirm or correct (1)–(7), especially builder empty-slot vs "uninitialized refuse", and whether received `m` / merge result share the exact same emit helper as `Model: m`.

---

## 5. Out of scope / later

- k.4 `Lmx.native` word (joint Opus c4).
- `lmx_own` / `lmx_dirty` module removal (after Opus c3b-2 / c3b-3).
- -187 selftests cleanup (note: `build_l2src -Run` must not leave `lmx_root_*_selftest.err/.out` in the tree root -- outputs under `build/`).
- No `build_l2src` / harness in Commit 1 (Opus holds the machine for c3b-2).

---

## 6. Commit 1 deliverable

This file only. Branch: `fable/grokbot-186-putref-md`. Next: Opus answers on §4; fable GO → Commit 2 kernel PUT_REF + selftest; joint with c3b-3 as fable schedules.