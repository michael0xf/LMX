import java.util.function.IntSupplier;
class Example {
    static int quote(int quantity, IntSupplier price) {
        return quantity * price.getAsInt();
    }
    static int memory() { return 10; }
    static int alternate() { return 12; }
    static int demo() { return quote(2, Example::memory) + quote(2, Example::alternate); }
}
