# Thread Message API and the `post` protocol

**Task to Fable: update the specification and implement the agreed model.**
Companion document: [Russian version](threadMessageAPI.ru.md).

## 0. Scope, authority, and expected result

This task consolidates the author's latest decisions from the discussion. It is an implementation assignment, not a claim that the current runtime already implements them. Apply the corrections recorded here rather than earlier, superseded explanations.

The objective is one mechanism: a Thread's user graph supplies its API; ordinary-looking calls become postal requests; the mail subsystem associates results with their original requests and distributes those results to the declared `answer` destinations. All compatibility is the ordinary LMX `implements` mechanism.

Do not introduce a separate RPC object model, a promise/future subsystem, a global listener registry, or a second mail system. Keep the existing mailbox operations available. Ordinary graph construction, composition, ownership, execution, and supervision remain the foundation.

**Particularly important: incoming formal descriptions such as `ms: int: time` MUST be supported through ordinary structural `implements`. This is a general LMX requirement, not a special timeout parser feature.** See §8.

The implementation details that the discussion did not settle are explicitly collected in §12. Reuse an already agreed contract where it resolves them; otherwise report the missing decision rather than silently choosing new semantics. These open details do not invalidate or reopen the confirmed requirements.

## 1. Required: make the user graph the Thread API

### 1.1 One source of API contents

Treat the Thread body/user graph as its API. Its existing array-based structural representation is the source from which an API lookup dictionary is formed. The dictionary is a lookup representation of those entries, not a second independently maintained declaration of what the Thread can do.

The array contains ordinary Structures: executable bodies, declared `sub`/`fn` callables, data used by them, and the handler structures introduced through the protocol. Preserve the ordinary distinction between a Structure's presence as data and its execution in a receiving role.

The API is populated in two explicit ways:

1. Structures and references are explicitly supplied when constructing/composing the Thread's user graph.
2. Preparing `answer` contributes the corresponding reply-listener/destination structures to the sender's API, using the same ordinary graph mechanisms. The mail subsystem records which original requests they belong to.

Use existing construction/`merge` rules for structural changes. Do not add a mandatory `registerMethod`, `registerListener`, or parallel callback registry for the user to maintain. The derived dictionary must reflect the actual graph and preserve every eligible candidate; it must not silently replace a multi-match lookup with first-match dispatch or overwrite another candidate merely because a lookup key is shared.

Settings and handlers supplied by a `post` belong to that particular exchange. Two instances of the same source block must not overwrite each other's reply associations or settings through a hidden global slot.

### 1.2 Object roles, not two special entry points

The drawing discussion motivated this change: a screen and a renderer for a particular figure are different object roles. Create the objects and give them their explicit references. Do not require the earlier special `registerFigure` protocol or turn one object into a mandatory pair of `main`/`paint` entry points.

A Thread still has one execution lane. Existing stepped execution without a dedicated OS thread and execution on an OS thread remain available. This task does not prescribe a new GUI threading framework or a new physical thread for every API entry.

## 2. Required: execute the API on turns and retain direct mail access

At `endturn`, inspect incoming mail and perform the corresponding API work on the owner's execution lane. Execute the API's no-argument, no-result executable structures sequentially in their array order as the recurring work described by the author. Continue the Thread's ordinary cycles until the user sets `success: 1`, subject also to the existing failure/stop/supervision rules.

“No result” means no returned value; it is not a textual test for the absence of a bare `return`. A bare `return` can simply end a `sub` or executable body.

Handler roles remain meaningful. The body associated with `answer`, `undelivered`, `unanswered`, or `catch` runs on its triggering outcome; storing it in the API does not execute it immediately or turn it into an unconditional recurring action. Likewise, a `post` description's settings are not ordinary commands to execute blindly from top to bottom.

A sender does not execute code directly inside a recipient's mutable graph. Incoming work executes on the recipient's lane. A stop request is not proof of completion and does not authorize freeing still-executing state.

Retain `sendMessage` and `receiveMessage` and callable access to their own mailbox. Preserve the currently agreed address-based iterator variant, the variant for receiving all available entries, and `0` as the iterator's end/null result. Use the actual existing call spelling; do not invent a new meaning for the address selector or assume that `receiveMessage(0)` is necessarily the spelling of the all-mail variant.

Manual and API-driven consumption use the same mailbox. An already consumed letter must not independently be consumed again by the other path. This is an ownership/consumption requirement, not a claim of network-wide exactly-once delivery.

