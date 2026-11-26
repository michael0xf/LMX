# Lingvamyxa — current specification and examples

**Latest follow-up — sized axes and direct TypeRef for every type.**
[Patch instructions](../PATCH_ARRAY_EXTENTS_2026-11-26.md) cover dynamic T[N],
complete LEFT identity, optional capacity storage and `sys\descriptor(typeof(obj))`.
The [TypeRef migration](../TYPE_REFERENCES_CHANGE.md) replaces integer type codes
with references to canonical immutable system Structures. This is a documentation
addition; source migration and production acceptance remain **NOT_RUN**.

**Дополнительный документ автора:** [LMX_INTERPRETER_JIT.md](../LMX_INTERPRETER_JIT.md) включён целиком из отдельного вложения от 26 ноября 2026; это проектная записка об общем основании интерпретатора и прямого генератора SLJIT.

**Revision 2026-11-26 — arrays and Expression.** [Array/matrix operations](ARRAY_EXPRESSIONS.en.md) now distinguish ordinary `*` from `.*`, elementwise equality `.=` from assignment `.:`; [fuse](FUSION.en.md) specifies one-loop evaluation; [conditional and strided slices](TERNARY_AND_SLICES.en.md) cover lazy branches and signed slice bounds. Native L2's omitted bounds checks do not legitimize negative Array indexing; use a pointer for a relative offset. The [revision and validation report](REVISION_2026-11-26.md) identifies all implementation and test limits.

[Operator depth](OPERATOR_DEPTH.en.md) is the middle input of left/depth/right:
one dot supplies 1, and `.(expression)` supplies an accepted depth through the
common parser. Dimension information comes only from the complete TYPE and
extents uniquely derivable with length; a reached operation diagnoses missing
information instead of guessing rows or factors.

