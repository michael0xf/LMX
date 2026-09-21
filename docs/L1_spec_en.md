# L1 specification

This specification covers L1, its lowering to C99, and the spelling of L2 kernel mechanisms in L1/C. L3 semantics are in the [main specification](LMX_semantics.en.md), and L2 operations and kernel model are in the [L2 specification](L2_spec_en.md). Implementation state, inspected snapshots, and migration work are kept in the [implementation notes](implementation-notes.en.md).

Each core mechanism is defined primarily in L2; this document defines how it is written in L1 and lowered to C99.

<a id="scope"></a>
## 1. Scope

Translator-L1 (`l1src/l1trans.lm1`) is a syntax-directed lowerer from wrapperless `.lm1` to one ANSI C99 translation unit per invocation. It is not L2: the L1 profile has no `Lmx` ontology, Message arena, or `implements` as language forms. The L2 core may be written in L1 and supplied to the same translator.

<a id="translator"></a>
## 2. Translator

The profile input is a file whose final extension is `.lm1`. Direct C member lowering is not the contract for resolving L2 paths through an `Lmx` graph.

L1 prefix `@` is C address-of of that binding (`p: @ value` → `&value`). Longer `@` runs in declarators are C pointer stars, not repeated address-of. Backslash: a leading `\` is a raw pointer load; `value\field` is field-follow, C `->`.

The libc door is declarations in `l1src/libc_abi.lm1` and `c.name` calls. L1 header units declare; an executable body in a header is refused.

<a id="lmx"></a>
## 3. `Lmx` in L1

Field definition: [L2 §2](L2_spec_en.md#lmx). In L1 this is `struct: Lmx` in `l2src/lmx.h.lm1`; the C header is generated. Fields are L1 types `@: Lmx`, `int`, `@: void`. No tag on the record. A child slot is a `void *` array cell; the slot address is `lmx_arena_refs` / former `lmx_branch_slot`.

<a id="type-by-range"></a>
## 4. Type by range in L1

Rule: [L2 §3](L2_spec_en.md#type-by-range). Enumerations and `LmxRange` live in the same `lmx.h.lm1`. The index belongs to the arena; classification is `lmx_range_*` from `lmx_arena.h.lm1`, bodies in `lmx_range.lm1` / `lmx_arena.lm1`. Mechanism domains are `#define`s in `lmx_implements.h.lm1`, not fields of `LmxMsg`.

<a id="pool"></a>
## 5. Pool in L1

