# Slice400: common mapped copier and written DATA

Baseline399: c46e556a31257159efafcec6750cedfd9c59cc28, directly on main.
Root is the sole code/test/build writer. Helpers performed read-only reviews; two unrelated untracked files are preserved.
Goal remains ACTIVE. Full overlap merge and complete M11/M13/M14 remain OPEN.

## Change and limits

The existing CopyMap/CopyStack now also support synchronous same-arena Graph construction.
The operation policy preserves physical profiles, defers Value edges and allocates ordinary parts when copying a held F.
The graph operation uses policy7 during reserve and5 during drain; policy0 preserves previous copy behavior.
The target role is selected before allocation. No shared pool is retagged.
CopyMap has a new ABI field: generated headers and their runtime must agree on its size.

FOREIGN values snapshot context before allocation or callbacks; absent payload is initialized but never copied from poison bytes.
The destination companion temporarily retains the full snapshot. Scalar and reference completion share the existing relocation
workers and queue with complete copies. References also keep one saved snapshot rather than rereading the source during drain.
WORD is a pointer-sized physical cell containing the process-lifetime canonical TEXT pointer; the copy keeps its full type
and selected physical profile while preserving shared/distinct cell identity.

Written DATA fn_data seeds written→new vars before reserving fields, completes CODE-own places, then drains once.
The Graph consumer projects copied names, immutable slot facts and mapped parents. The receiving vars keeps its own parent,
name and completed width. A copied held F consists of ordinary current parts; only explicit fn creates another callable.
Construction has no intermediate publication, dispatch, Model/test execution or GC window. The existing caller owns cleanup.
No new parser, registry, graph copy for execution, assignment journal or separate scalar copier is introduced.

This slice does not implement full overlapping merge or public scalar CODE-own declarations, Graph typed arguments/results,
FFI/Foreign-Array or the common cache/flush and ordinary native execution required by M14.

## Inputs and runtime

Stage: `build2/codex_fix250generationchain01/sol-m13-mapped-data-01`.
Run directory: `build2/codex_fix250generationchain01/runs/sol-m13-mapped-data-20261115-01`.
Seed: accepted399 actual G2. Its source manifest was verified before generated src/headers were copied and maintained inputs overlaid.

Transitional Tool01 was built with coherent seed399 headers/runtime and does not instantiate CopyMap.
Its SHA is bd32b1744c014b0f574bfd086034cb566ce743f38cb6a42b4d6b3c7ce07bc4cd.
It generates the new CopyMap layout and CopyOwned30 exports. Runtime01's prefix passed through ValueOwned/Graph;
Run then refused an untyped C-field first argument before a later nested call. Source02 adds an explicit arena cast.
Recorded Run retry02 passed. Runtime02 reuses the successful prefix and resumes the genuine recorded seed399 suffix with
new paths and exports. The first recovery stopped administratively because --machine preceded --library; corrected recovery03
passed121 steps, including97 real header commands, aggregate generation and production/observed C compilation.

Runtime02 driver.c SHA: 0edc124c6cde32b12cbe9168c9ba5d7e0f9ade073310cd51e84580ca72e7c625.
Runtime02 production SHA: cf5bbc1dd4189932e75eb17c8af4be5907c1b240c694d763046f99a6ae5b4102.
Runtime02 observed SHA: a71a0b885f6855f58c6a851b89146885d9f2b447464b03c0d6276f68481437d7.

Frozen/canonical Source04 contains934 inputs; SHA c5c4960f2549e7b8ba9cf05433f8bc5c48d35cfa50236c12c7869922617aabfb.
Normal manifest/stage-copy and repo/stage verification passed. Sources are frozen while the sequential producer runs.

## Focused acceptance

Maintained [graph_fn_data_typed](../../../selfbuild/tests/dyn/graph_fn_data_typed.lm2) uses C ABI setup/assertions around real
parsed sub/fn construction and ordinary Code execution. It supplies exact double bytes and independent double/f64 SOURCEs.
Before/after callbacks prove Model→new DATA, preserved receiving SOURCE, epsilon/3.5 precision, unchanged source DATA,
absence without poison copying, WORD sharing/profile, self-backedge, names, CODE-own touched and held ordinary parts.
Explicit Again starts from held current count3 and advances independently to4; the original remains3.
The final callback marks/sweeps only after construction/drain/publication and repeats the assertions.
A separate existing cross-arena copy API proves shared/distinct WORD cells, explicit destination profile and canonical
TEXT lifetime after the source graph/arena are released and destination GC runs.

The initial test draft was corrected during review to pass and dispose the mandatory relocated map and initialize both maps.
Private01 then refused the reserved local name profile; Source04 renames it physical.
Private02: SUITE1/0 PASS, native/forced and root0/root1. The machine assertion body is native C ABI in both modes;
the enclosed parsed ordinary Code exercises GraphRun, so this is not a claim that arbitrary typed Code is compiled natively.

Controls01 stopped at schema because a shell data expression concatenated four TSV rows.
The corrected data-only Controls02 passed SUITE4/0: exact_scalar_storage, graph_scalar_working,
public_scalar_calls and execution_gc_native, each native/forced/root0/root1. Expected results were not changed.

## Final gates

Whole bootstrap01 is terminal PASS: genuine source-built G1/G2 quick, smoke9/0 in each generation and364 consumed inputs.
Fixedpoint04 CHECKS32/0 PASS: generated frontend/tool L1/C, executable images apart from link timestamps,
runtime production/observed, retained headers including CopyOwned, canonical934 and repo/stage/consumed-input verification.
Private Runtime02 and actual G2 runtime are byte-identical in both variants.
Actual G2 frontend SHA: a42f15833c27cd753efcaebe1475e3cb2c22987cdae8431a70de5762655e14d9.
Actual G2 Tool SHA: 440a8ef655095c5631a3f70d95b0bdbe8f72b157b3274845b4ca6fdd8dad8c58.
Actual G2 targeted01: SUITE5/0 PASS native/forced/root0/root1, the new unit plus the same four controls.
G2 Graph01 SHA: cfd8aab4a02322be83c822432ea0d3ee8023b8e58a6c958f7e622f5101969a1a.
Graph6 CHECKS6/0 PASS in interp/native/forced: copy_callable_current, copy_held_state, copy_named_parts,
construction_paths_owned_data, declared_model_interface and the original declared_model_missing refusal4.
All code/test producers are terminal. Actual G2 render01 PASS35 paired semantic chapters/14 implements cases/both snapshots;
generated semantics and grammar are unchanged. Fresh docs-check01, in separate precreated cwd/private directories,
PASS35/14/27/44/615, links and LF28288. Working-tree diff check PASS.
The final index with17 owned files is checked before commit/push, directly on main. Both unrelated untracked files
and their hashes are preserved. Final indexed01 in separate fresh cwd/private directories passed35/14/27/44/615,
links and LF28290. Working/index diff checks PASS. Commit/push is directly on main, followed by the planned overlap merge.
The goal and full M11/M13/M14 remain ACTIVE/OPEN.
