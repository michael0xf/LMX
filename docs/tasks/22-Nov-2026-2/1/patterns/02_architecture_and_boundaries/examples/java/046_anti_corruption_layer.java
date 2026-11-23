class Example {
    static int legacyDollars() { return 12; }
    static int cents() { return legacyDollars() * 100; }
    static int total(int quantity) { return quantity * cents(); }
    static int demo() { return total(2); }
}
