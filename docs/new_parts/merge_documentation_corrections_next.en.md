# NEXT — Fable task: resolve the remaining documentation contradictions with the author

**Scope:** a focused follow-up to `merge_documentation_corrections.en.md`, covering all outstanding findings from the review of the edited English and Russian semantics specifications.

**Targets:** the canonical `LMX_semantics.en.md` and `LMX_semantics.ru.md` in the working repository. The reviewed attachment snapshots are identified in §2.

**This is a documentation task, not authorization to change the runtime, invent language rules, or refactor the implementation.** The previous correction is substantially accepted. Preserve it while addressing the remaining issues below.

## 1. Mandatory rule: ask the author when rules contradict

> **If an agent discovers a contradiction, it must ask the language author before choosing a semantic resolution. Do not silently reconcile the rules, invent an exception, or implement the interpretation that is easier.**

This applies to conflicts within one document, between English and Russian versions, between specifications, and between a specification and the implementation or its tests. Section 1 of both current specifications already requires explicit discussion when rules contradict; this task makes the required author interaction explicit. [E/R, §1, `#scope`, line 59.]

For each unresolved contradiction:

1. Locate the actual conflicting passages in the current repository. Quote both, with file, section and a stable locator.
2. Show the smallest concrete case in which the readings produce different behavior. Distinguish source statements from your inference about their interaction.
3. Ask the author which rule governs, or which existing operation or scope distinction explains the apparent conflict. State the unanswered question precisely.
4. Suspend the affected semantic edit until the author answers. Independent editorial work may continue, but must not assume an answer to the blocked question.
5. Record the answer and then apply it consistently to both languages, affected explanations and examples. Report any further conflict revealed by that answer.

An existing, explicit author decision that already answers the exact question is sufficient: cite and apply it rather than asking the same question again. An agent's earlier inference, the current implementation, a passing test, the position of a paragraph, or the number of repetitions of a rule is **not** a substitute for that decision. Do not treat the reviewer's proposed reading as an author ruling either.

Do not introduce “first in this subsystem, last in that subsystem,” “native uses one state model, interpreted uses another,” or a special header-composition exception merely to make contradictory prose coexist. Such distinctions require an existing explicit contract or an author decision.

A question left unanswered remains **blocked**, not “resolved with a reasonable assumption.” A partial report listing blocked issues is preferable to silently completing a different language.

## 2. Sources, locators and accepted baseline

| ID | Reviewed source | Role |
| --- | --- | --- |
| E | `LMX_semantics.en(4).md` | Current reviewed English semantics |
| R | `LMX_semantics.ru(3).md` | Current reviewed Russian semantics |
| P | `merge_documentation_corrections.en.md` | Previous correction task and its D01–D12 documentation checks |

Use the latest corresponding repository files when editing. Attachment suffixes distinguish snapshots; they do not request new language variants. Section numbers, anchors and quoted phrases are primary locators. Source line numbers below are aids for these snapshots, not instructions to replace a line blindly. In particular, the repeated-name paragraph is at **E:122 but R:124**.

The state-model and occurrence-selection conflicts below predate the last patch. They were previously outside its scope; this follow-up includes them. Do not label them regressions introduced by the recent `merge` correction.

### 2.1 Preserve these accepted corrections

- Ordinary locally used lexical Structures and callable occurrences are copied under the general composition rule. Rewritten links among copies do not imply retention of the original ordinary objects.
- An unchanged reusable native implementation can retain its implementation reference. That does not retain an ordinary callable occurrence or its lexical context; file-level declaration is not a sharing exemption.
- The full qualification **`independent: const: immutable`** remains the confirmed graph-branch sharing exception. Retain the original physical reference under its existing owner, lifetime and protection contracts. Do not broaden this exception to one qualifier or a null parent alone.
- `merge` does not bind arguments, capture a caller frame, remove dynamic requirements merely by copying data, or freeze a free input at its copied lexical value.
- Ordinary dynamic-input precedence remains intact. Explicit `node\x` addresses the corresponding lexical graph. Independence cuts the external lexical parent, not caller-provided dynamic inputs or internal lexical links.
- Ordinary reference passing, result transfer and Message storage handoff remain distinct from `merge`. Do not make all reference transfers copy their referents.

