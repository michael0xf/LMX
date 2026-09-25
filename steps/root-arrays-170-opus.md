# -170, the translator half: arrays at the walked root (Opus)

Ticket: fable's answer, `steps/tickets-20260925.md` §6 («затем -170 трансляторная половина», plan
`steps/root-arrays-170.md` §6).  Branch `claude/continue-opus-next-doc-rvjocj`, base main `6b631a6`.

## Plan

The kernel roles on main (grok_bot -170 c2, `lmx_walk.lm1` :1603-:1711): ELEM `[elem, holder, slot,
index]`, ELEMPUT `[elemput, holder, slot, index, value]`, LENGTH `[length, holder, slot]`.  The
holder is a Structure by reference or 0 (this activation's data, K-OT2), NOT evaluated
(`lmx_walk_array_desc` :548); the index is a literal size cell, not evaluated.

- 5a, an own Array of the body (5 rows): `[]: T x n` is no step (the graph build makes the
  descriptor in the field's slot); `x[N]: v` → ELEMPUT(0, slot, N, v); `x[N]` → ELEM(0, slot, N).
- 5b, `length(m\mainArgs)` and `m\mainArgs[1][0]` (5 rows): the Array is a field of a Structure that
  exists only in R0's turn (m's pointee), or an element of another Array.  The roles take neither: a
  QUESTION below.

## RESULT (5a; 5b is the QUESTION)

Base main `6b631a6`; STARTED `9b52254`.

### l2trans.lm1

- `l2_rw_elem_of(t, @index)`: `x[N]` names an element of an own Array x of the body being built
  (`l2_own_index_head`, the native reader of the same spelling; N a decimal literal, `08` is 8) whose
  element type the roles take -- int, char, size_t, ulong (`l2_rw_elem_ty`: own storage 4, 5, 7, 37 →
  0, 1, 2, 36).  Holder and slot are the own field's, as AT has them (`l2_rw_cell`: holder 0 at the
  root, the unit's slot).
- `l2_rw_elem` → `ELEM [elem, 0, slot, N]`; `l2_rw_elemput` → `ELEMPUT [elemput, 0, slot, N, v]`, v
  built at the element's type (`l2_rw_texpr`), so `command[0]: 0` and `'\0'` are LIT char.
- `l2_rw_stmt`: `[]: T x n` of the body is no step when it is such an Array (3 fields, the slot of a
  field of the body); any other `[]:` keeps «an array».  `x[N]: v` is the ELEMPUT step.
- `l2_rw_operand` / `l2_rw_opty`: `x[N]` is an ELEM operand of the element's type.
- `l2_rw_path_run`: `x [ N ]` after a bare name (four P0 fields in an expression) is one operand, the
  atom `x[N]` a statement's head already is.

The same builder serves walked method bodies (`--walk-methods`); the corpus shows no method that
gets frames because of it (below).

### Rows

| Row | Before | Now |
|---|---|---|
| `entry_array` | root-pending «an array» | eternal-runs, Entry 7: `command[0]: 'a'` read back (82), then `0` read back (81) |
| `entry_nul` | root-pending «an array» | eternal-runs, Entry 7: the same with `'\0'` |
| `entry_array_leading_zero` | root-pending «an array» | eternal-runs, Entry 7: `values[08]: 1`, `values[8]` read back (81) |
| `unit_matrix_path_array_elem` | root-pending «an array» | eternal-runs, Entry 7 (its own checks 11, 12) |
| `unit_matrix_callable_array_elem` | root-pending «an array» | eternal-runs, Entry 7: an element as a call input, both call forms (11, 12) |

Each fixture's success was 0 (an empty witness by `steps/current.md`); now 7, and the two plain
stores read back what they wrote.  Debt pins: `c.LMX_WALK_OP_ELEMPUT, 5U)`, `c.LMX_WALK_OP_ELEM, 4U)`;
the three `entry_*` keep Absent `c.array`.  Inverted check (`entry 0`): red on all five.

Generated L1 (`unit_matrix_path_array_elem`: `buf[0]: 1`, `buf[1]: 2`, then `buf[1]` read):

```text
        @: Lmx l2_rw0 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_entry_unit, c.LMX_WALK_OP_ELEMPUT, 5U)
        if: lmx_walk_store_size(l2_program_arena, l2_rw0, 2U, 0U) != c.LMX_WALK_OK
        if: lmx_walk_store_size(l2_program_arena, l2_rw0, 3U, 0U) != c.LMX_WALK_OK
        @: Lmx l2_rw1 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_rw0, c.LMX_WALK_OP_LIT, 2U)
        ...
        @: Lmx l2_rw2 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_entry_unit, c.LMX_WALK_OP_ELEMPUT, 5U)
        if: lmx_walk_store_size(l2_program_arena, l2_rw2, 2U, 0U) != c.LMX_WALK_OK
        if: lmx_walk_store_size(l2_program_arena, l2_rw2, 3U, 1U) != c.LMX_WALK_OK
        ...
        @: Lmx l2_rw10 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_rw9, c.LMX_WALK_OP_ELEM, 4U)
        if: lmx_walk_store_size(l2_program_arena, l2_rw10, 2U, 0U) != c.LMX_WALK_OK
```

(holder slot 1 left 0; slot 2 the unit child 0, the Array; slot 3 the index.)

### Mutants (private l2trans variants)

| Mutant | What is mutated | Red rows |
|---|---|---|
| A1 | ELEMPUT writes index + 1 | all five: `entry_array` / `entry_nul` exit 82, `entry_array_leading_zero` 81, both matrix rows walk INVALID (the last index is out of bounds) |
| A2 | a char Array's element typed int | `entry_array`, `entry_nul`: l2trans «mixed numeric types» at `'a'`; `entry_array_leading_zero`: walk INVALID; the int-Array rows stay green, as they must |
| A3 | ELEM always reads index 0 | `entry_array_leading_zero` 81, `unit_matrix_callable_array_elem` 12, `unit_matrix_path_array_elem` 11; the two rows that only use index 0 stay green, as they must |

### Numbers (cloud)

- `python tools/build_l2src.py`: 174/230 (as main).  `check_docs` OK, `git diff --check` clean.
- Corpus (tracked `.lm2`, main `bcad1f0`'s l2trans against this branch, which also carries D-76): the
  outcome changes are the five rows here and D-76's three; the only other output change is D-76's
  (`unit_ns_ref_field_general`).  With `--walk-methods` exactly the same list: no method body changed.
- Private `windows.h` shim: harness 397/397.  Evidence; the machine gate decides.

## Вопросы fable

QUESTION FABLE-GROKBOT-ROOT-ARRAYS-20260926-170: the 5b rows need the Array as an evaluated operand
-- a kernel form for Sonnet?

- Rows: `unit_admit_rebind_read`, `entry_argc_if`, `entry_index`, `entry_strcmp`, `unit_entry_args`
  (needle «an array»).  All stop at `length(m\mainArgs)`; `entry_index` / `entry_strcmp` then need
  `m\mainArgs[1][0]` (an element of an element).
- `m` is `MainLetter: m` / `receiveMessage: m`: its Structure exists only in R0's turn (the letter), so
  the Array's holder is DEREF(AT(0, m's cell)) -- a VALUE, like PUT_OF's holder (D-54).  And
  `mainArgs[1]` is an element of a `char: []: []:` Array: the inner Array is in no Structure slot.
- The roles on main take the holder as a fixed reference or 0 and never evaluate it
  (`lmx_walk_array_desc`, `lmx_walk.lm1` :548-:571), so neither form is expressible.
- Proposal (the kernel owner's call): ELEM / LENGTH over an evaluated Array operand,
  `[length, array]` and `[elem, array, index]` where `array` is any node that evaluates to an Array
  descriptor (OF / DEREF / ELEM of an Array-of-Arrays) -- by the arena's classification
  (`LMX_KIND_ARRAY`), no translator numbers; or the `_OF` pair beside today's.  Then the translator
  builds `length(OF(DEREF(AT(0, m)), mainArgs))` and `ELEM(ELEM(OF(…), 1), 0)`.
- `entry_index` / `entry_strcmp` also pass `@ m\mainArgs[1][0]` (an address) to `c.puts` / a C call:
  the root-address class (Q7, a raw pointer at the root), not this question.
