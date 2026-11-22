import java.util.function.IntUnaryOperator;
class Example {
    static class Kernel {
        IntUnaryOperator extension = x -> x * 2;
        void install(IntUnaryOperator implementation) { extension = implementation; }
        int execute(int value) { return extension.applyAsInt(value); }
    }
    static int demo() {
        Kernel kernel = new Kernel();
        int first = kernel.execute(5);
        kernel.install(x -> x * 3);
        return first + kernel.execute(5);
    }
}
