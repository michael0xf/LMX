# Retained compact-head paths: implementation verification

Status: verified limited slice. This removes repeated grammar adaptation for
compact indexed statement heads; it does not certify the complete common
resolved-path/value plan or all path consumers.

## Mechanism and limits

`L2HeadExpression` owns both the original P0 document and the common run
adapter's complete prepared `L2Path`, including its no-path verdict.
P0 decides the head's shape, not a test that its last byte is `]`.
The retained document still owns index-expression nodes and source spans.

`l2_path_prepared_view` allocates independent step storage and borrows the
owner's text and P0 spans. It transfers grammar counters, prefix boundaries,
flat-versus-linked form and source nodes together, while clearing every
previous root/step/leaf type, field map and semantic verdict. The destination
starts fresh; the owner must outlive it. This is not another parser, another
binding table or a second runtime graph.

`l2_array_place` and `l2_head_path_effect` now consume those views, then use
the existing common resolver in their source environments. Neither runs the
adapter again on the already prepared head. The effects consumer also drops
its separate last-byte recognizer. Binding and source provenance retain the
original P0 document until application cleanup; one disposer releases the
prepared storage, document and owner.

The free-name/capture scan consumes the retained head verdict too. Its root
and recorded index spans are traversed by the same `l2_scan_path` used for
ordinary operand runs; only subsequent independent operands get a fresh
ordinary scan. A cached no-path head scans its first node without retrying
the failed outer adaptation. This does not add a capture-specific resolver.

Body statements and operand Frames both use `l2_scan_head`: the former
previously bypassed the index spans and scanned only the head's root text.
The generic `l2_node_of_text` source-use query now includes each Frame's
retained head tree. Without that provenance, a real index read looked like
a forward-only input and native lowering emitted an undeclared value name
against its raw-reference-only signature. This repairs the common source
query, not a native-only guard or a special hidden-index rule.

Resolution is still repeated between phases. Other statement-call and
expression consumers still have result-transfer debts. Native/walker
names-prefix plus index-suffix lowering, field-after-index emission,
computed value roots, exact Array element requirement-instance provenance,
K07, ancestor coordinate projections and current-graph/native invalidation
remain open. No new refusal test replaces a positive obligation.

## Verified pins

| Input | SHA256 |
| --- | --- |
| `dev/l2src_sandbox/l2trans.lm1` | `b70a65a116e7dfccbfd97b2300703c6ec25e18b4d760ea95c52ede2def388fa6` |
| `dev/l2src_sandbox/l2_application.h.lm1` | `378859037156045492fbb7e01192170b5c90714e9e8e892c87fa2c4570a09d6b` |
| `tools/l2_path_prepared_test.c` | `0464150304b2edfa8923452ea23a14b866bbac0f5144d3d1f6eac3314aed4ec5` |
| `dev/l2src_sandbox/tests/unit_head_prepared_index.lm2` | `f56147a27de851ce5d7c3aaac5e02d8d33d5a538f33a80b83c5872213f986f0b` |
| `dev/l2src_sandbox/tests/unit_head_prepared_capture_index.lm2` | `95661232ee2a6dbe664333ec10f80a7dca4b931dfd86b35646fcb03c547783da` |
| `dev/l2src_sandbox/tests/unit_head_prepared_named_capture.lm2` | `9825ccf5cb72edc29f0c8605a464bb3f413953fdee88af58fa2975bb9a5df5e9` |
| `dev/l2src_sandbox/tests/unit_named_actual_head_index_free_refused.lm2` | `0437ecb75a861dbabac2c4fb745d04486dcb874b05b99da32ddd7c9a8de32f79` |

Canonical frontend blob: `273a0ec46a25950b8131b80205553fc3e37e2a92`.
After the preceding copy corpus and commit completed, the real harness was
updated byte-identically to the separately tested registration in ignored
`build/codex_head_prepared_harness_03.ps1` (SHA256
`4d1890eb4baaf36e9f405ebe68ff5d08841a2d673ecc2121f540940f1423503f`).
That artifact has the same repository root as the real script, copies the
test into the frozen source directory and adds four runtime modes for each
of three source witnesses, plus the negative's forced-method twin.
Actual `tools/l2_harness.ps1` has the same4d1890eb SHA256; this is now a
registered test set, not just an ignored diagnostic variant.

