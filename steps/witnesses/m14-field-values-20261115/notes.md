# Slice403: complete results through cleanup and GC

Status: WIP; focused gates pass, genuine G1/G2 bootstrap is still running.
Baseline: `67d8f00e4cd5c624023eeed51f94a8bf09c55e2a`, directly on main.
Goal remains ACTIVE; the replacement M13/M14 model is not complete.

## Change and limits

The existing witness-based result destination now delegates to a physical
allocator selected by type, exact scalar ABI, profile and SOURCE. No synthetic
witness, result heap or lifetime registry was introduced.

GraphRun transports `LmxWalkValue` through calls, application, return, block
cleanup and explicit launches. Numeric entry points project from that result.
Return receives and saves a value before finally; cleanup can replace the
complete record. Existing execution spans retain pending results.

The GraphTool native emitter uses the same full records. It consumes a call's
record directly at return instead of losing its per-Value Model by reloading
the address. Successful delivery uses the common `lmx_call_result_value` after
cleanup and work_finish. The walker uses that delivery helper too. A managed
destination uses its regular writer; external typed storage uses its ABI.
Failure leaves the helper's caller context/output canaries unchanged.

Direct scalar WORD results resolve through the active primitive source binding.
The frontend's existing physical type formatter now shares a bare-name selector
with profile generation. A numeric kernel code requires exact agreement with
the selected native C spelling. ABI size is never a C typedef compatibility
proof; a custom int row spelled double remains FOREIGN. SOURCE identity and
Model permissions remain separate from physical transport.

An addressable NUMBER with a proven scalar ABI normalizes to one existing
FOREIGN cell with a Value companion. Repeated address requests reuse it.
Ordinary numeric pools and Graph.kind are unchanged. The INT reader accepts
such a cell only after exact physical ABI/companion proof.

The new return/GC test exposed a pre-existing missing root: live GraphSpace
rows owned callable values and receiver catalogs, but mark_execution omitted
them. The common mark now visits root, scope and value for the complete live
prior-chain, validating count/cap/rows. Closing the existing scope stops that
retention. No new state, layout, reverse table or all-names root was added.

This is a bounded result transport change. Computed field consumption, compound
type views and Model reception, full formal receiving, independent local places,
sequential visibility, removal of local publication, variable arrays and the
replacement native descriptor/explicit compilation model remain OPEN.
The scalar GraphTool image writer still refuses FOREIGN cells: the new scalar
Fn tests exercise real GraphRun Fn bodies under C-ABI assertion owners, not an
emitted scalar native method. Existing int/control Graph triples cover emission.

The later author package cancels code snapshots and native freshness tracking.
Value snapshots before finally and GC roots remain required. When native moves
to call-table variants, destination/reception ABI must come from the selected
compiled variant, rather than the return WORD of a graph changed afterwards.
Known static native calls must bypass generic dynamic Value packing.

## Artifacts

Stage: `build2/codex_fix250generationchain01/sol-m14-field-values-01`.
Receipts: `build2/codex_fix250generationchain01/runs/sol-m14-field-values-20261115-01`.
Source12:935 is canonical and verified in repository and stage:
`172735eb60603f0445369a7908750ab4a677a69a40717beab9bfbe69762fc1be`.
Exports: Graph82, Run67, WalkValues189, FrontendValues177; layouts unchanged.

Tool02 normal build:
`df2d4e35bb7b5f28a830bf0a6ab57b074a80062c63ffd9b9e0c77378009fcea3`.
Raw Frontend01 normal build:
`7c93c0689100d82a0ec4bbbe076e6057d727f12dd0072b6e69a32a52e5163c79`;
preserved as `frontend-field-01/l2trans-raw.exe`.
Normal hosted link with the ABI-compatible Runtime01 bridge:
`52de7ca5ff94d549c7f934c7cb9c8e0c54c987d211965046ebd9c94508c32e2f`.

Runtime05 normal build, 98 headers:

- driver C: `b29ccbd8a0ac120070a987e95ad9d601436d5f121664a6d88b02415340aa0517`.
- production: `1d0c75bcb20e7c4d180aea099e231899618f4d5fd680079d912346bed94a6f4e`.
- observed: `49914db77d9fc7dbd3c6e3438054c833f72fda60dce3ce00515935785ff9eb3e`.

Graph01 normal build:
`702f6a6408c159c68eabbb29be9d0d75eb23d2fb37183a38becd95145fce6ebe`.

## Focused verification

Private08 PASS SUITE2/0, native/forced and root0/root1:

- exact_scalar_storage: exact destination before native entry, double epsilon,
  actual SOURCE/Model/profile, complete delivery, dest0 NUMBER without a stack
  result pointer, pending bytes after source mutation, wrong ABI status3 and
  immutable numeric status4 with independent payload/context/output canaries.
- graph_scalar_working: real parsed GSHold/GSReplace/GSForwardHold/GSCInt/GSForward,
  double/f64 actual SOURCE/Model through finally and collection, replacement
  return, nested full-record forwarding and stable C-int result address.
  The callback opens a fresh namespace around sweep, forcing prior-scope roots.

Controls01 PASS SUITE3/0 in the same four modes: execution_gc_roots,
execution_gc_native and graph_fn_data_typed.

Graph finally_scope and fn_alias_call passed interpreter/native/forced.
call_named returned the same 12/12/17/13 values but its oracle had an obsolete
double pair of parentheses. Accepted402 reproduced that failure and its entire
interpreter log was byte-identical (Tool SAME1). Only that pair was corrected;
GRAPH-SAME1 for all three existing outputs passed without rebuilding binaries.

