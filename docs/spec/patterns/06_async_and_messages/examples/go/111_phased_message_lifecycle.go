type PhaseEvent struct { Kind, Child, Value int; Epoch int64; OK bool }
type ParentPorts struct {
    Drain func(int, int64)
    CloseChildren func(int64)
    CloseOwner func()
    Finished func(bool)
    Status func(int, int, int)
}
func RunPhaseParent(in <-chan PhaseEvent, epoch int64, p ParentPorts) {
    phase, drain, stop := 0, 2, 2
    failed := false
    var drained, stopped [2]bool
    for e := range in {
        switch e.Kind {
        case 0:
            if phase != 0 { continue }
            phase = 1; p.Drain(0, epoch); p.Drain(1, epoch)
        case 1:
            if phase != 1 || e.Epoch != epoch || e.Child < 0 || e.Child > 1 || drained[e.Child] { continue }
            drained[e.Child] = true; failed = failed || !e.OK; drain--
            if drain == 0 { phase = 2; p.CloseChildren(epoch) }
        case 2:
            if phase != 2 || e.Epoch != epoch || e.Child < 0 || e.Child > 1 || stopped[e.Child] { continue }
            stopped[e.Child] = true; stop--
            if stop == 0 { phase = 3; p.Finished(!failed); p.CloseOwner() }
        case 3:
            p.Status(phase, drain, stop)
        }
    }
}
type ChildPorts struct {
    Flush func(int64)
    ReleaseCompleted func()
    Drained func(int, int64, bool)
    Value func(int)
    Rejected func()
    Status func(int, int)
}
func RunPhaseChild(in <-chan PhaseEvent, id int, epoch int64, p ChildPorts) {
    phase := 0
    for e := range in {
        switch e.Kind {
        case 0:
            if phase != 0 { p.Rejected() } else { p.Value(e.Value * 2) }
        case 1:
            if phase == 0 && e.Epoch == epoch { phase = 1; p.Flush(epoch) }
        case 2:
            if phase == 1 && e.Epoch == epoch {
                p.ReleaseCompleted(); phase = 2; p.Drained(id, epoch, e.OK)
            }
        case 3:
            p.Status(id, phase)
        }
    }
}
