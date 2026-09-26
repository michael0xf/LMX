# Ordinary LMX calls over Message transport: `post` and reply waits

**Task to Fable: update the specification and implementation to the author's latest decision.**  
Companion document: [Russian version](threadMessageAPI.ru.md).  
The filenames `threadMessageAPI.en.md` and `threadMessageAPI.ru.md` are retained for continuity; they do **not** name a new external Thread API.

## 0. Required: replace the previous external-API design

This revision replaces the previous task documents. It describes the required work, not a claim that the live implementation already implements it. The author's final clarification supersedes the intermediate proposals about API arrays, signature dictionaries, and multiple method selection.

**There is already an LMX Structure. Calling it through another Thread must use exactly the ordinary LMX call rules used inside a Thread. Only the transport changes. Do not define or implement the elementary call again in this protocol.**

**`answer` populates a separate sender-owned table of pending replies and their destinations. It does not populate, extend, or shrink a public method API.**

**The multiplicity of `ask` and `answer` belongs to transport and provides the basis for bulk operations. It does not mean that one request executes every method whose signature happens to match.**

Retain the existing `post` syntax, original-message correlation, reply distribution, delivery-state access, timeout callbacks, declared `throws`/`catch`, explicit conversions, and nested incoming argument descriptions. Remove the superseded external-dispatch rules throughout the implementation, documentation, and tests.

In particular, remove from this task:

- A user-graph array treated as a separate exported API and a dictionary derived from it.
- A replacement service table initially populated with the Message's own signature and later extended by `answer`.
- Special postal signature lookup, return-type overload rules, duplicate-signature prohibitions, and API-content-based filtering.
- A bodyless request that automatically enumerates or returns all `sub` entries.
- Automatic execution of all matching recipient methods and the proposed reply-number/total-count mechanism for that execution.
- A new `endturn` scan that executes an invented API array.

These removals concern the abandoned protocol design. They do not remove ordinary Structures, arrays, callables, or any mechanisms already used by normal LMX execution.

**Incoming argument descriptions such as `ms: int: time` MUST be supported by ordinary LMX `implements` and argument binding. This remains a general language requirement, not a timeout-specific feature.** See §8.

## 1. Required: keep three responsibilities separate

| Responsibility | Source of its rules |
| --- | --- |
| Calling the addressed Structure | Existing ordinary LMX call semantics and their existing implementation. |
| Sending requests, delivering results, and distributing a result to explicit destinations | Existing mail transport, extended by the `post` description where needed. |
| Associating expected replies with their destinations and outcome handlers | The sender's separate pending-reply table, associated with original-message identity. |

An external caller addresses the Structure through the available Message transport. The transport must not manufacture an exported-method namespace, inspect a different signature dictionary, or reinterpret the Structure as a list of alternative services.

The ordinary language mechanisms remain responsible for resolving a call, consuming its argument Structure, processing its result, and handling its declared exits. Reuse them. This task does not independently specify which overloads can exist or whether a result type participates in ordinary selection. Any such rule is the same rule as for a local call, not a postal variant.

The same applies to empty/bodyless calls: use ordinary LMX meaning and diagnostics. Do not add automatic API discovery, enumeration, or execution of unrelated child methods.

Here “elementary call” means one ordinary call carried by the transport. It does not promise transactional execution or describe a machine-level atomic instruction.

## 2. Required: `post` remains an ordinary protocol receiver

`post` consumes an ordinary Structure containing the exchange description:

| Branch | Role |
| --- | --- |
| `ask` | One or more explicit calls to send through the transport. |
| `answer` | One or more destinations for the results of those calls; these populate pending-reply state, not a public API. |
| `timeout` | Typed waiting-limit configuration for original sends, outside their argument lists. |
| `undelivered` | Receiving description and body for an original request that was not delivered. |
| `unanswered` | Receiving description and body invoked when the reply wait reaches its configured timeout. |
| `catch` | The ordinary handler required by a queried callable's explicit `throws`. |

For example, `getPixel: x y` uses an explicitly available destination/reference. The transport carries the call; `getPixel` is not a hardcoded kernel operation or a new exported-method name scheme. The same is true of `setRed`, `setGreen`, `setYellow`, and `print`.

