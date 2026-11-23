# 039. Retry

Ограниченный повтор временного отказа с задержкой между попытками.

**Отдельное сравнение реализации:** [097. RetryPost — asynchronous retry implementation](097_retry_library_implementation_comparision.md)

## Общий сценарий

Идемпотентное чтение возвращает 503,503,200. Разрешены три попытки и задержки 1,2 единицы.

**Ожидаемое наблюдение:** Итог 200; три обращения и две задержки. Статус 400 прекращает повторы сразу.

**Граница сравнения:** Использование библиотеки. Сохранены идемпотентные503,503,200 и задержки1,2мс. В LMX явно указан timeout письма1000мс; контроли могут задать deadline контекстом. Timeout не означает остановку удалённой работы. Jitter/Retry-After вне этой конечной политики.

LMX вызывает операции единого ядра. Иностранные клиенты используют настоящие средства языка или установленную библиотеку; показанные рядом самостоятельные реализации в них не импортируются.

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

worker и clock — явные Message из реализации097: отдельные арены, обычные post/reply. sink получает один итог;1 и2 — миллисекунды задержки.

[Отдельный листинг](examples/lmx/039_retry.lm3)

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

Настоящий cenkalti/backoff v5.0.3; код097 не используется. Context задаёт внешний deadline/cancellation; только завершённый503 повторяется.

[Отдельный листинг](examples/go/039_retry.go)

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

Настоящий Polly.Core8 Retry;2 означает повтора после первой попытки, всего3. Цепочка await не блокирует поток таймером.

[Отдельный листинг](examples/csharp/039_retry.cs)

## Разбор LMX

worker и clock — явные Message из реализации097: отдельные арены, обычные post/reply. sink получает один итог;1 и2 — миллисекунды задержки.

## Сопоставление

Используются direct LMX retryPost и настоящие Go/.NET retry libraries. Самостоятельные asynchronous реализации сравниваются только в097; отдельно указаны итог и окончание cleanup.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 242 | 15 |
| Go | 662 | 22 |
| C# | 565 | 16 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Bounded retry of a transient failure with delay between attempts.

**Separate implementation comparison:** [097. RetryPost — asynchronous retry implementation](097_retry_library_implementation_comparision.md)

**Scenario.** An idempotent read returns 503,503,200. Allow three attempts and delays of 1 and 2 units.

**Expected observation.** Final status 200; three calls and two delays. Status 400 stops retries immediately.

**LMX.** worker and clock are explicit Messages from097 with separate arenas and ordinary post/reply. sink receives one result;1 and2 are milliseconds of backoff.

**Comparison.** Usage calls direct LMX retryPost and real Go/.NET retry libraries. Independently written asynchronous implementations are compared only in097. Their result and cleanup-settled boundaries are stated separately.

**Scope and limitations.** The same idempotent503,503,200 fixture and1,2ms delays are preserved. LMΧ adds an explicit per-letter1000ms timeout in this client; control contexts may impose their own deadline. A timeout does not prove remote work stopped. Jitter and Retry-After are configurable concerns outside this bounded policy.

### Dependencies and execution boundaries

- **LMX:** worker and clock are explicit Messages from097 with separate arenas and ordinary post/reply. sink receives one result;1 and2 are milliseconds of backoff.
- **Go:** Real cenkalti/backoff v5.0.3;097 is not used. Context supplies outer deadline/cancellation; only completed503 results are retried.
- **C#:** Real Polly.Core8 Retry;2 means retries after the first attempt,3 attempts total. Awaited delays do not block a thread.

## Источники / Sources

- [cenkalti/backoff v5](https://pkg.go.dev/github.com/cenkalti/backoff/v5) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.
- [Polly retry](https://www.pollydocs.org/strategies/retry) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
