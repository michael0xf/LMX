# Slice410: fixes of the accepted 409 and the array path without cancelled checks

Written 2026-11-16 by Fable (fable_pc), the single writer/build of main. The code is by the peer
sessions opus (walker and runtime) and sonnet (frontend); the fixtures were entered by haiku.
Fable ran the baseline, the freeze and the acceptance gates. Base: 409 `2799ad1c` with the
documentation commits up to `b795a69d`.

## Why this slice exists

The review of 409 (FABLE-S409-A) had been done by reading only. Its four findings were reproduced
by real runs on the actual G2 of 409 (tool bb7132fe, frontend c8dc8d5a, runtime a9d6a398/28a0d532)
before anything else was built; the three control programs passed.

| Finding | Program | native | forced |
| --- | --- | --- | --- |
| D1 | an explicit actual into a `private:` header input, then a callee with the free name | 7 | 83 |
| D2 | a CODE-local Array read by a callee's free name | 88 | INVALID |
| D3 | a written DATA field read only inside a nested if / else / while / until body | 7 | INVALID |
| D4 | the locals of a block closed by `until` read by its condition | 83 | 7 |

Two more defects of 409 came out of the same runs. Any CODE-local Array gave INVALID in the forced
walker, with no callee involved. Eight fixtures crashed the translator with a stack overflow
(exit -1073741571, an empty log): under gdb the accepted frontend shows more than 22600 frames of
one ring, `ns_constructed_row → declaration → … → own_layout → ns_constructed_row`; the frontend of
408 translates all eight files.

## Baseline of the full suite

The full suite had not been run as a whole since about slice 350 (162 rows, 0 failures); slices
384–409 were accepted on targeted lists. On the accepted G2 of 409 the stage list of Source16 gives
**SUITE 178 rows, 132 failures**, 1098 PASS, 45 red fixtures (log `baseline-full01.log`, tables
`baseline-full01-triage.txt` and `baseline-full01-exits.txt` in the receipts). From this slice on the
full suite is part of the acceptance of every code slice; the red list is kept explicitly and may
only shrink. No row was disabled and no expectation was weakened.

## What changed

Walker and runtime (`lmx_walk_values.lm2`, `tools/build.lm2`):

- D1: one reader `lmx_walk_input_origin` gives the canonical origin and the private mark of a formal
  input of a callable's header — the header cell itself, what a generated native call already
  passes. `lmx_walk_call_rows` fills its rows with it; `lmx_walk_call_in` takes the arrays through
  `lmx_walk_input_origins` and hands them to `lmx_walk_dispatch_values` instead of zeros.
- D3: the skip of nested control bodies in `lmx_walk_entry_node` is removed whole. Rows are still
  made only for the DATA holder.
- D2 in the walker: a reached declaration without a candidate creates its local Work row under the
  same holder condition as a reached SET. A read still creates none; there is no branch by type.
- Arrays, plan M13 item 3: `lmx_value_array_place` keeps exactly one L3 check, the linear index
  against the current length, and gives the place of the element; the checks of the domain kind,
  the data pointer, the element metadata, the range type, the pointer pool and the stride are
  gone. The machine-pointer branch of `lmx_walk_value_index_place` is a plain offset: the owner,
  overflow and interval checks are gone. `lmx_walk_array_elem_meta` is deleted with its export and
  prototype: Walk exports 191 → 190.

Frontend (`l2_frontend_lower.lm2`, `l2_frontend_types.lm2`):

- D4: `lm_compiler_emit_body_with_position` is a binding mark, the new internal
  `lm_compiler_emit_body_statements` and a restore. In a block closed by `until` the restore is
  emitted after the condition and before the body of the next turn, so the locals of a turn live
  until the condition has read them, as in the walker.
- D2 in native code: a reached first declaration that stores nothing joins the activation's
  bindings by the same `lm_compiler_emit_work_binding` a stored local uses.
- The rule of `lm_compiler_scan_ident` that an Array "cannot travel as an input" is removed: a unit
  Array field visible to a method is a hidden input like a number, so a caller's local Array is
  found before the lexical one. The existing hidden-input path already carried Arrays.
- `lm_compiler_emit_array_cell` loses the dead branch for a status other than OK;
  `lm_compiler_emit_path_index` loses four unused locals and the separate index reception for a
  machine function.
- `lm_compiler_ns_constructed_row`: the edge to `lm_compiler_declaration` that 409 added is removed;
  the literal-primitive branch matches by the same owner, source node and bare flag as its
  neighbours. No depth counter and no visited flag.

