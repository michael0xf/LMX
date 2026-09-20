**Lingvamyxa (hereafter LMX) is a language in which a program is a lexical forest of primitive arrays connected into a dynamic graph.** This organization repeats self-similarly at the level of local actors with physical memory addressing and further at the level of remote intermachine messages with composite addressing.

**Both data and executable bodies are arrays**, represented by the same simple universal structures; every executable body is a complete abstract expression.

**Typing is analytical, at the level of lexical branches.** Admitting any candidate as an argument to any expression requires analytical compatibility checking and mandatory runtime validation by unit tests specified by the receiving expression. Tested candidates and checking expressions are uniquely identified by their physical addresses.

LMX is also a grammar capable of representing both data in a complex, uniquely structured hierarchical and tabular form with intersecting sets and, in principle, any language. See the [complete grammar specification](LMX_grammar.en.md).

**Language levels.**

- **L0** is native code: microprocessor instructions or virtual-machine instructions. For a microprocessor, the translation chain is **L3 → L2 → L1 → C99 → L0**; for a virtual machine, it is **L3 → L0** directly. Arrows denote translation stages.
- **L1** is the level of the L1 language and C99, described in [L1_spec_en.md](L1_spec_en.md) and [L1_spec_ru.md](L1_spec_ru.md).
- **L2** is LMX itself with low-level operations, described in the [L2 specification](L2_spec_en.md).
- **L3** is pure, hermetic LMX. Its semantics are the subject of this main specification.

<!-- semantics-toc -->

