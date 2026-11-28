# Common Array and indexed source algorithms — tensor contract v0.4

This document specifies the reusable bodies in
[src/array_expression_ops.lmx](src/array_expression_ops.lmx), the ordinary contexts
consumed by them, and the remaining production integration. These source bodies
are not evidence that the production parser, translator, interpreter, optimizer
or C adapters have executed the new forms. **LMX runtime: NOT_RUN.**

## One parser and one Expression grouping implementation

The production target is one common parser, with the `[]` helper as part of that
parser, and one common implementation of Expression grouping. Every source
entry uses the same parser code. Source-built and directly supplied graphs use
the same grouping code; the translator, interpreter and native emitter consume
its operation/stream plan. Built-in and custom operands use the same ordinary
priority and method metadata through that code.

Production integration must remove the replaced precedence tables, independent
grouping algorithms and special regrouping paths. Keeping several algorithms
behind adapters, translating between their priority scales or retaining a
compatibility fallback does not satisfy this architecture. Application and ABI
adapters may package the prepared actuals and invoke the selected method; they
do not parse source or group expressions again.

## One method, ordinary structures, several applicable forms

All profiles, numeric policies, access plans, state factories and capabilities
are ordinary LMX structures. They contain actual method references and values,
use existing parent and dynamic binding, and compose with copy/merge. An inventory
JSON is build-time documentation, not an operator-name registry. No per-operator
loop is generated into the public library.

| Layer | Shared source | Prepared information |
| --- | --- | --- |
| Ordinary elementwise operations | `FxArrayElementwise` | Actual inputs, scalar kernel, access/read/write, final result layout |
| Explicit traversal depth | `FxArrayDepth` | Zero = all logical axes; positive d = d leading axes, identical outer frames, selected whole cells, full result requirement |
| Explicit indexed operations | `FxArrayIndexed` | Coordinate maps, pair/unary term, independent reducer and state contract |
| Automatic `[*]` | `FxArrayProduct` → `FxArrayIndexed` | Vector/matrix/batch auto-axis rules, without implicit broadcast |
| Integer `[**]` | `FxMatrixPower` | Admitted square matrix, machine int exponent, real identity/copy/solve/multiply methods and one numeric context |
| `:=` and slice `.:` | `FxArrayAssignPrepared` | Real places, captured RHS, RHS index map, admission and store |
| Minimal `fuse` | `FxFusePrepared` → `FxArrayBuild` | Confirmed Scalar/Map plan, one expression template, fresh final result |
| All output traversals | `FxArrayExpressionFill` | Output count, one callback and one write contract |

`*`, `+`, comparisons and other ordinary operations preserve their elementwise
Array behavior. `[*]` means matrix/tensor multiplication. `[/]` means solve
`X B = A`, `[\]` means solve `A X = B`; their explicit indexed `/` profile is
ordinary pairwise division under the selected axis plan, not a solver. Whole
factorizations and matrix functions retain their own contracts and do not become
scalar kernels just because they have square-bracket spelling.

The full matrix family includes `[+]`, unary/binary `[-]`, `[*]`, `[/]`, `[\]`,
`[**]`, `[=]`, `[!=]`, and canonical `math\linear` functions such as inv,
transpose, adjoint, det, trace, rank, norm, lu, qr, cholesky, eig, svd, schur,
pinv, nullspace, cond, kron, leastSquares, exp, log, sqrt, sin and cos. Their
contracts are described in the Array specification; this source module does not
claim to implement numerical backends for all of them. A public function should
reuse the existing applicable implementation, not introduce a historical alias.

## Optional depth and actual values

The common operand DATA order is left, depth, right. Neither left nor depth is
made required by the shared template; right is a present sequence even when
empty. `FxOperandValueEngine` inspects slot 1 without demand. If absent, the
original method contract applies. Ordinary arithmetic is already fully
pointwise; whole `[op]` and other whole consumers keep their own meanings.

These Array traversal rules belong to the selected common Map profile, not to
generic operand transport. The common middle formal remains int; transport
admits that type and passes the optional named depth actual. A custom method
may interpret it according to its own contract, including a negative integer.
Unless it selects common Map, transport imposes no Array traversal, maximum
meaning for zero, nonnegative-depth limit or depth-versus-rank admission.

