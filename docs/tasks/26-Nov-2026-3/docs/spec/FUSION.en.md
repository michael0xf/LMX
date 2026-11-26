# fuse: one traversal of the selected output leaves

`fuse(expression)` is a standard receiver consuming **one RAW expression**
through the common Expression mechanism. It retains the live expression and
requests an eligible computation in one output traversal. An eager function
with an ordinary `@: expression` input does not implement that contract.

The [common operator-depth contract](OPERATOR_DEPTH.en.md) applies inside the
expression: the undecorated operation has depth 0, `.op` has depth 1, and
`.(EXPR)op` carries one obtained nonnegative integer. A receiver uses its base
name with the named `depth` input, for example `` `*`(a; b; depth := 2) ``.
Backticks preserve an identifier; they do not decode decorated names.
`.=` compares; `.:` assigns, as the depth-1 surface of base `:=`.

## 1. Eligible computation

```lmx
return: fuse(a .* b .+ e)
```

For matching **rank-one** Array descriptions, each coordinate performs scalar
multiplication followed by scalar addition. No intermediate `a .* b` Array is
created. Only result storage is allocated. An original scalar input expands
at the admitted levels but is obtained once before traversal.

```lmx
return: fuse(values .* scale() .+ bias())
```

`scale()` and `bias()` run once each in their established order, including for
an empty result. A wholly scalar subtree is also obtained once. Two written
occurrences remain two evaluations; no cache is keyed by a callable or source
text. Depth expressions are obtained by ordinary demanded Expression evaluation,
not by a numeric-literal parser or by rerunning the expression at every leaf.

For flat rank-two Arrays, the corresponding scalar-cell form is:

```lmx
return: fuse(a .(2)* b .(2)+ bias)
```

Depth consumes retained logical axes of the same flat storage. At depth one,
a rank-two input supplies logical rows; base `*` on two rows is vector
contraction. At depth two it supplies scalar cells. Row access uses temporary
address/shape descriptors, not allocated row Arrays or graph nodes. Requested
axes must exist under the admitted description. An Array-derived scalar cannot
silently supply a missing axis of another Array operand. Only an original
scalar operand may broadcast while lifting still needs another axis.
At remaining depth zero the base receiving contract takes over; it may itself
have an Array/scalar profile. Completely scalar original operands need no
synthetic Array levels.

| Selected operation | Eligibility |
| --- | --- |
| Pure arithmetic, bitwise or comparison applied to compatible output leaves | Yes |
| An admitted ordinary Array/scalar component profile | Yes |
| Ordinary `a * b` selecting vector/matrix contraction | No |
| `a .* b` over rank-two matrices | No: each pair of logical rows selects vector contraction |
| `a .(2)* b` over rank-two matrices | Yes: the base operation receives scalar cells |
| I/O, mutation, yield or unknown effects in the leaf kernel | No |
| Scalar captures outside the leaf kernel | Once per demanded written occurrence |
| A wholly scalar expression | One ordinary scalar evaluation, no Array or speed promise |

The compatibility check belongs to the actual selected contracts. An unknown
or ineligible request is diagnosed; it never selects an eager fallback.
Ordinary matrix `a * b + e` and coordinatewise
`a .(2)* b .(2)+ e` remain different. For rank-one inputs the scalar form
remains `a .* b .+ e`.

## 2. Conditional, diagnostics and ordinary failures

```lmx
return: fuse(enabled ? a .* b : e .+ bias())
```

This short example uses rank-one inputs. Rank-two inputs select depth two
where scalar arithmetic is intended. No depth is inferred from punctuation.

Only the selected arm is obtained and planned. An inactive arm performs no
calls and does not evaluate its depth expressions. The condition is scalar;
an Array of predicates does not implicitly become a truth mask. Results and
references follow the ordinary ternary contract.

Invalid depth/type of the depth expression, missing required logical axes,
incompatible selected shapes and an ineligible `fuse` expression are
**translator diagnostics when known, otherwise interpreter diagnostics at the
reached operation**. They are not catchable LMX exceptions and add no `FxDepth`,
`FxShape` or `FxKernelFailure` outcome to these forms. A host-model diagnostic
class is not a proposed language exception. A thrown error from a user depth
expression or from a normally selected numeric/callback operation keeps that
operation's existing failure contract.

