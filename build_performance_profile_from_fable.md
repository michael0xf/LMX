# Build performance profile (Fable): the translator before and after each optimization slice

Author fable_pc, sole writer/build by [to_fable.md](to_fable.md). Started 2026-11-01. Requirements and the G1 full100
reference times: [optimization_three_passes_shared_runtime.md](optimization_three_passes_shared_runtime.md); design:
[optimization_design_from_fable.md](optimization_design_from_fable.md); slice records: `steps/witnesses/fix251-20261101/`
onward. Every number here is an actual measurement with its record named; nothing is claimed from a document or a
flag. Different contexts are never compared as a pure speed-up: the G1 pipeline times are listed as the reference
they are, and the same-context comparison is a measured G1-frontend run of the same step on the same tree.

## Method

One measured L2→L1 translation of one frontend module by one frontend: `pins/tp110-measure.command` (parameters module,
G1 record line, frontend, label, attempt), run detached from its own private CWD `P/tp110-tree-01/src` (a staged copy
of G1 full100's stage as it stood before the emit step; manifest `perf251-emit-tree-03-all.sha256`, VERIFIED 211/0),
with the exact argv of the `$` line of G1's frontend record for that step (inputs are the stage's hash-pinned files
under `P/cold-full100/src`, re-checked against the record's `in` lines before the run, so the unit prefix is G1's), the
two outputs written to `P/tp110-measure/<module>-<label>-<try>/`. Measured per run: wall from process start to exit,
CPU user and kernel (GetProcessTimes), peak working set and peak commit (GetProcessMemoryInfo after exit), page faults;
then the SHA-256 of both outputs against the record's `out` lines (same-as-G1 or DIFF). Machine: AMD Ryzen 7 5800H,
16 logical processors, Windows 11; free physical and virtual memory at start are in each terminal.
P = `C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01`.

The L1→C and C-compilation of the translated result are not part of these runs: they are the backend steps of a
frontend build (`build-frontend-part`: `l1trans`, `gcc -O2 -fno-strict-aliasing`), recorded in that build's record with
their own times; they are listed separately where measured.

## Frontends

| label | binary | sha256 | source difference from G1 | build |
|---|---|---|---|---|
| g1 | `P/cold-full100/full100/g1/frontend/l2trans.exe` | `BF6D713E…` | none (G1 full100) | G1 full100 pipeline |
| fe110 | `P/cold-tp110/fe110/l2trans.exe` | `63FD9E71…` | types.lm2 (predef declaration index), intern.lm2 (index reset), build.lm2 (nine state cells) | `build-frontend-part` on tool110, 21:22:53–21:24:30Z, exported headers byte-equal to G1 |
| fe111 | `P/cold-tp111/fe111/l2trans.exe` | `3F174068…` | fe110 + context.lm2 (owner memo in `contract_source_begin_at`), resolve.lm2 (node-keyed declaration map), views.lm2 (head-source memo), values.lm2 (memo reset at head-expression dispose), build.lm2 (thirteen more cells) | `build-frontend-part` on tool111 with producer fe110, 23:06:58–23:08:51Z, exported headers byte-equal to G1 |
| fe112 (try 01, withdrawn) | `P/cold-tp112-try01/fe112/l2trans.exe` | `DEE9CB59…` | fe111 + resolve.lm2 (contract index and creation-ordinal writers), context.lm2 (contract-source reader, own-name index), core.lm2 (own-table generation, machine_validate order), build.lm2 (24 more cells) | `build-frontend-part` on tool112 with producer fe111, 23:43:19–23:46:48Z, exported headers byte-equal to G1 |
| fe112 | `P/cold-tp112/fe112/l2trans.exe` | `46F3A974…` | the same four modules, plus the declaration-list generation `l2_decl_gen` bumped by `application_free` and read by the declaration map, the contract index and the ordinal map (the fix of the try-01 crash) | `build-frontend-part` on the second tool112 with producer fe111, 00:34:27–00:40:09Z, exported headers byte-equal to G1 |

## G1 full100 reference (pipeline context, wall from log boundaries; requirements doc)

