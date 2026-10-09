# NODE source-field selection and retained lexical use

## Scope and baseline

Codex is the sole writer/build owner; Opus remains Q&A only. This child
starts at `6fe106a7`: full11 RED70/2711, kernel11 GREEN297 with 114 executed
selftests, L3_11 eleven suites/four budgets. It repairs the bounded
[NODE-PATH-ANON-STRUCT](defects.md#node-path-anon-struct) failure under
[existing path rules](../docs/LMX_semantics.en.md#fields), not a new language
decision. The historical label is inaccurate: the witness's `h:` is a
named source body, not an anonymous Structure.

Owned implementation: `dev/l2src_sandbox/l2trans.lm1`, the old NODE fixture's
comment, sixteen `unit_node_source_*.lm2` files (one is a program part), and
`tools/l2_harness.ps1`. No stable-root promotion, runtime name lookup, new
graph, per-atom metadata or synthetic own-row registration is authorized.

## Connected mechanism

`l2_source_field_seg` selects from one actual lexical source body in source
order. Original P0 identity links each declaration to its existing own or
namespace producer. It does not perform a global same-name namespace search
after an own-name miss. A source body's repeated names have one occurrence
order, not separate own/namespace occurrence counters.

The original MAIN body is the existing `l2_ruse_unit`, not a currently
visited program part. A control scope uses the existing `l2_scope_block`,
not the control header. An ordinary namespace uses its original body; a
method uses its retained body. Existing own-kind classification is shared
by `l2_own_seg_kind` rather than copied into the new selector.

Metadata keeps existing producer identity and type. COUNT's source ordinal
is only a topology seed, never a runtime coordinate. After PLACE a physical
request uses the declaration's completed source/own/namespace place;
missing completed placement is not replaced by a guessed ordinal.
Unsupported selected kind or placement is not mistaken for an absent name
and does not fall through to a formal.

Selection alone was insufficient: the first prototype translated the path
but left `merge`'s copied parent without `h`. The connected fix carries the
first source namespace identity in the existing transient path header and
feeds `l2_use_path`'s existing namespace/use tags. The ordinary dependency
collector resolves these identities after placement and copies the used
lexical field. Runtime still starts at the selected occurrence's actual
NODE, never at a global prototype. A host formal's schema is not a source
namespace declaration; the resolver explicitly returns producer identity
separately from schema, so the collector cannot confuse them.

## Private diagnostics, not fresh acceptance

Private stage01 (`node_build_02.log`) accepted the previously refused
root/deep/function paths, but copy executions failed with missing Structure
or INVALID. This is a failed partial prototype, not evidence of a fix.
An earlier private build failed parsing a missing explicit multi-level
closer; the candidate was corrected without changing the parser.

Connected final private stage03 (`node_build_04.log`) uses translator SHA256
`7C113E049A65E27D5AD472BA75EECCE77D8D1942298E23475C8C36F91EA8742D`.
`node_probes_04.log` and `node_probes_05.log` contain forty successful
executions of ten positive sources in native/walked-method and native/
actually-cleared-root combinations. The nonzero success sentinel is 7.
They cover the original failure, deeper paths, fn result use, repeated
primitive names, method/control/ordinary namespace parents, mixed field
kinds in a named parent, source-place selection with preceding expressions,
two copies, and copy independence after an original write. Three negative
sources reject an absent occurrence, another scope's field, and a field
tail on a primitive. Final production harness pins the measured native
root/method IDs or cleared method words for the supported positive rows.

The first two shadowing experiments placed root `h` before local `h:`.
That spelling is a nonempty call of known nullary h, correctly refused;
it is not a NODE defect. Final sources declare the root later where needed.
The following distinct required positives remain rejected before NODE:

- mixed ordinary/primitive root declarations: `l2_make_entry` reports a
  named-Structure/unit-field collision;
- a later root `h:` after `Outer`'s inner h: namespace collection reports
  duplicate named Structure;
- a part's own ordinary source body: collection reports that a named
  Structure in a program part is not supported yet.

These are registered as six RED required-positive rows, not expected
refusals or a decision on unsettled MAIN-to-part visibility. Nested mixed
names already pass on the published baseline and are a preservation
control, not claimed as a new recovery.

Private replay01 reran all 2615 recorded full65 translation commands:
2613 results are identical to published PATH replay03; only the original
NODE native/walk pair changes from refusal to successful output. No old
successful L1 byte, exit, diagnostic or output-presence result changes.
The final explicit producer/schema separation must still match this replay
on the exact fresh production binary.

Isolated generated-output mutants (`node_path_mutants_05.log`) reject in
four executions. Sharing the original parent and reading the global parent
produce result81 and driver failure. The former only mutates native root
construction; the latter mutates the still-native Model and is detected
with both root backends. Omitting the native root's lexical-use record
fails structurally. Earlier attempts survived the unaffected walked-root
constructor; those survivors are not counted as behavioral proof.
A separate generated-translator mutant (`node_use_mutant_01.log`) omits
all NODE use registration and is rejected structurally in all four backend
combinations. Original production and generated control inputs remain
unchanged. No mutant is part of the production fix.

## Fresh acceptance — verified

The serial chain used 22 frozen input fingerprints. Evidence is in
`build/codex_handoff/node_source_gates_01.log` and
`node_source_remaining_01.log`, on translator SHA256
`7C113E049A65E27D5AD472BA75EECCE77D8D1942298E23475C8C36F91EA8742D`,
staged Git blob `1377bf5bd586a92c7da4b9110c4967434a9e95a2`.
The fresh full binary SHA256 is
`F58D9BC435612EC969C9F9563ECB1F31D71E8DEC430F76ED40CFB67028B203FD`.

- `l2_harness/codex_node_source_focus_01`: RED12/318. Exactly the old NODE
  pair changes FAIL→OK, no old OK→FAIL; thirty additions have 24 GREEN and
  six required-positive declaration debts RED.
- `l2src/codex_kernel_12`: GREEN297, with 114 selftests actually executed.
- `l3_selftest/codex_l3_12`: all eleven suites/four type budgets pass.
- `l2_harness/codex_full_12`: RED74/2741. Against full11: two FAIL→OK,
  zero OK→FAIL, thirty added rows, none removed, no changed failure detail
  for remaining old RED rows. It has 2739 fixture rows and two build rows.
- `codex_handoff/node_replay_02`: all 2615 recorded full65 translation
  commands rerun on the fresh full binary; 820 nonzero exits/1795 L1
  outputs. All exits, diagnostics, output presence and L1 bytes exactly
  match private connected replay01. Against published PATH replay03,
  2613 are identical and only the original NODE native/walk pair changes
  from refusal/no L1 to successful output; no old successful L1 changes.
- `node_source_copies_01.log`: all 76 staged source copies match their
  originals; all 22 frozen inputs remain unchanged through the chain.

The first chain stopped after the completed full gate because the private
row-check helper incorrectly expected 2738 fixture rows, not 2739. The
verdict was already RED74/2741; the extra control is a fixture, not a build
row. Corrected only this diagnostic-helper count, rechecked the exact
named delta set and frozen manifest, verified all staged copies, and ran
the remaining full comparison/replay in the second log. No source, harness,
fixture, expected refusal or production gate was changed to repair that
assertion. This was a helper error, not a discarded failed product gate.

The old NODE fixture's program is unchanged; only its historical ANON
comment was corrected. The eighteen new positive backend rows, six normal
negative rows and six required-positive debts retain separate outcomes.
The bounded NODE source-selection/use defect is fixed. T7, recursive
admission, source declaration debts, both critical parents and §§8/8a
remain OPEN; stable root is not promoted.

Acceptance commands are the existing `tools/l2_harness.ps1 -KeepAll
-Translator bin/l1trans.exe -OutDir <fresh-path>` (focus selects the 315
`unit_node_`, `used_closure_`, `merge_parent_`, `local_ns_`, `a3_`,
`hosted_native_`, `path_structure_`, `s7_`, `s6_` fixture names),
`tools/build_l2src.ps1 -Run -KeepAll -OutDir <fresh-path>` and
`python tools/run_l3_selftest.py --output <fresh-path>`, followed by exact
named comparisons, frozen-source/copy verification, `python
tools/check_docs.py` and `git diff --check`. Private replay/mutant helpers
are supplementary diagnostics in `build/`, not language-owned self-build.

Next bounded child: actual lexical declaration-owner census and selection.
Do not merely remove duplicate/collision refusals, conflate a primitive
with an earlier same-name Structure, or use a caller's owner for a callee's
lexical fallback. Own-part construction is independent of the open author
question on MAIN declarations in parts.
