# One contract of a place: own place, the caller's transparent place, the former binding (slice 2 of «binding and callables»)

Written 2026-11-21 by Fable, the coordinator and the single writer of main. This is step 21.4 of the plan section
`next_core_tasks_v3.md#docs-20261121`, step 2 of `#binding-callables-20261119`. The design, the change of the kernel
and of the emitter, the 46 rows, the kernel self-test, the six re-pins and the 22 mutants are by the peer session
opus, on the pipeline token. Fable set the bounds before the code (the executor's answers Р110 and Р114 in
`LMX_blog/q/fable-self-answers-20261110.md`), read the design and the final diff, stopped the second candidate for
its speed, generated and verified the manifest, built the tool, the runtime, the hosted frontend and the Graph tool
from the tree, re-ran every row, ran the nine kernel self-tests on the base and on the candidate, measured the
interpreter and reproduced two mutants. The decisions of the acceptance are the answer Р128 of the same ledger.

## The norm

The author's requirement of 2026-11-19, `docs/TZ/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md`: decisions
R01–R04, §6.1–§6.4, §7.3, §7.4, §9.7, rows B01–B08 and B18–B23. A place has one contract whatever gives it.

- An own place: an explicit argument, an own value, or autofill -- an input with no argument and no value of its
  own takes the value of the same-named place of the immediate caller, when neither the place nor the source is
  `private` and the ordinary contract of the place takes the value (R03, §6.1). The value goes into the input's
  own cell.
- The transparent place of the caller: a name the callee does not declare, whose source is a place of the
  immediate caller, denotes that place itself; a write reaches the caller at once, with no copy back (R04, §6.2).
- The former binding, as the fallback: every other source gives an own copy, as before (R01, R02, §6.3).
- A chain A → B → C keeps the former reach; every use of a name chooses the binding of its activation (§6.4).
- A reached `required:` over names checks that the place each name denotes is initialized (§9.7; the book,
  `#required-receiver`).

The executor's readings. Р110: a write into a copy taken from a `const` source is refused; autofill takes the
immediate caller only, and nothing where the contract of the place does not take the value; a computed place of
the caller is computed once and stays in the place; autofill happens at entry. Р114: five accepted rows change
their pins by R04; a computed place of the caller is computed in the activation of its owner; autofill is one
rule for every own declared place created without a value, a declaration reached in the code included.

Before the slice a free name was always a copy: a bare write changed only the callee's activation, and an input
without a value stayed without one.

## What changed

