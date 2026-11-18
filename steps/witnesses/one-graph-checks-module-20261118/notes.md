# Step P1, slice C1: the module of checks and the types of L3; the existing checks moved into it

Written 2026-11-18 by Fable (fable_pc), the single writer/build of main. The code, the fixtures, the component builds
and the mutants are by the peer session opus under the pipeline token; eight of the ten fixtures were written by
haiku from opus's probes and checked by opus. Fable set the order, took the decisions and re-ran the witnesses.
Base: `34b63f7c`.

## The norm

The author, 2026-11-18 (`LMX_blog/2026-11-18.md#interpreter-runs-l2`): «сделайте модуль проверок и типы L3»; the
interpreter executes L2 with the same checks as L3; native L2 code is compiled without them. The book, #scope: an
element of an array is checked against the current length; pointers to Structures and methods are assigned only to
one another and nulled; pointers to data are wrappers. Plan, #one-graph-plan, step P1; executor's answers R49, R51.

## What changed

- New kernel module `selfbuild/src/l2src/lmx_checks.lm2`, below `lmx_graph`: it reads only the index of the regions of
  the arena. Four exported functions, no state, no table, no cell of its own:
  - `lmx_l3_type` -- the type of L3 of an address: the type code of the pool whose region holds it (the former body
    of `lmx_graph_kind`);
  - `lmx_check_index` -- an index against the current length of a Structure, answers 0 or 7;
  - `lmx_check_reference` -- a pointer to an int takes an int cell, a pointer to a Structure or a method takes an
    Lmx, answers 0 or 4;
  - `lmx_check_data_read` -- a read through `\p` needs a pointer to an int, answers 0 or 2.
- `lmx_graph.lm2`: `lmx_graph_kind`, `lmx_graph_index`, `lmx_graph_index_write` and `lmx_graph_reference_payload` call
  the module instead of their own tests. `lmx_graph_run.lm2`: the read through a pointer calls the module.
- `tools/build.lm2`: the module in the list of the runtime, before `lmx_graph`, with its header.
- The emitter is not changed. No answer of any program changed: the slice only gives the checks one place.

## Acceptance by the component cycle

This is a component acceptance by the author's order on the build cycle (`to_fable2_fast_build.md`): no whole
bootstrap, no fixedpoint, no full suite and no whole graph list were run. They are due at the border of stage P1.

- Source manifest: 1031 inputs, SHA 173c5593…, verify 1031/0 for the repository and the stage; the canonical
  `selfbuild/inputs.sha256` is byte-equal to it.
- Which command built what (opus's record): `build-self` by the working tool gave the candidate tool (1e7a0a2c), since
  `tools/build.lm2` changed; `build-runtime` by the candidate tool with the working frontend translated `lmx_checks`,
  `lmx_graph` and `lmx_graph_run` and gave the runtime `ps-rt-c102` (production object 57f22a3a, observed object
  833948b9); `build-graph` gave the Graph tool `ps-graph-c102` (66ca8bba). The hosted frontend was not rebuilt: it
  keeps the kernel of the previous step inside; the whole self-build at the border of the stage checks that.
- Witnesses, re-run by Fable on the candidates (`witness-rows.tsv`): 20 rows, each in the three modes interp / native
  / forced -- all pass. Ten are rows of the graph list that already pin these answers and answer as in the base
  `../one-graph-level2-record-20261118/graph-baseline.tsv`; ten are the new fixtures `checks_*`.
- Opus ran the same 20 rows on the working set too: the verdicts are the same, and the 40 emitted images, native and
  forced, are byte-identical to those of the working Graph tool.
- Mutants (run by opus, each one edit of the module in a private stage with its own runtime and Graph tool), six,
  all killed: the type of a pointer to an Lmx answered 0; `>=` made `>` in the index check; a negative index let
  through; a pointer to an int taking any referent; a pointer to a Structure taking any referent; the read through a
  pointer admitting any value. The two pointer mutants survived the first 18 rows: on the way of a store into a
  place of the activation the constructors of the pointer cell test the referent themselves. Two fixtures that write
  through an explicit path into a pointer place of shared data were added, and they kill them.
- Closers: the source diff adds one fence where the next line rises two levels, and removes the `end:` of
  `lmx_graph_kind`, which now ends with `return:`. The new module and the ten programs have none.

## Recorded and not changed here

- One duplication remains: the constructors `lmx_graph_ref_int` and `lmx_graph_ref_lmx` still test the type of the
  referent themselves, for their other callers.
- The emitter still writes the test of the read through a pointer as text; it becomes a call of the module with the
  slice of native L2 code (C8).
- Nulling of a pointer (C2), pointers to data of every scalar type and a write through a pointer (C3), the array
  `[]: T` (C4) are the next slices of step P1.

## What the running program holds after the step

The clean graph and the native methods, as before. The runtime gains one module of four functions. The type of a
value is still the type code of the pool that holds its address.

## Files beside these notes

- `witness-rows.tsv`: the 20 rows with their verdicts on the candidates.

Receipts outside the repository: `build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01`,
directories `receipts/opus/one-graph/c1` (`RESULT.txt`, the diff, build records, mutants) and `fable`
(`c1-witness02.log`).
