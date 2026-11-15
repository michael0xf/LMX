# Slice398: complete scalar working Values in GraphRun

Status: bounded code acceptance PASS; actual G1/G2 quick/fixedpoint and Graph checks PASS.
Targeted suite has three unchanged baseline header-source refusals; render/fresh docs check/final index PASS.
Baseline397: `68aa72a1365d9429774f655563f03ccc6e6242a5`, main. Root is the only code/test/build writer.

## Change and scope

Existing `LmxGraphWork` now keeps an inline complete scalar Value alongside the original physical cell/slot,
legacy number and loaded/dirty state. Exact pool/ABI/companion proof recognizes scalar FOREIGN independently of
the old Graph.kind subset. A physical Model supplies an absent ABI witness until the actual is loaded; mismatches
including legacy actuals refuse before reading. Absent actual metadata survives without reading payload bytes.

Ordinary Code runs over supplied typed DATA through the existing `lmx_graph_call_data` frame mechanism.
Reads and operands snapshot bytes/context. Destination selection precedes RHS; a stable row index reacquires
the row after RHS. The common FOREIGN writer's pure `prepare_scalar_store` validates destination ABI and guards,
preserving declared destination SOURCE and RHS Model/context. The explicit working producer owns exact bytes.
Dirty publication uses the old physical writer, clears dirty after success, retains the local snapshot and never
replaces the DATA cell/slot. Clean rows are not republished or reloaded after nested calls. GC marks the full row Value.

Native graph emission, typed args/results, scalar constructors/literals, public own fields, fn_data/merge,
the execution-wide direct cache and explicit flush remain OPEN in the main v3 plan. Scalar formal/free mutation
refuses before RHS until its existing activation place is extended. This is neither full Model admission nor M14 completion.

## Inputs and private gates

Artifact stage: `build2/codex_fix250generationchain01/sol-m13-graph-scalars-01`.
Run directory: `build2/codex_fix250generationchain01/runs/sol-m13-graph-scalars-20261115-01`.
Seed: accepted397's genuine G2 frontend/backend/runtime bundle.

- Source11:933, frozen/canonical SHA256 `d45261dc7f56f2734df8d7e41a3bc52c010bf8eeb8f65417b130ba8445d089e8`;
  normal manifest/stage-copy and verify repo/stage PASS.
- Transitional Tool01 SHA256 `0200d7360814f630b2d157123881a171b8b573e4b14f20d63308f06b42580df4`.
  It uses the accepted397 runtime and only generates the new common layout; its algorithm never creates GraphWork rows.
- Runtime03 builds the new Work layout, WalkValues186 and GC through the normal full runtime recipe.
- Source10 changes only GraphRun's Model/absence handling and the test. Recorded Run retry05 PASS; its changed
  C declaration is regenerated. Runtime04 reuses all other successful translations and passes aggregate/prod/observe CC.
  Prod SHA256 `65e5a94f664eed4e414daa2024265226fed04259ff3d85727b1cb81a28398770`;
  observed SHA256 `24cb9ed18a2da3bb034d04156ce75dee217010c0008d330582ada9913208f3f3`.
- Source11 changes only the unit to use public `work_open_data` with a real parsed Read sub for Model-entry checks;
  no API or runtime change follows. Unit SHA256 `1a4a8cb44f707ff2aacba8f5d0353548cf3d7f2cf411a69402d47ce7700e1d74`.
- Private06 SUITE1/0 PASS, ordinary owner n/f/root0/root1. The assertions use the C ABI; parsed ordinary
  Copy/Fill/Snapshot bodies actually execute through GraphRun over supplied double DATA. Their execution is not a
  native-graph-emission claim. Epsilon/3.5 bytes, distinct SOURCE aliases, Model, stable cell/slot, float→double refusal
  without mutation, poisoned unfilled storage, absent Model-entry metadata and snapshot after publication all pass.

## GC sensitivity

