# L1/L2 migration into LMX

Assignment `LMX-L1-L2-20260920`. Grok. Does not edit `docs/LMX_semantics.*` or `steps/current.md`.

## Source commit

L1 repository `C:\Nyasha_Planet\L1`, branch `main` = `origin/main`.

- Full hash: `b2a7c98aa59aaf9654f2180e6f2a149e58aa48ee`
- Subject: `openrouter: mark §7 e2e geometry + mtk_key translator gap as DONE in plan`
- Date: 2026-09-20 04:01:42 -0300
- Working tree at consult time: no uncommitted **core** files. Dirty/untracked under L1 were build logs, `dev/mixa_sandbox` artifacts, `deepseek_next.md`, `openrouter_next.md` — not copied.

L1 tree was **not deleted**.

## Consult (deepseek via `lmx_uds`)

Request `GROK-DS-SNAP-20260920`. deepseek stated he did **not** implement the L2 core (his line is `mixa_manager`); core line `l1-98` was not in the live session list. Measurements:

1. HEAD as above.
2. `l1src` — only root `L1\l1src`, 16 files; pin `L1_PIN.txt` = `4E0B7F5D942C291AFD4C2CEB8FBBA5B20EECC44BF7B455A40D8E564846D80DE7` matches `bin/l1trans.exe` on that host.
3. **Two** `l2src` trees: root `L1\l2src` (449 files, newest 2026-09-17) vs `L1\dev\l2src_sandbox\l2src` (511 files, newest 2026-09-19 `lmx_gc.lm1`). Counts: 22 names only in root, 84 only in sandbox, 427 shared, 49 content-differ. Last GREEN kernel gate ran on the **sandbox**. deepseek: do not merge blindly; if a “as of today” snapshot is needed, take root `l1src` + **sandbox** `l2src` and record the root divergence. Which copy is canonical is for the core line, not decided here.
4. Uncommitted core: none.

Historical orientation (not copied as law): `L1/L1_spec.txt`, `L1/L2_core_18-09-2026-description.md`, `L1/docs`, `L1/WHERE_THINGS_LIVE.md`.

## Local copy into LMX

| destination | source | files |
| --- | --- | --- |
| `l1src/` | `L1\l1src` | 16 |
| `l2src/` | `L1\dev\l2src_sandbox\l2src` | 511 |

Excluded: `build/**`. Not copied: root `L1\l2src`, mixa stage snapshots, session notes. Nested `l2src/l1src` inside the sandbox tree is part of that snapshot and was copied as-is.

## Specs rewritten

`docs/L1_spec_ru.md`, `docs/L1_spec_en.md`, `docs/L2_spec_ru.md`, `docs/L2_spec_en.md` — from the copied sources, paired anchors (`lmx`, `type-by-range`, `pool`, `method-array`, `arena`, `message`, `thread`, `mailbox`, `own`, `call`, `child`, `copy-merge`, `implements`, `gc`). One primary definition per mechanism (L2); L1 states lowering and file mapping.

## Verification

- `python tools/check_docs.py` — run after these files; grammar/semantics/imported tests must stay untouched.
- L1 source still present: `C:\Nyasha_Planet\L1\l1src\l1trans.lm1`.
- No edit to `docs/LMX_semantics.ru.md` / `.en.md`.

## Unresolved (ask Codex/user; do not invent)

<a id="dual-l2src"></a>
### Dual `l2src`

Author 2026-09-20: copy the freshest tree into L1 **root**, commit and push. Done in lingvamyxa-l1 `2a60beb`: `L1/l2src` is now a mirror of `dev/l2src_sandbox/l2src` (511 files, 22 stale root-only units removed). Byte-identical with LMX `l2src/` and the sandbox. Mixa dirty files were not part of that commit.

<a id="handshake-flags"></a>
### Handshake flags

Author, `LMX_blog/2026-09-19.md`: atomic handshake flags belong with **multithreaded access in the parent arena**, “without synchronization”, like immutable constant branches.

Implementation in this snapshot: `running`, `success`, `handoff_ready` are `uint_fast8_t` fields of closed `LmxMsg` (`l2src/lmx_message.h.lm1`). Cross-lane handshake **cell** `alive` lives on parent-owned `LmxLink` in the **parent arena** (`lmx_thread.h.lm1`). Comments mention relaxed atomic load for `running`/`handoff_ready` where it matches a volatile load.

Fact vs intent are both recorded. Placement of the Message flags themselves is not rewritten to match the blog.

### Translator vs L2 source `implements`

`lmx_runtime_implements` walks a used-tree; it is not shown that every candidate admission of L3 executes receiving-expression unit tests. Full source `implements(varA varB Consumer)` is not claimed.

### L2→L1 translator

`l2trans.lm1` exists with a bounded `.lm2` subset (`l2src/README.txt`). Completeness not claimed.

### mixa parser gaps

deepseek measurements on port modules (`empty colon Frame`, `unsupported statement atom`, trailer, `@(TYPE) name`) — recorded, not turned into L1 rules except the `18bdab8` name form already in L1 spec as a measured parse fact.
