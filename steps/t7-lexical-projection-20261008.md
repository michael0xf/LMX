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

## Child 3: preserve model source slots (full regression measured)

Candidate translator blob `e471c941f50ad8412351fb1cca44f9c51a5c350b`, SHA256
`B07970E8EF3CCF21C71CA50BDAF468B3739CD01416D735AC1BBA3AE8551EA32C`.
T7 COUNT and PLACE/FILL now use `l2_m_head(model)` as the body base. COUNT
measures the complete body/trailer before finalizing appended datum coordinates
to `head + steps + j`; the root allocation and source width include all data.
Earlier datum-slot consumers need only a nonnegative marker until FILL, as the
read-only pass-order audit recorded above. Overflow is diagnosed before the
final sum is committed. There is no reader offset, native specialization,
runtime coordinate table or new graph object.

`codex_t7_focus_05`: 15 targets, only the two existing part refusals fail.
The required native local_node_view now returns 13, as its walked twin does;
the expected value and native assertions were not weakened. The first wider
`codex_t7_family_01` has 85 targets / 5 failures: those two part refusals, the
pre-existing host_nested_return refusal, and the two local_definition shape
observers that pinned the old, defective layout. Their arithmetic still
returns the required entry result; their post-path comparison fails.

The local_definition oracle is explicitly migrated under the existing
`#composition` norm: the model's S stays at slot 2, its call at 3 and return at
4; the added y datum is at 5, not before S. Both result roots have width 6.
The old oracle pinned S at 3 and y at 2. The original model coordinates,
identity/parent checks, source-name observer and native-word checks remain;
two root-width assertions are added. Family01 preserves the negative evidence
that the old coordinates do not pass against this producer (11 post-path
failures in the native half). The historical data-first fixture input is NOT
silently migrated or declared normative by this observer correction.

New model-first positives, each with native/methods-walked and physical
root-walk checks:

- `unit_merge_parent_t7_local_node_defaults`: two own fields, two appended
  defaults, S's direct NODE paths and a get reachable only through S; two
  copies and reuse of the first after mutating the original, expected
  35 / 321 / 35, original 28;
- `unit_t7_trailer_only_two_defaults`: a trailer-only model with two appended
  defaults, two independent copies and later mutation of the original,
  expected 14 / 59 / 14, original 16.

`codex_t7_focus_06`: GREEN11. Final-input `codex_t7_family_02`: 89 targets,
exactly the three existing refusals above, no local_definition failure.
Final harness SHA256
`DD23962514561BFAF22BAF8B8AA9BCB764F8F46D130BF889936E7AC7A57C3CCD`;
new fixture hashes respectively
`6F6744D61BD9DA2F657FDA5F32E7411053E1B759F6DE98F17D4B1F62101336DE`
and `0AC088B41AC4C86B458631848E02E2E127DAA67E9F96689D284EA698AAE9193C`.

Final serial frozen-byte gates: kernel03 GREEN297 with 114 actually run
selftests; L3_04 all 11 suites and four budgets GREEN; full03 RED67/2628.
Against full02: one FAIL→OK (native local_node_view), zero OK→FAIL, four
new fixture rows all green, zero removed rows and no changed messages on
remaining red rows. Full03 also runs the four final model-first input
spellings migrated after full02. Source, harness and fixture fingerprints
stayed unchanged through every gate; the staged full03 translator and new
fixtures match the live bytes. The bounded producer defect is fixed; this
does not close T7-LOCAL-NAMED-UNIT, T7-DATA-FIRST-SHAPE, the full-formal/default
contract or native reuse on the constructed T7 root. Part identity/lexical
fallback and receiving-boundary projection remain the next dependencies.
Codex remains the sole writer/build; Opus's read-only consultations follow.

Full65's 2615 recorded translation commands were replayed serially with the
full03 executable into `build/codex_handoff/t7_layout_replay_01`: 827 nonzero
translation exits, exactly as `t7_closure_replay_01`. Comparing those replays
finds no exit/diagnostic, row-presence or generated-L1-presence change.
2571 outputs are byte-identical; 44 have only numeric graph coordinates
changed (181 graph-ref slots and 90 AT coordinates), consistent with
preserved model positions / appended data. Every changed line is classified
by `build/codex_handoff/tools/classify_t7_layout_replay.py`; no unclassified
edits remain. This replay is diagnostic evidence, not a replacement for
the executed full03 gate.

### Read-only follow-up: part identity and fallback

Opus returned correlated RESULT for
`CODEX-T7-PART-PROJECTION-20261008-08` on `e471c941`; no writes/builds.
The local procedure row is registered after E and outside the part's original
method range. `l2_m_part(S)` and then `l2_m_file(S)` both return -1, although
its source owner model belongs to the part. `l2_own_unit_seen` cannot see the
part root's cnt; `l2_vis_method` can instead compare offsets across two files.
That latter false-visibility possibility is inferred from source and still
needs its own witness, not a claim of a measured program result.

The next pre-PLACE projection must walk the existing source ownership:
namespace parent before namespace local host (all nested entries share the
latter stamp), then nested-method host, part root, unit. File membership and
the visibility point come from where that chain enters its source unit. After
PLACE, native pointer distances use the existing actual construction links;
do not count control scopes or invent runtime lookup. Keep the two halves
coherent, including a local Structure inside another local Structure.

Necessary next dependency chain, to be gated on fresh bytes after full03:

1. Chain-aware code-origin projection / `l2_own_unit_seen` and source-position visibility;
   test a part's local/nested-local body, forward-only declarations and a
   main-file same-name declaration so cross-file offsets cannot grant scope.
2. Self-resolved numeric fallback: `l2_hid_own_lex` must identify the root
   declaration on that chain; native `l2_emit_tramp_lex` must project from
   the selected self to that owner. Preserve caller-source precedence,
   present zero, and absence distinct from zero. The walked ARG fallback
   already uses form-9 retained uses; `l2_t7_emit_frames` rebinds l2_nsp aliases
   through its actual copied l2_entry_unit. Do not describe those aliases as
   necessarily global or add a second walker mechanism without evidence.
3. T7's result must occupy the model's position under the corresponding
   copied parent, including a part root. `l2_t7_emit_make` currently rejects
   that model and attaches only under the copied unit. Retain the required
   ancestor link even when no field of that ancestor is read; no part-name
   branch or unrelated source-parent change. Keep the distinct
   T7-MODEL-OPERAND-SOURCE debt explicit: copying l2_program_unit unconditionally
   does not prove selection of a model from an already copied occurrence.
4. Receiving-boundary projection remains a separate dependent child; its
   class policy must be stable before PLACE. This part witness admits no
   Structure formal and cannot certify that boundary.

The walkable-body checks after typing, view/prototype physical-path parity for
the part and nested-local ownership ordering need executable witnesses. The
consultation's recommendations are not test results.

Codex's additional reader audit found a classification dependency at
`l2_make_entry`'s unit-field collision check: its old predicate
`m_file(owner) >= 0 && m_part(owner) < 0` identified a part-root procedure only
while m_file did not follow local ownership. After that projection is repaired,
it also matches a local S. Keep the predicate about the actual root owner
(`ns_part(m_nsof(owner)) >= 0`), not about every field whose code originates in
the part. Otherwise an origin fix would incorrectly reject local declarations
under names of program methods. This is a source-derived risk, not a measured
regression; read-only follow-up `CODEX-T7-PART-OWNER-20261008-09` asks Opus to
check the remaining classification consumers and an ordinary, non-T7 witness.

Correlated RESULT09 confirms that risk and corrects RESULT08's earlier claim
that owner-side readers would be unaffected by broadening m_file. Final bounded
design: keep `l2_m_file` / `l2_m_part` as their existing row/owner classifications;
introduce a translation-only code-origin projection over the existing namespace
parent/local-host and nested-method-host identities. Give it only to code-side
visibility (`l2_vis_method`, `l2_own_unit_seen`, `l2_rw_seen`) and source
diagnostics (`l2_method_src`). Thus the root-owner
collision predicate above needs no compensating change. Physical `node` and
native lexical distances remain the committed PLACE relation, not this origin
classification.

