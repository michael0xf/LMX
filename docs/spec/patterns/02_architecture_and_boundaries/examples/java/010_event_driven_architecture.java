class Example {
    interface Delivery { void send(String destination, int quantity); }
    static void publish(int quantity, Delivery delivery) {
        delivery.send("audit", quantity);
        delivery.send("stock", quantity);
    }
    static class Consumer {
        int total;
        void receiveEvent(int quantity) { total += quantity; }
    }
}
