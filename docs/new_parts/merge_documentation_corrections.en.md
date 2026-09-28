# Fable task: correct `merge` documentation without removing the eternal-branch exception

**Scope:** documentation changes in the English and Russian LMX semantics specifications. This task does not request a runtime refactor, a new copying algorithm, or a new binding mechanism.

**Controlling decision:** `merge` copies the locally used lexical tree and does not perform argument binding or change dynamic-input precedence. Native implementation references remain reusable. The author explicitly confirms one exception for retaining an original **graph branch**: the full qualification `independent: const: immutable`.

## 1. Sources and priority

Use the latest corresponding files in the working repository. The reviewed conversation snapshots are:

- **S1:** `LMX_semantics.en(3).md` — the English semantics snapshot.
- **S2:** `LMX_semantics.ru(2).md` — the corresponding Russian snapshot.

The repository targets are the corresponding canonical English and Russian semantics documents, normally `LMX_semantics.en.md` and `LMX_semantics.ru.md`. Attachment suffixes identify snapshots; they do not request new language variants or filenames.

Apply the following priority:

1. The author's latest clarification, including the explicitly retained eternal-branch exception.
2. The preceding clarification that copying the lexical tree does not bind arguments or displace dynamic inputs, and that sharing a native implementation is different from sharing a callable Structure.
3. Unaffected rules in the current specifications.

The locators below use section numbers, exact phrases, and source-file line numbers from the reviewed snapshots. Line numbers are navigation aids, not instructions to replace whatever happens to occupy the same line in a newer revision. Read the matching paragraph before editing it.

The earlier review incorrectly classified the eternal-branch passages as violations of the author's intended rule. **That part of the review is withdrawn. Preserve those passages' substantive exception.**

## 2. State the corrected rule precisely

There are three distinct cases, not a blanket choice between copying everything and retaining all references.

| Material encountered by `merge` | Required treatment |
| --- | --- |
| Ordinary locally used lexical Structures, including ordinary callable occurrences and their required lexical state | Construct their copies under the general composition rule and rewrite their structural links. Do not retain the original occurrence merely because it represents a method. |
| A reusable native implementation | Keep the implementation reference under the existing native/ABI contract. The implementation receives the graph with which it executes; its address is not the identity of that graph or its lexical environment. |
| A branch admitted under the complete `independent: const: immutable` qualification | Retain its original physical reference as the already specified terminal. Do not copy the branch or reparent it. Preserve its existing owner and lifetime contract. |

The last row is the author-approved **graph-sharing exception**. It is not an accidental remnant to delete.

### 2.1 Why the exception remains

The author's rationale is direct: an independent branch has no external lexical parent, and its qualified body cannot change. Copying that entire branch gains nothing; the existing physical reference is sufficient.

Use the specification's representation consistently. Its null external lexical parent is written as root `parent = 0`. The author's shorthand `node = null` describes this external lexical boundary; do not turn it into a new rule that clears every internal `parent` or every nested method's `node`. Section 10 already preserves the branch's internal lexical links and permits caller-supplied dynamic inputs. [S1/S2, §10, `#qualification`, especially lines 597–601; §23, `#eternal`, line 1133.]

Apply the **combined qualification**, not `independent` alone, a null parent alone, or `immutable` alone. The existing qualification and lifetime contracts determine eligibility. Do not introduce a new flag, receiver, root-only privilege, or global registry to recognize the exception.

An implementation address and an eternal graph branch are different kinds of retained material. Keep the distinction explicit even where both are called terminals.

## 3. Preserve the native-implementation correction already present

In §20, source line 892, both reviewed snapshots already contain the Q44 correction:

> A field of another Structure that references a method (`A: fn: M`) keeps, under `merge`, a shared reference to the method's native implementation: the native implementation receives the graph node, so the reference to it can be kept; this has nothing to do with Structures, and the level a method is declared at (the file, an operand's body) differs in nothing from any other level.

The following sentence states that the method's occurrence is copied by the general rule.

**Retain this correction.** Make its reference to the general rule include the qualified-branch exception rather than contradicting it.

Do not restore the older wording under which a file-level method occurrence itself was retained and its original `node` remained attached. File scope is a lexical location, not an exemption from copying.