A final user message prepared before `success: 1` must follow the normal successful end-of-turn publication rules. Do not discard it merely because the user completes that turn.

## 3. Required: derive incoming filtering from API contents

Use the author's corrected table:

| API contents | Incoming filtering |
| --- | --- |
| Contains ordinary executable Structures with no formal arguments and no result | Accept incoming user mail without signature-based mailbox exclusion: these bodies can themselves process arbitrary mail through `receiveMessage`. |
| Only declared `sub` entries | Full matching of argument contracts **and absence of a return value**, through ordinary `implements`. |
| Only declared `fn` entries | Full matching of input and return contracts, through ordinary `implements`. |

The earlier statement “only `sub` means partial filtering by reply type” was an error and is superseded.

A declared `sub` with an empty argument list is still a declared, fully described callable. Do not classify it as an open arbitrary-mail handler merely because its arity is zero and it returns no value.

Accepting all incoming mail is not permission to reinterpret arbitrary storage or to bypass a later consumer's contract. It means that signature filtering cannot exclude the letter before the arbitrary receiving code gets the opportunity to handle it.

For a mixed declared API containing `sub` and `fn` but no open arbitrary-mail body, apply each candidate's own complete contract; the mixture itself is not an accept-all switch. This is the consequence of the same per-candidate matching rule.

### 3.1 Ordinary incoming request with a body

For a request that is not a correlated reply, find **all** eligible API entries whose input contracts and requested result/no-result contract admit the request. Use ordinary argument formation and `implements`; do not pick only the first match.

One incoming request matching several callable entries may therefore cause several actual method executions and their respective results. This request-side selection is distinct from the postal replication of one already computed reply described in §6.

An incoming request refused by the API filter does not execute a target method and does not trigger that method's `catch`. Where the refusal occurs at delivery, it follows the originating `undelivered` path. A statically established incompatibility remains an ordinary pre-execution diagnostic rather than requiring a deliberately invalid send.

### 3.2 Bodyless request: retain the author's requirement

The author also specified: **for a message without a body, the sender receives all `sub` entries from the API array**.

Preserve this requirement in the specification and cover it in implementation planning. The discussion did not finally establish the returned representation or whether a particular pre-existing API-discovery contract already defines it. Do not silently reinterpret it as “execute every `sub` with no arguments,” including methods that require arguments. The exact operational meaning is listed in §12.

Do not confuse this bodyless-request rule with the iterator end marker `0`, an explicit empty Structure, or a `sub`'s absence of a return value.

## 4. Required: implement `post` as one ordinary protocol receiver

The final source form is a `post` receiving a Structure with the following branches:

| Branch | Role |
| --- | --- |
| `ask` | One or more original requests, written like ordinary calls. |
| `answer` | One or more destinations/listeners for the corresponding computed replies. |
| `timeout` | Explicit typed data configuring the exchange's waiting limit. It is not an argument of a queried method. |
| `undelivered` | A receiving description and body for an originating request that was not delivered/accepted. |
| `unanswered` | A receiving description and body for expiry of the wait for an originating reply. |
| `catch` | Ordinary handling of an explicitly declared `throws` exit of the queried callable. |

For example, in `getPixel: x y`, `getPixel` is an explicitly resolved destination/method reference and `x y` form the request body. Names such as `getPixel`, `setRed`, and `ms` are not new hardcoded kernel operations.

The `ask`/`answer` association is structural, analogous to the already discussed pairing of `if` and `else`. Both `ask` and `answer` are plural. The enclosing `post` makes the scope of their settings and outcomes explicit.

The simplest no-result example is still an ordinary-looking call:

```text
post:
. ask:
. . print: "hello world"
```

Here `print` is an explicitly supplied Message destination, not necessarily a built-in stdout operation. Its `sub` contract accepts the text and produces no return value. Do not manufacture an `answer` or postal acknowledgment merely to complete this send.

Consume and prepare the whole protocol description before dispatching the requests: resolve destinations, check the relevant contracts, prepare argument formation, and associate replies and outcome handlers with the original sends. In particular, `ask` appearing first in the source must not cause a request to escape before the following `answer` and `timeout` branches have been considered.

Do not impose a synchronous wait, a join barrier, positional zip, global transaction, or implicit retry on the entire block. Each original request has its own identity and outcomes.

