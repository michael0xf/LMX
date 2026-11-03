# Slice270: ordinary data bindings and actual named places

## Verified slice270 scope

The October15 author example is implemented by ordinary input rebinding:
var initially holds selected data; assigning a Structure changes that same
local binding. Subsequent explicit paths follow its current value, while
data/var and held bare fields stay separate. Assigning the Structure does
not execute it. Compiler-only binding metadata refers to existing source
cells; it does not allocate extra runtime graph fields.

The actual typed named-place selection, reception and physical store are
shared by native and walker. The numeric receiver consumes one prepared
expression and applies the same runtime value receive. No separate parser
or execution rule is introduced for var. This slice does not close every
path occurrence/index/descriptor or broader receiver case, the remaining
C cleanup, common collector/three passes, final FULL or §§8/8a.


Baseline published269:5f468398b569e10802a487ee64cc07cf8ef5761b.
The old267 candidate was three-way merged against its original266 base into
the current269 sources. Only normalized temporary inputs were used to
avoid a whole-file CRLF/LF conflict; frozen stages and old WIP were unchanged.
Seven compiler/tool deltas are retained; BNOT and prepared-prefix/deref fixes
from269 are present. Source184 includes the two existing diagnostic fixtures
as maintained L2. The explicit-data witness now also checks that the reached
ordinary var assignment changes D/var/x to2, while D/x becomes13 and
S/var/x remains2. The physical source-cell witness keeps D/x10 distinct
from D/var/x2.

This is not a declaration of complete ordinary-var semantics. The author
question is resolved; exact call/data/source roles must be implemented by
the common mechanism, with no name-specific execution/rebinding rule.
Short-call var, FREE-root paths, uniform status/closure removal,
collector/three passes/FULL and8/8a remain open. No build/result yet.

## Initial preparation and tool result

The 184-input candidate manifest is
0334dd014cbed622f84a4dcddbb0194d013ecd21832752c4c3521a996a8710a4.
Prepare01 completed six language-owned verify/manifest/stage-copy steps;
reuse completed five, using the existing 232 named generated support paths
from coherent boot131b. The core source is not taken from old WIP wholesale.
Tool build01 completed 2026-11-03T07:20:16.3464973Z to
07:21:58.0772139Z, RebuildExit0. Actual tool SHA256:
4723ed04f4a79a04d164080a0d11595a00ccced100a23ed5338df032cce9dae5.
Its output directory remains cold-tp132/tool131 because the reused recipe
retained its label; the source and exported L2DataBinding contracts are132.
Do not interpret that directory label as source131 or rebuild to rename it.
Frontend fe132a started at07:22:08.8273271Z; its result is still pending.

The active v3 U3 paragraph still contained the old data-rebinding proposal.
It now points to the confirmed ordinary declaration/assignment and atom
rules, without declaring their implementation complete.

## Focus and actual walker observation

fe132a completed07:25:58.5150975Z,33 producer commands exit0;
frontend SHA ffbc29fb13d4a47e8a0fa98311c0aa496d0b3538955fb8b502ad7a633e7260bb.
Suite01 has2 rows/0 failures: data_source_cells and unary_complement,
native/forced root0/root1 actual7. The explicit_data_var_field fixture
was run once via the existing os-walk-witness to collect production and
observed results without duplicating its plain build.

Observation01,07:26:34.4488010Z to07:26:37.8463882Z, is NOT a green whole
witness: its static l1_binds_native classifier returns-1 for an ordinary
namespace S (two NATIVE failures). All eight actual executions return7;
observed forced runs each contain WALK_BODY S once, native runs none.
Independent generated-L1 inspection maps source name S to l2_nsp[0].
Native2440..2443 selects that node and sets native=l2_m0_tr;
forced2468..2473 selects the same node and emits no native assignment;
the freshly allocated Structure retains its initial zero word.
Thus actual walking and the strengthened D/var/x=2 result are established;
the method-only text classifier is not silently declared successful.
Neither oracle nor driver was weakened or patched. The existing G2 suite
will verify this fixture again with the genuinely new generation tuple.

Frozen boot132a starts from source0334DD01,184 maintained inputs;
its four preparation steps completed. Whole quick result is pending.

## Following open implementation boundary (read-only during bootstrap)

The existing Copy/Inner witness from266 remains a separate FREE-root path
failure. Current resolve path_root_select retains the hidden input row;
path_root_close preserves its selected contract. path_walk_bound then calls
path_walk_steps_from, whose no-schema branch (resolve3144..3147 in269)
rejects the first named step before any actual runtime value can be used.
The walker OF path currently projects a physical index or an admitted
model/code slot (walk_values3467..3634). A repair must share the actual
place selection and classification with native, preserve the current held
root value and named admission, and must not substitute a lexical schema
or introduce body preflight. No new runtime implementation is claimed here.

The independent observer check also reads node allocation:
lmx_value_owned78..88 initializes native to zero. The forced S constructor
omits its native assignment, consistent with both actual WALK_BODY logs.

## Admission-use review before publication

One further separating case is prepared at tp132-unused-probe/unused_data.lm2:
the same S/var and D/var both include an unused nested field, while D has no
separate top-level unused cell. The body refers only to x; its reached var
assignment has a compatible nested destination. collect_data_bindings sets
m_uses for every added alias, dyn_local scan_bound repeats that mark, and
split_data_row/place tables currently include all logical aliases. This
may demand data/unused despite no consumer of it. The concern must be
checked with the one prepared case after boot132a, before landing. No
runtime failure or new normative choice is inferred from this note.


## Boot132a completed; unused binding failure confirmed

Boot132a completed07:40:04.9505308Z, BootstrapExit0,764.07s. Each
generation has248 inventory hashes;496 actual hashes checked, zero stale.
245 files match raw, three equal-size PE files differ only at actual
TimeDateStamp/CheckSum offsets136/137/216/217. All33/39/6 producer commands
in each generation exit0. Consumed-inputs306 match raw; working tool is G2.
The independent hash/producers receipts are retained under pins.

This does not accept the candidate: tp132-unused-probe-01 completed
07:40:36.4158295Z, SuiteExit1,one row/four run failures. Both native/forced
compile, but both roots close R0 unsuccessfully before the expected exit.
The unused nested declaration was incorrectly a top-level data requirement.
Fix02 removes eager use marks, retains entry visibility, and records actual
reads/writes through scan_bound. The common split-place predicate excludes
unused logical aliases, while written body declarations retain their rules.
The existing explicit_data_var_field fixture now includes the separating
unused nested field and verifies its reached assignment. No new language
rule, body preflight, driver change, or weakened expected value is introduced.
Frozen132a and its historical receipts remain unchanged; selfbuild is269.

## Author-history correction before publication

The exact2026-10-15T22:09:00.405Z author example was recovered from the
same chat (msg_01a1419c-89f4-7ba2-bbe2-aaf98a1f12d4). Reserved var defaults
to the selected data reference; assigning var replaces that binding
normally. Later explicit paths use its new value. The recent documentation
claim that this reference cannot change was incorrect and is removed.

Boot132b remains a useful generation check of the frozen candidate, not
acceptance of ordinary-var semantics. In particular, the current maintained
explicit_data_var_field candidate still expects a write to D/var merely
from the var head; it does not separate the reserved activation reference
from an explicit field path. DO NOT LAND270 or accept that oracle as the
author's rule. Keep the frozen results; adapt the active implementation and
separating case to the recovered ordinary assignment, with no new author
question. Selfbuild269 remains the accepted package.

