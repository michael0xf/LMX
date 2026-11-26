# Array arithmetic, dotted operations and elementwise assignment

This is the integrated language contract of 2026-11-26, including the
[general depth mechanism](OPERATOR_DEPTH.en.md). The depth-1 spellings are
`.=` for elementwise equality and `.:` for elementwise assignment. Neither
`.=` nor `.:=` is an assignment alias. The implementation bodies are in
[array_expression_ops.lmx](patterns/LMX_Fn_Receivers/src/array_expression_ops.lmx);
the executable host reference is
[array_expression_reference.py](tools/array_expression_reference.py).
Host reference checks do not claim a production LMX parser/native run.

## 1. Selection and representation

The ordinary receiver first obtains its actual operands under the common
Expression/argument contract. If an obtained value is an Array, its array
profile participates in selection. An ordinary Structure is exactly an
Array of freely typed elements, `@[]`; it is not excluded because its fields
have names. No separate Matrix class, annotation or spelling is required.
Array detection does not recursively inspect arbitrary nested fields and
does not turn several right actuals into a single implicit argument.

Actual physical storage, complete element requirements, and shape come from
the existing value/declaration/description contract. A plain sequence has
shape `[length(source)]`. A described rectangular Array retains that shape;
the product of its extents must equal its element count. `int[][][]: arr`
describes rank three of one flat C-like backing. Rank/extents live in the arena's
side metadata beside capacity; the `parent/length/storage` header is unchanged.
Rank is not recovered from total length, pointer depth or the first element.
Structure is the same ordinary `@[]`. Stored Structure references retain their
identity and ordinary field/index access; they introduce no separate array-of-arrays kind.
See [Array storage and access](ARRAY_STORAGE.en.md).

Flat sequence operations and dimensional operations both remain available on
the same value. A flat consumer reads the existing length/storage without
reshaping, retagging or constructing a rank-one proxy. Shape-preserving results
retain extents; a fresh linear selection has its own declared rank-one result.

A result retains its computed shape in the actual Array's ordinary description,
carried to subsequent consumers through that description or the current
operation-local descriptor. Storage allocation by Array type and flat count
alone does not establish shape; the common preparation/publication boundary
must retain it. Thus `a * b + e` passes the product's `(m,n)` description to `+`
without reconstructing dimensions, adding header fields or building row objects.

All arithmetic uses the selected scalar operations. Machine integers,
floating-point profiles, bigint, decimal, real and other admitted scalar
models are not silently reduced to int or double. A contraction requires
compatible multiplication, addition, and a correctly typed additive zero.
The output requirement is established before traversal, including for empty
inputs; no first-element probe is allowed. Dense inputs produce dense R only
when the full R is established; a free-element Structure is handled through
the ordinary reference-array access path.

## 2. Ordinary arithmetic with Arrays

| Operation | Array profile |
| --- | --- |
| `a + b`, `a - b` | Equal shapes: component addition/subtraction. One scalar: expand that scalar over the Array, preserving operand order. |
| `scalar * a`, `a * scalar` | Scale each component; the scalar is obtained once. |
| `a * b`, both rank 1 | Bilinear dot product, in increasing component order. |
| `a * b`, ranks 2 and 1 | Matrix-vector product. |
| `a * b`, ranks 1 and 2 | Vector-matrix product; the rank-1 left value is the left vector. |
| `a * b`, both rank 2 | Matrix product: `(m,k) * (k,n) -> (m,n)`. |
| `a / scalar` | Component division with the original scalar division contract. |
| `a / b` with two Arrays, or scalar / Array | No matrix inverse/linear solve is guessed. Select scalar division at the required depth (`./` for rank 1, `.(2)/` for rank 2), or use an explicitly selected solver profile. |
| `a ** exponent` with Array a | Only an explicitly supplied algebraic power profile. Select scalar powers at the required depth (`.**` for rank 1); this edition does not invent an inverse or a matrix-power algorithm. |
| `%` and the available integer bitwise/shift profiles | Their admitted component profile; the dotted form makes component application explicit. |

