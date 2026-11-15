# Slice401: typed overlapping merge and physical field aliases

Code baseline400: a7a8f0dc82c9e3bf3d2d534a452101e30a6b439a, directly on main.
The author-prepared replacement call-frame documentation was accepted separately as
a3efab9209ba0fdac508ce488a542796980b5f6a, preserving this code WIP.
Root was the sole code/test/build writer; helpers reviewed read-only. Two unrelated untracked files remain untouched.

## Change and limits

GraphRun merge uses the existing mapped copier and queue. A finite receiving-group closure joins shared source
parts before final-width allocation. The retained layout preserves first-model occurrences and later named fields.
All receiving headers are mapped before reserving Value edges. Each group's canonical CHILDREN backing,
source-slot aliases, first places and late aliases are prepared before its children in actual root-first layout order.
Existing fields_bind preserves shared and noncontiguous physical cells. A temporary operation map terminates cycles.

Composed REF_LMX Value cells are reserved with deferred payloads; late cells alias only when their original
pointees map to the same receiving composition. A pointer to that Value cell remains distinct from a pointer
to its CHILDREN slot or its Structure target. Scalar stores read the original RHS through the existing exact ABI
writer; receiving SOURCE and physical identity remain stable, while full context edges finish through common drain.
WORD overrides update the copied cell in place, preserving its physical type/profile and aliases.
Ordered replay preserves repeated operands and sibling Q/R/Q contributions; the cycle guard belongs only to the active path.
Receiving root metadata is selected by the merge layout rather than overwritten by ordinal projection from later roots.

Graph84 adds explicit-context get_in/put_in. Managed Graph/Run, frontend, builder and emitted runtime consumers
use the existing physical resolver; slot keys and invalidation use canonical ref_cell_in. Legacy raw ABI remains
for direct-backed callers. put_in is a constructor fill, not the ordinary admission/protected store interface.
The two scratch merge records are emitted by the existing L2 decl_arena recipe. No maintained L1/C source,
new parser, execution registry, universal assignment journal or parallel runner was introduced.

These changes are checked on the earlier execution model. They do not implement the new M14 unified call namespace,
removal of local publication, code snapshot, actual-based native signatures or grouped sys tools.
Frozen index facts still exist in this runtime and are the next deletion task, together with their tables/transfers/emission.
Full typed image support and CHILDREN alias topology in the native image emitter remain OPEN in the main v3 plan.
The current image emitter preserves header/value identity but allocates separate backing for each header.
Generic reference replacement, qualifiers and the remaining M11/M13/M14 work are not claimed complete.

## Inputs and build

Stage: `build2/codex_fix250generationchain01/sol-m13-overlap-01`.
Receipts: `build2/codex_fix250generationchain01/runs/sol-m13-overlap-20261115-01`.
Seed: accepted400 actual G2. Canonical Source07 contains934 inputs and was verified against repo and stage.
Manifest SHA: 6d77aba13d762338c965c8ca80e8582f69149f9f7305b8ad5ab26b0da9950d66.

Initial Source02 refused a reserved local name; Source03 renamed it and added the real parsed merge oracle.
Run retry03 then exposed scratch declarations placed in a body-only unit. Source04 moved them to the existing
generated arena header. Tool02's initial CC lacked an arena header after a failed runtime cleared stage headers;
recorded CC/LD recovery reused coherent accepted400 headers plus the unit's genuine Methods header.
No maintained source or generated C was hand-patched. Runtime02 passed normally.
Source05 fixed WORD replacement/aliasing and singleton replay reset; recorded Run/runtime suffix reuse passed.
Private01 passed the expanded original unit. Source06 added three physical-alias oracles and reproduced all three
failures on Runtime03: parent152, shared slots156 and reference Value-cell159, consistently in n/f and both roots.

Source07 fixes those failures and migrates managed consumers. Fresh Tool03 passed normally:
47f679364068283ca228b1c9d0810af02fe9e5fd52a04b2336b54ecdcae69576.
Runtime04 passed normally with98 regenerated headers; driver.c SHA:
212a8d019e3b06bc990923bd70ee6173eca693aa2e6fed40fc0c77b1c64b5b2d.
Production: 946ca1804bd45b2880680f1a227574a8f7397ba513d0f798b11901a882d7e1aa.
Observed: 35962b94851043425c675ec178357478f2359fef9c5206100d4c28770ef38941.

## Acceptance

The maintained [graph_fn_data_typed unit](../../../selfbuild/tests/dyn/graph_fn_data_typed.lm2) retains the
previous real sub/ordinary Code checks and now executes parsed merge(M;N), merge(M;N;M), exact double/f64
overrides, Model/backedges, late scalar-cell and CHILDREN pointers, sibling shared compositions with Q/R/Q replay,
WORD aliases/profile, singleton non-reset, parent-before-child scalar aliases, shared physical slots and a pointer
to the composed late REF_LMX Value cell. Float/double incompatibility refuses without publishing the receiving value.
Shared-slot acceptance checks initial value5 through both managed reads before writing9 through one index;
the other index sees9, the source stays unchanged and the result's real slots share one new cell.
The machine assertion body is native C ABI in both modes; the enclosed parsed ordinary Code exercises GraphRun.
This is not evidence that arbitrary typed ordinary Code is compiled natively under the new M14.

Private03: SUITE1/0 PASS, native/forced and root0/root1.
Controls01: SUITE4/0 PASS, exact_scalar_storage, graph_scalar_working, public_scalar_calls and execution_gc_native.
Expected results were not changed. Whole bootstrap01: genuine source-built G1/G2 quick, smoke9/0 each,
364 consumed inputs. Fixedpoint01: CHECKS36/0, generated frontend/tool L1/C, runtime, executable images apart
from link timestamps, retained ABI headers, canonical934 and consumed-input verification.
Private Runtime04 equals actual G2 production and observed objects byte-for-byte.

Actual G2 frontend: 9bd2a1704e0c4475b091d2c08b58ca5cc0cad6f12270b4cdc908e3fee88bc788.
Actual G2 Tool: 1e999065f98a35ae8f14c5ba691a6a0b64584332593aa58d2f911b22ae5a3177.
Actual G2 targeted01: SUITE5/0 PASS, the expanded unit plus the same four controls, n/f/root0/root1.
Actual G2 Graph01: 713e61b7fa67a78ff7f2048f2c8def762f160c0213c61c2818e5ef053c0166a6.
Graph6: CHECKS6/0 PASS interp/native/forced for copy_callable_current, copy_held_state, copy_named_parts,
construction_paths_owned_data, declared_model_interface and the original declared_model_missing refusal4.

All code producers are terminal. Documentation was regenerated and checked for the separate author-document slice:
35 paired chapters/14 cases,27 grammar sections,44 verified excerpts,615 imports, links/LF28291.
Render grammar reports47 source excerpts in its generation inventory. Initial stale grammar and a later book edit
during the checker were resolved with fresh generation and indexed04 acceptance. Generated files were not edited by hand.
The final code/status index is checked before the separate code commit/push, directly on main.
Goal remains ACTIVE; replacement M14 is OPEN and takes priority over historical publication/CODE-own tasks.
Final indexed05 passed35/14/27/44/615, links/LF28292; final canonical repo verification passed934/0.
Both working and cached diff checks passed with18 owned code/status files staged. Commit and push are directly
on main; the two unrelated untracked files retain their original hashes. Next work removes the superseded
index-slot fact mechanism and its consumers under the replacement M14.
