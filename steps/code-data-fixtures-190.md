# FABLE-SONNET-FIXTURE-INVENTORY-20260925-190: harness fixtures asserting the old working-copy/checkpoint model

Read-only. Base origin/main `14472de`. Re-read `next_core_tasks.md` §3 "Пара исполнения code/data"
(current text, Q27.1 resolved), `docs/LMX_semantics.ru.md` §11–12, `docs/L2_spec_ru.md` §10 before
this pass. No fixture, `l2trans.lm1`, or kernel file touched; no gate run.

## The mechanism being replaced, in one paragraph

Today: a declared own field has a canonical local cell (the working copy) and a graph slot (the
published field); a bare name always reads/writes the local cell; an explicit path (`M\x`) always
reads/writes the graph slot directly; the two reconcile only at a **checkpoint** (before a call,
before return, before certain boundaries), which publishes the local over the graph if the field is
`dirty`, or — once `@x` has been evaluated on that name in this activation — **unconditionally**,
every checkpoint from that point on (`sticky`), even clobbering an explicit graph write that landed
between two checkpoints. §3's new model removes the local/graph distinction entirely for an own
field of the **current activation**: an assignment writes the data instance's own slot directly,
period, so a bare name and an explicit path to the *same* field are now the *same storage* with no
reconciliation step at all. `M\x` from **outside**, after the call returns, is unaffected in
principle (§3 point 4 keeps "the parent's slot holds the last created instance" as a *feature*, not
a bug) — what disappears is only the *within-one-activation* staleness window between a bare read
and an explicit-path write/read of the same name.

## Method used

