# Reference crossing: use the admitted slot map — Codex, 2026-10-09

## Bounded child — terminal acceptance

`CODEX-REFERENCE-CROSSING-SLOT-MAP-20261009-14`, started immediately after
verified publication of `ecadf0003524eaa77ed48b6c8bfa0943a77f87dd`.
Codex is the sole writer/build; Opus remains Q&A only. Parent T7, the two
critical tickets and stages8/8a remain OPEN. Stable root is unchanged.

Exact implementation boundary: the shared native path emitter
`l2_emit_path_to`, its existing slot-map lowerer `l2_d105_emit_slot`,
the shared walker path resolver `l2_rw_path_resolve_sized` and the
existing model operands consumed by `l2_rw_path_value` in
`dev/l2src_sandbox/l2trans.lm1`. Add persistent controls under
`dev/l2src_sandbox/tests/`, exact rows in `tools/l2_harness.ps1`, and
update this journal, `steps/current.md`, `steps/defects.md` and the four
v2 implementation documents. No new runtime opcode, registry, graph,
name lookup, per-atom metadata or language exception.

## Measured baseline

`unit_nested_model_compatible` and its walked twin are mandatory RED in
full14 RED76/2771. Outer owns Inner(x) and a typed reference; Candidate
owns pad and x at another physical slot. Binding is accepted and an
implements correspondence is registered, but `Outer\ref\x: 31` uses
raw model slot0. The candidate's x stays13 and execution yields81 in
native and actually-cleared-root modes. The copy/refusal controls are
GREEN; they do not prove shifted-candidate addressing or copied model
identity.

Native keeps an input/own key after a reference crossing only if an own
row exists. Namespace fields have no such row, despite an already
resolved pointee schema. Walker triples similarly discard that model.
Its existing OF/PUT readers already accept an optional model operand and
resolve the edge through `lmx_implements_slot`; no interpreter invention
is needed. Keep the resolved schema independently of an optional input
key, and let the common slot lowerer consume it directly.

## Enumerated continuation — no further prompt required

1. Verify the baseline witness in both backends; inventory model/schema,
   declared slot, selector half and physical receiving instance at each
   boundary. Keep private stages and outputs separate from fresh gates.
2. Implement the common native and walker route. Initial admitted roots
   retain their existing selection; each reference crossing carries its
   declared receiving schema to the next edge. Do not replace a missing
   source place with a prototype, fake own row or fixed depth buffer.
3. Exercise shifted read/write, address identity, duplicate names with
   LAST versus explicit ordinal, multiple crossings, copies/originals,
   existing formal/own/host/control paths, identity/null/refusal and actual
   method-walker/cleared-root execution. Expose additional required debts
   explicitly rather than accepting refusals or mutating language rules.
4. Reject isolated generated-output faults that remove the map or select
   the wrong half. Preserve originals and every failed attempt.
5. Freeze the exact final source/harness/tests, run fresh focused, kernel,
   L3 and full acceptance serially. Compare full14: no old GREEN regression,
   no removed rows, exact additions and classified changed diagnostics.
   Replay the2615 recorded translations and inspect every output delta;
   compare final replay with the tested candidate and verify staged copies.
   Run `python tools/check_docs.py` and `git diff --check`, then exact-path
   commit/push and verify HEAD/upstream/remote equality.
6. Immediately continue `LOCAL-NESTED-MODEL-ANCHOR` through the original
   source field/holder and selected actual local/receiving occurrence.
   No wait for Opus or another user ticket. A real unresolved norm is
   reported to the author in Russian; independent work continues.

Admission has already established structural correspondence. This repair
uses its address mapping; it does not revalidate every primitive mutation,
run behavioral tests on each access or analyze candidate algorithms.
T7-MODEL-OPERAND-SOURCE, recursive structural admission and actual local
host selection remain separate until specifically measured and repaired.

## Private attempt and first fresh focus — not publishable

Private probe02 (`5C9B18D5` source, `995E2AAA` binary) fixes the shifted
candidate in four actual backend/root modes. Five added witnesses cover
ordinal/LAST reads and writes, physical address identity, two crossings,
copied owners, formals and identity/null transitions:20 executions pass;
seven old controls add28 successful executions. Four isolated generated
faults are rejected (wrong half or omitted map, native and walker).
Replay01 retains all2615 exit/diagnostic/output-presence results, with526
L1-only changes:71 exact shared-slot-prologue removals and455 further
output changes preserved for classification, not assumed equivalent.

