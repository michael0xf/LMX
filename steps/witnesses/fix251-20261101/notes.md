# Slice251 — S1 of the optimization: the predef declaration index (tp110), measured against G1 full100's bytes

Base main/origin `3984006f` (slice249); slice250 is Opus's uncommitted WIP and stays untouched. Fable sole
writer/build by [to_fable.md](../../../to_fable.md) (handover CODEX-FABLE-TAKE-WRITER-20261101T1943Z-01, acceptance
FABLE-RESULT-ACCEPT-20261101T1946Z); Codex consults. Design: [optimization_design_from_fable.md](../../../optimization_design_from_fable.md)
(revisions 1–6 reviewed in `optimization_design_review_from_codex_20261101.md`). Sources stay in ignored `build2`;
nothing in `selfbuild/` changes in this slice.

R=`C:/Nyasha_Planet/LMX`; P=`R/build2/codex_fix250generationchain01`. Every tool CLI runs from a fresh private CWD; long
runs go through detached launcher records. Frozen tool `P/cold-full100/full100/lmxtool.exe` `E8150E60…` (G1 full100's
tool, host of every manifest/stage-copy/verify step and of `rebuild tool`); G1 frontend `P/cold-full100/full100/g1/frontend/l2trans.exe`
`BF6D713E…`; BASE `P/cold-candidate48/full48/g2/frontend`; RUNTIME-DIR `P/cold-full100/full100/g1/runtime`; gcc `920A4FC6…`.

## What S1 changes

`P/variants/tp110/src/l2src/l2_frontend_types.lm2` — `lm_compiler_predef_has_type` / `lm_compiler_predef_has_function`
answer from an index of the predef documents (`lm_compiler_pdx_*`, appended at the module end so the exported header
keeps its `l2_p<N>` numbering): FNV hash of the name, open addressing, parallel arrays (kind 1 struct / 2 fnptr / 3 fn),
built in two passes (count, insert) over the predef edges — fn/sub prototypes; struct/fnptr types through the predef
edges and the mapped `include: "*.lm1.h"` → `.h.lm1` edges — and valid while the predef table (`l2_pd_n`, base pointer)
is the one it was built from. `lm_compiler_pdx_kind(name, want)` also tries the `c.`-stripped suffix for kinds 1/2.
`P/variants/tp110/src/l2src/l2_frontend_intern.lm2` — `lm_compiler_pd_free` resets `l2_pdx_built`.
`P/variants/tp110/tools/build.lm2` — `decl_l2_frontend_state` writes nine new cells into the generated
`l2_frontend_state.lm1` (`l2_pdx_built/_n/_cap/_pd_n`, `l2_pdx_pd0`, `l2_pdx_key/_type/_fnptr/_fn`); frontend modules hold
no module-scope variables, so new state needs the tool rebuilt before a frontend part can be built.
Standalone check before staging: types.lm2 translated by the G1 frontend from a private copy of the stage tree, exit 0;
its header `l2_frontend_types.h.lm1` byte-equal to G1's (`0468457F…`), `l2_frontend_intern.h.lm1` too (`111518F8…`).

## The stage cold-tp110

