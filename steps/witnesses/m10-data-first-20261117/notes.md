# Slice416+417: of the two operands of `call` the first is the data; a name the root of a call's own data declares is a place of the call

Written 2026-11-17 by Fable (fable_pc), the single writer/build of main. The frontend and kernel code is by
the peer session opus, the fixture drafts by the peer session haiku; opus ran the component builds, the
candidate runs and the mutants under the pipeline token, in two measured steps (A = slice 416, B = slice 417
over A); Fable set the order, took the decisions named below and ran the acceptance gates. Base: slice 415
`0a28ec39`.

## What the slice is

Step A. By the book the two-operand call is `call(data code)`
([the table of call forms](../../../docs/spec/LMX_semantics.ru.md#call-receivers); the author's answer 6 of
2026-11-11, `LMX_blog/q/colon-declares-answered-20261111.md`). The working frontend read the two operands the
other way round, the code first: the lowering took the first operand as the code, the native launch evaluated
the code and then the data, the walker evaluated slot 2 of an `EXEC` node (the code) and then slot 1 (the data).
Twelve of the fixture drafts migrated to the norm failed on this after slice 414.

Step B. A Structure called through a callable place received no record of a launch, so the root declarations of
its own data were not asked when a free name of its code was resolved, and the call answered `implements`. And a
write `:=` to a name that only the data of the launch declares was refused at translation, although by the
executor's ruling R38 such a name is a place of the call
([the frame of a call](../../../docs/spec/LMX_semantics.ru.md#call-frame-20261115),
[`:=` writes a known place](../../../docs/spec/LMX_semantics.ru.md#assign-known)).

## What changed

Frontend, step A (`l2_frontend_lower.lm2`, `l2_frontend_emit.lm2`):

- `lm_compiler_struct_call_operands`: of two operands the first is the data and the second the code, in
  `call(D C)` and in `call: D C` alike. The two messages of the operand check name the operands in this order.
- The native launch evaluates the operands in the written order: `lm_compiler_emit_empty_struct_call` evaluates
  and holds the data of a split call before any effect of evaluating the code;
  `lm_compiler_emit_empty_struct_at` receives the number of the held pair and no longer evaluates the data.

Kernel, step A (`lmx_walk_values.lm2`):

- `lmx_walk_select_call_in` evaluates slot 1 of a split call (the data) first, holds it among the execution
  roots, then selects the code of slot 2.
- `lmx_walk_exec_data` evaluates the data as an ordinary operand. Its parameter `callee` and the branch that
  received the operand into the callee are removed: the data is evaluated before the code is selected, so there
  is no callee yet; no builder of the frontend produces such an operand (the trace is in the receipts, "CHANGE
  5"), and with the branch restored the full suite and the 266 graph rows are row by row equal to the candidate.

Kernel, step B (`lmx_walk_values.lm2`):

- `lmx_activation_resolve_input` (K1): a name that the root of the call's own data declares is that place — the
  value of its cell — before the chain of the callers is asked; two such roots make the name ambiguous. It is
  the one road of slice 412, `lmx_activation_data_root_find`, now asked for every entry: `data` is what the
  call was given.

Frontend, step B (`l2_frontend_emit.lm2`):

- `lm_compiler_check_body` (F2): in the code of an ordinary Structure a `:=` whose target is a hidden input made
  by the scan of free names is not refused at translation. The entry resolves the input from the root of the
  launch data, then from the callers' bindings, and refuses the call without either. In a `fn`, `sub`, `catch`
  and in the root of a unit such a target stays the refusal at translation.

Fixtures:

- New witnesses, each with its full-suite row: `call_data_first` (step A; every code and every operand writes
  its digit into a log of the root, so the value names which Structure ran as the code and in which order the
  operands were evaluated), `place_struct_root_input` (W1: a Structure written into a callable place and called
  through it reads its own root `int: i 5`), `launch_data_root_free` (W2, a control: `call(D C)` whose code
  reads a name only the root of `D` declares), `assign_launch_data_root` (W3: `got := data\i` writes the
  call's place `got`, and `Data\got` stays 0 — nothing is written back).
- Migrated to the new order with unchanged checks: `data_source_cells`, `structure_slot_write`,
  `var_ordinary_child`.
- Migrated with changed pinned values (`values-changed.tsv`; drafts of haiku, decided by Fable before the run):
  `code_write_words` and `unit_n4_inline_named_rebind` pinned `D\T\v` as written by the call; by the book a
  form `T:` in executed code is a call of its head and a frame is not published into the graph
  ([declaration or call](../../../docs/spec/LMX_semantics.ru.md#colon-declares),
  [frames are not published](../../../docs/spec/LMX_semantics.ru.md#flush-receiver-contract)), so `D\T\v` stays the
  declared 0.
- `assign_in_structure_refused` (draft of haiku): the row of a translation refusal becomes a row `runs 7`. `zz
  := 5` in the code of `Holder` is no translation error; the launch of `Holder` over itself has no place `zz`
  and is refused at entry, the refusal is caught as `implements`. A control in the same file launches the same
  write over data whose root declares `zz` and observes 5 through `data\seen`.

## Decisions taken on the way (Fable)

- 416 and 417 are one slice in two measured steps: the drafts that wait for 417 are written in the new order,
  and the witnesses of 417 need the launch `call(D C)` of 416. Step A has its own results and a fallback point
  in the receipts.
- The values 1 and 2 that two fixtures pinned for `D\T\v` recorded the cancelled publication of a call
  into its data; the new value is the declared 0 (R37).
- The branch of `lmx_walk_exec_data` that received the data into the callee goes with the reorder: its
  condition cannot be asked before the code is selected, and it had no producer.
- Only drafts green in every mode enter the tree. Nine red fixtures therefore still hold the text of the old
  order (listed below); their mechanical flip is scheduled for the next slice, where they stay red for their
  own causes.
- `free_index_places`: the draft is green with a respelling of line 112, `Box: ([]: int items 2)` to `Box: []:
  int items 2`, that haiku's notes did not declare. The respelling is lawful — brackets around the content of a
  Structure make one anonymous Structure inside it
  ([the book](../../../docs/spec/LMX_semantics.ru.md#colon-declares)), so the path `Box\items` named nothing — but
  the sources were frozen for the bootstrap already; the fixture goes into the next slice with the reason
  recorded.

## Left red, recorded and not fixed here

- 22 fixtures are red: the 24 of the base without `code_write_words` and
  `unit_n4_inline_named_rebind`. None is newly red (`full-suite-red-names.txt`).
- Nine of them hold the old operand order in the tree, so their first failing line changed with step A:
  `held_structure_places`, `place_map`, `place_write_form`, `source_occurrences`, `split_copy_bound_data`,
  `split_formal_data`, `split_selected_code`, `unary_data_selection`, `unit_n4_inline_named_incompatible`.
- Two changed their first line with F2: `explicit_data_var_field` passes translation and fails at run (4
  failures in place of 2), `immutable_reached_write` fails at translation on a later line (136:10).
- The typed gap of F2: `zz := int: 5` in the code of an ordinary Structure is still refused at translation. The
  scan of free names reads the target of `:=` only for an untyped assignment, so no hidden input is made for the
  typed one. The row of `assign_typed_unknown_structure_refused` stays a translation refusal and is green.
- The side finding of slice 415 is not closed: a local declared in the root of the code of a Structure launched
  over other data fails in the native executor ("a split-called code reached data without its place row") and
  with INVALID in the walker. The layer is the native entry check of a split-called code, which demands every
  place of the code's table from its data; the same check now shows in `held_structure_places`,
  `place_write_form`, `unit_n4_inline_named_incompatible`, `explicit_data_var_field`.
- The drafts that were marked "waits for 417" give the same first lines in step A and in step B: their cause is
  neither the operand order nor K1/F2. `split_copy_bound_data`, `split_formal_data`, `split_selected_code` are
  green in the walker and INVALID in the native executor (a code's own input without a value over its data).
- `var_own_fields` and `var_own_nested` fail at translation as in the base ("unknown field path segment") and
  do not reach K1.

## Acceptance on the frozen sources

Freeze Source46: 969 inputs, manifest SHA c8b3adeeefd1ec4a…, verify 969/0 for the repository and the stage; the
canonical `selfbuild/inputs.sha256` is byte-equal to it.

- Whole bootstrap, quick, label `boot-f417-01`: genuine G1 and actual G1→G2, 9 smoke rows and 0 failures
  each, 20.0 min. G0 is the accepted tool of slice 415 (89dd8b75; no list of machine functions, export name or
  recipe text changed), the previous frontend the hosted candidate `s417-frontend-01` (a12a9cbc).
- `fixedpoint417-01`: CHECKS 18 lines, 0 failed: 11 `same` and 3 `exe-same` between G1 and G2, the G2
  runtime objects byte-equal to the candidate runtime `s417-rt-01`, and the two source verifications.
- Actual G2: working tool `boot-f417-01/lmxtool.exe` 7b439b6f, frontend e894a343, runtime production object a73c6987
  and observed object 75eee8d7.
- Targeted list on the actual G2: SUITE 12 rows, 0 failures, 72 PASS.
- Full suite on the actual G2 (`g2-417-full01`, 17.7 min): **SUITE 203 rows, 68 failures**, 1384 PASS.
  By fixture names 22 are red, a subset of the 24 of the base; none is newly red. The four new witnesses and
  the six migrated fixtures are green.
- Graph tool on this G2 (`graph-f417-01`, d3d10165): `private_binding` and `call_frame_local`, each triple
  interp / native / forced PASS.
- Clean-graph list, 266 pinned rows, each under a 60 s limit: 177 pass, 88 fail, 1 does not
  terminate; the same 89 names as the base, none newly red.
- Mutants (run by opus under the pipeline token, each undoing one change):
  1. the lowering takes the first operand as the code: `call_data_first` exits 81 in all four runs;
  2. the native launch evaluates the code first: `call_data_first` exits 83 in the native runs, the walker is
     green;
  3. the walker of slice 415: `call_data_first` exits 83 in the forced runs, the native executor is green;
  4. K1 undone: `place_struct_root_input` is red in all four runs (an uncaught throw of the free root input);
     the launch `call(D C)` already has the record of slice 412, so W2, W3 and `assign_in_structure_refused`
     stay green — K1 is needed only for a Structure reached through a callable place;
  5. F2 undone: `assign_launch_data_root` (10:5) and `assign_in_structure_refused` (13:5) are refused at
     translation.
- Closers: the diff of the sources adds no fence and no `end:` line and removes one `end:` line and four
  fences. In the fixtures one fence is added in `assign_in_structure_refused` (the opening fence of an anonymous
  block whose closing fence drops two levels) and one in the new `place_struct_root_input` (line 10, two levels
  after `return: 1`).

Generated L1 and C were not edited by hand; no row was disabled. The changed expectations are listed beside
these notes.

## Files beside these notes

- `values-changed.tsv`: the changed pinned values and the changed row.
- `full-suite-red-names.txt`: the 22 red fixtures — the new base of the full-suite gate.
- The base of the graph gate is unchanged: `../graph-explicit-paths-20261116/graph-red-names.txt` (89 names) and
  `graph-baseline.tsv` there; the runner is `../m10-call-launch-20261116/graph-baseline-rows.sh`.

Receipts outside the repository: `build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01`,
directories `receipts/opus/s416` (README.txt, the diff, `run/stepA-result.txt`, `run/stepB-result.txt`, mutants,
probes), `receipts/opus/s417`, `receipts/haiku/dyn-ready416` and `dyn-ready417` (drafts), `fable` (bootstrap,
fixedpoint, G2 runs, graph list).