After captures and validation, output leaves are visited in structural order,
with the last coordinate varying fastest inside each actual Array. Scalar
expression-tree order is preserved within a leaf. No reassociation, implicit
FMA, precision change or conversion of decimal/real into machine double occurs.
A pure scalar operation may still fail. Explicit fusion selects the first such
failure by leaf order followed by expression-tree order. Eager whole-Array
operations may encounter another first failure; a compiler cannot silently
substitute one order for the other.

## 3. Assignment, depth and aliasing

```lmx
values .: fuse(values .* scale .+ bias)
```

For a rank-two destination, select its scalar-cell depth as well:

```lmx
values .(2): fuse(values .(2)* scale .(2)+ bias)
```

The destination selects real places. Shape, required levels and alias safety
are prepared before the first write. A complete scalar result is obtained and
admitted immediately before its leaf is written. A later ordinary scalar or
admission failure can therefore leave a written prefix. This streaming behavior
is requested explicitly by `fuse` and is not a replacement for ordinary
snapshot assignment.

Disjoint source storage and the same source/destination leaf map are admitted.
A source map that reads a different future destination cell, including across
logical regions or shared Structure fields, is rejected before writes in this profile. Repeated actual
destination places are likewise not a safe fused map. An explicit value snapshot
can establish a different valid source. Validation does not execute all scalar
arithmetic in advance and promises no rollback of earlier argument effects.

Ordinary `.:` or `.(n):` first retains **all selected RHS values across all
branches**, then admits every actual target, then writes in selected order.
This handles overlapping logical row regions and shared Structure fields.
At reached depth zero, a true binding PLACE accepts a whole new value under
its own type; its old value does not restrict rebinding. A logical row region
has no independent reference slot: whole region assignment admits a compatible
block and writes its existing cells. Scalar fill of rank r therefore selects
depth r unless the selected base block contract explicitly admits that scalar.

```lmx
(a b c) .: (b c a)
```

From `1,2,3` the result is `2,3,1`. A sole returned Array is opened into immediate
values by the assignment consumer at the selected level. Several sibling
structural values stay several values. The grouper performs no post-call
flattening. A slice in VALUE role produces a fresh selection; a slice consumed
as PLACE selects real cells for this operation without a persistent view type.

## 4. One live graph and result storage

The operation retains references to actual expression occurrences, obtained
scalar/depth values, full requirements, shape descriptions and admitted address
maps. This is local metadata, not a copied namespace, rewritten source graph or
second executable program. The scalar expression template is shared by output
leaves rather than cloned once per element. A scalar result reused by an admitted
base profile can remain in a scalar register for its current structural position.

