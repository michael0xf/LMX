# Revised follow-up to Fable — restore load/dirty caching at the author's request

**Historical-note correction, 2026-09-30.** The author-approved restoration of load/cache/dirty and its publication boundaries remains active. The changelog below also mentions the former canonical-cell/sticky/selector implementation and an argument's prepared own field; those statements record the earlier revision, not the current contract. [Assignment is not declaration](assignment_is_not_declaration.en.md) and [L2 §18.2–18.3](../L2_spec_en.md#lowlevel-address) supersede them: explicit/hidden inputs remain activation-local with no field or publication target, declared `@x` addresses actual typed data, and address-taking alone never dirties or publishes a clean working cache. No persistent data-only companion is introduced. The historical changelog is retained rather than rewritten as evidence for the new rule.

**To:** Fable / fable_pc  
**Scope:** aligned documentation corrections in `docs/LMX_semantics.en.md` and `docs/LMX_semantics.ru.md`, following `response48.md`.  
**Reviewed snapshots:** `LMX_semantics.en(5).md` and `LMX_semantics.ru(4).md`. Section numbers, anchors and exact phrases below are primary locators; line numbers refer only to these snapshots.  
**Status:** the restoration of local load/dirty caching in §1 is the author's explicit latest request. The proposed resolution of the remaining `sig` ambiguity is a reviewer proposal, not a new author-approved language rule.

## 1. Author request: restore load/dirty caching, not mandatory direct writes

The author explicitly requests:

> «Тогда наоборот давай попросим вот это удалить "there are no caches, dirty marks, working copies or checkpoints" и вернуть нормальное load и dirty как кеширование. Напиши еще раз и укажи что последнее — моя просьба».

Accordingly:

> **Remove the categorical prohibition of caches, dirty marks, working copies and checkpoints. Restore ordinary local working values with load/dirty caching and write-back under the applicable publication contract. This is the language author's request, not the reviewer's inference.**

The previous instruction to remove the remaining `dirty` sentence and make every bare assignment a mandatory immediate graph write is **withdrawn**. Any dependent recommendation based on “working-field publication no longer exists” must also be reconsidered.

Do not ask again whether the author wants load/dirty caching restored: that question is answered. Questions about an exact observation, checkpoint, or reload rule remain appropriate where the existing author decisions do not settle them.

Do not justify this restoration by counting passages in an older revision. Older snapshots contained both cached and direct-write descriptions, and the review previously confused their authority. The governing basis is the author's latest request above. Restore the mechanism coherently rather than reverting whole documents and losing the accepted `response48.md` changes.

### 1.1 What must be described

Local computation and the retained graph field are distinct representations of the relevant state. The restored description must cover the following operations under the existing field, argument and ownership contracts:

- **Load / initialization:** obtain the local working value from its resolved source. For an own field this can be a graph load; an explicit or hidden input can already supply the initial local value. Do not overwrite a correctly supplied input with an unrelated old graph value merely to perform a uniform “load”.
- **Local work:** reads and arithmetic use the working value. Loading or reading a value does not itself mark it dirty.
- **Accepted assignment:** update the local working value and record that its associated own-field destination needs write-back. Failed admission does not commit the attempted write or newly mark the destination dirty; an earlier valid pending change is not erased by that failure.
- **Write-back:** at the applicable publication/checkpoint boundary, publish the required dirty working values to their corresponding own fields. A clean cached value must not be written back merely because it was loaded.

These are implementation operations, not new source receivers named `load` or `dirty`. In particular, this request does **not** reintroduce raw L2 memory access into L3 source code.

A local cache does not create a second persistent graph field at each assignment site. Keep the established locations of declarations, the fixed graph layout, and the distinction between a callable's fields and fields declared in nested bodies. An explicit or hidden argument's local assignment targets the method's own prepared state under the established rules; it is not copy-back into the caller's argument source.

Ordinary Structure/Array passing still passes a reference, not a deep copy. Restoring a cached reference value must not be described as silently copying its referent.

### 1.2 Suggested replacement passage

