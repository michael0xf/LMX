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

## Applied (fable_pc, 2026-09-28)

Edited: `provenance/semantics-book.md` (both languages, one paired file; `docs/LMX_semantics.{en,ru}.md` regenerated by `tools/build_semantics.py`), `docs/L2_spec_{en,ru}.md` §10 and §18.2, `next_core_tasks.md` (§5 header, new §7b before GATE, a GATE item), this file (line endings normalized to LF without BOM, the project's rule; the text is untouched). `check_docs` passes. Section numbers below are the generated documents'.

### 1. The load/cache/dirty model restored

**Decision record.** The author's decision of 2026-09-28 (this file, §1) supersedes the reading, recorded in `merge_documentation_corrections_next.en.md` "Applied", N02, of the author's 2026-09-25 words as "no caches, dirty marks, working copies or checkpoints"; that record now says so. The execution pair (code and data as roles by position, a fresh data instance on re-entry; the author, 2026-09-25, Q27–Q29) is unchanged, and so are every later decision (Q22.2, Q44, Q48). The wording restored is the book's own pre-2026-09-25 wording (the commit before `b2a8b24`), merged with the instance model where the two met (the recursive trace).

**Edit map.** §4 (`node` paragraph): the assignment binds the local cache, marks it `dirty`, the checkpoint publishes into the own field, never into the hidden argument's source. §8 recipe 5: same. §9: on failure neither the target nor its `dirty` state changes; executing a bare assignment binds the local cache to the prepared own occurrence and marks it `dirty`. §10: qualification does not roll back pre-call publication of working fields; protection applies to writes and to publication of working fields. §11: each activation receives an ordinary frame with working copies of the own fields it uses, loaded and marked `dirty` under the same rules in both execution modes. §12: the own field's working value is loaded for the activation, assignment marks it `dirty`, a checkpoint publishes it; the bare-assignment rule binds the cache (no previous graph value is loaded over the input, an untaken branch does not activate the binding, publication targets the body's data instance); only own fields used by a bare name or to forward a dynamic input are cached; before control passes to another callable only `dirty` own working fields are published and marks are cleared, a clean cached field is not written back, the caller does not reload after return; `dirty` follows an executed write and is semantic working-state information, not a mandatory physical flag (the native translator may know statically, the interpreter may keep a bit or a bitmap); publication in forward field order and before a foreign boundary; after a nested `node\x` write the caller's bare working `x` may retain its earlier value while the explicit path sees the new one; the recursive trace S/I2 rewritten with working values and the published `S\x` (pre-call publication, the inner instance publishes into I2, the outer keeps 2 until its next write); a declared field combines the persistence of an instance field with the working locality of a stack variable; the `for`/`print` example is `9 0` again (`acc` from the cache, `for\j` the previously published graph value; `end: for` is not a checkpoint); publication is required at call, return, `throw`, diagnostic termination and `yield`, with the two publications of an exit with `finally`. §14: the exit order publishes dirty own working fields before cleanups and own fields dirtied by cleanup after them; clean cached fields are not published; calls within cleanup have ordinary publication boundaries. §16: `retry` publishes nothing merely because of the transfer, `retryable` rolls back neither published fields nor Messages, `yield` publishes dirty own fields before suspension and resumption does not reload. L2 spec §18.2: writing through the address of an own field changes the graph cell and neither assigns nor dirties the activation's working copy; `\p: 9` after `p: @x` leaves bare working `x` at 5 while an explicit graph read sees 9; §10: an argument becomes a data field by the assignment rule or by composition through `merge` (a formal's default), and the used own fields are loaded, dirtied and published at the checkpoints §12 defines, the physical form of `dirty` being the backend's.

**Checkpoint audit (§1 of the note, "do not invent them").** The boundaries are the book's own list, all restored from its earlier text: before control passes to another callable expression (call); return; `throw`; diagnostic termination; `yield`; the two publications of an exit with `finally` (before and after cleanups); a foreign boundary capable of calling back into LMX or exposing graph state. `end: for`, an explicit path read, `retry` and a local loop transfer are not checkpoints. No two rules were found to disagree; no boundary is invented. Outgoing Message publication (§22 end-of-turn, §25 delivery, §28 `post`) is a separate mechanism and is untouched; §15 `assert` ("publication and cleanup precede delivery to the diagnostic root") refers to the working-field publications of §14 and stays.

### 2. Callable `sig` (note §2)

§7's prose now describes the Consumer-relative mechanism in the author's order: the Consumer's actual use of `p` imposes requirements; the candidate's accepted interface must accept them; missing inputs may be formed by its ordinary defaults and permitted conversions; the formed call must satisfy the selected callable's descriptor; result, exits and passing modes must satisfy the Consumer; the `A`/`B` example (`f(1)` both, `f(1; y: 25)` only `A`) is in the text; an optional formal is removed neither from `sig` nor from the body's requirements or the ABI. The formula `sig(aVar.p) = sig(bVar.p) = ExpectedSig(Consumer, p)` is left as it was, because the existing meaning of `sig`, `ExpectedSig` and `implements` does not uniquely determine how to write the mechanism: `LMX_blog/q/current/q49.md` asks the author, with the two conflicting positions, the smallest example and two candidate notations. The answered question (a defaulted formal remains explicitly passable) is not reopened.

### 3. `DynRequired` (note §3)

§8 recipe 9 now carries the note's wording verbatim in both languages ("A formal with a provided default value is not a free name: it does not enter `DynRequired` merely because it can be omitted, and it remains part of the callable's accepted interface. Adding a **new free dynamic name to the body** changes `DynRequired` and therefore the corresponding callable requirements").

### 4. `assert` / failure wording (note §4)

Re-read under the restored model: §15 `assert` "after publication and cleanup" is the working-field publication of §14 and is retained; §14 exits, `finally`, return and cleanup are the two-publication order; §16 `retry`/`yield` as above. Nothing conflates working-field publication with Message publication; no boundary was deleted or invented.

### 5–7. Preserved

`merge` binds no argument (§11, §20; the L2 spec §10 phrase "or by binding through merge" corrected to composition giving a formal its default); the declared header is the receiving place's admission contract; a defaulted formal is governed by ordinary call preparation. `native` rules of §20 (unchanged body keeps its implementation; another body brings its own; a changed body without one is interpreted; the 2026-09-25 confirmation scoped, not reversed) untouched. Copying versus physical sharing untouched: ordinary Structures and lexical graph copied, the `independent: const: immutable` branch the single retained exception, native implementation reuse is not a shared mutable graph.

### 8. EN/RU audit

Counts in the generated documents (EN/RU): dirty 18/16, checkpoint 5/RU «контрольн»… , cache 15/RU «кэш», working state 4, working copy 0 (the RU says «рабочая копия/рабочее значение»), publish+publication 69/RU «публик…», `sig(` 3/3, ExpectedSig 1/1, DynRequired 2/2, default 35/RU «по умолчанию», optional 10/RU «необязательн», accepted interface 5/RU «принимаемый интерфейс», mandatory supply 2/RU «обязательная подача», formed inputs 1/RU «сформированные входы», native 50/8 (the RU writes «нативн…»), merge 54/51. Classification: every "dirty", "cache", "checkpoint", "working state" occurrence is the working-state model of §§4, 8, 9, 10, 11, 12, 14, 16 (plus §1's "implementation may cache resolved bindings", an optimization statement, and §9's "cached physical addresses", both unrelated to fields); "publication" occurrences split into working-field publication (§§4, 8, 10, 12, 14, 15, 16) and Message/child/queue publication (§§11 return-order pointer to exits, 22, 23, 25, 28), plus construction-time "before publication" of a built value (§9, §10) and the crypto profile's "publishes derived material" (ordinary storage); none conflates the two. "default"/"optional" occurrences in §§7, 11, 12, 20 are the defaulted formal, always distinct from a free dynamic input (§8 recipe 9, §12, §20). "native" occurrences in §§20, 23 are the reused implementation, never a shared mutable graph (§20 last sentence of the native paragraph). Both languages edited in the same places; the build's structural equality check passes.

### 9. Contradictions

One, filed as a question rather than resolved: the `sig` formula (q49). None on checkpoint boundaries. The implementation follows the note's request "at this stage": `next_core_tasks.md` §7b (steps before GATE and the self-build) and a blocking GATE item; the lead has the request.
