# Operation depth: one external traversal

The common modifier `.(expression)op` supplies **depth**, not cell rank. A positive d traverses d outer logical axes. **Explicit zero means maximum depth.** The Array's rank remains its number of axes, and `math\linear\rank` remains a mathematical operation. [Complete normative contract](TENSOR_EXPRESSIONS.md#operator-depth).

<a id="syntax"></a>
## 1. Syntax and default

| Form | Meaning |
| --- | --- |
| `A + B` | Ordinary arithmetic default: maximum elementwise traversal |
| `A .(0)+ B` | Explicit maximum depth |
| `A .(1)op B` | Traverse one outer axis, pass the remaining cells to op's base handler |
| `A .(d)op B` | Obtain one nonnegative integer from the ordinary expression d |
| `.(d)method(A; B)` | The same prefix modifier before the method designator |
| `A [*] B` | The whole/indexed product contract, without an external modifier |

There are no general `.op`, `..op` or `...op` abbreviations. `.:` is a dedicated slice-broadcast assignment, not depth-one `:=`; `.(d):` is not an assignment alias. Suffix `method.(d)(...)` is not introduced.

A dot immediately followed by `(` starts this modifier rather than a decimal fraction. Inner expressions use the common parser and retain source context. Strings, comments and quoted exact names retain shielding. Written boundaries are specified in the [bracket-subparser grammar](BRACKET_SUBPARSER.en.md). This documentation does not claim production parser/translator/runtime acceptance.

<a id="abi"></a>
## 2. Presence and common transport

The service parameter has the declared type int. The traversal rules in this chapter belong to **standard Map profiles**. A custom handler may interpret depth differently; unless it selects that Map profile, nonnegative-depth, depth>K and frame checks are not imposed globally. In particular an admitted negative int can be passed to such a custom method. This does not authorize an arbitrary non-int service argument.

Prepared actuals retain the order **left, depth, right**:

```lmx
ExpressionActuals:
    @: left
    int: depth
    []@: right
```

This is a DATA transport fragment, not a complete operand template. Missing left and missing depth stay absent. No uninitialized number is read, no universal default zero is inserted, and no separate depthPresent flag or numeric absence sentinel is introduced. Presence belongs to the prepared occurrence; an outer dynamic field named depth does not manufacture a written modifier.

An explicitly written depth expression is obtained once when demanded in its source context. The method can independently use dynamic data to choose its own default. For ordinary arithmetic the default is maximum elementwise traversal. For a whole `[op]`, reducer or DATA/TYPE/RAW consumer, absence retains that receiver's default. **Absence and explicit zero therefore remain distinct:** `A [*] B` receives whole matrices; `A .(0)[*] B` selects scalar cells and needs an actual base-product contract admitting them, otherwise it diagnoses the application.

The common operand template retains PASS_ARGS_AS_IS and PRIORITY. Candidate discovery examines roles and ready priority without executing depth or callbacks. There are still two ordinary placements: absent left or one left atom. Neither grouping nor binding moves right[0] into left; the operand establishes supported prefix/infix equivalence itself.

```lmx
DepthProbe:
    @: left
    int: depth
    []@: right
    const: int: PASS_ARGS_AS_IS 1
    const: int: PRIORITY sys\priority("+")
    required: depth
    return: int
    read:
        return: depth

@: myOperator DepthProbe\read
int: observed 10 .(1 + 1)myOperator 20
```

The service actual is 2. Original scalars have no missing Array axes to diagnose. This custom method reads the actual under its declared role; not every custom operand is forced into eager VALUE mapping. The LMX example is normative, production execution **NOT_RUN**.

<a id="receiver"></a>
## 3. Receiver form and exact names

```lmx
@: values `*`(A; B; depth := 0)
@: rowProducts `[*]`(A; B; depth := 1)
```

The receiver uses the base name and the same named depth actual; the second example supplies corresponding rows for rank-two A and B. This is its declared logical-argument interface, not a positional call to the three-field operand transport. A custom method exposing that transport directly names left/depth/right.

Backticks retain exact identifiers. Decoration does not become part of a standard callable name, nor does quoting decode a name. There are no historical dotted aliases. Errors are copied from actual base methods, for example ``copy(`*`\throws)``. A wrapper's service depth and an unrelated function's own argument have different owners; no blanket interception of every argument named depth is introduced.