Use this substance in the working-state section, integrating it with the already established rules rather than appending a second conflicting model.

**EN:**

> Execution uses local working values initialized from their resolved sources. An admitted local assignment updates the working value and marks its associated own field dirty. At the publication points defined for the activation, dirty working values are written back to their corresponding fields; clean cached values are not published merely because they were loaded. A local assignment to an explicit or hidden argument does not write back to the caller's argument source. Explicit reference-path accesses retain their own graph-access contract. The visibility of cached values through aliases, nested calls and external observation follows the established publication and reload rules; it is not determined by an assumption that every assignment immediately writes the graph. This caching mechanism neither adds a graph field at every assignment site nor creates an implicit deep copy of referenced objects.

**RU:**

> Исполнение использует локальные рабочие значения, инициализируемые из разрешённых источников. Допущенное локальное присваивание меняет рабочее значение и отмечает связанное с ним собственное поле как `dirty`. В установленных для активации точках публикации изменённые рабочие значения записываются в соответствующие поля; чистые кэшированные значения не публикуются только потому, что их загрузили. Локальное присваивание явному или скрытому аргументу не записывается обратно в источник аргумента вызывающего выражения. Явные обращения через ссылочные пути сохраняют собственный контракт доступа к графу. Видимость кэшированных значений через псевдонимы, вложенные вызовы и внешнее наблюдение определяется установленными правилами публикации и перечитывания, а не предположением, что каждое присваивание немедленно пишет в граф. Кэширование не добавляет поле графа в каждом месте присваивания и не создаёт неявную глубокую копию объектов по ссылкам.

The reference to “established rules” is not a substitute for documenting those rules. Locate the previously approved contract, state or cross-reference it precisely, and ask the author about any unresolved boundary before marking the section complete.

### 1.3 Do not invent a coherence policy while restoring caching

The request confirms caching. It does not, by itself, answer every ordering question.

Distinguish **write-back** from **reload**. Writing dirty locals to the graph does not automatically imply reloading all caller locals after every call. Conversely, keeping a value local does not by itself authorize arbitrary stale observations through every explicit path.

Use already recorded author decisions for the following cases. If they are not sufficient, submit the smallest unresolved example to the author:

| Observation or boundary | What must be determined from the approved contract |
| --- | --- |
| A local write followed by an explicit path read of the same field | Whether this access requires publication or reads the previously published graph value |
| A nested call/callback writes that field through an explicit path | Whether and when an outer cached value is reloaded, and what a later outer write-back does |
| Outbound calls, argument evaluation and foreign callbacks | Which dirty values must be visible, and in what order argument evaluation and publication occur |
| `return`, `throw`, diagnostic termination and `finally` | Publication and cleanup order, including changes made by cleanup |
| `yield` and resumption | What is published at suspension and what local/dirty state is retained |
| `retry` and loop transfers | Whether there is a boundary at all; do not add publication to every jump by guesswork |
| Graph copying, serialization or observation | Which already established boundary supplies the observable state; do not add AI-specific flush semantics |

For example, an older §14 explicitly ordered: evaluate/retain the result, publish dirty own fields, run cleanup, publish fields dirtied by cleanup, then transfer control. It also said clean caches are not published and the caller is not reloaded. That is useful restoration material, **not proof that every older sentence is authoritative**. Retrieve the corresponding author decision; retain it when applicable and ask if it conflicts with another confirmed rule. [Previous EN snapshot `en(4)`, §14, lines 757–761.]

Do not create a new global alias-coherence service, a new closure record, a universal reload after every call, or a different language semantics for the native and interpreted paths. No such design is requested.

### 1.4 Patch all dependent direct-write claims, not just one sentence

The reviewed `en(5)` / `ru(4)` snapshots contain the following affected passages:

