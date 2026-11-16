# Slice411: a Structure written through a path, and the anonymous group collected once

Written 2026-11-16 by Fable (fable_pc), the single writer/build of main. The code is by the peer
session sonnet (frontend); Fable set the order, verified the frozen sources and ran the acceptance
gates. Base: slice 410 `a0d5705a` with the documentation commits up to `6e35e873`.

## Why this slice exists

After slice 410 the full suite on the actual G2 had 37 red fixtures. Twelve of them stopped in
translation with "root operation not walkable yet: this reference path", two with "out of memory"
in a `catch`. This slice removes the first cause for the writes it covers and the second cause
whole. It is not the M10 vertical of the call forms.

## What changed

Frontend (`l2_frontend_values.lm2`, `l2_frontend_emit.lm2`, `l2_frontend_lower.lm2`):

- New `lm_compiler_path_leaf_descriptor`: a successful path whose leaf is a Structure descriptor —
  a Structure place or branch, or a method part. `lm_compiler_path_rec_leaf_ft`, the reader of the
  leaf, calls it instead of its two inline branches; the values are the same.
- `lm_compiler_rw_path_write_rec`, the writer of a Structure through a path, takes the same
  category: the write through a reference path is walkable when the leaf is a descriptor. Before,
  the writer knew only the first of the reader's cases.
- New `lm_compiler_ns_anonymous_group`: a namespace row of an anonymous `---` group has no name, no
  defining frame and is not a source part. `lm_compiler_ns_procs` no longer makes a procedure for
  such a row: the body that holds the group walks its fields and its code in that body's
  activation, once. Before, the same `catch` node was collected twice — once inline by the named
  Structure's procedure and once by the procedure made for the group's row — and the second
  registration, answering -1, was printed as "out of memory" (confirmed under gdb).
- Style only, by the author's rule repeated on 2026-11-16: the two functions of slice 410
  `lm_compiler_emit_body_with_position` and `lm_compiler_emit_body_statements` lose a needless
  `end:` and a needless fence each; the new functions of this slice are closed by their final
  `return`. The diff adds no `end:` line and no fence and removes seven.

Not reproduced and left as it was: the suspected call ring `own_source_visible → own_code_local`.
The three probe programs are refused earlier ("unsupported loop"): the five-field `for` that
would reach the recursion does not occur in any native fixture.

## What stays red and why

Of the thirteen fixtures this slice aimed at, eight are green and five remain red for other
reasons found on the way:

- `immutable_reached_write`, `place_write_form` — the fixtures use the old order
  `call: code data`; they wait for the migration of the call forms (M10).
- `structure_slot_write` — native is green; the walker answers INVALID on the assignment of a
  Structure to a root whose `implements` refusal a `catch` takes. The minimal program gives the
  same on the G2 of 410: a defect of the walker, not of this slice.
- `callable_place_fields` — native stops on an uncaught throw, the walker answers INVALID; the
  cause is not found yet.
- `written_path_form` — "a constructed child changed source slot" on a record-form through a path;
  probably a form the norm cancelled, to be checked with the fixture migration.

`explicit_data_var_field` now translates and stays red at run time on the old call order;
`written_form` now stops on a `var:` block, as `sub_parts`, `var_own_fields` and `var_own_nested`
do.

## Acceptance on the frozen sources

Freeze Source22: 958 inputs, manifest SHA b62971de99e2cf91858472979c674ef394bcf6b0e2cb80886210e2999a669821,
verify 958/0 for the repository and the stage. The diff of the slice against slice 410 adds no `end:` line
and no fence and removes seven.

- Whole bootstrap, quick, label `boot-f411-01` (G0 — the working tool of 410, previous frontend — the
  hosted candidate `s411-frontend-03` b60a54cb): genuine G1 and actual G1→G2, 9 smoke rows and 0 failures
  each, 20.9 min.
- `fixedpoint411-01`: CHECKS 18 lines, 0 failed — 11 `same` and 3 `exe-same` between G1 and G2, the G2
  runtime objects byte-equal to those of slice 410 (the slice changes the frontend only), and the two
  source verifications.