| step | wall |
|---|---|
| Frontend до Lower | 4.95 min |
| Lower | 24.29 min |
| Core | 43.24 min |
| Emit | 64.04 min |
| Остальной frontend (backend, libc, L1→C, C) | about 1.22 min |
| Tool | 10.28 min (10.17 min L2→L1 of the tool methods) |

## S1 (tp110): predef declaration index

Slice record: `steps/witnesses/fix251-20261101/notes.md`. Results are appended as each run's terminal completes
(`pins/tp110-measure-<module>-<label>-<try>.terminal.txt`).

| module | label | try | start (UTC) | wall s | cpu user s | cpu kernel s | peak WS MiB | peak commit MiB | outputs vs G1 |
|---|---|---|---|---|---|---|---|---|---|
| l2_frontend_lower | fe110 | 01 | 2026-11-01 22:10:55 | 791.2 | 787.9 | 1.0 | 288.2 | 325.0 | both same-as-G1 |
| l2_frontend_lower | g1 | 01 | 2026-11-01 22:25:54 | 1426.8 | 1423.4 | 1.4 | 286.3 | 325.2 | both same-as-G1 |

Same context, same inputs, same outputs to the byte: Lower with fe110 takes 791.2 s against 1426.8 s with the G1
frontend (wall; CPU 787.9 s against 1423.4 s), 1.80 times faster, at the same peak memory (about 288 MiB working
set, 325 MiB commit). The predef index alone removes 44 percent of Lower's translation time.

## S2 (tp111): node-keyed memos — owner of a site, declaration by source node, head-source node

| module | label | try | start (UTC) | wall s | cpu user s | cpu kernel s | peak WS MiB | peak commit MiB | outputs vs G1 |
|---|---|---|---|---|---|---|---|---|---|
| l2_frontend_lower | fe111 | 01 | 2026-11-01 23:09:49 | 136.4 | 135.4 | 0.4 | 323.5 | 327.6 | both same-as-G1 |
| l2_frontend_core | fe111 | 01 | 2026-11-01 23:12:30 | 161.6 | 160.5 | 0.5 | 360.1 | 371.5 | both same-as-G1 |
| l2_frontend_emit | fe111 | 01 | 2026-11-01 23:15:58 | 139.8 | 139.1 | 0.3 | 291.5 | 297.9 | both same-as-G1 |
| l2_frontend_useplan | fe111 | 01 | 2026-11-01 23:20:00 | 7.9 | 7.9 | 0.1 | 77.9 | 76.3 | both same-as-G1 |

Lower + Core + Emit with fe111: 437.8 s of translation for the three large frontend modules, every output byte-equal
to G1's. G1's pipeline spent 131.6 min on the same three steps (24.29 + 43.24 + 64.04, its own context: the reference,
not a same-context comparison; the same-context factor measured on Lower is 10.5).

## S3 (tp112): contract index, own-name index, two core fixes

| module | label | try | start (UTC) | wall s | cpu user s | cpu kernel s | peak WS MiB | peak commit MiB | outputs vs G1 |
|---|---|---|---|---|---|---|---|---|---|
| l2_frontend_lower | fe112 (try-01 build `DEE9CB59…`) | 01 | 2026-11-01 23:48:09 | 8.8 | 0.1 | 0.1 | 47.0 | 43.3 | crash 0xC0000005 at start, no outputs |
| l2_frontend_lower | fe112 (try-01 build) | 02 | 2026-11-02 00:00:52 | 57.8 | 57.3 | 0.3 | 324.0 | 329.1 | both same-as-G1 |
| l2_frontend_core | fe112 (try-01 build) | 01 | 2026-11-02 00:02:12 | 10.7 | 0.1 | 0.0 | 43.6 | 41.4 | crash 0xC0000005 at start, no outputs |
| l2_frontend_lower | fe112 | 03 | 2026-11-02 00:42:12 | 95.9 | 95.2 | 0.4 | 324.0 | 329.0 | both same-as-G1 |
| l2_frontend_core | fe112 | 02 | 2026-11-02 00:44:26 | 106.4 | 105.8 | 0.3 | 367.4 | 373.2 | both same-as-G1 |
| l2_frontend_emit | fe112 | 01 | 2026-11-02 00:47:21 | 133.5 | 132.8 | 0.2 | 284.7 | 299.2 | both same-as-G1 |

