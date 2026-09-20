package graph;

/**
 * Expression/call/IF/ARG fixtures. Callee links are physical {@link L3Node} references.
 */
public final class L3ExprFixture {
    private L3ExprFixture() {}

    /** Leaf: {@code return subject[0]} via SUBJECT_REF (arity 1). */
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

    public static CallGraphWithOrphan callerWithUnreachableOrphan() {
        L3Node entry = callerAddCallPlus5();
        L3Node orphan = leafReturnField0();
        return new CallGraphWithOrphan(entry, orphan);
    }

    public static L3Node unsupportedRoleGraph() {
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, L3Node.of(L3Role.UNSUPPORTED)));
    }

    public static L3Node callBadArity() {
        L3Node leaf = leafReturnField0();
        L3Node call = L3Node.of(L3Role.CALL, leaf);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, call));
    }

    public static L3Node callBadCallee() {
        L3Node notCallable = L3Node.ofInt(L3Role.INT_LITERAL, 1);
        L3Node subject = L3Node.of(L3Role.SUBJECT_REF);
        L3Node call = L3Node.of(L3Role.CALL, notCallable, subject);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, call));
    }

    public static L3Node ifLiteralBranches(int cond, int thenVal, int elseVal) {
        L3Node iff = L3Node.of(
                L3Role.IF,
                L3Node.ofInt(L3Role.INT_LITERAL, cond),
                L3Node.ofInt(L3Role.INT_LITERAL, thenVal),
                L3Node.ofInt(L3Role.INT_LITERAL, elseVal));
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, iff));
    }

    public static L3Node ifTrueUntakenElseInvalid() {
        L3Node subject = L3Node.of(L3Role.SUBJECT_REF);
        L3Node cond = new L3Node(L3Role.FIELD_FOLLOW, 0, subject);
        L3Node thenLit = L3Node.ofInt(L3Role.INT_LITERAL, 42);
        L3Node elseBad = new L3Node(L3Role.FIELD_FOLLOW, 1, L3Node.of(L3Role.SUBJECT_REF));
        L3Node iff = L3Node.of(L3Role.IF, cond, thenLit, elseBad);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, iff));
    }

    public static L3Node ifFalseUntakenThenInvalid() {
        L3Node subject = L3Node.of(L3Role.SUBJECT_REF);
        L3Node cond = new L3Node(L3Role.FIELD_FOLLOW, 0, subject);
        L3Node thenBad = new L3Node(L3Role.FIELD_FOLLOW, 1, L3Node.of(L3Role.SUBJECT_REF));
        L3Node elseLit = L3Node.ofInt(L3Role.INT_LITERAL, 7);
        L3Node iff = L3Node.of(L3Role.IF, cond, thenBad, elseLit);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, iff));
    }

    public static L3Node ifNestedCallThen() {
        L3Node leaf = leafReturnField0();
        L3Node subject = L3Node.of(L3Role.SUBJECT_REF);
        L3Node call = L3Node.of(L3Role.CALL, leaf, subject);
        L3Node cond = new L3Node(L3Role.FIELD_FOLLOW, 0, L3Node.of(L3Role.SUBJECT_REF));
        L3Node elseLit = L3Node.ofInt(L3Role.INT_LITERAL, 99);
        L3Node iff = L3Node.of(L3Role.IF, cond, call, elseLit);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, iff));
    }

    public static L3Node ifBadArity() {
        L3Node iff = L3Node.of(
                L3Role.IF,
                L3Node.ofInt(L3Role.INT_LITERAL, 1),
                L3Node.ofInt(L3Role.INT_LITERAL, 2));
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, iff));
    }

    public static L3Node ifBadConditionSubjectRef() {
        L3Node iff = L3Node.of(
                L3Role.IF,
                L3Node.of(L3Role.SUBJECT_REF),
                L3Node.ofInt(L3Role.INT_LITERAL, 1),
                L3Node.ofInt(L3Role.INT_LITERAL, 0));
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, iff));
    }

    public static L3Node ifBadConditionUnsupported() {
        L3Node iff = L3Node.of(
                L3Role.IF,
                L3Node.of(L3Role.UNSUPPORTED),
                L3Node.ofInt(L3Role.INT_LITERAL, 1),
                L3Node.ofInt(L3Role.INT_LITERAL, 0));
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, iff));
    }

    /** Callee: {@code return ARG(1);} arity 2. */
    public static L3Node calleeReturnArg1() {
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, L3Node.ofInt(L3Role.ARG, 1)));
    }

    /** Entry: {@code return CALL(calleeReturnArg1, subject, 42)}. */
    public static L3Node callerDirectArgReturn() {
        L3Node callee = calleeReturnArg1();
        L3Node call = L3Node.of(
                L3Role.CALL,
                callee,
                L3Node.of(L3Role.SUBJECT_REF),
                L3Node.ofInt(L3Role.INT_LITERAL, 42));
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, call));
    }

    /** Callee: {@code return ARG(1) + ARG(2);} arity 3. */
    public static L3Node calleeAddArg1Arg2() {
        L3Node add = L3Node.of(
                L3Role.ADD, L3Node.ofInt(L3Role.ARG, 1), L3Node.ofInt(L3Role.ARG, 2));
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, add));
    }

    /** Entry: {@code return CALL(add, subject, 3, 4)} ? 7. */
    public static L3Node callerTwoArgsAdd() {
        L3Node callee = calleeAddArg1Arg2();
        L3Node call = L3Node.of(
                L3Role.CALL,
                callee,
                L3Node.of(L3Role.SUBJECT_REF),
                L3Node.ofInt(L3Role.INT_LITERAL, 3),
                L3Node.ofInt(L3Role.INT_LITERAL, 4));
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, call));
    }

    /**
     * Nested: inner {@code return ARG(1)+ARG(2)}; outer
     * {@code return CALL(inner, subject, CALL(inner, subject, 1, 2), 10)} ? 13.
     */
    public static L3Node callerNestedComputedArgs() {
        L3Node inner = calleeAddArg1Arg2();
        L3Node innerCall = L3Node.of(
                L3Role.CALL,
                inner,
                L3Node.of(L3Role.SUBJECT_REF),
                L3Node.ofInt(L3Role.INT_LITERAL, 1),
                L3Node.ofInt(L3Role.INT_LITERAL, 2));
        L3Node outerCall = L3Node.of(
                L3Role.CALL,
                inner,
                L3Node.of(L3Role.SUBJECT_REF),
                innerCall,
                L3Node.ofInt(L3Role.INT_LITERAL, 10));
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, outerCall));
    }

    /** Same subject identity across ARG call: callee returns subject[0] via ARG(0) field follow. */
    public static L3Node callerArgSubjectIdentity() {
        L3Node subjectArg = L3Node.ofInt(L3Role.ARG, 0);
        L3Node field0 = new L3Node(L3Role.FIELD_FOLLOW, 0, subjectArg);
        L3Node callee = L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, field0));
        L3Node call = L3Node.of(L3Role.CALL, callee, L3Node.of(L3Role.SUBJECT_REF));
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, call));
    }

    /** CALL missing int arg (callee arity 2, only subject passed). */
    public static L3Node callMissingArg() {
        L3Node callee = calleeReturnArg1();
        L3Node call = L3Node.of(L3Role.CALL, callee, L3Node.of(L3Role.SUBJECT_REF));
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, call));
    }

    /** CALL with extra int arg (callee arity 2, two ints passed). */
    public static L3Node callExtraArg() {
        L3Node callee = calleeReturnArg1();
        L3Node call = L3Node.of(
                L3Role.CALL,
                callee,
                L3Node.of(L3Role.SUBJECT_REF),
                L3Node.ofInt(L3Role.INT_LITERAL, 1),
                L3Node.ofInt(L3Role.INT_LITERAL, 2));
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, call));
    }

    /** Body uses ARG(-1). */
    public static L3Node argOutOfRangeNegative() {
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, L3Node.ofInt(L3Role.ARG, -1)));
    }

    /**
     * {@code return CALL(add, subject, PROBE, PROBE)} ? probes must tick 1 then 2 once each.
     * Callee returns ARG(1)+ARG(2).
     */
    public static L3Node callerProbeArgOrder() {
        L3Node callee = calleeAddArg1Arg2();
        L3Node call = L3Node.of(
                L3Role.CALL,
                callee,
                L3Node.of(L3Role.SUBJECT_REF),
                L3Node.of(L3Role.PROBE),
                L3Node.of(L3Role.PROBE));
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
