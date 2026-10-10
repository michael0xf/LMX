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

## Slice A — throw-name keys (`fable_pc`, 2026-10-10)

Design. Under the per-callee ABI numbering (declared names 1..d in `throws:`
order, implicit names d + g) a walked status cannot cross a call boundary
unchanged, so every design that keeps the ABI ordinal as the walker's status
needs a per-call translation record, which is exactly the hidden row. The
walker therefore uses one identity per throw name, fixed at translation; this
slice carries it as a number: `l2_throw_key` gives the four implicit names the
fixed keys 1..4 and every declared name of the translation unit the next key
at its first appearance (`l2_tk_name`, released with the unit). The key is a
typed size_t cell at the source position of the name
(`l2_rw_key_cell`; the address-to-name table keeps its spelling for `toLmx`):
THROWS `[throws, key...]` (new op 53, built by `l2_rw_throws` for the `throws:`
header), PAD `[pad, key, params..., handler]` (`l2_rw_pad_new`,
`l2_rw_catch_stmt`), THROW `[throw, source, key]` (`l2_rw_throw`). The walker's
status is `THROWN + key`; `lmx_walk_fault` returns `THROWN + NAME_INTERPRETER`
and stores nothing; `lmx_walk_body` finds the pad with `lmx_walk_pad_find`
among the statements of the body it is executing, excluding a pad whose
handler threw again, and re-enters after the pad; a copied body therefore
catches on its own pad. The native boundary translates:
`lmx_walk_call0_dispatch`, `lmx_walk_call_prim_dispatch` and `lmx_walk_call`
use `lmx_walk_key_from_ordinal` / `lmx_walk_ordinal_from_key` /
`lmx_walk_boundary_status` through the callee's retained THROWS node
(`lmx_walk_throws_node`, `lmx_walk_declared_count`). A CALL at a conversion
edge carries source facet CONVERSION (6) and leaves as the caller's `convert`
(3), as native edge 1 does. The ABI itself (`l2_implicit_status`,
`l2_throws_pos`, `l2_emit_propagate`) is unchanged. Boundary: a precompiled
library whose graph is walked by another unit would need key reconciliation at
load; no such path exists today.

