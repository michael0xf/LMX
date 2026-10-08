# T7-LOCAL-NAMED-UNIT: actual-occurrence lexical projection

Owner: Codex, sole writer/build after Opus RELEASE
`CODEX-OPUS-HANDOFF-20261008-01`. Parent:
`K03-READ-FIELD-CLOSURE-20261008-31`. This is an implementation log and
acceptance checklist, not a new language contract.

## Baseline and scope

Code `4fb6dbbe`, handoff `e0727b69`, ownership documentation `72c18d51`.
`opus_full_65`: RED68/2616; no OK→FAIL against full63. Stable `l2src/`
is outside this change. `l2_driver_launch.err` is preserved and unstaged.

Reproduction `build/l2_harness/codex_t7_baseline_01`: 3 failures/7 targets.
`unit_merge_parent_t7_local_call` gives 117 instead of 77 natively and
with only the root walked; its methods-walked twin gives 77. The part
pair refuses local S's free `cnt` at translation.

## Required dependency chain (do not stop after a child result)

1. Inventory the actual construction parents and every reader of unit,
   receiving model, own-field owner and lexical fallback; distinguish
   caller bindings from the copied lexical fallback.
2. Native unit/ancestor-container readers use the selected occurrence's real parent
   chain. Derive distances from committed source PLACE, not the number of
   control scopes or a fixed nesting limit. No global-unit fallback. Also
   gate `T7-PROJECTED-PARENT-FIELD`: a native local body's explicit NODE field
   must address the selected parent correctly. Under the existing composition
   rule, data-only composition preserves the model's slots; fix the producer
   that shifts them rather than adding a runtime coordinate lookup.
3. Extend part membership/visibility through nested source ownership;
   project numeric fallback from the selected occurrence in native and
   walker paths, preserving caller-source precedence.
4. Move receiving-boundary formation and class policy to the same relation.
   Their comparison happens before PLACE: do not compare strings generated
   in a reused buffer or pretend that late places are already available.
   Remove the remaining global policy; don't strengthen structural admission
   into equality of method/model identities.
5. Callable-merge construction copies the used lexical tree of the actual
   source occurrence and attaches under the corresponding copied parent,
   including a part root. A merge site supplies no new lexical parent.
6. Complete read-field closure/oracles, mutation controls and regression
   gates; record exact bytes and remaining expected-positive failures.
   Only then close this parent and proceed to PATH-STRUCTURE-LEAF.

Exact implementation boundary: `dev/l2src_sandbox/l2trans.lm1`, only required
shared constructor/reader helpers; corresponding `tests/unit_merge_parent_*`
fixtures and `tools/l2_harness.ps1` rows; factual plan/defect/current documents.
No changes to the language's dynamic precedence, base `Lmx`, native dispatch,
runtime names, extra graph objects, or stable root source tree.

## Inventory evidence

Diagnostic-only staged translator:
`build/l2_harness/codex_t7_census_01`, SHA256
`7A50146EE52E0C599E450A2851F23E3C80B353130FEB5ACD3D79D2E50F931433`.
`build/codex_handoff/t7_census_replay_01`: 2615 translations, six marker
families cover native unit, own owner, receiving projection, caller fallback,
trampoline fallback and T7 copy sources. This replay is not a harness gate.
The four fault-injection rows generate L1 in replay because replay does not
set the harness's fault environment. Replaying those four with the unmodified
full65 translator produces byte-identical L1; they are not instrumentation
regressions. Census comments/log messages are not proof of runtime behavior.

Opus read-only answer `CODEX-T7-PARENT-LINKS-20261008-03` corrects his draft:
`S` inside IF has chain S → body → IF Frame → model → unit (not merely
S → body → model → unit). Existing `build/opus_handoff/probes/lb_body.lm1`
shows final reparenting at 919–920. The committed GraphPlace holder includes
the operation Frame. Other container kinds must use their actual constructor
edges, not an assumed two links per control level.

Opus read-only correction `CODEX-T7-RECEIVING-PHASE-20261008-04`:
`l2_cfl_close` does not compute classes and does not call `l2_cfl_alike`.
The first class comparison is `l2_rw_call_at` in method COUNT, before final
PLACE; native emission repeats it later. A receiving-projection comparison
must therefore be stable across COUNT/PLACE/FILL. Source containers are lazy
and cannot supply the early key merely because they exist by native emission.

## Child 2: native readers (implemented, full regression measured)

