class OrderPage {
    handle(quantity: number) {
        if (quantity < 1) return 0;
        return quantity * 10;
    }
}
function demo() { return new OrderPage().handle(3); }
