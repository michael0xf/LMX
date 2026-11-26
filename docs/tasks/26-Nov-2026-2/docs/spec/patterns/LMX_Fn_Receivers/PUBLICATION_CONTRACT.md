# Canonical operation publication, roles and exact results

This is the implementation contract of the existing library/actor publication
context and translator. The parser already accepts every receiver in Expression.
The source algorithms, descriptors and acceptance cases are integrated in this
package. Production binding and execution remain **NOT_RUN**.

## One family and two representations

[operation_definitions.json](operation_definitions.json) is the build-time
inventory of every canonical public operation. [catalog.json](catalog.json)
contains its ordinary and operand targets, semantic variants, source contracts
and input roles. [CANONICAL_MIGRATION.json](CANONICAL_MIGRATION.json) accounts for
every incoming export, including many-to-one renames and changed argument order.
These files are not runtime name registries.

[public_families.lmx](src/public_families.lmx) expresses the same family members
as ordinary graph DATA. The library/actor context publishes that complete
family. [public.lmx](src/public.lmx) is its receiver projection;
[public_operands.lmx](src/public_operands.lmx) supplies ordinary VALUE operand
representations through the one existing `FxAsOperand` builder.

The receiver projection alone does not implement family selection. Nor does
merely importing Maybe, Result and Array methods prove unambiguous publication.
The existing context/translator must consume the declared family and roles:

1. The already parsed use supplies the canonical name and syntactic role.
2. The role chooses the corresponding representation of this declared family.
3. Full requirements and the explicitly selected semantic family select the
   ordinary admissible declaration. Maybe and Result remain distinct from an
   explicit Array interpretation even though all may use Structure storage.
4. Real intersections remain ordinary ambiguity. Definition order, quotation,
   field count and trial execution never resolve them.
5. The selected operation consumes actuals in their written order and original
   context. Its existing algorithm performs the action.

This contract is applied to built-in, standard and user operations by the same
translator path. It does not turn DATA, TYPE, NAME, RAW/BODY or PLACE into eager
VALUE arguments. Control transfer and cleanup retain the original activation.
Type-declaring receivers remain included in the complete audit.

<a id="prepared-operand-data"></a>
## Explicit operand DATA and priorities