The result uses the canonical TypeRef of its complete declared/evaluated
requirement. Persistent output extents belong in that requirement; the operation
must not refine a generic result type from initializer rows, reserve or the
observed payload. A temporary expression-local shape plan may carry dimensions
to the next operation, but is not a hidden per-Array descriptor.
`FxSeqAllocate(arrayType; count)` is the existing unsized linear helper; count
does not recover axes. A fixed shaped result must use common construction
immediately under its complete evaluated type, with valid count and initialized
backing before publication. Empty-value-plus-resize and retagging a ready `T[]`
are not substitutes; this is a required migration of the old source prototype.
At capacity=length there is no secondary descriptor. Real reserve uses an
optional capacity entry and never changes TypeRef merely for that reserve.
No field is added to `Lmx`. [Canonical Array types](ARRAY_STORAGE.en.md#array-profiles)
govern publication; missing dimensions needed by fusion are diagnosed.

Flat rectangular input and result storage
stay flat through axis traversal. If a result contract actually returns
Structures in fields, those are ordinary required result values; they are not
a separate nested-array kind or temporary row objects.

An inline `[items]` is a common-P0 Array constructor, never a grouping node.
`[arr2]` retains one whole arr2 reference. Eligible fusion may capture such a
constructor once; that explicitly requested source value is distinct from an
intermediate result of an arithmetic operator. Removing its allocation is an
optional proof-based optimization preserving identity, lifetime and failure
order. There is no singleton broadcast or permission to reassociate a chain.
See [inline Array expressions](ARRAY_EXPRESSIONS.en.md#inline).

A walker may use the common leaf consumer and a native translator may emit the
same traversal. MLIR, a new program graph and implicit compilation are not
required. Existing explicit compilation and `endturn` boundaries remain.

<a id="implementation"></a>
## 5. Shared LMX bodies and integration boundary

Source: [array_expression_ops.lmx](patterns/LMX_Fn_Receivers/src/array_expression_ops.lmx).

| Shared body | Work performed |
| --- | --- |
| `FxArrayExpressionFill` | One output loop; selected writer or void traversal |
| `FxArrayInputsAt` | One common collection with the selected flat or logical-axis reader |
| `FxArrayDepthBase` / `FxArrayDepthCell` / `FxArrayDepth` | Whole base call and one linearized traversal of the depth-selected logical items |
| `FxArrayElementCell` / `FxArrayElementwise` | The established direct scalar component profile |
| `FxArrayContractionCell` / `FxArrayProduct` | Ordered multiply/add contraction; provider zero only for an empty contraction |
| `FxArraySnapshot` / `FxArrayAssignPrepared` | Shared complete-RHS capture, all-target admission and writes |
| `FxArrayDepthCollect` / `FxArrayDepthAssignPrepared` | Select actual deep places, then reuse the same assignment body |
| `FxArrayResultTree` | Allocate only described result containers |
| `FxFuseFill` / `FxFusePrepared` / `FxFuseIntoPrepared` | One shared leaf loop for a new result or an existing target |

`FxArrayDepth\apply(context; depth; inputs)` receives a ready numerical depth,
not flattened replacement arguments. Its context supplies:

| Context member | Required contract |
| --- | --- |
| `base`, `hasResult` | Actual source callable and exact result/void contract |
| `level(context; depth; inputs)` | Checked axis selection, original-scalar provenance and complete result/void policy; returns `{hasArray,count,inputs,read,layout,write}` |
| `read(map; index)` in that frame | One selected scalar, Structure value or logical slice descriptor on the existing backing; no row storage |
| `write(output; index; value)` in that frame | Admit/store one base result into its prepared scalar/block result region |
| `publish(context; layout; result)` | Retain the actual result's full type and rank/extents description |

The full selected depth/shape contract is prepared before source callbacks.
`count` is the number of base applications after consuming the selected axes,
not necessarily the flat scalar count. This linearization implements the same
ordered recursive axis rule without allocating containers at intermediate axes.
The body adds `frame.root = context`. For a value result, `FxArrayResultTree`
allocates/publishes only the full prepared output layout, then the shared loop
obtains inputs through `read`, calls the base once and stores through `write`.
The ordinary scalar reader remains the default for direct flat operations.

At depth zero, and for entirely original scalar inputs, the base fast path
preserves the exact R/void and invokes the source once without an Array.
A void source uses the same loop
without result allocation or `Array<void>`; the wrapper preserves the absence
of a public result. RAW, PLACE, TYPE and other special receivers choose their
own depth policy rather than entering VALUE lifting by accident.

Depth-selected assignment preparation supplies real `open`/`child` place access and a
`linearize` view over its selected entries. `FxArrayAssignPrepared` then uses
`admit(context; index; value)` and `write(context; index; ready)` once each as
specified. These are genuine place handles/maps, not copies of caller variables.
Logical row/plane PLACE is an addressable region, not a synthetic pointer slot.
Fusion's `bindOutput` supplies checked `target/count/cell/write/direct`; dense
output may use its Array directly, while other real places may use a compact
address map. It need not allocate a PLACE handle per dense cell. These callbacks are
explicit bridges to common type/Expression/PLACE preparation, not new public
functions with empty bodies or claimed completed runtime integration.

## 6. Verification and performance claim

The [host reference](tools/array_expression_reference.py) reuses
[common depth transport](tools/operand_depth_reference.py), not a second parser.
[Tests](tools/test_array_expression_reference.py) cover base-versus-lifted
products at flat rank-two depths 0/1/2, rank-three axes, demanded dynamic depth,
real-place rebinding, block snapshots, inline constructors and ordinary chain
order, shape/depth diagnostics, generic scalar contexts,
void, alias maps, lazy branches, ordinary failures and output/allocation counts.
Production parser, translator and LMX runtime remain **NOT_RUN**; the actual
host result is [recorded separately](tools/array_expression_reference_results.json).

```sh
python docs/spec/tools/test_array_expression_reference.py \
  --json docs/spec/tools/array_expression_reference_results.json
```

The rank-one `fuse(a .* b .+ e)` model has one output pass and one result Array,
versus two passes and two result Arrays for eager composition. Flat rank-two
`fuse(a .(2)* b .(2)+ e)` likewise allocates one flat result with retained shape;
traversing logical rows allocates no row storage. Ordinary Structure values
required by a result contract are allocated once. Compatible in-place fusion
allocates no intermediate result Array. These are algorithmic counts, not a
native benchmark or a universal elapsed-time guarantee.
