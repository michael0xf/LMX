# L1 Specification

1. **P0 keeps the written tree; the empty short form is admitted.** The ban on an empty short form is withdrawn: `short:` without arguments is admitted, and no expansion is needed anywhere in the parser ([the author's decision of 2026-11-10](../LMX_blog/2026-11-10.md)). P0 expands no written child container, neither a sole non-empty anonymous one nor an empty one. `A:`, `A{}` and `A()` give an empty Structure, zero immediate body fields; `A()` carries the call mark. The empty block of `A` (for example `A:` followed by `---`, or by a line `.` and `end: A`) gives an empty Structure as well: a line of a single dot sets a level, not a field. `A: {}` and `A: ()` contain one empty Structure; `B: {}; C: {}` are two adjacent forms, each body holding an empty child Structure. Adjacent short forms with zero body fields, for example `short0:`, `short1:`, `short2:; short3:` and `short4:` on their own lines, are closed by the ordinary mechanism: a neighbour on the previous level, `;`, or the end of input. Only at a function call do the translator or the interpreter fill the arguments from a sole passed Structure; that is not the parser ([the author's clarification, ibid.](../LMX_blog/2026-11-10.md)).

2. **REQUIREMENT TO REMOVE TWO-ARGUMENT RECEIVER FORMS FROM CODE.** Remove the two-argument forms of built-in data/type receivers from semantic validation, dispatch, implementation, examples, and any backward-compatible fallback. The removed forms include `int: i 5`, `@: ptr 0`, `@: ptr Model`, `@: ptr Model: Other`, and `int(v, j)`; they must not remain accepted as legacy alternatives. Put the declared or assigned place outside the receiver's operand, for example `i{ int: 5}`, `i: int: 5`, `ptr: @: 0`, and `ptr: @: Model`. Unary `int: x` and `@: ptr` remain admitted. This requirement does not ban multiple arguments of arbitrary functions, `merge`, `fn`, `print`, `if`, or message operations. P0 still parses their common structural form without receiver-name-based arity inference; the removed built-in interpretations must be rejected by their semantic consumer.

