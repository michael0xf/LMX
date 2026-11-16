# Slice407: full Value actuals in the common Graph call worker

Code gates PASS; final docs/index checks precede commit. Work directly on main
after b901f2bf. Goal ACTIVE; M10/M11/M13/M14 remain OPEN.
Author17e8af6f and both foreign WIP files are preserved.

## Result and limits

Ordinary, bound, single/whole and explicit Graph calls use the existing invoke
worker with complete already received Values. It scatters records into physical
DATA order; native refs address the final records' storage. Sparse holes stay
absent, a present-null reference still has storage, and native nargs is the
highest supplied slot plus one. Both source and final Values use ExecutionRoots.

The Graph frame consumes authoritative activation.values and creates independent
managed cells. A native LMX reference uses the existing GraphLmxRef cell inside
the frame; Graph_REF to GraphIntRef admission retains its physical adaptation.
SOURCE/Model/references/referent remain on the complete selected Value.
GraphTool still compiles actual expressions. Admission and scalar snapshot run
before the next actual. A known data group remains data; an expression runs once.

Physical INT admission uses the actual ABI and its proved physical scalar type,
rather than looking up the language word int. FOREIGN-to-NUMBER preserves
referent. Successful numeric local writes use the common context_copy and
refresh the inline number, clearing the old Model/references/referent.
The unused physical read_actual function/export is removed; its slot carries
read_actual_value. Run exports71, previous67 plus four adapters consumed by the
existing GraphTool/call paths. Frame/Work layouts and primitive entry ABI unchanged.

FREE/no-frame capture, general reference working-store context, numerical
Value-to-FOREIGN exact-ABI boxing, other callable producers/consumers, arbitrary
result descriptions, private/hidden inputs and native arena variants remain OPEN.
These results are not a claim of full M14 or of arbitrary primitive/profile support.

## Final snapshot and artifacts

Stage: build2/codex_fix250generationchain01/sol-m14-field-values-01.
Receipts: build2/codex_fix250generationchain01/runs/sol-m10-full-values-20261115-01.

Source05:940 canonical:
ab46bcdabe08c676ebc0ff0767e41558554331b7f66dffff31cf6d50b6f113d2.
Normal canonical02 equals source05 bytewise; repo/stage verify940/0 PASS.
Source04 and05 have identical maintained kernel/compiler code. Source05 removes
only the unaccepted exploratory profile probe from the proposed test inputs.

The genuine Source03 G2 tool is used for final normal commands:
47a63682bbe55e4a2a59e07981ade07a74a703dff64b0568d64cbb0d69b6b8c4.
Its build recipe71 is unchanged after Source03. Earlier Tool-values-02:
f5fb8ddea7dda5d8d01c42f1926e321d13a2469b0da213434fac2d043b4b7a41.

Runtime-values-04 normal PASS101, compiled by actual G2:
driver Cdfe6242962f10a942b64c6b9c27be266a853933b662152a64e29651b5e811d54,
productionae0567c8e6cf99ef3fa72125141ccd063d12982b9ce3c4872915c4adeb289c11,
observe96e645110bc172cba06306554f636c31cc93735b65edaf6c706a3695d83a9036.

Normal frontend-values-01 link reuses genuine G2 frontend/backend/libc inputs
(record/backend/libc manifest3 and stage-copy3 PASS), hosted with Runtime04:
9229fd9bfe771bd617d6e90a8322029383354078c1f81f63e0b448d68bca580e.
It is a normal rehost of the actual source-built G2, not a second object translation.

Hosted targeted06 PASS8/0, native/forced and root0/root1:
graph_call_values, graph_call_frames, graph_fn_data_typed, graph_scalar_working,
graph_name_lifetime, exact_scalar_storage, execution_gc_roots and the existing
supported-alias public_scalar_active with its original custom source table.
GV covers full native refs/projection, sparse/null, exact epsilon and all context,
immutable Echo/local Store, parsed Model/int-reference calls and explicit launch,
FOREIGN C-int context/referent and numeric-store context clearing, and fresh
pending-Value metadata through real GC in the next actual. Effects run once.
The input records/bytes and original graph values remain intact as asserted.

Graph-values-02 normal PASS101:
76f14c1b0437c9b76fc14a53ac2e12b782c100d1549cbb8bda337e1ba1d7b4ac.
Graph-local02 call_frame_local PASS interpreter/native/forced with unchanged expected.

