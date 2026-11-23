package patterns
type Event struct { ID,AccountID,Cents int }
type OutboxDB interface {
    Atomic(func() error) error
    UpdateAccount(int,int) error
    InsertOutbox(int,int,int) error
    Pending() ([]Event,error)
    MarkSent(int) error
}
func Execute(db OutboxDB,id,cents,eventID int) error {
    return db.Atomic(func() error {
        if err:=db.UpdateAccount(id,cents); err!=nil { return err }
        return db.InsertOutbox(eventID,id,cents)
    })
}
func Relay(db OutboxDB,publish func(Event) error) error {
    batch,err:=db.Pending(); if err!=nil { return err }
    for _,event:=range batch {
        if err=publish(event); err!=nil { return err }
        if err=db.MarkSent(event.ID); err!=nil { return err }
    }
    return nil
}
