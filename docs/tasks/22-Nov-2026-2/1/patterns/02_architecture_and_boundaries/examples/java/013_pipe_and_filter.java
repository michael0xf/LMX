import examplelib.Pipe;
class Example {
    static int normalize(int value) { return Math.abs(value); }
    static int twice(int value) { return value * 2; }
    static int offset(int value) { return value + 1; }
    static int pipeline(int value) {
        return Pipe.apply(value, Example::normalize, Example::twice, Example::offset);
    }
    static int demo() { return pipeline(-3); }
}
