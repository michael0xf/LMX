# The walked root's anonymous-block class (7 rows) and arrays class (5 rows)

Measure-first note for the tickets after -159 (Opus, read-only; base origin/main aad12b2).  Line
numbers are at that base.  "Read" means established by reading the code or the book; "measured"
means observed on a translator build in scratch (n159/blk*, n159/tlp: the root-walk refusal made to
print and continue, so every gap of a row shows, not only its first).

## Anonymous blocks: 7 rows

### What a statement-position Structure is (read)

A statement-position Structure is either a `---` block or a `( ... )` container: `(f)`, `(2 + 2)`,
`()`, and the vertical `( . f )`.  The native emission (l2trans.lm1:18382) makes it a nested
executable body, like an if body (§14, Q14 K):
- it emits `if: 1` plus the body;
- an inert one (`()`, `(2 + 2)`: l2_body_inert) emits nothing.

The root walk refused it (`l2trans.lm1:16890`, «an anonymous block») until -169, which builds it as
below (FABLE-OPUS-ROOT-BLOCKS-20260925-169).  The walker has no block role.  Its IF role already
runs a plain Structure body (`lmx_walk_plain`), the root's `if`/`else` bodies being built that way.
A plain body stored as a step on its own does not run: its parent is the body, so the walker's G3
(`lmx_walk.lm1:1089`) passes over it as a declaration (-169's mutant).

### Measured: a block built as IF(LIT 1, body)

With the translator alone, and no kernel change:
- `unit_discard_forms` runs green (Entry 3: `f`, `(f)` and `( . f )` each call f once).
- `unit_discard_codex` next needs `* / %` (`2 * 2` inside its vertical container).

The 5 S1 rows are catch rows.  Their blocks are catch scopes:

| row | what else it needs (every gap, measured) |
|---|---|
| unit_s1_catch_declared_vs_merge | catch in both blocks (Oops and merge) |
| unit_s1_catch_declared_vs_merge_ok | catch in both blocks |
| unit_s1_catch_sibling | catch in a block and at the root |
| unit_s1_catch_rethrow | catch in a block and at the root, `*` |
| unit_s1_catch_nested_while | a loop, catch in the block, `*` |

`unit_s1_catch_publish` (root-pending «throw and catch» since commit 3) needs a catch at the root
body itself.  K5 (9 rows) is this set plus the admission rows.

So the block itself is small: IF(LIT 1, body) today, or a SEQ role if a catch scope wants a node of
its own (below).  The class's weight is the catch role.

### What a catch needs from the walker (read: the book, LMX_semantics §exceptions, :491-499)

- `catch` is a landing pad in its block.  It is skipped on the straight-line pass.
- When the failure arrives, the pad's body runs, and execution continues with the statements
  after that `catch`.  A pad before a call re-enters the following region.
- The pad covers every call of its block, including calls from blocks nested inside it (`if`,
  `while`, `for`, `---`).  A sibling block is not covered.
- Two same-named pads cannot compete at one level.
- An implicit failure (`merge`, `implements`) may be caught the same way.  Uncaught, it flies to
  the Message's root and the Thread stops: what commit 3 builds today.
- The pad's parameters receive the payload.

In walker terms:
1. A PAD step: skipped when reached in order.  It holds its parameter cells (hosted in its block)
   and its body.
2. Where a throw lands.  A throw number k is the callee's own (S1.1: declared 1..d, implicit d+g),
   so which pad a throw reaches depends on the call site.  The translator resolves it statically:
   for each call, each of the callee's names maps to the nearest covering pad in the enclosing blocks
   of the same activation, or to none (uncaught).  The CALL node needs that per-site table, k -> pad,
   by reference.  Both slices of this per-site mapping coincide at the root.
3. The transfer.  When a CALL gets `LMX_WALK_THROWN + k`:
   - with no pad for k, the walk stops as today (uncaught);
   - with a pad, the walk unwinds the nested bodies it is in up to the pad's block, binds the thrown
     record's payload fields to the pad's parameter cells by position (`out` is the thrown record),
     runs the pad's body, then continues with the step after the pad in that block.
   This is non-local control inside one activation, like a `break` that also lands.
4. At the root, the unit's own body is a block with pads (`unit_s1_catch_sibling`,
   `unit_s1_catch_rethrow`, `unit_s1_catch_publish`).

The translator then builds:
- the PAD steps and their parameters (own cells of the block);
- the per-site table on each CALL;
- blocks as IF(LIT 1, body) or SEQ.
The refusal «throw and catch» goes, and `throw:` at the root stays its own item: no row needs it
yet.

## Arrays: 5 rows

