# 097. RetryPost — asynchronous retry implementation

Реализовать конечную asynchronous retry-policy с явным итогом и lifetime незавершённой работы.

**Примеры использования:** [039. Retry](039_retry_comparision.md), [045. Ambassador](045_ambassador_comparision.md)

## Общий сценарий

Сохранить503,503,200 с3 попытками/задержками1,2 и503,200 с2 попытками/без задержки. Дополнительно проверить400, один attempt, отказ predicate, cancel, timeout, late completion и один итог.

**Ожидаемое наблюдение:** Итог после конечного budget; повтор допускает только retryOn. Timeout/cancel завершают policy один раз; поздняя работа может завершиться позже и удерживает необходимые ресурсы.

**Граница сравнения:** Реализация библиотеки. Полная конечная retry-policy, не весь Polly/backoff: без jitter/Retry-After/circuit breaker/durable log. Типы общие. LMX worker/clock используют существующие Thread launcher и OS delay provider; алгоритм retry выписан. Отказ доставки отличен от application failure. Cancel прекращает планирование; некооперативная работа удерживает Settled. LMX runtime не запускался.

Это самостоятельное сравнение реализаций. Весь показанный код считается здесь; связанные иностранные клиенты используют настоящие библиотечные средства. Общие runtime-примитивы и их границы перечислены отдельно.

## LMX

