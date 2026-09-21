package graph;

/**
 * In-memory L3 graph node; {@link #role} is a physical shared record.
 * CALLABLE nodes may be built via {@link #unsealedCallable()} + {@link #seal(L3Node)}
 * so fixtures can form physical self/mutual CALL cycles without post-seal mutation.
 * After construction or successful seal, the child array content is frozen: no public
 * writable children surface; accessors {@link #childCount()} / {@link #child(int)} only.
 */
public final class L3Node {
    public final L3Role role;
    /** Private; replaced only during {@link #seal} of an unsealed CALLABLE shell. */
    private L3Node[] children;
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
        // Defensive copy: caller array alias cannot mutate this node after construction.
        this.children = children == null ? new L3Node[0] : children.clone();
        this.sealed = true;
    }

    /** Unsealed CALLABLE shell: children empty until {@link #seal} replaces with body. */
    private L3Node(boolean unsealedMarker) {
        this.role = L3Role.CALLABLE;
        this.intPayload = 0;
        this.children = new L3Node[0];
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

    /** Number of physical child nodes (frozen after construction/successful seal). */
    public int childCount() {
        return children.length;
    }

    /**
     * Physical child reference at {@code index}. Preferred hot-path accessor for printer
     * and fixtures (no array clone on traversal).
     */
    public L3Node child(int index) {
        if (index < 0 || index >= children.length) {
            throw new IndexOutOfBoundsException("child index " + index);
        }
        return children[index];
    }

    /**
     * Seal this unsealed CALLABLE with its single RETURN body. Exactly once.
     * Double-seal or seal on a non-shell node → {@link IllegalStateException}.
     * Null/malformed body → {@link IllegalArgumentException}; node stays unsealed
     * (no partial children written) so a later valid seal may still succeed once.
     */

    /**
     * Test-only: adopt {@code children} without cloning so ownership-cycle fixtures can
     * install a gray back-edge. Production graphs must use {@link #of} / {@link #seal}.
     * The returned node is sealed; the array remains the private backing store.
     */
    public static L3Node adoptChildrenForTest(L3Role role, L3Node[] children) {
        if (role == null || children == null) {
            throw new IllegalArgumentException("adoptChildrenForTest");
        }
        return new L3Node(role, 0, children, true);
    }

    /** Adopt or clone children; sealed at birth. */
    private L3Node(L3Role role, int intPayload, L3Node[] children, boolean adopt) {
        if (role == null) {
            throw new IllegalArgumentException("role");
        }
        this.role = role;
        this.intPayload = intPayload;
        this.children = adopt ? children : children.clone();
        this.sealed = true;
    }

    public void seal(L3Node returnBody) {
        if (role != L3Role.CALLABLE) {
            throw new IllegalStateException("seal only on CALLABLE");
        }
        if (sealed) {
            throw new IllegalStateException("CALLABLE already sealed");
        }
        // Validate before any children mutation — failed seal must not stick a child.
        if (returnBody == null || returnBody.role != L3Role.RETURN) {
            throw new IllegalArgumentException("seal requires single RETURN body");
        }
        // Replace with a fresh single-element array (not an alias to any caller array).
        this.children = new L3Node[] { returnBody };
        this.sealed = true;
    }
}
