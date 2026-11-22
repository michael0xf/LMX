# Fable review notes — English documentation revision

Date: 2026-11-21.

## 1. Review surface

The package contains nine primary documents and eight maintained accepted
supplements, plus six requirements under TZ: the original five and the latest
author clarification added during this review. The English primary
documents are the current review edition. The Russian grammar accidentally
included in the upload has been excluded at the author's request.

The developer instruction and the supplement `dirty.md` have been translated into English
while being reconciled with the current rules. The other accepted supplements
have been edited as part of the documentation, not treated as unapplied work.

Repository build diaries and historical execution receipts no longer serve as
current normative statements. Where detailed receipts are preserved, they are
clearly separated in [implementation-notes.en.md](implementation-notes.en.md).
The packet is reviewed through its local files and anchors.

## 2. Author corrections applied during this review

### 2.1 One argument contract for import, copy, and merge

The author removed the proposed DATA-argument variants.

**All three receivers use standard CODE arguments in every placement.** This
includes their records inside a surrounding DATA Structure. The same general
translator/evaluator argument mechanism applies; W/E does not acquire a special
DATA-placement exception.

A bare Structure reference and an anonymous Structure value are not themselves
calls. An anonymous Structure can nevertheless contain calls or computed
declarations. Their normal contracts determine when they execute. Grouping is
neither a universal quotation nor a request to execute every initializer early.

The corresponding [stream requirement](tasks/LMX_Fable_TZ_Import_Copy_Merge_Field_Streams_2026-11-21.md)
has been updated to revision 2. Old tables and cases claiming that a source
Producer() cannot call merely because merge/import was written in DATA have
been replaced.

### 2.2 Graph preservation and namespace

The clean graph is the complete literal source, including terminal primitive
declarations in their direct `{type value}` representation. Receiver records,
including `for`, `if`, `merge`, `copy`, and `import`, remain as written. All semantic
computation and transformation occurs in namespace.

This rule now constrains the descriptions of argument replacement, expression
evaluation, source copying, stream reception, and import. A result can contain
newly allocated values under the existing memory contract; its source receiver
is not replaced by that result.

A receiving DATA context is not an implicit source/model of merge. Overlay occurs
only among the sources of one merge invocation. Separate streams are accepted
through normal namespace/declaration behavior.

### 2.3 Blank lines

The blank-line requirement is treated as clarification and verification of the
common structural-boundary algorithm. It does not introduce an independent
parser or establish that an existing conforming parser needs a rewrite.

The documentation describes the complete root/block boundary and retains the
rules for protected text, paired delimiters, nested documents, and EOF. Source
examples have been checked for decorative blank lines that would accidentally
terminate an intended vertical block.

### 2.4 Author answer: zero-payload uninit and complete replaceable source graph

The author resolved P01 during this review. `uninit:T` is its type code only:
`sizeof(value) = 0`, with no reserved T cell and no inner T record. Assignment in
an execution frame changes its selected local place, leaving the clean graph
unchanged. Explicit graph assignment replaces a fragment at the selected field:
`struct\novalue := 5` replaces `{uninit:int}` by `{int 5}`. The former stable raw
payload-address and in-place retagging claims are withdrawn.

The author's further clarification confirms that primitive leaves are part of
the complete source graph, not an exception to its completeness. Every receiver
structure remains available as written and can be replaced through ordinary graph
assignment; this includes executable `for`/`if` and `merge`/`copy`/`import` forms.
When executable edits require recompilation, the existing compile/endturn restart
boundary applies. No second executable representation or special restricted
graph-editing protocol is introduced. The [new author note](tasks/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md)
records these decisions and overrides contrary earlier wording.

### 2.5 The complete program is the graph and compiled methods

The author's next clarification removes any interpretation that admits a working
graph under another name. Program material is the full Lmx graph plus a binary
containing compiled native methods. `parent` and `length` are logically determined
from source relationships; the other contents lie in the Lmx pointer array and
referenced records. R0 is an ordinary C method with a local pointer to the R0
graph, and interpreter execution also uses that binary R0.

The revised CORE, kernel, coding instruction, guide, and current implementation
notes prohibit hidden static DATA replicas, materialized namespace/program graphs,
copied executable bodies, and persistent expanded/callable graphs. This is a
representation rule, not a rename of a second graph. Ordinary local values,
operation-scoped bindings, runtime tables, arenas, and scheduling remain their
existing mechanisms. The clarification does not remove physically stored header
fields or require recalculating them from source text at each access.

