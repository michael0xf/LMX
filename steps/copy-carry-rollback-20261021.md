# Copy carry and arena rollback — private106/107, WIP

Codex is the sole writer/build;goal ACTIVE. Public dev remains unchanged.
This follows [the typed-copy source slice](typed-copy-current-model-20261021.md),
not a claim that the current-Model producer or all path consumers are closed.

## Ordinary copied roots are not absorbed roots

Private106 changes only `lmx_copy_carry_records` in the common copier.
`part_roots0` previously suppressed every operand-root receiving record,
even when `absorbed0` meant an ordinary complete copy. It now includes
unabsorbed roots in the SAME existing relocation map. Absorbed roots keep
their old guarded policy;no new root identity or physical-layout token is
invented. Source SHA256
`035935EAE0CB7AF1559B6C963FDF4260D24A8333E148018EB5336AFAB6E69E95`.

The new18-assertion kernel data witness copies two different admitted views,
including width4 logical maps over two physical cells. It checks both map
halves,9→41→address43,neighbor7,source independence,the Model=value alias,
and no full-proof transfer for an absorbed root. Actual106 test02 passes
18/0;the identical fixture on unchanged runtime95 fails11/18. Inherited
789 template assertions and54 pending-view assertions also pass.

Test01 incorrectly used coordinate-only registration while expecting a full
admission proof. It actually failed two proof assertions on106. Test02 uses
the ordinary `lmx_implements_admit_receiving`,with empty unused Model cells;
all18 assertions and production106 bytes stay unchanged. The failed fixture
and outputs remain;the production code was not changed to forge its proof.

## Actual allocation refusal exposes a pre-existing detached-block leak

`build/codex_copy106_fault_01.ps1` measures26 allocations in borrowed-map
mode. Fault positions1–6 pass;position7 actually returns NOMEM with four
unclosed allocations even after full arena release. The sweep stops there;
owned-map and Model=value modes are not claimed tested on106.

The unchanged runtime95 control,compiled from the same fault source,has the
same position7/status2/live_delta4 failure. This is not caused by carrying
the root's receiving maps. Read-only debugger traces01/02 locate the denied
16-byte temporary in `lmx_copy_struct_storage`;the four unmatched allocations
are the newly added pool chunk's payload,chunk and two block records.
`lmx_arena_revert` called detach-only `lmx_arena_drop` but never disposed the
detached singleton. A later arena release cannot see those removed blocks.

Simply adding free would leave an existing pool's head/tail pointing at a
freed chunk. Private107 therefore makes the existing arena drop operation
perform common chunk/embedded-pool detachment before storage can leave.
GC consumes that same operation;its two separate unlink traversals are
removed. Drop remains detach-only. Revert then disposes the detached
singleton with the existing block ownership/disposer operation.
No graph field,Model pool,service opcode or new runtime type API is added.

107 arena source SHA256
`E855CE2642F62D3684E81ECD913D6C7B03DD846DB6DEB9035FE116D966105247`;
GC source SHA256
`F31B1E84F09C83356F424B70C87F233DB94043AFD83A136B5BC1789071720C10`.
The copy source remains exactly106. Actual107 build01 keeps18+789+54 GREEN.
Fault107/01 completes82 fresh processes:three baselines plus all26/28/25
measured allocation positions in borrowed/owned/Model=value modes. Old
records remain byte-identical on refusal;the source keeps its values and
full arena release closes the allocation balance. Original106 failure and
unchanged95 counterfactual remain independently preserved.

