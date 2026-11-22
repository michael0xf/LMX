# The word of the receiver in the code: `implements` becomes `satisfies` (step 22.4 of the edition of 2026-11-22)

Written 2026-11-23 by Fable, the coordinator and the single writer of main. This is step 22.4 of the plan section
`next_core_tasks_v3.md#docs-20261122`. The inventory of the places is by the peer session haiku, the reviewed
scenario of the change by the peer session sonnet; Fable found the place where a plain replacement breaks the
kernel, decided what the step covers (the executor's answers Р141 and Р142 in
`LMX_blog/q/fable-self-answers-20261110.md`), applied the scenario, built every component from the tree and ran the
checks.

## The norm

- The edition of 2026-11-22: the receiver of the conformance check is `satisfies`; the former spelling is not a
  second public name ([the book](../../../docs/spec/LMX_semantics.en.md#fn-satisfies)).
- The book on handlers ([`catch` in the common model](../../../docs/spec/LMX_semantics.en.md#catch-common-model)):
  a language operator whose `throws` list is not written throws a named failure with its own name. The refusal of
  an admission is thrown by the receiver of the conformance check, so the implicit failure is named `satisfies`
  too, and a program catches it with `catch: satisfies ()` (Р142).

## What changed

- 45 string literals in eight sources of the kernel and the frontend: 16 diagnostics (`satisfies is false in …`),
  8 text comparisons, 17 arguments naming the implicit failure, the table of implicit names, the list of language
  words, the seed of the word in the kernel's table of ids.
- The seed passes the length of the word as a number: `"implements", 10U` became `"satisfies", 9U`. A plain
  textual replacement leaves 10 and no graph starts; this is the one place where the change is not textual.
- `selfbuild/tools/build.lm2`: 19 places, the word inside comments of generated headers.
- 104 test programs: the line `catch: implements ()` (100 under `selfbuild/tests`, 4 under `tests/l2`); three
  expected `refuses` rows (`selfbuild/tests/full-suite.tsv`, `tests/l2/suite.tsv`); 29 comments of tests.
- Not changed by this step: internal identifiers and file names with the former stem (162 names, 1859
  occurrences) and the 70 comments of the kernel sources that name them — one mechanical step before the stage
  border (plan step 21.22), because a change of exports needs a whole self-build; the word `fn` in the word lists;
  the tools of the former pipeline in the root `tools/`; labels of recorded rules written in capitals.

## Acceptance by the component cycle

No whole bootstrap, no fixedpoint and no full suite were run.

- Source manifest: 1555 inputs, SHA f0b998ab…, generated and verified by Fable for the repository and the stage.
- The chain from the final sources, by the accepted set of step 21.5 with the tool of the documentation move
  (`fable-d1-tool01`): tool, runtime (driver.o 5b0a53ca, driver-observe.o 88ea96f2), hosted frontend
  `fable-b4-feh01/l2trans.exe` (9772e000), runtime again by that frontend (byte-equal), Graph tool
  `fable-b4-graph02/graph_trans-prod.exe` (963df717); then the tool once more by the new frontend and the new
  runtime: `fable-b4-tool02/lmxtool-tool.exe` (2be4b7dc).
- The family of the receiver in the full suite, 47 rows (35 programs that catch the implicit failure, the two
  `os_implements` rows, two `refuses` rows, the nine kernel self-tests `dyn/graph_*`): run with their old text on
  the accepted set before the change and with the new text on the new set after it. The verdict lines are equal
  one by one: 177 lines, 152 PASS and 25 FAIL in both runs. The red names of the family (`callable_place_fields`,
  `explicit_data_var_field`, `free_graph_address`, `free_model_admit`, `place_map`, `place_write_form`,
  `source_occurrences`, `structure_path_write`, `unit_n4_inline_named_incompatible`, `written_form`,
  `written_path_form`) are among the sixteen known red names of the full suite
  (`../m10-code-places-step1-20261117/full-suite-red-names.txt`); the nine self-tests are green.
- Two graph rows whose programs use words standing beside the changed one in the list of language words
  (`marks_immutable_code`, `marks_chain_code`): green in three modes on the new Graph — the seed of the words is
  accepted.
- Parser suite on the new Graph: 169 cases, none failed.
- The old set does not run programs with `catch: satisfies ()` and the new set does not run
  `catch: implements ()`: the programs and the kernel change in one step.