The enclosing `post` scopes its requests, answer destinations, configuration, and outcome handlers. `ask` and `answer` remain plural. Their association is expressed by the protocol Structure, not by user-managed request identifiers.

A no-result call can still be written as:

```text
post:
. ask:
. . print: "hello world"
```

In this example `print` is a supplied Message destination whose ordinary call consumes the text and returns no value. Do not synthesize a reply or a successful-delivery acknowledgment merely because the call used the transport.

Preparing a `post` consumes the whole description before releasing its requests: the following `answer`, `timeout`, and handlers must already be associated with the sends. This does not mean blindly executing each branch top to bottom. Reuse normal argument preparation and the existing publication boundary.

The protocol does not introduce a synchronous wait, positional pairing of rows, a join barrier, a transaction across all sends, or automatic retry. Each explicit source call is an ordinary call; grouping and result distribution are transport work.

## 3. Required: `answer` maintains only pending-reply state

### 3.1 A separate table, not a callable API

When the sender prepares `answer`, it records the wait for the corresponding original request and the destinations to which mail must distribute its result. This is a sender-owned waiting table. It is separate from the addressed Structure, its normal callable representation, and the mailbox queue.

Do not initialize that table with the Thread's own signature. Do not insert waiting entries into its public methods or make them discoverable as ordinary externally callable entries. Conversely, do not search the waiting table to resolve a new, unrelated incoming call.

The table must retain the relationships already required by this protocol: the original message's identity, the prepared result destinations, and the applicable settings/handlers. The original formed arguments and timing/status information remain accessible through the original message and existing mail data. This is a statement of required associations, not a prescribed new physical record layout.

Preparing several instances of the same source `post` creates distinct exchange associations. They must not overwrite one another through a global slot keyed only by source name, result type, or destination.

### 3.2 Owner-local updates and existing lifetime rules

The sender adds and services waiting entries on its own single execution lane. Receiving a reply identifies the corresponding wait through the original message, then the transport uses the prepared destinations. Normal completion and release use the existing mail/lifetime mechanisms.

No extra registration acknowledgment, lock, inter-thread visibility protocol, or user `registerListener` call is required for this same-thread bookkeeping. Cross-thread delivery still uses the already implemented mailbox synchronization; do not replace or remove it.

An outstanding handler and its exchange data must remain valid under ordinary LMX construction, composition, and ownership rules. Do not retain a dead stack-local reference or invent a separate closure environment solely for `post`.

Timeout alone does not erase a wait or its routes. Further actions remain user policy, as specified in §6. A handler that only logs does not implicitly withdraw its `answer` destinations.

## 4. Required: plural calls and result fan-out are transport operations

### 4.1 One source call, one result, three destinations

The following illustrates the `ask`/`answer` branches within `post`:

```text
ask:
. getPixel: x y
answer:
. setRed: uint32: rgb
. setGreen: uint32: rgb
. setYellow: uint32: rgb
```

In this fixture, the ordinary `getPixel` call executes once and returns one color. Mail distributes that already computed result to three explicit destinations:

```text
Q1 -> ordinary getPixel call -> R1
                               -> setRed
                               -> setGreen
                               -> setYellow
```

There is one source computation and one original reply, followed by three deliveries. Each destination performs its ordinary LMX call when it consumes the delivered value. The queried method does not rerun and does not implement the fan-out itself.

### 4.2 Three source calls, three results, nine deliveries

```text
ask:
. getPixel: x y
. getPixel: x + 1, y + 1
. getPixel: x + 2, y + 2
answer:
. setRed: uint32: rgb
. setGreen: uint32: rgb
. setYellow: uint32: rgb
```

```text
Q1 -> R1 -> setRed, setGreen, setYellow
Q2 -> R2 -> setRed, setGreen, setYellow
Q3 -> R3 -> setRed, setGreen, setYellow
```

**Three explicit source calls; three source executions; three original replies; nine transport deliveries and consequent destination calls.** There are not nine executions of `getPixel`, and one source call does not scan for several recipient methods.

Q1/Q2/Q3 and R1/R2/R3 are explanatory labels, not additional user-visible identifiers. The mail subsystem keeps the original message address/identity. Replies may arrive in a different order without changing their associations. Answer rows are not zipped with ask rows; every result in this example is sent to the three stated places.

