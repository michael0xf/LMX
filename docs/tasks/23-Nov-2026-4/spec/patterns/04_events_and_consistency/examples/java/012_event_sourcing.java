interface EventStore {
    int[] read();
    boolean append(int expected,int delta);
}
final class EventAccount {
    private final EventStore store;
    EventAccount(EventStore store) { this.store=store; }
    int balance() {
        int result=0;
        for (int delta:store.read()) result+=delta;
        return result;
    }
    int append(int expected,int delta) {
        if (!store.append(expected,delta)) throw new IllegalStateException("conflict");
        return balance();
    }
}
