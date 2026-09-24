# L1 specification

This specification covers L1, its lowering to C99, and the spelling of L2 kernel mechanisms in L1/C. L3 semantics are in the [main specification](LMX_semantics.en.md), and L2 operations and kernel model are in the [L2 specification](L2_spec_en.md). Implementation state, inspected snapshots, and migration work are kept in the [implementation notes](implementation-notes.en.md).

Each core mechanism is defined primarily in L2; this document defines only a convenient intermediate spelling of its implementation and its lowering to C99. L1 does not repeat L2 graph semantics: graph identity, `own-load`, `dirty`, dynamic visibility, and contextual receiver roles have already been resolved before L1 is emitted.

<a id="scope"></a>
## 1. Scope

Translator-L1 (`l1src/l1trans.lm1`) is a syntax-directed lowerer from wrapperless `.lm1` to one ANSI C99 translation unit per invocation. It is not L2: the L1 profile has no `Lmx` ontology, Message arena, or `implements` as language forms. The L2 core may be written in L1 and supplied to the same translator.

<a id="translator"></a>
## 2. Translator

The profile input is a file whose final extension is `.lm1`. Direct C member lowering is not the contract for resolving L2 paths through an `Lmx` graph.

L1 prefix `@` is C address-of of that binding (`p: @ value` → `&value`). Longer `@` runs in declarators are C pointer stars, not repeated address-of. Backslash: a leading `\` is a raw pointer load; `value\field` is field-follow, C `->`.

Projection of a nonprimitive Lingvamyxa value into L1 is never a C aggregate passed by value: Structure and Array values are stored, passed, and returned by copying the physical reference to their descriptor/occurrence. Source `Model: fresh` therefore does not lower to `struct Model fresh`; it constructs a graph value and its working L1 binding is reference-shaped, conceptually `Lmx *fresh`. Taking `@fresh` addresses the slot that already stores this reference and therefore conceptually produces `Lmx **`. Internal machine-ABI records of the kernel, explicitly declared through L1 `struct:` and sometimes embedded by value, are not projections of nonprimitive language values and do not weaken this prohibition.

The libc door is declarations in `l1src/libc_abi.lm1` and `c.name` calls. L1 header units declare; an executable body in a header is refused.

<a id="lmx"></a>
## 3. `Lmx` in L1

Field definition: [L2 §2](L2_spec_en.md#lmx). The target L1 projection in `l2src/lmx.h.lm1` defines `VoidArray` with `size_t: size` and `@: void data`, then `Lmx` with a **by-value first member** `VoidArray array`, a second member `@: Lmx parent` and a third member `LmxEntry: native` — the direct reference to the native implementation of the Structure's body, zero when there is none (accepted 2026-09-25; the current header still has the flat `{parent, len, data}` layout without `native`); the C header is generated. The target ABI needs no separate `LmxArrayDesc` alias. This is the embedded physical child-reference array itself, whose backing is registered in the arena range index, not an additional wrapper over the old `len` and `data` fields. No tag is stored on the record. A Structure field slot is a `void *` array cell; the dynamic membership of child-Message references is a separate List (`KIND_LIST`) in the graph and is not lowered to a fixed group of such slots.

<a id="type-by-range"></a>
## 4. Type by range in L1

Rule: [L2 §3](L2_spec_en.md#type-by-range). Enumerations and `LmxRange` live in the same `lmx.h.lm1`. The index belongs to the arena; classification is `lmx_range_*` from `lmx_arena.h.lm1`, bodies in `lmx_range.lm1` / `lmx_arena.lm1`. Mechanism domains are `#define`s in `lmx_implements.h.lm1`, not fields of `LmxMsg`.

<a id="pool"></a>
## 5. Pool in L1

