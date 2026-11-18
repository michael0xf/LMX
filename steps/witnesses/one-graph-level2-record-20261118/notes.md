# One graph, steps L0 and L1: the programs of L3 are `.lm3`; the level of code is the record `L2`

Written 2026-11-18 by Fable (fable_pc), the single writer/build of main. The renames, the code of the builder, the
kernel, the interpreter, the emitter and the frontend, and the new fixture are by the peer session opus, who ran the
component builds, the candidate runs and the mutants under the pipeline token; Fable set the order, took the
decisions and ran the acceptance gates. Base: the slice of the typed literals, `2ecd7fcb`, and its note `c81f5b61`.

## The norm and the state before

The book, #scope: «Код L2 пишется под ресивером `L2:`; его запись лежит в графе как записана, и по ней транслятор и
интерпретатор узнают уровень кода. Файл `.lm2` сам по себе как обёрнут в этот ресивер». The author, 2026-11-17: the
receiver `L2` exists; an `.lm2` file is as if wrapped in it.

The author's order of 2026-11-18 came while this slice was being accepted: the rule «the interpreter executes only
L3» leaves the documentation; the interpreter executes L2 code with the same checks as L3 code, and native L2 code
is compiled without them (`LMX_blog/2026-11-18.md`). The code of the slice was written before the order and is
accepted as it stands; what the order adds is named below as not done.

Before the step the builder of the clean graph did not read the extension of a file at all: a copy of one program
named `.lm2` and `.lm3` gave the same graph. `L2:` was no word of the language: a block under it was built as a
Structure of that name, and its code did not run. Every program of `tests/graph` was an `.lm2` file.

## L0: the programs without L2-only forms are `.lm3`

- 365 files `tests/graph/NAME.lm2` are renamed `NAME.lm3`, byte for byte: every program of `tests/graph` with no
  L2-only form -- `c.X`, `cast:`, `include:`, `predef:`, `define:`, `os:`. 275 of them are rows of the graph list,
  90 are no row.
- 8 programs hold such forms and stay `.lm2`: `cdoor_declarations`, `construction_shape_controls`,
  `construction_shape_runtime_guard`, `fn_return_forms`, `formal_declarations`, `receiving_group_roles`,
  `receiving_names`, `receiving_unknown_door`.
- No `.expected` is renamed or changed by L0. `inputs.list`: 365 lines changed.
- The runner of the graph list beside these notes (`graph-baseline-rows.sh`) names a row by its source without
  `.lm2` or `.lm3`; it is the runner of `m10-call-launch-20261116` with that one line changed.
- The former frontend still refuses a source that is not `.lm2`; no program of the full suite is renamed.

## L1: the record `L2`

- The builder (`l2_graph_build.lm2`): for a path ending in `.lm2` the root holds one field, the record `L2` -- an
  Lmx named by the receiver `L2` -- and the record holds the fields of the file, each built as a field of the root
  is. An explicit `L2:` is a statement of the receiver `L2` of the language, built by the ordinary path.
- The kernel (`lmx_graph.lm2`): `L2` is a word of the language; `lmx_graph_file_code` answers the code of a file --
  for a Structure whose only field is the record `L2`, the record, and so for a record nested alone in it; for any
  other Structure, the Structure itself. It is the one place where the level is read; the 88th exported function.
- The interpreter (`lmx_graph_run.lm2`): `lmx_graph_call` runs the code of the file -- its namespace, its native
  entry and its activation are the record's.
- The emitter (`l2_graph_tool.lm2`): the image copies the whole graph from the root; the native body, the methods
  and the entry are the code's, installed on the image of the record. A plain `emit` of a wrapped file gives the
  root the entry `lm_graph_file`, which enters the file by `lmx_graph_call`.
- Route 331 (`l2_frontend_graph.lm2`): a machine module is an `.lm2` file and is translated from its code.
- `tools/build.lm2`: the word `w_l2` of the state; the list of `lmx_graph` grew from 87 to 88 exported functions.

The executors pass through the record that is the whole file: the content of a wrapped file runs as it ran, and
every row of both suites keeps its answer. By the order of 2026-11-18 the interpreter executes the code under a
record `L2` wherever it stands; this slice does so only for the record that is the whole file.

## The dump and the seven `.expected`

