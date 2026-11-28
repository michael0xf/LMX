type StashEvent struct { Kind, ID, Value, Mode int }
func RunSelective(in <-chan StashEvent, emit func(string, int, int)) {
    phase := 0
    queue := make([]StashEvent, 0, 2)
    wake := make(chan struct{}, 1)
    pump := func() { select { case wake <- struct{}{}: default: } }
    for {
        select {
        case event, open := <-in:
            if !open { return }
            switch event.Kind {
            case 0:
                if phase == 2 { emit("rejected", event.ID, 2); continue }
                if phase == 1 && len(queue) == 0 {
                    emit("finished", event.ID, event.Value * 2); continue
                }
                if len(queue) == 2 { emit("rejected", event.ID, 1); continue }
                queue = append(queue, event)
                if phase == 1 { pump() }
            case 1:
                if phase != 2 && event.Mode >= 0 && event.Mode <= 1 {
                    phase = event.Mode
                    if phase == 1 && len(queue) > 0 { pump() }
                }
            case 2:
                emit("reply", event.ID, event.Value)
            case 3:
                emit("status", phase, len(queue))
            case 4:
                if phase == 2 { continue }
                phase = 2
                for _, item := range queue { emit("rejected", item.ID, 2) }
                queue = queue[:0]
                emit("stopped", 0, 0)
            }
        case <-wake:
            if phase != 1 || len(queue) == 0 { continue }
            item := queue[0]; queue = queue[1:]
            emit("finished", item.ID, item.Value * 2)
            if len(queue) > 0 { pump() }
        }
    }
}