| Location | Existing wording or assumption | Required treatment |
| --- | --- | --- |
| §4, `#fields`, line 114 | A bare assignment writes directly; there are no working copies, dirty marks or checkpoints | Restore the local-working-value / dirty / own-field publication explanation |
| §8 case 5, line 504 | Direct writes with no local cache, dirty mark or checkpoint | Align the recipe with the restored working-state contract |
| §9, `#construction`, line 562 | The surviving local-cache / dirty sentence | **Do not delete it as obsolete.** Reconcile its terminology with the restored common rule; keep ordinary admission and source-locality rules |
| §10, `#qualification`, line 593 | The no-rollback explanation was rewritten around direct instance writes | Check the wording against restored publication; preserve qualification and no-transaction semantics |
| §12, `#dynamic`, lines 649–651 | Direct own-field writes and assignment explanation | Distinguish local updates from graph write-back without moving the destination or inventing additional fields |
| §12, lines 679–685 | “There are no caches”; “There is no publication”; no dirty/checkpoints; immediate observation after a nested write | Replace the whole dependent explanation, not just its negative sentence. Resolve alias visibility using §1.3 above |
| §12, recursive trace and explanation, approximately 690–708 | Graph observations shown without distinguishing local state from a publication point | Preserve activation identity and recursion rules; identify the observation boundaries required by the restored model |
| §12, line 725 | Loop example explained by universal immediate field visibility | Keep its source program. Explain its observation using the approved publication/argument-evaluation order, or ask where not settled |
| §12, line 731 | Calls, returns, throws, diagnostics and yields require no publication | Replace the blanket denial with the applicable boundary rules |
| §14, `#exits`, lines 759–763 | Cleanup assumes fields are always current; reload rationale assumes shared direct storage | Restore the approved publication/cleanup ordering; do not invent reload merely to preserve the former rationale |
| §15, `#exceptions`, line 823 | “publication and cleanup” | Clarify working-field publication under restored §14; keep it distinct from outgoing Message publication (§4 below) |
| §16, `#suspension`, lines 832–834 | Retry/yield explanations use direct field state or deny publication on that basis | Apply the approved transfer/suspension contract. Do not infer a new checkpoint at every transfer |

This map identifies what to review, not a blind line-replacement script. Search the matching current paragraphs in the repository. An unaffected example should not be rewritten simply to make an editorial patch easier.

### 1.5 Representation and performance

Describe `dirty` as write-back information, not a compulsory new flag inside every persistent Structure. The task does not prescribe whether a backend represents it with local flags, an interpreter record, or statically determined stores. Any representation must preserve the approved observable behavior.

The author's purpose is to retain local computation and avoid forcing every elementary local operation through graph storage. Do not claim that every direct store necessarily incurs a full graph traversal, or that a specific speedup has been measured. No benchmark is part of this documentation task.

## 2. Remaining `sig` issue — keep the observation and propose a Consumer-relative correction

This issue is **not cancelled** by restoring caching.

### 2.1 What still conflicts

In §7, `#three-argument-implements`, the equation still contains:

```text
sig(aVar.p) = sig(bVar.p) = ExpectedSig(Consumer, p)
```

The prose at line 449 distinguishes the accepted interface, mandatory supply and formed implementation inputs, but says exact matching compares the **mandatory supply**, passing modes, result and exits. §8 case 8, line 519, repeats “a match over the mandatory supply”.

The notation therefore needs a precise meaning. Comparing complete unprepared descriptors, comparing only mandatory inputs, and checking a concrete call after ordinary argument formation are different descriptions.

### 2.2 Minimal counterexample

These are contract sketches, not new LMX source syntax. Assume the same result type, no extra dynamic requirements and no converter that changes the argument structure.

```text
A accepts: x: int, optional y: int with default 5
B accepts: x: int
Both return int.
```

Both require only `x` to be supplied, but a Consumer using:

```text
f(1; y: 25)
```

cannot use B as the target: B accepts no `y`. Do not silently drop the supplied argument. Equality of mandatory sets `{x}` is therefore insufficient.

For a Consumer using only `f(1)`, A's extra optional `y` is not by itself a call-shape obstacle: the already accepted default supplies it. This does not certify behavior or bypass the Consumer's tests.

### 2.3 Proposed wording and method of correction

