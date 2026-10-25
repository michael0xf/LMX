# Fix223: limited physical-family foundation checkpoint

Date: 2026-10-25. This is a bounded verified source slice on published
Verified222: physical-family foundation223. The publication SHA is recorded
after commit. Verification is limited to the results below, not a successful
whole223 SHORT, G1/G2 or S8.6 closure. Codex is the sole writer/build owner
after handover194.

Published bounded code: `4540a067dda8bf17a38c9031888d0d7be3708948`.
Push/fetch/live remote main agree. All69 exact owned raw Git blobs were read
with three-argument `git cat-file blob SHA:path` and match precommit
index/working SHA256 (68 pins in publication-01 plus that manifest's own
82CEF65CFD57B1F8275601F909421C299593A081F8F12949AEA4B21F9CA5F531).
Both documentation generators, cached diffcheck and check_docs pass;
the added ASCII/LF publication manifest is also independently LF-checked.
The frozen runtime/native223 result is not rebuilt after publication.

## Base and source boundary

Published base code: `7e681c598f8a9005440afc25b45812d2f8396067`.
Published base record/main: `cef466aeb836dc4a4d826e173b4c7e238f5ff3ca`.
Both HEAD and origin/main still named that record during this packet review.

The draft is `build2/codex_fix223/draft`. Its runtime-overlays list contains
12 runtime sources plus `l2trans.lm1` (13 files): range, pool, arena,
value_owned, arena_refs, array_owned, array_ref_owned, list_owned,
walk_values, gc_graph, root, and graph_copy_owned, plus the frontend.
The separate tool overlay is the existing L3 `build.lm2`; the witness overlay
is the existing `native_closure_values.lm2`. These lists, not every file
lying in the draft directory, define the selected overlays.

The canonical publication selection is 15 files: those 13 runtime/frontend
overlays, the one existing L3 recipe and the witness. The selected canonical
witness is the tested source02 revision, not the refused source01. The
source-byte requirement is canonical15 SHA = tested SHA = code-current SHA;
a path name, draft copy or source description is not a substitute. Main
checked the exact 15 manifest and patch replay with `--fuzz=0` against the
published222 base: all 15 replay and canonical raw SHA match the tested pins.
Language manifest32611 and verify2684 both terminate0/15files0failed;
independent GNU verifies the same canonical pins. These are byte checks,
not another build. The committed SHA is recorded separately after publication.

The physical family is represented in the existing signed `LmxPool.type`:
positive mutable IDs remain; their negative counterparts are distinct
immutable full IDs; zero is NONE and INT_MIN is invalid. Representation
queries project through `lmx_type_base`, while storage allocation, copying,
pointer ABI and receiving obligations retain full physical identities.
The negative ID is a physical storage identity, not a new admission rule or
proof that an arbitrary Consumer may receive/read/address that value. General
directional qualification/effect admission is still OPEN; base projection
does not authorize a mutable address or erase an exact pointer ABI contract.
No new L2 syntax, grammar, second parser, graph ABI record or runner is
introduced. Existing L3 declaration writers emit the needed L1 declarations
and helper prototypes. The copier preserves each source storage type; the
experimental copy-time retagging route is not part of this checkpoint.

The exact-cell and byte-span barriers recognize the negative physical family
before the old profile checks. Old profile/retention/seal and qualified-root
span paths, including the two existing program root globals, remain present;
their retention is not reported as clean-kernel/full-authority completion.

## One failed whole SHORT, then an explicit runtime continuation

The ONE cold01 whole SHORT (session83667) terminated 1. Main's terminal
observation was 20:30:56.9619807Z to 20:31:33.5982014Z. The completed frontend
component succeeded, but runtime translation refused `lmx_range.lm2:346:72`:
the C member `pool\type` was supplied to the typed L2 helper without an
explicit int cast. The actual diagnostic says `assignment value has unknown
type`, detail `atom=pool`; bootstrap reports failing step 5, one failure,
and the driver reports exit 1 instead of 0. No runtime compile, smoke or G1/G2
is credited to that failed whole SHORT. Its inputs and logs remain frozen.

Evidence: `build2/codex_fix223cold01/trace/bootstrap-quick-01.log`,
`boot-quick-01/frontend/record.txt`, and
`boot-quick-01/runtime/{record.txt,lmx_range.L2.log}`.