## Normative correction source and next implementation boundary

The full point5 and example are archived verbatim in LMX_blog/2026-11-03.md,
with the original message id and timestamp. Adjacent author replies in the
same bounded history extract include the instruction to document the change
at2026-10-15T22:20:13.297Z; there is no unresolved request for author approval.
The live book's RU/EN namespace tables and ordinary-var section, migration
plan, coding instruction and resolved U3 question now agree on the default
reference and ordinary assignment. Generated RU/EN must be rerendered from
the book after the one current bootstrap completes.

Current source has no default reserved-var binding: path_root_select handles
ordinary roots and node; the sole walker literal var lookup selects a code
field for unary-call data. The proposed fix must initialize the real local
binding from the selected data and reuse ordinary place/read/write/address
semantics, including the author's local @ rule. A lexical code/var shortcut
or a required data/var field cannot implement that binding. A separating
case must read var/x before reassignment (selected data), then after an
ordinary var assignment (new reference), while an actual data/var field
remains separately observable. No implementation of that path is claimed.

## Boot132b diagnostic result

Boot132b ended2026-11-03T08:02:20.0110732Z, BootstrapExit0,790.29s.
Both generation smoke lists have9rows/0failures. Independent hashes verify
all184 source inputs and both248-entry inventories (496 actual hashes):
245 raw-equal, three equal-size PE files differing only in actual
TimeDateStamp/CheckSum offsets136/137/216/217. Consumed inputs306 match raw,
and the working tool equals G2. All33/39/6 producer commands in each
generation exit0. Exact receipts:
pins/boot132b-quick.terminal.txt,
pins/boot132b-independent-hashes.json, pins/boot132b-producers.json.
Source manifest1d03f906a1708a2e65f1845b2f0a9f750e7dce57699eea5a800c9cf79e53f76e.
G2frontend8a41861fb97a5282baa055ddb5fa26619fb229d0bcf0722a762a4963cb364ecf.
G2tool4aae5f226b61d9e87643db2c9909babb8d1de369d779ed74bc7e0b7a94167ce6.
The pipeline has ended. There is no G2 semantic acceptance or landing270;
selfbuild269 remains unchanged for the ordinary-var correction described above.

The corrected book was rendered by the accepted boot131b working tool
using pins/docs270-render02.command; its actual terminal records exit0.
The following docs270-norm-check is the existing language-owned complete
documentation check, not a compiler/test run of the candidate.

## Documentation correction verified; semantic diagnostic remains open

docs270-norm-check01 (named docs270-norm-check) exited1 before the EOL
phase because the new archive link needed an explicit id anchor. The link
and anchor were corrected; docs270-render03 exited0. The ordinary complete
docs270-norm-check02 ran2026-11-03T08:03:59.8281123Z through
08:06:57.9117729Z and exited0:35 paired semantic chapters,14 implements
cases,27 paired grammar sections,44 verbatim excerpts,615 imported files,
links/opening and LF for15838 indexed files. No checker rule was changed.
The primary point5 excerpt is a contiguous exact match of the recovered
author message, including original escapes, typos and HTML sequences.

The mutable explicit_data_var_field fixture now separates initial var=data
from reassignment and from the distinct explicit D/var field; its SHA256 is
262aaba319522ecb08f8181c6afe07557e3150f435d5bf614398c1efca1b79d3.
Only this revised variant/test copy changed; frozen132b and its source
manifest stay unchanged. The existing suite recipe ran one diagnostic
using the verified132b G2 compiler/runtime/tool:
pins/tp132-var-binding-probe-01.terminal.txt and .log,
2026-11-03T08:07:21.1951527Z through08:07:21.5891638Z.
SuiteExit1,one row/two translation failures. Both native and forced reject
the first var/x at4:13 with "field path goes through a slot with no Structure",
atom=x. This is a confirmed implementation gap, not a normative refusal or
a successful semantic test. Do not land270 from the previous green oracle.
Next: provide the actual default binding and reuse the common runtime path
and ordinary assignment; preserve data-field/activation-cell distinction.

## Shared selected-cell classification (fix03)

The native emitter no longer prints a second graph-cell classification
algorithm. lm_compiler_emit_selected_graph_place emits one call to
lmx_walk_graph_cell_place. That kernel function and lmx_walk_place_mode
use lmx_walk_cell_place for an already selected cell; descriptor storage,
actual primitive type and the existing low-box reference context remain
distinct. Field-name resolution, admission and write ordering are unchanged.
The walker's typed-cell fallback remains after the graph-witness branch.
The two helpers are exported by tools/build.lm2 (154 walk-value exports).

Source manifest56563d207b06c8dc3eaa1f55982ce9c41613393856d97d1aa8d2d1f27c04c16d
has184 inputs. Changed files are recorded by pins/tp132-fix03.json;
the files subsequently edited have exact copies in
pins/tp132-fix03-sources/. Frozen132b is unchanged.

Actual records:
- tp132c-tool-01:08:13:35.5124306Z–08:15:13.5999924Z, RebuildExit0;
  toola02798401620677dc004e9c9949e8ae2e6b03b0fd558ff324b49ce37a3980186.
- tp132c-rt-01:RuntimeExit0, driver
  d2fce4a717c7166615233d77aeb8cc7d34b4b187e6867620663a203868c883a6,
  observed4ab9806ed3f2b9d2a7cf1e1d86a2fb6751a4247961e6a941a29c9f956d609f6a.
- tp132c-fe-01:FrontendExit0, frontend
  d211f7363ea4f10e4c7cbad868e416493bc6f58e7bcbdd6f881c9e0c9debaabb.
- tp132-cell-suite-01:08:23:13.7010835Z–08:23:35.2196882Z,
  SuiteExit0,3rows/0failures. Existing free_model_admit,
  free_graph_address and free_held_model each return7 in native/forced,
  root0/root1. These are component checks of the common physical-place
  layer, not acceptance of the still failing var-path example.

## Initial selected-data reference (fix04–06, implementation in progress)

The existing shared lmx_activation_resolve_input now receives the selected
data explicitly from native self or walker frame.node. An unresolved hidden
input named var starts as a local LmxWalkValue reference to those data;
written formals retain their existing contract. No data/var field is read,
created or used as the variable's storage. Ordinary subsequent input writes
remain on the existing shared value/place path.

data_source_cells adds a separating execution of an ordinary Structure:
var first equals the explicitly selected D; var: D/var then changes the
local reference, with D/x and D/var/x still distinct and unchanged.
This does not yet cover the source-definition var: (...) assignment or
an unknown field path rooted in the actual reference; neither is closed.

The first runtime attempt tp132d-rt-01 (rt132d) exited1 at L2:2826:62:
the existing opaque frame.node member needed the written Lmx ABI cast.
tp132d-rt-02 (rt132e) then exited1 at C compilation: the existing
activation_check call still used the old helper signature. Its sole change
is an explicit null selected-data argument; every assertion and expected
value is unchanged. Both failed records remain intact.
tp132d-rt-03 (rt132f) ran08:26:31.8867685Z–08:27:22.1543904Z,
RuntimeExit0; driver9a8eaeec9d74c2b9bf8b31bd6d12149769d6a16e38f45f98fe29d40452722ff1,
observed5cef429ee2946f174ee950aded643943ef2c6e2f338baba066cf09976603abd8.

