# Canonical operation publication, roles and exact results

This is the implementation contract of the existing library/actor publication
context and translator. The parser already accepts every receiver in Expression.
The source algorithms, descriptors and acceptance cases are integrated in this
package. Production binding and execution remain **NOT_RUN**.

All source entries must use one common parser with the internal `[]` helper
specified by the [bracket delegation contract](../../BRACKET_SUBPARSER.ru.md).
One Expression grouping implementation consumes every admitted graph and
prepares the plan for interpretation or native translation. Production
integration removes duplicate parser/grouping algorithms and precedence tables;
adapters that preserve independent algorithms or priority scales are not an
accepted implementation. The publication and application adapters below only
select representations and package prepared actuals; they add no parser or
grouping pass.

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
        int: depth
        []@: right
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

## Depth is an optional operand service input

The common transport is **left, depth, right**. The actual `depth` is optional:
`op` leaves it absent; `.(expression)op` supplies an integer. The
expression is obtained once, when demanded, in its original dynamic context.
There is no `.op`, `..op` or `...op` shorthand. In ordinary tokenization `.(`
starts a modifier and is never a decimal point. No number is encoded in the
canonical name. A receiver uses the same quoted base name and named `depth` actual.

Absence is decided by the prepared occurrence, like absence of `left`. A distant
dynamic field also named depth does not make the modifier present. A method may
explicitly obtain its own default from its usual context; this is different from
unconditionally supplying zero. No extra presence field or numeric sentinel is
introduced. A present empty `right` Array remains present.

These Array traversal rules belong to the selected common Map profile, not to
generic operand transport. The common middle formal remains int; transport
admits that type and passes the optional named depth actual. A custom method
may interpret it according to its own contract, including a negative integer.
Unless it selects common Map, transport imposes no Array traversal, maximum
meaning for zero, nonnegative-depth limit or depth-versus-rank admission.

For explicit positive d in the common Map profile, the first d logical axes of each iterated Array form
its frame; the remaining axes form the cell. Positive d greater than that
Array's rank is a translator/interpreter diagnostic. **Explicit depth 0 means
maximum traversal:** all logical axes form the frame and elements are passed to
the base operation. It never means a whole-argument call. Frames match exactly.
Original scalars and explicit `$held` actuals add no frame axes; length-one Arrays
remain Arrays. References are not recursively followed to invent extra axes.

`RxLogicalArguments\collect` still combines only left and right. It is not an
OPERANDS_TEMPLATE implementer. A source callable may have its own ordinary
input named depth; that input keeps its owner and mapped logical argument. The
wrapper's service actual is not inserted into the source positional arguments.

### One VALUE adapter and the exact dependent result

`FxAsOperand` constructs the actual three-field DATA with **only right required**,
ready `PASS_ARGS_AS_IS` and `PRIORITY`, and ordinary `operandDepthSource` policy.
`FxOperandValueEngine` inspects frame slot 1 without demanding it. When absent,
it calls the ordinary source with its collected logical actuals. When present,
it reads the integer once, obtains the checked context from **PD01**
`FxKernel\operandDepthContext(frame; arguments)`, and invokes
`FxArrayDepth\apply(context; depth; inputs)`.

Zero takes the latter route and selects maximum scalar traversal. Plain
arithmetic without a modifier already has complete elementwise Array behavior.
But absent depth is still distinct: a whole `[op]`, reducer or text consumer
retains its own ordinary contract rather than receiving an explicit maximum map.

The prepared `base` is the selected method entry with its true consuming roles,
not its automatic Array wrapper. After selecting cells the executor invokes that
base once per frame coordinate **without re-entering automatic Map for this
same operation**. Otherwise every requested depth would secretly continue to
scalar leaves. Explicit operations written inside a user body retain their own
ordinary contracts; this is not a global switch disabling Array expressions.

With two Arrays of shape `(2,2)`:

```lmx
A * B
A .(0)* B
A .(2)* B
A [*] B
A .(1)[*] B
```

The first three produce scalar elementwise products. The fourth performs matrix
multiplication. The fifth traverses the outer row axis and invokes vector matmul
on corresponding rows, producing dot products. By contrast, `A .(1)* B` passes
whole rows to the selected base `*`; a scalar-only numeric base rejects them
unless a compatible row contract has been declared. It does not turn into dot
products and does not restart implicit scalar Map. For `.(d)[op rules]`, inner
axis numbers refer to the cells left after the outer traversal.

The ordinary context exposes:

| Field | Contract |
| --- | --- |
| `base` | Actual source callable with original owner and ordinary logical inputs |
| `hasResult` | Source value/void contract; no Array<void> is created |
| `frame(context; depth; inputs)` | Select maximum traversal for zero or d leading axes for positive d; check matching frames, the base cell contract and result requirements; return `singleResult,count,inputs,read,layout,write,allocate` |
| `inputs` | Entries distinguish iterated actual Arrays from original scalar or held values; references are read by their real layout |
| `read(map; index)` | Obtain one scalar/cell without creating a storage object for each logical row |
| `layout` and `allocate(context; layout)` | Construct valid result backing directly under the complete canonical TypeRef; no empty invalid shaped Array, resize trick or hidden retag |
| `write(output; index; result)` | Admit/store one scalar or cell result in the selected dense or structural output |

