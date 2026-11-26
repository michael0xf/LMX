# Operator depth: one dot and an ordinary parenthesized expression

Revision 2026-11-26. This is the common depth input of an operation, including
custom operands. It selects a logical depth using the retained dimensions of
a flat Array. It is not indentation or pointer indirection, and introduces no
new kind of function or Structure.

<a id="syntax"></a>
## 1. Written forms

| Expression form | Supplied depth |
| --- | --- |
| `p1 + p2` | 0: the base operation consumes the outer values as wholes |
| `p1 .+ p2` | 1: the standard value profile descends one logical dimension |
| `p1 .(2)+ p2` | 2 |
| `p1 .(10)+ p2` | 10 |
| `p1 .(0)+ p2` | 0, explicitly; the same operation as the undotted form |
| `p1 .(1)+ p2` | 1, explicitly; the same operation as the single-dot form |
| `p1 .(layers + 1)myOperator p2` | The result of the ordinary depth expression |

**The modifier has only one dot.** Custom depths are written in parentheses. A run of dots is not an alternative depth notation.

The material inside `.(…)` is parsed by the **same general parser** as other
expressions. It may contain a name, a call or an expression such as `1 + 9`.
No decimal-only scanner, source-text evaluator or second expression grammar
is introduced. The resulting graph occurrence retains its original context.

**A dot immediately followed by `(` always starts an operator/function
modifier.** In the ordinary lexical context, `.(` is recognized before a
decimal point or a dotted layout zone. The numeric scanner must leave this
dot unconsumed. Thus `1.(3)+2.(2)+3` has the same boundaries as
`1 .(3)+ 2 .(2)+ 3` and yields 6 under the existing scalar contract.

After `.(` the common P0 parses an ordinary expression up to the matching
`)`; no second depth-expression grammar is introduced. The grouper receives
the resulting graph occurrence, not source text. Strings, comments and exact
identifiers retain their shielding. Other numeric rules remain: `1 .+ 2`
needs its ordinary token boundary, while `.(` is never a decimal point,
even when adjacent to a preceding number.

<a id="abi"></a>
## 2. Operand template and method entry

The first three inputs are **left, depth, right**, in that order:

```lmx
operand_template:
    @: left
    int: depth
    @[]: right
    const: int: PASS_ARGS_AS_IS
    const: int: PRIORITY
```

All five named fields belong to the actual DATA description. `depth` is a
normal numeric input, not another constant property like PRIORITY. The
expression form supplies 0, 1 or the accepted result of the parenthesized
expression. The input must be an admitted nonnegative integer; malformed
structure, failures while evaluating the expression and ordinary input
admission retain their normal diagnostics. An invalid ready depth is a translator diagnostic when statically known,
otherwise an interpreter diagnostic when reached. It is not a catchable
LMX exception or an extra entry in throws.

This changes the operand transport layout: frame positions 0/1/2 contain
left/depth/right. It does **not** insert depth into the Array of right
arguments. The two existing placements remain: no left atom, or one left
atom. A missing left remains missing. Prefix equivalence is still decided
inside the operation method, not by moving the first right value into left.

PASS_ARGS_AS_IS still governs left/right consumption. For a RAW operation
those occurrences remain RAW; when the operation is actually invoked,
depth is a ready numeric input. Discovery reads the declared input type and
the existing ready mode/priority; it does not evaluate a computed depth.

A custom method receives the requested number before any optional
operation-specific traversal. For example, this method reports the supplied
depth and does not automatically map over its arguments:

```lmx
DepthProbe:
    @: left
    int: depth
    @[]: right
    const: int: PASS_ARGS_AS_IS 1
    const: int: PRIORITY sys\priority("+")
    return: int
    read:
        return: depth

@: myOperator DepthProbe\read
int: observed 10 .(1 + 1)myOperator 20
```

The expected observed value is 2. This is a specification example;
production parser/runtime execution is recorded separately.

<a id="receiver"></a>
## 3. Structural receiver form and exact names

The structural form uses the **base name**, with the same named input
`depth`. Dots and the parenthesized expression are not inserted into the name
inside backticks. In a system value-receiver profile, for example:

```lmx
@: result `*`(a; b; depth := 2)
```

That receiver profile consumes its ordinary value arguments plus the
declared named depth input. This is not a positional call of the three-slot
operand ABI. For a custom method exposing that ABI directly, name its
left/depth/right inputs explicitly.

Backticks retain their usual exact-identifier semantics. A quoted name
containing a dot remains that literal name if a user declares it; quoting
does not decode it as a depth modifier. The standard operation does not
publish a separate dot-prefixed callable alias. Its throws reference uses
the base operation, for example `` `*`\throws ``.

Depth is not a globally intercepted keyword in every function call. It
belongs to the selected operation's declared input. The original function
wrapped by `asOperand` keeps all its own logical arguments, including a
user argument that happens to be named depth; the wrapper's control input
has a different owner and is not inserted into those arguments.

<a id="evaluation"></a>
## 4. Evaluation and the common traversal

The depth expression is obtained **once when that operation occurrence is
demanded**, in its original source/caller context and under ordinary
argument-order rules. Grouping, priority inspection and candidate discovery
do not run it. A skipped logical or conditional branch does not run its
computed depth either. The base operation's precedence and associativity
do not depend on the resulting number.

For the standard value profile, one shared traversal applies:

```text
applyDepth(base, acceptedDepth, actuals, output):
    if acceptedDepth == 0 or every original consumed actual is scalar:
        return base(actuals) through the admitted result contract
    level = prepareNextLogicalDimension(actuals)
    diagnoseMissingRequiredDimensions(level, originalScalarInputs)
    validateMatchingSelectedShapes(level)
    for each position on this dimension:
        values = sameStorageSlicesOrOriginalScalars(level, position)
        applyDepth(base, acceptedDepth - 1, values, output.at(position))
    publish the result with its full shape and result requirement
```

