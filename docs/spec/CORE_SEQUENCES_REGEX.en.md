# Unified types, sequences, patterns, and callable adapters

The [naming review](NAMING_2026-11-22.md) records the current public words and their language analogues; the LMX contracts below remain authoritative.

**Current documentation, 22 November 2026.** This chapter applies the three specifications shipped at the root of this same archive: [types](#types), [sequences](#sequences), and [text patterns](#patterns). The callable-adapter requirements are those already present in the uploaded [semantics, §37](LMX_semantics.en.md#adapter-behavior), including its A/B acceptance cases. No earlier archive is a source for this revision.

The language contract below is normative for this documentation edition. LMX source implementations are supplied in [the core source directory](patterns/LMX_Fn_Receivers/README.md). Their integration with the actual kernel and execution of the acceptance fixtures remain to be performed. Source inspection and publication checks do not constitute runtime tests.

<a id="types"></a>
## 1. Type expressions and declarations

A type is represented publicly by an ordinary `int` code. `T[]` constructs the interned type of an array whose elements satisfy the complete requirement T. `T@` constructs a pointer type. Repeating postfixes applies them from left to right: `int@[]`, `int[]@`, `int[][]`, and `int@@` are different requirements. Pointer depth is any finite value supported by available resources; there is no language limit of three levels.

The common TYPE-role normalizer accepts a valid code, a symbolic type atom, an uninitialized typed record, or a full model as appropriate. It preserves complete structural and callable requirements. In `@[]`, the left `@` is the universal reference requirement; the result is the existing Structure/reference-array type. It is not another STRUCT/ARRAY category and allocates no array value. A numeric value that happens to equal a type code does not acquire a type role by itself.

| Written form | Meaning |
| --- | --- |
| `[]: pending` | Uninitialized place accepting any Array, including a dense Array and an ordinary Structure |
| `@[]: refs` | Uninitialized place requiring the specific reference-array/Structure type |
| `int[]: values` | Uninitialized array-of-int place |
| `int[]: values []` | Initialized empty array of int |
| `int[]: values [1 2 3]` | Initialized named typed array |
| `int[]: [1 2 3]` | One anonymous typed array value |
| `[]: [1 2 3]` | One anonymous ordinary Structure/reference-array value |
| `[]: values [1 2 3]` | Named generic-array place initialized with a Structure |
| `@: values [1 2 3]` | Universal reference to a Structure; no additional wrapper |
| `T[]: [copy(S)]` | Typed array from the explicit element stream inside the square group |
| `T[]: destination Source` | Named place initialized from a suitable existing value |
| `@: p` / `T@: p` | Uninitialized universal/typed reference |
| `T@: p 0` | Initialized null reference; distinct from uninit |
| `int@: 65536` | One unnamed reference-to-int value given by address 65536; no place is declared |
| `@x` | Address of the actual place x under the selected level's address contract |
| `x@` | Pointer type constructed from x in TYPE role |
| `@(name)` / `[](name)` | Ordinary compact declarations, equivalent to `@: name` / `[]: name` |

The author-approved structural forms `Model@: p`, `int@: left`, `Model[]: arr`, `int[]: values`, `Model[]: arr [Model Model]`, `Model[]: [Model Model]`, `int[]: values [1 2 3]`, and `int[]: [1 2 3]` are retained explicitly in the [positive-form acceptance matrix](TYPE_DECLARATION_FORMS.md). The complete type is always on the left of the colon. In the Model initializers both elements refer to the existing Model value; construction does not copy its fields, reparent it or replace the complete requirement with a physical reference code. Named and anonymous square initializers share ordinary element admission.

A sole declaration identifier is consumed as a NAME before lookup; a sole square group supplies anonymous data. A NAME followed by a square group supplies the explicit initializer. An existing same-named value cannot change this classification. The generic receiver path determines argument roles before attaching an initializer group as if it were an index. There is no whitespace-specific array parser.

The first argument distinguishes a named place from an unnamed value for references as well as arrays.
`int@: p` declares a place; `int@: 65536` constructs a reference value from the address. There are no unnamed
variables. This is the ordinary NAME/VALUE distinction, not a separate declaration or parser rule.

A typed anonymous array constructor requires its square group. `T[]: copy(S)` is not an alternative anonymous
constructor. `@[]: [S]` holds one reference to S; `@[]: [copy(S)]` receives the explicitly emitted fields.
A type expression performs no copy, initializer execution, or compilation.

A written empty suffix `T[]` constructs a type. A suffix containing a written index expression uses indexing, even when that expression later produces an empty stream: `a[()]` and `a[copy(empty)]` do not become type constructors. Original groups and postfix occurrences remain in the source graph.

`Struct@: p` and `(Struct)@: p` each normalize their complete left description; the enclosing group in the latter is not silently removed. Prefix `@Struct` still obtains an address. To address a field, write `@D\field` or `(@D\field)`; bare `@(D\field)` now has ordinary compact-declaration reading, not an address exception.

`sys\typeof` of an int variable containing a type code reports int. A TYPE-role consumer reads that code from the payload. For `uninit:T`, normalization reads its type information without reading absent value bytes. Every uninitialized array or pointer has zero payload bytes; it is neither an empty descriptor nor a null pointer.

### Interning, admission, and layout

The common type context interns full derived requirements. Length and capacity are properties of values, not distinct array types. Attach must preserve existing record codes and addresses and retain their type metadata. Within contexts whose arena chunks can be attached without recoding, the same code cannot designate incompatible types. Restoration from an independent context resolves the complete type descriptions under the existing rules; accidental numeric equality does not establish type identity.

The directed relation is:

```text
A[] satisfies B[]  iff  A satisfies B
```

The common kernel maintains a table of completed checked type pairs, with their direction, complete requirements, and applicable conversion context. A repeated check of the same stable pair reuses its completed result, including between calls when the requirements and context remain applicable. An in-progress recursive comparison is not a proven success. Mutable value-dependent tests, concrete field maps, bounds, lifetime, and access rights are still checked where required. This table is type metadata, not a second executable graph or a persistent snapshot of namespaces.

Successful admission does not change actual storage. An admitted Array<A> is read with A's actual layout and stride; a store must be valid for its actual element requirement. Checking types does not execute a user converter. Empty arrays follow the same type relation as nonempty arrays.

<a id="types-details"></a>
### Details of type forms

A written form is processed in one order: its source form and boundaries are kept; the consumer's role for it is established (a declaration name, a type description, or an ordinary value); it is resolved by that common contract; the reached operation then executes in the established order, each once. The outer colon and the postfix parts of a head are determined structurally; a fragment is never executed first and recognized afterwards, by its result or failure, as part of a head or a type description. In the VALUE role the ordinary prefix/postfix mechanism applies inside the boundaries of the argument: at the start of a required expression `@` may begin an address operand; after a completed left operand `@` may be a type postfix. Missing square brackets are not guessed, and no branch is chosen by the success of an evaluation.

The withdrawn readings are not kept as a second standard or a second parser path: the typed `[](T): …` and `@(T): …`, the prefix type codes `@int`, `@@int`, `[]T`, the typed heads `@Struct: p`, `@(Struct): p`, `[]@` as the Structure/reference-array type (now `@[]`), `@(int)` or `@: int` as the type of a pointer to int (now `int@`), `[]: int values …` and `[]: char text` (now `int[]: values …`, `char[]: text`), and `@: p Model Other` (now `Model@: p Other`). Their bytes are read by the common resolver with their ordinary meaning, if any; they are not converted into the new heads. The compact equivalence `@(name)` ≡ `@: name` and `[](name)` ≡ `[]: name` is a property of the ordinary receiver applied to the retained form, not an early textual substitution that loses the form's role or boundaries. A compact declaration with an invalid or occupied name gets the ordinary name diagnostic.

```lmx
int: value 7
int: typeCode sys\typeof(@value)
```

`@typeCode` is the address of the int place `typeCode`; `typeCode@` is the code of the pointer type to the type held in `typeCode`; `typeCode[]` is the code of the array of that type. A payload that happens to equal a known type code does not change the address operation. Adding a colon, `typeCode@: p`, uses the type already determined; it does not switch the meaning of the operator.

Three results are distinct: a type code (`int[]`, `int@` give an ordinary int value), a declared place without a value (`int[]: pending`, `int@: ptr`), and a constructed value (`int[]: [1 2 3]`, an initialized reference place). `sys\typeof` is the one type query; `typeof` in examples denotes the same query, not a second API. There is no user Type box, no new token class and no pointer to a service description in place of the code.

```lmx
int: numbersType int[]
int[]: numbers [1 2 3]
```

`numbersType` holds the code of the concrete array of int, and the type of `numbers` agrees with that code under ordinary reflection. `sys\typeof(@numbersType)` reports the type of the int place itself. A TYPE-role consumer given an invalid or unavailable code fails with the ordinary type refusal; the number is never treated as an arbitrary address of metadata.

The compact form exists at every depth: `@@(name)` in the position of a completed Frame is `@@: name`, and so on for `@@@(name)`. It declares a universal reference of that depth and never obtains a type from `name`.

A group to the left of a type postfix keeps its meaning: `(Struct)[]` and `(Struct)@` use the complete requirement the common normalizer obtains from the group; they are not declared equal to `Struct[]` and `Struct@` by removing the parentheses — when `(Struct)` is an anonymous one-element Structure, that is a different structural model, and equality of the normalized requirements is established by the common mechanism. `[]: [Name]` holds a group with one element and is not `[]: Name`. `[]: []` and `int[]: []` hold a present empty group and construct an empty value; a missing initializer is a different state. Empty and one-element groups are kept in the clean graph and in roundtrip. A standalone `[]` with no left form keeps its ordinary literal or receiver-symbol role; it is not the postfix constructor applied to a missing argument.

`int@[]` is an array of pointers to int, `int[]@` a pointer to an array of int, `int[][]` an array of arrays of int, `int@@` a pointer to a pointer to int, `int@@[]` an array of depth-2 pointers to int. A depth beyond the available resources is refused by the ordinary resource failure; a depth is never truncated or wrapped. The depth of a type orders no chain of objects: `int@@@: p 0` initializes one null reference and allocates no intermediate cells.

In the TYPE role, n postfixes `@` mean n levels of pointer, and the nested requirement of each level is kept. In a chain of addressable places

```lmx
int: value 7
int@: p1 @value
int@@: p2 @p1
int@@@: p3 @p2
```

each level addresses the real place of the previous level: `p2` holds the address of the cell `p1`, not the target stored in it, and no level is skipped because machine pointers have one size. The same holds for n > 3.

An anonymous constructor yields one Array value and declares no name; an ordinary expression consumes it directly: `2 * (int[]: [1 2 3 4])` gives `[2 4 6 8]` with no internal variable. A named construction uses the ordinary place, scope and admission rules of declarations; its initializer is not executed a second time to obtain the result of an expression.

Collecting a stream into a constructor is not a second copy: `copy` and `merge` keep their deep copy, maps and lexical relations; the container does not become the owner of copied methods and does not run stored bodies. An empty stream in `@[]: [copy(S)]` gives an empty Array, not one empty element. Expressions written to obtain elements execute once, in the established order; consuming a ready graph field does not run its computed declaration.

In DATA, `array(int: first 1; int: second 2)` and its vertical form `array:` with the same fields declare an ordinary named Structure, which is also an Array. Its name keeps the declaration contract of a Structure; it is not an assignable variable holding a reference. In CODE the same forms keep their ordinary role of a call. Sequence operations accept such a Structure directly; its named fields and physical elements stay its ordinary fields and elements. Reading the graph does not execute the receiver forms stored in it, and methods in it do not create a separate callable container. Two separately written groups construct their own values. When two places, one declared with `[]` and one with `@`, receive the same existing Structure, both refer to it: admission through `[]` or `@` performs no copy, creates no wrapper, and does not change `parent`; `sys\typeof` and the descriptor do not distinguish two artificial kinds of object.

In the active arena, obtaining the same derived type with the same complete parameters returns the existing code; a missing type is registered once. The key distinguishes at least the constructor and its complete source requirement: array of T, pointer to T at every depth, and their compositions. `int[]`, `char[]`, `int@` and `int@@` are not merged because their machine sizes are equal. A derived type of a Structure keeps its complete structural requirement; two different requirements are not replaced by the physical code of an ordinary Structure, and no user Structure gets a physical type merely for its name — a derived type is created when a type constructor is actually applied. Codes come from the common code issue of the kernel; a local index of an independent vector is not a code. Two equivalent codes obtained earlier are recognized by the common equivalence mechanism; old records are not rewritten for one number.

One normalization and resolution path serves every consumer: type operands `T[]` and pointer types, typed heads and declarations, `sys\typeof`, code checks and layout access, `satisfies` and complete signatures, the interpreter, native lowering and the common call transports, copy/merge, and saving and restoring values. Prepared native code keeps the same type contract without automatic tracking of graph writes.

The relation above keeps its direction; it is not equality of the codes of A and B, equality of storage sizes, or a symmetric relation. Complete models, reference requirements, nested Array types and callable signatures remain part of A and B and are not erased to a common Structure or void-pointer tag. For pointer types the existing common contract of correspondence of their complete requirements applies at every level of depth; this edition adds no other rule for pointers. Type compatibility is not a check of a text against a Pattern, a function call, a converter run or a check of mutable object state.

<a id="expressions"></a>
## 2. One Expression mechanism

`::`, the existing `to` and `record` operand implementations, postfix type construction, and the five pattern words all use the established Expression mechanism. Constant `PASS_ARGS_AS_IS` and `PRIORITY`, ordinary left/right preparation, dependency-demand evaluation, and normal receiver discovery are retained. There is no second operand ABI or regex parser.

The sole conditional opening rule remains exactly this: **left is a written anonymous Structure; right has exactly one argument; that argument is also a written anonymous Structure. Only one outer level of the right argument is opened. Left stays intact.** It is neither recursive nor a P0 transformation. Named references, returned arrays, and nested values do not open merely because they are arrays. Ordinary callable W/E selection remains a separate contract.

`map`, `apply`, `partial`, `compose`, `pipe`, sequence mutations and searches
retain their real receiving contracts in both forms. The parsed role selects
the receiver or operand representation of one published operation family,
then ordinary declaration selection applies. The shared translator preserves
omissions, named actuals, source order and all non-VALUE roles; it does not
blindly reinterpret one callable's DATA as another ABI. Built-in receivers
already enter Expression through P0 and need semantic lowering, not a new
parser. Library-built VALUE operands reuse `FxAsOperand`. See
[operation forms](OPERATION_FORMS.md) and [publication](GENERIC_OPERATIONS.md#32-публикация-под-одним-именем-и-пересечение-перегрузок).

Array arithmetic keeps its existing operand names: `*` is elementwise multiplication; `concat` joins sequences; `matmul` is matrix multiplication. Two array inputs must have equal lengths. Array/scalar operations evaluate the scalar once and preserve operand order. When every sequence input is dense, including array/scalar and scalar/array, the operation returns dense R if the scalar contract already establishes one complete result requirement R; otherwise, or with a Structure input, they return a reference-array. They do not execute a probe element to guess a type. Each elementwise comparison produces the scalar predicate result, normally int 0/1; the result array follows the same representation rule. Empty inputs have the selected representation without callback execution. Length and byte-size arithmetic must not overflow. No truncation, singleton broadcasting, implicit float promotion, or inferred multidimensional shape is added.

<a id="sequences"></a>
## 3. Universal sequence operations

A universal `@` points directly to a `{type value}` record. A sequence operation inspects the actual array type. For Structure/@[], reading a slot obtains its stored record reference; for a dense T[], reading obtains T through typed access. Preparing an addressable primitive actual, if necessary, uses the ordinary call/value machinery and a sufficient lifetime. It does not require boxing the whole source or inserting a user-visible `{value: ...}` wrapper.

Every array has variable length and the existing `parent/length/storage` descriptor. Capacity remains in its existing separate table. New selection results have a new outer container; shared referenced targets and their actual parents remain shared. Dense selection copies values. A selection is not a writable view and does not infer a rectangular shape.

| Receivers | Contract |
| --- | --- |
| `map(items; transform)` | One ordinary callback per item; reference-array of result records |
| `filter(items; accepts)` | Stable selection preserving the actual element storage profile |
| `foldl(items; seed; step)` | Left fold; empty source returns seed |
| `scanl(items; seed; step)` | Seed followed by all accumulated result records |
| `zip(first; second)` / `zipWith(first; second; combine)` | Pair/combine up to the shorter length; unlike equal-length array arithmetic |
| `traverse`, `bind`, `list`, `groupBy`, `transpose` | Existing container meaning, now accepting dense and reference sources through shared access |
| `select`, `omit`, `reorder` | Physical indices; selection preserves storage profile; reorder requires a full permutation |
| `project` | Selection followed by one shared graph copy/map |
| `range(start; stop; step := 1)` | Materialized half-open range through an explicit step/order profile; the default exact-integer profile retains dense int output and checked extent |
| `slice(source; begin; end)` | Validated half-open interval; use select with range for a step, without negative-index inference |
| `reverse(source)` | New container in reverse physical order |
| `concat(parts)` | Same dense T when all parts have the same dense T; otherwise a reference-array |
| `compress(source; mask)` | Same-length int truth mask, stable selection |
| `any`, `all`, `index`, `count` | Ordinary predicate calls in order; early stop where specified; index returns Maybe of an int index, none() when absent |
| `replaceRange`, `append`, `insert`, `deleteAt` | Explicit mutation, same target descriptor returned |
| `splice(target; begin; end; values)` | Same interval mutation, fresh removed-elements snapshot preserving the target's actual element type and storage profile |

Exact bounds, defaults, empty cases, and failure names are defined in the [sequence specification](#sequences-details) and the [implementation contract](patterns/LMX_Fn_Receivers/SEQUENCES_IMPLEMENTATION.md). Public names are direct kernel receivers. There is no `toArray` conversion family and no separate user collection kind.

Callbacks receive one explicit actual for map/filter/query and two for fold/scan/zipWith. This counts supplied actuals, not the total arity of a permissible target: ordinary optional inputs, full types, private/required rules, and declared exits remain applicable. Nested Structures and returned callables are single values and are not implicitly called. Omission is not a zero, nil, empty array, or uninit record. Effects occur left to right in one Message; callbacks must not alter the traversed sequence's membership or length. Failure stops further callbacks and does not return a partial success.

### Mutation and graph editing

`replaceRange(target; begin; end; values)` replaces the half-open interval `[begin,end)` with the immediate pre-write insertion values and returns the **same target descriptor**. The new `splice(target; begin; end; values)` performs that same mutation but returns a **fresh outer container of the removed pre-write elements**. These are separate ordinary receiver names. See the [naming contract differences](NAMING_2026-11-22.md#1-sequences-and-mutation).

Both entrances first validate bounds, resulting size, source kind, and all dense-target admissions. Overlapping insertion values and the removed interval needed by `splice` are stabilized before the first write or resize that could change them. Thus appending A to itself duplicates its original elements once. Commit runs no user converter or callback. Range/type errors leave target unchanged; already evaluated actual effects and resource failures do not acquire general transactional rollback.

The removed result preserves the actual element requirement and storage profile of target. Dense T[] yields a new dense T[]; Structure/@[] yields a new @[] holding the original record references. This is a shallow snapshot: referenced nodes retain identity and actual lexical parents. Replacing an outer result slot does not replace a target slot; mutation of a shared referenced object remains shared. With `begin == end`, the result is an initialized empty container of that same profile. Removing the whole interval returns all original elements while leaving the original target descriptor in place. `replaceRange` need not allocate an unused removed-result snapshot.

`append`, `insert`, and `deleteAt` delegate to the same mutation algorithm and return target. `insert` accepts a sequence of inserted values; `deleteAt` takes an explicit half-open interval. Structure slots accept direct references without inheriting a removed field's former requirement. Dense slots retain their actual type. An L3 element reference retains descriptor plus index, so insertion changes the content at that position; it does not track a moved logical item. A separately retained record reference still designates that record. L2 raw addresses are not repaired after storage moves. The unrelated selection operation `compress` continues to require equal source/mask lengths.

Code is the same editable graph. These operations can inspect or edit its immediate fields without executing stored forms. Runtime edits and subsequent interpretation require neither text roundtrips nor compile/endturn. Explicit native compilation and turn-boundary installation retain their existing independent rules; writing a graph does not discover reverse dependencies or rewrite old native callers.

<a id="sequences-details"></a>
### Exact sequence contracts

`unique(items; same := 0)` preserves the first representative of each equality
class and its original order in a fresh outer container of the source's actual
storage profile. `same=0` is an explicit API policy selecting default equality;
it is not a language-wide equivalence of omission, null and uninitialized
state. A supplied comparator consumes two whole typed records, previous
representative first, candidate second, and its result is admitted by the common
predicate consumer. Source membership and length remain unchanged.

`equalFields(first; second; same := 0)` checks ordered lengths/elements.
`FxValueSame` chooses the comparator; the sole paired traversal is
`FxSequenceDifference`, with independent first/second starts and checked count.
Default scalar comparison uses the actual `=` contract. Two finite acyclic
sequences recurse through that same traversal; a scalar and a sequence differ.
Array comparison masks are not mistaken for one Boolean. Text comparison is
exact and case-sensitive, including zero characters. Physical Structure equality
does not infer field-name, model or lexical-parent equality. Cyclic or special
domain values require an explicit comparator. Type errors and callback failures
propagate rather than becoming inequality. There is no extra `sameText` loop.
The [complete equality contract](GENERIC_EQUALITY.md) includes all failure,
identity, numerical-profile and complexity guarantees.

`range(start; stop; step := 1)` uses a step/order profile and materializes its
finite result. The default exact-integer profile returns dense `int[]`. Positive
steps include values below stop, negative steps values above stop; stop is
excluded. A zero or nonprogressing step is refused with `SequenceStep`. Equal
bounds or a step directed away from stop give an empty result. Each actual is
evaluated once. The exact-integer profile computes count in `bigint`, checks
maxLength and byte extent before allocation and does not evaluate a value after
the last included element: `range(MAX_INT - 1; MAX_INT; step := 2)` has one
element without an artificial overflow. Other admitted numeric/domain profiles
define next-value construction, order, direction, length limits and the complete
element requirement. Rounded arithmetic checks actual advancement; the sign of
the written step alone is not a termination proof. The result is not a lazy
iterator or a grammatical meaning of colon.

`slice(source; begin; end)` returns a new container of the immediate elements with `begin <= i < end`. It requires `0 <= begin <= end <= length(source)`; an empty interval is allowed, including at the end of the array. A negative index is not counted from the end, and a bound out of range is refused with `ReceiverIndex`, not clipped. The result has the storage profile of the source; a step is written as `select` with `range`.

`reverse(source)` returns a new outer container in reverse physical order with the storage profile of the source. Empty and one-element sources are allowed. The source does not change; reference targets are neither copied deeply nor reparented.

`concat(parts)` takes one ordinary actual, a sequence of sequences, and joins only the immediate elements of the parts, in their order. A non-empty `parts` whose parts are all dense arrays of the same complete T gives a new dense `T[]`; every other admissible combination, mixed dense arrays and Structures included, gives a new `@[]` of the values; an empty `parts` gives an empty Structure/`@[]`. An empty dense part still carries its T and takes part in choosing the profile. No numeric conversion is made to guess a common type; a dense result of a mixed input is obtained explicitly with a typed constructor. A nested array inside a part stays one element: there is no recursive flattening. Joining physical elements matches no field names, so `concat` is not implemented through `merge`.

`compress(source; mask)` takes a source and an int truth mask of the same length: 0 excludes an element, any nonzero int includes it. The result is a stable selection with the storage profile of the source. The mask is a dense `int[]` or an ordinary sequence of integers through `@`; its values are checked by their actual type, and an array of references is not a mask because its addresses are nonzero. Length and element types are checked before the result is formed; an empty mask is valid exactly for an empty source. The separate name keeps the indices `[0 1]` apart from the mask `[0 1]`.

`any`, `all`, `index` and `count` take `items; accepts`. `accepts` receives one explicit actual, the current value, and its result is read as int zero or nonzero. `any` stops at the first true and gives int 0 or 1, and 0 for an empty input. `all` stops at the first false and gives 0 or 1, and 1 for an empty input. `index` stops at the first true and gives the existing Maybe of the zero-based index, `some(i)`, or `none()` when nothing matches or the input is empty. `count` visits every element from left to right and gives the number of true results, 0 for an empty input. After the deciding element no further callback is called, and no callback is called in advance to determine a type. There is no SearchResult, no −1 sentinel and no second wrapper around the Maybe.

| Condition | Failure |
| --- | --- |
| An invalid physical index; invalid bounds of `slice`, `replaceRange` or `splice` | `ReceiverIndex` |
| Not a complete permutation | `ReceiverPermutation` |
| Unequal lengths of numeric arrays or of a mask; rows of unequal length | `FxShape` |
| An invalid or unsupported type token | `FxTypeToken` |
| A zero `range` step | `SequenceStep` |
| A size or length that cannot be represented without overflow | `SequenceSize` |
| An element not admissible for a dense target; a mask element that is not int | `SequenceElement` |
| The `accepts` result of a new query is not int | `FxPredicate` |
| A declared failure of a user callback | `FxCallFailure`, with the original name and payload |

These are ordinary declared failures, not a new exception mechanism. Failures of direct scalar arithmetic, of the admission of a user method, system memory limits and implicit failures keep their existing channels. A new query checks the type of the `accepts` result explicitly before consuming it as int; this neither intercepts nor renames an implicit failure raised by the call of the callback or by its return. The existing `filter` keeps its ordinary admission of the result as int. "A sequence was expected" is reported by the ordinary admission of that requirement: a reference to a number is not turned into a one-element array, and a raw address is not accepted merely because it has the machine size of a pointer.

`foldl` gives the step two explicit actuals, the previous accumulator and the element, in a strictly left fold, and returns a reference `@` to the last accumulator value; for an empty input it returns the original seed without a callback. `scanl` returns the seed followed by the n later accumulators and stores references to the returned states: when a step returns the same mutable target, the history refers to that target, and no deep snapshots are made; an empty `scanl` holds the seed alone. `bind` calls `next` once per element and joins the returned sequences one level deep into a new `@[]`; a nested array stays one element. `traverse` returns the existing Maybe and stops at the first `none`; on success it holds an ordinary `@` sequence of the results. `groupBy` uses the current whole element as key when `keyOf=0`, otherwise calls the selected `keyOf` once per element; `sameKey=0` chooses the shared default equality, and keeps a stable order of groups and members; each group has the fields `key` and `items`, and `items` is an ordinary `@` sequence. A dense source does not make these nested results dense. Empty `map`, `filter`, `zip` and `bind` give an empty result of their established kind. `zip` keeps its pair form with the fields `first` and `second`; for Structure elements the fields refer to the source values, and for dense primitives a stored value is an ordinary primitive record: an address inside dense storage is never presented as the address of an independent `{type value}`.

`select`, `omit` and `reorder` accept indices through `@` as a sequence of integers: a dense `int[]` or an ordinary Structure of integers. `select` allows repeats, and the order of its result is the order of the indices. `omit` keeps the order of the remaining elements, and a repeated exclusion index removes no further element. `reorder` requires a complete permutation: the right length, valid indices and no repeats. Indices are validated completely before an observable result is built. A Structure/`@[]` source gives direct references to the selected values; a dense source gives the selected values in new typed storage. `transpose(rows)` takes a sequence of rows of equal length, each of them a sequence read through the same universal access, and returns a sequence of columns, each an ordinary `@` sequence. An empty outer `rows` gives an empty result, and n empty rows give zero columns. Rows of unequal length fail with `FxShape`; `transpose` is not an implicit reshape of a flat rectangular array. `list(values)` makes a new `@[]` of the values of any admissible sequence and is never required before `map`, `filter` or `foldl`.

`replaceRange` requires `0 <= begin <= end <= length(target)`. The new length is `oldLength - (end - begin) + length(values)`, and every quantity is checked without overflow. `values` is an ordinary sequence of any admissible kind, received through `@`. Into a Structure/`@[]` target the immediate references are written with no check against the name, type or requirement of the former slot. Into a dense target of T each inserted element must be an admissible T with no hidden user conversion, the ordinary built-in conversions applying, and the whole set is checked before the target changes; a source of another storage kind is no reason for refusal when its values are admissible. `append(target; values)` is `replaceRange` with `begin = end = length(target)` taken before the call; `insert(target; position; values)` is `replaceRange` with `begin = end = position`; `deleteAt(target; begin; end)` is `replaceRange` with empty values.

Dense arrays, reference arrays and mixed pairs of them are all admissible operands; a uniform physical type of the whole input is not required. The operation on each pair is decided by the actual types of its two values under the ordinary scalar contract. A `@[]` may hold values of different types: every reached pair must admit the operation, and an incompatible element is neither skipped nor replaced by zero. The scalar conversion rules apply unchanged, and the profile adds no automatic promotion. Division keeps the scalar result type, rounding and failures; an array introduces no float conversion. The source arrays do not change. A length mismatch is detected before the first elementwise operation, so a failure of an element operation, such as a zero divisor, never replaces it. `result := A + B` assigns the new reference to the place; it is not an elementwise write into the array held by `result` before. A compound assignment keeps its ordinary meaning, `a += b` being `a := (a + b)`, and promises no change of the former backing; when the identity of the target container matters, an explicit mutation receiver is used. The written anonymous groups in `(2; 5; 9) * (3; 4; 2)` keep the ordinary conditional opening of the right operand; the sequence profile does not make them a special pair of arrays.

An explicit actual suppresses the initializer of its input. An omitted input with its own default keeps that default, and an unused computed default is not executed for the sake of the common transport. An omitted actual is never replaced by zero, an empty Structure, null or an artificial uninit record. `private` filters implicit binding by the ordinary rule, while explicit passing stays allowed. The state of a traversal is protected from accidental binding to user names; adapters are not repaired by removing every `private` or by declaring every callback input required or private. A service format of already prepared actuals, such as the one of `attempt`, is internal and is not a required user format of a collection. A nested Structure is one actual: the transport neither applies W/E to it again nor executes it. The actual DATA/parent of the callback is kept; the items container, the internal engine and the call site do not become its lexical owner. Dynamic binding follows the actual call chain: an operation that adds an ordinary call of its own does not promise to skip that level and restore an alias to an outer caller, and there is no global snapshot of the environment. During a traversal the callback does not change the membership of the traversed sequence, its length and stored elements; other objects may change, and the change is visible to later calls. No deep snapshot of the source is taken, and the rule needs no system that tracks every write. A failure on element i stops the traversal: elements i + 1 and later are not processed, no partial result of `map`, `filter` or `scanl` is returned as a success, and the effects already made remain. Generic calls keep `FxCallFailure` with the original name and payload; an implicit or system failure is not turned into `FxCallFailure`, `none`, false, a retry or a universal Result.

The required inputs of the new receivers are received explicitly: a missing required actual is not filled from a same-named local. Their own defaults, such as `step := 1`, are kept, and the service places of the implementation are private. These rules do not change the input policy of a supplied callback.

A zero value, a null reference, an empty sequence, void, `None` and `uninit:T` remain different cases. Moving a reference to an `uninit:T` record reads no payload; reading the value, or its admission by a particular callback, is the ordinary check of that use, not a duty of every traversal.

Preserving the storage profile keeps the kind of the elements and their way of storage; it does not guess a new multidimensional shape. A linear traversal visits the immediate elements in physical order, and `length` stays the total number of elements. A new selected result has a linear description: an operation neither builds rows or a shape from one length nor rewrites external dimension descriptions, and an insertion or deletion in a flat backing does not promise to recompute an external multidimensional description.

Four ordinary actions differ: a new outer container of references does not change the source slots; `copy` or `project` creates a copied graph under one common map; an explicit write into a selected graph changes its content; an assignment to a local of an activation changes its own place and is not published into the graph. A copied method keeps its copied lexical owner, and a container does not become the parent of a method because it holds a reference to it. Separate copy operations have their own maps; one common operation uses one map. A physical write into a Structure slot adds no check against the requirement of the former content of the slot. A copy of a method whose body is unchanged has no mandatory clearing of a compatible native implementation; a later graph write neither refreshes nor clears its entry.

A char array is an array of physical char elements of exact length: an inner NUL is an ordinary element, and no terminator is added. Slicing char elements is not Unicode slicing; positions of Unicode scalar values use an explicitly selected text profile of [text patterns](#patterns).

New results follow the ordinary Message and arena rules; a reference alone does not extend the life of a finished activation. A stored primitive value never points to a finished C-stack local, and moving or returning references does not authorize a hidden deep copy of the environment to repair a lifetime. A result holding source references is an independent outer container, not a promise that every reachable object is independent; `copy` and `project` give an independent graph.

The sequence profile adds no general broadcasting of dimensions, no hidden row views, no reshape storage, no lazy pipeline, no recursive flattening and no synonyms of `foldl`, `scanl` or `each`. Multidimensional arrays, iterator/yield and the ordinary description of other algorithms by Structures remain. `each` keeps its iterator/yield/Stop rules. `compose` constructs a callable while preserving the source input policy and exact result; `pipe` applies stages to a whole typed value and returns the actual final result. `repeat` and `lazy` retain their distinct execution contracts, including lazy's cached result. [Canonical operations](GENERIC_OPERATIONS.md) distinguish construction from value application.

<a id="patterns"></a>
## 4. Patterns over typed sources

A Pattern is an ordinary callable structural requirement over
`RxPreparedSource`, a position and the current capture state. A prepared source
contains a typed sequence of units, its original view and an explicit domain
profile. `arrayView(xs)` retains a finite Array's complete typed elements.
`utf8Text` and `byteText` retain their existing decoding and byte-boundary
profiles. One cursor, capture journal and candidate ordering serves every
domain. Text in a text-pattern role remains literal text, never a regex-string
parser. Ordinary LMX structures and callables implement the mechanism without
regex bytecode or a second working graph.

| Expression | Operation | Priority |
| --- | --- | --- |
| `P times n`, `P atLeast n`, `P atMost n`, `(P optional)` | Exact, lower-bounded, upper-bounded, or 0..1 repetition | Existing multiplication priority |
| `P then Q` | Ordered adjacent sequence | Existing addition priority |
| `P \| Q` | Ordered alternative with backtracking | Existing bitwise-or priority |

Priority values come from ordinary `sys\priority`. Repetition and then groups process left to right. The word operands declare private left/right places; missing left remains absent and a postfix occurrence supplies an empty right vector. A Pattern branch is added to existing `|` only when at least one logical argument is already a Pattern. Otherwise all old numeric/array behavior and existing binding rules remain unchanged. Remaining Pattern-branch arguments must satisfy the selected Pattern or explicit literal-source role; ambiguous structural values do not select a domain by their fields. `|=` follows the common single-evaluation compound assignment rule.

The operand forms of `then` and Pattern `|` take at least two logical arguments; a left-empty form can provide more. Ordinary `then` accepts 0/1/N parts: zero yields `emptyPattern` and one returns that Pattern. `times/atLeast/atMost` take one pattern and a count; `optional` takes one pattern. Operand arity is checked after ordinary grouping, never used to consume neighboring source retroactively. For two composite groups, write `(then (P | Q) (R | S))`; there is no left argument and no accidental right-only opening. Ordinary `then(P; Q)` reaches the same composition algorithm through its declared actual-to-parts mapping.

| API group | Direct names |
| --- | --- |
| Primitive builders | `literal`, `element`, `oneOf`, `noneOf`, `within`, `satisfy` |
| Composition | `then`, `choice`, `repeated`, `atomic` |
| Captures/context | `capture`, `sameAs`, `ahead`, `notAhead`, `behind`, `notBehind`, `boundaryOf` |
| Ready patterns | `emptyPattern`, `neverPattern`, `anyElement`, `lineChar`, `lineBreak`, `asciiDigit`, `asciiLetter`, `asciiWord`, `asciiSpace`, `start`, `end`, `lineStart`, `lineEnd`, `wordBoundary` |
| Repetition values | `extendFirst`, `stopFirst`, `unbounded` |
| Source views | `arrayView`, `utf8Text`, `byteText` |
| Matching/search | `matchAt`, `wholeMatch`, `find`, `eachMatch`, `contains`, `matches`, `hasPrefix`, `hasSuffix` |
| Result access | `matchedSpan`, `matchedValue`, `captureSpans`, `lastCapture`, `captureValue`, `captureValues` |
| Profile-preserving production | `replaceFirst`, `replace`, `split` |

`then/choice` accept any suitable array through @, including Pattern[] and Structure, without converting its kind. Empty sequence succeeds with zero consumption; empty choice never succeeds. `repeated` defaults to minimum 0, maximum `unbounded`, order `extendFirst`. Bounds are nonnegative and finite maximum is at least minimum. `unbounded` is a distinct ordinary setting value, not a negative counter. `stopFirst` tries stopping before another iteration at each permitted point; this is a local order of attempts, not a promise of the globally shortest result of a composite Pattern. Existing `some`, `none`, `repeat`, `lazy`, `record`, `guard`, and `match` retain their meanings. In particular, `lazy` remains a first-success-caching nullary callable wrapper.

### Whole-source and boundary predicates

All these operations accept a Pattern or an explicit compatible literal-source role. Text is never parsed as regex syntax. Positions use the selected source profile's units and valid boundaries; an Array element remains whole.

| Receiver | Result | Accepted match |
| --- | --- | --- |
| `wholeMatch(source; pattern)` | Maybe of Match | Begins at 0 and ends at source end |
| `matches(source; pattern)` | int 1/0 | The same whole-source condition |
| `hasPrefix(source; pattern)` | int 1/0 | Begins at 0; may end before source end |
| `hasSuffix(source; pattern)` | int 1/0 | Begins at any valid position and ends at source end |
| `contains(source; pattern)` | int 1/0 | May begin and end anywhere |

`hasSuffix` considers candidates at every relevant valid start, including overlapping starts and later alternatives at the same start. It cannot be defined as checking the last nonoverlapping `find`/`eachMatch` result. For source `ab`, pattern `literal("a") | "ab"` succeeds as a suffix: rejection of the earlier incomplete candidate must allow the later complete candidate. For `ababa` and literal `aba`, the candidate starting at 2 succeeds even though a nonoverlapping enumeration may have selected the match at 0. This does not undo a Pattern's explicit `atomic` restriction.

An empty Pattern is a valid prefix at 0 and suffix at the end; the same boundary rules apply to an empty source. `wholeMatch`/`matches` still require complete coverage. Anchors and lookaround see the original whole-source context: suffix testing does not reverse text or match a sliced substitute. A matching error propagates as an error, never false. Existing predicate termination and effect requirements remain unchanged.

### Candidate ordering, captures, and zero progress

Sequence explores continuation after each earlier candidate, backtracking when needed. `matchAt` selects the first candidate at its start; `wholeMatch` may reject an earlier incomplete candidate and accept a later complete one. `atomic(P)` retains only the first local success of P, without suppressing alternatives outside P.

Repeating an empty match can fulfill the finite minimum, but further zero-progress extension stops. Each capture belongs to its successful branch; failed attempts discard their capture changes. Repeated names keep history. Missing capture and present zero-length capture differ. `sameAs` compares the preceding captured range with the current range through `FxSequenceDifference` using both starts; its behavior is the explicitly extended, not purely regular, profile. Lookaround restores both outer cursor and capture journal; a matching error is never interpreted as negative-lookaround success.

`eachMatch` distinguishes a zero-length candidate from a nonempty candidate at the same start and does not skip the latter. It advances through valid source-unit positions and terminates, including at end of input. `emptyPattern` on `ab` yields positions 0, 1, 2; replacement with `-` yields `-a-b-`; splitting yields four parts including the two empty ends. Each returned Match keeps its own stable ranges and capture history. Replacement callbacks run once per selected match, and inserted units are not searched again. `replace` returns a fresh value assembled by the source profile without mutating source; `replaceFirst` keeps its one-match limit. Text retains its encoding and Array output retains the documented element/result requirement. These operations are independent of interval mutations `replaceRange` and `splice`.

`matchedSpan` returns a Span retaining its source view and `[begin,end)`.
`matchedValue` materializes the selected fragment through that source's profile:
text yields text, an Array view yields the corresponding Array. `captureSpans`
and `captureValues` preserve capture history; `lastCapture` and `captureValue`
return Maybe and distinguish absence from a present empty capture. The view and
prepared-source references retain identity and lifetime; no pointer into movable
backing is published. Materialization copies the outer selected fragment;
source-backed ranges themselves do not promise a snapshot.

### Source profiles, effects, and lifetime

Search takes an explicitly admitted source view. `arrayView` exposes whole typed elements without converting dense storage to reference arrays. The following text-specific rules apply to TextView. `utf8Text` counts Unicode scalar values, not bytes or grapheme clusters, and rejects malformed UTF-8 under the specified validation policy. `byteText` counts bytes and validates its substrate through the actual char layout. No locale, normalization, or case folding is implicit. ASCII classes are fixed; `lineBreak` treats CRLF as one logical separator and does not also match its LF independently.

Predicate callbacks used during candidate exploration must terminate and have no externally visible writes on which backtracking relies. The matcher modifies only its own attempt state. Builder arguments are evaluated once at construction, even for a subsequent repetition count of zero; matching is deferred. Replacement effects occur after selecting a match. Declared/system errors remain errors, not mismatch, false, None, or retry.

The public TextView retains the original source descriptor and explicit profile, not a cached units/offset index. Each public search, replacement or split operation prepares current units and offsets once; an `eachMatch` iterator retains that prepared context through suspension and completion. `Match.source` and `Span.source` preserve the original TextView identity, while their private prepared context retains the index for the operation that produced them. New operations never overwrite an earlier result's prepared index.

The source must remain alive and unchanged during an operation, suspended iteration, and access to source-backed results. After completing those uses, the caller may mutate the source and reuse the same TextView in a new operation. That operation reads the current bytes, rebuilds scalar boundaries and validates the current encoding. This does not add a lifetime-wide immutability requirement, a source snapshot, or mutation detection during an active operation.

<a id="patterns-details"></a>
### Exact pattern contracts

`Pattern`, `RxPreparedSource`, `ArrayView`, `TextView`, `Match` and `Span` are ordinary structural requirements and values. They register no pattern-specific physical type codes, no additional `Lmx` fields, no new pointer category and no instruction language; the arrays and typed references they use get their codes from the common type mechanism. A Pattern is an ordinary callable Structure with a real DATA/parent. Applying it to an input, a position and the current state of captures gives an ordered sequence of possible continuations; a continuation holds the new position and the capture journal of its path. This describes the observable contract: an implementation may enumerate the continuations with an ordinary iterator, keep explicit continuations or use prepared native code. Builders construct ready Pattern values: they match nothing, read no future input and never call the body of a supplied Pattern. A Pattern can be stored, passed, returned and assembled from run-time values; ordinary call and admission rules apply, and no statically fixed arity of the whole Pattern is required. A string in a Pattern position is accepted by the consumer's contract as a literal sequence, and an empty string is equivalent to `emptyPattern`; this is a decision of the consumer, not a P0 transformation or a regex grammar inside the string. A number alone means no character, range or repetition count: its meaning is set by the particular parameter of a receiver. A ready name such as `anyElement` is read as a value; it is not an implicit call without arguments. A `Match` holds at least `source`, `begin`, `end` and `captures`; `source` keeps the original view and its prepared source/profile with the rule for interpreting positions.

The five word operands use `PASS_ARGS_AS_IS = 0`. Their logical argument list is the written left argument, if any, followed by the elements of `right`; this is an internal rule of the method, and the ABI does not change. `left` is neither moved into `right` nor duplicated, and a string or an array stays one argument:

| Form | `left` | `right` | Logical list |
| --- | --- | --- | --- |
| `P then Q R` | P | Q, R | P, Q, R |
| `(then P Q R)` | absent | P, Q, R | P, Q, R |
| `P times 3` | P | 3 | P, 3 |
| `(times P 3)` | absent | P, 3 | P, 3 |
| `(P optional)` | P | present empty array | P |
| `(optional P)` | absent | P | P |

The prefix form `(| P Q R)` lists branches in the written order under the same extended contract of `|`. An empty or one-element sequence of parts is written with `then` or `choice`. `P optional Q` has an extra argument; the sequence is written `(P optional) then Q`. Under the common opening rule, `(x y) op (a b)` gives the whole `(x y)` as left and `a`, `b` as right, while `(x y) op ((a b))` gives one `(a b)` as right. `then(patterns := S)` passes S whole through the named actual, without ordinary W/E selection. Ordinary and operand forms retain their declared argument mapping and share one operation: `atomic(pattern := P)` receives one Pattern through its receiver representation, while its operand representation preserves the same whole Pattern role. References to methods and Patterns are not called by themselves. A complex count is grouped: `P times (n + 1)`.

`|` gets one new meaning, the ordered alternative of Patterns, used alike by `asciiLetter | asciiDigit` and `literal("cat") | "dog"`. Character classes are ordinary one-character Patterns; there is no separate branch that unites classes, removes coinciding paths or changes the error rules. When at least one logical argument of a `|` is a ready Pattern, every other one must be a Pattern or text accepted literally; an arbitrary Structure or a number does not become a Pattern. When there is no Pattern, the former contract of `|` holds, and an outer `wholeMatch` does not change the meaning of an operation already evaluated. An alternative of texts alone is written `literal("a") | "b"` or `choice(patterns := ("a" "b"))`. An LMX string is an array of type `char[]`, so `"a" then "b"` and `"a" times 3` have their meaning at once, without an initial Pattern marker and without touching `+` or `*`. Arithmetic `+`, `*` and the operations `&`, `-`, `~` get no Pattern meaning; there are no `or`, `and` or `xor` words. Sequence is `then`, look-ahead and look-behind have their explicit receivers, and a more complex set of characters is given by `satisfy` with an ordinary predicate. Logical `&&`, `||`, `!` and bitwise `&`, `^`, `~` keep their meanings.

`literal(value)` builds a Pattern for a block of source units. For a text
profile it decodes the retained text; for an Array profile it compares whole
typed elements. `element(value)` matches one complete value, including a nested
Array or a reference. Capturing the constructor argument happens once.
Domain-dependent literal compatibility is checked when the source is prepared
for matching; an explicitly typed text entry can preserve early char[] admission
without a separate matching algorithm. Empty literal means successful zero
consumption, not None.

`oneOf(values)` and `noneOf(values)` use the common `FxKeyIndex` search and
`FxValueSame` equality after domain preparation. Their order and duplicate
members do not introduce alternative captures. Empty membership sets give
`neverPattern` and `anyElement`. Each successful class consumes one unit.
`within(first; last)` uses an explicitly selected ordered-value profile;
inclusive bounds and reversed-bound failure remain specified. The text profile
admits one decoded unit per bound and preserves the old numeric character
order. This contract is distinct from the numeric sequence constructor `range`.

`satisfy(predicate)` and `boundaryOf(predicate)` validate the real callable
signature at construction, without executing it: one admitted input and an
`int` result. This validation occurs even before an empty source is matched.
Each reached callback receives the actual whole typed element; the shared
predicate consumer checks its result. Incompatibility and callback failures
remain errors, not mismatch. The supplied predicate is pure and terminating
under the matching contract.

ASCII classes remain a text profile: `asciiDigit` is U+0030..U+0039,
`asciiLetter` is A..Z/a..z, `asciiWord` also includes digits and underscore,
and `asciiSpace` comprises SPACE, TAB, LF, CR, FF and VT. There is no locale
dependence. `anyElement` consumes one unit in any admitted source; `lineChar`,
`lineBreak` and line/word anchors retain their explicit text profile. CRLF is
one logical separator of two text units, with no independent match from its LF.
These domain rules do not create a second Pattern engine.

`then(patterns := S)` and `choice(patterns := S)` take a ready sequence S through the universal `@`; the kind of the array and the access to its immediate elements follow the actual value and its existing type. Each part is admitted as an existing Pattern or an explicitly selected literal-source role. A number alone does not become a Pattern by physical shape; `element` expresses one value explicitly. A nested Pattern stays one part; there is no recursive opening. One element keeps its behavior. An ordinary Structure is accepted like `@[]`: the category or the way of declaring a container is no reason for refusal. Passing the same Structure through an initialized `[]` or `@` variable keeps the identity of the container, the references to its parts and their ordinary parent links; the requirements of the parts are checked as before. The operands are convenient forms of `repeated`: `times n` sets both bounds to n, `atLeast n` sets the minimum n, `atMost n` the range 0 to n, and `optional` the range 0 to 1; all of them use `extendFirst`. `atomic(pattern := P atLeast 0)` gives a repetition that does not give already chosen text back to a later part.

`start` and `end` test the exact bounds of the whole input; a final line break is no exception for `end`. `lineStart` succeeds at the start of the input and right after a complete `lineBreak`; `lineEnd` succeeds at the end of the input and before the start of a complete `lineBreak`. Line anchors do not succeed between CR and LF. An empty line and the position after a final separator have both ordinary bounds. `wordBoundary` succeeds where the membership of the neighbouring units in `asciiWord` differs; outside the input counts as "not a word". It is a technical ASCII boundary, not a definition of a natural-language word. Another boundary is given by `boundaryOf(predicate := F)`: a pure terminating test of one unit sets membership. The receiver compares the results on the two sides of the position, takes the result outside the input as false without calling F, and does not try to prove by analysis that an arbitrary Pattern has one character.

At one start position every Pattern sets an order of candidates. `P | Q` considers the candidates of P before those of Q. `P then Q` considers, for the current candidate of P, the fitting continuations of Q; when they are exhausted, it returns for the next candidate of P. The order is kept under nesting. `extendFirst` tries one more iteration before stopping at each permitted point; `stopFirst` tries stopping before one more iteration. Stopping is forbidden before the minimum is reached, and continuing is forbidden at the maximum; inside the body its own order of alternatives is kept. This is a local order of search, not a global sorting by length or by the number of iterations: the alternatives `literal("aa") | "a"` may give one iteration `aa` before two iterations `a`, and neither the start position nor the order of the written alternatives is rearranged for a longer match. `emptyPattern times 3` succeeds, and `emptyPattern atLeast 0` creates no infinite chain: with `extendFirst` it makes one empty iteration, and with `stopFirst` it first offers zero iterations. When the body has other variants, backtracking keeps the possibility of trying them, and captures reflect exactly the chosen number of executed iterations. No rollback of the external graph follows from this: only the attempt's own data, the position and the capture journal, are discarded. The ordinary `retry` is not redefined and does not become a transaction.

`capture(name; pattern)` keeps the start position, runs `pattern` and adds its successful range to the history of the name. The name is an ordinary string compared by content; there is no global registry of captures. The history holds all completed captures of the successful path, repetitions included. Several occurrences of one explicit name add elements to one history, in the order of completion: an inner capture of the same name completes before the outer one. `sameAs(name)` consumes a range equal to the last completed capture of that name on the current path, using the shared two-start comparator in the selected source units. With no such capture it is an ordinary mismatch, and a later capture to the right does not count as already obtained. Captures neither write into the locals of the caller nor use them as a fallback source. `ahead(pattern := P)` tests that P has a result from the current start. `behind(pattern := P)` tests that P has a result ending exactly at the current position; its possible starts lie between 0 and that position, and no statically known width is required, although an optimization of fixed ranges is allowed. The negative forms succeed when there is no such result; the outer position does not change. Lookaround is a pure test: its inner captures are not published outward, while earlier captures can be read through `sameAs`. An error inside a test remains an error and never becomes a success of the negative form. Full compatibility with the capture behavior of Perl is not claimed.

`find` tries start positions from 0 to the length inclusive, selecting the least successful start and, within it, the first admissible candidate. `contains` tests the presence of a `find` result and `matches` the presence of a `wholeMatch` result; neither materializes capture text to obtain the Boolean. After a nonempty result `[s,e)`, `eachMatch` searches anew from e. After an empty result `[s,s)` it first tests the same start again, excluding every zero-length candidate: a nonempty candidate there is emitted, otherwise the start advances by one unit. At the end of the input the search completes after the last empty result. `eachMatch` need not emit every zero-length variant of one start again. The capture history of each emitted match starts anew. The iterator uses the ordinary `yield` and completion by `throw: Stop`; another declared exit remains an error. `replaceFirst` uses the first result of `find`, and `replace` the sequence of `eachMatch`; both return a new value assembled by the selected source profile and do not change the source. With no match the result equals the source by value; identity of the address is not promised. When a replacement callback fails, no partial result is returned, and the external effects of callbacks already made are not rolled back. The copying cursor of source fragments and the position of the next search are different values, so advancing after an empty match loses no source element between insertions. `split` uses the same order of non-overlapping separators. It produces the source-profile values between their intervals, excludes the separators and keeps empty fields, the outer ones included; captures of a separator are not added to the result, and the parts are fresh outer arrays admitted by the source profile. With no separator the result is one element, the whole input; an empty input with no separator gives one empty element. An empty input with `emptyPattern` has one empty separator and gives two outer empty fields. There are no implicit modes that remove outer empty fields, insert captures, search with overlap or limit the number of replacements.

`utf8Text(source)` makes an ordinary view of valid UTF-8. Its units and all public positions are Unicode scalar values, not UTF-16 code units and not graphemes; CRLF takes two units. The source stays the original `char[]` array of exact length: no terminating NUL is added, and an inner U+0000 is an ordinary character. `byteText(source)` reads every element as a byte with the value 0 to 255, whatever the signedness of C `char`; the byte profile requires an eight-bit byte substrate, and another machine profile does not silently get another range of values. Positions are counted in bytes. Text literals in a Pattern are interpreted in the same selected profile; ASCII examples are the same in both. Invalid UTF-8, surrogate encodings and invalid sequences included, fails with `PatternEncoding`; the decoder never inserts U+FFFD. Future Unicode properties require an explicitly supplied version of their tables and a described profile, and a change of those tables must not silently change the meaning of an already prepared Pattern. A builder keeps no temporary service references `left`/`right` to records of a finished activation. Numeric parameters are kept by value; references to Patterns, texts, capture names and sequences of parts are kept in the builder's own ordinary DATA with an admissible lifetime. Referenced dependencies stay alive and unchanged until the applications of the Pattern and the accesses to results that hold them complete; independent copies are made explicitly by the caller.

| Situation | Outcome |
| --- | --- |
| The Pattern does not fit, a missing `sameAs` capture included | No result or candidate |
| A successful empty match | A present result with equal bounds |
| A negative repetition count, a wrong arity, a reversed range | `PatternArgument` |
| Invalid encoding | `PatternEncoding` |
| A position outside 0 to length | `PatternPosition` |
| An incompatible callback, a wrong value in place of a Pattern | The ordinary LMX admission error |
| A declared exit of a callback | Ordinary propagation under its contract |
| Exhaustion of an applicable explicit resource limit | A separate limit error, never "not found" |

`PatternArgument`, `PatternEncoding` and `PatternPosition` are ordinary declared failures; no new exception channel is needed. Suppressing errors inside `notAhead` and `notBehind` is forbidden.

The main interface uses ready Pattern values and `PASS_ARGS_AS_IS = 0`. A separate consumer of the source Expression may use `PASS_ARGS_AS_IS = 1`, but that is its own contract with an explicitly set moment of evaluation and capture of context; it does not replace the mode of `|` or of the word operands, and this dictionary needs no such consumer. No general guarantee of linear time is claimed for arbitrary extensions. Recursive rules, the transformation of captures into arbitrary values during backtracking, conditions on a capture and effectful predicates are not part of this version; they may become ordinary callable or receiver extensions with exact contracts, and the presence of the general `sys\eval` does not define those contracts automatically.

<a id="adapters"></a>
## 5. Callable adapters and exact signatures

One library publication retains receiver and operand representations under
the same canonical name. The source-form role selects the representation of
that family before ordinary overload selection. A Maybe or Result is also
physically a Structure/Array; the explicit full receiving contract, not
physical storage or declaration order, determines the semantic family.
Genuine overlaps remain ordinary ambiguity and are never resolved by executing
candidate bodies. The [common operation contract](GENERIC_OPERATIONS.md)
specifies value, TYPE, RAW and PLACE entry points, adaptive constructors,
generic Pattern sources and source-profile operations.

The uploaded semantics' [adapter contract](LMX_semantics.en.md#adapter-observations) is retained. Type identity remains ordered input requirements plus result requirement; labels, defaults, private/required policies, and declared exits are additional call behavior, not invented type components. Named `Name :: DATA` and the type-token form remain interchangeable except for the specified existing relationship between named signatures and `call`.

Adapter construction must retain the source declaration policy and a positional projection. A prepared call represents actual presence and deferred places. Generated CODE must not eagerly read every `p0…pn` before entering its engine. Omitted source inputs retain their own computed defaults and context; captured prefixes are available to defaults that depend on them. Service fields remain private. Calling a wrapper adds its documented call boundary; there is no promise of a hidden alias through every intervening frame.

`once` hits do not force unused omitted defaults. Passive trace events can describe present/deferred states without evaluating them. `guard/contract` read only the places their predicate/body needs. Memoization documents which accepted values its key observes, distinguishes omission from zero/nil, and does not cache failures. `uncurry` inspects the actual reached stage and performs exactly the number of calls specified by the flat contract, without fabricating intermediate `Ti -> @` signatures or calling a final callable result.

The LMX implementation keeps adapter algorithms in LMX and isolates access to the kernel's existing call-preparation phases. These bridges do not create a persistent environment, a new VM, or automatic native compilation. See [adapter implementation](patterns/LMX_Fn_Receivers/GENERIC_IMPLEMENTATION.md), [kernel boundaries](patterns/LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md), and [acceptance](patterns/LMX_Fn_Receivers/tests/ACCEPTANCE.md).

<a id="acceptance"></a>
## 6. Acceptance and publication

The core-type scenarios, sequence scenarios, original pattern scenarios, and adapter A01–A20/B01–B11 requirements remain acceptance obligations for interpreter, native, and both transitions. Added cases cover the distinct `replaceRange`/`splice` results and both boundary predicates, including alternatives, overlap, empty boundaries, actual element profiles, and aliasing. They must be run against the actual kernel. This archive separately records source coverage, unresolved integration duties, and reproducible character counts. Neither a documentation link nor a matching source token is a runtime PASS.

Examples retain genuinely different algorithms from the uploaded archive; minor one-line alternatives become notes. Syntax migrations apply to retained algorithms too. A shorter candidate is eligible only when it preserves the complete scenario, fields, effects, failure behavior, and comparable library boundary. LMX usage calls direct core functions from the [common inventory](CORE_FUNCTIONS.md); control-language usage calls actual libraries or native facilities, not our comparison implementations. Implementation comparisons retain complete stated contracts on both sides and count shared dependencies separately. Code length is not a performance measurement.
