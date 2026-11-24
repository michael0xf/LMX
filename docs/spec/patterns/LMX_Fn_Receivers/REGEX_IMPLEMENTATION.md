# Generic Patterns and text profiles: concrete LMX implementation

Revision: **2026-11-23**, integrating generic source domains, shared range equality, both operation forms and the AR01 interface-observation contract. The normative source is [the Regex requirements](../../CORE_SEQUENCES_REGEX.en.md#patterns), together with [the common Array/reference requirements](../../CORE_SEQUENCES_REGEX.en.md#types).

**Status:** the matcher algorithms are written in LMX. This is a source implementation for integration, **not a report of successful execution on an LMX kernel**. The archive supplied no runnable kernel against which these sources could be checked. Ordinary call admission, the AR01 read-only interface observation, the declared-failure metadata of dynamic callable dependencies, and the existing `|` implementation still require the common integration described below. None of those gates is a placeholder for an unimplemented regex engine.

## Source map

| Source | Implemented responsibility |
| --- | --- |
| [support.lmx](src/regex/support.lmx) | Ordinary structural requirements, Pattern factory, candidate cursors, persistent capture entries, Match and Span construction |
| [source.lmx](src/regex/source.lmx) | Generic prepared sources, Array/text domain adapters, slicing, replacement roles and profile-preserving assembly |
| [text.lmx](src/regex/text.lmx) | UTF-8 decoder, byte profile, scalar-to-byte offsets, text materialization and fragment copying |
| [primitives.lmx](src/regex/primitives.lmx) | Literal sequences, whole elements, sets and complements, domain ranges, predicates, boundaries, `sameAs` and position/text-profile probes |
| [values.lmx](src/regex/values.lmx) | Ready Pattern references, including ASCII classes, CRLF-aware anchors and `wordBoundary` |
| [combinators.lmx](src/regex/combinators.lmx) | Sequence, ordered alternative, bounded/unbounded repetition, atomic selection, captures, forward assertions and backward assertions of unrestricted width |
| [operations.lmx](src/regex/operations.lmx) | Matching, prefix/suffix predicates, searching, iteration, replacement, splitting and capture accessors |
| [operands.lmx](src/regex/operands.lmx) | Five ordinary operands and the additional Pattern branch of existing `|` |

[REGEX_EXPORTS.json](REGEX_EXPORTS.json) gives exact public names, qualified implementation paths, operand metadata, assembly order, dependencies, and integration gates. Its canonical entries include the generic `arrayView` and `element` constructors; the current catalog records both forms and every semantic variant. Ready Pattern values, configuration values, ordinary requirements and declared-failure names are listed separately. The extension of `|` adds no new public name.

The API spells the byte profile **`byteText`**, and first-match search **`find`**, following the current requirements. It does not introduce competing `bytesText`, `findFirst`, `or`, or a new `match`. Existing `repeat`, `lazy`, `some`, `none`, `record`, `guard` and their meanings are retained.

## Why these names and operations are unified this way

| Existing word or operation | Applied meaning | Boundary preserved |
| --- | --- | --- |
| `|` | Ordered alternative between Pattern values | The same existing sign keeps numeric and Array behavior when no Pattern is present; it is not Boolean `||` |
| `then` | Match the written parts one after another | Sequence construction does not reinterpret arithmetic `+` or merge/copy |
| `times`, `atLeast`, `atMost`, `optional` | Exact, lower-bounded, upper-bounded and zero-or-one multiplicity | Ordinary count meanings remain visible; `optional` constructs a Pattern rather than a Maybe value |
| `literal`, `element`, `oneOf`, `within` | A literal sequence, one whole element, a set of units, an inclusive domain range | Text decoding and range conversion are explicit profiles; no second regex parser |
| `then`, `choice`, `repeated` | Ordinary constructors with explicit ready values/settings | The short operand forms delegate to the same construction algorithms; they are not separate variants of the semantics |
| `some` / `none` | Existing presence/absence result containers | Empty successful text stays `some`, and no extra regex-only option type is created |
| `extendFirst` / `stopFirst` | Order of matching attempts | Existing `lazy` remains deferred/cached callable evaluation, and existing `repeat` keeps its call-repetition contract |
| `T[]`, `T@`, `[]: [parts]` | Existing common type and Array/Structure construction | Pattern arrays require no new container syntax, wrapper type or automatic spread |

The criterion is recognizability of the action and reuse of its existing mechanism. It is not a mechanical ban on new words or a search for shorter unfamiliar glyphs. All public names remain direct core entries; the `Rx...` names only identify implementation helpers.

## Actual representation and lifetime

`Pattern` is a named signature of an ordinary callable with one `RxPreparedSource` input. Public matching/searching accepts an explicitly prepared view role: `arrayView` preserves actual Array units; `utf8Text` and `byteText` preserve their text profiles. `RxPrepareSource` invokes the view's declared preparation method once and does not guess the domain from physical fields. A constructed Pattern is the `open` method of a copied ordinary owner:

- The owner stores its engine method reference and configuration.
- Its nested `Call` Structure is actual DATA for `open`, with `source`, `position` and `captures` inputs.
- `open` returns a nullary candidate cursor with its own copied owner and explicit ordinary state.

Returning the selected method retains its actual parent and lexical links under the normal factory rules. The body uses `parent() = parent(D)`, where `D = parent(C)`, to reach the owner of the nested Call/Next DATA; it does not equate lexical `node` with that DATA. The copied `private` Frame is shared by the collecting container and the actual copied owner through one copy map, so the explicit configuration writes address the same stored fields. Configuration enters those ordinary objects by explicit writes. No address of an automatic local, saved `left/right` activation or reconstructed native stack frame is retained.

A cursor's step returns the existing `Maybe`: `Some` carries an ordinary candidate with a new position and a capture-journal reference; `None` means exhaustion. A successful zero-length candidate is therefore distinct from exhaustion. The internal cursor protocol uses normal nullary calls and explicit state. Public `eachMatch` wraps that protocol with the existing `yield` suspension and declared `Stop` completion. It never catches a callback's `Stop` and misinterprets it as its own exhaustion.

`Match`, `Span`, `ArrayView`, `TextView`, `RxPreparedSource`, the text decoder's `RxPreparedText`, capture entries and search frames are ordinary Structures. They have no new physical type code, object kind, special pointer category or executable instruction format. A Structure remains the same `@[]` reference sequence accepted by the shared Array layer.

Typed requirements use the existing postfix heads. For example, the internal input is **`RxPreparedSource@: source`**, not `@: source RxPreparedSource`: the latter would initialize a universal reference with the model itself. Public source admission retains its explicit view family. The same distinction applies to `Pattern@: pattern`, `Match@: matched` and predicate/replacement references. `char[]` and `int[]` are ordinary dense arrays. Configuration defaults such as `@: maximum unbounded` intentionally remain initialized universal references.

All state is owned by the current Message and ordinary reference graph. No Thread, global mutable regex registry, parser, bytecode VM, opcode table or hidden second program graph is introduced.

<a id="ordered-candidate-enumeration"></a>
## Ordered candidate enumeration

`choice` maintains the current branch and its cursor. It exhausts that branch's candidates before opening the next branch. `then` maintains an explicit linked stack of child cursors. A failure of a later child pops only that stack level and requests another candidate from the preceding child. The matching code does not implement alternative as Boolean `||`.

Consequently, `(then (literal("a") | "ab") "c")` on `abc` first tries the local `a` result and can then return to `ab`. `wholeMatch` filters complete candidates by the required end position **while enumerating** them. It does not select `a` and reject the whole operation before considering `ab`.

Repetition uses one ordinary frame per explored iteration. Each frame records its candidate, count, child cursor, whether it has offered stopping, and whether extension is exhausted. The algorithm implements the two explicit orderings:

- `extendFirst`: explore another iteration before offering a permitted stop.
- `stopFirst`: offer a permitted stop before exploring another iteration.

The minimum and maximum control those choices. `unbounded` is an ordinary configuration value rather than a negative count or an overflowing sentinel. A zero-progress iteration prevents **optional** further repetition on that path; remaining mandatory iterations can still reach the finite minimum. The child cursor is retained, so other alternatives of the same body can still be explored on backtracking. Thus exact repetition of an empty Pattern can complete, while unrestricted repetition of an empty Pattern terminates. This ordering is local depth-first enumeration, not sorting all results by length.

`atomic` has a cursor which requests at most one candidate from its child. A later sequence failure cannot reopen that child; a surrounding choice can still try its other branches.

## Boolean predicates over the selected source

All four predicates require one source view and one pattern. They use the same `RxPrepareSource` and ordinary normalization as `matchAt`: an existing Pattern or explicitly selected literal input interpreted by that source's domain. Whole Array elements are not narrowed to char or int, and no regex-string parser is introduced. The result is an `int` equal to 1 or 0. A successful empty match counts as success; admission, encoding and callback failures remain failures.

| Receiver | Accepted position | Result |
| --- | --- | --- |
| `contains(source; pattern)` | Any valid start; unmatched beginning and tail permitted | Whether a match exists anywhere |
| `hasPrefix(source; pattern)` | Start exactly 0; unmatched tail permitted | Whether a prefix match exists |
| `hasSuffix(source; pattern)` | End exactly at the complete source length; unmatched beginning permitted | Whether a suffix match exists |
| `matches(source; pattern)` | Start 0 and end at the complete source length | Whether the whole input matches |

`RxHasPrefix\hasPrefix` delegates once to `RxMatchAt\matchAt(source := source; pattern := pattern; position := 0)` and returns its presence flag. It introduces no second preparation, matcher or kernel hook. `matches` retains its existing delegation to `wholeMatch`; it does not acquire prefix semantics.

`RxHasSuffix\hasSuffix` prepares the current source and normalizes the pattern once. It then tries every valid start from 0 through the source length, including the final boundary, on that same complete prepared source. At each start it calls `RxSelectAt\select(...; position := start; whole := 1)`. In this helper, `whole` filters the candidate's **end**, not its start: a candidate must end exactly at the original source length. Filtering happens while candidates are enumerated, so an incomplete first alternative does not hide a later valid suffix. The source is not sliced, preserving the meaning of source-relative anchors and lookaround.

This must not be implemented by taking the last result of `find` or `eachMatch`. For `literal("a") | literal("ab")` on `ab`, suffix matching must revisit the later `ab` alternative. On `ababa`, the literal `aba` ending at position 5 overlaps the earlier match at `[0,3)`; the non-overlapping iterator may omit it, but `hasSuffix` must return 1. The final start also admits an empty suffix on either empty or nonempty input.

The [boundary example](examples/regex_boundaries.lmx) contrasts all four predicates. Acceptance fixtures separately cover [prefix behavior](tests/regex/case_has_prefix.lmx), [suffix alternatives and overlap](tests/regex/case_has_suffix.lmx), and encoding failures for [prefix](tests/regex/case_has_prefix_encoding.lmx) and [suffix](tests/regex/case_has_suffix_encoding.lmx). They remain source-level acceptance material, not executed runtime results.

## Capture histories and lookaround

Capture histories are persistent singly linked ordinary Structures. Finishing a successful capture allocates one entry with `previous`, `name`, `begin` and `end`. A failed path abandons its new head; it never edits the history shared with another path. Nested captures complete inner-first, and accessors reverse the linked history when producing chronological arrays.

`sameAs` searches backward for the latest completed entry of the requested name and compares its source units literally. Missing names fail normally; an entry with equal boundaries is present and can match an empty string. There is no global capture registry and no use of same-named caller locals.

Lookahead obtains a candidate at the current start. Lookbehind enumerates possible starts from zero through the current position and accepts only a candidate ending exactly there. The underlying Pattern still sees the whole source, which matters for nested position tests and lookaround. There is no artificial fixed-width limitation.

Positive and negative lookaround preserve the outer position and outer capture head. Previously completed captures remain readable, but newly created local captures are discarded at the boundary. The code catches no encoding or callback failure to implement negation: absence of a candidate and a failed operation remain different outcomes.

## Source units and domain profiles

`RxPreparedSource` holds the original view, actual units and an explicit domain. The domain supplies literal preparation, range-bound conversion and slicing. `arrayView` retains dense/reference element admission; `element(x)` matches one complete value, while `literal(xs)` matches a sequence. `satisfy` and `boundaryOf` validate an actual unary predicate before matching, including empty input. `within` uses the selected element order and converted bounds. `FxSequenceDifference` is the single range-comparison loop for literals, `sameAs` and ordinary sequence equality.

An AST node is one value. Recursive matching may prepare its children with `arrayView`; captures from different sources retain explicit source/coordinate ownership. Combinators, backtracking, zero-progress rules and capture journals are unchanged between domains. See [generic operations](../../GENERIC_OPERATIONS.md) and [publication](PUBLICATION_CONTRACT.md).

### Text units and results

`utf8Text` validates the supplied `char[]` and returns a public view containing its original descriptor and the explicit profile. Each reached public search then validates and decodes the **current** source into a separate ordinary `RxPreparedText`: an `int[]` of Unicode scalar values plus a scalar-to-byte-offset array, the source descriptor, the profile and a reference to that original view. The decoder rejects invalid leads, malformed or truncated continuation sequences, overlong encodings, surrogate values and values above U+10FFFF. It does not normalize, fold case, insert U+FFFD or interpret UTF-16 units or grapheme clusters.

`byteText` treats each physical element as an octet in 0–255. `arrayInfo.elementBits` must report eight for this substrate. Negative signed-char values are converted to their unsigned octet value explicitly. This layout query is shared type metadata, not a regex-specific service.

CRLF is two text units and one logical line break. The CR branch consumes both units; the LF branch refuses the second half of a CRLF pair. Line anchors refuse the position between them. ASCII classes use their exact numeric ranges; no locale is consulted. NUL is an ordinary source unit and no terminator is added.

The original source descriptor and profile are retained by `TextView`; no raw pointer into Array backing is stored. The per-operation unit/offset arrays are explicit text-index data, not another executable graph. The caller keeps the source alive and unchanged during search, suspended iteration and access to source-backed results. The referenced Pattern dependencies follow their existing stability/lifetime contract. These sources do not silently copy the source text or install change watchers.

### Fresh preparation, original view identity and reuse

The public `TextView` stores **no units/offset cache**. `RxPrepare` builds current units and offsets once at the start of each public `matchAt`, `wholeMatch`, `find`, `eachMatch`, `hasSuffix`, replacement or split operation; `contains`, `hasPrefix` and `matches` delegate to those same entry points. Every candidate, backtracking step and `eachMatch` resume in that operation shares the one prepared context. An `eachMatch` iterator owns it from construction through its final suspension/completion.

`Match.source` and `Span.source` remain the **original public TextView object**. A separate ordinary `private\prepared` reference retains the index belonging to the selected operation. `matchedValue` and capture accessors use those retained offsets and source descriptor; they do not consult an index later overwritten by another search. Starting a new search never edits an old Match, Span or prepared context.

After a completed operation and after finishing access to its source-backed results, a caller may change the source and reuse the **same view** for another search. That search rebuilds its index from current bytes, so both changed scalar values and changed scalar widths are observed. Invalid new UTF-8 raises `PatternEncoding` at the new operation. This follows the normative stability interval without extending it to the entire view lifetime. There is no watcher, version field, source snapshot, second executable graph or promise that mutation during an active operation will be diagnosed.

The fixtures cover [same-view reuse and source identity](tests/regex/case_rebuild_view.lmx), [changed scalar width and retained offsets](tests/regex/case_reuse_view_width.lmx), and [invalid new bytes](tests/regex/case_reuse_view_invalid.lmx). Previous source-backed results are not accessed after the source mutation in those fixtures. Constructor validation currently uses the same explicit decoder as search preparation and discards its temporary index; avoiding that temporary constructor index is a permissible implementation optimization, not a condition for correct reuse.

In a text profile, `matchedValue`, `captureValue`, `captureValues` and `split` explicitly materialize new `char[]` fragments. In an Array profile, those accessors use the same domain slicing contract and preserve the admitted Array representation; multi-fragment results retain their declared outer collection. `Match`, `Span` and `captureSpans` retain descriptors and positions. Already emitted Match boundaries and journal heads are never rewritten by later iteration.

## Empty matches, replacement and splitting

`RxFindNext` owns the search position and a flag that excludes empty candidates at the current start. After an empty match it first tries the same start with that exclusion. Only if no nonempty candidate exists does it advance one unit. At the final source boundary, the last empty match completes the search.

Replacement and splitting keep a separate `copiedUntil` cursor. The search's advance after an empty match therefore does not omit a source character from the output. Required observations include:

| Source and Pattern | Operation | Required result |
| --- | --- | --- |
| `ab`, `emptyPattern` | `eachMatch` | Empty intervals at 0, 1 and 2 |
| `ab`, `emptyPattern`, replacement `-` | `replace` | `-a-b-` |
| `ab`, `emptyPattern` | `split` | `""`, `"a"`, `"b"`, `""` |
| Empty input, `emptyPattern` | `split` | Two empty fields |
| Empty input, `neverPattern` | `split` | One empty field |

The qualified replacement entry is `RxReplace\replace(source; pattern; replacement)`. It returns a fresh result admitted by the source profile and does not mutate the source; the text profile publishes an exact `char[]` result. The separate sequence operation `replaceRange(target; begin; end; values)` mutates a range and returns that target. The sequence operation `splice(target; begin; end; values)` performs the range edit and returns the removed elements. These operations have distinct public names and result contracts.

Before search, the public role selects `RxReplacementLiteral\accept` or `RxReplacementCallable\accept` and constructs ordinary `RxReplacementInput` DATA. A callable's physical Structure storage cannot silently select a literal role; real ambiguity requires an explicit representation. The callable receives one whole `Match` through the signature's actual map and runs once per **selected** match. It is never run for rejected candidates. Its result is admitted to the same source profile and appended without being searched again; text additionally validates encoding. On failure there is no partial returned output; already performed external callback effects are not rolled back.

## Operand integration

The established five short Pattern words use `PASS_ARGS_AS_IS = 0`, private `left/right`, an optional left and required right. The runtime supplies an explicitly empty right vector for a postfix form. `then` has the ready priority obtained from `sys\priority("+")`; the four repetition words use `sys\priority("*")`. Their order is left-to-right. The existing priority, binding, modifiers and defaults of `|` remain unchanged.

An operand method explicitly calls `RxLogicalArguments` inside its body when its own algorithm needs a logical argument sequence. The helper appends the **whole** supplied left reference, if present, followed by the already prepared right elements. It does not reopen a group, unwrap an Array, fold a right tail automatically, re-evaluate any occurrence or inspect written arity to consume neighboring expressions. The parser and transport preserve an absent left and never move the first right argument into it; this method-owned collection is not a universal pre-call binder.

The absence check `left != nil` uses the current [ordinary absence-state comparison](../../LMX_semantics.en.md#colon-declares); it does **not** dereference `left` or read nonexistent payload bytes. In prepared operand ABI, a written nil/uninitialized value has a present reference to its typed record; an omitted left leaves the receiving reference cell uninitialized. Those must remain different. [The explicit-nil fixture](tests/regex/case_nil_left.lmx) checks that nil data is rejected as Pattern/text, rather than silently omitted.

The [Expression grouper](../../LMX_semantics.en.md#expression-structural-grouping)
handles priorities, groups and field streams from the supplied graph. In
CODE/Expression an ordinary named Structure with the current lexical parent
follows the ordinary call path; a named Structure with another parent and every
anonymous Structure are grouped with the actual parent retained. Whole Pattern
values remain under their receiving value contract. The separate
application adapter packages the left side as one actual and the current right
stream as an Array of references. The established argument vectors follow from
that plan and ABI, not a conditional opening pass after grouping. Three right
Structures remain three elements at that level. P0 retains the graph; Pattern
values accepted under a whole-value contract are not automatically consumed as
CODE. This package performs **zero additional openings**.

All Pattern receivers also have the general operand representation under the [common form contract](../../OPERATION_FORMS.md); the five short words below retain their established arity/priority policies. Both `then` forms delegate to `RxSequence\then`: an ordinary zero-part call returns `emptyPattern`, a single part is returned, and the established operand form requires at least two logical arguments.

The existing `|` implementation calls `RxAlternativeDispatch\probe(left := left; right := right)` after its existing preparation. When `handled` is false, it executes its original numeric/Array algorithm with the original arguments. When at least one logical argument satisfies `Pattern`, the branch requires two or more arguments and admits every one in its explicitly selected Pattern or domain-literal role before constructing `choice`. Arithmetic and Array operations with no Pattern are untouched. `|=` keeps ordinary compound-assignment evaluation and admission.

The archive contains the high-level branch, not the old kernel's implementation body. Connecting that branch at the existing `|` entry is a concrete remaining integration step; replacing `|` with a Pattern-only function would be wrong.

## Common kernel gates and failure contract

There are **no regex-specific checking or matching bridges**. The common
`FxKernel.acceptsRequirement(candidate; requirement; consumer=0)` boundary is a
required read-only exposure of the existing directed interface checker; its
strict [AR01 contract](KERNEL_REQUIREMENTS.md#interface-probe-ar01)
and [acceptance matrix](tests/regex/ADMISSION_PROBE_ACCEPTANCE.json) are explicit
remaining kernel work. The native provider is **not implemented or verified in
this source archive**.

The former four uses of `satisfies` as an `int`/Boolean result were invalid:
that public receiver has no newly invented Boolean ABI. `RxIsPattern`,
`RxRepeated` and the explicit replacement admission routes use the common
observation bridge where a full requirement must be observed. It returns 1 only for established compatibility and 0 only
for established incompatibility; unknown remains a service failure and cannot
select numeric `|`, literal normalization or a finite repetition bound.
Ordinary later typed reception keeps its existing value checks and effects.

Raw type-tag equality would incorrectly narrow compatible Pattern signatures
and replacement requirements. Likewise, comparing the `unbounded` object's
identity would reject an ordinary copied configuration. The bridge reuses full
structural/positional admission relationships without executing a Pattern,
replacement, initializer, default, test or converter. It adds no public API,
global registry, speculative matching attempt or new Pattern representation.

The two finite service outcomes `FxKernelFailure` and `FxTypeToken` remain in the finite contracts on the static paths to this observation, including normalization, sequence/choice/repetition construction, word
operands, matching/search wrappers, lookaround construction and replacement.
[AR01_STATIC_DECLARATIONS.json](tests/regex/AR01_STATIC_DECLARATIONS.json)
records the reviewed paths and their called dependencies; the current complete source/effect audit also covers the added generic domain and admission routes. This is not an
inferred union of arbitrary callback failures. Returned matcher cursors do not
re-run construction-time normalization merely because they resume; their
dynamic callable-failure contract remains the separate gate below.

The implementation also uses the shared sequence layer's `FxSeqInfo`, `FxSeqRead`, `FxSeqPush` and checked-size helper `FxSeqSize`. Their underlying Array metadata and read/admit/write bridges preserve actual dense layout and the direct value-record references of `@[]`. `then` and `choice` do not require a dense source to be boxed into a new reference-array representation before reading its elements.

The ordinary factories additionally need these existing language mechanisms to work on the real kernel: copy with correct lexical/parent maps, returned nested methods, typed-reference admission, direct calls, checked allocation/resize, `yield`/`Stop`, and lifetime retention. New Pattern/text values do not need a native object tag or special allocator.

A concrete remaining **common declared-failure integration gate** concerns dynamic callable dependencies. The Pattern and replacement entries must obtain the applicable failure sets through the existing signature/call admission mechanism, compose their finite declared-failure metadata and preserve original failure name and typed payload at the public call boundary. The matcher sources use ordinary direct callbacks and do not catch their failures. A runtime that requires the generic `FxCallFailure` transport envelope may use it internally, but must rethrow the original admitted failure transparently at the specified boundary; it must never reinterpret that envelope as `None`, false, or successful negative lookaround. The exact `throws` metadata must be validated together with these copied callable instances. This source bundle does not claim that this native integration or arbitrary callback failure metadata has already passed a compiler.

Errors for invalid counts/ranges/arity, encoding and position remain the declared `PatternArgument`, `PatternEncoding` and `PatternPosition`. Ordinary admission failures remain admission failures. Array-size or resource exhaustion remains its own failure and is never “not found.” There is no claimed linear-time guarantee for unrestricted backtracking or `sameAs`.

## Verification and pending acceptance

[PUBLICATION_CONTRACT.md](PUBLICATION_CONTRACT.md) fixes the source-role, literal/callable, exact result and finite failure boundaries. [GENERIC_OPERATIONS.md](../../GENERIC_OPERATIONS.md) records generic-domain and both-form observations; current status remains source-only and runtime **NOT_RUN**.

[tests/regex/fixtures.json](tests/regex/fixtures.json) indexes **41** current numbered requirements and **57** source fixtures. The original 35 requirements retain their fixtures; four boundary fixtures cover prefix/suffix behavior, including end-reaching alternatives, overlap, empty success and encoding failures. The traceability for requirements 39–41 explicitly records the remaining empty-input combinations, boundary/profile/lookaround combinations and declared-callback-failure integration gate. These source fixtures do not establish complete runtime coverage. The source files deliberately include failure cases. They are acceptance material, not automatically imported program modules, and each has `pending_lmx_execution` status.

A limited [visible-level audit](tools/audit_new_sources.py) shields literal payloads, checks ordinary indentation cuts and reports terminal/paired-form cases for manual review. The [recorded audit](tests/regex/source_level_audit.json) is a source-layout check only. It is neither P0 validation nor a behavioral test. Explicit `---` cutters were inserted at multi-level decreases in the newly written bodies; existing examples were not automatically reformatted by this tool.

The semantic review covered candidate order, whole-end filtering, prefix/suffix boundaries and overlapping suffixes, rollback through persistent captures, zero-progress termination, same-start nonempty retry, source copying after empty matches, CRLF boundaries, fresh per-operation text indexes, original TextView identity and the current postfix type heads. Runtime success, native/JVM performance, complete failure-set lowering and compatibility with a concrete executor remain unverified. Those limits do not remove any of the requested matcher algorithms or weaken the acceptance observations.
