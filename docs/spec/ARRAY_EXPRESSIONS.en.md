# Array expressions, operation depth and indexed operations

This chapter is the Array-facing entry to the complete normative [tensor specification](TENSOR_EXPRESSIONS.md). Written operator bodies follow the [bracket subparser](BRACKET_SUBPARSER.en.md); ordinary expressions, names, roles and live graph traversal retain their common rules. These are documentation and implementation contracts, not a claim that production parsing or execution has passed.

## 1. Values, types and selection

An ordinary Structure is the Array type `[]@`. It participates in Array operations with the actual typed records of its elements; it is not excluded because it contains references or named fields. A method that cannot add, multiply or otherwise consume particular element types diagnoses that application. It does not ban the entire container class. Text is likewise an Array with its declared character element type. Whole-text and whole-object methods keep their own receiving contracts.

The Array header remains `parent/length/storage`. TypeRef points directly to a canonical immutable type description. The complete normalized left declaration determines that type: `[2][3]int` retains shape `(2,3)`, whereas `[][]int` retains two unspecified extents. Initializer rows validate rectangularity and flatten data without silently specializing `[][]int`. An operation obtains dimensions from the actual type, uniquely derivable information and its available instance access context; missing required dimensions cause a diagnostic. Flat operations remain valid when they do not need those dimensions.

The system parent provides the complete instance descriptor/context, including a View's source and access map when needed. It is constructed with ordinary Structure templates and copy/merge. No extra LMX header field or second type system is introduced. Equality of length and capacity removes the need for extra reserve information; it does not forbid a parent context needed for lifetime or access. [Storage](ARRAY_STORAGE.en.md) distinguishes type, capacity and instance context.

Stored references and ordinary graph identity are preserved. `struct[i]\[j]` is ordinary indexed path traversal, not evidence of another flat axis. A Structure containing Arrays can be consumed by methods that accept those values, but a rectangular tensor extent is not inferred from arbitrary nested fields or the first element.

A result is assembled under its complete declared/evaluated requirement. A dense result with persistent output extents must retain those extents through that requirement or an explicitly defined access context. Variable-shaped results may be ordinary Structures. Empty results use the declared result contract; the implementation does not invoke a made-up first cell to guess a type.

## 2. Ordinary operations are elementwise

| Ordinary form | Array contract |
| --- | --- |
| `A + B`, `A - B`, `-A` | Corresponding scalar arithmetic at every admitted cell |
| `A * B` | Component multiplication; never an implicit dot or matrix product |
| `A / B`, `A % B`, `A ** B` | Corresponding scalar operation with its actual types and domain |
| `A = B`, `A != B`, ordering comparisons | Component predicates and their declared result type |
| Bitwise, shift and logical methods | Their admitted component contracts, preserving demand and roles |
| `A := B` | Ordinary pointwise assignment to real places |
| `slice .: source` | Dedicated slice assignment with explicit RHS broadcasting |

Iterated Array shapes/frames match exactly. Scalars contribute no axes and can be supplied to each application when the selected method admits them. An Array of length one is still an Array and does not silently stretch to another extent. Scalar division, overflow, result admission, comparison and short-circuit contracts are not replaced by generic machine-double arithmetic.

```lmx
[2][2]int: A [1 2; 3 4]
[2][2]int: B [5 6; 7 8]
@: components A * B
# [5 12; 21 32]
@: matrices A [*] B
# [19 22; 43 50]
@: mask A > 2
# [0 0; 1 1]
```

`=` is equality, `^` is XOR, and `**` is power. Power has `sys\priority("**") = 131` and derived RHS minimum `131`: `A ** B ** C` groups as `A ** (B ** C)`. The same grouping policy applies to `.(depth)**` and `[**]`, subject to each method's type and shape admission. `**=` retains assignment priority. [Numeric derivation](EXPRESSION_ALGORITHM.md#power-priority). No general `.op`, `..op` or `...op` aliases remain. Quoted receiver names retain their exact spelling; there is no parallel family of dotted callable names.

<a id="inline"></a>
### 2.1. Inline Array values

