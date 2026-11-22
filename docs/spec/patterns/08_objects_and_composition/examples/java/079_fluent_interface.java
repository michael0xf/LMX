class Example {
    static class Options {
        int count, price;
        Options withCount(int value) { count = value; return this; }
        Options withPrice(int value) { price = value; return this; }
        int total() { return count * price; }
    }
    static int demo() { return new Options().withCount(3).withPrice(7).total(); }
}
