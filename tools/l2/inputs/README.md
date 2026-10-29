# Historical canonical inputs through slice237

The selected normal source root is now the tracked
[selfbuild package](../../../selfbuild/README.md), published unchanged from
whole-quick-accepted candidate45. Its one relative manifest selects all159
L3/L2 source/tool/test inputs while preserving the stage's src/tools/tests
layout. Use its existing manifest/stage-copy/bootstrap commands; these six
older lists are historical evidence, not a second current source route or
an error-path fallback. No old generated header/body/object may fill a failed
generation. Candidate46 remains pending and is not part of that baseline.

The dated selections and results below remain historical, including uses of
the word current relative to their recorded slice.

These six lists are maintained input data for the existing `lmxtool manifest`
and `stage-copy` commands, not a new preparation runner. Cold219 executed this
73-file selection from repository sources, with no prior generated kernel
headers or module bodies supplied. Its whole-bootstrap acceptance is recorded
in [packet219](../../../steps/witnesses/fix219-20261025/notes.md).
Slice220 removes the residual handwritten walker wrapper from runtime.list:
43+7+1+8+13 =72 inputs. The L3 recipe now writes that declaration-only wrapper;
its five remaining algorithms are L2. Cold220 executed this selection from84
absent generated targets; the corrected whole SHORT finished with zero failures,
including real G1/G2 startup, construction and replacement. Its first C-order
failure and repair are retained in [packet220](../../../steps/witnesses/fix220-20261025/notes.md).
The 35 named kernel modules now have maintained L2 bodies. Slice221 removes the
obsolete roles table/global and its unused argument plumbing, with126 exports
and the same72 canonical inputs. Cold221 executes one SHORT with smoke6/0 and
real G1/G2 startup/build/replacement; three future L1/C/object expectations,
five final bindings and normalized image equality pass. The existing native
and S8.1 values pass, as does one unchanged qualified-merge root fixture.
Two inherited root-span globals remain, together with the handwritten
compiler/P0/driver and broader clean-native/admission/tooling debts: this is
not the complete runtime/toolchain closure or source-closed S8.6.
Program and machine-module helpers use stage/src inputs; the refusal row's
older BASE helper path remains explicitly partial, not a hidden closure claim.
See [packet221](../../../steps/witnesses/fix221-20261025/notes.md).

Slice222 changes the selection to45+2+1+8+13 =69 inputs: P0 ownership
and text algorithms are maintained L2; the complete P0 ABI and own forward/state
declarations are emitted by L3. The explicit PREVIOUS-FRONTEND translates those
modules before the still-L1 parser/compiler consumes them. The old own/parser_text
bodies and p0.h are rejected in a stage, not used as generation-error fallback.
One corrected cold222 SHORT terminates0 with smoke6/0 and real G1/G2 builds,
startup/hash and working replacements. Its first reserved-formal refusal is
preserved separately. GCC-MM selects the generated P0 headers actually consumed.
Three inherited fault-injection globals remain; this is not clean kernel or
source-closed S8.6. See [packet222](../../../steps/witnesses/fix222-20261025/notes.md).

| List | Source root relative to REPO | Destination relative to STAGE | Files |
| --- | --- | --- | ---: |
| runtime.list | dev/l2src_sandbox | src/l2src | 57 |
| p0.list | dev/l2src_sandbox/l1src | src/l1src | 0 |
| driver.list | dev/l2src_sandbox/harness | src | 0 |
| backend.list | l1src | src/l1src | 1 |
| tools.list | tools/l2 | tools | 8 |
| tests.list | tests/l2 | tests | 17 |

