package graph;

/**
 * Physical shared role records for the L3 expression/callable subset.
 * Dispatch only by identity ({@code ==}); never by name/text.
 */
public final class L3Role {
    public static final L3Role CALLABLE = new L3Role();
    /** Formal/subject argument reference (the callable's subject). */
    public static final L3Role SUBJECT_REF = new L3Role();
    public static final L3Role INT_LITERAL = new L3Role();
    /** Field-follow by numeric index; {@link L3Node#intPayload} is the index. */
    public static final L3Role FIELD_FOLLOW = new L3Role();
    public static final L3Role ADD = new L3Role();
    public static final L3Role RETURN = new L3Role();
    /** Present only so printers can prove rejection of an unsupported role. */
    public static final L3Role UNSUPPORTED = new L3Role();

    private L3Role() {}
}
