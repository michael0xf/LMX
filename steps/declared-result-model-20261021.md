# Declared result Models and the copied-giving control

Implementation checkpoint, not a language amendment. Codex remains the sole
writer/build. Public `dev/` has not been replaced by private98. The full97
pipeline is still running; none of its live artifacts are terminal receipts.

## Private98 prerequisite, not yet a runtime result

Stage: `build/codex_mixed_path_fold_98`, based on private97. Only
`src/l2src/l2trans.lm1` differs from that stage's compiler source. Runtime95
is unchanged.

The existing ordinary method layout retains Model witnesses in `args`, but
its result was emitted as a closed pointer-cell witness. Private98 uses one
`l2_declared_graph_witness` helper for declared inputs and the declared result,
in both method headers and explicit CALL contracts. The result uses the
existing type-inventory index `-1`. The actual Model is an ordinary graph
reference, not an extra method field, model ID or opcode. COUNT retains the
same Model dependency that FILL emits. Primitive, void, opaque-reference and
hidden-input witnesses retain their prior forms. `l2_rw_contract_parts`
shares allocation of the existing two-part contract.

`build/codex_header98_translate_01.ps1` completed L1→C only. Its actual LM1
input is frozen under the correspondingly named output directory. No GCC98
or runtime source-value check has completed at this checkpoint.

The authoritative source/helper pair was frozen **before translation** by
`build/codex_header98_source_control_04.ps1`:

- `build/codex_header98_source_control_04/source.lm2`;
- `build/codex_header98_source_control_04/includes/l2src/tests/declared_result_header_test.h`.

It translated through old97 to native and forced-method L1/C. Those are two
translation observations, not passing value tests. Earlier attempts01–03
remain available. In01/02 the recorded source copies were reconstructed
after WIP edits from the exact preceding tool text; they must not be described
as original pre-execution snapshots. No runtime executable consumed those
early helper attempts.

The source checks two different result Models in actual method headers and
actual CALL contracts, ordinary copyMap alias relocation of a return Model,
opaque-null/void/int controls, forwarding, and real read/write/address values
9→41→43 while neighbors stay unchanged. Selected callbacks ensure the CALL
contract check is not vacuously inspecting only direct calls without an
explicit contract. The helper inspects graph addresses; it does not implement
another path resolver.

Prepared recipes, **not yet executed**:

- `build/codex_catalog98_build_01.ps1`: preserve the prior194 compiler assertions;
- `build/codex_header98_values_01.ps1 -Version 97` and `-Version 98`:
  the identical frozen source/helper, native/forced methods crossed with
  native/cleared physical root. The desired source result is7. The expected
  old97 observation90 is a RED control, not a passing language oracle.

Both recipes reject a GCC run while the existing full97 is nonterminal.
Results must be measured, including actual bindings and phases; successful
C generation is insufficient. Retaining a return Model alone does **not**
implement the typed-giving `sourceContext` producer or prove covariance.

## Copy97: two independent measured facts

Original source: `build/codex_giving96_copy_01.lm2`. Actual compiled program:
`build/codex_catalog97_nested_giving-copy_01/native.exe`. This remains one
of the original giving positives; its expected result7 is unchanged.

The foreign ABI fixture explicitly creates one two-int raw value and admits
it to root Models D/E. These declarations each contain four physical slots
(two value slots and two declaration-graph slots). Their maps use raw slots
0/1 for declared slots0/2; the remaining places are UNUSED. Both full
admissions are real, but neither is asserted to be the raw value's physical
origin, and R is not pre-admitted by the fixture.

1. `build/codex_giving97_copy_03.ps1` runs the actual executable under GDB.
   At the later refusal the original still has D/E entries with origin0.
   The copied value has a different address and only a self entry with the
   synthetic merge layout token5: no D/E entries. The copy operation itself
   has already succeeded. This is not evidence of allocation failure.
2. `build/codex_giving97_copy_04.ps1` runs actual compiler97 under GDB at the
   original source's admission site. The retained source of merge0 is E with
   layout absent. Nevertheless, pair merge0→R says source_width4 and
   physical_width4 and selects v→2/w→0. The actual copied graph has width2.
   This directly exposes the confusion between a logical schema and a
   physical producer, before the final native invariant abort.

Both probes03/04 completed successfully and their GDB children ended.
Probe02 produced valid initial source observations but subsequently failed
on a nonexistent diagnostic variable; its full execution is not a success.

The generic copier currently excludes operand roots from admission-record
carry. The old table selftest deliberately checks that a new root is admitted
anew; an unrelated old permission must not simply be copied to the root.
The single-operand/no-absorb route also passes this exclusion. This means the
observed absence of copied root entries must not be prematurely attributed
only to an uncopied Model dependency, nor "fixed" by removing lifetime checks
or borrowing every old permission across arenas.

The open dependency is one resolved typed result and its real current
Model/address/coordinate evidence through construction, copying, reference
and index steps. Both backends must consume that result. A native abort
guard, first-layout lookup, guessed origin from E, or a merge-only path parser
would not resolve it. The language's common merge/copy and admission rules
remain the norm; historical test implementation is not an additional norm.

## Existing unresolved source matrix

`build/codex_giving97_baseline_values_01/results.json` has32 actual RED cells
for formal/node/index/return/copy/mixed/capture/covariant. All translated,
compiled and linked. The original node control has a distinct missing-place
failure, while an additional explicit `var`-field node-body control yields
four ordinary exit1 failures rather than abort3. Neither the old node source
nor its oracle was removed. These failures are not declared to share one
proven cause.

Full97 is still the sole GCC pipeline. After its terminal result, compare
every actual target with full95 **and** full63, then run the prepared98
prerequisite and source-value differential. No private-stage promotion or
self-build readiness is asserted here.
