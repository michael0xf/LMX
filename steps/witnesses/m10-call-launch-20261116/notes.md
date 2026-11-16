# Slice412: one launch for `call`, a Structure run over itself, a declaration in a nested block of the root

Written 2026-11-16 by Fable (fable_pc), the single writer/build of main. The kernel code is by the peer
session opus, the frontend code by the peer session sonnet, the fixture migrations by the peer session
haiku; opus ran the component builds, the candidate runs and the mutants under the pipeline token; Fable
set the order, took the decisions named below and ran the acceptance gates. Base: slice 411 `deccd307`.

## What the slice is

Step 3 of M10: the native `call:` statement and the walker launch a Structure through one kernel entry,
`lmx_call_launch`, and the receiver no longer selects a part inside the Structure it is given. The slice
also repairs the walker defect that slice 411 found on its way.

## What changed

Kernel (`lmx_walk_values.lm2`, `lmx_call.lm2`, `tools/build.lm2`):

- `lmx_call_launch` replaces `lmx_call_selected_structure`; the latter is removed together with its
  prototype in the text an emitted program sees. `lmx_call_unary_data` no longer selects the `var` child
  of an ordinary Structure: `call(C)` is `call(C C)`, the data of the launch is `C` itself
  ([the book, the receivers `call` and `fncall`](../../../docs/LMX_semantics.ru.md#call-receivers)).
- One function `lmx_call_launch_rows` forms the input vector a launched `fn`/`sub` enters with, sized by
  its header: a formal the launch writes no actual for takes its current default or stays absent, with no
  refusal. Both executors call it. Without it the native trampoline of a function reached through a
  callable place was called with no inputs and aborted on its arity guard; the guard is unchanged.
- The record of a launch names the root declarations of its data: a free name of the body that is not
  among the supplied actuals is looked up there before the search goes up the chain
  (`lmx_activation_data_root_find`). Order: formals, actuals, roots of the data, inherited free inputs,
  parent. Two same-named roots end the search without binding a foreign name. This is the kernel's part
  of the norm that a call's namespace is made of the declarations of the roots of `data` and `code`
  ([the call frame](../../../docs/LMX_semantics.ru.md#call-frame-20261115)); the frontend's static place map stays
  the fast path where it exists.
- Walked root: the two rules that create a local binding excluded every holder inside the frame's source
  and node. In a walked root the code, the source and the node are one Structure, so every declaration of
  a nested block of the root (`int: x 0` inside `if:`) was refused with INVALID. The exclusions now apply
  only where the source or the node is another Structure than the code.
- Style: `lmx_walk_input_origin` and `lmx_walk_input_origins` of slice 410 lose a needless `end:`. The
  diff adds five fences, each closing more than one level, and no `end:` line.

Frontend (`l2_frontend_lower.lm2`, `l2_frontend_context.lm2`):

- `lm_compiler_emit_current_structure`, the only emitter of the old entry, emits `lmx_call_launch` with
  empty values, count and plan: the `call:` statement takes `code` and `data code` only.
- `lm_compiler_own_code_local`: a root declaration that the Structure's constructor filled is not a CODE
  variable that gets its value at its declaration; it is loaded from the cell of the run's data by the
  common path. Before, such a declaration was skipped when reached and its working value stayed empty; a
  field of a `var:` block was loaded because it lay in another part.

Fixtures:

- New `tests/dyn/root_block_declaration.lm2` with its full-suite row: the witness of the walked-root fix.
- Migrated, by the norm and not by the run: `named_call_below_os`, `named_call_below_unit` (the place
  `int: n 3` stands in `Counter` itself; the `var:` block, the former name of `data`, is not selected by a
  unary call), `callable_place_signature`, `formal_defaults`, `bound_order_axby` (each expected the
  cancelled refusal of an input without a value; only that expectation is removed, the form `call: Hw`
  stays).

## Decisions taken on the way (Fable)

- A fixture that was green and turns red only because it expected a cancelled refusal or the cancelled
  `var` selection is migrated in the same slice; any other reddening stops the slice.
- The twins are not left red: the kernel got the lookup among the roots of the launch's data, the
  frontend the load of a constructor-filled root declaration. Each is a general path; neither has a branch
  for the unary call.
- A claimed translator defect (a stray generated header changing the translation of the walker) was
  withdrawn by opus within the hour: his standalone runs had the stage root as the working directory, and
  the `predef` paths are relative to `<stage>/src`. Fable had passed the claim on unverified.

## Left for later, recorded and not fixed here

- A Structure formal without a value meets the admission of the native trampoline and answers
  `implements`; by the norm an absent input has nothing to admit. The path is shared with the static call.
- The frontend still collects a `var` child of a named Structure as its written data and still knows the
  reserved name `var` as the implicit data input; a lawful program can reach a native invariant instead of
  a translation error. To be removed with the migration of the fixtures that use `var:` blocks.
- Two same-named roots of a launch's data stop the free-name search with the status of an unresolved free
  input, not with the status an ambiguous path gives.

## Acceptance on the frozen sources

Freeze Source29: 959 inputs, manifest SHA fe326e0cc05894ada0e0cab584f75e308b2e5356e4efb6ab51e08b27e7f6c4e1,
verify 959/0 for the repository and the stage.

- Whole bootstrap, quick, label `boot-f412-02`: genuine G1 and actual G1→G2, 9 smoke rows and 0 failures
  each, 19.2 min. G0 is the hosted candidate tool `s412-tool-01` (bbc1b958), the previous frontend the
  hosted candidate `s412-frontend-03` (721e17ee). The first attempt `boot-f412-01` with the tool of slice
  411 as G0 failed within a minute at G1's runtime: the lists of kernel functions passed as `--machine`
  live in the tool, and the old tool still named `lmx_call_selected_structure`. A slice that changes
  those lists needs a tool built from the new `tools/build.lm2` as G0.
- `fixedpoint412-02`: CHECKS 18 lines, 0 failed — 11 `same` and 3 `exe-same` between G1 and G2, the G2
  runtime objects byte-equal to the candidate runtime `s412-runtime-06`, and the two source verifications.
- Actual G2: working tool `boot-f412-02/lmxtool.exe` c99879ae, frontend d7167335, runtime production
  object 8d7b0805 and observed object eb8c4b47.
- Targeted list on the actual G2: SUITE 12 rows, 0 failures, 72 PASS.
- Full suite on the actual G2 (`g2-412-full01`, 17.1 min): **SUITE 193 rows, 106 failures**, 1290 PASS.
  By fixture names 28 are red against 29 after slice 411; none is red that was green; green again:
  `structure_slot_write`. The new `root_block_declaration` and the five migrated fixtures are green. The
  list is the same the hosted candidate gave.
- Graph tool on this G2 (`graph-f412-01`, 9594dee3): `private_binding` and `call_frame_local`, each
  triple interp / native / forced PASS.
- Clean-graph list, 266 pinned rows, each under a 60 s limit: 60 pass, 205 fail, 1 does not terminate —
  the same 206 names as the base of slice 411, none newly red. The slice does not touch
  `lmx_graph_run.lm2`; the repair of that list is the next slice.
- Mutants (run by opus under the pipeline token, each in its own stage copy of Source29; the repository
  and the stage verified 959/0 afterwards):
  1. the launch hands the body the code as its data — `data_source_cells` red, native and forced;
  2. both walked-root conditions back to their text before the slice — `root_block_declaration` and
     `structure_slot_write` red at the walked root in both executors;
  3. the lookup among the roots of the launch's data off — the twins red again, 12 and 8 failures.
- Closers: the diff adds five fences, all in `lmx_walk_values.lm2`, each closing more than one level
  (four close two levels, one closes three), and no `end:` line; the migrated fixtures add none.

Generated L1 and C were not edited by hand; no row was disabled; the only expectations changed are the
five migrated fixtures named above, each by a cited norm.

## Files beside these notes

- `full-suite-red-names.txt` — the 28 red fixtures of the full suite on the actual G2 of this slice.
- `graph-red-names.txt` — the 206 clean-graph fixtures that do not pass.
- `graph-baseline.tsv` — all 266 rows: fixture, pinned exit, pinned number of runs, pinned interpreter
  answer, result on this G2.
- `graph-baseline-rows.sh` — the runner with a time limit per row; stage, tool and output label are
  arguments.

Receipts outside the repository: `build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01`,
directories `opus/run412` (STATUS.txt, component builds, candidate runs, mutants), `sonnet/s412` and
`sonnet/s412c` (frontend changes), `receipts/haiku/tests` (fixture drafts), `fable` (bootstrap, fixedpoint,
G2 runs, graph list).
