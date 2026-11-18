# One graph, group G1, step 1: the statement `send` on the clean graph

Written 2026-11-17 by Fable (fable_pc), the single writer/build of main. The code (the kernel of the clean graph, its
interpreter, the emitter of native bodies) and the fixtures are by the peer session sonnet, who ran the component
builds, the candidate runs, the probes and the mutants under the pipeline token; Fable set the order, took the
decisions and ran the acceptance gates. Base: the slice of place signs, `000db4a8`.

## The order of the author

The author, 2026-11-17 (`LMX_blog/2026-11-17.md#one-graph`, `#only-graph-and-native`): the graph is not duplicated;
a running program holds the clean graph and native methods and nothing else. The former path of execution is removed,
and the rows of the full suite move to the clean graph in groups by a common mechanism
(`next_core_tasks_v3.md#one-graph-plan`). Group G1 is the mail; its first measurable step is a program with
`send: exit(...)` that answers with its own code in the three modes.

Until this slice the clean graph had no `send`. The builder kept `send: exit(...)` as a Frame headed `send`; neither
the interpreter nor the emitter acted on it, and the scan of the free inputs of a body read the nested Frame
`exit(...)` as a call, so every such program ended with the answer 3.

## What changed

1. `lmx_graph_send` in `lmx_graph_run.lm2`: one function for the three modes. It builds the letter from the values of
   the graph with the calls of the kernel: a Message record whose graph is the sender and the payload. The sender is a
   pointer cell holding the Message of the current thread; the payload is a Structure whose fields stand in the
   written order, an int cell for an int expression and an array of characters for a quoted text. The letter lies in
   an arena of its own, which the service takes over when it posts. The letter goes to the parent of the current
   thread. There is no branch for `exit`: `exit` is the name of a Message that the host of the root thread admits.
2. The scan of the free inputs: the Message of `send` defines its field names, they are no free inputs of the body;
   the written values are read as the operands of any Frame.
3. The interpreter calls the function at a statement headed `send`. The emitter of native bodies emits a call of the
   same function, for a statement of the root and for a statement in the body of a native method.
4. The word `send` is interned with the state of the clean graph; `tools/build.lm2` carries the word in the text of
   the state and the function as the 73rd machine function of `lmx_graph_run`.
5. The command `run` of the Graph tool executes the program in the tool's own thread; the kernel is not changed. The
   tool sends its own exit letter after the program, as before; the host takes the first exit letter it admits.

## What the running program holds after the step

The clean graph, the native methods and the values of a call. A letter is objects of the kernel in an arena of its
own handed to the service; the step adds no C array, no row beside the graph and no record outside it. One new datum
of the state: the word `send`, one more of the interned words of the language, which move into a Structure of the
clean graph together with the others (`next_core_tasks_v3.md#one-graph-plan`, the source of the tables).

## Recorded and not done here

- A Ref written before the Message, naming another thread: no value of the graph is the address of a Message yet
  (`create` and `receive` bring it), so the form answers 5. It goes with the receiving step of group G1.
- The value of a field is an int expression or a quoted text. A Structure in a field answers 5, the bare name of a
  reference 4; a dereference (`exit_code: \p`) works. A letter carries any data by copy: the receiving step.
- An int in the place of a text and a text in the place of an int: `send` builds and posts the letter by the kind of
  the value; the host refuses it by the model of `exit`. The three modes answer the same.
- A condition of mine was withdrawn during the acceptance: the tool was to send no exit letter of its own when the
  program had sent a letter. Sonnet's probes showed that it made the interpreted mode differ from the other two on a
  letter the host does not admit; the function was removed.
- `dyn/p0_groups.lm2` is not among the witnesses. It is red on the clean graph for a cause that is not `send`: the
  builder of the clean graph loses a terminal `return` written at the opening level of an `fn` (grammar, section 17:
  such a `return` adds the return to the end of the body and closes the Frame). The next slice does it.
- The pins of a graph row accept the exits 0, 1 and 2 only and compare the dump for the exit 0 only, so the two new
  rows send the code 1 (3 - 2): a letter not sent gives 0, a lost local or call another number.
- `receive` and `post` are not touched.

## Acceptance on the frozen sources

Freeze Source13: 992 inputs, manifest SHA 71ebce5c8d6cea63…, verify 992/0 for the repository and the stage; the
canonical `selfbuild/inputs.sha256` is byte-equal to it.

- Which command translated each changed module (sonnet's record): `lmx_graph` and `lmx_graph_run` by the runtime
  build, `l2_graph_tool` by `build-graph`; the frontend was linked after them and built the runtime and the Graph tool
  of the candidate. After the candidate runs only comments of `lmx_graph_run.lm2` changed and one function of the
  Graph tool was removed; the whole bootstrap below builds everything from the final sources.
- Whole bootstrap, quick, label `boot-fg1-01`: genuine G1 and actual G1→G2, 9 smoke rows and 0 failures each,
  21.4 min. The list of machine functions changed, so G0 is the candidate tool built from the new `tools/build.lm2`
  (6bb40104), the previous frontend the hosted candidate (73bc64db).
- `fixedpointg1-01`: CHECKS 18 lines, 0 failed: 11 `same` and 3 `exe-same` between G1 and G2, the G2 runtime
  objects byte-equal to the candidate runtime built before the change of comments, and the two source verifications.
- Actual G2: working tool `boot-fg1-01/lmxtool.exe` 1436d6f4, frontend d1618e51, runtime production object 73ae89d6 and
  observed object bcfde14b.
- Targeted list on the actual G2: SUITE 12 rows, 0 failures, 72 PASS.
- Full suite on the actual G2 (`g2-g1-full01`, 18.6 min): **SUITE 210 rows, 44 failures**, 1450 PASS.
  By fixture names 16 are red, the same names as the base; none is newly red.
- Graph tool on this G2 (`graph-fg1-01`, 2d7fcc57): `private_binding` and `call_frame_local`, each triple
  interp / native / forced PASS.
- Programs of the full suite with `send: exit(...)` on the clean graph, text unchanged, three modes (sonnet's
  `measure.sh`): **10 of 10 pass in all three**; `send-rows.tsv` beside these notes.
- Clean-graph list, 275 pinned rows (the 273 of the base and the two new ones, `send_exit` and `send_in_fn`),
  each under a 60 s limit: **213 pass, 62 fail**, rows over the time limit: 0. Red by names: 62,
  the names of the base; the 273 rows of the base answer as before, row by row.
- Mutants (run by sonnet under the pipeline token, each undoing one edit): the letter not posted, the fields in the
  reverse order and the scan without its branch are killed in the three modes; the emitter without its branch is
  killed in the native mode, the interpreter without its call in the interpreted and the forced mode.
- Closers: the source diff and the two new programs add no `end:` and no fence.

Generated L1 and C were not edited by hand; no row was disabled.

## Files beside these notes

- `graph-baseline.tsv`: the 275 rows with their results — the new base of the graph gate.
- `graph-red-names.txt`: the 62 red fixtures of the graph list.
- `send-rows.tsv`: the programs of the full suite with `send`, the verdict, the last stage and the answer per mode.
- The base of the full-suite gate is unchanged: `../m10-code-places-step1-20261117/full-suite-red-names.txt`.

Receipts outside the repository: `build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01`,
directories `receipts/sonnet/one-graph` (`MAIL.txt`, `measure.sh`, `run/RESULT.txt`, probes, mutants),
`receipts/opus/one-graph` (the inventory of the former path), `fable` (bootstrap, fixedpoint, G2 runs, graph list).