### The rows (measured, every gap)

| row | forms | gaps |
|---|---|---|
| unit_matrix_path_array_elem | `[]: int buf 3`, `buf[1]: 9`, `buf[1] != 2` | an array, an element write (statement), an element read (expression) |
| unit_matrix_callable_array_elem | `[]: int buf 2`, `buf[0]: 7`, `get(buf[0])`, `get: buf[1]` | the same, and an element as a call's input |
| entry_array_leading_zero | `[]: char values 10`, `values[08]: 1` | a char array, an element write (decimal index with a leading zero) |
| entry_array | inside an `L2:` wrapper: `[]: char command 32`, `command[0]: 0` | a char array, an element write |
| entry_nul | inside an `L2:` wrapper: `[]: char command 8`, `command[0]: '\0'` | a char array, a char literal element write |

The `L2:` wrapper's statements reach the root walk as root statements; its refusals point inside it
(line 2 column 5).

### What the unit holds, and what the walker does (read)

- The builder puts an own array in its unit slot as a typed Array descriptor:
  `lmx_array_new_owned(c.LMX_TYPE_ARRAY_OF_INT / _CHAR / _SIZE_T, count, l2_program_arena)`
  (l2trans.lm1:~20096).
- The walker's roles are RET, CALL, LIT, OWN, ARG, AT, PUT, SET, ADD, SUB, LT, EQ, IF, WHILE, OF,
  PRIM and EXPECT_INT (`lmx_walk.h.lm1:187-216`).
  - AT, PUT and OF address a Structure's field by a size operand.
  - None reaches an Array's element: an element lives in the descriptor's `data` backing, not in a
    Structure's child slots.
- Indices: L2 checks no bounds at run time (L2 spec §18.3).  The translator admits an own-array
  index only as an in-bounds decimal literal (l2trans.lm1:13223/:13516/:13839: «own array index
  requires an in-bounds primitive literal», a pinned refusal row).  All 5 rows index by literals.

### What the class needs

- Walker: an element read and an element write on an Array descriptor, the element typed by the
  Array's element type.  For example ELEM(holder, slot, index) yields the element cell, and ELEMPUT
  stores a value into it.
- Index: a literal checked by the translator, like AT's slot operand.  A computed index is a later
  question: the walk is L3, and «no bounds» is L2's rule.  That's for the author.
- The 2 int rows need only int elements.  The 3 char rows need char values as well: part A of the
  non-int class (steps/root-walk-nonint.md).
