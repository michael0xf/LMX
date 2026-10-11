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
2. **Built (`fable_pc`, 2026-10-11):** a native method with no explicit
   `throws:` had a non-status-bearing typed ABI, so its call of a walked
   occurrence that raised `interpreter` hit "lmx: invariant: a callable that
   cannot throw reported a status" and aborted (measured on the committed
   translator with the probe of the day). Now a method the translation walks
   (`l2_walk_methods`, `l2_m_steps[i] >= 0`, `l2_m_walkable[i]`) is on the
   status channel (`l2_m_throws`) whatever its signature declares -- its
   selected occurrence executes through the walker and may raise the implicit
   statuses -- and its callers close over it (`l2_throws_close`, run again in
   `l2_emit_unit` right after the walk count pass fixed the walked set and
   before any ABI is written; the walk builders read no status mark, so count
   and fill agree; the same closure makes the newly marked methods receive and
   forward the Message). No per-name exception: the implicit ordinal is the
   callee's `d + 4` as for every implicit name, translated at the native
   boundary as slice A does; the invariant now guards native callees only; E
   stops on an uncaught status as before. Witnesses:
   `unit_walk_interpreter_native_catch_plain` (the native caller, kept native
   by a C-door call and declaring no names, catches with its own
   `catch: interpreter ()`: exit 7) and
   `unit_walk_interpreter_native_uncaught_plain` (no handler on the path: R0
   stops, `Thrown = 4`); the declared-name sibling
   `unit_walk_interpreter_native_catch` and the walked chain
   `unit_walk_interpreter_throw` unchanged. Gates: kernel `fable_item2_kernel_01`
   (GREEN, 300 targets, 0 failed); focused harness over every walked and throw-related row in two
   halves, `fable_item2_focus_01a` (936 targets, 19 failed) and `fable_item2_focus_01b` (936 targets, 24 failed; the 43 together are pre-existing with unchanged details against the full baseline codex_interpreter_throw_full_02 with the later focused runs superseding their rows; FAIL->OK 0, OK->FAIL 0, the two new rows added, both OK); L3 `fable_item2_l3_01`
   (all 11 suites ok, type budget ok); mutants on the staged translator: the marking dropped -> both witnesses abort on the "callable that cannot throw" invariant (driver exit 3, two abort sites in the L1) where the real ones exit 7 and stop with the thrown ordinal; the re-closure dropped -> the generated program does not compile: the marked callee is called in the status-bearing form from a caller whose signature carries no status outputs, so the propagation writes to a formal the caller does not have -- the closure is what keeps caller and callee ABIs consistent; `check_docs` and
   `diff --check` clean. The ABI of every walked method under `--walk-methods`
   now carries the status outputs; native translations are unchanged.
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
6. **The named Structure built (`fable_pc`, 2026-10-11); the callable-merge
   adapter still open.** Generated execution of an ordinary named Structure
   (`l2_emit_ns_exec_at`) aborted on any nonzero `lmx_call_prim` status --
   measured: `S: int: x -1 / size_t: s (x)` executed under `catch: convert ()`
   hit "lmx: invariant: executing a named Structure reported a status", exit 3.
   The analysis the item asked for holds before the emitter: the procedure is
   on the status channel by its own body (`l2_body_throws`, the admission site
   of the conversion; a walked procedure by item 2), and the executing method
   is closed over it by the execution's edge (`l2_m_edge` at the ns-exec sites
   29582/29589), so it already carried the status ABI. Now the emitter routes
   the status as a call does: when `l2_call_status(mi, pr)` holds, the status
   lands in a temp of the call numbering (`l2_ts<t>`, the thrown record in
   `l2_te<t>`) and `l2_emit_propagate` delivers it to the method's own handler
   or re-encodes it for the caller; a procedure that cannot throw keeps the
   invariant. Witnesses: `unit_ns_exec_convert_catch` (+`_walk`; the method's
   own `catch: convert ()`: exit 5) and `unit_ns_exec_convert_uncaught`
   (+`_walk`; R0 stops, `Thrown = 3`); `unit_local_ns_call` and
   `unit_walk_local_ns_call` unchanged. Gates: kernel `fable_item6_kernel_01` (GREEN, 300 targets, 0 failed);
   focused harness `fable_item6_focus_01a and fable_item6_focus_01b` (559 and 558 targets, 16 and 11 failed, all 27 pre-existing with unchanged details against the full baseline with the later focused runs superseding their rows; FAIL->OK 0, OK->FAIL 0, the four new rows added, all OK); L3 `fable_item6_l3_01` (all 11 suites ok, type budget ok); mutants on
   the staged translator: the routing condition forced false -> both witnesses abort on the "executing a named Structure" invariant (exit 3) where the real ones exit 5 and stop; the delivery dropped (the status in its temp, l2_emit_propagate not asked) -> both complete with 7 as if nothing had happened, where the real ones exit 5 and stop with ordinal 3; `check_docs` and `diff --check` clean.
   **The callable-merge adapter, native route built (`fable_pc`, 2026-10-11;
   Codex, REPLY FABLE-STATUS-20261011-08: implement the route, not
   PRIMITIVE/abort; the adapter returns the callee's status and record, the
   native site routes it through `l2_emit_propagate`, a conservative status ABI
   on every method with a held call is an implementation choice closed over
   callers before any ABI is emitted, the model's declared names are handled
   statically).** Measured first: a held call `(w: 1)` whose model converted -1
   to size_t aborted "lmx: invariant: a callable merge call failed" (exit 3),
   caught or not, natively and walked. Now (1) `l2_check_held_call` marks the
   calling method on the status channel -- after `l2_body_throws` computed the
   marks and before `l2_throws_close` closes its callers over it, both in
   `l2_parse_unit` -- and applies the static rule of section 15 to the model's
   declared names where the model is known at the call
   (`l2_check_throws_handled`); (2) the generated adapter returns the model's
   status (`lmx_call_prim`'s ordinal; `out` already holds the thrown record)
   instead of aborting; (3) the native held-call site (`l2_prep_held_call`)
   lands the status in a temp of the call numbering and asks
   `l2_emit_propagate` -- the caller's own handler, or the re-encoded return.
   A held call whose model is not known at the site kept the abort, recorded
   as a located limit -- withdrawn below: a limit is located only when
   translation refuses before emitting the executable path (Codex, CORRECTION
   FABLE-STATUS-20261011-09). Witnesses: `unit_held_throw_native_catch` (the
   implicit `convert` caught by the holder's caller: exit 7),
   `unit_held_throw_native_uncaught` (R0 stops, `Thrown = 3`),
   `unit_held_throw_declared_caught` (the model's declared `Oops` with its
   payload caught: exit 7), `unit_held_throw_declared_unhandled_refused`
   ("unhandled throw: Oops" at the held call, 14:14); `unit_t7_convert` and the
   other T7 rows unchanged. Gates: kernel `fable_item6b1_kernel_01` (GREEN: 300 targets, no failures); focused
   harness over the held-call, callable and throw-related rows plus the previous
   focus, in two halves, `fable_item6b1_focus_01a` (601 targets, 16 failed) and `fable_item6b1_focus_01b` (601 targets, 19 failed; all 35 pre-existing with unchanged details against the full baseline with the later focused runs superseding their rows; FAIL->OK 0, OK->FAIL 0, the four new rows added, all OK); L3
   `fable_item6b1_l3_01` (all 11 suites ok, type budget ok); mutants on the staged translator: the method with a held call left unmarked -> the site keeps its abort form (a bare abort, no message): exit 3 with no output where the real one exits 7; the adapter aborting again on the model's status -> both convert witnesses abort "a callable merge call failed" (exit 3) where the real ones exit 7 and stop with ordinal 3; the static rule for the model's declared names dropped -> the unhandled witness is still refused, but by the closure's internal check at 1:1 ("internal: a callee's declared throw is not handled by its caller") where the real one says "unhandled throw: Oops" at the held call, 14:14, so the Needle goes red;
   `check_docs` and `diff --check` clean. **The walked route is the next cut:**
   the adapter is the PRIM of a walked held call and `lmx_walk_prim` maps a
   PRIM's failure by the primitive's kind (merge, implements, else PRIMITIVE),
   so today the model's status makes the walk stop with a PRIMITIVE fault
   (`unit_held_throw_native_catch` under `--walk-methods`: R0 stops, no
   handler reached); the cut adds a PRIM protocol code conveying the callee's
   key (THROWN plus the key, the record in `out`), a walked variant of the
   adapter translating the model's ordinal to its key through its THROWS header
   (`lmx_walk_key_from_ordinal`), the walked held-call record bound to it, and a
   malformed-PRIM negative in the kernel self-tests; PRIMITIVE stays for a
   malformed runtime protocol.

   **The walked route built (`fable_pc`, 2026-10-11).** The primitive protocol
   (`lmx_primitive.h.lm1`) gets `LMX_PRIMITIVE_THROWN 64`: a primitive standing
   for a call of a callable value says its callee's throw as THROWN plus the
   KEY of the name, the thrown record in `out`; `lmx_walk_prim` lands such a
   code as `LMX_WALK_THROWN + key` on the pad of that key, as a callee's throw
   lands from a CALL; any other nonzero code outside the protocol stays
   PRIMITIVE (a malformed runtime protocol). The translator emits a walked
   variant of the adapter, `l2_mad_call_prim`: it calls `l2_mad_call` and
   translates the model's per-callee ordinal to the key through the model's
   THROWS header (`lmx_walk_key_from_ordinal` -- the one boundary where
   ordinal and key meet; the merge-built node retains that header, measured
   by the declared-name twin), answering FAIL (PRIMITIVE) for an ordinal the
   header does not have; the walked held-call record (`l2_rw_mad_call`) binds
   it, the native site keeps `l2_mad_call`. Kernel self-test
   `lmx_walk_catch_selftest`: a keyed PRIM throw uncaught is THROWN + its key
   and does not reach the literal after it, the pad of the key takes it and
   the body goes on, a code outside the protocol is PRIMITIVE (59 checks).
   Walk twins of the four witnesses (`unit_held_throw_*_walk`): the implicit
   `convert` caught (exit 7) and uncaught (R0 stops, `Thrown = 3`), the
   declared `Oops` with its payload caught (exit 7), the unhandled declared
   name refused at 14:14 of the twin. Gates: kernel `fable_item6b2_kernel_01` (GREEN: 300 targets, no failures; lmx_walk_catch_selftest 59 checks);
   focused harness in two halves, `fable_item6b2_focus_01a` (603 targets, 16 failed) and `fable_item6b2_focus_01b`
   (603 targets, 19 failed; all 35 pre-existing with unchanged details against the full baseline with the later focused runs superseding their rows; FAIL->OK 0, OK->FAIL 0, the four twins added, all OK); L3 `fable_item6b2_l3_01` (all 11 suites ok, type budget ok); mutants: the walker's THROWN pass-through of the protocol dropped (a keyed code read as PRIMITIVE) -> the walked catch twin stops with "lmx: walk error: PRIMITIVE" (exit 3) where the real one exits 7, and the catch self-test fails its two keyed checks (59 checks, 2 failures); the walked record bound to the native adapter again -> the model's ordinal 3 is read in the old protocol as THROW_IMPLEMENTS, the convert handler is not reached and R0 stops where the real one exits 7; the key translation replaced by the bare ordinal -> the declared twin's ordinal 1 is taken for the key of merge, the Oops pad is not reached and R0 stops where the real one exits 7, while the implicit-convert twin still passes (ordinal = key for a model declaring nothing), which is why the declared witness pins the translation; `check_docs`
   and `diff --check` clean.

   **Item 6 stays OPEN (Codex, CORRECTION FABLE-STATUS-20261011-09; measured
   by `fable_pc`).** The correction names the held-call site's `model < 0`
   branch (abort) as a remaining defect. Measured: that branch is dead code --
   `l2_call_head_held` admits a head only when `l2_mad_store_stmt` finds a host
   with `l2_mad_on(host)`, which is `l2_mad_model[host] >= 0`, exactly what
   `l2_mad_held_model` returns, so `model >= 0` at every site; the focused
   corpus (1196 rows) has no row reaching the abort form. The dynamically
   selected callable the correction means is the CALLABLE FORMAL (the q37
   shape, `apply (op(fn: (int: x) int) int(value)) int`): its native call is
   off the status channel -- the formal's contract (a descriptor-only method)
   has no body to mark and `l2_call_status` is 0 -- so the selected callee's
   ordinary implicit throw aborts "lmx: invariant: a callable that cannot
   throw reported a status" (probes `pf_convert_catch`/`pf_convert_uncaught`,
   native, exit 3, the caller's `catch: convert` never reached;
   `pf_interp_catch` under `--walk-methods`, the native caller of a walked
   callee faulting in the walker, the same abort); the walked caller routes
   by key (exit 7 / R0 stops). A callee declaring a name does not fit the
   nameless contract and is refused at the actual ("incompatible entry
   signature" -- the admission by signature of section 7, already located).
   Registered: [defects.md](defects.md) DYNAMIC-CALLEE-STATUS-ABORT, OPEN.
   The next cut: the contract and the calling method on the status channel
   at the check of a call through a callable formal (a conservative ABI, as
   for the held call), the existing `l2_emit_propagate` with the contract's
   d routing the selected callee's ordinal; the dead `model < 0` branch
   removed for a translation-time internal guard; witnesses: the selected
   callee's `convert` caught and uncaught, a walked callee's `interpreter`
   caught by its native caller, walk twins, the declared-name refusal pinned.

   **The dynamically selected callable built; item 6 closed (`fable_pc`,
   2026-10-11).** At the check of a call through a callable formal
   (`l2_check_call_at`, the `fi >= 0` edge) the contract -- the descriptor-only
   method -- and the calling method go on the status channel (a conservative
   ABI, an implementation choice, as for the held call), after `l2_body_throws`
   computed the marks and before `l2_throws_close` closes the callers; the site
   then takes the status form of `l2_emit_dyn_tail` and routes the selected
   callee's ordinal through `l2_emit_propagate` with the contract's d, which
   every method reaching the formal shares (S1.4). The held-call site's dead
   `model < 0` branch is a translation-time internal guard ("internal: a held
   call off the status channel"); no runtime abort stands on an ordinary
   throw's path. Witnesses: `unit_formal_throw_convert_catch` (the selected
   callee's `convert` caught by the caller of the formal: exit 7; a first site
   selecting another method completes) and `_uncaught` (R0 stops, `Thrown =
   3`), each with a walk twin; `unit_formal_throw_interpreter_catch` (a walked
   callee's walker fault caught as `interpreter` by its native caller through
   the formal: exit 7); `unit_formal_throw_declared_refused` (a callee
   declaring a name against the nameless contract: "incompatible entry
   signature" at the actual, 18:8). Gates: kernel `fable_item6b3_kernel_01` (GREEN: 300 targets, no failures);
   focused harness in two halves, `fable_item6b3_focus_01a` (606 targets, 16 failed) and `fable_item6b3_focus_01b`
   (606 targets, 19 failed; all 35 pre-existing with unchanged details against the full baseline with the later focused runs superseding their rows; FAIL->OK 0, OK->FAIL 0, the six new rows added, all OK); L3 `fable_item6b3_l3_01` (all 11 suites ok, type budget ok); mutants: the marks at the check of a call through a callable formal dropped -> both the convert-catch witness (native) and the interpreter-catch witness (walked callee) abort "lmx: invariant: a callable that cannot throw reported a status" (exit 3) where the real ones exit 7; the caller's own mark alone dropped -> unchanged (exit 7): the closure over the call edge marks the caller from the contract's mark, so the explicit caller mark is redundant -- kept in this cut, to be dropped under the next cut's gates; the held-call guard made unconditional -> the known-model held witness is refused at translation ("internal: a held call off the status channel", 18:15) where the real one exits 7: the guard is on the dead path only; `check_docs`
   and `diff --check` clean. [defects.md](defects.md)
   DYNAMIC-CALLEE-STATUS-ABORT: FIXED. With the named Structure, the
   adapter's native and walked routes and the dynamically selected callable
   on the status channel, item 6 has no open route left; it reopens on a
   measured case.
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
