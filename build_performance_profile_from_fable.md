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
| boot115f (slice 253, tp115 = the kernel's code links) | boot114's G2 frontend (= fe114's sources self-built) | 962 | 308 | 308 |

The frontend step translates all 23 frontend/backend modules, writes `frontend.c`/`backend.c` and compiles them; the
runtime step (kernel L2 → L1 → C headers, two objects) took 48 s and 47 s, the tool step 104 s and 105 s; the smoke list
about 40 s per generation.

## The first semantic slice (tp115, boot115f): no frontend time at stake

tp115 changes the kernel (design §4.4: the code links, the native reset on a write of code, the lifetime of the records,
the failure-atomic write path of fix05) and the frontend only in what it emits (`lmx_arena_ref_store(l2_program_arena,
…)`), so the frontend step's time is the previous slice's and is not measured as a pair; the runtime step (kernel L2 → L1 →
C) took 36 s and 36 s, and every program now runs the driver's start-up self-check of the code links (38 checks on a
private arena) before its own main — not visible in the smoke list's wall time at this scale. The six attempts boot115…
boot115f (fix01–fix06: three translation refusals, one C compile error, the reset's `parent` climb, Codex's P1-A/P1-B) are
the cost of the slice, 5 to 15 minutes each; standalone module translations caught two of the six before a bootstrap. The remaining targets of the frontend step are the ones named above (method-name scans, the
owner memo's re-check, the M2 pass).

## The second semantic slice (tp116, boot116): the activation chain costs no measurable time

tp116 (design §4.5, B1) adds to every activation of either executor a record pushed and popped in the C frame of the
trampoline or the walker (a memset and six stores), to every native method's prologue one `lmx_activation_bind` per used
own field (a C-heap list grown by doubling, freed with the record) and one `if` per consumed hidden input, and to every
call site with a hidden input that has no schema a `lmx_walk_value_free_mark` in place of the formed value; the resolver
runs once per free input at the callee's entry, by text comparison of the names of the records up the chain. The
bootstrap boot116c's wall time is boot115f's within the machine's drift: 796 s against 962 s; the frontend step (the
self-build of the frontend, unchanged in what it does for its own code -- the frontend has no hidden inputs) 248 s and
246 s, the runtime step 34 s and 34 s. The driver's start-up self-check grows from 38 to 60 checks. The cost of the slice is
again the attempts, not the product: ten stagings, seven isolated runtime builds (8 s to a refusal, about 55 s to a pass) and
three bootstraps -- the isolated `build-runtime` of the new tool over the stage is the cheap conclusive check of a
kernel change, and the standalone module translations the cheap check of a frontend change; both ran before boot116. What
neither catches is a run-time fault of the driver's own self-check: boot116 built G1 (frontend, runtime, tool) and every
smoke program crashed at start-up on a memset through a pointer local not yet assigned (a text slip of the slice's own
editing); relinking one built smoke program against the fixed driver.o (two seconds) showed the fix before boot116b, which
passed. What the bootstrap's smoke list does not run either is the slice's own fixture: the focus suite on boot116b's G2 gave it
81 in both modes, and gdb on the built program found the resolver right and the method reading other arrays than the record
held (its generated wrapper projects the caller's); the walker side named a field's value storage, not its cell. Both are
fix10; the forced program relinked against the new driver.o passed at once, the native one needed the new frontend -- boot116c.

## Slice269 / boot131b (Codex, 2026-11-03)

Whole quick805.29s:06:52:55.3079527Z--07:06:20.5968097Z, both generations
smoke9/0. Actual G2 focus30/0 at07:07:43.6906557Z--07:10:33.1409856Z.
Source182/A4E6CC19; all248 artifact paths per generation independently hashed,
245 raw-equal and3 PE metadata-only differences. This is a whole-pipeline
measurement, not a same-context translation-speed claim.
[Commands, failures, fixes and current hashes](steps/witnesses/fix269-20261103/notes.md).

## Slice270 / boot132c (Codex, 2026-11-03)

Whole quick879.95s:11:10:05.7616252Z–11:24:45.7090672Z, both generations
smoke9/0. G2 focus32/0; G2 observation confirms9 walked bodies and counts.
Source184/E4D1E376; all248 artifact paths per generation independently
hashed,245 raw-equal and3 PE metadata-only. This is a whole-pipeline
measurement, not a controlled translation-speed comparison.
[Commands, failures, fixes and hashes](steps/witnesses/fix270-20261103/notes.md).

## Slice271 / boot133a (Opus, 2026-11-03)

Whole quick 1119.42 s: 12:08:22.5906238Z–12:27:02.0057253Z, both generations
smoke 9/0. G2 focus 33/0, 378.43 s: 12:33:17.9583254Z–12:39:36.3851812Z.
Source 185/66B15DB1; all 248 artifact paths per generation independently
hashed, 245 raw-equal and 3 PE metadata-only. This is a whole-pipeline
measurement, not a controlled translation-speed comparison; no cause is
claimed for the difference from boot132c's 879.95 s.
[Commands, results and hashes](steps/witnesses/fix271-20261103/notes.md).

## Slice272 / boot134b (Opus, 2026-11-03)

Whole quick 1105.43 s: 15:07:14.6776444Z–15:25:40.1074512Z, both generations
smoke 9/0. G2 focus 36/0, 231.30 s: 15:26:32.8514172Z–15:30:24.1524334Z.
Source 188/B9CCD9A5; all 248 artifact paths per generation independently
hashed, 245 raw-equal and 3 PE metadata-only. This is a whole-pipeline
measurement, not a controlled translation-speed comparison.
[Commands, results and hashes](steps/witnesses/fix272-20261103/notes.md).

## Slice273 / boot135a (Opus, 2026-11-03)

Whole quick 1044.82 s: 16:00:57.2597788Z–16:18:22.0790541Z, both generations
smoke 9/0. G2 focus 37/0, 251.64 s: 16:19:22.7347109Z–16:23:34.3741423Z.
Source 189/985904FD; 248 artifact paths per generation, 245 raw-equal and 3 PE
metadata-only. A whole-pipeline measurement, not a controlled comparison.
[Commands, results and hashes](steps/witnesses/fix273-20261103/notes.md).

## Slice274 / boot136a (Opus, 2026-11-03)

Whole quick 1008.67 s: 17:47:03.2298107Z–18:03:51.9011088Z, both generations
smoke 9/0. G2 focus 38/0, 256.83 s: 18:04:43.0334151Z–18:08:59.8595940Z.
Source 190/C1DC96BB; 248 artifact paths per generation, 245 raw-equal and 3 PE
metadata-only. A write of code now walks up twice (admission, then the drop) and a
word above it costs one scan of its code. A whole-pipeline measurement, not a
controlled comparison.
[Commands, results and hashes](steps/witnesses/fix274-20261103/notes.md).

## Slice275 / boot137b (Opus, 2026-11-03)

Whole quick 1094.96 s: 20:52:09.0295527Z–21:10:23.9890957Z, both generations
smoke 9/0. G2 focus 39/0, 304.29 s: 21:11:03.5190411Z–21:16:07.8052453Z.
Source 191/FBC3FA4E; 248 artifact paths per generation, 245 raw-equal and 3 PE
metadata-only. A typed path now reads a named root as a value (one range lookup) and
checks a field of the loaded record per inline step; a rebinding looks up its slot's
model row. boot137a took 1019 s on nearly the same bytes, so the 76 s spread is not
attributable to the change: a whole-pipeline measurement, not a controlled comparison.
[Commands, results and hashes](steps/witnesses/fix275-20261103/notes.md).

## Slice276 / boot138b (Opus, 2026-11-04)

Whole quick 997.39 s: 02:11:44.4899726Z–02:28:21.8842378Z, both generations
smoke 9/0. G2 focus 48/0, 402.79 s: 02:28:44.3975320Z–02:35:27.1867485Z.
Source 198/C34D7122; 248 artifact paths per generation, 245 raw-equal and 3 PE
metadata-only. A map step now calls one function; a missing number walks the arena's records once per reached edge. Each root
head adds a row to the name table. The first boot of this slice took about the same on nearly the same bytes:
a whole-pipeline measurement, not a controlled comparison.
[Commands, results and hashes](steps/witnesses/fix276-20261104/notes.md).

## Slice277 / boot139a (Opus, 2026-11-04)

Whole quick 768.44 s: 07:20:27.0341670Z–07:33:15.4709688Z, both generations
smoke 9/0. G2 focus 50/0, 399.56 s: 07:33:45.4038375Z–07:40:24.9685028Z.
Source 200/A82F39AC; 248 artifact paths per generation, 245 raw-equal and 3 PE
metadata-only. A map step with no record now receives one edge and restores the numbers the record had: `width * 2` words copied per
missing edge, once per use. A whole-pipeline measurement, not a controlled comparison.
[Commands, results and hashes](steps/witnesses/fix277-20261104/notes.md).

## Slice278 / boot140c (Opus, 2026-11-04)

Whole quick 772.93 s: 12:45:09.3781539Z–12:58:02.3097660Z, both generations
smoke 9/0. G2 focus 53/0, 476.23 s: 12:58:35.3796328Z–13:06:31.6085806Z.
Source 203/79F7879B; 248 artifact paths per generation, 245 raw-equal and 3 PE
metadata-only. A local written Structure is now a typed reference place, so a read of `T\y` goes through the admitted map instead of a direct slot. A whole-pipeline
measurement, not a controlled comparison.
[Commands, results and hashes](steps/witnesses/fix278-20261104/notes.md).

## Slice279 / boot141a (Opus, 2026-11-04)

Whole quick 846.95 s: 15:59:23.9478940Z–16:13:30.8965757Z, both generations
smoke 9/0. G2 focus 53/0, 562.38 s: 16:14:30.0635449Z–16:23:52.4408663Z.
Source 203/F1CDB823; 248 artifact paths per generation, 245 raw-equal and 3 PE
metadata-only. The role of a written form moved from a spelling to frame flags and a C name lost the definition's text, with no new pass. A whole-pipeline
measurement, not a controlled comparison.
[Commands, results and hashes](steps/witnesses/fix279-20261104/notes.md).

## Slice280 / boot142a (Opus, 2026-11-04)

Whole quick 1144.86 s: 20:13:46.5847167Z→20:32:51.4473608Z, both generations
smoke 9/0. G2 focus 53/0, 762.53 s: 20:33:48.8514820Z→20:46:31.3809652Z.
Source 203/1E5584C9; 248 artifact paths per generation, 245 raw-equal and 3 PE
metadata-only. A place's requirement is one more use plan per reached named root with a static table per place; no new pass. The same 4 rows alternating on both G2 took 318.5, 322.0, 321.0 s on slice279's and 320.4, 319.4, 319.9 s on this one, and the frontend builds by one translator rose between fe142c and fe142d on unchanged steps and in gcc itself. That shows no noticeable regression on those rows and supports the environment as an explanation of the rise over boot141a's 847 s; it does not by itself prove every component of the rise is environmental. The whole run is a pipeline measurement, the 4 rows a controlled comparison.
[Commands, results and hashes](steps/witnesses/fix280-20261104/notes.md).

## Slice281 / boot143a (Opus, 2026-11-04)

Whole quick 1201.50 s: 23:08:27.8454090Z→23:28:29.3404490Z, both generations
smoke 9/0. G2 focus 53/0, 786.62 s: 23:29:04.3064430Z→23:42:10.9247609Z.
Source 203/9FA1F933; 248 artifact paths per generation, 245 raw-equal and 3 PE
metadata-only. A write of a declared reference field moved to the store a Structure field uses; no new pass. A whole-pipeline
measurement, not a controlled comparison.
[Commands, results and hashes](steps/witnesses/fix281-20261104/notes.md).

## Slice282 / boot144b (Opus, 2026-11-05)

Whole quick 1178.29 s: 04:34:42.1669525Z→04:54:20.4543469Z, both generations
smoke 9/0. G2 focus 58/0, 807.90 s: 04:54:43.0470032Z→05:08:10.9513113Z.
Source 208/2370E8F5; 248 artifact paths per generation, 245 raw-equal and 3 PE
metadata-only. The frontend gained one linear syntactic pass over the bodies at the start of a translation; its cost was not measured apart. A whole-pipeline
measurement, not a controlled comparison.
[Commands, results and hashes](steps/witnesses/fix282-20261105/notes.md).

## Slice283 / boot145a (Opus, 2026-11-05)

Whole quick 810.18 s: 18:33:17.0533815Z→18:46:47.2344071Z, both generations
smoke 9/0. G2 focus 61/0, 755.20 s: 18:48:19.5596910Z→19:00:54.7629969Z.
Source 211/44404A52; 248 artifact paths per generation, 245 raw-equal and 3 PE
metadata-only. The walker now asks the selected call's admission on every call with no data of its own: a fn answers at once, a sub scans the names table. Its cost was not measured apart.
A whole-pipeline measurement, not a controlled comparison.
[Commands, results and hashes](steps/witnesses/fix283-20261105/notes.md).

## Slice284 / boot146a (Opus, 2026-11-05)

Whole quick 1096.06 s: 22:15:42.9514930Z→22:33:59.0131237Z, both generations
smoke 9/0. G2 focus 64/0, 884.79 s: 22:35:37.7276961Z→22:50:22.5172290Z.
Source 214/2A1D385A; 248 artifact paths per generation, 245 raw-equal and 3 PE
metadata-only. P0 sets one node flag per separator, and `@:` with a path as its second operand no longer resolves that path to choose its form. Neither was measured apart.
A whole-pipeline measurement, not a controlled comparison.
[Commands, results and hashes](steps/witnesses/fix284-20261105/notes.md).

## Slice285 / boot147a (Opus, 2026-11-06)

Whole quick 810.91 s: 03:57:21.2680811Z→04:10:52.1796326Z, both generations
smoke 9/0. G2 focus 66/0, 787.27 s: 04:12:11.4579529Z→04:25:18.7230643Z.
Source 216/FA0B57AC; 248 artifact paths per generation, 245 raw-equal and 3 PE
metadata-only. A `sub` takes the parts builder of `fn`; no pass or table was added. Not measured apart.
A whole-pipeline measurement, not a controlled comparison.
[Commands, results and hashes](steps/witnesses/fix285-20261106/notes.md).

## Slice286 / boot148b (Opus, 2026-11-06)

Whole quick 1137.97 s: 08:20:25.5851370Z→08:39:23.5598476Z, both generations
smoke 9/0. G2 focus 67/0, 973.48 s: 08:40:04.4472460Z→08:56:17.9230150Z.
Source 217/CDB1FB25; 248 artifact paths per generation, 245 raw-equal and 3 PE
metadata-only. A callable place's declaration is one field of the existing place row: the write admission
reads that row once, and the collection marks the declared callables of live slots in its existing fixed
point. Not measured apart. The slice's first whole, boot148a (1070.21 s,
07:06:35.8034024Z→07:24:26.0096975Z), ran before the declared-throws comparison and is superseded.
A whole-pipeline measurement, not a controlled comparison.
[Commands, results and hashes](steps/witnesses/fix286-20261106/notes.md).

## Slice287 / boot149b (Opus, 2026-11-06)

Whole quick 1155.00 s: 11:53:38.0142864Z→12:12:53.0093853Z, both generations
smoke 9/0. G2 focus 68/0, 1008.81 s: 12:14:17.1378063Z→12:31:05.9479113Z; full list
on G2 85/0, 929.21 s: 12:31:10.7526502Z→12:46:39.9651083Z.
Source 218/43142543; 248 artifact paths per generation, 245 raw-equal and 3 PE
metadata-only; the runtime objects equal slice286's G2 runtime. The walked index of a machine pointer
held by an own field or a formal is decided once per path step from the step's resolved fields; no pass
or table was added. Not measured apart. The slice's first whole, boot149a (1197.07 s,
10:43:18.7534207Z→11:03:15.8224590Z), ran before the index reception check and is superseded.
A whole-pipeline measurement, not a controlled comparison.
[Commands, results and hashes](steps/witnesses/fix287-20261106/notes.md).