These corrections are present in E/R §§11, 12, 20, 23 and 25. Keep the previous task's D01–D12 scenarios as regression checks. The source-to-copy map, cycle handling and qualified terminal exception are not subjects for redesign in this follow-up.

## 3. Work items

| ID | Finding | Required treatment |
| --- | --- | --- |
| N01 | Recursive composition of `args`/`return` versus whole-header replacement in §20 | Clarify with the author before resolving the semantic ambiguity |
| N02 | Deferred cache/`dirty` publication versus direct field writes | Obtain or locate the author's governing decision; align all affected prose afterward |
| N03 | Last-occurrence lookup versus first-occurrence descriptions and example | Obtain or locate the author's governing selection rule; align dependent uses afterward |
| N04 | Overloaded §20 paragraph and bilingual editorial consistency | Restructure without changing semantics; keep N01-dependent text blocked until answered |

The observations below establish conflicting or ambiguous descriptions. They do **not** preselect the answers to N01–N03.

## 4. N01 — callable-header composition is still ambiguous

### 4.1 Source evidence

Both E and R, §20, `#composition`, source line 892, first prescribe recursive composition:

> “`merge` proceeds part by part and recursively -- `args` with `args`, `return` with `return`, `body` with `body` -- under the rule above at every level: an operand's same-name field is written into the model's slot, a new one is appended.”

Later in the same paragraph:

> “the declared header overrides `args` and `return` (the signature of `add` disappears)”

The latter appears in the explanation of `merge(add; {y: 5}; the declared header)`, presented as ordinary composition rather than a special callable-conversion procedure.

The paragraph now correctly says that copied `y` does not override a caller-supplied dynamic `y`. **Do not misreport the remaining issue as failure to remove captured-constant semantics.** The remaining issue is how the description's parts are composed or replaced.

### 4.2 Observable distinction

Use this structural fixture, not a new source syntax:

```text
model.args:   [x, y]
header.args:  [x]
```

Under the stated recursive field-composition rule, the later `x` can update the corresponding slot, but absence of `y` does not itself describe deletion of that slot. Under whole-part replacement, the old argument list can instead become `[x]`.

These are different operations unless the existing language already explicitly identifies the step that selects one of them. Calling the result “ordinary composition” does not identify that step.

Also distinguish the explicit `args` description from the **complete signature**: §7 includes dynamic inputs and other requirements, and §8 case 9 says free dynamic names contribute to `DynRequired` and `sig`. The phrase “the signature disappears” must not imply disappearance of requirements still imposed by the body. [E/R, §7:449; §8:524; §11:607–609.]

### 4.3 Question to the author

> In the §20 example, when the model has `args = [x, y]` and the supplied header has `args = [x]`, what exact `args` structure should result? Does the ordinary recursive composition retain `y`, or does an explicitly expressed operation replace the whole argument description? If a different operation applies, which existing operation and at which step? How should the resulting explicit and dynamic requirements be stated without making `merge` bind arguments?

Provide the actual complete definitions behind `add`, `add5` and `makeAdder` if available in the repository. Do not invent missing definitions to force the numerical example to work. If the example is only explanatory shorthand, say so in the question.

### 4.4 Editing after the answer

Explain the actual sequence using the existing terms and author-approved rule: ordinary structural composition; any explicitly supplied description and its ordinary consumption; subsequent call-time provision of inputs. Name the affected parts precisely instead of saying the whole signature disappears.

Update the `add5` and returned-method explanations accordingly. Preserve the already corrected dependence on caller-supplied dynamic values. Do not repair the text by reintroducing partial application, a hidden capture record, silent removal of requirements, or an agent-designed deletion/replacement operator.