The author's correction (2026-10-10, relayed by Codex as
`CODEX-FABLE-THROW-ADDRESS-20261010-1922`; the author's words verbatim in
[LMX_blog/2026-10-10.md](../LMX_blog/2026-10-10.md#throw-identity-address)):
numeric keys are not required by any inability to
use addresses, textual occurrences of one name do not need separate
identities, stable arena addresses can serve as resolved semantic identity,
spellings are resolved at translation and never compared by the walker; the
int status `THROWN + key` and the unit-wide interning are implementation
choices, to be weighed against an address-based identity (native per-callee
ordinal mapping only at the ABI boundary; exact source graph, copy/merge,
arena lifetime, lexical catch scope, toLmx preserved; no runtime name table,
no truncated address, no helper graph) before anything is cemented.
Evaluation sent to Codex the same day: the structure above does not depend on
the carrier; of the two address carriers, the arena cell at a name's first
position is hazardous because `lmx_graph_copy_owned` copies pointer and char*
cells by value and shares the pointee, so a copy in another arena can outlive
the anchor and a reused address would match falsely, while a module-lifetime
token, exactly the accepted §9.4 layout-token mechanism (`l2_layout_tokens`,
CHAR_PTR cells), with kernel-static tokens for the four implicit names, keeps
identity across copies and arenas, keeps toLmx through the existing
cell-address-to-spelling table, and carries the identity across an activation
as the payload already travels (`f\payload`). The key stays only as the
provisional carrier of this committed slice; the token carrier is the next
slice unless Codex or the author answer otherwise. Boundary common to both
carriers: a walked call across two precompiled modules compares per-module
identities; natively that call resolves by spelling at compile time; no such
walked route exists today. Codex's reply the same day: the implicit names'
identity is language-wide (semantics §15), so one kernel-owned identity per
implicit name is consistent only if it is really shared across loaded
modules, never a module-local duplicate; whether a declared name reuses a
module-lifetime token or preserves and remaps source-graph cell identity
through copy and ownership is Codex's open question to the author; the
structural repair may be committed on its gated merits with the numeric key
marked provisional, not normative. Later the same day the author's statements
(verbatim, in order, in `LMX_blog/2026-10-10.md#catch-lookup-20261010`)
superseded that evaluation: a dangling address is not a consequence of copying;
the catch lies in the caller's graph and can be found; no separate hidden catch
arguments; no runtime search of the graph by name; the name is resolved through
the namespace at translation. fable_pc's reading, sent to Codex for the author's
yes/no: the runtime form of a throw name's namespace entry is one record per
name next to the roles table, referenced from THROWS/PAD/THROW as child 0
references a role record and shared by copies by the existing terminal rule
(lmx_graph_copy_owned.lm1:377-380); the acceptance test of any carrier is the
S1 witness, a merge copy of a method throwing `boom` caught by the original
caller, natively and walked. The key stays provisional until the answer; the
cross-module walked route stays recorded as not built (library mode walks no
method: l2trans.lm1:50093, 50098), §15 unchanged.

Audit of the older protocol. The explicit catch rows on CALL/PRIM/ADMIT_AS
(`l2_rw_catch_call`, the rows behind the ADMIT_AS maps, the PRIM rows),
Codex's fault slots on DIV/MOD/ELEM/ELEMPUT and the remap triples are removed
together; the THROW node's ordinal child is now the key cell. What remains is
the cell the rows were counted in (CALL slot 4, PRIM slot 2, ADMIT_AS slot 2),
always 0; the next slice removes it from the walker, the translator, the
self-tests, the harness layout readers and the layout documents.

Evidence.
- `build/l2src/fable_throwkeys_kernel_03`: `fable_throwkeys_kernel_03` GREEN 298 targets. `lmx_walk_catch_selftest`
  (55 checks) pins uncaught and other-key pads, numeric and Structure
  parameters, THROWS ordinal/key translation and `lmx_walk_boundary_status`,
  resume, a handler's rethrow to an outer pad, sibling and IF-body pads, DIV
  1/0 on the interpreter pad and not on a merge pad, walked-callee and char
  payloads, operand throws of PRIM and CALL, and the copied body that catches
  on its own pad while the re-keyed original no longer does; the admit,
  admit_use, arith_mul and array_elem self-tests pin the operations without
  fault slots.
- `build/l2_harness/fable_throwkeys_focus_04`: GREEN 12/12: the nine regressed
  rows, the four interpreter fixtures, every catch/throws/conversion fixture.
- `build/l3/fable_throwkeys_l3_01`: all 11 L3 suites, the type budget of the
  four Thread units at 78/128 names; `python tools/check_docs.py` and
  `git diff --check` clean.
- `build/l2_harness/fable_throwkeys_full_01`: stopped by the host for system memory pressure at 10908 of about 12050 steps, before its verdict; the full replay is pending. Against
  `codex_interpreter_throw_full_02` (RED78/2894): pending the replay; no full-run comparison exists yet for these bytes, and the focused run is not a claim about the other rows.
- Harness oracles changed only where they pinned the removed rows and slots:
  PadOwnCells (PAD width 4, parameter cell at slot 2), the foreign-value CALL
  path oracle (slot 5 is the first actual's PRIM of width 3; its null-path
  mutant at slot 2), PAD GraphShapes width 4, the ADMIT_AS shapes without the
  row cells (widths 17/22 to 14/19, no Slot 2 size) with the inner CALL of
  width 2, and the Debt needles for ELEM/ELEMPUT/DIV/MOD widths; Codex's
  fault-width bumps on ELEM, ELEMPUT, DIV, MOD and DEREF are reverted to the
  `1a236e26` values. No exact-shape oracle of the nine rows was edited.

## Slice B — the count cell (`fable_pc`, 2026-10-10; implemented, held as a patch)

The cell the old catch rows were counted in is removed in the walker
(`lmx_walk_call` argument base 4, long form from width 4; `lmx_walk_prim`
operands from 2; `lmx_walk_admit_in` cells 2..7, coverage from 8), the
translator (`arg0 4`, the EXEC emitters and `l2_rw_ns_hidden`, the PRIM and
PRIM_PUB emitters, `l2_rw_admit_project`), the header and CORE map §9.5, 23
kernel self-tests, the L3 mail self-test and the harness layout readers
(`Get-WalkCallLayout` long layout `4 + arity`, `Walk-EvaluatesSlot`, the
CallLink checks, the EXEC debt needles, the CALL/EXEC/PRIM_PUB/ADMIT_AS
GraphShapes). Gates: `build/l2src/fable_slotb_kernel_02` GREEN 298;
`build/l3/fable_slotb_l3_01` all 11 suites; `build/l2_harness/fable_slotb_focus_01`
899 targets: 670 rows unchanged OK, the nine slice-A rows OK, 8 baseline
failures unchanged, 211 rows red, every one of them a path or shape-word oracle
that indexes the old slots (`graph child matches the next shape word`,
`physical path selects an existing child ordinal`) while the program itself
exits as expected (`exit=7 expected=7`). The rows belong to about 90 oracle
definitions (41 `$critical*` arrays and 49 inline Args). The code is held as a
patch outside the tree (not committed) until those oracles are shifted by one
cell from the old (`fable_throwkeys_full_01/gen`) and new
(`fable_slotb_focus_01/gen`) generated graphs with a tool and the focused run
is green: one sweep, after the carrier slice fixes the final shapes.

## Still open — do not infer completion from focus06

1. **Done in slice A (above):** no hidden status/pad slots or remap triples;
   keys in THROWS/PAD/THROW; the pad by lexical parentage with a copied-body
   witness; the explicit row protocol removed. Remainder of this item: the
   empty count cell in CALL/PRIM/ADMIT_AS (slice B: implemented, kernel and L3
   green, held as a patch until its 211 oracle rows are shifted).
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