These counts describe the example's application work, separately from any execution performed by existing mandatory admission tests. Copying/sharing of physical reply storage remains subject to existing ownership rules; this task prescribes neither shared mutable state across Messages nor duplication of executable code.

### 4.3 Basis for bulk, not another call semantics

The explicit plural form is the basis for subsequent bulk transport. A transport implementation may group work according to its established mechanisms, while each member retains ordinary call behavior, formed arguments, original-message association, result destinations, and applicable failure/timeout handling.

Do not make the group a barrier or combine its results into a new mandatory result type. Do not require reply ordinals, a total number of internally selected methods, or an all-methods-completed counter. Those were needed only by the abandoned automatic multi-method dispatch proposal.

A source program can explicitly construct further plural exchanges. That is ordinary program/transport composition, not a reason for a single addressed call to acquire hidden multiplicity.

## 5. Required: reuse ordinary validation; do not create a postal type system

The elementary call contract is intentionally not rewritten here. Connect transport preparation and execution to the same existing LMX operations used for local calls. Normal argument formation, `implements`, result consumption, declared failures, and mandatory receiver tests remain the source of truth.

Preserve the already agreed argument-conversion rule. The transport must not reintroduce literal C-signature equality as a preliminary exclusion or invent conversion ranking, a first-match shortcut, an all-matches policy, or an additional duplicate-signature rule. Any validity/selection rule comes from ordinary LMX, identically for both transports.

The descriptions and conversion context are ordinary data explicitly supplied to a concrete Message, including from root. They are not a process-global registry or automatically inherited environment.

### 5.1 Prepare the result routes on the sender side

During `post` preparation, use the normal `implements`/consumption mechanism to establish that each `answer` destination can receive the queried result:

```text
result of getPixel -> value consumed by setRed
result of getPixel -> value consumed by setGreen
result of getPixel -> value consumed by setYellow
```

`uint32: rgb` describes the result being received. It is not a demand that `setRed` return `uint32`; `setRed` may consume the color and return no value.

After preparation, correlation selects the existing wait and its already prepared routes. Do not perform a second postal search for compatible listeners when the result arrives. This does not remove execution of selected conversions, value-dependent range/format checks, or other existing ordinary call obligations.

If the shared implementation is incomplete, repair it once for both local and transported calls. Do not implement one-off acceptance rules for the `getPixel` example.

### 5.2 Preserve declared `throws`

The queried callable's explicit `throws` must be handled by its normal matching `catch` or an already permitted propagation rule. The Message boundary does not erase this obligation. Preserve the declared exit name and payload.

A pre-execution incompatibility is not an `axisOutOfBound` raised by an unexecuted method. Retain the ordinary distinction between call diagnostics, actual nondelivery, and a declared failure during execution. This protocol does not invent a new mapping of all errors to one handler.

## 6. Required: preserve delivery, timeout, and user-policy boundaries

| Event | Transport-facing behavior |
| --- | --- |
| An original request is not delivered | Invoke its associated `undelivered` with the original destination and already formed arguments. |
| A queried call returns a normal result | Associate it with the original request and distribute it through the prepared `answer` routes. |
| A queried call exits through a declared `throw` | Carry the declared exit and payload to the associated ordinary `catch`. |
| The reply wait reaches its timeout | Invoke the associated `unanswered` with the original-request and timing data; user code decides what to do. |
| A receiving executor hangs | Existing Thread supervision, mutual polling, and stopping mechanisms continue to apply. |

The table describes events and routing; it is not a new mutually exclusive terminal-state machine.

Mail sends no successful-delivery ACK to application code. A user that needs delivery state examines the existing delivery flags through its own mail API. A deliberately no-result call must not be forced to produce an application result or treated as unanswered merely because it has no result contract.

`timeout` is a separate branch of `post` and is counted **from sending the original message**, using the existing send timestamp. It is not counted from declaration, argument preparation, receiver admission, method entry, or a display event. A result copied to three destinations does not create three waits for the original computation.

Expiry provides an invocation of `unanswered`, not automatic cancellation or another imposed application decision. User code can inspect the original message, its formed arguments, settings, and delivery/status flags. The protocol must not automatically retry, cancel, suppress a late result or declared failure, remove the result destinations, free a live arena, or set another Thread's completion flag.