```lmx
# retryPost: asynchronous bounded retry over the existing Message post API.
# Each job is persistent DATA in its sender Message arena, not a captured frame.
# The caller retains the handle until its owner Message can release all waits.
# post itself correlates each response; no numeric request-id registry is built.
# Timeout/cancel stop this policy, NOT an operation already running elsewhere.
# Late replies only drain pending; they cannot publish a second result.
# Result.read() exposes the persisted outcome even if notification is undelivered.
# Control.settled() describes attempt/delay completion, not permission to free
# an arena still retained by any ordinary post route. timeoutMs > maxDelay
# leaves an explicit configured window for a delayed acknowledgement.
# complete is a nonthrowing procedure under the selected protocol; notification
# is one send attempt, not a promise of exactly-once external delivery.

# These internal bridge failures have the explicitly empty () payload.
# User failures retain their original name and typed payload in FxOutcome.
FxRetryEmptyFailure:
    private: char[]: name
    return: @
    make:
        private: @: outcome (copy(FxOutcome))
        outcome\failure := name
        outcome\payload := (copy(()))
        return: outcome

FxRetryPostResult:
    char[]: kind ""
    int: attempts 0
    @: outcome 0

FxRetryPostJob:
    private:
        @: request 0
        @: retryOn 0
        @: delay 0
        @: complete 0
        int: limit 0
        int: pause 0
        int: maxPause 0
        int: timeoutMs 0
        int: attempts 0
        int: completed 0
        int: pending 0
        @: finalResult 0
        int: notificationUndelivered 0
    dispatch:
        if: node\private\completed != 0
            return
        node\private\attempts += 1
        node\private\pending += 1
        private: @: request node\private\request
        post:
            ask:
                request()
            answer:
                Replies\accept
            timeout:
                ms:
                    int: time node\private\timeoutMs
            ---
            undelivered:
                Events\undelivered()
            unanswered:
                Events\unanswered()
            catch: FxKernelFailure ()
                Events\failed("FxKernelFailure")
            catch: FxTypeToken ()
                Events\failed("FxTypeToken")
    ---
    Events:
        char[]: failure
        failed:
            private: @: job parent(node)
            job\private\pending -= 1
            job\Completion\finish("requestFailure"; FxRetryEmptyFailure\make(failure))
        undelivered:
            private: @: job parent(node)
            job\private\pending -= 1
            job\Completion\finish("undelivered"; 0)
        unanswered:
            private: @: job parent(node)
            job\Completion\finish("timeout"; 0)
    ---
    Control:
        cancel:
            private: @: job parent(node)
            private: int: accepted job\private\completed = 0
            job\Completion\finish("cancelled"; 0)
            return: accepted
        return: int
        settled:
            private: @: job parent(node)
            return: job\private\pending = 0
    ---
    Result:
        return: @
        read:
            private: @: job parent(node)
            return: job\private\finalResult
        undelivered:
            private: @: job parent(node)
            job\private\notificationUndelivered := 1
            return: job\private\finalResult
    ---
    Completion:
        char[]: kind
        @: outcome
        finish:
            private: @: job parent(node)
            if: job\private\completed != 0
                return
            private: @: result (copy(FxRetryPostResult))
            result\kind := kind
            result\attempts := job\private\attempts
            result\outcome := outcome
            job\private\finalResult := result
            job\private\completed := 1
            private: @: complete job\private\complete
            post:
                ask:
                    complete(result)
                undelivered:
                    Result\undelivered()
    ---
    Replies:
        @: outcome
        accept:
            private: @: job parent(node)
            job\private\pending -= 1
            if: job\private\completed != 0
                return
            if: job\private\attempts >= job\private\limit
                job\Completion\finish("completed"; outcome)
                return
            private: @: accepted FxApply\apply(job\private\retryOn; FxOne\make(FxRecords\reference(outcome)))
            if: FxSeqPredicate\truth(accepted) = 0
                job\Completion\finish("completed"; outcome)
                return
            private: int: duration job\private\pause
            private: int: maximum job\private\maxPause
            if: duration > maximum - duration
                job\private\pause := maximum
            else:
                job\private\pause := duration + duration
            if: duration = 0
                job\dispatch()
                return
            job\private\pending += 1
            private: @: delay job\private\delay
            post:
                ask:
                    delay(duration)
                answer:
                    job\DelayReply\elapsed
                timeout:
                    ms:
                        int: time job\private\timeoutMs
                ---
                unanswered:
                    DelayReply\unanswered()
                undelivered:
                    DelayReply\undelivered()
            ---
            catch: FxCallFailure (@: failure)
                job\Completion\finish("policyFailure"; failure)
            catch: FxKernelFailure ()
                job\Completion\finish("policyFailure"; FxRetryEmptyFailure\make("FxKernelFailure"))
            catch: FxTypeToken ()
                job\Completion\finish("policyFailure"; FxRetryEmptyFailure\make("FxTypeToken"))
            catch: FxPredicate ()
                job\Completion\finish("policyFailure"; FxRetryEmptyFailure\make("FxPredicate"))
            catch: ReceiverIndex ()
                job\Completion\finish("policyFailure"; FxRetryEmptyFailure\make("ReceiverIndex"))
            catch: FxRecordArity ()
                job\Completion\finish("policyFailure"; FxRetryEmptyFailure\make("FxRecordArity"))
    ---
    DelayReply:
        int: acknowledgement
        unanswered:
            private: @: job parent(node)
            job\Completion\finish("delayTimeout"; 0)
        undelivered:
            private: @: job parent(node)
            job\private\pending -= 1
            job\Completion\finish("delayUndelivered"; 0)
        elapsed:
            private: @: job parent(node)
            job\private\pending -= 1
            if: job\private\completed != 0
                return
            if: acknowledgement != 1
                job\Completion\finish("delayFailure"; 0)
                return
            job\dispatch()

# request is an addressed nullary Message method returning an FxOutcome.
# retryOn(outcome)->int decides explicitly which completed results/failures to
# repeat. A timeout or undelivered request is terminal, so the library never
# silently repeats an operation with an unknown completion state.
# delay(ms)->int is the addressed timer worker acknowledgement, not a void call.
# complete(result)->void is an addressed completion consumer; no ACK is invented.
# Clock waiting belongs to the existing host delay port (MESSAGE_HTTP_PROFILE).
# The complete LMX worker below adapts that port into ordinary Message replies.
FxRetryPost:
    private:
        @: request
        @: retryOn
        int: attempts
        @: delay
        int: firstDelay
        int: maxDelay
        int: timeoutMs
        @: complete
    required: request retryOn attempts delay firstDelay maxDelay timeoutMs complete
    return: @
    retryPost:
        throws: FxIndex
        if: attempts < 1 || firstDelay < 0 || maxDelay < firstDelay || timeoutMs <= maxDelay
            throw: FxIndex()
        private: @: job (copy(FxRetryPostJob))
        job\private\request := request
        job\private\retryOn := retryOn
        job\private\limit := attempts
        job\private\delay := delay
        job\private\pause := firstDelay
        job\private\maxPause := maxDelay
        job\private\timeoutMs := timeoutMs
        job\private\complete := complete
        job\dispatch()
        return: job

# These are explicit Message templates. The existing host/lifecycle launches
# them as Threads with their own arenas; copying a Structure alone does not.
# The worker and its operation are owned by the SAME receiving Message. Passing
# a remote raw operation pointer here never makes a legal cross-owner call.
FxRetryOperationMessage:
    @: operation
    @: arguments ()
    return: @
    run:
        throws: copy(FxThrows\kernel)
        return: FxTry\attempt(operation; arguments)

FxRetryDelayMessage:
    @: wait
    int: duration
    return: int
    elapsed:
        wait(duration)
        return: 1
```

