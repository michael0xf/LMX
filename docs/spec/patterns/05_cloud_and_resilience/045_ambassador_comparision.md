# 045. Ambassador

Локальный сетевой посредник скрывает внешний endpoint и политику повторов от клиента.

**Отдельное сравнение реализации:** [097. RetryPost — asynchronous retry implementation](097_retry_library_implementation_comparision.md)

## Общий сценарий

Клиент просит получить каталог. Ambassador обращается к заданному endpoint: первый результат 503, второй 200.

**Ожидаемое наблюдение:** Клиент получает 200; внешний провайдер вызван дважды, с одним и тем же endpoint/route.

**Граница сравнения:** Использование библиотеки. Повторяется безопасное чтение. HTTP codec/admission/TLS относятся к существующему transport profile. Timeout/cancellation прекращают планирование, но не доказывают отсутствие удалённого эффекта.

LMX вызывает операции единого ядра. Иностранные клиенты используют настоящие средства языка или установленную библиотеку; показанные рядом самостоятельные реализации в них не импортируются.

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

catalogWorker вызывает существующий HTTP provider для https://catalog.example /catalog/read и оформляет FxOutcome. Две попытки, без задержки; шаблон worker полностью дан в097. Host помещает CatalogOperation и HTTP-reference в ту же арену receiving worker Message, что и FxRetryOperationMessage; чужой raw pointer прямо не вызывается.

[Отдельный листинг](examples/lmx/045_ambassador.lm3)

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

Реальный backoff; provider post остаётся явно переданным HTTP портом сценария.

[Отдельный листинг](examples/go/045_ambassador.go)

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

Настоящий Polly; один повтор после первой попытки, без задержки.

[Отдельный листинг](examples/csharp/045_ambassador.cs)

## Разбор LMX

catalogWorker вызывает существующий HTTP provider для https://catalog.example /catalog/read и оформляет FxOutcome. Две попытки, без задержки; шаблон worker полностью дан в097. Host помещает CatalogOperation и HTTP-reference в ту же арену receiving worker Message, что и FxRetryOperationMessage; чужой raw pointer прямо не вызывается.

## Сопоставление

Все клиенты сохраняют HTTP catalog boundary и endpoint/route; LMX использует retryPost, Go/C# — настоящие retry libraries, не исходник097.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 372 | 20 |
| Go | 564 | 17 |
| C# | 518 | 14 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

A local network proxy hides the remote endpoint and retry policy from its client.

**Separate implementation comparison:** [097. RetryPost — asynchronous retry implementation](097_retry_library_implementation_comparision.md)

**Scenario.** The client requests a catalog. The ambassador calls its configured endpoint: first status 503, then 200.

**Expected observation.** The client receives 200; the remote provider is called twice with the same endpoint and route.

**LMX.** catalogWorker calls the existing HTTP provider for https://catalog.example /catalog/read and returns FxOutcome. Two attempts, no delay;097 contains the complete worker template. The host installs CatalogOperation and its HTTP reference in the same receiving worker Message as FxRetryOperationMessage; a foreign raw pointer is not called directly.

**Comparison.** All clients retain the catalog HTTP boundary and configured endpoint/route; LMX uses direct retryPost, Go and C# use real retry libraries. Implementation097 is not imported by either control.

**Scope and limitations.** Only a safe read is retried. HTTP codec/admission/TLS are provided by the existing transport profile, not recreated in a retry helper. Timeout/cancellation stops policy scheduling and does not establish remote nonexecution.

### Dependencies and execution boundaries

- **LMX:** catalogWorker calls the existing HTTP provider for https://catalog.example /catalog/read and returns FxOutcome. Two attempts, no delay;097 contains the complete worker template. The host installs CatalogOperation and its HTTP reference in the same receiving worker Message as FxRetryOperationMessage; a foreign raw pointer is not called directly.
- **Go:** Real backoff; post remains the scenario’s explicitly supplied HTTP provider port.
- **C#:** Real Polly; one retry after the first attempt, without delay.

## Источники / Sources

- [Polly retry](https://www.pollydocs.org/strategies/retry) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.
- [cenkalti/backoff v5](https://pkg.go.dev/github.com/cenkalti/backoff/v5) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
