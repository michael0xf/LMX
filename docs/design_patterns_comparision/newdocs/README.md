# Lingvamyxa — English documentation for Fable review

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

All source receivers remain as written in the graph. Computation and semantic
transformation occur in namespace; terminal primitive declarations are represented
as `{type value}`. The source graph is not replaced by expanded import/merge/copy
results.

## Reading order

| Document | Purpose |
| --- | --- |
| [CORE.md](CORE.md) | Architecture map and the relationships among the contracts |
| [LMX_grammar.en.md](LMX_grammar.en.md) | Structural parsing, levels, Frames, grouping, and source boundaries |
| [LMX_semantics.en.md](LMX_semantics.en.md) | Normative language semantics |
| [LMX_semantics_guide.en.md](LMX_semantics_guide.en.md) | Worked examples and execution explanations |
| [L2_spec_en.md](L2_spec_en.md) | Physical memory, machine-side operations, runtime interfaces and ABI |
| [kernel-implementation.en.md](kernel-implementation.en.md) | Shared implementation algorithms and physical/runtime contracts |
| [L2_L3_CODING_INSTRUCTION.md](L2_L3_CODING_INSTRUCTION.md) | Developer integration and focused acceptance instructions |
| [implementation-notes.en.md](implementation-notes.en.md) | Implementation distinctions, narrow review questions, and historical provenance |
| [source-comparison.en.md](source-comparison.en.md) | Comparison of source forms and their roles |

[REVIEW_NOTES.md](REVIEW_NOTES.md) records the applied changes, verification scope,
and exact unresolved questions retained from the supplied requirements.

<a id="requirements"></a>
## Requirements

`TZ/` contains the supplied change requirements. Their source language is retained;
the operative English rules and examples are integrated into the primary documents.
Links to the documents have been adapted to this archive.

| Requirement | Integrated subject |
| --- | --- |
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
five source-requirement files, this index, and the review notes. Unrelated source
trees, generated binaries, test logs, and scratch editing scripts are not part
of the packet.
