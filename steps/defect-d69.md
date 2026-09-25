# D-69: a char formal's cell in the method's `args` part

Ticket: fable's answer, `steps/tickets-20260925.md` §9 («Пока: D-69»).  Branch
`claude/continue-opus-next-doc-rvjocj`, base main `af173de`.

## What and why

`l2_emit_parts` gives each formal its typed cell in the `args` part (-189 c4, form A); a char formal's
cell is `lmx_char_cell_known(process_chars, 0)`, the program's interned char cell, as an own char
field's is.  But the table (`@: char process_chars lmx_chars_new_owned(l2_program_arena)`) and the
predef `lmx_chars_owned.h.lm1` were emitted only for an own char field or a char field of a named
Structure (`l2_has_own_ty(1) || l2_ns_has_char`), so a program whose only char is a formal did not
compile (gcc: `lmx_char_cell_known` implicit, `process_chars` undeclared).

Fix: `l2_parts_have_char()` -- a method (not E) with a char formal whose cell `l2_emit_parts` makes
(not a callable formal, not a Structure formal), or a char result cell -- joins both conditions.  One
rule for every char cell: where the program makes one, it has the table.

A method's char RESULT (`fn: first (char: c) char`) is refused before this («unknown type» at the
result word): not D-69; the `return`-part branch of `l2_parts_have_char` is there for the day it
translates.

## RESULT

- Row `unit_char_formal_parts` (new, eternal-runs, Entry 7): `lo(5U, 'a')` reads its char formal
  (5), `lo(5U, 'b')` (0).  Also green under `--walk-methods` (measured with the private runner; the
  row is the plain one).  Main `af173de`: gcc refuses, both undeclared.  Debt: the predef, the table,
  the formal's cell `l2_entry_slot[0]: lmx_char_cell_known(process_chars, 0)`.  Inverted check red.
- Mutants: D69a (the table not emitted for parts) → gcc «'process_chars' undeclared»; D69b (the char
  formal not seen) → gcc, both undeclared.
- Corpus (644 tracked `.lm2`, main's l2trans against this one): no outcome change; one output
  change, `dev/l2src_sandbox/parser_text_predicates.lm2` (char formals only): it gains the predef and
  the table -- the same defect, fixed there too.
- Cloud: `build_l2src.py` 174/230, check_docs OK; private shim: harness 398/398.  Machine GATE? pending.