Higher-rank contraction requires an explicit admitted contract; it is not
silently flattened into a matrix or broadcast. Multiplication of two
vectors is therefore no longer the former component product: write `a .* b`.
Scalar arithmetic keeps its established meaning.

The matrix kernel computes each output cell in row-major order. For a nonempty inner dimension, each
cell starts with its first product, then adds subsequent products in increasing
inner-index order. The selected additive zero is requested only for an empty
inner dimension and then supplies every output cell. No implicit conjugation, reassociation, FMA,
parallel reduction or numerical promotion is introduced. A numerical
profile may explicitly permit stronger transformations.

For example, with shapes a=(2,3), b=(3,2), e=(2,2):

| Input | Rows |
| --- | --- |
| a | [1 2 3]; [4 5 6] |
| b | [7 8]; [9 10]; [11 12] |
| e | [1 1]; [1 1] |
| `a * b + e` | [59 65]; [140 155] |

The shapes here are part of the admitted input descriptions, not a proposal
to reinterpret an Array of separately allocated rows as a flat rectangle.

```lmx
MatrixExample:
    @: a
    @: b
    @: e
    return: @
    run:
        throws: copy(`*`\throws) copy(`+`\throws)
        return: a * b + e
```

The ordinary receiver form `` `*`(a; b) `` uses the same implementation as
the operand. A backend's technical name such as matmul is not a second
algorithm. Existing explicitly profiled dot/contract/outer operations keep
their stated contracts; different conjugation or contraction is not merged
merely because names look related.

<a id="inline"></a>
### 2.1. Inline Array values and an ordinary chain

In VALUE position `[items]` constructs one anonymous freely typed `@[]` through
common P0. It is an explicit Array VALUE, not an anonymous grouping node that
Expression may unwrap. Elements are obtained once in the established order;
the first element does not determine a dense type. A typed constructor, such as
`int[]: [10 20]`, gets its element contract from the receiver and need not create
an intermediate `@[]` for conversion.

```lmx
int: a 1
int: b 2
int: d 4
@: result a + b + [10 20] + d
# [17 27], with grouping ((a + b) + [10 20]) + d.
```

`a + b` is obtained once before its Array-consuming parent operation. With
effects or ordinary numeric failures, later literal elements and operands are
not moved ahead of a dependency that may fail. The explicit typed variant
`a + b + (int[]: [10 20]) + d` obeys the same expression priorities.

```lmx
@: arr0 [[1 2]]
@: arr1 [[10 20]]
@: arr2 [100 200]
@: result arr0 .+ arr1 .+ [arr2]
# [[111 222]]; all three outer operands have length 1.
```

`[arr2]` contains exactly one whole value, the same arr2. It neither copies nor
flattens arr2, and it does not request singleton broadcasting. An outer extent
greater than one on the left therefore diagnoses a mismatch with `[arr2]`.
This is an ordinary Structure reference in an element, not another Array kind.
The typed rank-two initializer `int[][]: [1 2; 3 4]` (equivalently
`int[][]: [[1 2] [3 4]]`) has a different receiving contract: it prepares one
flat rectangle with retained extents. That contract does not globally flatten
standalone `[arr2]`.

A translator can use known shape, lifetime and scalar contracts to remove
unobservable construction or intermediate storage. It must prove preservation
of identity, demand/effect/failure order and numerical grouping. No reassociation,
implicit FMA, silent eager-to-fused error-order change or program-graph clone is
authorized by the presence of brackets. [Complete examples](examples/array_expressions/README.md)
and the host reference keep these limits explicit.

<a id="dotted"></a>
## 3. Arithmetic as a profile of common operator depth

