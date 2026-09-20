# L1 specification

This specification covers the L1 language, translation to C99, and the L2 core as implemented in L1/C. Evidence is `l1src/` (16 files from L1 root) and `l2src/` (sandbox core snapshot) at L1 commit `b2a7c98aa59aaf9654f2180e6f2a149e58aa48ee`. L3 semantics: [main specification](LMX_semantics.en.md). Core operations at L2: [L2 specification](L2_spec_en.md). Snapshot and divergences: [migration log](../steps/l1-l2-migration.md).

Each core mechanism is defined primarily in L2; this document states how it is written in L1 and lowered to C99. Shared rules are not restated: link the L2 anchor.

<a id="scope"></a>
## 1. Scope

Translator-L1 (`l1src/l1trans.lm1`) is a syntax-directed lowerer from wrapperless `.lm1` to one ANSI C99 translation unit per invocation. It is not L2: the L1 profile has no `Lmx` ontology, Message arena, or `implements` as language forms. The L2 core **is written** in L1 and is input to the same translator. Self-build: `l1src/build_l1.lm1`, generations gen0…gen3 (see `l1src/README.md`). Pin of the working `l1trans.exe` at L1 root: `L1_PIN.txt` = `4E0B7F5D942C291AFD4C2CEB8FBBA5B20EECC44BF7B455A40D8E564846D80DE7`. P0 parser: `parser.lm1` plus `p0.h` / `p0.h.lm1` plus `own.lm1`.

<a id="translator"></a>
## 2. Translator

Input: a file whose final extension is `.lm1`. A temporary explicit `L1:` path in `.lm2` does not make the two translators interchangeable. Direct C member lowering is not the contract for resolving L2 paths through an `Lmx` graph.