## Slice288 / boot150a (Opus, 2026-11-06)

Whole quick 923.86 s: 15:48:40.1789044Z→16:04:04.0403247Z, both generations
smoke 9/0. The focus list 68/0 (896.20 s: 15:18:48.0615620Z→15:33:44.2578510Z) and the full list
85/0 (848.57 s: 15:33:48.4803583Z→15:47:57.0487114Z) ran on the candidate frontend fe150c, whose code
equals G2's up to the PE header bytes; probes on G2 10/0 (100.69 s). Source 218/61CBDA82; 248 artifact
paths per generation, 245 raw-equal and 3 PE metadata-only; the runtime objects equal slice287's G2
runtime. A native L3 INDEX of an own or formal pointer is now one kernel call per access instead of a C
index; no pass or table was added. Not measured apart. A whole-pipeline measurement, not a controlled
comparison.
[Commands, results and hashes](steps/witnesses/fix288-20261106/notes.md).

## Slice289 / boot151a (Opus, 2026-11-06)

Whole quick 647.20 s: 17:47:05.5415435Z→17:57:52.7447572Z, both generations
smoke 9/0. The focus list 68/0 (693.14 s: 17:23:10.6756949Z→17:34:43.8177012Z) and the full list
85/0 (645.27 s: 17:35:12.8834019Z→17:45:58.1519023Z) ran on the candidate frontend fe151a, which
`lmxtool exe-same` finds one image with G2's; probes on G2 14/0 (101.80 s). Source 221/D9F7391E; the
acceptance is 38 lmxtool commands (corrected by slice290: written 37), 0 failed (records closed on their
files, G1 and G2 equal by `exe-same`/`same`; the run and the count were a PS function of the recipe); the
runtime objects equal slice288's G2 runtime. An `int` index of the L3 INDEX now
calls the program's converter per access before the kernel's place selection; CHECK asks the same
reception as an Array level, no pass or table was added. Not measured apart. A whole-pipeline
measurement, not a controlled comparison.
[Commands, results and hashes](steps/witnesses/fix289-20261106/notes.md).

