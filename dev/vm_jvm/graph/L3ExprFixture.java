package graph;

/**
 * Expression/call/IF fixtures. Callee links are physical {@link L3Node} references.
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
        L3Node call = L3Node.of(L3Role.CALL, leaf);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, call));
    }

    /** CALL whose child[0] is not a CALLABLE. */
    public static L3Node callBadCallee() {
        L3Node notCallable = L3Node.ofInt(L3Role.INT_LITERAL, 1);
        L3Node subject = L3Node.of(L3Role.SUBJECT_REF);
        L3Node call = L3Node.of(L3Role.CALL, notCallable, subject);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, call));
    }

    /**
     * {@code return IF(condLit, thenLit, elseLit)}.
     * Condition is an INT_LITERAL (zero/nonzero).
     */
    public static L3Node ifLiteralBranches(int cond, int thenVal, int elseVal) {
        L3Node iff = L3Node.of(
                L3Role.IF,
                L3Node.ofInt(L3Role.INT_LITERAL, cond),
                L3Node.ofInt(L3Role.INT_LITERAL, thenVal),
                L3Node.ofInt(L3Role.INT_LITERAL, elseVal));
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, iff));
    }

    /**
     * {@code return IF(subject[0], 42, subject[0])} where untaken else would CHECKCAST-fail
     * if evaluated when child(0) is a non-Integer (e.g. String).
     * Used with true path: subject[0]=1 (Integer) ? then=42; else never runs.
     * For false path use {@link #ifFalseUntakenThenInvalid()}.
     */
    public static L3Node ifTrueUntakenElseInvalid() {
        L3Node subject = L3Node.of(L3Role.SUBJECT_REF);
        L3Node cond = new L3Node(L3Role.FIELD_FOLLOW, 0, subject);
        L3Node thenLit = L3Node.ofInt(L3Role.INT_LITERAL, 42);
        L3Node elseBad = new L3Node(L3Role.FIELD_FOLLOW, 1, L3Node.of(L3Role.SUBJECT_REF));
        // else reads subject[1]; fixture subject will only have slot 0 as Integer when true,
        // and slot 1 as String ? CHECKCAST Integer fails if else evaluated.
        L3Node iff = L3Node.of(L3Role.IF, cond, thenLit, elseBad);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, iff));
    }

    /**
     * {@code return IF(subject[0], subject[1], 7)} ? when cond=0, then is untaken;
     * then reads subject[1] which is a String (would fail CHECKCAST if evaluated).
     */
    public static L3Node ifFalseUntakenThenInvalid() {
        L3Node subject = L3Node.of(L3Role.SUBJECT_REF);
        L3Node cond = new L3Node(L3Role.FIELD_FOLLOW, 0, subject);
        L3Node thenBad = new L3Node(L3Role.FIELD_FOLLOW, 1, L3Node.of(L3Role.SUBJECT_REF));
        L3Node elseLit = L3Node.ofInt(L3Role.INT_LITERAL, 7);
        L3Node iff = L3Node.of(L3Role.IF, cond, thenBad, elseLit);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, iff));
    }

    /**
     * {@code return IF(subject[0], CALL(leaf, subject), 99)}.
     * Nonzero subject[0] selects nested CALL (returns subject[0]).
     */
    public static L3Node ifNestedCallThen() {
        L3Node leaf = leafReturnField0();
        L3Node subject = L3Node.of(L3Role.SUBJECT_REF);
        L3Node call = L3Node.of(L3Role.CALL, leaf, subject);
        L3Node cond = new L3Node(L3Role.FIELD_FOLLOW, 0, L3Node.of(L3Role.SUBJECT_REF));
        L3Node elseLit = L3Node.ofInt(L3Role.INT_LITERAL, 99);
        L3Node iff = L3Node.of(L3Role.IF, cond, call, elseLit);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, iff));
    }

    /** IF with only two children (arity reject). */
    public static L3Node ifBadArity() {
        L3Node iff = L3Node.of(
                L3Role.IF,
                L3Node.ofInt(L3Role.INT_LITERAL, 1),
                L3Node.ofInt(L3Role.INT_LITERAL, 2));
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, iff));
    }

    /** IF whose condition is SUBJECT_REF alone (not an int expression in this slice). */
    public static L3Node ifBadConditionSubjectRef() {
        L3Node iff = L3Node.of(
                L3Role.IF,
                L3Node.of(L3Role.SUBJECT_REF),
                L3Node.ofInt(L3Role.INT_LITERAL, 1),
                L3Node.ofInt(L3Role.INT_LITERAL, 0));
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, iff));
    }

    /** IF whose condition is UNSUPPORTED. */
    public static L3Node ifBadConditionUnsupported() {
        L3Node iff = L3Node.of(
                L3Role.IF,
                L3Node.of(L3Role.UNSUPPORTED),
                L3Node.ofInt(L3Role.INT_LITERAL, 1),
                L3Node.ofInt(L3Role.INT_LITERAL, 0));
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, iff));
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