The correction adds explicit int casts to the two pool-type arguments and
the analogous span array-type argument, not a changed physical algorithm.
Corrected range SHA256:
`F5495A5F4886CB13B7B3D05761D5687881F8E7E7F5A75BEF8A223E92D3CCDFBC`.
Recipe SHA256:
`69A9DF62A0B8F3688F0DE425F1EBC01E55A49392AAEADD08EC6659CFA5633B4E`.

The continuation is `build2/codex_fix223runtime02`, using the existing
`rebuild runtime` CLI. Its pins record transport/revalidation of 69 named
maintained inputs and seven actual generated P0 source/API outputs of the
completed cold01 frontend; range is the explicit corrected overlay.
The seven outputs are p0.h, p0_own_state, own.h, p0_own.lm1, p0_text.lm1,
p0_own.h and p0_text.h (all .lm1 files). Stage logs report 69/7/1 files,
respectively, each with 0 failures. No C header/object or old kernel
declaration was supplied as a substitute for runtime generation.

The exact completed frontend is reused, with no unchanged frontend
recompilation:
`DD7FD2EE36F1792F30AEDE347DF9D5EA9DED9794DACC52B7ABE97DC74B470ACD`.
The runtime record binds every machine translation to this executable.
Kernel declarations and C headers are regenerated before their consumers;
the generated C-header set has 54 files (52 under headers/l2src, two under
headers/l1src). The seven transported generated P0 files are explicitly
bounded bootstrap products, not a handwritten kernel-header fallback.

The L3 recipe seed is `build2/codex_fix223seed02/gen/lmxtool-tool.exe`,
SHA256 `720FB50CD646CCD274E9AF070F549B1E2C76833D4F101C97EF93C7BE8F67AC73`.
Its saved cc/link/startup-hash commands show the previous222 runtime object
`854F9A0BBC11CBBF7A4BBD1B61D8C84B67640077C83F68E8CF20A86687959445`;
startup/hash gives the intended 69A9DF62 recipe and 13 driver checks/0 roots.
This seed success alone is not acceptance of the new kernel.

Runtime rebuild session61776 terminated 0; main recorded
20:37:53.0977464Z to 20:41:53.9459675Z UTC. Actual rebuild log gives
`SUITE 6 rows, 0 failures`, `REBUILD runtime 0 failures`, and 13 driver
checks/0 roots. Production and observer strict C compilations both exit 0.

| Runtime artifact | SHA256 |
| --- | --- |
| driver.c | D4863E2F21638BBFBE797FE3A799B2C018E9817993C560184F8423FB94AE4EC4 |
| driver.o, production | E0A4AAA710446F3DB87067D1C652869A4A155EE847AE58D1A8B28861F0DA8C60 |
| driver-observe.o | 7ABB37B327A9D7D0F9362F0ADF61B9DE45FA3DCBDAC8F7DCC2A06509A640F760 |

Commands/input manifests are in runtime02/pins; full runtime provenance is
runtime02/runtime-build-01/record.txt and trace/rebuild-runtime-01.log.
Seed commands are seed02/trace/{cc-01,link-01,startup-hash-01}.command.
The UTC/session observations above are main's terminal observations;
the raw diagnostic logs themselves are not claimed to embed those times.

## Actual native physical-family values

Witness FE01/session92670 refused the diagnostic printf at 522:100: an
untyped `c.lmx_int_value_known` actual preceded another call actual. That
source remains frozen at runtime02/tests/native_closure_values.lm2,
SHA256 `593F2B608101526289B053FE78C89BE09A6EB0761711B4B12BEF7F7AFBF7893E`,
with trace/native-closure-01.FE.log. It produced no successful witness run.

Witness source02 differs only by explicit int casts on the three printf
actuals. The reads and assertions are unchanged. FE02/session8426 and the
backend both terminate 0; no diagnostic backend file is invented for the
empty pipeline. Saved translate-result.txt states that boundary explicitly.

| Witness artifact | SHA256 |
| --- | --- |
| witness-src-02/native_closure_values.lm2 | EDF44893CFCA9F2B17DEFC1B11594CCCDFA635A69B2A785E3B115706CCCC8197 |
| generated L1 | 08EAACA9FFAAC72B6E5910DCEEC8F2FE3F52B66D3E166C82DE87D8626905D5CE |
| generated C | 44E75846C57E72F38FBB048E17073957A575881BF6CA5322E8D11A26F149C929 |
| actual executable | 00522BDCDA618BE1F63C762FB8B68EEB468A6C08B1A3FBE1AA287B5AEBE164E1 |

