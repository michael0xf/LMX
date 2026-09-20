# L3 migration inventory (preparation only)

- request_id: `LMX-L3-MIGRATION-INVENTORY-20260920-38B`
- author: Grok Bot
- utc: 2026-09-20T15:45:00Z
- tree: `C:\Nyasha_Planet\LMX` HEAD `e8687f6`
- scope: **new file only**. No interpreter, translator, Fable, or DeepSeek code edits. No migration code authorized.

This inventory is dependency-ordered preparation. It does **not** start L1→L2→L3 conversion.

## Final target (recorded)

After the interpreter gate closes: all supported L1 becomes L2, then predominantly L3; the final self-build runs **on L3** with **explicit, justified L2 machine inserts**. Goal statement (no work plan): `dev/mixa_sandbox/FINAL_TARGET_AND_STAGE_IMPLICATIONS.md`. Self-build ownership and chain: `steps/core-self-build.md`. Receiver / interpreter contract: `steps/l3-receiver.md`. VM Path A order (MIR first): `include_languages/vm_porting_plan_en.txt`.

## Prerequisites before any migration batch (36B)

From `steps/l3-checkpoint-audit.md` and completion audit 36B — still open before batches:

| Blocker | Status | Owner hint |
|---|---|---|
| N5 data Structure ≠ body | FAIL | Grok (exec/fixtures) |
| N6 valued `return` | FAIL | Grok |
| N8 dirty-only publication | FAIL | Grok |
| Reproducible L3-01..04 runner | FAIL | Grok + docs |
| Generic activation plan + `lmx_walk` consumer | plan ABI in `steps/l3-activation-plan.md`; producer/consumer implementation separate | Fable / receiver |
| Exclusive Thread mode / no native fallback | explicit mode at `6f060c6`; `l3_interp` bind pending | turn-mode owners |

Do **not** open migration batches until those interpreter-gate items are closed.

---

## 1. Current L1 source (tracked units)

| Area | Tracked count (approx.) | Notes |
|---|---|---|
| `l1src/*.lm1` | 12 | Published translator / parser surface |
| `l2src/*.lm1` | 159 | Published L2 kernel snapshot |
| `dev/l2src_sandbox/**/*.lm1` | 71 | Live L2 sandbox + selftests |
| `dev/l3_interp/**` | admit/exec/path/recv/thread + tests | Interpreter in progress |
| `dev/mixa_sandbox/mixa_manager/**` | port modules (mtk_*, mixa_*) | Port gate measured separately |

L1 self-build line is independent of the interpreter gate (`steps/core-self-build.md`: PASS seed chain reported; portable loop still open).

---

## 2. Complete L2 replacement targets

Units whose supported semantics already have an L2 kernel counterpart and should become **full L2** before any L3 preference:

- L2 Message / Thread / own / pool / chars / call / value_owned (live gate 212/212 at recent heads).
- Port modules that compile cleanly under `build_mixa` once translator gaps below are closed — they remain **L2-shaped L1 text**, not L3, until interpreter gate + migration policy open.

No mass rewrite in this ticket.

---

## 3. Predominantly L3 candidates

After interpreter gate + L2 replacement of supported L1:

- Graph walk / callable body execution currently sketched under `dev/l3_interp/` (`l3_exec`, `l3_admit`, role/path).
- Future managed Path B printers (JVM / wasm-gc / Lua / CIL) per `include_languages/vm_porting_plan_en.txt` items 4–7 — **not** Path A MIR/WASM-linear/RISC-V.

---

## 4. Unavoidable justified L2 machine inserts

Keep explicit (name + reason); do not leave by inertia:

- Seed / external C toolchain for bootstrap (`tools/run_self_build.ps1` and portable `.sh`/`.bat` twins).
- Platform FFI already behind `c.` doors (Win32 backend of mixa, etc.).
- Any L3 Path A host that still consumes Translator-L1 C99 (MIR/WASM-linear/RISC-V) — L2 runtime (arenas, FIFO turns) runs **on** that L1 VM.

Exact insert list is deferred to migration batches after gate closure.

---

## 5. Existing tests

| Suite | Role |
|---|---|
| `dev/l2src_sandbox` + `tools/build_l2src.ps1 -Run` | Live L2 gate |
| `dev/l3_interp/tests/l3_0{1,2,3,4}_selftest.lm1` | Interpreter checkpoints (runner still FAIL) |
| `dev/mixa_sandbox` + `tools/build_mixa.ps1 -Run` | Port gate (RED 9 language/layout; see §7) |
| L1 self-build 8/8 | Seed chain (`steps/core-self-build.md`) |

---

## 6. Missing L3 contract (inventory, not design)

Still missing or incomplete for safe migration (details live in linked docs, not duplicated here):

