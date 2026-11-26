# Array dimensions, storage, and square values

Revision 26 November 2026. `int[][][]: arr` describes one flat Array of int
with three logical axes. Every Array has the same primary Lmx descriptor.
Its canonical TypeRef is determined only by the normalized complete left
requirement. Capacity is independent of that type. When capacity equals length,
there is no secondary descriptor. The Lmx header and user Structure fields are
unchanged; the existing type prefix is now a direct pointer-width TypeRef.

<a id="rank"></a>
## 1. Repeated postfixes and an initialized value

```lmx
int[]: line
int[][]: plane
int[][][]: arr
```

Each consecutive `[]` or `[extent-expression]` postfix describes one axis
of one Array, in outer-to-inner order. Thus N empty `[]` postfixes describe
N axes whose sizes are not constrained by the written type. Dense int storage is
one contiguous C block, with the last coordinate varying fastest. Rows and
layers are not separately allocated graph objects. A declaration without an
initializer retains ordinary typed absence; it allocates neither an empty
Array nor guessed dimensions or zero-filled elements.

The earlier description of `int[][]` as a separate array-of-arrays kind is
superseded. `int[]@[]` remains an ordinary composition of reference and Array
requirements, without a new container kind. Structure is the ordinary `@[]`.
Its elements may refer to other ordinary Structures through normal graph
links, without dedicated storage, a recursive-container type, or dispatch.

<a id="dynamic-postfix"></a>
### 1.1. Dynamic rank and pointer-depth spelling

**DOC_SPEC_ADDITION — specification only.** `int[](N)` equals N repeated
`[]` postfixes after int; `int@(N)` equals N repeated `@` postfixes. For example:

```lmx
int[](1): [1 2 3 4]
int@(2): ptr_to_ptr
```

The first line has rank 1 and length 4; N sets neither length nor capacity.
The second declares an uninitialized depth-two pointer place without allocating
a chain of objects. `int[](3): arr` without an initializer also remains uninit.

N is an ordinary expression yielding a positive finite integer. The TYPE consumer
obtains it once when consuming the complete requirement. Zero or negative counts
neither erase a type nor introduce rank zero. Common P0 retains the N region
without evaluation; repeated postfixes and the complete left model retain their
ordinary requirement meaning.

