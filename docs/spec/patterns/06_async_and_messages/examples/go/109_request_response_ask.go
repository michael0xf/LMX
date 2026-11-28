type AskReply struct { Token int64; Value int }
type AskEvent struct { Kind int; Token int64; Value int; Reply AskReply }
type AskPorts struct {
    Compute func(int64, int)
    Schedule func(int64)
    Finished func(int64, bool, int)
    Rejected func(int)
    Status func(bool, int64)
}
func RunAsk(in <-chan AskEvent, p AskPorts) {
    var next, current int64
    active := false
    for event := range in {
        switch event.Kind {
        case 0:
            if active { p.Rejected(1); continue }
            if next == 9223372036854775807 { p.Rejected(2); continue }
            next++; current = next; active = true
            p.Schedule(current)
            p.Compute(current, event.Value)
        case 1:
            if active && event.Reply.Token == current {
                active = false
                p.Finished(current, false, event.Reply.Value)
            }
        case 2:
            if active && event.Token == current {
                active = false
                p.Finished(current, true, 0)
            }
        case 3:
            p.Status(active, current)
        }
    }
}
func DoubleReply(token int64, value int) AskReply {
    return AskReply{Token: token, Value: value * 2}
}
