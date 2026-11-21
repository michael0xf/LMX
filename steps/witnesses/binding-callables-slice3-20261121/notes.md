# A private declaration the callee sees lexically is not replaced dynamically (slice 3 of «binding and callables»)

Written 2026-11-21 by Fable, the coordinator and the single writer of main. This is step 21.2 of the plan section
`next_core_tasks_v3.md#docs-20261121`, step 3 of `#binding-callables-20261119`. The change of the kernel, seven rows
and the three re-pins are by the peer session opus (2026-11-20); the author kept them in main as the commit
`30001e04`, marked `[wip]`. The peer session sonnet finished the slice on 2026-11-21: the Graph tool on the
candidate runtime, the row on the place of the write, the runs, the mutants, the probes, the chain from the final
sources, the two corrections of the kernel self-tests. Fable set the bounds (the executor's answers Р113 and Р115 in
`LMX_blog/q/fable-self-answers-20261110.md`), read the diff, generated and verified the manifest, rebuilt the hosted
frontend, the runtime and the Graph tool from the tree, re-ran every row, ran the full suite and bisected the two
self-tests. The map of the edition against the code (`../docs-20261121-map/notes.md`, A2) found the change
conforming to the edition of 2026-11-21.

## The norm

The author's requirement of 2026-11-19, `docs/TZ/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md`, decisions R05
and R06, §5.1–§5.4, rows B09–B17: `private` acts in both directions for every kind of implicit dynamic binding. A
private source is not supplied implicitly; a private declaration the receiver really sees is not replaced
dynamically. An explicit supply, the ordinary nested lexical visibility and explicit paths are not forbidden by
`private`. The mark is read from the record `private:` of the same graph (the author's clarification of 2026-11-21,
§1.3: no graph of marks). The kernel notes of the edition, `docs/kernel-implementation.en.md`, §3.4: check the
declaration the receiver actually sees; an explicitly supplied value carries no private history; a bare write to a
copy of the former binding changes the copy.

Before the slice only the source side existed: a private place of a calling activation was skipped. A public dynamic
place of the caller replaced a private declaration the callee saw lexically (row B11: 11 instead of 7).

## What changed

- `selfbuild/src/l2src/lmx_graph_run.lm2`, +49 −8:
  - `lmx_graph_declared_private`: is a name declared private by a record -- the record `private: (…)` itself or the
    modifier above the declaration; `lmx_graph_row_private` now calls it;
  - the lexical part of the search is moved out of `lmx_graph_select_binding` into `lmx_graph_lexical_binding`,
    without a change of its text; with `prepare` 0 it only selects: no namespace is prepared and nothing runs;
  - `lmx_graph_lexical_private` asks whether the declaration the lexical part selects for the name is private;
  - in `lmx_graph_select_binding`, before the first binding of a calling activation is taken, this question is
    asked once; if the answer is yes, the dynamic sources are left and the lexical part answers.
  The diff adds no `end:` (one moves with the end of the function) and no `---`, and no blank line inside a block.
- Rows, `selfbuild/tests/graph` (16 lines in `selfbuild/inputs.list`, 1353 → 1369):

  | Row | Pin | Observed | TZ |
  |---|---|---|---|
  | `bind_private_receiver` | `0 1 0` | `seen 7` | B11 |
  | `bind_private_receiver_write` | `0 1 0` | `seen 11079` | B11, the write |
  | `bind_private_write_own_copy` | `0 1 0` | `seen 110797` | B11, Р113: the place of the write |
  | `bind_private_outer_not_barrier` | `0 1 0` | `seen 11` | §5.3: an outer private declaration is no barrier |
  | `bind_private_source_explicit` | `0 1 0` | `seen 5` | B13 |
  | `bind_private_formal_explicit` | `0 1 0` | `seen 20` | B14 |
  | `bind_private_inner_shadows` | `0 1 0` | `seen 3` | B16 |
  | `bind_private_skip_continue` | `0 1 0` | `seen 1` | B17 |

  `bind_private_write_own_copy` is by sonnet from a probe of opus: a bare write under the protected lexical
  declaration lands in the callee's own copy, and the place of the owner keeps 7 (110797; a write into the lexical
  place would give 110799; before the slice 111237).