ONE native strictCC02 terminates 0, main's terminal observation
20:46:43.4098683Z to 20:46:50.0121141Z UTC. The saved command uses
`-O2 -fstrict-aliasing` and the usual strict declaration/type/qualifier
errors; it is not a blanket all-warnings-as-errors claim. No driver/runtime
object is linked into this witness: generated C includes the current frozen
runtime02 kernel definitions. Its libc object is pinned by the CC command.

The actual RUN log, runtime02/trace/native-closure-02.RUN.log, gives:

```text
PHYSICAL-NEGATIVE types root=-13/slots=-7 scalar=-2 array=-6/elements=-2 list=-10/elements=-8 pointer=-3072
PHYSICAL-NEGATIVE writes scalar=1 reference=1 pointer=1 append=1 remove=1 byte-spans=1/1 list=5/6 mutable=2/3
PHYSICAL-NEGATIVE copied=41/41/42 sharing=1 cycles=1 source-close=0 failed=0
NATIVE-CLOSURE reparent=0 thread=0 root=0 failed=0
NATIVE-CLOSURE walker-values=0
NATIVE-CLOSURE walker-boundary=0
NATIVE-CLOSURE physical-negative-values=0
```

These are dynamic values (`argc+40`/`argc+41` with argc 1), not constant
success prints. The source checks the actual negative pool types, unchanged
values after refused scalar/slot/pointer/List writes and interior-byte
barriers, the unchanged List storage/length/capacity 5/6, and a mutable List
which grows then removes to 2/3. The data graph contains sharing and cycles.
Copy checks distinct destination cells and preserved full source types,
then closes the source arena and checks destination values 41/41/42,
sharing and cycles again. The witness deliberately uses explicit C-door
allocation/initial-fill helpers; it is not a source-level first-construction
or full Consumer-effect proof. Native calls to walker helpers do not show
that those helper bodies themselves were interpreted.

## Existing S8.1 smoke retained, not a broader new claim

All four actual logs were read at runtime02/runtime-build-01/smoke/
lib_owner-{native,forced}/run-root{0,1}.log. Each reports the same real values:

```text
S81 calls A1=41 A2=41 B1=42 A1=42 B1=43 A2=42
S81 counts A1=42 A2=42 B1=43
S81 after A1 count 100: A1=101 A2=43
S81 C refused at its binding: 30
S81 runtime candidate r=142 p.y=42 p.x=1 p.pad=9 q.w=10
S81 a Thin without x refused where M receives it: 33
S81 a Far whose Bare has no w refused before M's body: 34 y=2
S81 seven taken by a formal M's body does not call: 3, called by plus1: 8
```

Root0 logs give 13 driver checks/0 roots; root1 logs give 17/0. This preserves
the selected known and runtime-built candidate/value regression evidence.
It does not turn the existing limited signature check into general callable
admission, or a native C-door helper into a walked helper body.

## Explicitly OPEN / next boundary

There is no successful whole223 SHORT, new G1/G2, fixed-point artifact or
EXE-SAME result in this packet, and no S8.6/full source-closed self-build
claim. The bounded source-slice publication SHA is recorded after commit.
This is the failed whole SHORT
plus a successful, separately pinned runtime continuation and one actual
native value witness, not a replacement full gate.

Full immutable source first-construction, general per-path write/address/
dirty/UNKNOWN Consumer effects and their propagation/snapshots, runtime
callable/general signature admission, and removal of the legacy profile/
root-span authority paths remain OPEN. The next clean-kernel slice must
carry effects through the ordinary producer/contract/map path and must not
gain permission from a base-type comparison or library-only exception.

Only this notes file was written by the notes reviewer. No source, current
status/checklist, frozen WIP, build output or test command was changed or run
by the notes reviewer.

## Final bounded artifact binding

`artifact-files.list` selects115 exact code/artifact/evidence paths, not a
recursive build-directory inventory. `artifact-current.sha256` binds them;
its SHA256 is A7BC8A95C595FA81FCD8413A2ED869270104B848674B0E816F83F50BBF3A3B3C.
Language manifest53473 and verify69247 both terminate0/115files0failed;
independent GNU verifies the same pins. Forty-one packet text copies are
LF/trailing/EOF formatted separately from the unchanged rawstage files.
`evidence-transports.tsv` names both sides; the artifact binding pins both.
The first draft artifact list used a nonexistent `probe02-01.lm1` spelling;
the pre-manifest existence check refused it. The saved frontend/backend
commands select the actual `probe02.lm1`; the corrected115 manifest and
verification above use that path. No translation or build was repeated.