## Slice290 / boot152a (Opus, 2026-11-06)

Whole quick 692.99 s: 19:18:23.8732524Z→19:29:56.8679323Z, both generations
smoke 9/0. One union list on G2 — the rows of focus149, the rows of fullsuite149 not in it and the two
fixtures of slice290 — 99/0 (773.50 s: 19:31:23.1330066Z→19:44:16.6303714Z); probes on G2 6/0. Source
224/6767573C; the acceptance is one `lmxtool checks` list run by the G1 tool: the 38 commands of slice289,
0 failed, and a 39th candidate-tool comparison that cannot hold across stages (the tool root's unit prefix
hashes its source path), failed; the G2 tool's self-test 0 failures. The runtime objects equal slice289's
G2 runtime. An absent free input of a part method now gets its place by the default's type (one default
read at the entry); a walked SET_ARG of an input with a lexical source holds that source at the entry.
Not measured apart. A whole-pipeline measurement, not a controlled comparison.
[Commands, results and hashes](steps/witnesses/fix290-20261106/notes.md).

## Slice291 / boot153a (Opus, 2026-11-06)

Whole quick 656.49 s: 20:11:38.9606332Z→20:22:35.4530421Z, both generations
smoke 9/0. The 20 rows the maintained registry gained (fixtures 280–290) on G2: 20/0, 120 checks
(171.22 s: 20:24:02.3810309Z→20:26:53.5977140Z). Source 224/59160055; the acceptance is one `lmxtool
checks` list of 38 commands run by the working tool of boot152a, 0 failed, with no cross-stage tool line;
the G2 frontend is one image with slice290's (`exe-same`) and the runtime objects equal its G2 runtime;
the G2 tool's self-test 0 failures. Only the tool changed: the list runner sizes each line's word arrays
by its tabs. Not measured apart. A whole-pipeline measurement, not a controlled comparison.
[Commands, results and hashes](steps/witnesses/fix291-20261106/notes.md).

