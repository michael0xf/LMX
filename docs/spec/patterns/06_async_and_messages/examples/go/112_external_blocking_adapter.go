type BlockingEvent struct { Kind, Value int }
type BlockingResult struct { Token int64; OK bool; Value int }
func RunBlocking(in <-chan BlockingEvent, call func(int) (int, error),
    emit func(string, int64, bool, int), releaseIdle func()) {
    done := make(chan BlockingResult, 1)
    var next int64
    active, closing := false, false
    finish := func() { releaseIdle(); emit("closed", 0, true, 0) }
    for {
        select {
        case e, open := <-in:
            if !open { in = nil; closing = true; if !active { finish(); return }; continue }
            switch e.Kind {
            case 0:
                if active || closing { emit("rejected", 0, false, 1); continue }
                if next == 9223372036854775807 { emit("rejected", 0, false, 2); continue }
                next++; active = true
                go func(token int64, value int) {
                    result := BlockingResult{Token: token}
                    defer func() { if recover() != nil { result.OK = false }; done <- result }()
                    v, err := call(value)
                    result.OK, result.Value = err == nil, v
                }(next, e.Value)
            case 1:
                closing = true
                if !active { finish(); return }
            case 2:
                emit("status", next, active, map[bool]int{false:0,true:1}[closing])
            }
        case result := <-done:
            if !active || result.Token != next { continue }
            active = false
            emit("finished", result.Token, result.OK, result.Value)
            if closing { finish(); return }
        }
    }
}
