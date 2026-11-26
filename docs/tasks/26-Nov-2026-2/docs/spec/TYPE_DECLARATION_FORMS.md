# Postfix type declarations and square initializers

The complete type requirement is written **before the colon**. A typed reference
uses `T@: name`; an array uses `T[]: name`. The array receiver also accepts a
square initializer without a declaration name: `T[]: [elements]`. These are
ordinary receiver Frames, preserved by P0 and interpreted by the common receiver
contract. No cast, auxiliary constructor, spelling-specific parser, or trial
execution is required.

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
| T01 | `Model@: p` | A named, uninitialized reference with the complete Model requirement. |
| T02 | `int@: left` | A named, uninitialized reference to int. |
| T03 | `Model[]: arr` | A named, uninitialized array place whose elements satisfy Model. |
| T04 | `int[]: values` | A named, uninitialized array-of-int place. |
| T05 | `Model[]: arr [Model Model]` | One named array initialized with two references to the existing Model value. |
| T06 | `Model[]: [Model Model]` | One anonymous array with the same two element values; no variable is invented. |
| T07 | `int[]: values [1 2 3]` | One named int array initialized with three elements. |
| T08 | `int[]: [1 2 3]` | One anonymous int array initialized with three elements. |

```lmx
Model@: p
int@: left

Model[]: arr
int[]: values

Model[]: arr [Model Model]
Model[]: [Model Model]

int[]: values [1 2 3]
int[]: [1 2 3]
```

There is no separate declaration tail meaning “allocate N elements”. Length is a property of an initialized value and is changed by `sys\resize`. For example, an empty named array is declared with `int[]: cells []`, then resized explicitly by `sys\resize(cells; n)` under that operation's contract. A numeric initializer is not reinterpreted as a hidden length argument, and resizing does not acquire an invented promise that newly exposed elements have numeric value zero.

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

Postfix order is preserved, with no fixed maximum pointer depth or finite Array
rank beyond available resources. Consecutive empty Array postfixes describe
logical axes of one flat Array; they do not construct a tree of row objects. Type construction creates an interned type description, not
the arrays or pointees described by it.

| Requirement | Named declaration | Composition |
| --- | --- | --- |
| `int@` | `int@: p` | Reference to int. |
| `int@@` | `int@@: pp` | Reference to an int reference. |
| `int@@@` | `int@@@: ppp` | Reference depth three; deeper finite compositions follow the same rule. |
| `int@[]` | `int@[]: pointers` | Array of int references. |
| `int[]@` | `int[]@: arrayPtr` | Reference to an int array. |
| `int[][]` | `int[][]: plane` | Rank-two flat Array of int; one contiguous element store. |
| `int[][][]` | `int[][][]: arr` | Rank-three flat Array of int; dimensions retained beside capacity. |
| `int[]@[]` | `int[]@[]: links` | Ordinary Array of references satisfying the int-array requirement; no extra container kind. |
| `int@@[]` | `int@@[]: chains` | Array of references of depth two. |
| `int@[]@` | `int@[]@: pointerArrayPtr` | Reference to an array of int references. |
| `@[]` | `@[]: refs` | The existing Structure/reference-array requirement. |
| `Model[]@` | `Model[]@: modelsPtr` | Reference to an array with the complete Model element requirement. |

The full left description is preserved, including groups. `(Model)@` and
`(Model)[]` normalize the written grouped description; the group is not silently
erased as if it were necessarily identical to bare Model. Different derived
requirements are not merged merely because their machine sizes match.

An address initializer is a value expression after the declaration name:

```lmx
int: value 7
int@: p1 @value
int@@: p2 @p1
int@@@: p3 @p2
```

The prefix address operation `@value` and the postfix type constructor `int@`
therefore have different roles. Declaring a deeper reference without an initializer
does not allocate the intermediate chain shown in this initialized example.

## 3. Universal references are still ordinary value declarations

```lmx
@: model Model
@: resource Resource
```