## 5. Required: use the existing `implements` and conversion mechanism

### 5.1 Request arguments

Arguments are formed by ordinary LMX substitution/assignment, including explicitly available conversions and their value/range contracts. Exact correspondence to the selected callable is required **after argument formation**, not as literal equality of the candidate's original C signature with the caller's initial descriptions.

The conversion/type context is ordinary data explicitly supplied to the concrete Message, including from root. It is not a process-global registry and is not inherited merely because another Message created this one.

### 5.2 Reply destinations are checked on the sender side

When preparing `post`, automatically check that each specified `answer` destination can receive the queried callable's result. In the example, the relevant relation is:

```text
getPixel's result -> input consumed by setRed
getPixel's result -> input consumed by setGreen
getPixel's result -> input consumed by setYellow
```

`uint32: rgb` describes the received result bound as `rgb`. It does not ask what `setRed` itself returns. A `setRed` implemented as `sub` can consume `getPixel`'s result without producing another result.

Once these associations and conversions are prepared, mail delivers along them. Do not add a separate response-time search/re-negotiation to rediscover compatible listeners. This does not remove actual conversion work or value-dependent format/range checks that are part of the already selected ordinary conversion.

Retain receiver-defined unit tests as part of the existing unified admission contract. Do not substitute a physical address-range check or a superficial signature comparison for that mechanism. Analytical checking itself does not run converters or candidate application code; execution of mandated tests and selected conversions retains its existing meaning.

### 5.3 Declared failures

An explicit `throws` declaration of `getPixel` must be handled by the ordinary matching `catch` or an existing permitted propagation contract. Crossing a Message boundary does not erase this obligation. Preserve the exit name and its declared payload; do not relabel it as nondelivery or manufacture a normal value of the return type.

## 6. Required: postal correlation and reply fan-out

The mail subsystem retains the address/identity of the original message and performs correlation. User code must not manufacture request IDs, maintain a correlation map, or dispatch answers manually by comparing IDs.

Retain the necessary references and lifetime under existing mail/ownership rules so that a later response cannot accidentally become associated with a different send or reused address. This requirement does not prescribe a new identity scheme.

### 6.1 One request, one computation, one reply, three placements

```text
ask:
. getPixel: x y
answer:
. setRed: uint32: rgb
. setGreen: uint32: rgb
. setYellow: uint32: rgb
```

In this example there is one selected `getPixel` execution and one original reply. **Mail replicates/distributes that completed reply to three places.** It is not three computations of the pixel and not three original replies.

```text
Q1 -> execute getPixel once -> R1
mail places R1 at setRed, setGreen, and setYellow
```

### 6.2 Three requests, three original replies, nine placements

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

**Three original requests; three application executions; three original replies; nine postal placements.** The receiving destinations perform their own work when they consume those deliveries. Do not confuse that later work with re-executing the queried method.

Each original reply remains associated with its own Q1/Q2/Q3. The destinations are not paired with requests by row number. Results need not be accumulated until every query finishes.

For a request matching multiple callable entries at the target, count the actual responses those entries produce first; only then apply the prepared destination fan-out to each response. Fan-out itself never multiplies the source computation.

Counts here describe application requests after preparation, not any separate invocations performed by mandatory admission tests. The memory representation of replicated deliveries is an implementation matter governed by existing copying/ownership rules; do not assume cross-Message sharing of mutable storage or require copying executable bodies.

## 7. Required: distinguish delivery, a result, `throw`, and waiting expiry

| Event | Required interpretation |
| --- | --- |
| Original request not delivered/accepted | Invoke its associated `undelivered` at the sender with the original destination and formed request arguments. |
| Queried `fn` returns normally | Produce its result once; mail associates and distributes it through `answer`. |
| Queried callable exits by declared `throw` | Route the declared exit and payload to the ordinary associated `catch`. |
| Reply wait expires under `timeout` | Trigger `unanswered` for that originating request, according to the agreed timeout policy. |
| Recipient hangs or fails to progress | Existing Thread supervision, mutual polling, and stopping mechanisms remain responsible. A query timeout is not proof of the recipient's death. |

Mail does **not** send its own delivery-success acknowledgments to user code. A user that needs delivery state examines the existing flags through its own mail API. `answer` is for a computed user-level reply, not a fabricated postal ACK.

