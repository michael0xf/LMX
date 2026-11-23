# Universal sequence receivers: implementation and integration

**Date:** 2026-11-22. **Basis:** the current uploaded archive, specifically
[the sequence task](../../../LMX_Sequence_Operations.ru.md),
[the priority core-type task](../../../LMX_Array_Reference_Types_Core.ru.md),
and the existing sources in this directory. Earlier delivered archives are
not used as a source of truth.

**Status:** concrete LMX algorithms and prepared source fixtures. The source
checks described below are not an LMX parser, an execution test, or evidence
that a native implementation exists. The actual kernel must supply the four
common array-access boundaries and the ordinary postfix type machinery.

## 1. What was unified

Universal sequence parameters are `@` references to existing values. A
Structure already is the ordinary `@[]`; a dense `T[]` retains its actual
element layout. No new List/Sequence wrapper, conversion receiver, or user
requirement to call `records` before an operation is introduced.

The algorithms share one element-access path, one representation-preserving
allocation path, and ordinary callback transport. A selected Structure is one
prepared actual. Reading it neither executes it nor applies W/E again.
Callbacks receive one explicit actual in map/filter/queries and two in
foldl/scanl/zipWith. Their own additional defaults, uninitialized inputs,
required/private policies, full requirements, results, and declared exits
remain those of the selected callable.

The public collection operations remain ordinary receivers. Turning `map`,
`slice`, or `replaceRange` into additional infix aliases would add competing
forms without improving the task's named-argument examples. Existing numeric
Expression operands already express pairwise arithmetic and scalar expansion;
they reuse the same access primitives and the normal scalar type analysis.
They keep the existing operand ABI and the single conditional opening of only
the written anonymous RIGHT container. In particular, this work does not add
`S map F`, `.*`, a slice grammar, recursive flattening, or automatic opening of
returned arrays.

`index` is the sequence search receiver. It returns the existing Maybe.
It is distinct from Regex `find(source; pattern)`, whose result is a Match;
no spelling collision or new overloaded dispatcher is needed. Sequence
queries likewise do not introduce a separate `contains` alias.

`replaceRange(target; begin; end; values)` changes a sequence and returns
that target. Regex `replace(source; pattern; replacement)` keeps its own name
and returns its new text result. Both are ordinary receivers with their own
input names, complete requirements, result, and declared exits; existing
declaration selection and argument preparation apply.

The new `splice(target; begin; end; values)` performs the same sequence
replacement but returns a new container holding the removed values. It is a
distinct result contract, not an alias of the target-returning `replaceRange`.

## 2. Source organization

| File | Implemented work |
| --- | --- |
| [src/sequences_core.lmx](src/sequences_core.lmx) | Common layout inspection, one-element reads, checked allocation/growth, integer validation, record-vector construction |
| [src/collections.lmx](src/collections.lmx) | Universal map/filter/foldl/scanl/zip/zipWith/traverse/transpose/groupBy |
| [src/sequences_selection.lmx](src/sequences_selection.lmx) | Universal select/omit/reorder/project/list/flatMap |
| [src/sequences.lmx](src/sequences.lmx) | range/slice/reverse/concat/compress and four ordered queries |
| [src/sequences_mutation.lmx](src/sequences_mutation.lmx) | One replacement algorithm, removed-value splice, and append/insert/deleteAt entries |
| [examples/sequence_examples.lmx](examples/sequence_examples.lmx) | Prepared assertions and named-failure probes |

The internal names `FxSlice\slice(values; start; count)`,
`FxAppend\append(first; second)`, and string `FxConcat\concat(first; second)`
retain their existing contracts. Public `slice` takes an exclusive **end**,
public `append` mutates, and public `concat` takes **one sequence of parts**.
They are not aliases for those older helpers.

## 3. Public export map

These are direct entries of the current kernel, not a separately versioned
library. The sequence API additions have these 14 callable forms:

