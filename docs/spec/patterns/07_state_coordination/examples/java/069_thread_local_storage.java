final class LocalCounter {
    private static final ThreadLocal<Integer> count = ThreadLocal.withInitial(() -> 0);
    static int next() {
        int value = count.get() + 1; count.set(value); return value;
    }
    static void clear() { count.remove(); }
}
