# Unified types, sequences, patterns, and callable adapters

The [naming review](NAMING_2026-11-22.md) records the current public words and their language analogues; the LMX contracts below remain authoritative.

**Current documentation, 22 November 2026.** This chapter applies the three specifications shipped at the root of this same archive: [types](../LMX_Array_Reference_Types_Core.ru.md), [sequences](../LMX_Sequence_Operations.ru.md), and [text patterns](../LMX_Regex_Operands.ru.md). The callable-adapter requirements are those already present in the uploaded [semantics, §37](LMX_semantics.en.md#adapter-behavior), including its A/B acceptance cases. No earlier archive is a source for this revision.

The language contract below is normative for this documentation edition. LMX source implementations are supplied in [the core source directory](patterns/LMX_Fn_Receivers/README.md). Their integration with the actual kernel and execution of the acceptance fixtures remain to be performed. Source inspection and publication checks do not constitute runtime tests.

<a id="types"></a>
## 1. Type expressions and declarations

A type is represented publicly by an ordinary `int` code. `T[]` constructs the interned type of an array whose elements satisfy the complete requirement T. `T@` constructs a pointer type. Repeating postfixes applies them from left to right: `int@[]`, `int[]@`, `int[][]`, and `int@@` are different requirements. Pointer depth is any finite value supported by available resources; there is no language limit of three levels.

The common TYPE-role normalizer accepts a valid code, a symbolic type atom, an uninitialized typed record, or a full model as appropriate. It preserves complete structural and callable requirements. In `@[]`, the left `@` is the universal reference requirement; the result is the existing Structure/reference-array type. It is not another STRUCT/ARRAY category and allocates no array value. A numeric value that happens to equal a type code does not acquire a type role by itself.

| Written form | Meaning |
| --- | --- |
| `[]: pending` | Uninitialized place accepting any Array, including a dense Array and an ordinary Structure |
| `@[]: refs` | Uninitialized place requiring the specific reference-array/Structure type |
| `int[]: values` | Uninitialized array-of-int place |
| `int[]: values []` | Initialized empty array of int |
| `int[]: values [1 2 3]` | Initialized named typed array |
| `int[]: [1 2 3]` | One anonymous typed array value |
| `[]: [1 2 3]` | One anonymous ordinary Structure/reference-array value |
| `[]: values [1 2 3]` | Named generic-array place initialized with a Structure |
| `@: values [1 2 3]` | Universal reference to a Structure; no additional wrapper |
| `T[]: [copy(S)]` | Typed array from the explicit element stream inside the square group |
| `T[]: destination Source` | Named place initialized from a suitable existing value |
| `@: p` / `T@: p` | Uninitialized universal/typed reference |
| `T@: p 0` | Initialized null reference; distinct from uninit |
| `@x` | Address of the actual place x under the selected level's address contract |
| `x@` | Pointer type constructed from x in TYPE role |
| `@(name)` / `[](name)` | Ordinary compact declarations, equivalent to `@: name` / `[]: name` |

A sole declaration identifier is consumed as a NAME before lookup; a sole square group supplies anonymous data. A NAME followed by a square group supplies the explicit initializer. An existing same-named value cannot change this classification. The generic receiver path determines argument roles before attaching an initializer group as if it were an index. There is no whitespace-specific array parser.

A typed anonymous constructor requires its square group. `T[]: copy(S)` is not an alternative anonymous constructor. `@[]: [S]` holds one reference to S; `@[]: [copy(S)]` receives the explicitly emitted fields. A type expression performs no copy, initializer execution, or compilation.

A written empty suffix `T[]` constructs a type. A suffix containing a written index expression uses indexing, even when that expression later produces an empty stream: `a[()]` and `a[copy(empty)]` do not become type constructors. Original groups and postfix occurrences remain in the source graph.

`Struct@: p` and `(Struct)@: p` each normalize their complete left description; the enclosing group in the latter is not silently removed. Prefix `@Struct` still obtains an address. To address a field, write `@D\field` or `(@D\field)`; bare `@(D\field)` now has ordinary compact-declaration reading, not an address exception.

`sys\typeof` of an int variable containing a type code reports int. A TYPE-role consumer reads that code from the payload. For `uninit:T`, normalization reads its type information without reading absent value bytes. Every uninitialized array or pointer has zero payload bytes; it is neither an empty descriptor nor a null pointer.

### Interning, admission, and layout

The common type context interns full derived requirements. Length and capacity are properties of values, not distinct array types. Attach must preserve existing record codes and addresses and retain their type metadata. Within contexts whose arena chunks can be attached without recoding, the same code cannot designate incompatible types. Restoration from an independent context resolves the complete type descriptions under the existing rules; accidental numeric equality does not establish type identity.

The directed relation is:

```text
A[] satisfies B[]  iff  A satisfies B
```

The common kernel maintains a table of completed checked type pairs, with their direction, complete requirements, and applicable conversion context. A repeated check of the same stable pair reuses its completed result, including between calls when the requirements and context remain applicable. An in-progress recursive comparison is not a proven success. Mutable value-dependent tests, concrete field maps, bounds, lifetime, and access rights are still checked where required. This table is type metadata, not a second executable graph or a persistent snapshot of namespaces.

Successful admission does not change actual storage. An admitted Array<A> is read with A's actual layout and stride; a store must be valid for its actual element requirement. Checking types does not execute a user converter. Empty arrays follow the same type relation as nonempty arrays.

<a id="expressions"></a>
## 2. One Expression mechanism

`::`, the existing `signatureTypes` and `record` operand implementations, postfix type construction, and the five pattern words all use the established Expression mechanism. Constant `PASS_ARGS_AS_IS` and `PRIORITY`, ordinary left/right preparation, dependency-demand evaluation, and normal receiver discovery are retained. There is no second operand ABI or regex parser.

The sole conditional opening rule remains exactly this: **left is a written anonymous Structure; right has exactly one argument; that argument is also a written anonymous Structure. Only one outer level of the right argument is opened. Left stays intact.** It is neither recursive nor a P0 transformation. Named references, returned arrays, and nested values do not open merely because they are arrays. Ordinary callable W/E selection remains a separate contract.

`map`, `apply`, `partial`, `compose`, `pipe`, sequence mutations, and text searches retain ordinary receiver contracts. Treating every callable as an infix operand would change its ABI, omission rules, or named-argument roles. No such blanket conversion or new pipe syntax is introduced. Reuse occurs in their implementation and in existing operand templates, rather than by giving one name two incompatible entries.

Array arithmetic keeps its existing operand names: `*` is elementwise multiplication; `concat` joins sequences; `matmul` is matrix multiplication. Two array inputs must have equal lengths. Array/scalar operations evaluate the scalar once and preserve operand order. When every sequence input is dense, including array/scalar and scalar/array, the operation returns dense R if the scalar contract already establishes one complete result requirement R; otherwise, or with a Structure input, they return a reference-array. They do not execute a probe element to guess a type. Each elementwise comparison produces the scalar predicate result, normally int 0/1; the result array follows the same representation rule. Empty inputs have the selected representation without callback execution. Length and byte-size arithmetic must not overflow. No truncation, singleton broadcasting, implicit float promotion, or inferred multidimensional shape is added.

<a id="sequences"></a>
## 3. Universal sequence operations

A universal `@` points directly to a `{type value}` record. A sequence operation inspects the actual array type. For Structure/@[], reading a slot obtains its stored record reference; for a dense T[], reading obtains T through typed access. Preparing an addressable primitive actual, if necessary, uses the ordinary call/value machinery and a sufficient lifetime. It does not require boxing the whole source or inserting a user-visible `{value: ...}` wrapper.

Every array has variable length and the existing `parent/length/storage` descriptor. Capacity remains in its existing separate table. New selection results have a new outer container; shared referenced targets and their actual parents remain shared. Dense selection copies values. A selection is not a writable view and does not infer a rectangular shape.

| Receivers | Contract |
| --- | --- |
| `map(items; transform)` | One ordinary callback per item; reference-array of result records |
| `filter(items; accepts)` | Stable selection preserving the actual element storage profile |
| `foldl(items; seed; step)` | Left fold; empty source returns seed |
| `scanl(items; seed; step)` | Seed followed by all accumulated result records |
| `zip(first; second)` / `zipWith(first; second; combine)` | Pair/combine up to the shorter length; unlike equal-length array arithmetic |
| `traverse`, `flatMap`, `list`, `groupBy`, `transpose` | Existing container meaning, now accepting dense and reference sources through shared access |
| `select`, `omit`, `reorder` | Physical indices; selection preserves storage profile; reorder requires a full permutation |
| `project` | Selection followed by one shared graph copy/map |
| `range(start; stop; step := 1)` | Dense int array, stop excluded; zero step and overflow are errors |
| `slice(source; begin; end)` | Validated half-open interval; use select with range for a step, without negative-index inference |
| `reverse(source)` | New container in reverse physical order |
| `concat(parts)` | Same dense T when all parts have the same dense T; otherwise a reference-array |
| `compress(source; mask)` | Same-length int truth mask, stable selection |
| `any`, `all`, `index`, `count` | Ordinary predicate calls in order; early stop where specified; index returns Maybe of an int index, none() when absent |
| `replaceRange`, `append`, `insert`, `deleteAt` | Explicit mutation, same target descriptor returned |
| `splice(target; begin; end; values)` | Same interval mutation, fresh removed-elements snapshot preserving the target's actual element type and storage profile |

Exact bounds, defaults, empty cases, and failure names are defined in the [sequence specification](../LMX_Sequence_Operations.ru.md#new) and the [implementation contract](patterns/LMX_Fn_Receivers/SEQUENCES_IMPLEMENTATION.md). Public names are direct kernel receivers. There is no `toArray` conversion family and no separate user collection kind.

Callbacks receive one explicit actual for map/filter/query and two for fold/scan/zipWith. This counts supplied actuals, not the total arity of a permissible target: ordinary optional inputs, full types, private/required rules, and declared exits remain applicable. Nested Structures and returned callables are single values and are not implicitly called. Omission is not a zero, nil, empty array, or uninit record. Effects occur left to right in one Message; callbacks must not alter the traversed sequence's membership or length. Failure stops further callbacks and does not return a partial success.

### Mutation and graph editing

`replaceRange(target; begin; end; values)` replaces the half-open interval `[begin,end)` with the immediate pre-write insertion values and returns the **same target descriptor**. The new `splice(target; begin; end; values)` performs that same mutation but returns a **fresh outer container of the removed pre-write elements**. These are separate ordinary receiver names. See the [naming contract differences](NAMING_2026-11-22.md#1-sequences-and-mutation).

Both entrances first validate bounds, resulting size, source kind, and all dense-target admissions. Overlapping insertion values and the removed interval needed by `splice` are stabilized before the first write or resize that could change them. Thus appending A to itself duplicates its original elements once. Commit runs no user converter or callback. Range/type errors leave target unchanged; already evaluated actual effects and resource failures do not acquire general transactional rollback.

The removed result preserves the actual element requirement and storage profile of target. Dense T[] yields a new dense T[]; Structure/@[] yields a new @[] holding the original record references. This is a shallow snapshot: referenced nodes retain identity and actual lexical parents. Replacing an outer result slot does not replace a target slot; mutation of a shared referenced object remains shared. With `begin == end`, the result is an initialized empty container of that same profile. Removing the whole interval returns all original elements while leaving the original target descriptor in place. `replaceRange` need not allocate an unused removed-result snapshot.

`append`, `insert`, and `deleteAt` delegate to the same mutation algorithm and return target. `insert` accepts a sequence of inserted values; `deleteAt` takes an explicit half-open interval. Structure slots accept direct references without inheriting a removed field's former requirement. Dense slots retain their actual type. An L3 element reference retains descriptor plus index, so insertion changes the content at that position; it does not track a moved logical item. A separately retained record reference still designates that record. L2 raw addresses are not repaired after storage moves. The unrelated selection operation `compress` continues to require equal source/mask lengths.

Code is the same editable graph. These operations can inspect or edit its immediate fields without executing stored forms. Runtime edits and subsequent interpretation require neither text roundtrips nor compile/endturn. Explicit native compilation and turn-boundary installation retain their existing independent rules; writing a graph does not discover reverse dependencies or rewrite old native callers.

<a id="patterns"></a>
## 4. Text patterns as ordinary values

A Pattern is an ordinary structural requirement and value with matching behavior. Text in a pattern-accepting argument is literal text, with no regex-string parser. The implementation represents candidate search and captures with ordinary LMX structures and callables; it introduces neither regex bytecode nor a second working graph.

| Expression | Operation | Priority |
| --- | --- | --- |
| `P times n`, `P atLeast n`, `P atMost n`, `(P optional)` | Exact, lower-bounded, upper-bounded, or 0..1 repetition | Existing multiplication priority |
| `P then Q` | Ordered adjacent sequence | Existing addition priority |
| `P \| Q` | Ordered alternative with backtracking | Existing bitwise-or priority |

Priority values come from ordinary `sys\priority`. Repetition and then groups process left to right. The word operands declare private left/right places; missing left remains absent and a postfix occurrence supplies an empty right vector. A Pattern branch is added to existing `|` only when at least one logical argument is already a Pattern. Otherwise all old numeric/array behavior and existing binding rules remain unchanged. Remaining Pattern-branch arguments must be Pattern or literal text. `|=` follows the common single-evaluation compound assignment rule.

`then` and Pattern `|` take at least two logical arguments; prefix forms can provide more. `times/atLeast/atMost` take one pattern and a count; `optional` takes one pattern. Operand arity is checked after ordinary grouping, never used to consume neighboring source retroactively. For two composite groups, write `(then (P | Q) (R | S))`; there is no left argument and no accidental right-only opening. Ordinary `then(P Q)` is not a promise of a different receiver ABI.

| API group | Direct names |
| --- | --- |
| Primitive builders | `literal`, `oneOf`, `noneOf`, `charRange`, `satisfy` |
| Composition | `sequence`, `choice`, `repeated`, `atomic` |
| Captures/context | `capture`, `sameAs`, `ahead`, `notAhead`, `behind`, `notBehind`, `boundaryOf` |
| Ready patterns | `emptyPattern`, `neverPattern`, `anyChar`, `lineChar`, `lineBreak`, `asciiDigit`, `asciiLetter`, `asciiWord`, `asciiSpace`, `textStart`, `textEnd`, `lineStart`, `lineEnd`, `wordBoundary` |
| Repetition values | `extendFirst`, `stopFirst`, `unbounded` |
| Text views | `utf8Text`, `byteText` |
| Matching/search | `matchAt`, `wholeMatch`, `find`, `eachMatch`, `contains`, `matches`, `hasPrefix`, `hasSuffix` |
| Result access | `matchedSpan`, `matchedText`, `captureSpans`, `lastCapture`, `captureText`, `captureTexts` |
| Text production | `replaceFirst`, `replace`, `split` |

`sequence/choice` accept any suitable array through @, including Pattern[] and Structure, without converting its kind. Empty sequence succeeds with zero consumption; empty choice never succeeds. `repeated` defaults to minimum 0, maximum `unbounded`, order `extendFirst`. Bounds are nonnegative and finite maximum is at least minimum. `unbounded` is a distinct ordinary setting value, not a negative counter. `stopFirst` tries shorter candidates first. Existing `some`, `none`, `repeat`, `lazy`, `record`, `guard`, and `match` retain their meanings. In particular, `lazy` remains a first-success-caching nullary callable wrapper.

### Whole-source and boundary predicates

All these operations accept a Pattern or literal text in their pattern argument. Literal text is not parsed as regex syntax. Source positions use the chosen TextView's existing units and valid boundaries.

| Receiver | Result | Accepted match |
| --- | --- | --- |
| `wholeMatch(source; pattern)` | Maybe of Match | Begins at 0 and ends at source end |
| `matches(source; pattern)` | int 1/0 | The same whole-source condition |
| `hasPrefix(source; pattern)` | int 1/0 | Begins at 0; may end before source end |
| `hasSuffix(source; pattern)` | int 1/0 | Begins at any valid position and ends at source end |
| `contains(source; pattern)` | int 1/0 | May begin and end anywhere |

`hasSuffix` considers candidates at every relevant valid start, including overlapping starts and later alternatives at the same start. It cannot be defined as checking the last nonoverlapping `find`/`eachMatch` result. For source `ab`, pattern `literal("a") | "ab"` succeeds as a suffix: rejection of the earlier incomplete candidate must allow the later complete candidate. For `ababa` and literal `aba`, the candidate starting at 2 succeeds even though a nonoverlapping enumeration may have selected the match at 0. This does not undo a Pattern's explicit `atomic` restriction.

An empty Pattern is a valid prefix at 0 and suffix at the end; the same boundary rules apply to an empty source. `wholeMatch`/`matches` still require complete coverage. Anchors and lookaround see the original whole-source context: suffix testing does not reverse text or match a sliced substitute. A matching error propagates as an error, never false. Existing predicate termination and effect requirements remain unchanged.

### Candidate ordering, captures, and zero progress

Sequence explores continuation after each earlier candidate, backtracking when needed. `matchAt` selects the first candidate at its start; `wholeMatch` may reject an earlier incomplete candidate and accept a later complete one. `atomic(P)` retains only the first local success of P, without suppressing alternatives outside P.

Repeating an empty match can fulfill the finite minimum, but further zero-progress extension stops. Each capture belongs to its successful branch; failed attempts discard their capture changes. Repeated names keep history. Missing capture and present zero-length capture differ. `sameAs` uses the preceding captured text; its behavior is the explicitly extended, not purely regular, profile. Lookaround restores both outer cursor and capture journal; a matching error is never interpreted as negative-lookaround success.

`eachMatch` distinguishes a zero-length candidate from a nonempty candidate at the same start and does not skip the latter. It advances through valid text positions and terminates, including at end of input. `emptyPattern` on `ab` yields positions 0, 1, 2; replacement with `-` yields `-a-b-`; splitting yields four parts including the two empty ends. Each returned Match keeps its own stable ranges and capture history. Replacement callbacks run once per selected match, and inserted text is not searched again. `replace(source; pattern; replacement)` returns newly produced text without mutating source; `replaceFirst` keeps its one-match limit. These text operations are independent of sequence `replaceRange` and `splice`.

`matchedSpan` returns a Span retaining source and `[begin,end)`. `matchedText` explicitly copies the matched text. `captureSpans` and `captureTexts` preserve all captures of a name; `lastCapture` and `captureText` return Maybe and distinguish absence from a present empty capture. Span retains the TextView, not a pointer into movable backing. Materializing accessors copy text; ranges themselves do not promise a source snapshot.

### Text profiles, effects, and lifetime

Search takes an explicit TextView. `utf8Text` counts Unicode scalar values, not bytes or grapheme clusters, and rejects malformed UTF-8 under the specified validation policy. `byteText` counts bytes and validates its substrate through the actual char layout. No locale, normalization, or case folding is implicit. ASCII classes are fixed; `lineBreak` treats CRLF as one logical separator and does not also match its LF independently.

Predicate callbacks used during candidate exploration must terminate and have no externally visible writes on which backtracking relies. The matcher modifies only its own attempt state. Builder arguments are evaluated once at construction, even for a subsequent repetition count of zero; matching is deferred. Replacement effects occur after selecting a match. Declared/system errors remain errors, not mismatch, false, None, or retry.

The public TextView retains the original source descriptor and explicit profile, not a cached units/offset index. Each public search, replacement or split operation prepares current units and offsets once; an `eachMatch` iterator retains that prepared context through suspension and completion. `Match.source` and `Span.source` preserve the original TextView identity, while their private prepared context retains the index for the operation that produced them. New operations never overwrite an earlier result's prepared index.

The source must remain alive and unchanged during an operation, suspended iteration, and access to source-backed results. After completing those uses, the caller may mutate the source and reuse the same TextView in a new operation. That operation reads the current bytes, rebuilds scalar boundaries and validates the current encoding. This does not add a lifetime-wide immutability requirement, a source snapshot, or mutation detection during an active operation.

<a id="adapters"></a>
## 5. Callable adapters and exact signatures

The uploaded semantics' [adapter contract](LMX_semantics.en.md#adapter-observations) is retained. Type identity remains ordered input requirements plus result requirement; labels, defaults, private/required policies, and declared exits are additional call behavior, not invented type components. Named `Name :: DATA` and the type-token form remain interchangeable except for the specified existing relationship between named signatures and `call`.

Adapter construction must retain the source declaration policy and a positional projection. A prepared call represents actual presence and deferred places. Generated CODE must not eagerly read every `p0…pn` before entering its engine. Omitted source inputs retain their own computed defaults and context; captured prefixes are available to defaults that depend on them. Service fields remain private. Calling a wrapper adds its documented call boundary; there is no promise of a hidden alias through every intervening frame.

`once` hits do not force unused omitted defaults. Passive trace events can describe present/deferred states without evaluating them. `guard/contract` read only the places their predicate/body needs. Memoization documents which accepted values its key observes, distinguishes omission from zero/nil, and does not cache failures. `uncurry` inspects the actual reached stage and performs exactly the number of calls specified by the flat contract, without fabricating intermediate `Ti -> @` signatures or calling a final callable result.

The LMX implementation keeps adapter algorithms in LMX and isolates access to the kernel's existing call-preparation phases. These bridges do not create a persistent environment, a new VM, or automatic native compilation. See [adapter implementation](patterns/LMX_Fn_Receivers/GENERIC_IMPLEMENTATION.md), [kernel boundaries](patterns/LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md), and [acceptance](patterns/LMX_Fn_Receivers/tests/ACCEPTANCE.md).

<a id="acceptance"></a>
## 6. Acceptance and publication

The core-type scenarios, sequence scenarios, original pattern scenarios, and adapter A01–A20/B01–B11 requirements remain acceptance obligations for interpreter, native, and both transitions. Added cases cover the distinct `replaceRange`/`splice` results and both boundary predicates, including alternatives, overlap, empty boundaries, actual element profiles, and aliasing. They must be run against the actual kernel. This archive separately records source coverage, unresolved integration duties, and reproducible character counts. Neither a documentation link nor a matching source token is a runtime PASS.

Examples retain earlier algorithms from the uploaded archive. Syntax migrations apply to those algorithms too. A shorter candidate is eligible only when it preserves the complete scenario, fields, effects, failure behavior, and comparable library boundary. Where both languages use a common facility, usage and implementation costs are reported separately. Code length is not a performance measurement.