| Public receiver | Implementation | Main result |
| --- | --- | --- |
| `range(start; stop; step := 1)` | `FxSeqRange\range` | Dense `int[]`, exclusive stop |
| `slice(source; begin; end)` | `FxSeqSlice\slice` | New container of the source's element-storage profile |
| `reverse(source)` | `FxSeqReverse\reverse` | Same profile, reverse physical order |
| `concat(parts)` | `FxSeqConcat\concat` | Dense T only when every part is dense with the same complete T; otherwise `@[]` |
| `compress(source; mask)` | `FxSeqCompress\compress` | Same profile; zero excludes, nonzero int includes |
| `any(items; accepts)` | `FxSeqAny\any` | int 0/1, stops at first true |
| `all(items; accepts)` | `FxSeqAll\all` | int 0/1, stops at first false |
| `index(items; accepts)` | `FxSeqIndex\index` | `some(index record)` or `none()` |
| `count(items; accepts)` | `FxSeqCount\count` | Number of nonzero predicate results |
| `replaceRange(target; begin; end; values)` | `FxSeqReplaceRange\replaceRange` | The same target reference after mutation |
| `splice(target; begin; end; values)` | `FxSeqSplice\splice` | New container of the removed values, preserving their source storage profile |
| `append(target; values)` | `FxSeqAppend\append` | The same target |
| `insert(target; position; values)` | `FxSeqInsert\insert` | The same target |
| `deleteAt(target; begin; end)` | `FxSeqDeleteAt\deleteAt` | The same target |

Existing exports requiring new universal bodies are:

| Existing name | Universal implementation |
| --- | --- |
| `select` | `FxSeqSelect\select` |
| `omit` | `FxSeqOmit\omit` |
| `reorder` | `FxSeqReorder\reorder` |
| `project` | `FxSeqProject\project` |
| `list` | `FxSeqList\list` |
| `flatMap` | `FxSeqFlatMap\flatMap` |

The retained internal `RxSelect/RxOmit/RxReorder/RxProject` and
`FxList/FxListBind` paths now delegate to those bodies. Their previous procedural
implementations from the current uploaded archive are preserved under
[reference/pre_sequence_fix ](reference/pre_sequence_fix/README.md). Map, filter,
foldl, scanl, zip, zipWith, traverse, transpose,
and groupBy retain their original `Fx*` paths in `collections.lmx`.

## 4. Four precise kernel boundaries

These are shared operations over the existing type table, descriptor, storage,
admission machinery, and allocator. They implement no map, filtering,
selection, mutation-range algorithm, Regex matching, or callable adapter.
The declaration sketches below document provider interfaces; they are not
empty implementations that make the package runnable.

```lmx
FxKernelArrayInfoAPI :: (@: source; return: @)

FxKernelArrayReadAPI :: (@: source; int: index; return: @)

FxKernelArrayAdmitAPI :: (@: target; @: value; return: @)

FxKernelArrayWriteAPI :: (@: target; int: index; @: value)
```

### `FxKernel\arrayInfo(source)`

Require an initialized array/Structure under ordinary admission. Return an
ordinary metadata value with these fields:

| Field | Meaning |
| --- | --- |
| `arrayType: int` | Canonical code of the **linear** array profile with the source's complete element requirement; `@[]` for ordinary Structures |
| `elementType: int` | Canonical full element requirement, retaining nested models, callable requirements, and arbitrary pointer depth |
| `elementBits: int` | Actual physical element width from layout; Regex may use it to require an 8-bit `char` substrate |
| `dense: int` | Nonzero for dense typed storage, zero for ordinary Structure/reference storage |
| `maxLength: int` | Largest length representable by this API's index/count contract and actual storage byte-size calculation; not an estimate of free memory |

Canonical codes come from the shared type resolver, including its equivalence
handling after attach. No new type is generated for each length or capacity.
The metadata describes existing values; it does not materialize a sequence,
read a nonexistent uninit payload, or interpret an int type-id as an instance.
The linear result profile does not infer or copy external multidimensional
shape descriptions merely from length.

### `FxKernel\arrayRead(source; index)`

