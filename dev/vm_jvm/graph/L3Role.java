package graph;

/**
 * Physical shared role records. Dispatch only by identity ({@code ==}).
 */
public final class L3Role {
    public static final L3Role CALLABLE = new L3Role();
    public static final L3Role SUBJECT_REF = new L3Role();
    public static final L3Role INT_LITERAL = new L3Role();
    public static final L3Role FIELD_FOLLOW = new L3Role();
    public static final L3Role ADD = new L3Role();
    public static final L3Role RETURN = new L3Role();
    /**
     * Call another callable. Child[0] is a physical {@link L3Node} reference to a
     * {@link #CALLABLE} (same object identity in the graph). Remaining children are
     * argument expressions (this slice: exactly one subject). Recursion deferred.
     */
    public static final L3Role CALL = new L3Role();
    public static final L3Role UNSUPPORTED = new L3Role();

    private L3Role() {}
}