**Reviewer proposal, subject to author confirmation where it resolves the remaining formal ambiguity:**

> For each use of a callable visible in Consumer, compatibility must account for the arguments that Consumer actually supplies, including explicitly supplied optional parameters. The selected callable must accept those arguments under the ordinary formation and conversion rules. Inputs not supplied explicitly must be obtainable from their permitted sources: formal defaults for omitted defaulted formals, and the existing dynamic/lexical sources for free inputs. The formed inputs must satisfy the selected implementation's actual descriptor, and its result must satisfy the receiving requirement after any admitted conversion. Passing modes, declared exits and the applicable ABI constraints remain checked under their existing contracts. Equal sets of mandatory arguments are not a sufficient substitute for this check.

Use this to clarify **the existing** admission mechanism, not to introduce a second receiver, global compatibility registry, optional-argument erasure pass or hidden wrapper mandated for every call.

Analytical checking reasons about the available descriptions and conversions; it must not start executing callable bodies, default expressions or converters merely because the explanation uses the word “prepare”. Actual preparation and execution remain governed by their existing stages. Mandatory Consumer tests still follow the analytical stage.

If a callable path is used at several visible call sites with different supplied arguments, the corrected notation must cover those uses rather than collapse them to one arity. Preserve the existing analytical coverage limits; do not add whole-heap analysis or arbitrary expansion of callee bodies.

Clarify the existing equation and §8 case 8 together. Do not leave the old equality as a contradictory normative formula beside new prose. Exact descriptor satisfaction after formation is not permission to declare distinct original interfaces equal.

**Question to the author when not already answered by a recorded decision:**

> What does `sig` denote in the equality in §7 after defaults are introduced, and how does it account for an optional parameter that this Consumer supplies explicitly? May we express this as the existing Consumer-relative call check after ordinary input formation, without erasing optional parameters or requiring equality of unrelated unprepared interfaces?

Do not re-ask whether `add5(1; y: 25)` is legal; that is already approved. The open point is the unambiguous formulation of compatibility.

## 3. Fix the ambiguous antecedent in §8 case 9

At line 524, the inserted sentence about a defaulted formal is followed by “Adding one changes `DynRequired`” / «Добавление такого имени меняет `DynRequired`».

Make the subject explicit; no semantic decision is needed to identify which kind of name is intended here.

**EN replacement:**

> The body's free dynamic names are part of its interface. A formal with a provided default value is not a free name: it is not in `DynRequired` and remains part of the accepted interface. Adding a new free dynamic name to the body changes `DynRequired` and the corresponding call requirements; known callers require rechecking, while runtime-selected callables remain subject to actual-call admission.

**RU replacement:**

> Свободные динамические имена тела входят в его интерфейс. Формал с предусмотренным значением по умолчанию — не свободное имя: в `DynRequired` он не входит и остаётся частью принимаемого интерфейса. Добавление нового свободного динамического имени в тело меняет `DynRequired` и соответствующие требования вызова; известные вызывающие выражения требуется проверить заново, динамически выбранные остаются под допуском фактического вызова.

Retain the rest of the paragraph about occurrence mutability, replacement and behavioral tests. After §2 is resolved, connect “call requirements” to the final definition of `sig` rather than introducing another meaning.

## 4. Clarify `assert`: field write-back is not Message publication

The previous review treated “publication and cleanup” in §15 as potentially obsolete because it assumed the no-cache model. **That assumption is withdrawn.** Working-field publication has a place in the restored model; the sentence must name the relevant contract, not delete the operation.

At line 823, replace the ambiguous phrase by a cross-reference to the restored diagnostic-exit ordering.

**Suggested EN wording:**

> In the actor profile, diagnostic termination follows the activation's working-field publication and cleanup rules in §14 before the diagnostic is delivered to the executing Message's diagnostic root. That Message stops executing and receives no further turns. This does not make the failed turn successful or authorize publication of its pending outgoing Messages; those remain governed by §25. Stopping execution and destroying the object remain distinct.

**Suggested RU wording:**