Check an L3 physical index and obtain exactly one ready typed value. For an
ordinary `@[]`, return its stored value reference directly. For dense T, read
with the source's actual stride and full requirement; prepare an ordinary
addressable value only when transport or lifetime requires it. An escaping
primitive must not reference a dead C local or pretend that a raw dense
payload address has a type tag before it.

Preserve reference targets, uninit state where representable, void, complete
types, and pointer depth. No `{value: @}` wrapper is imposed merely because a
value participates in iteration. Native lowering may use a direct typed load
and eliminate an unobservable temporary. No complete dense input is boxed as
a prerequisite for map/filter/foldl.

This boundary declares `ReceiverIndex`, `FxKernelFailure`, and `FxTypeToken`.
Ordinary source-kind/uninit admission and system failures retain their ordinary
channels. Reading a graph element never executes its saved form.

### `FxKernel\arrayAdmit(target; value)`

Prepare one value for the **actual** target's complete element requirement.
For `@[]`, return the direct supplied reference; do not require the former
slot's type, name, or model. For dense T, perform ordinary admissibility and
permitted built-in representation preparation. No hidden user converter or
initializer is invented. Required value checks remain part of this preparation
phase; a type-pair cache cannot replace them.

On incompatible inserted values, declare `SequenceElement`. Preserve ordinary
system/implicit failures. The returned value remains valid through the
subsequent commit. Full admission is not postponed to target writes.

### `FxKernel\arrayWrite(target; index; value)`

Store one already prepared value using the target's actual layout. The caller
has obtained the value from the same complete source profile or from
`arrayAdmit`. Perform the ordinary reached index/lifetime checks; do not run
converters, callbacks, initializers, or full admission tests again.

For `@[]`, replace the physical stored reference directly. For dense T, write
T, without treating the storage as `void**`. Descriptor identity and parent
links do not change. The boundary implements a one-slot write, not a hidden
range-replacement engine or an unchecked reinterpretation API.

`FxSeqStore\write` combines admission and writing for ordinary helper clients.
`FxSeqPush\append` prepares one element, checks size, resizes, then writes.
`replaceRange` calls the prepared write directly during commit.

## 5. Allocation, types, and overflow

`FxSeqAllocate\make(arrayType; count)` resolves an ordinary full int type code
as a declaration head, constructs its empty value with `(arrayType: [])`,
checks `maxLength`, and uses existing `sys\resize`. It introduces no allocator
or growth family. `reserve/resize/capacity` remain the common mechanism with
capacity stored outside the parent/length/storage descriptor.

All size additions check `extra <= limit - base` before calculating the sum.
Selected indices, masks, lengths, and mutation intervals are validated before
the relevant observable output or mutation. There is no clipping, negative
index convention, silent truncation, or wraparound into an admissible index.

Range uses the existing exact-integer `bigint` profile for its short preflight:
convert start/stop/step before subtraction, compute the positive distance and
step magnitude, then `(distance - 1) / stride + 1`. Conversion back to int
occurs only after the complete count fits the result's actual limit. The
materialization loop uses int and never calculates the value after the last
included element. This handles a minimum negative step and a range crossing
both signs without a fixed machine-width constant. An implementation may
replace that preflight with a proven equivalent bounded multiword calculation;
it must not replace it with overflowing native subtraction or `abs(MIN_INT)`.

Postfix types use the shared interner: `T[]`, `T@`, and arbitrary finite depths
are not privately implemented by collections. `[]: pending` remains any-array
uninit, distinct from `@[]: pending` and from an initialized empty array.
Array compatibility follows `A[] satisfies B[] iff A satisfies B`; this does
not change the actual source stride or permit writing B bytes into A storage.

## 6. Result and effect contracts

