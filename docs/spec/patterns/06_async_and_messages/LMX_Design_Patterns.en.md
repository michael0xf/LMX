# LMX: Asynchrony, workers and Message

Go illustrates channels and goroutines; Erlang illustrates isolated processes, mail and OTP supervision. They are characteristic controls for LMX Message. Comparisons distinguish logical workers, OS threads, readiness and completed I/O.

15 comparisons cover basic workers/Message, structured concurrency, supervision, MapReduce and four explicit application protocols 109–112. Message keeps ordinary execution; physically blocking native operations remain at the L2 boundary.

## Files

Markdown and CSV cover all 15 comparisons. The XLSX and PDF in this directory belong to the earlier edition with 11 comparisons.

- [Markdown](LMX_Comparison_06_async_and_messages.md)
- [Excel](LMX_Comparison_06_async_and_messages.xlsx)
- [PDF](LMX_Comparison_06_async_and_messages.pdf)
- [CSV](LMX_Comparison_06_async_and_messages.csv)

## Catalog

### 058. [Thread Pool](058_thread_pool_comparision.md)

A bounded set of workers is reused for a sequence of jobs.

**Scenario:** Two workers process four jobs 1,2,3,4, computing their squares.

**Observation:** The result multiset is {1,4,9,16}; no more than two workers are active. Reply order is unspecified.

LMX bounds logical workers; the ordinary Thread scheduler determines OS-thread mapping. Go goroutines and Erlang processes likewise are not dedicated OS threads.

### 059. [Producer-Consumer](059_producer_consumer_comparision.md)

A producer and consumer communicate through a queue while preserving one sender order.

**Scenario:** One producer sends 1,2,3 and then finish. The consumer sums the values.

**Observation:** After finish the result is 6; each item is consumed once in this failure-free local scenario.

LMX and Erlang make the consumer an owner of state; Go uses a channel between producer and caller goroutines. The Go buffer is bounded at two; the base mailbox does not acquire that limit automatically.

### 060. [Actor Model](060_actor_model_comparision.md)

An isolated state owner receives complete operations through messages.

**Scenario:** Two clients send add(2) and add(5) to one counter initially at zero.

**Observation:** After both operations are confirmed complete, read returns 7 in either admission order.

Message directly realizes this actor model: one mutable-graph owner and serial execution. Structural callables and transport do not create a shared mutable heap across owners.

### 061. [Active Object](061_active_object_comparision.md)

Invocation queues an operation for its owner and is separated from execution.

**Scenario:** The client submits compute(6); a separate executor doubles it and delivers 12.

**Observation:** Submit does not execute compute on the client lane; one result 12 is delivered.

LMX already specifies transport of ordinary calls through post. Go uses a request/reply object; Erlang uses an envelope with Ref. Result destinations are not rediscovered through listener enumeration.

### 062. [Reactor](062_reactor_comparision.md)

Descriptor readiness triggers a handler that performs a nonblocking read itself.

**Scenario:** A provider reports ready(fd=3); ReadReady(3) returns 2 bytes, then would-block=0.

**Observation:** The first readiness event performs a read and emits sink(2); would-block does not close the connection.

An LMX readiness notification becomes a Message. The Reactor distinction is preserved: the handler reads actual bytes after notification. Go/Erlang loops show the same adapter boundary.

### 063. [Proactor](063_proactor_comparision.md)

Reading is initiated in advance; the handler receives an already completed result.

**Scenario:** SubmitRead(fd=3,token=7), then completion(7,2). The handler does not perform another read.

**Observation:** Exactly one submit and sink(2); a completion with a different token is ignored.

It differs from Reactor in when I/O happens and what the notification contains. An LMX Message does not itself turn a readiness provider into a completion provider.

### 064. [Future / Promise](064_future_promise_comparision.md)

A once-completed result is available to current waiters and later readers.

**Scenario:** Two clients request the result before resolve(7), and a third after it. A second resolve(9) is rejected.

**Observation:** All three clients receive 7; resolve accepts only the first value.

LMX/Erlang retain waiters at the owner. Go close(done) publishes the value and releases readers under channel synchronization; it is not polling.

### 071. [Half-Sync / Half-Async](071_half_sync_half_async_comparision.md)

Asynchronous ingress is separated by a queue from synchronous processing and response delivery.

**Scenario:** Ingress delivers frames 3 and 4; a worker computes each square synchronously; the writer receives 9 and 16.

**Observation:** Processing does not run inside the I/O callback; the writer receives 9,16.

Independent Messages and mail express the role separation. A Go channel connects the async-facing layer to a synchronous worker; Erlang separates the worker process from the sender.

