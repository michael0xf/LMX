import java.util.function.IntSupplier;
class Example {
    static class Locator {
        IntSupplier resolve(int key) { return key == 1 ? () -> 42 : () -> 0; }
    }
    static int client(Locator locator) { return locator.resolve(1).getAsInt(); }
    static int demo() { return client(new Locator()); }
}
