# The take and Structure arguments at the walked root (-179)

FABLE-OPUS-ROOT-TAKE-20260925-179 (Opus; base origin/main ad9ff88, over Grok -177 c1-c3).  The
translator halves of the walker's take primitive and of a Structure argument passed by reference.

## Commit 1: `receiveMessage: m` and `m = 0` at the root

### What is built

- `receiveMessage: m` (l2_rw_take) is PUT [put, unit, m's cell, PRIM [prim, record]].
  - The record's fn is lmx_walk_mail_take (-177 c1).  It gives the current Thread's first letter's
    graph through `out`, or no value when the inbox is empty.
  - The PUT stores the graph by reference into m's pointer cell, or null: a PUT into a pointer cell
    admits null since -177 c1.
- `m = 0` / `m != 0` (and `0 = m`): a reference compared with 0 or with another reference.
  - It is the walker's EQ over the pointer cell (AT gives the cell; -177 c1 compares the address it
    holds) against LIT int 0.  `!=` is SUB(LIT 1, EQ) as for numbers.
- The static typing (l2_rw_tyof) gives a reference field its own type, 1000 and above.  A reference
  stands only:
  - beside 0 or another reference, in `=` / `!=`;
  - where its own type is asked (a formal of that type, commit 2).
  Elsewhere the refusal is located: «a reference where a number is asked», «a reference compared by
  order», «arithmetic on a reference», «a reference compared with a number other than 0».
- An assignment into a reference field is not built.
  - Of a declared Structure type it is an admission, the caller's implicit `implements` (D-55,
    Grok -177 c5): «an admission to a Structure type».
  - Untyped (a letter): «a reference assignment».
- `receiveMessage: m` into an m of a declared Structure type admits the letter first: «an admission
  to a Structure type».

### The rows (every row pending on the take, measured)

18 rows were pending on «receiveMessage needs the take primitive» (the 6 of -176 and 12 more since
-178 commit 2 built `Model: m`).  With the take built:

| row | now |
|---|---|
| unit_next_message_twice | eternal-runs; its tails were rewritten (3 returns); its pin moved from the native take to the walked one |
| unit_next_message_in_method | eternal-runs; the method takes the letter natively, and the root's take then finds none (tails: 2) |
| entry_argc | eternal-runs; an Argv row, run by the harness only (tails: 2) |
| unit_next_message_loop | root-pending «a loop» (`while:` at the root), then `&&` (-170) |
| unit_admit_letter_formal | root-pending «a call with an input that is not a number»: a letter passed to a `MainLetter` formal is an admission (D-55); tails: 1 |
| unit_admit_formal_refused | root-pending, the same (a letter to a `Model` formal) |
| unit_s1_catch_implements | root-pending, the same, then the catch role (-171) |
| unit_admit_letter_typed, _not_model, _extra_field, _coarse, entry_argc_if, entry_index, entry_strcmp, unit_charpp_return, unit_entry_args | root-pending «an admission to a Structure type»: the receive into a typed field (D-55) |
| unit_admit_rebind_refused, unit_admit_rebind_read | root-pending «an admission to a Structure type»: `m: raw`, a letter into a typed field (D-55) |

Also:
- unit_empty_assign_untyped is now at «a reference assignment» (`m()`, the empty Structure into a
  letter field).
- unit_empty_assign_admit is at «an admission to a Structure type» (`fresh()`).

### The letter's payload

The witness with one letter reads m != 0.  It does not read `m\payload`:
- The translator does not synthesize the letter's model (`sender`, `payload`) yet: that is Sonnet
  -172's receiving site, not on main.  So a path through a letter has no field table to resolve.
- The host's letter's payload holds only mainArgs, an Array, so there is no number to read at the
  root before the arrays roles either (-170).

### Witness

- unit_root_take_letter (Entry 1): the first take finds the host's letter, and m != 0.
- unit_root_take_empty (Entry 1): after a first take empties the box, the second gives null, and
  m = 0.
- Both pin the walked take (`\fn: lmx_walk_mail_take`).
- Mutant T1, the take not stored into m (the PRIM stands alone as a step, m stays null):
  unit_root_take_letter and unit_next_message_twice are RED.  The empty-box rows stay green, as
  they must: their m is null either way.
- Mutant T2, the reference test's polarity flipped: all four take rows are RED.

## Commit 2: a Structure argument by reference

### What is built

- A call's input whose formal is of a named Structure type (l2_nsty_get of the formal) takes a
  root own field of that same type.
- The CALL's input is DEREF(AT(unit, the field's cell)): the Structure the field holds, the very
  node.  So the callee receives the address of the caller's Structure, not a copy, and a write
  through the formal is the caller's (l2_rw_struct_arg).
- Refused, located:
  - an actual that is not such a field's name: «a Structure argument that is not a field's name»;
  - an actual of another type, or an untyped letter: «an admission to a Structure type» (the
    caller's implicit `implements` at the call, D-55).

### Rows

- eternal-runs:
  - unit_matrix_callable_struct_identity: `bump(m)`, `bump: m` and the vertical `bump:` each write
    `x\value` through the formal, and the caller reads 4U after them.  It pins the DEREF.
  - unit_field_path_terminal_checklist: `writer(a)`, whose checks are inside the callee.
- unit_admit_letter_formal, unit_admit_formal_refused and unit_s1_catch_implements move to «an
  admission to a Structure type»: a letter to a Structure formal.

### Witness

- Mutant C1, the argument passed as a fresh merge copy (PRIM lmx_walk_merge_model over the DEREF):
  unit_matrix_callable_struct_identity is RED (exit 90: bump's writes land in the copies).
- unit_field_path_terminal_checklist stays green under C1, as it must: it observes nothing on the
  caller's side.
