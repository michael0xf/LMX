func ProducerConsumer() int {
    items := make(chan int, 2)
    go func() { for _, v := range []int{1, 2, 3} { items <- v }; close(items) }()
    total := 0
    for v := range items { total += v }
    return total
}
