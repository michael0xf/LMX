# Core operations extracted from groups01–08

This edition is based only on the uploaded `spec.tar.gz` of23November2026. The
[LMX source](src/coreComparisonGroups.lmx) contains the complete new algorithms;
its public names use lowerCamelCase. They join the same core as the existing
callable/sequence operations. No application import, optional library version,
second namespace, or second scheduler is introduced.

## Public operations

| Name | Inputs | Result and complete contract | Implementation comparison |
| --- | --- | --- | --- |
| `findFirst` | `items; accepts` | Visit each actual typed element until true. Return `some(record)` or `none`; an initialized null or uninitialized typed record, if admitted by the predicate, remains a present value. A reference element retains identity; dense primitive access uses the existing stable value-record contract. No predicate runs after the first match. | [094](../03_domain_and_persistence/094_find_by_id_implementation_comparision.md) |
| `allOf` | `predicates; contract=0` | Construct an exact-signature callable returning int truth. Validate the finite predicate collection before publishing it. Without explicit contract, take the first predicate’s real input policy; with a contract, use that explicit policy. Empty predicates require a contract and produce true without reading arguments. Every candidate has the same canonical ordered input/result codes. Forward ordinary places through `FxApplyPlaces`, stop at false/failure, and do not eagerly read omitted/default inputs. | [095](../03_domain_and_persistence/095_specification_combinator_implementation_comparision.md) |
| `equalFields` | `first; second; same=0` | Compare lengths first and then ordered pairs through the shared scalar/deep Array equality or an optional explicit comparator. Empty equals empty; a length mismatch makes no comparator call. Dense arrays and Structure/@[] use their actual typed access. There is no hidden field-name matching, serializer, cyclic graph traversal, or replacement of an explicit relation. | [096](../03_domain_and_persistence/096_money_value_equality_implementation_comparision.md) |
| `retryPost` | `request; retryOn; attempts; delay; firstDelay; maxDelay; timeoutMs; complete` | Create persistent job DATA in the sender Message’s arena and start the first ordinary `post`. Return its handle. Attempts are finite and at least1; `0 <= firstDelay <= maxDelay < timeoutMs`. Backoff doubles to its cap without overflowing. Timeout/refusal/cancel never implicitly repeat an uncertain operation. See the full protocol below. | [097](../05_cloud_and_resilience/097_retry_library_implementation_comparision.md) |

`compose(outer; inner)` constructs an ordinary composed callable. `pipe(value; stages)` applies a finite sequence of stages immediately and retains the actual final result type. [coreGenericOperations.lmx](src/coreGenericOperations.lmx) supplies the one pipeline engine and exact-signature builder; [093](../02_architecture_and_boundaries/093_pipe_implementation_comparision.md) compares its complete value-application contract. `equals(first; second; projection=0; same=0)` reuses the shared equality after at most one projection per value. Money remains application DATA. `retry(operation; retryOn; limit; delay=0; arguments=())` is ordinary result-based retry; asynchronous Message retry remains `retryPost`.

`allOf(predicates := (first; second))` intentionally names the entire sequence.
The optional second `contract` input must not accidentally reinterpret a two-field
anonymous sequence as two ordinary actual arguments. The normal W/E call rule
remains unchanged. Type validation compares canonical signature codes; it does
not invent a Boolean-returning form of `satisfies`.

## Failure and ownership boundaries

The new sequence algorithms use the existing `FxThrows` sets and `FxCallFailure`
envelope. User-declared failures retain their names and typed payloads. Internal
`FxKernelFailure`, `FxTypeToken`, and the existing explicit service errors use their
empty `()` payload contract. Stage diagnostics, implicit execution failures and
system termination are not fabricated as successful results.

A Structure already is @[]: there is no boxing of its entire field sequence.
Common narrow `FxKernel` metadata/call/Array hooks are still integration points
of the uploaded source package. These algorithms add no new kernel hook.
Reference lifetimes and ordinary admission remain in force.

## retryPost Message protocol

The supplied source includes `FxRetryOperationMessage` and `FxRetryDelayMessage`.
The existing host/lifecycle launches each as an executable Message with its own
arena and serial turns. Copying a Structure is not itself a Thread launch.

| Port | Contract | Failure/ownership policy |
| --- | --- | --- |
| `request` | Addressed nullary method returning `FxOutcome {ok,value,failure,payload}` | The operation worker uses `FxTry.attempt` over an operation owned by that same receiving Message. It preserves declared user failures in the outcome and declares only `FxKernelFailure()`/`FxTypeToken()` as service exits. The sender post explicitly catches both. |
| `retryOn` | Local `FxOutcome -> int` | Called after a completed attempt only when budget remains. A false result ends normally. `FxCallFailure` and the finite service/type/predicate exits become a terminal policy failure. No callback state is borrowed from an expired activation. |
| `delay` | Addressed `duration:int -> acknowledgement:int` | The supplied delay Message calls the existing host `wait(duration):void` port and returns1. This port declares no additional recoverable throws. A different acknowledgement is a delay failure; refusal and expiry have separate outcomes. Host/implicit stop retains the ordinary failure channel. |
| `complete` | Addressed `RetryPostResult -> void`, no additional declared throws | At most one notification send is attempted after storing the final result. No synthetic ACK or exactly-once delivery promise is added. Refusal sets `notificationUndelivered`; the stored result remains readable. |