Use a new empty STAGE. Create its checks directory and a separate fresh working
directory for **each** language CLI execution using ordinary OS directory
operations. For each table row, run the existing commands (substitute absolute
paths; LIST is this directory's named list, FROM and TO are the table roots):

```text
TOOL 0 entry 0 -- manifest LIST FROM STAGE/checks/GROUP.sha256
TOOL 0 entry 0 -- stage-copy STAGE/checks/GROUP.sha256 FROM TO
```

Every call must terminate with zero failed files and the table's expected file count.
The two empty lists are intentional. The destination copies are
hash-verified by stage-copy. The next existing language command, from another
fresh working directory, is:

```text
TOOL 0 entry 0 -- bootstrap quick REPO STAGE BASE PREVIOUS-FRONTEND LABEL STAGE/tests/smoke-kernel225.tsv
```

Do not first clone a historical stage or fill `headers`/generated P0/kernel
`.lm1`/TLS outputs. The source-first recipe writes P0 declarations and translates
the P0 and compiler machine modules through the explicit previous frontend, constructs frontend headers,
executes the kernel L3 declaration writers, translates all 35 maintained kernel L2 modules
and nine API headers, then creates the common C headers before their consumers.
A failed generation is a failure, not permission to copy a legacy header.
Slice225's76-input selection was49+1+1+8+17. It moves the remaining204
parser algorithm bodies to ordinary L2 and removes the old maintained
`dev/l2src_sandbox/l1src/parser.lm1`. Its stage-relative forward is a generated
output, not a source to stage-copy. The explicit PREVIOUS-FRONTEND must already
support the common pointer-difference operation; a new helper beside an old
running binary cannot upgrade that binary. The completed225 cold run used
5FA1515E, built a new frontend and runtime, and completed G1/G2 startup,
construction and replacement with zero failures. See
[packet225](../../../steps/witnesses/fix225-20261026/notes.md).

Slice226 adds `l2_receiving_source.lm2`: the current selection is
50+1+1+8+17 =77 inputs. Declared headers retain active receiving SOURCE and
exact ABI witnesses as pairs; this is a carrier foundation, not full Consumer
admission. L3 callback writer44 runs before the new L2 producer, with31
generated targets removed before regeneration and no new L2 syntax. One whole
SHORT completed0 with smoke9/0; G1 really built G2, both started, hashed and
replaced the working tool. The three G2 L1/C/object expectations passed
language and GNU verification, and EXE-SAME returned1. Serial dependency
readback selects11 frontend and39 runtime headers, all generated in the cold
stage;16/61 regenerated counts are not consumption counts. The executed stage
retains225's P0 EOF blank line (272DC7F7 versus canonical872A0144), so this is
not a claim that all77 inputs are byte-equal to canonical sources. Concrete
actual/named/default/Consumer-result/exits admission and runtime-callable/Q49
remain OPEN. See [packet226](../../../steps/witnesses/fix226-20261026/notes.md).

Slice227 adds `l2_consumer_uses.lm2`: the current selection is
51+1+1+8+17 =78 inputs. Concrete written path calls retain their original
source environment and receive ordinary graph references in a sixth
receiving-record slot. This is not yet full Consumer signature admission;
the new rows are not consumed by the checker and result/exits are null.
L3 writer45 emits nine callback declarations,36 generated targets are
removed before regeneration, and no language syntax is added. One whole
SHORT completes0 with smoke9/0 and real G1/G2 build/start/hash/replacement.
Original future3 plus canonical7 pins pass G2 language/GNU verification;
EXE-SAME returns1. Serial dependency readback selects13 frontend/39 runtime
headers, all generated in cold10. The existing native owner binary also
checks the actual CALL carrier's width31/count6/coordinate2 and pointer
identities, with143 checks/0 roots and unchanged mutable values.
P0 stage bytes now equal canonical872A0144; one inherited
native_closure_values fixture snapshot still differs, already pinned in
225/226. This is not raw equality of all78 canonical inputs. See
[packet227](../../../steps/witnesses/fix227-20261026/notes.md).

The explicit nine-row smoke list adds three existing qualified-construction
fixtures; the ordinary `smoke.tsv` still selects six rows. The17 test-data
files are not the full suite's dependency closure.

Current231 selects47+1+1+8+17 =74 inputs. The five compiler declaration-only
headers were removed from maintained inventory by229; L3 writes them before
consumers. Slice231 adds ordinary L2 l2_driver_shape:25 bodies,22 exports.
The recipe requires its translation before C headers/driver and removes old
generated targets first. Its source-only cold74 whole SHORT terminates0 with
smoke9/0 and actual G1/G2 build/start/hash/replacement; dependency readback
selects13 frontend/40 runtime headers, all generated in that cold stage.
See [packet231](../../../steps/witnesses/fix231-20261026/notes.md).

Slice232 selects47+0+1+8+17 =73 inputs. Full l2_driver.lm2 replaces the
old helper selection; driver.list is empty and the old maintained L1 driver
is removed. L3 prints its58 old storage cells and forward declarations;
the generated L1 body is imported sequentially after the fixed arrays.
Cold05 whole SHORT16140 completes0/smoke9-0 with actual G1/G2
build/start/hash/replacement, source73/expected2/canonical5 language/GNU0,
EXE-SAME1 and dependency readback13frontend/40runtime generated headers.
See [packet232](../../../steps/witnesses/fix232-20261026/notes.md).

Slice233 selects48+0+1+8+17 =74 inputs. The new l2_frontend_helpers.lm2
contains248 former frontend helpers; the recipe translates its248 exports
before receiving/Consumer/frontend consumers and removes49 generated targets.
Source-only cold74 whole SHORT completes0/smoke9-0; G1 actually builds G2,
both start/hash/replace. Source74/expected2/canonical6 pass language/GNU,
and all48 canonical runtime/compiler inputs match the consumed cold bytes.
Serial dependency readback selects14 frontend/40 runtime generated headers.
The ordinary list omission was corrected after the explicit cold74 run;
the same new helper is now selected exactly once. See
[packet233](../../../steps/witnesses/fix233-20261026/notes.md).

Slice234 selects49+0+1+8+17 =75 inputs, including the new
l2_frontend_alloc.lm2 exactly once. Its20 functions replace the old frontend
bodies/prototypes; the same19 cells remain in the frontend, before the body
import. Recipe05095665 generates20 exports and cleans52 targets before users.
One source-only cold whole SHORT41954 completes0/smoke9-0; G1 actually builds
G2, both start/hash/replace. Source75/expected2/canonical5/runtime49 pass
language/GNU checks, EXE-SAME1 and working rawcmp0. Dependency-only readback
selects15 frontend/40 runtime generated headers. See
[packet234](../../../steps/witnesses/fix234-20261026/notes.md).

Current237 selects57+0+0+1+8+17 =83 inputs. The separate backend.list
uses the existing generic manifest/stage-copy route from REPO/l1src; it does
not create a second maintained backend in the sandbox. The recipe must come
from the current source: a previous control tool does not gain new generators
merely because their source files are present.

Cold04 whole SHORT completes0/smoke9-0 with actual G1/G2 build/start/hash/replacement.
Language/GNU170 checks cover all83 staged sources, two prelink artifacts,
all83 canonical sources and the two changed input lists. Serial-MM resolves
8 backend/20 frontend/40 runtime generated headers. The inherited native
fixture snapshot is now aligned to its previously executed225 bytes; it was
not rerun by237 smoke9. See [packet237](../../../steps/witnesses/fix237-20261027/notes.md).

Temporary handwritten inputs are explicit, not hidden: the frontend/compiler
and partial backend root. The libc ABI is L3-generated and its two stream
bodies are L2; the ordinary cold recipe uses their fresh object beside F1.
Explicit bootstrap seeds and remaining BASE/support/tooling dependencies remain debts. This route is
**not** source-closed S8.6. The old PowerShell gates are not called by it; their
historical assertion sets still need migration and are not declared replaced
merely by this short bootstrap.