Current source manifest99964bdf36470f2953e2cdf0a4905939a4cee65c4ca295ec7134cec548cce701
has184 inputs and13 changed paths (the driver signature call is included).
pins/tp132-fix06-variant.json records the exact current variant hashes.
Frontend tp132d-fe-01 completed08:27:35.4000446Z–08:31:22.3190083Z,
FrontendExit0, SHA7854104121eb96852eedbfc1b0b385725077182b28bd316c8415704e00313e75.
The three-row tp132-var-cell-suite-01 ran08:31:49.3260861Z–08:32:03.3837438Z,
SuiteExit1: two translation failures in data_source_cells, both at10:16
on atom D: "an operand beside a runtime-typed value has no value record
(an opaque C value: receive it into a typed local first)".
free_name_chain and free_pointer_paths each return7 in native/forced,
root0/root1. The initial-var test has not executed successfully.

The failure is a producer gap: prep_context_full returned only a raw
reference for a known source Structure (and similarly for a bare method
occurrence). fix07 supplies the full record through the existing
emit_material_value_full graph packer at those two known-reference
producers. It does not guess a type for an opaque C value or invoke a bare
atom. The fixture and its expectations are unchanged.
tp132e-fe-01 is the current single frontend build. Its runtime is the
ABI-compatible successful rt132f; fix07 changes only the frontend.
No new bootstrap, source landing, publication270 or full var-path
acceptance is claimed. Accepted selfbuild remains269.

## Resolved graph roots retain their full value (fix07–08)

tp132e-fe-01 completed08:33:27.7281605Z–08:37:16.3171686Z,
FrontendExit0; frontend1e23a88337daed91d835b66c45366bbfc8956149f18baa04ca0bdb882671f3b4.
tp132-var-cell-suite-02 ran08:37:26.5806674Z–08:37:40.3119112Z,
SuiteExit1,3rows/2failures: the same data_source_cells translation
refusal10:16 on D, with free_name_chain and free_pointer_paths green
in both modes and roots. fix07 did not cover the active prepared-path
producer: the zero-step branch still discarded full_value and its
binding helper returned graph roots as raw references only.

fix08 routes a zero-step read directly through the existing
emit_binding_value_full, removing its duplicate own/formal dispatch.
That producer now packs completed node/body/method/namespace references
through the same material-value helper. Explicit raw C bindings retain
their prior path. No name is searched again to manufacture a type.
The fixture and its expectations are unchanged.

pins/tp132-fix08-variant.json records the13 changed paths. The current
184-input source manifest is
fc37c6b59487a5429c8f03693d3f083c09558eaf0834539a3564439936c4224c.
The earlier lower source is preserved in pins/tp132-fix07-lower.lm2.
tp132e-fe-02/fe132f is the single frontend build for this change, using
tool132c and boot132bG2; runtime rt132f remains compatible.
No publication270 or full var-path acceptance is claimed.

### fix08 actual execution and next dependency

tp132e-fe-02/fe132f completed08:38:43.3136032Z–08:42:33.5435535Z,
FrontendExit0, frontend4ed7a671a0db7793793b2a3c164317cb59c445f9ca82c910eae3ec9b9b0e4456.
tp132-var-cell-suite-03 ran08:42:41.3906686Z–08:42:58.1512623Z,
SuiteExit1,3rows/4failures. data_source_cells now builds in native and
forced mode. Each execution (root0/root1) stops with success0 and no exit
Message; expected7 is unchanged. free_name_chain and free_pointer_paths
remain7 in both modes and roots. This is not a passing var implementation.

Actual native p.lm1 now contains the full graph value for D at577–579
and the common value_bin call586. It also exposes the next defect:
l2_m2 reads var from input0 at570–571, but collected a separate own var
and required D/var (534–562). At754–803 the source var:D/var is emitted
as a source-definition write into that data field. This cannot implement
the author's ordinary assignment to the existing local reference.

Next: make the existing reserved input visible to statement collection
and binding selection, so ordinary reads and writes select that same
activation cell. Preserve source definitions as source graph metadata;
do not make D/var a substitute variable, execute the Structure, or
change the fixture to avoid the assignment. Keep explicitly declared
methods/formals/typed bindings and unit-level declarations distinct.
The full literal var:(...) assignment and actual FREE-root path var/x
remain open. Their implementation must use ordinary receiving/places
and reached admission, not a type guessed from a lexical var body.
The current literal/path fixture is still the unchanged
262aaba319522ecb08f8181c6afe07557e3150f435d5bf614398c1efca1b79d3.

All recorded component operations are complete; no bootstrap after132b,
source landing270 or new accepted selfbuild is claimed.

## Reserved input binding classification (fix09–10)

fix09 registers the implicit data-reference input before assignment collection,
keeps its local input place distinct from a same-name source Structure,
and stops classifying an assignment to that input as a new local definition.
Source graph children remain source metadata. Native formal_row is the common
binding decision that walker helpers must also use.

tp132e-fe-03/fe132g ran08:49:33.2669585Z–08:51:22.6654269Z,
FrontendExit1: core4105 C-call actual had no declared C type before a later
actual call. No frontend artifact was produced. fix10 adds the existing
LmP0Text pointer contract to that actual; it changes no language rule.
The following named operation is tp132e-fe-04/fe132h, started08:53:11.8757156Z.
Its completion and focused results are recorded below when available.


### fix10 result; source retention is not an execution skip

fe132h completed08:53:11.8757156Z–08:57:04.9147102Z, FrontendExit0,
4194a75bd267bb1147eb100d19f1125b1964b5d76d7b968b01b07813d3c176f4.
tp132-var-cell-suite-04 completed08:57:07.6367148Z–08:57:24.4236605Z,
3rows/4failures. Both modes/roots now pass the initial var==D check,
then exit85 at the unchanged post-assignment check var==D/var.
The generated native code has no store between the two comparisons:
ns_constructed_row made the source assignment disappear as inert.
Chain and pointer fixtures remain green; this is not var acceptance.

fix11 separates that decision from retained source ownership: a common
assignment_input identifies an existing activation input; inert_source_row
excludes its reached assignment. Both native and walker use formal_row
for that input's binding. The source child remains retained, and walker
schedules the ordinary SET_ARG operation alongside it through the existing
source-field emission path. There is no new runtime opcode or second store
algorithm. Full literal assignment and FREE-root selection are still open.
Pre-fix11 sources: pins/tp132-fix10-binding-sources; changed hashes:
pins/tp132-fix11-variant.json. The one frontend build is tp132e-fe-05/fe132i.


### fix11 result and retained Structure values (fix12)

fe132i completed09:00:07.6925445Z–09:03:50.5901401Z,
FrontendExit0, fcbd65633bf09faaf5a8ff76dd249af26a49196a70519d2fdc55dbacd8a10f74.
The184 consumed source hashes match manifest
6e1ed2794865f01c0b68071a213c860e08b538663a24e5376025e804baac9724
(pins/tp132-fix11-state.json).
tp132-var-cell-suite-05 ran09:03:54.5106490Z–09:04:08.3510681Z,
3rows/2translation failures. data_source_cells fails5:9 on int,
"int has no value": the retained var:(int:x2) source value was sent
through expression evaluation. free_name_chain/free_pointer_paths pass
both modes and roots. No runtime var PASS is claimed.

