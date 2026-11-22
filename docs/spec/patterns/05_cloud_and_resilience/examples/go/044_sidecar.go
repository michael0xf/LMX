func App(record int, sendLocal func(int)) { sendLocal(record) }
func Sidecar(in <-chan int, write func(int)) {
    for record := range in { write(record) }
}
