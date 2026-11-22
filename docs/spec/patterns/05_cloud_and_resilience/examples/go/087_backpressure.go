type Producer struct { credit int; send func(int) }
func (p *Producer) Grant() int { p.credit++; return p.credit }
func (p *Producer) Offer(value int) bool {
    if p.credit == 0 { return false }
    p.credit--; p.send(value); return true
}
