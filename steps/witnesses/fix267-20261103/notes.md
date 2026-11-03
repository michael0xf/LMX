# Slice 267 candidate: declared data bindings

Current WIP, 2026-11-03 05:10Z: fe129e and two focused rows pass.
This is not a published or whole-bootstrap slice. Maintained source is still266.
The ordinary var execution question U3 remains pending; no semantic choice
has been made. Independent typed-native shift guard work has a measured
native-versus-walker separating witness and is the next available step.

Baseline: published slice 266, 01a7e3a8ff7d95c1427ceb45f6d73c0174b8339a.
The existing explicit-var probe refuses the first x before its var declaration.
This candidate adds logical activation bindings linked to the child's original
declaration rows. It allocates no additional runtime graph fields. Source
coordinates remain those of the existing child; reads, writes and addresses
of the enclosing body must use its admitted data-place map.

At its creation, the initial candidate was unbuilt and unverified. The handling of the var
definition itself, occurrence rules, FREE-root paths and the rest of the
full goal remain open. No success or publication is claimed.

Preparation 01: all six language-owned manifest/verify/stage-copy steps exited 0.
The wrapper then rejected manifest counts 180/180 because it retained the previous
slice's 179/180 guard; its executed bytes are preserved as
pins/tp129-prepare-01.executed.command. Future guards now expect 180/180 and
12 difference lines for the six changed inputs. Independent readback verified
all 180 staged and all 180 maintained hashes, equal path sets, exactly six
changes. The existing reuse command completed five steps with exit 0, including
a source verification. No stage-copy was repeated to repair this wrapper-only error.

Tool129 rebuilt successfully (tp129-tool-01), including its real smoke suite
and start/hash check. New tool SHA aaa32ba50d118e685846b55f9c86dfb65fc78924c4823b39ec81fa358aa33a4c.
The candidate frontend fe129a is being built by boot128a G2.
The two-row diagnostic probe separates the logical binding from the reached
var definition: one uses the previous unary example, another explicitly supplies
both x and var places in D. The unary example's retained expected value is not
yet an accepted oracle for U3 var execution/rebinding semantics.

Frontend fe129a completed with exit 0, SHA def1f9159e89ac855121f04925958ecf27e0cc3811d5c99f657856af9d5c4202.
The two-row probe refused translation in both modes at x: x + 3
(assignment value has incompatible type; 4 failures). Debugger trace03
locates this in own_add called by collect_source_definition, before execution:
the namespace collector had wrongly classified the pre-var x application as
a new Structure. Debug traces01/02 did not set breakpoints because command-line
-ex arguments were split; they are not diagnostic proof. Trace03 used debugger
stdin and captured the actual call stack.
Fix02 precollects the unique written var child through the existing namespace
collector, makes its actual declared field rows visible to namespace head
resolution, and reserves its parent field at the original source position.
Seven candidate inputs now differ. Prepare02 completed four language-owned steps
with exit 0; fe129b is the current build. No runtime result or var-semantic
closure is claimed.

fe129b failed while translating core at the new recursive call's raw C member arguments (line8650); no executable was produced. Fix03 uses the existing explicit const pointer casts at this foreign ABI boundary. The early child collection also applies the existing ns_nested_def resolution so an already-bound head is never promoted into a declaration merely by spelling. Probe02 was prepared but not run because frontend02 failed.

fe129c succeeded at 04:54:02Z, executable
85b710c725d3fbad22e7f5f724d70175fb7181f3a8d83cb2bb3b47ec36cd97f0.
Probe03 now translates the early x in both modes. Unary execution is refused:
debug admission01 observes named_places return NO with requirements var and x.
Selected S/var has x only. The reached meaning of ordinary var is the open U3
normative question sent to the author; only that dependent work is held.

The explicit D/x diagnostic fails in rw_path_records with namespace row3,
kind7, owner2. Its own source declaration had been folded into the child's
logical alias. Fix04 collects actual body declarations before adding var
bindings. An existing local declaration retains its own physical source cell;
a newly added logical binding alone uses the child source coordinates.
Both remain visible from the body start via the explicit-var binding record.
This fix changes compiler collection only; it does not define var execution.

fe129d completed 05:04:05Z, SHA3355445247e45a0f6c1c39fca0f2184e01646da13d87fe152259b26df303041a.
Probe04: data_source_cells passes native/forced and root0/root1 (D/x=10,
D/var/x=2). The explicit-data program now compiles in both modes but refuses
execution. Debug exec01 proves named_places YES; exec02 proves an unwanted
absent FREE input named x is still demanded, and admit_free_inputs returns10.
The scanner's pre-declaration seen table had not marked the new entry binding.
Fix05 seeds these actual ordinary data bindings through existing scan_bound
before scanning the body, without scanning or evaluating initializers.
The first edit attempt searched the wrong function name and wrote no source;
prepare05 consequently verified unchanged fix04 bytes. No build followed it.
The successful edit is prepared as receipt06; all earlier receipts stay intact.

fe129e completed 05:09:53.7332873Z, SHA
8326f708a9f7bb2c6c671133d86260d78dfea12c377fd86497902547caf409a6.
Prepare06 verified the fix05 bytes; no runtime/tool source changed.
tp129-var-probe-05 ran 05:09:56.4376210Z–05:10:01.1398101Z:
SuiteExit0, SUITE2 rows/0 failures. Actual four runs per fixture native/forced
root0/root1 all exit7. The construction-only case preserves D/x=10 and
D/var/x=2. The explicit-data case binds S's early x to D/x, publishes13,
and preserves S/var/x=2. The program supplies its own data/var place, so this
does not settle the held U3 question or justify a unary-success claim.

Independent next step, existing BITWISE-OPERATORS-NOT-CLASSIFIED ledger:
tp129-typedshift-probe-01 ran 05:10:02.0240534Z–05:10:07.6078621Z.
Its one L2 fixture has typed unsigned/int/size_t operands and catches the
existing interpreter fault for width/negative-count/signed-overflow cases.
Native root0/root1 fails with program exit81: left(1U,32) did not throw.
Forced walker root0/root1 both exit7, including all later cases.
This is an actual separating result, not a claim that later native cases ran.
Fixture SHA26b33b1793c68e8e21803f9b17d33b8051feb397a39a18a15d3cc63ce4c0ca7e.
No driver/oracle changes. Core source below remains byte-for-byte the tested
candidate; no compiler/test/docs process remains live after these runs.

Next implementation: route typed native language shifts through the existing
common numeric operation/admission before any C shift; preserve raw foreign
machine ABI behavior where that is its actual contract. The current typed
path in lower:11732 emits a direct C token after emit_live_int_bin_full
declines a machine operator. Shared lmx_walk_value_bin already performs the
width/count/signed-left checks and the forced witness proves them.
Unary ~ remains a separate open part of that ledger. Keep full C/shared
collector/3passes/S8/mail goal active; this partial WIP is not its completion.