fix12 distinguishes the already retained Structure RHS from an expression
using the existing source-body classification. The Structure producer's
actual graph reference is passed to the same native input-place store or
walker SET_ARG; no fields are executed or copied to a hidden graph.
The SET_ARG emission is shared by expression and retained-value producers.
Original source ownership stays intact. Pre-change sources are in
pins/tp132-fix11-binding-sources; the13 hashes are in
pins/tp132-fix12-variant.json. Build tp132e-fe-06/fe132j and focused
recipe tp132-var-cell-suite-06 are the next named operations.


### Local reference store gap (fix13–14)

fe132j completed09:06:16.4772916Z–09:10:06.9610392Z,
FrontendExit0, 89efeb45939fba9802d6ee7456dcdfaa47f1e66a0f60382b02bfda2cd4befd2c.
Focus06 completed09:10:13.5389622Z–09:10:30.2580790Z,
3rows/4runtime failures: data_source_cells stops with success0 in both
modes/roots; chain and pointer fixtures pass. Its native source still
preferred own_find_decl metadata over the already resolved input. fix13
corrects that choice; fe132k completed (tp132e-fe-07), but focus07 still
has4runtime failures in the same fixture. Historical terminals are intact.

Both emitters now contain the ordinary input store. Inspection of
lmx_value_cell_fill exposes the shared physical gap: a reference input
uses its Value.ref void* member outside a pool, so cell_access leaves the
unsupplied callback at0 and fill refuses it. fix14 supplies void* writing
only when owner is a present REFERENCE and cell is exactly &owner.ref.
An arbitrary non-pool address gets no bypass; the existing immutable,
rebind preparation and native-reset paths remain in place.
Native FREE assignment now asks for the existing input's actual type
(LMX_TYPE_NONE witness), matching walked SET_ARG, rather than requiring
its type to equal the RHS representation before receiving it.

lmx_value_owned.lm2 is the14th changed input; all other source inventories
remain184. pins/tp132-fix14-variant.json records the delta. Runtime build
is tp132d-rt-04/rt132g; the next frontend is tp132e-fe-08/fe132l.
No passing var result or new accepted selfbuild is claimed here.


### Physical dispatch build and separating fixture

fe132k ran09:11:18.1934769Z–09:15:09.1429530Z, FrontendExit0,
7271f61ac2624162e241843d3debb9ba47661cacb0098b6cbb3db870a7cbb683.
Focus07 ran09:15:28.1934219Z–09:15:44.8090315Z;3rows/4runtime failures
at data_source_cells, success0. The generated S now writes its input;
forced source also contains SET_ARG. The shared local reference callback
gap above remains the measured dependent repair.

tp132d-rt-04/rt132g failed in generated C: assigning a C callback with
bare write: was a callable application. rt132h (tp132d-rt-05) then
refused the leading-@ callback reassignment at the later status: call
with "assignment value has unknown type". These are retained build
failures, not language rules or a new question to the author.
The final implementation chooses the exact local void* physical write
at dispatch and otherwise calls the provided typed callback; preparation,
context update and commit remain one algorithm, with no recursive fallback.

tp132d-rt-06/rt132i completed09:18:11.1263284Z–09:19:01.2909180Z,
RuntimeExit0; driver89d97924b7620fd93a9010e8ef293f2853bba1e25a95314abb058057ba8fd085,
observed a9e14bf8f4987ce9cf2cf36cb222a475764b08e6427a613db5c7e6c03ee361e9.
The existing data_source_cells fixture now also reaches a literal
Structure assignment in T and checks its reference against T/var,
while both D/x and D/var/x remain unchanged. Original S checks remain.
The expected result stays7. New fixture SHA:
ed21b568a1f5fc023cd98c3a1bbc169b6a36acc3c628d2d99cd905ffd241a956.
The earlier fixture is preserved in pins/data-source-cells-before-literal-fix17.lm2.
All14 candidate hashes are pins/tp132-fix17-variant.json.
The single frontend operation is tp132e-fe-08/fe132l; focus08 uses rt132i.

### Current measured boundary: empty required-place interface (fix18–19)

fe132l completed FrontendExit0 (tp132e-fe-08), SHA
ba9a479ac15fd734b03211de475b406dc5be741e2d0a0fc2d3170356b3f89a0b.
Focus08 ran09:24:59.5426700Z–09:25:16.8474342Z,3rows/4runtime failures.
fix18 makes the exact owner.ref physical dispatch independent of the
nonzero generic default callback; rt132j (tp132d-rt-07) completed0.
Focus09 still has4runtime failures in data_source_cells; chain/pointer
remain green. Neither attempt is acceptance of ordinary var assignment.

Read-only debugger inspection of that exact built executable narrowed
the current failure BEFORE S/T entry, not in the local store. GDB
pins/tp132-var-cell-debug-05.txt shows call_places_open returns OK with
answer NO to lmx_call_selected_structure; debug03 never reaches S/T.
The source selected by the native call has no explicit interface row
when its required-place count is zero. Kernel fallback then treats its
named source statements as data requirements. The previously described
local reference writer gap is a code repair, not the measured explanation
of this particular current failure. No driver/oracle was modified.

fix19 emits the existing required-place interface also for ordinary
Structures with zero requirements. A real one-byte names buffer avoids
a null/zero-array surrogate. Kernel call_places_open honors a present
empty interface instead of falling back to source fields; the existing
unknown-interface fallback is retained. Native and walked entries consume
the same row. No source body is executed or copied to implement assignment.
src/l2src/lmx_implements.lm2 is the15th changed input (184 total);
pins/tp132-fix19-variant.json records all hashes. Backups are
pins/tp132-fix18-binding-sources. Prepared runtime rt132k/tp132d-rt-08,
frontend fe132m/tp132e-fe-09, focus tp132-var-cell-suite-10.
The full FREE-root var/field case remains open. Selfbuild269 is unchanged.

Runtime rt132k completed09:31:03.5212267Z–09:31:52.6235814Z,
RuntimeExit0; driver277cc1d040935b033561182b5a6ec342a1d3be2453fdddf92574c06afe352ac7,
observed02147ce0160cc9a3be75c5fcec3811c91433278bdb626df02a48b42dc33098a1.
Frontend fe132m started09:31:57.7843997Z (tp132e-fe-09).
Focus10 is now6 existing rows (pins/focus132-var-places.tsv): the three
var/input/pointer rows plus unary_data_selection, split_selected_code and
split_copy_bound_data. The additional cases are directly affected by the
common admission fix: absent data, actual selected code and copied mapping.
No broad/FULL run is started for this component.

### Focused reference and literal assignment passes

fe132m completed09:31:57.7843997Z–09:35:53.0578760Z,
FrontendExit0; SHA05cd416cf2bd216d222170fc1422259d9e406dbb2ae9d1778a2311bb340155c6.
tp132-var-cell-suite-10 completed SuiteExit0,6rows/0failures,
native/forced on both roots. Its data_source_cells reaches both S's
reference RHS and T's retained Structure RHS, sees the updated local
reference, and preserves the explicitly separate original D fields.
unary_data_selection, split_selected_code, split_copy_bound_data,
free_name_chain and free_pointer_paths also pass. Expected exits stay7;
no driver/oracle/source fixture was weakened for the empty-interface fix.

