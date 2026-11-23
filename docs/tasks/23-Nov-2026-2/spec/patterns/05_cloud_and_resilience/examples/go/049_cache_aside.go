type Store interface { Read() int; Write(int) }
type Cache struct { store Store; ready bool; value int }
func (c *Cache) Get() int {
    if !c.ready { c.value = c.store.Read(); c.ready = true }
    return c.value
}
func (c *Cache) Put(v int) int { c.store.Write(v); c.ready = false; return v }
