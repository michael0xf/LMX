# R2 / M1: value of an actual before its receiving contract

Status: verified scoped increment, 2026-10-19. Kernel/L3 pass; the full L2
gate remains RED on inherited failures, with no new regressions. This is
not acceptance of the complete M1 or all-consumer path migration.

The EA source below is the frozen acceptance snapshot, saved in the index;
the running gate has its own staged copy. A subsequent walker-record WIP
(92c29e270c5d775cdae7feb43c0add3538c760b78f93cca7c779f58dead049cd)
is separate in the working file and is not covered by the EA gate.
The code commit of this increment takes EA from the index, not that later
working file. Do not attribute the EA results to the next WIP.

## Norm and cause

The current [normative argument-position rule](../docs/LMX_semantics.en.md#callables)
distinguishes a bare callable occurrence from an explicit call. Its receiving
contract admits the computed value; it must not turn a call back into its head.
The old nullary atom/Frame equivalence in the
[2026-09-30 proposal](callable-actual-projection-20260930.md) is superseded.
No new language choice was needed and no canonical specification was changed.

Fable's handed-off R2 Frame-head witness, and Codex's first deep extension,
preserved the old suppression of an explicit call. Their initial green results
and the old cfhead mutant are therefore not current normative proof.

## Implementation scope

- The existing transparent-grouping normalization now feeds one bare-reference
  extraction shared by callable actuals, held callable lookup and ordinary
  descriptor reception. A named call Frame is not a bare reference.
- Callable references retain the resolved path record through native emission;
  the second Frame-head text resolution is removed. Walker callable actuals
  normalize the same grouping before selecting the reference.
- A failed graph-path result no longer resets its status to retry the root.
  The unexercised pkeep/rkept bridge from the handed-off WIP was removed.
  Raw C roots keep their explicit existing boundary. This does not close
  all remaining Array/index adapter rereads or the global path audit.

## Old-to-new witness manifest

| Row / source | Old expectation or source | Current witness |
| --- | --- | --- |
| unit_occ_path_actual | A path and the same path called were both treated as occurrence transport. | Bare and grouped bare paths transport the selected occurrence; its two real calls produce hits20, then an explicit path call produces30. Entry7 retained. |
| unit_occ_path_actual_walk | No forced-methods row. | Same values with walked methods0..4 and native root5, plus cleared-root execution. |
| unit_callable_nullary_forms | task, task(), task:() were called equivalent reference forms. Also used unsigned1U with int hits. | Bare task and transparent groupings transport without execution; explicit task() executes once. Int literal1 matches int storage. Entry7 retained. |
| unit_callable_nullary_forms_walk | No forced-methods row. | Same values with walked methods0..2/native root3 and cleared root. |
| unit_callable_frame_int_refused | Explicit no-result call was diagnosed as a reference received by int. | Call supplies no result: ordinary no-value diagnostic. The separate bare-reference/int refusal remains. |
| unit_k03_struct_frame_actual and walk | Generated code borrowed the named Empty descriptor for an empty Frame. | Ordinary empty-Structure construction remains a positive value actual; Entry7 unchanged, native and walker executions retained. |
| unit_cf_actual_path_head and walk | New WIP invoked Holder tick with parentheses but expected its reference. | Bare path is transported and called twice (n2); an explicit call passed to an int formal then produces3 (n3). Both observed. |
| unit_cf_actual_deep_path_head and walk | Codex's first extension had the same old suppression. | Same positive checks through Holder Inner tick; no successful translation-only expectation. |
| unit_cf_actual_call_result_refused and walk | Not previously registered. | Explicit int result cannot satisfy a callable formal; paired with the real positive bare-reference and int-result executions. |

The positive behaviours were migrated, not replaced by implementation refusals.
The negative checks concern genuinely incompatible int/callable or no-result/int
contracts. A function returning a callable is a different, positive case below.

## Evidence and boundaries

- Frontend built as build/codex_u7r2_value_variant_01, SHA256
  ea5457d8bdc3bd1587e766a8e1e7625f511ca15c1c5d797dfb9fb1a8cb1750d0.
- Shallow, deep, grouped-nullary, selected-path and ordinary empty-Frame probes
  each completed under native / walk-methods and native / cleared root.
- A mutation restoring nullary Frame-to-reference classification accepts and
  executes the incompatible int-result actual; the unmutated compiler refuses.
- A mutation cutting the transferred deep bare-path record after classification
  produces Entry81 under a native root (both translation flags). The unmutated
  program gives7; cleared-root remains7 because that mutation is native-only.
- Replay on the old staged corpus: EXIT1, L1 changes2, diagnostic changes2,
  SAME3568. All five changed IDs are covered by the manifest above; the old
  replay corpus is not silently rewritten. Its known coverage gap remains.
- Focus codex_u7r2_value_focus_02: 81 targets, nine failures. All nine have
  the same FAIL notes as D4: graph_shape_callable_formal,
  graph_shape_callable_formal_arg_mutant, unit_cf_call_pointer_refused,
  unit_local_ns_ctl, unit_walk_local_ns_ctl, unit_local_ns_ctl_loop,
  unit_local_ns_ctl_char, unit_local_callable_explicit_copy and its walk row.
  Every new or migrated row above passes, including assertions that the
  intended methods have no native body in forced-walker mode.
- Kernel codex_u7r2_value_kernel_02: 305 targets, zero failures, 118 executed
  self-tests; L3: all 11 suites and four type budgets pass. Frontend canonical
  Git blob afe025054992260ecf6aa5cc251b1e3e60672817.
- The independent full codex_u7r2_value_full_02 ran 13:18:47Z-14:03:53Z:
  **3613 targets, 1025 failures**. Against D4 fable_u7d4g_full_01
  (3605/1026): zero OK-to-FAIL regressions, one FAIL-to-OK fix
  (unit_callable_nullary_forms), eight new OK rows, zero removed rows,
  zero changed common FAIL notes or diagnostic signatures.
  Against D3: zero OK-to-FAIL regressions; the two new red node-field
  positives are exactly the already registered D4 ancestor-owner debt.
- The staged frontend blob is afe025054992260ecf6aa5cc251b1e3e60672817.
  Source bytes and all eleven relevant staged fixture/alias copies match
  the acceptance index. L2Path header, walk/walk.h, graph_copy_owned,
  implements and the driver match their retained source snapshots too.
  The harness pregate SHA256 is
  446f1b1ea06416da40db319088940139090289a54e0bb446be8b480efb3adcb9.
  Minimum sampled free physical memory during the full:3377MiB.
  The invalid earlier full is not substituted for this result.

The positive probe build/codex_callable_value_actual_candidate.lm2 expects6:
invoke receives the callable returned by mk(5). It still gets incompatible
entry signature in both modes. Keep it as an OPEN positive value-result case,
not an expected implementation refusal. The next common actual-value plan must
admit a produced callable without selecting or invoking the producer's head.

Ancestor-coordinate ownership, independently mapped nested values, mapped
executable copy proof, local-model holder, four-part own hop, root encoding's
990 limit, A/B/C, M2/N4/N3 and the complete self-build/mail goal remain open
at the accepted EA snapshot. The subsequent walker transfer is described
separately below; it is not proof of all-consumer unification.
The [remaining-consumer audit](path-resolution-consumer-audit-20261019.md)
also records the path-headed-call reread, repeated Array/index adapters and
the positive typed-reference-element then field rejection. Those require
one ordered result with types/maps, not just a fix to this actual wrapper.

## Subsequent walker-record slice: verified snapshot

Frontend SHA256
92c29e270c5d775cdae7feb43c0add3538c760b78f93cca7c779f58dead049cd,
canonical blob cc974ca6a2960bac375811c52e9956aebb62d1a9. This snapshot is
separate from the newer root-category WIP; its full gate has frozen its own
source/header copies. No acceptance of the newer WIP is implied.

l2_rw_callable_actual now takes the existing retained L2Path from
l2_cf_actual_rec and passes it to l2_rw_path_value_rec. The discarded-record
span wrapper and its prototype are removed. The path-head call wrapper is
still used elsewhere: the change does not claim those calls are unified.
COUNT and EMIT use the same callable-actual function.

The deep witness now also passes Holder Inner tick to invoke inside exercise,
not only at the program root, and passes an explicit-colon call result to
identity. It checks counts2/3 at the root and5/6 in exercise. Forced-methods
emission has no native words for methods0..6; only root7 remains native.
The witness produces7 in all four combinations of translation flag and root.

A synthetic mutation cuts the retained record to one name after classification
but before the walker consumes it. Unmutated and EA controls give7 under all
four combinations. The mutant gives81 with the normal methods and cleared
root, and INVALID/exit3 with forced methods under either root; its normal
native-root run still gives7. The record is actually consumed, not replaced
by a reparse. This deliberate inconsistent cut is a mutation, not a legal
record-view operation. First mutant attempt probe_01 did not translate because
its build closure was incomplete; only the completed probe_02 is evidence.

New paired positive obligations unit_values_after_index_permuted and its walk
row expect7, not a refusal. An explicit own Array of typed Structure references
receives two candidates with different outer and nested field orders. It
checks actual read/write/address values, unchanged neighbours and one evaluation
per side-effecting index. Both rows are RED at the first field after an index
(46:29, the same implementation-limit diagnostic); no runtime map/value proof
is claimed. They bypass the separate named-Structure Array-construction limit.

- Historical replay: SAME3573 against the walker predecessor; one missing
  retained input and the known696-row coverage gap are not hidden.
- Focus codex_u7r2_walker_focus_01:83 targets/11 failures. The old nine FAIL
  notes/diagnostics are unchanged; the only two added failures are the positive
  Array obligations. No regression, removed row or changed common diagnostic.
- Kernel codex_u7r2_walker_kernel_01:305/0,118 executed self-tests; L3 all11
  suites and four type budgets pass.
- Full codex_u7r2_walker_full_01 ran14:28:14Z-15:17:36Z:
  **3615 targets/1027 failures**. Against the accepted EA full3613/1025:
  zero regressions, zero changed common FAIL notes/diagnostics, zero removed
  rows; the only two added failures are the positive Array obligations above.
  Against D4 the retained M1 nullary fix and eight added OK rows remain;
  no previously green row regressed. The kernel is not declared clean.
- Frontend and the four retained deep/Array fixture copies (including walk
  aliases) match the acceptance index. L2Path header, walk/walk.h,
  graph_copy_owned, implements and driver match the unchanged EA dependencies.
  The frozen harness SHA256 is
  5e497daf2d133d68ad57cd8ab0804e3dca1e8c93e5d9bb6771571eae6a993e9b.
  Minimum sampled free physical memory during this full was3743MiB.

## Subsequent root-category slice

The category/index refactor has its own [verification manifest](path-root-categories-20261019.md):
frontend blob1138b256eb6cad23b9930e099e5fca2298a6ff87 and a complete3616/1027
corpus, exactly one added OK compiler test and no regressions/changed common
FAIL diagnostics against the walker snapshot above. This closes the numeric
root-encoding bound, not the ordered suffix, produced-value root or complete
path algorithm. The manifest explicitly records the launcher postamble error;
the complete corpus and separately run comparisons are the acceptance evidence.

## Excluded run

The initial codex_u7r2_full_01 is invalid: its Windows harness outlived the
stopped Bash runner and a partial output move disturbed its temporary files.
The resulting blank frontend pin /3609 targets /3206 failures are not evidence
of a source regression or of memory exhaustion. Its artifacts are preserved
under its original directory and the abandoned-semantic-audit sibling.
No tracked sources were moved or deleted; use fresh tags for acceptance.