The Touch native callback is a real Code entry over the supplied DATA, not a fake method. It changes physical
x/y to Model B, then removes every old Model A edge from all FOREIGN companions in that physical pool's chunks.
Models use separate profiled STRUCT pools, so coarse chunk marking cannot make the oracle pass accidentally.
The outer frame's complete working Values must alone retain Model A during the actual sweep. After resumption,
saved receives the original epsilon/Model A snapshot; clean physical x/y retain 3.5/Model B.

`runtime-graph-scalars-gc-mutant01` omits only the full row.Value mark in the artifact-stage GC source.
Actual GC L2 translation, aggregate and prod CC pass; already built Private06 owner objects are relinked.
Both n/f with root0/root1 produce the dedicated lost-Model result96, accepted by the existing driver with expected96.
The healthy source and generated GC body are restored in finally; subsequent normal stage verify PASS.
Private06's healthy result7 and this mutant96 establish that the GC oracle exercises the new edge.

## Recorded corrections

Runtime01/02 and recorded Run retry03 fail on internal L2 calls with untyped imported C-member arguments.
Source04/05 add explicit types/cache the selected physical cell; recorded retry04 passes.
Source06 fixes the analogous GC Value pointer cast. Runtime03 then passes the complete recipe.
Private01 refuses the unsupported fractional literal; Source07 uses the ordinary C producer `strtod`.
Private02/03 expose Snapshot status5: a namespace had not been opened after parsing. Source09 uses standard
space_open/close, and Private04 passes. Private05's new Model oracle fails CC because open_parts is private;
Source11 uses the existing public entry instead, and Private06 passes. Earlier failed records remain available.

The canonical manifest is generated with selfbuild as the input root; failed administrative manifest invocations
were corrected before freeze/verify. No maintained auxiliary runner or alternative parser was introduced.

## Final gates

Genuine Whole01 G1/G2 quick PASS with9 smoke rows/0 failures each, consumed closure360.
Fixedpoint11 CHECKS30/0 PASS, including canonical933/verify and Runtime04==G2 driver.
Actual G2 frontend SHA256 `09b7ad2a699c75bd1e097e42e5f21861b052776fb17f8c835a5bfb163625693b`;
Tool SHA256 `510f0c157020436ff90a02527ef4044bbfcdad2176d8385cc6ec9aed74c543ae`.
G2 Graph01 SHA256 `ed1bc637aa13d8e53a58d070d3c6d48e07d4d7e9326a6bc43848998fa7be4f62`;
Graph3 triple CHECKS3/0 PASS, including the original missing-model build4 refusal.

G2 targeted01 reports SUITE9 rows/6 failures. Six rows pass n/f/root0/root1: data_source_cells,
declared_source_interface, exact_scalar_storage, execution_gc_roots, public_scalar_calls and graph_scalar_working.
The other three cases refuse at L2 in both n/f: struct_call_selected:21, unary_data_selection:20 and place_map:87,
with `a declared header lost its original receiving source`. No C compilation follows those refusals.
Baseline397-header-controls01 replays only the three native L2 argv with accepted397's actual frontend;
all three return1, produce exactly the same first diagnostic and leave no L1. Thus this is an unchanged prior
compiler blocker, not a new398 regression. The aggregate suite remains FAIL; no expected result is changed.
The main v3 now prioritizes the common original receiving-source fix before the mapped copier/fn_data bridge.

Actual G2 render01 PASS35 paired chapters/14 cases/both source snapshots; generated semantics and grammar unchanged.
Fresh docs-check01 with precreated cwd/private directories PASS35/14/27/44/615, links/LF28285.
Final indexed01 with separate fresh cwd/private PASS35/14/27/44/615, links/LF28287;16 owned files staged.
Working/index diff checks PASS. Both foreign untracked files and their original hashes are retained and excluded.
These final receipt lines are verification outputs, not new semantic inputs. Commit/push follows directly on main.
Goal remains ACTIVE; continue the main v3 plan.
