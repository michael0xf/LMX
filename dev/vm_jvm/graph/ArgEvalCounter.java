package graph;

/** Mutable counter for CALL argument evaluation-order smokes. */
public final class ArgEvalCounter {
    private static int count;

    private ArgEvalCounter() {}

    public static void reset() {
        count = 0;
    }

    /** Increments and returns the new value (1 on first tick after reset). */
    public static int tick() {
        return ++count;
    }

    public static int get() {
        return count;
    }
}
