type Bulkhead chan struct{}
func NewBulkhead() Bulkhead { return make(chan struct{}, 1) }
func (b Bulkhead) Acquire() bool {
    select { case b <- struct{}{}: return true; default: return false }
}
func (b Bulkhead) Release() int { <-b; return 1 }
// a := NewBulkhead(); b := NewBulkhead()
