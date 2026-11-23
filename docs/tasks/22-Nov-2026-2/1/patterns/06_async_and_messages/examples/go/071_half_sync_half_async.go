func HalfSync(frames <-chan int, write func(int)) {
    jobs := make(chan int, 2)
    done := make(chan struct{})
    go func() {
        for frame := range jobs { write(frame * frame) }
        close(done)
    }()
    for frame := range frames { jobs <- frame }
    close(jobs); <-done
}
