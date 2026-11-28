# Conditional expressions and sequence slices

Revision 27 November 2026. This is the current conditional/slice contract of the common Expression grammar and [tensor specification](TENSOR_EXPRESSIONS.md). The [executable reference model](tools/ternary_slices_reference.py) checks normalization and consumption contracts separately from the production LMX parser, translator and runtime; those production executions remain **NOT_RUN**.

<a id="conditional"></a>
## 1. Conditional expression `condition ? yes : no`

`?:` is the canonical name of one conditional operation. Its expression spelling is `condition ? yes : no`; its receiver spelling is `` `?:`(condition; yes; no) ``. Both use one selection body and the existing transport of RAW occurrences with their live source context. The receiver is not an eager function call with three already computed arguments.

Obtain the condition exactly once under the same int truth contract as `if`: zero is false and nonzero is true. Obtain only the selected arm, exactly once. The other arm performs no calls, assignments or dynamic exits. Structural checks and available static contract checks on both arms do not execute them. The method's declared `throws` accounts for possible exits from the condition and either arm; lazy execution does not erase the static exit contract.

The result is the selected arm's whole ordinary value, preserving reference identity and lifetime. An Array is neither spread nor copied and does not become a truth mask. The receiving requirement admits the actual result normally; differing arm types do not silently become int or double.

Precedence is below `||` and above `:=`, `.:` and `::`, with right association. `sys\priority("?:")` is ready on the same common scale; no second numerical scale is introduced. P0 preserves conditional separators and enclosing structural context. The common grouper and ordinary application preparation determine the final RAW arm boundaries, retaining LeftView, at most one left atom and value-demand dependencies. Simply cutting at every weaker operand is insufficient: the policy used for `1 + v := 2 + 3` still applies. The assignment example below explicitly bounds each arm; no unverified reading of its ungrouped shorthand is established. Assignment keeps its ordinary place contract without an exception for `:=`.

```lmx
return: count > 0 ? total / count : 0
return: flag ? first : second ? other : fallback
return: flag ? (x := first) : (x := second)
return: `?:`(flag; first; second)
```

The second example is `flag ? first : (second ? other : fallback)`. The third executes one selected assignment. The operand has one left condition occurrence and two right RAW arm occurrences. The common public header has `left`, optional actual `depth`, `right`, followed by constant `PASS_ARGS_AS_IS` and `PRIORITY`; the conditional adds no form-specific field. Its ordinary application leaves depth absent and retains RAW mode 1. An explicit depth expression is obtained only on demand; a skipped arm cannot cause its effects. Absence of depth is not globally replaced by 0. See [depth](OPERATOR_DEPTH.en.md). A missing-left application remains a distinct actual vector, interpreted only by the method. The receiver adapter supplies the same three roles to the shared body.

<a id="colon-contexts"></a>
## 2. Colon contexts and graph boundaries

P0 preserves written occurrences and pairs delimiters by structural nesting, without resolving names or obtaining values. A colon that closes a pending question at the same level does not create a `yes:` Frame. Nested bounded forms and already formed Frames have their own level. Pair a colon with the nearest unmatched question at its level; nested conditionals in either arm remain unambiguous.

| Spelling | Role |
| --- | --- |
| `print: value` | Ordinary head/body delimiter |
| `Name :: int -> int` | One signature operand token `::` |
| `flag ? first : second` | Arm delimiter of the conditional operation |
| `a[start:stop:step]` | Up to two slice field separators |
| `a[::2]` | Two slice separators with omitted start/stop |
| `a[(flag ? 1 : 2):6]` | Nested conditional and an outer slice separator |
| `a[flag ? 1 : 2:6]` | The first colon belongs to `?`; the second separates slice fields |
| `flag ? (a := b) : c` | `:=` is one assignment token, not an arm delimiter |