This shorthand changes no storage contract: written rank/axis constraints
belong to the canonical type description, capacity has its independent optional
entry, and pointers gain no new Lmx fields. Composition order
and the distinction from left-less compact declarations are specified in the
[complete contract](TYPE_DECLARATION_FORMS.md#dynamic-postfix).
No implementation or new tests are added; production P0/translator/runtime:
**NOT_RUN**. The previous 14 host checks in this chapter do not test these forms.

<a id="sized-postfix"></a>
### 1.2. Sizes in square type postfixes

**DOC_SPEC_ADDITION_ONLY.** A nonempty postfix in a TYPE
requirement fixes that axis's extent. An empty postfix leaves its size
unspecified; it does not remove the axis. These four separate declarations
produce the same length 6 and ordered values `[1,2,3,4,5,6]`, but their
different left requirements do not all describe the same type:

```lmx
int[][3]: var [1 2 3    4 5 6]
```

```lmx
int[][]: var [1 2 3;    4 5 6]
```

```lmx
int[][]: var [[1 2 3]  [4 5 6]]
```

```lmx
int[][3]: var [1 2 3
              4 5 6]
```

The named form may omit `var` in every case. In the first and fourth forms,
the known last-axis size 3 partitions the six initializer elements into two
rows. The line break merely separates elements inside the already delimited
initializer: indentation does not supply an axis size or a row boundary. An
empty physical line outside a delimited region retains the ordinary block-reset
rule; this addition changes neither that rule nor the initializer's boundary.
The first and fourth declarations have type int[][3], from which shape `[2,3]`
is derivable using length. The second and third have type int[][]; their rows
are validated during construction but their two sizes remain unspecified
afterward. Equal payload is not equal complete type or persistent shape.

Both axis sizes may be explicit, and the element requirement may be a complete
structural model rather than a primitive type:

```lmx
int[2][5]: [[1 2 3 4 5] [1 2 3 4 5]]
Struct[2][5]: [[a b c d e] [e d c b a]]
```

These are rank-two Arrays of shape `[2,5]`, with ten elements. In the second
line, each of a through e must satisfy the ordinary complete Struct requirement;
the notation does not copy their fields or introduce a new container kind.

```lmx
Struct[2]: [a b]
Struct[2]: var [a b]
Struct[]: var [a b]
```

`Struct[2]` denotes the abstract requirement “Array of Struct elements, length
2”. The first complete declaration uses that requirement to initialize an
anonymous Array; the second names it var. No name is invented for the first
form. The third constructs the same two-element value with an unconstrained
axis in its declared requirement. A size is an admission constraint, not a
reserve request or a second element type. `int[2][5]: var` without an
initializer still declares typed absence and does not allocate ten elements.

The contents of every nonempty size region are parsed by the full common P0
and evaluated through its ordinary expression contract. A size is not restricted
to a numeral, identifier, or special constant-expression sublanguage:

```lmx
int: N 3
int[][N]: [1 2 3    4 5 6]
int[][N + 0]: [1 2 3    4 5 6]
```

Calls and nested VALUE indexing are parsed completely as well:

```lmx
int[]: row [1 2 3]
int[]: sizes [2 3]
int: axis 1
int[][length(row)]: [1 2 3 4 5 6]
int[][sizes[axis]]: [1 2 3 4 5 6]
```

Only the outer `[E]` contributes a type axis. E is an ordinary expression;
inside it, `sizes[axis]` indexes the existing VALUE sizes. The TYPE role is
not blindly propagated into every nested square region.

The TYPE consumer obtains each written size expression once, in postfix order
and in its original context, before admitting that declaration's initializer.
Calls, nested groups, paths, and operators retain their ordinary parsing and
effect contracts; an inner separator belongs to its own delimited region.
The expression must yield a finite nonnegative integer admitted by the existing
integer/size contract. A negative, noninteger, unavailable, or unsupported size
is diagnosed without truncation or wraparound. An axis size may be zero;
the positive count R in `T[](R)` or `T@(R)` has a different role.

The obtained sizes belong to the complete ordinary type requirement. Reuse of
that requirement does not reevaluate its source expressions or read later
changes to N. Its implementation preserves those constraints through existing
type normalization, comparison, admission, copying, and serialization; it does
not add a new TYPE-record field or a second type registry. The canonical
description is addressed directly by TypeRef. Runtime dimensions are obtained
only from that written normalized requirement and length where sufficient;
initializer boundaries are not retained as instance metadata.
The compatible forms `int[](1)[3]` and `int[][3]` both describe two axes, the
first unconstrained and the second of size 3. Pointer composition retains its
order: `int[2]@` is a reference to a length-two int Array, whereas `int@[2]`
is a length-two Array of int references.

`T[2]` refines `T[]`; an unsized declaration alone does not prove length 2.
Admission checks the actual current extent whenever that fact is value-dependent.
A stable type-pair cache must not treat one successful check on one unsized
Array as a permanent proof for all values of that type. This refinement does
not give one-dimensional and multidimensional Arrays different primary
descriptors or element-storage mechanisms. Type identity and compatibility
are described [below](#array-profiles).

The receiving role and complete syntax distinguish a type extent from an index:

```lmx
Struct[2]: [a b]
Struct[2]:= [a b]
```

The first has the declaration's `:` and a sized TYPE head. The second contains
the single assignment operand `:=`, exactly as `Struct[2] := [a b]` does. It
selects index 2 of an existing VALUE named Struct and assigns the ready Array
`[a b]` under ordinary place/admission rules. It neither declares a type nor
declares an Array of length 2. Ordinary index bounds and target compatibility
still apply. Capitalization does not decide the role, and the contents of the
initializer are not trial-executed to choose a parse.

An indexed receiver/callable VALUE before `:` retains its ordinary call contract.
The colon alone does not turn every `x[n]` head into TYPE; the common head
resolution and receiving-role rules still apply.

See [shape inference](#shape-inference) for flat streams, explicit row groups,
zero extents, and diagnostics. This addition does not claim a production P0,
translator, or LMX runtime implementation: **NOT_RUN**.

<a id="side-metadata"></a>
## 2. Primary descriptor and optional capacity storage

Every initialized Array has the same primary Lmx descriptor with `parent`,
`length`, and `storage`. It adds no shape field, hidden shape prefix, or
per-Array shape descriptor. The capacity association is independent of TYPE:

| Actual storage condition | Representation |
| --- | --- |
| `capacity == length` | No secondary descriptor or capacity entry. Capacity is obtained from length. This applies to empty, one-dimensional, and multidimensional values. |
| `capacity > length` | A compact optional entry stores capacity through the existing arena association. It contains no mandatory rank/extents data. |
| `capacity < length` | Invalid state. |

`sys\capacity(arr)` checks that association or returns length if the entry is
absent. It allocates nothing and neither creates nor changes a type. Reserve
amounts and the presence of a capacity entry never enter type identity.

Length and capacity count elements. The element size and stride follow the
ordinary full element/storage contract. Available dimensions come only from
that Array's complete type description and, where sufficient, its current
length. Written initializer row boundaries are not retained as hidden state.
Direct low-level writes to length must preserve capacity and the written type
constraints; `sys\resize` performs the coordinated ordinary operation.

`sys\descriptor` supplied an ordinary Array/Structure retains the three live
primary-field addresses. Its [TypeRef overload](#type-descriptor) has a distinct
contract. Names such as `arr\rank` or `arr\capacity` gain no special field role.

<a id="array-profiles"></a>
### 2.1. One canonical TypeRef per normalized left requirement

The type of a newly constructed Array is determined **only by its normalized
complete left requirement**. TypeRef is an ordinary address/reference to the
canonical immutable system Structure describing that type. It is not an int
counter, table index, encoded bit tag, or integer API token. The same mechanism
represents all types, including primitive int, Array, pointer, and signature
requirements. Equal resolved requirements share one canonical description.

| Declarations or type expressions | Type identity |
| --- | --- |
| `int[]: var [1 2]` and `int[]: vr2 [1 2 3]` | Same TypeRef. The initializer lengths do not specialize the type. |
| `int[][]` and `int[](2)` | Same TypeRef: two axes without specified sizes. |
| `int[][3]` and `int[](1)[3]` | Same TypeRef: two axes, with the last constrained to 3. |
| `int[2][3]` and `int[3][2]` | Different types: the ordered written constraints differ. |
| `int[5]` and `int[]` | Different complete requirements. |
| `int[N]` after N resolves to 5 and `int[5]` | Same normalized requirement and canonical TypeRef. Evaluation does not force a fresh type. |

Names, capacity, initializer lengths, row boundaries, and unused backing storage
are not interning-key parameters. The type constructor evaluates a dynamic
written size once under the ordinary contract and interns the resolved left
requirement. There is no initializer-derived actual type, reserved-capacity type
transition, or second type registry. The former compact/reserved *type-profile*
scheme is superseded; those words can describe capacity storage conditions only.

An Array created by `int[][]` retains two unspecified axes even when its
initializer used rectangular rows of lengths 3 and 3. Those boundaries validate
and flatten that construction; they do not turn its type into `int[2][3]`,
persist per-value extents, or authorize rereading the original initializer to
recover shape later. To retain the explicit shape, write the corresponding type:

```lmx
int[2][3]: var23 [[1 2 3] [4 5 6]]
int[3][2]: var32 [[1 2] [3 4] [5 6]]
```

Available shape is obtained from TYPE plus length. One unconstrained axis can
be derived by exact division by the positive product of all other known extents;
for rank one this is simply length. Multiple unspecified axes remain unspecified.
A zero known product does not determine another unknown axis. Thus `int[2][0][3]`
retains its full zero-length shape through its type, whereas `int[][0]` does not
invent its first size. Flat operations need no missing shape. An operation that
actually needs unavailable dimensions receives the ordinary translator/interpreter
diagnostic, not a new throw family or guessed factorization.

### 2.2. Compatibility, references, and `typeof`

Compatibility remains directed ordinary admission between complete descriptions.
Canonical pointer identity proves the same type, but is not the full compatibility
test. Exact size constraints refine the corresponding unsized requirements;
otherwise admissible shapes must meet every explicitly required dimension.
Value-dependent conditions use the current length and actual complete type,
not a permanent successful check on an earlier value.

A generic flat sequence consumer accepts the applicable one-dimensional and
multidimensional Arrays without changing their type or layout. Explicit rank or
size requirements still apply to consumers that declare them. An existing ready
Array admitted through a compatible declaration or alias is neither copied nor
retagged: its type remains the constructor's complete requirement. No alias or
initializer-driven specialization is introduced.

`typeof` and `sys\typeof` return TypeRef. A saved result is therefore declared
as a reference, not int:

```lmx
int[]: arr [1 2 3]
@: savedType typeof(arr)
sys\reserve(arr; 8)
@: afterReserve typeof(arr)
```

For this same arr, savedType and afterReserve refer to the same canonical int[]
description. Reserve changes no TYPE. An admitted resize likewise retains that
TypeRef and obeys any fixed constraints of the type. Replacing a variable's
value with a different typed object is a different ordinary operation. Queries
about an address or a reference place retain their own contracts; typeof does
not recursively dereference arbitrary pointers.

The direct TypeRef prefix, its pointer-width load, alignment, and zero-payload
uninit representation follow the [typed-record ABI](L2_spec_en.md#value-record).
For a genuine initialized record payload at byte address p, one pointer load
from `p - sizeof(TypeRef)` obtains the description address. This is neither the
old fixed `p - 4` nor universally `p - sizeof(size_t)`. Bare expressions and
dense Array elements do not automatically provide such tagged-record addresses.

<a id="type-descriptor"></a>
### 2.3. The system Structure itself: `sys\descriptor(typeof(obj))`

TypeRef already addresses the canonical system description. The existing
receiver's TypeRef overload returns **that same canonical immutable Structure**;
it does not look up an integer code, allocate a wrapper, or copy metadata for
each call or Array. This rule applies to primitive and dynamically derived types.

| Argument supplied to `sys\descriptor` | Result |
| --- | --- |
| A canonical system TypeRef, including `typeof(obj)` | That same system type-description Structure. |
| An ordinary Array or Structure value | The existing Structure of three live primary-field addresses: parent, length, storage. |
| No argument | The previous current-DATA selection and instance-field-address contract. |

A type description is itself a Structure, so the more specific canonical
system-TYPE contract takes precedence for that object. Canonical status is
established by the common type system, not by matching a user field layout,
name, or integer value. Arbitrary ints are not retained as type-code aliases
and are never interpreted as descriptor addresses. Invalid or unavailable TYPE
references receive the ordinary type refusal and lifetime rules.

```lmx
int[]: arr [1 2 3]
@: savedType typeof(arr)
@: instanceFields sys\descriptor(arr)
@: typeInfo sys\descriptor(savedType)
@: sameTypeInfo sys\descriptor(typeof(arr))
```

Here savedType, typeInfo, and sameTypeInfo refer to the same type Structure;
instanceFields has the ordinary three live addresses. `sys\descriptor(typeof(7))`
returns the canonical primitive int description by the same rule. Description
objects have a finite bootstrapped metatype; ordinary graph cycles can support
`typeof(typeof(obj))` without infinitely constructing more descriptions.

The returned Structure exposes the normalized complete type description:
applicable element/storage constraints, the written rank and axis constraints,
the policy for obtaining any dimension derivable from length, the common
capacity-access policy, and direct compatibility/refinement relations. Unknown
axes stay unspecified; initializer rows never appear as extra exact dimensions.
Actual instance length and reserve are not copied into a shared type description.
Capacity comes from `sys\capacity(obj)`; its type description explains the common
association-or-length policy, not whether this particular Array currently has
reserve. No new public field names or large mandatory metadata schema are required.

The canonical description is system-owned and read-only. Reserve and admitted
resize do not replace it. A saved TypeRef continues to identify that same type
under ordinary ownership/lifetime rules. The query creates no secondary Array
descriptor even for compact multidimensional values. A TYPE description's own
ordinary graph representation is not a disguised per-Array shape allocation.
Production P0/translator/runtime acceptance of this documentation change is
**NOT_RUN**; earlier integer-code/profile receipts do not validate the new ABI.

<a id="indexing"></a>
## 3. Linear access, coordinates, and ordinary paths

| Form | Meaning |
| --- | --- |
| `arr[k]` | One flat element index, also when rank is greater than one |
| `arr[i][j][k]` for rank=3 | Complete coordinates into that same flat storage |
| `arr[start:stop:step]` | A one-dimensional selection of the linear sequence |
| `plane[i][:]` | An explicit row selection through an axis chain |
| `plane[1:3][::-1]` | Selection along two retained axes, reversing the latter |
| `struct\struct2\field` | Ordinary named Structure-field path |
| `struct[i]\[j]\[k]` | The same path mechanism, selecting ordinary elements by index |

When i selects the field struct2 and j selects field, the exact correspondences are:

| Named/mixed form | Indexed form |
| --- | --- |
| `struct\struct2\field` | `struct[i]\[j]` |
| `struct\struct2\field[k]` | `struct[i]\[j]\[k]` |

The second row has one further selection k; it is not equivalent to a path
with only the first two selections.

Adjacent suffixes without a path separator refer to axes of one Array.
Backslash continues the ordinary path through the selected field value; it
does not invoke an array-of-arrays operation. Names and indexes can use the
same ordinary path rules.

For extents `[d0,d1,d2]`, coordinates map to `(i*d1+j)*d2+k`. Thus for
`[2,2,2]`, `arr[5]` and `arr[1][0][1]` address the same place. A single suffix
does not manufacture a row Array. A partial coordinate-only chain creates
no hidden view: use one flat index or the complete coordinate vector.
In a chain containing slices, a scalar removes its axis, a slice retains
its selected extent, and unmentioned remaining axes stay whole.
The needed dimensions must be available from the actual TYPE and length.
Rank alone does not supply unknown strides; former initializer rows are not
runtime evidence. Flat arr[k] remains available without those dimensions.

Source and index occurrences are obtained once in their existing order.
Retaining extents does not add per-coordinate upper-bound checks: existing
linearization and final-element validation remain authoritative. Negative
scalar Array indexing never means from-end access. Interpreted L2/L3 and
L3 retain their checks; native L2 retains its absence of automatic checks.
Use ordinary pointers for relative address offsets.

A full scalar chain first computes one row-major index and validates only
that final element: at extents `[2,3]`, `[0][3]` and `[1][0]` both give k=3.
Slice bounds have their separate selected-axis normalization contract; it
must not be applied to scalar-only chains as new per-coordinate checks.

<a id="constructors"></a>
## 4. Standalone `[items]` is one VALUE

In VALUE position, standalone squares construct an ordinary anonymous Array
of unrestricted element types, as `@[]: [items]` does. This extends the
existing declaration initializer through the same P0 machinery.

```lmx
int[]: arr2 [10 20]
@: whole [arr2]
@: empty []
@: pair [1 2]
```

Whole has one element holding the original arr2 value with its identity.
The constructor neither copies arr2's elements nor broadcasts the singleton.
Empty brackets yield one present empty Array. No first element is probed
to infer the complete result type.

Element expressions are obtained once in their normal order. Explicit
copy/merge streams follow the existing initializer contract. A ready VALUE
is not executed again as code. The constructed Array stays one value at
zero, one, or many elements; ordinary singleton expression-group transparency
does not flatten it. P0 retains the structural constructor form and original
context; the grouper consumes graph contracts without scanning brackets.

`T[]`, `T[extent]` in TYPE, `arr[i]` in VALUE/PLACE, `arr[:]`, `[items]`,
and `.(expression)op` remain distinct
by structural position and receiving role. No size tail on a declaration is
introduced. The rank-three examples may receive a ready Array with complete
extents `[2,2,2]`.

### 4.1. Rows of a typed multidimensional initializer

The declared rank and any explicit axis sizes determine how the receiver consumes already delimited
initializer regions. A `;` at the current initializer level finishes a row;
explicit row groups give the same boundaries. These forms are equivalent:

```lmx
int[][]: [a b c; a b d; a b c]
int[][]: [[a b c] [a b d] [a b c]]
```

With `a=1`, `b=2`, `c=3`, `d=4`, both validate an initializer of shape `[3,3]`
and produce flat storage `[1,2,3,1,2,4,1,2,3]`. Their retained type is int[][],
with unspecified extents; the row sizes do not enter it. The numeric pair
similarly validates rows of shape `[3,2]`:

```lmx
int[][]: [1 2; 3 4; 5 6]
int[][]: [[1 2] [3 4] [5 6]]
```

Row lengths must agree. The following forms have row lengths 3, 4, 5 and
receive a shape diagnostic from translation or the reached interpreter:

```lmx
int[][]: [a b c; a b c d; a b c d e]
int[][]: [[a b c] [a b c d] [a b c d e]]
```

The author's further negative example also fails: its row lengths are 3, 3, 4.

```lmx
int[][]: [[a b c] [a b d] [a b c d]]
```

These are not new catchable LMX exceptions. No ragged storage, row-boundary
table, or intermediate row Array objects are created. Above rank two, the
same contract consumes already delimited regions of the following axes.

Preparation uses common P0 and the ordinary initializer contract:

1. Preserve source nodes and contexts; delimiters identify complete regions.
   A `;` inside a call, literal, or nested region does not split an outer row.
   Outside an initializer it retains its ordinary short-form termination role.
2. Reconcile explicit type extents, rectangular initializer regions, and the
   element count by [the common shape procedure](#shape-inference). Check
   rectangularity of the available regions for the declared rank.
   A known mismatch is diagnosed before obtaining elements; dynamic streams
   retain their ordinary sequential admission contract.
3. Obtain each element once in source order and admit it under T. An ordinary
   Array VALUE does not implicitly become a stream. Explicit copy/merge streams
   retain the existing initialization contract.
4. Fill one flat storage with the left requirement's canonical TypeRef. Do not
   retain initializer-derived dimensions in the type or an instance-side record. Do not rewrite
   source text or the live graph into a different graph of row objects.

If empty axes remain unspecified, length=0 does not justify guessing their
sizes or rejecting otherwise valid empty storage. An explicit left type such
as int[2][0][3] preserves its complete zero-length shape.

### 4.2. Ordinary anonymous Structure fields in DATA

Rectangularity is a typed rank-constructor requirement, not a requirement on
every collection of Structures. These DATA forms are equivalent and valid:

```lmx
Struct: [a b c] [a b d] [a b c d]
Struct: (a b c) (a b d) (a b c d)
```

Each declares three ordinary anonymous Structure fields with lengths 3, 3, 4.
Structure is `@[]`; its fields may hold ordinary references without a special
array-of-arrays kind. This receiving DATA role retains three structural values
and imposes no shared rectangular shape on their individual fields.

The grouper does not choose this behavior by the original bracket characters.
In VALUE position, the ordinary constructor for `[arr2]` has been consumed and
returns one ready Array with one whole arr2 field. In DATA, the receiver accepts
the anonymous-field graph. No square-versus-round flags control unwrapping.

<a id="shape-inference"></a>
### 4.3. Initializer validation and the dimensions available afterward

One typed-initializer procedure consumes common P0 regions, not their source
spellings. It validates available row/layer boundaries but retains only the
type supplied by the left requirement. A ready Array initializer follows
ordinary reference identity/admission; checking it does not copy or reshape it.

1. Normalize the complete left requirement. Each `[]` contributes an unspecified
   extent; each `[E]` contributes its once-evaluated checked nonnegative size;
   `[](R)` contributes R unspecified axes. Pointer composition keeps its ordinary
   boundaries. Intern that complete requirement as a canonical TypeRef.
2. For a constructor with explicit rows/layers, verify the declared rank,
   rectangularity, and all written size constraints against those regions.
   Do not discard contradictory explicit boundaries merely because their total
   count could fit another shape. Their discovered dimensions are temporary
   construction facts, not new TYPE parameters or retained Array metadata.
3. Obtain each admitted element once in source order. Explicit copy/merge streams
   keep their contracts. A ready Array element does not implicitly become a
   stream. Check statically known contradictions before obtaining elements;
   dynamically obtained information is checked without rerunning producers.
4. Check the final count against the written constraints. With no unspecified
   axes, it must equal the known product. With one or more unspecified axes
   and a positive known product, the count must be exactly divisible by that
   product. A single residual size is then derivable when needed; with several
   unknowns, no factorization is chosen. If any written extent is zero, the
   count must be zero; other unknown extents remain unknown. Lack of a unique
   full shape does not itself prevent storing an otherwise admitted flat value.
5. Check integer products/offsets without wraparound and publish one flat Array
   with the left requirement's TypeRef and ordinary capacity storage. Do not
   append shape records, refine the type from rows, or later reread the original
   initializer as runtime shape. Existing effects/failure contracts remain;
   there is no new rollback guarantee.

| Separate source example | Required result |
| --- | --- |
| `int[][3]: [1 2 3 4 5 6]` | Type int[][3]; `[2,3]` is derivable from that TYPE and length 6. |
| `int[2][]: [1 2 3 4 5 6]` | Type int[2][]; `[2,3]` is derivable when required. |
| `int[2][3]: [1 2 3 4 5 6]` | Type and complete shape int[2][3]; length must be 6. |
| `int[][]: [[1 2 3] [4 5 6]]` | Rectangular rows validate and flatten; TYPE remains int[][] with unspecified extents. |
| `int[][]: [1 2 3 4 5 6]` | Valid flat storage under int[][]; two extents remain unspecified. |
| `int[][3]: [1 2 3 4 5]` | Invalid count: five is not divisible by the written width 3. |
| `int[2][3]: [[1 2] [3 4] [5 6]]` | Invalid explicit rows: their `[3,2]` form contradicts written `[2,3]`. |
| `int[][3]: []` | Type int[][3], length 0; shape `[0,3]` is derivable. |
| `int[2][0]: []` | Type int[2][0] retains the complete zero-length shape. |
| `int[0][]: []` | Valid empty value; the second extent remains unspecified. |
| `int[][0]: []` | Valid empty value; the first extent remains unspecified. |
| `int[][0]: [[] []]` | Explicit empty rows validate; their count 2 does not enter TYPE or persist as an implicit first extent. |

A shape-requiring operation uses only the actual complete TYPE and length.
For an int[][] value, even a former rectangular initializer does not prove
which pair of extents it had. Missing necessary information is diagnosed at
that consuming operation, while flat reads/writes/traversals remain available.
The same applies to compatible admission of a ready value: accepting it cannot
manufacture missing size evidence or silently retag it as a shaped type.

Explicit constraints continue to govern mutation. `int[2][3]` cannot retain its
type while an operation publishes length 7 or claims shape `[3,2]`. Reserve may
grow without changing any type or dimension. Known contradictions are translator
diagnostics; genuinely dynamic contradictions are interpreter diagnostics.
This addition supplies no new catchable shape-error family. Production parsing,
translation, and LMX execution remain **NOT_RUN**.

<a id="mutation"></a>
## 5. Flat operations and mutation remain ordinary

Rank does not prohibit flat traversal, selection, or element writes. Flat
consumers use the actual element/storage contract, length, and storage without
requiring unknown axis sizes. A multidimensional consumer uses only dimensions
available from TYPE and length, with a diagnostic if its needed information
is absent. Changing index spelling does not change the type or retain extra shape.

A newly constructed result receives the complete type selected by its declared
constructor/result contract. A new flat selection may use a one-axis requirement
without changing its source. Shape-preserving contracts must preserve the
applicable written constraints; they cannot promise hidden initializer-derived
extents. Whole assignment keeps ordinary reference/admission rules, and
in-place element assignment retains its target identity.

`sys\reserve` changes capacity while preserving length and TypeRef. An auxiliary
capacity entry exists only when the actual reserve exceeds length. Resize
respects the same complete type: a fixed `int[2][3]` cannot acquire length 7;
`int[][3]` admits lengths compatible with its known width; `int[][]` does not
invent axis sizes merely to change its flat length. At length equal to capacity
the entry is removed. Shrink retaining backing generally leaves a capacity entry.
Neither transition changes the type address. Direct low-level length writes
have the same consistency obligation. No new public reshape API is introduced.

<a id="reconstruction"></a>
## 6. Copying, restoration, and native code

References to one Array share its primary descriptor and canonical TypeRef.
Copying preserves values, complete type requirements, and ordinary reference
relationships through the existing source-to-copy mapping. It does not create
shape that the source type lacks. A copy or restoration may choose capacity equal
to length without allocating an auxiliary descriptor; reserve is not type identity.

Type-description addresses remain stable while needed. Same-context attach
preserves references and identities under the ordinary ownership/lifetime
contract. Cross-context restoration interns the complete descriptions and
relocates TypeRefs; raw addresses are not portable serialized identifiers.
Known constraints such as int[2][0][3] remain intact, while unspecified dimensions
remain unspecified. No former row boundaries are recovered from source code.

Moving storage does not change Array identity. An existing capacity association
is transferred or released with its owner, and reused descriptor memory must not
inherit it. Shared immutable type Structures obey the common type-context
lifetime rather than the lifetime of one Array. Copying does not multiply them
once per value when canonical descriptions can be shared.

Native code and caches may rely on the immutable complete type, but dimensions
derived from length and other value-dependent checks must use the current value
or a valid proof after mutations. No automatic compilation/invalidation mechanism
is added. Native modules and record readers must use the TypeRef-width ABI,
not old four-byte integer-tag layouts or old numeric-type receipts.

<a id="depth"></a>
## 7. Depth uses the dimensions available from TYPE and length

[Operation depth](OPERATOR_DEPTH.en.md#evaluation) uses logical dimensions, not
separately allocated C blocks. For an Array whose rank-two shape is available,
depth one selects logical rows and depth two reaches coordinate elements.
Multiplication then means matrix multiplication at depth zero, vector dot
products of row pairs at depth one, and scalar products at depth two.
An int[][] value whose two sizes remain unspecified does not acquire rows from
its former initializer merely because an operation requests them. A consumer
that needs unavailable dimensions reports the ordinary diagnostic; a consumer
whose contract only needs flat elements can proceed.

Logical subarrays use temporary execution information containing offset and the
available remaining shape. They do not allocate graph rows or build an Array
tree. An ordinary element that actually refers to a Structure follows the
same value/path rules, without another array-of-arrays category.

<a id="examples"></a>
## 8. Examples and verification scope

The chapter's current sized-declaration examples specify the TypeRef rule above.
The earlier [Array example collection](examples/array_storage/README.md),
[host reference](tools/array_storage_reference.py), and
[report](validation/array_storage_reference_report.json) remain prior acceptance
material. Their old totals do not validate pointer-valued types, shape omission
from unspecified left requirements, or the new optional-capacity policy.
Affected executable fixtures/host models require migration before they can be
used as acceptance of this final contract. Production P0, translation, and LMX
execution of this documentation change are **NOT_RUN**.