finally_error native/forced passed expected error exit1. Interpreter answer6
passed the driver's 82 checks when replaying the recorded argv with that actual
answer. Its full log equals accepted402 (SAME1). The first graph-check used
default interpreter answer1 and failed; graph-finally-error02 used a mistaken
CLI flag and is not acceptance. Correct replay is graph-finally-error03.

## Failed attempts retained

Runtime02 stopped on an unsupported raw C member actual before a later call;
the L2 source now computes storage first. Runtime03 reached unchanged Clock,
where a raw frontend lacks --graph; normal hosted linking resolved that route.
No generated L1/C source was hand-edited.

Private02 passed exact scalar tests but GraphScalar CC rejected ungrouped raw
struct members in three memcmp actuals. Source05 uses explicit pointer casts.
Private03/04 then exposed unheld C API Fn references across the old explicit GC;
the C assertion owner now retains its real references and checks restored roots.
Private05--07 reached GSHold, then returned5 with shape0/entry0. Interactive GDB
found return_value0 followed by cleanup launch_formals5. Namespace marking was
the missing dependency. Runtime04 and private07 preserve that negative baseline.
The attempted GDB argv/logging files are not successful test receipts.

## Remaining acceptance

Genuine whole01 G1/G2 quick bootstrap, fixed-point comparisons, actual G2 focused
checks, documentation generation/checks, final index verification, commits and
push remain pending. The external Astra explicit-compilation documentation is
being prepared in the same tree and must be preserved and synchronized.

## Source12 whole result and documentary commit

Whole01 is terminal PASS: genuine G1/G2 quick, smoke9/0 each, BOOTSTRAP0.
Actual G2 Tool SHA `3f7572978d61f7d3c53bf455901182c51de9e4751be0040eee2fdbd982547c43`.
Fixedpoint02 PASS30: frontend/tool L1/C, backend, executables, selected headers,
both complete consumed manifests364/0, source935/0 and Runtime05 C/prod/observe.
Fixedpoint01 had one invalid comparison against a nonexistent standalone
GCGraph.h; the other30 passed. Only that comparison input was removed.

The author's documentary package is committed/pushed on main as
`3d0ce661489f5d4ca9ac815f17b21766bf5b5859`, explicit index30.
Actual G2 docs-index01 PASS35/14/27/44/615, links/opening, LF28299; both diff
checks passed. Author renders35/14 and27/47 were already current and not repeated.
No code/test/manifest/current403 or either unrelated untracked file entered it.
The author confirmed the accepted M13/M14 package in the next user message.

## Additional physical delivery edge, still pending

Read-only review found NUMBER+proved scalar ABI was accepted by address
materialization but rejected by the common delivery writer for a same-ABI
FOREIGN destination. Source13 adds the real GSForward result before result_cell,
with successful full-context delivery and wrong-ABI/protected-cell canaries.
Private09 against Runtime05 builds n/f and all4 executions give110, the new
positive assertion. Source13 SHA
`4c0ea7633c7c8b6dadd953eafc3f8b3d0e2abe680a20c7d13daf40fbf3265081`.

Source14 factors the existing ABI proof/capture into Graph.scalar_box, used by
Run result_cell and delivery. Only the physical write uses temporary boxed;
the original NUMBER result/context remains authoritative. Wrong ABI still uses
the guarded writer; no new Model permission, state or table is added.
Graph83, Run67, Walk189. Graph imports the existing low-level Walk.h contract,
not WalkValues.h, keeping WalkValues→Graph.h→Walk.h acyclic.
Source14 SHA `d8a0083b37742594ec874e8f666638330ee40a2571f02f4efdb691d8b30e7055`.
Normal Tool03 PASS
`aed079b8814716847a34a8fc5af66ac64e2d1922ab9ee704ddc3bf46decee37b`.
Normal Runtime06 is running under unchanged actual G2 frontend; Source14 code
and stage are frozen. Runtime/focused/Graph checks and final code commit pending.

Runtime06 terminal normal PASS98 headers: driver C
`26453ffa3612b2e399cfec7695c2b142f123285489c7ef8827c05f6f23d7309d`,
prod `2c56f1f1f24daba3c29b19bb45eabfac8baa22722c9b03eeb0916c1111fa0c70`,
observe `895850c5e6c37c24249915ce6031821ea25787899b2e5766af592e3b608a7048`.
Private10 PASS2/0 with actual G2 frontend and Runtime06, n/f/root0/root1.
It retains all prior assertions and passes new successful delivery, wrong ABI3
and protected FOREIGN4 with unchanged bytes/companions/output/context/source.
Graph02 normal PASS
`a513823776a811a7b9153efb18cbc829ea05e884fe7722a40ba7de3ff99f2cfd`;
finally_scope and call_named pass interpreter/native/forced (g2-finally02/named02).

Source14 is canonical; repo/stage verify935/0 PASS. The final stateless capture
factor changed no frontend source: Source12 genuine G1/G2/fixedpoint30 is the
full-bootstrap foundation, while final Source14 has separate normal runtime,
negative regression and actual-G2 focused/Graph acceptance. No Source14 whole
bootstrap or complete M13/M14 implementation is claimed. Final index/docs and
code commit/push remain pending.

Final explicit owned index17 passed Tool03 docs-index02, exit0:
35 semantic pairs/14 implements/both snapshots;27 grammar pairs/44 verbatim
excerpts/615 imports;links/opening;LF28300 indexed tracked files. Working and
cached diff checks PASS. All code producers are terminal, Source14 remains
unchanged and verified935/0. Only receipt/status text was added after this gate.
The two unrelated untracked files retain their previously recorded hashes and
are excluded. This completed slice is committed/pushed directly on main; the
goal stays ACTIVE and the remaining M13/M14 implementation stays OPEN.
