package graph;

/**
 * Physical shared role records for L3 graph nodes.
 * Compare by identity ({@code ==}), never by runtime text/name lookup.
 */
public final class L3Role {
    public static final L3Role PROGRAM = new L3Role();
    public static final L3Role CHECK_INT = new L3Role();
    public static final L3Role CHECK_VOID_STEP = new L3Role();
    public static final L3Role CHECK_INDEPENDENT = new L3Role();
    public static final L3Role CHECK_NESTED = new L3Role();
    public static final L3Role CHECK_BOUNDS = new L3Role();
    public static final L3Role CHECK_FIELD_FOLLOW = new L3Role();
    public static final L3Role CHECK_MERGE = new L3Role();

    private L3Role() {}
}
