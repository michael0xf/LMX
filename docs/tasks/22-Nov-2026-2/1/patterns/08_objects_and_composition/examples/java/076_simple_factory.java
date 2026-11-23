class Example {
    record Product(int cost) {}
    static Product create(int kind) { return new Product(kind == 0 ? 5 : 9); }
    static int demo() { return create(0).cost() + create(1).cost(); }
}
