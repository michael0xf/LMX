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