A pure copy and a program explicitly composing a different callable description must remain distinguishable. Check the outcome against §11's statement about copying and method signatures; ask if that check exposes another unresolved conflict rather than assigning an exception yourself.

## 5. N02 — choose one documented working-state contract with the author

### 5.1 Conflicting source families

The following passages are present in **both** reviewed versions:

| Location | Current statement |
| --- | --- |
| §4, `#fields`, line 114 | A bare assignment connects a local cache to a prepared own field, marks `dirty`, and a checkpoint publishes it |
| §8 case 5, `#admission-case-5`, line 504 | The same cache/mark/publication sequence is given as the recipe for a local write |
| §9, `#construction`, line 562 | Failed admission leaves the target and its `dirty` state unchanged; a bare assignment binds a cache and marks it |
| §12, `#dynamic`, line 647 | The own field is written directly, with no working copies or modification mark |
| §12, lines 677–683 | There are no caches or publication; paths see current instance fields; there are no `dirty` marks, working copies or checkpoints |
| §12, lines 723 and 729 | The loop example and call/return/throw/yield boundaries require no field publication |
| §14, `#exits`, lines 757–761 | Exit publishes dirty own fields, performs cleanup, publishes again, and transfers control; clean cached fields are not published and cleanup calls have publication boundaries |

In particular:

> “There are no `dirty` marks, working copies or checkpoints...” [E, §12:681.]

versus:

> “publish dirty own working fields; perform applicable cleanups; publish own fields dirtied by cleanup” [E, §14:757, excerpt.]

These are incompatible descriptions of the same mechanism unless a scope distinction is explicitly provided. None should be selected merely because it sounds more recent or better optimized.

### 5.2 Question to the author

> Which working-state model is authoritative now: direct updates to the current instance's fields as described in §12, or separate working copies with `dirty` tracking and publication checkpoints as described in §§4, 8, 9 and 14? If an existing explicit decision already settled this, please identify it. What observable write/visibility rule should apply through ordinary paths, nested calls/callbacks and cleanup?

Do not infer that different backends or different spellings use different models. Do not convert the contradiction into a new selectable execution profile.

### 5.3 Small observation cases to include in the decision

These are schematic observations, not a newly specified LMX program or a request to add a debugger protocol:

```text
A. Write an own field, then read that exact field through an allowed
   explicit path before any later call or return.

B. A nested call/callback updates that same field through an explicit
   path; after it returns, the outer activation reads its corresponding
   bare name.

C. Cleanup changes a field while an activation exits; another applicable
   cleanup or the next permitted observer reads that field.
```

Use actual legal fixtures from the current language when expressing these as executable tests later. Do not treat a different caller argument cell, a lexical-parent field and the current activation's own field as one location. The existing distinction between them is not under review.

Record the author-approved observations before treating one visibility behavior as the expected result.

### 5.4 Dependent wording to sweep

The sweep must cover more than the literal word `dirty`. Inspect `cache`, `working fields`, `checkpoint`, `publish`, `publication`, `reload`, and their Russian equivalents in context.

One directly related occurrence is §10:593, “pre-call publication of working fields.” Check explanations of return, diagnostic exits, suspension and cleanup for assumptions carried from either state model. Do not leave an obsolete operational story in an example after updating its main definition.

**Do not globally remove the word “publication.”** Publication of a fully constructed graph and publication/delivery of outgoing Messages are different from copying cached activation fields back into graph storage. The existing queue, ownership, turn and lifecycle contracts are not being reopened by this issue.

Likewise, compiler or implementation caching that preserves the approved observable behavior is not automatically the disputed semantic working-copy mechanism. Do not ban unrelated optimizations or rewrite Message-local type/conversion caching.

### 5.5 Editing after the answer

Write one coherent state model and cross-reference it from recipes and exit rules. Preserve unaffected properties: no implicit copy-back to the caller's argument source; the distinction between local rebinding and explicit referent mutation; ordinary result identity and lifetime; cleanup obligations and their established order; no newly invented transaction or rollback.

