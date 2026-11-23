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
