# The walked root's implements class (6 rows) and receiveMessage class (8 rows)

Measure-first note after -175 (Opus, read-only; base origin/main af74bbc, -174 commit 0 on it).
- "Read" means established by reading the code.
- "Measured" means observed on a translator built in scratch with the named patch.  The patch is
  n159/ir.json on this tree, and no code is committed.
- Every gap of a row comes from the refusal-prints variant (n159/tlp), not only the first.

## Summary

| class | rows | translator only | needs the walker |
|---|---|---|---|
| implements | 6 | all 6 (measured green) | nothing |
| receiveMessage | 8 | 1: `unit_next_message_method_first` (measured green) | 7: a take primitive, a reference store with null, a reference null test; then per row a loop, `&&`, graph call inputs, the catch role |

## Implements: static, 6 rows

### What `implements` is in these rows (read)

Every row uses the three-argument form `implements(candidate, required, consumer)` with descriptor
names (`User`, `` `int` ``, `File`, a namespace-qualified name), in an `if:` condition:
`if: implements(Plain, Equatable, ThinConsumer) != 1`.
- It is decided at translation time.  `l2_check_implements` (l2trans.lm1:9579) and
  `l2_prep_implements` (:9630) call `l2_implements(cand, req, cons, @ result)` and emit the literal
  `1` or `0`.
- The form admits only three descriptor names ("implements expects candidate, required,
  consumer" / "... descriptor names").  It has no value operand.
- The run-time `lmx_runtime_implements` is another thing: the admission of a graph into a typed
  place (`l2_emit_admit`, :10979), whose refusal is the implicit throw `implements`.  None of the 6
  rows uses it.

So at the walked root, `implements(...)` is an int literal: the translator builds LIT int 1 or 0
with the same `l2_prep_implements`.  No walker role.

### Measured

- Patch: in `l2_rw_operand`, the frame head `implements` becomes
  `l2_prep_implements(node, ib)`, then `l2_rw_lit(parent, ib[0] = '1', out)`.  This replaces
  «root operation not walkable yet: implements».
- Result: all 6 rows translate and run green (Entry 0), and their pins hold:
  - `unit_implements_methods`, `_primitives`, `_namespace`, `_argument`, `_assignment`, `_return`;
  - Debt `l2_entry_unit: graph` and the launch are present; Absent `lmx_perm` /
    `LMX_ROOT_ETERNAL_SLOT` are absent.
- Their tails are already the exit letter: no rewrite.
- Witness: the result inverted (LIT `ib[0] != '1'`) turns `unit_implements_argument` and
  `unit_implements_methods` RED (exit 1, expected 0).
- For the static typing (`l2_rw_tyof`, -175), `implements(...)` is an operand it does not know, so
  it takes any type, and `!= 1` resolves it as int.  If wanted, `l2_rw_opty` can say int
  explicitly.

## receiveMessage: 8 rows

### What the native emission does (read, l2trans.lm1:19598)

`receiveMessage: m` does four things:
1. It takes the current Thread's next letter: `lmx_thread_mail_take(lmx_thread_current(),
   LMX_POST_INBOX)`.  The owner attaches the letter's arena before it exposes it.
2. m's value is the letter's graph, or 0 when the inbox is empty.
3. When m's field is typed (`MainLetter: m`; per the mail design, `receiveMessage: m Model`), it
   admits the letter: `l2_emit_admit`, `lmx_runtime_implements` against the model.  A refusal is
   the implicit throw `implements`.
4. It writes m's graph cell (`lmx_pointer_store_known`) and its working copy.

The letter's shape is fixed (steps/mail-wrappers.md, 2026-09-25): `(sender: @: LmxMsg; payload)`.
- The translator synthesizes the letter's model at the receiving site (Sonnet -172, the method
  path): `m\sender`, `m\payload\...`.
- The host's mainArgs letter is `(sender = the host's Message; (mainArgs))` (-173).

### The rows, every gap (measured)

| row | root forms | gaps after receiveMessage |
|---|---|---|
| `unit_next_message_method_first` | a declared method `receiveMessage(x)` called as `receiveMessage: 4` and `r: receiveMessage(3)` | none; see the fix below |
| `entry_argc` | `receiveMessage: m`, `if: m = 0` | the null test; tails (2 `return: V`) |
| `unit_next_message_twice` | two takes, `if: m = 0`, `if: m != 0` | the null test; tails (3) |
| `unit_next_message_in_method` | `take()` takes natively in a method; the root's `receiveMessage: after`, `if: after != 0` | the null test; tails (2) |
| `unit_next_message_loop` | `while: m != 0 && n < 5` around a take | the null test, «a loop» (translator), `&&` (walker: no short-circuit role) |
| `unit_admit_letter_formal` | `present(raw)` with a `MainLetter` formal, `MainLetter: m`, `m: raw`, `if: m = 0` | the null test, a graph call input (admission), a Structure-typed field (part B), `m: raw` admission; tails (4) |
| `unit_admit_formal_refused` | `get(m)` with a `Model` formal and a size_t result; the admission refuses: Fails 1, Stopped 1, Thrown 2 | a graph call input (admission, throw 2), a size_t call result (-174 commit 4) |
| `unit_s1_catch_implements` | `r: get(m)` refused (implements), `catch: implements ()`: Entry 42 | a graph call input (admission), the catch role (-171) |

Harness facts to fix when a row flips:
- `Letters = 0` stands on 6 of them.  It is not observable under the host (the driver reports a
  row that names it as red, 2b), so it goes.
- `unit_next_message_twice` pins the native take `l2_nmsg: (cast: (@: LmxMsg)
  lmx_thread_mail_take(...))`.  The walked root does not emit it, so the pin moves to the walked
  take.
- `entry_argc` has Argv (`one`, `two`): the harness runs it itself.

### A translator-only fix: a declared `receiveMessage` method (measured)

`l2_rw_stmt` refuses the head text `receiveMessage` before it looks for a method of that name.
- The native rule (l2trans.lm1:6012-6030, `l2_receive_msg_shape`) is that a declared method named
  receiveMessage takes precedence, as every callable head does.
- Patch: refuse only when `l2_find_method(h) < 0`.
- `unit_next_message_method_first` then translates and runs green (Entry 0).  Its Absent
  `lmx_thread_mail_take` holds, since nothing takes the letter.

### What the other 7 need from the walker (read)

1. The take.  One registered kernel primitive is enough; no per-site generated code.
   - A PRIM step whose record's fn takes the current Thread's next letter and hands its graph back
     through `out`.  `lmx_walk_prim` (lmx_walk.lm1:950) calls `record\fn(owner, refs, n, dest,
     out)`, so a primitive can return a reference.
   - An empty inbox is a null reference.
   - The owner's attach-before-expose stays in `lmx_thread_mail_take`.
2. The store into m: a reference PUT into m's pointer cell.  This is part B's reference PUT
   (-174), and it must admit null.  Today PUT refuses a value of 0 (lmx_walk.lm1:1093, `value = 0`
   gives INVALID).
3. The null test: `m = 0` / `m != 0` on a reference.
   - EQ loads its operands as numbers (`lmx_walk_load_operand`), and a pointer cell is not one:
     INVALID.
   - Either EQ compares two references, a null one included, or a role tests a reference for null.
   - Four rows need nothing else: `entry_argc`, `_twice`, `_in_method`, and `_loop` with its loop
     and `&&`.
   - As far as I can see this is not in -174's list (DEREF, reference PUT, merge primitive, typed
     CALL destination).