The question concerns field storage and visibility, not permission to delete `finally`, skip cleanup, copy whole methods on entry, change `node`, or move collection to every return. If the selected state model requires a further semantic decision about those boundaries, ask separately.

## 6. N03 — reconcile first/last occurrence selection with the author

### 6.1 Direct conflict

| Location | Current statement |
| --- | --- |
| §4, `#fields`, E:122 / R:124 | An unqualified name selects the **last** occurrence; `[0]name` is first, `[1]name` is second |
| §12, `#dynamic`, line 645 | Lexical lookup selects the direct **first** same-named occurrence |
| §9, `#construction`, lines 568–575 | With two `count` declarations holding 3 and 4, `result\count` is said to select **3** |

Preserve the existing example as the minimal evidence:

```text
(): result
    int: count 3
    String: text "hello"
    int: count 4
end: result
```

Under the currently stated occurrence numbering:

| Access | Result or question |
| --- | --- |
| `result\[0]count` | 3 |
| `result\[1]count` | 4 |
| `result\count` | 4 under last-occurrence selection; 3 under first-occurrence selection — author decision required for the conflict |

This table reports the conflicting readings; it is not permission to pick either one.

### 6.2 Related occurrences in the same rule family

Inspect these as part of N03, not as automatic instructions to change unrelated subsystems:

- §5, `#descriptions`, line 141: “A later same-name key does not displace the first without explicit occurrence selection.”
- §7, `#admission`, line 459: diagnostics may show “which first same-name branch composition selects.”

The first refers to converter keys; establish whether it is ordinary structural selection or an already explicitly specified different operation. The second must report the actual selection rather than introduce one. If a separate rule appears necessary but no author-approved rule exists, ask instead of creating an exception.

### 6.3 Question to the author

> Should the §4 last-occurrence rule govern unqualified field/path access and the selection within each lexical-search level, with the first-occurrence prose and `result\count = 3` example corrected? Or is another explicit rule intended? Please also identify whether converter-key selection in §5 follows ordinary occurrence selection or an already defined distinct operation.

If the exact last-occurrence decision and its scope were already explicitly settled by the author, cite that decision and update the contradictory remnants; do not ask again solely because an old paragraph survived.

### 6.4 Keep independent distinctions intact

The nearest eligible lexical level and the selected occurrence **within that level** are different questions. Resolving first versus last must not change the confirmed dynamic-before-lexical priority, the lexical traversal boundary, or the meaning of explicit `node\` access.

Also distinguish:

```text
a repeated declaration -> another occurrence;
assignment to an existing binding -> update of the selected cell;
merge of a matching model field -> update of the model's slot in the result.
```

A decision about lookup order does not authorize `merge` to append duplicates for matched fields, reverse storage order, renumber physical slots, or discard the full occurrence chain. Explicit occurrence numbers are not physical indices among all differently named fields.

### 6.5 Editing after the answer

Align §§4, 9 and 12; review §§5 and 7 under the same confirmed scope. Update the expected values in prose and any related fixtures, without deleting the two-`count` example to hide the discrepancy. Check explicit selectors as well as the unqualified path. Keep English and Russian statements equivalent.

## 7. N04 — make §20 readable without changing its contract

The reviewed §20:892 is a single paragraph of approximately four thousand characters in each language. It combines field layout, recursive parts, examples, callable descriptions, dynamic inputs, native implementation reuse and returned methods. This density made the N01 conflict difficult to see.

Split it into short paragraphs, using matching English/Russian subheadings where useful. A possible organization is:

1. Model slots, field matching and ordering.
2. Composition of structural parts.
3. Explicit callable descriptions, with the author-approved N01 explanation.
4. Dynamic sources and lexical fallback in examples.
5. Native implementation reuse versus copied callable occurrences.
6. Returned nested methods and the copied used context.

This is an editorial outline, not a new decomposition of the runtime. Keep the existing `#composition` anchor and section number. Preserve all substantive clauses, or identify each removal and its approved reason in the edit map. Do not append a second contradictory definition instead of replacing the rejected explanation.

