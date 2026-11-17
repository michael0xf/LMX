# LMX kernel implementation specification: the Lmx graph, primitives, the arena, names

**Norm of 2026-11-16:** [the value record](#value-record) -- the physical type and the value lie in one record; a type is
no longer learnt from an address range ([L2 §3](L2_spec_en.md#value-record), [plan M15](../next_core_tasks_v3.md#typed-value-records)).
Dated records below that speak of typed regions describe the earlier scheme and the present code.

**Norm of 2026-11-15:** [local frames without write-back](LMX_semantics.en.md#call-frame-20261115),
[single M14 and sys tools](../next_core_tasks_v3.md#native-structures). Dated records below describe implementation history;
their load-dirty, shared-cache, and flush references are not tasks to continue those mechanisms.

**Slice401, 2026-11-15 -- typed overlap merge; bounded code gates PASS.**
Receiving closure fixes final layouts before Value edges; the common copier preserves scalar/WORD,
shared CHILDREN and reference Value cells. Graph84 get_in/put_in take explicit Graph context;
the legacy raw ABI remains for direct backing. Source07:934, G1/G2 quick/fixedpoint36,
G2 targeted5/0 and Graph6 triple PASS. This uses the earlier execution model; replacement M14 remains OPEN.
[Witness401](../steps/witnesses/m13-overlap-20261115/notes.md).


**Slice400, 2026-11-15 -- common mapped copier and written DATA fn_data; code gates PASS.**
Source04:934, genuine G1/G2 quick/fixedpoint32, actual G2 targeted5/0 and Graph6 triple PASS.
Full overlap merge, scalar CODE-own and native/cache/flush M14 remain OPEN.
[Witness400](../steps/witnesses/m13-mapped-data-20261115/notes.md), [current pipeline](../steps/current.md).

**Slice399, 2026-11-15 -- written SOURCE and hidden transport; code gates PASS.** The common header-source
refusal and scalar FREE default metadata output are fixed. Written SOURCE and Model/capture admission guards are preserved.
Genuine G1/G2 quick/fixedpoint30, actual G2 targeted13/0 and Graph3 triple PASS; render/fresh docs check/final index PASS.
[Current status](../steps/current.md). Common copier/construction and native M14 remain OPEN.

**Slice398, 2026-11-15 -- complete scalar Value in GraphRun working rows.** Ordinary Code over supplied typed DATA
preserves physical cell/slot, the place's SOURCE and RHS Model. Private06 and the sensitive GC mutant passed;
genuine G1/G2 quick/fixedpoint30 and Graph3 triple PASS. Actual G2:6 of9 rows PASS;3 existing L2 header-source
refusals reproduce on accepted397 and remain OPEN. G2 render35/14, fresh docs check and final index PASS.
Native/typed args/results/construction,
the shared cache and flush remain OPEN. [Current status](../steps/current.md).

**Slice397, 2026-11-15 -- owned scalar receiving and formal places; bounded code gates PASS.**
Complete ACTIVE SOURCE is canonicalized by the existing counted TEXT interner separately from physical ABI.
Scalar actuals/returns retain the complete Value; the callee current Value and lazy mutable place are separate.
The first store/address creates its own cell and subsequent addresses are stable; an escaped pointer retains
the arena companion after activation exit. Direct stores update current; a read after an alias write refreshes
it from the companion and produces a snapshot. Runtime08/private13 SUITE1/0 covers a real dispatcher/scratch exit/GC.
FE07 raw/hosted ordinary-witness05/06 OSWALK0 confirms precision/store/address/caller isolation native/walker.
Source28:932/canonical, genuine G1/G2 quick smoke9/0, fixedpoint29 and actual G2 targeted6/0,
ordinary-witness07/Graph3 triple PASS. G2 render35/14 and fresh docs-check01 PASS35/14/27/44/615, links/LF28283;
the final index is checked before commit. Semantics source and grammar are unchanged.
Typed Run/FFI/Foreign-Array and the shared M14 cache/flush remain OPEN. [Witness397](../steps/witnesses/m13-scalar-receiving-20261115/notes.md).

**Slice396, 2026-11-15 -- public scalar resolver; bounded code gates PASS.**
The common frontend interner retains the source word, pointer depth, const and raw-C role; native printing
selects the exact scalar spelling from the active primitive.description. Translation-owned aliases use the
existing L1 type emitter; runtime row numbers and equal C spellings do not become semantic identity.
Public scalar machine units, including a separate reordered ACTIVE table with ProbeReal, pass private gates;
an ordinary method with double*** passes native/walker and root0/root1. Machine FP assertions remain native.
Whole01 genuine G1/G2 quick/fixedpoint29/canonical931, actual G2 recovery16 and Graph3 triple PASS.
Recovery reuses built objects after correcting the mistaken prod path; targeted01 SUITE is not reported as PASS.
G2 render35/14, fresh docs-check02 and indexed01 PASS35/14/27/44/615, links/LF28277/28283.
Owned scalar actual/result, runtime receiving/Run/FFI/Foreign-Array and the shared cache/flush remain OPEN.
Exact artifacts and acceptance limits are in [witness396](../steps/witnesses/m13-public-scalars-20261115/notes.md).

**Slice395, 2026-11-15 -- runtime/native execution GC roots; bounded code gates PASS.**
Before sweep, the marker visits existing activation/call_places, working frames and complete Values.
Temporary borrowed spans belong to the execution arena and detach before rewind/free; their owning scratch chunks
are retained explicitly, without treating scratch words as graph edges. Physical pool.profile is a separate live dependency.
Runtime02 and targeted collect/reclaim/pending PRIM/standalone Frame/native C ABI cases pass n/f/root0/root1.
The native emitter395 attaches working/pending Values and selected places to the same spans; existing statement,
loop/pad and inner branch scopes determine cleanup, and the trampoline drops body roots before the next poll.
Source27:927/Frontend04: the ordinary GC fixture passes native/walker and root0/root1, including a working snapshot after
clearing physical DATA, pending actuals, loops, short-circuit, catch and subsequent reclamation. Whole G1/G2 quick/fixedpoint31 PASS.
Public resolver/typed Run/receiving/FFI/Foreign-Array, the shared cache/flush and complete M11/M13/M14 remain OPEN.

**Current state, 2026-11-14, slice394 -- exact scalar ABI foundation; bounded code gates and docs-check PASS.**
The same35 Source rows generate header type aliases and profile bodies for32 scalar bindings (§3.2):
None/void have no cells, FILE remains opaque without a guessed binding. Source identity, C ABI and physical profile remain separate.
The machine C ABI unit passed native/forced with an ordinary owner and root0/root1: all32 bindings, float/double/flong precision,
i64/u64 limits, ABI rejection/protected write without mutation, immutable identity with nonzero physicalProfile,
and copy/projection/qualification/GC. FP assertions remain in the native C ABI unit; this does not establish general L3 FP execution.
Ordinary Graph.kind for Foreign remains0; SourceFact reads proven typed metadata before that fallback (§3.5).
Public primitive→frontend resolution, Run working/receiving/FFI, activation/pending GC roots and Foreign-Array ABI remain OPEN.
Source16:925, genuine G1/G2 quick with9 smoke each/fixedpoint20 PASS; actual G2 targeted4 n/f/root0/root1 and Graph3 triple PASS.
G2 render35/14, fresh docs-check01 and final indexed01 PASS; links/LF28270/28273.
Full acceptance of the common bridge and M11/M13/M14 is not claimed.

**Previous state, 2026-11-14, slice393 -- an operation-local SourceReader for source interface; bounded code acceptance/docs-check PASS.**
The common implements worker receives the selected Source's name/fact through a reader borrowed by the current operation (§3.5).
The full literal35-row/15-column projection of `primitive.description` is separate from physical `Fact.type` and ABI;
equal C spellings do not unify source contracts. All33 cell-row identity controls passed in private L2 native/forced
with root0/1. The qualifier chain is retained; references/Array give UNKNOWN without reading payloads.
Construction of direct three-argument `@` checks known candidate/Model by interface only: a proven missing Model field
refuses, `test` does not execute, and raw Model/default remain. No typed storage or runtime admission is claimed.
Actual G1/G2 quick/fixedpoint15, G2 interp23/AFTER22/image48, Unit08 and legacy2 PASS; this does not establish full
typed storage/runtime admission or M11/M13/M14. Render35/14 and docs-check01 PASS; the final index is checked before commit.

**Previous state, 2026-11-14, slice392 -- bounded code gates and docs-check01 passed.**
`declaration_parts` borrows the receiving leaf/model/candidate and presence/known while retaining the original root;
DATA logical names require a proven declaring contract (§3.5). The C-spelling projection extends the existing generated
primitive profile; `c_names` proves source-spelling roles without unifying C types with language aliases.
Arbitrary `c.*` remains provisional UNKNOWN. Construction does not turn receiving chains and their groups into DATA scopes;
model/default and unsupported qualified/Array/deep/typed forms stay raw, with no typed storage/admission claimed.
Final private Runtime06/Graph02: SHA-256 prefixes `fe17a328`/`69eab914`; frozen Source08:919, SHA-256
`b8b1b9b6095610b03bd26c80bc5c4988be3cfdc3c7b0eab0512a0c3994f44909`.
Private21: every interp/native/forced case and15 complete negative AFTER checks PASS; construction_shape_presence passes with its existing expected file.
Six new pairs; role oracles effects1/arithmetic15/called6/indexed12/via_whole13/done1.
Whole02: genuine G1/G2, nine smoke cases each, and tool PASS. Fixedpoint:13 artifact checks and2 canonical checks PASS after
canonical907→919 regeneration, without rebuilding artifacts. The genuine G2Graph SHA9c44994b is built;
actual G2 interp21/full AFTER21 PASS. Its42 emitted native/forced images and2 libc/backend files match byte-for-byte —44 PASS;
ready private binaries were reused without a new compilation or native/forced rerun.
The actual G1 frontend confirmed profile byte equality with quoted FILE; normal profile SHA-256
`d91946148a1c06809cd9ccd1a25a94cac303876a3032070ecb2fc7104a9facd5`; G1/G2 frontend exe equality PASS.
G2 render35 paired/14 cases/both snapshots PASS, with unchanged generated semantics and grammar.
Docs-check01/final index02 PASS35/14/27/44/615, links/LF28235/28262; commit/push392 follow. [Record392](../steps/witnesses/m11-receiving-view-20261114/notes.md)
retains the complete checks and history of intermediate attempts.
General typed storage/admission and the actual C-door bridge, full M11.7/8, M13/M14 and runtime `merge`/`sys\fromLmx` remain OPEN.

**Previous state, 2026-11-14, slice391 -- bounded implementation; code gates and docs-check passed.**
Only Run changes: private `construct_slot`/`construct_atom`/`construct_value` helpers extend bounded constructor390
to proven paths. Exports Graph75/Run58, ABI, layout and the public API are unchanged. A named step uses
`step_index`; a numeric index selects a physical slot and preserves its immediate value without turning raw `fn` into F
or resolving a WORD as a Structure name.
Only literal indices are used; index expressions are not executed. A named path retains exact source → F
and the existing masks (§3.5). Typed/qualified/common admission, full M11.7/8, M13/M14 and new construction
during runtime `merge`/`sys\fromLmx` remain OPEN; a held F without a native entry uses the walker.
6 sources/5 expected files were added, including `construction_paths_owned_data`; final Source07:907, SHA-256
`329fba48883be5014759e1fc74c4236873286c6050b69567c4ce3206f23ce9c3`.
The previous Source03/private48 triple and39 complete AFTER checks passed before the last correction, including43 existing
cases with unchanged expectations; this is an intermediate result, not final acceptance391. The combined probe
covers18 contexts/31 leaf oracles; a separate F.data probe checks two runs: initial11, bare8/9, held11/current9;
producer values change through `:=` to existing places. Graph01's index/atom distinction bug is corrected in Graph02;
the false EXPR pending blocker is also corrected. Final review found a missing pending audit for actual F.data,
which was outside the materialization queue: a method and a bodyless descriptor gave4 instead of2. Private `construct_data_scope`
corrects recognition of its lexical role without a materialization/blueprint walk; new Runtime03/Graph03 and the focused
check passed: method/descriptor2/2, data width2/2. Runtime03 SHA-256
`6a6105346ea9e3b841556ff5d29582dca09767931e7cc7bc9d2f88abad437582`, Graph03 SHA-256
`7aad957de36545b74dc225c2214f302357b9bcf48a3ab41ca4f44cc6e1af37c6`.
The owner stopped the first whole bootstrap01; its processes are terminated, with no acceptance claimed.
Private02: all49 cases in interp/native/forced and39 complete AFTER checks passed; the previous43 cases' expectations are unchanged.
Whole `boot-m11-construction-paths-02` passed: genuine G1/G2, nine smoke cases each, fixedpoint15/verify907 PASS;
private Runtime03 matches the G2 driver. Intermediate Source06 differs from verified Source05 only in formatting two
new fixture sources: a redundant single-level `end` after a bootstrap terminal was removed. Complete AFTER results match for2 cases,
and four generated native/forced programs match byte-for-byte. Source07 additionally removes redundant trailing blank lines
from the six new fixture sources:10 generated native/forced programs match the previous genuine G2 outputs byte-for-byte,
build4 control PASS, fixedpoint03:15/verify907 PASS. Core and compiler-build inputs are unchanged;
no additional whole was run for these fixture-only corrections. The genuine G2 graph-tool is built, SHA-256
`0cc869f7c12b9b3d7ae57aec8957602fcfaabe0750759ab9f5a131195f17b5a5`.
The G2 repeat of all49 cases in three modes and negative AFTER39 passed. Render35/14 PASS, generated content/grammar unchanged;
Fresh docs-check01 PASS35/14/27/44/615, links/LF28142; final index391 is checked before commit.

**Previous state, 2026-11-14, slice390 -- bounded implementation, code checks and docs-check passed.**
After filling the P0 fields, `lm_graph_build_root` calls `lmx_graph_construct`, then a separate pure preflight (§1a).
Construction owns a fresh namespace; held F values remain ordinary graph values, while raw `fn`/`sub`
remain written declarations. Source-known reference candidates fill places without executing CODE,
defaults, computed actuals or `test`; mutable aliases stay deferred (§3.5).
Private43 in three modes, including 36 existing cases, and 33 complete AFTER checks passed. Separately,18 logical interpreter
probes and2 FN-image cases in three modes passed. The initial mutable-alias mismatch1 instead of2 and native-image parent0/allocator failure are corrected.
Whole `boot-m11-known-data-01` quick passed: genuine G1/G2, nine smoke cases each, fixedpoint15/verify896 PASS;
private Runtime03 matches the G2 driver. The genuine G2 graph-tool is built, SHA-256
`17d12ce77360e99af075fb90967e0b7aef76f94985566a89e49b617d4bfd058a`; the G2 repeat of all 43 cases in interp/native/forced
and 33 complete negative AFTER checks on existing binaries passed. All code gates390 PASS.
Normal render35/14 and fresh docs-check01 PASS35/14/27/44/615, links/LF28087; final index before commit.
This route is bounded to direct two-argument `@`; paths, type fields and new construction
during runtime `merge`/`sys\fromLmx` remain OPEN. A held F without a native entry uses the walker.
Full M11.7/8 and M13/M14 remain OPEN.

**Previous state, 2026-11-14, slice388 -- bounded code and documentary acceptance are confirmed; commit/push follow.**
An occurrence and a literal exact name differ by the structure of the right step of the existing path3 (§3.3):
common `Graph.occurrence` (Graph74) reads an ordinary anonymous pair, and `Run.step`/`step_place` take a raw step (Run54).
The same reader, admission and native use this selection; P0 preserves quoted components through the common head scanner.
13 new cases passed in three modes; another 7 existing cases passed after golden formatting corrections only:
20/21 in aggregate. Genuine G1/G2 whole quick passed nine smoke cases each; fixedpoint15/verify867 PASS.
The genuine G2 graph-tool is built, SHA-256 prefix `0fcf70f9`; the G2 repeat gives the same 20/21, with all 13 new cases PASS.
9 full negative AFTER checks passed by reusing the existing binaries.
`root_occurrence_index` answers run3 under both seed387 and the new code;
its numeric seen3 expectation is retained, and the common declaration-site → frame map remains OPEN.
Source06:867, SHA-256 prefix `19d3d5dc`. Normal render and docs-check01 PASS35/14/27/44/615, links/LF27962;
Final index-check02 PASS, links/LF28021; commit/push388 to main follow.
Full M11.7/8 and M13/M14 remain OPEN.

**Previous state, 2026-11-14, slice384 -- bounded implementation, code acceptance passed; base383 `58bc7f3a`.** Direct named actuals of `fn`/`sub`
bind formals through `:=` only; `by_head`/mode2 and the former `frame_value` are removed from Run.
A whole descriptor is read as DATA: its colon fields are retained without execution. Structure formals `args`/`data`/`code`
read an actual through common `read_received_value` with contract2: a written group is inert, an unknown named Frame reaches
application and refuses3. `name`/`return` retain their written-description contract, including `@: c.FILE`.
`fn_decl_name` is a graph-only query: direct supply is separate from one whole-DATA descriptor, with no recursive
unwrapping or Space dependency (§3.4). The direct/whole-DATA positive pair gives12/12;
reception order gives effects1/later0/refusal5, and a retained code group with a missing call has length1 without effects.
Runtime01/Graph01, private32 triple,87 full AFTER checks,2 baseline checks and mutation24 passed.
The first private32 retains3 FAILs: stale fn_prepared/call_receivers goldens and a static name at emit5.
Seed383 confirmed six full AFTER checks; only13 synthetic RHS parenthesis lines were corrected, with numbers retained.
The static-name probe and emit5 are retained: no native runtime was created for it. A new reached-name case with computed args
and name-call/finally were checked by private02 on two new sources in three modes:5/before1/after0 and cleanup1.
Source03 SHA-256 `ac0d0a1ca48bfdb488c44982ada095ef2e7516dd304831d5987a735c55f13e9f`.
Whole bootstrap quick passed: genuine G1/G2, nine smoke cases each; fixedpoint13/verify798 PASS.
Native trace02 confirmed actual root → `fn_apply` → `receiver_bind` evaluate1 → actual native producer:
effects1/later0/body0/before1/after0, expected host exit1. The first GDB01 with missing args is retained and is not counted as proof.
The genuine G2 graph-tool is built, SHA-256 `09f0e983a7baa2b892bd755c5845495355062e673b41ff6556a02a6899004f82`;
G2 repeat:32 triple/21 full negative AFTER checks/mutation24 PASS. Tested code tuple384:
boot-m11-receiver-actuals-01/g2 + graph-m11-receiver-actuals-g2-01.
Normal render/docs check384 passed:35/14/27/44/615, links/LF; commit/push main follows.
A common catalog/declaration view and formal validation are OPEN M11.5e;
the working frontend's `by_head` is OPEN M11.8; full M11, external/computed CodeBody and M13/M14 remain OPEN.

**Previous state, 2026-11-14, slice383; base382 `d0e384c1`.** Only Run changed:
the common resolver distinguishes a pure query from a consuming read with a local status. Consuming raw fn/sub
without an F for the corresponding scope/source prepares the reached block through existing `space_declarations`/evaluate0;
sibling written methods are prepared in the existing order. Classification, slot requirements and binder queries stay pure
and do not re-enter a receiver being constructed. A constructor failure keeps its answer rather than becoming missing3.
The source/parent proof also covers the enclosing `node`. Copier, `fn_data`, Frame and Run53 ABI are unchanged;
there is no new registry/error field, SourceSpace transfer or restoration of FN-role on an ordinary F copy.
10 pure cases passed: raw Fn1/2/sub2/marks25 with source3; unentered1/2; named parts7/7;
held aliases8/8/8/9 with source3/next4; explicit clone4/5/source3; ordinary descriptor5;
malformed constructor5/before1/after0, pending3/touch0, ambiguity3; two walks give source1/held3.
Private34 triple gave32 PASS and two differences only in synthetic assignment RHS parentheses of existing
reference_alias/descriptor_merge. Seed382 confirmed that same shape through six full AFTER checks;
four parenthesis lines were corrected, with numbers retained. All102 full AFTER checks on the same binaries and mutation24 passed.
The trace confirmed actual native root → consuming declaration → scope preparation7/7 and normal exit;
a new callable may use the walker, M14 OPEN. Code was built on Source01:761; Source02 adds10 fixture pairs,
Source03 changes only four existing parenthesis lines:781 inputs, SHA-256
`4a7ed184d976b820d605f14c2e9a33970b16e0dae54c0ae95e83c35d9b5e5604`.
Whole bootstrap quick passed: genuine G1/G2, nine smoke cases each; fixedpoint13/verify781 PASS. The genuine G2 graph-tool is built,
SHA-256 `10dbb1b4dab7e7dd3395ea441d8a481ec795e6992bf60f3afa0be91bc0e35b59`.
The G2 repeat (34 cases in three modes, including runs2; 33 full negative AFTER checks; mutation24) passed;
Normal render/docs check383 passed:35/14/27/44/615, links/LF.
The working tuple is383: boot-m11-copy-bindings-01/g2 + graph-m11-copy-bindings-g2-01.
This is a bounded check of the copy classes; full M11, remaining5e/7/8, external/computed CodeBody,
native copy and M13/M14 remain OPEN.

**Previous state, 2026-11-14, slice382; base381 `38cf026c`.** Common `code_body` returns
borrowed `body/from/to` through existing control-argument roles (§6.3). For the whole
`else`/`finally` tail, a sole written group is selected as the body once; an already selected body or its remainder
is not unwrapped again. The scanner, `fn_own`, walker, native and `code_parent` use that same selection,
without changing physical parents or adding a frame or registry; exports are Graph71/Run53/implements74.
Runtime01/Graph01 and five pure cases passed: calls4 instead of2, cleanup trace21 instead of1,
written Fn790/computed890 instead of90, own late7/cleanup return4-after5/inert fields0,
including unknown inside a double group; the negative case gives6 with cleanup/root trace21.
Code was built on Source01:751; Source02:761 adds only five fixture pairs, SHA-256
`be5db8e3168082a1509b5b035f7d293b0f8ec40a6092c321b247647443e04d7f`.
Private25 triple/75 full AFTER checks/mutation24 and native written/computed outer/fn_apply trace passed.
Genuine G1/G2 quick with nine smoke cases each, fixedpoint13 and verify761 passed. The genuine G2 graph-tool is built,
SHA-256 `f71df0958fda2d9be2e958b70fcd3b081e2248305aa07a68a7dbf6eda5b89316`.
The G2 repeat (25 cases in three modes, 21 full negative AFTER checks, mutation24) and normal render/docs check382
passed:35/14/27/44/615, links/LF. The working tuple is382: boot-m11-codebody-01/g2 + graph-m11-codebody-g2-01.
External or computed CodeBody,
copying raw declarations and held F as distinct values, full M11, M11.7/8 and M13/M14 remain OPEN.
Acceptance of the copy classes is separated in the [plan reading](../steps/handoff/copy-construction-reading-20261114.md):
source Space bindings are not transferred, and applying `fn` anew remains a separate construction.

**Previous state, 2026-11-14, slice381; base380 `c5ba5ef9`.** The existing frame's `lexical_scope`
tracks the selected physical CodeBody, preserving `code`/`body`/`data`; the walker and native share
`work_scope` (§6.3). Runtime06/graph02, 17 pure cases, the previous 67 full AFTER checks unchanged,
private31 in three modes, AFTER93 and mutation24 passed on Source07:751. The final emitter-only optimization
covers the first statement with the entry prefix without a repeated call. Graph03/private02 inline triple and native trace
passed on Source08:751, SHA-256 `b84c11fec03b4eb7fa7a35db19ebf732be8ab13975191eb704207dab0961e906`.
The trace confirmed actual native outer, `work_scope` and `fn_apply`. Genuine G1/G2 quick with nine smoke cases each,
fixedpoint13 and verify751 passed. The genuine G2 graph-tool is built, SHA-256
`b8abfe4c58cc5702009aa09f65ce0a9b040aec403602c1c31eec88989fbcce4f`.
The genuine G2 repeat (86 cases in three modes, 102 full negative AFTER checks, mutation24) passed;
normal render/docs check381 passed:35/14/27/44/615, links/LF. The working tuple is boot-m11-computed-body-01/g2
and graph-m11-computed-body-g2-01; [record](../steps/witnesses/m11-computed-body-20261114/notes.md).
Full M11, copying a live F with its data and M13/M14 remain OPEN; a dynamically created callee may
use walker fallback, which does not establish ordinary native M14.

**Previous state, 2026-11-14, slice 378 -- acceptance passed.** Two core sources change:
the root uses the common work frame and block0; the native wrapper finishes that frame and forced reuses it.
The separate root emitter is removed. Scalar values stand without capture; discarded AST uses the common value reader,
and computed body bindings use existing metadata/rows. Runtime01/graph01 and five pure cases passed.
Private01 executed 50 cases in three modes: 48 matched their old goldens, 2 required five independently derived
root snapshot k5 changes: three outside8→5, data_result118→115, second892→592;
open_result55 is retained. The existing 50 binaries were not rebuilt. Additional root_frame_error passed triple;
in total 51 cases executed in three modes, all 153 complete AFTER comparisons and mutation24 passed.
finally_body_error/sub_error previously had no expected files; complete AFTER checks with root_trace12/seen12 were added.
Three existing fixture pairs now use explicit control Frames. Source04: 685, SHA-256:
b8e7d5a1a3742540b298ac30f0f1c2cc2f72fa776a358d14258ab1bd77e935d4.
Whole bootstrap01 quick passed genuine G1/G2, nine smoke rows each, fixedpoint13/verify685. Genuine G2 rebuilt
graph-tool and repeated 51 cases in three modes, AFTER60/mutation24; runtime01 matches G2.
Render/docs check passed:35/14/27/44/615, links and LF27517; both diff checks are clean, actual native root trace01 passed.
Working tuple: boot-m11-root-frame-01/g2 and graph-m11-root-frame-g2-01.
G2 graph SHA-256: dff1d7202b123be1758e88248960da8ba6f64aed57929729ba8edf453255eed7.
Full M11.5г, path-head calls,
computed ordinary declarations, M11.7/8, legacy computed-int construction M13 and shared cache/flush/ordinary native M14 remain OPEN.
[Witness 378](../steps/witnesses/m11-root-frame-20261114/notes.md).

**Previous state, 2026-11-14, slice 377 -- accepted `04fbf275`.** Only `lmx_graph_run.lm2` changes in the core:
frame opening prepares written fn/sub in selected data/body before work scan, and repeated preparation reuses
the existing scope/raw-source binding. State preserves F and its own data: first1/second2, leaf_count2/sub_count2,
bumped2. Separate D/C give 32/34, data_count12/code_count22, touch_calls0. Two leaf declarations at different
raw sources remain distinct occurrences; bare leaf refuses with 3 before the body, before1/after0. Source02:673;
private38 in three modes and AFTER45/mutation24 passed. Whole bootstrap01 quick passed genuine G1/G2,
nine smoke rows each, fixedpoint13/verify673. Genuine G2 rebuilt graph-tool and repeated 38 in three modes,
AFTER45/mutation24; runtime02 matches G2. Normal render/docs check passed:
35/14/27/44/615, links and index LF27467; both diff checks are clean.
Source02 SHA-256: 1441737c4cf71b27ab81c4734846f1b30a469326f7146f1dc86c33f74f8e4fa9.
Working tuple: boot-m11-ordinary-nested-01/g2 and graph-m11-ordinary-nested-g2-01.
G2 graph SHA-256: 039e29be84a420aa7ace00c0ba6003472bb56146c3fb5a40093aba124d6d2f5a.
The whole of M11.5г, root-frame work, computed ordinary declarations, M11.7/8, M13 and ordinary native M14 remain OPEN.
[Witness 377](../steps/witnesses/m11-ordinary-nested-20261114/notes.md).

**Previous state, 2026-11-14, slice 376 -- accepted `9039fa89`.** Canonical `@: p int`
without a candidate preallocates wrapper8/cell5 before index/typeof/path; a required formal8 receives an independent
reference cell through common admission. Source04: 669; runtime02/graph03, five pure cases, private36 in three modes,
AFTER42/mutation24 passed. Actual native TypeOnly with physical8 in method.code was confirmed by GDB trace03
in the private pipeline with a normal exit. Whole bootstrap01 quick passed: genuine G1/G2, nine smoke rows each,
fixedpoint13/verify669. Genuine G2 rebuilt graph-tool and repeated 36 in three modes,
AFTER42/mutation24; runtime02 is identical to the rebuilt runtime. Working tuple:
boot-m11-uninit-reference-01/g2 and graph-m11-uninit-reference-g2-01. Normal render/docs check passed:
35/14/27/44/615, links and index LF27434; both diff checks are clean. G2 direct trace01 also passed.
Source04 SHA-256: de34eb33fb7f603d1ed08c8bf7f69da0c7ffe5cd473d3408f9e770f5e6840daf.
M11.7/8, the whole of M11, M13 and ordinary native M14 remain open.
[Witness 376](../steps/witnesses/m11-uninit-reference-20261114/notes.md).

**Previous state, 2026-11-14, slice 373 -- computed reference places; code acceptance passed.** The existing work map
binds a retained raw `@` Frame with a candidate: three fields for an int reference, two for a Structure reference.
Admission does not run the initializer. Reading or launching that place before a working write refuses with 5;
the first write creates a working typed reference, and normal flush publishes it through the existing slot.
Existing initialized cells and wrappers retain their contract. `@: p int` without a candidate is OPEN:
it requires kind5 and already allocated wrapper8/cell5; the form currently refuses explicitly with 5,
is never treated as kind6 and does not allocate storage lazily. This is not refusal based on uninit:T contents.
Runtime02/graph01 passed six pure-interpreter cases: places 41/13/30/23 with calls0; read and head -- 5
after before1 with calls0; reference and numeric preflight -- 4 with calls0; binding priority 7/8/9/12 with calls0.
Full bootstrap quick built genuine G1/G2, nine smoke rows each; thirteen fixed-point checks and 643 inputs passed.
Genuine G2/graph repeated22 in three modes, AFTER24 and mutation24. Normal rendering and docs check passed:
35/14/27/44/615, links and LF for 27,317 indexed files; both diff checks are clean.
An independent probe reopened the M8 consumer for @2 with a written one-field Structure; it comes next.
The whole of M11.5г, the shared root route and ordinary Structure native in M14 remain OPEN.
[Current slice and limits](../steps/current.md).

**2026-11-14, slice 372 -- root/self dispatch, M11.5г OPEN.** A named head is resolved against live data
and calls a method or launches an ordinary Structure through the shared mechanism, including the root and a self launch.
A standalone written anonymous Structure remains a value: its fields do not execute or add inputs or own places;
selected control bodies and directly consumed expressions retain their roles. The private bundle passed sixteen cases
in interp/native/forced, three complete AFTER comparisons and mutation. Full bootstrap quick built genuine G1/G2,
nine smoke rows each; thirteen fixed-point checks and 631 canonical inputs passed. Genuine G2/graph repeated eighteen
cases in three modes, AFTER3 and mutation24. Normal rendering and docs check passed:
35/14/27/44/615, links and LF for 27,273 indexed files; both diff checks are clean.
Root numeric/reference publication and direct calls through path heads still need the shared
route; the whole of M11.5г, the following 5д–5е, M11.7/8 and M13/M14 remain open.
[Current checks and limits](../steps/current.md). The chronology below retains the results and limits of its own slices.

Paired version -- [RU](kernel-implementation.ru.md). The normative sources of the language are the [L3 semantics](LMX_semantics.en.md),
the [grammar](LMX_grammar.en.md), [L2](L2_spec_en.md) and [L1](L1_spec_en.md); this document is the specification of the
**implementation** of the kernel and of the code it emits, by the author's directive of 2026-11-08 (the author's words
verbatim -- the [journal](../LMX_blog/2026-11-08.md), the sections "Остановка инкрементальных кодов идентификаторов…",
"Атом — единственная не-структура…", "namespace — служебные таблицы обхода…", "Чистый граф…", "Единый механизм
неинициализированных примитивов…", "Все проверки — по адресам в арене…", "Замена указателя — при первом присваивании",
"Служебные операторы и ресиверы — без отдельных кодов…", "Термин: примитив, не атом…", "«int без инициализации» —
указатель на ту самую ячейку…"; the relays CODEX-FABLE-AUTHOR-KERNEL-REBUILD-20261108T171209823Z-01,
CODEX-FABLE-AUTHOR-ATOM-ADDRESS-20261108T172249908Z-01, CODEX-FABLE-AUTHOR-NAMESPACE-TRAVERSAL-20261108T172512156Z-01,
CODEX-FABLE-AUTHOR-CLEAN-GRAPH-FRESH-TRAVERSAL-20261108T172943665Z-01,
CODEX-FABLE-AUTHOR-UNIFIED-UNINITIALIZED-TYPES-20261108T180019959Z-01,
CODEX-FABLE-AUTHOR-ARENA-ADDRESS-VERIFICATION-20261108T180226654Z-01,
CODEX-FABLE-AUTHOR-FIRST-ASSIGNMENT-ONLY-20261108T181027312Z-01,
CODEX-FABLE-AUTHOR-OPERATORS-STRING-ADDRESSES-20261108T181832549Z-01,
CODEX-FABLE-AUTHOR-PRIMITIVE-TERMINOLOGY-20261108T182057865Z-01,
CODEX-FABLE-AUTHOR-UNINIT-POINTER-SAME-CELL-20261108T190254726Z-01; Codex's reviews
CODEX-FABLE-KERNEL-SPEC-REVIEW-20261108T175116933Z-01 and CODEX-FABLE-KERNEL-SPEC-REVIEW2-20261108T185727823Z-01 are applied).
Status: **the working specification of the transition; Codex has not declared the document accepted as a whole** -- the
direction and the order of §11 item 0 were allowed by the second review, the implementation has started from the
independent base; there are no open questions to the author. Marks: "norm" -- the author's words or the current book;
"decision" -- the implementer's choice within the norm, checked by Codex. The record of the slices below calls the
parts of a callable as the slice called them -- `var`, `body` -- and writes the order of the two arguments of `call` as
`call: code data`; by the author's decision of 2026-11-11 the parts are `data` and `code` and the order is
`call: data code`, and the clean graph reads them since slice 354 (§3.4).

Codex's graph10/tool11/rt07 implementation executes the Point/take example of §10 and used-field checks through both
consumers; [evidence and limits](../steps/witnesses/clean-call-20261108/notes.md). This is a partial migration:
int results, a body with one return, empty var, positional arguments and int defaults are supported.
The next [graph11/tool11/rt08](../steps/witnesses/clean-expr-20261108/notes.md) normalizes supported expressions:
a binary operation is Lmx [left, operator word, right], a prefix operation [operator word, operand]; construction sets
the nesting and respects P0 separators. Both consumers read this form without precedence parsing. The remaining
operators, body, admission, primitive and root forms are not implemented yet. The specification below
states the target, rather than claiming that the entire existing runtime conforms to it.

The [graph15/tool12/rt12 continuation](../steps/witnesses/working-var-20261108/notes.md) supports explicit int var and
sequential fn bodies: assignments, calls and return. Working values belong to each activation, while actual fields
stay in var; dirty values are published after argument evaluation before a call and on exit, including an error.
Native computes the body itself using the shared working-place and publication mechanism. All 24 execution checks
and 19 graph-mutation checks passed.
The next [graph18/tool13/rt15](../steps/witnesses/body-inputs-20261108/notes.md) constructs body-declared int places in var,
visible from the first line; body initializers stay at their statements. Dynamic int inputs get activation-local
places before var; nested methods impose no input requirements on their callers. Native method collection uses one
traversal of the completed graph, independent of construction. All 30 execution and19 graph-mutation checks passed.
Control flow, other working-place types, full admission and general call:code data were still open at that point.
The next [code/data continuation](../steps/witnesses/code-data-20261108/notes.md) binds int places of ordinary Structures
and fn to explicitly selected data. Shorthand selects var; code=data uses the same mechanism. The address map and working
values live only in the activation, data is not extended, and native computes the body directly. Remaining types,
control flow and full admission are still open; the activation model is not complete.
The next [graph24/tool16/rt22](../steps/witnesses/control-flow-20261108/notes.md) supports if/else, while, for,
nearest-loop break/continue/redo, return from inline bodies, comparisons and short-circuit &&/||. Bodies remain ordinary
Lmx and execute in the current activation; construction adds their own int fields to the shared var. Native emits its
own conditions and jumps. All27 execution and19 graph-mutation checks passed.
The current [graph28/tool17/rt23](../steps/witnesses/post-loop-20261108/notes.md) builds until as ordinary Lmx
[until, condition, body]. A named Structure retains its fields and an executable field referring to that loop;
fields shared by the body and Structure remain the same cells. Native allocates each encountered address once;
a temporary translation map associates it with a generated constructor local and is discarded after the traversal.
Both consumers evaluate the postcondition after the body; continue reaches it, while redo skips it.
All33 execution and19 graph-mutation checks passed. Named transfers, cleanups and remaining types/forms are still open;
this slice completes neither the activation model nor a general graph-state codec.
The current [graph34/tool19/rt26](../steps/witnesses/finally-20261108/notes.md) executes reached finally registrations
in reverse order on scope exit: normal completion, return, nearest-loop transfers and supported errors. The return
value is held before cleanup; dirty fields publish before activation-exit cleanups and afterwards. A transfer or
failure inside a cleanup neither reruns it nor omits outer cleanups. Native emits these paths directly; registration
state lives only in the current traversal/call. All42 execution and19 graph-mutation checks passed. Named targets,
throws/catch, stop/yield, other types and the complete activation/codec/selfbuild migration remain open.
The [graph36/tool21/rt28 continuation](../steps/witnesses/sub-calls-20261108/notes.md) brings sub into the shared path:
the word sub and args/var/body parts, with no return part. Root and nested calls, defaults, explicit code/data,
dynamic inputs, fallthrough, bare return and finally use the same activation and publication rules.
Using sub as a number is refused before argument effects. All42 execution checks, two result-refusal checks
and19 graph-mutation checks passed. fm, other types, full admission, exceptions, graph-state operations and §§8/8a remain open.
The current [graph40/tool22/rt30](../steps/witnesses/known-assignment-20261108/notes.md) preserves := as Lmx
[the := word, destination, right operand]. No parser flag survives; a destination path is ordinary nested Lmx.
Both consumers check a known int destination before the RHS; a bare name writes its working value, an explicit path
writes the graph without refreshing the working snapshot. Native computes the RHS directly. A typed int literal
is built as the same primitive. All30 execution and19 graph-mutation checks passed. Other types, reference writes,
named := arguments and §§8/8a remain open.
The next [graph41/tool23/rt31](../steps/witnesses/named-arguments-20261109/notes.md) supplies named arguments `a := v`
in a callable's argument structure (Codex's WIP, checked and finished by Opus). One temporary call binder matches the
written positional and named actuals with the physical formal slots of the selected callee by name addresses; an
unknown name, a repeat, a positional after a named one and a missing required formal are form refusals before any
argument effect. Then the right operands are evaluated in the written order, each received by its formal at once; a
refused reception leaves the later ones unevaluated and the body does not start. The binding map lives only in the
call; native emits it and computes the right operands itself. `a(5)` and `a: 5` stay ordinary calls with positional
results. All 45 graph fixtures: 45 graph-check runs × interp/native/forced passed (sub_void_value separately),
mutation 11/11, method-mutation 8/8. Computed defaults, AXBY with user conversions, q/z, merge35 and §§8/8a remain open.
The next [graph42/tool24/rt32](../steps/witnesses/whole-arguments-20261109/notes.md) gives the whole argument structure
of one Structure: a single positional actual without effects (a name or a path) whose direct fields name formals of the
selected callee of the same kind, every other formal having its default, is supplied by its fields; otherwise it is the
ordinary first argument. One kernel function `lmx_graph_call_single` decides for the interpreter and native alike, by
the formals and the direct fields, with no tree search and no second reading: `k(s)` takes q and z from `s` (15),
`k(q := s)` gives 50. 48 graph-check runs × interp/native/forced, mutation 11/11, method-mutation 8/8 passed. `merge` in
the clean graph (example 35), a Structure producer with effects and the choice between two methods of one name remain.
The next [graph43/tool24/rt33](../steps/witnesses/whole-empty-20261109/notes.md), after Codex's review, replaces the
field/formal kind check by the common admission of the subset: a field is supplied to a formal only when that formal
accepts it (`lmx_graph_admit`); an empty Structure is the empty field chain, the call of a nullary or default-only
callee (`zero(zero\var)` = `zero()`, `defaults(zero\var)` = `defaults()`). The current builder does not construct an
empty named Structure (`Empty: ()`) — a recorded limitation. 49 graph-check runs × interp/native/forced passed.
The next [graph44/tool25/rt34](../steps/witnesses/clean-merge-20261109/notes.md) gives `merge` in the clean graph
(§6.4). The operands are evaluated once, left to right, by their general meaning: a name, a path, a nested `merge`, a
call; an anonymous Structure `(a: int: 5)` is built by the ordinary rules — an unknown name is defined by its field. Then
one kernel operation `lmx_graph_merge_values`, for the interpreter and native alike, builds a new root with the model's
layout and the new fields at the end; a same-named field of a later operand is written into the model's slot by the
admission of an assignment (the same cell). One source → copy map serves all operands: operand roots map to the
result, shared targets and cycles stay shared, the copies' name rows keep the canonical names; the sources are not
changed. A head naming a function is called once and no model field intercepts the call: `f(3)` and `f: 3` are one
graph, and an int result is no Structure — an admission refusal (4). A Frame whose head is no function describes a
structure; its copy carries written names, and copying their lexical chain is open (5), as is copying callables, so the
result has no lexical parent. `mytest(merge(mytest\args; (a: int: 5)))` = 35 in all three modes, the native code runs
`merge` at execution time. `merge(f1; f2)` of two functions (the builder does not build a descriptor without a body), a
held place `pack: merge(...)` and replacing a Structure slot remain open. 53 graph-check runs × interp/native/forced
passed.
The next [graph45/tool26/rt35](../steps/witnesses/merge-places-20261109/notes.md), after Codex's review: a field of a
later operand that names an int place of the result is that same place in the one map (its value and its cell, the
cell behind `uninit:int` included); the correspondences are set before references are copied, so a reference to it
reaches the result's place in any field order (`R\a := 9` → `\R\p` = 9, sources intact; a mutant without this step gives
5). A field `name: @x` of an anonymous Structure is a new reference place. A root statement `name: value` with an
unknown name defines the place by its value (`lmx_graph_define`, both consumers):
`pack: merge(mytest\args; (a: int: 5)); mytest(pack)` = 35. The interface descriptor `fn: f2 (int: b 7) int` is built
with its `args` and `return` parts and an addressable empty `var`, without a body; it is no callable. Copying written
names and callables (with their lexical ancestors) and matching the `fn`/`return` parts in `merge(f1; f2)` (a question
to the author) remain open. 58 graph-check runs × interp/native/forced passed.
The next [graph46/tool26/rt36](../steps/witnesses/merge-repeat-20261109/notes.md), after Codex's review: a later supply
of a field is told from the first fill of its slot by its position (operand, field) — local data of the merge
traversal — not by its address, so the same source given again is written again in operand order:
`merge(M; N; M)\a` = 1, `merge(N; M; N)\a` = 5, sources intact. 59 graph-check runs × interp/native/forced passed.
The next [graph48/tool27/rt37](../steps/witnesses/merge-callable-20261109/notes.md), after Codex's review of 327:
`merge(f1)` copies a callable — its parts as ordinary Lmx, a written word as a new WORD cell holding the same canonical
address (`lmx_graph_word_of`) — and, when the copy holds written names or callables, takes their needed lexical
ancestors along, whole, through the same map up to `parent` = 0; the result's `parent` is the copy of the model's
parent. The copy is a new Lmx without `native`: the interpreter runs its call, since reusing the old implementation is
unproven. The place `g: merge(f1)` is defined by its value; the call `g(1)` in the root's native code is resolved, bound
and dispatched by the kernel at run time (the path `g \ field` is a read, not a call). With `int: k 2` and `k: 5` after
the merge: `f1(1)` = 15 (the live `k`), `g(1)` = 12 and `g(2)` = 22 (the copied `k` = 2), and the own `calls` stay
apart (`f1\var\calls` = 1, `g\var\calls` = 2). Open: the old name inside the copy — the slot `f1` of the copied root
holds the copy itself, named by its new place `g`, so a recursive `f1(...)` in the copy's body finds no name (3); a call
of a defined place from a method's native body. 60 graph-check runs × interp/native/forced passed.
The next [graph49/tool28/rt38](../steps/witnesses/callable-reference-20261109/notes.md), after Codex's review of 328:
the result of a one-operand `merge` is the copy of its root and keeps its name (§5.1), so the slot `f1` of a copied
ancestor answers `f1` at the copy and the copy's recursion stays in the copy: `g(3)` = 6 with `g\var\calls` = 4 and
`f1\var\calls` = 0. A new place for a named Structure or callable is a new named reference to the same instance (the
`LMX_TYPE_GRAPH_LMX_REF` region, `lmx_graph_ref_lmx`; `lmx_graph_target` takes the target): `g: merge(f1)` and `h: f1`
give `@: g f1` and `@: h f1`, the target's name does not change (`h(2)` = 21, the statement `h(5)`, `f1(3)` = 33, one
shared `calls` = 3), and `P\a := 7` through `P: M` changes `M\a`. A call head in an expression and in a statement, a
path, a field write, `call:`, a `merge` operand and a whole argument structure take the reference's target in both
consumers; the copy of a reference points at the copy of its target through the same map. Native: the call of a head
the translation cannot resolve is the common run-time resolve/bind/invoke in a root and in a method body alike, and a
statement on a place defined at run time is decided then (a call or a write), as by the interpreter: the body of
`twice` with the statement `g(a)` and `return: g(a) + 1` gives 13 with `g\var\calls` = 2. The clean graph has no
collector; the name of a composition of several roots and the `fn`/`return` parts (a question to the author), the `@`
address of a Structure reference and replacing a Structure or reference slot (5) are open. 63 graph-check runs ×
interp/native/forced passed.
The next [graph50/tool28/rt38](../steps/witnesses/runtime-statement-20261109/notes.md), after Codex's review of 329:
behind the call reading of a statement on a place defined at run time, the write reading takes only one value field
without a named actual (`lm_graph_emit_write_form`); another form — several actuals, named ones, none — is no write and
refuses when a place that is no callable is chosen, then (as the interpreter: answer 2 or 5), instead of stopping the
translation of a correct call. Reproduced on graph49 (`graph: emit answered 2`) and fixed: `f(a; b)` with
`calls`/`last`, `g: merge(f)`, `g(1; 2)` in the root, `g(3; 4)` in a native method body and `g(b := 7; a := 6)` give
the copy `calls` = 3, `last` = 67 and `f` 0 and 0; `x: 4`, `x(1; 2)` give answer 2; in native/forced R0 stops
(success 0) and `y` is not computed. 65 graph-check runs × interp/native/forced passed.
The next [graph52/tool29/rt40](../steps/witnesses/clean-production-20261109/notes.md), after Codex's review of 330 — the
first production input of the clean path, the machine module `src/l2src/lmx_schedule.lm2` (whose L1 F now writes in
build-runtime). With the existing command `G run`, graph50 stopped at construction (`graph: build answered 2`): the
builder did not take the reference formal `@: s T`. Now a formal `@: name T` is built as the Frame `[@, name, T]`,
named by field 1 (book :436), and printed; the C-door declarations `include:`/`predef:` are state words (`w_include`,
`w_predef`), their statements stay in the root and stand (the root runs nothing for them; the machine output will read
them). The graph of `lmx_schedule` is built whole and prints the same before and after its root runs; so do `l2_libc`,
`lmx_clock`, `os_native_path` and `tools/text`. The machine export from the clean graph (F's input instead of P0) is the
next step; the interpreter has no C door yet. 66 graph-check runs × interp/native/forced passed.

The author's decision of 2026-11-10 ([journal](../LMX_blog/2026-11-10.md#forms-declare-or-call),
[book](LMX_semantics.en.md#forms-declare-or-call)): structural forms only declare or call, and `:=` writes a value into
a known place. The following retains the historical description of
[slice 346](../steps/witnesses/colon-declares-clean-graph-20261110/notes.md): the definition of a place by its value
(`lmx_graph_define`) and the write by the form `name: value` are removed from both consumers; the descriptions of the
slices above state what the code did before it. A root form `Name: tail` whose head is no word of the language, no
receiver and no callable is a declaration of a Structure (`lmx_graph_root_declares`), executed where the traversal
reaches it (`lmx_graph_space_reach` → `lmx_graph_root_declare`): an atom of the tail that names a Structure, a callable
or a place now is that entity itself -- its address goes into the slot with no copy --, an unknown atom stays a word;
nested forms and kept statements stand as written. A repeated declaration gives the place of the name -- the slot of
the root holding the former Structure -- the newly declared one, and the slot of the form itself stays empty: there is
no second field, and the dump prints nothing for an empty slot. `Name: merge(...)` declares the Structure the receiver
builds: the name receives the result; a copy of one operand is named already and is held by `@: name merge(...)`. A
head that is a known place that is no Structure (an `int` place, a reference place) -- at the root, in a body and on a
path `owner\field:` -- is refused: answer 8 of the interpreter, a stop of R0 in a program (since slice 356 a reference place to an ordinary Structure at the root and in a body launches it -- below; on a path `owner\field:` and for a place that refers to neither a callable nor a Structure the refusal stays); the translator names `:=` in
its message and emits the refusal at the statement. A declaration of a Structure inside a running body and a repeated
declaration through a path are not executed by the slice (5). The fields of a written operand of `merge` are declared
by receivers -- `int: name value`, `@: name int value`; a field `name: tail` there is a description of a structure (5).
The author's example `Struct2: a b c`, `Struct1: q w e r t`, `Struct1: Struct2` gives the dump `Struct2: a b c` and
`Struct1: (Struct2 a b c)`. 99 graph-check runs × interp/native/forced PASS. The L3 lowering, the L2 machine path and
the walker still accept the colon assignment -- section [M7 of the plan](../next_core_tasks_v3.md#m7). The author's
decisions of 2026-11-11 changed the norm of what this slice executes -- the binding of an atom of the tail at the
declaration, the replacement of the content on a repetition, the name that receives the result of `merge`, the
printing of the referent in the dump, the declaration of a Structure among executed forms itself and a form whose head
is an ordinary Structure, or a place holding a reference to it, in code, which now launches the Structure by name; what
holds by them and what the clean graph still does otherwise is told below, in the paragraphs on the roles `data` and
`code`, on the author's answers and on launching a Structure by name.

The census of such writes in the working frontend is [slice 347](../steps/witnesses/colon-census-20261110/notes.md),
step 1 of section M7. The translator itself names every structural Frame -- with the colon, compact or a block:
anything but the operator `:=` -- that it lowers as a write of a place: `lm_compiler_colon_write`
(`l2_frontend_types.lm2`) is called in the write branches of the lowering (`lm_compiler_emit_stmts_with_position`,
`lm_compiler_emit_loc_stmt`) and of the walker's lowering (`lm_compiler_rw_stmt_content`). When the environment names
a file in `L2_COLON_WRITES`, the function appends a row to it: the route of the translation (1 a machine method, 2 the
L3 lowering, 3 the walker), the kind of the left side (1 a bare name, 2 a field path, 3 an index, 4 a dereference,
5 a member path of C storage; 6–9 the forms that themselves make a place: a name by its value, a reference `h: Box`,
a callable's result `r: h(3)`, a place under a Structure in the head `Model: m`), the file, the line, column and
offset of the head, its length, the flags of the Frame and the text of the head. A head that is a word of the language
or the receiver `@` gives no row: the receiver makes that declaration. Without the variable the function does nothing,
and the L1 written does not depend on it. Two commands of the tool (`tools/migrate.lm2`) read the report:
`colon-report CENSUS STAGE SOURCES` counts the sites -- one colon of one file, whatever number of translations and
routes named it -- by route and kind and checks every row against the source text (the head at its offset, the colon
and a space after it); `colon-migrate` replaces the colon of every checked site of kinds 1–5 by ` :=`, prints the
sites of kinds 6–9 and leaves them as written, and does not touch a row the text did not confirm. The command finds
nothing by the text. The report over a build of the frontend, the kernel, the tool, the graph translator and over
the full list of fixtures: 53,998 rows, 193 files, 34,843 sites. The machine path -- 33,639 sites (a name 20,216, an
index 8,925, a dereference 1,188, a member path of C storage 3,310), every one confirmed by the text. The L3 lowering
-- 1,309 write sites (a name 937, a path 215, an index 140, a dereference 15, C storage 2) and 18 sites whose form
itself makes the place; the walker named 1,276 write sites (a name 906, a path 215, an index 140, a dereference 15)
and 18 such forms. The text did not confirm 76 sites (762 rows): 61 are the receiver form `@: place value`, which the
frontend brings to a write through a path, 15 are block and compact forms of a Structure at a known place (`T:` with
a body, `Outer\Model()`); the command does not migrate them. The report does not see three kinds of writes: the
kernel modules translated from the clean graph (`lmx_schedule`, `lmx_clock`, `lmx_process_deadline`), the `default:`
branches of `os` blocks (they are not lowered on Windows) and the sources only a generation build translates
(`l2_frontend_graph.lm2`, `tools/l2trans.lm2`, `tools/lmxchild.lm2`).

The same slice fixed a declaration read at a site that is not its own. The pass that, before the calls are bound,
lifts a `merge` written as an argument of a call into a hidden declaration (`lm_compiler_merge_lift_walk`) asks every
statement whether it declares, and the reading of a declaration asks the places of the current method and keeps its
answer for the node (`lm_compiler_declaration`; a repeated `@` receiver takes the requirement of the earlier
declaration of its name). From the second registration round on the current method stayed the one the collection had
ended with -- the last method of the unit -- and `@: p int @ x` of any other method was read as a repeat of the place
`p` of that method with two values: "a declaration takes one value". The refusal showed when the pointer of the same
name in the last method stood nearer to the start of its file than the declaration to the start of its own, that is
through a program part; that is how it was found -- by adding a part to the tool. The pass now reads every method as
its own (`lm_compiler_merge_lift_methods`) and gives the caller its former reading site back; the fixture is
`tests/dyn/declaration_site.lm2` with the part `declaration_site_part.lm2`. `bootstrap quick` -- 0 failures, the
generations are the same; the full list -- `SUITE 140 rows, 0 failures`, 1108 PASS; 99 graph-check runs ×
interp/native/forced PASS.

[Slice 348](../steps/witnesses/colon-migrate-machine-20261111/notes.md) closed the three gaps of the census and
migrated the machine sources -- the translator, the kernel, the tool and the graph translator -- to `:=`. The machine
path from the clean graph (`lm_compiler_graph_block`, `l2_frontend_graph.lm2`) emits the operator `left := value` --
the builder's unnamed Lmx [`:=`, left side, operand] -- as the very write it emits for the form `name: value` and
`owner\field: value`: `lmx_schedule` and `lmx_process_deadline`, migrated to `:=`, give byte for byte the former L1
from their graph. The clean graph has no positions in the source text, so the rows of the census for these modules
come from a translation by the same frontend without the word `--graph`. The target the branches of `os` blocks are
selected for is named by the environment variable `L2_OS_TARGET` -- `win` or `default`; without it the target is the
translator's own (`lm_compiler_os_target`). A translation for another target writes the L1 of that target; that is
how the `default:` branches are lowered on Windows and name their writes. The sources only a generation build
translates are named by a `bootstrap` run with `L2_COLON_WRITES`. The receiver form `@: place value`, brought by
the frontend to a write through a path, gives no row any more; a Structure written with its fields at the place of
its head is kind 10 of its own. The commands of the report tell a write with a colon and a space from a write of
another form -- compact or a block -- and print the second (`COLON-FORM`) without touching it. The whole census of
`src` and `tools` -- 76,776 rows, 34,117 sites in 101 files: the machine path 34,058 (a name 20,547, an index 8,986,
a dereference 1,188, a member of C storage 3,337), the root programs of the tool in the L3 lowering -- a name 64, an
index 19, and four forms `MainLetter: m`, which the command does not touch
([P1](../LMX_blog/q/colon-declares-answered-20261111.md)). Every row is confirmed by the text, there is
no write of another form; by the text no statement with a colon whose head is a name, a path or a dereference is
left outside the census. `colon-migrate` rewrote 34,113 sites; every changed line differs from the former one by one
colon that became `:=`. The migration changed no generated file: all 172 L1 files of a generation -- the texts and
headers of the frontend, the kernel and the tool -- are byte for byte the files of the generation before the
migration; the frontend, `l1trans`, the tool and the graph translator are the same images (`EXE-SAME 1`), `driver.o`
is the same. What a build on Windows does not translate is compared apart: the L1 of the target `default` and the L1
of the graph-route modules read without `--graph` are the same before and after the migration. A repeated census of
the migrated sources names no write -- the four forms `MainLetter: m` are left in it. `bootstrap quick` -- 0
failures, the generations are the same; the full list -- `SUITE 140 rows, 0 failures`, 1108 PASS. The fixtures of
`tests` outside `tests/graph` were not migrated by this slice.

[Slice 349](../steps/witnesses/colon-migrate-fixtures-20261111/notes.md) migrated to `:=` the fixtures of
`selfbuild/tests` outside `tests/graph` -- the texts the L3 path lowers: the native lowering and the walker. The
census is refined. The put of a Structure that the receiver form `@: place (fields)` wrote gives no row: the origin
of the form has a node bit of its own (`lm_compiler_receiver_form_node`), and the role of a write through a path
stays on the first act of the written form only. A Frame with no field in its body that a write branch lowers as an
empty Structure at a known place (`Outer\Empty: ()`, `Outer\Model()`) is kind 10, a declaration. The rows come from
the full list, the small list of a generation build, the list `smoke-kernel225` and a translation of the fixtures
with `default:` branches for the target `default`: 13,187 rows, 1,221 sites in 103 files -- 1,160 write sites (the
native lowering: a name 887, a path 211, an index 45, a dereference 15, a member of C storage 2) and 61 forms that
declare: 54 Structures written at their own place, four places under a Structure in the head, two references and
one name defined by a value. A write of a known place here is also a write of a reference to a Structure,
`T: Swapped`, `Box\kid: Other`: the former reading assigned, the fixtures expect an assignment, and by the norm of
2026-11-10 it was written `T := Swapped`. `colon-migrate` rewrote 1,160 sites. Three forms that made a place
themselves were rewritten by hand into the forms of the same norm -- `var := D\var`, `@: b Inner2`,
`@: Other Answers`; 15 more writes stand behind the point of refusal in the fixtures of `refuses` rows, the
translation never reaches them, and they were migrated by reading the text. The operator `:=` knows the reserved
`var` -- the reference to the data of the current call -- as a known place: the collection already made it an input
of the activation, only the check of the left side refused it (`lm_compiler_check_body`). The author's decision of
2026-11-11 changed the norm of these writes: the names of Structures are not assigned -- `T := Swapped` is an error,
and pointer variables declared by `@: ptr T` are assigned --, and the special name `var` is called `data`
([book](LMX_semantics.en.md#data-code-roles)); their migration is steps 3 and 8 of
[section M11 of the plan](../next_core_tasks_v3.md#m11).

The checks of slice 349: the full list -- `SUITE 140 rows, 0 failures`, 1108 PASS. Of the 220 programs of the list
212 have byte for byte the former L1; two (`whole_arguments`) differ only in the name of a lifted `merge`, which
carries an offset in the source text; six -- the fixtures of the three forms rewritten by hand -- number their
places differently with the same results. The L1 of the 60 programs of the target `default` and of the 16 programs
of the list `smoke-kernel225` is the former one. A repeated census names no write: it holds 58 declarations.
`bootstrap quick` -- 0 failures, the generations are the same; `l1trans`, the tool, the graph translator and
`driver.o` are those of slice 348. Not migrated: `tests/native_closure_values.lm2` -- no command of the tool
translates it. The declarations keep the colon: written Structures and the records `Name: (fields)`
([P2](../LMX_blog/q/colon-declares-answered-20261111.md)), a place under a Structure in the head
(P1), declarations through `merge` (P4), the composed form ([M9](../next_core_tasks_v3.md#m9)) and the second heads
in three refusal fixtures, which step 4 will revisit. In this slice the L3 lowering, the machine path and the walker
still accepted a write with a colon.

[Slice 350](../steps/witnesses/colon-refusal-20261111/notes.md) introduced the refusal in the working frontend: a
structural form declares or calls and writes no known place
([book](LMX_semantics.en.md#forms-declare-or-call)). The refusal stands where the write is: every branch that
would emit a write of a place for a structural Frame first asks the function of the census
(`lm_compiler_colon_write`, `l2_frontend_types.lm2`), and the census showed that every write of the native L3
lowering, of the walker and of the machine path passes through it. A form of the kinds 1-6 -- its head is a known
place: a name, a path through fields, an element, a dereferenced cell, a member of C storage -- is refused, and the
message names `:=`: "a form with a colon declares and writes no known place: assign with :=". The forms of the kinds
7 and 8, which defined a place by its value (`h: Box`, `r: h(3)`), are refused with a message of their own: a form
with an unknown head declares a Structure with its tail inside, a reference is declared `@: name value`. The kinds 9
and 10 -- declarations -- pass. The row of the census is written before the refusal, so a census names the form that
stopped the translation. The machine path from the clean graph (`lm_compiler_graph_block`) refuses in its two
branches that emitted a write for the forms `name: value` and `owner\field: value`; the write there is the operator
`:=` alone.

Limits: the L3 lowering builds a repeated declaration of a Structure only from a written body; a Structure with
an atom that names another entity -- `Struct1: Struct2` with a known `Struct1`, `h: Box` with an unknown `h` -- it
does not build and refuses such a form instead of assigning a reference as before. The clean graph executes such a declaration. The
refusal does not tell a Structure place from a value place: its message is true of both.

The checks of slice 350: nine refusal fixtures (`colon_known_*_refused`, `colon_absent_reference_refused`) -- a
literal, a name and the result of a call as the tail, a path, the root, an element, a dereference, a statement of a
named Structure's body, a reference by a value -- are refused natively and under the walker. The mutant -- the
refusal removed -- translates all nine. The machine path is checked on the kernel module `lmx_ids` with one write
turned back into a colon form: refused; the same module unchanged gives the L1 of the build. The machine path from
the graph -- on `lmx_schedule` and `lmx_process_deadline` with one such write each: refused. Two fixtures that pinned
the former rule (`occurrence_bare_refused`, `occurrence_node_refused`: a second root head written `y: 7`) write the
second head as a repeat of the declaration; their subject and message are the former ones. `bootstrap quick` -- 0
failures, the generations are the same: the sources of the translator, the kernel and the tool hold no write with a
colon. The full list -- `SUITE 149 rows, 0 failures`, 1162 PASS; the L1 of all 220 programs of the list is byte for
byte that of the previous slice; `l1trans`, the tool, the graph translator and `driver.o` are the former ones.

The author's decision of the same day ([journal](../LMX_blog/2026-11-10.md#receiver-args-only),
[book](LMX_semantics.en.md#receiver-args-only)): a place is declared only by the form `receiver: arguments`, and the
composed form `name: receiver: value` is withdrawn. The examples of slices 304 and 307 above are written in the former
form (`(a: int: 5)`); under the norm the same field is written `(int: a 5)`, and since slice 351 the fixtures write it
so.

[Slice 351](../steps/witnesses/composed-form-20261111/notes.md) removed the composed reading from the working
frontend (steps 1-3 of [section M9 of the plan](../next_core_tasks_v3.md#m9); in the clean graph step 3 was done by
slice 346). Two places of `l2_frontend_resolve.lm2` read the composed form: the reader of a declaration
(`lm_compiler_declaration`) -- the outer head as the place, the receiver of the tail as an asserted requirement --
and the role of the content (`lm_compiler_decl_content`, role 4: "the tail is consumed by a receiver"), under which
the Frame was no definition of a Structure. Both readings stay with the operator `:=` (`place := int: 5` writes a
value its receiver checks) and with the receiver form brought to a write through its path (`@: Box\k Model: Other`,
node bit 8192); a form with a colon has neither. The common rule of the head applies from there. A head that names
nothing declares a named Structure with the tail inside: `holder: int: time` is a Structure with the field `time` at
the root, in the body of a Structure and in the body of a method, whatever `time` names outside it; before, a name
known outside turned the same line into a place with a value. A known place is refused with the message of slice
350. The field of a `merge` operand written name first (`(a: int: 5)`, label `MERGE-OPERAND-FORMS`) is withdrawn
together with the function `lm_compiler_named_typed_field_kind`: such an operand is refused as an operand form that
is not lowered.

So that `i: int: 6` with a known `i` is refused by the rule of the form and not by the words "int has no value"
about its tail, the check of a received value (`lm_compiler_check_receiving_value_at`, `l2_frontend_emit.lm2`) reads
a single application of a receiver of a primitive as an expression: its operand is received by the receiver's type,
and the place receives that type -- as it already read the initial value of a reference under an asserted
requirement. With that a write by index and through a reference takes such a value too (`a[1] := int: 6`,
`\p := int: 6`); before, it passed in a write by name -- through the composed reading -- and by path.

The limit: a Structure with a receiver call inside -- `i: int: 5`, `ptr: @: 0` under a head that names nothing --
is not built by the L3 lowering. An item of a body that is the application of a receiver of a value or of a type
(`int`, `char`, `size_t`, `unsigned`, `ulong`, `@`) to what is no name of a place is refused in
`lm_compiler_take_ns_body` where the application stands: "a receiver applied to a value declares no place, and a
Structure declared with it inside is not lowered yet…", and the message names the form that declares a place. The
reserved `var` with its data written as fields (`var: (int: n 3)`) does not fall under this rule. The clean graph
executes such a declaration.

The checks of slice 351: nine new rows of the list -- `composed_declares_structure` and `typed_value_write` give 7
natively and under the walker, with both executors of the root; seven refusal fixtures (`composed_value_refused`,
`composed_value_method_refused`, `composed_field_refused`, `composed_reference_refused`, `composed_known_refused`,
`composed_known_root_refused`, `merge_named_field_refused`) are refused with the named message at the named place.
A mutant -- the former reading restored in both readers -- fails `composed_declares_structure` ("unknown field path
segment" at `box\time`), makes the three forms under an unknown head a place again and translates the two on a known
place as a write (exits 6 and 8). The full list -- `SUITE 158 rows, 0 failures`, 1216 PASS. The first run gave 6
failures in three fixtures: the refusal of a receiver's application was wider than the norm and caught the data of
`var` written as fields; the condition was narrowed to the receivers that declare a field, and the tuple was built
again. Of the 220 programs of the previous slice 210 keep their L1 byte for byte; two (`whole_arguments`) differ
only by the name of the lifted `merge`, which embeds an offset in the source; two (`explicit_data_var_field`) by one
line of the name table: the word of the head `cell` became the word `int`; six (`free_c_abi`, `free_c_pointer`,
`free_value_consumers`) have a table of pointer types shorter by one or two unused entries, the codes of the types
after them shifted. The cause of the last: the question "a type word?" (`lm_compiler_prim_type_word`) interns a
pointer type for a word of the `c.` door as a side effect; it used to be asked of the head of the one Frame in the
tail of any form (`return: c.f(x)`), now only in the tail of the operator `:=` and of the receiver form. `bootstrap quick` -- 0
failures, the generations are the same; `l1trans`, `driver.o` and the graph translator are the former ones, the tool
is another (the export list of the frontend is one name shorter).

[Slice 352](../steps/witnesses/receiver-check-20261111/notes.md) did step 4 of
[section M9 of the plan](../next_core_tasks_v3.md#m9) in the working frontend -- the one-argument forms of the
receivers of primitives (`int`, `char`, `size_t`, `unsigned`, `ulong`). The form with a name (`int: i`) and its
repetition were executed before. Two lowerings by the shape of a form were added, both in `l2_frontend_core.lm2`.

The check as a statement (`lm_compiler_receiver_check_lower`). A receiver of a primitive applied to a value and
standing as a statement in the body of a method or at the root -- `int: 5`, `int: bump()`, `int: (2 + 3)` -- checks
the value: it is evaluated once, received by the receiver's type and not kept. The statement becomes the declaration
of a place with a name from the translator's space (`l2_check_<part>_<offset>` -- one per place of the program's
text), which receives the value as every declared place does; the check, the lowering and the walker read it as a
declaration. The rewriting stands in two passes over statements -- the collection of places
(`lm_compiler_collect_asgn_body`) and the collection of the rows of declarations (`lm_compiler_collect_decls`) -- and
does not fire twice: a rewritten statement is already a declaration.

A literal outside the type (`lm_compiler_receiver_literal_lower`). In a receiving position a literal has no type of
its own: it takes the type of the place, and a literal the place cannot hold is refused by the translation. In the
form `receiver: literal` the place is the receiver itself and the form is the check, so such a literal is given the
type that holds it -- `int`, else `size_t` -- by the same form: `int: 4294967296U` reads as
`int: size_t: 4294967296U`. The outer receiver receives a number of another type, and that is the run-time `convert`
that `catch: convert ()` accepts -- as with a value of another type from a variable. The rewriting is done by the
walk of the forms that say what they are by their shape (`lm_compiler_place_write_walk`), before anything is read for
its meaning; the decision "does the literal fit" is moved from `lm_compiler_check_literal_kind` into
`lm_compiler_literal_kind_fits`, one for both.

The limits: a literal that no number type of the translation holds (`int: 342348523485629384569384`) is refused by
the translation -- it has no value to receive at run time; a declaration with a literal outside the range
(`int: x 4294967296U`) is refused by the translation as before; in the body of a named Structure the form with a
value is no statement but a value inside the Structure, and is refused by the limit of slice 351.

The checks of slice 352: four new rows of the list -- `receiver_check_statement` and `receiver_literal_range` give 7
natively and under the walker, with both executors of the root; `receiver_literal_unrepresentable_refused` and
`receiver_check_structure_refused` are refused with the named message at the named place. A mutant -- both
rewritings switched off -- translates neither `receiver_check_statement` ("unsupported body" at `int: 5`) nor
`receiver_literal_range` ("literal not representable as int"), and refuses the third fixture with another message.
The full list -- `SUITE 162 rows, 0 failures`, 1240 PASS; all 224 programs of the previous slice keep their L1 byte
for byte. `bootstrap quick` -- 0 failures, the generations are the same; `l1trans`, `driver.o` and the graph
translator are the former ones, the tool is another (the export list of the frontend is one name longer).

A repeated declaration by a receiver in code has no mechanism of its own: it is an out-of-turn type check with an
assignment, and no second field arises; in data a repeated declaration is one more occurrence of the name: it
neither replaces the former one nor writes into it, and after it the name is addressed only with the index of an
occurrence (the author's clarification of 2026-11-11,
[journal](../LMX_blog/2026-11-11.md#repeat-is-check-and-assignment), and his decision on the roles of the same day;
the book -- [structural forms](LMX_semantics.en.md#forms-declare-or-call),
[names and paths](LMX_semantics.en.md#fields)). Both translators were measured against this clarification in the
same witness; the divergences of the implementation found there were written down as step 5 of
[section M9 of the plan](../next_core_tasks_v3.md#m9) and moved into steps 5 and 8 of
[section M11](../next_core_tasks_v3.md#m11): with a repetition in the explicit `var` of a method the working
frontend silently reads the first occurrence; the clean graph did not write the place on a repetition at the root, and
until slice 355 it selected the first occurrence by a bare path and did not build the path with the index of an
occurrence (the last two were removed by slice 355, sub-step 5а). The root of a unit is launched as a Structure over itself, and an access without an index to a variable declared twice in it
is refused (the executor's reading -- [answers](../LMX_blog/q/fable-self-answers-20261110.md), Р6 and Р11).

[Slice 353](../steps/witnesses/call-receivers-20261111/notes.md) executed in the clean graph the author's decision
of 2026-11-11 on launching code over data ([journal](../LMX_blog/2026-11-11.md#call-receivers); the book --
[the receivers `call` and `fncall`](LMX_semantics.en.md#call-receivers); steps 1-5 of
[section M10 of the plan](../next_core_tasks_v3.md#m10)). The working frontend does not read the new forms and
reads the one-argument `call` as before; a name used above the line of its declaration it still rejects by the
former rule of the book.

The current launch receives actuals separately from the input description data. Explicit receivers and
ordinary calls converge on one frame and execution worker; args is not read as formal declarations.
Migration of the former LmxGraphFrame/work_open_parts belongs to [M10 with M14](../next_core_tasks_v3.md#m10).
The historical place-model changes367 are in their [receipt](../steps/witnesses/m11-ordinary-model-20261113/notes.md).
Slice 368 replaces the call of own data with a pass over its implemented root declaration
receivers in the same frame (`lmx_graph_data_run`). Other fields, including assignments,
test, data, if and nested Structures, remain data. After a computed initializer, the work
row binds the published cell again so the next initializer reads it.
An ordinary data()/data(D) record now uses the common resolve/launch/binder in runtime and native emission.
The constructor prepares written fn/sub in both its data and code; the common binding_value
reader returns the existing method after checking its source parent, without changing the source graph field.
A unique written data method is checked by name and path. At slice 368, indexed repeated methods,
reference places and computed fn/sub in data, root/self and M14 remained open;
[checks and limits](../steps/witnesses/m11-data-roles-20261113/notes.md).
Slice 369 adds working values for the supported int/Structure references, a common known_place
preflight and reference writer; known_int remains numeric. A code @ writes a data place,
and its implicit own gets a real uninit:T with stable slot/wrapper/typed-cell identities.
The working snapshot is separate from the published cell: dirty values publish at standard points,
while a clean outer snapshot survives a nested call. The model's expected primitive kind is stored
once in the map row's expected_kind; another data cannot change that type through the RHS.
Native emits one RHS path for a fixed own model kind, retaining the same preflight and guard;
other places stay dynamic. Normal header generation supplies graph68/run52 and Work's contract field.
Full bootstrap quick built genuine G1/G2, nine smoke rows each; thirteen checks and 614 inputs passed. Genuine G2/graph repeated nine cases in three modes, the full mutation command and six AFTER comparisons;
[checks and remaining work](../steps/witnesses/m11-reference-work-20261113/notes.md).
Slice 370 admits computed fn/sub at the root of the current frame's own data through the same binder/make.
The existing Space.rows select the constructed method by owner and the source declaration's parent;
its computed name works in paths, and another launch in the same traversal retains its data.
When a local declaration's name is still unknown, the existing frame's temporary binding_open
distinguishes unfinished binding from a missing free input. Known external values are held at entry;
a new local immediately overrides the entry fallback, including in the next initializer.
After ordered data, a still missing input refuses before the body, without rereading an external source.
A closed scope retains its refusal before data initializers. Native selects the callee in the live frame
and checks its result before actuals, rather than treating a lexical fallback as the final target.
A possible entry snapshot of an ambiguous argument lives in an existing frame row, but becomes
an input for child calls only when its owner actually consumes it. Shape queries do not consume it.
The reading selected by the live contract is carried in the temporary call map's tail and used alike
by native code and the walker. An empty or partial whole Structure retains the common binder/defaults;
P0 groups stay intact. Source08:624 inputs,19 cases in three modes, AFTER12 and mutation passed;
the full bootstrap03 quick G1/G2,9 smoke rows each, fixedpoint13 and the actual G2/graph rerun passed.
The normal semantics rendering and docs check passed:35/14/27/44/615, LF27224; diff --check is clean.
Computed declarations in code/inline blocks,
root/self and the whole M11 remain open;
[checks and limits](../steps/witnesses/m11-computed-data-20261113/notes.md).
Slice371 extends lookup of a constructed fn/sub to fn_result(), retaining owner/name/parent:
a function description without a body remains available by name; method() is required at invocation.
This retains the absence of code without creating an artificial empty body. The remaining fixtures'
preparatory merge holders and references moved into own data; final readouts retain the complete
result dump. Source02:626 inputs;15 cases in three modes, AFTER6/mutation, the full bootstrap01
G1/G2, fixedpoint13 and the actual G2/graph passed. The normal render/docs check passed:
35/14/27/44/615, LF27241; diff --check is clean;
[change and checks](../steps/witnesses/m11-own-merge-references-20261113/notes.md).
The running code reads the formals, the body and
the result from the frame (`lmx_graph_activation_args`, `lmx_graph_method_run`, `lmx_graph_launch_result`), not from
the Structure of the method; an activation without a frame answers by the Structure, as before. The ordinary call
`f(x)` therefore goes the same way as a launch that was given its parts.

The receivers use the [six current forms](LMX_semantics.en.md#call-receivers).
args supplies values; data describes inputs, return describes the result, and code is the body.
Abbreviations supply no actuals and use code as data, not a callable's child data.
Ordinary and explicit calls must share binding/admission/frame/result; M10/M14 replace the
separate callable-without-args route and the former int-only result handling.
The old launch implementation does not establish acceptance of the new model.
The [checks353](../steps/witnesses/call-receivers-20261111/notes.md) remain historical evidence.

[Slice354](../steps/witnesses/data-code-names-order-20261111/notes.md) changed names to data/code
and the two-argument call order to data before code. Those decisions remain.
A current callable contains unified data, return when a result exists, and code;
launch receivers use args for actual values. Historical field names in internal
C/L2 procedures do not define an additional language contract.

The checks of slice 354: in 60 tracked files of `tests/graph` (44 sources and 16 expectations) `var` → `data` and
`body` → `code` (in `merge_arguments` the name `body` is a variable and stayed); 18 two-argument `call` lines in 11
fixtures and the same lines in six expectations are rearranged; the file names `call_var_not_selected`,
`code_data_no_var`, `var_copy_nesting` are the former ones. Four new negative fixtures: `former_var_part` (`f\var\x`,
answer 3), `former_body_part` (`body := …` in a record of `fn`, answer 5), `former_var_block` (a block `var:`,
answer 3), `former_call_order` (`call: Code Data`, answer 3). Graph-check -- `CHECKS 113 lines, 0 failed`, 339 `PASS`
in the three modes; `bootstrap quick` -- 0 failures, G1 and G2 built and tested; the full suite of the working
frontend -- `SUITE 162 rows, 0 failures`, 1240 `PASS`. The mutant "the former word `var` accepted" fails 3 rows of 3,
the mutant "the former order of the arguments" fails 4 of 4; in both lists every row is refused in all three modes. The
working frontend and its fixtures (`tests/dyn`, `tests/os_twins`) read the former `var`, `body` and `call: code data`
-- step 8; the clean graph still declares a Structure when the traversal of the root reaches it -- step 5 --, while the
binding of an atom at the moment the declaration is executed and the replacement of the content on a repetition were
removed by slice 355 (sub-step 5а).

[Slice 355](../steps/witnesses/data-registry-atom-20261111/notes.md) executed in the clean graph the registry of data,
the atom-pointer with no expansion and visibility in data in both directions (sub-step 5а of
[section M11 of the plan](../next_core_tasks_v3.md#m11); the author's decisions of 2026-11-11 --
[a mention is not expanded](../LMX_blog/2026-11-11.md#known-name-not-expanded),
[a repeated declaration](../LMX_blog/2026-11-11.md#repeat-is-check-and-assignment),
[the roles `data` and `code`](../LMX_blog/2026-11-11.md#data-code-roles),
[the parser tree is not expanded](../LMX_blog/2026-11-11.md#parser-tree-not-expanded); the executor's readings --
Р12–Р15 and Р19 in the [answers](../LMX_blog/q/fable-self-answers-20261110.md)). The registry of data is
`lmx_graph_data_find`: the records of a data level that declare a name are read whole at every consultation, with no
table; one record answers, with two or more the name without an index answers nothing (answer 3), and an occurrence is
chosen by the path `s\[N]name`; slice355's string encoding of the step is replaced in slice388 by the structural
representation below. The path step and the atom are `lmx_graph_step`, `lmx_graph_step_place` (the kernel
export, 43 names) and `lmx_graph_atom_target`: the atom of a declaration's tail is not bound when the declaration
is executed and the slot is not rewritten, while the name of the atom is looked up when a path goes through it --
lexically, from the holder outwards, by whole levels; a write through the atom writes the named place; the replacement
of the content on a repeated declaration is removed. The places and Structures of the root answer above and below their
line, and `data` in a root executed over itself is the root. A computed declaration of the data supplied to a launch is
not executed (`lmx_graph_data_realize` is removed, Р12): its place is without a value, and a read before a value answers
5. The print of the graph carries a path: a Structure met on it again is printed by its name.

**Implementation delta in slice388, with no change to occurrence-selection semantics.** The outer path retains three fields,
`[owner, WORD("\\"), step]`. An occurrence step is an ordinary anonymous pair,
`[WORD(decimal digits), WORD(canonical name)]`; an ordinary WORD always denotes a literal name, including `[0]x`.
Common `lmx_graph_occurrence` (Graph74) reads this pair without evaluating its fields, checks `size_t` overflow
before multiplication by 10, and leaves output parameters untouched for an invalid unit.
`lmx_graph_step` and `lmx_graph_step_place` take a raw step; reads, writes, `lmx_graph_admit_path` and native
use that same reader and the existing data registry. No new tag, registry or parser flag is added.
A compact selector is consumed again through existing P0 and the expression builder instead of a separate byte split;
common `lm_p0_scan_head` and the compact-piece reader use existing `lm_p0_scan_quoted`, preserving the boundaries
of an exact root, quoted components and doubled backticks. Global `lm_p0_is_quoted_token_boundary` is unchanged.

The checks of slice 355: 17 new and 6 changed fixtures of `tests/graph` (the list is in the
[evidence](../steps/witnesses/data-registry-atom-20261111/notes.md)), 499 entries in `inputs.list`. Graph-check --
`CHECKS 130 lines, 0 failed`, 390 `PASS` in the three modes; `bootstrap quick` -- 0 failures, G1 and G2 built and
tested; the full suite of the working frontend -- `SUITE 162 rows, 0 failures`, 1240 `PASS`. Six mutants are killed in
all three modes. Limits: the answer 5 "a place without a value" is given only by the rows of a launch, while in the root
of a unit that has no frame a read of a name above its computed declaration answers 3 ("the root as a launch with a
frame" is moved to a sub-step after 5г); reading a place with no initial value (`int: z`) still gives 0; a form whose
head is the name of a place of the same level is not counted as an occurrence in a path either (sub-step 5д);
`Name: merge(...)` still declares the holder of the result by a structural form (the translation into `@: R merge(...)`
is sub-step 5в); the dump expands a reference to a Structure whose parent is not the holder (the results of `merge`), and printing such a reference by name is a separate change. The working frontend does not execute these rules -- step 8.

[Slice 356](../steps/witnesses/callable-data-launch-by-name-20261111/notes.md) executed in the clean graph the first
part of sub-step 5б of [section M11 of the plan](../next_core_tasks_v3.md#m11): the launch of a Structure by name, one
binder of forms, and the visibility from code of the parts of a callable and of the Structures of the data of a launch
(the author's decisions of 2026-11-11 -- [launching by name](../LMX_blog/2026-11-11.md#structure-call-by-name), [the
parts of a callable see one another](../LMX_blog/2026-11-11.md#callable-parts-visibility),
[the roles `data` and `code`](../LMX_blog/2026-11-11.md#data-code-roles),
[`data` before `code`](../LMX_blog/2026-11-11.md#data-before-code); the executor's readings -- Р16 and Р20–Р23 in the
[answers](../LMX_blog/q/fable-self-answers-20261110.md)). A form whose head is an ordinary Structure launches it in the
code of a callable and in code over given data (`lmx_graph_launch_head`, `lmx_graph_eval_launch_record`): `S()` over
itself, `S(D)` and `S(data := D)` over `D`; a head that is a place with a reference to an ordinary Structure launches it
everywhere, the root included; a head that is a number place is answer 8; no form (two positional arguments, an argument
of another name), and a launch form in the place of an operand, are 5. One binder (`lmx_graph_receiver_form_of`) chooses
the form of `call`, `fncall` and of the launch form by the written actuals -- by position or by name through `:=` --
before any of them is evaluated; the emitted code binds the form at translation (`lmx_graph_launch_formals` -- an
export; the export list of the interpreter has 45 names). The data/code/return parts of a callable (args supplies actual values, not a callable part)
answer in its code (`lmx_graph_resolve`); the Structures of the data of a launch are found by the registry of the data
of the launch (`lmx_graph_data_find`): a name is searched by the rows of the frame, the formals, the registry of the
data of the launch and the lexical levels (Р20), and a Structure answers by reference, there is one instance.

The checks of slice 356: 21 new and one rewritten fixture of `tests/graph` (the list is in the
[evidence](../steps/witnesses/callable-data-launch-by-name-20261111/notes.md)), 536 entries in `inputs.list`.
Graph-check -- `CHECKS 151 lines, 0 failed`, 453 `PASS` in the three modes; `bootstrap quick` -- 0 failures, G1 and G2
built and tested; the full suite of the working frontend -- `SUITE 162 rows, 0 failures`, 1240 `PASS`. Seven mutants are
killed. The limits of that slice (history): until sub-step 5г the root of a unit and a Structure over itself do not execute the code role of a form
whose head is an ordinary Structure by name: `S()` in the root beside the declaration `S` stays one more occurrence of
the name (`struct_root_declares`, answer 3; this is a state of the implementation, not a rule -- Р22); `data()` in code
is skipped, the word `node` is unknown to the clean graph, and a multi-line part `data` in parentheses with a block
closed by `end:` is read with an extra form `end: Name` -- this is the second part of sub-step 5б; P0 expands a single
Structure in parentheses into the tail of the form, as in `Add((int: v 7))` (the debt of section M8); the supply by head
in the parts of `fn` and `sub` is removed by sub-step 5е; the word of the receiver `call` or `fncall` in the place of an operand finds the row of the contract, as `fn` did before (a state of the implementation, Р23); a head that is an empty reference (answer 8 by Р22) is shown by no fixture: `@: p 0` answers 4, `@: p` answers 5 on its own row. The working frontend does not execute these rules -- step 8.

The author's decision of 2026-11-11 on the roles `data` and `code` ([journal](../LMX_blog/2026-11-11.md#data-code-roles);
the book -- [the roles `data` and `code`](LMX_semantics.en.md#data-code-roles);
[section M11 of the plan](../next_core_tasks_v3.md#m11)) is executed by the clean graph so far only in part: the
names and the order (slice 354, step 4 of section M11) -- the parts of a callable are called `data` and `code`, the
two-argument `call` is `call: data code`; sub-step 5а (slice 355) -- data is read as a whole, the registry of data, an
atom-pointer with no expansion, a repeated declaration does not replace the former one, visibility in data in both
directions; the first part of sub-step 5б (slice 356) -- the launch of a Structure by name and the named supply of the
arguments of `call` and `fncall`. The rest is executed by no path of translation yet, and the working frontend reads not
even this. For the clean graph the decision means the following. Data is read as a whole before the code, and the registry of its root forms -- the
declarations of Structures by their heads and the declarations by receivers of places by the declared names -- is
known before the first statement of the code; a traversal of code declares nothing but callables. In code every
form is a call: a declaration by a receiver is a type check with an assignment into a place of the data, a
structural form is a call of its head: of a callable, a method call; of an ordinary Structure, its launch by name
([journal](../LMX_blog/2026-11-11.md#structure-call-by-name)); it is an error when the head names neither a callable nor
a Structure. A repeated declaration in data is
one more occurrence of the name: it neither replaces the former one nor writes into it, and after it the name is
addressed only with the index of an occurrence. The left side of `:=` is a place of a primitive or a pointer
variable: the names of Structures and functions are not assigned. The arguments of calls and receivers are read as
code: `f(arg: v)` calls `arg`, only `:=` gives a named argument, and the formals are declared by receivers
(`int: arg default`, `@: arg Template`). A launch form of a Structure at a place where a value is needed (an operand of
an expression, an actual argument of a call, an initial value, an operand of `merge`) is an error: a launch has no
result (the executor's reading -- [answers](../LMX_blog/q/fable-self-answers-20261110.md), Р22, item 3; Р25, item 4).
The name of a form `Name: merge(...)` does not receive the result: in code
it is a call of `Name`, in data a declaration of a Structure with the form of the call of `merge` inside, which is
not executed there; a pointer variable holds the result, `@: name merge(...)` (the executor's reading --
[closed questions](../LMX_blog/q/colon-declares-answered-20261111.md), P4). The words of the
state `var` and `body` and the names of the formals in the contracts of the receivers `fn` and `sub` are called
`data` and `code` (the clean graph reads these names since slice 354). The admission `implements` is performed by one
pass when the graph is built; calls of the
admission at run time stay only for the cases of the
[document](../steps/implements-runtime-cases-20261111.md). slice 372 removes the former
`lmx_graph_space_reach`, `lmx_graph_root_declares` and `lmx_graph_root_declare`: a named-head form
at the root or over self reaches shared resolution and launch. A standalone preserved anonymous Structure
does not execute; its receiving expression selects a code body. This is not the complete M11 migration:
root numeric/reference publication, path-head calls, the remaining forms of 5д–5е and admission migration M11.7 remain open.
The decision makes the choice between a
call, a declaration of a Structure and an assignment by the head and the tail of a form unnecessary -- the role
gives it; removing these branches is step 6 of section M11.

The author's answers of the same day to questions P3, P6 and P7 completed this norm
([a mention is not expanded](../LMX_blog/2026-11-11.md#known-name-not-expanded),
[`data` before `code`](../LMX_blog/2026-11-11.md#data-before-code),
[a Structure over itself has no rules of its own](../LMX_blog/2026-11-11.md#self-launch-no-own-rules); the book --
[declaring by a colon form](LMX_semantics.en.md#colon-declares) and
[visibility](LMX_semantics.en.md#declaration-visibility)); the questions are closed
([closed](../LMX_blog/q/colon-declares-answered-20261111.md)). A mention of a known Structure is expanded neither by
the parser nor by the builder: in `Struct1: Struct2` one atom stands under `Struct1` in the tree -- a pointer to
`Struct2`, immutable by name; it begins to refer to it at interpretation and translation, a path through it
continues into its fields, and the `parent` of `Struct2` itself -- its place in the tree -- does not change; the
slot of the atom is rewritten by index (`Struct1[0] := …`), and a mutable reference is declared by a receiver
(`Model: @: ptr knownModel`). The dump prints the tree -- the atom, not the referent (the executor's reading --
[answers](../LMX_blog/q/fable-self-answers-20261110.md), Р2). Named Structures and callables retain bidirectional visibility;
variables and const are sequential under M14 of2026-11-15. Cyclic references to named Structures are no error. The data stands before the code in every form: the
two-argument launch is `call: data code`. A Structure launched over itself -- `call(code)` and the root of
a unit -- has no rules of its own: its forms are read in both roles by the general rules, and an uncertainty is an
error; a structural form that execution has reached is an error when its head names neither a callable nor a
Structure; a data block inside an executed Structure is the same kind of form, a call with its own tail in the place of
the argument (the paragraphs below), and so declarations of Structures are written in data, and data and code apart (the
executor's reading -- the same answers, part Р). Here too the clean graph does otherwise now: a form of an ordinary
Structure in the executed root it neither launches by name (the paragraphs below) nor refuses but declares where the
traversal reaches it (§6.1), and the child block `data` of an executed Structure it skips. The rest of the execution is
step 5 of section M11 (the names and the order of `call` are executed by step 4, sub-step 5а by slice 355, the first
part of sub-step 5б by slice 356; sub-step 5в and the remainders of sub-steps 5б, 5г, 5д and 5е remain), in the working frontend step 8.

The author's decision of 2026-11-11 on launching a Structure by name
([journal](../LMX_blog/2026-11-11.md#structure-call-by-name); the executor's reading --
[answers](../LMX_blog/q/fable-self-answers-20261110.md), Р21) changed this norm for a form whose head is an ordinary
Structure (before the decision such a form was refused in code, and an ordinary Structure was executed only by the
receiver `call`). In code such a form launches that Structure: `S()` is the same as `call(S, S)` (the Structure over
itself), `S(D)` is the same as `call(D, S)` (the Structure over the given data `D`); so are the short form `S: D` and the
block form. It is a launch form of its own, not a form of a receiver: the receivers `call` and `fncall` remain the general
mechanism ([the receivers `call` and `fncall`](LMX_semantics.en.md#call-receivers)): args supplies actual values,
and data describes inputs. The short S(D) form has only its data argument; explicit call also accepts args. The form has one argument and it is
named `data` -- by the same name by which executed code names the data of its launch
([the special name `data`](LMX_semantics.en.md#ordinary-var)); it is supplied by position or by name, `S(D)` and
`S(data := D)` are one form, just as with the receivers, whose arguments are named and are supplied by position or by
name (`call(data := D; code := C)`); another name of the argument and two or more positional arguments are an error; the
argument `data` must give a Structure (a name, a path, a reference place, an unnamed Structure written in parentheses),
anything else is an error. The head is a place with a reference: what the reference points at is called -- a callable or
a Structure; a number place, an empty reference and an unknown name are an error. In data nothing changes: `S()` still
declares an empty Structure `S`, and `S(D)` a Structure `S` with an atom `D`; nothing is called.

In the root of a unit and in a Structure launched over itself every form is read in both roles, so `S()` there is at once
a declaration of one more `S` and a call: if `S` is declared in the same Structure, the name has two occurrences, without
an index it answers nothing, and the call is refused; if `S` is declared outside, the form declares its own empty `S`, and
that one is launched, not the outer one; there is no rule of its own for this, and the receiver `call` launches the same
Structure there. A declaration of a Structure among executed forms is still, as a rule, an error, but for another reason:
in code such a form is a call of the declared Structure with its own tail in the place of the argument, and two or more
fields in the tail are not a defined number of arguments (the argument is one, `data`); one field is the data of the
launch and must give a Structure. Degenerate forms are not refused: an empty tail, a single atom that names a Structure,
a single unnamed Structure in parentheses. Declarations of Structures are still written in data. `data()` in code is a
launch of the data of the current launch over itself. Since slice 356 the clean graph executes the launch of a Structure
by name in the code of a method and in code over given data -- `S()`, `S(D)`, `S(data := D)` -- and a form whose head is
a place holding a reference to an ordinary Structure everywhere, the root of a unit included, as well as the named
supply of the arguments of `call` and `fncall` (the first part of sub-step 5б). slice 372 removes the former skip
of a named head at the root and over self; the private checks and remaining limits of 5г are stated at the start
of this document and in §6.1. The working frontend reads the former names and order and does not execute the launch by name (step 8).

<a id="principles"></a>
## 1. Principles (norm)

1. **Lmx structures suffice to describe everything**, expressions, methods and arrays included. The program, its data and
   its current state are one Lmx graph; there is no second AST, no data graph, no "prepared" result of the translator and
   no hidden copy of the source ([L2 §2.1](L2_spec_en.md#interpretable-tree)). "Everything here is simply a structure"
   (the author, 18:18Z): code and data are the same Lmx; the role -- data or code -- is given by the launch, not by the
   kind of memory and not by the Structure itself (the author's decision of 2026-11-11,
   [book](LMX_semantics.en.md#data-code-roles)).
2. **Every verification goes by addresses in the arena; addresses do not change** (the author, 18:02Z: "все верификации
   производим по адресам в арене, и имя тоже сравниваем по адрресу его в арене. Адреса не меняются"). Every check -- of
   a type, a kind, a name, a correspondence, an admission -- rests on the address of a primitive, an Lmx or a string in
   the typed arena: the address tells the object (§2.1, §5.1). A name is compared by the address of the single reused
   string of its spelling (§4) -- not by bytes, not by a hash, not by an incremental code. The addresses of existing cells
   and strings never move; growth and attaching of regions keep them (§2.3).
3. **The only non-Structure is the primitive** (the author, 17:22Z; the term -- 18:20Z: "Это надо называть не атом а
   примитив. Атом это понятие парсера"). `int: i 5` is put as a primitive: a typed arena cell holding 5. Its address
   tells everything: the **type** -- from the code in the record at that address (the author's decision of 2026-11-16, §2.0; before it, from
   the typed region in which the address lay); the **name**
   -- from the address → name table; the **value** -- by reading the cell itself. No wrappers, leaves, "occurrences" or
   other entities between the field of the containing Lmx and the primitive; the field of an Lmx is a `void *` cell
   referring to the primitive's cell itself or to an Lmx (§3.1).
4. **One mechanism of uninitialized primitives in all structures and in the signature** (the author, 18:00Z and 18:10Z).
   For every primitive type T there is a distinct type "T without initialization", told apart by the same mechanism --
   by the region in which the address lies (since 2026-11-16 -- by the code of the record, §2.0). The author, 19:02Z: "Сделайте тип "int без инициализации" указателем на ту
   самую ячейку (массив в арене, указателей на такие ячейки), при этом даже отпадает необходимость менять тип при первом
   присваивании" -- `uninit:T` is a **pointer primitive** from a typed region of pointers, pointing at a **pre-existing**
   cell of T with an unchanging address and type, not yet written. Since the decision of 2026-11-16 the record `uninit:T`
   holds the record of T right after its code: the pointer of the quotation is the constant offset between them (§3.2). `int: i` is a `void *` field pointing at such an
   `uninit:int` pointer, which points at the `int` cell of the place `i`; `int: i 0` is a field pointing at an `int` cell
   holding 0 directly; one representation in code, data and signatures, with no mark, flag, bitmap or walker table. **The
   first assignment and all later assignments** write into **the same** cell of T. The slot and internal pointer retain
   their addresses, physical types and values. The author's latest answer about `@i` supersedes Codex's explanation
   requiring a direct slot after the first write. This is storage support, not a language reference: `i` remains `int`.
   No initial value is promised and no changing initialized state is tracked. In a signature this representation
   distinguishes a mandatory formal from a default.
   The author's decision of 2026-11-17 withdraws a part of this item: a value record is a type and a value, and an
   assignment into a place that holds `uninit:T` changes the type of the record to T; the address of the cell stays
   the same (§3.2, [journal](../LMX_blog/2026-11-17.md#assignment-changes-type)).
5. **No parallel hidden structures of the program** at the interpreter or the translator. The service traversal tables
   ("namespace" in the author's words) are the implementer's to design, but **they are kept nowhere outside a
   traversal**: every traversal starts with empty tables, uses them and destroys them on any exit; they do not lie in the
   graph, beside it, in the arena as mandatory preparation, in a module, a cache or hidden state; a repeated traversal
   after a change of the graph takes everything from its current content (§5.2). The address → name table (§5.1), the
   index of typed regions (§2.1) and the string table with its index (§4) are arena and process state, not traversal
   tables; they are not mixed with the temporary traversal tables.
6. **Identifiers are reused strings with stable addresses.** A spelling is interned at input (parsing text, loading a
   unit, `sys\fromLmx`, attaching a foreign region); from then on a name is a pointer to the single string of that spelling,
   and identifiers are compared by pointer. No string comparison in an executor and no separate numeric code as identity.
   Each process has one canonical pointer per spelling; the pointers of the translator's process are not the addresses of
   another process, so a loaded unit normalizes its strings into the loading process's pointers at load (§4, §7).
   **Service operators and receivers are no exception** (the author, 18:18Z: "никакие служебные операторы и ресиверы при
   такой схеме никаких отдельных кодов не имеют!! Те же адреса строк : "for", "=", "**" и что угодно. У нас все -- просто
   структура"): `for`, `=`, `**`, `fn`, `merge` are the same strings of the `text` region, recognized by address; there
   are no separate codes of operators, receivers or language words -- neither as numbers nor as kinds of memory regions
   (§2.2); there is no hidden program of codes (§3.3, §6.2).
7. **The arena attaches new memory chunks; a record carries its type** (the decision of 2026-11-16; before it the arena
   typed the regions). Addressable cells never move; the graph needs no dynamic
   arrays in the arena: sizes are known at construction, growth attaches a new region instead of moving the old one.
8. **One contract for all:** source → construction of a clean Lmx graph → that same graph is consumed by **both** the
   translator **and** the interpreter (§1a). The built graph holds nothing but Lmx and primitives: no prepared interfaces,
   no plans, no traversal data, no stored results of name resolution (§3.5), none disguised as Lmx. The P0 parse tree is
   the builder's internal matter, not a mandatory input of the translator; saved translator tables are not an input of
   the interpreter.
9. **Native and the interpreter execute one and the same graph** with one semantics of local frames and direct writes; executable graph edit timing before endturn is unspecified ([L2 §10–11](L2_spec_en.md#own)); emitted `native` needs no names at a call; the interpreter recognizes a
   head by the address of its word and finds places by name through the tables of its own traversal (§5.2, §6.2).
10. **What is unclear is asked, not guessed.** Questions go to Codex as a minimal case; what Codex forwards to the author
    is not implemented before the answer, the rest continues. The author's model is not reopened.

<a id="contract"></a>
## 1a. The one contract: the builder and the two consumers (norm)

```text
source text ──► builder (parsing + construction) ──► a clean Lmx graph in the arena
                                                        │ primitives, Lmx, the address → name table, typed regions
                                            ┌───────────┴───────────┐
                                      interpreter                translator (emits native)
                                      walks the graph            walks the same graph
```

**The builder** is the only place where text becomes a graph: parsing (P0 today) and construction of cells in the regions
of the receiving arena, interning of spellings (§4), filling of the address → name table (§5.1). Its boundary is the
finished graph; the parse tree, its arenas and any working data of the builder are destroyed on leaving the construction
(like traversal data, §5.2). Parsing and direct field filling retain a written name as a word primitive (§3.5), without
a hidden binding for a future consumer. The declarations of `fn`/`sub` remain as written: the receiver creates F in a separate
traversal, including the explicit slice390 construction below (§3.4).
**The consumers** -- the interpreter (§6) and the translator (§7) -- read one and the same graph and prepare nothing in it
for each other. The translator emits native bodies and the unit's loading code. The loading code is a **generated
initialization of the same clean graph**: the exact cells in typed regions, their links, the rows of the address → name
table, the `native` references -- through the common low-level graph constructor used by parsing, by `sys\fromLmx` and by
the loader alike (a decision confirmed by Codex on 2026-11-08: this is not the former generated operations, place tables
and hidden interfaces; the unit keeps no source text as a reserve for execution or recovery; embedding the P0 parser into
loading is not required). Native bodies are bound to callables by the addresses of the built graph. Construction from
`sys\fromLmx`, `merge`, a child reservation and mail is the same constructor with the same boundary.

**Explicit new-graph construction, slice390.** In `lm_graph_build_root` this phase follows the filling of all P0 fields
and precedes pure `lmx_graph_preflight`. `lmx_graph_construct` opens its own fresh namespace through the existing
`prior`, prepares proven written `fn`/`sub` through the common declaring contracts and retains admissible known candidates
as ordinary reference-cell values. Every exit destroys the namespace and role queues and restores the previous traversal;
preflight, translation and subsequent execution inherit no such table and do not repeat that materialization over existing
DATA. Reached deferred declarations retain their ordinary runtime route.
This is a separate construction walk, without executing CODE or deferred initializers.

The traversal distinguishes data, code and expression roles through the existing contracts. Formals/their defaults, the
result description and a method's source DATA do not become CODE; an ordinary user field named `data` does not by itself
become method DATA. For an actually created F, including a nested F in a copy of an outer F's DATA, the phase examines
its proven CODE and current declarations. This bounded subset does not require recursively materializing the CODE of
every raw `fn` in the source DATA blueprint, and does not change that blueprint. Calls, computed actuals,
defaults and `test` do not execute while finding a known candidate; this does not establish full M11 coverage.

<a id="arena"></a>
## 2. The arena

<a id="value-record"></a>
### 2.0 The value record (norm: the author's decision of 2026-11-16)

The author ([journal](../LMX_blog/2026-11-16.md#typed-value-raw-layout)): the physical type and the value lie in one
record and are obtained from it; typing and the extraction of a value no longer go through the checking of addresses.
The exact contract is [L2 §3–§4](L2_spec_en.md#value-record). This subsection says what it changes in this document;
the dated text below that tells a type "from the region in which the address lies" describes the scheme before the
decision and the code as it stands, and is not a task to continue that mechanism.

- **Record.** `int type`, the code of the physical type, and right after it the raw bytes of the value: a number, a
  word, a reference, or the `parent/length/storage` descriptor. Every reference of the graph -- a slot, an element of
  `Array<@>`, a reference cell, `parent`, a key of the address → name table and of a copy map, an execution root --
  refers to a record. The size of a record follows from its code; nothing is sized by the largest kind. A stored
  reference is the address of the value, and the code stands in the four bytes before it (the author's answer of
  2026-11-16, [journal](../LMX_blog/2026-11-16.md#typed-value-reference-answer)): every address keeps its present
  meaning, and only the places that learnt a type from an address change -- they read the code at value − 4.
- **Alignment.** The value stands at an address that is a multiple of `max(alignof(T), 4)`, the code in the four bytes
  right before it, padding between records. The code and the value are read by ordinary typed accesses, not by
  copying bytes; the descriptor inside a record is naturally aligned, and its fields are read as before.
- **Type and value without classifying an address.** `lmx_range_classify`, `lmx_range_type_of`, `lmx_range_stride`,
  `lmx_domain_kind`, `lmx_domain_type` and the readers built on them (`lmx_graph_node_in`, `lmx_graph_cell_in`,
  `lmx_graph_value_in`, `lmx_walk_value_cell`, `lmx_graph_kind`, `lmx_graph_address_type`) take the kind, the type
  and the step from the code of the record. `sys\typeof` answers with that code; zero and an address outside the
  Message's arena give “no type” by a null test and the chunk list, with no search by type.
- **`uninit:T`.** One record: the code `uninit:T`, then a complete record of T (§3.2). The slot refers to the outer
  record, the name and `@x` to the inner one; the pointer of the earlier representation is the constant offset
  between them.
- **Codes.** A distinction the kernel needs is expressed by a new type code: the code word of a record holds a
  code and nothing else, with no flag bits or masks (the author: "заводите просто новые типы себе и всё",
  [journal](../LMX_blog/2026-11-16.md#new-types-not-bits)). Different Structures are not different types: a user
  model produces no code.
- **Immutability** is told by the code -- the immutable variant of a type --, not by the interval of a region.
- **Dense storage.** The elements of a numeric `Array<T>` and the slots of a Structure are dense and carry no codes;
  the element type is told by the code of the Array's record. Typed native locals and temporaries are not packed into
  records.
- **Chunks.** The interval index tells only which arena and which chunk own an address: transfer, collection, the
  home of a name. The division of the arena into chunks is the allocator's policy. By the author's order the
  transition has two stages: first a cell of a present pool becomes a record with the pool's step; then the chunks
  by type are removed and the records of an arena go in one stream. On attach the donor's chunks become
  chunks of the receiver: records keep their addresses and codes, and nothing is registered anew for typing. One
  arena is never accessed from several threads.

Why: on the accepted G2 of slice 410 one read of a graph slot through the ordinary accessors costs 107–170 ns against
0.35–0.53 ns of the same loop without kernel calls, one classification of an address 10.6 ns at 100 intervals and
80 ns at 10,000, and an `int` allocated on its own holds 289 bytes of heap against 4 in a bulk allocation
([research record](../steps/witnesses/typed-value-research-20261116/notes.md)). Implementation is OPEN:
[plan M15](../next_core_tasks_v3.md#typed-value-records).

### 2.1 Regions (decision)

The arena of a Message is a list of **regions** (`LmxSegment`). A region is one contiguous block of cells of one C type
and one stride: `{ base, stride, type, count, used, next, owner }`. The region's type comes from a closed inventory
(§2.2). A region is never reallocated; when its cells run out, the arena attaches the next region of the same type.
Address → type is a lookup of the region by the half-open interval `[base, base + stride·count)`; the interval index is
ordered by address and lives outside the graph as arena state (not a traversal table: it is the means of learning a type
from an address, §1 item 2). Today's `LmxPool`/`LmxChunk`/`LmxRange` are the same idea (a pool of chunks of one stride,
intervals), but with profiles, roles and side arrays (`links`, `slot_owner`, `holder`, `side_cells`) that §9 removes.
Since the decision of 2026-11-16 (§2.0) an interval tells ownership only: the type is read from the record, and a
region of cells of one type is the allocator's present policy, not the means of typing.

A program gets the same answer from the receiver `sys\typeof(arg)` — the code of the type of the value at the address, read from
its record since the decision of 2026-11-16 (the present code asks the region) — and reads a Structure's slots as an array of references `S[i]` (author's decisions of 2026-11-10:
[book](LMX_semantics.en.md#get-type), [journal](../LMX_blog/2026-11-10.md)); the numeric values of the codes are not
fixed by the norm. The receiver is implemented in the clean graph by one kernel operation for both consumers —
`lmx_graph_address_type` over `lmx_range_type_of`: a Structure is the address of its own header, a reference the
address it holds, an `int` value is no address, a written zero is the null address
([record](../steps/witnesses/get-type-20261110/notes.md)). The index of a Structure is implemented in the clean graph
([record](../steps/witnesses/struct-index-20261110/notes.md)): the value of `S[i]` is a pointer cell of a region of its
own, `LMX_TYPE_GRAPH_REF`, an "untyped reference" that holds any address of the arena and is never stored in a slot of
the graph; the read is `lmx_graph_index`, the write against the physical slot's temporary receiving descriptor (slice380, §5.2/§6.3) is
`lmx_graph_index_write`, the number of slots is `lmx_graph_length`, and a place `@: p int` admits an untyped reference
through `lmx_graph_int_ref_of` — one kernel operation each for both consumers. An index outside the fields is the
interpreter's answer 7; native and forced stop R0.

### 2.2 Types of records and regions (decision; a finite inventory)

| Type | Cell | Content |
|---|---|---|
| `int`, `char`, `unsigned char`, `size_t`, `unsigned`, `ulong` | a number of the machine type | a number primitive; `int: i 5` is an `int` cell holding 5 |
| `uninit:int`, `uninit:char`, `uninit:unsigned char`, `uninit:size_t`, `uninit:unsigned`, `uninit:ulong` | `void *` -- a pointer to a cell of T; since 2026-11-16 the record of T itself, right after the code (§3.2) | the internal pointer primitive of a declaration without an initializer (§1 item 4); refers to a pre-existing cell of T. An assignment into the place changes the type of the record to T (the author's decision of 2026-11-17, §3.2). It does not make the language place a reference. In a signature it distinguishes a formal without a default from a default |
| `uninit:ref` | `void *` -- a pointer to a `ref` cell | a reference place without a promised initial address -- `@: p` ([book :487](LMX_semantics.en.md#explicit-copy)); the author's analogy "for all primitives" extends directly to the pointer receiver, which has "the same place and value forms as `int`" (confirmed by Codex, review 2) |
| `word` | `const char *` | a word primitive: a pointer to the interned string of a spelling -- operators (`+`, `\`, `[]`, `:=`), receiver and language words (`fn`, `if`, `return`, `node`, `int`), any written name (§3.5) |
| `ref` | `void *` | a reference cell: a slot of an Lmx field or of an Array element, the cell of a pointer `@: p T` after the first address write; holds the address of a primitive or an Lmx, or 0 |
| `lmx:data`, `lmx:immutable`, `lmx:result` | `Lmx` | the header of an ordinary Structure, of an immutable Structure (`independent: immutable`) and of a Structure **created by executing the `fn` receiver** ([L2 §2.1](L2_spec_en.md#interpretable-tree): the pool of `fn` results receives only a structure created by executing `fn`, not a Structure with similar parts; [§3](L2_spec_en.md#type-by-range): ordinary and immutable in different regions, not a C type per model) |
| `lmx:array<T>`, T ∈ {`int`, `char`, `unsigned char`, `size_t`, `unsigned`, `ulong`, `ref`} | `Lmx` | the header of a graph Array with the requirement T on its elements ([L2 §3](L2_spec_en.md#type-by-range): for an Array the range also tells the element type); the backing is `length` T elements, which are `void *` for `ref` (§3.1) |
| `text` | `char` | string bytes: interned spellings of names and operators (§4), user string literals |
| `name` | `{ void *address; const char *name }` | a row of the address → name table (§5.1) |

The header kinds are the finite inventory of the physical kinds of [L2 §3](L2_spec_en.md#type-by-range): ordinary,
immutable, an `fn` result, an Array with its element type; the kind is read from the code of the record (§2.0; before
2026-11-16 -- from the region in which the Lmx's own address lay, with no tag in the header or a cell), with one
common Lmx record (§3.1). **A region kind is not an opcode:**
an `fn`/`sub` definition, a statement, an expression and a data Structure are the same Lmx of the ordinary kind;
what a form is, is read not from the header's region but from the role of the Structure in the launch and from the
address of the head word (§3.3, §6.1). The service types
(`name`, the interval index) are visible to the arena and the executors but are not values of the language. User models
produce no region types: a Structure of any model is an `lmx` cell plus its slots.

### 2.3 Allocation at input and construction (norm + decision)

Before translation the unit's graph is known in full, so an emitted unit declares the **exact** sizes of its regions by
type (the number of `int`, `uninit:int`, `ref`, `lmx:*`, `word`, … cells, the length of `text`) and builds the graph in
them without intermediate dynamic arrays (the cell of T of a place without a value is allocated at construction together
with the `uninit:T` pointer onto it, §3.2). Growth at run time -- `merge`, a receiver's result, `sys\fromLmx`, a child
reservation, attaching mail, executing a declaration with an initializer (§3.4) -- takes cells from the current region of
the needed type and attaches a new one when it is full; the size of a new region is the arena's policy (decision; not
less than requested), the addresses of earlier cells do not change. `lmx_arena_attach` moves the donor's regions into the
receiver's list without relocation ([L2 §6](L2_spec_en.md#arena)); `mark`/`revert` roll back a failed construction,
releasing the regions attached since the mark and restoring `used` of the earlier ones.

### 2.4 Collection (decision)

Liveness is reachability from the roots ([book §22](LMX_semantics.en.md#memory)). Marking goes by regions: each region has
a bitmap of live cells for the current generation (a service traversal table, built by the pass and discarded); a cell is
marked by nothing. The traversal follows the slots of `lmx` cells (the address in each `ref` cell of the backing), pointer
cells, `parent` and the address → name table (the rows of live addresses live, the rows of dead ones are dropped). While
the place holds `uninit:T`, collection follows it to the cell of T; after an assignment the place holds T (§3.2). Separately taken addresses also keep T alive; unreachable cells follow ordinary collection. A region with
no live cells is released whole; a region with live cells stays and its
free cells are reused (decision; no compaction -- addresses are immovable).

<a id="lmx"></a>
## 3. The Lmx graph

### 3.1 The Lmx record (decision within [L2 §2](L2_spec_en.md#lmx))

```text
struct: Lmx
    @: parent Lmx        # structural parent, 0 at the root
    size_t: length       # number of Structure fields or Array elements
    @: storage void     # element storage address
```

The flat header contains only parent/length/storage, with neither native nor capacity.
A Structure or Array reference points to this descriptor's start; the code of its record stands in the four bytes
before it (§2.0). Its address survives resizing;
storage may move. The arena table “descriptor address → capacity” records reserved elements.
One allocation/resizing mechanism serves Structure, Array<@>, typed and service arrays; no separate
List/DynamicArray family is needed. Stable standalone primitive cells and canonical strings retain
their contracts; do not allocate a separate Array for every cell.

A Structure or Array<@> slot contains void *; a numeric Array<T> stores T elements directly.
Slot/element addresses are void **/T * and survive only while storage is not relocated.
Structure and Array<@> are interchangeable in all common operations, including execution and named
paths where names exist. A category difference alone is no reason for refusal.

L2 [] of any finite rank computes offsets without checking length, sign, arena, or a former field;
negative indexes are allowed. L3 reduces adjacent [i][j] to one linear index with one check,
0 <= index < length. An L3 element reference stores the Array descriptor reference and index, never
a storage address; the distinct L3 primitive-pointer type uses the common typed foundation.
An L2 address is not repaired after storage moves. [Exact contract](L2_spec_en.md#array-capacity).
Implementation of this [M13](../next_core_tasks_v3.md#flat-lmx-descriptor) migration remains OPEN.

<a id="get-descriptor"></a>
### 3.1.1 Header addresses

One explicit argument S selects S; with no argument, `sys\descriptor()` / `sys\descriptor:` select the current data,
as `sys\descriptor(data)`, including inside nested control bodies. Code requires an explicit argument.
The common call mechanism selects the argument; both variants share the same result-address contract.

Ordinary receiver `sys\descriptor: S` returns a Structure containing three actual field addresses,
parent/length/storage: Lmx **, size_t *, void **. A dereferenced write changes S's header directly;
writing a result field changes that result's own pointer. Writing through the length address does
not allocate storage: use sys\resize/sys\reserve for a consistent length/reserve change.
The result contains neither native nor capacity; there is no copy, proxy, write-back, or separate opcode.
S.parent may have the same numeric address as S: typed `Lmx **` access addresses the field, not a second Lmx.
Taking the address neither extends S's lifetime nor transfers ownership. Arbitrary finite pointer depth and Array rank
are independent; explicit paths and dereferenced writes use common typed operations, including references and function
pointers. Restrictions on assignment through a bare Structure or function name do not prohibit them.

Address `@x` of a namespace variable belongs to the current call's local cell. For a ready field,
`@(data\x)` retains the source graph cell's own address. For computed declaration
`int: field getValue()`, `@(data\field)` addresses the record of the declaration: an explicit path
executes nothing, neither on a read nor on taking an address (the author's decision of 2026-11-17,
[book](LMX_semantics.en.md#path-reads-no-execution)); lifetime remains ordinary.
A ready place's typed cell retains its address and type on writes, including through uninit:T;
taking its address does not read absent payload. This does not suppress evaluation of `@`'s operand:
for computed input `int: x next()`, `@x` obtains the value and the local int cell's address.
Do not substitute a source field for the local cell to preserve former behavior.
[L2](L2_spec_en.md#lowlevel-address).

<a id="header-receivers"></a>
### 3.1.2 Reading the header and service tables

`parent(S)`, `length(S)`, `sys\storage(S)` load header fields directly.
`sys\native(S)` queries call's tables for the ordinary Structure descriptor of native variants,
or 0; obtaining it does not execute code. `sys\capacity(S)` reads the arena's reserved capacity.
All five no-argument forms select current data. They are ordinary non-declaring receivers;
same-headed forms in data remain data. A simple getter creates no descriptor or proxy.
`sys\resize(S,n)` changes length and storage if necessary; `sys\reserve(S,n)` changes reserve only.
Capacity is not consulted on ordinary indexed reads/writes.

Rename size/data to length/storage in Lmx and its consumers, not in every technical structure.
data/code remain call's Structure arguments; node retains its existing meaning and ABI.
[Forms and rules](LMX_semantics.en.md#header-receivers), [plan M13](../next_core_tasks_v3.md#flat-lmx-descriptor).

<a id="system-indexof"></a>
### 3.1.3. A field's index

`sys\indexof(field parent)` returns the physical index of the unique occurrence of `field` among
the immediate elements of Structure `parent`. An absent field or multiple occurrences of the same
reference produce an error under the ordinary failure rules.

`sys\indexof(field index parent)` selects occurrence `index` of that same reference, counted from zero,
and returns its physical index in `parent`. A missing selected occurrence is an error.
The occurrence number and returned index differ: when a reference occurs at positions 2 and 5,
`index = 1` returns 5. Both forms receive `parent` explicitly; there is no zero-argument form.

Lookup uses the field's identity/reference, not an equal name or primitive value. It follows neither
nested Structures nor graph references. Structure and Array<@> use one mechanism for reading immediate
elements. Reuse existing addressing; no reverse-index table or per-write maintenance is needed.

<a id="primitive-storage"></a>
### 3.2 The primitive (norm: the author, 17:22Z, 18:00Z, 18:10Z, 18:20Z, 19:02Z)

**The term.** The only entity of the graph that is not an Lmx is called a **primitive**; in the relays and journal sections
before 18:20Z it was called an "atom" -- those quotations are not rewritten, and the term "atom" in this document remains
only for the parser's notion (a P0 atom).

A primitive is one arena cell outside the `lmx:*` regions: a number, a pointer "without initialization", a word (§2.2) or
a reference. A primitive has no header; its type is the code that stands right before its cell in the record (§2.0; before 2026-11-16 -- the
region's type), its name a row of the address → name table (if the
primitive is named), its value the cell. `int: i 5` in the body of a Structure `S`: an `int` cell = 5 in the `int` region;
a slot of `S` holds its address; a row of the name table `(the cell's address) → "i"`. Reading `S\i`: find the slot of `S`
whose cell is named `i` (§5.1), read the cell by its type. Writing `S\i := 7` writes into the same cell by the ordinary write
contract ([L2 §10–11](L2_spec_en.md#own)).

**A place without a value.** `int: x` in code, in data and in a signature: at construction the place receives its own
`int` cell in the `int` region (not yet written; every primitive place has its own cell -- two places never share one, a
literal of code is not shared with a place) and a pointer primitive onto it in the `uninit:int` region; the slot points at
that pointer. "Without initialization" is the distinct type of this pointer, recognizable by address only (§1 item 4);
the same for every primitive. It promises neither zero nor randomness, and is not a mark outside the graph; the book:
[:432](LMX_semantics.en.md#construction) -- no invented initial value, in a signature a mandatory formal;
[:123](LMX_semantics.en.md#fields) -- a repeat without a value in code writes nothing and only checks the contract, and in data it is one more occurrence of the name (there is no
separate policy of repeated declarations; REPEATED-DECL-OTHER-KINDS is unchanged). `int: x 0` is a slot onto an `int` cell
= 0 directly. The difference between a mandatory formal `int: q` and a default `int: q 0` is the general address
classification of what the slot points at, without a signature wrapper, a mask or a side mark. The name `x` is a table
row for the address of the `int` cell (it exists from construction; the `uninit:int` pointer is not named).
Since the decision of 2026-11-16 the place is one record: the code `uninit:int`, then the record `int` of the place --
the code `int` and the cell; the slot refers to the outer record, the name and `@x` to the inner one, and the pointer
of the earlier representation is the constant offset between them (§2.0).

**Assignment** (`data\x := 5`, an argument received into a frame place): a value record is a type and a value. The
received value is written into **the same** `int` cell, and if the place holds `uninit:int`, the type of the record
changes to `int` (the author's decision of 2026-11-17, [journal](../LMX_blog/2026-11-17.md#assignment-changes-type); the rule of
2026-11-08 that the type of the place does not change on the first assignment is withdrawn). The address of the cell
does not change and the name row stays in place. An assignment to a local of the call writes into the place of the
call: the graph does not change and the data are not published. Today's code still keeps `uninit:int` after a write;
a separate slice brings it to the norm ([plan](../next_core_tasks_v3.md#typed-nil-plan)).
Internal indirection is implementation support, not a user operator:
`i` remains `int` in expressions and argument admission. `@i` separately creates a language reference.
The check by both executors:
`int: i`; keep `@i` without reading unwritten bytes; `i := 5`; reading through the kept address gives 5; `i := 7` gives 7 at
the same address.

**Reading and admission.** Internal indirection is transparent: the code `uninit:T` (before 2026-11-16 -- address classification)
determines access to the
`int` cell, from which the value is read. A place holds `uninit:int` until a value is written into it: an assignment changes the type
of the record (see above). Codex's review-2 explanation requiring a runtime refusal on that basis is superseded by the author's
latest clarification. Before a write no initial value is promised; checks do not read those bytes or demand zero,
randomness or a special error. A signature describes mandatory/default arguments and remains unchanged by calls;
actual arguments are received into separate frame places.

**Exact scalar foundation, WIP394.** `LmxScalarABI {size, init, copy}` describes exact access to a C scalar object.
One existing exporter selects32 non-reference/non-opaque rows from Source35 and emits type aliases in the generated header,
with typed init/copy and ABI records in the profile body. This is one source projection; equal C spellings can share
access callbacks while retaining distinct source descriptions. None/void receive no cell, and FILE receives no scalar ABI.

`lmx_arena_scalar_cells_profiled` uses the existing arena/pool; `pool.scalar_abi` enters the physical key along with
type/stride/profile. ABI is not a Model, and pool.profile does not replace source identity. The complete Value stores
`scalar_abi`, `physical_profile`, `source_type` separately from existing model/references/referent. Owned FOREIGN capture
retains the object in the arena rather than a local address: mutable load/materialize owns its storage, while a suitable immutable
cell preserves identity, full physical type and profile. `receive_scalar` checks ABI; store applies protected/code
guards before typed copy. This is exact representation transport, not semantic conversion or complete runtime admission.

In slice398, `prepare_scalar_store` is factored from the same FOREIGN branch of the common writer: it purely
checks the physical place and destination ABI, preserving the place's declared SOURCE and complete RHS Model/context.
It allocates no storage, publishes no payload/companion and makes no snapshot. Working GraphRun separately produces
an owned snapshot; physical publication uses the existing `cell_place/value_store` with the same guards and typed copy.

The raw allocator creates C storage with `present=0`, without a current Value. Load and copy preserve absence
without reading source payload; GC retains metadata and the physical pool.profile in this state too. Capture checks
the ABI/stride of a registered FOREIGN source before copying. Copy rejects a nonzero referent whose physical owner
cannot be found. Mapping storage to written L3 declarations remains part of the open construction bridge.

Common copy/projection/qualification and GC account for scalar payload and its cell companion's graph dependencies;
the ABI record remains generated-module metadata. Runtime11 prod/observe is built; the machine unit passed native/forced with an ordinary
owner/root0/root1, including FP precision, i64/u64 limits, incompatible ABI, protected write/no mutation, nonzero-profile
immutable identity and copy/projection/qualification/GC. This is a bounded foundation unit check: public primitive resolution,
Run working/receiving/FFI, activation/pending Value GC roots and Foreign-Array ABI remain required OPEN work.
Source16/Unit-machine06 also checks unfilled storage and capture/copy refusal before ownership is lost. Whole G1/G2
quick/fixedpoint20 and G2 targeted gates PASS; full acceptance of the common bridge still follows, and M13 is not complete.

### 3.3 An expression (norm: the author's example `x+1`)

`x + 1` is an Lmx of the ordinary kind with three fields: field 0 → the word primitive `x` (the written name: a `word`
cell with the canonical pointer to the string `x`; resolved into a place at execution through the current traversal's
table, §3.5), field 1 → the word primitive `+` (a `word` cell with a pointer to the interned string `+`; an
implementation decision: a physical word cell with a pointer to the canonical string, with no opcode and no occurrence
entity), field 2 → the number primitive `1` (an `int` cell belonging to this expression). No typed operation record
(`LmxOp`), no frame with numeric selectors and no special kind of memory for code: the interpreter recognizes the
operation by comparing the word's pointer with the interned strings of the operators (§6.2), and the operand types by
the regions of their cells after the names are resolved. A written Frame `head: a b c` is an Lmx named by its head (the
address → name row for this Lmx's address is the string `head`) whose fields are the arguments `a`, `b`, `c` (the author
2026-11-09: «объявление fn в дереве это именованная структура (fn ее название) с аргументами»,
[journal](../LMX_blog/2026-11-09.md)); what a form is, is decided by the consumer during its traversal, not by the
builder: by the norm -- the role of the Structure in the launch (in data a form declares -- a place when its head is a
receiver of a place, otherwise a Structure; in code it is a call of its head -- of a callable or, by the author's decision
of 2026-11-11, of an ordinary Structure, which it launches by name: [book](LMX_semantics.en.md#data-code-roles),
[journal](../LMX_blog/2026-11-11.md#structure-call-by-name)) and the general resolution of a head in code -- a receiver
of the language, a callable or an ordinary Structure (§3.5); slice 372 sends a named head through shared
resolution and launch (§6.1) at the root and over self as well. Full acceptance, the remaining root publication and path heads
are still open ([section M11 of the plan](../next_core_tasks_v3.md#m11)). An operation written as
a Frame (`-(2 + 3)`, `\(p)`) stays an operation, as in any expression: the operator word in field 0 and the operands,
with no name; so do `x + 1`, a path and `:=`; an anonymous Structure gets no name. A nested Structure of a body is a
child Lmx with `parent` on the containing one. A Frame written on a path head, `owner\field: actuals`, is the unnamed
Lmx [path, actuals] -- the path expression [owner, \, field] in field 0, split by the builder once, while the lexical
boundaries are known (Codex, review of 331; an exact identifier in backquotes stays one name; slice 337); the consumers
recognize the general form of the path in field 0 (`lmx_graph_path_head`) and read such a statement alike
(`lmx_graph_eval_path_statement`, `lm_graph_emit_path_statement`): it does not write the field -- `owner\field := value`
writes a value through a path; a known place that is no Structure at its head is a refusal (answer 8 of the
interpreter; slice 346), and its other readings -- a callable through a path, a declaration of a Structure through a
path -- are not executed yet (5). Before slice 346 such a form wrote the place with the one value, and earlier still
the head stayed one word: at the root `Box\hits: 5` defined a new place named `Box\hits`, in a body it answered 3. An
anonymous body whose first statement were a bare path read followed by another statement has the same form and is
read as this statement (such a read has no effect).

### 3.4 Callables and namespace

<a id="call-receivers"></a>
### The `call` and `fncall` receivers

| Form | Supplied values `args` | Input `data` | Result |
|---|---|---|---|
| `call(args data code)` | `args` | `data` | none |
| `call(data code)` | not supplied | `data` | none |
| `call(code)` | not supplied | `code` | none |
| `fncall(args data return code)` | `args` | `data` | according to `return` |
| `fncall(data return code)` | not supplied | `data` | according to `return` |
| `fncall(return code)` | not supplied | `code` | according to `return` |

`args` is the Structure of actual supplied values, exactly the argument Structure
of an ordinary `call`. It is not formal declarations, a signature, or a separate
callable part. `data` describes input places, requirements, and defaults.
`return` describes the result; `code` is the executable Structure. `call` returns
no value; `fncall` returns a result according to `return`.

Forms without `args` supply no additional actual values. Omitted `data` means `code`
itself: `call(C)` equals `call(C C)`, and `fncall(R C)` equals `fncall(C R C)`.
A child `data` field inside `code` is not selected automatically. These are
abbreviations of one operation, without requiring an empty Structure allocation
or a new service object for omitted `args`.

All forms and ordinary method/Structure calls share one interpreter path:
select parts → bind actuals to data → common admission → fresh namespace → execution and result.
Receiving actuals neither changes source data nor runs entry initializers.
Calls from test and converters use the same mechanism. Known native-to-native calls
may still go directly through C without graph packaging.
[Full contract and named arguments](LMX_semantics.en.md#call-receivers).

<a id="private-binding"></a>
### Receiver private:

`private:` excludes the marked field and its corresponding binding from a call's dynamic
sources. Direct visibility from anywhere, explicit paths, and ordinary lexical lookup remain;
sequential visibility and explicit argument passing do not change.
Skipping the field follows the common binding order for every call/fncall form, ordinary call,
interpreter and native execution. This is a field property, not a global name ban or access
protection. Use the common binder without a separate registry or checks on direct reads.
[Full contract](LMX_semantics.en.md#private-binding).

<a id="call-frame-20261115"></a>
Every call creates its own namespace. For fn/sub/catch, unified data describes the inputs;
args in call/fncall contains actual values. Short headers remain. An actual replaces the corresponding
source declaration in the frame, and its initializer does not execute. Preparation collects only
data/code roots, without visiting branches or graph references or auto-filling source data.

Entry has no initializer-execution phase. Ready declarations fold during clean-graph construction
without program calls; uninit:T remains. An unused computed data field is not executed.
Reading obtains its value through the common mechanism, as with `data\field`: the written RHS
executes, not an implicit call on the obtained reference. Given `@: fptr getFuncPtr()`,
`fptr("hello world")` first obtains the pointer, then calls the resulting function.

Variables and const are visible from their initial declaration onward in their scope and below.
Names of Structures and callables retain bidirectional visibility; a function-pointer variable does not.
A new branch name does not escape its branch. Repeated `int: x bump()` retains evaluation,
admission, and assignment to existing x; only the repeated C declaration is omitted. Physical repeated
fields remain and are selected by `S\[n]x`. An explicit path is not restricted by the declaration
order of a bare name. A read through a path executes nothing; the RHS is executed when its code statement is reached.

Bare x and @x refer to the frame place, independently of source-field replacement immediately at entry,
even before the first read: the selected value or computed description is retained.
The rule is the same for explicit data, lexical binding, and dynamic binding. It does not deep-copy
referenced objects. `x := 0` changes the namespace; `data\x := 0` changes the source graph.
For computed input `int: x next()`, @x obtains the value and the local cell's address.
With `@(data\field)` and source `int: field getValue()`, the record of the declaration is addressed, not
getValue()'s result: an explicit path executes nothing (the author's decision of 2026-11-17; the former rule is withdrawn).
A ready place is addressed directly.
Lifetime remains ordinary. @f() was a research example, not a separate support or prohibition task.

Mandatory copying of executable code at entry is withdrawn, including the former copy of only
the corresponding C function's code. Selected local values/descriptions remain independent;
binding uses hidden arguments without an environment copy. Methods and ordinary Structures share
compilation without data=code; distinct actual supplies produce distinct C signatures.
Known native calls known native directly in C. Graph writes do not clear native: updating it requires
explicit compilation and an endturn boundary (§6.5–7). Before that boundary the time at which
executable graph changes take effect is unspecified.

Local frames are not published. Load-dirty, the shared direct-access cache, and flush() are cancelled;
explicit writes are observed through actual aliases in execution order.
[Agreed norm](LMX_semantics.en.md#call-frame-20261115),
[single M14 task](../next_core_tasks_v3.md#native-structures).

The source callable Structure retains its head and written data/return/code parts. The local namespace
is not its child field. No executable-code copy is required to equalize the time at which edits take effect.
The former args declaration part and code-to-data auto-fill are removed through one representation/consumer change,
not parallel semantic paths. Abbreviated fn/sub/catch headers remain with unified data;
a header without code describes a call signature, not a separate complete function.

### 3.5 Names: words in the graph, resolution by the traversal (decision, checked by Codex, review 2)

Variables and const are visible sequentially from their initial declaration in their scope and below.
Named Structures and callables are visible in both directions; a variable holding a callable stays a variable.
The namespace collects only data/code roots, without graph auto-fill or initializer execution at entry.
Data inputs are available to executing code; collecting the code root does not expose future locals.
A new branch name is not visible outside; repeating an already visible declaration preserves RHS evaluation,
admission and writing to the selected place. Before a local declaration, ordinary available outer bindings
can apply, without a separate TDZ. The 2026-11-15 clarification replaces general bidirectional visibility.
[Norm](LMX_semantics.en.md#call-frame-20261115).

The builder **does not bake hidden bindings** for a future traversal into the graph: written heads, paths, expression
operands and the names in the supply `a := v` retain word primitives with canonical string pointers (§4). Explicitly filling
a reference place with a known language value during slice390 construction (§1a) is ordinary graph content, not a retained
resolution table. Resolving a name into a place is done by the consumer during its own traversal, taking into account the
current activation, the selected `code`/`data` and the current content of the graph: the nearest local binding of the
calling expression, the dynamic input it inherited along the chain of activations, then the lexical fallback by `parent`
([book §12, :827–829](LMX_semantics.en.md#dynamic)); a field of the selected `data` in `call: data code` -- by its slots;
the bindings found are maps **of the current traversal only** (§5.2), not a result stored in the graph. Direct graph
references in slots are only the real links of the language: the value of `@: p Model`, a field holding a Structure, an
address written by the program -- not a hidden outcome of resolution. A mention of a known Structure -- in the tail of
a declaration, in the arguments of a call -- is likewise expanded neither by the parser nor by the builder: an atom
(in the graph, a word primitive) stands in the tree, a pointer to it, and it begins to refer to it at interpretation
and translation (the author's answer of 2026-11-11, [book](LMX_semantics.en.md#colon-declares)); the clean graph
executes this since slice 355: when the declaration is executed it does not rewrite the slot of such an atom, and the
name of the atom is looked up when a path is read through it (sub-step 5а of
[section M11 of the plan](../next_core_tasks_v3.md#m11)). The working values of different recursive
activations each live in their own frame and are not read from the shared formal or its default. The translator resolves
the same words during its translation with its own tables and emits native by the addresses found (§7); a code change does not invalidate native; updating it requires explicit compilation (§6.5). Verifiability: after construction the P0 tree is absent (its arenas are released), and the next
traversal starts with empty tables -- checked by the clean-traversal criterion (§11 item 6b). `sys\toLmx` prints a word by its
string, and a named primitive or Lmx by the address → name table.

In slice390 this route is bounded to the direct two-argument form `@: name candidate`: the construction-time reader proves a candidate
through its current source occurrence, physical scope and created-F binding, or through a directly written Structure.
It does not substitute a lexical match for a formal, own DATA
place, pending declaration, ambiguous name or free input. A mutable alias is a deferred read even if its initial target
is known in this traversal; its payload is not frozen and its chain is not evaluated to a fixed point.
An unknown candidate stays written and uses ordinary runtime reception when it is actually obtained.
Known path extensions are described below; additional type fields and applying this new phase during runtime `merge`/`sys\fromLmx` remain OPEN.

**Source-known paths, slice391.** Private Run helpers `construct_slot`, `construct_atom` and `construct_value` read
a proven source path without an activation resolver or expression evaluation. A named step uses the existing field
selection and exact raw-source → F correspondence of the current construction walk. A selected atom continues through
lexical lookup only; the pending audit examines actual DATA/CODE scopes, while EXPR creates no such scope.
Nearest-formal, own-DATA, pending/ambiguous-binding and free-input masks for a bare name remain unchanged.

A literal numeric index checks the physical slot bounds and yields the immediate address of its selected value:
if that is a raw Structure/Frame, construction may retain that very value; it neither reapplies `fn` to the selected Frame
nor turns a WORD into the Structure its spelling names lexically. Thus `A(B)` distinguishes `A\B` from `A[0]`: the latter
selects a WORD cell. In bounded materializer391 such an index is not a known Structure, so its initializer stays raw;
the reached runtime4 of bounded `@Struct` is not stated as a universal rule for receiver `@`. A computed index
and a mutable reference stay deferred; construction reads neither their effects nor their initial payload.

Classification follows the physical value, with no exceptions by the name of an F part. Current `F.data`, stored
by `fn_make` through `graph_put` as direct kind4, is a known Structure under the generic case; current kind6 references
in `F.args`/`F.code` stay deferred. For pending audit, private `construct_data_scope` separately recognizes actual
lexical DATA: its `parent` is an FN result, and `method_data(parent)` points to that exact Structure. A full
`method()!=0` is not required: a bodyless descriptor has its own DATA too. This role adds no DATA to the materialization
queue, walks no source blueprint and executes no initializer. The missing audit was discovered after intermediate
private48: a method and a bodyless descriptor answered4 instead of the required2; Runtime03/Graph03 give2/2,
with data width still2/2. This changes no signature, method-DATA or CODE role, opens no early execution
of their contents and adds no typed/qualified/common admission. Full M11.7, M13/M14 and applying the new phase
to runtime `merge`/`sys\fromLmx` remain OPEN. Private48 triple/AFTER39 predates this correction;
after it, private02:49 interp/native/forced and AFTER39 passed on Source05:907, with the previous43 expected files unchanged.
The first whole bootstrap01 was stopped without acceptance. Whole `boot-m11-construction-paths-02` passed with genuine G1/G2,
nine smoke cases each, and fixedpoint15/verify907; Runtime03 matches the G2 driver. Intermediate Source06 changes the formatting
of two fixture sources relative to Source05: complete AFTER2 and four generated native/forced programs match.
Final Source07 removes redundant trailing blank lines from the six new sources:10 generated programs match genuine G2 outputs,
with build4 control and fixedpoint03:15/verify907 PASS. Core and compiler-build inputs are unchanged,
with no additional whole run. G2 repeat49 triple/AFTER39, render35/14 and fresh docs-check01 PASS;
final index before commit.

**Borrowed receiving view, slice392.** Common `declaration_parts` reads only the receiving chain and returns borrowed
leaf/model/candidate, candidate presence and receiver knowledge; the caller retains the original root with every
qualifier/Array link. Model/default contents and mutable payloads are neither traversed nor evaluated. A two-argument
`@` remains ambiguous here; the signature wrapper separately retains the previous presence contract: a WORD is a requirement
without a default, while explicit0 is a present value. This conclusion is not automatically applied to the same form in DATA.

A DATA/CODE logical name is returned only for a proven declaring contract. The generated exporter uses
`primitive.spelling`: only cell1 rows with a single C identifier enter the C projection. Thus `c.uint8_t` can
be proven by a source spelling, whereas language alias `u8` alone does not prove type `c.u8`. Other `c.*` forms retain
provisional UNKNOWN; neither the prefix nor the argument count replaces the role of an actual C declaration.

Construction skips the receiving chain and its groups as separate DATA scopes; a typed model does not become candidate
data. Only the existing direct two-argument `@` owns its literal-DATA operand and applies bounded materialization390/391.
Unsupported qualifiers, Array, deep and typed declarations remain wholly raw;
the logical-step guard reports unsupported rather than presenting such a form as an ordinary Structure. Numeric indexing391
still selects the immediate physical slot without reinterpreting an atom or `fn`.
`call_single` checks the selected whole field's logical description before admission: a raw declaring description
is not presented as a ready Structure value. Normal whole-Group-as-first fallback is preserved; a ready reference
obtained by physical indexing uses the common route. `written_whole` first checks DATA shape through the pure binder,
default presence and shared declaration proof, then physical runtime kinds. The early contract1/3 gate in `call_reading`
is removed; char no longer incorrectly enters FREE scan. No language-word whitelist substitutes for the receiving contract.
Private21 triple/negative AFTER15 and whole02 with genuine G1/G2 passed; actual G2 interp21/full AFTER21 PASS.
42 emitted native/forced images plus2 libc/backend files gave44 byte-equality PASS, with no new compilation or rerun
of ready private binaries. Fixedpoint13 artifact/2 canonical checks and G2 render35/14/both snapshots PASS;
docs-check/index/commit/push392 still follow. Model/default remain source receiving descriptions: this is not yet typed
storage/admission or an actual C-door general bridge. Those remain OPEN along with M13 and full M11.7/8/M14.

**Source interface, slice393.** `LmxImplSourceReader` supplies operation-local name and receiving-fact callbacks to the
common implements worker, without a new parser or a persistent name/type map beside the graph. The clean Graph reader
uses the same borrowed declaration view and `g.names`. Physical `Fact.type`/cell/ABI comes through the existing route;
a separate source fact retains the original receiving root, primitive description and qualifier-chain order. Model/default
and language-reference payloads are not evaluated. A service uninit pointer locates the existing cell without reading its unprovided value.

The generated projection retains literal35 rows ×15 columns of source `primitive.description`. An exact source description
is not inferred from a machine type or C spelling alone; source aliases are not automatically unified. Positive
identity checks for all33 cell rows passed in private L2 native/forced with root0/1. This checks source interface,
not physical storage for those33 types. Qualifiers are retained; unproved references/Array remain UNKNOWN.

Common `lmx_implements_source_interface` owns one operation: `require_root`, shared `drain`, then `resolve_close`
with `published=0` and scratch closure. It publishes no permission, ready receiving map or persistent proof, and runs
neither candidate, converter nor `test`. Direct `@: p Model Value` uses this interface check for known Model/Value;
a proven missing required field refuses. UNKNOWN does not become YES. The declaration itself stays raw
with Model/default: an interface check allocates no typed storage and does not replace future runtime admission/test.
Bounded code/docs gates393 PASS; general typed storage/runtime admission and full M11/M13/M14 remain OPEN.

In WIP394 SourceFact separately reads proven scalar-pool/companion metadata before the existing `Graph.kind=0` fallback
for Foreign. Physical kind/type/cell are not replaced by a source row or ABI pointer; plain validated source evidence can
give YES, while unproved or qualified evidence stays UNKNOWN. This does not add general Foreign runtime support to old Graph.kind.

In slice 373 `lmx_graph_resolve_binding` returns the selected value and its working row in one search.
Classification and the value reader use that shared selection with the existing priority of formals, own places
and data methods. A retained deferred Frame is not exposed as an ordinary Structure or callable; the reader preserves
its refusal5 until a working write. An outer same-named place does not replace an already selected nearer binding.

<a id="names"></a>
## 4. Identifier strings (norm)

One spelling is one string in the process: the bytes of an interned spelling lie in the `text` region of the arena that
owns the string table and are never moved or released before the process ends. **The string state** -- the process's
string table (decision: one per process, like today's `lmx_ids`, but holding strings only) and its lookup index by bytes
-- is process state, like the address → name table and the region index (§1 item 5), not a temporary traversal table: it
exists for the whole process and is needed only at the input boundary. Interning -- the only operation that compares
bytes -- runs at the input boundaries: P0 parsing (every atom and head receives the pointer to its string together with
the token's bytes), unit loading (the unit's strings are already interned by the translator -- the emitted code carries
their table and turns it into process addresses once at load), `sys\fromLmx`, attaching regions of another process (§8). From
then on pointers everywhere: comparing identifiers is comparing addresses of strings in the arena (§1 item 2); `sys\toLmx`
prints the bytes by pointer. An exact identifier in backquotes is the same string as its value without the quotes
([grammar §§3.4.2–3.4.3](LMX_grammar.en.md)). User string values are not identifiers and are not interned. There is no
numeric code of a spelling, an operator or a receiver: the author's decision of 2026-11-07 about the code is replaced by
his decisions of 2026-11-08, and the book's paragraphs are updated as superseded (Codex's confirmation of 2026-11-08, no
separate ACK of the author). The former "exactly two tables" refers to names -- address → name and spelling → string
address at the input boundary -- and not to temporary traversal tables (§5.2).

<a id="tables"></a>
## 5. Tables

### 5.1 Address → name (norm: "the name is learnt from the address->name table")

One table per arena: rows `{ address, name }`, where `address` is the address **of the named primitive or Lmx itself** (the
author's norm of 17:22Z: the address of a primitive gives its type, name and value; an Lmx likewise; Codex, review 2 -- not
the slot's address, not an "occurrence", not a key "owner + number") and `name` a pointer to an interned string.
Operations: `name_of(address)` (bisection by address in the ordered table or an index by regions -- decision),
`named_field(lmx, name)` -- the slot of the Lmx whose content (the address of a primitive or an Lmx; for a place without a
value -- the record of T inside the record `uninit:T`, formerly the cell of T behind the `uninit:T` pointer) is named `name`: a walk over the Lmx's slots with one
`name_of` per slot and pointer comparison. A place's cell is named from construction, and the first assignment changes
nothing in the table (§3.2). The table is filled at construction (the names of declarations), at `merge`/copying (the
copy of a named address gets a row with the same name pointer), at `sys\fromLmx`; the rows of dead addresses are removed by
collection. Uniqueness follows the book ([names and paths](LMX_semantics.en.md#fields); the author's decisions of
2026-11-11): in a Structure as **data** every declaring form of its root level is an occurrence of the name; a sole
occurrence is addressed by the bare name, and `named_field` over it is unambiguous, while with two or more the bare
path is an error and an index selects the occurrence: `s\[N]field` with zero-based `N` is the Nth occurrence of that
name in field order, and `named_field(lmx, name, N)` counts occurrences in field order. A repeated declaration in data
neither replaces the former one nor writes into it: every occurrence is its own Lmx or cell with its own table row. In
**code** a repeated declaration by a receiver creates no second field -- it is a type check with an assignment into the
same place --, and a structural form there is a call of its head. This paragraph used to say otherwise: data never has
several same-named fields, and repeated definitions of one head are allowed in code. The clean graph executes the rule
of occurrences since slice 355: a name with two or more occurrences answers nothing without an index, and a path with
the index selects the occurrence; in a path, a form whose head is the name of a place of the same level is not yet
counted as an occurrence (sub-steps 5а and 5д of [section M11 of the plan](../next_core_tasks_v3.md#m11)).
The name table does not change the semantics of repeated
declarations or its narrow pause (REPEATED-DECL-OTHER-KINDS). This is the only structure of names; there is no
`LmxSourceName (key, port) → code`, no "place tables", no ordinal numbers of names.

### 5.2 Service tables for concrete work

Name tables, typed-arena ranges, canonical strings, and necessary copy maps retain their existing
responsibilities. Namespace and local places belong to a call; temporary construction and copying
tables belong to that operation and are released on its exits. No frame-publication tables,
shared-cache coherence, or former physical-slot requirements for S[n] are needed. Removing a check
includes its tables and fact transfers.

Resolve known names and requirements through common builder code during clean-graph construction.
Do not prepare separate runtime tables for hypothetical dynamic behavior. Explicit sys\check,
sys\checkL3, and sys\translate use the necessary parts of the working builder, not a second implementation.
Clean-graph checking executes neither user initializers nor test.
[Single task](../next_core_tasks_v3.md#graph-tools).

<a id="interpreter"></a>
## 6. The interpreter

<a id="direct-access-cache"></a>
Call-local places are independent of the source graph. A direct path or dereference uses the actually
addressed cell. A separate shared cache and load-dirty are cancelled; optimization preserves sequential
observable behavior. [Norm](LMX_semantics.en.md#call-frame-20261115).

### 6.1 Traversal

Executing a body is a walk over the Lmx of statements in field order. A statement is an Lmx (§3.3). The head of a named
Frame `head: a b` is its name (`name_of`: the row of the address → name table), its fields from 0 are the arguments; the
head's role is told by the address of its canonical string: a language word (`if`/`while`/`return`/…), a receiver (`fn`,
`int`, `merge`, `@`, …) or a name, resolved in the current traversal's namespace as it stands at this field, while the
places and Structures of the root answer by the registry of data above and below their line (§3.5, §5.2). A name answering
a function (the Structure F the receiver `fn`/`sub` created, §3.4), applied with arguments → a
call ([L2 §11](L2_spec_en.md#call)); a data place in a value position → a read.
slice 372 has no former root declaration/reach route: a named head in code is resolved against live data
and calls the selected method or launches an ordinary Structure, directly or through a reference place.
An unresolved head or an inapplicable form is refused when execution reaches the form; a form with a colon does not
assign a value into a place. Under the norm, the root of a unit is launched as a Structure over itself: a form is read in both roles,
declares in data and calls its head in code (a callable by a method call, an ordinary
Structure by a launch by name: `S()` is `call(S, S)`, `S(D)` is `call(D, S)`), and a structural form that execution has
reached is an error when its head names neither a callable nor a Structure, while declarations of Structures are written
in data (the author's answer to P7, [book](LMX_semantics.en.md#data-code-roles); the decision on launching by name --
[journal](../LMX_blog/2026-11-11.md#structure-call-by-name); the executor's reading --
[answers](../LMX_blog/q/fable-self-answers-20261110.md), Р6, Р7 and Р21; step 5 of
[section M11 of the plan](../next_core_tasks_v3.md#m11), the launch by name in the root of a unit and in a Structure over itself is its sub-step 5г).
Separately represented expressions keep their general form: an operation is an unnamed Lmx (the operator word and the operands, an operation
written as a Frame included, §3.3), a path, `:=`. A bare atom does not call ([READ.ME](../READ.ME)); an ordinary
Structure is executed by the receiver `call` or, in code, by a launch by name -- `S()`, `S(D)`; slice 372 extends shared
named-head dispatch to the root and a self launch. Root numeric/reference publication and direct path-head calls remain open.
By the author's decision of 2026-11-16 the written forms of a standalone written anonymous Structure in code are executed
in place, in the current activation ([semantics](LMX_semantics.en.md#data-code-roles)); the clean graph of slice 372 still
keeps it a value and does not execute its written forms -- the migration is open ([M10](../next_core_tasks_v3.md#m10),
the decisions of 2026-11-16, item 4). Control bodies execute under the explicit contract of their receiving expression.
An expression `a op b` is
three fields; the operands are evaluated recursively: a number primitive -- the value of the cell of its type, a nested
Lmx -- the result of its traversal, a name -- reading the cell of the place found, by its type (an `uninit:T` value -- by
the general admission, §3.2). No pre-translation of a body into operation frames: today's `LMX_WALK_OP_*`
frames and `LmxOp` are a second tree, removed by §9 (K03 of plan v3).

### 6.2 Roles by pointers

The language words are interned by the kernel first at process start (`fn`, `fm`, `sub`, `if`, `else`, `while`, `for`,
`until`, `return`, `break`, `continue`, `throw`, `catch`, `merge`, `implements`, `convert`, `interpreter`, `adopt`,
`independent`, `call`, `const`, `immutable`, `data`, `code`, `node`, `int`, `char`, `size_t`, `unsigned`, `ulong`, `void`, the
operators `+ - * / % = != < <= > >= && || ! & | ^ ~ << >> := \ @ [] ()`) and are available to the executors as constant
pointers (`lmx_word_if`, …): these constants are the addresses of the same strings of the `text` region, not separate
codes; service operators and receivers have neither numeric codes nor a special representation (the author, 18:18Z) --
`for`, `=`, `**` in the graph are word primitives with the addresses of their strings, and both consumers, the translator
and the interpreter, recognize them alike, by comparing the address. "Is this the word `if`" is a comparison of the
field's pointer with the constant; so is the list of the language's receivers (`lmx_graph_language_receiver`): the same
canonical strings, interned once into the graph state, and a comparison of addresses, with no byte comparison of an
already canonical word (Codex review of 332). A user's name in a word field (§3.5) is looked up in the book's order by pointer
comparison: the local binding of the current activation, the inherited dynamic input along the chain of activations, then
the lexical fallback by `parent` (`named_field` over the slots of a known Structure -- the selected `data`, the callable's
formals, own fields); not found -- the implicit throw by the book. Since slice 354 the list of the language words above holds `data` and
`code` instead of the former `var` and `body` (the author's decision of 2026-11-11,
[book](LMX_semantics.en.md#ordinary-var); step 4 of [section M11 of the plan](../next_core_tasks_v3.md#m11)).

### 6.3 Activation

A frame holds local values, namespace, and control for its call. Root data declarations map to inputs;
root code declarations absent from the input places then supply remaining locals. Preparation visits
neither nested branches nor graph references. Ready values use ordinary copying; computed declarations
are not executed early. uninit:T retains absence of a value.

@x addresses this call's local cell. @(data\x) retains a ready source place's address;
for a computed declaration, it addresses its record: an explicit path executes nothing.
For a computed input, @x obtains the value and the ordinary local cell's address. Use the existing
result place without an additional cell for @. Do not merge the local and source places
to preserve the former stable-cell model. Local-place pointers follow ordinary lifetime rules;
introduce no speculative escaped-local infrastructure. Recursive/repeated calls receive other local places.
Return and nested calls neither publish these places nor reload suspended callers' locals.

Mandatory copying of executable code at entry is withdrawn, including the former copy of only
the corresponding C function's code. Selected local values/descriptions remain independent;
binding uses hidden arguments without an environment copy. Methods and ordinary Structures share
compilation without data=code; distinct actual supplies produce distinct C signatures.
Known native calls known native directly in C. Graph writes do not clear native: updating it requires
explicit compilation and an endturn boundary (§6.5–7). Before that boundary the time at which
executable graph changes take effect is unspecified.

Slices through400 implemented working rows with loaded/dirty and publication: that previous mechanism
must be simplified while retaining necessary typed storage and the ordinary stack/GC. Those functions
do not establish the new model. [M14](../next_core_tasks_v3.md#native-structures) lists concrete removal sites.

### 6.4 Copying, merge, attaching

`merge`/a copy build a new Lmx with one source → copy address map (a service table for the duration of the operation):
`lmx` cells and primitives (an indirect place is copied as a cell of T and an `uninit:T` pointer onto the copy; the
contents of T and the indirect shape are preserved; words are copied as cells with the same string pointer) are copied into the regions of
their types in the receiving arena, slots are rewritten by the map, `parent` onto the copies, shared targets and cycles
are kept ([L2 §13](L2_spec_en.md#copy-merge)); the rows of the name table are copied with the same name pointer for the
copies' addresses; interned strings are shared by the process, nothing to copy. Attaching the regions of another arena of
the same process touches neither cells nor names; attaching from another process (mail between processes, §8) passes
through a `sys\fromLmx`-like interning boundary. `independent: immutable` follows the book.

Operands of `merge` are ordinary expressions with their general meaning (the author, 2026-11-08,
[journal](../LMX_blog/2026-11-08.md)): a head naming a function is applied once and its result is the operand, and a
model field of the same name never intercepts that call (`f(3)` and `f: 3` are one graph). A Frame whose head is no
function declares a Structure in data by the norm of 2026-11-11 and in code calls its head -- launches an ordinary
Structure (an error if the head names neither a callable nor a Structure); a launch form of a Structure at a place where
a value is needed (an operand of an expression, an actual argument of a call, an initial value, an operand of `merge`)
is an error: a launch has no result (the author's decisions of 2026-11-11 --
[the roles `data` and `code`](../LMX_blog/2026-11-11.md#data-code-roles) and
[launching by name](../LMX_blog/2026-11-11.md#structure-call-by-name); the executor's reading --
[answers](../LMX_blog/q/fable-self-answers-20261110.md), Р22, item 3; Р25, item 4). The working frontend reads such a
form as it did before the decision of 2026-11-11 -- until step 8 of [section M11 of the plan](../next_core_tasks_v3.md#m11); the state of
the clean graph is by [slice 356](../steps/witnesses/callable-data-launch-by-name-20261111/notes.md): it executes a launch form in
the code of a method and in code over given data, while in the root of a unit a launch form in the place of an operand
answers 5 (the fixture `struct_launch_operand`: `S: (int: k 1)`, `int: r S()`).
One composition serves every operand, whatever made it (slice 334; Codex, review of
333: no special merge of functions): a slot whose value is a Structure that later operands give again as Structures is
composed by the same level of `merge` through the same map, recursively (`lmx_graph_merge_level`), every field read by
its value (`lmx_graph_field_value`) -- nested parts of data (`merge_nested_part`: the part `P` gets the new field `v`),
descriptions written as code with a field `name` (`merge_code_descriptions`: `d2` without a body), functions of the
namespace (`merge_callable`, `fn_new_name`) --, with no classification by origin or by the statements a part holds; a
word place (`return`) takes the later word, and the slot keeps the model's form (a named reference refers to the
composition); for `f2` without a body the result keeps the copy of `f1`'s body and gets the signature of both:
`fn: g merge(f1, f2)` gives `g` with the formals `a`, `b` and the body of `f1` (`fn_new_name`; `descriptor_merge`: the
descriptor's default `b` 7). Every operand root maps to the result in the
one map, and a field of a later operand named like a place of the result maps to that place (its value and its cell),
so a reference to it reaches the result's place; a copied Structure's parent becomes the copy of its parent. A needed
lexical ancestor — one a copied name resolves through — is copied as an ordinary Lmx through the same map, whole, with
its fields, references and cycles, up to parent 0: it is not trimmed to the names met, and this is no copy of the whole
arena but the necessary reachable closure. A result with no written name or callable needs no ancestor and has parent 0
(no lexical parent, not an arena-root object); the source's mutable ancestor is never mixed in, and the place of
execution never gives one. The result of one operand is the copy of its root and keeps its name by §5.1. What a traversal
holds apart from the graph are its tables and their roots (§5.2): an F the program holds by a reference of the graph
stays a value and is copied as one; the copy holds no binding made by another traversal, and a new traversal builds its
tables from the graph it reaches -- no context is ruled out by the current resolver. The function `fn: g merge(f1)`
creates from the copy is a new declaration: its `parent` is the Frame of the application, and the free names of its body
resolve from there by the general rule of the chosen method and node (the book :110, :784; the priority of dynamic inputs
:829-833) -- `merge_recursion`: the name `f1` in the copied body is the root's function `f1`; one activation of `g`,
three of `f1`; the copy, its body and its references keep their copied chains (the book :1205-1207), and no explicit
reference is redirected to a source. A new place for a
Structure or callable that already has a name is a new named reference (a `ref` cell, §2.2)
to the same instance ([book :441](LMX_semantics.en.md#resolved-head-consumption), `@: name Model`): the reference has
its own address and name, the target's name does not change; a call, a path, a field write and a `merge` operand
through the reference take its target ([book :454](LMX_semantics.en.md#ordinary-var),
[:1237](LMX_semantics.en.md#factory-reference-result)), and the copy of a reference points at the copy of its target
through the same map. The name of a function created from a composition is the name argument of the receiver
(`fn: new_name merge(f1, f2)`), not a field and not the operands' names (§3.4). The implemented subset and its open
parts: the status above (graph73).

**Reading a copied declaration, slice383.** Queries and consumption share
`resolve_binding_context`; a query does not construct F because the binder needs that same search while creating a receiver.
`binding_source_read`/`binding_read` and the atom reader permit preparation of a reached owner during an actual read
through existing `space_declarations`/evaluate0. Preparing the block preserves the classification of sibling written
methods before later computed actuals; a computed producer is not run early. The common path
retains exact scope/source/parent, including the enclosing `node`, and the existing order of place resolution/admission.
Failures travel through a status local to this read; malformed constructor5 does not become missing3,
and no shared error latch is added to Space or the frame. Merge and `fn_data` code are unchanged; foreign bindings are not copied.

A raw declaration in a copy creates a new F from its copied arguments. A held F is copied
with its current parts and aliases as an ordinary Structure; a subsequent explicit `fn` creates a new F and new own data.
Pure queries neither replace this with consumption nor classify an ordinary descriptor as callable.
Runtime01/Graph01,10 pure cases,102 full AFTER checks of34 cases in three modes on the same binaries, mutation24 and native trace passed;
Whole bootstrap quick with genuine G1/G2, nine smoke cases each and fixedpoint13/verify781, and the G2 repeat (34 triple/33 negative AFTER checks/mutation24)
and normal render/docs check383 passed. Coverage is bounded to these classes; full M11, remaining5e/7/8, external/computed CodeBody,
native copy and M13/M14 remain OPEN.

### 6.5 Explicit compilation replaces change tracking

Graph writes are immediate and do not invalidate native. Remove the checks, code_uses, reverse links,
tables, transfers, and generator branches that exist for change tracking:
lmx_graph_invalidate_prepare/finish/invalidate and reset-only parts of lmx_code_* / reset_gen.
Keep common references, typed storage, and ordinary GC for their independent purposes.
Do not replace this mechanism with a dirty journal, versions, endturn hashing, or hidden recompilation.
An arbitrarily broken graph has no automatic repair guarantee.

`sys\compile(S)` explicitly builds/checks a clean graph without executing the program, translates
L1 → C, compiles/links machine code, registers successful results in call's tables, and returns diagnostics.
A failed result is not installed. Move working builder code into runtime only for a concrete operation;
do not create a second universal infrastructure in advance.
`sys\translate(S)` still returns L1 text and errors, not LMX or machine code.

<a id="endturn-receiver"></a>
`sys\endturn()` exits nested calls through already registered finally blocks in reverse order to the
ordinary turn boundary. Ordinary catch does not intercept it; there is no return to its call site or
continuation of that stack. It does not itself change running/success or complete a Message.
The next scheduled turn starts at its ordinary entry. Native and walker use the common cleanup/exit path.

Before the boundary, the time at which executable graph changes take effect is unspecified.
Only successful explicit compilation followed by endturn guarantees the prepared update at the next entry.
Endturn alone detects no changes, checks no graph, compiles nothing, and publishes no locals.
Old native frames and their finally blocks finish before their machine code is released.
[Norm](LMX_semantics.en.md#explicit-compilation), [plan](../next_core_tasks_v3.md#explicit-compilation-plan).

<a id="flush-receiver-contract"></a>
### 6.6 Removal of flush()

The flush receiver and local-frame publication are withdrawn by the 2026-11-15 decision. Remove
their supporting checks, tables, transfers, and generation. Message publication and exposing a
construction result are not local-frame write-back and retain their separate contracts.

<a id="native"></a>
## 7. Native

A native descriptor is an ordinary Structure containing actual-signature variants, binary module/entry
identifiers, and L1/C source paths. Call's tables are the primary store for descriptors of all compilable
Structures. Translation adds a missing ordinary native field to fn/sub/catch referencing that same
descriptor; other Structures receive no automatic field. Lmx's header contains no native.
Dynamic call selects a variant by target and actual signature.

A statically known native → native call is emitted directly in C with ordinary parameters and necessary
hidden binding arguments. Do not build an argument graph, universal Value wrappers, or lookup/trampolines
just to arrange such a call; explicitly requested data/code accesses remain.
Methods and ordinary Structures share emission, without data=code. A signature without code describes a call.
Do not create a speculative universal variant registry beyond tables required by actual calls.

If A directly calls B, recompiling B alone does not rewrite A's machine call.
Explicitly compile the common unit containing the necessary callers and callees. Do not introduce automatic
reverse-dependency tracking for edits. sys\native queries tables, sys\translate produces L1,
sys\compile runs the explicit full path in §6.5. Existing decl.native/made.native installations are the
former implementation to replace. The new model is OPEN; old receipts remain history.

<a id="codec"></a>
## 8. sys\toLmx and sys\fromLmx

`sys\toLmx(S)` saves selected S by ordinary graph rules: field order, null slots, shared links, cycles,
names, and typed-cell contents, including values written through uninit:T.
`sys\toLmx(Thread)` also saves all tables of its arena, including call/native descriptors.
The arena owns these tables, not R0's fields; R0 is a particular Thread.
External call tables are not silently added to an arbitrary S.

`sys\fromLmx` uses the common P0/builder, canonical strings, and address-link restoration.
After a restart on the same platform, restore the clean graph with ready ABI-compatible binaries
without retranslating the program. Persist module/entry identifiers and L1/C paths, not old-process
addresses. Reserved capacity need not persist: loading may set capacity=length.
The present diagnostic dump omits some null slots/unnamed cycles and is not yet this codec;
implementation is an explicit [M13](../next_core_tasks_v3.md#flat-lmx-descriptor) task.

<a id="audit"></a>
## 9. Audit of the existing parallel representations

| Today | What it is | Decision |
|---|---|---|
| `lmx_ids` (two tables "code → name", "name → code", unit codes `l2_ids[K]`, `LMX_ID_*`) | a numeric code as the identity of a spelling | replace by the string table (§4): identity is the string's address; word constants are the pointers of §6.2 |
| `LmxSourceName {key, port, code, place_spec, model_layout, place_uses, place_callable}` and `lmx_source_names` | the binding "occurrence + port → code" with side place maps | replace by the address → name table (§5.1); no place maps: a field is a slot |
| `lmx_walk_input_width` counts an ordinary Structure's interface by the positive ports of the name table; the emitter creates those rows (`lmx_source_name_set_at` by `m_dyn`) -- Codex's example | the interface is derived from a side table, not from the graph | a Structure's interface is its slots (`size`, named addresses); hidden inputs by §6.3 |
| Place tables `[m, SIZE_MAX, (code, type)…]` (`lmx_source_places_set`, the `PLACE` frame, `LmxCallPlaces`) | a static description of a procedure's places beside the graph | remove: a place is a slot; a name is a word resolved by the traversal (§3.5) |
| `LmxActivationBinding {code, storage, type, value}`, `lmx_activation_bind` | binding a name by code in an activation | remove: a formal/input is the address of a slot (§6.3), resolution is the traversal's table |
| A place without an initializer | no hidden initialized flag and no promotion of internal indirection to a language reference type | a record `uninit:T` with the cell of T; an assignment writes into that same T and changes the type of the record to T; `i` remains `int` (§3.2) |
| The walker's frames `LMX_WALK_OP_*` (66 operations), `LmxOp {code}`, `lmx_walk_frame_profiled`, numeric selectors in slots (`lmx_walk_store_size`), `OF`/`AT`/`PUT_OF` by slot numbers | a second tree of the body -- pre-translation into operations | remove (K03): a body is an Lmx of words, primitives and nested Lmx (§3.3, §6.1) |
| The binder's `l2_bn` name arrays, `lmx_call_bind_*` by codes | argument names as codes | by the string pointers in the word primitives of the named supply |
| `LmxPool.role/profile/sealed`, `LmxRange.links/slot_owner/holder/side_*` | side arrays of intervals and result profiles | the physical kinds are codes of records (§2.0, [L2 §3](L2_spec_en.md#value-record)); the role of a definition is its head word |
| `LmxImplEntry/LmxImplContract` (`implements` maps) | the address correspondence of a model and a candidate | data of the reception/traversal (§5.2): held for the duration of its operations, rebuilt by the next traversal |
| The arena's persistent `implements` map (`lmx_arena_impl`, `LmxImplEntry.exec_map`, `lmx_arena_impl_prune`) | prepared correspondences that outlive a traversal | data of the reception/traversal (§5.2): remove the persistent store, L2 §14 updated |
| `LmxCodeLink` / reset-only `lmx_code_*`, `reset_gen`, code_uses and invalidation | edit tracking to clear native | remove with supporting tables, transfers and generation; retain shared contexts/GC for independent purposes (§6.5) |
| The translator: `LmP0Text\code`, `l2_words`, `lm_compiler_text_same` by codes (the stopped WIP 308), the signature intern by codes | numeric codes in the translator | `LmP0Text` carries the interned string's pointer from parsing; comparisons are of pointers; the signature intern by pointers |
| The L1 translator (`l1_text_eq`, `l1_head_is`, …) | string comparison | the pointers of the same interned strings (one P0 for both translators) |
| The P0 parse tree as the translator's input (the frontend reads `LmP0Node/Frame/Field`), its arenas and indexes (`l2_pd`, `pdx`) | a separate form of the program for one consumer | the translator reads the clean Lmx graph (§1a, §7); P0 is inside the builder and is destroyed with the construction |
| The unit's graph builders in emitted code: `lmx_walk_frame_profiled` with operations, `lmx_source_name_set*`, `l2_ids_load`, place tables, `l2_sc*` | a generated second form of the program (operations, places, hidden interfaces) | remove; what remains is the generated initialization of the **clean** graph through the common constructor -- cells, slots, words, address → name, regions, `native` references (§1a) |

What stays: `Lmx.parent/length/storage`, call and capacity tables, the arena with its chunks and the interval index of ownership, Message/Thread/mail, `implements`
as a rule (its carrier is a service table of the reception), copying by one map, collection by reachability.

<a id="example"></a>
## 10. Worked frame example

Let source D contain x=1, and selected body C execute `x := 2` followed by `data\x := 9`.
This describes call(D,C), not a new header syntax.

| Point | Frame-local x | Source D\x |
| --- | --- | --- |
| After root-place preparation | 1 | 1 |
| After x := 2 | 2 | 1 |
| After data\x := 9 | 2 | 9 |
| After return | Frame ended | 9 |

`@x` addresses the second column; `@(data\x)` the third. Return does not copy 2 into D.
A new call gets a fresh namespace. No executable C snapshot is required at entry; mutation does not
clear native. Successful explicit compilation followed by endturn guarantees the update at the next
entry; before the boundary, executable edit timing is unspecified.

D[n] := p stores only void*: no former x requirement or slot fact is transferred. Named D\x := value
selects the current named place and checks its requirement during clean-graph construction where known.

<a id="transition"></a>
## 11. The transition plan (agreed with Codex in the second review)

The transition runs as the one existing L2/L3 pipeline (one writer/build), in slices, each recorded and checked by Codex;
code is written only in the agreed part. Checks go by the risk of a slice's change: the affected fixtures on native and the
interpreter, the short cycle of the whole chain ([READ.ME](../READ.ME)); the full checks -- the whole regression registry
(139 rows of `selfbuild/tests/full-suite.tsv`, native and forced, both roots), bootstrap quick and full, docs check -- at
the end of a stage and before every publication, not on every small slice. Earlier decisions and receipts remain history;
the earlier PASS results of the stopped slices prove nothing about the new implementation; the stopped mutants, bootstrap
and publication of 308 are not run; the task is closed neither by a document nor by one quick.

0. **The vertical slice -- first** (allowed by Codex, review 2; without another ACK). A minimal builder → one clean graph →
   both consumers, in this order: (a) a graph with an already initialized `int`, arithmetic and a repeated write
   (`int: x 5`, `x := x + 1`, `x := 7`); (b) the first assignment (`int: x`, `x := 5`, `x + 1`), including with an address taken
   in advance (`int: i`; `@i` kept without reading unwritten bytes; `i := 5` -- reading through the address gives 5; `i := 7`
   -- 7 at the same address; the author, 19:02Z), and separate clean traversals (a second traversal of the same graph with
   empty tables); (c) the example of §10 in full -- regions with `uninit:int`, slots, word primitives, the address → name
   table, the interpreter by §6, the translator by §7 with native for `take` and the generated initialization of the graph,
   `sys\toLmx` before and after, native/interpreter parity, the clean-traversal criterion (item 6b). The new path is built
   beside the old one under a separate tool entry and does not touch the old emission until it covers the fixture.
1. **Extending the graph by the registry's fixtures**, in groups by risk: expressions and `:=`, `merge` and copying, Array
   (slots, §3.1), `data` and `call: data code`, throws and `catch`, dynamic visibility, the named supply, q/z, AXBY
   -- every moved row passes native and forced on the new path.
2. **Removing the old carriers as coverage grows** (the map in item 7): `lmx_ids`/codes → strings; `LmxSourceName`, place
   tables, `LmxActivationBinding` → slots, words and the name table; `LMX_WALK_OP_*`/`LmxOp` → the Lmx of statements;
   profiles and side arrays → regions; the persistent `implements` map → reception data; `LmxCodeLink` → §6.5.
3. **The translator over the graph in full.** The frontend reads the unit's clean graph instead of the P0 tree; the parse
   tree and the builder's arenas are destroyed with the construction; the L1 translator compares the pointers of the same
   strings; the stopped WIP 308 is not used. The route (Codex 2026-11-09, route 331): the existing frontend F itself
   takes the clean graph, module by module, the machine module `lmx_schedule` first, with no second translator and no
   Lmx → P0 adapter; F reads the graph through the kernel, so it runs as a program linked with the runtime. Step 1 (slice
   336, [witness](../steps/witnesses/frontend-host-20261109/notes.md)): `build-frontend-host` builds the language root
   `tools/l2trans.lm2` -- the program's argv to the frontend's own command line `lm_compiler_cli_main`, the frontend's
   modules aggregated by L3 (`decl_write` 60, the text of the frontend's own root glue without its C `main`) -- linked
   with `rt/driver.o`; on the P0 path it gives the seed's L1 byte for byte (`lmx_schedule`, `lmx_graph_run` with its
   header, the program `graph_trans`). Step 2 (slice 338, [witness](../steps/witnesses/graph-machine-20261109/notes.md)):
   the first word `--graph` of the hosted F's command line selects the clean-graph input (`l2_frontend_graph.lm2`,
   `lm_compiler_graph_main`). The common builder -- now its own module `l2_graph_build.lm2`, shared with graph_trans --
   builds the unit's graph in an arena of the translation, the traversal of the root opens the translation's namespace
   (the Structure of every written `fn:` with its args, return and body parts), and the machine module is written from
   those Structures in F's form (the mark, the preamble of the C door's declarations, one prototype block, formals named
   `l2_p<f>_<j>_<name>`); the names of a body are resolved by the addresses of their spellings among the formals; any
   other form is refused where it stands, with no fallback to P0. `build-runtime ... HOSTED-FRONTEND` translates
   `lmx_schedule` so: the runtime's C differs from the previous one only inside `lmx_schedule_init` and
   `lmx_schedule_tick`; init/wait/tick/state through the C door (`tests/cdoor/schedule_machine.lm2`) answer 7 natively
   and walked, and the mutant `>=` -> `>` answers 89. Step 3 (slice 339,
   [witness](../steps/witnesses/hosted-chain-20261109/notes.md); Codex CODEX-OPUS-338-STEP3-REPLY: the ready F(n-1)
   builds, rt(n) is its result): the hosted F is the frontend of the chain. A generation translates the new frontend's
   objects and its runtime's kernel modules by the previous generation's hosted F -- `lmx_schedule` from its graph in
   every runtime; no runtime takes it from the P0 tree -- , links the new hosted F with that runtime last (its objects
   never with the previous runtime) and translates everything after (smoke, tool) by it; no standalone frontend is built.
   A frontend bundle -- `l2trans.exe`, `l1trans.exe`, `l2_libc.o` -- declares its launch in `launch.txt` (`0 entry 0
   --`, the driver words before the frontend's own words), which every recipe that runs a frontend reads
   (`bld_frontend_launch`), never the program's name. From the seed bundle fehost03 (made by the plain seed, linked with
   rt65) `bootstrap quick` built G1 and G2 with hosted frontends: their runtimes' C equals rt65's byte for byte, and G1
   and G2 differ only by link stamps (frontend, backend, tool; their L1 and C are the same bytes). Step 4 (slice 340,
   [witness](../steps/witnesses/clock-graph-20261109/notes.md)): `lmx_clock` is the second module every runtime
   translates from its graph. The graph path reads the forms it is written with: C door types `c.T` of formals and
   results, a function's own places `T: name [value]` and `@: name T [value]` (declared at its entry as
   `l2_q<k>_<name>`, written where they are written), `cast:`, calls of the C door and of the module's functions, an
   expression in parentheses as its one field. The actuals of a call and the operands of an operation are evaluated once
   each, in lexical order: a value evaluated before a later call is first kept in a local of its type (`l2_t<k>`; an
   actual of a function of the module takes its formal's type); a value with no C type in the graph -- a call of the C
   door, a field read through a path -- that would have to be kept is refused there, as the P0 path refuses such an
   actual of a C call. `lmx_clock` keeps no value: the C of the runtime rt67 differs from rt66's only in four functions
   of `lmx_clock` (their calls written directly), and its objects are the same bytes; through the C door
   (`tests/cdoor/clock_machine.lm2`) they answer 7, and the mutant `<` -> `<=` in `lmx_deadline_passed` answers 82.
   fehost03 reads none of these forms, so the chain starts from an intermediate generation, the bundle fehost07 (its
   objects by fehost03, linked with rt66): `bootstrap quick` from it built G1 and G2 with 0 failures, both translating
   `lmx_schedule` and `lmx_clock` from their graphs; their runtimes equal rt67 byte for byte, and G1 and G2 differ
   only by link stamps (frontend, backend, tool; their L1, C and objects are the same bytes). Step 5 (slice 342,
   [witness](../steps/witnesses/door-roles-20261109/notes.md)): `lmx_process_deadline` is the third module from the
   graph. The role of a C door name `c.X` at a Frame's head is its C declaration's (Codex,
   CODEX-OPUS-341-DOOR-HEAD-REPLY), not a colon, parentheses or the count of actuals: the graph path asks the
   frontend's existing import of the C door along the predef closure of the unit's root and releases the import before
   the module is written; a function of a prototype and an undeclared name are calls, a struct or fnptr type declares
   a place (such a place is still refused), `c.sizeof` is the C operator; a string literal is written as written.
   Slice 341 first lifted the backend's fixed 2048 bytes for the list of a header unit's types
   ([witness](../steps/witnesses/header-types-20261109/notes.md)). The C of the runtime rt68 differs from rt67's only in
   the three functions of `lmx_process_deadline`; through the C door (`tests/cdoor/deadline_machine.lm2`) they answer
   7, and the mutant of the clamp `INFINITE - 1` -> `- 2` answers 87. The chain starts from the intermediate bundle
   fehost09: `bootstrap quick` built G1 and G2 with 0 failures, their runtimes equal rt68 byte for byte, and G1 and G2
   differ only by link stamps. The next machine modules are the next step (`lmx_turn` already translates from its
   graph).
4. **Arena regions as the only storage.** `LmxPool/LmxChunk/LmxRange` → regions with the interval index; exact region sizes
   in the emission; attach/mark/revert/GC by §2.
5. **The full final checks:** the whole registry on both executors, bootstrap quick and full, checks, landing, docs render
   and check; item 6 in full.
6. **Acceptance of the transition.** (a) No comparison of identifier strings in any executing chain or any translator pass
   (an audit by grep for `memcmp/strcmp/strncmp` with a classification of the remainders by role), no `LmxSourceName`, place
   tables, `LmxOp`, numeric codes, persistent traversal maps, initialization marks outside regions, name-resolution results
   stored in the graph; (b) **the clean traversal criterion**, by language fixtures (`lmxtool`/L2, not a maintained
   Python/Perl runner): a program P (1) is built and executed -- the result R1 is compared with the expected E1, on native
   and on the interpreter each; (2) is changed during execution (a field write, `merge`, code built from data) and
   executed again -- the result R2 is compared with the expected result E2 of the **changed** program (not with R1),
   native and interpreter each for that state; (3) `sys\toLmx` of the changed graph, `sys\fromLmx` into a **second arena alive at
   the same time as the first**, execution there -- R3 = E2, and the next clean traversal of the first arena yields E2
   again; between traversals no live object of traversal tables and no P0 tree exist in the process (a release check on
   all exits, including a throw and a Thread stop); (c) `sys\toLmx` of a unit with a data Structure, the `data` part of a
   method (formerly `var`), a place without a value, a method, an expression and an Array matches the program in
   composition and order; (d) focused witnesses of explicit compilation/endturn without automatic native reset (§6.5); (e) native/interpreter parity on the whole registry; (f) the full self-build.
7. **The removal map of the prepared form** (what disappears at which stage): stage 2 -- `lmx_ids`, `l2_ids`, codes,
   `LmxSourceName`, place tables, `PLACE`, `LmxCallPlaces`, `LmxActivationBinding`, the `lmx_source_name_*_at` ports, the
   `LMX_WALK_OP_*` frames, `LmxOp`, numeric slot selectors, `l2_bn`, `LmxPool.role/profile`, the `LmxRange` side arrays,
   `LmxCodeLink`, the persistent `implements` map, `LmxChunk.value_contexts`; stage 3 -- `LmP0Text\code`, `l2_words`, the
   P0 tree as the frontend's input, the predef indexes `l2_pd`/`pdx`, the generated `l2_rw*` builders; stage 4 --
   `LmxPool/LmxChunk/LmxRange`.

**Decided by Codex's second review** (CODEX-FABLE-KERNEL-SPEC-REVIEW2-20261108T185727823Z-01): the name goes by the address
of the primitive or Lmx itself (§5.1); the earlier explanation of reading `uninit:T` is superseded by the author's latest
answer: internal addressing is transparent and `i` remains `int` (§3.2; since 2026-11-17 an assignment changes the type of the record of the place). `@: p` without an address -- `uninit:ref`, `Point: p` without a
value -- the ordinary declaration Lmx (§3.4); an Array -- an Lmx with slots and no special inline form (§3.1). The only
question of the second review -- what an `@i` taken before the first assignment addresses -- was **closed by the author at
19:02Z** (CODEX-FABLE-AUTHOR-UNINIT-POINTER-SAME-CELL-20261108T190254726Z-01): "T without initialization" is a pointer onto
that very cell of T, the cell's type does not change at the first assignment, `@i` before and after addresses one cell
(§1 item 4, §3.1, §3.2); there are no open questions to the author.