**Revision 4: 2026-11-09.** This specification follows the current [LMX grammar](LMX_grammar.en.md) and [semantics guide](LMX_semantics_guide.en.md). This revision takes precedence over outdated spellings in linked material. Revision 4 clarifies visibility of all names in both directions, accumulation of changes during traversal, and preservation of these semantics in native code. Implementation corrections and field unambiguity instead of selection by proximity ([the author's clarification of 2026-11-09](../LMX_blog/2026-11-09.md)) are collected in [bugs to fix](bugs_for_fixing.md).

L1 is the generated intermediate representation used to lower the kernel to C99. Graph-language rules belong to [L3](LMX_semantics.en.md) and [L2](L2_spec_en.md); only the C projection remains here. Current translator status and transitional hand-written L1 belong to the [implementation notes](implementation-notes.en.md).

<a id="scope"></a>
## 1. Scope

`l1trans` lowers `.lm1` to one C99 translation unit. L1 itself does not define arenas, `implements`, or graph visibility as language operations. The kernel library implements them explicitly. The self-build target is L3 with L2 insertions; L1 remains intermediate.

The revised spelling applies to LMX source and its parsed structure. Actual C99 fragments, C99 table columns, machine declarations, and library ABI names retain C syntax: their `[]`, `=`, compound assignments, and parentheses are not rewritten using LMX source rules.

<a id="translator"></a>
## 2. Translator

L1 resolves its C-like declarations and expressions. Prefix `@x` takes the address of C cell `x`, prefix `\p` loads through a pointer, and `p\field` accesses a field through a pointer. Declarative `@ⁿ:` sets the corresponding C pointer depth. The declared place name belongs outside the type receiver: `p: @: int`, `pp: @@: char`, `i: int: 5`, or `i{ int: 5}`. Removed forms passing the name and a value/requirement as two receiver operands are admitted neither as historical L1 exceptions nor as fallbacks. Unary and admitted nullary forms remain available. Foreign C symbols use explicit `c.name`.

Curly braces bound an ordinary Structure or expression and never form a call, and `name{...}` is a named description; square brackets delimit Mix with its existing rules. Parentheses immediately after an identifier form a call under the existing rules -- the main form `f(args)` and `f()`, plus the rarely needed additional layouts of the same call, `f(): args` and the block `f():` -- or an Array index; for a receiver the round form is admitted and changes nothing (`int(5)` is the same as `int: 5`), and the call rule does not apply to receivers and operators; without an identifier, `(...)` is an alternative spelling of the anonymous Structure `{...}` with the same admitted contents; the symbolic head `():` before a value describes/allocates a language Array. P0 retains every explicit non-empty container and marks a call form as a call; the non-call records of an empty Structure `f{}`, `f: {}`, and `f: ()` are indistinguishable in P0, whereas `f()` is a call ([the author's clarifications of 2026-11-09](../LMX_blog/2026-11-09.md)).

Lowering follows L3's common visibility rule: all names and prepared places of the applicable scope are available in both directions, including ordinary Structures and primitive fields, not only methods and handlers. Name resolution gives priority to the most recent preceding, already accumulated binding of that name in the relevant scope. It does not search for the “last compatible” value by type or tests: the selected value undergoes ordinary admission, and refusal does not trigger a search for an older value. If there is no preceding binding, an available future definition is not rejected merely because it occurs later in the text. Name availability does not execute a future initializer or assignment early. There is no selection by proximity among several candidates: within a code scope a name has one place prepared through `var`, and the executed writes change its value in sequence; an access to data must find its field unambiguously -- several same-named occurrences without an index are an ambiguity error, also when code is passed to itself as data ([the author's clarification of 2026-11-09](../LMX_blog/2026-11-09.md), [requirements](bugs_for_fixing.md#forward-candidates)).

<a id="lmx"></a>
## 3. Lmx in L1

The target C projection of [L2 §2](L2_spec_en.md#lmx) gives an ordinary Structure and a language Array a common `Lmx` base: both are graph objects with structural `parent` and `native`. The Array specialization holds fixed, typed elements; primitive and reference elements retain their physical access rules. The current layout, in which `Lmx` embeds `VoidArray` as its first member, is transitional rather than the inheritance rule. The exact future C field order is not yet settled; see [implementation status](implementation-notes.en.md#l2-status). Graph records gain no name, model tag, or hidden execution fields. Thread's dynamic child List remains separate.

<a id="interpretable-tree"></a>
### 3.1. Tree projection

Lowering preserves the full graph for the walker and `toLmx`; later mutation changes that same graph. It allocates no `leaf` wrapper for an already typed primitive cell and stores no names in graph records. The name table serves text output of the current graph; completed `native` does not need it for invocation. The walker may obtain the written head’s name by its address to determine its role; this is not textual variable lookup for field access. Comments play no dispatch role. The full contract is [L2 §2.1](L2_spec_en.md#interpretable-tree).

An expression is a Structure. Parsing retains its written fields, operator tokens, and child containers; `{a + b}` explicitly bounds that Structure. This adds no separate IR wrapper and establishes no fixed operator or operand positions in the machine ABI. Retaining a source Structure does not make every L1 machine variable a graph cell: the distinction in §18 remains in force.

Name discovery, place preparation, and layout determination belong to semantic preparation after P0. P0 preserves source order and containers but does not select runtime bindings. Lowering preserves L3 scope boundaries, the meaning of `node`, `independent` restrictions, and the existing order of dynamic lookup and lexical fallback. Visibility in both directions introduces no global name table, new opcode, hidden environment, or different ABI.

<a id="type-by-range"></a>
## 4. Type by range

`LmxRange` and the arena index classify physical addresses rather than reading in-band cell tags. User models do not create one C type per Structure. Ordinary and `immutable` Structures have separate pools while retaining a compatible physical record. See [L2 §3](L2_spec_en.md#type-by-range).

Language `typeof(p)` takes a pointer to an arena object and returns the type code of the pointed-to object’s arena. L1 implements this contract through the kernel library’s existing address classification, without adding an in-cell tag or a new ABI. This describes the target object, not the pointer’s static `@` type or the type of a future result from executing the pointed-to method. No numeric codes are assigned here; this spelling does not turn arbitrary C storage into an arena object.

<a id="pool"></a>
## 5. Pool

`LmxPool` and `LmxChunk` allocate fixed cells. Growth adds a chunk instead of moving live cells through `realloc`. Pool and range belong to the arena. See [L2 §4](L2_spec_en.md#pool).

During incremental self-build, the translator emits C99 access to a graph Array's `void *data` through a pointer `T *` of the actual element type selected by the L2 pool type. That pool allocates and accesses cells of that very type with suitable alignment: a cast does not redefine the effective type of existing backing. Graph-reference slots retain their separate `void **` contract, not an incompatible `T **` access. Thus one common Array Structure lowers to different typed arrays without a new language object for every `T`.

<a id="method-array"></a>
## 6. Native entry and Array

`LmxEntry` is the native-entry word; there is no second method record. A language Array lowers as a graph object with the common `Lmx` base and fixed, typed backing, not as a standalone `VoidArray` outside the graph. Dynamic List is implemented separately and does not replace fixed Structure slots or Array elements. See [L2 §5](L2_spec_en.md#method-array).

<a id="arena"></a>
## 7. Arena

`LmxArena` owns blocks, pools, and the range index. `attach` transfers ownership without moving addresses; `mark/revert` serve atomic construction. Simple mode does not perform GC. See [L2 §6](L2_spec_en.md#arena).

<a id="message"></a>
## 8. Message

`LmxMsg` lowers to exactly four fields: `running`, `success`, `handoff_ready`, and `graph`. Its identity is its record address; there is no numeric index field. Mail and family links are not added to the Message prefix. See [L2 §7](L2_spec_en.md#message).

<a id="thread"></a>
## 9. L3 Thread

`LmxThread` contains `LmxMsg` as its first member by value, so the Thread address equals the Message-prefix address. Tail access requires exact Thread classification. `Thread.children` holds one List of direct children outside the source graph. See [L2 §8](L2_spec_en.md#thread).

<a id="root-close"></a>
### 9.1. R0

R0 and the upper host scaffold use the common Thread mechanism. Launch data belong to the scaffold rather than hidden R0 graph fields. Shutdown cascades through the sole child List; a host watchdog enforces the whole subtree timeout. See [L2 §8.1](L2_spec_en.md#root-close).

<a id="mailbox"></a>
## 10. Mailbox

`LmxPost` holds `staged`, `outbox`, and FIFO `inbox`. An incoming slot contains the two components `target` and `source_arena`; the recipient owner attaches the donor before releasing the target. The inbox ring uses a separate DynamicArray with movable backing and a mailbox monitor; it is not the fixed graph slots of a Structure. See [L2 §9](L2_spec_en.md#mailbox).

<a id="own"></a>
## 11. Working state

L1 kernel code implements loads of used own fields, `dirty` marks, and publication at checkpoints. This lowers [L3 semantics](LMX_semantics.en.md#dynamic), rather than redefining the language. Graph slots remain physically stable.

Preparation of `var` determines the complete own-place set in advance: explicit `var` fields and fields added from the corresponding body by automatic completion. All these places are available from the start of the applicable scope; repeated writes of one name use its prepared place rather than allocating another field. Initial slot order, addresses, and the code→data map are preserved. Preliminary layout neither evaluates body initializers nor reorders effects or assigns zero to an uninitialized cell.

Native code must reproduce the walker's accumulation of changes at each execution point. It must not replace all references in a block with a statically selected last definition of the entire block or move a later write before an earlier read. Computed working values, `dirty` state, and publication points retain their existing contracts; a working-value change is not an immediate graph-slot write. Reads, address-taking, and publication use the actual prepared cells and proven address correspondence.

<a id="call"></a>
## 12. Call

A method is called as `f(1)` with its actual arguments. An ordinary Structure has no formal parameters: `s()` executes it without an explicitly supplied separate data Structure, while `s(data)` executes it with a separate Structure `data`. The built-in `call` operator is removed. Scalar `s(1)` does not acquire index meaning for an ordinary Structure; direct field access is written `s\(index)`. Data selection for `s()` and the execution contract remain defined by L2/L3; the new spelling introduces no different default.

Argument preparation for an already resolved invocation may expand the supplied argument Structure while preserving the P0 source tree. This is neither preliminary container stripping in L1 nor an arity restriction on ordinary functions. The source spelling change does not alter the existing native callback shape below.

The native-entry and primitive callback has one shape:

```c
int (void *owner, void **refs, size_t nargs,
     void *dest, void **out, LmxArena *arena, Lmx *code)
```

`owner` denotes active data, `code` the selected executable occurrence, and `arena` the actual call arena. A nonnull `refs[k]` points to argument value storage; null means absence. An object pointer value goes into a canonical `void *` cell; casting `T **` to `void **` is not a value conversion. The callback integer return is status, not the user's result. `dest` and `out` carry the result under the declared contract; a null reference can be a present result. Native/walker selection and the code→data map are specified in [L2 §11](L2_spec_en.md#call).

A call through a mutable cell holding a method reference uses its current bound value at the call boundary. The target is selected once before actual arguments are evaluated; changes to the cell during their evaluation do not replace the already selected target. Lowering must not retain a stale reference from an earlier use or substitute the last definition of the entire block. A direct native call is admitted only when it preserves this particular selected value and the common call contract. Ordinary admission of the selected target, address maps, and invalidation of `native` on an actual code write remain unchanged.

<a id="child"></a>
## 13. Child

A child is built in its own arena. Publication adds its reference to `Thread.children` without appending a field to the source Structure. See [L2 §12](L2_spec_en.md#child).

<a id="copy-merge"></a>
## 14. Copy and merge

`lmx_graph_copy_owned` and `lmx_merge_owned` implement a complete traversal using one source→copy map: repeated references reach one copy, and internal references and `parent` are rebased. Typed executable-operation records are copied with the body. The `native` word transfers when the selected body and the current contract of prepared places, value representations and the admission address map are preserved. This is not a forecast of future writes or aliases: an actual code write clears `native` under the shared L2 rule. L1 does not re-decide whether a source Frame is a declaration, assignment, or call. See [L2 §13](L2_spec_en.md#copy-merge).

<a id="implements"></a>
## 15. implements

The `LmxImplEntry` table stores a proven address mapping between candidate fields and the receiving description for any admitted pair of Structures. Different field order cannot be reduced to identity ordinals; reading, address-taking, and direct publication of a ready `dirty` value follow that same correspondence. At one structural level there are no multiple materialized data fields of one name. The most-recent-preceding-binding rule resolves a name and its current value within its scope; it does not make the `implements` map select the last source occurrence or create another data field. Path `s\(N)field` addresses source occurrence N of that particular `field:` head, whereas `s\(N)` without a name selects overall position N among all immediate Structure fields. Both counts start at zero. A numbered named occurrence does not admit duplicate materialized data fields or replace the `implements` address correspondence. The map holds no runtime names and does not itself keep the graph alive. See [L2 §14](L2_spec_en.md#implements).

<a id="gc"></a>
## 16. Collection

`lmx_gc_collect` implements collection from arena roots including Message, graph, mail, and `Thread.children`. Simple arena mode does not collect. See [L2 §15](L2_spec_en.md#gc).

<a id="c99"></a>
## 17. C99 output

One translator invocation emits one `.c`. Strict compilation uses `-std=c99 -Wall -Wextra -Wpedantic` and diagnostics for incompatible pointers, discarded qualifiers, and implicit declarations. `struct:`, `enum:`, `fnptr:`, and `type:` lower to C declarations. This does not alter the arena memory model.

The generator places required C declarations, function prototypes, and type definitions before the fragments that use them. This supports the common visibility of source names through existing C99 facilities; C declaration order does not become a new LMX execution order. Value initializers, calls, assignments, and other effects remain at their semantic points, and a mutable method reference is read at its corresponding call boundary. Complete-type requirements for by-value fields and forward-declaration rules remain in force. This preparation adds no global namespace, new callback, or ABI.

<a id="lowlevel-scope"></a>
## 18. Machine surface

L1 retains the target platform's C99 representation and numeric semantics. An L1 variable or C aggregate field is not automatically an Lmx graph cell; graph access goes through the kernel library. Identical spellings in L1 and L2 need not denote the same semantic operation.

<a id="lowlevel-address"></a>
## 19. Pointers and fields

In the table row containing `a(i)`, `a` is a raw C array explicitly selected through `c.array:` (§20).

| L1 | C99 |
| --- | --- |
| `p: @: int` | `int *p` |
| `pp: @@: char` | `char **pp` |
| `p: @x` | `p = &x` |
| `\p` | `*p` |
| `\p: value` | `(*p) = value` |
| `p\field` | `p->field` |
| `a(i): value` | `a[i] = value` |

The table states the current unified spelling; old two-argument declarations are not a compatibility mode. An addressable target needs valid C storage. `value\field` is a pointer step; by-value C aggregate access needs an explicit C form. `p: const: @: char` lowers to `const char *p` and protects the characters, not the pointer cell. Name `p` belongs to the enclosing description, and each nested receiver takes one operand. This is not L3 deep immutability.

A graph Structure uses the shared grammar’s paths, lowered through the kernel library:

| LMX path | Meaning |
| --- | --- |
| `struct\(index)` | All immediate Structure fields in overall order, counted from zero. |
| `struct\(index)field` | Source occurrences of that particular `field:` head, counted from zero. |
| `struct\field` | The sole occurrence of the `field:` head. |

A name after the index is included only as a written path continuation under existing boundaries; P0 neither captures a separate neighboring argument nor infers the name from a type or arity. This introduces neither numeric field reflection for arbitrary C aggregates nor physical offsets for their members.

Function `f` has the ordered parts `{return args var body}` ([the author's clarification of 2026-11-09](../LMX_blog/2026-11-09.md): return first everywhere). `f\(0)`, `f\(0)return`, and `f\return` select its `return` part, and `f\(1)` selects `args`; `f(1)` remains a method call. `sub` and `catch` have no result: their parts are `{args var body}`. The Array `@` representation remains an alternative access route:

```lmx
arr{ (): @}; arr: f; arr(0)
```

The final access also selects the `return` Structure. Direct access does not require creating this Array first. The method’s logical part order establishes no new order for service members in a C record; this spelling does not redefine ownership or copying.

<a id="lowlevel-array"></a>
## 20. Array and raw C arrays

Ordinary `():` in L1 as well as L2/L3 denotes a language Array: a graph Structure on the shared `Lmx` base with typed elements, structural `parent`, and `native`. Only the explicit `c.array:` door selects a raw contiguous C array without graph `Lmx`, arena, or hidden bounds checks. A rectangular raw array does not become an array of separately allocated rows. Automatic C-array lifetime follows C99; it is not identified with a graph Array. For example, a language Array is declared as `arr: (): int` and indexed as `arr(index)`. Lowering that form directly to a raw C array instead of a graph Array is not admitted. Actual C99 output retains its own `a[index]` indexing syntax; that is not legacy LMX source syntax.

<a id="lowlevel-abi"></a>
## 21. Casts and C ABI

`cast: {T} expression` emits an explicit C cast `(T)expression`, not an L3 checked conversion. The curly-bracket Structure bounds the source type description; the actual C cast retains its parentheses in C99 output. `c.name` is an explicit foreign C symbol. `foreign: Name` requires a type definition in an included C header; `external` and `prototype` describe export and declaration, while `include` and `predef` select explicit dependencies. Header source `name.h.lm1` emits `name.lm1.h` and permits declarations without executable bodies. A by-value field needs a complete C type; a pointer permits a forward declaration.

<a id="lowlevel-expression"></a>
## 22. Expressions and control

An expression is a Structure. For source `{a + b} * c`, P0 retains the inner Structure `{a + b}`, its fields, and its nesting; it neither strips the container nor replaces it with its result. The L1 expression profile determines operator roles, precedence, and evaluation after P0, then lowers them to C99 operations. Describing an expression does not itself execute it immediately or introduce a separate expression IR wrapper or ABI.

L1 lowers C arithmetic, logic, bitwise operations, `++/--`, and ordinary control flow. Source comparison `=` becomes `==`; `target: expression` becomes C assignment `target = expression`. There is no separate `:=` assignment operator in LMX source. Comparisons `!=`, `<=`, and `>=` retain their meanings.

| LMX compound assignment | Corresponding C99 operator |
| --- | --- |
| `+:` | `+=` |
| `-:` | `-=` |
| `*:` | `*=` |
| `/:` | `/=` |
| `%:` | `%=` |
| `<<:` | `<<=` |
| `>>:` | `>>=` |
| `&:` | `&=` |
| `^:` | `^=` |
| `\|:` | `\|=` |

The shared LMX syntax also includes `**` and `**:`. They require lowering the adopted exponentiation operation while preserving its existing contracts: C99 has no direct `**` or `**=` operators. This section assigns no new helper name, numeric implementation, or ABI, and does not permit passing those LMX tokens to the C compiler as native operators.

`switch` permits C fallthrough, unlike L3 `match`. L1 `throw/catch/finally` with a machine service payload does not define typed L2/L3 failures.

<a id="lowlevel-sync"></a>
## 23. Synchronization

L1 does not define the structural `synchronized` receiver. The kernel uses explicit machine and foreign atomic operations; `volatile` is not atomicity. The `synchronized` contract belongs to [L2](L2_spec_en.md#lowlevel-sync).
