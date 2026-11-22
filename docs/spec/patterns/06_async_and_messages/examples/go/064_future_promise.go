import "sync"
type Future struct { once sync.Once; done chan struct{}; value int }
func NewFuture() *Future { return &Future{done: make(chan struct{})} }
func (f *Future) Resolve(value int) {
    f.once.Do(func() { f.value = value; close(f.done) })
}
func (f *Future) Get() int { <-f.done; return f.value }
