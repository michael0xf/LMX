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
