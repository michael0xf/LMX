# Standard object, Option and Result operations

Edition: 23 November 2026. This adds **16 complete LMX operations** to the existing core. It does not introduce another container representation, native provider, default deep copy, or implicit null-to-absence conversion.

## Implemented contracts

All `value`, `fallback`, `reason` and returned value records below follow the existing `{type,value}` protocol. Ordinary result admission preserves the real primitive, Structure, Array or callable value; it does not impose another `@` box. A deliberately declared reference payload retains that reference level. See [typed records](src/generic_runtime.lmx), [Maybe/Result](src/containers.lmx) and [binding](../../LMX_semantics.en.md#binding-places).

| Public name | Inputs | Contract |
| --- | --- | --- |
| `mapOption` | `input; transform` | Map one present payload to a new Maybe; absent input skips transform; Some(null) stays present. |
| `filterOption` | `input; accepts` | Retain the same present container when an int predicate accepts its payload; absent or rejected input yields absence. |
| `orElse` | `input; fallback` | Return the existing payload record or an already evaluated fallback record; result is not a Maybe. |
| `orElseGet` | `input; fallback` | Return the payload record; invoke a nullary fallback only when absent. |
| `orElseOption` | `input; fallback` | Return the original present Maybe, or call the nullary fallback once and return its Maybe unchanged. |
| `foldOption` | `input; whenEmpty; whenPresent` | Invoke exactly one branch, a nullary absent branch or unary payload branch; return its typed result record. |
| `flattenOption` | `input` | Flatten one Maybe-of-Maybe level, retaining the nested container identity; absent outer input skips payload access. |
| `mapResult` | `input; transform` | Map only success payload into a fresh ok result; retain the existing error container without invoking transform. |
| `mapErr` | `input; transform` | Map only error payload into a fresh err result; retain the existing success container without invoking transform. |
| `orElseResult` | `input; fallback` | Invoke one error-to-Result continuation only on err; return its Result without nesting; success identity retained. |
| `foldResult` | `input; onError; onSuccess` | Invoke exactly one unary branch with the corresponding typed payload; return its result record. |
| `attempt` | `operation; args=()` | Invoke through existing FxTry; return ok(result record) or err(typed reference record to full original FxOutcome); kernel/admission failures propagate. |
| `tap` | `value; action` | Call one effect with the actual typed payload and return the exact original value record; no deep copying or swallowing failure. |
| `findField` | `source; label; occurrence` | Maybe of the selected physical field record; required zero-based occurrence counts equal ready names only; no payload evaluation. |
| `hasField` | `source; label; occurrence` | Whether that physical named occurrence exists; named uninitialized payloads count as present; no payload evaluation. |
| `getField` | `source; label; occurrence` | Return the existing selected field record; missing or negative occurrence raises FxIndex; no payload evaluation. |

## Why these names remain distinct

`orElse` follows Java Optional.orElse and returns a payload record with an already evaluated fallback. `orElseGet` takes a lazy nullary fallback and also returns a payload. `orElseOption` follows C++/Rust/Scala and returns a Maybe container. Conflating them would make a returned container ambiguous. Existing `map` maps sequences, including structural values, so `mapOption` and `mapResult` avoid changing its selection rules. `mapErr` retains the familiar Rust spelling in lowerCamelCase.

## Reuse and failures

`foldOption` is composed from `mapOption` and `orElseGet`; it contains no second branch-selection algorithm. `bind` and `bind` remain the existing flat-map operations. `tap` calls its effect once and returns the original record, with reference identity preserved. Mutable referenced objects are not secretly snapshotted.

`orElseOption`, `orElseResult` and `flattenOption` follow the existing FxBind/FxBindResult result-admission path. An actual Maybe/Result is admitted directly, with no unconditional dereference. Direct container results and a container carrying a reference payload are separate acceptance cases; the two are not collapsed by inventing another wrapper.

`attempt` is implemented through the existing FxTry bridge. Success stores the original result record, including the explicit void state. Failure stores a typed reference record to the complete FxOutcome, retaining both the original failure name and its typed payload. Undeclared kernel/admission failures keep the ordinary path. `attempt` is therefore not an indiscriminate exception catcher.

Unselected callbacks are not entered. Already evaluated actual arguments remain evaluated according to the language rules; lazy behavior applies to the explicitly passed fallback/branch callable, not to arbitrary code used to construct its reference. The operations require the stated admitted Maybe/Result/callback inputs; they do not imitate foreign-language validation of every invalid value.

## Complete source and cost

[coreStandardObjects.lmx](src/coreStandardObjects.lmx) is the canonical complete source. Its 16 public definitions and one shared input description contain **3771 nonwhitespace characters**, excluding comments outside definitions. The complete file, including all explanatory comments, contains **5152 nonwhitespace characters**. [Integration metadata](CORE_STANDARD_OBJECT_ADDITIONS.json) records each definition, export, scope and hash. No new kernel primitive is required for these 16 functions.

Common dependencies are FxApply/FxTry, FxOne/FxRecords, the existing constructors, predicate truth admission and the shared failure sets. Their bodies already belong to the current core and are counted once in its source inventory; they are not redefined in every example.

## Reviewed standard facilities

This is a family-by-family coverage review of the object/optional/result/resource facilities below. Sequence algorithms, text/numeric operations and Common Lisp facilities are covered in their companion reviews; this table does not claim every API of every standard library.

| Language | Facility | LMX decision | Status | Boundary |
| --- | --- | --- | --- | --- |
| Java | [Optional.map / filter](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Optional.html) | mapOption / filterOption | implemented | LMX retains Some(null); Java Optional.map treats a null mapper result as absence. |
| Java | [Optional.bind](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Optional.html) | bind | existing | Existing Maybe chaining; no second bind algorithm. |
| Java | [Optional.orElse](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Optional.html) | orElse | implemented | Eager payload fallback; never returns the Maybe container. |
| Java | [Optional.orElseGet](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Optional.html) | orElseGet | implemented | Nullary fallback invoked only on absence. |
| Java | [Optional.or](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Optional.html) | orElseOption | implemented | Lazy replacement container; no nested Maybe. |
| Java | [Optional.ifPresent / ifPresentOrElse](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Optional.html) | foldOption / tap | covered_composition | Effects are explicit callbacks; discarded result remains ordinary void/value record. |
| Rust | [Option.map / filter / flatten](https://doc.rust-lang.org/std/option/enum.Option.html) | mapOption / filterOption / flattenOption | implemented | Stored payload type and null value remain explicit. |
| Rust | [Option.unwrap_or / unwrap_or_else](https://doc.rust-lang.org/std/option/enum.Option.html) | orElse / orElseGet | implemented | Returns the chosen value record; caller reads its actual type. |
| Rust | [Option.or_else](https://doc.rust-lang.org/std/option/enum.Option.html) | orElseOption | implemented | Alternative container, distinct from eager payload fallback. |
| Rust | [Option.map_or_else](https://doc.rust-lang.org/std/option/enum.Option.html) | foldOption | implemented | One lazy branch; no fabricated value for None. |
| Rust | [Result.map / map_err](https://doc.rust-lang.org/std/result/enum.Result.html) | mapResult / mapErr | implemented | Only the selected channel is transformed. |
| Rust | [Result.or_else](https://doc.rust-lang.org/std/result/enum.Result.html) | orElseResult | implemented | Error continuation returns a Result, not an error payload. |
| Rust | [Result.map_or_else](https://doc.rust-lang.org/std/result/enum.Result.html) | foldResult | implemented | Exactly one branch receives its typed payload. |
| Rust | [Result.and_then](https://doc.rust-lang.org/std/result/enum.Result.html) | bind | existing | The existing success-chain operation is reused. |
| Rust | [Result.inspect / inspect_err](https://doc.rust-lang.org/std/result/enum.Result.html) | tag selection + tap | covered_composition | tap is a value effect; tag selection remains explicit, rather than pretending two tags are equal. |
| Rust | [Result ? propagation](https://doc.rust-lang.org/std/result/enum.Result.html) | bind / catch | covered_composition | No new source-rewriting propagation operator is required for these finite chains. |
| Scala | [Option.map / filter / flatten](https://www.scala-lang.org/api/2.13.16/scala/Option.html) | mapOption / filterOption / flattenOption | implemented | No eager evaluation of the absent callback. |
| Scala | [Option.getOrElse](https://www.scala-lang.org/api/2.13.16/scala/Option.html) | orElseGet | implemented | Scala default is by-name; the LMX equivalent takes an explicit thunk. |
| Scala | [Option.orElse](https://www.scala-lang.org/api/2.13.16/scala/Option.html) | orElseOption | implemented | Returns a replacement Option container lazily. |
| Scala | [Option.fold](https://www.scala-lang.org/api/2.13.16/scala/Option.html) | foldOption | implemented | Absent thunk and present mapper use the normal call contract. |
| Scala | [ChainingOps.tap](https://www.scala-lang.org/api/2.13.16/scala/util/ChainingOps.html) | tap | implemented | The exact input record returns after one callback. |
| Scala | [ChainingOps.pipe](https://www.scala-lang.org/api/2.13.16/scala/util/ChainingOps.html) | ordinary call / apply | existing | A value is passed to a function; composition pipe already has a separate callable-to-callable contract. |
| C++ | [optional.transform](https://eel.is/c++draft/optional.monadic) | mapOption | implemented | Typed value result; C++ cv/ref/move ownership rules are not claimed for LMX. |
| C++ | [optional.and_then](https://eel.is/c++draft/optional.monadic) | bind | existing | No duplicate implementation of Maybe bind. |
| C++ | [optional.or_else](https://eel.is/c++draft/optional.monadic) | orElseOption | implemented | Lazy alternative container. |
| C# | [??](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/operators/null-coalescing-operator) | orElseGet after explicit absence normalization | covered_composition | LMX none is distinct from a present null; the caller chooses the nullability policy. |
| C# | [??=](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/operators/null-coalescing-operator) | explicit assignment of the selected fallback | covered_composition | Does not imply mutation of the source Maybe through a hidden alias. |
| JavaScript / TypeScript | [Object.assign / object spread](https://tc39.es/ecma262/multipage/fundamental-objects.html#sec-object.assign) | merge / derive | existing_with_difference | LMX merge returns copied composition; it is not JavaScript in-place property assignment or getter execution. |
| JavaScript / TypeScript | [Object.keys / values / entries](https://tc39.es/ecma262/multipage/fundamental-objects.html#sec-object.keys) | names + sequence access / zip | existing_with_difference | LMX retains physical fields, repeated names and anonymous uninitialized names; JS enumerable property rules are not asserted. |
| Go | [defer](https://go.dev/ref/spec#Defer_statements) | finally / bracket | existing_with_difference | Uses LMX cleanup lifetime and failure policy, not Go panic/recover behavior. |
| Go | [panic / recover](https://go.dev/ref/spec#Handling_panics) | declared throw / catch / attempt | implemented_with_difference | attempt catches only the operation's declared recoverable failures, not every runtime failure. |
| Erlang | [try ... catch ... after](https://www.erlang.org/doc/system/expressions.html#try) | catch / finally / bracket | existing | Message ownership and typed failures remain the LMX contract. |
| Erlang | [case {ok,Value} / {error,Reason}](https://www.erlang.org/doc/system/expressions.html#try) | foldResult | implemented | Explicit tagged Result payloads, not Erlang atom or tuple representation. |
| Resource combinators in this review | [resource/context-manager acquisition](https://go.dev/ref/spec#Defer_statements) | bracket | existing | Existing bracket handles one acquire/action/release lifetime; language-specific scopes and async resource protocols remain separate. |
| JavaScript / TypeScript | [Object.hasOwn / runtime property access](https://tc39.es/ecma262/multipage/fundamental-objects.html#sec-object.hasown) | findField / hasField / getField | implemented_with_difference | Physical owning fields, explicit occurrence; anonymous nil and ready empty names differ; no JS prototype/getter semantics. |
| Concurrency boundary | [shared-memory atomic field update](https://pkg.go.dev/sync/atomic) | owning Message / existing native contract | not_equated | LMX owning Message execution is not a lock-free shared-memory atomic read-modify-write implementation. |
| Rust | [Option.is_some / is_none / is_some_and / is_none_or](https://doc.rust-lang.org/std/option/enum.Option.html) | present tag / foldOption | covered_composition | Tag reads are already one field access; conditional predicates use one branch without a new representation. |
| Rust | [Option.ok_or / ok_or_else](https://doc.rust-lang.org/std/option/enum.Option.html) | foldOption + ok/err | covered_composition | Explicit constructors distinguish eager error values from lazy error callbacks. |
| Rust | [Option.or / and / xor](https://doc.rust-lang.org/std/option/enum.Option.html) | present tags + ordinary branch | covered_composition | These eager finite choices do not justify duplicating the existing tag-selection algorithm in another representation. |
| Rust | [Option.take / replace / insert / get_or_insert_with](https://doc.rust-lang.org/std/option/enum.Option.html) | ordinary owning-field update + orElseGet | covered_composition | Mutation must be requested explicitly and performed by the owner; pure fallback helpers do not mutate Maybe. |
| Rust | [Option.zip / unzip / transpose](https://doc.rust-lang.org/std/option/enum.Option.html) | foldOption / bind + existing pair/list constructors | covered_composition | Finite container rearrangement uses existing tags; sequence transpose is a different existing contract. |
| Rust | [Option.as_ref / as_mut / cloned / copied](https://doc.rust-lang.org/std/option/enum.Option.html) | ordinary reference / copy policy | existing_with_difference | LMX does not import Rust borrow lifetimes or move semantics under a familiar name. |
| Rust | [Result.is_ok / is_err / ok / err projections](https://doc.rust-lang.org/std/result/enum.Result.html) | ok tag / foldResult + some/none | covered_composition | One chosen channel; projection absence is distinct from a null payload. |
| Java | [Objects.isNull / nonNull / requireNonNull](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Objects.html) | ordinary @ null check / named throw | covered_composition | The check is already one expression; typed nil absence is distinct from an initialized null pointer. |
| Java | [Objects.equals / deepEquals / compare](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Objects.html) | matches / equalFields / explicit comparator | existing_with_difference | Generic object equality and hash policy are not inferred from field names or reference bytes. |
| Java | [Objects.hash / hashCode](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Objects.html) | explicit caller key/equality policy | not_equated | Existing memoize takes sameKey; a universal foreign object hash is not fabricated from arbitrary graph identity. |
| Java | [Objects.checkIndex / checkFromToIndex / checkFromIndexSize](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Objects.html) | existing checked index/slice/size admission | existing | Existing sequence implementation validates the requested span before mutation. |
| C++ | [std::invoke / invoke_r](https://eel.is/c++draft/func.invoke) | ordinary call / apply | existing_with_difference | LMX uses its normal input/result admission; C++ cv/ref/noexcept rules are not claimed. |
| Erlang | [maps:find / get / is_key](https://www.erlang.org/doc/apps/stdlib/maps.html) | findField / getField / hasField; assoc for arbitrary keys | implemented_with_difference | Physical text-named Structure fields use explicit occurrence; arbitrary typed map keys use the separately implemented association-list representation. |
| Erlang | [maps:keys / values / to_list / map / fold / filter](https://www.erlang.org/doc/apps/stdlib/maps.html) | names + sequence access + map/fold/filter | covered_composition | Graph field semantics retain repeats and anonymous fields; no unordered unique-key map semantics are silently assumed. |
| Go | [maps.Equal / EqualFunc / Keys / Values](https://pkg.go.dev/maps) | equalFields with explicit map policy / association-list traversal | existing_with_difference | Hash-map key uniqueness and unspecified iteration order are not physical Structure-field semantics. |
| Go | [maps.Clone / Copy / DeleteFunc / Insert / Collect](https://pkg.go.dev/maps) | explicit association-list or owning-map representation | not_equated | Graph copy, shallow row aliasing and map entry copying have different mutation/identity contracts; no fake Go map provider is added. |
| Java | [try-with-resources / suppressed exceptions](https://docs.oracle.com/javase/specs/jls/se21/html/jls-14.html#jls-14.20.3) | bracket for one lifetime; explicit suppression policy for parity | existing_with_difference | Release-after-acquire is covered; Java primary/suppressed exception ordering is not the default LMX finally policy. |
| Scala | [Using / Using.Manager](https://www.scala-lang.org/api/2.13.16/scala/util/Using$.html) | bracket / nested bracket with explicit failure policy | existing_with_difference | Reverse release order can be composed; Scala severity/suppression selection is a separate contract. |

## Physical-name lookup without a new primitive

`findField(source; label; occurrence)` searches only the existing physical fields of `source`. `occurrence` is required and zero based among equal ready names. Repeated names remain distinct; there is no implicit unique-key map conversion. It returns a Maybe containing the existing field record. `hasField` reads only that Maybe tag; `getField` returns the record or raises `FxIndex` for absence. A negative ordinal also raises `FxIndex`.

The loop is written once in `FxFindField`. The three input contracts use one `copy(FxFieldArguments)`. `RxNames` already exposes canonical owning-field names, and the current [primitive/absence contract](../../LMX_semantics.en.md#receiver-args-only) permits a comparison with `nil` without reading nonexistent value bytes. The loop checks that state before calling the existing shared `FxEqualFields` body. No new public string-equality function is added; a public exact literal match already uses `matches(byteText(source); literalText)` with case-sensitive units and no normalization. A ready empty name is not an anonymous name. A named uninitialized payload is still an existing field; a computed declaration is returned as its graph record without running its initializer.

This adds neither dynamic source parsing nor a private namespace bypass. The operations use existing field-name and physical-value access under their ordinary protection/ownership contracts. The [integration acceptance contract](CORE_STANDARD_OBJECTS_CONTRACT.md) records the checks, including native/interpreter directions. It requires no new receiver, primitive or provider.

## Acceptance

[standard_objects_cases.json](tests/standard_objects_cases.json) records positive cases, null/empty distinctions, selected-branch counts, container identity, true-result admission and failure propagation. Every LMX execution status is **NOT_RUN**. Source inventory validation and prepared expected results are separate from native/interpreter acceptance.
