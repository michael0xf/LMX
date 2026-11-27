# LMX runtime-server source evidence

This note records the existing LMX constructs used by the proposed server sources. Paths below are relative to the restored documentation archive (`documentation/docs/`) unless prefixed `package/`. These are source and specification findings, not a successful runtime execution report.

## Existing data and service examples

| Requirement | Existing evidence | Consequence for this patch |
| --- | --- | --- |
| Real tabular LMX example | `spec/patterns/03_domain_and_persistence/examples/lmx/026_table_module.lm3:1–11` declares `[]@: rows`, iterates `rows[i]` and reads `row\quantity` / `row\price`. | `examples/01_table_and_tree.lmx` supplies concrete named rows and retains the same ordinary traversal. |
| Table metadata | `spec/LMX_semantics.en.md:3230–3240`; `core_catalog/catalog/schema.lmx:51–54` (`C99SourceCoverage`, explicit `columns`). | Tables are ordinary Structures. The first column is a row key, column metadata are explicit, and no table parser or automatic global registry is introduced. |
| Ordinary Message call | `spec/patterns/06_async_and_messages/examples/lmx/061_active_object.lm3:1–15`. | Local clients post a selected CODE reference; result routes are ordinary methods. |
| Owner state mutation | `spec/patterns/06_async_and_messages/examples/lmx/060_actor_model.lm3:1–9`, especially `node\total += delta`. | Service replacement writes `node\handler`; agent callbacks find their persistent owner with `parent(node)` and write its graph. Bare assignments would change call-local places. |
| Persistent asynchronous callback owner | `spec/patterns/05_cloud_and_resilience/extended_comparisons/source/lmx/097_retry_library_implementation_generalized.lm3:15–120`. | `LmxServerAgentJob` has nested callback DATA/CODE, persistent state, and normal `post` routes. It contains no second inbox, queue, timer or scheduler. |
| Typed records and constructors | `spec/patterns/LMX_Fn_Receivers/src/containers.lmx:6–23`, `:42–64`. | Models are copied as one grouped Structure, then actual fields are assigned. A typed result such as `return: @LmxServerReceipt` is ordinary LMX. |
| Typed integration contracts without invented implementations | `spec/patterns/LMX_Fn_Receivers/src/kernel_contracts.lmx:1–44`. | Runtime, model, transport and MCP integration are named signatures plus uninitialized typed callable slots. No provider returns fake success. |

## Normative constraints used in the code

