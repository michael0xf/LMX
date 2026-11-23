package main
type Router struct { Migrated bool }
func (r *Router) Handle(route int) int {
    if route == 1 && r.Migrated { return 200 + route }
    return 100 + route
}
func demo() int {
    r := &Router{}
    before := r.Handle(1)
    r.Migrated = true
    return before + r.Handle(1) + r.Handle(2)
}
