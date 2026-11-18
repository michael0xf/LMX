# One graph: the terminal `return` in the builder of the clean graph

Written 2026-11-17 by Fable (fable_pc), the single writer/build of main. The code of the builder and the fixtures
are by the peer session sonnet, who ran the component builds, the candidate runs and the mutants under the pipeline
token; Fable set the order, took the decisions and ran the acceptance gates. Base: the slice of `send`, `6871488f`.

## The norm and the defect

The grammar, section 17: a terminal `return` at the level that opens a named executable Structure, an ordinary
Structure without `fn` or `sub` included, adds the return to the end of its body and closes its Frame. The example of
the source: `fn: square (int(x)) (int)` and, under it at the same level, `return: x * x`.

P0 gives such a `return` as the trailer of the Frame it closes. The builder of the clean graph read the trailers
`until` and `end` and no other: the terminal `return` was lost. An `fn` written with no other body became an
interface with no code, and its call answered 5; an `fn` with a body lost its return. Found while the rows of the
full suite were moved to the clean graph: `dyn/p0_groups.lm2` writes `fn: add_fields (int: a; int: b) int` and
`return: (a + b)` at one level.

## What changed

One module, `l2_graph_build.lm2`. The builder reads the trailer `return` as it reads the trailer `until`: by the one
mechanism of the trailer, with no branch for a single receiver.

- The return the trailer stands for is built as the statement is built where it is written: the bare word, or the
  record `return` with the written fields.
- A callable (`fn`, `sub`) takes it into its body, the code part of its receiver form; a callable written with no
  body gets a body of that one statement.
- Any other Frame, a named Structure without `fn` or `sub`, takes it as one more field after the written ones.

After the build the graph holds an ordinary `return` at the end of the body; nothing of the trailer stays in the
graph, no flag and no table. The dump prints the return as the last statement of the body.

## Recorded and not changed here

- The code part of a callable is found by the count of its written fields: from 4 for `fn`, from 3 for `sub`. The
  forms themselves are written once more in `lmx_graph_receivers_open` of the interpreter, where they exist only in
  the namespace of a traversal; the builder runs before any traversal. The comment of the builder names that place,
  and the fixtures `trailer_return_fn_body`, `_fn_data`, `_fn_structure_type` and `_sub` go red when the two
  disagree. One record of the receiver forms for both sides is a separate step
  (`next_core_tasks_v3_checklist.md`).
- `fm` has no receiver form in the clean graph and is not touched.
- The rows of the full suite run on the former path, which does not read this builder: no name of the full suite
  changed its verdict. The measurement of the full suite on the clean graph shows the effect on the programs that
  write a terminal `return` after a body.

## Acceptance on the frozen sources

Freeze Source14: 1004 inputs, manifest SHA 6b5530ca3345da0a…, verify 1004/0 for the repository and the stage; the
canonical `selfbuild/inputs.sha256` is byte-equal to it.

- Which command translated the changed module (sonnet's record): `l2_graph_build` by `build-graph`; the hosted
  frontend was built whole from the final sources, linked after it, and built the runtime and the Graph tool of the
  candidate.
- Whole bootstrap, quick, label `boot-ftr-01`: genuine G1 and actual G1→G2, 9 smoke rows and 0 failures each,
  18.8 min. G0 is the working tool of the previous slice (1436d6f4), the previous frontend the hosted candidate
  (f8bf2df2).
- `fixedpointtr-01`: CHECKS 18 lines, 0 failed: 11 `same` and 3 `exe-same` between G1 and G2, the G2 runtime
  objects byte-equal to the candidate runtime, and the two source verifications.
- Actual G2: working tool `boot-ftr-01/lmxtool.exe` 1bcdd033, frontend 5036b654, runtime production object 73ae89d6 and
  observed object bcfde14b.
- Targeted list on the actual G2: SUITE 12 rows, 0 failures, 72 PASS.
- Full suite on the actual G2 (`g2-tr-full01`, 16.9 min): **SUITE 210 rows, 44 failures**, 1450 PASS.
  By fixture names 16 are red, the same names as the base; none is newly red.
- Graph tool on this G2 (`graph-ftr-01`, 538c926d): `private_binding` and `call_frame_local`, each triple
  interp / native / forced PASS.
- Programs of the full suite on the clean graph, text unchanged, three modes: `dyn/p0_groups.lm2` answers 7 in the
  three modes, and the ten programs with `send: exit(...)` of the previous slice stay green — **11 of 11
  pass in all three**; `clean-rows.tsv` beside these notes.
- Clean-graph list, 281 pinned rows (the 275 of the base and six new ones, `trailer_return_*`), each under a
  60 s limit: **219 pass, 62 fail**, rows over the time limit: 0. Red by names: 62, the names of
  the base; the 275 rows of the base answer as before, row by row.
- Mutants (run by sonnet in a private copy of the stage, each undoing one edit): the trailer ignored is killed by
  the six fixtures and by `p0_groups`; an `fn` that never takes the return into its written body by `_fn_body` and
  `_fn_data`; the threshold of `fn` moved from 4 to 3 by `_fn_structure_type`; the threshold of `sub` by `_sub`.
  A fifth edit, in the reading of a named block, survived its mutant and was removed from the slice.
- Closers: the source diff and the six new programs add no `end:` and no fence.

Generated L1 and C were not edited by hand; no row was disabled.

## Files beside these notes

- `graph-baseline.tsv`: the 281 rows with their results — the new base of the graph gate.
- `graph-red-names.txt`: the 62 red fixtures of the graph list.
- `clean-rows.tsv`: the programs of the full suite that pass on the clean graph in the three modes — the verdict, the
  last stage and the answer per mode. The base of this gate from now on.
- The base of the full-suite gate is unchanged: `../m10-code-places-step1-20261117/full-suite-red-names.txt`.

Receipts outside the repository: `build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01`,
directories `receipts/sonnet/one-graph` (`trailer/NOTES.txt`, `run/RESULT-trailer.txt`, mutants), `fable`
(bootstrap, fixedpoint, G2 runs, graph list).
