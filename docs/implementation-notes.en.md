# LMX implementation and migration notes

This document is not a language specification. It contains state of concrete translators and sources, investigation results, temporary limitations, open design decisions, and developer work. Normative rules live in [L1](L1_spec_en.md), [L2](L2_spec_en.md), [L3 semantics](LMX_semantics.en.md), and the [grammar](LMX_grammar.en.md). Rapidly changing run and ownership status lives in `steps/`.

<a id="source-migration"></a>
## 1. Source organization and migration

- The target organization clarified by the author on 2026-09-20 keeps machine mechanisms in L2 and high-level programs primarily in L3. Maintained `.lm1` units are gradually rewritten in `.lm2`, then high-level portions in L3. L1 remains an intermediate L2 → L1 → C99 lowering stage rather than the final source carrier of the graph.
- The interpreter consumes only a constructed L3 graph. The current tree state must not be presented as completion of that migration.
- The historical inspected L1/L2 snapshot used `l1src/` and the sandbox `l2src/` copy at L1 commit `b2a7c98aa59aaf9654f2180e6f2a149e58aa48ee`. The author later required the `l2src` copies to converge; L1 `2a60beb` mirrored the fresh sandbox and `LMX/l2src` matched it. Current state must be rechecked rather than inferred from these hashes.

<a id="l1-status"></a>
## 2. Translator-L1 state

