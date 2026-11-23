func Pool(input []int) []int {
    jobs := make(chan int, len(input))
    results := make(chan int, len(input))
    for worker := 0; worker < 2; worker++ {
        go func() { for job := range jobs { results <- job * job } }()
    }
    for _, job := range input { jobs <- job }; close(jobs)
    out := make([]int, 0, len(input))
    for range input { out = append(out, <-results) }
    return out
}
