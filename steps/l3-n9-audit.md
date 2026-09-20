# L3 N9 audit (if/else/while) + graph identity norm

- request_ids: `LMX-L3-N9-AUDIT-20260920-07`, folded author guidance `LMX-GRAPH-IDENTITY-20260920-08`
- auditor: Grok Bot
- utc: 2026-09-20T10:52:00Z
- tree: `C:\Nyasha_Planet\LMX` HEAD `cd0b5e2` (contains `90aee57`)
- scope: read-only; no code edits; N4–N8 not repeated

Author identity priority (semantics.ru §1 / `steps/l3-receiver.md`, message 08): (1) physical refs first; (2) numeric only where a physical ref cannot be kept; (3) text never identifies ops. `L3_NODE` 32–38 must not be permanent ISA/semantic identity if role can be a physical ref; numeric OK as internal resolve/adapter optimization.

## Table (N9 checklist)

| # | Question | Evidence | Verdict | Minimal fix (owner: Grok) |
|---|---|---|---|---|
| 1 | Are `L3_NODE_*` 32–38 only an internal carrier, or wrongly claimed as binary L3 norm? | `l3_recv.h.lm1:14-23` (“Body-node codes for L3 v1”, “32+ are L3 forms”); `V1.md:36` lists IF=32/WHILE=33 as L3-03 encoding. Contrasts `docs/LMX_semantics.ru.md:70` and identity priority above. Runtime dispatch keys solely on `op\code` (`l3_exec.lm1:69-92`) with no physical role ref. | **FAIL** as permanent ISA claim; numeric tags acceptable only if docs/API reframe them as adapter-local | Stop documenting 32–38 as L3 semantic identity; prefer physical role/link (or resolve-once then follow ref). Keep numbers as private interpreter tags if needed. |
| 2 | Condition evaluated as expression once for `if`, re-checked before each `while` iter — not only a fixed int cell? | `l3_cond_int` (`l3_exec.lm1:51-59`) accepts only `LMX_KIND_PRIMITIVE` + `LMX_TYPE_INT` and reads `lmx_int_value_known`. `if` calls it once (`:83-85`). `while` re-reads slot 1 each iter (`:97`) but still only that int cell — no general expression eval per `#branches` (`semantics.ru:351,355`). | **FAIL** (int-cell only; not expression eval). While re-read of the same cell is necessary but not sufficient. | Eval condition as a graph expression (once for if; each while iter); keep int cell as a special case of that expression. |
| 3 | Tests distinguish taken/skipped branch & iteration by observable effect, not identical OK? | `l3_03_selftest.lm1`: if-true/return and if-false/else-return both expect `L3_OK` (`:88,:101`) — effect collapses through `l3_exec_run` RETURN→OK. if-false/no-else → OK (`:113`). while-0 then MATCH → `L3_UNSUPPORTED` (`:128`) — good skip observable. while-1/return → OK (`:140`). throw → UNSUPPORTED (`:148`). | **UNKNOWN→weak PASS** for while-skip; **FAIL** for if-true vs if-false-else both ending as the same OK without a distinct observable | Add side-effect cell or distinct status for taken vs skipped if-branch; keep MATCH-after-while-0 pattern. |
| 4 | return / unsupported propagate correctly? | if/while return `l3_exec_stmt`/`L3_RETURN` up (`:87,:103-104`); `l3_exec_range`/`run` propagate RETURN and non-OK (`:157-160`). MATCH/THROW → `L3_UNSUPPORTED` (`:75-76`). | **PASS** (static) | Keep; still needs runnable gate. |
| 5 | Runner reproducible from LMX root? | Re-measured: `bin/l1trans.exe --unit-root C:\Nyasha_Planet\LMX dev/l3_interp/tests/l3_03_selftest.lm1 …` → `cannot read import ../l3_exec.lm1`, exit 1. | **FAIL** | One documented translate+link+run command with correct unit-root/layout for `dev/l3_interp`. |

## Summary

N9 smoke in `90aee57` sketches if/else/while and rejects match/each/yield/finally/throw, but: (a) numeric node codes are framed as L3 v1 forms contrary to physical-ref-first identity; (b) conditions are fixed int cells, not expressions; (c) several fixtures only assert OK; (d) no independent runner. Fixes belong to Grok; no code changed in this audit.
