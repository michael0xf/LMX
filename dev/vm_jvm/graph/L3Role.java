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
    /**
     * Return from the nearest current {@link #CALLABLE} activation.
     * Child[0] is the int result expression (evaluated exactly once).
     * May appear nested under SEQUENCE / IF / WHILE; exits the callable
     * (not merely a loop). Statement or value position; not a root wrapper-only form.
     * BREAK/CONTINUE remain nearest-WHILE and never cross a CALL boundary.
     */
    public static final L3Role RETURN = new L3Role();
    /**
     * Call another callable. Child[0] is a physical {@link L3Node} reference to a
     * {@link #CALLABLE} (object identity; may be self or mutual). Remaining children
     * are positional argument expressions: args[0] is the subject (occurrence-producing),
     * args[1..] are ints. Fresh args/locals per activation; subject identity preserved.
     */
    public static final L3Role CALL = new L3Role();
    /**
     * Integer IF: children are condition, then, else.
     * Condition is an int expression (zero = false, nonzero = true).
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
     */
    public static final L3Role PROBE = new L3Role();
    /**
     * Sequential evaluation: children left-to-right; yields the last expression's int.
     * At least one child. Non-final children may be statements (e.g. WHILE).
     */
    public static final L3Role SEQUENCE = new L3Role();
    /**
     * Read activation-local int slot. {@code intPayload} is the compile-time slot index.
     * Mapped to a distinct JVM local after subject/args for this callable.
     */
    public static final L3Role LOCAL_GET = new L3Role();
    /**
     * Write activation-local int slot. {@code intPayload} is the compile-time slot index;
     * child[0] is the RHS (evaluated once). Yields the stored int.
     */
    public static final L3Role LOCAL_SET = new L3Role();
    /**
     * Pre-test loop: children are condition, body. Condition is an int (zero=false).
     * Statement only — valid solely as a non-final SEQUENCE child; no int result.
     * Ordinary JVM back-edge; no fuel cap. UNTIL/FOR deferred.
     */
    public static final L3Role WHILE = new L3Role();
    /**
     * Exit the nearest active WHILE (statement-only). Compile-time loop-label stack;
     * no named labels. REDO/RETRY/cleanup deferred.
     */
    public static final L3Role BREAK = new L3Role();
    /**
     * Jump to the nearest WHILE condition recheck (statement-only).
     */
    public static final L3Role CONTINUE = new L3Role();
    public static final L3Role UNSUPPORTED = new L3Role();

    private L3Role() {}
}
