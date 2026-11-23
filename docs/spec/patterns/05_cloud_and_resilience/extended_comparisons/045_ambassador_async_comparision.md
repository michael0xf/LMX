# 045. Ambassador: отдельный асинхронный клиент

Сохранён договор и реальные library clients 23-Nov. Этот вариант использует retryPost и не входит в синхронную основную строку.

Клиент просит получить каталог. Ambassador обращается к заданному endpoint: первый результат 503, второй 200.

Повторяется безопасное чтение. HTTP codec/admission/TLS относятся к существующему transport profile. Timeout/cancellation прекращают планирование, но не доказывают отсутствие удалённого эффекта.

## LMX

```lmx
CatalogOperation:
    @: http
    return: int
    read:
        return: http\post("https://catalog.example"; "/catalog/read")

AmbassadorPolicy:
    @: outcome
    return: int
    unavailable:
        if: outcome\ok = 0
            return: 0
        return: \outcome\value = 503

AmbassadorMessage:
    @: catalogWorker
    @: clock
    @: sink
    return: @
    catalog:
        throws: FxIndex
        return: retryPost(catalogWorker\run; AmbassadorPolicy\unavailable; 2; clock\elapsed; 0; 0; 1000; sink\complete)
```
[Исходник](source/lmx/045_ambassador_async.lm3)

catalogWorker вызывает существующий HTTP provider для https://catalog.example /catalog/read и оформляет FxOutcome. Две попытки, без задержки; шаблон worker полностью дан в097. Host помещает CatalogOperation и HTTP-reference в ту же арену receiving worker Message, что и FxRetryOperationMessage; чужой raw pointer прямо не вызывается.

## Go

```go
package example
import (
    "context"
    "errors"
    backoff "github.com/cenkalti/backoff/v5"
)
func Ambassador(ctx context.Context, post func(context.Context,string,string) (int,error)) (int,error) {
    unavailable := errors.New("503")
    value,err := backoff.Retry(ctx,func() (int,error) {
        status,e := post(ctx,"https://catalog.example","/catalog/read")
        if e != nil { return status,backoff.Permanent(e) }
        if status == 503 { return status,unavailable }
        return status,nil
    },backoff.WithBackOff(&backoff.ZeroBackOff{}),backoff.WithMaxTries(2),backoff.WithMaxElapsedTime(0))
    if errors.Is(err,unavailable) { err=nil }
    return value,err
}
```
[Исходник](source/go/045_ambassador_async.go)

Реальный backoff; provider post остаётся явно переданным HTTP портом сценария.

## C#

```csharp
using System;
using System.Threading;
using System.Threading.Tasks;
using Polly;
using Polly.Retry;
public static class Example {
    public static ValueTask<int> Ambassador(Func<string,string,CancellationToken,ValueTask<int>> post, CancellationToken token) {
        var pipeline=new ResiliencePipelineBuilder<int>().AddRetry(new RetryStrategyOptions<int> {
            MaxRetryAttempts=1, Delay=TimeSpan.Zero,
            ShouldHandle=new PredicateBuilder<int>().HandleResult(503)
        }).Build();
        return pipeline.ExecuteAsync(ct=>post("https://catalog.example","/catalog/read",ct),token);
    }
}
```
[Исходник](source/csharp/045_ambassador_async.cs)

Настоящий Polly; один повтор после первой попытки, без задержки.

[Полная async-реализация](097_retry_library_implementation_generalized_comparision.md). [Основной синхронный клиент](../045_ambassador_comparision.md).

Ни LMX, ни внешние runtime в этой редакции не запускались.