In VALUE position `[items]` constructs one anonymous freely typed `[]@` through common P0. This is one explicit Array VALUE, not an anonymous grouping node to unwrap. Its elements are obtained in the ordinary demand order; its first element does not select a dense primitive type. A typed constructor such as `[]int: [10 20]` uses the declared element requirement directly.

```lmx
int: a 1
int: b 2
int: d 4
@: result a + b + [10 20] + d
# [17 27], with grouping ((a + b) + [10 20]) + d.

@: arr0 [1 2]
@: arr1 [10 20]
@: arr2 [100 200]
@: totals arr0 + arr1 + arr2
# [111 222]
```

`[arr2]` contains one whole arr2 reference. It does not flatten or copy arr2, request broadcasting, or add a dimensional claim to its element. An operation consuming it receives the actual element under its own contract. A typed rectangle `[2][2]int: [1 2; 3 4]` instead constructs one flat backing and validates equal row lengths. Both `[1 2; 3 4]` and `[[1 2] [3 4]]` are admitted row forms in that typed constructor.

Construction or intermediate storage may be removed only when identity, lifetime, scalar types, demand and failure order remain unchanged. Merely seeing an inline Array does not authorize reassociation, FMA or eager execution of later occurrences.

<a id="depth"></a>
<a id="dotted"></a>
## 3. Depth and held actuals

`.(expression)op` supplies **depth of one external traversal**. Positive d visits d outer logical axes; explicit zero means maximum depth. For an Array of rank K, d>0 requires d≤K and leaves K−d axes in each cell. Depth zero reaches scalar elements of that Array. Original scalar or explicitly held actuals do not acquire axes. The number is not cell rank and is not a reduction-axis selector.

A custom operand receives the declared int depth and may define its own meaning. Standard Map restrictions, including nonnegativity and depth>K, apply only when that profile is selected, not globally to every method.

Absent depth remains absent and selects the method's default. Ordinary arithmetic defaults to maximum pointwise application. A whole matrix method without a modifier gets its whole inputs; explicit zero instead requests maximum depth. The two cases must not be globally conflated.

```lmx
@: cells A .(0)* B
# [5 12; 21 32]
@: explicitCells A .(2)* B
# [5 12; 21 32]
@: rowDots A .(1)[*] B
# [17 53]
@: wholeProduct A [*] B
# [19 22; 43 50]
```

These examples use the rank-two A and B above. After selecting cells, the wrapper calls the **base handler without re-entering automatic Map**. `A .(1)* B` therefore does not silently map the row inputs again or reinterpret them as dot products: a scalar base `*` diagnoses them unless it has a separately admitted whole-cell contract. `A .(3)* B` fails because three outer axes do not exist. `A .(0)[*] B` likewise needs a base-product contract accepting scalar cells; absence of the modifier is the normal whole-product form.

The explicit depth expression is obtained once on demand in its original context, not during grouping, priority calculation or candidate inspection. Common transport is left/depth/right, with missing left preserved. The operand itself establishes any prefix/infix equivalence.

`$x` or `$(expression)` holds an actual whole for the current traversal, obtaining it once without copying. For Z `(rows,cols)` and bias `(cols)`, `Z .(1)rowAdd $bias` passes a row and the whole bias. A declared rowAdd can explicitly write ordinary `+` in its body; the wrapper does not introduce that second Map automatically. With depth 0 it passes one Z element and the whole bias, never hidden bias[j].

Frames of iterated Arrays agree exactly. Zero frame extents call no kernels. An empty frame tuple means one call. DATA, TYPE, RAW, NAME, PLACE and void consumers retain their declared roles. Internal axis rules of `.(d)[op ...]` address the remaining cell. See [operation depth](OPERATOR_DEPTH.en.md) for the complete contract.

## 4. General indexed operations and matrix contracts

`[op rules]` belongs to one common family. Its ordinary LMX configuration selects the scalar/cell kernel, optional reducer, initial state, result builder and numeric/access policies. These are structures and callable references, not a new options registry or an implicit implementation of algorithms.

