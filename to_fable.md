# Handoff to `fable_pc` — LMX core, 2026-10-10

This is an implementation handoff, not a language specification. The author
has moved the handoff to 15:00 São Paulo time on 2026-10-10. Both existing
sessions are now running; the transport probe
`FABLE-PC-LINK-20261010-165030` received a substantive `fable_pc` ACK through
`lmx_uds` and back into this Codex task. That confirms the route, **not** a
transfer of the writer/build slot. Codex is completing a bounded current
step, will commit and push the reviewed work, then pause its Pursuing goal.
`fable_pc` must not code, build, edit or change Git before that handoff.

## 1. Authority and ownership

- The accepted language rules are in `docs/` (with generated semantic and
  grammar source in `provenance/`). The dependency queue is
  [next_core_tasks_v2.md](next_core_tasks_v2.md); its terms are in
  [next_core_tasks_dictionary_v2.md](next_core_tasks_dictionary_v2.md), the
  architectural map in [CORE_L2_L3_v2.md](CORE_L2_L3_v2.md), and porting
  guidance in [L2_L3_CODING_INSTRUCTION.md](L2_L3_CODING_INSTRUCTION.md).
- Read [AGENTS.md](AGENTS.md), [READ.ME](READ.ME),
  [steps/current.md](steps/current.md), the v2 plan, and the relevant spec
  before modifying code. The older `next_core_tasks.md`, this file's previous
  2026-10-03 version, and [from_opus.md](from_opus.md) are historical
  context, not authority to restore a superseded implementation.
- `fable_pc` takes the **single writer/build slot** only at the author's
  15:00 handoff after Codex reports the commit/push and explicitly releases
  the slot. Codex pauses its Pursuing goal as part of that handoff. Inspect
  the actual checkout and Git state before taking it. Do not create a second
  worktree, concurrent build, or competing editor in the shared tree.
  Preserve unrelated or untracked user work.
- Continue the next *dependent* step without waiting for a new ticket. If
  implementation reveals a necessary subtask, add a concrete entry to the
  v2 plan and proceed in dependency order. Do not silently reinterpret an
  author rule to make a fixture pass.

## 2. Exact checkpoint to verify on arrival

The pre-handoff HEAD was `1a236e26` on `main`. It is **not** the final handoff
commit; obtain the final SHA with `git log -1 --oneline` and compare with
`origin/main`. Codex's 2026-10-10 work combined unfinished Stage23
`QUALIFIED-ORIGINAL-SOURCE` WIP with a bounded interpreter-throw step. The
current changed dependency closure includes kernel modules, translator,
harness, fixtures, semantic source and generated RU/EN pages. Do not treat
the old `1a236e26` as containing these uncommitted changes.

The current bounded interpreter step implements:

- one implicit `interpreter` throw name after `merge`, `implements`, and
  `convert`, without renumbering those existing names;
- a source-preserving walked role for explicit `throw`, ordered evaluation
  of its actuals, and ordinary declared-name status/payload delivery;
- ordinary `catch: interpreter ()` for walker DIV/MOD zero, L3 Array
  element bounds faults, null dereference and null Array use; malformed
  operator shapes and kernel invariants remain diagnostics, not renamed
  throws;
- local catch, walked cross-call remapping, and native-caller to walked-
  callee remapping when that caller has a status-bearing ABI.

Exact focused evidence before the final handoff: `build/l2_harness/
codex_interpreter_throw_focus_06` is GREEN, 7 targets (four selected fixtures
plus build/scope), with method-native and method-walk bindings asserted. The
earlier `focus_04` revealed a real native-caller defect (an implicit walker
status was misclassified as an impossible throw); `focus_06` tests its
general status-bearing call route. Final-byte kernel gate
`build/l2src/codex_interpreter_kernel_final_01` is GREEN, 298 targets,
including later `char`/`unsigned char` payload and `NOMEM` corrections. L3
`build/l3/codex_handoff_20261010_02` passes all 11 suites and four measured
type budgets (78/128 Windows type names after two qualification-local types).
`python tools/check_docs.py` and `git diff --check` pass on this final
handoff source/document state before commit.

