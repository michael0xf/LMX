package main
type Delivery func(destination string, quantity int)
func publish(quantity int, delivery Delivery) {
    delivery("audit", quantity)
    delivery("stock", quantity)
}
type Consumer struct { Total int }
func (c *Consumer) ReceiveEvent(quantity int) { c.Total += quantity }
