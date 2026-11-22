package main
type Order struct { Quantity, Price int }
func (o *Order) Total() int { return o.Quantity * o.Price }
type Repository interface { Save(*Order) }
type Memory struct { Last *Order }
func (m *Memory) Save(o *Order) { m.Last = o }
func submit(o *Order, r Repository) int { r.Save(o); return o.Total() }
func demo() int { return submit(&Order{3, 10}, &Memory{}) }
