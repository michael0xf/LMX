package lmx;

/**
 * Admitted immutable / method-style terminal for merge: retained by identity,
 * not deep-copied (docs/LMX_semantics.en.md ?19, ?22). Not a numeric type tag
 * and not stored in {@link LmxOccurrence#node()}.
 */
public final class LmxTerminal {
    private final Object payload;

    public LmxTerminal(Object payload) {
        this.payload = payload;
    }

    public Object payload() {
        return payload;
    }
}
