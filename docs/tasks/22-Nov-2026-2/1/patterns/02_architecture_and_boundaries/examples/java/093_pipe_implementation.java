package examplelib;
import java.util.function.IntUnaryOperator;
public final class Pipe {
    public static int apply(int value, IntUnaryOperator... stages) {
        for (IntUnaryOperator stage : stages) value = stage.applyAsInt(value);
        return value;
    }
}
