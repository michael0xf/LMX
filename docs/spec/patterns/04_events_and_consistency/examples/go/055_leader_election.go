package patterns
type Coordinator interface { Acquire(int) int; Release(int,int) }
type Resource interface { WriteIfCurrent(int,int) bool }
func Attempt(c Coordinator,r Resource,id int) bool {
    token:=c.Acquire(id)
    if token==0 { return false }
    result:=r.WriteIfCurrent(token,id)
    c.Release(id,token)
    return result
}
