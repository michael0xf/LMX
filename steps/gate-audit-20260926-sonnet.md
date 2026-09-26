# §GATE read-only audit — dead helpers / duplicate discard-call paths / residual c.puts,c.array (Sonnet, 2026-09-26)

Read-only. No code touched. Base: `main` @ `dffaa4b` (before Opus's `c955f24` VoidArray migration landed;
none of the findings below concern array layout, so the migration does not change them).

## 1. Dead helpers in `dev/l2src_sandbox/l2trans.lm1`

Method: extracted every top-level `fn:`/`sub:` name (707 definitions), counted whole-word occurrences of
each name across the whole file. A definition with count 1 (only its own `fn:`/`sub:` line) would be a
function with zero call sites anywhere, including recursively.

**Result: 0 names with count ≤ 1.** Every defined helper is called from at least one other place. Spot-checked
the 49 names with count == 2 (definition + exactly one other mention): in all 49 cases the second mention is
a real call site (verified line-by-line, not a comment or a `prototype:` forward-declaration) — e.g.
`l2_convert_body:6140`, `l2_pap_store:26031`, `l2_t7_take_sig:22433`. None of the 49 is dead code; each is a
helper used from exactly one call site, which is ordinary decomposition, not a leftover.

**Conclusion: no dead top-level helper functions measured in `l2trans.lm1` today.** This matches the file's
own running practice of removing a helper the moment it is found to have zero references (D-08's
`l2_uses_is_control`, the four `l2_c_header_*` scanners removed at `3e2cefb`, the `l2_own_new_zero` family's
dispatch branches removed at -155 commit 3 — all left only a "WHAT STOOD HERE AND IS GONE" comment, no dead
function body).

## 2. Duplicate discard/call paths next to the unified body dispatch

There are two discard-checking functions, `l2_check_discard` (`:15372`) and `l2_eval_discard` (`:24138`) —
this is **not** duplication: they belong to the translator's two separate passes (semantic check vs. C
emission), exactly like the existing `l2_colon_check_assignment`/`l2_colon_simple_ty` pair or
`l2_check_body`/`l2_emit_...` in general. Each has exactly one call site inside its own pass's single,
long if-chain dispatch (`l2_check_body` around `:15450`, the emit-side body walker around `:24260`–`:25196`
— the same sequential `l2_frame_head(stmt, "if") = 0 && l2_is_char_decl(stmt) = 0 && ...` condition chain
gates every branch of that dispatch, confirmed by reading `:25160`–`:25210`). `l2_eval_discard` is called
twice within that one dispatch (`:25192` for a call-headed statement, `:25196` for a known-`c.*`-headed
statement) — two branches of the *same* unified mechanism reaching the *same* helper, not two mechanisms.

**Conclusion: no duplicate old discard/call path found next to `l2_eval_discard`.** The single unified
dispatch this GATE item asks for already exists; the "old" pre-`FABLE-OPUS-DISCARD-20260924-147` shape (the
plan text names it) has already been removed to the point of leaving no reachable duplicate.

## 3. Residual special-case `c.puts` / `c.array` (translator, docs, fixtures, corpus)

- `dev/l2src_sandbox/l2trans.lm1` (and its `l2src/` twin, byte-identical on this axis): 4 hits total, all
  four are comments documenting the removal (`:5474`–`:5479`, `:9766`) — no code. `l2_simple_puts_main` and
  `l2_array_local`: 0 definitions anywhere in either tree (only mentioned in historical `steps/`/`docs/`
  provenance and in the two stale `.bak` files, item 4 below).
- `dev/l2src_sandbox/tests/*.lm2` and `l2src/tests/*.lm2`: 1 hit, `unit_native_activation.lm2:1`, a comment
  ("was c.array + c.sizeof") documenting the migration, not live syntax.
- `docs/LMX_grammar.*.md:2192`: `c.puts: "Hello C"` is a grammar *example* of the raw `c.*` door syntax, not
  a name-special description — expected and correct.
- `docs/implementation-notes.en.md:39` / `.ru.md:39` (**stale, flagged for correction**): "`l2_array_local`
  accepted a narrow `c.array` form: ..." is written in a way that does not mark it as removed, unlike the
  neighboring bullet at `:27` (VoidArray) which explicitly says "**The code migration is implemented**
  (`c955f24`, ...)". `l2_array_local` was deleted at -155 commit 4 (`next_core_tasks.md` §7a). This bullet
  should get the same "implemented"/"removed" annotation, or be moved out of the present-tense inspection
  list — as written it reads as still-current, which is exactly the "противоречивые docs" the GATE item
  warns about. Not fixed here (read-only); a one-line annotation in both language files is the fix.

## 4. Tracked-tree cleanliness — stale backup files (new finding, not in the original three bullets but under "Tracked tree и ownership чисты")

`git ls-files` confirms both are **tracked**, not just present on disk:

- `dev/l2src_sandbox/l2trans.lm1.bak_20260918_193500` (634,256 bytes, mtime 2026-09-18 16:33)
- `l2src/l2trans.lm1.bak_20260918_193500` (634,256 bytes, identical size)

Neither is referenced by any `.ps1`/`.py` tool (`grep -rn "l2trans.lm1.bak"` across tools/build scripts:
0 hits). These are an 8-day-old snapshot of `l2trans.lm1` before hundreds of subsequent commits, sitting in
both trees, committed to git. This is exactly the "tracked tree чист... нет чужого WIP на owned paths" GATE
bullet, and the twin-check bullet too (`diff -rq dev/l2src_sandbox l2src` would report these as a spurious
"pair" that isn't source). Not deleted here (read-only, and it is not certain whose these are — could be
intentional per-agent history someone still wants); flagged for the ticket to decide TAKE-and-delete vs.
leave-with-reason.

## Summary against the §GATE checklist bullets (`next_core_tasks.md` §GATE)

| Bullet | Status |
| --- | --- |
| Нет name-special/allowlist/header-scanner/hidden-registry/shim/fallback | Already measured clean at `3e2cefb`/`218709f` (unchanged since) |
| Нет L2 special semantics для `c.puts`/`c.array` | Confirmed again here (§3): 0 live hits, only historical comments |
| Нет дублирующих discard/call путей рядом с `l2_eval_discard` | Measured here (§2): none found, one unified dispatch confirmed |
| Нет мёртвых helpers | Measured here (§1): 0 of 707 top-level functions with zero call sites |
| Нет скрытого fallback | Not separately re-measured this pass; no candidate surfaced by §1/§2 |
| Tracked tree и ownership чисты | **New gap** (§4): two tracked 634 KB `.bak_*` files, unreferenced |
| Source inventory: удалённые helpers — ноль ссылок | Confirmed by §1's exhaustive count |
| Docs/tests не противоречат | **One stale bullet found** (§3, `implementation-notes.*:39`) |

Two of the eight bullets are not fully green: the tracked `.bak` files (§4) and the one implementation-notes
bullet (§3). Neither is a code defect — both are cleanup-only, no gate/harness impact, no mutant needed. Not
fixed in this pass per the read-only scope of this audit.
