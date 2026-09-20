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
