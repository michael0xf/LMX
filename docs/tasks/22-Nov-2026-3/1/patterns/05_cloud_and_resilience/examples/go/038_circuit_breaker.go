type Breaker struct { failures, until int }
func (b *Breaker) Invoke(now int, request func() int) int {
    if now < b.until { return -1 }
    if request() == 1 { b.failures = 0; b.until = 0; return 1 }
    b.failures++
    if b.failures >= 2 { b.until = now + 5 }
    return 0
}