Where the document says “shared method references” or “method records,” make clear which representation is meant. Sharing the reusable implementation must not imply sharing an ordinary mutable callable occurrence or its original lexical context. Do not use that wording to create a third, unqualified graph-sharing exception.

Do not change the existing distinction between a newly composed executable body and a nested native implementation carried over unchanged. This assignment does not turn every composition into native code, erase every retained `native` word, or permit a modified body to reuse an unrelated implementation.

## 4. Correct the earlier audit of eternal branches

These passages are **KEEP / CLARIFY**, not DELETE. They occur in both S1 and S2.

| Location in the reviewed snapshots | Existing statement | Editing instruction |
| --- | --- | --- |
| §20, line 890 | An `independent: const: immutable` branch is not copied; the result receives the original physical value reference. | Keep the requirement. State explicitly that this is the qualified graph-branch exception to the general copying rule. |
| §23, line 1143 | A qualifying branch in a DLL-like module remains referenced at its original address, with its original module as owner. | Keep. Do not invent a new unload policy in this task. |
| §23, line 1145 | `merge` and Message creation retain admitted eternal branches and method records as terminals. | Keep the eternal-branch rule. Clarify implementation-record terminology as described in §3 of this task. |
| §23, line 1147 | A and B can share eternal E while their mutable x cells are distinct. | Keep the example. It demonstrates the intended exception, not an aliasing bug. |
| §25, line 1180 | Creating a new executing Message copies ordinary settings and retains admitted eternal references. | Keep, with a cross-reference to the same exception. Do not introduce a second Message-specific copying policy. |

Preserve the existing explicit retention, ownership, range-classification, and protection rules around these paragraphs. Keeping an address is not permission to outlive its existing lifetime contract or disclose protected content. No additional mechanisms are requested here.

## 5. Remove the claim that `merge` binds arguments

This remains the actual semantic correction required by the review.

### 5.1 Section 11: “or by binding through merge”

At source line 611 the English text says:

> “…an argument becomes a field only by the rule of §12 or by binding through merge.”

The Russian text contains the corresponding phrase:

> «…или связыванием через merge».

Remove the purported second argument-binding mechanism. Keep the ordinary activation and assignment rules governed by §12; do not rewrite those rules as part of this task.

Describe copied lexical state separately: a value included in the copied lexical tree remains lexical data. Its presence does not cause `merge` to bind a formal, remove a dynamic requirement, or make a bare name a permanent reference to that field.

### 5.2 Section 20: formals “bound to same-name fields”

Within the long paragraph at source line 892, the English text says:

> “…the method's formals absent from the declared signature are bound to same-name fields…”

The Russian text says:

> «…формалы метода, которых нет в объявленной сигнатуре, связываются одноимёнными полями…».

Rewrite the surrounding explanation, not just the isolated word “bound.” The paragraph currently attributes a special callable-conversion/binding procedure to `merge`. The author rejects that explanation.

Document ordinary structural composition and copied lexical data. **Do not describe copying as partial application, closure capture, or freezing a call-time input.** Do not claim that copying required context makes a former dynamic input disappear from the interface.

This correction is not a ban on ordinary Structures containing `args`, `return`, and `body`, nor on a program explicitly supplying a description or composing those parts. Preserve the existing general composition and ordinary admission rules. If an example explicitly constructs or consumes a callable description, explain that expressed operation on its own terms; do not attribute extra argument-binding semantics to copying its lexical tree.

Keep the distinction between “the program supplied different description data” and “`merge` silently bound an argument.” The latter must not remain a normative explanation.

### 5.3 Section 20: unconditional lexical resolution in the example

The same paragraph says:

> “`n` in the body of `addN` resolves to the enclosing Structure's field.”

Qualify this as the **lexical fallback** when the ordinary dynamic sources do not provide the input. It is not an unconditional effect of `merge`.

A numerical example such as `add5: 1` producing `6` must state the relevant supplied/fallback values. It must not imply that a copied lexical value overrides a different value subsequently supplied through the normal dynamic-input mechanism.

Do not invent a new callable signature, source form, or closure object to repair the prose. Update the explanation and its assumptions using the existing language rules.

