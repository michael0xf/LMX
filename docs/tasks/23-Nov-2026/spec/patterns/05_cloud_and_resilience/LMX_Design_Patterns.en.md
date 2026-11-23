# LMX: Cloud, HTTP and resilience

Go and C# represent functions/channels and .NET delegates/Channel. Application cores are compared over equivalent transport/provider contracts; deployment is accounted for separately.

All 12 original patterns in this group and the added Backpressure pattern are retained. Retry and Ambassador share an application RetryLibrary; its complete algorithm is shown in a separate implementation example. LMX uses Message and its existing HTTP profile. HTTP admission, operation execution and semantic success remain distinct. Shared integration is listed separately and is not treated as free.

## Files

- [Markdown](LMX_Comparison_05_cloud_and_resilience.md)
- [Excel](LMX_Comparison_05_cloud_and_resilience.xlsx)
- [PDF](LMX_Comparison_05_cloud_and_resilience.pdf)
- [CSV](LMX_Comparison_05_cloud_and_resilience.csv)

## Catalog

### 038. [Circuit Breaker](038_circuit_breaker_comparision.md)

After two consecutive failures the owner temporarily rejects calls, then admits a recovery probe.

**Scenario:** Calls at times 0 and 1 fail; the call at 2 must be rejected; the probe at 6 succeeds.

**Observation:** Results are 0, 0, -1, 1; three provider calls; the successful probe resets the failure count.

LMX stores the machine in a Message; Go and C# use an instance. The serial contract, rather than a shared atomic flag, permits only one recovery probe at a time.

### 039. [Retry](039_retry_comparision.md)

Bounded retry of a transient failure with delay between attempts.

**Separate implementation comparison:** [097. RetryPost — asynchronous retry implementation](097_retry_library_implementation_comparision.md)

**Scenario:** An idempotent read returns 503,503,200. Allow three attempts and delays of 1 and 2 units.

**Observation:** Final status 200; three calls and two delays. Status 400 stops retries immediately.

Usage calls direct LMX retryPost and real Go/.NET retry libraries. Independently written asynchronous implementations are compared only in097. Their result and cleanup-settled boundaries are stated separately.

### 097. [RetryPost — asynchronous retry implementation](097_retry_library_implementation_comparision.md)

Implement a finite asynchronous retry policy with explicit completion and outstanding-work lifetime.

**Usage examples:** [039. Retry](039_retry_comparision.md), [045. Ambassador](045_ambassador_comparision.md)

**Scenario:** Preserve503,503,200 with3 attempts and1,2 delays, and503,200 with2 attempts/no delay. Also test immediate400, one-attempt exhaustion, predicate failure, cancellation, per-attempt timeout, late completion and one terminal notification.

**Observation:** Normal result after the configured finite budget. Only explicit retryOn accepts a repeated outcome. Timeout/cancel ends the policy once; late remote work may still finish and must settle before its retained resources are released.

The three implementations show their complete policy state and algorithm. LMX reuses ordinary Message/post correlation and its existing delay host port; Go uses goroutines/channels/timers; C# uses Task and cancellation. No mock library is imported by the separate usage clients.

### 040. [Bulkhead](040_bulkhead_comparision.md)

Partitioning concurrent work limits between independent destinations.

**Scenario:** Destinations A and B each have one permit. A is occupied; a second A request is rejected, while the first B request is admitted.

**Observation:** A acquire results: 1,0; B result: 1. Releasing A admits subsequent work.

LMX assigns permits to two owners; Go and C# use independent semaphores. A single Message executing both long operations would not isolate their delays.

### 042. [API Gateway](042_api_gateway_comparision.md)

One HTTP endpoint selects an explicit route to an internal service.

**Scenario:** Ingress maps /orders to route=1 and /stock to route=2. An unknown path receives 404.

**Observation:** Routes 1 and 2 invoke /orders/get and /stock/get respectively; an unknown route never invokes the provider.

LMX already supplies the HTTP profile and admission model; an application route table is still needed. Control listings use the same transport contract.

### 043. [Backends for Frontends](043_backends_for_frontends_comparision.md)

