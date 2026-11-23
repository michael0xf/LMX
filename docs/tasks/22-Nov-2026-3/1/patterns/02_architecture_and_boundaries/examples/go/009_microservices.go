package main
type Exchange func(endpoint, route string, quantity int) int
func catalog(quantity int) int { return quantity * 10 }
func buy(quantity int, exchange Exchange) int {
    return exchange("https://catalog.example", "/quote", quantity)
}