Полная policy owner-Message: конечный budget, capped backoff, обработка service errors, timeout попытки/таймера, cancel, сохранённый finalResult, один terminal переход и не более одной отправки уведомления. Late reply только уменьшает pending; корреляция штатная post. Result.read доступен при отказе уведомления. Control.settled — завершение attempt/delay, не разрешение освободить арену с другими mail routes.

[Отдельный листинг](examples/lmx/097_retry_library_implementation.lm3)

## Go

```go
package retrycomparison

import (
    "context"
    "errors"
    "time"
)

type Outcome[T any] struct { Value T; Err error }
type Result[T any] struct { Kind string; Attempts int; Outcome *Outcome[T] }
type Job[T any] struct {
    Result <-chan Result[T]
    Settled <-chan struct{}
    cancel context.CancelFunc
}
func (j *Job[T]) Cancel() { j.cancel() }

func wait(ctx context.Context, duration time.Duration) error {
    timer := time.NewTimer(duration)
    defer timer.Stop()
    select {
    case <-timer.C: return nil
    case <-ctx.Done(): return ctx.Err()
    }
}

// Result is published once. Settled additionally waits for an outstanding
// operation/delay after cancellation or timeout; cancellation is cooperative.
func Start[T any](parent context.Context,
    operation func(context.Context) (T, error),
    retryOn func(Outcome[T]) (bool, error), attempts int,
    firstDelay, maxDelay, attemptTimeout time.Duration,
    delay func(context.Context, time.Duration) error) (*Job[T], error) {
    if parent == nil || operation == nil || retryOn == nil || attempts < 1 ||
       firstDelay < 0 || maxDelay < firstDelay || attemptTimeout <= maxDelay {
        return nil, errors.New("invalid retry policy")
    }
    if delay == nil { delay = wait }
    ctx, cancel := context.WithCancel(parent)
    results := make(chan Result[T], 1)
    settled := make(chan struct{})
    job := &Job[T]{results, settled, cancel}
    go func() {
        defer close(settled)
        defer cancel()
        publish := func(kind string, n int, outcome *Outcome[T]) {
            results <- Result[T]{kind, n, outcome}
            close(results)
        }
        pause := firstDelay
        for n := 1; n <= attempts; n++ {
            if ctx.Err() != nil { publish("cancelled", n-1, nil); return }
            callCtx, callCancel := context.WithCancel(ctx)
            reply := make(chan Outcome[T], 1)
            go func() { value, err := operation(callCtx); reply <- Outcome[T]{value, err} }()
            timer := time.NewTimer(attemptTimeout)
            var outcome Outcome[T]
            select {
            case outcome = <-reply:
                timer.Stop()
                callCancel()
            case <-ctx.Done():
                timer.Stop()
                callCancel()
                publish("cancelled", n, nil)
                <-reply
                return
            case <-timer.C:
                callCancel()
                publish("timeout", n, nil)
                <-reply
                return
            }
            if n == attempts { publish("completed", n, &outcome); return }
            again, err := retryOn(outcome)
            if err != nil {
                publish("policyFailure", n, &Outcome[T]{Err: err})
                return
            }
            if !again { publish("completed", n, &outcome); return }
            if pause > 0 {
                delayed := make(chan error, 1)
                duration := pause
                go func() { delayed <- delay(ctx, duration) }()
                delayTimer := time.NewTimer(attemptTimeout)
                select {
                case err := <-delayed:
                    delayTimer.Stop()
                    if err != nil {
                        kind := "delayFailure"
                        if ctx.Err() != nil { kind = "cancelled" }
                        publish(kind, n, &Outcome[T]{Err: err})
                        return
                    }
                case <-ctx.Done():
                    delayTimer.Stop()
                    publish("cancelled", n, nil)
                    <-delayed
                    return
                case <-delayTimer.C:
                    cancel()
                    publish("delayTimeout", n, nil)
                    <-delayed
                    return
                }
            }
            if pause > maxDelay-pause { pause = maxDelay } else { pause += pause }
        }
    }()
    return job, nil
}
```

