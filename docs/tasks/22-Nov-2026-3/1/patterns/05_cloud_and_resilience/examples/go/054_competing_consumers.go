func Worker(jobs <-chan int, process func(int), done chan<- bool) {
    for job := range jobs { process(job) }
    done <- true
}
func Start(jobs <-chan int, process func(int)) {
    done := make(chan bool, 2)
    go Worker(jobs, process, done); go Worker(jobs, process, done)
    <-done; <-done
}
