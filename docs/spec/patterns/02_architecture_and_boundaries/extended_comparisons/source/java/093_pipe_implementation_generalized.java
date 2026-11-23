import java.util.Objects;
import java.util.function.Function;
public final class Pipe {
    private Pipe() {}
    public static <A,B,C> Function<A,C> pipe(
        Function<? super A,? extends B> first,
        Function<? super B,? extends C> second) {
        Objects.requireNonNull(first); Objects.requireNonNull(second);
        return value -> second.apply(first.apply(value));
    }
}
