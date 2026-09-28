# To Fable — local declarations, explicit initialization, and the complete graph

**Status:** the language author's latest request, not an interpretation of the previous specification. Apply it consistently to the EN/RU documentation and the implementation work that depends on it. Record unresolved consequences as questions to the author.

**Keep `(M, M)`.** The previous reviewer's suggestion that code and data must always have different roots is withdrawn. One universal Structure remains sufficient; `code` and `data` remain execution roles.

## 1. Separate ordinary access to values from inspection of program structure

In the executable-body case discussed here, a declaration such as:

```text
int: i
```

introduces a locally usable variable. Its presence in the complete graph must **not automatically expose `i` as an externally readable/writable field of the enclosing callable**.

Inside its permitted scope, ordinary reads and assignments to `i` work normally. Outside it, an ordinary field path such as `M\i` must not expose that local merely because the declaration occurs in M's stored body. Ordinary field access must not discover the declaration's initializer and treat it as a replaceable value slot either.

The declaration and the surrounding code remain present in the complete Structure. Deliberately examining that Structure as an abstract array/graph is still possible through the existing structural mechanisms. This is a different use of the same representation, not another object model.

In particular:

- Do not remove declaration or instruction nodes from the complete graph just to hide them from ordinary field lookup.
- Do not introduce `private`, a mandatory `var` section, a special class, a third environment graph, or a new visibility registry to express this decision.
- Do not describe this as cryptographic secrecy. It is the distinction between ordinary access to a variable and deliberate inspection/manipulation of program structure; existing permissions still apply.
- Do not infer a new lifetime rule from the word “local.” The author is changing ordinary accessibility, not instructing you to erase all stored state after return or to remove declaration-backed storage.

Apply the distinction through the general semantics of the declaration and its receiving context, not branches for the literal names `int`, `i`, or `findValue`. Do not silently generalize executable-body locality into a ban on explicitly constructed data records. If the current rules do not distinguish the required cases, identify that conflict and ask the author.

## 2. Use ordinary adjacent statements for computed initialization

The author's requested example is:

```text
int: i
i: findValue
```

The first statement declares `i`. The second is ordinary executable assignment: assuming `findValue` is the suitable value-returning callable, its result is obtained under the normal call rules and assigned to the existing `i`.

There is no special initializer receiver and no constructor body elsewhere. The declaration, its state, and the code using it belong together, in the Structure and lexical location where they are actually needed. Do not hoist them to a class-level member list or a Pascal-style declaration block.

The initialization assignment executes when normal control flow reaches it. It is not an implicit construction-time action, a first-read property, or a hidden once-only initialization phase. Merely inspecting the stored program must not execute it. This does not redefine unrelated explicitly requested value-construction operations.

The motivating problematic form was:

```text
int: i findValue()
```

Do not implement it by letting the same replaceable location stand both for the saved `findValue()` computation and for the current result of that computation. Use the two-statement form as the normative example for computed initialization. Do not silently invent a new normalization, prohibition, or initializer category for every existing compact declaration; ask the author where its treatment needs a further decision. This request does not by itself ban simple literal declarations such as `int: i 5`.

The contrast with the object-initialization approach discussed in the conversation is architectural: executable preparation need not be moved to a separate constructor or an implicit initialized-object phase. It is ordinary program code next to the declaration. Do not turn this motivation into a claim about every object-oriented language.

## 3. Preserve both the computation and the changing value

After executing the two-statement example, and after later assignments to `i`, the complete graph must still contain the declaration and the assignment calling `findValue`.

An ordinary assignment changes the resolved variable's working value. It does not replace the call, its operands, or the assignment instruction with the resulting integer. Assignment also creates no new declaration or additional field merely because it occurs.

This invariant applies with `(M, M)` and through both native execution and the interpreter. It requires no separate fundamental Structure type. Keep the established `load/cache/dirty` mechanism for applicable declaration-backed state; a checkpoint may write back a changed value only to its proper value storage, never into an initializer's executable representation.

