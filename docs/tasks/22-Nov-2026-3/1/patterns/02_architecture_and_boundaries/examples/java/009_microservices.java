class Example {
    interface Exchange { int quote(String endpoint, String route, int quantity); }
    static int catalog(int quantity) { return quantity * 10; }
    static int buy(int quantity, Exchange exchange) {
        return exchange.quote("https://catalog.example", "/quote", quantity);
    }
}