A normally terminating, well-formed `fn` returns its result or exits through the applicable declared failure mechanism; “completed successfully but silently forgot the result” is not an additional normal outcome. Conversely, an ordinary `sub` is deliberately no-result and must not need a synthetic result to count as successfully executed.

Use the already formed source arguments in diagnostics. Do not re-evaluate `x + 1` after the sender's `x` has changed.

`timeout` belongs to `post`, outside `ask`. Replicating one reply to three destinations does not create three new waits for the original computation. Timeout does not cancel or repeat the queried method, free its live arena, or set another participant's completion flag.

The start of the clock, the decisive reply-arrival boundary, late replies, and the diagnostic meaning of handler `time` were not finally chosen by the author; see §12. Do not silently promote a previous assistant suggestion into an agreed rule.

## 8. REQUIRED GENERAL SUPPORT: nested typed incoming arguments

### 8.1 `int` is a receiver, not a data-path variable

The final setting is:

```text
timeout: ms: int: time 500
```

`int` consumes the declaration and creates/initializes the typed binding `time`. The setting's data path is:

```text
timeout
  ms
    time -> integer value 500
```

Therefore the value is addressed as:

```text
timeout\ms\time
```

It is not addressed through a fabricated `int` child. The source graph may represent the `int` receiver application; this must not be confused with the resulting data layout. Do not revert to `ms: int: 500`: the final declaration explicitly supplies the binding name `time`.

### 8.2 Formal description uses the same general mechanism

The handler formal is:

```text
(ms: int: time; getPixel: method; int: x; int: y)
```

**Implement `ms: int: time` as a normal nested structural argument description.** The receiving contract includes the `ms` branch and its integer-valued binding. Ordinary `implements` checks the required structure and admissible leaf consumption; normal argument binding makes the received value available as local `time` in the handler.

Do not flatten the description to an unqualified `int` before structural checking. Do not require a new `Duration`, a mandatory `unit` tag, a privileged milliseconds class, or an external units subsystem to accept this form.

The incoming formal has no initializer because its value is supplied by the actual message. `time` is a formal binding; it is not a free lookup that should accidentally read the timeout setting. Formal-name matching/normalization must follow ordinary LMX rules rather than a one-off timeout rule.

Generalize the support to other branch names, leaf receivers, and nesting depths. An unrelated branch with an integer leaf is not automatically `ms`; a transition between such semantic branches is allowed only if explicitly supplied by the Message's existing conversion context. A primitive numeric conversion alone does not rename structural roles.

### 8.3 Two different accesses in the final log

Inside `unanswered`:

```text
time                  # value received by this handler
timeout\ms\time       # configured value in this particular post
```

These must remain distinct. The handler must retain access to the settings of its own exchange, not those of the last `post` executed anywhere in the process.

The discussion suggested using measured elapsed waiting time for the handler argument, with `500` remaining the configured limit. That diagnostic interpretation needs to be pinned to the actual timing contract; the structural support and distinct bindings are required regardless of that choice.

## 9. Required reference example

Preserve this source form. Only the explanatory `throws` comment is translated in this English document; the operations, argument structures, paths, and logging text are unchanged.

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

Leading dots express nesting. `end: error` is the author's explicit closure of the logging expression. Preserve the example's nested receiver forms and ordinary explicit-close handling; do not invent a special parser solely for this example.

### 9.1 Preparation

The surrounding Message explicitly provides the destinations, `x`, `y`, the logger/printer, type/receiver descriptions, and the conversion context. `post` obtains the timeout setting, the three source calls, the three reply destinations, and the associated handlers.

For illustration, if the current coordinates are `x = 10` and `y = 20`, argument formation produces:

| Original request | Target | Formed arguments |
| --- | --- | --- |
| Q1 | `getPixel` | `10, 20` |
| Q2 | `getPixel` | `11, 21` |
| Q3 | `getPixel` | `12, 22` |

Q1/Q2/Q3 are explanatory labels, not new user-visible identifier syntax. Mail uses original-message identity. The settings and listener associations must be ready before requests are dispatched.

Check each request against the selected target contract and check each requested result route through standard sender-side `implements`. For this example assume the declared `getPixel` result is consumable as `uint32` and the shown `axisOutOfBound` is among its explicit `throws`.

### 9.2 All queries succeed

Each queried execution returns one color. Mail distributes each returned color to `setRed`, `setGreen`, and `setYellow`. Total: three source results and nine placements. Neither failure handler nor the shown `catch` executes.

