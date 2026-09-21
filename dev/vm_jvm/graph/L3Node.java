package graph;

/**
 * In-memory L3 graph node; {@link #role} is a physical shared record.
 * CALLABLE nodes may be built via {@link #unsealedCallable()} + {@link #seal(L3Node)}
 * so fixtures can form physical self/mutual CALL cycles without post-seal mutation.
 */
public final class L3Node {
    public final L3Role role;
    public final L3Node[] children;
    /** Literal int or field index, depending on role. */
    public final int intPayload;
    /** False only for {@link #unsealedCallable()} before {@link #seal(L3Node)}. */
    private boolean sealed;

    public L3Node(L3Role role, int intPayload, L3Node... children) {
        if (role == null) {
            throw new IllegalArgumentException("role");
        }
        this.role = role;
        this.intPayload = intPayload;
        this.children = children == null ? new L3Node[0] : children.clone();
        this.sealed = true;
    }

    /** Unsealed CALLABLE shell: single child slot filled exactly once by {@link #seal}. */
    private L3Node(boolean unsealedMarker) {
        this.role = L3Role.CALLABLE;
        this.intPayload = 0;
        this.children = new L3Node[1];
        this.sealed = false;
        if (unsealedMarker) {
            // marker consumed; sealed stays false
        }
    }

    public static L3Node of(L3Role role, L3Node... children) {
        return new L3Node(role, 0, children);
    }

    public static L3Node ofInt(L3Role role, int value) {
        return new L3Node(role, value);
    }

    /**
     * Forward CALLABLE for recursive/mutual graphs. Must {@link #seal(L3Node)} exactly
     * once with a single RETURN body before print/emit. Children stay physical L3Node refs.
     */
    public static L3Node unsealedCallable() {
        return new L3Node(true);
    }

    public boolean isSealed() {
        return sealed;
    }

    /**
     * Seal this unsealed CALLABLE with its single RETURN body. Exactly once.
     * Double-seal or seal on a non-shell node → {@link IllegalStateException}.
     */
    public void seal(L3Node returnBody) {
        if (role != L3Role.CALLABLE) {
            throw new IllegalStateException("seal only on CALLABLE");
        }
        if (sealed) {
            throw new IllegalStateException("CALLABLE already sealed");
        }
        if (returnBody == null || returnBody.role != L3Role.RETURN) {
            throw new IllegalArgumentException("seal requires single RETURN body");
        }
        children[0] = returnBody;
        sealed = true;
    }
}