`l2_lex_parent` obtains a local definition's owning source container and its
physical GraphPlace chain. `l2_lex_depth` walks this finite ownership relation;
`l2_emit_lex_spaces` emits incremental activation-local address projections.
These are pointers in the machine activation, not additional runtime graph
containers or a name lookup. Native `l2_m_unit_ref` and ancestor `l2_own_ctr`
now read this projection. The existing one-link unit case remains `node`.

The former receiving policy is explicitly named `l2_m_recv_policy` while
child 4 is still OPEN. Its global cases are NOT approved semantics or a
completed fix. The part producer and general fallback are still OPEN too.

`build/l2_harness/codex_t7_focus_01`: 7 OK/9 targets, 2 expected-positive
part failures unchanged. Both local_call rows pass (native/root walk/method
walk); new local_control pair, with two nested IF bodies and mutation of the
original after the copy, passes the same paths, 77. This focused run is not
the full gate. Translator SHA256:
`F139E8B29510627E` (display prefix; full hash in run artifacts).

The new nested-control witness also fails with the unchanged full65 translator:
`build/codex_handoff/t7_control_old_native_01/probe.exe 0 entry 7` reports
exit 81 instead of 7. It therefore distinguishes the old implementation, not
merely a newly green unrelated program.

Full-corpus translation replay, baseline versus this native-reader slice:
2615 rows, identical exits/diagnostics/output presence; 390 L1 differences.
Read-only hunk classification finds only activation-local parent projections,
unit-reference expressions, and ancestor-field source expressions (no other
edits). This is not execution coverage. Before final gates, an integer-overflow
check was added to the physical-link counter; final source SHA256
`DFA47E66120B603E78F49F91499A87C1D81AB04632EF7ADD9DC1E80EFFDA7E81`,
Git blob `d67f15cb11f77ed0035b5cd42c79a7368f37b907`.

Final-byte gates so far: `build/l2src/codex_kernel_01` GREEN297, 114
selftests actually ran (113 ordinary zero exits and the expected watchdog
fatal); `build/l3_selftest/codex_l3_01` all 11 suites and four type budgets OK.
`build/l2_harness/codex_full_01`: RED67/2618. Against full65: FAIL→OK 1
(`unit_merge_parent_t7_local_call`), OK→FAIL 0, added two local_control rows
(both OK), removed 0, unchanged messages for every remaining red row.
Frozen translator/fixture/harness hashes did not change during the gates.
This is a bounded development checkpoint, not full T7 or stable promotion.

The reason GraphPlace is a physical-parent witness here is not just the IF
example: `l2_construct_link` records only an owning attachment whose parent
matches the allocation's recorded constructor parent, and explicitly excludes
borrowed references. `l2_construct_place` resolves those edges after PLACE;
`l2_source_places_bind` publishes the source container's resolved place. A
local root is allocated under its definition field's unique owning container
by `l2_source_shell_emit`. Thus its one edge plus that holder chain reaches
the source method occurrence without interpreting a scope count as a layout.
Copying preserves these corresponding links under the existing copy contract.

Checkpoint committed/pushed as `65d60a49`, with all eight exact reviewed
paths. HEAD/remote equality and frozen source/fixture/harness hashes were
verified. No stable source was promoted; unrelated `l2_driver_launch.err`
remains untracked.

## Required closure control (found during the first full gate)

The local_call/local_control witnesses also call `get` in the outer model;
that outer use independently retains `get` in the copied lexical tree. A
stronger control must remove that outer call: model constructs and executes
local S, S alone calls `get`, model returns only `S\v`, and the original
`cnt` is changed from 7 to 11 after merge. Expected result remains 7.

Diagnostic source `build/codex_handoff/t7_local_only_get.lm2`, translated by
the frozen `codex_full_01` translator: generated `l2_t7_make_0` passes zero
use records to `lmx_graph_copy_part_used_owned`. `l2_source_refs_note` records
borrowed callable fields but not the external uses of the retained local
body; `l2_mu_collect_home` starts only at the outer model. This is static
generated-code evidence. After the full gate,
`build/codex_handoff/t7_local_only_get_before_native_01` measures native exit 3,
"a dynamic call of a value that is not a Structure", instead of expected 7.
Register and fix it through
the common retained-source/home closure, not by adding a syntax-specific
dependency or copying the whole unit. The parent cannot close without it.

Original diagnostic input, retained here so the ignored diagnostic is not its
only copy (normal `convert.lm2 primitive.lm2` harness inputs). Its data-first
merge spelling exercises the legacy T7 producer; the normative spelling for
this specialization is `merge(model; y: k)`, as explained below:

```yaml
int: cnt 7
fn: get () int
    return: node\cnt
fn: model (int: y) int
    S:
        int: v 0
        v: get()
    S
    return: S\v
fn: wrap (int: k) fn: () int
    return: merge(y: k; model)
sub: poke ()
    node\cnt: 11
@: w wrap(5)
poke()
int: result w()
int: ok 7
if: result != 7
    ok: 81
sendMessage: exit(exit_code: ok; stdout: ""; stderr: "")
return
```

The bounded closure implementation extends the existing merge-home worklist
with its anchor selector, rather than copying use records into another home.
It enumerates each reached home's retained local definitions through the original
source containers/definition fields (including definitions inside control
bodies), then enqueues their body procedures with the existing internal-node
selector `-1`. Their unit uses still close over unit methods; their NODE uses
are inside the selected source view, not unit-relative paths. It deduplicates
the home/selector pair and preserves the monotone fixed point. This reuses the same
closure for ordinary and callable merge; no depth bound, namespace-name scan,
runtime home registry, or whole-unit retention. Before accepting the change,
measure the local-only witness in native/root-walk/method-walk modes, add nested
local/control and transitive unit-call controls, and check local NODE paths do
not accidentally retain a prototype owner. The initial diagnostic draft was
built under `build/l2_harness/codex_t7_closure_stage_01` without changing the
then-frozen native-reader checkpoint. Its later promotion and gates are
recorded in child 2b below; the diagnostic build itself was not a release.
Additional draft control: `build/codex_handoff/t7_local_only_nested_get.lm2`
(IF → S → T → middle → get).

Read-only consultant result `CODEX-T7-LOCAL-USE-CLOSURE-20261008-05` agrees
that COUNT visits each local procedure and its uses are keyed by that home.
It also identifies coverage beyond the queue fix: receiving/non-receiving
admission model reads and some native-only hidden-input reads currently have
no use note. These are source-level findings, not newly measured runtime
failures. A future generalized fallback cannot put an outside-part-root use
under local NODE/selector -1: its actual external anchor/path must be recorded.
Do not declare the full read-field closure complete after the local-only
get witness passes.

Diagnostic draft blob `6cc8106c`, binary SHA256
`429C4F018D910E6379A39E91158173D3D5EC094F737EA31693358BDA18714ABF`:
`t7_local_only_get_after_*_01` and `t7_local_only_nested_get_after_*_01`
pass native/root-walk and methods-walked/root-walk combinations (exit 7).
The emitted copy records contain just the reached external method/cell paths,
not a whole-unit copy. Serial full-corpus translation replay
`build/codex_handoff/t7_closure_replay_01`: 2615 rows, 827 nonzero exits,
byte-identical diagnostics, output presence and generated L1 against the
first native-reader replay (`t7_changed_replay_01`). The existing corpus
does not distinguish the missing local-only dependency; the added isolated
controls do. These probes/replay are not a regression gate or a release.

### T7-PROJECTED-PARENT-FIELD (OPEN; existing required positive)

