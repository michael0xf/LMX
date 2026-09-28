# Follow-up corrections after response48 — corrected cache/dirty decision

The latest revision correctly incorporates the main decisions from `response48.md`. Do not reopen or revert the accepted semantics for `merge`, callable defaults, free dynamic names, or `native`.

This note also **corrects one mistake in the previous review instruction**: the earlier suggestion to remove the remaining `dirty` / local-cache semantics was wrong.

## 1. AUTHOR DECISION: keep the load/cache/dirty model and remove the contradictory “no caches / dirty / checkpoints” wording

**This section is an explicit request from the language author, not an inference by the reviewing agent.**

The intended model is the ordinary efficient load/cache/dirty model.

A graph field may be loaded into activation-local working storage (and, in native code, may ultimately reside in an ordinary C local or machine register). Repeated operations use that local value. When the local value is modified, it becomes dirty. At the applicable publication/checkpoint boundary, only the required modified own-fields are written back to their graph locations.

Conceptually:

```text
graph own-field
    ↓ load
activation-local cached value
    ↓
ordinary repeated computation
    ↓
dirty
    ↓ checkpoint/publication
graph own-field
```

The specification already describes this model in several places. For example, the current §4 says that a resolved bare assignment uses a prepared own-field, binds the local cache to it, marks it dirty, and later publishes into that own-field rather than into the source of a hidden argument.

§8 case 5 and §9 likewise still describe the local-cache/dirty model. This is intentional, not stale wording.

Therefore:

### Remove or rewrite the contradictory rule

Find the current statement equivalent to:

> there are no caches, dirty marks, working copies or checkpoints

and its RU equivalent.

That statement is contrary to the author's intended model and must not remain as the semantic rule.

Also find any nearby text that was previously rewritten under the assumption that graph-field assignment is always an immediate physical graph store. Restore it to the cache/dirty model where required for consistency.

### Preserve the semantic distinction between local publication and source mutation

For a bare dynamically obtained name:

```text
x
```

the value may be loaded into activation-local working state.

If the body executes:

```text
x: x + 1
```

the write is local with respect to the source from which the input was obtained. It updates the body's prepared own occurrence through the working-state/cache mechanism; it does **not** write back into the caller's argument source merely because the original value came from there.

An explicit graph path is different. For example:

```text
node\x: value
```

explicitly addresses the selected graph field and is the mechanism for mutating that graph location.

Do not collapse these two cases.

### `dirty` is semantic working-state information, not necessarily one physical Boolean per variable

The specification should define the observable working-state rule, not require one particular backend representation.

A native translator may statically know that a cached local was modified and emit the necessary store at a checkpoint. An interpreter may use a dirty bit or bitmap. Another backend may use an equivalent mechanism.

The required semantics are:

- the current activation may operate on local cached values;
- modified values that require publication are distinguishable from unchanged ones;
- required dirty own-fields are published at the defined boundaries;
- unchanged values need not be redundantly written back;
- publication never silently changes the source of a dynamically supplied argument when the assignment is defined as local.

Do not introduce a mandatory physical `bool dirty` field merely because the specification uses the word `dirty`.

### Audit checkpoint boundaries, but do not invent them

After restoring the cache/dirty model, inspect all existing rules that define when working state is published: normal callable exit, `return`, `finally`, failure paths, suspension/retry, turn boundaries, calls requiring published graph state, or any other already documented boundary.

**Do not choose missing checkpoint semantics yourself.**

If two existing rules disagree about when dirty working state becomes visible, or if a required boundary is genuinely unspecified, quote the conflicting/insufficient passages and ask the author.

Do not confuse this with publication of outgoing Messages. Message publication is a separate mechanism and must remain governed by its own rules.

## 2. Callable `sig` still needs a consistency pass after defaults

The current callable-admission formula still contains:

```text
sig(aVar.p) = sig(bVar.p) = ExpectedSig(Consumer, p)
```

while the revised callable/default discussion now distinguishes at least:

1. the **accepted interface** — all arguments the callable accepts, including optional/defaulted formals;
2. the **mandatory supply** — inputs that must be supplied for a particular call;
3. the **formed inputs** — the actual inputs presented to the selected implementation after explicit arguments, defaults and permitted conversions have been processed.

The complete callable signature is still described as including declared and dynamic inputs, names, order, passing modes, result, throws and ABI.

Do not resolve this by simply deleting optional formals from `sig`.

For example:

```text
A:
    x: int
    y: int = 5

B:
    x: int
```

Both may permit the short call:

```text
f(1)
```

but only A accepts:

```text
f(1; y: 25)
```

Therefore equality of only the mandatory argument set is not sufficient to describe everything the Consumer may require.

At the same time, do not revert to a rule saying that every optional formal must occur in every Consumer's expected call descriptor merely because it belongs to the candidate's accepted interface.

The check is Consumer-relative.

The intended direction is conceptually:

