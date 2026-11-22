# The entry of a fixture: ENTRY and SOURCES (step 21.6 of the edition of 2026-11-21)

Written 2026-11-22 by Fable, the coordinator and the single writer of main. This is step 21.6 of the plan section
`next_core_tasks_v3.md#docs-20261121`. The change of the Graph tool and of the build tool, the fixture sources, the
expected dumps and the mutants are by the peer session sonnet, on the pipeline token. Fable set the form before
the code (the executor's answer Р117 in `LMX_blog/q/fable-self-answers-20261110.md`), read the diff, pinned the
rows from the norm before the run, generated and verified the manifest, built the tool, the runtime, the hosted
frontend and the Graph tool from the tree, ran the parser suite, the rows and the nine kernel self-tests,
reproduced two mutants and decided the helper's two questions (the answer Р132 of the same ledger).

## The norm

- `CORE.md`, §3.1: a callable is an ordinary Structure C selected for execution as CODE; its DATA is its actual
  `parent(C)`; the form `C()` has an empty written tail. Executable `fn` and `sub` definitions, the builtin name
  `data` and the separate DATA argument of `call` are withdrawn.
- `CORE.md`, §3.2, and `docs/implementation-notes.en.md#root-role-control`: R0 has no DATA and no user actuals and
  is not turned into its own DATA; a source or host entry profile states which entry it selects and does not call
  every declared Structure.
- `docs/REVIEW_NOTES.md`, D2: a fixture states its entry profile; a fragment supplying a DATA description can be
  prepared in that role and its explicitly named body called through the ordinary call path. No automatic `main`.
- The runner contract of the author's examples, `docs/new_parts/examples/expected_results.json`: every source
  with its `load_before` dependencies in one fresh context, then the named entry; `import` is not a file loader.
- The executor's decision Р117: the entry is the path of a body; the call with arguments and the preparation of
  a case are written in LMX in a small case source, the last of the sources.

## What a fixture can say after the step

- ENTRY, the path of a body such as `Case\run`: the optional last argument of `run`, `emit` and `emit-check`
  of the Graph tool and the fourteenth field of a `graph-check` row. The last argument is the ENTRY when it is
  not made of digits only. With an ENTRY the root is built as a description and is not executed; the body found
  is executed once per run, and its data is its parent: in the body of `Case\run` the path `data\seen`
  is `Case\seen`.
- The first segment is read as the head of a call is read, from the code of the file. Every later segment must
  be a member of the Structure before it: a path does not look outward.
- SOURCES, one path or several joined by `;`: the sources are built in the written order into one fresh root.
  Their texts are joined, each ended by a blank line -- the full border of a block of step 21.3 -- and parsed
  once by the same builder of the root. A diagnostic of the parser names the source and the line inside it.
- An unknown path answers 3 with the line `graph: entry PATH is not found or is not a Structure body`; nothing
  runs and the graph after equals the graph before. A source that cannot be read, and sources of both levels
  (`.lm2` with others) in one list, refuse the construction with answer 2.
- Without an ENTRY everything is as before: one source, the root is executed, rows of thirteen fields are read
  as they are. A fourteenth field that is empty means no ENTRY.
- There is no second runner, no file with the text of a call and no new print: the observation is the dump of
  the graph before and after, as for every row.

## What changed

- `selfbuild/src/l2src/l2_graph_tool.lm2`: the arguments of `run`, `emit` and `emit-check` (`lm_graph_is_count`);
  `lm_graph_build_sources`, the join of the sources and the one parse; `lm_graph_call_entry`, the reading of
  the path and the launch of the body over its parent by the kernel's launch of code over data
  (`lmx_graph_call_data`); `lm_graph_emit_entry`, the generated function `lm_graph_entry` of an image, called by
  the root of an ordinary program and by the adapter of `emit-check`.
- `selfbuild/tools/build.lm2`: `bld_graph_check` passes the entry as the last argument of `run` and of
  `emit-check`; the module `l2_graph_build` exports `lm_graph_build_root` beside `lm_graph_build_file`. The tool is
  therefore rebuilt.
- `selfbuild/tools/lmxtool_methods.lm2`: the fourteenth field of a `graph-check` row.
- `selfbuild/tests/graph`: 11 sources `entry_*.lm3` and 14 expected dumps; `selfbuild/inputs.list` has
  1487 lines.
- The kernel is not touched: no file `lmx_graph*.lm2` changes, and the runtime is byte-equal to the accepted one.

## Acceptance by the component cycle

This is a component acceptance by the author's order on the build cycle (`to_fable2_fast_build.md`): no whole
bootstrap, no fixedpoint and no full suite were run.

- Source manifest: 1487 inputs, SHA 2bd288a6…, generated and verified by Fable with the accepted
  tool `fable-b3-tool01` (fb3fbfbd) for the repository and for the stage. The changed and new files of the tree
  equal the helper's list of hashes.
- The chain from the final sources, built by Fable from the accepted set of step 21.3:
  - `build-self` gave `fable-e6-tool01/lmxtool-tool.exe` (cb658ad6);
  - `build-runtime` by the accepted frontend gave `driver.o` 29025785 and `driver-observe.o` cf247b29, the bytes
    of the accepted runtime;
  - `build-frontend-host` gave `fable-e6-feh01/l2trans.exe` (800016b7);
  - `build-runtime` by that frontend gave `fable-e6-rt02`, byte-equal to the first runtime;
  - `build-graph` gave `fable-e6-graph02/graph_trans-prod.exe` (f417ecda).

  The tool and the hosted frontend equal the helper's `son-f-tool01` and `son-f-feh01`, and the Graph tool equals his
  `son-g-graph02`, built from the final tree, after the two build fields of the PE header, TimeDateStamp and
  CheckSum, are zeroed.
  The working set after the step: the tool `fable-e6-tool01`, the frontend `fable-e6-feh01`, the runtime
  `fable-e6-rt02`, the Graph tool `fable-e6-graph02`.
- The parser suite, 169 cases, on the new Graph: 0 failed.
- Rows, each in the three modes interp / native / forced, run by the new tool (`witness-rows.tsv`):
  - the 388 rows of the acceptance of step 21.3 (`../blank-line-block-border-20261121/witness-rows.tsv`), all of
    thirteen fields: 327 are green before and after, no row changes its verdict, no row ran into the time limit.
    This is the witness that nothing changes without an ENTRY;
  - 17 new rows, pinned by Fable from the norm before the run, all green in the three modes: eight bodies that
    run (a member body, the same body writing by a path, two entries of one source, a path of three segments,
    two runs, two sources in both orders), a body of the root named by one segment, five refusals with answer 3
    (an unknown last and first segment, a name found only outside, a `fn` and a `sub`), two refusals of the
    construction with answer 2 and the control row with an empty fourteenth field;
  - Fable's run and the helper's agree in every mode of every row.
- The nine kernel self-tests of the graph, the rows `dyn/graph_*`: green on the accepted set and on the chain
  above, 9 rows and 0 failures in each run.
- Mutants, the helper, each in a stage of its own with its own Graph tool or build tool (`mutants.tsv`):
  18 mutants, all killed. Sixteen were run on the tree before the comments were
  re-wrapped and the row `entry_root_body` added, two (m19, m20) on the final tree. Fable reproduced two with the
  chain above: m19, the interpreter launches the body over itself, and m7, the image does not fail on an unknown
  path.
- Probes by Fable on the candidate, in the interpreter: 200 000 iterations inside the body of an entry and inside
  a method called from it, three runs in a row, end without a break; a refusal in the middle of a body answers 3
  and keeps what was written before it.

## What the modes mean for a row with an ENTRY

- interp: the Graph tool reads the path and launches the body in the kernel's interpreter.
- forced and native: the image has the generated function `lm_graph_entry` with the segments of the path in its
  text; it reads the path by the same kernel functions and launches the same body by `lmx_graph_call_data`.
- In the native image the methods of the sources are native code, as before, and the statements of the body of
  the entry are executed by the kernel's interpreter. The verdict `native=PASS` of such a row therefore covers
  the native methods the body calls, not a native translation of the body itself. The native function of a body
  comes with the structural call, step 21.7, and is due before the examples of the author become rows, step
  21.21.
- In a refusal row the answer number is compared in the interpreter only; native and forced must fail and leave
  the same graph (the executor's answer Р128).

## Decisions at the acceptance

- The data of the body is its parent. The kernel's ordinary call `S()` of today runs S over itself (the rule of
  2026-11-11); the edition gives `C()` the DATA `parent(C)`. The entry is built on the launch of code over given
  data, so it has the form of the edition now; step 21.7 brings the ordinary call to the same form, and the entry
  becomes that call literally. The mutants m19 and m20, the body over itself, are killed by every row that runs.
- An executable `fn` or `sub` of today is not the body of an entry: answer 3. The entry is the structural call of
  the edition, and the edition withdraws executable `fn` and `sub`; a callable of today has its own data and its
  own call path, and its call is written in the body of the case like any call. The check, its two rows and its
  two mutants leave with the form at step 21.7.
- Sources of both levels are not built into one root: a `.lm2` file is wrapped in the record L2, and the norm
  defines no mixed root.

## Open, not in this step

- The native translation of the body of an entry: step 21.7.
- The existing programs of `tests/graph` are not moved to the new profile: steps 21.7 and 21.21.
- An ordinary `emit` with an ENTRY is not run by a row: `graph-check` uses `emit-check`. The root of the image
  calls the same generated function, and that route is exercised under the mutant m13.
- No row enters a body of a `.lm2` source.
- An extra argument after the ENTRY is ignored, as an extra argument after the count was before.

## Files beside these notes

- `witness-rows.tsv`: the 405 rows -- the list a row comes from, its pin (expected exit, runs,
  answer and the ENTRY), the verdict before and after.
- `mutants.tsv`: the mutants of the helper -- the change, the verdict, the rows that differ.

Receipts outside the repository: `build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01/fable`,
directories `tz-20261121/step-21-6` (the delivery: `DESIGN.md`, `REPORT.md`, the scripts of the edit, the rows,
the logs of the chains and of the mutants) and `tz-20261121/accept-21-6` (the acceptance: the manifest, the build
logs, `new_rows.py` with Fable's pins, `acc.log`, the suite log, the self-tests, the two mutants).
