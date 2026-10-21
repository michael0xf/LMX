# Native declared-actual value transport — private128

Baseline main f0cf513623605a167098ed681bf63ba54b263277, exact private127
stage build/codex_native_formal_127. Working snapshot:
build/codex_native_actual_128. This closes a caller producer boundary, not
the whole path/copy kernel, self-build, or the mail plan. Goal remains ACTIVE.

## One value, admission and ABI storage

Previously the ordinary generated caller discarded its computed actual's
Model/reference-sheet pair and sent a zero input Value span. Private127
could consume legitimate explicit inputs, but did not produce this span.

The same l2_emit_call_value now forms declared Values in written order,
indexed by the already bound formal ordinal. Each actual's payload and
CURRENT pair are frozen immediately, before later actuals/hidden inputs.
No second parse, evaluation, type/layout/history guess or L2Tx tag is added.
The selected callable/class was already captured before actual formation.

For declared-Model admission, the SAME bound receiving-record emitter and
lmx_walk_value_admit consume/update this existing Value in place. The older
raw and result-context APIs are wrappers of that one core. A present null is
still admitted and acquires the selected formal's Model/sheet; it is not
treated as an absent entry. The caller input record is not mutated by a
callee's activation-local formal state.

The selected call arm copies declared Values into a full declared+hidden
span and derives every refs entry through lmx_walk_value_storage from that
SAME span. The existing uniform9 call receives it. No independent raw boxes
are kept beside metadata; interpretation's strict refs/storage correspondence
is preserved. Hidden raw/ABSENT transport is adapted to that representation;
CURRENT hidden producer metadata is NOT claimed closed by this slice.

Numeric inputs use exact closed primitive types. A C aggregate/enum passed by
value first occupies an automatic object of its exact C type. Internal
VALUE_FOREIGN borrows that object's storage for the call, without a Model;
the common storage projection forwards it. This is opaque C ABI transport,
not a new graph field, opcode, foreign graph type or proof of mutable foreign
VM places. Existing native-only bodies remain native-only. The Value layout
and uniform9 callback signature are unchanged, but runtime/header behavior
changes: this slice freshly rebuilds runtime and generated units together.

## Actual evidence and preserved failed attempts

Final compiler source SHA256:
2F4478092B7A3A48DAF2122D97E4F45E17D3A1EB7A14940E9A8698E2AB8B3FF3.
Frontend C build/codex_actual128_build_01/frontend.c:
92F47032EF63694882AF6C04582E3FDBCFF4F90AA081F9052AA79D9FC59FC99D.
Frontend EXE:
2ABFE992F00B9556C1A749C7BB7D76044D9FA35CDD55E63BB78B4BEF2937096E.
Walker source:
A180ED02FB2863C082EA16A6DB03D7BD908132D8288DEE59BB70235815A179C1.
Driver C:
0CCC6404EBB334A786CBC5BAD349726B0224850590A17E4416483BE9175277D9.
Fresh renamed runtime object:
F289244526F10FE9DED3300017BD523C05BE3B8185726D1CE85EDD105EC6F4A1.

The unchanged127 source and412-assertion fixture freshly pass L2/L1/strict
GCC O2/fstrict-aliasing/link/run against128. New probe04 and test04 give
311/0:93 inherited assertions plus218 new assertions. The earlier277/0
test03 is preserved; test04 only adds named/mixed-input effect witnesses.

Runtime-selected D/E produces real7/9 over one raw physical shape. Ordinary
native callers pass a computed result, working value or activation formal
through universal and declared-Model formals, nested calls and mixed numeric
inputs. Native-C consumers and real walked CALL→generated native bodies
then read, write41 and mutate through the taken address to43, preserving the
neighbor. This is not a claim that every source-native deep path emitter is
closed. Half-present metadata is preserved by universal transport and refused
by receiving admission; null remains present; sources execute once.

Named arguments are written right,left but stored in left,right formal
order. The effect trace must be21, not12, with exactly two effects and the
actual numeric result3. Named mixed reference/numeric arguments separately
exercise context and one effect. Both native invocation and real walked
CALL to the generated native named-actual body execute these assertions.