At the current level of an index suffix, `::` supplies two slice separators, not a signature token. A nested group has its ordinary context, including `::`. Outside an index suffix the signature token is unchanged. Strings and exact identifiers still shield their contents. Longest-token recognition preserves `.:`, `:=` and other compound operator tokens before structural single-colon handling. Ordinary `=` is elementwise comparison; a generic dotted `.=` form is not introduced. `.:` has the separate slice-broadcast assignment contract below.

A short colon receiver inside an arm must be bounded, as in `flag ? (f: x) : (g: y)`, or written compactly as `flag ? f(x) : g(y)`. Otherwise a colon at that level already closes the conditional arm. Unmatched questions, absent arms and surplus delimiters fail preparation before effects. P0 handles source punctuation. The Expression grouper receives graph boundaries and source references, never searches for textual parentheses, and accepts equivalent graph-created applications.

<a id="slice-contract"></a>
## 3. `[start:stop:step]`

The [square-form subparser](BRACKET_SUBPARSER.en.md) is a delegated part of the common parser, entered at `[`. It owns only the current square form's separators and `]`. Every bound expression, nested group, string and `{...}` region is parsed by the common parser, which returns `nextPosition`; the helper never scans for a nested `}`. In particular, the common parser consumes a ternary's colon before exposing an outer slice colon. Full expressions are admitted in every present field; syntax success does not replace integer admission.

An attached index suffix containing one or two slice separators selects a slice. Any field can be explicitly absent. Absence is distinct from zero, -1, null, an empty Structure, or a request for dynamic autofill.

The default step is 1. Positive steps select indexes below stop; negative steps select indexes above stop. Stop is excluded. An explicit negative bound counts from the end and is then clipped to the allowed boundary interval. A zero step fails with `SequenceStep`.

| Direction | Default start | Default stop | Clipping interval for explicit bounds |
| --- | --- | --- | --- |
| Positive step | 0 | length | 0 through length |
| Negative step | length − 1 | −1 as the excluded boundary | −1 through length − 1 |

An omitted negative-step stop differs from explicit -1: `a[::-1]` reverses all elements; `a[:-1:-1]` is empty. Empty sources, equal normalized bounds and a step directed away from stop produce an empty result. Bounds and counts use exact arithmetic; neither signed-to-unsigned wrapping nor intermediate overflow is allowed. Validate result size and allocation limits before construction.

Obtain the source once, then each present start, stop and step once in written order. Read its actual length/storage after those bound effects. A backing pointer captured before a bound expression may not be reused after an intervening resize. Source identity, element requirements, read admission and lifetime follow the ordinary contracts.

<a id="slice-values"></a>
## 4. Values, destinations and ranks

As a VALUE, a slice is a new outer container with the source's actual storage profile. Dense elements retain their type; reference elements retain their existing targets and parents. There is no deep copying or reparenting. Slice `[]char` in its element units without implicit Unicode decoding. The result is an ordinary Array, not a new hidden view kind or persistent execution representation.

In PLACE, the same index selection denotes real places in the source Array. Ordinary `:=` assigns corresponding elements: an Array RHS requires exactly the destination shape; a scalar RHS can fill the selected places. A one-element Array is not a scalar. `.:` is a separate **slice assignment with broadcasting** to the fixed destination shape, not an alias for `:=` with depth=1.

```lmx
(a b c) := (b c a)
values[1:5:2] := (8 9)
values[::-1] := values
values[:] := 0
```

Structure is Array `[]@`, so the first example uses ordinary elementwise assignment under the actual place/value types. Preserve all required RHS values before stores, validate count/shape and store admission, then write. Overlapping selections read the pre-write values. Destination length and shape do not change, and effects of obtaining RHS do not silently retarget a stale selection. Existing const/immutable, lifetime and access contracts remain in force. Resizing requires an explicit operation such as `replaceRange` or `splice` under its own contract.