| Family | Storage/result behavior |
| --- | --- |
| map/scanl/zip/zipWith/flatMap/list | New ordinary `@[]`; arbitrary result types retained |
| filter/slice/reverse/select/compress/omit/reorder | New outer container preserving the source's physical element profile |
| foldl | Last accumulator reference; empty input returns the original seed |
| scanl | Seed followed by every returned state; no automatic deep snapshots |
| zip/zipWith | Stop at the shorter input; zip pairs retain `first` and `second` fields |
| transpose | First validate equal row lengths; result columns are ordinary `@[]` |
| traverse | Existing Maybe; stop at first none; success contains `@[]` |
| groupBy | Stable groups with key/items; one keyOf call per element and explicit sameKey |
| project | Select followed by one ordinary copy operation and one shared copy map |
| concat | Same complete dense T in all parts gives dense T; all other valid combinations give `@[]` |
| replaceRange/append/insert/deleteAt | Mutate the existing target and return that same target |
| splice | Mutate the existing target and return a new outer container of the values removed from its pre-write `[begin,end)` |

The container's slots are independent of the source's slots. Shared referenced
targets remain shared. Selecting an uninitialized record does not read its
absent payload. Char operations use physical char elements and exact length;
they neither stop at NUL nor claim Unicode scalar slicing.

Callbacks run left to right in one Message. They may change other objects but
must not change the iterated sequence's stored elements or length. No deep
snapshot, parallel execution, or hidden lazy pipeline is introduced.

All four new queries validate the callback's actual returned record as int
before using its payload. Invalid results declare `FxPredicate`. Existing
filter retains ordinary int-result admission instead. The generic callback
path preserves `FxCallFailure` with the original declared name and payload;
implicit/system failures are not converted to false, none, or success.

## 7. Mutation algorithm and identity

`replaceRange` first validates `[begin,end)`, the source sequence, the new
length, and all inserted values. It stages exactly the inserted values in a
temporary container of the target's actual profile. This conservative path is
safe even when values is target or overlaps its storage. It does not deep-copy
targets, owners, code, or dynamic environments.

After successful preparation, it reserves capacity. A growth moves the tail
backwards after resize; shrink/equal length moves it forwards before final
resize. It then writes the staged insertion. Append, insert, and deleteAt call
this same algorithm; their alias/type semantics are not reimplemented and
they do not allocate a result containing removed values.

For these target-returning operations, the target descriptor and returned
reference are identical to the original.
L3 element references keep descriptor plus numeric index; they do not follow a
logical old element after insertion. Raw L2 addresses receive no automatic
repair. Existing value references continue to designate their targets within
ordinary lifetime rules. Parent is not rewritten by moving references.

Bounds/type errors precede mutation. Resource failures remain system failures;
there is no promised rollback of arbitrary earlier effects or a general
transaction. A production implementation may avoid the staging allocation
when nonoverlap is established and all promised checks can still precede the
first write.

### Splice: return the removed values

`splice(target; begin; end; values)` requires the same four inputs and uses
the same zero-based half-open interval. It first calls
`FxSeqSlice\slice(target; begin; end)` and retains that new container. Only
then does it call `FxSeqReplaceRange\replaceRange`; after successful replacement it
returns the retained container. There is one mutation algorithm, so splice
does not independently reimplement admission, capacity, tail movement, or
overlap handling.

The removed values are read before reserve, resize, or any target write. A
dense `T[]` yields a dense result with the same complete element requirement,
including `char`, pointer types, and nested requirements. A Structure yields
ordinary `@[]` with the original direct value references. Neither path is
limited to integers, boxes a complete dense source, nor copies the referenced
object graph. Result slots are independent; referenced objects remain shared.
The new container does not retain an index view into the changing target.

An empty interval returns an empty container with the target's original
storage profile while inserting the supplied values. Empty `values` deletes
the interval and returns its old contents. Replacing the whole target with an
empty sequence returns all its old values and leaves that same target empty.
When `values` is `target` or overlaps its storage, both the removed result and
inserted values reflect the target before the first write.

Bounds failures occur while preparing the removed snapshot; inserted-value,
source-kind, and new-size failures occur on the common replacement path.
These preparation failures leave the target's content and length unchanged;
no successful result is returned. Allocator/system failures retain the
existing system contract rather than acquiring arbitrary-effect rollback.

## 8. Efficiency decisions

