# L3 checkpoint audit (N4–N8) — independent, read-only

- request_id: `LMX-L3-AUDIT-20260920-03`
- auditor: Grok Bot (agent «Привет ты в git-е работаешь?»)
- utc: 2026-09-20T10:25:00Z
- tree: `C:\Nyasha_Planet\LMX` HEAD `ef9882f`
- basis: `steps/l3-receiver.md`, commits `582baa9` (L3-01) and `90b0b7c` (L3-02), current `dev/l3_interp/*`
- scope: no code edits; no LOCKED/OWNED_BY files touched (none marked under `dev/l3_interp`)

Codex task mapping: (1) return keeps its argument → N6 value path; (2) Structure data not executed as body → role/data vs body; (3) dirty/own checked substantively → N7/N8; (4) reproducible runner → infra.

## Table

| Criterion | File / symbol / test | Verdict | Next minimal action | Owner |
|---|---|---|---|---|
| **N4** callable M: slot 0 = `LmxCallable` (not METHOD as program sense) | `l3_exec_run` `dev/l3_interp/l3_exec.lm1:126-129` rejects METHOD; `tests/l3_02_selftest.lm1:65` expects `L3_UNSUPPORTED` for METHOD-only node | **PASS** (static + fixture intent) | Keep as regression; still needs a **runnable** gate (see runner) | Grok (fixtures) / whoever owns LMX runner |
| **N5** body = children of M from index 1, in order | `l3_exec_run` starts body at index 1 (`l3_exec.lm1:132`); nested Structure without role falls into `l3_exec_range(..., 0)` at `:86` | **FAIL** for “data ≠ body” | Add role/tag so data Structure is not walked as statements; negative fixture `[data…]` must not exit outer body | Grok |
| **N6** `return:` is a body node; void **and** one value; compute → dirty-only → exit | `LMX_OP_RETURN` at `l3_exec.lm1:66-69` returns `L3_RETURN` and never reads further slots; `mk_return` builds 1-slot stmt (`l3_02_selftest.lm1:22-32`) so valued return is untested | **FAIL** (argument silently dropped / unobserved) | Implement valued return or explicit `L3_UNSUPPORTED` if value present; add fixture that observes the value | Grok |
| **N7** call M; own ≠ input; recursion = separate activations | Nested callable fixture `l3_02_selftest.lm1:80-98`; API `l3_exec_run(arena, node)` has no inputs/result channels (`:110`); no per-activation own stack beyond locals in one run | **UNKNOWN→FAIL** as proof | Narrow claim or add fixtures: distinct own state across nested call, named input ≠ own, both exit paths | Grok |
| **N8** dirty-only; clean not published; no flush-all | Checkpoint only on RETURN (`l3_own_checkpoint_all` `:67`); **no** `lmx_own_write` in exec path; N8 selftest only asserts `cell==1` after run with no body write (`:100-116`), `cell2=99` unused | **FAIL** (not a substantive dirty-only proof) | Drive a dirty write in-graph; assert clean own unchanged and dirty published; forbid flush-all | Grok |
| **Runner** reproducible from LMX root | Doc claim in `steps/l3-receiver.md:69`; re-measured: `bin/l1trans.exe --unit-root C:\Nyasha_Planet\LMX dev/l3_interp/tests/l3_01_selftest.lm1 …` → `cannot read import ../l3_recv.lm1`, exit 1 | **FAIL** | Document one working command + unit-root/layout so `l3_01`/`l3_02` translate+link+run; do not imply semantic PASS without it | Grok + docs owner |

## Notes

- Prior Codex static review in `steps/l3-receiver.md` (§ «Статическая проверка 90b0b7c») remains directionally correct; line numbers shifted slightly in current `l3_exec.lm1`, defects remain.
- L3-01 (`582baa9`) N1–N3 walk is out of this ticket’s four asks except as runner dependency; smoke fixtures still not independently executed here.
- This file is the only intended deliverable artifact; implementation stays with Grok per `l3-receiver.md:83`.