Codex checked the complete `l2_node_seg_resolve` caller and excludes
`l2_e_own_seg_mi` from RESULT09's suggested substitutions: it resolves the
physical parent behind NODE after the local/nested-host branches have run.
A part-root procedure's code comes from the part, but its parent is the unit,
not that part root itself. Replacing its direct m_part classification with
code-file membership would conflate those two facts. Preserve this reader's
physical-parent meaning; no executable counterexample authorizes changing it.

The first isolated positive must have a part-root cnt=7 and ordinary model's
local S reading cnt, with no merge at all: an absent input yields 7, a caller's
own cnt=40 yields 40, and its supplied cnt=0 yields 0. A separate forward-only
control moves the part declaration after model: the absent call must be
refused, while caller-supplied 40/0 remain valid. Native and walked variants
will measure those requirements; RESULT09 supplies source evidence only.

Codex's later copy-reader audit adds a guard for the follow-up parent-retention
implementation: `lmx_copy_use` copies the final path value whole. A one-slot
use of the part-root field therefore is NOT a link-only retention request;
it would upgrade that root to a whole copy. The existing
`lmx_graph_copy_part_used_owned` instead seeds its source root in part, and
`lmx_copy_link` retains its ancestors/backlinks without their unrelated fields.
Investigate selecting the actual model's lexical parent as that partial root,
then deriving the copied unit for view construction through its ordinary parent
chain. Select the model's source occurrence before copying, not the merge site's
parent and not an unconditional program-global prototype. The constructor
already receives the performing occurrence as `l2_t7_at`; tracing its use and
the model operand's retained address is still required. This is source-derived
design work, not a tested correction or closure of T7-MODEL-OPERAND-SOURCE.

### Adjacent A3 constructor audit (no fix claimed)