Hiding a name from outside lookup alone is not evidence that this invariant holds. Verify the internal store/write-back destination as well. Do not conceal an unresolved representation conflict behind a lookup filter.

The existing distinction for `native` remains: changes to values do not invalidate an unchanged algorithm's implementation; an organized change to executable code requires a corresponding implementation or the applicable interpreted path. This task does not design arbitrary in-place editing of active machine code.

## 4. Correct the documentation and dependent tasks together

Use section titles and quoted wording to locate the passages; generated line numbers may move. The reviewed snapshots are `LMX_semantics.en(6).md`, `LMX_semantics.ru(5).md`, both L2 specifications, and `next_core_tasks.md`.

| Location | Required correction |
| --- | --- |
| LMX §4; §8 case 5; §9 | Remove assignment-driven creation/promotion of argument own-fields. Keep declaration, local assignment, ordinary exposed-data access, and structural inspection distinct. |
| LMX §11, “Callable expressions and their interfaces” | Correct the blanket statement that `Counter\n` reads a published field even when Counter is a method. A local declaration must not automatically become such an ordinary external field. Preserve `(M, M)` and the ordinary activation. |
| LMX §12, “Dynamic inputs and working state” | Replace the rule that assigning an argument creates a body field. Correct “reachable from outside through the path `M\x`” and the `remember` explanation. Do not equate graph presence with ordinary external visibility. |
| LMX §12 examples | Revisit the external `S\x` observations and `for\j` example wherever they expose body-local declarations. Show explicit structural inspection where that is intended, or ask about the precise access contract. Do not leave an invalid ordinary path solely to retain an old expected output. |
| L2 §§10–11, §13 assignment discussion, §18.3 | Align storage, local resolution, ordinary field lookup and address rules with the decision. Remove the contradictory “no working copies / no dirty / no load” sentence in §10; do not restore argument promotion as part of caching. |
| `next_core_tasks.md`, execution-pair discussion and §§5/7b | Update active work and witnesses. Clearly mark superseded historical instructions; do not reuse old checked boxes as proof that the new behavior is implemented. |

Review related `merge`, dynamic-input and admission examples for dependence on automatic external exposure. Preserve the established mechanisms; when an example now needs an author decision, report the dependency instead of silently changing capture, defaults, dynamic precedence or `implements`.

If these documents are generated, correct their authoritative source and regenerate both languages rather than editing only the rendered output.

## 5. Focused evidence

Demonstrate the following in both native and interpreted execution where applicable:

1. The two-statement example computes and assigns the result of `findValue` when the assignment is reached. A skipped assignment does not call it, and inspection alone does not call it.
2. Repeated assignments use the existing local value location and create no additional declarations or assignment-value snapshots.
3. Ordinary external lookup/read/write does not expose the body-local `i` as `M\i`.
4. Deliberate abstract-array/graph inspection still finds the declaration and executable assignment after execution. Compare executable structure, not whole-state equality: values are allowed to change.
5. The same checks hold for execution over the same Structure in both roles, `(M, M)`. No separate code/data type or mandatory separate graph is introduced.
6. Caching and dirty write-back never overwrite the saved call or other instruction nodes. Updating the local value alone leaves the matching `native` valid.

**If any required distinction conflicts with an existing rule, show the exact passages and a minimal example to the author before choosing a resolution. Do not invent an exception, constructor phase, visibility flag, or hidden storage scheme to make the tests pass. Do not ask again whether `(M, M)` should remain or whether ordinary external access should expose these locals: the author has answered both.**

## Source anchors for this correction

These are the prior passages being revised, not evidence that the author's new rule was already present:

