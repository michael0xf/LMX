# Canonical inputs for the short bootstrap

These five lists are maintained input data for the existing `lmxtool manifest`
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
| runtime.list | dev/l2src_sandbox | src/l2src | 50 |
| p0.list | dev/l2src_sandbox/l1src | src/l1src | 1 |
| driver.list | dev/l2src_sandbox/harness | src | 1 |
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

Every call must terminate with zero failed files. The destination copies are
hash-verified by stage-copy. The next existing language command, from another
fresh working directory, is:

```text
TOOL226 0 entry 0 -- bootstrap quick REPO STAGE BASE PREVIOUS-FRONTEND LABEL STAGE/tests/smoke-kernel225.tsv
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

The explicit nine-row smoke list adds three existing qualified-construction
fixtures; the ordinary `smoke.tsv` still selects six rows. The17 test-data
files are not the full suite's dependency closure.

Temporary handwritten inputs are explicit, not hidden: frontend/compiler/API,
libc ABI and driver. The external bootstrap backend,
BASE support/libc object and generated tools also remain debts. This route is
**not** source-closed S8.6. The old PowerShell gates are not called by it; their
historical assertion sets still need migration and are not declared replaced
merely by this short bootstrap.