`pins/tp110-prepare.command` (10 steps, all exit 0; terminal `pins/tp110-prepare.terminal.txt`): source-full100 staged,
the three tp110 files over it (`tp110-changed.sha256` `F761B6A5…`); `source-tp110.sha256` `FABE51AA…` differs from
`source-full100.sha256` `AA841167…` in exactly types, intern, build; the first reuse pair `tp110-reuse-inputs.sha256`
`61B7D509…` / `tp110-reuse-artifacts.sha256` `BACBE27D…` (135 generated files from G1's consumed-input snapshot) staged
and verified. Three later records completed the stage (each: manifest from the pinned source, every line checked against
the G1 record or manifest that pins it, stage-copy, verify, fresh CWDs):

- `pins/tp110-runtime-outputs.command` — the 46 `src/l2src` outputs of G1's runtime step (`g1/runtime/record.txt` `out`
  lines; 36 `lmx_*.lm1`, 10 `lmx_*.h.lm1`), manifest `tp110-runtime-outputs.sha256` `8414AE7A…`, VERIFIED 46/0. Needed
  because the first `rebuild tool` failed at the tool root's L1 step (`l1trans error: cannot read import
  l2src/lmx_walk_values.h.lm1`; `tool110-fail01`, `pins/tp110-tool-fail01.*`) — the same failure as candidate44's first
  `rebuild tool` on a fresh stage. The first attempt of this record itself failed on a PowerShell array literal (first
  step line without the leading comma is flattened); kept as `-fail01`.
- `pins/tp110-consumed-rest.command` — every file of G1's `consumed-inputs.sha256` (306, `F8826E9A…`) that the stage did
  not hold: 64, all generated, minus the three the part build regenerates (types.lm1, intern.lm1, state.lm1) = 61,
  manifest `tp110-consumed-rest.sha256` `66AAA95C…`, VERIFIED 61/0. Needed because the second `rebuild tool` passed L1 and
  failed in gcc (`fatal error: l2src/lmx_walk_values.lm1.h: No such file or directory`; `tool110-fail02`,
  `pins/tp110-tool-fail02.*`): the generated C headers of the kernel modules were not in the stage.
- `pins/tp110-reuse-02.command` — the second reuse pair for the part build: `tp110-reuse-02.list` = all 235 generated
  files of `consumed-inputs.sha256` minus the three regenerated minus the three tool-regenerated `lmxtool_methods.*`;
  `tp110-reuse-02-inputs.sha256` = `tp110-reuse-02-artifacts.sha256` = `BC9EF13C…`, VERIFIED 235/0. The first pair
  followed the candidate81 precedent, which built Lower itself and so listed no `l2_frontend_lower.lm1/.h.lm1/.lm1.h`;
  fe110 reuses Lower and must record it.

## tool110

`rebuild tool R P/cold-tp110 BASE G1-FE RUNTIME-DIR tool110 P/cold-tp110/tests/smoke-kernel225.tsv` with the frozen
tool as host (`pins/tp110-tool.command`, launcher `tp110-tool-detached.command`). Third attempt started 21:10:03Z
after the stage was completed; 21:10:03 -> 21:21:38Z, `RebuildExit 0`, `REBUILD tool 0 failures` (the tool is built;
starts and hashes a file as the host does, the same digest; runs the smoke list). `tool110/lmxtool-tool.exe`
`A5A9D82E…` (1841890 bytes), `lmxtool.lm1` `969B1F4E…`, `lmxtool.c` `D86AE173…`; records `pins/tp110-tool.terminal.txt`,
`pins/tp110-tool.log`, `cold-tp110/tool110/record.txt`. The two failed attempts are kept as `tool110-fail01/-fail02`
with their `pins/tp110-tool-fail0N.*` records (above).

## fe110

`build-frontend-part R P/cold-tp110 BASE G1-FE fe110 'l2_frontend_types,l2_frontend_intern' tp110-reuse-02-inputs
tp110-reuse-02-artifacts` with `P/cold-tp110/tool110/lmxtool-tool.exe` as host (`pins/tp110-frontend-part.command`,
launcher `-detached.command`). 21:22:53 -> 21:24:30Z, `PartExit 0`; both 235-file manifests VERIFIED before and
after. Outputs: `fe110/l2trans.exe` `63FD9E71…` (1548291 bytes), `l1trans.exe` `5813A29A…`, `l2_libc.o` `AF9FDAE3…`
(= G1), `frontend.c` `B5503E0A…` (10068207 bytes); `l2_frontend_types.h.lm1` `0468457F…` and
`l2_frontend_intern.h.lm1` `111518F8…` byte-equal to G1 (the exported ABI unchanged); `l2_frontend_types.lm1`
`EDF97255…`, `l2_frontend_intern.lm1` `0992AB7C…`; `l2_frontend_state.lm1` `C41B0A8E…` holds the nine `l2_pdx_*`
cells (lines 592-600). Records `pins/tp110-frontend-part.terminal.txt`, `pins/tp110-frontend-part.log`,
`cold-tp110/fe110/record.txt`.

## Measurement

`pins/tp110-measure.command` (parameters TP_MODULE TP_LINE TP_FE TP_LABEL TP_TRY; launcher `tp110-measure-detached.command`):
one L2→L1 translation of one frontend module by one frontend from the private tree `P/tp110-tree-01/src` (= G1's stage
before the emit step, manifest `perf251-emit-tree-03-all.sha256`, VERIFIED 211/0), argv = the `$` line of G1's
frontend record for that step (inputs the stage's hash-pinned files, so the unit prefix is G1's; the record re-checks
every `in` pin), outputs into `P/tp110-measure/<module>-<label>-<try>/`; wall from process start/exit, CPU user/kernel
(GetProcessTimes), peak working set and peak commit (GetProcessMemoryInfo), outputs' SHA-256 against the record's `out`
lines (same-as-G1 / DIFF). G1's own wall times (requirements doc, pipeline context): Lower 24.29 min, Core 43.24 min,
Emit 64.04 min.

| module | label | try | start (UTC) | wall s | cpu user s | cpu kernel s | peak WS MiB | peak commit MiB | page faults | outputs vs G1 |
|---|---|---|---|---|---|---|---|---|---|---|
| l2_frontend_lower | fe110 | 01 | 2026-11-01 22:10:55 | 791.2 | 787.9 | 1.0 | 288.2 | 325.0 | 101205 | `l2_frontend_lower.h.lm1` `6B63EB53…` same-as-G1, `l2_frontend_lower.lm1` `94C2297B…` same-as-G1 |
| l2_frontend_lower | g1 | 01 | 2026-11-01 22:25:54 | 1426.8 | 1423.4 | 1.4 | 286.3 | 325.2 | 106902 | both same-as-G1 (the same two hashes) |

Terminals: `pins/tp110-measure-l2_frontend_lower-<label>-01.terminal.txt` (+ `-detached.terminal.txt`); outputs
`P/tp110-measure/l2_frontend_lower-<label>-01/`. Ten gdb stack samples of Lower/fe110/01 (`records/samples/`): 5 in
the owning-method search of `lm_compiler_contract_source_begin_at` (`node_in`/`struct_has` over every method's source
tree), 3 in `lm_compiler_declaration` (the linear `l2_declarations` walk), 2 in `lm_compiler_head_source_node` (every
head-expression document searched by `node_in`); none in predef lookups. These three are the S2 targets (tp111).

## Carried to S4 (Codex, re-check of design revision 7; not a gate for S1)

- `lmx_array_grow_owned` is not among the `.lm2` of frozen source-full100 (only a generated header name): a future
  integration, not a verified hook. Work with the real path that changes a backing if one exists or enters the slice;
  add no growth feature for the review.
- `slot_owner` is weak: when a backing changes or leaves, and when the Array descriptor itself leaves, remove its old
  links even while the shared REF chunk lives; an old range must never be indexed from a new `holder\array.data`.
  Check against the actual lifecycle code.
- Focused S4 checks: several Arrays in one pool/chunk; code REF/deref write vs data write; a shared cell and the rebind
  of one place; drop/revert/bulk release of heads, `slot_owner` and records; termination on a cycle. No new test
  system, no whole-program analysis, no blanket native reset.

## S2 (tp111): node-keyed memos for the three sampled searches

Variant `P/variants/tp111/` = tp110's types/intern/build plus four modules patched over source-full100's text:
- `l2_frontend_context.lm2` — `lm_compiler_contract_source_begin_at`: the owning-method search (`node_in` over every
  method's source tree for a site passed with owner -1, which `contract_source_begin` always does) is memoized per site
  (`lm_compiler_omemo_*`: open addressing on the site address, int owner, -1 = none, -3 = no entry; valid for one method
  table, `l2_omemo_m_n` = `l2_m_n` it was filled under; a remembered owner is re-checked with `node_in` against its
  source before it is trusted, else searched again).
- `l2_frontend_resolve.lm2` — `lm_compiler_declaration`: the three list walks of `l2_declarations` by source node become
  `lm_compiler_dmap_get`; all four insertions (rb_declaration, the two find-or-create paths, the generic tail) call
  `lm_compiler_dmap_put`, so the map holds the newest record per source, the record the walk found first; a list emptied by
  `lm_compiler_application_free` (head 0) empties the map at the next use (`lm_compiler_dmap_sync`).
- `l2_frontend_views.lm2` — `lm_compiler_head_source_node`: the result per starting node is memoized
  (`lm_compiler_hmemo_*`); an empty head-expression list answers without the memo.
- `l2_frontend_values.lm2` — `lm_compiler_head_expression_dispose` empties the two address-keyed memos (head-source,
  owner) because the destroyed document's node addresses may be reused; the declaration map keys nodes that only die
  with the declarations themselves.
- `tools/build.lm2` — thirteen state cells `l2_hmemo_*`, `l2_dmap_*`, `l2_omemo_*` after tp110's nine.
Helper functions are module-internal (not in the `--machine` export lists), so no exported header changes. Two
language lessons on the way: a dedent of two levels needs a `---` tail cutter (parse error 13), and `node` is a word of
the language and cannot be bound (the helper parameter is `at`).

Stage cold-tp111: `pins/tp111-prepare.command` (10 steps; the first two attempts, staged before those two fixes, are kept
as `cold-tp111-try01/-try02` with `pins/tp111-prepare-*-try0N.*`): source-full100 + the seven tp111 files
(`tp111-changed.sha256`), `source-tp111.sha256` differs from source-full100 in exactly those seven; the 233 reused
generated files (`tp111-reuse.list` = tp110-reuse-02 minus the four regenerated L1 bodies plus fe110's
`l2_frontend_types.lm1` `EDF97255…` and `l2_frontend_intern.lm1` `0992AB7C…`) staged from cold-tp110, inputs and
artifacts manifests identical, VERIFIED 233/0.

Standalone translation of the four patched modules by fe110 (`pins/tp111-selfcheck.command`, try 03; CWD = the stage's
src, argv = G1's record line with the patched input, outputs to `P/tp111-selfcheck/<module>-03/`): all exit 0, all four
headers byte-equal to G1 (`values.h.lm1` `8D44D2BA…`, `views.h.lm1` `D063392B…`, `context.h.lm1` `F66863F9…`,
`resolve.h.lm1` `4EABD272…`), bodies differ as they must. tool111: `pins/tp111-tool.command` (frozen tool host),
22:54:16 -> 23:05:41Z, `RebuildExit 0`, `REBUILD tool 0 failures`; `tool111/lmxtool-tool.exe` `B68515D8…` (1841890 bytes),
`lmxtool.lm1` `F153662B…`, `lmxtool.c` `2B89C5C5…` (2505974 bytes, 310 more than tool110's: the thirteen cells). fe111: `pins/tp111-frontend-part.command` (host tool111, producer fe110, parts
values,views,context,resolve): 23:06:58 -> 23:08:51Z, `PartExit 0`, both 233-file manifests VERIFIED before and after;
`fe111/l2trans.exe` `3F174068…` (1552278 bytes), `l1trans.exe` `01FDB5BB…`, `l2_libc.o` `AF9FDAE3…` (= G1), `frontend.c`
`FDDFD805…` (10115510 bytes); the four regenerated bodies are byte-equal to the standalone translations (values
`60CE51D2…`, views `4E3F4212…`, context `FC0C01DE…`, resolve `C7082C42…`), their headers equal to G1;
`l2_frontend_state.lm1` `4B6B859B…` (16995 bytes) holds the 22 tp110+tp111 cells.

Measurement of fe111 (same record, same tree, same argv): Lower 23:09:49Z wall 136.4 s, CPU user 135.4 s, kernel 0.4 s,
peak WS 323.5 MiB, peak commit 327.6 MiB, page faults 96995, both outputs same-as-G1 (`6B63EB53…`, `94C2297B…`) — against
fe110's 791.2 s and the G1 frontend's 1426.8 s in the same context. Four gdb samples (`records/samples/sample-lower-fe111-*`):
`lm_compiler_contract_source_node` (dyn_local, contract_formal), `lm_compiler_own_at` via `call_head_method` in m2_close,
`lm_compiler_method_in_os` via `machine_validate` in emit_unit, and the emitter. Core/Emit with fe111: below.

| module | label | try | start (UTC) | wall s | cpu user s | cpu kernel s | peak WS MiB | peak commit MiB | page faults | outputs vs G1 |
|---|---|---|---|---|---|---|---|---|---|---|
| l2_frontend_core | fe111 | 01 | 2026-11-01 23:12:30 | 161.6 | 160.5 | 0.5 | 360.1 | 371.5 | 132967 | `l2_frontend_core.h.lm1` `180B95C2…` same-as-G1, `l2_frontend_core.lm1` `C04F5FFC…` same-as-G1 |
| l2_frontend_emit | fe111 | 01 | 2026-11-01 23:15:58 | 139.8 | 139.1 | 0.3 | 291.5 | 297.9 | 82361 | `l2_frontend_emit.h.lm1` `3A007B19…` same-as-G1, `l2_frontend_emit.lm1` `BC112CD8…` same-as-G1 |
| l2_frontend_useplan | fe111 | 01 | 2026-11-01 23:20:00 | 7.9 | 7.9 | 0.1 | 77.9 | 76.3 | 21497 | `l2_frontend_useplan.h.lm1` `AA712FD4…` same-as-G1, `l2_frontend_useplan.lm1` `FA9FB99C…` same-as-G1 |

(G1's own Core step took 43.24 min inside its pipeline — a different context, listed as the reference only.) Three
gdb samples of Core/fe111/01: all three in `lm_compiler_contract_source_node` (from m2_scalar_effect_free in m2_close
and from cast_resolve in emission).

## S3 (tp112): the contract index, the own-name index, two core fixes

Targets from the fe111 samples (Lower 4, Core 3, Emit 2, `records/samples/sample-*-fe111-*`): `lm_compiler_contract_source_node`
(every declaration's contract chains walked per contract query; the top frame in Lower and all three Core samples),
`lm_compiler_own_at` under `call_head_method` in m2_close (`text_same` over every own row), `lm_compiler_method_in_os`
under `machine_validate` (the unit walked for every machine name x method pair), and the owner memo's re-check in Emit.
Variant `P/variants/tp112/` = tp111 plus:
- `l2_frontend_resolve.lm2` — writers of the contract index (`lm_compiler_cmap_*`: contract -> chain of the declarations
  whose contract chain or asserted chain holds it; `lm_compiler_cmap_index(result)` at the four places a record's contract
  fields become final, i.e. every creation and the two rewriting paths) and of the creation ordinal (`lm_compiler_dord_put`
  next to every `lm_compiler_dmap_put`; the list is only prepended, so list order is descending ordinal); all emptied with
  the declaration map when `l2_declarations` is.
- `l2_frontend_context.lm2` — `lm_compiler_contract_source_node` reads the index: the candidates of the contract, each
  re-checked against its current chains exactly as the walk tested it, folded newest first by ordinal with the same
  `node_in` rule; the six own lookups (`own_find`, `own_find_last`, `own_at`, `own_local_at`, `own_lexical`, `own_host_at`)
  walk the name's chain of the own-name index (`lm_compiler_oix_*`: FNV hash of the name -> rows in ascending order, built
  incrementally from the rows added since its last use, forgotten on a new `l2_own_gen`) with their conditions unchanged
  (`text_same` kept as the collision guard).
- `l2_frontend_core.lm2` — `lm_compiler_own_free` bumps `l2_own_gen` (the only path that starts the own table over);
  `lm_compiler_machine_validate` tests the cheap name equality before `m_machine`'s unit walk (both pure).
- `tools/build.lm2` — 24 cells (`l2_cmap_*`, `l2_dord_*`, `l2_csn_*`, `l2_oix_*`, `l2_own_gen`) after tp111's.
Stage cold-tp112: `pins/tp112-prepare.command`, 10 steps exit 0; `source-tp112.sha256` differs from source-full100 in exactly
the eight tp112 files; 234 reused generated files (tp111-reuse minus core.lm1 plus fe111's values/views L1) staged from
cold-tp111, VERIFIED 234/0. Standalone translation by fe111 (`pins/tp112-selfcheck.command`, try 01): context 1.9 s,
resolve 5.5 s, core 150.2 s, all exit 0, headers byte-equal to G1 (`F66863F9…`, `4EABD272…`, `180B95C2…`), bodies
differ as they must. tool112: `pins/tp112-tool.command`, 23:31:38 -> 23:42:24Z, `RebuildExit 0`, `REBUILD tool 0
failures`; `tool112/lmxtool-tool.exe` `2F619DDF…` (1842402 bytes), `lmxtool.lm1` `DDB40A33…`, `lmxtool.c` `7358B67D…`. fe112: `pins/tp112-frontend-part.command`
(host tool112, producer fe111, parts context,resolve,core): 23:43:19 -> 23:46:48Z, `PartExit 0`, both 234-file manifests
VERIFIED before and after; `fe112/l2trans.exe` `DEE9CB59…` (1558703 bytes), `l1trans.exe` `0FD15526…`, `l2_libc.o` `AF9FDAE3…`
(= G1), `frontend.c` `6DD353F1…` (10181693 bytes); the three regenerated bodies byte-equal to the standalone translations
(context `824FD57C…`, resolve `22908FF3…`, core `86D5B4D2…`), their headers equal to G1; `l2_frontend_state.lm1`
`F1E720F8…` (17524 bytes) holds the 46 cells of tp110-tp112.

Measurement of fe112: Lower try 01 (23:48:09Z, the binary's first execution) exited with 0xC0000005 after 0.1 s CPU and
8.8 s wall, no outputs, empty stderr (`pins/tp110-measure-l2_frontend_lower-fe112-01.*`). Not reproduced: a direct run from the
same tree (`P/tp112-crash/`, exit 0, 57.5 s CPU) and try 02 (00:00:52Z: wall 57.8 s, CPU 57.3 s, peak WS 324.0 MiB, commit
329.1 MiB) both give G1's bytes; useplan direct run exit 0, 3.7 s, G1's bytes. A run under gdb -batch produced G1's bytes
at about 2 min and then kept running at full CPU until killed after 6 min (inferior exit code 01 = the kill); the direct
runs of the same binary exit normally, so the spin is not reproduced outside gdb either. Both oddities are recorded as
open observations of this slice (see Open). Lower, same context: g1 1426.8 s, fe110 791.2 s, fe111 136.4 s, fe112 57.8 s.
Sample of Lower/fe112/02 (`records/samples/sample-lower-fe112-01.txt`): `lm_compiler_m2_calls_in` in m2_close.

### tp112 try 01: an intermittent startup crash, its cause and the fix

The first fe112 (`DEE9CB59…`, now `cold-tp112-try01/fe112`, records `pins/tp112-*-try01.*`) crashed with 0xC0000005 after
about 0.1 s of CPU in 2 of 5 measured/direct runs (Lower try 01, Core try 01) and in 1 of 6 direct useplan runs
(`P/tp112-crash/rep-fe112-*`), never under gdb (14 runs; one gdb run of Lower wrote G1's bytes and then spun at full CPU
until killed), and never for fe111 (6 of 6). The successful runs produced G1's bytes every time. Cause (by reading, not
by the debugger, which hides it): the contract index and the ordinal map were emptied only when a writer observed an
empty `l2_declarations`; `lm_compiler_application_free` frees every declaration and contract, but the first writer after
it runs after the first new record is already prepended, so the empty list is never observed and the index keeps
entries pointing at freed declarations and contracts. `lm_compiler_contract_source_node` then reads freed memory (the
intermittent crash; the spin under gdb's debug heap is the same walk over garbage). The declaration map of tp111 is
checked before the first insertion (`dmap_get` opens `lm_compiler_declaration`), which is why fe111 never hit it — except
on the `rb_declaration` path, where the same hole existed in theory. Fix (tp112 try 02): `lm_compiler_application_free`
bumps a new cell `l2_decl_gen`; the declaration map, the contract index and the ordinal map record the generation they
were filled under (`l2_dmap_gen`, `l2_cmap_gen`) and forget everything when it moved; the reader of the contract index
answers 0 for a stale generation (the list is empty then). Re-staged as cold-tp112 (the faulty stage kept as
`cold-tp112-try01`), standalone translations by fe111 (try 02): context 2.1 s, resolve 6.2 s, core 180.2 s, exit 0,
headers byte-equal to G1 (`F66863F9…`, `4EABD272…`, `180B95C2…`).

tool112 (try 02, the fixed sources): `pins/tp112-tool.command`, 00:21:44 -> 00:34:00Z, `RebuildExit 0`, `REBUILD tool 0
failures`; `tool112/lmxtool-tool.exe` `A9E9A139…` (1842402 bytes), `lmxtool.c` `C7CA4F35…` (2506587 bytes: 60 more than
try 01, the three generation cells); the try-01 tool is kept as `cold-tp112-try01/tool112` with `pins/tp112-tool-try01.*`.
fe112 (try 02): `pins/tp112-frontend-part.command`, 00:34:27 -> 00:40:09Z, `PartExit 0`, both 234-file manifests VERIFIED
before and after; `fe112/l2trans.exe` `46F3A974…` (1558793 bytes), `l1trans.exe` `158B1E8A…`, `l2_libc.o` `AF9FDAE3…` (= G1),
`frontend.c` `125971FE…` (10184216 bytes); the three regenerated bodies byte-equal to the try-02 standalone translations
(context `F737F7B9…`, resolve `E9259B75…`, core `CC2DD45A…`), headers equal to G1; `l2_frontend_state.lm1` `4C3CB07D…`
(17581 bytes, 49 cells). The try-01 frontend is kept as `cold-tp112-try01/fe112` with `pins/tp112-frontend-part-try01.*`.
Crash probe of the fixed fe112 (`P/tp112-crash/rep2/`, twelve direct useplan runs from the private tree, redirected stdio):
12 of 12 exit 0, CPU 3.7-4.2 s, `l2_frontend_useplan.lm1` `FA9FB99C…` (= G1) every time; the try-01 build had crashed in 1 of
6 such runs (`P/tp112-crash/rep-fe112-*`) while fe111 passed 6 of 6 (`rep-fe111-*`).

Measurements of the fixed fe112 (same record, tree and argv): Lower try 03 (00:42:12Z) wall 95.9 s, CPU 95.2 s, peak WS 324.0
MiB, both outputs same-as-G1; Core try 02 (00:44:26Z) wall 106.4 s, CPU 105.8 s, peak WS 367.4 MiB, both same-as-G1
(`180B95C2…`, `C04F5FFC…`); Emit try 01 (00:47:21Z) wall 133.5 s, CPU 132.8 s, peak WS 284.7 MiB, both same-as-G1
(`3A007B19…`, `BC112CD8…`; fe111: 139.8 s — S3 hardly touches Emit). The faulty try-01 build's 57.8 s Lower was faster because its stale
contract index skipped work (withdrawn). Samples of Lower/fe112/03 (`records/samples/sample-lower-fe112b-*`): the owner
memo's re-check `node_in` in `contract_source_begin_at` (from is_asgn/contract_own in dyn_local) and the M2 pass.

## Codex on landing (relayed by lmx_uds, 2026-11-02 about 01:05Z, answer to FABLE-RESULT-S3-20261102T0100Z)

Relayed text, kept verbatim (the relay's own transcript ends "Fable получил решение: после успешного `boot112` перенести в
`selfbuild` цельный проверенный набор — 159 входов, 15 изменённых исходников, включая унаследованные правки"; no separate
raw copy of Codex's reply was obtained):

> Выбираю (a) ПОСЛЕ actual успешного boot112: посадить в selfbuild цельный source-tp112, не восемь файлов отдельно. Авторство
> унаследованных файлов само по себе не gate. Новый source-only quick проверяет full100+твои изменения вместе, поэтому
> незавершённый старый G2 full100 не требует повторного FULL и не мешает при успешном новом G1/G2. Текущий живой bootstrap
> сохранить, не дублировать.
>
> Codex read-only сверил: source-boot112=source-tp112 SHA 7fa43f9e1adc10ab044c9fd3d953e69f2f6f8f86fa501f17eac70341faeb19ca,
> 159 входов; все159 actual cold-boot112 inputs соответствуют ему. Все159 actual selfbuild inputs соответствуют
> inputs.sha256=source-boot89. Разница selfbuild -> source-tp112 ровно 15 источников (9 full100 +8 tp112 с перекрытием
> core/build). Пины fixed G0/tool112 A9E9A139 и producer 46F3A974 совпали с actual файлами, DEE9CB59 не кандидат посадки.
>
> Условие посадки — завершённый quick без compiler/runtime ошибок, реальные G1 и G2 (G2 построен настоящим G1), штатные smoke
> и сравнение фактических outputs поколений с точным объяснением допустимых различий. Нельзя засчитать только wrapper
> exit/done, один G1 или непонятное расхождение. Не нужен FULL до посадки и не нужен новый ACK Codex/автора после выполнения
> этих обычных проверок. Пока результат pending/failed — selfbuild не менять, сохранять старый boot89 и исправлять
> конкретный сбой текущей линии.
>
> После успешного результата: свежие CWD/dirty/pins, существующий verify -> stage-copy -> manifest -> verify на ТОЧНЫХ 159
> входах; selfbuild/inputs.sha256 должен совпасть с source-tp112, inputs.list сохранить если набор прежний. Только
> фактически изменившиеся 15 supported source paths + нужный manifest и твои records/docs в выбранный commit, без mass
> add/чужого WIP/reset/clean, без generated binaries/L1/C как новых maintained source. Приведи происхождение: inherited
> full100 (9), tp112 (8), overlap core/build, failed old full100 G2 исторический, принятие покрывает boot112 receipt. Не
> приписывать эти 9 себе, но переносить как проверенный coherent набор можно. Обычный main commit/push завершённого среза
> разрешения не требует.
>
> Если хочется сохранить docs до окончания boot112, отдельный промежуточный docs commit допустим; это не замена
> последующей посадке при PASS и не причина откладывать её до Opus. Когда boot112 завершится, действуй по этому ответу
> без нового согласования, затем tp113/следующие semantic slices по плану. Один pipeline, Opus продолжает ждать. Все
> вопросы Codex; полная архитектура S4/S8 и самосборка не объявляются готовыми одним этим срезом.

## boot112: the short bootstrap of the S1-S3 sources passed, G1 = G2 apart from the link stamps

`pins/boot112-prepare.command` (frozen tool `E8150E60`, verify/stage-copy/manifest/verify, 00:51:41-00:51:42Z, four steps
exit 0): fresh source-only stage `cold-boot112` = exactly `source-tp112.sha256` (159 inputs; `source-boot112.sha256` is
byte-equal to it, `7FA43F9E…`), no generated input. `pins/boot112-quick.command` through `boot112-detached.command`
(launcher pid 12852, `StartUTC 00:51:56.69Z`, PreVMKiB 8646652): `timeout 172800 tool112 (A9E9A139) bootstrap quick R
P/cold-boot112 P/cold-candidate48/full48/g2/frontend P/cold-tp112/fe112/l2trans.exe (46F3A974) quick112
P/cold-boot112/tests/smoke-kernel225.tsv`, CWD `P/boot112-quick-run-01`, log `pins/boot112-quick.log`. G0 = tool112 (the
tp112 tool, host of fe112), previous frontend = fe112, so G1's frontend is translated by the indexed frontend and G2's by
G1 itself. By 01:02Z G1 had its frontend, runtime, smoke (`SUITE 9 rows, 0 failures`, `PASS generation`) and tool; the G2
frontend step was running at 01:06Z.

Result ([boot112-quick.terminal](records/boot112-quick.terminal.txt): `EndUTC 01:11:15.95Z BootstrapExit 0`; launcher
`BOOT112-QUICK EXIT=0`, `done 01:11:15.98Z`; [log](records/boot112-quick.log) 342 lines: `PASS bootstrap: G0 builds and
tests whole G1`, `PASS G1: the tested whole bundle is working`, `PASS bootstrap: actual G1 builds and tests whole G2`,
`PASS G2: the tested whole bundle is working`, `BOOTSTRAP quick 0 failures`). 1159 s for both generations; boot98 (slice249,
the same recipe with the unindexed frontend 49c/FE94) took 18196 s. Step ends from the outputs' write times:

| generation | frontend (l2trans, l1trans) | runtime (driver.o, driver-observe.o) | smoke | tool (lmxtool-tool.exe, lmxtool.lm1) |
|---|---|---|---|---|
| G1 (by tool112 + fe112) | 00:58:57 `CE458992…`, `4BF083B2…` (421 s from StartUTC) | 00:59:45 `40B84ECF…`, `16A0C54A…` | `SUITE 9 rows, 0 failures` | 01:01:29 `97BAE3B4…`, `97E5BA99…` |
| G2 (by the actual G1 tool + G1 frontend) | 01:08:41 `6A66B24E…`, `3C0B1D3C…` | 01:09:28 `40B84ECF…`, `16A0C54A…` | `SUITE 9 rows, 0 failures` | 01:11:13 `0E3ACE61…`, `97E5BA99…` |

G2's record ([g2-record](records/boot112-g2-record.txt)): G2's tool hashes its own `lmxtool.lm1` to `97E5BA99…`, exit 0;
the working `quick112/lmxtool.exe` is `0E3ACE61…` (G2's tool) and `working-bundle.sha256` is `g2/bundle.sha256` byte for
byte ([g1](records/boot112-g1-bundle.txt), [g2](records/boot112-g2-bundle.txt)).

### G1 and G2 compared

Quick mode does not compare the generations; `pins/boot112-compare.command` ([record](records/boot112-compare.command),
[output](records/boot112-compare.txt), 01:12:21Z) read the `<sha256>  <path>` receipts of G1's part of the quick log and of
[g2-build.log](records/boot112-g2-build.log), keyed by the path with the generation directory normalised. 248 paths in
both (none only in one); 245 raw-equal: all 63 `.lm2`, 84 `.h.lm1`, 77 `.lm1` (every frontend, backend and kernel L1 —
G1's translated by fe112, G2's by the G1 frontend), 13 `.lm1.h`, 5 `.c` (`frontend.c`, `backend.c`, `l2_libc.c`,
`driver.c`, `lmxtool.c`) and 3 `.o`. The 3 that differ are the PE images `l2trans.exe`, `l1trans.exe`, `lmxtool-tool.exe`:
equal sizes, exactly 4 differing bytes each at offsets 136–137 (TimeDateStamp) and 216–217 (CheckSum) — the link stamp.
`g1/consumed-inputs.sha256` and `g2/consumed-inputs.sha256` (306 lines each) are raw-equal. So G1 = G2 apart from the
stamp: the fixed point boot89/boot98 did not reach (28 raw differences there, the parenthesis and typed-zero classes),
because here the previous frontend fe112 and G1's frontend are the same program: `cold-tp112/fe112/frontend.c` and
`quick112/g1/frontend/frontend.c` are byte-equal (10184216 bytes), fe112's `l2trans.exe`/`l1trans.exe` and G1's differ only
at the same 4 stamp bytes. (tool112 and G1's tool differ in 84 bytes — the 4 stamp bytes and 80 bytes from offset 1809328;
they were built from different stage trees by different frontends, so no equality is claimed for them.) Neither
generation ran the full list, OSWALK or the self-test (quick mode).

## The landing: source-tp112 is the selfbuild package (Codex, relayed answer above)

`pins/land251.command` ([record](records/land251.command), [terminal](records/land251.terminal.txt)) with the promoted
working tool of boot112 (G2's, `0E3ACE61…`; its hash, `source-tp112.sha256` = `source-boot112.sha256` = `7FA43F9E…`,
`BootstrapExit 0` and `BOOTSTRAP quick 0 failures` checked first), each step from a fresh private CWD, 01:12:55–01:12:57Z.
The record first writes the two subsets `land251-g1/g2-consumed-sources.sha256` ([g1](records/land251-g1-consumed-sources.sha256),
[g2](records/land251-g2-consumed-sources.sha256)): the lines of the generations' consumed-input snapshots whose paths are
in `selfbuild/inputs.list` — 65 of 306 each, the same 65 lines, every line in `source-tp112.sha256`.

| step | command | result |
|---|---|---|
| 01 | `verify P/pins/source-tp112.sha256 P/cold-boot112` | `VERIFIED 159 files, 0 failed` |
| 02 | `stage-copy P/pins/source-tp112.sha256 P/cold-boot112 R/selfbuild` | `STAGED 159 files, 0 failed` |
| 03 | `manifest R/selfbuild/inputs.list R/selfbuild R/selfbuild/inputs.sha256` | `MANIFEST 159 files, 0 failed` |
| 04 | `verify R/selfbuild/inputs.sha256 R/selfbuild` | `VERIFIED 159 files, 0 failed` |
| 05 | `verify P/pins/land251-g1-consumed-sources.sha256 R/selfbuild` | `VERIFIED 65 files, 0 failed` |
| 06 | `verify P/pins/land251-g2-consumed-sources.sha256 R/selfbuild` | `VERIFIED 65 files, 0 failed` |

The rewritten `selfbuild/inputs.sha256` is byte-equal to `source-tp112.sha256` (`7FA43F9E1ADC10AB044C9FD3D953E69F2F6F8F86FA501F17EAC70341FAEB19CA`);
`selfbuild/inputs.list` is unchanged (`E6FFBCFB…`, the same 159 paths). Git sees 16 changed paths under `selfbuild/`:
`inputs.sha256` and 15 sources — 9 inherited from full100 (`l2_frontend_coords`, `_core`, `_emit`, `_lower`, `_useplan`,
`lmx_reparent`, `lmx_value_owned`, `lmx_walk_values`, `tools/build.lm2`; Opus's line, slices 247–250, not this slice's
work — carried as the tested coherent set) and 8 of tp112 (`l2_frontend_types`, `_intern`, `_values`, `_views`, `_context`,
`_resolve`, `_core`, `tools/build.lm2`); `_core` and `build.lm2` carry both. The old full100 G2 (incomplete, stopped) is
history; the acceptance of these bytes is boot112's receipt. `selfbuild/README.md` names the package, the G0/previous
frontend tuple (tool112 `A9E9A139…`, fe112 `46F3A974…` with `158B1E8A…`/`AF9FDAE3…`, BASE full48/g2/frontend), the promoted
working tool and the acceptance boundary (quick, not FULL; the G1/G2 comparison as evidence, not a gate).

## tp113 (S3b): the method-name index -- sources and records written, builds after boot112

Target: the Emit sample of fe112 (`lm_compiler_text_same` under `lm_compiler_site_method` from `scan_ident`) and the
`find_method` scans. `variants/tp113` = `variants/tp112` + `l2_frontend_emit.lm2` (G1's, `C35CE51A…`), patched by
`tp113_patch.py` (scratchpad):
- `l2_frontend_context.lm2`: `lm_compiler_site_method` walks the chain of `t`'s bucket (`i: lm_compiler_mix_first(t)`,
  `i: lm_compiler_mix_step(i, linear)`) with the same `text_same`/`method_visible_at` filters and the same selection, in
  row order; `-2` from `mix_first` (allocation failure) makes it the old scan over every row (`linear`). Five internal
  helpers `lm_compiler_mix_hash/insert/sync/first/step` appended at the module end (the `oix` shape: bucket/tail/next,
  FNV over the name's bytes, incremental up to `l2_m_n`, valid per `l2_m_gen`, rows with a null name in no chain).
- `l2_frontend_values.lm2`: `lm_compiler_find_method` the same way over `lm_compiler_vmix_*` (the values copy of the five
  helpers; internal helpers are per module, the eight cells are shared, the algorithm is deterministic on them).
- `l2_frontend_core.lm2`: `lm_compiler_meth_free` bumps `l2_m_gen`; `l2_frontend_emit.lm2`: the per-unit reset of
  `lm_compiler_translate_unit` (`m_n_cell[0]: 0`) bumps it first. Checked over all 13 modules: `l2_m_name` is written at
  exactly three sites (emit 343, 443, 4188 -- each at the append position before `l2_m_n` is incremented) and `l2_m_n` only
  increments or returns to 0 at those two resets (aliases `m_n_cell` x149, `cell_m_n` x1 read-only), so a chain in row
  order sees the rows the scan saw and no row changes its name after it is indexed.
- `tools/build.lm2`: +8 cells (`l2_m_gen`, `l2_mix_n/cap/rows/gen`, `l2_mix_bucket/tail/next`; 57 in all).
Exported headers unchanged by construction (no `--machine` list touched). Records written, none run (one pipeline):
`pins/tp113-prepare.command` (stage `cold-tp113` = source-full100 + the nine tp113 files, 233 reused generated inputs from
`cold-tp112`: 229 G1 files, fe110's types/intern L1, fe111's views L1, fe112's resolve L1 `E9259B75…`; 18 manifest
differences), `tp113-tool.command` (+detached; tool113 by the frozen tool from G1's frontend/runtime), `tp113-frontend-part.command`
(+detached; fe113 = fe112 translating context, values, core, emit on tool113), `tp113-selfcheck.command` (standalone
translation of one module by fe112 against G1's record). Order after boot112: selfcheck x4, prepare, tool113, fe113,
the four measurements (`tp110-measure.command` with TP_FE = fe113), then the landing of boot112 is independent of tp113.