- `selfbuild/src/l2src/lmx_graph_run.lm2`, +239 −29:
  - the link row: a used name whose source is a row of the immediate caller (`lmx_graph_caller_place`) gets a row
    whose value is a link, `LMX_WALK_VALUE_PLACE` (the caller's frame and the index of its row); every reader and
    every store follows it (`lmx_graph_work_target`); any other source keeps the copy;
  - autofill, `lmx_graph_work_autofill`, at the open of a launch and at a declaration without a value reached in
    the code (`lmx_graph_place_without_value`): the immediate caller only; neither side private, the receiving
    side read from the record as written (`lmx_graph_written_of`); the kind must match; a computed source is
    computed once; the value goes into the place's own cell;
  - the computation of a place by its owner: `lmx_graph_work_load` finds the owner of the row
    (`lmx_graph_row_owner`), pushes a representative activation record over the running chain and pops it after,
    so the physical chain the collector walks is kept;
  - the stale row pointer: `lmx_graph_work_load` takes `@@: place` and takes the row again by its index after
    the computation, because the computation may grow the rows of the frame, and grown rows move;
  - a read is a use: `lmx_graph_named_int` takes the name (`lmx_graph_input_take`), as the writes, `@name` and
    `lmx_graph_operand_read` did; a repeated use returns at once on the existing row;
  - `required:` over names: `lmx_graph_required_names` and `lmx_graph_block_required`, before the modifiers over
    declarations, which count a written name as a declaration.
- `selfbuild/src/l2src/lmx_call.lm2`, +20: `lmx_activation_stand` and `lmx_activation_next` map a representative
  record (kind 3) to its owner for the searches of names. `selfbuild/src/l2src/lmx_walk_values.lm2`, +3 −3: the
  two searches of names use them.
- `selfbuild/src/l2src/l2_graph_tool.lm2`, +11: the emitter has its own statement loop; it emits the call of
  `lmx_graph_block_required` for the line.
- `selfbuild/tools/build.lm2`, +10 −6: `LMX_WALK_VALUE_PLACE 6`, two prototypes, the machine names of `lmx_call`
  (19 → 21) and of `lmx_graph_run` (80 → 82). The tool is therefore rebuilt.
- The diff adds no `end:` and no blank line inside a block; two added `---` lines each close a drop of two levels.
- Rows, `selfbuild/tests/graph`, 46 new (92 files). The last column is the helper's run of the same row on the
  base Graph: 23 are green there -- the rules they pin held before the slice -- and 23 are red.

  Part I, the contract of a place:

  | Row | Pin | Observed | Norm | On the base |
  |---|---|---|---|---|
  | `bind_place_autofill_read` | `0 1 0` | `seen 5` | B01 | red |
  | `bind_place_autofill_own` | `0 1 0` | `seen 559` | B01 | red |
  | `bind_place_free_write` | `0 1 0` | `seen 909` | B02 | red |
  | `bind_place_fallback_lexical` | `0 1 0` | `seen 509` | B03 | green |
  | `bind_place_type` | `0 1 0` | `seen 20202` | B04 | green |
  | `bind_place_address_own` | `0 1 0` | `seen 509` | B05 | green |
  | `bind_place_address_free` | `0 1 0` | `seen 909` | B05 | red |
  | `bind_place_address_fallback` | `0 1 0` | `seen 509` | B05 | green |
  | `bind_place_reference` | `0 1 0` | `seen 49` | B06 | red |
  | `bind_place_uninit_caller` | `0 1 0` | `seen 909` | B07 | red |
  | `bind_place_nested_sees` | `0 1 0` | `seen 909` | B08 | red |
  | `bind_place_const` | `1 1 4` | `seen 0` | B18 | green |
  | `bind_place_chain_fallback` | `0 1 0` | `seen 506` | B19 | green |
  | `bind_place_chain_copy` | `0 1 0` | `seen 50909` | B20 | red |
  | `bind_place_chain_alias` | `0 1 0` | `seen 90909` | B21 | red |
  | `bind_place_default_kept` | `0 1 0` | `seen 703` | B22 | green |
  | `bind_place_computed_default` | `0 1 0` | `ticks 0; seen 3; unused 1` | B23 | green |
  | `bind_place_const_fallback` | `1 1 4` | `seen 0` | Р110.1 | green |
  | `bind_place_autofill_private` | `1 1 5` | `seen 0` | Р110.2 | green |
  | `bind_place_autofill_absent` | `1 1 5` | `seen 0` | Р110.2 | green |
  | `bind_place_autofill_kind` | `0 1 0` | `seen 1` | Р110.3 | green |
  | `bind_place_autofill_kind_read` | `1 1 5` | `seen 0` | Р110.3 | green |
  | `bind_place_autofill_receiver_private` | `1 1 5` | `seen 0` | B12 | green |
  | `bind_place_code_autofill_read` | `0 1 0` | `seen 5` | Р114 | red |
  | `bind_place_code_autofill_own` | `0 1 0` | `seen 559` | Р114 | red |
  | `bind_place_code_autofill_nested` | `0 1 0` | `seen 75` | Р114 | red |
  | `bind_place_code_autofill_repeat` | `0 1 0` | `seen 3` | Р114 | green |
  | `bind_place_code_autofill_private` | `1 1 5` | `seen 0` | Р114 | green |
  | `bind_place_code_autofill_source_private` | `1 1 5` | `seen 0` | Р114 | green |
  | `bind_place_code_autofill_kind` | `1 1 5` | `seen 0` | Р114 | green |
  | `bind_place_owner_refusal` | `1 1 3` | `seen 0` | Р110.4 | red |
  | `bind_place_owner_refusal_own` | `1 1 3` | `seen 0` | Р110.4 | green |
  | `bind_place_computed_once` | `0 1 0` | `ticks 1; seen 80` | Р110.4 | green |
  | `bind_place_computed_context` | `0 1 0` | `seen 4` | Р110.4 | red |
  | `bind_place_autofill_entry` | `0 1 0` | `ticks 1; seen 1` | Р110.5 | red |
  | `bind_place_chain_reference_read` | `0 1 0` | `seen 90409` | B21 | red |
  | `bind_place_chain_reference_pass` | `0 1 0` | `seen 90409` | B21 | red |

  Part II, `required:` over names:

  | Row | Pin | Observed | Norm | On the base |
  |---|---|---|---|---|
  | `bind_place_required_transit` | `0 1 0` | `seen 505` | B19, B-04 | green |
  | `bind_place_required_connected` | `0 1 0` | `seen 808` | B21, B-04 | red |
  | `bind_place_required_uninit` | `1 1 5` | `seen 0` | TZ §9.7 | red |
  | `bind_place_required_absent` | `1 1 3` | `seen 0` | TZ §9.7 | red |
  | `bind_place_required_autofilled` | `0 1 0` | `seen 7` | TZ §9.7 | red |
  | `bind_place_required_inline` | `1 1 5` | `seen 0` | TZ §7.4, §9.7 | red |
  | `bind_place_required_computed` | `0 1 0` | `ticks 0; seen 1` | TZ §9.7 | green |

  Part III, the stale row pointer:

  | Row | Pin | Observed | Norm | On the base |
  |---|---|---|---|---|
  | `bind_place_stale_current` | `0 1 0` | `seen 1010` | the design, §1.4 | red |
  | `bind_place_stale_caller` | `0 1 0` | `seen 1010` | the design, §1.4 | green |

- Six accepted rows are re-pinned by R04 (Р114, item 1, and `body_fields` by the same rule); their headers say
  what was pinned before:

  | Row | Before | After |
  |---|---|---|
  | `scan_free_name_written` | `r 5; rx 10` | `r 5; rx 5` |
  | `scan_free_name_address_first_use` | `r 7; rx 10` | `r 7; rx 7` |
  | `scan_free_name_address_assigned` | `r 7; rx 10` | `r 7; rx 7` |
  | `node_write` | `after_bare 4` | `after_bare 5` |
  | `dynamic_inputs` | `x 20; unchanged 5; outside 20; next_relay 20` | `x 22; unchanged 7; outside 22; next_relay 22` |
  | `body_fields` | `outside 90` | `outside 7` |

- The kernel self-test `selfbuild/tests/dyn/graph_place_owner.lm2` and its row in `selfbuild/tests/full-suite.tsv`:
  while a place of a caller is computed in the activation of its owner, the activations between them stay on the
  chain the collector walks. The expected number is 99.
- `selfbuild/inputs.list`: 1369 → 1462 lines.

## Acceptance by the component cycle

This is a component acceptance by the author's order on the build cycle (`to_fable2_fast_build.md`): no whole
bootstrap, no fixedpoint and no full suite were run.

- Source manifest: 1462 inputs, SHA 8205dbcb…, generated and verified by Fable with the accepted tool
  `ps-tool-r101` (f0e186f4) for the repository and for the stage; it equals the helper's final manifest. The 112
  changed and new files of the tree equal the helper's list of hashes.
- The chain from the final sources, built by Fable from the accepted set of slice 3:
  - `build-self` gave `fable-p4-tool01/lmxtool-tool.exe` (ac4a5146), equal to the helper's `opus-p4-tool02` after
    the two build fields of the PE header, TimeDateStamp and CheckSum, are zeroed;
  - `build-runtime` by the accepted frontend gave `driver.o` 29025785 and `driver-observe.o` cf247b29;
  - `build-frontend-host` over that runtime gave `fable-p4-feh01/l2trans.exe` (4e95f919), equal to the helper's
    `opus-p4-feh31` under the same mask;
  - `build-runtime` by that frontend gave `fable-p4-rt02`, byte-equal to the first runtime and to the helper's
    `opus-p4-rt31` and `opus-p4-rt33`;
  - `build-graph` gave `fable-p4-graph02/graph_trans-prod.exe` (3044e168), equal under the mask to the helper's
    `opus-p4-graph31` and `opus-p4-graph33`.

  The working set after the slice: the tool `fable-p4-tool01`, the frontend `fable-p4-feh01`, the runtime
  `fable-p4-rt02`, the Graph tool `fable-p4-graph02`.
- Rows, each in the three modes interp / native / forced, run by the new tool: 388 rows -- the 342 of the
  acceptance of slice 3 (`../binding-callables-slice3-20261121/witness-rows.tsv`) and the 46 of this slice.
  `witness-rows.tsv` holds the verdict before (the base) and after (Fable's run).
  - Of the 342 base rows 281 are green in all three modes before and after; no base row changes its verdict.
    The five re-pinned rows other than `body_fields` are green under the new pins; on the base Graph the six are
    red under them (the helper's run).
  - The 46 new rows are green.
  - Fable's run and the helper's run of the candidate give the same verdict in every mode of every row, and no
    row ran into the time limit.
  - `body_fields` is red on the base and on the candidate, for reasons outside the slice. Its expected dump pins
    evaluated values of computed root declarations, and today's dump prints those declarations unevaluated. On
    the candidate the re-pinned line gives 7; the run is then refused with 3 at a local of the code read through
    `data`.
- The nine kernel self-tests of the graph, the rows `dyn/graph_*` of `selfbuild/tests/full-suite.tsv`: green on
  the accepted set of slice 3 and on the chain above, 9 rows and 0 failures in each run.
- The interpreter, Fable's probe (a loop of 200000 passes with four int assignments, one process at a time):
  6.4 and 6.7 s on the candidate against 12.9 and 13.6 s on the accepted Graph, with the same result. The second
  candidate of the helper put the take of a name on every int read and ran the probe 2.1 times slower; Fable
  stopped it, and the third candidate returns at once on a repeated use of a name.
- Mutants, the helper, each in a stage of its own with its own runtime and Graph tool, the 52 rows of the step in
  three modes (`mutants.tsv`): 22 mutants, 20 killed -- 19 by rows, m14 only by the self-test `graph_place_owner`,
  five runs of five. Fable reproduced two with its own tool and stage: m1 (no transparent place) changes
  15 rows, the same rows as in the helper's run; m14 (a bare change of the head of the chain
  instead of the representative) changes no row and fails the self-test: the call answers `status=4`.
  The number printed beside that status is not an answer and differs between runs: 234 in the helper's five
  runs, 0 and 315 in Fable's.
  - m13 survives and is equivalent: the function it changes has one caller, which maps the answer it changes,
    3, to 0.
  - m20 survives: it widens the fast path of a repeated use to every row of the activation. A program that tells
    it apart needs an `fn:` or a `break` inside a block, and both are refused by the build today.

## A limit of the witness: the answer of a refusal in the native modes

`graph-check` compares the number of the answer of a refusal row in the interpreter only. The native and the
forced programs must not succeed and must print the same dump (`selfbuild/tools/build.lm2`, the comment of
`bld_graph_check`). So the 14 refusal rows of the slice pin the number of the answer -- 3, 4 or 5 -- for the
interpreter, and for the native modes only the refusal and the dump. For that reason the mutants m5 (no kind
check in autofill) and m18 change the verdict of their refusal rows in the interpreter alone. This is a property
of the check, older than the slice; the number of the answer of a native refusal is due with the native ABI,
step 21.20.

## Found on the way

- The stale row pointer is older than the slice: in the current frame it showed as a heap corruption, 0xC0000374,
  exactly at the growth threshold of the frame. `bind_place_stale_current` is red on the base for that reason.
- Two statements of the design were wrong and were found by the runs. The counter of declarations of a modifier
  counts a written name as a declaration, so the first candidate never reached the new check of `required:`.
  The emitter has its own statement loop, so in the second candidate the native image skipped the line.

## Open, not in this step

- `body_fields` stays red; it is not a row of this slice.
- `lmx_graph_fn_apply` gives a capture row its own cell when a local callable is named like a used free input;
  for a link row the link would stay. No row reaches it today, there is no protective branch, and executable
  `fn` leaves at step 21.7. The survivor m20 is looked at again there.
- §14 of the requirement asks for the key rows in the four combinations of native and walker; the three modes of
  `graph-check` do not separate them. Due with the native ABI, step 21.20.
- The rows are written in the former forms `fn: f () int` and `sub: main ()`; they are migrated at step 21.21.
- The 61 rows that are not green are not touched by the slice.

## What the running program holds after the step

An input of a callee that got no argument and has no value of its own takes, at entry, the value of the
same-named place of the immediate caller -- when neither is private and the value is of the kind the input
takes -- into its own cell; later writes of the callee stay in the callee. The same holds for a declaration
without a value reached in the code. A name the callee does not declare, when the immediate caller holds a place
of that name, is that place: the callee's write is seen by the caller at once, through one or several calls. Any
other source gives the callee a copy, as before. A computed place of the caller is computed once, with the names
of its owner, whoever reads it first. `required: a b` refuses with 3 when a name denotes no place and with 5 when
its place holds no value, and computes nothing.

## Files beside these notes

- `witness-rows.tsv`: the 388 rows -- the list a row comes from, its pin, the verdict before and after.
- `mutants.tsv`: the 22 mutants of the helper -- the change, the verdict, the rows that change.

Receipts outside the repository: `build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01/fable`,
directories `tz-20261121/step-21-4` (the delivery: `DESIGN.md`, `REPORT.md`, the scripts of the edit, the logs of
the runs, of the mutants and of the chains) and `tz-20261121/accept-p4` (the acceptance: the manifest, the build
logs, `acc.log`, the self-tests, the timing, the two mutants).
