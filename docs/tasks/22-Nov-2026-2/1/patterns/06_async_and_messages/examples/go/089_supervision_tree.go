func Supervise(run func() error) error {
    for attempt:=0; attempt<2; attempt++ {
        done := make(chan error, 1)
        go func() { done <- run() }()
        err := <-done
        if err == nil { return nil }
        if attempt == 1 { return err }
    }
    return nil
}