The record prints as any block does, by the existing rule of the dump: a first line `L2:`, the content one level
deeper, a last line `end: L2`. Seven `.expected` of the `.lm2` programs with exit 0 were rewritten by that one rule
from their old text, not from a run -- `cdoor_declarations`, `construction_shape_controls`, `fn_return_forms`,
`formal_declarations`, `receiving_group_roles`, `receiving_names`, `receiving_unknown_door`. Checked by Fable against
`c81f5b61`: each new file is `L2:`, every old line with four more spaces, `end: L2`, and nothing else. For example
`cdoor_declarations.expected`:

    before                                                   after
    include: "<stdio.h>"                                     L2:
    predef: "l2src/lmx_schedule.h.lm1"                           include: "<stdio.h>"
    fn: f (@: s c.LmxSchedule; ulong: limit; int: a) int         predef: "l2src/lmx_schedule.h.lm1"
        return: (a + 1)                                          fn: f (@: s c.LmxSchedule; ulong: limit; int: a) int
    end: f                                                           return: (a + 1)
    int: r 5                                                     end: f
                                                                 int: r 5
                                                             end: L2

The runs agree: six of the rows pass in the three modes; `fn_return_forms` is red in the three modes as in the base.
`construction_shape_runtime_guard` pins exit 1, its dump is not compared and its `.expected` is unchanged.

New fixture `level2_record_file.lm3` (pins 0 1 0): a file written whole under an explicit `L2:` holds the same record
as a wrapped `.lm2` file; the run passes through it and the write through the explicit path takes place. On the
accepted tool the same text answered 3. Its `.expected` is the accepted tool's dump of the same content written
without `L2:`, wrapped by the rule above.

## Seven machine rows of the full suite