In particular, when `unanswered` only logs, a later reply still follows the existing route and mail rules. Do not restore the abandoned first-result/all-selected-methods policy or multiple-reply counting for one ordinary request.

Diagnostics must use the saved, formed arguments of the original send. Re-evaluating `x + 1` after `x` changed would report a different request.

Failure to deliver an already computed result to one `answer` destination is handled under the existing mail rules for that delivery. It does not make the original successful `getPixel` call an undelivered source request. This task introduces no replacement transport-failure protocol.

## 7. Required: reuse Thread execution and the existing mailbox

The queue, `sendMessage`, `receiveMessage`, `endturn`, publication, ownership, reference retention, and cleanup already have agreed contracts. This task connects `post` and pending replies to them; it does not reopen their design.

Incoming execution and reply-associated work run on the receiving owner's lane at the existing processing boundaries. Preparing `answer` is local waiting-table work. Do not add the old scan of an API array or an automatic call of every no-argument/no-result child. A handler runs for its associated event, not merely because it has a particular arity.

Preserve the existing Thread lifecycle, including repeated execution until the user sets `success: 1` and the applicable stop/failure/supervision rules. A final outgoing letter before completion follows the normal successful-turn publication rules. This protocol neither introduces a second entry loop nor changes when state may be safely reclaimed.

Keep direct access to the existing mail API. Preserve the currently agreed iterator selected by address, the variant consuming all available mail, and `0` as the iterator end/null value. Use their actual spelling and selector meaning; do not infer new arguments for `receiveMessage` from this document.

Manual consumption and protocol processing share the same existing mailbox. They must not independently consume the same queued letter twice. This is not a promise of global exactly-once network delivery.

Keep both existing execution arrangements: a Thread serviced without its own OS thread and a Thread with an OS thread. No mode switch, UI-specific entry pair, global scheduler, or new synchronization layer is part of this assignment. The earlier screen/renderer story is motivation, not a mandatory registration framework.

## 8. REQUIRED GENERAL SUPPORT: `ms: int: time`

### 8.1 `int` is a receiver, not a data-path node

The setting is:

```text
timeout: ms: int: time 500
```

`int` consumes the declaration and creates/initializes the typed binding `time`. The resulting setting data is addressed as:

```text
timeout
  ms
    time -> integer value 500
```

```text
timeout\ms\time
```

Do not create an extra `int` data field or use `timeout\ms\int\time`. The source representation of the receiver application and the resulting data structure have different roles. Do not restore the obsolete spelling `ms: int: 500`, which omits the declared binding name.

### 8.2 The incoming description is ordinary structural typing

The full `unanswered` formal description is:

```text
(ms: int: time; getPixel: method; int: x; int: y)
```

**Support `ms: int: time` in incoming argument descriptions through the standard LMX `implements` and normal argument binding.** The `ms` branch remains part of the required structure; `int` supplies the leaf receiver/contract; the received value becomes the handler's formal `time`.

Do not flatten the requirement to a bare integer before matching its structure. Do not solve it with a dedicated duration parser, `Duration` class, mandatory `unit` tag, new primitive, or timeout-only type checker.

An incoming formal has no initializer because its value is supplied by the call. Its binding is not a free-name lookup of the timeout configuration. Apply ordinary LMX formal-name rules; this task introduces no second name-matching policy.

The same support must work for other branch names, leaf receivers, and nesting depths, **both in local calls and in calls delivered by post**. A different semantic branch does not become `ms` merely because both leaves are integers. Any allowed conversion of semantic structure comes from the Message's explicitly supplied conversion context, not from special postal knowledge.

### 8.3 Distinguish the handler argument from the setting

Inside `unanswered`:

```text
time                  # timing value supplied to this handler
timeout\ms\time       # configured limit for this particular post
```

These are distinct bindings. The timing mechanism supplies the value associated with the original send. The elapsed-time example below uses `512` ms from sending while the limit is `500` ms. Do not silently read the setting in place of the handler argument or fetch a different exchange's settings.

This support belongs in the common receiver/argument/`implements` path even if the first regression that exposes it is a timeout handler.

## 9. Required reference example and complete walkthrough

Keep the author's final source form. The English document translates only the `throws` comment; executable notation, paths, and log text match the Russian version.

