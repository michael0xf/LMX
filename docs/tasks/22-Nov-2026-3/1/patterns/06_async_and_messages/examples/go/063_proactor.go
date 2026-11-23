type Completion struct { token, bytes int }
func Proactor(submit func(int, int, chan<- Completion), write func(int)) {
    completed := make(chan Completion, 1)
    submit(3, 7, completed)
    for c := range completed {
        if c.token == 7 { write(c.bytes); return }
    }
}