Paragraph splitting and unambiguous terminology cleanup may proceed before N01 is answered. Do not use that restructuring to conceal or silently decide N01. The established `x = 10 / 25 / 40` fixture must keep its meaning. The `add5` example must continue to distinguish caller-supplied `y` from its fallback instead of promising an unconditional fixed result.

## 8. Bilingual edit workflow and boundaries

Work on the latest repository pair, not by copying old attachments over newer work. Record the starting revision or source hashes. Locate each finding by anchor and phrase before editing.

Maintain a small decision record for N01–N03 containing the conflicting sources, exact question, author answer or existing ruling, and affected locations. It is an editing record, not a new language subsystem. Where one author answer settles several questions, reuse it.

After the required decisions, edit the governing rule and its dependent explanations together. Compare the English and Russian versions as independent specifications: either one must convey the same result without depending on readers knowing the other language or this conversation.

Retain successful work from the prior patch. Do not roll back to the previous snapshots, reintroduce `binding through merge`, remove the eternal-branch exception, or restore file-level sharing of ordinary callable occurrences. Do not reopen postal dispatch, `answer` tables, timeout policy, or existing synchronization merely because the word “publication” appears nearby.

Inspect linked grammar and L1/L2 documentation where an affected rule depends on them. If those sources are unavailable, state that limitation; do not assert cross-document consistency. If available sources disagree, apply the author-question rule. Report any necessary implementation change separately rather than treating this documentation task as automatic permission to make it.

## 9. Acceptance checks

These are **documentation acceptance checks**, not a claim that runtime tests have been executed. Source fixtures need executable syntax and expected results only after the applicable rule is confirmed.

| ID | Check |
| --- | --- |
| NEXT-01 | Every semantic resolution for N01–N03 cites an author answer or an existing exact author ruling; unresolved cases remain explicitly blocked |
| NEXT-02 | No agent-created exception, backend split or profile is used to reconcile conflicting text |
| NEXT-03 | The `[x, y]` / `[x]` argument-description fixture has one explained, approved result |
| NEXT-04 | The text identifies the operation responsible for any complete description replacement; recursive composition and replacement are not conflated |
| NEXT-05 | “The signature disappears” does not erase dynamic inputs, failures or other requirements still imposed by the resulting callable |
| NEXT-06 | Copying lexical values still binds no arguments and does not suppress ordinary dynamic inputs |
| NEXT-07 | Bare `x` observes caller values 25 and then 40; explicit `node\x` observes lexical 10; absence of dynamic input uses permitted fallback |
| NEXT-08 | The N02 write/visibility observations agree throughout the definitions, recipes and examples |
| NEXT-09 | Calls, callbacks, return, suspension and cleanup are described using the same approved state model |
| NEXT-10 | No accidental removal of Message publication, endturn behavior, cleanup obligations, or no-copy-back rules occurred |
| NEXT-11 | The two-`count` example and unqualified lookup agree with the approved N03 rule; explicit selectors remain consistent |
| NEXT-12 | Converter-key and diagnostic wording either follows that rule or cites an explicit author-approved distinction |
| NEXT-13 | Declaration, assignment, merge-slot replacement, occurrence numbering and physical slot indices remain distinct |
| NEXT-14 | Ordinary callable occurrences are copied; native implementation reuse is not shared mutable lexical state |
| NEXT-15 | The combined `independent: const: immutable` exception remains intact with its owner/lifetime/protection conditions; no weaker qualification is substituted |
| NEXT-16 | Source-to-copy topology and cycle handling were not silently redesigned; ordinary references retained outside `merge` were not turned into copies |
| NEXT-17 | §20 is readable in both languages, without loss of rules, new receivers, or a second callable-conversion subsystem |
| NEXT-18 | English/Russian edits, anchors, cross-references and all affected example outcomes match; scope and unreviewed dependencies are reported honestly |