`l2_mad_emit` uses the model's complete `l2_m_width(model)` and copies each
model field to the same index; no matching T7 capture-prefix shift was found
there by source reading. `l2_madc_slot` keeps a captured host own-field slot
or appends a captured host formal after the host width. That is not proof of
the general returned-node copy contract: the existing
[RETURNED-NODE-PARTIAL-COPY](defects.md#returned-node-partial-copy) records
shared ordinary signature/body material and missing complete remapping.
Native reuse and complete used lexical-tree copying for this constructor stay
OPEN; the current T7 producer correction must not close them implicitly.

## Child 4: source identity and numeric absent fallback (gated checkpoint)

After pushed checkpoint `90bcf0dc`, translator candidate `bca1af00`, SHA256
`A7B2491656EB478CBAAC34A223FDC6FA3342B796BA144DF551185297EC3CAEAB`, adds a
translation-only `l2_m_code_file` over existing namespace parent/local-host and
nested-method-host identities. `l2_m_file`, `l2_m_part` and the physical
`l2_e_own_seg_mi` stay unchanged. Visibility and source diagnostics use the
code-origin projection; part-root own fields compare against the original
callable source node, including a local named Structure without a fn header.
An own field of the same method is not a unit/free field of that method.

`l2_hid_own_lex` now admits the already visible numeric lexical source without
a unit-level restriction. Native absent-input emission follows the committed
physical `l2_lex_depth` to that owner, written incrementally without a fixed
text buffer. Present refs, including a present zero, retain precedence.

Before/after diagnostics in `build/codex_handoff/t7_part_origin_*` show:

- ordinary no-merge model calls with absent / caller 40 / caller zero return
  7 / 40 / 0 both before and after, native and walked. The model itself can
  supply the local body's input, so these are regression controls, NOT proof
  that the local body's absent branch executed;
- the two-level local body after the change has the same required results;
- a late part-root declaration cannot supply the absent model call; the
  explicit 40/0-only program succeeds. Main-file offsets do not grant scope;
- directly calling `model\S` from outside its host goes from the baseline's
  unresolved cnt to a separate not-built Structure-value path refusal. The
  existing T7 part fixture similarly advances to poke's separate walkability
  refusal. Neither required-positive row is declared fixed.

Correlated read-only RESULT `CODEX-T7-PART-WITNESS-20261008-10` confirms that
`l2_dyn_reads` delegates to `l2_node_of_text`, recursively searching nested
definitions. Thus this ordinary model is classified as a reader itself; it
resolves its input before calling S. No already-supported source witness was
found which isolates S's absent branch: the external `model\S` call and the
T7 part producer hit the distinct debts above. Do not change that classification
just to manufacture coverage or call the unexercised native branch proven.
There is no new language decision, runtime name mechanism or test-only dispatch.

Ten new native/walked controls cover source ownership, nested namespace
identity, caller 40/zero, forward-only declaration and cross-file offsets.
`codex_t7_family_03`: 99 targets, three failures; against family02, no old
verdict or recorded message changes, ten added rows all GREEN, none removed.
The failures are the historical part pair and host_nested_return. The part
pair's actual translator diagnostic advanced even though its generic harness
message (no emitted L1) did not; retain both facts.

Serial replay `build/codex_handoff/t7_origin_replay_01` covers the same 2615
full65 translation commands (827 expected/nonzero exits). Against
`t7_layout_replay_01`, there are no exit or L1-presence changes: 23 emitted L1
files differ, and the two part diagnostics advance from unresolved cnt to the
root operation's walkability refusal. Source/diff inspection of all 23 L1
changes classifies them as:

- `unit_absent_input_parts` and its walked twin: absence forwarded to the
  actual part reader, native entry fallback and walked ARG's AT moved there;
- four `unit_copy_call_chain_inputs` variants (base, source/target mutants,
  walked): retained root field x's slot 3 added to the existing use closure,
  its walked PRIM use payload enlarged by four, one SELF and one AT, and the
  local native entry uses two parent links;
- three held-actual variants (alike/free_names/local): no own-field-as-free
  fallback in the forwarding wrapper, one redundant AT removed;
- caller/formal/local_proc T7 pairs: numeric absent branches through two
  parent links and the corresponding two walked AT fallbacks;
- s7 part callable_field, root_below_definition, root_field (including
  unit_walk_s7_part_root_field), root_two, site_part_repeat, and used_closure
  part_lex pair: part-reader entry resolution, caller refs/absence forwarded
  unchanged, corresponding ARG/AT placement. callable_field also changes
  builder emission order/temporary numbering; its original frame/operator
  populations remain except the one added fallback AT.

The ignored `inspect_origin_replay.py` removes temporary numbers only to make
manual inspection readable; that normalization is not an equivalence proof or
a runtime gate. The complete frozen-byte harness supplies the executable
regression check. Kernel04 is GREEN297 with 114 actually executed selftests;
L3_05 has all 11 suites and four type budgets GREEN. Full04 completed on the
same frozen translator, harness and seven input files: RED67/2638. Against
full03: FAIL→OK 0, OK→FAIL 0, ten added GREEN rows, none removed, no changed
generic harness messages on remaining failures. The part pair's actual
diagnostics advance as classified above; both required positives remain RED.
The wrapper confirms unchanged input bytes through all three serial gates.
T7 remains OPEN; this checkpoint does not promote the stable tree.

After full04 released the sole compiler, six wrong-expected-value programs
were built serially with that same translator. Ordinary/nested part controls
demand 8 instead of their correct 7; supplied-only controls demand 41 instead
of 40. Native and methods-walked builds each return 81 and fail the driver's
expected 7. Running each binary again with only the root native word cleared
does the same: twelve negative executions, all detected. Evidence:
`build/codex_handoff/origin_negative_01_*`, runner
`build/codex_handoff/tools/run_origin_negative_01.ps1`. These witness actual
execution and non-vacuous oracles, not coverage of S's absent-input branch.

RESULT10 also flags a possible source/span pairing debt in error reporting:
`l2_method_src(m)` and `l2_free_name_at(m,k)` are separate projections. Codex
checked that the latter follows the original P0 text's address/length through
`l2_source_text`, not arbitrary equal spelling. A forwarded input may still
originate in another file; any correction needs that exact owner/source pair
and a located witness, not a runtime names table or an unproved first-name
search. No diagnostic-location fix is claimed by this slice.

### Next bounded source-parent dependency (source audit, not implemented)

Read-only RESULT `CODEX-T7-MODEL-PARENT-20261008-11` identifies the existing
route: constructor input `l2_t7_at`, completed host-to-unit `l2_lex_depth`,
the model's selected occurrence at `l2_occ_slot`, then its actual parent.
The copier accepts a source parent as its partial seed and independently
accepts unit-anchored paths; link fixup retains intermediate ancestors without
copying their complete fields. A use ending at the model or a part root would
copy that object whole, so no such synthetic use is justified just to find
the seed. The copied parent, not the merge site, must parent the constructed
node; the view also needs that copy's entry unit, not the seed mislabeled as
a unit. Admission-model operand selection remains its separate OPEN debt.
This is a source-level recommendation, not a measured positive or permission
to assume every selected model is present in an already partial-copied host.
That case needs its own producer/use-closure evidence.

Before changing the constructor, isolate the historical root `poke(5)` /
`poke(11)` refusal: source reading finds `l2_unit_names_method` scanning only
the current root before part methods are registered. The first part-defined
call may therefore be classified as a named Structure. This hypothesis is
not measured yet. Request `CODEX-PART-HEAD-CENSUS-20261008-12` asks existing
Opus for read-only scope/caller review, not coding. Ignored diagnostic sources
are prepared in `build/codex_handoff/t7_part_next_sources_01`; execute only
after full04 releases the sole compiler owner. New T7 diagnostics use the
model-first spelling to isolate this dependency; historical data-first
required-positive rows are not silently migrated or reclassified as refusals.

Post-gate measurements on the same `bca1af00` binary confirm the classifier
defect (`part_next_before_01_*`, `part_next_before_02_poke_value`): a single
root `poke(5)` calls nothing and a following part method reads the unchanged
7 instead of 5; with two calls the second is refused as `this declaration`
at line 2. Native and methods-walked first-call controls both fail. The
separate model-first factory, with its ordinary indented return, reaches
`internal: a callable merge's model is not a method of the unit`
(`part_next_before_02_model_parent`). These are distinct producer debts,
not conflicting language rules. Fix the shared pre-registration method census
first, preserving the forward-only scope of ordinary named Structures.
The factory's initial trailer-only host spelling hit the separate nested-body
diagnostic; no parser/host interpretation is inferred from that alone and
that spelling is not used to certify the model-parent slice.

### Fifth child: common pre-registration method census

Candidate `09e69997` (SHA256
`F7A99A239896132F506BEFF2541655D76B3FD2CBFDAAAC366D1E0E391663D04E`)
factors the currently implemented root-method producer predicate out of
`l2_unit_role`. `l2_unit_names_method` applies the same root-only census to
the current root, main source and already parsed part roots before COUNT/FILL
classifies applications. It collects no signatures, descends into no method
or ordinary named Structure, and adds no runtime table/state. `fm` remains an
unimplemented producer; recognizing only its name early would not implement
it. The declared fn/fm/sub language rule is unchanged. Per-file declaration,
ordinary-Structure and value visibility readers are unchanged.

`codex_part_census_stage_04`: 23 targets, only the two historical T7 part
positives remain RED. Ten added rows are GREEN: repeated part-root sub/fn
applications, an earlier part calling a later part, main-method-body calls
and non-export of a nested method name. Every executable row also clears
the physical root's native word and reruns that same artifact. Walk rows
assert the actual generated method IDs/absence of native words, with the
root's native implementation separately asserted. Stage03's four extra
failures were erroneous test IDs (the part roots are also walked); the final
rows correct those assertions, not program results. Stage02 never built
because an explicit relative L1-tool path stopped resolving after staging;
stage04 uses the absolute tool path and is the acceptance evidence.

Baseline `bca1af00` against the same new inputs:
`census_baseline_negative_02.log` records six sub/fn/cross-part refusals;
method-body and nested-name pairs already pass and are controls, not six
additional fixes. Eight deliberately wrong-oracle executions fail with 81
instead of 7 (two programs, native/methods-walked, normal/cleared root),
including the assertion that the relay part's dormant `poke(13)` must not run.
The historical T7 pair now reaches
`internal: a callable merge's model is not a method of the unit`, not the
root `poke` declaration refusal. Its positive requirement remains RED.

Read-only consultation `CODEX-PART-HEAD-CENSUS-20261008-12` agrees that this
aligns classification with the existing program-wide root-method binder;
it does not add backward visibility to ordinary named Structures. OS-branch
method census, host-local nested-method pre-registration and the existing
blind registered-method check in `l2_ns_body_stmt` are separate audit leads,
not measured fixes in this slice. Request
`CODEX-T7-MODEL-CLOSURE-20261008-13` asks only for read-only evidence about
retaining the selected model in an already partially copied host; no writer
or build ownership is delegated.

Opus's substantive RESULT13 arrived through the named return route. Its
source analysis confirms that the current T7 BUILD takes SELF, not its model,
and records no model dependency for the host's retained-use closure. The
existing MAD producer instead passes a real model occurrence and records
`l2_use_unit_child(1, model)`. That is the proposed common route for T7 too:
consume the model value, seed the partial lexical copy with that occurrence's
actual parent, anchor uses at its actual source unit, and hand the copied unit
to the view. Consuming the model whole is ordinary value-copy semantics, not
a synthetic whole-unit retention edge. Parent-link closure retains the
containing path without retaining unrelated ancestor fields.

This is source evidence, not a successful runtime probe. Main/part methods
with existing unit aliases and activation-local model producers must be
distinguished by construction metadata, not by a language depth limit or
fallback to the global prototype. Request
`CODEX-T7-MODEL-PRODUCER-20261008-14` asks Opus only to check that readiness
predicate. After this child's frozen gate/replay and checkpoint, measure the
part-parent snapshot, independent copies, caller zero, NODE and a copied
factory which performs another merge. Also measure dirty-value publication
immediately before graph copying (T7 currently uses PRIM, MAD uses PRIM_PUB)
and retained-merge loop cost. No test outcome or implementation is claimed
for these prepared probes; full-formal/default/native-composed-root and
receiving/admission-model debts remain separate and OPEN.

Final serial acceptance, `run_t7_gates_06.ps1` / `t7_gates_06.log`:
kernel05 GREEN297/114 actually run selftests; L3_06 all 11 suites/four
budgets; full05 RED67/2648. Against full04: no old verdict changes,
ten added GREEN rows, no removed rows or changed generic failure messages.
The harness has 2646 fixture rows plus its two build targets.

All 2615 full65 translation commands replayed serially with the final
full05 binary into `t7_part_census_replay_02`, compared against
`t7_origin_replay_01`: 2613 byte-identical results; only the two historical
T7 part failures change their actual diagnostic (poke declaration at 9:1
to model-of-unit at merge 11:13). No exit/output-presence or generated-L1
differences. The replay has 827 nonzero exits; it omits recorded fault
environments and is diagnostic evidence, not another execution gate.
The runner confirms translator/harness/eight fixture identities unchanged
through kernel, L3, full and replay. Harness SHA256:
`0002AE28411A91EC5F8B516EA4C8FED33046DA95497D80B7FCDBCDA0E141B552`.
Docs/whitespace checks pass. This closes only PART-CALL-HEAD-DECLARED,
not T7 or §§8/8a; no stable-tree promotion.

RESULT14 (read-only source evidence, no execution) confirms the existing
allocation/reparent predicates can distinguish main/part method aliases
from hosted models without a language depth limit, but identifies a prior
producer defect: `l2_mad_take_nested` assigns the host to `l2_m_n - 1` after
collection can have appended more method/descriptor rows, or none for a
bound declaration. The declaration's row is the first newly published row,
not necessarily the last. The proposed next probe must first measure that
misownership, fix the producer if reachable, and keep the nested-declaration
binding/scope question separate. No outcome of those source-only witnesses
is asserted here. Opus remains Q&A only, Codex the sole writer/build.

### Sixth child: selected model operand and actual lexical source (gated checkpoint)

Checkpoint `503ad610` published the fifth child's exact fourteen paths; remote
main was verified at `503ad6105a9f3941149d13d17ef47fd25f85e86b`.
The next candidate is translator blob
`8341e6ba98f6c690ad2a80ca194d8d0bac5fc4bc`, SHA256
`6F3C8E37169C7864359D0C326CCFB4A9F0E6E6AC037E96B05591B3FC1B1845AB`.
It implements the measured owner correction and the real-model route of
RESULT13/14, without changing language rules or kernel representation.

- `l2_mad_take_nested` retains the first newly published declaration row,
  verifies its source identity, and assigns no host when no row was
  published. The old full05 binary refuses the nested helper/in-place
  callable-formal probe with `the unit's statements changed between the
  lexical pass's walks`; the owner-only candidate in `codex_owner_stage_01`
  executes it successfully. The bound-root-declaration probe stops earlier
  with `duplicate definition`, so the hypothesized self-parent case is not
  certified reachable or fixed by that witness.
- T7 BUILD passes the real model occurrence, not SELF, and records its
  existing unit-child use in the performing home's dependency closure.
  A copying host therefore retains the model value and the model's code
  requirements by the ordinary fixed-point copier. No new runtime table,
  name lookup, auxiliary graph or synthetic whole-unit edge is added.
- Native and walked construction use the same model argument. Its actual
  parent seeds the partial copy; the completed lexical depth locates its
  source unit for use anchors. The result's parent is the copied model
  parent, while the view receives the corresponding copied unit. Chains
  are emitted incrementally, with no fixed depth or text buffer. A hosted
  or namespace model without this selection producer stays an explicit
  implementation debt, not an arbitrary prototype alias or a new ban.
- Copying is a publication boundary: native construction publishes pending
  writes, and its walked producer uses the existing PRIM_PUB path, as MAD
  already does. The added native publication control already passed on
  full05; it is not claimed as another measured fix.

Baseline `parent_operand_before_01.log`: six main/part snapshot, two-copy
and NODE rows stop at the old model-of-unit guard; the native nested
factory also stops there. Walked nested/publication forms stop at the
existing callable-formal subset refusal. Final source probes in
`parent_operand_after_01.log` pass the six part rows and native nested
factory/publication control. The nested factory keeps cnt=7, changes the
original to 100, then returns 13, not live-source 106. The two-copy row
keeps 5 and 11 after the original becomes 19; an explicit caller zero wins.

Final-input focus `codex_model_source_stage_04`: 91 targets, four failures
only -- historical `unit_t7_host_nested_return`, and three newly registered
required-positive methods-walked rows (nested factory, publication,
owner-formal). The historical T7 part pair now passes without changing
its input or result oracle, including its data-first spelling; this does
not establish general data-first layout semantics. All nine other new
rows pass, each rerunning its actual graph with the physical root's native
word cleared; native/walked method IDs and the native root are asserted
where supported. The owner row's E is 5, not 4 (4 is the dormant named
helper); this test-ID correction changes no source or expected result.
Stage03 retained that erroneous ID; stage02 also retained two old textual
expectations for SELF. Those expectations now require the actual model
argument; the no-native-call assertion for an always-walked definition is
strengthened to reject any native constructor call, not only SELF text.
Stage01 failed selection validation (`unit_t7` was not a fixture stem);
its built binary was used only for diagnostics, not as a focused certificate.