Самостоятельная generic asynchronous реализация; Result и Settled различаются. Не используется в039/045.

[Отдельный листинг](examples/go/097_retry_library_implementation.go)

## C#

```csharp
#nullable enable
using System;
using System.Threading;
using System.Threading.Tasks;

public sealed record RetryOutcome<T>(T? Value, Exception? Error);
public sealed record RetryResult<T>(string Kind, int Attempts, RetryOutcome<T>? Outcome);

public sealed class RetryJob<T> {
    readonly CancellationTokenSource cancellation;
    readonly TaskCompletionSource<RetryResult<T>> result = new(TaskCreationOptions.RunContinuationsAsynchronously);
    readonly TaskCompletionSource settled = new(TaskCreationOptions.RunContinuationsAsynchronously);
    public Task<RetryResult<T>> Result => result.Task;
    public Task Settled => settled.Task;
    public void Cancel() => cancellation.Cancel();
    RetryJob(CancellationToken parent) => cancellation = CancellationTokenSource.CreateLinkedTokenSource(parent);

    public static RetryJob<T> Start(Func<CancellationToken,Task<T>> operation,
        Func<RetryOutcome<T>,bool> retryOn, int attempts,
        TimeSpan firstDelay, TimeSpan maxDelay, TimeSpan attemptTimeout,
        CancellationToken cancellation = default,
        Func<TimeSpan,CancellationToken,Task>? delay = null) {
        ArgumentNullException.ThrowIfNull(operation);
        ArgumentNullException.ThrowIfNull(retryOn);
        if (attempts < 1 || firstDelay < TimeSpan.Zero || maxDelay < firstDelay || attemptTimeout <= maxDelay)
            throw new ArgumentOutOfRangeException(nameof(attempts));
        var job = new RetryJob<T>(cancellation);
        _ = job.Run(operation, retryOn, attempts, firstDelay, maxDelay, attemptTimeout, delay ?? Task.Delay);
        return job;
    }

    async Task Run(Func<CancellationToken,Task<T>> operation, Func<RetryOutcome<T>,bool> retryOn,
        int attempts, TimeSpan pause, TimeSpan maxDelay, TimeSpan timeout,
        Func<TimeSpan,CancellationToken,Task> delay) {
        var token = cancellation.Token;
        Task? pending = null;
        int completedAttempts = 0;
        try {
            for (int n = 1; n <= attempts; n++) {
                token.ThrowIfCancellationRequested();
                completedAttempts = n;
                RetryOutcome<T> outcome;
                using var attempt = CancellationTokenSource.CreateLinkedTokenSource(token);
                using var alarmCancellation = new CancellationTokenSource();
                try {
                    Task<T> call = operation(attempt.Token);
                    pending = call;
                    Task alarm = Task.Delay(timeout, alarmCancellation.Token);
                    Task cancelled = Task.Delay(Timeout.InfiniteTimeSpan, token);
                    Task winner = await Task.WhenAny(call, alarm, cancelled).ConfigureAwait(false);
                    alarmCancellation.Cancel();
                    if (winner != call) {
                        attempt.Cancel();
                        result.TrySetResult(new(winner == alarm ? "timeout" : "cancelled", n, null));
                        return;
                    }
                    outcome = new(await call.ConfigureAwait(false), null);
                    attempt.Cancel();
                } catch (OperationCanceledException) when (token.IsCancellationRequested) { throw; }
                  catch (Exception error) { outcome = new(default, error); }
                pending = null;
                if (n == attempts || !retryOn(outcome)) {
                    result.TrySetResult(new("completed", n, outcome));
                    return;
                }
                if (pause > TimeSpan.Zero) {
                    pending = delay(pause, token);
                    try { await pending.WaitAsync(timeout,token).ConfigureAwait(false); }
                    catch (TimeoutException) when (!pending.IsCompleted) {
                        result.TrySetResult(new("delayTimeout",n,null));
                        cancellation.Cancel();
                        return;
                    }
                    catch (OperationCanceledException) when (token.IsCancellationRequested) { throw; }
                    catch (Exception error) {
                        result.TrySetResult(new("delayFailure",n,new(default,error)));
                        return;
                    }
                    pending = null;
                }
                pause = pause.Ticks > maxDelay.Ticks-pause.Ticks ? maxDelay : TimeSpan.FromTicks(pause.Ticks+pause.Ticks);
            }
        } catch (OperationCanceledException) when (token.IsCancellationRequested) {
            result.TrySetResult(new("cancelled", completedAttempts, null));
        } catch (Exception error) {
            result.TrySetResult(new("policyFailure", completedAttempts, new(default, error)));
        } finally {
            // Observe an outstanding late result/fault before advertising Settled.
            if (pending is not null) { try { await pending.ConfigureAwait(false); } catch { } }
            cancellation.Cancel();
            settled.TrySetResult();
        }
    }
}
```