StartUTC 2026-11-03T09:35:55.9375185Z tool a02798401620677dc004e9c9949e8ae2e6b03b0fd558ff324b49ce37a3980186 fe 05cd416cf2bd216d222170fc1422259d9e406dbb2ae9d1778a2311bb340155c6 prod 277cc1d040935b033561182b5a6ec342a1d3be2453fdddf92574c06afe352ac7 obs 02147ce0160cc9a3be75c5fcec3811c91433278bdb626df02a48b42dc33098a1 list 386045092dc5b444cf152136c5789593e4406ce74c5ccc778a0f8c248029ff6e fixture ed21b568a1f5fc023cd98c3a1bbc169b6a36acc3c628d2d99cd905ffd241a956
EndUTC 2026-11-03T09:36:24.3857300Z SuiteExit 0
The exact source inventory is rehashed in pins/tp132-fix19-state.json:
184 inputs,0 mismatches,15 changed inputs; accepted selfbuild269 unchanged.
This closes the measured local reference/literal assignment boundary,
not the FREE-root field-path case, all270, C, FULL or §§8/8a.
All current component pipelines are finished. Next: implement actual
field selection through the common runtime place/admission machinery,
then run unchanged explicit_data_var_field and the related focused rows.
No new bootstrap or landing270 has been started.

Additional route observation tp132t-obs-var01 ran09:37:40.6060770Z–
09:37:44.8070258Z using the unchanged data_source_cells and exact
fe132m/rt132k pair. All prod/observed executions return7. The observed
forced runs count S=1,T=1 in each root; native runs count neither body
as walked. Thus the assignment check really reaches both executors.

The OSWALK command as a whole returns1/4failures: its static L1 native
binding recognizer returns -1 for ordinary Structures S/T in both modes.
This is NOT an OSWALK PASS and must be repaired/verified before landing270.
Manual inspection of the generated native L1 shows the concrete bindings
to l2_m2_tr and l2_m4_tr (lines4529/4537); forced L1 binds only the module
entry, not those bodies. Historical observer receipt remains intact.
No driver oracle or expected runtime result was changed.

### Ordinary Structure native-binding witness repaired (fix20)

Only tools/build.lm2 changes from fix19. l1_binds_native now recognizes the
existing source-name statement on an l2_nsp descriptor, then checks the
native assignment to that exact descriptor. Merely emitting a body is
not accepted as a binding. A duplicate witness name remains unresolved.
The prior unit-slot/header-part method paths are retained. No runtime,
frontend, fixture, expected result or observed-body counter changed.

Backup pins/tp132-fix19-build.lm2; candidate build source SHA
273f11f88d3f668f629d3661152f694c1481295d32e885f1f945091a98834e17.
tp132-prepare-20 completed4 steps/0; source manifest
8f75e9c8bf7d627c5d07c5d1a0c9e8b41247ec6c0fbe5b179285a5059b164c5f.
pins/tp132-fix20-state.json rehashes all184 actual inputs with0 mismatches;
15 changed input hashes are pins/tp132-fix20-variant.json.

tp132d-tool-01 ran09:44:41.9161342Z–09:46:20.6534909Z,
RebuildExit0; tool132d SHA
eb7ce31207132f97bdc7e05ae9139ead19afaae0bd80b08a693651bcfa69e94b.
The existing language-owned rebuild verifies startup/hash and smoke;
REBUILD tool0failures. Its runtime/frontend producers remain boot132bG2.

Using tool132d with the unchanged fe132m/rt132k tuple:
- tp132t-obs-var02,09:46:55.8205464Z–09:47:00.1677369Z:
  WitnessExit0/OSWALK0. S=1,T=1 forced on each root, neither walked in
  native; native bindings found in native L1 and absent in forced L1.
- tp132t-obs-methods02,09:47:04.6226077Z–09:47:08.8065887Z:
  WitnessExit0/OSWALK0. Existing os_walk_values still recognizes the
  fn bindings; os_mix=2,os_twice=2,run=1 in forced, none walked in native.
All production/observed runs return7. The earlier var01 receipt retains
its4 failures as history. This closes the observer recognizer gap only.

The exact October15 quotation was rechecked against the saved original
message: verbatim match. Archive/book/RU/EN bytes equal published35abfc67;
actual remote main is35abfc67. No unchanged docs check was repeated.
Selfbuild269 remains accepted. No new bootstrap/landing270; all current
component pipelines are complete. The unchanged full var/field fixture
and general actual FREE-root projection remain the next implementation.


### Actual FREE-root field selection (fix21/22, work in progress)

The held runtime root now enters one lmx_walk_value_named_place operation,
shared by native emission and reached OF/PUT_OF. It uses the existing
call-field admission and physical cell classifier. No var-name branch,
new data graph, static type guessed from the lexical source, or execution
of a stored Structure was added. NAME steps are represented by the
existing OF selector; non-NAME steps, occurrence selection, dynamic
address and descriptor writes are not claimed complete here.

fix21 source manifest27b39079036f34ec04b23af8cdb6d021325038f8174d760fd3d1b47eca718883.
tool132e rebuild09:53:28.0966486–09:55:09.0432018Z exit0;
rt132l09:55:15.1497724–09:56:05.3382011Z exit0;
fe132n09:56:21.1976716–10:00:06.5792857Z exit0.
Exact producer/source/output hashes are the named terminal receipts
tp132e-tool-01, tp132e-rt-01 and tp132f-fe-01 in P/pins.

tp132-var-path-suite-01 ran the existing six focused rows plus the
unchanged explicit_data_var_field. Six rows pass both executors/roots;
the full field case refuses translation at17:5 in both modes:
"root operation not walkable yet: a field path", frame var\x.
This is not a semantic refusal: rw_path_records had converted FREE45
through own_ty_of_param, losing the actual value category as -1.

fix22 preserves FREE as a runtime value record in that transport and
registers the two new lower helpers in the normal machine-module list.
Backups pins/tp132-fix21-core.lm2 and tp132-fix21-build.lm2;
15 candidate hashes in pins/tp132-fix22-variant.json. Prepare22 completed
four steps/0; source manifest
0cad4a33a9a15579603fc34dad7814d5ec4c15943dba2e19dd16eaa8eddd7906.
tool132f rebuild is the current single pipeline. No acceptance of fix22,
whole-bootstrap or landing270 is claimed.


fix22 tool132f completed10:01:48.4961533–10:03:28.3838717Z,exit0;
SHA fe184127776f06d2fb74362fd0ffe26d31e23af25642bc7dae03dacb17257d64.
fe132o completed from the named tp132g-fe-01 recipe,exit0; frontend
500a0b26230dd1f8b4e78a9fca91b82ae1d5961424601c4e21a04e71998d76fe.
Runtime rt132l was reused unchanged: this delta only changes compiler
transport/emission and machine exports. Actual184 inputs rehashed with
zero mismatches in pins/tp132-fix22-state.json.

tp132-var-path-suite-02: seven rows,two failures. The unchanged full
explicit_data_var_field now translates in both modes; native returns7
in both roots. Forced returns3/INVALID in both roots. Prior six rows stay
green. No assertion, fixture, driver or runtime oracle was modified.