1. **A selected callable is the selected Structure itself.** `spec/LMX_semantics.en.md:1670`, `:1696` and the structural launch rule around `:788` distinguish DATA ownership from the CODE being invoked. The handler slot therefore stores `LmxServerDispatch\execute`, not `LmxServerDispatch`. Its reference does not reparent its DATA to the Service.
2. **Signature positions are real.** `spec/LMX_semantics.en.md:1953` requires ordered inputs and result presence/type from the selected CODE's actual parent. Optional inputs remain positions. Provider implementations must not add hidden state parameters and assume they disappear. The sample event sink keeps state in an enclosing owner and gives `Receiver\accept` exactly one `event` input.
3. **Named signature compatibility is not complete call policy.** `spec/LMX_semantics.en.md:1869–1874`, `:393–396` and `:1953` keep finite throws, defaults, requiredness and actual Consumer obligations separate. The additional declared `runtime\admitHandler(candidate; scope)` checks the real concrete call contract, finite recoverable exits and owner/lifetime, then returns the same selected reference. It is called before publishing a replacement. Other providers require full assembly admission. No three-argument `satisfies` against a named signature is falsely called a proof of a throws subset.
4. **`private` preserves its physical written node.** `spec/LMX_semantics.en.md:310`, `:2364` distinguish `S\private\x` from `S\x` and explain the two-way implicit-binding filter. Source reads/writes use the correct paths. `private` is not described as secrecy or access control.
5. **Copy and merge are explicit field streams.** `spec/LMX_semantics.en.md:754–758` and `spec/LMX_semantics_guide.en.md:1040–1159` govern `(copy(Model))`, explicit assignment and real method parents. A grouped copy creates one retained record. An ordinary reference is not an implicit copy or a closure.
6. **Failures preserve their actual kind and data.** `spec/LMX_semantics.en.md:2706–2710` supports shared finite failure lists and selected-operation `throws` metadata. The server's single application exit is `LmxServerPortFailure(@cause)` and every actual provider must be admitted to that policy. Numeric diagnostic fields are placed in an ordinary retained diagnostic Structure; no integer is passed as a reference and no address of an expired numeric local is retained. Implicit runtime failures are not relabelled as normal success.
7. **The runtime codecs are universal kernel receivers.** `spec/LMX_semantics.en.md:3294–3300` defines `sys\toLmx` for current Structures and L3Thread state and `sys\fromLmx` through the shared graph construction path. The user's current clarification fixes the intended contract explicitly: `fromLmx` creates a clean graph suitable for compilation; `toLmx` creates LMX code from any Structure and any L3Thread. The server's `prepareText` and `present`/`inspect` are integrations with those receivers, not additional parsers or serializers.
8. **One parser and one expression grouping mechanism.** `spec/LMX_semantics.en.md:798–800` and `spec/EXPRESSION_ALGORITHM.md` govern the common main parser and `[]` subparser. Server source preparation calls that common mechanism. It does not scan model output for method-name strings or invent a command evaluator.
9. **`post` owns transport correlation and late outcomes.** `spec/LMX_semantics.en.md:3411–3445` requires whole-description preparation, owner-lane execution, real result routes and ordinary retained lifetimes. Timeout is not cancellation. In the server code, asynchronous delivery/failure routes select persistent nested methods, which recover the Job through `parent(node)`; they do not depend on retaining a dispatch stack local. The integration must still prove that the copied Job and parents outlive every pending route.
10. **A model response is a whole command document.** Existing `spec/LMX_semantics.en.md:3692–3833` (§36) requires complete text, normal preparation/admission, explicit placement versus invocation, and actual current-graph result presentation. `ModelAnswer.complete != 1` stops before submission. The general native/MCP command path may return any ordinary result; only the agent profile subsequently admits `LmxServerDecision` before reading `finished`.

## Final source organization

The main unit can be assembled in this order, with ordinary name resolution and no invented module loader. Insert a blank physical root boundary between source files; do not concatenate a nested final line directly with the next file's root header:

1. `package/lmx-runtime-server/src/models.lmx`
2. `package/lmx-runtime-server/src/ports.lmx`
3. `package/lmx-runtime-server/src/core.lmx`
4. `package/lmx-runtime-server/src/agent.lmx`
5. `package/lmx-runtime-server/src/boundaries.lmx`
6. the selected files in `package/lmx-runtime-server/examples/`

The later catalogue extension is an additional independent source file after the common models/ports; it is owned by the catalogue integration task.

`LmxServerService\submitText(source)` and `\submitGraph(graph)` are stable entry references. They read the current physical handler on the service owner's lane and pass its explicit runtime/scope inputs. `\replaceHandler(replacement)` first calls the declared common admission integration, then writes the mutable slot. Already selected old CODE references remain old references. A new ordinary graph method can be interpreted without recompilation; a ready native entry of an older method is neither rewritten nor invalidated by the slot write.

The agent API is `LmxServerAgent\ask(service; model; sink; question; roundLimit; timeoutMs) -> @LmxServerAgentJob`. It uses ordinary `post` to the model, then the stable service entry, then the model again with a linked history containing the real Receipt. `finished`, `budget`, `agent-stopped`, `incomplete-model-answer`, delivery/wait failures and late observations are distinct event kinds. There is one outstanding stage per job, no automatic retry of an uncertain runtime outcome, and no attempt to undo an already running call.

## Validation actually performed

The existing bounded checker was run on the five main source files and seven example files:

```text
mode: STATIC_SOURCE_CHECKS_NOT_P0_NOT_RUNTIME
files: 12
errors: 0
unsupported_forms: 0
c_tokens: 0
```

Report: `lmx_server_static_report.json` in the work directory. The checker verifies only its supported lexical/layout subset, quote shielding and delimiters. It is not P0, a type or admission checker, a compiler, or an interpreter. Runtime/model/transport/MCP providers are intentionally unbound. Protocol conformance, exact admission of the recursive named contracts, provider failure publication, owner/lifetime behavior, native/walker equivalence and real asynchronous late delivery remain integration acceptance work.
