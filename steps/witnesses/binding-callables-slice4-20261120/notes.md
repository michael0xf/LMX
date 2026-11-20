# A nested declaration takes its own place (slice 4 of the norm «binding and callables»)

Written 2026-11-20 by Fable, the coordinator and the single writer of main. The change of the kernel, the eight new
rows and the first measurements are by the peer session opus (delivered 2026-11-20). Fable set the bounds (section C
of the [record of step 1](../binding-callables-step1-20261119/notes.md)), read the diff, compared the delivered
hashes with the tree, re-pinned one row, generated and verified the manifest, rebuilt the runtime, the Graph tool
and the hosted frontend from the tree, re-ran every row and every probe and repeated the mutants. The slice was
built on main `3fbd0273`.

## The norm

The author's TZ of 2026-11-19, `docs/new_parts/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md`, decision R16
and §7.1–§7.4: a declaration on a nested level shadows the outer declaration of the same name; on one level there
is nothing to shadow, the existing place is used, and a repeat without a right-hand side keeps the value; after
the nested area is left the outer binding is seen again; a name used before its own declaration is resolved
outside. The control example of §7.4 is read by the executor's answer Р106
(`LMX_blog/q/fable-self-answers-20261110.md`): a new `int: x` without a right-hand side in a nested inline block
stays `uninit:int`, and reading it refuses with the answer 5.

Before the slice a declaration reached in a nested block took the visible row of its name from any enclosing
level: `int: x 9` in the body of `if` wrote the outer `x` (rows B24 and the control of §7.4 in the record of
step 1).

## What changed

- `selfbuild/src/l2src/lmx_graph_run.lm2`, one function, `lmx_graph_work_site`, +12 −12 lines:
  - the branch «take the visible row of the name from any enclosing level» (through `lmx_graph_work_row`) is
    removed;
  - a reached declaration looks for a row of its name only on the lexical level it stands on
    (`row\scope = frame\lexical_scope`) and only among the rows already declared in this entry of the level
    (bit 16 of `row\loaded`, the bit the function itself sets and the leaving of a block clears);
  - the place of the data of the call is taken by name only on the root level of the code
    (`frame\lexical_scope = frame\body`); a declaration on a nested level never takes it;
  - otherwise the level gets its row again (a loop body on the next pass) or a new row of the activation.
  The six comment lines above the function are rewritten; no line is wider than 120 characters. The diff adds no
  `end:` and no `---` and removes two `---`.
- Eight new rows, `selfbuild/tests/graph/bind_*` (16 lines in `selfbuild/inputs.list`):

  | Row | Pin | Observed | TZ |
  |---|---|---|---|
  | `bind_inner_same_type` | `0 1 0` | `seen 5` | B24, R16 |
  | `bind_inner_read` | `0 1 0` | `seen 95` | R16 |
  | `bind_inner_other_type` | `0 1 0` | `seen 5` | B24 |
  | `bind_inner_loop` | `0 1 0` | `seen 205` | R16, a loop body |
  | `bind_inner_over_data` | `0 1 0` | `seen 95` | R16, over a place of the data |
  | `bind_same_level_repeat` | `0 1 0` | `seen 57` | B25 |
  | `bind_before_own_decl` | `0 1 0` | `seen 507` | B26 |
  | `bind_inline_new_local` | `1 1 5` | `seen 0`, answer 5 | §7.4, Р106 |

  The rows are written in the former forms `fn: f () int` and `sub: main ()`; they are migrated at step 8 of the
  plan with the other examples.
- `selfbuild/tests/graph/declaration_site_projection`, re-pinned by Fable: `inline_seen` 7 becomes 1, and the header
  is rewritten. The program is unchanged. The former header pinned the rule «a declaration of a visible name in
  code assigns the existing place» for all three declarations of the row. For `int: x 2` and `int: x 3`, which
  stand on the root level of the code, nothing changes (`D\x` stays 10, `seen` 10). `int: x 7` stands in the block
  of `if`, a nested level: by R16 it is its own place, the read after the block sees the outer `x`, and `seen` of
  `Inline` is 1. The reason is recorded as the executor's answer Р109.

## Acceptance by the component cycle

