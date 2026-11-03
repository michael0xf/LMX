# Slice 266 — unary calls with absent data

This completed slice preserves absent unary data and admits required places before dispatch. The verified results below supersede the baseline and execution checkpoints. Declared-var binding and FREE-root field paths remain open.

Baseline on published slice 265, `cd69ef0c54d2e03cdff88b215310addbd274b290`, using the actual G2 tool, frontend and runtime from `boot127b`. The three probes are in `build2/codex_fix250generationchain01/tp128-call-baseline-01`. Their receipt is `pins/tp128-call-base-01.terminal.txt` under the same workspace. All expected success exits are 7.

| Control | Actual native and forced outcome |
| --- | --- |
| Explicit `call: Copy\\Inner Copy\\Inner` inside a method | Translation refuses the path at 11:11, atom Copy. The explicit data isolates this from shorthand call semantics. |
| A held ordinary code has no var and tries to update its declared x | Both roots return 82. The check that the original x retains 2 fails. A missing data place must reach the caller's call handler. |
| A held ordinary code declares var after the first use of x | Translation refuses at 3:8 with unknown field path root, atom x. The declared var must supply the selected data and the body's corresponding x place. |

The shorthand rule is in the method-parts section of the [semantics book](../../../provenance/semantics-book.md). The current kernel `lmx_call_unary_data` selects the fixed var part for the FN role and returns the code for an ordinary Structure. Frame entry and the generic native dispatch also require non-null data. The next implementation must distinguish missing data from the executable occurrence without synthesizing a hidden object, retain the free-input-only case, and use the common place admission for a selected var.

The explicit free-root trace from slice 265 has one prepared path step, FREE root type 45, input slot 1 and no static schema at that first step. The failure is in `lm_compiler_rw_prepared_value`. This path needs the actual value's interface and physical places, without making a lexical type a prerequisite.

At this baseline checkpoint the source package was still the verified 179-input slice 265. The implementation and completed results below supersede that checkpoint.

## Candidate tp128: absent data, common call admission

The slice now has a six-input candidate over the published 179-input base.
It changes lmx_walk_values, lmx_call, lmx_implements, the generated native
entry guard in l2_frontend_emit, the suite list and the new
dyn/unary_data_selection.lm2. The total is 180 inputs. No maintained inputs
have been landed and no slice 266 commit exists yet.

- Unary ordinary data selection no longer substitutes the code when the
  physical var place is absent. The ABI and frame can retain absent data.
- Both unary and explicit Structure calls admit their actual demanded places
  before dispatch. Missing required storage gives the named call refusal.
- A receiver-produced fn supplies its actual var part as the data description;
  args, return and body are not demanded fields of data.
- Explicit null remains distinct from absent unary data and must fault.
- The generated native entry requires its actual code occurrence. It no longer
  treats a missing data object as a missing code occurrence.

tp128t-rt-01 and tp128t-fe-01 completed. The first 13-row focus had 12
failures: the fn admission incorrectly used its outer four-part description,
and two new external-write probes incorrectly read the caller's held snapshot.
Those probes were corrected to read the physical external field separately
and still assert that the caller snapshot is unchanged. No driver oracle
was changed. After the fn-description correction, tp128-unary-02 completed
10 rows with zero failures, both roots/native/forced.

The current third candidate adds explicit-null control and reruns the related
transport/address/operation/call focus. Its source manifest is
556841e159fa7aedbc079ca9324130d341fca9393f14b2c417678673bf57d425.
The actual stage rehash was 180/0 mismatches before that run.

Still OPEN: binding the fields declared in an ordinary var into its body's
local data interface, including forward use; dynamic FREE-root field paths
(the corrected explicit Copy test); complete occurrence/ambiguity behaviour.
This candidate does not claim those compiler changes or all of N4-U.

## Execution checkpoint before completion

tp128t-rt-03 completed RuntimeExit 0. The component focus tp128-unary-03
completed SuiteExit 0, 28 rows and zero failures, native and forced on both
roots. The expanded unary fixture includes the explicit-null interpreter
handler. The frontend is fe128a (only its native-entry invariant changed);
runtime is rt128c. Earlier failures remain historical receipts.

