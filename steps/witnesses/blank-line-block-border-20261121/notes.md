# A blank line is the full border of a block (step 21.3 of the edition of 2026-11-21)

Written 2026-11-21 by Fable, the coordinator and the single writer of main. This is step 21.3 of the plan section
`next_core_tasks_v3.md#docs-20261121`. The change of the parser, the removal of blank lines from the self-build
sources, the 29 parser cases, the divergence records and the ten mutants are by the peer session sonnet, on the
pipeline token; the first list of blank lines inside blocks was made by the peer session haiku. Fable set the
bounds before the code (the executor's answer Р118 in `LMX_blog/q/fable-self-answers-20261110.md`), read the
requirement and the diff of the parser, generated and verified the manifest, built the tool, the runtime, the
hosted frontend and the Graph tool from the tree, re-ran the parser suite on the new and on the accepted Graph,
the P0 trees of the whole self-build corpus under both rules, the 388 rows and the nine kernel self-tests,
reproduced two mutants and answered the helper's five questions (the answer Р131 of the same ledger).

## The norm

The author's requirement of 2026-11-20, `docs/TZ/LMX_Fable_TZ_Blank_Line_Block_Terminator_2026-11-20.md`; the
grammar, §15–§18, §24, §25. A blank physical line outside shielded content equals a closing `---` at the virtual
level −1, above the root level 0: it closes every open form of the current document back to its root, at once.

- Blank is a line of no characters, or of spaces and tabs only. A line with `#`, with level dots or with any
  other text is not blank. Blank lines inside string literals, exact identifiers, block text and raw comments are
  their content.
- The blank line adds no field, no empty Structure, no call and no `return`. Blank lines in a row, at the start
  and after a closed block close nothing more.
- The next indent is read by the ordinary rules of the new root context and cannot resume the closed form.
- A closure that runs into an unclosed `(` or `[` is an error on the blank line, naming the opening delimiter.
- A Mix document closes to its own local root; a queue of Mix-only lines ends at the border.
- The end of the file closes as before. One newline between two non-blank lines stays an ordinary separator;
  `---`, `end:` and the level transitions stay.

Before the step P0 skipped a blank line as it skips a comment line, and the Factory example of the requirement
failed with code 13.

## What changed

- Part A, the sources. 114 blank lines inside blocks are removed from 11 self-build sources -- `convert`,
  `l1_backend_emit`, `l1_backend_text`, `l2_frontend_lower`, `lmx_root`, `p0_parser`, `primitive` in
  `selfbuild/src/l2src` and `os_file_open`, `os_filesystem`, `os_paths`, `os_windows_paths` in `selfbuild/tools`
  -- and three `\n\n` inside the generated declaration texts of `selfbuild/tools/build.lm2` became `\n`. The
  part is neutral: the P0 trees of the 11 files are equal before and after, and the chain built after it alone
  gave the runtime, the hosted frontend and the Graph tool of step 21.4 (the helper's chain `son-a`).
- Part B, the parser, `selfbuild/src/l2src/p0_parser.lm2`:
  - `lm_p0_stream_apply_blank`: the queue of Mix-only lines is flushed, a pending delimiter is resolved at the
    level −1 through the common mechanism, the stack is cut back to the root, the indent stack is reset;
  - `lm_p0_parse_stream` calls it for an empty physical line and for a line of spaces and tabs, before the
    common skip; a `#` line and a line of level dots keep their former branches;
  - the stream event `LM_P0_STREAM_EVENT_BLANK` for the check of a block disabled by `%`
    (`lm_p0_disabled_scan_next_event`, `lm_p0_disabled_state_accept_event`);
  - `lm_p0_blank_after_open_pair`: the error of an unclosed pair, code 5, moves to the blank line and names the
    opening delimiter.
- `selfbuild/tools/build.lm2`: `LM_P0_STREAM_EVENT_BLANK 6` in the generated declarations of P0. The tool is
  therefore rebuilt.
- `tests/parser/current`: 29 new cases `blank_*` -- the sixteen checks of §5, the Factory example, the pairs of
  check 6 at one, two and three levels and four cases added on the way; the suite has 169 cases. Their
  expectations were derived by hand from the requirement and the grammar, not copied from a run
  (`parser-cases.tsv`).
- `tests/parser/previous-l1`: 14 of the 131 legacy cases change their output because of a blank line. Ten get
  new divergence records and goldens; the four that had records -- `t0`, `t1`, `t2`, `test4` -- get the reason
  extended. `t1` and `t2` are now refused with code 17, and their goldens are the text of the diagnostic. The
  imported corpus is not touched.
- `selfbuild/inputs.list` is unchanged: 1462 lines.

## Acceptance by the component cycle

This is a component acceptance by the author's order on the build cycle (`to_fable2_fast_build.md`): no whole
bootstrap, no fixedpoint and no full suite were run. The step changes the parse of every self-build source, which
is a ground for the whole bootstrap at the stage border, step 21.22.

- Source manifest: 1462 inputs, SHA 5bc5334d…, generated and verified by Fable with the accepted tool
  `fable-p4-tool01` (ac4a5146) for the repository and for the stage; it equals the helper's final manifest. The 58
  changed and new files of the tree equal the helper's list of hashes.
- The chain from the final sources, built by Fable from the accepted set of step 21.4:
  - `build-self` gave `fable-b3-tool01/lmxtool-tool.exe` (fb3fbfbd), equal to the helper's `son-b-tool01` after
    the two build fields of the PE header, TimeDateStamp and CheckSum, are zeroed;
  - `build-runtime` by the accepted frontend gave `driver.o` 29025785 and `driver-observe.o` cf247b29 -- the
    bytes of the accepted runtime: P0 is not a part of the runtime;
  - `build-frontend-host` gave `fable-b3-feh01/l2trans.exe` (cfbf530f), equal to the helper's `son-b-feh01`
    under the same mask;
  - `build-runtime` by that frontend gave `fable-b3-rt02`, byte-equal to the first runtime: the frontend with
    the new rule translates every source of the runtime to the same code;
  - `build-graph` gave `fable-b3-graph02/graph_trans-prod.exe` (8d855aac), equal under the mask to the
    helper's `son-b-graph02`.

  The working set after the step: the tool `fable-b3-tool01`, the frontend `fable-b3-feh01`, the runtime
  `fable-b3-rt02`, the Graph tool `fable-b3-graph02`.
- The parser suite, 169 cases. On the new Graph: 0 failed. On the accepted Graph: 14 failed -- 12 of the new
  cases and the two legacy goldens `t0` and `test4`; the other 17 new cases pin what held before the step.
- The P0 trees of the self-build corpus, 1163 files -- the 946 sources of `selfbuild/inputs.list` and 217
  generated `.lm1` files of the stage: the accepted Graph and the new Graph give the same tree for every file.
- Rows, each in the three modes interp / native / forced, run by the new tool: the 388 rows of the acceptance of
  step 21.4 (`../binding-callables-slice2-20261121/witness-rows.tsv`). 327 are green before and after, no row
  changes its verdict, no row ran into the time limit; Fable's run and the helper's agree in every mode of every
  row (`witness-rows.tsv`).
- The nine kernel self-tests of the graph, the rows `dyn/graph_*`: green on the accepted set and on the chain
  above, 9 rows and 0 failures in each run.
- Mutants, the helper, each in a stage of its own with its own Graph tool, then the whole parser suite
  (`mutants.tsv`): ten mutants, nine killed. Fable reproduced two with its own tool and
  stage on the suite of 169 cases: m1 fails seven cases -- the helper's six and `blank_18b`, added after the helper's
  run of m1 --, m7 fails `blank_14b`.
  - m9 survives and is equivalent: a pending delimiter that the blank line does not resolve is resolved by the
    next line into the same tree, because the stack is already cut back to the root; the flags the resolution
    sets are read nowhere. The call stays: it is the common mechanism of closing at the level −1.
  - Two mutants of the plan cannot be made by one anchored edit: the blank line of a Mix applied to the outer
    document, and an end of file that needs a blank line. Their cases are in the suite (10, 10b, 11a, 11b).
- The author's examples, 227 programs (the helper's run): of the 103 that failed with code 13 on a line after a
  blank line 102 parse now; the 117 that parsed give the same tree.

## The checks of the requirement that needed a reading

- Check 13, parse → print the source → parse again. There is no printer of L3 source, and the dump of the graph
  is not source. The sources this tree generates are three, and the check holds on each: the declaration texts
  written by `tools/build.lm2` (three literals with a blank line inside a block were corrected by part A); the
  generated L1 (217 files with equal trees under both rules, and a runtime built by the new frontend byte-equal to
  the one built by the accepted frontend); the programs the graph emitter writes for the modes native and forced
  (the 388 rows are built by the new frontend, the verdicts are the same).
- Check 10, two blocks inside a Mix. With the blocks indented the expectation has two anonymous Structures: an
  indented first line of a document opens one (the accepted case `mark_comment_multiline`), and after the blank
  line the indented line starts from the local root and opens its own (check 6). With the blocks at column zero
  there is none (case 10b). The mutant m1 is killed by case 10.
- `end: A` after a blank line. P0 has never checked the target of a closing word: on the accepted Graph a lone
  `end: A` at the root is an ordinary record, and `end: B` closes `A` with no diagnostic. The rejection of an
  invisible target (the grammar, §17) is made by the graph builder: a record headed `end` that P0 attached to no
  Frame is a stray trailer, and the construction answers 2. After a blank line `end: A` is such a record. No new
  diagnostic is added to P0 by this step.

## Seven examples of the author that do not parse

Check 16 keeps the error of a level drop of more than one step without a blank line and without `---`. Seven
programs of `docs/new_parts` have such a drop and are refused with code 13, before and after the step; they need
`---` or a blank line at the named place. The seventh was hidden by the earlier error on its blank line.

| Program | Place |
|---|---|
| `03_domain_and_persistence/examples/lmx/017_unit_of_work.lm3` | 15:5 |
| `03_domain_and_persistence/examples/lmx/095_specification_combinator_implementation.lm3` | 10:5 |
| `04_events_and_consistency/examples/lmx/041_saga.lm3` | 18:9 |
| `04_events_and_consistency/examples/lmx/086_idempotent_consumer_inbox.lm3` | 10:5 |
| `05_cloud_and_resilience/examples/lmx/087_backpressure.lm3` | 16:9 |
| `05_cloud_and_resilience/examples/lmx/097_retry_library_implementation.lm3` | 23:9 |
| `05_cloud_and_resilience/examples/lmx/054_competing_consumers.lm3` | 20:5 |

`examples/lmx/R02.lm3` does not parse either: its group on the left of `:=` is step 21.12.

## Open, not in this step

- The whole bootstrap with the new rule is due at the stage border, step 21.22.
- The stray-trailer refusal of the builder has no row in the accepted list of 388.
- The flags `LM_P0_FRAME_DELIMITER_CLOSED` and `LM_P0_TRAILER_DELIMITER_CLOSED` are written and read nowhere.
- The legacy cases `t1` and `t2` are refused now; their inputs are the imported corpus and are not rewritten.

## What the program text means after the step

Root declarations separated by one blank line need no `---` and no `end:` whatever the depth of the block above:
the blank line closes it to the root. A blank line inside a block ends the block: the indented line after it is
not a continuation, it starts from the root and opens an anonymous Structure, and a later return to the former
indent is refused. A blank line between `(` or `[` and its closing delimiter is an error on that line. Inside a
Mix the same holds for the Mix alone. Text inside literals, block text and raw comments keeps its blank lines.

## Files beside these notes

- `witness-rows.tsv`: the 388 rows -- the list a row comes from, its pin, the verdict before and after.
- `parser-cases.tsv`: the 29 new parser cases -- the expectation, the verdict on the accepted and on the new Graph.
- `mutants.tsv`: the ten mutants of the helper -- the change, the verdict, the cases that fail.

Receipts outside the repository: `build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01/fable`,
directories `tz-20261121/step-21-3` (the delivery: `DESIGN.md`, `REPORT.md`, the scripts of the edit, the probes,
the logs of the chains, of the suites and of the mutants, `examples-defects.md`) and `tz-20261121/accept-21-3`
(the acceptance: the manifest, the build logs, the suite logs, the corpus tables, `acc.log`, the self-tests, the
two mutants).
