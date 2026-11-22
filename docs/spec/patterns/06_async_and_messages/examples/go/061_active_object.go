type Request struct { value int; reply chan int }
type Active chan Request
func NewActive() Active {
    a := make(Active)
    go func() { for r := range a { r.reply <- r.value * 2 } }()
    return a
}
func (a Active) Submit(value int) <-chan int {
    reply := make(chan int, 1)
    a <- Request{value, reply}; return reply
}