```text
post:
. ask:
. . getPixel: x y
. . getPixel: x + 1, y + 1
. . getPixel: x + 2, y + 2
. answer:
. . setRed: uint32: rgb
. . setGreen: uint32: rgb
. . setYellow: uint32: rgb
. timeout: ms: int: time 500
. undelivered: (getPixel: method; int: x; int: y)
. . log\error: "undelivered: " method "( x: " x " y: " y " )"
. unanswered: (ms: int: time; getPixel: method; int: x; int: y)
. . log\error:
. . . "unanswered after " time " ms "
. . . method "( x: " x " y: " y " ) timeout: " timeout\ms\time
. . end: error
. catch: axisOutOfBound (int: value; int: number) # required by explicit throws in getPixel
. . println: "axis: " number " value: " value
```

Leading dots and `end: error` retain their ordinary grammar meaning. Neither the example nor this protocol requires a special-case parser.

### 9.1 Preparation and sends

The surrounding Message supplies the addressed Structures, `x`, `y`, the logger/printer, receiver descriptions, and conversion context explicitly. For this fixture, `getPixel` normally returns a value consumable as `uint32` and declares `axisOutOfBound` in `throws`.

Preparing `post` establishes normal call compatibility and the three result routes, constructs its typed timeout data, and installs the corresponding entries in the **pending-reply table**. It does not modify a Thread's callable API.

For illustration, `x = 10` and `y = 20` produce:

| Original message | Addressed call | Formed arguments |
| --- | --- | --- |
| Q1 | `getPixel` | `10, 20` |
| Q2 | `getPixel` | `11, 21` |
| Q3 | `getPixel` | `12, 22` |

Each call uses ordinary LMX behavior. The transport stores its original-message association and starts its configured wait from that message's send time. The explanation's Q labels introduce no source-level IDs.

### 9.2 All calls return in time

Three ordinary `getPixel` executions produce three original color results. Mail places each result at `setRed`, `setGreen`, and `setYellow`: nine deliveries and subsequent destination calls. The waiting records are serviced by the existing reply mechanism; no recipient-method count is requested. The displayed failure handlers do not run.

### 9.3 Q2 is undelivered

`undelivered` receives Q2's original destination as `method` and its saved formed arguments `x = 11`, `y = 21`. It logs that specific request. If Q1 and Q3 succeed, they still produce two original replies and six result deliveries. There is no rollback of the entire `post`.

### 9.4 Q2 reaches the timeout

`unanswered` receives Q2's destination, its saved coordinates, and the nested timing argument bound to local `time`. The log separately reads `timeout\ms\time`, which is `500`.

If the mail/timing mechanism supplies elapsed `time = 512`, the message distinguishes “unanswered after 512 ms” from “timeout: 500”. The origin is sending. This handler only logs. It does not cancel Q2, retire its destinations, or suppress a later result. User code retains access to delivery flags and decides further action through the existing API.

### 9.5 Q2 raises `axisOutOfBound`

The associated `catch` receives `value` and `number` from the declared failure payload. Their meaning comes from `getPixel`'s contract; they are not renamed request coordinates. There is no normal color result from this invocation to distribute. The other independent requests retain their own processing.

The same declared failure exists for an ordinary local call. Transport carries it and preserves its association; it does not define a second exception-selection mechanism.

### 9.6 Nothing inside the addressed graph adds implicit multiplicity

Other callable fields inside an addressed Structure are not an invitation to enumerate them or execute all compatible ones. Whatever the ordinary LMX call does is what this elementary transported call does. In this fixture, all nine downstream deliveries come from the written three-by-three transport arrangement.

## 10. Required implementation work and acceptance tests

### 10.1 Work order

Inspect the live implementation and applicable ordinary-call/mail tests first. Then:

1. Remove the superseded external-API assumptions from this protocol's code and documentation. Do not remove ordinary language machinery needed elsewhere.
2. Connect transported calls to the existing ordinary call/`implements` path. Repair general nested formal support there if needed, with local and postal regressions.
3. Prepare `post` and maintain its sender-owned pending-reply table; do not mutate a public API when adding `answer`.
4. Implement the explicit plural request/result-distribution behavior through the existing transport and original-message identities. Leave it suitable for later bulk grouping without inventing bulk call semantics now.
5. Connect `undelivered`, timeout-from-send `unanswered`, and ordinary declared `catch` to the existing mail/timing mechanism. Preserve user policy and direct mail access.
6. Update the relevant specifications and implementation notes together. Keep both language versions of this assignment aligned.

