# Kernel integration requirements

**Integration source, not a completed runtime.** The archive contains LMX algorithms and internal bridge contracts. It contains no implementation repository for the LMX kernel. The real kernel must supply or expose the ordinary mechanisms below and execute the acceptance matrix. An interface declaration is not an implementation of that interface.

The normative adapter requirements are [the current semantics](../../LMX_semantics.en.md#adapter-behavior). The concrete LMX implementation, binding points and outstanding checks are explained in [ADAPTER_IMPLEMENTATION.md](ADAPTER_IMPLEMENTATION.md).

## 1. Common architecture

Use one parser, one complete source graph, ordinary owner/DATA/CODE and existing Message arenas. A generated callable is an ordinary callable with genuine parent links. No second expanded executable graph, permanent namespace copy, hidden global closure environment, new lazy-array VM or alternative bytecode engine is permitted.

Signature inspection and `satisfies` execute no candidate, default, test or converter. Source expressions and declaration actuals keep their normal effect timing. Compilation remains explicit; a new ABI never borrows an incompatible native entry. Permitted graph changes and compiled-call validity follow the existing `endturn` rules.

P0 retains every written group. The common operand handler opens one outer RHS group only when the written left is anonymous, there is exactly one right argument, and that right argument is a written anonymous Structure. The left remains whole. Returned Structures and references do not satisfy that source-form exception. Ordinary callable W/E remains separate.

`Name :: DATA` uses the general Expression/`OPERANDS_TEMPLATE` mechanism and one whole right DATA argument. It does not open a Frame or invent an `end:` target. `signatureTypes` retains its existing operand and explicit named-call forms. Both create the same positional signature kind, with the existing named-signature/`call` relationship unchanged.

All public receivers are part of the one current kernel namespace. `fun\const` is a physical source export group, not an optional package version or second registry. Service inputs remain private; source user inputs retain their individual policy.

The current package has **17 integration bridges**: the eight interfaces in §2, five ordinary call-phase hooks in §3, and four common Array boundaries in §6. These are internal boundaries, separate from the **115 public callable/operand names** and **24 other exported symbols** listed in the [catalog](CATALOG.md) and [value-symbol inventory](value_symbols.json).

## 2. Existing narrow bridges

Declarations are in [kernel_contracts.lmx](src/kernel_contracts.lmx). `FxKernel` is an internal integration name, not a new family of user pseudopackages.

### signature(subject)

Read the selected ordinary callable or signature description using the real analyzer. Return references/metadata in an ordinary structure:

| Field | Contract |
| --- | --- |
| `inputTypes` | Ordered full normalized requirements; the sequence stores type-code records, not arbitrary physical DATA fields |
| `resultType` | Full result requirement, including explicit void |
| `hasResult` | Result presence; never inferred from a zero pointer |
| `names` | Public labels of the inspected signature/candidate in semantic position order |
| `throws` | Declared named outcomes as canonical LMX strings |
| `declarations` | References to actual selected source declarations, preserving modifiers, initializer origin and own names |

Methods, const properties, free names and `return` are not promoted to formal inputs merely because they occur physically in DATA. Names/defaults/required/private/throws are not added to signature identity. Actual candidate policy remains distinct from a matching named template's policy. Existing call/type tables can serve this metadata without repeated full walks.

### normalizeType(token)

An initialized int token's **payload** is the type code; `typeof` of that token is still int. An uninitialized `T` token contributes its type without reading nonexistent payload. Explicit void retains absence of a result. A valid existing model preserves the complete Structure/callable/Array requirements and qualifiers through the current type registry.

The bridge's `@` return is an internal reference to the canonical ordinary int-code record, whose code resolves through the existing full type/model description. It is not a new public boxed Type value or permission to replace every model by the physical tag of `@`. Invalid codes produce `FxTypeToken`.

Postfix `T[]` and `T@` produce ordinary interned int codes. `int@@`, `int[]@`, `int@[]` retain their actual levels. `[]: value` means uninitialized AnyArray; `@[]: value` means the Structure/general-reference-array requirement. Neither is a typed allocation disguised as a type code.

### signatureData(inputs; result; labels)

Build ordinary DATA declarations from normalized requirements. Labels match the input count; R=void means no return declaration. Type-only inputs are ordinary uninitialized declarations with no invented default or automatic required/private modifier. Generated pN labels select public positions; candidate autofill keeps the candidate's own names.

### callable(contract; labels; bodyGraph; state; failures; policy)

Build real owner → DATA → CODE. `node\private\state` is the passed explicit state by reference. Generated CODE's actual parent is its own DATA. The policy is retained by reference in an ordinary `node\private\inputPolicy` graph field; it is not a hidden native field or a factory-local address. State is not implicitly copied per invocation. Failure names are validated, interned and deduplicated before publication.

`contract` supplies exact public inputs and R/void. `policy` supplies actual input behavior:

- **Source policy:** `source` identifies the real callable; `positions` maps public inputs to its source formals; `boundPositions/boundValues` retain ready captured values; `pendingPositions` identifies future curry inputs.
- **Own policy:** the explicitly chosen new contract's DATA supplies its ordinary declarations. A type-only constructor does not inherit defaults from unrelated source functions.
- The disjoint position sets cover source positions. The LMX `FxSourcePolicy` validates the map; ordinary admission validates actual values.
- Public maps, required applicability, duplicates, excess actuals and named selection are checked at the ordinary pre-effect stage. Explicit expressions are prepared once in written order. Omission is never encoded by a fake value.
- Keep full source DATA places, initializer provenance, source lexical node and declaration actual namespace substitution. Removing a captured input from the public list does not remove its target place.
- Preserve both private filters and own-versus-transparent-place behavior. Do not make engine locals sources for target autofill. Do not collect descendant free names or bypass intermediate ordinary calls.
- For a non-final curry stage, only its current projected input is selected as a public input. Future inputs are not missing mandatory inputs of a full call which has not been attempted. A demanded current default can still read source declarations under their ordinary uninit/default rules.

The builder associates this explicit policy with the existing preparation entry. It must not copy default text into a different lexical environment. The source call can be prepared without entering its body, exposed to the engine, then entered exactly once. Pending frame state is ordinary execution service state, not a second program graph. A fix self-edge is wired before publication; construction does not execute or read an interim uninitialized self placeholder.

No target/default runs at construction. No generated text is reparsed per call. No automatic native compilation or foreign-ABI reuse is added.

### attempt(operation; args; failures)

Perform an ordinary call from a **ready finite sequence of actual values**. The sequence may be Structure/@[] or a dense Array; typed access uses the actual element type/stride. @[] is read directly; a dense native argument can use its normal ABI without a mandatory record allocation. The bridge does not reinterpret dense backing as pointers or create an extra items container.

The number of actuals may be smaller than the full formal count. The actual candidate's defaults, required/private and ordinary binding rules govern remaining positions. A ready Structure element is exactly one actual; W/E and source expression evaluation are not repeated by this internal transport.

Return `FxOutcome {ok,value,failure,payload}`. Success contains a stable record of the true R. A procedure produces explicit void with no payload. A Structure/Array/callable result is referenced directly as its real typed value, without an obligatory extra @ wrapper.

Catch only admitted declared names in `failures`. Preserve the original name and typed payload. Implicit/system failures, stop/abort and invariant violations are not transformed into user Result values. Never return an expired native-local address or derive a type from bytes preceding a C local.

### raise(name; payload)

Resolve the canonical name in the generated CODE's declared outcome set, then use ordinary named throw delivery. No unchecked root context, wildcard `throws:*`, private bypass or general catch-all is introduced. A provider may generate finite ordinary catch/throw branches if no dynamic-name primitive exists.

### fieldNames(source)

Read the existing owning-field association in physical order, including repeated names. A named field yields a ready LMX string; an anonymous field yields `uninit:char[]`, not an empty string or @0. `sys\name(identifier)` is a different source-identifier operation. No second name table is stored in graph fields.

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

Expose ordinary call preparation at the reached call site. Each finite entry contains a destination position and either a ready typed record, a borrowed source-place reference, or a reference to an already selected explicit actual occurrence. The last form preserves presence and the original ready value/declaration form; it never turns omission or an autofilled proxy into an explicit actual. Maps are validated before effects. Ready entries are already prepared values. A place entry uses the existing preserved declaration-actual mechanism: its initializer reads the selected source place only when consumed. If the source supplied a declaration form, retain that form and its namespace substitution contract instead of erasing it into a value.

No public new lazy collection is involved. The entry is temporary call transport; ordinary receiving places, admission and initializer machinery do the work. No second execution pass or repeated Structure expansion occurs. Additional omitted formals of the called function retain its own policy. Dynamic lookup uses the reached ordinary call chain, never a caller context supplied by the factory.

Return one owned prepared frame. Preparation executes no target body. Eagerly prepared explicit values keep their written order; preserved declaration descriptions remain deferred.

### enter(frame; failures)

Enter the previously selected source CODE exactly once using its actual DATA/node and the existing native/interpreter dispatch. Do not rerun selection, recompute actual mapping, reopen groups or bind in helper locals. Return the same true-R/void/named-failure outcome format as `attempt`.

The prepared input/transport view remains accessible to the wrapper through postconditions and trace until its owner releases it; this does not keep CODE locals or their addresses alive after the target exits. Ordinary finally/cleanup executes on the correct target exit; the service frame's lifetime does not delay language cleanup or keep invalid local references alive.

### releaseCall(frame)

Finish the ordinary service frame owned by `prepare`, including exceptional paths. `FxInvokeEntries` calls it in finally. Do not use it to release a wrapper-owned currentCall frame. Returned arena values remain valid under normal ownership; borrowed slots and deferred-frame references become invalid. A frame cannot be transferred across Message/Thread or retained by curry/once/memoize.

## 4. Why the bridge is narrow

The provider exposes existing signature, graph builder, namespace/call preparation, one-place access, body entry and named delivery. Algorithms in the LMX sources construct and check maps; choose stages; retain prefix values; create predicates' actual entries; build trace observations; build and compare memo keys; dispatch overload branches; manage cache/retry state; and loop through N actual uncurry stages.

Do not implement these algorithms again inside `FxKernel`. Equally, do not claim the provider is already present merely because similar internal functions probably exist. Bind the hooks to the actual kernel, with exact ownership and native dispatch evidence.

## 5. Acceptance and optimization

Run the current specification's [A01–A20](../../LMX_semantics.en.md#adapter-observations) and [B01–B11](../../LMX_semantics.en.md#uncurry-observations), the prepared [adapter fixtures](tests/adapter_semantics.lmx), and [the package acceptance](tests/ACCEPTANCE.md) in I→I, I→N, N→I and N→N. Native tests must actually execute compiled methods. Compare journals, place identities, lifetime and partial failure order, not just final return values.

Optimize after correctness: use existing cached type relationships, prepared contracts, direct native ABI and real Array access; avoid copies of already-ready @[] vectors, whole-frame snapshots and repeated parsing. Measure direct/partial/once hit/miss/uncurry at equal work, including reads, calls and allocations. No measured speed claim is made in this archive.

The historical eight-hook source is retained under reference solely for provenance. The current callable contract includes policy and five phase hooks. A test of text, assembled file or declared effects is never recorded as runtime PASS.

## 6. Four common Array boundaries

The sequence and Regex implementations share the existing type table, descriptor, storage, admission and allocation services through four additional narrow operations. [SEQUENCES_IMPLEMENTATION.md §4](SEQUENCES_IMPLEMENTATION.md#4-four-precise-kernel-boundaries) defines them in full; declarations are included in `kernel_contracts.lmx`.

| Operation | Contract |
| --- | --- |
| `arrayInfo(source)` | Require an initialized Array/Structure; return `arrayType`, `elementType`, `elementBits`, `dense`, `maxLength` as ordinary int metadata. Canonical codes preserve full nested requirements; the array profile is linear, and maxLength accounts for index and actual byte-size overflow. |
| `arrayRead(source,index)` | Return one direct stored value reference for @[] or an ordinary stable dense-T record using actual stride. Preserve full type/reference/uninit state where representable. Do not execute saved graph forms, require a value box, or pre-materialize the entire input. |
| `arrayAdmit(target,value)` | Before commit, prepare the value against the actual target's complete element requirement. @[] takes the direct reference independently of the former slot. Dense T uses permitted ordinary representation preparation; no hidden user converter/initializer is added. |
| `arrayWrite(target,index,value)` | Write an already prepared same-profile/admitted value with ordinary bounds/lifetime checks and no repeated full admission, converter or callback. Keep descriptor identity and parent links. |

`arrayRead` uses `ReceiverIndex`, `FxKernelFailure`, `FxTypeToken`; incompatible insertion uses `SequenceElement` from `arrayAdmit`. System/implicit failures retain their ordinary channels. A prepared native path may use direct typed loads/stores without observable boxing. These hooks contain no map/filter/range-replacement/matcher algorithm and add no Sequence value kind.