In this common Map profile, explicit depth zero means maximum traversal of the actual logical Array axes.
Explicit positive d consumes exactly d leading axes, passing the remaining cell
to the selected base entry. Positive d above an iterated Array rank is diagnosed.
A rank-2 Array therefore reaches scalar cells at depth 0 or 2 and row cells at
1. Frames of iterated Arrays match exactly. Original scalar and held actuals add
no axes. Empty frames execute no method or sample callback.

`base` is the direct selected method entry, with its actual owner and roles. The
same invocation must not start automatic Map again after cells have been chosen.
For example scalar-only `*` rejects row cells selected by depth 1 unless a
compatible row contract is declared; it does not silently map them again or use
matrix multiplication. `.(1)[*]` invokes the vector matmul contract on row pairs.
Nested explicit operations written inside the method retain their own contracts.

The depth expression is demanded once in its original context. A distant field
also called depth does not make a missing modifier present. The source's own
logical input named depth is not the wrapper control actual. DATA/TYPE/RAW/NAME/
PLACE/callable roles remain declared by the receiving operation.

Input entries contain iterate and value. `$x` holds one actual whole for the
current outer traversal and does not make it immutable. A length-one Array
remains an Array. Structure/[]@ and text are admitted by actual types; stored
record slots yield typed values, while real reference values remain references.
No blind recursive pointer traversal or implicit field-name join occurs.

## Indexed plans and independent accumulation

Missing `axisRules` selects the whole/automatic profile. A present empty ordinary
structure selects an outer plan. Explicit rules have these meanings:

| Rule | Coordinates | Effect |
| --- | --- | --- |
| `i:j` | Equal-length linked coordinates | Reduce over the shared coordinate |
| `i=j` | Equal-length linked coordinates | Keep one output coordinate, without reduction |
| `i*j` | Independent coordinates | Merge into `a_i * dim(B,j) + b_j` |
| Unmentioned axis | Independent coordinate | Retain it as a free output axis |

Output order is matched axes, combined axes, free A axes, free B axes. Each group
retains its specified order. `->` is a full permutation of that canonical list.
Explicit links disable automatic extra batch links. The `[]` helper of the one
common parser builds these ordinary DATA records from the parsed graph. Its
production integration remains to be implemented and tested. The source
algorithms never reparse a quoted identifier or use strings as operator dispatch.

The [complete bracket-subparser contract](../../BRACKET_SUBPARSER.ru.md) applies
at an adjacent `[op` opener, without a space between `[` and the operation
designator, in a context that admits an operation. The same helper also handles
Python-style `value[start:stop:step]` index syntax. TYPE prefixes and ordinary
VALUE square groups remain contexts of the same common parser; `[ op]` is not
silently turned into the compact operation form.

The helper recognizes only its own square grammar and separators at the current
level. Whenever it identifies the start of any expression, it calls the main
parser at that exact source position. The main parser consumes the complete
expression with its nested regions and returns its ordinary graph and the next
position at the helper's structural boundary. The helper resumes only at that
returned position; it does not first search for the expression's end or for a
closing bracket.

The same delegation is mandatory for `{...}`: the helper passes the opening `{`
to the main parser, ignores the fragment's contents itself, and uses the returned
graph and position after the matching `}`. It neither scans ahead for `}`, counts
nested braces, nor interprets internal punctuation as axis or slice grammar.
If the fragment belongs to a larger delegated expression, the main parser also
consumes that expression up to the caller's boundary. Parenthesized groups,
nested square forms, strings, exact names and comments use that same parser's
normal rules; the helper contains no second expression or protected-region
scanner and does not discard the returned graph.

After consuming its own `]`, the helper returns the constructed graph and the
position immediately after that `]`. The following suffix, operation or base
TYPE remains unconsumed for the common parser. A missing closing bracket is a
source error. This cursor-return contract, including full conditional slice
bounds and context-sensitive `::`, is part of production acceptance.

