# CODE-DATA-SPLIT -188 — FABLE-GROKBOT-CODE-DATA-SPLIT-20260925-188

Норма: next_core §3 п.1–4, §4 Q29 (b7b7b99); Opus proposal steps/code-data-split-189.md § re-entry (Grok c3). k.2 = f86717 tip. Order: **k.3 → -186 → -187 → -170 c2 (D-63 first)**.

## Done (k.2)
OWN/SET/PUT/PUT_OF → graph cell; store_slot; checkpoint no-op; LmxWalkOwn={from}; mutant lmx_walk_off_instance_selftest. lmx_own/lmx_dirty stay to Opus c3b.

## Model (author)
(M,M)/(R0,R0); code immutability = no write to ops/literals/
ative. Q28: fresh only on re-entry/explicit, frame-local; M\x outside = fields of M. Q29: one cell at declaration; [N] = declarations.

## k.3 plan (concrete; GO waits)

### Sites today
- lmx_call_prim(arena, callable, refs, nargs, dest, out) :177 — entry(callable,…) owner=occurrence (lmx_call.lm1). Callers: l2trans ~16520, lmx_call_selftest.
- Walker CALL [call, M, arg…] :948 — callee child1, args from 2; native entry(callee,…) / lmx_walk_activate (lmx_walk.lm1).
- Fixtures: r(..., OP_CALL, 2U) + 
ef(n,1U,M) (walk_selftest / off_instance) — **no data operand yet**.
- Copier classify: lmx_graph_copy_owned + lmx_range_classify / domain kind+type — reuse for lmx_fresh child rules.
- Char 0: lmx_char_cell(arena,0) after lmx_chars_init (lmx_chars.lm1). D-63 = char table vs Array — fable order: after -186 in -170c2; fresh char cells use intern path (not Array).

### Commits (each + gate after GATE OK)
| # | Scope | Selftests / mutants | Harness |
|---|-------|---------------------|---------|
| **k.3a** | lmx_fresh(arena,code)→Lmx: parent=code.parent, len=code.len; child0 by addr (until k.4); else by arena class (num→0, char→interned0, ptr→null same type, Array→fresh same etype/len, control-body Struct parent=code→recurse); terminal callable/METHOD refs by addr; refuse unclassified; NULL→caller X1 | lmx_fresh_selftest.lm1: numeric/char/ptr/array/nested body; mutant guess unclassified→RED; shared child0 identity | build +1 selftest; harness 0 |
| **k.3b** | lmx_call_prim(arena, code, data, refs, nargs, dest, out): dispatch on code (child0 now); entry(data,…) owner=data=self, node=data.parent; trampoline builds nothing. Update call_selftest + note Opus c3a must emit new arity | lmx_call_selftest pass data=M; mutant owner=code when data≠code→RED | may RED until Opus c3a; Debt rows on lmx_call_prim arity if any |
| **k.3c** | New role FRESH (OP_COUNT bump); CALL=[call, code, data, args…]; in-place data=code Structure; re-entry data=[fresh, code]. Walker eval data operand; activate/native use that data as self. Fixtures: migrate all hand CALL nodes; recursion fresh instance; after return M\x = M fields (not frame instance) | extend walk_selftest summer/publisher; new lmx_walk_fresh_call_selftest; mutant CALL without data child / flag-word→RED | harness rows with walk CALL debt may need data operand in emitted trees (Opus); eternal rows unchanged if native emit lands with c3a |

### Risks / open Q
1. **Emission:** Opus owns l2trans CALL/data/lmx_fresh emit (189 c3a). Grok migrates kernel + hand fixtures; land k.3b/c so harness can go RED until Opus, or stage behind #/compat? Prefer: k.3a green alone; k.3b+c coordinated GO with Opus or accept harness Debt until c3a.
2. Walked activation: pass data into lmx_walk_activate as \self/node fields target — confirm OWN writes data not code when data≠code (re-entry).
3. D-63: fresh Array of CHAR elements before table fix — avoid in k.3a fixtures; use scalar char via lmx_char_cell only.
4. lmx_call0 / walk hook still nullary on occurrence — leave until k.4 native word?

### After k.3
-186 PUT_REF (no instance slot); -187; -170c2 D-63 first. k.4: Lmx.native dispatch, drop child0 descriptor (with Opus c4).

Gate: GATE? → GATE OK. Texts ≤4 KB. No code until GO k.3.
