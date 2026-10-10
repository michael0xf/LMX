# Interpreter throw — bounded implementation and evidence, 2026-10-10

This is an implementation/evidence ledger, not a new language rule. The
accepted rule is in the semantic book's `catch` section: an error detected
while executing a correctly constructed graph is an ordinary implicit
`interpreter` throw. Translation/construction failures, malformed graph
nodes, allocation failure and kernel invariants are diagnostics, not that
throw. The author selected one name, `interpreter`, and did not authorize a
parallel exception channel or runtime name lookup.

## Implemented on the current sandbox bytes

- `l2trans.lm1` appends `interpreter` after existing implicit `merge`,
  `implements`, `convert`; builds a retained THROW role for explicit source
  `throw:` and puts a typed ordinal on operations capable of recoverable
  walker failure. Their local lexical `catch` PAD is carried by the existing
  row mechanism. Cross-call rows remap implicit ordinals when caller and
  callee declare different numbers of throw names.
- `lmx_walk.h.lm1` and `lmx_walk.lm1` execute the retained THROW body,
  evaluating payload expressions in order, and use the ordinary thrown
  status/payload. DIV/MOD by zero, L3 Array element bounds failure, null
  dereference and null Array use go through one ordinary `interpreter`
  status path. Malformed operation metadata still returns `INVALID`.
  Numeric payload allocation failure returns `NOMEM`, not `INVALID`.
- Native call lowering can now receive an implicit status from a selected
  walked callee with **no explicit** `throws:` list when its caller already
  has a status-bearing ABI. It uses the existing name/ordinal propagation,
  not a name-specific special case.
- Fixtures assert local catch, walked-to-walked ordinal remapping, native
  caller to walked callee, source-level Array OOB catch, and walked explicit
  payload delivery. Kernel self-tests assert raw walker OOB and DIV/0 thrown
  statuses and a malformed operation's diagnostic status.

## Frozen gates

- `build/l2_harness/codex_interpreter_throw_focus_06`: GREEN 7 targets,
  four selected fixtures, exact translated/compiled/linked/executed
  snapshot. The selected methods' native/walk bindings are asserted.
- `build/l2src/codex_interpreter_kernel_final_01`: GREEN 298 targets on
  the final-byte kernel candidate, including the later `char`/`unsigned
  char` explicit payload and allocation-failure corrections. The earlier
  `codex_interpreter_kernel_01` also passed 298 but predates those bytes.
- `build/l2_harness/codex_interpreter_throw_focus_04`: RED1/7. It forced
  the caller to be truly native and exposed its old assertion that a
  callee without explicit `throws:` could not return an implicit walker
  status. The general status-bearing call route then made focus06 green.
- `build/l3/codex_handoff_20261010_02`: all 11 L3 suites and all four
  type budgets pass. The two additional activation-local qualification
  types make the measured Windows closure 78/128; the budget was updated
  from 76 only after identifying both declarations, not by widening the
  translator's 128-name limit.
- `build/l2_harness/codex_interpreter_throw_full_01`: RED84/2894. Against
  `codex_coverage_full_01` (RED69/2890), all 69 old failures have unchanged
  diagnostic details, all four new interpreter fixtures pass, and 15 former
  successes fail. Six failures were stale `NativeMethods` assertions for
  methods that now correctly walk; after changing those rows to assert
  `WalkedMethods`, all six executed successfully in focused run
  `codex_interpreter_walk_reclass_02` (GREEN9/9). This is a test-contract
  correction, not a forced native implementation.
- `build/l2_harness/codex_interpreter_throw_full_02`: RED78/2894 on the
  corrected final row definitions. Versus full01, exactly those six stale
  assertion rows change FAIL -> OK, with no OK -> FAIL and no changed
  diagnostic detail in the remaining FAIL rows. Versus the Stage23
  `codex_coverage_full_01` baseline (RED69/2890), no target is removed:
  four new interpreter fixtures are OK; all 69 old FAIL identities and
  details remain unchanged; exactly nine old OK graph-shape rows become
  FAIL. This is a measured open defect, not an accepted full gate.