L1 prefix `@` is C address-of of that binding (`p: @ value` → `&value`). Longer `@` runs in declarators are C pointer stars, not repeated address-of. Backslash: a leading `\` is a raw pointer load; `value\field` is field-follow, C `->`. Repeated short declarations, `c.array`, `define`/`ifdef`, `os: win:/default:` are accepted by the `tests/l1/run_*.ps1` suites in the L1 tree (historical runs; not imported into LMX as the norm).

The libc door is declarations in `l1src/libc_abi.lm1` and `c.name` calls. L1 header units declare; an executable body in a header is refused.

Measured translator traps (deepseek; not language law until the author confirms): `\` on a value emits `->`; assignment does not declare a local; on the measured platform `ulong` is 4 bytes and `size_t` is 8; `predef:` pulls the whole source. Form `@(TYPE) name` does not parse; use `@(TYPE name)` or `@: TYPE name` (L1 commit `18bdab8`).

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

Rule: [L2 §7](L2_spec_en.md#message). `type: LmxFlag uint_fast8_t`; `struct: LmxMsg` in `lmx_message.h.lm1`. The source comment specifies reading `running` / `handoff_ready` with a load such as `__atomic_load_n(..., RELAXED)` where that matches an ordinary volatile load, without RMW or an extra fence; that is an implementation note, not a new L3 rule. Field-order selftest: `lmx_message_selftest.lm1`. Poll hooks are declared in `lmx.h.lm1` (`lmx_msg_poll_abort`, `lmx_msg_poll_escape`); bodies are on the kernel side.

<a id="thread"></a>
## 9. L3 Thread in L1

Rule: [L2 §8](L2_spec_en.md#thread). `struct: LmxThread` / `LmxLink`: `lmx_thread.h.lm1`; bodies: `lmx_thread.lm1`. A turn is `lmx_thread_turn`. The object's scheduler is `lmx_manager` / `lmx_schedule`, opened by `lmx_thread_scheduler_open`. The child chain is cells of the parent's arena.

<a id="mailbox"></a>
## 10. Mailbox in L1

Rule: [L2 §9](L2_spec_en.md#mailbox). `struct: LmxPost`, inbox ring and outbox/staged lists: `lmx_post.h.lm1`; bodies: `lmx_post.lm1`. Target admission is `lmx_post_admits` via the address domain. Delivery between objects is `lmx_deliver`.

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

The single admission mechanism is defined in [L3 §7](LMX_semantics.en.md#admission); its L2 role is described in [L2 §14](L2_spec_en.md#implements). In the imported code, `lmx_implements` compares kind and type by range, while `lmx_runtime_implements` matches numerical field positions. The latter does not implement the required named-path checking and must be completely replaced. These functions are called only by their own self-tests in the inspected snapshot. Address-classification functions in the same module remain infrastructure for the shared arena index; mail and calls use them.

<a id="gc"></a>
## 16. Collection in L1

Rule: [L2 §15](L2_spec_en.md#gc). `lmx_gc_collect`: `lmx_gc.lm1`.

<a id="c99"></a>
## 17. Lowering to C99

One translator invocation yields one `.c`. Strict generation builds: `-std=c99 -Wall -Wextra -Wpedantic` and `-Werror=` on incompatible pointers, discarded qualifiers, implicit declarations. `os:` selects Windows or POSIX (`l1trans.lm1`). `include:` / `predef:` become C includes. L1 aggregates `struct:` / `enum:` / `fnptr:` / `type:` lower to C99 typedef/struct. That is not the L2 memory model: the memory model is the arena ([L2 §6](L2_spec_en.md#arena)).

<a id="unresolved"></a>
## 18. Unresolved

See [L2 §17](L2_spec_en.md#unresolved) and the [log](../steps/l1-l2-migration.md). Additional translator gaps on mixa port modules (`empty colon Frame`, `unsupported statement atom`, node trailer) are recorded by deepseek as measurements, not as L1 rules.

<a id="lowlevel-scope"></a>
## 19. L1 machine surface and its relation to L2

These sections explain direct machine operations in the migrated [Translator-L1](../l1src/l1trans.lm1). Historical foundations are `L1_spec.txt` and §11–13/§20 of the general specification; implementation facts were checked against the functions named below. The corresponding full L2 family contract is [in L2](L2_spec_en.md#lowlevel-scope). It does not automatically apply to identical L1 spellings.

The key distinction is that an L1 variable or C aggregate field is not an Lmx graph cell. L1 has no language own-cache, hidden `implements` admission or automatic arena. The L1 kernel explicitly calls the arena library to implement L2 mechanisms. Having that library does not change L1 address, array or assignment semantics.

<a id="lowlevel-address"></a>
## 20. Pointers, fields and addressable targets

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
## 21. Machine-profile arrays

In L1, both handled families `[]:` and `c.array:` lower to C arrays. This differs from ordinary L2 Array construction, where `[]:` builds a descriptor. `l1_emit_bracket_array` handles the dimension sequence; `l1_emit_c_array` handles the explicit wrapper. Forms supported by the source reference and code include `[]: int values 3 2 4 6`, `[][]: int matrix 2 2`, `c.array: [3]: int: values 2 4 6`, `c.array: []: char buffer 256`.

The result is contiguous C storage with no `LmxArrayDesc`, arena metadata or hidden index checks. Rectangular `matrix` does not become separately allocated rows. The element type and pointer depth form the C declarator; `const` qualifies the base element. `l1_emit_c_array` rejects multiple logical child declarations, a missing type/name or an invalid outer head; it emits initializer contents through `l1_emit_inits`.

The distinction from a graph-backed L2 Array is how storage is located, not the presence of checks: L2 access likewise checks neither index nor descriptor. L2 `@array[i]` addresses the actual backing element, after which lowering uses an ordinary machine address. Checked access belongs to L3; the [contract and translator discrepancies](L2_spec_en.md#lowlevel-address) are described separately.

After lowering, extents, lifetime, initialization and array-to-pointer conversion follow C99. Successful parsing does not establish that the translator checked every C restriction: some errors are detected by the next compiler. Nor can every specified L2 `c.array` variant be attributed to this emitter: [L2](L2_spec_en.md#lowlevel-array) distinguishes the broad contract from narrow frontend support.

Retaining an automatic array's address after return does not extend its lifetime. Kernel code explicitly allocates long-lived storage through the [arena](#arena) or a foreign API with defined release. Raw C arrays used as translator scratch buffers do not prove support for ordinary graph Arrays in source L2.

<a id="lowlevel-abi"></a>
## 22. Casts, C interface and ABI declarations

`l1_emit_cast` lowers `cast: (T) expression` to an explicit C cast, including admitted pointer types and multiword C types such as `unsigned long`. This is not checked high-level numeric conversion: range, alignment and validity of subsequent access follow C and the called API's contract.

The `c.` prefix explicitly accesses a C symbol: `c.malloc`, `c.memcpy`, `c.sizeof` and so on. In compact C forms, the translator removes `c.` and processes permitted paths; it is not a general L1 text interpreter within parentheses. A nested colon receiver such as `c.sizeof((cast: (unsigned) 0))` has a dedicated diagnostic; a colon inside a string/character literal or matched C ternary expression must not be mistaken for a receiver.

`foreign: Name` declares an externally defined type: the translator registers the name, while an included C header must provide its definition. `extern: @: Lmx object` emits a declaration of another unit's object. Header-unit `type: Alias …`, `struct:`, `enum:`, `fnptr:` describe actual C ABI, not ordinary L3 Structures. `fnptr` is a C function-pointer type; it does not replace METHOD and L2's call contract.

Header source `name.h.lm1` produces `name.lm1.h`. Headers admit declarations, not executable bodies. `l1_hdr_*` orders dependencies: forward declarations suffice for pointers, but by-value fields require complete types; cycles of such dependencies are errors. `include` includes the specified file; header `predef` preserves relative paths so same-basename files in different directories do not collide. This is translator work, not a runtime name registry.

`external` exports the declared function/procedure; `prototype` declares it. `os`, `ifdef`, `define` select and express an explicit machine profile. Reserved `C`, `L1`, `L2`, `L3` do not establish that current L1 executes the former `C:` escape. In particular, the general specification's proposed `c.struct`/`c.union` must not be described as implemented handlers. Status and the broader L2 contract are [in L2](L2_spec_en.md#lowlevel-abi).

<a id="lowlevel-expression"></a>
## 23. C expressions, updates and control

`l1_emit_expr`, `l1_emit_expr_range`, `l1_emit_one_expr` and target handlers form C expressions. Source comparison `=` becomes `==`; `target: expression` becomes assignment. Pointer operations are described [above](#lowlevel-address). Arithmetic, logical and bitwise operations, shifts and `++`/`--` retain the selected C types' requirements; automatic arithmetic-overflow or bounds checks are not promised.

The implementation contains `if`/`else`, `while`, three-part `for`, `break`, `continue`, `switch`/`case`/`default` and return. `switch` has no automatic `break`: fallthrough follows C rather than L3 `match`. A visible nullary function's bare name in statement position can emit a call; it is not a label. `goto` does not make an arbitrary source form a valid target declaration. Historical empty-colon-Frame restrictions belong to actual P0 and are separately checked by the new grammar corpus.

Current L1 has its own limited `throw`/`catch`/`finally` lowering: a service code and `long` payload of up to eight fields. This is neither L2's complete typed result/failure contract nor implemented L3 validation. Its limits must not become L3 rules. The shared subset and machine roles are documented in [L2](L2_spec_en.md#lowlevel-expression).

<a id="lowlevel-sync"></a>
## 24. Synchronization: requirements and implementation

The L2 `synchronized` contract, including release on exits, is retained [in L2](L2_spec_en.md#lowlevel-sync). A search of migrated `l1trans.lm1` and `l2trans.lm1` found no handler for this receiver. The old specification's `lm_synchronized_enter/leave` illustration must not be presented as currently emitted code.

The L1-written kernel uses explicit machine/foreign operations to implement [mail](#mailbox) and handshakes. Memory ordering and permitted writers belong to the respective module, not the name `synchronized`. `volatile` does not substitute for an atomic operation, and atomic calls do not establish support for a source-level structural synchronization region. Adding that support is separate translator work, not implemented by this documentation revision.
