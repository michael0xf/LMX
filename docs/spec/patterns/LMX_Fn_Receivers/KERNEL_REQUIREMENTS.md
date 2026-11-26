# Kernel integration requirements

**Integration source, not a completed runtime.** The archive contains LMX algorithms and internal bridge contracts. It contains no implementation repository for the LMX kernel. The real kernel must supply or expose the ordinary mechanisms below and execute the acceptance matrix. An interface declaration is not an implementation of that interface.

The normative adapter requirements are [the current semantics](../../LMX_semantics.en.md#adapter-behavior). The concrete LMX implementation, binding points and outstanding checks are explained in [ADAPTER_IMPLEMENTATION.md](ADAPTER_IMPLEMENTATION.md).

## 1. Common architecture

Use one parser, one complete source graph, ordinary owner/DATA/CODE and existing Message arenas. A generated callable is an ordinary callable with genuine parent links. No second expanded executable graph, permanent namespace copy, hidden global closure environment, new lazy-array VM or alternative bytecode engine is permitted.

Signature inspection and `satisfies` execute no candidate, default, test or converter. Source expressions and declaration actuals keep their normal effect timing. Compilation remains explicit; a new ABI never borrows an incompatible native entry. Plain graph mutation and subsequent interpretation require neither compilation nor `endturn`. Installing a newly compiled machine implementation follows the existing explicit compilation and `endturn` rules; graph editing alone does not patch an old native caller.

P0 retains the graph and diagnostic provenance. The Expression **grouper** handles priorities,
groups and field streams in the supplied pure graph, regardless of notation or origin; its result is
a structured operation/stream plan, not rewritten text to parse again.
The distinct **application adapter** packages the left side as one actual and
the current-level right stream as an Array of references. Left grouping is
preserved by this packaging, not by making the grouper a left-argument wrapper.
The familiar argument vectors follow from this plan and ABI; there is no
conditional container-opening pass after grouping. `RxLogicalArguments` and
library `asOperand` forward the prepared vector without traversing its elements.
Logical argument collection is explicitly requested inside the operand method
body. The two common forms retain an absent left or one left atom at method
entry; neither parser nor transport moves the first right item into left.
Equivalent assignment forms are handled by the assignment method itself,
without an assignment-specific parser branch or a universal pre-call binder.
See [grouping and application](../../LMX_semantics.en.md#expression-structural-grouping)
and the [accepted vector outcomes](../../LMX_semantics.en.md#operand-right-only-opening).

For `(a b c) .: (a c b)`, the plan contains the two ordered streams and the
adapter supplies one whole left argument with three right values. For
`(a b c) .: (f g h) (f g h) (f g h)`, the current right level has three whole
Structures, never their nine fields. An explicit field stream may be written
directly: `(a b c) .: copy(d)` and the grouped RHS spelling have the same
group-assignment effect. A scalar whole-Structure receiver still retains its
`(copy(d))` container.

Recursive scalar Expression grouping gives `1 + ((2)) = 3` on either side.
In a graph consumed as CODE/Expression, an ordinary named Structure with the
current lexical parent follows the ordinary call path. A named Structure with
a different parent, and every anonymous Structure, is traversed as a group.
The actual parent is retained; the decision uses the graph name and parent
relative to the traversal owner, not reference provenance.
VALUE/TYPE/DATA boundaries do not become CODE merely because their
objects are Structures. No source-origin or parenthesis flag decides grouping.
With `S: a b c d` owned by a different parent, `1 + S + 2` therefore sees the
same group as its direct graph equivalent. With the current parent, named S
follows ordinary call admission instead. Neither case asserts numeric admission
of four neighboring atoms by `+`.
Planning does not spread whole-value inputs, run DATA initializers or force RAW input.
RAW retains a complete inner Expression as one original occurrence with its
context, not a list of that Expression's physical source tokens.
Ordinary callable W/E remains separate. These are required integration
behaviors; the package contains no executable common grouper or application adapter.

`Name :: DATA` uses the general Expression mechanism and one
whole right description. It does not open a Frame or invent an `end:` target.
Its [description-consumption contract](../../LMX_semantics.en.md#signature-description-consumption)
consumes **all arguments exclusively as DATA**: the left datum is the NAME to
declare, and the right is one description. A single Structure remains one whole
external operand actual. When the receiving contract requires a declaration or
field list, the [common namespace/field-consumption mechanism](../../LMX_semantics.en.md#receiver-structure-sequences)
reads the ordered immediate fields of that Structure or of the target DATA
selected by a reference. `::` uses this common mechanism for signature declarations;
modifiers use it under their own DATA contracts. DATA or CODE governs the handling
of the elements, while the receiver contract chooses a list or a whole value.
This is not a special `::` helper and does not change the outer argument vector,
extend CODE W/E to DATA, call that Structure or recursively flatten nested models
and `return` descriptions. Whole TYPE/model/value contracts preserve the object.
A ready positional profile is also DATA and is not reopened by reflecting its
service fields. If the common Expression mechanism has prepared a
constructor result, `::` consumes that ready result. Reading a DATA template does not
execute its formal initializers or an associated executable body. Ready signatures are consumed
by their positional profile, not by reinterpreting service fields as inputs.
The [resolved receiver keeps its own contract](../../LMX_semantics.en.md#receiver-context-invariance):
a system operation is not reclassified as an ordinary user Structure by an
outer DATA context. `::` still declares a signature in CODE. Modifiers such as
`const` and `private` retain their own contracts and always consume DATA
arguments. Expression is CODE; an ordinary
explicit callable form inside it remains a call. RAW delays execution without
changing that meaning. Grouping, priorities and expression preparation belong
to the common Expression mechanism; `::` has no CODE-argument branch, DATA/value
selector or `sys\eval` of its RHS. Thus the two spellings
`f :: int -> int int` and `f :: (int -> int int)` are normative equivalents;
any needed constructor preparation belongs to that common mechanism, while `::`
receives the resulting profile as DATA. An anonymous Structure is not called;
it may execute in place in CODE/Expression under the ordinary rules. No selector
by operator spelling, declaration contents or field streams is introduced.
An ordinary value declaration followed by
`f :: description` remains an explicit equivalent path.
The builtin consumer's executable implementation and mode metadata are absent
here; no `PASS_ARGS_AS_IS` value is inferred for it. Runtime verification is
**NOT_RUN**. This adds no
bridge or parser profile. `->` retains its existing
operand and explicit named-call forms. Both create the same positional
signature kind, with the existing named-signature/`call` relationship unchanged.

All public receivers are part of the one current kernel namespace. `fun\const` is a physical source export group, not an optional package version or second registry. Service inputs remain private; source user inputs retain their individual policy.

The current package has **20 integration bridges**: the eight original interfaces in §2 plus the read-only compatibility observation AR01, five ordinary call-phase hooks in §3, four common Array boundaries in §6, the accepted-form gate AE01, and the dependent operand-context gate PD01 below. These are internal boundaries, separate from the public callable/operand names and other exported symbols listed in the [catalog](CATALOG.md) and [value-symbol inventory](value_symbols.json). A declaration of a required provider does not claim its production implementation exists in this documentation archive.

The bridge profile uses empty payload `()` for service exits `FxKernelFailure`
and `FxTypeToken`. This defines the adapter service outcomes only. User-declared
failures keep their original canonical name and arbitrary typed payload in
`FxOutcome`/`FxCallFailure`. Implicit diagnostics and system exits are not converted
into these service failures. Message reply handlers must cover the worker's
declared exits instead of silently treating a failure as a missing reply.

### Added gate AE01: accepted declaration/body execution

`FxKernel\attemptAccepted(form)` executes an already accepted declaration or its
associated body in the immediate receiving activation and returns the existing
`FxOutcome`. Its exact source-occurrence, live-place and finite-failure contract
is [specified here](CORE_EXAMPLE_HELPERS.md#required-integration-gate-ae01-fxkernelattemptacceptedform).
The declaration is in [coreComparisonExamples.lmx](src/coreComparisonExamples.lmx).
This is an explicit integration requirement, **not an implemented kernel body**.
The LMX `iterateUntilStop` loop itself is complete and uses this one boundary.

Reuse the kernel's existing accepted-form consumption and finite effect model.
Do not infer the receiving context from pointer equality, the declaration's
internal name or a saved factory scope. The same graph can be accepted at two
different actual positions; the selected occurrence must remain distinguishable.
The provider accepts no arbitrary frame handle and introduces no closure object,
second executor, graph copy or caller-local publication. It runs neither form
during inspection or transmission. A normal callable `attempt` cannot substitute
for this gate unless it proves the same receiving-place behavior.

AE01 must demonstrate the complete numbers/cycles observation, empty iteration,
heterogeneous payloads, live `item`/`total`, step failure and body `Stop`, all four
interpreter/native combinations, and failure before an initializer is run for an
unaccepted or ambiguous form. Prepared observations remain **NOT_RUN**.

## 2. Existing narrow bridges

Declarations are in [kernel_contracts.lmx](src/kernel_contracts.lmx). `FxKernel` is an internal integration name, not a new family of user pseudopackages.

<a id="interface-probe-ar01"></a>
### acceptsRequirement(candidate; requirement; consumer=0) — gate AR01

**Required provider work; no native implementation or execution is supplied by
this archive.** Expose a read-only observation of the existing directed
`satisfies` interface check. This is an internal bridge, not a new public
receiver, a Boolean return added to `satisfies`, or a second validator.

`candidate` is an already available ordinary value/description. `requirement`
is an existing primitive/Array type description, structural requirement or
resolved positional signature, interpreted by that same checking mechanism.
An explicitly supplied `consumer` selects its established used-interface rule;
the default `0` means no explicit Consumer and therefore the full stated
requirement. Transport and lifetime follow the ordinary current-Message rules.

| Outcome | Required behavior |
| --- | --- |
| Compatibility is established by the common checker | Return `int` 1. |
| Incompatibility is established by the common checker | Return `int` 0. |
| The requirement is malformed or its type token is invalid | Raise service `FxTypeToken()`. |
| The checker cannot complete the observation, including an unresolved required path | Raise service `FxKernelFailure()`; never substitute 0 or choose an alternate branch as if incompatibility were proved. |

Unknown is not evidence of incompatibility. The last row reports an unavailable
observation; it is not a type-refusal judgment. The provider must preserve any
additional ordinary implicit/system diagnostic instead of catching it and
returning 0. Service payloads use this document's empty `()` profile.

Reuse the actual current type/conversion context, directional structural
correspondence and positional-signature comparison. Different physical field
positions, compatible full requirements, admitted type relations and extra
candidate fields retain their normal meaning. Comparing raw physical tags or
requiring exact type-code equality is not an implementation of this bridge.
Signature parameter names do not become compatibility keys. An ordinary copy
of an admissible configuration remains admissible according to its requirement;
object identity is not an invented substitute for role checking.

The observation executes **no candidate body, computed initializer, default,
analytical test or converter**. It does not prepare or enter a trial call, copy
a graph, manufacture a public object, publish a frame or create another
persistent cache. Existing common TYPE-pair cache rules may be reused. A 1
describes interface compatibility only: real reception still performs its
ordinary value-dependent checks/conversion and can fail. It does not authorize
unchecked calls or replace subsequent admission by a Boolean token.

The first users are Pattern dispatch/normalization, the repetition
configuration requirement and replacement text/callable discrimination. These
algorithms remain LMX code. The provider contains no regex matching, alternative
selection, callback execution or special Pattern type tags.

The prepared [AR01 acceptance matrix](tests/regex/ADMISSION_PROBE_ACCEPTANCE.json)
covers positive/negative/unknown observations, compatible nonidentical
requirements, copied configuration, zero user effects, preserved numeric `|`
fallback and interpreter/native paths. Every execution case is **NOT_RUN**.

### signature(subject)

Read the selected ordinary callable or signature description using the real analyzer. Return references/metadata in an ordinary structure:

| Field | Contract |
| --- | --- |
| `inputTypes` | Ordered full normalized requirements; the sequence stores canonical TypeRef references, not arbitrary physical DATA fields |
| `resultType` | Full result requirement, including explicit void |
| `hasResult` | Result presence; never inferred from a zero pointer |
| `names` | Public labels of the inspected signature/candidate in semantic position order |
| `throws` | Declared named outcomes as canonical LMX strings |
| `declarations` | References to actual selected source declarations, preserving modifiers, initializer origin and own names |

Methods, const properties, free names and `return` are not promoted to formal inputs merely because they occur physically in DATA. Names/defaults/required/private/throws are not added to signature identity. Actual candidate policy remains distinct from a matching named template's policy. Existing call/type tables can serve this metadata without repeated full walks.

### normalizeType(token)

Accept the existing TYPE forms and return a direct canonical TypeRef to the
immutable system Structure describing the complete normalized requirement.
A ready canonical type description is already that result. An uninitialized
`T` declaration contributes its requirement without reading absent payload;
explicit void retains the absence of a result. Full Structure, callable, Array,
pointer and qualifier requirements remain intact. A plain initialized int is
not a TYPE code and must not be reinterpreted as a descriptor address.

Postfix `[]T`, `[N]T`, `@T` and dynamic rank/pointer forms produce TypeRef through
the common canonicalizer. The complete normalized constructing description alone
determines type identity: `[][]int` and `[](2)int` share a descriptor;
initializer rows, actual length and reserve do not refine it. `[]: value` retains
uninitialized AnyArray, and `[]@: value` the ordinary Structure/reference-array
requirement. Neither form allocates a typed backing merely by naming a type.

The old int-code source prototypes are pending ABI migration. Invalid TYPE
inputs retain the ordinary `FxTypeToken` boundary; they do not enable a second
numeric-code compatibility path.

### signatureData(inputs; result; labels)

Build ordinary DATA declarations from normalized requirements. Labels match the input count; R=void means no return declaration. Type-only inputs are ordinary uninitialized declarations with no invented default or automatic required/private modifier. Generated pN labels select public positions; candidate autofill keeps the candidate's own names.

### callable(contract; labels; bodyGraph; state; failures; policy)

Build real owner → DATA → CODE. `node\private\state` is the passed explicit state by reference. Generated CODE's actual parent is its own DATA. The policy is retained by reference in an ordinary `node\private\inputPolicy` graph field; it is not a hidden native field or a factory-local address. State is not implicitly copied per invocation. Failure names are validated, interned and deduplicated before publication.

`contract` supplies exact public inputs and R/void. `policy` supplies actual input behavior:

- **Source policy:** `source` identifies the real callable; `positions` maps public inputs to its source formals; `boundPositions/boundValues` retain ready captured values; `pendingPositions` identifies future curry inputs.
- **Own policy:** the explicitly chosen new contract's DATA supplies its ordinary declarations. A type-only constructor does not inherit defaults from unrelated source functions.
- The disjoint position sets cover source positions. The LMX `FxSourcePolicy` validates the map; ordinary admission validates actual values.
- Public maps, required applicability, duplicates, excess actuals and named selection are checked at the ordinary pre-effect stage. Explicit expressions are prepared once in written order. Omission is never encoded by a fake value.
- Keep full source DATA places, initializer provenance and source lexical node. A declaration actual remains its complete DATA Structure at the selected positional or explicitly outer-named destination; preserve its receiving-execution relationship if later executed. Do not select an input by its internal declared name. Removing a captured input from the public list does not remove its target place.
- Preserve both private filters and own-versus-transparent-place behavior. Do not make engine locals sources for target autofill. Do not collect descendant free names or bypass intermediate ordinary calls.
- For a non-final curry stage, only its current projected input is selected as a public input. Future inputs are not missing mandatory inputs of a full call which has not been attempted. A demanded current default can still read source declarations under their ordinary uninit/default rules.

The builder associates this explicit policy with the existing preparation entry. It must not copy default text into a different lexical environment. The source call can be prepared without entering its body, exposed to the engine, then entered exactly once. Pending frame state is ordinary execution service state, not a second program graph. A fix self-edge is wired before publication; construction does not execute or read an interim uninitialized self placeholder.

No target/default runs at construction. No generated text is reparsed per call. No automatic native compilation or foreign-ABI reuse is added.

### attempt(operation; args; failures)

Perform an ordinary call from a **ready finite sequence of actual values**. The sequence may be Structure/[]@ or a dense Array; typed access uses the actual element type/stride. []@ is read directly; a dense native argument can use its normal ABI without a mandatory record allocation. The bridge does not reinterpret dense backing as pointers or create an extra items container.

The number of actuals may be smaller than the full formal count. The actual candidate's defaults, required/private and ordinary binding rules govern remaining positions. A ready Structure element is exactly one actual; W/E and source expression evaluation are not repeated by this internal transport.

Return `FxOutcome {ok,value,failure,payload}`. Success contains a stable record of the true R. A procedure produces explicit void with no payload. A Structure/Array/callable result is referenced directly as its real typed value, without an obligatory extra @ wrapper.

Catch only admitted declared names in `failures`. Preserve the original name and typed payload. Implicit/system failures, stop/abort and invariant violations are not transformed into user Result values. Never return an expired native-local address or derive a type from bytes preceding a C local.

### raise(name; payload)

Resolve the canonical name in the generated CODE's declared outcome set, then use ordinary named throw delivery. No unchecked root context, wildcard `throws:*`, private bypass or general catch-all is introduced. A provider may generate finite ordinary catch/throw branches if no dynamic-name primitive exists.

This interface is used by generated CODE: `FxWrap\make` in
[generic_runtime.lmx](src/generic_runtime.lmx) emits the catch/rethrow boundary,
and `FxAsOperand\asOperand` in [coreStandardLisp.lmx](src/coreStandardLisp.lmx)
emits the failure branch for the prepared operand. Both emit
`FxKernel\raise(name := outcome\failure; payload := outcome\payload)`.
Construction only builds that ordinary CODE; the rethrow occurs when the
generated callable actually reaches the branch. Searching only for a direct
call outside source strings therefore misses the provider's consumers.
This remains a required provider contract, not evidence of runtime execution.

### fieldNames(source)

Read the existing owning-field association in physical order, including repeated names. A named field yields a ready LMX string; an anonymous field yields `uninit:[]char`, not an empty string or @0. `sys\name(identifier)` is a different source-identifier operation. No second name table is stored in graph fields.

### renameFields(target; indices; labels)

Validate the complete index/name update before writing. Preserve ordinary repeated-name semantics. The caller performs one shared-map `copy(source)` before renaming selected owning fields, preserving aliases, cycles and parent relationships. This operation is not whole-program text refactoring and does not rewrite every external path.

## 3. Five ordinary call-phase hooks

These hooks expose a pending ordinary invocation. Their provider is the remaining concrete kernel integration work. They are not five high-level implementations hidden behind opaque names.

### currentCall(owner)

Called directly from generated CODE, obtain the frame selected for that invocation. Validate that `owner` identifies the active generated call. Return a borrowed view with public `inputTypes`, source `operation`, source `failures`, and access to its existing selected places. The source namespace also contains bound/pending positions; public indices map through `policy.positions`.

Obtaining the view has no default/read/body effect. It exposes neither a factory environment nor arbitrary caller-frame selection. The generated call owns its lifetime and releases it on every exit, including once cache hits.

### frameSlot(frame; index; demand)

Validate lifetime and public index. With `demand=0`, report an ordinary observation:

| Field | Meaning |
| --- | --- |
| `supplied` | An explicit actual was supplied; independent of its value |
| `ready` | A ready value record is available without computation |
| `declaration` | A preserved supplied declaration form is present |
| `state` | value, declaration, default, autofill, uninit or future pending |
| `requirement` | The full selected input requirement |
| `ownPlace`, `transparentPlace` | The actual selected place relation |
| `value` | Present only when ready; a stable value record, not an address of a temporary local |

For ready actuals the view retains the accepted primitive value separately from later assignments to the target's own working formal, preserving the earlier pre/post/vector behavior. It does not freeze shared reference targets or replace actual transparent bindings. Deferred positions are read only when consumed; no hypothetical initializer snapshot is forced before a body assignment. Observation may materialize a stable record for an already ready native primitive; it invokes no initializer/converter and deep-copies no referent. Absence is represented by the flags and state, never by an invented explicit null actual.

With `demand=1`, perform one ordinary read of this selected place. Reuse its declaration form, source DATA/node, dependency places and current initialization state. Do not re-select binding or re-run an actual. Named failures during this demanded read propagate as `FxCallFailure(originalOutcome)` to the generic engine; implicit failures retain their normal path. A reached uninitialized payload read has its ordinary behavior.

### prepare(operation; entries)

Expose ordinary call preparation at the reached call site. Each finite entry contains a destination position and one of the existing transport kinds. Validate the maps before effects; do not derive the destination from a declaration's internal name.

| Kind | Required interpretation |
| --- | --- |
| `ready` | An already prepared typed value record received under the destination's ordinary contract. |
| `place` | Internal transport of an already selected source place, addressed by destination position and `(frame, sourcePosition)`. This is not a source declaration actual and does not use declaration substitution. |
| `actual` | The already selected explicit occurrence, retaining its presence, original ready value or complete declaration Structure, and selected positional/outer-label map. Omission or an autofilled proxy does not become an explicit actual. |

The `place` provider must preserve demanded source reads, ordinary receiving admission, own-versus-transparent place semantics, omission and frame lifetime through the existing preparation mechanism. A source place containing a declaration Structure still supplies that Structure under ordinary admission; it is not automatically reduced to an initializer's primitive result. An `actual` containing a declaration remains ordinary DATA material: transfer executes no initializer, its internal name selects no input, and its subsequent execution follows the accepted-form/body contract.

No public new lazy collection is involved. The entry is temporary call transport; ordinary receiving places, admission and initializer machinery do the work. No second execution pass or repeated Structure expansion occurs. Additional omitted formals of the called function retain its own policy. Dynamic lookup uses the reached ordinary call chain, never a caller context supplied by the factory.

Return one owned prepared frame. Preparation executes no target body. Eagerly prepared explicit values keep their written order; preserved declaration descriptions remain deferred.

**Pending integration gate PA01:** support and validate the distinct `place` path without implementing it as a user declaration actual. The gate must demonstrate selective demand of primitive source inputs and ordinary admission of actual declaration Structures, including an internal name that coincides with another input. The records and LMX algorithms in this archive do not implement or prove that provider. See [the required distinction and evidence](tests/ADAPTER_ACCEPTANCE.md#place-actual-integration); all four execution directions remain `NOT_RUN`.

### enter(frame; failures)

Enter the previously selected source CODE exactly once using its actual DATA/node and the existing native/interpreter dispatch. Do not rerun selection, recompute actual mapping, reopen groups or bind in helper locals. Return the same true-R/void/named-failure outcome format as `attempt`.

The prepared input/transport view remains accessible to the wrapper through postconditions and trace until its owner releases it; this does not keep CODE locals or their addresses alive after the target exits. Ordinary finally/cleanup executes on the correct target exit; the service frame's lifetime does not delay language cleanup or keep invalid local references alive.

### releaseCall(frame)

Finish the ordinary service frame owned by `prepare`, including exceptional paths. `FxInvokeEntries` calls it in finally. Do not use it to release a wrapper-owned currentCall frame. Returned arena values remain valid under normal ownership; borrowed slots and deferred-frame references become invalid. A frame cannot be transferred across Message/Thread or retained by curry/once/memoize.

## 4. Why the bridge is narrow

The provider exposes existing signature, graph builder, namespace/call preparation, one-place access, body entry and named delivery. Algorithms in the LMX sources construct and check maps; choose stages; retain prefix values; create predicates' actual entries; build trace observations; build and compare memo keys; dispatch overload branches; manage cache/retry state; and loop through N actual uncurry stages.

Do not implement these algorithms again inside `FxKernel`. Equally, do not claim the provider is already present merely because similar internal functions probably exist. Bind the hooks to the actual kernel, with exact ownership and native dispatch evidence.

## 5. Acceptance and optimization

Run the current specification's [A01–A20](../../LMX_semantics.en.md#adapter-observations) and [B01–B11](../../LMX_semantics.en.md#uncurry-observations), the separate [PA01 integration gate](tests/ADAPTER_ACCEPTANCE.md#place-actual-integration), the prepared [adapter fixtures](tests/adapter_semantics.lmx), and [the package acceptance](tests/ACCEPTANCE.md) in I→I, I→N, N→I and N→N. Native tests must actually execute compiled methods. Compare journals, place identities, lifetime and partial failure order, not just final return values.

Optimize after correctness: use existing cached type relationships, prepared contracts, direct native ABI and real Array access; avoid copies of already-ready []@ vectors, whole-frame snapshots and repeated parsing. Measure direct/partial/once hit/miss/uncurry at equal work, including reads, calls and allocations. No measured speed claim is made in this archive.

The historical eight-hook source is retained under reference solely for provenance. The current callable contract includes policy and five phase hooks. A test of text, assembled file or declared effects is never recorded as runtime PASS.

## 6. Four common Array boundaries

The sequence and Regex implementations share the existing canonical type descriptions, descriptor, storage, admission and allocation services through four additional narrow operations. [SEQUENCES_IMPLEMENTATION.md §4](SEQUENCES_IMPLEMENTATION.md#4-four-precise-kernel-boundaries) defines them in full; declarations are included in `kernel_contracts.lmx`.

| Operation | Contract |
| --- | --- |
| `arrayInfo(source)` | Require an initialized Array/Structure; return `arrayType` and `elementType` as canonical TypeRef references, and `elementBits`, `dense`, `maxLength` as ordinary int metadata. Complete normalized descriptions preserve full nested requirements; the array profile is linear, and maxLength accounts for index and actual byte-size overflow. |
| `arrayRead(source,index)` | Return one direct stored value reference for []@ or an ordinary stable dense-T record using actual stride. Preserve full type/reference/uninit state where representable. Do not execute saved graph forms, require a value box, or pre-materialize the entire input. |
| `arrayAdmit(target,value)` | Before commit, prepare the value against the actual target's complete element requirement. []@ takes the direct reference independently of the former slot. Dense T uses permitted ordinary representation preparation; no hidden user converter/initializer is added. |
| `arrayWrite(target,index,value)` | Write an already prepared same-profile/admitted value with ordinary bounds/lifetime checks and no repeated full admission, converter or callback. Keep descriptor identity and parent links. |

`arrayRead` uses `ReceiverIndex`, `FxKernelFailure`, `FxTypeToken`; incompatible insertion uses `SequenceElement` from `arrayAdmit`. System/implicit failures retain their ordinary channels. A prepared native path may use direct typed loads/stores without observable boxing. These hooks contain no map/filter/range-replacement/matcher algorithm and add no Sequence value kind.

## Actor publication and Expression lowering

The same existing dispatcher serves both forms of every operation. P0 already preserves receiver forms in Expression; integration belongs in translator role routing, not a replacement lexer. The exact implementation contract for semantic family selection, whole-value capture before default admission, exact-R builders and source profiles is [PUBLICATION_CONTRACT.md](PUBLICATION_CONTRACT.md). These hooks reuse the interfaces above. Ordinary and backtick names share one decoded identity; symbolic callable spelling does not select a different role. Attached `++var`, `var++`, `--var`, `var--` remain unary PLACE operations with their specified before/after results.

<a id="pd01"></a>
## PD01 — operandDepthContext(frame; arguments)

The [common depth ABI](../../OPERATOR_DEPTH.en.md#abi) is left / depth / right.
The source declaration is `FxKernelOperandDepthContextAPI :: (@: frame; @: arguments; return: @)`.
The concrete provider is `FxKernel\operandDepthContext`.

This provider is an **integration requirement**, not an implemented stub.
Production implementation: **NOT_IMPLEMENTED_IN_THIS_DOCS_ARCHIVE**;
production execution: **NOT_RUN**. The LMX wrapper and common traversal
bodies are supplied separately and must not be replaced by a second opaque
algorithm inside this provider.

PD01 is reached only for a selected VALUE operand. `frame` retains its
original owner/caller context; the source ordinary callable is identified
by `policy\operandDepthSource`. Frame slots 0/1/2 hold left/depth/right;
the separately supplied `arguments` are already collected logical arguments
of the source, **without the wrapper's control depth**. A source formal
also named depth retains its own owner and ordinary argument semantics.

The result is a checked, operation-local context for the common
`FxArrayDepth` traversal:

| Context component | Obligation |
| --- | --- |
| `base` | The selected source ordinary callable; invoked only by the common executor |
| `hasResult` | 0 or 1; void traversals do not allocate Array<void> |
| `level(context; depth; inputs)` | Select logical dimensions using available or uniquely derivable axis information from the current canonical Array type description plus length; insufficient required information is diagnosed. Compact arrays have no secondary descriptor. Return checked `{hasArray,count,inputs,read,layout,write}` and preserve original-scalar provenance. `count` counts base applications after the selected axes, not necessarily scalar storage cells |
| `read(map; index)` in the frame | Obtain a selected scalar, ordinary Structure value or logical slice descriptor on the same existing storage. Do not allocate row Structures or a separate array-of-arrays representation |
| `write(output; index; value)` in the frame | Admit and store the selected base result in its prepared scalar or block output region |
| Full result requirement and `layout` | Preserve source R/void at depth 0 and scalar fixed points; determine the complete result shape/type without a probe call. A flat rectangular result uses one backing, without traversal-generated row containers |
| `publish(context; layout; result)` | Use the canonical TypeRef of the complete declared/evaluated result requirement. Required persistent output axes must be expressed in that requirement; initializer/layout data cannot secretly specialize a generic result type. For capacity=length publish no secondary descriptor; real reserve uses an optional capacity entry without a new TypeRef. Preserve ordinary identity and parent rules; do not extend Lmx or user fields |

The provider checks actual shapes and full input/result requirements from
the current ordinary records and shared type metadata. Shape and reserve
representations follow [canonical Array descriptions](../../ARRAY_STORAGE.en.md#array-profiles).
For a fixed shaped result, common construction allocates/initializes the valid
backing directly under the complete evaluated requirement before publication.
The old `FxSeqAllocate` empty-value-plus-resize helper only serves unconstrained
linear types; it cannot publish an empty `[2][3]int` or retag a ready generic
Array. Migrating that prototype is part of this boundary, without a second
allocator or growth mechanism.
An operation-local frame/layout is temporary and does not restore a mandatory
per-Array shape descriptor. A temporary plan may carry dimensions during one
expression; only the complete published result requirement persists them. Old
host checks do not validate this TypeRef ABI or its production allocation transitions. It does not evaluate
the source to infer a type, perform element arithmetic or execute another
lifting algorithm. The LMX engine obtains one frame, adds `frame.root`,
allocates only the admitted result layout through `FxArrayResultTree`, and
runs the common `FxArrayExpressionFill` loop. `FxArrayDepthCell` reads the
selected arguments and calls `FxArrayDepthBase` once per base application.
The selected logical axes can be linearized into that loop; no second
program graph or row-storage hierarchy is constructed. All effect order
and actual callable failures retain the selected callable's ordinary contract.

At depth 0, `FxArrayDepth` directly delegates to the base method, retaining
exact R/void. If all original actuals are scalar, the checked frame selects
the same scalar fixed point. An Array whose required dimensions run out
cannot silently become a scalar broadcast. For flat rank-2 inputs, depth 1
selects rows and depth 2 selects scalar coordinates. Ordinary Structure
paths, including `struct[i]\[j]`, continue to use general reference access;
they do not declare another container entity. The header remains
`parent/length/storage`, and the Array/Structure VALUE overload of
`sys\descriptor` still returns those three field addresses for ordinary values.
The canonical system-TYPE branch has priority for a TypeRef description and
returns that same description: `sys\descriptor(typeof(obj))` is not an int-code
lookup ([contract](../../ARRAY_STORAGE.en.md#type-descriptor)). It allocates no
second descriptor for an Array.

A wrapper whose depth may change the logical return type cannot keep an
unconditional scalar R declaration for a lifted result. The existing
adaptive call preparation must select and admit the full requirement
before entry. Native dispatch must use the corresponding already prepared
ABI; this change does not authorize hidden compilation on demand, mutation
of the source callable description, or universal boxing of every result.
A statically depth-0 call retains the original exact R/void route.

RAW, DATA, TYPE and PLACE consumers are not routed through this VALUE
provider merely because they expose the same three input names. Their
selected receiving contract either implements its own depth behavior or
reports an unsupported depth as a translator/interpreter diagnostic. Invalid depth, inconsistent required Array levels/shapes and ineligible fusion do not introduce user exceptions or extra throws. Real callback failures retain their existing channels.