- Valued return + data≠body + dirty-only proofs (`steps/l3-receiver.md`, audit table above).
- One reproducible root runner for L3-01..04.
- Activation-plan **producer** + `lmx_walk` **consumer** wired to `LmxCallable.header` (ABI text: `steps/l3-activation-plan.md`).
- `l3_interp` bind to exclusive Thread mode.

---

## 7. DeepSeek nine unowned translator / layout gaps

**Source of the nine:** DeepSeek goal note `dev/mixa_sandbox/FINAL_TARGET_AND_STAGE_IMPLICATIONS.md` — port `RED 9 of 363`, all nine called translator gaps (`mixa_event_source`, `mtk_array`, `mtk_int_array`, `mtk_long_array`, `mtk_int_table`, `mtk_table`, `mtk_bytes` + two headers), **unowned** as of 2026-09-20. Same note: `mixa_event_source` is **probably not language** (import layout).

**Evidence gate (frozen logs, do not invent):** `C:\Nyasha_Planet\L1\dev\mixa_sandbox\build\20260920_061946\logs\` (same errors in `20260920_055129`). Working tree copies under `LMX/dev/mixa_sandbox/mixa_manager/` match paths below.

**Emit sites for shared language classes** (for owners fixing translator, not port):

| Class | Emit |
|---|---|
| `empty colon Frame is not allowed` | `l1src/parser.lm1` ~4479–4499 (and sandbox twin) |
| `unsupported statement atom` | `l1src/l1trans.lm1:3487` |
| `parser node already has a trailer` | `l1src/parser.lm1:3380` |
| `declaration expects a name` | `l1src/l1trans.lm1:3294,5901,5910` |

### 7.1 Split: layout vs language

| # | Ticket id (assignable) | Path | Exact error (20260920_061946) | Queue |
|---|---|---|---|---|
| 1 | `LMX-MIG-GAP-LAYOUT-mixa_event_source` | `mixa_manager/mixa_event_source` (unit **and** header logs) | `cannot read import l2src/lmx_message.h.lm1` | **Layout / import resolution** — **not** language queue |
| 2 | `LMX-MIG-GAP-mtk_array` | `mixa_manager/mtk_array.lm1:108:5` | `declaration expects a name` | Language / translator |
| 3 | `LMX-MIG-GAP-mtk_int_array` | `mixa_manager/mtk_int_array.lm1:197:5` | `unsupported statement atom` | Language / translator |
| 4 | `LMX-MIG-GAP-mtk_long_array` | `mixa_manager/mtk_long_array.lm1:190:5` | `unsupported statement atom` | Language / translator |
| 5 | `LMX-MIG-GAP-mtk_int_table` | `mixa_manager/mtk_int_table.lm1:120:5` | `declaration expects a name` | Language / translator |
| 6 | `LMX-MIG-GAP-mtk_table` | `mixa_manager/mtk_table.lm1:122:5` | `declaration expects a name` | Language / translator |
| 7 | `LMX-MIG-GAP-mtk_bytes` | `mixa_manager/mtk_bytes.lm1` (parse 11 at 476:1) | `parser node already has a trailer` | Language / translator |
| 8 | `LMX-MIG-GAP-mtk_bytes_h` | `mixa_manager/mtk_bytes.h.lm1:44:46` | `qualifier parameter has extra fields; write const: … qualifier last` | Language / translator (header of the pair) |
| 9 | *(second header in the RED-9 count)* | `header_mixa_event_source` | same import error as #1 | **Fold into ticket #1** (layout); counts as the second “header” in DeepSeek’s nine |

Owner: **unassigned** (DeepSeek note). Do not start migration code from these tickets; each is independently assignable for a **translator or layout fix** only.

**Note:** Older gate `20260920_031102` also RED on `mtk_key.lm1:11:5` (`declaration expects a name`). Not in the FINAL_TARGET nine; list only if a later frozen gate still shows it.

**Note:** Class `empty colon Frame` appears in DeepSeek’s four-class summary (`lmx_uds_claude.md`) but did **not** appear in the 20260920_061946 mtk FAIL lines above.

---

## 8. First safe batch (after gate closure only)

When N5/N6/N8 + runner + plan consumer are green:

1. Claim **one** small L2-complete unit with existing selftest (prefer already-GREEN L2 sandbox module).
2. Do **not** touch Fable/`lmx_walk`, DeepSeek self-build, or unowned translator gap files in the same batch.
3. Path A smoke (separate from language migration): earliest uncovered item in `include_languages/vm_porting_plan_en.txt` is **MIR** — build/load smoke only, claim exact files, no other owners.

This inventory does **not** authorize that batch.

---

## Acceptance for this ticket

- [x] Single new file `steps/l3-migration-inventory.md`
- [ ] `python tools/check_docs.py` exit 0
- [ ] `git diff --check` on staged path exit 0
- [ ] Commit + push **only** this file
- [ ] Codex callback `LMX-L3-MIGRATION-INVENTORY-20260920-38B`