- [1. Language scope and execution modes](#scope)
- [2. Values, Structures and Arrays](#values)
- [3. Identity and lexical trees](#identity)
- [4. Names, paths and repeated occurrences](#fields)
- [5. Explicit value descriptions and conversions](#descriptions)
- [6. Analytical checking and candidate validation](#admission)
- [7. Fourteen practical typing cases](#admission-recipes)
- [8. Value construction](#construction)
- [9. const, immutable and independent](#qualification)
- [10. Callable expressions and their interfaces](#callables)
- [11. Dynamic inputs and working state](#dynamic)
- [12. Branches and loops](#branches)
- [13. Exits and finally](#exits)
- [14. Declared failures and diagnostics](#exceptions)
- [15. Restart and suspension](#suspension)
- [16. Arrays, shape and shared backing](#arrays)
- [17. Array operations](#array-operations)
- [18. Numeric operations, purity and contexts](#mathematics)
- [19. Composition and graph copying](#composition)
- [20. Tables, queries, imports and providers](#registries)
- [21. Ownership, reachability and lifetime](#memory)
- [22. Eternal branches and shared methods](#eternal)
- [23. Message, actor and serial turn](#messages)
- [24. Delivery, ownership and mutation order](#delivery)
- [25. Completion, children and retained failure state](#lifecycle)
- [26. Incoming-message admission and execution](#pipeline)
- [27. Mix: active marks and intervals](#mix)
- [28. WorldWideMix: addresses, cells and navigation](#worldwide)
- [29. Prefix coordination and mirrors](#mix-coordination)
- [30. HTTP and service boundaries](#transport)
- [31. Authentication, authority and evidence](#authentication)
- [32. Cryptographic values and providers](#crypto-values)
- [33. Cryptographic operation contracts](#crypto-operations)

<a id="scope"></a>
## 1. Language scope and execution modes

LMX represents data, executable expressions, models, queries and messages. Source notation constructs Structures; a receiving expression assigns their meaning. Records, trees, configurations, schemas, tables and program bodies share the same structural basis. Registries, services, tables and Mix are families of data and receivers, not additional language levels.

L3 retains graph mutation, structural calls, tables, messages and local actors. Low-level address operations, raw memory access, raw machine interfaces and explicit low-level synchronization belong to [L2](L2_spec_en.md). The level distinction does not by itself establish computational purity, user authority or a separate security system.

A file extension selects its outer profile: `.lm1` selects direct L1 lowering, `.lm2` L2, and `.lm3` L3. `.lm4` and `.lm5` do not select current profiles. The ordinary L3 script profile executes the file's root body; a `main` function is not required. A service profile may select an explicit function, `start`, a handler or a message send. The entry point receives control after its environment and runtime graph are prepared.

The model supports interpretation of the constructed L3 graph and translation preserving the same semantics. The interpreter executes L3 only: not source text, L1/L2 or `c.*` operations. The interpreter's implementation does not expand the language of the interpreted program. The target maintained sources are divided into L2 and L3; existing `.lm1` units are gradually rewritten in L2. L1 remains an intermediate translation stage, not the source carrier of the executable graph; the migration's current state is distinguished from this target in the [L2 specification](L2_spec_en.md#scope). The parser, graph interpreter and translator serve different purposes. Grammatical forms, body boundaries, literals, comments and normalization are defined in the [grammar specification](LMX_grammar.en.md).

<a id="l3-receiver"></a>
### L3 receiving expression

The L3 receiving expression defines the contract for consuming a constructed graph as an L3 program. It determines the supported subset and the selected profile's entry point; the mere presence of a syntax tree does not establish program admissibility. An unsupported operation does not become admissible because a machine implementation address exists. A restricted execution profile must explicitly report an unsupported construct rather than silently skip it or execute it as L2. This profile restriction does not replace the [single candidate-admission mechanism](#admission).

Execution follows resolved references and positions in the binary graph, not source names; the diagnostic address-to-name table does not participate in execution, as specified under [names and paths](#fields). A high-level operation may have an explicitly selected machine implementation with an L3 contract, as described at the [numeric/machine-operation boundary](#mathematics); this does not authorize arbitrary `c.*` calls from the interpreted program.

The executable graph representation uses physical references wherever possible. A numeric code is used only where a physical reference cannot be retained or transported; after such a code is resolved, subsequent execution again follows the resulting reference. Textual names do not participate in operation recognition, receiving-expression selection, or dispatch. An internal numeric implementation tag may be used as a local interpreter optimization, but it does not by itself establish the meaning of an L3 node.

The simplest script-profile program is:

```text
print: "Hello World"
```

<a id="values"></a>
## 2. Values, Structures and Arrays

A Structure is an ordered collection of direct fields. Fields hold references to values: primitive cells, other Structures, Arrays and method records. Lexical nesting forms a forest; additional references connect it into a graph containing shared objects and cycles. A primitive cell does not acquire a Structure wrapper merely because a field references it.

An Array contains elements of one type. Its length counts Array elements, while a Structure's field count counts its direct fields. An Array of references to Arrays differs from a rectangular multidimensional Array. Representation details and address-range classification of cells are defined in [L2](L2_spec_en.md#type-by-range).

An empty Structure is a present value with zero fields. It differs from an absent argument, numeric zero and `void`, which denotes no primitive-cell content. An explicit empty vertical body supplies the same argument as `()`; see [empty bodies](LMX_grammar.en.md#empty-colon).

`None` is contextual: its representation is defined by the type expected by the receiving expression. There is no encoding shared by all types; a type without a corresponding definition of `None` does not accept it. The numeral `0` remains zero and means false in logical operations; it is not a universal absence marker. The earlier `Boolean` profile uses the range −1…1: `None = −1`, false is 0 and true is 1. This is a particular profile definition, not the universal encoding of missing values.

Text, images, decimal notation and machine words are substrate storage before recognition by a receiving expression. After parsing or decoding, they are values of the same graph. Format and numeric-library names do not introduce additional fundamental value kinds.

<a id="identity"></a>
## 3. Identity and lexical trees

Live Structures and Array records retain their physical addresses. Storage grows by adding new regions; existing objects do not move. Equal contents do not imply object identity. Explicit copying creates new identities and preserves relationships under the [copying rules](#composition).

A lexical parent determines a Structure's position in its tree; a root has no parent. Storage ownership and lexical ancestry are independent. Attaching another Message's storage preserves existing lexical links, does not itself add a reference from the recipient's root and does not make the adopted root a lexical child of the recipient.

The [independent qualifier](#qualification) cuts the external lexical parent at construction; obtaining inputs from the caller follows [dynamic visibility](#dynamic). Neither mechanism changes storage ownership or object identity.

<a id="references"></a>
<a id="fields"></a>
## 4. Names, paths and repeated occurrences

Names resolve source-level accesses; execution follows the resulting references and positions. A diagnostic mapping from address to short source name is not a variable-binding table, a type or an execution identifier. Construction, copying and calls do not require source-name registration. Anonymous and positional values need no synthetic names.

A structural path `object\field\nested` selects graph fields in sequence. Each step's presence and validity are determined by the selected object. A computed path is not replaced by an invented statically known name. Direct access to an invoked body's own graph uses reserved `node`; `node` denotes the callable Structure itself, while its lexical parent is a different value.

`node` cannot be declared, shadowed, rebound or dynamically supplied as a same-named value, including by quoted identifier spelling. The caller selects the structural occurrence but cannot substitute a value from its own context for that occurrence's `node`. `node\field` selects the occurrence's direct field without an additional hop to its parent; further traversal must be explicit.

Repeated source names are retained. `name` is equivalent to `[0]name`, selecting the first occurrence; `[1]name` selects the second. A name's occurrence number differs from the physical field index among all fields. A later `merge` part does not automatically override an earlier one. Reordering distinct names does not change a named path; reordering same-name occurrences may change the selected value.

A Structure's field count and positions are fixed at construction. Graph fields follow strictly lexical order; native-code emission order does not authorize rearranging the graph's fields. Updating an existing field replaces its stored reference; it does not append an occurrence. A different set of fields requires a new Structure. Array operations follow their own contracts and do not change this Structure rule.

<a id="descriptions"></a>
## 5. Explicit value descriptions and conversions

A value description is an ordinary explicitly accessible Structure. A receiving expression obtains it through an argument or reference. It is not secretly attached to every primitive and is unnecessary for determining a physical type from an address. Names such as `class` and `class.range` denote a particular profile's data, not mandatory global language entities.

A description separates its semantic contract from architecture binding. The contract defines meaning: count, integer, rational, profile-precision number, complex value, atom, address, opaque resource or absence of content. The binding defines width, signedness, range and target spelling. Equal representation does not imply equal contracts: `Boolean` and `int8` may share storage while admitting different values.

Ordinary description fields include `cell`, `semantic`, flags such as `numeric`/`integer`/`floating`/`reference`/`opaque`, `width`, `signed`, `range`, `spelling` and `convert` keys. The profile chooses field names. A range declaration is contract data; satisfaction is established through the [single admission mechanism](#admission), not by the field's presence alone.

The numeric contract chain is flag → nonnegative integer → integer → rational → profile-precision number → complex number. Nonnegative integers include zero. Machine `double` is not the set of all real numbers. Atoms, addresses and opaque resources are separate contracts, not rungs of this numeric chain. `unit` is an empty Structure; `void` denotes no cell content.

Descriptions are composed with ordinary `merge` under the common [occurrence-order rule](#fields). Fields such as `width`, `range` or `spelling` do not automatically create arithmetic methods. Such operations are callable expressions. For example, `u32` combines a nonnegative integer contract, 32-bit representation and range 0…4294967295; `FILE` describes opaque resource identity. A `FILE` word alone does not establish that reading or closing is valid: such requirements are expressed through paths of a `File` Structure.

A converter is an explicitly selected receiving expression. Conversion keys come from explicit descriptions and their composition; there is no hidden search across all type pairs. Analytical checking does not execute a converter. When an operation requires conversion, the selected call is executed; a missing key does not create a nonexistent converter. A later same-name key does not displace the first without explicit occurrence selection.

Numeric conversion preserves the destination-range contract: `u16(255) → u8` is admitted when the converter exists, while `u16(256) → u8` produces a range error, not zero. Rounding `1.5 → i32` and in-range precision loss require explicit numeric-profile rules. Proven range inclusion may eliminate a redundant machine operation while preserving the semantic requirement. Format, range and converter-behavior failures are not replaced by a positive `implements` result.

<a id="admission"></a>
## 6. Analytical checking and candidate validation

The single candidate-admission mechanism consists of analytical tree-based `implements` for the receiving expression and execution of that expression's unit tests by the graph interpreter. Arena address classification supports value representation; it is not alternative validation. A matching signature, an attached explicit description or a positive analytical answer does not replace execution of the required tests.

<a id="analytical-tree"></a>
### Analytical stage

`implements(A B Consumer)` checks candidate A against the paths of reference value B used by Consumer. Consumer is the known receiving-expression tree. Used named paths, including nested paths, and their leaf-consumption requirements must be satisfied. Unused fields of B do not become requirements. Without a receiving expression, the checking context is undefined; a two-argument form does not specify this model.

Use is determined by visible accesses in the tree, including alternative branches, not the trace of one execution. Checking is not replaced by matching physical field positions. Reordering differently named fields while preserving paths does not change the result. Repeated names follow [occurrence selection](#fields).

Direction matters: suitability of A in place of B for one Consumer implies neither reverse suitability nor suitability for another Consumer. An empty used-path set means this part of analysis has no structural requirements; unit tests remain mandatory. A field named `validate` does not create a special implicit hook.

Thin consumption stops at a leaf: passing or storing a word does not prove units, ranges or foreign-resource validity. Thick consumption follows explicit descriptive or behavioral paths. Analysis does not expand all callees, execute computed names or perform whole-heap alias and dataflow analysis. Unknown coverage remains unknown; it is not reported as successful verification of unknown properties.

Diagnostics should distinguish genuinely thin consumption from inability to establish used paths. They may show which first same-name branch composition selects, which descriptive fields are unused and which requirements remain unresolved. Diagnostics do not introduce a global strict mode or change field-selection rules.

When a receiving expression invokes a path, that call's contract includes declared and dynamic inputs, results and thrown values. Transporting a callable without invoking it does not require knowledge of every future use. An executed call must satisfy the selected expression's requirements; equal signatures do not prove equal behavior.

<a id="graph-tests"></a>
### Test execution

The interpreter receives an already constructed graph of executable Structures and links. Parsing source text precedes this stage and does not serve as interpretation. The receiving expression defines unit tests for the interpreter to execute against the candidate. These tests provide substantive runtime validation: a field named `range` or `unit` does not by its presence prove that the stated constraint holds.

The candidate and checking expression have physical identities. Successful checking does not freeze their state. Mutation, external effects and changes to consulted descriptions must be accounted for by the conditions under which a result applies. Result reuse, isolation of test execution and representation of the test set require explicit contracts; matching addresses alone do not resolve them.

Ordinary values may store test results and evidence when the program explicitly does so. Such data do not create a second admission predicate or automatically certify new or changed conditions. The former separate available-graph `RuntimeImplements` is not part of the new validation model.

A statically established violation is reported during analysis. In the earlier model, runtime type-check rejection used `throw: Type` carrying the candidate, required role and Consumer. The exact failure interface of the new unit-test set remains to be settled; handling of declared `throw` is described in [exceptions](#exceptions). Neither validation nor memory reclamation rolls back already published messages or external effects.

<a id="admission-recipes"></a>
## 7. Fourteen practical typing cases

These cases explain the [single admission mechanism](#admission). Its analytical stage checks used paths; substantive constraints belong to the receiving expression's unit tests. The examples specify required behavior, not verified completeness of the current translator.

<a id="admission-case-1"></a>
### 1. One receiving expression for multiple data shapes

The expression accesses only the paths it needs. A candidate provides those paths, admitted leaves and the required contracts of expressions actually invoked. No separate generic type-parameter declaration is required. This used-tree check provides structural generality without promising every property of parametric polymorphism.

<a id="admission-case-2"></a>
### 2. Knowing what a particular site checks

Consumer determines analytical coverage. Available source accesses and unknown coverage are distinguished explicitly. Analysis is followed by its unit tests through the graph interpreter. Success does not freeze operands or certify every future use. Inputs required by an actual invocation must be available at that invocation.

<a id="admission-case-3"></a>
### 3. Distinguishing meanings with the same representation

Encode the distinction in a path the receiving expression actually uses. With `Distance: Meter: 1`, access through `d\Meter` requires that path; a Structure exposing only `Foot` does not provide it. An outer name `Meter`, a field `unit: "meter"` or `const` alone is insufficient. When a field value's meaning matters, a receiving-expression test checks it.

<a id="admission-case-4"></a>
### 4. Constraining a scalar leaf

State the constraint explicitly and include it in tests. Presence of `x\width` does not establish `width = 32`; a scalar leaf may remain thinly consumed even when a description exists. Immutable build-time data can undergo preliminary analysis, but such a proof is not an alternative runtime-validation mechanism.

<a id="admission-case-5"></a>
### 5. Making a change visible to other reference holders

Writing `p\x: value` or `a[i]: value` changes the selected object. Bare `x: value` changes the current call's working value: an own field becomes dirty and is published at a boundary, while an ordinary formal, result or dynamic copy remains local. The input-to-own-field binding exception and its activation point are defined under [working state](#dynamic). Neither write implicitly appends a same-name occurrence.

<a id="admission-case-6"></a>
### 6. Independence from another holder's mutation

Explicit copying creates independent mutable values under its contract; genuine immutability prohibits mutation of the protected value. Ordinary Structure or Array passing copies a reference. Another alias within the Message can therefore change the shared mutable object. An immutable foreign-resource identifier does not make the foreign resource immutable.

<a id="admission-case-7"></a>
### 7. Establishing that a call can proceed

The used paths and callable contract must hold, and all dynamic inputs must be supplied. Suppose A and B expose the same `m`, whose body uses bare `x`, while Consumer only invokes `m`. Checking path `m` does not create `x`: the current calling context or permitted lexical fallback must provide it. Analysis is not replaced by expansion of every callee body.

<a id="admission-case-8"></a>
### 8. Checking a transported callable

Transporting a callable does not execute it or require knowledge of every future contract. The current receiving expression's requirements are checked. At actual invocation, the selected expression must receive its required inputs and satisfy the applicable admission requirements. Equal signatures do not imply equal algorithms.

<a id="admission-case-9"></a>
### 9. Changing a method body without breaking calls

The body's free dynamic names are part of its interface. Adding one changes `DynRequired` and the signature; known callers require rechecking. An immutable method record does not prohibit explicit replacement of a reference with a compatible callable. Behavioral change under the same signature is a matter for tests and program correctness.

<a id="admission-case-10"></a>
### 10. Selecting the intended part of a composition

Select the occurrence explicitly or construct the intended fields. `merge` preserves forward order and does not implement last-wins inheritance. If the result contains A's `read` followed by B's, `result\read` and `result\[0]read` select A; `result\[1]read` selects B. Analytical diagnostics may expose unintended selection after an import or composition changes.

<a id="admission-case-11"></a>
### 11. Changing an existing Structure

Fields and their count are fixed. References in existing fields may be replaced subject to their use requirements. A different field count requires a new Structure, such as a `merge` result. No conflict policy is introduced for nonexistent operations that remove or move an active field.

<a id="admission-case-12"></a>
### 12. Reliable numeric conversion

Use an available explicitly selected converter with a destination-range contract: `u16(255) → u8` is admitted, while `u16(256) → u8` is a range error. In-range rounding and precision loss are specified separately. Successful analytical checking does not permit silent modular wrapping.

<a id="admission-case-13"></a>
### 13. What a broad converter table provides

Additional explicit keys widen the available leaf conversions. They do not alter required tree paths or callable contracts. A profile need not provide every pair; a missing converter remains missing. Analytical checking does not execute converters or search for a hidden conversion chain.

<a id="admission-case-14"></a>
### 14. Foreign-resource validity

A foreign handle requires an explicit high-level wrapper and contracts for ownership, use and release. A thin `FILE`-like leaf does not establish validity, authority or single close. The receiving expression's unit tests check declared properties within their contract; immutable handle bits do not keep a resource alive. L3 has no ordinary machine-level `own:`/`borrow:`/`move:`, and `copy:` does not invent a foreign resource's duplication policy.

<a id="construction"></a>
## 8. Value construction

A structural expression constructs a value when execution reaches it. Declaring a name, importing a unit or providing a description does not eagerly create every instance. Named and anonymous Structures share one mechanism: determine the lexical parent, create fields with stable identity, evaluate initializers in source order, establish links and publish the successfully initialized result. An `independent` root has no external lexical parent.

In declarations `u32: id`, `Text: crop`, `f64: harvest 0.0`, the constructor operation consumes the following identifier as a proposed name rather than evaluating its previous value. `PlantBed: bed` requires an available `PlantBed` construction operation: a same-named description does not become a constructor by itself. Redeclaration of an existing field is subject to the remaining receiving expressions' requirements; it creates neither a new type nor a hidden name table.

The colon builds a nested application form. In `const: char: []: s "hello" "world!"`, qualification, element selection and Array construction have their respective contracts. `char` selects a primitive element; `String` denotes a higher-level immutable text value, not another spelling of machine `char *`. `String: ()` constructs a Structure of references, whereas `String: []` constructs an Array of references under the respective constructors.

A field can retain a reference to an existing object. This neither copies it nor reparents its lexical parent. An empty Structure is a present value, not an absent argument. In the following construction both `count` fields remain: `result\count` selects 3 and `result\[1]count` selects 4.

```text
(): result
    int: count 3
    String: text "hello"
    int: count 4
end: result
```

Naming does not add a descriptor, class or special layout to the object. Construction differs from [composition](#composition): it creates the expressed graph, whereas `merge` copies its operands' graph. The evaluation/reuse policy of a top-level named construction still requires definition; eager materialization of every value during translation does not follow from it.

<a id="qualification"></a>
## 9. const, immutable and independent

`const` protects a binding: it cannot be assigned, rebound or replaced. The value behind a protected reference may remain mutable. `immutable` protects the value itself for its entire life through every alias; a variable holding its reference may remain rebindable. `const: immutable` combines both guarantees. They are independent qualifications, not degrees of one scale.

Immutability applies to a primitive, a Structure and its selected tree, or an Array with its descriptor and elements. It covers positional fields, every repeated occurrence and explicitly included descriptions, not just Consumer's paths or the first occurrence. Passing, returning and storing an immutable value preserve its identity; qualification requires no copy, including for a primitive. It does not freeze a foreign resource denoted by an immutable identifier.

Construction-time `immutable` qualifies the new value before publication. `RuntimeImmutable` qualifies an existing tree while retaining its identity. The second operation's name does not denote a second argument-admission mechanism: changing qualification is its operational contract. Its arguments undergo [unified admission](#admission), like those of every receiving expression.

The whole selected tree is examined before qualification changes. A contained Structure is a tree branch only when its `node` points to the parent being examined. An outside reference is permitted only to an already immutable object; it is terminal, and its target is neither traversed nor requalified. The pre-change state is checked: processing an earlier field cannot justify an invalid outside reference in a later field. Malformed containment or a mutable outside target follows a declared `throw`, not `assert`.

Primitives and methods are leaves, not lexical-tree branches. An Array reference likewise establishes no `node` branch: a tree operation does not implicitly freeze an outside Array's mutable backing. An immutable Array is constructed under its own contract. A cell's membership in a service pool does not permit traversal or qualification of the entire pool.

Qualification is applied only after successful complete preflight. Failure leaves no partially frozen tree or published successful result; silently skipping a branch, copying it or retargeting links is prohibited. Requalifying an already suitable tree changes nothing. This rule does not roll back earlier initializers, argument evaluation or pre-call publication of working fields; it establishes no graph transaction.

Protection applies to writes through every path and to publication of working fields. A known-invalid write is rejected before execution; a dynamically selected write is checked during execution. Calling a method is allowed but does not remove protection. Changing a local argument copy or rebinding a local reference does not modify the protected value. Constructing a new value, including through `merge`, does not thaw the source.

Construction-time `independent` establishes the absence of an external lexical parent. Internal tree links and own fields remain. The qualification neither clears existing objects' `node` links nor prohibits explicitly supplied references, current-caller dynamic arguments, Messages or selection of a callable by a compatible signature. It does not require purity or an interface closed over explicit arguments alone.

For example, a method inside independent Structure S can use S's field through its internal lexical link. Required `x` can come from the current caller. If `x` exists only in S's former textual surroundings, implicit external access is unavailable. An explicitly passed large Array neither shrinks nor gets copied because of `independent`. The special lifetime of the three qualifications together is described under [eternal branches](#eternal).

<a id="execution"></a>
<a id="callables"></a>
## 10. Callable expressions and their interfaces

An executable body is a structural expression. `fn` defines an expression with one logical result; `sub` performs execution without a returned value; `fm` has one result Structure whose fields provide a multiple-return surface. The signature defines explicit arguments, required dynamic and lexical inputs, each value's pass mode, the result and declared `throws` exits. Merely having a Structure, label or name does not execute its body.

A callable occurrence has its own structural identity and lexical-parent link. Multiple occurrences can reference one immutable method. Graph copying neither creates another method implementation nor changes its signature; state belongs to particular structural occurrences and activations. A nested definition does not capture a caller frame in a hidden environment.

Entering a method does not copy its callable occurrence, body or any other part of the graph. Native and interpreted execution use the same locality model: each activation receives an ordinary frame for formal, dynamic and local values, the result, and working copies of used own fields. Those own values are loaded and marked `dirty` under the same rules regardless of execution mode. Logically, the frame has the lifetime of an ordinary stack call; an implementation may place its auxiliary storage in reusable memory provided that this neither creates a method copy nor hidden graph state and does not make entry substantially more expensive than a native call. Such storage is expressed through a standard L2 mechanism suitable for later code migration, not an interpreter-private facility. A recursive call creates another frame over the same method; graph memory is copied only by an explicitly expressed operation, not by invocation itself.

Callable selection starts from an explicit reference, structural path or textual path with an explicitly supplied root. Selecting an implementation and providing its arguments are distinct actions. The selected candidate undergoes [admission](#admission); the call must then receive every signature input. A suitable method field does not by itself supply its dynamic inputs. Transporting a method as data is not invoking it.

Positional actual arguments precede named ones. After the first named argument, subsequent arguments must also be named. An unknown name, duplicate assignment to one argument, missing required argument or ordering violation is an error. A named argument's body is supplied as a structural value when that is the receiving expression's specified mode; it does not become an arbitrary sequence of immediate calls.

The syntactic boundaries of the function name, argument list, result description and body are defined in the [grammar](LMX_grammar.en.md). An empty argument list is a present empty value. Descriptions and signatures do not create implicit calls. Bodyless declarations and partial-argument binding forms do not yet establish general automatic currying or closure construction.

Named `fm` results are fields of an already existing result Structure. `return` completes their updates and forwards that Structure; the control transfer itself neither allocates nor copies it. Multiple values in the `return` tail populate signature-defined fields of the same Structure. Exact surface unpacking forms require a separate profile rule.

Function-name assignment shorthand, such as `square: x * x` inside `square`, is admitted only if the receiving `fn` defines a same-named local result slot. It does not replace the persistent callable reference. Without that contract the form is rejected. Structural closing with `end: f` adds no implicit value return; explicit `return: value` is the core form.

```text
fn: square (int(x)) (int)
return: x * x

fm: coordinates () (int(x) int(y))
return: 10 20
```

A returned reference preserves its exact target identity. Constructing a result, if necessary, belongs to evaluation of the returned expression, not the transfer operation. Returning from a nested function ends its activation, not automatically the entire actor. Publication and cleanup ordering is defined under [exits](#exits).

<a id="publication"></a>
<a id="dynamic"></a>
## 11. Dynamic inputs and working state

A persistent graph field, the current activation's working value of an own field, an explicit formal argument and a dynamic input must be distinguished. They are separate storage locations with separate mutation rules. Ordinary passing copies a mutable primitive's value and a Structure or Array's reference; the special identity of an immutable value is retained under [qualification](#qualification).

For a free name, the called expression receives the current value from the caller's available context; if unavailable, permitted lexical lookup follows `node`. Own declarations and formal parameters have their respective resolved locations rather than being searched in a global registry. Required through-names are part of the signature: adding a free name changes the interface. A missing required input makes the call inadmissible; silently creating zero or a new field is prohibited.

A free name's sources have this priority: the caller's nearest current local binding, then its already inherited dynamic input, then the callee's lexical lookup. A local binding includes a used own field, formal argument, result or another receiver-defined local value. Statically known call requirements propagate to a fixed point, including through mutual recursion. A name needed only by the next call must still be retained and forwarded; forwarding alone creates no graph field.

Lexical lookup uses real Structure links, stops at a zero parent and selects the direct first same-named occurrence at the relevant step. `independent` cuts only the external lexical fallback. Explicit access through `node\x`, `reference\x` or `array[index]` addresses the graph rather than being replaced by the current call's dynamic `x`.

An own field's working value is loaded for the activation. Assigning that name changes the working value and marks it dirty. Assigning a formal or dynamic input changes only its local copy, without automatic copy-back to the caller. An explicit reference write changes the selected object directly and is observable through other references to it.

Same-name binding is the exception: an executed own-field declaration or assignment-as-declaration can bind an input to the current body's field. From that line the same working value becomes that field's own cache; no previous graph value is loaded over the input. Earlier input changes are not published. A preallocated slot neither activates the binding before its statement executes nor changes the field count. Publication targets the body's own field, never the caller's argument source.

Every body that a receiving expression executes statement by statement is a graph Structure hosting its directly declared fields. Bodies of `if`, `else`, loops and other receivers form a containment hierarchy, not a flat method-field list. An untaken branch performs no assignments. An ordinary nested block creates neither another method activation nor a dynamic-input boundary. Conditions, call arguments and `return` arguments are not executable bodies merely by being arguments: their receiving expression determines the role, not a Structure in the last syntactic position.

```text
fn: remember (int: x) int
    x: 7
    return: x
end: remember
```

Here input `x` becomes the body's own field when `x: 7` executes. This changes `remember` state, not the caller's variable. Only own fields actually used by a bare name or to forward a dynamic input are cached; an explicit path alone creates no own cache. Lack of caching does not remove an existing field from the graph.

Before control passes to another callable expression, only own working fields written since their latest successful publication are published. Their dirty marks are then cleared. A clean cached field must not be written back: a nested call may already have changed it through an explicit reference. After return, the caller activation does not reload its working values from the graph.

Dirty state follows an executed write, not value comparison or the presence of a possible assignment in source. Publication follows forward field order; a successful write clears the corresponding dirty mark. Failure to resolve an already bound slot or store into it uses diagnostic `assert`; the intended outbound call is not executed afterward. There is no general transaction rolling back earlier writes. Publication is also required before a foreign boundary capable of calling back into LMX or exposing graph state.

Consequently, after a nested modification of `node\x`, the caller's bare working `x` can retain its earlier value while an explicit path observes the new value. A later assignment to bare own `x` deliberately creates a new write and publishes it at the next boundary. No automatic reload is part of the semantics, not permission to lose dirty changes.

Recursive calls have separate working values and dirty marks even when using the same callable structural occurrence. One activation's publication does not turn another's working values into references to its stack. A body supplied to a receiving expression as a Structure and an executable call's arguments likewise do not become one hidden environment.

Publication is required at call, return, `throw`, diagnostic termination and `yield` boundaries. An exit with `finally` has the two publications specified under [exits](#exits). `retry` and local loop transfers do not by themselves create a new activation or reload fields. Signatures and the graph retain this model's requirements whether the graph is interpreted or translated.

<a id="branches"></a>
## 12. Branches and loops

Control receivers determine how their structural bodies are consumed. Membership in a body does not require immediate execution of all its fields. Control labels denote visible transfer targets; mentioning a label neither invokes its body nor constitutes an implicit `goto`.

`if` evaluates its condition once and executes its body when true. An immediately following sibling `else` executes only when false. Another statement between them breaks the pair. A profile-specific `branch` with named branches may exist separately and does not replace this contract.

`match` selects a suitable branch using expressed patterns. Branches can be pattern/body pairs or explicit Structures according to the profile; `default` is a profile-defined pattern, not a universal effect of an arbitrary name. Pattern union and exhaustive-coverage requirements belong to the contract. There is no automatic fallthrough unless explicitly defined.

`while` checks its condition before each iteration and can execute its body zero times. Closing `until` establishes a postcondition: the body executes at least once and repeats while the condition is false. Core `for` contains initialization, condition, step and body; initialization runs once, followed by condition, body and step. Unified semantics for all range shorthands are not yet established.

`each` consumes a container's elements or an explicitly selected iterator. The iterator produces an element through `yield` and indicates completion by declared `throw: Stop`; `None` can be an ordinary element and does not replace end-of-stream. Other exceptions propagate under their declarations. A source reference `words` differs from `words()`: the latter explicitly invokes the expression with no arguments.

| Transfer | while | until | for | each |
| --- | --- | --- | --- | --- |
| `continue` | Check condition | Check postcondition | Perform step | Obtain next element |
| `redo` | Repeat body without check | Repeat body without check | Repeat body without step | Repeat with same element, without `next` |
| `break` | Exit loop | Exit loop | Exit loop | Exit loop |

An unlabelled transfer targets the nearest suitable active loop. A labelled transfer requires a visible label; `continue` to a non-loop target is erroneous. `redo` is valid only within a loop and may fail to make progress. Every abandoned scope performs its registered cleanups. The complete set of scope kinds that can carry a label requires a separate grammar definition.

<a id="exits"></a>
## 13. Exits and finally

`finally` registers cleanup in the current scope without executing it at registration. Registered cleanups run in reverse order when that scope is exited. This applies to normal completion, `return`, `throw`, transfers out of a loop scope, `redo`, `retry`, diagnostic termination and other profile exits. It is neither a `try` construct nor an exception-only handler.

An exit that destroys an activation follows this order: evaluate and retain the result or exit payload once; publish dirty own working fields; perform applicable cleanups; publish own fields dirtied by cleanup; transfer the result or control and finish the activation. If no new changes occur, the second publication is empty, but it cannot be ruled out in advance.

Dynamic inputs are not copied back, clean cached fields are not published, and the caller activation is not reloaded. Every activation crossed by propagation performs its own required actions. Return preserves the result's reference identity and does not itself trigger actor end-of-turn collection.

An exit within an already running cleanup does not re-enter that cleanup. Remaining applicable outer cleanups retain their obligations. Calls within cleanup have ordinary publication boundaries. Removing an activation through stopping or cancellation does not permit these rules to be bypassed.

<a id="exceptions"></a>
## 14. Declared failures and diagnostics

`throws` lists names of an expression's possible recoverable exits, not exception types. The caller must provide a `catch` for each name or include it in its own `throws`. A call without either treatment is rejected. Failure detection uses ordinary `if`; module `guard` is not a failure-handling operator.

`throw: Name(arguments)` evaluates an explicit payload and leaves the current activation under the [exit rules](#exits), without returning its declared result. The selected `catch: Name (...)` parameters receive the payload. A handler's repeat call begins a new activation from the start and does not resume the abandoned frame.

`catch` is a landing pad in the caller's block, not an ordinary nested `sub`. Its body is skipped on the initial straight-line pass. When the corresponding failure arrives, its body runs and execution continues with the statements after that `catch`. Consequently, a handler before a call re-enters the following region; a handler after the call continues past itself. The region ends at the next `catch` in the same block or the block's end.

Two same-named handlers in one block are prohibited; separate nested blocks can each have one. Delivery selects the handler by the calling block, not a same-named handler in a sibling block. Throwing the same name inside a handler does not re-enter it: this is a failure in the enclosing calling context. An unhandled name propagates only through matching `throws` declarations.

The historical compatibility-failure contract uses `Type` with payload `(varA, varB, Consumer)`. In the new model it belongs to [unified admission](#admission); no separate `RuntimeImplements` path is introduced. The detailed unit-test result/failure interface requires agreement rather than arbitrary identification with an old validator.

`assert` checks a diagnostic invariant. A false condition produces `AssertionViolation`, not a recoverable `throw`; ordinary `catch` cannot handle it and it is not part of `throws`. In the actor profile, publication and cleanup precede delivery to the executing Message's diagnostic root; that Message stops executing and receives no further turns. This need not terminate the OS worker; stopping execution and destroying the object are distinct.

Expected input errors use an explicit condition and declared failure rather than a diagnostic abort. `log` and `error` record observations through the selected profile. `error` alone does not imply `throw`, `assert`, return or termination. A non-literal argument resolves as an ordinary value; an unknown name does not automatically become a log string.

<a id="suspension"></a>
## 15. Restart and suspension

`retryable` defines a restartable region. Unlabelled `retry` repeats the nearest active such region; `retry: label` repeats the named one. Abandoned-attempt cleanups run before restarting. The transfer does not roll back external effects, graph mutations, already published fields or Messages. Transactional rollback requires an explicitly represented data protocol.

`retry` itself is a local transfer in the current activation, not a new call or restoration of a hidden environment. Current working values continue to exist, with no additional publication merely because of the transfer. If repeated execution reaches a call or exit, that boundary's ordinary rules apply. A caught failure's payload remains the handler's explicit arguments.

`yield` transfers a produced value and suspends the activation. Dirty own fields are published before suspension. Explicit arguments, dynamic inputs, working values and their subsequent state are retained for resumption; they do not become body fields or a public hidden environment. Resumption does not reload them from the method Structure.

Producer inputs are fixed when its activation begins. A later `next` caller does not replace them with its own dynamic context. If `next` is a separate wrapper expression, its inputs belong to its activation unless an explicit operation changes the producer's saved state. The continuation and iterator-result representation remains unsettled; every representation must preserve these semantics.

<a id="arrays"></a>
## 16. Arrays, shape and shared backing

An ordinary Array is a typed value with stable reference identity. Constructor `[]` creates it when execution reaches the construction site. A Structure field holding its reference is not the Array itself. Passing a reference does not copy elements; an element mutation is visible through other references, whereas rebinding a local reference is not.

An owning Array has one contiguous rectangular block of elements. Nested dimensions do not mean separately allocated rows. For shape `[d0, …, dN−1]`, element count is the product of dimensions, with the last index varying fastest. An Array of references to other Arrays is a different value, not a replacement for a rectangular multidimensional Array. Primitive elements acquire no lexical parents.

`shape(array)` returns dimensions as a rank-one integer Array or shape Structure; `rank` returns their count; `length` for positive rank returns the first dimension; `size` returns total element count. The containing Structure's field count, Array length and service descriptor-pool size are distinct.

A full rank-N index contains N integer coordinates. L3 access checks the Array descriptor and index bounds; an out-of-bounds access produces a `Bounds` failure, not `None`. A partial index may produce a view, such as first row `matrix[0]`; full `matrix[0, 2]` selects an element. Coordinate spelling belongs to the [grammar](LMX_grammar.en.md), not C machine indexing. These checks belong only to L3: [L2 access](L2_spec_en.md#lowlevel-address), including obtaining a graph-backed element's address, works without them. Operation checks do not constitute a separate candidate-admission mechanism in place of [analysis and unit tests](#admission).

A view can share backing within one Message; a copy has separate backing. `slice`, compatible `reshape`, `transpose`, `permute`, `broadcast` and partial indexing may create views; `copy`/`clone`, materialization and ordinary elementwise arithmetic results create copies unless an existing output buffer is selected. Concrete view representation, backing retention and mutable sharing rules remain unsettled. Returning a reference must not hide copying to repair lifetime.

`reshape` preserves values and total element count; changing the count requires an explicit fill/truncate/copy contract. Compatible storage permits a view; otherwise explicitly defined materialization is necessary. `transpose` exchanges the last two axes for rank at least two or follows the selected matrix profile. `permute(array, axes)` specifies an axis permutation. An operation's logical stride data need not add fields to every universal descriptor.

<a id="array-operations"></a>
## 17. Array operations

Array arithmetic and comparisons are elementwise by default. Element operations follow their numeric domain and explicitly selected context. `*` means elementwise multiplication, not matrix multiplication. `matmul`, `dot`, `contract` and `outer` are separate explicit operations; a profile-specific matrix symbol must not make ordinary `*` ambiguous.

Broadcasting aligns dimensions from the right. A pair is admitted if equal, if one equals 1, or if one side is absent and treated as 1; the former rule chooses the maximum for the result. Examples: `[3]` and a scalar give `[3]`; `[2,3]` with `[3]` is treated as `[2,3]` with `[1,3]`; `[2,3]` with `[2,1]` gives `[2,3]`. A repeatedly read scalar is not expanded into another Array. Internal zero stride can represent repeated reads of one element. Zero extents require clarification: literal maximum does not define safe reads from an empty input.

`reduce` collapses elements with an associative or explicitly ordered operation. With no axis it returns a primitive by default; a profile may explicitly request a rank-zero Array. With an axis, only that axis is collapsed. The contract defines an identity where needed, element operation, result type and ordering. Reproducible real/decimal computations must not depend on an incidental backend choice of order.

`scan` is a prefix reduction: inclusive sum of `[1,2,3,4]` gives `[1,3,6,10]`. Inclusive or exclusive behavior is explicitly selected. `map` applies an expression to elements; a pure variant permits vectorization and parallel evaluation preserving the result. Effects need explicit ordering; the default profile expects pure mapping.

`filter` selects elements by a Boolean predicate and normally materializes a new Array: selected positions need not form a regular view. `concat` joins along the selected axis; other dimensions must match. Its result is normally a new Array with rectangular backing. Copies, materialization and all results retain Message ownership boundaries.

The original minimal numeric profile covers ranks 1/2, contiguous storage, checked indexing, shape, copying, elementwise `+ - * /`, scalar broadcasting, equal-shape operations and whole-array reduction. This is a minimal implementation target, not withdrawal of other contracts. Actual frontend coverage is checked in [L2](L2_spec_en.md#lowlevel-array).

<a id="mathematics"></a>
## 18. Numeric operations, purity and contexts

Numeric names and operators resolve to available constructors, explicit descriptions and callable operations. Families include machine integers/floats, `bigint`, `real`, `decimal`; these are not a mandatory closed language type list. GMP, MPFR and decNumber are possible implementations, not L3 source ontology. Conversions specify range, precision and rounding under the [description contract](#descriptions).

The default expression profile is pure: it admits only operations with declared pure contracts. `sqrt`, `sin`, `cos`, `pow`, `abs`, `gcd`, rounding and arithmetic may have such wrappers. Effectful operations remain valid high-level receivers but do not become pure by being written in an expression. L3 does not prohibit effects generally or derive authority solely from a level number.

A low-level function with raw pointers has no direct L3 call. A high-level wrapper defines ownership, borrow duration, null policy, bounds, element type, mutation, failures and result. Without it only the machine side of [L2](L2_spec_en.md#lowlevel-abi) is available. Numeric-backend initialization and release normally belong to the provider; user numeric code should not manually reproduce its internal storage management.

A `real` context may define precision, rounding, status, traps and exactness requirements; `decimal` additionally includes exponent limits and quantization. Context is explicitly reachable data or fixed profile configuration, not hidden global state. Exact context receiver names remain profile-specific. A deterministic profile must exclude dependence on unspecified platform settings.

Arrays use the same scalar operations and contexts. Vectorization, reduction and tensor operations do not create a different meaning of addition. The minimal mathematics profile includes basic arithmetic, Boolean operations, comparisons, construction/arithmetic for the three extended numeric families, explicit conversions, selected pure functions and numeric-Array operations. It does not imply exposure of the entire C library.

<a id="composition"></a>
## 19. Composition and graph copying

`merge` is an executable operation over live structural operands. It is neither a preprocessor include, C-type composition nor mutation of source values. Operands are evaluated once left-to-right; a fresh root is then built with direct fields in operand and appended-body order. A previous `merge` result can itself be an operand.

The complete used graph is copied with required references and lexical chains to a zero parent. One source-to-copy map spans all operands: shared targets remain shared, cycles are preserved, and references and `node` links are explicitly rewritten. Operand roots and necessary lexical ancestors do not become extra visible result fields. The new root's lexical parent follows the `merge` expression's location.

Shared methods and admitted [eternal branches](#eternal) are terminals under their respective contracts: they retain their addresses without copying code or branch contents. Other used mutable state receives distinct storage. The algorithm is not merely a direct-field pointer copy and does not leave references into another mutable arena.

Repeated fields retain forward order: the first `read` remains `read`/`[0]read`, the next is `[1]read`. A later operand does not automatically override the first. Different selection requires choosing an occurrence explicitly or constructing the intended result. Successful composition publishes a fully initialized result, requires no short-name registration and leaves sources unchanged.

Failure follows declared `throws merge(args)`, not an invented partial-result protocol. This does not promise rollback of operand-evaluation effects. Temporary-storage release follows the owning Message's rules. The exact low-level mechanism is in [L2](L2_spec_en.md#copy-merge).

A type description, schema, import data or Table is ordinary data: applying `merge` does not select a special descriptor-composition algorithm. `table` materializes an explicitly selected table representation; `join` creates a new table graph without mutating operands. Row, key, conflict and priority policies belong to the table operation, not structural field lookup.

Ownership transfer of existing storage during Message delivery is a [different operation](#delivery), without copying or reparenting `node`. Admission-policy combination is likewise not `merge`: it selects and checks explicit data without default structural copying.

<a id="registries"></a>
## 20. Tables, queries, imports and providers

Registry, Table, RegistryView, schema and policy are roles of ordinary values, not additional categories or hidden namespaces. Each operation receives a registry root explicitly or reaches it through an expressed reference. Merely having a Table does not trigger lookup; a row keyed `class`, `type`, `provides` or `satisfies` does not change language meaning.

In the table profile the first column provides the row key. `columns` contains names and optional explicit metadata; the cell count of dense rows must be divisible by column count, with missing cells represented explicitly. Text alignment adds no fields. Optional `source` requests a translator-profile projection rather than declaring cell contents as runtime bindings.

A cell can reference data, another key, a description, policy, diagnostic, evidence, provider or callable expression. Dynamic textual lookup starts from a supplied root and uses its ordered children's names. It neither replaces resolved structural references nor makes the Table a global runtime environment. A saved check result remains data with explicit dependencies, not indefinite permission for future calls.

Procedural consumption invokes a selected expression; object/event consumption supplies an explicit target and state; functional consumption follows operation references; logical consumption constructs results and Messages from explicit inputs. Rules, query variables, unification and continuations are data in their respective graph. A query result does not implicitly publish new names for other expressions.

A reactive update may produce events, which are Messages. An agent can propose a row or Message; every candidate undergoes [unified admission](#admission). An explicit policy ranks admitted candidates, and a separate operation publishes the selected result. Neither a successful test nor selection of the best candidate updates the Registry by itself.

Import links explicitly selected operations and construction recipes. It neither scans arbitrary directories, constructs every instance nor copies a runtime namespace. Providers, codecs and lowering rules are selected through imports, references, configuration or supplied Tables. An execution plan retains the chosen reference; changing providers is explicit, not the result of hidden global lookup.

`toLmx`/`fromLmx`, when provided by a profile, specify codec operations with explicit policy. Portable persistence represents content and identities under the codec, not a memory image of native addresses, allocator state and foreign descriptors. The latter require separate external-resource policies.

### Keys and cells

The following source examples describe an optional table profile. Keys `Circle` and `int` in the first Table are data, not declarations. String values in the second describe target spellings; obtaining `"uint8_t"` through `u8` and `spelling` does not change the source type's semantics.

```text
    table:
        name: classes
        columns: key kind
        rows:
            Circle layout
            int    primitive
    end: classes
```

```text
    table:
        name: `translator type-->spelling`
        columns: class (spelling char)
        rows:
            u8  "uint8_t"
            u16 "uint16_t"
            u32 "uint32_t"
    end: `translator type-->spelling`
```

An operator cell can directly hold an implementation key. For example, the following Table selects `u32_eq` for the corresponding pair; `None` is this profile's missing-cell marker, not numeric 0.

```text
    table:
        name: `equals.data`
        columns: class (u32 char) (decimal char)
        rows:
            u32     u32_eq None
            decimal None decimal_eq
    end: `equals.data`
```

### Relations, import and queries

One relation can be represented as a matrix of type pairs or organized around one operand. These are different views of explicit data, not hidden overload registration. Sparse-cell notation belongs to the selected table profile.

```text
    table `equals.relations`

              decimal          real             int
    decimal   decimal_eq       decimal_real_eq  decimal_int_eq
    real      real_decimal_eq  real_eq          real_int_eq
    int       int_decimal_eq   int_real_eq      int_eq
```

```text
    table `decimal.relations`

              decimal          real             int
    plus      decimal_plus     decimal_real_add decimal_int_add
    minus     decimal_minus    decimal_real_sub -
    equals    decimal_eq       decimal_real_eq  decimal_int_eq
```

A table consumer may define import order and numeric priorities. Conflicting-row policy belongs to that consumer and does not override first-occurrence structural lookup. Registry construction and querying remain separate operations.

```text
    table:
        source
        name: appEquals
        import:
            numericEquals
            textEquals
        priority:
            numericEquals: 20
            textEquals: 10
        String:
            String: string_eq
    end: appEquals
```

```text
    table:
        name: equalsData
        columns: left right implementation
        rows:
            decimal int decimal_int_eq
            int     int int_eq
    end: equalsData

    Registry: numericRegistry equalsData

    query: numericRegistry equalsData decimal int
```

### Linked result, effect and implementation tables

A selected cell need not repeat its lookup keys. Here `plus[decimal][int] = decimal_int_add` explains a selection result, not assignment syntax. Separate Tables use that key to describe result, effect, target level, lowering and cost. A `pure` row remains a declared property: its presence does not prove the selected expression's purity.

```text
    table:
        name: plus
        columns: class (int char) (u32 char)
        rows:
            decimal decimal_int_add None
            u32     None            plus_u32_u32_l2
    end: plus

    table:
        name: `plus cell-->result`
        columns: class (result char)
        rows:
            decimal_int_add decimal
            plus_u32_u32_l2 u32
    end: `plus cell-->result`

    table:
        name: effects
        columns: class (effect char)
        rows:
            decimal_int_add pure
            plus_u32_u32_l2 pure
    end: effects

    table:
        name: level
        columns: class (level char)
        rows:
            decimal_int_add L2
            plus_u32_u32_l2 L2
    end: level

    table:
        name: `implementation-->L2 lowering`
        columns: class (symbol char)
        rows:
            plus_u32_u32_l2 "+"
    end: `implementation-->L2 lowering`

    table:
        name: cost
        columns: class (cost serial)
        rows:
            decimal_int_add 10
            plus_u32_u32_l2 1
    end: cost
```

A diagnostic result can also be an ordinary cell value. For a higher-arity relation, an explicit query can follow an intermediate key; the arrows below explain this selection sequence.

```text
    table:
        source
        name: plus
        decimal:
            String:
                diagnostic:
                    code: incompatibleOperands
                    message: "plus(decimal, String) is not defined"
                end: diagnostic
    end: plus
```

```text
    multiply[Matrix][Matrix] -> MatrixMultiplySignature
    MatrixMultiplySignature[leftCols][rightRows] -> matrix_mul_impl
```

### Provider selection

`sqrt.dispatch` selects a result and implementation key; two linked Tables describe lowering and provider. MPFR, ANA_SQRT and CPU_C_Libm are concrete example data, not mandatory built-ins. The selected expression undergoes [ordinary admission](#admission), and the execution plan retains its reference. Physical table storage, hash/SQLite backends, ambiguous-query ranking and a common diagnostic format require a separate profile.

```text
    table:
        name: `sqrt.dispatch`
        columns: class (result char) (implementation char)
        rows:
            BigFloat BigFloat sqrt_mpfr
            fixedQ16 fixedQ16 sqrt_ana
            f64      f64      sqrt_ansi_c
    end: `sqrt.dispatch`

    table:
        name: `implementation-->L2 lowering`
        columns: class (symbol char)
        rows:
            sqrt_mpfr   "mpfr_sqrt"
            sqrt_ana    "ana_sqrt"
            sqrt_ansi_c "sqrt"
    end: `implementation-->L2 lowering`

    table:
        name: providerOf
        columns: class (provider char)
        rows:
            sqrt_mpfr MPFR
            sqrt_ana ANA_SQRT
            sqrt_ansi_c CPU_C_Libm
    end: providerOf
```

<a id="memory"></a>
## 21. Ownership, reachability and lifetime

Every Message, executing or not, owns one logical arena of mutable data. It can contain multiple disjoint regions; these are not additional source-level arenas. Calls, blocks, handlers, branches and retries do not create their own semantic arenas. L3 does not select an arena through an operation argument.

Lexical nesting, storage ownership and reachability are distinct relationships. One arena may contain multiple lexical trees. Transferring block ownership preserves addresses and `node`; the new owner neither becomes the lexical parent automatically nor gains an implicit application reference to every adopted object.

Liveness follows reachability, not block-list membership. Roots include the Message root, active structural arguments, retained own fields, results, formal/dynamic input references, continuations and explicitly retained application/service references. Tracing follows typed graph edges, necessary parents, Array-to-backing links and reference-valued elements. The auxiliary name index is not a root.

Live nodes and descriptors do not move. Growth adds storage without invalidating published references. Lexical exit does not destroy a reachable returned object; return requires no hidden copy or tree promotion. A stable address, however, does not guarantee indefinite life for an unreachable object.

One local collection pass runs at each end-of-turn: determine the outcome, publish successful outgoing Messages or discard failed staging, release completed input/temporary roots, and collect the owner's arena. Ordinary return, `break`, `continue`, `retry`, `redo` and caught `throw` are not separate collection points. A surviving suspended continuation retains its references.

An adopted graph with no application-retained references can be collected at end-of-turn once temporary roots are released. Arena transfer does not make it a permanent root. Retained failure history lives under its explicit policy. Destroying a Message ultimately releases its remaining storage; collection neither scans another mutable arena nor requires a global lock.

A foreign resource has a separate ownership, retention, release and transfer contract. `copy`, serialization and `merge` do not invent native-resource duplication. Immutability of its identifier does not extend resource lifetime. The physical collector, typed pools and region registration are described in [L2](L2_spec_en.md#arena) and [L1](L1_spec_en.md#arena).

<a id="eternal"></a>
## 22. Eternal branches and shared methods

Combined qualification `independent: const: immutable` establishes an eternal branch: its root has no external lexical parent, contents and protected bindings are immutable, and storage lasts until process termination. Any one qualification alone does not establish this sharing contract.

The process's first, root Message retains all such branches from all Messages in a fixed immutable reference Array. The branch set is translation-known; `merge` and Message creation do not append entries. Placement in the retention Array does not reparent a branch's lexical tree. Permitted runtime-value initialization occurs before publication without increasing the entry set.

A second separate fixed Array owned by the same Message contains known method records. A method stores no lexical parent; its concrete callable occurrence supplies its own Structure. Shared records remain live after a borrowing child Message terminates. This is root-Message-owned storage, not an ownerless global registry.

`merge` and Message creation retain explicitly supplied references to admitted eternal branches and method records as terminals. Receiving one branch does not expose its retention Array, root settings or unrelated branches. Mutable state is still copied separately. Every reference within a published eternal branch must have sufficient lifetime; qualification does not make an arbitrary reference to reclaimable storage eternal.

For example, A and B constructed from A's template can have the same eternal E address and distinct mutable x cells. Finishing A and B does not release E. Equal contents of separately constructed branches do not imply automatic interning. Across processes a native address is not wire identity: an explicit codec is required.

<a id="messages"></a>
## 23. Message, actor and serial turn

A Message is an isolated graph with its own ownership. A template or letter need not execute. An L3 Thread is a Message with turn execution and reception of other Messages; every L3 Thread is a Message, but not conversely. Receiving a letter does not automatically create a thread or actor. Launching a separate child requires an explicit operation.

An executing Message has FIFO mail and at most one active turn at a time. A turn consumes at most one admitted input. Different Messages may execute concurrently. An empty mailbox does not finish a background task: its mechanism keeps checking mail according to its execution mode until a stopping condition.

During a turn, one L3 Message executes on exactly one OS thread; transfer to another worker is allowed only between turns. An L3 Thread has one selected execution mode: either native code or the graph interpreter. These modes are mutually exclusive, not a common or hybrid mode: one turn does not run both paths for one Message. The `endturn` boundary commits the L3 Thread mode for the next turn together with the other boundary state; changing mode neither copies the method nor creates a second concurrent executor.

One arena has one writing lane. A Message's handler, local management, scheduler and service state are mutated on its own lane. A foreign sender neither appends itself to the owner's ready list nor modifies its application data. Mail admission and designated single-cell control protocols belong to the Message mechanism and grant no general access to foreign memory.

A parent manages only its direct children, retaining their list and scheduling policy locally. Each child likewise manages its own children. There is no separate global language scheduler, shared mutable Message registry or global management lock. A router, if needed, is itself a Message with private state.

An L3 Thread is a logical serial lane, not a promise of a dedicated OS thread. Both a dedicated thread and parent/platform-driven turns are possible. L2 implementation defines the API and mapping policy; this does not permit two simultaneous turns of one owner. Parent-liveness polling and self-maintenance are needed even by a childless actor.

The process's initial graph belongs to the root Message. Initial settings and user input arrive at entry; subsequent coordination uses Messages. Grouping Mix roles, cursors, pages and notifications into Messages remains a design choice: neither one actor for the whole document nor a separate actor for every cell is required.

<a id="addressing"></a>
<a id="delivery"></a>
## 24. Delivery, ownership and mutation order

The local intermediate organization level addresses participants by physical memory addresses within admitted Message-mechanism operations. Hierarchical index chains belong to [WorldWideMix](#worldwide), starting at the third organization scale, not to every local letter. Organization scale must not be confused with language profile L3. A native address is not serialized as a portable address on another machine.

Delivery of an existing non-executing Message can transfer its storage ownership to the receiver without moving data. Blocks and region classification join the receiver's single arena; the former owner no longer releases them. Lexical links remain unchanged; application attachment of the received root is explicit. Storage transfer is not copying and does not retain the sent object as a second independent owner.

Creating a new executing Message from a template uses [graph copying](#composition) and a separate arena. Ordinary settings are copied; admitted eternal references are retained. Creation does not implicitly import the parent's entire live context. Handing off supervision of a running child, transferring stopped storage and serializing a remote Message are three different contracts.

Concurrent arrivals have no predetermined relative order. Mailbox admission establishes FIFO order, preserved by consumption. Neither random shuffling nor sender-clock order is required. Empty-check/wait coordinates with admission: an accepted letter must not disappear as the receiver begins waiting. Capacity, backpressure and redelivery are explicit implementation/protocol policies.

Multiple senders mutate one object by sending its owner a complete operation. For example, `add(2)` and `add(5)` from initial 0 produce 7 in either admission order. Separate `read` and `write` requests are not one protected operation: two senders may both read 10 and write 11. Serial turns prevent overlapping execution but establish neither transaction rollback nor protection for a split protocol.

Delivery success means admission, not application of a requested change. A result requires protocol-defined reply correlation. The core does not automatically retain per-sender last identifiers or suppress duplicates. Deduplication, retry, batching and sorting requirements belong to explicit protocols without changing base FIFO.

Current-turn outgoing letters are staged separately from the published queue. A successful boundary publishes them in staging order; failure discards unpublished staging. This does not undo graph mutations already performed. The [collection boundary](#memory) follows outcome and temporary-root processing.

<a id="lifecycle"></a>
## 25. Completion, children and retained failure state

`success` means actual completion of assigned work, not an empty mailbox or delivery of one letter. Once set, the Message's main algorithm receives no next turn; finishing local child maintenance depends on implementation. `running = 0` during execution may be a stop request: physical storage-handoff safety is established by a separate protocol, not inferred from one flag.

A child checks parent liveness and begins its own orderly close after sustained lack of response. Forced closure from above is the second, emergency path. A parent services its direct children rather than arbitrarily managing grandchildren. Closing propagates through the family instead of retaining a released branch forever.

A running child can survive parent closure only through explicit supervision handoff to another live parent with suitable authority. It retains its arena, mail and turn; supervision and scheduling placement change. This is not storage adoption. Storage transfer ends the non-executing source's separate life; new children created from adopted content belong to the receiver.

Stopped failed state may be transferred to the parent without copying and retained as failure-history graph; successful history is reclaimed by default. Transfer requires a stopped, handoff-safe source with no native users. Stop request, actual exit, safe transfer and release must remain distinct; concrete flags and placement belong to the [L2 kernel](L2_spec_en.md#message).

A participant that loses its parent closes under an orphan policy: successful completion releases it, while failure history may remain until an explicit deadline. The old implementation includes intermediate host/root-transition details; these establish neither a second global registry nor an indefinite owner outside Messages. Detailed states and current migration limits belong in the [thread description](L2_spec_en.md#thread), without replacing L3 isolation.

<a id="pipeline"></a>
## 26. Incoming-message admission and execution

Incoming data pass through an explicit decoder to become a Message graph. The destination, route and receiving expression are then selected through supplied references or lookup from a supplied root. Neither Message text nor a Table reference installs a hidden environment or grants automatic trust.

Candidate admission uses only the [unified mechanism](#admission): analytical traversal of the used tree, followed by receiving-expression unit tests executed by the graph interpreter. Text decoding constructs the input graph before this stage; the test interpreter does not interpret source text instead of the graph. Former independent validators, `RuntimeImplements` and evidence are not alternative admission routes.

Routes, authority, lifetime and permitted effects are explicit contract data. Candidate-property checks belong to receiving-expression tests; cryptographic operations may supply verifiable facts. Evidence references exact data, policy and authenticated ingress facts, but does not bypass mandatory checking. Result-reuse rules remain unsettled.

After admission, an explicit implementation/provider reference is selected and an execution plan is built with arguments, results and required policies. Planning does not execute the chosen application operation, although admission already executed its tests. The executor follows the retained reference. A result or declared failure becomes input to the next explicit consumer.

A logical generator may construct zero or more proposed Messages. Each re-enters the same path; generator origin confers no trust. Received text does not transfer another actor's running frame. Work executes in the receiver's serial turn unless a separate child launch is explicit.

<a id="mix"></a>
## 27. Mix: active marks and intervals

Mix is a parallel mark/interval overlay on document positions, not a second parse tree or XML-like nesting. One source traversal builds ordinary Structures and anchors Mix marks. Structural nodes, fields, Array rows and source intervals can participate in overlapping active sets even without explicit braces.

`{…}` adds explicit structural mark payload. Its local parsing, strings, comments and source-level anchoring are defined in the [grammar](LMX_grammar.en.md). An ordinary structural consumer may ignore Mix-flagged nodes; a document consumer projects them into the active overlay. The parser does not choose attribute-conflict policy.

`{color: red}` opens an active entry with head `color` and close name/value `red`. `{end}` closes the latest still-active explicit mark; `{end: red}` closes the latest active entry with that close value, regardless of its head. With active `{style: red}` followed by `{color: red}`, the named close removes the latter, not the former.

```text
{color: red}
{color: green}
text
{end: red}
{end: green}
```

Closing red here does not close green. A later mark does not destroy an earlier one: a simple renderer may display the latest active value, while a semantic consumer can inspect the whole ordered chain and intersections. The base model is therefore not a flat key-to-single-value table. An unclosed entry remains tracked to the document/profile boundary and may become an interval, state or diagnostic under the contract.

Mix has three distinct roles: source-mark overlay, document placement tree and cooperating-Message execution. An interval, placement cell and Message do not correspond one-to-one. Document updates, notifications and cursors must follow ownership and FIFO rather than inherit the former Java implementation's locks and callbacks as L3 rules.

<a id="worldwide"></a>
## 28. WorldWideMix: addresses, cells and navigation

WorldWideMix defines a placement tree: where a cell is situated. The LMX graph defines a value: its fields and what an expression consumes. These trees meet in a cell but are not identical: address `3.17.4` is not field path `file\close`, and `implements` does not number Mix neighbours.

An address is a sequence of nonnegative integers from root to cell. Neither an individual branch's depth nor index magnitude has a language-defined finite ceiling; implementations must check actual resource limits rather than overflow their representation. Leading textual zeros do not change meaning: `03.17` equals `3.17`. A prefix addresses a subtree; shortening the path reaches an ancestor.

The numbers count neighbouring positions, not bytes. A cell may hold a word, buffer or value reference. Varints, mixed-width fields and other codecs store the same integers rather than defining different address types. Changing storage from 5 to 12 bits does not rename `3.17`. Examples of tens of RAM neighbours and larger disk-sector occupancy illustrate carriers, not address-model limits.

Branches may have different depths. For prefix P, `bunch(P)` contains only occupied direct indices. If `{0,4,5}` are occupied, `P.4` is followed by `P.5` and preceded by `P.0`. `next`/`prev` neither descend, ascend nor traverse every document worldwide. `down`/`up` change depth; `next`/`prev` change the last index within one bunch.

A cursor is a path plus a buffer-cell position when needed. Insertion/deletion affects the relevant sibling level rather than readdressing every subsequent file byte. A document is a root, placement tree and mark overlay; a file is one way to serialize pages. Human names, realms, volumes and chapters are attributes/profile conventions, not DNS or a fixed number of levels.

Carriers can be RAM, disk, wire, radio or removable storage; Internet and HTTP are optional. A Message may carry a short address, authority and consumer information instead of an entire large body. The consumer reads needed parts by cursor. Content typing follows the LMX value and [admission](#admission), not its Mix address, MIME or filename extension.

The Mix overlay places intersecting marks, cursors, attributes and intervals on the same positions. Page-value composition uses ordinary [merge](#composition) with first `[0]` occurrence, not neighbour-address overriding. Disk exhaustion does not authorize automatically spilling data to an arbitrary neighbour: refusal, compaction or an explicitly authorized mirror belongs to storage policy.

<a id="mix-coordination"></a>
## 29. Prefix coordination and mirrors

Mutable Mix state belongs to a Message. A change request addresses its owner and executes in that owner's serial turn. Concurrent senders to one owner need only FIFO; concurrency alone does not require an extra lock-grant step.

Logical prefix exclusion is a separately selected Message protocol, not a native cross-machine mutex or mandatory part of every operation. Reserving P covers all of subtree P, including deeper bunches. A common-prefix coordinator reconciles affected owners but neither writes directly into their arenas nor arbitrarily schedules descendants.

A reservation on `34.3.7` leaves independent `34.3.1` work alone; one on `34.3` must account for conflicts in both branches. The protocol must define when exclusion takes effect, treatment of already admitted commands and protection against late commands under revoked grants. Authority to request a change and a current reservation are different facts. A coordinator record alone does not enforce every write path.

Prefix exclusion implies neither distributed transaction, common rollback nor physically simultaneous mutation. An effective time T requires rules for clock uncertainty, lateness, nondelivery and partial failure. A timeout does not prove the former participant stopped. Grant/token formats, generations, retries and recovery remain explicit protocol choices, not implicit obligations of every Message.

A mirror is another prefix with corresponding content for a particular consumer, not a new fundamental document kind. Writes go to the primary owner; changes reach the mirror as Messages. A reader may tolerate lag; writing through a stale mirror is not automatically safe. A mirror's name is an attribute, while its address is its own path.

Equivalence of primary and mirrored values is relative to the receiving expression's used tree and tests. It does not mean perpetual byte equality. A last-wins projection is permitted for a selected renderer but does not destroy the complete occurrence chain. History and undo may consume Mix changes; a new whole-document version on every edit is not a core rule.

<a id="transport"></a>
## 30. HTTP and service boundaries

HTTP/REST LMX is a transport profile, not the execution core or WorldWideMix. A service is a set of cooperating Messages, not a shared mutable heap. An external request becomes a Message, then undergoes [intake and admission](#pipeline), execution and result-to-transport mapping.

An HTTP target combines normalized endpoint and route. Example: endpoint `https://archive.example.org` with route `/inbox/save`. The receiver resolves the local route in an explicit Table. A route neither names an OS worker, exposes a raw Thread handle nor grants authority by itself.

The original profile posts a complete LMX document with `application/lmx`. A provider receives the URI and exact bytes, returning transport failure or admission status. Substituting a test provider, WinHTTP, libcurl or another adapter does not change Message semantics. No universal process-wide HTTP singleton follows.

A synchronous profile may return the semantic reply in the HTTP response; an asynchronous one may acknowledge admission and later send a Message to `replyTo`. The semantic reply carries `correlation` matching request `id`. Admission, execution and application success remain distinct events.

Instead of a large body, an explicit cursor with range and reading mode may be supplied. Its address, authority and lifetime belong to the receiving expression's contract. Reading compressed content, decryption and format migration are explicit operations; a supplied `targetDescriptor` remains ordinary data rather than a hidden descriptor on every value.

The source external-body example supplies a segment reference, range and reading mode. Cursor authority and lifetime are checked by the receiving expression's unit tests; a short envelope does not waive admission of the data subsequently read.

```text
    message:
        id: "report-42"
        to:
            route: "/reports/process"
        end: to
        expression:
            process:
                body:
                    cursor: reportStore\flightLog\segment42
                    range: current
                    mode: readStream
                end: body
            end: process
        end: expression
    end: message
```

The declarative routing rule below is profile data, not a promise that the L2 statement implements this nested `send` form. A separate receiving expression must interpret the condition and construct the delivered Message.

```text
    route:
        when:
            `equals.data`[userRole][admin]: true
        send:
            to: AdminService
            expression:
                openPanel
    end: route
```

<a id="authentication"></a>
## 31. Authentication, authority and evidence

Credentials, verifiers, authority and evidence are explicit values in Message flow, not a global role hierarchy. A protected verifier checks a primary credential without retaining its original secret. A cryptographic result is a fact for policy, not automatic authority for every action.

A module, service, archive, directory or administrative operation may have its own verifier realm. A contract may require one verifier, several for one user, or a user/session quorum. Creator/child relationships establish lifecycle management, not content-reading rights. Resetting an access verifier does not recover content encrypted using a key derived from the former credential.

The initial username and empty password permitted by an earlier installation profile are explicit installation state, not universal security policy or permission for external input to bypass admission. A user or administrator may replace the verifier. A concrete first-run policy must be represented separately.

After primary-credential confirmation, policy may issue a delegated module/service ticket with permitted operations and expiry. Changing/resetting the primary verifier invalidates dependent tickets under explicit policy. OAuth and OS login are pluggable modules; they neither automatically replace the chosen verifier nor gain authority from language level L2/L3.

AuthEvidence may explicitly contain user, verifier realm, ticket, permitted actions and quorum satisfaction. It is data with dependencies and lifetime. The receiving expression checks required properties in its unit tests under [unified admission](#admission); the former independent validator layer is not retained. A password match or valid signature creates no implicit roles, name bindings or indefinite admission.

<a id="crypto-values"></a>
## 32. Cryptographic values and providers

L3 expresses cryptographic intent, key relationships, policy and protocol state. A provider implements primitives, secure storage and platform interfaces. The names below denote contracts, not final parser keywords or a mandatory type hierarchy. Providers are explicitly selected by profile, reference, capability, configuration or service.

AlgorithmId contains family, algorithm, version/profile and relevant parameters. Parameters affecting interoperable protocol bytes are explicit or fixed by a named profile. Algorithm substitution and silent downgrade are prohibited. Missing statically required providers fail build/link; unsupported dynamic selection fails explicitly at the operation.

PublicKey is ordinary non-secret data with algorithm, format and key bytes, optionally id/metadata. It may be copied, stored and transmitted. Raw, SPKI, JWK and other encodings are explicit choices; a provider's internal object is not a wire format.

KeyRef is an opaque secret-key capability with a contract covering owning provider, operations, lifetime and export. It is neither a raw L2 address nor necessarily an Array of secret bytes. KeyPair combines PublicKey and private KeyRef. Generation does not automatically publish private material into the graph; non-extractable keys are valid implementations.

A Verifier explicitly identifies algorithm, format/version, salt and verification parameters: memory cost, time/iteration cost, parallelism and result or canonical encoding. KeyPolicy may define uses, expiry, rotation, revocation, versions, object association, export and recipients; no universal mandatory policy Structure is fixed.

Passing KeyRef, returning it, storing it in a field, composition and provider changes do not export the secret. Its contract defines local multi-Message use, retain/transfer and serializability. The portable default is provider/runtime locality without wire serialization. Sending a secret to another machine requires explicit permitted export/import or a protected envelope.

Secure memory is a set of distinct capabilities: controlled secret storage, erasure, page locking, guard pages, non-extractability and hardware protection. One does not imply the others. Erasing copies outside provider control in UI, VM or host cannot be promised. Direct calls, service Messages and asynchronous adapters may implement one contract without introducing a new common scheduler or an already defined language `await`.

<a id="crypto-operations"></a>
## 33. Cryptographic operation contracts

The following signatures specify semantic inputs/results, not physical ABI. Byte results remain ordinary values; provider-private key representation stays hidden. These operations do not create another argument-admission mechanism.

| Family | Inputs and result | Essential contract |
| --- | --- | --- |
| `Random.bytes` | length → bytes | Cryptographically suitable randomness or explicit failure; no weak fallback |
| `Crypto.equalConstantTime` | a, b → boolean | Claimed timing contract for equal lengths; length may be public |
| `Hash.digest` | algorithm, data → digest | Explicit algorithm; digest is ordinary data unless separately protected by policy |
| `Mac.compute` / `Mac.verify` | algorithm, KeyRef, data, plus tag for verification | Produce tag or Boolean/failure without exposing intermediate secrets |
| `Kdf.deriveKey` | profile, inputKeyRef, salt, info, outputKeyProfile → KeyRef | Provider retains the secret result without needless export/import |
| `Kdf.deriveBytes` | profile, inputKeyRef, salt, info, length → bytes | Explicitly publishes derived material into ordinary storage |
| `PasswordVerifier.create` / `verify` | password with policy/profile or verifier | Produce Verifier or Boolean/failure under declared parameters; password is not persistent verifier state |
| `KeyPair.generate` | algorithm/profile, policy → KeyPair | Public key and private KeyRef with usage restrictions |
| `PublicKey.import/export` | algorithm, format, bytes / publicKey, format | Explicit public-encoding conversion |
| `PrivateKey.import`, `SecretKey.import` | algorithm, format, secretBytes, policy → KeyRef | Explicitly imports already visible secret material into provider storage |
| `PrivateKey.export`, `SecretKey.export` | KeyRef, format → secretBytes | Explicit permitted export only; non-extractability causes failure |
| `Signature.sign/verify` | profile, respective key, message, plus signature for verification | Signing never exposes private bytes; profile fixes format |
| `KeyAgreement.derive` | profile, privateKeyRef, peerPublicKey, outputKeyProfile → KeyRef | Prefer a session key directly; raw shared secret requires a separate operation |
| `Aead.seal/open` | profile, KeyRef, nonce, data, associatedData | Ciphertext with tag or authenticated plaintext/failure |
| `Key.release` | KeyRef | Invalidates handle and releases/clears controlled storage under its contract |

AEAD authenticates associatedData without encrypting them. The profile fixes nonce rules and ciphertext/tag layout; prohibited nonce reuse cannot be silently admitted. Authentication failure publishes no partial unauthenticated plaintext and differs from successful empty output. A helper may generate nonce, but nonce remains explicit protocol data.

Secret import minimizes buffer lifetime where the provider controls storage. Export explicitly changes responsibility for secret lifetime. Automatic release may replace `release` under an explicit contract, but a profile may require deterministic disposal. GC finalization does not promise erasure of uncontrolled copies.

Failures distinguish at least unsupported algorithm/profile, invalid key/encoding, prohibited export, authentication failure, invalid signature, invalid nonce/parameters, unavailable secure randomness, unavailable provider, internal failure and resource failure. Signature verification may return false under its contract. No failure authorizes silent algorithm weakening.

An interoperability profile fixes algorithm, parameters, key/result encodings and protocol bytes. SHA-256, HMAC-SHA-256, HKDF-SHA-256, Ed25519, X25519 and Argon2id are original-project testing candidates, not a mandatory list for every platform. AES-GCM, ChaCha20-Poly1305-IETF and XChaCha20-Poly1305 are different AEAD profiles. An Argon2id verifier cannot silently be read as PBKDF2.

Provider tests must include cross-implementation vectors and negative cases: invalid signature/tag, unsupported profile, non-extractable or released key and unavailable provider. Compare semantic bytes/results, not backend object layout. Functional tests do not establish timing, erasure, non-extractability or entropy quality; claimed guarantees need separate evidence.

Final receiver names, normalized AlgorithmId/Verifier/Policy Structures, mandatory initial profiles, exact error subtrees and provider registration remain open. Streaming, secret streams, HSM/TPM, KEM/PQC, remote key services and protected-envelope formats are separate future profiles, not already available implementation semantics.
