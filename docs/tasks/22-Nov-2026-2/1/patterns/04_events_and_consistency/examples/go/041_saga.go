package patterns
type Saga struct { Phase int; Publish func(int) }
func (s *Saga) Handle(kind int,ok bool) {
    action:=0
    if kind==0 && s.Phase==0 { s.Phase=1; action=1 }
    if kind==1 && s.Phase==1 {
        if ok { s.Phase=2; action=2 } else { s.Phase=4; action=4 }
    }
    if kind==2 && s.Phase==2 {
        if ok { s.Phase=5; action=5 } else { s.Phase=3; action=3 }
    }
    if kind==3 && s.Phase==3 && ok { s.Phase=4; action=4 }
    if action!=0 { s.Publish(action) }
}