Read-only GDB of that exact p-prod.exe (pins/tp132-var-path-debug-02/03)
shows all three reached named field selections succeed. The generated
forced L1 then exposes the mechanical defect: l2_rw368 is a LIT with an
empty payload. FREE45 was passed to rw_tlit as if it were a primitive
literal storage type; no matching producer existed, yet emission returned
success. The debugger's first attempt01 failed on charset display; it
is not a successful execution receipt.

fix23 changes only rw_evaluate_span: FREE denotes absence of a static
receiving type, so the ordinary operand producer chooses its own source
type. Runtime admission still belongs to the reached receiving place.
Backup pins/tp132-fix22-emit.lm2;15 hashes in fix23-variant.json.
Prepare23 completed4steps/0. fe132p (tp132h-fe-01) is the current single
pipeline,using tool132f and boot132bG2;rt132l remains unchanged.
No PASS or landing for fix23 is claimed before its actual focus.

Beyond the unchanged int-field witness, contextual numeric literal
reception into another actual field type, named failure routing at a
native path store, and dynamic path address/occurrence/index/descriptor
boundaries remain to check/implement before claiming general FREE-root
path completion. Do not infer their closure from this example.


### Full ordinary-var field witness passes on fix23

fe132p completed10:11:24.5534234–10:15:53.1493512Z,FrontendExit0;
SHA871e35e95f065703384fd362002fd2df70d2f1490d0e8bd815bfe225854d333f.
Exact184 inputs rehashed in pins/tp132-fix23-state.json,zero mismatches;
manifesteb0cdf05560180b601a4a379717d04af5e8a92687ce3f712459f91ea13a9c138.
Tool132f and runtime rt132l are unchanged from the preceding receipts.

tp132-var-path-suite-03 ran10:16:37.1954742–10:17:10.0610740Z:
SuiteExit0,7rows0failures. Each row builds native/forced and returns7 on
both roots. The unchanged explicit_data_var_field checks initial var/x10,
ordinary bare x publication to D/x13, ordinary var replacement with its
stored Structure, the subsequent var/x2, then explicit write var/x6.
D/var/x0 and D/var/unused0 remain separate and unchanged; S/var/x6 and
S/var/unused9 satisfy the final assertions. Fixture SHA
262aaba319522ecb08f8181c6afe07557e3150f435d5bf614398c1efca1b79d3.
No oracle, driver, expected value, or fixture was weakened.

tp132t-obs-varpath01 uses the same fe132p/rt132l/source with the existing
language-owned observer. WitnessExit0/OSWALK0: S is bound native only
in native mode; forced has no native binding and walks S exactly once on
each root. Native walks no S body. Both production and observed runs
return7. The earlier two failed focus receipts remain intact as history.

This closes the full original int-field separating witness and its
native/walker discrepancy, not general FREE-root path completeness.
The receiving/contextual-literal, native named-failure, address, occurrence,
mixed-index and descriptor boundaries listed above remain open.
All current component pipelines are finished. No new whole-bootstrap,
landing270 or publication of WIP270. Accepted selfbuild remains269.
The published norm remains35abfc67; its exact Oct15 excerpt was checked
again against msg_01a1419c-89f4-7ba2-bbe2-aaf98a1f12d4. Goal stays active.

### Actual path receiving and address: fix26 in progress

The original full ordinary-var assertions are retained. The same fixture
now calls one WriteNine body with int, unsigned and size_t fields, receives
4294967296U into size_t, takes the selected field's address, and catches
convert/implements from incompatible actual reception/missing selection.

Baseline receive01 refused the nested typed receiver at var/cell
("a named Structure's item is neither a field nor a statement"). This is
an open common collector gap, not a language prohibition. The focused
actual-type mismatch uses a predeclared int field as its source instead.
Baseline receive02 then refused p: @(var/cell), "assignment value has
unknown type". Both receipts are preserved; no PASS is inferred.

fix26 replaces fix23's provisional default literal type with an ordinary
three-part contextual LIT carrying magnitude and U spelling. The walker
calls the same lmx_walk_value_lit as native; the reached place supplies the
receiving type. Existing two-part typed LIT is unchanged. Actual path
addresses retain the FREE category until selecting the same physical
place and calling the common place_address. The common native store
routes its named statuses through existing local implicit-throw delivery;
the actual path applies the existing write guard before RHS evaluation.
No branch names var and no driver/oracle change is introduced here.

Four prior sources are in pins/tp132-fix25-sources. Prepare26 completed
4steps/0; source manifest3b9e33dfb497ea8c5cd9bc338914ab920b41d55b770fd2dc119fa5d80a9af0c6.
pins/tp132-fix26-state.json rehashed184/0. Tool132f is unchanged.
rt132m completed10:25:31.5725107–10:26:31.2201258Z,RuntimeExit0:
driver312ba215386f8d9b991af47f893b18bc055c5be94792b35e5dd7192076fd8489,
observe101ecf55e3881fd81c9f8f34d42f7e8888eec344ffcb386121692978590db415.
Frontend fe132q is running under tp132i-fe-01. The one-row receive03
recipe is prepared for that exact new tuple. No fix26 PASS/landing or
whole-bootstrap is claimed before its results.

fix26 frontend fe132q ended10:30:57.8394935Z,exit1 at final C compile.
COMPILE.log:692/695 records embedded L2Path reached via an invalid ->.
This is the new emitter source access, not a failure of the language
fixture. The diagnostic and its generated C are retained.

fix27 uses the existing explicit address of the embedded L2Path, then
reads its fields through that typed pointer; no generated output is
handwritten. Backup pins/tp132-fix26-lower.lm2;15 source hashes in
tp132-fix27-variant.json. Prepare27 completed4steps/0.
fe132r under tp132j-fe-01 is the single active pipeline. rt132m/tool132f
are unchanged and reused; receive03 now names fe132r before its first run.

fe132r completed10:31:40.1395540–10:36:34.7906006Z,FrontendExit0,
SHA2274b32ffb7cbf7502c1914de1bb2ff8a08aa43cd84dbf95ebc2198ae4480b7a.
pins/tp132-fix27-state.json verifies184/0. Before the first runtime probe,
fix28 adds the declared p pointer field explicitly to the passed W data:
an ordinary named Structure must receive its declared places. The
original var oracle and all new expected values are unchanged.
FixtureSHAff0b6695bfa6eab386f26bac8e38d8ca630f3900e23e842c9eb4a7582e4f1fea.
Prepare28 completed4steps/0; only the fixture changed.

receive03 ran10:36:47.2454428–10:36:48.3541443Z,SuiteExit1,1row/2failures
at L1 translation: p.lm1:783 "if without body" in both modes. Source
translation succeeded; new named-status delivery was emitted one indent
too shallow inside the present-value branch. No runtime PASS is claimed.

fix29 changes only that shared emitter's delivery indentation using the
existing bump_ind helper. Prior source pins/tp132-fix28-lower.lm2;
new lowerSHA2e7f41006d64fd631f7fa01eb31b559d69187b133d5029deeb9fb168b26fcd3e.
Prepare29 completed4steps/0. The existing build-frontend-part mode now
translates only l2_frontend_lower. Its177 unchanged source/artifact inputs
and49 unchanged declarations come from the actual completed fe132r record
and maintained source manifest; all110 recorded src/header files matched
their bytes before reuse. Existing L2 manifest command created both
manifests with0 failures; the build verifies them before use and the ABI
again afterwards. No new runner/cache or handwritten L1/C is introduced.
fe132s/tp132k-fe-01 is the current single pipeline; rt132m/tool132f reused.
receive04 is prepared for fe132s. No landing or whole-bootstrap270 yet.