- `LMX_semantics.en(6).md`, §11: “A structural path through a callable Structure (`Counter\n`) reads its published field”; execution-pair paragraph: “from outside the occurrence's own fields are visible.”
- The same file, §12: “makes `x` a field of that body's data prototype”; “reachable from outside through the path `M\x`”; `remember`, the recursion trace, and the `for\j` observation example.
- `L2_spec_en.md`, §10: the single paragraph currently combines `(M, M)`, preserved interpreter operators, external `M\x` access, restored caching, and the contradictory denial of caching. Its Russian counterpart requires the same coordinated correction.

**Deliverable:** a consistent EN/RU rule, updated implementation tasks, and focused evidence. Keep unresolved semantic choices as explicit questions, not undocumented behavior.

## Applied (fable_pc, 2026-09-28)

The note itself: committed and pushed (it entered `5c2933a`, being staged in the checkout at that commit; origin/main carries it). Text checks only; the implementation items are the lead's (below).

**Check by the docs.** The passages that made body-local declarations ordinary external fields: §11 "A structural path through a callable Structure (`Counter\n`) reads its published field and does not execute it, even when it is a method" and, in the execution-pair paragraph, "from outside the occurrence's own fields are visible"; §12 "reachable from outside through the path `M\x`", the recursive trace's "Published `S\x`" column and its explanation ("the path `S\x` from outside reads 2"), the `for\j` example; L2 §10 "the path `M\x` from outside reads the fields of the latest activation over its own graph". The argument-to-field promotion and the contradictory "no working copies" sentence were already removed in `bafca4c`; `remember` already creates no field.

**Edits (both languages; §4 of the note).** §11: a declaration in a method's executable body (`fn`/`sub`/`fm`) is a local of that body, not an ordinary external field — `M\i` from outside does not expose it, deliberate inspection of the complete Structure as an abstract array/graph finds it; the execution-pair paragraph says the body's locals are not visible from outside as ordinary fields and their storage stays in the complete Structure for inspection. §12: the "reachable from outside through `M\x`" sentence rewritten the same way; computed initialization added in the author's terms — two ordinary adjacent statements (`int: i` / `i: findValue`), executed when control reaches the line, no initializer receiver, construction phase or hidden once-only initialization, inspection does not execute it, the complete Structure keeps both the declaration and the assignment calling `findValue`, assignment changes the working value and never the call or the instruction, a checkpoint writes only to value storage, `int: i 5` not banned; the recursive trace's column renamed to the published value in S's storage (structural inspection, not an ordinary path — q51) and its `S\x` sentences reworded; the `for\j` example's paragraph now says the read of a nested body's local from the enclosing method is q51's access contract. L2 §10: the `M\x`-from-outside sentence rewritten (a body local is not an ordinary external field; the latest activation's published values stay in M's storage for inspection). `check_docs` passes.

**Conflicts identified and asked, not resolved (`LMX_blog/q/current/q51.md`):** (1) a named Structure executed as a procedure (Q45) — are its declared fields ordinary external fields (`Counter\n` after `Counter`, the `unit_named_struct_exec` family, about twenty gated rows) or locals of its body; (2) a nested body's local read from the enclosing method after `end: for` (the book's own `for\j` example; today "unresolved name", 7b-3); (3) an explicit path from another method into a method's local (`test\x: 7` in the working-state witnesses W3/W11 and the S/I2 trace) — which path, if any, is the explicit write into a declaration's storage.

**Check by the code (the lead's slice, reported not changed here).** The translator lowers `M\x` from outside as an ordinary field read/write of the callable occurrence (`l2_rw_host_read`/`l2_rw_host_put` in the walk, the own-field cells natively); 70 fixtures read a method's or named Structure's declared field by path from outside (census: the `unit_named_struct_exec_*` family, data records such as `Holder\buf`, `Point\x`, `Model\value`, the `unit_arg_addr_*` rows already going with the promotion). The lead has the note's evidence items 1–6 as a `next_core_tasks.md` §7b step and the q51 hold on the affected witnesses.

**Preserved:** `(M, M)`, the ordinary activation, the operator graph, defaults, dynamic precedence, `native`, `implements`, `merge`; no `private`, visibility registry, constructor phase or third graph introduced.
