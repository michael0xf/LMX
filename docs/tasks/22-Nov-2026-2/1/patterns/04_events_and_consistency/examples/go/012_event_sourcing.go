package patterns
import "fmt"
type EventStore interface { Read() []int; Append(int,int) bool }
type EventAccount struct { Store EventStore }
func (a *EventAccount) Balance() int {
    result:=0
    for _,delta:=range a.Store.Read() { result+=delta }
    return result
}
func (a *EventAccount) Append(expected,delta int) (int,error) {
    if !a.Store.Append(expected,delta) { return 0,fmt.Errorf("conflict") }
    return a.Balance(),nil
}