This is a component acceptance by the author's order on the build cycle (`to_fable2_fast_build.md`): no whole
bootstrap, no fixedpoint, no full suite and no whole graph list were run.

- Tree against the delivery: the 18 delivered files (the module, `inputs.list`, the 16 files of the new rows) have
  the delivered SHA-256 in the tree; the manifest of the acceptance differs from the delivered one by the two files
  of the re-pinned row only.
- Source manifest: 1353 inputs (1337 and the 16 new), SHA b8184d26…, generated and verified by Fable with the tool
  `ps-tool-r101` (f0e186f4): 1353/0 for the repository and for the stage.
- Runtime and Graph, rebuilt by Fable from the tree with the hosted frontend `ps-feh-x102` (6d21b7a4):
  `build-runtime` gave `fable-s4-rt01` (driver.o 48581a2a, driver-observe.o b384896b), byte-equal to the delivered
  objects; `build-graph` gave `fable-s4-graph01/graph_trans-prod.exe` (610e69f4), equal to the delivered tool
  (606c91b7) after the two build fields of the PE header, TimeDateStamp and CheckSum, are zeroed.
- Hosted frontend from the final sources. The helper reported that the frontend does not depend on the edit and
  did not rebuild it. The claim was not accepted without a run: the builder of the graph is linked into the hosted
  frontend, and in the generated C of the runtime the changed function is reached by direct calls from both entries
  the frontend calls, `lmx_graph_construct` and `lmx_graph_preflight` (through `lmx_graph_space_declare`,
  `lmx_graph_receiver_bind`, `lmx_graph_block`, `lmx_graph_place_site`). Fable ran `build-frontend-host` on the
  tree: `fable-s4-feh01/l2trans.exe` (aa4b75fb). `build-runtime` with this frontend gave `fable-s4-rt02`: the
  generated `driver.c`, `driver.o` and `driver-observe.o` are byte-equal to `fable-s4-rt01`, so the translation of
  the kernel by the new frontend is the same. `build-graph` with this frontend and this runtime gave
  `fable-s4-graph02/graph_trans-prod.exe` (d5a1b4c9), equal to `fable-s4-graph01` after the same two fields are
  zeroed. The working set after the slice is the one built wholly from the final sources: the tool `ps-tool-r101`,
  the frontend `fable-s4-feh01`, the runtime `fable-s4-rt02`, the Graph tool `fable-s4-graph02`.
- Rows, run by Fable twice, each row in the three modes interp / native / forced: on `fable-s4-rt01` and
  `fable-s4-graph01` with the frontend of the base, and on the working set built from the final sources. The two
  runs give the same verdict in every mode of every row; `witness-rows.tsv` holds it in the column «after». There
  are 334 rows -- the 275 rows of the acceptance of 2026-11-20
  (`../one-graph-refusal-dump-20261120/witness-rows.tsv`), the 51 rows of the helper's small list outside them and
  the 8 new rows. The verdict «before» is Fable's run of the 275 rows on the base and, for the other 59 rows, the
  helper's run on the same base; the 67 rows present in both runs have the same verdict in both. No row ran into
  the time limit.
  - Green in all three modes: 266 before, 273 after. By list: 235 → 236 of 275, 29 → 29 of 51, 2 → 8 of 8.
  - Seven rows change the verdict, all from red to green. Six are new rows, red in all three modes before:
    `bind_inner_same_type`, `bind_inner_read`, `bind_inner_other_type`, `bind_inner_loop`, `bind_inner_over_data`,
    `bind_inline_new_local`. The seventh is `construction_shape_runtime_guard` (pin `1 1 5`), red in interp
    before: the interpreter answered 4 at the declaration `@: held opaque` and now answers 5 at the call, as the
    pin says. The removed branch was the cause: on the mutant that restores it the interpreter answers 4 again.
  - `bind_same_level_repeat` and `bind_before_own_decl` are green before and after.
  - `declaration_site_projection` is green in all three modes at the new pin (before: green at the former pin).
    `literal_line` is green at its pin `1 1 4`.
  - No other row changes. The 61 red rows are red in the same modes as before the slice: 19 refusal rows and 20
    success rows of the 275 (the lists are in the notes of the acceptance of 2026-11-20, without
    `construction_shape_runtime_guard`) and 22 success rows of the small list, all of them in the red base of the
    graph list (`../one-graph-level2-record-20261118/graph-red-names.txt`).
