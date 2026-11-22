# Slice413: the clean graph after "frames are not published" — explicit paths in fixtures, three kernel fixes

Written 2026-11-16 by Fable (fable_pc), the single writer/build of main. The kernel code and the cause
analysis are by the peer session sonnet, the fixture migration by the peer session haiku; sonnet ran the
component builds, the candidate runs and the mutants under the pipeline token; Fable set the rules of the
migration, took the decisions named below and ran the acceptance gates. Base: slice 412 `1fc39385`.

## Why this slice exists

The baseline taken with slice 411 showed that of 266 pinned clean-graph fixtures only 60 passed. The
boundary was commit b901f2bf (2026-11-15), which implemented the norm that the frames `data` and `code`
are not published into the graph ([the book](../../../docs/spec/LMX_semantics.ru.md#flush-receiver-contract)) and
added one fixture of the new kind, but left the older fixtures pinning published values; they had been
accepted by short lists. This slice moves the fixtures that the norm explains to explicit operations and
repairs three places of the interpreter of the clean graph.

## The rules of the migration (decisions of Fable, by the norm)

The logic of a fixture and its pinned values are kept; a value the run gives differently is a finding and
the expectation is not fitted to it.

- Observation: a block of root data with one place per pinned value and an explicit write through a path
  in a final `sub: main`, as `tests/graph/call_frame_local` does.
- A state that must outlive a call is written through `data\name`, the explicit path to the data of the
  current launch ([the special name `data`](../../../docs/spec/LMX_semantics.ru.md#ordinary-var)); a bare name is
  the local of the call.
- A field of the root is read through `node\name` from a method of the root and through `data\name` from
  the code of the root itself: `node` is the space above a method, and the root is not a method.
- An unused computed initializer of the data is not executed at entry; a fixture that relied on its effect
  reads the field once.
- `call(D s)` where the fixture meant the body of `s` over `D` becomes `call(D s\code)`
  ([a callable is just a Structure](../../../LMX_blog/2026-11-16.md#callable-is-structure)); the kernel gets no
  rule for it. `f\args` becomes `f\data`: a callable has no part `args`.
- A fixture whose only purpose is a cancelled behaviour keeps its text and pins the new answer; nine pinned
  answers change, each with its anchor (`pins-changed.tsv`). One fixture gets a value that follows from the
  norm instead of the old one: `declaration_site_auto` returns 2, not 7 — a declaration of an already visible
  name assigns the existing place —, and its observation of own DATA created by a code declaration is
  dropped (`values-changed.tsv`).

## What changed

Kernel (`lmx_graph_run.lm2`):

- Reading a computed declaration through an explicit path executes the expression the declaration writes
  (`lmx_graph_declared_value`, called by `lmx_graph_step`), with no publication and no cache, in the scope
  of the Structure that holds the declaration. The norm says so
  ([the call frame](../../../docs/spec/LMX_semantics.ru.md#call-frame-20261115)); the interpreter answered 5, "this
  slice does not execute it", for `int` and for references alike, and publication had hidden the gap.
  Three fixtures of 2026-11-14 pinned that answer; they predate the norm and are migrated.
- The scan of free names skips the operand of `include` and `predef`: it is text, not a name.
- A write to a name bound to a function of the scope is refused again (answer 4): names of Structures are
  not assigned ([the book](../../../docs/spec/LMX_semantics.ru.md#colon-declares)). b901f2bf had lost the line.
- One function loses a needless `end:`; one fence closing two levels is added.

Fixtures (`tests/graph`): 112 names — 110 migrated fixtures that pass in all three modes, and
`known_data_deferred` and `received_field_read_refused` migrated by the first kernel fix
(`known_data_mutable_alias` changes its pinned answer only).

## Removed before acceptance

A second part of the third fix — the ambiguity of a name with two occurrences in the data checked before
a declared local makes the name optional — was taken out: no fixture and no probe distinguishes it, and it
does not solve the mixed case it was written for.

## Left red, recorded

- The mixed ambiguity: a formal that is a place and a same-named Structure in the data. A bare read
  silently takes the Structure and the supplied value is lost; the expected answer is 3, as for the path
  `data\x`. `declaration_site_wrong_type` stays red on its old pin.
- Three fixtures about a held function (`@: held leaf`, `@: Hold (@: p f; @: q f)`): the interpreter gives
  the values of the recorded model, native and forced give others. Not placed in the tree.
- Twelve fixtures of the group "answer 5 at a path step" now run; three more are ready for the next slice,
  six fail only on the observation of a reference — an explicit write of a reference through a path into
  an unfilled reference place answers 4 —, three fail on values.
- 34 fixtures with a nonzero answer are not resolved.

## Acceptance on the frozen sources

Freeze Source33: 959 inputs, manifest SHA f238e8f29e97605488053c0ae648f62edc344f24cf5de9f571691490c7ed3cfd,
verify 959/0 for the repository and the stage.

- Whole bootstrap, quick, label `boot-f413-01` (G0 — the working tool of slice 412, previous frontend —
  the G2 frontend of 412; the frontend sources do not change): genuine G1 and actual G1→G2, 9 smoke rows
  and 0 failures each, 20.9 min.
- `fixedpoint413-02`: CHECKS 16 lines, 0 failed — 11 `same` and 3 `exe-same` between G1 and G2, and the two
  source verifications. (A first list also compared the frontend and tool executables with those of 412
  and failed on those two rows: the executables contain the kernel, which this slice changes. The rows
  were a wrong assumption and are not part of the gate.)
- Actual G2: working tool `boot-f413-01/lmxtool.exe` 588725e8, frontend f06d4d6e, runtime production
  object 5b1dd98b and observed object 39d7194c.
- Targeted list on the actual G2: SUITE 12 rows, 0 failures, 72 PASS.
- Full suite on the actual G2 (`g2-413-full01`, 17 min): **SUITE 193 rows, 106 failures**, 1290 PASS; the
  same 28 red fixtures as after slice 412, none newly red.
- Graph tool on this G2 (`graph-f413-01`, c9518bdd): `private_binding` and `call_frame_local`, each
  triple interp / native / forced PASS.
- Clean-graph list, 266 pinned rows with the nine changed pins, each row under a 60 s limit:
  **177 pass, 88 fail, 1 does not terminate** — against 60 / 205 / 1. The 89 red names are a strict subset
  of the 206 of the base; none is newly red; 117 are green again: 114 migrated fixtures and
  `cdoor_declarations`, `computed_body_write_refused`, `place_reference_unknown` by the three kernel
  fixes. Eight red fixtures fail in the interpreter only, one in native and forced only.
- Mutants (run by sonnet under the pipeline token, each in a stage copy, sources verified afterwards):
  1. without the read of a computed declaration — `place_reference_unknown` red, and nothing else changes;
  2. without `include`/`predef` in the scan — `cdoor_declarations` red in all three modes;
  3. without the refusal of a write to a function's name — `computed_body_write_refused` red in all three.
  The first fix is needed by one fixture of the 266 and by the three migrated refusal fixtures; the 114
  migrated fixtures do not depend on it (measured on a variant without it).
- Closers: outside the generated `.expected` dumps the diff adds one fence, closing two levels, and no
  `end:` line; the migrated `.lm2` fixtures add none.

Generated L1 and C were not edited by hand; no row was disabled. Expectations changed only as listed:
nine pinned answers and one value, each with its anchor in the files beside these notes.

## Files beside these notes

- `graph-baseline.tsv` — all 266 rows: fixture, pinned exit, pinned number of runs, pinned interpreter
  answer, result on this G2. `graph-red-names.txt` — the 89 names that do not pass; the base of the next
  slices.
- `pins-changed.tsv` — the nine changed pinned answers with their anchors.
- `values-changed.tsv` — the value changed by the norm.
- The runner with the time limit is `../m10-call-launch-20261116/graph-baseline-rows.sh`; the base of the
  full suite stays `../m10-call-launch-20261116/full-suite-red-names.txt` (28 names, unchanged).

Receipts outside the repository: `build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01`,
directories `receipts/sonnet/graph-regress` and `receipts/sonnet/graph-slice` (cause analysis, probes,
STATUS.txt, mutants), `receipts/haiku` (graph205.md, graph-migration.md, graph-findings.md, drafts),
`fable` (bootstrap, fixedpoint, G2 runs, graph list).
