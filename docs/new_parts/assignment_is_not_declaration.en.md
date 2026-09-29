# To Fable — remove assignment-driven creation of own-fields

The author, in the fable_pc chat, 2026-09-28 (verbatim): «а проверь пожалуйста по коду и докам что у нас поле только в месте объявления (очень старая выдумка что в месте прсивоения очен неправильная)». The note below came with that message.

**The author rejects the rule that assigning an argument implicitly creates a persistent own-field. Assignment is not a declaration. Restoring `load/cache/dirty` must not restore this old field-creation mechanism.**

### 1. Remove the argument-to-field promotion rule

In **`LMX_semantics.en.md` and `LMX_semantics.ru.md`, §12**, remove the rule beginning:

> “The presence in a source body of a resolved bare assignment … makes `x` a field of that body's data prototype.”

Also correct the preceding paragraph, the explanation of `remember`, and the corresponding statement after the recursion example. These currently make assignment the reason for creating and binding a new body field.

Replace that mechanism with:

> **Assignment updates an already resolved binding. It does not create an additional data field, either during execution or by causing the translator to preallocate one. An explicit or hidden argument remains an activation-local value unless an explicit declaration establishes a graph-backed field. Assignment to the argument does not write back to its caller or silently create persistent method state.**

Consequently, `remember(3)` still returns `7`, but `x: 7` does not itself create an additional persistent body field. **Keep the assignment operator in the executable graph; remove the invented storage destination, not the operation.**

Propagate this correction to **§4, §8 case 5, §9, and §11**. In §9, also remove the duplicated final sentence about binding the cache to a prepared own-occurrence.

### 2. Correct L2 consistently

In **both L2 specifications**, update **§10**, the assignment paragraph in **§13**, and **§18.3**: none may require preparing a new own-field merely because an argument is assigned.

In **§10**, delete the contradictory sentence:

> “There are no working copies, no `dirty`, no load on entry, and no publication at a checkpoint…”

**Keep `load/cache/dirty` for declared graph-backed fields under the established publication rules.** A modified local argument does not acquire a graph publication destination merely because it changed.

### 3. Preserve the architecture

Keep `(code, data)`, including `(M, M)`, ordinary activation-local storage, and the executable operator graph. Do not change defaults, dynamic-input precedence, or the accepted `native` reuse rules.

**If any remaining rule conflicts with this correction, show the conflicting passages and a minimal example to the author before choosing a resolution. Do not introduce a replacement exception.**

## Applied (fable_pc, 2026-09-28)

**Check by the docs.** The rule lived in the book §12 (`#dynamic`: "the presence in a source body of a resolved bare assignment … makes `x` a field of that body's data prototype"), its preceding paragraph ("becomes a field of the instance only when a bare assignment targets it"), the `remember` explanation ("input `x` becomes a field of the body's data instance when `x: 7` executes"), the sentence after the recursive trace ("the hidden argument follows the same own-field preparation and binding rule"), §4 (`#fields`, the `node` paragraph: "the translator prepares that body's own field"), §8 recipe 5 ("makes the translator prepare a same-name own field"), §9 (`#construction`, the duplicated final sentence "binds the local cache to the prepared own occurrence"), §11 (`#callables`: "an argument becomes a field only by the rule of §12"), and in the L2 spec §10 ("an argument becomes a data field only by the assignment rule", plus the contradictory "There are no working copies, no `dirty`, no load on entry, and no publication at a checkpoint"), §13 ("otherwise it creates no target own field"), §18.3 (the whole "distinct same-name own-binding rule" paragraph with the sticky/occurrence-binding mechanism of an argument).

**Edits (both languages).** §12: the rule replaced by the author's text (assignment updates an already resolved binding, creates no field during execution or by translator preallocation, an explicit or hidden argument remains an activation-local value unless an explicit declaration establishes a graph-backed field, no write-back and no silent method state); the load paragraph now says an argument never becomes a field; `remember(3)` still 7 with no field of `remember` and no state; the post-trace sentence says a hidden argument differs in nothing from an explicit one; the `keep(3) = 4` example is kept because its field `n` exists by the declaration `int: n`. §4: assigning a hidden-argument name updates the local value and creates no field; a field exists only where a declaration puts it. §8 recipe 5: same, with "only a declared field makes method state". §9: the duplicate removed and the remaining sentence corrected (an assignment to an argument updates the local value; to a declared own field the working copy). §11: an argument never becomes a field. L2 §10: only a declaration makes a field; the contradictory no-working-copies sentence deleted; §13: an assignment never creates a target own field; §18.3: no own-binding rule for an argument, `@x` of an activation-local is that local's stable address, the address of a declared own field is its classified cell, sticky and occurrence binding of an argument gone. `load/cache/dirty` stays for declared fields (dirty.md). `check_docs` passes.

**Check by the code (the lead's slice, reported not changed here).** The translator implements the removed rule: `l2_param_is` (3 uses), `l2_formal_row` (13), `l2_own_bseq` (15) turn an assigned formal or dynamic input into a prepared field with a binding row; the scan of be1ba25 reads a write-only free target and the collector gives it a field (comment citing book :1188); the plan's §5 canonical-cell/sticky/active-selector items were built for argument occurrences. Harness rows built on the promotion: `unit_arg_addr_sticky`, `unit_arg_addr_types`, `unit_arg_addr_dyn_types`, `unit_arg_addr_ordinary` (`test\arg` / `[0]arg` paths to an argument), `unit_occ_*`, `unit_free_write`, `unit_field_write_below_local` (their exit values are unchanged by the correction; the field is what goes), `unit_free_conv` `target`. Recorded for the lead in `next_core_tasks.md` §5 (header) and §7b (a step): remove the promotion, keep a free target as a dynamic input without a field, revisit the rows by name.

**Contradiction found and asked, not resolved:** `LMX_blog/q/current/q50.md` — a pointer declared in a method body and addressed by bare `@p` (L2 §18.2 row "own graph field": the cell, no reload; row "machine address slot": the slot, the C store visible to the next bare read; `printTree`'s output parameter is the example).

**Preserved:** `(code, data)` including `(M, M)`, activation-local storage, the operator graph, defaults, dynamic-input precedence, `native` reuse. The author's note is saved above verbatim with his chat message; the decision is recorded in `LMX_blog/2026-09-27.md`.