`tests/dyn/graph_call_frames`, `graph_call_values`, `graph_copy_names`, `graph_fn_data_typed`, `graph_merge_receivers`,
`graph_private_binding` and `graph_scalar_working` write a program into a file, build it by `lm_graph_build_file` and
read the fields of the root. They named that file `.lm2`; with the wrap the fields moved into the record and the rows
went red (opus's run before the change: 210 rows, 72 failures, 23 names). The generated texts hold no L2-only form
(0 of 22 strings), so by the rule of L0 they are programs of L3: the rows now name the file `.lm3` (34 names in
string literals, nothing else). The rows themselves are machine code of L2 and stay `.lm2`. Decision of Fable,
executor's answers R50.

## Removed from the slice: no row told them

Three edits of the first candidates were taken out again, because the mutant undoing each survived every row: a rule
of the dump printing a record `L2` always as a block (the existing rule already prints it so); a branch of the
builder for an explicit `L2:` (the ordinary path builds the same record once `L2` is a word of the language); the
construction and the preflight started from the code of the file (they descend into the record from the root).

## Recorded and not changed here

- An explicit `L2:` that is not the whole file -- among other fields of the root, or in a body -- is built and
  printed as the record, and the interpreter does not run it: `int: before 1` / `L2:` with `int: x 5` /
  `int: after 2` answers 3 (before the step 5: a block of an unknown receiver). By the order of 2026-11-18 the
  interpreter is to execute it, with the checks: step П2 of the plan.
- That `L2` is a word of the language is told by that probe only (the mutant mX), by no row: a row pins exit 0, 1
  or 2, and the program answers 3 today. The row comes with step П2.
- A plain `emit` of a wrapped file prints between its BEFORE and AFTER marks the content of the record, the code
  that the entry runs, not the file with `L2:`; `emit-check`, which the rows use, prints the file.
- The level is read by the builder from the extension of the path it is given.
- No row can tell a native root from an interpreted one: the native skeleton evaluates through the exports of the
  interpreter. The entry on the record is checked on the image and by the mutants mE and mB.

## Acceptance on the frozen sources

Freeze: 1010 inputs, manifest SHA 7e434c30cac5dded…, verify 1010/0 for the repository and the stage; the canonical
`selfbuild/inputs.sha256` is byte-equal to it.

- Which command translated each changed module (opus's record): `lmx_graph` and `lmx_graph_run` by the runtime
  build; `l2_graph_build` and `l2_graph_tool` by `build-graph`; `l2_frontend_graph` by `build-frontend-host`;
  `tools/build.lm2` by `build-self`. The hosted frontend was built from the final sources and built the runtime and
  the Graph tool of the candidate; it translates every changed module to the same bytes as the working frontend.
- Whole bootstrap, quick, label `boot-fl01-02`: genuine G1 and actual G1→G2, 9 smoke rows and 0 failures each,
  22.2 min. G0 is the candidate tool built from the new `tools/build.lm2` (4fec4acd), the previous frontend the
  hosted candidate (9766b9df). A first run, label `boot-fl01-01`, was stopped by the host for lack of memory during
  the G2 build and gave no verdict.
- `fixedpointl01-02`: CHECKS 18 lines, 0 failed: 11 `same` and 3 `exe-same` between G1 and G2, the G2 runtime
  objects byte-equal to the candidate runtime, and the two source verifications.
- Actual G2: working tool `boot-fl01-02/lmxtool.exe` ec49198b, frontend 7e2e7186, runtime production object ff16d5fc and
  observed object 6c07014e.
- Route 331 (opus): `lmx_clock`, `lmx_process_deadline` and `lmx_schedule`, translated from the graph by the working
  frontend and by the candidate, whose builder wraps the module in the record, are the same bytes. The whole
  bootstrap repeats it: the generated runtime of G1 and of G2 is byte-equal.
- Targeted list on the actual G2: SUITE 12 rows, 0 failures, 72 PASS.
- Full suite on the actual G2 (`g2-l01-full01`, 19.6 min): **SUITE 210 rows, 44 failures**, 1450 PASS.
  By fixture names 16 are red, the same names as the base; none is newly red. The seven machine rows above are
  green.
- Graph tool on this G2 (`graph-fl01-01`, 7412d1e2): `private_binding` and `call_frame_local`, now `.lm3`, each triple
  interp / native / forced PASS.
- Programs of the full suite on the clean graph, text unchanged, three modes: **11 of 11 pass in all
  three**, the same stage and answer as the base, row for row. They are `.lm2` files: each is wrapped in the record
  now and runs through it.
- Clean-graph list, 284 pinned rows (the 283 of the base, 275 of them with an `.lm3` source, and the new
  `level2_record_file`), each under a 60 s limit: **222 pass, 62 fail**, rows over the time limit: 0.
  Red by names: 62, the names of the base; the 283 rows of the base answer as before, row by row.
- The images of the `.lm3` rows (opus): 542 emitted programs, native and forced, are byte-equal to those of the base
  run; 10 rows have no image, their construction is refused.
- A plain `emit` of a wrapped program (opus): `dyn/named_assign_quoted.lm2`, native and forced, built and run,
  answers its letter, 7.
- Mutants (run by opus, each undoing one edit in a private copy of the stage with its own runtime and Graph tool),
  six, all killed: an `.lm2` file not wrapped (22 of 27 checks of the eight `.lm2` rows and the new row fail); the
  call not passing through the record (25 of 27 fail, the clean row too); the entry and the methods installed on the
  root (12 of 27 fail, native); the native body taken from the root (11 of 27 fail, native); route 331 from the root
  of a machine module (the runtime refused); `L2` no word of the language (the probe above answers 5).
- Closers: the source diff adds no `end:`. It adds two fences, each where the next line rises two levels (from
  level 3 to level 1); `lmx_graph_file_code` ends with `return:` and has no `end:`; the new program adds none. The
  lines `end: L2` are dump text in `.expected` files.

Generated L1 and C were not edited by hand; no row was disabled.

## What the running program holds after the step

The clean graph, the native methods and the values of a call, as before. New in the graph: the record `L2` around
the content of an `.lm2` file and for every explicit `L2:`. The level is that record: no flag, no table and no field
beside the graph; one new word of the state. In an emitted program the image of the record carries the native entry
of the code.

## Files beside these notes

- `graph-baseline.tsv`: the 284 rows with their results -- the new base of the graph gate.
- `graph-red-names.txt`: the 62 red fixtures of the graph list.
- `graph-baseline-rows.sh`: the runner of the graph list that names a row without `.lm2` or `.lm3`.
- The base of the clean rows is unchanged: `../one-graph-terminal-return-20261117/clean-rows.tsv`.
- The base of the full-suite gate is unchanged: `../m10-code-places-step1-20261117/full-suite-red-names.txt`.

Receipts outside the repository: `build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01`,
directories `receipts/opus/one-graph/l1` (`RESULT.txt`, the list of the renames, the `.expected` before and after,
probes, mutants), `fable` (bootstrap, fixedpoint, G2 runs, graph list).