Dense output has shape `frame + resultCellShape`. A structural result can retain
heterogeneous actual types and different cell sizes. Empty frames execute no
sample callback; type/shape follow the declared result contract. A complete
reduction returns one R, which can itself be a Structure or Array. It is an
ordinary scalar only when R is scalar.

Structure/`[]@` and text participate in the same mechanism. A Structure slot
leading to an int record supplies that typed int, not the pointer's numeric
address. An actual reference-valued record remains a reference. Array elements
that refer to Structures do not automatically extend the outer logical rank;
`struct[i]\[j]` is ordinary reference/index access. Array alignment is positional,
not an implicit join by field names.

The full result requirement is prepared before execution without probing source
code on the first element. A result shape determined dynamically still selects
its canonical full TypeRef. This does not create a universal secondary physical
Array descriptor or mutate an already published type. A reused scalar native ABI
cannot silently return an Array. No native compilation on demand is implied.

PD01 and the existing allocation/binding boundaries are required production
integration, not implemented stubs. Source bodies and source checks in this
package do not claim a production parser, translator, runtime or C import run:
**NOT_RUN**. Invalid depth/shape/profile/fusion plans are translator/interpreter
diagnostics; reached callback/numeric failures preserve their real throws.

### Whole roles, indexed profiles and ordinary settings

DATA, TYPE, RAW, NAME, PLACE, callable and explicit family contracts remain
receiver-defined. Their absent-depth form retains that contract. An explicit
modifier is admitted only by a declared compatible profile; it is neither
silently ignored nor rejected because the physical container is `[]@`.
Maybe/Result/Array bind family intersections retain the explicit selection and
ordinary ambiguity rules above. Whole-value methods may be mapped over cells
when their declared argument/result roles admit those cells. Type constructors
and control transfer do not become eager scalar callbacks by sharing three
transport names.

`[op]` selects the declared whole operation; `[op rules]` selects its common
indexed profile. Absent `axisRules` and a present empty structure are distinct:
the former preserves automatic matmul for `[*]`, the latter is an outer plan.
The common source executor is `FxArrayIndexed`, with a `term` method and a
separate `reduce`, initializer, `mapToState`, `finish`, empty and stop contract.
Unary `[+ axis:]` sums, unary `[* axis:]` multiplies; geometry has no reduction.
The adapter normalizes prefix/infix logical arguments inside the selected method,
not by changing the parser's maximum-one-left rule.

Profiles and access plans are ordinary LMX structures: real fields and method
references composed with `copy`/`merge`, retaining parent and dynamic context.
No new runtime operator registry or per-symbol traversal is introduced. See
[TENSOR_OPERATIONS_IMPLEMENTATION.md](TENSOR_OPERATIONS_IMPLEMENTATION.md) for
source contracts, assignment, geometry, reduction state and the minimal fuse plan.

## Whole values and constructor adapters

The actor context has explicit input routes for:

| Public input | Internal operation | Result |
| --- | --- | --- |
| `some(x)` | `FxRecordAdapter\make(T; FxSome\some)` | exact `@FxMaybe` |
| `ok(x)` | `FxRecordAdapter\make(T; FxOk\ok)` | exact `@FxResult` |
| `err(x)` | `FxRecordAdapter\make(T; FxErr\err)` | exact `@FxResult` |
| `done(x)` | `FxRecordAdapter\make(T; FxDone\done)` | exact `@FxBounce` |
| `type(x)` | shared value capture, then `FxValueType\type` | canonical TypeRef (`@`), direct type description |
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

The `FxRecordConstructor` interface has a reference result. `type` uses the
shared capture route and returns the canonical TypeRef from `FxValueType`.
The standalone source still has its previous int result and requires migration;
that old result is not the current contract. Ownership follows the ordinary
arena/native lifetime rules, with type descriptions kept alive while referenced.

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
left side as one actual, the explicit depth actual, when present, as the second service input,
and the current-level right stream as an Array of references; the grouper itself does not package `left`. The library collector
and `asOperand` wrapper forward that prepared vector. Their logical argument
collection is an explicit step inside the operand method body, not a universal
pre-call binder. An absent left stays absent at method entry; the first right
item is not shifted into it. Thus `(:= a 1)` and `(a := 1)` reach the method
with different vectors, and their equivalence belongs to that method, not an
assignment-specific parser rule. There is no subsequent conditional opening
pass, textual rewrite or reparsing.

For `(a b c) := (a c b)`, the adapter supplies one whole left argument and the
right stream `a, c, b`. For `(a b c) := (f g h) (f g h) (f g h)`, it supplies
three whole right Structures, not nine fields. Direct `(a b c) := copy(d)` uses
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

`type(x)` obtains the canonical TypeRef of the actual typed value. Mere admission
to another model does not replace that descriptor or record all past semantic
checks. `types(source)` returns []@ TypeRef references for the physical fields.
These operations and `return` remain distinct contracts.

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