The 180-input package was frozen into cold-boot128a with four successful
language-owned prepare steps. Source-tp128 and source-boot128a have equal
manifest bytes. The ongoing single pipeline is boot128a-quick, launched by
the published boot127b G2 tool/frontend; it has not been restarted.
The live functions cell is 1132: after a successful bootstrap it runs the
existing compare recipe and tp128-suite-g2 in sequence. Resume that exact
cell or inspect its named terminal; do not start a second pipeline.

Next after its actual completion: verify G1/G2 inventories and actual producer
receipts plus G2 focus, then prepare the normal land266/docs266/commit/push
steps. Those landing and docs recipes have NOT yet been prepared or run.
Selfbuild and HEAD are still published slice 265. No full-goal claim follows
from this focused slice. Ordinary declared-var binding and the FREE-root
field path remain the next implementation, before completing C and the rest
of the original goal.

## Verified result

The common unary selector now looks for the unique physical var place of an
ordinary code occurrence through the existing call-field resolver. It returns
absent data when none exists; it does not return the code as a substitute.
Receiver-produced FN keeps its actual four-part representation and uses the
var part as the data description for common admission. No hidden Structure
or permanent activation field is synthesized.

Both ordinary unary and explicit calls now admit required data places before
dispatch. Missing required storage reaches the named call handler. A body
without such requirements can run with absent data; an explicitly supplied
null operand remains an interpreter refusal. The native entry invariant
checks the code occurrence, while native dispatch and walker frame entry
allow absent data.

The new fixture checks these distinctions in native and forced execution on
both roots. S has a local x but no var: its unary call reaches the call handler
before writing, so S.x retains 2. Explicitly supplying S as data then changes
that same physical field to 4. NoData executes an explicit external write
without data; FreeOnly changes its local free input and writes that value
through an explicit external path. Caller quote and signal working snapshots
retain their earlier values. A separate reader observes the external writes.

The component focus passed 28 rows with zero failures. Bootstrap built and
tested both generations in 762.66 seconds, smoke 9/0 in each generation.
The actual G2 passed all 28 focused rows.
[Focus](records/tp128-suite-g2.terminal.txt).
[Generation comparison](records/boot128a-compare.txt).

The 180 source inputs were independently hashed in the candidate and frozen
stage. The two actual generation inventories each contained 248 files;
245 were byte-identical, 3 differed only in PE timestamp/checksum fields.
All frontend/runtime/tool producer steps completed with zero exit status.
Consumed-input snapshots agree and the promoted working bundle is G2.
The language-owned landing verified and copied the same package into selfbuild.

| Artifact | SHA-256 |
| --- | --- |
| Input list | `50baf20d0a6ef9035805080c4f543a404d79236db4f963672e6840866ab79ed4` |
| Input manifest | `556841e159fa7aedbc079ca9324130d341fca9393f14b2c417678673bf57d425` |
| Working tool | `57304b57646e2f60a4ff00994c85d895363e6cafd40a4222dee0167d795c0921` |
| G2 frontend | `04eecfad1bca6b4e382851ad0ca6f514e904a43b477eae225a9a1a3328c87281` |
| Production runtime | `e617e95da4019c90a4b47adcb62ddfc79d9818d0729c4bb43b7ba7164a581c96` |
| Observation runtime | `84ef7a8471496a0225482985e773f856cf89f075b29ffcd0ff12409dc68bc774` |

The promoted G2 documentation check verified 35 paired semantic chapters, 14 implements cases, 615 imported files and index line endings for 15518 tracked files. [Documentation check](records/docs266-check.log).

## Remaining implementation

The ordinary declared-var case still needs the compiler to bind var's fields
to the body's selected data places, including use before the var declaration.
The existing explicit Copy free-root path still refuses in prepared-path
lowering. Full occurrence/ambiguity and var rebinding are not proved by this
slice. The remaining closures, common collector, three compiler passes,
final FULL and sections 8/8a remain open.
