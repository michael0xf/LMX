static class Example {
    sealed class OrderPage {
        public int Handle(int quantity) {
            if (quantity < 1) return 0;
            return quantity * 10;
        }
    }
    public static int Demo() => new OrderPage().Handle(3);
}