Probe01's277/62 RED was a fixture construction error: the native uniform ABI
returns payload separately from result context, while the consumer incorrectly
read context.ref as payload. Test02 corrects that constructor and gives277/4;
its four failures reused a candidate already changed to43 by an earlier test.
Test03 creates fresh candidates as the original127 fixture does,277/0.
No engine source changed between these attempts; all original value/map
oracles remain. Failed logs and binaries are retained.

Fresh matrix01/session30056, worker PID13904, startUTC
2026-10-21T13:54:45.1804780Z, TERMINAL0:85 fresh L2/L1/C/GCC/link units,
170 actual observations,162 GREEN and8 unchanged old copy RED/exits.
Runtime128 is newly compiled; only libc56 is reused.344 unchanged upstream
input pins are verified; the six intentionally changed source/header files
are recorded separately rather than incorrectly claimed unchanged. Native
binding counts, root modes and --walk-methods are preserved. Historical
provenance remains14 byte aliases plus5 exact118 graph reconstructions;
historical source bytes of those5 are not proved by this replay.

The IDENTICAL311 fixture through the old127 frontend freshly translates,
strictly compiles, links against the compatible128 runtime and executes
311/173 FAIL, exit1 by assertions, not a crash or setup/ABI refusal.
Two generated-C loss controls retain the same311 assertions: erasing40
input spans gives147 FAIL; clearing the pair after10 actual producers gives
171 FAIL. Both exit1 by assertions. These counts are not new GREEN checks.

The unchanged unit_uniform_aggregate and graph_shape_foreign_value sources
freshly pass L2/L1/GCC/link and execute in both root modes, four GREEN runs
with13/17 driver checks. They observe C aggregate fields41→99, the wide field
4294967303 and unchanged original41; the second also transports a C enum.
This proves native by-value transport with a walked root calling real native
bodies, not general interpretation of foreign-value bodies.

The current128 source freshly translates the kernel and passes unchanged
62,57+20,789,54,48 assertion profiles. Unchanged124 L2/source and111 fixture
freshly pass L2/L1/GCC/link/run. Source-linked compiler profiles give336/0.
All builds/runs in verify01/session79789 are terminal, exit0.

The published four-source patch native-actual128-u0.patch applies with
git apply --unidiff-zero --check -p0 to the exact127 snapshot. Its SHA256 is
EEF5E9B82E417C2EDFC6279E79D35E01228306B7921F028B6E68C1292171E754.
The three published input files match the executed311 fixture bytes:
native-actual128-probe.lm2 SHA522E76A4...,
native-actual128-test.c SHAE03571FA...,
actual128_effect_test.h SHA2C2BA64B....

Terminal23730 input pins are frozen in
build/codex_actual128_terminal_01.inputs.sha256, SHA256
ED2D1943370CCF7BA00C139404B75BD63B91CA2C3B3651D00332F397D90BF856.
All22378 upstream127 pins, unchanged source/header bytes, the intentionally
changed source files, compiler/runtime,85 actual generated units and their
170 executions,311/412/111/336 assertions, kernel and foreign regressions,
old127 and loss controls were independently verified. No named GCC pipeline
or verification worker remains running. This is not a full-gate certificate.

## Reproduction and remaining scope

Recipes are retained under build/: codex_actual128_build_01.ps1,
codex_actual128_test_04.ps1, codex_actual128_values_01.ps1 and
codex_actual128_verify_01.ps1. The targeted C fixture must be compiled with
ACTUAL128_SOURCE explicitly selecting probe04/unit.c, as the executed recipe
does; its historical default include is not the extended generated unit.

Declared actual production is not equivalent to all input/place production.
Hidden/default sources, forwarded raw entries, occurrence/letter-specific
view production and held-callable remapping still need explicit CURRENT
context. Raw initial/noncached graph cells, cross-activation persistence,
indirect pointer/address mutations, field/index/cast producers and typed copy
relocation remain open. Do not hide these gaps with a native read-time guard,
an address→Model registry, or a partial span that silently erases metadata.

Full112 still has1011 FAIL/3754 and8 copy positives remain RED. Clean kernel,
all general path consumers, L3+L2 self-build and mail T01–T26 remain required.
