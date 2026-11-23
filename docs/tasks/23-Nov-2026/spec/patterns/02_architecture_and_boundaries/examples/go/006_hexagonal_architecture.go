package main
func quote(quantity int, price func() int) int { return quantity * price() }
func memory() int { return 10 }
func alternate() int { return 12 }
func demo() int { return quote(2, memory) + quote(2, alternate) }
