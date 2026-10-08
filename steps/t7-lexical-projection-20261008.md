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
   must use the selected parent view's coordinates, not a prototype offset.
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

## Required closure control (OPEN, found during the full gate)

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

Exact pending positive, retained here so the ignored diagnostic is not its
only copy (normal `convert.lm2 primitive.lm2` harness inputs):

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

Next bounded closure implementation: extend the existing merge-home worklist
with its anchor selector, rather than copying use records into another home.
Enumerate each reached home's retained local definitions through the original
source containers/definition fields (including definitions inside control
bodies), then enqueue their body procedures with the existing internal-node
selector `-1`. Their unit uses still close over unit methods; their NODE uses
are inside the selected source view, not unit-relative paths. Deduplicate the
home/selector pair and preserve the monotone fixed point. This reuses the same
closure for ordinary and callable merge; no depth bound, namespace-name scan,
runtime home registry, or whole-unit retention. Before accepting the change,
measure the local-only witness in native/root-walk/method-walk modes, add nested
local/control and transitive unit-call controls, and check local NODE paths do
not accidentally retain a prototype owner. A diagnostic draft now exists only
under `build/l2_harness/codex_t7_closure_stage_01`; live translator/harness bytes
remain frozen and unchanged. The draft is separately built and probed, not
accepted into live source or covered by a full regression gate.
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

Use the shared source/view address relation for native field readers and
native implementation binding. Do not patch an offset by capture count, use
runtime names, introduce a hidden graph, or turn off a required native body
to make a witness green. Register the native and walked positives; keep this
child in the parent acceptance checklist before declaring T7 closed.

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
tools/l2_harness.ps1 -KeepAll -Translator C:\Nyasha_Planet\LMX\bin\l1trans.exe -OutDir build/l2_harness/codex_t7_focus_01 -OnlyFixture unit_merge_parent_t7_local_call,unit_merge_parent_t7_local_call_walk,unit_merge_parent_t7_local_control,unit_merge_parent_t7_local_control_walk,unit_merge_parent_t7_part,unit_merge_parent_t7_part_walk
tools/build_l2src.ps1 -Run -KeepAll -OutDir build/l2src/codex_kernel_01
python tools/run_l3_selftest.py --output build/l3_selftest/codex_l3_01
tools/l2_harness.ps1 -KeepAll -Translator C:\Nyasha_Planet\LMX\bin\l1trans.exe -OutDir build/l2_harness/codex_full_01
python tools/check_docs.py
git diff --check
```

`python tools/check_docs.py` and `git diff --check` are mandatory. Commit only
exact reviewed paths; compare staged/live/gated hashes, push, verify upstream.
RED development checkpoints must retain their failed rows; no stable promotion.

Any consultant request goes through existing `lmx_uds` with its own request ID
and a full correlated `codex_inbound.py send --sender opus --request-id …`
return route. Opus remains Q&A only; a relay receipt is not a consultant result.