### 9.3 Q2 is undelivered

`undelivered` receives the original `getPixel` destination as `method` and Q2's formed `x = 11`, `y = 21`. It logs that request without recomputing its arguments. If Q1 and Q3 succeed, they still produce two original results and six placements. Failure of Q2 does not turn the entire `post` into a rolled-back transaction.

### 9.4 Q2 exceeds its waiting limit

`unanswered` receives Q2's original destination and formed coordinates, plus the nested `ms` argument bound to local `time`. The log also reads the exchange setting through `timeout\ms\time`, yielding `500`.

If the elapsed-time interpretation is adopted and mail supplies `time = 512`, the log distinguishes “unanswered after 512 ms” from “timeout: 500”. This numerical trace illustrates that interpretation; it does not select the clock origin or late-reply policy on the author's behalf.

### 9.5 Q2 raises `axisOutOfBound`

The associated `catch` receives `value` and `number` from the declared throw payload. These are not aliases for request `x` and `y`: they have the meaning assigned by `getPixel`'s failure contract. That execution has no normal color result to distribute.

A signature-filtered rejection before method execution is a different event and must not pretend that `axisOutOfBound` was thrown.

### 9.6 Several compatible target methods

Outside the single-`getPixel` fixture, an incoming non-reply request can match multiple API entries. Each selected method executes according to its contract. Every actual normal reply keeps the source-request association and is distributed by mail to its already admitted destinations. Do not introduce first-match-only dispatch or use reply replication as a reason to execute a source method again.

## 10. Implementation work and acceptance tests

### 10.1 Work order

Inspect the live source and current tests first. Then:

1. Implement/repair general nested formal descriptions and structural binding in ordinary `implements` and argument formation, independently of the timeout feature.
2. Make the Thread user array the API source; derive/update lookup without a second authoritative registry.
3. Implement the corrected filtering cases, multiple eligible targets, turn-driven execution, and coexistence with explicit mailbox consumption.
4. Implement preparation of `post`, automatic sender-side result compatibility, `answer` insertion, and original-request association.
5. Implement postal reply replication, `undelivered`, and preservation of declared `throw`/`catch` behavior.
6. Connect timeout handling using the agreed existing timing model; resolve only the genuinely missing decisions in §12 before claiming those cases complete.
7. Update the relevant L3/L2/L1 documentation and kernel notes together. Keep both language versions of this task aligned when recording decisions.

### 10.2 Minimum observable tests

| ID | Fixture | Required observation |
| --- | --- | --- |
| T01 | API created from explicitly supplied Structures | Dictionary represents those entries; no separate user registration is needed. |
| T02 | Prepare `answer` | Listener/destination structures and their original-request associations exist before dispatch. |
| T03 | Two live instances of the same `post` | Answers and settings do not cross between instances. |
| T04 | API with an open ordinary executable body | An otherwise unmatched letter can enter the mailbox for manual handling. |
| T05 | Only `sub`, including a zero-argument `sub` | Full argument/no-result filtering; no automatic accept-all and no synthetic reply. |
| T06 | Only `fn` | Full input/result filtering; a rejected request does not execute the target body. |
| T07 | Multiple compatible API entries | All eligible entries are retained and selected, not just the first. |
| T08 | Incompatible declared result route | Normal preparation-time incompatibility is reported; no later reply-time listener guessing. |
| T09 | Allowed conversion and out-of-range value | Existing conversion is used; an invalid value does not bypass range/format rules. |
| T10 | One request and three destinations | One application execution, one original reply, three placements. |
| T11 | Three requests and three destinations | Three application executions, three original replies, nine placements. |
| T12 | Replies arrive in a different order | Each retains its originating request and correct destinations. |
| T13 | Undelivered second request, sender changes `x/y` later | Handler receives the second request's already formed original arguments. |
| T14 | Declared `axisOutOfBound` | Correct sender `catch` and payload; no fabricated successful color reply. |
| T15 | `timeout: ms: int: time 500` | The data value is at `timeout\ms\time`; `int` is not a data-path node. |
| T16 | Incoming `(ms: int: time)` | Structural check preserves `ms`; value binds to handler-local `time`. |
| T17 | Same nested mechanism with a different branch/leaf type | General support, with no hardcoded `ms`, `timeout`, or `uint32` branch. |
| T18 | Missing/different semantic branch | Refusal unless the existing explicit context admits the required structural conversion. |
| T19 | Handler `time` differs from timeout setting | Log reads both distinct values from the correct sources. |
| T20 | Expiry, timely reply, late reply, and boundary race | Behavior matches the explicitly settled timer policy; no accidental duplicate triggering. |
| T21 | Manual receive and automatic API handling | One letter is not consumed twice. |
| T22 | Triggered handlers with no ordinary inputs/results | No execution at registration or on unrelated turns. |
| T23 | Final send followed by `success: 1` | Final outgoing work follows normal publication; no further user turns are started. |
| T24 | Stepped/native/interpreted executions supported by the tree | Same observable API/mail semantics, without restoring a Thread mode switch. |
| T25 | Bodyless request | Conforms to the author's “all sub” rule once its precise payload contract is settled. |

