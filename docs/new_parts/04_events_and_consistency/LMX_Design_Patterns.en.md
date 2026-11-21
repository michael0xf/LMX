# LMX: Events, distributed state and consistency

Java contributes explicit service interfaces and transactional application conventions; Go contributes compact service handlers and explicit errors. Each comparison fixes the same protocol and external guarantees instead of comparing frameworks with different scope.

Original IDs 11,12,41,48,50,51,55,57 remain; 86 is added. LMX handlers run in executing Messages with one writing lane and owned arenas. Owners communicate through post/send/receive and the existing §32 HTTP profile: endpoint+route, application/lmx, intake/admission and synchronous reply or replyTo/correlation. transport/db/store/coordinator are explicit adapter contracts, not invented builtins; their implementations are excluded equally from all listings and code counts. A serial turn does not provide database transactions, consensus, durability or deduplication. All code is newly authored; sources establish pattern meaning and limits. The LMX fixture installs dependencies and initial state in the actual owner DATA before calls; potentially ambiguous actual positions are named explicitly, for example account\debit(amount := 30). Applicable control baselines are Python 3.10+, C# 12, Java 17 and Go 1.18+.

## Files

- [Markdown](LMX_Comparison_04_events_and_consistency.md)
- [Excel](LMX_Comparison_04_events_and_consistency.xlsx)
- [PDF](LMX_Comparison_04_events_and_consistency.pdf)
- [CSV](LMX_Comparison_04_events_and_consistency.csv)
- [Methodology](../COMPARISON_METHODOLOGY.en.md)
- [All 90 patterns](../PATTERN_CATALOG_90.en.md)
- [Validation status](../VALIDATION.md)
- [Message and existing HTTP transport profile](../MESSAGE_HTTP_PROFILE.md)

## Catalog

### 011. [CQRS](011_cqrs_comparision.md)

Separate the command model from the read model.

**Scenario:** WriteMessage accepts add(5). ReadMessage returns 0 before projection delivery and 5 after delivery.

**Observation:** The command updates write-state and emits snapshot 5; queries observe 0 then 5 without calling command behavior.

Every listing contains two serial owners and a delivery port, excluding runtime startup and networking. The example deliberately exposes an eventual-consistency window.

### 012. [Event Sourcing](012_event_sourcing_comparision.md)

Rebuild state from a durable ordered event sequence.

**Scenario:** The stream contains 100,20,-5. Replay, append 10 with expected version 3, and replay again.

**Observation:** Balances are 115 then 125. A stale append fails; replay performs no external payments.

Every version folds the same journal. A serial Message orders its own commands; the version check also protects against other writers.

### 041. [Saga](041_saga_comparision.md)

Coordinate local actions and an explicit compensating action.

**Scenario:** Start, Reserved(true), Charged(false), Released(true), duplicating each reply. A separate successful charge path is also tested.

**Observation:** States are 0→1→2→3→4 and actions reserve,charge,release,failed each occur once. Duplicates produce no action. Successful charge reaches state 5 and emits done.

All listings implement the same serial finite-state machine. Compensation is a separate business action, not graph rollback or a distributed transaction.

### 048. [Transactional Outbox](048_transactional_outbox_comparision.md)

Commit the business change and outgoing event in one local database transaction.

**Scenario:** Update account 7 to 120 and create event 51. Relay publishes; inject a crash after publish but before markSent.

**Observation:** Rollback leaves neither change nor outbox row. Commit persists both. The crash causes event 51 to be published again, so consumption must be idempotent.

Every version inserts before commit and marks sent only after publication. End-of-turn Message staging is not a durable database outbox.

### 050. [Materialized View](050_materialized_view_comparision.md)

Maintain a precomputed projection for cheap reads.

**Scenario:** Apply (1,10),(2,5), duplicate (2,5), then a gap (4,9); query total.

**Observation:** Total is 15 and last is 2. The duplicate is ignored; the gap fails before changing state.

Each version stores a sum and checkpoint separately from the source stream. Deduplication assumes one contiguous ordered stream.

### 051. [Sharding](051_sharding_comparision.md)

Route keys to horizontal storage partitions.

**Scenario:** For three shards, route nonnegative customer IDs 7,8,9 using id modulo 3.

**Observation:** The selected shards are 1,2,0; repeated keys retain placement while the shard set is unchanged.

Every language implements the same routing function and port call. LMX shards are separate Messages/services with isolated state.

### 055. [Leader Election](055_leader_election_comparision.md)

Acquire confirmed leadership and reject stale-owner resource writes.

**Scenario:** A holds token 10 while B is refused; after lease loss B obtains 11. A delayed write still carries 10.

**Observation:** B can write with 11; the resource rejects A with 10. acquire returns zero when no leadership was obtained and no work starts.

The listings compare a leader client protocol, not Raft/Paxos implementations. Java and Go use the same contracts. etcd Election/Lease is a possible adapter infrastructure, not an implicit LMX dependency.

### 057. [Claim Check](057_claim_check_comparision.md)

Send a compact claim ticket while retaining the large payload externally.

**Scenario:** Store 10000 ASCII characters and publish only ticket(key,length). The receiver uses its authorized store port to fetch and validate length.

**Observation:** The queue/HTTP carries two integers; the consumer obtains the original 10000-character payload. A length mismatch raises Payload.

All versions persist the blob before publishing the ticket. LMX HTTP also supports cursor/range bodies for this role.

### 086. [Idempotent Consumer / Transactional Inbox](086_idempotent_consumer_inbox_comparision.md)

Suppress repeated business effects using a durable delivery identity.

**Scenario:** Deliver subscriber 7,event 51,delta 5 twice from balance 100. The first commit succeeds but its ACK is lost.

**Observation:** Balance ends at 105 with one inbox row (7,51). Both successful deliveries may ACK. A failed transaction leaves neither marker nor effect and sends no ACK.

Every implementation commits the durable marker and business effect together. An in-memory set protects only its lifetime and is not a transactional inbox across restarts.

## Boundaries

Sizes are computed from each pattern’s three listings. They exclude implementations of supplied libraries, runtime, HTTP hosts and databases. Read each case’s individual limits. IDs retain the original list; 86–90 are explicit additions.
