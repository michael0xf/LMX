# Explicit resolved-place value context — private130

Baseline main139aa45d53dd71ff00d6d3bf464975b8ec07c3b9 and exact129 snapshot
build/codex_native_hidden_129. Final candidate source is in
build/codex_value_place_130c. Codex remains sole writer/build; goal ACTIVE.
This is not a claim that all path/copy or self-build requirements are closed.

## Common owner, load and store

Before this slice, ARG reads and SET_ARG separately copied two context fields,
but ADDRESS/DEREF/PUT transported/stored only a raw pointer. The destination's
old Model/sheet could survive an addressed write, even when the new value had
a different valid view of the SAME raw address. A read-time raw-address guard
cannot distinguish that case and is not the fix.

An activation Value may now explicitly bind an ADDRESS-produced pointer to
the already resolved live Value whose storage it addresses. The referent
member belongs to internal value transport, not the program graph. An ordinary
raw pointer has no such producer binding. No containing Value is recovered
from a raw address, no Model is chosen from layout/history, and no global
address→Model table is introduced.

LmxWalkPlace carries the explicit state owner, when one exists. ARG resolves
its activation-owned cell; ADDRESS carries that owner; DEREF uses the carried
binding. One place-load and value-store operation now handle the payload and
complete context. The old ARG/default/SET_ARG-specific pair updates are
removed. Raw replacement clears old context, including when raw identity is
unchanged; a present null retains its explicit current pair. The same load
can snapshot metadata before writing an aliased output Value.

The public evaluator has one output boundary around its unchanged single
operation implementation. It evaluates into a fresh result before publishing
to the requested output. Clearing a caller-supplied output must not destroy
the operand when both identify the same Value. There is no second operator
implementation, alternative path parser or repeated evaluation.

The backend-neutral lmx_value_context_copy lives in the value module, not
the interpreter implementation. Value construction, working state, native
formal entry/read/rebinding, actuals, hidden forwarding, receiving results,
ordinary returns and the uniform call boundary use the same complete
context. Native function signatures/uniform9 remain unchanged, but internal
Value/Work/Place layouts change. Every runtime and unit object must be rebuilt;
old objects that access these records are not compatible.

## Actual witnesses and retained attempts

The original729 fixture observes the current pair after a store through
stored address chains of depths1,5,17. Targets switch D↔E; both different and
identical raw addresses are exercised. Ordinary generated native void**
forwarding is called directly and by real walked CALL. The higher chain
levels use canonical activation-transport pointer domains; this does not
prove arbitrary-depth source-native C pointer-object representation.

After receiving against R, actual reads are7/9, mapped store41 and mutation
through the taken field address43 preserve the neighboring field. Caller
input records stay unchanged. Address/native sources execute once. This is
not merely successful translation or a fabricated receiving failure.

Baseline02 freshly translates the source with129, strictly compiles/links
with matching old headers/runtime, and executes729 checks/144 assertion FAIL,
exit1. Baseline01's initial C build failed because the fixture omitted the
prototype of the existing internal args_open_values routine; test02 adds it
without changing value oracles. Both attempts are retained.

Initial130 build01 runtime C was invalid because new dotted L1 call operands
were not parenthesized; the failed generated C and source are retained.
Build02 fixes only that spelling. Initial130 target729/0, extended3229/0
then pass.130b moves the complete-context helper into the common value module;
build03/probe03 gives3229/0. Test04 adds14 null/raw/in-place-load assertions:
130b gives3243/2, revealing eval's early output clear. The old3229 assertions
remain GREEN.130c adds the common evaluator result boundary; build04/probe05
freshly gives3243/0, with all original value assertions preserved.

Final3243 includes93 inherited assertions and3150 new assertions. Beyond the
original729, it covers storage of the address in a working variable, ordinary
native working copies and formal rebinding, raw SAME-address replacement,
present null, and a read whose output aliases its owning Value. Actual native
parameter types for the native forwarding witness are void** and point at a
real void* object; higher canonical transport layers stay interpreted.

Final compiler source SHA256:
DEC4C78F344289F432D5A1FD65B9E118C059AC84426DB585629764ACDC9E83B2.
Frontend C build/codex_place130_build_04/frontend.c:
F7DEF96BDE87702BAEB162C1481FEC2A53106A2127B14995F9B1FF81B6AD079B.
Frontend EXE:
8FACD56E2EC4090F0685098EE5170B1BCBCBA32C1A9178AF0BFFC68BA45A72F3.
Walker source:
F2F793FFA9A2DD73E127A224B33DFD2D4674A8E7BC28EE83B62CB0282E02FE00.
Fresh driver C:
EFAA219BB45F50CEDCAF5FB8E40C6E396A318E41A0C885E81FAFE8A511746867.
Fresh renamed runtime object:
F78CE91B709CF892A4433B9B36A5A8569376A08C1B2A413BED1405B83C010F61.
Target unit C:
0CD0F131E95BD9F8069B0AFB02B3C1F116A64607B27B48EAEA3BAD975786D1F3.
Executed LM2:
C152BB457BC4C6EF6F71C3F69CBB1D178D32F3B806A29D79C16D16EDE06DCAC9.
Executed C fixture:
8D97572F6543B8931CA684FA4386629738F60156F7568E43EDF61C7C6200030C.

