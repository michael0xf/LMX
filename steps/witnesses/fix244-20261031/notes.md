# Slice244 — the coherent draft79 line built (85 → 85b → 87): two fixes, three OPEN items

Base main/origin `764f67acd07390ff37b63376a0546b4ba3b2bcf5`. Opus sole writer/build; Codex consults
(answers CODEX-OPUS-243-20261031-REVIEW, CODEX-OPUS-85FIND-20261031-ANSWER). Sources stay in ignored
`build2` variants; nothing in `selfbuild/` changes in this slice.

R=`C:/Nyasha_Planet/LMX`; P=`R/build2/codex_fix250generationchain01`. Every tool CLI runs from a
fresh private CWD; long launches go through detached launcher records (`P/pins/*-detached.command`).
Producer 49c `P/cold-candidate49c/fe49c/l2trans.exe` `F646DD07…`; BASE `P/cold-candidate48/full48/g2/frontend`.

## Generator85 and stage85

- Generator85 = source-generator62 + writer85 (`variants/coherent85/tools/build.lm2` `965F01F6…`) and the
  56 bridge headers; GEN62 host: 09:58:17 → 10:09:41Z exit0, `cold-generator85/tool85-parts/lmxtool-tool.exe`
  `D7D723905DD745E164AEA2DB343C0CD8FAF07C42141A7275D815A7CC657F66A1`.
- Stage85 = source84 + coherent85 (`pins/coherent85.list`: draft79 Useplan/Lower/Core/Emit/walker/
  ValueOwned/writer merged three-way with 82/83/84 and walker86; implements83), `source-candidate85.sha256`
  `7663D5FC…`; reuse = the 80b-era set without the four frontend modules.

## FE85, RT85/RT85b and the four rows

- FE85 (Useplan/Lower/Core/Emit, host tool85): 10:13:38 → 12:48:10Z exit0, `fe85/l2trans.exe`
  `D3D49F3B9694CB1441F5534A414DB391275CEAEBFAB3FAFA03EBA15E7A12C4E1`.
