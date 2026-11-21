class Example {
    static int normalize(int value) { return Math.abs(value); }
    static int twice(int value) { return value * 2; }
    static int offset(int value) { return value + 1; }
    static int pipeline(int value) { return offset(twice(normalize(value))); }
    static int demo() { return pipeline(-3); }
}
