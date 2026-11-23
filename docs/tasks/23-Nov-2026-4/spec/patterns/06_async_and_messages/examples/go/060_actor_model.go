type Command struct { delta int; read bool; reply chan int }
func Counter(in <-chan Command) {
    total := 0
    for c := range in {
        if !c.read { total += c.delta }
        c.reply <- total
    }
}
