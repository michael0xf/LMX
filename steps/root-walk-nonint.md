# The walked root's biggest pending class: values that are not an int (51 rows)

Measure-first note for Grok's first class ticket after -159 commit 2b (Opus, read-only; base
origin/main e9d76c9).  Line numbers are at that base.  "Read" means established by reading the code;
"measured" means observed on a translator or harness run.

## The rows (measured: the 2b classification)

51 rows are refused «root operation not walkable yet: a value that is not an int».  The refused line
decides the sub-class:

| sub-class | rows | refused line, e.g. |
|---|---|---|
| a Structure-typed root field: `Model: m`, `MainLetter: m`, `Outer: o`, `P: q` ... | 26 | `entry_argc_if.lm2:8 MainLetter: m` |
| a `size_t` root field | 22 | `unit_addr_arg.lm2:15 size_t: got` |
| an empty-frame declaration of a Structure-typed field: `S()`, `E()` | 2 | `unit_empty_assign_named.lm2:9 S()` |
| a `char` root field | 1 | `unit_char_own_publish.lm2:23 char: mark 'a'` |

31 of the 51 still hold a root `return: V`.  2b's tail rewrite (n159/tails.py) reaches a root
`return:` only past the refusals, and these fail earlier.  When the class is built, n159/tails.py must
be rerun on its rows: otherwise they turn «return with a value at the root».  Counted over all 122
root-pending rows: 36 (31 of this class, 4 nextMessage, 1 a Structure value).

## What the translator refuses, and where (read)

- `l2trans.lm1:16337` (l2_rw_own_row): a read or an assignment of a root field whose own type is not
  int (`l2_own_ty[oi] != 0`).
- `l2trans.lm1:16900` and `:16913`: a declaration whose type word is not `int`, or whose own row is
  not int.
- A Structure-typed declaration `Model: m` reaches l2_rw_own_row through the normalized colon form:
  m's own row has a graph type.

## What the unit holds for these fields (read: the builder, l2trans.lm1:~20008-20020)

Every root field is a typed cell in the unit's own child slot:

| type | cell |
|---|---|
| int (ty 0) | `lmx_int_new_owned` |
| char (ty 1) | a cell of the unit's char pool, `lmx_char_cell_known(process_chars, 0)` |
| size_t (ty 2) | `lmx_size_new_owned` |
| unsigned (ty 3) | `lmx_unsigned_new_owned` |
| ulong (ty 36) | `lmx_ulong_new_owned` |
| a graph type: `Model: m`, a letter model | `lmx_pointer_new_owned(c.LMX_TYPE_POINTER_BASE + id)`, a pointer cell holding the Structure's reference |

The walker is therefore handed a typed cell per field.

## What the walker does with a value today (read, lmx_walk.lm1)

The walker is int-only at every value site:

- LIT: an int (`lmx_walk_store_int`).  `lmx_walk_store_size` exists, but only for the size
  operands of a node, i.e. a slot number (`:208`, `:304`).
- OWN/SET: the activation's working copy is `LmxWalkOwn {from; int value; dirty}`
  (`lmx_walk.h.lm1:231`).  It is loaded by `lmx_int_value_known(from[0])` (`:412`, `:1215`) and published
  by `lmx_int_store_known(o\from[0], o\value)` (`:573`).
- AT: `\out: slot[0]`, the cell's own address, whatever its type (`:859`).
- PUT: `lmx_int_store_known(slot[0], lmx_int_value_known(value))` (`:884`).  This writes 4 bytes into
  whatever cell the field holds:
  - into a `size_t` cell it writes the low half only, and the high half keeps its old contents;
  - into a pointer cell it corrupts the reference.
  This is not refused.
- ADD/SUB/LT/EQ: both operands are read as int, and the result is an int (`:903`-`:921`).
- IF/WHILE: the condition is read as int (`:930`, `:940`).
- OF: `m\f` requires the operand value to be a Structure (`:866`).  AT on a Structure-typed field
  yields its pointer cell (kind PRIMITIVE, type POINTER_BASE + id), so `m\f` is refused INVALID.
- There is no merge role.  PRIM calls a primitive record `{fn, signature, owner}` with the evaluated
  inputs (`:751`); 2b's l2_send<k> uses it.
- The dispatch's return value: an int cell only (`:187`).

So the translator's refusal is the right answer today.  Building these fields as AT/PUT would compile
and run, and be silently wrong: a `size_t` above 2^31 or after a wider value, and any pointer cell.

## What the class needs (proposal for the ticket)

### A. Typed numeric values: size_t (22) and char (1)

unsigned and ulong come with it: no row needs them yet.

Walker:
- A value's C type is its cell's, asked of the arena (`lmx_domain_type`).  The value carries no tag.
- LIT: a store per type, or the LIT takes the type of the cell it is built with.  `lmx_walk_store_size`
  already exists; add unsigned, ulong and char.
- OWN/SET working copy: widen `LmxWalkOwn.value` to the widest numeric (`ulong` / `size_t`).  Load and
  publish through the cell's type.
- PUT and SET: store through the target cell's type.  An operand of another type is INVALID: the
  translator makes operands agree.