The final 2026-10-10 full harness `codex_interpreter_throw_full_02` is
**RED78/2894**, against earlier Stage23 gate `codex_coverage_full_01`
(RED69/2890). No old target disappeared. All four added interpreter
fixtures pass; all 69 old failures retain identical diagnostic details;
exactly nine old successes regress. The preceding full01 was RED84/2894:
six of its additional failures were obsolete assertions that a method with
source `throw` must retain a native word under `--walk-methods`. The
corrected rows assert the actual walked method, and all six return to OK
in full02, with no new regression. Focused
`codex_interpreter_walk_reclass_02` also executes those rows (GREEN9/9).
The remaining **nine** regressions are real violations of the
source-defined graph shape: operation frames gained hidden status/pad fields
and a CALL gained implicit-remap triples. Do not change their exact-shape
oracles to green. The specific code sites and a general no-runtime-name
design constraint are in
[INTERPRETER-STATUS-HIDDEN-GRAPH-CHILDREN](steps/defects.md#interpreter-status-hidden-graph-children).
A focused green run is not a claim that the whole translator or stages 8/8a
are complete. The step-by-step evidence and open boundary are in
[steps/interpreter-throw-20261010.md](steps/interpreter-throw-20261010.md).

## 3. Open boundary, in dependency order

1. Repair the hidden status/catch fields in the source graph. The measured
   nine regressions are source-fidelity defects, not just old graph-oracle
   spelling. `l2_rw_frame` appends two children to DIV/MOD/ELEM/ELEMPUT and
   other faulting roles; `l2_rw_catch_call` appends implicit remap triples.
   `lmx_walk_fault` and `lmx_walk_call` consume them. The existing graph
   already retains `throws:` as an inert role and PAD as a lexical handler;
   assign them identity within the existing typed role representation, or
   another general source-preserving design. Runtime must use numeric/typed
   identities and ordinary activation, never a name table. Find a copied
   handler in the copied body, not by an original-node address. Audit the
   new THROW ordinal and pre-existing explicit catch triples too; a narrow
   nine-row fix is not full source-graph fidelity. Preserve native/walk ABI
   and graph-copy qualification checks. This is multi-slice work, so do not
   relabel the current RED gate as accepted. A possible general route (design
   hypothesis, not a newly authorized language rule) is to intern throw
   identities to numeric keys at translation time and carry a key in the
   existing typed operation-role token rather than a new graph child. A
   walker activation can then match the PAD role in its current lexical body
   and preserve that selection after copy/merge; native and walker calls
   pass the key rather than re-map per-call graph triples. The role registry
   and graph-copy validator currently assume `role.code == roles index`:
   update and test that invariant coherently rather than inserting an
   unregistered token. A naive linear scan of every site-specific role on
   every interpreted operation would be expensive; typed-address validation
   with registry-index confirmation is one implementation path. Prove the
   overall ABI and performance before adopting it.
2. Finish exact current-gate classification and Stage23
   `QUALIFIED-ORIGINAL-SOURCE`: source-faithful qualification, an explicitly
   located construction diagnostic (not a catchable executable throw), old
   row comparison, and acceptance on final bytes. Follow
   [the live journal](steps/qualified-original-source-20261010.md) and the
   top of the v2 plan; do not turn a focused improvement into a full release.
   The P0 branch site is already retained in `l2_ebr_at[k]`, while the
   generated preflight currently prints only `branch k`. The journal records
   a source-location emission route, the required escaped path and the
   difference between branch-site and exact bad-edge provenance. Do not
   report this as fixed merely because the builder exits nonzero.
3. Extend the interpreter-throw closure honestly. The current native bridge
   still needs a universal treatment for a *non-status-bearing* native caller
   invoking a walked method that can throw implicitly; the implementation
   must not assume an absent explicit `throws:` list means an actual selected
   occurrence cannot raise an implicit status. The named-Structure execution
   path `l2_emit_ns_exec_at` and callable-merge adapter `l2_mad_call` also
   abort on nonzero walked statuses instead of using the general route.
   For named Structure, a safe fix needs pre-ABI possible-status marking
   and throw closure, not only swapping the emitted abort; then reuse the
   existing `l2_emit_propagate` mapping.
   In `lmx_walk_call`, a graph-level fault from a long-call callee selector
   is collapsed to `INVALID` by its combined status/contract check; its
   source-level reachability is not yet established. Add positive and
   negative witnesses for uncaught `interpreter`, fault in a nested call actual,
   malformed executed-op metadata, and direct `lmx_interp_apply_value`
   propagation. The direct `lmx_interp_map` currently collapses an uncaught
   `THROWN+k` into `LMX_INTERP_INVALID`; do not pretend that is a preserved
   language throw. Native DIV/0 parity is a separate L3 native lowering
   dependency, not evidence that walker catch is broken.
4. Continue the v2 plan through `critical_graph_bug`,
   `critical_pointer_to_struct_bug`, the subsequent general refactoring,
   clean-kernel checkpoint, then stage 8 and 8a. The target is two-generation
   L3/L2 self-build **without handwritten L1**; generated L1 as a technical
   intermediate is legitimate. Do not move to `myxa_manager` work.

The design boundaries remain strict: the retained graph mirrors source
containment and field/operation order; no permanent auxiliary data/callable
graph, runtime name table, atom leaf for an already materialized primitive,
or name-specific syntax path. A qualified Structure's stored data references
are checked before qualification, but code operands in an unexecuted Frame
are not imagined to have executed. A `throw` from executing a valid graph is
different from a translation/construction failure. Ordinary named Structure
has a body but no explicit formal arguments; `fn/fm/sub` have signatures.
Native versus interpreted execution depends on the selected occurrence's
actual native implementation word, not the spelling or source position.
Array descriptors, pointer depth, receiver composition and `implements`
must follow the current docs, not legacy special cases.

## 4. Verification and publication

Use fresh output directories, the pinned `bin/l1trans.exe`, and the existing
test runners. `build/` evidence is local, ignored, and not a Git deliverable.
The normal Windows gates are:

```powershell
& .\tools\l2_harness.ps1 -OutDir C:\Nyasha_Planet\LMX\build\l2_harness\<fresh-name> -KeepAll
& .\tools\build_l2src.ps1 -Run -OutDir C:\Nyasha_Planet\LMX\build\l2src\<fresh-name> -KeepAll
python tools/run_l3_selftest.py --help
python tools/check_docs.py
git diff --check
```

Choose the L3 runner's actual output syntax after reading `--help`. Record
translation, compile, link, run and walk/native observations separately.
Do not adjust an oracle to green merely because implementation refuses the
accepted positive case. Compare full runs by fixture identity and outcome;
report additions, removals, FAIL→OK and OK→FAIL explicitly. Before a new
commit, review exact owned paths and stage only intended repository changes;
do not add `l2_driver_launch.err`, ignored `build/`, or credentials. Push
normally and verify `HEAD`/`origin/main`; never force-push for this handoff.

## 5. Every question goes to Codex, through `lmx_uds`

The author explicitly delegates to Codex **all questions that `fable_pc`
would otherwise address to the author** while implementing this plan. Do
not ask the author directly, wait for another agent to make the language
decision, or let the postman decide semantics. Codex answers from accepted
rules, code and evidence; if the question reveals a genuinely unresolved
contradiction or missing author choice, Codex itself asks the author here in
Russian and relays the answer back. This is the only escalation path.

After the 15:00 handoff, send the full question to the existing `lmx_uds`
session. Include one unique request ID, actual sender
`fable_pc`, minimal source example, expected rule and doc anchor, observed
native/walker result, exact symbols/files, and one precise question. Explicitly
request a substantive reply to **the existing `fable_pc` session with the
same ID**. The verified Claude-to-Claude route is native `SendMessage`:

```text
SendMessage(to="lmx_uds", message="From fable_pc. QUESTION <ID> for Codex. <Full evidence and question>. Route to the bound Codex task and return Codex's full answer to this fable_pc session with the same ID.", summary="LMX core question for Codex")
```

The local client `python claude_chat/uds.py --name lmx_uds send
"From fable_pc. QUESTION <ID> for Codex. ..."` is a fallback only if native
messaging is unavailable in that session. The postman's duties and delivery
stages are in [to_lmx_uds.md](to_lmx_uds.md). Do not run
`codex_inbound.py bind` from Fable or lmx_uds; only the intended Codex task
binds its own inbound endpoint. A socket ACK is not Codex's answer. Do not
start a new Fable/ACP session to work around a missing recipient.

At handoff, Codex stops coding and remains the architectural question
answerer. `fable_pc` owns the next sequential code step after verifying the
actual committed checkpoint.
