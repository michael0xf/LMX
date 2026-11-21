# Fable review notes — English documentation revision

Date: 2026-11-21.

## 1. Review surface

The package contains nine primary documents and eight maintained accepted
supplements, plus the five supplied requirements under TZ. The English primary
documents are the current review edition. The Russian grammar accidentally
included in the upload has been excluded at the author's request.

The developer instruction and Old_TZ/dirty.md have been translated into English
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

The corresponding [stream requirement](TZ/LMX_Fable_TZ_Import_Copy_Merge_Field_Streams_2026-11-21.md)
has been updated to revision 2. Old tables and cases claiming that a source
Producer() cannot call merely because merge/import was written in DATA have
been replaced.

### 2.2 Graph preservation and namespace

Receiver records remain as written in the source graph. All semantic computation
and transformation occurs in namespace. Terminal primitive declarations retain
their direct typed-value representation.

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

## 3. Integrated changes

| Area | Resulting contract | Principal files |
| --- | --- | --- |
| Callable structure | Ordinary C executes with its actual parent as DATA; call has code or args/code; R0 has no DATA/user actuals | Semantics, L2, kernel, CORE, guide |
| Result | return in DATA is a result description; return in CODE returns a value; no synthesized return | Semantics, L2, guide |
| Named fn | fn: name data has two DATA arguments and creates a constant positional signature description | Semantics, grammar, L2, guide |
| Structural versus fn matching | A structural template checks its required tree; fn checks ordered input types/count and result contract | Semantics, L2, kernel, CORE |
| Selection | W/E are equal candidates; explicit actuals only; selected mapping is not expanded again | Semantics, L2, guide |
| Binding | Own actual/default/autofill places; transparent caller place; former own-copy fallback | Semantics, L2, kernel, CORE |
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
| Native/editing | Explicit compilation/update boundary; no restoration of old load-dirty or automatic invalidation mechanisms | Semantics, L2, kernel, accepted supplements |
| Mail and ownership | One transport and source/donor ownership path; supervision parent distinct from lexical parent | L2, kernel, Thread/Message supplements |

Physical record layout, alignment, scalar ABI, arena ownership, native bridging,
copy correspondence, serialization, exceptions, and Thread/Message contracts
remain in the detailed documents. This revision does not substitute a general
summary for those contracts.

## 4. Files and links

All primary documents and accepted supplements have been processed. The
five TZ source files remain the change record. The stream TZ contains the latest
author revision; affected merge/import wording and examples in the binding and
blank-line requirements have also been synchronized. Links in the requirements
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
## 5. Exact inherited review questions

These are narrow checks explicitly left by the supplied requirements or identified
as executor interpretations in the old documents. They do not block review of the
other changes.

### Q1. A no-RHS local in an inline nested scope

The current activation has an outer x = 5. It enters an inline nested scope
without making a new callable invocation. That scope declares a new int x with
no RHS/default, then reads it. The activation's caller has no same-named x.

Separate inner identity and shadowing are fixed. Binding TZ §7.4 asks whether
ordinary autofill can use the parent inline scope in this exact case, yielding 5,
or whether the new place remains uninit:int because no new caller source exists.

Older documentation asserted uninit from an executor answer not included here.
That statement is no longer presented as an author decision. Fable should derive
the answer from the accepted general namespace algorithm or return this exact
example for an author decision. It must not implement a universal copy of all
outer locals to resolve this one case.

### Q2. Classification of unit-root source forms

R0's no-DATA/no-user-actual contract is fixed. The supplied material does not
fully settle how an entry profile classifies all records of a source unit at
that root after removing executable fn/sub and the former self-DATA launch.

Fable should identify the ordinary entry/profile rule that handles those forms,
or request the precise missing rule. The answer must not silently restore
call(C C), synthesize an artificial DATA object, or reinterpret node as a
substitute entry parameter.

## 6. Validation scope

Documentation validation checks local link targets and anchors, Markdown
structure, preservation of useful explicit anchors, current normative wording,
and consistency of the worked examples with the supplied requirements.

No runtime source repository was part of this task. Language execution,
interpreter/native equivalence, or self-build results are not claimed from
editing these files. The detailed acceptance cases remain obligations for the
implementation review.

### Documentation validation record

| Check | Result |
| --- | --- |
| Delivered Markdown files | 24: nine primary documents, eight accepted supplements, five requirements, README and these notes |
| Internal Markdown references | 706 checked; no missing files or anchors; targets resolve within the archive |
| Existing explicit anchors | All 298 retained; 327 explicit anchors in the revised packet; no duplicate explicit IDs within a file |
| Fenced examples | 211 balanced blocks, including 110 labeled LMX blocks |
| LMX blank-line boundaries | No blank physical line followed by an unintended indented continuation in the checked LMX examples |
| Markdown tables and historical appendices | Table column counts consistent; details containers balanced |
| Requirement synchronization | Named fn, declaration actuals, ordinary W/E, lexical node, operands, field streams, source graph and the always-CODE rule cross-checked across affected files |
| Factory example in blank-line TZ | Both returns use (copy(Product)); 340 nonwhitespace characters, 549 characters with whitespace/LF and 27 lines, including one final LF |
| English text | Primary documents and accepted supplements are English; original Russian identifiers and cited titles remain only in labeled historical receipts |
| Source preservation | The extracted original files remain byte-identical to their recorded SHA-256 hashes |
| Exclusions | No Russian grammar, scratch scripts, omitted repository dependency files, generated executable code, or runtime test logs are packaged |

The Markdown/example checks validate document structure and internal consistency.
They are not parser execution or native/interpreter conformance results. Historical
receipts remain historical; none is reported as a newly executed test.
