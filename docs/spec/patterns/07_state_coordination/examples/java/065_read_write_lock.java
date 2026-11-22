final class Value {
    private final java.util.concurrent.locks.ReentrantReadWriteLock lock =
        new java.util.concurrent.locks.ReentrantReadWriteLock();
    private int value = 10;
    int read() {
        lock.readLock().lock();
        try { return value; } finally { lock.readLock().unlock(); }
    }
    int write(int next) {
        lock.writeLock().lock();
        try { value = next; return value; }
        finally { lock.writeLock().unlock(); }
    }
}