> В акторном профиле диагностическое прекращение выполняет правила публикации рабочих полей и очистки активации из §14 до передачи диагностики корню исполняющегося Message. Message прекращает исполнение и больше не получает тактов. Это не делает неуспешный такт успешным и не разрешает публикацию его ожидающих исходящих писем: они по-прежнему подчиняются §25. Остановка исполнения и уничтожение объекта различаются.

Use this wording once the §14 order is established from the approved contract. Do not invent a special forced store to inaccessible or invalid storage on `assert` failure. Any unresolved exceptional case is a question for the author.

Keep the three meanings separate throughout the text:

```text
working-field write-back:  local dirty value -> associated graph field
construction publication: fully built result becomes available
Message publication:      prepared outgoing mail -> published delivery state
```

Restoring the first does not change the third. §25's existing success/failure treatment of outgoing mail and the lack of automatic rollback of previous graph effects remain intact.

## 5. Preserve the accepted response48 decisions

The following are not being reopened by the caching request.

**Native code.** Unchanged executable code retains its matching `native` over copied/composed data. Selecting another whole ready body selects its matching implementation. Changed code without a corresponding implementation cannot use the former address. A change to data under a part named `body` is not automatically a change to executable code. The 2026-09-25 interpreted-result statement concerned changed bodies, not every `merge`.

**Formals and defaults.** A defaulted formal remains explicitly passable. For the formal-`y` example:

```text
add5(1)                       -> 6
add5(1; y: 25)                -> 26
add5(1; y: 0)                 -> 1
caller-local y = 25, omitted y: add5(1) -> 6
add5(1; y: 25), then add5(1)  -> 26, then 6
```

The last line assumes the default's source was not explicitly changed. Do not let dirty write-back of an activation's working argument silently overwrite the default's source. Preserve the existing distinction between those roles; if their representation is unresolved, ask rather than creating a second hidden environment.

**Free dynamic names.** A free `n` in `addN` remains a free input with dynamic-before-lexical priority. It does not become a formal merely because its lexical fallback was copied. Cache initialization must use the value selected by this priority; explicit `node\n` remains a graph access, not that dynamic local.

**Composition and types.** `merge` does not become an argument binder. The declared callable header is the receiving-place contract, not an extra implicit operand. Defaults are ordinary call preparation, not a special `merge` facility.

**Copying and sharing.** Copy ordinary used Structures and lexical relations under the existing rule. Reusing a native implementation does not retain the original mutable occurrence. Preserve the `independent: const: immutable` whole-branch exception and its lifetime/protection rules.

**Other boundaries.** Do not change Message ownership, ordinary reference passing, storage handoff, type-conversion context, cleanup obligations, or the confirmed last-occurrence name rule as a side effect of this patch.

## 6. Editing workflow and acceptance checks

Make the bilingual documentation patch against the current canonical files, not by restoring an entire older snapshot. Record the author request in §1 as the reason for the state-model change; record the separate resolution of §2 when obtained.

| ID | Check |
| --- | --- |
| F49-01 | The change log explicitly attributes restoration of load/dirty caching to the author's latest request and withdraws the reviewer's opposite instruction |
| F49-02 | No remaining normative passage categorically forbids local caches, dirty marks, working copies or their publication boundaries |
| F49-03 | Loads/reads alone do not mark values dirty; accepted local changes can require own-field write-back; clean values are not blindly published |
| F49-04 | Failed assignment does not commit its candidate or newly dirty the destination; an earlier valid pending write is not discarded by that failure |
| F49-05 | Local explicit/hidden argument assignment does not write back into the caller's argument source; field locations and recursion ownership remain unchanged |
| F49-06 | Alias/path reads, nested writes, callbacks, exits and suspension have documented author-approved boundaries or are explicitly reported as blocked questions |
| F49-07 | Write-back is distinguished from reload; no universal automatic reload or new alias-coherence mechanism is introduced by inference |
| F49-08 | `finally` and diagnostics use the restored field-publication contract without promoting a failed turn's pending mail to successful publication |
| F49-09 | Consumer's explicit use of optional `y` is not erased by a mandatory-only signature comparison; §7's equation and §8's recipe agree |
| F49-10 | Adding a defaulted formal is not called adding a free dynamic name in the `DynRequired` paragraph |
| F49-11 | All accepted `native`, default, free-input, composition and qualified-branch examples remain consistent |
| F49-12 | EN/RU say the same thing; anchors and numbering remain stable; the report distinguishes text checks from any actual runtime tests |