fix29 fe132s completed10:38:27.9593969–10:41:18.8508111Z,exit0;
SHA297586c1e4c6ad3ee0d15eb542b00bd72ab82298b7a7d0fc050e8b257212d3b8.
Component record13steps/0; only the lower frontend module was translated,
plus the existing backend/libc steps. Actual184 source hashes and all49
declaration invariants matched in pins/tp132-fix29-state.json.
Source manifest1513e557f8be37c162be224deea45b04f778d9595cb585eb3da8a05482cafcc8.

receive04 completed10:41:22.3018993–10:41:29.4240564Z,1row/0failures:
native and forced both roots return7. This verifies the retained original
var oracle and the new three numeric receivers, large size_t literal,
field address/deref/store, local convert and implements handlers.

neighbours01 completed10:41:39.8910836–10:42:05.5137456Z,6rows/2failures.
Five rows remain green. unary_data_selection native/forced refuses at L2,
"internal: a catch without its pad". The default hidden-input preparation
uses the common store before the method body pad exists. Emitting a
lexical body handler there is wrong even when the generated status branch
would never be reached for this default value. The source test is unchanged.

fix30 passes the existing entry/body boundary through native_input_store
to the same received-place emitter. Entry failure returns the named
ordinal to its caller, without body-handler delivery or publication of
not-yet-loaded own working values. Reached body stores retain the common
existing lexical handler/publication path. Admission/store algorithm
remains the shared runtime function; no test/driver/grammar change.
Backup pins/tp132-fix29-lower.lm2;newlower6d73ed576343aa3feb16e5ce774470b5fa7d3936d12edae9885d5dbdb41c7b5e.
Prepare30 completed4steps/0. fe132t/tp132l-fe-01 runs the same existing
component mode; unchanged177 inputs and49 ABI manifest reused after their
actual fix29 verification. Target receive05 and neighbours02 are prepared.
No whole-bootstrap/landing270 or closure of all actual-path gaps.
The generated LIT-format comment in tools/build.lm2 also needs its small
three-part-carrier documentation update before the coherent final package.

fix30 translated lower successfully, then the existing byte-invariant
check stopped fe132t before backend/C compilation: lower.h.lm1 differs.
The new private helper inserted ahead of the last exported functions
shifted their generated parameter identifiers (p544..546 to p545..547);
this is not a runtime test result. Generated evidence retained at
pins/tp132-fix30-lower.h.lm1,source backup tp132-fix30-lower.lm2.

fix31 moves that private helper to the end of the same maintained module.
Its behavior and entry/body routing are unchanged; public method ordering
is retained. Prepare31 completed4steps/0. fe132u/tp132m-fe-01 regenerates
lower with the same177 reuse entries and48 unchanged declarations. The
currently stale selected lower.h.lm1 is deliberately regenerated, not
manually edited; all49 original declaration hashes must be checked again
afterwards before claiming invariant closure. No weakened runtime oracle,
new language rule, or claim of successful tests from this build.

### fix31 receiving/address and adjacent cases pass

fe132u completed10:46:42.4916212–10:49:25.9903279Z,FrontendExit0,
163.50s. Actual13 component steps exit0; frontend
0ea73f14f49aae0d3ee4c55ff06278fa0f8c1823bf4c14177f542624134e5b4d.
After regeneration ALL49 original declaration files match their original
fix29 hashes byte-for-byte, including the selected lower.h.lm1. The
temporary48-file component precondition did not replace that final49-file
verification. Actual184 maintained inputs match with0 mismatches:
manifest256cb6c59d76ce580b84d1db034fdae70f1c1964377d918ce023c7e03abc42b3.
Evidence: pins/tp132-fix31-state.json. Runtime rt132m/tool132f unchanged.

receive05:10:49:32.8852712–10:49:39.5547331Z,SuiteExit0,1row/0fail.
neighbours02:10:49:42.7511817–10:50:12.5398407Z,SuiteExit0,6rows/0fail.
Each runs native/forced at both roots and returns7. The unary-data
translation regression is repaired with the original fixture unchanged.
The expanded ordinary-var fixture retains the original replacement and
separate data/var assertions, plus int/unsigned/size_t reception,
4294967296U, selected-cell address/deref/write, and caught actual
convert/implements. It explicitly supplies AddressWide's declared p
place in W; no hidden data field is created by the test.

tp132t-obs-varpath02:10:50:18.8159072–10:50:26.4738877Z,WitnessExit0,
OSWALK0. Both roots: forced has no native binding and actually walks
S1,WriteNine3,WriteWide1,AddressWide1,CatchConvert1,CatchMissing1.
Native walks none of those bodies. Production and observed results are7.

These results close this numeric receiving/address and failure-routing
delta, not all actual-path operations. The nested typed receiver collector,
occurrence/mixed-index/descriptor and raw-only consumer boundaries remain
open. The small generated LIT-format comment update is still pending for
the coherent package. There is no new whole-bootstrap/landing270; accepted
selfbuild269 and published norm35abfc67 are unchanged. All current
component/test/observer pipelines are finished; goal remains active.

### fix32–34: consumed numeric receiver is a value at an ordinary path

The exact October15 author source and the published norm35abfc67 were
rechecked. Ordinary assignment changes the same var binding; no new
execution/data-selection exception is introduced.

fix32 corrects ns_decl_first: decl_content=4 describes a typed RHS, but
only a binding name can introduce the outer field. A path target remains
a statement. Original core and fixture are in pins/tp132-fix32-before.
fe132v/tp132n-fe-01 completed10:55:02.8843970–10:57:33.0717778Z,exit0.
receive06 then refused both modes at93:15,"int has no value". This proves
the collector refusal was passed, but did NOT close the nested receiver.

fix33 adds one common prepared numeric-receiver projection in resolve.
CHECK, type, native emission and retained emission consume the same
borrowed operand. A language numeric receiver uses existing actual
lmx_walk_value_receive; native emits that call and the walker's existing
RECEIVE operation accepts its three-part value/witness form. Five-part
pointer reception stays unchanged. No new opcode, driver/oracle patch,
temporary graph, or per-var parser exists. The machine-only C path keeps
the existing typed receiving emitter. Material numeric receiver scope
is verified here; this is not closure of every receiver/model/empty-value
case or the shared collector/three-pass work.

The declaration list appends primary_numeric_receiver as export120,
count121. The other48 declaration files remain byte-identical; removing
that ONE appended line from resolve.h.lm1 reproduces the original file's
SHA. The existing component mode translates resolve/lower/emit only,
with171 exact unchanged/source reuse entries and48 declaration invariants.
The generated LIT comment now describes its contextual three-part form.

