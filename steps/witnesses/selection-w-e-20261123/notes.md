# The selection of a declaration at calls: the readings W and E (step 21.5 of the edition of 2026-11-21)

Written 2026-11-23 by Fable, the coordinator and the single writer of main. This is step 21.5 of the plan section
`next_core_tasks_v3.md#docs-20261121`. The change of the kernel module, the fixtures, the expected dumps and the
mutants are by the peer session opus, on the pipeline token. Fable set the rules before the code (the executor's
answers Р102, Р103, Р129, Р130 and Р144 in `LMX_blog/q/fable-self-answers-20261110.md`), pinned every new and every
re-pinned row from the norm before the run, verified the tree against the helper's hashes, built the runtime, the
hosted frontend and the Graph tool from the tree, compared them with the helper's byte for byte, judged the helper's
log of the rows by Fable's own pins, ran the addressed set and the nine kernel self-tests and reproduced two mutants.

## The norm

- The book, [selection of a declaration](../../../docs/LMX_semantics.en.md#declaration-selection) and the required
  observations [C01–C36](../../../docs/LMX_semantics.en.md#callable-observations): the readings W (the sole actual
  whole) and E (its fields as actuals) are equal; candidates are checked without executing effects; a named actual
  `f(arg := S)` excludes E; no candidate is a refusal, more than one is an ambiguity.
- The executor's answers: nothing runs before the choice (Р102); one declaration is a case of the rule (Р103);
  the admission is asked at one point, today's admission of the kernel (Р129); a sole actual obtained by execution
  is evaluated once before the decision and serves both readings, ambiguity answers 3 (Р130).

## What the step does

- W and E of one declaration are two candidates. The former rule «opening is only an attempt» is withdrawn in both
  of its places, at calls and at receivers of one input. No candidate answers 4 when a pair reached admission and 5
  otherwise; one candidate is the call; more answer 3.
- E exists for exactly one actual that is a Structure or a reference to one and is not written as `formal := S`.
  A group of one around a name or a path is weighed through what it holds; a declaration given as the sole actual
  is a form and has no E.
- An actual with an effect is judged by its description, in three classes: known (a declared place of a known ABI,
  `call`, a call of a name whose declared results are primitive); a primitive of no known type (an expression of a
  built-in operator), possible where the admission point fills the formal with some primitive value; unknown,
  possible at any formal. A description that gives no value is the answer of the actual.
- A call of a name with one declaration goes through the selection when it has an opened reading or an actual with
  an effect: its pair is judged before anything runs.
- The choice made by the description of an inner call is carried to the evaluation of that actual and executed
  there without a new search; the description of a sole call is read once.
- A defect of the accepted set is corrected on the way: the operand of a call was evaluated more than once
  (`f(1 + tick())` against `f(int a)` and `f(long a)` gave three runs of `tick`, now one, after the choice).

No check of the step is bound to `int` (the author's decision of 2026-11-22, Р137). The admission itself still fills
only an own int place and a scalar of the profile; the selection asks the same function the admission branches on
(`lmx_graph_primitive_branch`), so step 21.8 (a) changes one place. The value a description is judged by is a zero
of the ABI of its declared type; it exists only because today's admission point takes a value, not a type, reaches
only the admission question (mutant mS21) and goes away with the library of step 21.8 (a).

## What changed

- `selfbuild/src/l2src/lmx_graph_run.lm2` (sha256 371cf499…): +610 −124 lines; new functions of the description
  (`lmx_graph_described_class`, `_value`, `_admit`, `_result`, `_zero`), of the carried choice
  (`lmx_graph_carry_needed`, `lmx_graph_carried_value`, `lmx_graph_carry_free`), `lmx_graph_selection_applies`,
  `lmx_graph_select_whole` in place of `lmx_graph_select_actuals`, `lmx_graph_primitive_branch` and
  `lmx_graph_admit_primitive`.
- `selfbuild/tests/graph`: 34 new programs with their expected dumps (24 `select_*`, 10 `c6_*`); five programs
  re-pinned with their dumps. `selfbuild/inputs.list` has 1555 lines.
- Nothing else: no other kernel module, no tool and no frontend source changes.

## Acceptance by the component cycle

This is a component acceptance by the author's order on the build cycle (`to_fable2_fast_build.md`): no whole
bootstrap, no fixedpoint and no full suite were run. By the author's rule of 2026-11-22 the measure is the build
time: the whole list of witness rows is not run a second time when the builds are equal byte for byte.

- Source manifest: 1555 inputs, SHA c87bb0d2…, generated and verified by Fable with the accepted tool
  `fable-e6-tool01` (cb658ad6) for the repository and for the stage. The 81 changed and new files of the tree equal
  the helper's list of hashes; the tree holds no other change under `selfbuild`.
- The chain from the final sources, built by Fable from the accepted set of step 21.6: runtime by the accepted
  frontend (driver.o c48acd95, driver-observe.o 61cb7675); hosted frontend over it, `fable-s5-feh01/l2trans.exe`
  (89ee544b); runtime by that frontend, byte-equal to the first; Graph tool `fable-s5-graph02/graph_trans-prod.exe`
  (15baa5b7). The tool is not rebuilt: its sources do not change.
- Against the helper's final chain `opus-s5m`: the frontend and the Graph tool differ in no byte once the PE
  TimeDateStamp and CheckSum are zeroed; both runtime objects are byte-equal.
- Parser suite on the new Graph: 169 cases, none failed.
- Pins: Fable's list of 439 rows (the 405 of step 21.6 with five re-pins and 34 new rows, pinned from the norm
  before the run, `O/tz-20261121/accept-21-5/new_rows.py`) equals the helper's list in every pin.
- The helper's log of the 439 rows in three modes, judged by Fable's pins and the witness list of step 21.6:
  green 383 — 349 of the 405 base rows (344 before) and all 34 new rows; no time-out; no base row lost its
  verdict. The table is `witness-rows.tsv` beside this note.
- The addressed set on Fable's own builds: 145 rows — the families `select_`, `c6_`, `declsel_`, `receiving_`,
  `computed_body_`, `head_` and 28 single rows whose call sites the step reads; no verdict differs from the
  helper's log; the 43 rows that must be green (34 new, four re-pinned, five turning green) are green.
- The nine kernel self-tests `dyn/graph_*`: green on the accepted set and on the candidate.

## Rows the step changes

| row | before | after | why |
|---|---|---|---|
| `declsel_g04`, `declsel_c11`, `declsel_c12` | 0 1 0, green | 1 1 3, green | W and E fit one declaration |
| `receiving_bare_read` | 0 1 0, green | 1 1 3, green | `take(p)`, p refers to an empty Model, `value` is optional: W gives p whole, E gives no actual, both fit; nothing runs |
| `declsel_g01` | 0 1 0, red | 1 1 3, red | the same derivation; red until step 21.8 (a): today's admission refuses a Structure at an untyped reference formal |
| `c6_no_effect_ambiguous`, `c6_no_effect_no_pair`, `c6_one_decl_refused` | red | green | nothing runs before the choice |
| `receiving_whole_read`, `receiving_whole_read_list` | red | green | W and E of a written group fit: 3 |

Three rows are pinned on today's admission and are derived again at step 21.8 (a): `select_operator_u8` and
`select_operator_long` (1 1 4: today's admission fills no u8 or long formal with any value) and
`c6_expr_type_selects` (0 1 0: the u8 pair is refused before the evaluation, so the int pair remains).

## Mutants

21 mutants of the helper, each one edit of the kernel module in a private stage, run on their killer rows:
20 killed; mS19 (the carried choice is not used, the reception searches again) gives the same results and is told
apart by the counters — per iteration of the nested call the selections go 2 → 3 and the lookups by name 2 → 3.
The table is `mutants.tsv`. Fable reproduced two on the own builds: mS1 (a one-field Structure is not opened in
the selection) is killed by `declsel_g04`, `select_both_one_field`, `select_opened_name_field` and
`select_opened_one`; mS21 (the zero of a description is received as the actual) is killed by nine rows.

## Speed of the kernel

The author's threshold for the kernel is 1 %; the timing of this machine swings by far more (one probe on one
Graph ran 94 and 124 seconds in a row), so the decision is by counters of operations per iteration, time only
confirms.

- A plain call `g(n)`: reads of the formal's contract 2 → 0, reads of the actual 4 → 2; selections, lookups by
  name and arena cells are unchanged.
- A nested call with an effect `g(h(n))`: lookups by name 2 → 2, arena cells 2 → 2; added, all of it by the norm:
  the selection of g before the effect (two passes of its pair), one description of `h(n)` and one admission of
  its value.
- CPU time, pairs under the machine lock, accepted set / candidate: loop 7.1 / 7.2; loop-call 25.1 / 23.3 and
  24.7 / 23.0; loop-call-effect 77.6 / 81.3; fourteen sampled runs of the last probe gave 83.4 on the accepted
  set and 92.4 on the candidate on average — the tenth added is the selection of g.
- Two of sixteen runs of the candidate took about 188 seconds. Stack samples of both sets show the same innermost
  frame in half of the samples and more: the insertion into the arena's sorted index of ranges, whose cost depends
  on the layout of the C heap. It is the cost of the type by address, outside this step (the plan's M15 and step
  21.17).

## Debts outside the step

- Today's admission accepts no value at a u8 or long formal and refuses a Structure at an untyped reference
  formal (`declsel_b02`, `declsel_g01`–`declsel_g03` stay red): step 21.8 (a).
- An empty Model under a reference is seen as a Structure of one field (`length(p) = 1`, before the step and
  after): the representation of a reference to a reference; to be checked at step 21.17.
- `whole_arguments`: the build refuses a named actual aimed at a formal whose type is a data Structure of the
  caller, and the pin of the row at `k(s)` is stale (ambiguous by the norm): step 21.7.
- `merge_arguments`: its expected dump prints statements in the older bracket form: step 21.11.
- No row writes a sole actual that is a call through a path head (`p\f(x)`); the branch that serves it has no
  killer row, before the step and after: a row is added with step 21.7.
- `grouped_actual_contract` is red for a cause outside the step: the dump keeps the computed declarations of the
  root unevaluated; step 21.17.
- Two new short top-level functions end with a needless `end:`; by the author's clarification of 2026-11-23
  (`LMX_blog/2026-11-23.md`) such closers are for long functions without a final `return` and for long nested
  ones. They are removed with step 21.9 (a), which edits the same module.
