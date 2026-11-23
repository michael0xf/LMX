package patterns
import "fmt"
type Transport interface { Get(string,int) (any,error) }
func Get(targets []string,transport Transport,id int) (any,error) {
    if id<0 || len(targets)==0 { return nil,fmt.Errorf("shard") }
    return transport.Get(targets[id%len(targets)],id)
}