The concrete `private` case is explicit: read its ordinary receiver in the same
graph, and let generated methods reflect the binding rule. Do not add a second
binary graph marked with privacy, initialization, or other node flags. Historical
working-copy receipts are labeled obsolete provenance, not permission to restore
that representation under an alternative name.

## 3. Integrated changes

| Area | Resulting contract | Principal files |
| --- | --- | --- |
| Callable structure | Ordinary C executes with its actual parent as DATA; call has code or args/code; R0 has no DATA/user actuals | Semantics, L2, kernel, CORE, guide |
| Result | return in DATA is a result description; return in CODE returns a value; no synthesized return | Semantics, L2, guide |
| Named fn | fn: name data has two DATA arguments and creates a constant positional signature description | Semantics, grammar, L2, guide |
| Structural versus fn matching | A structural template checks its required tree; fn checks ordered input types/count and result contract | Semantics, L2, kernel, CORE |
| Selection | W/E are equal candidates; explicit actuals only; selected mapping is not expanded again | Semantics, L2, guide |
| Binding | Own actual/default/autofill places; transparent caller place; former own-copy fallback; derived uninit for the specified inline local | Semantics, L2, kernel, CORE |
| Admission stages | Nonexecuting construction checks; explicit pre-C build tests; interpreted reached-call implements; prepared native contract; explicit implements in either path | Semantics, guide, kernel, CORE |
| Private | Both source and visible lexical receiving place filter implicit dynamic binding; explicit access remains ordinary | Semantics, guide, kernel |
| Declaration actuals | Retained DATA form; matching declaration replaced in namespace; unmatched inner name remains one positional Structure | Semantics, guide, kernel |
| Iterate behavior | Step repeatedly executes the retained declaration; body sees the same receiving local without a second initializer call | Guide, semantics, coding instruction |
| Operands | Ordinary method resolution, left/right, mandatory PASS_ARGS_AS_IS and PRIORITY, ordinary declared result | Semantics, grammar, L2, guide |
| Raw expression arguments | Original occurrence/context, explicit sys eval, no hidden evaluation by dereference, no permanent graph cache | Semantics, guide, kernel |
| Expression order | Demand dependencies, per-evaluation effect count, normal C ordering plus the specified exponentiation rule | Semantics, grammar, coding instruction |
| Sys name/priority | Identifier spelling without value lookup; priority from the available operand's ordinary properties | Semantics, L2, guide |
| Import | Root const declarations, including intrinsically constant user Structures; preserved source identity/parent; multiple sources | Semantics, guide, accepted supplements |
| Copy and merge | One source versus at least two admitted sources; field streams; explicit grouping for one Structure | Semantics, L2, kernel, guide |
| Stream input and result | Always-CODE input algorithm; source count separate from output count; ordinary W/E; no destination model | All affected contracts and the revised stream TZ |
| Arrays and physical types | Common variable-length descriptor/storage model; type code in the value record; ownership intervals do not determine type | L2, kernel, CORE |
| Uninitialized graph leaves and graph assignment | `uninit:T` is code only with zero payload; graph assignment replaces fragments; frame assignment leaves source unchanged; P01 resolved by the author | Author clarification, semantics, L2, kernel, guide, accepted supplements |
| Native/editing | Explicit compilation/update boundary; no restoration of old load-dirty or automatic invalidation mechanisms | Semantics, L2, kernel, accepted supplements |
| Complete program and R0 | Full graph plus compiled-method binary; R0 C method with a local graph pointer; interpreter also uses binary R0; no disguised working graph | Author clarification, CORE, kernel, coding instruction, semantics, L2, guide |
| Mail and ownership | One transport and source/donor ownership path; supervision parent distinct from lexical parent | L2, kernel, Thread/Message supplements |

Physical record layout, alignment, scalar ABI, arena ownership, native bridging,
copy correspondence, serialization, exceptions, and Thread/Message contracts
remain in the detailed documents. This revision does not substitute a general
summary for those contracts.

## 4. Files and links

All primary documents and accepted supplements have been processed. The original
five TZ source files remain unchanged during this reconciliation. The sixth TZ
file records the latest author clarification and takes priority where it revises
earlier physical or graph-assignment wording. The supplied stream TZ already
contains its revision-2 corrections. Links in the requirements
that formerly opened older exported documents now refer to the corresponding
files in the archive.