`term(context; outputIndex; reductionIndex)` obtains the next actual value. In a
binary indexed plan it calls the selected kernel on mapped actuals; in a unary
reduction it reads one reached input. This ordinary callback also supports a
map-before-reduce plan without storing a temporary Array. No reduced axes means
one term and **no** reducer, initializer or artificial one-element fold.

A reduction context contains actual references to `start`, `mapToState`, `reduce`,
`finish`, `empty` and, when explicitly enabled, `stop`. It is complete before
execution. `start` produces a fresh `FxArrayFoldState` for each output coordinate:
`present` distinguishes an absent state from every legitimate numeric/reference
value. The state value has its declared S type; the term has Z and finish returns
R. `first` requires admission/mapToState Z→S. Seed/identity/factory starts must
create the required independent mutable state. An identity state on an empty
input still passes through finish; a complete reduction can return any declared R.

`FxArrayIndexedCell` checks `stop` **before obtaining the next term**, so a reached
short-circuit state does not execute later kernels or raise their errors. Such
stopping requires the declared demand/effect contract. An absorbing value alone
is not permission to omit a callback. Input coordinates follow the declared
lexicographic order, last axis fastest. Default numerical policy forbids
reassociation, automatic FMA, precision changes and conversion of all values to
double. IEEE flags, NaN, signed zero, overflow and first-record tie rules follow
the chosen methods.

Unary `[+ axis:]` sums and `[* axis:]` multiplies. Unary `[+ i:j]` sums a diagonal;
`[* i:j]` multiplies it. Non-reducing `[* -> order]` and `[* i=j]` retain geometric
permutation/diagonal contracts. Pair kernel and reducer are independent: product
uses `*`/`+`, min-plus uses `+`/`min`, Boolean product uses `&`/`|`, GF(2) uses
`&`/`^` on the corresponding admitted domain. No pair is guessed from a symbol.

## Shape, access context and allocation

The primary Array header remains parent/length/storage. Full TypeRef is a direct
reference to the canonical type-description Structure. Rank and declared axis
lengths belong to that type. Capacity is instance reserve, independent of shape;
capacity=length requires no second reserve descriptor. Mutable access details do
not mutate a canonical type or add a permanent user-data field to every Array.

An ordinary context reachable through parent can supply source ownership,
offset, strides, index maps, bounds, lifetime, read/write access, or boundary
policy. This supports affine views, permutation, diagonal, slice, reverse,
broadcastTo, window and non-affine access without a new primitive object kind.
A source-dependent saved view retains its source under the ordinary lifetime
contract. Temporary fusion plans need not publish persistent view objects.
Aliasing, overlapping windows and repeated addresses restrict writing.

`allocate(context; layout)` uses the existing full-type constructor. It directly
constructs a valid shaped result with its complete canonical TypeRef. An empty
invalid `[2][3]int` followed by resize, hidden retag or first-element type probe
is not acceptable. A dense result shape is frame + resultCellShape. Structural
assembly uses ordinary references and preserves heterogeneous results; there is
no distinct arrays-of-arrays primitive. `FxArrayResultTree` is only the shared
allocation adapter name, not a requirement to create a physical tree of rows.

## Assignment and minimal fuse

Both assignments capture the reached RHS once, resolve real target places,
complete all admissions, and then commit writes. `:=` uses the ordinary matching
shape/scalar contract. `.:` applies explicit right-aligned broadcasting to an
already selected slice; its readRhs plan repeats captured values without
reevaluating the source. Assignment does not resize its destination. Overlap and
permutation retain snapshot semantics. A target that maps several writes to the
same place requires an explicitly compatible store contract; no silent scatter
policy is guessed.

The minimal fuse capability supports confirmed Scalar/Map plans with a fresh
result and no intermediate Array results inside the accepted expression. Compact
access context, scalar state and the final result are allowed. This is not a
promise of no RAM access, register-only computation or universal speedup.

`destination := fuse(expr)` and `slice .: fuse(expr)` obtain that final result
before ordinary assignment. No source entry in this module implements implicit
streaming stores with partial writes. Reduce, contraction epilogues, in-place
updates, effects, general callbacks, sort, FFT and solve require separately
implemented and declared capabilities. Unsupported plans produce a translator/
interpreter diagnostic, not hidden intermediate materialization.

