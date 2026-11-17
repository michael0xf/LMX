# No signs of places in the clean graph: `private:` is a record of the graph

Written 2026-11-17 by Fable (fable_pc), the single writer/build of main. The code of the clean graph (builder,
kernel, interpreter, emitter of the image and of native bodies) and the fixtures are by the peer session sonnet,
who ran the component builds, the candidate runs and the mutants under the pipeline token; Fable set the order,
took the decisions and ran the acceptance gates. Base: slice 420, step 1, `6f75f596`.

## The order of the author

The author, 2026-11-17 (`LMX_blog/2026-11-17.md#no-place-signs`): no signs of places; every hidden datum leaves
the clean graph at once; the walker executes the receiver `private` straight from the clean graph. The same day
(`#clean-graph-only-data`, `#graph-is-data`): all data lie in the storage of a Structure, `length` and `parent`
are derived from the text `toLmx` forms, and every receiver lies in the graph exactly as it is written.

Until this slice the clean graph kept `private:` otherwise. The builder folded the record `private: (int: x 10)`
into its leaf, the int cell of `x`, and set the flag `binding_private` in the row of that cell (the design of
slice 408). The record itself was not in the graph: the dump printed `int: x 10`.

## What changed

Eight measured edits, each with its reproduction, its witness and its mutant:

0. `lmx_graph_assign_int` reads the element through the chain of receiver records. Without it the write
   `shared\Library\x := 33` into a field under a kept record answered 1.
1. The builder, the construction of data and the description of `merge` no longer fold the record into its leaf.
1b. Construction publishes a value inside the innermost place of the chain (`lmx_graph_receiving_place`): the
   records around the place stay. Without it `private: (@: p A)` lost its record at construction.
1c. The emitter of native bodies fetches a statement and reads a local by the leaf of its record. Without it a
   local `private: (int: x 20)` in the body of a `fn` ended natively with an uncaught throw.
2. `lmx_graph_field_private` asks the record (`lmx_graph_receiving_view`), not the flag.
3. `lmx_graph_field_prepare` and `lm_graph_private_copy` are deleted with their calls; the list of machine
   functions of the graph kernel in `tools/build.lm2` loses the first and the tool is rebuilt from it.
4. `lm_graph_emit_field_private` is deleted: the image carries the record, not a flag.
5. The working row of a call holds a pointer to the received record (`row\declared`) instead of bit 128 of
   `row\loaded`; the collector marks it. A distinction is a datum of its own, not a bit.
6. A copy of the graph carries the names of the copied addresses (one mechanism, `lmx_graph_copy_with_names`).
   The copy through the C door used to lose the names of the heads of all Frames; the flag had hidden that.
7. `merge` reads a field of an operand by the leaf of its chain and writes the later value into the copy of
   the place of the model: `merge` of a `private:` or `const:` provider with a plain one gives
   `private: (int: v 2)`, in the other order `int: v 1`. The book: a compatible field of a later operand
   replaces the value of the slot of the model. `merge` used to read such a field as a nested Structure.

After the slice neither a stored `binding_private` nor `loaded & 128` occurs in the modules of the clean graph;
the two remaining `binding_private` are the output parameter of the function that reads the record.

## The criterion, checked on the witnesses

The dump of the field under `private:` before and after the operation (interp; native and forced the same):

| Witness | Before | After |
|---|---|---|
| `private_binding` | `private: ((int x 10))` | the same; the value is read through the record |
| `private_path_write` | `private: ((int x 10))` | `private: ((int x 33))`: a write by a path, the record in place |
| `private_data_write` | `private: ((int x 10))` | the same: a write of the call's data by the bare name |
| `construction_private_ref` | `private: ((@ data_snapshot data))` | the same: construction puts the reference inside |

`graph_copy_names` (a machine row): the copy carries the names of the heads. `graph_merge_receivers` (a
machine row): the record of the first provider stays whole around the place that takes the later value.

## Recorded and not changed here

- A write into the array, `S[i] := p`, replaces the element with what is written, the same before and after
  the slice for an element under `private:`, under `const:` and without a record. The author: it is simply a
  write of a value into the array, without checks.