- Probes in the interpreter, on the Graph tool of the base and of the slice (`probes.tsv`): the helper's 14 are
  reproduced with the delivered values; Fable's nine more give the values derived from the norm before the run and
  pass as rows in all three modes, on both sets, with the graph printed by the interpreter as the expected file:
  two nested levels (333 → 395), a declaration in `else` (99 → 95), a repeat on the nested level (944 → 945),
  a write by the bare name in a block without a declaration (8 → 8), a write after the nested declaration
  (8 → 5), two sibling blocks (977 → 575), a callee called from the block (99 → 95) and after it (9 → 5), a write
  in a loop body (210 → 205).
- Rows B22 and B23 (one's own default; a computed default is not executed by the entry) conform before and after:
  the probes of step 1 `b22_default` and `b23_computed_default` give 703 and `ticks 0 seen 3 unused 1` on the
  Graph tool of the base and of the slice in the interpreter, and on the working set they pass as rows in all three
  modes. They are not pinned as rows by this slice.
- Mutants, built by the helper, the eight new rows re-run by Fable in the interpreter: m1 (the removed branch
  restored) moves six of the eight rows off the pin; m2 (the data place taken on any level) moves
  `bind_inner_over_data` (99 instead of 95). The helper's logs show both killed in all three modes.
- Emitter: the native image calls the kernel function for a declaration, so the emitted C of the rows is
  byte-equal before and after (the helper's check, `run/emitter-check.txt` in the delivery); the native and the
  forced verdicts above come from the new runtime object.

## Open, not in this step

- A declaration on the root level of the code over a name of the data of the call takes the place of the data, as
  before the slice: with the formal `x` equal to 5, `int: x 9` on the root level gives 9 and `int: x` without a
  right-hand side gives 5 (`p2_formal_root`, `p2_formal_root_then_read`, `p2_datapart_root` in `probes.tsv`).
  Whether the root level of the code is one level with the data or a level nested in them follows from step 5 of
  the plan (the data are `parent(C)`). The program that tells the readings apart: `fn: f (int: x)` with `int: x`
  without a right-hand side on the root level, called `f(5)`; today the read gives 5, under the other reading it
  refuses. Recorded in the plan and in Р109.
- D5 of the record of step 1, a repeat on one level with another type: the slice keeps the refusal 4
  (`g14_same_level_other_type`).
- B22 and B23 have no pinned row yet; they are pinned with slice 2, whose autofill they bound.
- The row `post_loop` hangs before and after the slice (the helper's record); it is in none of the lists above
  and is not analysed.
- The 22 red rows of the small list and the 39 red rows of the 275 are not touched by the slice.

## What the running program holds after the step

A declaration reached in a nested block of a code -- the body of `if`, of `else`, of a loop -- gets a row of its
own in the activation, on the level of that block. Inside the block, after the declaration, a read and a write by
the bare name go to this row; before the declaration, and after the block is left, the name is the outer place,
whose value the block did not change. A loop body gets its row again on every pass, and the declaration
initializes it again. A callable called from inside the block finds this row as the visible place of the calling
activation. A repeat of the declaration on the same level works with the same row and, without a right-hand side,
keeps its value. Nothing is appended to the data of the call.

## Files beside these notes

- `witness-rows.tsv`: the 334 rows -- the list a row comes from, its pin, the verdict before and after.
- `probes.tsv`: the 25 probes -- the value on the Graph tool of the base and of the slice, and the three modes for
  Fable's nine and for the two probes of step 1; an empty field is `-`.

Receipts outside the repository: `build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01/fable`,
directories `tz-20261119/slice4` (the delivery: `REPORT.md`, the diff, the manifests, the probes, the logs of the
runs and of the mutants) and `tz-20261119/accept-s4` (the acceptance: the manifest, the build logs of the runtime,
the Graph tool and the frontend, the lists and the logs of the two runs of the 334 rows -- `acc.log`, `acc2.log`
-- and of the probe rows, the probes and their outputs, the mutant table, the reachability script).
