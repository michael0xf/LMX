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