- Historical self-build used `l1src/build_l1.lm1` with generations gen0…gen3. The recorded `L1_PIN.txt` SHA-256 was `4E0B7F5D942C291AFD4C2CEB8FBBA5B20EECC44BF7B455A40D8E564846D80DE7`. Parser units were `parser.lm1`, `p0.h`, `p0.h.lm1`, and `own.lm1`. These are snapshot facts, not a permanent pin.
- Historical `tests/l1/run_*.ps1` runs accepted repeated short declarations, `c.array`, `define`/`ifdef`, and `os: win:/default:`; those runs were not imported into LMX as a normative corpus.
- Features measured by deepseek included value `\` lowering as `->`, assignment not declaring a local, `ulong` being 4 bytes and `size_t` 8 on the measured platform, and `predef:` pulling an entire source. Form `@(TYPE) name` did not parse while `@(TYPE name)` and `@: TYPE name` did; related L1 commit: `18bdab8`. These are implementation observations, not language rules.
- Message field order was checked by `lmx_message_selftest.lm1`. A source comment proposed relaxed loads for `running`/`handoff_ready` without RMW or an extra fence; actual code and memory model must be checked together.
- In the inspected snapshot, `lmx_implements` compared kind/type by address range and `lmx_runtime_implements` matched numeric field positions; both were called only from their own self-tests. The positional walk must be replaced by analytical named-used-path traversal plus mandatory execution of receiving-expression tests. Address classification remains common arena-index infrastructure and must not become a second validator.
- Measured mixa-port parser gaps included `empty colon Frame`, `unsupported statement atom`, and node trailer handling. They are translator work.
- The reserved old `C:` escape and proposed `c.struct`/`c.union` cannot be treated as supported without actual handlers. Implemented L1 `throw`/`catch`/`finally` lowering used a service code and up to eight `long` payload fields; that limitation must not become an L2/L3 rule.
- No source-level `synchronized` receiver handler was found in the inspected `l1trans.lm1` and `l2trans.lm1`. The old `lm_synchronized_enter/leave` illustration is not evidence of emitted code. The reentrant monitor embedded in `lmx_post` provides mutual exclusion for the current mail collection, but does not by itself implement the language's structural receiver.

<a id="l2-status"></a>
## 3. Translator-L2 and machine-surface state

- The inspected `l2trans.lm1` accepted a bounded `.lm2` subset; the snapshot did not establish a complete L2→L1 translator. Kernel low-level operations and support for concrete frontend spellings must be checked separately.
- Placement of atomic handshake flags relative to parent/child arenas remained open; provenance is kept in `steps/l1-l2-migration.md#handshake-flags`.
- Interpreter-frame auxiliary storage should use one reusable standard L2 mechanism suitable for later code rewriting, not a private C allocator belonging only to `lmx_walk`.
- Address lowering in `l2_check_addr`/`l2_prep_addr` distinguished a parameter from graph own data: a parameter emitted `@ l2_p…`, while an own primitive cast stored `l2_q…_from[0]`. Branches existed for `int`, `char`, `size_t`, `unsigned`, `ulong`, and pointer own fields. Own-Array was rejected through `l2_own_is_array`; that is an implementation limit, not withdrawal of the descriptor contract.
- Before the `FABLE-L2-ARG-ADDRESS-DIRTY-20260921-67` slice `l2_collect_asgn_body` created an argument-as-own only for a repeated `int`/`char`/`size_t`/`ulong` type list, and `l2_bind_own` compared a formal's type code with an own field's storage code although these are different number spaces (`unsigned` is 34 and 3): the declared form was refused for `unsigned`, a pointer was never bound at all, and `l2_emit_checkpoint` cleared every dirty mark. Now one function, `l2_own_ty_of_param`, maps a formal's type to the storage code, publication is one emission over a type descriptor (`l2_own_store_helper`, `l2_own_store_rebinds`, `l2_own_store_value`), and the temporally ordered [L3 §11](LMX_semantics.en.md#dynamic) rule is carried by three activation flags `early`/`bound`/`sticky`. Only methods whose body writes `@: x` for a bound parameter have them: `@x` while `x` is unbound sets `early`, the first executed binding line (a declaration or an assignment) decides `sticky`, and a checkpoint publishes on `dirty` or `sticky` and clears only `dirty`. The before-bind, never-bound, after-bind, run-time order and “a declaration binds too” cases are pinned in `tests/unit_arg_addr_sticky.lm2`, types in `unit_arg_addr_types.lm2` and `unit_arg_addr_pointer.lm2`; the run is `tools/l2_harness.ps1`. Found with this slice and left outside it: an explicit write to a `node` path with a field name resolves the name in the first method that has such a field rather than in the current one; a callee with two formals does not accept an `@:` actual; a field made by assignment alone cannot be read through a `node` path. The fourth finding of that slice was closed separately (`FABLE-L2TRANS-CHAR-UCHAR-20260921-86`): the byte handed to `lmx_char_rebind_known` was spelled through `uchar` by three emitters — the publication descriptor of a checkpoint, an explicit write to a `node` path, and the program entry's write to a unit field. That type is defined where the translator itself is built (`l1src/p0.h.lm1`) but not in a generated program unless its author includes `p0` himself; no gate target drives these emitters, so every program that published a `char` own field stopped at the C compiler and nobody saw it. The byte is now spelled the way the kernel spells it, `((cast: (int) x) & 255)`, with no type beyond `int`; the cases are pinned in `tests/unit_char_own_publish.lm2`.
- Negative fixtures `address_array_element.lm2` and `address_array_element_sum.lm2` encoded rejection of element address-taking. After the author's 2026-09-20 clarification that is the wrong L2 expectation: `@array[i]` must obtain the actual element address without an index check. Rejections saying `own array index requires an in-bounds primitive literal` must leave the L2 path. `l2_emit_array_ptr` already extracted descriptor backing while `l2_emit_array_load` materialized a temporary; address lowering must use backing rather than the copy's address.
- `l2_array_local` accepted a narrow `c.array` form: one `[]` head and atoms `char`, name, and numeric extent. This is not the complete `c.array` contract; graph branches `l2_own_*array*`/`l2_emit_array_*` do not automatically extend it.
- C-ABI support in the inspected frontend lived in `l2_cast_type`, `l2_prep_sizeof_name`, `l2_c_door`, and foreign-type checks. Fixtures `unit_cast_ptr_int`, `unit_sizeof_arg`, and `unit_sizeof_own_local` are snapshot evidence but do not replace a fresh run.
- No `synchronized` handler was found in the two inspected translators. Implementing that receiver and later replacing mail's internal enter/leave with the structural form remain separate work; the current mailbox monitor fixes the required semantics without adding translator syntax.
- Inspection of current `lmx_post.lm1` shows that `lmx_post_monitor_enter/leave` are called only for the `inbox` ring: admission, take, count, and the consistent snapshot of unread addresses. The `outbox`/`staged` branches, `LmxMsg.running/success/handoff_ready` flags, `LmxLink.alive` handshake, address service, graph, arena, scheduler, and turn state are outside this monitor. This matches the [normative mailbox boundary](L2_spec_en.md#mailbox); extending the lock beyond it would be a separate defect.
- The currently published `lmx_root_close` does not yet implement the [clarified upper cascade](L2_spec_en.md#root-close): it has no separate overall subtree-close deadline or fatal OS-process path. A correction is being investigated in an isolated scratch tree and is not shared-tree state until its checks are green.

<a id="l3-status"></a>
## 4. L3 interpreter and candidate admission

- Admission code must not be structured as a choice among analytical `implements`, a separate available-graph `RuntimeImplements`, a field named `validate`, or stored evidence. The implementation task is singular: first traverse `uses(Consumer, bVar)` analytically, then execute the nonempty complete Consumer test set in the graph interpreter. Tests cannot repair a negative analytical result.
- The former runtime compatibility failure used `throw: Type(varA, varB, Consumer)`. The exact result/failure interface for the new test set needs a separate decision and must not be obtained by merely renaming the old validator.
- Reusing a test result requires a contract covering identity of candidate, Consumer, and test set, immutability of the checked state, and execution isolation.
- The fourteen guarantee examples do not establish completeness of the current translator. Every implemented case requires its own checks.
- Intermediate host/root transitions in the old implementation must not create a second global registry or indefinite owner outside Messages. Old Java locks and callbacks likewise must not be copied into Mix automatically; ownership and FIFO follow the new model.

<a id="open-design"></a>
## 5. Open design decisions

- Failure representation for the unit-test set and its exact relation to declared `throw`.
- A broadcasting profile for zero extents; the core specification defines positive extents only.
- Final cryptographic receiver names, normalized AlgorithmId/Verifier/Policy Structures, mandatory initial profiles, exact error subtrees, and provider registration.
- Streaming, secret streams, HSM/TPM, KEM/PQC, remote key services, and protected envelopes require separate profiles.

<a id="grammar-extraction"></a>
## 6. Grammar extraction boundaries

Grammar extraction does not establish that either old or new translator implements every rule. The source grammar sketch was incomplete about full update, indexing, type, and relation semantics; missing semantics must not be invented inside the grammar specification.

The author's 2026-09-19 clarification removed the former rejection of an empty vertical body: it is an empty Structure argument, not absent arguments. The old source also conflicts between a flat normal form for mixed inline/vertical continuation (§4.3) and preservation of the Structure boundary on down/up transitions (§§4.2.1, 15.0). That provenance belongs here; the normative outcome belongs in the current grammar.

Implementations whose “zero fields after assembly” check loses an explicitly formed empty vertical body must distinguish Structure field count from receiver argument count. Historical rejection expectations for this form must be replaced by current acceptance checks for `receiver:` with an empty body.

Detailed diagnostics for malformed Mix marks inside strings and the `{#...}` form were not separately defined by the two compared specifications. References from old grammar chapters to Message, ABI, and memory do not themselves become new semantics. Receiver catalogs, numerical libraries, network protocols, and runtime services are outside the common grammar.
