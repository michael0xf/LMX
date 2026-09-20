package graph;

/**
 * Minimal callable expression graph:
 * {@code return subject[0] + 5} where subject is the callable argument.
 * Not Java source; not Translator-L1; not CHECK_* selftest roles.
 */
public final class L3ExprFixture {
    private L3ExprFixture() {}

    /**
     * CALLABLE ? RETURN ? ADD( FIELD_FOLLOW(0, SUBJECT_REF), INT_LITERAL(5) )
     */
    public static L3Node callableAddField0Plus5() {
        L3Node subject = L3Node.of(L3Role.SUBJECT_REF);
        L3Node field0 = new L3Node(L3Role.FIELD_FOLLOW, 0, subject);
        L3Node five = L3Node.ofInt(L3Role.INT_LITERAL, 5);
        L3Node add = L3Node.of(L3Role.ADD, field0, five);
        L3Node ret = L3Node.of(L3Role.RETURN, add);
        return L3Node.of(L3Role.CALLABLE, ret);
    }

    /** Graph that must be rejected at print time. */
    public static L3Node unsupportedRoleGraph() {
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, L3Node.of(L3Role.UNSUPPORTED)));
    }
}
