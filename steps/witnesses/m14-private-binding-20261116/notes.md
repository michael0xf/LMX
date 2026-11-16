# Slice408: field private and ready/deferred Graph binding

Bounded code gates and whole/bootstrap below passed; final docs/index and commit remain pending.
Goal ACTIVE. Work is directly on main above407/85881b5f and author17e8af6f.
The author's documentation package is preserved and is not committed again.

## Implementation and limits

One Graph selector returns the selected working row, borrowed ready Value or
written deferred description, and the field's private attribute. Selection
does not evaluate an initializer or box a native activation's input Value.
Capture copies the ready record before reallocating working rows, refreshes
only its current payload, and snapshots it through the existing Value producer.
Deferred descriptions use the existing mapped copier and remain lazy. A named
Structure keeps its non-place binding category.

Private belongs to the canonical CHILDREN cell in the existing SourceName
metadata, port SIZE_MAX. Activation work rows retain the selected bit. Dynamic
candidates are filtered before ambiguity; current, lexical and explicit reads
remain available. A lexical match reuses the live frame at the exact CODE/DATA
origin, including after a local assignment. Explicit actuals inherit the
receiving DATA field's attribute, rather than the argument Value's source.

The common receiving view preserves raw qualifier SOURCE. Construction folds
only private-only receiver chains into their real owning field. It neither
executes an RHS nor strips const/immutable/independent; their full runtime
lowering remains OPEN. Fresh P0 construction uses the existing parent setter;
injected shared values are not reparented by runtime construction.

Copying uses exact mapped source/target child cells, including concatenated
Fn DATA offsets. Merge takes the attribute of its canonical receiving provider,
without OR-ing late aliases or choosing by hash iteration. Ordinary copies and
GraphTool images carry the same field attribute. SourceName initialization,
cancel/drop, weak-key GC and attach retain their existing lifecycle.

SourceName adds binding_private after pending_next: this is an ABI change.
Exports: Graph86, SourceNames16, Copy31, Run71 and Walk189.
Native/Walk hidden-input parity remains OPEN. The next409 transfer is specified
in the main v3 through existing activation bindings, without private on Value
or a new registry. General reference-store context, the numerical exact-ABI
boxing bridge, native variants and the full M10/M11/M13/M14 remain OPEN.

## Artifacts and gates

Stage: build2/codex_fix250generationchain01/sol-m14-field-values-01.
Receipts: build2/codex_fix250generationchain01/runs/sol-m14-private-binding-20261116-01.

Frozen Source14:943 SHA
1298d28b815549cc911ab0d948d3a0f7795632195fba0dc2c92279d177e33506.
Normal manifest/stage-copy and both repository/stage verify:943/0 PASS.

Tool-private-03 normal build-self PASS:
8b6696b544c373fa9985ed050d880cfcfc521e7bbaaae2e16cff6f0f1166d3a4.
It uses the accepted Runtime-values-04 host. Its header bridge copied exactly
101 existing generated C headers from genuine407 G2 consumed-inputs through
normal manifest/stage-copy. Generated L1/C were never edited.

Runtime-private-09 normal build PASS:
C d199ab8dceec82cff588eeb088887509a86690b9ab02e6c81dbfd60fc771a7cc,
production f469b4bd7030dc71e1efe87220ddfa2bd66b8b73c00aa895936d147f9de413d7,
observe a9e4a51920eb629b9e5dc64577c0a0c31ae77d6dd2af52fc1d3e928e2d9edec0.
Private-focused02 PASS1/0, native/forced and root0/root1. Controls01 PASS8/0 in
the same four modes: full actual Values, call frames, typed Fn DATA/copy,
working scalars, name lifetime, exact scalar storage, execution GC roots and
the unchanged supported public-scalar alias control.

A final namespace selector refinement selects the physical eligible provider
before a namespace fallback and carries its attribute from the actual lexical
scope. Runtime-private-10 normal build PASS:
C 9f785bf7dd5083e158589bf87aa396a51504472130c1a92e103624b8b35bd637,
production 7ecddcba0199b442a9f14421f35091c6baf5900d8f9efe2c733451ca4fd3682f,
observe f3199d289bf752d64cc15619003ce89bd0073ad9d58c977d8dbbcb6a1dd0f32e.
Private-focused03 PASS1/0 in all four modes, including new case119: a private
and public field of the same spelling do not create dynamic ambiguity.

The assertion owner also checks results2110/2121, DATA2010/3010, source20,
live lexical721/source20, inherited private FREE40/local21/source20,
explicit actual3030/source10, and lazy42/calls0 then9/calls1 and5/calls1.
Metadata cases130–138 check canonical cells, Fn DATA offset1, a shared referent
in public/private fields, ordinary copy/sharing and both merge provider orders.

Graph-private-04 normal build PASS, SHA
7da4a56e8f2f28503a61097ffe91a89c2c60181c96499c2d1a740b4437b78347.
Graph private-case01 interpreter/native/forced PASS with independently derived
expected2110/2121/10/2010. Existing call_frame_local triple also PASS unchanged.