## Slice292 / boot154a (Opus, 2026-11-06)

Whole quick 647.31 s: 21:59:52.0549505Z→22:10:39.3633333Z, both generations smoke 9/0. The whole
maintained registry on the candidate frontend fe154c, `exe-same` with G2: 102/0, 880 checks (784.46 s:
21:28:43.4379087Z→21:41:47.9024973Z). Source 225/E9D6EBAE; the acceptance is one `lmxtool checks` list of
38 commands run by the working tool of boot153a, 0 failed; the runtime objects equal slice291's G2 runtime;
the G2 tool's self-test 0 failures. The own fields a method's body declares are laid out in its var (one more
pass over the body's direct fields while var is built); native code reaches a var place through
`lmx_call_index` over the selected data. Not measured apart. A whole-pipeline measurement, not a controlled
comparison.
[Commands, results and hashes](steps/witnesses/fix292-20261106/notes.md).

## Slice293 / boot155a (Opus, 2026-11-07)

Whole quick 667.71 s: 2026-11-06T23:57:33.4516477Z→2026-11-07T00:08:41.1613318Z, both generations smoke 9/0;
G0 is tool155a, the tool rebuilt from this package's tools/build.lm2 (one more kernel export). The whole
maintained registry on the candidate frontend fe155b and runtime rt155a, `exe-same` with G2 and byte-equal to
G2's runtime: 106/0, 904 checks (807.35 s: 23:25:10.0392205Z→23:38:37.3926197Z). Source 229/3C2AB9EB; the
acceptance is one `lmxtool checks` list of 38 commands run by the working tool of boot154a, 0 failed; the G2
tool's self-test 0 failures. A formal's literal default is one cell in its args entry; a native call reads
an omitted formal's default through one kernel call (`lmx_call_formal_default`), the walker checks the formal
entry of a suffix slot without an operand. Calls that omit nothing are unchanged. Not measured apart. A
whole-pipeline measurement, not a controlled comparison.
[Commands, results and hashes](steps/witnesses/fix293-20261106/notes.md).

## Slice294 / boot156a (Opus, 2026-11-07)

Whole quick 688.70 s: 01:33:22.4366990Z→01:44:51.1415445Z, both generations smoke 9/0; G0 is tool156a, the
tool rebuilt from this package's tools/build.lm2 (one more kernel export). The whole maintained registry on
the candidate frontend fe156a and runtime rt156b, `exe-same` with G2 and byte-equal to G2's runtime: 107/0,
909 checks (823.96 s: 01:19:12.5346139Z→01:32:56.4952980Z). Source 230/A9D768A6; the acceptance is one
`lmxtool checks` list of 38 commands run by the working tool of boot155a, 0 failed; the G2 tool's self-test
0 failures. A native call that names an actual or omits a formal makes one kernel call
(`lmx_call_bind_actuals`: the selected callable's headers, a name match per named actual, the permutation,
the defaults); a walked call that omits formals carries a shorter frame. Calls that write every formal by
position are unchanged. Not measured apart. A whole-pipeline measurement, not a controlled comparison.
[Commands, results and hashes](steps/witnesses/fix294-20261107/notes.md).

## Slice295 / boot157a (Opus, 2026-11-07)

Whole quick 745.39 s: 03:29:08.5957938Z→03:41:33.9821514Z, both generations smoke 9/0; G0 is the working tool of
boot156a (tools/build.lm2 is unchanged). The whole maintained registry on the candidate frontend fe157a and the
G2 runtime of boot156a (the kernel is unchanged; G2's runtime of boot157a is byte-equal to it), fe157a `exe-same`
with G2: 109/0, 921 checks (881.58 s: 02:54:30.2358854Z→03:09:11.8147647Z). Source 232/DC724B82; the acceptance
is one `lmxtool checks` list of 38 commands run by the working tool of boot156a, 0 failed (its first run failed one
line of the list itself, a lost tab); the G2 tool's self-test 0 failures. A declaration in an inline statement
of a fn or sub body is a place of its var: one more var slot per such name, no second cell in the nested list,
one registration search by the activation's host. Not measured apart. A whole-pipeline measurement, not a
controlled comparison. [Commands, results and hashes](steps/witnesses/fix295-20261107/notes.md).

## Slice296 / boot158a (Opus, 2026-11-07)

Whole quick 705.97 s: 04:52:41.7180387Z→05:04:27.6912682Z, both generations smoke 9/0; G0 is the working tool of
boot157a (tools/build.lm2 is unchanged). The whole maintained registry on the candidate frontend fe158b and the
G2 runtime of boot157a (the kernel is unchanged; G2's runtime of boot158a is byte-equal to it), fe158b `exe-same`
with G2: 110/0, 927 checks (883.72 s: 04:14:37.0262170Z→04:29:20.7420662Z). Source 234/B39CA2AA; the acceptance
is one `lmxtool checks` list of 38 commands run by the working tool of boot157a, 0 failed; the G2 tool's self-test
0 failures. A head written with a name tail and bound by nothing now builds a named Structure through the same
collection a literal tail took; one question of a declaration goes through an existing guard. Not measured apart.
A whole-pipeline measurement, not a controlled comparison. [Commands, results and hashes](steps/witnesses/fix296-20261107/notes.md).

## Slice297 / boot159a (Opus, 2026-11-07)

Whole quick 772.86 s: 07:15:04.6927947Z→07:27:57.5501415Z, both generations smoke 9/0; G0 is the working tool of
boot158a (tools/build.lm2 is unchanged). The kernel changed (lmx_walk_values): the candidate runtime rt159b was built
by the working tool of boot158a and its G2 frontend, and G2's runtime of boot159a is byte-equal to it. The whole
maintained registry on the candidate frontend fe159c and rt159b, fe159c `exe-same` with G2: 111/0, 933 checks
(977.54 s: 06:31:33.1793262Z→06:47:50.7238810Z; the failed first registry on fe159b and rt159a took 979.57 s). Source
235/F2DD70E2; the acceptance is one `lmxtool checks` list of 38 commands run by the working tool of boot158a, 0
failed; the G2 tool's self-test 0 failures. The registry took 93.82 s more than 296's with one row more; the new
per-receive range check of a contextual literal (`lmx_walk_value_lit_fits`) and the changed rows were not measured
apart, so the cause is not located. A whole-pipeline measurement, not a controlled comparison.
[Commands, results and hashes](steps/witnesses/fix297-20261107/notes.md).

## Slice298 / boot160a (Opus, 2026-11-07)

Whole quick 650.92 s: 08:36:15.2071276Z→08:47:06.1235754Z, both generations smoke 9/0; G0 is the working tool of
boot159a (tools/build.lm2 is unchanged). The whole maintained registry on the candidate frontend fe160a and the G2
runtime of boot159a (the kernel is unchanged; G2's runtime of boot160a is byte-equal to it), fe160a `exe-same` with G2:
111/0, 933 checks (1146.02 s: 08:10:09.7245638Z→08:29:15.7439021Z). Source 235/34A70535; the acceptance is one
`lmxtool checks` list of 38 commands run by the working tool of boot159a, 0 failed; the G2 tool's self-test 0 failures.
The collection of hidden inputs asks each call's head once more with its method current; a path call with named
actuals loses two hidden inputs. The registry took 168.48 s more than 297's on the same rows (one fixture with four more
methods; a docs render and a two-file copy of about a second each ran during it); not measured apart, the cause is not
located. A whole-pipeline measurement, not a controlled comparison.
[Commands, results and hashes](steps/witnesses/fix298-20261107/notes.md).

## Slice299 / boot161a (Opus, 2026-11-07)

Whole quick 682.88 s: 10:07:11.4604087Z→10:18:34.3405963Z, both generations smoke 9/0; G0 is the working tool of
boot160a (tools/build.lm2 is unchanged). The whole maintained registry on the candidate frontend fe161b and the G2
runtime of boot160a (the kernel is unchanged; G2's runtime of boot161a is byte-equal to it), fe161b `exe-same` with G2:
111/0, 934 checks (858.64 s: 09:28:07.3384403Z→09:42:25.9810535Z). The registry logs of 297 and 298 hold 934 PASS lines
too: the 933 reported for them missed the first line, which follows the log's UTF-8 byte order mark. Source
235/E2DBCE33; the acceptance is one `lmxtool checks` list of 38 commands run by the working tool of boot160a, 0 failed;
the G2 tool's self-test 0 failures. An unavailable route adds a packed record and one kernel reception only where a
program without the receiver reaches it; the self-build has no such reception. The registry took 287.38 s less than
298's with the same number of rows (three refused rows became three running ones); not measured apart, the cause is
not located. A whole-pipeline measurement, not a controlled comparison.
[Commands, results and hashes](steps/witnesses/fix299-20261107/notes.md).

## Slice300 / boot162a (Opus, 2026-11-07)

Whole quick 674.29 s: 11:14:51.5062014Z→11:26:05.7945638Z, both generations smoke 9/0; G0 is the working tool of
boot161a (tools/build.lm2 is unchanged). The whole maintained registry on the candidate frontend fe162a and the G2
runtime of boot161a (the kernel is unchanged; G2's runtime of boot162a is byte-equal to it), fe162a `exe-same` with G2:
112/0, 940 checks (852.68 s: 10:46:39.5912481Z→11:00:52.2746187Z; counted with the log's byte order mark). Source
236/FF8A8238; the acceptance is one `lmxtool checks` list of 38 commands run by the working tool of boot161a, 0 failed;
the G2 tool's self-test 0 failures. A pair the conversion table has no row of takes 299's route: a packed record and one
kernel reception only where a program reaches it (the frontend of 299, which refuses such a pair, translated this
source, so the self-build has none). A reached single-field repeat at a place its written type cannot be received by
adds a zero record of the written type and one kernel reception; whether the self-build holds one was not measured.
The registry took 5.96 s less than 299's with one more row; not measured apart, the cause is not located. A
whole-pipeline measurement, not a controlled comparison.
[Commands, results and hashes](steps/witnesses/fix300-20261107/notes.md).
