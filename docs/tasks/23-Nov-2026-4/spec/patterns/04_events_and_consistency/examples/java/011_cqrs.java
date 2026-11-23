import java.util.function.IntConsumer;
final class WriteModel {
    private int balance;
    private final IntConsumer publish;
    WriteModel(IntConsumer publish) { this.publish=publish; }
    void add(int amount) {
        if (amount<0) throw new IllegalArgumentException("amount");
        balance+=amount;
        publish.accept(balance);
    }
}
final class ReadModel {
    private int visible;
    int apply(int snapshot) { visible=snapshot; return visible; }
    int query() { return visible; }
}