<a id="evaluation"></a>
## 4. One traversal, then the selected base handler

For an iterated Array of rank K, positive d requires d≤K. The first d axes form the frame and the last K−d axes form each cell. Explicit zero selects all K axes. Unlike the former cell-rank proposal, d>K is an error, not clipping.

| Shape | depth | Cell | Frame |
| --- | ---: | --- | --- |
| `(2,3,4)` | 0 (maximum) | One element | `(2,3,4)` |
| `(2,3,4)` | 1 | `(3,4)` | `(2)` |
| `(2,3,4)` | 2 | `(4)` | `(2,3)` |
| `(2,3,4)` | 3 | One element | `(2,3,4)` |
| `(2,3,4)` | 4 | Diagnostic | — |

After selecting a cell, the common mechanism calls the selected **base handler without re-entering the same automatic Map wrapper**. Otherwise depth would be erased by recursive remapping. Unsupported remaining Array inputs cause an ordinary admission diagnostic; they are not silently descended into. Explicit operations written inside a user's body retain their normal contracts.

```lmx
[2][2]int: A [1 2; 3 4]
[2][2]int: B [5 6; 7 8]
@: cells A * B
# [5 12; 21 32]
@: sameCells A .(0)* B
# [5 12; 21 32]
@: explicitCells A .(2)* B
# [5 12; 21 32]
@: rows A .(1)[*] B
# [17 53]
@: product A [*] B
# [19 22; 43 50]
```

Here `A .(1)* B` does not secretly perform row dots or another automatic scalar Map: the scalar base `*` needs an explicit admission for Array cells, otherwise it diagnoses them. `A .(3)* B` fails because the inputs have only two axes. For a rank-three batch, depth 1 passes matrix cells to a whole matrix method. Axis rules inside `.(d)[op ...]` refer to the remaining cells, not removed frame axes.

Frames of iterated Arrays match exactly. Their cell shapes can differ if the handler admits them. Original scalars contribute no axes and can be repeated. `$x` or `$(expression)` holds an actual whole for this external traversal, obtaining it once on demand without copying. For Z `(rows,cols)` and bias `(cols)`, `Z .(1)rowAdd $bias` passes a row and the whole bias. A declared rowAdd may explicitly use ordinary `+` in its body; the wrapper itself does not add a hidden inner Map. Explicit zero would instead pass each element and the whole bias, never hidden bias[j].

An empty frame tuple means one call. A zero frame extent means no calls. Result requirements and empty assembly are declared rather than guessed by a trial invocation. Required dimensions come from the actual type and valid instance access context. Forgotten initializer rows are not recovered. Cells refer to the same flat backing with temporary parent context; escape requires retained context or materialization.

Structure `[]@` participates with actual typed records. References do not invent tensor axes, and `struct[i]\[j]` keeps its path meaning. Unsupported operations are diagnosed on actual elements, not by excluding a container class.

<a id="assignment"></a>
## 5. Special roles and writes

Ordinary `:=` is pointwise with exact Array shapes and admitted scalar fill. `.:` broadcasts RHS to a selected slice. An explicitly supported `.(d):=` selects real places through one external traversal and calls the base PLACE contract; it never turns a row region into a fictitious pointer slot.

The destination is resolved once. All required pre-write RHS values and target admissions are established before stores, including overlapping permutations:

```lmx
int: a 1
int: b 2
int: c 3
(a b c) := (b c a)
```

Ready Array targets retain count, shape and identity. Ordinary declared reference places keep their distinct reference-assignment admission. Compound and attached updates reuse base arithmetic and the common writer. Prefix/postfix names remain `++var`, `var++`, `--var`, `var--`; decoration creates no new exact names. DATA/TYPE/RAW/NAME/PLACE and void consumers keep their declared roles.

Initial fuse computes a fresh final result before outside assignment; it does not silently select streaming writes. Unsupported depth, unknown required axes, incompatible frames or unsupported methods are translator/interpreter diagnostics. Ordinary failures in depth expressions and actual methods retain their throws.

- [Array expressions](ARRAY_EXPRESSIONS.en.md).
- [Minimal fusion](FUSION.en.md).
- [Storage and context](ARRAY_STORAGE.en.md).
- [Operation forms](OPERATION_FORMS.md).