Tool132g:tp132g-tool-01,11:00:32.5383023–11:02:36.8800558Z,6steps0.
SHA78b06f9529b7c9b927c7dab7ed33f97ad22a5e06fb57167c2c765a3cfd9f57aa.
rt132n:tp132g-rt-01,11:02:54.1127908–11:03:52.7591186Z,39steps0.
driver5a39a205a07e4e40b185251811ac2897b1ff22660d1224f04637f25deef06ada;
observe60ff05dd4bff4c1567775b10c4ec5348a4f614a2eb697756fca2e38cd1b99adb.
fe132w:tp132o-fe-01,11:04:04.5227022–11:07:55.6066889Z,15steps0.
SHAf5ca7767c156d96b22cdde5f7660a10e72057f9afa6d802cbb1616ef64cd4110.

fix34 retains the original var oracle unchanged. The existing fixture
also checks cell:int:1 as a declaration, consumed int:15 inside arithmetic,
I/cell:int:19 through an ordinary static root, an explicit typed result
refused at an actual size_t place, and an actual pointer refused by the
inner int receiver before writing the outer target. Both failures are
caught convert, not generic INVALID or translation bans.

Actual receive07:11:08:00–11:08:09.5956545Z,1row/0failures.
Actual neighbours03:11:08:13.0968362–11:08:43.1492402Z,6rows/0failures.
Native and forced at roots0/1 all return7. OSWALK varpath03:
11:08:47.6658066–11:08:57.4772884Z,WitnessExit0/OSWALK0.
Forced actually walks S1,WriteNine3,WriteWide1,AddressWide1,
CatchConvert1,CatchMissing1,WriteTyped1,CatchTypedConvert1,CatchInnerConvert1
at each root; native walks none. Production and observed results agree.

pins/tp132-fix34-state.json records184 maintained hashes/0 mismatches,
manifeste4d1e376bc1be9a8018a05f3519ca60b34226e1ad99a860a5122d205df877ad0,
fixture278c62be4abc3e10ea5a6fae5bc3c5c2c66fb0773b40c46f78edef73e6bcbfb4.
No landing270 yet. Source/current paths outside the allowlist remain alone.

Whole boot132c is now the single pipeline, using the existing bootstrap
quick command: fresh stage cold-boot132c/source184 exact, G0tool132g and
the coherent boot132b/G2 frontend+backend. Preparation4steps0; terminal
pins/boot132c-quick.terminal.txt started11:10:05.7616252Z, noEnd yet.
Exec session14256 owns it. Observed fresh l2trans5860,parent2676,
creation11:10:18.554792Z belongs to this exact stage; recheck rather than
treating that PID as permanent. Invocation records boot132g-prepare.command
and boot132g-quick.command,TP_TRY=c. Do not start another pipeline.

After completion inspect actual G1/G2 receipts, then run the appropriate
G2 focus/observer, docs and exact landing if coherent. Remaining actual-path
occurrence/mixed INDEX/descriptor/raw-only boundaries, broader receivers,
C/M2/preflight, common collector/three passes, FULL and §§8/8a are open.
Goal stays active; accepted selfbuild remains269 until a verified landing.

### boot132c completed, final G2 focus running

Whole quick completed11:10:05.7616252–11:24:45.7090672Z,
BootstrapExit0,879.95s. Each generation passed9 smoke rows with0 failures.
All actual33 frontend,39 runtime and6 tool inner commands per generation
exit0. G1 frontend is produced by boot132b/G2; G2 by the new G1 frontend.

Independent read-only verification rehashed all248 inventory paths per
generation:0 stale,245 raw-equal and3 equal-size PE binaries with changes
only at their actual TimeDateStamp/CheckSum bytes136/137/216/217.
Both306-line consumed-input snapshots are raw-equal. All184 frozen source
hashes match E4D1E376; the working tool is the actual G2 tool.
Full results: pins/boot132c-independent-hashes.json and boot132c-producers.json.

Working tool2e936543ab9c36c842b03c489052b44a6bcaa3110f8018851f2ee07f7f49ba26;
G2frontendfa22765b71e99c1e2f5b4eb0f01588eec5859e9d30405945492a73dece09b99d.
Production and observation runtime hashes equal the already tested
rt132n objects. tp132c-suite-g2 now runs the existing32-row focused list
with this new coherent tuple. There is no landing/publication270 yet.

### Final G2 acceptance and landing

G2 focus: 2026-11-03T11:25:00.8181619Z–2026-11-03T11:27:55.2051087Z,SuiteExit0,32rows/0failures.
G2 observation: 2026-11-03T11:28:01.7276334Z–2026-11-03T11:28:11.4096222Z,WitnessExit0,OSWALK0.
Production and observed results are7 at both roots. Forced execution has
no native binding for the nine named bodies and actually walks S1,
WriteNine3,WriteWide1,AddressWide1,CatchConvert1,CatchMissing1,
WriteTyped1,CatchTypedConvert1,CatchInnerConvert1. Native walks none.

Land270c completed all8 existing language-owned steps. Both65-source
consumed subsets verify against the selected package. All184 selfbuild
files were independently rehashed with0 mismatches; its input manifest is
the frozen source E4D1E376. No other source selection or unrelated WIP was
adopted. Archival text copies normalize only BOM/line endings to UTF-8 LF;
original receipts remain unchanged and are bound by evidence.sha256.
Documentation checks and publication follow this verified landing.

### Repository LF normalization, without changing the frozen build

The precommit check found3505 CRLF pairs in the changed l2_driver.lm2.
Git's declared text/eol=lf rule would otherwise publish bytes different
from its manifest. Only those pairs were normalized in selfbuild; no
code token or assertion changed, and cold-boot132c remains untouched.
The raw frozen source hash is c0aedb1920b6736d2fe5db5335b03994ea866a325baf4bb6181ff0b683eb0c49;
the published LF file is d05751bd2a8f0e8eca62917e38f9d2da2f40127e7ad4f2142472c4a2c9bc54da.

Existing language manifest/verify steps land270lf both exit0. Independent
verification checks all184 published hashes:183 raw-equal to frozen, and
exact CRLF-to-LF equality for the sole differing file. Published manifest
4f50cea1483d62d53a5c65d5f5f8f02fcec6b40bcac97304651e9fd4faedb94d; frozen/tested manifest remains E4D1E376. The two generations and
G2 results above apply to that frozen source; no new bootstrap is claimed
for a line-ending-only publication normalization.
Receipts: land270-lf-normalization.json and land270-published-source.json.

### Final canonical source and documentation check

git diff --check additionally identified one extra empty EOF line in
l2_frontend_views.lm2. Only that final byte was removed; its frozen original
remains unchanged. The final184-file published package has182 raw-equal
inputs, the exact driver CRLF-to-LF change, and this one EOF byte change.
No token/assertion changed. Existing land270lf2 manifest/verify exit0.
Final manifest b9af771a661c8a2ecff90dcd881c055af974d301460d3493fa5cf9d69533a916; full source proof is land270-final-source.json
and source270-final.sha256. Earlier landing and normalization receipts
above are preserved as the sequence, not relabelled final bytes.

docs270c-check:11:30:46.2373167Z–11:33:53.7649824Z,exit0:
35 paired semantic chapters,14 implements cases,27 paired grammar sections,
44 verbatim excerpts,615 imports,links,opening,LF15929 indexed files;
driver60 checks. Subsequent changes are only the EOF normalization,
updated hashes and these terminal records. The final exact staged source
hashes and git diff --check are checked before committing.

Final precommit verification: all184 Git-index source blobs match the
published manifest exactly;0 mismatches. The exact123-path allowlist
excludes unrelated WIP. LF and git diff --cached --check both pass.
