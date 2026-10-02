# K04 — callable actuals and hidden inputs (next_core_tasks_v2.md, §3)

Status 2026-10-01 (deepseek, continuing fable's queue). This slice is **K04a**. It records its
reproductions before its repair, as the plan's §1 asks, and it separates the rows of the witness
matrix it measured from the ones it did not.

Norm: [callable actual projection](callable-actual-projection-20260930.md) (its witness matrix),
[docs/LMX_semantics.ru.md #callables](../docs/LMX_semantics.ru.md#callables) ("a declared callable
formal receives the callable occurrence reference … Transport is not execution"),
[next_core_tasks_v2.md](../next_core_tasks_v2.md) §3 K04, and D-106 (a callable formal of a method
shadows a same-named unit method).

<a id="k04a"></a>
## K04a — the callable formal's actual is resolved in the caller's context

**Reproduction** on the committed bytes `b7e7a87` (`l2trans.lm1` blob `2e4131dd`):

- **Matrix row 1 — transport — already works.** A nonreturning `sub task` received by a `(task: f)`
  formal is transmitted by reference and the transport executes nothing: `unit_callable_sub_transport`
  (registered in this slice) checks `hits` = 0 through the receiving call, then 0 again, then 1 after
  the explicit `task()`. The ACCEPTED shape, though, is exactly one ATOM resolved by
  `l2_find_method` in the unit namespace.
- **Matrix row 2 — forwarding — is refused.** `return: inner(f)` with `f` a callable formal of the
  calling method: `unit_callable_forward.lm2:18:13: incompatible entry signature`, `detail: frame=inner`.
  `l2_check_call`'s callable-formal route resolves the actual only as
  `l2_find_method(a0\value\as\atom)`, so a formal — a binding of the caller's own scope — is not a
  callable occurrence to it, and the audit's prediction holds ("the implementation cannot rely on
  `l2_find_method` of an atom in the unit namespace"). The native emitter's twin (`l2_prep`) carried
  the same narrow shape (`l2_tok_method_occ(l2_find_method(atom))`).
- **Matrix row 3 — equivalent nullary forms — still refused.**
  `recv(task())` beside `recv(task)`: `r3_nullary.lm2:19:8: incompatible entry signature`,
  `detail: frame=recv`. The Frame form and the atom are one P0 shape semantically (the author's
  correction in [the current instructions](current.md)), but the receiving-actual decision is not made
  in one place yet; recorded as a residual.
- **Matrix row 7 — `g(int: x)` given a nonreturning callable — still the wrong reason.** This is the
  retained failure `unit_value_call_sub_refused`: refused, but with "a callable without a result has no
  value" (SUB-ACTUAL-REFERENCE-CLASSIFICATION) instead of the ordinary reference-versus-integer
  incompatibility. Residual.

**Repair** (`l2trans.lm1`) — one resolver, used by the checker and by the native emitter, so the
decision is made once:

- `l2_cf_actual(mi, a0, actual_span, @kind, @fi)`: the actual is resolved in the CALLER's lexical
  context. A callable FORMAL of this method is kind 2 — its occurrence is what its caller handed it and
  is passed on unchanged, and by D-106 the resolved binding wins over a same-named unit method. A unit
  method's occurrence is kind 1. The resolved contract method is returned, so the existing
  `l2_method_sig_compatible(cand, req)` check decides admission, and anything else stays the located
  `incompatible entry signature` it was.
- `l2_cf_actual_emit(mi, a0, actual_span, dest)`: the same decision, emitted — `l2_tok_formal` for a
  forwarded formal (its own bound value, nothing invented), `l2_tok_method_occ` for a unit method.
- The checker marks `l2_m_value_used` only for kind 1: a forwarded formal's occurrence is chosen by the
  caller of THIS method, not here.

**Witnesses.** Rows in `tools/l2_harness.ps1`:

- `unit_callable_forward` — identity survives forwarding and the transport executes nothing: one
  `int: hits` field, `sub task` increments it, `inner (task: f)` receives the callable, `outer (task: f)`
  forwards it (`return: inner(f)`); the root reads 0 after the call and 0 again, then invokes `task()`
  and reads 1. Entry 7.
- `unit_callable_forward_refused` — the negative: a callable formal whose own contract is incompatible
  with the receiving formal's (`mk` returns an int; the position takes a nonreturning callable) is
  refused at the call, `20:13: incompatible entry signature`. Forwarding is not a way around the
  signature check.
- `unit_callable_sub_transport` — matrix row 1 as a standing witness (green on the committed bytes
  before this slice; the row is the regression guard for the transport).

**Evidence.**

- Focused `build/l2_harness/dk_k04_focus_02` (15 targets: the two new rows, `unit_callable_sub_transport`,
  `unit_value_call_sub_refused`, and the callable neighbours `unit_make_adder_size_t`,
  `unit_make_adder_model_call`, `unit_make_adder_helper_call`, `unit_d105r_formal`,
  `unit_ref_formal_path`, `unit_formal_spelling_rebind`, `unit_merge_atom_unit`,
  `unit_merge_hidden_input`): **1 failed** — only the retained `unit_value_call_sub_refused` (row 7,
  above); staged `l2trans.lm1` blob `ab2519c0` = the committed bytes.
- M0, the committed bytes with the new rows (`build/l2_harness/dk_k04_m0`): `unit_callable_forward` RED,
  `l2trans produced no L1`, `18:13: incompatible entry signature` (`detail: frame=inner`) — the
  reproduction; the negative row is refused the same way on both sides, so it guards against
  over-acceptance rather than proving the change.
- M1, the checker half only — the helpers and the checker patched, `l2_prep` NOT (`dk_k04_m1`): the row
  is still red, but for the other reason: `internal:` — the actual passes the check and the emitter has
  no expression for it. Both halves are in the slice; neither alone produces a program.
- Full gate `build/l2_harness/dk_k04_full_01`: **37 of 1139** targets failed (K02d's committed result:
  37 of 1136) — `unit_callable_forward`, `unit_callable_forward_refused` and
  `unit_callable_sub_transport` all OK, no newly failing target, no newly passing one, and the 37
  retained failures unchanged by exact ID and diagnostic (`build/fable_k03b/compare_full.py`). Staged
  `l2trans.lm1` blob `ab2519c0` = the committed bytes. Kernel and L3 sources are untouched by this
  slice.
- `python tools/check_docs.py` OK, `tools/gate_p0_header.ps1 -Root .` OK (47 P0 defines, 7 files),
  `git diff --check` clean.

<a id="k04b"></a>
## K04b — the equivalent nullary forms are one receiving contract

**Reproduction** on K04a's bytes (`980971e`, `l2trans.lm1` blob `ab2519c0`): `recv(task())` — the
canonical nullary call Frame as an actual of a callable formal — is refused,
`19:8: incompatible entry signature`, `detail: frame=recv`; the bare atom `recv(task)` was accepted.
P0 keeps the two spellings apart and collapses the other two: printTree gives `recv (task)` as
`structure[atom "task"]`, while `recv (task())` and `recv (task: ())` are both
`structure[frame head="task" body=empty]`.

**Repair.** `l2_cf_actual` resolves a nullary call Frame — an empty body, a head that resolves to a
callable — by the same rule the atom takes, and the emitter needed nothing: the occurrence it emits is
the same one. A Frame with any active field is a call with arguments (a value or a statement), not
this, so it keeps its located refusal.

**Witnesses.**

- `unit_callable_nullary_forms` — all three spellings in ONE program: `recv(task)`, `recv(task())`,
  `recv(task: ())`; the counter is 0 after each of the three and 1 after the explicit `task()`.
  Entry 7.
- `unit_callable_returning_two_contracts` — matrix row 4: a RETURNING callable received once by a
  callable formal (no execution: the counter stays 0) and once by a result-receiving primitive formal
  (executes exactly once — the counter is 1 and the received value is the callable's own result, 41).
  This row was already green before this slice's repair (measured on the K04a-only bytes below), so it
  is a standing guard for the receiving-contract distinction, not evidence of the new resolution.

**Evidence.**

- Focused `build/l2_harness/dk_k04b_focus_01` (the new row, the K04a rows and the callable neighbours):
  **1 failed** — only the retained `unit_value_call_sub_refused`; staged blob `d87307f5` = the
  committed bytes. `build/l2_harness/dk_k04b_focus_02` (the row-4 witness with the same rows):
  **0 failed**.
- M-K04a-only (`build/l2_harness/dk_k04b_m0`, the K04a bytes with the new rows): `unit_callable_nullary_forms`
  RED — `l2trans produced no L1`, `…: incompatible entry signature` (`detail: frame=recv`), i.e. the
  reproduction; `unit_callable_returning_two_contracts` and the K04a rows stayed green.
- Full gate `build/l2_harness/dk_k04b_full_01`: **37 of 1141** targets failed (K04a's committed result:
  37 of 1139) — the two new rows OK, no newly failing target, no newly passing one, and the 37 retained
  failures unchanged by exact ID and diagnostic. Staged `l2trans.lm1` blob `d87307f5` = the committed
  bytes. Kernel and L3 sources are untouched by this slice.
- `python tools/check_docs.py` OK, `tools/gate_p0_header.ps1 -Root .` OK (47 P0 defines, 7 files),
  `git diff --check` clean.

**Observed divergence, recorded not claimed as equivalence.** With the Frame actual the generated L1
is NOT byte-identical to the atom form's: the atom form emits walker IR for the receiving method
(`l2_rw…` frames) and the Frame form does not, because the walker's own callable-actual branch
(`l2_rw_call`) still accepts only an atom (`a callable input that is not a method's name` otherwise),
so the method stops being walk-eligible. Both run natively to the same observable (the rows above are
native runs). The walker half of this decision is the residual below; no walked route is claimed for
any row of this slice.

<a id="k04c"></a>
## K04c — a no-result callable in a NUMBER argument is a reference (matrix row 7)

**Reproduction** on K04b's bytes (`adf3d71`, `l2trans.lm1` blob `d87307f5`), probes in
`build/deepseek_k04c/src/`:

| source | HEAD said |
| --- | --- |
| `g(s)`, `s` a nonreturning `sub`, `g (int: n)` | `8:3: a callable without a result has no value` (`detail: atom=s`) |
| `g(s())` — the same value, the canonical nullary form | the same message (`detail: frame=s`) |
| `g(A)`, `A` a UNIT-LEVEL named Structure | **ACCEPTED**, and emitted as an int argument |

The third row was found while measuring the first two: the generated C declared the argument
`int: l2_arg2 lmx_arena_ref_struct(node, 5U)` and read it back as an int
(`lmx_int_value_known(refs[0])`) — the Structure's descriptor read as a number. The same shape with a
method-local declaration (`A: b`, then `g(b)`) WAS refused ("a reference where a number is asked"), so
two spellings of one rule disagreed. Recorded as
[NAMED-STRUCTURE-NUMBER-ARGUMENT-TYPED-UNKNOWN](defects.md#named-structure-number-argument-typed-unknown).

**The ordinary phrase.** `a reference where a number is asked` — already pinned by
`unit_valkind_arg_ref_refused` for a Structure given to a number formal, and what the plan's matrix row
7 asks for: "Ordinary incompatible actual/reference-versus-integer failure; no blanket assertion that
a `sub` cannot be transported as a value".

**Repair** — one edit to `l2_check_call`, in the argument loop, where the receiving formal asks for a
number (its type is a primitive number and it is not a Structure formal):

1. the actual resolves (`l2_cf_actual`) to a callable occurrence WITHOUT a result → refused as a
   reference. A RETURNING callable is untouched: it executes, and its result is what a number place
   receives (row 4's witness).
2. the actual is a name of a UNIT-LEVEL named Structure → refused by the same rule. That name is a
   reference like any other, and `l2_colon_bound_ty` types an own field, a formal and a dynamic input
   but not it, so the receiving contract is where the rule is applied.

**The general attempt, measured and withdrawn.** The first form of this repair taught
`l2_colon_bound_ty` to type a unit-level named Structure as a reference (`l2_colon_graph_ty()`), so
that the existing number-place check would refuse it everywhere at once. That changed the meaning of a
Structure's name for unrelated callers: `build/l2_harness/dk_k04c_full_01` shows **55 newly failing
targets** — `unit_named_struct_exec_*`, `unit_named_struct_call*`, `unit_walk_named_struct_*`,
`unit_s7_*`, `unit_ns_noclose_*` and others — each stopping at
`…: not supported yet` (`detail: atom=Counter`, the Structure's own name) because a caller that had
received "unknown" for that atom now received a reference type. The general change is NOT the route;
the rule is applied at the receiving contract instead, and the measured consequence is recorded here
so the next attempt does not repeat it.

**Witnesses** (rows in `tools/l2_harness.ps1`; all refusals, with the message as the observation):

- `unit_value_call_sub_refused` — the atom spelling. Its needle moves to the ordinary phrase; the old
  needle (`incompatible entry signature`) never fired, which is why the row stood red in the retained
  list since `cbc97c79`.
- `unit_callable_frame_int_refused` (new) — the nullary call form of the same value: one receiving
  contract, one refusal.
- `unit_named_struct_number_arg_refused` (new) — the unit-level named Structure as an argument.
- The rows that keep the OTHER message stay green and are measured here: `unit_return_sub_refused`,
  `unit_void_value`, `unit_discard_void_refused`, `unit_predef_result_void_refused` (the return and
  assignment positions have their own sites; this slice did not change them), and
  `unit_valkind_arg_ref_refused` (the Structure-in-a-method case, unchanged).

**Evidence.**

- Focused `build/l2_harness/dk_k04c_focus_02` (16 targets: the three rows, the four owners of the
  other message, `unit_valkind_arg_ref_refused`, the named-Structure and `unit_s7` fixtures the
  withdrawn general attempt had broken, and the K04a/K04b rows): **0 failed**; staged `l2trans.lm1`
  blob `5576e6f8` = the committed bytes. The first focused run of the withdrawn form is
  `dk_k04c_focus_01`.
- M0, K04b's bytes with the changed and new rows (`build/l2_harness/dk_k04c_m0`): the three rows RED —
  the two callable rows with "a callable without a result has no value" (not the new needle), the
  Structure row because it is ACCEPTED. Two different failure reasons, one per half of the repair.
- The withdrawn general form, full gate `build/l2_harness/dk_k04c_full_01`: 37 of 1141 → **91** with
  55 newly failing targets, every one of them from that change; it is the measurement behind
  "the general change is not the route" above.
- Full gate of THIS slice, `build/l2_harness/dk_k04c_full_02`: **36 of 1143** targets failed (K04b's
  committed result: 37 of 1141) — the two new rows OK, no newly failing target, and
  `unit_value_call_sub_refused` leaves the retained list (its needle now matches the refusal the
  translator gives). The remaining 36 are the retained failures unchanged by exact ID and diagnostic.
  Staged `l2trans.lm1` blob `5576e6f8` = the committed bytes. Kernel and L3 sources untouched.
- `python tools/check_docs.py` OK, `tools/gate_p0_header.ps1 -Root .` OK (47 P0 defines, 7 files),
  `git diff --check` clean.

**Found while measuring, recorded, not this slice.**
[CALLABLE-FORMAL-STATEMENT-CALL-INTERNAL](defects.md#callable-formal-statement-call-internal): a
standalone Frame of a known callable formal, `f()`, ended in `internal: a refusal said nothing`.
The 2026-10-01 note said a returning contract's standalone Frame already translated. The 2026-10-02
remeasurement does not support that: both the nonreturning and the returning standalone Frames fail
on blob `5576e6f8`. `return: f()` is result reception, a different context, and it does translate.
The repair is the next section.

**Residuals.** The parent defect
[SUB-ACTUAL-REFERENCE-CLASSIFICATION](defects.md#sub-actual-reference-classification) keeps its other
half: an ordinary REFERENCE formal receiving a callable, resolved paths, and the shared projection
into native and walker emission. Matrix rows 5 (the two nonprimitive formal spellings), 6 (an own
binding or path as the actual, with a shadowing formal) and 8 (the pointer-depth control) are not
measured here. `CALLABLE-FORMAL-HIDDEN-CONTRACT` remains untouched.

**Residuals (not this slice).** Matrix rows 3–8: the equivalent nullary forms (row 3), the returning
callable received as a reference and as a result (row 4), the two nonprimitive spellings (row 5), the
own-binding/path actual and the shadowing formal (row 6 — the resolver's next category), the ordinary
incompatible refusal for a nonreturning callable given a primitive formal (row 7), and the
pointer-depth control (row 8). The **walker** half: `l2_rw_call`'s callable-formal branch still accepts
only a unit method's atom (`a callable input that is not a method's name` otherwise), so a forwarded
formal is not walked; the rows above run natively and no walked route is claimed for them. The
`CALLABLE-FORMAL-HIDDEN-CONTRACT` defect (the callee's hidden inputs built from the required exemplar
rather than from the actual callable) is untouched here: this slice resolves the actual, it does not
rebuild the callee's free inputs from it.

<a id="k04d"></a>
## K04d — a standalone Frame of a known callable formal is the call

Landed with this slice. Emission only; the kernel and L3 sources are untouched.

On the unchanged bytes a standalone `f()` whose head is a callable formal took the formal-store
route: `l2_emit_stmts` saw `fi >= 0` and called `l2_eval_fields` on the empty argument list, and
`l2_eval_fields` returns 1 for `n <= 0` without a located diagnostic. The later call emission
requires `fi < 0`, so the formal never reached it. `l2_head_is_call` already knew the head was a
call. The repair clears the store targets when that common classifier says the head is a call, and
the existing discarded-call emission runs. An unknown `f()` is not a call under that classifier, so
it stays an empty named Structure. An ordinary pointer formal is not a callable formal, so this
does not invoke it. A no-result callable in a result position keeps its located refusal.

**Focused evidence**, not a full gate: `build/l2_harness/gk_formal_frame_03`, 10 targets, 0
failures. `unit_formal_frame_stmt` runs and says `m 1` once, entry 5. `unit_formal_frame_sub_stmt`
says `s 1` once, entry 0. Controls that stayed green: `unit_bare_in_method`,
`unit_callable_nullary_forms` (argument-position `task()` still does not execute),
`unit_callable_returning_two_contracts`, `unit_return_sub_refused`, `unit_void_value`.
Source blob of both runs: `9168b081`. The harness PE prefix of the full run is `E649E0BCA71BBC5E`.

**Full gate** `build/l2_harness/gk_formal_frame_full_01`: **36 of 1145** targets failed. K04c's
committed result was 36 of 1143. The two new rows are OK. The 36 names and diagnostics match
`build/l2_harness/dk_k04c_full_02` exactly; this slice adds no failure. Walker execution of these
rows is not claimed.

<a id="k04e"></a>
## K04e — an ordinary nonprimitive formal receives a no-result occurrence

Landed with this slice. Checker, schema, and native emission only. The kernel and L3 sources are
untouched. The stable `l2src/` twin is not promoted.

On the K04d bytes an ordinary nonprimitive formal did not take `l2_cf_actual`. A no-result method
fell through to `l2_check_value_call`. A returning method whose result model matches the formal was
accepted as a call. `@task` failed as an unresolved address; the occurrence spelling is the bare name.

The repair gives that occurrence a schema of its own fields (kind 3, handle at or below
`-1500000000`; `-1` alone is absent). Close-time admission walks the consumer's uses against those
fields. Native emission registers the occurrence with `lmx_implements_register_map` and does not call
it. A returning callable stays result reception. A number formal stays on the K04c phrase. Kind-2
forwarding of a formal is not this route. No descriptor registry, syntax branch, or automatic `@`
strip was added.

**Witnesses.**

- `unit_occ_descriptor_formal` — `Holder` has `other` then `mark`, so `mark` is not slot 0. `sub task`
  has `pad` then `mark` 4 and increments `hits`. `check` calls `task()` once, then `byColon(task)`,
  `byAt(task)`, and `byColon(task())`. Those three read 4 and leave `hits` at 1. One later `task()`
  makes `hits` 2. Entry 7.
- `unit_occ_descriptor_refused` — `take` reads `x\other` and `task` declares only `mark`. Refusal
  `unit_occ_descriptor_refused.lm2:17:13: implements is false in function argument`, frame `take`.

A translated control, not a harness row: a returning `make` passed to `(Holder: x)` is still
`lmx_call_prim` of `make`, and the call result is what the formal admits. That probe was not executed.

**Evidence.** Same staged blob `44e8e4e1b355e2ad81de86d9c1e2cab4d5e08c9f`.

- Focused `build/l2_harness/gk_occ_formal_02`: **5 targets, 0 failures**. PE prefix
  `ED03C26D78312ED5`. The line pin on the refusal was added after this run.
- Full gate `build/l2_harness/gk_occ_formal_full_01`: **36 of 1147** targets failed. K04d's committed
  result was 36 of 1145. Both new rows are OK, including the pinned needle. The 36 FAIL lines match
  `build/l2_harness/gk_formal_frame_full_01` exactly. PE prefix `B196EB56270DF440`. Walker execution
  of this row is not claimed.

**Residuals.** Matrix rows 6 and 8, paths, kind-2 forwarding through this schema, and the walker half
(`l2_rw_call` still accepts only a unit method's atom). `CALLABLE-FORMAL-HIDDEN-CONTRACT` is untouched.

<a id="k04f"></a>
## K04f — a path actual selects the callable field's occurrence

Landed with this slice. Resolution of the actual only. The kernel and L3 sources are untouched.
The stable `l2src/` twin is not promoted.

On the K04e bytes `l2_cf_actual` accepted one atom or one nullary frame. A value-position path
arrives as atoms around the separator, so `recv(Holder\other)` was span 3 and the callable formal
refused it. An own `int` of the method's spelling did not hide the unit method: the old emission
passed `lmx_arena_ref_struct` of that method.

The repair joins that span with `l2_join_path` and uses the text a frame head already carries.
A callable formal stays kind 2. Any other formal stays absent. A nearest binding
(`l2_colon_bound_ty` returns 0) hides a unit method of the same spelling. Otherwise
`l2_head_method` selects a bare method or a path whose leaf is a callable field. That field's
method is the occurrence, the shared terminal, emitted by the existing `l2_tok_method_occ`.
No descriptor registry, syntax branch, or automatic `@` strip was added.

**Witnesses.**

- `unit_occ_path_actual` — `task` adds 1, `other` adds 10, and `Holder` has `fn: other`. `recv`
  calls its formal once. `Holder\other` leaves `hits` at 10. `Holder\other()` leaves `hits` at 20.
  Entry 7. Generated L1 passes unit child 5 (`other`, `l2_m1`) into `recv` at child 6. It does not
  call `other` while transporting it. Child 4 is `task`.
- `unit_occ_own_shadow` — `int: task 4` is the nearest binding. Refusal
  `unit_occ_own_shadow.lm2:15:5: incompatible entry signature`, frame `recv`.

**Evidence.** Staged blob `a24cda703df5ac2bab775874d86a3c83263fa6c8`.

- Focused `build/l2_harness/gk_occ_path_03`: **11 targets, 0 failures**. PE prefix
  `9AA9F8F2CFEA5B16`. The line pin on the refusal was added after this run.
- Full gate `build/l2_harness/gk_occ_path_full_01`: **36 of 1149** targets failed. K04e's committed
  result was 36 of 1147. Both new rows are OK, including the pinned needle. The 36 FAIL lines match
  `build/l2_harness/gk_occ_formal_full_01` exactly. PE prefix `5EEE53F41DF1D7A9`. Walker execution
  of this row is not claimed.

**Residuals.** The explicit pointer sentence of row 6 is unmeasured: a valid pointer binding was
not shown to stay unexecuted merely because its referent is callable. `@: task` is not that
witness; it is an unknown type. Row 8 and the walker half remain open. Kind-2 forwarding is
unchanged. `CALLABLE-FORMAL-HIDDEN-CONTRACT` is untouched. The next code item is
[critical_graph_bug](tickets/critical_graph_bug.md), not row 8.
