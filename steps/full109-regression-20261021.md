# Full109 regression — started, no verdict yet

Codex is the sole writer/build;goal ACTIVE. This is a frozen-input start
receipt,not a completed gate or a promotion of public dev. It follows
[the measured copy/rollback slice](copy-carry-rollback-20261021.md).

## Exact scope and start

Base commit:`66d72211b31017002bdbd6ed0edeb8a66c3eb4bb`.
`build/codex_catalog109_full_prepare_01.ps1` completed0. It copied all3209
frozen full103 source inputs and verified every logical SHA. Only these
five files differ,each byte-identical to targeted/value-tested109:

| Source | SHA256 of tested109 input |
| --- | --- |
| l2trans.lm1 | CEC453A719244A80BBA7C2A2A9AFEA5B92FB351E2CE88F1D2E3627A3101A8D30 |
| lmx_arena.lm1 | E855CE2642F62D3684E81ECD913D6C7B03DD846DB6DEB9035FE116D966105247 |
| lmx_gc_graph.lm1 | F31B1E84F09C83356F424B70C87F233DB94043AFD83A136B5BC1789071720C10 |
| lmx_graph_copy_owned.lm1 | 035935EAE0CB7AF1559B6C963FDF4260D24A8333E148018EB5336AFAB6E69E95 |
| lmx_merge_owned.lm1 | 164A6383E11780E3B0C59E726C630F274969D9C2260D1B717E86A3DE7FEA8E66 |

Header remains103/109 SHA
`E970F85869F5C8DEADAB98562F8C520EFEED8E84DA88BEEFDE0B10865F81E50A`.
The only added input is the already published105 dynamic-negative source
`tests/unit_at_third_candidate_dynamic_refused.lm2`:3210 source files total.
No positive source/oracle is weakened or reclassified by this recipe.

All36 current tracked tools are frozen together. The harness carries the
published static/dynamic negative-phase audit and its real current789-check
template fixture,not the earlier mixed773/789 snapshot. Only harness root,
sandbox,and the two root-relative tools dependencies are mechanically bound
to these exact frozen directories. The pair-plan60/2 and original arena
table54/2 are not silently replaced by private improved test sources.

`build/codex_catalog109_full_01.inputs.sha256` contains3251 pins including
the source/tools snapshots,explicit L1 translator/pin,GCC and both recipes.
Manifest SHA256:
`95B89735B7F4B271ED36228C90BB59CABBB00BF9E5C534FE3ADBB6E1DACB85C8`.
`build/codex_catalog109_full_prepared_01.json` records exact before/after
hashes and source inventory. Every pin is checked again before execution.

`build/codex_catalog109_full_01.ps1` runs with `-KeepAll`,one GCC pipeline.
Session50874/PID3896,startUTC`2026-10-21T07:34:32.8593621Z`.
Output:`build/l2_harness/codex_catalog109_full_01`.
Harness log:`build/codex_catalog109_full_01.log`.
Launch log:`build/codex_catalog109_full_launch_01.log`.
The staged input and generated compiler/driver closure are being built;
silence in the main log is not a reason to duplicate/restart the worker.
Actual target count,FAIL inventory and comparison remain to be measured.

## Reversible storage recovery, completed

`build/codex_completed_bins_repack_109_01.ps1` LZX-compressed only the
explicitly validated,completed full100/full103 `bin/*.exe` directories.
It required their terminal3752/1015 and3752/1012 summaries before touching
storage. All2244+2253 original exe logical SHA256 values/counts match after
compression;no source,evidence or binary was deleted. Ordinary byte streams
are unchanged and transparent compression is reversible.

Its receipt is `build/codex_completed_bins_repack_109_01/results.json`,with
per-run before hashes and compact logs alongside. Measured free bytes:
1413541888→2798669824;the new frozen snapshot was also prepared during this
interval,so the net free-space change is not an isolated compression size.
New gate output directories use ordinary transparent NTFS compression.

Neither this preparation nor earlier320 compiler/154 value GREENs close
the current giving-Model producer,indexed copy,full clean kernel or §§8/8a.
The hourly `lmx-goal` heartbeat already exists and remains ACTIVE;no duplicate
was created and the existing goal was not paused or replaced.