- ADD/SUB/LT/EQ: both operands of one type, and the result is a scratch cell of that type (LT/EQ
  results stay int).  Mixed types are INVALID.
- IF/WHILE: true when nonzero, for any numeric type.
- Unchanged: the dispatch return value (the exit is the host's now, not the walk's value).

Translator (l2_rw_*):
- A literal takes its type from its context: the typed field it is assigned to, or the other operand.
  For example, `got != 99U` with `got` a `size_t` becomes LIT size_t 99.
- l2_rw_own_row admits ty 1/2/3/36.  The declarations admit `size_t`/`char`/`unsigned`/`ulong`.
- Mixed types are refused, located, until a conversion role exists.  Author Q24/D-48's
  mixed-occurrence conversion is its own ticket.

Witness rows: the 22 `size_t` rows plus `unit_char_own_publish`, each after its tail rewrite.

### B. Structure-typed fields (26 + the 2 empty-frame declarations)

Walker:
- Read: a role that yields the Structure a pointer cell holds (AT through the reference), so OF can
  follow `m\f`.  AT itself stays the cell's address: PUT and the checkpoint need it.
- Write: store a reference into a pointer cell, checked against the cell's pointer type (a PUT of a
  reference).
- Create: `Model: m` is `merge(Model, empty)` (L2 spec §13, the contextual `left: right` rule).  The
  walker has no merge.  The smallest door is a PRIM record for a kernel merge primitive over
  `lmx_merge_owned` / `lmx_merge_profiles_owned`, with the model as input and the new Structure in
  `dest`.  That is one registered kernel primitive, not per-site generated code.  The model operand
  is the named Structure's own unit field: named Structures are unit fields whose node is the unit.
- Admission (`m: v` of a graph into a typed field, `l2_emit_admit`) is `implements`.  The rows
  `unit_admit_*` counted here need the implements class too, and flip only when both land.

Translator:
- `Model: m` becomes the PRIM merge node plus the reference PUT into m's pointer cell.
- A read `m\f` becomes OF over the deref role.
- The empty-frame declarations `S()` / `E()` declare the field and leave it empty: no step.

Witness rows: rows whose root uses only these forms, for example `unit_colon_model_decl`,
`unit_field_path_unit_colon`, `unit_struct_int_field`, `unit_model_fresh_synonyms`.  Rows that also
use `nextMessage` (`entry_argc_if`, `entry_index`, `entry_strcmp`, `unit_entry_args`, ...) flip with
the nextMessage class (8 rows, after Sonnet's receiveMessage rename).

### Order

A first: it is self-contained in the walker's value sites.  B depends on A's typed-cell reading for
its pointer cells, and on a merge primitive.  Both are Grok's files (lmx_walk.lm1, lmx_walk.h.lm1).
The translator's side of each (l2_rw_*) is small once the roles exist.

## Status after part A (-167 walker; -175 translator)

Built (FABLE-OPUS-ROOT-TYPED-20260925-175, l2trans.lm1 `l2_rw_*`):
- Numeric root fields: int, char, size_t, unsigned, ulong.  They are declared with or without an
  initializer, assigned and read.
- The static type of every root expression (`l2_rw_tyof`).  A literal takes the type of its place:
  a decimal, a `U` literal only in an unsigned type, a char literal as its byte.  Two types in one
  operation, or in one place, are refused: «mixed numeric types (a conversion)».
- A call's inputs are typed by their formals, as the trampoline reads them.  A call's result is
  still an int only.
- The refusals now name what a non-number is: «a Structure-typed field» (`Model: m`, and a read of
  such a field), «an array», «a value that is not a number».

Rows (split eternal-runs 97 -> 101, root-pending 97 -> 92, l2trans-refuses 119 -> 121):
- Run:
  - `unit_node_root_unit_field`, after its tail rewrite;
  - `unit_arg_addr_types`;
  - `unit_sizeof_own_local`;
  - the new `unit_root_typed_numerics` (Entry 63).
- Refused for good: `unit_char_own_publish` and `unit_own_find_last_sizeof` reach «L2 operation
  outside a method body» (`c.printf`, `sizeof:` at the root).
- Still pending (all root-pending rows with these needles), each at its next gap:
  - 28 on «a Structure-typed field»: part B, Grok -174;
  - 9 on «a call whose result is not an int»: a size_t call result;
  - 5 on «a field path»;
  - 5 on «a Structure value» (merge);
  - 4 on «a call with an input that is not a number» (pointer or Structure inputs);
  - 1 on «mixed numeric types (a conversion)»: `unit_addr_arg`, `got: go(0U)` with an int `go`.

What the size_t call results need from the walker: CALL writes the trampoline's result into the
evaluator's destination, an int temp (4 bytes).  A size_t result would overrun it.  The CALL needs
a destination of the callee's result type, for example a fresh cell of that type as
`lmx_walk_arith_out` makes for + and -.

Walker defects found on the way, with probe fixtures and no harness rows yet (Grok registers them
with the fix):
- D-50: an int LT compares unsigned (`unit_walk_int_lt_negative.lm2`, Entry 1).
- D-51: the working width is `ulong`, 32 bits on LLP64, and truncates size_t
  (`unit_walk_size_t_wide.lm2`, Entry 2).
