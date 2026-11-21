package patterns
import "fmt"
type Ticket struct { Key,Size int }
type Blobs interface { Put(string) (int,error); Get(int) (string,error) }
func Send(blobs Blobs,publish func(Ticket) error,payload string) error {
    key,err:=blobs.Put(payload); if err!=nil { return err }
    return publish(Ticket{key,len(payload)})
}
func Receive(blobs Blobs,consume func(string) error,ticket Ticket) error {
    payload,err:=blobs.Get(ticket.Key); if err!=nil { return err }
    if len(payload)!=ticket.Size { return fmt.Errorf("payload") }
    return consume(payload)
}