The try-01 build of fe112 crashed intermittently at start (2 of 5 measured or direct runs, 1 of 6 useplan runs, never under
gdb): its contract index kept entries pointing at declarations freed by `lm_compiler_application_free` (slice notes). The
successful runs were byte-equal to G1 (Lower 57.8 s, 24.7 times faster than the G1 frontend in the same context). The
fixed build (generation cell bumped by `application_free`) is measured below: Lower 95.9 s against fe111's 136.4 s (1.42
times; 14.9 times against the G1 frontend in the same context). The faulty build's 57.8 s was faster because its stale
contract index answered some contract-source queries with nothing, skipping work it should have done — identical bytes
on this input, but not the translator's semantics; it is withdrawn. Samples of the fixed Lower run: the owner memo's
re-check (`node_in` over the owning method's tree, from `contract_source_begin_at`) and the M2 pass
(`lm_compiler_m2_calls_in`, design §4.3 — a removal, not an index).

Core and Emit with the fixed fe112 (same records): Core 106.4 s against fe111's 161.6 s (1.52 times), Emit 133.5 s
against fe111's 139.8 s (1.04 times) — the contract index and the own-name index help Lower and Core, hardly Emit.
Peak working set: Core 367.4 MiB (fe111 360.1), Emit 284.7 MiB (fe111 291.5). The Emit sample (00:47:55Z, one `bt`)
sat in `lm_compiler_text_same` under `lm_compiler_site_method` (the linear method-name search over `l2_m_n` rows) reached
from `scan_ident` in the path scan of dyn_local — the first candidate after S3 (a method-name index keyed by the name's
text, valid per a method-list generation).

Lower, same context and inputs, outputs byte-equal to G1 in every run: G1 frontend 1426.8 s, fe110 791.2 s, fe111 136.4 s
(10.5 times faster than the G1 frontend; the three memos removed 83 percent of fe110's time). Peak memory grew by
about 35 MiB working set (the memo tables), commit by 2.6 MiB.
Stack samples of Lower/fe111/01 (4, between 23:10:13 and 23:12:06Z): `lm_compiler_contract_source_node` (every
declaration's contract chains walked per contract query), `lm_compiler_own_at` under `call_head_method` in the M2 pass
(`text_same` over every own row), `lm_compiler_method_in_os` under `machine_validate` (every method's unit walked per
machine name × method pair), and emission. Those are the S3 candidates.

Stack samples (gdb, one `bt` per sample, attach + detach ≈ 1 s wall each, CPU unaffected): recorded under the slice.
Lower/fe110/01: 10 samples between 22:12:36 and 22:21:18Z — 5 in the owning-method search of
`lm_compiler_contract_source_begin_at` (`lm_compiler_node_in`/`struct_has` over every method's source tree, reached from
`contract_formal`/`contract_model_word` in dyn_local, check_body and path effects), 3 in `lm_compiler_declaration`
itself (the linear walk of `l2_declarations`), 2 in `lm_compiler_head_source_node` (every head-expression document
searched by `node_in`, from `own_source_visible`). None in predef lookups any more (attempt03's 4 of 4 were there).

## S3b (tp113): the method-name index — measured as back-to-back pairs

The design's slice table (§6) numbered its contents S1–S9 by candidate; the candidates actually built diverge from it after
tp110: tp111 = node-keyed memos, tp112 = contract and own-name indexes, tp113 = method-name index, tp114 = owner memo
without re-check, predef file index, fact index (all exact, outputs byte-equal to G1). The semantic slices of the table
(explicit throws, one collection pass, kernel code links, …) start after these; their numbers follow the candidates.

fe113 (`P/cold-tp113/fe113/l2trans.exe`, `6038F156…`): `site_method` and `find_method` over a method-name index valid per
a method-table generation. Slice 252 notes. The same machine runs slower in this hour than at 00:42Z (fe112's Lower 111.7 s
against its own 95.9 s before), so from here each candidate is measured right next to the previous frontend:

| module | fe113 wall s | fe112 wall s (next run) | ratio | outputs |
|---|---|---|---|---|
| l2_frontend_lower | 94.6 | 111.7 | 0.85 | both same-as-G1 |
| l2_frontend_core | 122.4 | 135.9 | 0.90 | both same-as-G1 |
| l2_frontend_emit | 154.4 | 165.4 | 0.93 | both same-as-G1 |
| l2_frontend_useplan | 6.6 | — (fe111 7.9) | | both same-as-G1 |

Stack samples with fe113 (10): 4 in the owner memo's re-check (`node_in` over the owner's tree in
`contract_source_begin_at`), 2 in `predef_file_define`, 1 in `predef_file_result_ty`, 1 in `source_parent_body` under
`method_duplicate`, 1 in `use_fact_find`, 1 in `path_fact_note_bytes`; none in the method-name scans any more. The first
three are tp114's targets.

## S3c (tp114): owner memo without the tree re-check, predef file index, fact index — paired with fe113

fe114 (`P/cold-tp114/fe114/l2trans.exe`, `0DB4B5D1…`; slice 252 notes): the owner memo is trusted by three generations
(method count, method-table generation, document generation bumped by every document destroy) instead of a walk of the
owner's tree per query; the predef `define`/prototype lookups read a per-file index merged with the file's imports in
document order; `use_fact_find` reads a (method, source) index of the path facts. Measured right after fe113:

| module | fe114 wall s | fe113 wall s (next run) | ratio | outputs |
|---|---|---|---|---|
| l2_frontend_useplan | 3.1 | 6.6 (try 01) | 0.47 | both same-as-G1 |
| l2_frontend_lower | 70.8 | 92.4 | 0.77 | both same-as-G1 |
| l2_frontend_core | 74.5 | 105.0 | 0.71 | both same-as-G1 |
| l2_frontend_emit | 55.5 | 129.2 | 0.43 | both same-as-G1 |

Chained against the G1 frontend in the same tree (G1 1426.8 s for Lower; fe112 14.9x at 00:42Z; fe113 0.85 of fe112;
fe114 0.77 of fe113), Lower is about 23x faster than G1's frontend; the machine's hour-to-hour drift (about 15 percent) is
the uncertainty of the chain. tool114 (`rebuild tool`) took 92 s with boot112's G2 frontend as the producer against
1230 s for tool113 with full100's G1 frontend (Codex's pointer, 2026-11-02).

## The whole short bootstrap with the S3 frontend (boot112)

`bootstrap quick` of the S1–S3 sources (stage cold-boot112 = source-tp112, 159 inputs) with G0 = tool112 and the previous
frontend fe112, 2026-11-02 00:51:56–01:11:16Z (slice 251 notes). Both generations built and smoke-tested (9 rows, 0
failures each), `BOOTSTRAP quick 0 failures`; G1 = G2 apart from the PE link stamps (245 of 248 receipt paths raw-equal).

| bootstrap | frontend of G0's line | whole quick (s) | G1 frontend step (s) | G2 frontend step (s) |
|---|---|---|---|---|
| boot98 (slice 249, draft79 line) | 49c / FE94 (no indexes) | 18196 | — | 8273 |
| boot112 (slice 251) | fe112 (S1–S3) | 1159 | 421 | 424 |
| boot114 (slice 252) | fe114 (S1–S3c) | 969 | 324 | 316 |

The frontend step translates all 23 frontend/backend modules, writes `frontend.c`/`backend.c` and compiles them; the
runtime step (kernel L2 → L1 → C headers, two objects) took 48 s and 47 s, the tool step 104 s and 105 s; the smoke list
about 40 s per generation. The remaining targets of the frontend step are the ones named above (method-name scans, the
owner memo's re-check, the M2 pass).