`source_negatives_02.log`: eighteen wrong-value executions (nine compiled
programs, normal and cleared-root) all reach 81 instead of expected 7 and
fail the driver. They cover caller-zero priority, independent snapshots,
NODE, live-source 106, nested-owner result and publication. The first
batch stopped on an empty Parts parameter in the diagnostic helper; its
earlier results are preserved, not substituted for the completed batch.

Ordinary 200-merge loop, ten launches per mode: full05 native/walked
13133/13187 ms, candidate native/walked 13239/13175 ms. These include process
startup and driver launch/cleanup, are not isolated merge timings and show
no material change in that control. The distinct repeated inner merge in
an already copied factory passed ten launches of 200 calls, totaling
390593 ms including process startup and driver launch/cleanup
(`source_nested_bench_01/timed_1.log` through `timed_10.log`). This is a
separate performance investigation, with no attributed cause or proposed
semantic workaround. Do not infer a comparable old regression: the old
binary refuses that part-model program before execution.
Source inspection identifies work worth measuring, not an attributed cause:
`lmx_copy_carry_records` takes two passes over the source arena's `impl_len`,
and `lmx_implements_find` scans that table. Measure copied nodes/records and
time by operation before choosing a change. Do not remove carried admission
proofs, revalidate on every read, or add runtime name lookup to optimize this
unattributed observation.

Final harness blob `28d208ac439f0743b744a10360ea8b1224cd3919`, SHA256
`DBA765681A19192CC68F51E058E373727BADAC010AF06876E784F5C8B82F4880`.
Final serial acceptance (`t7_gates_07.log`): kernel06 GREEN297/114 actually
run selftests; L3_07 all eleven suites/four budgets; full06 RED68/2660.
Against full05: two old FAIL→OK (the historical T7 part pair), zero OK→FAIL,
twelve added rows (nine GREEN, three required-positive RED), none removed,
no changed generic message on the remaining old failures. All eleven
translator/harness/fixture inputs stayed unchanged through kernel, L3,
full and the subsequent replay. This is a development checkpoint, not
full stage closure or stable promotion.

Replay `t7_model_source_replay_01` executes all 2615 full65 translation
commands serially, with 825 nonzero exits versus the prior 827. Against
`t7_part_census_replay_02`: 2551 results are identical; 62 generated-L1
files change; the two historical part commands change from refusal/no L1
to success/emitted L1. No other exit, diagnostic or output-presence changes.
Full inspection is saved as `model_source_replay_inspection_01.log` (3561
lines). The 62 edit families are actual-model constructor operands, source
parent/unit chains and use anchors, SELF replaced by the actual model ref
and its existing null guard, PRIM replaced by PRIM_PUB, and the existing
dirty-value publication blocks before native copying. Each PRIM removal
matches one PRIM_PUB addition and one SELF removal; no residual edit family
remains after classifying those lines. Readable alpha-normalization is not
a proof of semantic equivalence. Replay omits injected fault environments
and is diagnostic evidence, not a replacement for executed gates.
Receiving-boundary/global admission-model operands, hosted/value-model
selection, full formal/default preservation and native composed-body reuse
remain OPEN after this limited source-parent repair.

### Next child preparation (source audit, not an implemented correction)

The next receiving/admission child must distinguish the selected callee's
actual unit, its immediate NODE, and the ordinary Structure used as its
requirement. `l2_m_recv_policy` still substitutes `l2_program_unit` for
part/hosted/local contexts; `l2_recv_ref` feeds this policy to native
declared/free input admission, and `l2_rw_recv_req` only emits RECEIVING for
the old `node` class. The shared late projection must use the completed
physical links. Formation classes (`l2_cfl_formal_alike`,
`l2_cfl_recv_alike`) are already consulted before PLACE; replacing their
policy by an unfinished physical depth would not be a sound repair.

The adjacent native-reference fallback in `l2_hidden_from` emits
`lmx_arena_ref_struct(l2_cN\parent, ns_unit_slot)` for a root requirement
without accounting for callee depth; `l2_hidden_lex` still consults
`l2_m_unit_level`. These are source facts, not yet a measured failure or
permission to change which lexical declaration is visible. Numeric absent
fallback, caller-source precedence, and present zero remain the previously
gated contract. Read-only consultation
`CODEX-T7-RECEIVING-PROJECTION-20261008-15` reviews this bounded dependency;
Codex remains the only writer/build owner.

