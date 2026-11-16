# Slice406: unified Graph DATA and activation places

Code gates PASS; documentation/index checks precede commit. Goal remains ACTIVE. Work is directly on main;
the author's documentation commit17e8af6f is already present and is not duplicated.
Canonical Source16:939 is verified in repository and stage; author17e8af6f remains unchanged.

## Implementation

Graph fn/sub construct DATA from header declarations and written DATA through
the existing mapped copier. They emit no physical formal-args part and append
no CODE-local fields. Ordinary calls, bound calls and the six call/fncall forms
use the existing invoke worker after binding/admission. Missing DATA is CODE
itself. Unsupplied declarations do not become phantom native actuals.

Each activation owns its ready cells and selected computed descriptions.
Entry runs no program initializer. Defaults are lazy; actuals replace the
corresponding original declaration. CODE locals become visible when reached,
including when DATA equals CODE. A later repeated declaration still evaluates
and stores its RHS. Named Structure/callable lookup retains its separate role.

The existing copier's concrete same-arena description policy copies structural
expression cells, preserves pointer Value/context targets and borrows outside
parents. It does not copy a lexical environment or running CODE root. Shared
field and sequence-cell owner expansion is disabled only for this policy.
Whole graph copies retain their previous policy.

Graph work_flush and its export/calls/generated cleanup are removed. Local
writes change local cells; explicit paths use the existing graph writers.
The unused scalar-store deferred-working branch is removed as well. Scalar
local Values retain Model/SOURCE/context and validate their exact owned ABI.

Graph exports83 (method_args removed, names_drop added); Run exports67 (work_flush removed, place_supplied added).
GraphFrame/Work records changed; old runtime objects are incompatible.
WalkFrame's separate argument transport is unchanged.

## Artifacts and gates so far

Stage: build2/codex_fix250generationchain01/sol-m14-field-values-01.
Receipts: build2/codex_fix250generationchain01/runs/sol-m10-unified-data-20261115-01.
Actual compiler is the unchanged accepted G2 frontend.

Tool-frame-03 normal PASS:
6defabd7c95221da6c3dd7f7a2c75da386f6d02e430d7ade207812172e2f86ee.
Runtime-frame-04 normal PASS98:
driver C1b2d3321fa9b1a453529eea616512fb86c763c21bcf1d61057314d0e7e6a7f89,
production221b7d2b9704f455bd11c1f4c3e6eb954187e73bdf12c32a11d03d66149a3f83,
observe8991304a44b8f9a7bbc5f7fa4085f7d00378f635e8b63a9f6c570014972dac00.

Source06:938 focused03: graph_call_frames PASS native/forced, root0/root1.
Assertions cover parsed ordinary/nested actuals, six launch forms, unused
computed defaults, original-default suppression, no publication/no CODE append,
local/source distinction, sequential DATA=CODE and repeated declaration RHS.
Computed description mutation before first read returns9 then5 on the next
entry; the source declaration remains a declaration, with RHS5.

Graph-local-frame-07 interpreter/native/forced all execute successfully.
After correcting only expected rendering of the anonymous group/index and
the unchanged written function DATA, normal graph-same returns1 for each log.
Observed fields prove results8/12/42/21/10/10/99/10/12/5/2/8, counter5,
original supplied DATA.a1. These observations are explicit graph writes;
they do not depend on the canceled publication of bare root locals.

Runtime-frame-05 normal PASS98 includes the captured-callable readiness fix:
driver C7986a64335b9da28c24f4b6174c6032a3973bd83da3d41384b257de30ea2929c,
production787cece7d2697c72119d8ab636ef3667b27feca45db0624e9234319aa2a81f04,
observea290f3aeac7865ca1c51486fbbd80daa4363f3df2fd9c60dafae011cd188b3f2.
Focused04 repeats GraphCallFrames successfully on Runtime05. Typed/copy
legacy03 PASS1/0 and scalar01 PASS1/0, native/forced/root0/root1. Controls02
PASS2/0 in the same modes: exact_scalar_storage and execution_gc_roots.

