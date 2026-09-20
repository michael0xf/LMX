package graph;

/**
 * Expression/call fixtures. Callee links are physical {@link L3Node} references.
 */
public final class L3ExprFixture {
    private L3ExprFixture() {}

    /** Leaf: {@code return subject[0]}. */
    public static L3Node leafReturnField0() {
        L3Node subject = L3Node.of(L3Role.SUBJECT_REF);
        L3Node field0 = new L3Node(L3Role.FIELD_FOLLOW, 0, subject);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, field0));
    }

    /**
     * Entry: {@code return CALL(leaf, subject) + 5}.
     * {@code call.children[0] == leaf} by object identity.
     */
    public static L3Node callerAddCallPlus5() {
        L3Node leaf = leafReturnField0();
        L3Node subject = L3Node.of(L3Role.SUBJECT_REF);
        L3Node call = L3Node.of(L3Role.CALL, leaf, subject);
        L3Node five = L3Node.ofInt(L3Role.INT_LITERAL, 5);
        L3Node add = L3Node.of(L3Role.ADD, call, five);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, add));
    }

    /** Same as {@link #callerAddCallPlus5()} plus an unreachable orphan CALLABLE. */
    public static CallGraphWithOrphan callerWithUnreachableOrphan() {
        L3Node entry = callerAddCallPlus5();
        L3Node orphan = leafReturnField0();
        return new CallGraphWithOrphan(entry, orphan);
    }

    public static L3Node unsupportedRoleGraph() {
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, L3Node.of(L3Role.UNSUPPORTED)));
    }

    /** CALL with zero args (arity reject). */
    public static L3Node callBadArity() {
        L3Node leaf = leafReturnField0();
        L3Node call = L3Node.of(L3Role.CALL, leaf); // missing subject arg
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, call));
    }

    /** CALL whose child[0] is not a CALLABLE. */
    public static L3Node callBadCallee() {
        L3Node notCallable = L3Node.ofInt(L3Role.INT_LITERAL, 1);
        L3Node subject = L3Node.of(L3Role.SUBJECT_REF);
        L3Node call = L3Node.of(L3Role.CALL, notCallable, subject);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, call));
    }

    public static final class CallGraphWithOrphan {
        public final L3Node entry;
        public final L3Node orphan;

        public CallGraphWithOrphan(L3Node entry, L3Node orphan) {
            this.entry = entry;
            this.orphan = orphan;
        }
    }
}
