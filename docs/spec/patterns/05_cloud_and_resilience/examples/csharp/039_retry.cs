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