Rule: [L2 §4](L2_spec_en.md#pool). Chunk and pool structs are in `lmx.h.lm1`. Operations `lmx_pool_open`, `lmx_pool_make`, `lmx_pool_take`, `lmx_pool_take_n`, `lmx_pool_add_chunk` are declared in `lmx_pool.h.lm1` and implemented in `lmx_pool.lm1`. Growth is a new chunk as arena blocks so `revert` retires the interval with them.

<a id="method-array"></a>
## 6. METHOD and Array in L1

Rule: [L2 §5](L2_spec_en.md#method-array). `fnptr: LmxEntry () void`; `struct: LmxMethod` and `LmxArrayDesc` in `lmx.h.lm1`. Typed Array pools: `lmx_array_owned`, `lmx_array_ref_owned`, `lmx_chars_owned`, `lmx_value_owned`.

<a id="arena"></a>
## 7. Arena in L1

Rule: [L2 §6](L2_spec_en.md#arena). `struct: LmxArena` and prototypes: `lmx_arena.h.lm1`; bodies: `lmx_arena.lm1`. Blocks: `lmx_arena_blocks.h.lm1` / `.lm1`. Structure slots: `lmx_arena_refs.h.lm1` / `.lm1`. Collector generation is field `generation`; simple mode is `simple`.

<a id="message"></a>
## 8. Message in L1

Rule: [L2 §7](L2_spec_en.md#message). `type: LmxFlag uint_fast8_t`; `struct: LmxMsg` in `lmx_message.h.lm1`. Reading `running` / `handoff_ready` is an ordinary atomic load without RMW or an additional fence. Poll hooks are declared in `lmx.h.lm1` (`lmx_msg_poll_abort`, `lmx_msg_poll_escape`); bodies are on the kernel side.

<a id="thread"></a>
## 9. L3 Thread in L1

Rule: [L2 §8](L2_spec_en.md#thread). `struct: LmxThread` / `LmxLink`: `lmx_thread.h.lm1`; bodies: `lmx_thread.lm1`. A turn is `lmx_thread_turn`. The object's scheduler is `lmx_manager` / `lmx_schedule`, opened by `lmx_thread_scheduler_open`. The child chain is cells of the parent's arena. One turn selects exactly one body path, native or interpreted. A separate operation explicitly requests the next turn's mode and `endturn` commits that request; the presence of an entry or body does not select a mode. Both paths use the same activation-frame own-load/dirty model and do not copy the method on entry. Auxiliary storage may be reusable, but per-activation allocation and release must not make entry substantially more expensive than a native call.

<a id="mailbox"></a>
## 10. Mailbox in L1

Rule: [L2 §9](L2_spec_en.md#mailbox). `struct: LmxPost`, its inbox ring, its sole reentrant monitor without wait/notify, and the outbox/staged lists are declared in `lmx_post.h.lm1`; all enter/leave and collection operations are confined to `lmx_post.lm1`. Target admission is `lmx_post_admits` via the address domain. Delivery between objects is `lmx_deliver`.

<a id="own"></a>
## 11. Own in L1

Rule: [L2 §10](L2_spec_en.md#own). `lmx_own_load` / `lmx_own_write` / `lmx_own_checkpoint`: `lmx_own.lm1`. Adjacent dirty bookkeeping on a turn: `lmx_dirty.h.lm1`.

<a id="call"></a>
## 12. Call in L1

Rule: [L2 §11](L2_spec_en.md#call). `fnptr: LmxCallEntry (@: Lmx node) int`; `lmx_call0`: `lmx_call.lm1`. Signature matching is the translator's duty, not this module's.

<a id="child"></a>
## 13. Child in L1

Rule: [L2 §12](L2_spec_en.md#child). `lmx_child_create` / `reserve` / `publish_prepared` / `drop_prepared` / `handoff`: `lmx_child.lm1`.

<a id="copy-merge"></a>
## 14. Copy and merge in L1

Rule: [L2 §13](L2_spec_en.md#copy-merge). `lmx_graph_copy_owned.lm1`, `lmx_merge_owned.lm1` and paired `.h.lm1`.

<a id="implements"></a>
## 15. `implements` in L1

The admission mechanism is defined in [L3 §7](LMX_semantics.en.md#admission); its L2 role is described in [L2 §14](L2_spec_en.md#implements). Address-classification functions serve the common arena index used by mail and calls; classification by itself is not `implements`.

<a id="gc"></a>
## 16. Collection in L1

Rule: [L2 §15](L2_spec_en.md#gc). `lmx_gc_collect`: `lmx_gc.lm1`.

<a id="c99"></a>
## 17. Lowering to C99

One translator invocation yields one `.c`. Strict generation builds: `-std=c99 -Wall -Wextra -Wpedantic` and `-Werror=` on incompatible pointers, discarded qualifiers, implicit declarations. `os:` selects Windows or POSIX (`l1trans.lm1`). `include:` / `predef:` become C includes. L1 aggregates `struct:` / `enum:` / `fnptr:` / `type:` lower to C99 typedef/struct. That is not the L2 memory model: the memory model is the arena ([L2 §6](L2_spec_en.md#arena)).

<a id="lowlevel-scope"></a>
## 18. L1 machine surface and its relation to L2

These sections define Translator-L1's direct machine operations. The corresponding full L2 family contract is [in L2](L2_spec_en.md#lowlevel-scope) and does not automatically apply to identical L1 spellings.

The key distinction is that an L1 variable or C aggregate field is not an Lmx graph cell. L1 has no language own-cache, hidden `implements` admission or automatic arena. The L1 kernel explicitly calls the arena library to implement L2 mechanisms. Having that library does not change L1 address, array or assignment semantics.

<a id="lowlevel-address"></a>
## 19. Pointers, fields and addressable targets

| L1 | C99 output | Condition |
| --- | --- | --- |
| `@: int p` | `int *p` | Explicit pointer declaration |
| `@@: char pp` | `char **pp` | Each declarative `@` adds a level |
| `p: @x` | `p = &x` | x is an addressable C target |
| `\p` | `*p` | Address must be valid and suitably typed |
| `\p: value` | `(*p) = value` | Target permits writing |
| `p\field` | `p->field` | p points to an aggregate with a known field |
| `a[i]: value` | `a[i] = value` | Raw C index; no automatic check |

`l1_emit_assign_head` parses leading dereferences, the root, field suffixes and indices. `l1_assign_index_close` accounts for nested brackets, strings and escapes; `l1_emit_assign_index` delegates index contents to ordinary expression parsing. Empty indices, unclosed brackets, missing names after `\` and malformed targets produce diagnostics. This is lvalue parsing, not declaration or field creation.

Ordinary `value\field` always lowers as a pointer step. A by-value C aggregate needs explicit C access such as `c.value.field`; emitted `value->field` cannot be considered correct merely because the source parsed. Ordinary L2 graph paths have a different [address contract](L2_spec_en.md#lowlevel-address).

In an expression, `@` is address-of; in type form `@: T`, it is a pointer declarator. Thus `c.sizeof(@: char)` denotes the size of `char *`, whereas `c.sizeof(@ x)` denotes the size of x's address. Extra pointer-type/parameter fields must not disappear: the translator has diagnostics `pointer type has extra fields` and `pointer parameter has extra fields`. Neither a cast nor a pointer declarator alone verifies liveness, alignment, bounds or access rights.

`const: @(char p)` lowers to `const char *p`: characters are protected, not the pointer slot. L1 `immutable` applies this C qualification to a group of declarations; it is neither L3 deep graph immutability nor `RuntimeImmutable`. Rebinding p remains allowed, writing through it does not. Nested wrappers collapse to one C `const`; this does not promise protection through every alias of a mutable foreign object.

<a id="lowlevel-array"></a>
## 20. Machine-profile arrays

In L1, both handled families `[]:` and `c.array:` lower to C arrays. This differs from ordinary L2 Array construction, where `[]:` builds a descriptor. `l1_emit_bracket_array` handles the dimension sequence; `l1_emit_c_array` handles the explicit wrapper. The profile includes `[]: int values 3 2 4 6`, `[][]: int matrix 2 2`, `c.array: [3]: int: values 2 4 6`, and `c.array: []: char buffer 256`.

The result is contiguous C storage with no `LmxArrayDesc`, arena metadata or hidden index checks. Rectangular `matrix` does not become separately allocated rows. The element type and pointer depth form the C declarator; `const` qualifies the base element. `l1_emit_c_array` rejects multiple logical child declarations, a missing type/name or an invalid outer head; it emits initializer contents through `l1_emit_inits`.

The distinction from a graph-backed L2 Array is how storage is located, not the presence of checks: L2 access likewise checks neither index nor descriptor. L2 `@array[i]` addresses the actual backing element, after which lowering uses an ordinary machine address. Checked access belongs to L3; the [L2 contract](L2_spec_en.md#lowlevel-address) is defined separately.

After lowering, extents, lifetime, initialization and array-to-pointer conversion follow C99. Successful parsing does not establish that every C restriction was checked: some errors are detected by the next compiler. The L2 `c.array` contract is defined [separately](L2_spec_en.md#lowlevel-array).

Retaining an automatic array's address after return does not extend its lifetime. Kernel code explicitly allocates long-lived storage through the [arena](#arena) or a foreign API with defined release. Raw C arrays used as translator scratch buffers do not prove support for ordinary graph Arrays in source L2.

<a id="lowlevel-abi"></a>
## 21. Casts, C interface and ABI declarations

`l1_emit_cast` lowers `cast: (T) expression` to an explicit C cast, including admitted pointer types and multiword C types such as `unsigned long`. This is not checked high-level numeric conversion: range, alignment and validity of subsequent access follow C and the called API's contract.

The `c.` prefix explicitly accesses a C symbol: `c.malloc`, `c.memcpy`, `c.sizeof` and so on. In compact C forms, the translator removes `c.` and processes permitted paths; it is not a general L1 text interpreter within parentheses. A nested colon receiver such as `c.sizeof((cast: (unsigned) 0))` has a dedicated diagnostic; a colon inside a string/character literal or matched C ternary expression must not be mistaken for a receiver.

`foreign: Name` declares an externally defined type: the translator registers the name, while an included C header must provide its definition. `extern: @: Lmx object` emits a declaration of another unit's object. Header-unit `type: Alias …`, `struct:`, `enum:`, `fnptr:` describe actual C ABI, not ordinary L3 Structures. `fnptr` is a C function-pointer type; it does not replace METHOD and L2's call contract.

Header source `name.h.lm1` produces `name.lm1.h`. Headers admit declarations, not executable bodies. `l1_hdr_*` orders dependencies: forward declarations suffice for pointers, but by-value fields require complete types; cycles of such dependencies are errors. `include` includes the specified file; header `predef` preserves relative paths so same-basename files in different directories do not collide. This is translator work, not a runtime name registry.

`external` exports the declared function/procedure; `prototype` declares it. `os`, `ifdef`, `define` select and express an explicit machine profile. Reserved heads `C`, `L1`, `L2`, `L3`, `c.struct`, and `c.union` have no behavior without an explicit profile definition. The broader L2 contract is [in L2](L2_spec_en.md#lowlevel-abi).

<a id="lowlevel-expression"></a>
## 22. C expressions, updates and control

`l1_emit_expr`, `l1_emit_expr_range`, `l1_emit_one_expr` and target handlers form C expressions. Source comparison `=` becomes `==`; `target: expression` becomes assignment. Pointer operations are described [above](#lowlevel-address). Arithmetic, logical and bitwise operations, shifts and `++`/`--` retain the selected C types' requirements; automatic arithmetic-overflow or bounds checks are not promised.

The profile contains `if`/`else`, `while`, three-part `for`, `break`, `continue`, `switch`/`case`/`default`, and return. `switch` has no automatic `break`: fallthrough follows C rather than L3 `match`. A visible nullary function's bare name in statement position may denote a call; it is not a label. `goto` does not make an arbitrary source form a valid target declaration.

The L1 `throw`/`catch`/`finally` profile uses a service code and a `long` payload of up to eight fields. This contract belongs only to L1; typed L2 results and failures are specified [separately](L2_spec_en.md#lowlevel-expression).

<a id="lowlevel-sync"></a>
## 23. Synchronization

L1 does not define a source-level structural `synchronized` receiver; its contract belongs to [L2](L2_spec_en.md#lowlevel-sync). The L1-written kernel uses explicit machine/foreign operations for [mail](#mailbox) and handshakes. Their memory ordering and permitted writers belong to the respective module. `volatile` does not substitute for an atomic operation, and an atomic call does not create a structural synchronization region.