Source10:938 is frozen:
1852d764ddb5e0c3b4b6ea8392f331b5c0237d02d51ac2716bf21186524eba4d.
The genuine quick bootstrap whole01, label boot-m10-unified-data-01, PASS:
actual G1 and actual G1-built G2 each pass all9 smoke-kernel225 rows. The two
generations' consumed snapshot369, runtime C/prod/observe, tool L1/C, frontend
L1/C, backend C and libc C/object match bytewise; frontend/backend/tool images
match after link-stamp normalization. All14 normal same/exe-same checks PASS.
Consumed snapshot SHA225c343b8d2b3ca2b2962e2a1438b60c22f0d6b6d935ad1bf1942d02356e4713.
Actual G2 frontend9c59b04a4817448190115dcb667ad6b3462af80ccd422132cfb17bd53c272ae7,
Tool409303f6fd8b3e48f917096067ebfb53428ee6db67c5dc9d22877140204f2d4f.

## Immutable scalar follow-up after bootstrap

Review identified a concrete edge in the supported FOREIGN DATA route. A ready
immutable Value correctly retains its source identity at entry/read. Bare
assignment must be able to replace the local binding without writing that
protected value. Runtime05 rejected it at place preflight. New GS case131
reproduces the refusal in all4 modes after its entry/identity assertions pass.

Source12:938 contains the bounded fix: prepare a mutable local destination
through the existing scalar arg-place helper after RHS evaluation, using a
temporary Value; commit the row only after admission/store succeeds. Ordinary
reads retain immutable identity. Explicit graph writes retain protection.
The helper now preserves full context for absent typed inputs as well, without
reading their uninitialized payload. No layouts, exports or call protocol change.
Normal Runtime-frame-06 passed on actual G2. The Source10 whole bootstrap
is not reported as a whole bootstrap of this later source snapshot.

## Final code gates

Source16:939 canonical:
a68df8c469898fb738f1e638c58e259b19f1f58a051d0be6585074f5073893a2.
Canonical manifest equals frozen Source16 bytewise; normal verify939/0 PASS in repository and stage.

Two additional corrections followed the scalar fix. A method's installed entry
belongs to its selected CODE part; explicit call(F) over the descriptor must
not jump directly to that method entry. Existing normal invoke and ordinary
native callbacks remain eligible without a DATA=CODE restriction. The CF route
probe requires the same descriptor-walk result, while normal invoke still uses
the entry. Old Runtime06 refuses the tagged wrong entry (case125) in all4 modes;
Runtime07 passes. The initial probe's guessed status5 was wrong: its saved
metadata executes normally and reaches the saved body; the confirmed baseline
is status0/one effect. The corrected callback accepts its valid0/1 actual forms
and distinguishes the mismatched descriptor owner, rather than weakening status.

The expanded scalar fixture exposed a later post-GC allocation failure105 in
one mode. Independent real-GC graph_name_lifetime deterministically finds that
Graph's address/name index retains a retired name (105 in all4 modes). The
existing source_names_drop retirement hook now also compacts matching Graph
records and rebuilds their existing hash index before reuse. It initializes no
state and allocates no memory; live and external-address names survive. The new
export is appended as Graph83; existing layouts/signatures are unchanged.

Tool-frame-04 normal PASS:
c521d00e11be682d39039d99bb042ee9f864643bc57e37c62d248ae1f3cb5277.
Runtime-frame-07 normal PASS98 on actual G2:
driver Cf0b8f6e156c50af595e3f7b7337e638ee6545e4d54ff4a092f15fb18ce0049a5,
productionf365837898409168fc7ad2fe3494ea9e26ce0f4f10ca9be518a33042fcc700af,
observe021d12b7aa928e264ea22607a6fffd7af0e08bca38008e46e7f66b21e459439e.

Targeted01 PASS6/0, native/forced/root0/root1: GraphCallFrames, typed/copy FD,
scalar/immutable GS, graph name lifetime, exact scalar storage and execution roots.
The final GS checks retain immutable identity on entry/read, prove local stores,
physical graph refusal4, absent ABI initialization without reading poison,
full SOURCE/Model/profile and the earlier pending/result/GC assertions.

