# Conditional expressions and sequence slices

Revision 26 November 2026. This is a normative addition to the common Expression grammar and semantics. The [executable reference model](tools/ternary_slices_reference.py) checks normalization and consumption contracts separately from the production LMX parser, translator and runtime; those production executions remain **NOT_RUN**.

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

The second example is `flag ? first : (second ? other : fallback)`. The third executes one selected assignment. The operand has one left condition occurrence and two right RAW arm occurrences. The common public header has `left`, integer `depth`, `right`, followed by constant `PASS_ARGS_AS_IS` and `PRIORITY`; this conditional form adds no form-specific fields. Its ordinary application supplies depth=0 and mode 1. A depth expression is obtained only on demand, so the unselected arm cannot cause depth effects either; see [operation depth](OPERATOR_DEPTH.en.md#evaluation). A missing-left operand application remains a distinct actual vector and can be admitted or interpreted only by the method, not by a parser rewrite. The receiver adapter supplies three explicit roles to the shared body.

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
| `flag ? (a .: b) : c` | `.:` is one assignment token, not an arm delimiter |

At the current level of an index suffix, `::` supplies two slice separators, not a signature token. A nested group has its ordinary context, including `::`. Outside an index suffix the signature token is unchanged. Strings and exact identifiers still shield their contents. Longest-token recognition preserves `.:`, `:=` and other compound operator tokens before structural single-colon handling; `.=` is elementwise comparison, not assignment.

A short colon receiver inside an arm must be bounded, as in `flag ? (f: x) : (g: y)`, or written compactly as `flag ? f(x) : g(y)`. Otherwise a colon at that level already closes the conditional arm. Unmatched questions, absent arms and surplus delimiters fail preparation before effects. P0 handles source punctuation. The Expression grouper receives graph boundaries and source references, never searches for textual parentheses, and accepts equivalent graph-created applications.

<a id="slice-contract"></a>
## 3. `[start:stop:step]`

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

As a VALUE, a slice is a new outer container with the source's actual storage profile. Dense elements retain their type; reference elements retain their existing targets and parents. There is no deep copying or reparenting. Slice `char[]` in its element units without implicit Unicode decoding. The result is an ordinary Array, not a new hidden view kind or persistent execution representation.

As the destination of `.:`, the same index selection denotes real places in the source Array. The selection plan belongs to that operation. Obtain all required RHS values before the first store so overlapping selections, including `a[::-1] .: a`, are correct. Preflight count/shape and write admission. Destination length does not change. If RHS preparation changes its shape relative to the selected places, fail before stores. Existing const/immutable, ownership and actual-stride contracts apply.

```lmx
(a b c) .: (b c a)
values[1:5:2] .: (8 9)
values[::-1] .: values
```

A Structure is an Array of unrestricted element types, so the first line uses the same elementwise assignment. Capturing the RHS before stores makes the rotation correct. Existing current-level sequence consumption and single-left packaging remain; no tuple type is added. Scalar `x := value` keeps its own contract. Python-style resizing through slice `:=` is not introduced; use the existing explicit `replaceRange`/`splice` operations for resizing.

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

The suffix uses `slice(source; spec)`, where spec is an ordinary Structure with independently present start/stop/step. An explicitly supplied description is not completed from similarly named caller variables. Presence can be represented by ordinary flags and uninitialized fields; never read an absent field's nonexistent payload. This is an operation argument description, not a second program graph.

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
    int[]: values [10 20 30]
    int@: p @values[1]
    int: previous \(p - 1)
```

`p - 1` reaches the preceding element within the same valid backing; it is not `values[-1]`. This distinction also matters because interpreted L2 still checks Array bounds. A pointer grants no permission to leave the allocation or violate alignment, lifetime or protection.

Negative slice bounds have their explicit separate meaning: `values[-1:]` returns a one-element Array containing the last value; `values[:-2]` omits the last two values; `values[-4:-1]` selects the indicated half-open range.

<a id="examples"></a>
## 7. Required examples and verification

For `int[]: nums [0 1 2 3 4 5 6]`:

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

The following is algorithmic pseudocode, not new LMX syntax. `obtainValue`,
`admitIfCondition`, `readElement` and `allocateLike` denote integration points
for existing namespace, `if` admission, Array access and allocation with the
complete storage profile. They are not invented system functions or kernel
stubs. Executable host-model bodies are in
[`ternary_slices_reference.py`](tools/ternary_slices_reference.py).

### One conditional body

```text
conditionalMethod(conditionOccurrence, yesOccurrence, noOccurrence):
    condition = obtainValue(conditionOccurrence, its original context)
    admitIfCondition(condition)
    selected = yesOccurrence if condition != 0, otherwise noOccurrence
    return obtainValue(selected, its original context)
```

The inputs are RAW occurrences, not ready values. In `a ? b : c`, the method
receives its condition through one `left` and its arms through two `right`
items; the `` `?:` `` receiver supplies the same three roles. Neither the
grouper nor adaptation obtains an unused arm. The selected value keeps its
identity. Static contract checks do not execute either arm's body.

### Obtaining the descriptor and sharing selection

```text
prepareSliceSuffix(sourceOccurrence, boundOccurrences, receivingRole):
    source = obtainValue(sourceOccurrence, its original context)
    for each of start, stop, step in that order:
        if absent: retain absence without reading payload
        otherwise:
            value = obtainValue(bound occurrence, its original context)
            immediately admit its integer type
            retain presence and value
    shape = actual shape(source)  # after all bound-expression effects
    plan = normalizeSlice(selected axis length, explicit bound descriptor)
    return consumeSelection(source, shape, plan, receivingRole)

slice(source, explicitSpec):
    # Ordinary argument handling has obtained source and present fields.
    shape = actual shape(source)
    plan = normalizeSlice(selected axis length, explicitSpec)
    return consumeSelection(source, shape, plan, VALUE)

slice(source, begin, end):
    N = actual length(source)
    admit integer begin/end and 0 <= begin <= end <= N
    plan = (start=begin, stop=end, step=1, count=end-begin)
    return consumeSelection(source, actual shape(source), plan, VALUE)
```

Presence is checked in the explicit descriptor, without requesting a matching
field from another dynamic scope. A bad early bound stops later bound effects.
Backing storage is not captured before bound effects. A call and a suffix
share selection after their argument descriptors have been obtained.

### Normalizing the Python-like profile

```text
normalizeSlice(N, spec):
    admit N >= 0
    s = spec.step if present, otherwise 1
    if s = 0: fail SequenceStep
    (low, high) = (0, N) if s > 0, otherwise (-1, N-1)

    normalizeBound(present, value, default):
        if not present: return default
        if value < 0: value = N + value
        return min(high, max(low, value))

    a = normalizeBound(spec.hasStart, spec.start, 0 if s > 0, otherwise N-1)
    b = normalizeBound(spec.hasStop, spec.stop, N if s > 0, otherwise -1)
    if s > 0:
        count = 0 if a >= b, otherwise 1 + (b-a-1) div s
    otherwise:
        count = 0 if a <= b, otherwise 1 + (a-b-1) div (-s)
    admit count and result storage size before allocating
    return (start=a, stop=b, step=s, count=count)
```

Intermediate arithmetic is exact and signed. In particular, `-s` must not
overflow for the minimum machine integer. Conditional `spec.start` notation
does not authorize reading absent payload: presence is tested before reading.
An omitted stop returns default `-1` before explicit-negative adjustment,
which preserves its distinction from written `-1`.

### Shared collection and stores

```text
consumeSelection(source, sourceShape, plan, VALUE):
    result = allocateLike(source, shape with selected axis length plan.count)
    index = plan.start
    for position from 0 through plan.count-1:
        result[position] = readElement(source, index)
        if position+1 < plan.count: index = index + plan.step
    return result

consumeSelection(source, sourceShape, plan, PLACE):
    return operation-local original-place selection (source, sourceShape, plan)

elementwiseStore(selectedPlaces, incoming):
    obtain and retain all required right values
    verify unchanged destination shape, count/shape and store admission
    store retained values into the selected original places
    return the target under the ordinary .: result contract
```

The loop never reads an empty result and never increments after its final
read. Multiple axes use the composition in §4 and the common shape traversal;
this one-dimensional body does not flatten a matrix. `readElement` preserves
references and `parent`; VALUE produces an independent outer Array. PLACE
does not allocate a user-visible Array copy. When one RHS value is a returned
Array, `.:` selects its immediate elements; three sibling Arrays remain three
source elements. The grouper does not execute or expand a returned value.

## Sources for the adopted slicing policy

Omission, clipping and signed-step behavior were checked against the primary [Python sequence types](https://docs.python.org/3/library/stdtypes.html#common-sequence-operations) and [Python slicing syntax](https://docs.python.org/3/reference/expressions.html#slicings). This adopts the stated slicing policy, not Python's negative scalar indexing, resizing slice assignment or unrelated language rules.