Historical references to repository journals, plans, scripts, or receipts are
either replaced by an included normative reference or retained as plain provenance
rather than a broken link. This does not fabricate the contents of omitted
repository material.

The complete L1 specification and a source repository were not supplied.
The included L2/materialization contracts are used for the present packet;
no absent L1 document is presented as if it were bundled.

<a id="open-questions"></a>
## 5. Derived review cases and the resolved physical-layout decision

The current rules decide D1 and D2 below without another author decision. P01 was
resolved by the author's explicit answer recorded below. Ask only if applicable current requirements explicitly conflict;
identify both clauses and a minimal case with different observable outcomes.
Superseded prose or an unspecified test-launch profile does not establish such
a conflict.

### D1. A no-RHS local in an inline nested scope

The current activation has an outer x = 5. It enters an inline nested scope
without making a new callable invocation. That scope declares a new int x with
no RHS/default; the activation's actual caller has no same-named x.

The new declaration creates a distinct inner place. Binding TZ §§6–7 permits
own-place autofill from the actual caller, not from a newly invented caller for
an inline lexical scope. Consequently the inner place is `uninit:int`; a reached
required check refuses the absence. The outer place remains 5. The derivation
does not depend on a previous executor report and introduces neither implicit
zero nor universal copying of outer locals. This supplies the ordinary-algorithm
derivation requested by Binding TZ §7.4.

### D2. Classification of unit-root source forms

Binding TZ §4.3 preserves R0's own executable declarations and ordinary references
while removing DATA and user actuals. A selected R0 entry therefore consumes its
reached records under the common CODE head contracts. Forms supplied as DATA use
the receiving DATA contract; import/copy/merge always retain CODE arguments.
There is no need to restore call(C C), an artificial DATA object, or a new node
meaning to classify these forms.

A fixture must state the host/source entry profile it uses. A fragment supplying
a DATA description can be prepared in that role and its explicitly named body
called through the ordinary call path. This does not invent automatic main
discovery, universal file-root execution, or a call to every declared Structure.
The absence of a concrete host launcher in this documentation packet is an
implementation-fixture boundary, not a contradiction in the language rules.

### P01. Resolved: code-only uninit and graph-fragment replacement

The author's answer supersedes both previous physical alternatives. `uninit:T`
contains only its code, with zero payload; a graph-field assignment installs a
new fragment. `struct\novalue := 5` replaces `{uninit:int}` by `{int 5}` instead
of initializing or retagging a reserved cell. There is no stable raw value-cell
address promised across replacement. Assignment in an activation changes only
the corresponding execution place. Absence and ordinary nil/required behavior
remain distinct from zero.

The [resolved record](implementation-notes.en.md#uninit-layout-conflict) retains
the old anchor for links. Structure-descriptor stability and Array-element
descriptor/index references are separate contracts. P01 requires no further
author question, and its implementation oracle now follows the
[latest author clarification](tasks/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

## 6. Validation scope

Documentation validation checks local link targets and anchors, Markdown
structure, preservation of useful explicit anchors, current normative wording,
and consistency of the worked examples with the supplied requirements.

No runtime source repository was part of this task. Language execution,
interpreter/native equivalence, or self-build results are not claimed from
editing these files. The detailed acceptance cases remain obligations for the
implementation review.

### Current documentation review record

The companion review read the original five governing TZ files, the subsequent
author clarification, the primary contracts, and all eight maintained supplements.
The always-CODE source roles, const-root
import identity, stream arities/grouping, independent copy maps, native-update
boundary, local place behavior, test scheduling, and Message/Thread boundary were
checked against those current requirements. Derived inline-local and entry-role
cases are recorded in §5; P01 records the author's completed answer and the
corresponding correction of storage, assignment and source-completeness wording.

The earlier packet's numerical link/fence counts are not evidence for this edited
edition. Reproducible file inventory, link/anchor, fence, and source-example checks
for the delivered revision belong to the accompanying current review report.
Edited documentation files are intentionally changed; the supplied archive is
the comparison baseline, not a claim that those edited files remain byte-identical.
The five original TZ files are not edited by this reconciliation; the sixth
records the new author clarification.

Markdown/example checks validate document structure and internal consistency.
They are not parser execution, native/interpreter conformance, transport results,
or a new compiler bootstrap. Historical receipts remain historical; none is
reported as a newly executed test.