Whole01 bootstrap quick PASS on exactly Source14:943, label
boot-m14-private-binding-01: genuine G1 and actual G1-built G2 each pass9 smoke
rows. All14 normal same/exe-same comparisons pass: consumed snapshot, runtime
C/production/observe, tool L1/C, frontend L1/C, backend C, libc C/object and
normalized frontend/backend/tool images. Consumed snapshot382 SHA
7d6abc3c85a4577e4f9283b705ab7172e0d83ae6630a0f2f289225a2c16c1110.
Actual G2 frontend4c40c01fc2049ea756cf638ce942142d902c92102792ec00feb64e5637c5b102,
Tool8eacbaa717943c92cc801f2db678b80b44a2a1c36694eba5ff1d8b728a318629.

Source15:943 adds the differential frame0/FREE context witness and removes
the unreachable legacy reference-copy branch plus outdated comments. No
layout, signature, compiler or recipe changed after Source14. Source15 SHA
6c8ac20d05a4bb80305859b0e05578150eaa334c3d5014ad7fa82d91c4fe060a.
This later snapshot is not reported as the Source14 whole bootstrap.

Final Source16:943 SHA
445ff00fb86198e5b82c0aef7f1163b402c86039a2bcffa864abcf1a1eeec91c.
Docs01 failed at the final line-endings check on four mixed-EOL working files: inputs.list,
Graph, full-suite.tsv and build.lm2. They were normalized to LF without changing
their semantic/index content. Source16 updates the canonical manifest only;
the working/index code diff after normalization is empty. The successful
Runtime11/Targeted01/Graph05 gates above refer to the same code before this
LF normalization. Source16 is not claimed as another whole bootstrap.

Actual G2 Runtime-private-11 normal PASS:
C f145b983e8772ab6a991222c9bddfd5a5d54d172446007ffe70e19a4a522fadf,
production2452dca1a2061d78bedaa6233f92521e6ec66d9c1991c7cb81418d6932dd3480,
observe94c849851c34dce3f33889d40120d1cbe159455b570775d90fd03b8a6ee488ff.
Targeted01 PASS9/0, native/forced and root0/root1, on Runtime11 with actual G2.
The immutable actual has separate semantic Model/references/referent addresses
from its unchanged physical companion. Direct frame0 read preserves the full
record. FreeEcho receives no actuals; its first Collect clears the native
parent's input record and runs GC before the FREE read. The child's captured
record survives and returns exactly the selected context/payload. The parent
input is safely restored through existing ExecutionRoots; no work-row inspection
or separate callback/registry is added. Counter delta is exactly1.

Final actual G2 Graph-private-05 normal PASS, SHA
707c9cf48c5927642ab49c0a6bc6241769041177c4fe8cea45c68d1cd6a2667c.
Private-case02 and local02 both pass interpreter/native/forced on Runtime11.

## Sensitive mutant

Separate stage: build2/codex_fix250generationchain01/sol-m14-private-mutant-01.
Normal Source15 stage-copy943, then exactly one L2 line in select_binding's
native frame0 branch changes held[0] from input to0. The maintained root/stage
remain unmutated; mutant-run.diff records that single logical-line change.
Mutant Runtime01 normal build PASS:
C f2343c2c2e3ce1546f61558c53375a23ac89a27bd82d96f54ef8a89c88f2350d,
production1dcccc98f646a20b7f57f3b6bc1559a59fa34151c89fd4d7852b6c7d747da9fe,
observe1b1d52e4108536cee9b9a4e1178411327f425595978181a481c5c8a233fbc75b.
Normal Graph support build PASS67. Unchanged GV builds native and forced;
all four executions fail at native status155, owner exit144 instead of7.
This is the full-record frame0 differential against the unchanged immutable
companion, rather than an earlier parsing, GC or linking failure. The positive
Targeted01 passes the same witness on Runtime11 in all four modes.

## Preserved failed attempts

Runtime01–06 exposed L2 block fences and missing C actual annotations. Runtime07
stopped in the recipe because two expanded export arrays lacked their new
initializers; the maintained L2 recipe was corrected. Runtime08 exposed one
further L2 fence. Tool02 C compilation lacked a generated arena header after
the interrupted ABI regeneration; the exact accepted-header bridge above fixed
Tool03. Graph01/02 exposed the same nested C-actual annotation in Builder/Tool;
their maintained L2 sources were fixed, then Graph03/04 passed.

Private01 used a relative output directory and failed to read its generated
owner source. Its own artifacts were moved to the private receipts directory;
Private02 used the correct absolute output and passed. This was infrastructure
failure, not execution evidence. No old expected values were weakened.

Semantics/grammar sources were unchanged; author17e8af6f renders are retained.
Two foreign untracked WIP files remain untouched and must not enter the index.

## Documentation and index

Normal actual G2 Docs02 PASS35 paired/14 cases/27/44/615, links/opening,
LF28316, exit0. Docs01 had completed semantics/grammar/links before its final
EOL failure; it was not an unrun semantics phase. Working/cached diff-checks
PASS. Final indexed Docs03 is run after recording these facts; its terminal
result is recorded in the commit body, without another receipt-edit loop.
