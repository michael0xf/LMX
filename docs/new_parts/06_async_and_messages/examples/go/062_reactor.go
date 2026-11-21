func Reactor(ready <-chan int, readReady func(int) int,
             unregister func(int), write func(int)) {
    for fd := range ready {
        n := readReady(fd)
        if n > 0 { write(n) }
        if n < 0 { unregister(fd) }
    }
}