Fixtures listed in §5's own audit trail (`unit_arg_addr_{sticky,types,pointer,dynamic,dyn_types,
dyn_nocell,ordinary}.lm2`) plus the families named in the ticket (`unit_occ_*`, `unit_node_path*`,
`unit_forj_*`), each read against its current `tools/l2_harness.ps1` row (`Says`, or the harness's
own pass/fail shape for refusal rows) and against the new model's own text. "Unchanged" means the
*observable* `Says`/`Entry`/refusal text should not move; a predicted new value is given where it
should. Confidence is stated explicitly where the model's own text does not settle the case.

## Per-fixture table

| File | Current Says (or refusal) | Prediction | Why (§3/§12) |
| --- | --- | --- | --- |
| `unit_forj_parent.lm2` | `9` | **Unchanged** | Single activation, one write path (`acc: j` inside the `for`'s own nested field container, `test`'s own data instance) — no bare/explicit divergence exists to remove. |
| `unit_forj_sib.lm2` | (no Says, exit 0) | **Unchanged** | Two textually distinct `for` statements get two distinct nested field containers in the prototype (§3.2, "M\for\y remains the same path") — independent of the storage-cell mechanism being removed. |
| `unit_forj_stale.lm2` | `9`, `9 42` | **Changes to `9`, `42 42`** | This fixture's whole point is the bare/explicit divergence the new model deletes: `for\j: 42` (explicit path) and the immediately-following bare `j` (same activation, no call boundary) are, under §12's new text ("assignment... writes into this field directly, no working copies, no dirty mark"), the *same storage*. High confidence — this is the single most direct case in the set. |
| `unit_occ_arg_slots.lm2` | (checks `\[0]arg=1`, `\[1]arg=2`) | **Unchanged** | Tests occurrence *indexing* (§4, Q22.2/Q24 — a repeated bound assignment is a new occurrence/slot), a separate mechanism from checkpoint/dirty; not superseded by §3. |
| `unit_occ_self_field.lm2` (`probe`) | asserts `v` stays `3U` after `probe\v: 9U` (own file's `return: 95/96` on failure) | **The assertion itself inverts** — see below | `v` is a declared own field of `probe`'s own data instance (`size_t: v 3U`); `probe\v: 9U` is an explicit path to that same field, from *within the same activation*. Under the new model this is the same storage, so the bare `v` should read `9U`, not stay `3U` — the fixture's current success condition (`v` unchanged) is exactly the staleness the new model removes. **Medium confidence on the mechanism, low confidence on the exact new Entry/exit value**: this fixture predates the root-walk migration (header cites -121, no `sendMessage: exit`, a bare `return: probe()` at root) and I did not run it, so I can't state today's actual observed exit code with certainty — flagging for a run-based check rather than guessing a number. |
| `unit_node_path_nested_own.lm2` | exit 0 (checks `shared = 11` after `node\shared: 11` from nested `if`/`if`) | **Unchanged** | `node\x` targets the *lexical parent's* data instance (root/unit here), not the current activation's own field — §3.3's Pascal-parent chain, and §12's "this outer field changes only by explicit path write" — both models already treat this as a plain explicit write with no caching in between; nothing here exercises the current-activation staleness window. |
| `unit_occ_root_field.lm2` (`bump`) | exit 0 (`bump\val` reads `3U` then, after an external `bump\val: 9U`, reads `9U`) | **Unchanged** | This is *exactly* §3 point 4's kept behavior: "the parent's slot holds the last created instance; `M\x` from outside, after the call, reads it." `val` is an ordinary declared field, not bump's *result* (bump returns `int`, unrelated to `val`) — so this is the positive case the new model explicitly preserves, not the negative case it removes. |
| `unit_occ_root_named.lm2` | asserts `test\[0]arg = 2`, `test\[1]arg = 2`, `test\arg = 2` (exit codes 81/82/83 on failure) | **Contradicts a sibling fixture — flagged, not a confident number** | This fixture's own comment states the *mechanism*, not just the outcome: "an argument-bound field has no independent per-occurrence graph value... checkpoint publishes EVERY occurrence row... from the ONE CANONICAL PARAMETER CELL" — i.e. it depends explicitly on the very "one canonical cell, published on checkpoint" machinery §3/§12 remove. `unit_occ_arg_slots.lm2`, in the *same* family, establishes that two bare assignments to a formal (`arg: 1` then `arg: 2`) are two *physically distinct* occurrence slots when read from *inside* the same activation (`\[0]arg=1`, `\[1]arg=2`). Once there is no canonical-cell republish step forcing every occurrence row to the same final value, I'd expect `test\[0]arg` and `test\[1]arg`, read from *outside* after the call, to show their own distinct written values (`1`, `2`) rather than both collapsing to `2` — but I am not fully confident the "one canonical cell" behavior wasn't *also* deliberately-kept API surface (as opposed to an accident of the old mechanism), so I'm reporting the contradiction rather than asserting the new Says line. Needs an author/implementer call, not a guess. |
| `unit_occ_root_out_of_range_refused.lm2` | refuses `test\[2]arg` (only 2 occurrences exist) as a located error | **Unchanged** | Range-checking the occurrence count is a static/lexical fact (how many times `arg` was assigned in the source), independent of which storage mechanism backs each occurrence. |
| `unit_arg_addr_sticky.lm2` | `Says` — see full list in the harness row | **Bound-case lines unchanged; "B" lines (unbound formal + explicit write) are an open question** | Every *bound* pair (A1–A4, C1–C3, D0/D1, E) already shows a converged pair today (sticky republish forces it) — under the new model the same convergence happens for a *different* reason (direct single-storage write), so the printed numbers don't move. The three `B 5 100` lines (`never_bound`, `go = 0`: address taken via `poke5(@: nb)`, then `never_bound\nb: 100` explicit write, *no bare/declaration binding ever runs*) are the family's clearest instance of the deeper open question below. |
| `unit_arg_addr_types.lm2` | `U 51 51`, `Z local 71`, `Z graph 71`, `L local 81`, `L graph 81` | **Unchanged** | Every case here is bound before its address is taken (per the file's own header) — already fully converged pairs, no unbound-formal path-write case present. |
| `unit_arg_addr_pointer.lm2` | `P local is null` | **Unchanged** | Single bound pointer parameter, no bare/explicit divergence exercised. |
| `unit_arg_addr_dynamic.lm2` | `IA1..IA4`/`ZA1..ZA4` converged; `IB 5 100` (×3), `ZB 5 100` (×3), `IB+`/`ZB+` converged; `CALLER 3 3 3 3 3 3` | **Same shape as `unit_arg_addr_sticky.lm2`**: bound lines unchanged, `IB`/`ZB` lines are the same open question (this is one of the three rows the ticket names explicitly) | Structurally identical to `never_bound` above, just for a dynamic (hidden) input instead of a declared formal. |
| `unit_arg_addr_dyn_types.lm2` | `W 3`, `U1/U2/L1/L2/F1/F2` converged, `DP local is null`, `DP caller keeps its pointer`, `FC 3`, `TC 3 3 3` | **Unchanged** | `DP`/`FC`/`TC`/`W` exercise the "no value cell" boundary (`unit_arg_addr_dyn_nocell.lm2`'s own mechanism) and type-code plumbing, not checkpoint/dirty; the bound `U*/L*/F*` pairs are already converged, same as `types.lm2`. |
| `unit_arg_addr_ordinary.lm2` | `OC1 4 4`, `OC2 9 9`, `OC3 9 9`, `OE 6 6`, `OD1 4 4`, `OD2 9 9`, `OD3 9 9` | **Unchanged** | File's own comment: every address here is taken *after* the binding line, so every pair is already converged; nothing here depends on sticky-republish overriding a later explicit write. |
| `unit_arg_addr_dyn_nocell.lm2` | refuses: "dynamic input type has no value cell" | **Unchanged** | About whether a *type* (`c.LmP0Text`, by value) can be a dynamic input at all — orthogonal to which storage model backs a value that *does* have a cell. |
| `unit_occ_sticky_selector.lm2` | `BEFORE 1 1`, `AFTER 9 9`, `NONE 7 100` (×2), `NONE+ 1 1` | **`BEFORE`/`AFTER` change value (still converged, new number); `NONE+` unchanged; `NONE` is the same open question (the ticket's third named row)** | `BEFORE`: sticky republish currently forces the graph back to the *local's* value (`1`) even after `before\ba: 100` writes it explicit — under direct-write, the *last* write wins outright, and `before\ba: 100` runs *after* `ba: 1`, so the converged value should become `100`, not `1`: predict `BEFORE 100 100`. `AFTER`: `poke9(@: af)` writes `9` through the pointer, then `after\af: 100` writes explicitly *after* it — under direct-write the last write (`100`) wins: predict `AFTER 100 100`. Both are a **value change on an already-converged pair**, worth flagging separately from the plain "stays converged" cases above. `NONE` (`none`, `go = 0`): `nn` is never bare-bound in this run; same open question as `unit_arg_addr_sticky.lm2`'s "B" lines. `NONE+` (`go = 1`, after `int: nn` / `nn: 1` actually runs): a bound case, converges either way — unchanged at `1 1`. |
| `unit_occ_snapshot_selector.lm2` | `BETWEEN 2`, `LAST 9` | **Needs the same re-check as occ_root_named, not a confident unchanged** | This file's own header says it deliberately uses the `\[N]x` snapshot selector *because* occurrence 0 of an assignment-only field isn't reachable through a method-name path root — i.e. it is *explicitly* testing per-occurrence snapshots of a repeatedly-*bare-assigned* (not argument-aliased) field (`between`: `bt:1` then `bt:2`, `\[0]bt`/`\[1]bt` read *from inside*, after further mutation through `@`). This is closer to `unit_occ_arg_slots.lm2`'s shape (distinct slots, read from inside, no argument-canonical-cell collapse) than to `unit_occ_root_named.lm2`'s (read from *outside* after return) — so I lean **unchanged**, but flag it alongside `occ_root_named` since both hinge on exactly how occurrence slots and the "one canonical cell" idea interact, and I'd rather the two be checked together than assert this one confidently in isolation. |

## (a) The three explicitly named "local ≠ graph" rows

`unit_arg_addr_sticky.lm2` `B 5 100`, `unit_arg_addr_dynamic.lm2` `IB`/`ZB 5 100`,
`unit_occ_sticky_selector.lm2` `NONE 7 100` are the *same* scenario three times: a formal or
dynamic input whose address is taken (`@: x`) and which is explicitly written via a method-name
path (`M\x: 100`), but which **never** goes through a bare assignment/re-declaration in this
activation — so under today's rule it never "binds," sticky-republish never activates, and the bare
name keeps showing whatever the address-taking call itself wrote (`5`/`7`), independent of and
un-synced with the explicit `100`.

This is the one place in the whole survey where I could **not** settle on a confident predicted
value, because the new model's own text cuts both ways depending on a question it doesn't answer
directly: **does an unreified formal have a data-prototype field at all for `M\x` to address?**

- §3.2: "аргумент становится полем прототипа ТОЛЬКО по правилу §12 (голое присваивание) ИЛИ
  merge" — read strictly, an argument that is *never* bare-assigned in this run is *not* a
  prototype field, so `M\x: 100` would have nothing to target — a **static "no such field"
  refusal**, not a value at all (unlike today, where the own-table registration is apparently eager
  enough that the graph slot exists regardless of whether any assignment ever executes).
- Alternatively, since prototype layout is fixed at *translation* time ("Трансляция уже
  зафиксировала раскладку прототипа", §12) from the *lexical presence* of a binding line anywhere
  in the method (even one that, at runtime, is never reached), the field could exist structurally
  the same way it does today, and `M\x: 100` would write it directly — in which case the *bare*
  name `x`, reading the untouched machine-activation argument value, and the *explicit path*,
  reading the just-written prototype field, are **legitimately two different storages** even under
  the new model (the argument itself is never promoted), and the divergence (`5`/`7` vs `100`)
  would be **correct, not a staleness bug** — i.e. genuinely unchanged.

I lean toward the second reading (unchanged) being more consistent with §3.2's own "becomes a field
only by §12 or merge" wording taken as a description of *write* semantics rather than *existence*,
but I would not commit code to that guess. Recommend this be the first thing whoever implements
-188/-189 resolves explicitly, since all three rows the ticket named land on exactly this question.

## (b) Fields whose declaration didn't execute this activation (untaken branch)

Searched the full fixture set for a case that reads an occurrence/path field whose *own*
declaration is inside a conditional that a *specific* activation skipped, where a **different,
earlier** activation of the same method *did* execute that declaration (i.e. a case that could
currently — by implementation accident — show the *prior* activation's leftover value instead of
the prototype's own fresh default). I did not find one. `unit_occ_sticky_selector.lm2`'s `none`
comes closest structurally (an `if: go = 0 / return` before `int: nn` / `nn: 1`), but its two calls
(`none(3, 0)` then `none(3, 1)`) never put a *written* occurrence-1 value in play before the
skipping call runs, so nothing today distinguishes "fresh prototype default" from "leftover from
nowhere" for that field. This looks like a genuine coverage gap, not a fixture I'm predicting a new
value for — matches the ticket's own §3 point 7 framing ("measure at landing, don't hide it"): I'd
flag it as something to add a fixture for once -188/-189 land, rather than something today's suite
already pins one way or the other.

## (c) Results read through the occurrence slot after recursion

Searched the fixture set for a self-recursive method (a body calling its own name) combined with
reading its *result* — as opposed to an ordinary declared field, which `unit_occ_root_field.lm2`
already covers and §3 point 4 explicitly keeps working — through the occurrence/path mechanism
after the call returns. Found none: no fixture in `dev/l2src_sandbox/tests` calls itself. §3 point 4
is explicit that this should be refused by design ("результат через слот не читается" — `fn`
returns a value through the ordinary machine-activation channel, not a field), so there is nothing
here to contradict; it's simply untested today. Same recommendation as (b): worth a fixture once
-188/-189 land, both for the ordinary case (confirm it still isn't read through the slot) and for
recursion specifically (confirm each activation's own frame, not the slot, is what a recursive call
sees for its own locals — the semantics doc's own trace, §12 "Стек активаций, рекурсия").

## Summary

Of 18 fixtures reviewed: 10 unchanged (mechanism changes, observable output does not);
2 unambiguous value changes (`unit_forj_stale.lm2`, and `unit_occ_sticky_selector.lm2`'s
`BEFORE`/`AFTER` lines); 1 fixture whose success condition inverts (`unit_occ_self_field.lm2`,
exact new value not run-confirmed); 1 fixture in direct contradiction with a sibling
(`unit_occ_root_named.lm2` vs `unit_occ_arg_slots.lm2`) needing an author/implementer call, plus one
more flagged alongside it for the same reason (`unit_occ_snapshot_selector.lm2`); 3 rows (the
ticket's own named set, part (a)) hinging on one unresolved question about whether an unreified
formal has a prototype field at all. Parts (b) and (c) are coverage gaps, not existing pins —
recommend new fixtures once -188/-189 land rather than guessed predictions against nothing.
