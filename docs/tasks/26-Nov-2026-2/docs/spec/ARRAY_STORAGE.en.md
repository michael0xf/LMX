# Array dimensions, storage, and square values

Revision 26 November 2026. `int[][][]: arr` describes one flat Array of int
with three logical axes. Rank and extents belong to arena metadata beside
capacity. The Lmx header, `{type value}` records, and user Structure fields
are unchanged.

<a id="rank"></a>
## 1. Repeated postfixes and an initialized value

```lmx
int[]: line
int[][]: plane
int[][][]: arr
```

N empty `[]` postfixes describe N axes of one Array. Dense int storage is
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

This shorthand changes no storage contract: rank/extents remain in the external
entry beside capacity, and pointers gain no new Lmx fields. Composition order
and the distinction from left-less compact declarations are specified in the
[complete contract](TYPE_DECLARATION_FORMS.md#dynamic-postfix).
No implementation or new tests are added; production P0/translator/runtime:
**NOT_RUN**. The previous 14 host checks in this chapter do not test these forms.

<a id="side-metadata"></a>
## 2. Metadata beside capacity

The existing arena association from descriptor identity/address to capacity
also retains rank and extents. An initialized rectangular value satisfies:

```text
metadata = arena entry selected by identity(array)
metadata.rank = number of extents
array.length = product(metadata.extents)
metadata.capacity >= array.length
```

These are internal operations, not new LMX functions or fields. Rank is
positive and finite; extents are nonnegative integers. A zero extent retains
rank and the remaining extents while making length zero. Size and offset
arithmetic must not wrap into an apparently valid smaller value.

Length counts all elements; capacity is the reserve measured in elements.
Element size and physical stride follow actual storage. Row-major axis strides
follow from extents; any cached strides in the same service entry must agree.
Host-model names shape, rank, extents, strides, and size are not LMX fields.

Lmx still contains only parent, length, and storage. Do not extend even an
internal Lmx header, a hidden prefix, or a TYPE record with rank.
`sys\descriptor` still returns the three genuine header-field addresses;
`sys\capacity` still returns capacity. `arr\rank` gains no service meaning.

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

`T[]`, `arr[i]`, `arr[:]`, `[items]`, and `.(expression)op` remain distinct
by structural position and receiving role. No size tail on a declaration is
introduced. The rank-three examples may receive a ready Array with complete
extents `[2,2,2]`.

### 4.1. Rows of a typed multidimensional initializer

The declared rank determines how the receiver consumes already delimited
initializer regions. A `;` at the current initializer level finishes a row;
explicit row groups give the same boundaries. These forms are equivalent:

```lmx
int[][]: [a b c; a b d; a b c]
int[][]: [[a b c] [a b d] [a b c]]
```

With `a=1`, `b=2`, `c=3`, `d=4`, both give extents `[3,3]` and one flat
storage `[1,2,3,1,2,4,1,2,3]`. The numeric pair has extents `[3,2]`:

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
2. Check rectangularity of the available regions for the declared rank.
   A known mismatch is diagnosed before obtaining elements; dynamic streams
   retain their ordinary sequential admission contract.
3. Obtain each element once in source order and admit it under T. An ordinary
   Array VALUE does not implicitly become a stream. Explicit copy/merge streams
   retain the existing initialization contract.
4. Fill one flat storage and retain rank/extents beside capacity. Do not rewrite
   source text or the live graph into a different graph of row objects.

If the remaining empty axes have no complete description, length=0 does not
justify guessing their sizes. An already provided description such as `[2,0,3]`
is preserved in full.

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

<a id="mutation"></a>
## 5. One-dimensional operations remain available

Rank does not prohibit flat traversal, selection, element writes, or an
existing size-changing operation. Multidimensional operations address the
same elements through extents. No graph conversion between representations
is necessary.

A flat sequence consumer uses the original Array's actual element type,
length, and storage at any rank. Selecting that consumer profile constructs
no replacement Array, performs no reshape, and does not change the source
rank to one or retag its type. An explicitly rank-constrained user contract
retains its own admission; it is not a global restriction on flat operations.

A shape-preserving result retains consistent extents. A new flat selection
may have rank one while its source keeps its shape. The actual result
contract determines this; changing index spelling alone does not change an
existing object's rank. Whole assignment retains ordinary reference/admission
rules; elementwise assignment retains its destination identity.

Reserve changes capacity without changing length or extents. An operation
that changes length, including resize, must update the service description
under its declared contract. Stale extents whose product differs from length
are invalid. Rank alone cannot prohibit the operation, and a total element
count does not justify guessing new axes. No new public reshape API is added.
Direct L2 length writes retain the same consistency obligation.

<a id="reconstruction"></a>
## 6. Copying, restoration, and native code

Two references to one Array use the same metadata entry. Copying an Array
transfers the description to the new descriptor through the existing
source-to-copy mapping. Moving storage or changing its reserve does not
create a different language object.

Restoration may choose capacity=length but must preserve or reconstruct rank
and extents from an already retained complete description. Length=12 cannot
distinguish `[2,6]` from `[3,4]`. This is service serialization information,
not extra source-graph nodes or a second persistent graph. Attach, release,
and descriptor-memory reuse follow existing ownership rules.

Native code can use known dimensions as constants, but the live value keeps
the description required by the interpreter and later admitted operations.

<a id="depth"></a>
## 7. Depth follows logical axes of flat storage

[Operation depth](OPERATOR_DEPTH.en.md#evaluation) follows retained axes,
not the number of separately allocated C blocks. On a rank-two matrix,
depth one selects logical rows; depth two reaches coordinate elements.
For multiplication this means matrix multiplication at depth zero, vector
dot products of row pairs at depth one, and scalar products at depth two.

Logical subarrays use temporary execution information containing offset
and remaining shape. They do not allocate graph rows or build a nested
Array tree. If an ordinary element actually refers to a Structure, further
consumption follows the same value/depth rules, without a special kind.

<a id="examples"></a>
## 8. Examples and verification

[Complete short sources](examples/array_storage/README.md) cover rank-three
declarations, flat/coordinate access, ordinary Structure paths, and `[arr2]`.
The [host reference](tools/array_storage_reference.py) reuses the common
Array model and slice normalizer; it is not P0.
The [report](validation/array_storage_reference_report.json) distinguishes
host checks from production P0, translation, and LMX execution: **NOT_RUN**.
