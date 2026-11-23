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