The dimensions are read from [external Array metadata beside capacity](ARRAY_STORAGE.en.md#side-metadata).
For a flat rectangular Array, descending one dimension selects a logical
slice of the same backing storage; it does not allocate a row Structure.
Axis order is the declared order, outermost first. Once the requested
number of dimensions has been consumed, the base operation receives the
remaining whole values. Output shape follows that operation's actual
result: a row product can return a scalar, while a row sum returns a row.
One flat output backing is used when the admitted result is rectangular.
No per-row graph or intermediate row objects are required. The concrete
LMX executor may linearize the selected dimensions into one loop over a
checked shape/address plan; this is the same traversal, not a second algorithm.

No scalar leaf is probed to discover a type. Void remains void. Array
inputs must provide the requested dimensions and compatible selected
shapes. Original scalar inputs may be repeated; an exhausted Array cannot
silently become a scalar broadcast while more dimensions are required.
All-original-scalar inputs are fixed points. A singleton Array is still an
Array. Invalid depth/shape is a translator/interpreter diagnostic. Empty
inputs retain their complete shape and type without probing a first item.

For two **flat rank-2 Arrays** p1 and p2, with retained shape `(2,2)` and
row-major backing `[1 2 3 4]` and `[10 20 30 40]`:

| Operation | Base operation receives | Result |
| --- | --- | --- |
| `p1 * p2` | Two whole matrices | Shape `(2,2)`, backing `[70 100 150 220]` |
| `p1 .* p2` | Each pair of logical rows | Shape `(2)`, values `[50 250]` |
| `p1 .(2)* p2` | Each pair of scalar coordinates | Shape `(2,2)`, backing `[10 40 90 160]` |

Thus scalar coordinatewise multiplication of rank N uses depth N. A single
dot is exactly depth 1; it does not silently change its numeric meaning with
rank. The former claim that every flat rank has only one usable depth level
is replaced by this shape-aware rule. The same mechanism applies to all
operations, without a multiplication-specific depth exception.

An ordinary Structure remains `@[]`. A field may refer to another ordinary
Structure; that introduces no separate “array of arrays” entity. The path
`struct[i]\[j]` is the index spelling of `struct\struct2\field` when i and j
select those fields; `struct[i]\[j]\[k]` spells `struct\struct2\field[k]`.
Such paths use the common access mechanism. Flat Array dimensions come
from metadata, not from guessing the shape of a referenced graph.

Depth 0 means the base operation's existing whole-value contract; it does
not promise that every outer container is valid for that contract.

Custom, RAW, DATA, TYPE and PLACE consumers retain their own roles and
semantics. They receive depth through the same transport but are not
blindly rewritten into a VALUE map. A profile with no meaning for a
nonzero depth reports an explicit translator/interpreter diagnostic instead of ignoring it.
The value adapter shares the traversal and preserves the actual dependent
result requirement; it must not promise scalar R for an Array result or
replace every result with an untyped wrapper.

<a id="assignment"></a>
## 5. Assignment family

The established assignment spellings remain:

| Form | Canonical operation | Depth |
| --- | --- | --- |
| `target := source` | `:=` | 0 |
| `target .: source` | `:=` | 1 |
| `target .(n): source` | `:=` | accepted n |
| `target .(0): source` | `:=` | 0, whole-place assignment |

This is the surface-form table for the existing assignment family. A bare
colon is not turned into a new assignment receiver. The group planner,
one-left rule and argument adaptation acquire no assignment-specific
unwrapping pass. Structural calls use base `:=` and the named depth input;
the standard throws reference is `` `:=`\throws ``.

At positive depth, the destination traversal retains real PLACE identities.
For ordinary assignment, all required RHS values and target admissions are
prepared before the first store across the whole operation, not merely
before each child branch. This preserves overlapping permutations.
Whole-place depth 0 follows ordinary := admission and identity rules.
The explicit fused-output form retains its separately documented streaming
contract; increasing depth does not silently turn ordinary assignment into
streaming writes.

A logical row/plane PLACE in flat storage is an existing storage region,
not an independent reference slot. At the selected base depth, assigning
that PLACE writes an admitted block of the same remaining shape; it cannot
rebind a fictitious row reference. A real variable/reference PLACE at depth
0 keeps ordinary rebinding. For scalar fill of a rank-N Array, depth N
selects scalar cells. All region/cell admissions and RHS snapshots precede
the first write across the entire ordinary assignment.

Invalid depth, incompatible requested operand depths/shapes and an
ineligible `fuse(expression)` are language-preparation diagnostics: the
translator reports what it can determine, and the interpreter reports a
reached dynamic violation. These are not new user exception types or
wrapper failures. Real failures from evaluated user calls and selected
scalar operations keep their existing contracts.

## 6. Integration and examples

See [short examples of all depth forms](examples/operator_depth/README.md).

- [Array contracts and shared LMX bodies](ARRAY_EXPRESSIONS.en.md).
- [Fusion, eligibility and shape propagation](FUSION.en.md).
- [Structural discovery and operation forms](OPERATION_FORMS.md).
- [Assignment examples and expected refusals](examples/assignment_forms/README.md).
- [Expression depth transport reference](tools/operand_depth_reference.py).
- [Callable publication and exact result requirements](patterns/LMX_Fn_Receivers/PUBLICATION_CONTRACT.md).

The archive contains algorithms and independent contract models. Production
P0, translator/runtime publication and the dependent-result provider are
separate integration checks; no host model result is a production PASS.