- Translator: `[]: T x n` is already a unit field (no step).  `x[i]: v` becomes ELEMPUT; `x[i]` in
  an expression or a call input becomes ELEM.  The leading-zero literal `08` is decimal (the
  translator's l2_dec_literal already reads it so).

## Order

1. Blocks as IF(LIT 1, body): translator only.  It flips `unit_discard_forms` now.
2. `* / %`: a walker role, 4 rows plus codex, rethrow and nested_while.
3. Array elements (int): 2 rows; the char rows follow part A.
4. The catch role (PAD + per-site table + landing): the 5 S1 rows, `unit_s1_catch_publish` and
   the K5 rows.

## Arrays: the translator's side, ready for -170 (prep; base origin/main 63cc240)

Read-only prep for when Grok's -170 adds the element roles.  "Measured" means the refusal-prints
variant (n159/tlp) on this tree.  Typed values landed in -175, so the char rows need no more than
the int rows.  Line numbers are at 63cc240.

### Every gap, measured

| row | gaps (line: refusal) |
|---|---|
| unit_matrix_path_array_elem | 3 «an array» (`[]: int buf 3`); 4, 5, 6, 10 «this statement» (`buf[i]: v`); 7, 11 «this expression» (`if: buf[1] != 2`) |
| unit_matrix_callable_array_elem | 7 «an array»; 8, 9 «this statement»; 11 `r: get(buf[0])` and 15 `r: get: buf[1]` «this expression» |
| entry_array_leading_zero | 1 «an array» (`[]: char values 10`); 2 «this statement» (`values[08]: 1`) |
| entry_array | 2 «an array» (`[]: char command 32`); 3 «this statement» (`command[0]: 0`) |
| entry_nul | 2 «an array» (`[]: char command 8`); 3 «this statement» (`command[0]: '\0'`) |

- Nothing else stands in these rows.
- The `L2:` wrapper's statements are root statements.  No row refuses «L2 operation outside a method
  body».
- All 5 already end in the exit letter, so they need no tail rewrite.

### What P0 gives the translator (read)

There are three shapes:
1. The declaration `[]: T x n`: a frame headed `[]`.  The root refuses it today at
   l2trans.lm1:17458, «an array».
   - It builds no step.  The builder already puts the typed Array descriptor in x's unit slot:
     `lmx_array_new_owned(c.LMX_TYPE_ARRAY_OF_INT / _CHAR / _SIZE_T / _ULONG / _UNSIGNED_CHAR,
     n, l2_program_arena)` (:20625 and on; own types 4 / 5 / 7 / 37 / 8).
2. An element write `x[i]: v`: a frame whose head is one atom, `x[i]`.
   - Natively, `l2_own_index_head(head, mi, @ oi, @ index)` (:7954) answers:
     - 0: an own array with an in-bounds decimal index;
     - 2: a bad index, «own array index requires an in-bounds primitive literal»;
     - 1: not an element.
   - The index is `l2_array_literal` (:7930): digits only, below the declared count.  `08` is 8.
3. An element read inside an expression: a run of four fields, `x [ i ]` (six when rooted:
   `root \ x [ i ]`).
   - Natively, `l2_own_index_tail(f, mi, @ oi, @ index, @ after, @ count)` (:7987).
   - A call's inputs already span such a run: `l2_expr_span` calls `l2_index_chain` (:7835).
   - So `get(buf[0])` reaches `l2_rw_texpr` as one input of 4 fields.  There `l2_rw_texpr`'s
     tokenizer (:16953) takes it as operand, operator, operand, operator: an even count, «this
     expression».

The E check pass is native, so an index that `l2_array_literal` rejects is refused before the walk:
the walk only ever sees proven indices.

### What the root emits once the roles exist (the translator half of -170)

1. The declaration of a root own array (host 0, fid < 0, a unit child): no step.
   - The same rule as the numeric declarations, «a field declared in a nested body» included.
   - «an array» then stays only for what is not a root own array.
2. `x[i]: v` becomes ELEMPUT [elemput, holder, slot, index, value]:
   - holder and slot are the unit and x's unit child, as AT and PUT name them (l2_rw_cell);
   - value is `l2_rw_texpr(v, want = the element's type)`.
3. `x [ i ]` in an expression becomes ELEM [elem, holder, slot, index], an operand.
   - The tokenizer of l2_rw_texpr and l2_rw_fields_ty groups the run with `l2_own_index_tail`
     into one operand slot, which carries its field node and (oi, index).
   - l2_rw_opty types it by the element (below), and l2_rw_operand emits ELEM.
   - The rooted six-field form stays refused, «a field path», as today.
4. The element's static type, per the array's own type:

   | own type | array of | element type |
   |---|---|---|
   | 4 | int | int (0) |
   | 5 | char | char (1) |
   | 7 | size_t | size_t (2) |
   | 37 | ulong | ulong (36) |
   | 8 | unsigned char | no scalar code; refused until a row needs it |

   So in `command[0]: 0` the 0 is LIT char 0; `'\0'` is LIT char 0 as well (-175's char literal);
   and `buf[1] != 2` compares int with int.
5. The index.  Preferred: an operand node, LIT size_t of the proven literal.
   - The shape is then already the one a computed index would use (the author's question), and
     only the index node changes.
   - The alternative is a raw size stored in the node, as AT's slot is (`lmx_walk_store_size`).
     It is one node less, but a computed index would need a new shape.
   - Either way the translator only ever builds a proven literal.

### What the translator needs the roles to do

- ELEM: reads element `index` of the descriptor in `slot` of `holder`, by the descriptor's element
  type (`lmx_domain_type`: ARRAY_OF_INT, ...).  It yields a value the typed ops read:
  - an int cell, or the destination-passing int, for int;
  - the interned `lmx_char_cell(byte)` for char;
  - a fresh typed cell for size_t and ulong, as `lmx_walk_arith_out` makes for + and -.
- ELEMPUT: loads the value by its cell's type, which must be the element's (else INVALID, as PUT),
  and stores it into `data[index]` (a char as its byte).
- Both: `index < len`, else INVALID.  With literal indices the translator has proven it already;
  it is the guard a computed index would need.

### Flips and witness

- All 5 rows flip with the roles and this half: eternal-runs, Entry 0 each.  No other gap stands
  (measured above).
- Witness mutants for that commit:
  - ELEMPUT built with index + 1: unit_matrix_path_array_elem RED (it reads back `buf[1]`);
  - a char array's element type taken as int:
    - entry_array is RED at run time: `0` becomes LIT int, and ELEMPUT's type check refuses it;
    - entry_nul is refused at translation: `'\0'` is a char where an int is asked;
  - the declaration's no-step made a refusal: all 5 RED.