These declarations initialize universal references from existing values. Model
and Resource are VALUE initializers here, not hidden type arguments. An audit must
retain such valid uses. The explicitly typed uninitialized form is `Model@: p`;
neither `@: p Model` nor `@: Model p` means that typed declaration. A typed
initialized form is `Model@: p Candidate`, with Candidate in the VALUE role.

Withdrawn prefix type spellings and old type-after-name/type-before-name tails
are not compatibility aliases. Their ordinary parse, if any, must not be
mistaken for the postfix typed declaration. Historical discussions and explicit
negative fixtures may quote such bytes, but must identify their status.

## 4. Acceptance across documentation and code

| Check | Required observation |
| --- | --- |
| Positive forms T01–T08 | Every exact source above is retained in the readable acceptance material and accepted through the ordinary declaration mechanism. |
| Head and name | The complete type is in the head; a declaration NAME is consumed as written, without evaluating a same-named value. |
| Anonymous square initialization | T06 and T08 yield one Array value and declare no invented name; named and anonymous initializers have the same element admission. |
| Absence versus empty | T03/T04 remain uninitialized; an explicit empty square initializer creates an initialized empty Array. |
| Model identity | Both positions of `[Model Model]` preserve the original reference identity without deep copy or reparenting. |
| Composition | Pointer/array postfix order, complete model requirements and arbitrary supported finite depth survive normalization, copy, serialization, interpreter and native lowering. |
| Value initializers | Genuine `@: model Model` and `@: resource Resource` remain valid universal-reference initializers. |
| Source carriers | Check standalone `.lmx`/`.lm3` files, Markdown LMX fences, JSON code fields and source-generating strings; generated mirrors agree with canonical inputs. |
| Obsolete typed declarations | Active code uses postfix heads. Historical quotations and negative fixtures are classified separately, not silently accepted or globally rewritten. |

Square brackets also retain their other ordinary roles. An empty attached type
suffix `T[]` constructs a type; `a[i]` indexes a value; a square initializer
supplies elements. Standalone `[items]` in VALUE position constructs an ordinary
anonymous reference Array, with the same element contract as `@[]: [items]`.
It is one VALUE even when empty or singleton. A single `arr[k]` is flat access
at every rank; a complete adjacent coordinate chain uses the same flat storage.
Backslash indexes use ordinary Structure paths: when i selects struct2 and j
selects field, `struct\struct2\field` equals `struct[i]\[j]`, and
`struct\struct2\field[k]` equals `struct[i]\[j]\[k]`. There is no special
nested-container operation.


<a id="array-rank"></a>
## 5. Rank-three declarations and retained dimensions

`int[][][]: arr` declares a rank-three requirement on one flat int Array.
Without an initializer it is still an uninitialized place. A ready value with
extents `[2,2,2]` has length 8, and `arr[5]` addresses exactly the same place
as `arr[1][0][1]`. No row or layer Array is manufactured to perform either
access. All ordinary flat operations and the admitted multidimensional
operations remain available; rank alone is not an exclusion rule.

Rank and extents belong to the existing arena service entry beside capacity.
They are not new fields of Lmx, a TYPE record, a hidden prefix, or the user
Structure. The existing header and `sys\descriptor` retain parent/length/storage.
Shape-preserving operations retain shape; a newly built flat selection can
have rank one without changing its source. Size-changing operations must keep
length and service metadata consistent under their declared contracts.

`[arr2]` gives one ordinary anonymous Array element referring to arr2, without
copying its elements, flattening the singleton, or broadcasting it. A ready
reference in an ordinary Structure follows the same graph and path rules as
any other field. Descriptive composition such as `int[]@[]` introduces no
separate array-of-arrays kind.

Operation depth uses the retained logical axes of flat storage. A rank-two
Array supplies rows at depth one and coordinates at depth two; no separately
allocated rows are required. Details, invariants, and restoration are in
[Array storage](ARRAY_STORAGE.en.md); complete sources and explicit inputs
are in [the focused examples](examples/array_storage/README.md).