| Rule | Meaning |
| --- | --- |
| `i:j` | Equal input coordinates, reduced together; equal extents required |
| `i=j` | Shared retained coordinate; equal extents, no singleton expansion |
| `i*j` | Independent coordinates merged into extent `dim(A,i)*dim(B,j)` |
| Unmentioned axis | Free independent output axis |
| `-> positions` | Permutation of the canonical output-axis list |

An input axis appears in at most one relation. Canonical output order is retained `=` axes in rule order, composite `*` axes in rule order, free A axes, then free B axes. Every output position appears exactly once in a permutation. Explicit rules disable automatic batch inference. Options alone do not create a rule list.

```lmx
@: matrix A [*] B
@: outer A [* ()] B
@: sums A [+ ()] B
@: shortest A [+ 1:0; reduce := min] B
# [6 7; 8 9]
```

Absent rules select the named method's default; present empty rules select no links. Therefore `A [*] B` is automatic matrix multiplication and `A [* ()] B` is an outer product. `A [+ ()] B` combines all independent pairs by addition. Binary contraction uses a separately chosen reducer; `+` alone does not mean min-plus. With no reduced axes, default reducer/state configuration is unused and no identity is requested; an explicitly supplied inappropriate reduce actual is diagnosed.

Unary arithmetic is distinct from the geometry-only `[*]` forms:

```lmx
[2][3]int: M [1 2 3; 4 5 6]
@: rowSums [+ 1:] M
# [6 15]
@: rowProducts [* 1:] M
# [6 120]
@: traceValue [+ 0:1] A
# 5
@: diagonalProduct [* 0:1] A
# 4
@: diagonal [* 0=1] A
# [1 4]
@: transposed [* -> 1, 0] M
# [1 4; 2 5; 3 6]
```

The numeric contracts preserve separate kernel output, accumulator state and final result types. Identity is a neutral of the state algebra; an arbitrary seed is not renamed identity. A first-item reduction needs its admitted conversion into state. Each mutable accumulator is independent. Empty identity or seed results pass through the selected finish method. Min/max retain the first selected typed record on ties. Parallelization needs actual algebraic and numerical permission, including overflow, NaN, signed zero and rounding policies.

### 4.1. Whole matrix operations

| Operation | Whole-object contract |
| --- | --- |
| `[+]`, `[-]` | Matrix addition/subtraction; unary `[-]` gives the opposite matrix |
| `[*]` | Automatic vector/matrix product or explicit indexed contraction |
| `[\]` | Left solve `A X = B` |
| `[/]` | Right solve `X B = A` |
| `[**]` | Integer matrix power under its numerical contract |
| `[=]`, `[!=]` | One whole-matrix equality/inequality result |
| `inv`, `transpose`, `adjoint` | Inverse, transpose, conjugate transpose |
| `det`, `trace`, `rank`, `norm`, `cond` | Whole-object characteristics with declared conventions |
| `lu`, `qr`, `cholesky`, `eig`, `svd`, `schur` | Structured factorizations and spectral results |
| `pinv`, `nullspace`, `leastSquares`, `kron` | Explicit generalized inverse, kernel basis, least squares and Kronecker product |
| `math\linear\exp`, `log`, `sqrt`, `sin`, `cos` | Matrix functions in the stated namespace |

