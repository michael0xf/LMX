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
