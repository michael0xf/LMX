import java.util.function.IntSupplier;
class Example {
    static class Client {
        final IntSupplier read;
        Client(IntSupplier read) { this.read = read; }
        int execute() { return read.getAsInt() * 2; }
    }
    static int demo() { return new Client(() -> 5).execute() + new Client(() -> 7).execute(); }
}
