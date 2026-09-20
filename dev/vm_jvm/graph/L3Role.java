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
     * {@link #CALLABLE}. Remaining children are positional argument expressions:
     * args[0] is the subject (occurrence-producing), args[1..] are ints.
     * Recursion deferred.
     */
    public static final L3Role CALL = new L3Role();
    /**
     * Integer IF: children are condition, then, else.
     * Condition is an int expression (zero = false, nonzero = true). WHILE deferred.
     */
    public static final L3Role IF = new L3Role();
    /**
     * Positional parameter. {@code intPayload} is the compile-time index:
     * 0 = subject (LmxOccurrence local), 1.. = int locals.
     * No runtime name/text lookup.
     */
    public static final L3Role ARG = new L3Role();
    /**
     * Smoke-only int probe: increments {@link ArgEvalCounter} and returns the new count.
     * Used to prove CALL argument expressions evaluate exactly once, left-to-right.
     */
    public static final L3Role PROBE = new L3Role();
    public static final L3Role UNSUPPORTED = new L3Role();

    private L3Role() {}
}