## Observed checks

The internal test includes the actual frozen generated frontend, with main
renamed. The current registered-focus snapshot passes85 checks, extending
the83-check `codex_path_prepared_test_02`: independent views;
preserved index spans and rebased locations; field names after an index;
flat/linked distinction; prefix-cut counter consistency; removal of poisoned
old root/type/map verdicts; malformed counter/capacity refusal; allocation
failure, unchanged owner, retry and balanced cleanup. Fault injection uses
the existing compiler allocator hook, not a new production switch.
The added two checks find an index's actual source node through the original
Frame and recover its original owner. Both fail against V4
(`codex_path_prepared_origin_baseline_01`:85 checks/two failures) and pass
on current V6. They distinguish the general provenance repair.

Its field-after-index effects check fails against the preceding V2 frontend
(`codex_path_prepared_effect_baseline_01`:83 checks/one failure), which still
had the effects consumer's last-byte guard. It passes from V3 onward.
This synthetic context has no collected binding, so the common
resolver conservatively reports an effect; it is not execution evidence for
the still-unimplemented field-after-index value path.

`unit_head_prepared_index` executes compact stores whose indices call
`choose`, including a linked second index. Actual reads must observe29,
the untouched neighbour11, and exactly two increments of the source
Counter. `codex_head_prepared_source_calls_02` passes normal and
`--walk-methods` translation, each with native and cleared-root dispatch:
four real driver runs,13/17 checks. The forced-method output retains only
native root m3; the actual methods walk.

A separate simple control stores11/22 and checks both actual cells.
An ignored generated-C mutant replaces only the retained prepared index span
with literal1U, leaving the original P0 expression tree unchanged. All four
runtime combinations then observe its deliberate wrong-cell result81.
Restoring the old consumer's re-adaptation of the original tree, with the
same mutation, produces7 in all four combinations. The outputs
`codex_head_prepared_source_control_01`,
`codex_head_prepared_source_mutant_01` and
`codex_head_prepared_source_reparse_control_01` distinguish retained-result
consumption in native and COUNT/EMIT walker from a hidden fallback reparse.
These are diagnostic C variants, not a production mode.

`unit_head_prepared_capture_index` stores29 through a namespace Array using
a hidden numeric index, preserving neighbour11. Its original source fails
on the preceding copy-focus frontend and V4 at `selected` (`this operand`).
Routing body heads through the common scan collected the input; the generic
provenance fix then corrected its forward-only classification. Current V6
`codex_head_prepared_capture_fixed_02` passes all four real execution modes,
13/17 driver checks; only root m3 retains native in forced-method output.
The intermediate variant01 failed gcc on undeclared `l2_p1_0`, not execution.
No such intermediate failure is counted as acceptance.

### Named payload and the one changed old diagnostic

V6 historical replay has one MSG change and no generated-L1/exit change:
`unit_named_actual_head_index_free_refused` now refuses put's unsupplied
hidden input b at its call14:30, rather than calling the index read10:24
an unresolved name before collecting that input. The existing negative still
refuses the same missing value. Its three-line comment and exact harness
needle are migrated; this is not recorded as an unchanged diagnostic.

The distinguishing positive `unit_head_prepared_named_capture` uses that
same `row[pick(b: 1U; a: b)]` expression, but an ordinary caller supplies
its own b=0. Both engines must write5 to row1, preserve row0=11/row2=33 and
return7. The actual named b=1 belongs only to pick, not to put's hidden b.
The old copy-focus frontend refuses this valid positive at its b read;
current `codex_head_prepared_named_capture_01` passes all four actual runtime
combinations,13/17 driver checks, only native root m3 in forced output.
This follows the existing free-input norm (semantics book/free-names), which
requires the caller's current value and closes required through-names before
emission. A free read cannot be rejected at definition merely because this
particular caller supplies nothing. The negative's added walker twin and
the existing duplicate-named-actual refusal remain separate controls.

An additional captured-Array counter probe remains RED. The previous
copy-focus frontend and V4 refuse `a dereference without a retained binding`;
current V6 refuses `unbound dynamic input choose`.
Sources/comparison logs remain in `codex_head_prepared_capture_array_red`,
`codex_head_capture_array_baseline_01` and
`codex_head_prepared_capture_array_after_scan_01` under build. This is an
open Array/capture obligation, not a passing witness or an unchanged
diagnostic. Full acceptance must classify every changed old row independently.

