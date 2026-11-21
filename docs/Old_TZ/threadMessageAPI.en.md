# Ordinary LMX calls over Message transport: `post` and reply waits

Applied transport requirements, reconciled through 2026-11-21. The governing contract is [L3 §28](../LMX_semantics.en.md#thread-message-api); migration of the old entry points has a [separate instruction](threadMessageAPI_migration.en.md). This document retains the detailed acceptance matrix. Its directory name does not create an alternative or optional Thread API, and no test success is asserted.

## 0. Required: replace the previous external-API design

`post` describes ordinary LMX calls over existing Message transport. There is no exported method dictionary, enumeration of every matching callable, or separate postal call system.

## 1. Required: keep three responsibilities separate

The ordinary LMX machine selects and executes the addressed call; mail carries its formed request and result; the sender keeps waits and result routes. These responsibilities create neither a second program graph nor another mailbox.

## 2. Required: `post` remains an ordinary protocol receiver

`ask` contains explicitly addressed calls, `answer` names result destinations, `timeout` configures the wait, and `undelivered`, `unanswered`, and `catch` handle the corresponding outcomes. The entire description is bound before sending. The addressed Structure does not expose an enumerable method list for `post`; every `ask` is the same ordinary call, with the same inputs and exits, as a local call.

## 3. Required: `answer` maintains only pending-reply state

`answer` populates separate sender-owned waiting state; it neither declares a public recipient method nor replaces `receive`. Original-letter identity correlates a reply with its wait without user-supplied IDs or reply ordinals. Updates to this state belong to the sender and follow existing ownership and lifetime rules.

## 4. Required: plural calls and result fan-out are transport operations

For M explicit `ask` calls and N `answer` destinations there are M source executions, M original results, and, when all arrive, M×N result deliveries. In particular, one `getPixel` and three destinations give 1/1/3; three requests and three destinations give 3/3/9. Each result recipient then performs its own ordinary call. Fan-out does not rerun `getPixel`, enumerate recipient methods, or introduce an implicit barrier; bulk optimization is not required by the semantics.

## 5. Required: reuse ordinary validation; do not create a postal type system

Arguments, `implements`, available conversions, tests, declared `throws`, and `catch` use the ordinary local-call mechanisms. The selected executable Structure keeps its actual DATA parent. Named `fn: name data` requirements compare ordered input types and result; explicitly supplied structural templates require their whole described tree. Place-declaration receiver arguments preserve their DATA forms and do not run initializers merely during supply. Field-stream arguments and written grouping follow the same ordinary CODE W/E selection as local calls. `import`, `copy`, and `merge` always use CODE arguments, including inside DATA; bare references/anonymous Structures remain values and explicit source calls execute on consumption. Result routes are prepared on the sender before sending; incompatibility is refused there rather than triggering listener search. A declared failure and payload are not replaced by a normal result or delivery failure. Transport does not extend an expired activation's lifetime merely by retaining a reference.

## 6. Required: preserve delivery, timeout, and user-policy boundaries

`undelivered` is a delivery refusal before execution; `unanswered` is timed from the original send. Its handler receives the original letter's already formed arguments and status even if the sender later changes variables. Logging alone does not cancel recipient work, `answer` routes, or a late result. Delivery refusal, wait expiration, and declared `throw` are distinct outcomes. An ordinary callable with no result declaration creates no synthetic reply or ACK. There is no executable `sub`.

## 7. Required: reuse Thread execution and the existing mailbox

`post`, explicit send, and explicit receive use the same queue, ownership, publication, and state operations. One letter cannot be taken independently by two routes. No second loop, GUI entry point, global dispatcher, or OS thread for every `post` is required; supported native/walker and stepped/threaded modes must agree observably.

## 8. REQUIRED GENERAL SUPPORT: `ms: int: time`

In `timeout: ms: int: time 500`, `timeout` and `ms` remain written structural forms. The terminal primitive declaration `time` has the direct `{type value}` representation, so its source path is `timeout\ms\time`, without an extra `int` node. This is the primitive leaf's physical source representation, included in the complete graph; it does not permit evaluating arbitrary RHS forms or flattening receivers. Namespace computations and admission leave the clean source graph intact. Incoming `(ms: int: time)` binds through ordinary structural checking. Handler `time` and configured timeout `time` are distinct places. Other names and deeper structures use the same algorithm; no postal parser is added.

## 9. Reference outcomes

Rows T10–T20 below fix the reference outcomes: one or three `getPixel` calls, out-of-order replies, undelivered Q2, timed-out Q2, declared `axisOutOfBound`, and a late result. A handler receives its own original letter's arguments. The addressed graph adds no hidden calls.

## 10. Required implementation work and acceptance tests

### 10.1 Work order

Locate the current common call and mail mechanisms, connect `post` to them, and migrate `send`/`receive` without changing their public behavior. Exercise equivalent local and transported scenarios; count source executions, replies, deliveries, and wait-state changes separately. Verify the general nested declaration case in §8 through the shared parser and namespace. A parser success or historical self-build does not establish transport behavior.

### 10.2 Observable acceptance tests

| ID | Fixture | Required observation |
| --- | --- | --- |
| T01 | Equivalent local and transported call, with equivalent supplied context | Same ordinary result/state effect or declared exit; the postal path adds transport, not another call resolver. |
| T02 | Existing argument/result selection cases, including any result-type distinction permitted by ordinary LMX | The same cases pass or fail locally and through post. No new postal uniqueness, return-type, or conversion-ranking rule. |
| T03 | Empty/bodyless call | Same ordinary meaning and diagnostics; no automatic listing or execution of unrelated callable entries. |
| T04 | Preparing an `answer` | Only the separate waiting state is populated; no exported methods or API dictionary are added. |
| T05 | Two live instances of the same source `post` | Original requests, result routes, and settings do not cross between instances. |
| T06 | Adding and completing waits | Existing owner-local/lifetime mechanisms are used; no new registration handshake or same-thread lock, no stale association to a reused message. |
| T07 | An addressed Structure also contains unrelated compatible callables | No protocol-level enumeration or all-matches execution; behavior agrees with the ordinary call. |
| T08 | Incompatible declared `answer` destination | Ordinary sender-side preparation reports incompatibility; no later search for substitute listeners. |
| T09 | Allowed conversion and a value-dependent format/range failure | Normal conversion/check behavior is preserved; no postal reinterpretation or bypass. |
| T10 | One `getPixel` request and three answer destinations | One source execution, one original reply, three result deliveries. |
| T11 | Three `getPixel` requests and three destinations | Three source executions, three original replies, nine result deliveries. |
| T12 | Replies arrive out of order | Original-message correlation preserves the correct waits/routes without user IDs or reply ordinal/total fields. |
| T13 | Q2 is undelivered and the sender later changes `x/y` | The handler receives Q2's already formed original arguments. |
| T14 | Declared `axisOutOfBound` | Ordinary matching `catch` receives the declared payload; no normal color or fabricated delivery failure replaces it. |
| T15 | `timeout: ms: int: time 500` | Setting is readable as `timeout\ms\time`; `int` is a receiver, not an extra data node. |
| T16 | Incoming `(ms: int: time)` in local and postal calls | Ordinary structural checking preserves `ms` and binds the received value to local `time`. |
| T17 | Different branch names, leaf receivers, and greater nesting | The same general argument mechanism works without hardcoded timeout/unit cases. |
| T18 | Missing/different semantic branch | Ordinary rejection unless the explicitly supplied conversion context admits the necessary structural conversion. |
| T19 | Handler `time` differs from the configured timeout | Both sources remain distinct and refer to the correct exchange. |
| T20 | Timeout from sending; handler logs; result arrives later | `unanswered` sees original data/status. Logging alone neither cancels the call nor suppresses its later result. |
| T21 | Direct receive and protocol processing | Existing queue/publication/lifetime rules are preserved; the same queued letter is not consumed independently twice. |
| T22 | A waiting handler has no ordinary arguments/result | It is triggered by its exchange event, not by a scan of nullary API methods or an unrelated turn. |
| T23 | A final send followed by `success := 1` | Existing successful-turn publication and completion rules are preserved. |
| T24 | Native/interpreted and stepped/dedicated-thread paths supported by the live tree | Same observable call and mail semantics; no new mode or special GUI entry pair. |
| T25 | Explicit plural transport; compare grouping with elementary sends where grouping exists | The same calls, associations, and destinations; no implicit barrier, target enumeration, or change in timeout origin. Future bulk optimization is not required to pass the elementary grouped-source example. |
| T26 | An ordinary deliberately no-result callable | No synthetic reply/ACK or spurious missing-result requirement is introduced by the transport. |

Implementation acceptance records actual evidence for T01–T26 and applicable native/interpreter modes. Test gaps are reported as gaps; this document review does not imply that a runtime, transport fixture, or mutation test was run.

## 11. Superseded designs: do not reintroduce them

Do not revive an external Thread API dictionary, reply registration as a callable, all-matches execution, user reply IDs, a second mailbox, a second resolver, or a `send → post → send` cycle. This does not constrain future optimization of the common mail machinery.

## 12. Required deliverables and source priority

Retain exact commands and results for T01–T26, local/transported and native/walker comparisons, and old send/receive regressions. In a conflict with current L3 rules, the [main semantics](../LMX_semantics.en.md#thread-message-api) governs over a historical example in this instruction.