RESULT15 is now received: a source-only review, not execution evidence.
It separates unit-level admission requirements from local/K02c model
occurrences and from explicit NODE reads. The suggested common unit
projection follows the selected occurrence's completed parent chain to E;
the immediate parent is not interchangeable with the unit at depth greater
than one. Early formation classes need a conservative collection-time key
whose equivalence remains valid after PLACE, with a late consistency check;
an unresolved local/hosted producer must not be folded by a guessed depth.
Native admission text must grow rather than truncate in `recv[192]`.
The walked RECEIVING model still encodes only the immediate NODE; a counted
ancestor operand for that existing operation is a proposed kernel dependency,
not a landed feature or an instruction to invent runtime names/metadata.
Ordinary/global model operands and reference-input fallback are distinct
following children. Suggested part-formal witnesses may hit an earlier
part-visibility refusal: measure that before attributing a receiving bug.

The adjacent `l2_cf_set(me, cfp_j[j], l2_m_n - 1)` after recursive inline
callable-descriptor collection is another FIRST/LAST-row source lead.
The ignored nested-inline probe has now executed: it is refused at 6:17,
`more arguments than op has formals`, on the outer actual `value`, both
natively and with --walk-methods. This is a measured required-positive
failure, not a fixed map. Read-only
consultation `CODEX-T7-FORMAL-PRODUCER-20261008-16` reviewed recursive
publication and all five collection callers; substantive RESULT16 and its
name-spelling erratum are received. The source order publishes the own row
before nested methods and inline descriptors. The immediate
`l2_mad_take_nested(l2_m_n - 1, ...)` before any recursive collection is
currently safe sequencing (`me` would state its intent); the later inline
`l2_cf_set` is not. A shared first-published-row/identity check is the
suggested producer contract, not a registry or a change to METHOD contents.
Opus's scan of the old 67 red sources finds no nested inline descriptor
shape, so neither this lead nor the bounded owner correction is claimed
to explain those old failures. Fix and remeasure the shared publication
contract before claiming the map fixed. Opus has no writer/build ownership.

The existing 63-byte checks of method/formal/declared-throw names are already
listed in FIXED-BLOCKS-AUDIT. A synthesized descriptor name adds one formal
component per nested level and reaches the same check. Do not exempt only
synthesized names or leave an arbitrary cap for written names: any follow-up
must audit the shared name producers/readers and external source-name
emission for the whole scope. No runtime name lookup is justified.

RESULT `CODEX-T7-WALKED-CALLABLE-20261008-17` is also received, source-only.
All three new walked failures in full06 are the explicit blanket
`l2_rw_methods_count` refusal, not evidence against the source-parent repair.
The existing source builder already counts/emits callable-formal bodies;
ARG/witness/EXEC transport and one formation class are present, while
`l2_rw_may` excludes every callable formal. Any correction must measure the
existing frames, not merely remove a diagnostic. The same eligibility feeds
`l2_src_eligible` before layout: full source-order/replay comparison is needed
even for native twins. Actual multi-class formation and ordinary callable
results remain distinct OPEN dependencies; a forced-walk test must not
silently claim success by retaining a native address. Extend positive and
stopped/throw controls, and explicitly review old pinned-native/text-refusal
oracles rather than declaring every changed test a regression. No new
registry, graph, runtime-name lookup or source-form exception is proposed.

Ignored post-gate diagnostics (`post_gate_probes_01.log`) under
`build/codex_handoff/t7_part_next_sources_01`: `publication_node_actual`
uses explicit `node\cnt` so a caller's free input cannot mask an old copy;
`receiving_part_main` plus `receiving_part_body` moves the declared-formal
reader into a program part and creates its candidate after the copy, so a
pre-existing admission cannot supply the missing receiving record. They
have now executed serially, after the frozen acceptance chain:

- Explicit NODE publication returns 5 on full05 and the required 16 on
  full06. The expected-16 program goes from refusal-by-driver (81) to
  GREEN, including cleared-root dispatch; the expected-5 control goes
  from GREEN to 81. The initially hypothesized old value 12 was disproved,
  not silently accepted. This measures the combined source/publication
  repair, not isolated PRIM_PUB causality. The methods-walked versions
  still stop at the known callable-formal exclusion. A direct `@:` capture
  stops earlier at an unsupported initializer and proves no publication
  behavior. These are ignored diagnostics, not new full06 rows.
- The declared-formal part reader and RESULT15's free-Structure-input
  variant both pass natively and with --walk-methods, each with normal and
  cleared-root dispatch. The suggested earlier part-visibility refusal was
  not observed. These positives are regression controls, not evidence of
  a receiving bug or of a completed general projection. Inspect the actual
  selected method/requirement reader before choosing a receiving witness.
- The nested-inline callable descriptor refusal above is reproducible
  before any producer correction; it supplies the next bounded map probe.

### Seventh child: callable-formal publication and interpreted call contract (accepted bounded checkpoint)

Sixth-child exact sixteen-path checkpoint `ba3c4632` is pushed; remote main
was verified at `ba3c4632972964f636573bb022c852dab5943b99`. Codex continues as
the sole writer/build owner, Opus remains Q&A only.

The measured nested-inline refusal is repaired at its producer: one
`l2_collected_row` validates the first published source identity, distinguishes
no published row from a broken contract, and serves both inline descriptors
and nested-host assignment. The own row is `me`; recursively appended
descendants never replace it. METHOD contents, signature-only semantics and
descriptor-only addr=0 remain unchanged. Native and walked witnesses at two
and three inline signature levels execute successfully; this does not close
the separately recorded general method/formal name-length cap.

The existing ARG/witness/EXEC route already transports a whole callable
occurrence. The candidate removes only its blanket eligibility exclusion;
COUNT still records actual unsupported machine operations. This immediately
exposed a second producer mismatch: a call through a formal passed the actual
formation's hidden cnt, but `l2_rw_method_contract` described only the exemplar's
explicit zero inputs. The kernel correctly returned INVALID on the mismatched
count; explicit NODE (no free cnt input) already passed. The common
`l2_rw_call_contract` now forms declared inputs/result from the admitted
signature and hidden input witnesses from the selected formation. Ordinary
direct calls use the same method for both. No runtime names, registry,
auxiliary graph or syntax-specific execution route is introduced.

`codex_formal_focus_03` GREEN21: eighteen fixture rows, the two builds and
focused-scope row. The three required-positive walked rows introduced in
full06 now execute, with only E native; the nested factory retains 13 rather
than live-source 106. The strict NODE snapshot is now a permanent positive
in both modes. `unit_callable_formal_free_names_self_walk` executes its
5/40 cases. Two historical `_refused` filenames now require actual interpreted
execution rather than an implementation-limit diagnostic. Three old pinned
native consumer oracles migrate to explicit walked pins, with unchanged
program results. Three measured multi-formation consumers (classes, models,
static) remain pinned native: this child does not implement their dispatcher
or claim those bodies were interpreted.

Earlier attempts are retained, not acceptance certificates: focus01 had
two malformed new three-level source rows, three stale native pins, and two
real hidden-contract INVALID failures. Focus02 did not build because the new
temporary declaration was placed in the wrong function; focus03 corrects
that placement, source syntax and pins and includes the hidden-contract fix.
The separate map-only diagnostic already passed the two-level witness before
the eligibility change.

Broader `codex_formal_family_01`: 219 fixture rows plus two builds and the
scope row, 222 targets / six old failures. Four old FAIL→OK, zero OK→FAIL,
six new GREEN rows. The remaining failures are callable_sub_transport,
callable_forward, callable_nullary_forms, callable_returning_two_contracts,
t7_host_nested_return and callable_formal_unfollowed_actual. This is not
the full gate. Isolated LAST-row, hidden-contract and silent-native mutants
are all rejected; the silent-native mutant still returns the right result
but fails the explicit walked-method pin. Twelve wrong-value executions
(three sources, native/walked, normal/cleared root) give 81 instead of 7
and a failed driver. Production bytes were not mutated.

