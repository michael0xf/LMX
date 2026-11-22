func Route(id int, post func(string, string) int) int {
    routes := map[int][2]string{
        1: {"https://orders.example", "/orders/get"},
        2: {"https://stock.example", "/stock/get"},
    }
    target, ok := routes[id]
    if !ok { return 404 }
    return post(target[0], target[1])
}