Rerun P's D01–D12 documentation checks as regressions, in addition to NEXT-01–NEXT-18. Keep a record of any example change: where, why and which author decision it follows. The reviewed files currently contain 57 fenced blocks each; preserving a number is not a substitute for preserving their meaning, and an approved example correction must not be concealed just to keep a byte-identical block.

## 10. Required deliverables

Provide the revised canonical English and Russian semantics files and a focused diff. Include a short edit map for N01–N04 and the author-decision record for the semantic issues.

Report each item as resolved with its ruling, editorially completed, or blocked with its exact unanswered question. Distinguish inherited inconsistencies from regressions, and distinguish documentation validation from any separately authorized and actually executed runtime testing.

The existing accepted `merge` correction should remain recognizable in the result. The purpose of this next pass is to remove contradictory explanations **under the author's decisions**, not to replace them with an agent's preferred architecture.

**Final gate: if two readings still imply different behavior and no explicit author decision resolves them, ask the author. Do not ship a silently chosen answer.**

## Applied (fable_pc, 2026-09-28)

Edited source: `provenance/semantics-book.md` (both languages, one paired file; `docs/LMX_semantics.{en,ru}.md` are regenerated from it by `tools/build_semantics.py`, which asserts equal paragraph, code-block, heading and link structure in both languages). Starting revision: `10c5043` (the author's commit of this task) on top of the previous correction `7e2554c`. `check_docs` passes. Section numbers below are the generated documents'.

### Decision record

**N01 -- resolved by the author's answer (2026-09-28, `LMX_blog/q/response48.md`; the question `LMX_blog/q/q48.md`, the analysis `LMX_blog/q/Answer48.md`; blog record `LMX_blog/2026-09-27.md`, Q48).** The answer says yes to the four points of Answer48 §5 and corrects Answer48's generalizations. Applied: (a) §20 "Explicit callable descriptions" -- the declared header is the type of the receiving place; the composition result is admitted by ordinary admission with the ordinary preparation of inputs, including defaults; no automatic `merge(add; {y: 5}; header)`, no implicit replacement of `args` by a shorter header, no cutting of the candidate's fields or of its machine body's ABI; `y` stays a formal with the default 5: `add5(1)` = 6, `add5(1; y: 25)` = 26, `add5(1; y: 0)` = 1, a caller's unsupplied same-named `y` does not reach `add5`, one call's argument is not a new default (R48-05..08, R48-10; the fixture is added in both languages, so the files now hold 58 fenced blocks each); "the signature of `add` disappears" is replaced by "the set of arguments that must be supplied explicitly shrinks; the formals and the body's other requirements do not disappear". (b) §20 "Native implementation reuse" -- the unconditional "the result's `native` word is empty" is replaced by the four cases of the answer's table (an unchanged body keeps its implementation; a data-only change keeps the model's code and `native`; a whole other operand body brings its own `native`; a changed body without a matching implementation has an empty `native` and is interpreted under the ordinary L3 contract); renumbering is not a mandatory effect; the confirmation of 2026-09-25 "the result is interpreted" is recorded as scoped to the changed-body case -- a clarification of the earlier confirmation's scope, not a reversal (the answer, §1). (c) §20 "Returned nested methods" -- the unchanged code of `addN` plus the activation's used values composed into its data; the declared `fn` result type checks the callable ordinarily, no third implicit operand; the free name `n` stays free with dynamic priority (R48-09) and is a default only when `n` is a formal of the selected method. (d) §20 "Composition of structural parts" -- the datum `y: 5` of `merge(add; y: 5)` is the formal's default; whole-body selection at the relevant level, machine bodies never glued. (e) §11 -- the answer's §4 wording added as a paragraph (defaults are a general call facility; a contract-violating value is not an absent one; zero is a supplied value; the default's source and the current activation's argument are distinct; no default arises from a previous call); the "no binding through `merge`" sentence now separates the free-name fallback from a formal's default. (f) §12 -- a formal is not a free name of its body; the source priority does not extend to an omitted formal. (g) §7/§8 -- three notions named: the accepted interface, the mandatory supply, the formed inputs of the selected implementation; an optional formal is removed from none of them; substitution into a shorter declared type is by admission with preparation, not by declaring full signatures equal; recipes 8 and 9 aligned (`DynRequired` excludes a defaulted formal).