```text
Consumer's actual use of callable p
    ↓
arguments/requirements imposed at that use
    ↓
candidate accepted interface must accept them
    ↓
missing candidate inputs may be formed by its ordinary defaults
    and permitted conversions
    ↓
formed call must satisfy the selected callable's actual descriptor
    ↓
result / throws / passing-mode requirements must satisfy Consumer
```

Please make the formal notation and the prose describe the same mechanism.

If the existing meaning of `sig`, `ExpectedSig`, and `implements` does not uniquely determine how to express this, **ask the author before choosing a new formula**.

Do not reopen the already answered question whether a defaulted formal remains explicitly passable. It does:

```text
add5(1)         -> 6
add5(1; y: 25)  -> 26
add5(1; y: 0)   -> 1
```

## 3. Fix the `DynRequired` wording so defaults and free inputs remain distinct

A formal with a default value is not a free dynamic name merely because it may be omitted at a call.

A free dynamic name in a body is different.

Please make the wording explicit:

> A formal with a provided default value is not a free name: it does not enter `DynRequired` merely because it can be omitted, and it remains part of the callable's accepted interface. Adding a **new free dynamic name to the body** changes `DynRequired` and therefore the corresponding callable requirements.

RU equivalent:

> Формал с предусмотренным значением по умолчанию — не свободное имя: возможность опустить его при вызове сама по себе не включает его в `DynRequired`, и он остаётся частью принимаемого интерфейса. Добавление **нового свободного динамического имени в тело** меняет `DynRequired` и соответствующие требования вызываемого выражения.

Use the final agreed terminology for `sig` after item 2 is resolved.

## 4. Re-check `assert` / failure wording in light of the restored cache/dirty model

The previous review treated wording such as:

> after publication and cleanup

as suspicious because it assumed that working-field publication had been removed.

That assumption was wrong.

Now re-read the relevant `assert`, failure, `finally`, return and cleanup rules **under the restored cache/dirty model**.

If “publication” there refers to publishing dirty own-fields at a defined checkpoint, retain it and make that relation explicit if useful.

If it refers to outgoing Message publication, retain that separate meaning.

If the text conflates the two, distinguish them.

If the intended publication boundary cannot be determined uniquely from the existing rules, **ask the author** rather than deleting the wording.

## 5. Preserve the accepted `merge` rules

Do not restore any previous interpretation in which `merge` binds arguments.

`merge` copies/composes the applicable graph material. Copying lexical data does not disable dynamic-input precedence and does not itself turn a free name into a formal.

The declared callable header is the receiving-place/admission contract, not an implicit extra `merge` operand.

A defaulted formal is governed by ordinary call preparation, not by a special `merge` binder.

## 6. Preserve the accepted `native` rules

Do not restore the old rule that every result of `merge` receives an empty `native`.

The correct rule remains:

- unchanged executable code/body may retain its corresponding native implementation even when its data or copied lexical graph differs;
- the native implementation receives the graph/context it operates on;
- selecting another already existing body may select that body's corresponding native implementation;
- if executable code is actually changed and there is no native implementation corresponding to the resulting code, the old native address cannot be reused and the valid L3 graph is interpreted.

Changing data merely located under a structural field named `body` is not automatically changing executable code.

The 2026-09-25 author confirmation about an interpreted result referred to the case where the executable body had changed. Do not record the current clarification as a reversal of that decision.

## 7. Preserve copying versus physical sharing

Reusing a native implementation does not mean retaining the original mutable graph.

Ordinary copied Structures and their applicable lexical graph follow the normal copying rules.

The established whole-branch exception remains:

```text
independent: const: immutable
```

Such a branch has no external lexical parent and cannot change, so retaining its original physical reference is the intended exception rather than uselessly copying the whole branch.

Do not generalize that exception to ordinary mutable Structures or callable occurrences.

## 8. EN/RU consistency audit

After the changes, search both specifications for at least:

```text
dirty
checkpoint
cache
local cache
working state
working copy
publish / publication
sig
ExpectedSig
DynRequired
default
optional
accepted interface
mandatory supply
formed inputs
native
merge
```

For every occurrence, classify what it refers to.

In particular, keep distinct:

```text
working-field publication
≠
outgoing Message publication
```

and:

```text
formal with a default
≠
free dynamic input
```

and:

```text
reused native implementation
≠
shared mutable graph
```

## 9. Mandatory contradiction rule

If you encounter a semantic contradiction, do **not** silently choose the interpretation that is easiest to implement or that appears more conventional.

The main specification already requires that a contradictory decision be suspended for explicit discussion rather than resolved by invented workaround semantics.

When asking the author:

1. quote the two conflicting rules;
2. give the smallest example for which they produce different observable results;
3. ask one concrete semantic question.

Do not ask again about decisions explicitly answered above.

---

### Author correction to the previous review

**The request to restore and retain the load/cache/dirty model is explicitly from the language author.**

The previous reviewer instruction that treated the remaining `dirty` wording as stale was incorrect. Do not use that earlier instruction as evidence for removing caches, dirty tracking, or checkpoints.

The remaining issues concerning callable admission/`sig`, `DynRequired`, and wording around publication should be reconsidered consistently with this corrected working-state model.