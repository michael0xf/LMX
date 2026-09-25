# Root classes the translator can build alone (-196)

FABLE-OPUS-ROOT-CLASSES-20260926-196 (Opus): ticket (5) of steps/next-phase-195.md §7.
- Branch opus/root-classes-196, based on T2's head 0d981be (T2 was not integrated yet).
- Translator only: the walker's roles as they are.
- Each class group has its own commit and its own rows out of the 50 root-pending ones.

## Commits

G2 (878dee7): a string literal alone as a root statement makes no step, as natively
(`l2_eval_discard` drops it).
- The numeric literal statements stay LIT steps.
- Row: unit_bare_literal_stmt (0).

G3 (bdc1df0): root paths.
- A qualified (eternal) branch, read only, `E\deep\d` and `Frozen\value`.
  - AT(unit, its unit child `l2_unit_base + l2_occ_n() + branch`), then OF along the named
    Structures' field table.
  - A write is refused, located: «a qualified immutable branch is not written».
- A method's occurrence, `M\x` and `M\[N]x` (`l2_rw_path_occ`).
  - The last same-name own field, or occurrence N, that M uses: the same lookups as the native
    method-root branches of `l2_check_fields`.
  - A number, read by OF over AT(unit, `l2_unit_base + M`) and written by PUT into the occurrence
    at `l2_own_mslot`.
  - `l2_rw_path_run` joins the occurrence step `\[N]x` into the path run.
- A call through a path, `Holder\viaPath(4U)`: the general resolver (`l2_path_kind`, kind 4) gives
  the callable field's method, a shared terminal (Q22 = II), and the step is that method's CALL.
- Rows: unit_eternal_xref, unit_field_path_unit_qualified, unit_occ_root_field,
  unit_occ_root_named, unit_recursion (all 0).
  - Their root `return: V` tails became the exit letter (n159 tails.py: 10 in 4 files).
  - unit_recursion's stale Debt pins (from before c3, never checked while it was root-pending) now
    pin the direct-cell call.
- Mutants:
  - a qualified branch one unit child off: unit_field_path_unit_qualified gets X1;
  - an occurrence's own slot one off: both occurrence rows get X1.

G1 (8c73d15): `&&` / `||`, short-circuit, and root `while:`.
- The walker's IF has no value, and there is no sequence role.  So `a && b` is a flag cell of a
  plain holder h, written on both ways after a is known, and read by AT(h, 0):
  - `a && b` = IF(a, [b's flag steps, IF(b, [h: 1], [h: 0])], [h: 0]);
  - `a || b` = IF(a, [h: 1], [b's flag steps, IF(b, [h: 1], [h: 0])]).
- The IF is a flag STEP that runs before its statement.  `l2_rw_stmts` moves a statement's steps up
  and puts its flag steps in front (`l2_rw_pre_place`), in both passes.
- b's own flag steps go inside the way that runs b, so a nested short-circuit stays short-circuit.
- Writing both ways after a is evaluated keeps the cell right even if a or b recurses.
- The value is an int, each side typed on its own; a reference as a side is refused, located.
- `while: c` + body is WHILE(c, body).  The condition's flag steps run before the loop and again at
  the end of each turn of the body.  `for` / `until` stay refused.
- Rows:
  - unit_value_call_result, 7811: `a = 0 && m = 7` leaves m uncalled.  It is the fixture's own
    short-circuit witness.
  - unit_forward_oneline, 0: `||` in the exit code's value.
  - unit_next_message_loop, 0: `while: m != 0 && n < 5` over receiveMessage.
- Mutants:
  - `&&` running b when a is false: 7012;
  - `||` with its ways swapped: exit 1;
  - the while condition's flag steps not re-run: the loop never ends.

## Not in this ticket

- «an admission to a Structure type» (unit_empty_assign_admit, unit_empty_assign_named).
  - A correction to next-phase-195 §4: both rows catch the admission's `implements`
    (`catch: implements ()`), so they wait for the root CATCH role, not the translator.
  - They stay root-pending with their needle.
- The loop class's two other rows (unit_s1_catch_nested_while, unit_s1_catch_user_break) are catch
  rows.  With `while:` built, they now stop at their catch or break, and their needles are updated
  to that: «throw and catch», and «break and continue» (the walker has no break role).

Root-pending: 50 → 41 (9 rows flipped).