Readings to confirm (derived from the answer and the existing rules; recorded here, not asked as questions): (1) the header example is spelled `merge(add; y: 5)` -- the author's own specialization spelling of 2026-09-25 («merge(add; y: 5) делал функцию смержив только body add и "y: 5". А вот merge(y: 5; add) делал обертку вокруг add», `LMX_blog/2026-09-25.md`) and the answer's `merge(Dadd, {y: 5})`; the earlier header spelling `merge(y: 5; add)` is, by that rule, the wrapper (a Structure with `add` nested, the book's `merge((n: 5); addN)` case), and with the automatic second merge removed the book no longer states how a wrapper would enter a declared callable type -- it is silent on it. (2) §7's exact match is read over the mandatory supply, passing modes, result and exits; the full accepted interface is not compared for equality (otherwise `add5` with the formals `x, y` could not enter `fn (int: x) int`, which the answer says it does by admission with defaults); "complete signatures may not [differ]" is replaced accordingly. (3) Where the default lives is not stated (the answer: meaning, not layout); under the existing rules an argument is a frame value and becomes a field only by a bare assignment in the body (§12), so for a body that does not assign its defaulted formal the default cannot change through calls (R48-10), while for a body that does assign it the own field is the default's source and that assignment is the "ordinary explicit operation on the state the default is taken from" (the answer, §4). Not changed: `docs/L2_spec_*.md` §13 still describes the transitional mechanism (one more merge with the method as the model, `addr = 0`, the position map) -- a kernel/translator plan item, handed to the lead with R48-01..12.

**N02 -- resolved by an existing explicit author decision (2026-09-25, `LMX_blog/2026-09-25.md`).** The author, verbatim: «вообще я понял тебя -- давай уберем все эти вхождения и заодно код быстрей станет. int: i 5 это целая операция которыуюты наверное слева где-то хранишь в интерператоре? Не надо клади уж ге она лежит -- в то поле. Все эти dirty -load видимо надо убрать»; «поигрались и хватит --вырезай весь код load-dirty и храни там в ячейках нормальный граф для интерператора»; «да прямо там. Зачем тебе рабочие копии?Заводи стек и в нем работай»; and the same day: «Присваивание слот не открывает для записи из выполняющего но оно остается в дереве структуры как слот как и все остальные фичи типа else», «для записи и для чтения через data\x -- одинаковое поведение», «то есть никаких дополнительных структур в графе кроме временных необходимых интерпретатору -- нет!». The authoritative model is §12's: values live in the instance's fields, a write goes directly into the field, there are no working copies, `dirty` marks, checkpoints or field publication; the activation's temporaries (arguments, locals, result) live in the frame. Applied to every dependent passage: §4 (`#fields`, the `node` paragraph: the assignment writes directly into the body's own field), §8 case 5 (the recipe writes directly, no cache/dirty/checkpoint), §9 (`#construction`: "on failure the target does not change"), §10 (`#qualification`: "writes into instance fields made before the call" instead of "pre-call publication of working fields"), §14 (`#exits`: the exit order is result, cleanups, transfer; no field publication; the caller reloads nothing; calls within cleanup are ordinary calls), §16 (`#suspension`: "already written fields or published Messages"; "the instance's fields keep their current values"). Retained: implementation caching that preserves observable behaviour (§6 "may cache resolved bindings", §9 "cached physical addresses … do not remove the semantic admission call"), Message publication, `finally` order and obligations, no copy-back to the caller's argument, the local-rebinding/explicit-referent distinction. Observations A-C of the task follow from the one model: A reads the value just written; B the outer activation's bare name reads the field the nested call wrote (§12 already states it); C the next reader sees the cleanup's write at once.

