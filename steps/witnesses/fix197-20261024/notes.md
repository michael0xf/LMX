# Slice 197: physical correspondence and analytical admission in L2

Codex, sole writer/build after the author's handover. Base: main `0b47d267` (Verified196 record), frozen stage
`build2/codex_fix196`. New stage: `build2/codex_fix197`; only `src`, `headers`, `tests`, `tools` copied as inputs.
The short bootstrap and final artifact checks passed. This is one runtime module's source migration, not the
L3+L2 self-build: 15 of 35 runtime modules are now ported.

## Source change

- `src/l2src/lmx_implements.lm2`: the old module's 90 functions, in the same order, with the same 51 public C entries.
  The graph/arena remains explicit in the arguments; operation scratch, ownership of computed maps, publication and
  cleanup retain their existing roles. C aggregate locals use their declared C ABI types. Indexed records and
  embedded records are accessed through typed local pointers to the same physical places; C-boundary actuals and
  opaque member results have explicit casts. These are machine locals, not graph fields, roots or a companion graph.
  The source identifier `table` becomes `slot_table` because it is a word of L2. No syntax or parser change.
- The existing L3 recipe (`tools/l2/build.lm2`) prints `lmx_implements.h.lm1` and
  `lmx_implements_resolve.h.lm1` as ordinary L1 output text (31 and 2 `fputs` calls, 25,900 and 1,156 output bytes).
  Their content is preserved, including the frame, template and operation-local resolver records and public
  prototypes. Header order: lmx, blocks, arena, implements, scratch, implements_resolve, source_names, gc.
  All eight L1/C headers are removed before generation; a write/translation error stops the ordinary recipe rather
  than selecting a maintained old header. The new module is translated last, without `--header`. No library
  signature comparator, provider lookup or new admission rule was introduced.

| Input/output | SHA-256 prefix | Evidence |
| --- | --- | --- |
| maintained `lmx_implements.lm2` | `57A57BBE…` | source-creating patch, zero-fuzz replay and manifest |
| recipe (repository and stage) | `A2093064…` | committed L3 code and parity check |
| unchanged `l2trans.lm1` | `DE127434…` | frontend's saved source equals196 |
| generated implements L1 | `A8EF4713…` | direct translation and bootstrap output equal |
| generated main / resolver L1 headers | `78ECF3BE…` / `6C7BD3B1…` | equal196's hand-written bytes |
| generated main / resolver C headers | `6A9AD813…` / `8458EEEE…` | equal196's bytes |

The source-creating patch replays with GNU patch `--fuzz=0`: source and replay SHA-256 are both
`57a57bbea1a4925eea0228a29a42db2cdb81fea646f8ef310b47febbd281959a`.
The source and header directory diffs contain only the new L2 file and replacement generated module; headers
remain byte-equal. Runtime C before and after that replacement block is exactly 196, without identifier
normalisation (`checks/runtime-boundaries.command`).

## Real runs

| Run | Actual result |
| --- | --- |
| `gen/implements-08` | frontend196 translates all 90 functions; L1 backend and strict GCC syntax check exit 0. Warnings retained. This alone is not execution proof. |
| `rt-01`, tool196 | generated module used by the new runtime; smoke 6/0, `REBUILD runtime 0 failures`. |
| `tool-01`, tool196 | new recipe linked with that runtime; tool-start/hash and smoke pass, `REBUILD tool 0 failures`. |
| `boot-quick-01`, new seed | `BOOTSTRAP quick 0 failures`, exit 0; smoke 6/0; G1 builds G2 and both tool-start/hash checks pass. Observed process-start to final-output interval: about 1,207 s. |
| `checks-01` | `VERIFIED 21 files, 0 failed`; G1/G2 `EXE-SAME 1` (normalised PE comparison, not raw EXE equality). |
| `manifest-01` | language-owned manifest and verifier: 107 files, 0 failed; independent `sha256sum -c`: 107 OK, exit 0. |

The seed transition is explicit: old tool196 does not yet translate this new module, so frontend196 first writes
its L1; tool196 builds `rt-01` from it and then builds the new recipe's seed. That seed's ordinary bootstrap then
executes the L3 header writers, translates the L2 module and only afterwards builds its consumers. Its runtime
record shows both new headers before their dependent headers/modules and pins the frontend, inputs and outputs.
This is not a build succeeding merely on headers placed nearby.

Bootstrap runtime C (`1C63EC2A…`), ordinary object (`79E17495…`) and observed object (`D7CBE760…`) equal `rt-01`.
G0/G1/G2 tool L1 is `E8278D65…`, C is `5B14240B…`. Raw G1 and G2 executables differ; the working G2 is
`07bdf0ceb199ebb58e4ef3ce556cd8d469b831fbb206103c53b451d0e042dea9`.

## Values, not only exits

All four bootstrap native/forced root0/1 stdout files were read and equal196's bytes:

- A1/A2/B1 calls: `41,41,42,42,43,42`; final counts `A1=42 A2=42 B1=43`.
- After A1's count becomes 100: `A1=101 A2=43`.
- Runtime candidate: `r=142 p.y=42 p.x=1 p.pad=9 q.w=10`.
- Refusals 30/33/34 persist; the Far refusal leaves `y=2`; callable values remain 3/8.

These are the existing witness's state and nonpositional correspondence observations, not a new claim that arbitrary
runtime-callable admission is complete. No new test system, fixture matrix or mutant campaign was added.

## Evidence and boundaries

`evidence-197.list` explicitly names 107 original files. The recipe, source patch/replay, old/new declarations,
compiler, runtime, programs, generation records and outputs are pinned by `evidence-197.sha256`. Text copies in
this packet have LF and no trailing blanks; the manifest hashes the original bytes in their original paths.

This port does not close the existing arbitrary runtime-callable/Q49 admission debt, declared exits, opaque
C-member typing or other open clean-kernel defects. The other 20 runtime modules, driver, both translators and
remaining maintained tooling still require migration. The standard dev snapshot is not silently replaced.
No `bootstrap full`, broad gate/corpus replay or mutant was run. Next: `lmx_graph_copy_owned`, then merge/call.