Depth belongs to [all operator families](OPERATOR_DEPTH.en.md), not a separate
set of arithmetic names. `op` means depth 0, `.op` means depth 1, and
`.(EXPR)op` supplies an explicit depth, including 0 or 1. The parentheses contain
an ordinary parsed Expression: a literal, name, operation or call is obtained
once when this operation is demanded. Further levels use this parenthesized form,
not repeated dots. The operator method receives `left`, **`int: depth`**, `right`;
the argument transport does not flatten its operands beforehand.
The lexical sequence `.(` always starts an operator/function depth modifier;
it is never a decimal point. Array constructors and index/slice brackets keep
their square-bracket syntax. For example, `1 .(3)+ 2 .(2)+ 3` is valid and
returns 6 under the ordinary scalar fixed-point and addition rules.

The standard arithmetic VALUE profile consumes one **logical leading axis**
at each positive depth. Its size and the remaining extents come from the
retained descriptor. Selecting a row or plane uses an operation-local
descriptor over the same backing; no row Array, pointer slot or graph node is
allocated for the traversal. Selected extents must agree. At remaining depth
zero the base operation consumes the complete selected scalar, vector or block
according to its own contract.

An original scalar input may broadcast. An original Array that reaches a
scalar before the requested depth cannot silently supply another Array's
missing axis. Excess or incompatible required depth is diagnosed. Entirely
scalar original operands are fixed points. An ordinary Structure stored in a
field remains the same value and can be consumed through the same general
Array mechanism; it is not a special nested-array model.

```lmx
int[][]: a [1 2; 3 4]
int[][]: b [[5 6] [7 8]]
@: matrix a * b
# shape (2,2): [19 22 43 50]
@: rowProducts a .* b
# shape (2): [17 53], the base * contracts each pair of rows.
@: cells a .(2)* b
# shape (2,2): [5 12 21 32], scalar multiplication at every coordinate.
```

Thus `.op` always means depth one; it does **not** promise scalar application
at every rank. For rank r, `.(r)op` reaches scalar cells when the declared
elements are scalar. A rank-three value has three logical axes in its one
flat storage. `a .(1)* rowScalars` can select valid vector/scalar scaling;
`a .(2)* rowScalars` cannot invent the missing second axis of rank-one rowScalars.

The table gives convenient depth-1 spellings, not separately named bodies:

| Scalar family | Depth-1 spellings |
| --- | --- |
| Binary arithmetic | `.+ .- .* ./ .% .**` |
| Unary signs | `.+ .-` in their unary position |
| Integer bitwise and shifts | `.& .\| .^ .~ .<< .>>` |
| Comparisons | `.= .!= .< .<= .> .>=` |
| Compound arithmetic updates | `.+= .-= .*= ./= .%= .**=` |
| Compound bitwise/shift updates | `.&= .\|= .^= .<<= .>>=` |
| Attached updates | Prefix/postfix `.++`, `.--` in the corresponding attached class |
| Assignment family | `.:`, the depth-1 surface of `:=` |

The canonical attached receiver names are `++var`, `var++`, `--var`, `var--`;
`depth := 1` selects the forms in the table. Prefix returns updated values;
postfix returns a snapshot at the selected depth. One shared update algorithm
serves both. This table invents neither a character-count limit nor a rotation
meaning for an otherwise unprovided `<<<`/`>>>`.

Selected leading extents must match; at remaining depth zero the base contract
checks the remaining whole values and block shapes. Equal total counts alone
are insufficient. There is no
singleton-axis broadcasting, truncation, recursive sibling flattening or
implicit numeric conversion. Comparison produces a correspondingly shaped
result of scalar predicates, normally int 0/1, without reducing it to one
truth value. Use an explicitly selected `all`/`any` reduction when needed.

```lmx
@[]: a [1 2 3]
@[]: b [1 8 3]
@: equal a .= b
# equal = [1 0 1]; a and b are unchanged.
a .: b
# a = [1 8 3]; its outer identity is preserved.
```

Receiver examples use **base names and the same named depth**:
`` `+`(a; b; depth := 1) ``, `` `=`(a; b; depth := 1) `` and
`` `:=`(a; b; depth := 1) ``. A quoted identifier containing a dot remains that
literal identifier; it is not an alias or a request to decode a depth.
The assignment family's agreed surface mapping is `:=` at depth 0,
`.:` at depth 1 and `.(EXPR):` for explicit depth. In particular `.(0):`
performs the base whole-place assignment; `.:=` is not a spelling of this family.

