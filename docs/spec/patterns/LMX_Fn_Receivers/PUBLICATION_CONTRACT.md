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
| Finite comparison profiles `PipeLibrary`, `FindLibrary`, `SpecificationLibrary\Operators`, `MoneyLibrary\Equality`, `RetryLibrary` | `sys\priority("+")` |
| `FxBetween` | `sys\priority("<=")` |
| `bind` and Pattern `then` | `sys\priority("+")` |
| Pattern `times`, `atLeast`, `atMost`, `optional` | `sys\priority("*")` |
| `asOperand(operation; priority)` | Its explicit ready `priority` argument; the standard VALUE publication passes `sys\priority("+")` |

These are ordinary ready properties on the existing expression scale, obtained
before grouping without running the operand body. They do not assign numeric
priority constants, change built-in symbolic priorities, or introduce a new
registry. `::` and the original non-Pattern branches of `|` keep their existing
contracts. The copied fields contain no matching, collection or adapter
algorithm. The same bodies are used by both applicable forms.

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
Neither W/E nor operand RHS-opening is repeated. Some(null), Some(0), an empty
Array and absence remain distinct.

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

`to(A0; A1; R)` collects complete TYPE tokens with the result last.
`A0 to A1 R` uses `FxToOperand` and the same `FxToTokens` / `FxToTypes` builder.
`to(R)` constructs a nullary signature; an empty call fails with `FxArity`.
`Name :: DATA` retains its named-signature meaning.

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
- wrong arity, omitted arguments, named actual order and one RHS-opening;
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