Deliver the EN/RU edits, their diff, a short change map and any precise unanswered questions. No runtime rewrite is authorized merely by this documentation task.

## 7. Mandatory rule for contradictions

> **If an agent finds a contradiction, ask the language author before choosing a semantic resolution. Quote the conflicting passages, show the smallest case with different consequences, and state the exact unanswered question. Do not silently invent a rule, choose by implementation convenience, or treat the reviewer's proposal as an author decision.**

Already answered points are applied, not re-asked. In particular, **restoring load/dirty caching is now an explicit author request**. Unanswered checkpoint, reload or `sig` questions block only the dependent change; unrelated edits can proceed. A complete-looking document with an invented answer is not an acceptable substitute for the author's decision.

## Applied (fable_pc, 2026-09-28; v1 applied in 9ae0b33, v2 in this commit)

Edited: `provenance/semantics-book.md` (both languages, one paired file; `docs/LMX_semantics.{en,ru}.md` regenerated by `tools/build_semantics.py`), `docs/L2_spec_{en,ru}.md` §10 and §18.2, `next_core_tasks.md` (§5 header, new §7b before GATE, a blocking GATE item), `LMX_blog/q/current/q49.md`. `check_docs` passes. Section numbers below are the generated documents'. Text checks only; no runtime test was run for this task.

**Change log (F49-01).** The restoration of load/dirty caching is made on the author's latest request quoted in §1 («…вернуть нормальное load и dirty как кеширование…»); the reviewer's earlier opposite instruction (the reading of the 2026-09-25 words as "no caches, dirty marks or checkpoints", applied as N02 in 9f64ab8) is withdrawn and its record in `merge_documentation_corrections_next.en.md` marked superseded. The wording was restored site by site against the current canonical files, not by reverting a snapshot; the accepted `response48.md` changes (`native`, defaults, free names, composition, copying) are untouched.

**Change map (§1.4).** §4 `#fields` (`node` paragraph): the assignment binds the local cache and marks it `dirty`, the checkpoint publishes into the own field, never into the hidden argument's source. §8 case 5: same. §9 `#construction`: the surviving cache/dirty sentence kept and reconciled — on failure neither the target nor its `dirty` state changes, the candidate is not committed, the destination is not newly marked, an earlier admitted pending write is not erased (F49-04); executing a bare assignment binds the local cache to the prepared own occurrence and marks it `dirty`. §10 `#qualification`: no rollback of pre-call publication of working fields; protection covers publication of working fields. §11: each activation's frame holds working copies of the own fields it uses, loaded and marked `dirty` under the same rules in both modes. §12 `#dynamic`: the working value is loaded from its resolved source (a graph load for an own field; an input already supplies the initial value and no old graph value is loaded over it), loads and reads do not mark `dirty` (F49-03), an admitted assignment updates the working value and marks the own field `dirty`, only own fields used by a bare name or forwarded are cached, only `dirty` fields are published before control passes to another callable and marks are cleared, a clean cached field is not written back, the caller does not reload after return (F49-07), `dirty` is write-back information and not a mandatory flag (§1.5), publication before a foreign boundary, the nested `node\x` write leaves the caller's cached value until its own next write, the recursive trace S/I2 with working values and the published `S\x`, the loop example explained by the publication/argument-evaluation order (`9 0`), the boundary sentence replaced by the applicable list. §14 `#exits`: the order evaluate/retain → publish dirty own fields → cleanups → publish fields dirtied by cleanup → transfer; clean cached fields not published; calls within cleanup have ordinary publication boundaries (F49-08). §15 `#exceptions`: the v2 §4 wording — diagnostic termination follows the working-field publication and cleanup rules of §14, the failed turn is not made successful and its pending outgoing Messages stay under §25. §16 `#suspension`: `retryable` rolls back neither published fields nor Messages, `retry` publishes nothing merely because of the transfer, `yield` publishes dirty own fields before suspension and resumption does not reload. L2 spec §18.2: writing through the address of an own field changes the graph cell and neither assigns nor dirties the working copy; `\p: 9` after `p: @x` leaves bare working `x` at 5 while an explicit graph read sees 9; §10: composition through `merge` gives a formal its default and binds nothing; the used own fields are loaded, dirtied and published at the checkpoints §12 defines.

