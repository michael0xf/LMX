# Lingvamyxa — English documentation for Fable review

> **Repository note.** This directory holds the edition of 2026-11-21 in the layout of the author's packet
> (`new_parts/newdocs/`, kept as delivered). The texts are verbatim; only link targets required by the placement
> were adapted: [CORE.md](../CORE.md) and the [developer instruction](../L2_L3_CODING_INSTRUCTION.md) stand in
> the repository root. In this repository the semantics and the grammar are generated from
> `provenance/semantics-book.md` and `provenance/grammar.json` together with their Russian halves; the Russian
> halves of changed paragraphs follow the English text until they are translated. The other Russian documents
> (`L2_spec_ru.md`, `LMX_semantics_guide.ru.md`, `kernel-implementation.ru.md`, `implementation-notes.ru.md`,
> `source-comparison.ru.md`) are bridges to the English edition until the Russian pass of the
> [plan](../next_core_tasks_v3.md#docs-20261121). The L1 specification (`L1_spec_en.md`, `L1_spec_ru.md`) was not
> part of the packet and is kept as it was.

**Review edition: 2026-11-21.**

This is a self-contained documentation packet. Read and review the files as they
are arranged in this archive; no repository documentation build, generated mirror,
or absent journal is needed to follow its internal references.

The packet integrates the supplied change requirements into the primary English
documents and the accepted supplements. The latest author clarification is
applied throughout: **import, copy, and merge always use ordinary CODE arguments**,
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

The latest [author clarification](TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md)
has priority over contrary earlier physical descriptions: `uninit:T` has only its
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

<a id="requirements"></a>
## Requirements

`TZ/` contains the supplied change requirements. Their source language is retained;
the operative English rules and examples are integrated into the primary documents.
Links to the documents have been adapted to this archive.

| Requirement | Integrated subject |
| --- | --- |
| [Latest author clarification: complete program, uninit and graph assignment](TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md) | Highest-priority clarification: complete graph plus methods-only binary, local R0 graph pointer and binary R0 for interpretation, zero-payload uninit, replaceable source fragments, existing compile/endturn update boundary |
| [Binding and callables](TZ/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md) | Ordinary callable Structures, actual parent as DATA, named fn signatures, selection, binding places, two-way private |
| [Declaration arguments and import](TZ/LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md) | Preserved declaration actuals, receiving-root namespace behavior, positional/named mapping, root-const import filter |
| [Blank-line block termination](TZ/LMX_Fable_TZ_Blank_Line_Block_Terminator_2026-11-20.md) | Complete block termination within the common parser; verification of boundaries and examples |
| [Operands, arguments and priorities](TZ/to_fable_operands_arguments_priorities.md) | Ordinary operand methods, mandatory properties, prepared/raw modes, sys helpers, effect order and ordinary results |
| [Import, copy and merge field streams — revision 2](TZ/LMX_Fable_TZ_Import_Copy_Merge_Field_Streams_2026-11-21.md) | Always-CODE arguments, source-preserving namespace processing, stream output, explicit grouping and source arity |

The revision-2 stream requirement includes the author's corrections made during
this review. It supersedes the earlier DATA-argument variants of these three
receivers. This does not change the DATA-argument contracts of fn or modifiers.

A requirement's revision and specific subject control its meaning; its original
filename date alone is not an ordering rule. Earlier wording quoted to explain a
migration does not establish an alternative current syntax. References inside TZ
to older exported filenames identify the original baseline; this archive supplies
the corresponding revised primary files listed above.

<a id="accepted-supplements"></a>
## Accepted supplements

`Old_TZ/` is part of the current documentation. Its name records that the
requirements were already applied; it does not make the documents optional,
unapplied proposals, or an archive of competing norms. All eight supplied
supplements have been reviewed and updated.

| Supplement | Subject |
| --- | --- |
| [assignment_is_not_declaration.en.md](Old_TZ/assignment_is_not_declaration.en.md) | Writable places, assignment and structural declaration |
| [local_declarations_and_explicit_initialization.to_fable.en.md](Old_TZ/local_declarations_and_explicit_initialization.to_fable.en.md) | Local declaration behavior and initialization |
| [merge_documentation_corrections.en.md](Old_TZ/merge_documentation_corrections.en.md) | Graph-copy relationships and composition |
| [merge_documentation_corrections_next.en.md](Old_TZ/merge_documentation_corrections_next.en.md) | Further composition/callable clarification |
| [dirty.md](Old_TZ/dirty.md) | Current activation and explicit-editing model; removal of load-dirty publication |
| [mutating_debug_API.en.md](Old_TZ/mutating_debug_API.en.md) | Explicit inspection, compilation and editing boundary |
| [threadMessageAPI.en.md](Old_TZ/threadMessageAPI.en.md) | Unified Thread/Message/mail API |
| [threadMessageAPI_migration.en.md](Old_TZ/threadMessageAPI_migration.en.md) | Integration and acceptance of the shared transport |

`dirty.md` and `L2_L3_CODING_INSTRUCTION.md` were supplied in Russian and are
English in this packet. The accidentally supplied `LMX_grammar.ru.md` is excluded
at the author's request. A complete Russian edition is a separate later pass.

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

There are nine primary English documents, eight maintained English supplements,
six source-requirement files (the original five plus the latest author clarification),
this index, and the review notes. Unrelated source
trees, generated binaries, test logs, and scratch editing scripts are not part
of the packet.
