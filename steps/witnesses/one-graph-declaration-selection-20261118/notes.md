# The declaration is selected by the call: every declaration of the name against both readings

Written 2026-11-18 by Fable (fable_pc), the single writer/build of main. The code, the component builds and the
mutants are by the peer session opus under the pipeline token (his steps A, B, D, E); the fixtures are by the peer
session haiku. Fable gave the norm readings (the executor's answers R80-R95), read the diff, verified the manifest
and the components, re-ran the witnesses on the final chain and ran his own probes. Base: `5bd50034`; the commits
between it and this one are documents only.

## The norm

The book, `docs/LMX_semantics.ru.md#declaration-selection`; the author, 2026-11-18
(`LMX_blog/2026-11-18.md#general-algorithm`, `#no-count-preference`, `#unwrapped-into-declaration`,
`#opening-tries-other-signatures`): a call is checked against every visible declaration of its name; the arguments
are read as written and, when the call has one argument that is a Structure, opened into its fields; exactly one
admitted pair «declaration -- reading» is the call, none or more than one is an error. There is no preference by
the number of arguments. Opening is an attempt to find another signature: a rejected attempt passes the Structure
as it is, and a signature of one argument that selected the call opens nothing.

## What changed

- Formals (`lmx_graph_run.lm2`, `lmx_graph.lm2`): the formals of a declaration are counted in written order, and a
  declaration given to modifiers is a formal like any other (`lmx_graph_formal_width`, `_place`, `_name_at`,
  `_ordinal`, `_raw`); the activation gives it the argument of its ordinal. A formal declared `required` and left
  without a value fails the pair; a written value of the declaration is taken (`lmx_graph_formal_required`). A named
  argument that stands on the position of its own formal counts as positional. A declaration among the arguments
  assigns the formal of its name. A named record whose head is not a declaration receiver -- `Name(fields)`,
  `Name: fields` -- is a Structure declaration named by itself, in a list of formals too.
- Candidates and the selection (`lmx_graph_run.lm2`): every `fn` and `sub` of the name in the nearest block that
  declares one, outward along the parents of the graph (`lmx_graph_call_candidates`, over the new kernel readers
  `lmx_graph_space_count` and `lmx_graph_space_nth`); an inner declaration shadows an outer one. Arguments with
  effects are evaluated once, in written order, before the selection (`lmx_graph_select_actuals`). Every candidate
  is paired with the arguments as written (`lmx_graph_pair_written`) and with the fields of the one Structure
  (`lmx_graph_pair_opened`): the assignment of arguments to formals, then the admission. A candidate that admitted
  the Structure as written opens nothing by that same formal. `lmx_graph_select_call`: more than one admitted pair
  answers 3; none answers 4 when a pair reached the admission and 5 otherwise. A name that declares one callable and
  a call with no opened reading goes the former way (`lmx_graph_eval_selected` answers -1).
- The receivers `call` and `fncall` (`lmx_graph_receiver_reading`, `lmx_graph_receiver_opened`,
  `lmx_graph_field_structure`): a record with one argument without effects tries to open it by the same binder of
  forms; a Structure of one field opens nothing; when both readings resolve the record the answer is 3. The attempt
  executes nothing: a field that is a call is judged by the declared result of its callee.
- The native image (`l2_graph_tool.lm2`): a call that goes through the selection is emitted as a call of the
  interpreter's selection (`lmx_graph_eval_selected`), and a `call` record of one argument asks
  `lmx_graph_receiver_reading` at run time. This is interim: the image does not prepare the selected call yet.
- `tools/build.lm2`: the exports of `lmx_graph` 91 to 93 and of `lmx_graph_run` 76 to 80.
- Fixtures: 50 new rows -- 47 `declsel_*.lm3`, `declsel_both_readings.lm2`, `declsel_launch_calls`,
  `callable_part_names_data`; `callable_part_names` (comment and expected text; the pin is kept) and
  `receiving_group_roles` are rewritten. The former `via_whole` of `receiving_group_roles` passed only because the
  opened reading silently won; by the norm that call is ambiguous, and the old form is kept as the row
  `declsel_both_readings`, pinned to the answer 3.

## Acceptance by the component cycle

This is a component acceptance by the author's order on the build cycle (`to_fable2_fast_build.md`): no whole
bootstrap, no fixedpoint, no full suite and no whole graph list were run. They are due at the border of the stage,
after the step «the series is the library» that changes the ABI of the library.

- Source manifest: 1243 inputs, SHA 7e3a3cab…, generated and verified by Fable with the new tool: 1243/0 for the
  repository and for the stage. The tree diff of the four tracked source files is byte-equal to the delivered diff
  (a38617a9), the diff of the changed fixtures to the delivered one (6e7c5062). The components were built from the
  manifest of 1239 inputs (b5471fd5); the two fixtures added after that are not inputs of any build.
- Which command built what (opus's record), from the working set of the entry-scan slice:
  - `build-self` gave the tool `ps-tool-d103` (6c45cef5): `tools/build.lm2` changed.
  - `build-runtime` by that tool with the working frontend gave the runtime `ps-rt-d110` (production object
    bebc1775, observed object e524da40); `build-graph` gave the Graph tool `ps-graph-d110` (228f9d71).
  - `build-frontend-host` gave the hosted frontend `ps-feh-d101` (0010e396) over the new runtime, from the final
    sources.
- The runtime generated by the new frontend (`ps-rt-d111`) is byte-identical to `ps-rt-d110`: both objects, compared
  by Fable. The Graph tool built by the new frontend (`ps-graph-d111`, 8a804b5b) is identical to `ps-graph-d110`
  after masking the PE TimeDateStamp and CheckSum: 0 differing bytes, checked by Fable with his own script.
- Witnesses, re-run by Fable on the final chain -- the new frontend, the runtime and the Graph tool built by it
  (`witness-rows.tsv`): 173 rows, each in the three modes interp / native / forced.
  - The 123 rows of the entry-scan slice: every verdict is equal to that slice's witness -- 103 pass in all three
    modes, 20 are red as there.
  - Of the 50 new rows 41 pass in all three modes.
  - Nine new rows are red on purpose; each is pinned by the norm and none is fitted. `declsel_b02`, `declsel_g01`,
    `declsel_g02` (interp only) and `declsel_g03` wait for the step «the series is the library»: a formal without a
    written model, `@: a`, admits a Structure only there. `declsel_b10` and its measure row `declsel_b10direct`:
    `fncall(int; Self)` answers 4 on the base too. `declsel_c09`, `declsel_c10` and their measure row
    `declsel_launch_calls`: the attempt to open is refused as the norm says, but the launch of a block declared in
    the data of a method whose fields are calls calls nothing.
- Fable's probes on the new Graph tool, interpretation, 17 programs with the Structures in the data of a method:
  - `h(Arg)` with `fn: h (int: x)` and `Arg(int: x 9)` answers 9; with the field named `y` the call is refused 4;
  - `f(S)` with `S(int: b 4; int: a 3)` and `fn: f (int: a; int: b)` answers 34: opened fields go by name;
  - `f(3)` with `fn: f (int: a)` and `fn: f (int: a; int: b)` in one block is refused 3; an inner declaration of the
    same name shadows the outer one and the call is not ambiguous;
  - `f(tick(); 4)` with two candidates runs `tick` once;
  - `fn: f (required: int: a; int: b 5)`: `f(1)` is 15, `f(a := 1; b := 2)` is 12, `f(b := 2)` is refused; with
    `required: int: a 1` the same call answers 12; of two candidates the one whose `required` formal is left without
    a value fails and the other is the call;
  - `f(3; int: b 4)` and `f(a := 3; 4)` answer 34; `f(b := 4; 3)` is refused.
  - Two probes show the gap of the step «the series is the library» from the other side. `g(S)` with
    `fn: g (@: a)` is refused 4 instead of passing `S` whole. With `fn: f (@: s)` and `fn: f (int: a; int: b)` in
    one block, `f(S)` for `S(int: a 3; int: b 4)` answers by the second declaration, where the norm says
    ambiguity: the first declaration does not admit `S` yet.
- Mutants (run by opus, each in a private stage with its own runtime and Graph tool, on the final tree): 24, all
  killed. Two survived the first run. The mutant «the candidates are only the first declaration of the name» had
  badly chosen rows; on the rows of two declarations it is killed. The mutant without the rule «a Structure of
  one field opens nothing» of `call` was equal to the candidate on every row: the rule had no witness. Fable
  wrote two probes that tell them apart, and they are in the tree as `declsel_c11` and `declsel_c12`: `call(C)`
  for `C(Inner)` and for `C(@: code D)` runs `C` as it is, the mutant answers 3. Two mutants of the rule on a
  field that is a call are killed only by the direct answers of `declsel_c09` and `declsel_c10`: those rows are
  red on purpose for the candidate and the mutant alike, so the three modes do not tell them apart. The mutants
  cover the count of formals under modifiers, the named argument on its own position, the declaration
  among the arguments, both halves of the `required` rule, the Structure declaration as a formal, the supply to a
  formal under a modifier, the list of candidates, the answer 3, the opened reading, the rule «the same signature
  opens nothing», the walk through the blocks of a callable and along the parents, the operand of a declaration
  field, the hook of the selection, the four rules of the receivers and the two branches of the emitter.
- Closers: the source diff adds seven `---`, each at a drop of two levels at the inner level, counted and read by
  Fable; no `end:` is added; the new functions end in `return`.

## Open, not in this slice

- The step «the series is the library» (opus, next after the expression steps): the admission by the first part
  of the library `implements`, the comparison of two primitives, the reader member `convert`, the formal without a
  written model. It changes the ABI of the library and is accepted with a whole bootstrap. Until it, a call that
  the norm calls ambiguous because of such a formal selects the other declaration (the probe above).
- The launch of a block of data whose fields are calls: `sub: main (C(foo(); bar()))` with `call(C)` calls nothing;
  at the root the same block answers 5 after the first call. A block of assignments declared the same way runs.
- `fncall(int; Self)` answers 4 on the base and on the candidate; the opening of `fncall(F)` has no witness, and in
  the native image only `call` asks the reading.
- The native image hands a selected call to the interpreter's selection; it will prepare the call when the call
  tables exist.
- The place where a refused call is refused differs: a call of a callable declared at the root is refused when it
  runs, a call of one declared in the code of a method when the graph is built. The same on the base.
- `receiving_group_roles`: the element `Written[0]` is not carried into the new form of `via_whole`.
- The translator, not changed here: a path step after a bracketed expression reads the field as a free name of the
  unit; a path argument cannot precede a nested call argument. Both are worked around by a local.

## What the running program holds after the step

The clean graph and the native methods, as before. The selection keeps nothing between calls: the candidates and
the values of the arguments live for the time of one call.

## Files beside these notes

- `witness-rows.tsv`: the 173 rows with their verdicts on the final chain.

Receipts outside the repository: `build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01`,
directories `receipts/opus/one-graph/declaration-selection` (`RESULT.txt`, `slice-src.diff`, build records,
mutants), `receipts/haiku/declaration-selection` and `fable` (`fa-d1-rows01.log`, `accept-d1`).
