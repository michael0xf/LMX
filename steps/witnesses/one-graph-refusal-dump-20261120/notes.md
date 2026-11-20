# The check of a refusal row compares the printed graph (the small slice of the row check)

Written 2026-11-20 by Fable, the coordinator and the single writer of main. The change of the tool, the re-pins
and the tables are by the peer session opus (delivered 2026-11-18, four rounds of Fable's corrections); the rows
`receiving_whole_read`, `receiving_whole_read_list`, `copy_descriptor_refused` and the three `c6_*` programs are
by the peer session haiku. Fable set the bounds and the readings (the executor's answer Р104), read the diff,
generated and verified the manifest, compared the delivered hashes with the tree, re-ran every row on the new tool
and repeated the check of the command itself. The slice was built on main `846c5363`; the commits between it and
this one are documents only (nothing under `selfbuild/`).

## The norm

The executor's answer Р104 (`LMX_blog/q/fable-self-answers-20261110.md`), found while step a1 was built: for a
row pinned to a refusal, `graph-check` compared only the interpreter's answer and the fact that the native and the
forced programs did not end with success. All three modes print the graph after the execution, but it was not
compared with the pinned file, so a witness of the kind «after the refusal the observed value is such» was checked
only by the answer. Decision: the printed graph is compared for a refusal row too, in all three modes; a witness
seen only by the interpreter was rejected, because the native image would stay unchecked.

## What changed

- `selfbuild/tools/build.lm2`, `bld_graph_check`: the condition under which the printed graph is compared with the
  expected file was `ok != 0 && expected_exit = 0` and is `ok != 0 && expected_exit != 2`, in the interpreter
  route and in the loop of the native and the forced routes. The graph is compared for a row pinned to success (0)
  and for a row pinned to a refusal of the program (1); a row pinned to a refusal of the construction of the graph
  (2) prints no graph. Two condition lines; the comment above them grows from 5 to 7 lines. Kernel, builder,
  emitter, runtime, frontend and the Graph tool are untouched.
- 47 expected files are re-pinned by rule, by a script, from the old text (`repin-table.tsv`); a row entered the
  package only if the predicted text is equal to the printed graph of all three modes:
  - N-loc, 37 rows: a place declared once as `int: NAME V0` and written only by a bare name keeps its declared
    value in the graph -- locals are not published, only explicit writes change the graph; the pinned `before 1`
    becomes `before 0`;
  - N-rec, 7 rows (20 records): a root declaration whose value is computed stays in the graph as the record as
    written (the author 2026-11-17, an explicit path executes nothing);
  - N-exp, 4 rows (5 places): named places whose value follows from the reading of the program;
  - N-echo, 1 row: a call without arguments in a value is printed `(name)`, not `((name))`.
  Two rows carry two kinds.
- One more re-pin of its own kind: `construction_shape_runtime_guard`, `before 1` to `before 0` and the old 14
  lines indented under `L2:` ... `end: L2`, as the other eight pins of `.lm2` rows.
- Rows by haiku: `receiving_whole_read` -- the program is unchanged, the header is rewritten, the pin goes from
  `1 1 5` to `1 1 3` (ambiguity by the norm: the formal with the empty model takes the group whole, and its fields
  suit two formals); `receiving_whole_read_list` -- new, the twin in the list form, `1 1 3`;
  `copy_descriptor_refused` -- rewritten through an `Observed` group, pin `1 1 5`.
- Headers rewritten, comments only: `open_data_missing`, `deferred_reference_read_refused`, `root_frame_error`,
  `declaration_site_overlap`. No header states the state of its row; header lines are at most 120 characters.
- Three new rows red on purpose: `c6_no_effect_ambiguous` (`1 1 3`), `c6_no_effect_no_pair` (`1 1 4`),
  `c6_one_decl_refused` (`1 1 4`). They pin the norm «the selection of a declaration executes nothing» (`seen 0`);
  today the selection runs the actual (`seen 1`).
- `selfbuild/inputs.list`: 8 new lines (the pairs of the four new rows).
- `literal_line`: the program is unchanged; its expected file is re-pinned by N-rec; the pin stays `1 1 4`, the pin
  of 2026-11-16 (`steps/witnesses/graph-explicit-paths-20261116/pins-changed.tsv`, sequential visibility). Item 6
  of Р104 («pinned to success») is withdrawn; see the correction under Р104.

## Acceptance by the component cycle

This is a component acceptance by the author's order on the build cycle (`to_fable2_fast_build.md`): no whole
bootstrap, no fixedpoint, no full suite and no whole graph list were run.

- Tree against the delivery: the 67 files of the delivered list (57 changed, 8 new, 2 unchanged) have the delivered
  SHA-256 in the git index, checked by Fable by script on 2026-11-20; the staged `selfbuild/inputs.sha256` is
  byte-equal to the manifest generated at the acceptance and to the delivered one.
- Source manifest: 1337 inputs (1329 and 8 new), SHA ad2a31d7…, generated and verified by Fable with the new tool:
  1337/0 for the repository and for the stage.
- Which command built what (opus's record): `build-self` with the hosted frontend `ps-feh-x102` (6d21b7a4) and the
  runtime object `ps-rt-x105/driver.o` (fb58dd3f) gave the tool `ps-tool-r101` (f0e186f4), 46 s. Frontend, runtime
  and the Graph tool `ps-graph-x105` (a7222f8e) are those of step a1; the hashes of the files in the stage were
  re-read by Fable.
- The check of the command, repeated by Fable: `open_data_missing` with one line of a copy of its expected file
  changed (`calls 99` to `calls 98`) fails in interp, native and forced on the new tool and passes in all three on
  the old tool (`ps-tool-x102`, ae2425de); with the true expected file the new tool passes in all three.
- Witnesses, re-run by Fable on the new tool (`witness-rows.tsv`): 275 rows, each in the three modes interp /
  native / forced; 235 pass in all three. The rows are the 216 rows of step a1 and the 59 refusal rows outside
  that list; `refusal-rows.tsv` holds the 117 refusal rows with the pin and the verdict before (old tool) and after
  (new tool).
  - Of the 216 rows of step a1, 215 keep the verdict of that step; `receiving_whole_read` goes from green to red
    in all three modes, on purpose (the new pin). 190 are green (a1: 191).
  - Refusal rows: 113 before, 15 red; 117 after, 20 red. Red by the printed graph, on purpose, in all three
    modes: `receiving_whole_read`, `receiving_whole_read_list` and the three `c6_*` rows. Red by the answer, as
    before the slice: nine in interp only (`declsel_g02`, `deferred_reference_head_refused`,
    `deferred_reference_read_refused`, `marks_ref_code_private`, `reference_model_refused`,
    `computed_body_number_refused`, `declaration_site_missing`, `received_assignment_preflight_refused`,
    `construction_shape_runtime_guard`) and six in all three modes (the five `formal_*_refused` rows and
    `slot_context_reset`).
  - The other 20 red rows are success rows red at step a1 in the same modes: 19 in all three and `declsel_b10`
    in native only.
  - `literal_line` passes in all three modes at its pin `1 1 4`. The delivered list of rows carried a stale pin
    for it (`0 1 0`); the row was run again at the pin of the tree, and the table holds that run.
- Mutant: the check of the command above is the permanent killer of the change -- the old tool is the mutant, and
  it passes the row with the wrong graph.
- Closers: the diff of `tools/build.lm2` adds no `end:` and no `---`; the test files are data.
- One line of the new comment in `tools/build.lm2` is 121 characters wide. It is wrapped with the next edit of the
  file: an edit now would change the manifest of a verified slice.

## Open, not in this step

- The five rows red on purpose wait for the step «the series is the library»: the opened reading of a written
  group enters the selection (`receiving_whole_read`, `receiving_whole_read_list`), and the selection stops
  executing the actual (the three `c6_*` rows).
- `construction_shape_runtime_guard`: today the answer is 4 at the declaration of `@: held opaque`, only when the
  block calls through `held`; by the norm the declaration stands and the call refuses with 5 at its shape before
  any actual. The pin is the norm; the row is red in interp. A defect of callable places.
- Three success rows hold `((name))` in their pins and are not touched here: `code_data`,
  `place_reference_launch` (red at step a1 and in this run, in all three modes) and `own_initializer` (outside the
  275 rows of this run; red in the list of 2026-11-17, `steps/witnesses/m10-throws-graph-20261117`). By opus's
  record they print `(name)` today, with other differences.
- `literal_line` is pinned to the refusal 4: the line of Self reads its own place above the line that declares it.
  The reading «the data place of a Structure launched over itself is declared from the start of the launch» is
  withdrawn. The launch of a Structure over itself is itself withdrawn by the norm of 2026-11-19 (decision R09,
  the data are `parent(C)`), so the row is rewritten at step 5 of the plan `binding-callables-20261119`.
- The pin of a row is a field of its line in a list of the command `checks`; the lists are kept with the receipts.
  In the tree `refusal-rows.tsv` is the record of the pins of the refusal rows after this slice.

## What the running program holds after the step

Nothing changes in a running program: the slice changes the tool that checks rows, and the tests.

## Files beside these notes

- `witness-rows.tsv`: the 275 rows with their verdicts on the new tool.
- `refusal-rows.tsv`: the 117 refusal rows -- the list, the pin before and after, the verdict before and after.
- `repin-table.tsv`: the re-pins by rule -- the kinds and the changed lines of each row; an empty field is `-`.

Receipts outside the repository: `build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01`,
directories `receipts/opus/one-graph/refusal-dump` (`run/RESULT.txt`, `ANALYSIS.txt`, the script of the re-pins,
the manifests of the four rounds), `receipts/haiku/refusal-rows` and `fable` (`accept-rd`, `accept-rd2`,
`tz-20261119/run3/acc_rd_check.log`).