Focus04 exposed one overstrong new oracle, not a program failure: it asked
for a trampoline of nested helper 1, which is absent even before this child.
Nested helper 1 and returned inner 3 still have no native trampoline; this
old uniform-native debt remains OPEN. Final `codex_formal_focus_05` GREEN21
pins walked 0 and 4 for that fixture, plus the other supported bodies.
The other strengthened pins cover all six walked methods of the nested
factory, the three publication bodies and all four free-name/self bodies;
only their root remains native before the cleared-root rerun.

Frozen candidate: translator blob `e6200afa98e1797fd81f54a2acd9b6f9323f7bc7`,
SHA256 `39122D1CDE1AB761AD5F6A97E3DCC7AB09F13BFFFDE4B03A9A87D00B22CEE819`;
harness blob `2372d2b34898daea2b6e28991897560e7853e61d`,
SHA256 `A8ADBBF8FCC8D5DFB4A2D1EF6CFE3202D4914AB261D3B056BDE6F877BE7E37CB`.
The serial `run_t7_gates_08.ps1` freezes these and five fixture inputs:
kernel07 GREEN297/114 actual selftests and L3_08 exit 0 are complete.
Full07 is RED64/2666 against full06 RED68/2660: four FAIL→OK (the four
walked positives listed above), zero OK→FAIL, six new GREEN rows, none
removed and no changed generic refusal messages. The serial replay of all
2615 full65 translation commands ends with 822 nonzero exits versus 825.
Compared with `t7_model_source_replay_01`, 2576 results are identical and
39 differ: three former walked callable-formal refusals now emit L1 with
exit 0, and 36 successful translations have L1-only changes. The replay
omits per-row injected fault environments and is diagnostic, not an execution
gate. The four full-gate fixes include newer fixtures outside the full65 corpus;
their count therefore differs from the three newly accepted replay commands.

Every changed L1 was inspected in `formal_replay_inspection_01.log` (1592
lines, all diff chunks shown), alongside raw identities where normalization
would hide an edge. The changes are call-contract input extents/witnesses
from selected hidden formations (dormant/free-name/site/reference/held/T7
actual families), reordered activation-local source-container aliases with
unchanged resolved slot chains (graph-shape/address/result/formation families),
and removal of three consumer native words under --walk-methods (reference,
model-subref and callable-actual). Existing operator counts in those 36
translations are unchanged. None is an unexplained new source rule or
runtime name lookup. The three newly emitted walked programs are covered
by actual execution and walked-method pins, not by replay acceptance alone.

All seven source/harness/fixture fingerprints remain unchanged through
kernel, L3, full gate and replay. A separate verifier checks fourteen owned
paths, control bytes and thirteen gated source copies, then requires exact
live/index identity before publication. No stable-tree promotion, concurrent
compiler or unrelated file staging. This is a completed bounded child;
T7, uniform native entry coverage and §§8/8a remain OPEN. The next child
measures the materialized-part receiving projection described below.

Read-only follow-up `CODEX-T7-RECEIVING-WITNESS-20261008-18` is terminal,
with the full reply received through codex_inbound. The earlier receiving
part controls had only fn declarations: `l2_part_root` returns at n=0 and
does not materialize the part's root. They therefore exercise depth one,
where admission and body already use the same copied unit. Adding the
ordinary root field `int: partMarker 0` supplies the missing producer.
Source analysis now distinguishes the old policy's global requirement
from the copied body's actual unit requirement, whose record key is its
address; immediate NODE would instead read the part root, also incorrectly.
The declared/free and two-independent-copy diagnostics are prepared under
`build/codex_handoff/t7_part_next_sources_01`; they have NOT run while the
frozen acceptance chain is active. This is a source-supported lead, not a
measured program failure or a completed receiving fix.

`CODEX-T7-RECEIVING-PHASE-20261008-19` is terminal; its full correlated reply
arrived through codex_inbound. Source analysis finds that current formation
members are method rows or held nodes of method models, not nameless named-
Structure procedure rows. Their host/part-root edges are final before COUNT;
the local-Structure branch of `l2_lex_parent` instead needs PLACE and must
not silently supply a pre-PLACE depth. The proposed common receiving key
therefore follows only completed static method edges, rejects an unavailable
relation rather than falling back, and is validated against physical depth
after PLACE. No receiving implementation or runtime result is claimed yet.
The interaction with a merge absorbing a lexical-chain operand still needs
measurement, not an assumption about every copy. Codex remains the only
writer/build owner. Do not correct emission ancestry while silently retaining
class decisions based on the old global-policy string.

### Eighth child: receiving model follows the selected occurrence (WIP)

Seventh-child checkpoint `c4f65a8b` is pushed; remote main was verified at
`c4f65a8bedb5439271f7dd303c67bd18d1ac196d`. Opus RESULT19 is consultation,
not coding authority; Codex retains the sole writer/build slot.

Serial `receiving_projection_probes_02.log` measures the old policy on those
published bytes. Rootless declared-formal control passes native/walked.
Materialized free-input and two-copy declared-formal
controls both exit 3 in both method modes: native
reports a missing implements record, walker INVALID. A simpler materialized
declared-formal input refuses earlier at `Wide` (`unknown type`, part 2:11);
it is a separate producer lead, not a runtime receiving witness. No expected
failure was relabelled as success.

Bounded implementation scope: `dev/l2src_sandbox/l2trans.lm1` lexical-depth
relation, formation equivalence and native/walked receiving model operands;
`lmx_walk.lm1`, `lmx_walk.h.lm1` and
`tests/lmx_walk_call_data_selftest.lm1` for a typed ancestor-count operand of
the existing NODE projection; permanent `.lm2` witnesses under the same
sandbox tests directory, their exact rows in `tools/l2_harness.ps1`, and
factual plan/core/current/defect documentation. No runtime names, per-atom
metadata, new graph, METHOD mutation or global-unit fallback.

Use one lexical-edge walk in two explicit phases: static method ownership
for COUNT/class equivalence, committed source places for physical emission.
Unavailable local-place ancestry must not become a static class key; validate
class members' static depths after PLACE. Native receiving expressions use
growable L2Tx, not the old 192-byte path buffer. A one-cell NODE still means
one parent; a typed count operand expresses any other depth, including zero.
COUNT must determine the same frame width as FILL even when physical source
places are not available yet. This is carrier representation, not new source
syntax or a separate callable/data graph.

Acceptance: rootless regression, materialized declared/free requirements and
two independent copies; candidate created after a copy, explicit copied NODE
state; native/walked and cleared-root runs; exact walked/native pins; wrong
value/global-unit/one-parent/depth mutants; typed NODE zero/one/many ancestors,
missing ancestor and malformed count; focused families, kernel/L3/full gates,
all-command replay and exact frozen/index identity. Keep required-positive
limits RED and retain the earlier unknown-type producer separately. Then
commit/push this bounded child and continue the parent dependencies.

Eighth-child measured candidate: translator blob `9922b2ac9fb6d4082cd88e46c964d88dd6d15108`,
SHA256 `1610F51B8C1146F9DF04A1FA8734BDFB30F82E46E1C6B0E1660816E67353F552`.
The earlier b3c672b2 preflight did not include the static-unavailable-depth
guards and corrected comments; do not use it as final frozen provenance.
`receiving_projection_probes_04.log` repeats rootless, materialized-free and
materialized-two-copy native/walked positives on final candidate
bytes. The simple materialized declared source still stops at unknown Wide.

