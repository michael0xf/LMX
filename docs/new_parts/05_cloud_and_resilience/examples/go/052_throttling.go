type Throttle struct { window, count int }
func (t *Throttle) Allow(now int) bool {
    current := now / 10
    if current != t.window { t.window = current; t.count = 0 }
    if t.count >= 2 { return false }
    t.count++; return true
}
