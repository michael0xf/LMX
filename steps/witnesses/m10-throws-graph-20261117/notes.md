# Slice418+419: a `call` in a walked root asks the obligation of the selected code's `throws`; `data` in the code of a root; the clean graph: an ambiguous name in the data of a launch, reference places made by the builder, a producer of the data root reached by a read

Written 2026-11-17 by Fable (fable_pc), the single writer/build of main. The frontend and kernel code is by
the peer session sonnet, the fixture drafts by the peer session haiku; sonnet ran the component builds, the
candidate runs and the mutants under the pipeline token, in two measured steps (A = slice 418, B = the graph
slice 419 over A) and a correction B2 after the first whole bootstrap failed; Fable set the order, took the
decisions named below and ran the acceptance gates. Base: slice 416+417 `03a78196`.

## What the slice is

Step A. By the book a call whose callee lists a name in `throws` is rejected unless the caller provides a
`catch` for the name or lists it in its own `throws`
([declared refusals](../../../docs/LMX_semantics.ru.md#exceptions)). A `call` selects its code at run time, so
the check is made at the call. The native launch asked it (`lmx_call_launch`); the walker's `call` never did
(`lmx_call_obligation` had one caller), so the same program gave 7 in a native root and 91 or 81 in a walked
root. Sonnet reproduced it on the working set of slice 416+417 in both executors before any edit (four rows:
root0 7, root1 91 / 81).

With it, three items the previous slices recorded: the reserved name `data` in the code of a root was not
resolved ("unresolved name"), although a root runs over itself and is its own data
([roles of data and code](../../../docs/LMX_semantics.ru.md#data-code-roles),
[`data` is reserved](../../../docs/LMX_semantics.ru.md#ordinary-var)); the emitter registered the code part of
a callable under the word `body`, the norm names the part `code`; nine red fixtures still held the text of the
old operand order of `call`, and the green draft of `free_index_places` waited for a slice.

Step B, the clean graph (rulings R36 and R39 in `LMX_blog/q/fable-self-answers-20261110.md`):

- A Structure beside a place of the same name in the data of a launch was read as "a statement on that place";
  in data a structural form declares, so it is one more occurrence of the name and the bare name is ambiguous
  (R39 item 3).
- A reference place `@: name` without a value was created by the first write into it; the place belongs to the
  builder, as `@: name int` and a declaration with a value already are (R39 item 7).
- A producer (`fn`, `sub`) declared in the root of the data of a launch was not found when its name was read:
  nothing is applied at entry, a declaration enters the namespace when the read reaches it
  ([visibility of declarations](../../../docs/LMX_semantics.ru.md#declaration-visibility)).

## What changed

Kernel, step A (`lmx_walk_values.lm2`):

- `lmx_walk_call_in`: one insertion before the roots of the callee are pushed. For every `EXEC` (`call`) the
  obligation of the throws of the selected code is asked by the existing `lmx_call_obligation`, on both roads:
  the signature road (`call: fn`) and the launch road (`call(D C)`). The refusal is the implicit `implements`
  with no payload, and the callee is not entered. The machine's own receivers — a conversion, a receiving
  (source `CONVERSION` / `RECEIVING`) — are not asked: the throw of their callee is the caller's implicit
  `convert`, which need not be caught.

Frontend, step A (`l2_frontend_resolve.lm2`, `l2_frontend_lower.lm2`, `l2_frontend_emit.lm2`):

- `lm_compiler_path_root_select`: in the code of a root (the unit's, a part's) `data` is a path root and names
  that root; a name `data` the code declared, received or named a method with is selected first.
- `lm_compiler_scan_ident`: the scan of free names does not make `data` a free input of a root (as `node`).
  Found by the run: with the resolve change alone the witness still failed with `unresolved entry name=data`.
- `lm_compiler_emit_parts`: part word 3 of an explicit method is registered as `code` (was `body`).

Kernel, step B (`lmx_graph_run.lm2`, `l2_graph_build.lm2`, `lmx_graph.lm2`):

- The ambiguity. `lmx_graph_data_find_scope` receives a parameter `fold`. The data of a launch
  (`lmx_graph_work_data_find_scope`, the role of data) passes 0: a named Structure beside a place of its name
  is one more occurrence, no slot is chosen, and the capture answers 3. The code and the root
  (`lmx_graph_data_find`) keep 1: there the Structure beside a place is a statement on it.
- Reference places. The builder (`lm_graph_build_place`) constructs `@: name` as the reference without a value
  (kind 9, the wrapper over a typed cell, as `@: name int` builds kind 8) and `@: name 0` as a typed cell with a
  null target — a value "zero", not the lack of one. No new type code: the wrapper kinds 8/9 and the typed cell
  kinds 5/6 already tell "no value" from "zero". The printer prints kind 9 as `@: name` (field list, header
  formal, token) and a null cell of kind 6 as `@: name 0`.
- The lazy road. `lmx_graph_work_pending` also asks the root of the data of the launch: an unapplied `fn` or
  `sub` whose written name is the name (or that has none written) defers the required name, so the entry
  capture refuses nothing. The new `lmx_graph_data_reach_next` applies the next such declaration by the one
  `lmx_graph_fn_apply`; `lmx_graph_select_binding` calls it, on a read, at the row of the required name that
  nothing has bound yet.
- A description of a type declares no place (step B2). `lm_graph_build_node` asks `lm_graph_build_place` before
  it classifies the frame, so the new branch of the reference place also took the type operand of
  `cast: (@: void) d` for a declaration `@: void`. A parameter `described` now goes down
  `lm_graph_build_node`, `lm_graph_build_sequence` and `lm_graph_build_expression`; the first operand of `cast`
  is built with `described` 1, everything inside a description is a description, and a node of a description
  is not asked for a place. A parameter of the build functions, no flag and no bit.

Fixtures, step A:

- New witnesses, each with its full-suite row: `call_throws_obligation` (the signature road),
  `call_launch_throws_obligation` (the launch road: the same `fn` called as `call(D target)`; the first call
  has only `catch: implements ()` and is refused before the body, the second has `catch: Bad ()` and enters,
  the third receives the payload 5), `root_data_path` (`data\[0]raising := 1` in the code of the unit root
  writes the field a `fn` reads as `node\[0]raising`).
- `struct_call_throws`, corrected text: `raising := 1` in the code of the root wrote the root's local, not the
  field `bad` reads through `node`; the field is now written by a `fn` through `node\[0]raising`. The part
  that pinned a refusal of a call with a formal it forms no input for is replaced by the author's decision of
  2026-11-16: such a call is not refused, the body runs (`values-changed.tsv`).
- `code_write_words`: `quote\body := src\body` becomes `quote\code := src\code` — the witness of the
  part word.
- `free_index_places` (draft of haiku, green in all six runs): line 112 `Box: ([]: int items 2)` becomes
  `Box: []: int items 2` — brackets around the content of a Structure make one anonymous Structure inside it
  ([the book](../../../docs/LMX_semantics.ru.md#colon-declares)), so `Box\items` named nothing; line 30
  pinned the stale 5 for a local that the fixture itself writes to 12 through a pointer
  (`values-changed.tsv`).
- Nine fixtures get the operands of `call` in the order of the norm and nothing else: `held_structure_places`,
  `place_map`, `place_write_form`, `source_occurrences`, `split_copy_bound_data`, `split_formal_data`,
  `split_selected_code`, `unary_data_selection`, `unit_n4_inline_named_incompatible`. They stay red for their
  own causes (slice 420).

Fixtures, step B (`selfbuild/tests/graph`):

- New witnesses: `ambig_place_structure` (a formal `int: x` and `x(int: y 1)` in the data group of the header;
  answer 3), `k3_reference_places` (writes by an explicit path into `@: plain`, `@: typed int`, `@: zero 0`
  and an untouched `@: untouched`, read back through the places), `k1_data_producer` (`fn: prepared` of the
  data root read twice: one function for both reads; a second producer never read is never evaluated).
- 23 fixtures of haiku migrated to explicit observation (the values are written by an explicit path into an
  `Observed` block; a local is not published): `callable_over_given_data`, `close_two_levels`, `codebody_own`,
  `computed_body_loop`, `computed_line_publishes`, `construction_paths_fn_data`, `copy_binding_walk`,
  `data_launch_current`, `data_launch_method`, `declaration_site_projection`, `deferred_reference_places`,
  `formal_declarations`, `known_data_identity_twice`, `named_arguments`, `nested_expressions`,
  `ordinary_data_launch`, `ordinary_data_model`, `ordinary_nested_methods`, `own_publication`,
  `physical_reference_type_only`, `struct_launch_given`, `struct_launch_method`,
  `uninit_reference_visibility`. Each expected block was written from the model before the run and the run
  was compared with it; only drafts equal to the model in all three modes were placed. Thirteen pinned values
  in eight of them changed by the norm (`values-changed.tsv`): ten because a local of a call is not written
  back into the data, one because the written formals of a callable are its data, two because the row runs
  the built graph twice.
- Seven pins of the graph list (`pins-changed.tsv`): three new rows, `declaration_site_wrong_type` 4 to 3,
  `declaration_site_overlap` and `declaration_site_reference` to the refusal 3 (R36 item 5: a bare name with
  two occurrences in the data of a launch is ambiguous, a formal has no priority over an own field),
  `copy_declaration_refused` marked as a refusal of the construction.

## Decisions taken on the way (Fable)

- The exclusion of the machine's receivers from the obligation is the norm, not a narrowing: operators in which
  the programmer sees no written `throws` raise a named refusal that need not be caught
  ([declared refusals](../../../docs/LMX_semantics.ru.md#exceptions)), and a type mismatch at a reception is the
  implicit `convert`. Without it the full suite showed two newly red fixtures (`index_numeric_receive`,
  `var_own_repeat_receive`: the numeric reception calls a converter that lists `throws: range`).
- The change of the lowering belongs to the same mechanism as the selection of the path root; each of the two
  has its own mutant.
- The first operand of `cast` names a type; the builder makes no place there. The correction belongs to the
  builder, not to the consumer of the cast (`l2_frontend_graph.lm2` expects the written head `@` with one
  word and is right to). The declarations keep the reference place (R39 item 7).
- A change with no witness does not enter: the second half of the ambiguity design (the gate of the capture
  reading `context_optional`) survived its mutant and was removed; the rule "copying a reference without a
  value writes nothing" had no witness — the value reaches the assignment already unwrapped to the typed cell —
  and was removed.
- Three fixtures about a held function are rows of two runs: the F of the construction walk lives in the built
  graph and survives the runs, the F of a bare name is new at each entry (R39 item 1). Their expected blocks are
  the state after the second run; `known_data_identity_twice` and `construction_paths_fn_data` keep their
  pinned values, `copy_binding_walk` changes two.
- The fixture `deferred_reference_head_refused` is not touched in this slice. Its pin is the old answer 5; the
  candidate answers 8 with one evaluation of `touch()`, which is R39 item 8, and its dump keeps `before 0` —
  `before := 1` in the code is the local of the call. The pin and the expected text change in the next graph
  round.

## Left red, recorded and not fixed here

- Full suite: 20 fixtures are red, the 22 of the base without `free_index_places` and `struct_call_throws`;
  none is newly red (`full-suite-red-names.txt`).
- The nine fixtures with swapped operands changed their first failing line (the receipts,
  `run/first-line-changes.txt`): their causes are the requirement that the data hold the places of the code's
  table and the local without a value over the data of a launch — slice 420.
- Graph list: 62 rows are red, a subset of the 89 of the base (`graph-red-names.txt`).
- The index write of a reference into a slot (`S[0] := @j`, then `S\j`): `struct_index`, `struct_index_admit`
  and `slot_atom_replace` stay red. Their text is older than the call frame: the bare `j` in code is the local of
  the call, and the pinned 40 and 41 are values of the data field. Decided after the acceptance (R42 item 1): the
  fixtures move to `@data\j`, which answers 40 today; what a slot holding the address of an activation's local
  answers by name is pinned nowhere.
- Eighteen drafts of haiku were not placed: the run differs from the model (the receipts,
  `run/draft-findings.txt`). Nothing was fitted. Their analysis by sonnet after the acceptance (the receipts
  `receipts/sonnet/graph-rest2` and `graph-rest3`, rulings R42) sorts them: four kernel defects, recorded in the
  checklist — a Structure launched over itself reads the last of two root declarations of a name where the book
  asks the refusal 3, a whole argument with a field declared without a value and written later answers 4, a
  write by path into a field with a computed declaration answers 4, `merge` leaves the references of the copy
  in the source graph — and draft model errors in the others; two drafts match the run and wait for the next
  graph round.
- A type written as `@: T` in the operand of `sizeof` and as the result of a function still builds a reference
  place in the builder (measured by sonnet, `run/STEP-B2-RESULT.txt`, part b). Nothing in the graph path
  consumes either, so no program shows it; left for a witness.
- Not in step A, for lack of a witness: bare `data` as a value in a root (`data != D`) and `data := ptr` in a
  root; `written_path_form` (the internal invariant on an unnamed tail of two fields).

## Acceptance on the frozen sources

Freeze Source63: 978 inputs, manifest SHA 57a2f979137e26a6…, verify 978/0 for the repository and the stage;
the canonical `selfbuild/inputs.sha256` is byte-equal to it.

- The first whole bootstrap (label `boot-f419-01`, the sources of step B, freeze Source61) FAILED and is kept
  in the stage as evidence: G0 built and checked G1 (9 smoke rows, 0 failures), then the genuine G1 frontend
  could not build the runtime of G2 — `lmx_process_deadline.lm2`, `fn lmx_process_deadline_arm`, "a cast of a
  machine function is to a C scalar or door type or to a reference `@: T`". The builder of the clean graph is
  compiled into the frontend, and the three kernel modules translated with `--graph --machine` go through it;
  the component gates of step B had run with the frontend of step A, which did not hold the builder change,
  and the dump of the graph prints the place and the written type alike. Since B2 the gates of a slice run
  with a frontend built whole from the final sources, and the runtime is built by that frontend.
- Whole bootstrap, quick, label `boot-f419-02`: genuine G1 and actual G1→G2, 9 smoke rows and 0 failures
  each, 28.8 min. G0 is the accepted tool of slice 416+417 (7b439b6f; no list of machine functions, export
  name or recipe text changed — the new kernel function was built by the unchanged tool), the previous frontend
  the hosted candidate `s419-fe-04` (31f2eff6), a full frontend build from the final sources.
- `fixedpoint419-02`: CHECKS 18 lines, 0 failed: 11 `same` and 3 `exe-same` between G1 and G2, the G2
  runtime objects byte-equal to the candidate runtime `s419-rt-08` (built by `s419-fe-04`), and the two source
  verifications.
- Actual G2: working tool `boot-f419-02/lmxtool.exe` d58de444, frontend c299b347, runtime production object 6eb3cc06
  and observed object 935506ff.
- Targeted list on the actual G2: SUITE 12 rows, 0 failures, 72 PASS.
- Full suite on the actual G2 (`g2-419-full01`, 17.6 min): **SUITE 206 rows, 62 failures**, 1412 PASS.
  By fixture names 20 are red, a subset of the 22 of the base; none is newly red. The three new witnesses,
  `struct_call_throws`, `free_index_places` and `code_write_words` are green in every run.
- Graph tool on this G2 (`graph-f419-01`, 7dbcc6b1): `private_binding` and `call_frame_local`, each triple
  interp / native / forced PASS.
- Clean-graph list, 269 pinned rows (the 266 of the base and the three new), each under a 60 s limit:
  **207 pass, 62 fail**, rows over the time limit: 0. Red by names: 62, a subset of the 89 of the
  base; none is newly red; 27 turned green — the 23 placed fixtures, `declaration_site_wrong_type`,
  `declaration_site_overlap`, `declaration_site_reference` and `copy_declaration_refused`.
- Mutants (run by sonnet under the pipeline token, each undoing one change):
  1. the walker of slice 416+417: the four rows of the obligation are red in a walked root (8 failures);
  2. the obligation asked only inside the launch branch: the signature witnesses are red (6 runs), the launch
     witness is green;
  3. the obligation asked only after the launch branch: `call_launch_throws_obligation` is red (2 runs), the
     signature witnesses are green;
  4. no exclusion of the machine's receivers: `index_numeric_receive` and `var_own_repeat_receive` are red;
  5. the lowering without the clause of free names, and the resolve without the path root, each:
     `root_data_path` is red in the native and the forced run (`unresolved name` 8:1);
  6. the emitter with the word `body`: `code_write_words` is red in all four runs; the old text
     `quote\body := src\body` on the final frontend is red in all four runs;
  7. `fold` 1 in the data branch: `ambig_place_structure` and `declaration_site_wrong_type` are red in the
     three modes;
  8. the builder of the base, and the printer of the base, each: `k3_reference_places` is red in the three
     modes;
  9. no hook at the read, no question to the data root in `lmx_graph_work_pending`, and every `fn`/`sub` of
     the data root applied at entry (the forbidden eager design), each: `k1_data_producer` is red in the three
     modes;
  10. the builder with the reference place and without the rule of the description (the builder of step B):
      the build of the runtime by that frontend exits 1 at `lmx_process_deadline` with the message of the
      failed bootstrap; the frontend of the final sources builds the runtime, byte-equal to the candidate.
      No row of the suite can hold this: the `machine` rows go by the P0 path, the `--graph` machine path
      runs only in the build of the runtime (`lmx_schedule`, `lmx_clock`, `lmx_process_deadline`). The
      witness is that build, a step of every bootstrap.
- Closers: the diff of the sources adds one fence, in `lmx_graph_select_binding` after the block of the hook —
  its body ends two levels deeper than the next line. No `end:` line is added. In the fixtures the added fences
  are those of anonymous blocks whose body ends two levels deeper (`call_throws_obligation`,
  `call_launch_throws_obligation`); the `.expected` dumps carry the printer's own `end:` and fence lines.

Generated L1 and C were not edited by hand; no row was disabled. The changed expectations are listed beside
these notes.

## Files beside these notes

- `values-changed.tsv`: the changed pinned values of the full-suite and graph fixtures.
- `pins-changed.tsv`: the changed and new pins of the graph list.
- `full-suite-red-names.txt`: the 20 red fixtures — the new base of the full-suite gate.
- `graph-baseline.tsv`: all 269 rows of the graph list — fixture, pinned exit, pinned number of runs, pinned
  interpreter answer, result on the actual G2; `graph-red-names.txt`: the 62 red names. They are the new base
  of the graph gate; the runner is `../m10-call-launch-20261116/graph-baseline-rows.sh`.

Receipts outside the repository: `build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01`,
directories `receipts/sonnet/s418` (the diffs, `run/STEP-A-RESULT.txt`, `run/STEP-B-RESULT.txt`,
`run/STEP-B2-RESULT.txt`, mutants,
`run/first-line-changes.txt`, `run/draft-findings.txt`), `receipts/sonnet/s419`, `receipts/haiku/dyn-flip418`,
`dyn-ready416`, `graph-ready` and `graph-ready3` (drafts), `fable` (bootstrap, fixedpoint, G2 runs, graph list).