Private candidate04 `C7201D1683148CEA10923CE4FC5B58FC0D3E851B60CC1E92A5E7E2F462108684`,
binary `070870DEC198B04F32683D0BD5864EF23F5344D6AC941E0C900484887F4DDDF4`,
passes68 actual backend/root executions and four generated map faults.
The revised root-store oracle accepts the original operand and rejects a
distinct operand of the same kind/width, without changing emitted bytes.
Two diagnostic-script launch mistakes (PowerShell's reserved Input variable
and an unset exit code) are retained; corrected oracle03 is terminal.
Fresh private replay04 executes2615 commands: all exits/diagnostics/presence
match probe03, and2614 outputs are byte-identical. The sole changed output,
`unit_named_actual_structure_name_lib`, adds exactly the required shared
API predef; every other byte is identical. This is not full acceptance.

## Full15 failure — continuation remains in this child

Full15 is terminal RED76/2781, not publishable. Its comparison has two
old recoveries, ten additions GREEN, no removed rows or changed old refusal,
but two old GREEN regressions; the serial driver stops before final replay.
`unit_named_actual_structure_name_lib` really fails C compilation: the new
shared constructor publisher calls the admission API but the dependency
selector omitted its header for a library without an admission site.
Include the shared dependency whenever namespace construction needs it,
not by any source name or a special library implementation.

`unit_root_putof` stops at its obsolete static oracle, before execution:
it expects OF/3/raw packed slot0. The common reader now emits OF/4 with
the actual committed model slot2 and the SAME existing m operand as holder
and model. Direct full15-byte native-root and actually-cleared-root probes
both pass (12 and16 driver checks). Strengthen the shape oracle to pin the
new model edge, actual slot and exact operand identity; do not delete it.
Preserve full15 and rerun private controls, library linking, root identity
faults and a fresh complete serial gate on corrected final bytes.

Fresh focus01 is terminal RED34/513 (510 definitions). The serial gate
driver correctly stops before kernel/L3/full: five former GREEN rows fail.
`unit_a3_capture_direct_vs_copy` pins an obsolete temporary spelling and
does not reach execution; replace it with a declaration/lookup/cell-use
relationship pin. The native and walked `unit_ns2_bind_nested_self` and
`unit_ns2_eternal_ref` execute and fail with missing correspondence.
Their inert NSF producers construct Inner/E, including self references,
but `l2_source_layouts_emit` publishes only non-inert callable roots.
This is a constructor-publication omission, not permission for missing-map
fallback, name lookup, repeated mutation validation or a new runtime graph.

Continue within this child: once every original namespace is fully filled
and reference-wired, publish its existing layout evidence through
`l2_emit_constructed_layout`, the same route used by local/projected roots.
Library construction needs this evidence as well. Rebuild a fresh private
stage and rerun actual ns2 failures plus prior controls; preserve focus01.
No code from this attempt is published and no failed row is reclassified
as an expected refusal.

## Corrected private constructor and fresh acceptance in progress

Probe03 source `D6C8B377D002102902D503EB549D8635D2AA393FD1742DF97BFE8DCCA8B8751B`,
binary `3570477AB524F023802FA1C36A69196A2D9D50116CBF0124E2BD9EB470FD7B47`.
The existing publisher now includes every completed original non-local
namespace, after reference wiring and frame filling, including libraries.
It uses the same layout token and admission table; no missing-record reader
fallback is introduced. Local/projected roots retain their existing producer.

`reference_crossing_probes03.log`:64 actual executions pass across both
method backends and native/cleared roots. This includes the ns2 self and
qualified-reference regressions with their full physical `postpaths`
assertions, A3 and the previous shifted/deep/copy/formal/null controls.
`reference_crossing_mutants03.log`: all four isolated generated map/half
faults execute and fail; original generated outputs remain unchanged.

Private producer replay03:2615 commands,1795 outputs,820 nonzero exits.
Against probe02, an exact read-only classifier proves876 changed outputs
contain only2013 completed-namespace identity publishers, with the namespace
index matching its token and an actual allocation for each instance.
Every other output byte, exit, diagnostic and output presence is unchanged.
The original526 crossing deltas are inspected separately; this publisher
proof does not by itself establish their execution correctness.