### Rectangular rows and ordinary DATA fields

Both typed initializer forms below give the same flat rank-two Array with
extents `[3,3]`. The written spaces separate explicit row groups.

```lmx
int[][]: [a b c; a b d; a b c]
int[][]: [[a b c] [a b d] [a b c]]
```

The numeric forms `[1 2; 3 4; 5 6]` and `[[1 2] [3 4] [5 6]]` give
extents `[3,2]` and flat values 1 through 6. A typed rank initializer requires
matching row shapes. Both `[a b c; a b c d; a b c d e]` and
`[[a b c] [a b c d] [a b c d e]]` fail with lengths 3/4/5; the further form
`[[a b c] [a b d] [a b c d]]` fails with lengths 3/3/4. The diagnostics come
from the translator/interpreter, not a new LMX throw family.

The DATA declarations below are nevertheless valid and equivalent:

```lmx
Struct: [a b c] [a b d] [a b c d]
Struct: (a b c) (a b d) (a b c d)
```

They contain three ordinary anonymous Structure values of independent lengths;
no typed rank-constructor asks them to share one rectangular shape. Receiving
roles determine their use. The grouper sees ordinary graph nodes and ready
values, without bracket-origin flags. A VALUE constructor `[arr2]` still yields
one whole child and is not flattened.

A current-level semicolon splits a typed initializer row through common P0;
inner calls, strings, and nested regions keep their own separators. Outside
initializers semicolon retains short-form termination. The typed receiver
consumes the delimited rows into flat storage and records extents beside
capacity; it does not rewrite the graph or allocate row Array values.
[Complete rules and algorithm](ARRAY_STORAGE.en.md#constructors).
Production P0/translator/LMX execution of these additions remains **NOT_RUN**.


<a id="dynamic-postfix"></a>
## 6. Dynamic postfix counts: `T[](N)` and `T@(N)`

**DOC_SPEC_ADDITION — specification only.** These forms extend the ordinary
TYPE/postfix receiving contract. No parser, translator, runtime implementation,
source fixture, or host-model test of this addition is supplied in this patch.
Production P0/translation/execution acceptance remains **NOT_RUN**.

`T[](N)` has the same complete requirement as applying N consecutive `[]`
postfixes to T. `T@(N)` applies N consecutive `@` postfixes to T. They do not
replace the repeated spellings: `int[](3)` equals `int[][][]`, and `int@(3)`
equals `int@@@`. Each form preserves the entire left requirement.

```lmx
int[](1): [1 2 3 4]
int@(2): ptr_to_ptr
int[](1 + 2): volume
int@(1 + 2): ptr3
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

Postfix composition retains its existing left-to-right order:

```lmx
int@(P)[](R): pointers
int[](R)@(P): arrayPtr
```

The first has R Array axes with a depth-P pointer element requirement. The
second has P pointer levels to an Array with R axes. P and R are ordinary
positive integer expressions; each written occurrence is obtained once in
its consumption order. The two requirements remain distinct.

The attached count region belongs to the postfix TYPE requirement. It is not
an Array index, an initializer, a size tail, or the arguments of a subsequent
call to a constructed type value. The common P0 and receiving-role machinery
retain these boundaries; a separate parser or textual expansion into N source
postfix nodes is not introduced. The forms without a left requirement,
`@(name)` and `[](name)`, retain their ordinary compact-declaration meaning.
Their existence does not reclassify `T@(N)` or `T[](N)` after evaluating N.

Array rank/extents remain external service metadata beside capacity; pointer
counts add no fields to Lmx, TYPE records, or the user graph. See
[grammar](LMX_grammar.en.md#dynamic-type-postfix) and
[storage](ARRAY_STORAGE.en.md#dynamic-postfix).
The existing 14 Array-storage host checks cover their previously stated scope;
they are **not validation of these dynamic type forms**.
