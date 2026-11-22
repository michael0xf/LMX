import ("context"; "sync")
type Outcome struct { value int; err error }
func Scope(a, b func(context.Context) (int, error)) (int, error) {
    ctx, cancel := context.WithCancel(context.Background()); defer cancel()
    out := make(chan Outcome, 2)
    var wg sync.WaitGroup
    for _, fn := range []func(context.Context)(int,error){a,b} {
        wg.Add(1)
        go func(f func(context.Context)(int,error)) {
            defer wg.Done(); v,e := f(ctx); out <- Outcome{v,e}
        }(fn)
    }
    total := 0; var first error
    for i:=0; i<2; i++ {
        r := <-out
        if r.err != nil && first == nil { first = r.err; cancel() }
        total += r.value
    }
    wg.Wait(); return total, first
}
