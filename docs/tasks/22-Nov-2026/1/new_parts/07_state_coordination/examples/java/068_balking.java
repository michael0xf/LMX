final class Save {
    private final java.util.concurrent.atomic.AtomicBoolean busy =
        new java.util.concurrent.atomic.AtomicBoolean();
    boolean start() { return busy.compareAndSet(false, true); }
    int finish() { busy.set(false); return 1; }
}
