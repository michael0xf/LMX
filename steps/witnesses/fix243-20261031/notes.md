# Slice243 — the publication table (84), the walked entry's input width (86) and owner73c

Base main/origin `46a03c7f76f28a38f16e604851d358605da424c9`. Opus is the sole writer/build
(CODEX-OPUS-HANDOFF-20261031T004230Z); Codex consults. Author directive relayed by Codex
(CODEX-OPUS-84NEXT-20261031-USER, CODEX-OPUS-84START-20261031T075013Z): continue toward the short
L3+L2 bootstrap without waiting for review; one pipeline; finite bounds. Sources stay in ignored
`build2` variants; nothing in `selfbuild/` changes in this slice.

R=`C:/Nyasha_Planet/LMX`; P=`R/build2/codex_fix250generationchain01`. Every tool CLI runs from a
fresh private CWD; each launch is a text record `P/pins/<name>.command` run by the existing pwsh7,
detached through a launcher record where it is long. Producer 49c `P/cold-candidate49c/fe49c/l2trans.exe`
`F646DD07…`; BASE `P/cold-candidate48/full48/g2/frontend`.

## Generator84, FE84 and suites84

- Generator84 = source-generator62 + writer84 only (`variants/frontend84/tools/build.lm2` `3D4F4E71…`:
  writer83b + `frontend_useplan_names[149]` `lm_compiler_emit_publish_table`, 150 names), host GEN62:
  07:56:59Z → 08:09:03Z exit0, `cold-generator84/tool84-parts/lmxtool-tool.exe`
  `B9A2D857776B7BB3D8BFFFB386518CC05FB4F5D2651B77E4BD6ACBC5676A4D62`.
- Stage84 = stage83 (`source-candidate83b`) with Useplan84 `44A96E1D…`, Core84 `60421B9B…`, writer84
  (`source-candidate84.sha256`; [useplan84.diff](useplan84.diff), [core84.diff](core84.diff),
  [writer84.diff](writer84.diff)). ONLY Useplan84 + Core84, Lower83/Emit83 reused by exact manifests:
  08:09:36Z → 08:59:51Z exit0, `fe84/l2trans.exe`
  `DAC5C700F61FDADDF68FD8FA3F8DE455EDF4C0250F21FB46B50971E6DCC01DC3`.
- The publication table: one activation-local `[]: @(void) l2_pt N` filled where each own place is
  declared (`lm_compiler_emit_publish_table`, called from `emit_work_decl`); every group helper takes
  `@@: void l2_pt`, captures all slot handles before its first publisher and casts each element back
  to its exact address type; a boundary passes `(l2_program_arena, roots, count, l2_pt)`. Dirty-only
  publication, its moment, field order and snapshot semantics are unchanged.

Suites84 (`pins/suites84.command`, runner tool84, FE84 + production RT83 on stage83):

- held78 (`pins/held-forward78.tsv` `14171ED1…`): SUITE 1 rows, 0 failures; native/forced root0/root1
  each `V78 held-forward result=7 copied=2 original=1`; log `230EB1EF…`.
- owner73b: p.lm1 16969548 → 6805971 bytes, p.c 16543281 → 6371233 (forced 6375747). CC native
  09:00:21 → 09:04:58Z, forced 09:05:20 → 09:10:02Z, 0 errors (1132/1314 warnings), all four libraries
  and both programs link (PUBLISH-CALL-CODE-SIZE and SUITE-PROGRAM-CC-BOUND closed). Values: native
  root0/root1 exit28 after `V64 used-copy values partial-y=42->42` (log `CA1BB082…`); forced root0/root1
  `lmx: walk error: INVALID`, exit3, right after the first S81 line (log `8CE3331A…`). Suite log
  `A2099D7D…`, 4 failures.

## Two defects behind the owner73b values

Native exit28 is the fixture (OWNER73B-V64-STORE-REBINDS). V64 wrote
`lmx_walk_store_int(context_destination, partial_candidate, 2U, 44)` and read the old
`partial_y_cell`. `lmx_walk_store_int` takes a fresh cell and rebinds the slot
(`lmx_graph_ref_store_in`); the kernel selftest uses it for construction and `lmx_int_store_known`
for the in-place write (`dev/l2src_sandbox/tests/lmx_exec_projection_copy_test.h:63–84`, `:195`).
No ruling in `steps/` names V64. owner73c ([owner73c.diff](owner73c.diff),
`variants/runtime-callable73c/lib_owner.lm2` `04518DAC…`, row `pins/owner-values73c-callable-hidden55.tsv`
`560351C9…`) writes the partial copy's own y cell in place; the independence check is kept.

Forced INVALID is the walker (WALK-ENTRY-UNHANDED-INPUT-REFUSED), located by manual gdb from a fresh
CWD `P/gdb84-owner-forced-01`. `-ex` arguments lost their words under both shells (logs 01/02, my
invocation error); command files work: [03](records/gdb84-owner-forced-03.gdb) — `lmx_call_note_walk_fail`
← `lmx_walk_call_prim_dispatch` ← `lmx_call_prim_values` ← `l2_m19` (`run`);
[04](records/gdb84-owner-forced-04.gdb) entry markers — `dispatch refs=0 nargs=0`, `args_open`,
`snapshot`, then `FAIL st=1` (log `E69B15B4…`). The native owner calls hidden55's walked `lib_a_next`
through its model LibA (`fn: lib_a_next () int`) with nargs0; the method consumes its hidden input
`count` (ARG_ENTRY with a lexical fallback). `lmx_walk_entry_node` refused an ARG_ENTRY with
`index >= f\nargs` (stage83 `src/l2src/lmx_walk_values.lm2:1817`), and so would the ARG place and read.
The native trampoline of the same method takes nargs in [written, transport] and receives into the
full width, padded absent; the method's entry then takes the fallback (RU §12, a consuming method
forms its value from the same sources including its own lexical lookup).

