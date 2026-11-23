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

Postfixes apply from left to right, with no fixed maximum pointer depth other than
available resources. Type construction creates an interned type description, not
the arrays or pointees described by it.

| Requirement | Named declaration | Composition |
| --- | --- | --- |
| `int@` | `int@: p` | Reference to int. |
| `int@@` | `int@@: pp` | Reference to an int reference. |
| `int@@@` | `int@@@: ppp` | Reference depth three; deeper finite compositions follow the same rule. |
| `int@[]` | `int@[]: pointers` | Array of int references. |
| `int[]@` | `int[]@: arrayPtr` | Reference to an int array. |
| `int[][]` | `int[][]: rows` | Array whose elements satisfy the int-array requirement. |
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
suffix `T[]` constructs a type; `a[i]` indexes a value; the explicit square group
in a declaration initializer supplies elements. No rule restricting all square
groups to indexing or type construction supersedes T05–T08. Adjacent index
suffixes address a multidimensional Array, whereas `a[i]\[j]` follows a reference
to a separate inner Array; adding typed initializers changes neither rule.
