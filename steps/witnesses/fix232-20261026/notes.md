# Driver bodies in ordinary L2

Date: 2026-10-26. Base main is
6b1ea256a68309f788f0bb9c5822c2b3b5654d47. Verified232 moves the remaining
driver bodies into ordinary L2. The source-only whole bootstrap completes
with exit0 and nine smoke rows pass. G1 actually builds G2; both start,
hash and replace the working tool. This remains the mixed bootstrap,
not source-closed S8.6.

## Maintained source and generated declarations

Candidate driver059206f9 combines the previous25 helpers and32 remaining
bodies, plus one cleanup wrapper:58 functions and13 machine exports.
L3 recipe6af7a0b7 prints declarations only: the same58 process-observation
cells,56 extern declarations and the old producer/driver prototypes.
The two fixed arrays are defined before a sequential generated-body import;
a body predef would hoist their use too early. No algorithm body is encoded
in those declaration strings, and no new state/context/registry is added.

The four previous variable-size stack buffers now share one allocation and
cleanup owner. Overflow/allocation failure reports a technical failure and
aborts;250 inherited checks and their predicates/order remain, with two
allocation-failure checks added. These are not additional Consumer rules.
There is no claim that all252 check sites or all58 bodies were executed.

Four function-pointer reads become declaration initializers at their old
read points, after the same guards and effects. Exact int-result casts
preserve the old C check ABI; typed temporary views preserve indexed native
field stores and pointer actuals. The two final dereference actuals use
ordinary grouping, not a new parser rule.

The existing general function-pointer local emitter now lowers initializer
temporaries before printing the declaration prefix. This small correction
remains in the transitional handwritten L1 frontend; it adds no helper,
syntax, type or ABI mechanism. The generated declaration line is no longer
interrupted by temporary declarations.

## Preserved refusals and diagnostic limits

Warm seed94689 completes0, executable89af34d7. It compiles the recipe with
explicit generated declarations from completed231; it does not execute the
new driver bodies. Initial source-only cold02/session98282 exits1 during
L2 translation at783:11, before driver C/runtime/smoke.

Diagnostic03 runs01–08 are targeted L2 investigation, not cold bootstrap.
Runs01–05 incorrectly start in an empty current directory, losing relative
l2src predefs. Unknown function-pointer result reports from those runs are
not ordinary-recipe failures. Runs06–08 use fresh explicit src contexts.
The last translates to L1/API with exit0, but that L1 still has the emitter
ordering defect and is not a successful C/runtime result.

Fresh cold04/session77999 runs13:43:05.4432032–13:48:09.9480344 UTC,
actual exit1. Driver L2 and L1 translation pass; production C rejects two
ungrouped dereference actuals folded into arena\\place. There is no04
runtime or smoke result. The exact two-line grouping patch is retained.
Completed cold04 frontend1748d42a is only an explicit preceding frontend.

## Current cold chain

Fresh cold05 receives73 selected source inputs, manifest474a87cf, no old
maintained driver or generated declaration seeds. Source-copy96419 and
manifest43233 complete0/73files/0failed; independent GNU verification is0.
Whole SHORT session16140 runs13:53:46.2414067–14:30:33.5529276 UTC,
actual terminal0,2207.311521 seconds, in a fresh runs directory.
The prelaunch free virtual memory is4338000 KiB, above838861 KiB.

New frontend713798ce actually translates final driver059206f9. Frontend
source8499f23e produces C80f62b4e; generated driver API0568f004 and full
L1c07c2818 precede runtime C3c116aaa. Production120a0981 and observed
dc776ee3 compile with exit0. API preserves the13 existing machine entry
names, pointer depths, arena arguments, callable types and result types.

The ordinary selection replaces the old helper source with the full
driver and retires the old maintained L1 driver. Its resulting inventory is
47runtime/compiler/support +0driver +1compiler ABI +8tools +17tests =73.
Generated L1/C remain intermediates, not maintained fallback bodies.

## Actual values and generations

All four existing native/forced root0/1 S8.1 logs retain:

```text
calls A1=41 A2=41 B1=42 A1=42 B1=43 A2=42
counts A1=42 A2=42 B1=43
after A1 count100 A1=101 A2=43
runtime r=142 p.y=42 p.x=1 p.pad=9 q.w=10
refusals C=30 Thin=33 Far=34 y=2
seven unused=3 called-plus1=8
```

Forced library commands retain --walk-methods. A native callee reached from
a walked root is not counted as walking its body. These existing witnesses
do not establish complete common used-interface admission.

G1fa2d4754 actually builds G221e0c53a. Its L108892c85/C4d8aa487 expected
pins are frozen before G2 executable exists, at14:14:11 UTC. Both generations
start, hash and replace the working tool. G1/G2 objecte8f1401a equality
is observed after completion, not predicted; working/G2 raw cmp is0.
Existing EXE-SAME returns1 with exit0. G2 language verification and independent
GNU checks confirm source73, expected2 and canonical5 with zero failed files.
All five final canonical inputs are raw-equal to their executed candidates
or the two explicit selection lists; no consumed stage file was normalized.
Source73 retains the inherited native_closure_values snapshot already
distinguished in225–231; equality of all73 inputs with canonical is not claimed.

Serial dependency-only readback from the actual component flags selects
13 frontend and40 runtime C headers, all under the cold stage's generated
headers. The64 regenerated count is not the number consumed. There is no
second C/object build or additional smoke campaign for this readback.

The exact source patch replays from the published231 base with GNU --fuzz=0,
then reproduces all five canonical hashes. Both retired source files are
absent; driver.list is intentionally an empty maintained selection. The
first replay used non-null deletion labels and left empty files; corrected
null-device labels and a fresh replay directory fix only patch metadata.
One initial read-only MM command had a shell parse error before GCC launch.
The first G2 verify command split a concatenated path into two PowerShell
array elements; it received a directory as its manifest, not a changed source.
Those preparation refusals are retained separately from successful results.

Packet copies retain the actual commands and failures. Their text formatting
may be LF-normalized; raw consumed stage records and source manifests remain
separately bound and unchanged.

Semantic and grammar generation completes0. Documentation checks confirm
35 paired semantic chapters,14 implements cases,27 grammar sections,44
verbatim excerpts and615 imports. The staged diff-check is0; generated
documentation has no unrelated delta. No new test runner or broad suite was added.

## Remaining work

Common used-interface narrowing and UNKNOWN handling, general immutable and
native effects, runtime-callable/Q49, the remaining compiler/backend/libc and
tooling closure, S8.6 and mail T01–T26 remain OPEN. Source-only233 prepares
248 frontend helpers and two incoming ABI edges; its source review is not
translation or execution. Its warm recipe seed starts only after232 terminal
and serial dependency readback, never beside the232 compiler.