### 088. [Structured Concurrency](088_structured_concurrency_comparision.md)

A parent bounds two child tasks to its scope and waits for both even after a failure.

**Scenario:** Children return 2 and 3: result 5. If one fails, the other receives a stop request; scope finishes only after both stopped notifications.

**Observation:** Success yields 5. A failure is returned only after both tasks finish; no live child outlives the scope.

LMX uses its existing Message hierarchy and adds an explicit result barrier. Go shows cooperative cancellation; Erlang uses monitors and shutdown signals. These cancellation mechanisms are not identical.

### 089. [Supervision Tree](089_supervision_tree_comparision.md)

A parent monitors its direct child and restarts it after failure under a bounded policy.

**Scenario:** The first child launch fails and the second succeeds. Allow one restart; a second failure stops recovery.

**Observation:** Two distinct child identities are created; a successful child is not restarted.

LMX uses ordinary direct parenthood; restart strategy remains application policy. Erlang OTP supplies a supervisor; the Go example implements a small bounded controller.

### 090. [MapReduce](090_map_reduce_comparision.md)

Map emits keys, shuffle routes them to owners, and reduce combines values per key.

**Scenario:** Two partitions [1,2] and [3,4] are grouped by parity. Map emits (n mod 2,1); reduce counts values.

**Observation:** Result {0:2,1:2}. Final reads occur after four acknowledged reduce operations.

LMX expresses shuffle as explicit selection of the key owner Message; Go channels and Erlang mail carry keys. This exposes map/group/reduce without claiming to implement the distributed Google MapReduce engine.

### 109. [Request-Response / Ask](109_request_response_ask_comparision.md)

A request finishes through a later reply or deadline while its owner continues serving messages.

**Scenario:** Request token 1 expires, then token 2 starts. A late reply for token 1 is ignored; token 2 accepts value 12. Query remains serviceable while active.

**Observation:** Token 1 has one terminal timeout and token 2 one result 12; repeated replies/deadlines create no further result. Busy and i64 counter exhaustion are separate rejections.

LMX shows post/answer and owner state, Go the same state machine in a channel loop with nonblocking Compute/Schedule ports, and Erlang receive/send_after. This is application deadline policy, not a new blocking ask primitive.

### 110. [Become / Selective Stash](110_become_selective_stash_comparision.md)

A behavior change defers only work; control, queries and replies remain serviceable.

**Scenario:** While paused, accept work(1,2) and work(2,3), reject the third work at capacity two, and serve query/reply. become(1) pumps FIFO work one item per turn; stop rejects any remainder.

**Observation:** Query observes phase 0/count 2 and reply runs through its own handler. Accepted work yields 4 then 6, with no repeated effect from extra pumps. Stop is never stashed and leaves count zero.

Go uses a bounded slice and a separate wake channel; Erlang a bounded list and self message. gen_statem postpone is the conceptual analogue, but this queue is explicitly bounded and only work is deferred. Each listing includes its complete small FIFO.

### 111. [Phased Message Lifecycle](111_phased_message_lifecycle_comparision.md)

A live parent drains children, then closes them, then closes itself.

**Scenario:** Two current children receive drain. Each starts native flush and keeps serving query; flushed releases the completed native resource and sends drained. After both drained events the parent requests child close; after both stopped events it publishes the result and closes itself.

**Observation:** Parent phases progress 0→1→2→3; duplicates and foreign epochs do not decrement counts. Query works in phases 1 and 2. Exactly one result is published, with no request or wait from a stopped parent/poststop.

This complements 089 Supervision Tree; restart and its budget remain separate policy. Go stores phases/seen arrays, Erlang confirms termination through monitor references/DOWN, and LMX uses its ordinary lifecycle provider. Shutdown coordination never moves into poststop.

### 112. [External Blocking Adapter](112_external_blocking_adapter_comparision.md)

A physically blocking call runs in a native L2 worker; LMX receives an ordinary Message completion.

**Scenario:** Admit one native job, serve query, begin close and reject new jobs. A native completion reports real ok/value after releasing native holds; then the owner releases the idle adapter and closes.

**Observation:** While the native call runs, active is one and query remains serviceable. beginClose does not mark the job complete. One completion yields one result; a stale token changes nothing. releaseIdle/close occur only when inactive.

Go starts one goroutine with the supplied blocking function and a bounded completion channel. Erlang starts a process, but native Call must use a port or correctly dirty-scheduled NIF; spawn alone does not make an arbitrary blocking NIF safe. The LMX state machine does not hide its missing physical adapter.