## Genuine bootstrap and exact scope

Whole01 boot-m10-full-values-01 is exactly Source03:940:
cebe43644c47c74c5b9e9fc42d46b47f83c92bd928285d94fa086e5b29abbb9e.
G0 builds whole G1, actual G1 builds whole G2, both pass all9 smoke-kernel225 rows.
All14 normal same/exe-same checks PASS: consumed snapshot, runtime C/prod/observe,
tool L1/C, frontend L1/C, backend C, libc C/object and the three normalized images.
Consumed snapshot377:
ef5c4b65c46ef4714ca912b38342f5d3e358c75316cb3e69cde3f0e9972fa30e.
Actual G2 frontend98f007c46fb4f76ff66cbcb4185a4a71b2803452a1fa7f20fea86908b577184f.

The three late numeric body fixes followed that bootstrap. Compiler sources,
records, existing signatures and recipe71 are unchanged. Actual G2 rebuilt
Runtime04 and the final hosted targeted/Graph gates above accepted those fixes.
The Source03 whole is not reported as a whole bootstrap of Source05.

## GC sensitivity

The isolated sol-m10-full-values-mutant-01 changes exactly one line: the
eval_call_value pending Values span count becomes0U. Both source03 and final
source05 variants were built normally; main repository/stage were not mutated.
Final mutant-runtime02 PASS68:
driver C740bdf7dc00a3d7960ab6836ae75c660613a79a7b33ab73e2b1da593917fd1f4,
production8e908f07044979e53e45a1bcec33bac7a4d8ee64db13586a9e67f8b307e536a0,
observe7c5a8ce4a2112eb175459a5d6b9cd2ddf5fb0386e7a3e1d3fd104597e7a61b6f.
Mutant03 includes the final numeric181/182 checks. Both modes build successfully;
all four executions fail174/status4/made1/collected1/used0. Positive GV returns7
and made/collected/used are all1. The fresh payload and isolated semantic metadata
have no source-graph backup; mutable physical companion edges are cleared before GC.

GS now expects the unused old temporary GraphIntRef transport wrapper to be
reclaimed. Its target is the received reference Value; retaining that unused
wrapper is not the new transport contract. Functional80/two-effects, root
cleanup and final reclaim checks remain. The new sensitive GV replaces that
physical-wrapper lifetime oracle.

## Failed attempts and remaining profile boundary

All logs are retained. Precheck01 found a missing cutter;02–04 used stage instead
of stage/src and missed relative foreign predefs.05/06 PASS. Read-only GDB aided
that command-context diagnosis; no generated L1/C was edited.
Targeted01 used relative private-list paths; targeted02/03 found fixture cutters,
reserved profile/node locals and the old GS wrapper oracle, then the inline
NUMBER ABI guard. Values-only01–04 corrected foreign projections/typed C
intermediates;05 PASS on Runtime02. Source03 targeted04 and Graph-local01 PASS.
The first mutant suite lacked generated GraphBuild/parser imports in its fresh
stage; normal build-graph prepared them. Mutant02 then failed174 in all4 modes.

Numeric-before01 used an unsupported qualified primitive declaration in the
fixture; before02 fixes it and reproduces the real missing referent181 in all4
modes on Runtime03. Final Runtime04 passes both181 and182.
Targeted05 passes all seven supported rows but its extra exploratory int-to-C-double
profile probe is rejected by the frontend before execution. Existing ret_type_word
fixes native FT for int before active table lookup; native_type_text consults the
table only for foreign FT. No fixture-only change can prove that override.
The unaccepted probe/table are retained privately as unaccepted-int-profile*.lm2;
they are not maintained CI cases. The missing FE path and the distinction between
unit/frontend and runtime catalogs are recorded OPEN in the main v3.
The existing supported custom-alias control passes unchanged in targeted06.

## Documentation checkpoint

Semantic book, generated RU/EN and grammar sources are unchanged from the author's
accepted package. No render is repeated. The owned code/plan index is checked
with the normal Source03 G2 docs command before commit. Docs01 PASS on the
explicit14-file owned index:35 paired semantic chapters,14 implements cases,
both snapshots,27 paired grammar sections,44 verbatim excerpts,615 imports,
links/exact opening and LF28312. Working/cached diff-check PASS. After recording
this result docs-index01 also PASS with the same counts/LF28312. The main v3
status is then updated to the bounded result above; final docs-index02 precedes
commit. Both foreign WIP stay excluded.
