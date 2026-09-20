package graph;

/** In-memory L3 graph node; {@link #role} is a physical shared record. */
public final class L3Node {
    public final L3Role role;
    public final L3Node[] children;
    /** Literal int or field index, depending on role. */
    public final int intPayload;

    public L3Node(L3Role role, int intPayload, L3Node... children) {
        if (role == null) {
            throw new IllegalArgumentException("role");
        }
        this.role = role;
        this.intPayload = intPayload;
        this.children = children == null ? new L3Node[0] : children.clone();
    }

    public static L3Node of(L3Role role, L3Node... children) {
        return new L3Node(role, 0, children);
    }

    public static L3Node ofInt(L3Role role, int value) {
        return new L3Node(role, value);
    }
}