- Actual G2: working tool `boot-f411-01/lmxtool.exe` 6fd82910, frontend dfbe6110, runtime production
  object 20069522 and observed object d0cd3d64 as in 410.
- Targeted list on the actual G2: SUITE 12 rows, 0 failures, 72 PASS.
- Full suite on the actual G2 (`g2-411-full01`, 17.7 min): **SUITE 192 rows, 108 failures**, 1282 PASS.
  By fixture names 29 are red against 37 after slice 410; none is red that was green. Green again:
  `bound_order_axby`, `bound_typed_reception`, `callable_place_signature`, `entry_admission_order`,
  `formal_defaults`, `map_chain`, `named_actuals_selected`, `whole_arguments`. The list of the 29 is
  `g2-411-full01-red-names.txt`; it is the same list the hosted candidate gave.
- Graph tool on this G2 (`graph-f411-01`, 02f67180): `private_binding` and `call_frame_local`, each
  triple interp / native / forced PASS.
- Mutant (run by sonnet under the pipeline token, label `s411-mutant-01`): the writer without the new
  condition `|| lm_compiler_path_leaf_descriptor(resolved) != 0`. On the list of the fourteen aimed
  fixtures the same eight fixtures are red again with "this reference path"; the mutation was removed
  and the sources verified against the manifest.

Generated L1 and C were not edited by hand; no expectation was weakened; no row was disabled.
Receipts: `build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01`, directories
`sonnet` (component runs, probes, mutant) and `fable` (bootstrap, fixedpoint, G2 runs).

## Baseline of the clean-graph fixtures, taken with this slice

The clean-graph fixtures (`tests/graph`) had been accepted by short lists since about slice 384. A list of
all fixtures that have an `.expected` file and a pinned `graph-check` row was assembled (266 rows; the
expected exit, the number of runs and the interpreter answer of each row come from the latest pinned
list that names the fixture) and run on the actual G2 of this slice (`graph-f411-01`), each row in
interp, native and forced.

Result: **60 pass, 205 fail, 1 does not terminate** (`computed_body_loop`, stopped after 60 s). Almost
every positive program fails, already in the interpreter, with answers 3, 4 or 5 where 0 is pinned; the
refusal fixtures pass. `typeof` and `struct_index`, whose pinned answers the value-record norm quotes,
are among the failing ones: their expectations stand in the files but no run confirms them now.

This is not caused by slices 410 or 411. Five of the failing fixtures were run on the tuple of 410 and
fail the same way. Running `typeof.lm2` in the interpreter on every graph tool kept in the stage gives
the boundary: the tool `graph-call-01` (2026-11-15 19:41) passes with the pinned answers
(`t_cell 2`, `t_uninit 2`, `t_box 13`, `t_null 0`), the tool `graph-frame-01` (20:33) answers 5, and so
does every later one. The commit between them is b901f2bf "Unify Graph DATA and activation-local calls".

Whether each failure is a defect or an expectation the call-frame norm of 2026-11-15 cancelled is not
determined. From this slice on the list is an acceptance gate like the full suite: the 206 names of
`graph-baseline411-red-names.txt` may only shrink. The row-by-row table is `graph-baseline411-result.tsv`;
the runner with the time limit is `graph-baseline411-rows.sh` (the tool's `checks` has no time limit, and
one hanging fixture had stopped the first attempt).

Not in the list: 88 fixtures without an `.expected` file (pinned as refusals; their rows point to files
that do not exist), `post_loop` (does not terminate), and `private_binding` and `call_frame_local`, which
have no pinned row and pass as the two triples above.

## Files beside these notes

The receipts directory is not part of the repository, so the bases of the two acceptance gates are kept here:

- `full-suite-red-names.txt` — the 29 red fixtures of the full suite on the actual G2 of this slice.
- `graph-red-names.txt` — the 206 clean-graph fixtures that do not pass (205 fail, 1 does not terminate).
- `graph-baseline.tsv` — all 266 rows: fixture, pinned exit, pinned number of runs, pinned interpreter
  answer, result on this G2.
- `graph-baseline-rows.sh` — the runner that gives each row its own time limit.
