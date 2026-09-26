# Migration instruction to Fable: retain `sendMessage` and `receiveMessage` on a shared foundation

**Task: refactor the implementation, not the user's ability to send and receive messages.**

Companion specification: [Ordinary LMX calls over Message transport](threadMessageAPI.en.md).

## 1. Required decision

**Keep `sendMessage` and `receiveMessage`. Implement their existing behavior through the same more basic mechanisms that support `post`.**

This supersedes the suggestion to remove these entry points from user code. They are not automatically deprecated. The simplification is in the implementation and semantic ownership: several useful interfaces use one common implementation rather than maintaining competing versions of messaging.

This is an implementation assignment, not a report that the live source has already been inspected or migrated. Inspect the current functions and tests before choosing extraction boundaries. Reuse working code wherever it already supplies the required operation.

## 2. Required dependency direction

Conceptually:

```text
sendMessage    -----------------\
receiveMessage ------------------+--> shared lower-level Message operations
post           -----------------/         |
                                          +-- existing queue, ownership,
                                          |   publication, and state operations
                                          |
                                          +-- ordinary LMX call machinery
                                          |   when delivering a call
                                          |
                                          +-- sender-owned pending-reply state,
                                              correlation, distribution,
                                              and existing timing hooks
```

This diagram describes responsibilities, not a required new object, class hierarchy, global dispatcher, or set of function names. Each interface uses only the operations it needs. In particular, receiving an ordinary message as data does not inherently invoke its payload or allocate a reply wait.

Do not create a circular chain such as `sendMessage -> post -> sendMessage`. Do not copy a second queue implementation into `post`, or a second call resolver into `receiveMessage`.

Where an old function already delegates to the appropriate primitive, retain it. Where it combines reusable queue/transport work with its public interface, extract that work once and let both the old interface and the new protocol use it. The common operation may be existing code rather than a rewritten replacement.

## 3. What stays, and what it delegates to

| Interface | Preserve | Shared implementation it uses |
| --- | --- | --- |
| `sendMessage` | Its established arguments, result/status behavior, and message meaning | The common preparation/submission and existing delivery/publication operations appropriate to that send |
| `receiveMessage` | Its established selection behavior, iterator contract, consumption semantics, and `0` end/null result | The same underlying mailbox selection/take operations used by transport processing |
| `post` | The agreed `ask`, `answer`, `timeout`, `undelivered`, `unanswered`, and `catch` description | Ordinary call preparation plus shared sending, reply association, distribution, and event delivery |
| Mail-state access | Access to original messages, formed arguments, delivery flags, and relevant waiting state | The existing authoritative mail records, not duplicated status objects |

**`answer` is not a replacement for `receiveMessage`.** It describes what to do with a result associated with an earlier send. `receiveMessage` can still expose the caller's own available mail under its established contract. Both operate over the existing mail system; neither may independently consume a letter already taken by the other.

Preserve the existing address-selected iterator and the existing all-available-mail variant. Do not infer a new selector meaning or assume that the latter is spelled `receiveMessage(0)`. Use the actual implemented and specified forms.

Likewise, do not silently convert an old data-message operation into automatic execution of its contents. Normal receiver context still determines how a Structure is consumed.

## 4. What the common foundation must not duplicate

An addressed Structure is called by the **ordinary LMX call mechanism**. Transport changes how the call reaches its owner, not the rules for selecting, forming, checking, or executing that call.

Reuse ordinary argument/result consumption, `implements`, the explicitly supplied Message-local conversion context, mandatory receiver tests, and declared `throws`/`catch`. Any missing support must be repaired in the shared implementation, with local-call and transported-call regressions.

In particular, preserve general incoming descriptions such as:

```text
ms: int: time
```

They must work through normal structural checking and binding, not a postal-only parser. In the setting:

```text
timeout: ms: int: time 500
```

`int` is the receiver creating the typed binding, and the resulting value is reached as `timeout\ms\time`.

Do not reintroduce an external Thread API dictionary, an API-array scan, postal overload rules, or execution of all signature-compatible methods. Do not expose pending replies as callable methods.

## 5. How the old operations are covered

### Sending without an application result

For an equivalent addressed no-result call, the declarative form can be:

```text
post:
. ask:
. . print: "hello world"
```

The explicit old send and this `post` use the same underlying delivery operations. `post` prepares a call description; the existing explicit interface remains available. No synthetic reply, wait-for-result requirement, or successful-delivery ACK is introduced for a deliberately no-result call.

This example is not an invented replacement signature for `sendMessage` and does not assert that every possible old raw-message use is a callable invocation.

### Requests and result distribution

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
```

Preparation checks the result destinations using ordinary sender-side `implements` and records them in the sender's separate pending-reply table. Mail retains the original message identity and uses it to correlate the result. Users do not supply correlation IDs or write an answer-dispatch loop.

This fixture performs **three source calls, obtains three original results, and makes nine result deliveries**. Distribution is transport work and the basis for later bulk processing. It neither repeats `getPixel` per destination nor searches for additional target methods. It introduces no mandatory barrier or reply-number/total-count protocol.

### Explicit receiving

An existing iterator-based receiving program continues to select and take messages under the same contract. Its implementation delegates to common mailbox operations; `post` does not force the user to replace it with `answer` or callbacks.

Transported-call processing invokes the ordinary call engine for calls. Correlated replies use pending-reply state. Explicit receiving returns what its own contract specifies. These are different uses of shared machinery, not three mailboxes.

## 6. Boundaries to preserve during refactoring

Keep the already agreed queue, synchronization, ownership, publication, lifetime, `endturn`, and supervision rules. Updating the sender's waiting table is ordinary work on its own lane; existing cross-thread mailbox synchronization remains necessary and unchanged.

`timeout` is measured from the original send. Expiry invokes `unanswered`; user code decides what to do using the original data and delivery flags. Logging alone does not cancel the call, remove its answer routes, discard a late result, or free a running recipient's state. Keep `undelivered` and declared `catch` separate from timeout and from successful results.

Preserve normal completion through user-set `success: 1`, including publication of final outgoing work under the existing turn contract. Do not add a second execution loop or require a dedicated OS thread for every participant.

## 7. Migration and evidence

First map the existing send/receive implementation to the shared responsibilities above. Keep old signatures and observable behavior while moving genuinely reusable logic below the interfaces. Connect `post` to those same operations. Then remove only duplicated implementation paths and superseded special cases, not working primitives or public functionality merely because their names are old.

Required regression evidence:

- Existing explicit-send and explicit-receive tests still pass, including address selection, all-mail iteration, empty results, and the `0` terminator.
- Equivalent old-interface and `post` scenarios share delivery/state behavior; consuming a letter through either path does not consume it again through the other.
- A transported call uses the ordinary local-call machinery, including conversions, nested formal descriptions, and declared failures.
- One source result with three destinations is computed once; the three-by-three example gives three source executions and nine result deliveries.
- Concurrent exchanges and out-of-order replies retain their original-message associations. Waiting state is separate from public callable state.
- Timeout starts at sending; a logging-only handler preserves the established handling of later replies. Delivery flags remain accessible.
- Final-send/completion behavior and the supported execution arrangements retain their current contracts.

Report the exact revision and tests, the common operations reused or extracted, which old bodies became thin delegating entry points, and which duplicated paths were removed. Do not claim an adapter is equivalent if it silently loses a formerly supported behavior; preserve that behavior with the common mechanism or identify the concrete mismatch.

**Acceptance criterion: `sendMessage` and `receiveMessage` remain usable, `post` provides the structured protocol, and all three rely on one shared Message foundation and one ordinary LMX call implementation.**