- Three accepted rows are re-pinned by R05: `private_binding` and `private_data_write`, `public_result` 2121 → 2110;
  `private_path_write`, `public_result` 2121 → 2133. Their headers say what was pinned before.
- The kernel self-test `selfbuild/tests/dyn/graph_private_binding.lm2`: the cases of the slice -- `CodePublic`
  2121 → 2110 (case 106), `Explicit` 3030 → 3010 (case 114), `Eligible` 30 → 10 (case 119) -- and the cases 117 and
  118, see below.

## Acceptance by the component cycle

This is a component acceptance by the author's order on the build cycle (`to_fable2_fast_build.md`): no whole
bootstrap and no fixedpoint were run. The full suite was run once, for the reason given in the next section.

- Source manifest: 1369 inputs, generated and verified by Fable with the tool `ps-tool-r101` (f0e186f4): 1369/0 for
  the repository and for the stage. Before the two corrections of the self-tests its SHA was d5a4a6e6…, the one
  sonnet delivered; with them it is 9dfde5d3…, and the two files are its only difference.
- The chain from the final sources, built by Fable: `build-frontend-host` gave `fable-s3-feh01/l2trans.exe`
  (37cffd01), equal to sonnet's `sn-s3-feh01` (14416eac) after the two build fields of the PE header,
  TimeDateStamp and CheckSum, are zeroed. `build-runtime` with it gave `fable-s3-rt02`: `driver.o` 25d8a485 and
  `driver-observe.o` 83e0241a, byte-equal to the candidate runtime `opus-s3-rt01` and to sonnet's `sn-s3-rt02`.
  `build-graph` with it gave `fable-s3-graph02/graph_trans-prod.exe` (bce0875f), equal to sonnet's two Graph tools
  after the same two fields are zeroed. The working set after the slice: the tool `ps-tool-r101`, the frontend
  `fable-s3-feh01`, the runtime `fable-s3-rt02`, the Graph tool `fable-s3-graph02`.