Tests of timeout edge cases and bodyless replies remain explicitly pending until their unresolved contracts are settled. Do not call a build-only or parser-only fixture proof of runtime behavior.

## 11. Superseded ideas and prohibited substitutions

- No “`sub` only checks a return type”; it checks arguments and the absence of a returned value.
- No user-level postal ACK inserted into `answer`.
- No repeated `getPixel` execution to service multiple reply destinations.
- No user-managed correlation IDs or callback-dispatch loops in place of mail's association.
- No second response-time compatibility subsystem after sender-side preparation.
- No `timeout` argument added to `getPixel`, and no timeout setting hidden in the `ask` call head.
- No `int` variable/field inserted in `timeout\ms\time`.
- No flattening of `ms: int: time` to a bare integer contract.
- No new primitive unit class, mandatory nominal wrapper, or global conversion table.
- No special source spelling, API name, or C-signature comparison that bypasses general LMX rules.
- No automatic retry, cancellation, heap release, or fabricated successful result on timeout.
- No separate public method/listener registration or mandatory dual-entry GUI object restored from the earlier draft.

## 12. Decisions not finally fixed in the discussion

These are specification completion points, not invitations to redesign the agreed mechanism.

**O1 — Bodyless request.** The sender receives all `sub` entries. Confirm the exact representation and whether the existing reflection/discovery protocol already defines it, including the distinction from an explicitly empty argument body.

**O2 — Timing and diagnostics.** Confirm the start phase of the timeout (preparation, publication, admission, or another already defined boundary), the moment a reply satisfies the wait, and what local handler `time` measures. “Start at publication” and “report elapsed time” were assistant proposals, not explicit final author decisions. Specify how one configured timeout applies if one request selects multiple result-producing methods. Intentionally no-result `sub` calls must not become failures merely for producing no result.

**O3 — Late outcomes.** Confirm treatment of a reply/declared throw arriving after `unanswered`, the boundary race with expiry, and cleanup of the corresponding listeners. The earlier suggestion to discard late replies was not a final author decision. Failure to deliver an already produced reply to one answer destination is not proof that the original `getPixel` request was undelivered; reuse the mail system's applicable failure policy.

**O4 — Turn ordering and listener lifetime.** Reconcile the exact ordering of incoming handling, ordinary no-argument/no-result bodies, API changes, outgoing publication, and completion with the current kernel contract. Specify when newly inserted handlers become visible, which pending handlers survive which turns, and how original-message references are retired. Do not invent recursive re-entry into another Thread as a shortcut.

## 13. Deliverables and reference map

Deliver a coherent patch to the live implementation and relevant specifications, runnable positive and negative tests, and an implementation report listing exact revision/tree, test commands, actual results, and remaining mismatches. Report request-execution counts, original-reply counts, and placement counts separately. A green exit code alone is not proof that a handler or queried method executed.

Background documents inspected for this task:

- `CORE(1).md`, §3: ordinary Structures, code/data execution roles, native entry, and callable composition.
- `CORE(1).md`, §§5–6: Thread lifecycle, successful-turn publication, mailbox ownership, and existing supervision.
- `LMX_semantics.en.md`, §§5–6: explicit descriptions, conversions, structural `implements`, and mandatory receiver tests.
- `LMX_semantics.en.md`, §14: declared `throws` and ordinary `catch` payload handling.

These uploaded documents contain transitional and older text. In particular, the old literal-equality callable-signature wording must not override the later agreed argument-formation/conversion rule; old `main`/`paint` draft scaffolding is not part of this task. Implement the author's decisions, not a reconstruction of a familiar external RPC framework.