At that earlier attempt, canonical source exactly matches probe03. Fresh focus02 is terminal
RED29/513 (510 definitions): ten additions GREEN, the nested compatible
pair recovers, no previous GREEN regression or changed old refusal. The
strong A3 pin ties declaration, map output and cell use to one temporary.
The serial driver continues kernel15, L3_15, full15 and final replay02;
none is claimed complete here before its terminal result. Preserve all
failed and successful attempts, keep26 frozen inputs and94 staged copies
exact, then publish only after the complete child checklist.

At that earlier checkpoint, kernel15 is terminal GREEN297/114 executed
selftests and L3_15 passes eleven suites/four type-budget units. Full15
was still running; its later failure is recorded above and is not accepted.

Read-only next-child diagnosis: `l2_rw_ns_model` and `l2_model_inst` resolve
the local root using `l2_own_of_local_ns(current_method, root)`. In the local
Outer/Inner witness the current constructor is Outer's procedure, whereas
Outer's source declaration belongs to read. The actual existing
`l2_source_definition_field(root, 0, -1, owner)` supplies its declaration
field and source owner without spelling lookup. Its native GraphField and
native `l2_own_ctr` already project lexical ancestry. Walker `l2_rw_cell`,
however, binds an unhosted foreign row to the unit; merely changing the own
lookup would still produce a wrong physical root. Reuse GraphField and the
existing NODE/OF operations with the actual declaration-owner ancestry,
including the selected receiving context, not a unit prototype or a constant
parent-depth assumption. No code for that child changes these frozen bytes.

Exhaustive old-to-probe02 delta inventory05 is terminal:526 outputs differ,
71 exact unused-slot-declaration removals and455 further outputs. Every
changed hunk is retained and classified into slot temporaries, map calls,
physical cell use, invariant wording, OF/model edges/selectors and residual
lines. This inventory is not a byte-equivalence assertion. Slow exploratory
inventories03/04 were stopped, retained and replaced by05; no compiler or
gate was interrupted. Final probe03 adds only the separately proved
constructor publications described above. Actual full execution remains
mandatory for these translated changes.

## Corrected fresh serial chain — terminal

Focus03 is terminal RED29/515,512 fixture definitions. The two full15
regression controls are explicitly included and both GREEN; the ten new
rows are GREEN, the old compatible pair recovers, and no old GREEN row
regresses or old refusal detail changes. Kernel16 is GREEN297/114 executed
selftests; L3_16 passes all eleven suites/four type-budget units. These
stages and canonical source have the same `C7201D16` bytes. Full16 is
terminal RED74/2781 (2779 fixture rows). Against full14 RED76/2771:
two old FAIL→OK (the compatible pair), ten added GREEN rows, zero old
OK→FAIL, zero removed rows and zero changed old refusal details. The two
full15 regression controls are GREEN in focus and full. The full remains
RED for required parent debts; no row is reclassified as an accepted refusal.

The corrected serial driver `run_reference_crossing_gates_02.ps1` is
terminal exit0; its full log is
`build/codex_handoff/reference_crossing_gates03.log`. All28 frozen inputs
are unchanged and98 gated source copies are byte-identical. Final replay03
executes2615 recorded full65 commands, with1795 L1 outputs and820 nonzero
results. Every exit, diagnostic, output presence and output byte exactly
matches private replay04. Full comparison is retained in
`build/codex_handoff/reference_crossing_full16_compare_01.log`.

Exact final source SHA256:
`C7201D1683148CEA10923CE4FC5B58FC0D3E851B60CC1E92A5E7E2F462108684`;
Git blob `2a02d6b91dc0d93e42fc5f97014dedbce4139fa0`;
fresh full16 binary SHA256
`3F3604258FB49D28E2612F6A13BF0E5E1E98FF70EDA14C4B30BA08FB29ED251D`.
Build-directory binary identity is recorded, not assumed to equal the
private binary; equality is proved for its2615 translation results.

The bounded crossing defect is repaired. Preserve all failed attempts;
stable, T7, recursive structural admission and stages8/8a remain OPEN.
After docs/whitespace/exact-path commit/push checks immediately start
LOCAL-NESTED-MODEL-ANCHOR through the actual source-owning occurrence;
do not wait for Opus or another prompt, and do not start a second build.
