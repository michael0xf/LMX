# Slice415: the reserved name of a launch's data is `data`; a child block `var` is an ordinary name

Written 2026-11-17 by Fable (fable_pc), the single writer/build of main. The frontend and kernel code is by
the peer session sonnet, the fixture drafts by the peer session haiku; sonnet ran the component builds, the
candidate runs and the mutants under the pipeline token; Fable set the order, took the decisions named below
and ran the acceptance gates. Base: slice 414 `9e1e88cf`.

## What the slice is

By the book `data` is the reserved name of the explicit reference to the data of the current launch; before
the author's decision of 2026-11-11 it was `var`
([the special name `data`](../../../docs/LMX_semantics.ru.md#ordinary-var)). The working frontend and the
kernel still knew the word `var`: the frontend as the implicit data input of a code and as a child block of a
named Structure that it collected beforehand as "written data", the kernel as a seeded word. Slice 412
recorded the frontend part as a remnant; the kernel part was found while this slice was prepared.

## What changed

Frontend:

- The reserved name is `data` (`lm_compiler_default_data_name`); its readers are unchanged.
- The servicing of a child block `var` is removed whole: `lm_compiler_data_binding_source` and
  `lm_compiler_ns_data_source` (views), `lm_compiler_collect_data_bindings` and its call (emit), the collection
  of the child before the body and the `child` parameter of `ns_child`, the loops over such bindings in the
  release of own rows, in the local inputs and in the method slots (core), in `own_source_visible` (context),
  in `graph_field` and `split_data_row` (coords), two conditions of the name scan (lower), and the bypass in
  `ns_site_known` (resolve).
- A path segment that names a part of a method accepts `data` and `code` only; the former spellings `var`
  and `body` are removed (values). The clean graph refuses them already.
- The list `l2_addr_own` with `own_addr_note` — written, never read — is removed (core, emit, resolve).

Kernel:

- The seeded word is `data` with the code `LMX_ID_DATA` in place of `var` and `LMX_ID_VAR`: `lmx_ids.lm2`,
  the table of codes in `tools/build.lm2`, the self-check of `l2_driver.lm2`, one line of
  `lmx_walk_values.lm2`. The emitter names part 2 of a method `data`.
- `lmx_implements_repeated_var` is removed with its call. It counted root heads `var` of a code at the
  admission of a call with no data and served the rule "a short call reads the child `var` of its code by
  name", which slice 412 had removed from the kernel.

Tool (`tools/build.lm2`): the lists of machine functions without the removed ones, the frontend's state text
without `L2DataBinding`, `l2_data_bindings` and `l2_addr_own`, the table of codes.

Fixtures:

- `data_source_cells` is migrated (the draft of haiku): the reserved reference is written `data`; the block
  `var:` that stood in the executed code of `T` moves into the data `TD` that `T` is launched over, because a
  structural form in executed code is a call of its head
  ([the book](../../../docs/LMX_semantics.ru.md#colon-declares)); `T` checks `data = TD` and, by the bare name,
  `var = TD\var`. The pinned values are unchanged; the value 17 is read at `TD\var\x` instead of `T\var\x`
  (`values-changed.tsv`). The two-operand `call` keeps the old order, code first, until slice 416.
- New `var_ordinary_child` with its full-suite row: `var` is an ordinary local of a `fn`, `data\x` reaches the
  data of the launch, `data := E\var` rebinds the reference, a child block `var:` of a Structure is one more
  field reached and written by a path.

## Decisions taken on the way (Fable)

- The kernel half goes into the same slice: with the frontend alone the name `data` would not have received
  the data of the launch at execution, and `var` would have.
- `lmx_implements_repeated_var` is removed, not renamed: by the book a form `data(...)` is a declaration in
  data and a call of its head in code, with no check by this name.
- The word `body` that the emitter gives part 3 of a method stays for a later slice; the kernel has no seeded
  word for it.
- The fixtures of this slice keep the old operand order: the order changes for the whole corpus in one
  slice, together with the frontend.
- A block `var:` in executed code has no lawful reading as a declaration; the fixture moves it into the data.

## Left red, recorded and not fixed here

- The same 24 fixtures are red. Two of them now fail at translation instead of at run:
  `explicit_data_var_field` (8:5) and `immutable_reached_write` (124:5), ":= writes a place already known:
  its left side is not one here" — their text of the base assigns to `var`, an ordinary unknown name now.
- The migrated drafts of the other fixtures with `var` stay red on the candidate and are not placed:
  `explicit_data_var_field` (exit 85), `immutable_reached_write` (translation), `place_map` (exit 92),
  `place_write_form` (exit 30), `written_form` (translation 20:17), `callable_place_fields`, and the four
  that used the former part spellings (`sub_parts`, `var_own_fields`, `var_own_nested`, `code_write_words`).
  Their causes are those traced after slice 414: the operand order and the missing record of a launch.
- Found on the way: a local declared in the code of a Structure launched over other data (`call: held D`)
  fails with any name ("a split-called code reached data without its place row"); in a `fn` the same
  declaration works. The same class as slices 416 and 417.

## Acceptance on the frozen sources

Freeze Source42: 965 inputs, manifest SHA 1e20ba62542810fad64172c02bc607983ff63ef227ac370d9db75ca49825e78a,
verify 965/0 for the repository and the stage.

- Whole bootstrap, quick, label `boot-f415-01`: genuine G1 and actual G1→G2, 9 smoke rows and 0 failures
  each, 19.2 min. G0 is the hosted candidate tool `s415-tool-01` (2231981f) — the lists of machine functions
  and the table of codes live in the tool —, the previous frontend the hosted candidate `s415-frontend-01`
  (9288f342).
- `fixedpoint415-01`: CHECKS 18 lines, 0 failed: 11 `same` and 3 `exe-same` between G1 and G2, the G2
  runtime objects byte-equal to the candidate runtime `s415-rt-01`, and the two source verifications.
- Actual G2: working tool `boot-f415-01/lmxtool.exe` 89dd8b75, frontend b3b587af, runtime production object e943fba6
  and observed object b92a09bc.
- Targeted list on the actual G2: SUITE 12 rows, 0 failures, 72 PASS.
- Full suite on the actual G2 (`g2-415-full01`, 16.4 min): **SUITE 199 rows, 74 failures**, 1350 PASS.
  By fixture names 24 are red, the same as after slice 414; none is newly red. `data_source_cells` and
  the new `var_ordinary_child` are green.
- Graph tool on this G2 (`graph-f415-01`, 669d8cc1): `private_binding` and `call_frame_local`, each triple
  interp / native / forced PASS.
- Clean-graph list, 266 pinned rows, each under a 60 s limit: 177 pass, 88 fail, 1 does not
  terminate; the same 89 names as the base, none newly red.
- Mutants in reverse (run by sonnet under the pipeline token; a removal needs none of its own):
  1. the frontend compares the reserved name with `var` again: `var_ordinary_child` and `data_source_cells`
     do not translate. The first text of the witness survived this mutant — it did not assign to `data` —
     and was extended by `data := E\var` with its check;
  2. the kernel does not know `data` as the reserved name (another code at the comparison): both fixtures red
     in all four runs;
  3. the seeded word is `var` again: both red in all four runs.
- Closers: the kernel and frontend diff adds no fence and no `end:` line and removes four `end:` lines and
  more than fourteen fences; the migrated fixture adds one fence and the new one two, each closing two
  levels.

Generated L1 and C were not edited by hand; no row was disabled. The only expectation changed is the place
of one pinned value, listed beside these notes.

## Files beside these notes

- `values-changed.tsv`: the changed place of a pinned value.
- The bases of the gates are unchanged: `../m10-local-address-20261116/full-suite-red-names.txt` (24 names),
  `../graph-explicit-paths-20261116/graph-red-names.txt` (89 names) and `graph-baseline.tsv` there; the runner
  is `../m10-call-launch-20261116/graph-baseline-rows.sh`.

Receipts outside the repository: `build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01`,
directories `receipts/sonnet/s415` (README.txt, STATUS.txt, diffs, mutants), `receipts/haiku/dyn-ready415`
(drafts), `fable` (bootstrap, fixedpoint, G2 runs, graph list).