4. A typed receive (`receiveMessage: m Model`, or `m` declared `MainLetter: m`): the admission of
   field 1 (payload) through `lmx_runtime_implements`, whose refusal is the implicit throw
   `implements`.
   - A primitive cannot throw today: a status other than LMX_PRIMITIVE_OK becomes
     LMX_WALK_PRIMITIVE, an error, not LMX_WALK_THROWN + k (lmx_walk.lm1:992).
   - So either the primitive returns a throw number the walk carries as a throw, as a trampoline's
     does (commit 3), or the admission is a step of its own.
   - None of the 8 rows needs a typed receive itself.  `unit_admit_*` in the Structure-typed class
     do.
5. A graph as a call input (`present(raw)`, `get(m)`): CALL passes a reference.
   - The admission into the callee's graph formal is an implicit throw `implements`.
   - Natively it is the caller's (`l2_emit_admit` at the call site), numbered in the caller's order:
     2 at the root, where no `throws:` exists (Thrown 2 in `unit_admit_formal_refused`).
   - The trampoline could admit on the callee's side and return the throw.  Then the number would
     be the callee's own d + 2, which is the same 2 here, since neither side declares a throw.
     That is a question to settle before the ticket: whose number is an admission's throw, when
     the callee declares throws of its own?
6. The rest are known gaps:
   - `while:` at the root: the translator's half (the walker has WHILE);
   - `&&` / `||`: the walker has no short-circuit role;
   - the catch role (-171);
   - a size_t call result (-174 commit 4).

## Order

1. Now, translator only: `implements(...)` as LIT, and the method-first order.  7 rows flip, 6
   implements plus `unit_next_message_method_first`.  One commit, with the inverted-LIT mutant as
   its witness.
2. After -174's reference PUT: the take primitive, null in PUT, and the reference null test.  That
   flips `entry_argc`, `unit_next_message_twice` and `unit_next_message_in_method`, each after its
   tails rewrite and with `Letters` dropped.
3. `unit_next_message_loop`: after `while:` at the root, and `&&`.
4. `unit_admit_letter_formal` and `unit_admit_formal_refused`: after a graph call input with its
   admission throw, part B's Structure-typed fields, and the typed CALL destination.
5. `unit_s1_catch_implements`: after the catch role (-171).