- RT85 (label rt85) stopped translating the walker: `lmx_walk_values.lm2:467:13: assignment value has
  unknown type` (atom=value) — draft79 `lmx_walk_graph_value_ref` returned `value\ref` of a by-value
  LmxWalkValue ([walker85b.diff](walker85b.diff): the file's own cast form, `8B704430…` → `D04DEC9D…`).
  `candidate85b-walker.command` replaced only the walker (`source-candidate85b.sha256` `7292F4F3…`);
  RT85b 12:53:42 → 12:57:23Z exit0, `rt85b/driver.o` `1ECED7AF…`.
- Suites85-02 (FE85 + RT85b), all fast failures: held78 CC `p.c:1128 'l2_wv8_copyl2_wv8_copy' undeclared`;
  owner73c `lib_m native` CC the same (`l2_wv0_pyl2_wv0_py`, …); no-candidate79 L2 `split call not
  supported yet: Code assigns p, a reference, whose data place is not admitted yet`; computed-absence79
  L2 `unsupported body` (atom=return).

The doubled name is draft79 Lower `lm_compiler_own_work_store_value`: `wv` is filled for every type
(the new memcpy of the working value after the store) and again in the pointer branch; the builder
appends. Lower87 ([lower87.diff](lower87.diff), `987E4578…` → `3965C9C2…`) no longer refills it. The
Core three-way merge (base Core80 `478F6F2E…`, draft79 `1C4B35A8…`, Core84 `60421B9B…`) conflicts only in
`emit_work_decl`'s tail; outside it the merge result equals coherent85 byte for byte, so no draft79
Core code was lost. Codex: (b) and (c) are unfinished original draft79 connections, not merge loss.

## Chain87 (ONLY Lower87)

- Stage87 = source85b + Lower87 (`source-candidate87.sha256` `3D3E8137…`), reuse = the 80b-era set +
  FE85's Useplan/Core/Emit sources and outputs (289), invariants 139.
- FE87 (host tool85): 13:02:58 → 13:30:58Z exit0, `fe87/l2trans.exe`
  `2E08BE9092F6DEC888886818D6D3724B863D3AC0E5DE85A2C39ABAA620B11296`. RT87 13:30:59 → 13:34:44Z exit0,
  `driver.o` `1ECED7AF…` and `driver-observe.o` `927263F5…`, byte-equal to RT85b (same kernel sources).
- Suites87: held78 SUITE 1 rows, 0 failures, all four modes `V78 held-forward result=7 copied=2
  original=1` (log `230EB1EF…`, byte-equal to the FE84 runs); no-candidate79 and computed-absence79
  the same L2 refusals (OPEN: SPLIT-POINTER-PLACE-NOT-ADMITTED, DRAFT79-BARE-RETURN-CHECKER, with
  Codex's routes in the ledger); owner73c — a new regression versus FE84 + RT86w3: native and forced,
  root0 and root1 identical, `V63 copy failure=11 status=3` → exit28 (log `C95C9608…`).

## Locating the V63 regression

Manual gdb from a fresh CWD on the FE87 native program (`pins/gdb87-owner-v63-0[1-6].gdb` with their
logs). The only status-3 store hit is `lmx_copy_value` +1440 ← `lmx_copy_reference_fill` ← `lmx_copy_value`
← `lmx_copy_process` ← `lmx_copy_run` ← `lmx_graph_copy_many_profiles_staged` ← `lmx_graph_copy_owned` ←
`l2_m15` (try_dynamic_m). The refused value is a thread-stack address (run 06: v=0xfb979ffaf8,
rsp=0xfb979eb900), a raw reference reached as a pointee. The referent lookups are not the cause (all 7
non-null `lmx_value_context_cell_in` resolved; a context store with a stack-valued referent — 0 hits).
The kernel barely changed between RT86w3 and RT87; the fixture's native code did: FE84 stores own
`owner_address` with context 0, FE87 (draft79 full receiving) with the source field's full Value
context through `lmx_walk_value_store_with_writer`. Runs 07–09 record the last
`lmx_copy_reference_fill` source cell before the refusal and ask the kernel about it: type 1125
(`LMX_TYPE_POINTER_BASE` 1024 + 101, `@: c.LmxArena`), domain kind 1, source name bytes `61 72 65 6e 61`
= `arena` (length 5) — an own field like `@: arena c.LmxArena (cast: (@: c.LmxArena) c.l2_call_arena)`
in `try_dynamic_m` (`lib_owner.lm2:211`), whose pointee is the activation's arena on the thread stack. On
the 87 line the V63 root reaches that cell; the parent edge and the 84→87 producer of the reaching field
are not pinned yet (DRAFT79-OWNER-POINTER-CONTEXT-STACK-POINTEE, OPEN).

## Decision for the bootstrap

Codex (CODEX-OPUS-87V63-20261031-ANSWER): source87 does not meet its own precondition (owner73c regresses),
so it stays OPEN evidence; the whole short bootstrap runs on the green line — `source-candidate84.sha256`
`647C5268…` with only `src/l2src/lmx_walk_values.lm2` replaced by walker86 `892D8E36…` (the FE84 + RT86w3
pair where held78 and owner73c gave 7 in all four modes), G0 tool84 `B9A2D857…` (writer84, byte-equal to
that line's writer), previous FE 49c with its backend and libc, BASE full48/g2/frontend, a fresh
source-only stage, the ordinary smoke list, a real G0 → G1 → G2 chain with the runtime rebuilt from the
new stage. The V63 edge is an ownership boundary, not a blanket fix: neither suppressing contexts of
`c.*` right-hand sides nor letting graph copy accept stack memory; draft79 continues on its own line.

## Evidence and checks

[evidence.list](evidence.list) `BF60D74B…` names 135 originals under P (records, terminals, logs,
manifests, sources, outputs, the gdb command files and logs, the three question files to Codex). The
working G2 tool `P/cold-candidate48/full48/lmxtool.exe` `A6D5EC40…` computed
[evidence.sha256](evidence.sha256) `69757EC7…` (MANIFEST 135/0) and verified it (135/0),
`P/pins/docs244.command`. `records/` holds LF copies (trailing blanks removed) of the records,
terminals, gdb command files and the smaller logs; four large originals (the gdb 02 marker trace, the
gdb 03 disassembly, the two FE85 CC logs) are pinned by hash only, their decisive lines are quoted above.

The ordinary full docs check with the same tool (`P/pins/docs244-check.command`, fresh empty
`P/docs244-out-01` created first), the slice files in the Git index: 13:55:23 → 13:55:38Z exit0, log
`58C8EF42…`: line endings LF in the index for all 12400 tracked files, links, paired chapters and sections.
`git diff --cached --check` is clean. No broad corpus or FULL run belongs to this slice.
