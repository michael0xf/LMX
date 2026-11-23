# 039. Retry: отдельный асинхронный клиент

Сохранён договор и реальные library clients 23-Nov. Этот вариант использует retryPost и не входит в синхронную основную строку.

Идемпотентное чтение возвращает 503,503,200. Разрешены три попытки и задержки 1,2 единицы.

Сохранены идемпотентные503,503,200 и задержки1,2мс. В LMX явно указан timeout письма1000мс; контроли могут задать deadline контекстом. Timeout не означает остановку удалённой работы. Jitter/Retry-After вне этой конечной политики.

## LMX

```lmx
RetryPolicy:
    @: outcome
    return: int
    unavailable:
        if: outcome\ok = 0
            return: 0
        return: \outcome\value = 503

RetryMessage:
    @: worker
    @: clock
    @: sink
    return: @
    run:
        throws: FxIndex
        return: retryPost(worker\run; RetryPolicy\unavailable; 3; clock\elapsed; 1; 2; 1000; sink\complete)
```

[Исходник](source/lmx/039_retry_async.lm3)

worker и clock — явные Message из реализации097: отдельные арены, обычные post/reply. sink получает один итог;1 и2 — миллисекунды задержки.

## Go

```go
package example
import (
    "context"
    "errors"
    "time"
    backoff "github.com/cenkalti/backoff/v5"
)
func Retry(ctx context.Context, request func(context.Context) (int,error)) (int,error) {
    unavailable := errors.New("503")
    policy := backoff.NewExponentialBackOff()
    policy.InitialInterval = time.Millisecond
    policy.MaxInterval = 2*time.Millisecond
    policy.Multiplier, policy.RandomizationFactor = 2,0
    value,err := backoff.Retry(ctx, func() (int,error) {
        status,e := request(ctx)
        if e != nil { return status,backoff.Permanent(e) }
        if status == 503 { return status,unavailable }
        return status,nil
    }, backoff.WithBackOff(policy), backoff.WithMaxTries(3), backoff.WithMaxElapsedTime(0))
    if errors.Is(err,unavailable) { err=nil }
    return value,err
}
```

[Исходник](source/go/039_retry_async.go)

Настоящий cenkalti/backoff v5.0.3; код097 не используется. Context задаёт внешний deadline/cancellation; только завершённый503 повторяется.

## C#

```csharp
using System;
using System.Threading;
using System.Threading.Tasks;
using Polly;
using Polly.Retry;
public static class Example {
    public static ValueTask<int> Retry(Func<CancellationToken,ValueTask<int>> request, CancellationToken token) {
        var pipeline = new ResiliencePipelineBuilder<int>().AddRetry(new RetryStrategyOptions<int> {
            MaxRetryAttempts=2,
            ShouldHandle=new PredicateBuilder<int>().HandleResult(503),
            Delay=TimeSpan.FromMilliseconds(1), MaxDelay=TimeSpan.FromMilliseconds(2),
            BackoffType=DelayBackoffType.Exponential, UseJitter=false
        }).Build();
        return pipeline.ExecuteAsync(request,token);
    }
}
```

[Исходник](source/csharp/039_retry_async.cs)

Настоящий Polly.Core8 Retry;2 означает повтора после первой попытки, всего3. Цепочка await не блокирует поток таймером.

[Полная async-реализация](097_retry_library_implementation_generalized_comparision.md). [Основной синхронный клиент](../039_retry_comparision.md).

Ни LMX, ни внешние runtime в этой редакции не запускались.