Permanent fixtures add comments that reveal a separate producer defect:
main and part source offsets are compared by header type lookup. Rootless and
two-copy permanent rows now stop at unknown Wide, whereas the materialized
declared part's own comments make it pass. Final `codex_receiving_focus_04`
is 23 targets/four failures, exactly those two new pairs; old receiving
reference/classes/models/static and nested-owner/T7 controls remain GREEN.
This is not a receiving runtime regression, nor permission to strip comments
until the test passes. `CODEX-T7-PART-FORMAL-TYPE-20261008-20` has genuine
STARTED and later terminal RESULT20; the measured comment-offset lead is
confirmed below. Do not invent a backward-visible Structure rule.

Evidence correction: the diagnostic helper used `walk_root`, whereas the
driver accepts `walkroot`. Thus the `_02`/`_03`/`_04` logs' second executions
do not prove cleared-root dispatch. The helper is corrected. A fresh serial
execution-only rerun of the twelve existing baseline/final binaries uses the
actual flag (`receiving_actual_cleared_01.log`); baseline rootless passes,
baseline materialized free/two-copy cases exit3, and all six final executions
pass. Binary hashes are recorded and unchanged; no compiler runs for this
correction, and the frozen chain continues. Permanent harness WalkRoot rows and the
`receiving_mutants_04`/`receiving_negatives_01` helpers use the correct flag;
their cleared-root evidence is valid and independent.

`codex_kernel_08` is a failed preflight (296/297): the newly added L1 helper
omitted its empty `()` signature, so the first pointer declaration was read
as a formal with extra fields. Corrected source is now independently compiled
and run in `receiving_node_control_01/run_02.log`: GREEN20. Nine new checks
cover NODE zero/one/257, missing ancestor, SIZE_MAX stopping at the missing
ancestor, wrong integer type, null count, unknown width and the old one-cell
form. Isolated discard-count, accept-int-count and cap-at-192 mutants each
fail their relevant check (`receiving_node_mutants_02.log`). The first helper
compilation used blanket Werror instead of the kernel's actual warning flags;
its log is failed evidence, not the corrected test's result.

`receiving_mutants_04.log` rejects two isolated translator mutations: native
global-unit substitution exits3 normally but still passes cleared-root
(the walker was not mutated); walker forced-one-parent passes native-root
but fails cleared-root with INVALID. This demonstrates why both admission
engines must actually execute. `receiving_negatives_01.log` runs three wrong-
value programs in both method modes and both root modes: all12 executions
exit81 instead of7 and the driver refuses. Negative sources use the original
measured diagnostic pairs, not a comment edit to the permanent tests.

Full correlated RESULT20 is now terminal: the two-file offset comparison
fully explains the differing acceptance; setMarker and collection order do
not. The old rule that excludes ordinary MAIN declarations from parts was
found only in fable_pc's answer in `steps/table-receiver.md`, not an author
ruling or a normative ordering of files. The
[minimal author question](../LMX_blog/q/program-parts-declaration-visibility.md)
is asked in this chat. Do not turn accidental signature acceptance into a
new norm, or turn the consultant's suggested refusal into one either. The
dependent source-visibility correction awaits that answer; independent
receiving acceptance continues. Earlier RESULT18's withdrawal of RESULT15's
declared-formal restriction relied on the accidental rootless acceptance and
is not normative evidence. The successful two-copy diagnostics measure the
receiving implementation conditional on a collected descriptor, not proof
of source-level cross-file visibility.

Frozen acceptance chain `run_t7_gates_09.ps1` / `t7_gates_09.log` ran fresh
kernel09, L3_09, full08 and all2615 full65 translation commands, serially.
Twelve code/harness/fixture inputs are fingerprinted before work and after
every stage. Full08 is terminal RED68/2674: against full07 no FAIL→OK,
no OK→FAIL, eight added rows (four GREEN and the four cross-file header
failures), no removals or changed messages of old failed rows. Replay2615
is terminal: 2613 entirely identical, the nested-model native/walked pair
has changed L1, all exits/diagnostics/output presence unchanged (822 nonzero
translation exits, including expected refusals). Classification checks a
bijection of all77 old graph identifiers in each changed file; all old
references retain that identity. The only remaining edits are six native
admission statements changing global-model references to the selected
occurrence's two parents, plus OF(NODE(size_t2), slot0) and the RECEIVING
mark. Both complete bijection-adjusted diffs were read
(`receiving_replay_classification_01.log`), not just collapsed-ID previews.
The full-gen comparison additionally has three library path-key renames
from the new staging directory; exact normalization of that one module key
makes each whole library file identical. No other overlapping full-gen L1
changes occur. The chain's final line confirms all twelve frozen inputs
unchanged; `verify_receiving_candidate_01.ps1` verifies22 owned paths and
24 gated source copies. This is a RED development checkpoint, not stable
promotion. Next dependent source-visibility work awaits the author, while
the independent hosted-native completion below continues.
T7 and §§8/8a remain OPEN.

### Next independent child: hosted native completion (source inventory)

This is a plan, not a verified fix. On frozen9922, `l2_emit_body_in` at21943
stubs hosted capturing bodies. `l2_emit_native_word` at51823 and both
trampoline call sites at52135/52328 exclude all hosted methods. The full07
generated `unit_nested_method_owner_formal.lm1` has implemented helper m1,
descriptor-only signature m2, capturing inner m3 stubbed to return0, unrelated
root named Structure m4 and program root m5. It actually calls mk(2), then
the returned inner(1); it never calls the nested helper. Opus21 and both
RESULT22 texts contain incorrect descriptions of these rows/execution;
they are not accepted evidence or a policy permitting native suppression.

On frozen9922, `l2_mad_emit` directly emits the native factory return, while
`l2_emit_mad_construct_one` emits the walked factory's constructor. There is
no current `l2_mad_emit_into`; that name in historical notes does not identify
a current shared producer. Both producers return model child N (`l2_mad`),
not its snapshot parent C (`l2_madc`), and neither copy carries the model's
native word. The generated `l2_mad_inputs` preserves
absent hidden refs. For host formal n, walked `l2_rw_arg_fb` resolves the
snapshot cell by `l2_node_seg`; native `l2_emit_tramp_lex` only consults
`l2_hid_own_lex`, whose own-row requirement does not describe a captured
formal. A native adapter is therefore not proven sufficient merely by
removing hosted guards. Request23 asks Opus only to trace this exact absent-
input discrepancy, read-only; Codex keeps the sole writer/build.

RESULT23 is terminal and still overstates its findings: it says walked
`l2_node_seg` cannot locate the captured host formal, but the actual common
resolver at24574-24653 explicitly iterates host formals and projects
`l2_m_width(host)+j`. The existing walked positive demonstrates that path.
The native absent-input gap is real; a new runtime/per-method metadata table
is neither required nor permitted to replace existing translation relations.
Read source facts directly, not the consultant's unsupported conclusion.
Prepared diagnostic sources `t7_hosted_next_sources_01` were used in the first
probe run below; their existence alone is not an acceptance result.

An isolated diagnostic prototype is prepared at
`build/codex_handoff/t7_hosted_candidate_01/l2trans.lm1`; it is not the frozen
production translator and has no gate result. Native-word preservation must
cover both current producers above, not a nonexistent common function. The
driver's existing `postpaths`/`nativepath` can inspect returned references
after execution, including `deref`, without adding a test-only runtime path.
The staged prototype SHA256 is
`82B9F2E2CC60DE5B883C9964EBA9642F16A11EF35A5E37B4D13AD0054110AF16`
(`codex_hosted_probe_01/src/l2src/l2trans.lm1`, hash equal to the private
candidate). No second compiler/build was started alongside the frozen
acceptance chain. After its terminal result the prototype compiled in the
fresh diagnostic stage (`hosted_probe_build_01.log`, binary SHA256
`FA8FD77764F9AB72B8F69D1CAA267527D4F6F2E4996B2E173868926D57A18F5E`).
The serial baseline/candidate probes are terminal (`hosted_baseline_01.log`,
`hosted_candidate_01.log`). Baseline passes10 builds/20 executions; the
prototype passes8/16 (snapshot, helper, callable-formal owner and own-row
Structure controls, native/methods-walked, ordinary/actual cleared root).
Both prototype builds of `unit_capture_struct_formal` fail C compilation:
`l2_p1_1` is undeclared, while `l2_pr1_1` exists. This is a new regression
to repair in the private prototype, not a reason to force the method walked.
The four pre-existing whole/merge translation refusals remain in both runs.
Actual returned-copy native-word assertions are still pending; value-only
success and compilation alone are not a verified native fix or a full gate.