Rule: [L2 §4](L2_spec_en.md#pool). Chunk and pool structs are in `lmx.h.lm1`. Operations `lmx_pool_open`, `lmx_pool_make`, `lmx_pool_take`, `lmx_pool_take_n`, `lmx_pool_add_chunk` are declared in `lmx_pool.h.lm1` and implemented in `lmx_pool.lm1`. Growth is a new chunk as arena blocks so `revert` retires the interval with them.

<a id="method-array"></a>
## 6. METHOD and Array in L1

Rule: [L2 §5](L2_spec_en.md#method-array). `fnptr: LmxEntry () void`; `struct: LmxMethod` and `VoidArray` in `lmx.h.lm1`. The descriptor lowers to exactly two fields `{size, data}` in that order; standalone Array backing contains exactly `size` cells. The same physical representation is embedded as the first member of `Lmx` for child references. Base Array has no `capacity` and does not grow or switch backing. Dynamic membership uses separate List (`KIND_LIST`) modules such as `lmx_list_owned`. Typed Array pools: `lmx_array_owned`, `lmx_array_ref_owned`, `lmx_chars_owned`, `lmx_value_owned`.

<a id="arena"></a>
## 7. Arena in L1

Rule: [L2 §6](L2_spec_en.md#arena). `struct: LmxArena` and prototypes: `lmx_arena.h.lm1`; bodies: `lmx_arena.lm1`. Blocks: `lmx_arena_blocks.h.lm1` / `.lm1`. Structure slots: `lmx_arena_refs.h.lm1` / `.lm1`. Collector generation is field `generation`; simple mode is `simple`. Every L3 Thread uses the same typed-Array mechanism. At creation its arena receives only explicitly supplied data and references. Bootstrap may place permanent values of the initial module in its owner R0's arena through ordinary Array operations and pass their physical references to its children. A later DLL-like module creates its own sealed typed ranges in its owner's arena. During composition or qualified constructor lowering, a consumer receives the original physical reference to an `independent: const: immutable` value without copying it or changing its owner. Its unload operation and range lifetime are not yet defined. L1 lowering creates no hidden tables, automatic inheritance, separate semantic import operation, or special root-slot numbers.

<a id="message"></a>
## 8. Message in L1

Rule: [L2 §7](L2_spec_en.md#message). `type: LmxFlag uint_fast8_t`; `struct: LmxMsg` in `lmx_message.h.lm1`. Local identity lowers to the record's physical address; Message has no `index` field. Reading `running` / `handoff_ready` is an ordinary atomic load without RMW or an additional fence. Poll hooks are declared in `lmx.h.lm1` (`lmx_msg_poll_abort`, `lmx_msg_poll_escape`); bodies are on the kernel side.

<a id="thread"></a>
## 9. L3 Thread in L1

Rule: [L2 §8](L2_spec_en.md#thread). An executable L3 Thread lowers as one record whose first field is the closed Message record by value: `struct: LmxThread; LmxMsg: message; ...`. Consequently `@thread` and `@thread\message` have the same physical address. This is a common C-layout prefix, not semantic inheritance: `LmxMsg` stays minimal, while mail, scheduling, execution mode, and the other Thread APIs remain in the Thread-only tail. A standalone plain Message is still an independent `LmxMsg` record and cannot later be upgraded in place to a Thread; an executable object is constructed as `LmxThread` from the beginning. Message operations may use the first-member address, but Thread operations require that the exact typed range classify the allocation as `LmxThread`. Sole direct-child membership lowers to a graph List (`KIND_LIST`) of physical references allocated in the parent's arena. The scheduler traverses that List directly; no separate `LmxLink` chain or manager membership queue is emitted. A turn is `lmx_thread_turn`. There is no thread execution mode and no mode request at the turn boundary (the earlier mode flag was removed): a Structure in code position runs natively when its `native` word is set and through the walker when it is empty ([L2 §10](L2_spec_en.md#own)). Both paths run over the declared fields of the executed Structure — the ordinary call over the Structure's own graph, a fresh instance only on re-entry or with explicitly passed data — and do not copy the method on entry; the earlier activation-frame own-load/dirty model is transitional (§11). Auxiliary storage may be reusable, but per-activation allocation and release must not make entry substantially more expensive than a native call.

<a id="root-close"></a>
### 9.1. R0 and the upper parent frame in L1

Rule: [L2 §8.1](L2_spec_en.md#root-close). R0 is an ordinary L3 Thread with no additional functions; its WorldWideMix parent frame uses the same parent mechanism and likewise receives no root-only API. Only the upper frame lacks a parent of its own. The ordinary cascade follows the graph Lists of direct children. The overall subtree timeout belongs to an external host watchdog and is tested independently of R0's liveness deadline and descendants' individual deadlines. The normal path returns only after the entire subtree has completed; expiry of the upper deadline lowers by the host to unconditional OS-process termination, not a repeatable `close` call or successful return of a partially closed runtime.

<a id="mailbox"></a>
## 10. Mailbox in L1

Rule: [L2 §9](L2_spec_en.md#mailbox). Each L3 Thread owns its `struct: LmxPost` and mail API. A delivery/address service explicitly supplied by the parent only resolves a target and invokes destination-mailbox admission; it neither reads the mailbox, schedules the recipient, nor tracks membership. The inbox ring is a DynamicArray of its pair-record element type plus `head`/`tail`, growing by approximately `3/2` from initial capacity 2 (capacity is on the `*DynamicArray` field, not on base Array); its sole reentrant monitor without wait/notify and the outbox/staged lists are declared in `lmx_post.h.lm1`. Each inbox entry is `[target, source_arena]`: publication does not mutate the receiver arena, and the receiver owner attaches the donor before exposing the target; refusal retains the pair. All enter/leave, growth, and collection operations are confined to `lmx_post.lm1`. The private ring backing is not a graph value and may move only under the monitor. The monitor does not wrap atomic operations on `LmxMsg.running/success/handoff_ready`; they remain a separate Message mechanism. `init` and `close` require no concurrent mailbox operation; close fails closed on a donor it cannot release. Settlement closes the mailbox before route/member removal and before arena release or attachment. Target admission is `lmx_post_admits` via the address domain. Delivery between objects is `lmx_deliver`.

<a id="own"></a>
## 11. Own in L1

Rule: [L2 §10](L2_spec_en.md#own) — the execution pair: writes go directly into the declared fields of the executed Structure; there are no working copies, dirty marks or checkpoints. Transitional implementation still present in the tree: `lmx_own_load` / `lmx_own_write` / `lmx_own_checkpoint` in `lmx_own.lm1` and the dirty bookkeeping in `lmx_dirty.h.lm1`, used only by the native translator's generated code until its cell-direct rewrite lands; the walker no longer uses them. They are not an instruction for new code.

<a id="call"></a>
## 12. Call in L1

Rule: [L2 §11](L2_spec_en.md#call). Transitional METHOD uses `fnptr: LmxCallEntry (@: Lmx node) int`; Callable uses `fnptr: LmxCallEntrySelf (@: Lmx node; @: Lmx self) int`, where `node` is the activation-fixed lexical space above the method and `self` is the hidden physical own-field base of the selected occurrence. Ordinary field `Lmx.parent` is not a language word. `lmx_call0`: `lmx_call.lm1`. Signature matching is the translator's duty, not this module's.

<a id="child"></a>
## 13. Child in L1

Rule: [L2 §12](L2_spec_en.md#child). Creation and reservation prepare a child separately; successful publication appends its physical reference to the child List (`KIND_LIST`) in the parent's graph. The L1 interface accepts no child-slot number and introduces no fixed membership size.

<a id="copy-merge"></a>
## 14. Copy and merge in L1

The rule is already defined in [L2 §13](L2_spec_en.md#copy-merge) and [L3 §8](LMX_semantics.en.md#construction). `lmx_graph_copy_owned.lm1`, `lmx_merge_owned.lm1`, and their paired `.h.lm1` files are the L1 implementation of the full `merge` traversal. L1 itself does not decide whether `left: right` is a declaration, assignment, or call, contain graph bindings, or model `own-load`/`dirty`. Before emitting L1, the L2 translator selects the contextual role, performs the required type, `const`, and `implements` checks, and then emits either an unambiguous call to the `merge` implementation or an ordinary C-like reference assignment. Intermediate spellings may vary provided the generated C preserves the selected L2/L3 semantics and the complete `merge` traversal.

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

The `c.` prefix is the raw door into C: explicit access to a C symbol (`c.malloc`, `c.memcpy`, `c.sizeof`, and so on). The door does not maintain a declaration registry of C names as language norm. In compact C forms, the translator removes `c.` and lowers to C99; it is not a general L1 text interpreter within parentheses. A nested colon receiver such as `c.sizeof((cast: (unsigned) 0))` has a dedicated diagnostic; a colon inside a string/character literal or matched C ternary expression must not be mistaken for a receiver.

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
