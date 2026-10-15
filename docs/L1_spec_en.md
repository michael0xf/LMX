# L1 Specification

L1 is the generated intermediate representation used to lower the kernel to C99. Graph-language rules belong to [L3](LMX_semantics.en.md) and [L2](L2_spec_en.md); only the C projection remains here. Current translator status and transitional hand-written L1 belong to the [implementation notes](implementation-notes.en.md).

<a id="scope"></a>
## 1. Scope

`l1trans` lowers `.lm1` to one C99 translation unit. L1 itself does not define arenas, `implements`, or graph visibility as language operations. The kernel library implements them explicitly. The self-build target is L3 with L2 insertions; L1 remains intermediate.

<a id="translator"></a>
## 2. Translator

L1 resolves its C-like declarations and expressions. Prefix `@x` takes the address of C cell `x`, prefix `\p` loads through a pointer, and `p\field` accesses a field through a pointer. Declarative `@ⁿ:` sets the corresponding C pointer depth. The historical argument order for pointer declarations in hand-written L1 is not a permanent exception: target intermediate L1 must follow the shared L2/L3 order “name, requirement, value.” Foreign C symbols use explicit `c.name`.

<a id="lmx"></a>
## 3. Lmx in L1

The target C projection of [L2 §2](L2_spec_en.md#lmx) gives an ordinary Structure and a language Array a common `Lmx` base: both are graph objects with structural `parent` and `native`. The Array specialization holds fixed, typed elements; primitive and reference elements retain their physical access rules. The current layout, in which `Lmx` embeds `VoidArray` as its first member, is transitional rather than the inheritance rule. The exact future C field order is not yet settled; see [implementation status](implementation-notes.en.md#l2-status). Graph records gain no name, model tag, or hidden execution fields. Thread's dynamic child List remains separate.

<a id="interpretable-tree"></a>
### 3.1. Tree projection

Lowering preserves the full graph for the walker and `toLmx`; later mutation changes that same graph. It allocates no `leaf` wrapper for an already typed primitive cell and stores no names in graph records. The name table and comments serve text output of the current graph, not execution. The full contract is [L2 §2.1](L2_spec_en.md#interpretable-tree).

<a id="type-by-range"></a>
## 4. Type by range

`LmxRange` and the arena index classify physical addresses rather than reading in-band cell tags. User models do not create one C type per Structure. Ordinary and `immutable` Structures have separate pools while retaining a compatible physical record. See [L2 §3](L2_spec_en.md#type-by-range).

<a id="pool"></a>
## 5. Pool

`LmxPool` and `LmxChunk` allocate fixed cells. Growth adds a chunk instead of moving live cells through `realloc`. Pool and range belong to the arena. See [L2 §4](L2_spec_en.md#pool).

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

`LmxPost` holds `staged`, `outbox`, and FIFO `inbox`. An incoming slot is the pair `[target, source_arena]`; the recipient owner attaches the donor before releasing the target. The inbox ring uses a separate DynamicArray with movable backing and a mailbox monitor; it is not the fixed graph slots of a Structure. See [L2 §9](L2_spec_en.md#mailbox).

<a id="own"></a>
## 11. Working state

L1 kernel code implements loads of used own fields, `dirty` marks, and publication at checkpoints. This lowers [L3 semantics](LMX_semantics.en.md#dynamic), rather than redefining the language. Graph slots remain physically stable.

<a id="call"></a>
## 12. Call

The native-entry and primitive callback has one shape:

```c
int (void *owner, void **refs, size_t nargs,
     void *dest, void **out, LmxArena *arena, Lmx *code)
```

`owner` denotes active data, `code` the selected executable occurrence, and `arena` the actual call arena. A nonnull `refs[k]` points to argument value storage; null means absence. An object pointer value goes into a canonical `void *` cell; casting `T **` to `void **` is not a value conversion. The callback integer return is status, not the user's result. `dest` and `out` carry the result under the declared contract; a null reference can be a present result. Native/walker selection and the code→data map are specified in [L2 §11](L2_spec_en.md#call).

<a id="child"></a>
## 13. Child

A child is built in its own arena. Publication adds its reference to `Thread.children` without appending a field to the source Structure. See [L2 §12](L2_spec_en.md#child).

<a id="copy-merge"></a>
## 14. Copy and merge

`lmx_graph_copy_owned` and `lmx_merge_owned` implement a complete traversal using one source→copy map: repeated references reach one copy, and internal references and `parent` are rebased. Typed executable-operation records are copied with the body. The `native` word transfers only if the body remains selected and its address/type contract is proved. L1 does not re-decide whether a source Frame is a declaration, assignment, or call. See [L2 §13](L2_spec_en.md#copy-merge).

<a id="implements"></a>
## 15. implements

The `LmxImplEntry` table stores a proven address mapping between candidate fields and the receiving description for any admitted pair of Structures. Different field order cannot be reduced to identity ordinals; reading, address-taking, and direct publication of a ready `dirty` value follow that same correspondence. At one structural level there are no multiple fields of one name; old `[N]name` targets as numbered duplicate **data fields** and “last occurrence” selection are not part of the new contract. The returning `s\[N]field` addresses a source head occurrence, not the Nth data field. The map holds no runtime names and does not itself keep the graph alive. See [L2 §14](L2_spec_en.md#implements).

<a id="gc"></a>
## 16. Collection

`lmx_gc_collect` implements collection from arena roots including Message, graph, mail, and `Thread.children`. Simple arena mode does not collect. See [L2 §15](L2_spec_en.md#gc).

<a id="c99"></a>
## 17. C99 output

One translator invocation emits one `.c`. Strict compilation uses `-std=c99 -Wall -Wextra -Wpedantic` and diagnostics for incompatible pointers, discarded qualifiers, and implicit declarations. `struct:`, `enum:`, `fnptr:`, and `type:` lower to C declarations. This does not alter the arena memory model.

<a id="lowlevel-scope"></a>
## 18. Machine surface

L1 retains the target platform's C99 representation and numeric semantics. An L1 variable or C aggregate field is not automatically an Lmx graph cell; graph access goes through the kernel library. Identical spellings in L1 and L2 need not denote the same semantic operation.

<a id="lowlevel-address"></a>
## 19. Pointers and fields

| L1 | C99 |
| --- | --- |
| `@: p int` | `int *p` |
| `@@: pp char` | `char **pp` |
| `p: @x` | `p = &x` |
| `\p` | `*p` |
| `\p: value` | `(*p) = value` |
| `p\field` | `p->field` |
| `a[i]: value` | `a[i] = value` |

The table states the target unified spelling; transitional hand-written L1 may still need declaration-order migration. An addressable target needs valid C storage. `value\field` is a pointer step; by-value C aggregate access needs an explicit C form. `const: @(char p)` lowers to `const char *p` and protects the characters, not the pointer cell. This is not L3 deep immutability.

<a id="lowlevel-array"></a>
## 20. Array and raw C arrays

Ordinary `[]:` in L1 as well as L2/L3 denotes a language Array: a graph Structure on the shared `Lmx` base with typed elements, structural `parent`, and `native`. Only the explicit `c.array:` door selects a raw contiguous C array without graph `Lmx`, arena, or hidden bounds checks. A rectangular raw array does not become an array of separately allocated rows. Automatic C-array lifetime follows C99; it is not identified with a graph Array. The former lowering of bare L1 `[]:` directly to a C array is an implementation state to remove.

<a id="lowlevel-abi"></a>
## 21. Casts and C ABI

`cast: (T) expression` emits an explicit C cast, not an L3 checked conversion. `c.name` is an explicit foreign C symbol. `foreign: Name` requires a type definition in an included C header; `external` and `prototype` describe export and declaration, while `include` and `predef` select explicit dependencies. Header source `name.h.lm1` emits `name.lm1.h` and permits declarations without executable bodies. A by-value field needs a complete C type; a pointer permits a forward declaration.

<a id="lowlevel-expression"></a>
## 22. Expressions and control

L1 lowers C arithmetic, logic, bitwise operations, `++/--`, and ordinary control flow. Source `=` in a comparison becomes `==`; `target: expression` is assignment. `switch` permits C fallthrough, unlike L3 `match`. L1 `throw/catch/finally` with a machine service payload does not define typed L2/L3 failures.

<a id="lowlevel-sync"></a>
## 23. Synchronization

L1 does not define the structural `synchronized` receiver. The kernel uses explicit machine and foreign atomic operations; `volatile` is not atomicity. The `synchronized` contract belongs to [L2](L2_spec_en.md#lowlevel-sync).
