# Slice414: the address of a local is the place its bare name reads; an input without a value is not refused

Written 2026-11-16 by Fable (fable_pc), the single writer/build of main. The frontend code is by the peer
session sonnet, the kernel code by the peer session opus, the fixture drafts by the peer session haiku; sonnet
ran the component builds, the candidate runs and the mutants under the pipeline token; Fable set the order,
took the decisions named below and ran the acceptance gates. Base: slice 413 `e9c995b6`.

## What the slice is

Two remnants that slices 412 and 413 recorded:

- `@x` of a local addressed the graph cell of its declaration, which no write of the activation reaches,
  instead of the place the bare name reads and writes
  ([the book, unary `@`](../../../docs/LMX_semantics.ru.md#method-reference-assignment));
- the cancelled refusal of an input without a value
  ([the author, 2026-11-16](../../../LMX_blog/2026-11-16.md#optional-inputs-required)) still stood in the
  frontend's static call and whole-argument form and in three places of the walker.

## What changed

Frontend (`l2_frontend_lower.lm2`, `l2_frontend_core.lm2`):

- `@x` of a CODE local that the activation keeps in a working place is the address of that place, the C
  local (`lm_compiler_own_work_addr`, asked first by `lm_compiler_emit_address_context_raw`). The class is
  one predicate, `lm_compiler_own_storage_local`: a number, or a pointer of the kernel's own table of
  pointer codes. Any other local keeps the former address.
- The binding that offers such a local to the free names of the activations below gives its storage and its
  type code instead of a working Value (`lm_compiler_emit_work_binding`), so a write through `@x` is what a
  callee entered afterwards reads.
- `lm_compiler_bind_defaults_check` loses the refusal "has no argument" for a formal with no default;
  `lm_compiler_whole_fields` loses the demand that a formal no field supplies hold a built default.

Kernel (`lmx_walk_values.lm2`):

- `OP_SET_ARG`: an input the call gave no value stays absent; nothing is written into the formal's place.
- `OP_ADDRESS`: a local held in a working row is addressed in that row's Value.
- `lmx_call_bind_whole_form` and `lmx_call_bind_whole` lose the loops that threw `call` for a formal no field
  supplies and that has no default.
- `lmx_walk_selected_ready_values`: an occupied formal whose value is absent travels absent, with no storage.

Fixtures:

- New, each with its full-suite row and each expecting 7: `struct_formal_launch`, `struct_formal_static`,
  `address_of_local`, `write_through_address`, `whole_unsupplied_formal` (probes of opus).
- Changed by the norm, not by the run (`values-changed.tsv`): `formal_default_none_refused` (the row was a
  refusal at translation and is a run now), `free_pointer_paths` (checks 98 and 99), `root_path_read_os`
  and `root_path_read_unit` (the root checks the returned value instead of a field of the method's frame).

## Decisions taken on the way (Fable)

- A change with no witness does not enter the slice. The frontend also set the type code of a working Value
  after a run-time store ("B"); the mutant without it gave the same full suite and the same clean-graph list
  line by line, and the change was taken out before acceptance.
- The class of the address change is narrowed to numbers and pointers of the kernel's table: for a foreign
  C pointer the kernel has no pointee type and answers UNSUPPORTED where the former address passes.
- A migrated draft enters the tree only when it is green in all modes. Three of haiku's drafts did; twenty
  stayed red after the migration and keep the text of the base.
- The new values of `free_pointer_paths` were derived from the fixture's text and the norm before the run.
- The rules of the migration are recorded as R37 in
  [the answers of the executor](../../../LMX_blog/q/fable-self-answers-20261110.md). One of them, given
  without a check against the book, was wrong and is withdrawn there: the name of a Structure does not
  stand to the left of `:=`.

## Left red, recorded and not fixed here

- `free_graph_address` and `free_model_admit`, native only: the address of a local that holds a reference
  to a Structure is still the graph slot of its declaration, right while the local holds its constructed
  value and wrong after a run-time assignment. The C local has no record that types its pointee. The
  mechanism is not chosen: the plan of M15 leaves typed native locals out of the value records, so a local
  written as `code + value` contradicts it as it stands. Witness outside the tree:
  `receipts/opus/s414/o414_m15s2_structure_local_address.lm2`.
- The twenty drafts. opus traced them on the candidate of this slice (`receipts/opus/s415-throws/STATUS.txt`):
  - twelve die on a `call` throw because the working frontend still reads a two-operand `call` code first
    and the drafts are written data first: the open item of M10 about `struct_call_operands`;
  - one meets a refusal `implements`: a Structure called through a callable place gets no record of its
    launch, so the root declarations of its data are not asked when its free names are resolved (the lookup
    of slice 412 is reached only from a launch by `call`);
  - the reserved name of the launch's data is still `var` in the frontend and the kernel, and the name
    `data` is not resolved in the code of the root;
  - the others pin cancelled premises (a launch publishing a Structure into a slot of its data, a write to
    the name of a Structure) and are rewritten by the norm.
- `struct_call_throws`: its text arms the throw by a local write, which does not reach the graph; with that
  repaired, a walked root still enters a callee that declares `throws` under a block with no matching
  `catch`.
- `written_path_form`: an internal invariant of the frontend fires on an anonymous tail of two fields.

## Acceptance on the frozen sources

Freeze Source39: 964 inputs, manifest SHA ee22ba8425219b6fe54f96fbace46c7dcebb5a0d5624b8867285653eb3433b27,
verify 964/0 for the repository and the stage.

- Whole bootstrap, quick, label `boot-f414-01` (G0: the working tool of slice 413; previous frontend: the
  hosted candidate `s414-frontend-06`, 99406528, since the frontend sources change): genuine G1 and actual
  G1→G2, 9 smoke rows and 0 failures each, 24.4 min.
- `fixedpoint414-01`: CHECKS 18 lines, 0 failed: 11 `same` and 3 `exe-same` between G1 and G2, the G2
  runtime objects byte-equal to the candidate runtime `s414-rt-02`, and the two source verifications.
- Actual G2: working tool `boot-f414-01/lmxtool.exe` 8e4b6265, frontend b43a978f, runtime production
  object 49220ab9 and observed object c62e7c9e.
- Targeted list on the actual G2: SUITE 12 rows, 0 failures, 72 PASS.
- Full suite on the actual G2 (`g2-414-full01`, 20.9 min): **SUITE 198 rows, 78 failures**, 1348 PASS.
  By fixture names 24 are red against 28; none is red that was green; green again: `free_c_abi`,
  `free_pointer_paths`, `root_path_read_os`, `root_path_read_unit`. The five new fixtures are green.
- Graph tool on this G2 (`graph-f414-01`, d865022a): `private_binding` and `call_frame_local`, each triple
  interp / native / forced PASS.
- Clean-graph list, 266 pinned rows, each under a 60 s limit: 177 pass, 88 fail, 1 does not
  terminate; the same 89 names as the base of slice 413, none newly red.
- Mutants (run by sonnet under the pipeline token; the frontend mutants were built in place in the stage,
  whose path the frontend headers carry, and the stage was restored and verified afterwards):
  1. the address not taken from the working place: `write_through_address` native, `address_of_local`
     native and forced, `free_pointer_paths` native red;
  2. the binding by the working Value instead of the storage: `write_through_address` native gives 11;
  3. the refusal "has no argument" back: `struct_formal_static` and `formal_default_none_refused` do not
     translate;
  4. the demand of a built default back: `whole_unsupplied_formal` does not translate;
  5. the walker writes the absent value at `OP_SET_ARG`: `struct_formal_launch`, `struct_formal_static`
     forced red;
  6. no branch of `OP_ADDRESS` for a working row: `write_through_address`, `address_of_local`,
     `free_pointer_paths` forced red;
  7. the refusing loops of the whole form back: `whole_unsupplied_formal` red in all four runs;
  8. UNSUPPORTED for an absent occupied formal back: `whole_unsupplied_formal` red at the walked root.
- Closers: the diff adds two fences, each closing two levels (`lm_compiler_emit_work_binding`,
  `lmx_walk_eval_result_in`), and no `end:` line; the two new functions end in `return`.

Generated L1 and C were not edited by hand; no row was disabled. Expectations changed only as listed in
`values-changed.tsv`, each by a cited norm.

## Files beside these notes

- `full-suite-red-names.txt`: the 24 red fixtures of the full suite on the actual G2 of this slice; the
  base of the next slices.
- `values-changed.tsv`: the changed expectations with their anchors.
- The base of the clean-graph list stays `../graph-explicit-paths-20261116/graph-red-names.txt` (89 names)
  and `graph-baseline.tsv` there; the runner is `../m10-call-launch-20261116/graph-baseline-rows.sh`.

Receipts outside the repository: `build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01`,
directories `receipts/sonnet/s414` (STATUS.txt, diffs, mutants), `receipts/opus/s414` (kernel notes, probes),
`receipts/opus/s415-throws` (the trace of the red drafts), `receipts/haiku/dyn-ready` (drafts), `fable`
(bootstrap, fixedpoint, G2 runs, graph list).
