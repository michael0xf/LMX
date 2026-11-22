package patterns
type InboxDB interface {
    Atomic(func() error) error
    TryInsert(int,int) (bool,error)
    AddBalance(int) error
}
type Broker interface { Ack(int) error }
func Receive(db InboxDB,broker Broker,subscriber,eventID,delta int) error {
    err:=db.Atomic(func() error {
        inserted,err:=db.TryInsert(subscriber,eventID)
        if err!=nil { return err }
        if !inserted { return nil }
        return db.AddBalance(delta)
    })
    if err!=nil { return err }
    return broker.Ack(eventID)
}
