# Prefix types, declarations and square initializers

The complete type requirement is written **before the colon**. A typed reference
uses `@T: name`; an array uses `[]T: name` or the sized form `[N]T: name`.
Consecutive empty or sized square prefixes specify its logical axes. The array receiver also accepts a
square initializer without a declaration name: `[]T: [elements]`. These are
ordinary receiver Frames, preserved by P0 and interpreted by the common receiver
contract. No cast, auxiliary constructor, spelling-specific parser, or trial
execution is required.

All Array and pointer type constructors are prefixes, including in a standalone
TYPE expression with no colon or declared name. Here `type` stands for a type
description or a name in the indicated role.

- `[5]type` is the Array type with extent 5 and element type `type`.
- `type[5]` selects physical index 5 of an existing value.
- `struct\[5]type` selects occurrence 5 of the field named `type` in `struct`.

`type[n]: args` uses `type[n]` as an indexed call head. The ordinary index
selects the callable from `type`, and `args` follow its ordinary call contract.
`[n]type: args` uses a sized Array type as a declaration head. An indexed
assignment, `type[n] := value`, writes the existing selected place.

`@type` has the same spelling in both roles. In TYPE it denotes the address
type for `type`, including in a declaration head. In VALUE it takes the address
of the existing `type`. The consumer
and the written boundary select the role before execution. `@: name` retains
its universal-reference contract.

