static int Route(int id, System.Func<string,string,int> post) {
    return id switch {
        1 => post("https://orders.example", "/orders/get"),
        2 => post("https://stock.example", "/stock/get"),
        _ => 404
    };
}