`build/codex_handoff/t7_local_only_node_get.lm2` adds `int: seed 6` to model
and changes S's assignment to `v: node\seed + get()`: expected 13. The draft
gives 12 natively (root's assertion sends exit 81), but passes with methods
walked, including root walk. Generated S reads parent slot 2, the prototype
model's seed coordinate; the actual T7 view stores bound y=5 at slot 2 and
seed at slot 3. The copy's get correctly supplies 7. This is a coordinate
reader defect, not a reason to change NODE semantics.

Independent baseline: remove `+ get()` and report result as the exit code
(`build/codex_handoff/t7_local_node_value.lm2`). Unchanged full65 translator
reports 5 instead of expected 6 in `t7_local_node_value_full65_native_01`.
The defect therefore predates both native-reader and closure drafts. Required
minimal body: model `(int: y)` contains `int: seed 6`, local S with
`int: v 0 / v: node\seed`, calls S and returns `S\v`; merge binds y=5.

Read-only Opus answer `CODEX-T7-NATIVE-VIEW-20261008-06` identifies the producer:
`l2_t7_fill` assigns added datum slots from 2, and `l2_t7_count` /
`l2_t7_emit_frames` start the model's body at `2 + nb`; `l2_t7_emit_make`
allocates and fills that shifted layout. Local S keeps the model's native
implementation, so the unchanged code reads the wrong parent slot. The
existing layout map only describes named Structure admission; it is not a
general map for arbitrary constructed method occurrences.

The existing norm in `docs/LMX_semantics.en.md#composition` requires the model
slots to stay in place and new fields to append, with unchanged code retaining
its native implementation. The next bounded fix must therefore preserve the
model's header/body/trailer coordinates and append new data in the existing
occurrence. Audit COUNT, PLACE, FILL and every `l2_t7_bound_slot` reader together.
Do not patch a reader offset by capture count, introduce a per-read runtime
map/registry, specialize native code per copy, use runtime names, add a hidden
graph, or turn off a required native body to make a witness green. The native
and walked positives remain in the parent checklist before T7 can close.

Bounded read-only consultation `CODEX-T7-LAYOUT-COUNT-20261008-07` checked the
four datum-slot consumers and pass order on source blob `6cc8106c`. COUNT and
PLACE only allocate the three-child AT shape; its numeric datum coordinate
is emitted in FILL. No earlier datum-coordinate cache was found. Candidate
implementation: use `l2_m_head(model)` as the body base in both T7 passes;
after measuring `made + one` in COUNT, finalize each added datum slot to
`head + steps + j` before PLACE, and include those appended data in the root's
allocation/recorded width. This is source evidence and an implementation plan,
not a tested fix. Gate local definitions directly and under nested control,
trailer-only models, multiple defaults, local NODE reads and copy/original
mutation separately. Capturing nested-method (A3) constructors must also be
audited before claiming the general layout/native-reuse contract complete.

### Fixture spelling and existing T7 composition debt

The new diagnostic inputs and the first versions of local_control,
local_only_get, local_only_nested_get and local_node_view inherited
`merge(y: k; model)` from the historical T7 witnesses. That is NOT the current
norm for specialization. `T7-DATA-FIRST-SHAPE` has been OPEN since 2026-10-04:
the implementation wrongly selects a unique unit method at any operand
position. The normative input here is `merge(model; y: k)`. A data-first
composition is not forbidden: by the general composition rule it constructs
an outer Structure with the nested method, not the same callable result.

After the frozen full02 gate completed, these four new specialization fixtures
were explicitly migrated to model-first. Their old bytes are preserved under
`build/codex_handoff/t7_fixture_spelling_01`, and the original local-only input
above stays historical evidence. The final-input focused gate is focus04
(completed below); no other old fixture was migrated. Do not call the
legacy data-first result normative. The related OPEN
`MERGE-KEEPS-MODEL-INTERFACE` requires a supplied default to remain an explicitly
passable formal; this queue fix and the planned layout correction do not
complete that contract or the general composition implementation.

## Child 2b: retained-local code-use closure (implemented, full regression measured)

The diagnostic worklist change is now live, byte-identical to staged draft
`6cc8106cfecc6eea5bfe8bf678d045760c0209ff`, SHA256
`D3F877F3E07AE3BC95D3765FD2AA7340D249F5390FFDF3075A75B1E4E99C149F`.
The home/anchor pair is the worklist identity; discovered local code homes
add their external uses transitively while their NODE anchor remains inside
the existing selected source. No runtime object or namespace scan is added.

Permanent fixtures and native/method-walked rows:

- `unit_merge_parent_t7_local_only_get`: only S reaches get;
- `unit_merge_parent_t7_local_only_nested_get`: IF → S → T → middle → get;
- `unit_merge_parent_t7_local_node_view`: NODE seed plus the external get,
  the existing projected-parent coordinate debt, kept as a required positive.

`build/l2_harness/codex_t7_focus_03`: 15 targets, 3 failures. Four new
dependency rows and all four earlier local rows are green, including the
same artifact with its physical root walked. `local_node_view_walk` passes;
native `local_node_view` remains red (12 rather than 13). Both part rows
remain refused. The stronger NODE test has NOT been changed to expect 12.
Native-word assertions distinguish full-native, methods-walked, and the
required native factory-host entry; an ordinary green exit is not mode proof.
Here "native" identifies the checked original methods and the local S/T
implementations. It does not prove a native entry on the newly constructed
T7 root: `l2_t7_emit_make` creates that root without assigning its native word,
and only the retained local definitions receive native entries in
`l2_view_build_0`. The historical `callable-merge-t7.md` explicitly recorded
zero native there; the current composition norm supersedes that blanket
policy. Native reuse on an unchanged composed root remains an acceptance debt
with the full-interface/default-input work; these tests must not certify it.

Full-corpus replay against the first native-reader slice is byte-identical
(2615 translations). Kernel `build/l2src/codex_kernel_02` GREEN297,
114 selftests ran. L3 `codex_l3_03`: all 11 suites and four type budgets green.
Full `codex_full_02`: RED68/2624. Against full01: no FAIL→OK or OK→FAIL,
six rows added (five green, the native local_node_view required positive red),
none removed, no remaining red message changed. All frozen source/harness and
then-current fixture bytes were unchanged through that gate. The full02
translator blob is `6cc8106c` and its built binary SHA256 display prefix is
`3E6954EAAF17C78A` (full identity retained in the artifact).
Frozen harness SHA256 is
`7B4CA218FDCAA27A4E4E73A1139CB3EBDEDEAC895BD6CD61749FB7983D467752`.

The subsequent fixture-only migration changes exactly one merge operand order
in each of the four inputs named above; translator and harness bytes are
unchanged. Fresh `codex_t7_focus_04` is the final-input acceptance run, not a
second full gate: 15 targets, the same three failures (native local_node_view
and both part rows). Its twelve fixture verdicts and red messages are identical
to focus03; all eight rows affected by the four input migrations are covered.
Do not claim full02 ran the later spellings: its saved inputs
and hashes precede that migration. Each of the eight affected native/walked
rows is explicitly selected in focus04 alongside the older local_call and
part controls. This distinguishes complete compiler regression from the
bounded recheck of the changed independent test programs.

Final fixture SHA256 (all unchanged through focus04):

| Fixture suffix after `unit_merge_parent_t7_` | SHA256 |
| --- | --- |
| `local_control.lm2` | `C614166BB6A559A5DB72E47BD0C7E1FE03A53E5666B87F451B56CC76C19ADA09` |
| `local_only_get.lm2` | `348722AE552AD577C8A2E978DC3EC7C1B1C82FC584670FAF8B37877C241E8F24` |
| `local_only_nested_get.lm2` | `B11B1168BAE9128C77BB8DEEC302035D004DDEDFD1C117A62710C106C9D6E60A` |
| `local_node_view.lm2` | `EA651F84215A0BBE8E5D76CD1A69835216227B9C32969EA5BC4569D694669949` |

This completes the missing retained-local dependency child, not T7 as a whole.
Next is the model-slot-preserving producer correction described above; no
author decision is missing. Keep part visibility, receiving/fallback policy,
unrecorded use families and the full-interface/native-reuse debts explicit.

Infrastructure attempts, not language failures: `codex_t7_focus_02` used a
relative output path which the harness resolved again after changing cwd;
it did not build the translator. The fresh focus03 uses an absolute path.
The first L3 invocation (`codex_l3_02.log`) ran no suite because the kernel
script left the caller in its staged source directory. The recovery invokes
tools by absolute path, checks completed kernel02, and uses fresh L3_03.
Neither failed invocation counts as a gate or overwrites earlier evidence.

## Acceptance commands

Run a fresh harness directory with explicit `bin/l1trans.exe`, `-KeepAll`,
`-OnlyFixture` selecting local_call/local_control/part pairs and all added
controls. Replay every full65 translation with baseline and changed binaries;
classify every changed exit, diagnostic and generated L1 (fault environment
omissions kept separate). Run the complete kernel, L3 and full harness gates
serially on the final frozen source bytes. No concurrent compiler owner.

From `C:\Nyasha_Planet\LMX`, choose a fresh output directory for each run;
the following names document the first native-reader checkpoint, not an
instruction to overwrite its saved evidence:

```powershell
tools/l2_harness.ps1 -KeepAll -Translator C:\Nyasha_Planet\LMX\bin\l1trans.exe -OutDir C:\Nyasha_Planet\LMX\build\l2_harness\codex_t7_focus_01 -OnlyFixture unit_merge_parent_t7_local_call,unit_merge_parent_t7_local_call_walk,unit_merge_parent_t7_local_control,unit_merge_parent_t7_local_control_walk,unit_merge_parent_t7_part,unit_merge_parent_t7_part_walk
Set-Location C:\Nyasha_Planet\LMX
tools/build_l2src.ps1 -Run -KeepAll -OutDir C:\Nyasha_Planet\LMX\build\l2src\codex_kernel_01
Set-Location C:\Nyasha_Planet\LMX
python tools/run_l3_selftest.py --output C:\Nyasha_Planet\LMX\build\l3_selftest\codex_l3_01
Set-Location C:\Nyasha_Planet\LMX
tools/l2_harness.ps1 -KeepAll -Translator C:\Nyasha_Planet\LMX\bin\l1trans.exe -OutDir C:\Nyasha_Planet\LMX\build\l2_harness\codex_full_01
Set-Location C:\Nyasha_Planet\LMX
python tools/check_docs.py
git diff --check
```

`python tools/check_docs.py` and `git diff --check` are mandatory. Commit only
exact reviewed paths; compare staged/live/gated hashes, push, verify upstream.
RED development checkpoints must retain their failed rows; no stable promotion.

Any consultant request goes through existing `lmx_uds` with its own request ID
and a full correlated `codex_inbound.py send --sender opus --request-id …`
return route. Opus remains Q&A only; a relay receipt is not a consultant result.