### 10.2 Observable acceptance tests

| ID | Fixture | Required observation |
| --- | --- | --- |
| T01 | Equivalent local and transported call, with equivalent supplied context | Same ordinary result/state effect or declared exit; the postal path adds transport, not another call resolver. |
| T02 | Existing argument/result selection cases, including any result-type distinction permitted by ordinary LMX | The same cases pass or fail locally and through post. No new postal uniqueness, return-type, or conversion-ranking rule. |
| T03 | Empty/bodyless call | Same ordinary meaning and diagnostics; no automatic listing or execution of all `sub` entries. |
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
| T23 | A final send followed by `success: 1` | Existing successful-turn publication and completion rules are preserved. |
| T24 | Native/interpreted and stepped/dedicated-thread paths supported by the live tree | Same observable call and mail semantics; no new mode or special GUI entry pair. |
| T25 | Explicit plural transport; compare grouping with elementary sends where grouping exists | The same calls, associations, and destinations; no implicit barrier, target enumeration, or change in timeout origin. Future bulk optimization is not required to pass the elementary grouped-source example. |
| T26 | An ordinary deliberately no-result `sub` | No synthetic reply/ACK or spurious missing-result requirement is introduced by the transport. |

Measure source executions, original replies, result deliveries, and waiting-table changes separately. Parser success, successful linking, or an exit code alone does not establish these observations.

## 11. Superseded designs: do not reintroduce them

| Earlier proposal | Rule for this revision |
| --- | --- |
| Thread body/array becomes an exported API dictionary | No separate external API; call the existing Structure normally. |
| Service table starts with the Message signature | No new inbound signature/service table. |
| `answer` adds/removes callable API entries | `answer` maintains only its own pending-reply state and routes. |
| Incoming filtering depends on the presence of plain bodies, `sub`, or `fn` in the API array | No protocol-specific filtering table; reuse ordinary call/admission and existing mail rules. |
| Bodyless request returns every `sub` | No automatic discovery; ordinary empty-call semantics. |
| All signature-compatible recipient methods execute | No hidden target multiplicity; only explicit transport fan-out/grouping. |
| Disallow or allow result-only overloads by a new postal rule | Ordinary LMX alone decides; this task duplicates neither policy. |
| Number replies and precompute how many matched methods will answer | Removed with automatic multi-method dispatch. |
| Scan an API array at every `endturn` | Use the existing Thread execution and mail processing contract. |

Keep successful-delivery flags separate from user results. Keep timeout as an event available to user code, not automatic cancellation. Keep Message-local conversion data explicit. Do not replace the shared language mechanisms with a new RPC framework, promise/future subsystem, global listener registry, unit-type subsystem, or source-name-specific implementation.

## 12. Required deliverables and source priority

Deliver the live implementation patch, aligned specification updates, runnable positive/negative and regression tests, and an execution report stating the exact revision/tree, commands, observed effects, and remaining implementation gaps.

The source order for this assignment is:

1. The author's final decision: ordinary call through another transport; a separate reply-wait table; multiplicity only in explicit transport operations.
2. Retained decisions from the earlier task: `post` branches and reference example, sender-side route checks, original-message correlation, timeout from sending with user-controlled reaction, and standard nested `implements` support.
3. Existing ordinary LMX and mail specifications/implementation for the mechanisms this task reuses.

Background references are `CORE(1).md` §3 and §§5–6, and `LMX_semantics.en.md` §§5–6 and §14. They contain transitional text; apply later accepted core rules rather than reinstating obsolete descriptor or signature behavior. This task does not assert that the live code has been inspected or that this example currently compiles.

The former open-questions list is not restored. Queue order, publication, timing origin, and same-thread waiting-table insertion are not a new design exercise. A genuine contradiction found in the live implementation must be reported as such, with a minimal example, rather than silently resolved by inventing external-call semantics.

**Acceptance criterion: `post` transports ordinary LMX calls, records waits, and distributes results. It does not become a second language for calling Structures.**
