# Slice 420, step 1: a name the data of a launch does not hold is a place of the call; a local without a value takes the value of the data at entry; the typed write `zz := int: 5`; a `:=` frame is no head of its name

Written 2026-11-17 by Fable (fable_pc), the single writer/build of main. The frontend and kernel code is by the
peer session opus, the fixture drafts by the peer session haiku; opus ran the component builds, the candidate
runs and the mutants under the pipeline token; Fable set the order, took the decisions (ruling R40 in
`LMX_blog/q/fable-self-answers-20261110.md`) and ran the acceptance gates. Base: slice 418+419 `c48346e1`.

Slice 420 was planned as three measured steps. Step 1 is accepted alone, as its fallback point allows: the
author ordered the removal of the signs of places from the clean graph first
(`LMX_blog/2026-11-17.md#no-place-signs`), and the tree had to be freed for it. Steps 2a and 2b are measured by
opus in his own stage and return after that removal.

## What the step is

The call frame of 2026-11-15 gives every call its own namespace: the root declarations of the data give the
input places, the root declarations of the code the other local places, and a code local has no duty to exist in
the data ([parts of a callable](../../../docs/LMX_semantics.ru.md#method-parts),
[call frame](../../../docs/LMX_semantics.ru.md#call-frame-20261115)). The working frontend and the walker still
required every place of the code's table from the data of a launch (the old N4 requirement). Measured before any
edit on the working set of slice 418+419:

- a code that declares `int: v` and assigns it, launched over data without `v`, was refused: natively a thrown
  `call`, in the forced walk `walk error: INVALID`;
- a code local without a value over data that hold the name got no value at entry in the native run (`INVALID`),
  while the walker was green (`split_formal_data`, `split_selected_code`, `split_copy_bound_data`);
- the typed write `zz := int: 5` of a name the code declares nowhere was refused at translation
  (`:= writes a place already known`);
- a root line `x := 4` beside `int: x 2` was counted as a second head of the name `x` (the rule of slice 276),
  so the bare name was refused as ambiguous.

## What changed

Kernel (`lmx_implements.lm2`, `lmx_walk_values.lm2`):

- `lmx_implements_named_places`: a name the data do not hold in one place (none, or two) gives no slot and no
  refusal; a held place of another type still refuses (until step 2b).
- `lmx_walk_slot_place`, the place branch: a row without a slot in the data is the code's own root place of that
  name, its holder the code.

Frontend (`l2_frontend_emit`, `_coords`, `_useplan`, `_lower`, `_core`, `_resolve`):

- the native prologue keeps a holder for every place row beside its slot; a row the data do not hold takes the
  code and its own index, and the three readers of a place address it by the pair holder and slot;
- a code local of a split code whose row is in the data loads the value of the data at entry;
- `zz := int: 5` of a name the method declares nowhere is the operator's write, in both lowerings: the walker
  refused it as an unwalkable declaration, and the native lowering silently dropped the statement (a defect
  hidden until now by the translation refusal: the control read 0 instead of 5);
- `lm_compiler_root_head_text`: a `:=` frame is no named head (the last paragraph of R40).

The source diff is 8 files, +95/-15 lines.

Fixtures:

- New witnesses with their full-suite rows: `code_place_absent_assigned` (`int: v` / `v := 5` over data without
  `v`), `code_place_data_input` (a formal `@: d D`).
- Placed drafts of haiku, each green in the four runs before placing: `split_formal_data`, `split_selected_code`,
  `split_copy_bound_data`, `unary_data_selection`, `assign_typed_unknown_structure_refused` (its row changes from
  a translation refusal to a run that answers 7: the write is translated, a Structure over itself has no place
  for the hidden input and is caught as `implements`, the launch over data that hold `zz` observes 5).

## Recorded and not fixed here

- `code_place_absent_local` (`int: v 5` in the code, data without `v`) is not placed. The same program was
  refused before the step (`call`) and is refused on it (`implements`); the step adds no refusal. Measured
  cause: the constructor row `int: v 5` is inert to the scan of free names, so `v` becomes a hidden input of
  the code. Step 2a.
- Step 2a (`code_place_declaration_assigns`), step 2b (`code_place_input_admission`: a place of another type is
  ordinary admission, `convert`), slice 421 (`unit_n4_inline_named_incompatible`: the separate source
  definition of a Structure row) and the drafts `held_structure_places`, `source_occurrences`,
  `place_write_form`, `explicit_data_var_field` wait.
- Two red fixtures changed their first failing line: `source_occurrences` now stops at translation
  (`Two\[1]y` names a second occurrence that the fourth change removed; the fixture is rewritten by the same
  ruling), `explicit_data_var_field` no longer meets the removed requirement and runs to its own check.
- Limits of the machine path met while the frontend translated itself, worked around and not extended: two
  calls among the variadic actuals of one C call; a field of the result of a `c.` call.
- A fact of the gates, read by opus from `tools/build.lm2` and the build records: the command `build-frontend`
  translates neither `l2_graph_build.lm2` nor `l2_frontend_graph.lm2`; the link imports their `.lm1` as the
  stage holds them. The builder is translated by `build-graph` (or `build-frontend-host`), `l2_frontend_graph`
  only by `build-frontend-host`. Neither module changed in this step; the rule of the helper gates in
  `steps/current.md` is corrected by it.

## Acceptance on the frozen sources

Freeze Source69: 980 inputs, manifest SHA 2f16ef5aac0b29f9…, verify 980/0 for the repository and the stage; the
canonical `selfbuild/inputs.sha256` is byte-equal to it.

- Whole bootstrap, quick, label `boot-f420-01`: genuine G1 and actual G1→G2, 9 smoke rows and 0 failures each,
  21.6 min. G0 is the accepted tool of slice 418+419 (d58de444; no list of machine functions or export
  changed), the previous frontend the hosted candidate `s420a-fe-05` (9c186254), a full frontend build from the
  final sources of the step.
- `fixedpoint420-01`: CHECKS 18 lines, 0 failed: 11 `same` and 3 `exe-same` between G1 and G2, the G2 runtime
  objects byte-equal to the candidate runtime `s420a-rt-03` (built by `s420a-fe-05`), and the two source
  verifications.
- Actual G2: working tool `boot-f420-01/lmxtool.exe` 94559225, frontend c875bf1e, runtime production object ac9d858b and
  observed object 9402fffd.
- Targeted list on the actual G2: SUITE 12 rows, 0 failures, 72 PASS.
- Full suite on the actual G2 (`g2-420-full01`, 17.1 min): **SUITE 208 rows, 44 failures**, 1438 PASS.
  By fixture names 16 are red, a subset of the 20 of the base; none is newly red; `split_copy_bound_data`,
  `split_formal_data`, `split_selected_code` and `unary_data_selection` turned green. The two new witnesses and
  `assign_typed_unknown_structure_refused` are green in every run.
- Graph tool on this G2 (`graph-f420-01`, 722daaa1): `private_binding` and `call_frame_local`, each triple
  interp / native / forced PASS.
- Clean-graph list, 269 pinned rows, each under a 60 s limit: **207 pass, 62 fail**, rows over the
  time limit: 0. Red by names: 62, the names of the base; the graph kernel is not touched by the step.
- Mutants (run by opus under the pipeline token, each undoing one change; every one is killed and leaves the
  other rows green): the kernel of the base in `lmx_implements` (the new witness red in the four runs); the
  walker of the base (red in the forced runs); the prologue without the holder of an absent row (native
  invariant); the frontend core of the base (the four data-input fixtures `INVALID` natively); the lowering with
  the old test of an assignment, and the walker lowering without the typed write (translation refusals); the
  resolve of the base (two root heads); the native lowering without the typed write — the found defect (native
  exit 83, forced green).
- Closers: the source diff adds no `end:` and no fence. The tests add one fence, the opening one of an anonymous
  block whose closing fence drops two levels (`assign_typed_unknown_structure_refused`).

Generated L1 and C were not edited by hand; no row was disabled.

## Files beside these notes

- `full-suite-red-names.txt`: the 16 red fixtures — the new base of the full-suite gate.
- The base of the graph gate is unchanged: `../m10-throws-graph-20261117/graph-baseline.tsv` and
  `graph-red-names.txt`.

Receipts outside the repository: `build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01`,
directories `receipts/opus/s420` (`run/RESULT-step1.txt`, `run/step1-tree.diff`, mutants `mut1b`, probes),
`receipts/haiku/dyn-ready420b` (drafts), `fable` (bootstrap, fixedpoint, G2 runs, graph list).
