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

Keep the complete source Structure, ordinary activation-local storage, and the executable operator graph. There is no separate persistent data/context graph beside the Structure. Do not change defaults, dynamic-input precedence, or the accepted `native` dispatch rules.

**If any remaining rule conflicts with this correction, show the conflicting passages and a minimal example to the author before choosing a resolution. Do not introduce a replacement exception.**

## Applied (fable_pc, 2026-09-28)

**Document audit:** older §12 and L2 §10/§18.3 passages mistakenly promoted an assigned explicit or hidden argument to an own field and suppressed the intended working-state model. The current rule is declaration-only storage plus an activation-local argument; the exact removed wording remains in Git history, not as a competing reading here.

**Edits (both languages).** §12: the rule replaced by the author's text (assignment updates an already resolved binding, creates no field during execution or by translator preallocation, an explicit or hidden argument remains an activation-local value unless an explicit declaration establishes a graph-backed field, no write-back and no silent method state); the load paragraph now says an argument never becomes a field; `remember(3)` still 7 with no field of `remember` and no state; the post-trace sentence says a hidden argument differs in nothing from an explicit one; the `keep(3) = 4` example is kept because its field `n` exists by the declaration `int: n`. §4: assigning a hidden-argument name updates the local value and creates no field; a field exists only where a declaration puts it. §8 recipe 5: same, with "only a declared field makes method state". §9: the duplicate removed and the remaining sentence corrected (an assignment to an argument updates the local value; to a declared own field the working copy). §11: an argument never becomes a field. L2 §10: only a declaration makes a field; the contradictory no-working-copies sentence deleted; §13: an assignment never creates a target own field; §18.3: no own-binding rule for an argument, `@x` of an activation-local is that local's stable address, the address of a declared own field is its classified cell, sticky and occurrence binding of an argument gone. `load/cache/dirty` stays for declared fields (dirty.md). `check_docs` passes.

**Check by the code (the lead's slice, reported not changed here).** The translator implements the removed rule: `l2_param_is` (3 uses), `l2_formal_row` (13), `l2_own_bseq` (15) turn an assigned formal or dynamic input into a prepared field with a binding row; the scan of be1ba25 reads a write-only free target and the collector gives it a field (comment citing book :1188); the plan's §5 canonical-cell/sticky/active-selector items were built for argument occurrences. Harness rows built on the promotion: `unit_arg_addr_sticky`, `unit_arg_addr_types`, `unit_arg_addr_dyn_types`, `unit_arg_addr_ordinary` (`test\arg` / `[0]arg` paths to an argument), `unit_occ_*`, `unit_free_write`, `unit_field_write_below_local` (their exit values are unchanged by the correction; the field is what goes), `unit_free_conv` `target`. Recorded for the lead in `next_core_tasks.md` §5 (header) and §7b (a step): remove the promotion, keep a free target as a dynamic input without a field, revisit the rows by name.

**Historical question:** [Q50](../../LMX_blog/q/q50.md) recorded the then-conflicting descriptions of a pointer field and a machine-local pointer slot. It is not in the current question queue. The active address contract is [L2 §18.2–18.3](../L2_spec_en.md#lowlevel-address): classify the selected source value and its real storage, without substituting a working copy for a declared graph cell or a transport parameter for a nonprimitive descriptor. This status note does not invent a new author answer to the historical question.

**Preserved:** the established call rules, activation-local values, the complete operator graph, defaults, dynamic-input precedence, and `native` selection. The author's clarification is recorded in `LMX_blog/2026-09-27.md`.

**Q52 resolved (author, 2026-09-28; `LMX_blog/q/q52.md`):** if ROOT declares `y` but the body of `s` only assigns bare `y`, `s` has no `y` field. Its assignment operator remains in the complete graph. The author selected the activation-local hidden input: the assignment does not write back ROOT, and the minimal example reads `exit(y) = 0`. Dependent gates must be reviewed by name, without a ROOT-specific exception.

**Call and definition boundary (author's current rule):** an existing callable head selects a call checked against the resolved value's contract. An ordinary named Structure has only a body and no arguments: supplying an argument is a call error ([Q59](../../LMX_blog/q/q59.md)), not an unimplemented argument feature. fn/fm/sub use their declared signatures. An unknown actual argument is never declared or supplied by implicit `merge(Model, empty)`. An unknown head instead defines a named Structure with that tail as its body; definition does not execute the body and does not require its free names to be resolved then. With both `C` and nested `makeA` unknown, `C: makeA()` defines `C` containing named empty Structure `makeA`. With an already known nested callable, its ordinary application remains in the retained tree without execution at definition time; see [Q58](../../LMX_blog/q/q58.md). There is no separate saved-call object. Primitive bindings remain assignment targets. Structure and held Structure reference have equal ordinary application behavior: `b: args` calls under the selected contract, and `@: b B` explicitly reassigns. For absent b, `b: A` and `@: b A` are equivalent; preserve the written source body and declaration occurrences. Explicit `b: merge A C` retains its existing result/operand contract.

**References and descriptions (corrected 2026-10-02):** A Structure already travels by reference. Unary `@B` addresses the real cell holding that reference (conceptually `Lmx **`), not the descriptor (`Lmx *`). Array references and nonprimitive formals obey the same rule; an ABI box or temporary cannot stand in for the language place. Unary `@` and receiver `@:` are different operations. Signature descriptions do not erase an actual's explicit address level. Structural admission follows allowed primitive conversion; no per-model conversion registry, implicit cloning or C-valued transport. Implementation remains pending in [critical_pointer_to_struct_bug](../../steps/tickets/critical_pointer_to_struct_bug.md) and the subsequent [reference-application refactoring](../../steps/tickets/structure_reference_application_refactor.md).