## Remaining production work and validation boundary

PD01 prepares ordinary frame/access/result contexts; it does not contain a
second opaque traversal. Array construction and scalar/admission methods are
existing integration boundaries. The source methods above provide the common
loops and calls once the checked contexts exist. The `[]` component of the one
parser, the sole Expression grouper, production role binding, dependent result
ABI, allocation integration and native backend support must be implemented and
tested in the compiler/runtime project. Acceptance includes removal of the
replaced parser/grouping branches and duplicate precedence tables, plus evidence
that every source, interpreter and native path uses the common code.

The C catalogue remains a future import task: determine canonical LMX names,
real prototypes, TYPE/VALUE conversion, errors and ownership, then implement
VALUE adapters. Reconcile existing identity/select/minMax/rank/sign/polar
contracts before publication; do not declare C surface entries ready by name.
Source inventory and reference-plan checks here do not replace that acceptance.

## Shared integer matrix power

`FxMatrixPower\power(context; matrix; exponent)` in
[src/array_expression_ops.lmx](src/array_expression_ops.lmx) is the one binary
power loop. The exponent is the admitted machine `int` of this entry; a larger
integer requires a separately admitted exponent profile, never silent
narrowing. Before entry, the common operation preparation establishes square
shape, actual input and result types, exponent domain and the chosen numeric
profile. This prepared helper does not replace those admissions.

The ordinary `context` supplies **actual method references**, with the same
owner, parent and reachable numeric settings as the selected operations:

| Field | Arguments | Required result and behavior |
| --- | --- | --- |
| `identity` | context, matrix | Fresh square identity with the declared result type, including 0×0; does not inspect scalar values merely to decide exponent zero |
| `copyValue` | context, matrix | Fresh VALUE copy preserving shape, actual type and elements; returning the original reference is invalid |
| `solve` | context, matrix, identity | One solve of `matrix X = identity` in the selected inversion profile; fresh output; preserves both inputs |
| `multiply` | context, left, right | The same admitted whole `[*]` contract, precision, reduction order and result type; fresh output even when inputs alias |

These are provider obligations, not declarations that backend bridges already
exist. A provider must be implemented and its contracts admitted before the
public `[**]` entry uses it. The source uses existing `FxApply\apply`; a failure
keeps that common callable boundary and never fabricates `ok=1` or substitutes
an identity after a numerical error. An optimized backend may replace the
computation only under the numeric/effect contract established for the call.

The zero case calls only `identity`; the one case calls only `copyValue`.
A negative exponent constructs one identity and solves once, then reuses the
same binary order as the positive magnitude. The signed quotient variable
is repeatedly divided by two with the C99 integer profile's truncation toward
zero; oddness is `q % 2 != 0`. No step negates the exponent or evaluates its
absolute value, so the minimum representable machine int is supported without
signed overflow. The existing
[integer helpers](src/coreStandardNumeric.lmx) use the same truncating
division profile and explicitly distinguish it from their floor `divMod`.

The first selected power initializes the accumulator directly. There is no
extra `I [*] A`, and no unused final squaring. For a nonzero magnitude with b
binary digits and k set bits, the loop performs `b-1` squarings and `k-1`
accumulator multiplications; negative powers additionally perform the one
solve. This count describes the selected evaluation order, not permission to
reassociate approximate arithmetic. All paths preserve the source matrix.
For exponent one the explicit copy also preserves ordinary VALUE freshness.

A genuine LMX integration call is:

```lmx
PreparedMatrixPower:
    @: context
    @: matrix
    int: exponent
    return: @
    run:
        throws: copy(FxMatrixPower\power\throws)
        return: FxMatrixPower\power(context; matrix; exponent)
```

The body of the algorithm is stored only in the linked source. Canonical
public examples are in
[integer_matrix_power.lm3](../../examples/array_expressions/integer_matrix_power.lm3).
Static source checks and host-side algorithm checks, where reported, are not
execution by the production LMX parser, translator or runtime.
