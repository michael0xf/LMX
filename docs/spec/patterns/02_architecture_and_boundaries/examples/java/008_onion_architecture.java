class Example {
    record Order(int quantity, int price) { int total() { return quantity * price; } }
    interface Repository { void save(Order order); }
    static class Memory implements Repository {
        Order last;
        public void save(Order order) { last = order; }
    }
    static int submit(Order order, Repository repository) {
        repository.save(order);
        return order.total();
    }
    static int demo() { return submit(new Order(3, 10), new Memory()); }
}
