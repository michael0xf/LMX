# Migrate `send` and `receive` to common mail

Applied migration requirements, reconciled through 2026-11-21. Companion documents are the [`post` contract and T01–T26 matrix](threadMessageAPI.en.md) and [main L3 semantics](../LMX_semantics.en.md#thread-message-api). This specifies required implementation behavior and evidence; it does not claim that migration has already happened.

Historical provenance: the author's 2026-11-10 renaming changed `sendMessage`/`receiveMessage` to `send`/`receive`. “Old” below refers to these existing operations compared with `post`, not to obsolete public names.

## 1. Required decision

Keep user-facing `send` and `receive` with their existing signatures and observable behavior. Their implementations and `post` must use common Message operations; the old names do not become deprecated merely because `post` exists.

## 2. Required dependency direction

All three interfaces delegate downward to the existing queue, ownership, publication, and state operations. Processing a transported call uses the ordinary LMX call machine; waits, correlation, and result routes belong to the sender. Do not create a `send → post → send` cycle, another queue, or another resolver.

Where an old operation already delegates to a suitable primitive, keep it. Extract a common part only where the current body mixes public interface with reusable work; do not replace proven code to create a new object hierarchy.

## 3. What stays, and what it delegates to

`send` keeps its arguments and result/status; `receive` keeps address selection, iteration over all available mail, consumption, and terminal `0`. Do not rename the all-mail form into invented `receive(0)`. `post` keeps structured `ask`, `answer`, `timeout`, `undelivered`, `unanswered`, and `catch`. `answer` does not replace explicit receive: a letter taken by one path cannot be independently consumed by the other.

## 4. What the common foundation must not duplicate

An addressed call uses ordinary selection, arguments, `satisfies`, conversions, tests, results, and `throws`/`catch`. It executes the selected Structure over its actual parent; no transport-specific DATA substitution is allowed. Named signature contracts compare ordered types/result, while structural templates require their written tree. Declaration-receiver arguments, field streams, grouping, and CODE W/E retain their normal contracts. `import`, `copy`, and `merge` always consume CODE arguments in every placement; anonymous Structures and bare references are values rather than implicit calls. `ms: int: time`, `timeout: ms: int: time 500`, and incoming `(ms: int: time)` use the shared parser and namespace. All source receivers stay as written, and terminal primitives are included in the full source graph through their direct `{type value}` representation; a computed RHS is not eagerly evaluated or substituted. Direct receipt of a data Message does not itself execute its contents.

## 5. How the old operations are covered

A deliberate no-result send and equivalent `post` use the same delivery with no synthetic reply/ACK. For results, one source call and three destinations give one execution, one reply, and three deliveries; three calls and three destinations give three executions, three replies, and nine deliveries. Correlation uses the original letter without user IDs, total-reply counts, or hidden method search. Explicit `receive` continues to return messages under its own contract rather than becoming an `answer` handler.

## 6. Boundaries to preserve during refactoring

Preserve FIFO, mailbox synchronization, arena ownership, publication, `endturn`, and lifetime. Timeout starts at the original send; logging in `unanswered` does not cancel the recipient, an `answer` route, or a late result. `undelivered`, timeout, and declared failure remain distinct outcomes. A final send before `success := 1` is published under existing turn rules; no OS thread per participant is required.

## 7. Migration and evidence

First inventory the live send/receive bodies and tests; then move only genuinely common mechanics below the interfaces and connect `post`. Run old explicit-send/receive regressions and [T01–T26](threadMessageAPI.en.md), including local/transported equivalence, fan-out, out-of-order replies, timeout, delivery, no-result, native/walker, and supported Thread modes. Report exact commands and results, extracted common operations, and removed duplicates. An adapter that loses old behavior is not a migration.
