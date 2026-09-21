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
     * Pre-test loop: children are condition, body[, LOOP_LABEL]. Condition is an int (zero=false).
     * Statement only — valid solely as a non-final SEQUENCE child; no int result.
     * Ordinary JVM back-edge; no fuel cap. FOR deferred.
     */
    public static final L3Role WHILE = new L3Role();
    /**
     * Post-test loop (semantics §12): children condition, body[, LOOP_LABEL] (same shape as WHILE).
     * Body runs first; then condition; repeat while condition is zero. Body executes at least once.
     * Statement only. BREAK/CONTINUE/REDO reuse the physical LOOP_LABEL framework with WHILE.
     */
    public static final L3Role UNTIL = new L3Role();
    /**
     * Exit the nearest active WHILE or UNTIL (statement-only). Compile-time loop-label stack;
     * unlabelled or physical LOOP_LABEL.
     */
    public static final L3Role BREAK = new L3Role();
    /**
     * Jump to the nearest active loop condition check (WHILE pretest / UNTIL postcondition).
     * Statement-only.
     */
    public static final L3Role CONTINUE = new L3Role();
    /**
     * Repeat the nearest active WHILE/UNTIL body without checking the condition (statement-only).
     * Unlabelled or physically labelled; cannot cross a CALL boundary.
     */
    public static final L3Role REDO = new L3Role();
    /**
     * Physical loop label record. Sealed leaf; object identity only (no text/numeric id).
     * Referenced by labelled WHILE/UNTIL and labelled BREAK/CONTINUE/REDO.
     */
    public static final L3Role LOOP_LABEL = new L3Role();
    /**
     * Physical retry-region label. Sealed leaf; distinct from {@link #LOOP_LABEL}.
     * Referenced by labelled {@link #RETRYABLE} and labelled {@link #RETRY}.
     */
    public static final L3Role RETRY_LABEL = new L3Role();
    /**
     * Restartable statement region (semantics §15). Children: body[, RETRY_LABEL].
     * Statement-only in this slice. FINALLY/cleanup deferred.
     */
    public static final L3Role RETRYABLE = new L3Role();
    /**
     * Jump to the beginning of an active {@link #RETRYABLE} body in the same CALLABLE.
     * Unlabelled = nearest; one child = physical {@link #RETRY_LABEL}. No new activation;
     * locals/args/probes are not rolled back. FINALLY deferred.
     */
    public static final L3Role RETRY = new L3Role();
    public static final L3Role UNSUPPORTED = new L3Role();

    private L3Role() {}
}
