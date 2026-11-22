import java.util.function.IntConsumer;
class Example {
    static final IntConsumer SILENT = value -> {};
    static int execute(int value, IntConsumer log) {
        log.accept(value);
        return value;
    }
    static int demo() { return execute(10, SILENT); }
}