For `.:`, align Array RHS axes on the right of the selected destination shape. RHS rank cannot exceed destination rank. Each matched RHS extent must equal the destination extent or be 1; absent leading RHS axes and extent-1 axes repeat. A scalar fills the slice. The destination never grows. Extent 1 may map to a zero target extent; extent 0 may map only to extent 0. An empty target causes no element writes or element reads for stores; obtaining demanded actuals retains ordinary effects.

```lmx
[2][3]int: matrix [0 0 0; 0 0 0]
[3]int: row [10 20 30]
[2][1]int: column [100; 200]

matrix[:][:] .: row
# [10 20 30; 10 20 30]

matrix[:][:] .: column
# [100 100 100; 200 200 200]

matrix[:][:] := row    # error: exact shapes (2,3) and (3) differ
matrix[:][:] .: [1 2]  # error: last extent 2 does not match 3 or 1
values[:] .: values[0:1] # overlapping RHS is stabilized before writing
```

Ordinary assignment and broadcast assignment share one store traversal with different coordinate maps. Broadcasting does not re-evaluate RHS once per output element and does not require an expanded RHS buffer. Unsupported shape/rank or write-access contracts are translator/interpreter diagnostics under [the assignment contract](TENSOR_EXPRESSIONS.md#assignment-contract).

A single `array[start:stop:step]` suffix selects the flat sequence by total
length at any rank. The new flat selection has one axis; source rank/extents
remain unchanged. An adjacent suffix chain containing slices selects retained
axes: a scalar removes its axis, a slice retains its selected extent, and
unmentioned remaining axes stay whole. `matrix[1:3][::-1]` selects rows 1 and 2
and reverses columns; `matrix[i][:]` explicitly selects a row. Single `matrix[i]`
is a flat element, not an implicit row Array. Use actual extents/strides, never
first-element inference. `struct[i]\[j]` is the ordinary Structure path
corresponding to `struct\struct2\field` when i and j select those fields;
`struct[i]\[j]\[k]` corresponds to `struct\struct2\field[k]`.
There is no separate nested-container mechanism. `s\[N]field` retains its
named-occurrence meaning. [Storage contract](ARRAY_STORAGE.en.md#indexing).

A complete scalar-only coordinate chain preserves its existing contract:
row-major linearization followed by final-element validation against length,
without new per-coordinate upper-bound checks. At extents `[2,3]`,
`a[0][3]` and `a[1][0]` both give k=3. Normalizing selected slice axes is
a separate receiving contract and does not replace that scalar policy.

<a id="slice-receiver"></a>
## 5. One `slice` name, explicit profiles

The suffix uses `slice(source; spec)`, where spec is an ordinary Structure with independently present start/stop/step. An explicitly supplied description is not completed from similarly named caller variables. Presence is the ordinary presence of the explicitly supplied field; a missing field has no payload to read. No new mandatory presence flags or dynamic fallback are introduced. This is an operation argument description, not a second program graph.

Both roles of `slice(source; spec)` are **VALUE/VALUE**: spec is a ready
Structure value, not a DATA declaration. The suffix retains RAW source/bound
occurrences only until ordinary argument obtaining supplies their values.

Existing `slice(source; begin; end)` retains its strict profile: `0 <= begin <= end <= length`, no clipping and no from-end negative bounds; invalid input fails with `ReceiverIndex`. Both profiles share the same selected-index traversal and result construction. Only their explicit plan-validation policy differs. These are overloads of one canonical name, not aliases or duplicated selection algorithms.

Normalization produces start, stop, step and count. A nonempty positive-step count is `1 + (stop - start - 1) div step`; the negative-step equivalent is `1 + (start - stop - 1) div (-step)`. Check the empty case first. Traverse exactly count indexes and do not compute a next index after the final selected element.

<a id="negative-index"></a>
## 6. Negative scalar indexes and L2

A valid scalar Array index is an integer within the allowed bounds, beginning at zero. `values[-1]` is not last-element access and is invalid. Diagnose a known negative index during preparation; reached computed indexes are checked by L3 and by interpreted execution of **both** L2 and L3. A minus expression itself is not forbidden: `values[-offset]` can produce a valid nonnegative index.

Native L2 adds no automatic bounds check. This does not make an invalid index valid and does not introduce from-end indexing. When an operation needs a backward offset from an existing address, express it through a pointer under the ordinary address contract:

```lmx
L2:
    []int: values [10 20 30]
    @int: p @values[1]
    int: previous \(p - 1)
```

`p - 1` reaches the preceding element within the same valid backing; it is not `values[-1]`. This distinction also matters because interpreted L2 still checks Array bounds. A pointer grants no permission to leave the allocation or violate alignment, lifetime or protection.

Negative slice bounds have their explicit separate meaning: `values[-1:]` returns a one-element Array containing the last value; `values[:-2]` omits the last two values; `values[-4:-1]` selects the indicated half-open range.

<a id="examples"></a>
## 7. Required examples and verification

For `[]int: nums [0 1 2 3 4 5 6]`:

| Expression | Result |
| --- | --- |
| `nums[::2]` | `[0 2 4 6]` |
| `nums[1:6:2]` | `[1 3 5]` |
| `nums[::-1]` | `[6 5 4 3 2 1 0]` |
| `nums[-3:]` | `[4 5 6]` |
| `nums[:-2]` | `[0 1 2 3 4]` |
| `nums[-4:-1]` | `[3 4 5]` |
| `nums[5:1:-1]` | `[5 4 3 2]` |
| `nums[:-1:-1]` | `[]` |
| `nums[100:-100:-2]` | `[6 4 2 0]` |
| `nums[::0]` | `SequenceStep` |
| `nums[-1]` | Invalid scalar index; not the last element |

[Complete examples](examples/expression_slices/README.md) have sources and expected outcomes. [Executable tests](validation/ternary_slices_reference_test.py) compare 7371 length/bounds/step vectors against Python, then separately check omission, effects, laziness, reference identity, overlap and colon contexts. Their [report](validation/ternary_slices_reference_report.json) distinguishes these host-model checks from LMX runtime acceptance.

<a id="receiver-algorithms"></a>
## 8. Receiver bodies and implementation boundaries

This section specifies the phases shared by the existing namespace, `if`
admission, Array access and storage mechanisms. It does not introduce a second
evaluator or new public system functions. LMX examples are in
[expression_slices](examples/expression_slices/README.md); the executable
**host verification model** is separately kept in
[ternary_slices_reference.py](tools/ternary_slices_reference.py). A passing
host test is not evidence that these receiver contracts run in production LMX.

### One conditional body

```lmx
condition ? yes : no
`?:`(condition; yes; no)
```

The method receives RAW occurrences: one condition through `left` and two
arms through `right` in the infix form; the receiver supplies the same roles.
It obtains the condition once in its original context, admits it under the
ordinary `if` contract, then obtains only the selected arm in that arm's
original context. The selected value keeps its identity. Neither grouping,
adaptation nor static contract checking executes an unused arm.

### Obtaining the descriptor and sharing selection

| Entry | Ordered preparation |
| --- | --- |
| Slice suffix | Obtain the source once. Visit present `start`, `stop`, then `step` expressions, obtaining and immediately admitting each integer before visiting the next. Preserve absence without reading payload. Only after all bound effects, obtain the actual source shape and normalize the selected axis. |
| Call with an explicit slice descriptor | Ordinary argument handling obtains the source and present descriptor fields; then obtain the actual shape and use the same normalization and VALUE selection. |
| Strict `slice(source; begin; end)` | Admit integer bounds and `0 <= begin <= end <= N`; use start `begin`, stop `end`, step `1`, count `end - begin`, then the same VALUE selection. This profile does not clip bounds. |

Presence belongs to the explicit descriptor; another dynamic scope cannot
supply an omitted field. A bad early bound stops later bound effects. Backing
storage is not captured before those effects. Call and suffix share selection
after their argument descriptors are obtained.

```lmx
values[1:5:2]
values[::-1]
values[:-1:-1]
```

The last two forms deliberately differ: omitted reverse stop and written `-1`
are distinct descriptors.

### Normalizing the Python-like profile

Length `N` must be nonnegative. An absent step means `1`; zero step fails
`SequenceStep`. Normalization uses exact signed intermediate arithmetic.

| Rule | Positive step `s` | Negative step `s` |
| --- | --- | --- |
| Admitted clipped interval | `[0, N]` | `[-1, N - 1]` |
| Absent start | `0` | `N - 1` |
| Absent stop | `N` | `-1`, retained as the default sentinel |
| Present bound | Add `N` if negative, then clip to the interval. | Add `N` if negative, then clip to the interval. |
| Empty selection | `a >= b` | `a <= b` |
| Nonempty count | `1 + (b - a - 1) div s` | `1 + (a - b - 1) div (-s)` |

Here `a` and `b` are the normalized start and stop. Presence is tested before
accessing payload. In particular, omitted negative-step stop returns default
`-1` **before** the explicit-negative adjustment. The mathematical `-s` in
the count formula must not overflow when `s` is the minimum machine integer;
use checked/widened or magnitude-safe arithmetic. Admit count and result
storage size before allocation. The table defines arithmetic, not additional
LMX receivers or a hidden second slice implementation.

### Shared collection and stores

VALUE allocates one independent outer Array with the source's complete
storage profile and the selected axis length. Common Array traversal reads
each selected element in order, preserving reference targets and their
`parent`. It performs no read for an empty selection and no index increment
after the final read. Multiple axes compose under §4 and the common shape
traversal; a matrix is not flattened.

PLACE retains an operation-local selection of original places, the source
and checked geometry; it does not allocate a user-visible Array copy.
Assignment obtains each required RHS actual once. `:=` admits scalar fill or
exact Array shape correspondence; `.:` requires a slice destination and
constructs the explicit right-aligned broadcast map. All destination
geometry, store admission and required source values are stabilized before
the first write.

```lmx
values[::-1] := values
matrix[:][:] .: bias
```

One RHS Array is consumed under the destination method's element contract;
three sibling Arrays remain three source elements. The grouper neither
executes nor expands a returned value. Common prepared assignment uses the
existing LMX body [FxArrayAssignPrepared](patterns/LMX_Fn_Receivers/src/array_expression_ops.lmx):

```lmx
FxArrayAssignPrepared\assign(context; source)
```

This body snapshots the source, admits every mapped RHS value, then writes
through the prepared common accessors. Its presence does not establish
production support for extended slice descriptors or PLACE preparation.

### Source/instance context and fusion

A copied VALUE slice is not silently a retained View. An explicitly requested View is an ordinary Array whose system `parent` supplies the instance access/source context; its immutable type descriptor supplies type/rank/extents, not per-instance backing or alias information. Copying a reference does not reparent its target. The common accessor must preserve the source and validate the current geometry; no new Array user field is introduced. [View contract](TENSOR_EXPRESSIONS.md#geometry-and-parent).

`destination := fuse(expression)` and `slice .: fuse(expression)` first obtain the fresh final result under the initial Scalar/Map `fuse` contract, then perform ordinary assignment. Merging the store, a reduction, or a contraction requires a separately supported capability and cannot be promised from syntax alone. Production support of the new square-source parser and these new execution contracts remains **NOT_RUN**.

## Sources for the adopted slicing policy

Omission, clipping and signed-step behavior were checked against the primary [Python sequence types](https://docs.python.org/3/library/stdtypes.html#common-sequence-operations) and [Python slicing syntax](https://docs.python.org/3/reference/expressions.html#slicings). This adopts the stated slicing policy, not Python's negative scalar indexing, resizing slice assignment or unrelated language rules.
