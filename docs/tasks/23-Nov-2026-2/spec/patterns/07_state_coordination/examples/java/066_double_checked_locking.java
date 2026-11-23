final class Lazy {
    private volatile Integer value;
    private final java.util.function.IntSupplier build;
    Lazy(java.util.function.IntSupplier build) { this.build = build; }
    int get() {
        Integer result = value;
        if (result == null) {
            synchronized (this) {
                result = value;
                if (result == null) value = result = build.getAsInt();
            }
        }
        return result;
    }
}