**N03 -- resolved by an existing explicit author decision (2026-09-24, Q22.2, `LMX_blog/2026-09-24.md`).** The author, verbatim, on «неуточнённое имя -- снова первое ([0])?»: «--мы вроде выяснили что последнее [lastIndex] следует более общему правилу»; also 2026-09-24: «надо поменять struct\overrided вызов не на struct\[0]overrided а на struct\[lastIndex]overrided». So §4's rule governs: an unqualified name selects the last occurrence, `[N]` numbers occurrences lexically. Applied: §12 (`#dynamic`) lexical lookup now selects, at the relevant step, the last same-named occurrence, as every unqualified name does, `[N]name` picks another (was "the direct first"); §9 (`#construction`) the two-`count` example now reads `result\count` = 4, `result\[0]count` = 3, `result\[1]count` = 4 (the example is kept, the value corrected); §5 (`#descriptions`) the converter-key sentence now follows the general rules of names (last by an unqualified name, `[N]` for another, composition writes a later same-name description into the model's slot) and leaves the choice among several table rows with one key to the table operation's own policy (§21's existing statement), instead of "a later same-name key does not displace the first" -- applied by the general rule, no separate ruling exists or is needed; §7 (`#admission`) diagnostics show "which same-name branch composition selects (the last by the general rule, or the explicitly selected occurrence)". Unchanged and distinct: dynamic-before-lexical priority, the lexical traversal boundary, explicit `node\` access, "only a declaration creates an occurrence", `merge` writing a matched field into the model's slot without appending an occurrence, physical slot indices versus occurrence numbers.

**N04 -- editorial, done.** The §20 paragraph is split into six subsections with matching headings in both languages, no sentence removed or reworded: model slots, field matching and ordering; composition of structural parts (with the `merge(add; y: 5)` / `merge((n: 5); addN)` examples); explicit callable descriptions (the N01-dependent text, unchanged); native implementation reuse and copied callable occurrences (the Q44 sentence and the general-rule copy); returned nested methods; dynamic sources and the lexical fallback (the previous task's paragraph and its `x = 10 / 25 / 40` fixture). The `#composition` anchor and section number are unchanged.

### Acceptance checks

NEXT-01 N02 and N03 cite the author's verbatim decisions above; N01 cites the author's answer of 2026-09-28 (`response48.md`). NEXT-02 no exception, backend split or profile was introduced. NEXT-03 the `[x, y]` / `[x]` fixture has one explained result: composition keeps `y` as a formal with a default, the shorter header is the place's type. NEXT-04 the operation responsible for whole replacement is named (an operand's nameless body statements replace the model's); nothing replaces the argument description. NEXT-05 "the signature disappears" is gone; dynamic inputs, failures and the body's other requirements stay. NEXT-06/07 unchanged from the previous task and re-read: copying binds no arguments; bare `x` reads 25 then 40, `node\x` reads 10, the fallback supplies 10 only without a dynamic source. NEXT-08/09 one state model in §§4, 8, 9, 10, 12, 14, 16; calls, return, throw, yield, retry and cleanup are described by it. NEXT-10 Message publication, end-of-turn, cleanup obligations and no-copy-back rules are intact. NEXT-11 the two-`count` example agrees with the last-occurrence rule; explicit selectors consistent. NEXT-12 converter keys and diagnostics follow the general rule; no distinct operation was invented. NEXT-13 declaration, assignment, merge-slot replacement, occurrence numbering and physical indices remain distinct. NEXT-14/15/16 the previous correction is intact (occurrences copied, native implementation reused, the combined qualification the one exception, the map and cycles untouched). NEXT-17 §20 readable in both languages, no rule lost, no new receiver. NEXT-18 both languages edited in the same places; the build's structural equality check passes. D01-D12 re-read against the regenerated text: unchanged conclusions. Not inspected: the grammar and the L1/L2 documents beyond `docs/L2_spec_*.md#copy-merge` ("METHOD pointers are retained" -- consistent with native implementation reuse); no runtime test was run for this task.