## 6. State that dynamic-input precedence is unchanged

Section 12 already describes the required priority for a free input name:

```text
current caller's nearest applicable local binding
    then inherited dynamic input
    then permitted lexical fallback
```

An explicit `node\x` follows the selected lexical graph instead. [S1/S2, §12, `#dynamic`, lines 641–645.]

Add a direct statement near the composition rules:

> Copying the locally used lexical tree does not change dynamic-input resolution. On a later call, a bare input name continues to use the ordinary caller-provided dynamic sources before lexical fallback. The copied lexical context supplies fallback data; it is not a capture that overrides the caller. An explicit `node\` path selects the corresponding lexical context directly. `merge` introduces no argument-binding operation.

The example below is a semantic fixture, not a new source syntax:

```text
The copied lexical context contains x = 10.
The called body reads x as an ordinary free input.
The current caller supplies x = 25.

read x       -> 25
read node\x  -> 10
```

A second call supplying `x = 40` reads `40` through the same bare input. If neither ordinary dynamic source supplies `x`, the permitted copied lexical fallback supplies `10`. If no admissible source supplies a required input, retain ordinary missing-input diagnostics.

Keep ordinary local declarations, explicit formals, assignment, and explicit reference access under their existing contracts. This example is about a free input and its lexical fallback, not a new rule that every occurrence of every name must be a dynamic input.

The same distinction applies to methods inside independent branches: cutting the **external lexical parent** does not prohibit dynamic inputs from the current caller. Reusing an eternal branch therefore does not turn its permissible caller-supplied inputs into constants.

## 7. Clarify topology preservation without inventing original-object sharing

Section 20, source line 886, currently states:

> “One source-to-copy map spans all operands: shared targets remain shared, cycles are preserved, and references and `parent` links are explicitly rewritten.”

Keep two questions separate:

1. Does a result retain an original physical target?
2. Are relationships between copied targets reconstructed inside the result?

The source-to-copy statement concerns the second question. For ordinary copied material, the links are rewritten to the corresponding copies; it is not permission to retain their source objects. The original-reference cases are the native implementation and the qualified eternal branch described above.

Do not delete the existing source-to-copy map or cycle handling merely because the paragraph uses the words “shared” and “preserved.” The latest clarification confirms the eternal-branch exception; it does not instruct a different cycle algorithm or mandate a fresh copy for every incoming edge.

At the same time, do not expand “locally used lexical tree” into an unrestricted traversal of unrelated application state. Preserve the existing used-context boundary. This editorial task does not decide a new closure-selection, alias-analysis, or graph-deduplication algorithm.

Recommended clarification after the existing map description:

> For ordinary copied targets, preservation of relationships means that the result's links refer to the corresponding copied objects, not to the original graph. Retention of original targets is limited to reusable native implementation references and the admitted `independent: const: immutable` branch exception. Preserving relationships inside a copy does not bind arguments or change dynamic-input precedence.

Do not describe a mutable copied context as an automatically updated mirror of its source. Any intentional later communication or update remains an explicitly expressed program operation.

## 8. Suggested compact replacement passage for §20

Integrate the following substance into the existing section; it is not an instruction to append a contradictory second definition at its end. Retain the surrounding field-composition, ordering, failure, protection, and lifetime rules that are unaffected.

> `merge` copies and composes the locally used lexical tree under the ordinary structural rules. Ordinary Structures and callable occurrences are copied, with their necessary structural links rewritten for the result. The native implementation is separate from the occurrence and its lexical state: an unchanged reusable implementation reference may be retained because execution supplies the graph it consumes. A method's declaration level does not by itself change these rules.
>
> A branch admitted under the combined qualification `independent: const: immutable` is the explicit graph-sharing exception. Its root has no external lexical parent and its qualified contents cannot change; `merge` retains the original physical reference instead of copying the branch. Its existing owner, qualification, and lifetime rules continue to apply. This exception does not extend to ordinary mutable branches or to a method occurrence merely because it has a native implementation.
>
> Copying lexical state does not bind arguments, capture a caller frame, or alter dynamic-input precedence. Bare input names continue to obtain their values from the ordinary dynamic sources, using the lexical context only as fallback. An explicit `node\` path selects that lexical context directly. The same rule applies after composition and inside independent branches.
>
> Relationships reconstructed among copied objects are not references back to the original ordinary graph. The source-to-copy bookkeeping and the qualified terminal exception serve different purposes and must not be conflated.

Use the same substance in Russian. Retain established vocabulary: `Structure`, callable occurrence, native implementation, lexical context, dynamic input, `parent`, and `node`. Do not replace them with a new object or capability taxonomy.

## 9. Documentation consistency checks

These are acceptance scenarios for the **documented contract**, not a claim that runtime tests have been executed. This request is for documentation editing; no implementation changes are authorized merely by this table.

| ID | Scenario | The edited documentation must say or imply |
| --- | --- | --- |
| D01 | Copy an ordinary callable occurrence with used mutable lexical state | The occurrence and copied lexical state are not the original ordinary objects. Its native implementation can remain shared. |
| D02 | Encounter a valid `independent: const: immutable` branch | Retain the original branch reference. Do not copy it or change its owner. |
| D03 | A branch has only `independent`, only `immutable`, or merely a null parent | Do not claim eligibility for the complete qualified-branch exception from this fact alone. |
| D04 | The same method is declared at file scope or inside another ordinary body | Declaration level does not itself permit retaining its original callable occurrence. |
| D05 | Copied lexical x is 10; caller dynamically supplies x = 25 | A bare free x reads 25. Explicit `node\x` reads the copied lexical 10. |
| D06 | The same copied expression is called with another dynamic x | It observes that call's supplied value, not a value frozen by `merge`. |
| D07 | No dynamic x is supplied, but a permitted lexical fallback exists | Use the fallback under ordinary rules. Its presence does not mean `merge` performed binding. |
| D08 | A method inside an independent branch needs a dynamic input | Independence does not by itself reject that input or make the method pure. |
| D09 | Several rewritten edges or a cycle concern ordinary copied targets | Explain relationships inside the result without implying retained source objects. Do not silently change the current map policy. |
| D10 | An example uses explicitly supplied `args` or `return` descriptions | Explain ordinary composition/consumption of those descriptions, not an implicit capture performed by copying. |
| D11 | Ordinary argument passing, returning a reference, or storage handoff | Preserve the distinct existing contracts; the `merge` correction does not make every reference transfer a copy. |
| D12 | English and Russian versions are read independently | They describe the same exception, the same native/occurrence distinction, and unchanged dynamic-input precedence. |

## 10. Editing workflow and deliverables

Read the matching sections of both current documents, then make a focused bilingual documentation patch.

Keep the native-implementation correction and the eternal-branch exception. Remove or rewrite the two argument-binding claims and the unconditional lexical-resolution explanation. Add an explicit composition-to-dynamic-input cross-reference. Clarify the source-to-copy paragraph so that it cannot be mistaken for a general retention-of-originals rule.

Search the relevant documentation for the following phrases and their equivalents after editing:

```text
binding through merge
bound to same-name fields
shared reference to the same occurrence
the method's node does not change
shared method references
original physical value reference
shared targets remain shared
```

The last three phrases are not a blind deletion list. Their acceptability depends on whether they now distinguish native implementations, qualified eternal branches, and links among copies correctly. Likewise, do not globally remove the word “binding”: normal argument binding, type bindings, and reference rebinding still have their established meanings.

Preserve section numbering, anchors, and unaffected examples wherever possible. Adjust examples only where their explanation depends on the rejected binding/capture rule. Do not fold unrelated inconsistencies elsewhere in the snapshots into this patch, redesign `node`, change queue or lifecycle contracts, or add UI/IDE/AI-specific semantics.

Deliver:

- The aligned English and Russian documentation edits and their diff.
- A brief edit map identifying which audited locations were changed and which eternal-branch passages were deliberately retained.
- Confirmation that the D01–D12 scenarios are consistent with the resulting text, distinguishing documentation review from any separately performed implementation testing.

**Acceptance criterion:** ordinary lexical copying, native implementation reuse, and the one qualified graph-sharing exception are stated distinctly. `merge` does not become a binder, and copied lexical data never displaces the existing dynamic-input priority merely because it was copied.