[Type identity](ARRAY_STORAGE.en.md#array-profiles) is the normalized complete LEFT.
Every `{type value}` prefix stores TypeRef, the direct address of the canonical
system Structure, for primitives as well as derived types. `int[]` lengths 2/3
share a type; `int[][]` equals `int[](2)`; `int[2][3]` and `int[3][2]` differ.
Names, initializer rows, length and reserve do not specialize TypeRef.

The primary Lmx remains parent/length/storage. **Capacity=length means no secondary
descriptor**, for empty, 1D and nD Arrays. Only a larger reserve uses an optional
capacity-only entry; reserve/resize preserve the type and fixed constraints.
`sys\typeof(obj)` already returns its canonical type Structure reference.
[sys\descriptor(TypeRef)](ARRAY_STORAGE.en.md#type-descriptor) returns that same
Structure under the more specific canonical-TYPE contract. Ordinary object input
still yields three live primary-field addresses. Actual capacity is `sys\capacity(obj)`.
No per-object shape metadata or separate array-of-arrays entity is introduced.

[Sized axes](ARRAY_STORAGE.en.md#sized-postfix) accept full expressions in T[extent],
including int[][N] and Struct[2][5], alongside [dynamic repetitions](TYPE_DECLARATION_FORMS.md#dynamic-postfix)
`T[](N)` and T@(N). int[][3] plus six elements determines [2,3]. int[][] with those
same flat values or explicit rows is valid but retains two unknown extents; rows
validate the initializer without changing TYPE. Flat operations remain available.
Named/anonymous forms are supported; Struct[2]:= [a b] is ordinary indexed assignment.
Standalone [items] remains one whole Array value in an Expression chain. Ordinary
Structure field/index paths use the same graph mechanism.

The [physical ABI](L2_spec_en.md#value-record) uses sizeof(TypeRef), alignment before
the prefix, zero-payload uninit and relocation on restoration. Existing int-code
source listings and historical native receipts require migration; this packet
claims no production execution of the new contract.

An empty physical LMX line closes open blocks at levels 1 and above and resets the next code to logical level 0, under the existing string/Mix/bounded-input lexical rules. Redundant `---`/`end` before that reset or EOF have been removed; significant cutters remain. See [grammar](LMX_grammar.en.md) and [normalization tooling](../tools/NORMALIZE_LMX_CLOSERS.md).

**Current core:** [types, universal sequences, generic patterns, and callable adapters](CORE_SEQUENCES_REGEX.en.md). The root specifications of this uploaded archive govern this edition; old contradictory spellings are superseded.

**Previous revision: 2026-11-24.** The [revision report](REVISION_2026-11-24.md)
records the `->` signature name, shortened examples, refreshed comparisons and
the author's final Expression grouping rules. See the [clean-graph grouping
chapter](EXPRESSION_GROUPING.md) and [detailed algorithm with reference code](EXPRESSION_ALGORITHM.md).
There are exactly two operand forms: no left atom, or one left atom; both have
a right tail. The [26 November clarification](LMX_semantics.en.md#expression-structure-parent-guard)
classifies a graph reference atom to a Structure as a group only outside the
operand role. Translation rejects ambiguous interpretations.
The separate application adapter preserves one left actual and a right Array.

This is the documentation layout of the current uploaded archive. Historical notes
inside individual files can refer to the author's wider repository; those paths do
not change the layout or the source of this edition. The earlier naming work is summarized
in the [revision report](REVISION_2026-11-22.md), including the [naming decisions](NAMING_2026-11-22.md).

**Integrated baseline: 2026-11-23.** The uploaded `spec` documentation and its
parser-checked examples are the base of this edition. Canonical names,
generalized library contracts, adaptive constructors and both operation forms
are incorporated into the permanent chapters and current examples. Historical
restoration records remain provenance; they do not replace the current source.

**Answers to Fable are included in this archive:**
[FABLE_CLARIFICATIONS.md](FABLE_CLARIFICATIONS.md) answers every item in the supplied findings,
states the concrete corrections and includes the author's resolution of the R0 question.
The rules are also corrected in their permanent chapters. See the
[integration and verification report](INTEGRATION_REPORT.md) for the completed scope and execution limits.

**Current implementation work:** [direct core functions](CORE_FUNCTIONS.md) and
[library-use and implementation comparisons](patterns/CORE_COMPARISONS_2026-11-23.md). Control-language clients
use real language/library facilities; their separately authored implementations
remain comparison material. LMX clients use the corresponding direct kernel
functions. Functional comparisons publish both a complete procedural LMX client and
a complete functional LMX client for the same observable contract; shared library
implementations remain single canonical bodies.

The [standard-operation review](patterns/LMX_Fn_Receivers/CORE_STANDARD_REVIEW_20261123.md)
and [current catalog](patterns/LMX_Fn_Receivers/CATALOG.md) describe one core.
The [Common Lisp/SBCL comparison](patterns/examples/SBCL_comparison/README.md)
is included in full. PDF/XLSX comparisons count each complete procedural and
functional LMX source independently, including every written declaration and
`copy(target\throws)` reference. Green cells mark the actual minimum full count
in each comparable row. There is no statistical reduction of Throws.

**Author clarification — postfix declarations:** typed pointers use `Model@: p`
and `int@: left`; typed arrays place `T[]` before the colon. Both named and
anonymous square initialization are valid, including `Model[]: arr [Model Model]`,
`Model[]: [Model Model]`, `int[]: values [1 2 3]`, and `int[]: [1 2 3]`.
The [eight positive forms and composition checks](TYPE_DECLARATION_FORMS.md)
cover these declarations without rewriting genuine universal-reference initializers.

**Author clarification — declaration arguments:** a supplied declaration is a DATA Structure,
not an automatically executed call. Its internal name never selects an input. Unnamed actuals
use ordinary positions; only an outer `name := value` names a destination. See the
[merge note and complete numbers/cycles example](LMX_semantics.en.md#declaration-arguments).

The final naming revision restores `replaceRange` for target-returning range replacement and adds removed-returning `splice`, plus `hasPrefix`/`hasSuffix`. Current examples and preserved algorithms use `Struct@: ptr` and `type[]: array`. See the [application review](patterns/APPLICATION_REVIEW.md) for explicit source coverage and remaining runtime acceptance.

This edition integrates the requested
receiver rename, general functional library, containers and signature interchangeability.
The existing relationship of named signatures with call is preserved. Earlier repository
build receipts remain historical; the new source package requires its specified
kernel integration before runtime acceptance.

This is a self-contained documentation packet. Read and review the files as they
are arranged in this archive; no repository documentation build, generated mirror,
or absent journal is needed to follow its internal references.

The primary documents hold the whole norm: every change requirement and every
accepted supplement of the author is carried into them. Among the latest rules:
**import, copy, and merge always use ordinary CODE arguments**,
wherever their receiver records occur. An anonymous Structure is not itself a
call, but its contents can contain calls and initializers with their ordinary
contracts.

Expression is the ordinary Structure graph interpreted with a [structural grouper](LMX_semantics.en.md#expression-structural-grouping): it determines priorities, complete expression units and streams at the current tree level, independently of source spelling. A separate Expression application adapter packages left as one actual/reference bundle and right as an Array of references. `arg0 operand arg1 arg2 arg3` is the general form; a binary contract uses one right item, with no automatic fold or movement of the first right item into an absent left. The receiving contract selects whole-value or current-level sequence consumption. `(a b c) .: (a c b)` therefore has one left bundle and three right values; three sibling RHS groups remain three Structure items. There is no extra conditional unwrapping pass after grouping. The grouper reads the clean graph. In Expression, a graph reference atom to a Structure forms a group only outside the operand role. Translation rejects ambiguous interpretations before effects. Other reached Structures follow the name/actual-parent rule. Reference resolution preserves the actual parent. Whole VALUE/TYPE/DATA material is not automatically reclassified as CODE. `1 + ((2))` is 3; field collectors such as `(copy(Model))` remain containers for zero, one or many fields. `::` and modifiers keep DATA consumption and the common immediate-field reader; they gain no RHS evaluator. P0, ordinary callable W/E and the existing lifetime/effect rules remain intact. See [architecture and acceptance](EXPRESSION_GROUPING.md); execution is **NOT_RUN**.

The clean graph is the complete literal source representation, including terminal
primitive leaves as `{type value}` at addresses referenced by Structure cells.
All receivers, including `for`, `if`, `merge`, `copy`, and `import`, remain as written.
Computation and semantic transformation occur in namespace; results do not implicitly
replace those source records. Ordinary explicit graph assignment can replace these
fragments. Executable changes use the existing explicit compilation/endturn restart
mechanism when recompilation is needed.

The rules of [zero-payload `uninit` and graph assignment](LMX_semantics.en.md#uninit-zero-payload)
have priority over contrary earlier physical descriptions: `uninit:T` has only its
TypeRef and zero payload; frame writes leave source unchanged; graph writes replace
fragments. P01 is resolved, with no reserved T cell or raw payload-address promise.

The program has only the complete graph and a binary of compiled native methods.
R0 is an ordinary C method with a local pointer to its graph; interpreter execution
also uses this binary R0. `parent` and `length` follow logically from source shape,
and the other contents are represented by the Lmx pointer array and referenced
records. Ordinary runtime bookkeeping remains; a working/expanded/callable graph,
static DATA replica, or namespace-shaped program copy does not.

**Root startup clarification:** execution always starts at the root as an ordinary L3 Thread, without DATA or user actuals. CODE locals and calls use the common mechanisms. A parent stub with arguments may send an ordinary Message to the root; it does not select Main as an alternate entry. See [the startup contract and observations](LMX_semantics.en.md#source-entry-profiles).

## Reading order

The subject chapters are self-contained normative documentation:

| Chapter | Contract and implementation design |
| --- | --- |
| [Operation forms](OPERATION_FORMS.md) | All receiver/operand classes, exact names, roles, shared lowering and unary variants |
| [Generic operations](GENERIC_OPERATIONS.md) | Unified names, publication, type/->, common comparison, Pattern sources and explicit profiles |
| [Generic equality](GENERIC_EQUALITY.md) | Default equality, unique, equalFields, identity, errors and one range traversal |
| [Monadic operations](MONADIC_OPERATIONS.md) | Adaptive whole-value constructors, exact result types and one bind chain |

These chapters are part of the specification, alongside the English grammar,
semantics and implementation chapters. Source-only and reference-model checks
are identified separately from LMX runtime execution.

| Document | Purpose |
| --- | --- |
| [Core-function inventory](CORE_FUNCTIONS.md) | Complete public function list, new comparison helpers, implementation paths and integration duties |
| [Kernel integration of the receivers](kernel-implementation.en.md#receiver-kernel-integration) | satisfies rename, direct receivers, generic containers, signature equivalence and source links |
| [Receiver guide](patterns/RECEIVERS.md) | Complete catalog and value-record/callable distinction |
| [Receiver sources and API](patterns/LMX_Fn_Receivers/README.md) | Transferred and generalized source package |
| [CORE.md](CORE.md) | Architecture map and the relationships among the contracts |
| [LMX_grammar.en.md](LMX_grammar.en.md) | Structural parsing, levels, Frames, grouping, and source boundaries |
| [LMX_semantics.en.md](LMX_semantics.en.md) | Normative language semantics |
| [LMX_semantics_guide.en.md](LMX_semantics_guide.en.md) | Worked examples and execution explanations |
| [L2_spec_en.md](L2_spec_en.md) | Physical memory, machine-side operations, runtime interfaces and ABI |
| [kernel-implementation.en.md](kernel-implementation.en.md) | Shared implementation algorithms and physical/runtime contracts |
| [L2_L3_CODING_INSTRUCTION.md](L2_L3_CODING_INSTRUCTION.md) | Developer integration and focused acceptance instructions |
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
| New generic receivers, containers and direct names | [receiver chapter](LMX_semantics.en.md#functional-receivers), [kernel integration](kernel-implementation.en.md#receiver-kernel-integration) |
| Interchangeable signature forms, preserved named-signature/call behavior | [equivalence](LMX_semantics.en.md#fn-forms-equivalent) |
| Complete program graph, binary of compiled methods, zero-payload `uninit`, graph assignment | [program representation](LMX_semantics.en.md#program-representation), [`uninit`](LMX_semantics.en.md#uninit-zero-payload), [graph assignment](LMX_semantics.en.md#graph-fragment-assignment), [required observations](LMX_semantics.en.md#regression-obligations) |
| Callable Structures, actual parent as DATA, named `Name :: DATA` signatures, selection, binding places, two-way `private` | [binding places](LMX_semantics.en.md#binding-places), [decisions R01–R19](LMX_semantics.en.md#binding-decisions), observations [B01–B27](LMX_semantics.en.md#binding-observations) and [C01–C36](LMX_semantics.en.md#callable-observations) |
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
`copy` and `merge`. Signature declarations still inspect the complete DATA template supplied as one
right argument of the ordinary `Name :: DATA` operand; modifier DATA contracts are
unchanged. Earlier wording quoted to explain a migration does not establish an
alternative current syntax.

`L2_L3_CODING_INSTRUCTION.md` was supplied in Russian and is English in this
packet. The current uploaded `LMX_grammar.en.md` is retained and updated together with the semantics. A complete new Russian translation of the primary documents is outside this pass.

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

This directory contains the current specifications, reading guides, revision reports,
implementation contracts, and the complete patterns/example package. Source code for
the proposed core receivers, publication tools, and scoped verification reports are
provided under `patterns/`; an executable LMX kernel is not included.
