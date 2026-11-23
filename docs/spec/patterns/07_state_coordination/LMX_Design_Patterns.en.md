# LMX: State coordination: Message and shared memory

Java exposes monitors, volatile and TLS; Rust exposes Mutex/RwLock, OnceLock and scoped access. They make explicit which properties LMX replaces through Message ownership rather than obtaining for free.

All six original patterns remain separate. Message-based LMX alternatives preserve the selected observations without pretending to be shared-memory RW locks, DCL fast paths or OS-thread-local storage. Parallelism, affinity and latency differences are stated for each example.

## Files

- [Markdown](LMX_Comparison_07_state_coordination.md)
- [Excel](LMX_Comparison_07_state_coordination.xlsx)
- [PDF](LMX_Comparison_07_state_coordination.pdf)
- [CSV](LMX_Comparison_07_state_coordination.csv)

## Catalog

### 065. [Read-Write Lock](065_read_write_lock_comparision.md)

Reading a consistent snapshot without overlapping a mutation.

**Scenario:** Start at 10. Read, write 20, read again; then consider concurrent read requests.

**Observation:** The sequential trace returns 10,20. Java/Rust permit concurrent readers; the LMX owner serves them serially.

This is a functional alternative for consistent scalar reads, not an implementation of an L3 RW-lock. Parallel access to a large immutable snapshot requires a separate protocol.

### 066. [Double-Checked Locking](066_double_checked_locking_comparision.md)

Safe once-only lazy initialization under concurrent access.

**Scenario:** Two clients concurrently request a resource; the factory builds 42 and counts invocations.

**Observation:** Both receive 42; one factory invocation. Java uses volatile+DCL, Rust OnceLock, and LMX one owner.

LMX needs no double check because concurrent clients serialize at the owner. The mechanism changes while retaining the once-only goal. Java requires volatile for this DCL; Rust uses an established primitive.

### 067. [Guarded Suspension](067_guarded_suspension_comparision.md)

A request receives its result only after a readiness predicate becomes true.

**Scenario:** Two clients wait for a value; publish(7) makes it ready and completes both waits.

**Observation:** No replies before publish; afterwards both clients receive 7. The LMX owner remains able to process publish while requests wait.

Java/Rust release the lock while waiting and recheck the predicate. LMX stores the request and ends its turn so publish can reach the owner: an event-driven guarded wait.

### 068. [Balking](068_balking_comparision.md)

If an action is already underway, another request immediately declines to execute it.

**Scenario:** Start a save, repeat start before finish, finish it, then start again.

**Observation:** start results: 1,0,1. The second request creates no extra work.

Balking refuses rather than retaining a waiter as Guarded Suspension does. LMX checks and changes its flag in one turn; Java/Rust use atomic compare-and-set.

### 069. [Thread-Local Storage](069_thread_local_storage_comparision.md)

Isolating a counter within one execution participant.

**Scenario:** Participant A calls next twice; participant B calls it once.

**Observation:** A receives 1,2; B receives 1. In LMX the participant is a Message; in Java/Rust it is a thread.

Message-local state survives migration to another OS worker between turns. It is a useful task/actor-local alternative, not literal TLS: thread-affine native resources need an OS-thread-affinity policy.

### 070. [Monitor Object](070_monitor_object_comparision.md)

An object protects an invariant across a complete operation on its state.

**Scenario:** Balance is 10. Two clients request withdraw(7); checking and decrementing must be one operation.

**Observation:** Exactly one request succeeds; final balance is 3. Separate read+write requests do not have this property.

A serial turn expresses an invariant-owning object without an application L3 lock. It is not a distributed transaction: another owner does not automatically join the atomic operation.