Initial130b matrix01/session27758 and final130c matrix02/session43026 are
TERMINAL0. Each freshly translates/compiles/links85 units and actually runs
170 observations:162 GREEN and8 unchanged old copy RED/exits. Final worker
PID4900,startUTC2026-10-21T14:39:09.8605054Z. New runtime130 is built in each
matrix; only libc56 is reused. Its pinned1358-byte C source does not use
Value/Work/Place records.342 unchanged upstream input pins are verified;
the six changed source files and two changed headers are separate inputs.
Native binding counts, root modes and --walk-methods remain unchanged.
Historical source provenance remains14 byte aliases and5 exact118 graph
reconstructions, not proof of those five historical source byte streams.

Sequential verify01/session51450 is TERMINAL0. The identical final3243 fixture
through old129 freshly translates/compiles/links/runs with matching old
headers/runtime and gives677 assertion FAIL,exit1. No new-layout object is
mixed into that old control.

Four loss controls keep the final130 layout and SAME3243 assertions. Erasing
the ADDRESS binding gives677 FAIL; erasing it after the common place load also
gives677. Clearing only the binding at18 generated native formal entries gives
576; clearing it at16 native working reads gives384. All exit1 by assertions,
not setup/ABI refusal or crash. Payloads and original Model/map value oracles
are unchanged.130b's3243/2 remains a separate same-layout negative control for
the evaluator result boundary.

Fresh standalone kernel62/57+20/789/54/48 profiles pass, including linking the
common value-context operation without the interpreter implementation. Fresh
unchanged129 source/408,127 source/412,128 source/311 and124 source/111 fixtures
all pass. Source-linked compiler profiles give336/0; aggregate/enum regressions
freshly compile/link and execute four root-mode runs,13/17 driver checks.
These are separate overlapping profiles, not a sum of independent new checks.

The exact129→130c six-source patch resolved-place130-u0.patch applies with
git apply --unidiff-zero --check -p0 against the129 snapshot. SHA256:
C81FDE3A4C72117D520DBE51B0625A1724C98196B5AF7C4604D1FD847245B68D.
Published resolved-place130-probe.lm2 and resolved-place130-test.c match the
executed LM2/C bytes above. The fixture must use PLACE130_SOURCE explicitly
selecting build/codex_place130_probe_05/unit.c; its historical default include
is not the extended generated unit. Recipes are retained under build/:
codex_place130_build_04.ps1, test_05.ps1, values_02.ps1 and verify_01.ps1
(each latter name has the same codex_place130_ prefix).

Terminal27868 input pins are frozen in
build/codex_place130_terminal_01.inputs.sha256, SHA256
EE010A359CA1A4E04900BB9110ED2A00660035FDFAC73C37BB62C42DAB1D7EF4.
All25014 upstream129 pins, six changed sources, two changed headers, all
unchanged inputs, exact compiler/runtime, both85-unit matrices and340 actual
observations, final3243/408/412/311/111/336 profiles, fresh standalone kernel,
foreign executions, old129 and loss controls were independently verified.
The two matrices are successive checks of snapshots130b/c, not self-built
language generations. All named verification workers are terminal. This
receipt is not a full-gate or self-build certificate.

## Boundaries still open

This explicitly bound activation-place mechanism is a dependency toward the
one general path algorithm, not its final certificate. Raw graph/noncached
pointer cells and direct Structure/Array slots do not yet own a persisted
current-context record. An opaque raw pointer without a carried place binding
does not gain one here. Native source ADDRESS producers, arbitrary C aliases,
field/index/cast/cross-activation/default/held-capture persistence, address
lifetime/escape and graph-copy relocation still need their common typed
place/pool/value closure. Do not hide those gaps with read guards, negative
expectations for valid programs, a second parser, or historical Model guesses.

Full112 still has1011 FAIL/3754 and the8 copy observations remain RED. Clean
kernel, all path consumers, genuine L3+L2 self-build and mail T01–T26 remain
uncompleted. Public dev is unchanged; goal remains ACTIVE.