The host delay port is the existing one described in
[MESSAGE_HTTP_PROFILE.md](../MESSAGE_HTTP_PROFILE.md), not an omitted retry
algorithm. It may wait in its dedicated worker. `post` already supplies
asynchronous delivery, source-letter correlation, sender-side prepared routes,
request timeouts and serial handler execution. Reimplementing those as a second
broker would duplicate the kernel. HTTP delivery uses the existing HTTP profile;
retry adds no codec, admission bypass or transport stack.

The job’s `Control.cancel()` is idempotent and returns whether this call made the
terminal transition. It stops further policy attempts. It does not claim to stop
a remote operation, cancel a timer already running, close a route, or discard a
late response. `Control.settled()` reports that outstanding attempt/delay replies
have drained; it does not authorize releasing an arena still retained by other
ordinary mail routes. The enclosing Message follows its normal lifetime and
supervision rules, including uncooperative/lost peers.

`Result.read()` returns0 before completion and the stored final result afterwards.
The result has `kind`, `attempts`, and `outcome`. Kinds distinguish `completed`,
`requestFailure`, `policyFailure`, `undelivered`, `timeout`, `cancelled`,
`delayUndelivered`, `delayTimeout`, and `delayFailure`. Final state is stored before
notification. A late response can only reduce pending work, never replace a
terminal result or send another notification. A permanently unresponsive peer
can keep the job unsettled until the owning Message’s lifecycle resolves it.

The policy deliberately does not implement all Polly/backoff features: jitter,
Retry-After parsing, circuit breaking, durable logs and application idempotency
remain separate contracts. The old arbitrary31-attempt limit is removed; the
algorithm checks actual configured counts and safe capped delay arithmetic.

## Foreign clients and separate implementations

| Usage | Real foreign facility | Separate comparison body |
| --- | --- | --- |
|013Pipe | Java `IntUnaryOperator.andThen`; ordinary Go calls for the fixed pipeline | Generic composition in093; no `example/pipe` or `examplelib.Pipe` import |
|016Repository | Python `next(generator, default)`; C# LINQ `FirstOrDefault` | Generic first-match implementations in094 |
|031Specification | Python `all(generator)`; C# `Enumerable.All` | Generic conjunction implementations in095 |
|032Value Object | Python frozen dataclass; C# record | General field comparator and manual immutable control types in096 |
|039Retry,045Ambassador | Real `github.com/cenkalti/backoff/v5` (v5.0.3) and Polly.Core8 | Independent generic asynchronous retry implementations in097, never imported by these clients |

References are linked in the individual comparisons. The v5 Go baseline is an
explicit established dependency, not a claim that it is the newest module major.
The three097 implementations cover the same finite policy with platform-specific
failure representations. Go/C# cooperative cancellation can request that a
callback stop; LMX cancellation ends its policy and leaves remote stopping to
ordinary Message supervision. In all cases a callback may ignore cancellation,
and outstanding work must remain owned until it actually settles.

## Verification

[Prepared acceptance cases](tests/CORE_COMPARISON_GROUPS.json) specify the important
branches, including empty/null/generic values, lazy conjunction, length mismatch,
timeout, late reply, cancellation and lost notification. Their LMX execution
status is **NOT_RUN**: the archive does not contain an executable kernel.

The actual Python verifier in
[validate_python.py](../03_domain_and_persistence/validate_python.py) executes all
19 domain scenarios using their real standard facilities, and independently tests
three comparison implementations. It no longer inserts fake lookup/specification/
money modules into clients. Its [receipt](../03_domain_and_persistence/python_validation.json)
records source hashes. Java/C#/Go compilation is not claimed: `/usr/bin/go` in the
available environment is not the Go compiler (`go version` is rejected).

The [group publication tool](../tools/refresh_group_publication.py) synchronizes
current JSON,273 source mirrors,91 comparison pages and eight catalogs. It removes
minor source variants authorized in this edition; it does not reapply an older
archive or run LMX. [The revision report](../validation/group_library_revision_20261123.json)
records all26 removed minor variants and all five retained implementation pairs.

Both forms of each canonical operation use the same body and exact role. See [publication](PUBLICATION_CONTRACT.md) and [generic operations](../../GENERIC_OPERATIONS.md).