Walker86 ([walker86.diff](walker86.diff), `variants/walker86/src/l2src/lmx_walk_values.lm2`
`892D8E36…` = kernel83 walker + the fix): `lmx_walk_args_open_values` takes the activation's input
width from the selected fn's own args part (part0: the written formals, then the hidden inputs;
module-internal `lmx_walk_input_width`, same physical access as the walker's vars/body parts). An
input the caller did not hand is the frame's zero input — absent, as one handed absent — so a
consumed hidden input takes its fallback at entry and a forwarded one goes on absent. A fn without an
args part widens nothing. The walker still does not check the trampoline's lower bound (the written
count); call binding provides it. The same change is applied to the coherent85 walker
([walker86-coherent85.diff](walker86-coherent85.diff): `1BA9A35B…` → `8B704430…`) for the 85 chain.

## RT86w3 and suites86w-03

Stage86w = stage83 with only the walker replaced, for an isolated check with FE84:

- prepare attempt 01 verified the stale `source-candidate83` and stopped at step02 (`tools/build.lm2`
  is writer83b since `candidate83b-writer`); attempt 02 used `source-candidate83b` → 8 steps exit0,
  `source-candidate86w.sha256` `5D50D85F…` differs from source83b in the walker line only.
- RT86w (label rt86w) stopped in `bld_headers`: `l1trans error: cannot read import
  l2src/l2_frontend_lower.h.lm1` (`l2src-l2_frontend_core.log`). RT83 had run after FE83, whose
  outputs stage83 holds and neither manifest carries. prepare-03 copied the seven FE83 headers
  (`candidate86w-fe83-headers.sha256` `F346DB87…`); RT86w2 then stopped on
  `l1src/l1_backend_scratch.h.lm1`; prepare-04 copied the remaining ten FE83 outputs
  (`candidate86w-fe83-outputs.sha256` `CC517DCE…`). After that, stage86w and stage83 list the same
  names in `src`, `src/l1src`, `src/l2src`, `tools`, and differ in bytes only in the walker's
  `.lm2/.lm1/.h.lm1`. These were my stage-recipe errors, not runtime defects. Launchers 01–03 are kept.
- RT86w3 (host tool83b `36C2F7E1…`): 09:43:34 → 09:47:05Z exit0, `rt86w3/driver.o`
  `B3063DBA27F6850C92F9009DCEBC58A6F4AD8862E54F7E236C2B09DDC35E2306`, `driver-observe.o`
  `FEEBEC32024C68514BAB00C276334520BA9572F714DFEF918079046241533D82`, record `A98E1BFA…`. The
  regenerated `lmx_walk_values.h.lm1` differs from RT83's only in the `l2_pNN_` parameter names
  (one more function precedes them); the helper is not declared.

Suites86w-03 (`pins/suites86w-03.command`, runner tool84, FE84 + RT86w3 on stage86w):

- held78: SUITE 1 rows, 0 failures, all four modes `result=7 copied=2 original=1`; log `230EB1EF…`,
  byte-identical to the RT83 run.
- owner73c: SUITE 1 rows, 0 failures; native and forced, root0 and root1, all give 7 (log
  `A0FE3E2C…`). CC native 09:47:17 → 09:51:49Z, forced 09:52:16 → 09:56:56Z, 0 errors. The forced run
  logs are byte-identical to the native ones of the same root (root0 `F1AED85A…`, root1 `37DA3340…`;
  root1 differs from root0 only in the driver's check count): S81, V59, V63, V64
  `partial-y=42->44 upgraded=9/1/42 after=42 source=42 whole=43`, V69 nested box, V73 runtime
  callable good/bad, then the S81 refusals Thin 33 and Far 34 (`y=2`) and `seven taken by a formal M's
  body does not call: 3, called by plus1: 8`.

These are the two named rows only, on the production runtime. The coherent draft79 merge (chain 85:
generator85 → stage85 → FE85 → RT85 → held78, no-candidate79, computed-absence79, owner73c) is not
part of this slice; generator85 was built after these checks (10:09:41Z exit0) and is reported with
chain 85.

## Evidence and checks

[evidence.list](evidence.list) `8687E7F2…` names 111 originals under P (records, terminals, logs,
manifests, sources, outputs). The working G2 tool `P/cold-candidate48/full48/lmxtool.exe`
`A6D5EC40…` computed [evidence.sha256](evidence.sha256) `20DF3F97…` (MANIFEST 111/0) and verified it
(111/0), `P/pins/docs243.command`. `records/` holds LF copies (trailing blanks removed) of the
records, terminals, gdb command files and logs, suite/runtime logs and docs logs; the manifest pins
the raw originals (the docs check log below by its own hash).

The ordinary full docs check with the same tool (`P/pins/docs243-check.command`, fresh empty
`P/docs243-out-01` created first; DOCS-CHECK-PRIVATE-OUT-SILENT stays open), the slice files in the
Git index: 10:11:56 → 10:12:23Z exit0, log `106B3F50…`: `OK: 35 paired semantic chapters,
14 implements cases, both source snapshots; 27 paired grammar sections, 44 verbatim source excerpts,
615 imported files, links, exact semantic opening; line endings LF in the index for all 12314 tracked
files`. `git diff --cached --check` is clean. No broad corpus or FULL run belongs to this slice.