Selection and mapping use one final allocation where the maximum output size
is known. Filter allocates up to the source count and shrinks. Query loops
allocate no result sequence and stop immediately when decided. Groupby does
not invent a hash/equality contract: the supplied comparator determines key
equality, so its general implementation is O(n times number of groups).

Select is O(k). Omit and reorder use a checked dense index/flag buffer for
O(n+k) and O(n) work instead of repeated quadratic searches. Concat performs
O(number of parts + total elements) logical work without deep copies or
rebuilding a growing prefix after every part. Flatmap grows one output rather
than repeatedly copying the entire prefix. Actual allocation movement follows
the existing capacity policy.

The reference replacement algorithm copies O(inserted values + moved tail),
with temporary storage only for inserted values. Splice additionally copies
O(removed values) into its required result before mutation; this cost is not
paid by replaceRange, append, insert, or deleteAt. A kernel can lower dense moves to
typed bulk copies when the same identity, initialization, lifetime, and overlap
contract is retained. None of these optimizations require another program
graph or erasing Ti/R to @.

## 9. Prepared verification and remaining kernel work

`FxSequenceExamples\run()` calls the numeric/default, query-order, mutation,
splice, bad-mask, bad-insertion, and zero-step probes. The source includes assertions
for every new ordinary receiver, dense/reference mixing, representation
preservation, source independence, self-append, overlapping replacement,
Maybe index zero, min-length zip, seed scanl, stable grouping, transpose, and
one-copy project sharing.

The new splice probes cover its removed-value return independently of target
content, fresh result slots, same target descriptor, dense int/char profiles,
dense typed references `int@[]`, direct Structure references, reference sharing,
self-overlap for dense and reference inputs, empty/full ranges, and failure
before target mutation. Invalid insertion is tested with a valid first value
followed by an incompatible value; invalid bounds cover a negative beginning,
a reversed interval, and an end beyond the target. These are prepared runtime
assertions with status **NOT_RUN**, not a claim that the LMX runtime passed.
The probes establish shared-container behavior by writing through retained
aliases and reading the original container. They establish independent result
slots by modifying one container and checking the other. Referenced-object
sharing is checked by changing the referent and observing that change through
the retained result. They do not assume that elementwise array `=` is a scalar
reference-identity test.

`FxSeqProbeRangeBoundary\run(maxInt)` additionally requires the real maximum
from the target numeric profile. The complete task matrices remain normative:
82 sequence cases and 58 core cases, including parent/lifetime, uninit,
pointer depth, malformed types, graph code selection, and four interpreter/
native combinations. The prepared probes do not replace those matrices.

Limited source checks performed on the five implementation files, two retained
delegate files, and the fixture file found no unbalanced quoted literals/round
or square delimiters, non-four-space indentation, multi-level dedent lacking
an explicit cutter, or unresolved qualified root names. The fixture source
contains 82 prepared assertions.
They do not establish name resolution, admission, callback demand, lifetime,
array initialization, or native ABI correctness.

[SEQUENCES_SOURCE_REPORT.json](tests/SEQUENCES_SOURCE_REPORT.json) records
**PASS** for the bounded source checks and **NOT_RUN** for LMX execution. The
current revision also checked 2,640 replacement/overlap cases and 2,640
removed-result splice cases using Python models against independent slice
concatenation. Those cases cover integer values and referenced objects,
including self-insertion, every valid interval for the selected small input
lengths, independent removed-result slots, and retained referent sharing.
The earlier report of 8,750 range cases is retained explicitly as prior work;
the unaffected range algorithm was not rerun for this mutation revision.
These models check move ordering and snapshot semantics; they do not execute
LMX or prove that a kernel implements the documented bridge semantics.

The actual kernel repository is not included in this documentation archive.
Its remaining work is concrete: implement the shared parser/type/head changes;
provide the four common array boundaries above; integrate exact callback
transport and its defaults; apply the scalar-expansion profile in the existing
numeric operand dispatcher; run the prepared fixtures against real kernels.
No scalar operator implementation is concealed inside these new receivers,
and no runtime PASS is claimed for that integration.
