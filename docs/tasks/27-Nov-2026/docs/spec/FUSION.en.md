# fuse: minimal Scalar and Map contract

`fuse(expression)` is a standard receiver consuming one **RAW Expression** through the common mechanism. It requires a supported plan without materializing the plan's intermediate Array results. The final result, scalar values and small access descriptions are allowed. It does not promise no RAM traffic, mandatory register allocation or faster elapsed time for every input.

The complete normative contract is [TENSOR_EXPRESSIONS.md](TENSOR_EXPRESSIONS.md#fuse-contract). Ordinary Array operations are elementwise. `.(d)op` specifies one outer traversal; explicit depth 0 means maximum depth and scalar cells. `[op ...]` retains its selected indexed/whole-object contract inside fuse. General `.op` abbreviations and depth-based callable aliases are not used.

## 1. Initial capability boundary

**The mandatory initial set is Scalar and Map→Map producing a fresh result.** Coordinates, actual scalar types, methods and result assembly must be supported. An ordinary settings Structure describes actual capabilities; a field does not implement an algorithm by itself.

| Plan | Initial contract |
| --- | --- |
| Scalar | Supported when the selected ordinary scalar computation is admitted |
| Map→Map | Supported for compatible coordinates, types, roles and order |
| Geometry read inside Map | Only an already implemented, validated access map |
| Map→Reduce | Requires a separate tested implementation; not initial |
| Contraction→Map | Requires a separate executor/epilogue; not initial |
| Contraction→Contraction | Requires a separately proven plan; not a mathematical impossibility |
| Streaming write into an existing target | Not initial; needs place, alias and failure contracts |
| General solve, factorization or matrix function | Not initial; needs its numerical/workspace contract |

```lmx
FuseMinimum:
    int: scalar 1
    int: map 1
    int: mapReduce 0
    int: contractionMap 0
    int: streamingWrite 0
    int: preserveScalarTypes 1
    int: preserveDemand 1
    int: reassociate 0
```

These are ordinary fields. Setting mapReduce to 1 does not create a reducer or authorize a backend that cannot fulfill the promise. Implementation references, supported type domains and policy data are ordinary LMX structures and methods, not a second metadata language.

```lmx
[2][3]int: A [1 2 3; 4 5 6]
[2][3]int: B [2 2 2; 2 2 2]
@: result fuse(A * B + 1)
# [3 5 7; 9 11 13]
```

No Array of component products is materialized. One final Array is permitted. The inner multiplication is ordinary pointwise `*`; a matrix product must be written `[*]` and does not enter the initial whitelist.

Structure `[]@` is not excluded by container type. The plan checks actual element types, kernel capability and output construction. A specific unsupported Structure-valued result or unknown callback produces a diagnostic for that plan.

## 2. Preparation, captures and demand

Preparation retains the live expression occurrences, actual requirements and access descriptions. It does not clone the program graph, rewrite source punctuation into a new namespace, or evaluate arbitrary bodies while inspecting candidates. The argument is RAW, so eager evaluation into intermediate Arrays before planning is not an implementation of fuse.

Demanded input values, held actuals, depth expressions and axis parameters are obtained once in their original contexts. A captured occurrence is not called again for every output coordinate. Two written occurrences remain two occurrences; no cache is keyed merely by their spelling or callable identity. An inactive branch does not obtain its parameters early.

```lmx
return: fuse(enabled ? A * B : C + bias())
```

The scalar condition selects the reached arm. The other arm performs no calls and no depth-expression evaluations. An Array of predicates does not become a scalar truth value by accident; a mask/select operation has its own contract.

A held `$value` remains one whole actual under the selected map. It does not synthesize indexes into that value. Explicit depth uses the [ordinary traversal contract](OPERATOR_DEPTH.en.md): positive d removes d outer axes, d=0 selects all, and d>K is an error for iterated Arrays. The base handler is called without a second automatic Map. Unsupported remaining whole-cell work is diagnosed; depth does not promise a scalar emitter for every method.

An empty final frame executes no cell kernels. The type and empty result come from the declared result requirement rather than a test invocation. Source occurrences that are required to determine shape or select a reached plan still follow ordinary demand; a zero output is not permission to skip arbitrary required source effects.

## 3. Numeric and observable order

Coordinates of the fresh output are visited with the final axis varying fastest. For each coordinate, preserve the ordinary scalar expression tree and demand. Intermediate numeric boundaries still admit and round to their declared types even when no intermediate Array is allocated:

```text
intermediate = admitAndRound(scalarResult, declaredIntermediateType)
result = evaluateNextScalarOperation(intermediate)
```

No implicit promotion to machine double, reassociation, FMA or parallel reduction is authorized. A selected numeric contract may explicitly allow particular transformations. The initial plan only accepts known operations whose observable effect and failure requirements can be preserved. Purity alone does not make exceptions disappear.

If eager whole-Array evaluation would produce a different observable failure/effect order, a backend must prove preservation or reject the requested fusion. Writing fuse is not silent permission to choose a different first exception. Input captures, numeric domain checks and target admission cannot be arbitrarily reordered across observable failures.

A depth expression is obtained once per demanded occurrence, not while grouping or calculating priority. Names in backticks remain exact names. New unsupported grammar/plan/shape conditions are translator diagnostics when statically known, otherwise interpreter diagnostics at the reached operation. User expressions and selected scalar methods keep their ordinary throws contracts.

## 4. Final result and assignment

The initial profile publishes a fresh final result after success. It does not mutate existing input or destination storage during scalar evaluation.

```lmx
result := fuse(A * B + C)
values[:] .: fuse(values * scale + bias)
```

Each RHS first obtains its final fresh Array, then ordinary assignment executes. `:=` uses exact pointwise correspondence; `.:` broadcasts to the selected slice. The presence of fuse on the RHS does not insert the outer store into the fused loop and does not select a written-prefix failure behavior.

Ordinary assignment obtains required pre-write RHS values and validates all actual target admissions before stores. Overlapping permutations therefore use a snapshot:

```lmx
int: a 1
int: b 2
int: c 3
(a b c) := (b c a)
```

A future terminal-write executor may eliminate the final temporary only under its declared exact assignment/failure contract. It must handle actual alias maps: current-cell read, shifted read, transpose, broadcast reuse and duplicate writes are different cases. Unknown dependencies are not made safe by equal shapes. An explicit streaming capability must not silently replace RHS-before-first-write with partial visible stores.

## 5. Storage, views and result context

The result is built under its full declared/evaluated type requirement. Persistent shape is not invented from payload or forgotten initializer rows. A temporary operation context may describe dimensions needed by the next operation; publication obeys its actual result/access contract. TypeRef remains a canonical type pointer, capacity remains independent reserve information, and the Array header remains parent/length/storage.

The system parent contains a complete instance context where needed. It supplies source/owner, mapping, lifetime and access data using ordinary structures and copy/merge. Depth-selected cells can refer to flat regions without allocating row Arrays. A saved cell or persistent View needs a retained context or materialization; this is already expressible by the existing parent mechanism.

A supported View map is a read capability, not a promise that all possible offset/stride/window/gather expressions can be fused. Read-only is the initial persistent-View default. A retained owner prevents invalidating backing/shape changes for that View. Maps first respect the source's logical region and then the owner's allocation bounds. Repeated reads are valid; duplicate target writes require a separately declared deterministic policy.

An inline `[items]` is an explicit input value with ordinary identity, not a grouping node or an arithmetic intermediate. Capturing it once may be supported. Eliminating that explicit construction requires a separate proof preserving identity, lifetime, demand and failures. `[arr2]` remains one whole reference and does not grant singleton-axis broadcasting.

<a id="implementation"></a>
## 6. Shared implementation algorithm

The following steps describe integration, not newly exported `sys` functions:

```text
prepareFuse(rawOccurrence, actualContext):
    inspect roles and supported method capabilities without running bodies
    obtain the reached demanded inputs and dynamic parameters once
    derive compatible output coordinates and complete result requirement
    validate input access maps, scalar numeric boundaries and demand/failure order
    reject any unsupported operation or guarantee
    allocate only the final result and allowed compact access metadata
    for each output coordinate in canonical order:
        obtain required scalar inputs through their checked access maps
        evaluate the original scalar tree, including intermediate admission
        store into the unpublished fresh result
    publish the result under its complete type and parent-context contract
```

Scalar-only work uses the selected ordinary scalar evaluation. A Map→Map plan shares one scalar tree and access maps rather than allocating a tree or row storage per coordinate. Settings are ordinary data; the executor must contain the actual reader, scalar emitter and result builder. The selected scalar rules, lazy demand and complete result types are not replaced by metadata declarations.

If the plan is unsupported, the translator/interpreter reports it. It cannot fall back to eager materialization, claim an unimplemented View, or silently run a general matrix library inside an advertised scalar plan. Reduce, contraction, accelerator, BLAS/GraphBLAS and C-import support are separate implementation work. A two-contraction plan is outside the initial capability set, not inherently impossible.

## 7. Verification and performance scope

The [host reference](tools/array_expression_reference.py) and [tests](tools/test_array_expression_reference.py) model the explicit minimum and its rejection paths. They use [depth transport](tools/operand_depth_reference.py). They do not prove production LMX parser, translator or native execution; that status remains **NOT_RUN** until checked with the project's tools.

For an admitted `fuse(A * B + C)`, the structural guarantee is no intermediate product Array and one final result. It is not a benchmark, mandatory SIMD, zero RAM access or a universal speed promise. Scalar values with their own variable-sized storage retain that type's allocation semantics. Future executors must state working-memory budgets; a full intermediate Array does not become a small tile merely by being renamed.