**Boundaries (§1.3, F49-06).** Each row of the §1.3 table is answered by the book's established working-state text (the `#dynamic`, `#exits`, `#suspension` chapters as written before the 2026-09-25 reading, commits 5b6e985 "Document occurrence publication semantics", 57c3a2e, 8cab5bc; the plan's §5 canonical cell / sticky / checkpoint mechanism the author's tickets -188/-189 measured), now restored: a local write followed by an explicit path read of the same field reads the previously published graph value (`for\j` reads 0; `end: for` and the read itself are not checkpoints); a nested call writing the field through an explicit path does not reload the outer cached value, and a later outer write-back publishes the outer's new value (the S/I2 trace); before control passes to another callable the dirty own fields are published, and actual arguments are evaluated before that publication (`9 0`); `return`, `throw`, diagnostic termination and an exit with `finally` follow §14's two publications; `yield` publishes dirty own fields and retains working values; `retry` and loop transfers are not boundaries; graph copying, serialization or observation from outside is the foreign-boundary publication. No two confirmed rules were found to conflict, so no boundary question is filed; no reload, alias-coherence service or flush semantics was added.

**`sig` (§2, F49-09).** §7's prose describes the Consumer-relative mechanism (the Consumer's use imposes the supplied arguments, the candidate's accepted interface must accept them, missing inputs are formed by defaults and permitted conversions, the formed call must satisfy the selected callable's descriptor, result/exits/modes must satisfy the Consumer; the A/B example). Resolved by the author (Q49, 2026-09-28, `LMX_blog/q/q49.md`, `LMX_blog/2026-09-27.md`): variant (а) — the equality is replaced by the directed check of the candidate against how the Consumer uses it. The formula block now reads `∀ u ∈ calls(Consumer, p): accepts(iface(aVar.p), supplied(u)) ∧ formed(aVar.p, supplied(u)) ⊨ descriptor(aVar.p) ∧ result_exits_modes(aVar.p) ⊨ expects(Consumer, u)` in both languages, the prose defines the symbols, the exemplar `bVar` drops out of the leaf check (its role is the collection of `uses`), equality of complete unprepared signatures is neither required nor declared, and §8 cases 1, 8, 9 plus the "equal signatures make the call admissible" sentences read through that check. This also carries out the author's earlier ticket in `next_core_tasks.md` §7 (the `call_arguments_formable` / `formed_call_matches_exactly` / `result_consumable` sketch, whose predicate names were declared free).

**`DynRequired` (§3, F49-10)** — the v2 wording verbatim in both languages. **`assert` (§4)** — the v2 wording in both languages, with the three publications kept distinct (working-field write-back, construction publication, Message publication). **§5** — unchanged and re-read: `native`, defaults (`6 / 26 / 1 / 6 / 26-then-6`), free `n`, composition, copying. **F49-02** — no normative passage forbids caches, dirty marks, working copies or their publication boundaries. **F49-05** — the local assignment to an explicit or hidden argument writes back into the body's own field, never the caller's source; field locations and recursion ownership unchanged. **F49-11/12** — both languages edited in the same places; the build's structural equality check passes.

**Implementation.** The author's request «постарайтесь реализовать на данном этапе» is in `next_core_tasks.md` §7b (before GATE and the self-build) and a blocking GATE item; the lead has the request and takes §7b after the running slice.