- Rows, each in the three modes interp / native / forced: 342 rows -- the 334 of the acceptance of slice 4
  (`../binding-callables-slice4-20261120/witness-rows.tsv`) and the 8 of this slice. Sonnet ran them on the accepted
  set of slice 4 and on the candidate; Fable ran them on the chain above. `witness-rows.tsv` holds the verdict
  before (the base) and after (Fable's run); Fable's run and the candidate's give the same verdict in every mode of
  every row, and no row ran into the time limit.
  - Green in all three modes: 275 before, 281 after.
  - Six rows change the verdict, all from red to green: `bind_private_receiver`, `bind_private_receiver_write`,
    `bind_private_write_own_copy` and the three re-pinned rows. The base run reproduces the «after» of slice 4 in
    every row but those three, which are red on the base at their new pins.
  - The other five new rows are green before and after: the rules they pin held before the slice and still hold.
  - The 61 rows that are not green are the ones that were not green after slice 4, in the same modes.
- Mutants, sonnet, each in a stage of its own with its own runtime and Graph tool, 11 rows × 3 modes: m1 (the
  receiver's condition removed) is killed by six rows -- the three rows of the receiver and the three re-pinned
  ones; m3 (`lmx_graph_lexical_private` true for a private declaration of an outer level too) is killed by
  `bind_private_outer_not_barrier` alone.
- Probes in the interpreter on the Graph tool of the base and of the candidate, sonnet (`probes.tsv`, 14 probes):
  three change -- B11 11 → 7, a nested lexical read of the private declaration 11 → 7, the write under the
  protected declaration 111237 → 110797; the explicit supply, the explicit path, the shadowing and the continued
  search do not change.
- Emitter: the native image calls the kernel's resolver, so the emitted `p.lm1` of every row is byte-equal before
  and after in the modes native and forced (682 of 682 images, sonnet).
- The eight kernel self-tests of the graph, the rows `dyn/graph_*` of `selfbuild/tests/full-suite.tsv`: green on
  the chain above, inside the full suite.

## Two kernel self-tests were red since 2026-11-18

Found by sonnet when the self-test of the slice was run: `graph_private_binding` failed in case 117 on the candidate
and on the accepted set of slice 4 alike. Fable ran the eight rows `dyn/graph_*` on the accepted set: two were red,
`graph_private_binding` (case 117) and `graph_call_values` (case 156). The component acceptances since 2026-11-18
had not run them. Bisect with the runtimes kept in the stage: `ps-rt-m102` (2026-11-18, 10:53) is green on both,
`ps-rt-s201` and `ps-rt-s218` -- builds of the slice «the body scan at the entry of a call is removed»
(`5bd50034`, `../one-graph-entry-scan-removed-20261118/notes.md`) -- are red on both; the full suite of the stage
border of that morning had both green.

Both cases pinned the capture of a free name at the entry of a call, which that slice removed by the author's
decision of 2026-11-18 (`LMX_blog/2026-11-18.md#interpreter-builds-nothing`, `#one-level-scan-for-namespace`): a
free name is resolved when it is first read. They are outdated expectations, not defects of the kernel (Р115).

- Case 117, `LazySnapshot`: the first read of `x` stands after the write `LazyLibrary[0][1] := @five`, so the
  binding made at that read sees the changed description: 5, and `private_bump` is not called. The cases 117 and 118
  expect 5 with the counter 0; before, 9 with the counter 1.
- Case 156, `FreeEcho`: the test cleared the input of the native parent during the call, so that only a snapshot
  taken at the entry could answer the later read. Sonnet's diagnostic run: with the clearing the read answers 3,
  the name has no source; without it every other check of the case holds. The clearing, the check that it happened
  and the restoring copy are removed; the case pins that the first read after the call and the collection returns
  the same record byte for byte with its metadata alive.

## The full suite

Two red self-tests outside the small lists are «local results that point to a general regression» in the words of
the build order (`to_fable2_fast_build.md`), so the full suite was run once, on the chain built from the final
sources, with the two corrected self-tests: `SUITE 210 rows, 44 failures`, 1450 PASS lines, 17.6 minutes. The red
names are sixteen -- the same sixteen as at the stage border of 2026-11-18
(`../m10-code-places-step1-20261117/full-suite-red-names.txt`), whose run gave the same three numbers. No row became
red since the border and none became green. The eight rows `dyn/graph_*` are green in every mode. From this step on
these eight rows belong to the addressed checks of every slice of the kernel.

## Open, not in this step

- Row B12 (a private receiving place is not autofilled) and B09 (a private source gives no autofill) wait for
  autofill, step 21.4.
- §14 of the requirement asks for the key rows in the four combinations of native and walker. The three modes of
  `graph-check` do not separate «native caller, walked callee» from the other pairs; there is no such row yet. It
  is due with the native ABI, step 21.20.
- The rows are written in the former forms `fn: f () int` and `sub: main ()`; they are migrated at step 21.21.
- The 61 rows that are not green are not touched by the slice.

## What the running program holds after the step

When a callee uses a name it does not declare, and the declaration it sees lexically for this name is marked
`private`, the name is that declaration: a public place of the same name in a calling activation does not replace
it. The read takes the lexical value. A bare write goes to the callee's own copy and leaves the owner's place; the
owner's place is changed by an explicit path or `node`. A private declaration of an outer lexical level that the
name does not resolve to is no barrier. A value supplied explicitly reaches a private input, and a value read from a
private source can be supplied explicitly.

## Files beside these notes

- `witness-rows.tsv`: the 342 rows -- the list a row comes from, its pin, the verdict before and after.
- `probes.tsv`: the 14 probes on the Graph tool of the base and of the candidate.

Receipts outside the repository: `build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01/fable`,
directories `tz-20261121/slice3-finish` (the delivery: `REPORT.md`, the logs of the runs, of the mutants and of the
chain, the diagnostic runs of case 156) and `tz-20261121/accept-s3` (the acceptance: the manifests, the build logs,
`acc.log`, the bisect logs, the log of the full suite and its red names).