This does **not** close [issued-cell rollback](defects.md#arena-revert-issued-cells):
the old mark still lacks a snapshot of occupancy inside pre-existing chunks.
No such checkpoint API is implemented by107.

## Core regressions and the stale-address oracle

Actual107 completed94 attach,143 block ownership/disposer,17 reopen,18 simple,
53 GC and25 Post sweep assertions. A separate corrected54-check table test
also passes:404 actual assertions across seven sets,not counting template
and new copy assertions again. The original table source still reports54/2.
Those two original expectations require a newly allocated descriptor and its
pools to differ from dead addresses:the test comment explicitly relied on
revert never freeing storage. It is not a language lifetime rule;the arena
contract already retires records before an address may be handed out again.

The original source/result are preserved. The separate reclaimed-address
test replaces only those two dead-address inequalities with stronger current
kind/type/array relations. Prior live descriptors,backing values and addresses
must remain unchanged;retirement before reuse,range counts,array counts and
the second revert remain checked. Actual allocator balance is independently
required by all82 fault processes;merely ignoring the old RED would not prove
this. No positive source test is converted to an expected refusal.

Core01 failed linking the original attach test because its old standalone
imports omitted the now-needed source-name dependency. Core02 reuses the
existing20-import kernel closure without changing source assertions;attach94
passes,then the block test needs its declared GNU free wrapper. Core03 links
declared wrappers,keeps block143/reopen17/simple18 GREEN,and records the
original table54/2. Core04 reuses those completed sets and executes reclaimed
table54/GC53/Post25. The failed recipes and original RED are not overwritten.

## Continuation boundary

No full107 gate or language-copy correction is accepted here. The serial
`build/codex_copy107_next_04.ps1` completed0,including the actual107 driver
and three original copy sources with compiler105/runtime107. Its actual
inventory is10 RED phase observations,not the previous six:Model=value
regresses in four runtime cells. Native reports “successful merge has
conflicting producer evidence”;forced methods report PRIMITIVE. The ordinary
copy now carries its source's real physical-layout evidence,but the common
merge finalizer still tries to register a different fresh synthetic token.
The kernel data test did not cover this finalizer,so its positive result
was insufficient. This regression is not accepted or waived.

Opaque copying still has four runtime failures(now reaching an unmapped
field path in native),and indexed copying keeps its two L2 refusals. The
next dependent slice must let common finalization consume the copied result's
already-proved physical evidence without guessing a receiving Model or
overwriting it with synthetic coordinates. A corresponding finalizer witness
and both actual engines are required. No108 implementation is claimed here.
Native and forced-walker copy values,sourceContext,
current Model transport,indexed copying and the remaining schema/name-based
consumers remain open until their own evidence closes them.

## Private108 and the newly exposed receiving-token mismatch

108's common finalizer consumes physical evidence already present on the
current result instead of registering another self record with a conflicting
synthetic token. It does not choose a receiving Model from arbitrary entries.
The20-assertion kernel witness also requires the copied full proof to survive
finalization. Actual107 control fails exactly one of20;108 passes20/0.
Merge source SHA256
`164A6383E11780E3B0C59E726C630F274969D9C2260D1B717E86A3DE7FEA8E66`.

Actual compiler105/runtime108 copy observations restore Model=value's four
GREEN cells. Opaque copying still has four runtime failures and indexed
copying two L2 refusals. These are the original10 phase observations with
six RED,not a successful12-cell copy gate.

The broader original154-cell recipe then stops on a genuine regression:
146 cells executed,142 GREEN/four RED. The four RED are the unchanged
`receiving-hidden-unused-conflict` positive in both method/root modes.
The last mixed positive and four header cells were not executed:eight cells
remain unrun,not counted as successes. Both engines close without the expected
exit7. The source is not converted to an expected error or weakened.

The actual read-only old/current traces
`build/codex_hidden109_receiving_01.ps1 -Version 105/108` each complete six
receiving operations. Old105's six succeed;108's last returns UNKNOWN2.
For that current required Model the real physical token is2,but the two
prepared templates still require synthetic5. Both source contexts are0.
These are relative token-cell coordinates in this one program,not language
codes or a rule about a namespace named box. No process data was edited.

## Private109 compiler dependency — targeted verification complete

The next compiler-only change is in the one `l2_schema_token_slot` producer,
shared by catalog,reference-contract and both backend representations.
A copied schema follows only its retained `source.layout` physical evidence;
`source.schema` never supplies a physical origin. Unknown physical evidence
keeps the current constructor's own token. The finite current source inventory
permits long chains and rejects cycles/invalid rows;no fixed depth or second
name/path lookup is added. Source SHA256
`CEC453A719244A80BBA7C2A2A9AFEA5B92FB351E2CE88F1D2E3627A3101A8D30`.

Actual109's original302 distinct compiler assertions plus18 new token checks
are GREEN. The identical corrected18-assertion test on unchanged105 fails13.
It covers129 links,unknown physical origin despite a known logical Model,
current mutations,method/invalid/cyclic origins,and allocation balance.
Build01 first crashed in its synthetic fixture's method lookup:five declared
namespaces had no ordinary `l2_ns_proc` inventory. The saved backtrace reaches
`l2_m_nsof` after the first assertion. Fixture02 supplies that inventory;all18
assertions and production109 bytes are unchanged. Finish02 reuses the completed
old profile logs and executes the corrected18 plus the unchanged20 effects
assertions,not a relaunch of the whole compiler build.

`build/codex_catalog109_continue_02.ps1` completed0 on compiler109/runtime108:
the old control,all original154 actual value/header cells,and the original
copy observations are terminal. The hidden-unused-conflict positive again
passes in all four actual method/root cells. Its read-only109 trace completes
six successful receiving operations;the final current-required token2 now
matches both templates' required2. SourceContext remains0:the original giving
contract producer is not implemented by this token correction.

The extra copy inventory remains10 phase observations/six RED:Model=value
four GREEN,opaque current Model four runtime failures,indexed copy two L2
refusals. A source holding two valid D/E correspondences still needs its
actual declared giving Model,not an arbitrary first map or fabricated physical
origin. A copied Model that is also its value must follow the SAME relocation
map;merely replacing a copied root's logical schema by the old external Model
would not prove that transport. No new metadata encoding/ABI is selected here.

[copy-origin109.patch](witnesses/used-scope-20261020/copy-origin109.patch)
reproduces exact105→109 compiler and four runtime source files. Published
[kernel20](witnesses/used-scope-20261020/copy_origin109_kernel_test.c),
[allocation fault](witnesses/used-scope-20261020/copy_origin109_fault_test.c),
[token18](witnesses/used-scope-20261020/copy_origin109_token_test.c) and
[reclaimed table54](witnesses/used-scope-20261020/arena_table_reclaimed_selftest.lm1)
are byte-identical to their executed fixtures. The original table54/2 and all
failed fixture/recipe traces remain separate,not edited into successes.

`build/codex_copy109_publish_01.ps1` independently reapplies/checks the coupled
patch,verifies all154 GREEN cells,the82 fault processes,the404 core assertions,
the old/new metadata/finalizer controls and the unchanged six RED copy phases.
All1196 upstream105 pins were independently rehashed unchanged.3541 bounded
terminal pins:`build/codex_copy109_terminal_01.inputs.sha256`,SHA256
`206E4F2F3FC34EB90FED499214D18DC79776D76929EF2F7D221D33ABB83B2C19`.
No full109 gate,current-Model sourceContext fix,indexed-copy implementation,
public-dev promotion or global path certification is claimed.