- The other nine regressions are **not** obsolete oracles. DIV/MOD gained
  two hidden status/pad graph children, ELEM/ELEMPUT gained two, and one
  foreign CALL gained four implicit-remap triples (9 -> 21 children).
  Three mutant failures are downstream of their changed baseline graph.
  These extra children violate the accepted source-defined graph field
  composition/order. Do **not** change their expected shape to get a green
  gate. The catch/status protocol must be derived from retained source roles
  and ordinary activation state, not appended hidden source-graph fields.
  Exact old failing rows: `graph_shape_dormant_zero_divisor`,
  `graph_shape_array_place_selectors`, its `_walk` row and
  `graph_shape_array_place_erase_index_mutant`, plus
  `graph_shape_foreign_value`, `graph_shape_walk_foreign_value` and its
  `_actual_mutant`, `_callee_mutant`, `_literal_mutant` rows. The three
  foreign mutants fail their baseline/setup precondition after CALL widens;
  they are not independent wrong-value executions.
- `python tools/check_docs.py` and `git diff --check`: green on the final
  handoff source/document state before commit.

## Still open — do not infer completion from focus06

1. **Repair the graph-shape regression before accepting this candidate.**
   `l2_rw_frame` adds hidden interpreter status/pad slots; `l2_rw_catch_call`
   adds hidden implicit-remap triples. `lmx_walk_fault` and `lmx_walk_call`
   read them. Source `throws:` currently has a generic inert role and PAD
   lacks a retained throw identity. A general repair can retain these
   identities in the existing source roles, derive each activation's
   declared-count/implicit status from the source header, and select a
   lexical catch PAD by graph parentage. Cross-call implicit status maps
   `d_callee + g` to `d_caller + g`, without per-call child triples or
   runtime names. Audit the already existing explicit row protocol and the
   new THROW ordinal child as well; a narrow nine-test repair does not
   prove the whole source-graph invariant. Preserve the physical source
   graph and separately test copy/merge of a handler. This is an
   architectural dependency, not permission to alter the exact-shape
   oracle. See `INTERPRETER-STATUS-HIDDEN-GRAPH-CHILDREN` in defects.
2. A native method with no explicit `throws:` still has a non-status-bearing
   typed ABI. If it calls a walked occurrence that raises `interpreter`,
   universal propagation/uncaught handling is not yet implemented. Do not
   make a per-name exception or assume that the selected occurrence must be
   native. Add a positive witness and preserve all existing status routes.
3. Add source-level uncaught `interpreter` and nested-call-actual witnesses.
   The direct `lmx_interp_apply_value` API currently maps unhandled
   `THROWN+k` to `LMX_INTERP_INVALID`, losing the distinction from malformed
   graph; resolve that public boundary without a second throw channel.
4. For manually supplied malformed executable frames, metadata shape is
   checked on the fault branch. Decide and implement general eager validation
   of an **executed** operation before evaluating its operands, so a
   malformed frame does not sometimes run based on operand values. This is
   a graph-invariant check, not a recoverable `interpreter` throw.
5. Native L3 arithmetic fault parity is a separate lowering dependency.
   `interpreter` here describes detected walker errors; the new fixtures do
   not prove that native DIV/0 is caught.
6. Audit every callable entry, not only `fn/fm/sub`: generated execution of
   an ordinary named Structure in `l2_emit_ns_exec_at` still aborts on any
   nonzero `lmx_call_prim` status, even when a caller could catch the
   selected walked body's implicit `interpreter`. The callable-merge adapter
   `l2_mad_call` also aborts on a nonzero status. Both are concrete open
   propagation paths; do not silently make these failures uncatchable. The
   named-Structure fix must also mark possible implicit statuses before
   caller ABI selection/throw closure; replacing only the emitter's abort
   is unsafe for a non-status-bearing caller. The existing
   `l2_emit_propagate` route is available once that analysis is correct.
7. In `lmx_walk_call`, a fault while evaluating the long-call callee selector
   is currently collapsed to `LMX_WALK_INVALID` by the combined
   `status != OK || contract == 0` check before actuals. Preserve an ordinary
   thrown status there, while separately diagnosing a missing contract;
   add a graph-level selected-callee witness. Source-level reachability of
   that selector fault has not yet been demonstrated; do not call it a
   source regression without evidence. This is distinct from the direct public
   `lmx_interp_apply_value` boundary in item 3.
8. Finish the qualified-original-source Stage23 old-row comparison and
   construction-diagnostic contract separately. A root graph that cannot
   be constructed is a translation diagnostic; it is not made catchable
   by this runtime work.