Самостоятельный generic RetryJob<T> с Task, отменой, timeout и наблюдением поздней ошибки перед Settled. Не подключается039/045.

[Отдельный листинг](examples/csharp/097_retry_library_implementation.cs)

## Разбор LMX

Полная policy owner-Message: конечный budget, capped backoff, обработка service errors, timeout попытки/таймера, cancel, сохранённый finalResult, один terminal переход и не более одной отправки уведомления. Late reply только уменьшает pending; корреляция штатная post. Result.read доступен при отказе уведомления. Control.settled — завершение attempt/delay, не разрешение освободить арену с другими mail routes.

## Сопоставление

Все три реализации показывают полную policy. LMX использует обычные Message/post и существующий delay host port, Go — goroutines/channels/timers, C# — Task/cancellation. Клиенты чужой самописный helper не импортируют.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 6081 | 243 |
| Go | 2456 | 107 |
| C# | 3462 | 90 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Implement a finite asynchronous retry policy with explicit completion and outstanding-work lifetime.

**Usage examples:** [039. Retry](039_retry_comparision.md), [045. Ambassador](045_ambassador_comparision.md)

**Scenario.** Preserve503,503,200 with3 attempts and1,2 delays, and503,200 with2 attempts/no delay. Also test immediate400, one-attempt exhaustion, predicate failure, cancellation, per-attempt timeout, late completion and one terminal notification.

**Expected observation.** Normal result after the configured finite budget. Only explicit retryOn accepts a repeated outcome. Timeout/cancel ends the policy once; late remote work may still finish and must settle before its retained resources are released.

**LMX.** Complete owner-Message policy: finite budget, capped backoff, finite service-error catches, per-attempt and delay timeouts, cancellation, persisted finalResult, one logical terminal transition and at most one completion send. Late replies only drain pending; post itself correlates them. Result.read remains available after notification refusal. Control.settled reports attempt/delay completion, not permission to free an arena retained by other mail routes.

**Comparison.** The three implementations show their complete policy state and algorithm. LMX reuses ordinary Message/post correlation and its existing delay host port; Go uses goroutines/channels/timers; C# uses Task and cancellation. No mock library is imported by the separate usage clients.

**Scope and limitations.** This is a complete bounded retry contract, not all Polly/backoff features: no jitter, Retry-After parser, circuit breaker or durable log. Operation/result types are generic. LMX worker/delay templates require the existing Thread launcher and OS delay provider; the retry algorithm is not a host stub. Transport refusal is distinct from application failure. Cancellation is a stop-scheduling policy; uncooperative work can keep Settled pending. No LMX runtime execution is claimed.

### Dependencies and execution boundaries

- **LMX:** Complete owner-Message policy: finite budget, capped backoff, finite service-error catches, per-attempt and delay timeouts, cancellation, persisted finalResult, one logical terminal transition and at most one completion send. Late replies only drain pending; post itself correlates them. Result.read remains available after notification refusal. Control.settled reports attempt/delay completion, not permission to free an arena retained by other mail routes.
- **Go:** Standalone generic asynchronous implementation; Result and Settled are distinct. It is not used by039/045.
- **C#:** Standalone generic RetryJob<T> using Task, cancellation, timeout and late-fault observation before Settled; not imported by039/045.

## Источники / Sources

- [Go context](https://pkg.go.dev/context) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.
- [Polly retry contract](https://www.pollydocs.org/strategies/retry) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