Logical, TYPE, DATA, RAW, PLACE and other receivers retain their own consuming
contracts and select a supported depth policy. A common decorator does not
turn short-circuiting into eager calls or force recursive VALUE lifting onto
signatures, addresses or Pattern composition. See [roles and ABI](OPERATOR_DEPTH.en.md#abi).

<a id="assignment"></a>
## 4. Elementwise assignment and permutations

`destination .: source` consumes the left occurrence as real target places
at depth one. For rank one these are actual element slots; for rank two they
are logical row regions of the same flat backing. For a written
group of places, the common PLACE consumer obtains those real places:
the group is still a Structure/Array of freely typed elements, not a tuple
object and not a copy of the variables.

The target is resolved once. RHS occurrences are consumed once in their
established order; their values are retained before the first target write.
Shape/count and each actual target's admission are checked before the write
phase in checked execution. The assignment preserves target count, shape
and outer identity. It returns the assigned target under the ordinary
result contract, without making a second copy of the assigned data.

For `destination .(n): source`, these rules apply to the actual places
selected through n logical axes. All RHS values in all selected branches are
captured before any write; checking only the first child is insufficient.
An original scalar source may fill the selected levels. A source Array must
provide the required levels and shapes; its missing children are not scalar
broadcast. At reached depth 0 a target PLACE accepts a whole value, including
an Array reference or a different admitted type. Its old value's nesting and
an uninitialized old value do not obstruct ordinary whole-place assignment.
The syntax `reference .(0): other` is therefore the base `reference := other`.
A logical row/plane region has no independent pointer slot to rebind. Its
base assignment admits a complete compatible block of the same tail shape,
retains all source cells, then writes the real region without resizing it.
For a scalar fill of a rank-two matrix use `matrix .(2): scalar`; `matrix .: scalar`
selects whole rows and does not bypass their ordinary block admission.

```lmx
int: a 1
int: b 2
int: c 3
(a b c) .: (b c a)
# a=2, b=3, c=1
```

Both `(a b c) .: copy(d)` and `(a b c) .: (copy(d))` use the existing
group/field-stream consumer. No new post-grouping flattening pass is added.
Sibling structural RHS values remain separate items. A scalar RHS can fill
all selected targets; an actual Array/field stream must match the selected
shape/count. A copied Structure remains subject to ordinary graph-copy
identity, parent and ownership rules.

Aliasing never makes a permutation sequentially overwrite the next value.
The general operation retains the required RHS values before writes.
For compound updates, the old target values and RHS are obtained before
commit; `a .+= b` uses the same component addition and assignment machinery
as `a .: a .+ b`, but resolves a only once. A target failure or RHS failure
does not undo effects already performed while obtaining the arguments.
This does not add a general transaction or rollback mechanism.

`destination .: fuse(expression)` explicitly selects the streaming fused-output
contract: shape, places and alias safety are prepared before writes, but each
scalar result and its value admission are obtained at that coordinate. A later
scalar/admission failure can leave an already written prefix. This exception
is requested by `fuse`; the compiler cannot silently replace the ordinary
complete-RHS assignment above with that behavior. See [fusion](FUSION.en.md).

`a[start:stop:step]` as VALUE produces a fresh selection. In the PLACE
position of `.:` it denotes selected real target cells for that operation;
it does not introduce a persistent view type. Resizing remains
`replaceRange`/`splice`. See [slices](TERNARY_AND_SLICES.en.md).


### Shared compound and attached update algorithm

Compound and attached updates compose the component evaluator and the same
ordinary assignment body; they do not contain another write loop:

```text
compound(targetOccurrence, rhsOccurrence, baseOperation, depth):
    target = resolvePlaceOnce(targetOccurrence)
    old, rhs = captureRequiredValuesInWrittenDemandOrder(target, rhsOccurrence)
    values = applyAtDepth(baseOperation, old, rhs, depth)
    return ordinaryAssignmentAtDepth(target, values, depth)

attached(targetOccurrence, baseOperation, depth, resultPosition):
    target = resolvePlaceOnce(targetOccurrence)
    old = snapshotSelectedLevels(target, depth)
    if old has elements:
        unit = selectedScalarProfile.unit()
        values = applyAtDepth(baseOperation, old, unit, depth)
        ordinaryAssignmentAtDepth(target, values, depth)
    return old if resultPosition is postfix else target
```

Here the lowercase helper names describe integration steps, not new exported
LMX functions. The shared LMX bodies are `FxArrayDepth\apply` and
`FxArrayDepthAssignPrepared\assign`, which reuses `FxArrayAssignPrepared\assign`; the executable contract model implements
`compound` and `increment` in [array_expression_reference.py](tools/array_expression_reference.py).
Postfix update snapshots the selected levels so deeper writes cannot change
the saved old values; prefix returns the updated target. References below the
selected boundary retain their ordinary identity. At depth 0 the base result
contract applies. The scalar profile supplies the unit, so an implicit
`int` conversion is not introduced.

## 5. Priorities, roles and fusion

Dotted arithmetic/comparison has the corresponding scalar operation's
priority, arity and associativity. `.**` keeps the directional power rule.
`.=` has equality priority; `.:` and dotted compound updates have assignment
priority. The written left PLACE remains tied to its occurrence as in
ordinary assignment. Attached updates retain the common attached-operator
class. Names containing punctuation use the existing backtick identifier
rule in receiver form.

`fuse(expression)` explicitly requests the eligible one-traversal component
profile. Its argument is RAW; it is not evaluated into temporary Arrays
before planning. See [fusion](FUSION.en.md) for scalar capture, selected
ternary branches, alias admission and error order. A matrix contraction
does not become elementwise merely because it is inside fuse.

```lmx
@: scores fuse(2 .* left .+ right .* right)
@: mask scores .>= limit
return: compress(scores; mask)
```

Here left/right are rank-one sequences. For a rank-two scalar kernel select
depth two explicitly, for example `fuse(a .(2)* b .(2)+ e)`.

The benefit is one output traversal and no intermediate component-result
Arrays for an eligible expression. This is a structural execution guarantee,
not a measured promise that every input or backend runs faster.

<a id="implementation"></a>
## 6. Runtime integration and admission

The scalar operation is selected under its actual full contract. Shared
preparation obtains shape, source access, result representation and the
declared scalar operations; the LMX algorithm performs traversal. Temporary
operation-local layout/plan values do not replace the live program graph.
No persistent expanded namespace, shadow data or implicit graph copy is
introduced. Direct known native calls and the current compile/endturn
contract remain unchanged.

Invalid requested depth, missing required logical axes, incompatible Array-expression
shapes and ineligible fuse are translator diagnostics when known, otherwise
interpreter diagnostics at the reached operation. They are not catchable LMX
exceptions and introduce no new throw entry. Ordinary scalar/callback errors,
ordinary target admission and existing allocator/library failures retain their
own contracts. Declared errors are copied from the **base** methods, for example
``copy(`*`\throws)``, rather than from a fictitious dotted callable name.

The common VALUE bridge supplies the actual source, depth, original-scalar
provenance, checked level access and full result/void requirement. Special
receivers consume depth themselves. [Implementation contracts](FUSION.en.md#implementation)
describe `level`, `publish`, actual deep PLACE collection and the fused leaf
writer. They are explicit integration requirements; production execution is
not claimed. [Source examples](examples/assignment_forms/README.md) include
rebinding, nested assignment, dynamic depth and separate diagnostic fixtures.

These are common semantic preconditions. L3 and interpreted L2 use the
existing checked wrappers. Native L2 does not gain automatic bounds checks:
invalid access is not made valid by their absence. Relative address
arithmetic should use an appropriate pointer, not negative Array indexing.
The detailed indexing distinction is in [slices](TERNARY_AND_SLICES.en.md).