Bounded next route: one translation-time hidden-source locator (actual
parent projection, slot and storage type), shared by native entry and ARG
fallback; complete real typed bodies, one entry-eligibility producer shared
by prototype/definition/native-word emission, and preserve that same model
entry in returned/copied occurrences. No runtime name lookup, companion
graph, per-copy entry or invented implementation of a descriptor-only fn.
Acceptance must pin original/helper/returned native entries, force walked
twins and cleared-root dispatch, distinguish two snapshots, present zero
from absent input, primitive and Structure captures, callable formals and
descriptor-only addr0. Mutants must catch a stub body, dropped native word,
global/wrong snapshot and ignored present input. Then frozen kernel/L3/full,
all-command replay/classification and exact-path reviewed publication.

### Ninth child: source provenance and actual native execution (verified)

The eighth child was committed/pushed as `b83ca7f3`; remote main was checked
equal to the local full commit. The first private hosted prototype's
Structure-formal regression was not published as working. Its path scanner
passed the host declaration's Text to `l2_scan_ident`; `l2_dyn_reads` then
found no read in the nested body and classified the input as forwarding
only. `l2_scan_path_root` now passes a prefix view of the actual path head,
as `l2_scan_head_root` already does. `l2_dyn_add` owns that view. Capture
records also need owned views: they formerly borrowed Text pointers, which
cannot retain a machine-local prefix. `l2_mcap_add` now owns/frees only its
view, borrowing unchanged live P0 bytes. No runtime name table or graph
metadata is added. The intermediate `_02` lost-capture refusal was the
dangling-view diagnostic, not a language restriction.

Final diagnostic prototype `_03` SHA256:
`B195CD258A8047EAF7D155C31F330B8F253393D0FEEF9550CD3A49C3B56DDD58`.
It passes10 builds/20 ordinary/cleared-root executions, matching baseline's
values while actually executing native capturing bodies. Four whole/merge
translation refusals persist in both modes, as before. The full prototype
diff was reviewed and applied with `apply_patch` to development source;
live/private hashes were checked equal before the focused run.

`hosted_native_paths_01.log` executes sixteen physical native-word
observations without rebuilding: baseline native fails at helper/model/copy,
final native passes, and both methods-walked variants keep actual native0.
Each is repeated with the actual `walkroot 1` flag, and binary hashes stay
unchanged. Existing driver `postpaths`/`nativepath`/`deref` inspect the actual
returned copy after execution, not a translator comment or a prototype row.

`hosted_mutants_01.log` mechanically mutates only diagnostic generated C;
all four mutants compile/link and fail in both normal and cleared-root
execution (eight rejections). Dropped copy-native fails the requested actual
native-word checks; stub body gives82, wrong/global ancestor gives81, and
ignoring a present zero gives82 instead of7. The original C is unchanged.

Production fixtures `unit_hosted_native_snapshots`/`...helper` and their
walked rows pin original/helper/returned words, independent snapshots,
present zero and actual helper invocation. Focus02 is RED2/64: only the old
`unit_capture_struct_whole` and `...merge_two` required positives fail.
Focus01 never ran fixtures: its wildcard `-OnlyFixture` selection was
refused, so it is not a gate. Focus03 names its62 exact rows, adds the
Structure-formal walked twin/actual-copy pin and the descriptor-only
contract's native0. Chain10 completed on nine unchanged inputs: focus03
RED2/65, kernel10 GREEN297/114 actual selftests, L3_10 eleven suites/four
budgets, full09 RED70/2679. Against full08, five added rows pass and two old
rows fail obsolete backend oracles; those differences are investigated below,
not silently called regressions or discarded. All2615 translations replay:
2298 identical results and317 L1-only changes; exits, diagnostics and output
presence are unchanged. No full-green, T7 completion, stable promotion or
§§8/8a completion is asserted.

Full09's `unit_a3_node_direct_absent` still stops at exit3 on the absent BODY
field. Its real nested native body emits the field-path invariant; the old
test required the walker's INVALID even in native mode. The harness now
uses a general graph-X1 category requiring exactly one specified diagnostic,
not a permissive native/walker alternative. Existing walked rows retain
their exact INVALID, and two new cleared-root negative rows distinguish
both backends. Full09's `unit_t7_actual_in_definition` stopped before compile
because its text oracle forbade a native constructor call. That prohibition
encoded the old missing implementation. The revised twins require actual
native words for all six methods (including inner4), retain the constructor
and no-SOURCE_MACHINE assertions, and execute114/116/125 in native and
methods-walked modes with a separately cleared physical root.

Focus04 is terminal RED2/73: all eight selected X1/constructor/held-reference
rows pass; only the two pre-existing whole/merge debts fail. The held-reference
twin additionally checks actual native/zero words for methods0–7, root8 and
results9/45/45. These are behavior checks, not acceptance of a changed value.
Fresh full10/replay02 completed in chain11 on eleven frozen inputs.
Translator and all three kernel inputs exactly match chain10; kernel10 and L3_10 certificates
are explicitly reused, not reported as newly executed. The first RED70 full
gate remains evidence. Revised full10 is RED68/2683: versus full08, no
old-row regressions or corrected old failures, nine added GREEN rows, none
removed, and no changed remaining failure messages. Versus full09, the two
revised oracles pass and four added rows pass, with no OK-to-FAIL transition.
Replay02 ran all2615 commands and exactly matches every replay01 exit,
diagnostic, output-presence result and generated L1 byte. The final chain
records unchanged inputs. `hosted_replay_exact_02.log` independently asserts
the exact row set and every byte; `_03.log` compares the final replay with
the eighth child: exits/diagnostics/output presence unchanged on all2615,
1793 outputs present, exactly317 L1-only changes, 822 nonzero exits as before.

Generated L1 classification compared every old output: final full10 has1503
identical and336 changed common files, nine added and none removed; replay
has1476 identical and317 changed generated outputs. The checked mechanical
families are native-word publication/copy/prototypes, filled hosted stubs,
shared hidden-input unmarshaling, fourteen Structure-read header/prototype
changes and three bijective library-path keys (full gate only). The only
two residual regions are `unit_held_actual_reference`'s caller m3 and
program builder. `hosted_graph_bijection_05.log` repeats the complete check
against final full10 and verifies144 common graph
identifiers bijectively, then compares every line: exactly one native-word
publication is added and one seven-line caller-side AT fallback is removed.
The native caller loses exactly the corresponding fifteen-line fallback;
after five exact local substitutions all admission and call logic is
identical. Absence is forwarded to the already-existing actual-callee
fallback; present caller references keep priority. No new graph node is
introduced by that residual, and no identifier is collapsed to hide changes.

Final publication checks: thirteen owned paths, eleven frozen inputs and
twenty-two matching gated source copies (`verify_hosted_candidate_02.ps1`).
Index/live equality is required before commit. `l2_driver_launch.err` is
unrelated and excluded. No stable promotion, full-green or parent completion
is claimed. Whole/merge captures, PAP/native-composed and the cross-file
visibility question remain OPEN; next bounded child is PATH-STRUCTURE-LEAF.

Read-only Opus24 consultation is terminal. Its stale HEAD and unverified
producer assertions are not evidence; `path[3]` is a value/cell type, not a
kind, and `l2_check_value_call_at` is not a reference-admission checker. No
new formal receiver/non-receiver categories are adopted. Codex independently
inventoried the source selector/consumers and prepared unexecuted probes;
the consultation authorizes no second writer or build.

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