`OPERANDS_TEMPLATE` denotes the language's ordinary structural requirement,
described in [operand discovery](../../LMX_semantics.en.md#operand-receiver).
It does not establish a system object named `sys\OPERANDS_TEMPLATE`.
The library uses the ordinary shared DATA fragment
`FxPreparedOperands` in [generic_functions.lmx](src/generic_functions.lmx):

```lmx
FxPreparedOperands:
    private:
        @: left
        int: depth 0
        @[]: right
    const: int: PASS_ARGS_AS_IS 0
```

An explicit `copy: FxPreparedOperands` supplies these actual fields. Each
consumer separately declares a ready constant `PRIORITY` and its own
`required` and result policy. The fragment alone is not a complete operand;
structural checking supplies neither a missing field nor a default priority.
The transport inputs are private service inputs, not a rule that all inputs
of a generated user callable must be private or required.

| Prepared representation | Explicit priority |
| --- | --- |
| `FxRecordOperands`, `FxSignatureOperand`, `FxToOperand`, `FxTypeOperand` | `sys\priority("+")` |
| Built-in named signature operand `::` | `sys\priority(":=")`; weaker than `->` |
| Finite comparison profiles `PipeLibrary`, `FindLibrary`, `SpecificationLibrary\Operators`, `MoneyLibrary\Equality`, `RetryLibrary` | `sys\priority("+")` |
| `FxBetween` | `sys\priority("<=")` |
| `bind` and Pattern `then` | `sys\priority("+")` |
| Pattern `times`, `atLeast`, `atMost`, `optional` | `sys\priority("*")` |
| `asOperand(operation; priority)` | Its explicit ready `priority` argument; the standard VALUE publication passes `sys\priority("+")` |

These are ordinary ready properties on the existing expression scale, obtained
before grouping without running the operand body. They do not assign numeric
priority constants, change built-in symbolic priorities, or introduce a new
registry. `::` retains its NAME/description declaration contract; its weaker
grouping gives `f :: int -> int int` one whole RHS occurrence, just as in
`f :: (int -> int int)`.
The [description-consumption contract](../../LMX_semantics.en.md#signature-description-consumption)
consumes every argument exclusively as DATA, including the declaration NAME.
One Structure supplied as the description remains one external operand actual.
When a contract requires a declaration or field list, the
[common namespace mechanism](../../LMX_semantics.en.md#receiver-structure-sequences)
reads the ordered immediate fields of a Structure or its referenced DATA target.
`::` uses that mechanism for signature declarations; modifiers use the same
machinery under their DATA contracts. DATA or CODE governs element consumption;
the receiver contract decides between a list and a whole value. Whole TYPE,
model and value contracts retain the object. This introduces no special `::`
opening, outer actual expansion, CODE W/E in DATA, Structure call or recursive
flattening of nested models and `return` descriptions. A ready positional profile
is also DATA and is consumed as a profile, not reflected into service-field declarations.
If the common Expression mechanism prepares a constructor result, `::` consumes
that ready result. Under
[receiver-context invariance](../../LMX_semantics.en.md#receiver-context-invariance),
the resolved operation retains its own contract: `::` is a signature declaration
even in CODE, and modifiers such as `const`/`private` always consume DATA.
Expression is CODE, so an ordinary explicit callable form inside it remains a
call. RAW controls timing without changing that meaning. Grouping, priorities
and any preparation of the constructor result belong to the common Expression
mechanism. `::` has no CODE-argument branch, local DATA/value selector or RHS
evaluation step. The direct arrow spellings are normative equivalents under
that common mechanism. An anonymous Structure is not called; execution in
place in CODE/Expression follows the ordinary rules.
Formal initializers in an explicit DATA template remain unexecuted. An ordinary
value declaration followed by `f :: description` is another explicit path.
The builtin `::` implementation and mode metadata are absent from this package;
no `PASS_ARGS_AS_IS` value is assigned to it. Runtime verification remains
**NOT_RUN**. It does not acquire assignment
semantics from that priority.
The original non-Pattern
branches of `|` keep their existing contracts. The copied fields contain no matching, collection or adapter
algorithm. The same bodies are used by both applicable forms.

## Depth is an operand service input

The complete common rule is [OPERATOR_DEPTH.en.md](../../OPERATOR_DEPTH.en.md)
([Russian](../../OPERATOR_DEPTH.ru.md)).

Every real operand declares the transport inputs in the order **left, depth,
right**. `op` supplies depth 0; `.op` supplies 1; `.(expression)op` supplies the
nonnegative `int` produced by the ordinary Expression contract. There is at most
one prefix dot. The explicit depth expression is evaluated once, only when that
receiver demands it. No new callable names are registered for depth values.
In ordinary code tokenization, `.(` always starts an operator/function depth
modifier; it is not a decimal point. Protected lexical modes remain opaque.
Array indices and type postfix forms keep their own brackets.
The receiver spelling uses the quoted **base** name and a named `depth` actual
of that selected outer operand profile. This is not a reserved identifier: an
original ordinary function may have its own user input named `depth`; that input
retains its original owner and receives only its mapped logical argument. The
outer service input is not a second positional argument of the original function. Prefix absence remains absence, and a present empty right Array
remains present. `PASS_ARGS_AS_IS` and `PRIORITY` keep their previous roles.

`RxLogicalArguments\collect` deliberately remains an ordinary two-input helper:
it combines only left and right. It is not an OPERANDS_TEMPLATE implementer.
Its caller receives depth separately. This prevents `asOperand(add; priority)`
from accidentally calling the original `add(first; depth; second)`.

### Ordinary VALUE functions: one algorithm and a dependent exact result

`FxAsOperand` constructs the real three-input DATA and delegates to the shared
`FxOperandValueEngine` in [coreStandardLisp.lmx](src/coreStandardLisp.lmx).
The engine collects ready logical arguments once. Depth 0 calls the original
operation through `FxApply`; a positive depth obtains the prepared Array
context through the explicit **PD01** `FxKernel\operandDepthContext(frame;
arguments)` provider and invokes the single
[`FxArrayDepth\apply(context; depth; inputs)`](src/array_expression_ops.lmx)
algorithm. The original function never receives the depth field as user data.

The builder adds ordinary `operandDepthSource` policy data to `FxOwnPolicy`.
The same callable preparation and final result admission must honor this policy:
depth 0 retains the source's complete `R`/void. Positive depth traverses that
many logical outer axes of the ordinary Array descriptor. Dimension metadata
belongs to the same description as capacity; contiguous storage does not reduce
a rank-2 matrix to a single logical level. Preparation derives the complete
result requirement and flat output layout from the traversed axes and the base
result contract, without inserting a separate array-of-arrays storage kind.
Only an original scalar actual broadcasts across the selected axes. A call whose
original actuals are all scalar reaches a fixed point without creating synthetic
singleton dimensions. Original Array provenance persists during traversal: two
Array inputs with incompatible selected dimensions, or an Array whose logical
rank is exhausted before the requested depth, produce a translator/interpreter
diagnostic. A reached scalar from such an Array does not become an original
broadcast scalar. Shape, qualifiers, models and reference requirements are
retained; the first element is never called to guess a result type. A
runtime-selected depth requires the corresponding dependent result preparation.
An unchanged native scalar-return ABI cannot be reused for an Array result, and
no implicit native compilation is requested.

The common context contains:

| Field | Contract |
| --- | --- |
| `base` | Original ordinary callable, invoked with logical arguments only |
| `hasResult` | The source's actual value/void contract |
| `level(context; depth; inputs)` | Checks all selected logical axes and the full result requirement; returns a frame with `hasArray`, `count`, `inputs`, `read`, `layout` and `write` |
| `publish(context; layout; result)` | Retains the allocated result's complete ordinary shape description from its prepared layout, without inventing a second header |

The frame's `count` is the number of selected base applications, which need not
equal the number of physical scalar cells. An input entry contains `isArray`
and `value`; `value` may be a prepared logical access map. `read(map; index)`
returns the scalar or slice descriptor for one application, sharing the existing
storage. The source attaches `root = context` and uses the same fill loop for
all applications; it does not recursively allocate row containers or require a
`childDepth` field. `layout` describes only actual result storage, allocated once
by `FxArrayResultTree`. `write(output; index; result)` admits and writes the
selected scalar or block result into that storage. Shape preparation never
executes the user's method to infer a type or layout.

The level inputs distinguish actual Arrays and original broadcast scalar values,
and retain each original actual's Array/scalar provenance across logical-axis
traversal. With two flat matrices of shape `(2 2)`, depth 0 invokes matrix `*`,
depth 1 invokes vector `*` on corresponding rows, and depth 2 invokes scalar `*`
on corresponding components. Thus `a .* b` is the row-dot profile in that
matrix example; `a .(2)* b` is its complete scalar componentwise product.
For rank-1 vectors, `a .* b` already reaches the scalar components.

A Structure is an `@[]`. A reference stored in it may refer to another Array:
`struct[i]\[j]` first selects that reference and then performs ordinary indexed
access through it. This uses the existing reference and Array contracts, not a
separate array-of-arrays entity or a second definition of dimension depth.

An empty traversal obtains its full result type from preparation and performs
no sample call. A void source executes the same selected
base calls but allocates no `Array<void>`; `FxWrap` discards the internal engine
marker and returns ordinary void. It also projects a real value result through
its full selected requirement. Internal `return: @` on the engine remains a
transport reference to a typed value record, not the public result declaration.

PD01 is a **required kernel integration boundary, not an implemented provider**.
The source contains the adapter and the reusable LMX traversal; it does not
claim that the production parser, translator, dynamic result admission or native
bridge have passed execution. Their status remains **NOT_RUN**. Invalid depth, incompatible structure/shape and unavailable fusion are
translator/interpreter diagnostics, not fabricated callable failures. The provider
prepares existing contracts and shape callbacks; it must not hide a second
mapping implementation or execute the source's function while preparing them.

### Receivers with whole DATA, TYPE, RAW, PLACE or family contracts

A depth field does not authorize a universal recursive rewrite of these roles.
The existing `record`, `->`, `type`, Maybe/Result `bind`, Pattern combinators and
finite comparison helpers here retain their whole-value depth-0 profile.
A nonzero depth outside that profile is a translator/interpreter diagnostic
during semantic preparation, before method execution or incompatible typed
family reception. It is not a new LMX exception and adds no synthetic `throws`.
Role-aware and adaptive projections, including direct receiver spelling, apply
that same profile admission. No exported diagnostic helper or eager graph
rewriter is introduced; depth is not silently ignored. A future profile can explicitly choose the
common VALUE traversal or define a role-specific meaning. Array `bind`, already
constructed with `asOperand`, uses the ordinary VALUE lifting policy.

## Whole values and constructor adapters

The actor context has explicit input routes for:

| Public input | Internal operation | Result |
| --- | --- | --- |
| `some(x)` | `FxRecordAdapter\make(T; FxSome\some)` | exact `FxMaybe@` |
| `ok(x)` | `FxRecordAdapter\make(T; FxOk\ok)` | exact `FxResult@` |
| `err(x)` | `FxRecordAdapter\make(T; FxErr\err)` | exact `FxResult@` |
| `done(x)` | `FxRecordAdapter\make(T; FxDone\done)` | exact `FxBounce@` |
| `type(x)` | shared value capture, then `FxValueType\type` | `int` |
| `literal(x)` / `element(x)` | shared whole-value capture, then their existing constructors | Pattern reference |
| `arrayView(xs)` | whole Array record, then `RxArrayView\arrayView` | Array view |

`T` is the actual complete requirement, including Array shape, qualification and
reference depth. The input expression is evaluated once. The selected value
is retained as one record and passed by the named internal `p0` mapping.
The capture receives the already projected actual record. It does not regroup
the source, reopen that value or reapply ordinary callable W/E. Some(null),
Some(0), an empty Array and absence remain distinct.

`FxRecordAdapter` is implemented in
[generic_functions.lmx](src/generic_functions.lmx). `FxCaptureOne` delegates to
that same implementation. Internal constructors already receiving a record
continue to receive it directly and do not apply a second capture. For example,
`FxSome\some(value := readyRecord)` is deliberately an internal protocol.

The source `FxRecordConstructor` interface has a reference result. `type` uses
the shared capture route but returns its actual `int` from `FxValueType`; it
is not forced through that constructor interface. Source/result ownership
follows the ordinary arena/native lifetime rules.

## Exact public results for value pipelines and retries

`FxPipe\pipe` and `FxRetryValue\retry` are internal **record-returning engines**.
Their `return: @` is not the public type of an arbitrary stage or request result.
The publication context must use the supplied exact builders:

| Public action | Exact builder | Invocation |
| --- | --- | --- |
| `pipe(value; stages)` / `value pipe f g` | `FxPipeBuild\make(T; stages)` | one accepted value `T` → the final stage's exact `R` |
| `retry(operation; retryOn; limit; delay; arguments)` | `FxRetryBuild\make(...)` | prepared nullary call → the request's exact `R` |

Both builders use `FxWrap`; its shared engine protocol returns a record and its
generated caller returns the actual value with the selected signature. There
is no fixed-`@` public `pipe` operand. The context prepares stage/request
arguments once, builds or reuses the ordinary typed callable, and invokes it
through the existing common dispatcher. For the operand spelling the same
argument mapping is applied before invoking that typed callable. The stage
list is not passed or opened a second time.

For a pipeline with no stages, `R = T`. The builder checks every stage signature
for one input and a non-void result before publishing the pipeline. Each reached
stage then admits the complete previous value through its actual contract; an
incompatible value fails at that reached call. Arbitrary type changes between
stages are supported without copying the algorithm per type.

`retryOn(result; attempt)` decides whether to repeat an ordinary result;
`delay(attempt)` runs only between actual attempts. The last permitted attempt
returns its actual result without calling a policy that could not cause another
attempt. Declared-exception retry remains `retryCall` and asynchronous Message
retry remains `retryPost`.

## TYPE and prepared argument routes

The common Expression grouper resolves priorities, groups and explicit field
streams from the supplied pure graph, regardless of notation or origin. Its output is a
structured operation/stream plan. A separate application adapter packages the
left side as one actual, the evaluated depth as the second service input,
and the current-level right stream as an Array of references; the grouper itself does not package `left`. The library collector
and `asOperand` wrapper forward that prepared vector. Their logical argument
collection is an explicit step inside the operand method body, not a universal
pre-call binder. An absent left stays absent at method entry; the first right
item is not shifted into it. Thus `(:= a 1)` and `(a := 1)` reach the method
with different vectors, and their equivalence belongs to that method, not an
assignment-specific parser rule. There is no subsequent conditional opening
pass, textual rewrite or reparsing.

For `(a b c) .: (a c b)`, the adapter supplies one whole left argument and the
right stream `a, c, b`. For `(a b c) .: (f g h) (f g h) (f g h)`, it supplies
three whole right Structures, not nine fields. Direct `(a b c) .: copy(d)` uses
the explicit field stream and needs no enclosing RHS group. Its group-assignment
effect equals the wrapped spelling; a scalar whole-value `(copy(d))` is retained.
These outcomes follow from [the common grouper and application adapter](../../LMX_semantics.en.md#expression-structural-grouping).
Nested scalar Expressions such as `1 + ((2))` are handled recursively from the
graph. When consumed as CODE/Expression, an ordinary named Structure with the
current lexical parent follows the ordinary call path. A named Structure with
another parent, and every anonymous Structure, is handled as a group with its
actual parent retained. The distinction uses graph name/parent and traversal
owner, not how a reference was obtained.
VALUE/TYPE/DATA positions preserve their receiving contracts and do not become
CODE automatically. A graph's source origin and parenthesis history are not
semantic flags. DATA is not evaluated and RAW is not forced by group planning;
a complete inner Expression remains one
original RAW occurrence with its context, not several physical-token actuals.

`` `->`(A0; A1; R) `` collects complete TYPE tokens with the result last.
`A0 -> A1 R` uses `FxToOperand` and the same `FxToTokens` / `FxToTypes` builder.
`` `->`(R) `` constructs a nullary signature; an empty call fails with `FxArity`.
`Name :: DATA` retains its named-signature meaning.
`f :: int -> int int` groups as `f :: (int -> int int)`. Obtaining the constructor's
two-input/one-result description belongs to the common Expression mechanism;
`::` receives that ready profile as DATA and does not evaluate its arguments.
The constructor neither creates an executable body nor
implicitly turns the flat signature into a chain of unary callables.
`int -> (int int)` has one right Structure, not two right TYPE tokens;
`int -> ()` has one right empty Structure. Their admission follows the ordinary
TYPE contract. `FxToOperand`, `FxToTokens` and `RxLogicalArguments` use the
projected arguments without signature-specific opening or a second adaptation.

`type(x)` reads the actual physical type code, not an arbitrary semantic model.
`types(source)` still returns the sequence of field type codes. These operations
and `return` remain distinct contracts.

The four attached update forms have canonical variant names `++var`,
`var++`, `--var` and `var--`, each with one PLACE. Existing `@` needs no quote.
Exact names such as `` `@name` `` or `` `++counter` `` stay opaque. See the
complete [operation forms](../../OPERATION_FORMS.md) contract and translator
reference for the common lowering.

## Pattern domains and replacement roles

The single Pattern signature takes `RxPreparedSource`. Text retains its
`RxPreparedText` decoder, UTF-8/octet profile and byte offsets; an Array retains
its actual typed units. Both public view constructors put the preparing method
in ordinary `prepare` DATA. `RxPrepareSource` calls that declared method; it
does not infer a source kind from coincidentally similar fields.

The source domain supplies literal preparation, range-bound conversion and
slicing. Combinators, candidates, backtracking, repetition guards and capture
journals remain common. `literal` matches a sequence, `element` one whole
element, `within` uses a selected order, and `satisfy`/`boundaryOf` validate
the actual unary predicate signature before matching even an empty source.

Public replacement admission selects the declared literal or callable role:
`RxReplacementLiteral\accept` or `RxReplacementCallable\accept` produces
ordinary `RxReplacementInput` DATA. The callback's complete Match input and
actual result are then consumed once. A callable's physical Structure storage
does not silently turn it into replacement text. A genuinely ambiguous role
requires an explicit representation.

`matchedValue`, `captureValue` and `captureValues` preserve the source profile.
Generic replacement assembles a fresh result with the source's element
admission; text additionally validates its encoding. There is one source
matching engine and one general typed range comparison.

## Errors and publication acceptance

Preparation/building and execution have separate finite contracts. The actor
context propagates failures of actually reached construction; a cached prepared
callable retains its own declared failures. Public regex callback errors follow
the existing finite signature-union / attempt / raise path, preserving original
names and payloads. They never become a mismatch or an empty optional value.

There are no old callable aliases. Migration changes every source use and
generated-code string as well as exports. The remaining code and contract
checks must cover:

- both forms of every canonical name and every semantic variant;
- all input roles, full result/void and field-stream/control behavior;
- whole scalars, arrays, Structures, reference values and dynamic binding;
- ambiguous Maybe/Result/Array and literal/callable intersections;
- wrong arity, omitted arguments, named actual order and current-level stream projection without a second opening;
- exact pipeline/retry results across interpreter/native transitions;
- generic Pattern inputs, literal failure phase, zero-length success and
  monotonic cursor completion;
- actual callback names/payload and the complete declared failure set.

The source descriptors and proposed algorithms are available for binding to the
real runtime. Static inventory checks alone do not establish that these context
hooks have executed. No successful runtime status is inferred from this document.

The shared record constructor adapter invokes its sole input positionally.
It does not assume a formal label `value`: `err` retains its actual `reason`
input label, while `some`, `ok` and `done` retain theirs.
