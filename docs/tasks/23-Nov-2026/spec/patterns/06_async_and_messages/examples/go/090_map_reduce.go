import "sync"
func MapReduce(parts [][]int) map[int]int {
    keys := make(chan int)
    var wg sync.WaitGroup
    for _, part := range parts {
        wg.Add(1)
        go func(xs []int) {
            defer wg.Done()
            for _, x := range xs { keys <- x % 2 }
        }(part)
    }
    go func(){ wg.Wait(); close(keys) }()
    totals := map[int]int{0:0,1:0}
    for key := range keys { totals[key]++ }
    return totals
}