## Gate state

The120-fixture expanded focus produced124 targets/19 failures in V1, V2
and V3 (`codex_head_prepared_focus_01/02/03`). V2-to-V3 has zero
row changes, regressions, changed common FAIL notes or diagnostics. V1
against the complete root predecessor also has no regressed row or changed
common FAIL diagnostic: all19 failures already existed in that full corpus.
The3493 absent rows in a full-versus-focus comparison are coverage, not
deleted tests. Minimum free physical memory for focus03:4399 MiB.

`codex_head_prepared_kernel_01` passed306 targets/zero failures,
119 executed self-tests, L3 all11 suites/four type budgets. It used V2
frontend `7d421191…54fe3`, not this later effects change; do not relabel it
as V3 evidence. V3 kernel/L3 `codex_head_prepared_kernel_02` also passed306/0,
119 and all11/four; minimum free physical memory4424 MiB. Neither is evidence
for the subsequent V4 capture traversal. V4 kernel/L3
`codex_head_prepared_kernel_03` also passed306/0,119 and all11/four;
minimum free physical memory4411 MiB. Current V6
`codex_head_prepared_kernel_04` completed306/0,119 executed self-tests and
L3 all11/four, with observed kernel/L3 exits0/0; minimum free4684 MiB.

The separately registered V3 focus
`codex_head_prepared_registered_focus_01` completed129 targets/19 failures:
all five added rows pass, with zero changed old rows/FAIL notes/diagnostics
or removed rows. Minimum free physical memory4504 MiB. V4 registered focus
`codex_head_prepared_registered_focus_02` also completed129/19 with no
changed row/note/diagnostic or removed row; minimum free4348 MiB.
Current V6 registered focus `codex_head_prepared_registered_focus_03`
completed133/19: all four added numeric-capture rows pass, with zero changed
old rows/notes/diagnostics or removed rows. Minimum free physical memory4677
MiB. Together the two source witnesses have eight passing runtime rows;
the current internal test passes85 checks. The registered-focus04 extension completed140/19: four
new named-payload positives and all three selected negative controls pass,
zero changed old rows/FAIL notes/diagnostics or removed rows. Minimum free
physical memory5149 MiB. Real-harness full
`codex_head_prepared_full_01` started17:07:57Z after publication of
`ef8e95df03db0baffee9ebf7e5a8a6e73d1eb2ea`. The complete eight-input raw
pin list is retained in `build/codex_head_prepared_full_01.inputs.sha256`;
the staged frontend/header/internal-test hashes match this slice.
The full completed at17:54:29Z with3630 targets/1027 failures and observed
PowerShell exit1; the wrapper and both comparisons completed normally.
Against both COPY3616/1027 and ROOT3616/1027: zero regressions, fixed rows,
other state changes, changed common FAIL notes/diagnostics or removed rows.
All14 additions pass: the internal prepared-head test, three positive source
witnesses in four actual native/forced-method and normal/cleared-root modes,
and the free-input refusal's forced-method twin. Minimum free physical
memory3520 MiB. The whole L2 corpus remains RED on its1027 existing failures.

The input verifier confirms all8 INDEX/live raw pins and canonical blobs,
all7 copied raw inputs, and every113 frozen root-module/header blob against
the candidate tree. The four logical Windows modules are checked against
the real harness's exact `_win32.lm1` source selections. The harness itself
matches its start pin and INDEX; it is not claimed to have been copied into
the evidence tree. The newer K07 working sources were not part of this
frozen old-ABI runtime closure and are not included in the slice.

Historical V3 replay `codex_head_prepared_replay_01` reports SAME3573 versus
the root replay:3572 actual translations and one equally absent input row
(`unit_p50_missing_input`), not3573 executions. Its old `fable_u6_full_02`
input also retains the previously documented696-row coverage gap. It does
not cover new witnesses or replace a full gate. V6 replay02 completed
MSG1/SAME3572: the one diagnostic migration above, unchanged exits and L1
bytes for every replayed source. Its one missing input remains missing;
it is not an executed test or a proof of the later added source witnesses.