Different frontends receive separate aggregation operations over a shared backend.

**Scenario:** The backend returns price 12 and shipping 3. Mobile shows the price; web checkout shows the delivered total.

**Observation:** Mobile returns 12 after one backend call; Web returns 15 after two.

The difference is frontend-specific aggregation and independent deployment boundaries. Neither a Message nor a short function alone creates a complete BFF.

### 044. [Sidecar](044_sidecar_comparision.md)

Auxiliary processing runs beside the application in a separate process with a shared deployment lifecycle.

**Scenario:** The application sends record 7 to a local logging sidecar, which writes it to a sink.

**Observation:** The sink contains one record 7. Deployment shutdown closes both app and sidecar.

The core is small in every language; Sidecar is primarily deployment: two processes/containers, one lifecycle and an endpoint. A child Message in the same process provides weaker isolation.

### 045. [Ambassador](045_ambassador_comparision.md)

A local network proxy hides the remote endpoint and retry policy from its client.

**Separate implementation comparison:** [097. RetryPost — asynchronous retry implementation](097_retry_library_implementation_comparision.md)

**Scenario:** The client requests a catalog. The ambassador calls its configured endpoint: first status 503, then 200.

**Observation:** The client receives 200; the remote provider is called twice with the same endpoint and route.

All clients retain the catalog HTTP boundary and configured endpoint/route; LMX uses direct retryPost, Go and C# use real retry libraries. Implementation097 is not imported by either control.

### 049. [Cache-Aside](049_cache_aside_comparision.md)

The application loads a missing value and explicitly invalidates the cache after a store update.

**Scenario:** For one fixed key the store contains 7. Execute get,get,put(9),get.

**Observation:** Reads return 7,7,9; store.read is called twice. put updates the store before clearing ready.

LMX places the cache in its owner Message, controlling get and put. Control versions have the same confinement; this is not a globally coherent distributed cache.

### 052. [Throttling](052_throttling_comparision.md)

Admission limits requests within a fixed time window.

**Scenario:** Limit two requests per window of length 10. Requests arrive at times 0,1,2,10.

**Observation:** allow results: 1,1,0,1.

Algorithm and state are the same; a Message removes concurrent mutation within that owner. Different owners do not automatically share a global quota.

### 053. [Queue-Based Load Leveling](053_queue_based_load_leveling_comparision.md)

A queue decouples burst admission from a limited processing rate.

**Scenario:** A burst enqueues 1,2,3. Each tick processes at most one item.

**Observation:** After one tick only 1 is processed; after three, 1,2,3 are processed and the queue is empty.

The LMX inbox provides delivery; the application buffer and processing rate are explicit. No listing misrepresents an unbounded queue as backpressure.

### 054. [Competing Consumers](054_competing_consumers_comparision.md)

Several workers request work from a single queue owner.

**Scenario:** A queue contains 1,2,3. Two worker Messages repeatedly take jobs until exhausted.

**Observation:** Each of 1,2,3 is issued to one worker in this failure-free run; an empty queue yields -1.

Workers never concurrently execute one LMX Thread: take requests compete at QueueMessage, then work runs in distinct Messages. Go and .NET channels provide atomic dequeue.

### 056. [Health Endpoint Monitoring](056_health_endpoint_monitoring_comparision.md)

Separate checks report process liveness and readiness to serve requests.

**Scenario:** The process responds but its required database is unavailable; the database then recovers.

**Observation:** Liveness is 200 when the handler is reached; readiness changes from 503 to 200.

The existing LMX HTTP profile separates admission from semantic response, so readiness comes from the handler result. Mail acceptance alone does not make the service ready.

### 087. [Backpressure](087_backpressure_comparision.md)

A producer sends items only within explicit consumer-issued credit.

**Scenario:** One credit is granted. The producer attempts 7 and 8, receives another credit, and retries 8.

**Observation:** 7 is sent; the first attempt at 8 returns 0 without sending; retrying 8 sends it. In-flight stays at most 1.

Credit limits sending before downstream fills, rather than rejecting only after overload. The LMX mailbox does not supply this policy automatically; the application implements it.