No inverse is inferred from scalar `/`, `~` or `!`. Solve is not an indexed reduction of scalar divisions. Real/complex domains, rectangular or singular inputs, tolerance, empty shapes, branches, mutation and failure contracts are specified individually in [the full matrix chapter](TENSOR_EXPRESSIONS.md#matrix-contracts). The complete 529-entry operation catalogue is in the same normative document; catalogued or future-imported capability does not imply a completed implementation.

<a id="assignment"></a>
## 5. Assignment, slices and overlap

`destination := source` retains ordinary pointwise assignment. The destination is resolved once. Array shapes match exactly; an admitted scalar may fill its selected places. RHS values and all target admissions are established before stores. A group of places is not copied into unrelated variables:

```lmx
int: a 1
int: b 2
int: c 3
(a b c) := (b c a)
# a=2, b=3, c=1
```

`(a b c) := copy(d)` uses the established group/field-stream consumer; extra parentheses are not required. No post-call global flattening pass is added. A ready Array destination retains its count, shape and identity. A declared reference PLACE keeps its separate ordinary reference-assignment admission; real row/plane regions do not have fictitious pointer slots to rebind.

`slice .: source` broadcasts the RHS to the already selected destination shape. Align source axes to the right, pad missing leading axes with one, and require each source extent to equal its target extent or be one. Extent 1 may expand to zero; extent zero cannot expand to a positive length. The destination is not resized.

```lmx
[2][3]int: matrix [0 0 0; 0 0 0]
[3]int: row [10 20 30]
[2][1]int: column [100; 200]

matrix[:][:] .: row
# [10 20 30; 10 20 30]
matrix[:][:] .: column
# [100 100 100; 200 200 200]
```

`matrix[:][:] := row` is a shape error. `matrix[:][:] .: [1 2]` is a broadcast error. A flat `matrix[:]` has one selected axis; chained `matrix[:][:]` retains two selected axes. The PLACE slice's shape, not its punctuation alone, determines broadcasting.

### Depth on slice assignment

`.(N).:` keeps the name **depth**; rank is the number of axes in the resulting target slice. For `(2,3,4)`, positive depth 1 selects `(3,4)`, depth 2 selects `(4)`, and zero means maximum and individual places. Its PLACE profile first prepares one RHS broadcast map to the **complete original target shape**. Depth then controls traversal granularity over those prepared places. It does not run generic exact-frame VALUE Map on raw RHS shapes. Thus RHS `(4)` is admitted for `(2,3,4)` at depth 0, 1 or 2; shape admission and the assignment map are unchanged. Prepared scalar places at depth zero are not rejected as non-slices. No extra ban on broadcasting inside a cell is introduced. All needed RHS values across the entire frame are retained before the first store.

Both assignment contracts share preparation, snapshot, admission and store. Overlap uses pre-write RHS values; broadcasting need not materialize a repeated destination-sized RHS. Duplicate physical target addresses require an explicitly supported deterministic scatter/reduce rule, otherwise they are rejected. Compound updates resolve the target once, compute with the corresponding base operation, then reuse this writer. Prefix/postfix updates keep their ordinary result identity and pre-update snapshot rules.

A VALUE slice retains its ordinary fresh-selection contract unless a View is explicitly selected. A PLACE slice supplies actual cells for this operation. Range resizing remains the separate replace/splice contract. Negative direct Array indexes remain invalid; use pointer arithmetic for a valid relative-address task. [Slices and ternary](TERNARY_AND_SLICES.en.md) define defaults and checked/native boundaries.

## 6. Minimal fusion and implementation boundary

```lmx
@: scores fuse(2 * left + right * right)
@: mask scores >= limit
return: compress(scores; mask)
```

`fuse` consumes RAW Expression. Its initial guarantee covers Scalar and Map→Map with a fresh final result and no materialized intermediate Array results. Supported input access maps, actual types, numerical boundaries, demand and observable failure order are preserved. Matrix products, reductions, arbitrary callbacks, streaming stores and all View maps are not automatically admitted.

`destination := fuse(expression)` and `slice .: fuse(expression)` first obtain the final fresh result, then perform ordinary assignment. A late arithmetic failure cannot silently leave a prefix written merely because fuse appears on the RHS. [Fusion](FUSION.en.md) defines the exact minimum and unsupported-plan diagnostics.

<a id="implementation"></a>
Preparation selects actual methods, roles, complete result requirements, dimensions and access maps. Ordinary structures/templates and copy/merge carry these settings and parent context. The executor still has to read and implement them. The graph is live; there is no expanded program clone, alternate namespace or eager evaluation during candidate discovery.

Malformed depth, unavailable required dimensions, incompatible shapes, invalid axis rules and unsupported plans are translator diagnostics when known, otherwise interpreter diagnostics at the reached operation. User expressions, scalar methods and external library failures retain their existing throws contracts. Error lists are copied from actual base methods, not fictitious dotted aliases.

The [host contract model](tools/array_expression_reference.py) and [tests](tools/test_array_expression_reference.py) check selected contracts; they are not a production LMX implementation. Parser, translator and runtime acceptance remains **NOT_RUN** until exercised by project tools. Numeric acceleration or imported library support must preserve the complete selected contract.