The machine step of a graph Array path turned out unreachable: a machine function cannot declare a
graph Array (the translator answers "a field of a machine function is neither a number nor a
pointer: it needs the graph"), so no branch was kept for it. A rectangular multi-dimensional Array
does not exist in the working frontend: `a[i][j]` on a declared Array is refused as not built, and
the written chains in the fixtures step through Arrays of references. The folding of adjacent
indexes therefore had nothing to fold; declaring rectangular Arrays stays OPEN in plan M13.

## Fixtures

Fourteen programs of the reproduction became maintained fixtures in `tests/dyn` with their rows
in `full-suite.tsv`: `walk_private_header`, `walk_public_header_control`, `local_array_binding`,
`data_field_top_and_nested_control`, `nested_if_data_field`, `nested_else_data_field`,
`nested_while_data_field`, `nested_until_data_field`, `until_outer_local_control`,
`until_body_locals`, `local_array_const_index`, `local_array_var_index`,
`local_array_pointer_read`, `local_array_store_only`.

Two fixtures expected the cancelled refusal of a pointer index beyond its interval. Without the
check such an index is a raw address outside the object, and both programs crashed with an access
violation in native and forced. Only those expectations were removed: checks 23–28 of
`root_pointer_index.lm2` with the methods that served them alone, and checks 22–23 of
`index_numeric_receive.lm2`.

## Component runs before the freeze

- Runtime of opus (`o410-rt-01`, driver.o 20069522, observed d0cd3d64; tool `o410-tool-02`
  45612bbb) with the accepted frontend: targeted 12 rows, 0 failures; full suite 178 rows, 130
  failures.
- Frontend of sonnet (`s410-frontend-03`, hosted 7bc60efa) on that runtime: all reproduction
  programs and both migrated fixtures give 7 in native and forced, root0 and root1; targeted 12
  rows, 0 failures; full suite 192 rows, 116 failures, 37 red fixtures, none red that was green.
  Green again: `composed_declares_structure`, `free_c_pointer`, `free_field_places`,
  `index_numeric_receive`, `index_numeric_unavailable`, `numeric_unavailable_norow`,
  `root_pointer_index`, `whole_direct_fields`, `whole_field_refused`.

## Final acceptance on the frozen sources

Freeze Source17: 958 inputs, manifest SHA 59438d92bac1e551ae4385490674d966312379f0228469b0050b04a0bd581a93
(`source17.sha256`), verify 958/0 for the repository and the stage. The canonical
`selfbuild/inputs.sha256` was regenerated by the ordinary `manifest` in the repository and in the
stage; both copies are the same file as Source17.

- Whole bootstrap, quick, label `boot-f410-02` (G0 tool `o410-tool-02` 45612bbb, previous frontend
  `s410-frontend-03`): genuine G1 and actual G1→G2, 9 smoke rows and 0 failures each, 22.6 min. The
  first launch (`boot-f410-01`) was stopped by the session harness for low system memory during the G2
  build and is not a result (`whole01.killed.txt`).
- `fixedpoint01`: CHECKS 18 lines, 0 failed — 11 `same` and 3 `exe-same` between G1 and G2
  (consumed inputs, runtime C and both objects, tool L1 and C, backend, libc, frontend L1 and C, the
  three executables), the G2 runtime objects byte-equal to the component run `o410-rt-01`, and the
  two source verifications.
- Actual G2: working tool `boot-f410-02/lmxtool.exe` 06ac1cd2, frontend 63010ca6, runtime C
  3e6b904d, production object 20069522, observed object d0cd3d64.
- Targeted list of 409 on the actual G2 (`g2-targeted01`): SUITE 12 rows, 0 failures, 72 PASS in
  native and forced, root0 and root1.
- Full suite on the actual G2 (`g2-full01`, 14 min): **SUITE 192 rows, 116 failures**, 1222 PASS.
  By fixture names in the FAIL lines the baseline has 46 red fixtures and this run 37; none is red
  that was green in the baseline. Green again: `composed_declares_structure`, `free_c_pointer`,
  `free_field_places`, `index_numeric_receive`, `index_numeric_unavailable`,
  `numeric_unavailable_norow`, `root_pointer_index`, `whole_direct_fields`, `whole_field_refused`.
  The 37 remaining names are listed in `g2-full01-red-names.txt`; they are the work of the next
  slices and the list may only shrink.
- Graph tool on the same G2 (`graph-f410-01`, 3e1dad12): `private_binding` and `call_frame_local`,
  each triple interp / native / forced PASS.
- Mutant in a separate stage `fable-m14-binding-mutant-01`, staged from the canonical manifest: one
  line of `lmx_walk_input_origin`, `binding_private[0] := metadata\binding_private` replaced by
  `binding_private[0] := 0` (`mutant-run.diff`, two changed lines). Its runtime builds (C 6cc2c2bf,
  production d85ecd5f, observed ca71a544); the unchanged `walk_private_header` gives 7 in native on
  both roots and exit 83 instead of 7 in forced on both roots — the finding D1 again. The
  repository and the working stage were not mutated.
- Documentation: `docs render semantics` rendered 35 paired chapters and 14 implements cases from
  the edited source; `git diff --check` is clean. The working-tree `docs check` stops at the line
  endings phase on the journal question file that this commit deletes (it is archived under
  `LMX_blog/q/`); the check of the staged index is the acceptance one and its result is in the
  commit message.

Generated L1 and C were not edited by hand; no expectation was weakened; no row was disabled.
Receipts: `build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01/fable`.

## Numbering

This slice is number 410. The M10 vertical with the six call forms, which the plan had under that
number, follows it as the next code slices.