Normal frontend-link frontend-frame-01 reuses the genuine G2 source-built
frontend/backend/libc inputs and links Runtime07. Reuse manifest3, stage-copy3
and link PASS; hosted frontend:
3b2c82c1df309c7e04b720f843e5254fe63286676ec67c8c169369d8d8fba2bd.
Hosted targeted02 repeats all6 rows successfully in all4 modes.
Graph-frame-03 normal PASS100:
dce33f715261a4ee92b36b7eae15d02a04b648e8119f5b27bfb0920e55de40d5.
Graph-local08 interpreter/native/forced PASS against the maintained expected file.

The genuine whole/fixed-point result remains exactly Source10, not a new whole
bootstrap of Source16. Final canonical verification passed; docs/index/commit/push follow these code gates.

## Failed attempts retained

Tool01 used a directory where build-self expects driver.o; L2/L1/CC succeeded,
LD failed. Runtime01 and prechecks02/03 found L2 cutters/C-field projections;
precheck04 passed. Runtime03 found the description snapshot out-field projection;
the explicit cast passed recorded GraphRun precheck05. Precheck06 passed after
the captured-callable/scalar-store changes. No generated L1/C was hand edited.

Focused01 used reserved parameter name test; focused02 corrected the fixture
and passed its then-current assertions. Legacy01 used canceled DATA append,
local publication and Fn-as-call-CODE assumptions. Focused03 retained typed/GC
checks: FD stopped at85; GS CC found three ungrouped raw C member actuals.
Legacy02 fixed those setup issues and exposed the real missing readiness bit
after runtime construction of F. GS125 retained an obsolete single-head-chunk
assumption; the fixture now isolates the anchor's actual current tail chunk.
Focused04's diagnostic print calls needed explicit C result casts; legacy03
then passed FD and reached GS128. The final reclaim proof now closes the
declaration namespace before the sweep: that namespace legitimately retained
older copied input-reference chunks. The strong single-anchor chunk assertion
and pending-span survival/reclaim assertions remain in scalar01.
Controls01 used the wrong machine entry/list kind; controls02 corrected only
the private list, with no maintained source or runtime change.
Scalar-protected-before01 found a fixture tail cutter; before02 corrected it
and reproduced the actual immutable-local refusal131 in all4 modes.
No failing expectation was converted into an accepted result.

Names-before01 found the reserved fixture variable `external`; before02 uses
`foreign_cell` and reproduces the stale retired name105 in all4 modes.
Descriptor-before01 used an incorrect guessed baseline5; corrected before02
reproduces the mismatched native-body refusal125 in all4 modes.

Graph-local01/02 mixed ordinary data declarations into executable root code;
03 hid observations in copied constructor DATA;04--06 still executed named
data forms at the root.07 uses an inert written group and an ordinary local
reference to it. All prior logs remain. The one-off debug build recompiles the
unchanged generated driver C with recorded compiler argv and O0/debug flags;
it is diagnostic, not a production gate or a new maintained runner.

## Documentation and index gate

Normal Tool-frame-04 docs01 PASS on the explicit24-file owned index:
35 paired semantic chapters,14 implements cases, both source snapshots,
27 paired grammar sections,44 verbatim source excerpts,615 imported files,
links/exact opening and LF28310. Semantic/grammar sources are unchanged;
the author's generated documentation in17e8af6f is preserved without rendering
again. Read-only final code review reports no new actionable findings.
Working and cached diff-check PASS. After recording this result, the final
indexed docs gate precedes commit/push. The two foreign untracked files are excluded.

## Still OPEN

This is the Graph executor portion of M10/M14. Full Value actual/native ABI,
all callable/catch producers and consumers including full constructor syntax, arbitrary result descriptions,
computed lexical/dynamic inputs, private and hidden args, direct known native
calls, arena call/native variants and explicit compilation/endturn remain OPEN.
Legacy edit tracking outside the removed Graph working publication also remains
until selected compiled-signature authority is safe. M8/M11/M13/M14 are not
marked complete by these tests.
