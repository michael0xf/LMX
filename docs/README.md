# Lingvamyxa — English documentation for Fable review

> **Repository note.** This directory holds the edition of 2026-11-21 in the layout of the author's packet
> (it lay in `new_parts/newdocs/` and was removed there as a duplicate on the author's order of 2026-11-21).
> The texts are verbatim; only link targets required by the placement
> were adapted: [CORE.md](../CORE.md) and the [developer instruction](../L2_L3_CODING_INSTRUCTION.md) stand in
> the repository root. In this repository the semantics and the grammar are generated from
> `provenance/semantics-book.md` and `provenance/grammar.json` together with their Russian halves, which are
> translations of the English text (completed on 2026-11-21). The other Russian documents
> (`L2_spec_ru.md`, `LMX_semantics_guide.ru.md`, `kernel-implementation.ru.md`, `implementation-notes.ru.md`,
> `source-comparison.ru.md`) are translations of the English edition as well (completed on 2026-11-21,
> [plan](../next_core_tasks_v3.md#docs-20261121)). The L1 specification (`L1_spec_en.md`, `L1_spec_ru.md`) was not
> part of the packet and is kept as it was.

**Review edition: 2026-11-21.**

This is a self-contained documentation packet. Read and review the files as they
are arranged in this archive; no repository documentation build, generated mirror,
or absent journal is needed to follow its internal references.

The primary documents hold the whole norm: every change requirement and every
accepted supplement of the author is carried into them. Among the latest rules:
**import, copy, and merge always use ordinary CODE arguments**,
wherever their receiver records occur. An anonymous Structure is not itself a
call, but its contents can contain calls and initializers with their ordinary
contracts.

The clean graph is the complete literal source representation, including terminal
primitive leaves as `{type value}` at addresses referenced by Structure cells.
All receivers, including `for`, `if`, `merge`, `copy`, and `import`, remain as written.
Computation and semantic transformation occur in namespace; results do not implicitly
replace those source records. Ordinary explicit graph assignment can replace these
fragments. Executable changes use the existing explicit compilation/endturn restart
mechanism when recompilation is needed.

The rules of [zero-payload `uninit` and graph assignment](LMX_semantics.en.md#uninit-zero-payload)
have priority over contrary earlier physical descriptions: `uninit:T` has only its
code and zero payload; frame writes leave source unchanged; graph writes replace
fragments. P01 is resolved, with no reserved T cell or raw payload-address promise.

The program has only the complete graph and a binary of compiled native methods.
R0 is an ordinary C method with a local pointer to its graph; interpreter execution
also uses this binary R0. `parent` and `length` follow logically from source shape,
and the other contents are represented by the Lmx pointer array and referenced
records. Ordinary runtime bookkeeping remains; a working/expanded/callable graph,
static DATA replica, or namespace-shaped program copy does not.

## Reading order

| Document | Purpose |
| --- | --- |
| [CORE.md](../CORE.md) | Architecture map and the relationships among the contracts |
| [LMX_grammar.en.md](LMX_grammar.en.md) | Structural parsing, levels, Frames, grouping, and source boundaries |
| [LMX_semantics.en.md](LMX_semantics.en.md) | Normative language semantics |
| [LMX_semantics_guide.en.md](LMX_semantics_guide.en.md) | Worked examples and execution explanations |
| [L2_spec_en.md](L2_spec_en.md) | Physical memory, machine-side operations, runtime interfaces and ABI |
| [kernel-implementation.en.md](kernel-implementation.en.md) | Shared implementation algorithms and physical/runtime contracts |
| [L2_L3_CODING_INSTRUCTION.md](../L2_L3_CODING_INSTRUCTION.md) | Developer integration and focused acceptance instructions |
| [implementation-notes.en.md](implementation-notes.en.md) | Implementation distinctions, derived review cases, the resolved P01 author decision, and historical provenance |
| [source-comparison.en.md](source-comparison.en.md) | Comparison of source forms and their roles |

[REVIEW_NOTES.md](REVIEW_NOTES.md) records the applied changes, verification scope,
and derivation of inherited review cases from the current rules. P01 records the
author's completed zero-payload and graph-assignment decision. A genuine
contradiction between applicable current requirements must be presented to the
author with both clauses; superseded wording and routine derivations do not create
an additional approval gate.

<a id="subjects"></a>
## Where each subject is specified

The author's change requirements and accepted supplements are carried into the
primary documents in full; the primary documents alone are the norm. The table
names the place of each subject.

| Subject | Where it is specified |
| --- | --- |
| Complete program graph, binary of compiled methods, zero-payload `uninit`, graph assignment | [program representation](LMX_semantics.en.md#program-representation), [`uninit`](LMX_semantics.en.md#uninit-zero-payload), [graph assignment](LMX_semantics.en.md#graph-fragment-assignment), [required observations](LMX_semantics.en.md#regression-obligations) |
| Callable Structures, actual parent as DATA, named `fn` signatures, selection, binding places, two-way `private` | [binding places](LMX_semantics.en.md#binding-places), [decisions R01–R19](LMX_semantics.en.md#binding-decisions), observations [B01–B27](LMX_semantics.en.md#binding-observations) and [C01–C36](LMX_semantics.en.md#callable-observations) |
| Declaration arguments and `import` | [declaration arguments](LMX_semantics.en.md#declaration-arguments), [`import`](LMX_semantics.en.md#import-receiver), [required observations](LMX_semantics.en.md#declaration-observations) |
| Blank-line block termination | [blank physical line and its observations](LMX_grammar.en.md#levels), [guide](LMX_semantics_guide.en.md#blank-line-blocks) |
| Operand methods, prepared and raw modes, `sys` helpers, priorities | [operands](LMX_semantics.en.md#operand-receiver), [observations O01–F10](LMX_semantics.en.md#operand-observations) |
| `import`, `copy` and `merge` field streams | [composition](LMX_semantics.en.md#composition), [observations G01–N01](LMX_semantics.en.md#field-stream-observations) |
| Writable places, assignment and structural declaration | [writing a known place](LMX_semantics.en.md#assign-known) |
| Local declarations and initialization | [declaration levels](LMX_semantics.en.md#shadowing-levels) |
| Call frame without load-dirty publication | [call frame](LMX_semantics.en.md#call-frame-20261115) |
| Application interface of inspection, insertion, copying and stepping | [chapter 36](LMX_semantics.en.md#edit-api) |
| Thread/Message transport: `post`, reply waits, `send` and `receive` | [chapter 28](LMX_semantics.en.md#thread-message-api), [observations T01–T26](LMX_semantics.en.md#thread-message-observations) |

The field-stream rules supersede the earlier DATA-argument variants of `import`,
`copy` and `merge`. This does not change the DATA-argument contracts of `fn` or
modifiers. Earlier wording quoted to explain a migration does not establish an
alternative current syntax.

`L2_L3_CODING_INSTRUCTION.md` was supplied in Russian and is English in this
packet. The accidentally supplied `LMX_grammar.ru.md` is excluded at the author's
request. A complete Russian edition is a separate later pass.

## Scope and precedence

The operative documents reflect the latest author requirements. Accepted
supplements retain their contracts where those requirements do not replace them.
Historical implementation receipts are labeled as historical and do not determine
current language behavior.

The architecture and examples are intended for acceptance of the model. This
document rewrite does not assert that a compiler, interpreter, bootstrap, or
runtime conformance suite was executed. Existing code must be compared against
the accepted model when Fable performs implementation acceptance.

Internal Markdown links refer to files and anchors in this archive. External
language-standard references, where retained in a source requirement, are
background sources rather than repository build dependencies.

## Archive contents

There are nine primary English documents, this index, and the review notes. Unrelated source
trees, generated binaries, test logs, and scratch editing scripts are not part
of the packet.