- A place declared without a value keeps its record of the type without initialization after an assignment:
  after `a := 9` the dump prints `int: a`, a later read gives 9. By the author's decision of the same day an
  assignment changes the type of the record; a separate slice does it (`next_core_tasks_v3.md#typed-nil-plan`).
- A reference local under `private:` in a function answered 3 natively and 9 in the other modes before the
  slice; it answers 9 in the three modes now (edit 1c).
- `lm_graph_emit_model_kind` takes the field of the model whole, so a formal under `private:` loses the
  specialised native path and goes by the general dynamic one; the answers do not change.
- `merge` of a computed declaration under a record is not probed.
- Two new graph fixtures keep one trailer each, `end: Library`: the body of `fn: read` ends two levels deeper
  than the next block, and a drop of two levels needs a closer.
- The sign in the former path of execution (rows `LmxSourceName` of the graph built by generated code, the
  walker, the frontend) is not touched: that path is removed whole by the author's order of the same day
  (`LMX_blog/2026-11-17.md#one-graph`, `next_core_tasks_v3.md#one-graph-plan`).

## Acceptance on the frozen sources

Freeze Source88: 988 inputs, manifest SHA 51180dd43e646adc…, verify 988/0 for the repository and the stage;
the canonical `selfbuild/inputs.sha256` is byte-equal to it.

- Which command translated each changed module from the final sources (sonnet's record): `lmx_graph`,
  `lmx_graph_run`, `lmx_gc_graph` by the runtime build; `l2_graph_build`, `l2_graph_tool` by `build-graph`;
  the frontend was linked after them and built the runtime and the Graph tool of the candidate.
- Whole bootstrap, quick, label `boot-fps-01`: genuine G1 and actual G1→G2, 9 smoke rows and 0 failures each,
  22.2 min. The lists of machine functions changed, so G0 is the candidate tool built from the new
  `tools/build.lm2` (3f543765), the previous frontend the hosted candidate (903ffa17).
- `fixedpointps-01`: CHECKS 18 lines, 0 failed: 11 `same` and 3 `exe-same` between G1 and G2, the G2 runtime
  objects byte-equal to the candidate runtime built by the candidate frontend, and the two source verifications.
- Actual G2: working tool `boot-fps-01/lmxtool.exe` 1443cd6f, frontend 2d445baf, runtime production object f3cf644e and
  observed object d680cc6e.
- Targeted list on the actual G2: SUITE 12 rows, 0 failures, 72 PASS.
- Full suite on the actual G2 (`g2-ps-full01`, 18.6 min): **SUITE 210 rows, 44 failures**, 1450 PASS.
  By fixture names 16 are red, the same names as the base; none is newly red. The two new machine rows and
  `graph_private_binding` are green in every run; `private_hidden_binding`, `walk_private_header` and
  `graph_call_values` stay green.
- Graph tool on this G2 (`graph-fps-01`, 14ebc638): `private_binding` and `call_frame_local`, each triple
  interp / native / forced PASS.
- Clean-graph list, 273 pinned rows (the 269 of the base and four witnesses), each under a 60 s limit:
  **211 pass, 62 fail**, rows over the time limit: 0. Red by names: 62, the names of the base;
  the 269 rows of the base answer as before, row by row.
- Ten mutants (run by sonnet under the pipeline token, each undoing one edit): every one is killed. Two are
  seen only by the machine rows (the working row not taking the record; `merge` without the copy of the leaf
  place), one only in the native mode (the emitter reading a statement raw).
- Closers: the source diff adds no `end:` and no fence.

Generated L1 and C were not edited by hand; no row was disabled.

## Files beside these notes

- `graph-baseline.tsv`: the 273 rows with their results — the new base of the graph gate.
- `graph-red-names.txt`: the 62 red fixtures of the graph list.
- The base of the full-suite gate is unchanged: `../m10-code-places-step1-20261117/full-suite-red-names.txt`.

Receipts outside the repository: `build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01`,
directories `receipts/sonnet/place-signs` (`REPORT.txt`, `steps/`, `run/RESULT.txt`, mutants), `receipts/opus/place-signs`
(the inventory of the former path), `fable` (bootstrap, fixedpoint, G2 runs, graph list).
