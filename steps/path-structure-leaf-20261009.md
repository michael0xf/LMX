# PATH-STRUCTURE-LEAF: selected occurrence and consumption

## Scope and baseline

Codex is the sole writer/build owner. This development child starts at
`644a7c51`, with full10 RED68/2683, kernel10 GREEN297/114 executed selftests
and L3_10 eleven suites/four budgets. It continues the recorded
[defect](defects.md#path-structure-leaf), not a new language decision.
The common contract is [resolved-head consumption](../docs/LMX_semantics.en.md#resolved-head-consumption)
and [callables](../docs/LMX_semantics.en.md#callables).

Owned code: `dev/l2src_sandbox/l2trans.lm1`, fourteen new
`unit_path_structure_*.lm2` sources, comment corrections in the two old
field/matrix path call-refusal sources, and `tools/l2_harness.ps1`.
No stable-root promotion, runtime names, auxiliary graph, new per-atom
metadata or receiver-specific syntax is part of this child.

## Mechanism under test

The existing path resolver supplies the final ordinary Structure's existing
schema and procedure. `l2_head_method` uses that procedure only when an
application consumes the selected head. `l2_emit_path_to` selects the actual
occurrence, not its global prototype. A normal C temporary stabilizes the
selected reference across subsequent operand emission; it is not a graph node.

`l2_path_text_read`, `l2_emit_fields` and `l2_rw_span` keep a no-result
Structure as a reference in reference-receiving places. Discarded whole-path
applications use the existing call route in both native emission and
`l2_rw_stmt_content`. `l2_fields_has_call` observes these path applications
inside anonymous bodies, so effect analysis does not discard them.
`l2_schema_method` reuses an ordinary Structure procedure's full existing
schema rather than synthesizing a numeric-fields-only interface.

Number reception rejects the reference with the existing diagnostic, including
formal/result/prefix/composite cases. `l2_check_numeric_span_kind` runs after
held-result reception and does not replace exact machine pointer types or
the existing arithmetic/text diagnostic checker. This ordering was corrected
after the first replay exposed six regressions; no fixture-specific bypass
was introduced. Ordinary named Structure visibility remains forward-only.

## Private diagnostics, not fresh production gates

The published baseline refused eight native/walk translations of the first
four probes. In the statement source it refused the first explicit `()`
application; that does not prove that the preceding bare statement itself
was checked correctly.

Private stage02 translated and ran six positive sources in all four
combinations of native/walked methods and native/cleared-root execution:
24 successful executions with nonzero success sentinel 7. They cover:

- bare, parenthesized, short-empty and vertical-empty applications; each
  activation reinitializes a declared local, while an explicit counter records
  four calls; enclosing Structure bodies remain dormant;
- reference transport without executing the transported Structure;
- a copied occurrence, with original/copy data and native-word checks;
- a deep path inside an anonymous body, without executing its ancestors;
- reordered candidate fields, read through the admitted interface;
- selection and application through a method's Structure formal.

Number/formal/result/prefix/composite negatives, a nonempty call of a nullary
Structure and a forbidden forward reference are registered as native/walk
pairs. The source comments of two old rebind-shaped negatives now describe
their actual invalid-call contract; programs are unchanged.

The nested-description transport source is a REQUIRED POSITIVE. Both modes
still refuse recursive admission through a Structure field of another type.
They remain red acceptance rows, not expected refusals. No unmeasured method
IDs or native-word claims are attached to those rows.

Private replay01 found six old successful translations lost at held-result
reception and three overbroad diagnostic changes. After the common ordering
and type-boundary correction, replay02 reran all 2615 recorded commands:
822 nonzero exits, no changed exit or output presence against the published
hosted replay02. Exactly four L1 files changed (`unit_exprtext_path` and
`unit_s7_arg_deep`, including their walked twins). Two already-refused path
programs now report `incompatible entry signature` at the same locations.
The other 2609 rows are byte-identical. Review of the four changed L1 files
found the same actual-path stabilization/admission replacement in the
native/walk pairs. The later admission-counter and call-temporary changes
are renumbering, not different consumers. Fresh full-gate execution must
still validate these four translations.

Four isolated generated-C mutants were rejected in seven executions, each
with wrong-result sentinel 81 and driver failure: selecting the prototype,
stubbing the selected body, executing a reference actual, and reading the
first field instead of its admitted field. The prototype mutation concerns
only native root code; it is not claimed to mutate the walker. Earlier
mutation-design attempts that survived an unmodified backend or tripped an
invariant guard are not counted as behavioral proof.

Private logs are under `build/codex_handoff/`: `path_leaf_probes_03.log`,
`path_leaf_translation_02.log`, `path_leaf_replay_02.log`,
`path_leaf_replay_compare_02.log` and `path_leaf_mutants_04.log`.
The final source SHA256 is
`F791AD9B880EF1293FA9A9AD879F13CBD7F169B697ED792863C0F5027695208D`.
It differs from private stage02 only in comments, but that is not a substitute
for gating the exact production bytes.

## Fresh acceptance

The exact-source focused harness completed: `codex_path_leaf_focus_01`
RED5/184 (181 selected fixtures plus three build controls). All 28 new rows
are present: 26 GREEN and the two required nested-admission positives RED.
The other three red fixtures were already red in full10; no selected old
OK became FAIL. The first orchestration attempt stopped because its auxiliary
comparison expected fixture extensions where summary rows use stems. After
correcting that comparison, the completed focus was reused only after all
21 frozen input fingerprints matched. No production source or expectation
was changed to repair the helper. The exact kernel11 run then passed
297 targets, with 114 selftests actually executed. L3_11 passed all eleven
suites and four budget checks.

Full11 completed RED70/2711. All old rows are retained, with no old OK→FAIL
or FAIL→OK; the existing 68 red rows retain their harness failure details.
The 28 additions are exactly the fourteen paired sources above: 26 GREEN,
two required recursive-admission positives RED. All four previously
classified changed translations ran successfully; their walked twins also
ran with the actual physical root's native word cleared.

Fresh replay03 ran all 2615 old recorded translation commands, with 822
nonzero exits and 1793 outputs. Against hosted replay02, it has the same
four classified L1 changes and two corrected invalid-call diagnostics
described above; no exit or output-presence change. Against corrected
private replay02, every row, exit, diagnostic, output-presence result and
L1 byte is identical. All 21 frozen source/harness fingerprints stayed
unchanged through the serial focus/kernel/L3/full/replay chain.

Evidence under `build/`: `l2_harness/codex_path_leaf_focus_01`,
`l2src/codex_kernel_11`, `l3_selftest/codex_l3_11`,
`l2_harness/codex_full_11`; orchestration `codex_handoff/path_leaf_gates_02.log`,
full comparison `codex_handoff/path_leaf_full11_compare_01.log`,
replay `codex_handoff/path_leaf_replay_03` and
`codex_handoff/path_leaf_replay_compare_03.log`.

This is a reviewed development checkpoint, not a GREEN full gate or stable
promotion. All 42 relevant source copies in focus/full/kernel match the
owned inputs (`path_leaf_gated_copies_01.log`). `check_docs.py` and
`git diff --check` pass; publication uses only the 24 exact owned paths.
The next independent bounded child is NODE's
lexical-source field selection/projection. Its private candidate/probes are
not part of this acceptance and are not yet built or tested.

T7, the recursive-admission debt, NODE-PATH-ANON-STRUCT and stages 8/8a remain
OPEN. A successful bounded child does not establish full self-build.