Every complete type is represented by TypeRef, an ordinary direct reference to
its canonical immutable system Structure. Type construction and typeof return
that reference, not an integer code. The normalized complete left requirement
alone determines a constructor result's type; initializer length, row boundaries,
names, and reserve never specialize it. See [type identity](ARRAY_STORAGE.en.md#array-profiles).

This chapter records the author's current positive forms and the acceptance
conditions for all source carriers. It supplements the
[grammar](LMX_grammar.en.md#paths),
[place declarations](LMX_semantics.en.md#receiver-args-only),
[worked guide](LMX_semantics_guide.en.md#receiver-arities), and
[complete type contract](CORE_SEQUENCES_REGEX.en.md#types). Runtime acceptance of
these newly collected fixtures remains **NOT_RUN** in this package.

<a id="1-eight-author-approved-forms"></a>
## 1. Eight author-approved forms

Each row is a separate example. `Model` names the existing full structural
requirement and, where used in an initializer, the existing Structure satisfying
that requirement. Repeated names in different rows are not consecutive
redeclarations in one program.

| ID | Exact source | Required interpretation |
| --- | --- | --- |
| T01 | `@Model: p` | A named, uninitialized reference with the complete Model requirement. |
| T02 | `@int: left` | A named, uninitialized reference to int. |
| T03 | `[]Model: arr` | A named, uninitialized array place whose elements satisfy Model. |
| T04 | `[]int: values` | A named, uninitialized array-of-int place. |
| T05 | `[]Model: arr [Model Model]` | One named array initialized with two references to the existing Model value. |
| T06 | `[]Model: [Model Model]` | One anonymous array with the same two element values; no variable is invented. |
| T07 | `[]int: values [1 2 3]` | One named int array initialized with three elements. |
| T08 | `[]int: [1 2 3]` | One anonymous int array initialized with three elements. |

```lmx
@Model: p
@int: left

[]Model: arr
[]int: values

[]Model: arr [Model Model]
[]Model: [Model Model]

[]int: values [1 2 3]
[]int: [1 2 3]
```

There is no separate declaration tail meaning “allocate N elements”. An explicit
size constraint belongs to the complete head, as in `[N]int: cells`, and does not
allocate elements without an initializer. Length is a property of an initialized
value and is changed by `sys\resize` under its ordinary contract and applicable
complete requirements. For example, an empty unconstrained named array is
declared with `[]int: cells []`, then resized explicitly by `sys\resize(cells; n)`.
A numeric initializer is not reinterpreted as a hidden length argument, and
resizing does not acquire an invented promise that newly exposed elements have
numeric value zero. [Sized prefixes](#sized-postfix) describe the constraints.

The complete type remains on the left in every row. In the named form the raw
NAME precedes its optional initializer. In the anonymous array form the square
group supplies the initializer directly; it is not an index applied to an
undeclared name. A same-named value elsewhere does not change these roles.

No initializer means typed absence with zero payload bytes. It does not allocate
an empty Array or manufacture a null reference. An explicitly written `[]`
initializer does create an empty Array, and an explicitly written `0` initializer
for an admitted pointer is null. The existing rules for DATA, CODE, repeated
declarations, const/immutable places and admission continue to apply.

The square constructor admits each element against the complete left requirement
and retains its actual value, reference identity and supported storage profile.
Two occurrences of `Model` do not implicitly copy its fields or construct two new
Model objects. Initializer expressions execute once in their ordinary order;
ready source records are not executed as code. Admission of an existing Array
does not retag its actual elements or invent a new storage layout.

## 2. Composed types retain their order

The leftmost prefix is outermost. Pointer depth and Array rank are limited by
available resources. Consecutive empty or sized Array prefixes describe
logical axes of one flat Array; they do not construct a tree of row objects. Type construction creates an interned type description, not
the arrays or pointees described by it.

| Requirement | Named declaration | Composition |
| --- | --- | --- |
| `@int` | `@int: p` | Reference to int. |
| `@@int` | `@@int: pp` | Reference to an int reference. |
| `@@@int` | `@@@int: ppp` | Reference depth three; deeper finite compositions follow the same rule. |
| `[]@int` | `[]@int: pointers` | Array of int references. |
| `@[]int` | `@[]int: arrayPtr` | Reference to an int array. |
| `[][]int` | `[][]int: plane` | Rank-two flat Array of int; one contiguous element store. |
| `[][][]int` | `[][][]int: arr` | Rank-three flat Array of int; all three axis sizes remain unspecified in this requirement. |
| `[][3]int` | `[][3]int: plane` | Rank-two flat int Array; unconstrained first extent and second extent 3. |
| `[2][5]int` | `[2][5]int: plane` | Rank-two flat int Array constrained to shape `[2,5]`. |
| `[2]Model` | `[2]Model: models` | Length-two Array with the complete Model element requirement. |
| `[]@[]int` | `[]@[]int: links` | Ordinary Array of references satisfying the int-array requirement; no extra container kind. |
| `[]@@int` | `[]@@int: chains` | Array of references of depth two. |
| `@[]@int` | `@[]@int: pointerArrayPtr` | Reference to an array of int references. |
| `[]@` | `[]@: refs` | The existing Structure/reference-array requirement. |
| `@[]Model` | `@[]Model: modelsPtr` | Reference to an array with the complete Model element requirement. |

The full left description is preserved, including groups. `@(Model)` and
`[](Model)` normalize the written grouped description; the group is not silently
erased as if it were necessarily identical to bare Model. Different derived
requirements are not merged merely because their machine sizes match.

An address initializer is a value expression after the declaration name:

```lmx
int: value 7
@int: p1 @value
@@int: p2 @p1
@@@int: p3 @p2
```

The prefix address operation `@value` and the prefix type constructor `@int`
therefore have different roles. Declaring a deeper reference without an initializer
does not allocate the intermediate chain shown in this initialized example.

## 3. Universal references are still ordinary value declarations

```lmx
@: model Model
@: resource Resource
```

These declarations initialize universal references from existing values. Model
and Resource are VALUE initializers here, not hidden type arguments. An audit must
retain such valid uses. The explicitly typed uninitialized form is `@Model: p`;
neither `@: p Model` nor `@: Model p` means that typed declaration. A typed
initialized form is `@Model: p Candidate`, with Candidate in the VALUE role.

Trailing type constructors and the former type-after-name or type-before-name
tails require migration. In current source, indexed heads retain their ordinary
call meaning.

## 4. Acceptance across documentation and code

| Check | Required observation |
| --- | --- |
| Positive forms T01–T08 | Every exact source above is retained in the readable acceptance material and accepted through the ordinary declaration mechanism. |
| Head and name | The complete type is in the head; a declaration NAME is consumed as written, without evaluating a same-named value. |
| Anonymous square initialization | T06 and T08 yield one Array value and declare no invented name; named and anonymous initializers have the same element admission. |
| Absence versus empty | T03/T04 remain uninitialized; an explicit empty square initializer creates an initialized empty Array. |
| Model identity | Both positions of `[Model Model]` preserve the original reference identity without deep copy or reparenting. |
| Composition | Pointer/array prefix order, complete model requirements and arbitrary supported finite depth survive normalization, copy, serialization, interpreter and native lowering. |
| Value initializers | Genuine `@: model Model` and `@: resource Resource` remain valid universal-reference initializers. |
| Source carriers | Check standalone `.lmx`/`.lm3` files, Markdown LMX fences, JSON code fields and source-generating strings; generated mirrors agree with canonical inputs. |
| Declaration, call and write | `[N]T: value`, `[N]T: args` and `[N]T := value` select declaration, call and write before effects. |

Square brackets also retain their other ordinary roles. An attached type
prefix `[]T` or `[N]T` constructs an unsized or sized axis requirement in TYPE;
`a[i]` indexes a value in VALUE/PLACE; a square initializer
supplies elements. Standalone `[items]` in VALUE position constructs an ordinary
anonymous reference Array, with the same element contract as `[]@: [items]`.
It is one VALUE even when empty or singleton. A single `arr[k]` is flat access
at every rank; a complete adjacent coordinate chain uses the same flat storage.
Backslash indexes use ordinary Structure paths: when i selects struct2 and j
selects field, `struct\struct2\field` equals `struct[i]\[j]`, and
`struct\struct2\field[k]` equals `struct[i]\[j]\[k]`. There is no special
nested-container operation.


<a id="array-rank"></a>
## 5. Rank, written sizes, and flat storage

`[][][]int: arr` declares a rank-three requirement on one flat int Array.
Without an initializer it is an uninitialized place. Its three unknown extents
remain unknown unless they can be derived from the actual complete type and
length. To retain shape `[2,2,2]` in the type itself, use `[2][2][2]int`.
When the required dimensions are available, `arr[5]` and `arr[1][0][1]`
address the same place without manufacturing row or layer objects. Flat access
remains available when complete coordinates cannot be resolved.

Every Array retains the same primary Lmx with parent/length/storage. Capacity
is independent of TYPE: at capacity=length there is no secondary descriptor;
otherwise an optional capacity-only entry uses the existing arena association.
`sys\capacity` reads the association or returns length. No per-Array shape
record, hidden prefix, or additional Lmx field is introduced.

The type of a constructor result is determined only by its normalized complete
left requirement. Its canonical immutable system Structure is directly addressed
by TypeRef. Initializer dimensions, names, capacity, and storage reserve do not
specialize that type. An existing ready object admitted through a compatible
requirement is not copied or retagged. [Type identity and compatibility](ARRAY_STORAGE.en.md#array-profiles)
retain the ordinary directed admission rules.

`[arr2]` gives one ordinary anonymous Array element referring to arr2, without
copying its elements, flattening the singleton, or broadcasting it. A ready
reference in an ordinary Structure follows the same graph and path rules as
any other field. Composition such as `[]@[]int` introduces no array-of-arrays kind.

### Rectangular initializer rows and ordinary DATA fields

The following forms validate the same rectangular initializer and construct
identical flat payload under the same [][]int requirement. They do not retain
initializer-derived extents as part of that type or elsewhere:

```lmx
[][]int: [a b c; a b d; a b c]
[][]int: [[a b c] [a b d] [a b c]]
```

The temporary row shape here is `[3,3]`; the written spaces separate row regions.
The numeric forms `[1 2; 3 4; 5 6]` and `[[1 2] [3 4] [5 6]]` similarly
validate `[3,2]` and flatten to values 1 through 6. Their [][]int TypeRef still
contains two unspecified extents. To retain exact dimensions, write them in the
left requirement. Unknown shape does not prevent ordinary flat storage.

Explicit rows must be rectangular and satisfy any written sizes. Both
`[a b c; a b c d; a b c d e]` and `[[a b c] [a b c d] [a b c d e]]`
fail with lengths 3/4/5; `[[a b c] [a b d] [a b c d]]` fails with lengths
3/3/4. These are translator/interpreter diagnostics, not new LMX throw types.

Ordinary DATA declarations below are nevertheless valid and equivalent:

```lmx
Struct: [a b c] [a b d] [a b c d]
Struct: (a b c) (a b d) (a b c d)
```

They contain three ordinary anonymous Structure values of independent lengths;
no typed rank-constructor asks them to share a rectangular shape. The receiving
role and clean graph control consumption, without bracket-origin flags. A VALUE
constructor `[arr2]` still yields one whole child rather than flattening it.

A current-level semicolon splits typed initializer rows through common P0;
inner calls, literals, and nested regions retain their own separators. The
receiver validates and fills flat storage without retaining a second graph or
recovering old row boundaries later. [Complete rules](ARRAY_STORAGE.en.md#shape-inference)
distinguish construction validation from a later operation that needs shape.
Production parsing/translation/LMX execution of this addition remain **NOT_RUN**.


<a id="dynamic-postfix"></a>
## 6. Dynamic prefix counts: `[](N)T` and `@(N)T`

**DOC_SPEC_ADDITION — specification only.** These forms extend the ordinary
TYPE/prefix receiving contract. No parser, translator, runtime implementation,
source fixture, or host-model test of this addition is supplied in this patch.
Production P0/translation/execution acceptance remains **NOT_RUN**.

`[](N)T` has the same complete requirement as applying N consecutive `[]`
prefixes before T. `@(N)T` applies N consecutive `@` prefixes before T. They do not
replace the repeated spellings: `[](3)int` equals `[][][]int`, and `@(3)int`
equals `@@@int`. Each form preserves the entire left requirement.

```lmx
[](1)int: [1 2 3 4]
@(2)int: ptr_to_ptr
[](1 + 2)int: volume
@(1 + 2)int: ptr3
```

The first line constructs an Array with rank 1 and length 4. The count 1 is
neither length nor capacity. The second declares an uninitialized place with
a pointer-depth-2 requirement and allocates no chain of pointed-to objects.
The last two show ordinary expressions, not a digits-only count syntax. An
Array declaration without an initializer remains uninitialized; a rank count
does not choose its extents or allocate its elements.

N is an ordinary integer expression. The common TYPE consumer obtains it
exactly once, when that complete requirement is consumed, using its original
context. P0 preserves the complete head and count-expression region without
computing it. Reusing the resulting interned requirement does not reevaluate
its source expression. The value must be a positive finite integer supported
by available resources. Zero, negative, or noninteger counts are not admitted;
this addition defines no rank-zero or type-erasure meaning and no new exception
family. The usual type-requirement diagnostic and resource contracts apply.

The outer constructors are written first. Successive count and size
expressions are consumed once in written order:

```lmx
[](R)@(P)int: pointers
@(P)[](R)int: arrayPtr
```

The first has R Array axes with a depth-P pointer element requirement. The
second has P pointer levels to an Array with R axes. P and R are ordinary
positive integer expressions; each written occurrence is obtained once in
its consumption order. The two requirements remain distinct.

The attached count region belongs to the prefix TYPE requirement. It is not
an Array index, an initializer, a size tail, or the arguments of a subsequent
call to a constructed type value. The common P0 and receiving-role machinery
retain these boundaries; a separate parser or textual expansion into N source
prefix nodes is not introduced. The compact forms with no following type,
`@(name)` and `[](name)`, retain their ordinary compact-declaration meaning.
Their existence does not reclassify `@(N)T` or `[](N)T` after evaluating N.

Written Array rank/axis constraints belong to its canonical TypeRef description.
Unspecified axes remain unspecified except for values derivable from TYPE and
length. Capacity is independent of TYPE; at capacity=length there is no secondary
descriptor. Pointer counts add no Lmx field or user-graph field. See
[grammar](LMX_grammar.en.md#dynamic-type-postfix) and
[storage](ARRAY_STORAGE.en.md#dynamic-postfix).
The existing 14 Array-storage host checks cover their previously stated scope;
they are **not validation of these dynamic type forms**.


<a id="sized-postfix"></a>
## 7. Explicit and dynamic axis sizes: `[N]T`, `[][N]T`, and `[A][B]T`

**DOC_SPEC_ADDITION_ONLY.** This is part of the existing TYPE and
initializer receiving contracts, not a report that production implementation
has been completed. Production parser/translator/LMX runtime acceptance remains
**NOT_RUN**.

Each adjacent square type prefix contributes one axis, in outer-to-inner
order. `[]` leaves its extent unconstrained; `[E]` fixes it to the obtained
nonnegative integer result of E. The same one flat Array and primary Lmx
descriptor are used. Its TypeRef retains only the normalized left requirement;
only capacity greater than length requires an auxiliary capacity descriptor.
There is no array-of-arrays category, hidden
row allocation, or new field in Lmx or the fixed TYPE-record layout.

These four separate named declarations give the same flat values, but their
different left requirements do not all denote the same type or retained shape:

```lmx
[][3]int: var [1 2 3    4 5 6]
```

```lmx
[][]int: var [1 2 3;    4 5 6]
```

```lmx
[][]int: var [[1 2 3]  [4 5 6]]
```

```lmx
[][3]int: var [1 2 3
              4 5 6]
```

Each also has the corresponding anonymous form with `var` omitted. The fixed
last extent 3 and six flat elements determine the first extent 2. An ordinary
line break inside the bounded initializer is whitespace, not a shape marker;
the current-level semicolon and explicit row regions retain their established
structural meaning. A flat initializer does not require invented row nodes.
The first and fourth have type [][3]int, with shape `[2,3]` derivable from
length. The second and third have type [][]int with two unspecified sizes.
Their row boundaries validate construction but are not preserved in TYPE or
instance metadata. In particular, `[][]int` and `[](2)int` remain the same type.

The following author-provided forms are admitted under the same rule:

```lmx
int: N 3
[][N]int: [1 2 3    4 5 6]
[2][5]int: [[1 2 3 4 5] [1 2 3 4 5]]
[2][5]Struct: [[a b c d e] [e d c b a]]
[2]Struct: [a b]
[2]Struct: var [a b]
[]Struct: var [a b]
```

Here Struct denotes an existing complete model and a through e denote values
admitted by that model. `[2]Struct` is the abstract requirement “Array of Struct
elements of length 2”; the complete form `[2]Struct: [a b]` initializes an
anonymous value under that requirement. `[2]Struct: var [a b]` instead declares
the named place var. `[]Struct: var [a b]` has the same initialized length but
does not state a length constraint. These are alternative examples; repeated
var names do not mean that a program must declare each example together.

### Complete parsing and one evaluation

Every nonempty `[E]` region is parsed by common P0 with the full ordinary
expression grammar. It is not a digits-only extension or a special parser.
Arithmetic, groups, paths, calls, and conditional expressions retain their
normal contracts. For example, with N equal to 3:

```lmx
[][N + 0]int: [1 2 3 4 5 6]
[2][N]int: [[1 2 3] [4 5 6]]
```

Calls and nested indexing remain ordinary expressions too:

```lmx
[]int: row [1 2 3]
[]int: sizes [2 3]
int: axis 1
[][length(row)]int: [1 2 3 4 5 6]
[][sizes[axis]]int: [1 2 3 4 5 6]
```

Only the outer `[E]` adds a type axis. The contents E are consumed as an
ordinary expression; the nested `sizes[axis]` indexes an existing VALUE and
does not add another type axis. TYPE is not propagated indiscriminately into
all nested square regions.

The TYPE consumer obtains every written extent expression once, in written
order and in its original context, before admitting that declaration's
initializer. Full ordinary expression parsing does not imply that P0 executes
the expression. Its obtained integer is retained as part of the normal complete
requirement. Reusing the requirement does not reevaluate E or track later writes
to its variables. Negative, noninteger, unavailable, or unsupported sizes are
diagnosed through the ordinary translator/interpreter contracts, without a new
catchable exception family. Size products and offsets are checked without
wraparound into an apparently valid size.

An extent may be zero; a rank or pointer-depth count must still be positive:

| Type form | Meaning |
| --- | --- |
| `[3]int` | One axis of length 3. |
| `[][3]int` | Two axes; the second has length 3. |
| `[](3)int` | Three axes with unconstrained extents. |
| `[](1)[3]int` | Two axes, equivalent to `[][3]int`. |
| `[0]int` | One axis constrained to length zero; an initializer is still required for a ready empty value. |
| `@(3)int` | Three pointer levels, with no axis added. |

The existing left-to-right composition order continues to apply across pointers:
`@[2]int` is a reference to a length-two int Array, whereas `[2]@int` is a
length-two Array of int references. Declaring either without an initializer
does not allocate its Array, pointee, or a chain of intermediate objects.

### Admission, shape inference, and the indexing distinction

Explicit size constraints belong to the complete derived requirement. They
refine its unsized counterpart: a conforming `[2]T` satisfies `[]T`, while an
unsized `[]T` declaration alone does not prove that a particular value satisfies
`[2]T`. Admission to a sized requirement checks the actual current extent when
that fact is not already validly established. A stable type-pair cache cannot
turn one successful value-dependent check into an everlasting proof for every
value of the unsized source type. Actual length/capacity changes do not silently
create a new declared type or replace the ordinary mutation/admission contracts.

Reserve and admitted resize also retain the same **actual TypeRef**. Only the
optional capacity association changes when needed; the type description and
existing type prefix are not switched because of reserve or initializer data.
Ordinary admission of a ready Array through a compatible declaration or alias
does not copy or retag it. Its constructor's normalized requirement still
determines its type. The [complete identity and compatibility rules](ARRAY_STORAGE.en.md#array-profiles)
include equal []int types for lengths two and three, and different [2][3]int
and [3][2]int types despite equal total lengths.

The initializer validates explicit rows and written constraints. Row groups
must be rectangular, but their discovered extents do not enter the retained
type. A single unspecified size can be derived from TYPE and length by exact
division by a positive known product. Several unknown sizes, or an unknown
multiplied by zero, remain unspecified. Flat `[][]int: [1 2 3 4 5 6]`,
`[0][]int: []`, and `[][0]int: []` are therefore valid storage declarations;
they do not guess a complete shape. Missing dimensions are an error only when
a later consumer needs them. Contradictory written sizes, nonrectangular rows,
or impossible length/product are still errors. No factorization, implicit
reshape of a ready value, or inference from indentation is performed. The
[complete algorithm and positive/negative examples](ARRAY_STORAGE.en.md#shape-inference)
also cover empty Arrays and zero extents.

`[2]Struct: [a b]` and `Struct[2]:= [a b]` are different constructions. The
first example has a declaration colon and the sized TYPE head described above.
In the second, `:=` is one assignment operand, just as in `Struct[2] := [a b]`:
the existing VALUE named Struct is indexed at 2 and that place receives one
ready Array `[a b]`. The actual value must admit that index and assignment.
No Array declaration or size constraint is inferred from `:=`.

This distinction does not make every indexed head before `:` a type. An ordinary
indexed receiver/callable VALUE keeps its existing call contract. The common
head-resolution and receiving-role mechanisms determine TYPE versus VALUE;
capitalization, trial execution, and a spelling-specific rewrite do not.

Canonical storage and inference rules: [English](ARRAY_STORAGE.en.md#sized-postfix)
and [Russian](ARRAY_STORAGE.ru.md#sized-postfix). The older host-check totals
do not constitute production acceptance of these new sized-type forms.


<a id="type-descriptor"></a>
## 8. TypeRef and the canonical system Structure

Every type, including primitive int, is represented by TypeRef: an ordinary
direct address/reference to its canonical immutable system description Structure.
Type constructors `[]T`, `[N]T`, `@T`, and signature producers return TypeRef;
`typeof`/`sys\typeof` return TypeRef, and `types` yields references to descriptions.
They do not return int counters, table indices, or encoded tags. Dynamic type
construction interns equal normalized requirements instead of forcing a fresh
identity on every evaluation.

```lmx
[]int: arr [1 2 3]
@: arrayType typeof(arr)
@: description sys\descriptor(arrayType)
```

arrayType and description refer to the same canonical system Structure.
`sys\descriptor(typeof(obj))` therefore returns the description itself through
the more specific canonical system-TYPE contract. Since the description is
already a Structure, this contract takes precedence over the ordinary object
branch for that canonical object; no user field pattern or name grants that
status. Integer-code lookup and treating an arbitrary int as an address are
not compatibility aliases.

For an ordinary Array/Structure value, `sys\descriptor(obj)` still returns the
three live primary-field addresses; its zero-argument form still selects current
DATA. The TypeRef overload allocates no new box, instance shape record, or
per-query copy. A saved TypeRef remains the same immutable type description;
reserve/resize do not switch it. Replacing a variable with another typed value
is a different ordinary operation.

The Structure exposes the complete normalized type, written rank/size
constraints, element/storage contract, direct compatibility relations, and
common rules for deriving sizes or reading capacity from an actual value.
It contains no per-instance initializer shape or reserve. Description objects
have a finite bootstrapped meta-description; ordinary graph cycles support
`typeof(typeof(obj))` without infinite allocation.

The `{type value}` prefix now stores TypeRef immediately before a genuine
initialized payload. Its offset is `sizeof(TypeRef)` in bytes, not a fixed
four bytes or universally `sizeof(size_t)`. Dense elements and arbitrary native
locals do not each gain a tagged-record prefix. Uninit has no payload. The
[record ABI](L2_spec_en.md#value-record) defines alignment and address lifetime;
cross-context restoration interns descriptions and relocates references rather
than persisting raw pointer values.

Full descriptor contract: [English](ARRAY_STORAGE.en.md#type-descriptor) and
[Russian](ARRAY_STORAGE.ru.md#type-descriptor). Old integer-code/type-profile
receipts do not validate this new documentation; production acceptance is **NOT_RUN**.
