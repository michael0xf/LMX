package main
func legacyDollars() int { return 12 }
func cents() int { return legacyDollars() * 100 }
func total(quantity int) int { return quantity * cents() }
func demo() int { return total(2) }
